# Buyer Control / CVD + Volume Divergence Score v6 (CPeletz)

- url: https://www.tradingview.com/script/0XFY8qOm-Buyer-Control-CVD-Volume-Divergence-Score-v6-CPeletz/
- type: indicator
- pine_id: PUB;26644e14ec3a4f32b94269d512bc088c
- version: 5.0

## Description

This Pine script is beautiful. The ultimate **buyer/seller control warning system**. It does not predict the future by itself. It watches whether price, volume, and CVD-style buying pressure are agreeing or starting to split apart.

The simple version:

> **Red line = buyers may be losing control.**
> **Green line = sellers may be getting exhausted.**
> **Blue line = price and CVD are agreeing or disagreeing.**
> **Bear Div / Bull Div markers = possible reversal warnings.**

## 1. It builds a fake/proxy CVD

True CVD uses real market buys vs market sells. TradingView usually does not give that on normal candles, so your script estimates it.

It does this:

```pinescript
if close > open
    signedVol = volume
else if close < open
    signedVol = -volume
else
    signedVol = 0
```

So:

* Green candle = count volume as buying pressure
* Red candle = count volume as selling pressure
* Then it adds that up over time with `ta.cum()`

That creates:

```pinescript
cvd = ta.cum(signedVol)
```

So your CVD line is basically:

> “Is volume building more on green candles or red candles?”

It is not perfect order flow, but it is useful for spotting pressure shifts.

## 2. It smooths the CVD

Then it smooths CVD with an EMA:

```pinescript
cvdSmooth = ta.ema(cvd, 5)
```

This makes it less noisy so the script does not overreact to every candle.

## 3. It calculates price slope and CVD slope

This is one of the most important parts.

```pinescript
priceSlope = ta.linreg(close, slopeLen, 0) - ta.linreg(close, slopeLen, 1)
cvdSlope   = ta.linreg(cvdSmooth, slopeLen, 0) - ta.linreg(cvdSmooth, slopeLen, 1)
```

In plain English:

* Is price trending up or down?
* Is CVD trending up or down?

The dangerous setup is:

> **Price slope up, CVD slope down.**

That means price is rising, but buying pressure is fading.

That is buyer exhaustion.

## 4. It calculates price/CVD correlation

```pinescript
corrCvd = ta.correlation(ta.change(close), cvdDelta, corrLen)
```

This checks whether price movement and CVD movement agree.

Correlation ranges from:

* **+1.00** = price and CVD strongly agree
* **0.00** = no clear relationship
* **-1.00** = price and CVD are moving opposite

Then your script converts it into a 0–100 visual score:

```pinescript
corrScore = (corrCvd + 1.0) * 50.0
```

So:

* **100** = very strong agreement
* **50** = neutral/choppy
* **0** = strong disagreement

This is your blue line.

If price is rising but the blue line is falling hard, the rally may be unhealthy.

## 5. It checks volume strength

```pinescript
volRatio = volume / averageVolume
```

This tells you whether current volume is strong or weak compared to normal.

Examples:

* **0.50x** = half normal volume
* **1.00x** = normal volume
* **2.00x** = double normal volume

A breakout on low volume is suspicious.

A dump on high volume is more serious.

## 6. It finds swing highs and swing lows

This part:

```pinescript
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
```

It detects local tops and bottoms.

If `pivotLen = 5`, the script waits for a swing high/low confirmed by 5 candles on each side.

That means the divergence markers appear late by design, because Pine needs confirmation.

## 7. It detects bearish divergence

Bearish divergence means:

> Price makes a higher high, but CVD or volume makes a lower high.

That tells you buyers pushed price higher, but the pressure behind the move was weaker.

The script checks:

```pinescript
currPH > prevPH and currPHCvd < prevPHCvd
```

That means:

* Current price high is higher than previous high
* But current CVD is lower than previous CVD

That creates a **Bear Div** marker.

Bear Div means:

> “Do not chase long. Buyers may be weakening.”

It does **not** mean instant short.

## 8. It detects bullish divergence

Bullish divergence means:

> Price makes a lower low, but CVD improves or sell volume weakens.

The script checks:

```pinescript
currPL < prevPL and currPLCvd > prevPLCvd
```

That means:

* Price made a lower low
* But CVD made a higher low

That creates a **Bull Div** marker.

Bull Div means:

> “Sellers may be weakening. Watch for reclaim.”

It does **not** mean instant buy.

## 9. It builds the Buyer Loss Score

This is the red line.

The script adds points when bearish warning signs appear.

### Buyer Loss gets +25 if:

