# EMA Trend Stack and Reactions 9 21 50 200

- url: https://www.tradingview.com/script/QjUiNpwU-EMA-Trend-Stack-and-Reactions-9-21-50-200/
- type: indicator
- pine_id: PUB;71894063b1004bef80fd4b28b0c0c74b
- version: 1.0

## Description

This indicator shows the EMA measurements for the 9,21,50,200 trend lines including instances where the lines signaled a change in direction or momentum shift.

## Source Code

````pine
//@version=6
indicator("EMA Trend Stack + Reactions", shorttitle="EMA Trend+", overlay=true, max_labels_count=500)

// ============================== INPUTS ==============================
src = input.source(close, "Source", group="Source")

grpL = "EMA Lengths"
len1 = input.int(9,   "EMA 1 (Fast)", minval=1, group=grpL)
len2 = input.int(21,  "EMA 2",        minval=1, group=grpL)
len3 = input.int(50,  "EMA 3",        minval=1, group=grpL)
len4 = input.int(200, "EMA 4 (Slow)", minval=1, group=grpL)

grpV = "Visibility"
show1 = input.bool(true, "Show EMA 1 (9)",   group=grpV)
show2 = input.bool(true, "Show EMA 2 (21)",  group=grpV)
show3 = input.bool(true, "Show EMA 3 (50)",  group=grpV)
show4 = input.bool(true, "Show EMA 4 (200)", group=grpV)

grpE = "Trend Extras"
showCloud = input.bool(true, "Fast cloud (EMA1–EMA2)",           group=grpE)
showCross = input.bool(true, "Golden / Death cross (EMA3×EMA4)", group=grpE)
showStack = input.bool(true, "Trend-stack label",                group=grpE)

grpR = "Reactions & Moves"
showReact = input.bool(true,  "Highlight EMA reactions",        group=grpR)
reactSel  = input.string("50", "Reaction EMA", options=["9","21","50","200"], group=grpR)
tolPct    = input.float(0.1,  "Touch tolerance %", minval=0.0, step=0.05, group=grpR)
useSlope  = input.bool(true,  "Require EMA slope agrees",       group=grpR)
showSwing = input.bool(true,  "Label swing-leg % moves",        group=grpR)
pivLen    = input.int(5,      "Swing sensitivity", minval=1,    group=grpR)
showTable = input.bool(true,  "Show % distance table",          group=grpR)

// =========================== CALCULATIONS ===========================
ema1 = ta.ema(src, len1)
ema2 = ta.ema(src, len2)
ema3 = ta.ema(src, len3)
ema4 = ta.ema(src, len4)

