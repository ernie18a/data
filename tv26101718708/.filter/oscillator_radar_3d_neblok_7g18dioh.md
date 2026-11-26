# Oscillator Radar 3D [NeBlok]

- url: https://www.tradingview.com/script/7G18Dioh-Oscillator-Radar-3D-NeBlok/
- type: indicator
- pine_id: PUB;7e5560d8513441b88c7b604a5a0e87bc
- version: 1.0

## Description

OSCILLATOR RADAR 3D [NeBlok]

Eight different oscillators, one picture. This indicator normalizes eight oscillators to a common 0–100 scale and plots them as a radar (spider) chart to the right of your price action. A 3D engine tilts the radar and stacks past snapshots behind it, so you can see not only where momentum is now but how it got there.

──────────────────────────
WHY THESE EIGHT OSCILLATORS
──────────────────────────
Many multi-oscillator tools stack indicators that are nearly the same math, such as Stochastic %K and Williams %R, or RSI and CMO. When that happens, a "strong confluence" reading is often just one signal counted two or three times. This radar uses eight oscillators that each measure a different thing:

- RSI: momentum of closing prices (Wilder smoothing)
- STOCH: where price sits inside its recent high/low range (%K, 3-period smoothing)
- MFI: volume-weighted momentum (money flow)
- DMI: directional balance, meaning the +DI share of total directional movement
- AROON: trend timing, meaning how recently new highs were made compared with new lows
- CORR: trend quality, meaning how straight and steady price has moved over time (Pearson correlation vs. time)
- %B: volatility-adjusted position inside 2-standard-deviation Bollinger Bands (clamped 0–100)
- %UP: breadth of buying, meaning the percentage of up closes in the lookback window

All eight share one Length input (default 14) and can be smoothed with an optional EMA.

──────────────────────────
HOW TO READ THE RADAR
──────────────────────────
- Center = 0, outer edge = 100.
- Dashed ring = 50 (neutral).
- Dotted green ring = bull zone (default 70).
- Dotted red ring = bear zone (default 30).

The filled shape is the current reading of all eight oscillators, colored by the composite score:
- Green/teal: bullish (composite above 50)
- Purple: neutral (around 50)
- Red/pink: bearish (composite below 50)

What the shape tells you:
- A large, even shape pushed toward the outer ring means broad bullish agreement.
- A small shape pulled toward the center means broad bearish agreement.
- A lopsided or spiky shape means the oscillators disagree. That is often the most useful read, because it shows which kind of strength or weakness is missing. For example, strong RSI and STOCH with weak MFI means price is moving but volume isn't backing it.

Each axis label shows the oscillator's current value. An arrow (▲ / ▼) appears when that oscillator has risen or fallen since the previous history layer. Hover over any label for a short description of that oscillator.

──────────────────────────
THE 3D VIEW
──────────────────────────
With 3D enabled, the radar is tilted and rotated with perspective. Behind it are "history layers": snapshots of the radar from earlier bars (default: 5 layers, 4 bars apart). Older layers fade out and sit further back.

- The dashed spine running from the center is the time axis.
- Curved trails connect each oscillator through the history layers, so you can see whether that axis is expanding (gaining strength) or contracting (fading).
- If the layers expand as they come forward, momentum is building. If they shrink, momentum is fading.

Turn 3D off for a flat radar. The history layers then appear as faint outlines behind the current shape.

──────────────────────────
COMPOSITE GAUGE & SUMMARY
──────────────────────────
The vertical gradient bar on the right is the Composite Gauge, the average of all active oscillators (0–100). The ◀ marker shows the current composite value.

The summary label below the radar shows:
- Composite score and bias. BULLISH is 55 or above, BEARISH is 45 or below, and anything in between is NEUTRAL.
- Bull zone count: how many oscillators are at or above the bull level.
- Bear zone count: how many oscillators are at or below the bear level.

The Composite and both zone counts also appear in the Data Window, so you can read them on any historical bar.

