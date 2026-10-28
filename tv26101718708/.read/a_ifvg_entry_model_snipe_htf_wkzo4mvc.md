# A+ IFVG Entry Model - SNIPE + HTF

- url: https://www.tradingview.com/script/wKzO4MVC-A-IFVG-Entry-Model-SNIPE-HTF/
- type: indicator
- pine_id: PUB;08394fa2c948415baf1a70400fbd170d
- version: 1.0

## Description

The A+ IFVG Entry Model – SNIPE + HTF is a rule-based trading indicator designed to identify high-probability intraday and swing opportunities using liquidity concepts, displacement, and imbalance analysis. It operationalizes a structured entry model centered on market behavior commonly associated with institutional order flow.

Core Methodology

The indicator scans for a specific sequence of events:

Liquidity Sweep
Price takes out prior highs or lows, signaling potential stop runs and liquidity collection.
Displacement Move
A strong directional expansion confirms intent, indicating that market participants are committing to a move.
Fair Value Gap (FVG) / Inversion FVG (IFVG)
The presence of an imbalance highlights inefficiencies in price delivery, which often act as continuation zones.
Confirmation
Entries are only validated once price action confirms direction through candle structure, reducing premature signals.
Entry Types

The script distinguishes between two strategic entry profiles:

SNIPE Entries
Designed for short-term execution
Triggered immediately following the core model conditions
Targets nearby liquidity levels for quicker profit-taking
Ideal for lower timeframes and active trade management
HTF Bias Entries (Runner Trades)
Filtered by higher timeframe directional bias using a moving average framework
Intended to capture extended moves (“runners”)
Targets broader liquidity zones using an expanded lookback range
Suitable for holding positions longer with trend alignment
Risk Management

The model incorporates dynamic, liquidity-based risk controls:

Stop Loss Placement
Positioned beyond the most recent sweep or protected structure, with an ATR-based buffer to account for volatility.
Profit Targets
Derived from real liquidity zones (recent highs/lows or extended ranges), rather than arbitrary fixed distances.
Risk-to-Reward Filter
Optional validation ensures trades meet a minimum reward-to-risk threshold before being signaled.
Additional Features
Automated FVG Visualization for identifying imbalance zones directly on the chart
Sweep Markers (SH / SL) to highlight liquidity events
Cooldown Mechanism to prevent signal clustering and overtrading
Customizable Parameters for timeframe adaptability and strategy refinement
Alert Conditions for real-time trade monitoring and automation support
Use Case

This indicator is intended for traders who rely on price action, liquidity theory, and structured execution models. It emphasizes discipline, consistency, and contextual decision-making rather than signal overdependence, making it suitable as both a standalone tool and a confirmation layer within a broader trading framework.

## Source Code

````pine
//@version=5
indicator("PJ Style A+ IFVG Entry Model - SNIPE + HTF", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//====================
// INPUTS
//====================
showFVG        = input.bool(true, "Show FVG")
showSweeps     = input.bool(true, "Show SH / SL")
showEntries    = input.bool(true, "Show Entry Boxes")
showLevels     = input.bool(true, "Show SL / TP")
useRRFilter    = input.bool(true, "Use Minimum RR Filter")

showSnipe      = input.bool(true, "Show SNIPE Entries")
showHTF        = input.bool(true, "Show HTF Runner Entries")
htf_tf         = input.timeframe("60", "HTF Bias Timeframe")

swingLen       = input.int(3, "Liquidity Swing Length", minval=1)
atrLen         = input.int(14, "ATR Length")
dispMult       = input.float(0.8, "Displacement Strength", step=0.1)
setupWindow    = input.int(30, "Setup Window Bars", minval=1)
cooldown       = input.int(20, "Entry Cooldown Bars", minval=1)
liqLookback    = input.int(20, "Liquidity Target Lookback", minval=5)
runnerLookback = input.int(100, "HTF Runner Target Lookback", minval=20)
minRR          = input.float(1.5, "Minimum RR", step=0.25)
stopBufferATR  = input.float(0.15, "Stop Buffer ATR", step=0.05)

//====================
// CORE
//====================
atr = ta.atr(atrLen)

//====================
// HTF BIAS
//====================
htfClose = request.security(syminfo.tickerid, htf_tf, close)
htfEMA   = request.security(syminfo.tickerid, htf_tf, ta.ema(close, 50))

bullHTF = htfClose > htfEMA
bearHTF = htfClose < htfEMA

//====================
// SWINGS / LIQUIDITY
//====================
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

//====================
// SWEEPS
//====================
sweepLow  = not na(lastLow) and low < lastLow and close > lastLow
sweepHigh = not na(lastHigh) and high > lastHigh and close < lastHigh

//====================
// DISPLACEMENT
//====================
bullDisp = close > open and math.abs(close - open) > atr * dispMult
bearDisp = close < open and math.abs(close - open) > atr * dispMult

//====================
// FVG
//====================
bull_fvg = low[1] > high[2]
bear_fvg = high[1] < low[2]

if showFVG and bull_fvg
    box.new(bar_index[2], low[1], bar_index, high[2], bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 50))