// ============================== PLOTS ===============================
p1 = plot(show1 ? ema1 : na, "EMA 1", color=color.new(#ff5252, 0), linewidth=2)
p2 = plot(show2 ? ema2 : na, "EMA 2", color=color.new(#ffb74d, 0), linewidth=2)
p3 = plot(show3 ? ema3 : na, "EMA 3", color=color.new(#42a5f5, 0), linewidth=2)
p4 = plot(show4 ? ema4 : na, "EMA 4", color=color.new(#7e57c2, 0), linewidth=3)

cloudCol = ema1 >= ema2 ? color.new(color.green, 85) : color.new(color.red, 85)
fill(p1, p2, color = showCloud ? cloudCol : na, title="Fast Cloud")

golden = ta.crossover(ema3, ema4)
death  = ta.crossunder(ema3, ema4)
plotshape(showCross and golden ? ema4 : na, title="Golden Cross", style=shape.triangleup,
     location=location.absolute, color=color.new(color.green, 0), size=size.small, text="Golden")
plotshape(showCross and death ? ema4 : na, title="Death Cross", style=shape.triangledown,
     location=location.absolute, color=color.new(color.red, 0), size=size.small, text="Death")

bullStack = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearStack = ema1 < ema2 and ema2 < ema3 and ema3 < ema4
stackTxt  = bullStack ? "▲ Full Bull Stack" : bearStack ? "▼ Full Bear Stack" : "↔ Mixed / Transition"
stackCol  = bullStack ? color.green : bearStack ? color.red : color.gray
var label stackLbl = na
if showStack and barstate.islast
    label.delete(stackLbl)
    stackLbl := label.new(bar_index, ema1, stackTxt, style=label.style_label_left,
         color=color.new(stackCol, 20), textcolor=color.white, size=size.normal)

// =========================== REACTIONS ==============================
// Pick which EMA acts as the support/resistance line to watch.
reactEma = reactSel == "9" ? ema1 : reactSel == "21" ? ema2 : reactSel == "50" ? ema3 : ema4
tol      = tolPct / 100.0
emaUp    = reactEma > reactEma[1]
emaDn    = reactEma < reactEma[1]

// Support held: wick into/through the EMA, close back above, bullish bar.
bounceUp = low  <= reactEma * (1 + tol) and close > reactEma and close > open and (not useSlope or emaUp)
// Resistance rejected: wick up to the EMA, close back below, bearish bar.
bounceDn = high >= reactEma * (1 - tol) and close < reactEma and close < open and (not useSlope or emaDn)

plotshape(showReact and bounceUp ? reactEma : na, title="Support Reaction", style=shape.triangleup,
     location=location.absolute, color=color.new(#26a69a, 0), size=size.tiny)
plotshape(showReact and bounceDn ? reactEma : na, title="Resistance Reaction", style=shape.triangledown,
     location=location.absolute, color=color.new(#ef5350, 0), size=size.tiny)
bgcolor(showReact and bounceUp ? color.new(#26a69a, 90) : showReact and bounceDn ? color.new(#ef5350, 90) : na)

// ========================= SWING-LEG % MOVE =========================
// Pivots, then % change from one confirmed pivot to the next alternating one.
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)
var float lastPx = na
var int   lastTy = 0   // 1 = last pivot was a high, -1 = a low

f_pct(a, b) => (a - b) / b * 100.0
f_sign(x)   => (x >= 0 ? "+" : "") + str.tostring(x, "#.0") + "%"

if showSwing and not na(ph)
    p = high[pivLen]
    if na(lastPx)
        lastPx := p
        lastTy := 1
    else if lastTy == 1
        lastPx := math.max(lastPx, p)        // consecutive highs: keep the higher
    else
        pct = f_pct(p, lastPx)
        label.new(bar_index[pivLen], p, f_sign(pct), style=label.style_label_down,
             color=color.new(color.green, 25), textcolor=color.white, size=size.small)
        lastPx := p
        lastTy := 1

if showSwing and not na(pl)
    p = low[pivLen]
    if na(lastPx)
        lastPx := p
        lastTy := -1
    else if lastTy == -1
        lastPx := math.min(lastPx, p)        // consecutive lows: keep the lower
    else
        pct = f_pct(p, lastPx)
        label.new(bar_index[pivLen], p, f_sign(pct), style=label.style_label_up,
             color=color.new(color.red, 25), textcolor=color.white, size=size.small)
        lastPx := p
        lastTy := -1

// ======================= % DISTANCE TABLE ===========================
var table t = table.new(position.top_right, 2, 5, border_width=1)
f_cell(row, name, e) =>
    d = f_pct(close, e)
    table.cell(t, 0, row, name, text_color=color.white, text_size=size.small)
    table.cell(t, 1, row, f_sign(d), text_size=size.small,
         text_color=color.white, bgcolor=d >= 0 ? color.new(color.green, 60) : color.new(color.red, 60))
if showTable and barstate.islast
    table.cell(t, 0, 0, "EMA", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, "% from price", text_color=color.gray, text_size=size.small)
    f_cell(1, "9",   ema1)
    f_cell(2, "21",  ema2)
    f_cell(3, "50",  ema3)
    f_cell(4, "200", ema4)

// ============================== ALERTS ==============================
alertcondition(golden,   "Golden Cross (50/200)", "EMA50 crossed above EMA200")
alertcondition(death,    "Death Cross (50/200)",  "EMA50 crossed below EMA200")
alertcondition(bounceUp, "EMA Support Reaction",  "Price bounced off the reaction EMA")
alertcondition(bounceDn, "EMA Resistance Reaction","Price rejected at the reaction EMA")
````
