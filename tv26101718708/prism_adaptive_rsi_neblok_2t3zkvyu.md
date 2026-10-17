# Prism Adaptive RSI [NeBlok]

- url: https://www.tradingview.com/script/2T3zKvYU-Prism-Adaptive-RSI-NeBlok/
- type: indicator
- pine_id: PUB;5dbe9ae7f28247fe8d6aad516f393a6e
- version: 1.0

## Description

Prism Adaptive RSI [NeBlok]

OVERVIEW
Prism Adaptive RSI is a momentum oscillator built on an RSI whose lookback length changes bar by bar to match current market conditions. Instead of a single line, it plots five layers of the same adaptive RSI at staggered speeds and shades the space between them as a "prism" ribbon. When the fastest layer crosses the slowest layer, the ribbon visibly twists. That twist is the core momentum signal.

A standard RSI uses a fixed lookback, so it gives false overbought/oversold readings in choppy markets and flips too early in strong trends. This version adapts: it speeds up when price is trending cleanly and slows down when price is chopping sideways.

HOW IT WORKS

1. Adaptive Engine (choose one in settings)

Efficiency Ratio (default)
Measures how directly price has traveled over the lookback window compared to the total distance it moved bar to bar. A clean, one-directional move scores near 1. Sideways noise scores near 0.
- Trending market → shorter RSI length → the oscillator reaches and holds its extremes, so a strong trend stays "pinned" near 80+ or 20- instead of giving early exit signals.
- Choppy market → longer RSI length → the oscillator stays closer to the middle, which filters out fake overbought/oversold readings.

Dominant Cycle
Uses the Ehlers homodyne discriminator to estimate the market's current dominant cycle (in bars), then sets the RSI length to a fraction of that cycle (half by default). This suits markets that rotate rhythmically rather than trend.

The adaptive length is always kept between your Min Length and Max Length settings.

2. The Prism Ribbon
Five copies of the adaptive RSI are calculated, each running at a different multiple of the adaptive length (from fast to slow). The four bands between them are shaded on a red → amber → green spectrum based on where the oscillator sits:
- Green: momentum in the upper zone (bullish pressure)
- Amber: neutral / transitioning momentum
- Red: momentum in the lower zone (bearish pressure)

The fast layer is drawn as the bright glowing line. The slow layer is the thin line at the other edge of the ribbon.

3. The 3D Look
TradingView does not support true 3D rendering, so depth is simulated with an extruded "wall" beneath the ribbon, layered transparency from front to back, a neon glow on the lead line, and a thin highlight along the top edge. Each effect can be switched off under Visuals.

HOW TO READ IT

Ribbon direction
- Fast layer above slow layer = bullish twist (momentum rising)
- Fast layer below slow layer = bearish twist (momentum falling)

Ribbon width
- A wide ribbon means the fast and slow layers disagree strongly, which usually means momentum is accelerating.
- A narrow, flattening ribbon means momentum is fading and a twist may be coming.

Pinned extremes
When the ribbon holds above 80 or below 20 for an extended period, that is usually a sign of trend strength, not an automatic reversal signal. The adaptive engine is designed to let strong trends stay pinned.

SIGNALS

Dot = Ribbon Flip
The fast layer crossed the slow layer. This marks a shift in short-term momentum direction.

Diamond = Exhaustion Flip
A flip that happens shortly after the fast layer touched the overbought or oversold zone (within the Exhaustion Lookback window). These mark momentum turning after a stretched move and are the higher-quality signal of the two.

Buy Low / Sell High Filter (on by default)
When enabled, bullish flips only count if the slow layer is below 50, and bearish flips only count if it is above 50. This removes flips that happen in the "wrong" half of the range, such as a bullish flip that fires when momentum is already extended.

DASHBOARD
The table in the corner of the pane shows live readings:
- Engine: which adaptive engine is active
- Length: the current adaptive RSI length
- Regime: Trending, Mixed, or Choppy, based on the efficiency ratio
- Momentum: current twist direction
- Zone: Overbought, Oversold, or Neutral

HOW TO USE IT

Trend continuation
In a Trending regime, look for the ribbon to pull back toward the middle without fully breaking down, then flip back in the trend's direction. Flips with the trend tend to be more reliable than flips against it.

Mean reversion
In a Choppy regime, diamonds (exhaustion flips) near the zones can mark turning points within a range. Choppy conditions also produce more flips overall, so be selective.

