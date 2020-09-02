module beziermeshmaker.datastructures.input.polymesh;

import beziermeshmaker.datastructures.vec3;
import beziermeshmaker.datastructures.input.polygon;

class PolyMesh {
	Polygon[] polygons;

	/*
	 * Vertices of a polygon needn't be planar or have a bounded number, but the polygon should be convex.
	 */
	public void addPolygon(Polygon poly) {
		polygons ~= [poly];
	}
}