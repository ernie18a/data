# IANI Liquidity M/W Scalper

- url: https://www.tradingview.com/script/PT42utXM-IANI-Liquidity-M-W-Scalper/
- type: indicator
- pine_id: PUB;b352df08a04848f4962942d2dc57d7b5
- version: 1.0

## Description

English description

IANI Liquidity M/W Scalper is a price-action scalping indicator designed mainly for low-timeframe execution, especially M1 and M5.

The indicator combines:

liquidity levels: PDH / PDL / PWH / PWL
higher-timeframe support and resistance
local trendline breakout structure
M / W reversal patterns
breakout + pullback / retest logic
optional EMA 50 / EMA 200, hidden by default

The goal is to help identify:

where liquidity is located
where important reaction zones are
where price may reverse or continue
where local breakout structure appears
where a pullback entry may form
How to use — English
1. Start with the main map

First, watch the main liquidity levels:

PDH = Previous Day High
PDL = Previous Day Low
PWH = Previous Week High
PWL = Previous Week Low

These are liquidity areas. Price may move toward them to take liquidity, trigger stops, or react.

2. Use higher-timeframe support and resistance

Support and resistance are calculated from higher timeframes, such as H1.

Basic idea:

near support, look for BUY setups
near resistance, look for SELL setups
after a breakout, watch the next level as a possible target

Do not enter only because price touches a line. Wait for reaction, structure, rejection, or retest.

3. Use the trendline for scalp structure

The trendline is for local scalp structure.

By default, it uses Chart TF:

on M1, it draws trendlines from M1 pivots
on M5, it draws trendlines from M5 pivots

Usage:

green line below price = local bullish structure
break below it = possible SELL watch
red line above price = local bearish structure
break above it = possible BUY watch
4. Use M / W patterns for confirmation

M/W patterns help with reversal setups:

W near support / PDL / liquidity zone = possible BUY
M near resistance / PDH / liquidity zone = possible SELL

The most useful labels are:

BUY PB / W Retest
SELL PB / M Retest

This means the pattern had a breakout and then a pullback/retest.

5. Safer entry workflow

Do not enter every label blindly.

Better process:

1. Price reaches an important area: PDH / PDL / S/R / weekly level
2. Price reacts
3. M or W structure forms
4. Local structure or trendline breaks
5. Wait for pullback / retest
6. Enter with a small SL behind structure
Recommended settings for M1 scalping
Show EMA 50 / EMA 200 = OFF
Show Liquidity Zones = ON
Show Previous Day High / Low = ON
Show Previous Week High / Low = ON
Show Daily Swings = OFF
Show Weekly Swings = OFF
S/R Source TF = 60
Visible S/R Above = 3 or 4
Visible S/R Below = 3 or 4
Trendline Source TF = Chart
Trendline Swing Mode = Major
Show TL Break Labels = OFF
Show M/W Retest Entry Labels = ON
Important

This is not a blind buy/sell system.
Use it with market structure, liquidity, session timing, risk management, and confirmation from price action.

## Source Code

````pine
//@version=6
indicator("IANI Liquidity M/W Scalper", shorttitle="IANI LQ", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=1500)

//====================================================================
// GENERAL
//====================================================================
group_general = "General"
showEma = input.bool(false, "Show EMA 50 / EMA 200", group=group_general)
ema50Color = input.color(color.red, "EMA 50 Color", group=group_general)
ema200Color = input.color(color.white, "EMA 200 Color", group=group_general)
emaTransp = input.int(0, "EMA Transparency", minval=0, maxval=100, group=group_general)

//====================================================================
// LIQUIDITY / INTEREST ZONES
//====================================================================
group_liq = "Liquidity / Interest Zones"
showLiquidity = input.bool(true, "Show Liquidity Zones", group=group_liq)

showPD = input.bool(true, "Show Previous Day High / Low", group=group_liq)
showPW = input.bool(true, "Show Previous Week High / Low", group=group_liq)
showDailySwings = input.bool(false, "Show Last Confirmed Daily Swing High / Low", group=group_liq)
showWeeklySwings = input.bool(false, "Show Last Confirmed Weekly Swing High / Low", group=group_liq)

liqPivotLeft = input.int(3, "Daily/Weekly Swing Left Bars", minval=1, maxval=20, group=group_liq)
liqPivotRight = input.int(3, "Daily/Weekly Swing Right Bars", minval=1, maxval=20, group=group_liq)

