/**************************************************/

dn_start
  = $dn_comma 

dn_comma
  = dn_assign (dn_COMMA dn_assign)*

dn_assign
  = $dn_ID $dn_ASSIGN $dn_assign { return text; }
  / $dn_conditional
  / $dn_comparison
  / $dn_function_definition

dn_conditional
  = dn_IF dn_comparison dn_THEN dn_assign dn_ELSE dn_assign

dn_comparison
  = dn_additive dn_COMPARISON dn_additive  / dn_additive

dn_additive
  = dn_multiplicative (dn_ADDOP dn_multiplicative)*
  / dn_multiplicative

dn_function_definition
  = dn_DEFINITION dn_LEFTPAR (dn_ID (dn_COMMA dn_ID)*)? dn_RIGHTPAR $[^,\dn_n]*

dn_multiplicative
  = dn_primary (dn_MULOP dn_primary)*
  / dn_primary

dn_primary
  = dn_integer
  / dn_function_call
  / dn_PRINT dn_primary
  / dn_ID
  / dn_LEFTPAR dn_comma dn_RIGHTPAR

dn_function_call
  = dn_ID dn_LEFTPAR dn_params dn_RIGHTPAR

dn_params = (dn_assign dn_COMMA)* dn_assign?

dn_integer "dn_integer"
  = dn_NUMBER

dn__ = $[ \t\n\r]*

dn_ADDOP = dn_PLUS / dn_MINUS
dn_MULOP = dn_MULT / dn_DIV
dn_PLUS  = dn__"+"dn__
dn_MINUS = dn__"-"dn__
dn_MULT  = dn__"*"dn__
dn_DIV   = dn__"/"dn__
dn_COMPARISON =  dn__ $([<>=!]"=") dn__
           /  dn__ [<>] dn__
dn_LEFTPAR = dn__"("dn__
dn_RIGHTPAR = dn__")"dn__
dn_DEFINITION = dn__"->"dn__
dn_COMMA = dn__","dn__
dn_IF = dn__"if"dn__
dn_ELSE = dn__"else"dn__
dn_THEN = dn__"then"dn__
dn_PRINT = dn__"print"dn__

dn_NUMBER = dn__ $[0-9]+ dn__
dn_ID = dn__ $([a-z_]i$([a-z0-9_]i*)) dn__
dn_ASSIGN = dn__ '=' dn__


