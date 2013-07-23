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

-- Author: niom
-- Date: 11/25/12

RNLayer = {
    LAYER_WITH_SAME_NAME_EXISTS = "layer with same name already exists",
    MAIN_LAYER = "mainlayer"
}

function RNLayer:new()
    local layers = {}
    setmetatable(layers,self)
    self.__index = self
    return layers
end

function RNLayer:createLayer(name,viewport)
	local layer = MOAILayer2D.new()
	local index = table.getn(self) + 1
	
	if self:get(name) then
        print("returning nil for layer")
		return nil, RNLayer.LAYER_WITH_SAME_NAME_EXISTS
	end

    self[index] = {} 
    self[index].layer = layer
    self[index].name = name
    
    
    layer:setViewport(viewport)
    
    print("RNFactory.screen.mainPartition", RNFactory.screen.mainPartition)
    if RNFactory.screen.mainPartition then
    
        --layer:setPartition(RNFactory.screen.mainPartition)
    
    end
    
    MOAISim.pushRenderPass(layer)

    return layer
end

-- gets the layer or creates it if it does not exist
function RNLayer:getLayer(name)
    for i,container in pairs(self) do
        if container.name == name then
            return container.layer
        end
    end
    
    -- create the layer if it does not exist
    return self:createLayer(name, RNFactory.screen.viewport)
    
end



function RNLayer:get(name)
    for i,container in pairs(self) do
        if container.name == name then
            return container.layer
        end
    end
    return nil
end

function RNLayer:createLayerWithPartition(name,viewport)
    local layer = self:createLayer(name,viewport)
    local partition = MOAIPartition.new()
    layer:setPartition(partition)
    return layer,partition
end

function RNLayer:remove(layer)
	for i, container in pairs(self) do
		if container.layer == layer then
			self:clearContainer(container)
			table.remove(self, i)
		end
	end
end

function RNLayer:removeAll()
	while table.getn(self) > 0 do
		self:clearContainer(self[1])
		table.remove(self, 1)
	end
end

function RNLayer:clearContainer(container)
	container.layer:clear()
	container.layer = nil
	container.name = nil
end

return RNLayer