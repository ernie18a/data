# Smart S/R Price Action with Volume, Breakout Retest & Auto SL/TP

- url: https://www.tradingview.com/script/FArv6PIm-Smart-S-R-Price-Action-with-Volume-Breakout-Retest-Auto-SL-TP/
- type: indicator
- pine_id: PUB;c7be228d576445d5b838beeb241016f3
- version: 1.0

## Description

This indicator combines support and resistance, price action, and volume confirmation to generate higher-quality trading signals. It is designed to identify both reversal setups at key levels and breakout–retest opportunities, while automatically plotting adaptive Stop Loss and Take Profit levels.

The script detects dynamic support and resistance using pivot points and expands them into zones to better reflect real market behavior. Trade signals are only generated when price shows strong rejection candles (wick-based confirmation) along with above-average volume, helping filter out weak or low-probability setups.

For breakout trading, the indicator tracks when price closes beyond a key level with strong volume, then waits for a retest of that level before confirming an entry—reducing the likelihood of false breakouts.

## Source Code

````pine
//@version=5
indicator("S/R + Volume + BO + Auto SL/TP", overlay=true)

// === INPUTS ===
pivotLen   = input.int(5, "Pivot Length")
zoneBuffer = input.float(0.5, "Zone Buffer (%)")
wickRatio  = input.float(2.0, "Wick Ratio")

volLen     = input.int(20, "Volume MA Length")
volMult    = input.float(1.2, "Volume Multiplier")

atrLen     = input.int(14, "ATR Length")
atrMult    = input.float(1.5, "ATR Multiplier for SL")

rr         = input.float(2.0, "Risk/Reward Ratio")

// === CORE CALCULATIONS ===
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

var float resistance = na
var float support = na

if not na(pivotHigh)
    resistance := pivotHigh

if not na(pivotLow)
    support := pivotLow

// Zones
resHigh = resistance * (1 + zoneBuffer / 100)
resLow  = resistance * (1 - zoneBuffer / 100)

supHigh = support * (1 + zoneBuffer / 100)
supLow  = support * (1 - zoneBuffer / 100)

// Candle
body = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

bullReject = lowerWick > body * wickRatio and close > open
bearReject = upperWick > body * wickRatio and close < open

// Volume
volMA = ta.sma(volume, volLen)
strongVol = volume > volMA * volMult

// ATR
atr = ta.atr(atrLen)

// === SIGNALS ===
buySignal  = close >= supLow and close <= supHigh and bullReject and strongVol
sellSignal = close >= resLow and close <= resHigh and bearReject and strongVol

// === STOP LOSS & TAKE PROFIT ===
var float sl = na
var float tp = na

if buySignal
    sl := close - atr * atrMult
    risk = close - sl
    tp := close + risk * rr

if sellSignal
    sl := close + atr * atrMult
    risk = sl - close
    tp := close - risk * rr

// === PLOTTING ===
plot(support, "Support", color=color.green, linewidth=2)
plot(resistance, "Resistance", color=color.red, linewidth=2)

// Signals
plotshape(buySignal, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// SL/TP lines (only show after signal)
plot(sl, "Stop Loss", color=color.red, style=plot.style_linebr, linewidth=2)
plot(tp, "Take Profit", color=color.blue, style=plot.style_linebr, linewidth=2)

// Alerts
alertcondition(buySignal, title="Buy", message="Buy with SL/TP")
alertcondition(sellSignal, title="Sell", message="Sell with SL/TP")
````
