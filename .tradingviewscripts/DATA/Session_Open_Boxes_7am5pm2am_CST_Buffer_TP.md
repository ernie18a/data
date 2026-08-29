<!-- tradingview-pine-id: PUB;cbbb271192ca45dabba6a179b8a92e5e -->
<!-- tradingviewscripts-format: 1 -->
# Session Open Boxes (7am/5pm/2am CST) + Buffer + TP

Source: https://www.tradingview.com/script/p6PPc0AG-Prophet-Session-7am-5pm-2am-CST-Buffer-TP/

## Description

Trigger logic
Pulls the actual 5-minute/15-minute candle data — regardless of what timeframe you're viewing the chart on — so it works correctly on a 1m, 5m, 15m, or any other chart. It watches for the specific 5-min, 15-min candle whose open time (converted to CST) matches your three session anchors: 7:00 AM, 5:00 PM, and 2:00 AM CST. When the candle closes within the buffer top/bottom is your entry. Closes top - go long, closes bottom - go short, and use Take Profit indicator and opposite box for Stop Loss.

What gets drawn per session

Main box (teal) — the true high/low range of that first 5-min candle, extended forward 2.5 hours. This is your reference box.
Buffer zones (red, top and bottom) — two separate boxes sitting 30 ticks above the candle high and 30 ticks below the candle low. Pure visual padding, no other function.
TP1/TP2 lines (lime/purple, dashed) — sit at 100 and 200 ticks out from the main candle box's high/low (not the buffer edges), both above and below.
Tick count label — shows "5m: XXX ticks", "15m: XXX ticks" on the main box so you can visually verify against your own calculations.

Customizable inputs
Session on/off toggles, exact hour/minute per session, tick size, buffer ticks, TP1/TP2 tick distances, extension length, and all colors — all exposed in the settings panel, no code editing needed for day-to-day tuning.

---

## Source Code

