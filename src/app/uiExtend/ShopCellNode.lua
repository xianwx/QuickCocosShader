-- ShopCellNode.lua
-- Author: xianwx
-- Date: 2016-05-16 16:58:50
-- 商店元素

local ShopCellNode = class("ShopCellNode", function ()
    return display.newNode()
end)

-- @params info.id              物品在shop表里的id
-- @params info.buy_count       物品购买次数，取值0或1
function ShopCellNode:ctor(index, info, shopType)
    layerLoadControl:loadCsb(self, "shopcellLayer")
    self:setContentSize(480, 120)

    -- 获取各个控件
    -- 按钮
    self.btn = layerLoadControl:setButtonEvent(self, "btnBuy", function ()
        -- print("btnBuy")
        self:tryBuyItem()
    end)

    -- 购买次数大于0，置灰
    if info.buy_count > 0 then
        self.btn:setBright(false)
    end

    -- 整个背景
    self.labelCellFloor = layerLoadControl:getChildNodeByName(self, "labelCellFloor")

    -- 图片
    self.iconItem = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconItem"})
    self.iconBetter = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconBetter"})
    self.iconGold = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconGold"}):setTag(1000)
    self.iconSilver = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconSilver"}):setTag(1001)
    self.iconJJC = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconJJC"}):setTag(1002)
    self.iconJunxu = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "iconJunxu"}):setTag(1003)

    -- 文字
    self.txtItemName = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "txtItemName"})
    self.txtCost = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "txtCost"})
    self.txtInfoItem = layerLoadControl:getChildNodeByName(self, {"labelCellFloor", "txtInfoItem"})

    -- 数据
    self.index = index
    self.id = info.id
    self.butTimes = info.buy_count
    self.shopType = shopType
    self.itemId = getValueFromDeepTable("shop", shopType, self.id, "sell_id")
    self.itemType = getValueFromDeepTable("shop", shopType, self.id, "item_type")

    -- 添加点击监听
    addTouchEvent(self.labelCellFloor, {beginCallback = function (touch)

        if self.detailLayer then
            return
        end

        self.detailLayer = require("app.layer.shop.ShopCellDetailLayer").new():addTo(self.displayLayer, 99)

        if self.itemType == getConstant("TYPE_PROP") then
            -- 道具
            self.detailLayer:updateMyInfo(getValueInConfig("prop", self.itemId, "name"), "", getValueInConfig("prop", self.itemId, "desc"))
        elseif self.itemType == getConstant("TYPE_EQUIP") then
            -- 装备
            local limitStr = getStringFormatById(60000026, getValueInConfig("equipment", self.itemId, "require_lv"))
            self.detailLayer:updateMyInfo(getValueInConfig("equipment", self.itemId, "name"), limitStr, getValueInConfig("equipment", self.itemId, "desc"), self.equipInfo[getValueInConfig("equipment", self.itemId, "match_desc")])
        end

        -- 计算一下显示的位置
        local posX
        local posY = touch:getLocation().y - 110 - ((display.height - 720) / 2)

        -- 如果超出显示范围
        if self:getPositionX() == 155 then
            posX = touch:getLocation().x + 150
        else
            posX = touch:getLocation().x - 390
        end

        if posY < 0 then
            posY = 0
        end

        self.detailLayer:setPosition(posX, posY)

    end, endCallback = function ()
        self.detailLayer:cleanUpSelf()
        self.detailLayer = nil
    end})

    -- self:updateMyInfo()
end

function ShopCellNode:updateMyInfo(info)
    if info then
        self.id = info.id
        self.butTimes = info.buy_count
        self.itemId = getValueFromDeepTable("shop", self.shopType, self.id, "sell_id")
        self.itemType = getValueFromDeepTable("shop", self.shopType, self.id, "item_type")
    end

    local shopConf = getValueInConfig("shop", self.shopType, self.id)
    local itemConf

    if self.itemType == getConstant("TYPE_PROP") then
        -- 道具
        itemConf = getValueByNameAndIndex("prop", shopConf.sell_id)
        self.iconItem:setTexture(itemConf.icon)
        self.txtItemName:setString(itemConf.name)
        self.iconItem:setScale(1)
        self.txtInfoItem:setString(itemConf.desc)
    elseif self.itemType == getConstant("TYPE_EQUIP") then
        -- 装备
        itemConf = getValueByNameAndIndex("equipment", shopConf.sell_id)
        self.iconItem:setTexture(itemConf.icon)
        self.txtItemName:setString(itemConf.name)
        self.iconItem:setScale(86 / self.iconItem:getContentSize().width)
    end

    if not self.numLabel then
        self.numLabel = createSimpleLabel({ text = "", size = 30, align = cc.ui.TEXT_ALIGN_CENTER, x = 25, y = 35, dimensions = cc.size(80, 30), outLine = true }):addTo(self.labelCellFloor)
    end

    if getValueFromDeepTable("shop", self.shopType, self.id, "amount") > 2 then
        self.numLabel:setString("x" .. getValueFromDeepTable("shop", self.shopType, self.id, "amount"))
    else
        self.numLabel:setString("")
    end

    if self.butTimes > 0 then
        self.btn:setBright(false)
    else
        self.btn:setBright(true)
    end

    self.txtCost:setString(shopConf.money_amount)

    local _, moneyType = self:getIconNameByMoneyType(shopConf.money_type)
    if gameData:getAccValue(moneyType) < shopConf.money_amount then
        self.txtCost:setColor(cc.c3b(255, 0, 0))
    else
        self.txtCost:setColor(cc.c3b(255, 255, 255))
    end

    self:autoShowHideMoneyIcon(self:getIconNameByMoneyType(shopConf.money_type))
