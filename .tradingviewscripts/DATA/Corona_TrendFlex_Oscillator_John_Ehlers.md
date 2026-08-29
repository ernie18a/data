<!-- tradingview-pine-id: PUB;8RhQrXVBQaWeVJ4FYGdvjzazTNhk3Wkv -->
<!-- tradingviewscripts-format: 1 -->
# Corona TrendFlex Oscillator - John Ehlers

Source: https://www.tradingview.com/script/8ZSALctc-TrendFlex-Oscillator-Dr-John-Ehlers/

## Description

Hot off the press, I present this NEW "TrendFlex Oscillator" employing PSv4.0, originally formulated by Dr. John Ehlers for TASC - February 2020 Traders Tips. John Ehlers might describe it's novel characteristics as being a reversal sensitive near zero-lag averaging indicator retaining the TREND component. Also, I would add that irregardless of the sampling interval, this indicator has a bound range between +/-2.0 on "1 second" candles all the way up to "1 month" candle durations. This indicator also has a companion indicator entitled "Reflex Oscillator". I have published it in tandem with this one in my scripts profile.

One notable difference between this and the original formulation is that I have added an independent control for the Super Smoother. This "tweak" is enabled by applying the override and adjusting it's period. There is a "Post Smooth" input() that "tweaks" the internal TrendFlex EMA too. Keep in mind that my intention of adding tweaks is solely for experimentation with the original formulation.

I also added adjustable levels for those of you that may wish to employ alertcondition()s to this indicator somehow. Providing a more utilitarian approach, I created this with an easy to use reusable function named trendflex(). As always, I have included advanced Pine programming techniques that conform to proper "Pine Ettiquette". Being this is one of John Ehlers' first two simultaneously released indicators for 2020, I felt a few more bells and whistles were appropriate as a proper contribution to the Tradingview community.

Features List Includes:
Dark Background - Easily disabled in indicator Settings->Style for "Light" charts or with Pine commenting
AND much, much more... You have the source!

The comments section below is solely just for commenting and other remarks, ideas, compliments, etc... regarding only this indicator, not others. When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members, I may implement more ideas when they present themselves as worthy additions. As always, "Like" it if you simply just like it with a proper thumbs up, and also return to my scripts list occasionally for additional postings. Have a profitable future everyone!

---

## Source Code

````pine
//@version=5
indicator('Corona TrendFlex Oscillator - John Ehlers', 'TFO', false, format.price, 2)

var color invisible = #00000000
bgcolor(color.new(#000000, 15), title='Dark Background')

essf(float Series, float Period) =>
    // Ehlers' SuperSmoother Filter
    var float SQRT2xPI =  math.sqrt(2.0) * math.pi
    var float alpha    =  SQRT2xPI / Period
    var float beta     =  math.exp(-alpha)
    var float coef2    = -math.pow(  beta, 2)
    var float coef1    =  math.cos( alpha) * 2.0 * beta
    var float coef0    =  1.0 - coef1 - coef2
    float sma2 = (Series + nz(Series[1], Series)) * 0.5
    float ess = na, ess := coef0 *    sma2    +
                           coef1 * nz(ess[1]) +
                           coef2 * nz(ess[2])

sumDiffs(float Series, int Period) =>
    // Sum of Differences
    float E = 0.0
    for int i=1 to Period
        E += Series - nz(Series[i])
    E / Period

ema(float Series, float Period) =>
    // Exponential Moving Average
    var float coef0 = 2.0 / (Period + 1.0)
    var float coef1 = 1.0 - coef0
    float EMA = na, EMA := coef0 *   Series +
                           coef1 * nz(EMA[1])

fRMS(float Series, float Period) =>
    // Fast Root Mean Square
    float EMA = ema(math.pow(Series, 2), Period)
    nz(Series / math.sqrt(EMA))

trendflex(float     Series,
          float PeriodESSF,
   simple   int PeriodTFLX,
   simple float PeriodFRMS) =>
    // Ehlers' TrendFlex
    fRMS(sumDiffs(essf(Series * 10000000.0, PeriodESSF), PeriodTFLX), PeriodFRMS)


float     source                  = input(close, 'Price Source')
const string grp0 = 'TrendFLex Controls'
var   int periodTrendFlex         = input.int  (   20,             'TrendFlex Period', group=grp0, minval=2)
var  bool useSuperSmootherOveride = input.bool (false, 'Post-Smooth Period Override:', group=grp0, inline='1')
var float periodSuperSmoother     = input.float(  7.5,                             '', group=grp0, inline='1', minval=4.0, step=0.5)
var float postSmooth              = input.float( 33.0,              'Fast RMS Period', group=grp0,             minval=1.0, step=0.5)
var   int lineThickness           = input.int  (    2,     '---- Line Thickness ----', group=grp0, options=[1, 2, 3])
const string grp1 = 'Threshold Settings'
var float upperLevel = input.float( 1.0, 'Upper Level', group=grp1, minval= 0.1, maxval= 2.0, step=0.1)
var float lowerLevel = input.float(-1.0, 'Lower Level', group=grp1, minval=-2.0, maxval=-0.1, step=0.1)
const string grp2 = 'Color Preferences'
var color upperColor = input.color(#FF00FF, 'Upper Corona', group=grp2)
var color lowerColor = input.color(#0088FF, 'Lower Corona', group=grp2)

if barstate.isfirst
    periodSuperSmoother := useSuperSmootherOveride ? periodSuperSmoother
                                                   : periodTrendFlex * 0.5

float TFO = trendflex(source, periodSuperSmoother, periodTrendFlex, postSmooth)

hline(upperLevel, color=#FF0000ff, title='Upper Threshold')
hline(lowerLevel, color=#00FF00ff, title='Lower Threshold')
hline(       0.0, color=#FFFFFFff, title='Zero', editable=false)

plot_0 = plot(0.0, color=#FFFFFF22, editable=false, linewidth=6)
plotTF = plot(TFO, color=#FFFFFFff, linewidth=lineThickness, title='TrendFlex')

bool isPositiveTFO = TFO >  0.0
fill(plot_0, plotTF, top_value=isPositiveTFO ?        TFO :       0.0,
                  bottom_value=isPositiveTFO ?        0.0 :       TFO,
                     top_color=isPositiveTFO ? upperColor : invisible,
                  bottom_color=isPositiveTFO ?  invisible : lowerColor)
````