Confirmation, not standalone entries
Prism RSI works best as one input among several. Use it to confirm a setup you already have (structure, levels, volume, higher-timeframe bias) rather than as a buy/sell button on its own.

Timeframes
Works on any timeframe and any market. On fast intraday charts (1-5 minute), increasing Post Smoothing to 3 reduces noise. On higher timeframes, the defaults are a good starting point.

SETTINGS GUIDE

Adaptive Engine
- Source: price input (default close)
- Engine: Efficiency Ratio or Dominant Cycle
- Min / Max Length: the range the adaptive RSI length can move within
- Efficiency Lookback: bars used to measure trend efficiency
- Cycle Multiplier: fraction of the dominant cycle used as RSI length (Dominant Cycle engine only)

Prism Ribbon
- Layer Spread: how far apart the five layer speeds are. Higher values make a wider, more dramatic ribbon with fewer flips.
- Post Smoothing: extra smoothing applied to every layer. Raise it to reduce noise.

Signals
- Overbought / Oversold: zone levels (default 80 / 20)
- Buy Low / Sell High Filter: see Signals section above
- Exhaustion Lookback: how recently the fast layer must have touched a zone for a flip to count as an exhaustion flip

Visuals
- Bull / Neutral / Bear colors
- 3D Extrusion and Depth
- Neon Glow
- Top Highlight
- Color Price Bars: tints the main chart candles with the ribbon's color
- Show Dashboard

ALERTS
The script has built-in alerts for bullish flips, bearish flips, bullish exhaustion flips, and bearish exhaustion flips. To use them, create an alert on the indicator and choose "Any alert() function call." Alerts fire once per bar close.

NOTES AND LIMITATIONS
- Signals are confirmed on bar close. On the live (unclosed) bar, the ribbon and any signal can still change until the bar closes.
- The script does not use higher-timeframe data or future bars, so confirmed historical signals do not repaint.
- Like every oscillator, Prism RSI can stay overbought or oversold for long periods during strong trends. An extreme reading alone is not a reversal signal.
- Past signal behavior does not guarantee future results. Always test any tool on your own markets and timeframes before relying on it.

DISCLAIMER
This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, cryptocurrency, or other financial instrument. Trading involves substantial risk of loss and is not suitable for every investor. You are solely responsible for your own trading decisions. Past performance, whether actual or indicated by historical signals, is not indicative of future results. The author assumes no liability for any losses incurred from the use of this indicator. Consult a licensed financial professional before making any investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
indicator("Prism Adaptive RSI [NeBlok]", shorttitle = "Prism RSI [NeBlok]", overlay = false, precision = 2)

// =====================================================================
//  Prism Adaptive RSI [NeBlok]
//  ---------------------------------------------------------------
//  An RSI whose lookback adapts to market conditions, rendered as a
//  five-layer "prism" ribbon. Every layer is the same adaptive RSI run
//  at a staggered speed. When the fast layer crosses the slow layer the
//  ribbon twists, marking a momentum flip.
//
//  Adaptive engines:
//   - Efficiency Ratio: clean trends shorten the lookback so RSI reaches
//     and holds its extremes; chop lengthens it, cutting false OB/OS.
//   - Dominant Cycle: lookback follows a fraction of the measured market
//     cycle (Ehlers homodyne discriminator).
//
//  Signals:
//   - Dot     = ribbon flip (fast layer crosses slow layer)
//   - Diamond = exhaustion flip (flip that follows a visit to OB/OS)
// =====================================================================

// ─────────────────────────── Inputs ───────────────────────────
G_ENG = "Adaptive Engine"
G_RIB = "Prism Ribbon"
G_SIG = "Signals"
G_VIS = "Visuals"

float  src        = input.source(close, "Source", group = G_ENG)
string engine     = input.string("Efficiency Ratio", "Engine", options = ["Efficiency Ratio", "Dominant Cycle"], group = G_ENG,
     tooltip = "Efficiency Ratio: trend strength sets the lookback.\nDominant Cycle: the measured market cycle sets the lookback.")
