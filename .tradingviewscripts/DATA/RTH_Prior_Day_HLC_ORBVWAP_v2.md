<!-- tradingview-pine-id: PUB;a698613234c6463ab36a4b80f1838fcb -->
<!-- tradingviewscripts-format: 1 -->
# RTH Prior Day H/L/C — ORB+VWAP v2

Source: https://www.tradingview.com/script/2jqOLQ2F-RTH-Prior-Day-H-L-C/

## Description

Gives you the previous day High, Low and Close in Regular Trading Hours (RTH)

---

## Source Code

````pine
//@version=6
indicator("RTH Prior Day H/L/C — ORB+VWAP v2", shorttitle="RTH PD", overlay=true)

// RTH = 09:30–16:00 New York = 07:30–14:00 CDMX.
// Exchange time + timezone keeps it correct through US DST changes,
// since Mexico stays on UTC-6 year-round.
sessInput  = input.session("0930-1600", "RTH session (exchange time)")
tzInput    = input.string("America/New_York", "Session timezone")
showClose  = input.bool(true, "Show prior RTH close (for gap calc)")

inSess  = not na(time(timeframe.period, sessInput, tzInput))
newSess = inSess and not inSess[1]

var float rthH = na
var float rthL = na
var float rthC = na
var float pdh  = na
var float pdl  = na
var float pdc  = na

if newSess
    // roll the just-completed session into the "prior day" values
    pdh  := rthH
    pdl  := rthL
    pdc  := rthC
    rthH := high
    rthL := low
    rthC := close
else if inSess
    rthH := math.max(rthH, high)
    rthL := math.min(rthL, low)
    rthC := close

plot(timeframe.isintraday ? pdh : na, "Prior RTH High",
     color = color.new(color.blue, 0), style = plot.style_linebr, linewidth = 1)
plot(timeframe.isintraday ? pdl : na, "Prior RTH Low",
     color = color.new(color.blue, 0), style = plot.style_linebr, linewidth = 1)
plot((showClose and timeframe.isintraday) ? pdc : na, "Prior RTH Close",
     color = color.new(color.gray, 0), style = plot.style_linebr, linewidth = 1)
````
