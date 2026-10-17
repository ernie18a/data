# Trend Flip Risk Map

- url: https://www.tradingview.com/script/SkGtdZEh-Trend-Flip-Risk-Map/
- type: indicator
- pine_id: PUB;da5f36f7ca4c41ecae1ee5d32f1e5690
- version: 1.0

## Description

Trend Flip Risk Map - TradingView Publishing Description

[b]Short description:[/b]
Trend Flip Risk Map is a Pine v6 regime-transition study that turns selected compression-release flips into structured risk maps. It combines EMA-spread compression, directional pressure, release scoring, structure-based invalidation, retest tracking, and staged R-multiple targets.

[b]Full description:[/b]
Trend Flip Risk Map is built for studying one specific market behaviour: a compressed trend regime beginning to release into a new directional phase. It is not intended to mark every moving-average crossover. The crossover is only the initial trigger. A signal is accepted only when the surrounding compression, candle participation, spread slope, and directional pressure conditions support the idea that the market may be leaving a low-separation regime.

The script’s purpose is to turn a possible trend flip into a complete review map. Instead of showing only a BUY or SELL label, it draws the active transition zone, the signal reference, a structure-aware stop, an early flip-failure line, three R-multiple target references, and a short retest window. This helps users review the full shape of the setup: where the regime changed, where the idea begins to weaken, where it is invalidated, and whether the first pullback into the transition zone holds.

[b]Core idea:[/b]
A plain EMA crossover can occur in strong expansion, during compression, or inside meaningless chop. Trend Flip Risk Map tries to separate those situations by measuring the relationship between EMA separation and volatility. The script normalises the distance between the fast EMA and slow EMA by ATR. When that normalised spread remains below the selected threshold, the market is treated as compressed. A later flip is more meaningful when it appears after that compression and begins to expand with directional pressure.

[b]How the regime engine works:[/b]
1. The fast EMA and slow EMA define the baseline regime.
2. The absolute distance between those EMAs is divided by ATR to create a volatility-normalised spread reading.
3. If the spread is below the compression threshold, the script treats the market as being in a compressed phase.
4. The script counts how many bars the market has spent in that compressed phase.
5. A flip can qualify only when the fast EMA crosses the slow EMA and the selected compression-release conditions are satisfied.

[b]Directional pressure filter:[/b]
The script uses a pressure stack to avoid accepting weak flips by default. For bullish releases, price should be above the fast EMA, the fast EMA should be above the slow EMA, the EMA spread slope should be positive, and the signal candle should close in the upper part of its range. For bearish releases, the same checks are inverted. This makes the marker more selective than a basic crossover label.

[b]Candle participation filter:[/b]
The signal candle body is measured relative to ATR. This prevents very small candles from being treated the same as larger transition candles. Users can raise or lower the minimum body-to-ATR input depending on whether they want fewer, stronger releases or more exploratory signals.

[b]Release score:[/b]
Each accepted flip receives a release score. The score is a relative context score, not a prediction. It combines:
- How long the market spent in compression
- How much the EMA spread is expanding relative to its baseline
- How large the signal candle body is compared with ATR
- How strongly the EMA spread is sloping in the new direction

The score is useful for comparing different releases on the same symbol and timeframe under the same settings. It should not be read as a win probability or performance forecast.

[b]Structure-aware risk map:[/b]
When a qualifying BUY or SELL release appears, the script creates a risk map from the signal candle. The Entry reference is the signal candle close. The stop can be based on recent swing structure with an ATR buffer. For bullish releases, the structure stop references recent lows. For bearish releases, it references recent highs. If that structure stop would not make sense relative to the entry, the script falls back to an ATR-based stop.

The Entry-to-Stop distance defines one unit of risk. TP1, TP2, and TP3 are then projected as configurable R-multiples from that distance. This keeps the ladder tied to the actual invalidation distance rather than drawing arbitrary target lines.

