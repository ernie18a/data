<!-- tradingview-pine-id: PUB;94rkh4pBNidPI0OOznhEEQy87YdOKZRt -->
<!-- tradingviewscripts-format: 1 -->
# CME Equity Futures Price Limits

Source: https://www.tradingview.com/script/O0MU1wau-CME-Equity-Futures-Price-Limits/

## Description

https://www.tradingview.com/x/TWRO2YN8/

Breakers for CME's futures contracts. Should work on CST/EST/UTC charts.

CME says it uses the last 30 seconds of the session to grab a reference price, so I took the open of the last session's candle because it's easier.

Out of session breakers: +/-5%
Limit downs: -7%/-13%/-20%

There are some minor nuances for the later part of the NY session but I don't really care to add that in right now.

Options:
- Input a manual reference price to override the selected price for accuracy. 
- Show only the current/last session's limits. This breaks the in session limit down lines.

Live prices:
https://www.cmegroup.com/trading/price-limits.html#equityIndex

Month codes:
https://www.cmegroup.com/month-codes.html

Reference: 
https://www.cmegroup.com/trading/equity-index/faq-us-based-equity-index-price-limits.html

It's best to check the last updated reference price to ensure it's correct.
https://www.tradingview.com/x/6FJKyB3Z/
https://www.tradingview.com/x/IUOgsfQo/

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeoButane
// 
// https://www.cmegroup.com/trading/price-limits.html#equityIndex
// https://www.cmegroup.com/trading/equity-index/faq-us-based-equity-index-price-limits.html
// 
// https://www.cmegroup.com/month-codes.html

//@version=4
study("CME Equity Futures Price Limits", "CME Limits", overlay = true)

labels = input(true, "Show Labels for Afterhours Breakers")
man = input(0.0, "Manual Input (Zero to Disable)", minval = 0)
only = input(false, "Show Only Today's Limits")
isb = input(true, "Show -7/-13/-20% Limit Down Levels")

test = hour(0)

chicago = 15
utc = 20
newyork = 16

offset = test == 18 ? chicago : test == 19 ? newyork : utc
session = test == 18 ? -1 : test == 19 ? 0 : 4
s_open = 9 + session
s_close = 16 + session

reference = valuewhen(hour == offset and hour[1] != offset, open, 0)
reference := man != 0.0 ? man : reference
limit_down(x) =>
    ld  = man != 0.0 ? man * x : valuewhen(change(reference), reference * x, 0)
    ld := change(dayofweek) ? ld : ld[1]
// limit_down(x) := 


x5 = reference * 1.05
n5 = reference * 0.95
l1 = limit_down(0.93)
l2 = limit_down(0.87)
l3 = limit_down(0.80)
// plot(reference) // reference price check

// Colors/plotting
red = color.red
grn = color.green
gry = color.gray
wht = color.white
blk = color.black
lbr = plot.style_linebr
yo = 24 - hour, oneday = 1000*60*60*yo, clean = not only ? true : (timenow - time) < oneday
nys = ( hour < s_open or ( hour == s_open and minute <= 30 ) ) or ( hour > s_close )
ahc = nys ? red : gry


plot(x5 == x5[1] and clean ? x5 : na, title = "Overnight Upper Limit", color = ahc, style = lbr)
plot(n5 == n5[1] and clean ? n5 : na, title = "Overnight Lower Limit", color = ahc, style = lbr)

show71320 = not nys and clean and isb
plot(show71320 ? l1 : na, title = "-7%", color = grn, style = lbr, linewidth = 1)
plot(show71320 ? l2 : na, title = "-13%", color = grn, style = lbr, linewidth = 2)
plot(show71320 ? l3 : na, title = "-20%", color = grn, style = lbr, linewidth = 3)


plotshape(x5 != x5[1] and labels and not only ? x5 : na, title = "Upper Limit Label",
          style = shape.labeldown, location = location.absolute, color = wht,
          transp = 0, offset = 0, text = " Upper ", textcolor = blk, editable = false)
plotshape(labels and only ? x5 : na, title = "Upper Limit Label",
          style = shape.labeldown, location = location.absolute, color = wht,
          transp = 0, offset = 0, text = " Upper ", textcolor = blk, editable = false, show_last = 1)

plotshape(n5 != n5[1] and labels and not only ? n5 : na, title = "Lower Limit Label",
          style = shape.labelup, location = location.absolute, color = wht,
          transp = 0, offset = 0, text = " Lower ", textcolor = blk, editable = false)
plotshape(labels and only ? n5 : na, title = "Lower Limit Label",
          style = shape.labelup, location = location.absolute, color = wht,
          transp = 0, offset = 0, text = " Lower ", textcolor = blk, editable = false, show_last = 1)
````
