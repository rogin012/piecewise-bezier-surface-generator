module beziermeshmaker.datastructures.quadmesh;

import std.math;
import std.container;
import std.conv;
import std.algorithm;

public import beziermeshmaker.datastructures.meshpoint;
public import beziermeshmaker.datastructures.quadcell;
import beziermeshmaker.datastructures.input.polygon;
import beziermeshmaker.datastructures.input.polymesh;
import beziermeshmaker.datastructures.vec3;

import modules.testing.DebugLog;

/*
 * The algorithm implemented here is from the paper Biquartic C1 Spline Surfaces Over Irregular Meshes, by Jörg Peters 1994
 */
class QuadMesh {
	QuadCell[] cells;

	MeshPoint[vec3] meshPoints;

	float gammaBlend = 0.125; //Recommended default

	this(PolyMesh polyMesh) {
		//Construct all of the quad cells, making sure that any common corners map to the same MeshPoint
		subdivideMeshAndLinkVertices(polyMesh);

		//At this point, all of the MeshPoints' surrounding quads are set, and all of the QuadCell vertices are set.
		//It remains only to find the QuadCells' neighbors.
		linkQuads();

		//If adjacent quads have inconsistent vertex orders/normals, it breaks the connection guarantee Pi(0, t) = Pi+1(t, 0)
		//This can still happen for non-orientable surfaces, though all quads for a given input polygon will share the same final orientation.
		//This means that transitioning between quads with different orientations can only happen when X or Y equals 0, and the coordinate transformation
		//becomes source.xy = dest.xy, rather than source.xy = dest.yx
		orientNormals();

		//All neighbors of a mesh point are guaranteed to share it as a vertex, but they may be out of order (i.e. point.neighbors[0] and point.neighbors[1] don't have a common edge.
		foreach (MeshPoint point ; meshPoints) {
			sortMeshPointNeighbors(point);
		}

		//Now that everything is linked, we can start setting the intermediate control points.
		foreach (QuadCell cell ; cells) {
			cell.calculateCenter();
		}
		foreach (QuadCell cell ; cells) {
			cell.calculatePrimes();
		}
		//It's more trouble than it's worth to precalculate bValues
		//Honestly there's not much point in precalculating the others either...

		calculateControlPoints();
	}

	/*
	 * This subdivides the mesh such that each polygon becomes N quad patches, where N is the number of sides it had.
	 * This also links the vertices with their connected cells and vice versa.
	 */
	private void subdivideMeshAndLinkVertices(PolyMesh polyMesh) {
		foreach (Polygon poly ; polyMesh.polygons) {
			MeshPoint polyCenter = getOrDefineMeshPoint(poly.centroid, MeshPoint.P_TYPE_CENTROID);
			for (int i = 1; i <= poly.vertices.length; i++) {
				vec3 prev = poly.vertices[i - 1];
				vec3 curr = poly.vertices[i % poly.vertices.length];
				vec3 next = poly.vertices[(i + 1) % poly.vertices.length];

				MeshPoint originalVertex = getOrDefineMeshPoint(curr, MeshPoint.P_TYPE_ORIGINAL);
				MeshPoint mid1 = getOrDefineMeshPoint(curr.interpolate(0.5, next), MeshPoint.M_TYPE);
				MeshPoint mid2 = getOrDefineMeshPoint(curr.interpolate(0.5, prev), MeshPoint.M_TYPE);

				QuadCell cell = new QuadCell();
				cell.vertices = [originalVertex, mid1, polyCenter, mid2];
				cells ~= [cell];

				cell.metadata = poly.metadata.dup;
				cell.metadata[QuadCell.VERTEX_METADATA_KEY] = to!string(i);

				//Each cell will be added exactly once to each of the mesh points
				//They won't necessarily be in order, but that doesn't impact the rest of the algorithm
				foreach (MeshPoint point ; cell.vertices) {
					point.neighbors ~= [cell];
				}
			}
		}
	}
	private MeshPoint getOrDefineMeshPoint(vec3 pt, int type) {
		if (pt in meshPoints) {
			return meshPoints[pt];
		}
		else {
			meshPoints[pt] = new MeshPoint(pt, type);
			return meshPoints[pt];
		}
	}

