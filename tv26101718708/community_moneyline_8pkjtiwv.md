# Community MoneyLine

- url: https://www.tradingview.com/script/8PKjTIwv-Community-MoneyLine/
- type: indicator
- pine_id: PUB;f46fbc209a3f4a0a90fc1e3b577effbd
- version: 1.0

## Description

[b]Overview[/b]
The Community MoneyLine is a advanced volatility-based trend-following indicator, refined for precision entries and exits. It is designed to capture macro market shifts while providing tools to mitigate the "sideways meat grinder." This version features built-in smoothing and optional filters to help traders avoid false signals during low-volatility periods.

[b]How it Works[/b]
The core engine uses a modified trailing-stop mechanism that generates a unique "Staircase Support/Resistance."

In an Uptrend (Bullish): The green support line only moves UP with the price, locking in profits. It will never move down until the trend officially flips.

In a Downtrend (Bearish): The red resistance line only moves DOWN, tracking the descent. It will never move up until momentum shifts back.

The indicator is designed to wait for a decisive price action (such as a low touching the line in a bullish trend) before triggering a "Flip."

[b]Key Features[/b]
"Clean Break" Signals: To maintain visual clarity, the script features a gap between trend shifts. This removes confusing vertical connecting lines and highlights the exact moment a pivot occurs.

Heikin Ashi Price Smoothing: The script internally utilizes Heikin Ashi candle calculations for its trailing-stop logic. This significantly reduces whipsaws caused by single-candle wicks or "fake" price spikes, ensuring you stick with the dominant trend longer.

Pinpointed Labeling: "Bullish" and "Bearish" labels are pinned precisely to the MoneyLine itself rather than floating above the candles, ensuring constant visibility and a clean chart.

Momentum Filter (Noise Reduction): Features an EMA-based filter that requires price confirmation relative to a medium-term moving average before a trend flip is confirmed. This is designed specifically for range-bound or "choppy" market phases.

[b]Settings Explained (Current Defaults)[/b]
ATR Sensitivity (Current: 7): Controls the lookback period for the Average True Range. A value of 7 provides a balance between rapid reaction and stability.

Trend Depth (Current: 3.5): This is the multiplier for the ATR. A 3.5 depth pushes the line further from the price action, capturing larger macro moves while avoiding premature stop-outs during normal volatility.

Use Heikin Ashi Smoothing: Use HA candles internally to smooth the trailing stop calculation.

Label Offset (Current: 0.6): Customizes the vertical gap between the signal text and the MoneyLine (higher values push the labels further away).

Enable Momentum Filter: If enabled, the system requires an additional confirmation before flipping to Bullish (must be > EMA) or Bearish (must be < EMA). Enable this to filter range chop.

## Source Code

````pine
// The Multi-Timeframe Trick: If you are trading on the 15m or 1h chart,
// try setting the indicator's ATR Sensitivity to a higher value (like 20)
// or even manually setting the indicator's timeframe (in the settings menu)
// to one step higher than your chart. This helps you stay on the right side
// of the "macro" trend while ignoring the "micro" noise.

// -----------------------------------------------------------------------------

//@version=6
indicator("Community MoneyLine", overlay=true)

// --- Inputs ---
atrPeriod  = input.int(7, "ATR Sensitivity", minval=1) // Increased default to 14 for stability
multiplier = input.float(3.5, "Trend Depth", step=0.1)
useHA      = input.bool(true, "Use Heikin Ashi Smoothing")
offsetMult = input.float(0.6, "Label Offset", step=0.1)

// --- NEW Noise Reduction Inputs ---
filterNoise = input.bool(false, "Enable Momentum Filter", tooltip="Requires a small trend confirmation before flipping.")
emaLength   = input.int(50, "Filter EMA Length", minval=1)

// --- Calculations ---
haClose = (open + high + low + close) / 4
haOpen  = 0.0
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh  = math.max(high, math.max(haOpen, haClose))
haLow   = math.min(low, math.min(haOpen, haClose))

price_close = useHA ? haClose : close
price_high  = useHA ? haHigh : high
price_low   = useHA ? haLow : low

// Filter EMA for trend confirmation
filterEma = ta.ema(close, emaLength)

atrValue = ta.atr(atrPeriod)
atr = atrValue * multiplier

var float trailStop = na
var bool  isBullish = true

// Potential levels
float longStop  = price_close - atr
float shortStop = price_close + atr

// Staircase Logic
if not (trailStop[1] != trailStop[1])
    longStop  := (price_close[1] > trailStop[1]) ? math.max(longStop, trailStop[1]) : longStop
    shortStop := (price_close[1] < trailStop[1]) ? math.min(shortStop, trailStop[1]) : shortStop

// Trend Switching Logic with Noise Filter
bool prevIsBullish = bar_index > 0 ? isBullish[1] : true
bool flipTriggered = false

// The Logic: To flip Bullish, price must be > Line AND (if filtered) > EMA.
if isBullish and price_low < trailStop[1]
    if not filterNoise or (close < filterEma)
        isBullish := false
        flipTriggered := true
else if not isBullish and price_high > trailStop[1]
    if not filterNoise or (close > filterEma)
        isBullish := true
        flipTriggered := true
else
    isBullish := prevIsBullish

trailStop := isBullish ? longStop : shortStop
float displayStop = flipTriggered ? na : trailStop

// --- Visuals ---
lineColor = isBullish ? color.new(color.green, 0) : color.new(color.red, 0)
fillColor = isBullish ? color.new(color.green, 85) : color.new(color.red, 85)

mlPlot = plot(displayStop, "MoneyLine", color=lineColor, linewidth=2, style=plot.style_linebr)
pricePlot = plot(close, "Price Reference", display=display.none)
fill(mlPlot, pricePlot, color=fillColor, title="MoneyLine Cloud")

// --- Signals ---
float labelBuffer = atrValue * offsetMult

plotshape(isBullish and flipTriggered ? trailStop - labelBuffer : na, 
     title="Bullish Flip", style=shape.labelup, location=location.absolute, 
     color=color.green, text="Bullish", textcolor=color.white, size=size.small)

plotshape(not isBullish and flipTriggered ? trailStop + labelBuffer : na, 
     title="Bearish Flip", style=shape.labeldown, location=location.absolute, 
     color=color.red, text="Bearish", textcolor=color.white, size=size.small)
````
