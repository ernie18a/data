# Shannon Entropy Terrain 3D [LliterH]

- url: https://www.tradingview.com/script/Wgvr8CP8/
- type: indicator
- pine_id: PUB;0e3642bd334f442989a1ccdff8142e89
- version: 1.0

## Description

[b]SHANNON ENTROPY TERRAIN 3D [LliterH][/b]
─────────────────────────────────────────────────────────────────────

Most market regime filters give you a single number. This indicator gives
you a landscape.

Shannon Entropy of price log-returns is computed simultaneously across
20 different lookback windows and rendered as a 3D thermal terrain surface.
Each layer of that surface answers the same question with a different time
horizon: is the market currently structured or random?

The result is a visual map that reveals what a flat oscillator cannot —
whether the order or chaos you see in one timeframe is isolated or systemic.


[b]THE MATHEMATICS[/b]
─────────────────────────────────────────────────────────────────────

Shannon Entropy quantifies the unpredictability of a system:

    [pine]H = -sum( p_i * log2(p_i) )[/pine]

Applied to the distribution of price log-returns ln(close/close[1]) over
a rolling window, H measures how randomly recent price behavior has been
distributed — independent of direction or magnitude.

This indicator normalizes H to a 0-100 scale using:

    [pine]H_norm = H / log2(N) * 100[/pine]

where N is the number of histogram bins. Result interpretation:

    0    Perfect order    One directional move dominates the window
    30   Order boundary   Market is structured, patterns are reliable
    50   Neutral plane    Mixed regime, no clear consensus
    70   Chaos boundary   Market begins to lose predictability
    100  Maximum chaos    Returns distributed uniformly at random


[b]READING THE TERRAIN[/b]
─────────────────────────────────────────────────────────────────────

The surface is colored by entropy VALUE at each point, not by depth.
This means color always communicates information — not decoration.

    Deep navy to cyan      Entropy 0-30     Order zone
    Cyan to warm yellow    Entropy 30-50    Transitioning toward order
    Yellow to orange       Entropy 50-70    Transitioning toward chaos
    Orange to crimson      Entropy 70-100   Chaos zone

Two floating wireframe rectangles mark the critical thresholds:

    Cyan frame at 30     The order boundary
    Red frame at 70      The chaos boundary

When the terrain surface breaches a frame, the market has crossed a
regime threshold across that lookback range.

The left wall shows the entropy profile of the oldest bar in view.
The right wall shows the live entropy profile of the current bar.

The label at the right edge displays two readings:

    LOCAL    Short lookback layer — fast, reactive to recent bars
    MACRO    Long lookback layer  — slow, structural regime


[b]PRACTICAL READING GUIDE[/b]
─────────────────────────────────────────────────────────────────────

The most valuable insight this indicator provides is CONSENSUS.

SCENARIO 1 — All layers cold (terrain below neutral plane, blue-cyan)

    The market is ordered across every time horizon simultaneously.
    Short lookback and long lookback agree: structure is present.
    This is the highest-conviction environment for any systematic strategy.
    Trend-following entries have high reliability. Range plays are clean.
    Set-and-forget methodology works in this condition.

SCENARIO 2 — All layers hot (terrain above 70% frame, orange-red)

    The market is noisy across every time horizon simultaneously.
    No lookback window finds structure. Returns are near-random.
    Breakouts are likely false. Stop hunts increase in frequency.
    The correct response is to reduce position size or stand aside.
    This condition often precedes or follows major news events.

SCENARIO 3 — Front cold, back cold (local and macro both ordered)

    The strongest structural signal. The market has been trending
    long enough for even the longer lookback windows to confirm order.
    This is the ideal session condition for a London momentum setup.

SCENARIO 4 — Front hot, back cold (local chaos, macro structure)

    A brief disruption within a structurally ordered trend.
    The long-term framework is intact. The short-term is noisy.
    Wait for the front layers to cool before entering.
    The entry timing is off, but the directional bias may still be valid.

