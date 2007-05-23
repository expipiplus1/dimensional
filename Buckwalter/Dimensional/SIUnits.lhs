Buckwalter.Dimensional.SIUnits
Bjorn Buckwalter, bjorn.buckwalter@gmail.com
License: BSD3


= Summary =

This module defines the SI prefixes, the SI base units and the SI
derived units. It also defines the units outside of the SI that are
accepted for use with the SI.  Any chapters, sections or tables
referenced are from [1] unless otherwise specified.

> module Buckwalter.Dimensional.SIUnits where

> import Buckwalter.Dimensional
> import Buckwalter.NumType 
>   ( Neg3, Neg2, Neg1, Zero, Pos1, Pos2, Pos3, Pos4
>   , neg3, neg2, neg1, pos1, pos2, pos3
>   )
> import Prelude ( (.), Num, Fractional, Floating, recip )
> import qualified Prelude


= SI prefixes (section 4.4) =

Prefixes are used to form decimal multiples and submultiples of SI
Units as described in section 4.4. We will define the SI prefixes
in terms of the 'prefix' function which applies a scale factor to a
unit.

We define all SI prefixes from Table 5. Multiples first.

> deca, hecto, kilo, mega, giga, tera, peta, exa, zetta, yotta 
>   :: Num a => Unit d a -> Unit d a
> deca  = prefix 10 -- "deka" in international English.
> hecto = deca . deca
> kilo  = deca . hecto
> mega  = kilo . kilo
> giga  = kilo . mega
> tera  = kilo . giga
> peta  = kilo . tera
> exa   = kilo . peta
> zetta = kilo . exa
> yotta = kilo . zetta

Then the submultiples.
 
> deci, centi, milli, micro, nano, pico, femto, atto, zepto, yocto
>   :: Fractional a => Unit d a -> Unit d a
> deci  = prefix 0.1
> centi = deci . deci
> milli = deci . centi
> micro = milli . milli
> nano  = milli . micro
> pico  = milli . nano
> femto = milli . pico
> atto  = milli . femto
> zepto = milli . atto
> yocto = milli . zepto

By defining SI prefixes as functions applied to a 'Unit' we satisfy
section 6.2.6 "Unacceptability of stand-alone prefixes".


= SI base units (section 4.1) =

Now we will define the SI base unitsi from section 4.1. To avoid a
myriad of one-letter functions that would doubtlessly cause clashes
and frustration in users' code we spell out all unit names in full,
as we did for prefixes. We also elect to spell the unit names in
singular form, as allowed by section 9.7 "Other spelling conventions".

We define the SI base units in the order of table 1.

> meter   :: Num a => Unit DLength a -- "metre" in international English.
> meter   = Dimensional 1

For mass the SI base unit is kilogram. For sensible prefixes we
define gram here (see section 6.2.7 "Prefixes and the kilogram").
The drawback is that we are forced to use 'Fractional'.

> gram    :: Fractional a => Unit DMass a
> gram    = Dimensional 1e-3
> second  :: Num a => Unit DTime a
> second  = Dimensional 1
> ampere  :: Num a => Unit DElectricCurrent a
> ampere  = Dimensional 1
> kelvin  :: Num a => Unit DThermodynamicTemperature a
> kelvin  = Dimensional 1
> mole    :: Num a => Unit DAmountOfSubstance a
> mole    = Dimensional 1
> candela :: Num a => Unit DLuminousIntensity a
> candela = Dimensional 1


= SI derived units (section 4.2) =

Before defining the derived units themselves we provide type synonyms
for derived quantities and their dimensionalities. For lack of better
organization we provide definitions grouped by table in [1].


== Table 2 ==

"Examples of SI derived units expressed in terms of SI base units."

The following definitions are grouped so that a type synonym for
the dimensionality is defined first in terms of base dimension
exponents.  Then a type synonym for the corresponding quantity type
is defined. If there are several alternate names for a quantity
type one type synonyms is provided for each name.

