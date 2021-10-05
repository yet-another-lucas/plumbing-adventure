shader_type canvas_item;

uniform bool active = true;

void fragment() {
	vec4 prevColor = texture(TEXTURE, UV);
	vec4 whiteColor = vec4(1.0, 1.0, 1.0, prevColor.a);
	vec4 newColor = prevColor;
//	COLOR = prevColor;
//	COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	if (active == true) {
		newColor = whiteColor;
	}
	COLOR = newColor;
}
