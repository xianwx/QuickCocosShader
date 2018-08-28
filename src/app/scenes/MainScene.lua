local MainLayer = require "app.layer.MainLayer"
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local layer = MainLayer.new()
    self:addChild(layer)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
