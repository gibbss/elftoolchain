include(SaveCompilerFlags)
include(CheckCCompilerFlag)

if(CMAKE_C_COMPILER_WORKS)
  include(CFlags)
endif()
