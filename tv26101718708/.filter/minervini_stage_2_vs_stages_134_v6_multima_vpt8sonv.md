# Minervini Stage 2 vs Stages 1,3,4 (v6 - Multi-MA)

- url: https://www.tradingview.com/script/VPT8SoNv-Minervini-Stage-2-vs-Stages-1-3-4-v6-Multi-MA/
- type: indicator
- pine_id: PUB;634e3449787d4e788e00b108bbd89280
- version: 1.0

## Description

Based on Lengendary trader Sir Mark Minarvini's teachings, it's my effort for fellow traders so we can identify different stages of stocks. Credit only belongs to SIR MARK MINARVINI. 
And I'm open to any suggestions.

## Source Code

````pine
//@version=6
indicator("Minervini Stage 2 vs Stages 1,3,4 (v6 - Multi-MA)", overlay=true)

// --- Group: MA Configuration ---
maType50  = input.string("EMA", title="Short MA Type", options=["SMA", "EMA", "WMA", "HMA"], group="MA Styles")
len50     = input.int(50, title="Short MA Length", group="MA Styles")

maType150 = input.string("EMA", title="Medium MA Type", options=["SMA", "EMA", "WMA", "HMA"], group="MA Styles")
len150    = input.int(150, title="Medium MA Length", group="MA Styles")

maType200 = input.string("EMA", title="Long MA Type", options=["SMA", "EMA", "WMA", "HMA"], group="MA Styles")
len200    = input.int(200, title="Long MA Length", group="MA Styles")

lookback200 = input.int(22, title="Long MA Trend Slope Lookback (Bars)", group="MA Styles")

// --- 1. Compute MAs Directly (Bypasses Switch Block Spacing Errors) ---
ma50 = maType50 == "SMA" ? ta.sma(close, len50) : maType50 == "EMA" ? ta.ema(close, len50) : maType50 == "WMA" ? ta.wma(close, len50) : ta.hma(close, len50)

ma150 = maType150 == "SMA" ? ta.sma(close, len150) : maType150 == "EMA" ? ta.ema(close, len150) : maType150 == "WMA" ? ta.wma(close, len150) : ta.hma(close, len150)

ma200 = maType200 == "SMA" ? ta.sma(close, len200) : maType200 == "EMA" ? ta.ema(close, len200) : maType200 == "WMA" ? ta.wma(close, len200) : ta.hma(close, len200)

// --- 2. 52-Week High and Low ---
high52 = ta.highest(high, 252)
low52  = ta.lowest(low, 252)

// --- 3. Strict Trend Template Conditions (Stage 2) ---
c1 = (close > ma150) and (close > ma200)
c2 = (ma150 > ma200)
c3 = (ma200 > ma200[lookback200])
c4 = (ma50 > ma150) and (ma50 > ma200)
c5 = (close > ma50)
c6 = (close >= low52 * 1.30)
c7 = (close >= high52 * 0.75)

trendTemplateMet = c1 and c2 and c3 and c4 and c5 and c6 and c7

// --- 4. Identifying the START (The Transition) ---
stage2Start = trendTemplateMet and not trendTemplateMet[1]

// --- 5. Volume Confirmation for the Breakout ---
volMa = ta.sma(volume, 20)
volumeConfirmed = volume > volMa * 1.2
earlyEntrySignal = stage2Start and volumeConfirmed

// --- 6. Plotting Selected Moving Averages ---
plot(ma50, color=color.blue, title="Short MA Line")
plot(ma150, color=color.orange, title="Medium MA Line")
plot(ma200, color=color.red, title="Long MA Line")

// --- 7. Background & Signal Painting ---
bgColorChoice = trendTemplateMet ? color.new(color.green, 92) : color.new(color.red, 94)
bgcolor(bgColorChoice, title="Stage Lifecycle Background")

// Plot a green "Buy" triangle underneath the breakout candle
plotshape(earlyEntrySignal, title="Stage 2 Start Trigger", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// --- 8. Dynamic Alerts ---
if earlyEntrySignal
    alert("Boom! " + syminfo.ticker + " has officially triggered a confirmed Stage 2 Start on high volume.", alert.freq_once_per_bar_close)
````
