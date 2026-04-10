#!/usr/bin/env lua

local width = 120

local snippets = {
    { name = "today's date (YYYY-MM-DD)", cmd = "date +%Y-%m-%d" },
    { name = "bash if-then (double brackets)", text = 'if [[ condition ]]; then\n    command\nfi' },
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

local function load_snippet_files()
    local dir = os.getenv("HOME") .. "/bin/snippets"
    local h = io.popen('ls -1 "' .. dir .. '" 2>/dev/null')
    if h == nil then return {} end
    local listing = h:read("*a")
    h:close()
    local file_snippets = {}
    for filename in listing:gmatch("[^\n]+") do
        local filepath = dir .. "/" .. filename
        local f = io.open(filepath, "r")
        if f then
            local content = f:read("*a")
            f:close()
            -- Strip trailing newline
            content = content:gsub("\n$", "")
            local name = filename:gsub("%.[^.]+$", ""):gsub("[-_]", " ")
            table.insert(file_snippets, { name = name, text = content })
        end
    end
    return file_snippets
end

local function handle_snip(query)
    local names = {}
    local snip_map = {}
    for _, s in ipairs(snippets) do
        table.insert(names, s.name)
        snip_map[s.name] = s
    end
    for _, s in ipairs(load_snippet_files()) do
        table.insert(names, s.name)
        snip_map[s.name] = s
    end
    local snip_input = table.concat(names, "\\n")
    local h = io.popen('printf "' .. snip_input .. '\\n" | fuzzel -w ' .. width .. ' --dmenu --prompt="snippet> "')
    if h == nil then os.exit(1) end
    local selected = trim(h:read("*a"))
    h:close()
    if selected ~= "" and snip_map[selected] then
        local entry = snip_map[selected]
        local result
        if entry.cmd then
            local c = io.popen(entry.cmd)
            result = trim(c:read("*a"))
            c:close()
        else
            result = entry.text
        end
        local copy = io.popen("wl-copy -t text/plain", "w")
        copy:write(result)
        copy:close()
    end
end

local function handle_pdf(query)
    local home = os.getenv("HOME")
    local db = home .. "/.locate.db"
    local grep_pattern = (query == "") and "." or query
    local cmd = 'plocate -d "' .. db .. '" -r \'\\.pdf$\' | grep -i "' .. grep_pattern .. '"'
    local h = io.popen(cmd)
    if h == nil then
        os.execute('notify-send "No PDFs found" "Query: ' .. query .. '"')
        os.exit(1)
    end
    local pdfs = h:read("*a")
    h:close()
    if pdfs == "" then
        os.execute('notify-send "No PDFs found" "Query: ' .. query .. '"')
        os.exit(1)
    end
    local pdf_list = {}
    local path_map = {}
    for line in pdfs:gmatch("[^\n]+") do
        local truncated, full_path = truncate_path(line, home)
        table.insert(pdf_list, truncated)
        path_map[truncated] = full_path
    end
    local pdf_string = table.concat(pdf_list, "\\n")
    local echo_cmd = 'printf "' .. pdf_string .. '\\n" | fuzzel -w ' .. width .. ' --dmenu --prompt="Select PDF: "'
    local handle_select = io.popen(echo_cmd)
    if handle_select == nil then
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
end

local function handle_pr(query)
    local org = os.getenv("GITHUB_DEFAULT_ORG") or ""
    if org == "" then
        os.execute('notify-send "pr_find" "Set GITHUB_DEFAULT_ORG"')
        os.exit(1)
    end
    local graphql = string.format([[
query {
  search(query: "org:%s type:pr state:open", type: ISSUE, first: 100) {
    nodes {
      ... on PullRequest {
        number
        title
        author { login }
        headRefName
        repository { nameWithOwner }
        url
        updatedAt
        isDraft
        reviewDecision
      }
    }
  }
}]], org)
    local jq_filter = [[.data.search.nodes[] | [
      (.updatedAt | split("T")[0]),
      (.repository.nameWithOwner | split("/")[1]),
      "#\(.number)",
      .author.login,
      (if .isDraft then "draft" elif .reviewDecision == "APPROVED" then "approved" elif .reviewDecision == "CHANGES_REQUESTED" then "changes" else "needs_review" end),
      .headRefName,
      .title,
      .url
    ] | @tsv]]
    -- Write query to temp file to avoid shell escaping issues
    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    f:write(graphql)
    f:close()
    local cmd = "gh api graphql -f query=\"$(cat " .. tmpfile .. ")\" --jq '" .. jq_filter .. "'"
    local h = io.popen(cmd)
    if h == nil then
        os.remove(tmpfile)
        os.execute('notify-send "pr_find" "Failed to fetch PRs"')
        os.exit(1)
    end
    local raw = h:read("*a")
    h:close()
    os.remove(tmpfile)
    if raw == nil or trim(raw) == "" then
        os.execute('notify-send "pr_find" "No open PRs found for ' .. org .. '"')
        os.exit(1)
    end
    -- Build display lines and url map
    local display_lines = {}
    local url_map = {}
    for line in raw:gmatch("[^\n]+") do
        local fields = {}
        for field in line:gmatch("[^\t]+") do
            table.insert(fields, field)
        end
        if #fields >= 8 then
            local display = string.format("%-10s  %-14s  %-5s  %-14s  %-12s  %-30s  %s",
                fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7])
            table.insert(display_lines, display)
            url_map[display] = fields[8]
        end
    end
    -- Pre-filter by initial query
    if query ~= "" then
        local filtered = {}
        local q = query:lower()
        for _, d in ipairs(display_lines) do
            if d:lower():find(q, 1, true) then
                table.insert(filtered, d)
            end
        end
        display_lines = filtered
    end
    if #display_lines == 0 then
        os.execute('notify-send "pr_find" "No PRs matching: ' .. query .. '"')
        os.exit(1)
    end
    -- Pipe to fuzzel
    local input_str = table.concat(display_lines, "\n")
    local fh = io.popen('printf "%s" "' .. input_str:gsub('"', '\\"') .. '" | fuzzel -w ' .. width .. ' --dmenu --prompt="PR> "')
    if fh == nil then os.exit(1) end
    local selected = trim(fh:read("*a"))
    fh:close()
    if selected ~= "" and url_map[selected] then
        local url = url_map[selected]
        if not os.getenv("PR_FIND_USE_SYSTEM_OPEN") and os.execute("command -v chromium >/dev/null 2>&1") then
            os.execute('chromium --new-tab "' .. url .. '" 2>/dev/null')
        else
            os.execute('xdg-open "' .. url .. '" 2>/dev/null')
        end
    end
