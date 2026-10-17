# NY Session 1H Opening Candle Bracket - Dutch Time

- url: https://www.tradingview.com/script/WfNIzjpm-NY-Session-1H-Opening-Candle-Bracket-Dutch-Time/
- type: indicator
- pine_id: PUB;d0a02406d543443f8aa7280a265d2532
- version: 2.0

## Description

[b]GM G's.[/b]
This indicator brackets the 1h candle when the NY sessions start and extends this bracket till the end of NY sessions. IN UTC+1 (winter time) UTC+2 (summer time) 

You would have to change these 2 parts of the code to make it adapt to your time zone:
nySession = input.session("1400-2300:23456", "NY Session Dutch Time")
tz = "Europe/Amsterdam"

for example into: 
nySession = input.session("0800-1700:23456", "NY Session")
tz = "America/New_York"

CryptoJuggler38 :)

## Source Code

````pine
//@version=6
indicator("NY Session 1H Opening Candle Bracket - Dutch Time", overlay=true, max_boxes_count=500)

// Dutch time session: 14:00–23:00, all days for crypto
nySession = input.session("1400-2300:23456", "NY Session Dutch Time")
tz = "Europe/Amsterdam"

// Detect session
inNY = not na(time(timeframe.period, nySession, tz))
nyStart = inNY and (bar_index == 0 or not inNY[1])

// Box
var box nyBox = na

// Create box on first NY session candle
if nyStart
    nyBox := box.new(left=bar_index, right=bar_index + 1, top=high, bottom=low, bgcolor=color.new(color.blue, 92), border_color=color.new(color.blue, 0), border_width=2)

// Extend box until session ends
if inNY and not na(nyBox)
    box.set_right(nyBox, bar_index + 1)
````
