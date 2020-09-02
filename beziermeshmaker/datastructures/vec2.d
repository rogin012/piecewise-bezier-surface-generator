module beziermeshmaker.datastructures.vec2;

import std.stdio;
import std.string;
import std.conv;
import std.math;

import modules.opengl.EitanOpenGLClasses;

class vec2{
	float[2] values;
	alias values this;
	
	this(){
		this(0, 0);
	}
	this(float a, float b){
		values = [a, b];
	}
	this(vec2 input){
		this(input.x, input.y);
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

		nothrow float u() { return x; }
		nothrow float u(float newU){ return x(newU); }
		nothrow float v() { return y; }
		nothrow float v(float newV){ return y(newV); }
	}
	
	float dot(vec2 other){
		return (x * other.x) + (y * other.y);
	}
	vec2 normalize(){
		return this / length();
	}
	float length(){
		return sqrt(x * x + y * y);
	}
	float angleBetween(vec2 other){
		float value = dot(other) / (length() * other.length() );
		
		return acos(value);
	}

	vec2 moveToward(vec2 other, float amount) {
		vec2 motionVector = (other - this).normalize() * amount;

		return this + motionVector;
	}
	
	vec2 opBinary(string op)(float val){
		if(op == "*"){
			return new vec2(x * val, y * val);
		}
		else if(op == "/"){
			return new vec2(x / val, y / val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec2 opBinaryRight(string op)(float val){
		if(op == "*"){
			return new vec2(x * val, y * val);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec2 opBinary(string op)(vec2 val){
		if(op == "+"){
			return new vec2(x + val.x, y + val.y);
		}
		else if(op == "-"){
			return new vec2(x - val.x, y - val.y);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}
	vec2 opBinary(string op)(vec3 val){
		if(op == "+"){
			return new vec2(x + val.x, y + val.y);
		}
		else if(op == "-"){
			return new vec2(x - val.x, y - val.y);
		}
		else{
			assert(0, "Operator "~op~" not implemented");
		}
	}

	override bool opEquals(Object o) {
		vec2 other = cast(vec2) o;

		if (other is null) {
			return false;
		}
		else {
			return approxEqual(x, other.x, 0.00001) && approxEqual(y, other.y, 0.00001);
		}
	}
	override nothrow @trusted size_t toHash() {
		return cast(ulong)(x * 10000 + y * 10000);
	}

	override string toString(){
		//return "vec2(" ~ to!string(x) ~ ", " ~ to!string(y) ~ ")";
		return format("vec2(%.10f, %.10f)", x, y);
	}
	string toNiceString(int chars){
		string xStr = to!string(x);
		string yStr = to!string(y);
		
		xStr = leftJustify!string(xStr, chars, ' ');
		yStr = leftJustify!string(yStr, chars, ' ');
		
		return "vec2(" ~ xStr ~ ", " ~ yStr ~ ")";
	}
}

//This is used when storing data in buffers to send to the GPU, since exact memory alignment matters.
struct vec2_struct {
	float x;
	float y;

	this(float x, float y) {
		this.x = x;
		this.y = y;
	}
	this(vec2 v){
		x = v.x;
		y = v.y;
	}
}