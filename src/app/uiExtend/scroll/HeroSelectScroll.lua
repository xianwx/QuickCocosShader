-- HeroSelectScroll.lua
-- Author: xianwx
-- Date: 2016-04-21 17:45:38
-- 武将选择界面的滚动界面

local BarAlwaysShowScroll = import(".BarAlwaysShowScroll")
local HeroSelectScroll = class("HeroSelectScroll", BarAlwaysShowScroll)
local general = require("app.layer.init").get("general")

function HeroSelectScroll:initSelf()
    self.curPoint = 1
    self.itemHDis = 240
    self.itemVDis = 140
    self.classValue = 0
    self.initComp = false
    -- 先创建好分隔条
    self:createDividingLine()
end

-- 设置界面元素界限
function HeroSelectScroll:setLimit()

    -- 计算一下需要分多少行
    local line = math.ceil((#sortHelper:getListByClassValueAndType(self.classValue, "CanActiveHero") + #sortHelper:getListByClassValueAndType(self.classValue, "ActiveHero")) / self.lineNumLimit) + math.ceil(#sortHelper:getListByClassValueAndType(self.classValue, "InactiveHero") / self.lineNumLimit)
    self.scrollNode:setContentSize(self.showRect.width, self.itemVDis * line + 40)
    self.scrollNode:setPosition(self.showRect.x, (self.showRect.y + self.showRect.height) - self.scrollNode:getContentSize().height)
    self.upLimit = (self.showRect.y + self.showRect.height) - self.scrollNode:getContentSize().height
    self.downLimit = self.showRect.y
    self:countParams()
end

-- 计算各个节点
function HeroSelectScroll:countParams()
    self.activingNum = #sortHelper:getListByClassValueAndType(self.classValue, "CanActiveHero")
    self.inactiveNum = #sortHelper:getListByClassValueAndType(self.classValue, "InactiveHero")
    self.activeEnd = #sortHelper:getListByClassValueAndType(self.classValue, "CanActiveHero") + #sortHelper:getListByClassValueAndType(self.classValue, "ActiveHero")
    self.inactiveStart = math.ceil(self.activeEnd / self.lineNumLimit) * self.lineNumLimit + 1
end

function HeroSelectScroll:onEnter()
    self:frameAdd()
end

function HeroSelectScroll:frameAdd()

    if self.count < self.itemNum then
        self:performWithDelay(function ()
            self:addItemToScroll()
            self:frameAdd()
        end, 0.01)
    else
        -- 计算出最末端的一行的起始下标
        self.firstIndex = 1
        self.lastShowLineIndex = 21
        self.initComp = true
    end
end

function HeroSelectScroll:addItemToScroll()

    local item
    for _ = 1, 2 do

        if self.count >= self.itemNum then
            return
        end

        if self:checkDividingNeedToShow(self.count) then
            -- 先把分隔符创建好
            self.dividingLine:setPosition(0, self.disY + self.itemVDis - 25)
            self.disY = self.disY - 50
            self.disX = 0
            self.dividingLine:setVisible(true)
        end

        item = self:newItem()
        self:setItemInfo(item, item.lineIndex)
        self.scrollNode:addChild(item)
        item:setVisible(self:checkItemNeedToShow(item.lineIndex))
    end
end

function HeroSelectScroll:newItem()
    local node = require("app.uiExtend.GeneralsInfoNode").new():setAnchorPoint(0, 0)
    node:setPosition(self.disX, self.disY)
    node:addMovedListener(handler(self, self.onMovedEvent))
    node:addClickedListener(handler(self, self.gotoDetailLayer))
    node:addHeroAddListener(handler(self, self.heroAddCallback))
    node:addTouchEnableListener(handler(self, self.clickPreconditions))
    node:addMoveEndListener(handler(self, self.moveEnd))

    self.count = self.count + 1
    node.lineIndex = self.count
    node:setTag(self.count)
    self:countLinePostion()
    return node
end

function HeroSelectScroll:moveUpHandler()
    if self.scrollNode:getChildByTag(self.lastShowLineIndex):convertToWorldSpace(cc.p(0, 0)).y < -85 then
        self:downToUp()
    end

    if self.dividingLine:convertToWorldSpace(cc.p(0, 0)).y < 33 then
        self.dividingLine:setVisible(false)
    end
end

function HeroSelectScroll:moveDownHandler()

    if self.scrollNode:getChildByTag(self.lastShowLineIndex):convertToWorldSpace(cc.p(0, 0)).y > 49 then
        self:upToDown()
    end

    if self.dividingLine:convertToWorldSpace(cc.p(0, 0)).y > 646 then
        self.dividingLine:setVisible(false)
    end
end

function HeroSelectScroll:upToDown()
    
    local item
    local posY = self.scrollNode:getChildByTag(self.lastShowLineIndex):getPositionY()
    local count = 0
    local startIndex = self.scrollNode:getChildByTag(self.lastShowLineIndex).lineIndex

    if self:checkDividingNeedToShow(startIndex + self.lineNumLimit) then
        self.dividingLine:setPosition(0, posY - 25)
        posY = posY - 50
        self.dividingLine:setVisible(true)
    end

    for i = self.firstIndex, self.firstIndex + self.lineNumLimit - 1 do
        item = self.scrollNode:getChildByTag(i)
        self:setItemInfo(item, startIndex + self.lineNumLimit + count)
        count = count + 1
        if item.lineIndex % self.lineNumLimit == 0 then

            self:checkDividingNeedToShow(item.lineIndex)
        end
        item:setPosition(item:getPositionX(), posY - self.itemVDis)
        item:setVisible(self:checkItemNeedToShow(item.lineIndex))
    end

    -- 最上端的移动完成，把指针改一下
    self.lastShowLineIndex = self.firstIndex
    self.firstIndex = self.firstIndex + self.lineNumLimit

    if self.firstIndex > self.itemNum then
        self.firstIndex = self.firstIndex - self.itemNum
    end
end

function HeroSelectScroll:downToUp()
    local item
    local posY = self.scrollNode:getChildByTag(self.firstIndex):getPositionY()
    local count = 0
    local startIndex = self.scrollNode:getChildByTag(self.firstIndex).lineIndex

    if self:checkDividingNeedToShow(startIndex) then
        self.dividingLine:setPosition(0, posY + self.itemVDis + 25)
        posY = posY + 50
        self.dividingLine:setVisible(true)
    end

    for i = self.lastShowLineIndex, self.lastShowLineIndex + self.lineNumLimit - 1 do
        item = self.scrollNode:getChildByTag(i)
        self:setItemInfo(item, startIndex - self.lineNumLimit + count)
        count = count + 1
        item:setPosition(item:getPositionX(), posY + self.itemVDis)
        item:setVisible(self:checkItemNeedToShow(item.lineIndex))
    end

    -- 最下端的移动完成，把指针改一下
    self.firstIndex = self.lastShowLineIndex
    self.lastShowLineIndex = self.lastShowLineIndex - self.lineNumLimit

    if self.lastShowLineIndex < 0 then
        self.lastShowLineIndex = self.itemNum - self.lineNumLimit + 1
    end
end

function HeroSelectScroll:setItemInfo(item, index)

    item.lineIndex = index
    if index <= self.activingNum then

        item:updateMyInfo(sortHelper:getListByClassValueAndType(self.classValue, "CanActiveHero")[index], "activing")
    elseif index <= self.activeEnd then
        item.index = index - self.activingNum
        item:updateMyInfo(sortHelper:getListByClassValueAndType(self.classValue, "ActiveHero")[index - self.activingNum].id, "actived")
    elseif index >= self.inactiveStart and index < self.inactiveStart + self.inactiveNum then
        item:updateMyInfo(sortHelper:getListByClassValueAndType(self.classValue, "InactiveHero")[index - self.inactiveStart + 1], "inactive")
    end
end

function HeroSelectScroll:checkItemNeedToShow(lineIndex)

    if lineIndex <= self.activeEnd then
        return true
    elseif lineIndex < self.inactiveStart + self.inactiveNum then
        return lineIndex >= self.inactiveStart
    else
        return false
    end
end

function HeroSelectScroll:checkDividingNeedToShow(lineIndex)

    return (lineIndex == self.inactiveStart - 1 or lineIndex == self.inactiveStart) and (self.dividingLine:isVisible() == false)
end

function HeroSelectScroll:createDividingLine()

    if self.lineNum ~= 1 then
        self.disY = self.disY - self.itemVDis
    end
    
    self.dividingLine = display.newNode():setAnchorPoint(0, 0)
    self.dividingLine:setContentSize(1190, 40)
    display.newSprite("UI/GeneralSelected/dividingLineFringe.png", 210, 0):addTo(self.dividingLine):setFlippedX(true)
    display.newSprite("UI/GeneralSelected/dividingLineFringe.png", 990, 0):addTo(self.dividingLine)
    display.newScale9Sprite("UI/GeneralSelected/dividingLineBg.png", 600, 0, cc.size(420, 40)):addTo(self.dividingLine)
    createSimpleLabel({ text = getStringById(60000083), size = 24, align = cc.ui.TEXT_VALIGN_CENTER, color = cc.c3b(255, 240, 0), x = 480, y = 0, outLine = true }):addTo(self.dividingLine)
    self.scrollNode:addChild(self.dividingLine)
    self.dividingLine:setVisible(false)
end

function HeroSelectScroll:heroAddCallback(event, id)
    netControl:removeEvent(event.name)
    local params = {heroId = id}
    layerLoadControl:pushDialogTop("gacha.GachaGeneralDisplayLayer", params, { notShowPopup = true })

    -- 修改排序数组
    gameData:heroAdd(event.data.hero)
    gameData:updateAccount(event.data.account)
    gameData:updateBackpack({ props = event.data.props })
end

function HeroSelectScroll:gotoDetailLayer(id, touch, cascadeBound)

    if self:clickPreconditions(cascadeBound, touch) then
        layerLoadControl:addLayer("GeneralsDetailLayer", {heroId = id}, general)
    end

    self:moveEnd()
end

function HeroSelectScroll:cleanupSelf()
    self.activeingComplete = false
    self.activedComplete = false
    self.count = 0
    self.curPoint = 1
    self.lineNum = 1
    self.curLine = 1
    self:setLimit()
    self.dividingLine:setVisible(false)
    self.disX = 0
    self.disY = self.scrollNode:getContentSize().height - self.itemVDis

    -- 将之前创建好的item全部归位
    self.firstIndex = 1
    self.lastShowLineIndex = 21

    local item
    local lineNum = 1
    local disX, disY = self.disX, self.disY
    local curLine = 1

    for i = 1, self.scrollNode:getChildrenCount() - 1 do

        if self:checkDividingNeedToShow(i - 1) then
            -- 先把分隔符创建好
            self.dividingLine:setPosition(0, disY + self.itemVDis - 25)
            disY = disY - 50
            disX = 0
            self.dividingLine:setVisible(true)
        end

        item = self.scrollNode:getChildByTag(i)
        item:setPosition(disX, disY)
        item.lineIndex = i
        self:setItemInfo(item, item.lineIndex)
        item:setVisible(self:checkItemNeedToShow(item.lineIndex))

        if lineNum % self.lineNumLimit == 0 then
            disX = 0
            disY = disY - self.itemVDis
            lineNum = 1
            curLine = curLine + 1
        else
            disX = disX + self.itemHDis
            lineNum = lineNum + 1
        end
    end

    self:gotoTop()
end

function HeroSelectScroll:reload(classValue)
    if classValue then
        self.classValue = classValue
    end
    
    self:cleanupSelf()
end

return HeroSelectScroll