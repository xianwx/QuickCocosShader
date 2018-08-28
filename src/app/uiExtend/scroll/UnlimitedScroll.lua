-- UnlimitedScroll.lua
-- Author: xianwx
-- Date: 2016-03-29 18:55:20
-- 无限拖动的滚动条

local itemGap = 100
local smallItemWidth = 110
local nodeGap = 100 - 110 * 0.65
local itemScaleNum = 0.65
local offset = 25 + nodeGap
local longGap = 50.75
local nodeHeight = 77
local unLimitNum = 11

local UnlimitedScroll = class("UnlimitedScroll", function ()
    return display.newNode()
end)

function UnlimitedScroll:ctor(index)

    local width = 1200
    -- 背景
    local bgUpSp = display.newScale9Sprite("UI/GeneralUI/scrollBg.png", 10, 20, cc.size(width - 40, 90)):addTo(self, -1)
    bgUpSp:setAnchorPoint(0, 0)
    bgUpSp:setPosition(20, 0)

    local scrollFrameUp = display.newScale9Sprite("UI/GeneralUI/scrollFrame.png", 10, 20, cc.size(width, 38)):addTo(self, 1)
    scrollFrameUp:setAnchorPoint(0, 1)
    scrollFrameUp:setPosition(0, 90)

    local scrollFrameDown = display.newScale9Sprite("UI/GeneralUI/scrollFrame.png", 10, 20, cc.size(width, 38)):addTo(self, 1):setFlippedY(true)
    scrollFrameDown:setAnchorPoint(0, 0)
    scrollFrameDown:setPosition(0, 38)

    self:setContentSize(width, 90)

    -- 裁剪区域
    local clippingRect = display.newClippingRegionNode(cc.rect(25, 0, width, 120)):addTo(self, 3)

    addTouchEvent(self, {endCallback = function (touch)
        self:onClicked(touch)
    end, moveCallback = function (touch)
        self:onMovedEvent(touch)
    end})

    self.scrollNodeOne = display.newNode():addTo(clippingRect):setTag(1000)
    self.scrollNodeOther = display.newNode():addTo(clippingRect):setTag(1001)

    -- 左右2个完全一样的node
    self.leftNode = self.scrollNodeOther
    self.rightNode = self.scrollNodeOne

    self.selectedFrame = display.newSprite("UI/GeneralUI/scrollSelectedFrame.png", display.cx, 3):addTo(self, 2)
    self.selectedFrame:setAnchorPoint(0.5, 0)
    self.selectedFrame:setVisible(true)

    self:updateMyInfo(index)
end

