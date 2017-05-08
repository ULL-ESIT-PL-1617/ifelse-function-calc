/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */
{
  var Parser = this;
  var prefix = ">";

  var util = require('util');
  var constantSymbols = new Set(["pi", "true", "false"])
  Parser.symbolTable = Parser.symbolTable || {
    PI: Math.PI,
    true: 1,
    false: 0
  };
  var calcEval = function(input){
    // console.log(`calcEval('${input}')`);
    let PEG = require('./arithmetics.js');
    PEG.symbolTable = Parser.symbolTable;
    prefix += ">";
    let result = PEG.parse(input /*, symbolTable */);
    //console.log(util.inspect(result));
    prefix = prefix.slice(1);
    return result;
  };
}

start
  = a:comma {
             //console.log(Parser.symbolTable);
             return a;
           }

comma
  = left:assign right:(COMMA assign)* {
        return (right.length > 0) ? right[right.length - 1][1] : left;
    }

assign
  = id:ID ASSIGN a:assign {
         if (constantSymbols.has(id.toLowerCase()))
            throw "Cant override value of constant " + id.toLowerCase();
         Parser.symbolTable[id] = a;
         return a;
      }
  / conditional
  / comparison
  / function_definition

conditional
  = IF cond:comparison THEN actionsif:dn_assign ELSE actionselse:dn_assign {
    //console.log('condition = '+cond+' actionsif = '+actionsif+" actionselse = "+actionselse);
    if (cond) {
       //console.log("cond es true"); 
       return calcEval(actionsif);
    } else {
      //console.log("cond es falsa actionelse = "+actionselse+" st = "+util.inspect(Parser.symbolTable));
      return calcEval(actionselse);
    }
  }

comparison
  = left:additive comp:COMPARISON right:additive {
    let boolean = false;
    eval(`boolean = ${left} ${comp} ${right}`)
    //console.log(`comparison: ${boolean}`);
    return boolean;
  } / additive

additive
  = left:multiplicative rest:(ADDOP multiplicative)* {
       let sum = left;
       rest.forEach( (x) => {
         eval(`sum ${x[0]}= ${x[1]}`);
       });
       return sum;
    }
  / multiplicative

function_definition
  = DEFINITION LEFTPAR params:(ID (COMMA ID)*)? RIGHTPAR code:dn_assign {
        let params_array = [];
        if (params) {
          params_array.push(params[0])
          params[1].forEach((x) => {
            params_array.push(x[1]);
          });
        }
        //console.log(params_array);
        //console.log(code);
        return {
          params: params_array,
          code: code
        }
  }

multiplicative
  = left:primary rest:(MULOP primary)* {
      return rest.reduce((prod, [op, num])=>{ return eval(prod+op+num); },left);
    }
  / primary

primary
  = integer
  / PRINT p:primary { console.log(prefix+" "+p); return p; }
  / function_call
  / id:ID { 
            if (!(id in Parser.symbolTable)) { 
              throw id + " not defined"; } 
              return Parser.symbolTable[id]; 
          }
  / LEFTPAR assign:comma RIGHTPAR { return assign; }

function_call
  = id:ID LEFTPAR params:params RIGHTPAR {
      let result = 0;
      //console.log(`${id}(${util.inspect(params)})`);
      //console.log(Parser.symbolTable);
      let function_def = Parser.symbolTable[id];
      //console.log(`{${util.inspect(function_def)}}`);
      let code = "";

      if (params.length > 0) {
        //console.log("inside if");
        for (let i = 0; i < params.length; ++i) {
          code += `${function_def.params[i]} = ${params[i]},\n`
          //console.log("i = "+i+" code= '"+code+"'");
        }
      }

      code += Parser.symbolTable[id].code;
      //console.log(code);
      result = calcEval(code);
      //console.log(result);
      return result;
    }

params = r:(assign COMMA)* p1:assign? {
           if (p1 == null) return [];
           let params = (r.map(([p,_]) => p)).concat([ p1 ]);
           //console.log(params);
           return params;
         }

integer "integer"
  = NUMBER

_ = $[ \t\n\r]*

ADDOP = PLUS / MINUS
MULOP = MULT / DIV
PLUS  = _"+"_ { return '+'; }
MINUS = _"-"_ { return '-'; }
MULT  = _"*"_ { return '*'; }
DIV   = _"/"_ { return '/'; }
COMPARISON =  _ op:$([<>=!]"=") _  { return op; }
           /  _ op:[<>] _ { return op; } 
LEFTPAR = _"("_
RIGHTPAR = _")"_
DEFINITION = _"->"_
COMMA = _","_ { return ','; }
IF = _"if"_
ELSE = _"else"_
THEN = _"then"_
PRINT = _"print"_

NUMBER = _ digits:$[0-9]+ _ { return parseInt(digits, 10); }
ID = _ id:$([a-z_]i$([a-z0-9_]i*)) _ { return id; }
ASSIGN = _ '=' _

/************** DO NOTHING SCHEME: KEEP IN SYNCHRO WITH MAIN GRAMMAR *********************/

dn_start
  = $dn_comma 

dn_comma
  = dn_assign (dn_COMMA dn_assign)*

dn_assign
  = $dn_ID $dn_ASSIGN $dn_assign { return text(); }
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


