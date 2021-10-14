local M = {}

--- Deep copy object (include dict)
-- @param obj   The object to be copyed
-- @return      A duplicated object
local function luabuild_copy_table(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[luabuild_copy_table(k)] = luabuild_copy_table(v) end
    return res
end

-- @return "gcc" or "clang" or "cl" or nil
local function luabuild_get_real_c_compier_name(name)
    if name == nil then
        return nil
    end

    local output = vim.fn.system(name)
    if string.find(output, "gcc") ~= nil then
        return "gcc"
    elseif string.find(output, "clang") ~= nil then
        return "clang"
    elseif string.find(output, "cl") ~= nil then
        return "cl"
    end
    return nil
end

local function luabuild_get_real_cxx_compiler_name(name)
    if name == nil then
        return nil
    end

    local output = vim.fn.system(name)
    if string.find(output, "gcc") ~= nil then
        return "g++"
    elseif string.find(output, "clang") ~= nil then
        return "clang++"
    elseif string.find(output, "cl") ~= nil then
        return "cl"
    end
    return nil
end

--- @return "gcc" or "clang" or "cl" or nil
local function luabuild_get_available_c_compiler()
    local cc_list = { "cc", "gcc", "clang", "cl" }
    for _, cc in ipairs(cc_list) do
        if vim.fn.executable(cc) == 1 then
            return luabuild_get_real_c_compier_name(cc)
        end
    end
    return nil
end

local function luabuild_get_available_cxx_compiler()
    local cxx_list = { "cxx", "g++", "clang++", "cl" }
    for _, cxx in ipairs(cxx_list) do
        if vim.fn.executable(cxx) == 1 then
            return luabuild_get_real_cxx_compiler_name(cxx)
        end
    end
end

local function luabuild_append_include_flags_cl(includes)
    local cflags = ""

    if includes == nil then
        return cflags
    end

    for idx, inc in ipairs(includes) do
        cflags = cflags .. (idx == 1 and "/I" or " /I") .. inc
    end
    return cflags
end

local function luabuild_append_include_flags_gcc_clang(includes)
    local cflags = ""

    if includes == nil then
        return cflags
    end

    for idx, inc in ipairs(includes) do
        cflags = cflags .. (idx == 1 and "-I" or " -I") .. inc
    end
    return cflags
end

local function luabuild_get_include_flags(compiler, includes)
    if compiler == "cl" then
        return luabuild_append_include_flags_cl(includes)
    elseif compiler == "gcc" or compiler == "clang" then
        return luabuild_append_include_flags_gcc_clang(includes)
    end
    return ""
end

local function luabuild_get_compile_c_flags_cl(mode, type, standard)
    local cflags = "/W4"
    -- append debug/release flags
    if type == "release" or type == nil then
        cflags = cflags .. " /O2"
    elseif type == "debug" then
        cflags = cflags .. " /Od /DEBUG"
    end
    -- append standard flags
    if standard == "c90" or standard == "c99" or standard == "c11" then
        cflags = cflags .. " /std:c11"
    elseif standard == "c17" then
        cflags = cflags .. " /std:c17"
    end
    return cflags
end

local function luabuild_get_compile_c_flags_gcc_clang(mode, type, standard)
    local cflags = "-Wall -Werror"
    if mode == "shared" and vim.fn.has("windows") == 0 then
        cflags = cflags .. " -fPIC"
    end
    -- append debug/release flags
    if type == "release" or type == nil then
        cflags = cflags .. " -O3"
    elseif type == "debug" then
        cflags = cflags .. " -Og"
    end
    -- append standard flags
    if standard == "c90" then
        cflags = cflags .. " -std=gnu90"
    elseif standard == "c99" then
        cflags = cflags .. " -std=gnu99"
    elseif standard == "c11" then
        cflags = cflags .. " -std=gnu11"
    elseif standard == "c17" then
        cflags = cflags .. " -std=gnu17"
    end
    return cflags
end

-- @param compiler Compiler name
-- @param mode  "executable" or "static" or "shared"
-- @param type  "release" or "debug"
local function luabuild_get_compile_c_flags(compiler, mode, type, standard)
    local cflags

    if compiler == "cl" then
        cflags = luabuild_get_compile_c_flags_cl(mode, type, standard)
    elseif compiler == "gcc" or compiler == "clang" then
        cflags = luabuild_get_compile_c_flags_gcc_clang(mode, type, standard)
    end

    return cflags
end

local function luabuild_get_compile_cxx_flags_cl(mode, type, standard)
    local cflags = "/W4"

    -- append debug/release flags
    if type == "release" or type == nil then
        cflags = cflags .. " /O2"
    elseif type == "debug" then
        cflags = cflags .. " /Od /DEBUG"
    end
    -- append standard flags
    if standard == "c++11" or standard == "c++14" then
        cflags = cflags .. " /std:c++14"
    elseif standard == "c++17" then
        cflags = cflags .. " /std:c++17"
    elseif standard == "c++20" then
        cflags = cflags .. " /std:c++20"
    elseif standard == "c++23" then
        cflags = cflags .. " /std:c++latest"
    end
    return cflags
end

local function luabuild_get_compile_cxx_flags_gcc_clang(mode, type, standard)
    local cflags = "-Wall -Werror"
    if mode == "shared" and vim.fn.has("windows") == 0 then
        cflags = cflags .. " -fPIC"
    end
    -- append debug/release flags
    if type == "release" or type == nil then
        cflags = cflags .. " -O3"
    elseif type == "debug" then
        cflags = cflags .. " -Og"
    end
    -- append standard flags
    if standard == "c++98" then
        cflags = cflags .. " -std=gnu++98"
    elseif standard == "c++11" then
        cflags = cflags .. " -std=gnu++11"
    elseif standard == "c++14" then
        cflags = cflags .. " -std=gnu++14"
    elseif standard == "c++17" then
        cflags = cflags .. " -std=gnu++17"
    elseif standard == "c++20" then
        cflags = cflags .. " -std=gnu++20"
    elseif standard == "c++23" then
        cflags = cflags .. " -std=gnu++2b"
    end
    return cflags
end

local function luabuild_get_compile_cxx_flags(compiler, mode, type, standard)
    if compiler == "cl" then
        return luabuild_get_compile_cxx_flags_cl(mode, type, standard)
    elseif compiler == "gcc" or compiler == "clang" then
        return luabuild_get_compile_cxx_flags_gcc_clang(mode, type, standard)
    end
    return nil
end

local function luabuild_get_tmp_dir(path)
    if path == nil then
        return "luabuild.tmp"
    end
    return path
end

local function luabuild_setup(target)
    local path = require("plenary.path")

    -- delete tmp directory
    local tmp_dir = path:new(target.tmp_dir)
    if tmp_dir:exists() then
        tmp_dir:rm({recursive = true})
    end
    tmp_dir = nil

    -- delete install file
    local install_target = path:new(target.install_file)
    if install_target:exists() then
        install_target:rm()
    end
    install_target = nil

    local install_dir = path:new(target.install_dir)
    if not install_dir:exists() then
        install_dir:mkdir({parents = true})
    end
    install_dir = nil

    if target.c ~= nil then
        for _, info in pairs(target.c.src) do
            local obj_path = string.match(info.object, "(.*[/\\])")

            local obj_dir = path:new(obj_path)
            obj_dir:mkdir({ parents = true })
        end
    end

    if target.cxx ~= nil then
        for _, info in pairs(target.cxx.src) do
            local obj_path = string.match(info.object, "(.*[/\\])")

            local obj_dir = path:new(obj_path)
            obj_dir:mkdir({ parents = true })
        end
    end
end

local function luabuild_get_file_extension(filename)
    return string.match(filename, "^.+%.(.+)$")
end

--- Generate compile object path from source file path
-- @param target A dict
-- @param opt User defined options
local function luabuild_add_object(target)
    local ext
    if target.c ~= nil then
        if target.c.compiler == "gcc" or target.c.compiler == "clang" then
            ext = ".o"
        elseif target.c.compiler == "cl" then
            ext = ".obj"
        end
        for k, v in pairs(target.c.src) do
            local dst_file = target.tmp_dir .. target.separator .. k .. ext
            v.object = dst_file
        end
    end

    if target.cxx ~= nil then
        if target.cxx.compiler == "g++" or target.cxx.compiler == "clang++" then
            ext = ".o"
        elseif target.cxx.compiler == "cl" then
            ext = ".obj"
        end
        for k, v in pairs(target.cxx.src) do
            local dst_file = target.tmp_dir .. target.separator .. k .. ext
            v.object = dst_file
        end
    end
end

--- Detect and choice available compiler for c/c++
-- If contains c file, compiler name will be assigned to `target.c.compiler`
-- If contains c++ file, compiler name will be assigned to `target.cxx.compiler`
-- @param target A dict
-- @return 1 for success, nil for failed
local function luabuild_detect_compiler(target)
    if target.c ~= nil then
        target.c.compiler = luabuild_get_available_c_compiler()
        if target.c.compiler == nil then
            return
        end
    end
    if target.cxx ~= nil then
        target.cxx.compiler = luabuild_get_available_cxx_compiler()
        if target.cxx.compiler == nil then
            return
        end
    end
    return 1
end

local function luabuild_add_compile_flags(target, opt)
    if target.c ~= nil then
       target.c.cflags = luabuild_get_compile_c_flags(target.c.compiler, target.mode, opt.type,
        target.standard.c)
    end
    if target.cxx ~= nil then
        target.cxx.cxxflags = luabuild_get_compile_cxx_flags(target.cxx.compiler, target.mode, opt.type,
            target.standard.cxx)
    end
end

local function luabuild_add_include_flags(target)
    if target.c ~= nil then
        local cflags = luabuild_get_include_flags(target.c.compiler, target.include)
        target.c.cflags = target.c.cflags .. " " .. cflags
    end
    if target.cxx ~= nil then
        local cxxflags = luabuild_get_include_flags(target.cxx.compiler, target.include)
        target.cxx.cxxflags = target.cxx.cxxflags .. " " .. cxxflags
    end
end

--- Generate all necessary path that will be used later
-- The following path will be generated:
--   + target.separator: path separator
--   + target.tmp_dir: directory to store temporary compile object
--   + target.install_dir: directory to store target binary
--   + target.install_file: path to target binary
-- @param target A dict contains user-defined rule
-- @param opt User-defined options
local function luabuild_setup_target_path(target, opt)
    target.separator = vim.fn.has("windows") and "\\" or "/"
    target.tmp_dir = opt.cwd .. target.separator .. luabuild_get_tmp_dir(opt.tmp)
    target.install_dir = opt.cwd .. target.separator .. target.install
    target.install_file = target.install_dir .. target.separator .. target.name

    if target.mode == "exe" and vim.fn.has("windows") then
        target.install_file = target.install_file .. ".exe"
    elseif target.mode == "static" then
        if vim.fn.has("windows") then
            target.install_file = target.install_file .. ".lib"
        else
            target.install_file = target.install_file .. ".a"
        end
    elseif target.mode == "shared" then
        if vim.fn.has("windows") then
            target.install_file = target.install_file .. ".dll"
        else
            target.install_file = target.install_file .. ".so"
        end
    end
end

local function luabuild_link_cl(target, linker, objects)
    local cmd
    if target.mode == "exe" then
        cmd = linker .. " " .. objects .. " /link /OUT:" .. target.install_file
    elseif target.mode == "static" then
        cmd = "lib " .. objects .. "/OUT:" .. target.install_file
    elseif target.mode == "shared" then
        cmd = "link /DLL /OUT:" .. target.install_file .. " " .. objects
    end
    return cmd
end

local function luabuild_link_gcc_clang(target, linker, objects)
    local cmd
    if target.mode == "exe" then
        cmd = linker .. " " .. objects .. " -o " .. target.install_file
    elseif target.mode == "static" then
        cmd = "ar " .. target.install_file .. " " .. objects
    elseif target.mode == "shared" then
        cmd = linker .. " " .. objects .. " -shared -o " .. target.install_file
    end
    return cmd
end

local function luabuild_link(target, objects)
    local cmd
    local linker = target.cxx ~= nil and target.cxx.compiler or target.c.compiler
    if linker == "cl" then
        cmd = luabuild_link_cl(target, linker, objects)
    elseif linker == "gcc" or linker == "clang" or linker == "g++" or linker == "clang++" then
        cmd = luabuild_link_gcc_clang(target, linker, objects)
    end

    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.cmd(string.format("echoerr \"%s\"", output))
        return
    end
end

local function luabuild_build_c_gcc_clang(target)
    local objects = ""
    for src, info in pairs(target.c.src) do
        local cmd = target.c.compiler .. " " .. target.c.cflags .. " -c " .. info.source .. " -o " .. info.object
        objects = objects .. " " .. info.object

        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            vim.cmd(string.format('echoerr \"%s\"', output))
            return
        end
    end
    return objects
end

local function luabuild_build_cxx_gcc_clang(target)
    local objects = ""
    for src, info in pairs(target.cxx.src) do
        local cmd = target.cxx.compiler .. " " .. target.cxx.cxxflags .. " -c " .. info.source .. " -o " .. info.object
        objects = objects .. " " .. info.object

        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            vim.cmd(string.format('echoerr \"%s\"', output))
            return
        end
    end
    return objects
end

local function luabuild_build_c_cl(target)
    local objects = ""
    for src, info in pairs(target.c.src) do
        local cmd = target.c.compiler .. " " .. target.c.cflags .. " /c " .. info.source .. " /Fo\"" .. info.object .. "\""
        objects = objects .. " " .. info.object

        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            vim.cmd(string.format('echoerr \"%s\"', output))
            return
        end
    end
    return objects
end

local function luabuild_build_cxx_cl(target)
    local objects = ""
    for src, info in pairs(target.cxx.src) do
        local cmd = target.cxx.compiler .. " " .. target.cxx.cxxflags .. " /c " .. info.source .. " /Fo\"" .. info.object .. "\""
        objects = objects .. " " .. info.object

        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            vim.cmd(string.format('echoerr \"%s\"', output))
            return
        end
    end
    return objects
end

local function luabuild_build_c(target)
    if target.c.compiler == "gcc" or target.c.compiler == "clang" then
        return luabuild_build_c_gcc_clang(target)
    elseif target.c.compiler == "cl" then
        return luabuild_build_c_cl(target)
    end
end

local function luabuild_build_cxx(target)
    if target.cxx.compiler == "g++" or target.cxx.compiler == "clang++" then
        return luabuild_build_cxx_gcc_clang(target)
    elseif target.cxx.compiler == "cl" then
        return luabuild_build_cxx_cl(target)
    end
end

local function luabuild_build_and_link(target)
    local objects = ""

    -- compile c
    if target.c ~= nil then
        objects = objects .. luabuild_build_c(target)
    end
    -- compile cxx
    if target.cxx ~= nil then
        objects = objects .. luabuild_build_cxx(target)
    end

    luabuild_link(target, objects)
end

local function luabuild_cleanup(target)
    local path = require("plenary.path")

    -- delete tmp directory
    local tmp_dir = path:new(target.tmp_dir)
    tmp_dir:rm({recursive = true})
end

local function luabuild_setup_target_table(target, opt)
    for _, src in ipairs(target.source) do
        local src_file = opt.cwd .. target.separator .. src
        local ext = string.lower(luabuild_get_file_extension(src_file))

        if ext == "c" then
            if target.c == nil then
                target.c = {}
            end
            if target.c.src == nil then
                target.c.src = {}
            end
            if target.c.src[src] == nil then
                target.c.src[src] = {}
            end
            target.c.src[src].source = src_file
        elseif ext == "cc" or ext == "cpp" or ext == "cxx" then
            if target.cxx == nil then
                target.cxx = {}
            end
            if target.cxx.src == nil then
                target.cxx.src = {}
            end
            if target.cxx.src[src] == nil then
                target.cxx.src[src] = {}
            end
            target.cxx.src[src].source = src_file
        end
    end
end

local function luabuild_setup_target(target, opt)
    luabuild_setup_target_path(target, opt)
    luabuild_setup_target_table(target, opt)
end

--- Compile and install
-- @param rule Rule table.
--  | field    | type        | describe                                                                               |
--  | -------- | ----------- | -------------------------------------------------------------------------------------- |
--  | name     | string      | The name of target                                                                     |
--  | mode     | string      | Target binary type. One of "exe" / "static" / "shared"                                 |
--  | include  | string list | Additional include path list                                                           |
--  | source   | string list | Source file list                                                                       |
--  | install  | string      | Install path                                                                           |
--  | standard | table       | + `standard.c` is the standard for c language.                                         |
--  |          |             |   can be one of "c90" / "c99" / "c11" / "c17"                                          |
--  |          |             | + `standard.cxx` is the standard for c++ language.                                     |
--  |          |             |   can be one of "c++11" / "c++14" / "c++17" / "c++20" / "c++23"                        |
-- @param opt Options table.
--  | field    | type        | describe                                                                               |
--  | -------- | ----------- | -------------------------------------------------------------------------------------- |
--  | cwd      | string      | Current working directory                                                              |
--  | tmp      | string      | Temp build directory. By default is "luabuild.tmp"                                     |
--  | type     | string      | Build type. One of "debug" / "release"                                                 |
M.make = function (rule, opt)
    local target = luabuild_copy_table(rule)
    luabuild_setup_target(target, opt)

    if not luabuild_detect_compiler(target) then
        vim.cmd[[echoerr "supported compiler not found"]]
        return
    end
    luabuild_add_object(target)

    luabuild_add_compile_flags(target, opt)
    luabuild_add_include_flags(target)

    luabuild_setup(target)
    luabuild_build_and_link(target)
    luabuild_cleanup(target)
end

return M
