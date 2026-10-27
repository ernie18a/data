# BTM - Order Blocks & Breaker Blocks Pro [Scored, Non-Repainting]

- url: https://www.tradingview.com/script/dmcfK37j-BTM-Order-Blocks-Breaker-Blocks-Pro-Scored-Non-Repainting/
- type: indicator
- pine_id: PUB;d8e69e3a5c3148b1868146ba50938d87
- version: 1.0

## Description

Order Blocks & Breaker Blocks Pro detects ICT-style order blocks only when they are backed by a confirmed break of market structure, scores each zone for quality, and automatically converts failed order blocks into breaker blocks.

WHY THIS INDICATOR IS DIFFERENT
Many order block tools box any large candle, which produces a lot of weak zones. This script requires a sequence of events before a zone is drawn: a confirmed swing, a break of that swing, and an origin candle the move can be traced back to. Each zone is then graded so you can filter for the strongest ones.

HOW IT WORKS
1. Market structure
Swing highs and lows are confirmed pivots, so they never repaint. When price closes beyond the last unbroken swing, the script marks a BOS (break of structure, trend continuation) or a CHoCH (change of character, possible reversal).

2. Order block detection
The move that caused the break is traced back to its origin. The last opposite-coloured candle at that origin is marked as the order block. You can choose between the last opposite candle (classic ICT definition) or the extreme candle of the move, and between the full wick range or the candle body only.

3. Quality score (0–4 stars)
Each order block earns one point for each of the following:
- Displacement – a strong candle (body of at least 1.2× ATR by default) in the move away from the zone
- Fair value gap – the move left a price imbalance
- Liquidity sweep – the zone took out the previous swing low or high
- Volume – the order block candle had above-average volume
Any of these can be made mandatory, and you can set a minimum score.

4. Breaker blocks
If price later closes through the far side of an order block, the zone has failed. Because every order block here was created by a break of structure that already took liquidity, its failure flips it into a breaker block with the opposite role:
- A failed bullish order block becomes a bearish breaker (resistance)
- A failed bearish order block becomes a bullish breaker (support)
A breaker is invalidated when price closes through its far side.

COLOUR KEY
- Green – Bullish order block (support)
- Red – Bearish order block (resistance)
- Blue – Bullish breaker (support)
- Orange – Bearish breaker (resistance)
- Dotted line – 50% level of the zone (consequent encroachment)
- Faded zone – already retested once

DASHBOARD
A colour-coded table shows the current structure direction, the nearest support and resistance zones with their price range and distance, and the number of active zones of each type. Position, size, theme and accent colour are all adjustable.

HOW TO USE IT
1. Check the structure direction on the dashboard.
2. In a bullish structure, look for price to return to green or blue zones. In a bearish structure, look to red or orange zones.
3. Wait for a reaction inside the zone, such as a rejection wick or a strong candle in your direction, rather than entering on the first touch.
4. A close through the far side of the zone invalidates the idea, which makes it a natural stop-loss reference.
5. The nearest opposing zone can serve as a target.

SUGGESTED SETTINGS
- Minimum quality score of 2 for cleaner charts
- "Remove OB after first retest" to show only untouched zones
- Higher swing length (15–20) for higher timeframes and swing trading, lower (5) for scalping

NON-REPAINTING
Swings are confirmed pivots, and by default the script only acts on closed candles, so zones do not appear and disappear on the live candle. Note that, because pivots need confirmation, structure breaks are recognised only after the swing is confirmed.

ALERTS
Alerts are available for new bullish and bearish order blocks, new breakers, retests of each zone type, and a combined "any event" alert.

