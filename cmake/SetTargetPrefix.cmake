macro(set_target_prefix target_)
  set_target_properties(${target_} PROPERTIES 
  OUTPUT_NAME "${ELFTC_PREFIX}-${target_}")
endmacro()