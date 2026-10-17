# Smart Multi-Period [SVT]

- url: https://www.tradingview.com/script/Uj0OVqwh/
- type: indicator
- pine_id: PUB;61ea8b03cdfe429bb1f55f98db2b485a
- version: 1.0

## Description

🔷 VWAP CONFLUENCE ENGINE — Smart Multi-Period

An institutional-grade VWAP indicator designed around one core 
idea: confluences between multiple timeframe Value Areas are the 
highest-probability levels in the market.

⚙️ HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator automatically selects the two most relevant VWAP 
periods for your current timeframe:

  📊 12H / Daily / Weekly  →  Annual VWAP
  📊 4H / 8H               →  Quarterly VWAP
  📊 1H / 2H               →  Monthly VWAP
  📊 15M                   →  Weekly VWAP
  📊 5M / 3M / 1M          →  Session VWAP

No configuration needed. Just add it and trade.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 CONFLUENCE ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automatically detects when DVAH, VWAP or DVAL levels from 
different periods align within a configurable threshold.
Confluence zones are highlighted with dynamic boxes — the 
stronger the confluence, the more visible the zone.

When price enters a confluence zone, the chart background 
changes color as a real-time visual cue.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 MATURITY RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A VWAP with only 1-2 bars of data is statistically unreliable.
This indicator only displays a VWAP once it has accumulated 
enough volume to be meaningful:

  • Weekly   → from Tuesday (2nd trading day)
  • Monthly  → from Day 10
  • Quarterly→ from the 2nd month of the quarter
  • Annual   → from Q2 (April)

Historical periods are always displayed in full.
Only the current active period applies the maturity rule.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Real-time panel showing all active levels with:
  ▲ / ▼  Price position relative to each level
  📍      Exact price of each level
  %       Distance from current price
  ⚡      Confluence indicator per level
  ◀       Nearest level to current price
  ✓ IVA / ↑↓ OVA  Value Area status
  ⏳      Maturity countdown for active periods

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Built-in alerts for:
  • Price crosses VWAP / DVAH / DVAL (both periods)
  • Price enters a Confluence Zone

Compatible with TradingView's alert manager via alertcondition().

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ KEY FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Auto-Adaptive period selection
✅ Manual period override
✅ ATR-based confluence zone sizing
✅ IVA / OVA Value Area status
✅ Previous period zones (PDVAH / PDVAL / PDVWAP)
✅ Real-time level labels with price values
✅ Line width by period importance
✅ Fully customizable colors per period
✅ Works on all markets and timeframes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 HOW TO READ IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • VWAP line: green = price above, red = price below
  • DVA fill: the area between DVAH and DVAL (Value Area)
  • ⚡ in dashboard: this level has a confluence
  • Yellow box on chart: active confluence zone
  • Yellow background: price currently inside confluence zone
  • IVA ✓: price is inside the Value Area (balanced market)
  • OVA ↑/↓: price is outside the Value Area (trending)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Based on the original VWAP Salvatierra framework.
Built for traders who use VWAP as a primary tool.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jesus_Salvatierra — Hiper VWAP Confluences
//@version=6
indicator(title="Hiper VWAP Confluences", shorttitle="HVC", overlay=true, max_boxes_count=50, max_lines_count=100, max_labels_count=100)

// ═══════════════════════════════════════════════════════════════════
// FUNCIÓN CORE
// ═══════════════════════════════════════════════════════════════════
computeVWAP(src, isNewPeriod, stDevMultiplier) =>
    var float sumSrcVol    = na
    var float sumVol       = na
    var float sumSrcSrcVol = na
    sumSrcVol    := isNewPeriod ? src * volume : src * volume + sumSrcVol[1]
    sumVol       := isNewPeriod ? volume       : volume + sumVol[1]
    sumSrcSrcVol := isNewPeriod ? volume * math.pow(src, 2) : volume * math.pow(src, 2) + sumSrcSrcVol[1]
    _vwap    = sumSrcVol / sumVol
    variance = sumSrcSrcVol / sumVol - math.pow(_vwap, 2)
    variance := variance < 0 ? 0 : variance
    stDev    = math.sqrt(variance)
    [_vwap, _vwap - stDev * stDevMultiplier, _vwap + stDev * stDevMultiplier]