if showFVG and bear_fvg
    box.new(bar_index[2], low[2], bar_index, high[1], bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 50))

//====================
// IFVG
//====================
bullIFVG = bull_fvg or close > high[1]
bearIFVG = bear_fvg or close < low[1]

//====================
// MODEL MEMORY
//====================
var int bullSweepBar = na
var int bearSweepBar = na
var int bullDispBar = na
var int bearDispBar = na
var int bullIFVGBar = na
var int bearIFVGBar = na

var float bullSweepLow = na
var float bearSweepHigh = na

if sweepLow
    bullSweepBar := bar_index
    bullSweepLow := low

if sweepHigh
    bearSweepBar := bar_index
    bearSweepHigh := high

if bullDisp
    bullDispBar := bar_index

if bearDisp
    bearDispBar := bar_index

if bullIFVG
    bullIFVGBar := bar_index

if bearIFVG
    bearIFVGBar := bar_index

recentBullSweep = not na(bullSweepBar) and bar_index - bullSweepBar <= setupWindow
recentBearSweep = not na(bearSweepBar) and bar_index - bearSweepBar <= setupWindow

recentBullDisp = not na(bullDispBar) and bar_index - bullDispBar <= setupWindow
recentBearDisp = not na(bearDispBar) and bar_index - bearDispBar <= setupWindow

recentBullIFVG = not na(bullIFVGBar) and bar_index - bullIFVGBar <= setupWindow
recentBearIFVG = not na(bearIFVGBar) and bar_index - bearIFVGBar <= setupWindow

//====================
// SMART STOPS
//====================
var float protectedLow = na
var float protectedHigh = na

if sweepLow
    protectedLow := low

if sweepHigh
    protectedHigh := high

if recentBullSweep and not na(protectedLow)
    protectedLow := math.min(protectedLow, low)

if recentBearSweep and not na(protectedHigh)
    protectedHigh := math.max(protectedHigh, high)

longStop  = not na(protectedLow) ? protectedLow - atr * stopBufferATR : low - atr * stopBufferATR
shortStop = not na(protectedHigh) ? protectedHigh + atr * stopBufferATR : high + atr * stopBufferATR

//====================
// TARGETS
//====================
normalLongTarget  = ta.highest(high, liqLookback)
normalShortTarget = ta.lowest(low, liqLookback)

runnerLongTarget  = ta.highest(high, runnerLookback)
runnerShortTarget = ta.lowest(low, runnerLookback)

//====================
// BASE CONFIRMATION
//====================
longBase  = recentBullSweep and recentBullDisp and recentBullIFVG and close > open and close > high[1]
shortBase = recentBearSweep and recentBearDisp and recentBearIFVG and close < open and close < low[1]

//====================
// ENTRY TYPES
//====================
snipeLong  = longBase
snipeShort = shortBase

htfLong  = longBase and bullHTF
htfShort = shortBase and bearHTF

//====================
// RR FILTERS
//====================
longRisk = close - longStop
shortRisk = shortStop - close

