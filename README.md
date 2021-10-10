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
