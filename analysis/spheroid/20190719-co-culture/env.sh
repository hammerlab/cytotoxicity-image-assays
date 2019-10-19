export EXP_GROUP="20190719-co-culture"
export EXP_GROUP_DIR=${CYTOKIT_DATA_DIR}/spheroid/${EXP_GROUP}
export EXP_GROUP_RAW_DIR=${EXP_GROUP_DIR}/raw
export EXP_GROUP_OUT_DIR=${EXP_GROUP_DIR}/output
export EXP_GROUP_CONF_DIR=/lab/repos/cytotoxicity-image-assays/config/spheroid/${EXP_GROUP}
export EXP_GROUP_ANALYSIS_DIR=/lab/repos/cytotoxicity-image-assays/analysis/spheroid/${EXP_GROUP}
export EXP_ILASTIK_DIR=${CYTOKIT_DATA_DIR}/spheroid/ilastik/mc38-co-culture
# Currently, all results were running using this model instead of 0822 like everything else:
# export EXP_SPHEROID_ILASTIK_PRJ=${EXP_ILASTIK_DIR}/project/20190719-co-culture-maxz-bf-20x-25s.ilp
export EXP_SPHEROID_ILASTIK_PRJ=${EXP_ILASTIK_DIR}/project/20190822-co-culture-maxz-bf-20x-25s.ilp