[b]Flip-failure line:[/b]
The script also draws a separate FLIP FAIL line around the EMA midline with an ATR band. This is not the same as the full stop. It is an earlier regime-quality warning level. The idea is that a new trend regime can start to lose quality before the full structure stop is reached. This line gives users a visual reference for where the transition thesis begins to weaken.

[b]Retest zone:[/b]
After a qualifying release, the script creates a temporary retest zone around the EMA midline. If price returns to that zone and holds in the direction of the active flip within the selected watch window, a RETEST HELD label is printed. This helps users study whether a release continues immediately, fails quickly, or first retests the transition area before continuation.

[b]Dashboard:[/b]
The dashboard summarises the current state of the model. It shows whether there is an active bull or bear flip, whether the market is currently in compression or expansion, the current EMA spread relative to ATR, the current candle body relative to ATR, and the latest release score. The dashboard is designed to make the script easier to understand without needing to inspect every input or calculation manually.

[b]Visual elements:[/b]
- Fast EMA: short-term regime reference
- Slow EMA: longer regime reference
- EMA midline: centre of the transition zone
- Compression box: recent low-separation area before release
- BUY / SELL release label: accepted directional transition after filters
- Release score: relative strength of the accepted transition
- Entry line: signal candle close
- STRUCT SL line: structure-aware invalidation reference
- FLIP FAIL line: earlier regime-quality warning level
- TP1 / TP2 / TP3 lines: R-multiple target references
- Retest zone: temporary zone used to study the first pullback after release
- RETEST HELD label: retest zone held during the watch window
- Dashboard: live regime and filter context

[b]How to use it:[/b]
1. Add the indicator to a clean chart.
2. Use a liquid market and a timeframe where trend transitions are readable.
3. Look for releases that occur after visible compression, not random sideways crossover noise.
4. Review the release score in relation to other signals on the same chart.
5. Check whether the Entry, FLIP FAIL, STRUCT SL, and TP levels make sense against nearby structure.
6. Watch whether price retests the transition zone and holds during the retest window.
7. Adjust the compression threshold, required compression bars, EMA lengths, structure lookback, stop buffer, and R-multiple targets for the market being studied.
8. Forward-test settings before using them in any decision process.

[b]Suggested chart setup:[/b]
15-minute and 30-minute charts usually provide cleaner examples because they show compression, release, retest, and continuation without excessive low-timeframe noise. One-hour charts can work well for broader swing review. Very small timeframes may produce more signals but can make the chart harder to interpret.

[b]Important limitations:[/b]
Trend Flip Risk Map does not forecast price movement. It does not know whether a release will continue or fail. It can still produce poor signals during rotational, illiquid, or news-driven conditions. The release score is only a relative study metric under the selected settings. It is not a probability model, performance estimate, or recommendation.

[b]Educational-use notice:[/b]
This script is for educational, research, and chart-planning purposes only. BUY and SELL labels, release scores, Entry levels, Stop Loss levels, flip-failure levels, retest markers, and target levels are visual study references. They are not financial advice, trade recommendations, or guarantees of future performance. Each user is responsible for testing settings on their own symbol, timeframe, and risk model.

## Source Code

````pine
//@version=6
indicator("Trend Flip Risk Map", shorttitle="Trend Flip Risk", overlay=true, max_lines_count=160, max_labels_count=160, max_boxes_count=40)

// Educational regime-transition risk map. Signals and levels are visual study references only.

