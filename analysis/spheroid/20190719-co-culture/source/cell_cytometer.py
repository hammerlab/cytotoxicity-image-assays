import numpy as np
from scipy import ndimage as ndi
from skimage import filters
from skimage import measure
from skimage import exposure
from skimage import transform
from skimage import feature
from skimage import morphology
from skimage import draw
from skimage import util
from skimage import segmentation
from skimage import img_as_float
from cytokit.cytometry import cytometer
import logging
logger = logging.getLogger(__name__)

class CellCytometer(cytometer.Cytometer):
    
    def _segment(self, img):
        img = exposure.rescale_intensity(img, in_range=str(img.dtype), out_range=np.uint8).astype(np.uint8)
        img = filters.median(img, selem=morphology.disk(3))
        img = util.img_as_float(img)
        img = filters.gaussian(img, sigma=1)
        
        blobs = feature.blob_dog(img, min_sigma=5, max_sigma=12, sigma_ratio=1.2, threshold=.005, overlap=.5)
        img_ctr = np.zeros(img.shape, dtype=np.uint16)
        for i, blob in enumerate(blobs):
            y, x, r = blob
            rr, cc = draw.circle(y, x, r, shape=img_ctr.shape)
            img_ctr[rr, cc] = i
            
        img_mask = morphology.binary_dilation(img_ctr > 0, morphology.disk(6))
        img_dist = ndi.distance_transform_edt(img_mask)
        img_seg = segmentation.watershed(-img_dist, img_ctr, mask=img_mask).astype(np.uint16)

        img_ctr_bnd = img_ctr * segmentation.find_boundaries(img_ctr, mode='inner', background=0)
        img_seg_bnd = img_seg * segmentation.find_boundaries(img_seg, mode='inner', background=0)
        res = np.stack([img_seg, img_ctr, img_seg_bnd, img_ctr_bnd]) 
        assert res.dtype == np.uint16, 'Expecting 16bit result but got {}'.format(res.dtype)
        return res
        
    def segment(self, img, **kwargs):
        assert img.ndim == 3, 'Expecting 3D image but got shape {}'.format(img.shape)
        assert img.dtype in [np.uint8, np.uint16]
        return np.stack([self._segment(img[z]) for z in range(img.shape[0])])
    
    def quantify(self, tile, segments, **kwargs):
        return cytometer.CytometerBase.quantify(tile, segments, **kwargs)
    
    def augment(self, df):
        return cytometer.CytometerBase.augment(df, self.config.microscope_params)