return [[
    #ifdef GL_ES
    precision highp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main(void)
    {
        vec3 c_outlineColor = vec3([RGB]);
        float c_threshold = 1.0;

        float radius = 0.0015;
        vec4 accum = vec4(0.0);
        vec4 normal = vec4(0.0);

        normal = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y));

        accum += texture2D(CC_Texture0, vec2(clamp(v_texCoord.x - radius, 0.0, 1.0), clamp(v_texCoord.y - radius, 0.0, 1.0)));
        accum += texture2D(CC_Texture0, vec2(clamp(v_texCoord.x + radius, 0.0, 1.0), clamp(v_texCoord.y - radius, 0.0, 1.0)));
        accum += texture2D(CC_Texture0, vec2(clamp(v_texCoord.x + radius, 0.0, 1.0), clamp(v_texCoord.y + radius, 0.0, 1.0)));
        accum += texture2D(CC_Texture0, vec2(clamp(v_texCoord.x - radius, 0.0, 1.0), clamp(v_texCoord.y + radius, 0.0, 1.0)));

        accum *= c_threshold;
        accum.rgb =  c_outlineColor * accum.a;
        [TIME] accum.rgb *= abs(sin(CC_Time.x * 20.0));
        //accum.rgb *= 1.0 - smoothstep(0.3, 0.5, normal.a);

        normal.rgb = mix(normal.rgb, accum.rgb, 1.0 - normal.a);
        gl_FragColor = v_fragmentColor * normal;
        // gl_FragColor = accum * (1.0 - normal.a);
    }
]]
