# Dynamic Premium & Discount Zones [AlgoNorth]

- url: https://www.tradingview.com/script/DQaxJaS0-Dynamic-Premium-Discount-Zones-AlgoNorth/
- type: indicator
- pine_id: PUB;a9af994b62234463801aa1082a34bb0c
- version: 1.0

## Description

Dynamic Premium & Discount Zones

Price is deep in premium. Will it come back to the middle, or keep running? Most tools draw the zones and leave that call to you. This one gives you a number for it, from your own chart.

It splits the live swing range at its midpoint, equilibrium: above is premium, below is discount. Every candle glows back to equilibrium, pink above and cyan below, stronger the deeper price pushes. A gauge beside the last bar shows exactly where price sits in the range. Next to it, a gold figure shows how often price has made it back to equilibrium within 20 bars from the depth zone it is in now, counted from the chart you're on.

Static boxes go stale the moment price breaks a swing. Here the range updates with price on every bar, and every return is measured to the level price actually left from. Load it on the market you trade and see how often its deep zone has actually come back. Next time price stretches to the extreme, you'll know what this chart has done from there before you decide.

🔶 USAGE

🔸 Read the gauge. The gauge beside the last bar is the dealing range drawn to the price scale, premium above and discount below, with the deep bands at each end and a fill from equilibrium to price. The pill on the gauge shows the zone and position: 0% is the range low, 50% is equilibrium, 100% is the range high.

🔸 Read the glow. The glow between every candle and the equilibrium line shows which zone that bar closed in and how deep, so you can scroll back and see the whole history. Faint means near equilibrium, bright means deep in the zone, and bars that close in deep premium or deep discount get a white-hot layer.

🔸 Follow the equilibrium line. It is the 50% line of the range. A haloed dot marks each bar that closes across it.

🔸 Check the gold figure. Beside the gauge, it shows how often price traded back to equilibrium within 20 bars from the depth zone price is in now, with the count. It appears once price is at least a quarter of the way from equilibrium to the range edge.

🔸 Look for the round trips. A gold ◆ marks the bar that closes in the deep zone. A gold dot marks where price traded back to that bar's equilibrium level. A ◆ with no dot stays dimmed, so misses are as visible as returns. Only the latest round trip and the one in progress are kept on the chart.

🔸 Read the panel. The zone and position now, equilibrium and its distance in ATR, and the return rate for the current depth. Full mode lists all four depths.

🔸 Alerts: into premium, into discount, deep premium, deep discount, back to equilibrium.

🔶 DETAILS

🔸 Premium and discount. The dealing range split at its midpoint, equilibrium. Above it is premium, below it is discount. The framing comes from ICT / Smart Money Concepts; this script updates the range with price and puts a number on each zone.

🔸 Dealing range. Latest swing low to latest swing high, where a swing needs 8 bars either side. When price trades beyond an edge, that edge moves with it on the same bar, so price is always inside the range.

🔸 Equilibrium. The midpoint of the range. Smooth mode eases it between levels with a double 6-bar average and keeps it inside the range; Stepped draws the exact midpoint. In Smooth mode only, the zones follow the eased line, so for a few bars after the range changes they can differ from the exact midpoint. Stepped mode has no lag.

🔸 Depth. How far price has closed from equilibrium toward the range edge on its side, from 0 at equilibrium to 1 at the edge. Deep starts at 0.75. The deep line, the heat, the gauge bands and the panel rows all use that one level.

🔸 Depth zones. 0–25%, 25–50%, 50–75% and 75–100% deep. Premium and discount are counted together in each zone.

🔸 Measurement. Each time a bar closes in a new depth zone, the script stores that bar's equilibrium level. A return counts only if price trades back to that stored level within 20 bars. Because the level is fixed at entry, equilibrium drifting toward price during a trend does not count as a return.

🔸 Round trips. One at a time. A trip opens on the first close in the deep zone and ends when price trades back to that bar's equilibrium level or the 20-bar window closes, the same rule as the panel. Trips shorter than 3 bars are not marked.

🔸 Contrast. Every readout is checked against your chart background and switches to a legible colour automatically, on dark, light or grey charts.

🔶 SETTINGS

🔸 Dealing range: Swing length, Equilibrium line, Smoothing. Bars either side of a swing, Smooth or Stepped equilibrium, and how gently Smooth eases to a new midpoint.

🔸 Glow: Glow at candles, Mid layers, Core glow, Deep-zone heat. The strength of each layer, from the base glow to the white-hot layer on deep bars; 0 turns a layer off.

🔸 Detail: Depth contours, Equilibrium crosses, Colour candles by zone, Heat deep candles, Down candles. Colour candles by zone fills candle bodies in the zone colour; wicks and borders keep your chart's colours. The preview shows it on. It is off by default so your own candle colours are kept.