──────────────────────────
SUGGESTED WAYS TO USE IT
──────────────────────────
1. Confirmation, not a trigger. Use the radar to check whether your setup has broad support across different kinds of signal before you act on your own entry criteria.
2. Look for divergence inside the radar. When price makes a new high but the shape shrinks, or one family such as MFI or CORR lags behind, the move may be losing support.
3. Watch the transitions. A composite cross of 50, or several oscillators entering a zone at once, often matters more than any single oscillator hitting an extreme.
4. Compare timeframes. Load the indicator on a higher and a lower timeframe to see whether the shapes agree.

──────────────────────────
SETTINGS OVERVIEW
──────────────────────────
Oscillators: Source, Length, Smoothing, and an on/off toggle for each oscillator (at least 3 must be on).
Levels & Alerts: Bull and bear zone levels, and the minimum number of oscillators needed for a confluence alert.
Layout: Vertical range lookback, radar height, radar width (in bars), gap from the last bar, and toggles for labels, gauge, and summary.
3D Engine: 3D on/off, tilt, rotation, camera distance (perspective strength), number of history layers, bars between layers, layer spacing, and axis trails.
Style: Bull, neutral, bear, and grid colors.

──────────────────────────
ALERTS
──────────────────────────
Create an alert and pick "Any alert() function call." It fires once per bar close when:
- The composite crosses above 50
- The composite crosses below 50
- The number of oscillators in the bull zone reaches the confluence count
- The number of oscillators in the bear zone reaches the confluence count

──────────────────────────
NOTES
──────────────────────────
- The radar is drawn in the empty space to the right of the last bar. If you don't see it, scroll right or increase the chart's right margin.
- The radar's proportions change as you zoom in and out. Adjust "Radar radius (bars)" and "Radar height" to fit your chart.
- MFI requires volume data. On symbols without volume it reads a flat 50.
- Values on the current, unfinished bar update in real time and can change until the bar closes. Alerts fire on bar close only.

──────────────────────────
DISCLAIMER
──────────────────────────
This script is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument. Oscillators describe past price and volume behavior and do not predict future results. Past performance is not indicative of future results. Trading involves substantial risk of loss and is not suitable for every investor. Always do your own research, test any tool thoroughly before relying on it, and consider consulting a licensed financial professional. The author accepts no liability for any losses resulting from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  Oscillator Radar 3D [NeBlok]
//  Original implementation — NeBlok Edge
//  Eight decorrelated oscillators, each normalized to 0–100, drawn as a radar
//  on the right side of the price chart. The 3D engine tilts the radar and
//  stacks past snapshots behind it so you can see HOW the shape got here.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Oscillator Radar 3D [NeBlok]", shorttitle = "OscRadar 3D [NeBlok]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100, max_bars_back = 500)

//════════════════════════════════════════════════════════════════════════════
// INPUTS
//════════════════════════════════════════════════════════════════════════════
const string G_OSC = "Oscillators"
const string G_LVL = "Levels & Alerts"
const string G_LAY = "Layout"
const string G_3D  = "3D Engine"
const string G_STY = "Style"

src       = input.source(close, "Source", group = G_OSC)
len       = input.int(14, "Length", minval = 2, group = G_OSC)
smoothN   = input.int(1, "Smoothing (EMA, 1 = off)", minval = 1, group = G_OSC)
useRSI    = input.bool(true, "RSI",         inline = "o1", group = G_OSC)
useSTO    = input.bool(true, "Stoch %K",    inline = "o1", group = G_OSC)
useMFI    = input.bool(true, "MFI",         inline = "o1", group = G_OSC)
useDMI    = input.bool(true, "DMI Balance", inline = "o1", group = G_OSC)
useARN    = input.bool(true, "Aroon",       inline = "o2", group = G_OSC)
useCOR    = input.bool(true, "Trend Corr",  inline = "o2", group = G_OSC)
usePB     = input.bool(true, "%B",          inline = "o2", group = G_OSC)
useUP     = input.bool(true, "% Up Bars",   inline = "o2", group = G_OSC)

