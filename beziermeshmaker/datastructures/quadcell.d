module beziermeshmaker.datastructures.quadcell;

import std.math;
import std.stdio;

import beziermeshmaker.datastructures.meshpoint;
import beziermeshmaker.datastructures.vec3;
import beziermeshmaker.datastructures.biquarticbeziersurface;

import modules.testing.DebugLog;

class QuadCell {
	//Vertices should be defined so vertices[0] is the P vertex associated with an original mesh vertex
	//This means that vertices[2] is the P vertex associated with the centroid of a cell in the original mesh
	//Note that we can't depend on which order vertices[1] and vertices[3] are in, since that depends on the order of the original polygon's vertices (or equivalently, on its normal direction)
	MeshPoint[4] vertices;
	private QuadCell[4] neighbors;

	float a1Blend;
	float a2Blend;

	vec3 center; //Ci in the paper

	vec3[MeshPoint] pPrime;
	vec3[MeshPoint] cPrime;

	bool border = false; //Set to true if this is an extra cell added to extend the border, that should be trimmed later.
	BiquarticBezierSurface surfacePatch;

	this() {
		this(0.5, 0.5); //Defaults suggested by the paper
	}
	this(float a1Blend, float a2Blend) {
		this.a1Blend = a1Blend;
		this.a2Blend = a2Blend;
		surfacePatch = new BiquarticBezierSurface();
	}

	//The following methods are to be called once everything is properly linked.
	//However, each of them needs to be called on all quads in order before moving on to the next, since each depends on the previous.
	public void calculateCenter() {
		center = (1 - a1Blend) * (1 - a2Blend) 	* vertices[0].pt +
				(1 - a1Blend) * a2Blend 		* vertices[1].pt +
				a1Blend * a2Blend 				* vertices[2].pt +
				a1Blend * (1 - a2Blend) 		* vertices[3].pt;
	}
	public void calculatePrimes() {
		pPrime[vertices[0]] = getPPrime(vertices[0]);
		pPrime[vertices[2]] = getPPrime(vertices[2]);

		cPrime[vertices[0]] = getCPrime(vertices[0], pPrime[vertices[0]]);
		cPrime[vertices[2]] = getCPrime(vertices[2], pPrime[vertices[2]]);
	}

	//Helpers for the above
	private vec3 getPPrime(MeshPoint p) {
		vec3 sum = new vec3(0, 0, 0);
		foreach (QuadCell cell ; p.neighbors) {
			sum = sum + cell.center;
		}
		sum = sum / p.neighbors.length;

		return (1 - p.betaBlend) * p.pt + p.betaBlend * sum;
	}
	private vec3 getCPrime(MeshPoint p, vec3 pPrime) {
		int currentQuadIndex = p.getIndex(this);
		vec3 sum = new vec3(0, 0, 0);
		for (int i = 1; i <= p.neighbors.length; i++) {
			float cosTerm = cos( (PI * 2 * i) / p.neighbors.length);
			vec3 vertex = p.neighbors[ (currentQuadIndex + i) % p.neighbors.length].center;

			sum = sum + (cosTerm * vertex);
		}

		return pPrime + (p.alphaBlend / p.neighbors.length) * sum;
	}

	/*
	 * The intermediate control points b1 and b2 are generated in the paper by averaging over the C and C' of neighboring cells around P
	 * To avoid having to sort the neighbors of the P points consistently, we instead calculate b1 & b2 relative to the edge between P and M
	 * This is a little redundant, but it means the neighbor order doesn't matter, which drastically simplifies things.
	 */
	public vec3 getB1(MeshPoint pPoint, MeshPoint mPoint) {
		return (cPrime[pPoint] + getNeighborSharingBoth(pPoint, mPoint).cPrime[pPoint]) / 2;
	}
	public vec3 getB2(MeshPoint pPoint, MeshPoint mPoint) {
		return (center + getNeighborSharingBoth(pPoint, mPoint).center) / 2;
	}

	//Returns the neighboring QuadCell that contains the two given points
	public QuadCell getNeighborSharingBoth(MeshPoint a, MeshPoint b) {
		foreach (QuadCell neighbor ; neighbors) {
			if (neighbor !is null && neighbor.containsVertex(a) && neighbor.containsVertex(b) ) {
				return neighbor;
			}
		}
		return null;
	}
	public QuadCell getNeighborSharingANotB(MeshPoint a, MeshPoint b) {
		foreach (QuadCell neighbor ; neighbors) {
			if (neighbor !is null && neighbor.containsVertex(a) && !neighbor.containsVertex(b) ) {
				return neighbor;
			}
		}
		return null;
	}
	public bool containsVertex(MeshPoint point) {
		foreach (MeshPoint cellVertex ; vertices) {
			if (cellVertex == point) {
				return true;
			}
		}
		return false;
	}

	public void setNeighbor(int index, QuadCell cell) {
		neighbors[index] = cell;
		surfacePatch.neighbors[index] = cell.surfacePatch;
	}
	public QuadCell getNeighbor(int index) {
		return neighbors[index];
	}
	public int getNeighborIndex(QuadCell cell) {
		for (int i = 0; i < neighbors.length; i++) {
			if (neighbors[i] == cell) {
				return i;
			}
		}
		return -1;
	}
	public bool hasAllNeighbors() {
		foreach (QuadCell neighbor ; neighbors) {
			if (neighbor is null) {
				return false;
			}
		}
		return true;
	}
}