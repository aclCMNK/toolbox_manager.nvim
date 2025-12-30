local API = {
	IDGen = function()
		local usedIDs = {}
		local timestamp = os.time()
		local random = math.random(10000, 99999)
		local id = string.format("%d_%d", timestamp, random)
		-- Asegurar unicidad en caso de colisión
		while usedIDs[id] do
			random = math.random(10000, 99999)
			id = string.format("%d_%d", timestamp, random)
		end
		usedIDs[id] = true
		return id
	end
}

local M = {}
local _fzf = nil
local _fzf_props = {}
local _tools = {}
local _rendered_tools = {}
local _ID = -1

local function find_node_by_id(tools)
	local node = nil
	for k, v in pairs(tools) do
		if v.id == _ID then
			node = v
			return node
		end
		if type(v.tools) == "table" then
			node = find_node_by_id(v.tools)
		end
	end
	return node
end

local function run_cmd(cmd, commands)
	if type(commands[cmd]) == "string" then
		vim.cmd(commands[cmd])
	elseif type(commands[cmd]) == "function" then
		commands[cmd]()
	end
end

local function bind_list()
	vim.cmd(":redraw!")
	local node = find_node_by_id(_rendered_tools)
	if type(node) == "nil" then
		node = { tools = _rendered_tools }
	end

	local title = node.label or ""
	if #title > 0 then
		title = title .." > "
	end
	local labels = {}
	local commands = {}
	for _, v in pairs(node.tools) do
		local has_childs = type(v.tools) == "table"
		local openner_childs = ""
		if has_childs then
			openner_childs = " >>>"
		end
		local label = v.label .. openner_childs
		table.insert(labels, label)
		if type(v.action) ~= "nil" then
			commands[label] = v.action
		elseif type(v.tools) then
			commands[label] = function()
				_ID = v.id
				bind_list()
			end
		end
	end
	if _fzf ~= nil then
		_fzf_props["prompt"] = "ToolBox > Tools > " .. title
		_fzf_props["cwd"] = vim.loop.cwd()
		_fzf_props["actions"] = {
			["default"] = function(selected)
				local choice = selected[1]
				if choice then
					run_cmd(choice, commands)
				end
			end
		}
		if _fzf_props["winopts"] == nil then
			_fzf_props["winopts"] = {
				height = 0.35,
				width = 0.50,
				border = "rounded",
			}
		end
		_fzf.fzf_exec(labels, _fzf_props)
		return
	end
	vim.ui.select(labels, { prompt = "ToolBox > Tools" .. title }, function(choice)
		if choice then
			run_cmd(choice, commands)
		end
	end)
end

local function classify_tools(tools, gparent)
	gparent = gparent or {}
	local rtools = {}
	for k, v in pairs(tools) do
		if type(v.label) ~= "string" then
			goto continue
		end
		local node_data = { label = v.label, id = API.IDGen(), gparent = gparent.id or -1 }
		if type(v.action) ~= "nil" then
			node_data.action = v.action
		elseif type(v.tools) == "table" then
			node_data.tools = classify_tools(v.tools, node_data)
			table.insert(node_data.tools, {
				label = "<<< Back",
				id = API.IDGen(),
				action = function()
					_ID = node_data.gparent
					bind_list()
				end
			})
		end
		table.insert(rtools, node_data)
		::continue::
	end
	return rtools
end

local function Select()
	_rendered_tools = classify_tools(_tools)
	bind_list()
end

M.setup = function(props)
	props = props or {}
	_tools = props.tools or {}
	local has_fzflua, _ = pcall(require, "fzf-lua")
	if has_fzflua == true then
		_fzf_props = props.fzf_lua or {}
		_fzf = require("fzf-lua")
	end
	vim.api.nvim_create_user_command("ToolBox", Select, {})
end

return M
