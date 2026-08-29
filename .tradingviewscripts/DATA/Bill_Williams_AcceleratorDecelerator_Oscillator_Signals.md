<!-- tradingview-pine-id: PUB;0231796d426942cbb09b6c8365bbe611 -->
<!-- tradingviewscripts-format: 1 -->
# Bill Williams Accelerator/Decelerator Oscillator Signals

Source: https://www.tradingview.com/script/mEc7FXNe-Bill-Williams-Accelerator-Decelerator-Oscillator-Signals/

## Description

**Bill Williams Accelerator/Decelerator Oscillator Signals (AC)**

This indicator is based on Bill Williams' Accelerator/Decelerator Oscillator (AC) concept and combines AC momentum analysis with an Alligator trend filter to identify potential market acceleration and deceleration phases.

The Accelerator Oscillator measures the change in momentum of the Awesome Oscillator (AO). It helps traders observe whether market momentum is increasing or slowing before possible trend changes.

### Features

• **Classic AC calculation**

* Awesome Oscillator (AO): SMA(hl2, 5) − SMA(hl2, 34)
* Accelerator Oscillator (AC): AO − SMA(AO, 5)

• **AC Histogram**

* Green bars indicate increasing acceleration.
* Red bars indicate decreasing acceleration.
* Flat bars maintain the previous momentum color.

• **Alligator Trend Filter**
Signals are filtered using Bill Williams' Alligator to align entries with the prevailing market direction and reduce low-quality signals.

• **Three Signal Types**

* Signal 1: Early momentum confirmation.
* Signal 2: Stronger acceleration pattern before momentum continuation.
* Signal 3: Zero-line momentum transition signal.

• **Signal Priority System**
When multiple signals appear on the same bar, the indicator prioritizes the strongest signal to keep the chart cleaner.

### How It Works

**Buy signals**
Appear when AC momentum improves and price direction agrees with the Alligator trend filter.

**Sell signals**
Appear when AC momentum weakens and price direction agrees with the Alligator trend filter.

The indicator is designed to help traders visually identify changes in market acceleration, momentum strength, and possible trend continuation areas.

### Important Notes

This tool is not a standalone trading system and does not provide guaranteed entry or exit points. It should be used together with market structure, risk management, and additional analysis.

Designed for traders who use Bill Williams' trading methodology and momentum-based analysis.

---

## Source Code

````pine
// © OlekBard

//@version=6
indicator("Bill Williams Accelerator/Decelerator Oscillator Signals", shorttitle="AC", overlay=false, max_labels_count=500)

//==================================================
// USER INPUTS
//==================================================

// --- Display
groupDisplay = "Display"
showHistogram = input.bool(true, "Show AC Histogram", group=groupDisplay)
showZeroLine  = input.bool(true, "Show Zero Line", group=groupDisplay)
showOnlyStrongest = input.bool(true, "Show Only Strongest Signal Per Bar", group=groupDisplay)
markerOffsetFactor = input.float(0.15, "Marker Offset Factor", step=0.01, minval=0.0, maxval=1.0, group=groupDisplay)

// --- Signals (BUY + SELL together)
groupSignals = "Signals"
showSignal1 = input.bool(true, "Signal 1 (Buy1 + Sell1)", group=groupSignals)
showSignal2 = input.bool(true, "Signal 2 (Buy2 + Sell2)", group=groupSignals)
showSignal3 = input.bool(true, "Signal 3 (Buy3 + Sell3)", group=groupSignals)