	/*
	 * Goes through the list of quads and makes sure adjacent quads are linked to each other.
	 */
	private void linkQuads() {
		foreach (QuadCell cell ; cells) {
			for(int i = 0; i < 4; i++) {
				MeshPoint curr = cell.vertices[i];
				MeshPoint next = cell.vertices[ (i+1) % 4];

				//We know that the cell that should be connected has two vertices in common, so iterate through the cells with a common vertex and search for one with a second matching vertex.
				foreach (QuadCell sharedVertexCell ; curr.neighbors) {
					if (cell != sharedVertexCell && sharedVertexCell.containsVertex(next)) {
						cell.setNeighbor(i, sharedVertexCell);
						break;
					}
				}
			}
		}
	}

	/*
	 * Ensures that all quads have consistent orientation.  Note that there will still be inconsistencies if the surface is non-orientable.
	 */
	private void orientNormals() {
		bool[QuadCell] seen;

		QuadCell first = cells[0];

		DList!QuadCell toProcess;
		toProcess.insertFront(first);

		while(!toProcess.empty) {
			QuadCell current = toProcess.removeAny();
			assert(current !is null);
			seen[current] = true;

			for (int i = 0; i < 4; i++) {
				QuadCell neighbor = current.getNeighbor(i);
				if (neighbor !is null && neighbor !in seen) {
					if(neighbor.getNeighbor(i) == current) {
						//This ensures that we flip all quads that were part of an original polygon at the same time.
						//This means that even for non-orientable surfaces, there's a consistent rule for the coordinate transformation
						//between quads.
						MeshPoint pCentroid = neighbor.getCentroidPoint();
						foreach (QuadCell centroidNeighbor ; pCentroid.neighbors) {
							flipQuadVertexOrder(centroidNeighbor);
						}
					}
					seen[neighbor] = true;
					toProcess.insertFront(neighbor);
				}
			}
		}
	}
	private void flipQuadVertexOrder(QuadCell cell) {
		MeshPoint temp = cell.vertices[3];
		cell.vertices[3] = cell.vertices[1];
		cell.vertices[1] = temp;

		QuadCell tempNeighbor = cell.getNeighbor(0);
		cell.setNeighbor(0, cell.getNeighbor(3));
		cell.setNeighbor(3, tempNeighbor);
		tempNeighbor = cell.getNeighbor(1);
		cell.setNeighbor(1, cell.getNeighbor(2));
		cell.setNeighbor(2, tempNeighbor);
	}

