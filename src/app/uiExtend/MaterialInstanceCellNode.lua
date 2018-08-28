--
-- Author: zyt
-- Date: 2016-06-13 16:01:32
-- 材料副本项
--
local MaterialInstanceCellNode = class("MaterialInstanceCellNode", function ()
	return display.newNode()
end)

function MaterialInstanceCellNode:ctor(params)
	layerLoadControl:loadCsb(self,"materialdungeonscellLayer")

	self.dungeonsName = params.dungeonsName
    self.todayTime = params.todayTime
    self.openTime = params.openTime
    self.entranceId=params.entranceId

    self.buttons = {}
    table.insert(self.buttons, layerLoadControl:getChildNodeByName(self, {"labelFloor", "btnNormal"}))
    table.insert(self.buttons, layerLoadControl:getChildNodeByName(self, {"labelFloor", "btnHard"}))
    table.insert(self.buttons, layerLoadControl:getChildNodeByName(self, {"labelFloor", "btnInfernal"}))

	layerLoadControl:setButtonEvent(self, {"labelFloor", "btnNormal"}, function()
		local normalBattleId=self:findTypeOfBattle(1)
		local info = {
			visiableDropId = getValueInConfig("material_battle", normalBattleId, "visable_drop"),
			todayTime = self.todayTime,
			instanceName = getValueInConfig("material_battle", normalBattleId, "instance_name"),
			instanceDesc = getValueInConfig("material_battle", normalBattleId, "instance_desc"),
			materialMap = getValueInConfig("material_battle", normalBattleId, "instance_map"),
			materialId=normalBattleId
		}
		self:enterNormal(info)
	end)

	layerLoadControl:setButtonEvent(self, {"labelFloor", "btnHard"}, function()
		print("hard instance")
		local hardBattleId=self:findTypeOfBattle(2)
		local info = {
			visiableDropId = getValueInConfig("material_battle", hardBattleId, "visable_drop"),
			todayTime = self.todayTime,
			instanceName = getValueInConfig("material_battle", hardBattleId, "instance_name"),
			instanceDesc = getValueInConfig("material_battle", hardBattleId, "instance_desc"),
			materialMap = getValueInConfig("material_battle", hardBattleId, "instance_map"),
			materialId=hardBattleId
		}
		self:enterHard(info)
	end)

	layerLoadControl:setButtonEvent(self, {"labelFloor", "btnInfernal"}, function()
		print("fernal instance")
		local fernalBattleId=self:findTypeOfBattle(3)
		local info = {
			visiableDropId = getValueInConfig("material_battle", fernalBattleId, "visable_drop"),
			todayTime = self.todayTime,
			instanceName = getValueInConfig("material_battle", fernalBattleId, "instance_name"),
			instanceDesc = getValueInConfig("material_battle", fernalBattleId, "instance_desc"),
			materialMap = getValueInConfig("material_battle", fernalBattleId, "instance_map"),
			materialId=fernalBattleId
		}
		self:enterFernal(info)
	end)

	self:setButtonStatus()

	self.txtName = layerLoadControl:getChildNodeByName(self, "txtName")
	self.remainTimes = layerLoadControl:getChildNodeByName(self, "txtNumber")
	self.txtOpenTime = layerLoadControl:getChildNodeByName(self, "txtTime")

	layerLoadControl:labelEnableOutLine(self,"txtName")
	layerLoadControl:labelEnableOutLine(self, "txtTime")
	-- layerLoadControl:labelEnableOutLine(self,"txtNumber")
	-- layerLoadControl:labelEnableOutLine(self,"txtSprite")
	-- setCCSpriteGray(layerLoadControl:getChildNodeByName(self, "labelPic"))

	self:setMaterialInstanceInfo()
	self:setOpenStatus()

	gameData:addRefreshEvent("materialFightTimes", "materialInstanceCellNode", handler(self, self.setMaterialInstanceInfo))
end

function MaterialInstanceCellNode:setOpenStatus()
	local weekday = os.date("%w")
	if not self:shouldOpen(weekday) then
		setCCSpriteGray(layerLoadControl:getChildNodeByName(self, "labelPic"))
	    setCCSpriteGray(layerLoadControl:getChildNodeByName(self, "labelFloor"):getVirtualRenderer():getSprite()) 
		for _, button in pairs(self.buttons) do
			self:disableButton(button)
		end
	end
end

function MaterialInstanceCellNode:shouldOpen(weekday)
	for _, day in pairs(self.openTime) do
		if tonumber(weekday) == 0 then
			weekday =  7
		end
		if day == tonumber(weekday) then
			return true
		end
	end
	return false
end

function MaterialInstanceCellNode:setMaterialInstanceInfo()
	local fight_times = gameData.allFightTimes[self.entranceId]
	local remainTimes = self.todayTime-fight_times
	local totalTimes = self.todayTime
	self.remainTimes:setString(remainTimes.."/"..totalTimes)
	self.txtName:setString(self.dungeonsName)
	self.txtOpenTime:setString("周"..self:convertOpenTime(self.openTime).."开放")
end

function MaterialInstanceCellNode:findTypeOfBattle(difficult)
	local materialConfig = getConfigByName("material_battle")
	for battleId in pairs(materialConfig) do
		local currentEntrance=getValueInConfig("material_battle", battleId, "entrance_id")
		local diff = getValueInConfig("material_battle", battleId, "instance_difficulty")
		if self.entranceId==currentEntrance and diff==difficult then
			return battleId
		end
	end
end

function MaterialInstanceCellNode:setButtonStatus()
	local battleId, lvLimit
	for index = 1, self:getEntranceItems() do
		battleId = self:findTypeOfBattle(index)
		lvLimit = getValueInConfig("material_battle",battleId, "lv_limit")
		if gameData:getAccValue("level") < lvLimit then
			self:disableButton(self.buttons[index])
		end
	end
end

function MaterialInstanceCellNode:disableButton(button) 
	button:setEnabled(false)
	button:setBright(false)
end

function MaterialInstanceCellNode:getEntranceItems()
	local itemCount = 0
	local materialConfig = getConfigByName("material_battle")
	for battleId in pairs(materialConfig) do
		local currentEntrance=getValueInConfig("material_battle", battleId, "entrance_id")
		if self.entranceId==currentEntrance then
			itemCount = itemCount + 1 
		end
	end
	return itemCount
end

function MaterialInstanceCellNode:convertOpenTime(str)
    local showStr=str
    local startId = 60000090
  	local result = ""

    for index = 1, #showStr do
    	if index ~= #showStr then
    		result = result .. getStringById(startId + tonumber(showStr[index])) ..","
    	else
    		result = result..getStringById(startId + tonumber(showStr[index]))
    	end
    end
    return result
end

function MaterialInstanceCellNode:getCellSize()
	local sizeItem = layerLoadControl:getChildNodeByName(self, "labelFloor")
	local size = sizeItem:getContentSize()
	return size
end

function MaterialInstanceCellNode:enterNormal(params)
	layerLoadControl:addLayer("materialinstance.MaterialInstanceInfomationLayer", params)
end

function MaterialInstanceCellNode:enterHard(params)
	layerLoadControl:addLayer("materialinstance.MaterialInstanceInfomationLayer", params)
end

function MaterialInstanceCellNode:enterFernal(params)
	layerLoadControl:addLayer("materialinstance.MaterialInstanceInfomationLayer", params)
end

return MaterialInstanceCellNode