// ═══════════════════════════════════════════════════════════════════
// MADUREZ
// ═══════════════════════════════════════════════════════════════════
getMature(p) =>
    switch p
        "Session"  => true
        "Week"     => dayofweek  >= dayofweek.tuesday     // ← martes
        "Month"    => dayofmonth >= 10
        "Quarter"  => (month - 1) % 3 >= 1
        "Year"     => month >= 4
        => true

getMatureInfo(p) =>
    switch p
        "Week"    => "⏳ Day " + str.tostring(dayofweek - 1) + "/2"
        "Month"   => "⏳ Day " + str.tostring(dayofmonth)    + "/10"
        "Quarter" => "⏳ Mes "  + str.tostring((month - 1) % 3 + 1) + "/2"
        "Year"    => "⏳ Q"     + str.tostring(math.ceil(month / 3.0)) + "/2"
        => "⏳ Maturing"

getLineWidth(p) =>
    switch p
        "Year"    => 3
        "Quarter" => 2
        "Month"   => 2
        => 1

tcSession  = time_close("D")
tcWeek     = time_close("W")
tcMonth    = time_close("M")
tcQuarter  = time_close("3M")
tcYear     = time_close("12M")

getPeriodClose(p) =>
    switch p
        "Session"  => tcSession
        "Week"     => tcWeek
        "Month"    => tcMonth
        "Quarter"  => tcQuarter
        "Year"     => tcYear
        => tcSession

// ═══════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════
src        = input(hlc3, "Source",          group="⚙️ General")
showBands  = input.bool(true, "Show Bands", group="⚙️ General")
stdevMult  = input.float(1.0, "σ1",         group="⚙️ General", step=0.1)
stdevMult2 = input.float(2.0, "σ2",         group="⚙️ General", step=0.1)
stdevMult3 = input.float(3.0, "σ3",         group="⚙️ General", step=0.1)

useAuto = input.bool(true, "Auto-Adaptive (recomendado)", group="📡 Períodos")
anchor1 = input.string("Session", "Período 1 (manual)", group="📡 Períodos",
     options=["Session","Week","Month","Quarter","Year"])
anchor2 = input.string("Week", "Período 2 (manual)", group="📡 Períodos",
     options=["Session","Week","Month","Quarter","Year","None"])

c1  = input.color(color.new(color.blue,   0),  "Color P1 bandas", group="🎨 Colores")
fc1 = input.color(color.new(color.blue,   90), "Color P1 fill",   group="🎨 Colores")
c2  = input.color(color.new(color.orange, 0),  "Color P2 bandas", group="🎨 Colores")
fc2 = input.color(color.new(color.orange, 90), "Color P2 fill",   group="🎨 Colores")

showConfl   = input.bool(true,  "Show Confluence Zones",  group="🔥 Confluencias")
conflThresh = input.float(0.15, "Umbral confluencia (%)", group="🔥 Confluencias", step=0.05, minval=0.01, maxval=1.0)
showConflBG = input.bool(true,  "Background en confluencia", group="🔥 Confluencias")

showDash    = input.bool(true,     "Show Dashboard", group="📊 Dashboard")
dashPos     = input.string("right", "Posición",      group="📊 Dashboard", options=["right","left"])

showLabels  = input.bool(true, "Show Labels",           group="🏷️ Labels")
labelOffset = input.int(3,     "Offset (bars derecha)", group="🏷️ Labels", minval=1, maxval=20)

showPrevious = input.bool(false, "Show Previous Zones", group="⏮️ Previous")

alertCross = input.bool(true, "Alert cruce niveles", group="🚨 Alerts")
alertConfl = input.bool(true, "Alert confluencia",   group="🚨 Alerts")

// ═══════════════════════════════════════════════════════════════════
// AUTO-ADAPTIVE
// ═══════════════════════════════════════════════════════════════════
tfMins = timeframe.in_seconds() / 60

var string autoPrimary   = ""
var string autoSecondary = ""

if tfMins >= 720
    autoPrimary   := "Year"
    autoSecondary := "Quarter"
else if tfMins >= 240
    autoPrimary   := "Quarter"
    autoSecondary := "Year"
else if tfMins >= 60
    autoPrimary   := "Month"
    autoSecondary := "Quarter"
else if tfMins >= 15
    autoPrimary   := "Week"
    autoSecondary := "Month"
else
    autoPrimary   := "Session"
    autoSecondary := "Week"

period1 = useAuto ? autoPrimary   : anchor1
period2 = useAuto ? autoSecondary : anchor2

