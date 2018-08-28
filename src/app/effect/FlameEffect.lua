-- FlameEffect.lua
-- Author: xianwx
-- Date: 2018-08-28 10:16:49
-- 火焰特效
local shader = {
    fs = require "app.shader.FlameFS",
    vert = require "app.shader.NormalVS",
}

local FlameEffect = class("FlameEffect")

function FlameEffect.getDescText()
    return "火焰特效"
end

function FlameEffect:init(node)
    node:spUseShader("noisetexture.png", "flame")
end

function FlameEffect:setUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FlameEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FlameEffect.getVert()
    return shader.vert
end

function FlameEffect.needRefresh()
    return true
end

function FlameEffect.getFS()
    return shader.fs
end

function FlameEffect:resetTime(time)
    return time + 0.008
end

return FlameEffect
