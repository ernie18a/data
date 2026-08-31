<!-- tradingview-pine-id: PUB;a628cac08d7c49bdafb595aaa1a4f21a -->
<!-- tradingviewscripts-format: 1 -->
# Zone Radar [DefinedEdge]

Source: https://www.tradingview.com/script/Dx4yfv9J-Zone-Radar-DefinedEdge/

## Description

Price spends most of its time going nowhere. Zone Radar finds those stretches automatically, draws the range while it's still forming, and tells you the moment it breaks and how hard.

🎯 What it does

Zone Radar watches for price coiling inside a bounded range. When a genuine consolidation forms, it marks the zone with its support and resistance, then tracks it live. The instant price closes decisively outside the range, it flags the break and scores its strength from 0 to 100. Strong breaks get a bold label and a projected target.

It is a context and breakout tool, not a signal service. It shows you where the market is compressed and when that compression releases. What you do with that read is yours.

🧭 How a zone is found

A range only qualifies when two things are true at once:

Price stays inside an ATR normalised band for a minimum number of bars, so the width adapts to any symbol or timeframe on its own.
Price does not drift across that band from one side to the other, which filters out slow trends pretending to be ranges.

Once a zone is confirmed the box breathes to hug the real range, but it is capped at the width it formed with. That cap is what makes a breakout meaningful: a close beyond it is a true expansion out of compression, not just another bar inside the noise.

💥 Break strength (0 to 100)

Every break is graded on four things that separate a real breakout from a fake one:

Displacement how far beyond the edge it closed, in ATR
Range expansion the break bar's range against its recent average
Volume surge participation on the break (auto adjusted on symbols with no volume data, like spot FX)
Coil quality how long and tight the range was, since a longer coil breaks harder

Breaks at or above your Strong threshold get the bold badge plus a measured move target: the height of the range projected from the breakout point. Broken edges stay on the chart as polarity support and resistance for the retest.

⚙️ Under The Hood

Signals fire on the close of the breakout bar. No repainting, ever.
Fully adjustable: range length, width, break sensitivity, strength threshold, and how much history stays on the chart.
Works on any market and any timeframe. Tuned nicely for intraday out of the box.

🔔 Alerts

Zone formed, break up, break down, strong break up, strong break down. Wire any of them into your workflow.

📝 Notes

