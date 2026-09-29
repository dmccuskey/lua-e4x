# Development

How lua-e4x is put together and tested.

## Where the Code Lives

Only `dmc_lua/lua_e4x.lua` is written in this repository, and it requires nothing. The other files in `dmc_lua/` are copies, kept so the tests work from a plain clone: the tests read their XML with `lua_files`, which needs the rest. Fix them in their own repository, then copy them here by hand:

| file | owner |
|---|---|
| `lua_files.lua` | [lua-files](https://github.com/dmccuskey/lua-files) |
| `lua_error.lua` | [lua-error](https://github.com/dmccuskey/lua-error) |
| `lua_utils.lua` | [lua-utils](https://github.com/dmccuskey/lua-utils) |
| `lua_class.lua` (needed by `lua_error.lua`) | [lua-class](https://github.com/dmccuskey/lua-class) |
| `json.lua` | [lua-json-shim](https://github.com/dmccuskey/lua-json-shim) |

[DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies `lua_e4x.lua` into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module), and every DMC Solar2D library copies it from there into `dmc_corona/lib/dmc_lua/`. The `Snakefile` lists no requirements: lua-files is needed only by the tests, which use the copy here.

## Testing

The tests are in `spec/lua_e4x_spec.lua` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
++++++++
17 successes / 0 failures / 0 errors / 0 pending : 0.007218 seconds
```

They parse `spec/xml/test-01.xml` and check dot traversal, attributes, `toString()` and `toXmlString()`, then check each parser fix of version 0.2.0 on small strings: names, mixed content, CDATA, comments and DOCTYPE, entities, errors, globals. They don't cover anything in the [Known Issues](api.md#known-issues).
