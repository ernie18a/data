# MTF Candle Countdown: Multi-Timeframe Close Timer 

- url: https://www.tradingview.com/script/PhtBKjvB-MTF-Candle-Countdown-Multi-Timeframe-Close-Timer/
- type: indicator
- pine_id: PUB;26a32d743596475f8019297132ff7855
- version: 1.0

## Description

⏳ Know exactly how long until your candles close — on up to 4 timeframes at once, in one clean panel.
Stop switching charts to check the 1H or 4H while you trade the 5m. See every countdown you care about in one place.
──────────────────────────
✅ WHAT IT DOES
Shows a live countdown to candle close for up to 4 timeframes you choose, side by side. Each row shows the timeframe, the time left, and the exact clock time that candle will close.
──────────────────────────
⚙️ WHAT YOU CAN CONTROL
• Up to 4 timeframes — pick any, turn each on/off
• Corner — any of the 4 chart corners
• Font size — Small, Medium, or Large
• Text + background colors
• Close-time column — show/hide, and choose its timezone
• Near-close highlight — a row turns amber in the final seconds before close
──────────────────────────
🔔 ALERTS (two independent switches, both optional)
• "Closing soon" — fires shortly before a candle closes (your heads-up)
• "Candle closed" — fires the moment a candle closes (your confirmation)
Turn on either, both, or neither.
──────────────────────────
🌍 TIMEZONE — SET IT ONCE
TradingView scripts can't read your chart's timezone, so pick yours in the "Close-time timezone" setting (New York, London, Tokyo, UTC, etc.). Set it to match your chart and the close times line up perfectly. Daylight saving is handled automatically.
──────────────────────────
ℹ️ GOOD TO KNOW
• A countdown timeframe must be the same as or higher than your chart timeframe. (A 1-minute countdown needs a ≤1-minute chart.) Rows below your chart timeframe show a gentle "use ≤Xm chart" reminder.
• Works on any symbol — crypto, forex, futures, stocks.
• On closed markets the countdown pauses until trading resumes (this is normal for all indicators).
• Not designed for Bar Replay — use it on a live chart.
──────────────────────────
🚀 HOW TO USE
1. Add to your chart
2. Open settings (gear icon)
3. Choose your timeframes, timezone, colors, and corner
──────────────────────────
👨‍💻 FOR DEVELOPERS / AUTOMATION
Set "Alert message format" to JSON event and the alerts emit a structured, webhook-ready payload (sent as application/json):
   {"ticker":"BTCUSD","exchange":"COINBASE","timeframe":"4H","event":"closed","price":60800.5,"time":1749264000000}
("closing_soon" events also include "seconds_left".)
This is a TIMING EVENT source, not an order engine — it tells you WHEN a candle closes, with no buy/sell baked in (a countdown has no direction). Route the event to your webhook receiver or bridge (CrossTrade, NinjaView, your own listener, n8n, etc.) and map it to your platform's order format there. Each event fires once per candle (no spam). Prefer "Plain text" format for human phone/email alerts.
──────────────────────────
Free and open-source. Feedback welcome 🙏

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandlesofKarma

//@version=6
indicator("MTF Candle Countdown", overlay = true)

// ============================================================
//  Multi-Timeframe Candle Countdown — v1.3
// © CandlesofKarma
//  Live time-to-close for up to 4 chosen timeframes at once.
//  Engine: native time_close(tf) - timenow  (no request.security).
//  NOTE: a countdown timeframe must be >= the chart timeframe
//  (a script can't update faster than the chart's bars). Rows
//  below the chart TF show a "use <=Xm chart" hint instead.
//  Close-time is shown in a user-selected timezone (Pine cannot
//  read the chart's own timezone setting).
//  Alerts can emit plain text (for humans) or a structured JSON
//  EVENT (for webhook automation). It is a timing event source,
//  NOT an order engine — your bridge/automation maps events to
//  orders in its own required format.
// ============================================================

