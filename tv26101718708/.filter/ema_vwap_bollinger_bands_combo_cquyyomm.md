# EMA + VWAP + Bollinger Bands Combo

- url: https://www.tradingview.com/script/CQuYyomM-EMA-VWAP-Bollinger-Bands-Combo/
- type: indicator
- pine_id: PUB;4d20f2d5b1b24f7cb60a2b9e026bbcbf
- version: 1.0

## Description

# EMA + VWAP + Bollinger Bands Combo

This indicator combines three of the most popular technical analysis tools into a single customizable overlay: Exponential Moving Average (EMA), Volume Weighted Average Price (VWAP), and Bollinger Bands.

Instead of adding multiple indicators to your chart, you can manage all three from a single script and enable only the tools you need.

### Features

✅ **Exponential Moving Average (EMA)**

* Customizable length and source
* Optional display toggle
* Useful for identifying trend direction and dynamic support/resistance

✅ **Volume Weighted Average Price (VWAP)**

* Supports Session, Weekly, Monthly, Quarterly, and Yearly anchors
* Optional VWAP deviation bands
* Useful for institutional price analysis and intraday trend confirmation

✅ **Bollinger Bands**

* Customizable length and standard deviation settings
* Supports SMA, EMA, RMA (SMMA), WMA, and VWMA as the basis
* Useful for volatility analysis, breakout detection, and mean-reversion setups

### Display Combinations

The indicator allows any combination of:

* EMA only
* VWAP only
* Bollinger Bands only
* EMA + VWAP
* EMA + Bollinger Bands
* VWAP + Bollinger Bands
* EMA + VWAP + Bollinger Bands

### How Traders Commonly Use It

**Trend Following**

* Price above EMA and VWAP can indicate bullish conditions.
* Price below EMA and VWAP can indicate bearish conditions.

**Intraday Trading**

* VWAP acts as a key institutional reference level.
* VWAP bands can help identify stretched price conditions.

**Volatility Analysis**

* Bollinger Band expansion may indicate increasing volatility.
* Bollinger Band contraction may indicate potential breakout conditions.

**Confluence Zones**

* Areas where EMA, VWAP, and Bollinger Bands align can provide stronger support and resistance levels.

### Notes

This indicator is designed as a convenience tool that combines multiple commonly used overlays into a single script, helping reduce chart clutter while maintaining flexibility and customization.

## Source Code

````pine
//@version=6
indicator("EMA + VWAP + Bollinger Bands Combo", overlay=true)

//====================================================
// DISPLAY TOGGLES
//====================================================
showEMA  = input.bool(true, "Show EMA", group="Display")
showVWAP = input.bool(true, "Show VWAP", group="Display")
showBB   = input.bool(true, "Show Bollinger Bands", group="Display")

//====================================================
// EMA SETTINGS
//====================================================
emaGroup = "EMA Settings"

emaLen = input.int(9, minval=1, title="Length", group=emaGroup)
emaSrc = input.source(close, title="Source", group=emaGroup)
emaOffset = input.int(0, title="Offset", minval=-500, maxval=500, group=emaGroup)

emaValue = ta.ema(emaSrc, emaLen)

plot(
     showEMA ? emaValue : na,
     title="EMA",
     color=color.blue,
     offset=emaOffset,
     linewidth=2)

//====================================================
// VWAP SETTINGS
//====================================================
vwapGroup = "VWAP Settings"

hideonDWM = input.bool(false, "Hide VWAP on 1D or Above", group=vwapGroup)

anchor = input.string(
     "Session",
     "Anchor Period",
     options=["Session", "Week", "Month", "Quarter", "Year"],
     group=vwapGroup)

vwapSrc = input.source(hlc3, "Source", group=vwapGroup)

vwapBandGroup = "VWAP Bands"

showVwapBand1 = input.bool(true, "Show Band 1", group=vwapBandGroup)
vwapBand1Mult = input.float(1.0, "Band 1 Multiplier", step=0.5, group=vwapBandGroup)

