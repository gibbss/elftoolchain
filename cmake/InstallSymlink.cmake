# This macro can be used to install symlinks, which turns out to be
# non-trivial due to CMake version differences and limitations on how
# files can be installed when building binary packages.
#
# The rule for binary packaging is that files (including symlinks) must
# be installed with the standard CMake install() macro.
#
# The rule for non-binary packaging is that CMake 2.6 cannot install()
# symlinks, but can create the symlink at install-time via scripting.
# Though, we assume that CMake 2.6 isn't going to be used to generate
# packages because versions later than 2.8.3 are superior for that purpose.
#
#   _filepath: the absolute path to the file to symlink
#   _sympath: absolute path of the installed symlink

macro(install_symlink _filepath _sympath)
  install(CODE "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink
                                ${CMAKE_INSTALL_PREFIX}/${_filepath}
                                ${CMAKE_INSTALL_PREFIX}/${_sympath})")
endmacro()
