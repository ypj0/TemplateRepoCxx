file(GLOB_RECURSE test_sources CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx"
)

foreach(source IN LISTS test_sources)
    file(RELATIVE_PATH relative_path "${CMAKE_CURRENT_SOURCE_DIR}" "${source}")
    string(MAKE_C_IDENTIFIER "${relative_path}" source_id)
    # Include a path hash to distinguish paths with identical sanitized names.
    string(SHA256 path_hash "${relative_path}")
    string(SUBSTRING "${path_hash}" 0 12 path_hash)
    set(target "my_project_test_${source_id}_${path_hash}")
    add_executable(${target} "${source}")
    target_link_libraries(${target} PRIVATE my_project::core)
    my_project_enable_warnings(${target})
    add_test(NAME "my_project.test.${relative_path}" COMMAND ${target})
endforeach()
