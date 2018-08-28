-- StrategyTabCell.lua
-- Author: xianwx
-- Date: 2016-07-12 14:14:38
-- 计策滚动条元素

local outLineList = {
    { "txtSkillName" },
    { "btnLvUp", "txtSprite" },
    { "btnLvUp", "txtLv" },
    { "btnLvUp", "txtSilverCost" },
    { "btnLvUp", "txtSkillBook" },
    { "btnUnlock", "txtSprite" },
}

local function visbleBtn(btn, visible)
    btn:setEnabled(visible)
    btn:setVisible(visible)
end

local function enabelBtn(btn, enable)
    btn:setEnabled(enable)
    btn:setBright(enable)
end

local function setStringAndColor(label, showNum, compNum)
    label:setString(showNum)

    if showNum > compNum then
        label:setColor(cc.c3b(255, 0, 0))
    else
        label:setColor(cc.c3b(255, 255, 255))
    end
end

local StrategyTabCell = class("StrategyTabCell", function ()
    return display.newNode()
end)

function StrategyTabCell:ctor(id)

    self.id = id
    local csb = layerLoadControl:loadCsb(self, "technologytrickcellLayer")
    csb:setAnchorPoint(0, 0)
    csb:setPosition(0, 0)
    self.csb = csb

    -- 给一些东西设置描边
    for i = 1, #outLineList do
        layerLoadControl:labelEnableOutLine(self, outLineList[i])
    end

    -- 设置按钮点击事件
    layerLoadControl:setButtonEvent(self, "btnLvUp", function ()
        self:lvUpStrategy()
    end)

    layerLoadControl:setButtonEvent(self, "btnUnlock", function ()
        self:unlockStrategy()
    end)

    self:updateMyInfo()    

    if gameData.guideStep == 11 then
        self:_newPlayerGuide()
    end

end

