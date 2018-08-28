--
-- Author: xuewenjie
-- Date: 2016-03-15 18:23:14
--
-- local AnimFactory = require "app.helper.AnimFactory"
LayerLoadControl={}
LayerLoadControl.TOUCH_CLOSE_DIALOG = 1
LayerLoadControl.TOUCH_UNCLOSE_DIALOG = 2
LayerLoadControl.DEPLOY_ATTACK = 3
LayerLoadControl.DEPLOY_DEFEND = 4

local BASE_LAYER = 1001
local POP_LAYER = 1002
local UI_LAYER = 1003

require("app.UiHelper")

function LayerLoadControl:new() --private method.
    local store = nil

    return function()
        if store then return store end
        local o = {}
        setmetatable(o, self)
        self.__index = self
        store = o
        o:init()
        return o
    end
end

LayerLoadControl.instance = LayerLoadControl:new() --implement single instance object.

function LayerLoadControl:init()
    self.mainLayerCacheList={}
    self.uiLayer=nil
    self.popLayer=nil
    self.popBattleLayer=nil
    self.topPopLayer=nil
end

function LayerLoadControl:setTopPopLayer(layer)
    self.topPopLayer=layer
    print("setTopPopLayer")
end

function LayerLoadControl:setLabelLayer(layer)
    self.labelLayer = layer
end

function LayerLoadControl:firstLayer(obj,layerName, params, path)
    path = path or ""
    table.insert(self.mainLayerCacheList,obj)

    local layer=require("app.layer.".. path .. layerName).new(params)
    layer:setName(path .. layerName)
    layer:addTo(obj,1,0)
    layer:setTag(BASE_LAYER)
    self:setLayerUnTouch(layer)

    local popLayer=display.newLayer()
    popLayer:addTo(obj,2,0)
    popLayer:setTag(POP_LAYER)
    self.popLayer=popLayer

    local uiLayer=display.newLayer()
    uiLayer:addTo(obj,3,0)
    uiLayer:setTag(UI_LAYER)
    self.uiLayer=uiLayer
end


-- 打开一个新的页面
-- 可以传入参数
--layerLoadControl:addLayer("OneLayer")
function LayerLoadControl:addLayer(layerName, params, path)
    path = path or ""

    table.insert(self.mainLayerCacheList, self.uiLayer)

    local layer=require("app.layer." .. path .. layerName).new(params)
    layer:setName(path .. layerName)
    layer:addTo(self.uiLayer,1,0)
    layer:setTag(BASE_LAYER)
    self:setLayerUnTouch(layer)

    -- 加一层黑色的底
    local black = cc.LayerColor:create(cc.c4b(0, 0, 0, 200)):addTo(layer, -999)
    black:setContentSize(layer:getContentSize())
    black:setAnchorPoint(cc.p(0, 0))
    black:setPosition(0, 0)

    if layer.layerAdd then
        layer:layerAdd()
    end

    local popLayer=display.newLayer()
    popLayer:addTo(self.uiLayer,2,0)
    popLayer:setTag(POP_LAYER)
    self.popLayer=popLayer

    local uiLayer=display.newLayer()
    uiLayer:addTo(self.uiLayer,3,0)
    uiLayer:setTag(UI_LAYER)
    self.uiLayer=uiLayer
end

-- 关闭 layer 时，应该保证子窗口的 closeIng 的调用
local function disposeChildDialog(popLayer)
    for _,child in pairs(popLayer:getChildren()) do
        if child.closeIng then
            print("dispose child dialog")
            child:closeIng()
        end
    end
end