int    minLenIn   = input.int(8, "Min Length", minval = 2, group = G_ENG)
int    maxLenIn   = input.int(34, "Max Length", minval = 3, group = G_ENG)
int    erLen      = input.int(20, "Efficiency Lookback", minval = 2, group = G_ENG)
float  cycleMult  = input.float(0.5, "Cycle Multiplier", minval = 0.1, step = 0.05, group = G_ENG,
     tooltip = "Fraction of the dominant cycle used as RSI length (Dominant Cycle engine only). 0.5 = half-cycle.")

float  spread     = input.float(0.5, "Layer Spread", minval = 0.1, maxval = 0.9, step = 0.05, group = G_RIB,
     tooltip = "How far apart the five layer speeds are. Higher = wider, more dramatic ribbon.")
int    postSmooth = input.int(2, "Post Smoothing", minval = 1, group = G_RIB)

int    obLevel    = input.int(80, "Overbought", minval = 51, maxval = 99, group = G_SIG)
int    osLevel    = input.int(20, "Oversold", minval = 1, maxval = 49, group = G_SIG)
bool   halfFilter = input.bool(true, "Buy Low / Sell High Filter", group = G_SIG,
     tooltip = "Bull flips only count when the slow layer is below 50; bear flips only when it is above 50.")
int    exhaustLb  = input.int(10, "Exhaustion Lookback", minval = 1, group = G_SIG,
     tooltip = "A flip is upgraded to an exhaustion flip if the fast layer touched OB/OS within this many bars.")

