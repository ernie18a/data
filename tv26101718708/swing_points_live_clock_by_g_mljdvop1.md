# Swing Points + Live Clock by G

- url: https://www.tradingview.com/script/MLJDVOp1-Swing-Points-Live-Clock-by-G/
- type: indicator
- pine_id: PUB;02c385a2c93141ecb9aa9b37f041dbdd
- version: 1.0

## Description

Swing Points + Live Clock

A dual-purpose indicator combining Williams Fractal-based swing point detection with a forward-looking "live clock" table that flags upcoming minutes matching a specific number set.

Swing Points

Detects swing highs and lows using a Williams Fractal method (2-bar lookback, with handling for equal highs/lows so flat tops/bottoms still register).
Classifies each swing point relative to the previous one of the same type and marks it on the chart:
Highs: Higher High (green), Lower High (red), Equal High (gray)
Lows: Higher Low (green), Lower Low (red), Equal Low (gray)
Plotted as small circles above/below the corresponding bar.

Live Clock Table

Displays a real-time, minute-by-minute forward-looking table (from the current time up to 30 minutes ahead) in your selected chart timezone (choice of major timezones including Europe/Zurich, New York, Tokyo, Kolkata, UTC, etc.).
For each upcoming minute, it checks three derived values against a fixed set of reference numbers (0, 3, 7, 11, 14, 17, 23, 29, 35, 41, 44, 47, 50, 53, 56, 59, plus a few extended values for the third column):
:mm — the minute value itself
-|mm−hh| — the absolute difference between minute and hour
+hh+mm — the sum of hour and minute (normalized back to the reference set)
Matches within ±1 are highlighted in color; non-matches are grayed out — giving an at-a-glance view of which upcoming minutes align with the model's key numbers.

Customization

Toggle the clock table on/off, set how many minutes ahead to project (5–30)
Choose table position (9 anchor points) and text size
Full color control: background, border, header text, time text, and separate colors for each of the three matched-value columns and their "no match" state

Use case
Built for traders following a time-of-day number model (e.g., Goldbach/CE-style minute windows) who want both real-time swing structure and a live countdown highlighting when the next "significant" minute is coming up, without manually checking a clock or table.

## Source Code

````pine
//@version=6
indicator('Swing Points + Live Clock', overlay=true)

n = 2

// ============================================
// === INPUTS ===
// ============================================

