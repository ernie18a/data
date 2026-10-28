# Pivot Premium Suite Nicolau Edition

- url: https://www.tradingview.com/script/Gdskfumv/
- type: indicator
- pine_id: PUB;327fac36394b40a0a68470a07c14eb38
- version: 2.0

## Description

PivotPro Nicolau — Pivot Points + SuperTrend + EMA with the “Displacement” option

A professional all-in-one indicator combining three powerful technical 
analysis tools into a single, clean, and highly configurable solution.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 1. ADVANCED PIVOT POINTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Calculates and displays Pivot Points with full customization:

- Two calculation methods: Traditional and Fibonacci
- Configurable timeframe: Daily, Weekly, Monthly or Yearly
- Choose how many periods to display (current + previous)
- Labels positioned on Left or Right side of each line
- Individual color control for each level (P, R1, R2, R3, S1, S2, S3)
- Labels follow the line edge automatically — no overlap
- Alerts for price crossing any pivot level

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 2. PIVOT POINT SUPERTREND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A unique SuperTrend implementation that uses Pivot Highs and Lows 
as its center line instead of the traditional midpoint — making it 
more reactive to actual market structure:

- ATR-based dynamic bands calculated from pivot-weighted center
- Buy/Sell signals rendered as plotshape (independent from labels)
- Optional Support/Resistance circles from pivot points
- Optional center line display
- Alerts for trend changes and Buy/Sell signals

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 3. EMA SUITE WITH SHIFT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Three fully configurable Exponential Moving Averages with an 
exclusive displacement feature:

- EMA 9, EMA 21, EMA 200 — all periods configurable
- Individual color for each EMA
- Each EMA has its own shift toggle and period input
- Positive shift = forward displacement (future projection)
- Negative shift = backward displacement (historical alignment)
- Visual crossover marker between EMA 9 and EMA 21

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ KEY FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Pivot numbers stay visible even when chart objects are hidden
- Buy/Sell labels are independent from Pivot labels
- All colors individually configurable
- Clean, non-overlapping label system
- Full alert support for all signals

Designed for traders who need precision, clarity and full control 
over their chart without visual clutter.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Fabricio Nicolau

//@version=6
indicator(title="Pivot Premium Suite — Nicolau Edition", shorttitle="PivotPro", overlay=true, max_lines_count=500, max_labels_count=500)
//Charts Update
//==================================================
// SEÇÃO 1: PIVOT POINTS AVANÇADO1
//==================================================

is_newbar(res) =>
    bool ch = false
    if res == 'Y'
        t = year(time('D'))
        ch := ta.change(t) != 0
    else
        t = time(res)
        ch := ta.change(t) != 0
    ch

nround(x) =>
    n = x < 10 ? 3 : x < 100 ? 2 : x < 1000 ? 1 : 0
    math.round(x * math.pow(10, n)) / math.pow(10, n)

//--------------------------------------------------
// INPUTS - PIVOT POINTS
//--------------------------------------------------
pp_period       = input.string("Day", "Period", options=["Day", "Week", "Month", "Year"], group="Pivot Points")
pp_type         = input.string("Traditional", "Pivot Type", options=["Traditional", "Fibonacci"], group="Pivot Points")
periods_to_show = input.int(3, "Períodos para mostrar", minval=1, maxval=20, group="Pivot Points")
show_labels     = input.bool(true,  "Mostrar Labels (P, R1, S1...)?", group="Pivot Points")
show_values     = input.bool(true,  "Mostrar Valores?", group="Pivot Points")
label_side      = input.string("Right", "Posição dos Labels", options=["Left", "Right"], group="Pivot Points")
label_color     = input.color(color.rgb(64, 73, 126), "Label Color", group="Pivot Points")

