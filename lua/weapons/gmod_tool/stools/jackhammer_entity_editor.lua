TOOL.Category = "Construction"
TOOL.Name = "Jackhammer entity editor"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

-- If the classname is changed in the editor an entity refresh is needed to update the entity.
function TOOL:LeftClick( trace )
    local ent = trace.Entity
	if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end
	if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn
	if ( CLIENT ) then return true end

    -- use net messages to send information about the entity to the client:
    -- 1. the entity's class
    -- 2. the entity's keyvalues
    -- 3. check for the entity's io chainlinks in the 
    
    return true

end

-- If origin and destination entities are different class this will require
-- entity refresh.
function TOOL:RightClick( trace )
    local ent = trace.Entity
	if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end
	if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn
	if ( CLIENT ) then return true end
    
    return true
end

-- Creates a new entity from scratch, just save the location of the trace and
-- tell the client to open the editor with forced entity refresh.
function TOOL:Reload( trace )


    return true
end

if (CLIENT) then
	language.Add("tool.jackhammer_entity_editor.name", "Jackhammer entity editor");
	language.Add("tool.jackhammer_entity_editor.left", "Select and edit entity");
	language.Add("tool.jackhammer_entity_editor.right", "Copy entity");
    language.Add("tool.jackhammer_entity_editor.reload", "Create entity from scratch");
	language.Add("tool.jackhammer_entity_editor.desc", "Edit any properties of any entity");
end

-- function to add a io chainlink to the entity
function AddIOChainlink( id, io )
    --[[
        1. check if the main chainlink table (JEE_IO_CHAINLINKS) already has an entry for the id
        2. if it does, add the io to the table
        3. if it doesn't, create a new entry in the table with the given io

        entries should follow this format:

        {
        ent_id:
            inputs:
                {chainlink entry, chainlink entry, etc}
            outputs:
                {chainlink entry, chainlink entry, etc}
        }

        io is a table with the following structure:
        {
            outputName:"output name",           -- the name of the output
            targetName:"target name",           -- the targetname of the entities we affect
            targetInput:"target input",         -- the input we trigger on the target entity
            paramOverride:"param override"      -- paramater override for the target input
            fireDelay:"fire delay"              -- fire delay for the target input
            fireTimes:"fire times"              -- fire times for the target input (-1, 0 is infinite)
        }

    ]]

    if ( !JEE_IO_CHAINLINKS[ id ] ) then
        JEE_IO_CHAINLINKS[ id ] = {
            inputs = {},
            outputs = {}
        }
    end

    -- when we add a new input the given entity will always be the source entity
    table.insert(JEE_IO_CHAINLINKS_IDS[ id ].outputs, io)
    table.insert(JEE_IO_CHAINLINKS_TRG[ io.targetName ].inputs, io)

end