local function closeLayer(self)
    local layer=self.mainLayerCacheList[#self.mainLayerCacheList]
    table.remove(self.mainLayerCacheList,#self.mainLayerCacheList)

    local baseLayer = layer:getChildByTag(BASE_LAYER)
    if baseLayer.closeIng~=nil then
        baseLayer:closeIng()
    end
    baseLayer:removeFromParent()
    
    local poplayer = layer:getChildByTag(POP_LAYER)
    disposeChildDialog(poplayer)
    poplayer:removeFromParent()
    
    layer:getChildByTag(UI_LAYER):removeFromParent()

    local layer1=self.mainLayerCacheList[#self.mainLayerCacheList]
    self.popLayer=layer1:getChildByTag(POP_LAYER)
    self.uiLayer=layer1:getChildByTag(UI_LAYER)
end

-- @param name 如果 name 为空，关闭最上层的 layer，否则该名字的 layer 以及其子 layer
-- @return true 表示关闭成功
function LayerLoadControl:closeLayer(name)
    local size = #self.mainLayerCacheList
    if size < 2 then
        return
    end

    if not name or type(name) ~= "string" or name == "" then
        closeLayer(self)
        return true
    end

    print("close until layer : " .. name)

    local found = false
    local count = 0
    local layer

    for i=size, 2, -1 do
        count = count + 1
        layer = self.mainLayerCacheList[i]
        local ok, baseLayer = pcall(layer.getChildByTag, layer, BASE_LAYER)
        if ok and baseLayer and baseLayer:getName() == name then
            found = true
            break
        else
            print("DEBUG: getChildByTag failed " .. tostring(baseLayer))
        end
    end

    assert(count > 0)
    if not found then
        print("DEBUG: could not found layer : " .. name)
        return
    end

    for _=1,count do
        closeLayer(self)
    end

    return true
end

-- 打开一个新界面,点击空白关闭
function LayerLoadControl:addLayerNotSetUnTouch(layerName,params)
    local layer=require("app.layer."..layerName).new(params)
    layerLoadControl.popLayer:addChild(layer)
    layer:setTag(#self.popLayer:getChildren())
end

--加载一个csb资源文件
--layerLoadControl:loadCsb(self,"MainScene")
function LayerLoadControl:loadCsb(obj,csbName)
    local layer = cc.CSLoader:createNode("Layer/"..csbName..".csb")
    layer:setPosition(cc.p(0,(display.height-720)/2))
    obj:addChild(layer, 0)
    obj.cocosLayer=layer
    return layer
end

--设置csb文件上的一个控件的点击方法
--layerLoadControl:getChildNodeByName(self,"txtNumber1")
function LayerLoadControl:setButtonEvent(obj,buttonName,event,notShowPressedAction,notSwallowTouches,moveFix)
    local button=self:getChildNodeByName(obj, buttonName)

    if tolua.type(button) == "ccui.Button" then

        -- 默认给所有添加了点击事件的按钮字体描黑边
        local label = button:getTitleRenderer()
        if label then
            label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        end
        addButtonEvent(button, {endCallback=event}, notShowPressedAction)
    else
        if not notSwallowTouches then
            notSwallowTouches=false
        end
        if not moveFix then
            moveFix = true
        end
        addTouchEvent(button,{endCallback=event,notSwallowTouches=notSwallowTouches,moveFix = moveFix})
    end
    return button
end

--获取csb文件上的一个控件
function LayerLoadControl:getChildNodeByName(obj,nodeName)
    if type(nodeName) ~= "table" then
        return obj.cocosLayer:getChildByName(nodeName)
    end

    local node
    for i=1,#nodeName do
        if node==nil then
            node=obj.cocosLayer:getChildByName(nodeName[i])
        else
            node=node:getChildByName(nodeName[i])
        end
    end
    return node
end

--设置主页面的背景不可点击
function LayerLoadControl:setLayerUnTouch(obj)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(
        function(touch)
            local pt=obj:convertToNodeSpace(touch:getLocation())
            local s=obj:getContentSize()
            local rect=cc.rect(0,0,s.width,s.height)
            if cc.rectContainsPoint(rect, pt) then
                return true
            end
            return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = obj:getEventDispatcher()-- 时间派发器
    -- 绑定触摸事件到层当中
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj)
end

--设置主页面的背景不可点击
function LayerLoadControl:setUnTouch(obj)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(
        function(touch)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = obj:getEventDispatcher()-- 时间派发器
    -- 绑定触摸事件到层当中
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj)
end

--设置弹出框的背景点击后关闭该弹出框
function LayerLoadControl:setLayerCloseTouch(obj, popType)
    if popType == nil then
        popType = LayerLoadControl.TOUCH_CLOSE_DIALOG
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN )
    if popType == LayerLoadControl.TOUCH_CLOSE_DIALOG then
        listener:registerScriptHandler(function() self:closeDialog() end,cc.Handler.EVENT_TOUCH_ENDED )
    end

    local eventDispatcher = obj:getEventDispatcher()-- 时间派发器
    -- 绑定触摸事件到层当中
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj)
end

--打开一个弹出框
function LayerLoadControl:pushDialog(layerName, layerParams, pushParams)
    -- popType, showMask, path
    pushParams = pushParams or {}
    pushParams.path = pushParams.path or ""

    if pushParams.showMask == nil then
        pushParams.showMask = true
    end

    local layer=require("app.layer." .. pushParams.path .. layerName).new(layerParams)

    layer.cocosLayer:setAnchorPoint(0.5, 0.5)
    layer.cocosLayer:setPosition(display.cx, display.cy)
    layer:addTo(layerLoadControl.popLayer)

    if not pushParams.notShowPopup then
        -- AnimFactory.popup(layer.cocosLayer)()
    end

    if pushParams.showMask then
        local bg = require("app.layer.MaskLayer").new()
        layer:addChild(bg, -1)
        bg:setPosition(0, 0)
    end
    self:setLayerCloseTouch(layer, pushParams.popType)
    self:setLayerUnTouch(layer.cocosLayer)
    layer:setTag(#self.popLayer:getChildren())
end

--关闭最上层的弹出框
function LayerLoadControl:closeDialog()
    local layer=self.popLayer:getChildByTag(#self.popLayer:getChildren())
    if layer ~= nil then
        if layer.closeIng~=nil then
            layer:closeIng()
        end
        self.popLayer:removeChildByTag(#self.popLayer:getChildren(), true)
    end
end

--打开一个弹出框
function LayerLoadControl:pushDialogTop(layerName, layerParams, pushParams)
    if self.topPopLayer==nil then
        return
    end
    pushParams = pushParams or {}
    pushParams.path = pushParams.path or ""
    local layer=require("app.layer." .. pushParams.path .. layerName).new(layerParams)
    layer.cocosLayer:setAnchorPoint(0.5, 0.5)
    layer.cocosLayer:setPosition(display.cx, display.cy)

    if not pushParams.notShowPopup then
        -- AnimFactory.popup(layer.cocosLayer)()
    end

    layer:addTo(self.topPopLayer)
    if pushParams.showMask then
        local bg = require("app.layer.MaskLayer").new()
        layer:addChild(bg, -1)
        bg:setPosition(0, 0)
    end
    self:setLayerCloseTouch(layer, pushParams.popType)
    self:setLayerUnTouch(layer.cocosLayer)
    layer:setTag(#layerLoadControl.topPopLayer:getChildren())
end

--关闭最上层的弹出框
function LayerLoadControl:closeDialogTop()
    local layer=self.topPopLayer:getChildByTag(#self.topPopLayer:getChildren())
    if layer ~= nil then
        if layer.closeIng~=nil then
            layer:closeIng()
        end
        self.topPopLayer:removeChildByTag(#self.topPopLayer:getChildren(), true)
    end
end

function LayerLoadControl:pushLayerInBattle(layerName, params,showMask)
    local layer=require("app.layer."..layerName).new(params)
    if layer.cocosLayer then
        local x=(1280-layer.cocosLayer:getContentSize().width)/2
        local y=(720-layer.cocosLayer:getContentSize().height)/2
        layer:setPosition(cc.p(x,y))

        if showMask then
            local bg = require("app.layer.MaskLayer").new()
            layer:addChild(bg, -1)
            bg:setPosition(-x, -y)
        end
    else
        layer:setPosition(cc.p(display.width/2,display.height/2))
    end
    -- layer:addTo(self.popBattleLayer)
    layer:addTo(layerLoadControl.popBattleLayer,#self.popBattleLayer:getChildren()+1)
    -- self:setLayerCloseTouch(layer)
    if layer.cocosLayer then
        self:setLayerUnTouch(layer.cocosLayer)
    end
    self:setUnTouch(layer)
    layer:setTag(#self.popBattleLayer:getChildren())
end

--在战斗中打开一个弹出框
function LayerLoadControl:pushBattleDialog(layerName,params,showMask)
    local layer=require("app.battle.layer."..layerName).new(params)
    if layer.cocosLayer then
        local x=(1280-layer.cocosLayer:getContentSize().width)/2
        local y=(720-layer.cocosLayer:getContentSize().height)/2
        layer:setPosition(cc.p(x,y))

        if showMask then
            local bg = require("app.layer.MaskLayer").new()
            layer:addChild(bg, -1)
            bg:setPosition(-x, -y)
        end
    else
        layer:setPosition(cc.p(display.width/2,display.height/2))
    end
    -- layer:addTo(self.popBattleLayer)
    layer:addTo(layerLoadControl.popBattleLayer,#self.popBattleLayer:getChildren()+1)
    -- self:setLayerCloseTouch(layer)
    if layer.cocosLayer then
        self:setLayerUnTouch(layer.cocosLayer)
    end
    self:setUnTouch(layer)
    layer:setTag(#self.popBattleLayer:getChildren())
end

--关闭战斗中最上层的弹出框
function LayerLoadControl:closeBattleDialog()
    local layer=self.popBattleLayer:getChildByTag(#self.popBattleLayer:getChildren())
    if layer.closeIng~=nil then
        layer:closeIng()
    end
    self.popBattleLayer:removeChildByTag(#self.popBattleLayer:getChildren(), true)
end

-- 一个临时的弹出框提醒
function LayerLoadControl:showNoticeMsg(msg, duration, stayDuration, delay, layer)
    local obj = layer or self.labelLayer
    duration = duration == nil and 0.2 or duration
    stayDuration = stayDuration == nil and 0.2 or stayDuration
    delay = delay == nil and 0 or delay
    require("app.uiExtend.NoticeMsg").new(msg, duration, stayDuration, delay):addTo(obj)
end

-- 给label控件加上描边
-- @param obj       layer
-- @param name      控件名称，可以直接传字符串或者nameList
-- @param color     描边颜色（默认为黑色）
-- @param size      描边宽度（默认为1）
function LayerLoadControl:labelEnableOutLine(obj, name, color, size)
    local label = self:getChildNodeByName(obj, name)
    color = color or cc.c4b(0, 0, 0, 255)
    size = size or 3
    label:enableOutline(color, size)
    return label
end

-- 不要在 callback 中重复调用 closeDialog
function LayerLoadControl:showTwoStepVeriLayer(str, okCallback, cancelCallback, param)
    param = param or {}
    okCallback = okCallback or function () end
    cancelCallback = cancelCallback or function () end
    local onConfirm = function ()
        self:closeDialog()
        okCallback()
    end

    local onCancel = function ()
        self:closeDialog()
        cancelCallback()
    end
    local params = {
        dialog = str, 
        cancelCallback = onCancel, 
        okCallback = onConfirm, 
        okLabel = param.okLabel, 
        cancelLabel = param.cancelLabel
    }
    self:pushDialog("TwoStepVerificatLayer", params, { popType = LayerLoadControl.TOUCH_UNCLOSE_DIALOG, showMask = false })
end

-- @param table params
--[[
    dialog                 要显示的文字
    onConfirm              确定回调，不传默认只是关闭本对话框
    okLabel                按钮文字，默认显示 确认 
]]
function LayerLoadControl:showConfimDialog(params)
    params = params or {}
    params.type = "one"
    params.okCallback = function ()
        if params.onConfirm then
            params.onConfirm()
        end
        self:closeDialog()
    end
    self:pushDialog("TwoStepVerificatLayer", params, { popType = LayerLoadControl.TOUCH_UNCLOSE_DIALOG, showMask = false })
end

function LayerLoadControl:showNetErrorLayer()
    print("网络错误")
    local function okCallbackFunc()
        netControl:close()
        gameData:cleadData()
        clockHelper:close()
        local LoginScene=require("app.scenes.LoginScene")
        local nextScene=LoginScene.new("FastLoginLayer")

        cc.Director:getInstance():replaceScene(nextScene)
    end

    local params = {dialog = getStringById(60000008), cancelCallback = okCallbackFunc, okCallback = okCallbackFunc}
    layerLoadControl:pushDialogTop("TwoStepVerificatLayer", params, { popType = LayerLoadControl.TOUCH_UNCLOSE_DIALOG, showMask = false })

end

return LayerLoadControl
