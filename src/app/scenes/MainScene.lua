local MainLayer = require "app.layer.MainLayer"
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- local layer = MainLayer.new()
    -- self:addChild(layer)
    self.uiLayer=display.newLayer()
    self.uiLayer:addTo(self,1,0)
    -- layerLoadControl.uiLayer=self.mainLayer
    layerLoadControl:firstLayer(self.uiLayer,"MainLayer")
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
