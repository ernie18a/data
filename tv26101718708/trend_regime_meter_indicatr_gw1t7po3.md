# Trend Regime Meter [Indicatr]

- url: https://www.tradingview.com/script/gw1t7po3-Trend-Regime-Meter-Indicatr/
- type: indicator
- pine_id: PUB;b74e2b2155b04232a3120697fdfde95b
- version: 1.0

## Description

[b]Trend Regime Meter[/b] turns ADX and the directional indicators into one clear state: uptrend, downtrend, range, trend building or trend fading. It fixes the most common misreading of ADX - a high ADX says that a trend is strong, not in which direction.

[b]WHAT IT DOES[/b]
ADX measures trend strength, +DI and -DI show direction, and many traders struggle to combine the three lines. This script classifies every bar into a regime, colours the ADX line accordingly and shows the current state in a table. It can be used on its own or as a filter for other tools.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Direction:[/b] +DI above -DI = up, -DI above +DI = down. A minimum DI spread (default 2) is required to change direction, so small crossings do not flip the state.
[*][b]Trend on/off with hysteresis:[/b] a trend starts when ADX rises above 25 and only ends when ADX falls below 20. The gap between the two levels prevents constant switching around a single threshold.
[*][b]Strong vs. fading:[/b] inside a trend, a rising ADX means the trend is strengthening, a falling ADX means it is fading (lighter colour).
[*][b]Trend building:[/b] outside a trend, ADX rising above 15 marks a possible new trend (amber) with its likely direction.
[*][b]Range:[/b] everything else (grey).
[/list]

[b]HOW TO USE[/b]
[list]
[*]Uptrend or downtrend: context for trend-following setups in that direction - long or short.
[*]Range: crossovers and breakouts tend to be less reliable; mean-reversion tools are usually the better fit.
[*]Fading: the trend is losing strength. This does not mean it has reversed.
[*]Optional: colour the price bars by regime.
[*]Alerts: uptrend started, downtrend started, range started, trend building, trend fading, any regime change.
[/list]

[b]THE CHART[/b]
Daily chart. The ADX line is coloured by regime: green = uptrend, red = downtrend, light = fading, amber = building, grey = range. The histogram shows the DI spread (+DI minus -DI). Dashed and dotted lines mark the trend-on (25) and trend-off (20) levels. The table shows the current regime, how many bars it has lasted, ADX with its slope and both DI values.

[b]WHAT IS ORIGINAL[/b]
The built-in ADX and DMI show raw lines. This script adds a state model with hysteresis, a DI dead band, separate building and fading states, and a regime table - so the three lines become one readable answer.

[b]CREDITS[/b]
ADX, +DI and -DI were developed by J. Welles Wilder (New Concepts in Technical Trading Systems, 1978). Standard formulas via the built-in ta.dmi function.

[b]LIMITATIONS[/b]
[list]
[*]ADX is a lagging indicator; regimes are confirmed after the move has started.
[*]Thresholds (25/20/15) are common defaults, not optimised values.
[*]The state on the current bar can change until the bar closes.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Trend Regime Meter [Indicatr]", shorttitle="Regime Meter [Indicatr]", overlay=false)

// ===== Inputs =====
grpA = "ADX / DMI"
diLen   = input.int(14, "DI length", minval=1, group=grpA)
adxLen  = input.int(14, "ADX smoothing", minval=1, group=grpA)

grpR = "Regime rules"
trendOn  = input.float(25, "Trend starts when ADX rises above", minval=1, group=grpR)
trendOff = input.float(20, "Trend ends when ADX falls below", minval=1, group=grpR)
slopeLen = input.int(3, "ADX slope lookback (bars)", minval=1, group=grpR)
diMin    = input.float(2.0, "Minimum DI spread to change direction", minval=0, step=0.5, group=grpR)
buildMin = input.float(15, "Trend building: ADX at least", minval=1, group=grpR)