> type DArea = Dim Pos2 Zero Zero Zero Zero Zero Zero
> type Area  = Quantity DArea

> type DVolume = Dim Pos3 Zero Zero Zero Zero Zero Zero
> type Volume  = Quantity DVolume

> type DVelocity = Dim Pos1 Zero Neg1 Zero Zero Zero Zero
> type Velocity  = Quantity DVelocity

> type DAcceleration = Dim Pos1 Zero Neg2 Zero Zero Zero Zero
> type Acceleration  = Quantity DAcceleration

> type DWaveNumber = Dim Neg1 Zero Zero Zero Zero Zero Zero
> type WaveNumber  = Quantity DWaveNumber

> type DMassDensity = Dim Neg3 Pos1 Zero Zero Zero Zero Zero
> type MassDensity  = Quantity DMassDensity
> type Density      = MassDensity -- Short name.

> type DSpecificVolume = Dim Pos3 Neg1 Zero Zero Zero Zero Zero 
> type SpecificVolume  = Quantity DSpecificVolume

> type DCurrentDensity = Dim Neg2 Zero Zero Pos1 Zero Zero Zero
> type CurrentDensity  = Quantity DCurrentDensity

> type DMagneticFieldStrength = Dim Neg1 Zero Zero Pos1 Zero Zero Zero
> type MagneticFieldStrength  = Quantity DMagneticFieldStrength

> type DAmountOfSubstanceConcentration = Dim Neg3 Zero Zero Zero Zero Pos1 Zero
> type AmountOfSubstanceConcentration  = Quantity DAmountOfSubstanceConcentration
> type Concentration                   = AmountOfSubstanceConcentration -- Short name.

> type DLuminance = Dim Neg2 Zero Zero Zero Zero Zero Pos1
> type Luminance  = Quantity DLuminance


== Table 3a ==

"SI derived units with special names and symboks, including the
radian and steradian."

The following definitions are grouped so that a type synonym for
the dimensionality is defined first in terms of base dimension
exponents.  Then a type synonym for the corresponding quantity type
is defined. If there are several quantity types with the same
dimensionality a type synonym is provided for each quantity type.
Finally the unit is defined.

> type DPlaneAngle = DOne
> type PlaneAngle  = Dimensionless
> radian :: Fractional a => Unit DPlaneAngle a
> radian = one -- meter * meter ^ neg1

> type DSolidAngle = DOne
> type SolidAngle  = Dimensionless
> steradian :: Fractional a => Unit DSolidAngle a
> steradian = one -- meter ^ pos2 * meter ^ neg2

> type DFrequency = Dim Zero Zero Neg1 Zero Zero Zero Zero
> type Frequency  = Quantity DFrequency
> hertz :: Fractional a => Unit DFrequency a
> hertz = second ^ neg1

> type DForce = Dim Pos1 Pos1 Neg2 Zero Zero Zero Zero
> type Force  = Quantity DForce
> newton :: Fractional a => Unit DForce a
> newton = kilo gram * meter * second ^ neg2

> type DPressure = Dim Neg1 Pos1 Neg2 Zero Zero Zero Zero
> type Pressure  = Quantity DPressure
> type Stress    = Quantity DPressure
> pascal :: Fractional a => Unit DPressure a
> pascal = newton / meter ^ pos2

> type DEnergy        = Dim Pos2 Pos1 Neg2 Zero Zero Zero Zero
> type Energy         = Quantity DEnergy
> type Work           = Quantity DEnergy
> type QuantityOfHeat = Quantity DEnergy
> joule :: Fractional a => Unit DEnergy a
> joule = newton * meter

> type DPower      = Dim Pos2 Pos1 Neg3 Zero Zero Zero Zero
> type Power       = Quantity DPower
> type RadiantFlux = Quantity DPower
> watt :: Fractional a => Unit DPower a
> watt = joule / second

