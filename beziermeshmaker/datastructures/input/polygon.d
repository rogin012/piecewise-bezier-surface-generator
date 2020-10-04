module beziermeshmaker.datastructures.input.polygon;

import beziermeshmaker.datastructures.vec3;

class Polygon {
	vec3[] vertices;
	vec3 centroid;

	//Used to carry forward information from the initial polygons to the output surfaces
	string[string] metadata;

	this(float[3][] vertices) {
		foreach (float[3] coords ; vertices) {
			this.vertices ~= new vec3(coords[0], coords[1], coords[2]);
		}

		centroid = getCentroid();
	}

	//Algorithm is from https://bell0bytes.eu/centroid-convex/
	private vec3 getCentroid() {
		vec3 weightedCenterSum = new vec3(0, 0, 0);
		float totalWeight = 0;

		//We're not doing anything special with the triangulation here since the polygons are supposed to be convex.
		vec3 root = vertices[0];
		for (int i = 0; i < vertices.length - 2; i++) {
			vec3 a = vertices[i+1];
			vec3 b = vertices[i+2];

			vec3 center = (root + a + b) / 3;
			float weight = 0.5 * (a - root).cross(b - root).length();

			weightedCenterSum = weightedCenterSum + (center * weight);
			totalWeight += weight;
		}

		return weightedCenterSum / totalWeight;
	}
}