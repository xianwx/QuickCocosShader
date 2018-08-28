-- GeneralsInfoNode.lua
-- Author: xianwx
-- Date: 2016-04-18 12:17:46
-- 武将选择界面滚动条item

local general = require("app.layer.init").get("general")
local GeneralsInfoNode = class("GeneralsInfoNode", function ()
    return display.newNode()
end)

-- 状态、星星设置、战力设置、是否新的
-- @params status   必要，状态
-- @params id       必要，武将id
-- @params star     可选，传入的话显示这个星级
-- @params power    可选，传入的值为等级，显示传入等级的战力
-- @params level    可选，传入的话显示传入等级
function GeneralsInfoNode:ctor(params)
    self:setContentSize(230, 120)

    -- 未激活模块
    self.inactiveNode = display.newNode():addTo(self, 1):setVisible(false):setContentSize(self:getContentSize())

    -- 可以激活模块
    self.activingNode = display.newNode():addTo(self, 1):setVisible(false):setContentSize(self:getContentSize())

    -- 已获得模块
    self.activedNode = display.newNode():addTo(self, 1):setVisible(false):setContentSize(self:getContentSize())

    -- 图片
    self.bgSp = display.newSprite():setAnchorPoint(0, 0):addTo(self, -1)
    display.newSprite("UI/GeneralSelected/loadingbarfloor.png", 17, 109):setAnchorPoint(0, 0):addTo(self.inactiveNode)
    display.newSprite("UI/GeneralSelected/loadingbarfloor.png", 17, 109):setAnchorPoint(0, 0):addTo(self.activingNode)
    display.newSprite("UI/GeneralSelected/loadingbarstonefinish.png", 17, 109):setAnchorPoint(0, 0):addTo(self.activingNode)

    self.heroIcon = display.newSprite():setScale(0.7):addTo(self):setLocalZOrder(0)
    self.heroIcon:setPosition(55, 56)
    
    -- 按钮
    self.getBtn = display.newNode():addTo(self.inactiveNode):setContentSize(101, 52):setPosition(160, 40):setAnchorPoint(0.5, 0.5)
    self.activeBtn = display.newNode():addTo(self.activingNode):setContentSize(101, 52):setPosition(160, 40):setAnchorPoint(0.5, 0.5)

    self.getBtn:addChild(display.newSprite("UI/GeneralSelected/btnGet.png", 0, 0):setAnchorPoint(0, 0))
    self.activeBtn:addChild(display.newSprite("UI/GeneralSelected/btnActive.png", 0, 0):setAnchorPoint(0, 0))

    self.getBtn:addChild(createSimpleLabel({ text = getStringById(60000084), size = 30, align = cc.ui.TEXT_ALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_CENTER, dimensions = cc.size(101, 52), outLine = true }):setAnchorPoint(0, 0))
    self.activeBtn:addChild(createSimpleLabel({ text = getStringById(60000088), size = 30, align = cc.ui.TEXT_ALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_CENTER, dimensions = cc.size(101, 52), outLine = true }):setAnchorPoint(0, 0))

    -- 星星们
    for i = 1, 5 do
        self["star" .. i] = display.newSprite("UI/GeneralSelected/star.png", 12 + (i - 1) * 29, 109):setAnchorPoint(0, 0):addTo(self.activedNode)
    end

    -- 进度条
    self.loadingBar = ccui.LoadingBar:create("UI/GeneralSelected/loadingbarstoneunfinish.png", 100):setAnchorPoint(0, 0):addTo(self.inactiveNode):setPosition(17, 109)

    -- label
    self.nameLabel = createSimpleLabel({ text = "", size = 20, align = cc.ui.TEXT_ALIGN_LEFT, x = 100, y = 76, outLine = true }):addTo(self):setAnchorPoint(0, 0)
    self.lv = createSimpleLabel({ text = "", size = 17, align = cc.ui.TEXT_ALIGN_RIGHT, x = 10, y = 17, dimensions = cc.size(80, 17), outLine = true }):addTo(self.activedNode):setAnchorPoint(0, 0)
    self.army = createSimpleLabel({ text = "", size = 20, align = cc.ui.TEXT_ALIGN_LEFT, x = 100, y = 45, color = cc.c3b(255, 82, 82), outLine = true }):addTo(self.activedNode):setAnchorPoint(0, 0)
    createSimpleLabel({ text = getStringById(60000089), size = 20, align = cc.ui.TEXT_ALIGN_LEFT, x = 100, y = 16, color = cc.c3b(255, 240, 0), outLine = true }):addTo(self.activedNode):setAnchorPoint(0, 0)
    self.power = createSimpleLabel({ text = "", size = 20, align = cc.ui.TEXT_ALIGN_LEFT, x = 143, y = 16, color = cc.c3b(255, 240, 0), outLine = true }):addTo(self.activedNode):setAnchorPoint(0, 0)
    self.enoughNum = createSimpleLabel({ text = "", size = 20, align = cc.ui.TEXT_ALIGN_CENTER, x = 115, y = 109, outLine = true }):addTo(self.activingNode):setAnchorPoint(0.5, 0)
    self.percentNum = createSimpleLabel({ text = "", size = 20, align = cc.ui.TEXT_ALIGN_CENTER, x = 115, y = 109, outLine = true }):addTo(self.inactiveNode):setAnchorPoint(0.5, 0)

    if params then
        self.status = params.status
        self.id = params.id

        -- 可选参数
        self.needShowLevel = params.level
        self.needShowStar = params.star
    end

    -- 添加点击事件
    addTouchEvent(self, {endCallback = function (touch)
        if self:isVisible() then
            self:onTouch(touch)
        end
    end, moveCallback = function(touch)
            self:onMoved(touch)
    end, moveFix = true})
