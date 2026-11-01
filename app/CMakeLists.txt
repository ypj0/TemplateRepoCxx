file(GLOB_RECURSE app_sources CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx"
)
add_executable(my_project_app ${app_sources})
target_link_libraries(my_project_app PRIVATE my_project::core)
my_project_enable_warnings(my_project_app)
