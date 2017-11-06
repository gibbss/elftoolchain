cmake_minimum_required(VERSION 3.0)
project(elftoolchain C)

###
# Import cmake modules
##
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(TestBigEndian)
include(M4GenerateC)
include(AwkGenerateC)
include(SetTargetPrefix)
include(InstallSymlink)

###
# Build options
##
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()

###
# Find dependencies before we start
# messing with the CFLAGS
###
find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)
find_package(ZLIB REQUIRED)
find_package(LibArchive REQUIRED)

###
# Set up flags and configuration
###
include(ConfigCompilerFlags)
include(ConfigVersion)

# For elf-native-format
set(ELFTC_CLASS "ELFCLASS64")
set(ELFTC_ARCH "EM_X86_64")
test_big_endian(ELFTC_BIGENDIAN)
if (ELFTC_BIGENDIAN)
  set(ELFTC_BYTEORDER "ELFDATA2MSB")
else()
  set(ELFTC_BYTEORDER "ELFDATA2LSB")
endif()

# for elftc-version
set(ELFTC_NAME "elftoolchain")
set(ELFTC_VERSION ${PROJECT_VERSION})
set(ELFTC_BUILDHOST ${CMAKE_SYSTEM_NAME})
set(ELFTC_VERSIONSTRING ${PROJECT_VERSION})

# for executable tools
set(ELFTC_PREFIX "elftc")


configure_file("common/native-elf-format.h.in" 
  "${PROJECT_BINARY_DIR}/common/native-elf-format.h"
  @ONLY)

m4_generate(libelf 
  libelf/libelf_convert.m4 libelf/elf_types.m4
  libelf_convert.c)
m4_generate(libelf 
  libelf/libelf_fsize.m4 libelf/elf_types.m4
  libelf_fsize.c)
m4_generate(libelf 
  libelf/libelf_msize.m4 libelf/elf_types.m4
  libelf_msize.c)

set(LIBELF_C_GENSRC
  libelf_convert.c
  libelf_fsize.c
  libelf_msize.c
)

set(LIBELF_C_SRC
  libelf/elf.c
  libelf/elf_begin.c
  libelf/elf_cntl.c
  libelf/elf_end.c 
  libelf/elf_errmsg.c 
  libelf/elf_errno.c
  libelf/elf_data.c
  libelf/elf_fill.c
  libelf/elf_flag.c
  libelf/elf_getarhdr.c
  libelf/elf_getarsym.c
  libelf/elf_getbase.c
  libelf/elf_getident.c
  libelf/elf_hash.c
  libelf/elf_kind.c
  libelf/elf_memory.c
  libelf/elf_next.c
  libelf/elf_open.c
  libelf/elf_rand.c
  libelf/elf_rawfile.c
  libelf/elf_phnum.c
  libelf/elf_shnum.c
  libelf/elf_shstrndx.c
  libelf/elf_scn.c
  libelf/elf_strptr.c
  libelf/elf_update.c
  libelf/elf_version.c
  libelf/gelf_cap.c
  libelf/gelf_checksum.c
  libelf/gelf_dyn.c
  libelf/gelf_ehdr.c
  libelf/gelf_getclass.c
  libelf/gelf_fsize.c
  libelf/gelf_move.c
  libelf/gelf_phdr.c
  libelf/gelf_rel.c
  libelf/gelf_rela.c
  libelf/gelf_shdr.c
  libelf/gelf_sym.c
  libelf/gelf_syminfo.c
  libelf/gelf_symshndx.c
  libelf/gelf_xlate.c
  libelf/libelf_align.c
  libelf/libelf_allocate.c
  libelf/libelf_ar.c
  libelf/libelf_ar_util.c
  libelf/libelf_checksum.c
  libelf/libelf_data.c
  libelf/libelf_ehdr.c
  libelf/libelf_extended.c
  libelf/libelf_memory.c
  libelf/libelf_open.c
  libelf/libelf_phdr.c
  libelf/libelf_shdr.c
  libelf/libelf_xlate.c)

add_library(elf SHARED ${LIBELF_C_SRC} ${LIBELF_C_GENSRC})
target_include_directories(elf PUBLIC 
  libelf 
  common
  ${CMAKE_BINARY_DIR}/common)
install(TARGETS elf 
  LIBRARY DESTINATION lib)

set(LIBELF_H_SRC
  libelf/libelf.h
  libelf/gelf.h
  common/elfdefinitions.h)

install(FILES  
  ${LIBELF_H_SRC} 
  DESTINATION include/${ELFTC_PREFIX})

set(LIBELF_MAN_SRC
  libelf/elf.3
  libelf/elf_begin.3
  libelf/elf_cntl.3
  libelf/elf_end.3
  libelf/elf_errmsg.3
  libelf/elf_fill.3
  libelf/elf_flagdata.3
  libelf/elf_getarhdr.3
  libelf/elf_getarsym.3
  libelf/elf_getbase.3
  libelf/elf_getdata.3
  libelf/elf_getident.3
  libelf/elf_getscn.3
  libelf/elf_getphdrnum.3
  libelf/elf_getphnum.3
  libelf/elf_getshdrnum.3
  libelf/elf_getshnum.3
  libelf/elf_getshdrstrndx.3
  libelf/elf_getshstrndx.3
  libelf/elf_hash.3
  libelf/elf_kind.3
  libelf/elf_memory.3
  libelf/elf_next.3
  libelf/elf_open.3
  libelf/elf_rawfile.3
  libelf/elf_rand.3
  libelf/elf_strptr.3
  libelf/elf_update.3
  libelf/elf_version.3
  libelf/gelf.3
  libelf/gelf_checksum.3
  libelf/gelf_fsize.3
  libelf/gelf_getcap.3
  libelf/gelf_getclass.3
  libelf/gelf_getdyn.3
  libelf/gelf_getehdr.3
  libelf/gelf_getmove.3
  libelf/gelf_getphdr.3
  libelf/gelf_getrel.3
  libelf/gelf_getrela.3
  libelf/gelf_getshdr.3
  libelf/gelf_getsym.3
  libelf/gelf_getsyminfo.3
  libelf/gelf_getsymshndx.3
  libelf/gelf_newehdr.3
  libelf/gelf_newphdr.3
  libelf/gelf_update_ehdr.3
  libelf/gelf_xlatetof.3)

