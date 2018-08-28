-- StrategyTabScroll.lua
-- Author: xianwx
-- Date: 2016-07-12 14:18:19
-- 计策滚动条

local BarAlwaysShowScroll = import(".BarAlwaysShowScroll")
local StrategyTabScroll = class("StrategyTabScroll", BarAlwaysShowScroll)
local TableExt = require("app.helper.table.TableExt")

function StrategyTabScroll:initSelf()
    self.curPoint = 1
    self.itemHDis = 275
    self.itemVDis = 338
    self.lineNumLimit = 4

    local strategyList = getConfigByName("strategy")
    self.allStrategy = {}
    for id, _ in pairs(strategyList) do
        table.insert(self.allStrategy, { active = self:checkActive(id), lvUp = self:checkLvUp(id), own = self:checkOwn(id), id = id })
    end

    local greater = function (lhs, rhs)
        lhs = lhs or 0
        rhs = rhs or 0
        return lhs > rhs
    end

    table.sort( self.allStrategy, TableExt.multi_compare({ "active", "lvUp", "own", "id" }, greater, {
            id = function (lhs, rhs)
                return lhs < rhs
            end
        }) )

    self.itemNum = #self.allStrategy
end

function StrategyTabScroll:setLimit(params)
    self.scrollNode:setContentSize(params.rect.width, self.itemVDis * math.ceil(self.itemNum / self.lineNumLimit))
    self.scrollNode:setPosition(params.rect.x, (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height)
    self.upLimit = (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height
    self.downLimit = params.rect.y
end

function StrategyTabScroll:onEnter()
    self:frameAdd()
end

function StrategyTabScroll:frameAdd()

    if self.count < self.itemNum then
        self:performWithDelay(function ()
            self:addItemToScroll()
            self:frameAdd()
        end, 0.01)
    end
end

function StrategyTabScroll:addItemToScroll()

    for i = self.curPoint, self.curPoint + 2 do
        if self.itemNum < i then
            break
        end

        self:newItem(self.allStrategy[i].id)
        
        self.curPoint = self.curPoint + 1
    end
end

function StrategyTabScroll:newItem(id)

    local item = require("app.uiExtend.scroll.StrategyTabCell").new(id):addTo(self.scrollNode)
    item:setPosition(self.disX, self.disY)
    self.count = self.count + 1
    item:setTag(self.count)
    self:countLinePostion()
    return item
end

-- todo 检查耗费
function StrategyTabScroll:checkCost(id)

    if self:checkOwn(id) == -1 then
        return false
    end

    local num = gameData:getPropNum(getConstant("STRATEGY_LVUP_ITEM"))
    local strategy = getValueByNameAndIndex("strategy", id)
    local level = gameData.unlockStrategys[id].level

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

-- todo 检查计策能否能升级
function StrategyTabScroll:checkLvUp(id)
    if not self:checkCost(id) then
        return -1
    end

    return 1
end

-- todo 检查计策是否能激活
function StrategyTabScroll:checkActive(id)
    if gameData.unlockStrategys[id] then
        return -1
    end

    local strategy = getValueByNameAndIndex("strategy", id)
    local unlockList = strategy.unlock_condition_list

    for _, heroId in ipairs(unlockList) do
        if not heroConfig:checkHeroOwn(heroId) then
            return -1
        end
    end

    return 1
end

-- todo 检查计策是否已拥有
function StrategyTabScroll:checkOwn(id)
    if gameData.unlockStrategys[id] then
        return 1
    end

    return -1
end

return StrategyTabScroll
