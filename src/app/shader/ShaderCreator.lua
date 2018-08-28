--
-- Author: Chen Qingqing
-- Date: ???
--

local Outline = {
    vs = import ".NormalVS",
    fs = import ".OutlineFS",
}

local Shine = {
    vs = import ".NormalVS",
    fs = import ".ShineFS",
}

local Blur = {
    vs = import ".NormalVS",
    fs = import ".SimpleBlurFS",
}

local ZoomBlur = {
    vs = import ".NormalVS",
    fs = import ".ZoomBlurFS",
}

local function createShader(name, new)
    local cache = cc.GLProgramCache:getInstance()
    local p = cache:getGLProgram(name)
    if not p then
        p = new()
        p:link()
        p:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        p:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        p:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        p:updateUniforms()
        cache:addGLProgram(p, name)
    end

    return p
end

-- @param flicker 闪烁的
local function createOutline(opts)
    opts = opts or {}
    local color = opts.color or cc.c3b(255, 255, 255)
    local flicker = not not opts.flicker

    local colorStr = string.format("%f, %f, %f", color.r/255, color.g/255, color.b/255);
    local fs = string.gsub(Outline.fs, "%[RGB%]", colorStr)
    fs = string.gsub(fs, "%[TIME%]", flicker and "" or "//")

    local name = string.format("OutlineC[%s]F[%s]", colorStr, flicker)
    return createShader(name, function ()
        return cc.GLProgram:createWithByteArrays(Outline.vs, fs)
    end)
end

local function createBlur(opts)
    opts = opts or {}
    local resolution = opts.resolution or {width = 480, height = 320}
    local resolutionStr = string.format("%f, %f", resolution.width, resolution.height)
    local fs = string.gsub(Blur.fs, "%[resolution%]", resolutionStr)
    fs = string.gsub(fs, "%[blurRadius%]", "10.0")
    fs = string.gsub(fs, "%[sampleNum%]", "5.0")

    local name = "SimpleBlur" .. opts.name
    return createShader(name, function ()
        return cc.GLProgram:createWithByteArrays(Blur.vs, fs)
    end)
end

local function createZoomBlur(opts)
    opts = opts or {}
    -- local size = opts.size or {width = 480, height = 320}
    local blurSize = opts.blurSize or 0.7
    local blurCenterStr = string.format("%f, %f", 0.5, 0.5)
    local fs = string.gsub(ZoomBlur.fs, "%[blurCenter%]", blurCenterStr)
    local blurSizeStr = string.format("%f", blurSize)
    fs = string.gsub(fs, "%[blurSize%]", tostring(blurSizeStr))

    local name = "ZoomBlur"
    return createShader(name, function ()
        return cc.GLProgram:createWithByteArrays(ZoomBlur.vs, fs)
    end)
end

local function createShine(opts)
    opts = opts or {}
    local intensity = opts.intensity or 0.5
    local duration = opts.duration or 2.5

    local intensityStr = string.format("%f", intensity)
    local durationStr = string.format("%f", duration)

    local fs = string.gsub(Shine.fs, "%[INTENSITY%]", intensityStr)
    fs = string.gsub(fs, "%[DURATION%]", durationStr)

    local name = string.format("ShineI[%s]D[%s]", intensityStr, durationStr)
    return createShader(name, function ()
        return cc.GLProgram:createWithByteArrays(Shine.vs, fs)
    end)
end

local function createGray()
    return createShader("Gray", function ()
        return cc.GLProgram:create("shader/gray.vsh", "shader/gray.fsh")
    end)
end

local function createNormal()
    return createShader("Normal", function ()
        return cc.GLProgram:create("shader/gray.vsh", "shader/normal.fsh")
    end)
end

local function createFishEyes()
    return createShader("fishEyes", function ()
        return cc.GLProgram:create("shader/fisheyes.vert", "shader/fisheyes.frag")
    end)
end

local function createTest()
    return createShader("testShader", function ()
        return cc.GLProgram:create("shader/test.vert", "shader/test.frag")
    end)
end

return {
    createOutline = createOutline,
    createShine = createShine,
    createNormal = createNormal,
    createGray = createGray,
    createFishEyes = createFishEyes,
    createTest = createTest,
    createBlur = createBlur,
    createZoomBlur = createZoomBlur,
}
