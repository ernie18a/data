<!-- tradingview-pine-id: PUB;f9Aq9UQUZN1dY47QpVxTHsvJNcfdGdE7 -->
<!-- tradingviewscripts-format: 1 -->
# Reflex Oscillator - Dr. John Ehlers

Source: https://www.tradingview.com/script/NI17VkdU-Reflex-Oscillator-Dr-John-Ehlers/

## Description

Hot off the press, I present this NEW "Reflex Oscillator" employing PSv4.0, originally formulated by Dr. John Ehlers for TASC - February 2020 Traders Tips. John Ehlers might describe it's novel characteristics as being a reversal sensitive near zero-lag averaging indicator retaining the CYCLE component. Also, I would add that irregardless of the sampling interval, this indicator has a bound range between +/-2.0 on "1 second" candles all the way up to "1 month" candle durations. This indicator also has a companion indicator entitled "TrendFlex Oscillator". I have published it in tandem with this one in my scripts profile.

One notable difference between this and the original formulation is that I have added an independent control for the Super Smoother. This "tweak" is enabled by applying the override and adjusting it's period. There is a "Post Smooth" input() that "tweaks" the internal Reflex EMA too. Keep in mind that my intention of adding tweaks is solely for experimentation with the original formulation.

I also added adjustable levels for those of you that may wish to employ alertcondition()s to this indicator somehow. Providing a more utilitarian approach, I created this with an easy to use reusable function named reflex(). As always, I have included advanced Pine programming techniques that conform to proper "Pine Etiquette". Being this is one of John Ehlers' first two simultaneously released indicators for 2020, I felt a few more bells and whistles were appropriate as a proper contribution to the Tradingview community.

Features List Includes:
Dark Background - Easily disabled in indicator Settings->Style for "Light" charts or with Pine commenting
AND much, much more... You have the source!

The comments section below is solely just for commenting and other remarks, ideas, compliments, etc... regarding only this indicator, not others. When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members, I may implement more ideas when they present themselves as worthy additions. As always, "Like" it if you simply just like it with a proper thumbs up, and also return to my scripts list occasionally for additional postings. Have a profitable future everyone!

---

## Source Code

````pine
//@version=4
study("Reflex Oscillator - Dr. John Ehlers", "RO", false, format.price, 2)

bgcolor(color.new(#000000,15), title="Dark Background")

reflex(Series, SSPeriod, ReflexPeriod, PeriodEMA) =>
    var SQRT2xPI = sqrt(8.0) * asin(1.0) // 4.44288293815 Constant
    alpha = SQRT2xPI / SSPeriod
    beta = exp(-alpha)
    gamma = -beta * beta
    delta = 2.0 * beta * cos(alpha)
    float superSmooth = na, superSmooth := (1.0 - delta - gamma) * (Series + nz(Series[1])) * 0.5 + delta * nz(superSmooth[1]) + gamma * nz(superSmooth[2])
    slope = (nz(superSmooth[ReflexPeriod]) - superSmooth) / ReflexPeriod
    E = 0.0
    for i=1 to ReflexPeriod
    	E := E + (superSmooth + i * slope) - nz(superSmooth[i])
    epsilon = E / ReflexPeriod
    zeta = 2.0 / (PeriodEMA + 1.0)
    float EMA = na, EMA := zeta * epsilon * epsilon + (1.0 - zeta) * nz(EMA[1])
    return = EMA==0.0 ? 0.0 : epsilon / sqrt(EMA)

source                  = input( close,                              "Source", input.source)
periodReflex            = input(    20,                       "Reflex Period", input.integer, minval=2)
useSuperSmootherOveride = input( false, "Apply SuperSmoother Override Below*", input.bool)
periodSuperSmoother     = input(   8.0,               "SuperSmoother Period*", input.float  , minval=4.0, step=0.5)
postSmooth              = input(  33.0,                "Post Smooth Period**", input.float  , minval=1.0, step=0.5)
lineThickness           = input(     2,            "---- Line Thickness ----", input.integer, options=[1,2,3])
showArea                = input("Show",                        "Display Area", input.string , options=["Show","Hide"])
upperLevel              = input(   1.0,                         "Upper Level", input.float  , minval= 0.1, maxval= 2.0, step=0.1)
lowerLevel              = input(  -1.0,                         "Lower Level", input.float  , minval=-2.0, maxval=-0.1, step=0.1)
var HIDE_AREA = not (showArea=="Show")
if(not useSuperSmootherOveride)
    periodSuperSmoother := periodReflex * 0.5

reflexOscillator = reflex(source, periodSuperSmoother, periodReflex, postSmooth)

plot(        0.0, color=#FFFFFF22, linewidth=7            , editable=false)
hline(       0.0, color=#FFFFFFff, title=           "Zero", editable=false)
hline(upperLevel, color=#FF0000ff, title="Upper Threshold")
hline(lowerLevel, color=#00FF00ff, title="Lower Threshold")

plot(HIDE_AREA ? na : reflexOscillator, color=#FFFF00  , transp=80, style=plot.style_area, title="Reflex Area")
plot(                 reflexOscillator, color=#FFFF00ff, linewidth=lineThickness         , title="Reflex")
````
