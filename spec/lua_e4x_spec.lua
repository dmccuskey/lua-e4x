--====================================================================--
-- spec/lua_e4x_spec.lua
--
-- Testing for lua-e4x using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


--====================================================================--
--== Test: Lua e4x
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local E4X = require 'lua_e4x'
local File = require 'lua_files'



--====================================================================--
--== Testing Setup
--====================================================================--


describe( "Module Test: lua_e4x.lua", function()

	describe("Test: XMLList", function()

		local xml

		setup( function()
			local data_file = './spec/xml/test-01.xml'
			data = File.readFileContents( data_file )
			xml = E4X.parse( data )
		end)


		it( "method: dot traversal", function()
			assert.is.equal( xml.book:isa(E4X.XmlListClass), true )
			assert.is.equal( xml.book.title:isa( E4X.XmlListClass ), true )
		end)

		it( "method: length()", function()
			assert.is.equal( xml.book:length(), 2 )
			assert.is.equal( xml.book.title:length(), 2 )
		end)

		it( "method: attribute()", function()

			--== multiple book records

			assert.is.equal( xml.book:attribute('ISBN'):isa(E4X.XmlListClass), true )
			assert.is.equal( xml.book:attribute('ISBN'):length(), 2 )
			assert.is.equal( xml.book['@ISBN']:length(), 2 )

			local books = xml.book
			for i, attr in xml.book:attribute('ISBN'):nodes() do
				assert.are.same( books[i]:attribute('ISBN')[1], attr )
				assert.is.equal( books[i]:attribute('ISBN')[1]:toString(), attr:toString() )
			end

			assert.is.equal( xml.book:attribute('one'):length(), 0 )

		end)

		it( "method: hasOwnProperty", function()
			assert.is.equal( xml.book[1]:hasOwnProperty('title'), true )
			assert.is.equal( xml.book[1]:hasOwnProperty('@ISBN'), true )
			assert.is.equal( xml.book[1]:hasOwnProperty('@one'), false )
		end)

		it( "method: toString", function()
			assert.is.equal( xml.book[1]['@ISBN']:toString(), '0942407296' )
			assert.is.equal( xml.book[1]['@one']:toString(), nil )
		end)

	end) -- Test: XMLList



	describe("Test: XMLNode", function()

		local xml

		setup( function()
			local data_file = './spec/xml/test-01.xml'
			data = File.readFileContents( data_file )
			xml = E4X.parse( data )
		end)


		it( "Test XMLNode", function()

			assert.is.equal( xml.book[3], nil )

			assert.is.equal( xml.book[1]:isa( E4X.XmlNodeClass ), true )

			assert.is.equal( xml.book[1]:name(), 'book' )
			assert.is.equal( xml:child('book')[1]:name(), 'book' )

			assert.is.equal( xml.book[1]:length(), 1 )

			assert.is.equal( xml.book[1]:children():isa( E4X.XmlListClass ), true )
			assert.is.equal( xml.book[1]:children():length(), 3 )

			assert.is.equal( xml.book[1].title[1]:hasComplexContent(), false )
			assert.is.equal( xml.book[1].title[1]:hasSimpleContent(), true )

			assert.is.equal( xml.book[1], xml.book.title[1]:parent() )

		end)

		it( "method: toString()", function()

			--== Book 1

			assert.is.equal( xml.book[1]:toString(), '<title>Baking Extravagant Pastries with Kumquats</title><author><lastName>Contino</lastName><firstName>Chuck</firstName></author><pageCount>238</pageCount>' )
			assert.is.equal( xml.book[1]:toXmlString(), '<book ISBN="0942407296"><title>Baking Extravagant Pastries with Kumquats</title><author><lastName>Contino</lastName><firstName>Chuck</firstName></author><pageCount>238</pageCount></book>' )

			assert.is.equal( xml.book[1].title[1]:toString(), 'Baking Extravagant Pastries with Kumquats' )
			assert.is.equal( xml.book[1].title[1]:toXmlString(), '<title>Baking Extravagant Pastries with Kumquats</title>' )

			assert.is.equal( xml.book[1].author[1]:toString(), '<lastName>Contino</lastName><firstName>Chuck</firstName>' )
			assert.is.equal( xml.book[1].author[1]:toXmlString(), '<author><lastName>Contino</lastName><firstName>Chuck</firstName></author>' )

			assert.is.equal( xml.book[1]['@ISBN'][1]:toString(), '0942407296' )

			--== Book 2

			assert.is.equal( xml.book[2]:toString(), '<title>Emu Care and Breeding</title><editor><lastName>Case</lastName><firstName>Justin</firstName></editor><pageCount>115</pageCount>' )
			assert.is.equal( xml.book[2]:toXmlString(), '<book ISBN="0865436401" publisher="Prentice Hall"><title>Emu Care and Breeding</title><editor><lastName>Case</lastName><firstName>Justin</firstName></editor><pageCount>115</pageCount></book>' )

			assert.is.equal( xml.book[2].title[1]:toString(), 'Emu Care and Breeding' )
			assert.is.equal( xml.book[2].title[1]:toXmlString(), '<title>Emu Care and Breeding</title>' )

			assert.is.equal( xml.book[2].editor[1]:toString(), '<lastName>Case</lastName><firstName>Justin</firstName>' )
			assert.is.equal( xml.book[2].editor[1]:toXmlString(), '<editor><lastName>Case</lastName><firstName>Justin</firstName></editor>' )

		end)

		it( "Test: attribute()/attributes()", function()

			--== Book 1

			assert.is.equal( xml.book[1]:attribute('ISBN'):length(), 1 )
			assert.is.equal( xml.book[1]['@ISBN']:length(), 1 )

			assert.is.equal( xml.book[1]:attribute('missing'):length(), 0 )
			assert.is.equal( xml.book[1]['@missing']:length(), 0 )

			assert.is.equal( xml.book[1]:attribute('*'):length(), 1 )
			assert.is.equal( xml.book[1]:attributes():length(), 1 )

			--== Book 2

			assert.is.equal( xml.book[2]:attribute('ISBN'):length(), 1 )
			assert.is.equal( xml.book[2]['@ISBN']:length(), 1 )

			assert.is.equal( xml.book[2]:attribute('ISBN')[1]:toString(), '0865436401' )
			assert.is.equal( xml.book[2]['@ISBN'][1]:toString(), '0865436401' )

			assert.is.equal( xml.book[2]:attribute('publisher'):length(), 1 )
			assert.is.equal( xml.book[2]['@publisher']:length(), 1 )

			assert.is.equal( xml.book[2]:attribute('publisher'):toString(), 'Prentice Hall' )
			assert.is.equal( xml.book[2]['@publisher'][1]:toString(), 'Prentice Hall' )
			assert.is.equal( xml.book[2]:attribute('publisher')[1]:toXmlString(), 'publisher="Prentice Hall"' )
			assert.is.equal( xml.book[2]['@publisher'][1]:toXmlString(), 'publisher="Prentice Hall"' )

			assert.is.equal( xml.book[2]:attribute('missing'):length(), 0 )
			assert.is.equal( xml.book[2]['@missing']:length(), 0 )

			assert.is.equal( xml.book[2]:attribute('*'):length(), 2 )
			assert.is.equal( xml.book[2]:attributes():length(), 2 )

		end)

	end) -- Test: XML Node


	describe("Test: parser fixes (0.2.0)", function()

		it( "reads element names with '_' and '.'", function()
			local xml = E4X.parse( '<r><first_name>Ann</first_name><v.1 a_b="x"/></r>' )
			assert.is.equal( xml.first_name:toString(), 'Ann' )
			assert.is.equal( xml:child('v.1')[1]['@a_b']:toString(), 'x' )
		end)

		it( "searches past text nodes", function()
			local xml = E4X.parse( '<r><p>Hi <b>there</b></p><t>text</t></r>' )
			assert.is.equal( xml.p.b:toString(), 'there' )
			assert.is.equal( xml.p:child('b'):length(), 1 )
			assert.is.equal( xml.t[1].missing, nil )
			assert.is.equal( xml.t.missing:length(), 0 )
		end)

		it( "reads CDATA as text", function()
			local xml = E4X.parse( '<r><c><![CDATA[a < b & <c>]]></c></r>' )
			assert.is.equal( xml.c:toString(), 'a < b & <c>' )
			assert.is.equal( xml.c[1]:toXmlString(), '<c>a &lt; b &amp; &lt;c&gt;</c>' )
		end)

		it( "keeps the attributes of an empty root element", function()
			local xml = E4X.parse( '<config debug="1"/>' )
			assert.is.equal( xml:name(), 'config' )
			assert.is.equal( xml['@debug']:toString(), '1' )
		end)

		it( "skips comments, processing instructions and DOCTYPE", function()
			local xml = E4X.parse( '<?xml version="1.0"?>\n<!DOCTYPE r [ <!ELEMENT r ANY> ]>\n<!-- c --><r><!-- <x/> --><?pi data?><a>1</a></r>' )
			assert.is.equal( xml.declaration['@version']:toString(), '1.0' )
			assert.is.equal( xml:children():length(), 1 )
			assert.is.equal( xml.x, nil )
			assert.is.equal( xml:toXmlString(), '<r><a>1</a></r>' )
		end)

		it( "reads attribute values holding '>'", function()
			local xml = E4X.parse( "<r><a test='x > 1' b = \"2\">t</a></r>" )
			assert.is.equal( xml.a['@test']:toString(), 'x > 1' )
			assert.is.equal( xml.a['@b']:toString(), '2' )
			assert.is.equal( xml.a:toString(), 't' )
		end)

		it( "decodes and encodes entities", function()
			local xml = E4X.parse( '<r a="&lt;&amp;&quot;"><t>&#233; &#x20AC; &amp;lt; &unknown;</t><u>a &amp; b</u></r>' )
			assert.is.equal( xml['@a']:toString(), '<&"' )
			assert.is.equal( xml.t:toString(), '\195\169 \226\130\172 &lt; &unknown;' )
			assert.is.equal( xml.u[1]:toXmlString(), '<u>a &amp; b</u>' )
			assert.is.equal( xml:attribute('a')[1]:toXmlString(), 'a="&lt;&amp;&quot;"' )
		end)

		it( "reports malformed XML clearly", function()
			assert.has_error( function() E4X.parse( 'no tags' ) end, "Lua E4X: no root element found" )
			assert.has_error( function() E4X.parse( '<r><a></r>' ) end, "Lua E4X: incorrect closing label found: </r>, expected </a>" )
			assert.has_error( function() E4X.parse( '<r><a>' ) end, "Lua E4X: missing end tag </a>" )
		end)

		it( "sets no globals and has a version", function()
			assert.is_nil( rawget( _G, 'filter' ) )
			assert.is_nil( rawget( _G, 'map' ) )
			assert.is_nil( rawget( _G, 'foldr' ) )
			assert.is_nil( rawget( _G, 'encodeXmlString' ) )
			assert.is.equal( E4X.__version, '0.2.0' )
		end)

	end) -- Test: parser fixes

end) -- lua_e4x.lua