end

function GeneralsInfoNode:updateMyInfo(id, status)

    if id then
        self.id = id
    end

    if status then
        self.status = status
    end

    if self.id == nil or self.status == nil then
        return
    end

    self.nameLabel:setString(heroConfig:getHeroName(self.id))
    self.heroIcon:setTexture(heroConfig:getHeroHeadIcon(self.id))

    if self.showFloor then
        self.showFloor:setVisible(false)
    end

    if self.status == "inactive" then
        self:updateInactiveInfo()
        self.showFloor = self.inactiveNode
        self.bgSp:setTexture("UI/GeneralSelected/inactivefloor.png")
    elseif self.status == "activing" then
        self:updateActivingInfo()
        self.showFloor = self.activingNode
        self.bgSp:setTexture("UI/GeneralSelected/inactivefloor.png")
    else
        self:updateActivedInfo()
        self.showFloor = self.activedNode
        self.bgSp:setTexture("UI/GeneralSelected/activefloor.png")
    end

    self.showFloor:setVisible(true)
end

function GeneralsInfoNode:updateInactiveInfo()
    local needStoneId, needStoneNum = heroConfig:getHeroConfigByIndex(self.id, "special_stone_id", 1), heroConfig:getHeroConfigByIndex(self.id, "special_stone_amount", 1)
    local number = gameData:getPropNum(needStoneId)
    self.percentNum:setString(number .. " / " .. needStoneNum)
    self.loadingBar:setPercent(number / needStoneNum * 100)
end

function GeneralsInfoNode:updateActivingInfo()
    local needStoneNum = heroConfig:getHeroConfigByIndex(self.id, "special_stone_amount", 1)
    self.enoughNum:setString(needStoneNum .. " / " .. needStoneNum)
end

function GeneralsInfoNode:updateActivedInfo()

    local hero = gameData.heros[self.id]
    local level = self.needShowLevel == nil and hero.level or self.needShowLevel
    local star = self.needShowStar == nil and hero.star or self.needShowStar
    local maxStar = heroConfig:getHeroConfigByIndex(self.id, "max_star")

    star = star > maxStar and maxStar or star
    self.army:setString(getValueInConfig("soldiers", hero.current_army, "name"))
    self.lv:setString("Lv. " .. level)

    self.power:setString(heroConfig:getHeroPower(self.id, level, star))

    for i = 1, 5 do
        if i <= star and i <= heroConfig:getHeroConfigByIndex(self.id, "max_star") then
            self["star" .. i]:setVisible(true)
        else
            self["star" .. i]:setVisible(false)
        end
    end
