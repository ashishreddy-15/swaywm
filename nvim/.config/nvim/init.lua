-- Set leader keys at the absolute top before loading lazy or other configs
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused host providers to speed up startup & silence healthcheck
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Load core options
require("config.options")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/*.lua
require("lazy").setup("plugins", {
    change_detection = { notify = false },
    rocks = { enabled = false },
})

-- Load custom keymaps
require("config.keymaps")