install(FILES  
  ${LIBELF_MAN_SRC} 
  DESTINATION share/man/3)

install_symlink(share/man/3/elf_errmsg.3 
                share/man/3/elf_errno.3)
install_symlink(share/man/3/elf_flagdata.3 
		share/man/3/elf_flagarhdr.3)
install_symlink(share/man/3/elf_flagdata.3
                share/man/3/elf_flagehdr.3)
install_symlink(share/man/3/elf_flagdata.3 
                share/man/3/elf_flagelf.3)
install_symlink(share/man/3/elf_flagdata.3
                share/man/3/elf_flagphdr.3)
install_symlink(share/man/3/elf_flagdata.3
                share/man/3/elf_flagscn.3)
install_symlink(share/man/3/elf_flagdata.3
                share/man/3/elf_flagshdr.3)
install_symlink(share/man/3/elf_getdata.3
                share/man/3/elf_newdata.3)
install_symlink(share/man/3/elf_getdata.3
                share/man/3/elf_rawdata.3)
install_symlink(share/man/3/elf_getscn.3
                share/man/3/elf_ndxscn.3)
install_symlink(share/man/3/elf_getscn.3
                share/man/3/elf_newscn.3)
install_symlink(share/man/3/elf_getscn.3
                share/man/3/elf_nextscn.3)
install_symlink(share/man/3/elf_getshstrndx.3
                share/man/3/elf_setshstrndx.3)
install_symlink(share/man/3/elf_open.3
                share/man/3/elf_openmemory.3)
install_symlink(share/man/3/gelf_getcap.3
                share/man/3/gelf_update_cap.3)
install_symlink(share/man/3/gelf_getdyn.3
                share/man/3/gelf_update_dyn.3)
install_symlink(share/man/3/gelf_getmove.3
                share/man/3/gelf_update_move.3)
install_symlink(share/man/3/gelf_getrel.3
                share/man/3/gelf_update_rel.3)
install_symlink(share/man/3/gelf_getrela.3
                share/man/3/gelf_update_rela.3)
install_symlink(share/man/3/gelf_getsym.3
                share/man/3/gelf_update_sym.3)
install_symlink(share/man/3/gelf_getsyminfo.3
                share/man/3/gelf_update_syminfo.3)
install_symlink(share/man/3/gelf_getsymshndx.3
                share/man/3/gelf_update_symshndx.3)
install_symlink(share/man/3/gelf_update_ehdr.3
                share/man/3/gelf_update_phdr.3)
install_symlink(share/man/3/gelf_update_ehdr.3
                share/man/3/gelf_update_shdr.3)
install_symlink(share/man/3/gelf_xlatetof.3
                share/man/3/gelf_xlatetom.3)

install_symlink(share/man/3/gelf_checksum.3
                share/man/3/elf32_checksum.3)
install_symlink(share/man/3/gelf_fsize.3
                share/man/3/elf32_fsize.3)
install_symlink(share/man/3/gelf_getehdr.3
                share/man/3/elf32_getehdr.3)
install_symlink(share/man/3/gelf_getphdr.3
                share/man/3/elf32_getphdr.3)
install_symlink(share/man/3/gelf_getshdr.3
                share/man/3/elf32_getshdr.3)
install_symlink(share/man/3/gelf_newehdr.3
                share/man/3/elf32_newehdr.3)
install_symlink(share/man/3/gelf_newphdr.3
                share/man/3/elf32_newphdr.3)
install_symlink(share/man/3/gelf_xlatetof.3
                share/man/3/elf32_xlatetof.3)
install_symlink(share/man/3/gelf_xlatetof.3
                share/man/3/elf32_xlatetom.3)

install_symlink(share/man/3/gelf_checksum.3
                share/man/3/elf64_checksum.3)
install_symlink(share/man/3/gelf_fsize.3
                share/man/3/elf64_fsize.3)
install_symlink(share/man/3/gelf_getehdr.3
                share/man/3/elf64_getehdr.3)
install_symlink(share/man/3/gelf_getphdr.3
                share/man/3/elf64_getphdr.3)
install_symlink(share/man/3/gelf_getshdr.3
                share/man/3/elf64_getshdr.3)
install_symlink(share/man/3/gelf_newehdr.3
                share/man/3/elf64_newehdr.3)
install_symlink(share/man/3/gelf_newphdr.3
                share/man/3/elf64_newphdr.3)
install_symlink(share/man/3/gelf_xlatetof.3
                share/man/3/elf64_xlatetof.3)
install_symlink(share/man/3/gelf_xlatetof.3
                share/man/3/elf64_xlatetom.3)


m4_generate(libdwarf
  libdwarf/dwarf_pubnames.m4 libdwarf/dwarf_nametbl.m4
  dwarf_pubnames.c)
m4_generate(libdwarf
  libdwarf/dwarf_pubtypes.m4 libdwarf/dwarf_nametbl.m4
  dwarf_pubtypes.c)
m4_generate(libdwarf
  libdwarf/dwarf_weaks.m4 libdwarf/dwarf_nametbl.m4
  dwarf_weaks.c)
