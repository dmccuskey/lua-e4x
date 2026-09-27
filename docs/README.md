# lua-e4x Documentation

New here? The [Quick Start](../README.md#quick-start) reads an XML file and pulls out elements, attributes and lists of results in about 5 minutes.

## Start

- [Quick Start](../README.md#quick-start): get the code, parse a file, loop over results and read attributes

## Use

- [API reference](api.md): the module, lists and nodes, dot traversal, attributes, every method, what `parse()` accepts, known issues
- [In Solar2D](api.md#in-solar2d): reading an XML file from a Solar2D project
- [dmc-e4x](https://github.com/dmccuskey/dmc-e4x): the module packaged like the other DMC Solar2D libraries
- [E4X](https://en.wikipedia.org/wiki/ECMAScript_for_XML): the ECMAScript standard the API is modeled on, as in ActionScript 3

## Contribute

- [Development](development.md): which files are copies, tests
- [Issues](https://github.com/dmccuskey/lua-e4x/issues)

## Project Structure

```text
README.md                   landing page and Quick Start
LICENSE
docs/                       this documentation
dmc_lua/
├── lua_e4x.lua             the module
├── lua_files.lua           used by the tests to read XML files (copy)
└── ...                     what lua_files.lua needs (copies)
Snakefile                   build rules, for DMC-Lua-Library
spec/
├── lua_e4x_spec.lua        tests (busted)
└── xml/test-01.xml         the XML the tests and docs use
```
