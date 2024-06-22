local function getEntityOrNilFromDict(haystack, needle)
    for _, entity in pairs(haystack) do
        if entity == needle then
            return entity
        end
    end

    return nil
end

local function isEntityTypeInPlayerNeed(entityType, playerNeed)
    for _, need in ipairs(playerNeed) do
        if entityType == need then
            return true
        end
    end
    return false
end

local function getPlayerNeed(settings)
    local need = {}
    for key, value in pairs(settings) do
        if key:sub(1, 9) == "alt-mode-" and value.value then
            need[#need + 1] = key:sub(10)
        end
    end
    return need
end

local function filter_entities(entities, playerNeed)
    local filtered = {}
    for _, entity in ipairs(entities) do
        if isEntityTypeInPlayerNeed(entity.type, playerNeed) then
            table.insert(filtered, entity)
            log(tostring(entity.electric_network_id))
    end
    end
    return filtered
end

local function zigzag_sort(entities, playerNeed)
    entities = filter_entities(entities, playerNeed)
    -- 先按從上到下、從左到右的順序排序
    table.sort(entities, function(a, b)
        if a.position.y == b.position.y then
            return a.position.x < b.position.x
        else
            return a.position.y < b.position.y
        end
    end)
    -- 分行處理
    local rows = {}
    local current_row_y = nil
    local current_row = {}
    for _, entity in ipairs(entities) do
        if current_row_y == nil or entity.position.y == current_row_y then
            table.insert(current_row, entity)
            current_row_y = entity.position.y
        else
            table.insert(rows, current_row)
            current_row = { entity }
            current_row_y = entity.position.y
        end
    end
    if #current_row > 0 then
        table.insert(rows, current_row)
    end
    -- 對每一行進行左右顛倒排列
    local zigzag_sorted_entities = {}
    for i, row in ipairs(rows) do
        if i % 2 == 0 then
            for j = #row, 1, -1 do
                table.insert(zigzag_sorted_entities, row[j])
            end
        else
            for j = 1, #row do
                table.insert(zigzag_sorted_entities, row[j])
            end
        end
    end

    return zigzag_sorted_entities
end

local function on_player_selected_area(event)
    if event.item ~= "wire-box-tool" then
        return
    end
    local playerSettings = settings.get_player_settings(event.player_index)

    for _, entity in pairs(event.entities) do
        if entity.type == "electric-pole" and entity.neighbours and entity.neighbours.copper then
            for _, targetEntity in pairs(entity.neighbours.copper) do
                -- Ignore entities we're connected to that aren't in our selected entities.
                if getEntityOrNilFromDict(event.entities, targetEntity) then
                    local isBoth = playerSettings["wire-box-tool-mode"].value == "red-green"
                    local isRed = isBoth or playerSettings["wire-box-tool-mode"].value == "red-only"
                    local isGreen = isBoth or playerSettings["wire-box-tool-mode"].value == "green-only"

                    if isRed and not getEntityOrNilFromDict(entity.neighbours.red, targetEntity) then
                        entity.connect_neighbour({ wire = defines.wire_type.red, target_entity = targetEntity })
                    end

                    if isGreen and not getEntityOrNilFromDict(entity.neighbours.green, targetEntity) then
                        entity.connect_neighbour({ wire = defines.wire_type.green, target_entity = targetEntity })
                    end
                end
            end
        end
    end
end

local function on_player_alt_selected_area(event)
    if event.item ~= "wire-box-tool" then
        return
    end
    local playerSettings = settings.get_player_settings(event.player_index)
    local entities = event.entities
    local playerNeed = getPlayerNeed(playerSettings)
    if next(playerNeed) == nil then
        return
    end

    -- 以從左到右、從上到下的順序按實體的位置對實體進行排序
    entities = zigzag_sort(entities, playerNeed)

    local lastEntity = nil

    for i = 1, #entities do
        local entity = entities[i]
        if lastEntity then
            local isBoth = playerSettings["wire-box-tool-mode"].value == "red-green"
            local isRed = isBoth or playerSettings["wire-box-tool-mode"].value == "red-only"
            local isGreen = isBoth or playerSettings["wire-box-tool-mode"].value == "green-only"
            if isRed then
                pcall(function()
                    lastEntity.connect_neighbour({ wire = defines.wire_type.red, target_entity = entity })
                end)
            end
            if isGreen then
                pcall(function()
                    lastEntity.connect_neighbour({ wire = defines.wire_type.green, target_entity = entity })
                end)
            end
        end
        -- The current entity becomes the last entity for the next iteration
        lastEntity = entity
    end
end

local function on_player_reverse_selected_area(event)
    if event.item ~= "wire-box-tool" then
        return
    end
    local playerSettings = settings.get_player_settings(event.player_index)

    for _, entity in pairs(event.entities) do
        if entity.type == "electric-pole" and entity.neighbours and entity.neighbours.copper then
            for _, targetEntity in pairs(entity.neighbours.copper) do
                -- 忽略我們連結到的、不在我們所選實體中的實體.
                if getEntityOrNilFromDict(event.entities, targetEntity) then
                    local isBoth = playerSettings["wire-box-tool-mode"].value == "red-green"
                    local isRed = isBoth or playerSettings["wire-box-tool-mode"].value == "red-only"
                    local isGreen = isBoth or playerSettings["wire-box-tool-mode"].value == "green-only"
                    if isRed then
                        entity.disconnect_neighbour({ wire = defines.wire_type.red, target_entity = targetEntity })
                    end
                    if isGreen then
                        entity.disconnect_neighbour({ wire = defines.wire_type.green, target_entity = targetEntity })
                    end
                end
            end
        end
    end
end

local function on_player_alt_reverse_selected_area(event)
    if event.item ~= "wire-box-tool" then
        return
    end
    local playerSettings = settings.get_player_settings(event.player_index)
    local entities = event.entities
    local playerNeed = getPlayerNeed(playerSettings)
    if next(playerNeed) == nil then
        return
    end
    -- 以從左到右、從上到下的順序按實體的位置對實體進行排序
    entities = zigzag_sort(entities, playerNeed)
    local lastEntity = nil
    for i = 1, #entities do
        local entity = entities[i]
        -- Check if the entity is a container
        if lastEntity then
            local isBoth = playerSettings["wire-box-tool-mode"].value == "red-green"
            local isRed = isBoth or playerSettings["wire-box-tool-mode"].value == "red-only"
            local isGreen = isBoth or playerSettings["wire-box-tool-mode"].value == "green-only"
            if isRed then
                pcall(function()
                    lastEntity.disconnect_neighbour({ wire = defines.wire_type.red, target_entity = entity })
                end)
            end
            if isGreen then
                pcall(function()
                    lastEntity.disconnect_neighbour({ wire = defines.wire_type.green, target_entity = entity })
                end)
            end
        end
        -- The current entity becomes the last entity for the next iteration
        lastEntity = entity
    end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
script.on_event(defines.events.on_player_reverse_selected_area, on_player_reverse_selected_area)
script.on_event(defines.events.on_player_alt_reverse_selected_area, on_player_alt_reverse_selected_area)