end

local commands = {
    { key = "a",     desc = "Amazon search",     url = "https://www.amazon.com/s?k=" },
    { key = "g",     desc = "Google search",      url = "https://www.google.com/search?q=" },
    { key = "d",     desc = "DuckDuckGo search",  url = "https://duckduckgo.com/?q=" },
    { key = "bwb",   desc = "Better World Books", url = "https://www.betterworldbooks.com/search/results?q=" },
    { key = "i",     desc = "CL Issues",          url = "https://github.com/classiclearning/Issues/issues/" },
    { key = "it",    desc = "Tigger Issues",      url = "https://github.com/classiclearning/tigger/issues/" },
    { key = "rust",  desc = "Rust api docs",      url = "https://doc.rust-lang.org/stable/std/index.html?search=" },
    { key = "sp",    desc = "Play/Pause",         exec = "playerctl -a play-pause" },
    { key = "sn",    desc = "Next track",         exec = "playerctl -a next" },
    { key = "sprev", desc = "Previous track",     exec = "playerctl -a previous" },
    { key = "sf",    desc = "Seek +10s",          exec = "playerctl -a position +10" },
    { key = "sff",   desc = "Seek +30s",          exec = "playerctl -a position +30" },
    { key = "sb",    desc = "Seek -10s",          exec = "playerctl -a position -10" },
    { key = "sbb",   desc = "Seek -30s",          exec = "playerctl -a position -30" },
    { key = "snip",  desc = "Snippets",           handler = handle_snip },
    { key = "p",     desc = "Open PDF",           handler = handle_pdf },
    { key = "pr",    desc = "Find PR",            handler = handle_pr },
}

-- Build lookup map and fuzzel completion lines, sorted by key length
-- so shorter keys rank first when fuzzy match quality is tied
local cmd_map = {}
local sorted_commands = {}
for _, entry in ipairs(commands) do
    cmd_map[entry.key] = entry
    table.insert(sorted_commands, entry)
end
table.sort(sorted_commands, function(a, b) return #a.key < #b.key end)
local lines = {}
for _, entry in ipairs(sorted_commands) do
    local padded = entry.key .. string.rep(" ", 8 - #entry.key)
    table.insert(lines, padded .. entry.desc)
end
local fuzzel_input = table.concat(lines, "\\n")

local handle = io.popen('printf "' .. fuzzel_input .. '\\n" | fuzzel -w ' .. width .. ' --dmenu --match-mode=exact --no-sort --prompt="launch> "')

if handle == nil then
    return 1
end

local input = trim(handle:read("*a"))
handle:close()

if input == "" then
    os.exit(0)
end

local shortcut = input:match("^%S+")
local query = trim(input:match("^%S+%s+(.*)") or "")

local cmd = cmd_map[shortcut]
if cmd then
    -- If user selected from the list, query will be the description — treat as empty
    if query == cmd.desc then
        query = ""
    end

    if cmd.url then
        if query == "" then
            local h = io.popen('fuzzel -w ' .. width .. ' --dmenu --prompt="' .. cmd.desc .. '> "')
            if h then
                query = trim(h:read("*a"))
                h:close()
            end
        end
        if query ~= "" then
            local encoded_query = query:gsub(" ", "+")
            os.execute('xdg-open "' .. cmd.url .. encoded_query .. '" 2>/dev/null')
        end
    elseif cmd.exec then
        os.execute(cmd.exec)
    elseif cmd.handler then
        cmd.handler(query)
    end
elseif input:match("^http") then
    os.execute('xdg-open "' .. input .. '" 2>/dev/null')
else
    os.execute('fuzzel --no-run-if-empty "' .. input .. '"')
end