function UnlimitedScroll:updateMyInfo(index)

    -- 获取要显示的武将列表
    local allHero = sortHelper:getListByClassValueAndType(SortHelper.ALL, "ActiveHero")
    self.allHeroNum = #allHero
    local list = {}
    for i = 1, self.allHeroNum do
        table.insert(list, { id = allHero[i].id })
    end

    -- 创建承载元素
    local sp
    local copySp

    self.itemList = {}
    self.copyList = {}
    for i = 1, #list do
        sp = self:newItem(list[i].id, i, self.itemList):setAnchorPoint(0.5, 0)
        if i ~= index then
            sp:setScale(itemScaleNum)
        end
        table.insert(self.itemList, sp)

        if #list >= unLimitNum then
            copySp = self:newItem(list[i].id, i, self.copyList):setAnchorPoint(0.5, 0)
            copySp:setScale(itemScaleNum)
            table.insert(self.copyList, copySp)
        end
    end

    -- 加到界面上并计算位置等
    local disX = smallItemWidth * itemScaleNum * 0.5
    
    for _, v in pairs(self.itemList) do
        self.scrollNodeOne:addChild(v)
        v:setAnchorPoint(0.5, 0)

        if v:getScale() == 1 then
            v:setPosition(disX + longGap, 6)
            self.scrollNodeOne:setContentSize(v:getPositionX() + v:getContentSize().width * 0.5, nodeHeight)
            disX = disX + itemGap + longGap * 2
        else
            v:setPosition(disX, 10)
            self.scrollNodeOne:setContentSize(v:getPositionX() + v:getContentSize().width * itemScaleNum * 0.5, nodeHeight)
            disX = disX + itemGap
        end
    end

    self.onSelectedNodeWidth = self.scrollNodeOne:getContentSize().width        -- 有选中元素的宽度

    disX = smallItemWidth * itemScaleNum * 0.5      -- reset

    -- 大于10的话，创建另一个node
    if self.allHeroNum >= unLimitNum then
        for _, v in pairs(self.copyList) do
            self.scrollNodeOther:addChild(v)
            v:setAnchorPoint(0.5, 0)
            v:setPosition(disX, 10)
            self.scrollNodeOther:setContentSize(v:getPositionX() + v:getContentSize().width * itemScaleNum * 0.5, nodeHeight)
            disX = disX + itemGap
        end

        self.noSelectedNodeWidth = self.scrollNodeOther:getContentSize().width
    else
        -- 不大于10 只简单计算下宽度
        local count = 0
        for _, _ in pairs(self.itemList) do
            count = disX + smallItemWidth * itemScaleNum * 0.5
            disX = disX + itemGap
        end

        self.noSelectedNodeWidth = count
    end

    self.leftHidePoint = cc.p(-self.scrollNodeOther:getContentSize().width - nodeGap + offset, 0)      -- 左隐藏点

    self.scrollNodeOne:setPosition(offset, 0)
    self.scrollNodeOther:setPosition(-self.scrollNodeOther:getContentSize().width - nodeGap + offset, 0)

    -- 对目前显示的元素位置修正
    local itemDisX = display.cx - offset - self.itemList[index]:getPositionX()

    self:moveX(itemDisX)

    -- 小于10个就不做循环滚动
    if index == self.allHeroNum and index >= unLimitNum then
        self.leftNode:setPosition(self.rightNode:getPositionX() + self.rightNode:getContentSize().width + longGap, 0)
        local temp = self.rightNode
        self.rightNode = self.leftNode
        self.leftNode = temp
    else
        self:switchNode(nil, true)
    end

    self.selectedItem = self.itemList[index]

    -- local black = cc.LayerColor:create(cc.c4b(100, 0, 0, 200))
    -- black:setContentSize(self.scrollNodeOne:getContentSize())
    -- black:setAnchorPoint(cc.p(0, 0))
    -- black:setPosition(0, 0)
    -- black:setTag(1000)
    -- self.scrollNodeOne:addChild(black)

    -- local other = cc.LayerColor:create(cc.c4b(100, 100, 0, 200))
    -- other:setContentSize(self.scrollNodeOther:getContentSize())
    -- other:setAnchorPoint(cc.p(0, 0))
    -- other:setPosition(0, 0)
    -- other:setTag(1000)
    -- self.scrollNodeOther:addChild(other)
end

function UnlimitedScroll:newItem(id, index, list)
    local item
    item = require("app.uiExtend.scroll.UnlimitedScrollItem").new(id, index, list)
    item:addClickedListener(handler(self, self.itemSizeChangeListener))
    item:addMovedListener(handler(self, self.onMovedEvent))
    return item
end

function UnlimitedScroll:addRefreshListener(listener)
    self.refreshListener = listener
end

function UnlimitedScroll:itemSizeChangeListener(item, index, list)

    if self.isMoved then
        -- self.isMoved = false
        self:onClicked()
        return
    end

    if self.selectedItem == nil or item == self.selectedItem then
        return
    end

    self.isMoved = true

    self:resetSelectedItem(self:getMyList(self.selectedItem))

    self:showSelectedItem(item, index, list)
end

function UnlimitedScroll:doShowSelected()
    local item, index, list = self:getCenterItem()
    self:showSelectedItem(item, index, list)
end