DISCLAIMER
This indicator is a tool for identifying price zones based on market structure concepts. It does not predict future price movement and is not financial advice. Zones can and do fail. Always test it on historical data, use proper risk management, and make your own trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("BTM - Order Blocks & Breaker Blocks Pro", shorttitle = "BTM - OB/BB Pro", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════════════════
//  HOW IT WORKS
//  1. Swing highs/lows are confirmed pivots (no repainting).
//  2. When price CLOSES beyond the last unbroken swing (BOS / CHoCH), the leg
//     that caused the break is traced back to its origin. The last opposite-
//     colour candle at that origin is the order block (OB).
//  3. Each OB is scored 0–4: displacement, fair value gap, liquidity sweep,
//     volume. Filters can make any of these mandatory.
//  4. If price later closes through the far side of an OB, the OB has failed.
//     Because every OB here was born from a break of structure (it already
//     took liquidity), its failure flips it into a BREAKER BLOCK with the
//     opposite role (failed bullish OB -> bearish breaker, and vice versa).
//  5. A breaker is invalidated when price closes through its far side.
// ════════════════════════════════════════════════════════════════════════════

// ─── Inputs ────────────────────────────────────────────────────────────────
const string G1 = "Market structure"
int    swingLen   = input.int(10, "Swing length", minval = 2, maxval = 50, group = G1, tooltip = "Bars on each side that confirm a swing high/low. Higher = fewer, more significant order blocks. Swings are only used once confirmed, so nothing repaints.")
string breakBy    = input.string("Close", "Structure break needs", options = ["Close", "Wick"], group = G1, tooltip = "Close = a candle must close beyond the swing (stricter, fewer false order blocks).")
bool   confOnly   = input.bool(true, "Only act on closed candles", group = G1, tooltip = "Stops zones appearing and disappearing on the live, unfinished candle.")
bool   showStruct = input.bool(true, "Show BOS / CHoCH", group = G1)

const string G2 = "Order blocks"
string obPick    = input.string("Last opposite candle", "OB candle", options = ["Last opposite candle", "Extreme candle"], group = G2, tooltip = "Last opposite candle = the last down-close candle before a bullish move (ICT definition). Extreme candle = the candle that made the low/high of the leg.")
string zoneSrc   = input.string("Wick", "Zone range", options = ["Wick", "Body"], group = G2, tooltip = "Wick = full candle range, extended to the leg's extreme. Body = open/close only (tighter, more precise entries, more failures).")
int    lookback  = input.int(50, "Max bars to search back", minval = 5, maxval = 200, group = G2)
bool   freshOnly = input.bool(false, "Remove OB after first retest", group = G2, tooltip = "ICT treats an OB as strongest while unmitigated. Turn on to show only untouched OBs.")
bool   noOverlap = input.bool(true, "Skip OBs overlapping an active one", group = G2)

const string G3 = "Quality filters"
bool  reqDisp  = input.bool(true, "Require displacement", group = G3, inline = "d")
float dispMult = input.float(1.2, "× ATR body", minval = 0.3, step = 0.1, group = G3, inline = "d", tooltip = "At least one candle in the move away from the OB must have a body this many ATRs large.")
bool  reqFvg   = input.bool(false, "Require fair value gap in the move", group = G3)
bool  reqSweep = input.bool(false, "Require liquidity sweep at the OB", group = G3, tooltip = "The OB's extreme must take out the previous swing low (bullish) or swing high (bearish).")
bool  reqVol   = input.bool(false, "Require above-average volume", group = G3, inline = "v")
float volMult  = input.float(1.2, "× 20-bar avg", minval = 0.5, step = 0.1, group = G3, inline = "v")
int   minScore = input.int(0, "Minimum quality score", minval = 0, maxval = 4, group = G3, tooltip = "One point each for displacement, FVG, liquidity sweep and volume. Shown as stars on the zone. Symbols with no volume data can score at most 3.")
float maxH     = input.float(3.0, "Max zone height (× ATR)", minval = 0.5, step = 0.5, group = G3, tooltip = "Skips oversized zones that are useless for entries.")
int   atrLen   = input.int(14, "ATR length", minval = 1, group = G3)

const string G4 = "Breaker blocks"
bool   showBrk  = input.bool(true, "Show breaker blocks", group = G4)
string failBy   = input.string("Close", "OB fails / breaker invalid on", options = ["Close", "Wick"], group = G4, tooltip = "Close = a candle must close through the far side of the zone.")
bool   brkDisp  = input.bool(false, "Require displacement on the break", group = G4, tooltip = "The candle that breaks the OB must have a body of at least the displacement ATR multiple.")
bool   keepDead = input.bool(false, "Keep invalidated breakers (faded)", group = G4)

const string G5 = "Display"
bool  showBullOB = input.bool(true, "Bullish OB", group = G5, inline = "a")
color cBullOB    = input.color(color.new(#089981, 80), "", group = G5, inline = "a")
bool  showBearOB = input.bool(true, "Bearish OB", group = G5, inline = "a")
color cBearOB    = input.color(color.new(#f23645, 80), "", group = G5, inline = "a")
color cBullBB    = input.color(color.new(#2962ff, 80), "Bullish breaker", group = G5, inline = "b")
color cBearBB    = input.color(color.new(#ff9800, 80), "Bearish breaker", group = G5, inline = "b")
int   maxShow    = input.int(5, "Max zones per type", minval = 1, maxval = 50, group = G5)
int   extBars    = input.int(15, "Extend zones right (bars)", minval = 0, maxval = 500, group = G5)
bool  showCE     = input.bool(true, "Show 50% line (consequent encroachment)", group = G5)
bool  showText   = input.bool(true, "Show zone labels", group = G5)

const string G6 = "Dashboard"
bool   showDash  = input.bool(true, "Show dashboard", group = G6)
string dashPos   = input.string("Bottom Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G6)
string dashSize  = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G6)
string dashTheme = input.string("Dark", "Theme", options = ["Dark", "Light"], group = G6)
color  cAccent   = input.color(#2962ff, "Header / frame colour", group = G6)

// ─── Core series (calculated on every bar) ─────────────────────────────────
float atrV   = ta.atr(atrLen)
float volAvg = ta.sma(volume, 20)
float ph     = ta.pivothigh(high, swingLen, swingLen)
float pl     = ta.pivotlow(low, swingLen, swingLen)

// ─── Zone object ───────────────────────────────────────────────────────────
type Zone
    float top
    float bot
    int   left
    int   born
    bool  support   // true = acts as support (bullish OB / bullish breaker)
    bool  breaker
    int   score
    bool  tested
    box   bx
    line  ce

var array<Zone>  zones  = array.new<Zone>()
var array<float> pivHiP = array.new<float>()
var array<int>   pivHiB = array.new<int>()
var array<float> pivLoP = array.new<float>()
var array<int>   pivLoB = array.new<int>()

var float swHi     = na
var int   swHiBar  = na
var bool  swHiDone = true
var float swLo     = na
var int   swLoBar  = na
var bool  swLoDone = true
var int   trend    = 0

// ─── Helpers ───────────────────────────────────────────────────────────────
isVisible(Zone z) =>
    z.breaker ? showBrk : (z.support ? showBullOB : showBearOB)

baseColor(Zone z) =>
    z.breaker ? (z.support ? cBullBB : cBearBB) : (z.support ? cBullOB : cBearOB)

fillColor(Zone z) =>
    color c = baseColor(z)
    isVisible(z) ? (z.tested ? color.new(c, math.min(95.0, color.t(c) + 10)) : c) : color.new(c, 100)

edgeColor(Zone z) =>
    isVisible(z) ? color.new(baseColor(z), 40) : color.new(baseColor(z), 100)

zoneName(Zone z) =>
    string kind = z.breaker ? (z.support ? "Bull BB" : "Bear BB") : (z.support ? "Bull OB" : "Bear OB")
    kind + (z.score > 0 ? " " + str.repeat("★", z.score) : "")

zoneText(Zone z) =>
    showText and isVisible(z) ? zoneName(z) : ""

drawZone(Zone z) =>
    z.bx := box.new(z.left, z.top, bar_index + extBars, z.bot, border_color = edgeColor(z), bgcolor = fillColor(z), text = zoneText(z), text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right, text_valign = text.align_center)
    if showCE
        float mid = (z.top + z.bot) / 2
        z.ce := line.new(z.left, mid, bar_index + extBars, mid, color = edgeColor(z), style = line.style_dotted)
    z

restyle(Zone z) =>
    z.bx.set_bgcolor(fillColor(z))
    z.bx.set_border_color(edgeColor(z))
    z.bx.set_text(zoneText(z))
    if not na(z.ce)
        z.ce.set_color(edgeColor(z))
    z

killZone(Zone z, bool keep) =>
    if keep
        z.bx.set_right(bar_index)
        z.bx.set_bgcolor(color.new(baseColor(z), 94))
        z.bx.set_border_color(color.new(baseColor(z), 85))
        z.bx.set_text_color(color.new(chart.fg_color, 70))
        if not na(z.ce)
            z.ce.set_x2(bar_index)
    else
        z.bx.delete()
        if not na(z.ce)
            z.ce.delete()
    z

overlaps(float top, float bot, bool support) =>
    bool hit = false
    for z in zones
        if not z.breaker and z.support == support and top >= z.bot and bot <= z.top
            hit := true
            break
    hit

pruneZones(bool support, bool brk) =>
    int cnt = 0
    for z in zones
        if z.support == support and z.breaker == brk
            cnt += 1
    int excess = cnt - maxShow
    int i = 0
    while excess > 0 and i < zones.size()
        Zone z = zones.get(i)
        if z.support == support and z.breaker == brk
            killZone(z, false)
            zones.remove(i)
            excess -= 1
        else
            i += 1
    cnt

// ─── Event flags (for alerts) ──────────────────────────────────────────────
bool evNewBullOB = false
bool evNewBearOB = false
bool evNewBullBB = false
bool evNewBearBB = false
bool evTapBullOB = false
bool evTapBearOB = false
bool evTapBullBB = false
bool evTapBearBB = false

// ─── Main logic ────────────────────────────────────────────────────────────
bool go = not confOnly or barstate.isconfirmed

if go
    // 1) Register confirmed swings
    if not na(ph)
        swHi     := ph
        swHiBar  := bar_index - swingLen
        swHiDone := false
        pivHiP.push(ph)
        pivHiB.push(bar_index - swingLen)
        if pivHiP.size() > 10
            pivHiP.shift()
            pivHiB.shift()
    if not na(pl)
        swLo     := pl
        swLoBar  := bar_index - swingLen
        swLoDone := false
        pivLoP.push(pl)
        pivLoB.push(bar_index - swingLen)
        if pivLoP.size() > 10
            pivLoP.shift()
            pivLoB.shift()

    float upSrc = breakBy == "Close" ? close : high
    float dnSrc = breakBy == "Close" ? close : low

    // 2) Bullish break of structure -> bullish order block
    if not swHiDone and upSrc > swHi
        swHiDone := true
        bool choch = trend == -1
        trend := 1
        if showStruct
            line.new(swHiBar, swHi, bar_index, swHi, color = color.new(cBullOB, 0), style = line.style_dashed)
            label.new(math.round((swHiBar + bar_index) / 2), swHi, choch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(color.black, 100), textcolor = color.new(cBullOB, 0), size = size.tiny)

        // Trace the leg back to its origin (lowest low since the broken swing)
        int   n   = math.min(bar_index - swHiBar, lookback)
        int   ext = 1
        float mn  = low[1]
        for i = 1 to n
            if low[i] < mn
                mn  := low[i]
                ext := i

        int obi = ext
        if obPick == "Last opposite candle" and close[ext] >= open[ext]
            for j = ext + 1 to ext + 3
                if close[j] < open[j]
                    obi := j
                    break

        float zTop = zoneSrc == "Wick" ? high[obi] : math.max(open[obi], close[obi])
        float zBot = zoneSrc == "Wick" ? math.min(low[obi], mn) : math.min(open[obi], close[obi])

        bool disp   = false
        bool intact = true
        for k = 0 to obi - 1
            if math.abs(close[k] - open[k]) >= dispMult * atrV
                disp := true
            if close[k] < zBot
                intact := false

        bool fvg = false
        if obi >= 2
            for k = 0 to obi - 2
                if low[k] > high[k + 2]
                    fvg := true
                    break

        bool sweep = false
        if pivLoP.size() > 0
            for m = pivLoP.size() - 1 to 0
                if pivLoB.get(m) < bar_index - ext
                    sweep := mn < pivLoP.get(m)
                    break

        bool hasVol = not na(volume[obi]) and not na(volAvg[obi]) and volAvg[obi] > 0
        bool volOk  = hasVol and volume[obi] >= volMult * volAvg[obi]

        int  score = (disp ? 1 : 0) + (fvg ? 1 : 0) + (sweep ? 1 : 0) + (volOk ? 1 : 0)
        bool pass  = intact and (not reqDisp or disp) and (not reqFvg or fvg) and (not reqSweep or sweep) and (not reqVol or not hasVol or volOk) and score >= minScore and (zTop - zBot) <= maxH * atrV and (not noOverlap or not overlaps(zTop, zBot, true))

        if pass
            Zone z = Zone.new(top = zTop, bot = zBot, left = bar_index - obi, born = bar_index, support = true, breaker = false, score = score, tested = false)
            drawZone(z)
            zones.push(z)
            evNewBullOB := true

    // 3) Bearish break of structure -> bearish order block
    if not swLoDone and dnSrc < swLo
        swLoDone := true
        bool choch = trend == 1
        trend := -1
        if showStruct
            line.new(swLoBar, swLo, bar_index, swLo, color = color.new(cBearOB, 0), style = line.style_dashed)
            label.new(math.round((swLoBar + bar_index) / 2), swLo, choch ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(cBearOB, 0), size = size.tiny)

        int   n   = math.min(bar_index - swLoBar, lookback)
        int   ext = 1
        float mx  = high[1]
        for i = 1 to n
            if high[i] > mx
                mx  := high[i]
                ext := i

        int obi = ext
        if obPick == "Last opposite candle" and close[ext] <= open[ext]
            for j = ext + 1 to ext + 3
                if close[j] > open[j]
                    obi := j
                    break

        float zTop = zoneSrc == "Wick" ? math.max(high[obi], mx) : math.max(open[obi], close[obi])
        float zBot = zoneSrc == "Wick" ? low[obi] : math.min(open[obi], close[obi])

        bool disp   = false
        bool intact = true
        for k = 0 to obi - 1
            if math.abs(close[k] - open[k]) >= dispMult * atrV
                disp := true
            if close[k] > zTop
                intact := false

        bool fvg = false
        if obi >= 2
            for k = 0 to obi - 2
                if high[k] < low[k + 2]
                    fvg := true
                    break

        bool sweep = false
        if pivHiP.size() > 0
            for m = pivHiP.size() - 1 to 0
                if pivHiB.get(m) < bar_index - ext
                    sweep := mx > pivHiP.get(m)
                    break

        bool hasVol = not na(volume[obi]) and not na(volAvg[obi]) and volAvg[obi] > 0
        bool volOk  = hasVol and volume[obi] >= volMult * volAvg[obi]

        int  score = (disp ? 1 : 0) + (fvg ? 1 : 0) + (sweep ? 1 : 0) + (volOk ? 1 : 0)
        bool pass  = intact and (not reqDisp or disp) and (not reqFvg or fvg) and (not reqSweep or sweep) and (not reqVol or not hasVol or volOk) and score >= minScore and (zTop - zBot) <= maxH * atrV and (not noOverlap or not overlaps(zTop, zBot, false))

        if pass
            Zone z = Zone.new(top = zTop, bot = zBot, left = bar_index - obi, born = bar_index, support = false, breaker = false, score = score, tested = false)
            drawZone(z)
            zones.push(z)
            evNewBearOB := true

    // 4) Manage existing zones: retests, failures -> breakers, invalidation
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            Zone z = zones.get(i)
            if bar_index > z.born
                float hiSrc  = failBy == "Close" ? close : high
                float loSrc  = failBy == "Close" ? close : low
                bool  failed = z.support ? loSrc < z.bot : hiSrc > z.top
                bool  tapped = z.support ? (low <= z.top and low[1] > z.top) : (high >= z.bot and high[1] < z.bot)

                if failed
                    bool canFlip = not z.breaker and showBrk and (not brkDisp or math.abs(close - open) >= dispMult * atrV)
                    zones.remove(i)
                    if canFlip
                        z.breaker := true
                        z.support := not z.support
                        z.born    := bar_index
                        z.tested  := false
                        restyle(z)
                        z.bx.set_right(bar_index + extBars)
                        if not na(z.ce)
                            z.ce.set_x2(bar_index + extBars)
                        zones.push(z)
                        if z.support
                            evNewBullBB := true
                        else
                            evNewBearBB := true
                    else
                        killZone(z, z.breaker and keepDead)
                else
                    bool alive = true
                    if tapped
                        if z.support
                            if z.breaker
                                evTapBullBB := true
                            else
                                evTapBullOB := true
                        else
                            if z.breaker
                                evTapBearBB := true
                            else
                                evTapBearOB := true
                        if freshOnly and not z.breaker
                            killZone(z, false)
                            zones.remove(i)
                            alive := false
                        else if not z.tested
                            z.tested := true
                            restyle(z)
                    if alive
                        z.bx.set_right(bar_index + extBars)
                        if not na(z.ce)
                            z.ce.set_x2(bar_index + extBars)

    // 5) Keep the chart clean
    pruneZones(true, false)
    pruneZones(false, false)
    pruneZones(true, true)
    pruneZones(false, true)

// ─── Dashboard ─────────────────────────────────────────────────────────────
posOf(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

sizeOf(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

bool   dkTheme = dashTheme == "Dark"
color  tBg     = dkTheme ? #131722 : #f5f7fa
color  tLbl    = dkTheme ? #1e222d : #e3e8ef
color  tTxt    = dkTheme ? #d1d4dc : #131722
color  tMuted  = dkTheme ? #787b86 : #5d606b
string tSz     = sizeOf(dashSize)

var table dash = showDash ? table.new(posOf(dashPos), 2, 9, bgcolor = tBg, frame_color = cAccent, frame_width = 2, border_color = tBg, border_width = 2) : table(na)

if showDash and barstate.isfirst and not na(dash)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.merge_cells(dash, 0, 8, 1, 8)

dashRow(int r, string lbl, string val, color valBg, color valTxt) =>
    table.cell(dash, 0, r, "  " + lbl + "  ", bgcolor = tLbl, text_color = tTxt, text_size = tSz, text_halign = text.align_left)
    table.cell(dash, 1, r, "  " + val + "  ", bgcolor = valBg, text_color = valTxt, text_size = tSz, text_halign = text.align_center)

if showDash and barstate.islast and not na(dash)
    string supTxt  = "—"
    string resTxt  = "—"
    float  supD    = na
    float  resD    = na
    int    nBullOB = 0
    int    nBearOB = 0
    int    nBullBB = 0
    int    nBearBB = 0
    for z in zones
        if isVisible(z)
            if z.breaker
                if z.support
                    nBullBB += 1
                else
                    nBearBB += 1
            else
                if z.support
                    nBullOB += 1
                else
                    nBearOB += 1
            if z.support and z.bot <= close
                float d = math.max(0.0, (close - z.top) / close * 100)
                if na(supD) or d < supD
                    supD   := d
                    supTxt := zoneName(z) + "  " + str.tostring(z.bot, format.mintick) + " – " + str.tostring(z.top, format.mintick) + "  (" + str.tostring(d, "0.00") + "%)"
            if not z.support and z.top >= close
                float d = math.max(0.0, (z.bot - close) / close * 100)
                if na(resD) or d < resD
                    resD   := d
                    resTxt := zoneName(z) + "  " + str.tostring(z.bot, format.mintick) + " – " + str.tostring(z.top, format.mintick) + "  (" + str.tostring(d, "0.00") + "%)"

    color green  = color.new(cBullOB, 0)
    color red    = color.new(cBearOB, 0)
    color blue   = color.new(cBullBB, 0)
    color orange = color.new(cBearBB, 0)

    // Header
    table.cell(dash, 0, 0, "◆  ORDER BLOCKS & BREAKERS  ◆", bgcolor = cAccent, text_color = color.white, text_size = tSz, text_halign = text.align_center)

    // Trend
    string trTxt = trend == 1 ? "▲  BULLISH" : trend == -1 ? "▼  BEARISH" : "—  NEUTRAL"
    color  trBg  = trend == 1 ? green : trend == -1 ? red : tLbl
    dashRow(1, "Market structure", trTxt, trBg, trend == 0 ? tTxt : color.white)

    // Nearest zones
    dashRow(2, "Nearest support", supTxt, na(supD) ? tLbl : color.new(cBullOB, 25), na(supD) ? tMuted : color.white)
    dashRow(3, "Nearest resistance", resTxt, na(resD) ? tLbl : color.new(cBearOB, 25), na(resD) ? tMuted : color.white)

    // Zone counts
    dashRow(4, "Bullish order blocks", str.tostring(nBullOB), green, color.white)
    dashRow(5, "Bearish order blocks", str.tostring(nBearOB), red, color.white)
    dashRow(6, "Bullish breakers", str.tostring(nBullBB), blue, color.white)
    dashRow(7, "Bearish breakers", str.tostring(nBearBB), orange, color.white)

    // Footer
    table.cell(dash, 0, 8, syminfo.ticker + "  ·  " + timeframe.period + "  ·  OB/BB Pro", bgcolor = tLbl, text_color = tMuted, text_size = tSz, text_halign = text.align_center)

// ─── Alerts ────────────────────────────────────────────────────────────────
alertcondition(evNewBullOB, "New bullish order block", "New bullish order block on {{ticker}} ({{interval}})")
alertcondition(evNewBearOB, "New bearish order block", "New bearish order block on {{ticker}} ({{interval}})")
alertcondition(evNewBullBB, "New bullish breaker", "Bearish OB failed – new bullish breaker on {{ticker}} ({{interval}})")
alertcondition(evNewBearBB, "New bearish breaker", "Bullish OB failed – new bearish breaker on {{ticker}} ({{interval}})")
alertcondition(evTapBullOB, "Retest of bullish OB", "Price is retesting a bullish order block on {{ticker}} ({{interval}})")
alertcondition(evTapBearOB, "Retest of bearish OB", "Price is retesting a bearish order block on {{ticker}} ({{interval}})")
alertcondition(evTapBullBB, "Retest of bullish breaker", "Price is retesting a bullish breaker on {{ticker}} ({{interval}})")
alertcondition(evTapBearBB, "Retest of bearish breaker", "Price is retesting a bearish breaker on {{ticker}} ({{interval}})")
alertcondition(evNewBullOB or evNewBearOB or evNewBullBB or evNewBearBB or evTapBullOB or evTapBearOB or evTapBullBB or evTapBearBB, "Any OB / breaker event", "Order block / breaker event on {{ticker}} ({{interval}})")
````
