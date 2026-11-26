# OM Trend Stack v4

- url: https://www.tradingview.com/script/n6Qxa7nZ-OM-Trend-Stack-v4/
- type: indicator
- pine_id: PUB;3f3795bd092e43cb953a9bf8dc13bd7d
- version: 3.0

## Description

**OM Trend Stack v4** is a lightweight, horizontal trend alignment tool that gives you an at-a-glance read of market structure across multiple timeframes without cluttering your chart.

The table shows four signals in a compact 2-row layout: Daily 200 EMA position, 4H 200 EMA position, Daily candle structure (HH/HL vs LH/LL with candle bias), and Daily BB% showing where price sits within the Bollinger Band channel. The title cell doubles as a live chart timeframe read, so you always know your current TF bias alongside the higher timeframe context.

Color coding is automatic — green for bullish alignment, red for bearish, yellow for conflict. Background color reflects the overall bias of all four signals combined.

Designed for swing and tactical traders who need fast, clean trend context before evaluating a setup. No repainting. All signals update on bar close.

## Source Code

````pine
//@version=5
indicator("Trend Stack v3[OGM]", overlay=true)

grpEMA = "EMA Settings"
emaLongLen = input.int(200, "EMA Slow (200)", minval=1, group=grpEMA)
structLen = input.int(7, "Current TF Structure Lookback", minval=2, group=grpEMA)

grpBB = "Daily BB Settings"
bbLen = input.int(20, "BB Length", minval=1, group=grpBB)
bbMult = input.float(2.0, "BB StdDev Multiplier", minval=0.1, step=0.1, group=grpBB)

grpRows = "Row Visibility"
showDailyEMA = input.bool(true, "Show D200", group=grpRows)
show4HEMA = input.bool(true, "Show 4H200", group=grpRows)
showDailyStruct = input.bool(true, "Show D/STRUCT", group=grpRows)
showMidBB = input.bool(true, "Show MID BB", group=grpRows)

grpDisplay = "Display Settings"
showBGColor = input.bool(true, "Show background color", group=grpDisplay)
labelPos = input.string("Top Right", "Label position", group=grpDisplay, options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
bgStrong = input.int(90, "Strong alignment opacity", group=grpDisplay, minval=50, maxval=99)
bgWeak = input.int(96, "Partial alignment opacity", group=grpDisplay, minval=50, maxval=99)

grpColors = "Colors"
colBull = input.color(color.new(color.green, 0), "Bull color", group=grpColors)
colBear = input.color(color.new(color.red, 0), "Bear color", group=grpColors)
colMixed = input.color(color.new(color.yellow, 0), "Mixed color", group=grpColors)

slopeDir(ema) =>
    ema > ema[1] ? "+" : ema < ema[1] ? "-" : "~"

d_ema200 = request.security(syminfo.tickerid, "D", ta.ema(close, emaLongLen), lookahead=barmerge.lookahead_off)
d_close = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_off)
d_ema200_slope = request.security(syminfo.tickerid, "D", slopeDir(ta.ema(close, emaLongLen)), lookahead=barmerge.lookahead_off)
d_emaAbove = d_close > d_ema200
d_emaState = d_emaAbove ? 1 : -1
d_emaLabel = d_emaAbove ? "BULL " + d_ema200_slope : "BEAR " + d_ema200_slope
d_emaColor = d_emaAbove ? color.new(color.lime, 0) : color.new(color.red, 0)

h4_ema200 = request.security(syminfo.tickerid, "240", ta.ema(close, emaLongLen), lookahead=barmerge.lookahead_off)
h4_close = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)
h4_ema200_slope = request.security(syminfo.tickerid, "240", slopeDir(ta.ema(close, emaLongLen)), lookahead=barmerge.lookahead_off)
h4_emaAbove = h4_close > h4_ema200
h4_emaState = h4_emaAbove ? 1 : -1
h4_emaLabel = h4_emaAbove ? "BULL " + h4_ema200_slope : "BEAR " + h4_ema200_slope
h4_emaColor = h4_emaAbove ? color.new(color.lime, 0) : color.new(color.red, 0)

d_high0 = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_off)
d_high1 = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
d_low0 = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_off)
d_low1 = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
d_close0 = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_off)
d_close1 = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)
d_close2 = request.security(syminfo.tickerid, "D", close[2], lookahead=barmerge.lookahead_off)
d_open0 = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
d_open1 = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_off)
d_open2 = request.security(syminfo.tickerid, "D", open[2], lookahead=barmerge.lookahead_off)

hhhl = d_high0 > d_high1 and d_low0 > d_low1
lhll = d_high0 < d_high1 and d_low0 < d_low1
greenCount = (d_close0 > d_open0 ? 1 : 0) + (d_close1 > d_open1 ? 1 : 0) + (d_close2 > d_open2 ? 1 : 0)
candleBullBias = greenCount >= 2
structBull = hhhl and candleBullBias
structBear = lhll and not candleBullBias
structState = structBull ? 1 : structBear ? -1 : 0
structLabel = structBull ? "BULL" : structBear ? "BEAR" : "NEUT"
structColor = structBull ? color.new(color.lime, 0) : structBear ? color.new(color.red, 0) : color.new(color.yellow, 0)

