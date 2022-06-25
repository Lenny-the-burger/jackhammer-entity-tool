local json = require("json")

local function create_egui( className, keys, flags, io, misc )
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
            e_keys_list:AddLine( k, v )
        end
    end

    -- time to parse the giant json files yipee!!!
    local mount_txt_file = print( file.Read( "mounted_fgds.txt", "GAME" ) )
    
    local json_file_name = ""
    print(mount_txt_file)
    --[[

    while json_file_name ~= "\n" do
        json_file_name = mount_txt_file:ReadLine()
        print(json_file_name)
    end

    mount_txt_file:Close()]]

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