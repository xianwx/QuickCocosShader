-- GrassyEffect.lua
-- Author: xianwx
-- Date: 2018-08-28 15:13:08
-- 模拟草地
local shader = {
    fs = require "app.shader.GrassyFS",
    vert = require "app.shader.NormalVS",
}

local GrassyEffect = class("GrassyEffect")

function GrassyEffect.getDescText()
    return "模拟草地特效"
end

function GrassyEffect:init(node)
    node:spUseShader("noise.png", "grassy")
end

function GrassyEffect:setUniform(glState, time)
    glState:setUniformFloat("time", time)
    glState:setUniformVec2("resolution", { x = 590, y = 350 })
end

function GrassyEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function GrassyEffect.getVert()
    return shader.vert
end

function GrassyEffect.needRefresh()
    return true
end

function GrassyEffect.getFS()
    return shader.fs
end

function GrassyEffect:resetTime(time)
    return time + 0.03
end

return GrassyEffect
