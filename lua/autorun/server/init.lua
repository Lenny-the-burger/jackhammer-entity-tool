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