```pinescript
priceSlope > 0 and cvdSlope < 0
```

Price is rising but CVD is falling.

That is a big warning.

### Buyer Loss gets +20 or +10 if:

```pinescript
corrCvd < 0
corrCvd < 0.25
```

Price and CVD are not agreeing.

### Buyer Loss gets +10 if:

```pinescript
close > close[slopeLen] and volRatio < 0.80
```

Price is rising on weak volume.

### Buyer Loss gets +10 if:

```pinescript
rsi > 55 and rsiSlope < 0 and priceSlope > 0
```

Price is rising, RSI is above 55, but RSI is weakening.

### Buyer Loss gets +25 if:

```pinescript
recentBearDiv
```

A recent bearish divergence happened.

### Buyer Loss gets +10 if:

```pinescript
close < emaControl
```

Price is below the control EMA.

So the red line is basically saying:

> “How many buyer weakness signs are stacking together?”

## 10. It builds the Seller Exhaustion Score

This is the green line.

It adds points when sellers may be running out of pressure.

Seller Exhaustion rises when:

* Price is falling but CVD is rising
* Bullish divergence appears
* Price drops on weak volume
* RSI starts improving while price is still weak
* Price reclaims the EMA

So the green line tells you:

> “Are sellers weakening enough for a possible bounce?”

## How to trade it

### For longs

Good long environment:

* Buyer Loss under **40**
* Seller Exhaustion rising after a dump
* Bull Div appears
* Price reclaims EMA/VWAP/midline
* CVD/correlation improves
* Price makes a higher low

Bad long environment:

* Buyer Loss above **65**
* Bear Div appears
* Price below EMA/VWAP/midline
* Blue correlation line falling
* CVD not confirming price

## Main score meanings

| Score                       | Meaning                       |
| --------------------------- | ----------------------------- |
| **Buyer Loss 0–40**         | Buyers okay                   |
| **Buyer Loss 40–65**        | Buyers stalling / caution     |
| **Buyer Loss 65+**          | Buyers likely losing control  |
| **Seller Exhaustion 0–40**  | Sellers still okay            |
| **Seller Exhaustion 40–65** | Sellers slowing               |
| **Seller Exhaustion 65+**   | Possible bottom/reclaim setup |

## Important limitation

Your script is not true CVD.

It is a **candle-direction CVD proxy**.

So it can help you see pressure changes, but you should always confirm with:

* price structure
* support/resistance
* VWAP or Bollinger basis
* BTC direction
* actual volume
* reclaim/failure candles

## The cleanest way to use it

For a top/reversal warning:

> **Bear Div + Buyer Loss over 65 + price breaks EMA/VWAP = buyers lost control.**

For a bottom/reclaim warning:

> **Bull Div + Seller Exhaustion rising + price reclaims EMA/VWAP = sellers may be losing control.**

The script’s job is not to tell you “buy now” or “sell now.”

Its job is to tell you:

> **Is the move healthy, or is pressure starting to diverge?**

## Source Code

