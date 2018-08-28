-- GlowCircleEffect.lua
-- Author: xianwx
-- Date: 2018-08-28 15:17:08
-- 发光圆环效果
local shader = {
    fs = require "app.shader.GlowCircleFS",
    vert = require "app.shader.NormalVS",
}

local GlowCircleEffect = class("GlowCircleEffect")

function GlowCircleEffect.getDescText()
    return "发光圆环特效"
end

function GlowCircleEffect:init(node)
    node:spUseShader("noise.png", "glow_circle")
end

function GlowCircleEffect:setUniform(glState, time)
    glState:setUniformFloat("time", time)
    glState:setUniformVec2("resolution", { x = 590, y = 590 })
end

function GlowCircleEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function GlowCircleEffect.getVert()
    return shader.vert
end

function GlowCircleEffect.needRefresh()
    return true
end

function GlowCircleEffect.getFS()
    return shader.fs
end

function GlowCircleEffect:resetTime(time)
    return time + 0.008
end

return GlowCircleEffect