color  bullCol    = input.color(#00E676, "Bull", group = G_VIS, inline = "pal")
color  midCol     = input.color(#FFB300, "Neutral", group = G_VIS, inline = "pal")
color  bearCol    = input.color(#FF1744, "Bear", group = G_VIS, inline = "pal")
bool   show3D     = input.bool(true, "3D Extrusion", group = G_VIS, inline = "3d")
float  wallDepth  = input.float(6.0, "Depth", minval = 1.0, step = 0.5, group = G_VIS, inline = "3d")
bool   glow       = input.bool(true, "Neon Glow", group = G_VIS)
bool   specular   = input.bool(true, "Top Highlight", group = G_VIS)
bool   colorBars  = input.bool(false, "Color Price Bars", group = G_VIS)
bool   showDash   = input.bool(true, "Show Dashboard", group = G_VIS)

int loLen = math.min(minLenIn, maxLenIn)
int hiLen = math.max(minLenIn, maxLenIn)

// ─────────────────────────── Functions ───────────────────────────
// Wilder-style RSI that accepts a fractional, bar-by-bar length.
// na-safe: a single na length would otherwise poison the recursive state forever.
adaptiveRsi(float s, float len) =>
    float L  = na(len) ? 14.0 : math.max(len, 2.0)
    float a  = 1.0 / L
    float ch = nz(s - s[1])
    var float up = 0.0
    var float dn = 0.0
    up := a * math.max(ch, 0.0) + (1.0 - a) * nz(up)
    dn := a * math.max(-ch, 0.0) + (1.0 - a) * nz(dn)
    dn == 0.0 ? 100.0 : up == 0.0 ? 0.0 : 100.0 - 100.0 / (1.0 + up / dn)

// Ehlers homodyne discriminator – returns smoothed dominant cycle period (bars).
dominantCycle(float s) =>
    var float period       = 15.0
    var float smoothPeriod = 15.0
    var float i2 = 0.0
    var float q2 = 0.0
    var float re = 0.0
    var float im = 0.0
    float prevP  = period
    float adj    = 0.075 * prevP + 0.54
    float sm     = (4.0 * s + 3.0 * nz(s[1]) + 2.0 * nz(s[2]) + nz(s[3])) / 10.0
    float det    = (0.0962 * sm + 0.5769 * nz(sm[2]) - 0.5769 * nz(sm[4]) - 0.0962 * nz(sm[6])) * adj
    float q1     = (0.0962 * det + 0.5769 * nz(det[2]) - 0.5769 * nz(det[4]) - 0.0962 * nz(det[6])) * adj
    float i1     = nz(det[3])
    float jI     = (0.0962 * i1 + 0.5769 * nz(i1[2]) - 0.5769 * nz(i1[4]) - 0.0962 * nz(i1[6])) * adj
    float jQ     = (0.0962 * q1 + 0.5769 * nz(q1[2]) - 0.5769 * nz(q1[4]) - 0.0962 * nz(q1[6])) * adj
    float prevI2 = i2
    float prevQ2 = q2
    i2 := 0.2 * (i1 - jQ) + 0.8 * prevI2
    q2 := 0.2 * (q1 + jI) + 0.8 * prevQ2
    re := 0.2 * (i2 * prevI2 + q2 * prevQ2) + 0.8 * re
    im := 0.2 * (i2 * prevQ2 - q2 * prevI2) + 0.8 * im
    float p = prevP
    if im != 0.0 and re != 0.0
        p := 2.0 * math.pi / math.atan(im / re)
    p := math.min(p, 1.5 * prevP)
    p := math.max(p, 0.67 * prevP)
    p := math.max(math.min(p, 50.0), 6.0)
    period       := 0.2 * p + 0.8 * prevP
    smoothPeriod := 0.33 * period + 0.67 * smoothPeriod
    smoothPeriod

// Red → amber → green spectrum keyed to oscillator value.
spectrum(float v) =>
    v < 50 ? color.from_gradient(v, osLevel, 50, bearCol, midCol) : color.from_gradient(v, 50, obLevel, midCol, bullCol)

darken(color c, float k) =>
    color.rgb(color.r(c) * k, color.g(c) * k, color.b(c) * k, color.t(c))

// ─────────────────────────── Adaptive length ───────────────────────────
float erNum  = math.abs(src - src[erLen])
float erDen  = math.sum(math.abs(src - src[1]), erLen)
float erRaw  = erDen > 0 ? nz(erNum) / erDen : 0.0
float er     = nz(ta.ema(erRaw, 3), erRaw)   // ta.ema returns na on the first bars; fall back to raw

float erBasedLen  = hiLen - (hiLen - loLen) * er
float dc          = dominantCycle(src)
float cycBasedLen = math.max(math.min(dc * cycleMult, hiLen), loLen)
float baseLen     = nz(engine == "Efficiency Ratio" ? erBasedLen : cycBasedLen, hiLen)

// ─────────────────────────── Prism layers (fast → slow) ───────────────────────────
float r0 = ta.ema(adaptiveRsi(src, baseLen * (1.0 - spread)),       postSmooth)
float r1 = ta.ema(adaptiveRsi(src, baseLen * (1.0 - spread * 0.5)), postSmooth)
float r2 = ta.ema(adaptiveRsi(src, baseLen),                        postSmooth)
float r3 = ta.ema(adaptiveRsi(src, baseLen * (1.0 + spread * 0.5)), postSmooth)
float r4 = ta.ema(adaptiveRsi(src, baseLen * (1.0 + spread)),       postSmooth)

bool  bullTwist = r0 >= r4
float faceDim   = bullTwist ? 0.0 : 10.0
float midVal    = (r0 + r4) / 2.0
float lowEnv    = math.min(r0, r1, r2, r3, r4)
float highEnv   = math.max(r0, r1, r2, r3, r4)

// ─────────────────────────── Zones ───────────────────────────
h100 = hline(100, "Ceiling", color.new(color.gray, 100))
hOB  = hline(obLevel, "Overbought", color.new(color.gray, 55), hline.style_dotted)
hline(50, "Midline", color.new(color.gray, 75), hline.style_dotted)
hOS  = hline(osLevel, "Oversold", color.new(color.gray, 55), hline.style_dotted)
h0   = hline(0, "Floor", color.new(color.gray, 100))
fill(h100, hOB, color.new(bullCol, 94), "OB Zone")
fill(hOS, h0, color.new(bearCol, 94), "OS Zone")

// ─────────────────────────── 3D extrusion (drawn first, sits behind) ───────────────────────────
float wallBot = show3D ? lowEnv - wallDepth : na
color wallCol = darken(spectrum(midVal), 0.55)
pFloor = plot(lowEnv, "Ribbon Floor", display = display.none, editable = false)
pWall  = plot(wallBot, "Extrusion Floor", display = display.none, editable = false)
fill(pFloor, pWall, lowEnv, wallBot, color.new(wallCol, 30), color.new(wallCol, 100), "3D Extrusion")

// ─────────────────────────── Prism ribbon ───────────────────────────
p0 = plot(r0, "Fast Layer", color.new(spectrum(r0), 0), 2)
p1 = plot(r1, "Layer 2", display = display.none, editable = false)
p2 = plot(r2, "Layer 3", display = display.none, editable = false)
p3 = plot(r3, "Layer 4", display = display.none, editable = false)
p4 = plot(r4, "Slow Layer", color.new(spectrum(r4), 55), 1)

fill(p0, p1, color.new(spectrum((r0 + r1) / 2.0), 15 + faceDim), "Band 1")
fill(p1, p2, color.new(spectrum((r1 + r2) / 2.0), 30 + faceDim), "Band 2")
fill(p2, p3, color.new(spectrum((r2 + r3) / 2.0), 45 + faceDim), "Band 3")
fill(p3, p4, color.new(spectrum((r3 + r4) / 2.0), 60 + faceDim), "Band 4")

// ─────────────────────────── Glow + highlight ───────────────────────────
color leadCol = spectrum(r0)
plot(glow ? r0 : na, "Glow Outer", color.new(leadCol, 88), 8, display = display.pane, editable = false)
plot(glow ? r0 : na, "Glow Inner", color.new(leadCol, 70), 4, display = display.pane, editable = false)
plot(specular ? highEnv : na, "Top Highlight", color.new(color.white, 78), 1, display = display.pane, editable = false)

// ─────────────────────────── Signals ───────────────────────────
bool  xUp   = ta.crossover(r0, r4)
bool  xDn   = ta.crossunder(r0, r4)
float lowR  = ta.lowest(r0, exhaustLb)
float highR = ta.highest(r0, exhaustLb)

bool upOk  = xUp and (not halfFilter or r4 < 50)
bool dnOk  = xDn and (not halfFilter or r4 > 50)
bool upExh = upOk and lowR <= osLevel
bool dnExh = dnOk and highR >= obLevel

plotshape(upOk and not upExh ? r0 : na, "Bull Flip", shape.circle, location.absolute, bullCol, size = size.tiny)
plotshape(dnOk and not dnExh ? r0 : na, "Bear Flip", shape.circle, location.absolute, bearCol, size = size.tiny)
plotshape(upExh ? r0 : na, "Bull Exhaustion Flip", shape.diamond, location.absolute, bullCol, size = size.small)
plotshape(dnExh ? r0 : na, "Bear Exhaustion Flip", shape.diamond, location.absolute, bearCol, size = size.small)

barcolor(colorBars ? spectrum(midVal) : na)

// ─────────────────────────── Alerts ───────────────────────────
if upExh
    alert("Prism RSI [NeBlok]: BULL exhaustion flip on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)
else if upOk
    alert("Prism RSI [NeBlok]: bull flip on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if dnExh
    alert("Prism RSI [NeBlok]: BEAR exhaustion flip on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)
else if dnOk
    alert("Prism RSI [NeBlok]: bear flip on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

// ─────────────────────────── Dashboard ───────────────────────────
var table dash = table.new(position.top_right, 2, 6, bgcolor = color.new(#0B0F19, 15), border_color = color.new(color.gray, 75), border_width = 1)

if showDash and barstate.islast
    color txt = color.new(color.white, 15)
    string regime   = er >= 0.35 ? "Trending" : er <= 0.20 ? "Choppy" : "Mixed"
    color  regimeC  = er >= 0.35 ? bullCol : er <= 0.20 ? bearCol : midCol
    string zone     = r0 >= obLevel ? "Overbought" : r0 <= osLevel ? "Oversold" : "Neutral"
    color  zoneC    = r0 >= obLevel ? bullCol : r0 <= osLevel ? bearCol : txt
    table.cell(dash, 0, 0, "PRISM RSI", text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 0, "NeBlok", text_color = bullCol, text_size = size.small)
    table.cell(dash, 0, 1, "Engine", text_color = txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, engine == "Efficiency Ratio" ? "Efficiency" : "Cycle", text_color = txt, text_size = size.small)
    table.cell(dash, 0, 2, "Length", text_color = txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(baseLen, "#.0"), text_color = txt, text_size = size.small)
    table.cell(dash, 0, 3, "Regime", text_color = txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, regime, text_color = regimeC, text_size = size.small)
    table.cell(dash, 0, 4, "Momentum", text_color = txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, bullTwist ? "▲ Bull Twist" : "▼ Bear Twist", text_color = bullTwist ? bullCol : bearCol, text_size = size.small)
    table.cell(dash, 0, 5, "Zone", text_color = txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, zone, text_color = zoneC, text_size = size.small)
````
