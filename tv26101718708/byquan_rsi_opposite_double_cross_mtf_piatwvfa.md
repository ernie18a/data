# byquan RSI Opposite Double Cross MTF

- url: https://www.tradingview.com/script/PiatWvFa/
- type: indicator
- pine_id: PUB;98bab218417345b89301246a79054fb0
- version: 2.0

## Description

// RSI Opposite Double Cross MTF

This indicator identifies **Opposite Double Cross** signals on RSI, designed to catch potential short-term reversals when RSI momentum fails to continue in its initial direction.

The core idea is based on a two-step RSI behavior within a short lookback window: an initial cross between RSI and its moving average, followed by an **opposite cross** in the opposite direction while respecting the 50 midline bias. This creates a contrarian signal that highlights exhaustion or rejection in momentum.

### How It Works

**Components:**
- RSI (default length 14) calculated on a user-selected timeframe (can be higher timeframe via MTF).
- Moving Average of RSI (default 9 periods, with choice of SMA, EMA, or RMA).
- Detects initial crossover (RSI crosses above MA) or crossunder (RSI crosses below MA).
- Monitors the next few bars (default 5-bar window) for an **opposite cross**.

**Signal Conditions:**
- **Sell Signal (Red Triangle)**: RSI first crosses above its MA, then crosses back down while the MA is still above 50. This suggests bullish momentum failed quickly.
- **Buy Signal (Green Triangle)**: RSI first crosses below its MA, then crosses back up while the MA is still below 50. This suggests bearish momentum failed quickly.

This "opposite double cross" logic within a limited bar window helps filter for high-probability mean-reversion moments around the central 50 level.

### Visual Elements
- **Blue Line**: Raw RSI
- **Orange Line**: RSI Moving Average
- Green/Red triangles plotted directly on the RSI line for clear signal visibility
- Horizontal lines at 30 (Oversold), 50 (Mid), and 70 (Overbought)

### How to Use

- **Buy Signal**: Green triangle appears when bearish momentum reverses quickly. Consider long positions, especially if price is near support or showing bullish structure.
- **Sell Signal**: Red triangle appears when bullish momentum reverses quickly. Consider short positions, especially if price is near resistance.
- Best used as a **confluence tool** together with price action, support/resistance levels, or higher timeframe trend analysis.
- The MTF feature allows you to use higher timeframe RSI dynamics on lower timeframe charts for stronger signals.

### Recommended Settings
- **Timeframe**: Current or one higher (e.g., use 15m on 5m chart, or 1H on 15m chart).
- **Lookback Bars**: 3–7 bars (smaller = more sensitive, larger = stricter).
- **MA Type**: EMA or RMA generally performs well for smoothing.
- Best suited for **intraday trading** on 5m, 15m, and 30m timeframes across forex, indices, and crypto.

This script is not just another RSI crossover indicator. Its originality comes from the **Opposite Double Cross detection logic** combined with MTF capability and the 50-level filter, aiming to capture failed momentum moves rather than trend following.

The indicator is open-source and shared for educational purposes only. It is not financial advice. Always backtest thoroughly and combine with proper risk management.

Feedback and ideas for improvement are welcome!

## Source Code

````pine
//@version=5
indicator("RSI Opposite 2 Cat Ban 2", overlay=false)

// INPUT
tf       = input.timeframe("", "RSI Timeframe (để trống = current)")
rsiLen   = input.int(14, "RSI Length")
maLen    = input.int(9, "MA Length")
maType   = input.string("EMA", "MA Type", options=["SMA","EMA","RMA"])
lookBars = input.int(10, "Bars Window")
midBuy   = input.float(50.0, "BUY Filter  – MA phải dưới mức", minval=1.0, maxval=99.0, step=0.5)
midSell  = input.float(50.0, "SELL Filter – MA phải trên mức", minval=1.0, maxval=99.0, step=0.5)

tf_used = tf == "" ? timeframe.period : tf

rsi_tf = request.security(syminfo.tickerid, tf_used, ta.rsi(close, rsiLen))

rsiMA_tf = request.security(syminfo.tickerid, tf_used,
     maType == "SMA" ? ta.sma(ta.rsi(close, rsiLen), maLen) :
     maType == "EMA" ? ta.ema(ta.rsi(close, rsiLen), maLen) :
                       ta.rma(ta.rsi(close, rsiLen), maLen))

crossUp   = ta.crossover(rsi_tf, rsiMA_tf)
crossDown = ta.crossunder(rsi_tf, rsiMA_tf)

var int state     = 0
var int barsCount = 0

if barsCount > lookBars
    state     := 0
    barsCount := 0

if state == 0
    if crossUp
        state     := 1
        barsCount := 1
    else if crossDown
        state     := -1
        barsCount := 1
else
    barsCount += 1

bool buySignal  = false
bool sellSignal = false

if state == 1 and crossDown
    if rsiMA_tf > midSell
        sellSignal := true
    state     := 0
    barsCount := 0

if state == -1 and crossUp
    if rsiMA_tf < midBuy
        buySignal := true
    state     := 0
    barsCount := 0

// PLOT
plot(rsi_tf,   "RSI",    color=color.blue,   linewidth=2)
plot(rsiMA_tf, "RSI MA", color=color.orange, linewidth=2)

hline(70,      "OB",          color=color.red)
hline(midSell, "SELL Filter", color=color.red,   linestyle=hline.style_dashed)
hline(midBuy,  "BUY Filter",  color=color.green, linestyle=hline.style_dashed)
hline(30,      "OS",          color=color.green)

// SIGNAL – nằm đúng trên đường RSI
plotshape(buySignal  ? rsi_tf : na, title="BUY",  location=location.absolute,
     color=color.green, style=shape.triangleup,   size=size.small)
plotshape(sellSignal ? rsi_tf : na, title="SELL", location=location.absolute,
     color=color.red,   style=shape.triangledown, size=size.small)

alertcondition(buySignal or sellSignal, title="RSI Double Cross Alert",
     message="RSI double cross signal")
````
