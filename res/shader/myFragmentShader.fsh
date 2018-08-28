varying vec4 v_fragmentColor;
varying vec2 v_texCoord; 

void main()
{
	vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
	vec3 rgbColor=v_orColor.rgb;
	if(rgbColor.r>=0.81&&rgbColor.r<=0.93
        &&rgbColor.g>=0.26&&rgbColor.g<=0.38
        &&rgbColor.b>=0.15&&rgbColor.b<=0.27){
		gl_FragColor = vec4(0, 0.46, 1, v_orColor.a);
	}else if(rgbColor.r>=0.39&&rgbColor.r<=0.51
        &&rgbColor.g>=0.07&&rgbColor.g<=0.19
        &&rgbColor.b<=0.13){
        gl_FragColor = vec4(0, 0.1, 0.44, v_orColor.a);
    }else{
	   gl_FragColor=v_orColor;
	}
}