fastLen = input.int(21, "Fast EMA", minval=2, group="Regime Engine")
slowLen = input.int(55, "Slow EMA", minval=3, group="Regime Engine")
atrLen = input.int(14, "ATR Length", minval=2, group="Regime Engine")
compressionLookback = input.int(34, "Compression Lookback", minval=10, group="Regime Engine")
compressionThreshold = input.float(0.65, "Compression Threshold", minval=0.1, step=0.05, group="Regime Engine")
releaseBars = input.int(8, "Required Compression Bars", minval=1, maxval=50, group="Regime Engine")
slopeLen = input.int(8, "Spread Slope Lookback", minval=2, group="Regime Engine")
confirmClose = input.bool(true, "Confirm On Close", group="Signal Filters")
minBodyAtr = input.float(0.20, "Minimum Flip Candle Body / ATR", minval=0.0, step=0.05, group="Signal Filters")
needRelease = input.bool(true, "Require Compression Release", group="Signal Filters")
needPressure = input.bool(true, "Require Directional Pressure Stack", group="Signal Filters")
useStructureStop = input.bool(true, "Use Structure Stop", group="Risk Map")
swingLookback = input.int(12, "Structure Lookback", minval=2, group="Risk Map")
stopAtrBuffer = input.float(0.35, "Structure Stop ATR Buffer", minval=0.0, step=0.05, group="Risk Map")
fallbackStopAtr = input.float(1.50, "Fallback Stop ATR", minval=0.25, step=0.25, group="Risk Map")
rr1 = input.float(1.0, "TP1 R", minval=0.25, step=0.25, group="Risk Map")
rr2 = input.float(1.75, "TP2 R", minval=0.5, step=0.25, group="Risk Map")
rr3 = input.float(2.75, "TP3 R", minval=0.75, step=0.25, group="Risk Map")
retestWindow = input.int(10, "Retest Watch Bars", minval=2, maxval=40, group="Post-Flip Review")
retestAtrBand = input.float(0.40, "Retest Band ATR Width", minval=0.05, step=0.05, group="Post-Flip Review")
levelBars = input.int(90, "Risk Line Length", minval=15, maxval=300, group="Display")
showDashboard = input.bool(true, "Show Regime Dashboard", group="Display")
showBoxes = input.bool(true, "Show Compression / Retest Zones", group="Display")
bullColor = input.color(color.rgb(38, 166, 154), "Bull Colour", group="Display")
bearColor = input.color(color.rgb(239, 83, 80), "Bear Colour", group="Display")
neutralColor = input.color(color.rgb(120, 144, 156), "Neutral Colour", group="Display")
entryColor = input.color(color.rgb(255, 167, 38), "Entry Colour", group="Display")
tpColor = input.color(color.rgb(102, 187, 106), "Target Colour", group="Display")
slColor = input.color(color.rgb(239, 83, 80), "Stop Colour", group="Display")

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
mid = (fast + slow) * 0.5
atr = ta.atr(atrLen)
atrSafe = math.max(atr, syminfo.mintick)
spread = fast - slow
spreadAbs = math.abs(spread)
spreadNorm = spreadAbs / atrSafe
spreadBase = ta.sma(spreadNorm, compressionLookback)
isCompressed = spreadNorm < compressionThreshold
compressionCount = ta.barssince(not isCompressed)
compressionReady = nz(compressionCount, 0) >= releaseBars
releaseNow = compressionReady[1] and not isCompressed
spreadSlope = ta.linreg(spread, slopeLen, 0) - ta.linreg(spread, slopeLen, 1)
bodyAtr = math.abs(close - open) / atrSafe
closePosition = (close - low) / math.max(high - low, syminfo.mintick)
bullPressure = close > fast and fast > slow and spreadSlope > 0 and closePosition > 0.55
bearPressure = close < fast and fast < slow and spreadSlope < 0 and closePosition < 0.45
rawBuy = ta.crossover(fast, slow)
rawSell = ta.crossunder(fast, slow)
confirmed = not confirmClose or barstate.isconfirmed
buySignal = rawBuy and confirmed and bodyAtr >= minBodyAtr and (not needRelease or releaseNow or compressionReady[1]) and (not needPressure or bullPressure)
sellSignal = rawSell and confirmed and bodyAtr >= minBodyAtr and (not needRelease or releaseNow or compressionReady[1]) and (not needPressure or bearPressure)