tz = input.string("Europe/Zurich", title="Chart Timezone", options=["Europe/Zurich", "Europe/Bucharest", "Europe/London", "Europe/Berlin", "Europe/Moscow", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Kolkata", "Australia/Sydney", "UTC"])

showLiveClock = input.bool(true, title="Show Live Clock Table", group="Live Clock")
clockMinutesAhead = input.int(20, title="Minutes Ahead", minval=5, maxval=30, group="Live Clock")
clockPositionStr = input.string("bottom_left", title="Clock Position", options=["top_right","top_left","top_center","middle_right","middle_left","middle_center","bottom_right","bottom_left","bottom_center"], group="Live Clock")
clockTextSizeStr = input.string("tiny", title="Clock Text Size", options=["tiny", "small", "normal", "large", "huge"], group="Live Clock")
clockBgColor = input.color(color.new(color.black, 80), title="Clock Background Color", group="Live Clock")
clockBorderColor = input.color(color.gray, title="Clock Border Color", group="Live Clock")
clockHeaderColor = input.color(color.silver, title="Clock Header Text Color", group="Live Clock")
clockTimeColor = input.color(color.white, title="Clock Time Text Color", group="Live Clock")
clockMmColor = input.color(color.aqua, title="Clock :mm Color", group="Live Clock")
clockMinusColor = input.color(color.yellow, title="Clock -minus Color", group="Live Clock")
clockPlusColor = input.color(color.white, title="Clock +plus Color", group="Live Clock")
clockNoMatchColor = input.color(color.gray, title="Clock No Match Color", group="Live Clock")

clockPosition = clockPositionStr == "top_right" ? position.top_right : clockPositionStr == "top_left" ? position.top_left : clockPositionStr == "top_center" ? position.top_center : clockPositionStr == "middle_right" ? position.middle_right : clockPositionStr == "middle_left" ? position.middle_left : clockPositionStr == "middle_center" ? position.middle_center : clockPositionStr == "bottom_right" ? position.bottom_right : clockPositionStr == "bottom_left" ? position.bottom_left : position.bottom_center

// ============================================
// === SIZE HELPER (Clock) ===
// ============================================

getTableSize(sizeStr) =>
    switch sizeStr
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        "huge" => size.huge
        => size.tiny

// ============================================
// === TIME NUMBER MATCHING HELPERS (Clock) ===
// ============================================

matchSet(val) =>
    result = -1
    if math.abs(val - 0) <= 1
        result := 0
    else if math.abs(val - 3) <= 1
        result := 3
    else if math.abs(val - 7) <= 1
        result := 7
    else if math.abs(val - 11) <= 1
        result := 11
    else if math.abs(val - 14) <= 1
        result := 14
    else if math.abs(val - 17) <= 1
        result := 17
    else if math.abs(val - 23) <= 1
        result := 23
    else if math.abs(val - 29) <= 1
        result := 29
    else if math.abs(val - 35) <= 1
        result := 35
    else if math.abs(val - 41) <= 1
        result := 41
    else if math.abs(val - 44) <= 1
        result := 44
    else if math.abs(val - 47) <= 1
        result := 47
    else if math.abs(val - 50) <= 1
        result := 50
    else if math.abs(val - 53) <= 1
        result := 53
    else if math.abs(val - 56) <= 1
        result := 56
    else if math.abs(val - 59) <= 1
        result := 59
    result

matchSetC(val) =>
    result = -1
    if math.abs(val - 0) <= 1
        result := 100
    else if math.abs(val - 3) <= 1
        result := 103
    else if math.abs(val - 7) <= 1
        result := 107
    else if math.abs(val - 11) <= 1
        result := 111
    else if math.abs(val - 14) <= 1
        result := 114
    else if math.abs(val - 17) <= 1
        result := 117
    else if math.abs(val - 23) <= 1
        result := 123
    else if math.abs(val - 29) <= 1
        result := 129
    else if math.abs(val - 35) <= 1
        result := 135
    else if math.abs(val - 41) <= 1
        result := 141
    else if math.abs(val - 44) <= 1
        result := 144
    else if math.abs(val - 47) <= 1
        result := 147
    else if math.abs(val - 50) <= 1
        result := 150
    else if math.abs(val - 53) <= 1
        result := 153
    else if math.abs(val - 56) <= 1
        result := 156
    else if math.abs(val - 59) <= 1
        result := 159
    else if math.abs(val - 65) <= 1
        result := 65
    else if math.abs(val - 71) <= 1
        result := 71
    else if math.abs(val - 77) <= 1
        result := 77
    result

getCRealNumber(num) =>
    switch num
        100 => 0
        103 => 3
        107 => 7
        111 => 11
        114 => 14
        117 => 17
        123 => 23
        129 => 29
        135 => 35
        141 => 41
        144 => 44
        147 => 47
        150 => 50
        153 => 53
        156 => 56
        159 => 59
        => num

// ============================================
// === SWING POINTS (Williams Fractal) ===
// ============================================

up = high[n+2] < high[n] and high[n+1] < high[n] and high[n-1] < high[n] and high[n-2] < high[n]
         or high[n+3] < high[n] and high[n+2] < high[n] and high[n+1] == high[n] and high[n-1] < high[n] and high[n-2] < high[n]
         or high[n+4] < high[n] and high[n+3] < high[n] and high[n+2] == high[n] and high[n+1] <= high[n] and high[n-1] < high[n] and high[n-2] < high[n]
         or high[n+5] < high[n] and high[n+4] < high[n] and high[n+3] == high[n] and high[n+2] == high[n] and high[n+1] <= high[n] and high[n-1] < high[n] and high[n-2] < high[n]
         or high[n+6] < high[n] and high[n+5] < high[n] and high[n+4] == high[n] and high[n+3] <= high[n] and high[n+2] == high[n] and high[n+1] <= high[n] and high[n-1] < high[n] and high[n-2] < high[n]

down = low[n+2] > low[n] and low[n+1] > low[n] and low[n-1] > low[n] and low[n-2] > low[n]
         or low[n+3] > low[n] and low[n+2] > low[n] and low[n+1] == low[n] and low[n-1] > low[n] and low[n-2] > low[n]
         or low[n+4] > low[n] and low[n+3] > low[n] and low[n+2] == low[n] and low[n+1] >= low[n] and low[n-1] > low[n] and low[n-2] > low[n]
         or low[n+5] > low[n] and low[n+4] > low[n] and low[n+3] == low[n] and low[n+2] == low[n] and low[n+1] >= low[n] and low[n-1] > low[n] and low[n-2] > low[n]
         or low[n+6] > low[n] and low[n+5] > low[n] and low[n+4] == low[n] and low[n+3] >= low[n] and low[n+2] == low[n] and low[n+1] >= low[n] and low[n-1] > low[n] and low[n-2] > low[n]

LH = up and high[n] < ta.valuewhen(up, high[n], 1)
HH = up and high[n] > ta.valuewhen(up, high[n], 1)
EH = up and high[n] == ta.valuewhen(up, high[n], 1)

LL = down and low[n] < ta.valuewhen(down, low[n], 1)
HL = down and low[n] > ta.valuewhen(down, low[n], 1)
EL = down and low[n] == ta.valuewhen(down, low[n], 1)

plotshape(LH, style=shape.circle, location=location.abovebar, offset=-2, color=color.new(color.red, 0))
plotshape(HH, style=shape.circle, location=location.abovebar, offset=-2, color=color.new(color.green, 0))
plotshape(EH, style=shape.circle, location=location.abovebar, offset=-2, color=color.new(color.gray, 0))
plotshape(LL, style=shape.circle, location=location.belowbar, offset=-2, color=color.new(color.red, 0))
plotshape(HL, style=shape.circle, location=location.belowbar, offset=-2, color=color.new(color.green, 0))
plotshape(EL, style=shape.circle, location=location.belowbar, offset=-2, color=color.new(color.gray, 0))

// ============================================
// === LIVE CLOCK TABLE ===
// ============================================

clockTblSize = getTableSize(clockTextSizeStr)

var table clockTable = table.new(clockPosition, 4, 33, bgcolor=clockBgColor, border_width=1, border_color=clockBorderColor, frame_width=1, frame_color=clockBorderColor)

if barstate.islast and showLiveClock
    headerBg = color.new(color.gray, 70)
    table.cell(clockTable, 0, 0, "Time",    bgcolor=headerBg, text_color=clockHeaderColor, text_size=clockTblSize)
    table.cell(clockTable, 1, 0, ":mm",     bgcolor=headerBg, text_color=clockMmColor,     text_size=clockTblSize)
    table.cell(clockTable, 2, 0, "-|mm-hh|", bgcolor=headerBg, text_color=clockMinusColor, text_size=clockTblSize)
    table.cell(clockTable, 3, 0, "+hh+mm",  bgcolor=headerBg, text_color=clockPlusColor,   text_size=clockTblSize)

    for i = 0 to clockMinutesAhead
        futureMs = timenow + i * 60 * 1000
        fh = hour(futureMs, tz)
        fm = minute(futureMs, tz)

        rawA = fm
        rawB = math.abs(fm - fh)
        rawC = fh + fm

        dispA = matchSet(rawA)
        dispB = matchSet(rawB)
        dispCcoded = matchSetC(rawC)
        dispC = dispCcoded == -1 ? -1 : getCRealNumber(dispCcoded)

        partA = dispA != -1 ? ":" + str.tostring(dispA) : ":-"
        partB = dispB != -1 ? "-" + str.tostring(dispB) : "--"
        partC = dispC != -1 ? "+" + str.tostring(dispC) : "+-"

        rowIdx = i + 1
        timeStr = (i == 0 ? "► " : "+" + str.tostring(i) + " ") + str.tostring(fh, "00") + ":" + str.tostring(fm, "00")

        timeBg = color.new(color.white, 100)

        colA = dispA != -1 ? clockMmColor : clockNoMatchColor
        colB = dispB != -1 ? clockMinusColor : clockNoMatchColor
        colC = dispC != -1 ? clockPlusColor : clockNoMatchColor

        table.cell(clockTable, 0, rowIdx, timeStr, bgcolor=timeBg, text_color=clockTimeColor, text_size=clockTblSize)
        table.cell(clockTable, 1, rowIdx, partA,   bgcolor=timeBg, text_color=colA,           text_size=clockTblSize)
        table.cell(clockTable, 2, rowIdx, partB,   bgcolor=timeBg, text_color=colB,           text_size=clockTblSize)
        table.cell(clockTable, 3, rowIdx, partC,   bgcolor=timeBg, text_color=colC,           text_size=clockTblSize)
````
