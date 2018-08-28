-- ArmyInfoNode.lua
-- Author: xianwx
-- Date: 2016-04-28 21:17:27
-- 兵种信息
local ArmyInfoNode = class("ArmyInfoNode", function ()
    return display.newNode()
end)

function ArmyInfoNode:ctor(id, heroId)
    
    self.id = id
    self.heroId = heroId
    self:setContentSize(200, 270)

    self.name = createSimpleLabel({ text = heroConfig:getHeroName(self.heroId), size = 32, color = cc.c3b(255, 255, 255), dimensions = cc.size(32, 200), x = 0, y = 50 }):addTo(self):setAnchorPoint(0, 0)

    local class = getValueInConfig("soldiers", self.id, "class")
    local sp = display.newSprite(getValueInConfig("soldiers", self.id, "portrait_resource"), 35, 80):addTo(self):setAnchorPoint(0, 0)

    if class == 3 then
        -- 这个是骑兵，要缩放
        sp:setScale(0.65)
    end

    self.btn = newButton(getStringById(60000086), { normal = "UI/GeneralUI/btnUp.png", selected = "UI/GeneralUI/btnUp.png", disable = "UI/GeneralUI/btnDisable.png", size = 30 }):addTo(self):setAnchorPoint(0, 0):setPosition(30, 45)
    local label = self.btn:getTitleRenderer()
    label:enableOutline(cc.c4b(0, 0, 0, 255), 3)

    addButtonEvent(self.btn, {endCallback = function ()
        local req = netDataControl:heros_change_army(self.heroId, self.id)
            netControl:sendData(req, self, self.changeCallBackFunc)
    end})

    self.arrow = display.newSprite("UI/GeneralUI/arrowActive.png", 210, 120):addTo(self):setAnchorPoint(0, 0.5)
    self.arrowCp = display.newSprite("UI/GeneralUI/arrowActive.png", 210, 100):addTo(self):setAnchorPoint(0, 0.5):setVisible(false)

    self.isSelected = display.newSprite("UI/GeneralUI/currentArmy.png", 20, 20):addTo(self):setAnchorPoint(0, 0)

    self.onMove = false
    addTouchEvent(self, {moveCallback = function ()
        self.onMove = true
        if self.intoLongToucou then
            self.removeDetailListener()
            self.intoLongToucou = false
        end
    end, longTouchCallback = function (touch)
        local cascadeBound = cc.rect(sp:getPositionX(), sp:getPositionY(), sp:getContentSize().width, sp:getContentSize().height)
        local pos = self:convertTouchToNodeSpace(touch)
        if self.onMove == false and cc.rectContainsPoint(cascadeBound, pos) then
            self.intoLongToucou = true
            self.showDetailListener(touch, self.id)
        end
    end, longTouchCloseCallback = function ()
        if self.intoLongToucou then
            self.removeDetailListener()
        end
        self.intoLongToucou = false
        self.onMove = false
    end, endCallback = function ()
        self.onMove = false
    end, moveFix = true, notSwallowTouches = true})

    self.sp = sp
end

function ArmyInfoNode:updateMyInfo(onSelected, onActive, showArrow, arrowActive, downActive, showFork)

    self.name:setString(getValueInConfig("soldiers", self.id, "name"))

    if onSelected then
        self.btn:setVisible(false)
        self.isSelected:setVisible(true)
    else
        self.btn:setVisible(true)
        self.isSelected:setVisible(false)

        if onActive then
            self.btn:setVisible(true)
        else
            self.btn:setVisible(false)
            setCCSpriteGray(self.sp)
        end
    end

    if showArrow ~= nil then
        if showArrow then
            self.arrow:setVisible(true)
            if arrowActive then
                self.arrow:setTexture("UI/GeneralUI/arrowActive.png")
            else
                self.arrow:setTexture("UI/GeneralUI/arrowInactive.png")
            end

            if downActive then
                self.arrowCp:setTexture("UI/GeneralUI/arrowActive.png")
            else
                self.arrowCp:setTexture("UI/GeneralUI/arrowInactive.png")
            end
        else
            self.arrow:setVisible(false)
        end
    end
    

    if showFork ~= nil and showFork then
        self.arrowCp:setVisible(true)
        self.arrow:setRotation(-30)
        self.arrowCp:setRotation(30)
    end
    -- self.arrow:setFlippedY(flippedY)
end

function ArmyInfoNode:unlockCallBackFunc(event)
    netControl:removeEvent(event.name)
    if self.unLockCallBack then
        self.unLockCallBack(event)
    end
end

function ArmyInfoNode:addShowDetailListener(listener)
    self.showDetailListener = listener
end

function ArmyInfoNode:addRemoveDetailListener(listener)
    self.removeDetailListener = listener
end

function ArmyInfoNode:changeCallBackFunc(event)
    netControl:removeEvent(event.name)
    if self.changeCallBack then
        self.changeCallBack(event)
    end
end

function ArmyInfoNode:addArmyUnlockCallback(listener)
    self.unLockCallBack = listener
end

function ArmyInfoNode:addArmyChangeCallback(listener)
    self.changeCallBack = listener
end

return ArmyInfoNode