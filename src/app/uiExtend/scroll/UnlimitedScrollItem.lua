-- UnlimitedScrollItem.lua
-- Author: xianwx
-- Date: 2016-03-31 10:31:29
-- 无限拖动滚动条的元素

local UnlimitedScrollItem = class("UnlimitedScrollItem", function ()
    return display.newNode()
end)

function UnlimitedScrollItem:ctor(id, index, list)

    local bgSp = display.newSprite("UI/GeneralUI/scrollItemBg.png", 0, 0):addTo(self):setAnchorPoint(0, 0)
    local sp = display.newSprite(heroConfig:getHeroHeadIcon(id))
    sp:setScale(0.97)
    sp:setAnchorPoint(0, 0)
    sp:setPosition(2, 2)
    self:addChild(sp)

    local label = createSimpleLabel({ text = heroConfig:getHeroName(id), size = 25, align = cc.ui.TEXT_VALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_CENTER, dimensions = cc.size(110, 25), outLine = true }):addTo(self)
    label:setAnchorPoint(0, 0)
    label:setPosition(0, 20)
    label:setContentSize(110, 50)
    self:setContentSize(bgSp:getContentSize())

    addTouchEvent(self, {endCallback = function ()
        self:changeScale(index, list)
    end, moveCallback = function (touch)
        self:onMoved(touch)
    end})
    self.id = id
    self.index = index
end

function UnlimitedScrollItem:addClickedListener(listener)
    self.isMove = false
    self.clickedListener = listener
    -- return self
end

function UnlimitedScrollItem:changeScale(index, list)
    self.clickedListener(self, index, list)
end

function UnlimitedScrollItem:addMovedListener(listener)
    self.movedListener = listener
end

function UnlimitedScrollItem:onMoved(touch)
    if self.isMove then
        self.movedListener(touch)
    else
        local startLocation=touch:getStartLocation()
        local location = touch:getLocation() 
        if math.abs(startLocation.x - location.x) > 10 or math.abs(startLocation.y - location.y) > 10 then
            self.isMoved = true
            self.movedListener(touch)
        end
    end
end

return UnlimitedScrollItem