liqPastBars = input.int(1000, "Liquidity Line Left Bars", minval=50, maxval=5000, group=group_liq)
liqFutureBars = input.int(250, "Liquidity Line Right Bars", minval=20, maxval=1000, group=group_liq)

liqResistanceColor = input.color(color.red, "Liquidity Above Color", group=group_liq)
liqSupportColor = input.color(color.rgb(0, 35, 150), "Liquidity Below Color", group=group_liq)
liqTransparency = input.int(45, "Liquidity Line Transparency", minval=0, maxval=100, group=group_liq)
liqLineStyle = input.string("Dashed", "Liquidity Line Style", options=["Solid", "Dashed", "Dotted"], group=group_liq)

showLiqLabels = input.bool(true, "Show Small Liquidity Labels", group=group_liq)
liqLabelOffset = input.int(10, "Label Offset Bars", minval=1, maxval=100, group=group_liq)
liqLabelYOffset = input.float(0.80, "Label Y Offset Above Line", step=0.10, group=group_liq)
liqLabelBgTransparency = input.int(10, "Label Box Transparency", minval=0, maxval=100, group=group_liq)

//====================================================================
// HTF SUPPORT / RESISTANCE
//====================================================================
group_sr = "HTF Support / Resistance"
showSR = input.bool(true, "Show HTF S/R", group=group_sr)
srTF = input.string("60", "S/R Source TF", options=["15", "60", "240", "D", "W"], group=group_sr)
srUseClose = input.bool(true, "Use Close Pivots", group=group_sr)

srLeftBars = input.int(15, "S/R Left Bars", minval=2, maxval=50, group=group_sr)
srRightBars = input.int(15, "S/R Right Bars", minval=2, maxval=50, group=group_sr)
srMergeDistance = input.float(5.00, "Merge Levels Distance", step=0.10, group=group_sr)
srMaxLevels = input.int(40, "Max Stored S/R Levels", minval=5, maxval=100, group=group_sr)
srMinStrengthToShow = input.int(1, "Min Strength To Show", minval=1, maxval=10, group=group_sr)

visibleSRAbove = input.int(4, "Visible S/R Above Price", minval=1, maxval=20, group=group_sr)
visibleSRBelow = input.int(4, "Visible S/R Below Price", minval=1, maxval=20, group=group_sr)
srMaxDistance = input.float(0.00, "Max Distance From Price - 0 OFF", step=1.0, group=group_sr)

srPastBars = input.int(1000, "S/R Line Left Bars", minval=50, maxval=5000, group=group_sr)
srFutureBars = input.int(250, "S/R Line Right Bars", minval=20, maxval=1000, group=group_sr)

srBaseWidth = input.int(1, "Base Line Width", minval=1, maxval=4, group=group_sr)
srSupportColor = input.color(color.rgb(0, 35, 150), "Support Color", group=group_sr)
srResistanceColor = input.color(color.red, "Resistance Color", group=group_sr)
srTransparency = input.int(25, "S/R Transparency", minval=0, maxval=100, group=group_sr)

showSRLabels = input.bool(false, "Show S/R Labels", group=group_sr)

//====================================================================
// TRENDLINE
//====================================================================
group_tl = "Scalp Trendline"
showTrendline = input.bool(true, "Show Trendline", group=group_tl)
trendlineTF = input.string("Chart", "Trendline Source TF", options=["Chart", "5", "15"], group=group_tl)
tlSourceMode = input.string("Close", "Trendline Source", options=["Close", "Wick"], group=group_tl)
tlSwingMode = input.string("Major", "Trendline Swing Mode", options=["Recent", "Major"], group=group_tl)
tlMajorLookback = input.int(8, "Major Swing Lookback Pivots", minval=3, maxval=30, group=group_tl)

tlLeftBars = input.int(4, "Trendline Left Bars", minval=2, maxval=20, group=group_tl)
tlRightBars = input.int(4, "Trendline Right Bars", minval=2, maxval=20, group=group_tl)

showBullTL = input.bool(true, "Show Bullish Trendline Under Lows", group=group_tl)
showBearTL = input.bool(true, "Show Bearish Trendline Above Highs", group=group_tl)

