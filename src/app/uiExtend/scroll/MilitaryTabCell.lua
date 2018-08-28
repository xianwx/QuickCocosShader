-- MilitaryTabCell.lua
-- Author: xianwx
-- Date: 2016-07-12 15:29:23
-- 军工滚动条元素

local outLineList = {
    { "txtCondition" },
    { "txtType" },
    { "txtString" },
    { "txtInfo" },
    { "btnLvUp", "txtCost" },
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

local MilitaryTabCell = class("MilitaryTabCell", function ()
    return display.newNode()
end)

function MilitaryTabCell:ctor(id)
    self.id = id
    
    local csb = layerLoadControl:loadCsb(self, "technologmilitarycellLayer")
    csb:setAnchorPoint(0, 0)
    csb:setPosition(0, 0)

    -- 给一些东西设置描边
    for i = 1, #outLineList do
        layerLoadControl:labelEnableOutLine(self, outLineList[i], nil, 2)
    end

    -- 设置按钮点击事件
    layerLoadControl:setButtonEvent(self, "btnLvUp", function ()
        self:lvUpMilitary()
    end)

    self:updateMyInfo()
end

function MilitaryTabCell:updateMyInfo()

    self.lv = gameData.militaryList[self.id]

    -- layerLoadControl:getChildNodeByName(self, "iconMilitary"):setTexture()

    local limitStr
    local name = getValueFromDeepTable("technology", self.id, self.lv, "science_name")
    local desc = getValueFromDeepTable("technology", self.id, self.lv, "science_desc")
    layerLoadControl:getChildNodeByName(self, "txtType"):setString(name)
    layerLoadControl:getChildNodeByName(self, "txtString"):setString(desc)

    if self:checkCost() then
        layerLoadControl:getChildNodeByName(self, "txtInfo"):setVisible(false)
        local cost = getValueFromDeepTable("technology", self.id, self.lv, "lvup_cost")
        setStringAndColor(layerLoadControl:getChildNodeByName(self, { "btnLvUp", "txtCost" }), cost, gameData:getAccValue("coin"))
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), true)

        enabelBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), gameData:getAccValue("coin") > cost)

        local levelLimit = getValueFromDeepTable("technology", self.id, self.lv, "lvup_player_condition")
        limitStr = getStringFormatById(60000145, levelLimit)
    else
        visbleBtn(layerLoadControl:getChildNodeByName(self, "btnLvUp"), false)
        layerLoadControl:getChildNodeByName(self, "txtInfo"):setVisible(true)

        if gameData:getAccValue("level") < getValueFromDeepTable("technology", self.id, self.lv, "lvup_player_condition") then
            limitStr = getStringFormatById(60000145, getValueFromDeepTable("technology", self.id, self.lv, "lvup_player_condition"))
            layerLoadControl:getChildNodeByName(self, "txtInfo"):setString(getStringById(60000147))
        end

        if gameData.buildings.levels[3] < getValueFromDeepTable("technology", self.id, self.lv, "lvup_building_condition") then
            limitStr = getStringFormatById(60000132, getValueFromDeepTable("technology", self.id, self.lv, "lvup_building_condition"))
            layerLoadControl:getChildNodeByName(self, "txtInfo"):setString(getStringById(60000146))
        end
    end

    layerLoadControl:getChildNodeByName(self, "txtCondition"):setString(limitStr)
end

function MilitaryTabCell:checkCost()
    local bLevelLimit = getValueFromDeepTable("technology", self.id, self.lv, "lvup_building_condition")
    local uLevelLimit = getValueFromDeepTable("technology", self.id, self.lv, "lvup_player_condition")

    if gameData.buildings.levels[3] < bLevelLimit then
        return false
    end

    if gameData:getAccValue("level") < uLevelLimit then
        return false
    end

    return true
end


function MilitaryTabCell:lvUpMilitary()
    local req = netDataControl:technology_upgrade(self.id)
    netControl:sendData(req, self, self.lvUpCallback)
end

function MilitaryTabCell:lvUpCallback(event)
    netControl:removeEvent(event.name)
    gameData.militaryList[self.id] = event.data.level
    gameData:updateAccount(event.data.account)
    self:updateMyInfo()
end

return MilitaryTabCell
