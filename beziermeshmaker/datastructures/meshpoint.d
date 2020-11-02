module beziermeshmaker.datastructures.meshpoint;

import beziermeshmaker.datastructures.quadcell;
import beziermeshmaker.datastructures.vec3;

class MeshPoint {
	public static immutable int P_TYPE_ORIGINAL = 1; //P type vertices that were vertices in the original mesh
	public static immutable int P_TYPE_CENTROID = 2; //P type vertices that were centroids in the original mesh
	public static immutable int M_TYPE = 3;

	//Experimentally determined defaults
	public static float ALPHA_BLEND_DEFAULT = 2;
	public static float BETA_BLEND_DEFAULT = 1;

	QuadCell[] neighbors;

	vec3 pt; //The actual location of the point
	int ptType;

	float alphaBlend, betaBlend;

	this (vec3 pt, int type) {
		this(pt, type, ALPHA_BLEND_DEFAULT, BETA_BLEND_DEFAULT);
	}
	this (vec3 pt, int type, float alphaBlend, float betaBlend) {
		this.pt = pt;
		this.ptType = type;
		this.alphaBlend = alphaBlend;
		this.betaBlend = betaBlend;
	}

	public int getIndex(QuadCell cell) {
		for (int i = 0; i < neighbors.length; i++) {
			if (neighbors[i] == cell) {
				return i;
			}
		}
		return -1;
	}
}
