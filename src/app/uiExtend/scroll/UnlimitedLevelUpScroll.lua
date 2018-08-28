-- UnlimitedLevelUpScroll.lua
-- Author: xianwx
-- Date: 2016-04-07 09:59:26
-- 武将升级无限滚动条

local itemGap = 100
local smallItemWidth = 110
local itemScaleNum = 0.75
local nodeGap = 100 - 110 * itemScaleNum
local nodeHeight = 120
local unLimitNum = 10

local UnlimitedLevelUpScroll = class("UnlimitedLevelUpScroll", function ()
    return display.newNode()
end)

function UnlimitedLevelUpScroll:ctor(id)
    self.id = id
    self:setContentSize(900, 90)

    -- 裁剪区域
    local clippingRect = display.newClippingRegionNode(cc.rect(0, 0, 900, 120)):addTo(self)
    -- self:setClippingRegion(cc.rect(0, 0, 900, 120))
    -- clippingRect:setTouchType(true)

    addTouchEvent(self, {endCallback = function (touch)
        self:itemClickedListener(nil, touch)
    end, moveCallback = function (touch)
        self:onMovedEvent(touch)
    end})

    self.scrollNodeOne = display.newNode():addTo(clippingRect):setTag(1000)
    self.scrollNodeOther = display.newNode():addTo(clippingRect):setTag(1001)

    -- 左右2个完全一样的node
    self.leftNode = self.scrollNodeOther
    self.rightNode = self.scrollNodeOne

    self:updateMyInfo()
end

function UnlimitedLevelUpScroll:updateMyInfo()

    -- 获取要显示的武将列表
    local allHero = sortHelper:getListByClassValueAndType(SortHelper.ALL, "ActiveHero")
    self.allHeroNum = #allHero
    self.index = 0
    local list = {}
    for i = 1, self.allHeroNum do
        table.insert(list, { id = allHero[i].id })
    end

    local sp
    local copySp
    self.itemList = {}
    self.copyList = {}

    for i = 1, #list do
        sp = self:newItem(list[i].id, i):setAnchorPoint(0.5, 0)
        sp:setScale(itemScaleNum)
        table.insert(self.itemList, sp)

        if #list >= unLimitNum then
            copySp = self:newItem(list[i].id, i):setAnchorPoint(0.5, 0)
            copySp:setScale(itemScaleNum)
            table.insert(self.copyList, copySp)
        end

        if list[i].id == self.id then

            self.index = i
        end
    end

    local disX = smallItemWidth * itemScaleNum * 0.5
    
    for _, v in pairs(self.itemList) do
        self.scrollNodeOne:addChild(v)
        v:setAnchorPoint(0.5, 0)
        v:setPosition(disX, 10)
        self.scrollNodeOne:setContentSize(v:getPositionX() + v:getContentSize().width * itemScaleNum * 0.5, nodeHeight)
        disX = disX + itemGap
    end

    self.itemList[self.index]:onSelectedOrCancel()
    self.selectedItem = self.itemList[self.index]

    if self.allHeroNum >= unLimitNum then
        disX = smallItemWidth * itemScaleNum * 0.5
        for _, v in pairs(self.copyList) do
            self.scrollNodeOther:addChild(v)
            v:setAnchorPoint(0.5, 0)
            v:setPosition(disX, 10)
            self.scrollNodeOther:setContentSize(v:getPositionX() + v:getContentSize().width * itemScaleNum * 0.5, nodeHeight)
            disX = disX + itemGap
        end

        self.copyList[self.index]:onSelectedOrCancel()
    end
    
    -- 对目前显示的元素位置修正
    if self.allHeroNum >= unLimitNum then
        self.scrollNodeOne:setPosition(0, 0)
        self.scrollNodeOther:setPosition(-self.scrollNodeOther:getContentSize().width - nodeGap, 0)
        local itemDisX = display.cx - self.itemList[self.index]:getPositionX()
        self:moveX(itemDisX)
        self:switchNode(nil, true)
    else
        self.scrollNodeOne:setPosition(441.25 - self.scrollNodeOne:getContentSize().width / 2, 0)
    end
    
    -- local red = cc.LayerColor:create(cc.c4b(100, 0, 0, 200))
    -- red:setContentSize(self.scrollNodeOne:getContentSize())
    -- red:setAnchorPoint(cc.p(0, 0))
    -- red:setPosition(0, 0)
    -- red:setTag(1000)
    -- self.scrollNodeOne:addChild(red, -1)

    -- local green = cc.LayerColor:create(cc.c4b(0, 100, 0, 200))
    -- green:setContentSize(self.scrollNodeOther:getContentSize())
    -- green:setAnchorPoint(cc.p(0, 0))
    -- green:setPosition(0, 0)
    -- green:setTag(1000)
    -- self.scrollNodeOther:addChild(green, -1)
