
macro(awk_generate work_dir_ script_ input_ output_)
  add_custom_command(
    OUTPUT ${output_}    
    COMMAND awk
    ARGS -f ${script_} ${input_} > ${output_}
    WORKING_DIRECTORY ${work_dir_}
    VERBATIM)
endmacro()