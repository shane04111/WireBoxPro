local function getEntityOrNilFromDict(haystack, needle)
    for i, entity in pairs(haystack) do
        if entity == needle then
            return entity
        end
    end

    return nil
end

local function on_player_selected_area(event)
    if event.item == "wire-box-tool" then
        for k, entity in pairs(event.entities) do
            if entity.type == "electric-pole" and entity.neighbours and entity.neighbours.copper then
                for k, targetEntity in pairs(entity.neighbours.copper) do
                    -- Ignore entities we're connected to that aren't in our selected entities.
                    if getEntityOrNilFromDict(event.entities, targetEntity) then
                        if not getEntityOrNilFromDict(entity.neighbours.red, targetEntity) then
                            entity.connect_neighbour({wire = defines.wire_type.red, target_entity = targetEntity})
                        end

                        if not getEntityOrNilFromDict(entity.neighbours.green, targetEntity) then
                            entity.connect_neighbour({wire = defines.wire_type.green, target_entity = targetEntity})
                        end
                    end
                end
            end
        end
    end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)