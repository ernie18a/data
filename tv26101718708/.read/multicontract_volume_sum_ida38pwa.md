# Multi-Contract Volume Sum

- url: https://www.tradingview.com/script/iDa38pwa/
- type: indicator
- pine_id: PUB;70b23d63296144cd8a9dbcdb9dad8788
- version: 1.0

## Description

[image]https://www.tradingview.com/x/7sZQpJ4p/[/image]

An indicator that summarizes contract volume.
You can enter 12 contracts, with a choice of 4 profiles for easy application on 4 instruments.
 [symbol="NYMEX:CL1!"]NYMEX:CL1![/symbol] [symbol="NYMEX:NG1!"]NYMEX:NG1![/symbol] [symbol="ICEEUR:BRN1!"]ICEEUR:BRN1![/symbol]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FX_power

//@version=6
indicator("Multi-Contract Volume Sum", overlay=false, max_bars_back=500)

// ── Active profile ───────────────────────────────────────────────
activeProfile = input.string("NG", "Active profile", options=["NG", "CL", "Profile 3", "Profile 4"], group="Profile")

// ── Profile NG ───────────────────────────────────────────────────
p1s01 = input.symbol("NYMEX:NGK2026", title="Contract 01",            group="NG")
p1s02 = input.symbol("NYMEX:NGM2026", title="Contract 02",            group="NG")
p1s03 = input.symbol("NYMEX:NGN2026", title="Contract 03",            group="NG")
p1s04 = input.symbol("NYMEX:NGQ2026", title="Contract 04 (optional)", group="NG")
p1s05 = input.symbol("NYMEX:NGU2026", title="Contract 05 (optional)", group="NG")
p1s06 = input.symbol("NYMEX:NGV2026", title="Contract 06 (optional)", group="NG")
p1s07 = input.symbol("NYMEX:NGX2026", title="Contract 07 (optional)", group="NG")
p1s08 = input.symbol("NYMEX:NGZ2026", title="Contract 08 (optional)", group="NG")
p1s09 = input.symbol("NYMEX:NGF2027", title="Contract 09 (optional)", group="NG")
p1s10 = input.symbol("NYMEX:NGG2027", title="Contract 10 (optional)", group="NG")
p1s11 = input.symbol("NYMEX:NGH2027", title="Contract 11 (optional)", group="NG")
p1s12 = input.symbol("NYMEX:NGJ2027", title="Contract 12 (optional)", group="NG")

// ── Profile CL ───────────────────────────────────────────────────
p2s01 = input.symbol("NYMEX:CLM2026", title="Contract 01",            group="CL")
p2s02 = input.symbol("NYMEX:CLN2026", title="Contract 02",            group="CL")
p2s03 = input.symbol("NYMEX:CLQ2026", title="Contract 03",            group="CL")
p2s04 = input.symbol("NYMEX:CLU2026", title="Contract 04 (optional)", group="CL")
p2s05 = input.symbol("NYMEX:CLV2026", title="Contract 05 (optional)", group="CL")
p2s06 = input.symbol("NYMEX:CLX2026", title="Contract 06 (optional)", group="CL")
p2s07 = input.symbol("NYMEX:CLZ2026", title="Contract 07 (optional)", group="CL")
p2s08 = input.symbol("NYMEX:CLF2027", title="Contract 08 (optional)", group="CL")
p2s09 = input.symbol("NYMEX:CLG2027", title="Contract 09 (optional)", group="CL")
p2s10 = input.symbol("NYMEX:CLH2027", title="Contract 10 (optional)", group="CL")
p2s11 = input.symbol("NYMEX:CLJ2027", title="Contract 11 (optional)", group="CL")
p2s12 = input.symbol("NYMEX:CLK2027", title="Contract 12 (optional)", group="CL")

