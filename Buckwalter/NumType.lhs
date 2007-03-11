Buckwalter.NumType -- Type level integers
Bjorn Buckwalter, bjorn.buckwalter@gmail.com
License: Public domain


= Summary =

This Module provides type level representations, hereafter referred
to as "NumTypes", of the (positive and negative) integers and some
basic operations (addition, subtraction...) on these. While functions
are provided for the operations NumTypes are solely for the type
level and their only value is 'undefined'.

There are similarities with the HNats of the HList library [1],
which was indeed a source of inspiration. Occasionally references
are made to the HNats. The main addition in this module is negative
numbers.


= Preliminaries =

This module requires GHC 6.6 or later. We utilize multi-parameter
type classes, phantom types, functional dependencies and undecidable
instances (and possibly additional unidentified GHC extensions).

> {-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances #-}

> module Buckwalter.NumType {- (
> 	Zero, Pos, Neg,
> 	NumType, PosType, NegType, asIntegral,
> 	Negate, negate, Incr, incr, Decr, decr, 
>   Add, (+), Sub, (-), (*), (/), Halve, halve,
> 	Pos1, Pos2, Pos3, Neg1, Neg2, Neg3,
> 	zero, pos1, pos2, pos3, pos4, pos5, neg1, neg2, neg3, neg4, neg5
>   ) -} where

> import Prelude hiding ((*), (/), (+), (-), negate) -- (undefined, Integral)
> import qualified Prelude as P ((+), (-))

Use the same fixity for operators as the Prelude.

> infixl 6  +, -


= NumTypes =

We start by defining a class encompassing all integers with the
class function 'asIntegral' that converts from the type-level to a
value-level 'Integral'.

> class NumType n where asIntegral :: (Integral a) => n -> a

Then we define classes encompassing all positive and negative integers
respectively. The 'PosType' class corresponds to HList's 'HNat'.

> class NumType n => PosType n
> class NumType n => NegType n

Now we Define the data types used to represent integers. We begin
with 'Zero', which we allow to be used as both a positive and a
negative number in the sense of the previously defined type classes.
'Zero' corresponds to HList's 'HZero'.

> data Zero
> instance NumType Zero where asIntegral _ = 0
> instance PosType Zero
> instance NegType Zero

Next we define the "successor" type, here called 'Pos' (corresponding
to HList's 'HSucc').

> data Pos n
> instance (PosType n) => NumType (Pos n) where 
>   asIntegral _ = asIntegral (undefined :: n) P.+ 1 
> instance (PosType n) => PosType (Pos n)

We could be more restrictive using "data (PosType n) => Pos n" but
this constraint will not be checked (by GHC) anyway when 'Pos' is
used solely at the type level. 

Finally we define the "predecessor" type used to represent negative
numbers.

> data Neg n
> instance (NegType n) => NumType (Neg n) where
>   asIntegral _ = asIntegral (undefined :: n) P.- 1 
> instance (NegType n) => NegType (Neg n)
 

= Show instances =

We create show instances for the defines NumTypes for convenience.

> instance Show Zero where show _ = "NumType 0"
> instance (PosType n) => Show (Pos n) where show x = "NumType " ++ show (asIntegral x)
> instance (NegType n) => Show (Neg n) where show x = "NumType " ++ show (asIntegral x)

 
= Negation, incrementing and decrementing =

We start off with some basic building blocks. Negation is a simple
matter of recursively changing 'Pos' to 'Neg' or vice versa while
leaving 'Zero' unchanged.

> class (NumType a, NumType b) => Negate a b | a -> b, b -> a where 
>   negate :: a -> b
>   negate _ = undefined
> instance Negate Zero Zero
> instance (PosType a, NegType b, Negate a b) => Negate (Pos a) (Neg b)
> instance (NegType a, PosType b, Negate a b) => Negate (Neg a) (Pos b) 

We define two type classes for incrementing and decrementing NumTypes.
The 'incr' and 'decr' functions correspond roughly to HList's 'hSucc'
and 'hPred' respectively.

> class (NumType a, NumType b) => Incr a b | a -> b, b -> a where 
>   incr :: a -> b
>   incr _ = undefined

> class (NumType a, NumType b) => Decr a b | a -> b, b -> a where
>   decr :: a -> b
>   decr _ = undefined

To increment NumTypes we either prepend 'Pos' to numbers greater
than or equal to Zero or remove a 'Neg' from numbers less than Zero.

> instance Incr Zero (Pos Zero)
> instance (PosType a) => Incr (Pos a) (Pos (Pos a))
> instance Incr (Neg Zero) Zero
> instance (NegType a) => Incr (Neg (Neg a)) (Neg a)

Decrementing is the inverse of incrementing. 

> instance (Incr b a) => Decr a b


= Addition and subtraction =

Now let us move on towards more complex arithmetic operations. We
define classes for addition and subtraction of NumTypes.

> class (NumType a, NumType b, NumType c) 
>    => Add a b c | a b -> c, a c -> b, b c -> a where 
>       (+) :: a -> b -> c
>       _ + _ = undefined

> class (NumType a, NumType b, NumType c) 
>    => Sub a b c | a b -> c, a c -> b, b c -> a where
>       (-) :: a -> b -> c
>       _ - _ = undefined

In order to provide instances satisfying the functional dependencies
of 'Add' and 'Sub', in particular the property that any two parameters
uniquely define the third, we must use helper classes.

> class (NumType a, NumType b, NumType c) => Add' a b c | a b -> c

Adding anything to Zero gives "anything".

> instance (NumType a) => Add' Zero a a

When adding to a non-Zero number our strategy is to "transfer" type
constructors from the first type to the second type until the first
type is Zero. We use the 'incr' and 'decr' operators to do this.

> instance (PosType a, Incr b c, Add' a c d) => Add' (Pos a) b d
> instance (NegType a, Decr b c, Add' a c d) => Add' (Neg a) b d

We define our helper class for subtraction using negation and
addition.

> class (NumType a, NumType b, NumType c) => Sub' a b c | a b -> c
> instance (Negate b b', Add' a b' c) => Sub' a b c

Using the helper classes we can provide an instance of 'Add' that
satisfies its functional dependencies. We provide an instance of
'Sub' in terms of 'Add'.

> instance (Add' a b c, Sub' c b a) => Add a b c
> instance (Add c b a) => Sub a b c


= Halving =

TODO: If we fix division we this class is redundant.

We neglect to provide multiplication and division. However, let us
define a halving operator which is useful when using NumTypes to
represent powers (taking the square root requires halving the
power).

> class (NumType a, NumType b) => Halve a b | a -> b, b -> a where 
>   halve :: a -> b
>   halve _ = undefined
> instance Halve Zero Zero
> instance (PosType a, PosType b, Halve a b) => Halve (Pos (Pos a)) (Pos b) 
> instance (NegType a, NegType b, Halve a b) => Halve (Neg (Neg a)) (Neg b) 


= Multiplication =

Class for multiplication. Limited by the type checker stack. If the
multiplication is too large this error message will be emitted:

    Context reduction stack overflow; size = 20 
    Use -fcontext-stack=N to increase stack size to N

> class (NumType a, NumType b, NumType c) => Mul a b c | a b -> c where 
>   (*) :: a -> b -> c 
>   _ * _ = undefined

> instance (NumType n) => Mul Zero n Zero
> instance (PosType n, Mul n n' n'', Add n'' n' n''') => Mul (Pos n) n' n'''
> instance (NegType n, Mul n n' n'', Sub n'' n' n''') => Mul (Neg n) n' n'''




= Division =

Class for non-zero numbers. This is needed to prohibit divide-by-zero.

> class NonZero n
> instance NonZero (Pos n)
> instance NonZero (Neg n)

> -- class (NumType a, NumType b, NumType c) => Div a b c | a b -> c where 
> class Div a b c | a b -> c where 
>   (/) :: a -> b -> c 
>   _ / _ = undefined

The 'Div' instances are incomplete and only work with positive numbers.

> instance (NonZero n) => Div Zero n Zero
> instance (Sub (Pos n) (Pos n') n'', PosType n'',  Div n'' (Pos n') n''') 
>       => Div (Pos n) (Pos n') (Pos n''')
> instance (Negate n p, Negate n' p', Div (Pos p) (Pos p') (Pos p''))
>       => Div (Neg n) (Neg n') (Pos p'')
> --instance (Sub (Neg n) (Neg n') n'', NegType n'', Div n'' (Neg n') n''') => 
> --  Div (Neg n) (Neg n') (Pos n''')



> --instance (NonZero n', Div' n n' n'') => Div n n' n''


= Convenince types and values =

Finally we define some type synonyms for the convenience of clients
of the library.

> type Pos1 = Pos Zero
> type Pos2 = Pos Pos1
> type Pos3 = Pos Pos2
> type Neg1 = Neg Zero
> type Neg2 = Neg Neg1
> type Neg3 = Neg Neg2

Analogously we also define some convenience values (all 'undefined'
but with the expected types).

> zero :: Zero  -- ~ hZero
> zero = undefined
> pos1 = incr zero
> pos2 = incr pos1
> pos3 = incr pos2
> pos4 = incr pos3
> pos5 = incr pos4
> neg1 = decr zero
> neg2 = decr neg1
> neg3 = decr neg2
> neg4 = decr neg3
> neg5 = decr neg4


= References =

[1] http://homepages.cwi.nl/~ralf/HList/