Lower timeframes produce far more zones than higher ones, so only the most recent are kept drawn to stay within platform limits. Raise the zone cap if you want more history, or drop to a higher timeframe for a cleaner chart. The ATR based settings are a starting point, not gospel. Tune them to how your instrument actually moves.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("Zone Radar [DefinedEdge]",
     shorttitle = "Zone Radar",
     overlay = true,
     max_bars_back    = 2000,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ============================================================================
//  ZONE RADAR   ·   DefinedEdge
//
//  Finds where an instrument has been COILING - trading inside a bounded range
//  for a sustained stretch - marks that zone's support and resistance, and
//  flags STRONG breaks out of it.
//
//  A zone is confirmed when, over a minimum number of bars, price stays inside
//  an ATR-normalised band AND does not drift across it (so a slow trend is not
//  mistaken for a range). The box breathes to hug the true range but is capped
//  at its formation width. On each bar the break is tested FIRST - a decisive
//  close beyond the edge fires immediately, on that bar - and only otherwise
//  is the bar absorbed into the range.
//
//  BREAK STRENGTH (0-100) blends four breakout traits on the break bar:
//    displacement beyond the edge (ATR) · range expansion vs recent average ·
//    volume surge (redistributed if the symbol has no volume) · coil quality
//    (how long and tight the range was - a coiled spring breaks harder).
//  Breaks above the label threshold are marked; STRONG ones get a bold badge
//  and a measured-move target (the zone's own height projected). Broken edges
//  remain as polarity support / resistance.
//
//  NOTE: lower timeframes generate many more zones. Only the most recent
//  "Max Broken Zones" are kept on the chart (Pine allows 500 drawings total) -
//  raise that cap to see more history, at the cost of drawing budget.
// ============================================================================

// ------------------------------- INPUTS -------------------------------------

string gD = "Zone Detection"
int   minBars   = input.int(20,  "Min Zone Length (bars)", minval=5, maxval=300, group=gD, tooltip="How long price must stay contained before a range is recognised. Higher = only well-established zones.")
float widthMult = input.float(5.0, "Max Zone Height (xATR)", minval=0.5, maxval=30, step=0.5, group=gD, tooltip="A range qualifies only if it fits inside this many ATRs. Lower = only tight coils; higher = looser ranges. ATR-normalised so it travels across symbols.")
float maxDrift  = input.float(0.7, "Max Drift", minval=0.1, maxval=1.0, step=0.05, group=gD, tooltip="Rejects one-way drift dressed as a range. Price must end within this fraction of the band's height from where it started - lower is stricter.")
int   atrLen    = input.int(14,  "ATR Length", minval=2, maxval=100, group=gD)
float breakBuf  = input.float(0.15, "Break Buffer (xATR)", minval=0.0, maxval=2.0, step=0.05, group=gD, tooltip="A break needs a close this far beyond the zone edge to count - filters marginal pokes.")
float testTol   = input.float(0.2, "Edge Touch Tolerance (xATR)", minval=0.0, maxval=2.0, step=0.05, group=gD, tooltip="How close a wick must come to an edge to count as a defended touch.")
int   coolBars  = input.int(3,   "Cooldown After Break (bars)", minval=0, maxval=50, group=gD)

string gS = "Break Strength"
int   avgLen      = input.int(20, "Volume / Range Average", minval=5, maxval=200, group=gS, tooltip="Baseline window for range-expansion and volume-surge comparison.")
float strongThr   = input.float(55, "Strong Break ≥", minval=10, maxval=95, step=5, group=gS, tooltip="Breaks scoring at or above this are STRONG - bold badge + measured-move target.")
int   coilRef     = input.int(50, "Coil Reference (bars)", minval=10, maxval=300, group=gS, tooltip="A zone this long earns full coil credit in the strength score.")

string gV = "Display"
bool  showActive  = input.bool(true,  "Show Forming Zone", group=gV)
bool  showInfo    = input.bool(true,  "Zone Info Tag", group=gV, tooltip="Small tag on the active zone: bars contained + edge touches.")
bool  showHistory = input.bool(true,  "Keep Broken Zones", group=gV)
int   maxZones    = input.int(25, "Max Broken Zones Kept", minval=1, maxval=100, group=gV, tooltip="How many past zones stay drawn. Higher = more scroll-back history. Pine caps total drawings at 500, so very high values on low timeframes may start dropping objects.")
float labelMinStr = input.float(55, "Label Breaks ≥", minval=0, maxval=95, step=5, group=gV, tooltip="Minimum strength a break needs to get a badge. Default only labels strong breaks; raise to show only the strongest. Zones are unaffected.")
bool  compact     = input.bool(false, "Compact Labels", group=gV, tooltip="Collapse badges to just an arrow + score. Declutters busy charts.")
int   minBreakGap = input.int(0, "Min Bars Between Break Labels", minval=0, maxval=100, group=gV, tooltip="Suppress a break badge if the previous one was fewer than this many bars ago. Thins out clustered breaks; zones still track normally.")
bool  showTarget  = input.bool(true,  "Measured-Move Target", group=gV)
bool  showPolarity= input.bool(true,  "Extend S/R After Break", group=gV)
int   projLen     = input.int(30, "Projection Length (bars)", minval=0, maxval=200, group=gV)

string gC = "Colors"
color colZone = input.color(#6b7a99, "Range", group=gC)
color colUp   = input.color(#26c281, "Bull Break", group=gC)
color colDn   = input.color(#f0506e, "Bear Break", group=gC)
color colInk  = input.color(#0a0e14, "Label Text", group=gC)

// -------------------------------- TYPES -------------------------------------

type ZoneArt
    box   bx   = na
    line  topL = na
    line  botL = na
    label brk  = na
    line  tgt  = na

// -------------------------------- STATE -------------------------------------

var bool  inZone   = false
var float zTop     = na
var float zBot     = na
var int   zStart   = 0
var float zAtr     = na       // ATR locked at formation - stable zone scale
var int   topTest  = 0
var int   botTest  = 0
var int   coolTo   = 0
var int   lastLbl  = na       // bar of the last drawn break badge

var box   aBox = na
var line  aTop = na
var line  aBot = na
var label aLbl = na

var array<ZoneArt> hist = array.new<ZoneArt>()

// --------------------------- MEASUREMENTS -----------------------------------

float atr    = ta.atr(atrLen)
float trueR  = ta.tr(true)
float avgRng = ta.sma(trueR, avgLen)
float volAvg = ta.sma(volume, avgLen)
bool  hasVol = not na(volAvg) and volAvg > 0
int   n      = bar_index

// ------------------------------- HELPERS ------------------------------------

pushHist(ZoneArt z) =>
    array.push(hist, z)
    if array.size(hist) > maxZones
        ZoneArt o = array.shift(hist)
        if not na(o.bx)
            box.delete(o.bx)
        if not na(o.topL)
            line.delete(o.topL)
        if not na(o.botL)
            line.delete(o.botL)
        if not na(o.brk)
            label.delete(o.brk)
        if not na(o.tgt)
            line.delete(o.tgt)
    true

// signal booleans (per bar)
bool  zoneBorn = false
bool  brokeUp  = false
bool  brokeDn  = false
bool  strongUp = false
bool  strongDn = false
float lastStr  = 0.0

// ===================== STATE MACHINE (confirmed bars) =======================

if barstate.isconfirmed and atr > 0
    if not inZone
        // ---- look for a new zone ----
        if n >= coolTo and n > minBars
            float wHi   = ta.highest(high, minBars)
            float wLo   = ta.lowest(low, minBars)
            float wRng  = wHi - wLo
            float drift = math.abs(close - close[minBars])
            if wRng <= widthMult * atr and drift <= wRng * maxDrift
                inZone   := true
                zTop     := wHi
                zBot     := wLo
                zStart   := n - minBars + 1
                zAtr     := atr
                topTest  := 0
                botTest  := 0
                zoneBorn := true
                if showActive
                    aBox := box.new(zStart, zTop, n, zBot, border_color = color.new(colZone, 35), border_width = 1, bgcolor = color.new(colZone, 88))
                    aTop := line.new(zStart, zTop, n, zTop, color = color.new(colZone, 20), width = 2)
                    aBot := line.new(zStart, zBot, n, zBot, color = color.new(colZone, 20), width = 2)
                    if showInfo
                        aLbl := label.new(n, zTop, "RANGE", style = label.style_label_down, color = color.new(colZone, 20), textcolor = colInk, size = size.tiny)
    else
        // ---- BREAK TESTED FIRST: a decisive close fires on THIS bar ----
        bool upB = close > zTop + breakBuf * zAtr
        bool dnB = close < zBot - breakBuf * zAtr

        if upB or dnB
            // ---- strength score ----
            float zone  = zTop - zBot
            int   bars  = n - zStart
            float edge  = upB ? zTop : zBot
            float disp  = upB ? (close - zTop) : (zBot - close)
            float dispT = math.min(disp / zAtr / 1.0, 1.0)
            float expT  = avgRng > 0 ? math.min((trueR / avgRng) / 2.0, 1.0) : 0.0
            float volT  = hasVol ? math.min((volume / volAvg) / 2.0, 1.0) : na
            float coilT = math.min(bars / float(coilRef), 1.0)
            float baseT = 0.35 * dispT + 0.30 * expT + 0.15 * coilT
            float strg  = hasVol ? (baseT + 0.20 * volT) * 100.0 : (baseT / 0.80) * 100.0
            bool  strong = strg >= strongThr
            lastStr := strg

            if upB
                brokeUp := true
                strongUp := strong
            else
                brokeDn := true
                strongDn := strong

            color   bc  = upB ? colUp : colDn
            ZoneArt art = ZoneArt.new()

            // freeze / discard the range box
            if not na(aBox)
                if showHistory
                    box.set_right(aBox, n)
                    box.set_bgcolor(aBox, color.new(bc, 90))
                    box.set_border_color(aBox, color.new(bc, 55))
                    art.bx := aBox
                else
                    box.delete(aBox)
            if not na(aLbl)
                label.delete(aLbl)

            // polarity S/R lines
            if not na(aTop)
                if showHistory and showPolarity
                    line.set_x2(aTop, n + projLen)
                    line.set_style(aTop, line.style_dashed)
                    line.set_color(aTop, color.new(upB ? colUp : colZone, 35))
                    art.topL := aTop
                else
                    line.delete(aTop)
            if not na(aBot)
                if showHistory and showPolarity
                    line.set_x2(aBot, n + projLen)
                    line.set_style(aBot, line.style_dashed)
                    line.set_color(aBot, color.new(dnB ? colDn : colZone, 35))
                    art.botL := aBot
                else
                    line.delete(aBot)

            // break badge (respects strength floor + spacing)
            bool spaced = na(lastLbl) or (n - lastLbl) >= minBreakGap
            if strg >= labelMinStr and spaced
                string btxt = compact ? ((upB ? "▲" : "▼") + str.tostring(strg, "#")) : ((upB ? "▲" : "▼") + (strong ? " STRONG " : " ") + str.tostring(strg, "#"))
                art.brk := label.new(n, upB ? low : high, btxt,
                     style     = upB ? label.style_label_up : label.style_label_down,
                     color     = strong ? bc : color.new(bc, 55),
                     textcolor = strong ? colInk : color.new(color.white, 20),
                     size      = strong ? size.small : size.tiny)
                lastLbl := n

                // measured-move target - clean dotted line, no text block
                if showTarget and strong
                    float tgtP = upB ? edge + zone : edge - zone
                    art.tgt := line.new(n, tgtP, n + projLen, tgtP, color = color.new(bc, 30), width = 1, style = line.style_dotted)

            pushHist(art)

            // reset to searching
            inZone := false
            coolTo := n + coolBars
            aBox := na
            aTop := na
            aBot := na
            aLbl := na
        else
            // ---- no break: absorb the bar into the range if still contained ----
            float newTop = math.max(zTop, high)
            float newBot = math.min(zBot, low)
            if (newTop - newBot) <= widthMult * zAtr
                zTop := newTop
                zBot := newBot
                if high >= zTop - testTol * zAtr and close < zTop
                    topTest += 1
                if low <= zBot + testTol * zAtr and close > zBot
                    botTest += 1

// ===================== LIVE EXTENSION (every bar) ===========================

if inZone and not na(aBox)
    box.set_right(aBox, n)
    box.set_top(aBox, zTop)
    box.set_bottom(aBox, zBot)
    if not na(aTop)
        line.set_y1(aTop, zTop)
        line.set_y2(aTop, zTop)
        line.set_x2(aTop, n)
    if not na(aBot)
        line.set_y1(aBot, zBot)
        line.set_y2(aBot, zBot)
        line.set_x2(aBot, n)
    if not na(aLbl) and showInfo
        label.set_xy(aLbl, n, zTop)
        label.set_text(aLbl, "RANGE  " + str.tostring(n - zStart) + "b  ·  " + str.tostring(topTest + botTest) + " touches")

// ------------------------------- ALERTS -------------------------------------

alertcondition(zoneBorn, "Zone Formed", "Zone Radar: a consolidation range has formed.")
alertcondition(strongUp, "Strong Break Up",   "Zone Radar: STRONG break above the range.")
alertcondition(strongDn, "Strong Break Down", "Zone Radar: STRONG break below the range.")
alertcondition(brokeUp,  "Break Up",   "Zone Radar: range broken to the upside.")
alertcondition(brokeDn,  "Break Down", "Zone Radar: range broken to the downside.")

if barstate.isconfirmed
    if strongUp or strongDn
        alert("STRONG " + (strongUp ? "UP" : "DOWN") + " BREAK  " + syminfo.ticker + " (" + timeframe.period + ")  Strength=" + str.tostring(lastStr, "#") + "/100", alert.freq_once_per_bar)
    else if brokeUp or brokeDn
        alert((brokeUp ? "UP" : "DOWN") + " BREAK  " + syminfo.ticker + " (" + timeframe.period + ")  Strength=" + str.tostring(lastStr, "#") + "/100", alert.freq_once_per_bar)
````