🔸 Round trips: Deep zone from, Minimum trip length, Show the latest round trip, Return window. Where the deep zone starts, the shortest trip that gets marked, and how many bars a return has to reach the stored level, for the marks and the panel alike.

🔸 Gauge: Position gauge, Price leader, Gauge offset, Gauge width. Switch the gauge and the dotted price leader on or off, and set where the gauge sits and how wide it is.

🔸 Panel: Show panel, Panel detail, Position, Text size. Compact or Full, and four corners for when more than one copy is loaded.

🔸 Colours: Premium, Discount, Highlight. Highlight is used for the ◆ marks, the return dots and the figure beside the gauge.

🔶 NOTES

🔸 Every ◆, dot, cross, alert and panel count is set at bar close, never on the forming bar, and nothing is redrawn on past bars. The gauge and the panel's live readings follow price as it moves on the current, unfinished bar.

🔸 The gold figure and panel numbers come from the bars loaded on your chart, so each symbol and timeframe shows its own numbers.

🔸 Candle colouring in the preview is an optional setting.

🔸 The panel's last-bar time is shown in exchange time, which can differ from your chart's display timezone.

🔸 Made for candle and bar charts. Chart types that redraw past bars, such as Renko or Kagi, change the history the counts are built from.

🔶 SUMMARY

A live dealing range, a glow that shows how deep price has pushed, and a gauge with a number behind it. Dynamic Premium & Discount Zones turns "will it come back?" into a question your own chart's history can answer.

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth
//@version=6
indicator("Dynamic Premium & Discount Zones [AlgoNorth]", overlay = true, behind_chart = true, max_boxes_count = 40, max_lines_count = 25, max_labels_count = 20)

// ═══════════════════════ Inputs ═══════════════════════
grpR = "Dealing range"
swLen   = input.int(8, "Swing length", minval = 2, maxval = 50, group = grpR, tooltip = "Bars on each side that make a swing high or low. The dealing range starts from the latest confirmed swing low and swing high, and its edges move out with price whenever price trades beyond them.")
eqStyle = input.string("Smooth", "Equilibrium line", options = ["Smooth", "Stepped"], group = grpR, tooltip = "Smooth eases the 50% line from one level to the next in an even S-curve. Stepped draws the exact 50% of the range: flat while the range holds, stepping when it changes.")
eqLen   = input.int(6, "Smoothing", minval = 2, maxval = 30, group = grpR, tooltip = "How gently the Smooth line eases to a new midpoint. A change in the range takes about twice this many bars to complete. Higher is smoother but trails further behind.")

grpG = "Glow"
glowAmt = input.int(30, "Glow at candles", minval = 0, maxval = 100, group = grpG, tooltip = "Opacity of the translucent base glow where it reaches the candles. It runs to the middle of each candle body, behind the candle, and fades out at the 50% line. Brightness also scales with how deep price is in its zone.")
midAmt  = input.int(10, "Mid layers", minval = 0, maxval = 100, group = grpG, tooltip = "Two translucent layers starting 35% and 65% of the way to the candles, so the glow builds smoothly toward them. 0 turns them off.")
coreAmt = input.int(15, "Core glow", minval = 0, maxval = 100, group = grpG, tooltip = "Lighter layer over the 15% of the glow closest to the candles, so each candle looks lit from behind. 0 turns it off.")
hotAmt  = input.int(20, "Deep-zone heat", minval = 0, maxval = 100, group = grpG, tooltip = "White-hot layer between the deep line and the candle, shown only on bars that close in deep premium or deep discount. 0 turns it off.")

grpD = "Detail"
showCont   = input.bool(true, "Depth contours", group = grpD, tooltip = "Faint lines at 25% and 50% depth and a brighter deep line, drawn only inside the glow, so you can see how far into its zone price has travelled.")
showCross  = input.bool(true, "Equilibrium crosses", group = grpD, tooltip = "A haloed dot on the 50% line on each bar that closes across it. On very low timeframes price crosses often; switch this off if the line looks busy.")
colCandles = input.bool(false, "Colour candles by zone", group = grpD, tooltip = "Colours every candle in the zone it closes in: premium colour above equilibrium, discount colour below. Candle borders and wicks keep your chart's own colours. Off by default, so your own candle colours are kept.")
heatCnd    = input.bool(true, "Heat deep candles", group = grpD, tooltip = "With zone colouring on, candles that close in deep premium or deep discount are drawn in a lighter, white-hot version of the zone colour.")
dnStyle    = input.string("Same colour", "Down candles", options = ["Same colour", "Dimmer"], group = grpD, tooltip = "With zone colouring on: Same colour keeps every candle in the zone colour, Dimmer blends down-candle bodies 30% toward the chart background so direction stays readable.")