````pine
//@version=6
indicator("Buyer Control + CVD Divergence + Adaptive Bottom Risk v7", overlay=false, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cvdMode = input.string("Close vs Open", "CVD Proxy Method", options=["Close vs Open", "Close vs Previous Close"])
pivotLen = input.int(5, "Swing Pivot Length", minval=2, maxval=20)
corrLen = input.int(34, "Price/CVD Correlation Length", minval=5, maxval=200)
slopeLen = input.int(14, "Momentum Slope Length", minval=3, maxval=100)
volLen = input.int(20, "Volume Average Length", minval=5, maxval=200)
rsiLen = input.int(14, "RSI Length", minval=5, maxval=50)
emaLen = input.int(20, "Control EMA Length", minval=5, maxval=100)

warnLevel = input.int(40, "Buyer Warning Level", minval=1, maxval=100)
dangerLevel = input.int(65, "Buyer Danger Level", minval=1, maxval=100)

compressionLen = input.int(20, "Compression Length", minval=10, maxval=100)
rangeLen = input.int(30, "Range Lookback", minval=10, maxval=200)
breakRiskLevel = input.int(65, "Bottom Risk Warning Level", minval=1, maxval=100)

showBg = input.bool(true, "Show Background Warnings")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CVD proxy
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float v = nz(volume, 0.0)

float signedVol = 0.0

if cvdMode == "Close vs Open"
    signedVol := close > open ? v : close < open ? -v : 0.0
else
    signedVol := close > close[1] ? v : close < close[1] ? -v : 0.0

float cvd = ta.cum(signedVol)
float cvdSmooth = ta.ema(cvd, 5)
float cvdDelta = ta.change(cvdSmooth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float priceSlope = ta.linreg(close, slopeLen, 0) - ta.linreg(close, slopeLen, 1)
float cvdSlope = ta.linreg(cvdSmooth, slopeLen, 0) - ta.linreg(cvdSmooth, slopeLen, 1)

float corrRaw = ta.correlation(ta.change(close), cvdDelta, corrLen)
float corrCvd = nz(corrRaw, 0.0)
float corrScore = (corrCvd + 1.0) * 50.0

float volAvg = ta.sma(v, volLen)
float volRatio = volAvg == 0.0 ? 0.0 : v / volAvg

float rsi = ta.rsi(close, rsiLen)
float rsiSlope = ta.linreg(rsi, slopeLen, 0) - ta.linreg(rsi, slopeLen, 1)

float emaControl = ta.ema(close, emaLen)

float macdLine = ta.ema(close, 12) - ta.ema(close, 26)
float macdSignal = ta.ema(macdLine, 9)
float macdHist = macdLine - macdSignal
float macdHistSlope = macdHist - macdHist[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot divergence
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var float prevPH = na
var float prevPHCvd = na
var float prevPHVol = na

var float prevPL = na
var float prevPLCvd = na
var float prevPLVol = na

bool bearCvdDiv = false
bool bearVolDiv = false
bool bullCvdDiv = false
bool bullVolDiv = false

if not na(ph)
    float currPH = ph
    float currPHCvd = cvdSmooth[pivotLen]
    float currPHVol = v[pivotLen]

    bearCvdDiv := not na(prevPH) and currPH > prevPH and currPHCvd < prevPHCvd
    bearVolDiv := not na(prevPH) and currPH > prevPH and currPHVol < prevPHVol

    prevPH := currPH
    prevPHCvd := currPHCvd
    prevPHVol := currPHVol

if not na(pl)
    float currPL = pl
    float currPLCvd = cvdSmooth[pivotLen]
    float currPLVol = v[pivotLen]

    bullCvdDiv := not na(prevPL) and currPL < prevPL and currPLCvd > prevPLCvd
    bullVolDiv := not na(prevPL) and currPL < prevPL and currPLVol < prevPLVol

    prevPL := currPL
    prevPLCvd := currPLCvd
    prevPLVol := currPLVol

bool bearDivEvent = bearCvdDiv or bearVolDiv
bool bullDivEvent = bullCvdDiv or bullVolDiv

int bearBarsAgo = ta.barssince(bearDivEvent)
int bullBarsAgo = ta.barssince(bullDivEvent)

bool recentBearDiv = not na(bearBarsAgo) and bearBarsAgo <= pivotLen * 3
bool recentBullDiv = not na(bullBarsAgo) and bullBarsAgo <= pivotLen * 3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Buyer Loss Score
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float buyerLossScore = 0.0

buyerLossScore += priceSlope > 0 and cvdSlope < 0 ? 25.0 : 0.0
buyerLossScore += corrCvd < 0 ? 20.0 : corrCvd < 0.25 ? 10.0 : 0.0
buyerLossScore += close > close[slopeLen] and volRatio < 0.80 ? 10.0 : 0.0
buyerLossScore += rsi > 55 and rsiSlope < 0 and priceSlope > 0 ? 10.0 : 0.0
buyerLossScore += recentBearDiv ? 25.0 : 0.0
buyerLossScore += close < emaControl ? 10.0 : 0.0

buyerLossScore := math.min(buyerLossScore, 100.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Seller Exhaustion Score
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float sellerExhaustionScore = 0.0

sellerExhaustionScore += priceSlope < 0 and cvdSlope > 0 ? 25.0 : 0.0
sellerExhaustionScore += recentBullDiv ? 30.0 : 0.0
sellerExhaustionScore += close < close[slopeLen] and volRatio < 0.80 ? 10.0 : 0.0
sellerExhaustionScore += rsi < 45 and rsiSlope > 0 and priceSlope < 0 ? 10.0 : 0.0
sellerExhaustionScore += close > emaControl and close[1] <= emaControl[1] ? 15.0 : 0.0

sellerExhaustionScore := math.min(sellerExhaustionScore, 100.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Compression / range logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float basis = ta.sma(close, compressionLen)
float dev = ta.stdev(close, compressionLen)
float upper = basis + dev * 2.0
float lower = basis - dev * 2.0

float bbWidth = basis == 0.0 ? 0.0 : (upper - lower) / basis
float avgBbWidth = ta.sma(bbWidth, compressionLen)

bool isCompressed = bbWidth < avgBbWidth * 0.75

float atr = ta.atr(14)
float avgAtr = ta.sma(atr, compressionLen)

bool atrCompressed = atr < avgAtr * 0.80

float rangeHigh = ta.highest(high, rangeLen)
float rangeLow = ta.lowest(low, rangeLen)
float rangeSize = rangeHigh - rangeLow

float rangePosition = rangeSize == 0.0 ? 0.5 : (close - rangeLow) / rangeSize

bool nearRangeLow = rangePosition < 0.35
bool nearRangeHigh = rangePosition > 0.65

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Bottom Drop Risk
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool weakMomentum = priceSlope <= 0 and cvdSlope <= 0
bool buyersFading = buyerLossScore >= warnLevel
bool sellersActive = sellerExhaustionScore < 40
bool weakCorr = corrCvd < 0.25
bool weakVolume = volRatio < 0.85
bool belowControl = close < emaControl
bool macdImproving = macdHist > macdHist[1]
bool macdBullish = macdHist > 0
bool cvdHealthy = corrScore >= 65 and cvdSlope >= 0
bool buyerHealthy = buyerLossScore < warnLevel

float rawBottomRisk = 0.0

rawBottomRisk += isCompressed ? 20.0 : 0.0
rawBottomRisk += atrCompressed ? 15.0 : 0.0
rawBottomRisk += nearRangeLow ? 15.0 : 0.0
rawBottomRisk += weakMomentum ? 15.0 : 0.0
rawBottomRisk += buyersFading ? 15.0 : 0.0
rawBottomRisk += sellersActive ? 10.0 : 0.0
rawBottomRisk += weakCorr ? 10.0 : 0.0
rawBottomRisk += weakVolume ? 5.0 : 0.0
rawBottomRisk += belowControl ? 10.0 : 0.0

// Adaptive reduction:
// If buyers are still healthy and MACD/CVD are improving,
// reduce false bottom-risk warnings.
float adaptiveReduction = 0.0

adaptiveReduction += buyerHealthy ? 10.0 : 0.0
adaptiveReduction += macdImproving ? 10.0 : 0.0
adaptiveReduction += macdBullish ? 10.0 : 0.0
adaptiveReduction += cvdHealthy ? 15.0 : 0.0
adaptiveReduction += close > emaControl ? 10.0 : 0.0

// Adaptive increase:
// If buyer loss is high, CVD is weak, and price is under EMA,
// increase breakdown risk.
float adaptiveIncrease = 0.0

adaptiveIncrease += buyerLossScore >= dangerLevel ? 15.0 : 0.0
adaptiveIncrease += corrScore < 40 ? 15.0 : 0.0
adaptiveIncrease += cvdSlope < 0 ? 10.0 : 0.0
adaptiveIncrease += macdHist < 0 and macdHistSlope < 0 ? 10.0 : 0.0
adaptiveIncrease += close < emaControl and nearRangeLow ? 15.0 : 0.0

float bottomDropRisk = rawBottomRisk + adaptiveIncrease - adaptiveReduction
bottomDropRisk := math.max(math.min(bottomDropRisk, 100.0), 0.0)

bool rangeBreakdown = not na(rangeLow[1]) and close < rangeLow[1] and v > volAvg
bool bottomTrapWarning = bottomDropRisk >= breakRiskLevel
bool bottomTrapConfirmed = bottomTrapWarning and rangeBreakdown
bool bottomTrapNew = bottomTrapWarning and not bottomTrapWarning[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trade Quality Score
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float tradeQuality = 50.0

tradeQuality += buyerLossScore < 40 ? 15.0 : buyerLossScore > 65 ? -20.0 : -5.0
tradeQuality += sellerExhaustionScore > 40 and close > emaControl ? 10.0 : 0.0
tradeQuality += bottomDropRisk < 40 ? 15.0 : bottomDropRisk > 65 ? -20.0 : -5.0
tradeQuality += corrScore > 65 ? 15.0 : corrScore < 40 ? -15.0 : 0.0
tradeQuality += macdHist > 0 ? 10.0 : -10.0
tradeQuality += macdHistSlope > 0 ? 5.0 : -5.0
tradeQuality += close > emaControl ? 10.0 : -10.0

tradeQuality := math.max(math.min(tradeQuality, 100.0), 0.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hline(80, "Strong", color=color.new(color.green, 70))
hline(65, "High", color=color.new(color.orange, 65))
hline(50, "Neutral", color=color.new(color.gray, 75))
hline(40, "Caution", color=color.new(color.orange, 70))
hline(20, "Weak", color=color.new(color.red, 75))

plot(buyerLossScore, "Buyer Loss Score", color=color.red, linewidth=2)
plot(sellerExhaustionScore, "Seller Exhaustion Score", color=color.lime, linewidth=2)
plot(bottomDropRisk, "Adaptive Bottom Drop Risk", color=color.purple, linewidth=2)
plot(corrScore, "Price/CVD Correlation Score", color=color.blue, linewidth=1)
plot(tradeQuality, "Trade Quality Score", color=color.white, linewidth=2)

plotshape(bearDivEvent, title="Bearish CVD/Volume Divergence", style=shape.triangledown, location=location.top, color=color.red, text="Bear Div", offset=-pivotLen)
plotshape(bullDivEvent, title="Bullish CVD/Volume Divergence", style=shape.triangleup, location=location.bottom, color=color.lime, text="Bull Div", offset=-pivotLen)
plotshape(bottomTrapNew, title="Bottom Trap Warning", style=shape.diamond, location=location.top, color=color.purple, text="Trap?")
plotshape(bottomTrapConfirmed, title="Bottom Drop Confirmed", style=shape.xcross, location=location.top, color=color.red, text="Drop")

bgcolor(showBg and bottomTrapConfirmed ? color.new(color.red, 78) : showBg and bottomTrapWarning ? color.new(color.purple, 86) : showBg and buyerLossScore >= dangerLevel ? color.new(color.red, 88) : showBg and buyerLossScore >= warnLevel ? color.new(color.orange, 90) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 8, border_width=1)

string state = "NEUTRAL"
color stateColor = color.gray

if bottomTrapConfirmed
    state := "BOTTOM DROPPING"
    stateColor := color.red
else if bottomTrapWarning
    state := "BOTTOM TRAP RISK"
    stateColor := color.purple
else if tradeQuality >= 80
    state := "HIGH QUALITY LONG"
    stateColor := color.green
else if tradeQuality >= 65
    state := "BULLISH"
    stateColor := color.lime
else if buyerLossScore >= dangerLevel
    state := "BUYERS LOSING CONTROL"
    stateColor := color.red
else if buyerLossScore >= warnLevel
    state := "STALLING / CAUTION"
    stateColor := color.orange

if barstate.islast
    table.cell(dash, 0, 0, "Status", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, state, text_color=color.white, bgcolor=stateColor)

    table.cell(dash, 0, 1, "Trade Quality", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(tradeQuality, "#.0"), text_color=color.white, bgcolor=color.new(color.white, 80))

    table.cell(dash, 0, 2, "Buyer Loss", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(buyerLossScore, "#.0"), text_color=color.white, bgcolor=color.new(color.red, 25))

    table.cell(dash, 0, 3, "Seller Exhaustion", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, str.tostring(sellerExhaustionScore, "#.0"), text_color=color.white, bgcolor=color.new(color.green, 25))

    table.cell(dash, 0, 4, "Bottom Risk", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, str.tostring(bottomDropRisk, "#.0"), text_color=color.white, bgcolor=color.new(color.purple, 25))

    table.cell(dash, 0, 5, "CVD Corr", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, str.tostring(corrCvd, "#.00"), text_color=color.white, bgcolor=color.new(color.blue, 25))

    table.cell(dash, 0, 6, "Vol Ratio", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, str.tostring(volRatio, "#.00") + "x", text_color=color.white, bgcolor=color.new(color.gray, 30))

    table.cell(dash, 0, 7, "Range Pos", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, str.tostring(rangePosition * 100.0, "#.0") + "%", text_color=color.white, bgcolor=color.new(color.gray, 30))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(tradeQuality >= 80 and tradeQuality[1] < 80, "High Quality Long", "Trade Quality crossed above 80.")
alertcondition(buyerLossScore >= dangerLevel and buyerLossScore[1] < dangerLevel, "Buyers Losing Control", "Buyer Loss Score crossed into danger.")
alertcondition(bearDivEvent, "Bearish CVD/Volume Divergence", "Bearish divergence detected.")
alertcondition(bullDivEvent, "Bullish CVD/Volume Divergence", "Bullish divergence detected.")
alertcondition(bottomTrapNew, "Bottom Trap Warning", "Adaptive Bottom Drop Risk crossed warning level.")
alertcondition(bottomTrapConfirmed, "Bottom Drop Confirmed", "Compressed bottom range broke down with elevated volume.")
````