m4_generate(libdwarf
  libdwarf/dwarf_funcs.m4 libdwarf/dwarf_nametbl.m4
  dwarf_funcs.c)
m4_generate(libdwarf
  libdwarf/dwarf_vars.m4 libdwarf/dwarf_nametbl.m4
  dwarf_vars.c)
m4_generate(libdwarf
  libdwarf/dwarf_types.m4 libdwarf/dwarf_nametbl.m4
  dwarf_types.c)
m4_generate(libdwarf
  libdwarf/dwarf_pro_pubnames.m4 libdwarf/dwarf_pro_nametbl.m4
  dwarf_pro_pubnames.c)
m4_generate(libdwarf
  libdwarf/dwarf_pro_weaks.m4 libdwarf/dwarf_pro_nametbl.m4
  dwarf_pro_weaks.c)
m4_generate(libdwarf
  libdwarf/dwarf_pro_funcs.m4 libdwarf/dwarf_pro_nametbl.m4
  dwarf_pro_funcs.c)
m4_generate(libdwarf
  libdwarf/dwarf_pro_types.m4 libdwarf/dwarf_pro_nametbl.m4
  dwarf_pro_types.c)
m4_generate(libdwarf
  libdwarf/dwarf_pro_vars.m4 libdwarf/dwarf_pro_nametbl.m4
  dwarf_pro_vars.c)

set(LIBDWARF_C_GENSRC
  dwarf_pubnames.c 
  dwarf_pubtypes.c
  dwarf_weaks.c
  dwarf_funcs.c
  dwarf_vars.c
  dwarf_types.c
  dwarf_pro_pubnames.c
  dwarf_pro_weaks.c
  dwarf_pro_funcs.c
  dwarf_pro_types.c
  dwarf_pro_vars.c)

set(LIBDWARF_C_SRC 
  libdwarf/dwarf_abbrev.c
  libdwarf/dwarf_arange.c
  libdwarf/dwarf_attr.c
  libdwarf/dwarf_attrval.c
  libdwarf/dwarf_cu.c
  libdwarf/dwarf_dealloc.c
  libdwarf/dwarf_die.c
  libdwarf/dwarf_dump.c
  libdwarf/dwarf_errmsg.c
  libdwarf/dwarf_finish.c
  libdwarf/dwarf_form.c
  libdwarf/dwarf_frame.c
  libdwarf/dwarf_init.c
  libdwarf/dwarf_lineno.c
  libdwarf/dwarf_loclist.c
  libdwarf/dwarf_macinfo.c
  libdwarf/dwarf_pro_arange.c
  libdwarf/dwarf_pro_attr.c
  libdwarf/dwarf_pro_die.c
  libdwarf/dwarf_pro_expr.c
  libdwarf/dwarf_pro_finish.c
  libdwarf/dwarf_pro_frame.c
  libdwarf/dwarf_pro_init.c
  libdwarf/dwarf_pro_lineno.c
  libdwarf/dwarf_pro_macinfo.c
  libdwarf/dwarf_pro_reloc.c
  libdwarf/dwarf_pro_sections.c
  libdwarf/dwarf_ranges.c
  libdwarf/dwarf_reloc.c
  libdwarf/dwarf_sections.c
  libdwarf/dwarf_seterror.c
  libdwarf/dwarf_str.c
  libdwarf/libdwarf.c
  libdwarf/libdwarf_abbrev.c
  libdwarf/libdwarf_arange.c
  libdwarf/libdwarf_attr.c
  libdwarf/libdwarf_die.c
  libdwarf/libdwarf_error.c
  libdwarf/libdwarf_elf_access.c
  libdwarf/libdwarf_elf_init.c
  libdwarf/libdwarf_frame.c
  libdwarf/libdwarf_info.c
  libdwarf/libdwarf_init.c
  libdwarf/libdwarf_lineno.c
  libdwarf/libdwarf_loc.c
  libdwarf/libdwarf_loclist.c
  libdwarf/libdwarf_macinfo.c
  libdwarf/libdwarf_nametbl.c
  libdwarf/libdwarf_ranges.c
  libdwarf/libdwarf_reloc.c
  libdwarf/libdwarf_rw.c
  libdwarf/libdwarf_sections.c
  libdwarf/libdwarf_str.c)

add_library(dwarf SHARED ${LIBDWARF_C_SRC} ${LIBDWARF_C_GENSRC})
target_include_directories(dwarf PUBLIC 
  libdwarf
  libelf
  common
  ${CMAKE_BINARY_DIR}/common)
install(TARGETS dwarf 
  LIBRARY DESTINATION lib)


set(LIBDWARF_H_SRC
  libdwarf/dwarf.h
  libdwarf/libdwarf.h)

install(FILES  
  ${LIBDWARF_H_SRC} 
  DESTINATION include/${ELFTC_PREFIX})

