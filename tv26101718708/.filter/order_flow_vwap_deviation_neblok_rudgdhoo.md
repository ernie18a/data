# Order Flow VWAP Deviation [NeBlok]

- url: https://www.tradingview.com/script/rUDgdhoo-Order-Flow-VWAP-Deviation-NeBlok/
- type: indicator
- pine_id: PUB;b6838432ffeb49649e616685c14e029b
- version: 1.0

## Description

ORDER FLOW VWAP DEVIATION [NeBlok]

Order Flow VWAP Deviation shows where price sits relative to fair value (VWAP) and who is in control, buyers or sellers, at each price level. It combines an anchored VWAP, deviation bands weighted by order flow, a 3D buy/sell volume profile with imbalance detection, band-rejection signals and a live dashboard. Everything is drawn in flat neon colors with large, readable labels.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) ANCHORED VWAP (cyan line)
VWAP resets at the start of each Session, Week or Month (your choice). It is the volume-weighted average price for that period and works as the "fair value" line. Price above VWAP means buyers have control of the period. Price below means sellers do. A yellow background marks each reset bar.

2) ORDER-FLOW DEVIATION BANDS (red upper / green lower)
Standard VWAP bands are symmetric. These are not. Each bar's volume is split into estimated buy volume and sell volume using lower-timeframe (intrabar) data:
- The UPPER bands measure how far price has traveled from VWAP, weighted by BUY volume.
- The LOWER bands measure the same distance, weighted by SELL volume.
When aggressive buyers are active far above VWAP, the upper band widens more than the lower band, and the reverse is true for sellers. The bands expand toward the side where participation is strongest.

Two bands are drawn on each side:
- Inner band (1σ by default): normal rotation zone
- Outer band (2σ by default): extended or stretched zone
The flat neon fill between the inner and outer band highlights the extreme zones.

3) 3D ORDER-FLOW VOLUME PROFILE (right side of chart)
The profile covers the current anchor period. Each row is split into:
- Green segment = estimated buy volume
- Pink segment = estimated sell volume
Rows inside the Value Area are bright. Rows outside it are dimmed. A 3D extrusion adds depth and can be turned off.

Profile markings:
- POC: the price row with the most volume, drawn as a yellow line extending back across the period
- VAH / VAL: the top and bottom of the Value Area (70% of volume by default), drawn as purple dashed lines
- IMBALANCE ROWS: rows where one side outweighs the other by 1.5× or more get an orange outline and a label such as "2.2× BUY" or "1.8× SELL"
- ★ TOP IMBALANCE: the strongest imbalance row gets a yellow outline and a star

4) PERIOD HIGH / LOW
Dashed white lines mark the high and low of the current period, with price labels.

5) BAND REJECTION SIGNALS
- REJ ▼ (red): price tagged the upper band, closed back below it, and the bar had sell-dominant delta
- REJ ▲ (green): price tagged the lower band, closed back above it, and the bar had buy-dominant delta
Signals use the outer band by default, fire only on closed bars, have a cooldown, and are ignored for the first few bars after a reset, while the bands are still too tight to mean anything.

6) DASHBOARD
- VWAP and POC prices
- Price vs VWAP in σ units (shows "EXTENDED" beyond the outer band)
- σ Up / σ Down: current band widths in points
- Band Skew: above 1.15× = BUY-SIDE participation, below 0.87× = SELL-SIDE, otherwise BALANCED
- Period Δ: cumulative estimated buy minus sell volume, with % of total volume
- Flow Data: which intrabar timeframe is being used

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MEAN REVERSION
When price pushes into the outer band and prints a REJ signal, the move is stretched and the aggressive side is losing control. Common targets are the inner band, the POC, or VWAP.

TREND CONTINUATION
In a strong trend, price holds between VWAP and the inner band on pullbacks. A pullback to VWAP that holds, with band skew favoring the trend side, suggests continuation. Closes beyond the outer band with heavy delta in the same direction show strength, not exhaustion. Don't fade those blindly.

READING BAND SKEW
If the upper band is much wider than the lower band (BUY-SIDE skew), buyers have been doing their work at extended prices. If the lower band is wider (SELL-SIDE skew), sellers have. Skew that disagrees with price direction is a warning sign.

