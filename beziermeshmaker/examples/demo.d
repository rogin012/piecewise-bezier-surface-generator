module examples.demo;

import std.stdio;
import std.format;

import beziermeshmaker.datastructures.input.polymesh;
import beziermeshmaker.datastructures.input.polygon;
import beziermeshmaker.datastructures.quadcell;
import beziermeshmaker.datastructures.quadmesh;
import beziermeshmaker.datastructures.biquarticbeziersurface;

class Demo {

	public static void example() {
		Polygon a = new Polygon([[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0]]);
		Polygon b = new Polygon([[0, 0, 0], [1, 0, 0], [1, -1, 0], [0, -1, 0]]);

		//Optional, this is a way to track which output quads correspond to which input polygon
		a.metadata["name"] = "a";
		b.metadata["name"] = "b";

		convert([a, b]);
	}

	private static BiquarticBezierSurface[] convert(Polygon[] polys) {
		PolyMesh mesh = new PolyMesh();

		foreach (Polygon poly ; polys) {
			mesh.addPolygon(poly);
		}

		QuadMesh quadMesh = new QuadMesh(mesh);

		BiquarticBezierSurface[] surfaces;
		foreach (QuadCell cell ; quadMesh.cells) {
			if (cell.hasAllNeighbors() ){
				writeln(format("Original poly %s, quad index %s", cell.metadata["name"], cell.metadata[QuadCell.VERTEX_METADATA_KEY]));
				surfaces ~= [cell.surfacePatch];
			}
		}

		return surfaces;
	}
}