> type DElectricCharge       = Dim Zero Zero Pos1 Pos1 Zero Zero Zero
> type ElectricCharge        = Quantity DElectricCharge
> type QuantityOfElectricity = Quantity DElectricCharge
> coulomb :: Fractional a => Unit DElectricCharge a
> coulomb = second * ampere

> type DElectricPotential  = Dim Pos2 Pos1 Neg3 Neg1 Zero Zero Zero
> type ElectricPotential   = Quantity DElectricPotential
> type PotentialDifference = Quantity DElectricPotential
> type ElectromotiveForce  = Quantity DElectricPotential
> volt :: Fractional a => Unit DElectricPotential a
> volt = watt / ampere

> type DCapacitance = Dim Neg2 Neg1 Pos4 Pos2 Zero Zero Zero
> type Capacitance  = Quantity DCapacitance
> farad :: Fractional a => Unit DCapacitance a
> farad = coulomb / volt

> type DElectricResistance = Dim Pos2 Pos1 Neg3 Neg2 Zero Zero Zero
> type ElectricResistance  = Quantity DElectricResistance
> ohm :: Fractional a => Unit DElectricResistance a
> ohm = volt / ampere

> type DElectricConductance = Dim Neg2 Neg1 Pos3 Pos2 Zero Zero Zero
> type ElectricConductance  = Quantity DElectricConductance
> siemens :: Fractional a => Unit DElectricConductance a
> siemens = ampere / volt

> type DMagneticFlux = Dim Pos2 Pos1 Neg2 Neg1 Zero Zero Zero
> type MagneticFlux  = Quantity DMagneticFlux
> weber :: Fractional a => Unit DMagneticFlux a
> weber = volt * second

> type DMagneticFluxDensity = Dim Zero Pos1 Neg2 Neg1 Zero Zero Zero
> type MagneticFluxDensity  = Quantity DMagneticFluxDensity
> tesla :: Fractional a => Unit DMagneticFluxDensity a
> tesla = weber / meter ^ pos2

> type DInductance = Dim Pos2 Pos1 Neg2 Neg2 Zero Zero Zero
> type Inductance  = Quantity DInductance
> henry :: Fractional a => Unit DInductance a
> henry = weber / ampere

We defer the definition of Celcius temperature to the end (would
appear here if we stricly followed table 3a).

> type DLuminousFlux = DLuminousIntensity
> type LuminousFlux  = LuminousIntensity
> lumen :: Fractional a => Unit DLuminousFlux a
> lumen = candela / steradian

> type DIlluminance = Dim Neg2 Zero Zero Zero Zero Zero Pos1
> type Illuminance  = Quantity DIlluminance
> lux :: Fractional a => Unit DIlluminance a
> lux = lumen / meter ^ pos2

=== Degree Celsius ===

A problematic area is units which increase proportionally to the
base SI units but cross zero at a different point. An example would
be degrees Celsius (see section 4.2.1.1). The author feels that it
is appropriate to define a unit for use with relative quantities
(taking only into account the proportionality) and complement the
unit with functions for converting absolute values.

> type DCelsiusTemperature = DThermodynamicTemperature
> type CelsiusTemperature  = ThermodynamicTemperature
> degreeCelsius :: Num a => Unit DCelsiusTemperature a
> degreeCelsius = kelvin

The function 'fromDegreeCelsiusAbsolute' should be used in lieu of
"*~ degreeCelsius" when working with absolute temperatures. Similarily,
'toDegreeCelsiusAbsolute' should be used in lieu of "/~ degreeCelsius"
when working with absolute temperatures.

> fromDegreeCelsiusAbsolute :: Fractional a => a -> ThermodynamicTemperature a
> fromDegreeCelsiusAbsolute x = x *~ degreeCelsius + 273.15 *~ degreeCelsius
> toDegreeCelsiusAbsolute :: Fractional a => ThermodynamicTemperature a -> a
> toDegreeCelsiusAbsolute x = (x - 273.15 *~ degreeCelsius) /~ degreeCelsius


== Table 3b ==

"SI derived units with special names and symbols admitted for reasons
of safeguarding human health"

