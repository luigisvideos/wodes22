# A Matlab toolbox implementing MSCG computation

This tool has been developed by Luigi Ferrara (luigiferrara.info@gmail.com) at the end of his PhD in Computer Engineering at UNISA, as member of the Automatic Control Group.

The toolbox has been tested under full installation of Matlab R2021b; it requires the correct installation of additional toolboxes, such as the Symbolic Toolbox and the Optimization Toolbox.

The usage and modification of the tool is free but it is kindly requested to cite the paper "A Matlab toolbox implementing MSCG computation", by F. Basile, L. Ferrara submitted to WODES 2022.

All folders and subfolders of this code should be permanently added to the Matlab path to execute the provided code (see https://it.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html)
Alternatively, the script init.m should be run to temporarely add all folders and subfolders to the Matlab path.

Folder "examples" contains several scripts exploiting and showing the features of the code.
It also contains a script for each figure contained in the paper.
Script 'exampleWodes22_MSCGfig6.m' shows all features of the code, except infinite-server enablingness (all transitions are single server).
Script 'EXInfiniteServerSemantic.m' shows the infinite-server semantic feature.

The scripts generate also the MSCG as pdf figures in the current Matlab path

To stop the computation of the MSCG while busy press ctrl+c in the console
