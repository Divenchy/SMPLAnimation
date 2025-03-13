# SMPL Animation Implementation
This MATLAB project aims to produce the following final result:


https://github.com/user-attachments/assets/657b1972-7e96-4313-9b5d-574fa352e74f

An animation produced using a base mesh (shown in blue) as well as two other calculated meshes (shown in red and yellow) based from the base mesh after a modifier beta applied. The motion of the meshes utilize two mocap animations and calculating the rotations using the supplied quaternions. The following is the content of the animation:

- For 95 frames, play first mocap with base mesh (blue)
- For 50 frames, blend from base mesh to beta1 mesh (red) while frozen in the mocap animation
- For 65 frames, play out the rest of the first mocap animation with the beta1 mesh
- For 50 frames, transition to the next mocap animation
- For 80 frames, play out the new mocap animation on current mesh
- For 50 frames, pause mocap and blend to beta2 mesh (yellow)
- For 80 frames, finish the second mocap animation with the beta2 mesh

Total of 470 frames.

# Citations
Cite data: https://smpl.is.tue.mpg.de

readObj.m: https://www.mathworks.com/matlabcentral/fileexchange/18957-readobj?s_tid=ta_fx_results

All other parsers and writeObj were created with ChatGPT.


## NOTES

- Some additional components may be needed in order for visualization and a matrix function used for calculations