// ── Profile 3 ────────────────────────────────────────────────────
p3s01 = input.symbol("", title="Contract 01",            group="Profile 3")
p3s02 = input.symbol("", title="Contract 02",            group="Profile 3")
p3s03 = input.symbol("", title="Contract 03",            group="Profile 3")
p3s04 = input.symbol("", title="Contract 04 (optional)", group="Profile 3")
p3s05 = input.symbol("", title="Contract 05 (optional)", group="Profile 3")
p3s06 = input.symbol("", title="Contract 06 (optional)", group="Profile 3")
p3s07 = input.symbol("", title="Contract 07 (optional)", group="Profile 3")
p3s08 = input.symbol("", title="Contract 08 (optional)", group="Profile 3")
p3s09 = input.symbol("", title="Contract 09 (optional)", group="Profile 3")
p3s10 = input.symbol("", title="Contract 10 (optional)", group="Profile 3")
p3s11 = input.symbol("", title="Contract 11 (optional)", group="Profile 3")
p3s12 = input.symbol("", title="Contract 12 (optional)", group="Profile 3")

// ── Profile 4 ────────────────────────────────────────────────────
p4s01 = input.symbol("", title="Contract 01",            group="Profile 4")
p4s02 = input.symbol("", title="Contract 02",            group="Profile 4")
p4s03 = input.symbol("", title="Contract 03",            group="Profile 4")
p4s04 = input.symbol("", title="Contract 04 (optional)", group="Profile 4")
p4s05 = input.symbol("", title="Contract 05 (optional)", group="Profile 4")
p4s06 = input.symbol("", title="Contract 06 (optional)", group="Profile 4")
p4s07 = input.symbol("", title="Contract 07 (optional)", group="Profile 4")
p4s08 = input.symbol("", title="Contract 08 (optional)", group="Profile 4")
p4s09 = input.symbol("", title="Contract 09 (optional)", group="Profile 4")
p4s10 = input.symbol("", title="Contract 10 (optional)", group="Profile 4")
p4s11 = input.symbol("", title="Contract 11 (optional)", group="Profile 4")
p4s12 = input.symbol("", title="Contract 12 (optional)", group="Profile 4")

// ── Select active profile ─────────────────────────────────────────
isNG = activeProfile == "NG"
isCL = activeProfile == "CL"
isP3 = activeProfile == "Profile 3"

sym01 = isNG ? p1s01 : isCL ? p2s01 : isP3 ? p3s01 : p4s01
sym02 = isNG ? p1s02 : isCL ? p2s02 : isP3 ? p3s02 : p4s02
sym03 = isNG ? p1s03 : isCL ? p2s03 : isP3 ? p3s03 : p4s03
sym04 = isNG ? p1s04 : isCL ? p2s04 : isP3 ? p3s04 : p4s04
sym05 = isNG ? p1s05 : isCL ? p2s05 : isP3 ? p3s05 : p4s05
sym06 = isNG ? p1s06 : isCL ? p2s06 : isP3 ? p3s06 : p4s06
sym07 = isNG ? p1s07 : isCL ? p2s07 : isP3 ? p3s07 : p4s07
sym08 = isNG ? p1s08 : isCL ? p2s08 : isP3 ? p3s08 : p4s08
sym09 = isNG ? p1s09 : isCL ? p2s09 : isP3 ? p3s09 : p4s09
sym10 = isNG ? p1s10 : isCL ? p2s10 : isP3 ? p3s10 : p4s10
sym11 = isNG ? p1s11 : isCL ? p2s11 : isP3 ? p3s11 : p4s11
sym12 = isNG ? p1s12 : isCL ? p2s12 : isP3 ? p3s12 : p4s12

