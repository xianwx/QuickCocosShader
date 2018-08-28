-- FluxayEffect_2.lua
-- Author: xianwx
-- Date: 2018-08-21 16:17:03
-- 流光特效
local test_sp = "dragon_nest.png"

local shader = {
    fs = require "app.shader.FluxayFS_2",
    vert = require "app.shader.NormalVS",
}

local FluxayEffect_2 = class("FluxayEffect_2")

function FluxayEffect_2.getDescText()
    return "波光特效"
end

function FluxayEffect_2:init(node)
    node:spUseShader(test_sp, "fluxay_2")
end

function FluxayEffect_2:setUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FluxayEffect_2:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FluxayEffect_2:resetTime(time)
    return time + 0.03
end

function FluxayEffect_2.getVert()
    return shader.vert
end

function FluxayEffect_2.needRefresh()
    return true
end

function FluxayEffect_2.getFS()
    return shader.fs
end

return FluxayEffect_2