obLvl     = input.float(70, "Bull zone ≥", minval = 50, maxval = 100, group = G_LVL)
osLvl     = input.float(30, "Bear zone ≤", minval = 0, maxval = 50, group = G_LVL)
confMin   = input.int(5, "Confluence count for alerts", minval = 1, maxval = 8, group = G_LVL,
     tooltip = "Alert fires when at least this many oscillators sit in the bull (or bear) zone.")

lookback  = input.int(100, "Vertical range lookback (bars)", minval = 10, maxval = 500, group = G_LAY)
sizePct   = input.float(85, "Radar height (% of range)", minval = 10, maxval = 200, group = G_LAY)
widthBars = input.int(45, "Radar radius (bars)", minval = 10, maxval = 120, group = G_LAY)
offsetBars= input.int(20, "Gap from last bar", minval = 0, maxval = 150, group = G_LAY)
showLbl   = input.bool(true, "Axis labels", group = G_LAY)
showGauge = input.bool(true, "Composite gauge", group = G_LAY)
showInfo  = input.bool(true, "Summary label", group = G_LAY)

use3D     = input.bool(true, "Enable 3D", group = G_3D)
pitchDeg  = input.float(55, "Tilt (°)", minval = 0, maxval = 80, group = G_3D)
yawDeg    = input.float(12, "Rotation (°)", minval = -45, maxval = 45, group = G_3D)
camDist   = input.float(5.0, "Camera distance (lower = stronger perspective)", minval = 2.5, maxval = 50, step = 0.5, group = G_3D)
layers    = input.int(5, "History layers", minval = 0, maxval = 10, group = G_3D)
layerStep = input.int(4, "Bars between layers", minval = 1, maxval = 40, group = G_3D)
depth     = input.float(0.16, "Layer spacing", minval = 0.02, maxval = 0.5, step = 0.01, group = G_3D)
showTrail = input.bool(true, "Axis trails through time", group = G_3D)

