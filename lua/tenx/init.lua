local M = {}

local defaults = {
    max_files = 5,
}
M.config = vim.deepcopy(defaults)

local data = {}
local DATA_FILE = vim.fn.stdpath("data") .. "/tenx.json"

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", defaults, opts or {})
end

local function get_list()
    local project = vim.fn.getcwd()
    if not data[project] then
        data[project] = {}
    end
    return data[project]
end

local function save()
    local table_json = vim.json.encode(data)
    vim.fn.writefile({ table_json }, DATA_FILE)
end

local function load()
    if vim.fn.filereadable(DATA_FILE) == 0 then
        return
    end
    local content = vim.fn.readfile(DATA_FILE)[1]
    data = vim.json.decode(content)
end

function M.add()
    load()
    local list = get_list()
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

    if #list >= M.config.max_files then
        vim.notify(string.format("tenx: cannot pin more than %d files", M.config.max_files), vim.log.levels.WARN)
        return
    end

    table.insert(list, path)
    save()
end

function M.show()
    local list = get_list()
    print(vim.inspect(list))
end

function M.select(n)
    local list = get_list()
    local path = list[n]
    if not path then
        vim.notify(string.format("tenx: no file in slot %d", n), vim.log.levels.WARN)
        return
    end

    vim.cmd.edit(path)
end

function M.statusline()
    local list = get_list()
    local parts = {}
    local current = vim.api.nvim_buf_get_name(0)

    for i, path in ipairs(list) do
        local name = vim.fn.fnamemodify(path, ":t")
        local text = i .. " " .. name
        if path == current then
            text = "%#TabLineSel#" .. text .. "%#StatusLine#"
        end
        table.insert(parts, text)
    end

    return table.concat(parts, " ")
end

function M.remove()
    load()
    local list = get_list()
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
    load()
    data[vim.fn.getcwd()] = {}
    vim.notify("tenx: cleared pinned files", vim.log.levels.INFO)
    save()
end

load()
return M
