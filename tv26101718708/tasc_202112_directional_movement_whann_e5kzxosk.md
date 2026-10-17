# TASC 2021.12 Directional Movement w/Hann

- url: https://www.tradingview.com/script/E5KzXOsk-TASC-2021-12-Directional-Movement-w-Hann/
- type: indicator
- pine_id: PUB;56423896c25a45c09191237109e6b23a
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

Presented here is code for the "Directional Movement w/Hann" indicator originally conceived by John ​Ehlers. The code is also published in the [url=https://traders.com/Documentation/FEEDbk_docs/2021/12/TradersTips.html]December 2021 issue of Trader's Tips[/url] by [url=http://traders.com/]Technical Analysis of Stocks & ​Commodities (TASC)[/url] magazine.

Ehlers continues here his exploration of the application of [url=https://en.wikipedia.org/wiki/Hann_function]Hann windowing[/url] to conventional trading indicators.


█ [b]FEATURES[/b]

The rolling length can be modified in the script's inputs, as well as the width of the line.


█ [b]NOTES[/b]

[b]Calculations[/b]
The calculation starts with the classic definition of PlusDM and MinusDM. These directional movements are summed in an exponential moving average (EMA). Then, this EMA is further smoothed in a finite impulse response (FIR) filter using Hann window coefficients over the calculation period.

[b]Background[/b]
The [url=https://www.tradingview.com/u/?solution=43000502250]DMI and ADX[/url] indicators were designed by J. Welles Wilder and presented in his "New Concepts in Technical Trading Systems" book published in 1978.


[url=https://www.tradingview.com/gopro/]Join TradingView![/url]

## Source Code

````pine
//  TASC Issue: December 2021 - Vol. 39, Issue 13
//     Article: "The DMH: An Improved
//               Directional Movement Indicator"
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script v5
// Provided By: PineCoders, for tradingview.com

//@version=5
indicator("TASC 2021.12 Directional Movement w/Hann", "DMH")

lengthInput = input.int(10,     "Length:", minval = 2)
lWidthInput = input.int( 2, "Line Width:", minval = 1)

hann(src, period) => // Hann FIR Filter
    var PIx2 = 2.0 * math.pi / (period + 1)
    sum4Hann  = 0.0, sumCoefs = 0.0
    for count= 1 to period
        coef      =  1.0 - math.cos(count * PIx2)
        sum4Hann += coef * src[count - 1]
        sumCoefs += coef
    nz(sum4Hann / sumCoefs)

dmh(period) => // Directional Movement w/Hann
    upMove = high - high[1]
    dnMove = -low +  low[1]
    pDM = upMove > dnMove and upMove > 0 ? upMove : 0.0
    mDM = dnMove > upMove and dnMove > 0 ? dnMove : 0.0
    hann(ta.rma(pDM - mDM, period), period)

signal = dmh(lengthInput)

plotColor = signal > 0.0 ? #FFCC00   : #0055FF
areaColor = signal > 0.0 ? #FFCC0055 : #0055FF55

plot(signal, "Area", areaColor, style = plot.style_area)
plot(signal,  "DMH", plotColor, lWidthInput)
hline(0, "Zero", color.gray)
````
