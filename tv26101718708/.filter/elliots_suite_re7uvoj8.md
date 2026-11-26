# Elliot's Suite

- url: https://www.tradingview.com/script/rE7UVoj8-Elliot-s-Suite/
- type: indicator
- pine_id: PUB;f2c3f9e1354d461889565a083cec79d0
- version: 2.0

## Description

Elliot's suite. Vwap and other editable indicators.

1. How to Read the Chart
The Market Structure Engine (BOS vs. ChoCh) The script uses fractal geometry to identify swing highs and swing lows. When price closes past these historical lines, a label is printed:
BOS (Break of Structure): Indicates trend continuation. If the market is bullish and breaks a fractal high, it prints a Bullish BOS. This means the trend is healthy and continuing.
ChoCh (Change of Character): Indicates a potential reversal or shift in momentum. If the market is bullish but suddenly breaks below a recent fractal low, it prints a Bearish ChoCh. This is your early warning that the buyers are losing control.
Fractal Boundary Lines: The faint horizontal lines trailing behind the price show you exactly where the previous structural highs and lows are located.
The Algorithmic Levels
Session VWAP: The volume-weighted average price for the current day. Price above = institutional bullish bias. Price below = institutional bearish bias.
Yesterday's VWAP Close: This is a massive hidden liquidity level. Algorithms frequently target the previous day's final VWAP value as a "magnet" for mean-reversion trades.
Daily Open: The absolute baseline for the session. Crossing the daily open often triggers intraday momentum shifts.
Moving Averages (50 & 200 EMA)
Your classic macro trend filters. When the 50 EMA is above the 200 EMA, you are in a macro uptrend.

2. How to Optimize the Settings
Open the indicator settings (the gear icon on your chart). You will see distinct, collapsible groups.
Tuning the Market Structure Sensitivity The most critical settings in the script are the Fractal Left/Right Bars Lookback. This controls how sensitive the ChoCh and BOS labels are.
For Scalping (1m - 5m charts): Lower the lookback values to 2 or 3. This makes the script highly sensitive to micro-structure shifts, catching early entries.
For Swing / Intraday Trend (15m - 1H charts): Keep the values at the default 5, or raise them to 8 or 10. This filters out market noise and only flags major, significant structural breaks.
Decluttering the UI If the chart feels too busy during a volatile session (like the US Open), you don't need to delete the indicator. Just use the master toggles:
Uncheck Enable EMAs if you are trading pure price action.
Uncheck Enable Market Structure if you just want to trade mean-reversion off the VWAP bands and Daily Open.

3. Suggested Trading Workflow
Define the Bias: Look at the EMAs and current Session VWAP. Are you above or below them? Establish whether you are looking for longs or shorts.
Wait for the Setup: Let price approach a high-value level (like the Daily Open, VWAP, or Yesterday's VWAP Close).
Look for the Trigger: Do not enter blindly at a level. Wait for a ChoCh label to print in your intended direction. For example, if price taps Yesterday's VWAP Close and then prints a Bullish ChoCh, you have structural confirmation that buyers are stepping in at that algorithmic level.
Manage the Trade: Use the BOS labels to confirm you are still on the right side of the trade, and trail your stop losses behind the newly formed fractal boundary lines.

## Source Code

````pine
//@version=6
indicator("Eliot's Suite", shorttitle="E Suite v1", overlay=true)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================

// --- Group: Market Structure Engine ---
showMS       = input.bool(true, "Enable Market Structure", group="Market Structure Engine")
leftLen      = input.int(5, "Fractal Left Bars Lookback", minval=1, group="Market Structure Engine")
rightLen     = input.int(5, "Fractal Right Bars Lookback", minval=1, group="Market Structure Engine")
bullColor    = input.color(color.green, "Bullish (BOS/ChoCh) Color", group="Market Structure Engine")
bearColor    = input.color(color.red, "Bearish (BOS/ChoCh) Color", group="Market Structure Engine")
// Optimized size input to use built-in size strings directly
lblSize      = input.string(size.small, "Label Text Size", options=[size.tiny, size.small, size.normal, size.large], group="Market Structure Engine") 

// --- Group: Moving Averages ---
showEMAs     = input.bool(true, "Enable EMAs", group="Moving Averages Engine")
ema1Len      = input.int(50, "EMA 1 Length", minval=1, group="Moving Averages Engine")
ema1Color    = input.color(color.blue, "EMA 1 Color", group="Moving Averages Engine")
ema1Width    = input.int(2, "EMA 1 Width", minval=1, maxval=5, group="Moving Averages Engine")

ema2Len      = input.int(200, "EMA 2 Length", minval=1, group="Moving Averages Engine")
ema2Color    = input.color(color.orange, "EMA 2 Color", group="Moving Averages Engine")
ema2Width    = input.int(2, "EMA 2 Width", minval=1, maxval=5, group="Moving Averages Engine")

// --- Group: Session VWAP ---
showVWAP     = input.bool(true, "Enable Session VWAP", group="Session VWAP")
vwapColor    = input.color(color.rgb(180, 140, 20), "VWAP Color", group="Session VWAP")
vwapWidth    = input.int(2, "VWAP Width", minval=1, maxval=5, group="Session VWAP")

// --- Group: High-Value Levels ---
showDailyOp  = input.bool(true, "Enable Daily Open Line", group="High-Value Intraday Levels")
doColor      = input.color(color.teal, "Daily Open Color", group="High-Value Intraday Levels")
doWidth      = input.int(1, "Daily Open Width", minval=1, maxval=5, group="High-Value Intraday Levels")

showVwapCls  = input.bool(true, "Enable Yesterday VWAP Close", group="High-Value Intraday Levels")
vcColor      = input.color(color.maroon, "VWAP Close Color", group="High-Value Intraday Levels")
vcWidth      = input.int(1, "VWAP Close Width", minval=1, maxval=5, group="High-Value Intraday Levels")


// ==========================================
// 2. QUANT MATHEMATICS & LOGIC
// ==========================================
// Compute EMAs
ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)

