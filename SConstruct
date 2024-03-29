#!/usr/bin/env python
import os
import sys

ext_name = "opensd"

env = SConscript("godot-cpp/SConstruct")
env['CXXFLAGS'].remove('-std=c++17')
env.Append(CXXFLAGS=["-std=c++20"])
#env.Append(LINKFLAGS=["-static-libstdc++"])

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/", "src/common", "src/opensdd", "src/opensd/drivers"])
sources = Glob("src/*.cpp")
sources.extend(Glob("src/common/errors.cpp"))
sources.extend(Glob("src/common/log.cpp"))
sources.extend(Glob("src/common/ini.cpp"))
sources.extend(Glob("src/common/xdg.cpp"))
sources.extend(Glob("src/common/prog_args.cpp"))
sources.extend(Glob("src/common/input_event_names.cpp"))
sources.extend(Glob("src/common/string_funcs.cpp"))
sources.extend(Glob("src/opensdd/*.cpp"))
sources.extend(Glob("src/opensdd/drivers/*.cpp"))
sources.extend(Glob("src/opensdd/drivers/backlight/*.cpp"))
sources.extend(Glob("src/opensdd/drivers/gamepad/*.cpp"))


# Generating the compilation DB (`compile_commands.json`) requires SCons 4.0.0 or later.
from SCons import __version__ as scons_raw_version

scons_ver = env._get_major_minor_revision(scons_raw_version)
if scons_ver < (4, 0, 0):
    print(
        "The `compiledb=yes` option requires SCons 4.0 or later, but your version is %s."
        % scons_raw_version
    )
    Exit(255)

env.Tool("compilation_db")
env.Alias("compiledb", env.CompilationDatabase())


# Build the shared library
library = env.SharedLibrary(
    "addons/{}/bin/lib{}{}{}".format(ext_name, ext_name, env["suffix"], env["SHLIBSUFFIX"]),
    source=sources,
)

Default(library)
