# Weekdays

- url: https://www.tradingview.com/script/TpCZ8R4n-Weekdays/
- type: indicator
- pine_id: PUB;2565e5afb1d242f98f0624c39a5ae780
- version: 1.0

## Description

Customizeable color days for backtest and journaling.

## Source Code

````pine
//@version=6
indicator(title = "Week", shorttitle = "Weekdays", overlay = true, max_lines_count = 500)

// ─── Inputs: General ──────────────────────────────────────────────
showLabels     = input.bool(true, "Show Day Labels",          group = "General")
showBG         = input.bool(true, "Show Background Tint",     group = "General")
showVLines     = input.bool(true, "Show Vertical Separators", group = "General")
bgTransp       = input.int(90, "Background Transparency",   minval = 0, maxval = 100, group = "General")
lineTransp     = input.int(60, "Vertical Line Transparency", minval = 0, maxval = 100, group = "General")
lineLengthMult = input.int(100, "Vertical Line Length Multiplier", minval = 1, group = "General")

// ─── Inputs: Per-Day Colors (full color wheel) ────────────────────
colMon = input.color(color.red,    "Monday",    group = "Day Colors", inline = "Mon")
onMon  = input.bool(true,          "",          group = "Day Colors", inline = "Mon")

colTue = input.color(color.orange, "Tuesday",   group = "Day Colors", inline = "Tue")
onTue  = input.bool(true,          "",          group = "Day Colors", inline = "Tue")

colWed = input.color(color.yellow, "Wednesday", group = "Day Colors", inline = "Wed")
onWed  = input.bool(true,          "",          group = "Day Colors", inline = "Wed")

colThu = input.color(color.green,  "Thursday",  group = "Day Colors", inline = "Thu")
onThu  = input.bool(true,          "",          group = "Day Colors", inline = "Thu")

colFri = input.color(color.blue,   "Friday",    group = "Day Colors", inline = "Fri")
onFri  = input.bool(true,          "",          group = "Day Colors", inline = "Fri")

colSat = input.color(color.purple, "Saturday",  group = "Day Colors", inline = "Sat")
onSat  = input.bool(true,          "",          group = "Day Colors", inline = "Sat")

colSun = input.color(color.black,  "Sunday",    group = "Day Colors", inline = "Sun")
onSun  = input.bool(true,          "",          group = "Day Colors", inline = "Sun")

// ─── Logic ────────────────────────────────────────────────────────
newDay     = ta.change(time("D")) != 0
LineLength = ta.atr(100) * lineLengthMult

isMon = dayofweek == dayofweek.monday
isTue = dayofweek == dayofweek.tuesday
isWed = dayofweek == dayofweek.wednesday
isThu = dayofweek == dayofweek.thursday
isFri = dayofweek == dayofweek.friday
isSat = dayofweek == dayofweek.saturday
isSun = dayofweek == dayofweek.sunday

// ─── Vertical stacked text ────────────────────────────────────────
txtMon = "M\no\nn\nd\na\ny"
txtTue = "T\nu\ne\ns\nd\na\ny"
txtWed = "W\ne\nd\nn\ne\ns\nd\na\ny"
txtThu = "T\nh\nu\nr\ns\nd\na\ny"
txtFri = "F\nr\ni\nd\na\ny"
txtSat = "S\na\nt\nu\nr\nd\na\ny"
txtSun = "S\nu\nn\nd\na\ny"

// ─── Labels: anchored to chart bottom, above time ribbon ──────────
plotchar(series = showLabels and onMon and isMon and newDay, title = "Mon", char = "", location = location.bottom, color = colMon, text = txtMon, textcolor = colMon, size = size.tiny, offset = 2)
plotchar(series = showLabels and onTue and isTue and newDay, title = "Tue", char = "", location = location.bottom, color = colTue, text = txtTue, textcolor = colTue, size = size.tiny, offset = 2)
plotchar(series = showLabels and onWed and isWed and newDay, title = "Wed", char = "", location = location.bottom, color = colWed, text = txtWed, textcolor = colWed, size = size.tiny, offset = 2)
plotchar(series = showLabels and onThu and isThu and newDay, title = "Thu", char = "", location = location.bottom, color = colThu, text = txtThu, textcolor = colThu, size = size.tiny, offset = 2)
plotchar(series = showLabels and onFri and isFri and newDay, title = "Fri", char = "", location = location.bottom, color = colFri, text = txtFri, textcolor = colFri, size = size.tiny, offset = 2)
plotchar(series = showLabels and onSat and isSat and newDay, title = "Sat", char = "", location = location.bottom, color = colSat, text = txtSat, textcolor = colSat, size = size.tiny, offset = 2)
plotchar(series = showLabels and onSun and isSun and newDay, title = "Sun", char = "", location = location.bottom, color = colSun, text = txtSun, textcolor = colSun, size = size.tiny, offset = 2)

// ─── Background tint per day ──────────────────────────────────────
bgcolor(showBG and onMon and isMon ? color.new(colMon, bgTransp) : na, title = "Mon BG")
bgcolor(showBG and onTue and isTue ? color.new(colTue, bgTransp) : na, title = "Tue BG")
bgcolor(showBG and onWed and isWed ? color.new(colWed, bgTransp) : na, title = "Wed BG")
bgcolor(showBG and onThu and isThu ? color.new(colThu, bgTransp) : na, title = "Thu BG")
bgcolor(showBG and onFri and isFri ? color.new(colFri, bgTransp) : na, title = "Fri BG")
bgcolor(showBG and onSat and isSat ? color.new(colSat, bgTransp) : na, title = "Sat BG")
bgcolor(showBG and onSun and isSun ? color.new(colSun, bgTransp) : na, title = "Sun BG")

// ─── Vertical separator lines on day change ───────────────────────
drawVerticalLine(bool cond, color col) =>
    if cond and showVLines
        line.new(bar_index, low - LineLength, bar_index, high + LineLength, color = color.new(col, lineTransp), width = 1)

drawVerticalLine(onMon and isMon and newDay, colMon)
drawVerticalLine(onTue and isTue and newDay, colTue)
drawVerticalLine(onWed and isWed and newDay, colWed)
drawVerticalLine(onThu and isThu and newDay, colThu)
drawVerticalLine(onFri and isFri and newDay, colFri)
drawVerticalLine(onSat and isSat and newDay, colSat)
drawVerticalLine(onSun and isSun and newDay, colSun)
````