bullTLColor = input.color(color.lime, "Bullish Trendline Color", group=group_tl)
bearTLColor = input.color(color.red, "Bearish Trendline Color", group=group_tl)
tlTransparency = input.int(0, "Trendline Transparency", minval=0, maxval=100, group=group_tl)
tlWidth = input.int(2, "Trendline Width", minval=1, maxval=5, group=group_tl)

showTLBreakLabels = input.bool(false, "Show Trendline Break Labels", group=group_tl)
tlBreakBuffer = input.float(0.30, "Trendline Break Buffer", step=0.10, group=group_tl)

//====================================================================
// M / W PATTERNS
//====================================================================
group_mw = "M / W Pattern"
showMW = input.bool(true, "Show M / W Patterns", group=group_mw)
showMWWatch = input.bool(false, "Show M/W Watch Labels", group=group_mw)
showMWBreak = input.bool(false, "Show M/W Break Labels", group=group_mw)
showMWRetest = input.bool(true, "Show M/W Retest Entry Labels", group=group_mw)

patternPivotLen = input.int(5, "Pattern Pivot Sensitivity", minval=2, maxval=20, group=group_mw)
mwTolerance = input.float(2.00, "M/W Shoulder Tolerance", step=0.10, group=group_mw)
mwMinDepth = input.float(2.00, "Minimum Pattern Depth", step=0.10, group=group_mw)
mwBreakBuffer = input.float(0.50, "Neckline Break Buffer", step=0.10, group=group_mw)
mwRetestTolerance = input.float(1.00, "Neckline Retest Tolerance", step=0.10, group=group_mw)
mwMaxWait = input.int(80, "Max Bars To Wait For Retest", minval=5, maxval=300, group=group_mw)

maxMWPatterns = input.int(3, "Max Visible M/W Patterns", minval=1, maxval=20, group=group_mw)

wLineColor = input.color(color.lime, "W Line Color", group=group_mw)
mLineColor = input.color(color.red, "M Line Color", group=group_mw)
mwLineTransp = input.int(0, "M/W Line Transparency", minval=0, maxval=100, group=group_mw)
mwLineWidth = input.int(2, "M/W Line Width", minval=1, maxval=4, group=group_mw)

//====================================================================
// EMA
//====================================================================
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(showEma ? ema50 : na, "EMA 50", color=color.new(ema50Color, emaTransp), linewidth=2)
plot(showEma ? ema200 : na, "EMA 200", color=color.new(ema200Color, emaTransp), linewidth=2)

//====================================================================
// LIQUIDITY ENGINE - CURRENT LEVELS ONLY
//====================================================================
f_last_pivot_high(_left, _right) =>
    float ph = ta.pivothigh(high, _left, _right)
    ta.valuewhen(not na(ph), ph, 0)

f_last_pivot_low(_left, _right) =>
    float pl = ta.pivotlow(low, _left, _right)
    ta.valuewhen(not na(pl), pl, 0)

f_liq_color(_price) =>
    _price >= close ? color.new(liqResistanceColor, liqTransparency) : color.new(liqSupportColor, liqTransparency)

f_liq_label_color(_price) =>
    _price >= close ? color.new(liqResistanceColor, liqLabelBgTransparency) : color.new(liqSupportColor, liqLabelBgTransparency)

f_liq_line_style() =>
    liqLineStyle == "Dashed" ? line.style_dashed : liqLineStyle == "Dotted" ? line.style_dotted : line.style_solid

f_update_level_line(line _ln, bool _show, float _price, int _width) =>
    line out = _ln

    if not _show or na(_price)
        if not na(out)
            line.delete(out)
        out := na
    else
        int xLeft = math.max(0, bar_index - liqPastBars)
        int xRight = bar_index + liqFutureBars
        color col = f_liq_color(_price)

        if na(out)
            out := line.new(
                 xLeft,
                 _price,
                 xRight,
                 _price,
                 extend=extend.none,
                 color=col,
                 width=_width,
                 style=f_liq_line_style())
        else
            line.set_x1(out, xLeft)
            line.set_x2(out, xRight)
            line.set_y1(out, _price)
            line.set_y2(out, _price)
            line.set_color(out, col)
            line.set_width(out, _width)
            line.set_style(out, f_liq_line_style())

    out

