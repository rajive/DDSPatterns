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
  AcceptedRequestReader = CONTAINER.READER['Subscriber::AcceptedRequestReader']
  CommandReader = CONTAINER.READER['CommandSubscriber::CommandReader']
  
  -- Outputs
  ProposedRequestWriter = CONTAINER.WRITER['Publisher::ProposedRequestWriter']
  
  --- Proposed Requests: at most one request pending per entity (color)
  proposed_requests = {} -- { color : { ShapeType_Instance } }
end

--------------------------------------------------------------------------------
-- Sample Inputs
--------------------------------------------------------------------------------

CommandReader:take()
AcceptedRequestReader:take()

-- print statistics if there is any input
if #CommandReader.samples > 0 or  #AcceptedRequestReader.samples > 0 then
  print("--------------------- Requester State Machine ---------------------")
  print("---", tick, 
    "#commands", #CommandReader.samples, 
    "#accepted", #AcceptedRequestReader.samples,
    "---")
  tick = tick + 1
end

--------------------------------------------------------------------------------
-- Requester State Machine
--------------------------------------------------------------------------------

-- ***Awaiting Acceptance*** --

for i, accepted_request in ipairs(AcceptedRequestReader.samples) do

  local entity = accepted_request[ShapeType.color]
  
  -- do we an outstanding request for this entity?
  --       No! => Skip
  if proposed_requests[entity] then

    -- entity appeared in “Accepted” reader’s view

    -- ***Reviewing Accepted Requests*** --
    print("Reviewing Accepted Requests", entity)
    local is_completed = false
    
    if (AcceptedRequestReader.infos[i].valid_data) then  

      -- accepted our request?
      if ShapeType_utils.is_equal_instance_storage(proposed_requests[entity],
                                                   accepted_request) 
      then  
        print(" -> accepted our request", entity)
        ShapeType_utils.print_storage(accepted_request)
        is_completed = true
      end

    else -- NOT_ALIVE_NO_WRITERS  
      print(" -> NOT_ALIVE_NO_WRITERS", entity)
      -- is_completed = true
    end
      
    -- completed: unregister() entity on “Proposed” topic 
    if is_completed then
        ShapeType_utils.copy_storage_from_instance(ProposedRequestWriter.instance,
                                                   proposed_requests[entity])
        ProposedRequestWriter:unregister()
        
        proposed_requests[entity] = nil
   
        -- ***No Requests*** 
        print("No Requests", entity)      
            
    else
      print(" -> not our request", entity)
      
      -- ***Awaiting Acceptance*** --
      print("Awaiting Acceptance", entity)
    end
  end
end



-- ***No Requests*** -- or -- ***Awaiting Acceptance*** --

--     Process External "Joystick" Command Inputs
for i, command in ipairs(CommandReader.samples) do

  local entity = command[ShapeType.color]
  
  if (CommandReader.infos[i].valid_data) then
    
    -- update request
    if proposed_requests[entity] then -- already have a proposed request
      print(" -> update request", entity)
      
    else -- new request
      print(" -> new request", entity)
      proposed_requests[entity] = {}
    end
        
    ShapeType_utils.copy_instance_from_storage(proposed_requests[entity], command)
    
    ShapeType_utils.copy_storage_from_instance(ProposedRequestWriter.instance,
                                               proposed_requests[entity])
    ProposedRequestWriter:write()
    
    ShapeType_utils.print_storage(ProposedRequestWriter.instance)
  
    -- ***Awaiting Acceptance*** --
    print("Awaiting Acceptance", entity)
  
  else -- clear request
  
    if proposed_requests[entity] then
          
      -- clear request: unregister() entity on “Proposed” topic
      ShapeType_utils.copy_storage_from_instance(ProposedRequestWriter.instance,
                                               proposed_requests[entity])
      ProposedRequestWriter:unregister()
     
      print(" -> clear request", entity) 
      proposed_requests[entity] = nil
      
      -- ***No Requests*** 
      print("No Requests", entity)
    end
  end  
end

-- At this point 'proposed_requests' table holds the command inputs per entity

--------------------------------------------------------------------------------
