<!-- tradingview-pine-id: PUB;d161b2d5aef144179bf06bd94080328e -->
<!-- tradingviewscripts-format: 1 -->
# Bill Williams: Alligator • Fractals • AO • AC • BW MFI • BDB

Source: https://www.tradingview.com/script/PVdLrlzv-Bill-Williams-Alligator-Fractals-AO-AC-BW-MFI-BDB/

## Description

# Bill Williams Chaos System — Alligator • Fractals • AO • AC • BW MFI • BDB

A complete Bill Williams inspired trading toolkit combining market structure, momentum, volume analysis and price behavior into one indicator.

This indicator is designed to help traders analyze the market through the principles of **Trading Chaos** by combining several key elements:

### 🐊 Alligator

The indicator includes the Bill Williams Alligator with Jaw, Teeth and Lips lines to identify market phases:

* Sleeping market (low activity)
* Awakening phase
* Trend development
* Trend continuation

The Alligator is also used as a filter for signal confirmation, helping avoid trades against the current market structure.

### 🔺 Fractals

Classic Bill Williams fractals are included to identify potential breakout levels and important swing points.

Fractals can help traders:

* Detect local highs and lows
* Identify breakout areas
* Understand market structure

### 🌈 Awesome Oscillator (AO)

AO momentum analysis with:

* Zero line crossing signals
* Saucer signals
* Alligator confirmation filter

Signals are generated only when price position agrees with the Alligator structure.

### 💎 Accelerator Oscillator (AC)

AC measures the acceleration and deceleration of momentum.

Included signals:

* Momentum continuation
* Counter-trend acceleration setups
* Filtered signals to reduce noise

### 📊 Bill Williams Market Facilitation Index (BW MFI)

Volume and price range analysis based on Bill Williams' Market Facilitation concept.

The indicator highlights four market states:

🟢 Green — volume and range increase (strong market participation)
🔵 Blue — range increases while volume decreases (possible continuation)
🩷 Pink — volume increases while range decreases (possible battle between buyers and sellers)
🟤 Brown — low activity / market pause

### 🔥 BDB (Divergent Bar Behavior)

Price action analysis based on bar location and relationship with the Alligator.

Detects:

* Strong bullish and bearish bars
* Weak divergent bars
* Market exhaustion behavior

Signals are filtered using Alligator positioning to improve quality.

### 📌 PB Signals (Price Behavior)

Additional price behavior signals based on:

* Candle position inside its range
* Relationship with the Alligator Teeth line
* Strong directional candle structure

Designed to highlight candles showing possible continuation behavior.

---

## Indicator Philosophy

This script combines:

* Market structure
* Momentum
* Volume
* Price action
* Trend confirmation

The goal is not to predict the market, but to help traders recognize current market conditions and make decisions using multiple confirmations.

⚠️ This indicator is an analytical tool and does not provide guaranteed buy or sell signals. Always combine signals with risk management and your own market analysis.

Created by OlekBard

---

## Source Code

````pine
// © OlekBard

//@version=6
indicator("Bill Williams: Alligator • Fractals • AO • AC • BW MFI • BDB", shorttitle="Chaos", overlay=true, max_labels_count=500)

//================ INPUTS =================
showFractals = input.bool(true, "Show Fractals")
showZones = input.bool(true, "Enable Trading in the Zones")