end

function GeneralsInfoNode:onTouch(touch)

    local cascadeBound
    if self.status == "inactive" then
        cascadeBound = cc.rect(self.getBtn:convertToWorldSpace(cc.p(0, 0)).x, self.getBtn:convertToWorldSpace(cc.p(0, 0)).y, self.getBtn:getContentSize().width, self.getBtn:getContentSize().height)
        if self.touchEnableListenter and self.touchEnableListenter(cascadeBound, touch) then
            self:showBtnClickedEffect(self.getBtn, function ()
                local needStoneId = heroConfig:getHeroConfigByIndex(self.id, "special_stone_id", 1)
                layerLoadControl:pushDialog("DropIndexLayer", needStoneId, { popType = LayerLoadControl.TOUCH_CLOSE_DIALOG, showMask = true, path = general})
            end)
        end

        if self.moveEndListener then
            self.moveEndListener()
        end
    elseif self.status == "activing" then
        cascadeBound = cc.rect(self.activeBtn:convertToWorldSpace(cc.p(0, 0)).x, self.activeBtn:convertToWorldSpace(cc.p(0, 0)).y, self.activeBtn:getContentSize().width, self.activeBtn:getContentSize().height)

        if self.touchEnableListenter and self.touchEnableListenter(cascadeBound, touch) then
            self:showBtnClickedEffect(self.activeBtn, function ()

                -- 银两不足给个提示
                if gameData:getAccValue("coin") < getValueFromDeepTable("heros", self.id, 1, "coin_amount") then
                    layerLoadControl:showNoticeMsg(getStringById(60000130))
                    return
                end
                
                local req = netDataControl:heros_add(self.id)
                netControl:sendData(req, self, self.heroAddCallback)
            end)
        end

        if self.moveEndListener then
            self.moveEndListener()
        end
    else
        if self.clickedListener then
            cascadeBound = cc.rect(self.bgSp:convertToWorldSpace(cc.p(0, 0)).x, self.bgSp:convertToWorldSpace(cc.p(0, 0)).y, self.bgSp:getContentSize().width, self.bgSp:getContentSize().height)
            self.clickedListener(self.id, touch, cascadeBound, self.index)
        end
    end
end

function GeneralsInfoNode:showBtnClickedEffect(btn, callback)
    btn:runAction(transition.sequence({
        cc.ScaleTo:create(0.1, 1.2),
        cc.CallFunc:create(callback),
        cc.ScaleTo:create(0.05, 1.0),
        }))
end

function GeneralsInfoNode:addMoveEndListener(listener)
    self.moveEndListener = listener
end

function GeneralsInfoNode:addTouchEnableListener(listener)
    self.touchEnableListenter = listener
end

function GeneralsInfoNode:statusChange(toStatus)
    self.status = toStatus
    self:updateMyInfo()
end

function GeneralsInfoNode:addClickedListener(listener)
    self.clickedListener = listener
end

function GeneralsInfoNode:addMovedListener(listener)
    self.movedListener = listener
end

function GeneralsInfoNode:addHeroAddListener(listener)
    self.heroAddListener = listener
end

function GeneralsInfoNode:heroAddCallback(event)

    netControl:removeEvent(event.name)
    if self.heroAddListener then
        self.heroAddListener(event, self.id)
    end
end

function GeneralsInfoNode:strategyCallback(event)
    netControl:removeEvent(event.name)
    gameData.unlockStrategys = event.data.strategys
end

function GeneralsInfoNode:onMoved(touch)
    if self.movedListener then
        self.movedListener(touch)
    end
end

return GeneralsInfoNode