f_update_level_label(label _lb, bool _show, float _price, string _txt) =>
    label out = _lb

    if not _show or na(_price)
        if not na(out)
            label.delete(out)
        out := na
    else
        color boxCol = f_liq_label_color(_price)
        float labelY = _price + liqLabelYOffset

        if na(out)
            out := label.new(
                 bar_index + liqLabelOffset,
                 labelY,
                 _txt,
                 style=label.style_label_left,
                 color=boxCol,
                 textcolor=color.white,
                 size=size.tiny)
        else
            label.set_x(out, bar_index + liqLabelOffset)
            label.set_y(out, labelY)
            label.set_text(out, _txt)
            label.set_color(out, boxCol)
            label.set_textcolor(out, color.white)

    out

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)

pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)

dsh = request.security(syminfo.tickerid, "D", f_last_pivot_high(liqPivotLeft, liqPivotRight), lookahead=barmerge.lookahead_off)
dsl = request.security(syminfo.tickerid, "D", f_last_pivot_low(liqPivotLeft, liqPivotRight), lookahead=barmerge.lookahead_off)

wsh = request.security(syminfo.tickerid, "W", f_last_pivot_high(liqPivotLeft, liqPivotRight), lookahead=barmerge.lookahead_off)
wsl = request.security(syminfo.tickerid, "W", f_last_pivot_low(liqPivotLeft, liqPivotRight), lookahead=barmerge.lookahead_off)

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line dshLine = na
var line dslLine = na
var line wshLine = na
var line wslLine = na

var label pdhLbl = na
var label pdlLbl = na
var label pwhLbl = na
var label pwlLbl = na
var label dshLbl = na
var label dslLbl = na
var label wshLbl = na
var label wslLbl = na

pdhLine := f_update_level_line(pdhLine, showLiquidity and showPD, pdh, 1)
pdlLine := f_update_level_line(pdlLine, showLiquidity and showPD, pdl, 1)

pwhLine := f_update_level_line(pwhLine, showLiquidity and showPW, pwh, 2)
pwlLine := f_update_level_line(pwlLine, showLiquidity and showPW, pwl, 2)

dshLine := f_update_level_line(dshLine, showLiquidity and showDailySwings, dsh, 1)
dslLine := f_update_level_line(dslLine, showLiquidity and showDailySwings, dsl, 1)

wshLine := f_update_level_line(wshLine, showLiquidity and showWeeklySwings, wsh, 2)
wslLine := f_update_level_line(wslLine, showLiquidity and showWeeklySwings, wsl, 2)

pdhLbl := f_update_level_label(pdhLbl, showLiquidity and showLiqLabels and showPD, pdh, "PDH")
pdlLbl := f_update_level_label(pdlLbl, showLiquidity and showLiqLabels and showPD, pdl, "PDL")

pwhLbl := f_update_level_label(pwhLbl, showLiquidity and showLiqLabels and showPW, pwh, "PWH")
pwlLbl := f_update_level_label(pwlLbl, showLiquidity and showLiqLabels and showPW, pwl, "PWL")

dshLbl := f_update_level_label(dshLbl, showLiquidity and showLiqLabels and showDailySwings, dsh, "D-LQ High")
dslLbl := f_update_level_label(dslLbl, showLiquidity and showLiqLabels and showDailySwings, dsl, "D-LQ Low")

wshLbl := f_update_level_label(wshLbl, showLiquidity and showLiqLabels and showWeeklySwings, wsh, "W-LQ High")
wslLbl := f_update_level_label(wslLbl, showLiquidity and showLiqLabels and showWeeklySwings, wsl, "W-LQ Low")

//====================================================================
// HTF S/R ENGINE - NEAREST IMPORTANT LEVELS ONLY
//====================================================================
f_sr_payload(_left, _right, _useClose) =>
    float hsrc = _useClose ? close : high
    float lsrc = _useClose ? close : low
    float ph = ta.pivothigh(hsrc, _left, _right)
    float pl = ta.pivotlow(lsrc, _left, _right)
    int pt = time[_right]
    [ph, pl, pt]

