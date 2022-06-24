local function create_egui()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Entity editor")
    frame:SetSize(800, 700)
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
    local e_class_selector_lbl = vgui.Create( "DLabel", ents_inf_panel )
    e_class_selector_lbl:SetDark( 1 )
    e_class_selector_lbl:SetPos( 15, 15)
    e_class_selector_lbl:SetText( "Class:" )

end