// ── Display ──────────────────────────────────────────────────────
showSum     = input.bool(true,  "Show total volume",   group="Display")
showCurrent = input.bool(true,  "Show current volume", group="Display")
showMA      = input.bool(false, "Show MA on total",    group="Display")
maLen       = input.int(20, "MA length", minval=1, maxval=500, group="Display")
styleOpts   = input.string("Columns", "Style", options=["Columns", "Histogram", "Line", "Area", "Circles"], group="Display")
colorMode   = input.string("Solid", "Color mode", options=["Solid", "Bull/Bear", "Gradient", "Peaks"], group="Display")
peakLen     = input.int(50, "Peaks lookback", minval=2, maxval=500, group="Display")

// ── Colors ───────────────────────────────────────────────────────
colSum     = input.color(color.new(color.blue,   50), "Total volume color",   group="Colors")
colCurrent = input.color(color.new(color.orange,  0), "Current volume color", group="Colors")
colBull    = input.color(color.new(color.teal,   20), "Bull candle color",    group="Colors")
colBear    = input.color(color.new(color.red,    20), "Bear candle color",    group="Colors")
colPeakHi  = input.color(color.new(color.red,     0), "Peak HIGH vol color",  group="Colors")
colPeakLo  = input.color(color.new(color.lime,    0), "Peak LOW vol color",   group="Colors")
colMA      = input.color(color.yellow,                 "MA line color",        group="Colors")

// ── Volume fetch ─────────────────────────────────────────────────
getVol(sym) => sym != "" ? request.security(sym, timeframe.period, volume, gaps=barmerge.gaps_on, ignore_invalid_symbol=true) : 0.0

v01 = nz(getVol(sym01))
v02 = nz(getVol(sym02))
v03 = nz(getVol(sym03))
v04 = nz(getVol(sym04))
v05 = nz(getVol(sym05))
v06 = nz(getVol(sym06))
v07 = nz(getVol(sym07))
v08 = nz(getVol(sym08))
v09 = nz(getVol(sym09))
v10 = nz(getVol(sym10))
v11 = nz(getVol(sym11))
v12 = nz(getVol(sym12))

totalVol   = v01 + v02 + v03 + v04 + v05 + v06 + v07 + v08 + v09 + v10 + v11 + v12
currentVol = volume

// ── Current / Next / Next+1 detection ────────────────────────────
chartSym = syminfo.tickerid
isC01 = chartSym == sym01
isC02 = chartSym == sym02
isC03 = chartSym == sym03
isC04 = chartSym == sym04
isC05 = chartSym == sym05
isC06 = chartSym == sym06
isC07 = chartSym == sym07
isC08 = chartSym == sym08
isC09 = chartSym == sym09
isC10 = chartSym == sym10
isC11 = chartSym == sym11

curLabel = isC01 ? sym01 : isC02 ? sym02 : isC03 ? sym03 : isC04 ? sym04 : isC05 ? sym05 : isC06 ? sym06 : isC07 ? sym07 : isC08 ? sym08 : isC09 ? sym09 : isC10 ? sym10 : isC11 ? sym11 : sym12
nxt1Sym  = isC01 ? sym02 : isC02 ? sym03 : isC03 ? sym04 : isC04 ? sym05 : isC05 ? sym06 : isC06 ? sym07 : isC07 ? sym08 : isC08 ? sym09 : isC09 ? sym10 : isC10 ? sym11 : isC11 ? sym12 : "—"
nxt2Sym  = isC01 ? sym03 : isC02 ? sym04 : isC03 ? sym05 : isC04 ? sym06 : isC05 ? sym07 : isC06 ? sym08 : isC07 ? sym09 : isC08 ? sym10 : isC09 ? sym11 : isC10 ? sym12 : "—"
nxt1Vol  = isC01 ? v02 : isC02 ? v03 : isC03 ? v04 : isC04 ? v05 : isC05 ? v06 : isC06 ? v07 : isC07 ? v08 : isC08 ? v09 : isC09 ? v10 : isC10 ? v11 : isC11 ? v12 : 0.0
nxt2Vol  = isC01 ? v03 : isC02 ? v04 : isC03 ? v05 : isC04 ? v06 : isC05 ? v07 : isC06 ? v08 : isC07 ? v09 : isC08 ? v10 : isC09 ? v11 : isC10 ? v12 : 0.0