````pine
//@version=6
indicator("Session Open Boxes (7am/5pm/2am CST) + Buffer + TP", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────────── INPUTS ─────────────────────────────
grpSessions = "Sessions (times are CST / America/Chicago)"
enableS1 = input.bool(true,  "Enable Session 1 (7:00 AM CST)", group = grpSessions)
h1       = input.int(7,  "Session 1 Hour (24h)",  minval = 0, maxval = 23, group = grpSessions)
m1       = input.int(0,  "Session 1 Minute",      minval = 0, maxval = 55, step = 5, group = grpSessions)

enableS2 = input.bool(true,  "Enable Session 2 (5:00 PM CST)", group = grpSessions)
h2       = input.int(17, "Session 2 Hour (24h)",  minval = 0, maxval = 23, group = grpSessions)
m2       = input.int(0,  "Session 2 Minute",      minval = 0, maxval = 55, step = 5, group = grpSessions)

enableS3 = input.bool(true,  "Enable Session 3 (2:00 AM CST)", group = grpSessions)
h3       = input.int(2,  "Session 3 Hour (24h)",  minval = 0, maxval = 23, group = grpSessions)
m3       = input.int(0,  "Session 3 Minute",      minval = 0, maxval = 55, step = 5, group = grpSessions)

grpBox = "Box / Tick Settings"
boxTF       = input.string("5", "Box Timeframe", options = ["5", "15"], group = grpBox)
tickSize    = input.float(0.25, "Tick Size", minval = 0.01, step = 0.01, group = grpBox)
bufferTicks = input.int(30, "Buffer Ticks (from candle high/low)", minval = 1, group = grpBox)
tp1Ticks    = input.int(100, "TP1 Ticks (from Main Candle Box edge)", minval = 1, group = grpBox)
tp2Ticks    = input.int(200, "TP2 Ticks (from Main Candle Box edge)", minval = 1, group = grpBox)
extendHours = input.float(2.5, "Forward Extension (hours)", minval = 0.1, step = 0.5, group = grpBox)

grpStyle = "Colors"
mainBoxColor = input.color(color.new(color.teal, 92),    "Main Candle Box Fill", group = grpStyle)
mainBoxBorder= input.color(color.new(color.teal, 40),    "Main Candle Box Border", group = grpStyle)
bufTopColor  = input.color(color.new(color.red, 70),     "Top Buffer Fill (resistance side)", group = grpStyle)
bufTopBorder = input.color(color.new(color.red, 20),     "Top Buffer Border", group = grpStyle)
bufBotColor  = input.color(color.new(color.red, 70),     "Bottom Buffer Fill (support side)", group = grpStyle)
bufBotBorder = input.color(color.new(color.red, 20),     "Bottom Buffer Border", group = grpStyle)
tp1Color     = input.color(color.new(color.lime, 0),     "TP1 Line", group = grpStyle)
tp2Color     = input.color(color.new(color.purple, 0),   "TP2 Line", group = grpStyle)
showLabels   = input.bool(true, "Show TP / Session Labels", group = grpStyle)
showTickCount= input.bool(true, "Show Tick Count Label on Main Box", group = grpStyle)

// ───────────────────────────── PULL ACTUAL CANDLE DATA AT SELECTED BOX TIMEFRAME ─────────────────────────────
// This guarantees the box always reflects the true 5m/15m candle's open/high/low/time,
// regardless of what timeframe the chart is currently displaying (1m, 5m, etc.)
[boxOpen, boxHigh, boxLow, boxClose, boxTime] = request.security(syminfo.tickerid, boxTF, [open, high, low, close, time], lookahead = barmerge.lookahead_off)

// Detect when a NEW box-timeframe candle has just formed (its timestamp changed)
newBoxCandle = ta.change(boxTime) != 0

// Convert the candle's own open time to CST to check against session targets
boxCstHour   = hour(boxTime, "America/Chicago")
boxCstMinute = minute(boxTime, "America/Chicago")

isSessionStart(hh, mm) =>
    boxCstHour == hh and boxCstMinute == mm

triggerS1 = enableS1 and isSessionStart(h1, m1) and newBoxCandle
triggerS2 = enableS2 and isSessionStart(h2, m2) and newBoxCandle
triggerS3 = enableS3 and isSessionStart(h3, m3) and newBoxCandle

extendMs = extendHours * 60 * 60 * 1000

// ───────────────────────────── DRAW FUNCTION ─────────────────────────────
drawSessionBox(bool trigger, string sessLabel) =>
    if trigger
        candleHigh = boxHigh
        candleLow  = boxLow
        leftTime   = boxTime
        rightTime  = boxTime + math.round(extendMs)
        tickCount  = math.round((candleHigh - candleLow) / tickSize)

        bufTop = candleHigh + bufferTicks * tickSize
        bufBot = candleLow  - bufferTicks * tickSize

        // TP levels now measured from the MAIN CANDLE BOX edges (high/low), not the buffer edges
        tp1Top = candleHigh + tp1Ticks * tickSize
        tp2Top = candleHigh + tp2Ticks * tickSize
        tp1Bot = candleLow  - tp1Ticks * tickSize
        tp2Bot = candleLow  - tp2Ticks * tickSize

        // Buffer boxes drawn first (behind) — separate top (resistance) and bottom (support) zones for clear color contrast
        box.new(left = leftTime, top = bufTop, right = rightTime, bottom = candleHigh,
                 xloc = xloc.bar_time,
                 border_color = bufTopBorder, bgcolor = bufTopColor, border_width = 1, border_style = line.style_dashed, extend = extend.none)
        box.new(left = leftTime, top = candleLow, right = rightTime, bottom = bufBot,
                 xloc = xloc.bar_time,
                 border_color = bufBotBorder, bgcolor = bufBotColor, border_width = 1, border_style = line.style_dashed, extend = extend.none)

        // Main box = TRUE 5-minute candle range (high/low), anchored at the candle's real open time
        box.new(left = leftTime, top = candleHigh, right = rightTime, bottom = candleLow,
                 xloc = xloc.bar_time,
                 border_color = mainBoxBorder, bgcolor = mainBoxColor, border_width = 2, extend = extend.none)

        if showTickCount
            label.new(leftTime, candleHigh, str.format("{0}m: {1} ticks", boxTF, tickCount), xloc = xloc.bar_time, color = color.new(color.black, 30), textcolor = color.white, style = label.style_label_right, size = size.small)

        // TP lines
        line.new(leftTime, tp1Top, rightTime, tp1Top, xloc = xloc.bar_time, color = tp1Color, width = 1, style = line.style_dashed)
        line.new(leftTime, tp2Top, rightTime, tp2Top, xloc = xloc.bar_time, color = tp2Color, width = 1, style = line.style_dashed)
        line.new(leftTime, tp1Bot, rightTime, tp1Bot, xloc = xloc.bar_time, color = tp1Color, width = 1, style = line.style_dashed)
        line.new(leftTime, tp2Bot, rightTime, tp2Bot, xloc = xloc.bar_time, color = tp2Color, width = 1, style = line.style_dashed)

        if showLabels
            label.new(rightTime, tp1Top, "TP1 +" + str.tostring(tp1Ticks), xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = tp1Color, style = label.style_label_left, size = size.small)
            label.new(rightTime, tp2Top, "TP2 +" + str.tostring(tp2Ticks), xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = tp2Color, style = label.style_label_left, size = size.small)
            label.new(rightTime, tp1Bot, "TP1 -" + str.tostring(tp1Ticks), xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = tp1Color, style = label.style_label_left, size = size.small)
            label.new(rightTime, tp2Bot, "TP2 -" + str.tostring(tp2Ticks), xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = tp2Color, style = label.style_label_left, size = size.small)
            label.new(leftTime, candleLow, sessLabel, xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = color.white, style = label.style_label_up, size = size.small)

drawSessionBox(triggerS1, "7:00 AM CST")
drawSessionBox(triggerS2, "5:00 PM CST")
drawSessionBox(triggerS3, "2:00 AM CST")
````
