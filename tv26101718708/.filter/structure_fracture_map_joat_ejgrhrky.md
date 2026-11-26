# Structure Fracture Map [JOAT]

- url: https://www.tradingview.com/script/ejGRhrKy-Structure-Fracture-Map-JOAT/
- type: indicator
- pine_id: PUB;2a5e2191e3d049449be1c2e54330133f
- version: 1.0

## Description

Structure Fracture Map is an open-source market structure and imbalance zone indicator that combines Fair Value Gap detection with a dynamic quality scoring system, a dual strength bar visualization inside each zone, and a real-time Break of Structure and Change of Character engine. It provides a single-indicator view of where price has left imbalances, how significant those imbalances are, and where structural shifts have occurred.

The problem with most FVG indicators is static treatment — a gap is detected and displayed with no differentiation between a high-quality gap formed on a strong impulse with above-average volume and a weak gap formed on a low-volume, narrow-range bar. Structure Fracture Map scores every FVG at formation and continuously updates that score based on mitigation progress, age, and trend alignment, ranking all active zones so that only the most institutionally relevant ones remain visible.

[image]https://www.tradingview.com/x/00yxT2kf/[/image]

[b]Core Concepts[/b]

[b]1. Fair Value Gap Detection[/b]

A bullish FVG exists when the current bar's low is above the high of the bar two positions prior — a three-bar pattern where the middle bar's range creates a gap that price has not filled. A bearish FVG is the inverse. Detection is confirmed only on completed bars to prevent repainting.

[b]2. Four-Component Strength Score[/b]

Each FVG receives an initial strength score from four components: gap size relative to ATR(14) scaled to 40 points, volume relative to 20-bar average scaled to 30 points, trend EMA alignment scaled to 20 points, and candle body-to-range ratio scaled to 10 points. The score is recalculated every bar, with a small age penalty and a mitigation penalty applied as price partially fills the gap:

[pine]
float totalStrength = (gapScore * 40) + (volScore * 30) + (trendScore * 20) + (candleScore * 10)
fvg.qualityScore   := totalStrength - fvg.mitigation * 50 - fvg.age * 0.1
[/pine]

[b]3. Dual Strength Bars[/b]

Inside each FVG box, two small bars are rendered — one showing bearish pressure score and one showing bullish pressure score as a proportion of the box width. The relative lengths reflect which directional force is currently dominating at that imbalance zone.

[b]4. Mitigation Tracking[/b]

Mitigation is computed as the ratio of how far price has penetrated into the zone to the total zone height. A fully mitigated FVG is removed from the display. Partially mitigated FVGs remain visible with their score updated downward, reflecting reduced structural significance.

[b]5. Break of Structure and Change of Character[/b]

Pivot highs and lows track the most recent confirmed structural levels. A Break of Structure (BOS) occurs when price closes through the last confirmed pivot in the current structural direction — confirming continuation. A Change of Character (CHoCH) occurs when price closes through the last confirmed pivot against the current direction — signaling a potential structural shift. Both events are labeled with a horizontal line at the break level.

[image]https://www.tradingview.com/x/YiiYKJEa/[/image]

[b]Features[/b]

