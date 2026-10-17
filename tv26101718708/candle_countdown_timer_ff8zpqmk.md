# Candle Countdown Timer

- url: https://www.tradingview.com/script/fF8zPQMK-Candle-Countdown-Timer/
- type: indicator
- pine_id: PUB;9001d9e6c8974e929b276d02d1d1990a
- version: 1.0

## Description

A simple chart-based timer designed to help traders stay aware of upcoming candle closes.

Trading Timer provides a real-time countdown to the next candle close directly on your chart, helping you prepare for timeframe changes, review setups, and maintain a consistent trading routine.

Built for discretionary traders who rely on candle closes as important decision points, the indicator provides a clean visual countdown, optional alerts, and a compact dashboard that stays out of the way of your analysis.

---

[b]Features[/b]

✓ Real-time candle close countdown
✓ Customisable timeframe selection
✓ Alerts before candle close
✓ Automatic symbol recognition
✓ Mobile notifications through TradingView alerts
✓ Compact dashboard display
✓ Minimal mode for a cleaner workspace
✓ Colour-coded timing zones:

Countdown Phases:
🔵Dark grey — waiting
🟡Yellow — approaching close
🔴Red — final minute

---

[b]Alert Setup[/b]

To receive notifications, create a TradingView alert after adding Trading Timer to your chart.

Recommended setup:
[list=1]
[*]Add Trading Timer to your preferred chart timeframe (for example, 15 minutes).
[*]Open TradingView's Alert menu.
[*]Under Condition, select:
[*]Trading Timer → Any alert() function call
[*]Choose your preferred notification options
[*]Create the alert.
[/list]
The alert is linked to the chart where it was created. If you want alerts for multiple markets (for example Gold and NAS100), create a separate alert for each chart.

For mobile notifications, make sure TradingView app notifications are enabled on your device.

[b]Example Setup:[/b]

For a 15-minute trading setup, set the indicator to 15 minutes and choose your preferred warning time (for example, 1 minute before close)."

The timer keeps you informed so you can focus on the chart instead of watching the clock!

---

[b] Intended Use[/b]

Trading Timer is a timing and workflow tool. It does not provide trade signals, entries, exits, or predictions.

It is designed to help traders:
[list]
[*]Prepare before candle closes
[*]Review setups at consistent intervals
[*]Manage multi-timeframe workflows
[*]Stay disciplined with candle-based analysis
[/list]
Suitable for markets including forex, futures, indices, commodities, stocks, and crypto.

---

How it looks on the charts:
[image]https://www.tradingview.com/x/IJtwq5E4/[/image]

Compact Dashboard Display:
[image]https://www.tradingview.com/x/grcZ49se/[/image]

## Source Code

````pine
//@version=6
indicator("Trading Timer - Candle Countdown & Alerts ","Candle Countdown Timer", overlay=true)

//========================
// SETTINGS
//========================

targetMinutes = input.int(
     15,
     "Target Candle Timeframe",
     options=[5,15,30,60,240])

alertMinutes = input.int(
     1,
     "Alert Before Close (minutes)",
     minval=0,
     maxval=10)

showPanel = input.bool(true, "Show Timer")

minimalMode = input.bool(
     false,
     "Minimal Mode")

showBorder = input.bool(
     true,
     "Show Border")

autoMarket = input.bool(
     true,
     "Use Automatic Symbol Name")

customMarket = input.string(
     "Gold",
     "Custom Market Name")

displayMarket =
     autoMarket ?
     syminfo.ticker :
     customMarket



//========================
// GET 1 MINUTE CLOCK
//========================

oneMinuteTime = request.security(
     syminfo.tickerid,
     "1",
     time,
     lookahead=barmerge.lookahead_on)

currentTime = timenow

tfMillis = targetMinutes * 60 * 1000

nextClose =
     (math.floor(currentTime / tfMillis) + 1) * tfMillis

remaining =
     math.max(0, math.floor((nextClose - currentTime) / 1000))

mins = math.floor(remaining / 60)
secs = remaining % 60

countdown =
     str.tostring(mins, "00") + ":" +
     str.tostring(secs, "00")

//========================
// ALERT
//========================

var bool alerted = false

warning =
     remaining <= alertMinutes * 60 and
     remaining > 0

if remaining > alertMinutes * 60
    alerted := false

if warning and not alerted
    alert(
     "🔔 " +
     displayMarket +
     " " +
     str.tostring(targetMinutes) +
     "m candle closing soon",
     alert.freq_once_per_bar)

    alerted := true

//========================
// COLOUR
//========================

panelColour =
     remaining <= 60 ? color.red :
     remaining <= 300 ? color.yellow :
     color.rgb(45,45,45)

fontColour =
     panelColour == color.yellow ?
     color.black :
     color.white


//========================
// COMPACT PANEL
//========================

statusText =
     remaining <= 60 ? "CHECK" :
     remaining <= 300 ? "WATCH" :
     "WAIT"


panelText =
     minimalMode ?
     countdown :
     displayMarket + "\n" +
     str.tostring(targetMinutes) + "M\n" +
     countdown + "\n" +
     statusText


var table timer =
     table.new(
     position.top_right,
     1,
     1,
     border_width = showBorder ? 2 : 0,
     frame_color = color.black,
     frame_width = showBorder ? 2 : 0)


if barstate.islast and showPanel

    textColour =
         panelColour == color.yellow ?
         color.black :
         color.white

    table.cell(
     timer,
     0,
     0,
     panelText,
     bgcolor=panelColour,
     text_color=textColour,
     text_size = minimalMode ? size.large : size.normal)
````
