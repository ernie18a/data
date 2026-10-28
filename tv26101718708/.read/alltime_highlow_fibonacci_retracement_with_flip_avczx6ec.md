# All-Time High/Low Fibonacci Retracement (with Flip)

- url: https://www.tradingview.com/script/AvcZx6eC-All-Time-High-Low-Fibonacci-Retracement-with-Flip/
- type: indicator
- pine_id: PUB;ef020182770c44b2a22a53dbd51d53b1
- version: 5.0

## Description

Tired of manually dragging the Fibonacci tool across macro charts every time an asset makes a new high or low? This indicator automates the entire process. It scans the absolute historical data of any asset to identify its true All-Time High (ATH) and All-Time Low (ATL), then dynamically projects standard Fibonacci retracement levels between them.

Whether you are analyzing a stock's decades-long macro cycle or looking for major historical support and resistance levels, this script keeps your charts perfectly anchored without the manual clutter.

Key Features
100% Automated Tracking: Uses historical state variables (var) to lock onto the ultimate lowest and highest prices ever printed on your current chart.

Real-Time Dynamic Updates: If the asset breaks out into price discovery (new ATH) or capitulates to a new bottom (new ATL), the script recalculates and shifts all Fibonacci lines instantly.

One-Click Flip Toggle: Built-in calculation flip. Measure retracements from the top down (bearish retracement) or flip it from the bottom up (bullish expansion) right from the settings menu.

Clean Visuals: Hard-coded with classic Fibonacci ratios (23.6%, 38.2%, 50.0%, 61.8%, 78.6%) using a subtle, non-intrusive color gradient that won't crowd your daily price action.

How to Use the Settings
Flip Retracement (Checkbox): * Unchecked (Default): Places 0% at the All-Time High and 100% at the All-Time Low (Ideal for finding support levels during a pullback from macro highs).

Checked: Places 0% at the All-Time Low and 100% at the All-Time High (Ideal for tracking major resistance levels and targets on the way back up).

💡 Pro-Tip: Because TradingView loads a limited number of historical bars on lower timeframes (like 5-minute or 15-minute charts), always load this indicator on a Daily (D), Weekly (W), or Monthly (M) chart first. This ensures the script catches the true historical inception highs and lows of the asset!

## Source Code

````pine
//@version=6
indicator('All-Time High/Low Fibonacci Retracement (with Flip)', overlay = true)

// User Input Toggle (Acts as your button)
flip = input.bool(false, title = 'Flip Retracement (0% at Bottom / Low)')

// --- Range Source: All-Time vs Local Window vs Swing Pivots ---
range_mode = input.string('All-Time', title = 'Range Source', options = ['All-Time', 'Local Window', 'Swing Pivots'])
lookback   = input.int(100, title = 'Local Window Lookback (bars)', minval = 2)
piv_left   = input.int(15, title = 'Pivot Left Bars', minval = 1)
piv_right  = input.int(15, title = 'Pivot Right Bars', minval = 1)

// Display options
offset       = input.int(5, title = 'Label Offset (bars)', minval = 0)
show_pocket  = input.bool(true, title = 'Shade Golden Pocket (61.8%–78.6%)')

// --- Moving Averages ---
show_ma = input.bool(true, title = 'Show Moving Averages', group = 'Moving Averages')

ma1_len   = input.int(150, title = 'MA 1 Length', minval = 1, group = 'Moving Averages', inline = 'ma1')
ma1_tf    = input.timeframe('D', title = 'TF', options = ['D', 'W', 'M'], group = 'Moving Averages', inline = 'ma1')
ma1_color = input.color(color.aqua, title = '', group = 'Moving Averages', inline = 'ma1')

ma2_len   = input.int(200, title = 'MA 2 Length', minval = 1, group = 'Moving Averages', inline = 'ma2')
ma2_tf    = input.timeframe('D', title = 'TF', options = ['D', 'W', 'M'], group = 'Moving Averages', inline = 'ma2')
ma2_color = input.color(color.fuchsia, title = '', group = 'Moving Averages', inline = 'ma2')

// Use 'var' to keep track of values across the entire history of the chart
var float ath = na
var float atl = na

// Update All-Time High and All-Time Low dynamically
if na(ath) or high > ath
    ath := high
    ath

if na(atl) or low < atl
    atl := low
    atl

// Local (fixed trailing window) high and low
float local_hi = ta.highest(high, lookback)
float local_lo = ta.lowest(low, lookback)

// Swing pivots — hold the most recent CONFIRMED pivot high/low
float ph = ta.pivothigh(piv_left, piv_right)
float pl = ta.pivotlow(piv_left, piv_right)
var float swing_hi = na
var float swing_lo = na
if not na(ph)
    swing_hi := ph
    swing_hi
if not na(pl)
    swing_lo := pl
    swing_lo

