cmake_minimum_required(VERSION 3.10)

# set the project name
project(CompilerFlags)

# add the executable
add_executable(sort main.c)

set(COMP_FLAGS "")
set(COMP_FLAGS "${COMP_FLAGS} -Wall ")
set(COMP_FLAGS "${COMP_FLAGS} -Wextra --pedantic ")
set(COMP_FLAGS "${COMP_FLAGS} -Werror -pedantic-errors ")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMP_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMP_FLAGS}" CACHE STRING "" FORCE)
