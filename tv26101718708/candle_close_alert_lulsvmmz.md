# Candle close alert

- url: https://www.tradingview.com/script/lUlSvMMZ-Candle-close-alert/
- type: indicator
- pine_id: PUB;24ff66dfc76f41fb9800a3c5721148b0
- version: 1.0

## Description

This script puts no marks on charts, but works together with TV native alarms and will notify in advance about candle close.

Candles:
15 min
30 min
1 hour
2 hours
4 hours.

Users have option to choose candle time frame and warning time before candle's closing.

Important:
In TV alarm settings put
- Any alert function call
- interval 1 minute (Important!)

Important:
- If you change script settings like, warning time - then TV alarm must but set again and old TV alarm deleted.

Tips:
If you use browser for TV and have TV opened in few tabs, then all tabs will sound alarm.
use "mute tab" option to leave only single TV tab that will be alarming you.
Chrome browser doesn't allow single tab to mute but the whole site - which doesn''t help. However, there're few chrome extensions that do the job correctly, e.g. "Mute Tab".

Enjoy
+

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alfabravo_klp

//@version=6
indicator("Candle close alert", overlay=false)

// === Inputs: Toggles & Custom Warning Times ===
// Using 'inline' puts the checkbox and the minute input on the same line in settings
enable15m = input.bool(true,  "15m Alert", inline="15m")
warn15m   = input.int(2, "Mins before", minval=1, inline="15m")

enable30m = input.bool(true,  "30m Alert", inline="30m")
warn30m   = input.int(3, "Mins before", minval=1, inline="30m")

enable1h  = input.bool(true,  "1h Alert ", inline="1h")
warn1h    = input.int(5, "Mins before", minval=1, inline="1h")

enable2h  = input.bool(true,  "2h Alert ", inline="2h")
warn2h    = input.int(6, "Mins before", minval=1, inline="2h")

enable4h  = input.bool(true,  "4h Alert ", inline="4h")
warn4h    = input.int(7, "Mins before", minval=1, inline="4h")

// === Fetch HTF Times globally to avoid local scope issues ===
[t15, tc15]   = request.security(syminfo.tickerid, "15",  [time, time_close])
[t30, tc30]   = request.security(syminfo.tickerid, "30",  [time, time_close])
[t60, tc60]   = request.security(syminfo.tickerid, "60",  [time, time_close])
[t120, tc120] = request.security(syminfo.tickerid, "120", [time, time_close])
[t240, tc240] = request.security(syminfo.tickerid, "240", [time, time_close])

// === State Tracking (To prevent multiple alerts per candle) ===
var int last15 = -1
var int last30 = -1
var int last1h = -1
var int last2h = -1
var int last4h = -1

// === Logic Checks ===
if barstate.isrealtime
    
    // 15 Minute Check (Only runs if enable15m is true)
    if enable15m and (tc15 - timenow) <= (warn15m * 60 * 1000) and last15 != t15
        last15 := t15
        alert("15m Candle closing in " + str.tostring(warn15m) + " mins", alert.freq_once_per_bar)

    // 30 Minute Check
    if enable30m and (tc30 - timenow) <= (warn30m * 60 * 1000) and last30 != t30
        last30 := t30
        alert("30m Candle closing in " + str.tostring(warn30m) + " mins", alert.freq_once_per_bar)

    // 1 Hour Check
    if enable1h and (tc60 - timenow) <= (warn1h * 60 * 1000) and last1h != t60
        last1h := t60
        alert("1h Candle closing in " + str.tostring(warn1h) + " mins", alert.freq_once_per_bar)

    // 2 Hour Check
    if enable2h and (tc120 - timenow) <= (warn2h * 60 * 1000) and last2h != t120
        last2h := t120
        alert("2h Candle closing in " + str.tostring(warn2h) + " mins", alert.freq_once_per_bar)

    // 4 Hour Check
    if enable4h and (tc240 - timenow) <= (warn4h * 60 * 1000) and last4h != t240
        last4h := t240
        alert("4h Candle closing in " + str.tostring(warn4h) + " mins", alert.freq_once_per_bar)
````
