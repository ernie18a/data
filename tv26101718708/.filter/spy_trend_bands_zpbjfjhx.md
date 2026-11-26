# SPY Trend Bands

- url: https://www.tradingview.com/script/zpbJfJHX-SPY-Trend-Bands/
- type: indicator
- pine_id: PUB;6b758ed2f9c5456781657f42f19b112f
- version: 1.0

## Description

SPY Trend Bands

Precision intraday trend and daily target levels for SPY options trading.

---

What it does:

SPY Trend Bands combines an asymmetric ATR band system with statistically-validated daily target levels to give you a clear picture of intraday trend direction and key price zones — all in one lightweight indicator.

Trend Bands (Intraday)
Uses a smoothed RMA with asymmetric ATR multipliers — a tight upper band and a wider lower band. This asymmetry means bullish signals trigger more easily, while bearish signals require stronger conviction. The bands change color in real time: green when bullish, red when bearish.

Daily Target Boxes
Built on walk-forward validated SPY statistics across 1,445 sessions (2020–2026). Target levels are calculated from the RTH open price and automatically adjust based on daily volatility category (Low / Normal / High / Extreme). Once set at market open, levels remain fixed for the entire session.

---

Key features:
- Single target box mode — shows only the active directional target in blue, switching automatically with trend
- Optional dual box mode — displays both long and short targets simultaneously
- TP1 / TP2 label mode — relabels Avg/Ext levels as take profit targets
- Fully customizable colors for bullish, bearish, and single-box modes
- Bar coloring option

---

How to use:
- On 15min chart — use bands for intraday entry timing and trend confirmation
- On 1H chart — use target boxes as key support/resistance and reversal zones
- Works best with SPY and SPX-related instruments

---

Settings:
- MA / ATR lengths — tune band sensitivity
- Upper / Lower multipliers — control band width asymmetry
- Show both boxes — toggle between single directional and dual target display
- Use TP1/TP2 labels — switch label style for options traders

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// SPY Trend Bands – L3 Intraday + Daily Target Boxes

//@version=6
indicator("SPY Trend Bands", shorttitle="SPY Trend", overlay=true, max_boxes_count=5, max_labels_count=10)

// ═══════════════════════════════════════════════════════════════════
// INPUTS – BANDS
// ═══════════════════════════════════════════════════════════════════
grpL3 = "L3 · Intraday Bands"
l3MaLen     = input.int(9,     "MA Length",        minval=3,  maxval=30,  group=grpL3)
l3AtrLen    = input.int(10,    "ATR Length",        minval=5,  maxval=20,  group=grpL3)
l3UpperMult = input.float(0.3, "Upper Multiplier",  minval=0.1, maxval=1.0, step=0.1, group=grpL3)
l3LowerMult = input.float(1.2, "Lower Multiplier",  minval=0.3, maxval=3.0, step=0.1, group=grpL3)
fillTransp  = input.int(88,    "Fill transparency", minval=50, maxval=99,  group=grpL3)
showSignals = input.bool(true,  "Show signals",     group=grpL3)
colorBars   = input.bool(false, "Color bars",       group=grpL3)

