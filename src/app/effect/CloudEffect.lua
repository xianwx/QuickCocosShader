-- CloudEffect.lua
-- Author: xianwx
-- Date: 2018-08-28 11:12:19
-- 模拟云的效果
local shader = {
    fs = require "app.shader.CloudFS",
    vert = require "app.shader.NormalVS",
}

local CloudEffect = class("CloudEffect")

function CloudEffect.getDescText()
    return "模拟云朵特效"
end

function CloudEffect:init(node)
    node:spUseShader("noise.png", "cloud")
end

function CloudEffect:setUniform(glState, time)
    glState:setUniformFloat("time", time)
    glState:setUniformVec2("resolution", { x = 590, y = 350 })
end

function CloudEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function CloudEffect.getVert()
    return shader.vert
end

function CloudEffect.needRefresh()
    return true
end

function CloudEffect.getFS()
    return shader.fs
end

function CloudEffect:resetTime(time)
    return time + 0.03
end

return CloudEffect