function UnlimitedScroll:resetSelectedItem(list, showAction)
    
    local item
    local otherNode
    otherNode = self:getTheOtherNode(self.selectedItem:getParent())

    self.selectedFrame:setVisible(false)

    -- y轴复位
    self.selectedItem:setPosition(self.selectedItem:getPositionX(), self.selectedItem:getPositionY() + 4)
    if showAction then
        self.onResetShow = true
        self.selectedItem:runAction(transition.sequence({
                cc.ScaleTo:create(0.08, 0.65),
            }))

        for i = self.selectedItem.index, #list do
            item = list[i]
            if i == self.selectedItem.index then
                if i == #list then
                    transition.execute(item, cc.MoveBy:create(0.1, cc.p(-longGap, 0)), {onComplete = function ()
                        self.onResetShow = false
                        if self.tryShowSelected then
                            self:doShowSelected()
                        end
                    end})
                else
                    item:runAction(cc.MoveBy:create(0.1, cc.p(-longGap, 0)))
                end
            elseif i ~= #list then
                item:runAction(cc.MoveBy:create(0.1, cc.p(-longGap * 2, 0)))
            else
                transition.execute(item, cc.MoveBy:create(0.1, cc.p(-longGap * 2, 0)), {onComplete = function ()
                    self.onResetShow = false
                    if self.tryShowSelected then
                        self:doShowSelected()
                    end
                end})
            end
        end

        -- 在右边，往左移
        -- 如果太少不显示就不判断了
        if self.allHeroNum >= unLimitNum then
            if otherNode:getPositionX() > self.selectedItem:getParent():getPositionX() then
                self.moveRight = true
                transition.execute(otherNode, cc.MoveBy:create(0.1, cc.p(-longGap * 2, 0)), {onComplete = function ()
                    self.moveRight = false
                    if self.tryShowSelected then
                        self:doShowSelected()
                    end
                end})
            end
        end
    else
        self.selectedItem:setScale(0.65)
        for i = self.selectedItem.index, #list do
            item = list[i]
            if i == self.selectedItem.index then
                item:setPosition(item:getPositionX() - longGap, item:getPositionY())
            else
                item:setPosition(item:getPositionX() - longGap * 2, item:getPositionY())
            end
        end

        -- 在右边，往左移
        if otherNode:getPositionX() > self.selectedItem:getParent():getPositionX() then
            otherNode:setPosition(otherNode:getPositionX() - longGap * 2, 0)
        end
    end

    -- 恢复大小
    self.selectedItem:getParent():setContentSize(self.noSelectedNodeWidth, nodeHeight)
end

function UnlimitedScroll:showSelectedItem(item, index, list)

    if self.onShowEffect then
        return
    end

    -- 如果当前复位特效还没播放完毕
    if self.onResetShow or self.moveRight then
        self.tryShowSelected = true
        return
    end

    self.onShowEffect = true
    self.tryShowSelected = false

    -- 计算当前元素距离display.cx，减去缩放以及锚点设置的偏差
    local itemDisX = display.cx - item:convertToWorldSpace(cc.p(0, 0)).x - (smallItemWidth * itemScaleNum * 0.5) - longGap

    -- 先移动控件
    self.scrollNodeOne:runAction(cc.MoveBy:create(0.1, cc.p(itemDisX, 0)))
    self.scrollNodeOther:runAction(cc.MoveBy:create(0.1, cc.p(itemDisX, 0)))

    -- 移动并缩放
    item:runAction(transition.sequence({
        cc.MoveBy:create(0.1, cc.p(0, item:getScale() == 1 and 4 or -4)),
        cc.ScaleTo:create(0.15, item:getScale() == 1 and 0.65 or 1.0),
        cc.CallFunc:create(function ()
            self.isMoved = false
            self:switchNode(itemDisX > 0 and "right" or "left")
            -- self:switchNode(nil, true)
            self.selectedFrame:setVisible(true)
            self.onShowEffect = false
            -- print("item scale complete")
        end)
        }))

    local gotoGap
    for i = index, #list do

        if i == index then
            gotoGap = longGap
        else
            gotoGap = longGap * 2
        end

        transition.execute(list[i], cc.MoveBy:create(0.1, cc.p(gotoGap, 0)))
    end

    item:getParent():setContentSize(self.onSelectedNodeWidth, nodeHeight)
    self:getTheOtherNode(item:getParent()):setContentSize(self.noSelectedNodeWidth, nodeHeight)

    if self:getTheOtherNode(item:getParent()):getPositionX() > item:getParent():getPositionX() then
        transition.execute(self:getTheOtherNode(item:getParent()), cc.MoveBy:create(0.1, cc.p(longGap * 2, 0)), {onComplete = function ()
            -- print("node move compelte")
        end})
    end

    self.selectedItem = item
    self.refreshListener(item.id, item.index)
    -- 通知武将界面刷新数据

    -- 恢复大小
    -- local bgColor = item:getParent():getChildByTag(1000)
    -- local color = bgColor:getColor()
    -- bgColor:removeSelf()

    -- local colorLayer = cc.LayerColor:create(cc.c4b(color.r, color.g, color.b, 200))
    -- colorLayer:setContentSize(item:getParent():getContentSize())
    -- colorLayer:setAnchorPoint(cc.p(0, 0))
    -- colorLayer:setPosition(0, 0)
    -- colorLayer:setTag(1000)
    -- item:getParent():addChild(colorLayer)
