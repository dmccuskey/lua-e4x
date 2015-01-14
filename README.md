### Overview ###

`lua_e4x` is an implementation of E4X for sane XML navigation in Lua. The API is modeled closely after the one for Adobe e4x (_see references_).

Requires: lua-error, lua-files, lua-objects, lua-utils (all included)


### Usage ###

**Searching via Dot Traversal**

```lua
xml.book  -- searches all children of the XML root for `book` elements.

xml.book.title  -- searches all children of each `book` result for `title` child-elements and returns those results, and so on.

xml.book[1].author  -- only searches the first `book` element for any `author` child-elements.
```


### More Info ###


**Documentation**

http://docs.davidmccuskey.com/

**Examples**

There are a lot of examples found in the test dir. There is also a micro example on the documentation website.

**References**

* [Adobe e4x Docs](http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7e72.html)
