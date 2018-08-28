return [[
    #ifdef GL_ES
    precision mediump float;
    #endif

    #define F cos(x-y)*cos(y),sin(x+y)*sin(y)

    uniform float time;
    uniform vec2 resolution;
    varying vec2 v_texCoord;

    vec2 s(vec2 p)
    {
        float d=time*0.2,x=8.*(p.x+d),y=8.*(p.y+d);
        return vec2(F);
    }
    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
        // 换成resolution
        vec2 rs = resolution.xy;
        // 换成纹理坐标v_texCoord.xy
        vec2 uv = v_texCoord.xy;
        vec2 q = uv+2./resolution.x*(s(uv)-s(uv+rs));
        fragColor = texture2D(CC_Texture0,q);
    }
    void main()
    {
        mainImage(gl_FragColor, gl_FragCoord.xy);
    }
]]
