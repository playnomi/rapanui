
--[[
--
-- RapaNui
--
-- by Ymobe ltd  (http://ymobe.co.uk)
--
-- LICENSE:
--
-- RapaNui uses the Common Public Attribution License Version 1.0 (CPAL) http://www.opensource.org/licenses/cpal_1.0.
-- CPAL is an Open Source Initiative approved
-- license based on the Mozilla Public License, with the added requirement that you attribute
-- Moai (http://getmoai.com/) and RapaNui in the credits of your program.
]]

RNFastListView = {}


--since RapaNui touch listener doesn't return the target as the enterFrame does,
--we need to specify SELF here, and due to this fact
--only one RNList at once can be created  TODO: fix this.

local SELF




local function fieldChangedListener(self, key, value)

    getmetatable(self).__object[key] = value
    self = getmetatable(self).__object

    if key ~= nil and key == "x" then
        self:setX(value)
    end

    if key ~= nil and key == "y" then
        self:setY(value)
    end

    if key ~= nil and key == "alpha" then
        self:setAlpha(value)
    end
    if key ~= nil and key == "visible" then
        self:setVisibility(value)
    end
end


local function fieldAccessListener(self, key)

    local object = getmetatable(self).__object

    return getmetatable(self).__object[key]
end



function RNFastListView:new(o)
    local tab = RNFastListView:innerNew(o)
    local proxy = setmetatable({}, { __newindex = fieldChangedListener, __index = fieldAccessListener, __object = tab })
    return proxy, tab
end


function RNFastListView:innerNew(o)

    o = o or {
        name = "",
        options = { cellH = 50, cellW = 50, maxScrollingForceY = 30, minY = 0, maxY = 100, maxY = 100, touchW = 320, touchH = 480, touchStartX = 0, touchStartY = 0 },
        elements = {},
        x = 0,
        y = 0,
        cellForRowAtIndexPath = nil,
        --
        timerListener = nil,
        enterFrameListener = nil,
        touchListener = nil,
        --
        isTouching = false,
        tmpY = 0,
        deltay = 0,
        canScrollY = true,
        isScrollingY = false,
        --
        isChooseDone = false,
        cells = {},
        currentVisibleCells = {}
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function RNFastListView:init()
    SELF = self
    --set default values if nil
    if self.options.cellH == nil then self.options.cellH = 50 end
    if self.options.cellW == nil then self.options.cellW = 50 end
    if self.options.maxScrollingForceY == nil then self.options.maxScrollingForceY = 30 end
    if self.options.minY == nil then self.options.minY = 0 end
    if self.options.maxY == nil then self.options.maxY = 100 end
    if self.options.touchW == nil then self.options.touchW = 320 end
    if self.options.touchH == nil then self.options.touchH = 480 end
    if self.options.touchStartX == nil then self.options.touchStartX = 0 end
    if self.options.touchStartY == nil then self.options.touchStartY = 0 end
    if self.options.timestep == nil then self.options.timestep = 1 / 60 end

    --organize items
 --   for i = 1, table.getn(self.elements), 1 do
 --       self.elements[i].object.x = self.x + self.elements[i].offsetX
 --       self.elements[i].object.y = self.y + i * self.options.cellH + self.elements[i].offsetY - self.options.cellH
 --   end

    --set listeners
    self.touchListener = RNListeners:addEventListener("touch", self.touchEvent)
    self.timerListener = nil
    self.createTimer()

    self.isToScroll = false
    self.postogo = 0

    self.registeredFunctions = {}

    self.scrolled = false

end

function RNFastListView:drawCells()

    print("draw cells")

    local elementSize = self.getListSize()

    print ("elementSize", elementSize)

   -- local height = MOAIEnvironment.verticalResolution

        local height = contentHeight

        minRow = -(math.floor(SELF.y / SELF.options.cellH)) + 1
        maxRow = -(math.floor((SELF.y-height) / SELF.options.cellH)) + 1

        if (minRow < 1) then
            minRow = 1
        end

        print ("min row", minRow, "max row", maxRow)

        for i = minRow, maxRow do

            self.elements[i] = self.cellForRowAtIndexPath(i)

        end

        --organize items
        --for i = 1, table.getn(self.elements), 1 do
        
        for i = minRow, maxRow do    
            self.elements[i].object.x = self.x + self.elements[i].offsetX
            self.elements[i].object.y = self.y + i * self.options.cellH + self.elements[i].offsetY - self.options.cellH
        end


end

function RNFastListView.step()

        if SELF ~= nil then
        if #SELF.elements > 0 then
     
            if SELF.canScrollY == true then
               
                if SELF.deltay > 0 then SELF.deltay = SELF.deltay - 0.2 end
                if SELF.deltay < 0 then SELF.deltay = SELF.deltay + 0.2 end

                if SELF.deltay > SELF.options.maxScrollingForceY then SELF.deltay = SELF.options.maxScrollingForceY end
                if SELF.deltay < -SELF.options.maxScrollingForceY then SELF.deltay = -SELF.options.maxScrollingForceY end

                if SELF.deltay > 0 and SELF.deltay <= 0.1 then
                    SELF.deltay = 0
                end
                if SELF.deltay < 0 and SELF.deltay >= -0.1 then
                    SELF.deltay = 0
                end

                if SELF.deltay > 0 and SELF.y < SELF.options.maxY + 100 then
                    SELF.y = SELF.y + SELF.deltay
                end
                
                -- don't do anything if deltay is = 0
                --if SELF.deltay <= 0 and SELF.y > SELF.options.minY - 100 then
                if SELF.deltay <= 0 and SELF.y > SELF.options.minY - 100 then
                    SELF.y = SELF.y + SELF.deltay
                end

                if SELF.deltay > 1 or SELF.deltay < -1 then
                    SELF.isScrollingY = true
                end

                if SELF.y > SELF.options.maxY and SELF.isTouching == false then
                    
                    SELF.deltay = 0
                    local value = (SELF.y - SELF.options.maxY) / 20
                    
                    SELF.y = SELF.y - value
                    if value < 0.001 then
                        SELF.removeTimer()
                    end
                end
                if SELF.y < SELF.options.minY and SELF.isTouching == false then
                    SELF.deltay = 0
                    local value = (SELF.options.minY - SELF.y) / 20
                    SELF.y = SELF.y + value
                    if value < 0.001 then
                        SELF.removeTimer()
                    end
                end

                --scroll due to postogo
                if SELF.isToScroll == true then
                    if SELF.y > SELF.postogo then SELF.y = SELF.y - 1 end
                    if SELF.y <= SELF.postogo then SELF.y = SELF.y + 1 end
                    if math.abs(SELF.y - SELF.postogo) < 2 then
                        SELF.y = SELF.postogo
                        SELF.isToScroll = false
                        SELF.removeTimer()
                    end
                end
                SELF:callRegisteredFunctions("step")
            end
        end
    end   
    

end

function RNFastListView.createTimer()
    if SELF.timerListener == nil then
        SELF.timerListener = RNMainThread.addTimedAction(SELF.options.timestep, SELF.step)
    end
end

function RNFastListView.removeTimer()
    if SELF.timerListener ~= nil then
        RNMainThread.removeAction(SELF.timerListener)
        SELF.timerListener = nil
    end
end

function RNFastListView:callRegisteredFunctions(phase)
    for i = 1, #SELF.registeredFunctions do
        SELF.registeredFunctions[i](phase)
    end
end

function RNFastListView:registerFunction(funct)
    self.registeredFunctions[#self.registeredFunctions + 1] = funct
end


function RNFastListView.touchEvent(event)
   
    --print("touch event")
    
    local self = SELF
    if self.canScrollY == true then
        if event.x > self.options.touchStartX and event.x < self.options.touchStartX + self.options.touchW and
                event.y > self.options.touchStartY and event.y < self.options.touchStartY + self.options.touchH then
            if event.phase == "began" and self ~= nil then
                self.tmpY = event.y
                self.isTouching = true
                SELF:callRegisteredFunctions("beganTouch")
                SELF.beganDelta = event.y - self.y
                self.olddeltay = 0
                SELF.removeTimer()
            end

            if event.phase == "moved" and self ~= nil then
                self.deltay = event.y - self.tmpY
                if self.canScrollY == true then
                    self.tmpY = event.y
                    SELF:callRegisteredFunctions("movedTouch")
                    self.scrolled = true
                    if (SELF.deltay > 0 and SELF.y < SELF.options.maxY + 100) then
                        if self.olddeltay > 0 then
                            if self.beganDelta ~= nil then
                                --  print("               down")
                                self.y = event.y - self.beganDelta
                            end
                        else
                            -- print("got new began")
                            SELF.beganDelta = event.y - self.y
                        end
                    end
                    if (SELF.deltay < 0 and SELF.y > SELF.options.minY - 100) then
                        if self.olddeltay < 0 then
                            if self.beganDelta ~= nil then
                                --    print("               up")
                                self.y = event.y - self.beganDelta
                            end
                        else
                            -- print("got new began")
                            SELF.beganDelta = event.y - self.y
                        end
                    end
                end
                self.olddeltay = self.deltay
            end


            if event.phase == "ended" and self ~= nil and self.isScrollingY == false and self.isChooseDone == false then
                print("ended not scrolling")
                for i = 1, table.getn(self.elements), 1 do
                    if event.x > self.x and event.x < self.x + self.options.cellW and event.y > self.y + i * self.options.cellH - self.options.cellH and event.y < self.y + i * self.options.cellH + self.options.cellH - self.options.cellH then
                        if self.elements[i].onClick ~= nil and self.scrolled == false then
                            local funct = self.elements[i].onClick
                            funct({ target = self.elements[i] })
                        end
                    end
                end
                self.isTouching = false
                SELF:callRegisteredFunctions("endedTouch")
                self.scrolled = false
                SELF.createTimer()
            end
        end
    end
    if event.phase == "ended" and self.isScrollingY == true then
        print("ended is scrolling")
        self.isScrollingY = false
        self.isTouching = false
        SELF:callRegisteredFunctions("cancelledTouch")
        self.scrolled = false
        SELF.createTimer()
    end
    

end


function RNFastListView:setX(value)
    for i, v in ipairs(self.elements) do
        if v.object ~= nil then
            v.object.x = self.x + self.elements[i].offsetX
        end
    end
    self.options.x = value
end

function RNFastListView:jumpToLetter(letter)

    print("jump to letter", letter)

    for i, v in pairs(self.elements) do
        self.elements[i].object:remove()
        self.elements[i] = nil
    end
    
    print("all elements removed")
    
    -- get the letter index
    print("letter", letter)
    print("min value", self.options.minY)

    index = self.letterIndexes[letter]

    print ("jump to index", self.letterIndexes[letter])
    print ("jump to y", - index * self.options.cellH)

    self.deltay = 0
    self.y = - index * self.options.cellH

    self:drawCells()

end

--lastDeltay = 0 

function RNFastListView:setY(value)
    
    if self.deltay > self.options.cellH then
    
        print("big jump", self.deltay)
        
    end
    
        local indexRemoved = 0

        -- need to check the value and see if it is higher than the max
        local height = contentHeight

        minRow = -(math.floor(self.y/ self.options.cellH))
        maxRow = -(math.floor((self.y - height) / self.options.cellH))

        if (minRow < 1) then
            minRow = 1
        end

        if (maxRow > self.options.getListSizeFunction()) then
            maxRow = self.options.getListSizeFunction()
        end

        if (self.deltay < 0 ) then
        
            local higherNeeded = false
        
            for i, v in pairs(self.elements) do
            
                local newY = self.y + i * self.options.cellH + self.elements[i].offsetY - self.options.cellH
        
                if (newY < -self.options.cellH*1.5 and maxRow <= self.options.getListSizeFunction()) then
                    higherNeeded = true                
                    lowerIndex = i
                else
                    if v.object ~= nil then
                        v.object.y = newY
                    end
                end
            end
            
                if (higherNeeded == true) then
            
                    nextRow = maxRow+1
                    if (self.elements[nextRow] == nil) then

                        self.elements[nextRow] = self.cellForRowAtIndexPath(nextRow)
                        
                        if (self.elements[nextRow] ~= nil and self.elements[lowerIndex] ~= nil) then

                            print("higher needed remove lower: ", lowerIndex)
                            print("higher needed add: ", nextRow)
                    
                            -- remove all lower than lower index
                            
                            for i, element in pairs(self.elements) do
                            
                                if ( i <= lowerIndex ) then
                                
                                    --print("Remove index", i)

                                    self.elements[i].object:remove()
                                    self.elements[i] = nil
                                end
                            end
                    
                            indexRemoved = lowerIndex
                        end
                        
                        self.elements[nextRow].object.y = self.y + (nextRow) * self.options.cellH + self.elements[nextRow].offsetY - self.options.cellH

                    end
                end

                -- base case should have no nil cells
                for i=minRow, maxRow do

                    if self.elements[i] == nil and i ~= indexRemoved then
                        --print ("fill in higher cell at ", i, indexRemoved)
                        self.elements[i] = self.cellForRowAtIndexPath(i)

                        -- now we must give this a y value
                        self.elements[i].object.y = self.y + (i) * self.options.cellH + self.elements[i].offsetY - self.options.cellH
                        
                    end

                end
                
        elseif (self.deltay > 0) then
        
            local lowerNeeded = false
            for i, v in pairs(self.elements) do

                local newY = self.y + i * self.options.cellH + self.elements[i].offsetY - self.options.cellH
                if (newY > (height + self.options.cellH) and minRow > 1) then
                    lowerNeeded = true
                    higherIndex = i
                else
                    if v.object ~= nil then
                        v.object.y = newY
                    end
                end
            end
        
            if (lowerNeeded == true) then
                nextRow = minRow - 1
                if (self.elements[nextRow] == nil) then
                    
                    self.elements[nextRow] = self.cellForRowAtIndexPath(nextRow)
                    
                    if (self.elements[nextRow] == nil) and (self.elements[maxRow+1] ~= nil) then

                        print("lower needed remove higher: ", higherIndex)
                        print("lower needed add: ", nextRow)

                       -- self.elements[maxRow+1].object:remove()
                       -- self.elements[maxRow+1] = nil
                        for i, element in ipairs(self.elements) do
                            if ( i >= maxRow+1 ) then
                            
                                --print("Remove index", i)
                                self.elements[i].object:remove()
                                self.elements[i] = nil
                            end
                        end
                    
                        indexRemoved = maxRow+1
                    end
                    
                    self.elements[nextRow].object.y = self.y + (nextRow) * self.options.cellH + self.elements[nextRow].offsetY - self.options.cellH
                end
            end

            -- base case should have no nil cells
            for i=minRow, maxRow do
                if self.elements[i] == nil and i ~= indexRemoved then
                    --print ("fill in lower cell at ", i, indexRemoved)
                    self.elements[i] = self.cellForRowAtIndexPath(i)  
                    
                    self.elements[i].object.y = self.y + (i) * self.options.cellH + self.elements[i].offsetY - self.options.cellH                

                end
            end
        end
        
    for i, element in pairs(self.elements) do
    
        if i < minRow or i > maxRow then
            --print("Remove index backup", i)
            self.elements[i].object:remove()
            self.elements[i] = nil       
        end

    end
        

    self.options.y = value
end

function RNFastListView:remove()
    
    self:removeTimer()
    RNListeners:removeEventListener("touch", self.touchListener)
    
    for i, v in pairs(self.elements) do
        if v.object ~= nil then
            v.object:remove()
        end
    end

    self = nil
    SELF = nil    
    

end



-- elements actions

function RNFastListView:getElement(value)
    return self.elements[value]
end

function RNFastListView:getSize()
    return table.getn(self.elements)
end

function RNFastListView:insertElement(element, number)
    if number ~= nil then
        --the element is add to the end of the list if param number is > of the list size
        if number > self:getSize() then
            self.elements[self:getSize() + 1] = element
        end
        --else the element is inserted in the place [number] and the below elements moved
        if number <= self:getSize() then
            for i = self:getSize(), number, -1 do
                self.elements[i + 1] = self.elements[i]
            end
            self.elements[number] = element
        end
    else
        --the element is add to the end of the list if param number is nil
        self.elements[self:getSize() + 1] = element
    end
end

function RNFastListView:removeElement(removeRNObject, number)
    if number ~= nil then
        if number > self:getSize() then
            if removeRNObject == true then
                self.elements[self:getSize()].object:remove()
            end
            self.elements[self:getSize()] = nil
        end
        if number <= self:getSize() then
            if removeRNObject == true then
                self.elements[number].object:remove()
            end
            for i = number, self:getSize() - 1, 1 do
                self.elements[i] = self.elements[i + 1]
            end
            self.elements[self:getSize()] = nil
        end
    else
        if removeRNObject == true then
            self.elements[self:getSize()].object:remove()
        end
        self.elements[self:getSize()] = nil
    end
end


function RNFastListView:swapElements(n1, n2)
    local tempn1 = self.elements[n1]
    local tempn2 = self.elements[n2]

    self.elements[n1] = tempn2
    self.elements[n2] = tempn1
end


function RNFastListView:getObjectByNumber(value)
    local o
    for i = 1, self:getSize() do
        if i == value then
            o = self.elements[i]
        end
    end

    return o
end


function RNFastListView:getNumberByObject(value)
    local n
    for i = 1, self:getSize() do
        if self.elements[i].object == value then
            n = i
        end
    end

    return n
end

--

function RNFastListView:getType()
    return "RNFastListView"
end


function RNFastListView:setAlpha(value)
    for i, v in ipairs(self.elements) do
        v.object:setAlpha(value)
    end
end

function RNFastListView:setVisibility(value)
    for i, v in ipairs(self.elements) do
        v.object.visible = value
    end
end

function RNFastListView:goToElement(value)
    self.isToScroll = true
    self.postogo = -value * self.options.cellH + self.options.touchStartY + self.options.cellH
    self.createTimer()
end

function RNFastListView:jumpToElement(value)
    SELF.y = -value * SELF.options.cellH + SELF.options.touchStartY + SELF.options.cellH
    SELF.removeTimer()
end


function RNFastListView:getTotalHeight()
    return self.options.cellH * (#self.elements)
end

--mocks for groupAdd (Yes, RNListViews can be added to RNGroups ^^)

function RNFastListView:setIDInGroup()
    --mocked for group adding see RNGroup
end

function RNFastListView:setLevel()
    --mocked for group adding see RNGroup
end

function RNFastListView:setParentGroup()
    --mocked for group adding see RNGroup
end

return RNFastListView
