# luabuild.nvim
A lua build system for neovim.

## Install

```lua
use {
    "qgymib/luabuild.nvim",
    requires = "plenary.nvim"
}
```

To use existing compile rule, try [luabuild-addons.nvim](https://github.com/qgymib/luabuild-addons.nvim).

## Usage

`luabuild.nvim` has only one interface:

```lua
require("luabuild").make(rule, opt)
```

`rule` could contains following fields:
+ `name`: _string_
    
    > The name of target. Extension will be appended automatically according to OS and `mode`.
    
+ `mode`: _string_
    
    > Target binary type. One of "exe" / "static" / "shared".
    
+ `include`: _string list_
    
    > Additional include path list.
    
+ `source`: _string list_
    
    > Source file list.
    
+ `install`: _string_
    
    > Install path.
    
+ `standard`: _table_
    - `standard.c` is the standard for c language, can be one of "c90" / "c99" / "c11" / "c17".
    - `standard.cxx` is the standard for c++ language, can be one of "c++11" / "c++14" / "c++17" / "c++20" / "c++23".

`opt` could contains following fields:
+ `cwd`: _string_
    
    > Current working director.
    
+ `tmp`: _string_
    
    > Temp build directory. By default is "luabuild.tmp"
    
+ `type`: _string_
    
    > Build type, one of "debug" / "release". Default is "release".

## Example

Let's take [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) as example. The meaningful part of their makefile is:

```Makefile
CFLAGS = -Wall -Werror -fpic -std=gnu99
COVERAGE ?=

ifeq ($(OS),Windows_NT)
    MKD = -mkdir
    RM = cmd /C rmdir /Q /S
    CC = gcc
    TARGET := libfzf.dll
else
    MKD = mkdir -p
    RM = rm -rf
    TARGET := libfzf.so
endif

all: build/$(TARGET)

build/$(TARGET): src/fzf.c src/fzf.h
	$(MKD) build
	$(CC) -O3 $(CFLAGS) -shared src/fzf.c -o build/$(TARGET)
```

The equal luabuild code is:
```lua
require("luabuild").make({
    -- Target name is 'libfzf.dll', the extension will be automatically added.
    name = "libfzf",
    -- We need to build a dll, known as `shared` library.
    mode = "shared",
    -- Install to 'build' directory
    install = "build",
    -- Add source file here
    source = { "src/fzf.c" },
    -- They use '-std=gnu99', it is c99 standard
    standard = { c = "c99" },
})
```
