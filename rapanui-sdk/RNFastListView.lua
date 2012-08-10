
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
        options = { cellH = 50, cellW = 50, maxScrollingForceY = 30, minY = 0, maxY = 100 },
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


    --set listeners
    self.timerListener = RNMainThread.addTimedAction(.01, self.step)
    self.touchListener = RNListeners:addEventListener("touch", self.touchEvent)
    --self.enterFrameListener = RNListeners:addEventListener("enterFrame", self)

end

function RNFastListView:drawCells()

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

--function RNFastListView:enterFrame()
function RNFastListView.step()
    if SELF ~= nil and SELF.canScrollY == true then
        
        if SELF.deltay > 0 then 
            SELF.deltay = SELF.deltay - 0.2 
        end
        
        if SELF.deltay < 0 then 
            SELF.deltay = SELF.deltay + 0.2 
        end

        if SELF.deltay > SELF.options.maxScrollingForceY then SELF.deltay = SELF.options.maxScrollingForceY end
        if SELF.deltay < -SELF.options.maxScrollingForceY then SELF.deltay = -SELF.options.maxScrollingForceY end

        if SELF.deltay > 0 and SELF.deltay <= 0.2 
            then SELF.deltay = 0 
        end

        if SELF.deltay < 0 and SELF.deltay >= -0.2 
            then SELF.deltay = 0 
        end

        if SELF.deltay > 0 and SELF.y < SELF.options.maxY + 100 then
           --print("set y less than max", SELF.deltay)
            SELF.y = SELF.y + SELF.deltay
         
        if (SELF.isTouching == true) then
            --SELF.deltay = 0
        end

        elseif SELF.deltay <= 0 and SELF.y > SELF.options.minY - 100 then            
            
            if (SELF.deltay ~= 0) then
                SELF.y = SELF.y + SELF.deltay
            
                if (SELF.isTouching == true) then
                    --SELF.deltay = 0
                end

            end
        end

        if SELF.deltay > 1 or SELF.deltay < -1 then
            SELF.isScrollingY = true
             --print("enterFrame deltay", SELF.deltay)
        end

        if SELF.y > SELF.options.maxY and SELF.isTouching == false then
            
            if (SELF.y - SELF.options.maxY > SELF.options.cellH/2) then

                -- trigger the callback here
                if SELF.options.callback ~= nil then
                    SELF.options.callback("reload")
                end
            end

            SELF.deltay = 0

            --print("EnterFame: changing y ", SELF.deltay)
            SELF.y = SELF.y - (SELF.options.maxY + SELF.y) / 20
        end
        if SELF.y < SELF.options.minY and SELF.isTouching == false then
            --print("EnterFame: changing y plac 2 ", SELF.options.minY, "self.y", SELF.y)
            SELF.deltay = 0
            
            if (SELF.options.minY - SELF.y) < 1 and (SELF.options.minY - SELF.y) > -1 then 
                SELF.y = SELF.options.minY
            else
                SELF.y = SELF.y + (SELF.options.minY - SELF.y) / 20
            end
        end
    end
end

function RNFastListView.touchEvent(event)
    local self = SELF
    if event.phase == "began" and self ~= nil then
        self.tmpY = event.y
        self.isTouching = true
    end


    if event.phase == "moved" and self ~= nil then
        self.deltay = event.y - self.tmpY
        if self.canScrollY == true then
            self.tmpY = event.y            
        end
    end

    if event.phase == "ended" and self ~= nil and self.isScrollingY == false and self.isChooseDone == false then
        for i = 1, table.getn(self.elements), 1 do
            if event.x > self.x and event.x < self.x + self.options.cellW and event.y > self.y + i * self.options.cellH - self.options.cellH and event.y < self.y + i * self.options.cellH + self.options.cellH - self.options.cellH then
                if self.elements[i].onClick ~= nil then
                    local funct = self.elements[i].onClick
                    funct({ target = self.elements[i] })
                end
            end
        end
        self.isTouching = false
    end

    if event.phase == "ended" and self.isScrollingY == true then
        self.isScrollingY = false
        self.isTouching = false
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

    self.y = - index * self.options.cellH

    local elementSize = self.getListSize()

    print ("elementSize", elementSize)

    --local height = MOAIEnvironment.verticalResolution

    local height = contentHeight

    print("current y", self.y, SELF.y)

    minRow = -(math.floor(SELF.y / SELF.options.cellH)) + 1
    maxRow = -(math.floor((SELF.y-height) / SELF.options.cellH)) + 1

    if maxRow > elementSize then
        maxRow = elementSize
        minRow = math.floor(maxRow - height/SELF.options.cellH)
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

--lastDeltay = 0 

function RNFastListView:setY(value)
    
    -- need to check the value and see if it is higher than the max
    --local height = MOAIEnvironment.verticalResolution
    local height = contentHeight

    minRow = -(math.floor(self.y / self.options.cellH)) + 1
    maxRow = -(math.floor((self.y-height) / self.options.cellH)) + 1

    minRow = minRow - 1
    --maxRow = maxRow + 1


    if (minRow < 1) then
        minRow = 1
    end

    if (maxRow > self.options.getListSizeFunction()) then

        maxRow = self.options.getListSizeFunction()

    end

    if (self.deltay < 0 ) then
    
        higherNeeded = false
    
        for i, v in pairs(self.elements) do
        
            local newY = self.y + i * self.options.cellH + self.elements[i].offsetY - self.options.cellH
    
            if (newY < 0 and maxRow <= self.options.getListSizeFunction()) then
                higherNeeded = true                
                lowerIndex = i
                --lowerIndex = minRow
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

                        print("higher needed remove: ", lowerIndex)
                        print("higher needed add: ", nextRow)
                
                        self.elements[lowerIndex].object:remove()
                        self.elements[lowerIndex] = nil

                        self.elements[nextRow].object.y = self.y + (nextRow) * self.options.cellH + self.elements[nextRow].offsetY - self.options.cellH
                    
                    end

                end

            end

            -- base case should have no nil cells
            for i=minRow, maxRow do

                if self.elements[i] == nil then

                    self.elements[i] = self.cellForRowAtIndexPath(i)

                end

            end

    elseif (self.deltay > 0) then
    
        lowerNeeded = false

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

                if (self.elements[minRow-1] == nil) and (self.elements[maxRow+1] ~= nil) then

                    print("lower needed remove: ", higherIndex)
                    print("lower needed add: ", nextRow)

                    self.elements[maxRow+1].object:remove()
                    self.elements[maxRow+1] = nil

                    self.elements[nextRow].object.y = self.y + (nextRow) * self.options.cellH + self.elements[nextRow].offsetY - self.options.cellH
                    
                end
            end
        end

        -- base case should have no nil cells

        for i=minRow, maxRow do

            if self.elements[i] == nil then

                self.elements[i] = self.cellForRowAtIndexPath(i)

            end

        end

        
            
    end
        
    self.options.y = value
end

function RNFastListView:remove()
    --RNListeners:removeEventListener("enterFrame", self.enterFrameListener)
    RNMainThread.removeAction(self.timerListener)    
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



--mocks for groupAdd (Yes, RNFastListViews can be added to RNGroups ^^)


function RNFastListView:setIDInGroup()
    --mocked for group adding see RNGroup
end

function RNFastListView:setLevel()
    --mocked for group adding see RNGroup
end


return RNFastListView