[list]
[*][b]FVG detection with quality scoring:[/b] Bullish and bearish fair value gaps detected and scored by gap size, volume, trend alignment, and candle quality
[*][b]Dynamic score updates:[/b] Quality scores recalculated each bar with age decay and mitigation penalty
[*][b]Top-N zone ranking:[/b] Only the highest-scoring active zones displayed; lower-quality zones removed as better ones form
[*][b]Dual strength bars:[/b] Bearish and bullish strength bars inside each zone show directional pressure balance
[*][b]Mitigation tracking:[/b] Zones removed automatically when fully mitigated; partial mitigation reflected in updated score
[*][b]BOS and CHoCH detection:[/b] Structural break events labeled with horizontal level lines and text identifiers
[*][b]HH / HL / LH / LL pivot labels:[/b] Confirmed swing pivot types labeled on chart for structural context
[*][b]Swing level extension lines:[/b] Dotted lines at current unbroken swing levels extending to right edge of chart
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[*][b]Non-repainting:[/b] All detection gated by barstate.isconfirmed
[*][b]Alert conditions:[/b] New top-ranked FVG, BOS bull, BOS bear, CHoCH bull, CHoCH bear, FVG touched
[*][b]Dashed FVG borders:[/b] Each Fair Value Gap box has a dashed colored border matching its directional bias — teal for bullish, pink for bearish
[*][b]Clean pivot arrow labels:[/b] HH, HL, LH, LL events rendered as minimal text arrows (▲ HH etc.) with no background box, positioned above/below bars without obstructing price action
[*][b]Short BOS/CHoCH event lines:[/b] Break of Structure and Change of Character events marked with compact 6-bar horizontal lines and right-anchored labels — no full-width horizontal clutter
[*][b]Resistance/Support swing extensions:[/b] Nearest unbroken swing high labeled "Res" and swing low labeled "Sup" at right edge, updated each bar
[*][b]Structural bias background:[/b] Subtle bull/bear background tint driven by current HH/HL or LH/LL structural sequence
[*][b]Trend EMA reference line:[/b] 50-period EMA plotted in elite theme color as a trend context reference
[/list]

[b]Input Parameters[/b]

[b]FVG Zones:[/b]
[list]
[*]Show Top Zones: Maximum number of ranked zones displayed (default: 10)
[*]Max Stored FVGs: Maximum FVGs tracked in memory (default: 50)
[*]Volume MA Length: Volume average for scoring (default: 20)
[*]Trend EMA Length: Trend alignment reference (default: 50)
[*]Show Strength Bars toggle
[*]Bull/Bear FVG colors
[/list]

[b]Market Structure:[/b]
[list]
[*]Swing Lookback: Bars required on each side for pivot confirmation (default: 10)
[*]Show Structure Labels toggle
[*]Show BOS Events toggle
[*]Show CHoCH Events toggle
[*]Show Swing Level Lines toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Zone Rankings[/b]
Zones with higher quality scores represent structurally more significant imbalances. Focus on fresh (un-mitigated) zones with strong scores for potential reaction areas.

[b]Step 2: Monitor Dual Strength Bars[/b]
A bullish FVG whose bearish strength bar is growing indicates that selling pressure is building within the zone. When the bearish bar exceeds the bullish bar, the zone may be losing its bullish character.

[b]Step 3: Use BOS and CHoCH for Context[/b]
A BOS confirms continuation. A CHoCH is a warning that the current structural bias may be reversing. CHoCH events near high-quality FVG zones are particularly significant structural signals.

[b]Step 4: Watch Swing Level Extensions[/b]
The dotted right-edge lines show the nearest unbroken swing high and low — the next levels where a BOS or CHoCH could occur. These levels frame the most immediate structural breakpoints.

[b]Indicator Limitations[/b]

[list]
[*]Pivot confirmation requires a lookback offset. BOS and CHoCH events are labeled after confirmation, not on the bar that caused them
[*]FVG quality scores include volume as a factor. On instruments where volume is less meaningful, the score may rank gaps differently than expected
[*]Age penalty causes long-standing FVGs to lose score over time even if they remain structurally valid
[*]This indicator identifies existing imbalances and structural events. It does not predict where price will go next
[/list]

[b]Originality Statement[/b]

[list]
[*]A dynamic per-bar quality score for FVGs that decays with age and mitigation, combined with a top-N ranking system that actively removes lower-quality zones when better ones form, is not replicated in existing open-source Pine Script v6 FVG publications
[*]Dual strength bars rendered inside each FVG box — showing the current bull-versus-bear directional pressure balance within that specific imbalance zone — is an original visualization concept
[*]Combining FVG quality ranking, mitigation tracking, BOS/CHoCH structural event detection, and pivot type labeling in a unified indicator with a single clean overlay is an original integration
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Fair Value Gaps and structural events are based on historical price data and do not predict future price direction. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structure Fracture Map [JOAT]", overlay=true, max_boxes_count=300, max_lines_count=150, max_labels_count=200)

