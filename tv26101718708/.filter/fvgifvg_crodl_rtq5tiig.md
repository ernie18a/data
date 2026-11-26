# FVG/IFVG [CRODL]

- url: https://www.tradingview.com/script/rTQ5tIiG-FVG-IFVG-CRODL/
- type: indicator
- pine_id: PUB;ab1887ae6faa4783ad9a427c5a2b2d4b
- version: 1.0

## Description

█ OVERVIEW

This indicator detects Fair Value Gaps (FVGs) on up to five timeframes at once, tracks every gap it draws, and invalidates each one automatically the moment price fills it. A filled gap can be deleted, kept on the chart cut off at the candle that filled it, or flipped into an Inversion Fair Value Gap (iFVG) - the same zone watched with the opposite bias. What makes the script useful is that it manages the full life cycle of every zone in one tool: detect, track, fill-check on every bar, invert, and expire - across multiple timeframes, with a choice of close-based or wick-based fill logic, and without repainting committed zones.

█ CONCEPTS

Fair Value Gap (FVG)
An FVG is a three-candle imbalance, a concept popularized in ICT / "smart money" style trading. A bullish FVG forms when the low of the third candle stays above the high of the first candle: price moved up so fast that the middle candle left a slice of untraded space behind it. A bearish FVG is the mirror image - the high of the third candle stays below the low of the first. The space between those two levels is the zone this script draws. Traders typically watch unfilled gaps as areas price may revisit ("rebalance") before continuing.

Inversion Fair Value Gap (iFVG)
An iFVG is a gap that failed. When price closes through a bullish FVG instead of respecting it, many traders treat that same zone as resistance afterwards - a support/resistance flip applied to imbalances. This script performs the flip automatically: the box changes to the iFVG colors and label, and the inversion zone remains active until price trades back through its far side, at which point it is removed as well.

█ HOW IT WORKS

Detection
On every enabled timeframe the script tests the last three confirmed candles. A bullish gap is registered when the low of the newest candle is above the high of the oldest one; a bearish gap when the high of the newest candle is below the low of the oldest one. The gap is committed the moment its third candle closes, and the box is anchored at the middle candle where the imbalance was created.

Higher-timeframe data
Higher-timeframe candles are requested on confirmed bars only, using bar offsets (the publication-safe request technique recommended by PineCoders). No future data is accessed, and committed zones print in the same place historically and in real time — they do not repaint.

Live preview
With "Wait for candle close to identify FVGs" turned OFF, a provisional box is drawn while the third candle is still forming. It expands and contracts with the developing high/low, becomes permanent only if the gap survives the candle close, and is removed if the wick closes the gap first. Turn the setting ON if you prefer to see confirmed gaps only.

Invalidation engine
Every active zone is stored internally and re-checked on every chart bar:
• A bullish FVG is filled when price breaks below the BOTTOM of its zone.
• A bearish FVG is filled when price breaks above the TOP of its zone.
• "Close" mode requires a confirmed candle close beyond the level; "Wick" mode triggers on a single touch.
When a gap fills it is either deleted (default), kept on the chart truncated at the fill candle, or inverted into an iFVG - depending on your settings. An iFVG is then invalidated by the same Close/Wick rule, mirrored to its new direction.

█ SETTINGS AND HOW TO USE IT

• Timeframes - the chart timeframe plus up to four higher ones (15m / 1h / 4h / 1D by default). "Hide FVGs from timeframes lower than the chart" keeps the chart clean when you move up a timeframe.
• Filled FVG Type - Close (stricter) or Wick (more sensitive).
• Show FVG / Show iFVG - display fresh gaps, inversion zones, or both.
• Delete Boxes after fill - ON shows only zones that are still valid; OFF keeps a visual history of filled gaps, each cut off where it was filled.
• Extend Boxes + Label Distance - stretch active zones to the right edge of the chart with floating labels.
• Per-timeframe label text, plus full color and border control for FVG and iFVG boxes.
• Max bars back - how much history to scan (performance guard).

Typical use: treat unfilled gaps as potential reaction zones in the direction of the prevailing move, look for multi-timeframe confluence (for example a 15m gap sitting inside a 4h gap), and watch iFVGs as flip zones after a gap fails. The script marks and manages zones - it does not generate buy or sell signals. Combine it with your own market-structure analysis and risk management.

