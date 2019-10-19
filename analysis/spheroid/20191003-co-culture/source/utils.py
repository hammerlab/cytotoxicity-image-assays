import os
import os.path as osp
import numpy as np
import matplotlib
from cytokit import io as ck_io
from cytokit import config as ck_config
from cytokit.function import core as ck_core
from cytokit.ops import tile_generator, tile_crop
from skimage import util, transform
import tqdm

def get_config(r):
    config = ck_config.load(osp.join(os.environ['EXP_GROUP_CONF_DIR'], 'experiment.yaml'))
    config._conf['acquisition']['num_z_planes'] = r['n_z']
    config._conf['environment'] = {}
    config._conf['environment']['path_formats'] = "get_default_path_formats('1_" + r['grid'] + "_{tile:05d}_Z{z:03d}_CH{channel:d}.tif')"
    config._conf['processor']['cytometry']['target_shape'] = [1008, 1344]
    config.register_environment(force=True)
    return config

def get_tile(config, raw_dir, tile_index):
    cropper = tile_crop.CytokitTileCrop(config)
    tile = tile_generator.CytokitTileGenerator(config, raw_dir, 0, tile_index).run()
    tile = cropper.run(tile)
    assert tile.ndim == 5, str(tile.shape)
    return tile
    
def get_tile_iterator(config, raw_dir):
    for ti in config.get_tile_indices():
        yield get_tile(config, raw_dir, ti.tile_index), ti

def get_maxz_fn(config, channel):
    def fn(tile):
        ich = config.channel_names.index(channel)
        img = tile[0, :, ich]
        img = util.img_as_float(img)
        if channel == 'BF':
            img = util.invert(img)
        img = img.max(axis=0)
        return img
    return fn
        
def get_tiles(config, raw_dir):
    iterator = get_tile_iterator(config, raw_dir)
    return list(tqdm.tqdm(iterator, total=config.n_tiles_per_region))

def get_channel_maxz_images(config, raw_dir, channel):
    iterator = get_tile_iterator(config, raw_dir)
    maxz_fn = get_maxz_fn(config, channel)
    iterator = map(lambda tile: (maxz_fn(tile[0]), tile[1]), iterator)
    return iterator

def rand_cmap(seed=0):
    np.random.seed(seed)
    return matplotlib.colors.ListedColormap(np.random.rand(256,3))