SCENARIO 5 — Front cold, back hot (local order, macro chaos)

    A short-term window of clarity within a chaotic structural backdrop.
    Trade with reduced size. The macro environment does not support
    clean follow-through. Tighter management required.

SCENARIO 6 — Terrain crossing the 70% frame in real time

    Watch the right wall and the label. When the LOCAL reading crosses
    above 70 during a trade, consider whether the entry signal was
    generated during the chaos or before it. If after — reassess.


[b]HOW THIS BENEFITS YOUR TRADING[/b]
─────────────────────────────────────────────────────────────────────

The fundamental problem in discretionary trading is not finding signals —
it is knowing which signals to trust on a given day.

A strategy with a 60% win rate in ordered markets may drop to 40% in
chaotic markets. The signal logic does not change. The market regime does.

This indicator addresses that problem directly by:

1. Showing regime quality BEFORE you look for an entry. If the terrain
   is red before your session opens, the day is compromised before it
   starts. You know this at 3:00 AM, not after two losing trades.

2. Showing whether the regime is LOCAL or SYSTEMIC. A brief spike in
   local entropy during an otherwise ordered session is different from
   full-spectrum chaos. The terrain makes this distinction visual and
   immediate.

3. Providing a historical map of the last 45 bars. You can see when
   the chaos started, whether it is intensifying or resolving, and how
   the current bar relates to the recent structural pattern.

4. Operating independently of direction. It does not tell you to buy
   or sell. It tells you whether the environment supports the signals
   your system generates. This separation is intentional and correct.


[b]PARAMETERS[/b]
─────────────────────────────────────────────────────────────────────

Terrain
  Time History (Width)      Bars displayed on X axis. Default 45.
  Entropy Layers (Depth)    Lookback windows on Y axis. Default 18.
  Min Lookback (Front)      Shortest window. Most reactive. Default 8.
  Max Lookback (Back)       Longest window. Most structural. Default 55.
  Histogram Bins            Entropy resolution. Default 10.
  Terrain Smoothing         EMA smoothing per layer. Default 4.

Camera
  Yaw                       Rotates the landscape left or right.
  Pitch                     Tilts the viewing angle up or down.
  Scale X, Y, Z             Stretch each axis independently.
  Offset X, Y               Reposition the terrain within the pane.

Style
  Wireframe                 Grid overlay on or off.
  Surface Fill              Filled terrain on or off.
  Side Walls                Left and right entropy profile panels.
  Threshold Contour Frames  30% and 70% floating reference frames.
  Thermal palette           All five color anchors are adjustable.


[b]METHODOLOGY[/b]
─────────────────────────────────────────────────────────────────────

Input signal: natural log returns ln(close/close[1]).
Log returns are scale-independent, symmetric, and stationary — the
mathematically correct input for entropy analysis of financial time series.

Histogram method: returns are binned into N equal-width intervals over
the lookback window. Probabilities are relative frequencies. This is a
direct implementation of Shannon's discrete entropy formula.

Normalization: H divided by log2(N), the theoretical maximum entropy for
N equiprobable bins. Output is always bounded in [0, 100].

Thermal color: each strip is colored by the mean entropy of its two
constituent rows, not by its position in the Y axis. Color always
encodes information value, not spatial location.

Rendering: all drawing is performed exclusively on the last bar.
The terrain matrix updates incrementally every bar for efficiency.


[b]WHAT MAKES THIS DIFFERENT[/b]
─────────────────────────────────────────────────────────────────────

Existing 3D terrain indicators color by depth (Y axis position).
That choice is arbitrary — the color tells you where you are in the
structure, not what the data says at that point.

This indicator colors by entropy value (Z axis). The thermal gradient
is a direct encoding of the measurement. You read regime from color
without consulting a separate legend.