function StrategyTabCell:updateMyInfo()
    
    local strategy = getValueByNameAndIndex("strategy", self.id)
    layerLoadControl:getChildNodeByName(self, "txtSkillName"):setString(getValueInConfig("strategy", self.id, "strategy_name"))
    layerLoadControl:getChildNodeByName(self, "iconSkill"):setTexture(strategy.strategy_icon)
    
    if gameData.unlockStrategys[self.id] then
        -- 显示该显示的区域
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), true)
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnUnlock"), false)

        local level = gameData.unlockStrategys[self.id].level
        layerLoadControl:getChildNodeByName(self, {"btnLvUp", "txtLv"}):setString(level)
        setStringAndColor(layerLoadControl:getChildNodeByName(self, {"btnLvUp", "txtSkillBook"}), strategy.book_cost_list[level], gameData:getPropNum(getConstant("STRATEGY_LVUP_ITEM")))
        setStringAndColor(layerLoadControl:getChildNodeByName(self, {"btnLvUp", "txtSilverCost"}), strategy.silver_cost_list[level], gameData:getAccValue("coin"))

        if not self:checkCost() then
            enabelBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), false)
        end
    else
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), false)
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnUnlock"), true)

        local unlockList = strategy.unlock_condition_list
        local posList = self:getPosList(#unlockList)
        local panel = layerLoadControl:getChildNodeByName(self, {"btnUnlock", "panelPos"})
        for index, id in ipairs(unlockList) do
            local sp = display.newSprite(heroConfig:getHeroHeadIcon(id), posList[index], 0):addTo(panel)
            sp:setScale(50 / sp:getContentSize().width)
            sp:setAnchorPoint(0, 0)
            if not heroConfig:checkHeroOwn(id) then
                setCCSpriteGray(sp)
                enabelBtn(layerLoadControl:getChildNodeByName(self, "btnUnlock"), false)
            end
        end
    end
end

function StrategyTabCell:getPosList(count)
    if count == 1 then
        return { 0 }
    elseif count == 2 then
        return { -40, 40 }
    else
        return { -60, 0, 60 }
    end
end

function StrategyTabCell:checkCost()
    local num = gameData:getPropNum(getConstant("STRATEGY_LVUP_ITEM"))
    local strategy = getValueByNameAndIndex("strategy", self.id)
    local level = gameData.unlockStrategys[self.id].level

    if num < strategy.book_cost_list[level] then
        return false
    end

    if gameData:getAccValue("coin") < strategy.silver_cost_list[level] then
        return false
    end

    if level >= gameData.buildings.levels[3] then
        return false
    end

    return true
end

function StrategyTabCell:lvUpStrategy()
    if not self:checkCost() then
        return
    end

    local req = netDataControl:heros_strategy_upgrade(self.id)
    netControl:sendData(req, self, self.lvUpStrategyCallback)
end

function StrategyTabCell:lvUpStrategyCallback(event)
    netControl:removeEvent(event.name)
    self:updateStrategyCallback(event)
    gameData:updateAccount(event.data.account)
    gameData:updateBackpack({ props = event.data.prop })
end

function StrategyTabCell:unlockStrategy()
    local req = netDataControl:heros_strategy_active(self.id)
    netControl:sendData(req, self, self.updateStrategyCallback)
end

function StrategyTabCell:updateStrategyCallback(event)
    netControl:removeEvent(event.name)
    local strategy = event.data.strategy
    gameData.unlockStrategys[strategy.id] = strategy
    gameData:updateData("strategy")
    self:updateMyInfo()
end

-- 设置引导步数

function StrategyTabCell:_newPlayerGuide()
    if self:_canActive() then
        local _guideMask = display.newColorLayer(cc.c4b(0, 0, 0, 0))
        _guideMask:addTo(self.cocosLayer)
        local clickButton = layerLoadControl:getChildNodeByName(self, "btnUnlock")
        addTouchEvent(_guideMask, {endCallback =function (touch)
            local location = touch:getLocation()
            local s = clickButton:getContentSize()
            local deltaY = (display.height-720)/2
            if cc.rectContainsPoint(cc.rect(140, 285+deltaY, s.width, s.height), location) then
                self:unlockStrategy()
                self:_setGuideStep(gameData.guideStep)
                gameData.guideStep = gameData.guideStep + 1
                self:_removeGuideMask()
            else
                layerLoadControl:showNoticeMsg("请点击按钮激活计策", 0.4, 0.4)
            end
        end})
        gameData.guideMask[#gameData.guideMask + 1] = _guideMask
    else
        local width = self.csb:getContentSize().width
        local height = self.csb:getContentSize().height
        local _uActiveGuideMask = display.newColorLayer(cc.c4b(0, 0, 0, 0))
        _uActiveGuideMask:addTo(self.cocosLayer)
        _uActiveGuideMask:setContentSize(width+40, height+40)
        addTouchEvent(_uActiveGuideMask, {endCallback =function ()
            layerLoadControl:showNoticeMsg("请点击按钮激活计策@@", 0.4, 0.4)
        end})
        gameData.guideMask[#gameData.guideMask + 1] = _uActiveGuideMask
    end
end

function StrategyTabCell:_removeGuideMask()
    for _, mask in ipairs(gameData.guideMask) do
        mask:removeSelf()
    end
    gameData.guideMask = {}
end

function StrategyTabCell:_canActive()    
    local strategy = getValueByNameAndIndex("strategy", self.id)
    local unlockList = strategy.unlock_condition_list
    for _, id in ipairs(unlockList) do
        if not heroConfig:checkHeroOwn(id) then
            return false
        end
    end

    return true
end

function StrategyTabCell:_setGuideStep(step)
    local req = netDataControl:user_set_guide(step)
    netControl:sendData(req, self, self._guideCallback)
end

function StrategyTabCell:_guideCallback(event)
    gameData:updateAccount(event.data.account)
end

return StrategyTabCell
