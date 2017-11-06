if(NOT DEFINED DEFAULT_C_FLAGS_SET OR RESET_FLAGS)

  # custom flags are defined by setup --custom-cc-flags
  if(DEFINED CUSTOM_C_FLAGS)
    # set custom compiler flags (for every build type)
    set(CMAKE_C_FLAGS "${CUSTOM_C_FLAGS}")
    # special flags for build types will be empty
    set(CMAKE_C_FLAGS_DEBUG "")
    set(CMAKE_C_FLAGS_RELEASE "")
  else()
    # custom flags are not defined
    if(CMAKE_C_COMPILER_ID MATCHES GNU)
      set(CMAKE_C_FLAGS "-Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith -Wno-uninitialized -Wreturn-type -Wcast-qual -Wpointer-arith -Wwrite-strings -Wswitch -Wshadow")
      set(CMAKE_C_FLAGS_DEBUG   "-O0 -g3")
      set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
      set(CMAKE_C_FLAGS_RELEASE "-O3")
    else()
      message(FATAL_ERROR "Your C compiler is not supported")
    endif() # GNU
  endif() # CUSTOM_CFLAGS
endif() # NOT DEFAULT_C_FLAGS_SET OR ..