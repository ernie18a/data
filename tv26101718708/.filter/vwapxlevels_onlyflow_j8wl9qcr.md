# VWAPxLevels - OnlyFlow

- url: https://www.tradingview.com/script/J8wL9QCR-VWAPxLevels-OnlyFlow/
- type: indicator
- pine_id: PUB;8f8ce6b7493448acbb82b2a69a165d51
- version: 1.0

## Description

VWAPxLevels is a comprehensive VWAP-based indicator that combines real-time intraday volume-weighted average price calculations with previous-day reference levels. It's designed for traders who use VWAP and standard deviation bands as key support/resistance zones, with special offset functionality optimized for futures contracts like ES (E-mini S&P 500) and NQ (E-mini Nasdaq).
Key Features
Intraday VWAP with Triple Deviation Band Groups
The indicator plots the current session's VWAP along with three independently configurable groups of standard deviation bands:

Group 1 bands (default 1.0 stdev) for the inner mean-reversion zone
Group 2 bands (default 2.03 stdev) for moderate price extension zones
Group 3 bands (default 2.53 stdev) for extreme price extension zones

Each group can be toggled on or off and adjusted independently, giving you full control over which volatility layers are visible.
Previous Day Reference Levels
Automatically captures and plots the final values from the prior session:

Previous day's closing VWAP
Previous day's Group 1 upper and lower bands
Previous day's Group 2 upper and lower bands
Previous day's Group 3 upper and lower bands

These persistent levels often act as significant magnets and reaction zones in the current session.
Smart Offset Mode for Futures
A unique feature that applies preset offsets to previous-day levels, useful when trading correlated instruments or accounting for overnight gaps:

ES Mode: Applies a 0.5 point offset
NQ Mode: Applies a 2.5 point offset
None: Uses raw VWAP close values

When an offset mode is active, the indicator plots both upper and lower offset variations of the previous day's VWAP and all three deviation band groups, creating bracketed zones around each key level.
How to Use
The intraday VWAP serves as the session's mean price. Group 1 bands highlight the inner volatility envelope where price typically oscillates around fair value, while Group 2 and Group 3 bands identify progressively more extreme reversal or breakout zones. The previous day levels provide context from the prior session, helping identify areas where price has historically reacted. Use the offset mode when you want to create wider reaction zones or when trading futures contracts where slight adjustments to reference levels improve accuracy.
Customization
All three band groups and previous-day plots can be toggled independently through the input panel, letting you display only the levels relevant to your strategy. Deviation multipliers are fully adjustable to match your preferred volatility settings.
Best For
Day traders, scalpers, and futures traders who rely on VWAP-based mean reversion or breakout strategies and want layered volatility zones plus previous session reference levels integrated into a single clean indicator.

## Source Code

````pine
//@version=6
indicator("VWAPxLevels - OnlyFlow", overlay=true, max_bars_back=500)

// ===== Input Parameters =====
// Deviation multipliers for groups 1, 2 & 3
devUp1 = input.float(1.0,  title="Stdev above (Group 1)")
devDn1 = input.float(1.0,  title="Stdev below (Group 1)")
devUp2 = input.float(2.03, title="Stdev above (Group 2)")
devDn2 = input.float(2.03, title="Stdev below (Group 2)")
devUp3 = input.float(2.53, title="Stdev above (Group 3)")
devDn3 = input.float(2.53, title="Stdev below (Group 3)")

// Toggles for intraday bands
showDv1 = input.bool(true, title="Show Intraday Group 1 Bands")
showDv2 = input.bool(true, title="Show Intraday Group 2 Bands")
showDv3 = input.bool(true, title="Show Intraday Group 3 Bands")

// Toggles for previous-day offset plots
showVWAPPrev = input.bool(true, title="Show Prev Day VWAP Close & Offsets")
showDv1Prev  = input.bool(true, title="Show Prev Day Group 1 Offset Bands")
showDv2Prev  = input.bool(true, title="Show Prev Day Group 2 Offset Bands")
showDv3Prev  = input.bool(true, title="Show Prev Day Group 3 Offset Bands")

// VWAP offset mode: "None" = straight close; "ES"/"NQ" apply 0.5/2.5 offsets
vwapOffsetMode = input.string("None", title="VWAP Close Offset Mode", options=["None","ES","NQ"])

// Pre-set offsets (still available if you want custom later)
es_offset = 0.5
nq_offset = 2.5

// ===== Daily-open detection via security() =====
sessionOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
newSession  = sessionOpen != sessionOpen[1]

// ===== Intraday VWAP & Deviations =====
var float vwapsum   = 0.0
var float volumesum = 0.0
var float v2sum     = 0.0

if newSession
    vwapsum   := hl2 * volume
    volumesum := volume
    v2sum     := volume * hl2 * hl2
else
    vwapsum   := nz(vwapsum[1]) + hl2 * volume
    volumesum := nz(volumesum[1]) + volume
    v2sum     := nz(v2sum[1]) + volume * hl2 * hl2

myvwap = vwapsum / volumesum
dev    = math.sqrt(math.max(v2sum / volumesum - myvwap * myvwap, 0))