grpE = "Round trips"
deepPct = input.int(75, "Deep zone from", minval = 50, maxval = 95, step = 5, group = grpE, tooltip = "How far from equilibrium price must close, as a share of the distance from equilibrium to the range edge on that side, to count as deep premium or deep discount. 75 means the outer quarter of that distance. The deep line, the deep-zone heat, the gauge's deep bands and the panel's depth zones all use this level.")
minTrip = input.int(3, "Minimum trip length", minval = 1, maxval = 50, group = grpE, tooltip = "Round trips that return in fewer than this many bars are not marked, and raise no Back to equilibrium alert either. A trip that expires without returning is always marked, because it ran the whole return window.")
showEx  = input.bool(true, "Show the latest round trip", group = grpE, tooltip = "A ◆ on the bar where price closes in deep premium or discount, and a dot on the bar it trades back to the equilibrium level fixed at the ◆ bar. The dot sits at that fixed level, so after a trend it can sit off the live equilibrium line. If price has not returned to that level within the return window the trip expires: the ◆ stays, dimmed, and no dot is drawn, so misses stay visible as well as returns. Hover either mark for the numbers. Only the latest marked round trip and the one in progress are kept: a trip that returns in fewer than the minimum trip length is never marked, so an earlier marked trip stays on screen. The ◆ and the dot of a trip are drawn on its entry and return bars.")
horiz   = input.int(20, "Return window", minval = 2, maxval = 300, group = grpE, tooltip = "The figure in the Highlight colour beside the gauge shows how often, on this chart, price traded back to the equilibrium level it had on the bar price entered the depth zone it is in now, within this many bars, with the sample count beside it. The level is fixed when price entered the zone, so the equilibrium line drifting toward price does not count as a return. Results are filed only once that happens or the window closes. The figure is hidden while price is within a quarter of the way from equilibrium to the range edge.")

grpK = "Gauge"
showGauge = input.bool(true, "Position gauge", group = grpK, tooltip = "Glass gauge right of the last bar, drawn to the price scale: the dealing range with its premium and discount halves, deep bands, a fill from equilibrium to price, and the live zone and its return rate beside it. The percentage reads 0% at the range low, 50% at equilibrium and 100% at the range high. Redrawn on every tick.")
showLive  = input.bool(true, "Price leader", group = grpK, tooltip = "A glowing dot beside the current candle at the live close and a dotted line from it to the gauge. Redrawn on every tick.")
gOff      = input.int(10, "Gauge offset", minval = 4, maxval = 100, group = grpK, tooltip = "Bars between the last candle and the gauge.")
gW        = input.int(5, "Gauge width", minval = 2, maxval = 30, group = grpK, tooltip = "Width of the gauge in bars.")

grpP = "Panel"
showTbl = input.bool(true, "Show panel", group = grpP, tooltip = "Readout of the range and the return-to-equilibrium statistics. The gauge shows the figure for the zone price is in now; the panel adds the equilibrium distance and, in Full mode, all four depth zones.")
tblMode = input.string("Compact", "Panel detail", options = ["Compact", "Full"], group = grpP, tooltip = "Compact shows the figure for the zone price is in now. Full lists all four depth zones.")
tblPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpP, tooltip = "Panel corner. Use a different corner for each copy if you load the script more than once.")
tblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpP, tooltip = "Panel text size.")