// ═══════════════════════════════════════════════════════════════════
// DETECCIÓN DE NUEVO PERÍODO
// ═══════════════════════════════════════════════════════════════════
timeChange(period) => ta.change(time(period))

getNewPeriod(p) =>
    switch p
        "Session"  => timeChange("D")   != 0
        "Week"     => timeChange("W")   != 0
        "Month"    => timeChange("M")   != 0
        "Quarter"  => timeChange("3M")  != 0
        "Year"     => timeChange("12M") != 0
        => false

isNewPeriod1 = getNewPeriod(period1)
isNewPeriod2 = getNewPeriod(period2)

if na(src[1])
    isNewPeriod1 := true
    isNewPeriod2 := true

en2 = period2 != "None"

isActivePeriod1 = getPeriodClose(period1) > timenow
isActivePeriod2 = getPeriodClose(period2) > timenow
mature1 = isActivePeriod1 ? getMature(period1) : true
mature2 = isActivePeriod2 ? getMature(period2) : true

lw1 = input.int(2, "Grosor líneas P1", group="🎨 Colores", minval=1, maxval=4)
lw2 = input.int(1, "Grosor líneas P2", group="🎨 Colores", minval=1, maxval=4)

// ═══════════════════════════════════════════════════════════════════
// CÁLCULO P1
// ═══════════════════════════════════════════════════════════════════
float vwap1 = na
float u1a = na, float l1a = na
float u2a = na, float l2a = na
float u3a = na, float l3a = na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod1, stdevMult3)
    vwap1 := v
    u3a   := showBands ? hi : na
    l3a   := showBands ? lo : na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod1, stdevMult2)
    vwap1 := v
    u2a   := showBands ? hi : na
    l2a   := showBands ? lo : na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod1, stdevMult)
    vwap1 := v
    u1a   := showBands ? hi : na
    l1a   := showBands ? lo : na

// ═══════════════════════════════════════════════════════════════════
// CÁLCULO P2
// ═══════════════════════════════════════════════════════════════════
float vwap2 = na
float u1b = na, float l1b = na
float u2b = na, float l2b = na
float u3b = na, float l3b = na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod2, stdevMult3)
    vwap2 := v
    u3b   := showBands ? hi : na
    l3b   := showBands ? lo : na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod2, stdevMult2)
    vwap2 := v
    u2b   := showBands ? hi : na
    l2b   := showBands ? lo : na

if not timeframe.isdwm or timeframe.isdwm
    [v, lo, hi] = computeVWAP(src, isNewPeriod2, stdevMult)
    vwap2 := v
    u1b   := showBands ? hi : na
    l1b   := showBands ? lo : na

// ═══════════════════════════════════════════════════════════════════
// CONFLUENCE ENGINE
// ═══════════════════════════════════════════════════════════════════
atrVal = ta.atr(14)
conflBoxH() => atrVal * 0.3

isConfluent(a, b) => not na(a) and not na(b) and math.abs(a - b) / b * 100 < conflThresh

cfDvahDvah = isConfluent(u1a,   u1b)
cfDvalDval = isConfluent(l1a,   l1b)
cfVwapVwap = isConfluent(vwap1, vwap2)
cfDvahVwap = isConfluent(u1a,   vwap2)
cfDvalVwap = isConfluent(l1a,   vwap2)
cfVwapDvah = isConfluent(vwap1, u1b)
cfVwapDval = isConfluent(vwap1, l1b)

scoreDvah1 = (cfDvahDvah ? 1 : 0) + (cfDvahVwap ? 1 : 0)
scoreDval1 = (cfDvalDval ? 1 : 0) + (cfDvalVwap ? 1 : 0)
scoreVwap1 = (cfVwapVwap ? 1 : 0) + (cfVwapDvah ? 1 : 0) + (cfVwapDval ? 1 : 0)

inConflZone = mature1 and mature2 and
     ((scoreDvah1 > 0 and not na(u1a)   and math.abs(close - u1a)   / u1a   * 100 < conflThresh) or
      (scoreDval1 > 0 and not na(l1a)   and math.abs(close - l1a)   / l1a   * 100 < conflThresh) or
      (scoreVwap1 > 0 and not na(vwap1) and math.abs(close - vwap1) / vwap1 * 100 < conflThresh))

var box bxDvah1 = na
var box bxDval1 = na
var box bxVwap1 = na

