# Time Alerts

- url: https://www.tradingview.com/script/d3bVJ7FX-Time-Alerts/
- type: indicator
- pine_id: PUB;adcd4fa75ca44a0b8f40548f06c76bfc
- version: 1.0

## Description

Clean time-based alerts for H1, H4, H6, 90M, Daily open, and NY 08:30/09:30 AM session opens.


Press Alt + A to open the alert configuration window. 

Change the top Condition dropdown from the asset ticker to Time Alerts.

Select your desired trigger (e.g., H4 New Candle Open or 09:30 AM Equities Open) from the secondary dropdown.

Set the trigger action to Once Per Bar and click Create. 

Repeat for other timeframes.

## Source Code

````pine
//@version=6
indicator("Time Alerts", overlay=true)

// --- 1. Higher Timeframe New Candle Opens ---
new_bar(string tf) =>
    ta.change(time(tf)) != 0

h1_open  = new_bar("60")
h4_open  = new_bar("240")
h6_open  = new_bar("360")
m90_open = new_bar("90")
d_open   = new_bar("D")

// --- 2. Precise Intraday Time Triggers (NY Time) ---
// 08:30 AM News
in_news_minute = not na(time(timeframe.period, "0830-0831:23456", "America/New_York"))
news_alert     = in_news_minute and not in_news_minute[1]

// 09:30 AM Equities Open
in_eq_open_minute = not na(time(timeframe.period, "0930-0931:23456", "America/New_York"))
eq_open_alert     = in_eq_open_minute and not in_eq_open_minute[1]

// --- 3. UI Chart Plots (Visual Verification) ---
plotshape(h1_open,       title="H1 Open",       style=shape.triangleup, location=location.belowbar, color=color.blue,   size=size.small, display=display.none)
plotshape(h4_open,       title="H4 Open",       style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.small, display=display.none)
plotshape(h6_open,       title="H6 Open",       style=shape.triangleup, location=location.belowbar, color=color.purple, size=size.small, display=display.none)
plotshape(m90_open,      title="90M Open",      style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.small, display=display.none)
plotshape(d_open,        title="Daily Open",    style=shape.diamond,    location=location.belowbar, color=color.green,  size=size.small)
plotshape(news_alert,    title="08:30 AM News", style=shape.flag,       location=location.abovebar, color=color.red,    size=size.small)
plotshape(eq_open_alert, title="09:30 AM Open", style=shape.flag,       location=location.abovebar, color=color.aqua,   size=size.small)

// --- 4. Alert Conditions ---
alertcondition(h1_open,       title="H1 New Candle Open",   message="H1")
alertcondition(h4_open,       title="H4 New Candle Open",   message="H4")
alertcondition(h6_open,       title="H6 New Candle Open",   message="H6")
alertcondition(m90_open,      title="90M New Candle Open",  message="m90")
alertcondition(d_open,        title="Daily Session Open",   message="D1")
alertcondition(news_alert,    title="08:30 AM News Trigger", message="[NEWS] 08:30 AM")
alertcondition(eq_open_alert, title="09:30 AM Equities Open", message="[OPEN] 09:30 AM")
````