color_P  = input.color(color.rgb(255, 235, 59),  "Cor P",  group="Cores das Linhas Pivot", inline="P")
color_R1 = input.color(color.rgb(76, 175, 80),   "Cor R1", group="Cores das Linhas Pivot", inline="R1")
color_R2 = input.color(color.rgb(139, 195, 74),  "Cor R2", group="Cores das Linhas Pivot", inline="R2")
color_R3 = input.color(color.rgb(205, 220, 57),  "Cor R3", group="Cores das Linhas Pivot", inline="R3")
color_S1 = input.color(color.rgb(244, 67, 54),   "Cor S1", group="Cores das Linhas Pivot", inline="S1")
color_S2 = input.color(color.rgb(229, 115, 115), "Cor S2", group="Cores das Linhas Pivot", inline="S2")
color_S3 = input.color(color.rgb(239, 154, 154), "Cor S3", group="Cores das Linhas Pivot", inline="S3")

pp_res = pp_period == "Day" ? "D" : pp_period == "Week" ? "W" : pp_period == "Month" ? "M" : "Y"

//--------------------------------------------------
// INPUTS - EMAs
//--------------------------------------------------
ema9Len       = input.int(9,   "EMA 9 — Período",   minval=1, group="Médias Móveis Exponenciais", inline="ema9")
ema9Color     = input.color(#FF6D00, "",             group="Médias Móveis Exponenciais", inline="ema9")
ema9Shift     = input.bool(false, "Deslocar EMA 9?", group="Médias Móveis Exponenciais", inline="ema9shift")
ema9ShiftVal  = input.int(0, "Períodos",             group="Médias Móveis Exponenciais", inline="ema9shift", minval=-500, maxval=500)

ema21Len      = input.int(21,  "EMA 21 — Período",   minval=1, group="Médias Móveis Exponenciais", inline="ema21")
ema21Color    = input.color(#43A047, "",              group="Médias Móveis Exponenciais", inline="ema21")
ema21Shift    = input.bool(false, "Deslocar EMA 21?", group="Médias Móveis Exponenciais", inline="ema21shift")
ema21ShiftVal = input.int(0, "Períodos",              group="Médias Móveis Exponenciais", inline="ema21shift", minval=-500, maxval=500)

ema200Len      = input.int(200, "EMA 200 — Período",   minval=1, group="Médias Móveis Exponenciais", inline="ema200")
ema200Color    = input.color(#ffffff, "",               group="Médias Móveis Exponenciais", inline="ema200")
showEma200     = input.bool(true, "Mostrar EMA 200",   group="Médias Móveis Exponenciais", inline="ema200show")
ema200Shift    = input.bool(false, "Deslocar EMA 200?", group="Médias Móveis Exponenciais", inline="ema200shift")
ema200ShiftVal = input.int(0, "Períodos",               group="Médias Móveis Exponenciais", inline="ema200shift", minval=-500, maxval=500)

//--------------------------------------------------
// HLC DO PERÍODO
//--------------------------------------------------
var float high_cur = na
high_cur := is_newbar(pp_res) ? high : math.max(high_cur[1], high)
var float phigh = na
phigh := is_newbar(pp_res) ? high_cur[1] : phigh[1]

var float low_cur = na
low_cur := is_newbar(pp_res) ? low : math.min(low_cur[1], low)
var float plow = na
plow := is_newbar(pp_res) ? low_cur[1] : plow[1]

var float pclose = na
pclose := is_newbar(pp_res) ? close[1] : pclose[1]

//--------------------------------------------------
// CÁLCULO PIVOT
//--------------------------------------------------
vPP      = (phigh + plow + pclose) / 3
pp_range = phigh - plow

vR1 = pp_type == "Traditional" ? (2 * vPP) - plow        : vPP + 0.382 * pp_range
vS1 = pp_type == "Traditional" ? (2 * vPP) - phigh       : vPP - 0.382 * pp_range
vR2 = pp_type == "Traditional" ? vPP + pp_range           : vPP + 0.618 * pp_range
vS2 = pp_type == "Traditional" ? vPP - pp_range           : vPP - 0.618 * pp_range
vR3 = pp_type == "Traditional" ? phigh + 2*(vPP - plow)  : vPP + 1.000 * pp_range
vS3 = pp_type == "Traditional" ? plow  - 2*(phigh - vPP) : vPP - 1.000 * pp_range

//--------------------------------------------------
// ESTRUTURA DE DADOS — PERÍODO
//--------------------------------------------------
type PivotPeriod
    int   startBar
    int   endBar
    float pp
    float r1
    float r2
    float r3
    float s1
    float s2
    float s3
    line  lPP
    line  lR1
    line  lR2
    line  lR3
    line  lS1
    line  lS2
    line  lS3
    label labPP
    label labR1
    label labR2
    label labR3
    label labS1
    label labS2
    label labS3

var array<PivotPeriod> periods = array.new<PivotPeriod>()

//--------------------------------------------------
// FUNÇÕES AUXILIARES
//--------------------------------------------------
makeLine(int x1, float y, color c) =>
    line.new(x1, y, x1, y, color=c, width=1)

makeLabel(int x, float y, string txt, color c, string side) =>
    labelStyle = side == "Right" ? label.style_label_left : label.style_label_right
    label.new(x, y, txt, style=labelStyle, color=label_color, textcolor=color.white, size=size.small)

buildLabelText(string tag, float val) =>
    (show_labels and show_values) ? tag + " " + str.tostring(nround(val)) :
     show_labels ? tag : str.tostring(nround(val))

//--------------------------------------------------
// LÓGICA PRINCIPAL — NOVO PERÍODO
//--------------------------------------------------
if is_newbar(pp_res) and not na(phigh) and not na(plow)
    // Fecha período anterior
    if array.size(periods) > 0
        prev = array.get(periods, array.size(periods) - 1)
        prev.endBar := bar_index - 1
        line.set_x2(prev.lPP, bar_index - 1)
        line.set_x2(prev.lR1, bar_index - 1)
        line.set_x2(prev.lR2, bar_index - 1)
        line.set_x2(prev.lR3, bar_index - 1)
        line.set_x2(prev.lS1, bar_index - 1)
        line.set_x2(prev.lS2, bar_index - 1)
        line.set_x2(prev.lS3, bar_index - 1)
        // Move label para o final da linha
        if show_labels or show_values
            lx = label_side == "Right" ? bar_index - 1 : prev.startBar
            label.set_x(prev.labPP, lx)
            label.set_x(prev.labR1, lx)
            label.set_x(prev.labR2, lx)
            label.set_x(prev.labR3, lx)
            label.set_x(prev.labS1, lx)
            label.set_x(prev.labS2, lx)
            label.set_x(prev.labS3, lx)

    // Remove períodos excedentes
    while array.size(periods) >= periods_to_show
        old = array.shift(periods)
        line.delete(old.lPP)
        line.delete(old.lR1)
        line.delete(old.lR2)
        line.delete(old.lR3)
        line.delete(old.lS1)
        line.delete(old.lS2)
        line.delete(old.lS3)
        label.delete(old.labPP)
        label.delete(old.labR1)
        label.delete(old.labR2)
        label.delete(old.labR3)
        label.delete(old.labS1)
        label.delete(old.labS2)
        label.delete(old.labS3)

    // Cria novo período
    lx = label_side == "Right" ? bar_index : bar_index
    newPeriod = PivotPeriod.new(
         startBar = bar_index,
         endBar   = bar_index,
         pp = vPP, r1 = vR1, r2 = vR2, r3 = vR3,
         s1 = vS1, s2 = vS2, s3 = vS3,
         lPP = makeLine(bar_index, vPP, color_P),
         lR1 = makeLine(bar_index, vR1, color_R1),
         lR2 = makeLine(bar_index, vR2, color_R2),
         lR3 = makeLine(bar_index, vR3, color_R3),
         lS1 = makeLine(bar_index, vS1, color_S1),
         lS2 = makeLine(bar_index, vS2, color_S2),
         lS3 = makeLine(bar_index, vS3, color_S3),
         labPP = (show_labels or show_values) ? makeLabel(lx, vPP, buildLabelText("P",  vPP), color_P,  label_side) : label.new(na, na),
         labR1 = (show_labels or show_values) ? makeLabel(lx, vR1, buildLabelText("R1", vR1), color_R1, label_side) : label.new(na, na),
         labR2 = (show_labels or show_values) ? makeLabel(lx, vR2, buildLabelText("R2", vR2), color_R2, label_side) : label.new(na, na),
         labR3 = (show_labels or show_values) ? makeLabel(lx, vR3, buildLabelText("R3", vR3), color_R3, label_side) : label.new(na, na),
         labS1 = (show_labels or show_values) ? makeLabel(lx, vS1, buildLabelText("S1", vS1), color_S1, label_side) : label.new(na, na),
         labS2 = (show_labels or show_values) ? makeLabel(lx, vS2, buildLabelText("S2", vS2), color_S2, label_side) : label.new(na, na),
         labS3 = (show_labels or show_values) ? makeLabel(lx, vS3, buildLabelText("S3", vS3), color_S3, label_side) : label.new(na, na))

    array.push(periods, newPeriod)

// Estende linhas do período atual a cada barra
if array.size(periods) > 0 and not is_newbar(pp_res)
    curr = array.get(periods, array.size(periods) - 1)
    line.set_x2(curr.lPP, bar_index)
    line.set_x2(curr.lR1, bar_index)
    line.set_x2(curr.lR2, bar_index)
    line.set_x2(curr.lR3, bar_index)
    line.set_x2(curr.lS1, bar_index)
    line.set_x2(curr.lS2, bar_index)
    line.set_x2(curr.lS3, bar_index)
    // Mantém label na extremidade correta
    if show_labels or show_values
        lx = label_side == "Right" ? bar_index : curr.startBar
        label.set_x(curr.labPP, lx)
        label.set_x(curr.labR1, lx)
        label.set_x(curr.labR2, lx)
        label.set_x(curr.labR3, lx)
        label.set_x(curr.labS1, lx)
        label.set_x(curr.labS2, lx)
        label.set_x(curr.labS3, lx)

//--------------------------------------------------
///--------------------------------------------------
// ALERTAS — calculados no escopo global
//--------------------------------------------------
isNewBar = is_newbar(pp_res)

// Pega os níveis do período atual com segurança
currPP = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).pp : na
currR1 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).r1 : na
currR2 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).r2 : na
currR3 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).r3 : na
currS1 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).s1 : na
currS2 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).s2 : na
currS3 = array.size(periods) > 0 ? (array.get(periods, array.size(periods) - 1)).s3 : na

