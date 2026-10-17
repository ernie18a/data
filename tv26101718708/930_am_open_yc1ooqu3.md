# 9:30 AM Open

- url: https://www.tradingview.com/script/YC1OoQu3-9-30-AM-Open/
- type: indicator
- pine_id: PUB;bb56ff62d0cc4430a8193d7faa32edad
- version: 1.0

## Description

09:30 AM New York Open time.

Can easily identify the open price and use the line for reference in the current session.

## Source Code

````pine
//@version=6
indicator("9:30 AM Open", overlay=true)

// Get the current time in the exchange timezone
current_time = time

// Check if we're at 9:30 AM
is_930 = hour(current_time) == 9 and minute(current_time) == 30

// Store the 9:30 AM open price
var float open_930 = na

// Update open_930 when we hit 9:30 AM
if is_930
    open_930 := open

// Plot the 9:30 AM open price
plot(open_930, color=color.red, linewidth=1, style=plot.style_circles, title="9:30 AM Open")
````