The floating threshold frames at 30% and 70% are 3D reference planes
that the terrain can physically breach. This is not available in any
other published terrain indicator.

The side wall panels render the full entropy distribution across all
lookback layers at a single point in time, functioning as entropy
histograms projected in 3D space.

Shannon Entropy applied to multi-lookback terrain is, to the author's
knowledge, not represented in the published TradingView library.


[b]LIMITATIONS[/b]
─────────────────────────────────────────────────────────────────────

This indicator measures regime quality, not direction. It does not
generate buy or sell signals and should be used alongside a complete
entry methodology.

Histogram entropy with lookback windows below 8 bars approaches the
Nyquist sampling limit and produces unreliable readings. The minimum
lookback is constrained to 5 bars as a safeguard.

Performance: the indicator is computationally intensive for TradingView's
rendering engine. If responsiveness is slow, reduce Entropy Layers and
Time History. Recommended maximums: 20 layers, 55 bars width.

█ DISCLAIMER

This indicator is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Trading involves substantial risk of loss and is not suitable for every investor. Always conduct your own research and consult a qualified financial professional before making any trading decisions. The author is not responsible for any losses incurred from the use of this tool

─────────────────────────────────────────────────────────────────────
Published under Mozilla Public License 2.0
© LliterH
─────────────────────────────────────────────────────────────────────

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © LliterH
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║   SHANNON ENTROPY TERRAIN 3D  [LliterH]  v2.0                   ║
// ║   "Thermal Cartography"                                          ║
// ║                                                                  ║
// ║   Visualizes Shannon Entropy of log-returns across 20 lookback   ║
// ║   windows as a 3D thermal terrain — like satellite imagery of   ║
// ║   market order vs. chaos.                                        ║
// ║                                                                  ║
// ║   H = -Σ pᵢ·log₂(pᵢ)   normalized 0–100                        ║
// ║   0%  = ORDER  — structured, high-conviction market             ║
// ║   50% = MIXED  — neutral regime boundary (neutral plane)        ║
// ║   100% = CHAOS — random noise, fake-outs, avoid trading         ║
// ║                                                                  ║
// ║   Thermal coloring : cold (ORDER) → warm (CHAOS)                ║
// ║   Contour frames   : 30% (ORDER) and 70% (CHAOS) thresholds     ║
// ║   Side walls       : current and historical entropy profiles     ║
// ╚══════════════════════════════════════════════════════════════════╝

//@version=6
indicator("Shannon Entropy Terrain 3D [LliterH]",
          shorttitle          = "LliterH · Entropy Terrain 3D",
          overlay             = false,
          max_polylines_count = 100,
          max_lines_count     = 500,
          max_labels_count    = 500,
          calc_bars_count     = 1000)

// ─────────────────────────────────────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────────────────────────────────────
const string G_T = "Terrain"
const string G_C = "Camera"
const string G_S = "Style"

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
int   i_width   = input.int  (45, "Time History (Width)",     group=G_T, minval=10, maxval=60)
int   i_depth   = input.int  (20, "Entropy Layers (Depth)",   group=G_T, minval=5,  maxval=24,
                               tooltip="Each layer = different lookback window. Front = fast (local), Back = slow (structural).")
int   i_minLen  = input.int  (8,  "Min Lookback (Front)",     group=G_T, minval=5)
int   i_maxLen  = input.int  (55, "Max Lookback (Back)",      group=G_T, minval=10, maxval=200)
int   i_bins    = input.int  (8,  "Histogram Bins",           group=G_T, minval=4, maxval=16,
                               tooltip="Bins for entropy histogram. 6-10 recommended.")
int   i_smooth  = input.int  (3,  "Terrain Smoothing",        group=G_T, minval=1)