compressionScore = math.min(35.0, nz(compressionCount, 0) / math.max(releaseBars, 1) * 35.0)
spreadScore = math.min(25.0, spreadNorm / math.max(spreadBase, 0.1) * 18.0)
bodyScore = math.min(20.0, bodyAtr * 45.0)
slopeScore = math.min(20.0, math.abs(spreadSlope) / atrSafe * 250.0)
flipScore = math.round(compressionScore + spreadScore + bodyScore + slopeScore)

plot(fast, "Fast EMA", color=fast > slow ? bullColor : bearColor, linewidth=2)
plot(slow, "Slow EMA", color=color.new(color.white, 35), linewidth=2)
plot(mid, "EMA Midline", color=color.new(neutralColor, 55), linewidth=1)
barcolor(fast > slow ? color.new(bullColor, 82) : fast < slow ? color.new(bearColor, 82) : na)

var line entryLine = na
var line stopLine = na
var line failLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label signalLabel = na
var label entryLabel = na
var label stopLabel = na
var label failLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var box retestBox = na
var int activeDir = 0
var int activeBar = na
var float activeEntry = na
var float activeMid = na
var bool retestTagged = false

if showBoxes and releaseNow
    box.new(bar_index - nz(compressionCount[1], releaseBars), high + atrSafe * 0.25, bar_index, low - atrSafe * 0.25, bgcolor=color.new(neutralColor, 90), border_color=color.new(neutralColor, 65))

