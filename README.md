# bezier-surface-generator
## An implementation of the algorithm described in the paper Biquartic C1 Spline Surfaces Over Irregular Meshes, by Jörg Peters 1994

Here are some samples, with the original mesh outlined in yellow wireframe and the boundaries of the bezier surface patches indicated with dark gray dotted lines.  The surface patch coloration is a function of the normal.

1. A cube
![Sample 1](https://i.imgur.com/yxmUtIV.png)

2. A cylinder (octagonal prism)
![Sample 2](https://i.imgur.com/8WMD5fg.png)
![Sample 3](https://i.imgur.com/OQH11aI.png)

3. A simple triangle - in general, when the mesh isn't closed, the final bezier surface will tend to pull in from the corners.
![Sample 4](https://i.imgur.com/AyB565g.png)

4. Some more complex shapes, with their original surfaces also shown for clarity
![Sample 5](https://i.imgur.com/DRwagfF.png)
![Sample 6](https://i.imgur.com/mzn3rIi.png)
![Sample 7](https://i.imgur.com/WvWSto5.png)
![Sample 8](https://i.imgur.com/WSJsiPl.png)

## Usage
See `beziermeshmaker/examples/demo.d`

The gamma blend parameter can be set when creating the QuadMesh.  The alpha/beta blend parameters can be altered by changing the static variables in MeshPoint, but of course this will apply that setting to all points.

## Misc.
`NotesAndClarifications.html` gives a little more detail on some parts of the paper that were unclear or ambiguous.