// Select the active range top/bottom based on the chosen mode
// (Swing mode falls back to all-time until the first pivots confirm)
float hi = range_mode == 'Local Window' ? local_hi : range_mode == 'Swing Pivots' ? (na(swing_hi) ? ath : swing_hi) : ath
float lo = range_mode == 'Local Window' ? local_lo : range_mode == 'Swing Pivots' ? (na(swing_lo) ? atl : swing_lo) : atl

// Calculate the total price difference
float diff = hi - lo

// Conditional calculation based on the 'flip' checkbox
float fib_0 = flip ? lo : hi
float fib_236 = flip ? lo + diff * 0.236 : hi - diff * 0.236
float fib_382 = flip ? lo + diff * 0.382 : hi - diff * 0.382
float fib_50 = flip ? lo + diff * 0.500 : hi - diff * 0.500
float fib_618 = flip ? lo + diff * 0.618 : hi - diff * 0.618
float fib_786 = flip ? lo + diff * 0.786 : hi - diff * 0.786
float fib_100 = flip ? hi : lo

// Plot Levels on the Chart (keep IDs so we can fill between them)
plot(fib_0, title = '0.0%', color = color.new(color.red, 0), linewidth = 2)
plot(fib_236, title = '23.6%', color = color.new(color.orange, 20), linewidth = 1)
plot(fib_382, title = '38.2%', color = color.new(color.yellow, 20), linewidth = 1)
plot(fib_50, title = '50.0%', color = color.new(color.green, 20), linewidth = 1)
p_618 = plot(fib_618, title = '61.8%', color = color.new(color.blue, 20), linewidth = 1)
p_786 = plot(fib_786, title = '78.6%', color = color.new(color.purple, 20), linewidth = 1)
plot(fib_100, title = '100.0%', color = color.new(color.red, 0), linewidth = 2)

// --- Golden Pocket Fill (61.8% – 78.6%) ---
fill(p_618, p_786, color = show_pocket ? color.new(color.blue, 85) : na, title = 'Golden Pocket')

// --- Moving Averages ---
// Each MA is pulled from its own selected timeframe (D/W/M) so it stays true to
// that timeframe even when viewed on a lower chart timeframe.
float ma1 = request.security(syminfo.tickerid, ma1_tf, ta.sma(close, ma1_len))
float ma2 = request.security(syminfo.tickerid, ma2_tf, ta.sma(close, ma2_len))
plot(show_ma ? ma1 : na, title = 'MA 1', color = ma1_color, linewidth = 2)
plot(show_ma ? ma2 : na, title = 'MA 2', color = ma2_color, linewidth = 2)

// --- Percentage + Price Labels ---
// Keep a persistent reference to each label so we can move it instead of stacking new ones
var label lbl_0   = na
var label lbl_236 = na
var label lbl_382 = na
var label lbl_50  = na
var label lbl_618 = na
var label lbl_786 = na
var label lbl_100 = na

// Helper to create-or-update a label at a given price level
f_setLabel(label lbl, float price, string pct, color col) =>
    string txt = pct + '  —  ' + str.tostring(price, format.mintick)
    label result = na
    if na(lbl)
        result := label.new(x = bar_index + offset, y = price, text = txt, color = color.new(col, 100), textcolor = col, style = label.style_label_left, size = size.small)
    else
        label.set_xy(lbl, bar_index + offset, price)
        label.set_text(lbl, txt)
        result := lbl
    result

if barstate.islast
    lbl_0   := f_setLabel(lbl_0,   fib_0,   '0.0%',   color.red)
    lbl_236 := f_setLabel(lbl_236, fib_236, '23.6%',  color.orange)
    lbl_382 := f_setLabel(lbl_382, fib_382, '38.2%',  color.yellow)
    lbl_50  := f_setLabel(lbl_50,  fib_50,  '50.0%',  color.green)
    lbl_618 := f_setLabel(lbl_618, fib_618, '61.8%',  color.blue)
    lbl_786 := f_setLabel(lbl_786, fib_786, '78.6%',  color.purple)
    lbl_100 := f_setLabel(lbl_100, fib_100, '100.0%', color.red)

// --- Alerts on Level Crosses ---
alertcondition(ta.cross(close, fib_236), title = 'Cross 23.6%', message = 'Price crossed 23.6% Fib level')
alertcondition(ta.cross(close, fib_382), title = 'Cross 38.2%', message = 'Price crossed 38.2% Fib level')
alertcondition(ta.cross(close, fib_50),  title = 'Cross 50.0%', message = 'Price crossed 50.0% Fib level')
alertcondition(ta.cross(close, fib_618), title = 'Cross 61.8%', message = 'Price crossed 61.8% Fib level (golden pocket edge)')
alertcondition(ta.cross(close, fib_786), title = 'Cross 78.6%', message = 'Price crossed 78.6% Fib level (golden pocket edge)')
````
