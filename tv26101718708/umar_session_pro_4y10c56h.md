# Umar Session Pro

- url: https://www.tradingview.com/script/4Y10C56H-Umar-Session-Pro/
- type: indicator
- pine_id: PUB;e6c085a4fcb74ba28d7306f77798465a
- version: 1.0

## Description

** Sessions Dashboard — Asia, London & New York**

This indicator displays the Asia, London, and New York trading sessions using thin vertical lines on the chart.

**Features:**
- Asia session boundaries — Green
- London session boundaries — Blue
- New York session boundaries — Red
- Vertical lines mark both the session opening and closing times.
- Dashboard displays session timings and ACTIVE/CLOSED status.
- UAE current time (GMT+4) is displayed on the dashboard.
- Session time zones automatically adjust for daylight saving time where applicable.
- Customizable session hours, colors, and visibility settings.

**How to Use:**
Add the indicator to your TradingView chart. It can be used on Gold (XAUUSD), forex pairs, indices, and other markets to help visualize trading sessions.

**Note:** Session timings are configurable. Please verify the settings for your preferred market and trading strategy. This indicator is designed for session visualization only and does not generate buy or sell signals.

## Source Code

````pine

 //@version=6
indicator("Umar Session Pro", overlay=true, max_lines_count=500)

// ───── SESSION SETTINGS ─────
asiaSession   = input.session("0900-1800", "Asia Session")
londonSession = input.session("0800-1700", "London Session")
nySession     = input.session("0800-1700", "New York Session")

asiaTZ   = input.string("Asia/Tokyo", "Asia Timezone")
londonTZ = input.string("Europe/London", "London Timezone")
nyTZ     = input.string("America/New_York", "New York Timezone")

showAsia      = input.bool(true, "Show Asia Lines")
showLondon    = input.bool(true, "Show London Lines")
showNY        = input.bool(true, "Show New York Lines")
showDashboard = input.bool(true, "Show Dashboard")

asiaColor   = input.color(color.green, "Asia Color")
londonColor = input.color(color.blue, "London Color")
nyColor     = input.color(color.red, "New York Color")

// ───── TIMEFRAME FILTER ─────
// Show lines on 30-minute charts and below.
showSessionLines = timeframe.isintraday and timeframe.in_seconds() <= 30 * 60

// ───── SESSION DETECTION ─────
asiaIn   = not na(time(timeframe.period, asiaSession, asiaTZ))
londonIn = not na(time(timeframe.period, londonSession, londonTZ))
nyIn     = not na(time(timeframe.period, nySession, nyTZ))

asiaStart   = asiaIn and not asiaIn[1]
asiaEnd     = not asiaIn and asiaIn[1]

londonStart = londonIn and not londonIn[1]
londonEnd   = not londonIn and londonIn[1]

nyStart     = nyIn and not nyIn[1]
nyEnd       = not nyIn and nyIn[1]

// ───── VERTICAL LINE FUNCTION ─────
drawBoundary(color clr) =>
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=clr,
         width=1)

// ───── ASIA ─────
if showSessionLines and showAsia and asiaStart
    drawBoundary(asiaColor)

if showSessionLines and showAsia and asiaEnd
    drawBoundary(asiaColor)

// ───── LONDON ─────
if showSessionLines and showLondon and londonStart
    drawBoundary(londonColor)

if showSessionLines and showLondon and londonEnd
    drawBoundary(londonColor)

// ───── NEW YORK ─────
if showSessionLines and showNY and nyStart
    drawBoundary(nyColor)

if showSessionLines and showNY and nyEnd
    drawBoundary(nyColor)

// ───── DASHBOARD ─────
fmtSession(string s) =>
    str.substring(s, 0, 2) + ":" +
     str.substring(s, 2, 4) + " - " +
     str.substring(s, 5, 7) + ":" +
     str.substring(s, 7, 9)

var table dash = table.new(position.top_right, 3, 5, border_width=1)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "SESSION", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, 0, "LOCAL TIME", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 2, 0, "STATUS", bgcolor=color.black, text_color=color.white)

        table.cell(dash, 0, 1, "ASIA", bgcolor=asiaColor, text_color=color.white)
        table.cell(dash, 1, 1, fmtSession(asiaSession), text_color=asiaColor)
        table.cell(dash, 2, 1, asiaIn ? "ACTIVE" : "CLOSED",
             bgcolor=asiaIn ? color.green : color.gray, text_color=color.white)

        table.cell(dash, 0, 2, "LONDON", bgcolor=londonColor, text_color=color.white)
        table.cell(dash, 1, 2, fmtSession(londonSession), text_color=londonColor)
        table.cell(dash, 2, 2, londonIn ? "ACTIVE" : "CLOSED",
             bgcolor=londonIn ? color.green : color.gray, text_color=color.white)

        table.cell(dash, 0, 3, "NEW YORK", bgcolor=nyColor, text_color=color.white)
        table.cell(dash, 1, 3, fmtSession(nySession), text_color=nyColor)
        table.cell(dash, 2, 3, nyIn ? "ACTIVE" : "CLOSED",
             bgcolor=nyIn ? color.green : color.gray, text_color=color.white)

        table.cell(dash, 0, 4, "UAE TIME", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, 4, "Dubai GMT+4", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 2, 4,
             str.format_time(timenow, "HH:mm:ss", "Asia/Dubai"),
             bgcolor=color.black, text_color=color.white)
    else
        table.clear(dash, 0, 0, 2, 4)
````