crossPP = not isNewBar and ta.cross(close, currPP)
crossR1 = not isNewBar and ta.cross(close, currR1)
crossR2 = not isNewBar and ta.cross(close, currR2)
crossR3 = not isNewBar and ta.cross(close, currR3)
crossS1 = not isNewBar and ta.cross(close, currS1)
crossS2 = not isNewBar and ta.cross(close, currS2)
crossS3 = not isNewBar and ta.cross(close, currS3)

alertcondition(crossPP, "Cross P",  "Cross P")
alertcondition(crossR1, "Cross R1", "Cross R1")
alertcondition(crossR2, "Cross R2", "Cross R2")
alertcondition(crossR3, "Cross R3", "Cross R3")
alertcondition(crossS1, "Cross S1", "Cross S1")
alertcondition(crossS2, "Cross S2", "Cross S2")
alertcondition(crossS3, "Cross S3", "Cross S3")
alertcondition(crossPP or crossR1 or crossR2 or crossR3 or crossS1 or crossS2 or crossS3, "Cross Any", "Cross Any")

//--------------------------------------------------
// EMAs COM DESLOCAMENTO
//--------------------------------------------------
ema9   = ta.ema(close, ema9Len)
ema21  = ta.ema(close, ema21Len)
ema200 = ta.ema(close, ema200Len)

