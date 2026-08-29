<!-- tradingview-pine-id: PUB;8003db1b93f84378a11c9cece34c1bfa -->
<!-- tradingviewscripts-format: 1 -->
# MASTER S 28

Source: https://www.tradingview.com/script/HVDw5YHk-MASTER-S-28/

## Description

For sidhu pinescript 6 version
Stop asking me to write more bla bla bla

---

## Source Code

````pine
//@version=6
indicator("MASTER S 28", overlay=true)

// EMAs
plot(ta.ema(close, 10),  "EMA 10",  color=#ffffff)
plot(ta.ema(close, 20),  "EMA 20",  color=#5bc8e0)
plot(ta.ema(close, 200), "EMA 200", color=#f5a623)

// VWAP
plot(ta.vwap(hlc3), "VWAP", color=#b47ed6)

// Prior day / week / month
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1],  lookahead=barmerge.lookahead_on)

plot(pdh, "PDH", color=color.green,    style=plot.style_linebr)
plot(pdl, "PDL", color=#FF5252,        style=plot.style_linebr)
plot(pwh, "PWH", color=color.purple,   style=plot.style_linebr)
plot(pwl, "PWL", color=color.fuchsia,  style=plot.style_linebr)
plot(pmh, "PMH", color=#00897B,        style=plot.style_linebr)
plot(pml, "PML", color=color.maroon,   style=plot.style_linebr)

// Overnight high / low
onSess = not na(time(timeframe.period, "2000-0400", "America/New_York"))
var float onh = na
var float onl = na
if onSess and not onSess[1]
    onh := high
    onl := low
else if onSess
    onh := math.max(onh, high)
    onl := math.min(onl, low)

plot(onh, "ONH", color=color.blue,   style=plot.style_linebr)
plot(onl, "ONL", color=color.orange, style=plot.style_linebr)

// Pre-market high / low
preSess = not na(time(timeframe.period, "1800-0930", "America/New_York"))
var float preh = na
var float prel = na
if preSess and not preSess[1]
    preh := high
    prel := low
else if preSess
    preh := math.max(preh, high)
    prel := math.min(prel, low)

plot(preh, "PreH", color=color.aqua, style=plot.style_linebr)
plot(prel, "PreL", color=#FFEB3B,    style=plot.style_linebr)
````