if showConfl and barstate.islast and mature1 and mature2
    box.delete(bxDvah1)
    box.delete(bxDval1)
    box.delete(bxVwap1)
    if scoreDvah1 > 0 and not na(u1a)
        bxDvah1 := box.new(bar_index - 50, u1a + conflBoxH(), bar_index, u1a - conflBoxH(), bgcolor=color.new(color.yellow, 80 - scoreDvah1 * 15), border_color=color.new(color.yellow, 40), border_width=1, extend=extend.right)
    if scoreDval1 > 0 and not na(l1a)
        bxDval1 := box.new(bar_index - 50, l1a + conflBoxH(), bar_index, l1a - conflBoxH(), bgcolor=color.new(color.yellow, 80 - scoreDval1 * 15), border_color=color.new(color.yellow, 40), border_width=1, extend=extend.right)
    if scoreVwap1 > 0 and not na(vwap1)
        bxVwap1 := box.new(bar_index - 50, vwap1 + conflBoxH(), bar_index, vwap1 - conflBoxH(), bgcolor=color.new(color.yellow, 80 - scoreVwap1 * 15), border_color=color.new(color.yellow, 40), border_width=1, extend=extend.right)

// ── Background cuando precio en confluencia
bgcolor(showConflBG and inConflZone ? color.new(color.yellow, 92) : na, title="Confluence BG")

// ═══════════════════════════════════════════════════════════════════
// IVA / OVA
// ═══════════════════════════════════════════════════════════════════
ivaStatus1 = not mature1 ? getMatureInfo(period1) : not na(u1a) and not na(l1a) ? (close > u1a ? "OVA ↑" : close < l1a ? "OVA ↓" : "IVA ✓") : "..."
ivaColor1  = not mature1 ? color.new(color.gray, 70) : not na(u1a) and not na(l1a) ? (close > u1a ? color.new(color.green, 55) : close < l1a ? color.new(color.red, 55) : color.new(color.blue, 55)) : color.new(color.gray, 70)
ivaStatus2 = not mature2 ? getMatureInfo(period2) : en2 and not na(u1b) and not na(l1b) ? (close > u1b ? "OVA ↑" : close < l1b ? "OVA ↓" : "IVA ✓") : "..."
ivaColor2  = not mature2 ? color.new(color.gray, 70) : en2 and not na(u1b) and not na(l1b) ? (close > u1b ? color.new(color.green, 55) : close < l1b ? color.new(color.red, 55) : color.new(color.blue, 55)) : color.new(color.gray, 70)

// ═══════════════════════════════════════════════════════════════════
// NEAREST LEVEL P1
// ═══════════════════════════════════════════════════════════════════
d_u2a = not na(u2a)   ? math.abs(close - u2a)   : 999999.0
d_u1a = not na(u1a)   ? math.abs(close - u1a)   : 999999.0
d_v1  = not na(vwap1) ? math.abs(close - vwap1) : 999999.0
d_l1a = not na(l1a)   ? math.abs(close - l1a)   : 999999.0
d_l2a = not na(l2a)   ? math.abs(close - l2a)   : 999999.0
minD1 = math.min(d_u2a, d_u1a, d_v1, d_l1a, d_l2a)

// ═══════════════════════════════════════════════════════════════════
// NEAREST LEVEL P2 — bug fix
// ═══════════════════════════════════════════════════════════════════
d_u2b = not na(u2b)   ? math.abs(close - u2b)   : 999999.0
d_u1b = not na(u1b)   ? math.abs(close - u1b)   : 999999.0
d_v2  = not na(vwap2) ? math.abs(close - vwap2) : 999999.0
d_l1b = not na(l1b)   ? math.abs(close - l1b)   : 999999.0
d_l2b = not na(l2b)   ? math.abs(close - l2b)   : 999999.0
minD2 = math.min(d_u2b, d_u1b, d_v2, d_l1b, d_l2b)

// ═══════════════════════════════════════════════════════════════════
// PREVIOUS ZONES P1 + P2
// ═══════════════════════════════════════════════════════════════════
pdvavwap1 = ta.valuewhen(isNewPeriod1, vwap1[1], 0)
pdvah1    = ta.valuewhen(isNewPeriod1, u1a[1],   0)
pdval1    = ta.valuewhen(isNewPeriod1, l1a[1],   0)
pdvavwap2 = ta.valuewhen(isNewPeriod2, vwap2[1], 0)
pdvah2    = ta.valuewhen(isNewPeriod2, u1b[1],   0)
pdval2    = ta.valuewhen(isNewPeriod2, l1b[1],   0)

