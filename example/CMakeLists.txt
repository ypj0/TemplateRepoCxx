file(GLOB_RECURSE example_sources CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx"
)

foreach(source IN LISTS example_sources)
    file(RELATIVE_PATH relative_path "${CMAKE_CURRENT_SOURCE_DIR}" "${source}")
    string(MAKE_C_IDENTIFIER "${relative_path}" source_id)
    string(SHA256 path_hash "${relative_path}")
    string(SUBSTRING "${path_hash}" 0 12 path_hash)
    set(target "my_project_example_${source_id}_${path_hash}")
    add_executable(${target} "${source}")
    target_link_libraries(${target} PRIVATE my_project::core)
    my_project_enable_warnings(${target})
endforeach()
