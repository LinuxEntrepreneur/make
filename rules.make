#
#   rules.make
#
#   All of the common makefile rules.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Don't reload all the rules if already loaded
ifneq ($(RULES_LOADED),yes)
RULES_LOADED := yes

ALL_CPPFLAGS = $(CPPFLAGS) $(ADDITIONAL_CPPFLAGS)

ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   -I$(GNUSTEP_TARGET_HEADERS) -I$(GNUSTEP_HEADERS)

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   -I$(GNUSTEP_TARGET_HEADERS) -I$(GNUSTEP_HEADERS) 

ALL_LDFLAGS = $(ADDITIONAL_LDFLAGS) $(GUI_LDFLAGS) $(FND_LDFLAGS) \
   $(BACKEND_LDFLAGS) $(SYSTEM_LDFLAGS) $(INTERNAL_LDFLAGS)

ALL_LIB_DIRS = $(ADDITIONAL_LIB_DIRS) -L$(GNUSTEP_LIBRARIES) \
   -L$(GNUSTEP_TARGET_LIBRARIES) $(SYSTEM_LIB_DIR)

ALL_TOOL_LIBS = $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) $(FND_LIBS) \
   $(OBJC_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_GUI_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(BACKEND_LIBS) \
   $(GUI_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

LIB_DIRS_NO_SYSTEM = $(ADDITIONAL_LIB_DIRS) -L$(GNUSTEP_LIBRARIES) \
   -L$(GNUSTEP_TARGET_LIBRARIES)

ALL_TOOL_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TOOL_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ALL_GUI_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_GUI_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

LIBRARIES_DEPEND_UPON := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(LIBRARIES_DEPEND_UPON)\
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

VPATH = .

.SUFFIXES: .m .c .psw

.PRECIOUS: %.c %.h $(GNUSTEP_OBJ_DIR)/%${OEXT}

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.c
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@ $<

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.m
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@ $<

%.c : %.psw
	pswrap -h $*.h -o $@ $<

# The magical app rule, thank you GNU make!
%.buildapp:
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-all \
		  INTERNAL_APP_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  RESOURCE_FILES="$($*_RESOURCES)" \
		  RESOURCE_DIRS="$($*_RESOURCE_DIRS)"

%.buildtool : FORCE
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-tool-all \
		  TOOL_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)"

#
# The bundle extension (default is .bundle) is defined by BUNDLE_EXTENSION.
#
ifeq ($(strip $(BUNDLE_EXTENSION)),)
BUNDLE_EXTENSION = .bundle
endif

%$(BUNDLE_EXTENSION) : FORCE
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-bundle-all \
		  BUNDLE_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  RESOURCE_FILES="$($*_RESOURCES)" \
		  RESOURCE_DIRS="$($*_RESOURCE_DIRS)" \
		  BUNDLE_LIBS="$($*_BUNDLE_LIBS)"

#
# Testing rules
#

# These are for compiling
ALL_TEST_LIBRARY_LIBS = $(ADDITIONAL_LIBRARY_LIBS) $(AUXILIARY_LIBS) \
    -lobjc-test \
    $(AUXILIARY_TOOL_LIBS) $(FND_LIBS) $(OBJC_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_TEST_BUNDLE_LIBS = $(ADDITIONAL_BUNDLE_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(OBJC_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_TEST_TOOL_LIBS = $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(OBJC_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_TEST_GUI_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) \
   $(BACKEND_LIBS) $(GUI_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_TEST_LIBRARY_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TEST_LIBRARY_LIBS)\
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ALL_TEST_BUNDLE_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TEST_BUNDLE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ALL_TEST_TOOL_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TEST_TOOL_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ALL_TEST_GUI_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TEST_GUI_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

%.testlib : FORCE
	@echo Making $*...
	$(MAKE) --no-print-directory internal-testlib-all \
		  TEST_LIBRARY_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  ADDITIONAL_INCLUDE_DIRS="$($*_INCLUDE_DIRS)" \
		  ADDITIONAL_LIBRARY_LIBS="$($*_LIBS)" \
		  ADDITIONAL_LIB_DIRS="$($*_LIB_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.testbundle : FORCE
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-testbundle-all \
		  TEST_BUNDLE_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  RESOURCE_FILES="$($*_RESOURCES)" \
		  RESOURCE_DIRS="$($*_RESOURCE_DIRS)" \
		  ADDITIONAL_INCLUDE_DIRS="$($*_INCLUDE_DIRS)" \
		  ADDITIONAL_BUNDLE_LIBS="$($*_LIBS)" \
		  ADDITIONAL_LIB_DIRS="$($*_LIB_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.testtool : FORCE
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-testtool-all \
		  TEST_TOOL_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  ADDITIONAL_INCLUDE_DIRS="$($*_INCLUDE_DIRS)" \
		  ADDITIONAL_TOOL_LIBS="$($*_LIBS)" \
		  ADDITIONAL_LIB_DIRS="$($*_LIB_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.testapp : FORCE
	@echo Making $*...
	@$(MAKE) --no-print-directory internal-testapp-all \
		  TEST_APP_NAME=$* \
		  OBJC_FILES="$($*_OBJC_FILES)" \
		  C_FILES="$($*_C_FILES)" \
		  PSWRAP_FILES="$($*_PSWRAP_FILES)" \
		  RESOURCE_FILES="$($*_RESOURCES)" \
		  RESOURCE_DIRS="$($*_RESOURCE_DIRS)" \
		  ADDITIONAL_INCLUDE_DIRS="$($*_INCLUDE_DIRS)" \
		  ADDITIONAL_GUI_LIBS="$($*_LIBS)" \
		  ADDITIONAL_LIB_DIRS="$($*_LIB_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

# These are for running the tests

%.checklib : FORCE
	@echo Checking $*...
	$(MAKE) --no-print-directory internal-check-LIBRARY \
		  TEST_LIBRARY_NAME=$* \
		  ADDITIONAL_LD_LIB_DIRS="$($*_LD_LIB_DIRS)" \
		  CHECK_SCRIPT_DIRS="$($*_SCRIPT_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.checkbundle : FORCE
	@echo Checking $*...
	$(MAKE) --no-print-directory internal-check-BUNDLE \
		  TEST_BUNDLE_NAME=$* \
		  ADDITIONAL_LD_LIB_DIRS="$($*_LD_LIB_DIRS)" \
		  CHECK_SCRIPT_DIRS="$($*_SCRIPT_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.checktool : FORCE
	@echo Checking $*...
	$(MAKE) --no-print-directory internal-check-TOOL \
		  TEST_TOOL_NAME=$* \
		  ADDITIONAL_LD_LIB_DIRS="$($*_LD_LIB_DIRS)" \
		  CHECK_SCRIPT_DIRS="$($*_SCRIPT_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

%.checkapp : FORCE
	@echo Checking $*...
	$(MAKE) --no-print-directory internal-check-APP \
		  TEST_APP_NAME=$* \
		  ADDITIONAL_LD_LIB_DIRS="$($*_LD_LIB_DIRS)" \
		  CHECK_SCRIPT_DIRS="$($*_SCRIPT_DIRS)" \
		  SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)"

#
# The list of Objective-C source files to be compiled
# are in the OBJC_FILES variable.
#
# The list of C source files to be compiled
# are in the C_FILES variable.
#
# The list of PSWRAP source files to be compiled
# are in the PSWRAP_FILES variable.

OBJC_OBJS = $(OBJC_FILES:.m=${OEXT})
OBJC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(OBJC_OBJS))

PSWRAP_C_FILES = $(PSWRAP_FILES:.psw=.c)
PSWRAP_H_FILES = $(PSWRAP_FILES:.psw=.h)
PSWRAP_OBJS = $(PSWRAP_FILES:.psw=${OEXT})
PSWRAP_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(PSWRAP_OBJS))

C_OBJS = $(C_FILES:.c=${OEXT})
C_OBJ_FILES = $(PSWRAP_OBJ_FILES) $(addprefix $(GNUSTEP_OBJ_DIR)/,$(C_OBJS))

#
# Global targets
#
all:: before-all internal-all after-all

install:: before-install internal-install after-install

uninstall:: before-uninstall internal-uninstall after-uninstall

clean:: before-clean internal-clean after-clean

distclean:: before-distclean internal-distclean after-distclean

check:: before-check internal-check after-check

# The rule to create the objects file directory
$(GNUSTEP_OBJ_DIR):
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs ./$(GNUSTEP_OBJ_DIR)

#
# Placeholders for internal targets
#

before-all::

internal-all::

after-all::

before-install::

internal-install::

after-install::

before-uninstall::

internal-uninstall::

after-uninstall::

before-clean::

internal-clean::
	rm -f *~

after-clean::

before-distclean::

internal-distclean::

after-distclean::

before-check::

internal-check::

after-check::

FORCE:

# Rules loaded
endif