grpD = "Display"
showDI   = input.bool(true, "Show DI spread histogram", group=grpD)
showBg   = input.bool(true, "Shade pane by regime", group=grpD)
colorBar = input.bool(false, "Colour price bars by regime", group=grpD)
showTbl  = input.bool(true, "Show regime table", group=grpD)
cUp   = input.color(#1B5E40, "Uptrend", group=grpD, inline="c1")
cDn   = input.color(#C0412F, "Downtrend", group=grpD, inline="c1")
cRg   = input.color(#8A8F98, "Range", group=grpD, inline="c2")
cBd   = input.color(#D9A21B, "Building / fading", group=grpD, inline="c2")

// ===== Calculation =====
[diP, diM, adx] = ta.dmi(diLen, adxLen)
spread = diP - diM
rising  = adx > adx[slopeLen]
falling = adx < adx[slopeLen]

// direction with a dead band against DI flicker
var int dir = 0
if spread > diMin
    dir := 1
else if spread < -diMin
    dir := -1

// trend state with hysteresis (on above trendOn, off below trendOff)
var bool trending = false
if not trending and adx >= trendOn
    trending := true
else if trending and adx < trendOff
    trending := false

// regime codes: 2 = strong up, 1 = up fading, -2 = strong down, -1 = down fading,
// 3 = building (up), -3 = building (down), 0 = range
regime = 0
if trending
    regime := dir >= 0 ? (falling ? 1 : 2) : (falling ? -1 : -2)
else
    regime := rising and adx >= buildMin ? (dir >= 0 ? 3 : -3) : 0

regimeName(int r) =>
    switch r
        2  => "Uptrend"
        1  => "Uptrend, fading"
        -2 => "Downtrend"
        -1 => "Downtrend, fading"
        3  => "Trend building (up)"
        -3 => "Trend building (down)"
        => "Range"

regimeCol(int r) =>
    switch r
        2  => cUp
        -2 => cDn
        1  => color.new(cUp, 45)
        -1 => color.new(cDn, 45)
        3  => cBd
        -3 => cBd
        => cRg

var int barsIn = 0
barsIn := regime == regime[1] ? barsIn + 1 : 1
rc = regimeCol(regime)

// ===== Plots =====
plot(showDI ? spread : na, "DI spread (+DI minus -DI)", spread >= 0 ? color.new(cUp, 70) : color.new(cDn, 70), style=plot.style_columns)
plot(adx, "ADX", rc, 3)
hline(trendOn,  "Trend on",  color.new(color.gray, 40), hline.style_dashed)
hline(trendOff, "Trend off", color.new(color.gray, 65), hline.style_dotted)
hline(0, "Zero", color.new(color.gray, 80))
bgcolor(showBg ? color.new(rc, 90) : na, title="Regime shading")
barcolor(colorBar ? rc : na, title="Regime bar colour")

// ===== Table =====
var table tb = table.new(position.top_right, 2, 4, bgcolor=color.new(color.white, 8), border_color=color.new(color.gray, 75), border_width=1)
if showTbl and barstate.islast
    table.cell(tb, 0, 0, "Regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, 0, regimeName(regime), text_color=regime == 0 ? color.black : rc, text_size=size.small)
    table.cell(tb, 0, 1, "Bars in regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, 1, str.tostring(barsIn), text_color=color.black, text_size=size.small)
    table.cell(tb, 0, 2, "ADX", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, 2, str.tostring(adx, "#.0") + (rising ? "  rising" : falling ? "  falling" : "  flat"), text_color=color.black, text_size=size.small)
    table.cell(tb, 0, 3, "+DI / -DI", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, 3, str.tostring(diP, "#.0") + " / " + str.tostring(diM, "#.0"), text_color=color.black, text_size=size.small)

// ===== Alerts =====
upStart   = regime == 2 and regime[1] != 1 and regime[1] != 2
dnStart   = regime == -2 and regime[1] != -1 and regime[1] != -2
rgStart   = regime == 0 and regime[1] != 0
build     = math.abs(regime) == 3 and math.abs(regime[1]) != 3
fade      = math.abs(regime) == 1 and math.abs(regime[1]) == 2
alertcondition(upStart, "Uptrend started",   "Regime Meter {{ticker}} {{interval}}: uptrend regime started ({{close}})")
alertcondition(dnStart, "Downtrend started", "Regime Meter {{ticker}} {{interval}}: downtrend regime started ({{close}})")
alertcondition(rgStart, "Range started",     "Regime Meter {{ticker}} {{interval}}: trend ended, range regime ({{close}})")
alertcondition(build,   "Trend building",    "Regime Meter {{ticker}} {{interval}}: ADX rising, trend may be building ({{close}})")
alertcondition(fade,    "Trend fading",      "Regime Meter {{ticker}} {{interval}}: ADX falling inside a trend ({{close}})")
alertcondition(regime != regime[1], "Any regime change", "Regime Meter {{ticker}} {{interval}}: regime changed ({{close}})")
````
