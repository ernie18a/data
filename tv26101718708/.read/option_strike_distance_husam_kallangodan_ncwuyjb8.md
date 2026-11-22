# Option Strike Distance - Husam Kallangodan

- url: https://www.tradingview.com/script/NCWUYJb8-Option-Strike-Distance-Husam-Kallangodan/
- type: indicator
- pine_id: PUB;f9c4169e22e848fd8edc0dd91249c4aa
- version: 1.0

## Description

A simple BTC options dashboard designed to monitor the distance between spot price and your short call/put strikes.

This indicator helps track strike buffer, ATR distance, DTE, and risk status in one view, making it easier to monitor a short strangle or similar options-selling setup.

What it shows
Call Buffer (%) — Percentage distance between BTC spot and the short call strike.
Put Buffer (%) — Percentage distance between BTC spot and the short put strike.
Call / Put ATRs — Distance to each strike expressed in ATRs.
ATR (14) — Current 14-period ATR.
ATR % — ATR expressed as a percentage of BTC spot.
DTE — Time remaining until the configured Friday 1:30 PM IST expiry.
4H Candles — Approximate number of 4-hour candles remaining until expiry.
Status — Overall status based on the closest short strike.
Buffer Status

The status is determined by the nearest short strike:

🟢 SAFE — Buffer above the Safe Threshold
🔵 WATCH — Buffer between Safe and Watch thresholds
⚪ ALERT — Buffer between Watch and Defend thresholds
🔴 DEFEND — Buffer below the Defend Threshold

The default thresholds are:

SAFE: >12%
WATCH: >8%
ALERT: >5%
DEFEND: ≤5%

All thresholds can be adjusted from the indicator settings.

Alerts

The indicator provides separate alerts when either the call-side or put-side buffer crosses below the configured Alert Trigger (%).

For example, with an Alert Trigger of 7%, an alert is generated when the respective strike's buffer crosses below 7%.

Inputs

You can configure:

Short Call Strike
Short Put Strike
Safe Threshold
Watch Threshold
Defend Threshold
Alert Trigger


This indicator is intended as a monitoring and risk-management aid, not as a prediction tool or a standalone trading strategy.

The buffer percentages are calculated relative to the current BTC spot price, while ATR values provide additional context around current market volatility.

Always consider volatility, liquidity, time to expiry, option Greeks, market structure, and your own risk management before making trading decisions.

## Source Code

````pine
//@version=6

indicator("Coinswitch Option Strike Distance", overlay=true)



shortCall = input.float(78000, "Short Call Strike")

shortPut  = input.float(64000, "Short Put Strike")



safeThreshold   = input.float(12.0, "Safe Threshold (%)", step = 0.5)

watchThreshold  = input.float(8.0, "Watch Threshold (%)", step = 0.5)

defendThreshold = input.float(5.0, "Defend Threshold (%)", step = 0.5)



alertTrigger    = input.float(7.0, "Alert Trigger (%)", step = 0.5)



spot = close



// Buffer %

callDistPct = ((shortCall - spot) / spot) * 100

putDistPct  = ((spot - shortPut) / spot) * 100



nearestBuffer = math.min(callDistPct, putDistPct)



// ------------------------

// Buffer Colors

// ------------------------



callBufferColor = color.new(color.red, 50)



if callDistPct > safeThreshold

    callBufferColor := color.new(color.green, 65)

else if callDistPct > watchThreshold

    callBufferColor := color.new(color.blue, 70)

else if callDistPct > defendThreshold

    callBufferColor := color.new(color.gray, 50)



putBufferColor = color.new(color.red, 50)



if putDistPct > safeThreshold

    putBufferColor := color.new(color.green, 65)

else if putDistPct > watchThreshold

    putBufferColor := color.new(color.blue, 70)

else if putDistPct > defendThreshold

    putBufferColor := color.new(color.gray, 50)



// ------------------------

// ATR

// ------------------------



atr = ta.atr(14)

atrPct = (atr / spot) * 100



callATRs = (shortCall - spot) / atr

putATRs  = (spot - shortPut) / atr



