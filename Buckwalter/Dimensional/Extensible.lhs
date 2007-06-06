Buckwalter.Dimensional.Extensible -- Extensible physical dimensions
Bjorn Buckwalter, bjorn.buckwalter@gmail.com
License: BSD3


= Summary =

On January 3 Mike Gunter asked[1]:

| The very nice Buckwalter and Denney dimensional-numbers packages
| both work on a fixed set of base dimensions.  This is a significant
| restriction for me--I want to avoid adding apples to oranges as
| well as avoiding adding meters to grams.  Is it possible to have
| an extensible set of base dimensions?  If so, how usable can such
| a system be made?  Is it very much worse than a system with a fixed
| set of base dimensions?

In this module we facilitate the addition an arbitrary number of
"extra" dimensions to the seven base dimensions defined in
'Buckwalter.Dimensional'. A quantity or unit with one or more extra
dimensions will be referred to as an "extended Dimensional".


= Preliminaries =

Similarly with 'Buckwalter.Dimensional' this module requires GHC
6.6 or later.

> {-# OPTIONS_GHC -fglasgow-exts -fallow-undecidable-instances #-}

> module Buckwalter.Dimensional.Extensible (DExt) where

> import Buckwalter.Dimensional ( Dim, Mul, Div, Pow, Root )
> import Buckwalter.NumType ( NumType, Sum, Negate, Zero, Pos, Neg ) 
> import qualified Buckwalter.NumType as N ( Div, Mul )


= 'DExt', 'Apples' and 'Oranges' =

We define the datatype 'DExt' which we will use to increase the
number of dimensions from the seven SI base dimensions to an arbitrary
number of dimensions.

> data DExt t n d

The type variable 't' is used to tag the extended dimensions with
an identity, thus preventing inadvertent mixing of extended dimensions.

Using 'DExt' we can define type synonyms for extended dimensions
applicable to our problem domain. For example, Mike Gunter could
define the 'Apples' and 'Oranges' dimensions and the corresponding
quantities.

] data TApples -- Type tag.
] type DApples  = DExt TApples Pos1 DOne
] type Apples   = Quantity DApples

] data TOrange -- Type tag.
] type DOranges = DExt TApples Zero (DExt TOranges Pos1 DOne)
] type Oranges  = Quantity DOranges

And while he was at it he could define corresponding units.

] apple  :: Num a => Unit DApples a
] apple  = Dimensional 1
] orange :: Num a => Unit DOranges a
] orange = Dimensional 1

When extending dimensions we adopt the convention that the first
(outermost) dimension is the reference for aligning dimensions, as
shown in the above example. This is important when performing
operations on two Dimensionals with a differing number of extended
dimensions.


= The 'DropZero' class =

The choice of convention may seem backwards considering the opposite
convention is used for NumTypes (though for NumTypes the distinction
is arguably irrelevant). However, this choice facilitates relatively
simple interoperability with base dimensions. In particular it lets
us drop any dimensions with zero extent adjacent to the terminating
'Dim'. To capture this property we define the 'DropZero' class.

> class DropZero d d' | d -> d'

The following 'DropZero' instances say that when an extended dimension
with zero extent is next to a 'Dim' the extended dimension can be
dropped. In all other cases the dimensions are retained as is.

> instance DropZero (DExt t Zero (Dim l m t i th n j)) (Dim l m t i th j j)
> instance DropZero (DExt t Zero (DExt t' n d)) (DExt t Zero (DExt t' n d))
> instance DropZero (DExt t (Pos n) d) (DExt t (Pos n) d)
> instance DropZero (DExt t (Neg n) d) (DExt t (Neg n) d)


= Classes from 'Buckwalter.Dimensional' = 

We get negation, addition and subtraction for free with extended
Dimensionals. However, we will need instances of the 'Mul', 'Div',
'Pow' and 'Root' classes for the corresponding operations to work.

Multiplication and division can cause dimensions to be eliminated.
We use the 'DropZero' type class to guarantee that the result of a
multiplication or division has a minimal representation.

When only one of the 'Mul' factors is an extended dimensional there is
no need to minimize.

> instance (Mul d (Dim l m t i th n j) d') 
>       => Mul (DExt t x d) (Dim l m t i th n j) (DExt t x d')
> instance (Mul (Dim l m t i th n j) d d') 
>       => Mul (Dim l m t i th n j) (DExt t x d) (DExt t x d')

If both of the factors are extended the product must be minimized.

> instance (Sum n n' n'', Mul d d' d'', DropZero (DExt t n'' d'') d''') 
>       => Mul (DExt t n d) (DExt t n' d') d'''

Analogously for 'Div'.

> instance (Div d (Dim l m t i th n j) d') 
>       => Div (DExt t x d) (Dim l m t i th n j) (DExt t x d')
> instance (Div (Dim l m t i th n j) d d', Negate x x') 
>       => Div (Dim l m t i th n j) (DExt t x d) (DExt t x' d')

> instance (Sum n'' n' n, Div d d' d'', DropZero (DExt t n'' d'') d''') 
>       => Div (DExt t n d) (DExt t n' d') d'''

The instances for 'Pow' and 'Root' are simpler since they can not
change any previously non-zero to be eliminated.

> instance (N.Mul n x n', Pow d x d')   => Pow  (DExt t n d) x (DExt t n' d')
> instance (N.Div n x n', Root  d x d') => Root (DExt t n d) x (DExt t n' d')


= WARNING =

The use of 'DExt' is not particularily safe and care must be taken
when using more than one extended dimension. Consider for example
the following example.

] module Apples where
]
] type DApples  = DExt Pos1 DOne
] type Apples   = Quantity DApples

] module Oranges where
]
] import Apples
]
] type DOranges = DExt Pos1 DOne
] type Oranges  = Quantity DOranges

The author of the Oranges module has inadvertently defined Oranges
to be identical with Apples, thus allowing the to be e.g. added
together. This was obviously not the intent but unless the author
knows the inner workings of the Apples module he can not avoid this
situation. Thus extended dimensions as defined in this module are
not safely modular.

Rule of thumb: Extended dimensions should not cross module boundaries.
They should be defined and used in the same module and should not
be exported.

This is a significant shortcoming. Accidental mixing could be
prevented by adding a phantom type "tag" to 'DExt'. This would make
it safe for extended dimensions to cross module boundaries. However,
extended dimensions from different modules would not be compatible
(in terms of e.g. multiplication) with each other in this situation.


= References =

[1] http://www.haskell.org/pipermail/haskell-cafe/2007-January/021069.html