snipeLongReward = normalLongTarget - close
snipeShortReward = close - normalShortTarget

htfLongReward = runnerLongTarget - close
htfShortReward = close - runnerShortTarget

validSnipeLong = longRisk > 0 and snipeLongReward > longRisk * minRR
validSnipeShort = shortRisk > 0 and snipeShortReward > shortRisk * minRR

validHTFLong = longRisk > 0 and htfLongReward > longRisk * minRR
validHTFShort = shortRisk > 0 and htfShortReward > shortRisk * minRR

//====================
// COOLDOWN
//====================
var int lastSnipeLong = na
var int lastSnipeShort = na
var int lastHTFLong = na
var int lastHTFShort = na

canSnipeLong = na(lastSnipeLong) or bar_index - lastSnipeLong > cooldown
canSnipeShort = na(lastSnipeShort) or bar_index - lastSnipeShort > cooldown
canHTFLong = na(lastHTFLong) or bar_index - lastHTFLong > cooldown
canHTFShort = na(lastHTFShort) or bar_index - lastHTFShort > cooldown

finalSnipeLong = showSnipe and snipeLong and canSnipeLong and (not useRRFilter or validSnipeLong)
finalSnipeShort = showSnipe and snipeShort and canSnipeShort and (not useRRFilter or validSnipeShort)

finalHTFLong = showHTF and htfLong and canHTFLong and (not useRRFilter or validHTFLong)
finalHTFShort = showHTF and htfShort and canHTFShort and (not useRRFilter or validHTFShort)

//====================
// ENTRY LABELS + LEVELS
//====================
if showEntries and finalSnipeLong
    label.new(bar_index, low, "SNIPE\nA+\nLONG", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.normal)
    lastSnipeLong := bar_index
    if showLevels
        line.new(bar_index, longStop, bar_index + 20, longStop, color=color.red, width=2)
        line.new(bar_index, normalLongTarget, bar_index + 20, normalLongTarget, color=color.green, width=2)

if showEntries and finalSnipeShort
    label.new(bar_index, high, "SNIPE\nA+\nSHORT", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)
    lastSnipeShort := bar_index
    if showLevels
        line.new(bar_index, shortStop, bar_index + 20, shortStop, color=color.red, width=2)
        line.new(bar_index, normalShortTarget, bar_index + 20, normalShortTarget, color=color.green, width=2)

if showEntries and finalHTFLong
    label.new(bar_index, low - atr * 0.5, "HTF\nA++\nLONG\nRUNNER", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.normal)
    lastHTFLong := bar_index
    if showLevels
        line.new(bar_index, longStop, bar_index + 40, longStop, color=color.red, width=2)
        line.new(bar_index, runnerLongTarget, bar_index + 40, runnerLongTarget, color=color.lime, width=2)

if showEntries and finalHTFShort
    label.new(bar_index, high + atr * 0.5, "HTF\nA++\nSHORT\nRUNNER", style=label.style_label_down, color=color.maroon, textcolor=color.white, size=size.normal)
    lastHTFShort := bar_index
    if showLevels
        line.new(bar_index, shortStop, bar_index + 40, shortStop, color=color.red, width=2)
        line.new(bar_index, runnerShortTarget, bar_index + 40, runnerShortTarget, color=color.lime, width=2)

//====================
// SWEEP MARKERS
//====================
plotshape(showSweeps and sweepLow, title="SL", location=location.belowbar, style=shape.triangleup, color=color.green, size=size.tiny, text="SL")
plotshape(showSweeps and sweepHigh, title="SH", location=location.abovebar, style=shape.triangledown, color=color.red, size=size.tiny, text="SH")

//====================
// ALERTS
//====================
alertcondition(finalSnipeLong, title="SNIPE Long", message="SNIPE A+ LONG")
alertcondition(finalSnipeShort, title="SNIPE Short", message="SNIPE A+ SHORT")
alertcondition(finalHTFLong, title="HTF Runner Long", message="HTF A++ LONG RUNNER")
alertcondition(finalHTFShort, title="HTF Runner Short", message="HTF A++ SHORT RUNNER")
````