set(LIBDWARF_MAN_SRC
  libdwarf/dwarf.3
  libdwarf/dwarf_add_arange.3
  libdwarf/dwarf_add_AT_comp_dir.3
  libdwarf/dwarf_add_AT_const_value_string.3
  libdwarf/dwarf_add_AT_dataref.3
  libdwarf/dwarf_add_AT_flag.3
  libdwarf/dwarf_add_AT_location_expr.3
  libdwarf/dwarf_add_AT_name.3
  libdwarf/dwarf_add_AT_producer.3
  libdwarf/dwarf_add_AT_ref_address.3
  libdwarf/dwarf_add_AT_reference.3
  libdwarf/dwarf_add_AT_signed_const.3
  libdwarf/dwarf_add_AT_string.3
  libdwarf/dwarf_add_AT_targ_address.3
  libdwarf/dwarf_add_die_to_debug.3
  libdwarf/dwarf_add_directory_decl.3
  libdwarf/dwarf_add_expr_addr.3
  libdwarf/dwarf_add_expr_gen.3
  libdwarf/dwarf_add_fde_inst.3
  libdwarf/dwarf_add_file_decl.3
  libdwarf/dwarf_add_frame_cie.3
  libdwarf/dwarf_add_frame_fde.3
  libdwarf/dwarf_add_funcname.3
  libdwarf/dwarf_add_line_entry.3
  libdwarf/dwarf_add_pubname.3
  libdwarf/dwarf_add_typename.3
  libdwarf/dwarf_add_varname.3
  libdwarf/dwarf_add_weakname.3
  libdwarf/dwarf_attr.3
  libdwarf/dwarf_attrlist.3
  libdwarf/dwarf_attroffset.3
  libdwarf/dwarf_attrval_signed.3
  libdwarf/dwarf_child.3
  libdwarf/dwarf_dealloc.3
  libdwarf/dwarf_def_macro.3
  libdwarf/dwarf_die_abbrev_code.3
  libdwarf/dwarf_die_link.3
  libdwarf/dwarf_diename.3
  libdwarf/dwarf_dieoffset.3
  libdwarf/dwarf_end_macro_file.3
  libdwarf/dwarf_errmsg.3
  libdwarf/dwarf_errno.3
  libdwarf/dwarf_expand_frame_instructions.3
  libdwarf/dwarf_expr_current_offset.3
  libdwarf/dwarf_expr_into_block.3
  libdwarf/dwarf_fde_cfa_offset.3
  libdwarf/dwarf_find_macro_value_start.3
  libdwarf/dwarf_finish.3
  libdwarf/dwarf_formaddr.3
  libdwarf/dwarf_formblock.3
  libdwarf/dwarf_formexprloc.3
  libdwarf/dwarf_formflag.3
  libdwarf/dwarf_formref.3
  libdwarf/dwarf_formsig8.3
  libdwarf/dwarf_formstring.3
  libdwarf/dwarf_formudata.3
  libdwarf/dwarf_get_abbrev.3
  libdwarf/dwarf_get_abbrev_children_flag.3
  libdwarf/dwarf_get_abbrev_code.3
  libdwarf/dwarf_get_abbrev_entry.3
  libdwarf/dwarf_get_abbrev_tag.3
  libdwarf/dwarf_get_address_size.3
  libdwarf/dwarf_get_arange.3
  libdwarf/dwarf_get_arange_info.3
  libdwarf/dwarf_get_aranges.3
  libdwarf/dwarf_get_AT_name.3
  libdwarf/dwarf_get_cie_index.3
  libdwarf/dwarf_get_cie_info.3
  libdwarf/dwarf_get_cie_of_fde.3
  libdwarf/dwarf_get_cu_die_offset.3
  libdwarf/dwarf_get_die_infotypes_flag.3
  libdwarf/dwarf_get_elf.3
  libdwarf/dwarf_get_fde_at_pc.3
  libdwarf/dwarf_get_fde_info_for_all_regs.3
  libdwarf/dwarf_get_fde_info_for_all_regs3.3
  libdwarf/dwarf_get_fde_info_for_cfa_reg3.3
  libdwarf/dwarf_get_fde_info_for_reg.3
  libdwarf/dwarf_get_fde_info_for_reg3.3
  libdwarf/dwarf_get_fde_instr_bytes.3
  libdwarf/dwarf_get_fde_list.3
  libdwarf/dwarf_get_fde_n.3
  libdwarf/dwarf_get_fde_range.3
  libdwarf/dwarf_get_form_class.3
  libdwarf/dwarf_get_funcs.3
  libdwarf/dwarf_get_globals.3
  libdwarf/dwarf_get_loclist_entry.3
  libdwarf/dwarf_get_macro_details.3
  libdwarf/dwarf_get_pubtypes.3
  libdwarf/dwarf_get_ranges.3
  libdwarf/dwarf_get_relocation_info.3
  libdwarf/dwarf_get_relocation_info_count.3
  libdwarf/dwarf_get_section_bytes.3
  libdwarf/dwarf_get_section_max_offsets.3
  libdwarf/dwarf_get_str.3
  libdwarf/dwarf_get_types.3
  libdwarf/dwarf_get_vars.3
  libdwarf/dwarf_get_weaks.3
  libdwarf/dwarf_hasattr.3
  libdwarf/dwarf_hasform.3
  libdwarf/dwarf_highpc.3
  libdwarf/dwarf_init.3
  libdwarf/dwarf_lineno.3
  libdwarf/dwarf_lne_end_sequence.3
  libdwarf/dwarf_lne_set_address.3
  libdwarf/dwarf_loclist.3
  libdwarf/dwarf_loclist_from_expr.3
  libdwarf/dwarf_new_die.3
  libdwarf/dwarf_new_expr.3
  libdwarf/dwarf_new_fde.3
  libdwarf/dwarf_next_cu_header.3
  libdwarf/dwarf_next_types_section.3
  libdwarf/dwarf_object_init.3
  libdwarf/dwarf_producer_init.3
  libdwarf/dwarf_producer_set_isa.3
  libdwarf/dwarf_reset_section_bytes.3
  libdwarf/dwarf_seterrarg.3
  libdwarf/dwarf_set_frame_cfa_value.3
  libdwarf/dwarf_set_reloc_application.3
  libdwarf/dwarf_srcfiles.3
  libdwarf/dwarf_srclines.3
  libdwarf/dwarf_start_macro_file.3
  libdwarf/dwarf_tag.3
  libdwarf/dwarf_transform_to_disk_form.3
  libdwarf/dwarf_undef_macro.3
  libdwarf/dwarf_vendor_ext.3
  libdwarf/dwarf_whatattr.3)

