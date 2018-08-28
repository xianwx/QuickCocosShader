-- WaterWaveEffect.lua
-- Author: xianwx
-- Date: 2018-08-21 10:37:11
-- 水波纹效果
local test_sp = "startbg.jpg"

local shader = {
    fs = require "app.shader.WaterWaveFS",
    vert = require "app.shader.NormalVS",
}

local WaterWaveEffect = class("WaterWaveEffect")

function WaterWaveEffect.getDescText()
    return "水波纹效果\n请尝试点击一下图片"
end

function WaterWaveEffect:init(node)
    node:spTouchUseShader(test_sp, "water_wave")
end

function WaterWaveEffect:setUniform(glState, time, sp)
    local size = sp:getContentSize()
    glState:setUniformVec2("resolution", { x = size.width, y = size.height })
    glState:setUniformFloat("time", time)
end

function WaterWaveEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function WaterWaveEffect:resetTime(time)
    return time + 0.06
end

function WaterWaveEffect.needRefresh()
    return true
end

function WaterWaveEffect.getVert()
    return shader.vert
end

function WaterWaveEffect.getFS()
    return shader.fs
end

return WaterWaveEffect