zoneUpColor       = input.color(#009688, "Zone Up Color")
zoneDownColor     = input.color(#F44336, "Zone Down Color")
zoneNeutralColor  = input.color(color.gray, "Zone Neutral Color")

showMFI = input.bool(true, "Enable BW MFI")
mfiGreenEnable  = input.bool(true, "MFI Green")
mfiBlueEnable   = input.bool(true, "MFI Blue")
mfiPinkEnable   = input.bool(true, "MFI Pink")
mfiBrownEnable  = input.bool(true, "MFI Brown")

mfiGreenColor = input.color(color.green, "MFI Green Color")
mfiBlueColor  = input.color(#2196f3,  "MFI Blue Color")
mfiPinkColor  = input.color(color.rgb(255,105,180), "MFI Pink Color")
mfiBrownColor = input.color(color.rgb(139,69,19), "MFI Brown Color")

jawLength   = input.int(13, minval=1, title="Jaw Length")
teethLength = input.int(8, minval=1, title="Teeth Length")
lipsLength  = input.int(5, minval=1, title="Lips Length")

jawOffset   = input.int(8, title="Jaw Offset")
teethOffset = input.int(5, title="Teeth Offset")
lipsOffset  = input.int(3, title="Lips Offset")

fractalPeriod = input.int(2, "Fractal Period", minval=2)

//================ SMMA FUNCTION =================
smma(src, length) =>
    smma_val = 0.0
    smma_val := na(smma_val[1]) ? ta.sma(src, length) : (smma_val[1]*(length-1) + src)/length
    smma_val

//================ ALLIGATOR =================
jaw   = smma(hl2, jawLength)
teeth = smma(hl2, teethLength)
lips  = smma(hl2, lipsLength)

plot(jaw, "Jaw", color=#2962FF, offset=jawOffset)
plot(teeth, "Teeth", color=#E91E63, offset=teethOffset)
plot(lips, "Lips", color=#66BB6A, offset=lipsOffset)

//================ REAL ALLIGATOR =================
jawReal   = jaw[jawOffset]
teethReal = teeth[teethOffset]
lipsReal  = lips[lipsOffset]

//================ AO / AC CALCULATION =================
median = (high + low)/2
aoFast = ta.sma(median, 5)
aoSlow = ta.sma(median, 34)
ao = aoFast - aoSlow
ac = ao - ta.sma(ao, 5)

//================ AO SIGNALS =================
aoSaucerBuy = ao > 0 and ao[2] > ao[1] and ao > ao[1]
aoSaucerSell = ao < 0 and ao[2] < ao[1] and ao < ao[1]

aoZeroBuy = ao[1] < 0 and ao > 0
aoZeroSell = ao[1] > 0 and ao < 0


// AO FINAL WITH CLOSE FILTER
barAboveAlligatorClose = close < jawReal and close < teethReal and close < lipsReal
barBelowAlligatorClose = close > jawReal and close > teethReal and close > lipsReal


aoBuy = (aoSaucerBuy or aoZeroBuy) and barBelowAlligatorClose
aoSell = (aoSaucerSell or aoZeroSell) and barAboveAlligatorClose


plotshape(aoBuy, location=location.belowbar, style=shape.square, color=#81c784, size=size.auto, title="AO Buy")
plotshape(aoSell, location=location.abovebar, style=shape.square, color=#e57373, size=size.auto, title="AO Sell")


//================ AC SIGNALS =================

// conditions
acBuyTrend = ac > 0 and ac > ac[1] and ac[1] > ac[2]
acBuyCounter = ac < 0 and ac > ac[1] and ac[1] > ac[2] and ac[2] > ac[3]

acSellTrend = ac < 0 and ac < ac[1] and ac[1] < ac[2]
acSellCounter = ac > 0 and ac < ac[1] and ac[1] < ac[2] and ac[2] < ac[3]

// raw signals
acBuyRaw = (acBuyTrend or acBuyCounter) and barBelowAlligatorClose
acSellRaw = (acSellTrend or acSellCounter) and barAboveAlligatorClose

// prevent stacking signals
acBuy = acBuyRaw and not acBuyRaw[1]
acSell = acSellRaw and not acSellRaw[1]

// plots
plotshape(acBuy, location=location.belowbar, style=shape.diamond, color=#81c784, size=size.auto, title="AC Buy")
plotshape(acSell, location=location.abovebar, style=shape.diamond, color=#e57373, size=size.auto, title="AC Sell")

//================ TRADING ZONES =================
aoUp = ao > ao[1]
acUp = ac > ac[1]

var color zoneColor = na
zoneColor := aoUp and acUp ? zoneUpColor : not aoUp and not acUp ? zoneDownColor : zoneNeutralColor
if not showZones
    zoneColor := na
//================ BW MFI =================
bwMFI = (high - low)/(volume==0?1:volume)
rangeUp = (high - low) > (high[1] - low[1])
volUp   = volume > volume[1]

var color bwColor = na
bwColor := rangeUp and volUp ? (mfiGreenEnable ? mfiGreenColor : na) :
           rangeUp and not volUp ? (mfiBlueEnable ? mfiBlueColor : na) :
           not rangeUp and volUp ? (mfiPinkEnable ? mfiPinkColor : na) :
           (mfiBrownEnable ? mfiBrownColor : na)
if not showMFI
    bwColor := na

var color barColor = na
barColor := na
if showMFI and not na(bwColor)
    barColor := bwColor
else if showZones and not na(zoneColor)
    barColor := zoneColor
barcolor(barColor)

//================ BDB BAR CLASSIFICATION =================
barHigh  = high
barLow   = low
barOpen  = open
barClose = close
barRange = barHigh - barLow
validBar = barRange > syminfo.mintick

topThird    = validBar ? barLow + barRange * 2/3 : na
bottomThird = validBar ? barLow + barRange * 1/3 : na
midPoint    = validBar ? barLow + barRange * 0.5 : na

openPos = validBar ? (barOpen <= bottomThird ? 1 : barOpen >= topThird ? 3 : 2) : na
closePos = validBar ? (barClose <= bottomThird ? 1 : barClose >= topThird ? 3 : 2) : na

bearStrong = validBar and openPos == 1 and closePos == 1
bullStrong = validBar and openPos == 3 and closePos == 3

newHigh = validBar and barHigh > high[1]
newLow  = validBar and barLow < low[1]

// BDB ALLIGATOR FILTER: FULL BAR OUTSIDE
barAboveAlligatorFull = validBar and barLow > jawReal and barLow > teethReal and barLow > lipsReal
barBelowAlligatorFull = validBar and barHigh < jawReal and barHigh < teethReal and barHigh < lipsReal

bearishStrongSignal = bearStrong and newHigh and barAboveAlligatorFull
bullishStrongSignal = bullStrong and newLow and barBelowAlligatorFull

bearishWeakSignal = validBar and newHigh and barClose <= midPoint and barAboveAlligatorFull and not bearishStrongSignal
bullishWeakSignal = validBar and newLow and barClose >= midPoint and barBelowAlligatorFull and not bullishStrongSignal

plotshape(bullishStrongSignal, location=location.abovebar, style=shape.circle, size=size.auto, color=color.rgb(0,220,0), title="3-3 Strong Bullish")
plotshape(bullishWeakSignal, location=location.abovebar, style=shape.circle, size=size.auto, color=color.rgb(76, 175, 80, 20), title="Half Close Weak Bullish")
plotshape(bearishStrongSignal, location=location.belowbar, style=shape.circle, size=size.auto, color=color.rgb(220,0,0), title="1-1 Strong Bearish")
plotshape(bearishWeakSignal, location=location.belowbar, style=shape.circle, size=size.auto, color=color.rgb(255, 82, 82, 20), title="Half Close Weak Bearish")

//================ PB SIGNAL — RED ALLIGATOR LINE ONLY =================

// Candle position inside its own range
pbUpperThird = validBar and barOpen >= topThird and barClose >= topThird
pbLowerThird = validBar and barOpen <= bottomThird and barClose <= bottomThird

// Filter using only the red Alligator line (Teeth)
// Bullish candle must be completely above Teeth
// Bearish candle must be completely below Teeth
pbBullAboveTeeth = validBar and barLow > teethReal
pbBearBelowTeeth = validBar and barHigh < teethReal

// Final PB signals
pbBullSignal = pbUpperThird and pbBullAboveTeeth
pbBearSignal = pbLowerThird and pbBearBelowTeeth

// Yellow circle above bullish candle
plotshape(
     pbBullSignal,
     location=location.abovebar,
     style=shape.circle,
     color=color.yellow,
     size=size.auto,
     title="PB Bullish"
     )

// Yellow circle below bearish candle
plotshape(
     pbBearSignal,
     location=location.belowbar,
     style=shape.circle,
     color=color.yellow,
     size=size.auto,
     title="PB Bearish"
     )
     
//================ FRACTALS FULL =================
n = fractalPeriod

// UP FRACTAL
upflagDownFrontier = true
upflagUpFrontier0 = true
upflagUpFrontier1 = true
upflagUpFrontier2 = true
upflagUpFrontier3 = true
upflagUpFrontier4 = true

for i = 1 to n
    upflagDownFrontier := upflagDownFrontier and (high[n-i] < high[n])
    upflagUpFrontier0  := upflagUpFrontier0  and (high[n+i] < high[n])
    upflagUpFrontier1  := upflagUpFrontier1  and (high[n+1] <= high[n] and high[n+i+1] < high[n])
    upflagUpFrontier2  := upflagUpFrontier2  and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+i+2] < high[n])
    upflagUpFrontier3  := upflagUpFrontier3  and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+i+3] < high[n])
    upflagUpFrontier4  := upflagUpFrontier4  and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+4] <= high[n] and high[n+i+4] < high[n])

flagUpFrontier = upflagUpFrontier0 or upflagUpFrontier1 or upflagUpFrontier2 or upflagUpFrontier3 or upflagUpFrontier4
upFractal = upflagDownFrontier and flagUpFrontier

// DOWN FRACTAL
downflagDownFrontier = true
downflagUpFrontier0 = true
downflagUpFrontier1 = true
downflagUpFrontier2 = true
downflagUpFrontier3 = true
downflagUpFrontier4 = true
for i = 1 to n
    downflagDownFrontier := downflagDownFrontier and (low[n-i] > low[n])
    downflagUpFrontier0  := downflagUpFrontier0  and (low[n+i] > low[n])
    downflagUpFrontier1  := downflagUpFrontier1  and (low[n+1] >= low[n] and low[n+i+1] > low[n])
    downflagUpFrontier2  := downflagUpFrontier2  and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+i+2] > low[n])
    downflagUpFrontier3  := downflagUpFrontier3  and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+i+3] > low[n])
    downflagUpFrontier4  := downflagUpFrontier4  and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+4] >= low[n] and low[n+i+4] > low[n])

flagDownFrontier = downflagUpFrontier0 or downflagUpFrontier1 or downflagUpFrontier2 or downflagUpFrontier3 or downflagUpFrontier4
downFractal = downflagDownFrontier and flagDownFrontier

plotshape(showFractals and upFractal, location=location.abovebar, style=shape.triangleup, color=#fab34c, size=size.auto, offset=-n)
plotshape(showFractals and downFractal, location=location.belowbar, style=shape.triangledown, color=#2196f3, size=size.auto, offset=-n)
````