install(FILES  
  ${LIBDWARF_MAN_SRC} 
  DESTINATION share/man/3)

install_symlink(share/man/3/dwarf_add_AT_const_value_string.3
                share/man/3/dwarf_add_AT_const_value_signedint.3)
install_symlink(share/man/3/dwarf_add_AT_const_value_string.3
                share/man/3/dwarf_add_AT_const_value_unsignedint.3)
install_symlink(share/man/3/dwarf_add_AT_signed_const.3
                share/man/3/dwarf_add_AT_unsigned_const.3)
install_symlink(share/man/3/dwarf_add_AT_targ_address.3
                share/man/3/dwarf_add_AT_targ_address_b.3)
install_symlink(share/man/3/dwarf_add_arange.3
                share/man/3/dwarf_add_arange_b.3)
install_symlink(share/man/3/dwarf_add_expr_addr.3
                share/man/3/dwarf_add_expr_addr_b.3)
install_symlink(share/man/3/dwarf_add_frame_fde.3
                share/man/3/dwarf_add_frame_fde_b.3)
install_symlink(share/man/3/dwarf_attrval_signed.3
                share/man/3/dwarf_attrval_flag.3)
install_symlink(share/man/3/dwarf_attrval_signed.3
                share/man/3/dwarf_attrval_string.3)
install_symlink(share/man/3/dwarf_attrval_signed.3
                share/man/3/dwarf_attrval_unsigned.3)
install_symlink(share/man/3/dwarf_child.3
                share/man/3/dwarf_offdie.3)
install_symlink(share/man/3/dwarf_child.3
                share/man/3/dwarf_offdie_b.3)
install_symlink(share/man/3/dwarf_child.3
                share/man/3/dwarf_siblingof.3)
install_symlink(share/man/3/dwarf_child.3
                share/man/3/dwarf_siblingof_b.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_fde_cie_list_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_funcs_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_globals_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_pubtypes_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_types_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_vars_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_weaks_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_ranges_dealloc.3)
install_symlink(share/man/3/dwarf_dealloc.3
                share/man/3/dwarf_srclines_dealloc.3)
install_symlink(share/man/3/dwarf_init.3
                share/man/3/dwarf_elf_init.3)
install_symlink(share/man/3/dwarf_dieoffset.3
                share/man/3/dwarf_die_CU_offset.3)
install_symlink(share/man/3/dwarf_dieoffset.3
                share/man/3/dwarf_die_CU_offset_range.3)
install_symlink(share/man/3/dwarf_dieoffset.3
                share/man/3/dwarf_get_cu_die_offset_given_cu_header_offset.3)
install_symlink(share/man/3/dwarf_dieoffset.3
                share/man/3/dwarf_get_cu_die_offset_given_cu_header_offset_b.3)
install_symlink(share/man/3/dwarf_finish.3
                share/man/3/dwarf_object_finish.3)
install_symlink(share/man/3/dwarf_formref.3
                share/man/3/dwarf_global_formref.3)
install_symlink(share/man/3/dwarf_formudata.3
                share/man/3/dwarf_formsdata.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_ACCESS_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_ATE_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_CC_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_CFA_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_CHILDREN_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_DS_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_DSC_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_EH_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_END_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_FORM_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_ID_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_INL_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_LANG_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_LNE_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_LNS_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_MACINFO_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_OP_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_ORD_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_TAG_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_VIRTUALITY_name.3)
install_symlink(share/man/3/dwarf_get_AT_name.3
                share/man/3/dwarf_get_VIS_name.3)
install_symlink(share/man/3/dwarf_get_cu_die_offset.3
                share/man/3/dwarf_get_arange_cu_header_offset.3)
install_symlink(share/man/3/dwarf_get_fde_list.3
                share/man/3/dwarf_get_fde_list_eh.3)
install_symlink(share/man/3/dwarf_get_funcs.3
                share/man/3/dwarf_func_die_offset.3)
install_symlink(share/man/3/dwarf_get_funcs.3
                share/man/3/dwarf_func_cu_offset.3)
install_symlink(share/man/3/dwarf_get_funcs.3
                share/man/3/dwarf_func_name_offsets.3)
install_symlink(share/man/3/dwarf_get_funcs.3
                share/man/3/dwarf_funcname.3)
install_symlink(share/man/3/dwarf_get_globals.3
                share/man/3/dwarf_global_die_offset.3)
install_symlink(share/man/3/dwarf_get_globals.3
                share/man/3/dwarf_global_cu_offset.3)
install_symlink(share/man/3/dwarf_get_globals.3
                share/man/3/dwarf_global_name_offsets.3)
install_symlink(share/man/3/dwarf_get_globals.3
                share/man/3/dwarf_globname.3)
install_symlink(share/man/3/dwarf_get_pubtypes.3
                share/man/3/dwarf_pubtype_die_offset.3)
install_symlink(share/man/3/dwarf_get_pubtypes.3
                share/man/3/dwarf_pubtype_cu_offset.3)
install_symlink(share/man/3/dwarf_get_pubtypes.3
                share/man/3/dwarf_pubtype_name_offsets.3)
install_symlink(share/man/3/dwarf_get_pubtypes.3
                share/man/3/dwarf_pubtypename.3)
install_symlink(share/man/3/dwarf_get_ranges.3
                share/man/3/dwarf_get_ranges_a.3)
install_symlink(share/man/3/dwarf_get_section_max_offsets.3
                share/man/3/dwarf_get_section_max_offsets_b.3)
install_symlink(share/man/3/dwarf_get_types.3
                share/man/3/dwarf_type_die_offset.3)