USING THE PROFILE
- POC and high-volume rows act as magnets and support/resistance
- Low-volume gaps between rows tend to get crossed quickly
- Imbalance rows show where one side was aggressive. A BUY imbalance below price can act as support on retests, and a SELL imbalance above price can act as resistance
- Price trading outside the Value Area often tries to return to it (or accepts outside and trends)

CONFLUENCE
The strongest setups line up several pieces: an outer-band rejection INTO a POC, VAH/VAL or imbalance row, with delta confirming.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VWAP & DEVIATION
- Anchor Period: Session (intraday), Week or Month (swing)
- Inner / Outer Band σ: band multipliers (default 1.0 / 2.0)
- Show/hide inner bands, outer bands, fill, glow and reset highlight

ORDER FLOW
- Intrabar Timeframe: Auto picks 1m data on charts up to 15m, 5m up to 1H, 15m up to 4H, and 60m above that. On 1m charts and below, the chart bars themselves are used. Custom lets you choose, and it falls back to Auto if you pick a timeframe higher than the chart.

SIGNALS
- Signal Band: Inner or Outer
- Require Order-Flow Confirmation: on = delta must agree with the rejection
- Cooldown: minimum bars between signals of the same direction
- Warm-up: bars to ignore after each reset
- Only on Closed Bars: on = no repainting signals

VOLUME PROFILE
- Rows: more rows = finer detail. If labels overlap, lower this (25–30 works well at Large size)
- Offset / Max Width: where the profile sits and how wide it gets
- Max Bars in Profile: caps history on long anchors to keep it fast
- 3D Extrusion + Depth: turn the 3D effect on or off and adjust thickness
- Imbalance Ratio: how lopsided a row must be to count (default 1.5×)
- Min Row Volume: ignores imbalances on thin rows (% of POC volume)
- Value Area %: default 70%
- Extend POC: draws the POC line back across the period

LABELS & DASHBOARD
- Label Size: Small / Normal / Large / Huge
- Dashboard position and text size
- Every neon color can be customized

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Create an alert, select this indicator, and choose "Any alert() function call." Alerts fire once per bar close for:
- Bearish upper band rejection
- Bullish lower band rejection
- Close above the upper outer band
- Close below the lower outer band
- VWAP reclaimed
- VWAP lost

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Built for liquid futures (NQ, ES, MNQ, MES) and liquid stocks/ETFs on 1m–15m charts with the Session anchor
- Use Week or Month anchors on 1H–4H charts for swing context
- Requires volume data. Symbols without volume will show an error
- Treat signals as areas of interest, not automatic entries. Always combine them with your own structure, risk management and plan

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES & DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Buy and sell volume are ESTIMATED from intrabar price action (where each lower-timeframe bar closes within its range). This is not true bid/ask or footprint data, and results can differ from exchange order-flow tools.
- With "Only on Closed Bars" turned off, signals and the live profile can change until the bar closes.
- This indicator is provided free for educational and informational purposes only. It is NOT financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other instrument.
- Trading futures, stocks, options and other financial instruments involves substantial risk of loss and is not suitable for every investor. You can lose more than your initial investment when trading leveraged products.
- Past performance, backtests, and historical signals do not guarantee future results.
- You are solely responsible for your own trading decisions. Always do your own research and consider consulting a licensed financial professional.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok
//
// ══════════════════════════════════════════════════════════════════════════════
//  ORDER FLOW VWAP DEVIATION [NeBlok]
//  • Anchored VWAP (Session / Week / Month)
//  • Asymmetric deviation bands: upper σ weighted by BUY volume,
//    lower σ weighted by SELL volume (estimated from intrabar data)
//  • Band-rejection signals with order-flow confirmation
//  • 3D extruded buy/sell volume profile with imbalance rows, POC and Value Area
//  • Neon styling, no gradients, large readable labels, live dashboard
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Order Flow VWAP Deviation [NeBlok]", shorttitle = "OF VWAP Dev [NeBlok]", overlay = true,
     max_boxes_count = 500, max_lines_count = 100, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
