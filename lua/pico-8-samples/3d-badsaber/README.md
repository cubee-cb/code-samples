# Picodachi Cabin and Bad Saber - 3D rendering experiments
All of these use an external trifill routine created by someone else for efficiency.

- badsaber - The first VR PICO-8 game. Beat Saber demake built from MBoffin's Simple FPS Controller cart. Originally intended to display in-headset and interface with WebXR via JavaScript, but I couldn't figure out how to draw the screen directly to the HMD. Perhaps for the best?
- convert.p8 - Third 3D attempt. Interprets an OBJ file and renders it.
- dotprod.p8 - Contains a dot product function.
- project.p8 - Fourth 3D renderer attempt. Has backface culling, near clipping, simple depth sorting, and normal-based shading.
- project-cull2.p8 - Near identical to project, but faces marked "textured" flash colours and the model rotates to demo the shading.
