shader_type canvas_item;

// index values for each channel
uniform vec4 color;
uniform float maxValue;
uniform float minValue;
uniform float lineThickness: hint_range(0,10);
uniform float dataPoints;
// 1,1361111111 hours worth of data with 1 value per second
const uint dataLen = uint(4090);
uniform float[dataLen] data;


void vertex() {
    // Called for every vertex the material is visible on.
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void fragment() {
        float indexHeight = float(dataPoints) * (1.0 - UV.x);

        float mixer = fract(indexHeight);
        float val1 = data[uint(floor(indexHeight))];
        float val2 = data[uint(ceil(indexHeight))];
        float value = val1 * (1.0-mixer) + val2 * mixer;
        
        float indexWidth = map(value, minValue, maxValue, 0, 1);
        float dist = distance(UV, vec2(UV.x, indexWidth));
        
        // Adjust lineThickness based on slope (optional)
        float slope = dFdx(indexWidth);
        if (slope != 0.0) {
            float val1 = map(val1, minValue, maxValue, 0, 1);
            float val2 = map(val2, minValue, maxValue, 0, 1);
            if ((UV.y > val1 && UV.y < val2) || (UV.y < val1 && UV.y > val2)) {
                COLOR = color;
            }
        }
        
        if (dist < lineThickness) {
            COLOR = color;
        }
}