grpCol = "Colours"
colPrem = input.color(#ff1f8f, "Premium", group = grpCol, tooltip = "Glow, candles and gauge above equilibrium.")
colDisc = input.color(#00e5ff, "Discount", group = grpCol, tooltip = "Glow, candles and gauge below equilibrium, and the panel's header bar.")
colHi   = input.color(#ffd23f, "Highlight", group = grpCol, tooltip = "The ◆ marks and the return figure beside the gauge.")

// ═══════════════════════ Dealing range (swings + live edges) ═══════════════════════
ph    = ta.pivothigh(high, swLen, swLen)
pl    = ta.pivotlow(low, swLen, swLen)
winLo = ta.lowest(low, swLen + 1)
winHi = ta.highest(high, swLen + 1)
atr   = ta.atr(14)

var float rTop = na
var float rBot = na
if not na(ph)
    rTop := ph
    if not na(rBot) and rBot >= rTop
        rBot := winLo
if not na(pl)
    rBot := pl
    if not na(rTop) and rTop <= rBot
        rTop := winHi
if not na(rTop) and high > rTop
    rTop := high
if not na(rBot) and low < rBot
    rBot := low

bool  rangeOK  = not na(rTop) and not na(rBot) and rTop > rBot
var int mCount = 0
mCount := rangeOK ? mCount + 1 : 0
bool  hasRange = rangeOK and mCount >= (eqStyle == "Stepped" ? 1 : eqLen * 2)
float rMid     = rangeOK ? (rTop + rBot) / 2 : hl2
float eqSm     = ta.sma(ta.sma(rMid, eqLen), eqLen)
float eqS      = eqStyle == "Stepped" ? rMid : (rangeOK ? math.min(math.max(eqSm, rBot), rTop) : eqSm)
eqPlotStyle    = eqStyle == "Stepped" ? plot.style_steplinebr : plot.style_linebr
bool  inPrem   = hasRange and close >= eqS
float hUp      = hasRange ? math.max(rTop - eqS, 0) : 0.0
float hDn      = hasRange ? math.max(eqS - rBot, 0) : 0.0
float pos      = not hasRange ? na : inPrem ? (hUp > 0 ? 0.5 + 0.5 * (close - eqS) / hUp : 0.5) : (hDn > 0 ? 0.5 - 0.5 * (eqS - close) / hDn : 0.5)
float depth    = not hasRange ? na : math.min(inPrem ? (hUp > 0 ? (close - eqS) / hUp : 0.0) : (hDn > 0 ? (eqS - close) / hDn : 0.0), 1.0)
float kDeep    = deepPct / 100.0
bool  isDeep   = hasRange and depth >= kDeep
color cSide    = inPrem ? colPrem : colDisc
color cHot     = color.from_gradient(35, 0, 100, cSide, #ffffff)
color cLit     = color.from_gradient(25, 0, 100, cSide, #ffffff)
color cClear   = color.new(cSide, 100)
// theme: every readout is measured against the chart background with the WCAG contrast
// formula and swapped for a legible alternative when it falls short, so the script adapts
// to any background rather than to a light/dark flag
const float MIN_CONTRAST = 4.5
const float MIN_PANEL    = 3.0

f_lum(color c) =>
    float r  = color.r(c) / 255.0
    float g  = color.g(c) / 255.0
    float b  = color.b(c) / 255.0
    float rl = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4)
    float gl = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4)
    float bl = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4)
    0.2126 * rl + 0.7152 * gl + 0.0722 * bl

f_contrast(float la, float lb) =>
    (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05)

f_over(color c, float opacity) =>
    color.rgb(color.r(c) * opacity + color.r(chart.bg_color) * (1 - opacity),
      color.g(c) * opacity + color.g(chart.bg_color) * (1 - opacity),
      color.b(c) * opacity + color.b(chart.bg_color) * (1 - opacity))

float bgLum    = f_lum(chart.bg_color)
bool  isLight  = f_contrast(f_lum(#0a0b0d), bgLum) >= f_contrast(f_lum(#ffffff), bgLum)
color pillTxt  = isLight ? #0a0b0d : #ffffff
color fg       = f_contrast(f_lum(chart.fg_color), bgLum) >= MIN_CONTRAST ? chart.fg_color : pillTxt
color markHi   = isLight ? color.from_gradient(80, 0, 100, colHi, #000000) : colHi
color eqTxt    = f_contrast(f_lum(f_over(fg, 0.65)), bgLum) >= MIN_CONTRAST ? color.new(fg, 35) : fg
bool  figLight = f_contrast(f_lum(#6b5200), f_lum(f_over(colHi, 0.70))) > f_contrast(f_lum(colHi), f_lum(f_over(colHi, 0.12)))

// panel cells: the plate is chart.bg_color at the table's 8% transparency, drawn over the
// chart background, so it resolves to chart.bg_color itself. A coloured cell is measured
// against that and stepped toward black until it clears MIN_PANEL, the same way the ◆ is
// darkened for light charts; if no step clears it the cell falls back to pillTxt.
f_cellCol(color c) =>
    color out  = c
    bool  done = f_contrast(f_lum(c), bgLum) >= MIN_PANEL
    for i = 1 to 9
        if not done
            color d = color.from_gradient(i * 10, 0, 100, c, #000000)
            if f_contrast(f_lum(d), bgLum) >= MIN_PANEL
                out  := d
                done := true
    done ? out : pillTxt

// ═══════════════════════ Glow: equilibrium → middle of the candle body (candle covers the join) ═══════════════════════
float bodyMid = (open + close) / 2
float farEnd  = inPrem ? math.max(bodyMid, eqS) : math.min(bodyMid, eqS)
float glowLen = farEnd - eqS
bool  glowOn  = hasRange and math.abs(glowLen) > syminfo.mintick * 0.25
float bright  = hasRange ? 0.45 + 0.55 * math.sqrt(depth) : 0.0
float y35     = eqS + glowLen * 0.35
float y65     = eqS + glowLen * 0.65
float y85     = eqS + glowLen * 0.85

f_tr(int amt) =>
    int(math.round(100 - amt * bright))

color cB = color.new(cSide, f_tr(glowAmt))
color cM = color.new(cSide, f_tr(midAmt))
color cC = color.new(cLit, f_tr(coreAmt))

gBase = plot(glowOn ? eqS : na, "Glow base", color = color(na), style = eqPlotStyle, editable = false, display = display.none)
g35   = plot(glowOn ? y35 : na, "Glow layer 2 anchor", color = color(na), style = eqPlotStyle, editable = false, display = display.none)
g65   = plot(glowOn ? y65 : na, "Glow layer 3 anchor", color = color(na), style = eqPlotStyle, editable = false, display = display.none)
gCore = plot(glowOn ? y85 : na, "Glow core anchor", color = color(na), style = eqPlotStyle, editable = false, display = display.none)
gEnd  = plot(glowOn ? farEnd : na, "Glow end", color = color(na), style = plot.style_linebr, editable = false, display = display.none)
fill(gBase, gEnd, math.max(eqS, farEnd), math.min(eqS, farEnd), inPrem ? cB : cClear, inPrem ? cClear : cB, "Glow", editable = false)
fill(g35, gEnd, math.max(y35, farEnd), math.min(y35, farEnd), inPrem ? cM : cClear, inPrem ? cClear : cM, "Glow layer 2", editable = false)
fill(g65, gEnd, math.max(y65, farEnd), math.min(y65, farEnd), inPrem ? cM : cClear, inPrem ? cClear : cM, "Glow layer 3", editable = false)
fill(gCore, gEnd, math.max(y85, farEnd), math.min(y85, farEnd), inPrem ? cC : cClear, inPrem ? cClear : cC, "Glow core", editable = false)

// ═══════════════════════ Depth contours + deep-zone heat (inside the glow only) ═══════════════════════
float sgn   = inPrem ? 1.0 : -1.0
float hSide = inPrem ? hUp : hDn

f_contour(float k) =>
    float lvl = eqS + sgn * hSide * k
    glowOn and math.abs(lvl - eqS) < math.abs(glowLen) ? lvl : na

float c25 = f_contour(0.25)
float c50 = f_contour(0.50)
float cDp = f_contour(kDeep)

color cH   = color.new(cHot, f_tr(hotAmt))
float cDpH = (glowOn and isDeep) ? eqS + sgn * math.min(hSide * kDeep, math.abs(glowLen)) : na
pDeep = plot(hotAmt > 0 ? cDpH : na, "Deep heat start", color = color(na), style = eqPlotStyle, editable = false, display = display.none)
fill(pDeep, gEnd, math.max(cDpH, farEnd), math.min(cDpH, farEnd), inPrem ? cH : cClear, inPrem ? cClear : cH, "Deep heat", editable = false)

plot(showCont ? c25 : na, "Depth 25%", color = color.new(cLit, 82), linewidth = 1, style = eqPlotStyle, editable = false, display = display.pane)
plot(showCont ? c50 : na, "Depth 50%", color = color.new(cLit, 72), linewidth = 1, style = eqPlotStyle, editable = false, display = display.pane)
plot(showCont ? cDp : na, "Deep line", color = color.new(cHot, 40), linewidth = 1, style = eqPlotStyle, editable = false, display = display.pane)

// ═══════════════════════ Candles by zone (optional) ═══════════════════════
color cCnd   = heatCnd and isDeep ? cHot : cSide
color cDnBar = dnStyle == "Dimmer" ? color.from_gradient(30, 0, 100, cCnd, chart.bg_color) : cCnd
barcolor(colCandles and hasRange ? (close >= open ? cCnd : cDnBar) : na, title = "Zone candles", editable = false)

// ═══════════════════════ Equilibrium ═══════════════════════
plot(hasRange ? eqS : na, "Equilibrium zone glow", color = color.new(cSide, 85), linewidth = 10, style = eqPlotStyle, editable = false, display = display.pane)
plot(hasRange ? eqS : na, "Equilibrium glow", color = color.new(fg, 78), linewidth = 4, style = eqPlotStyle, editable = false, display = display.pane)
plot(hasRange ? eqS : na, "Equilibrium", color = fg, linewidth = 2, style = eqPlotStyle, display = display.pane + display.data_window + display.status_line)

bool xUp    = ta.crossover(close, eqS)
bool xDn    = ta.crossunder(close, eqS)
bool xEq    = ta.cross(close, eqS)
bool xShown = showCross and hasRange and xEq and barstate.isconfirmed
plot(xShown ? eqS : na, "Cross halo", color = color.new(fg, 70), linewidth = 10, style = plot.style_circles, editable = false, display = display.pane)
plot(xShown ? eqS : na, "Equilibrium cross", color = fg, linewidth = 4, style = plot.style_circles, editable = false, display = display.pane)

// ═══════════════════════ Return rate and round trips (bar close only) ═══════════════════════
// every sample and every round trip stores the equilibrium level of the bar it started on;
// a return means price traded back to that fixed level, so the line drifting toward price
// does not count
type Samp
    int   bar
    int   side
    int   bucket
    float target

var array<Samp> pend       = array.new<Samp>()
var array<int>  hitN       = array.new<int>(4, 0)
var array<int>  totN       = array.new<int>(4, 0)
var int         prevBucket = -1
var bool        armed      = true
var int         entBar     = na
var int         entSide    = 0
var float       entEq      = na
var label       liveDia    = na
var label       exDia      = na
var label       exDot      = na

f_bucket(float d) =>
    d < kDeep / 3 ? 0 : d < kDeep * 2 / 3 ? 1 : d < kDeep ? 2 : 3

f_bucketTxt(int k) =>
    switch k
        0 => "0–" + str.tostring(math.round(deepPct / 3.0)) + "% deep"
        1 => str.tostring(math.round(deepPct / 3.0)) + "–" + str.tostring(math.round(deepPct * 2 / 3.0)) + "% deep"
        2 => str.tostring(math.round(deepPct * 2 / 3.0)) + "–" + str.tostring(deepPct) + "% deep"
        => str.tostring(deepPct) + "–100% deep"

f_rate(int k) =>
    int n = totN.get(k)
    n > 0 ? str.tostring(math.round(100.0 * hitN.get(k) / n)) + "% · n " + str.tostring(n) : "—"

bool aDeepP = false
bool aDeepD = false
bool aBack  = false

if barstate.isconfirmed and hasRange
    // return-to-equilibrium rate, filed per depth zone, against the level fixed at entry
    if pend.size() > 0
        for i = pend.size() - 1 to 0
            Samp s   = pend.get(i)
            bool hit = s.side == 1 ? low <= s.target : high >= s.target
            if hit or bar_index - s.bar >= horiz
                totN.set(s.bucket, totN.get(s.bucket) + 1)
                if hit
                    hitN.set(s.bucket, hitN.get(s.bucket) + 1)
                pend.remove(i)
    int bk = f_bucket(depth)
    if bk != prevBucket
        pend.push(Samp.new(bar_index, inPrem ? 1 : -1, bk, eqS))
    prevBucket := bk

    // round trips: an open trip is resolved first, so a bar that closes a trip can also open
    // the next one; a trip ends either by trading back to the equilibrium level fixed at the
    // ◆ bar, or by expiring on the same return window as the samples above
    if not armed
        bool touch   = entSide == 1 ? low <= entEq : high >= entEq
        bool expired = not touch and bar_index - entBar >= horiz
        if touch or expired
            int tripLen = bar_index - entBar
            armed := true
            aBack := touch and tripLen >= minTrip
            if showEx
                if touch and tripLen >= minTrip
                    if not na(exDia)
                        exDia.delete()
                    if not na(exDot)
                        exDot.delete()
                    exDia := liveDia
                    exDot := label.new(bar_index, entEq, "", style = label.style_circle, color = colHi, size = size.tiny, tooltip = "Back to " + str.tostring(entEq, format.mintick) + ", the equilibrium at the ◆, in " + str.tostring(tripLen) + (tripLen == 1 ? " bar" : " bars"))
                else if expired
                    if not na(exDia)
                        exDia.delete()
                    if not na(exDot)
                        exDot.delete()
                    exDia := liveDia
                    exDot := na
                    if not na(exDia)
                        exDia.set_textcolor(color.new(markHi, 50))
                        exDia.set_tooltip("No return to " + str.tostring(entEq, format.mintick) + " within " + str.tostring(horiz) + " bars")
                else if not na(liveDia)
                    liveDia.delete()
            liveDia := na
    if armed and isDeep
        armed   := false
        entBar  := bar_index
        entSide := inPrem ? 1 : -1
        entEq   := eqS
        aDeepP  := inPrem
        aDeepD  := not inPrem
        if showEx
            liveDia := label.new(bar_index, inPrem ? high : low, "◆", style = inPrem ? label.style_label_down : label.style_label_up, color = color(na), textcolor = markHi, size = size.large, tooltip = (inPrem ? "Deep premium · " : "Deep discount · ") + str.tostring(math.round(pos * 100)) + "% of the range · equilibrium " + str.tostring(eqS, format.mintick))

// ═══════════════════════ Price leader, gauge & readouts ═══════════════════════
// readout spacing, as a share of the dealing-range span: a label is drawn only when it
// clears the price needle and the return figure, and the figure sits this far from the needle
const float CLR_PRICE        = 0.14
const float CLR_OTHER        = 0.12
const float FIG_OFF          = 0.13
const float FIG_EQ_GAP       = 0.05
const float FIG_MIN_DEPTH    = 0.25
const int   GAUGE_FILL_STEPS = 20

f_clear(float y, float yO, float sp) =>
    math.abs(y - close) > CLR_PRICE * sp and (na(yO) or math.abs(y - yO) > CLR_OTHER * sp)

var array<float> gTicks  = array.new<float>()
var array<box>   gBoxes  = array.new<box>()
var array<line>  gLines  = array.new<line>()
var array<label> gLabels = array.new<label>()

if barstate.islast
    for b in gBoxes
        b.delete()
    for l in gLines
        l.delete()
    for t in gLabels
        t.delete()
    gBoxes.clear()
    gLines.clear()
    gLabels.clear()
    if hasRange
        int gx  = bar_index + gOff
        int gx2 = gx + gW
        int bx  = bar_index + 1

        // price leader: glowing dot at the live close, dotted line into the gauge
        if showLive
            if showGauge
                gLines.push(line.new(bx, close, gx - 1, close, color = color.new(cSide, 45), style = line.style_dotted, width = 1))
            gLabels.push(label.new(bx, close, "", style = label.style_circle, color = color.new(cSide, 70), size = size.small))
            gLabels.push(label.new(bx, close, "", style = label.style_circle, color = cHot, size = size.tiny, tooltip = (inPrem ? "Premium · " : "Discount · ") + str.tostring(math.round(pos * 100)) + "% of the range · " + str.tostring(math.abs(close - eqS) / atr, "0.0") + " ATR from equilibrium"))

        if showGauge
            float span = rTop - rBot
            float yDP  = eqS + hUp * kDeep
            float yDD  = eqS - hDn * kDeep

            // glass track: zone tints, stronger in the deep bands
            gBoxes.push(box.new(gx, rTop, gx2, eqS, border_color = color(na), border_width = 0, bgcolor = color.new(colPrem, 87)))
            gBoxes.push(box.new(gx, eqS, gx2, rBot, border_color = color(na), border_width = 0, bgcolor = color.new(colDisc, 87)))
            gBoxes.push(box.new(gx, rTop, gx2, yDP, border_color = color(na), border_width = 0, bgcolor = color.new(colPrem, 74)))
            gBoxes.push(box.new(gx, yDD, gx2, rBot, border_color = color(na), border_width = 0, bgcolor = color.new(colDisc, 74)))

            // live fill: fades in from equilibrium to near-solid at price, inside the track only
            float dist = close - eqS
            if math.abs(dist) > syminfo.mintick * 0.25
                for i = 0 to GAUGE_FILL_STEPS - 1
                    float a  = i * 1.0 / GAUGE_FILL_STEPS
                    float b  = (i + 1) * 1.0 / GAUGE_FILL_STEPS
                    // transparency runs 90 at equilibrium to 5 at price, eased by a 1.6 power curve
                    int   tf = int(math.round(90 - 85 * math.pow(b, 1.6)))
                    gBoxes.push(box.new(gx, math.max(eqS + dist * a, eqS + dist * b), gx2, math.min(eqS + dist * a, eqS + dist * b), border_color = color(na), border_width = 0, bgcolor = color.new(cSide, tf)))

            // frame and coloured caps
            gBoxes.push(box.new(gx, rTop, gx2, rBot, border_color = color.new(fg, 70), border_width = 1, bgcolor = color(na)))
            gLines.push(line.new(gx, rTop, gx2, rTop, color = colPrem, width = 2))
            gLines.push(line.new(gx, rBot, gx2, rBot, color = colDisc, width = 2))

            // scale ticks at 25%, 50% and deep on each side
            gTicks.clear()
            gTicks.push(0.25)
            gTicks.push(0.5)
            if kDeep != 0.5
                gTicks.push(kDeep)
            for k in gTicks
                bool dk = k == kDeep
                gLines.push(line.new(gx2, eqS + hUp * k, gx2 + 1, eqS + hUp * k, color = dk ? color.new(colPrem, 20) : color.new(fg, 65), width = 1))
                gLines.push(line.new(gx2, eqS - hDn * k, gx2 + 1, eqS - hDn * k, color = dk ? color.new(colDisc, 20) : color.new(fg, 65), width = 1))

            // equilibrium and the live needle
            gLines.push(line.new(gx - 1, eqS, gx2 + 1, eqS, color = color.new(fg, 82), width = 6))
            gLines.push(line.new(gx - 1, eqS, gx2 + 1, eqS, color = fg, width = 2))
            gLines.push(line.new(gx - 1, close, gx2 + 1, close, color = color.new(cSide, 65), width = 7))
            gLines.push(line.new(gx - 1, close, gx2 + 1, close, color = cHot, width = 2))

            // readouts: zone at the needle, return rate beside it, EQ and tagged range edges when clear of both
            gLabels.push(label.new(gx2 + 2, close, (inPrem ? "PREMIUM  " : "DISCOUNT  ") + str.tostring(math.round(pos * 100)) + "%", style = label.style_label_left, color = color.new(cSide, 70), textcolor = pillTxt, size = size.normal, text_formatting = text.format_bold))

            float yRet  = na
            int   bk    = f_bucket(depth)
            int   n     = totN.get(bk)
            if depth >= FIG_MIN_DEPTH and n > 0
                yRet := close - sgn * FIG_OFF * span
                if math.abs(yRet - eqS) < FIG_EQ_GAP * span
                    yRet := close + sgn * FIG_OFF * span
                gLabels.push(label.new(gx2 + 2, yRet, str.tostring(math.round(100.0 * hitN.get(bk) / n)) + "% back to EQ within " + str.tostring(horiz) + " bars · n " + str.tostring(n), style = label.style_label_left, color = color.new(colHi, figLight ? 30 : 88), textcolor = figLight ? #6b5200 : colHi, size = size.small, tooltip = "How often, on this chart, price traded back to the equilibrium level it had when price entered this depth zone, within " + str.tostring(horiz) + " bars · n " + str.tostring(n)))

            float yEq = na
            if f_clear(eqS, yRet, span)
                yEq := eqS
                gLabels.push(label.new(gx2 + 2, eqS, "EQ  " + str.tostring(eqS, format.mintick), style = label.style_label_left, color = color(na), textcolor = eqTxt, size = size.small))
            if f_clear(rTop, yRet, span) and (na(yEq) or math.abs(rTop - yEq) > CLR_OTHER * span)
                gLabels.push(label.new(gx2 + 2, rTop, "HIGH  " + str.tostring(rTop, format.mintick), style = label.style_label_left, color = color.new(colPrem, 70), textcolor = pillTxt, size = size.small, text_formatting = text.format_bold))
            if f_clear(rBot, yRet, span) and (na(yEq) or math.abs(rBot - yEq) > CLR_OTHER * span)
                gLabels.push(label.new(gx2 + 2, rBot, "LOW  " + str.tostring(rBot, format.mintick), style = label.style_label_left, color = color.new(colDisc, 70), textcolor = pillTxt, size = size.small, text_formatting = text.format_bold))

// ═══════════════════════ Panel (optional) ═══════════════════════
tPos = switch tblPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right
tSz = switch tblSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table tbl = na

f_row(int r, string k, string v, color vc) =>
    tbl.cell(0, r, k, text_color = eqTxt, text_size = tSz, text_halign = text.align_left)
    tbl.cell(1, r, v, text_color = vc, text_size = tSz, text_halign = text.align_right)

if showTbl and barstate.islast
    if na(tbl)
        tbl := table.new(tPos, 2, 8, bgcolor = color.new(chart.bg_color, 8), border_color = color.new(fg, 85), border_width = 1, frame_color = color.new(fg, 70), frame_width = 1)
    tbl.clear(0, 0, 1, 7)
    tbl.cell(0, 0, "DYNAMIC P&D ZONES · swing " + str.tostring(swLen) + " · " + str.lower(eqStyle) + " · " + str.tostring(horiz) + " bars", bgcolor = colDisc, text_color = f_contrast(f_lum(#0a0b0d), f_lum(colDisc)) >= f_contrast(f_lum(#ffffff), f_lum(colDisc)) ? #0a0b0d : #ffffff, text_size = tSz, text_halign = text.align_left)
    tbl.merge_cells(0, 0, 1, 0)
    if hasRange
        int curBk = f_bucket(depth)
        f_row(1, "Zone", (inPrem ? "Premium " : "Discount ") + str.tostring(math.round(pos * 100)) + "%", f_cellCol(cSide))
        f_row(2, "Equilibrium", str.tostring(eqS, format.mintick) + " · " + str.tostring(math.abs(close - eqS) / atr, "0.0") + " ATR", fg)
        if tblMode == "Compact"
            f_row(3, "Back to EQ ≤" + str.tostring(horiz), f_rate(curBk), f_cellCol(colHi))
            f_row(4, "Bars · last", str.tostring(bar_index + 1) + " · " + str.format_time(time, "MM-dd HH:mm", syminfo.timezone), eqTxt)
        else
            for k = 0 to 3
                f_row(3 + k, (k == curBk ? "▶ " : "") + f_bucketTxt(k), f_rate(k), k == curBk ? f_cellCol(colHi) : fg)
            f_row(7, "Bars · last", str.tostring(bar_index + 1) + " · " + str.format_time(time, "MM-dd HH:mm", syminfo.timezone), eqTxt)
    else
        f_row(1, "Zone", "waiting for swings", fg)

// ═══════════════════════ Alerts ═══════════════════════
alertcondition(hasRange and barstate.isconfirmed and xUp, "Into premium", "{{ticker}} {{interval}}: price closed above equilibrium into premium")
alertcondition(hasRange and barstate.isconfirmed and xDn, "Into discount", "{{ticker}} {{interval}}: price closed below equilibrium into discount")
alertcondition(aDeepP, "Deep premium", "{{ticker}} {{interval}}: price closed in deep premium")
alertcondition(aDeepD, "Deep discount", "{{ticker}} {{interval}}: price closed in deep discount")
alertcondition(aBack, "Back to equilibrium", "{{ticker}} {{interval}}: price traded back to the equilibrium level set when price entered the deep zone")
````
