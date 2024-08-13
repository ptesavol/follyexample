cmake_minimum_required(VERSION 3.22)
include(homebrewClang.cmake)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


set (VCPKG_OVERLAY_TRIPLETS "$ENV{VCPKG_OVERLAY_TRIPLETS}")
set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")

project(follyexample CXX)
find_package(folly REQUIRED)

add_executable(follyexample
    src/follyexample.cpp
)

target_link_libraries(follyexample
    PUBLIC Folly::folly
)