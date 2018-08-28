-- FluxayEffect_1.lua
-- Author: xianwx
-- Date: 2018-08-21 16:17:03
-- 流光特效
local test_sp = "dragon_nest.png"

local shader = {
    fs = require "app.shader.FluxayFS",
    vert = require "app.shader.NormalVS",
}

local FluxayEffect_1 = class("TransferEffect")

function FluxayEffect_1.getDescText()
    return "流光特效"
end

function FluxayEffect_1:init(node)
    node:spUseShader(test_sp, "fluxay_1")
end

function FluxayEffect_1:setUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FluxayEffect_1:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function FluxayEffect_1:resetTime(time)
    return time + 0.03
end

function FluxayEffect_1.getVert()
    return shader.vert
end

function FluxayEffect_1.needRefresh()
    return true
end

function FluxayEffect_1.getFS()
    return shader.fs
end

return FluxayEffect_1