// ------------------------

// Status

// ------------------------



status = "DEFEND"



if nearestBuffer > safeThreshold

    status := "SAFE"

else if nearestBuffer > watchThreshold

    status := "WATCH"

else if nearestBuffer > defendThreshold

    status := "ALERT"



statusColor = color.new(color.red, 30)



if nearestBuffer > safeThreshold

    statusColor := color.new(color.green, 50)

else if nearestBuffer > watchThreshold

    statusColor := color.new(color.blue, 60)

else if nearestBuffer > defendThreshold

    statusColor := color.new(color.gray, 40)



// ------------------------

// DTE to Friday 1:30 PM IST

// ------------------------



istHour   = hour(time, "Asia/Kolkata")

istMinute = minute(time, "Asia/Kolkata")

istDay    = dayofweek(time, "Asia/Kolkata")



expiryHour = 13

expiryMin  = 30



daysUntilFriday =

     istDay == dayofweek.friday and

     (istHour < expiryHour or (istHour == expiryHour and istMinute < expiryMin))

     ? 0

     : (dayofweek.friday - istDay + 7) % 7



expiryTimestamp =

     timestamp(

         "Asia/Kolkata",

         year(time, "Asia/Kolkata"),

         month(time, "Asia/Kolkata"),

         dayofmonth(time, "Asia/Kolkata") + daysUntilFriday,

         expiryHour,

         expiryMin

     )



if time > expiryTimestamp

    expiryTimestamp += 7 * 24 * 60 * 60 * 1000



remainingMs = expiryTimestamp - timenow



dteDays = math.floor(remainingMs / 86400000)



dteHours = math.floor((remainingMs % 86400000) / 3600000)



dteDisplay =

     str.tostring(dteDays) +

     "d " +

     str.tostring(dteHours) +

     "h"



// ------------------------

// 4H Candles Remaining

// ------------------------



fourHMs = 4 * 60 * 60 * 1000

fourHCandlesRemaining = math.floor(remainingMs / fourHMs)

fourHCandleDisplay = str.tostring(fourHCandlesRemaining)



// ------------------------

// Plots

// ------------------------



plot(shortCall, "Short Call", color=color.red, linewidth=2)

plot(shortPut, "Short Put", color=color.green, linewidth=2)



// ------------------------

// Alerts

// ------------------------



putAlert  = ta.crossunder(putDistPct, alertTrigger)

callAlert = ta.crossunder(callDistPct, alertTrigger)



alertcondition(

     callAlert,

     title = "CALL ALERT",

     message = "Call strike entered alert zone."

)



alertcondition(

     putAlert,

     title = "PUT ALERT",

     message = "Put strike entered alert zone."

)



// ------------------------

// Dashboard

// ------------------------



var table t = table.new(

     position.middle_right,

     2,

     10,

     bgcolor=color.black,

     frame_color=color.gray,

     frame_width=1

)



if barstate.islast



    table.cell(t, 0, 0, "BTC Spot", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 0, str.tostring(spot, "#"), text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 1, "Call Buffer", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 1, str.tostring(callDistPct, "#.##") + "%", text_color=color.white, bgcolor=callBufferColor)



    table.cell(t, 0, 2, "Call ATRs", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 2, str.tostring(callATRs, "#.##"), text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 3, "Put Buffer", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 3, str.tostring(putDistPct, "#.##") + "%", text_color=color.white, bgcolor=putBufferColor)



    table.cell(t, 0, 4, "Put ATRs", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 4, str.tostring(putATRs, "#.##"), text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 5, "ATR(14)", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 5, str.tostring(atr, "#"), text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 6, "ATR %", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 6, str.tostring(atrPct, "#.##") + "%", text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 7, "DTE", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 7, dteDisplay, text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 8, "4H Candles", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 8, fourHCandleDisplay, text_color=color.white, bgcolor=color.black)



    table.cell(t, 0, 9, "Status", text_color=color.white, bgcolor=color.black)

    table.cell(t, 1, 9, status, text_color=color.white, bgcolor=statusColor)
````
