# cd $CYTOKIT_ANALYSIS_REPO_DIR/analysis/experiments/spheroid/20190703-sta-titration; source env.sh && source explorer.sh && cytokit application run_explorer
#export APP_EXP_NAME="sta-00.125-20um-s-XY01"
#export APP_EXP_NAME="sta-00.000-20um-s-XY01"
#export APP_EXP_NAME="sta-01.000-20um-s-XY03"
export APP_EXP_NAME="sta-02.000-20um-s-XY02"
export APP_EXP_DATA_DIR=$EXP_GROUP_OUT_DIR/$APP_EXP_NAME/v00
export APP_EXP_CONFIG_PATH=$APP_EXP_DATA_DIR/config
export APP_EXTRACT_NAME=best_z_segm
export APP_MONTAGE_NAME=best_z_segm
export APP_PORT=8050
export APP_MONTAGE_CHANNEL_NAMES="proc_HOECHST,proc_SYTOX,cyto_cell_boundary"
export APP_MONTAGE_CHANNEL_COLORS="gray,red,cyan"
export APP_MONTAGE_CHANNEL_RANGES="0-65535,0-65535,0-1"
export APP_MONTAGE_POINT_COLOR="white"
export APP_GRAPH_POINT_SIZE=8