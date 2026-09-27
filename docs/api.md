# API Reference

Everything in lua-e4x, as of version 0.1.1.

| name | what it is |
|---|---|
| [The module](#the-module) | what `require 'lua_e4x'` returns; using it in Solar2D |
| [The example data](#the-example-data) | the XML the examples on this page use |
| [Lists and nodes](#lists-and-nodes) | the two kinds of result, and how indexing works on each |
| [Dot traversal](#dot-traversal) | searching with `xml.a.b` |
| [Attributes](#attributes) | `'@name'` and `attribute()` |
| [XmlList](#xmllist) | methods on lists |
| [XmlNode](#xmlnode) | methods on elements, including the root |
| [Attribute and text nodes](#attribute-and-text-nodes) | the other nodes in the tree |
| [Parsing](#parsing) | what `parse()` accepts, and its errors |
| [Known issues](#known-issues) | what doesn't work as you'd expect |

## The Module

```lua
local E4X = require 'lua_e4x'
```

`lua_e4x.lua` requires no other module. In [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) and the DMC Solar2D libraries it is in `lib/dmc_lua/`, loaded as `lib.dmc_lua.lua_e4x`.

| field | |
|---|---|
| `E4X.parse( xml_string )` | parses a string of XML and returns its root element, an [XmlNode](#xmlnode). See [Parsing](#parsing). |
| `E4X.XmlListClass` | the class of lists, for `isa()`: `result:isa( E4X.XmlListClass )` |
| `E4X.XmlNodeClass` | the class of elements, for `isa()` |
| `E4X.Parser` | the parser object `parse()` uses |
| `E4X.load()`, `E4X.save()` | not written: they print `LuaE4X.load` or `LuaE4X.save` and return nothing |

The module has no version field; the version is in the source file's `VERSION`.

### In Solar2D

The module works the same in Solar2D (formerly Corona SDK). Copy `lua_e4x.lua` into your project folder, and read the XML file from the project with `system.pathForFile()`:

```lua
local E4X = require 'lua_e4x'

local path = system.pathForFile( 'books.xml', system.ResourceDirectory )
local file = io.open( path, 'r' )
local xml = E4X.parse( file:read( '*a' ) )
file:close()

print( xml.book.title:length() )
```

[dmc-e4x](https://github.com/dmccuskey/dmc-e4x) is the same module packaged like the other DMC Solar2D libraries, for projects that use them.

## The Example Data

The examples on this page use `spec/xml/test-01.xml`, parsed into `xml`:

```xml
<?xml version="1.0"?>
<order>
	<book ISBN="0942407296">
		<title>Baking Extravagant Pastries with Kumquats</title>
		<author>
			<lastName>Contino</lastName>
			<firstName>Chuck</firstName>
		</author>
		<pageCount>238</pageCount>
	</book>
	<book ISBN="0865436401" publisher="Prentice Hall">
		<title>Emu Care and Breeding</title>
		<editor>
			<lastName>Case</lastName>
			<firstName>Justin</firstName>
		</editor>
		<pageCount>115</pageCount>
	</book>
</order>
```

`xml` is the root element, `<order>`: `xml:name()` is `order`.

## Lists and Nodes

A search returns an **XmlList**: an array of results, which can be empty. Index it with a number to get one result, a **node**:

```lua
local titles = xml.book.title        -- an XmlList of both <title> elements
print( titles:length() )             --> 2

local title = xml.book.title[1]      -- the first <title>, an XmlNode
print( title:toString() )            --> Baking Extravagant Pastries with Kumquats

for i, title in xml.book.title:nodes() do
	print( i, title:toString() )
end
```

Lists count from 1. `#list` and `ipairs( list )` don't work on a list (they give 0 and nothing): use `length()` and `nodes()`.

Lists and element nodes answer the common methods the same way. On a node, the method works on that node; on a list, it works on every node in the list and puts the results together, in another list or, for `toString()`, one string:

```lua
xml.book[1].title:toString()         -- the same text
xml.book[1].title[1]:toString()

xml.book.author:child( 'lastName' )  -- lists, one <lastName> in each
xml.book.author[1]:child( 'lastName' )
```

Indexing does different things on each:

| key | on an XmlList | on an XmlNode |
|---|---|---|
| a number, `[1]` | that result, or `nil` | always `nil` |
| a name, `.book` | `child( 'book' )` of every node in the list: an XmlList, empty if there are none | its children named `book`: an XmlList, or **`nil`** if there are none |
| `['@ISBN']` | `attribute( 'ISBN' )` | `attribute( 'ISBN' )` |

So a missing element is `nil` when searched from a node, and an empty list when searched from a list. `xml.missing:length()` is an error; `xml.book.missing:length()` is 0. Check for `nil` when a path starts from a node, or use `child()`, which always returns a list.

## Dot Traversal

Each name in a path searches the **children** (not all descendants) of every result of the step before it:

```lua
xml.book                   -- the <book> children of <order>: 2 results
xml.book.author            -- the <author> children of both books: 1 result, from the first book
xml.book[1].author         -- the <author> children of the first book only
xml.book.editor.lastName   -- the <lastName> of every <editor>: 1 result, "Case"
```

A name that is also a method name gives the method, not the element: `xml.name`, `xml.parent`, `xml.length`, `xml.children` (and `xml.book.nodes` on a list). Use `child()` for those: `xml:child( 'name' )`. Names with characters Lua doesn't allow after a dot need brackets: `xml['first-name']`, `xml['dc:title']`.

## Attributes

A key that starts with `@` reads an attribute. It always returns an XmlList, empty if the attribute isn't there:

```lua
xml.book[1]['@ISBN']:toString()        --> 0942407296
xml.book['@ISBN']:length()             --> 2, one from each book
xml.book[1]['@missing']:length()       --> 0
xml.book[1]['@missing']:toString()     --> nil
xml.book[2]['@*']:length()             --> 2, all its attributes
```

`node:attribute( 'ISBN' )` is the same as `node['@ISBN']`. The results are [attribute nodes](#attribute-and-text-nodes).

## XmlList

| method | returns |
|---|---|
| `list:length()` | the number of results |
| `list:nodes()` | an iterator for `for i, node in list:nodes() do`, in document order |
| `list[i]` | the `i`th result, or `nil` |
| `list:child( name )` | a list of the children named `name` of every node in the list |
| `list:attribute( name )` | a list of the attribute `name` of every node in the list; `'*'` for all attributes |
| `list:toString()` | every node's `toString()`, joined into one string; `nil` for an empty list |
| `list:toXmlString()` | not written: raises the error `XmlList:toXmlString, not implemented` |
| `list:isa( class )` | `true` for `E4X.XmlListClass` |

Only these. The element methods below (`name()`, `children()`, `hasOwnProperty()`, ...) don't work on a list, and calling one raises no error: it returns an empty list. Pick a node first: `xml.book[1]:children()`.

## XmlNode

An element: the root that `parse()` returns, and every element a search finds.

| method | returns |
|---|---|
| `node:name()` | the element's name: `'book'` |
| `node:parent()` | the parent element; `nil` for the root |
| `node:child( name )` | an XmlList of its children named `name` (empty if none) |
| `node:children()` | an XmlList of all its children: elements and [text nodes](#attribute-and-text-nodes) |
| `node:attribute( name )` | an XmlList with the attribute `name` (empty if it isn't there); `'*'` for all |
| `node:attributes()` | an XmlList of all its attributes, in no set order |
| `node:hasOwnProperty( key )` | `true` if it has a child element `key`, or with `'@key'`, an attribute `key` |
| `node:hasSimpleContent()` | `true` if it has no child elements (only text, or nothing) |
| `node:hasComplexContent()` | `true` if it has child elements |
| `node:length()` | always 1 |
| `node:toString()` | its contents: the text for `<title>Emu Care</title>`, the XML of its children for an element with child elements, `''` for an empty element |
| `node:toXmlString()` | the element itself as XML, with its attributes (in no set order) and children, without the whitespace between elements |
| `node:isa( class )` | `true` for `E4X.XmlNodeClass` |

```lua
xml.book[1].author[1]:toString()
--> <lastName>Contino</lastName><firstName>Chuck</firstName>

xml.book[1].title[1]:toXmlString()
--> <title>Baking Extravagant Pastries with Kumquats</title>

xml.book.title[1]:parent() == xml.book[1]   --> true
```

`toString()` on a node is its text only when the node has simple content. `tostring( node )` doesn't call it: it gives `table: 0x...`.

`setName()`, `addChild()` and `addAttribute()` are also there, used by the parser. There is no method to remove anything.

## Attribute and Text Nodes

An **attribute node** comes from `'@name'` or `attribute()`:

| method | returns |
|---|---|
| `attr:name()` | the attribute's name: `'ISBN'` |
| `attr:toString()` | its value, as written in the XML (entities aren't decoded) |
| `attr:toXmlString()` | `ISBN="0942407296"` |

A **text node** holds the text inside an element. `children()` returns them along with the elements:

| method | returns |
|---|---|
| `text:toString()` | the text, with entities decoded and the whitespace kept |
| `text:toXmlString()` | the same text (entities aren't encoded again) |

Text nodes have none of the element methods (`name()`, `length()`, ...): calling one is an error.

## Parsing

`E4X.parse( xml_string )` reads:

- an optional XML declaration, `<?xml version="1.0"?>`. It is kept in the root's `declaration` field, but nothing reads it.
- elements, including empty ones (`<pageCount/>`), and namespace prefixes, which are part of the name (`xml['dc:title']`; `xmlns` attributes are ordinary attributes);
- attributes in single or double quotes;
- text. The entities `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;` and numeric ones like `&#65;` are decoded in text (not in attribute values). A numeric entity becomes one byte, so only those below 128 give the right character in UTF-8; above 255 they are an error. Text that is only whitespace is dropped; other text keeps its whitespace.

It raises an error for:

| error | when |
|---|---|
| `Lua E4X: missing XML data to parse` | the argument isn't a string |
| `Lua E4X: XML data must have length` | the string is empty |
| `incorrect closing label found:` | a closing tag doesn't match the open element, e.g. `<a></b>`; also any CDATA section |
| `malformed XML in XmlParser:parseString` | the document starts with a closing tag |
| `attempt to perform arithmetic on local 'si'` | the string has no tags at all |
| `bad argument #1 to 'char'` | a numeric entity above 255 |

It checks nothing else: elements left open at the end are accepted, text before the root element becomes part of the root, and anything after the root element is ignored.

## Known Issues

- **Element names with `_` or `.` are cut short**: `<first_name>` is read as an element named `first` (the rest is taken for attributes), so `xml.first_name` finds nothing. Only letters, digits, `-` and `:` are read.
- **Searching an element that holds text raises an error**, when the text is next to child elements (`<p>Hi <b>there</b></p>`, then `xml.p.b`) or when the name isn't there (`xml.book.title.missing`): `attempt to call method 'name' (a nil value)`. Text nodes have no `name()`. Search only elements whose children are all elements.
- **CDATA sections raise an error** (`incorrect closing label found:`).
- **Comments, processing instructions and `<!DOCTYPE>`** aren't recognized: they become text, and tags inside a comment become elements.
- **An attribute value with `>` in it** ends the tag early, so the element is read wrong.
- **An empty root element loses its attributes**: `<config debug="1"/>` parses with none. `<config debug="1"></config>` keeps them.
- **Numeric entities above 127** become a single byte (`&#233;` is not UTF-8 `é`), and above 255 an error.
- **Entities aren't decoded in attribute values**, and `toXmlString()` doesn't encode them again in text, so it can write XML that isn't valid (`<t>a & b</t>`).
- **Element names that are method names** (`name`, `parent`, `length`, `children`, `nodes`, `child`, `attribute`, ...) give the method in dot traversal; use `child( 'name' )`.
- **Element methods on a list return an empty list** instead of an error: `xml.book:children()`, `xml.book:name()`. See [XmlList](#xmllist).
- **A missing element is `nil` from a node** but an empty list from a list. See [Lists and Nodes](#lists-and-nodes).
- `node[1]` is `nil` (in E4X it is the node itself); `list:toXmlString()`, `E4X.load()` and `E4X.save()` aren't written; nothing reads the XML declaration.
- Loading the module sets the globals `filter`, `map`, `foldr` and `encodeXmlString`.
- The module has no version field.
