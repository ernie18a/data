# Adaptive Fibonacci Compass [JOAT]

- url: https://www.tradingview.com/script/vwHvFJGG-Adaptive-Fibonacci-Compass-JOAT/
- type: indicator
- pine_id: PUB;9a56720408ec497aa55b6137b79543d6
- version: 1.0

## Description

[b]Adaptive Fibonacci Compass [JOAT][/b]

[b]Overview[/b]

Adaptive Fibonacci Compass is a dynamic, pivot-anchored Fibonacci retracement and extension system built in Pine Script v6. It continuously detects the most recent confirmed swing pivot pair, grades the pivot's ATR-normalised strength, checks for Break of Structure or Change of Character on the swing axis, then draws a live Fibonacci grid of seven standard levels (0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0) with fill-highlighted Optimal Trade Entry zones (OTE: 0.382–0.618 and 0.618–0.786) — all rendered at barstate.islast using the delete-before-create pattern for zero ghost-drawing artifacts.

[image]https://www.tradingview.com/x/6Pd099d4/[/image]

[b]Why Adaptive Fibonacci?[/b]

Static Fibonacci tools require manual anchor selection, which introduces subjectivity and results in different traders drawing the same move differently. Adaptive Fibonacci Compass removes this ambiguity by algorithmically detecting the pivot pair that defines the most recent significant swing and anchoring the grid there automatically. The grid updates whenever a new, stronger pivot forms — keeping the Fibonacci reference aligned with the current market structure without any manual intervention.

[b]Pivot Detection and ATR Strength Grading[/b]

Swing pivots are detected using ta.pivothigh() and ta.pivotlow() with configurable left and right bar confirmation windows (default 10/10). When a new pivot forms, its ATR-normalised strength is computed:

Strength = (pivotHigh - pivotLow) / ATR(14)

This ratio grades the swing on a universal scale independent of price level or instrument. Pivots grading above a configurable minimum strength (default 1.5 ATR) are accepted as valid Fibonacci anchors. Smaller price structures that do not meet the threshold are ignored, preventing the grid from anchoring to noise.

[b]BOS / CHoCH Detection on Pivot Axis[/b]

Each time a new pivot pair is accepted, the engine checks whether the new swing extreme exceeds the prior swing extreme of the same type:

- [b]BOS Up:[/b] New swing high exceeds the previous swing high — structural expansion to the upside
- [b]BOS Down:[/b] New swing low is below the previous swing low — structural expansion to the downside
- [b]CHoCH:[/b] A swing extreme that forms against the prevailing structure — e.g., a new swing high forming when prior context was bearish

BOS and CHoCH labels are stamped at the pivot level to provide structural context for interpreting the Fibonacci grid.

[b]Dynamic Fibonacci Grid (7 Levels)[/b]

The grid spans from the last confirmed swing low to the last confirmed swing high (for bullish pivots) or the reverse (for bearish pivots). Seven retracement levels are drawn as horizontal lines:

- 0.0 (swing origin) — white/neutral
- 0.236 — subtle grey
- 0.382 — teal (start of OTE zone)
- 0.5 — gold (midpoint)
- 0.618 — teal (end of deep OTE zone)
- 0.786 — purple
- 1.0 (swing extreme) — white/neutral

Each level label shows both the ratio and the exact price value.

[b]Optimal Trade Entry (OTE) Fill Zones[/b]

Two fill zones are highlighted as semi-transparent boxes between specific Fibonacci levels, representing the confluence areas where institutional entries are statistically most concentrated:

- [b]OTE 0.382–0.618:[/b] The standard OTE zone — the area of highest probability for pullback continuation trades
- [b]OTE 0.618–0.786:[/b] The deep OTE zone — commonly used for higher-conviction reversal entries where the move has retraced deeply into the prior swing

Both zones are rendered with directional colour (teal for bullish swings, red for bearish swings) at 80–85% transparency.

[b]Live Pivot Tracking and Grid Refresh[/b]

On every bar, the indicator tracks whether price is forming a new potential extreme beyond the current grid's anchor. When a new confirmed pivot qualifies (passes the ATR strength threshold), the previous grid is fully deleted (all lines, labels, and boxes) and rebuilt from the new anchor points. The delete-before-create pattern at barstate.islast ensures no duplicate or orphaned drawing objects accumulate over the session.

[b]Inputs Reference[/b]