// Compute VWAP
myVwap = ta.vwap(close)

// Extract Intraday Variables
newDay = ta.change(time("D")) != 0
var float dailyOpen = na
var float prevVwapClose = na
var float lastVwapOfPrice = na

if (not na(myVwap))
    lastVwapOfPrice := myVwap

if newDay
    dailyOpen := open
    prevVwapClose := lastVwapOfPrice[1]

// --- Market Structure Core ---
var float hiFractal = na
var float loFractal = na
var int lastDir = 0 

pHi = ta.pivothigh(high, leftLen, rightLen)
pLo = ta.pivotlow(low, leftLen, rightLen)

if not na(pHi)
    hiFractal := pHi
if not na(pLo)
    loFractal := pLo

bool bullBreak = false
bool bearBreak = false

if showMS and not na(hiFractal) and ta.crossover(close, hiFractal)
    bullBreak := true
    hiFractal := na 

if showMS and not na(loFractal) and ta.crossunder(close, loFractal)
    bearBreak := true
    loFractal := na 

string structuralLabel = ""
if bullBreak
    structuralLabel := (lastDir == -1 or lastDir == 0) ? "ChoCh" : "BOS"
    lastDir := 1
if bearBreak
    structuralLabel := (lastDir == 1 or lastDir == 0) ? "ChoCh" : "BOS"
    lastDir := -1

// ==========================================
// 3. RENDERING PIPELINE
// ==========================================
// Trend Plots
plot(showEMAs ? ema1 : na, color=ema1Color, title="EMA 1 Line", linewidth=ema1Width)
plot(showEMAs ? ema2 : na, color=ema2Color, title="EMA 2 Line", linewidth=ema2Width)
plot(showVWAP ? myVwap : na, color=vwapColor, title="Anchor VWAP", linewidth=vwapWidth)

// Key Levels Plots (Styles hardcoded to linebr to satisfy compiler requirements)
plot(showDailyOp and not newDay ? dailyOpen : na, color=doColor, title="Daily Open Plot", style=plot.style_linebr, linewidth=doWidth)
plot(showVwapCls and not newDay ? prevVwapClose : na, color=vcColor, title="Yest VWAP Close Plot", style=plot.style_linebr, linewidth=vcWidth)

// Historical Structure Lines (Offset applied for visual synchronization)
plot(showMS ? hiFractal : na, color=color.new(bearColor, 40), style=plot.style_linebr, offset=-rightLen, title="Fractal High Boundary")
plot(showMS ? loFractal : na, color=color.new(bullColor, 40), style=plot.style_linebr, offset=-rightLen, title="Fractal Low Boundary")

// Instant Dynamic Label Dispatcher (No repainting artifacts)
if bullBreak
    label.new(bar_index, low, text=structuralLabel, color=bullColor, textcolor=color.white, style=label.style_label_up, size=lblSize)
if bearBreak
    label.new(bar_index, high, text=structuralLabel, color=bearColor, textcolor=color.white, style=label.style_label_down, size=lblSize)
````
