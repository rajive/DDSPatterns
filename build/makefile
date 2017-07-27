#*****************************************************************************
#*    (c) 2005-2017 Copyright, Real-Time Innovations, All rights reserved.   *
#*                                                                           *
#*         Permission to modify and use for internal purposes granted.       *
#* This software is provided "as is", without warranty, express or implied.  *
#*                                                                           *
#*****************************************************************************
# Updated: Rajive Joshi, 2017 Jul 26
# Updated: Rajive Joshi, 2017 May 01
# Created: Rajive Joshi, 2016 Jan 21  

#-------------------------------------------------------------------------------
# Environment
#-------------------------------------------------------------------------------

# Check NDDSHOME:
ifndef NDDSHOME
$(error Please define NDDSHOME)
endif
$(info NDDSHOME=${NDDSHOME})

#-------------------------------------------------------------------------------
# Locations
#-------------------------------------------------------------------------------

# Data-Oriented Interfaces:
TYPE_IDL_FILES:=$(patsubst ../dm/types/%.idl,%.xml,$(wildcard ../dm/types/*.idl))
TYPE_XML_FILES:=$(patsubst ../dm/types/%.xml,%.xml,$(wildcard ../dm/types/*.xml))
QOS_XML_FILES:=$(patsubst ../dm/qos/%.xml,%.xml,$(wildcard ../dm/qos/*.xml))
DOMAIN_XML_FILES:=$(patsubst ../if/domains/%.xml,%.xml,$(wildcard ../if/domains/*.xml))
PARTICIPANT_XML_FILES:=$(patsubst ../if/participants/%.xml,%.xml,$(wildcard ../if/participants/*.xml)) 

# Applications:
SRC_LUA_FILES:=$(patsubst ../src/lua/%.lua,%.lua,$(wildcard ../src/lua/*.lua))

#-------------------------------------------------------------------------------
# Rules
#-------------------------------------------------------------------------------

BUILD_FILES:= ${TYPE_IDL_FILES} ${QOS_XML_FILES} ${DOMAIN_XML_FILES}

ALL_FILES:= ${BUILD_FILES} ${PARTICIPANT_XML_FILES} ${SRC_LUA_FILES}

build: ${BUILD_FILES}

clean:
	@echo Removing: ${BUILD_FILES}
	rm ${BUILD_FILES}
	rm -rf rticonnextdds-ddsl
	
${TYPE_IDL_FILES}: %.xml: ../dm/types/%.idl
	${NDDSHOME}/bin/rtiddsgen -I../dm/types -convertToXml -d . $< 

${TYPE_XML_FILES}: %.xml: ../dm/types/%.xml
	cp $< $@
	
${QOS_XML_FILES}: %.xml: ../dm/qos/%.xml
	cp $< $@
	
${DOMAIN_XML_FILES}: %.xml: ../if/domains/%.xml
	cp $< $@
	
	
# not used:
${PARTICIPANT_XML_FILES}: %.xml: ../if/participants/%.xml
	cp $< $@
	
${SRC_LUA_FILES}: %.lua: ../src/lua/%.lua
	cp $< $@

#-------------------------------------------------------------------------------
# NDDS_QOS_PROFILES - common to all application components
#-------------------------------------------------------------------------------

space :=
space +=
export NDDS_QOS_PROFILES:=$(subst $(space),;,${QOS_XML_FILES} ${DOMAIN_XML_FILES})
$(info NDDS_QOS_PROFILES=${NDDS_QOS_PROFILES})

#-------------------------------------------------------------------------------
# Lua - DDSL Installation
#-------------------------------------------------------------------------------

rticonnextdds-ddsl:
	git clone git@github.com:rticommunity/rticonnextdds-ddsl.git
	cd rticonnextdds-ddsl && git checkout develop && cd ..
	#ln -s ../../../../rticonnextdds-ddsl

export LUA_PATH:=\
../src/lua/?.lua;rticonnextdds-ddsl/src/?.lua;rticonnextdds-ddsl/src/?/init.lua;
$(info LUA_PATH=${LUA_PATH})

#-------------------------------------------------------------------------------
# run/lua/<app> - run lua file called <app>.lua
#-------------------------------------------------------------------------------

run/lua/%: build rticonnextdds-ddsl
	${NDDSHOME}/bin/rtiddsprototyper -cfgFile ../if/participants/$*.xml \
					                 -luaFile ../src/lua/$*.lua
			  
#-------------------------------------------------------------------------------
# run/spyN - run rtiddsspy on domain N

run/spy%:
	${NDDSHOME}/bin/rtiddsspy -domainId $* -printSample
		 		
#-------------------------------------------------------------------------------
