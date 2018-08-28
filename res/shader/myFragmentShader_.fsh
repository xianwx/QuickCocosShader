varying vec4 v_fragmentColor;
varying vec2 v_texCoord; 

void main()
{
	vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
	vec3 rgbColor=v_orColor.rgb;
	if(rgbColor.r>0.8&&rgbColor.g<0.1&&rgbColor.b>0.9){
		float gray = dot(v_orColor.rgb, vec3(0.299, 0.587, 0.114));
        gl_FragColor = vec4(gray, gray, gray, v_orColor.a);
	}else{
	   gl_FragColor=v_orColor;
	}
	
}