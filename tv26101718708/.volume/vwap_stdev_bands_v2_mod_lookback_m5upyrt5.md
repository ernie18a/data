# VWAP Stdev Bands v2 Mod - Lookback

- url: https://www.tradingview.com/script/m5upYrT5-VWAP-Stdev-Bands-v2-Mod-Lookback/
- type: indicator
- pine_id: PUB;cdef8c93e28a4e79a8e6832bff98834d
- version: 1.0

## Description

VWAP Stdev Bands v2 Mod with added adjustable Lookback setting.

## Source Code

````pine
//@version=6
indicator("VWAP Stdev Bands v2 Mod - Lookback", overlay = true)

lookbackDays = input.int(12, "Lookback Days", minval = 1)

devUp1 = input.float(1.28, title = "Stdev above (1)")
devDn1 = input.float(1.28, title = "Stdev below (1)")

devUp2 = input.float(2.01, title = "Stdev above (2)")
devDn2 = input.float(2.01, title = "Stdev below (2)")

devUp3 = input.float(2.51, title = "Stdev above (3)")
devDn3 = input.float(2.51, title = "Stdev below (3)")

devUp4 = input.float(3.09, title = "Stdev above (4)")
devDn4 = input.float(3.09, title = "Stdev below (4)")

devUp5 = input.float(4.01, title = "Stdev above (5)")
devDn5 = input.float(4.01, title = "Stdev below (5)")

showDv2 = input.bool(true, title = "Show second group of bands?")
showDv3 = input.bool(true, title = "Show third group of bands?")
showDv4 = input.bool(false, title = "Show fourth group of bands?")
showDv5 = input.bool(false, title = "Show fifth group of bands?")

showPrevVWAP = input.bool(false, title = "Show previous VWAP close")

// Counts actual DAILY bars/sessions, not calendar days.
// Example: 12 means the last 12 daily bars available for this symbol.
inLookback = request.security(
     syminfo.tickerid,
     "D",
     bar_index >= last_bar_index - lookbackDays + 1,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// New daily session detection
newSession = timeframe.change("D")

var float vwapsum = na
var float volumesum = na
var float v2sum = na
var float prevwap = na

vwapsum   := newSession ? hl2 * volume : nz(vwapsum[1]) + hl2 * volume
volumesum := newSession ? volume       : nz(volumesum[1]) + volume
v2sum     := newSession ? volume * hl2 * hl2 : nz(v2sum[1]) + volume * hl2 * hl2

myvwap = vwapsum / volumesum
dev = math.sqrt(math.max(v2sum / volumesum - myvwap * myvwap, 0))

prevwap := newSession ? myvwap[1] : nz(prevwap[1])

vwapPlot = inLookback ? myvwap : na

A = plot(vwapPlot, style = plot.style_circles, title = "VWAP", color = color.black)

U1 = plot(inLookback ? myvwap + devUp1 * dev : na, style = plot.style_circles, title = "VWAP Upper", color = color.gray)
D1 = plot(inLookback ? myvwap - devDn1 * dev : na, style = plot.style_circles, title = "VWAP Lower", color = color.gray)

U2 = plot(inLookback and showDv2 ? myvwap + devUp2 * dev : na, color = color.red, title = "VWAP Upper (2)")
D2 = plot(inLookback and showDv2 ? myvwap - devDn2 * dev : na, color = color.green, title = "VWAP Lower (2)")

U3 = plot(inLookback and showDv3 ? myvwap + devUp3 * dev : na, title = "VWAP Upper (3)", color = color.red)
D3 = plot(inLookback and showDv3 ? myvwap - devDn3 * dev : na, title = "VWAP Lower (3)", color = color.green)

U4 = plot(inLookback and showDv4 ? myvwap + devUp4 * dev : na, title = "VWAP Upper (4)", color = color.red)
D4 = plot(inLookback and showDv4 ? myvwap - devDn4 * dev : na, title = "VWAP Lower (4)", color = color.green)

U5 = plot(inLookback and showDv5 ? myvwap + devUp5 * dev : na, title = "VWAP Upper (5)", color = color.red)
D5 = plot(inLookback and showDv5 ? myvwap - devDn5 * dev : na, title = "VWAP Lower (5)", color = color.green)

plot(
     inLookback and showPrevVWAP ? prevwap : na,
     style = plot.style_circles,
     color = close > prevwap ? color.green : color.red,
     title = "Previous VWAP Close"
)

fill(U1, U2, color = color.new(color.red, 90), title = "Over Bought Fill 1")
fill(D1, D2, color = color.new(color.green, 90), title = "Over Sold Fill 1")

fill(U2, U3, color = color.new(color.red, 90), title = "Over Bought Fill 2")
fill(D2, D3, color = color.new(color.green, 90), title = "Over Sold Fill 2")

fill(U3, U4, color = color.new(color.red, 90), title = "Over Bought Fill 3")
fill(D3, D4, color = color.new(color.green, 90), title = "Over Sold Fill 3")

fill(U4, U5, color = color.new(color.red, 90), title = "Over Bought Fill 4")
fill(D4, D5, color = color.new(color.green, 90), title = "Over Sold Fill 4")

fill(A, U1, color = color.new(color.gray, 90), title = "Middle Fill Up")
fill(A, D1, color = color.new(color.gray, 90), title = "Middle Fill Down")
````
