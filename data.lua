local item = {
    type = "selection-tool",
    name = "wire-box-tool",
    subgroup = "tool",
    order = "z[wire-box-tool]",
    show_in_library = false,
    icons = {
        {
            icon = "__WireBox__/graphics/icons/power-grid-comb.png",
            icon_size = 32,
        }
    },
    flags = { "hidden", "only-in-cursor", "not-stackable", "spawnable" },
    stack_size = 1,
    stackable = false,
    selection_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
    alt_selection_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
    selection_mode = { "buildable-type", "same-force" },
    alt_selection_mode = { "buildable-type", "same-force" },
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity"
}

local shortcut = {
    type = "shortcut",
    name = "shortcut-wire-box-tool-item",
    action = "spawn-item",
    item_to_spawn = "wire-box-tool",
    order = "m[wire-box-tool]",
    icon = {
        filename = "__WireBox__/graphics/icons/power-grid-comb-x32.png",
        flags = { "icon" },
        priority = "extra-high-no-scale",
        scale = 1,
        size = 32
    },
    disabled_icon = {
        filename = "__WireBox__/graphics/icons/power-grid-comb-x32-white.png",
        flags = { "icon" },
        priority = "extra-high-no-scale",
        scale = 1,
        size = 32
    },
    small_icon = {
        filename = "__WireBox__/graphics/icons/power-grid-comb-x24.png",
        flags = { "icon" },
        priority = "extra-high-no-scale",
        scale = 1,
        size = 24
    },
    disabled_small_icon = {
        filename = "__WireBox__/graphics/icons/power-grid-comb-x24-white.png",
        flags = { "icon" },
        priority = "extra-high-no-scale",
        scale = 1,
        size = 24
    }
}

data:extend{item, shortcut}