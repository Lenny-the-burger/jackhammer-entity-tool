-- time to parse the giant json files yipee!!!
local json_files, json_dirs = file.Find("addons/jackhammer_entity_tool/json/*.json", "GAME")

local ents_fgds_data = {} -- master table of all entity data

for k, v in ipairs(json_files) do
    local json_file = util.JSONToTable(file.Read("addons/jackhammer_entity_tool/json/" .. v, "GAME"))
    ents_fgds_data[v] = json_file.entities -- we deont need the includes
end

--[[ Example code to loop through all the entities in the json files and find "env_fire"

for k, v in pairs(ents_fgs_data) do
        for k2, v2 in pairs(v) do
            if v2.name == "env_fire" then PrintTable(v2, 0) end
        end
    end

]]

local function create_egui( className, keys, flags, io, misc )
    -- before we do anything, get all the entity fgs data needed

    local ent_fgds_data = {}
    for k, v in pairs(ents_fgds_data) do
        for k2, v2 in pairs(v) do
            if v2.name == className then ent_fgds_data = v2 end
        end
    end

    if ent_fgds_data.name == nil then 
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

    -- loop through the properties and create a keys_lookup_table where there is name:{title, type, description}
    -- this is so we dnt have to loop every time a row is selecetd in the table
    -- remember that since things inherit from each other we also need to recursisvly loop through
    -- the properties of the parent classes which can be found in the base parameter of the class
    -- to get the full list of properties!!!
    local keys_lookup_table = {}
    local function recursive_get_loop( tbl )
        -- first look at base parameter if it exists, and lookup every class recursivly
        -- once we get to maximum depth, we collapse the table together and keep going
        -- TODO: redo how entity fgd data is held so we can lookup ents without a need to loop through a giant table
    end
    recursive_get_loop(ent_fgds_data.properties)


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

    -- manual keyvalue list order override:
    local e_override_keys_list = {}
    e_override_keys_list["classname"] = true -- this is handled already, so we don't need to add it here

    e_keys_list:AddLine( "Name", keys["targetname"] )
    e_override_keys_list["targetname"] = true

    e_keys_list:AddLine( "Pitch Yaw Roll (Y Z X)", keys["angle"] )
    e_override_keys_list["angle"] = true

    -- if the entity has a model, override it to the top of the list
    if keys["model"] then
        e_keys_list:AddLine( "Model", keys["model"] )
        e_override_keys_list["model"] = true
    end

    for k, v in pairs(keys) do -- loop through the key values, if the key is in the override ignore it, else add to list
        if e_override_keys_list[k] == nil then
            e_keys_list:AddLine( keys_lookup_table[k].title, v )
        end
    end

    local e_description_text_actual = ent_fgds_data.description

    e_keys_list.OnRowSelected = function( panel, rowIndex, row )
        local key = row:GetValue( 1 )
        local val = row:GetValue( 2 )
    end

    local e_description_parent = vgui.Create( "DPanel", ents_inf_panel )
    e_description_parent:SetPos( 635, 250 )
    e_description_parent:SetSize( 300, 300 )
    e_description_parent:SetPaintBackground( false )
    
    local e_description_lbl = vgui.Create( "DLabel", e_description_parent )
    e_description_lbl:SetDark( 1 )
    e_description_lbl:SetText( "Description:" )
    e_description_lbl:Dock( TOP )

    local e_description_text = vgui.Create( "DTextEntry", e_description_parent )
    e_description_text:SetText( e_description_text_actual )
    e_description_text:SetMultiline( true )
    e_description_text:Dock( FILL )
    e_description_text:SetEditable( false )
    e_description_text.AllowInput = function( self, stringValue )
        return false
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