// ═══════════════════════════════════════════════════════════════════
// INPUTS – SPALVOS
// ═══════════════════════════════════════════════════════════════════
grpColors = "Colors"
cBullInput  = input.color(#00FF1F, "Bullish color",     group=grpColors)
cBearInput  = input.color(#FF0000, "Bearish color",     group=grpColors)
cBoxInput   = input.color(#1848CC, "Single box color",  group=grpColors)

// ═══════════════════════════════════════════════════════════════════
// INPUTS – TARGET BOXES
// ═══════════════════════════════════════════════════════════════════
grpBox = "Target Box"
showBox       = input.bool(true,  "Show target box",          group=grpBox)
showBothBoxes = input.bool(false, "Show both boxes (Long+Short)", group=grpBox)
showBoxLabels = input.bool(true,  "Show box level labels",    group=grpBox)
showBoxPrice  = input.bool(true,  "Show price on labels",     group=grpBox)
useTPLabels   = input.bool(false, "Use TP1/TP2 labels",         group=grpBox)
boxLblSize    = input.string("Small", "Label size",
     options=["Tiny","Small","Normal","Large"], group=grpBox)

boxLblSz = switch boxLblSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    =>          size.large

// ═══════════════════════════════════════════════════════════════════
// SESSION
// ═══════════════════════════════════════════════════════════════════
isRTH    = not na(time("1", "0930-1600"))
isNewDay = ta.change(time("D")) != 0

// ═══════════════════════════════════════════════════════════════════
// VOL CATEGORY
// ═══════════════════════════════════════════════════════════════════
d_atr    = request.security(syminfo.tickerid, "D", ta.atr(10),            barmerge.gaps_off, barmerge.lookahead_off)
d_atrSma = request.security(syminfo.tickerid, "D", ta.sma(ta.atr(10),20), barmerge.gaps_off, barmerge.lookahead_off)
vol5d    = not na(d_atr) and not na(d_atrSma) and d_atrSma > 0 ? d_atr / d_atrSma : 1.0
string volCat = vol5d >= 1.2 ? "Extreme" : vol5d >= 0.8 ? "High" : vol5d >= 0.5 ? "Normal" : "Low"

// ═══════════════════════════════════════════════════════════════════
// DAILY TARGETS
// ═══════════════════════════════════════════════════════════════════
float up_avg_usd = na
float up_ext_usd = na
float dn_avg_usd = na
float dn_ext_usd = na

if volCat == "Extreme"
    up_avg_usd := 3.09,  up_ext_usd := 5.58
    dn_avg_usd := 3.29,  dn_ext_usd := 5.89
else if volCat == "High"
    up_avg_usd := 2.62,  up_ext_usd := 4.51
    dn_avg_usd := 2.09,  dn_ext_usd := 4.62
else if volCat == "Normal"
    up_avg_usd := 2.06,  up_ext_usd := 3.60
    dn_avg_usd := 1.90,  dn_ext_usd := 3.77
else
    up_avg_usd := 1.51,  up_ext_usd := 2.77
    dn_avg_usd := 1.62,  dn_ext_usd := 3.16

var float rthDayOpen = na
var float up_avg_lvl = na
var float up_ext_lvl = na
var float dn_avg_lvl = na
var float dn_ext_lvl = na

if isNewDay
    rthDayOpen := na
    up_avg_lvl := na,  up_ext_lvl := na
    dn_avg_lvl := na,  dn_ext_lvl := na

if isRTH and na(rthDayOpen)
    rthDayOpen := open
    up_avg_lvl := open + up_avg_usd
    up_ext_lvl := open + up_ext_usd
    dn_avg_lvl := open - dn_avg_usd
    dn_ext_lvl := open - dn_ext_usd

// ═══════════════════════════════════════════════════════════════════
// L3 BANDS
// ═══════════════════════════════════════════════════════════════════
l3Ma    = ta.rma(high, l3MaLen)
l3Atr   = ta.atr(l3AtrLen)
l3Upper = l3Ma + l3Atr * l3UpperMult
l3Lower = l3Ma - l3Atr * l3LowerMult

var int l3Trend = 0
if close > l3Upper and barstate.isconfirmed
    l3Trend := 1
if close < l3Lower and barstate.isconfirmed
    l3Trend := -1

l3LongSig  = l3Trend == 1 and l3Trend[1] != 1
l3ShortSig = l3Trend == -1 and l3Trend[1] != -1
l3Color    = l3Trend == 1 ? cBullInput : l3Trend == -1 ? cBearInput : color.gray

// ═══════════════════════════════════════════════════════════════════
// BAND PLOTS (be MA linijos)
// ═══════════════════════════════════════════════════════════════════
l3UpperPlot = plot(l3Upper, "Upper", color=l3Color, linewidth=1)
l3LowerPlot = plot(l3Lower, "Lower", color=l3Color, linewidth=1)
l3MidPlot   = plot((l3Upper + l3Lower) / 2, display=display.none)
fill(l3UpperPlot, l3MidPlot,   color=color.new(l3Color, fillTransp), title="Upper Fill")
fill(l3MidPlot,   l3LowerPlot, color=color.new(l3Color, fillTransp), title="Lower Fill")

plotshape(showSignals and l3LongSig,
     title="Long", style=shape.triangleup,
     location=location.belowbar, color=cBullInput,
     size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and l3ShortSig,
     title="Short", style=shape.triangledown,
     location=location.abovebar, color=cBearInput,
     size=size.small, text="SHORT", textcolor=color.white)

barcolor(colorBars ? l3Color : na)

// ═══════════════════════════════════════════════════════════════════
// TARGET BOXES
// ═══════════════════════════════════════════════════════════════════
var box longBox  = na
var box shortBox = na
var label lblUpAvg = na
var label lblUpExt = na
var label lblDnAvg = na
var label lblDnExt = na

if isNewDay
    for _lbl in array.from(lblUpAvg, lblUpExt, lblDnAvg, lblDnExt)
        if not na(_lbl)
            label.delete(_lbl)
    lblUpAvg := na,  lblUpExt := na
    lblDnAvg := na,  lblDnExt := na
    if not na(longBox)
        box.delete(longBox),  longBox  := na
    if not na(shortBox)
        box.delete(shortBox), shortBox := na

// Box spalva: showBothBoxes → žalia/raudona, vienas → mėlyna
color _longBoxC  = showBothBoxes ? cBullInput : cBoxInput
color _shortBoxC = showBothBoxes ? cBearInput : cBoxInput

bool showLongBox  = showBox and not na(up_avg_lvl) and (showBothBoxes or l3Trend == 1)
bool showShortBox = showBox and not na(dn_avg_lvl) and (showBothBoxes or l3Trend == -1)

if isRTH and showLongBox
    if na(longBox)
        longBox := box.new(bar_index, up_ext_lvl, bar_index + 20, up_avg_lvl,
             border_color=_longBoxC, border_width=1,
             bgcolor=color.new(_longBoxC, 65), extend=extend.right)
    else
        box.set_top(longBox,    up_ext_lvl)
        box.set_bottom(longBox, up_avg_lvl)
        box.set_border_color(longBox, _longBoxC)
        box.set_bgcolor(longBox, color.new(_longBoxC, 65))
else if not showLongBox and not na(longBox)
    box.delete(longBox), longBox := na

if isRTH and showShortBox
    if na(shortBox)
        shortBox := box.new(bar_index, dn_avg_lvl, bar_index + 20, dn_ext_lvl,
             border_color=_shortBoxC, border_width=1,
             bgcolor=color.new(_shortBoxC, 65), extend=extend.right)
    else
        box.set_top(shortBox,    dn_avg_lvl)
        box.set_bottom(shortBox, dn_ext_lvl)
        box.set_border_color(shortBox, _shortBoxC)
        box.set_bgcolor(shortBox, color.new(_shortBoxC, 65))
else if not showShortBox and not na(shortBox)
    box.delete(shortBox), shortBox := na

if barstate.islast and showBox and showBoxLabels and not na(up_avg_lvl)
    for _lbl in array.from(lblUpAvg, lblUpExt, lblDnAvg, lblDnExt)
        if not na(_lbl)
            label.delete(_lbl)
    lblUpAvg := na,  lblUpExt := na
    lblDnAvg := na,  lblDnExt := na

    if showLongBox
        string upAvgTxt = useTPLabels ? (showBoxPrice ? "TP1  " + str.tostring(math.round(up_avg_lvl, 2)) : "TP1") : (showBoxPrice ? "Avg Long  " + str.tostring(math.round(up_avg_lvl, 2)) : "Avg Long")
        string upExtTxt = useTPLabels ? (showBoxPrice ? "TP2  " + str.tostring(math.round(up_ext_lvl, 2)) : "TP2") : (showBoxPrice ? "Ext Long  " + str.tostring(math.round(up_ext_lvl, 2)) : "Ext Long")
        lblUpAvg := label.new(bar_index + 1, up_avg_lvl, upAvgTxt,
             style=label.style_label_left, color=_longBoxC,
             textcolor=color.white, size=boxLblSz, force_overlay=true)
        lblUpExt := label.new(bar_index + 1, up_ext_lvl, upExtTxt,
             style=label.style_label_left, color=_longBoxC,
             textcolor=color.white, size=boxLblSz, force_overlay=true)

    if showShortBox
        string dnAvgTxt = useTPLabels ? (showBoxPrice ? "TP1  " + str.tostring(math.round(dn_avg_lvl, 2)) : "TP1") : (showBoxPrice ? "Avg Short  " + str.tostring(math.round(dn_avg_lvl, 2)) : "Avg Short")
        string dnExtTxt = useTPLabels ? (showBoxPrice ? "TP2  " + str.tostring(math.round(dn_ext_lvl, 2)) : "TP2") : (showBoxPrice ? "Ext Short  " + str.tostring(math.round(dn_ext_lvl, 2)) : "Ext Short")
        lblDnAvg := label.new(bar_index + 1, dn_avg_lvl, dnAvgTxt,
             style=label.style_label_left, color=_shortBoxC,
             textcolor=color.white, size=boxLblSz, force_overlay=true)
        lblDnExt := label.new(bar_index + 1, dn_ext_lvl, dnExtTxt,
             style=label.style_label_left, color=_shortBoxC,
             textcolor=color.white, size=boxLblSz, force_overlay=true)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(l3LongSig,  "L3 Bull", "SPY Trend Bands: Bullish signal")
alertcondition(l3ShortSig, "L3 Bear", "SPY Trend Bands: Bearish signal")
````
