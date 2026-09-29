# API Reference

Everything in lua-e4x, as of version 0.2.0.

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
| `E4X.__version` | the module's version, `'0.2.0'` |

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

A name that is also a method name gives the method, not the element: `xml.name`, `xml.parent`, `xml.length`, `xml.children` (and `xml.book.nodes` on a list). Use `child()` for those: `xml:child( 'name' )`. Names with characters Lua doesn't allow after a dot need brackets: `xml['first-name']`, `xml['dc:title']`, `xml['v1.2']`. `xml.first_name` works as it is.

Text next to child elements (`<p>Hi <b>there</b></p>`) is passed over: `xml.p.b` finds the `<b>`.

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
| `node:attributes()` | an XmlList of all its attributes, in the order they're written |
| `node:hasOwnProperty( key )` | `true` if it has a child element `key`, or with `'@key'`, an attribute `key` |
| `node:hasSimpleContent()` | `true` if it has no child elements (only text, or nothing) |
| `node:hasComplexContent()` | `true` if it has child elements |
| `node:length()` | always 1 |
| `node:toString()` | its contents: the text for `<title>Emu Care</title>` (entities decoded), the XML of its children for an element with child elements, `''` for an empty element |
| `node:toXmlString()` | the element itself as XML, with its attributes (in the order they're written) and children, without the whitespace between elements; `&`, `<`, `>` (and `"` in attribute values) are written as entities |
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
| `attr:toString()` | its value, with entities decoded |
| `attr:toXmlString()` | `ISBN="0942407296"`, with entities encoded again |

A **text node** holds the text inside an element, or a CDATA section. `children()` returns them along with the elements:

| method | returns |
|---|---|
| `text:toString()` | the text, with entities decoded and the whitespace kept |
| `text:toXmlString()` | the same text, with `&`, `<` and `>` encoded again |
| `text:name()` | `nil` |
| `text:child( name )`, `text:attribute( name )` | an empty XmlList |

Text nodes have none of the other element methods (`length()`, `children()`, ...): calling one is an error.

## Parsing

`E4X.parse( xml_string )` reads:

- an optional XML declaration, `<?xml version="1.0"?>`, at the start. It is kept in the root's `declaration` field, and its attributes can be read like an element's: `xml.declaration['@version']:toString()`.
- elements, including empty ones (`<pageCount/>`). Names may hold letters, digits, `_`, `-`, `.`, `:` and non-ASCII (UTF-8) characters. Namespace prefixes are part of the name (`xml['dc:title']`; `xmlns` attributes are ordinary attributes);
- attributes in single or double quotes, with spaces around `=` or not; a value may hold `>`;
- text. The entities `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;` and numeric ones like `&#233;` or `&#x20AC;` (written as UTF-8) are decoded in text and in attribute values; any other entity is kept as written. Text that is only whitespace is dropped; other text keeps its whitespace.
- CDATA sections, as text nodes, not decoded.

It skips comments, processing instructions (`<?name ...?>`) and the `<!DOCTYPE>`, with an internal subset in `[ ]`.

It raises an error for:

| error | when |
|---|---|
| `Lua E4X: missing XML data to parse` | the argument isn't a string |
| `Lua E4X: XML data must have length` | the string is empty |
| `Lua E4X: no root element found` | the string has no element |
| `Lua E4X: incorrect closing label found: </b>, expected </a>` | a closing tag doesn't match the open element, e.g. `<a></b>` |
| `Lua E4X: missing end tag </a>` | an element is left open at the end |
| `Lua E4X: malformed attribute in <a>, at character 7: 'b=1/></r>'`, and the like | a tag, end tag or attribute it can't read, or an unclosed comment, CDATA section, processing instruction or DOCTYPE; the message says which, where, and shows what follows |

It checks nothing else: text before the root element becomes part of the root, and anything after the root element is ignored.

## Known Issues

- **Element names that are method names** (`name`, `parent`, `length`, `children`, `nodes`, `child`, `attribute`, ...) give the method in dot traversal; use `child( 'name' )`.
- **Element methods on a list return an empty list** instead of an error: `xml.book:children()`, `xml.book:name()`. See [XmlList](#xmllist).
- **A missing element is `nil` from a node** but an empty list from a list. See [Lists and Nodes](#lists-and-nodes).
- `node[1]` is `nil` (in E4X it is the node itself); `list:toXmlString()`, `E4X.load()` and `E4X.save()` aren't written.

Version 0.2.0 fixed those of 0.1.1: element names with `_` or `.` were cut short; searching an element that held text next to child elements, or a missing name below text, raised an error; CDATA sections raised an error; an empty root element lost its attributes; comments, processing instructions and the DOCTYPE became text; a `>` in an attribute value ended the tag; entities weren't decoded in attribute values or encoded again by `toXmlString()`; numeric entities became a single byte; `parse()` of a string with no tags gave an arithmetic error, and an element left open was accepted; attributes came out in no set order; the declaration's attributes couldn't be read; the module set the globals `filter`, `map`, `foldr` and `encodeXmlString`, and had no version field.
