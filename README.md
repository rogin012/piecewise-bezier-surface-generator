# bezier-surface-generator
## Introduction
This is an implementation of the algorithm described in the paper Biquartic C1 Spline Surfaces Over Irregular Meshes, by Jörg Peters (1994).  It takes a mesh specified as a set of polygons and converts this into a smooth set of biquartic bezier surfaces, with the mesh vertices effectively acting as the control points of the overall piecewise bezier surface set.

The input has a few constraints (see Usage), but in general allows for relatively arbitrary meshes.  Adjacency information is calculated as part of the algorithm.  The set of output surfaces will have consistent orientation, so long as the input mesh is orientable.

## Samples
The original mesh is outlined in yellow wireframe and the boundaries of the bezier surface patches are indicated with dark gray dotted lines.  The surface patch coloration is a function of the normal.

1. Standard cube<br/>
![Sample 1](samples/Cube.png)

2. Cylinder (octagonal prism)<br/>
![Sample 2](samples/Cylinder.png)
![Sample 3](samples/Cylinder2.png)

3. A simple triangle - in general, when the mesh isn't closed, the final bezier surface will tend to pull in from the corners.<br/>
![Sample 4](samples/Triangle.png)

4. Some more complex shapes, with their original surfaces also shown for clarity<br/>
![Sample 5](samples/Boxy.png)
![Sample 6](samples/BoxySurface.png)
![Sample 7](samples/Column.png)
![Sample 8](samples/ColumnSurface.png)

## Usage
See `beziermeshmaker/examples/demo.d`

Constraints on the input polygons:
* They must be convex.
* They can't be degenerate (i.e. no zero length sides, number of sides must be at least 3).
* If two polygons have a vertex at the same point in space, that's considered a shared vertex.  Two polygons that share a vertex must also share at least one adjacent vertex (i.e. they must also share an edge).
* Each edge can be shared by at most two polygons.

Aside from these limitations, this should work with arbitrary meshes (open/closed, multiple disjoint surfaces, arbitrary vertex valence, any number of polygon sides, etc...)

### Parameters from the Paper
The gamma blend parameter can be set when creating the QuadMesh.  The alpha/beta blend parameters can be altered by changing the static variables in MeshPoint, but of course this will apply that setting to all points.

## Misc.
`NotesAndClarifications.html` gives a little more detail on some parts of the paper that were unclear or ambiguous.
