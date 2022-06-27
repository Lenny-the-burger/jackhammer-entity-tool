-- init the entity tables:
-- the io chainlinks table, as we can't get the io chainlinks from the entity thx gmod :/


local function setSecretValues( ent, vals )
    --[[ A bunch of keyvalues are not attainable using ent:GetKeyValues() so we have to get the manually >:(
    ]]

    if vals["rendercolor32"] ~= nil then ent:SetColor(vals["rendercolor32"]) end
    if vals["disableshadows"] ~= nil then ent:SetSaveValue("EF_NOSHADOW", vals["disableshadows"]) end
    --local min, max = ent:GetCollisionBounds()
    --vals["mins"] = min
    --vals["maxs"] = max
    if vals["disablereceiveshadows"] ~= nil then ent:SetSaveValue("EF_NORECEIVESHADOW", vals["disablereceiveshadows"]) end
    if vals["nodamageforces"] ~= nil then ent:SetSaveValue("EFL_NO_DAMAGE_FORCES", vals["nodamageforces"]) end
    if vals["angle"] ~= nil then ent:SetAngles(vals["angle"]) end
    if vals["origin"] ~= nil then ent:SetPos(vals["origin"]) end
    if vals["targetname"] ~= nil then ent:SetName(vals["targetname"]) end
    if vals["model"] ~= nil then ent:SetModel(vals["model"]) end
end

--[[
    io chainlinks structure:
    - when a new output is created it is stored within the JEE_IO_CHAINLINKS_IDS table
    - it also stoed in the JEE_IO_CHAINLINKS_TRG table with the apropriate target name
    - when a new targetname is given to an entity we will run a check in the JEE_IO_CHAINLINKS_TRG table
        and see if it has an incoming link and display it.

    - if an entity is deleted we will check if the id is in the JEE_IO_CHAINLINKS_IDS table and
        if it is, we will remove it from the table.
        
]]

JEE_IO_CHAINLINKS_IDS = {}
JEE_IO_CHAINLINKS_TRG = {}


--[[ Set up net messages:

    Server needs to send keyvalues and io chainlinks to the client upon opening editor.
    Upon entity refresh needs to resend info unless we close the editor on apply? (TODO)

    Before we send we will do all the searching on the server and send that to the client, 
        this isnt made for server so who cares, this is just to make it easier to code.
]]

-- SEND
util.AddNetworkString( "jhammer_e_startEditor" ) -- sent when we open the editor to tell the client to open it
    -- params: string (entity class), table (keyvalues), table (flags), table (io), table (io), table (misc)

util.AddNetworkString( "jhammer_e_applyEdit" )

-- RECIEVE
net.Receive( "jhammer_e_updateEnt", function( len, ply ) -- recieved when we update an entity from the client
    local ent = net.ReadEntity()
    local keys = net.ReadTable()          -- for now we will just send all the keyvalues, io, and flags every time
    local flags = net.ReadTable()         -- if we run into the limit ill fix it in a later version
    local io_chainlinks = net.ReadTable()
    local misc = net.ReadTable() -- this one is just other stuff like gmod properties, etc.

    -- im not a monster so client only sends one copy of the io, server figures out which targetnames are affected

    -- handle update

end )

net.Receive( "jhammer_e_refreshEnt", function( len, ply ) -- recieved when we need to refresh an entity from the client
    local newPos = net.ReadVector()
    local newClass = net.ReadString()

    -- handle refresh, just create the newClass entity with default keyvalues
    -- we keep the io but discard the keyvalues except targetname which gets carried over

end )

net.Receive( "jhammer_e_applyEdit", function( len, ply ) -- recieved when we are done editing and apply settings
    print("apply edit")

    local ent_id = net.ReadInt(16)
    local keys = net.ReadTable()          -- for now we will just send all the keyvalues, io, and flags every time
    local flags = net.ReadTable()         -- if we run into the limit ill fix it in a later version
    local io_chainlinks = net.ReadTable()
    local misc = net.ReadTable() -- this one is just other stuff like gmod properties, etc.

    print(ent_id)
    PrintTable(keys)

    local ent_sv = Entity(ent_id)
    for k, v in pairs( keys ) do
        ent_sv:SetKeyValue( k, tostring(v) )
    end
    setSecretValues( ent_sv, keys )

end )