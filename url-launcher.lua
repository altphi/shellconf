#!/usr/bin/env lua

local width = 120

local searches = {
    ["a"] = "https://www.amazon.com/s?k=",
    ["g"] = "https://www.google.com/search?q=",
    ["d"] = "https://duckduckgo.com/?q=",
    ["bwb"] = "https://www.betterworldbooks.com/search/results?q=",
    ["i"] = "https://github.com/classiclearning/Issues/issues/",
    ["it"] = "https://github.com/classiclearning/tigger/issues/",
}

local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function truncate_path(full_path, home)
    local relative = full_path:gsub("^" .. home .. "/", "~/")
    if relative == full_path then
        return full_path, full_path
    end

    local components = {}
    for part in relative:gmatch("[^/]+") do
        table.insert(components, part)
    end

    if #components <= 2 then
        return relative, full_path
    end

    local truncatedPath = components[1] .. "/" .. components[2] -- Keep ~ and top-level directory
    for i = 3, #components - 2 do
        truncatedPath = truncatedPath .. "/~" .. components[i]:sub(1, 1)
    end
    if #components >= 3 then
        truncatedPath = truncatedPath .. "/" .. components[#components - 1] .. "/" .. components[#components]
    end

    return truncatedPath, full_path
end

local handle = io.popen('fuzzel -w '..width..' --dmenu --prompt="Search or command: "')

if handle==nil then
  return 1;
end

local input = trim(handle:read("*a"))
handle:close()

if input == "" then
    os.exit(0)
end

local shortcut = input:match("^%S+")
local query = trim(input:match("^%S+%s+(.*)") or "")

if searches[shortcut] then
    local encoded_query = query:gsub(" ", "+")
    os.execute('xdg-open "' .. searches[shortcut] .. encoded_query .. '" 2>/dev/null')
elseif input:match("^http.*") then
    os.execute('xdg-open "' .. input .. '" 2>/dev/null')
elseif shortcut == "pdf" then
    local home = os.getenv("HOME")
    local db = home .. "/.locate.db"
    local grep_pattern = (query == "") and "." or query
    local cmd = 'plocate -d "' .. db .. '" -r \'\\.pdf$\' | grep -i "' .. grep_pattern .. '"'
    local handle_pdf = io.popen(cmd)
    if handle_pdf==nil then
      os.execute('notify-send "No PDFs found" "Query: ' .. query .. '"')
      os.exit(1)
    end
    local pdfs = handle_pdf:read("*a")
    handle_pdf:close()
    if pdfs == "" then
        os.execute('notify-send "No PDFs found" "Query: ' .. query .. '"')
        os.exit(1)
    end
    local pdf_list = {}
    local path_map = {} -- Map truncated paths to full paths
    for line in pdfs:gmatch("[^\n]+") do
        local truncated, full_path = truncate_path(line, home)
        table.insert(pdf_list, truncated)
        path_map[truncated] = full_path
    end
    local pdf_string = table.concat(pdf_list, "\\n")
    local echo_cmd = 'printf "' .. pdf_string .. '\\n" | fuzzel -w '..width..' --dmenu --prompt="Select PDF: "'
    local handle_select = io.popen(echo_cmd)
    if handle_select==nil then
      os.execute('notify-send "No PDFs found" "Query: ' .. query .. '"')
      os.execute('notify-send "command was "' .. cmd .. '"')
      os.exit(1)
    end

    local selected = trim(handle_select:read("*a"))
    handle_select:close()
    if selected ~= "" then
        local full_path = path_map[selected] or selected
        os.execute('xdg-open "' .. full_path .. '" 2>/dev/null')
    end
else
    os.execute('fuzzel --no-run-if-empty "' .. input .. '"')
end