// ── Tooltip ───────────────────────────────────────────────────────
fv(v) => str.tostring(v, "#,###")
t01 = sym01 != "" ? sym01 + ": " + fv(v01) + "\n" : ""
t02 = sym02 != "" ? sym02 + ": " + fv(v02) + "\n" : ""
t03 = sym03 != "" ? sym03 + ": " + fv(v03) + "\n" : ""
t04 = sym04 != "" ? sym04 + ": " + fv(v04) + "\n" : ""
t05 = sym05 != "" ? sym05 + ": " + fv(v05) + "\n" : ""
t06 = sym06 != "" ? sym06 + ": " + fv(v06) + "\n" : ""
t07 = sym07 != "" ? sym07 + ": " + fv(v07) + "\n" : ""
t08 = sym08 != "" ? sym08 + ": " + fv(v08) + "\n" : ""
t09 = sym09 != "" ? sym09 + ": " + fv(v09) + "\n" : ""
t10 = sym10 != "" ? sym10 + ": " + fv(v10) + "\n" : ""
t11 = sym11 != "" ? sym11 + ": " + fv(v11) + "\n" : ""
t12 = sym12 != "" ? sym12 + ": " + fv(v12) + "\n" : ""
tipHeader = "[" + activeProfile + "] Total: " + fv(totalVol) + "\n"
tipCur    = "Current  (" + curLabel + "): " + fv(currentVol) + "\n"
tipNxt1   = nxt1Sym != "—" ? "Next     (" + nxt1Sym + "): " + fv(nxt1Vol) + "\n" : ""
tipNxt2   = nxt2Sym != "—" ? "Next+1   (" + nxt2Sym + "): " + fv(nxt2Vol) + "\n" : ""
tipSep    = "─────────────\n"
tip = tipHeader + tipCur + tipNxt1 + tipNxt2 + tipSep + t01 + t02 + t03 + t04 + t05 + t06 + t07 + t08 + t09 + t10 + t11 + t12

// ── Dynamic colors ───────────────────────────────────────────────
isBull    = close >= open
maxVol    = ta.highest(totalVol, 50)
gradAlpha = math.max(10, math.min(80, int((1.0 - totalVol / maxVol) * 80)))
peakHi    = ta.highest(totalVol, peakLen)
peakLo    = ta.lowest(totalVol, peakLen)
dynSum    = colorMode == "Bull/Bear" ? (isBull ? colBull : colBear) : colorMode == "Gradient" ? color.new(color.blue, gradAlpha) : colorMode == "Peaks" ? (totalVol >= peakHi ? colPeakHi : totalVol <= peakLo ? colPeakLo : colSum) : colSum
dynCur    = colorMode == "Bull/Bear" ? (isBull ? color.new(color.teal, 0) : color.new(color.red, 0)) : colCurrent

// ── Style ────────────────────────────────────────────────────────
ps = styleOpts == "Histogram" ? plot.style_histogram : styleOpts == "Line" ? plot.style_line : styleOpts == "Area" ? plot.style_area : styleOpts == "Circles" ? plot.style_circles : plot.style_columns

// ── Plots ────────────────────────────────────────────────────────
plot(showSum     ? totalVol   : na, "Total volume",   color=dynSum, style=ps, linewidth=4)
plot(showCurrent ? currentVol : na, "Current volume", color=dynCur, style=ps, linewidth=2)
plot(showMA ? ta.sma(totalVol, maLen) : na, "Total MA", color=colMA, style=plot.style_line, linewidth=2)

// ── Tooltip via label.new ─────────────────────────────────────────
if showSum
    label.new(bar_index, totalVol, text="", tooltip=tip, style=label.style_none, color=color.new(color.white, 100), textcolor=color.new(color.white, 100))
````