█ ALERTS

Alert conditions are included: Bullish FVG created, Bearish FVG created, FVG inverted bearish (a bullish gap was invalidated), and FVG inverted bullish (a bearish gap was invalidated).

█ NOTES AND LIMITATIONS

• Invalidation is evaluated against chart-timeframe candles. On a low timeframe a higher-timeframe gap can therefore be invalidated by a lower-timeframe close - this makes mitigation responsive, but it means the exact moment a higher-timeframe zone disappears can differ slightly depending on the chart timeframe you are viewing.
• With "Wait for candle close" OFF, the preview box on the still-forming candle keeps updating until that candle closes. This is by design and only affects the live, unconfirmed candle - committed zones never change.
• Up to 500 boxes and labels are kept on the chart; beyond that, the oldest zones are recycled first.

This is an educational tool, not financial advice. Past behavior of price around these zones does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("FVG/IFVG [CRODL]", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ─────────────────────────────── Inputs ───────────────────────────────
grpTF  = "Timeframes"
useTf1 = input.bool(true,  "", inline = "tf1", group = grpTF)
tfIn1  = input.timeframe("",    "Timeframe 1", inline = "tf1", group = grpTF)
useTf2 = input.bool(false, "", inline = "tf2", group = grpTF)
tfIn2  = input.timeframe("15",  "Timeframe 2", inline = "tf2", group = grpTF)
useTf3 = input.bool(false, "", inline = "tf3", group = grpTF)
tfIn3  = input.timeframe("60",  "Timeframe 3", inline = "tf3", group = grpTF)
useTf4 = input.bool(false, "", inline = "tf4", group = grpTF)
tfIn4  = input.timeframe("240", "Timeframe 4", inline = "tf4", group = grpTF)
useTf5 = input.bool(false, "", inline = "tf5", group = grpTF)
tfIn5  = input.timeframe("D",   "Timeframe 5", inline = "tf5", group = grpTF)

grpFVG    = "FVG Settings"
waitClose = input.bool(false, "Wait for candle close to identify FVGs", group = grpFVG)
hideLower = input.bool(true,  "Hide FVGs from timeframes lower than the chart", group = grpFVG)
showFVG   = input.bool(true,  "Show FVG",  group = grpFVG)
showIFVG  = input.bool(false, "Show iFVG", group = grpFVG)
fillType  = input.string("Close", "Filled FVG Type", options = ["Close", "Wick"], group = grpFVG, tooltip = "Close → a candle must CLOSE beyond the far side of the gap to fill/invalidate it.\nWick → a wick touching the far side is enough.")
maxBack   = input.int(300, "Max bars back to find FVGs", minval = 20, group = grpFVG)

grpLbl     = "Label Settings"
showLabels = input.bool(true, "Show Labels", group = grpLbl)
lblDist    = input.int(10, "Label Distance (Extend option only)", minval = 0, group = grpLbl)
lblF1 = input.string("FVG",      "TF1 Labels:  FVG", inline = "l1", group = grpLbl)
lblI1 = input.string("iFVG",     " | iFVG",          inline = "l1", group = grpLbl)
lblF2 = input.string("15m FVG",  "TF2 Labels:  FVG", inline = "l2", group = grpLbl)
lblI2 = input.string("15m iFVG", " | iFVG",          inline = "l2", group = grpLbl)
lblF3 = input.string("1h FVG",   "TF3 Labels:  FVG", inline = "l3", group = grpLbl)
lblI3 = input.string("1h iFVG",  " | iFVG",          inline = "l3", group = grpLbl)
lblF4 = input.string("4h FVG",   "TF4 Labels:  FVG", inline = "l4", group = grpLbl)
lblI4 = input.string("4h iFVG",  " | iFVG",          inline = "l4", group = grpLbl)
lblF5 = input.string("D FVG",    "TF5 Labels:  FVG", inline = "l5", group = grpLbl)
lblI5 = input.string("D iFVG",   " | iFVG",          inline = "l5", group = grpLbl)
colTxtBull = input.color(#089981, "Label Colors:  Bullish", inline = "lc", group = grpLbl)
colTxtBear = input.color(#f23645, " | Bearish",             inline = "lc", group = grpLbl)

grpBox       = "Box Settings"
deleteFilled = input.bool(true,  "Delete Boxes after fill", group = grpBox, tooltip = "Off → filled boxes stay on the chart, cut off at the candle that filled them.")
extendBoxes  = input.bool(false, "Extend Boxes", group = grpBox)
boxLen       = input.int(20, "Length of Boxes", minval = 1, group = grpBox)
colFvgBull  = input.color(color.new(#089981, 86), "FVG Box Color:  Bullish",  inline = "b1", group = grpBox)
colFvgBear  = input.color(color.new(#f23645, 86), " | Bearish",               inline = "b1", group = grpBox)
colIfvgBull = input.color(color.new(#2962ff, 82), "iFVG Box Color:  Bullish", inline = "b2", group = grpBox)
colIfvgBear = input.color(color.new(#ff9800, 82), " | Bearish",               inline = "b2", group = grpBox)

grpBrd     = "Border Settings"
brdStyleIn = input.string("Solid", "Border style", options = ["Solid", "Dashed", "Dotted", "None"], group = grpBrd)
brdWidth   = input.int(1, "Border Width", minval = 1, group = grpBrd)
colBrdBull = input.color(color.new(#089981, 65), "FVG Border Colors:  Bullish", inline = "br", group = grpBrd)
colBrdBear = input.color(color.new(#f23645, 65), " | Bearish",                  inline = "br", group = grpBrd)

// ────────────────────────────── Derived ──────────────────────────────
useClose = fillType == "Close"
brdStyle = brdStyleIn == "Dashed" ? line.style_dashed : brdStyleIn == "Dotted" ? line.style_dotted : line.style_solid
chartMs  = timeframe.in_seconds(timeframe.period) * 1000
lblStyle = extendBoxes ? label.style_label_left : label.style_label_right

f_res(string tf) =>
    tf == "" ? timeframe.period : tf

f_brd(bool bull) =>
    brdStyleIn == "None" ? color(na) : bull ? colBrdBull : colBrdBear

f_text(int idx, bool inv) =>
    switch idx
        1 => inv ? lblI1 : lblF1
        2 => inv ? lblI2 : lblF2
        3 => inv ? lblI3 : lblF3
        4 => inv ? lblI4 : lblF4
        => inv ? lblI5 : lblF5

// ──────────────────────── FVG object & storage ────────────────────────
type FVG
    box   bx
    label lb
    float top
    float bottom
    bool  isBull      // direction of the ORIGINAL gap
    bool  inverted    // true once it has flipped into an iFVG
    int   tfIdx
    int   tfMs

var fvgs = array.new<FVG>()
var sigs = array.new<bool>(4, false)  // 0:new bull  1:new bear  2:bear iFVG  3:bull iFVG

// ───────────────────── Higher-timeframe candle data ─────────────────────
// Confirmed candles only. The [1..3] offsets + lookahead_on is the standard
// non-repainting pattern: [1] = last CLOSED candle (C), [2] = middle (B),
// [3] = oldest (A). A bullish FVG exists when C.low > A.high, bearish when
// C.high < A.low. The gap zone is the space between those two levels.
f_data(string tf) =>
    request.security(syminfo.tickerid, tf, [high[1], low[1], high[2], low[2], high[3], low[3], time[1], time[2]], lookahead = barmerge.lookahead_on)

res1 = f_res(tfIn1)
res2 = f_res(tfIn2)
res3 = f_res(tfIn3)
res4 = f_res(tfIn4)
res5 = f_res(tfIn5)

[h1_1, l1_1, h2_1, l2_1, h3_1, l3_1, t1_1, t2_1] = f_data(res1)
[h1_2, l1_2, h2_2, l2_2, h3_2, l3_2, t1_2, t2_2] = f_data(res2)
[h1_3, l1_3, h2_3, l2_3, h3_3, l3_3, t1_3, t2_3] = f_data(res3)
[h1_4, l1_4, h2_4, l2_4, h3_4, l3_4, t1_4, t2_4] = f_data(res4)
[h1_5, l1_5, h2_5, l2_5, h3_5, l3_5, t1_5, t2_5] = f_data(res5)

// ──────────────────── Detection (one call per timeframe) ────────────────────
f_process(bool enabled, int tfIdx, string res, float h1, float l1, float h2, float l2, float h3, float l3, int t1, int t2) =>
    int  tfMs   = timeframe.in_seconds(res) * 1000
    bool newBar = nz(ta.change(time(res)), 1) != 0

    // running high/low of the candle currently forming on this timeframe
    var float devHi = na
    var float devLo = na
    devHi := newBar ? high : math.max(nz(devHi, high), high)
    devLo := newBar ? low  : math.min(nz(devLo, low),  low)

    var box   pBx = na   // live "preview" box while the 3rd candle is still open
    var label pLb = na

    bool inRange = last_bar_index - bar_index <= maxBack
    bool track   = enabled and (showFVG or showIFVG) and inRange

    // 1 ▸ commit a confirmed FVG the moment its 3rd candle closes
    if track and newBar
        box.delete(pBx)
        label.delete(pLb)
        pBx := na
        pLb := na
        bool bull = not na(l1) and not na(h3) and l1 > h3
        bool bear = not na(h1) and not na(l3) and h1 < l3
        if bull or bear
            float top = bull ? l1 : l3
            float bot = bull ? h3 : h1
            int   rgt = t2 + boxLen * tfMs
            box bx = box.new(t2, top, rgt, bot, xloc = xloc.bar_time, extend = extendBoxes ? extend.right : extend.none, bgcolor = showFVG ? (bull ? colFvgBull : colFvgBear) : color(na), border_color = showFVG ? f_brd(bull) : color(na), border_width = brdWidth, border_style = brdStyle)
            label lb = na
            if showLabels and showFVG
                lb := label.new(extendBoxes ? time + lblDist * chartMs : rgt, (top + bot) / 2, f_text(tfIdx, false), xloc = xloc.bar_time, style = lblStyle, color = color.new(color.black, 100), textcolor = bull ? colTxtBull : colTxtBear, size = size.small)
            fvgs.push(FVG.new(bx, lb, top, bot, bull, false, tfIdx, tfMs))
            sigs.set(bull ? 0 : 1, true)

    // 2 ▸ live preview while the 3rd candle is still forming (waitClose off)
    if track and showFVG and not waitClose
        bool pBull = not na(h2) and devLo > h2
        bool pBear = not na(l2) and devHi < l2
        bool pLive = pBull or pBear
        if pLive
            float pTop = pBull ? devLo : l2
            float pBot = pBull ? h2    : devHi
            int   pRgt = t1 + boxLen * tfMs
            if na(pBx)
                pBx := box.new(t1, pTop, pRgt, pBot, xloc = xloc.bar_time, extend = extendBoxes ? extend.right : extend.none, border_width = brdWidth, border_style = brdStyle)
            if showLabels and na(pLb)
                pLb := label.new(pRgt, (pTop + pBot) / 2, f_text(tfIdx, false), xloc = xloc.bar_time, style = lblStyle, color = color.new(color.black, 100), size = size.small)
            box.set_top(pBx, pTop)
            box.set_bottom(pBx, pBot)
            box.set_bgcolor(pBx, pBull ? colFvgBull : colFvgBear)
            box.set_border_color(pBx, f_brd(pBull))
            if not na(pLb)
                label.set_x(pLb, extendBoxes ? time + lblDist * chartMs : pRgt)
                label.set_y(pLb, (pTop + pBot) / 2)
                label.set_textcolor(pLb, pBull ? colTxtBull : colTxtBear)
        if not pLive
            box.delete(pBx)
            label.delete(pLb)
            pBx := na
            pLb := na

// ───────────────────────────── Run detection ─────────────────────────────
sigs.fill(false)

chartSec = timeframe.in_seconds(timeframe.period)
en1 = useTf1 and (not hideLower or timeframe.in_seconds(res1) >= chartSec)
en2 = useTf2 and (not hideLower or timeframe.in_seconds(res2) >= chartSec)
en3 = useTf3 and (not hideLower or timeframe.in_seconds(res3) >= chartSec)
en4 = useTf4 and (not hideLower or timeframe.in_seconds(res4) >= chartSec)
en5 = useTf5 and (not hideLower or timeframe.in_seconds(res5) >= chartSec)

f_process(en1, 1, res1, h1_1, l1_1, h2_1, l2_1, h3_1, l3_1, t1_1, t2_1)
f_process(en2, 2, res2, h1_2, l1_2, h2_2, l2_2, h3_2, l3_2, t1_2, t2_2)
f_process(en3, 3, res3, h1_3, l1_3, h2_3, l2_3, h3_3, l3_3, t1_3, t2_3)
f_process(en4, 4, res4, h1_4, l1_4, h2_4, l2_4, h3_4, l3_4, t1_4, t2_4)
f_process(en5, 5, res5, h1_5, l1_5, h2_5, l2_5, h3_5, l3_5, t1_5, t2_5)

// ─────────────────── Invalidation engine (the core) ───────────────────
// Every tracked gap is re-checked on every chart bar. Walking the array
// BACKWARD makes removal safe (indices of unvisited items don't shift).
f_kill(FVG f) =>
    if deleteFilled
        box.delete(f.bx)
        label.delete(f.lb)
    else
        box.set_right(f.bx, time)          // keep it, cut off at the fill candle
        box.set_extend(f.bx, extend.none)
        if not na(f.lb)
            label.set_x(f.lb, time)

bool closeOk = barstate.isconfirmed   // "Close" mode only fires once a candle has closed

if fvgs.size() > 0
    for i = fvgs.size() - 1 to 0
        FVG f = fvgs.get(i)
        if not f.inverted
            // bullish gap fills when price breaks below its bottom; bearish when above its top
            bool filled = f.isBull ? (useClose ? closeOk and close < f.bottom : low <= f.bottom) : (useClose ? closeOk and close > f.top : high >= f.top)
            if filled
                if showIFVG
                    // flip into an inversion zone instead of deleting
                    bool nowBull = not f.isBull
                    f.inverted := true
                    box.set_bgcolor(f.bx, nowBull ? colIfvgBull : colIfvgBear)
                    box.set_border_color(f.bx, f_brd(nowBull))
                    if not extendBoxes
                        box.set_right(f.bx, time + boxLen * f.tfMs)
                    if showLabels
                        int lx = extendBoxes ? time + lblDist * chartMs : time + boxLen * f.tfMs
                        if na(f.lb)
                            f.lb := label.new(lx, (f.top + f.bottom) / 2, "", xloc = xloc.bar_time, style = lblStyle, color = color.new(color.black, 100), size = size.small)
                        label.set_text(f.lb, f_text(f.tfIdx, true))
                        label.set_textcolor(f.lb, nowBull ? colTxtBull : colTxtBear)
                        label.set_x(f.lb, lx)
                    sigs.set(nowBull ? 3 : 2, true)
                else
                    fvgs.remove(i)
                    f_kill(f)
        else
            // iFVG dies when price trades back through its far side
            bool nowBull = not f.isBull
            bool dead = nowBull ? (useClose ? closeOk and close < f.bottom : low <= f.bottom) : (useClose ? closeOk and close > f.top : high >= f.top)
            if dead
                fvgs.remove(i)
                f_kill(f)

// keep memory bounded — oldest zones recycle first
if fvgs.size() > 400
    FVG old = fvgs.shift()
    box.delete(old.bx)
    label.delete(old.lb)

// float labels beside current price when boxes are extended
if barstate.islast and extendBoxes and showLabels
    for f in fvgs
        if not na(f.lb)
            label.set_x(f.lb, time + lblDist * chartMs)

// ─────────────────────────────── Alerts ───────────────────────────────
alertcondition(sigs.get(0), "Bullish FVG created",  "Bullish FVG created on {{ticker}}")
alertcondition(sigs.get(1), "Bearish FVG created",  "Bearish FVG created on {{ticker}}")
alertcondition(sigs.get(2), "FVG inverted bearish", "Bullish FVG invalidated -> bearish iFVG on {{ticker}}")
alertcondition(sigs.get(3), "FVG inverted bullish", "Bearish FVG invalidated -> bullish iFVG on {{ticker}}")
````
