-- RichLabel.lua
-- Author: xianwx
-- Date: 2016-03-25 16:29:20
-- 创建个富文本

local chineseSize = 3
local RichLabel = class("RichLabel", function ()
    return display.newNode()
end)

-- 根据内容裁减，部分内容颜色不一样，部分内容响应点击
--[[
    params.str          格式为：xxx[color=FF00FF]xxx[/color]xxxx
    params.width        根据宽度自动排版，如果不传的话就是不换行
    params.size         字体大小，默认20
    params.spacing      字体间距
]]
function RichLabel:ctor(params)
    -- 用来显示的label列表
    params.size = params.size or 20
    params.spacing = params.spacing or 1
    self.outLine = params.outLine == nil and true or params.outLine -- 默认描边
    if self.outLine then
        self.outlineSize = params.outlineSize or 1
        self.outLineColor = params.outLineColor or cc.c4b(0, 0, 0, 255)
    end
    self.fontHans = nil
    self.fontEn = nil
    self.spacing = params.spacing
    self:createLabels(params.str, params.width, params.size)
end

-- 判断labelName的值是为了方便以后扩展其它样式和功能
function RichLabel:createLabels(str, width, size)

    -- 记录需要渲染成怎么样的字符串的数组
    local arr = {}              -- 实际要渲染的数组
    local tempStr = str    

    while string.find(tempStr, "%[") do
        local tab = {}

        -- 第一个"["号之前的字符串
        local firstStr = string.sub(tempStr, 1, string.find(tempStr, "%[") - 1)
        if firstStr ~= "" then
            table.insert(arr, {type = "default", text = firstStr, textSize = size})
        end

        -- 取出[]号里的内容
        local tmpLabelName = string.sub(tempStr, string.find(tempStr, "%[") + 1, string.find(tempStr, "%]") - 1)
        local labelName                 -- 标签类别
        local labelInfo = nil           -- 标签内容

        -- 如果有"=",比如颜色的值之类的
        if string.find(tmpLabelName, "=") then
            labelName = string.sub(tmpLabelName, 1, string.find(tmpLabelName, "=") - 1)
            labelInfo = string.sub(tmpLabelName, string.find(tmpLabelName, "=") + 1, #tmpLabelName)
        else
            labelName = tmpLabelName
        end

        local startIndex, endIndex = string.find(tempStr, "%[%/" .. labelName .. "%]")

        if startIndex ~= nil and endIndex ~= nil then
            -- 标签里的实际需要显示的内容
            local content = string.sub(tempStr, string.find(tempStr, "%]") + 1, startIndex - 1)
            tab.text = content              -- 记录实际显示内容
        else
            tab.text = ""
        end
        
        tab.type = labelName            -- 记录标签的类型
        tab.labelInfo = labelInfo       -- 记录标签的值
        tab.textSize = size

        table.insert(arr, tab)

        if not endIndex then
            local _, tempEnd = string.find(tempStr, "%[%" .. labelName .. "%]")
            endIndex = tempEnd
        end

        tempStr = string.sub(tempStr, endIndex + 1, #tempStr)
    end

    -- 裁减剩下的
    if tempStr ~= "" then
        table.insert(arr, {type = "default", text = tempStr, textSize = size})
    end

    -- 开始创建以及渲染
    local disX = 0
    local label
    local row = 0
    local disY = 0
    local enterCount = 0
    if width ~= nil then
        local _, tempArr = self:automaticNewLine(arr, width, size)
        arr = tempArr
    end

    while #arr > 0 do
        label = self:createLabelByType(arr[1])
        label:setAnchorPoint(cc.p(0, 0))
        self:addChild(label)

        if not width then
            if arr[1].type == "enter" then
                enterCount = enterCount + 1
                disX = 0
            end
            label:setPosition(disX, 0 - enterCount * size)
            disX = disX + label:getContentSize().width
        else
            if row == arr[1].row then
                label:setPosition(disX, disY)
            else
                if arr[1].row == 1 then
                    disY = 0
                else
                    disY = -((arr[1].row - 1) * size) - self.spacing
                end

                label:setPosition(0, disY)
                disX = 0
                row = arr[1].row
            end

            disX = disX + label:getContentSize().width
        end

        table.remove(arr, 1)
    end
    
end

function RichLabel:createLabelByType(tab)

    if tab.type == "color" then
        return self:createColorLabel(tab)
    elseif tab.type == "default" then
        return createSimpleLabel({ text = tab.text, size = tab.textSize, outLine = self.outLine, outlineSize = self.outlineSize, outLineColor = self.outLineColor })
    elseif tab.type == "enter" then
        return createSimpleLabel({ text = tab.text, size = 1 })
    end
end

-- t is tab
function RichLabel:accountTextLen(str, tSize)

    -- 获取一个格式化后的浮点数
    local function strFormatToNumber(number, num)
        local s = "%." .. num .. "f"
        return tonumber(string.format(s, number))
    end

    local list = self:comminuteText(str)
    local len = 0

    for _, v in pairs(list) do
        local tmpLen
        local tmpFontWidth
        local tmpShift = self:calShiftByOne(v)

        if tmpShift == 3 then
            if self.fontHans == nil then
                local label = createSimpleLabel({ text = v, size = tSize })
                self.fontHans = label:getContentSize().width
            end
            tmpFontWidth = self.fontHans - chineseSize + 1
        elseif tmpShift == 1 then
            if self.fontEn == nil then
                local label = createSimpleLabel({ text = v, size = tSize })
                self.fontEn = label:getContentSize().width
            end

            tmpFontWidth = self.fontEn - chineseSize
        else
            tmpFontWidth = self.fontHans
        end
        tmpLen = tSize / tmpFontWidth
        local float = strFormatToNumber(chineseSize / tmpLen, 4)
        len = len + float
    end

    self.fontEn = nil
    return len
end

-- 计算单个字符的shift值，以此判断中英文等字符
function RichLabel:calShiftByOne(str)
    local i = 1
    local byte = string.byte(str, i)
    local shift = 1
    if byte > 0 and byte <= 127 then
        -- 单个字符
        shift = 1
    elseif byte >= 192 and byte <= 223 then
        shift = 2
    elseif byte > 224 and byte <= 239 then
        -- 全角标点或者汉字
        shift = 3
    elseif byte >= 240 and byte <= 247 then
        shift = 4
    end

    return shift
end

function RichLabel:tabAddDataTo(tab, src)
    table.merge(tab, src)
end

function RichLabel:addDataToRenderTab(copyVar, tab, text, index, current, strLen)
    local tag = #copyVar + 1
    copyVar[tag] = {}
    self:tabAddDataTo(copyVar[tag], tab)
    copyVar[tag].text = text
    copyVar[tag].index = index              -- 该行的第几个字符开始
    copyVar[tag].row = current              -- 第几行
    copyVar[tag].breadth = strLen           -- 所占宽度
    copyVar[tag].tag = tag                  -- 唯一标识
end

-- 拆分出单个字符
function RichLabel:comminuteText(str)
    local list = {}
    local len = string.len(str)
    local i = 1
    while i <= len do
        local byte = string.byte(str, i)        -- 获取字符的整数形式
        local shift = 1
        if byte > 0 and byte <= 127 then
            shift = 1
        elseif byte >= 192 and byte <= 223 then
            shift = 2
        elseif byte >= 224 and byte <= 239 then
            shift = 3
        elseif byte >= 240 and byte <= 247 then
            shift = 4
        end

        local char = string.sub(str, i, i + shift - 1)
        i = i + shift
        table.insert(list, char)
    end

    return list, len
end

-- 计算，再排版

-- 根据限定的宽度，再切割，确定行数
--[[
    var是字符串以及table构成的数组
]]

--[[
    "arr: " = {
        1 = "试试"
        2 = {
            "labelInfo" = "FF00FF"
            "text"      = "变色"
            "type"      = "color"
        }
        3 = "结尾"
    }
]]
function RichLabel:automaticNewLine(var, width, size)
    
    local allTab = {}       -- 总的字符数组
    local copyVar = {}      -- 准备渲染的数组
    local useLen = 0        -- 记录该行使用长度信息
    local str = ""          -- 储存该行字符
    local cur = 1           -- 记录最大行数
    local textLen

    for _, tab in ipairs(var) do

        -- 将字符串切割，返回字符串数组和字符数
        local textTab

        textTab = self:comminuteText(tab.text)

        -- 每一行最多能完整放下几个字符
        local num = math.floor((width) / math.ceil((size) / chineseSize))
        -- 最后一行被占用，却未占满，先填满
        if useLen > 0 and tab.type ~= "enter" then
            local remain = num - useLen
            textLen = self:accountTextLen(tab.text, size)
            if textLen <= remain then
                -- 新的文本块长度小于剩余长度则直接拼接
                allTab[cur] = allTab[cur] .. tab.text
                self:addDataToRenderTab(copyVar, tab, tab.text, (useLen + 1), cur, textLen)
                useLen = useLen + textLen
                textTab = {}
            else
                -- 填满最后一行
                local cTag = 0
                local mStr = ""
                local sIndex = useLen + 1
                local sLenTotal = 0
                for k, element in pairs(textTab) do
                    local sLen = self:accountTextLen(element, size)
                    if useLen + sLen <= num then
                        useLen = useLen + sLen
                        sLenTotal = sLenTotal + sLen
                        cTag = k
                        mStr = mStr .. element
                    else
                        if string.len(mStr) > 0 then
                            allTab[cur] = allTab[cur] .. mStr
                            self:addDataToRenderTab(copyVar, tab, mStr, sIndex, cur, sLenTotal)
                        end
                        cur = cur + 1
                        useLen = 0          -- 重算占用长度
                        str = ""            -- 重新填充字符
                        break
                    end
                end
                for _ = 1, cTag do
                    table.remove(textTab, 1)
                end
            end
        elseif useLen > 0 then
            cur = cur + 1
            allTab[cur] = ""
            useLen = 0
            str = ""
        end

        -- 填充字符
        for k, element in pairs(textTab) do
            local sLen = self:accountTextLen(element, size)
            if useLen + sLen <= num then
                useLen = useLen + sLen          -- 记录字符已占用该行长度
                str = str .. element            -- 拼接该行字符
            else
                allTab[cur] = str               -- 储存已经装满字符的行
                self:addDataToRenderTab(copyVar, tab, str, 1, cur, useLen)
                cur = cur + 1                   -- 开辟新的一行
                useLen = sLen                   -- 重算占用长度
                str = element                   -- 重新填充字符
            end

            -- 最后一行字符占用情况
            if k == #textTab then
                if useLen <= num then
                    allTab[cur] = str
                    self:addDataToRenderTab(copyVar, tab, str, 1, cur, useLen)
                end
            end
        end
    end

    return allTab, copyVar
end

-- 创建指定颜色的文字
function RichLabel:createColorLabel(tab)
    local label = createSimpleLabel({ text = tab.text, size = tab.textSize, outLine = self.outLine, outlineSize = self.outlineSize, outLineColor = self.outLineColor })
    if tab.labelInfo then
        label:setColor(self:getC3bValue(tab.labelInfo))
    end
    return label
end

function RichLabel:getC3bValue(color)
    
    if string.len(color) == 6 then
        local tmp = {}
        for i = 0, 5 do
            local str = string.sub(color, i + 1, i + 1)
            if str >= "0" and str <= "9" then
                tmp[6 - i] = str - "0"
            elseif str == "A" or str == "a" then
                tmp[6 - i] = 10
            elseif str == "B" or str == "b" then
                tmp[6 - i] = 11
            elseif str == "C" or str == "c" then
                tmp[6 - i] = 12
            elseif str == "D" or str == "d" then
                tmp[6 - i] = 13
            elseif str == "E" or str == "e" then
                tmp[6 - i] = 14
            elseif str == "F" or str == "f" then
                tmp[6 - i] = 15
            else
                print("wrong color value.")
                tmp[6 - i] = 0
            end
        end

        -- 将十六进制的值转换成十进制
        local r = tmp[6] * 16 + tmp[5]
        local g = tmp[4] * 16 + tmp[3]
        local b = tmp[2] * 16 + tmp[1]
        return cc.c3b(r, g, b)
    end

    -- 默认值，如果解析出现什么问题返回这个
    return cc.c3b(255, 255, 255)
end

function RichLabel:cleanupSelf()
    self:removeAllChildren()
    self:removeSelf()
end

return RichLabel
