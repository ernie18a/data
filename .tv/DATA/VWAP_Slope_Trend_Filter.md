<!-- tradingview-pine-id: PUB;d06ae9a678fe48fbb5cf246011e09f89 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Slope Trend Filter

Source: https://www.tradingview.com/script/OkbSIHvu-VWAP-Slope-Trend-Filter/

## Description

# VWAP Slope Trend Filter

The **VWAP Slope Trend Filter** is designed to identify the current intraday market direction by analyzing both the position and the slope of the Volume Weighted Average Price (VWAP).

Instead of simply checking whether price is above or below VWAP, the indicator measures how strongly VWAP is rising or falling. This helps filter out flat or sideways market conditions where trend-following entries are more likely to fail.

The VWAP slope is normalized using ATR, allowing the filter to adapt to different levels of market volatility.

## Trend Colors

**Green VWAP – Bullish Trend**
The VWAP is rising with sufficient momentum. Traders can use this condition as a filter for long setups.

**Red VWAP – Bearish Trend**
The VWAP is falling with sufficient momentum. Traders can use this condition as a filter for short setups.

**Gray VWAP – Neutral / Range**
The VWAP slope is too weak to confirm a clear trend. These conditions can be avoided to reduce trades during sideways markets.

## Main Features

* Session VWAP
* ATR-normalized VWAP slope
* Bullish, bearish, and neutral trend detection
* Adjustable slope sensitivity
* Adjustable slope lookback length
* Dynamic VWAP coloring
* Optional background trend highlighting
* Trend-change markers
* Bullish and bearish alert conditions

## Example Usage

The indicator can be used as a directional filter for another entry system.

A possible long setup:

1. Price is above VWAP.
2. VWAP is green and rising.
3. The primary entry indicator produces a long signal.
4. Enter the trade with predefined risk management.

A possible short setup:

1. Price is below VWAP.
2. VWAP is red and falling.
3. The primary entry indicator produces a short signal.
4. Enter the trade with predefined risk management.

When the VWAP is gray, traders may choose to avoid new positions until a clearer directional trend develops.

## Important

This indicator is intended to be used as a **trend filter**, not as a standalone trading system. It does not guarantee profitable trades and should be combined with proper entry rules, stop-loss placement, risk management, and backtesting.

The optimal Slope Length and Minimum Slope settings may vary depending on the market, trading session, and timeframe.

---

## Source Code

````pine
//@version=6
indicator("VWAP Slope Trend Filter", overlay=true)

//====================================================
// SETTINGS
//====================================================

// VWAP Quelle
src = input.source(hlc3, "VWAP Source")

// Wie viele Kerzen für die Steigung betrachtet werden
slopeLength = input.int(5, "Slope Length", minval=1)

// Mindeststeigung in ATR-Einheiten
minSlope = input.float(0.03, "Minimum Slope", step=0.01)

// ATR für Normalisierung
atrLength = input.int(14, "ATR Length", minval=1)

// Hintergrund anzeigen
showBackground = input.bool(true, "Show Trend Background")

// Signale anzeigen
showSignals = input.bool(true, "Show Trend Change Signals")

//====================================================
// VWAP
//====================================================

vwapValue = ta.vwap(src)

//====================================================
// ATR
//====================================================

atrValue = ta.atr(atrLength)

//====================================================
// VWAP SLOPE
//====================================================

// Veränderung des VWAP über X Kerzen
rawSlope = vwapValue - vwapValue[slopeLength]

// Durch ATR normalisieren
normalizedSlope = atrValue != 0 ?
     rawSlope / atrValue :
     0.0

//====================================================
// TREND
//====================================================

bullTrend = normalizedSlope > minSlope

bearTrend = normalizedSlope < -minSlope

rangeTrend = not bullTrend and not bearTrend

//====================================================
// COLORS
//====================================================

vwapColor =
     bullTrend ? color.lime :
     bearTrend ? color.red :
     color.gray

//====================================================
// VWAP PLOT
//====================================================

plot(
     vwapValue,
     title="VWAP",
     color=vwapColor,
     linewidth=3
)

//====================================================
// BACKGROUND
//====================================================

bgcolor(
     showBackground ?
         bullTrend ? color.new(color.green, 92) :
         bearTrend ? color.new(color.red, 92) :
         color.new(color.gray, 94)
     : na
)

//====================================================
// TREND CHANGE SIGNALS
//====================================================

bullStart = bullTrend and not bullTrend[1]
bearStart = bearTrend and not bearTrend[1]

plotshape(
     showSignals and bullStart,
     title="Bull Trend Start",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     text="LONG"
)

plotshape(
     showSignals and bearStart,
     title="Bear Trend Start",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     text="SHORT"
)

//====================================================
// ALERTS
//====================================================

alertcondition(
     bullStart,
     title="VWAP Bull Trend",
     message="VWAP Slope changed to bullish"
)

alertcondition(
     bearStart,
     title="VWAP Bear Trend",
     message="VWAP Slope changed to bearish"
)
````