d_bbBasis = request.security(syminfo.tickerid, "D", ta.sma(close, bbLen), lookahead=barmerge.lookahead_off)
d_bbStdev = request.security(syminfo.tickerid, "D", ta.stdev(close, bbLen), lookahead=barmerge.lookahead_off)
d_bbUpper = d_bbBasis + bbMult * d_bbStdev
d_bbLower = d_bbBasis - bbMult * d_bbStdev
d_bbRange = d_bbUpper - d_bbLower
d_bbPct = d_bbRange > 0 ? (d_close - d_bbLower) / d_bbRange * 100 : 50.0
d_bbMidState = d_close > d_bbBasis ? 1 : -1
d_bbPctLabel = str.tostring(math.round(d_bbPct, 1)) + "%"
d_bbPctColor = d_bbPct > 50 ? color.new(color.lime, 0) : color.new(color.red, 0)

totalScore = d_emaState + h4_emaState + structState + d_bbMidState
allBull = totalScore == 4
mostlyBull = totalScore == 2 or totalScore == 3
allBear = totalScore == -4
mostlyBear = totalScore == -2 or totalScore == -3
overallColor = allBull or mostlyBull ? colBull : allBear or mostlyBear ? colBear : colMixed

bgColor = allBull ? color.new(colBull, bgStrong) : mostlyBull ? color.new(colBull, bgWeak) : allBear ? color.new(colBear, bgStrong) : mostlyBear ? color.new(colBear, bgWeak) : color.new(colMixed, bgWeak)
bgcolor(showBGColor ? bgColor : na, title="Trend Stack BG")

cur_ema200 = ta.ema(close, emaLongLen)
cur_above = close > cur_ema200
cur_slope = slopeDir(cur_ema200)

curSwingHigh = ta.highest(high, structLen)
curSwingLow = ta.lowest(low, structLen)
curPrevSwingHigh = ta.highest(high[structLen], structLen)
curPrevSwingLow = ta.lowest(low[structLen], structLen)

curStructBull = curSwingHigh > curPrevSwingHigh and curSwingLow > curPrevSwingLow
curStructBear = curSwingHigh < curPrevSwingHigh and curSwingLow < curPrevSwingLow
curStructText = curStructBull ? "HH/HL" : curStructBear ? "LH/LL" : "MIX"

curTrendBull = cur_above and cur_slope == "+"
curTrendBear = not cur_above and cur_slope == "-"

curAlignedBull = curTrendBull and curStructBull
curAlignedBear = curTrendBear and curStructBear
curConflict = (curTrendBull and curStructBear) or (curTrendBear and curStructBull)

cur_label = curAlignedBull ? "▲+ HH/HL" :
     curAlignedBear ? "▼- LH/LL" :
     curConflict ? "⚠ " + curStructText :
     (cur_above ? "▲" : "▼") + cur_slope + " " + curStructText

cur_color = curAlignedBull ? color.new(color.lime, 0) :curAlignedBear ? color.new(color.red, 0) : curConflict ? color.new(color.orange, 0) : color.new(color.yellow, 0)


lPos = labelPos == "Top Right" ? position.top_right : labelPos == "Top Left" ? position.top_left : labelPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table t = table.new(lPos, 5, 2, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 40), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)
 
if barstate.islast
    table.cell(t, 0, 0, "OM TREND STACK", text_color=color.new(color.white, 0), text_size=size.small, bgcolor=color.new(color.black, 30))
    table.cell(t, 1, 0, showDailyEMA ? "D200" : "", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(t, 2, 0, show4HEMA ? "4H200" : "", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(t, 3, 0, showDailyStruct ? "D/STRUCT" : "", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(t, 4, 0, showMidBB ? "MID BB" : "", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(t, 0, 1, cur_label, text_color=cur_color, text_size=size.small, bgcolor=color.new(color.black, 30))
    table.cell(t, 1, 1, showDailyEMA ? d_emaLabel : "", text_color=showDailyEMA ? d_emaColor : color.new(color.gray, 80), text_size=size.small)
    table.cell(t, 2, 1, show4HEMA ? h4_emaLabel : "", text_color=show4HEMA ? h4_emaColor : color.new(color.gray, 80), text_size=size.small)
    table.cell(t, 3, 1, showDailyStruct ? structLabel : "", text_color=showDailyStruct ? structColor : color.new(color.gray, 80), text_size=size.small)
    table.cell(t, 4, 1, showMidBB ? d_bbPctLabel : "", text_color=showMidBB ? d_bbPctColor : color.new(color.gray, 80), text_size=size.small)
````