- Pivot Left Bars (10) — left confirmation bars for swing detection
- Pivot Right Bars (10) — right confirmation bars for swing detection
- Min ATR Strength (1.5) — minimum swing size in ATR units to accept as a valid anchor
- Show Fib Grid — toggles the full Fibonacci grid
- Show OTE Zones — toggles the 0.382–0.618 and 0.618–0.786 fill zones
- Show BOS / CHoCH Labels — toggles structural labels on pivot extremes
- Show Level Labels — toggles price and ratio annotations on each Fibonacci line
- Extend Lines (bars, default 30) — how far right the grid lines extend from the current bar
- Theme: Dark, Light, Auto

[b]How to Use[/b]

1. Apply to any liquid market on any timeframe. The indicator needs at least (PivotLeft + PivotRight) * 3 bars to warm up.
2. The gold 0.5 level and teal 0.382/0.618 lines define the primary trade management area. In a confirmed uptrend, look for price to pull back into the OTE 0.382–0.618 zone with a bullish reaction for long entries.
3. The deep OTE 0.618–0.786 zone is valid for entries only in strong, high-momentum swings where the pullback is orderly and accompanied by decreasing volume.
4. Treat the 0.0 and 1.0 levels as structural extremes. A confirmed close beyond the 1.0 level triggers a new BOS and should cause the grid to reload on the next qualifying pivot.
5. Use BOS labels to confirm that the current Fibonacci swing direction aligns with the broader structural bias from a higher timeframe.

[b]Non-Repainting Design[/b]

Pivots are only detected once the full right-bar confirmation period has elapsed. The grid is always anchored to confirmed historical pivots. No drawing is created based on the current in-progress bar. All grid refreshes occur at barstate.islast using confirmed pivot data.

[b]Limitations[/b]

- The indicator anchors to the most recent qualifying pivot pair. In multi-week trends with no significant retracement, the grid may anchor to a very old pivot that is no longer contextually relevant.
- The minimum ATR strength filter helps but does not eliminate all noise pivots on highly volatile instruments. Increasing the threshold on crypto assets is recommended.
- Fibonacci levels are probabilistic reference zones, not guaranteed reversal or support/resistance levels. Confluence with other structure (OBs, PDH/PDL, volume profile POC) significantly increases their reliability.
- The grid does not account for higher-timeframe Fibonacci structures. Always check alignment with HTF pivots manually.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Fibonacci retracements are historical price relationships and do not predict future market behaviour with certainty. Always use proper risk management and conduct your own analysis.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Fibonacci Compass [JOAT]", shorttitle="AFC [JOAT]", overlay=true,
          max_lines_count=300, max_boxes_count=200, max_labels_count=100)

// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_P = "Pivot Settings"
var GRP_F = "Fibonacci Grid"
var GRP_S = "Structure"
var GRP_V = "Visual"

i_pvLeft    = input.int   (8,    "Pivot Left Bars",        group=GRP_P, minval=2)
i_pvRight   = input.int   (8,    "Pivot Right Bars",       group=GRP_P, minval=2)
i_atrStr    = input.float (1.5,  "Strong Pivot (ATR x)",   group=GRP_P, minval=0.5, step=0.25)
i_minSwing  = input.float (0.5,  "Min Swing (ATR x)",      group=GRP_P, minval=0.1, step=0.1)

i_showFib   = input.bool  (true, "Show Fibonacci Grid",    group=GRP_F)
i_showOTE   = input.bool  (true, "Show OTE Zones",         group=GRP_F)
i_showExt   = input.bool  (true, "Show Extension Levels",  group=GRP_F)
i_fibRight  = input.int   (50,   "Grid Extension (bars)",  group=GRP_F, minval=10, maxval=200)

i_showBOS   = input.bool  (true, "Show BOS / CHoCH",       group=GRP_S)
i_showHHLL  = input.bool  (true, "Show HH/HL/LH/LL",       group=GRP_S)
i_showLive  = input.bool  (true, "Show Live Pivot Extreme", group=GRP_S)

