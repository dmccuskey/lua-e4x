# lua-e4x

Read XML in Lua 5.1 with dot syntax: `xml.book.title` finds every `title` in every `book`.

lua-e4x parses an XML string into a tree you search the way [E4X](https://en.wikipedia.org/wiki/ECMAScript_for_XML) (ECMAScript for XML, as in ActionScript 3) does. Each step of a path searches the results of the step before it, and returns a list:

```lua
local E4X = require 'lua_e4x'

local xml = E4X.parse( [[
<order>
	<book ISBN="0942407296"><title>Baking Extravagant Pastries with Kumquats</title></book>
	<book ISBN="0865436401"><title>Emu Care and Breeding</title></book>
</order>
]] )

print( xml.book:length() )                  --> 2
print( xml.book[2].title:toString() )       --> Emu Care and Breeding
print( xml.book[1]['@ISBN']:toString() )    --> 0942407296
```

## Features

- `E4X.parse()` turns an XML string into a tree of nodes
- Dot traversal: `xml.book.author.lastName` searches children, then their children, and so on
- Attributes with `'@name'`: `xml.book['@ISBN']`
- Lists and nodes share the common methods: `child()`, `attribute()`, `length()`, `toString()`
- `toXmlString()` writes a node back out as XML
- One file, pure Lua, no dependencies; MIT licensed

It reads elements, attributes, text and CDATA, and skips comments, processing instructions and the `<!DOCTYPE>`. It doesn't validate, and some E4X behavior differs; see [Known Issues](docs/api.md#known-issues) before using it on XML you don't control.

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will read an XML file and pull out elements, attributes and lists of results.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-e4x.git
```

`lua-e4x/dmc_lua/lua_e4x.lua` is the module. The other files in `dmc_lua/` are used only by the tests.

### 2. Parse Some XML

Create `main.lua` in the same folder:

```lua
package.path = './lua-e4x/dmc_lua/?.lua;' .. package.path
local E4X = require 'lua_e4x'

local file = io.open( './lua-e4x/spec/xml/test-01.xml', 'r' )
local xml = E4X.parse( file:read( '*a' ) )
file:close()

print( xml:name() )
print( xml.book:length() )
print( xml.book.editor.lastName:toString() )
```

Run it:

```sh
lua main.lua
```

```text
order
2
Case
```

If it shows `module 'lua_e4x' not found`, or `attempt to index local 'file'`, run it from the folder that holds `lua-e4x/`.

`test-01.xml` is an `<order>` with two `<book>` elements; only the second has an `<editor>`. `xml` is the root element, `<order>`. `xml.book` searches its children for `book` elements and returns them as a list; `.editor` then searches every book in that list, and `.lastName` every editor found.

**Going further:** the file's contents are in [the example data](docs/api.md#the-example-data); how lists and nodes work ([Lists and Nodes](docs/api.md#lists-and-nodes)).

### 3. Loop Over Results and Read Attributes

Add this to the end of `main.lua`:

```lua
for i, book in xml.book:nodes() do
	print( i, book['@ISBN']:toString(), book.title:toString() )
end

print( xml.book[2]:toXmlString() )
```

`lua main.lua` now also shows:

```text
1	0942407296	Baking Extravagant Pastries with Kumquats
2	0865436401	Emu Care and Breeding
<book ISBN="0865436401" publisher="Prentice Hall"><title>Emu Care and Breeding</title><editor><lastName>Case</lastName><firstName>Justin</firstName></editor><pageCount>115</pageCount></book>
```

`nodes()` loops over a list; `[2]` picks one node from it (lists start at 1). `'@ISBN'` reads an attribute. `toXmlString()` writes the attributes in the order they're written in the XML.

**Going further:** every method on lists and nodes ([API reference](docs/api.md)); what it can't parse ([Known Issues](docs/api.md#known-issues)).

To update, pull the repository again (`git -C lua-e4x pull`), or replace `dmc_lua/lua_e4x.lua` with the newer one.

## Documentation

- [API reference](docs/api.md): the module, lists and nodes, dot traversal, attributes, every method, known issues
- [dmc-e4x](https://github.com/dmccuskey/dmc-e4x): the same module for Solar2D (formerly Corona SDK), set up like the other DMC Solar2D libraries
- [Development](docs/development.md): the tests, and where the code is copied to

Everything else is listed on the [documentation home](docs/README.md).

## License

lua-e4x is released under the [MIT License](LICENSE).
