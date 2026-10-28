# CPR Indicator

- url: https://www.tradingview.com/script/QXaoR03n-CPR-Indicator/
- type: indicator
- pine_id: PUB;83f0b9fda1fe4a3aada1962b9e3b2ae9
- version: 1.0

## Description

CPR Pivots
Indicator shows the supports from S1 to S6 and the resistances from R1 to R5. 
The Central Pivot Range is also showed. 
NWM

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ankitnarshana27

//@version=6
indicator("CPR Custom", overlay=true)

// === Previous Day Values (LOCKED) ===
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// === CPR Calculation ===
pivot = (prevHigh + prevLow + prevClose) / 3
bc    = (prevHigh + prevLow) / 2
tc    = 2 * pivot - bc

bc_final = math.min(bc, tc)
tc_final = math.max(bc, tc)

// === Support & Resistance ===
r1 = 2 * pivot - prevLow
s1 = 2 * pivot - prevHigh

r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)

r3 = prevHigh + 2 * (pivot - prevLow)
s3 = prevLow - 2 * (prevHigh - pivot)

r4 = r3 + (r2 - r1)
s4 = s3 - (s1 - s2)

r5 = r4 + (r2 - r1)
s5 = s4 - (s1 - s2)

s6 = s5 - (s1 - s2)

// === Plot CPR ===
p_bc = plot(bc_final, title="BC", color=color.aqua, style=plot.style_stepline, linewidth = 2)
p_tc = plot(tc_final, title="TC", color=color.aqua, style=plot.style_stepline, linewidth = 2)
plot(pivot, title="Pivot", color=color.yellow, linewidth=2, style=plot.style_stepline)

fill(p_bc, p_tc, color=color.new(color.blue, 85))

// === Plot R/S Levels ===
plot(r1, title="R1", color=color.teal, style=plot.style_circles)
plot(r2, title="R2", color=color.teal, style=plot.style_circles)
plot(r3, title="R3", color=color.teal, style=plot.style_circles)
plot(r4, title="R4", color=color.teal, style=plot.style_circles)
plot(r5, title="R5", color=color.teal, style=plot.style_circles)


plot(s1, title="S1", color=color.maroon, style=plot.style_cross, linewidth = 2)
plot(s2, title="S2", color=color.maroon, style=plot.style_cross, linewidth = 2)
plot(s3, title="S3", color=color.maroon, style=plot.style_cross, linewidth = 2)
plot(s4, title="S4", color=color.maroon, style=plot.style_cross, linewidth = 2)
plot(s5, title="S5", color=color.maroon, style=plot.style_cross, linewidth = 2)
plot(s6, title="S6", color=color.maroon, style=plot.style_cross, linewidth = 2)
````
