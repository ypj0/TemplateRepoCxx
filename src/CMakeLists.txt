file(GLOB_RECURSE core_sources CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx"
)
add_library(my_project_core STATIC ${core_sources})
add_library(my_project::core ALIAS my_project_core)
target_include_directories(my_project_core PUBLIC ${PROJECT_SOURCE_DIR}/include)
target_compile_features(my_project_core PUBLIC cxx_std_20)
my_project_enable_warnings(my_project_core)
