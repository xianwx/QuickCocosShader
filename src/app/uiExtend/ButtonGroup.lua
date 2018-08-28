-- 
-- Author : Chen Qingqing 
-- Date : 2016-06-14 11:07:59
-- 类似RadioButton的功能，单选按钮

local ButtonGroup = class("ButtonGroup")

function ButtonGroup:ctor(parent, buttonNames, onFocus, onFocusLost)
    self._buttonNames = buttonNames
    self._onFocus = onFocus
    self._onFocusLost = onFocusLost

    for index,name in ipairs(buttonNames) do
        local focusFunc = function ()
            self:focus(index, name)
        end

        if type(name) == "table" then
            layerLoadControl:setButtonEvent(parent, name, focusFunc)
        else
            layerLoadControl:setButtonEvent(parent, name, focusFunc)
        end
    end
end

-- public method
function ButtonGroup:focus(index)
    if index == self._focused or self._disable then
        return
    end

    if self._focused and self._onFocusLost then
        self._onFocusLost(self._focused, self._buttonNames[self._focused])
    end

    self._focused = index
    if self._onFocus then
        self._onFocus(index, self._buttonNames[index])
    end
end

-- public
function ButtonGroup:getFocused()
    return self._focused
end

-- public
function ButtonGroup:active()
    self._disable = false
end

-- public
function ButtonGroup:disabled()
    self._disable = true
end
return ButtonGroup
