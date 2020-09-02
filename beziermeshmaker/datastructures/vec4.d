module beziermeshmaker.datastructures.vec4;

import std.stdio;
import std.string;
import std.conv;
import std.math;

import modules.opengl.EitanOpenGLClasses;

class vec4{
	float* values;
	alias values this;
	
	this(){
		this(0, 0, 0, 0);
	}
	this(float a, float b, float c, float d){
		values = [a, b, c, d].ptr;
	}
	this(vec4 input){
		this(input.x, input.y, input.z, input.w);
	}
	
	@property{
		nothrow float x(){
			return values[0];
		}
		nothrow float x(float newX){
			return values[0] = newX;
		}
		nothrow float y(){
			return values[1];
		}
		nothrow float y(float newY){
			return values[1] = newY;
		}
		nothrow float z(){
			return values[2];
		}
		nothrow float z(float newZ){
			return values[2] = newZ;
		}
		nothrow float w(){
			return values[3];
		}
		nothrow float w(float newW){
			return values[3] = newW;
		}
	}
	
	float dot(vec4 other){
		return x * other.x + y * other.y + z * other.z + w * other.w;
	}
	vec4 normalize(){
		return this / length();
	}
	float length(){
		return sqrt(x * x + y * y + z * z + w * w);
	}
	
	vec4 opBinary(string op)(float val){
		if(op == "*"){
			return new vec4(x * val, y * val, z * val, w * val);
		}
		else if(op == "/"){
			return new vec4(x / val, y / val, z / val, w / val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec4 opBinaryRight(string op)(float val){
		if(op == "*"){
			return new vec4(x * val, y * val, z * val, w * val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec4 opBinary(string op)(vec4 val){
		if(op == "+"){
			return new vec4(x + val.x, y + val.y, z + val.z, w + val.w);
		}
		else if(op == "-"){
			return new vec4(x - val.x, y - val.y, z - val.z, w - val.w);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}

	override bool opEquals(Object o) {
		vec4 other = cast(vec4) o;

		if (other is null) {
			return false;
		}
		else {
			return approxEqual(x, other.x, 0.00001) && approxEqual(y, other.y, 0.00001) && approxEqual(z, other.z, 0.00001) && approxEqual(w, other.w, 0.00001);
		}
	}
	override @trusted size_t toHash() {
		return cast(ulong)(x * 10000 + y * 10000 + z * 10000 + w * 10000);
	}

	override string toString(){
		return "vec4(" ~ to!string(x) ~ ", " ~ to!string(y) ~ ", " ~ to!string(z) ~ ", " ~ to!string(w) ~ ")";
	}
	string toNiceString(int chars){
		string xStr = to!string(x);
		string yStr = to!string(y);
		string zStr = to!string(z);
		string wStr = to!string(w);
		
		xStr = leftJustify!string(xStr, chars, ' ');
		yStr = leftJustify!string(yStr, chars, ' ');
		zStr = leftJustify!string(zStr, chars, ' ');
		wStr = leftJustify!string(wStr, chars, ' ');
		
		return "vec3(" ~ xStr ~ ", " ~ yStr ~ ", " ~ zStr ~ ", " ~ wStr ~ ")";
	}
}

//This is used when storing data in buffers to send to the GPU, since exact memory alignment matters.
//It has intializers for vec3 too because opengl has idiosyncratic behavior for vec3s and in general it's best to avoid
//using them when exact byte alignment matters.
struct vec4_struct {
	float x;
	float y;
	float z;
	float w;

	this(float x, float y, float z) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = 0;
	}
	this(float x, float y, float z, float w) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	this(vec3 v){
		x = v.x;
		y = v.y;
		z = v.z;
		w = 0;
	}
	this(vec4 v){
		x = v.x;
		y = v.y;
		z = v.z;
		w = v.w;
	}
}