end

function UnlimitedLevelUpScroll:newItem(id, index)
    local item
    item = require("app.uiExtend.scroll.UnlimitedLevelUpScrollItem").new(id, index)
    item:addClickedListener(handler(self, self.itemClickedListener))
    item:addMovedListener(handler(self, self.onMovedEvent))
    return item
end

function UnlimitedLevelUpScroll:addRefreshListener(listener)
    self.refreshListener = listener
end

function UnlimitedLevelUpScroll:itemClickedListener(item, touch)

    local cascadeBound = cc.rect(self:convertToWorldSpace(cc.p(0, 0)).x, self:convertToWorldSpace(cc.p(0, 0)).y, self:getContentSize().width, self:getContentSize().height)
    if not cc.rectContainsPoint(cascadeBound, cc.p(touch:getLocation().x, touch:getLocation().y)) then
        return false
    end

    if not item then
        self.isMoved = false
        return
    end

    if self.isMoved then
        self.isMoved = false
        return
    end

    if self.selectedItem and self.selectedItem.id ~= item.id then

        if self.allHeroNum >= unLimitNum then
            local otherItem = self:getTheOtherNode(self.selectedItem)[self.selectedItem.index]
            otherItem:onSelectedOrCancel()
            otherItem = self:getTheOtherNode(item)[item.index]
            otherItem:onSelectedOrCancel()
        end
         
        self.selectedItem:onSelectedOrCancel()
        self.selectedItem = item
        item:onSelectedOrCancel()
        self.index = self.selectedItem.index

        if self.refreshListener then
            self.refreshListener(item.id)
        end
    end
end

function UnlimitedLevelUpScroll:onMovedEvent(touch)

    if self.allHeroNum < unLimitNum then
        return
    end

    self.isMoved = true

    self:moveX(touch:getDelta().x)

    if touch:getDelta().x < 0 then
        -- 如果在显示区域里的是leftNode，则不做啥，如果是rightNode则马上把leftNode移到右边，且交换2个的指针
        self:switchNode("left")
    elseif touch:getDelta().x > 0 then
        self:switchNode("right")
    end
end

function UnlimitedLevelUpScroll:moveX(deltaX)
    self.scrollNodeOne:setPosition(self.scrollNodeOne:getPositionX() + deltaX, 0)
    self.scrollNodeOther:setPosition(self.scrollNodeOther:getPositionX() + deltaX, 0)
end

function UnlimitedLevelUpScroll:moveAuto()
    
end

-- fast drag
function UnlimitedLevelUpScroll:twiningScroll()

    -- 速度达不到需要自动移动
    if math.abs(self.speed.x) < 10 then
        return false
    end

    local disX = self:moveXY(0, 0, self.speed * 6)
    local disY = 0
    transition.moveBy(self.scrollNode,
        {x = disX, y = disY, time = 0.3,
        easing = "sineOut",
        onComplete = function()
            self:elasticScroll()
        end})
end

function UnlimitedLevelUpScroll:moveXY(orgX, orgY, speedX, speedY)
    if self.bBounce then
        -- bounce enable
        return orgX + speedX, orgY + speedY
    end

    local cascadeBound = self:getScrollNodeRect()
    local viewRect = self:getViewRectInWorldSpace()
    local x, y = orgX, orgY
    local disX, disY

    if speedX > 0 then
        if cascadeBound.x < viewRect.x then
            disX = viewRect.x - cascadeBound.x
            disX = disX / self.scaleToWorldSpace_.x
            x = orgX + math.min(disX, speedX)
        end
    else
        if cascadeBound.x + cascadeBound.width > viewRect.x + viewRect.width then
            disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
            disX = disX / self.scaleToWorldSpace_.x
            x = orgX + math.max(disX, speedX)
        end
    end

    if speedY > 0 then
        if cascadeBound.y < viewRect.y then
            disY = viewRect.y - cascadeBound.y
            disY = disY / self.scaleToWorldSpace_.y
            y = orgY + math.min(disY, speedY)
        end
    else
        if cascadeBound.y + cascadeBound.height > viewRect.y + viewRect.height then
            disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
            disY = disY / self.scaleToWorldSpace_.y
            y = orgY + math.max(disY, speedY)
        end
    end

    return x, y
end

