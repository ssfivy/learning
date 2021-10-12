cmake_minimum_required(VERSION 3.10)

# set the project name
project(CompilerFlags)

# add the executable
add_executable(hello main.c)

# Global compiler flags settings for all gcc compilers.
set(COMP_FLAGS "")

# ================================================================================================
# Optimization Options
# ================================================================================================

# Enable stack protector to mitigate stack clash
set(COMP_FLAGS "${COMP_FLAGS} -fstack-protector-strong ")

# Disable strict aliasing optimisations
# codebases that isn't written in a very strict way will need a lot of work to get rid of strict aliasing warning
# So instead we disable strict aliasing optimisations to make sure code don't do weird things when optimised
set(COMP_FLAGS "${COMP_FLAGS} -fno-strict-aliasing ")

# Wrap values when signed integer overflow
# This option instructs the compiler to assume that signed arithmetic overflow of addition,
# subtraction and multiplication wraps around using twos-complement representation.
# This is better than having them as undefined behavior and then having the compiler make
# optimisations based on that, which can go really bad really quick
set(COMP_FLAGS "${COMP_FLAGS} -fwrapv ")

# Trap undefined behavior
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
# https://news.ycombinator.com/item?id=28779340
#set(COMP_FLAGS "${COMP_FLAGS} -fsanitize-trap=undefined ")

# ================================================================================================
# Warnings
# ================================================================================================

set(COMP_FLAGS "${COMP_FLAGS} -Wall ")

# More potentially useful warnings to enable.
# see http://stackoverflow.com/questions/399850/best-compiler-warning-level-for-c-c-compilers
# and http://stackoverflow.com/questions/5088460/flags-to-enable-thorough-and-verbose-g-warnings
# and http://stackoverflow.com/questions/5283894/recommended-w-flags-for-building-c-with-gcc
set(COMP_FLAGS "${COMP_FLAGS} -Wextra --pedantic ")
set(COMP_FLAGS "${COMP_FLAGS} -Werror -pedantic-errors ")
set(COMP_FLAGS "${COMP_FLAGS} -Waggregate-return ")
set(COMP_FLAGS "${COMP_FLAGS} -Wcast-align -Wcast-qual -Wchar-subscripts ")
set(COMP_FLAGS "${COMP_FLAGS} -Wconversion ")
set(COMP_FLAGS "${COMP_FLAGS} -Wdisabled-optimization ")
#set(COMP_FLAGS "${COMP_FLAGS} -Wexcept ") # maybe need newer gcc?
set(COMP_FLAGS "${COMP_FLAGS} -Wfloat-equal ")
set(COMP_FLAGS "${COMP_FLAGS} -Wformat -Wformat=2 -Wformat-nonliteral -Wformat-security -Wformat-y2k ")
set(COMP_FLAGS "${COMP_FLAGS} -Wimplicit -Wimport -Winit-self -Winline ")
set(COMP_FLAGS "${COMP_FLAGS} -Winvalid-pch -Wlogical-op ")
set(COMP_FLAGS "${COMP_FLAGS} -Wunsafe-loop-optimizations  -Wlong-long -Wmissing-braces ")
set(COMP_FLAGS "${COMP_FLAGS} -Wmissing-declarations -Wmissing-field-initializers -Wmissing-format-attribute -Wmissing-include-dirs -Wmissing-noreturn    ")
set(COMP_FLAGS "${COMP_FLAGS} -Wpacked  -Wpadded -Wparentheses  -Wpointer-arith ")
set(COMP_FLAGS "${COMP_FLAGS} -Wredundant-decls -Wreturn-type ")
set(COMP_FLAGS "${COMP_FLAGS} -Wsequence-point  -Wshadow -Wsign-compare -Wsign-conversion -Wstack-protector ")
set(COMP_FLAGS "${COMP_FLAGS} -Wstrict-overflow=5 -Wstrict-aliasing -Wstrict-aliasing=2 -Wswitch  -Wswitch-default -Wswitch-enum ")
set(COMP_FLAGS "${COMP_FLAGS} -Wtrigraphs  -Wuninitialized -Wunknown-pragmas  -Wunreachable-code ")
set(COMP_FLAGS "${COMP_FLAGS} -Wunused -Wunused-function  -Wunused-label -Wundef -Wunused-parameter -Wunused-value  -Wunused-variable ")
set(COMP_FLAGS "${COMP_FLAGS} -Wvariadic-macros -Wvolatile-register-var  -Wwrite-strings ")


# ================================================================================================
# Eliminate specific warnings
# ================================================================================================
# This section is ideally empty, but sometimes we don't want to clutter our compile output with low-priority issues

# Ignore a "union initialization" bug in gcc, https://gcc.gnu.org/bugzilla/show_bug.cgi?id=80454
#set(COMP_FLAGS "${COMP_FLAGS} -Wno-missing-braces ")
# in case things are still WIP?
#set(COMP_FLAGS "${COMP_FLAGS} -Wno-unused-variable ")
# Some variables may be used on some targets, not all.
#set(COMP_FLAGS "${COMP_FLAGS} -Wno-unused-but-set-variable ")
# Some functions may be used on some targets, not all.
#set(COMP_FLAGS "${COMP_FLAGS} -Wno-unused-function ")


# ================================================================================================
# Apply common flags to actual variables
# ================================================================================================
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMP_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMP_FLAGS}" CACHE STRING "" FORCE)

# ================================================================================================
# Apply C specific flags
# ================================================================================================

# ================================================================================================
# Apply C++ specific flags
# ================================================================================================
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Weffc++ ")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wctor-dtor-privacy ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wold-style-cast -Woverloaded-virtual ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wsign-promo  ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wstrict-null-sentinel  ")


#EOF