shift9   = ema9Shift   ? ema9ShiftVal   : 0
shift21  = ema21Shift  ? ema21ShiftVal  : 0
shift200 = ema200Shift ? ema200ShiftVal : 0

plot(ema9,  color=ema9Color,  linewidth=2, title="EMA 9",  offset=shift9)
plot(ema21, color=ema21Color, linewidth=2, title="EMA 21", offset=shift21)
plot(showEma200 ? ema200 : na, color=ema200Color, linewidth=3, title="EMA 200", offset=shift200)

plot(ta.cross(ema9, ema21) ? ema9 : na, color=#2962FF, style=plot.style_cross, linewidth=4, title="Cruzamento EMAs")

//==================================================
// SEÇÃO 2: PIVOT POINT SUPERTREND
//==================================================
prd       = input.int(defval=2,     title="Pivot Point Period", minval=1, maxval=50,  group="Pivot Point SuperTrend")
Factor    = input.float(defval=3,   title="ATR Factor",         minval=1, step=0.1,   group="Pivot Point SuperTrend")
Pd        = input.int(defval=10,    title="ATR Period",         minval=1,             group="Pivot Point SuperTrend")
showpivot = input.bool(defval=false, title="Show Topos e Fundos",    group="Pivot Point SuperTrend")
showlabel = input.bool(defval=true,  title="Show Buy/Sell Labels",   group="Pivot Point SuperTrend")
showcl    = input.bool(defval=false, title="Show PP Center Line",    group="Pivot Point SuperTrend")
showsr    = input.bool(defval=false, title="Show Support/Resistance", group="Pivot Point SuperTrend")

float ph = ta.pivothigh(high, prd, prd)
float pl = ta.pivotlow(low, prd, prd)

plotshape(not na(ph) and showpivot, text="T", style=shape.labeldown, color=na, textcolor=color.rgb(177,23,23),  location=location.abovebar, offset=-prd)
plotshape(not na(pl) and showpivot, text="F", style=shape.labeldown, color=na, textcolor=color.rgb(9,186,101), location=location.belowbar, offset=-prd)

var float center = na
float lastpp = na
if not na(ph)
    lastpp := ph
else if not na(pl)
    lastpp := pl
if not na(lastpp)
    center := na(center) ? lastpp : (center * 2 + lastpp) / 3

Up   = center - (Factor * ta.atr(Pd))
Dn   = center + (Factor * ta.atr(Pd))

float TUp   = na
float TDown = na
var int Trend = 0
TUp   := close[1] > TUp[1]   ? math.max(Up, TUp[1])   : Up
TDown := close[1] < TDown[1] ? math.min(Dn, TDown[1]) : Dn
Trend := close > TDown[1] ? 1 : close < TUp[1] ? -1 : nz(Trend[1], 1)
Trailingsl = Trend == 1 ? TUp : TDown

linecolor = Trend == 1 and nz(Trend[1]) == 1 ? color.lime : Trend == -1 and nz(Trend[1]) == -1 ? color.red : na
plot(Trailingsl, color=linecolor, linewidth=2, title="PP SuperTrend")
plot(showcl ? center : na, color=showcl ? center < hl2 ? color.blue : color.red : na)

bsignal = Trend == 1 and Trend[1] == -1
ssignal = Trend == -1 and Trend[1] == 1

plotshape(bsignal and showlabel ? Trailingsl : na, title="Buy",  text="Buy",  style=shape.labelup,   location=location.absolute, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(ssignal and showlabel ? Trailingsl : na, title="Sell", text="Sell", style=shape.labeldown, location=location.absolute, color=color.red,  textcolor=color.white, size=size.tiny)

var float resistance = na
var float support    = na
if not na(pl)
    support    := pl
if not na(ph)
    resistance := ph

plot(showsr and not na(support)    ? support    : na, color=showsr ? color.lime : na, style=plot.style_circles, offset=-prd)
plot(showsr and not na(resistance) ? resistance : na, color=showsr ? color.red  : na, style=plot.style_circles, offset=-prd)

alertcondition(Trend == 1 and Trend[1] == -1, title='Buy Signal',    message='Buy Signal')
alertcondition(Trend == -1 and Trend[1] == 1, title='Sell Signal',   message='Sell Signal')
alertcondition(ta.change(Trend) != 0,         title='Trend Changed', message='Trend Changed')
````
