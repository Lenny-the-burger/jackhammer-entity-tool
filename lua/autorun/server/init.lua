-- init the entity tables:
-- the io chainlinks table, as we can't get the io chainlinks from the entity thx gmod :/


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
util.AddNetworkString( "startEditor" ) -- sent when we open the editor to tell the client to open it
    -- params: string (entity class), table (keyvalues), table (flags), table (io), table (io), table (misc)

-- RECIEVE
net.Receive( "updateEnt", function( len, ply ) -- recieved when we update an entity from the client
    local ent = net.ReadEntity()
    local keys = net.ReadTable()          -- for now we will just send all the keyvalues, io, and flags every time
    local flags = net.ReadTable()         -- if we run into the limit ill fix it in a later version
    local io_chainlinks = net.ReadTable()
    local misc = net.ReadTable() -- this one is just other stuff like gmod properties, etc.

    -- im not a monster so client only sends one copy of the io, server figures out which targetnames are affected

    -- handle update

end )

net.Receive( "refreshEnt", function( len, ply ) -- recieved when we need to refresh an entity from the client
    local newPos = net.ReadVector()
    local newClass = net.ReadString()

    -- handle refresh, just create the newClass entity with default keyvalues
    -- we keep the io but discard the keyvalues except targetname which gets carried over

end )