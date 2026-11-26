# FRESH Weekly Regime - 4H

- url: https://www.tradingview.com/script/QhvdAqcz-FRESH-Weekly-Regime-4H/
- type: indicator
- pine_id: PUB;17fe32a0869b4b678f59e376dcc9b909
- version: 1.0

## Description

[b]FRESH Weekly Regime (4H)[/b]
Higher‑timeframe context in one glance: how much of the week's expected range is already used, and how much is left.

[b]What it does[/b]
It measures the weekly opening range (the week's Initial Balance, captured from the Sunday/Globex open through early Tuesday) and compares it to the weekly ATR:
[list]
[*]ATR Ratio = weekly range ÷ weekly ATR → a regime read: COMPRESSED → BALANCED → EXPANDED → STRETCHED.
[*]Fuel = weekly ATR − weekly range = the points of "average week" still unspent.
[*]Walls = the opening‑range high/low projected outward by that Fuel — i.e. where a full average‑volatility week would reach (projected weekly extremes).
[*]A VIX state (VOL CRUSH / STABLE / RISING / SHOCK) for the volatility backdrop, and a summary dashboard.
[/list]

[b]Why I built it[/b]
My intraday read kept missing the bigger frame: a setup looks great until you realize the week has already run most of its average range (little fuel left) — or that it's coiled with room to run. This puts that weekly context on the chart so lower‑timeframe trades are taken with the week's position in mind.

[b]How to read it[/b]
[list]
[*]COMPRESSED / low ratio → lots of Fuel, walls sit far away → the week has room to expand; favor continuation/breakout toward the walls.
[*]STRETCHED / high ratio → little Fuel, the week has used most of its average range → expect slowing or mean‑reversion; the walls become exhaustion zones rather than targets.
[*]Walls act as projected weekly range boundaries — magnets in an expanding week, fade zones in a stretched one (read the context).
[*]VIX frames it: high/rising vol widens what "normal" is; a crush tightens it.
[/list]

[b]Notes[/b]
[list=1]
[*]Designed for the 4‑hour chart (it reads weekly data - 4H is the intended view).
[*]Built for ES / index futures (a VIX‑style series is used for the volatility state).
[*]Levels reset each week. Context/education tool - not financial advice.
[/list]

by oxkit (kitar.co/fresh)

## Source Code

````pine
//@version=6
indicator('FRESH Weekly Regime - 4H', overlay = true)

//==============================
// Inputs
//==============================
atrLen = input.int(14, 'Weekly ATR Length')
compressedPct = input.float(0.30, 'Compressed Threshold', step = 0.05)
expandedPct = input.float(0.50, 'Expanded Threshold', step = 0.05)
stretchedPct = input.float(0.80, 'Stretched Threshold', step = 0.05)

showWalls = input.bool(true, 'Show Weekly Walls')
showDashboard = input.bool(true, 'Show Dashboard')

//==============================
// Helpers
//==============================
getState(ratio) =>
    na(ratio) ? 'N/A' : ratio < compressedPct ? 'COMPRESSED' : ratio < expandedPct ? 'BALANCED' : ratio < stretchedPct ? 'EXPANDED' : 'STRETCHED'

getColor(state) =>
    state == 'COMPRESSED' ? color.teal : state == 'BALANCED' ? color.gray : state == 'EXPANDED' ? color.orange : state == 'STRETCHED' ? color.red : color.gray

//==============================
// Weekly ATR
//==============================
weeklyAtr = request.security(syminfo.tickerid, 'W', ta.atr(atrLen))

//==============================
// VIX
//==============================
vix = request.security('TVC:VIX', timeframe.period, close)
vixOpen = request.security('TVC:VIX', 'D', open)
vixChange = vixOpen > 0 ? (vix - vixOpen) / vixOpen * 100 : na

vixState = na(vixChange) ? 'N/A' : vixChange > 5 ? 'VOL SHOCK' : vixChange > 2 ? 'VOL RISING' : vixChange < -3 ? 'VOL CRUSH' : 'VOL STABLE'

vixColor = vixState == 'VOL SHOCK' ? color.red : vixState == 'VOL RISING' ? color.orange : vixState == 'VOL CRUSH' ? color.green : color.gray

//==============================
// Weekly IB Window
// Sunday 18:00 to Tuesday 16:00 NY time
//==============================
dow = dayofweek
hourNY = hour(time, 'America/New_York')

inWeeklyWindow = dow == dayofweek.sunday and hourNY >= 18 or dow == dayofweek.monday or dow == dayofweek.tuesday and hourNY < 16

newWeeklyWindow = inWeeklyWindow and not inWeeklyWindow[1]

//==============================
// Weekly IB Calculation
//==============================
var float wHigh = na
var float wLow = na

if newWeeklyWindow
    wHigh := high
    wLow := low
    wLow
else if inWeeklyWindow
    wHigh := math.max(nz(wHigh, high), high)
    wLow := math.min(nz(wLow, low), low)
    wLow

//==============================
// Regime Math
//==============================
wSize = wHigh - wLow
wRatio = weeklyAtr > 0 ? wSize / weeklyAtr : na
wFuel = math.max(0, weeklyAtr - nz(wSize, 0))

wUpperWall = wHigh + wFuel
wLowerWall = wLow - wFuel

wState = getState(wRatio)
wColor = getColor(wState)

//==============================
// Wall Style Inputs
//==============================
wallColor = input.color(color.fuchsia, 'Wall Color')
wallTransparency = input.int(35, 'Wall Transparency', minval = 0, maxval = 100)
wallThickness = input.int(1, 'Wall Thickness', minval = 1, maxval = 5)

//==============================
// Weekly IB / Wall Plots
//==============================
showWeeklyLines = not inWeeklyWindow and not na(wHigh) and not na(wLow)

plot(showWeeklyLines ? wHigh : na, 'Weekly IB High', color = wColor, linewidth = 2, style = plot.style_linebr, editable = false)

plot(showWeeklyLines ? wLow : na, 'Weekly IB Low', color = wColor, linewidth = 2, style = plot.style_linebr, editable = false)

plot(showWalls and showWeeklyLines ? wUpperWall : na, 'Weekly Upper Wall', color = color.new(wallColor, wallTransparency), linewidth = math.max(1, wallThickness), style = plot.style_circles, editable = false)

plot(showWalls and showWeeklyLines ? wLowerWall : na, 'Weekly Lower Wall', color = color.new(wallColor, wallTransparency), linewidth = math.max(1, wallThickness), style = plot.style_circles, editable = false)

//==============================
// Dashboard
//==============================
dashboardPositionInput = input.string('Top Right', 'Dashboard Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = 'Display')

dashboardPosition = dashboardPositionInput == 'Top Left' ? position.top_left : dashboardPositionInput == 'Bottom Right' ? position.bottom_right : dashboardPositionInput == 'Bottom Left' ? position.bottom_left : position.top_right

var table dash = table.new(dashboardPosition, 4, 7, border_width = 1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, 'Weekly Regime', text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 0, 'Data', text_color = color.white, bgcolor = color.black)
    table.cell(dash, 2, 0, 'State', text_color = color.white, bgcolor = color.black)

    table.cell(dash, 0, 1, 'ATR Ratio', text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 1, str.tostring(wRatio, '#.##'), text_color = color.white, bgcolor = color.gray)
    table.cell(dash, 2, 1, wState, text_color = color.white, bgcolor = wColor)

    table.cell(dash, 0, 2, 'Fuel', text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 2, str.tostring(wFuel, '#.##') + ' pts', text_color = color.white, bgcolor = color.gray)
    table.cell(dash, 2, 2, '', bgcolor = color.gray)

    table.cell(dash, 0, 3, 'VIX', text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 3, str.tostring(vix, '#.##') + ' / ' + str.tostring(vixChange, '#.##') + '%', text_color = color.white, bgcolor = color.gray)
    table.cell(dash, 2, 3, vixState, text_color = color.white, bgcolor = vixColor)
````
