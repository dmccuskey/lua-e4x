# lua-e4x

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-e4x"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-e4x",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"lua_e4x.lua"
		],
		"requires": [
			"lua-files"
		]
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-e4x", module_config )