i_alertConf = input.bool  (true, "Confirmed-Bar Alerts",   group=GRP_V)
i_theme     = input.string("Auto","Theme",["Dark","Light","Auto"], group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL   = color.rgb(0, 245, 212)
C_BEAR   = color.rgb(255, 68, 102)
C_GOLD   = color.rgb(255, 215, 0)
C_OTE    = color.rgb(140, 100, 255)
C_EXT    = color.rgb(255, 160, 0)
C_KEY    = color.rgb(220, 220, 60)
C_SLATE  = color.rgb(96, 112, 128)
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT    = _isDark ? color.white : color.black

// ─── HELPERS ─────────────────────────────────────────────────────────
safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

// ─── FIB RATIOS ──────────────────────────────────────────────────────
var float[] FR  = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var float[] FEX = array.from(1.272, 1.618)   // extensions

// ─── PIVOT CALCULATION ───────────────────────────────────────────────
atr14 = ta.atr(14)
ph    = ta.pivothigh(high, i_pvLeft, i_pvRight)
pl    = ta.pivotlow (low,  i_pvLeft, i_pvRight)

WARMUP  = (i_pvLeft + i_pvRight) * 3
isReady = bar_index >= WARMUP

// Pivot strength
phSize  = not na(ph) ? ph - low [i_pvRight] : float(na)
plSize  = not na(pl) ? high[i_pvRight] - pl : float(na)
phStrong = not na(ph) and phSize > atr14 * i_atrStr and phSize > atr14 * i_minSwing
plStrong = not na(pl) and plSize > atr14 * i_atrStr and plSize > atr14 * i_minSwing

// ─── STRUCTURE TRACKING ──────────────────────────────────────────────
var float lastSH    = na
var float lastSL    = na
var int   shBar     = na
var int   slBar     = na
var float prevSH    = na
var float prevSL    = na
var int   structDir = 0
var bool  bosUpDone = false
var bool  bosDnDone = false

// Fib anchors
var float fibHigh   = na
var float fibLow    = na
var int   fibAncBar = na

if not na(ph) and isReady
    prevSH    := lastSH
    lastSH    := ph
    shBar     := bar_index - i_pvRight
    bosUpDone := false

if not na(pl) and isReady
    prevSL    := lastSL
    lastSL    := pl
    slBar     := bar_index - i_pvRight
    bosDnDone := false

// BOS detection
bosUp  = not bosUpDone and not na(lastSH) and close > lastSH and barstate.isconfirmed and isReady
bosDn  = not bosDnDone and not na(lastSL) and close < lastSL and barstate.isconfirmed and isReady
chochU = bosUp  and structDir == -1
chochD = bosDn  and structDir ==  1

if bosUp
    bosUpDone := true
    structDir := 1
    // Update fib anchors: from last low to last high
    if not na(lastSL) and not na(lastSH)
        fibHigh   := lastSH
        fibLow    := lastSL
        fibAncBar := shBar

if bosDn
    bosDnDone := true
    structDir := -1
    // Update fib anchors: from last high down to last low
    if not na(lastSH) and not na(lastSL)
        fibHigh   := lastSH
        fibLow    := lastSL
        fibAncBar := slBar

// HH/HL/LH/LL labels
if i_showHHLL and not na(ph) and not na(prevSH) and isReady
    txt = ph > prevSH ? "HH" : "LH"
    clr = ph > prevSH ? C_BULL : C_BEAR
    label.new(shBar, ph, txt, color=color.new(clr, 55), textcolor=color.white,
         style=label.style_label_down, size=size.tiny, xloc=xloc.bar_index)

if i_showHHLL and not na(pl) and not na(prevSL) and isReady
    txt = pl > prevSL ? "HL" : "LL"
    clr = pl > prevSL ? C_BULL : C_BEAR
    label.new(slBar, pl, txt, color=color.new(clr, 55), textcolor=color.white,
         style=label.style_label_up, size=size.tiny, xloc=xloc.bar_index)

// Pivot strength labels
if not na(ph) and phStrong and isReady
    label.new(shBar, ph, "S", color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_down, size=size.tiny, xloc=xloc.bar_index)

if not na(pl) and plStrong and isReady
    label.new(slBar, pl, "S", color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_up, size=size.tiny, xloc=xloc.bar_index)

// BOS / CHoCH lines and labels
if i_showBOS and bosUp and not chochU
    line.new(shBar, lastSH, bar_index, lastSH, color=color.new(C_BULL, 30), width=1)
    label.new(bar_index, lastSH, "BOS", color=color.new(C_BULL, 50),
         textcolor=color.white, style=label.style_label_down, size=size.tiny)

if i_showBOS and bosDn and not chochD
    line.new(slBar, lastSL, bar_index, lastSL, color=color.new(C_BEAR, 30), width=1)
    label.new(bar_index, lastSL, "BOS", color=color.new(C_BEAR, 50),
         textcolor=color.white, style=label.style_label_up, size=size.tiny)

if i_showBOS and chochU
    line.new(shBar, lastSH, bar_index, lastSH,
         color=color.new(C_GOLD, 20), width=2, style=line.style_dashed)
    label.new(bar_index, lastSH, "CHoCH", color=color.new(C_GOLD, 45),
         textcolor=color.black, style=label.style_label_down, size=size.tiny)

if i_showBOS and chochD
    line.new(slBar, lastSL, bar_index, lastSL,
         color=color.new(C_GOLD, 20), width=2, style=line.style_dashed)
    label.new(bar_index, lastSL, "CHoCH", color=color.new(C_GOLD, 45),
         textcolor=color.black, style=label.style_label_up, size=size.tiny)

// ─── LIVE PIVOT EXTREME ───────────────────────────────────────────────
var float liveExtreme = na
if structDir == 1
    liveExtreme := na(liveExtreme) ? high : math.max(liveExtreme, high)
    if bosUp
        liveExtreme := high
else if structDir == -1
    liveExtreme := na(liveExtreme) ? low : math.min(liveExtreme, low)
    if bosDn
        liveExtreme := low

// ─── ACTIVE LEVEL MANAGEMENT ─────────────────────────────────────────
var array<float> activeLevels = array.new<float>()
var array<line>  activeLines  = array.new<line>()

// Delete levels broken by close
if array.size(activeLevels) > 0
    for i = array.size(activeLevels) - 1 to 0
        lvl     = array.get(activeLevels, i)
        brokenU = close > lvl + atr14 * 0.2 and close[1] <= lvl
        brokenD = close < lvl - atr14 * 0.2 and close[1] >= lvl
        if brokenU or brokenD
            line.delete(array.get(activeLines, i))
            array.remove(activeLevels, i)
            array.remove(activeLines, i)
    // Extend remaining lines
    for i = 0 to array.size(activeLines) - 1
        line.set_x2(array.get(activeLines, i), bar_index + 1)

// ─── FIBONACCI GRID (delete-before-create at barstate.islast) ─────────
var array<line>  fibLines  = array.new<line>()
var array<box>   fibOTE    = array.new<box>()
var array<label> fibLabels = array.new<label>()

if barstate.islast and i_showFib and not na(fibHigh) and not na(fibLow)
    // Delete old fib objects
    for l  in fibLines
        line.delete(l)
    for b  in fibOTE
        box.delete(b)
    for lb in fibLabels
        label.delete(lb)
    fibLines.clear()
    fibOTE.clear()
    fibLabels.clear()

    ancLeft  = nz(fibAncBar, bar_index - 50)
    rightEdge = bar_index + i_fibRight
    rng      = fibHigh - fibLow
    isBullFib = structDir >= 0  // bull: draw from low up

    // Main fib levels
    for i = 0 to array.size(FR) - 1
        r    = array.get(FR, i)
        lvl  = isBullFib ? fibLow + r * rng : fibHigh - r * rng
        isKey = r == 0.5 or r == 0.618
        isOTE = r == 0.382 or r == 0.618 or r == 0.786
        lc   = r == 0.0 ? C_BULL : r == 1.0 ? C_BEAR : isKey ? C_KEY : C_SLATE
        lw   = isKey ? 2 : 1
        lst  = isKey ? line.style_solid : line.style_dotted
        ln   = line.new(ancLeft, lvl, rightEdge, lvl,
               color=color.new(lc, isKey ? 25 : 50), width=lw, style=lst)
        fibLines.push(ln)
        txt  = str.tostring(r * 100, "##.#") + "%"
        lb   = label.new(rightEdge + 1, lvl, txt,
               color=color.new(lc, 65), textcolor=C_TXT,
               style=label.style_label_left, size=size.tiny, xloc=xloc.bar_index)
        fibLabels.push(lb)

    // OTE zones: 0.382–0.618 and 0.618–0.786
    if i_showOTE
        ote1H = isBullFib ? fibLow + 0.618 * rng : fibHigh - 0.382 * rng
        ote1L = isBullFib ? fibLow + 0.382 * rng : fibHigh - 0.618 * rng
        ote2H = isBullFib ? fibLow + 0.786 * rng : fibHigh - 0.618 * rng
        ote2L = isBullFib ? fibLow + 0.618 * rng : fibHigh - 0.786 * rng
        b1 = box.new(ancLeft, ote1H, rightEdge, ote1L,
             bgcolor=color.new(C_OTE, 88), border_color=na)
        b2 = box.new(ancLeft, ote2H, rightEdge, ote2L,
             bgcolor=color.new(C_OTE, 82), border_color=na)
        fibOTE.push(b1)
        fibOTE.push(b2)

    // Extension levels
    if i_showExt
        for i = 0 to array.size(FEX) - 1
            r   = array.get(FEX, i)
            lvl = isBullFib ? fibLow + r * rng : fibHigh - r * rng
            ln  = line.new(ancLeft, lvl, rightEdge, lvl,
                  color=color.new(C_EXT, 30), width=1, style=line.style_dashed)
            fibLines.push(ln)
            lb  = label.new(rightEdge + 1, lvl, str.tostring(r * 100, "##.#") + "%",
                  color=color.new(C_EXT, 60), textcolor=C_TXT,
                  style=label.style_label_left, size=size.tiny, xloc=xloc.bar_index)
            fibLabels.push(lb)

    // Live extreme line
    if i_showLive and not na(liveExtreme)
        ln = line.new(bar_index - 20, liveExtreme, bar_index + 5, liveExtreme,
             color=color.new(C_GOLD, 20), width=1, style=line.style_dashed)
        fibLines.push(ln)

// ─── NEAR-FIB SIGNAL ─────────────────────────────────────────────────
fibNearBull = false
fibNearBear = false
if not na(fibHigh) and not na(fibLow)
    oteH = structDir >= 0 ? fibLow + 0.618 * (fibHigh - fibLow) : fibHigh - 0.382 * (fibHigh - fibLow)
    oteL = structDir >= 0 ? fibLow + 0.382 * (fibHigh - fibLow) : fibHigh - 0.618 * (fibHigh - fibLow)
    fibNearBull = close >= oteL and close <= oteH and structDir == 1  and barstate.isconfirmed
    fibNearBear = close >= oteL and close <= oteH and structDir == -1 and barstate.isconfirmed

plotshape(fibNearBull, "OTE Bull Zone", style=shape.diamond,
     location=location.belowbar, color=C_OTE, size=size.tiny)
plotshape(fibNearBear, "OTE Bear Zone", style=shape.diamond,
     location=location.abovebar, color=C_OTE, size=size.tiny)

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(i_alertConf ? (bosUp  and barstate.isconfirmed) : bosUp,
     "AFC Bull BOS [JOAT]", "Adaptive Fibonacci Compass: Bullish BOS — fibs recalibrated")
alertcondition(i_alertConf ? (bosDn  and barstate.isconfirmed) : bosDn,
     "AFC Bear BOS [JOAT]", "Adaptive Fibonacci Compass: Bearish BOS — fibs recalibrated")
alertcondition(fibNearBull, "AFC OTE Bull Zone [JOAT]", "AFC: Price in bullish OTE zone")
alertcondition(fibNearBear, "AFC OTE Bear Zone [JOAT]", "AFC: Price in bearish OTE zone")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if barstate.islast
    dirStr  = structDir == 1 ? "BULLISH" : structDir == -1 ? "BEARISH" : "NEUTRAL"
    dirClr  = structDir == 1 ? C_BULL    : structDir == -1 ? C_BEAR    : C_SLATE
    fibRng  = not na(fibHigh) and not na(fibLow) ? fibHigh - fibLow : float(na)
    oteH    = not na(fibHigh) and not na(fibLow) ? (structDir >= 0 ? fibLow + 0.618 * fibRng : fibHigh - 0.382 * fibRng) : float(na)
    oteL    = not na(fibHigh) and not na(fibLow) ? (structDir >= 0 ? fibLow + 0.382 * fibRng : fibHigh - 0.618 * fibRng) : float(na)
    inOTE   = not na(oteH) and not na(oteL) and close >= oteL and close <= oteH

    table.cell(dash, 0, 0, "AFC [JOAT]", bgcolor=color.new(C_OTE, 35),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "JackOfAllTrades", bgcolor=color.new(C_OTE, 35),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "Structure", text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 1, dirStr,      text_color=dirClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 2, "Fib High",  text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 2, na(fibHigh) ? "N/A" : str.tostring(math.round(fibHigh, 4)),
         text_color=C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 3, "Fib Low",   text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 3, na(fibLow)  ? "N/A" : str.tostring(math.round(fibLow, 4)),
         text_color=C_BULL, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 4, "OTE High",  text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 4, na(oteH) ? "N/A" : str.tostring(math.round(oteH, 4)),
         text_color=C_OTE,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 5, "OTE Low",   text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 5, na(oteL) ? "N/A" : str.tostring(math.round(oteL, 4)),
         text_color=C_OTE,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 6, "In OTE",    text_color=C_TXT,  text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 6, inOTE ? "YES" : "NO",
         text_color=inOTE ? C_GOLD : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
````