end

function UnlimitedScroll:getTheOtherNode(one)
    if one == self.scrollNodeOne then
        return self.scrollNodeOther
    else
        return self.scrollNodeOne
    end
end

function UnlimitedScroll:getMyList(item)
    if self.itemList[item.index] == item then
        return self.itemList
    else
        return self.copyList
    end
end

function UnlimitedScroll:onClicked()

    if not self.isMoved then
        return
    end

    -- self.isMoved = false

    local item, index, list = self:getCenterItem()

    self:showSelectedItem(item, index, list)
end

function UnlimitedScroll:getCenterItem()
    
    local posX, item, cpItem, index, list, disX, cpDisX, tempList
    for i = 1, #self.itemList do
        item = self.itemList[i]
        cpItem = self.copyList[i]
        disX = math.abs(display.cx - item:convertToWorldSpace(cc.p(0, 0)).x - (smallItemWidth * itemScaleNum * 0.5) - longGap)

        if cpItem then
            cpDisX = math.abs(display.cx - cpItem:convertToWorldSpace(cc.p(0, 0)).x - (smallItemWidth * itemScaleNum * 0.5) - longGap)
            -- item = disX > cpDisX and cpItem or item
            tempList = disX > cpDisX and self.copyList or self.itemList
            disX = disX > cpDisX and cpDisX or disX
        else
            tempList = self.itemList
        end

        if posX == nil or posX > disX then
            posX = disX
            index = i
            list = tempList
        end
    end

    return list[index], index, list
end

function UnlimitedScroll:onMovedEvent(touch)

    if self.onShowEffect then
        return
    end

    if not self.isMoved and self.selectedItem ~= nil then
        -- self.selectedFrame:setVisible(false)
        self:resetSelectedItem(self:getMyList(self.selectedItem), true)
        self.selectedItem = nil
    end

    self.isMoved = true

    if self.allHeroNum < unLimitNum and touch:getDelta().x > 0 and self.scrollNodeOne:getPositionX() > display.cx then
        return
    elseif self.allHeroNum < unLimitNum and touch:getDelta().x < 0 and self.scrollNodeOne:getPositionX() + self.scrollNodeOne:getContentSize().width < display.cx then
        return
    end

    self:moveX(touch:getDelta().x)
    -- print("dis: ", touch:getLocation().x - touch:getPreviousLocation().x)

    -- print("disX: ", touch:getDelta().x)
    if touch:getDelta().x < 0 and self.allHeroNum >= unLimitNum then
        -- 如果在显示区域里的是leftNode，则不做啥，如果是rightNode则马上把leftNode移到右边，且交换2个的指针
        self:switchNode("left")
    elseif touch:getDelta().x > 0 then
        self:switchNode("right")
    end
end

function UnlimitedScroll:moveX(deltaX)
    self.scrollNodeOne:setPosition(self.scrollNodeOne:getPositionX() + deltaX, 0)
    self.scrollNodeOther:setPosition(self.scrollNodeOther:getPositionX() + deltaX, 0)
end

function UnlimitedScroll:moveAuto()
    
end

-- fast drag
function UnlimitedScroll:twiningScroll()

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

function UnlimitedScroll:moveXY(orgX, orgY, speedX, speedY)
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

function UnlimitedScroll:switchNode(moveTo, adjust)
    
    local hasMove = false

    if moveTo == "left" then
        if self.leftNode:getPositionX() <= -self.leftNode:getContentSize().width - nodeGap + offset then
            -- leftNode 完全隐藏，移到右边去
            self.leftNode:stopAllActions()
            self.leftNode:setPosition(self.rightNode:getPositionX() + self.rightNode:getContentSize().width + nodeGap, 0)
            hasMove = true
        end
    elseif moveTo == "right" then
        if self.rightNode:getPositionX() >= 1150 then
            -- rightNode 完全隐藏，移到左边去
            self.rightNode:stopAllActions()
            self.rightNode:setPosition(self.leftNode:getPositionX() - self.rightNode:getContentSize().width - nodeGap, 0)
            hasMove = true
        end
    elseif adjust then
        -- 这种情况只有需要移到右边
        if self.rightNode:getPositionX() + self.rightNode:getContentSize().width <= self:getContentSize().width then
            -- 很有可能需要显示在右边
            self.leftNode:stopAllActions()
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

return UnlimitedScroll
