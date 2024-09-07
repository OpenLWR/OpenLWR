shader_type canvas_item;

// index values for each channel
uniform vec4 color;
uniform float maxValue;
uniform float minValue;
uniform float lineThickness: hint_range(0,1000);
// 30 minutes with one value each second for each channel
uniform float dataPoints;
const uint dataLen = uint(4090);
uniform float[dataLen] data;


void vertex() {
    // Called for every vertex the material is visible on.
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void fragment() {
    float UVPerIndex = 1./dataPoints;
    float indexHeight = float(dataPoints) * (1.0 - UV.x);
    float prevIndexHeight = float(dataPoints) * (1.0 - UV.x - UVPerIndex);
    
    float mixer = fract(indexHeight);
    float val1 = map(data[uint(ceil(indexHeight))], minValue, maxValue, 0, 1);
    float val2 = map(data[uint(ceil(indexHeight))], minValue, maxValue, 0, 1);
    float NextdataPoint = map(val1 * (1.0-mixer) + val2 * mixer, minValue, maxValue, 0, 1);
    
    float dist = distance(UV.y, NextdataPoint);
    if (dist < lineThickness) {
        COLOR = color;
    }
}