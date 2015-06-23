#!/bin/sh

./reconstruction_GPU2 -o 3TReconstruction.nii.gz -i output_segmentation/masked_stack-1.nii.gz output_segmentation/masked_stack-2.nii.gz output_segmentation/masked_stack-3.nii.gz output_segmentation/masked_stack-4.nii.gz --disableBiasCorrection --useAutoTemplate --useSINCPSF --resolution 2.0 --debug 0 --numThreads 32 --useCPU