install_symlink(share/man/3/dwarf_get_types.3
                share/man/3/dwarf_type_cu_offset.3)
install_symlink(share/man/3/dwarf_get_types.3
                share/man/3/dwarf_type_name_offsets.3)
install_symlink(share/man/3/dwarf_get_types.3
                share/man/3/dwarf_typename.3)
install_symlink(share/man/3/dwarf_get_vars.3
                share/man/3/dwarf_var_die_offset.3)
install_symlink(share/man/3/dwarf_get_vars.3
                share/man/3/dwarf_var_cu_offset.3)
install_symlink(share/man/3/dwarf_get_vars.3
                share/man/3/dwarf_var_name_offsets.3)
install_symlink(share/man/3/dwarf_get_vars.3
                share/man/3/dwarf_varname.3)
install_symlink(share/man/3/dwarf_get_weaks.3
                share/man/3/dwarf_weak_die_offset.3)
install_symlink(share/man/3/dwarf_get_weaks.3
                share/man/3/dwarf_weak_cu_offset.3)
install_symlink(share/man/3/dwarf_get_weaks.3
                share/man/3/dwarf_weak_name_offsets.3)
install_symlink(share/man/3/dwarf_get_weaks.3
                share/man/3/dwarf_weakname.3)
install_symlink(share/man/3/dwarf_hasform.3
                share/man/3/dwarf_whatform.3)
install_symlink(share/man/3/dwarf_hasform.3
                share/man/3/dwarf_whatform_direct.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_arrayorder.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_bitoffset.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_bitsize.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_bytesize.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_highpc_b.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_lowpc.3)
install_symlink(share/man/3/dwarf_highpc.3
                share/man/3/dwarf_srclang.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_lineaddr.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_linebeginstatement.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_lineblock.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_lineendsequence.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_lineoff.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_linesrc.3)
install_symlink(share/man/3/dwarf_lineno.3
                share/man/3/dwarf_line_srcfileno.3)
install_symlink(share/man/3/dwarf_loclist.3
                share/man/3/dwarf_loclist_n.3)
install_symlink(share/man/3/dwarf_loclist_from_expr.3
                share/man/3/dwarf_loclist_from_expr_a.3)
install_symlink(share/man/3/dwarf_loclist_from_expr.3
                share/man/3/dwarf_loclist_from_expr_b.3)
install_symlink(share/man/3/dwarf_next_cu_header.3
                share/man/3/dwarf_next_cu_header_b.3)
install_symlink(share/man/3/dwarf_next_cu_header.3
                share/man/3/dwarf_next_cu_header_c.3)
install_symlink(share/man/3/dwarf_producer_init.3
                share/man/3/dwarf_producer_init_b.3)
install_symlink(share/man/3/dwarf_seterrarg.3
                share/man/3/dwarf_seterrhand.3)
install_symlink(share/man/3/dwarf_set_frame_cfa_value.3
                share/man/3/dwarf_set_frame_rule_initial_value.3)
install_symlink(share/man/3/dwarf_set_frame_cfa_value.3
                share/man/3/dwarf_set_frame_rule_table_size.3)
install_symlink(share/man/3/dwarf_set_frame_cfa_value.3
                share/man/3/dwarf_set_frame_same_value.3)
install_symlink(share/man/3/dwarf_set_frame_cfa_value.3
                share/man/3/dwarf_set_frame_undefined_value.3)


set(LIBPE_C_SRC
  libpe/libpe_buffer.c
  libpe/libpe_coff.c
  libpe/libpe_dos.c
  libpe/libpe_init.c
  libpe/libpe_rich.c
  libpe/libpe_section.c
  libpe/libpe_utils.c
  libpe/pe_buffer.c
  libpe/pe_cntl.c
  libpe/pe_coff.c
  libpe/pe_dos.c
  libpe/pe_flag.c
  libpe/pe_init.c
  libpe/pe_rich.c
  libpe/pe_section.c
  libpe/pe_symtab.c
  libpe/pe_update.c)

add_library(pe SHARED ${LIBPE_C_SRC})
target_include_directories(pe PUBLIC 
  libpe
  common)
install(TARGETS pe
  LIBRARY DESTINATION lib)

set(LIBPE_H_SRC
  libpe/libpe.h
  libpe/pe.h)

install(FILES  
  ${LIBPE_H_SRC} 
  DESTINATION include/${ELFTC_PREFIX})


add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/elftc_version.c
  DEPENDS libelftc/make-toolchain-version
  COMMAND ${CMAKE_SOURCE_DIR}/libelftc/make-toolchain-version 
  ARGS -t ${CMAKE_SOURCE_DIR} -o ${PROJECT_BINARY_DIR}/elftc_version.c
  VERBATIM)

set(LIBELFTC_C_GENSRC
  ${PROJECT_BINARY_DIR}/elftc_version.c)

set(LIBELFTC_C_SRC
  libelftc/elftc_bfdtarget.c
  libelftc/elftc_copyfile.c
  libelftc/elftc_demangle.c
  libelftc/elftc_reloc_type_str.c
  libelftc/elftc_set_timestamps.c
  libelftc/elftc_string_table.c
  libelftc/elftc_timestamp.c
  libelftc/libelftc_bfdtarget.c
  libelftc/libelftc_dem_arm.c
  libelftc/libelftc_dem_gnu2.c
  libelftc/libelftc_dem_gnu3.c
  libelftc/libelftc_hash.c
  libelftc/libelftc_vstr.c)
add_library(elftc SHARED ${LIBELFTC_C_SRC} ${LIBELFTC_C_GENSRC})
target_include_directories(elftc PUBLIC 
  libelftc
  libelf
  common)
install(TARGETS elftc
  LIBRARY DESTINATION lib)


