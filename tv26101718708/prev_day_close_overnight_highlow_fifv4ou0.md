# Prev Day Close + Overnight High/Low

- url: https://www.tradingview.com/script/FIfV4ou0-Prev-Day-Close-Overnight-High-Low/
- type: indicator
- pine_id: PUB;d850187e10e94541b0e3b103db053ce1
- version: 1.0

## Description

Prev Day Close + Overnight High/Low

It does what it says in the name

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TBB Trades Tony Barassi
// www.tbbtrades.com

//@version=5
indicator("Prev Day Close + Overnight High/Low", overlay=true)

// ===== Input Settings =====
group1 = "Previous Day Close Settings"
show_prev_close_line = input.bool(true, "Show Dotted Line", group=group1)
show_prev_close_label = input.bool(true, "Show Label", group=group1)

group2 = "Overnight High/Low (from midnight)"
show_on_high_line = input.bool(true, "Show Overnight High Line", group=group2)
show_on_high_label = input.bool(true, "Show Overnight High Label", group=group2)
show_on_low_line = input.bool(true, "Show Overnight Low Line", group=group2)
show_on_low_label = input.bool(true, "Show Overnight Low Label", group=group2)

// ===== Previous Day Close =====
prev_close = request.security(syminfo.tickerid, "D", close[1])

// ===== Overnight High/Low (from midnight of current day) =====
var float overnight_high = na
var float overnight_low = na

// Reset at each new day
if ta.change(time("D"))
    overnight_high := high
    overnight_low := low
else
    overnight_high := math.max(nz(overnight_high), high)
    overnight_low := math.min(nz(overnight_low), low)

// ===== Persistent Drawing Objects =====
var line prevCloseLine = na
var label prevCloseLabel = na
var line overnightHighLine = na
var label overnightHighLabel = na
var line overnightLowLine = na
var label overnightLowLabel = na

// ===== Draw on Last Bar Only =====
if barstate.islast
    // Delete previous objects (using proper multi-line if)
    if not na(prevCloseLine)
        line.delete(prevCloseLine)
    if not na(prevCloseLabel)
        label.delete(prevCloseLabel)
    if not na(overnightHighLine)
        line.delete(overnightHighLine)
    if not na(overnightHighLabel)
        label.delete(overnightHighLabel)
    if not na(overnightLowLine)
        line.delete(overnightLowLine)
    if not na(overnightLowLabel)
        label.delete(overnightLowLabel)
    
    // Previous Day Close
    if show_prev_close_line
        prevCloseLine := line.new(bar_index[1], prev_close, bar_index, prev_close,
                                  extend=extend.right, color=color.blue,
                                  style=line.style_dotted, width=2)
    if show_prev_close_label
        prevCloseLabel := label.new(bar_index, prev_close, text="Prev Day Close\n" + str.tostring(prev_close, "#.##"), color=color.new(color.blue, 80), textcolor=color.white, style=label.style_label_right, size=size.small)
    
    // Overnight High (gold)
    if show_on_high_line and not na(overnight_high)
        overnightHighLine := line.new(bar_index[1], overnight_high, bar_index, overnight_high,
                                      extend=extend.right, color=color.new(color.yellow, 0),
                                      style=line.style_dotted, width=2)
    if show_on_high_label and not na(overnight_high)
        overnightHighLabel := label.new(bar_index, overnight_high, text="Overnight High\n" + str.tostring(overnight_high, "#.##"), color=color.new(color.yellow, 80), textcolor=color.white, style=label.style_label_right, size=size.small)
    
    // Overnight Low (gold)
    if show_on_low_line and not na(overnight_low)
        overnightLowLine := line.new(bar_index[1], overnight_low, bar_index, overnight_low,
                                     extend=extend.right, color=color.new(color.yellow, 0),
                                     style=line.style_dotted, width=2)
    if show_on_low_label and not na(overnight_low)
        overnightLowLabel := label.new(bar_index, overnight_low,
                                       text="Overnight Low\n" + str.tostring(overnight_low, "#.##"),
                                       color=color.new(color.yellow, 80), textcolor=color.white,
                                       style=label.style_label_right, size=size.small)
````