We use the same grouping as for table 3a.

> type DActivity = DFrequency -- Activity of a radionuclide.
> type Activity  = Quantity DActivity
> becquerel :: Fractional a => Unit DActivity a
> becquerel = second ^ neg1

Above we gave a new name to the dimensionality instead of reusing
'Frequency' in the quantity type definition. This will allow GHCi
be more specific when queried for the type of 'becquerel'. For
quantity types without a specific unit we don't bother doing this
(though perhaps we should in case there is a non-SI unit for the
quantity type?).

> type DAbsorbedDose  = Dim Pos2 Zero Neg2 Zero Zero Zero Zero
> type AbsorbedDose   = Quantity DAbsorbedDose
> type SpecificEnergy = Quantity DAbsorbedDose -- Specific energy imparted.
> type Kerma          = Quantity DAbsorbedDose
> gray :: Fractional a => Unit DAbsorbedDose a
> gray = joule / kilo gram

> type DDoseEquivalent           = DAbsorbedDose
> type DoseEquivalent            = Quantity DDoseEquivalent
> type AmbientDoseEquivalent     = DoseEquivalent
> type DirectionalDoseEquivalent = DoseEquivalent
> type PersonalDoseEquivalent    = DoseEquivalent
> type EquivalentDose            = DoseEquivalent
> sievert :: Fractional a => Unit DAbsorbedDose a
> sievert = joule / kilo gram


== Table 4 ==

"Examples of SI derived units expressed with the aid of SI derived
units having special names and symbols."

We use the same grouping as for table 2.

> type AngularVelocity = Frequency

> type DAngularAcceleration = Dim Zero Zero Neg2 Zero Zero Zero Zero
> type AngularAcceleration  = Quantity DAngularAcceleration

> type DDynamicViscosity = Dim Neg1 Pos1 Neg1 Zero Zero Zero Zero
> type DynamicViscosity  = Quantity DDynamicViscosity

> type MomentOfForce  = Quantity DEnergy

> type DSurfaceTension = Dim Zero Pos1 Neg2 Zero Zero Zero Zero
> type SurfaceTension  = Quantity DSurfaceTension

> type DHeatFluxDensity = Dim Zero Pos1 Neg3 Zero Zero Zero Zero
> type HeatFluxDensity  = Quantity DHeatFluxDensity
> type Irradiance       = HeatFluxDensity

> type RadiantIntensity = Power

> type Radiance = Irradiance

> type DHeatCapacity = Dim Pos2 Pos1 Neg2 Zero Neg1 Zero Zero
> type HeatCapacity  = Quantity DHeatCapacity
> type Entropy       = HeatCapacity

> type DSpecificHeatCapacity = Dim Pos2 Zero Neg2 Zero Neg1 Zero Zero
> type SpecificHeatCapacity  = Quantity DSpecificHeatCapacity
> type SpecificEntropy       = SpecificHeatCapacity

Specific energy was already defined in table 3b.

> type DThermalConductivity = Dim Pos1 Pos1 Neg3 Zero Neg1 Zero Zero
> type ThermalConductivity  = Quantity DThermalConductivity

> type EnergyDensity = Pressure

> type DElectricFieldStrength = Dim Pos1 Pos1 Neg3 Neg1 Zero Zero Zero
> type ElectricFieldStrength  = Quantity DElectricFieldStrength

> type DElectricChargeDensity = Dim Neg3 Zero Pos1 Pos1 Zero Zero Zero
> type ElectricChargeDensity  = Quantity DElectricChargeDensity

> type DElectricFluxDensity = Dim Neg2 Zero Pos1 Pos1 Zero Zero Zero
> type ElectricFluxDensity  = Quantity DElectricFluxDensity

> type DPermittivity = Dim Neg3 Neg1 Pos4 Pos2 Zero Zero Zero
> type Permittivity  = Quantity DPermittivity

> type DPermeability = Dim Pos1 Pos1 Neg2 Neg2 Zero Zero Zero
> type Permeability  = Quantity DPermeability