prvwap1   = showPrevious ? line.new(bar_index[30], pdvavwap1, bar_index[0], pdvavwap1, extend=extend.both, width=2, color=color.rgb(255,111,123,50)) : na
line.delete(prvwap1[1])
prevdvah1 = showPrevious ? line.new(bar_index[30], pdvah1,    bar_index[0], pdvah1,    extend=extend.both, width=2, color=color.rgb(255,111,123,50)) : na
line.delete(prevdvah1[1])
prevdval1 = showPrevious ? line.new(bar_index[30], pdval1,    bar_index[0], pdval1,    extend=extend.both, width=2, color=color.rgb(255,111,123,50)) : na
line.delete(prevdval1[1])
line.set_style(prvwap1,   line.style_dashed)
line.set_style(prevdvah1, line.style_dashed)
line.set_style(prevdval1, line.style_dashed)

lblPV1 = showPrevious ? label.new(bar_index[0], pdvavwap1, "PDVA VWAP P1", color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPV1[1])
lblPH1 = showPrevious ? label.new(bar_index[0], pdvah1, "PDVAH P1",        color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPH1[1])
lblPL1 = showPrevious ? label.new(bar_index[0], pdval1, "PDVAL P1",        color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPL1[1])

prvwap2   = showPrevious and en2 ? line.new(bar_index[30], pdvavwap2, bar_index[0], pdvavwap2, extend=extend.both, width=2, color=color.rgb(255,180,50,50)) : na
line.delete(prvwap2[1])
prevdvah2 = showPrevious and en2 ? line.new(bar_index[30], pdvah2,    bar_index[0], pdvah2,    extend=extend.both, width=2, color=color.rgb(255,180,50,50)) : na
line.delete(prevdvah2[1])
prevdval2 = showPrevious and en2 ? line.new(bar_index[30], pdval2,    bar_index[0], pdval2,    extend=extend.both, width=2, color=color.rgb(255,180,50,50)) : na
line.delete(prevdval2[1])
line.set_style(prvwap2,   line.style_dashed)
line.set_style(prevdvah2, line.style_dashed)
line.set_style(prevdval2, line.style_dashed)

