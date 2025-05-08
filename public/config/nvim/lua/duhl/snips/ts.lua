require("luasnip.session.snippet_collection").clear_snippets("ts")
local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local s = ls.snippet
local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node

local tsSnips = {
  s("ternary", {
    -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
    i(1, "cond"),
    t(" ? "),
    i(2, "then"),
    t(" : "),
    i(3, "else"),
  }),
  s("cll", fmta([[console.log(<log>)]], { log = i(1) })),
  s("fn", {
    t("const "),
    i(1),
    t({ " = () => {", "\t" }),
    i(2),
    t({ "", "};" }),
  }),
  s("{}", { t({ "{", "  " }), i(1), t({ "", "};" }) }),
}

ls.add_snippets("all", tsSnips)
-- ls.add_snippets("typescript", tsSnips)
-- ls.add_snippets("typescriptreact", tsSnips)
