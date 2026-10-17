# Alpha Forge Accumulation Lite

- url: https://www.tradingview.com/script/9UHtho1A-Alpha-Forge-Accumulation-Lite/
- type: indicator
- pine_id: PUB;31430f0072484d7c850e50b01285a151
- version: 1.0

## Description

Alpha Forge Accumulation Lite is an open-source overlay designed to visualize possible long-term accumulation conditions on higher-timeframe charts.

The script is not built for intraday trading, exact bottom detection, or short-term entries. Instead, it provides a visual framework for studying when an asset is trading below its longer-term trend context while additional correction and stabilization conditions are present.

Core Idea

The script asks a simple chart-analysis question:

Is this asset showing conditions that may be associated with a long-term accumulation phase?

To answer that, the script combines several rule-based inputs, including:

Long-term EMA distance
Drawdown depth
Momentum exhaustion
Volatility behavior
Early stabilization conditions

When enough of these conditions are present, the script marks an Accumulation Zone.

What It Shows

Alpha Forge Accumulation Lite can display:

Potential accumulation zones
Gold candle tinting during active zones
A long-term trend EMA
An accumulation score
Simple visual chart context for Daily and Weekly charts

How To Use

This script is designed for higher-timeframe chart review.

It may be useful for users who want to study:

Assets after large pullbacks
Long-term trend discount conditions
Possible cycle-style accumulation areas
Watchlist candidates for further research
Daily and Weekly chart structure

An Accumulation Zone does not mean price has bottomed.

It does not mean price cannot continue lower.

It only means the script’s programmed conditions for a possible accumulation environment are present on the selected chart and timeframe.

Best Timeframes

The script is primarily intended for:

Daily charts
Weekly charts

Lower timeframes may produce less meaningful results because the logic is based on broader market structure and longer-term conditions.

Possible Markets

The script can be applied to different asset classes, including:

Stocks
Crypto
Metals
Macro-related assets
Indices

Users should test and interpret the script differently depending on the market being reviewed.

Lite Version Notes

This is a simplified public version of a broader accumulation framework.

It is intended to provide clean visual context without adding excessive chart complexity.

Important Notes

This script is open source.

It is for educational chart analysis and research.

It does not provide financial advice.

It does not identify guaranteed buy zones.

It does not predict exact tops or bottoms.

It does not guarantee future results.

All zones, scores, candle colors, and visual states are based only on the script’s programmed conditions and should be interpreted as informational chart context.

## Source Code

````pine
//@version=6
indicator("Alpha Forge Accumulation Lite", shorttitle="AF Accumulation Lite", overlay=true, max_labels_count=100)

//====================================================
// INPUTS
//====================================================
showDashboard     = input.bool(true, "Show Dashboard")
showCandleTint    = input.bool(true, "Show Gold Candle Tint")
showBackground    = input.bool(true, "Show Background Zone")
showLiveTag       = input.bool(true, "Show Live State Tag")
showTrendLine     = input.bool(true, "Show Long Trend EMA")
lineMode          = input.string("Soft", "Trend Line Display", options=["Soft", "Normal", "Off"])

dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
dashboardSize     = input.string("Small", "Dashboard Size", options=["Small", "Normal", "Large"])

tagOffsetATR      = input.float(0.15, "Live Tag Offset ATR", minval=0.0, maxval=2.0, step=0.05)

trendLen          = input.int(200, "Long Trend EMA Length", minval=50)
drawdownLookback  = input.int(250, "Drawdown Lookback", minval=50)
rsiLen            = input.int(21, "RSI Length", minval=5)
atrLen            = input.int(14, "ATR Length", minval=5)
atrBaseLen        = input.int(50, "ATR Baseline Length", minval=10)
baseLen           = input.int(40, "Base Formation Lookback", minval=10)
baseTightLen      = input.int(20, "Base Tightness Lookback", minval=10)

//====================================================
// COLORS
//====================================================
goldZone   = color.rgb(214, 176, 72)
goldLine   = color.rgb(181, 145, 56)
panelDark  = color.rgb(34, 37, 46)
panelMid   = color.rgb(49, 54, 67)
panelSoft  = color.rgb(63, 69, 83)

bgZone     = color.new(goldZone, 94)

cellBg     = color.new(panelDark, 8)
headerBg   = color.new(color.black, 0)