	/*
	 * Goes through the set of quads and calculates the coefficients for their bezier patches.
	 */
	private void calculateControlPoints() {
		foreach (QuadCell cell ; cells) {
			if (!cell.hasAllNeighbors() ) {
				continue;
			}

			calculateControlPoints(cell, cell.vertices[0], cell.vertices[1], false);
			calculateControlPoints(cell, cell.vertices[0], cell.vertices[3], true);
			calculateControlPoints(cell, cell.vertices[2], cell.vertices[1], true);
			calculateControlPoints(cell, cell.vertices[2], cell.vertices[3], false);
		}
	}
	private void calculateControlPoints(QuadCell cell, MeshPoint pPoint, MeshPoint mPoint, bool flipIJ) {
		//The [0][0] control point is always at the P_TYPE_MESH point, and the [4][4] control point at the P_TYPE_CENTROID point
		bool invertIndices = (pPoint.ptType == MeshPoint.P_TYPE_CENTROID);

		float c = cos( (2 * PI) / pPoint.neighbors.length);
		//These are used because we don't have guarantees about the order of the neighbors of a point
		QuadCell mNotPNeighbor = cell.getNeighborSharingANotB(mPoint, pPoint);
		QuadCell mpNeighbor = cell.getNeighborSharingBoth(mPoint, pPoint);

		vec3 b00 = cell.pPrime[pPoint];
		vec3 b01 = (3 * cell.getB1(pPoint, mPoint) + b00) / 4;
		vec3 b02 = (3 * cell.getB2(pPoint, mPoint) + 3 * cell.getB1(pPoint, mPoint)) / 6;

		vec3 b04 = new vec3(0,0,0);
		for (int i = 0; i < mPoint.neighbors.length; i++) {
			b04 = b04 + mPoint.neighbors[i].center / 4;
		}
		vec3 b03 = (3 * cell.getB2(pPoint, mPoint) + b04) / 4;

		vec3 b11 = ((3 * c) / 8) * cell.center + ((6 - (3*c)) / 8) * cell.cPrime[pPoint] + b00 / 4;
		vec3 b12 = (c / 16) * mNotPNeighbor.center + ((8-c)/16) * cell.center + cell.cPrime[pPoint] / 2
			- gammaBlend * (cell.center - mpNeighbor.center + cell.cPrime[pPoint] - mpNeighbor.cPrime[pPoint]);
		vec3 b13 = (3 * cell.center + b04) / 4;

		vec3 b22 = cell.center;

		setControlPoint(cell, b00, 0, 0, flipIJ, invertIndices);
		setControlPoint(cell, b01, 0, 1, flipIJ, invertIndices);
		setControlPoint(cell, b02, 0, 2, flipIJ, invertIndices);
		setControlPoint(cell, b03, 0, 3, flipIJ, invertIndices);
		setControlPoint(cell, b04, 0, 4, flipIJ, invertIndices);
		setControlPoint(cell, b11, 1, 1, flipIJ, invertIndices);
		setControlPoint(cell, b12, 1, 2, flipIJ, invertIndices);
		setControlPoint(cell, b13, 1, 3, flipIJ, invertIndices);
		setControlPoint(cell, b22, 2, 2, flipIJ, invertIndices);
	}
	private void setControlPoint(QuadCell cell, vec3 value, int i, int j, bool flipIJ, bool invertIndices) {
		if (invertIndices) {
			i = 4 - i;
			j = 4 - j;
		}
		if (flipIJ) {
			int temp = i;
			i = j;
			j = temp;
		}

		if (cell.surfacePatch.controlPoints[i][j] !is null && cell.surfacePatch.controlPoints[i][j] != value) {
			writeNow("was %s, became: %s", cell.surfacePatch.controlPoints[i][j], value);
		}

		cell.surfacePatch.controlPoints[i][j] = value;
	}

	//This ensures that the neighbors of a MeshPoint are in order corresponding to their spatial orientation around the point.
	//When C' is calculated, the cosine term ensures the nearby neighbors in either direction have a scaled effect on the result.  Because
	//it's a cosine, the order doesn't matter, it just needs to be in order
	private void sortMeshPointNeighbors(MeshPoint point) {
		//3 is the minimum number of choices for there to be multiple orderings.
		if (point.neighbors.length <= 2) {
			return;
		}

		QuadCell[] newNeighbors;
		QuadCell current = null;

		//If this is a vertex where two of the quads don't meet each other, we have to start with one of the quads with a single neighbor
		//This happens in cases where there's a cleft in the surface.
		for (int i = 0; i < point.neighbors.length; i++) {
			QuadCell quad = point.neighbors[i];
			int neighborCount = 0;
			foreach (QuadCell testCell; point.neighbors) {
				neighborCount += (quad.getNeighborIndex(testCell) != -1 ? 1 : 0);
			}
			if (neighborCount == 1) {
				current = quad;
				point.neighbors = point.neighbors[0 .. i] ~ point.neighbors[i+1 .. $];
				break;
			}
		}

		if (current is null) {
			current = point.neighbors[0];
			point.neighbors = point.neighbors[1..$];
		}
		newNeighbors ~= [current];

		while (point.neighbors.length > 0) {
			bool found = false;
			for (int i = 0; i < point.neighbors.length; i++) {
				QuadCell testCell = point.neighbors[i];

				if (current.getNeighborIndex(testCell) != -1) {
					newNeighbors ~= [testCell];
					current = testCell;
					point.neighbors = point.neighbors[0 .. i] ~ point.neighbors[i+1 .. $];
					found = true;
					break;
				}
			}
			if (!found) {
				//This only happens if the vertex is adjacent to multiple quads, but there are at least two separate
				//groups of them that have no common boundaries.
				throw new Exception("Mesh vertex has two neighboring non-continuous faces");
			}
		}

		point.neighbors = newNeighbors;
	}
}