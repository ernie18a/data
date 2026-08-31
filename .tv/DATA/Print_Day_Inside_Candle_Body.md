<!-- tradingview-pine-id: PUB;3f24ec6dd2f3448dbcdb8467317cf102 -->
<!-- tradingviewscripts-format: 1 -->
# Print Day Inside Candle Body

Source: https://www.tradingview.com/script/7wfZXi4M-Print-Day-Inside-Candle-Body/

## Description

This prints the date inside the candle body. This is very helpful to get the date of the cand.

---

## Source Code

````pine
//@version=6
indicator("Print Day Inside Candle Body", overlay=true)

// Get the two-digit day format (DD)
string dayFormat = str.format("{0,date,dd}", time)

// Split the two digits and stack them vertically with a newline character
string verticalText = str.substring(dayFormat, 0, 1) + "\n" + str.substring(dayFormat, 1, 2)

// Calculate the vertical center of the candle body
float bodyCenter = (open + close) / 2

// Plot the day number vertically inside the candle body
if barstate.islast or barstate.ishistory
    label.new(x=bar_index, y=bodyCenter, text=verticalText, 
              style=label.style_none, 
              textcolor=color.white, 
              size=size.small)
````
