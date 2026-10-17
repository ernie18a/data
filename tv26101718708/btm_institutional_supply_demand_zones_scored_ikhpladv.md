# BTM Institutional Supply & Demand Zones [Scored]

- url: https://www.tradingview.com/script/IkHpLAdV-BTM-Institutional-Supply-Demand-Zones-Scored/
- type: indicator
- pine_id: PUB;bd09f804cefa488182f199ddb817fdf6
- version: 1.0

## Description

BTM Institutional Supply & Demand Zones [Scored] automatically detects supply and demand zones using the classic Leg-In → Base → Leg-Out method, grades every zone with a transparent 8-point scoring system, and tracks each zone through its full life: fresh, retested, broken and flipped.

WHY THIS INDICATOR IS DIFFERENT
Many supply and demand tools draw a box at every pause in price, which fills the chart with weak zones. This script only draws a zone when a short, indecisive base is followed by a strong candle that closes clean beyond it. Every zone is then scored using the well-known "odds enhancers" from the supply and demand method, so you can see at a glance which zones are worth watching and which are not.

HOW ZONES ARE DETECTED
1. Base: 1 to 6 indecisive candles (body no more than 50% of the candle's range by default).
2. Leg-out: a strong candle (body at least 60% of its range and a range of at least 1× ATR by default) that closes beyond the base.
3. Leg-in: the candle before the base sets the pattern type:
- DBR (Drop-Base-Rally) – demand, reversal
- RBR (Rally-Base-Rally) – demand, continuation
- RBD (Rally-Base-Drop) – supply, reversal
- DBD (Drop-Base-Drop) – supply, continuation

The entry edge (proximal line) is drawn at the base candle bodies by default, and the stop edge (distal line) at the base wicks. Both can be adjusted.

THE SCORING SYSTEM (OUT OF 8)
- Departure strength (0–2): how forcefully price left the zone
- Time at level (0–2): fewer base candles score higher
- Freshness (0–2): untouched zones score highest; each retest lowers the score
- Pattern (0–1): reversal patterns (DBR / RBD) earn an extra point
- Location (0–1): demand in the lower half or supply in the upper half of the recent range earns an extra point

Grades: A = 6–8, B = 4–5, C = 0–3. Each zone label shows the pattern, grade and score, for example "Demand DBR A 7/8 ✦ Fresh".

ZONE LIFECYCLE
- Fresh zones are drawn brighter.
- Each retest fades the zone and lowers its score. Zones are removed after 3 retests by default.
- A close through the far edge breaks the zone. Broken zones can flip: a broken demand zone becomes supply, and a broken supply zone becomes demand.

COLOUR KEY
- Green – Demand zone
- Red – Supply zone
- Blue – Broken supply flipped to demand
- Orange – Broken demand flipped to supply
- Dotted line – 50% level of the zone

REACTION SIGNALS
A BUY label appears when price taps a qualifying demand zone and a candle closes back above it in the zone's direction. A SELL label appears for the opposite at supply. You can set the minimum zone grade required for signals and how many bars price has to react.

DASHBOARD
A colour-coded table shows:
- Trend direction based on an EMA
- Nearest demand and supply zones with price range and distance
- Estimated risk:reward from one zone to the opposite zone (highlighted at 1:2 or better)
- Number of active demand and supply zones
Position, size, theme and accent colour are fully adjustable.

HOW TO USE IT
1. Check the trend on the dashboard. Favour demand zones in an uptrend and supply zones in a downtrend, or turn on the trend filter.
2. Focus on A-grade, fresh zones.
3. Wait for price to return to the zone and react. A BUY or SELL signal confirms a reaction, but always check the chart yourself.
4. Place your stop beyond the far edge of the zone.
5. Use the nearest opposite zone as a target and check the R:R on the dashboard.

SUGGESTED SETTINGS
- Beginners: Minimum grade A, trend filter on, signals on.
- Experienced traders: Minimum grade B, wick entry edge, leg-in included for wider protective stops.
- Higher timeframes give fewer, stronger zones. Lower timeframes give more zones and more noise.

NON-REPAINTING
By default the script only acts on closed candles, so zones and signals do not appear and disappear on the live candle. Once drawn, a zone's position does not change.

ALERTS
Alerts are available for new demand and supply zones, zone retests, BUY and SELL reactions, flipped zones, and a combined "any event" alert.

DISCLAIMER
This indicator identifies price zones based on supply and demand concepts. It does not predict future price movement and is not financial advice. Zones and signals can and do fail. Always test it on historical data, use proper risk management, and make your own trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("BTM Institutional Supply & Demand Zones [Scored]", shorttitle = "BTM Inst. S&D", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════════════════
//  BTM INSTITUTIONAL SUPPLY & DEMAND ZONES [SCORED]
//
//  HOW IT WORKS
//  1. A zone forms from a Leg-In -> Base -> Leg-Out sequence:
//       Base    = 1–6 indecisive candles (small body vs. range)
//       Leg-out = a strong candle (big body, >= ATR) that closes beyond the base
//     Patterns: DBR / RBR = demand, RBD / DBD = supply.
//  2. Proximal line (entry edge) = base body (or wick); distal line = base wick.
//  3. Each zone is scored out of 8 with the classic "odds enhancers":
//       Departure strength 0–2 | Time at level 0–2 | Freshness 0–2
//       Reversal pattern 0–1   | Premium/discount location 0–1
//     Grade: A = 6–8, B = 4–5, C = 0–3
//  4. Every retest lowers freshness. A close through the distal line breaks
//     the zone; broken zones can flip (demand -> supply and vice versa).
//  5. Reaction signals fire when price taps a qualifying zone and closes back
//     out of it in the zone's direction.
// ════════════════════════════════════════════════════════════════════════════

// ─── Inputs ────────────────────────────────────────────────────────────────
const string G1 = "Zone detection"
int    basePct   = input.int(50, "Base candle: max body % of range", minval = 10, maxval = 80, group = G1, tooltip = "A candle counts as a base (indecision) candle when its body is at most this % of its full range.")
int    maxBase   = input.int(6, "Max base candles", minval = 1, maxval = 10, group = G1, tooltip = "Fewer base candles = less time at the level = stronger imbalance.")
int    ercBody   = input.int(60, "Leg-out candle: min body % of range", minval = 40, maxval = 95, group = G1)
float  ercAtr    = input.float(1.0, "Leg-out candle: min range (× ATR)", minval = 0.3, step = 0.1, group = G1, tooltip = "How strong the candle leaving the base must be.")
string proxMode  = input.string("Body", "Entry edge (proximal line)", options = ["Body", "Wick"], group = G1, tooltip = "Body = classic supply & demand drawing (tighter zones). Wick = full base range.")
bool   inclLegIn = input.bool(false, "Include leg-in wick in reversal zones", group = G1, tooltip = "Extends the stop side (distal line) of DBR / RBD zones to the leg-in candle's extreme. Safer stops, wider zones.")
int    atrLen    = input.int(14, "ATR length", minval = 1, group = G1)
bool   confOnly  = input.bool(true, "Only act on closed candles", group = G1, tooltip = "Prevents zones and signals appearing and disappearing on the live candle.")

const string G2 = "Quality filters"
string minGrade  = input.string("B", "Minimum grade to draw", options = ["A", "B", "C"], group = G2, tooltip = "A = 6–8 points, B = 4–5, C = 0–3. Choose A for the cleanest chart.")
bool   useTrend  = input.bool(false, "Only draw zones in the trend direction", group = G2, inline = "t")
int    trendLen  = input.int(200, "EMA", minval = 10, group = G2, inline = "t")
int    curveLen  = input.int(100, "Range for premium / discount (bars)", minval = 20, group = G2, tooltip = "Demand in the lower half and supply in the upper half of this range score an extra point.")
float  maxH      = input.float(2.5, "Max zone height (× ATR)", minval = 0.5, step = 0.5, group = G2)
bool   noOverlap = input.bool(true, "Skip zones overlapping an active one", group = G2)

const string G3 = "Zone lifecycle"
string breakBy    = input.string("Close", "Zone breaks on", options = ["Close", "Wick"], group = G3)
int    maxTouches = input.int(3, "Remove zone after retests", minval = 1, maxval = 10, group = G3, tooltip = "Each retest absorbs orders at the level, so zones weaken with every touch.")
bool   showFlip   = input.bool(true, "Flip broken zones (demand ↔ supply)", group = G3)

const string G4 = "Signals"
bool   showSig  = input.bool(true, "Show BUY / SELL reaction signals", group = G4)
string sigGrade = input.string("B", "Minimum zone grade for signals", options = ["A", "B", "C"], group = G4)
int    sigWin   = input.int(5, "Bars allowed for the reaction", minval = 1, maxval = 20, group = G4, tooltip = "After price taps a zone, a signal fires if a candle closes back out of the zone in its direction within this many bars.")
bool   sigFlip  = input.bool(false, "Allow signals on flipped zones", group = G4)

const string G5 = "Display"
bool  showDem  = input.bool(true, "Demand", group = G5, inline = "a")
color cDem     = input.color(#00c48c, "", group = G5, inline = "a")
bool  showSup  = input.bool(true, "Supply", group = G5, inline = "a")
color cSup     = input.color(#ff4d5e, "", group = G5, inline = "a")
color cFlipD   = input.color(#3d8bfd, "Flipped → demand", group = G5, inline = "b")
color cFlipS   = input.color(#ffa62b, "Flipped → supply", group = G5, inline = "b")
int   maxShow  = input.int(6, "Max zones per type", minval = 1, maxval = 50, group = G5)
int   extBars  = input.int(20, "Extend zones right (bars)", minval = 0, maxval = 500, group = G5)
bool  showCE   = input.bool(true, "Show 50% line", group = G5)
bool  showText = input.bool(true, "Show zone labels", group = G5)
bool  showEma  = input.bool(false, "Show trend EMA", group = G5)

const string G6 = "Dashboard"
bool   showDash  = input.bool(true, "Show dashboard", group = G6)
string dashPos   = input.string("Bottom Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G6)
string dashSize  = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G6)
string dashTheme = input.string("Dark", "Theme", options = ["Dark", "Light"], group = G6)
color  cAccent   = input.color(#7c4dff, "Header / frame colour", group = G6)

// ─── Core series ───────────────────────────────────────────────────────────
float atrV = ta.atr(atrLen)
float emaV = ta.ema(close, trendLen)
float hh   = ta.highest(high, curveLen)
float ll   = ta.lowest(low, curveLen)

// ─── Zone object ───────────────────────────────────────────────────────────
type SDZone
    float  top
    float  bot
    int    left
    int    born
    bool   support    // true = demand (support), false = supply (resistance)
    bool   flip
    string pat
    int    baseScore  // all points except freshness
    int    touches
    int    armBar
    box    bx
    line   ce

var array<SDZone> zones = array.new<SDZone>()

// ─── Helpers ───────────────────────────────────────────────────────────────
zScore(SDZone z) =>
    z.baseScore + (z.touches == 0 ? 2 : z.touches == 1 ? 1 : 0)

gradeOf(int s) =>
    s >= 6 ? "A" : s >= 4 ? "B" : "C"

gradeRank(string g) =>
    g == "A" ? 3 : g == "B" ? 2 : 1

baseCol(SDZone z) =>
    z.flip ? (z.support ? cFlipD : cFlipS) : (z.support ? cDem : cSup)

fillCol(SDZone z) =>
    string g = gradeOf(zScore(z))
    float  t = z.flip ? 82.0 : g == "A" ? 68.0 : g == "B" ? 78.0 : 86.0
    color.new(baseCol(z), math.min(94.0, t + z.touches * 5))

edgeCol(SDZone z) =>
    color.new(baseCol(z), z.touches == 0 ? 20 : 50)

zName(SDZone z) =>
    string g = gradeOf(zScore(z))
    string s = z.flip ? (z.support ? "Flip → Demand" : "Flip → Supply") : ((z.support ? "Demand " : "Supply ") + z.pat + "  " + g + " " + str.tostring(zScore(z)) + "/8")
    s

zText(SDZone z) =>
    string state = z.touches == 0 ? "  ✦ Fresh" : "  ×" + str.tostring(z.touches)
    showText ? zName(z) + state : ""

drawZone(SDZone z) =>
    z.bx := box.new(z.left, z.top, bar_index + extBars, z.bot, border_color = edgeCol(z), bgcolor = fillCol(z), text = zText(z), text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right, text_valign = text.align_center)
    if showCE
        float mid = (z.top + z.bot) / 2
        z.ce := line.new(z.left, mid, bar_index + extBars, mid, color = edgeCol(z), style = line.style_dotted)
    z

restyle(SDZone z) =>
    z.bx.set_bgcolor(fillCol(z))
    z.bx.set_border_color(edgeCol(z))
    z.bx.set_text(zText(z))
    if not na(z.ce)
        z.ce.set_color(edgeCol(z))
    z

extendZone(SDZone z) =>
    z.bx.set_right(bar_index + extBars)
    if not na(z.ce)
        z.ce.set_x2(bar_index + extBars)
    z

killZone(SDZone z) =>
    z.bx.delete()
    if not na(z.ce)
        z.ce.delete()
    z

overlaps(float top, float bot, bool support) =>
    bool hit = false
    for z in zones
        if not z.flip and z.support == support and top >= z.bot and bot <= z.top
            hit := true
            break
    hit

pruneZones(bool support, bool flp) =>
    int cnt = 0
    for z in zones
        if z.support == support and z.flip == flp
            cnt += 1
    int excess = cnt - maxShow
    int i = 0
    while excess > 0 and i < zones.size()
        SDZone z = zones.get(i)
        if z.support == support and z.flip == flp
            killZone(z)
            zones.remove(i)
            excess -= 1
        else
            i += 1
    cnt

// ─── Event flags ───────────────────────────────────────────────────────────
bool evNewDem  = false
bool evNewSup  = false
bool evTapDem  = false
bool evTapSup  = false
bool evFlip    = false
bool sigBuy    = false
bool sigSell   = false

// ─── Main logic ────────────────────────────────────────────────────────────
bool go = not confOnly or barstate.isconfirmed

if go
    // 1) Detect Leg-In -> Base -> Leg-Out on the candle that just closed
    float rng0  = high - low
    float body0 = math.abs(close - open)
    bool  erc   = rng0 > 0 and body0 >= ercBody / 100.0 * rng0 and rng0 >= ercAtr * atrV

    if erc
        int nb = 0
        for i = 1 to maxBase + 1
            float r      = high[i] - low[i]
            bool  isBase = r <= 0 or math.abs(close[i] - open[i]) <= basePct / 100.0 * r
            if isBase
                nb += 1
            else
                break

        if nb >= 1 and nb <= maxBase
            float bHi  = high[1]
            float bLo  = low[1]
            float bdHi = math.max(open[1], close[1])
            float bdLo = math.min(open[1], close[1])
            for k = 1 to nb
                bHi  := math.max(bHi, high[k])
                bLo  := math.min(bLo, low[k])
                bdHi := math.max(bdHi, math.max(open[k], close[k]))
                bdLo := math.min(bdLo, math.min(open[k], close[k]))

            int   li      = nb + 1
            bool  legInUp = close[li] > open[li]
            bool  upOut   = close > open
            float midR    = (hh + ll) / 2
            int   timePts = nb <= 3 ? 2 : 1

            // Demand: DBR / RBR
            if upOut and close > bHi and showDem
                float  zTop     = proxMode == "Body" ? bdHi : bHi
                float  zBot     = inclLegIn and not legInUp ? math.min(bLo, low[li]) : bLo
                string pat      = legInUp ? "RBR" : "DBR"
                int    depPts   = rng0 >= 2 * atrV or low > bHi ? 2 : 1
                int    patPts   = legInUp ? 0 : 1
                int    curvePts = zTop <= midR ? 1 : 0
                int    bs       = depPts + timePts + patPts + curvePts
                float  h        = zTop - zBot
                bool   ok       = (not useTrend or close > emaV) and h > 0 and h <= maxH * atrV and gradeRank(gradeOf(bs + 2)) >= gradeRank(minGrade) and (not noOverlap or not overlaps(zTop, zBot, true))
                if ok
                    SDZone z = SDZone.new(top = zTop, bot = zBot, left = bar_index - nb, born = bar_index, support = true, flip = false, pat = pat, baseScore = bs, touches = 0)
                    drawZone(z)
                    zones.push(z)
                    evNewDem := true

            // Supply: RBD / DBD
            if not upOut and close < bLo and showSup
                float  zTop     = inclLegIn and legInUp ? math.max(bHi, high[li]) : bHi
                float  zBot     = proxMode == "Body" ? bdLo : bLo
                string pat      = legInUp ? "RBD" : "DBD"
                int    depPts   = rng0 >= 2 * atrV or high < bLo ? 2 : 1
                int    patPts   = legInUp ? 1 : 0
                int    curvePts = zBot >= midR ? 1 : 0
                int    bs       = depPts + timePts + patPts + curvePts
                float  h        = zTop - zBot
                bool   ok       = (not useTrend or close < emaV) and h > 0 and h <= maxH * atrV and gradeRank(gradeOf(bs + 2)) >= gradeRank(minGrade) and (not noOverlap or not overlaps(zTop, zBot, false))
                if ok
                    SDZone z = SDZone.new(top = zTop, bot = zBot, left = bar_index - nb, born = bar_index, support = false, flip = false, pat = pat, baseScore = bs, touches = 0)
                    drawZone(z)
                    zones.push(z)
                    evNewSup := true

    // 2) Manage zones: retests, signals, breaks, flips
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            SDZone z = zones.get(i)
            if bar_index > z.born
                float loSrc  = breakBy == "Close" ? close : low
                float hiSrc  = breakBy == "Close" ? close : high
                bool  broken = z.support ? loSrc < z.bot : hiSrc > z.top
                bool  tapped = z.support ? (low <= z.top and low[1] > z.top) : (high >= z.bot and high[1] < z.bot)

                if broken
                    zones.remove(i)
                    if showFlip and not z.flip
                        z.flip    := true
                        z.support := not z.support
                        z.born    := bar_index
                        z.touches := 0
                        z.armBar  := na
                        restyle(z)
                        extendZone(z)
                        zones.push(z)
                        evFlip := true
                    else
                        killZone(z)
                else
                    bool alive = true
                    if tapped
                        z.touches += 1
                        z.armBar  := bar_index
                        if z.support
                            evTapDem := true
                        else
                            evTapSup := true
                        if z.touches > maxTouches
                            killZone(z)
                            zones.remove(i)
                            alive := false
                        else
                            restyle(z)
                    if alive
                        bool armed = not na(z.armBar) and bar_index - z.armBar <= sigWin
                        bool qual  = (not z.flip or sigFlip) and gradeRank(gradeOf(zScore(z))) >= gradeRank(sigGrade)
                        if showSig and armed and qual
                            if z.support and close > z.top and close > open
                                sigBuy   := true
                                z.armBar := na
                            else if not z.support and close < z.bot and close < open
                                sigSell  := true
                                z.armBar := na
                        extendZone(z)

    // 3) Keep the chart clean
    pruneZones(true, false)
    pruneZones(false, false)
    pruneZones(true, true)
    pruneZones(false, true)

// ─── Plots ─────────────────────────────────────────────────────────────────
plot(showEma ? emaV : na, "Trend EMA", color.new(color.gray, 30), 2)
plotshape(sigBuy, "BUY reaction", shape.labelup, location.belowbar, color.new(cDem, 0), text = "BUY", textcolor = color.white, size = size.small)
plotshape(sigSell, "SELL reaction", shape.labeldown, location.abovebar, color.new(cSup, 0), text = "SELL", textcolor = color.white, size = size.small)

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
    string demTxt = "—"
    string supTxt = "—"
    float  demD   = na
    float  supD   = na
    float  demTop = na
    float  demBot = na
    float  supTop = na
    float  supBot = na
    int    nDem   = 0
    int    nSup   = 0
    for z in zones
        if z.support
            nDem += 1
            if z.bot <= close
                float d = math.max(0.0, (close - z.top) / close * 100)
                if na(demD) or d < demD
                    demD   := d
                    demTop := z.top
                    demBot := z.bot
                    demTxt := zName(z) + "  " + str.tostring(z.bot, format.mintick) + " – " + str.tostring(z.top, format.mintick) + "  (" + str.tostring(d, "0.00") + "%)"
        else
            nSup += 1
            if z.top >= close
                float d = math.max(0.0, (z.bot - close) / close * 100)
                if na(supD) or d < supD
                    supD   := d
                    supTop := z.top
                    supBot := z.bot
                    supTxt := zName(z) + "  " + str.tostring(z.bot, format.mintick) + " – " + str.tostring(z.top, format.mintick) + "  (" + str.tostring(d, "0.00") + "%)"

    // Risk : reward from the entry edge of one zone to the entry edge of the opposite zone
    float rrL = na
    float rrS = na
    if not na(demTop) and not na(supBot) and supBot > demTop and demTop > demBot
        rrL := (supBot - demTop) / (demTop - demBot)
    if not na(demTop) and not na(supBot) and supBot > demTop and supTop > supBot
        rrS := (supBot - demTop) / (supTop - supBot)

    color green = color.new(cDem, 0)
    color red   = color.new(cSup, 0)

    table.cell(dash, 0, 0, "◆  BTM INSTITUTIONAL SUPPLY & DEMAND  ◆", bgcolor = cAccent, text_color = color.white, text_size = tSz, text_halign = text.align_center)

    bool   upT   = close > emaV
    string trTxt = na(emaV) ? "—" : upT ? "▲  UPTREND" : "▼  DOWNTREND"
    dashRow(1, "Trend (" + str.tostring(trendLen) + " EMA)", trTxt, na(emaV) ? tLbl : upT ? green : red, na(emaV) ? tTxt : color.white)

    dashRow(2, "Nearest demand", demTxt, na(demD) ? tLbl : color.new(cDem, 25), na(demD) ? tMuted : color.white)
    dashRow(3, "Nearest supply", supTxt, na(supD) ? tLbl : color.new(cSup, 25), na(supD) ? tMuted : color.white)

    dashRow(4, "Long R:R (demand → supply)", na(rrL) ? "—" : "1 : " + str.tostring(rrL, "0.0"), na(rrL) ? tLbl : rrL >= 2 ? green : color.new(color.gray, 40), na(rrL) ? tMuted : color.white)
    dashRow(5, "Short R:R (supply → demand)", na(rrS) ? "—" : "1 : " + str.tostring(rrS, "0.0"), na(rrS) ? tLbl : rrS >= 2 ? red : color.new(color.gray, 40), na(rrS) ? tMuted : color.white)

    dashRow(6, "Active demand zones", str.tostring(nDem), green, color.white)
    dashRow(7, "Active supply zones", str.tostring(nSup), red, color.white)

    table.cell(dash, 0, 8, syminfo.ticker + "  ·  " + timeframe.period + "  ·  BTM Inst. S&D [Scored]", bgcolor = tLbl, text_color = tMuted, text_size = tSz, text_halign = text.align_center)

// ─── Alerts ────────────────────────────────────────────────────────────────
alertcondition(evNewDem, "BTM – New demand zone", "BTM: new demand zone on {{ticker}} ({{interval}})")
alertcondition(evNewSup, "BTM – New supply zone", "BTM: new supply zone on {{ticker}} ({{interval}})")
alertcondition(evTapDem, "BTM – Demand zone retest", "BTM: price is retesting a demand zone on {{ticker}} ({{interval}})")
alertcondition(evTapSup, "BTM – Supply zone retest", "BTM: price is retesting a supply zone on {{ticker}} ({{interval}})")
alertcondition(sigBuy, "BTM – BUY reaction", "BTM: BUY reaction from a demand zone on {{ticker}} ({{interval}})")
alertcondition(sigSell, "BTM – SELL reaction", "BTM: SELL reaction from a supply zone on {{ticker}} ({{interval}})")
alertcondition(evFlip, "BTM – Zone flipped", "BTM: a zone broke and flipped on {{ticker}} ({{interval}})")
alertcondition(evNewDem or evNewSup or evTapDem or evTapSup or sigBuy or sigSell or evFlip, "BTM – Any S&D event", "BTM: supply & demand event on {{ticker}} ({{interval}})")
````