> type DMolarEnergy = Dim Pos2 Pos1 Neg2 Zero Zero Neg1 Zero
> type MolarEnergy  = Quantity DMolarEnergy

> type DMolarEntropy     = Dim Pos2 Pos1 Neg2 Zero Neg1 Neg1 Zero
> type MolarEntropy      = Quantity DMolarEntropy
> type MolarHeatCapacity = MolarEntropy

> type DExposure = Dim Zero Neg1 Pos1 Pos1 Zero Zero Zero
> type Exposure  = Quantity DExposure -- Exposure to x and gamma rays.

> type DAbsorbedDoseRate = Dim Pos2 Zero Neg3 Zero Zero Zero Zero
> type AbsorbedDoseRate  = Quantity DAbsorbedDoseRate


= Units outside the SI =

There are several units that are not strictly part of the SI but
are either permanently or temporarily accepted for use with the SI.

== Table 6 ==

"Units accepted for use with the SI."

We start with time which we grant exclusive rights to 'minute' and
'second'.

> minute, hour, day :: Num a => Unit DTime a
> minute = prefix 60 second
> hour   = prefix 60 minute
> day    = prefix 24 hour

Since 'minute' and 'second' are already in use for time we use
'arcminute' and 'arcsecond' [2] for plane angle instead.

> degree, arcMinute, arcSecond :: Floating a => Unit DPlaneAngle a
> degree = prefix (Prelude.pi Prelude./ 180) radian
> arcminute = prefix (recip 60) degreeOfArc
> arcsecond = prefix (recip 60) minuteOfArc

Alternate (longer) forms of the above. In particular 'degreeOfArc'
can be used if there is a percieved need to disambiguate from e.g.
temperature.

> degreeOfArc, minuteOfArc, secondOfArc :: Floating a => Unit DPlaneAngle a
> degreeOfArc = degree
> secondOfArc = arcsecond
> minuteOfArc = arcminute

> liter :: Fractional a => Unit DVolume a -- "litre" in international English.
> liter = deci meter ^ pos3

> metricTon :: Fractional a => Unit DMass a
> metricTon = prefix 1000 (kilo gram) -- mega gram.

(A footnote to table 6 mentions that the metric ton is called "tonne"
in the SI standard and many countries.)


== Neper, bel, shannon and the like ==

The units of section 5.1.2 are purposefully omitted. In fact the
logarithmic units (see section 8.7) are problematic and it is not
clear how to implement them. Perhaps with a conversion function
similar to for degrees Celsius.


== Table 7 ==

TODO: Move these to NonSIUnits module.

"Units accepted for use with the SI whose values in SI units are
obtained experimentally."

The electronvolt had a standard combined uncertainity of 0.00000049e-19 J
when [1] was published.

> electronVolt :: Unit DEnergy a
> electronVolt = prefix 1.60217733e-19 joule

The unified atomic mass unit had a combined uncertainty of 0.0000010e-27 kg.

> unifiedAtomicMassUnit :: Unit DMass a
> unifiedAtomicMassUnit = prefix 1.6605402e-27 kilo gram


== Table 9 ==

"Units temporarily accepted for use with the SI."

TODO: put in NonSIUnits module.


= Other quantities =

Some other quantity types that have come in handy.

> {-
> type Angle           = PlaneAngle -- Abbreviation
> type Thrust          = Force
> type Impulse         = Quantity DImpulse
> type MassFlow        = Quantity DMassFlow
> type EnergyPerUnitMass = SpecificEnergy


> type DImpulse      = Dim Pos1 Pos1 Neg1 Zero Zero Zero Zero
> type DMassFlow     = Dim Zero Pos1 Neg1 Zero Zero Zero Zero
> type DEnergyPerUnitMass = Dim Pos2 Zero Neg2 Zero Zero Zero Zero
> -}


= References =

[1] http://physics.nist.gov/Pubs/SP811/
[2] http://en.wikipedia.org/wiki/Minute_of_arc