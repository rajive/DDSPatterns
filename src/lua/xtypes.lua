--*****************************************************************************
--*    (c) 2005-2016 Copyright, Real-Time Innovations, All rights reserved.   *
--*                                                                           *
--*         Permission to modify and use for internal purposes granted.       *
--* This software is provided "as is", without warranty, express or implied.  *
--*                                                                           *
--*****************************************************************************
-- Created: Rajive Joshi, 2016 Jan 21  

-- Load DDSL to work with X-Types in Lua
local xtypes       = require('ddsl.xtypes')
xtypes.xml         = require('ddsl.xtypes.xml')
xtypes.utils       = require('ddsl.xtypes.utils')
xtypes.gen         = require('ddslgen.generator')
  
--------------------------------------------------------------------------------
-- Types --
--------------------------------------------------------------------------------
 
CONTAINER.TYPES = xtypes.xml.filelist2xtypes{'ShapeType.xml'}
local idl = xtypes.utils.to_idl_string_table(CONTAINER.TYPES, {'datatypes:'})
print(table.concat(idl, '\n\t'))

CONTAINER.UTILS = {
  ShapeType = {}
}

--------------------------------------------------------------------------------
-- ShapeType Utils --
--------------------------------------------------------------------------------

local ShapeType_utils = CONTAINER.UTILS.ShapeType

-- define a copy method for ShapeType instances
ShapeType_utils.copy_instance = function (to_instance, from_instance)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for role, _ in pairs(ShapeType) do
    to_instance[role] = from_instance[role]
  end
end

-- define a copy method for ShapeType instances from storage
ShapeType_utils.copy_instance_from_storage = function (to_instance, from_storage)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for role, storage_index in pairs(ShapeType) do
    to_instance[role] = from_storage[storage_index]
  end
end

-- define a copy method for ShapeType storage from instances
ShapeType_utils.copy_storage_from_instance = function (to_storage, from_instance)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for role, storage_index in pairs(ShapeType) do
    to_storage[storage_index] = from_instance[role]
  end
end

-- define a copy method for ShapeType storage
ShapeType_utils.copy_storage = function (to_storage, from_storage)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for role, storage_index in pairs(ShapeType) do
    to_storage[storage_index] = from_storage[storage_index]
  end
end

-- define a print method for ShapeType instance
ShapeType_utils.print_instance = function (instance)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for i = 1, #ShapeType do
   local role, _ = next(ShapeType[i])
    print("\t", instance[role])
  end
end

-- define a print method for ShapeType storage
ShapeType_utils.print_storage = function (storage)
  local ShapeType = CONTAINER.TYPES.ShapeType
  for i = 1, #ShapeType do
   local role, _ = next(ShapeType[i])
    print("\t", storage[ShapeType[role]])
  end
end

-- are two storage values equal?
ShapeType_utils.is_equal_storage = function (storage1, storage2)
  local ShapeType = CONTAINER.TYPES.ShapeType
  local is_equal = true
  for role, storage_index in pairs(ShapeType) do
    if storage1[storage_index] ~= storage2[storage_index] then
      is_equal = false
      break
    end
  end
  -- print("is_equal", is_equal)
  -- ShapeType_utils.print_storage(storage1)
  -- ShapeType_utils.print_storage(storage2)
  return is_equal
end

-- is the instance value equal to the storage value?
ShapeType_utils.is_equal_instance_storage = function (instance, storage)
  local ShapeType = CONTAINER.TYPES.ShapeType
  local is_equal = true
  for role, storage_index in pairs(ShapeType) do
    if instance[role] ~= storage[storage_index] then
      is_equal = false
      break
    end
  end
  -- print("is_equal", is_equal)
  -- ShapeType_utils.print_instance(instance)
  -- ShapeType_utils.print_storage(storage)
  return is_equal
end

--------------------------------------------------------------------------------

return xtypes
