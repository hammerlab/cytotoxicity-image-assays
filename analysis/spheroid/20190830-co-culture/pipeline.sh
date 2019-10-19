#!/usr/bin/env bash
# cd $CYTOKIT_ANALYSIS_REPO_DIR/analysis/experiments/spheroid/20190830-co-culture; source env.sh && bash -e pipeline.sh

#EXPERIMENTS=`cat experiments.csv | tail -n +2 | grep '0250kT-0uM-np-XY07-1'`
#EXPERIMENTS=`cat experiments.csv | tail -n +2 | sort -R --random-source=/dev/zero | head -n 10`
#EXPERIMENTS=`cat experiments.csv | tail -n +2 | grep 'XY01-1'`
EXPERIMENTS=`cat experiments.csv | tail -n +2`


for EXP in $EXPERIMENTS
do
    EXP_NAME=`echo $EXP | cut -d',' -f 1`
    EXP_CFG=`echo $EXP | cut -d',' -f 2`
    EXP_DIR=`echo $EXP | cut -d',' -f 3`
    EXP_GRID=`echo $EXP | cut -d',' -f 4`
    EXP_NUMZ=`echo $EXP | cut -d',' -f 7`
    OUT_DIR=$EXP_GROUP_OUT_DIR/$EXP_NAME
    DATA_DIR=$EXP_GROUP_RAW_DIR/$EXP_DIR/$EXP_GRID
    BASE_CONF=$EXP_GROUP_CONF_DIR/$EXP_CFG
    
    # Add custom cytometer implementations to python path
    export PYTHONPATH=$EXP_GROUP_ANALYSIS_DIR/source
    
    cytokit config editor --base-config-path=$BASE_CONF --output-dir=$OUT_DIR \
    set name "$EXP_NAME" \
    set acquisition.num_z_planes $EXP_NUMZ \
    set environment.path_formats "get_default_path_formats('1_${EXP_GRID}_{tile:05d}_Z{z:03d}_CH{channel:d}.tif')" \
    save_variant v00/config \
    save_variant v02/config \
    set processor.cytometry.type '{"module": "cell_cytometer", "class": "CellCytometer"}' \
    save_variant v01/config \
    exit

    for VARIANT in v00
    do
        OUTPUT_DIR=$OUT_DIR/$VARIANT
        CONFIG_DIR=$OUTPUT_DIR/config
        
        if [ "$VARIANT" == "v02" ]; then
            echo "Processing experiment $EXP_NAME (config = $CONFIG_DIR, output dir = $OUTPUT_DIR)"
            cytokit processor run_all --config-path=$CONFIG_DIR --data-dir=$DATA_DIR --output-dir=$OUTPUT_DIR
            cytokit operator run_all  --config-path=$CONFIG_DIR --data-dir=$OUTPUT_DIR --raw-dir=$DATA_DIR
            cytokit analysis run_all  --config-path=$CONFIG_DIR --data-dir=$OUTPUT_DIR
        else
            echo "Processing experiment $EXP_NAME (config = $CONFIG_DIR, output dir = $OUTPUT_DIR)"
            mkdir -p $OUTPUT_DIR/logs
            papermill pipeline.ipynb $OUTPUT_DIR/logs/pipeline.ipynb \
                -p raw_dir $DATA_DIR \
                -p output_dir $OUTPUT_DIR \
                -p exp_name $EXP_NAME
        fi
    done
done