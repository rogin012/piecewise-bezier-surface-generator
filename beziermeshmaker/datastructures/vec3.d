module beziermeshmaker.datastructures.vec3;

import std.stdio;
import std.string;
import std.conv;
import std.math;

import modules.opengl.EitanOpenGLClasses;

/*
 *This acts as an ordinary Vector3f, except that it can also be passed into openGL functions
 */
class vec3{
	float* values;
	alias values this;
	
	this(){
		this(0, 0, 0);
	}
	this(float a, float b, float c){
		values = [a, b, c].ptr;
	}
	this(vec3 input){
		this(input.x, input.y, input.z);
	}
	
	@property{
		nothrow float x(){ return values[0]; }
		nothrow float x(float newX){ return values[0] = newX; }
		nothrow float y(){ return values[1]; }
		nothrow float y(float newY){ return values[1] = newY; }
		nothrow float z(){ return values[2]; }
		nothrow float z(float newZ){ return values[2] = newZ; }

		float u() { return x; }
		float u(float newU){ return x(newU); }
		float q() { return y; }
		float q(float newQ){ return y(newQ); }
		float v() { return z; }
		float v(float newV){ return z(newV); }
	}
	
	float dot(vec3 other){
		return (x * other.x) + (y * other.y) + (z * other.z);
	}
	vec3 cross(vec3 v){
		return new vec3(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
	}
	vec3 normalize(){
		return this / length();
	}
	//Returns a copy of this vector, interpolated by <amount> between this vector and <other>
	vec3 interpolate(float amount, vec3 other) {
		float inverse = 1 - amount;
		
		return new vec3(x * inverse + other.x * amount, y * inverse + other.y * amount, z * inverse + other.z * amount);
	}
	//Returns a copy of this vector, rotated around <axis> by <theta> radians.
	//This uses Rodrigues' rotation formula https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
	vec3 rotateAround(vec3 axis, float theta) {
		axis = axis.normalize();

		return (this * cos(theta) ) + (axis.cross(this) * sin(theta) ) + (axis * (axis.dot(this)) * (1 - cos(theta) ) );
	}
	float length(){
		return sqrt(x * x + y * y + z * z);
	}
	float angleBetween(vec3 other){
		float value = dot(other) / (length() * other.length() );
		
		return acos(value);
	}
	float distanceBetween(vec3 other) {
		float xDiff = x - other.x;
		float yDiff = y - other.y;
		float zDiff = z - other.z;
		
		return sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff);
	}
	
	vec3 opBinary(string op)(float val){
		if(op == "*"){
			return new vec3(x * val, y * val, z * val);
		}
		else if(op == "/"){
			return new vec3(x / val, y / val, z / val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec3 opBinaryRight(string op)(float val){
		if(op == "*"){
			return new vec3(x * val, y * val, z * val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec3 opBinary(string op)(vec3 val){
		if(op == "+"){
			return new vec3(x + val.x, y + val.y, z + val.z);
		}
		else if(op == "-"){
			return new vec3(x - val.x, y - val.y, z - val.z);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}

	override bool opEquals(Object o) {
		vec3 other = cast(vec3) o;

		if (other is null) {
			return false;
		}
		else {
			return approxEqual(x, other.x, 0.00001) && approxEqual(y, other.y, 0.00001) && approxEqual(z, other.z, 0.00001);
		}
	}
	override @trusted size_t toHash() {
		return cast(ulong)(x * 10000 + y * 10000 + z * 10000);
	}

	override string toString(){
		return "vec3(" ~ to!string(x) ~ ", " ~ to!string(y) ~ ", " ~ to!string(z) ~ ")";
	}
	string toNiceString(int chars){
		string xStr = to!string(x);
		string yStr = to!string(y);
		string zStr = to!string(z);
		
		xStr = leftJustify!string(xStr, chars, ' ');
		yStr = leftJustify!string(yStr, chars, ' ');
		zStr = leftJustify!string(zStr, chars, ' ');
		
		return "vec3(" ~ xStr ~ ", " ~ yStr ~ ", " ~ zStr ~ ")";
	}
}