# Summary

- [Objective State](#objective-state)

# Building

Ensure that NDDSHOME is defined

- On Unix, for example:

    export NDDSHOME=/opt/rti/NDDSHOME  # path to RTI Connext Installation
    
Change to the working directory:
	
			cd build/

Build all the application components:

			make
			
Build a specific application component <app>:
  
            make <app>

		
Cleanup (the build/ directory):

			make clean
    
# Running 

## Lua Apps

Open a terminal window for an application component and run the <app>
  
           make run/lua/<app>
      		
## RTI Connext Tools
      
Open a 'rtiddspy' window on domain N
 
    		make run/spyN
    
    
Launch the **RTI Admin Console**

  - view the system configuration 
   
  - subscribe to topics on interest
 
 
# Patterns

## Objective State

Effector
- run as many as you want

      make run/lua/effector
      
- kill as many as you want
- as long as one is up and running, the Current State is always available

Requester
- requester.xml: change minimum separation to throttle speed
  - default = 1 sec; to observe the state machine slow down to 10+sec
- For each requester, pick a partition
- Run a requester, e.g. for partition "A":

      make PARTITION=A run/lua/requester

- Run another requester, e.g. for partition "B":

      make PARTITION=B run/lua/requester
      
- Run as many requesters as you want
  - Shapes Demo easily allows 4 partitions out-of-the-box: A, B, C, D


Shapes Demo: Current State
- Subscribe to Triangle: EXCLUSIVE, TRANSIENT_LOCAL, RELIABLE, 
					     HISTORY depth = 1
- Start as may of these as you want (at least 2)
  - all should show the same (consistent) state

Shapes Demo: Proposed and Accepted Topics
- Subscribe to Square: EXCLUSIVE, TRANSIENT_LOCAL, RELIABLE, 
					   HISTORY depth = #requesters
- Subscribe to Circle: SHARED, TRANSIENT_LOCAL, RELIABLE, 
					   HISTORY depth = #requesters x #effectors
					   
Shapes Demo Command Input x #requesters
- For each requester launch a Shapes Demo
    - pick a partition  (A, B, C, D) and size for it
      - vary size to distinguish different command inputs for same color
- Publish Square on that partition with the selected size
- Demo Scenarios
   - put a shape in each corner; if colors are same for two, should see 
     bouncing between them symmetrically in a predictable pattern
   - add new colors as desired (vary the size on different partitions)

					   
     
# File Organization

## Purpose

A suggested directory structure for organizing a data-centric distributed
system architecture.

The component interfaces, common services, and application components are 
organized according to the following directory structure to maximize openness
and system evolution overtime. 

The scheme is intended to support multiple versions if interfaces, components, 
and launch configurations.

## Organization

- `dm/` : the data models repository (organization wide or public)
     - `types/` : the datatype definitions 
        - `.idl` : IDL files
        - `.xml` : XML files
     - `qos/` : the qos profiles    
            
- `if/` : the project data-oriented component interfaces
     - `domains/` : the data domains organized into topics 
         - domain id not hardcoded
            - e.g. `ShapeDomain/` : the topics in ShapeDomain
     - `participants/` : the data-oriented interfaces 
     
- `svc/` : the project configurations for common services
    - `ps/`  : persistence service configurations
    - `rs/`  : routing service configurations  
    - `qs/`  : queuing service configurations 
    - `rec/` : recording service configurations 
    - `rep/` : replay service configurations 
    - `db/`  : database integration service configurations
    - `web/` : web integration service configurations  
    :
      
- `src/` : project source code for applications a.k.a components
    - `lua/` : apps in lua
       - e.g. `ChatApp/` : the Chat app in Lua
    - `cpp/` : apps in lua
       - e.g. `ChatApp/` : the Chat app in Java
    - `java/` : apps in lua
       - e.g. `ChatApp/` : the Chat app in Java


	App/ : an application component 'launcher' working directory
	 - Has a local `USER_QOS_PROFILES.xml` for application specific 
	   initialization or overrides
	 - application specific 'properties' can be initialized here 
	   via property qos
	 - Working directory, so that each component can have a 
	   separate `USER_QOS_PROFILES.xml`
	 - Multiple components can implement the same interface
	 
- `run/` : scripts to deploy and run apps and services in the correct sandbox
    - `run_X/` : launch configuration X

	 Scripted in Lua, to support all the platforms using a single set of scripts
	  - Download lua from lua.org
	  - OR used the lua shipped with NDDS

-------------------------------------------------------------------------------



 
 