set(LIBELFTC_H_SRC
  libelftc/libelftc.h)

install(FILES  
  ${LIBELFTC_H_SRC} 
  DESTINATION include/${ELFTC_PREFIX})

set(LIBELFTC_MAN_SRC
  libelftc/elftc.3
  libelftc/elftc_bfd_find_target.3
  libelftc/elftc_copyfile.3
  libelftc/elftc_demangle.3
  libelftc/elftc_reloc_type_str.3
  libelftc/elftc_set_timestamps.3
  libelftc/elftc_string_table_create.3
  libelftc/elftc_version.3)

install(FILES  
  ${LIBELFTC_MAN_SRC} 
  DESTINATION share/man/3)

install_symlink(share/man/3/elftc_bfd_find_target.3
               share/man/3/elftc_bfd_target_byteorder.3)
install_symlink(share/man/3/elftc_bfd_find_target.3
               share/man/3/elftc_bfd_target_class.3)
install_symlink(share/man/3/elftc_bfd_find_target.3
               share/man/3/elftc_bfd_target_flavor.3)
install_symlink(share/man/3/elftc_string_table_create.3
               share/man/3/elftc_string_table_from_section.3)
install_symlink(share/man/3/elftc_string_table_create.3
               share/man/3/elftc_string_table_destroy.3)
install_symlink(share/man/3/elftc_string_table_create.3
               share/man/3/elftc_string_table_image.3)
install_symlink(share/man/3/elftc_string_table_create.3
               share/man/3/elftc_string_table_insert.3)
install_symlink(share/man/3/elftc_string_table_create.3
               share/man/3/elftc_string_table_lookup.3)

set(ADDR2LINE_C_SRC
  addr2line/addr2line.c)

add_executable(addr2line ${ADDR2LINE_C_SRC})
set_target_prefix(addr2line)
target_link_libraries(addr2line elftc dwarf elf)
install(TARGETS addr2line
  RUNTIME DESTINATION bin)

install(FILES  
  addr2line/addr2line.1 
  DESTINATION share/man/1)


bison_target(acpyacc
  ar/acpyacc.y ${CMAKE_BINARY_DIR}/acpyacc.c
  COMPILE_FLAGS)
flex_target(acplex 
  ar/acplex.l ${CMAKE_BINARY_DIR}/acplex.c)

set(AR_C_GENSRC
 ${CMAKE_BINARY_DIR}/acplex.c
 ${CMAKE_BINARY_DIR}/acpyacc.c)

set(AR_C_SRC
  ar/ar.c
  ar/read.c
  ar/util.c
  ar/write.c)

add_executable(ar ${AR_C_SRC} ${AR_C_GENSRC})
set_target_prefix(ar)
target_link_libraries(ar elftc elf 
  ${LibArchive_LIBRARIES}
  ${ZLIB_LIBRARIES})
target_include_directories(ar PUBLIC 
  ar
  ${LibArchive_INCLUDE_DIRS}
  ${ZLIB_INCLUDE_DIRS})
install(TARGETS ar
  RUNTIME DESTINATION bin)

install_symlink(bin/${ELFTC_PREFIX}-ar
                bin/${ELFTC_PREFIX}-ranlib)

install(FILES  
  ar/ar.1 
  DESTINATION share/man/1)

install(FILES  
  ar/ar.5 
  DESTINATION share/man/5)


set(AS_C_SRC
  as/as.c)

add_executable(as ${AS_C_SRC})
set_target_prefix(as)
target_link_libraries(as elftc elf)
install(TARGETS as
  RUNTIME DESTINATION bin)

install(FILES  
  as/as.1 
  DESTINATION share/man/1)


set(BRANDELF_C_SRC
  brandelf/brandelf.c)

add_executable(brandelf ${BRANDELF_C_SRC})
set_target_prefix(brandelf)
target_link_libraries(brandelf elftc elf)
install(TARGETS brandelf
  RUNTIME DESTINATION bin)

install(FILES  
  brandelf/brandelf.1 
  DESTINATION share/man/1)


set(CXXFILT_C_SRC
  cxxfilt/cxxfilt.c)

add_executable(cxxfilt ${CXXFILT_C_SRC})
set_target_prefix(cxxfilt)
target_link_libraries(cxxfilt elftc elf)
install(TARGETS cxxfilt
  RUNTIME DESTINATION bin)

install(FILES  
  cxxfilt/c++filt.1 
  DESTINATION share/man/1)


set(ELFCOPY_C_SRC
  elfcopy/archive.c
  elfcopy/ascii.c
  elfcopy/binary.c
  elfcopy/main.c
  elfcopy/pe.c
  elfcopy/sections.c
  elfcopy/segments.c
  elfcopy/symbols.c
)

add_executable(elfcopy ${ELFCOPY_C_SRC})
set_target_prefix(elfcopy)
target_compile_definitions(elfcopy PUBLIC WITH_PE=1)
target_link_libraries(elfcopy 
  elftc elf pe
  ${LibArchive_LIBRARIES})
install(TARGETS elfcopy
  RUNTIME DESTINATION bin)

install_symlink(bin/${ELFTC_PREFIX}-elfcopy
                bin/${ELFTC_PREFIX}-mcs)
install_symlink(bin/${ELFTC_PREFIX}-elfcopy
                bin/${ELFTC_PREFIX}-objcopy)
install_symlink(bin/${ELFTC_PREFIX}-elfcopy
                bin/${ELFTC_PREFIX}-strip)

set(ELFCOPY_MAN_SRC
  elfcopy/mcs.1 
  elfcopy/strip.1 
  elfcopy/elfcopy.1)

install(FILES  
  ${ELFCOPY_MAN_SRC}
  DESTINATION share/man/1)


