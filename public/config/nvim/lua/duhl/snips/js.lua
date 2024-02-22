require("luasnip.session.snippet_collection").clear_snippets "js"
local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local s = ls.snippet
local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node

ls.add_snippets("js", {
	s("cll", fmta(
		[[console.log(foo<log>)]],
		{ log = i(1) }
	))
})
