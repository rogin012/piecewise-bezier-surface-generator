module beziermeshmaker.datastructures.biquarticbeziersurface;

import beziermeshmaker.datastructures.vec3;

class BiquarticBezierSurface {
	vec3[5][5] controlPoints;

	BiquarticBezierSurface[4] neighbors;
}
