# 15-Min ORB % Retrace

- url: https://www.tradingview.com/script/rUikFSdG-15-Min-ORB-Retrace/
- type: indicator
- pine_id: PUB;6cb76e11a816450f9f7bdf91fd5b8783
- version: 1.0

## Description

15 min orb retracement calculation. Indicator calculates retracements back in 15 min range after a brake based on the size of the first 15 min candle

## Source Code

````pine
//@version=6
indicator('15-Min ORB % Retrace', overlay = true)

// --- Inputs ---
orb_session = input.session('0930-0945', 'Opening Range (EST)')
timezone = 'America/New_York'

// --- State Variables ---
var float orb_hi = na
var float orb_lo = na
var float orb_size = na

// --- Detect Session ---
is_new_day = ta.change(time('D', timezone))
in_session = not na(time(timeframe.period, orb_session, timezone))

// Reset at Start of Day
if bool(is_new_day)
    orb_hi := na
    orb_lo := na
    orb_size := na
    orb_size

// Capture the High/Low during the 9:30-9:45 window
if in_session
    orb_hi := na(orb_hi) ? high : math.max(high, orb_hi)
    orb_lo := na(orb_lo) ? low : math.min(low, orb_lo)
    orb_size := orb_hi - orb_lo
    orb_size

// --- Fibonacci / Retracement Levels ---
f25 = orb_hi - orb_size * 0.25
f50 = orb_hi - orb_size * 0.50
f75 = orb_hi - orb_size * 0.75

// --- Visuals ---
// Lines only plot after the 15-min window closes
show = not na(orb_hi) and not in_session

plot(show ? orb_hi : na, 'ORB High', color = color.green, style = plot.style_linebr, linewidth = 2)
plot(show ? orb_lo : na, 'ORB Low', color = color.red, style = plot.style_linebr, linewidth = 2)

plot(show ? f25 : na, '25%', color = color.new(color.gray, 50), style = plot.style_linebr)
plot(show ? f50 : na, '50%', color = color.new(color.white, 20), style = plot.style_linebr, linewidth = 2)
plot(show ? f75 : na, '75%', color = color.new(color.gray, 50), style = plot.style_linebr)

// Highlight the 9:30-9:45 window
bgcolor(in_session ? color.new(color.blue, 90) : na)
````
