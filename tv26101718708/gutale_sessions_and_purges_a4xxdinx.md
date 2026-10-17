# Gutale Sessions and Purges

- url: https://www.tradingview.com/script/A4XXdInx-Gutale-Sessions-and-Purges/
- type: indicator
- pine_id: PUB;3bf927a406154116985a96357b8bd1e6
- version: 1.0

## Description

# Gutale Sessions and Purges

[b]## Overview[/b]

Gutale Sessions and Purges is a Pine Script v6 overlay indicator designed to help traders monitor key trading sessions and selected purge times directly on their charts. It combines a session dashboard, a live New York clock, purge status information, and the next scheduled purge time in one organized display.

The indicator is intended to support structured intraday market analysis by helping traders keep track of important time windows and observe price behavior during their preferred trading sessions.

## Key Features

**1. Trading Session Monitoring**

The dashboard displays five session periods: Pre-Asian, Asian, London, Pre-New York, and New York. This helps traders follow their trading schedule and identify the current session according to New York time.

**2. Purge Time Tracking**

The indicator monitors selected purge hours: 8 PM, 9 PM, 10 PM, 2 AM, 3 AM, 6 AM, 8 AM, and 9 AM and 10 AM. The dashboard displays the current purge status when the chart's candle time falls within one of these hours.

**3. Next Purge Time**

The dashboard displays the next scheduled purge time based on the current New York clock. This gives traders a convenient reference for preparing to observe upcoming time windows.

**4. Purge Labels Above Candles**

On the 1-hour timeframe, the indicator can display time labels such as 8PM, 9PM, 10PM, 2AM, 3AM, 6AM, 8AM, 9AM, and 10AM above the relevant candles. Labels are limited to the most recent five days and can be enabled or disabled in the settings.

**5. New York Clock**

A live clock displays New York time, including hours, minutes, seconds, and AM/PM. This helps traders coordinate their chart analysis with the indicator's scheduled session and purge times.

**6. Customizable Dashboard**

Users can choose the dashboard position from four chart corners and adjust the text size to suit their preferred layout. These settings help maintain a clear and organized chart display.

**7. Alert Condition**

The indicator includes an alert condition for the defined purge hours. Traders can use this condition to configure alerts in TradingView and monitor their selected time windows.

## How to Use

1. Add Gutale Sessions and Purges to your TradingView chart.
2. Check the dashboard to identify the current session and purge status.
3. Review the Next Purge field to see the next scheduled purge hour.
4. Switch to the 1-hour timeframe to view the purge labels above relevant candles.
5. Adjust the dashboard position and text size in the indicator settings.
6. Enable or disable purge labels according to your preferences.
7. Observe price action during the marked periods and combine the timing information with your own trading analysis.

## Originality and Practical Usefulness

Gutale Sessions and Purges brings session monitoring, scheduled purge-time tracking, a New York clock, next-purge information, and configurable dashboard controls into one dedicated chart overlay.

Its purpose is to provide a convenient visual reference for traders who follow a structured session-based trading routine. By keeping relevant time information in one place, the indicator can help reduce the need to track each time window manually.

The indicator focuses on time organization and chart monitoring rather than generating automated trading signals. Its usefulness depends on how traders incorporate the displayed information into their own analysis.

## Important Limitations

This indicator is a time-based chart analysis tool. It does not confirm that a liquidity sweep, market structure shift, reversal, breakout, or other price-action event has occurred.

A marked purge hour represents a scheduled time window, not a guarantee of a trading opportunity. Market behavior can vary across instruments, trading sessions, and market conditions.

The indicator uses the America/New_York time zone for its session and purge calculations. Users should understand the displayed schedule and verify that it aligns with their intended trading routine.

The candle labels are designed for the 1-hour timeframe and are limited to the most recent five days. The dashboard and time labels should be used as references alongside independent price-action analysis and appropriate risk management.

## Disclaimer

Gutale Sessions and Purges is provided for educational and analytical purposes only. It does not provide financial advice, guarantee trading results, or replace independent market analysis. Traders are responsible for their own trading decisions and risk management.

## Source Code

````pine

 //@version=6
indicator("Gutale Sessions and Purges", overlay=true)

//━━━━━━━━━━━━━━━━━━━
// Dashboard Settings
//━━━━━━━━━━━━━━━━━━━
table_pos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])
position_control = table_pos == "Top Right" ? position.top_right : table_pos == "Bottom Right" ? position.bottom_right : table_pos == "Top Left" ? position.top_left : position.bottom_left