// ---------- Inputs: Timeframes ----------
gTF = "Timeframes"
tf1On = input.bool(true, "", inline = "tf1", group = gTF)
tf1   = input.timeframe("5",   "Timeframe 1", inline = "tf1", group = gTF)
tf2On = input.bool(true, "", inline = "tf2", group = gTF)
tf2   = input.timeframe("15",  "Timeframe 2", inline = "tf2", group = gTF)
tf3On = input.bool(true, "", inline = "tf3", group = gTF)
tf3   = input.timeframe("60",  "Timeframe 3", inline = "tf3", group = gTF)
tf4On = input.bool(true, "", inline = "tf4", group = gTF)
tf4   = input.timeframe("240", "Timeframe 4", inline = "tf4", group = gTF)

// ---------- Inputs: Display ----------
gDisp = "Display"
posInput  = input.string("Top Right", "Corner", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = gDisp)
sizeInput = input.string("Medium", "Font size", options = ["Small", "Medium", "Large"], group = gDisp)
txtColor  = input.color(color.white, "Text color", group = gDisp)
bgColor   = input.color(color.new(#1e222d, 20), "Background color", group = gDisp)
showClose = input.bool(true, "Show close time column", group = gDisp)
tzInput   = input.string("New York", "Close-time timezone", options = ["Exchange", "New York", "Chicago", "London", "Frankfurt", "Tokyo", "Sydney", "UTC"], group = gDisp)

// ---------- Inputs: Near-close highlight ----------
gHL = "Near-close highlight"
highlightOn  = input.bool(true, "Enable highlight", group = gHL)
thresholdSec = input.int(60, "Threshold (seconds)", minval = 1, group = gHL)
highlightCol = input.color(#ffa726, "Highlight color", group = gHL)

// ---------- Inputs: Alerts ----------
gAL = "Alerts"
alertFormat   = input.string("Plain text", "Alert message format", options = ["Plain text", "JSON event"], group = gAL, tooltip = "Plain text = human-readable. JSON event = structured payload for webhooks/automation (ticker, timeframe, event, price, time).")
alertSoonOn   = input.bool(false, "Alert: closing soon (at threshold)", group = gAL)
alertClosedOn = input.bool(false, "Alert: candle closed", group = gAL)

// ---------- Mappings ----------
tablePos = switch posInput
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

txtSize = switch sizeInput
    "Small"  => size.small
    "Medium" => size.normal
    "Large"  => size.large
    => size.normal

closeTz = switch tzInput
    "Exchange"  => syminfo.timezone
    "New York"  => "America/New_York"
    "Chicago"   => "America/Chicago"
    "London"    => "Europe/London"
    "Frankfurt" => "Europe/Berlin"
    "Tokyo"     => "Asia/Tokyo"
    "Sydney"    => "Australia/Sydney"
    "UTC"       => "UTC"
    => "America/New_York"

// ---------- Helpers ----------
f_pad(int n) => (n < 10 ? "0" : "") + str.tostring(n)

f_fmtCountdown(int totalSec) =>
    s   = math.max(totalSec, 0)
    d   = int(s / 86400)
    h   = int(s % 86400 / 3600)
    m   = int(s % 3600 / 60)
    sec = int(s % 60)
    d > 0 ? str.tostring(d) + "d " + f_pad(h) + ":" + f_pad(m) + ":" + f_pad(sec) : h > 0 ? f_pad(h) + ":" + f_pad(m) + ":" + f_pad(sec) : f_pad(m) + ":" + f_pad(sec)

// Friendly timeframe label ("240"->"4H", "D"->"1D"). Uses seconds to avoid string parsing.
f_tfLabel(string tf) =>
    secs = timeframe.in_seconds(tf)
    switch
        secs >= 2628003 and secs % 2628003 == 0 => str.tostring(int(secs / 2628003)) + "M"
        secs >= 604800  and secs % 604800  == 0 => str.tostring(int(secs / 604800))  + "W"
        secs >= 86400   and secs % 86400   == 0 => str.tostring(int(secs / 86400))   + "D"
        secs >= 3600    and secs % 3600    == 0 => str.tostring(int(secs / 3600))    + "H"
        secs >= 60      and secs % 60      == 0 => str.tostring(int(secs / 60))      + "m"
        => str.tostring(secs) + "s"

// Build the alert message. Plain text for humans, or a structured JSON EVENT for
// webhook automation. secsLeft < 0 means "not applicable" (a close event).
f_alertMsg(string tfLbl, string ev, int secsLeft) =>
    if alertFormat == "JSON event"
        b = '{"ticker":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","timeframe":"' + tfLbl + '","event":"' + ev + '","price":' + str.tostring(close) + ',"time":' + str.tostring(timenow)
        secsLeft >= 0 ? b + ',"seconds_left":' + str.tostring(secsLeft) + '}' : b + '}'
    else
        ev == "closing_soon" ? syminfo.ticker + " " + tfLbl + " closing in ~" + str.tostring(secsLeft) + "s" : syminfo.ticker + " " + tfLbl + " candle closed"

// ---------- Slot arrays ----------
ons = array.from(tf1On, tf2On, tf3On, tf4On)
tfs = array.from(tf1, tf2, tf3, tf4)

enabledCount = 0
for i = 0 to 3
    if array.get(ons, i)
        enabledCount := enabledCount + 1

cols      = showClose ? 3 : 2
rowCount  = math.max(enabledCount, 1)
chartSecs = timeframe.in_seconds(timeframe.period)   // resolution of the chart itself

// ---------- Render ----------
var table t = table.new(tablePos, cols, rowCount, bgcolor = bgColor)
if barstate.islast
    if enabledCount == 0
        table.cell(t, 0, 0, "Enable a timeframe in settings", text_color = txtColor, text_size = txtSize, bgcolor = bgColor)
    else
        rowIdx = 0
        for i = 0 to 3
            if array.get(ons, i)
                tf      = array.get(tfs, i)
                isSubTf = timeframe.in_seconds(tf) < chartSecs       // below the chart TF -> can't track
                tc      = time_close(tf)
                remSec  = na(tc) ? na : int((tc - timenow) / 1000)
                cdText  = isSubTf ? "use ≤" + f_tfLabel(tf) + " chart" : (na(remSec) or remSec <= 0) ? "—" : f_fmtCountdown(remSec)
                isSoon  = not isSubTf and not na(remSec) and remSec > 0 and remSec <= thresholdSec
                cdColor = (highlightOn and isSoon) ? highlightCol : txtColor
                table.cell(t, 0, rowIdx, f_tfLabel(tf), text_color = txtColor, text_size = txtSize, bgcolor = bgColor)
                table.cell(t, 1, rowIdx, cdText, text_color = cdColor, text_size = txtSize, bgcolor = bgColor)
                if showClose
                    ctText = (isSubTf or na(tc)) ? "—" : "→ " + str.format_time(tc, "h:mm a", closeTz)
                    table.cell(t, 2, rowIdx, ctText, text_color = txtColor, text_size = txtSize, bgcolor = bgColor)
                rowIdx := rowIdx + 1

// ---------- Alerts ----------
var soonFired = array.new_bool(4, false)
for i = 0 to 3
    if array.get(ons, i)
        tf = array.get(tfs, i)
        if timeframe.in_seconds(tf) >= chartSecs                    // skip sub-chart-TF rows
            if timeframe.change(tf)
                array.set(soonFired, i, false)                      // new candle -> re-arm the warning
                if alertClosedOn
                    alert(f_alertMsg(f_tfLabel(tf), "closed", -1), alert.freq_once_per_bar)
            if alertSoonOn
                tc     = time_close(tf)
                remSec = na(tc) ? na : int((tc - timenow) / 1000)
                if not na(remSec) and remSec > 0 and remSec <= thresholdSec and not array.get(soonFired, i)
                    alert(f_alertMsg(f_tfLabel(tf), "closing_soon", remSec), alert.freq_once_per_bar)
                    array.set(soonFired, i, true)                   // fire once per candle
````