// --- Styles
groupS1 = "Style - Signal 1"
sig1BuyColor  = input.color(#81c784, "Buy Color", group=groupS1)
sig1SellColor = input.color(#e57373, "Sell Color", group=groupS1)

groupS2 = "Style - Signal 2"
sig2BuyColor  = input.color(#81c784, "Buy Color", group=groupS2)
sig2SellColor = input.color(#e57373, "Sell Color", group=groupS2)

groupS3 = "Style - Signal 3"
sig3BuyColor  = input.color(#81c784, "Buy Color", group=groupS3)
sig3SellColor = input.color(#e57373, "Sell Color", group=groupS3)

histGreen = input.color(#009688, "Histogram Up Color")
histRed   = input.color(#F44336, "Histogram Down Color")

//==================================================
// ACCELERATOR OSCILLATOR (FIXED CLASSIC FORMULA)
// AC = AO - SMA(AO, 5)
// AO = SMA(hl2, 5) - SMA(hl2, 34)
//==================================================
ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
ac = ao - ta.sma(ao, 5)

//==================================================
// HISTOGRAM COLORS - Classic AC logic with flat bars
//==================================================
isGreen = ac > ac[1]
isRed   = ac < ac[1]

// var stores the previous bar color
var color lastColor = histGreen  // initial color for the first bar

// update lastColor only if AC changed, otherwise keep previous
lastColor := isGreen ? histGreen : isRed ? histRed : lastColor

plotColor = lastColor


//==================================================
// ALLIGATOR FILTER (NO VISUALIZATION)
//==================================================
smma(src, length) =>
    smma = 0.0
    smma := na(smma[1]) ? ta.sma(src, length) : (smma[1] * (length - 1) + src) / length

jawLength = input.int(13, minval=1, title="Jaw Length")
teethLength = input.int(8, minval=1, title="Teeth Length")
lipsLength = input.int(5, minval=1, title="Lips Length")

jawOffset = input.int(8, title="Jaw Offset")
teethOffset = input.int(5, title="Teeth Offset")
lipsOffset = input.int(3, title="Lips Offset")

jaw   = smma(hl2, jawLength)
teeth = smma(hl2, teethLength)
lips  = smma(hl2, lipsLength)

jaw_f   = jaw[jawOffset]
teeth_f = teeth[teethOffset]
lips_f  = lips[lipsOffset]

alligatorBuy  = close > jaw_f and close > teeth_f and close > lips_f
alligatorSell = close < jaw_f and close < teeth_f and close < lips_f

//==================================================
// PLOT HISTOGRAM & ZERO
//==================================================
plot(showHistogram ? ac : na, style=plot.style_histogram, color=plotColor, linewidth=2)
plot(showZeroLine ? 0 : na, color=color.gray, style=plot.style_line, linewidth=1)

//==================================================
// CLEAN SIGNAL LOGIC (ANTI-NOISE)
//==================================================

buy1  = showSignal1 and alligatorBuy and ac > 0 and isGreen and isGreen[1] and not isGreen[2]
sell1 = showSignal1 and alligatorSell and ac < 0 and isRed and isRed[1] and not isRed[2]

buy2  = showSignal2 and alligatorBuy and ac < 0 and isGreen and isGreen[1] and isGreen[2] and not isGreen[3]
sell2 = showSignal2 and alligatorSell and ac > 0 and isRed and isRed[1] and isRed[2] and not isRed[3]
buy3  = showSignal3 and alligatorBuy and ac > 0 and ac[1] <= 0 and isGreen and isGreen[1]
sell3 = showSignal3 and alligatorSell and ac < 0 and ac[1] >= 0 and isRed and isRed[1]

//==================================================
// PRIORITY
//==================================================
buySignal =
     buy3 ? 3 :
     buy2 ? 2 :
     buy1 ? 1 : 0

sellSignal =
     sell3 ? 3 :
     sell2 ? 2 :
     sell1 ? 1 : 0

finalBuy1  = not showOnlyStrongest ? buy1 : (buySignal == 1 and sellSignal == 0)
finalSell1 = not showOnlyStrongest ? sell1 : (sellSignal == 1 and buySignal == 0)

finalBuy2  = not showOnlyStrongest ? buy2 : (buySignal == 2 and sellSignal == 0)
finalSell2 = not showOnlyStrongest ? sell2 : (sellSignal == 2 and buySignal == 0)

finalBuy3  = not showOnlyStrongest ? buy3 : (buySignal == 3 and sellSignal == 0)
finalSell3 = not showOnlyStrongest ? sell3 : (sellSignal == 3 and buySignal == 0)

//==================================================
// OFFSET FOR MARKERS
//==================================================
highestAC = ta.highest(ac, 100)
lowestAC  = ta.lowest(ac, 100)

offsetUp   = math.abs(highestAC) * markerOffsetFactor
offsetDown = -math.abs(lowestAC) * markerOffsetFactor

//==================================================
// PLOT MARKERS (ABSOLUTE)
// positive zone -> above AC
// negative zone -> below AC
//==================================================

// Signal 1 Buy
plotshape(
     finalBuy1 ? (ac >= 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Buy 1",
     style=shape.diamond,
     location=location.absolute,
     color=sig1BuyColor,
     size=size.auto
)

// Signal 1 Sell
plotshape(
     finalSell1 ? (ac > 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Sell 1",
     style=shape.diamond,
     location=location.absolute,
     color=sig1SellColor,
     size=size.auto
)

// Signal 2 Buy
plotshape(
     finalBuy2 ? (ac >= 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Buy 2",
     style=shape.diamond,
     location=location.absolute,
     color=sig2BuyColor,
     size=size.auto
)

// Signal 2 Sell
plotshape(
     finalSell2 ? (ac > 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Sell 2",
     style=shape.diamond,
     location=location.absolute,
     color=sig2SellColor,
     size=size.auto
)

// Signal 3 Buy
plotshape(
     finalBuy3 ? (ac >= 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Buy 3",
     style=shape.diamond,
     location=location.absolute,
     color=sig3BuyColor,
     size=size.auto
)

// Signal 3 Sell
plotshape(
     finalSell3 ? (ac > 0 ? ac + offsetUp : ac + offsetDown) : na,
     title="Sell 3",
     style=shape.diamond,
     location=location.absolute,
     color=sig3SellColor,
     size=size.auto
)
````
