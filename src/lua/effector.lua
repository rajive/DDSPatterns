--*****************************************************************************
--*    (c) 2005-2017 Copyright, Real-Time Innovations, All rights reserved.   *
--*                                                                           *
--*         Permission to modify and use for internal purposes granted.       *
--* This software is provided "as is", without warranty, express or implied.  *
--*                                                                           *
--*****************************************************************************
-- Created: Rajive Joshi, 2017 May 01  

-- initialization (global state preserved across invocations)  
if CONTAINER.CONTEXT.onStartEvent then
  tick         = 1
  xtypes       = require('xtypes')
  
  ShapeType         = CONTAINER.TYPES.ShapeType
  ShapeType_utils   = CONTAINER.UTILS.ShapeType
  
  -- Inputs
  ProposedRequestReader = CONTAINER.READER['Subscriber::ProposedRequestReader']
  CurrentStateReader    = CONTAINER.READER['Subscriber::CurrentStateReader']
  
  -- Outputs
  AcceptedRequestWriter = CONTAINER.WRITER['Publisher::AcceptedRequestWriter']
  CurrentStateWriter    = CONTAINER.WRITER['Publisher::CurrentStateWriter']
  
  
  --- MyCurrentState : at most one per entity (color)
  my_current_state = {} -- { color : { ShapeType_Instance } }
end

--------------------------------------------------------------------------------
-- Sample Inputs
--------------------------------------------------------------------------------

ProposedRequestReader:take()

-- print statistics if there is any input
if #ProposedRequestReader.samples > 0 then
  print("--------------------- Effector State Machine ---------------------")
  print("---", tick, 
        "#proposed", #ProposedRequestReader.samples, 
        "---")
  tick = tick + 1
end

--------------------------------------------------------------------------------
-- Effector State Machine
--------------------------------------------------------------------------------

-- ***Awaiting Request*** --

for i, proposed_request in ipairs(ProposedRequestReader.samples) do
  
  local entity = proposed_request[ShapeType.color]

  if ProposedRequestReader.infos[i].valid_data then

    -- discard older requests (those with an older timestamp)
    -- NOTE: In Connext DDS (Professional), used for this example, this can be 
    --       achieved simply by setting the DESTINATION_ORDER QoS Policy 
    --       to BY_SOURCE_TIMESTAMP.
    --     
    --       Since we got here, it must be newer request!

    -- newer request: write request on "Accepted" topic
    ShapeType_utils.copy_storage(AcceptedRequestWriter.instance, proposed_request)
    AcceptedRequestWriter:write()


    -- ***Accepted Request*** ---
    print("Accepted Request", entity)
    ShapeType_utils.print_storage(AcceptedRequestWriter.instance)


    -- process request: "physical activity"
    if not my_current_state[entity] then my_current_state[entity] = {} end
    ShapeType_utils.copy_instance_from_storage(my_current_state[entity], 
                                               proposed_request)
    ShapeType_utils.copy_storage(CurrentStateWriter.instance, proposed_request)


    -- ***Processed Request*** ---
    print("Processed Request", entity)

    -- update state: write current state on "Current" topic
    CurrentStateWriter:write()

    -- ***Completed Request*** ---
    print("Completed Request", entity)


    -- finish request: unregister request on "Accepted" topic
    AcceptedRequestWriter.instance[ShapeType.color] = entity
    AcceptedRequestWriter:unregister()

  else -- no more requests OR all requesters are disconnected
    print("No Requests", entity)
  end

  -- ***Awaiting Request*** --
  print("Awaiting Request", entity)
end


-- ***Sync Replica*** --
CurrentStateReader:read()
for i, current_state in ipairs(CurrentStateReader.samples) do
  if CurrentStateReader.infos[i].valid_data then
  
    local entity = current_state[ShapeType.color]
    
    -- NOTE: could check for state divergence here
    
    if not my_current_state[entity] then my_current_state[entity] = {} end
    ShapeType_utils.copy_instance_from_storage(my_current_state[entity], 
                                               current_state)
  end
end

--------------------------------------------------------------------------------
-- My Current State
--------------------------------------------------------------------------------
print("\n--- My Current State", #CurrentStateReader.samples, "---")
for color, state in pairs(my_current_state) do
  print(color)
  ShapeType_utils.print_instance(state)
end
--------------------------------------------------------------------------------