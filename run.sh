#!/bin/bash

set -e

do_detection=false
do_segmentation=false
do_reconstruction=false
debug=false

function usage {
    echo "Usage: $0 -a" >&2
    echo "" >&2
    echo "Valid options are: -1, -2, -3, -a, -d" >&2
    echo "    -1    to run only the detection step" >&2
    echo "    -2    to run only the segmentation step" >&2
    echo "    -3    to only the motion correction step" >&2
    echo "    -a    to run all steps" >&2
    echo "    -d    for debugging" >&2
    exit 1
}

# getopts (with an "s") only deals with short options
while getopts "123ad" opt
do
    case $opt in
        1)
            do_detection=true
            ;;
        2)
            do_segmentation=true
            ;;
        3)
            do_reconstruction=true
            ;;
        a)
            do_detection=true
            do_segmentation=true
            do_reconstruction=true
            ;;
        d)
            set -x
            debug=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

echo \
"This script is an example of a fully automated motion correction of the
fetal brain, as described in \"Automated Fetal Brain Segmentation from 2D MRI
Slices for Motion Correction\", K. Keraudren et al. (2014)"
echo ""

if [ "$do_detection" = false ] && [ "$do_segmentation" = false ] && [ "$do_reconstruction" = false ]
then
    usage
fi

# Parameters for all steps
ROOT_DIR="/home/handong"
SCRIPT_DIR="$ROOT_DIR/IRTK/wrapping/cython/scripts/"
BIN_DIR="$ROOT_DIR/IRTK/build/bin/"
ga=29.7
NEW_SAMPLING=0.8

##################################################################################
# Brain detection
vocabulary="model/vocabulary_0.npy"
mser_detector="model/mser_detector_0_linearSVM"
detection_folder="output_detection"

mkdir -p $detection_folder

if [ "$do_detection" = true ]
then
    echo "Performing brain detection"
    echo
    for filename in data/*.nii.gz
    do
        mask_file=${detection_folder}/`basename $filename`
	
        python $SCRIPT_DIR/parallel_fetalMask_detection.py \
            $filename \
            $ga \
            $mask_file \
            --classifier $mser_detector \
            --vocabulary $vocabulary \
            --new_sampling $NEW_SAMPLING
    done
fi

################################################################################

# Brain segmentation
segmentation_folder="output_segmentation"

mkdir -p $segmentation_folder

if [ "$do_segmentation" = true ]
then
    echo "Performing brain segmentation"
    echo
    for filename in data/*.nii.gz
    do
        mask_file=${detection_folder}/`basename $filename`

        python $SCRIPT_DIR/fetalMask_segmentation.py \
            --img $filename \
            --ga $ga \
            --mask $mask_file \
            --output_dir $segmentation_folder \
            --cpu 32 \
            --do_3D \
            --mass
    done
fi
