--
-- Author: xianwx
-- Date: 2018-08-28 18:21:17
--
return [[
#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;

void main(void)
{
    // read the color of the current pixel out of the
    // input texture
    vec4 src_color = texture2D(CC_Texture0, v_texCoord).rgba;

    // output:
    // set color of the fragment
    gl_FragColor = vec4(src_color.g, src_color.r, src_color.b, src_color.a);
}
]]
