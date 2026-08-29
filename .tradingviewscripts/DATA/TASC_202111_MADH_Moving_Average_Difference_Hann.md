<!-- tradingview-pine-id: PUB;99538a6403c44e36b2dcddddb0f51923 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2021.11 (MADH) Moving Average Difference, Hann

Source: https://www.tradingview.com/script/vraaRpAA-TASC-2021-11-MADH-Moving-Average-Difference-Hann/

## Description

█ OVERVIEW

Presented here is code for the "Moving Average Difference, Hann" indicator originally conceived by John ​Ehlers. The code is also published in the [November 2021 issue of Trader's Tips](https://traders.com/Documentation/FEEDbk_docs/2021/11/TradersTips.html) by [Technical Analysis of Stocks & ​Commodities (TASC)](http://traders.com/) magazine.

█ CONCEPTS

By employing a Hann windowed finite impulse response filter (FIR), John ​Ehlers has enhanced the [Moving Average Difference (MAD)](https://www.tradingview.com/script/8YMTHXu3-TASC-2021-10-MAD-Moving-Average-Difference/) to provide an oscillator with exceptional smoothness.

​Of notable mention, the wave form of MADH resembles ​Ehlers' "Reverse EMA" Indicator, formerly revealed in the September 2017 issue of TASC. Many [variations of the "Reverse EMA"](https://www.tradingview.com/scripts/search/Reverse%20EMA/) were published in TradingView's Public Library.

█ FEATURES

Three values in the script's "Settings/Inputs" provide control over the oscillators behavior:
 • The price source
 • A "Short Length" with a default of 8, to manage the lower band edge of the oscillator
 • The "Dominant Cycle", originally set at 27, which appears to be a placeholder for an adaptive control mechanism

Two coloring options are provided for the line's fill:
 • "ZeroCross", the default, uses the line's position above/below the zero level. This is the mode used in the top version of MADH on this chart.
 • "Momentum" uses the line's up/down state, as shown in the bottom version of the indicator on the chart.

█ NOTES

Calculations
The source price is used in two independent Hann windowed FIR filters having two different periods (lengths) of historical observation for calculation, one being a "Short Length" and the other termed "Dominant Cycle". These are then passed to a "rate of change" calculation and then returned by the reusable function. The secret ​sauce is that a "windowed Hann FIR filter" is superior tp a generic SMA filter, and that ultimately reveals Ehlers' clever enhancement. We'll have to wait and see what ingenuities ​Ehlers has next to unleash. Stay tuned...

The `madh()` function code was optimized for computational efficiency in Pine, differing visibly from ​Ehlers' original formula, but yielding the same results as ​Ehlers' version.

Background
This indicator has a sibling indicator discussed in the "The MAD Indicator, Enhanced" article by ​Ehlers. MADH is an evolutionary update from the prior MAD indicator code published in the October 2021 issue of TASC.

Sibling Indicators
 • [Moving Average Difference (MAD)](https://www.tradingview.com/script/8YMTHXu3-TASC-2021-10-MAD-Moving-Average-Difference/)
 • [Cycle/Trend Analytics](https://www.tradingview.com/script/7TgeAK3Y-TASC-2021-10-Cycle-Trend-Analytics/)

Related Information
 • [Cycle/Trend Analytics And The MAD Indicator](http://technical.traders.com/archive/archivelogin.asp?file=\V39\C10\314EHLE.pdf&src=SC)
 • [The Reverse ​EMA Indicator](https://store.traders.com/stcov35812re.html)
 • [Hann Window](https://en.wikipedia.org/wiki/Window_function#Hann_and_Hamming_windows)
 • [ROC](https://www.tradingview.com/u/?solution=43000502343)

[Join TradingView!](https://www.tradingview.com/gopro/)

---

## Source Code

````pine
//  TASC Issue: November 2021 - Vol. 39, Issue 12
//     Article: "The MAD Indicator, Enhanced" by John Ehlers
//    Language: TradingView's Pine Script v4
// Provided By: PineCoders, for tradingview.com

//@version=4
study("TASC 2021.11 (MADH) Moving Average Difference, Hann", "MADH")

float Source     = input( defval = close,
                           title = "Source:",
                           group = "Adjustments")
int ShortLength  = input( defval = 8,
                           title = "Short Length:",
                           group = "Adjustments",
                          minval = 2)
int DomCycle     = input( defval = 27,
                           title = "Dominant Cycle:",
                           group = "Adjustments",
                          minval = 4)
int LineWidth    = input( defval = 2,
                           title = "Line Width:",
                           group = "Options",
                         options = [1,2,3])
string ColScheme = input( defval = "ZeroCross",
                           title = "Color Scheme:",
                           group = "Options",
                         options = ["ZeroCross","Momentum"])

colorize(signal, scheme, transp) =>
    if scheme == "ZeroCross"
        if signal > 0.0
            color.new(#FF00FF, transp)
        else
            color.new(#55CC00, transp)
    else // "Momentum"
        if rising(signal, 1)
            color.new(#00DD00, transp)
        else
            color.new(#FF0000, transp)

madh(source, shortLength, dominantCycle) =>
    int longLength =  int(dominantCycle * 0.5 +  shortLength)
    float     PIx2LengthLong  = math.pi * 2.0 / ( longLength + 1)
    var float PIx2LengthShort = math.pi * 2.0 / (shortLength + 1)
    float filt1 = 0.0
    float coefs = 0.0
    for count = 1 to shortLength
        float coefHann = 1.0 - cos(count * PIx2LengthShort)
        filt1 += coefHann * source[count - 1]
        coefs += coefHann
    filt1 := nz(filt1 / coefs)
    float filt2 = 0.0
    coefs      := 0.0
    for count=1 to longLength
        float coefHann = 1.0 - cos(count * PIx2LengthLong)
        filt2 += coefHann * source[count - 1]
        coefs += coefHann
    filt2 := nz(filt2 / coefs)
    nz((filt1 - filt2) / filt2 * 100.0)

MADH = madh(Source, ShortLength, DomCycle)

plot(MADH, "Area", colorize(MADH, ColScheme, 65), style = 4)
plot(MADH, "MADH", colorize(MADH, ColScheme,  0), LineWidth)
hline(  0, "Zero", color=color.gray)
````
