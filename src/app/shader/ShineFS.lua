return [[
    #ifdef GL_ES
    precision highp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main(void)
    {
        float PI_2 = 3.14159 * 2.0;
        vec4 c = texture2D(CC_Texture0, v_texCoord);
        float added = 1.0 + (cos(CC_Time.y * PI_2 / [DURATION]) + 1.0) / 2.0 * [INTENSITY];
        gl_FragColor.xyz = c.xyz * added;
        gl_FragColor.w = c.w;
    }
]]