//====================================================
// HELPERS
//====================================================
clampf(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

dashTextSize = dashboardSize == "Small" ? size.small : dashboardSize == "Large" ? size.large : size.normal

f_state_bg(string txt) =>
    txt == "Accumulation Zone" ? color.new(goldZone, 68) : color.new(panelSoft, 22)

//====================================================
// CORE CALCULATIONS
//====================================================
emaLong = ta.ema(close, trendLen)

trendDiscountPct = emaLong != 0 ? ((close - emaLong) / emaLong) * 100.0 : 0.0
trendDiscountAbs = math.max(-trendDiscountPct, 0.0)

rollingHigh = ta.highest(close, drawdownLookback)
drawdownPct = rollingHigh != 0 ? ((close - rollingHigh) / rollingHigh) * 100.0 : 0.0
drawdownAbs = math.max(-drawdownPct, 0.0)

rsiVal = ta.rsi(close, rsiLen)

atrVal = ta.atr(atrLen)
atrPct = close != 0 ? (atrVal / close) * 100.0 : 0.0
atrBase = ta.sma(atrPct, atrBaseLen)
atrRatio = atrPct / math.max(atrBase, 0.0001)

//====================================================
// BASE STABILIZATION CALCS
//====================================================
baseHigh = ta.highest(close, baseLen)
baseLow = ta.lowest(close, baseLen)
baseRangePct = baseLow != 0 ? ((baseHigh - baseLow) / baseLow) * 100.0 : 0.0

tightHigh = ta.highest(close, baseTightLen)
tightLow = ta.lowest(close, baseTightLen)
tightRangePct = tightLow != 0 ? ((tightHigh - tightLow) / tightLow) * 100.0 : 0.0

nearLowsPct = baseLow != 0 ? ((close - baseLow) / math.max(baseLow, syminfo.mintick)) * 100.0 : 0.0
baseVolatilityCompression = atrRatio < 1.0
noFreshBreakdown = close >= ta.lowest(close[1], math.min(baseLen, 20))
stabilizingRsi = rsiVal >= 35 and rsiVal <= 55

//====================================================
// SIMPLE SCORE MODEL
//====================================================
trendDiscountScore = trendDiscountAbs < 5.0 ? clampf(trendDiscountAbs * 1.0, 0.0, 5.0) : trendDiscountAbs < 15.0 ? clampf(5.0 + (trendDiscountAbs - 5.0) * 0.8, 0.0, 13.0) : trendDiscountAbs < 30.0 ? clampf(13.0 + (trendDiscountAbs - 15.0) * (8.0 / 15.0), 0.0, 21.0) : clampf(21.0 + (trendDiscountAbs - 30.0) * 0.2, 0.0, 25.0)

drawdownScore = drawdownAbs < 15.0 ? 0.0 : drawdownAbs < 30.0 ? clampf(4.0 + (drawdownAbs - 15.0) * (6.0 / 15.0), 0.0, 10.0) : drawdownAbs < 50.0 ? clampf(10.0 + (drawdownAbs - 30.0) * (8.0 / 20.0), 0.0, 18.0) : clampf(18.0 + (drawdownAbs - 50.0) * (7.0 / 20.0), 0.0, 25.0)

momentumScore = rsiVal > 50.0 ? 0.0 : rsiVal > 40.0 ? clampf((50.0 - rsiVal) * 0.4, 0.0, 4.0) : rsiVal > 30.0 ? clampf(4.0 + (40.0 - rsiVal) * 0.6, 0.0, 10.0) : clampf(10.0 + (30.0 - rsiVal) * 0.5, 0.0, 15.0)

rawVolScore = atrRatio < 1.0 ? 0.0 : atrRatio < 1.3 ? clampf((atrRatio - 1.0) * (6.0 / 0.3), 0.0, 6.0) : atrRatio < 1.8 ? clampf(6.0 + (atrRatio - 1.3) * (6.0 / 0.5), 0.0, 12.0) : clampf(12.0 + (atrRatio - 1.8) * 3.0, 0.0, 15.0)
volatilityScore = (trendDiscountAbs > 8.0 or drawdownAbs > 20.0) ? rawVolScore : rawVolScore * 0.35

baseTightnessPts = tightRangePct <= 8.0 ? 8.0 : tightRangePct <= 15.0 ? clampf(8.0 - (tightRangePct - 8.0) * 0.7, 0.0, 8.0) : 0.0
baseWideRangePenalty = baseRangePct <= 20.0 ? 4.0 : baseRangePct <= 35.0 ? clampf(4.0 - (baseRangePct - 20.0) * 0.25, 0.0, 4.0) : 0.0
baseLowLocationPts = drawdownAbs > 25.0 and nearLowsPct <= 15.0 ? 4.0 : drawdownAbs > 25.0 and nearLowsPct <= 30.0 ? 2.0 : 0.0
baseVolCompressionPts = baseVolatilityCompression ? 2.0 : 0.0
baseNoBreakdownPts = noFreshBreakdown ? 1.0 : 0.0
baseRsiStabilizePts = stabilizingRsi ? 1.0 : 0.0
baseFormationScoreRaw = baseTightnessPts + baseWideRangePenalty + baseLowLocationPts + baseVolCompressionPts + baseNoBreakdownPts + baseRsiStabilizePts
baseFormationScore = drawdownAbs > 20.0 and trendDiscountAbs > 8.0 ? clampf(baseFormationScoreRaw, 0.0, 20.0) : 0.0

accumulationScoreRaw = trendDiscountScore + drawdownScore + momentumScore + volatilityScore + baseFormationScore
accumulationScore = int(math.round(clampf(accumulationScoreRaw, 0.0, 100.0)))

//====================================================
// LITE STATE
//====================================================
string zoneState = accumulationScore >= 40 ? "Accumulation Zone" : "No Zone"

//====================================================
// VISUALS
//====================================================
trendLineColor = lineMode == "Off" ? color.new(goldLine, 100) : lineMode == "Soft" ? color.new(goldLine, 58) : color.new(goldLine, 8)

plot(showTrendLine and lineMode != "Off" ? emaLong : na, "Long Trend EMA", color=trendLineColor, linewidth=2)

bgcolor(showBackground and zoneState == "Accumulation Zone" ? bgZone : na)

barTint = zoneState == "Accumulation Zone" ? color.new(goldZone, 14) : na
barcolor(showCandleTint ? barTint : na)

//====================================================
// LIVE TAG
//====================================================
var label liveTag = na

if barstate.islast and showLiveTag
    label.delete(liveTag)
    tagText = zoneState + " • " + str.tostring(accumulationScore) + "/100"
    liveTag := label.new(bar_index, high, tagText, yloc=yloc.abovebar, style=label.style_label_down, color=zoneState == "No Zone" ? color.new(panelSoft, 10) : color.new(goldZone, 6), textcolor=zoneState == "No Zone" ? color.white : color.black, size=size.small)
    label.set_y(liveTag, high + ta.atr(14) * tagOffsetATR)

if barstate.islast and not showLiveTag
    label.delete(liveTag)

//====================================================
// ALERTS
//====================================================
enteredZone = zoneState == "Accumulation Zone" and zoneState[1] != "Accumulation Zone"
exitedZone = zoneState == "No Zone" and zoneState[1] != "No Zone"

alertcondition(enteredZone, "AFAL Entered Accumulation Zone", "Alpha Forge Accumulation Lite: Entered accumulation zone on {{ticker}} {{interval}}")
alertcondition(exitedZone, "AFAL Exited Accumulation Zone", "Alpha Forge Accumulation Lite: Exited accumulation zone on {{ticker}} {{interval}}")

//====================================================
// DASHBOARDS
//====================================================
var table dashTR = table.new(position.top_right, 2, 4, frame_color=color.new(color.black, 0), border_width=1)
var table dashTL = table.new(position.top_left, 2, 4, frame_color=color.new(color.black, 0), border_width=1)
var table dashBR = table.new(position.bottom_right, 2, 4, frame_color=color.new(color.black, 0), border_width=1)
var table dashBL = table.new(position.bottom_left, 2, 4, frame_color=color.new(color.black, 0), border_width=1)

f_clear_table(table t) =>
    for c = 0 to 1
        for r = 0 to 3
            table.cell(t, c, r, "", text_color=color.new(color.white, 100), bgcolor=color.new(color.black, 100), text_size=dashTextSize)

f_put(table t, int r, string l, string v, color vbg, color vtxt) =>
    table.cell(t, 0, r, l, text_color=color.white, bgcolor=cellBg, text_size=dashTextSize)
    table.cell(t, 1, r, v, text_color=vtxt, bgcolor=vbg, text_size=dashTextSize)

f_header(table t, string rightTxt) =>
    table.cell(t, 0, 0, "ALPHA FORGE", text_color=color.white, bgcolor=headerBg, text_size=dashTextSize)
    table.cell(t, 1, 0, rightTxt, text_color=color.white, bgcolor=headerBg, text_size=dashTextSize)

if barstate.islast
    f_clear_table(dashTR)
    f_clear_table(dashTL)
    f_clear_table(dashBR)
    f_clear_table(dashBL)

    activeDash = dashboardPosition == "Top Right" ? dashTR : dashboardPosition == "Top Left" ? dashTL : dashboardPosition == "Bottom Right" ? dashBR : dashBL

    if showDashboard
        f_header(activeDash, "ACCUM LITE")

        row = 1
        f_put(activeDash, row, "State", zoneState, f_state_bg(zoneState), color.white)
        row := row + 1

        f_put(activeDash, row, "Score", str.tostring(accumulationScore) + "/100", color.new(panelMid, 10), color.white)
        row := row + 1

        timeframeText = timeframe.isdaily ? "Daily" : timeframe.isweekly ? "Weekly" : "Best on D/W"
        timeframeBg = timeframe.isdaily or timeframe.isweekly ? color.new(color.green, 78) : color.new(color.orange, 74)
        f_put(activeDash, row, "Mode", timeframeText, timeframeBg, color.white)

//====================================================
// HIDDEN DATA WINDOW PLOTS
//====================================================
plot(accumulationScore, "Accumulation Score", color=color.new(goldZone, 100), display=display.none)
````