bullCol   = input.color(#00E5A0, "Bull",    inline = "c", group = G_STY)
neutCol   = input.color(#8B7CFF, "Neutral", inline = "c", group = G_STY)
bearCol   = input.color(#FF3D71, "Bear",    inline = "c", group = G_STY)
gridCol   = input.color(#787B86, "Grid",    inline = "c", group = G_STY)

//════════════════════════════════════════════════════════════════════════════
// OSCILLATORS (raw)
//════════════════════════════════════════════════════════════════════════════
rsiRaw = ta.rsi(src, len)
stoRaw = ta.sma(ta.stoch(src, high, low, len), 3)
mfiRaw = ta.mfi(hlc3, len)

[diP, diM, adxV] = ta.dmi(len, len)
dmiRaw = diP + diM > 0 ? 100.0 * diP / (diP + diM) : 50.0

arnUp  = 100.0 * (ta.highestbars(high, len + 1) + len) / len
arnDn  = 100.0 * (ta.lowestbars(low, len + 1) + len) / len
arnRaw = (arnUp - arnDn + 100.0) / 2.0

corRaw = (ta.correlation(src, bar_index, len) + 1.0) * 50.0

bbMid  = ta.sma(src, len)
bbDev  = 2.0 * ta.stdev(src, len)
pbRaw  = bbDev > 0 ? (src - (bbMid - bbDev)) / (2.0 * bbDev) * 100.0 : 50.0

upRaw  = 100.0 * math.sum(src > src[1] ? 1 : 0, len) / len

//════════════════════════════════════════════════════════════════════════════
// NORMALIZATION (0–100, na-safe, optional smoothing)
//════════════════════════════════════════════════════════════════════════════
f_clamp(float v) => math.max(0.0, math.min(100.0, nz(v, 50.0)))
f_norm(float v)  => ta.ema(f_clamp(v), smoothN)

nRSI = f_norm(rsiRaw)
nSTO = f_norm(stoRaw)
nMFI = f_norm(mfiRaw)
nDMI = f_norm(dmiRaw)
nARN = f_norm(arnRaw)
nCOR = f_norm(corRaw)
nPB  = f_norm(pbRaw)
nUP  = f_norm(upRaw)

//════════════════════════════════════════════════════════════════════════════
// REGISTRY
//════════════════════════════════════════════════════════════════════════════
var array<string> NAMES = array.from("RSI", "STOCH", "MFI", "DMI", "AROON", "CORR", "%B", "%UP")
var array<string> TIPS  = array.from(
     "RSI — momentum of closes (Wilder smoothing)",
     "Stochastic %K (3 SMA) — where price sits inside its recent high/low range",
     "Money Flow Index — volume-weighted momentum (reads 50 on symbols with no volume)",
     "DMI Balance — +DI share of total directional movement",
     "Aroon Oscillator — how recently highs were made vs lows",
     "Trend Correlation — how straight/steady the trend is (Pearson vs time)",
     "Bollinger %B — position inside 2σ bands, clamped 0–100",
     "% Up Bars — share of up closes in the window")
var array<bool> ON  = array.from(useRSI, useSTO, useMFI, useDMI, useARN, useCOR, usePB, useUP)
var array<int>  ACT = array.new<int>()

if barstate.isfirst
    for i = 0 to 7
        if ON.get(i)
            ACT.push(i)
    if ACT.size() < 3
        runtime.error("Oscillator Radar 3D [NeBlok]: enable at least 3 oscillators.")

// value of oscillator i, k bars ago
f_val(int i, int k) =>
    float v = switch i
        0 => nRSI[k]
        1 => nSTO[k]
        2 => nMFI[k]
        3 => nDMI[k]
        4 => nARN[k]
        5 => nCOR[k]
        6 => nPB[k]
        => nUP[k]
    nz(v, 50.0)

// composite (average of active oscillators), k bars ago
f_comp(int k) =>
    float s = 0.0
    for i in ACT
        s += f_val(i, k)
    s / ACT.size()

//════════════════════════════════════════════════════════════════════════════
// COMPOSITE & CONFLUENCE (every bar, for alerts / data window)
//════════════════════════════════════════════════════════════════════════════
float composite = f_comp(0)
int bullN = 0
int bearN = 0
for i in ACT
    float v = f_val(i, 0)
    if v >= obLvl
        bullN += 1
    if v <= osLvl
        bearN += 1

//════════════════════════════════════════════════════════════════════════════
// COLOR + 3D PROJECTION
//════════════════════════════════════════════════════════════════════════════
f_grad(float v) =>
    v < 50 ? color.from_gradient(v, 0, 50, bearCol, neutCol) : color.from_gradient(v, 50, 100, neutCol, bullCol)

float pitchR = use3D ? math.toradians(pitchDeg) : 0.0
float yawR   = use3D ? math.toradians(yawDeg)   : 0.0

// unit-space (ux, uy, uz) → chart point. uz = depth into the screen (history).
f_proj(float ux, float uy, float uz, int cx, float cy, float rX, float rY) =>
    float y1 = uy * math.cos(pitchR) - uz * math.sin(pitchR)
    float z1 = uy * math.sin(pitchR) + uz * math.cos(pitchR)
    float x2 = ux * math.cos(yawR) + z1 * math.sin(yawR)
    float z2 = -ux * math.sin(yawR) + z1 * math.cos(yawR)
    float s  = use3D ? camDist / math.max(camDist + z2, 0.1) : 1.0
    chart.point.from_index(cx + math.round(x2 * s * rX), cy + y1 * s * rY)

// axis j of n at radius r (top = axis 0, clockwise)
f_unit(int j, int n, float r) =>
    float a = 2.0 * math.pi * j / n
    [r * math.sin(a), r * math.cos(a)]

f_ring(float r, float uz, int n, int cx, float cy, float rX, float rY) =>
    array<chart.point> pts = array.new<chart.point>()
    for j = 0 to n - 1
        [ux, uy] = f_unit(j, n, r)
        pts.push(f_proj(ux, uy, uz, cx, cy, rX, rY))
    pts

f_shape(int k, float uz, int n, int cx, float cy, float rX, float rY) =>
    array<chart.point> pts = array.new<chart.point>()
    for j = 0 to n - 1
        [ux, uy] = f_unit(j, n, f_val(ACT.get(j), k) / 100.0)
        pts.push(f_proj(ux, uy, uz, cx, cy, rX, rY))
    pts

//════════════════════════════════════════════════════════════════════════════
// RENDER (last bar only)
//════════════════════════════════════════════════════════════════════════════
float hiR = ta.highest(high, lookback)
float loR = ta.lowest(low, lookback)

var array<polyline> PL = array.new<polyline>()
var array<line>     LN = array.new<line>()
var array<label>    LB = array.new<label>()

if barstate.islast
    for pl in PL
        pl.delete()
    PL.clear()
    for ln in LN
        ln.delete()
    LN.clear()
    for lb in LB
        lb.delete()
    LB.clear()

    int   n      = ACT.size()
    float rY     = (hiR - loR) / 2.0 * sizePct / 100.0
    float rX     = widthBars
    int   cx     = bar_index + offsetBars + widthBars
    float cyBase = (hiR + loR) / 2.0
    float cy     = cyBase + (use3D ? 0.5 * layers * depth * math.sin(pitchR) * rY : 0.0)
    color cc     = f_grad(composite)

    // ── base plate + reference rings
    PL.push(polyline.new(f_ring(1.0, 0, n, cx, cy, rX, rY), closed = true,
         line_color = color.new(gridCol, 40), fill_color = color.new(gridCol, 93), line_width = 1))
    PL.push(polyline.new(f_ring(obLvl / 100.0, 0, n, cx, cy, rX, rY), closed = true,
         line_color = color.new(bullCol, 55), line_style = line.style_dotted))
    PL.push(polyline.new(f_ring(0.5, 0, n, cx, cy, rX, rY), closed = true,
         line_color = color.new(gridCol, 45), line_style = line.style_dashed))
    PL.push(polyline.new(f_ring(osLvl / 100.0, 0, n, cx, cy, rX, rY), closed = true,
         line_color = color.new(bearCol, 55), line_style = line.style_dotted))

    // ── spokes
    chart.point c0 = f_proj(0, 0, 0, cx, cy, rX, rY)
    for j = 0 to n - 1
        [ux, uy] = f_unit(j, n, 1.0)
        chart.point e = f_proj(ux, uy, 0, cx, cy, rX, rY)
        LN.push(line.new(c0.index, c0.price, e.index, e.price, color = color.new(gridCol, 60)))

    // ── depth spine (time axis)
    if use3D and layers > 0
        chart.point cz = f_proj(0, 0, layers * depth, cx, cy, rX, rY)
        LN.push(line.new(c0.index, c0.price, cz.index, cz.price, color = color.new(gridCol, 45), style = line.style_dashed))

    // ── history layers (oldest first so newest sits on top)
    if layers > 0
        for l = layers to 1
            int   k  = l * layerStep
            color lc = f_grad(f_comp(k))
            PL.push(polyline.new(f_shape(k, l * depth, n, cx, cy, rX, rY), closed = true,
                 line_color = color.new(lc, math.min(90, 35 + l * 10)),
                 fill_color = color.new(lc, math.min(96, 80 + l * 3))))

    // ── axis trails: each oscillator's path through the layers
    if use3D and showTrail and layers > 0
        for j = 0 to n - 1
            int oi = ACT.get(j)
            array<chart.point> tp = array.new<chart.point>()
            for l = layers to 0
                [ux, uy] = f_unit(j, n, f_val(oi, l * layerStep) / 100.0)
                tp.push(f_proj(ux, uy, l * depth, cx, cy, rX, rY))
            PL.push(polyline.new(tp, curved = true, closed = false,
                 line_color = color.new(f_grad(f_val(oi, 0)), 45), line_width = 1))

    // ── current shape
    PL.push(polyline.new(f_shape(0, 0, n, cx, cy, rX, rY), closed = true,
         line_color = cc, fill_color = color.new(cc, 72), line_width = 2))

    // ── vertices + axis labels (▲/▼ = change vs one layer ago)
    for j = 0 to n - 1
        int   oi = ACT.get(j)
        float v  = f_val(oi, 0)
        float dv = v - f_val(oi, layerStep)
        color vc = f_grad(v)
        [ux, uy] = f_unit(j, n, v / 100.0)
        chart.point p = f_proj(ux, uy, 0, cx, cy, rX, rY)
        LB.push(label.new(p.index, p.price, "", color = vc, style = label.style_circle, size = size.tiny))
        if showLbl
            [lx, ly] = f_unit(j, n, 1.2)
            chart.point q = f_proj(lx, ly, 0, cx, cy, rX, rY)
            string arrow = dv > 0.5 ? " ▲" : dv < -0.5 ? " ▼" : ""
            LB.push(label.new(q.index, q.price, NAMES.get(oi) + "\n" + str.tostring(v, "#") + arrow,
                 color = color(na), style = label.style_label_center, textcolor = vc,
                 size = size.small, tooltip = TIPS.get(oi)))

    // ── composite gauge
    if showGauge
        int   gx   = cx + math.round(rX * (showLbl ? 1.75 : 1.35))
        float gy0  = cyBase - rY
        float gy1  = cyBase + rY
        int   segs = 25
        for s = 0 to segs - 1
            float ya = gy0 + (gy1 - gy0) * s / segs
            float yb = gy0 + (gy1 - gy0) * (s + 1) / segs
            LN.push(line.new(gx, ya, gx, yb, color = color.new(f_grad(100.0 * (s + 0.5) / segs), 25), width = 4))
        float gm = gy0 + (gy1 - gy0) * composite / 100.0
        LB.push(label.new(gx, gm, "◀ " + str.tostring(composite, "#.0"), color = color(na),
             style = label.style_label_left, textcolor = cc, size = size.normal))
        LB.push(label.new(gx, gy1, "100", color = color(na), style = label.style_label_down, textcolor = gridCol, size = size.tiny))
        LB.push(label.new(gx, gy0, "0",   color = color(na), style = label.style_label_up,   textcolor = gridCol, size = size.tiny))

    // ── summary
    if showInfo
        string bias = composite >= 55 ? "BULLISH" : composite <= 45 ? "BEARISH" : "NEUTRAL"
        string txt  = "OSC RADAR 3D [NeBlok]\nComposite " + str.tostring(composite, "#.0") + "  ·  " + bias +
             "\nBull zone " + str.tostring(bullN) + "/" + str.tostring(n) +
             "  ·  Bear zone " + str.tostring(bearN) + "/" + str.tostring(n)
        LB.push(label.new(cx, cyBase - rY * 1.15, txt, color = color(na), style = label.style_label_center,
             textcolor = cc, size = size.small))

//════════════════════════════════════════════════════════════════════════════
// DATA WINDOW + ALERTS
//════════════════════════════════════════════════════════════════════════════
plot(composite, "Composite",       color = f_grad(composite), display = display.data_window)
plot(bullN,     "Bull-zone count", display = display.data_window)
plot(bearN,     "Bear-zone count", display = display.data_window)

if ta.crossover(composite, 50)
    alert("OscRadar [NeBlok] " + syminfo.ticker + ": composite crossed ABOVE 50 (" + str.tostring(composite, "#.0") + ")", alert.freq_once_per_bar_close)
if ta.crossunder(composite, 50)
    alert("OscRadar [NeBlok] " + syminfo.ticker + ": composite crossed BELOW 50 (" + str.tostring(composite, "#.0") + ")", alert.freq_once_per_bar_close)
if bullN >= confMin and bullN[1] < confMin
    alert("OscRadar [NeBlok] " + syminfo.ticker + ": bull confluence " + str.tostring(bullN) + " oscillators ≥ " + str.tostring(obLvl), alert.freq_once_per_bar_close)
if bearN >= confMin and bearN[1] < confMin
    alert("OscRadar [NeBlok] " + syminfo.ticker + ": bear confluence " + str.tostring(bearN) + " oscillators ≤ " + str.tostring(osLvl), alert.freq_once_per_bar_close)
````
