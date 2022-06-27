-- time to parse the giant json files yipee!!!
local json_files, json_dirs = file.Find("addons/jackhammer_entity_tool/json/*.json", "GAME")

local ents_fgds_data = {} -- master table of all entity data

for k, v in ipairs(json_files) do
    local json_file = util.JSONToTable(file.Read("addons/jackhammer_entity_tool/json/" .. v, "GAME"))
    for k2, v2 in ipairs(json_file.entities) do
        v2.gametype = v
        ents_fgds_data[v2.name] = v2
    end
end

-- function to perform function func on all entries and sub entries in table tbl recursively
-- WARNING: this modifies in place
local function super_vectorize(tbl, func)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            tbl[k] = func(k)
            super_vectorize(v, func)
        else
            tbl[k] = func(v)
        end
    end
end

-- somehow lua does not have a good way to get the size of a table wtf???
local function size(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- main function to create gui
local function create_egui( className, keys, flags, io, misc )
    -- before we do anything, get all the entity fgs data needed

    local ent_fgds_data = ents_fgds_data[className]

    if ent_fgds_data == nil then 
        MsgC( Color( 255, 90, 90 ), "[JHammer] ERROR: No entity data found for " .. className .. "! This is probably a custom lua entity. \n")
        -- fill data with placeholder data
        ent_fgds_data = {
            name = className,
            description = "No description found, or this is a custom Lua entity.",
            type = "Unkown",
            parameters = {},
            properties = {},
            flags = {},
            outputs = {},
            intputs = {}, 
        }
    end

    -- get the ineritence tree for entity, recusively
    -- input: the entity fgd data
    local function get_ent_inheritance_tree( tbl )
        local ret = {}
        ret[tbl.name] = {}
        -- if lua end just return
        if tbl.type == "Unkown" then return {} end

        -- if no inheritances then return empty
        if tbl.parameters == nil then return {tbl.name} end

        -- base is always the first property i think check anyway
        if tbl.parameters[1].name ~= "base" then return {} end

        for k, v in ipairs(tbl.parameters[1].values) do
            table.insert(ret[tbl.name], get_ent_inheritance_tree( ents_fgds_data[v] ))
        end

        return ret
    end

    local ent_inheritance_tree = get_ent_inheritance_tree( ent_fgds_data )

    local keys_lookup_table = {}
    -- loop through the ent_inheritance_tree, for each entry add the print name to the keys_lookup_table
    local temp_table = ent_inheritance_tree
    super_vectorize(temp_table, function (inp) 
        if type(inp) ~= "string" then return end
        if inp == nil then return end
        if ents_fgds_data[inp].properties == nil then return end

        for k, v in pairs(ents_fgds_data[inp].properties) do
            keys_lookup_table[v.name] = v
        end

        return 0
    end)

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Entity editor")
    frame:SetSize(1000, 900)
    frame:SetSizable(true)
    frame:SetBackgroundBlur(true)
    frame:SetIcon("icon16/wand.png")

    frame:Center()
    frame:MakePopup()

    local sheet = vgui.Create( "DPropertySheet", frame )
    sheet:Dock( FILL )

    local ents_inf_panel = vgui.Create( "DPanel", sheet )
    --ents_inf_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Entity info", ents_inf_panel, "icon16/wrench.png" )

    local inputs_panel = vgui.Create( "DPanel", sheet )
    inputs_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 128, 0, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Inputs", inputs_panel, "icon16/brick.png" )

    local outputs_panel = vgui.Create( "DPanel", sheet )
    outputs_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 0, 128, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Outputs", outputs_panel, "icon16/brick_go.png" )

    local flags_panel = vgui.Create( "DPanel", sheet )
    flags_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 128, 0, 255, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Flags", flags_panel, "icon16/flag_blue.png" )

    local metainfo_panel = vgui.Create( "DPanel", sheet )
    metainfo_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 128, 255, 0, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Meta info", metainfo_panel, "icon16/book_open.png" )

    local settings_panel = vgui.Create( "DPanel", sheet )
    settings_panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 255, 128, self:GetAlpha() ) ) end 
    sheet:AddSheet( "Addon settings", settings_panel, "icon16/cog.png" )


    --[[
        all items belonging different panels should haev a prefix:
            - ents_inf_panel: "e_"
            - inputs_panel: "i_"
            - outputs_panel: "o_"
            - flags_panel: "f_"
            - metainfo_panel: "m_"
            - settings_panel: "s_"
    ]]--

    -- ====================== ents_inf_panel ======================

    -- class selector
    local e_class_selector_lbl = vgui.Create( "DLabel", ents_inf_panel )
    e_class_selector_lbl:SetDark( 1 )
    e_class_selector_lbl:SetPos( 15, 15)
    e_class_selector_lbl:SetText( "Class:" )

    local e_class_selector_parent = vgui.Create( "DPanel", ents_inf_panel )
    e_class_selector_parent:SetPos( 15, 35 )
    e_class_selector_parent:SetSize( 200, 25 )

    -- TODO: this needs to be a dropdown menu with all the classnames, idk how
    local e_class_selector_edit = vgui.Create( "DTextEntry", e_class_selector_parent )
    e_class_selector_edit:SetText( className )
    e_class_selector_edit:SetPlaceholderText( "Entity class name" )
    e_class_selector_edit:Dock( TOP )
	e_class_selector_edit:DockMargin( 0, 5, 0, 0 )

    -- keyvalue editor
    local e_keys_lbl = vgui.Create( "DLabel", ents_inf_panel )
    e_keys_lbl:SetDark( 1 )
    e_keys_lbl:SetPos( 15, 80 )
    e_keys_lbl:SetText( "Keyvalues:" )

    local e_keys_parent = vgui.Create( "DPanel", ents_inf_panel )
    e_keys_parent:SetPos( 15, 115 )
    e_keys_parent:SetSize( 600, 700 )

    local e_keys_list = vgui.Create( "DListView", e_keys_parent )
    e_keys_list:Dock( FILL )
    e_keys_list:SetMultiSelect( false )
    e_keys_list:AddColumn( "Key" )
    e_keys_list:AddColumn( "Value" )

    local keys_indx_lookup = {}

    -- manual keyvalue list order override:
    local e_override_keys_list = {}
    e_override_keys_list["classname"] = true -- this is handled already, so we don't need to add it here

    e_keys_list:AddLine( "Name", keys["targetname"] )
    e_override_keys_list["targetname"] = true
    keys_indx_lookup[1] = "targetname"

    e_keys_list:AddLine( "Pitch Yaw Roll (Y Z X)", keys["angle"] )
    e_override_keys_list["angle"] = true
    keys_indx_lookup[2] = "angle"

    -- if the entity has a model, override it to the top of the list
    if keys["model"] then
        e_keys_list:AddLine( "Model", keys["model"] )
        e_override_keys_list["model"] = true
        keys_indx_lookup[3] = "model"
    end

    local temp_v = {}
    local count = size(e_override_keys_list)
    print(count)
    for k, v in pairs(keys) do -- loop through the key values, if the key is in the override ignore it, else add to list
        if e_override_keys_list[k] == nil then
            if keys_lookup_table[k] ~= nil then
                temp_v = v
                if keys_lookup_table[k].type == "choices" then
                    temp_v = keys_lookup_table[k].choices[v]
                end
                e_keys_list:AddLine( keys_lookup_table[k].title, temp_v )
            else
                e_keys_list:AddLine( k, v )
            end
            keys_indx_lookup[count] = k
            count = count + 1
        end
    end

    local e_edit_box_parent = vgui.Create( "DPanel", ents_inf_panel )
    e_edit_box_parent:SetPos( 635, 80 )
    e_edit_box_parent:SetSize( 300, 40 )
    e_edit_box_parent:SetPaintBackground( false )

    local e_edit_box_lbl = vgui.Create( "DLabel", e_edit_box_parent )
    e_edit_box_lbl:SetDark( 1 )
    e_edit_box_lbl:SetText( "Keyvalue name (data type):" )
    e_edit_box_lbl:Dock( TOP )

    local e_edit_box = vgui.Create( "DTextEntry", e_edit_box_parent )
    e_edit_box:SetText( "" )
    e_edit_box:SetPlaceholderText( "Default value" )
    e_edit_box:Dock( FILL )

    local e_description_parent = vgui.Create( "DPanel", ents_inf_panel )
    e_description_parent:SetPos( 635, 170 )
    e_description_parent:SetSize( 300, 300 )
    e_description_parent:SetPaintBackground( false )
    
    local e_description_lbl = vgui.Create( "DLabel", e_description_parent )
    e_description_lbl:SetDark( 1 )
    e_description_lbl:SetText( "Description:" )
    e_description_lbl:Dock( TOP )

    local e_description_text = vgui.Create( "DTextEntry", e_description_parent )
    e_description_text:SetText( ent_fgds_data.description )
    e_description_text:SetMultiline( true )
    e_description_text:Dock( FILL )
    e_description_text:SetEditable( false )
    e_description_text.AllowInput = function( self, stringValue )
        return false
    end

    e_keys_list.OnRowSelected = function( Panel, rowIndex )
        local temp = keys_lookup_table[keys_indx_lookup[rowIndex]]
        if temp == nil then
            if keys_lookup_table[string.lower(keys_indx_lookup[rowIndex])] == nil then
                e_description_text:SetText( "No decription found" ) 
                e_edit_box_lbl:SetText( keys_indx_lookup[rowIndex] .. " (unknown type):" )
                e_edit_box:SetPlaceholderText( "Default value" )
                return
            else
                temp = keys_lookup_table[string.lower(keys_indx_lookup[rowIndex])]
            end
        end

        if temp.description ~= nil then
            e_description_text:SetText( temp.description )
        else 
            e_description_text:SetText( "No decription found" )
        end

        e_edit_box_lbl:SetText( temp.title .. " (" .. temp.type .. "):" )
        print(temp.deflt)
        e_edit_box:SetPlaceholderText( tostring(temp.deflt) )
    end


end

--[[ Set up net messages:

    Client needs to recieve when to create the gui.

    Client needs to send keyvalues when we want to change the entity.

    Client also sends when we refresh the entity.

    All changes (except entity class change) are only applied when we hit the apply button
        to simplify the process, i do not care enough to make it more dynamic, nobody will'
        care if i do.
]]

-- SEND:

 --updateEnt: send when we want to update the entity
    -- params: ent (entity to modify), table (table of flags), table (io table), table (misc table)

-- RECIEVE
net.Receive( "startEditor", function( len, ply ) -- recieved when we need to open the gui
    local class = net.ReadString()
    local keys = net.ReadTable()          -- for now we will just send all the keyvalues, io, and flags every time
    local flags = net.ReadTable()         -- if we run into the limit ill fix it in a later version
    local io_chainlinks = net.ReadTable()
    local misc = net.ReadTable() -- this one is just other stuff like gmod properties, etc.

    -- handle start editor

    create_egui( class, keys, flags, io_chainlinks, misc )

end )