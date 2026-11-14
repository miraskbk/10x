local M = {}
local MAX_FILES = 5
local list = {}
local DATA_FILE = vim.fn.stdpath("data") .. "/tenx.json"

local function save()
    local table_json = vim.json.encode(list)
    vim.fn.writefile({ table_json }, DATA_FILE)
end

local function load()
    if vim.fn.filereadable(DATA_FILE) == 0 then
        vim.notify(string.format("tenx: cannot read from %s", DATA_FILE))
        return
    end
    local content = vim.fn.readfile(DATA_FILE)[1]
    list = vim.json.decode(content)
end

function M.add()
    local path = vim.api.nvim_buf_get_name(0)

    if vim.bo.buftype ~= "" then
        vim.notify("tenx: not a file buffer", vim.log.levels.WARN)
        return
    end

    if path == "" then
        vim.notify("tenx: empty file", vim.log.levels.WARN)
        return
    end

    for _, file in ipairs(list) do
        if file == path then
            vim.notify("tenx: file already pinned", vim.log.levels.WARN)
            return
        end
    end

    if #list >= MAX_FILES then
        vim.notify(string.format("tenx: cannot pin more than %d files", MAX_FILES), vim.log.levels.WARN)
        return
    end

    table.insert(list, path)
    save()
end

function M.show()
    print(vim.inspect(list))
end

function M.select(n)
    local path = list[n]
    if not path then
        vim.notify(string.format("tenx: no file in slot %d", n), vim.log.levels.WARN)
        return
    end

    vim.cmd.edit(path)
end

function M.statusline()
    local parts = {}

    for i, path in ipairs(list) do
        local name = vim.fn.fnamemodify(path, ":t")
        table.insert(parts, i .. " " .. name)
    end

    return table.concat(parts, " ")
end

function M.remove()
    local path = vim.api.nvim_buf_get_name(0)

    for i, file in ipairs(list) do
        if file == path then
            table.remove(list, i)
            vim.notify(string.format("tenx: unpinned %s", vim.fn.fnamemodify(path, ":t")), vim.log.levels.INFO)
            save()
            return
        end
    end
    vim.notify("tenx: file is not pinned", vim.log.levels.WARN)
end

function M.clear()
    list = {}
    vim.notify("tenx: cleared pinned files", vim.log.levels.INFO)
    save()
end

load()
return M