set(ELFDUMP_C_SRC
  elfdump/elfdump.c)

add_executable(elfdump ${ELFDUMP_C_SRC})
set_target_prefix(elfdump)
target_link_libraries(elfdump elftc elf)
install(TARGETS elfdump
  RUNTIME DESTINATION bin)

install(FILES  
  elfdump/elfdump.1 
  DESTINATION share/man/1)


set(FINDTEXTREL_C_SRC
  findtextrel/findtextrel.c)

add_executable(findtextrel ${FINDTEXTREL_C_SRC})
set_target_prefix(findtextrel)
target_link_libraries(findtextrel elftc elf dwarf)
install(TARGETS findtextrel
  RUNTIME DESTINATION bin)

install(FILES  
  findtextrel/findtextrel.1 
  DESTINATION share/man/1)


set(ISA_C_SRC
  isa/isa.c)

add_executable(isa ${ISA_C_SRC})
set_target_prefix(isa)
target_link_libraries(isa elftc elf)
install(TARGETS isa
  RUNTIME DESTINATION bin)

install(FILES  
  isa/isa.1 
  DESTINATION share/man/1)

install(FILES  
  isa/isa.5
  DESTINATION share/man/5)


awk_generate(${CMAKE_SOURCE_DIR}/ld ld_script.awk 
  amd64_script.ld ${CMAKE_BINARY_DIR}/amd64_script.c)
awk_generate(${CMAKE_SOURCE_DIR}/ld ld_script.awk 
  i386_script.ld ${CMAKE_BINARY_DIR}/i386_script.c)
awk_generate(${CMAKE_SOURCE_DIR}/ld ld_script.awk 
  littlemips_script.ld ${CMAKE_BINARY_DIR}/littlemips_script.c)
awk_generate(${CMAKE_SOURCE_DIR}/ld ld_script.awk 
  bigmips_script.ld ${CMAKE_BINARY_DIR}/bigmips_script.c)

bison_target(ld_script_parser 
  ld/ld_script_parser.y ${CMAKE_BINARY_DIR}/ld_script_parser.c
  COMPILE_FLAGS)
flex_target(ld_script_lexer 
  ld/ld_script_lexer.l ${CMAKE_BINARY_DIR}/ld_script_lexer.c)

set(LD_C_GENSRC
 ${CMAKE_BINARY_DIR}/amd64_script.c
 ${CMAKE_BINARY_DIR}/i386_script.c
 ${CMAKE_BINARY_DIR}/littlemips_script.c
 ${CMAKE_BINARY_DIR}/bigmips_script.c
 ${CMAKE_BINARY_DIR}/ld_script_lexer.c
 ${CMAKE_BINARY_DIR}/ld_script_parser.c
)

set(LD_C_SRC
  ld/amd64.c
  ld/i386.c
  ld/ld_arch.c
  ld/ld_dynamic.c
  ld/ld_ehframe.c
  ld/ld_error.c
  ld/ld_exp.c
  ld/ld_file.c
  ld/ld_hash.c
  ld/ld_input.c
  ld/ld_layout.c
  ld/ld_main.c
  ld/ld_options.c
  ld/ld_output.c
  ld/ld_path.c
  ld/ld_reloc.c
  ld/ld_script.c
  ld/ld_strtab.c
  ld/ld_symbols.c
  ld/ld_symver.c
  ld/mips.c)

add_executable(ld ${LD_C_SRC} ${LD_C_GENSRC})
set_target_prefix(ld)
target_include_directories(ld PUBLIC ld)
target_link_libraries(ld elftc elf dwarf)
install(TARGETS ld
  RUNTIME DESTINATION bin)

install(FILES  
  ld/ld.1 
  DESTINATION share/man/1)


set(NM_C_SRC
  nm/nm.c)

add_executable(nm ${NM_C_SRC})
set_target_prefix(nm)
target_link_libraries(nm elftc elf dwarf)
install(TARGETS nm
  RUNTIME DESTINATION bin)

install(FILES  
  nm/nm.1 
  DESTINATION share/man/1)


set(READELF_C_SRC
  readelf/readelf.c)

add_executable(readelf ${READELF_C_SRC})
set_target_prefix(readelf)
target_link_libraries(readelf elftc elf dwarf)
install(TARGETS readelf
  RUNTIME DESTINATION bin)

install(FILES  
  readelf/readelf.1 
  DESTINATION share/man/1)


set(SIZE_C_SRC
  size/size.c)

add_executable(size ${SIZE_C_SRC})
set_target_prefix(size)
target_link_libraries(size elftc elf)
install(TARGETS size
  RUNTIME DESTINATION bin)

install(FILES  
  size/size.1 
  DESTINATION share/man/1)


set(STRINGS_C_SRC
  strings/strings.c)

add_executable(strings ${STRINGS_C_SRC})
set_target_prefix(strings)
target_link_libraries(strings elftc elf)
install(TARGETS strings
  RUNTIME DESTINATION bin)

install(FILES  
  strings/strings.1 
  DESTINATION share/man/1)


configure_file("${PROJECT_NAME}Config.cmake.in" 
  "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}Config.cmake" 
  @ONLY)
configure_file("${PROJECT_NAME}ConfigVersion.cmake.in" 
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" 
  @ONLY)
install(FILES 
  "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}Config.cmake" 
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" 
  DESTINATION share/cmake/${PROJECT_NAME})


#file(GLOB_RECURSE ETC_HEADERS 
#  "${PROJECT_SOURCE_DIR}/libelf/*.h"
#  "${PROJECT_SOURCE_DIR}/libdwarf/*.h"
#  "${PROJECT_SOURCE_DIR}/common/elfdefinitions.h")
#install(FILES ${ETC_HEADERS} DESTINATION include)
