# Futrues Daily Pivot Zones

- url: https://www.tradingview.com/script/KWmPcET8-Futrues-Daily-Pivot-Zones/
- type: indicator
- pine_id: PUB;aefae509e9244c89b3b40b25bc282a91
- version: 5.0

## Description

Automatically plots Daily Pivot Point levels as clean rectangle zones directly on your futures chart. Levels are calculated from the previous day's High, Low, and Close — the same levels watched by institutions, banks, and algorithms every single session.
Levels Included:
PP — Main Pivot Point (most watched level of the day)
R1, R2, R3 — Resistance zones above PP
S1, S2, S3 — Support zones below PP
PDH — Previous Day High
PDL — Previous Day Low
How To Use:
Look for price to reject or bounce off a zone in confluence with your EMA bias and VWAP direction. The more factors that agree at a zone — the stronger the trade.
Recommended Zone Buffer By Instrument:
MES (Micro E-Mini S&P 500) → 4.0 - 5.0 points
MNQ (Micro E-Mini Nasdaq) → 8.0 - 10.0 points
MGC (Micro Gold) → 15.0 - 20.0 points
MCL (Micro Crude Oil) → 0.15 - 0.25 points
M2K (Micro Russell 2000) → 3.0 - 4.0 points
Recommended Lookback:
750 bars on a 15-min chart covers approximately 3 trading days of price action.

## Source Code

````pine
//@version=5
indicator("Futures Pivot Zones", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
zoneBuffer  = input.float(4.0,  "Zone Buffer (points)", minval=0.5, step=0.5)
zoneExtend  = input.int(500,    "Extend Right (bars)",  minval=10,  maxval=1000)
lookback    = input.int(50,     "Pivot Lookback (bars)", minval=5,  maxval=500)

showPP      = input.bool(true, "Show Pivot Point (PP)")
showR1      = input.bool(true, "Show R1")
showR2      = input.bool(true, "Show R2")
showR3      = input.bool(true, "Show R3")
showS1      = input.bool(true, "Show S1")
showS2      = input.bool(true, "Show S2")
showS3      = input.bool(true, "Show S3")
showPDHL    = input.bool(true, "Show Period High/Low")

ppColor     = input.color(color.new(color.white,  70), "PP Color")
resColor    = input.color(color.new(color.red,    70), "Resistance Color")
supColor    = input.color(color.new(color.green,  70), "Support Color")
pdhlColor   = input.color(color.new(color.aqua,   70), "Period High/Low Color")

// ─── GET HIGH LOW CLOSE OVER LOOKBACK ────────────────────────────────────────
periodHigh  = ta.highest(high,  lookback)
periodLow   = ta.lowest(low,    lookback)
periodClose = close

// ─── CALCULATE PIVOT POINTS ───────────────────────────────────────────────────
PP = (periodHigh + periodLow + periodClose) / 3

R1 = 2 * PP - periodLow
R2 = PP + (periodHigh - periodLow)
R3 = periodHigh + 2 * (PP - periodLow)

S1 = 2 * PP - periodHigh
S2 = PP - (periodHigh - periodLow)
S3 = periodLow - 2 * (periodHigh - PP)

// ─── DRAW FUNCTION ────────────────────────────────────────────────────────────
drawZone(lvl, col, lbl) =>
    if barstate.islast
        leftBar  = bar_index - 750
        rightBar = bar_index + zoneExtend
        box.new(
             left         = leftBar,
             top          = lvl + zoneBuffer,
             right        = rightBar,
             bottom       = lvl - zoneBuffer,
             border_color = col,
             border_width  = 1,
             bgcolor       = col,
             text          = lbl,
             text_color    = color.white,
             text_size     = size.small)

// ─── DRAW MAIN PIVOTS ─────────────────────────────────────────────────────────
if showPP
    drawZone(PP, ppColor, "PP")
if showR1
    drawZone(R1, resColor, "R1")
if showR2
    drawZone(R2, resColor, "R2")
if showR3
    drawZone(R3, resColor, "R3")
if showS1
    drawZone(S1, supColor, "S1")
if showS2
    drawZone(S2, supColor, "S2")
if showS3
    drawZone(S3, supColor, "S3")

// ─── DRAW PERIOD HIGH/LOW ─────────────────────────────────────────────────────
if showPDHL
    drawZone(periodHigh, pdhlColor, "PHigh")
    drawZone(periodLow,  pdhlColor, "PLow")
````
