# ToolBox Manager
## Description
Plugin to manage your own tools and commands for Neovim 0.9.

 - [Installation](https://github.com/aclCMNK/toolbox_manager.nvim#Installation)
 - [Usage](https://github.com/aclCMNK/toolbox_manager.nvim#Usage)

## Installation
### Simple installation
**Using Lazy**

    {
		    "aclCMNK/toolbox_manager.nvim",
		    config = function()
				    require("toolbox_manager").setup({
						    tools = {
								    {label = "[You can put icons here as well] Your tool name", action = [":neovim_command" | lua function]},
								    ...
								    {
										    label = "Your hierarchy tool", 
										    tools = {
												    {label = "Your first child tool", action = [":neovim_command" | lua function]},
												    ...
												    {label = "Your second child tool", tools = {...}}
										    }
										}
						    }
				    })
		    end
    }

### Installation with FzfLua
**Using Lazy**

    {
		    "aclCMNK/toolbox_manager.nvim",
		    dependencies = {
					"ibhagwan/fzf-lua"
				},
		    config = function()
				    require("toolbox_manager").setup({
						    tools = {
								    {label = "[You can put icons here as well] Your tool name", action = [":neovim_command" | lua function]},
								    ...
								    {
										    label = "Your hierarchy tool", 
										    tools = {
												    {label = "Your first child tool", action = [":neovim_command" | lua function]},
												    ...
												    {label = "Your second child tool", tools = {...}}
										    }
										}
						    },
						    fzf_lua = {...} -- FzfLua properties
				    })
		    end
    }

### Usage
You can use BuffersJump running this command:

    :ToolBox
This command runs the plugin depending of the instalation you defined.
You can close the selector pressing "Esc"