float i_yaw     = input.float(35, "Yaw (°)",          group=G_C, minval=-89, maxval=89)
float i_pitch   = input.float(40, "Pitch (°)",         group=G_C, minval=0,   maxval=89)
float i_sx      = input.float(4.0,"Scale X (Width)",   group=G_C, step=0.1)
float i_sy      = input.float(5.0,"Scale Y (Depth)",   group=G_C, step=0.1)
float i_sz      = input.float(3.5,"Scale Z (Height)",  group=G_C, step=0.1)
int   i_offX    = input.int  (0,  "Offset X",          group=G_C)
float i_offY    = input.float(0.0,"Offset Y",          group=G_C)

bool  i_wire    = input.bool (true,  "Wireframe",              group=G_S)
bool  i_fill    = input.bool (true,  "Surface Fill",           group=G_S)
bool  i_walls   = input.bool (true,  "Side Walls",             group=G_S,
                               tooltip="Vertical entropy profile panels on left (historical) and right (current) edges.")
bool  i_frames  = input.bool (true,  "Threshold Contour Frames",group=G_S,
                               tooltip="Floating rectangular frames at 30% (ORDER) and 70% (CHAOS) entropy levels.")
bool  i_mark    = input.bool (true,  "Current Profile Marker", group=G_S)