//━━━━━━━━━━━━━━━━━━━
// Responsive Text Size Settings
//━━━━━━━━━━━━━━━━━━━
text_size_input = input.string("Normal", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Dashboard Appearance")
dash_size = text_size_input == "Tiny" ? size.tiny : text_size_input == "Small" ? size.small : text_size_input == "Large" ? size.large : size.normal

//━━━━━━━━━━━━━━━━━━━
// Purge Visuals
//━━━━━━━━━━━━━━━━━━━
show_candle_labels = input.bool(true, "Show Purge Labels Above Candles", group="Purge Visuals")

//━━━━━━━━━━━━━━━━━━━
// Theme & Time Calculations
//━━━━━━━━━━━━━━━━━━━
bg_color  = color.new(#131722, 0)
txt_color = color.white
hdr_color = color.yellow

nyLiveHour   = hour(timenow, "America/New_York")
nyLiveMinute = minute(timenow, "America/New_York")
nyLiveSecond = second(timenow, "America/New_York")
nyLiveHour12 = nyLiveHour % 12 == 0 ? 12 : nyLiveHour % 12
nyLiveAmPm   = nyLiveHour >= 12 ? "PM" : "AM"

nyTimeText = str.tostring(nyLiveHour12) + ":" + str.tostring(nyLiveMinute, "00") + ":" + str.tostring(nyLiveSecond, "00") + " " + nyLiveAmPm

nyHour = hour(time, "America/New_York")

currentSession = nyHour >= 17 and nyHour < 21 ? "Pre Asian" : nyHour >= 21 or nyHour < 1 ? "Asian" : nyHour >= 1 and nyHour < 5 ? "London" : nyHour >= 5 and nyHour < 9 ? "Pre NY" : "New York"

purgeActive = nyHour == 20 or nyHour == 21 or nyHour == 22 or nyHour == 2 or nyHour == 3 or nyHour == 6 or nyHour == 8 or nyHour == 9 or nyHour == 10

//━━━━━━━━━━━━━━━━━━━
// Next Purge Time
//━━━━━━━━━━━━━━━━━━━
int nextPurgeHour = na

for i = 1 to 24
    candidateHour = (nyLiveHour + i) % 24
    candidateIsPurge = candidateHour == 20 or candidateHour == 21 or candidateHour == 22 or candidateHour == 2 or candidateHour == 3 or candidateHour == 6 or candidateHour == 8 or candidateHour == 9 or candidateHour == 10

    if candidateIsPurge and na(nextPurgeHour)
        nextPurgeHour := candidateHour

nextPurgeHour12 = na(nextPurgeHour) ? 0 : nextPurgeHour % 12 == 0 ? 12 : nextPurgeHour % 12
nextPurgeAmPm = na(nextPurgeHour) ? "" : nextPurgeHour >= 12 ? "PM" : "AM"
nextPurgeText = na(nextPurgeHour) ? "N/A" : str.tostring(nextPurgeHour12) + nextPurgeAmPm

//━━━━━━━━━━━━━━━━━━━
// Candle Labels
// 1-Hour Timeframe & Last 5 Days Only
//━━━━━━━━━━━━━━━━━━━
isNewHour = ta.change(nyHour) != 0

fiveDaysInMs = 5 * 24 * 60 * 60 * 1000
isWithinLast5Days = (timenow - time) <= fiveDaysInMs

isOneHour = timeframe.isminutes and timeframe.multiplier == 60

string labelText = na

if isNewHour and show_candle_labels and isWithinLast5Days and isOneHour
    if nyHour == 20
        labelText := "8PM"
    else if nyHour == 21
        labelText := "9PM"
    else if nyHour == 22
        labelText := "10PM"
    else if nyHour == 2
        labelText := "2AM"
    else if nyHour == 3
        labelText := "3AM"
    else if nyHour == 6
        labelText := "6AM"
    else if nyHour == 8
        labelText := "8AM"
    else if nyHour == 9
        labelText := "9AM"
    else if nyHour == 10
        labelText := "10AM"

// Qoraalka waxaa lagu qorayaa candle-ka korkiisa.
// Wax color ah laguma darayo candle-ka ama chart-ka.
if not na(labelText)
    label.new(bar_index, high, labelText, yloc=yloc.abovebar, color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal)

//━━━━━━━━━━━━━━━━━━━
// Dashboard Status
//━━━━━━━━━━━━━━━━━━━
statusText = nyHour == 20 ? "⚠ 8PM ACTIVE" : nyHour == 21 ? "⚠ 9PM ACTIVE" : nyHour == 22 ? "⚠ 10PM ACTIVE" : nyHour == 2 ? "⚠ 2AM ACTIVE" : nyHour == 3 ? "⚠ 3AM ACTIVE" : nyHour == 6 ? "⚠ 6AM ACTIVE" : nyHour == 8 ? "⚠ 8AM ACTIVE" : nyHour == 9 ? "⚠ 9AM ACTIVE" : nyHour == 10 ? "⚠ 10AM ACTIVE" : "Waiting"

statusColor = purgeActive ? color.yellow : color.white

//━━━━━━━━━━━━━━━━━━━
// Dashboard Creation
//━━━━━━━━━━━━━━━━━━━
var table gutale_table = table.new(position_control, 1, 10, bgcolor=bg_color, border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(gutale_table, 0, 0, "📌 GUTALE SESSIONS & PURGES", text_color=hdr_color, text_size=dash_size)
    table.cell(gutale_table, 0, 1, "🕒 Current Session: " + currentSession, text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 2, "Status: " + statusText, text_color=statusColor, text_size=dash_size)
    table.cell(gutale_table, 0, 3, "✅ PRE ASIAN (5PM ---- PURGE 8PM)", text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 4, "✅ ASIAN (9PM ---- PURGE 9PM, 10PM)", text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 5, "✅ LONDON (1AM ---- PURGE 2AM, 3AM)", text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 6, "✅ PRE NY (5AM ---- PURGE 6AM, 8AM)", text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 7, "✅ NEW YORK (9AM ---- PURGE 9AM, 10AM)", text_color=txt_color, text_size=dash_size)
    table.cell(gutale_table, 0, 8, "⏭ NEXT PURGE: " + nextPurgeText, text_color=color.yellow, text_size=dash_size)
    table.cell(gutale_table, 0, 9, "🕒 NEW YORK: " + nyTimeText, text_color=color.white, text_size=dash_size)

//━━━━━━━━━━━━━━━━━━━
// Alert
//━━━━━━━━━━━━━━━━━━━
alertcondition(purgeActive, title="Gutale Purge Active", message="Gutale Sessions and Purges: Active")
````
