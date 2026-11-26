# VWAP Daily

- url: https://www.tradingview.com/script/T5htvhFy-VWAP-Daily/
- type: indicator
- pine_id: PUB;db3a7f323b534672b574334a713444e1
- version: 1.0

## Description

daily$$$$$$$$$$$$
daily$$$$$$$$$$$$
daily$$$$$$$$$$
daily$$$$$$$$$$

## Source Code

````pine
//@version=5
indicator("VWAP Stdev Bands", shorttitle="VWAP Stdev", overlay=true, max_bars_back=500)

// ============================================================
//  INPUTS — multiplicadores exactos del original
// ============================================================

devUp1 = input.float(1.28, "Stdev above (1)", step=0.01)
devDn1 = input.float(1.28, "Stdev below (1)", step=0.01)
devUp2 = input.float(2.01, "Stdev above (2)", step=0.01)
devDn2 = input.float(2.01, "Stdev below (2)", step=0.01)
devUp3 = input.float(2.51, "Stdev above (3)", step=0.01)
devDn3 = input.float(2.51, "Stdev below (3)", step=0.01)
devUp4 = input.float(3.09, "Stdev above (4)", step=0.01)
devDn4 = input.float(3.09, "Stdev below (4)", step=0.01)
devUp5 = input.float(4.01, "Stdev above (5)", step=0.01)
devDn5 = input.float(4.01, "Stdev below (5)", step=0.01)

showDv2      = input.bool(true,  "Show second group of bands")
showDv3      = input.bool(true,  "Show third group of bands")
showDv4      = input.bool(false, "Show fourth group of bands")
showDv5      = input.bool(false, "Show fifth group of bands")
showPrevVWAP = input.bool(false, "Show previous VWAP close")

// ============================================================
//  SESSION DETECTION — mismo patron que original
// ============================================================

sessionOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
newSession  = sessionOpen != sessionOpen[1]

// ============================================================
//  VWAP CALCULATION
// ============================================================

var float vwapsum   = 0.0
var float volumesum = 0.0
var float v2sum     = 0.0

if newSession
    vwapsum   := hl2 * volume
    volumesum := volume
    v2sum     := volume * hl2 * hl2
else
    vwapsum   := nz(vwapsum[1])   + hl2 * volume
    volumesum := nz(volumesum[1]) + volume
    v2sum     := nz(v2sum[1])     + volume * hl2 * hl2

myvwap = vwapsum / volumesum
dev    = math.sqrt(math.max(v2sum / volumesum - myvwap * myvwap, 0.0))

// ============================================================
//  PREV VWAP
// ============================================================

var float prevwap = na
if newSession
    prevwap := nz(myvwap[1])

// ============================================================
//  PLOTS
// ============================================================

A  = plot(myvwap,                                         "VWAP",          color.new(#000000, 0),  2)
U1 = plot(myvwap + devUp1 * dev,                          "Upper 1",       color.new(#9E9E9E, 0),  1)
D1 = plot(myvwap - devDn1 * dev,                          "Lower 1",       color.new(#9E9E9E, 0),  1)
U2 = plot(showDv2 ? myvwap + devUp2 * dev : na,           "Upper 2",       color.new(#FF5252, 0),  1)
D2 = plot(showDv2 ? myvwap - devDn2 * dev : na,           "Lower 2",       color.new(#00C853, 0),  1)
U3 = plot(showDv3 ? myvwap + devUp3 * dev : na,           "Upper 3",       color.new(#FF1744, 0),  1)
D3 = plot(showDv3 ? myvwap - devDn3 * dev : na,           "Lower 3",       color.new(#00E676, 0),  1)
U4 = plot(showDv4 ? myvwap + devUp4 * dev : na,           "Upper 4",       color.new(#D50000, 0),  1)
D4 = plot(showDv4 ? myvwap - devDn4 * dev : na,           "Lower 4",       color.new(#00B248, 0),  1)
U5 = plot(showDv5 ? myvwap + devUp5 * dev : na,           "Upper 5",       color.new(#B71C1C, 0),  1)
D5 = plot(showDv5 ? myvwap - devDn5 * dev : na,           "Lower 5",       color.new(#1B5E20, 0),  1)

plot(showPrevVWAP ? prevwap : na, "Prev VWAP",
     close > prevwap ? color.new(#00C853, 0) : color.new(#FF5252, 0), 1)

// ============================================================
//  FILLS
// ============================================================

fill(A,  U1, color.new(#9E9E9E, 90), "Middle Fill Up")
fill(A,  D1, color.new(#9E9E9E, 90), "Middle Fill Down")
fill(U1, U2, color.new(#FF5252, 90), "OB Fill 1")
fill(D1, D2, color.new(#00C853, 90), "OS Fill 1")
fill(U2, U3, color.new(#FF5252, 90), "OB Fill 2")
fill(D2, D3, color.new(#00C853, 90), "OS Fill 2")
fill(U3, U4, color.new(#FF5252, 90), "OB Fill 3")
fill(D3, D4, color.new(#00C853, 90), "OS Fill 3")
fill(U4, U5, color.new(#FF5252, 90), "OB Fill 4")
fill(D4, D5, color.new(#00C853, 90), "OS Fill 4")
````
