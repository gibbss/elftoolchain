
macro(m4_generate srcdir_ input_ dependencies_ output_)
  add_custom_command(
    OUTPUT ${output_}
    DEPENDS ${dependencies_}
    COMMAND m4
    ARGS -D SRCDIR=${CMAKE_SOURCE_DIR}/${srcdir_} ${CMAKE_SOURCE_DIR}/${input_} > ${output_}
    VERBATIM)
endmacro()