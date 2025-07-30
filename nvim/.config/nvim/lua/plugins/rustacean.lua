return {
	"mrcjkb/rustaceanvim",
	version = "^6", -- Recommended
	lazy = false, -- This plugin is already lazy
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		local mason_registry = require("mason-registry")
		local codelldb = mason_registry.get_package("codelldb")
		local extension_path = codelldb:get_install_path() .. "/extension/"
		local codelldb_path = extension_path .. "adapter/codelldb"
		local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
		-- If you are on Linux, replace the line above with the line below:
		-- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
		local cfg = require("rustaceanvim.config")
		vim.g.rustaceanvim = {
			-- Plugin configuration
			tools = {},
			-- LSP configuration
			server = {
				on_attach = function(client, bufnr)
					-- you can also put keymaps in here
					-- require("config.plugin.lsp.lsp_mappings").on_attach(client, bufnr)

					-- rustaceanvim keymaps
					local set = vim.keymap.set
					local bufopts = { noremap = true, silent = true, buffer = bufnr }
					set("n", "K", ":RustLsp hover actions<CR>", bufopts)
					set("n", "<leader>rd", ":RustLsp renderDiagnostic<CR>", bufopts)
					set("n", "J", ":RustLsp joinLines<CR>", bufopts)
					set("n", "<leader>ca", ":RustLsp codeAction<CR>", bufopts)
					set("n", "<leader>dbg", ":RustLsp debuggables<CR>", bufopts)
					set("n", "gd", vim.lsp.buf.definition, bufopts)
					set("n", "gD", vim.lsp.buf.declaration, bufopts)
					set("n", "gi", vim.lsp.buf.implementation, bufopts)
					set("n", "gr", vim.lsp.buf.references, bufopts)
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						assist = {
							importEnforceGranularity = true,
							importPrefix = "crate",
						},
						check = {
							command = "clippy",
							extraArgs = { "--no-deps" },
							allTargets = false,
						},
						inlayHints = { locationLinks = false },
						diagnostics = {
							enable = true,
							experimnetal = {
								enable = true,
							},
						},
					},
				},
			},
			-- DAP configuration
			dap = {
				adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
			},
		}
	end,
}