GV = "VWAP & DEVIATION"
anchorIn     = input.string("Session", "Anchor Period", options = ["Session", "Week", "Month"], group = GV)
srcIn        = input.source(hlc3, "Source", group = GV)
mult1        = input.float(1.0, "Inner Band (σ)", minval = 0.1, step = 0.1, group = GV)
mult2        = input.float(2.0, "Outer Band (σ)", minval = 0.1, step = 0.1, group = GV)
showInner    = input.bool(true, "Show Inner Bands", group = GV)
showOuter    = input.bool(true, "Show Outer Bands", group = GV)
showFill     = input.bool(true, "Flat Neon Fill (Inner → Outer)", group = GV)
showGlow     = input.bool(true, "Neon Glow Lines", group = GV)
showAnchorBg = input.bool(true, "Highlight Anchor Reset", group = GV)

GF = "ORDER FLOW"
ltfMode   = input.string("Auto", "Intrabar Timeframe", options = ["Auto", "Custom"], group = GF,
     tooltip = "Buy/sell volume is estimated from lower-timeframe bars. Auto: 1m data on charts up to 15m, 5m up to 1H, 15m up to 4H, 60m above. On 1m charts and below the chart bar itself is used.")
ltfCustom = input.timeframe("1", "Custom Intrabar TF", group = GF,
     tooltip = "Must be equal to or lower than the chart timeframe. If it is higher, Auto is used instead.")

GS = "SIGNALS"
showSig    = input.bool(true, "Show Band Rejection Signals", group = GS)
sigBand    = input.string("Outer", "Signal Band", options = ["Inner", "Outer"], group = GS)
needFlow   = input.bool(true, "Require Order-Flow Confirmation", group = GS,
     tooltip = "Bear rejection needs a sell-dominant bar delta. Bull rejection needs a buy-dominant bar delta.")
sigCool    = input.int(5, "Cooldown (bars)", minval = 0, group = GS)
sigWarm    = input.int(6, "Warm-up After Anchor (bars)", minval = 0, group = GS,
     tooltip = "Bands are very tight right after a reset. Signals are ignored for this many bars.")
confirmBar = input.bool(true, "Only on Closed Bars", group = GS)

GP = "VOLUME PROFILE"
showProf  = input.bool(true, "Show Order-Flow Profile", group = GP)
rows      = input.int(40, "Rows", minval = 10, maxval = 80, group = GP)
profOff   = input.int(10, "Offset From Last Bar", minval = 2, maxval = 150, group = GP)
profWidth = input.int(50, "Max Width (bars)", minval = 10, maxval = 250, group = GP)
maxBars   = input.int(3000, "Max Bars in Profile", minval = 100, maxval = 5000, group = GP,
     tooltip = "Caps how many bars of the current anchor period feed the profile, to keep it fast on long anchors.")
show3D    = input.bool(true, "3D Extrusion", group = GP)
depthBars = input.int(3, "3D Depth (bars)", minval = 1, maxval = 10, group = GP)
imbRatio  = input.float(1.5, "Imbalance Ratio ≥", minval = 1.05, step = 0.05, group = GP)
imbMinPct = input.float(15.0, "Min Row Volume for Imbalance (% of POC)", minval = 0.0, maxval = 100.0, group = GP)
showVA    = input.bool(true, "Show Value Area", group = GP)
vaPct     = input.float(70.0, "Value Area %", minval = 10.0, maxval = 100.0, group = GP)
extendPOC = input.bool(true, "Extend POC Across Period", group = GP)

GL = "LEVELS & LABELS"
showHL    = input.bool(true, "Show Period High / Low", group = GL)
lblSizeIn = input.string("Normal", "Label Size", options = ["Small", "Normal", "Large", "Huge"], group = GL)

GT = "DASHBOARD"
showTab   = input.bool(true, "Show Dashboard", group = GT)
tabPosIn  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GT)
tabSizeIn = input.string("Normal", "Text Size", options = ["Small", "Normal", "Large"], group = GT)

