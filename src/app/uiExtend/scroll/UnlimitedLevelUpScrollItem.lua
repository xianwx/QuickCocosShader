-- UnlimitedLevelUpScrollItem.lua
-- Author: xianwx
-- Date: 2016-04-07 10:07:10
-- 武将升级滚动条元素

local UnlimitedLevelUpScrollItem = class("UnlimitedLevelUpScrollItem", function ()
    return display.newNode()
end)

function UnlimitedLevelUpScrollItem:ctor(id, index)

    self.bgSelect = display.newSprite("UI/GeneralUI/scrollSelectedFrame.png", 0, 0):setVisible(false)
    self.bgSelect:setScale(0.97)
    self.bgSelect:setAnchorPoint(0, 0)
    self.bgSelect:setPosition(0, 0)
    self:addChild(self.bgSelect)

    local bgSp = display.newSprite("UI/GeneralUI/scrollItemBg.png", 3, 3):addTo(self):setAnchorPoint(0, 0)
    bgSp:setScale(0.97)
    display.newSprite(heroConfig:getHeroHeadIcon(id), 4, 4):addTo(self):setAnchorPoint(0, 0):setScale(0.96)

    -- self.label = createSimpleLabel(text = heroConfig:getHeroName(id), size = 25, align = cc.ui.TEXT_VALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_CENTER, dimensions = cc.size(110, 25)):addTo(self)
    self.label = createSimpleLabel({text = heroConfig:getHeroName(id), size = 25, align = cc.ui.TEXT_VALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_CENTER, dimensions = cc.size(110, 25)}):addTo(self)
    self.label:setAnchorPoint(0, 0)
    self.label:setPosition(0, 130)
    self.label:setContentSize(110, 50)
    self:setContentSize(bgSp:getContentSize())

    addTouchEvent(self, {endCallback = function (touch)
        self:onSelected(touch)
    end, moveCallback = function (touch)
        self:onMoved(touch)
    end})
    self.id = id
    self.index = index
end

function UnlimitedLevelUpScrollItem:addClickedListener(listener)
    self.clickedListener = listener
end

function UnlimitedLevelUpScrollItem:onSelected(touch)
    self.clickedListener(self, touch)
end

function UnlimitedLevelUpScrollItem:addMovedListener(listener)
    self.movedListener = listener
end

function UnlimitedLevelUpScrollItem:onMoved(touch)
    self.movedListener(touch)
end

function UnlimitedLevelUpScrollItem:onSelectedOrCancel()
    self.bgSelect:setVisible(self.bgSelect:isVisible() == false and true or false)
end

return UnlimitedLevelUpScrollItem