// Thermal palette anchors (color by entropy VALUE, not by depth)
color i_cOrder  = input.color(#023E8A, "ORDER color  (0%)",    group=G_S)
color i_cMidLo  = input.color(#00B4D8, "Order→Mixed (30%)",    group=G_S)
color i_cMid    = input.color(#E9C46A, "Mixed color  (50%)",   group=G_S)
color i_cMidHi  = input.color(#F4A261, "Mixed→Chaos (70%)",    group=G_S)
color i_cChaos  = input.color(#D62828, "CHAOS color  (100%)",  group=G_S)
color i_cPlane  = input.color(color.new(color.white, 88), "Neutral Plane (50%)", group=G_S)

// ─────────────────────────────────────────────────────────────────────────────
// THERMAL COLOR ENGINE
//
//   Maps entropy value (0-100) to a 4-stop thermal gradient:
//     0%  → i_cOrder  (deep navy)   ← perfect order
//     30% → i_cMidLo  (cyan)         ← order/mixed boundary
//     50% → i_cMid    (warm yellow)  ← neutral
//     70% → i_cMidHi  (orange)       ← mixed/chaos boundary
//     100%→ i_cChaos  (crimson)      ← maximum chaos
// ─────────────────────────────────────────────────────────────────────────────
f_thermal(float e) =>
    float t = math.max(0.0, math.min(100.0, e))
    color result =
         t <= 30.0 ? color.from_gradient(t,    0.0,  30.0, i_cOrder, i_cMidLo) :
         t <= 50.0 ? color.from_gradient(t,   30.0,  50.0, i_cMidLo, i_cMid)   :
         t <= 70.0 ? color.from_gradient(t,   50.0,  70.0, i_cMid,   i_cMidHi) :
                     color.from_gradient(t,   70.0, 100.0, i_cMidHi, i_cChaos)
    result

// ─────────────────────────────────────────────────────────────────────────────
// SHANNON ENTROPY ENGINE
//   H = -Σ p_i · log₂(p_i), computed over log-returns, normalized 0-100
// ─────────────────────────────────────────────────────────────────────────────
f_entropy(array<float> buf, int len, int numBins) =>
    float lo = array.get(buf, 0)
    float hi = array.get(buf, 0)
    for k = 1 to len - 1
        float v = array.get(buf, k)
        lo      := math.min(lo, v)
        hi      := math.max(hi, v)
    float rng = hi - lo
    float H   = 50.0
    if rng > 1e-10
        array<float> cnt = array.new_float(numBins, 0.0)
        for k = 0 to len - 1
            float v  = array.get(buf, k)
            int   bn = math.min(int(math.floor((v - lo) / rng * numBins)), numBins - 1)
            cnt.set(bn, cnt.get(bn) + 1.0)
        float tot  = float(len)
        float maxH = math.log(float(numBins)) / math.log(2.0)
        float acc  = 0.0
        for k = 0 to numBins - 1
            float p = cnt.get(k) / tot
            if p > 0.0
                acc += -p * (math.log(p) / math.log(2.0))
        H := maxH > 0.0 ? acc / maxH * 100.0 : 50.0
    H

// ─────────────────────────────────────────────────────────────────────────────
// 3D PROJECTION ENGINE  (original — yaw + pitch rotation)
// ─────────────────────────────────────────────────────────────────────────────
f_pt(float gx, float gy, float gz,
     float cY,  float sY,  float sP,  float cP,
     float sx,  float sy,  float sz,
     int   aX,  float aY) =>
    float rx = gx * cY - gy * sY
    float ry = gx * sY + gy * cY
    chart.point.from_index(aX + int(rx * sx), aY - (ry * sP * sy - gz * cP * sz))

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
var int[]         layerLens = array.new_int  (i_depth, 0)
var float[]       smoothEma = array.new_float(i_depth, na)
var float[]       lrBuf     = array.new_float(0)
var matrix<float> terrain   = matrix.new<float>(i_depth, i_width, 50.0)

if barstate.isfirst
    int   safeMin = math.min(i_minLen, i_maxLen - 1)  // guard: minLen must be < maxLen
    for i = 0 to i_depth - 1
        float frac = i_depth > 1 ? float(i) / (i_depth - 1) : 0.0
        layerLens.set(i, i_maxLen - int(math.round(frac * (i_maxLen - safeMin))))

// ─────────────────────────────────────────────────────────────────────────────
// PER-BAR UPDATE
// ─────────────────────────────────────────────────────────────────────────────
float logRet = (close > 0.0 and close[1] > 0.0) ? math.log(close / close[1]) : 0.0
array.unshift(lrBuf, logRet)
if array.size(lrBuf) > i_maxLen
    array.pop(lrBuf)

int colIdx = bar_index % i_width

for i = 0 to i_depth - 1
    int   L   = layerLens.get(i)
    float raw = array.size(lrBuf) >= L ? f_entropy(lrBuf, L, i_bins) : 50.0
    float prv = smoothEma.get(i)
    float alp = 2.0 / (i_smooth + 1)
    float val = na(prv) ? raw : prv + alp * (raw - prv)
    smoothEma.set(i, val)
    terrain.set(i, colIdx, val)

// ─────────────────────────────────────────────────────────────────────────────
// RENDER  (last bar only)
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast

    for p  in polyline.all
        p.delete()
    for ln in line.all
        ln.delete()
    for lb in label.all
        lb.delete()

    int   head = bar_index % i_width
    float cY   = math.cos(i_yaw   * math.pi / 180.0)
    float sY   = math.sin(i_yaw   * math.pi / 180.0)
    float sP   = math.sin(i_pitch * math.pi / 180.0)
    float cP   = math.cos(i_pitch * math.pi / 180.0)
    int   aX   = bar_index - int(i_width * i_sx * 0.55) + i_offX
    float aY   = 50.0 - i_offY

    // ── LAYER 1: Threshold contour frames ────────────────────────────────────
    // Floating rectangular wireframes at entropy 30% and 70% — like
    // "danger ceiling" and "opportunity floor" hovering over the terrain.
    // These make regime thresholds immediately readable.
    if i_frames
        // ORDER frame (entropy = 30, z = -20)
        array<chart.point> fr30 = array.new<chart.point>()
        fr30.push(f_pt(0,          0,         -20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr30.push(f_pt(i_width-1,  0,         -20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr30.push(f_pt(i_width-1,  i_depth-1, -20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr30.push(f_pt(0,          i_depth-1, -20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        polyline.new(fr30, closed=true, fill_color=color.new(i_cMidLo, 94),
                     line_color=color.new(i_cMidLo, 55), line_width=1)
        // Label on corner
        chart.point lp30 = f_pt(0, i_depth-1, -20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY)
        label.new(lp30.index, lp30.price, "30%", color=#00000000,
                  textcolor=color.new(i_cMidLo, 30), style=label.style_label_right, size=size.small)

        // CHAOS frame (entropy = 70, z = +20)
        array<chart.point> fr70 = array.new<chart.point>()
        fr70.push(f_pt(0,          0,         20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr70.push(f_pt(i_width-1,  0,         20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr70.push(f_pt(i_width-1,  i_depth-1, 20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        fr70.push(f_pt(0,          i_depth-1, 20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        polyline.new(fr70, closed=true, fill_color=color.new(i_cChaos, 94),
                     line_color=color.new(i_cChaos, 55), line_width=1)
        chart.point lp70 = f_pt(0, i_depth-1, 20.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY)
        label.new(lp70.index, lp70.price, "70%", color=#00000000,
                  textcolor=color.new(i_cChaos, 30), style=label.style_label_right, size=size.small)

    // ── LAYER 2: Neutral plane (entropy = 50) ─────────────────────────────
    array<chart.point> plane = array.new<chart.point>()
    plane.push(f_pt(0,          0,          0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
    plane.push(f_pt(i_width-1,  0,          0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
    plane.push(f_pt(i_width-1,  i_depth-1,  0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
    plane.push(f_pt(0,          i_depth-1,  0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
    polyline.new(plane, closed=true, fill_color=i_cPlane, line_color=color.new(color.gray, 75))

    // ── LAYER 3: Historical (left) side wall ─────────────────────────────
    // Shows the entropy profile of the oldest bar in the buffer as a
    // semi-transparent curtain — visual anchor for historical context.
    if i_walls
        int oldX = (head + 1) % i_width  // oldest column in the circular buffer
        array<chart.point> wallL = array.new<chart.point>()
        for y = 0 to i_depth - 1
            float z = terrain.get(y, oldX) - 50.0
            wallL.push(f_pt(0, y, z, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        for y = i_depth - 1 to 0
            wallL.push(f_pt(0, y, 0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        float avgL = 0.0
        for y = 0 to i_depth - 1
            avgL += terrain.get(y, oldX)
        avgL /= i_depth
        polyline.new(wallL, closed=true,
                     fill_color  = color.new(f_thermal(avgL), 75),
                     line_color  = color.new(f_thermal(avgL), 45),
                     line_width  = 1)

    // ── LAYER 4: Terrain surface strips (back → front, thermal coloring) ──
    // KEY DIFFERENTIATOR: color is determined by entropy VALUE (Z axis),
    // not by depth position (Y axis). Hot peaks = chaos, cold valleys = order.
    array<chart.point> strip = array.new<chart.point>()
    for y = 0 to i_depth - 2
        strip.clear()
        // Compute average entropy of this strip (rows y and y+1, all X)
        float sumE = 0.0
        for x = 0 to i_width - 1
            int hx = (head + 1 + x) % i_width
            sumE += (terrain.get(y, hx) + terrain.get(y+1, hx)) * 0.5
        float avgE = sumE / i_width

        // Build strip polygon (forward + return pass)
        for x = 0 to i_width - 1
            int hx = (head + 1 + x) % i_width
            strip.push(f_pt(x, y,   terrain.get(y,   hx) - 50.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        for x = i_width - 1 to 0
            int hx = (head + 1 + x) % i_width
            strip.push(f_pt(x, y+1, terrain.get(y+1, hx) - 50.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))

        color thermalC = f_thermal(avgE)
        polyline.new(strip, closed=true,
                     fill_color = i_fill ? color.new(thermalC, 18) : #00000000,
                     line_color = i_wire ? color.new(thermalC, 50) : #00000000)

    // ── LAYER 5: Column wireframe (thermal-colored) ───────────────────────
    if i_wire
        array<chart.point> col2 = array.new<chart.point>()
        for x = 0 to i_width - 1
            col2.clear()
            int hx = (head + 1 + x) % i_width
            // Average entropy of this column for thermal color
            float colSum = 0.0
            for y = 0 to i_depth - 1
                colSum += terrain.get(y, hx)
            float colAvg = colSum / i_depth
            for y = 0 to i_depth - 1
                col2.push(f_pt(x, y, terrain.get(y, hx) - 50.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
            polyline.new(col2, closed=false, line_color=color.new(f_thermal(colAvg), 68))

    // ── LAYER 6: Current (right) side wall ───────────────────────────────
    // Shows the LIVE entropy profile as a thermal-colored filled curtain.
    // The most important visual element for real-time reading.
    if i_walls
        array<chart.point> wallR = array.new<chart.point>()
        for y = 0 to i_depth - 1
            float z = terrain.get(y, head) - 50.0
            wallR.push(f_pt(i_width-1, y, z, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        for y = i_depth - 1 to 0
            wallR.push(f_pt(i_width-1, y, 0.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        float avgR = 0.0
        for y = 0 to i_depth - 1
            avgR += terrain.get(y, head)
        avgR /= i_depth
        polyline.new(wallR, closed=true,
                     fill_color  = color.new(f_thermal(avgR), 55),
                     line_color  = color.new(f_thermal(avgR), 20),
                     line_width  = 2)

    // ── LAYER 7: Current edge spine + regime labels ───────────────────────
    if i_mark
        // White spine along the live entropy profile
        array<chart.point> edge = array.new<chart.point>()
        for y = 0 to i_depth - 1
            edge.push(f_pt(i_width-1, y, terrain.get(y, head) - 50.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY))
        polyline.new(edge, closed=false, line_color=color.new(color.white, 15), line_width=2)

        // LOCAL: shortest lookback — fast, reactive
        float  liveE  = terrain.get(i_depth-1, head)
        // MACRO: longest lookback — structural, slow
        float  macroE = terrain.get(0, head)

        string lRegime = liveE  > 70.0 ? "CHAOS" : liveE  < 30.0 ? "ORDER" : "MIXED"
        string mRegime = macroE > 70.0 ? "CHAOS" : macroE < 30.0 ? "ORDER" : "MIXED"

        // Anchor points
        chart.point p1 = f_pt(i_width-1, i_depth-1, liveE - 50.0, cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY)
        chart.point p2 = f_pt(i_width-1, i_depth-1, 0.0,          cY, sY, sP, cP, i_sx, i_sy, i_sz, aX, aY)
        line.new(p2, p1, color=color.new(color.white, 40), width=1, style=line.style_dashed)

        // Label callout — positioned to the RIGHT of the terrain so it never
        // overlaps the surface. A horizontal dashed leader line connects the
        // terrain edge to the label, keeping the terrain fully visible.
        color bgColor = color.new(#1E1E2E, 8)

        string lblText = "LOCAL    " + lRegime + "    " + str.tostring(math.round(liveE,  1)) + "%"
                       + "\nMACRO  " + mRegime + "    " + str.tostring(math.round(macroE, 1)) + "%"

        // Label anchored well past the terrain's projected right edge (p1.index).
        // p1.index is the actual chart bar where the terrain's frontmost corner lands.
        // Adding 20 bars guarantees the label box starts after the terrain ends.
        int   calloutX = p1.index + 60
        float calloutY = p1.price
        line.new(x1    = p1.index,
                 y1    = p1.price,
                 x2    = calloutX,
                 y2    = calloutY,
                 color = color.new(color.white, 55),
                 width = 1,
                 style = line.style_dashed)

        label.new(calloutX, calloutY, lblText,
                  color     = bgColor,
                  textcolor = color.white,
                  style     = label.style_label_left,
                  size      = size.normal)
````