GC = "NEON COLORS"
cVwap = input.color(#00F0FF, "VWAP",       group = GC, inline = "c1")
cUp   = input.color(#FF1F4B, "Upper",      group = GC, inline = "c1")
cDn   = input.color(#00FF85, "Lower",      group = GC, inline = "c1")
cBuy  = input.color(#39FF14, "Buy",        group = GC, inline = "c2")
cSell = input.color(#FF2BD6, "Sell",       group = GC, inline = "c2")
cImb  = input.color(#FF9900, "Imbalance",  group = GC, inline = "c3")
cTop  = input.color(#FFF200, "Top Imb / POC", group = GC, inline = "c3")
cVA   = input.color(#B84DFF, "Value Area", group = GC, inline = "c4")
cHL   = input.color(#FFFFFF, "High / Low", group = GC, inline = "c4")
C_BG  = #05070D

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
sizeOf(string s) =>
    switch s
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

posOf(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

fmtSigned(float v, string f) =>
    (v >= 0 ? "+" : "") + str.tostring(v, f)

string lblSize = sizeOf(lblSizeIn)

// ─────────────────────────────────────────────────────────────────────────────
// ORDER FLOW ESTIMATE (intrabar close-location split)
// ─────────────────────────────────────────────────────────────────────────────
int    chartSec = timeframe.in_seconds()
string autoLtf  = chartSec <= 60 ? timeframe.period : chartSec <= 900 ? "1" : chartSec <= 3600 ? "5" : chartSec <= 14400 ? "15" : "60"
string ltf      = ltfMode == "Custom" and timeframe.in_seconds(ltfCustom) <= chartSec ? ltfCustom : autoLtf

[ih, il, ic, iv] = request.security_lower_tf(syminfo.tickerid, ltf, [high, low, close, volume])

float buyVol  = 0.0
float sellVol = 0.0
int   nIntra  = iv.size()
if nIntra > 0
    for i = 0 to nIntra - 1
        float h_ = ih.get(i)
        float l_ = il.get(i)
        float c_ = ic.get(i)
        float v_ = nz(iv.get(i))
        float bf = h_ > l_ ? (c_ - l_) / (h_ - l_) : 0.5
        buyVol  += v_ * bf
        sellVol += v_ * (1.0 - bf)
else
    float v_ = nz(volume)
    float bf = high > low ? (close - low) / (high - low) : 0.5
    buyVol  := v_ * bf
    sellVol := v_ * (1.0 - bf)

float barDelta = buyVol - sellVol
float cumVol   = ta.cum(nz(volume))
if barstate.islast and cumVol == 0
    runtime.error("No volume data for this symbol. Order Flow VWAP Deviation [NeBlok] needs volume.")

// ─────────────────────────────────────────────────────────────────────────────
// ANCHOR + ACCUMULATION
// ─────────────────────────────────────────────────────────────────────────────
bool newAnchor = switch anchorIn
    "Week"  => timeframe.change("W")
    "Month" => timeframe.change("M")
    => timeframe.change("D")
newAnchor := newAnchor or bar_index == 0

var float refPx = na      // reference price keeps the variance math numerically clean
var float sV    = 0.0
var float sPV   = 0.0
var float sB    = 0.0
var float sBX   = 0.0
var float sBX2  = 0.0
var float sS    = 0.0
var float sSX   = 0.0
var float sSX2  = 0.0
var float sesHi = na
var float sesLo = na
var int   sesHiBar  = na
var int   sesLoBar  = na
var int   anchorBar = na

var array<float> aHi = array.new<float>()
var array<float> aLo = array.new<float>()
var array<float> aB  = array.new<float>()
var array<float> aS  = array.new<float>()

if newAnchor
    refPx     := srcIn
    sV        := 0.0
    sPV       := 0.0
    sB        := 0.0
    sBX       := 0.0
    sBX2      := 0.0
    sS        := 0.0
    sSX       := 0.0
    sSX2      := 0.0
    sesHi     := high
    sesLo     := low
    sesHiBar  := bar_index
    sesLoBar  := bar_index
    anchorBar := bar_index
    aHi.clear()
    aLo.clear()
    aB.clear()
    aS.clear()
else
    if high > sesHi
        sesHi    := high
        sesHiBar := bar_index
    if low < sesLo
        sesLo    := low
        sesLoBar := bar_index

float x    = srcIn - refPx
float vTot = buyVol + sellVol
sV   += vTot
sPV  += vTot * x
sB   += buyVol
sBX  += buyVol * x
sBX2 += buyVol * x * x
sS   += sellVol
sSX  += sellVol * x
sSX2 += sellVol * x * x

aHi.push(high)
aLo.push(low)
aB.push(buyVol)
aS.push(sellVol)
if aHi.size() > maxBars
    aHi.shift()
    aLo.shift()
    aB.shift()
    aS.shift()

// ─────────────────────────────────────────────────────────────────────────────
// VWAP + ORDER-FLOW WEIGHTED DEVIATION
// σ_up = sqrt( Σ buyVol·(src − VWAP)² / Σ buyVol )
// σ_dn = sqrt( Σ sellVol·(src − VWAP)² / Σ sellVol )
// ─────────────────────────────────────────────────────────────────────────────
float m     = sV > 0 ? sPV / sV : 0.0
float vwap  = refPx + m
float sigUp = sB > 0 ? math.sqrt(math.max((sBX2 - 2.0 * m * sBX + m * m * sB) / sB, 0.0)) : 0.0
float sigDn = sS > 0 ? math.sqrt(math.max((sSX2 - 2.0 * m * sSX + m * m * sS) / sS, 0.0)) : 0.0

float up1 = vwap + mult1 * sigUp
float up2 = vwap + mult2 * sigUp
float dn1 = vwap - mult1 * sigDn
float dn2 = vwap - mult2 * sigDn

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS (flat neon, glow underlay, no gradients)
// ─────────────────────────────────────────────────────────────────────────────
float pV  = newAnchor ? na : vwap
float pU1 = newAnchor ? na : up1
float pU2 = newAnchor ? na : up2
float pD1 = newAnchor ? na : dn1
float pD2 = newAnchor ? na : dn2

plot(showGlow ? pV : na, "VWAP Glow", color.new(cVwap, 78), 8, plot.style_linebr, editable = false, display = display.pane)
plot(showGlow and showOuter ? pU2 : na, "Upper Glow", color.new(cUp, 82), 7, plot.style_linebr, editable = false, display = display.pane)
plot(showGlow and showOuter ? pD2 : na, "Lower Glow", color.new(cDn, 82), 7, plot.style_linebr, editable = false, display = display.pane)

pVw  = plot(pV,  "VWAP",        cVwap, 3, plot.style_linebr)
pU1p = plot(pU1, "Upper Inner", showInner ? color.new(cUp, 25) : na, 1, plot.style_linebr)
pU2p = plot(pU2, "Upper Outer", showOuter ? cUp : na, 2, plot.style_linebr)
pD1p = plot(pD1, "Lower Inner", showInner ? color.new(cDn, 25) : na, 1, plot.style_linebr)
pD2p = plot(pD2, "Lower Outer", showOuter ? cDn : na, 2, plot.style_linebr)

fill(pU1p, pU2p, color = showFill ? color.new(cUp, 88) : na, title = "Upper Zone Fill")
fill(pD1p, pD2p, color = showFill ? color.new(cDn, 88) : na, title = "Lower Zone Fill")

bgcolor(showAnchorBg and newAnchor ? color.new(cTop, 70) : na, title = "Anchor Reset")

// ─────────────────────────────────────────────────────────────────────────────
// SIGNALS — band rejection with order-flow confirmation
// ─────────────────────────────────────────────────────────────────────────────
float sigUpper = sigBand == "Inner" ? up1 : up2
float sigLower = sigBand == "Inner" ? dn1 : dn2
bool  okBar    = confirmBar ? barstate.isconfirmed : true
bool  warmOk   = bar_index - anchorBar >= sigWarm

var int lastBear = -100000
var int lastBull = -100000

bool bearSig = not newAnchor and okBar and warmOk and high >= sigUpper and close < sigUpper and (not needFlow or barDelta < 0) and bar_index - lastBear > sigCool
bool bullSig = not newAnchor and okBar and warmOk and low <= sigLower and close > sigLower and (not needFlow or barDelta > 0) and bar_index - lastBull > sigCool

if bearSig
    lastBear := bar_index
    if showSig
        label.new(bar_index, high, "REJ ▼", style = label.style_label_down, color = cUp, textcolor = #000000, size = lblSize,
             tooltip = "Upper band rejection\nBar Δ: " + str.tostring(barDelta, format.volume) + "\nBand: " + str.tostring(sigUpper, format.mintick))
if bullSig
    lastBull := bar_index
    if showSig
        label.new(bar_index, low, "REJ ▲", style = label.style_label_up, color = cDn, textcolor = #000000, size = lblSize,
             tooltip = "Lower band rejection\nBar Δ: " + str.tostring(barDelta, format.volume) + "\nBand: " + str.tostring(sigLower, format.mintick))

// ─────────────────────────────────────────────────────────────────────────────
// PERIOD HIGH / LOW
// ─────────────────────────────────────────────────────────────────────────────
var line  hiLn = na
var line  loLn = na
var label hiLb = na
var label loLb = na

if barstate.islast
    line.delete(hiLn)
    line.delete(loLn)
    label.delete(hiLb)
    label.delete(loLb)
    if showHL
        int    xE   = bar_index + profOff + profWidth + depthBars
        int    x0   = bar_index + profOff
        string name = anchorIn == "Session" ? "SESSION" : str.upper(anchorIn)
        hiLn := line.new(math.max(sesHiBar, bar_index - 4900), sesHi, xE, sesHi, color = color.new(cHL, 30), style = line.style_dashed, width = 1)
        loLn := line.new(math.max(sesLoBar, bar_index - 4900), sesLo, xE, sesLo, color = color.new(cHL, 30), style = line.style_dashed, width = 1)
        hiLb := label.new(x0, sesHi, name + " HIGH  " + str.tostring(sesHi, format.mintick), style = label.style_label_lower_left,
             color = color.new(C_BG, 10), textcolor = cHL, size = lblSize)
        loLb := label.new(x0, sesLo, name + " LOW  " + str.tostring(sesLo, format.mintick), style = label.style_label_upper_left,
             color = color.new(C_BG, 10), textcolor = cHL, size = lblSize)

// ─────────────────────────────────────────────────────────────────────────────
// 3D ORDER-FLOW VOLUME PROFILE
// ─────────────────────────────────────────────────────────────────────────────
var array<box>   pBoxes  = array.new<box>()
var array<label> pLabels = array.new<label>()
var array<line>  pLines  = array.new<line>()
var float        pocPrice = na

if barstate.islast
    for bx in pBoxes
        bx.delete()
    pBoxes.clear()
    for lb in pLabels
        lb.delete()
    pLabels.clear()
    for ln in pLines
        ln.delete()
    pLines.clear()

    int   n   = aHi.size()
    float pHi = n > 0 ? aHi.max() : na
    float pLo = n > 0 ? aLo.min() : na

    if showProf and n > 0 and pHi > pLo
        float rowH = (pHi - pLo) / rows
        array<float> rb = array.new<float>(rows, 0.0)
        array<float> rs = array.new<float>(rows, 0.0)

        // distribute each bar's buy/sell volume across the rows it spans
        for i = 0 to n - 1
            float h_ = aHi.get(i)
            float l_ = aLo.get(i)
            float b_ = aB.get(i)
            float s_ = aS.get(i)
            int   r0 = math.max(0, math.min(rows - 1, int(math.floor((l_ - pLo) / rowH))))
            int   r1 = math.max(0, math.min(rows - 1, int(math.floor((h_ - pLo) / rowH))))
            if r0 == r1 or h_ <= l_
                rb.set(r0, rb.get(r0) + b_)
                rs.set(r0, rs.get(r0) + s_)
            else
                float rng = h_ - l_
                for r = r0 to r1
                    float rBot = pLo + r * rowH
                    float rTop = rBot + rowH
                    float ov   = math.min(h_, rTop) - math.max(l_, rBot)
                    if ov > 0
                        float f = ov / rng
                        rb.set(r, rb.get(r) + b_ * f)
                        rs.set(r, rs.get(r) + s_ * f)

        // totals + POC
        array<float> rt = array.new<float>(rows, 0.0)
        float maxT   = 0.0
        float totV   = 0.0
        int   pocIdx = 0
        for r = 0 to rows - 1
            float t = rb.get(r) + rs.get(r)
            rt.set(r, t)
            totV += t
            if t > maxT
                maxT   := t
                pocIdx := r

        if maxT > 0
            pocPrice := pLo + (pocIdx + 0.5) * rowH

            // imbalance rows
            array<float> ratioArr = array.new<float>(rows, 0.0)
            int   topIdx   = -1
            float topRatio = 0.0
            for r = 0 to rows - 1
                float b_    = rb.get(r)
                float s_    = rs.get(r)
                float t     = rt.get(r)
                float ratio = math.min(math.max(b_, s_) / math.max(math.min(b_, s_), 1e-10), 99.0)
                bool  ok    = t >= maxT * imbMinPct / 100.0 and ratio >= imbRatio
                ratioArr.set(r, ok ? ratio : 0.0)
                if ok and ratio > topRatio
                    topRatio := ratio
                    topIdx   := r

            // value area
            int   vaUp  = pocIdx
            int   vaDn  = pocIdx
            float vaVol = rt.get(pocIdx)
            float vaTgt = totV * vaPct / 100.0
            while vaVol < vaTgt and (vaUp < rows - 1 or vaDn > 0)
                float nextUp = vaUp < rows - 1 ? rt.get(vaUp + 1) : -1.0
                float nextDn = vaDn > 0 ? rt.get(vaDn - 1) : -1.0
                if nextUp >= nextDn
                    vaUp  += 1
                    vaVol += nextUp
                else
                    vaDn  -= 1
                    vaVol += nextDn

            int   x0   = bar_index + profOff
            float gap  = rowH * 0.18
            float dPx  = rowH * 0.30
            int   dX   = show3D ? depthBars : 0

            // POC extension line back across the period
            if extendPOC
                pLines.push(line.new(math.max(anchorBar, bar_index - 4900), pocPrice, x0, pocPrice, color = color.new(cTop, 15), width = 2))

            // Value area edges across the profile
            if showVA
                float vahY = pLo + (vaUp + 0.5) * rowH
                float valY = pLo + (vaDn + 0.5) * rowH
                pLines.push(line.new(x0, vahY, x0 + profWidth + dX, vahY, color = cVA, style = line.style_dashed, width = 2))
                pLines.push(line.new(x0, valY, x0 + profWidth + dX, valY, color = cVA, style = line.style_dashed, width = 2))

            for r = 0 to rows - 1
                float t = rt.get(r)
                if t <= 0
                    continue
                float b_   = rb.get(r)
                float s_   = rs.get(r)
                float bot  = pLo + r * rowH + gap
                float top  = pLo + (r + 1) * rowH - gap
                float midY = pLo + (r + 0.5) * rowH
                int   bLen = int(math.round(b_ / maxT * profWidth))
                int   sLen = int(math.round(s_ / maxT * profWidth))
                int   tLen = math.max(bLen + sLen, 1)
                int   xR   = x0 + tLen
                float ratio    = ratioArr.get(r)
                bool  isImb    = ratio > 0
                bool  isTopImb = r == topIdx
                bool  inVA     = showVA and r >= vaDn and r <= vaUp
                bool  buyDom   = b_ >= s_
                int   tr       = isImb ? 0 : inVA ? 20 : 55
                color domC     = buyDom ? cBuy : cSell

                // 3D extrusion: top face + side face drawn behind the front bar
                if show3D
                    pBoxes.push(box.new(math.min(x0 + depthBars, xR), top + dPx, xR, top,
                         border_width = 0, bgcolor = color.new(domC, math.min(tr + 45, 90))))
                    pBoxes.push(box.new(xR, top + dPx, xR + depthBars, bot + dPx,
                         border_width = 0, bgcolor = color.new(domC, math.min(tr + 65, 95))))

                // front face: buy segment + sell segment
                if bLen > 0
                    pBoxes.push(box.new(x0, top, x0 + bLen, bot, border_width = 0, bgcolor = color.new(cBuy, tr)))
                if sLen > 0
                    pBoxes.push(box.new(x0 + bLen, top, x0 + bLen + sLen, bot, border_width = 0, bgcolor = color.new(cSell, tr)))
                if bLen + sLen == 0
                    pBoxes.push(box.new(x0, top, x0 + 1, bot, border_width = 0, bgcolor = color.new(domC, tr)))

                // imbalance outline
                if isImb
                    pBoxes.push(box.new(x0, top, xR, bot, border_color = isTopImb ? cTop : cImb,
                         border_width = isTopImb ? 3 : 2, bgcolor = color(na)))

                // one label per row: imbalance text and/or level tag
                string tag    = r == pocIdx ? "POC" : showVA and r == vaUp ? "VAH" : showVA and r == vaDn ? "VAL" : ""
                string imbTxt = isImb ? (isTopImb ? "★ " : "") + str.tostring(ratio, "0.0") + "× " + (buyDom ? "BUY" : "SELL") : ""
                string lvlTxt = tag != "" ? tag + " " + str.tostring(midY, format.mintick) : ""
                string txt    = imbTxt != "" and lvlTxt != "" ? imbTxt + "  │  " + lvlTxt : imbTxt + lvlTxt
                if txt != ""
                    color tc = isTopImb ? cTop : isImb ? domC : tag == "POC" ? cTop : cVA
                    pLabels.push(label.new(xR + dX + 1, midY, txt, style = label.style_label_left,
                         color = color.new(C_BG, 10), textcolor = tc, size = lblSize))

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table dash = table.new(posOf(tabPosIn), 2, 8, bgcolor = color.new(C_BG, 5), frame_color = cVwap,
     frame_width = 2, border_color = color.new(cVwap, 75), border_width = 1)

if barstate.islast and showTab
    string tsz      = sizeOf(tabSizeIn)
    float  z        = close >= vwap ? (sigUp > 0 ? (close - vwap) / sigUp : 0.0) : (sigDn > 0 ? (close - vwap) / sigDn : 0.0)
    float  sesDelta = sB - sS
    float  dPct     = sV > 0 ? sesDelta / sV * 100.0 : 0.0
    float  skew     = sigDn > 0 ? sigUp / sigDn : 1.0
    string skewTxt  = skew > 1.15 ? "BUY-SIDE" : skew < 0.87 ? "SELL-SIDE" : "BALANCED"
    color  skewCol  = skew > 1.15 ? cBuy : skew < 0.87 ? cSell : cHL
    string zone     = z >= mult2 ? "  EXTENDED ↑" : z <= -mult2 ? "  EXTENDED ↓" : ""

    table.cell(dash, 0, 0, "OF VWAP DEVIATION", text_color = cVwap, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 0, "[NeBlok]", text_color = cTop, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 1, "VWAP", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(vwap, format.mintick), text_color = cVwap, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 2, "POC", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 2, na(pocPrice) ? "—" : str.tostring(pocPrice, format.mintick), text_color = cTop, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Price vs VWAP", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 3, fmtSigned(z, "0.00") + "σ" + zone, text_color = z >= 0 ? cBuy : cSell, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 4, "σ Up / σ Down", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(sigUp, format.mintick) + " / " + str.tostring(sigDn, format.mintick), text_color = cHL, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Band Skew", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(skew, "0.00") + "×  " + skewTxt, text_color = skewCol, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Period Δ", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 6, (sesDelta >= 0 ? "+" : "") + str.tostring(sesDelta, format.volume) + "  (" + fmtSigned(dPct, "0.0") + "%)",
         text_color = sesDelta >= 0 ? cBuy : cSell, text_size = tsz, text_halign = text.align_right)

    table.cell(dash, 0, 7, "Flow Data", text_color = cHL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 7, ltf == timeframe.period ? "Chart bars" : "Intrabar " + ltf, text_color = color.new(cHL, 30), text_size = tsz, text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
bool crossUpOuter = ta.crossover(close, up2) and not newAnchor
bool crossDnOuter = ta.crossunder(close, dn2) and not newAnchor
bool crossUpVwap  = ta.crossover(close, vwap) and not newAnchor
bool crossDnVwap  = ta.crossunder(close, vwap) and not newAnchor

if bearSig
    alert("OF VWAP Dev [NeBlok] — Bearish upper band rejection on " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bullSig
    alert("OF VWAP Dev [NeBlok] — Bullish lower band rejection on " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if crossUpOuter
    alert("OF VWAP Dev [NeBlok] — Close above upper outer band on " + syminfo.ticker, alert.freq_once_per_bar_close)
if crossDnOuter
    alert("OF VWAP Dev [NeBlok] — Close below lower outer band on " + syminfo.ticker, alert.freq_once_per_bar_close)
if crossUpVwap
    alert("OF VWAP Dev [NeBlok] — Reclaimed VWAP on " + syminfo.ticker, alert.freq_once_per_bar_close)
if crossDnVwap
    alert("OF VWAP Dev [NeBlok] — Lost VWAP on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