function UnlimitedLevelUpScroll:switchNode(moveTo, adjust)
    
    local hasMove = false

    if moveTo == "left" then
        if self.leftNode:getPositionX() <= -self.leftNode:getContentSize().width - nodeGap then
            -- leftNode 完全隐藏，移到右边去
            self.leftNode:setPosition(self.rightNode:getPositionX() + self.rightNode:getContentSize().width + nodeGap, 0)
            hasMove = true
        end
    elseif moveTo == "right" then
        if self.rightNode:getPositionX() >= self:getContentSize().width + nodeGap then
            -- rightNode 完全隐藏，移到左边去
            self.rightNode:setPosition(self.leftNode:getPositionX() - self.rightNode:getContentSize().width - nodeGap, 0)
            hasMove = true
        end
    elseif adjust then
        -- 这种情况只有需要移到右边
        if self.rightNode:getPositionX() + self.rightNode:getContentSize().width <= self:getContentSize().width then
            -- 很有可能需要显示在右边
            self.leftNode:setPosition(self.rightNode:getPositionX() + self.rightNode:getContentSize().width + nodeGap, 0)
            hasMove = true
        end
    end

    if hasMove then
        local temp = self.rightNode
        self.rightNode = self.leftNode
        self.leftNode = temp
    end
end

function UnlimitedLevelUpScroll:getMyList(item)
    if self.itemList[item.index] == item then
        return self.itemList
    else
        return self.copyList
    end
end

function UnlimitedLevelUpScroll:getTheOtherNode(item)
    if self.itemList[item.index] == item then
        return self.copyList
    else
        return self.itemList
    end
end

function UnlimitedLevelUpScroll:moveLeftOnce()

    if self.allHeroNum < unLimitNum then
        if self.index == 1 then
            return
        else
            self.selectedItem:onSelectedOrCancel()
            self:getMyList(self.selectedItem)[self.selectedItem.index - 1]:onSelectedOrCancel()
            self.selectedItem = self:getMyList(self.selectedItem)[self.selectedItem.index - 1]
            self.index = self.index - 1
        end
    else
        -- 先取消目前的元素的选中
        local otherItem = self:getTheOtherNode(self.selectedItem)[self.selectedItem.index]
        self.selectedItem:onSelectedOrCancel()
        otherItem:onSelectedOrCancel()

        -- 先计算好下一个的索引
        if self.index == 1 then
            self.index = self.allHeroNum
            self.selectedItem = self:getTheOtherNode(self.selectedItem)[self.index]
        else
            self.index = self.index - 1
            self.selectedItem = self:getMyList(self.selectedItem)[self.index]
        end
        otherItem = self:getTheOtherNode(self.selectedItem)[self.selectedItem.index]

        -- 前一个元素被选中
        self.selectedItem:onSelectedOrCancel()
        otherItem:onSelectedOrCancel()

        -- 计算下位置
        if self.selectedItem:convertToWorldSpace(cc.p(0, 0)).x < 181.75 then
            -- 被遮住了，要移出来
            self:moveX(181.75 - self.selectedItem:convertToWorldSpace(cc.p(0, 0)).x)
            self:switchNode("right")
        end
    end

    if self.refreshListener then
        self.refreshListener(self.selectedItem.id)
    end
end

function UnlimitedLevelUpScroll:moveRightOnce()

    if self.allHeroNum < unLimitNum then
        if self.index == self.allHeroNum then
            return
        else
            self.selectedItem:onSelectedOrCancel()
            self:getMyList(self.selectedItem)[self.selectedItem.index + 1]:onSelectedOrCancel()
            self.selectedItem = self:getMyList(self.selectedItem)[self.selectedItem.index + 1]
            self.index = self.index + 1
        end
    else
        -- 先取消目前的元素的选中
        local otherItem = self:getTheOtherNode(self.selectedItem)[self.selectedItem.index]
        self.selectedItem:onSelectedOrCancel()
        otherItem:onSelectedOrCancel()

        -- 先计算好下一个的索引
        if self.index == self.allHeroNum then
            self.index = 1
            self.selectedItem = self:getTheOtherNode(self.selectedItem)[self.index]
        else
            self.index = self.index + 1
            self.selectedItem = self:getMyList(self.selectedItem)[self.index]
        end
        otherItem = self:getTheOtherNode(self.selectedItem)[self.selectedItem.index]

        -- 后一个元素被选中
        self.selectedItem:onSelectedOrCancel()
        otherItem:onSelectedOrCancel()

        -- 计算下位置
        if self.selectedItem:convertToWorldSpace(cc.p(0, 0)).x > 997.75 then
            -- 被遮住了，要移出来
            self:moveX(997.75 - self.selectedItem:convertToWorldSpace(cc.p(0, 0)).x)
            self:switchNode("left")
        end
    end

    if self.refreshListener then
        self.refreshListener(self.selectedItem.id)
    end
end

return UnlimitedLevelUpScroll