lblPV2 = showPrevious and en2 ? label.new(bar_index[0], pdvavwap2, "PDVA VWAP P2", color=color.rgb(255,180,50,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPV2[1])
lblPH2 = showPrevious and en2 ? label.new(bar_index[0], pdvah2, "PDVAH P2",        color=color.rgb(255,180,50,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPH2[1])
lblPL2 = showPrevious and en2 ? label.new(bar_index[0], pdval2, "PDVAL P2",        color=color.rgb(255,180,50,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right, size=size.small) : na
label.delete(lblPL2[1])

// ═══════════════════════════════════════════════════════════════════
// PLOTS P1 — con grosor por importancia
// ═══════════════════════════════════════════════════════════════════
plot(mature1 ? vwap1 : na,        "VWAP P1",  color=close > vwap1 ? color.green : color.red, linewidth=lw1)
p1u1 = plot(mature1 ? u1a  : na, "DVAH P1",  color=color.new(c1, 70), linewidth=lw1)
p1l1 = plot(mature1 ? l1a  : na, "DVAL P1",  color=color.new(c1, 70), linewidth=lw1)
p1u2 = plot(mature1 ? u2a  : na, "DVA+2 P1", color=color.new(c1, 70))
p1l2 = plot(mature1 ? l2a  : na, "DVA-2 P1", color=color.new(c1, 70))
p1u3 = plot(mature1 ? u3a  : na, "DVA+3 P1", color=color.new(c1, 70), display=display.none)
p1l3 = plot(mature1 ? l3a  : na, "DVA-3 P1", color=color.new(c1, 70), display=display.none)
fill(p1u1, p1l1, fc1, "DVA Fill P1")
fill(p1u3, p1u2, fc1, "DVA Outer+ P1")
fill(p1l3, p1l2, fc1, "DVA Outer- P1")

// ═══════════════════════════════════════════════════════════════════
// PLOTS P2 — con grosor por importancia
// ═══════════════════════════════════════════════════════════════════
plot(en2 and mature2 ? vwap2 : na,        "VWAP P2",  color=close > vwap2 ? color.green : color.red, linewidth=lw2)
p2u1 = plot(en2 and mature2 ? u1b  : na, "DVAH P2",  color=color.new(c2, 70), linewidth=lw2)
p2l1 = plot(en2 and mature2 ? l1b  : na, "DVAL P2",  color=color.new(c2, 70), linewidth=lw2)
p2u2 = plot(en2 and mature2 ? u2b  : na, "DVA+2 P2", color=color.new(c2, 70))
p2l2 = plot(en2 and mature2 ? l2b  : na, "DVA-2 P2", color=color.new(c2, 70))
p2u3 = plot(en2 and mature2 ? u3b  : na, "DVA+3 P2", color=color.new(c2, 70), display=display.none)
p2l3 = plot(en2 and mature2 ? l3b  : na, "DVA-3 P2", color=color.new(c2, 70), display=display.none)
fill(p2u1, p2l1, fc2, "DVA Fill P2")
fill(p2u3, p2u2, fc2, "DVA Outer+ P2")
fill(p2l3, p2l2, fc2, "DVA Outer- P2")

// ═══════════════════════════════════════════════════════════════════
// REAL-TIME LABELS
// ═══════════════════════════════════════════════════════════════════
lbl_v1 = showLabels and mature1 ? label.new(bar_index + labelOffset, vwap1, "VWAP: "  + str.tostring(vwap1, format.mintick), color=color.new(color.gray,60), textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_v1[1])
lbl_u1 = showLabels and mature1 ? label.new(bar_index + labelOffset, u1a,   "DVAH: "  + str.tostring(u1a,   format.mintick), color=color.new(c1,50),        textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_u1[1])
lbl_l1 = showLabels and mature1 ? label.new(bar_index + labelOffset, l1a,   "DVAL: "  + str.tostring(l1a,   format.mintick), color=color.new(c1,50),        textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_l1[1])
lbl_v2 = showLabels and en2 and mature2 ? label.new(bar_index + labelOffset, vwap2, "VWAP2: " + str.tostring(vwap2, format.mintick), color=color.new(color.gray,60), textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_v2[1])
lbl_u2 = showLabels and en2 and mature2 ? label.new(bar_index + labelOffset, u1b,   "DVAH2: " + str.tostring(u1b,   format.mintick), color=color.new(c2,50),        textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_u2[1])
lbl_l2 = showLabels and en2 and mature2 ? label.new(bar_index + labelOffset, l1b,   "DVAL2: " + str.tostring(l1b,   format.mintick), color=color.new(c2,50),        textcolor=color.white, style=label.style_label_left, size=size.small) : na
label.delete(lbl_l2[1])

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════
addRow(tbl, row, name, lvl, col, score, isNearest) =>
    isAbove  = not na(lvl) and close > lvl
    rowBg    = isNearest ? color.new(color.white, 65) : color.new(col, 88)
    txtCol   = isAbove ? color.new(color.green, 10) : color.new(color.red, 10)
    nearMark = isNearest ? " ◀" : ""
    distTxt  = not na(lvl) ? (close >= lvl ? "+" : "") + str.tostring(math.round((close - lvl) / lvl * 100, 2)) + "%" : "n/a"
    priceTxt = not na(lvl) ? str.tostring(lvl, format.mintick) : "n/a"
    table.cell(tbl, 0, row, (isAbove ? "▲ " : "▼ ") + name + nearMark, text_color=txtCol,       text_size=size.small, bgcolor=rowBg)
    table.cell(tbl, 1, row, priceTxt,                                    text_color=color.white,  text_size=size.small, bgcolor=rowBg)
    table.cell(tbl, 2, row, distTxt,                                     text_color=txtCol,       text_size=size.small, bgcolor=rowBg)
    table.cell(tbl, 3, row, score > 0 ? "⚡" : " ",                      text_color=color.yellow, text_size=size.small, bgcolor=rowBg)

var table dash = na

if showDash and barstate.islast
    table.delete(dash)
    dPos = dashPos == "right" ? position.middle_right : position.middle_left
    dash := table.new(dPos, 4, 14, bgcolor=color.rgb(10,10,20,75), border_color=color.rgb(80,80,100,50), border_width=1, frame_color=color.rgb(100,100,150,30), frame_width=1)

    hBg   = color.rgb(30, 30, 50, 60)
    sepBg = color.rgb(5, 5, 10, 80)

    table.cell(dash, 0, 0, "P1: " + period1, text_color=color.new(c1, 10), text_size=size.small, bgcolor=hBg)
    table.cell(dash, 1, 0, "Precio",          text_color=color.silver,      text_size=size.small, bgcolor=hBg)
    table.cell(dash, 2, 0, "Dist %",          text_color=color.silver,      text_size=size.small, bgcolor=hBg)
    table.cell(dash, 3, 0, ivaStatus1,        text_color=color.white,       text_size=size.small, bgcolor=ivaColor1)

    addRow(dash, 1, "DVA+2", u2a,   c1,         0,          d_u2a == minD1)
    addRow(dash, 2, "DVAH",  u1a,   c1,         scoreDvah1, d_u1a == minD1)
    addRow(dash, 3, "VWAP",  vwap1, color.gray, scoreVwap1, d_v1  == minD1)
    addRow(dash, 4, "DVAL",  l1a,   c1,         scoreDval1, d_l1a == minD1)
    addRow(dash, 5, "DVA-2", l2a,   c1,         0,          d_l2a == minD1)

    table.cell(dash, 0, 6, "P2: " + period2, text_color=color.new(c2, 10),   text_size=size.small, bgcolor=hBg)
    table.cell(dash, 1, 6, "──────",          text_color=color.rgb(80,80,80), text_size=size.small, bgcolor=sepBg)
    table.cell(dash, 2, 6, "──────",          text_color=color.rgb(80,80,80), text_size=size.small, bgcolor=sepBg)
    table.cell(dash, 3, 6, ivaStatus2,        text_color=color.white,         text_size=size.small, bgcolor=ivaColor2)

    addRow(dash, 7,  "DVA+2", u2b,   c2,         0,          d_u2b == minD2)
    addRow(dash, 8,  "DVAH",  u1b,   c2,         scoreDvah1, d_u1b == minD2)
    addRow(dash, 9,  "VWAP",  vwap2, color.gray, scoreVwap1, d_v2  == minD2)
    addRow(dash, 10, "DVAL",  l1b,   c2,         scoreDval1, d_l1b == minD2)
    addRow(dash, 11, "DVA-2", l2b,   c2,         0,          d_l2b == minD2)

// ═══════════════════════════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════════════════════════
crossVwap1 = ta.cross(close, vwap1) and mature1
crossDvah1 = ta.cross(close, u1a)   and mature1
crossDval1 = ta.cross(close, l1a)   and mature1
crossVwap2 = ta.cross(close, vwap2) and mature2
crossDvah2 = ta.cross(close, u1b)   and mature2
crossDval2 = ta.cross(close, l1b)   and mature2

if alertCross and crossVwap1
    alert("⚡ Cruce VWAP P1 (" + period1 + ")", alert.freq_once_per_bar)
if alertCross and crossDvah1
    alert("⚡ Cruce DVAH P1 (" + period1 + ")", alert.freq_once_per_bar)
if alertCross and crossDval1
    alert("⚡ Cruce DVAL P1 (" + period1 + ")", alert.freq_once_per_bar)
if alertCross and crossVwap2 and en2
    alert("⚡ Cruce VWAP P2 (" + period2 + ")", alert.freq_once_per_bar)
if alertCross and crossDvah2 and en2
    alert("⚡ Cruce DVAH P2 (" + period2 + ")", alert.freq_once_per_bar)
if alertCross and crossDval2 and en2
    alert("⚡ Cruce DVAL P2 (" + period2 + ")", alert.freq_once_per_bar)
if alertConfl and inConflZone
    alert("🔥 Confluencia activa — revisa el chart", alert.freq_once_per_bar)

alertcondition(crossVwap1,  "Cruce VWAP P1",  "Precio cruza VWAP P1")
alertcondition(crossDvah1,  "Cruce DVAH P1",  "Precio cruza DVAH P1")
alertcondition(crossDval1,  "Cruce DVAL P1",  "Precio cruza DVAL P1")
alertcondition(crossVwap2,  "Cruce VWAP P2",  "Precio cruza VWAP P2")
alertcondition(crossDvah2,  "Cruce DVAH P2",  "Precio cruza DVAH P2")
alertcondition(crossDval2,  "Cruce DVAL P2",  "Precio cruza DVAL P2")
alertcondition(inConflZone, "Confluencia",     "Precio en zona de confluencia")
````
