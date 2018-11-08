`` raw str
@`` tpl
~ tpl lang
@ keyword, objNew
# local ## global
& function
^ string concat
. Obj$get .(Expr)
[] Items$get
-> InnateGet ->(Expr)
<> class
=> curry
<<>> scope
? defined
?= if defined =, similar to  ||=, so no ||=
_ null
__ undefined
$ system var, method-Class spliter




# generate step
ti jssl ti2soulgen.sl bootstrap.sl //run 1min for old computer





# Simulation of human minds

## Programming

### Basic types:
Undf
Char
Num
 Short
 Int
 Long
 IntBig
 Float
 Double
 NumBig
 *Unsigned
Str
 ArrChar
 ArrCharFixed 
Func &Id?(){}
 Tpl
Arr []
 Arr*
 Chain*
Dic {}
 Dic*
 Bst
 Hash
Obj @obj 
Class @class 
Scope @scope

### Expr
Id
Call
 CallStatic
 CallDynamic

### class-obj schema
route: __
obj: ___


## Concept formation

## Thinking process

Concept sets -> Pattern match -> Pattern Response

##
State
 stateVars
 stateDef
Block
 blockVal
 blockLabel
 blockState
Func
 funcVarNames
 funcVarTypes
 funcReturn
 funcBlock
Call
 callFunc
 callArgs
Call step
 callFunc -> funcBlock -> blockState -> blockStateIns + callArgs -> blockExec
 call BlockState -> blockState -> blockStateIns -> blockExec
 call Block -> get parent state -> blockExec


1. state bind blockState
2. stateVars bind state
3. 