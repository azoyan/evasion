local orientation = { --The orientation table holds the API
    _VERSION     = 'orientation v0.1.0',
    _DESCRIPTION = 'Detect mobile phone orientation using the accelerometer in LÖVE',
    _URL         = 'https://www.github.com/Positive07/Love-Android-libs',
    _LICENSE     = [[
        Licensed under MIT License (MIT)

        Copyright (c) 2015 Pablo Mayobre

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]]
}

--The library is not stateless but there is no need for it to be, there is a single device and a single screen
local _D = { --The _D table holds the data
    screen = "landscape",
    orientation = 0,
    accelerometers = { --Possible accelerometer names, lower case!
        ["android accelerometer"]   = true,
        ["iphone accelerometer"]    = true, --This depends on the SDL version
        ["ios accelerometer"]       = true, --Some use this alternative so we better support both
        ["windows accelerometer"]   = true  --?? Maybe in the WinRT port who knows...
    },
	name = {
		[0] = {"landscape", "left"  },
		      {"portrait" , "top"   },
		      {"landscape", "right" },
		      {"portrait" , "bottom"}
	},
	tresholds = {},
	axis = { {time = 0},{time = 0},{time = 0} }
}

--------------------------------------------------
--               Helper Functions               --
--------------------------------------------------
local sign = function (number)  --Sign function
    return number >= 0
end

local angle = function (orientation) --Turn an orientation value into an angle in radians
    local add = _D.screen == "landscape" and 0 or 1

    local orientation = (orientation + add) % 4

    return orientation / 2 * math.pi
end

--------------------------------------------------
--               Setup Functions                --
--------------------------------------------------
orientation.screen = function (w, h) --w = landscape/portrait (The one specified in the AndroidManifest)
                                     --h = if w is a number w is the width and h is the height, the type is deduced from this
    if w == nil and h == nil then w,h = love.graphics.getDimensions() end

	local typ = w

    if type(w) == "number" and type(h) == "number" then
        typ = w > h and "landscape" or "portrait"
    end

    _D.screen = typ == "portrait" and "portrait" or "landscape" --Default landscape
end

orientation.tresholds = function (t) --Change the tresholds to be used
    local t = t or {}

    _D.tresholds = { --Adjust tresholds to change the sensibility
        top     = t.top     or _D.tresholds.top     or 70,   --Defines the top region
        bottom  = t.bottom  or _D.tresholds.bottom  or 30,   --Defines the bottom region
        time    = t.time    or _D.tresholds.time    or 0.3,  --Defines the time between changes
    }
end

orientation.tresholds()

--------------------------------------------------
--                Get functions                 --
--------------------------------------------------
orientation.possible = function () --A check to see if it is possible to detect orientation
    if _D.joystick == nil then --Joystick was not loaded
        _D.joystick = false

        if love.joystick then --If the joystick module is present
            for _, joystick in ipairs(love.joystick.getJoysticks()) do --Loop through the available joysticks
                if _D.accelerometers[string.lower(joystick:getName())] then
                    _D.joystick = joystick --Yeah we found the accelerometer!
                    break
                end
            end
        end

        if not _D.joystick then return false end --Not found!
    elseif _D.joystick == false then
        return false --No accelerometer, sorry
    end

    return true
end

orientation.update = function (dt) --Call this function in love.update and get the current orientation
    if not orientation.possible() then return _D.orientation end --Check if it is possible

    --Okey this is the important part (THE MATH!)! 

    local accel = _D.joystick --Localize it in order to use a shorter name

    for i=1, 3 do --For each of the three axis in the accelerometer
        local axis = accel:getAxis(i)
        local sign, value = sign(axis), math.abs(axis * 100)

        local region = value > _D.tresholds.top and "top" or value < _D.tresholds.bottom and "bottom" or _D.axis[i].region

        if _D.axis[i].region ~= region then --Something changed
			_D.axis[i].time = _D.axis[i].time + dt --Add delta time to the current time
            if _D.axis[i].time > _D.tresholds.time then --Check if it is not an error and update the info
                _D.axis[i].region   = region
                _D.axis[i].sign     = sign
				_D.axis[i].time		= 0 --Reset the time of the last change
            end
        end
    end
    
    local orientation   = _D.orientation --Default is the last orientation
    local x, y, z = _D.axis[1].region, _D.axis[2].region, _D.axis[3].region --Give better names to some stuff

    if x == "bottom" and y == "top" and z == "top" then -- Landscape
        if _D.axis[2].sign then --The sign determines whether it is one side or the other
            orientation = 0
        else
            orientation = 2
        end
        orientation = angle(orientation) --Takes the orientation and turns it into radians
    elseif x == "top" and y == "bottom" and z == "top" then -- Portrait
        if _D.axis[1].sign then  --The sign determines whether it is one side or the other
            orientation = 3
        else
            orientation = 1
        end
        orientation = angle(orientation) --Takes the orientation and turns it into radians
    --[[
    elseif x == "bottom" and y == "bottom" and z == "bottom" then -- Flat
        orientation = 0 --Default orientation
    ]]
    end

    _D.orientation  = orientation --Save the orientation for later use

    return orientation
end

orientation.get = function ()  --If you have already called update use this to get the orientation of this frame
    return _D.orientation
end

orientation.name = function (angle)
	local orientation = angle / math.pi * 2 - (_D.screen == "landscape" and 0 or 1)

	return unpack(_D.name[orientation])
end

--------------------------------------------------
if _debug then orientation.data = _D end --If you use this in debug mode you have access to the data table

return orientation