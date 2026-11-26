# Minervini Swing Bot V3 - Stricter

- url: https://www.tradingview.com/script/EANjdAcC-Minervini-Swing-Bot-V3-Stricter/
- type: indicator
- pine_id: PUB;dc826e5819c44bc8a0e9288eccf8b36b
- version: 1.0

## Description

Minervini Swing Bot V3 - Stricter is a momentum breakout indicator inspired by Mark Minervini trend-template principles.

This script scans for high-quality swing trading opportunities using:
• Price above key moving averages
• 20/50/150/200 SMA trend alignment
• Relative strength momentum
• Breakout confirmation
• Pivot-based entries
• Volume expansion filters
• Trend-template validation

Features:
• Buy signal alerts
• Breakout detection
• Trend confirmation
• Dynamic support levels
• Daily swing trading focus
• Reduced false signals with stricter filtering

Best used on:
• Daily timeframe
• Growth and momentum stocks
• AI, semiconductor, cybersecurity, and leadership sectors

Recommended workflow:
Finviz scan → TradingView watchlist → Alert confirmation → Swing entry setup.

This indicator is designed for educational and swing trading research purposes and does not provide financial advice.

## Source Code

````pine
//@version=5
indicator("Minervini Swing Bot V3 - Stricter", overlay=true, explicit_plot_zorder=true)

// --- Inputs ---
pivotLength         = input.int(20, "Pivot Lookback", minval=5)
breakoutBufferPct   = input.float(1.0, "Breakout Buffer %", step=0.1)
relativeVolumeMin   = input.float(2.0, "Min Rel Volume (Breakout)", step=0.1)
rsSymbol            = input.symbol("SPY", "RS Benchmark")
vcpLookback         = input.int(10, "VCP Tightness Lookback", minval=5)
atrMultiplier       = input.float(2.0, "ATR Stop Multiplier", step=0.1)
maxDistanceFrom50   = input.float(15.0, "Max % Above 50 SMA", step=0.5)

// --- Moving Averages ---
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

// Mark Minervini requirement: SMA 200 must be trending up for at least 1 month (approx 22 days)
sma200Rising = ta.rising(sma200, 22)

// --- 52-Week High / Low ---
high52 = ta.highest(high, 252)
low52  = ta.lowest(low, 252)

// --- Volume Metrics ---
vol50 = ta.sma(volume, 50)
relVol = volume / vol50
volumeSurge = relVol >= relativeVolumeMin

// --- Relative Strength (RS) ---
// Using tuple for security call efficiency
[benchmarkClose, benchmarkSma50] = request.security(rsSymbol, timeframe.period, [close, ta.sma(close, 50)], lookahead=barmerge.lookahead_off)

rsLine = close / benchmarkClose
rsSma  = ta.sma(rsLine, 50)
rsStrong = rsLine > rsSma and rsLine > rsLine[10]

// --- Market Filter ---
marketHealthy = benchmarkClose > benchmarkSma50

// --- Trend Template (The Hard Rules) ---
trendTemplate =
     close > sma150 and close > sma200 and
     sma150 > sma200 and
     sma200Rising and
     sma50 > sma150 and
     close > sma50 and
     close >= low52 * 1.30 and   // At least 30% above 52-week low
     close >= high52 * 0.75      // Within 25% of 52-week high

// --- Extension Check ---
distanceFrom50 = ((close - sma50) / sma50) * 100
notExtended = distanceFrom50 <= maxDistanceFrom50

// --- Pivot Breakout ---
pivotHigh = ta.highest(high[1], pivotLength)
breakoutLevel = pivotHigh * (1 + breakoutBufferPct / 100)
breakout = close > breakoutLevel and close[1] <= pivotHigh

// --- VCP / Tightness Filter ---
currentATR = ta.atr(14)
atrTightening = currentATR < currentATR[vcpLookback]
rangeTightening = (high - low) < ta.sma(high - low, vcpLookback)
volumeDryingBeforeBreakout = ta.lowest(volume, vcpLookback) < vol50 * 0.7

isTightening = atrTightening and rangeTightening and volumeDryingBeforeBreakout

// --- Final Buy Signal ---
buySignal = trendTemplate and rsStrong and marketHealthy and breakout and volumeSurge and isTightening and notExtended

// --- ATR Stop ---
atrStop = close - ta.atr(14) * atrMultiplier

// --- Visual Plots ---
plot(sma50,  "SMA 50",  color=color.blue, linewidth=1)
plot(sma150, "SMA 150", color=color.orange, linewidth=1)
plot(sma200, "SMA 200", color=color.red, linewidth=2)

plot(pivotHigh, "Pivot Level", color=color.new(color.gray, 50), style=plot.style_linebr)
plot(atrStop, "ATR Stop", color=color.new(color.red, 40), style=plot.style_linebr)

plotshape(
     buySignal,
     title="Minervini Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     text="MINERVINI",
     size=size.small
 )

bgcolor(trendTemplate ? color.new(color.green, 95) : na)

// --- ALERT SYSTEM ---

// 1. Classic Alert Condition (For selecting in the dropdown)
alertcondition(
     buySignal,
     title="Minervini Buy Signal",
     message="Strict Minervini breakout on {{ticker}}. Price: {{close}}, Vol: {{volume}}"
 )

// 2. Dynamic Alert Function (Triggers on 'Any alert() function call')
if buySignal
    alert("Minervini Signal Detected on " + syminfo.ticker + " (" + str.tostring(close) + ")", alert.freq_once_per_bar_close)
````
