# Adaptive Volatility Bands [I.M]

- url: https://www.tradingview.com/script/4lSBcoMD/
- type: indicator
- pine_id: PUB;7e0246e2f2cd445eb9d1b2a344852458
- version: 1.0

## Description

Adaptive Volatility Bands [I.M]

A clean, directional volatility envelope that visually highlights the dominant side of the market. Instead of showing bands on both sides at once, AVB displays a single trailing gradient band that flips with the trend — acting as dynamic support during uptrends and dynamic resistance during downtrends.

▶ HOW IT WORKS

1. CENTER LINE
A double-smoothed baseline (WMA → EMA) defines the underlying trend. Its slope determines whether the market is in bullish or bearish mode.

2. TRAILING BAND
A single ATR-based band is plotted on the dominant side:
- Uptrend → band sits BELOW price (support zone)
- Downtrend → band sits ABOVE price (resistance zone)

3. GRADIENT FILL
The space between the trailing band and price is filled with 8 progressive transparency layers, creating a smooth gradient that fades toward the candles. This makes the trend visually unambiguous at a glance.

▶ HOW TO USE IT

The core principle is simple: TRADE WITH THE BAND, NEVER AGAINST IT.

When the band is GREEN (below price):
- The market is in an uptrend
- Look for LONG entries on pullbacks toward the band
- The trailing band acts as a dynamic stop-loss reference
- Avoid shorting until the band flips to red above price

When the band is RED (above price):
- The market is in a downtrend
- Look for SHORT entries on rallies toward the band
- The trailing band acts as a dynamic stop-loss reference
- Avoid longs until the band flips to green below price

TREND FLIPS: When the band switches sides, treat it as a regime change. Wait for confirmation (a clean close on the new side) before committing — the first bars after a flip are noisy.

▶ SETTINGS

- Length / Smoothing: control baseline responsiveness
- ATR Length: volatility lookback for band distance
- Band Distance (ATR): how far the band sits from the baseline (default 2.0)
- Gradient Layers: smoothness of the fill (3–15)
- Up / Down Colors: fully customizable

▶ ALERTS

- Bullish / Bearish baseline crosses
- Trend flip to bullish / bearish

▶ NOTES

This indicator is a visual trend filter, not a standalone signal generator. It works best when combined with momentum or volume confirmation. The unilateral design is intentional — it forces directional discipline and discourages counter-trend trading.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=6
indicator("Adaptive Volatility Bands [I.M]", shorttitle="AVB [I.M]", overlay=true, max_bars_back=500)

// =============================================================================
// Adaptive Volatility Bands [I.M]
// -----------------------------------------------------------------------------
// Trailing volatility band that follows the dominant side of price.
// In uptrend: gradient support band below price.
// In downtrend: gradient resistance band above price.
// =============================================================================

// === Inputs ==================================================================
g1 = "── Center Line ──"
length    = input.int(50, "Length",    minval=2, group=g1)
smoothLen = input.int(5,  "Smoothing", minval=1, group=g1)

g2 = "── Bands ──"
atrLen   = input.int(14,    "ATR Length",  minval=1, group=g2)
bandMult = input.float(2.0, "Band Distance (ATR)", minval=0.5, step=0.1, group=g2, tooltip="How far the trailing band sits from the center line")
gradLayers = input.int(8, "Gradient Layers", minval=3, maxval=15, group=g2, tooltip="More layers = smoother gradient")

g3 = "── Visual ──"
upColor   = input.color(color.rgb(38, 166, 154),  "Up Color",   group=g3)
dnColor   = input.color(color.rgb(239, 83, 80),   "Down Color", group=g3)
showPanel = input.bool(true, "Show Info Panel", group=g3)

// === Calculations ============================================================
wma   = ta.wma(close, length)
basis = ta.ema(wma, smoothLen)
atr   = ta.atr(atrLen)

// Trend detection: baseline slope
var bool isUp = true
if basis > basis[1]
    isUp := true
else if basis < basis[1]
    isUp := false

trendCol = isUp ? upColor : dnColor

// Trailing band: ONE side only, depending on trend
trailBand = isUp ? basis - atr * bandMult : basis + atr * bandMult

// === Plots ===================================================================
plot(basis, "Center", color=color.new(trendCol, 30), linewidth=1)

pTrail = plot(trailBand, "Trailing Band", color=color.new(trendCol, 0), linewidth=2)
pPrice = plot(close, "Price Anchor", color=na, display=display.none, editable=false)

// === GRADIENT FILL (unilateral) ==============================================
step = (close - trailBand) / gradLayers

l1 = trailBand + step * 1
l2 = trailBand + step * 2
l3 = trailBand + step * 3
l4 = trailBand + step * 4
l5 = trailBand + step * 5
l6 = trailBand + step * 6
l7 = trailBand + step * 7

p1 = plot(l1, color=na, display=display.none, editable=false)
p2 = plot(l2, color=na, display=display.none, editable=false)
p3 = plot(l3, color=na, display=display.none, editable=false)
p4 = plot(l4, color=na, display=display.none, editable=false)
p5 = plot(l5, color=na, display=display.none, editable=false)
p6 = plot(l6, color=na, display=display.none, editable=false)
p7 = plot(l7, color=na, display=display.none, editable=false)

fill(pTrail, p1, color=color.new(trendCol, 70))
fill(p1,     p2, color=color.new(trendCol, 74))
fill(p2,     p3, color=color.new(trendCol, 78))
fill(p3,     p4, color=color.new(trendCol, 82))
fill(p4,     p5, color=color.new(trendCol, 86))
fill(p5,     p6, color=color.new(trendCol, 90))
fill(p6,     p7, color=color.new(trendCol, 93))
fill(p7, pPrice, color=color.new(trendCol, 96))

// === Info Panel ==============================================================
if showPanel and barstate.islast
    var table panel = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.new(color.gray, 70))

    trendTxt  = isUp ? "▲ BULLISH" : "▼ BEARISH"
    distance  = math.abs(close - trailBand) / close * 100
    distTxt   = str.tostring(distance, "#.##") + " %"
    atrTxt    = str.tostring(atr, format.mintick)

    table.cell(panel, 0, 0, "Trend",     text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 0, trendTxt,    text_color=trendCol,    text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 1, "Band Dist", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 1, distTxt,     text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 2, "ATR",       text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 2, atrTxt,      text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))

// === Alerts ==================================================================
alertcondition(ta.crossover(close, basis),  title="AVB Cross Up",   message="Adaptive Volatility Bands: Bullish cross")
alertcondition(ta.crossunder(close, basis), title="AVB Cross Down", message="Adaptive Volatility Bands: Bearish cross")
alertcondition(not isUp[1] and isUp,         title="AVB Trend Up",   message="Adaptive Volatility Bands: Trend flipped to BULLISH")
alertcondition(isUp[1] and not isUp,         title="AVB Trend Down", message="Adaptive Volatility Bands: Trend flipped to BEARISH")
````