showVwapBand2 = input.bool(false, "Show Band 2", group=vwapBandGroup)
vwapBand2Mult = input.float(2.0, "Band 2 Multiplier", step=0.5, group=vwapBandGroup)

showVwapBand3 = input.bool(false, "Show Band 3", group=vwapBandGroup)
vwapBand3Mult = input.float(3.0, "Band 3 Multiplier", step=0.5, group=vwapBandGroup)

isNewPeriod =
     anchor == "Session" ? timeframe.change("D") :
     anchor == "Week"    ? timeframe.change("W") :
     anchor == "Month"   ? timeframe.change("M") :
     anchor == "Quarter" ? timeframe.change("3M") :
                           timeframe.change("12M")

float vwapValue = na
float vwapUpper1 = na
float vwapLower1 = na
float vwapUpper2 = na
float vwapLower2 = na
float vwapUpper3 = na
float vwapLower3 = na

if not (hideonDWM and timeframe.isdwm)
    [vwapCalc, stdevUpper, _] = ta.vwap(vwapSrc, isNewPeriod, 1)

    vwapValue := vwapCalc

    stdevAbs = stdevUpper - vwapCalc

    vwapUpper1 := vwapCalc + stdevAbs * vwapBand1Mult
    vwapLower1 := vwapCalc - stdevAbs * vwapBand1Mult

    vwapUpper2 := vwapCalc + stdevAbs * vwapBand2Mult
    vwapLower2 := vwapCalc - stdevAbs * vwapBand2Mult

    vwapUpper3 := vwapCalc + stdevAbs * vwapBand3Mult
    vwapLower3 := vwapCalc - stdevAbs * vwapBand3Mult

plot(
     showVWAP ? vwapValue : na,
     title="VWAP",
     color=color.orange,
     linewidth=2)

vwapU1 = plot(
     showVWAP and showVwapBand1 ? vwapUpper1 : na,
     title="VWAP Upper Band 1",
     color=color.green)

vwapL1 = plot(
     showVWAP and showVwapBand1 ? vwapLower1 : na,
     title="VWAP Lower Band 1",
     color=color.green)

fill(vwapU1, vwapL1, color=color.new(color.green, 92))

vwapU2 = plot(
     showVWAP and showVwapBand2 ? vwapUpper2 : na,
     title="VWAP Upper Band 2",
     color=color.olive)

vwapL2 = plot(
     showVWAP and showVwapBand2 ? vwapLower2 : na,
     title="VWAP Lower Band 2",
     color=color.olive)

fill(vwapU2, vwapL2, color=color.new(color.olive, 92))

vwapU3 = plot(
     showVWAP and showVwapBand3 ? vwapUpper3 : na,
     title="VWAP Upper Band 3",
     color=color.teal)

vwapL3 = plot(
     showVWAP and showVwapBand3 ? vwapLower3 : na,
     title="VWAP Lower Band 3",
     color=color.teal)

fill(vwapU3, vwapL3, color=color.new(color.teal, 92))

//====================================================
// BOLLINGER BAND SETTINGS
//====================================================
bbGroup = "Bollinger Bands Settings"

bbLength = input.int(20, minval=1, title="Length", group=bbGroup)

bbMAType = input.string(
     "SMA",
     "Basis MA Type",
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=bbGroup)

bbSrc = input.source(close, "Source", group=bbGroup)

bbMult = input.float(
     2.0,
     "StdDev",
     minval=0.001,
     maxval=50,
     group=bbGroup)

bbMA(source, length, maType) =>
    switch maType
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

bbBasis = bbMA(bbSrc, bbLength, bbMAType)
bbDev = bbMult * ta.stdev(bbSrc, bbLength)

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

bbBasisPlot = plot(
     showBB ? bbBasis : na,
     title="BB Basis",
     color=#2962FF)

bbUpperPlot = plot(
     showBB ? bbUpper : na,
     title="BB Upper",
     color=#F23645)

bbLowerPlot = plot(
     showBB ? bbLower : na,
     title="BB Lower",
     color=#089981)

fill(
     bbUpperPlot,
     bbLowerPlot,
     title="BB Background",
     color=color.rgb(33, 150, 243, 90))
````