if buySignal or sellSignal
    if not na(entryLine)
        line.delete(entryLine)
        line.delete(stopLine)
        line.delete(failLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(signalLabel)
        label.delete(entryLabel)
        label.delete(stopLabel)
        label.delete(failLabel)
        label.delete(tp1Label)
        label.delete(tp2Label)
        label.delete(tp3Label)
        box.delete(retestBox)

    dir = buySignal ? 1 : -1
    entry = close
    structureStop = dir == 1 ? ta.lowest(low, swingLookback) - atrSafe * stopAtrBuffer : ta.highest(high, swingLookback) + atrSafe * stopAtrBuffer
    fallbackStop = entry - dir * atrSafe * fallbackStopAtr
    stop = useStructureStop ? structureStop : fallbackStop
    stop := dir == 1 and stop >= entry ? fallbackStop : dir == -1 and stop <= entry ? fallbackStop : stop
    risk = math.max(math.abs(entry - stop), syminfo.mintick)
    tp1 = entry + dir * risk * rr1
    tp2 = entry + dir * risk * rr2
    tp3 = entry + dir * risk * rr3
    failure = dir == 1 ? mid - atrSafe * retestAtrBand : mid + atrSafe * retestAtrBand
    endBar = bar_index + levelBars
    sigColor = dir == 1 ? bullColor : bearColor
    sigText = dir == 1 ? "BUY\nRelease " : "SELL\nRelease "
    signalLabel := label.new(bar_index, dir == 1 ? low : high, sigText + str.tostring(flipScore), style=dir == 1 ? label.style_label_up : label.style_label_down, color=sigColor, textcolor=color.white)
    entryLine := line.new(bar_index, entry, endBar, entry, color=entryColor, width=2)
    stopLine := line.new(bar_index, stop, endBar, stop, color=slColor, width=2)
    failLine := line.new(bar_index, failure, endBar, failure, color=color.new(slColor, 25), style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, tp1, endBar, tp1, color=tpColor, width=1)
    tp2Line := line.new(bar_index, tp2, endBar, tp2, color=tpColor, width=1)
    tp3Line := line.new(bar_index, tp3, endBar, tp3, color=tpColor, width=2)
    entryLabel := label.new(endBar, entry, "ENTRY " + str.tostring(entry, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white)
    stopLabel := label.new(endBar, stop, "STRUCT SL " + str.tostring(stop, format.mintick), style=label.style_label_left, color=slColor, textcolor=color.white)
    failLabel := label.new(endBar, failure, "FLIP FAIL " + str.tostring(failure, format.mintick), style=label.style_label_left, color=color.new(slColor, 25), textcolor=color.white)
    tp1Label := label.new(endBar, tp1, "TP1 " + str.tostring(tp1, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)
    tp2Label := label.new(endBar, tp2, "TP2 " + str.tostring(tp2, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)
    tp3Label := label.new(endBar, tp3, "TP3 " + str.tostring(tp3, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)
    if showBoxes
        boxTop = mid + atrSafe * retestAtrBand
        boxBottom = mid - atrSafe * retestAtrBand
        retestBox := box.new(bar_index, boxTop, bar_index + retestWindow, boxBottom, bgcolor=color.new(sigColor, 90), border_color=color.new(sigColor, 55))
    activeDir := dir
    activeBar := bar_index
    activeEntry := entry
    activeMid := mid
    retestTagged := false

barsFromFlip = not na(activeBar) ? bar_index - activeBar : na
inRetestWindow = not na(barsFromFlip) and barsFromFlip > 0 and barsFromFlip <= retestWindow
bullRetestHold = activeDir == 1 and inRetestWindow and low <= activeMid + atrSafe * retestAtrBand and close > activeMid
bearRetestHold = activeDir == -1 and inRetestWindow and high >= activeMid - atrSafe * retestAtrBand and close < activeMid
if not retestTagged and (bullRetestHold or bearRetestHold)
    label.new(bar_index, activeDir == 1 ? low : high, "RETEST\nHELD", style=activeDir == 1 ? label.style_label_up : label.style_label_down, color=activeDir == 1 ? color.new(bullColor, 10) : color.new(bearColor, 10), textcolor=color.white)
    retestTagged := true

activeState = activeDir == 1 ? "Bull flip" : activeDir == -1 ? "Bear flip" : "No active flip"
filterState = isCompressed ? "Compression" : releaseNow ? "Release" : "Expansion"
var table dash = table.new(position.top_right, 2, 5, border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "State", text_color=color.white, bgcolor=color.new(neutralColor, 25))
    table.cell(dash, 1, 0, activeState, text_color=color.white, bgcolor=activeDir == 1 ? color.new(bullColor, 35) : activeDir == -1 ? color.new(bearColor, 35) : color.new(neutralColor, 35))
    table.cell(dash, 0, 1, "Phase", text_color=color.white, bgcolor=color.new(neutralColor, 55))
    table.cell(dash, 1, 1, filterState, text_color=color.white, bgcolor=color.new(neutralColor, 75))
    table.cell(dash, 0, 2, "Spread/ATR", text_color=color.white, bgcolor=color.new(neutralColor, 55))
    table.cell(dash, 1, 2, str.tostring(spreadNorm, "#.##"), text_color=color.white, bgcolor=color.new(neutralColor, 75))
    table.cell(dash, 0, 3, "Body/ATR", text_color=color.white, bgcolor=color.new(neutralColor, 55))
    table.cell(dash, 1, 3, str.tostring(bodyAtr, "#.##"), text_color=color.white, bgcolor=color.new(neutralColor, 75))
    table.cell(dash, 0, 4, "Last score", text_color=color.white, bgcolor=color.new(neutralColor, 55))
    table.cell(dash, 1, 4, str.tostring(flipScore), text_color=color.white, bgcolor=color.new(neutralColor, 75))

alertcondition(buySignal, "Trend Flip Risk Map BUY", "Bullish compression-release flip created a structured risk map.")
alertcondition(sellSignal, "Trend Flip Risk Map SELL", "Bearish compression-release flip created a structured risk map.")
alertcondition(bullRetestHold or bearRetestHold, "Trend Flip Risk Map Retest Held", "The active flip retest zone held during the watch window.")
````