end

-- 直接显示的内容
function ShopCellNode:showDesc(conf)
    local equipConf = getValueByNameAndIndex("equipment", conf.config_id)
    local str
    
    if equipConf.equip_type == 6 then
        local treasureDesc = getValueFromDeepTable("treasure_random_attr", equipConf.require_lv, conf.treasure_attr_id, "description")
        str = getStringByStrFormat(treasureDesc, conf.treasure_value)
    else
        str = getStringByStrFormat(equipConf.desc, conf[equipConf.match_desc])
    end

    self.txtInfoItem:setString(str)
end

-- 设置显示详细信息界面的层
function ShopCellNode:setShowDetailLayer(layer)
    self.displayLayer = layer
end

-- 设置装备信息
function ShopCellNode:setEquipInfo(info)
    self.equipInfo = info
    self:showDesc(self.equipInfo)
    self:checkBetter()
end

-- 计算战力是否有使某个武将变强
function ShopCellNode:checkBetter()

    if self.butTimes <= 0 and self.itemType == getConstant("TYPE_EQUIP") then
        local result, list = heroConfig:checkEquipStrongAll(self.equipInfo)
        if result then
            self.iconBetter:setVisible(true)
            -- 缓存一下要自动穿上的武将
            self.wearHeroId = list[1].id
        else
            self.iconBetter:setVisible(false)
            self.wearHeroId = nil
        end
    else
        self.iconBetter:setVisible(false)
        self.wearHeroId = nil
    end
end

-- 获取相应的钱币图标
function ShopCellNode:getIconNameByMoneyType(moneyType)
    if moneyType == 3 then
        return "iconSilver", "coin"
    elseif moneyType == 4 then
        return "iconGold", "ingot"
    elseif moneyType == 6 then
        return "iconJJC", "arena_coin"
    elseif moneyType == 7 then
        return "iconJunxu"
    end
end

-- 自动显示钱币图标
function ShopCellNode:autoShowHideMoneyIcon(curType)

    local item
    for i = 1000, 1003 do
        item = self.labelCellFloor:getChildByTag(i)
        if item:getName() ~= curType then
            item:setVisible(false)
        else
            item:setVisible(true)
        end
    end
end

-- 尝试购买
function ShopCellNode:tryBuyItem()

    -- 已经购买过，不能买了
    if self.butTimes > 0 then
        -- layerLoadControl:showNoticeMsg("无法购买，次数不足！")
        return
    end

    local _, moneyType = self:getIconNameByMoneyType(getValueFromDeepTable("shop", self.shopType, self.id, "money_type"))
    if moneyType then

        if gameData:getAccValue(moneyType) < getValueFromDeepTable("shop", self.shopType, self.id, "money_amount") then
            layerLoadControl:showNoticeMsg(getStringById(60000098))
            return
        end
    else
        layerLoadControl:showNoticeMsg(getStringById(60000098))
        return
    end

    local req = netDataControl:shop_buy(self.shopType, self.index)
    netControl:sendData(req, self, self.buyItemSucCallback)
end

-- 购买成功回调
function ShopCellNode:buyItemSucCallback(event)
    
    netControl:removeEvent(event.name)
    
    self.btn:setBright(false)
    -- self.btn:setEnabled(false)

    self.butTimes = event.data.shop_item.buy_count
    gameData:updateAccount(event.data.account)

    gameData:updateBackpack({ props = event.data.prop, equips = event.data.equipment })

    -- 给个提示
    local str
    if self.itemType == getConstant("TYPE_PROP") then
        str = getStringFormatById(60000099, getValueInConfig("prop", self.itemId, "name"), getValueFromDeepTable("shop", self.shopType, self.id, "amount"))
    else
        str = getStringFormatById(60000100, getValueInConfig("equipment", self.itemId, "name"), getValueFromDeepTable("shop", self.shopType, self.id, "amount"))
        if self.wearHeroId then
            -- 自动穿装备
            local req = netDataControl:heros_set_equips(self.wearHeroId, getValueInConfig("equipment", self.itemId, "equip_type"), event.data.equipment.id)
            netControl:sendData(req, self, self.equipmentOneCallback)
        end
    end

    layerLoadControl:showNoticeMsg(str)
end

function ShopCellNode:equipmentOneCallback(event)
    netControl:removeEvent(event.name)

    gameData:updateHeros(event.data.heros)
    gameData:updateBackpack({ equips = event.data.equipments })
    local str = ""
    for heroId, _ in pairs(event.data.heros) do
        str = getStringFormatById(60000101, heroConfig:getHeroName(heroId), getValueInConfig("equipment", self.itemId, "name"))
    end

    layerLoadControl:showNoticeMsg(str, nil, nil, 0.6)
    self:noticeReCheck()
end

function ShopCellNode:addReCheckListener(listener)
    self.reCheckListener = listener
end

function ShopCellNode:noticeReCheck()
    if self.reCheckListener then
        self.reCheckListener()
    end
end

function ShopCellNode:cleanInfo()
    if self.richLabel then
        self.richLabel:cleanupSelf()
        self.richLabel = nil
    end

    self.equipInfo = nil
    self.wearHeroId = nil
    self.iconBetter:setVisible(false)
end

return ShopCellNode