plot( myvwap,                        title="Intraday VWAP",     color=color.black )
plot( showDv1 ? myvwap + devUp1*dev + 1 : na, title="Intraday Upper G1", color=color.orange )
plot( showDv1 ? myvwap - devDn1*dev - 1 : na, title="Intraday Lower G1", color=color.aqua )
plot( showDv2 ? myvwap + devUp2*dev + 1 : na, title="Intraday Upper G2", color=color.red )
plot( showDv2 ? myvwap - devDn2*dev - 1 : na, title="Intraday Lower G2", color=color.green )
plot( showDv3 ? myvwap + devUp3*dev + 1 : na, title="Intraday Upper G3", color=color.red )
plot( showDv3 ? myvwap - devDn3*dev - 1 : na, title="Intraday Lower G3", color=color.green )

// ===== Capture Prev-Day Final Values =====
var float prev_vwap = na
var float prev_U1   = na
var float prev_D1   = na
var float prev_U2   = na
var float prev_D2   = na
var float prev_U3   = na
var float prev_D3   = na

if newSession and not na(myvwap[1]) and not na(dev[1])
    prev_vwap := myvwap[1]
    prev_U1   := myvwap[1] + devUp1*dev[1] + 1
    prev_D1   := myvwap[1] - devDn1*dev[1] - 1
    prev_U2   := myvwap[1] + devUp2*dev[1] + 1
    prev_D2   := myvwap[1] - devDn2*dev[1] - 1
    prev_U3   := myvwap[1] + devUp3*dev[1] + 1
    prev_D3   := myvwap[1] - devDn3*dev[1] - 1

// ===== Determine the chosen offset =====
offset_val = vwapOffsetMode == "ES"  ? es_offset  :
             vwapOffsetMode == "NQ" ? nq_offset : 0.0

// ===== Compute VWAP-close offset lines =====
prev_vwap_upper = not na(prev_vwap) ? prev_vwap + offset_val : na
prev_vwap_lower = not na(prev_vwap) ? prev_vwap - offset_val : na

// ===== Compute band offset lines for Group 1 =====
prev_U1_up   = not na(prev_U1) ? prev_U1 + offset_val : na
prev_U1_down = not na(prev_U1) ? prev_U1 - offset_val : na
prev_D1_up   = not na(prev_D1) ? prev_D1 + offset_val : na
prev_D1_down = not na(prev_D1) ? prev_D1 - offset_val : na

// ===== Compute band offset lines for Group 2 =====
prev_U2_up   = not na(prev_U2) ? prev_U2 + offset_val : na
prev_U2_down = not na(prev_U2) ? prev_U2 - offset_val : na
prev_D2_up   = not na(prev_D2) ? prev_D2 + offset_val : na
prev_D2_down = not na(prev_D2) ? prev_D2 - offset_val : na

// ===== Compute band offset lines for Group 3 =====
prev_U3_up   = not na(prev_U3) ? prev_U3 + offset_val : na
prev_U3_down = not na(prev_U3) ? prev_U3 - offset_val : na
prev_D3_up   = not na(prev_D3) ? prev_D3 + offset_val : na
prev_D3_down = not na(prev_D3) ? prev_D3 - offset_val : na

// ===== Plot Previous Day VWAP + Offsets =====
plot(showVWAPPrev ? prev_vwap       : na, title="Prev Day VWAP Close",       color=color.black, linewidth=2)
plot(showVWAPPrev ? prev_vwap_upper : na, title="VWAP Offset Upper",         color=color.blue,  linewidth=1)
plot(showVWAPPrev ? prev_vwap_lower : na, title="VWAP Offset Lower",         color=color.blue,  linewidth=1)

// ===== Plot Previous Day Group 1 Offsets =====
plot(showDv1Prev ? prev_U1_up   : na, title="G1 Upper + Offset", color=color.orange, linewidth=1)
plot(showDv1Prev ? prev_U1_down : na, title="G1 Upper - Offset", color=color.orange, linewidth=1)
plot(showDv1Prev ? prev_D1_up   : na, title="G1 Lower + Offset", color=color.aqua,   linewidth=1)
plot(showDv1Prev ? prev_D1_down : na, title="G1 Lower - Offset", color=color.aqua,   linewidth=1)

// ===== Plot Previous Day Group 2 Offsets =====
plot(showDv2Prev ? prev_U2_up   : na, title="G2 Upper + Offset", color=color.red,   linewidth=1)
plot(showDv2Prev ? prev_U2_down : na, title="G2 Upper - Offset", color=color.red,   linewidth=1)
plot(showDv2Prev ? prev_D2_up   : na, title="G2 Lower + Offset", color=color.green, linewidth=1)
plot(showDv2Prev ? prev_D2_down : na, title="G2 Lower - Offset", color=color.green, linewidth=1)

// ===== Plot Previous Day Group 3 Offsets =====
plot(showDv3Prev ? prev_U3_up   : na, title="G3 Upper + Offset", color=color.red,   linewidth=1)
plot(showDv3Prev ? prev_U3_down : na, title="G3 Upper - Offset", color=color.red,   linewidth=1)
plot(showDv3Prev ? prev_D3_up   : na, title="G3 Lower + Offset", color=color.green, linewidth=1)
plot(showDv3Prev ? prev_D3_down : na, title="G3 Lower - Offset", color=color.green, linewidth=1)

//
````