[srPH, srPL, srPT] = request.security(syminfo.tickerid, srTF, f_sr_payload(srLeftBars, srRightBars, srUseClose), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

var float[] srPrices = array.new_float()
var int[] srStrength = array.new_int()
var line[] srLines = array.new_line()
var label[] srLabels = array.new_label()
var string[] srNames = array.new_string()

var int lastSRHighT = na
var int lastSRLowT = na

f_add_sr_level(_price, _name) =>
    if showSR and not na(_price)
        int found = na
        int n = array.size(srPrices)

        if n > 0
            for i = 0 to n - 1
                float oldPrice = array.get(srPrices, i)
                if math.abs(oldPrice - _price) <= srMergeDistance
                    found := i
                    break

        int xLeft = math.max(0, bar_index - srPastBars)
        int xRight = bar_index + srFutureBars

        if na(found)
            line ln = line.new(xLeft, _price, xRight, _price, extend=extend.none, color=color.new(color.gray, 100), width=srBaseWidth)
            label lb = na

            if showSRLabels
                lb := label.new(bar_index + 5, _price, _name, style=label.style_label_left, color=color.new(color.black, 85), textcolor=color.white, size=size.tiny)

            array.push(srPrices, _price)
            array.push(srStrength, 1)
            array.push(srLines, ln)
            array.push(srLabels, lb)
            array.push(srNames, _name)

            if array.size(srPrices) > srMaxLevels
                line oldLine = array.shift(srLines)
                label oldLabel = array.shift(srLabels)

                if not na(oldLine)
                    line.delete(oldLine)

                if not na(oldLabel)
                    label.delete(oldLabel)

                array.shift(srPrices)
                array.shift(srStrength)
                array.shift(srNames)
        else
            float oldPrice = array.get(srPrices, found)
            int oldStrength = array.get(srStrength, found)

            float newPrice = (oldPrice * oldStrength + _price) / (oldStrength + 1)
            int newStrength = oldStrength + 1

            line ln = array.get(srLines, found)

            line.set_y1(ln, newPrice)
            line.set_y2(ln, newPrice)
            line.set_width(ln, math.min(4, srBaseWidth + int(math.floor(newStrength / 3))))

            array.set(srPrices, found, newPrice)
            array.set(srStrength, found, newStrength)

    0

f_update_sr_levels() =>
    int n = array.size(srPrices)

    if n > 0
        int xLeft = math.max(0, bar_index - srPastBars)
        int xRight = bar_index + srFutureBars

        for i = 0 to n - 1
            float p = array.get(srPrices, i)
            int s = array.get(srStrength, i)
            line ln = array.get(srLines, i)

            bool isAbove = p > close
            bool isBelow = p < close

            int rank = 0

            for j = 0 to n - 1
                if j != i
                    float p2 = array.get(srPrices, j)
                    int s2 = array.get(srStrength, j)

                    if s2 >= srMinStrengthToShow
                        if isAbove and p2 > close and p2 - close < p - close
                            rank += 1

                        if isBelow and p2 < close and close - p2 < close - p
                            rank += 1

            bool distanceOk = srMaxDistance <= 0 or math.abs(p - close) <= srMaxDistance
            bool showAbove = isAbove and rank < visibleSRAbove
            bool showBelow = isBelow and rank < visibleSRBelow
            bool showThis = s >= srMinStrengthToShow and distanceOk and (showAbove or showBelow)

            color finalColor = color.new(color.gray, 100)

            if showThis
                finalColor := p >= close ? color.new(srResistanceColor, srTransparency) : color.new(srSupportColor, srTransparency)

            line.set_x1(ln, xLeft)
            line.set_x2(ln, xRight)
            line.set_y1(ln, p)
            line.set_y2(ln, p)
            line.set_color(ln, finalColor)
            line.set_width(ln, math.min(3, srBaseWidth + int(math.floor(s / 3))))

            label lb = array.get(srLabels, i)

            if showSRLabels and not na(lb)
                label.set_x(lb, bar_index + 5)
                label.set_y(lb, p)

            if not showSRLabels and not na(lb)
                label.delete(lb)
                array.set(srLabels, i, na)

    0

if showSR and not na(srPH) and (na(lastSRHighT) or srPT != lastSRHighT)
    lastSRHighT := srPT
    f_add_sr_level(srPH, srTF + " R")

if showSR and not na(srPL) and (na(lastSRLowT) or srPT != lastSRLowT)
    lastSRLowT := srPT
    f_add_sr_level(srPL, srTF + " S")

f_update_sr_levels()

//====================================================================
// TRENDLINE LOGIC
//====================================================================
f_tl_payload(_left, _right, _useClose) =>
    float hsrc = _useClose ? close : high
    float lsrc = _useClose ? close : low
    float ph = ta.pivothigh(hsrc, _left, _right)
    float pl = ta.pivotlow(lsrc, _left, _right)
    int pt = time[_right]
    [ph, pl, pt]

useCloseTL = tlSourceMode == "Close"
useChartTL = trendlineTF == "Chart"

chartHsrc = useCloseTL ? close : high
chartLsrc = useCloseTL ? close : low
chartPH = ta.pivothigh(chartHsrc, tlLeftBars, tlRightBars)
chartPL = ta.pivotlow(chartLsrc, tlLeftBars, tlRightBars)
chartPT = bar_index - tlRightBars

[m5PH, m5PL, m5PT] = request.security(syminfo.tickerid, "5", f_tl_payload(tlLeftBars, tlRightBars, useCloseTL), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[m15PH, m15PL, m15PT] = request.security(syminfo.tickerid, "15", f_tl_payload(tlLeftBars, tlRightBars, useCloseTL), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

tlPH = useChartTL ? chartPH : trendlineTF == "5" ? m5PH : m15PH
tlPL = useChartTL ? chartPL : trendlineTF == "5" ? m5PL : m15PL
tlPT = useChartTL ? chartPT : trendlineTF == "5" ? m5PT : m15PT

var float[] highYs = array.new_float()
var int[] highXs = array.new_int()
var float[] lowYs = array.new_float()
var int[] lowXs = array.new_int()

var int lastHighX = na
var int lastLowX = na

var line bullTL = na
var line bearTL = na

var float bullY1 = na
var float bullY2 = na
var int bullX1 = na
var int bullX2 = na

var float bearY1 = na
var float bearY2 = na
var int bearX1 = na
var int bearX2 = na

f_make_line(_x1, _y1, _x2, _y2, _color) =>
    line ln = na

    if useChartTL
        ln := line.new(_x1, _y1, _x2, _y2, xloc=xloc.bar_index, extend=extend.right, color=_color, width=tlWidth)
    else
        ln := line.new(_x1, _y1, _x2, _y2, xloc=xloc.bar_time, extend=extend.right, color=_color, width=tlWidth)

    ln

if showTrendline and not na(tlPH) and (na(lastHighX) or tlPT != lastHighX)
    lastHighX := tlPT

    array.push(highYs, tlPH)
    array.push(highXs, tlPT)

    if array.size(highYs) > 50
        array.shift(highYs)
        array.shift(highXs)

    int nH = array.size(highYs)

    if nH >= 2 and showBearTL
        float currentHigh = array.get(highYs, nH - 1)
        int currentX = array.get(highXs, nH - 1)

        float anchorHigh = na
        int anchorX = na

        if tlSwingMode == "Recent"
            anchorHigh := array.get(highYs, nH - 2)
            anchorX := array.get(highXs, nH - 2)
        else
            int startIdx = math.max(0, nH - 1 - tlMajorLookback)

            for i = startIdx to nH - 2
                float candidate = array.get(highYs, i)
                int candidateX = array.get(highXs, i)

                if candidate > currentHigh
                    if na(anchorHigh) or candidate > anchorHigh
                        anchorHigh := candidate
                        anchorX := candidateX

        bool validBear = not na(anchorHigh) and currentHigh < anchorHigh and currentX != anchorX

        if validBear
            if not na(bearTL)
                line.delete(bearTL)

            bearTL := f_make_line(anchorX, anchorHigh, currentX, currentHigh, color.new(bearTLColor, tlTransparency))

            bearX1 := anchorX
            bearY1 := anchorHigh
            bearX2 := currentX
            bearY2 := currentHigh

if showTrendline and not na(tlPL) and (na(lastLowX) or tlPT != lastLowX)
    lastLowX := tlPT

    array.push(lowYs, tlPL)
    array.push(lowXs, tlPT)

    if array.size(lowYs) > 50
        array.shift(lowYs)
        array.shift(lowXs)

    int nL = array.size(lowYs)

    if nL >= 2 and showBullTL
        float currentLow = array.get(lowYs, nL - 1)
        int currentX = array.get(lowXs, nL - 1)

        float anchorLow = na
        int anchorX = na

        if tlSwingMode == "Recent"
            anchorLow := array.get(lowYs, nL - 2)
            anchorX := array.get(lowXs, nL - 2)
        else
            int startIdx = math.max(0, nL - 1 - tlMajorLookback)

            for i = startIdx to nL - 2
                float candidate = array.get(lowYs, i)
                int candidateX = array.get(lowXs, i)

                if candidate < currentLow
                    if na(anchorLow) or candidate < anchorLow
                        anchorLow := candidate
                        anchorX := candidateX

        bool validBull = not na(anchorLow) and currentLow > anchorLow and currentX != anchorX

        if validBull
            if not na(bullTL)
                line.delete(bullTL)

            bullTL := f_make_line(anchorX, anchorLow, currentX, currentLow, color.new(bullTLColor, tlTransparency))

            bullX1 := anchorX
            bullY1 := anchorLow
            bullX2 := currentX
            bullY2 := currentLow

f_line_price(_x, _x1, _y1, _x2, _y2) =>
    float result = na

    if not na(_x1) and not na(_x2) and _x2 != _x1
        result := _y1 + (_y2 - _y1) * (float(_x - _x1) / float(_x2 - _x1))

    result

currentX = useChartTL ? bar_index : time

bullTLPrice = f_line_price(currentX, bullX1, bullY1, bullX2, bullY2)
bearTLPrice = f_line_price(currentX, bearX1, bearY1, bearX2, bearY2)

bullTLBreakDown = showTrendline and showTLBreakLabels and not na(bullTLPrice) and ta.crossunder(close, bullTLPrice - tlBreakBuffer)
bearTLBreakUp = showTrendline and showTLBreakLabels and not na(bearTLPrice) and ta.crossover(close, bearTLPrice + tlBreakBuffer)

if bullTLBreakDown
    label.new(bar_index, high, "TL BREAK\nSELL Watch", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

if bearTLBreakUp
    label.new(bar_index, low, "TL BREAK\nBUY Watch", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.tiny)

//====================================================================
// M/W LINE STORAGE
//====================================================================
var line[] mwLines = array.new_line()

f_add_mw_line(_x1, _y1, _x2, _y2, _color, _width) =>
    line ln = line.new(_x1, _y1, _x2, _y2, color=_color, width=_width, style=line.style_solid, extend=extend.none)

    array.push(mwLines, ln)

    if array.size(mwLines) > maxMWPatterns * 2
        line oldLine = array.shift(mwLines)

        if not na(oldLine)
            line.delete(oldLine)

    ln

//====================================================================
// M / W PATTERN MEMORY
//====================================================================
patPh = ta.pivothigh(close, patternPivotLen, patternPivotLen)
patPl = ta.pivotlow(close, patternPivotLen, patternPivotLen)

var int[] pivType = array.new_int()
var int[] pivX = array.new_int()
var float[] pivY = array.new_float()

f_add_pivot(_type, _x, _y) =>
    bool changed = false
    int n = array.size(pivType)

    if n == 0
        array.push(pivType, _type)
        array.push(pivX, _x)
        array.push(pivY, _y)
        changed := true
    else
        int lastIdx = n - 1
        int lastType = array.get(pivType, lastIdx)
        float lastY = array.get(pivY, lastIdx)

        if lastType == _type
            bool replacePivot = (_type == 1 and _y >= lastY) or (_type == -1 and _y <= lastY)

            if replacePivot
                array.set(pivX, lastIdx, _x)
                array.set(pivY, lastIdx, _y)
                changed := true
        else
            array.push(pivType, _type)
            array.push(pivX, _x)
            array.push(pivY, _y)
            changed := true

    if array.size(pivType) > 40
        array.shift(pivType)
        array.shift(pivX)
        array.shift(pivY)

    changed

bool newPatternPivot = false

if not na(patPh)
    newPatternPivot := f_add_pivot(1, bar_index - patternPivotLen, patPh) or newPatternPivot

if not na(patPl)
    newPatternPivot := f_add_pivot(-1, bar_index - patternPivotLen, patPl) or newPatternPivot

//====================================================================
// M / W DETECTION
//====================================================================
var bool activeW = false
var bool activeM = false

var float wNeck = na
var float mNeck = na
var int wRightX = na
var int mRightX = na

var bool wBroken = false
var bool mBroken = false
var float wBreakLevel = na
var float mBreakLevel = na
var int wBreakBar = na
var int mBreakBar = na

var int lastWX = na
var int lastMX = na

if showMW and newPatternPivot
    int n = array.size(pivType)

    if n >= 3
        int t1 = array.get(pivType, n - 3)
        int t2 = array.get(pivType, n - 2)
        int t3 = array.get(pivType, n - 1)

        int x1 = array.get(pivX, n - 3)
        int x2 = array.get(pivX, n - 2)
        int x3 = array.get(pivX, n - 1)

        float y1 = array.get(pivY, n - 3)
        float y2 = array.get(pivY, n - 2)
        float y3 = array.get(pivY, n - 1)

        float avgLevel = (y1 + y3) / 2.0

        bool wCandidate = t1 == -1 and t2 == 1 and t3 == -1 and math.abs(y1 - y3) <= mwTolerance and (y2 - avgLevel) >= mwMinDepth
        bool mCandidate = t1 == 1 and t2 == -1 and t3 == 1 and math.abs(y1 - y3) <= mwTolerance and (avgLevel - y2) >= mwMinDepth

        if wCandidate and (na(lastWX) or x3 != lastWX)
            lastWX := x3
            activeW := true
            wBroken := false
            wNeck := y2
            wRightX := x3

            f_add_mw_line(x1, y1, x2, y2, color.new(wLineColor, mwLineTransp), mwLineWidth)
            f_add_mw_line(x2, y2, x3, y3, color.new(wLineColor, mwLineTransp), mwLineWidth)

            if showMWWatch
                label.new(x3, y3, "W WATCH", style=label.style_label_up, color=color.new(wLineColor, 0), textcolor=color.white, size=size.tiny)

        if mCandidate and (na(lastMX) or x3 != lastMX)
            lastMX := x3
            activeM := true
            mBroken := false
            mNeck := y2
            mRightX := x3

            f_add_mw_line(x1, y1, x2, y2, color.new(mLineColor, mwLineTransp), mwLineWidth)
            f_add_mw_line(x2, y2, x3, y3, color.new(mLineColor, mwLineTransp), mwLineWidth)

            if showMWWatch
                label.new(x3, y3, "M WATCH", style=label.style_label_down, color=color.new(mLineColor, 0), textcolor=color.white, size=size.tiny)

wBreak = showMW and activeW and not na(wNeck) and bar_index > wRightX and close > wNeck + mwBreakBuffer
mBreak = showMW and activeM and not na(mNeck) and bar_index > mRightX and close < mNeck - mwBreakBuffer

if wBreak
    activeW := false
    wBroken := true
    wBreakLevel := wNeck
    wBreakBar := bar_index

    if showMWBreak
        label.new(bar_index, low, "W BREAK\nWait PB", style=label.style_label_up, color=color.new(wLineColor, 0), textcolor=color.white, size=size.tiny)

if mBreak
    activeM := false
    mBroken := true
    mBreakLevel := mNeck
    mBreakBar := bar_index

    if showMWBreak
        label.new(bar_index, high, "M BREAK\nWait PB", style=label.style_label_down, color=color.new(mLineColor, 0), textcolor=color.white, size=size.tiny)

if wBroken and not na(wBreakBar) and bar_index - wBreakBar > mwMaxWait
    wBroken := false
    wBreakLevel := na
    wBreakBar := na

if mBroken and not na(mBreakBar) and bar_index - mBreakBar > mwMaxWait
    mBroken := false
    mBreakLevel := na
    mBreakBar := na

wRetestBuy = showMW and wBroken and not na(wBreakLevel) and bar_index > wBreakBar and low <= wBreakLevel + mwRetestTolerance and close > wBreakLevel
mRetestSell = showMW and mBroken and not na(mBreakLevel) and bar_index > mBreakBar and high >= mBreakLevel - mwRetestTolerance and close < mBreakLevel

if wRetestBuy
    wBroken := false

    if showMWRetest
        label.new(bar_index, low, "BUY PB\nW Retest", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.small)

if mRetestSell
    mBroken := false

    if showMWRetest
        label.new(bar_index, high, "SELL PB\nM Retest", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//====================================================================
// ALERTS
//====================================================================
alertcondition(bullTLBreakDown, title="Bullish Trendline Broken Down", message="Bullish trendline broken down. Possible sell watch.")
alertcondition(bearTLBreakUp, title="Bearish Trendline Broken Up", message="Bearish trendline broken up. Possible buy watch.")

alertcondition(wBreak, title="W Breakout", message="W pattern neckline breakout. Wait for pullback.")
alertcondition(mBreak, title="M Breakdown", message="M pattern neckline breakdown. Wait for pullback.")
alertcondition(wRetestBuy, title="W BUY PB", message="BUY pullback after W neckline breakout.")
alertcondition(mRetestSell, title="M SELL PB", message="SELL pullback after M neckline breakdown.")
````
