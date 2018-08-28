-- 
-- Author : Chen Qingqing 
-- Date : 2016-06-16 09:56:34
-- 图片文字，暂时只支持整数(以后可以修改成更通用的)，
-- 对齐方式可以通过设置 anchor point 来实现，例如左对齐(0, 0)，右对齐(1, 0)

local ImageNumber = class("ImageNumber", function ()
    return display.newNode()
end)

-- @param images 表示图片，0-9分别表示相应的数字图片
function ImageNumber:ctor(images)
    if not images then
        images = {}
        for i=0,9 do
            images[i] = "UI/GuildMainUI/" .. i .. ".png"
        end
    end

    self._images = images
    self._numbers = {}
end

-- public method
function ImageNumber:setNumber(number)
    local sprites = {}

    if number < 1 then
        table.insert(sprites, self:_getNumber(0))
    else
        while number >= 1 do
            local n = math.floor(number % 10)
            local sprite = self:_getNumber(n)
            table.insert(sprites, 1, sprite)
            number = number / 10
        end
    end

    self:_reset()
    self:_relayout(sprites)
end

function ImageNumber:_getNumber(number)
    return display.newSprite(self._images[number])
end

-- 移除旧的数字
function ImageNumber:_reset()
    for _,sprite in ipairs(self._numbers) do
        sprite:removeSelf()
    end
end

function ImageNumber:_relayout(sprites)
    self._numbers = sprites

    local width = 0
    local height = 0
    for _,sprite in ipairs(sprites) do
        sprite:setAnchorPoint(0, 0.5)
        sprite:setPosition(width, 0)
        self:addChild(sprite)

        local size = sprite:getContentSize()
        width = width + size.width
        height = math.max(height, size.height)
    end

    self:setContentSize(width, height)
end

return ImageNumber