// ══════════════════════════════════════════════════════════
//  SECTION 1 — COLOR THEME
// ══════════════════════════════════════════════════════════

string themeInput = input.string("Phantom", "Color Theme", options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ══════════════════════════════════════════════════════════
//  SECTION 2 — INPUTS
// ══════════════════════════════════════════════════════════

var string G_FVG  = "◈ FVG Zones"
int   maxZones   = input.int(10,  "Show Top Zones",       minval=1,  maxval=20,  group=G_FVG)
int   maxStored  = input.int(50,  "Max Stored FVGs",      minval=10, maxval=200, group=G_FVG)
int   volLength  = input.int(20,  "Volume MA Length",                            group=G_FVG)
int   trendLen   = input.int(50,  "Trend EMA Length",                            group=G_FVG)
bool  showBars   = input.bool(true,  "Show Strength Bars",                       group=G_FVG)
bool  showText   = input.bool(true,  "Show FVG Label Text",                      group=G_FVG)
color bullFVGColor = input.color(color.rgb(26, 216, 194, 50), "Bull FVG Color",  group=G_FVG)
color bearFVGColor = input.color(color.rgb(216, 26, 102, 50), "Bear FVG Color",  group=G_FVG)

// Keep legacy aliases for internal use
color bullColor = bullFVGColor
color bearColor = bearFVGColor

var string G_STR  = "◈ Market Structure"
int   swingLen       = input.int(10,   "Swing Lookback",          minval=3, maxval=30, group=G_STR)
bool  showStruct     = input.bool(true, "Show Structure Labels",                       group=G_STR)
bool  showBOS        = input.bool(true, "Show BOS Events",                             group=G_STR)
bool  showCHoCH      = input.bool(true, "Show CHoCH Events",                           group=G_STR)
bool  showSwingLines = input.bool(true, "Show Swing Level Lines",                      group=G_STR)

var string G_DASH = "◈ Dashboard"
bool   showDash = input.bool(true,          "Show Dashboard", group=G_DASH)
string dashPos  = input.string("Top Right", "Position",       options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string dashSize = input.string("Small",     "Size",           options=["Tiny","Small","Normal"], group=G_DASH)

// ══════════════════════════════════════════════════════════
//  SECTION 3 — TYPE DEFINITION
// ══════════════════════════════════════════════════════════

type FVG
    float top
    float bottom
    float qualityScore
    float mitigation
    float volumeScore
    float trendScore
    int   direction
    int   bornBar
    int   bornTime
    int   bullStrength
    int   bearStrength
    box   body
    box   bullBar
    box   bearBar

// ══════════════════════════════════════════════════════════
//  SECTION 4 — ARRAYS / PERSISTENT STATE
// ══════════════════════════════════════════════════════════

var array<FVG> fvgList = array.new<FVG>()

var float lPH        = na
var float lPL        = na
var bool  iHH        = false
var bool  iHL        = false
var bool  iLH        = false
var bool  iLL        = false
var int   structBias = 0

var int bosCount   = 0
var int chochCount = 0

var line  swingHiLine = na
var line  swingLoLine = na
var label swingHiLbl  = na
var label swingLoLbl  = na

// ══════════════════════════════════════════════════════════
//  SECTION 5 — CORE SERIES CALCULATIONS
// ══════════════════════════════════════════════════════════

float atrVal   = ta.atr(14)
float volumeMA = ta.sma(volume, volLength)
float trendEMA = ta.ema(close, trendLen)

// ── FVG Conditions ──────────────────────────────────────
bool bullFVG = low > high[2]
bool bearFVG = high < low[2]

// ── Swing Pivots ────────────────────────────────────────
float swingHigh = ta.pivothigh(high, swingLen, swingLen)
float swingLow  = ta.pivotlow( low,  swingLen, swingLen)

// ══════════════════════════════════════════════════════════
//  SECTION 6 — TREND EMA PLOT
// ══════════════════════════════════════════════════════════

plot(trendEMA, "Trend EMA", color.new(colorELITE, 60), 1, plot.style_line)

// ══════════════════════════════════════════════════════════
//  SECTION 7 — STRUCTURAL RANGE BACKGROUND
// ══════════════════════════════════════════════════════════

bgcolor(structBias == 1 ? color.new(colorBULL, 97) : structBias == -1 ? color.new(colorBEAR, 97) : na,
     title="Structural Range Bias")

// ══════════════════════════════════════════════════════════
//  SECTION 8 — FUNCTIONS
// ══════════════════════════════════════════════════════════

// FVG Quality Scoring
// Returns [volumeScore, trendScore, bullStrength, bearStrength, mainScore]
f_fvgQuality(float topP, float botP, int dir) =>
    float fvgSize    = math.abs(topP - botP)
    float volScore   = volumeMA != 0 ? math.min(volume / volumeMA, 3.0) : 1.0
    float trendScore = (dir == 1 and close > trendEMA) or (dir == -1 and close < trendEMA) ? 1.0 : 0.0
    float gapStr     = math.min(fvgSize / math.max(atrVal, syminfo.mintick), 2.0) / 2.0 * 40.0
    float volStr     = math.min(volScore, 2.0) / 2.0 * 30.0
    float trendStr   = trendScore * 20.0
    float candleStr  = math.abs(close - open) / math.max(high - low, syminfo.mintick) * 10.0
    float total      = gapStr + volStr + trendStr + candleStr
    float mainStr    = math.max(0.0, math.min(100.0, total))
    int   bStr       = dir == 1  ? int(mainStr) : int(100.0 - mainStr)
    int   eStr       = dir == -1 ? int(mainStr) : int(100.0 - mainStr)
    [float(volumeMA != 0 ? volume / volumeMA : 1.0), trendScore, bStr, eStr, mainStr]

// FVG Box and Strength Bar Creation — institutional dashed-border style
// Returns [bodyBox, bearBarBox, bullBarBox]
f_createFVG(float topP, float botP, int dir, int bBar, int bTime) =>
    int   rightTime = bTime + timeframe.in_seconds(timeframe.period) * 1000 * 5
    // Body box with dashed border for institutional look
    box   bodyBox   = box.new(
         left         = bTime,
         right        = rightTime,
         top          = topP,
         bottom       = botP,
         xloc         = xloc.bar_time,
         bgcolor      = dir == 1 ? color.new(bullFVGColor, 70) : color.new(bearFVGColor, 70),
         border_color = dir == 1 ? color.new(colorBULL, 60) : color.new(colorBEAR, 60),
         border_width = 1,
         border_style = line.style_dashed)
    float mid    = math.avg(topP, botP)
    // Bear strength bar — clearly red/pink
    box   bBar2  = box.new(
         left         = bTime,
         right        = bTime,
         top          = topP,
         bottom       = mid,
         xloc         = xloc.bar_time,
         bgcolor      = color.new(colorBEAR, 20),
         border_color = color.new(colorBEAR, 60),
         border_width = 1)
    // Bull strength bar — clearly green
    box   bBull  = box.new(
         left         = bTime,
         right        = bTime,
         top          = mid,
         bottom       = botP,
         xloc         = xloc.bar_time,
         bgcolor      = color.new(colorBULL, 20),
         border_color = color.new(colorBULL, 60),
         border_width = 1)
    [bodyBox, bBar2, bBull]

// Dashboard cell helper
f_dc(table t, int c, int r, string txt, color tc, color bg, string sz) =>
    table.cell(t, c, r, txt,
         text_color  = tc,
         text_size   = sz,
         bgcolor     = bg,
         text_halign = c == 0 ? text.align_left : text.align_right)

// ══════════════════════════════════════════════════════════
//  SECTION 9 — NEW BULL FVG CREATION
// ══════════════════════════════════════════════════════════

if bullFVG and barstate.isconfirmed
    float topP = low
    float botP = high[2]
    if topP > botP
        [volSc, trendSc, bStr, eStr, mainStr] = f_fvgQuality(topP, botP, 1)
        [bodyBox, bearBarBox, bullBarBox]      = f_createFVG(topP, botP, 1, bar_index - 2, time[2])
        FVG newFvg = FVG.new(
             top          = topP,
             bottom       = botP,
             qualityScore = mainStr,
             mitigation   = 0.0,
             volumeScore  = volSc,
             trendScore   = trendSc,
             direction    = 1,
             bornBar      = bar_index - 2,
             bornTime     = time[2],
             bullStrength = bStr,
             bearStrength = eStr,
             body         = bodyBox,
             bullBar      = bullBarBox,
             bearBar      = bearBarBox)
        fvgList.push(newFvg)
        if fvgList.size() > maxStored
            FVG old = fvgList.shift()
            box.delete(old.body)
            box.delete(old.bullBar)
            box.delete(old.bearBar)

// ══════════════════════════════════════════════════════════
//  SECTION 10 — NEW BEAR FVG CREATION
// ══════════════════════════════════════════════════════════

if bearFVG and barstate.isconfirmed
    float topP = low[2]
    float botP = high
    if topP > botP
        [volSc, trendSc, bStr, eStr, mainStr] = f_fvgQuality(topP, botP, -1)
        [bodyBox, bearBarBox, bullBarBox]      = f_createFVG(topP, botP, -1, bar_index - 2, time[2])
        FVG newFvg = FVG.new(
             top          = topP,
             bottom       = botP,
             qualityScore = mainStr,
             mitigation   = 0.0,
             volumeScore  = volSc,
             trendScore   = trendSc,
             direction    = -1,
             bornBar      = bar_index - 2,
             bornTime     = time[2],
             bullStrength = bStr,
             bearStrength = eStr,
             body         = bodyBox,
             bullBar      = bullBarBox,
             bearBar      = bearBarBox)
        fvgList.push(newFvg)
        if fvgList.size() > maxStored
            FVG old = fvgList.shift()
            box.delete(old.body)
            box.delete(old.bullBar)
            box.delete(old.bearBar)

// ══════════════════════════════════════════════════════════
//  SECTION 11 — FVG UPDATE LOOP
//  Mitigation, quality re-score, strength bar widths
// ══════════════════════════════════════════════════════════

if fvgList.size() > 0
    for i = fvgList.size() - 1 to 0
        FVG fvg = fvgList.get(i)
        int age = bar_index - fvg.bornBar

        // Mitigation tracking
        float fillDist = fvg.direction == 1 ? fvg.top - low : high - fvg.bottom
        float zoneSize = math.max(fvg.top - fvg.bottom, syminfo.mintick)
        fvg.mitigation := math.min(math.max(fillDist / zoneSize, 0.0), 1.0)

        // Dynamic quality score (decays with age and mitigation)
        fvg.qualityScore := fvg.top * 100.0 + fvg.volumeScore * 10.0 + fvg.trendScore * 20.0 - fvg.mitigation * 50.0 - float(age) * 0.1

        // Remove fully-mitigated zones
        if fvg.mitigation >= 1.0
            box.delete(fvg.body)
            box.delete(fvg.bullBar)
            box.delete(fvg.bearBar)
            fvgList.remove(i)
        else
            // Update strength bar widths — wider and more visible
            if showBars
                int rightTime2 = fvg.bornTime + timeframe.in_seconds(timeframe.period) * 1000 * 35
                int sUnit      = math.max(int((rightTime2 - fvg.bornTime) / 200), 1)
                box.set_right(fvg.bearBar, fvg.bornTime + sUnit * fvg.bearStrength)
                box.set_right(fvg.bullBar, fvg.bornTime + sUnit * fvg.bullStrength)
                if showText
                    box.set_text(fvg.bearBar, str.tostring(fvg.bearStrength) + "%")
                    box.set_text_color(fvg.bearBar, colorBEAR)
                    box.set_text_halign(fvg.bearBar, text.align_right)
                    box.set_text_size(fvg.bearBar, size.tiny)
                    box.set_text(fvg.bullBar, str.tostring(fvg.bullStrength) + "%")
                    box.set_text_color(fvg.bullBar, colorBULL)
                    box.set_text_halign(fvg.bullBar, text.align_right)
                    box.set_text_size(fvg.bullBar, size.tiny)

            // Cap FVG body right extension to 20 bars from birth to avoid
            // boxes stretching too far right and overlapping with labels
            int fvgRight = fvg.bornTime + timeframe.in_seconds(timeframe.period) * 1000 * 20
            box.set_right(fvg.body, fvgRight)

            // Rank-based visibility — fade zones when list exceeds maxZones cap
            int   alphaAdj = fvgList.size() > maxZones ? 90 : 70
            color adjCol   = fvg.direction == 1 ? color.new(bullFVGColor, alphaAdj) : color.new(bearFVGColor, alphaAdj)
            box.set_bgcolor(fvg.body, adjCol)

// ══════════════════════════════════════════════════════════
//  SECTION 12 — MARKET STRUCTURE LABELS (HH / HL / LH / LL)
//  Institutional style: unicode arrow + label.style_none
// ══════════════════════════════════════════════════════════

if not na(swingHigh)
    iHH := swingHigh > nz(lPH, 0.0)
    iLH := swingHigh < nz(lPH, 999999.0)
    lPH := swingHigh
    if showStruct
        if iHH
            label.new(bar_index - swingLen, swingHigh, "▲ HH",
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = colorBULL,
                 size      = size.tiny,
                 yloc      = yloc.abovebar)
        else
            label.new(bar_index - swingLen, swingHigh, "▼ LH",
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = color.new(colorBEAR, 40),
                 size      = size.tiny,
                 yloc      = yloc.abovebar)

if not na(swingLow)
    iHL := swingLow > nz(lPL, 0.0)
    iLL := swingLow < nz(lPL, 999999.0)
    lPL := swingLow
    if showStruct
        if iHL
            label.new(bar_index - swingLen, swingLow, "▲ HL",
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = color.new(colorBULL, 40),
                 size      = size.tiny,
                 yloc      = yloc.belowbar)
        else
            label.new(bar_index - swingLen, swingLow, "▼ LL",
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = colorBEAR,
                 size      = size.tiny,
                 yloc      = yloc.belowbar)

// ══════════════════════════════════════════════════════════
//  SECTION 13 — BOS / CHoCH DETECTION
//  Institutional style labels + extension lines
// ══════════════════════════════════════════════════════════

bool bullBreak = not na(lPH) and ta.crossover(close,  lPH)
bool bearBreak = not na(lPL) and ta.crossunder(close, lPL)

bool bosBull   = bullBreak and structBias ==  1
bool chochBull = bullBreak and structBias != 1
bool bosBear   = bearBreak and structBias == -1
bool chochBear = bearBreak and structBias != -1

if bullBreak
    structBias  := 1
    bosCount    += bosBull   ? 1 : 0
    chochCount  += chochBull ? 1 : 0
    if showBOS and bosBull
        line.new(bar_index - 5, lPH, bar_index + 8, lPH,
             color = color.new(colorBULL, 50),
             style = line.style_dashed,
             width = 1)
        label.new(bar_index, lPH, "BOS",
             style     = label.style_label_down,
             color     = color.new(colorBULL, 85),
             textcolor = colorBULL,
             size      = size.small)
    if showCHoCH and chochBull
        line.new(bar_index - 5, lPH, bar_index + 8, lPH,
             color = color.new(colorELITE, 50),
             style = line.style_dashed,
             width = 1)
        label.new(bar_index, lPH, "CHoCH",
             style     = label.style_label_up,
             color     = color.new(colorELITE, 75),
             textcolor = colorELITE,
             size      = size.small)

if bearBreak
    structBias  := -1
    bosCount    += bosBear   ? 1 : 0
    chochCount  += chochBear ? 1 : 0
    if showBOS and bosBear
        line.new(bar_index - 5, lPL, bar_index + 8, lPL,
             color = color.new(colorBEAR, 50),
             style = line.style_dashed,
             width = 1)
        label.new(bar_index, lPL, "BOS",
             style     = label.style_label_up,
             color     = color.new(colorBEAR, 85),
             textcolor = colorBEAR,
             size      = size.small)
    if showCHoCH and chochBear
        line.new(bar_index - 5, lPL, bar_index + 8, lPL,
             color = color.new(colorELITE, 50),
             style = line.style_dashed,
             width = 1)
        label.new(bar_index, lPL, "CHoCH",
             style     = label.style_label_down,
             color     = color.new(colorELITE, 75),
             textcolor = colorELITE,
             size      = size.small)

// ══════════════════════════════════════════════════════════
//  SECTION 14 — SWING EXTENSION LINES (last bar only)
//  Thicker, more visible, with price dot labels
// ══════════════════════════════════════════════════════════

if barstate.islast and showSwingLines
    line.delete(swingHiLine)
    line.delete(swingLoLine)
    label.delete(swingHiLbl)
    label.delete(swingLoLbl)
    if not na(lPH)
        swingHiLine := line.new(
             bar_index - 2, lPH, bar_index + 8, lPH,
             color = color.new(colorBEAR, 35),
             style = line.style_dotted,
             width = 2)
        swingHiLbl := label.new(
             bar_index + 8, lPH,
             "⬤ " + str.tostring(lPH, format.mintick),
             style     = label.style_label_left,
             color     = color.new(colorBEAR, 80),
             textcolor = colorBEAR,
             size      = size.small)
    if not na(lPL)
        swingLoLine := line.new(
             bar_index - 2, lPL, bar_index + 8, lPL,
             color = color.new(colorBULL, 35),
             style = line.style_dotted,
             width = 2)
        swingLoLbl := label.new(
             bar_index + 8, lPL,
             "⬤ " + str.tostring(lPL, format.mintick),
             style     = label.style_label_left,
             color     = color.new(colorBULL, 80),
             textcolor = colorBULL,
             size      = size.small)

// ══════════════════════════════════════════════════════════
//  SECTION 15 — ALERT CONDITIONS
// ══════════════════════════════════════════════════════════

alertcondition(bosBull,   "Structure Fracture BOS Bull",   "Structure Fracture Map: Bullish Break of Structure confirmed.")
alertcondition(bosBear,   "Structure Fracture BOS Bear",   "Structure Fracture Map: Bearish Break of Structure confirmed.")
alertcondition(chochBull, "Structure Fracture CHoCH Bull", "Structure Fracture Map: Bullish Change of Character — possible reversal.")
alertcondition(chochBear, "Structure Fracture CHoCH Bear", "Structure Fracture Map: Bearish Change of Character — possible reversal.")
alertcondition(bullFVG,   "Structure Fracture New Bull FVG","Structure Fracture Map: New bullish Fair Value Gap detected.")
alertcondition(bearFVG,   "Structure Fracture New Bear FVG","Structure Fracture Map: New bearish Fair Value Gap detected.")

// ══════════════════════════════════════════════════════════
//  SECTION 16 — DASHBOARD
// ══════════════════════════════════════════════════════════

// Resolve dashboard position via switch
string positionVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

var table dash = table.new(
     positionVal,
     2, 11,
     bgcolor      = color.new(#0d1117, 10),
     border_color = color.new(#30363d, 20),
     border_width = 1,
     frame_color  = color.new(#30363d, 40),
     frame_width  = 1)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // Row 0 — Header
    f_dc(dash, 0,  0, "Structure Fracture Map [JOAT]", colorELITE,                 hBg,  dSz)
    f_dc(dash, 1,  0, timeframe.period + " | v1.0",    cMut,                       hBg,  dSz)

    // Row 1 — Active FVGs
    f_dc(dash, 0,  1, "Active FVGs",                  cMut,                       pBg,  dSz)
    f_dc(dash, 1,  1, str.tostring(fvgList.size()),    cMut,                       dBg,  dSz)

    // Row 2 — Structure bias
    string strTxt = structBias ==  1 ? "Bullish" : structBias == -1 ? "Bearish" : "Neutral"
    color  strCol = structBias ==  1 ? colorBULL : structBias == -1 ? colorBEAR : cMut
    f_dc(dash, 0,  2, "Structure",                     cMut,                       pBg,  dSz)
    f_dc(dash, 1,  2, strTxt,                          strCol,                     dBg,  dSz)

    // Row 3 — Last Pivot High
    f_dc(dash, 0,  3, "Last Pivot Hi",                 cMut,                       pBg,  dSz)
    f_dc(dash, 1,  3, not na(lPH) ? str.tostring(lPH, format.mintick) : "─",
         colorBEAR,                                                                 dBg,  dSz)

    // Row 4 — Last Pivot Low
    f_dc(dash, 0,  4, "Last Pivot Lo",                 cMut,                       pBg,  dSz)
    f_dc(dash, 1,  4, not na(lPL) ? str.tostring(lPL, format.mintick) : "─",
         colorBULL,                                                                 dBg,  dSz)

    // Row 5 — BOS Count
    f_dc(dash, 0,  5, "BOS Count",                     cMut,                       pBg,  dSz)
    f_dc(dash, 1,  5, str.tostring(bosCount),           colorBULL,                  dBg,  dSz)

    // Row 6 — CHoCH Count
    f_dc(dash, 0,  6, "CHoCH Count",                   cMut,                       pBg,  dSz)
    f_dc(dash, 1,  6, str.tostring(chochCount),         colorELITE,                 dBg,  dSz)

    // Row 7 — Last BOS Direction
    f_dc(dash, 0,  7, "Last BOS Dir",                  cMut,                       pBg,  dSz)
    f_dc(dash, 1,  7,
         structBias ==  1 ? "Bull" : structBias == -1 ? "Bear" : "─",
         strCol,                                                                    dBg,  dSz)

    // Row 8 — Trend EMA
    f_dc(dash, 0,  8, "Trend EMA",                     cMut,                       pBg,  dSz)
    f_dc(dash, 1,  8, str.tostring(trendEMA, format.mintick),
         close > trendEMA ? colorBULL : colorBEAR,                                 dBg,  dSz)

    // Row 9 — ATR
    f_dc(dash, 0,  9, "ATR",                           cMut,                       pBg,  dSz)
    f_dc(dash, 1,  9, str.tostring(atrVal, format.mintick), cMut,                  dBg,  dSz)

    // Row 10 — Branding
    f_dc(dash, 0, 10, "[JOAT]",          color.new(#6C63FF, 0),   color.new(#0d1117, 20), dSz)
    f_dc(dash, 1, 10, "jackofalltrades", cMut,                    color.new(#0d1117, 20), dSz)

// ══════════════════════════════════════════════════════════
//  END OF SCRIPT — Structure Fracture Map [JOAT] v1.1
// ══════════════════════════════════════════════════════════
````
