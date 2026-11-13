local M = {}
local MAX_FILES = 5
local list = {}

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
        table.insert(parts, i.." "..name)
    end

    return table.concat(parts, " ")
end

return M
