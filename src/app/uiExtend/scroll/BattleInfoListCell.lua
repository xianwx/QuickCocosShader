-- BattleInfoListCell.lua
-- Author: xianwx
-- Date: 2016-06-14 17:05:07
-- 战报元素
local BattleConfig = require("app.battle.config.BattleConfig")
local BattleInfoListCell = class("BattleInfoListCell", function ()
    return display.newNode()
end)

function BattleInfoListCell:ctor(info)
    layerLoadControl:loadCsb(self, "pvpbattleinfocellLayer")

    self.txtRankNum = layerLoadControl:getChildNodeByName(self, "txtRankNum")
    self.txtLv = layerLoadControl:getChildNodeByName(self, "txtLv")
    self.txtName = layerLoadControl:getChildNodeByName(self, "txtName")
    self.iconWin = layerLoadControl:getChildNodeByName(self, "iconWin")
    self.iconFail = layerLoadControl:getChildNodeByName(self, "iconFail")

    -- 设置按钮点击
    layerLoadControl:setButtonEvent(self, "btnReview", function (button)
        local pos = button:getTouchEndPosition()
        if self.touchEnableListenter and self.touchEnableListenter(pos) then
            self:enterBattle()
        end
    end)

    addTouchEvent(self, {moveCallback = function(touch)
        self:onMoved(touch)
    end, moveFix = true})

    self:updateMyInfo(info)
end

function BattleInfoListCell:updateMyInfo(info)

    self.iconWin:setVisible(info.fight_result == 1)
    self.iconFail:setVisible(info.fight_result == 0)
    self.txtRankNum:setString(info.opponent_rank)
    self.txtLv:setString(info.opponent_account.level)
    self.txtName:setString(info.opponent_account.nickname)

    -- 如果这个数据有进攻阵型，那就是在左边
    if info.user.attack_formation then
        self.myBattleInfo = info.user
        self.enemyBattleInfo = info.opponent
        self.stragegy = info.user.attack_strategy
    else
        self.myBattleInfo = info.opponent
        self.enemyBattleInfo = info.user
        self.stragegy = info.user.defend_strategy
    end
    
    self.opponentAccount = info.opponent_account
    self.timestamp = info.timestamp
end

function BattleInfoListCell:enterBattle()

    local PackBattleDataHelper = require("app.battle.helper.PackBattleDataHelper")
    PackBattleDataHelper:setConfigFunc()
    local myHeros = self:changeArrToMap(self.myBattleInfo.heros)
    local enemyHeros = self:changeArrToMap(self.enemyBattleInfo.heros)
    local legionList = PackBattleDataHelper:createHeroData(self.myBattleInfo.attack_formation, myHeros, self.myBattleInfo.armys,gameData.Bag:getEquipList(false))
    local monsterInfoList
    if self.opponentAccount.id < 0 then
        monsterInfoList = PackBattleDataHelper:createMonsterData(self.enemyBattleInfo.defend_formation)
    else
        monsterInfoList = PackBattleDataHelper:createHeroData(self.enemyBattleInfo.defend_formation, enemyHeros, self.enemyBattleInfo.armys,gameData.Bag:getEquipList(false))
    end

    local stragegyList = PackBattleDataHelper:createStragegyData(self.stragegy)
    local mapConfig = BattleConfig.getMapConfigByName(getConstant("ARENA_MAP_ID"))
    local battleType = 3
    local allyBuildInfoList = {}
    local enemyBuildInfoList = {}
    PackBattleDataHelper:enterBattle(legionList, monsterInfoList, stragegyList, mapConfig, battleType, nil, allyBuildInfoList, enemyBuildInfoList)
end

function BattleInfoListCell:changeArrToMap(herosArr)
    local map = {}
    for i = 1, #herosArr do
        local id = herosArr[i].id
        map[id] = herosArr[i]
    end
    return map
end

function BattleInfoListCell:addTouchEnableListener(listener)
    self.touchEnableListenter = listener
end

function BattleInfoListCell:addMovedListener(listener)
    self.movedListener = listener
end

function BattleInfoListCell:onMoved(touch)
    if self.movedListener then
        self.movedListener(touch)
    end
end

return BattleInfoListCell
