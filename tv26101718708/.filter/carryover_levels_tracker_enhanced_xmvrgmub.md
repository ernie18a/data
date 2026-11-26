# Carryover Levels Tracker [Enhanced]

- url: https://www.tradingview.com/script/xmvrgmUB-Carryover-Levels-Tracker-Enhanced/
- type: indicator
- pine_id: PUB;ea921d0dd2264988986d3ea6dac91162
- version: 8.0

## Description

Carryover Levels Tracker - Session Highs & Lows with Statistics
This indicator tracks carryover highs and lows from the Asia and London sessions into the New York session and following days.It calculates the high and low during the Asia session (default 20:00–02:00 ET) and London session (default 02:00–08:00 ET), then carries these levels forward. The script monitors wick touches and close breaks of these levels specifically during the New York session.Levels automatically expire after a user-defined number of sessions (default 10).
Key Features
Fully customizable session times
Visual lines with age-based fading, colors, styles, and width
Real-time display of each level’s age and break status (wick or close) during NY session
Statistics table showing historical wick touch and close break rates by level type and age:
Today, D2, D3, D4, D5 (always shown)
Optional D10 bucket (age 6–10)

Summary table of all currently active carryover levels with price, age, and status

Users can independently enable/disable tracking for Asia High/Low and London High/Low, adjust maximum age, table position, text size, and many other settings.Best suited for forex, indices, and futures on intraday timeframes for market structure analysis.Past behavior of carryover levels does not guarantee future results. This script is for observational and analytical purposes only.

## Source Code

````pine
//@version=6
indicator("Carryover Levels Tracker [Enhanced]", "CLT Enhanced", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════════════
grpSess = "Session Times (ET)"
asiaStartH = input.int(20, "Asia Start Hour",   minval=0, maxval=23, group=grpSess, inline="a1")
asiaStartM = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="a1")
asiaEndH   = input.int(2,  "Asia End Hour",      minval=0, maxval=23, group=grpSess, inline="a2")
asiaEndM   = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="a2")
lonStartH  = input.int(2,  "London Start Hour",  minval=0, maxval=23, group=grpSess, inline="l1")
lonStartM  = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="l1")
lonEndH    = input.int(8,  "London End Hour",    minval=0, maxval=23, group=grpSess, inline="l2")
lonEndM    = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="l2")
nyStartH   = input.int(8,  "NY Start Hour",      minval=0, maxval=23, group=grpSess, inline="n1")
nyStartM   = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="n1")
nyEndH     = input.int(16, "NY End Hour",        minval=0, maxval=23, group=grpSess, inline="n2")
nyEndM     = input.int(0,  "Min",                minval=0, maxval=59, group=grpSess, inline="n2")
tzInput    = input.string("America/New_York", "Timezone", options=["America/New_York","America/Chicago","Etc/UTC"], group=grpSess)

grpTrack = "Tracking Settings"
maxAge = input.int(5, "Expire carryover after N sessions", minval=1, maxval=5, group=grpTrack, tooltip="Levels are tracked for up to N sessions, then expire. Stats are bucketed Today/D2/D3/D4/D5, so 5 is the practical max.")
useStatsStart = input.bool(false, "Limit stats to a start date", group=grpTrack, tooltip="When on, only sessions on/after the date below count toward all statistics (ALN, SSS, carryover touch rates). Use this to lock a fixed sample so on-chart numbers can be reproduced exactly in a CSV/Python check. When off, all loaded history is used.")
statsStartDate = input.time(timestamp("01 Jan 2020 00:00 +0000"), "Stats start date", group=grpTrack, tooltip="Sessions before this date are ignored for statistics. Only used when 'Limit stats to a start date' is on. Cutoff is keyed to the NY close (when each session's outcome finalizes).")
useStatsEnd = input.bool(false, "Limit stats to an end date", group=grpTrack, tooltip="When on, only sessions on/before the date below count toward statistics. Pair with the start date to pin the sample to an exact window — e.g. to match a CSV export for validation — regardless of how much chart history is loaded.")
statsEndDate = input.time(timestamp("01 Jan 2030 00:00 +0000"), "Stats end date", group=grpTrack, tooltip="Sessions after this date are ignored for statistics. Only used when 'Limit stats to an end date' is on. Cutoff is keyed to the NY close.")
trackAsiaH = input.bool(true, "Track Asia H carryovers", group=grpTrack)
trackAsiaL = input.bool(true, "Track Asia L carryovers", group=grpTrack)
trackLonH  = input.bool(true, "Track London H carryovers", group=grpTrack)
trackLonL  = input.bool(true, "Track London L carryovers", group=grpTrack)
trackNyH   = input.bool(true, "Track NY Day H carryovers", group=grpTrack)
trackNyL   = input.bool(true, "Track NY Day L carryovers", group=grpTrack)
nyDayWindowMode = input.string("Match NY session settings", "NY Day H/L window", options=["Match NY session settings","Use custom RTH (09:30-16:00 ET)","Custom hours"], group=grpTrack, tooltip="Defines which bars contribute to the NY day H/L. 'Match NY' uses your NY Start/End above. 'RTH' uses fixed 09:30-16:00 ET. 'Custom hours' uses the inputs below.")
nyDayStartH = input.int(9,  "NY Day Custom Start Hour", minval=0, maxval=23, group=grpTrack, inline="nyd1")
nyDayStartM = input.int(30, "Min", minval=0, maxval=59, group=grpTrack, inline="nyd1")
nyDayEndH   = input.int(16, "NY Day Custom End Hour",   minval=0, maxval=23, group=grpTrack, inline="nyd2")
nyDayEndM   = input.int(0,  "Min", minval=0, maxval=59, group=grpTrack, inline="nyd2")
hitGateMode = input.string("NY only", "Track hits during", options=["NY only","NY + London","All sessions"], group=grpTrack, tooltip="Which sessions count toward wick/close hit statistics. 'NY only' is the most tradeable read for NY intraday traders.")

grpBehavior = "Behavior & Alerts"
hideBroken      = input.bool(true,  "Hide broken levels", group=grpBehavior, tooltip="When on, wick-broken levels are hidden everywhere — lines, labels, and the Active Carryovers list. A level counts as broken once price wick-touches it during any NY session in its lifetime. The Target Ladder always shows live levels only.")
extendLeft      = input.bool(false, "Extend lines to the left", group=grpBehavior)
alertOnWick     = input.bool(false, "Alert on wick break", group=grpBehavior)
alertOnClose    = input.bool(true,  "Alert on close break", group=grpBehavior)
showHitStatus   = input.bool(true,  "Show hit status on labels", group=grpBehavior)

grpDisp = "Display"
showLines = input.bool(true, "Draw lines for active carryovers", group=grpDisp)
showLineLabels = input.bool(true, "Show level + age on lines", group=grpDisp)
mergeCloseLabels = input.bool(true, "Merge labels of close levels", group=grpDisp, tooltip="When two or more level lines sit within the threshold below, their labels merge into one (e.g. 'Asia H / Lon H  30259–30264') to avoid overlap. Lines still draw at their own prices; only the labels combine. Newest level (Today > D-2 > D-3) anchors the merged label.")
mergeThreshPct = input.float(0.05, "  • Merge threshold (% of price)", minval=0.005, maxval=1.0, step=0.005, group=grpDisp, tooltip="Levels within this % of each other are grouped. 0.05% ≈ 15 pts at NQ 30,000. Lower = only merge near-identical levels; higher = group wider clusters.")
lineExtendBars = input.int(50, "Line Length (bars to right)", minval=10, maxval=500, group=grpDisp)
showStatsTable = input.bool(false, "Show Wick/Close Rates section", group=grpDisp, tooltip="Historical touch/break rates by level type and age. Reference data — the Target Ladder already shows each live level's touch%. Turn on to study the full age breakdown.")
showWickStats  = input.bool(true, "  • Wick Touch table", group=grpDisp, inline="statTbl")
showCloseStats = input.bool(false, "  • Close Break table", group=grpDisp, inline="statTbl")
showTodaysRead = input.bool(false, "Show Today's Active Carryovers (plain list)", group=grpDisp, tooltip="Plain price/age/live list of today's carryovers. The Target Ladder in the Situation panel shows the same levels plus side, distance, and touch% — so this is redundant unless you want a stripped-down view.")
maxActiveDisplay = input.int(5, "Max active carryovers to display", minval=1, maxval=60, group=grpDisp, tooltip="Caps how many rows the Today's Active Carryovers section shows. Levels are sorted closest-to-price first, so the cap drops the farthest levels. Doesn't affect tracking or stats — just visual display.")
tablePosition  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=grpDisp)
tableTextSize  = input.string("Small", "Table Text Size", options=["Tiny","Small","Normal","Large"], group=grpDisp)
fadeWithAge   = input.bool(true, "Fade lines with age", group=grpDisp)
showCounts    = input.bool(false, "Show raw counts in stat cells", group=grpDisp, tooltip="Display hit counts alongside percentages")
countFormat   = input.string("pct (n)", "Count Format", options=["pct (n)","n/total","n only"], group=grpDisp, tooltip="pct (n): 88.7% (55) | n/total: 55/62 | n only: 55")

grpLineStyle = "Line Styling"
asiaHCol  = input.color(color.new(#9A8F84, 15), "Asia High Color",   group=grpLineStyle)
asiaLCol  = input.color(color.new(#9A8F84, 45), "Asia Low Color",    group=grpLineStyle)
lonHCol   = input.color(color.new(#84968C, 15), "London High Color", group=grpLineStyle)
lonLCol   = input.color(color.new(#84968C, 45), "London Low Color",  group=grpLineStyle)
nyHCol    = input.color(color.new(#838EA3, 15), "NY Day High Color", group=grpLineStyle)
nyLCol    = input.color(color.new(#838EA3, 45), "NY Day Low Color",  group=grpLineStyle)
asiaHStyle = input.string("Dashed", "Asia Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
asiaLStyle = input.string("Dashed", "Asia Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
lonHStyle  = input.string("Dotted",  "London Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
lonLStyle  = input.string("Dotted",  "London Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
nyHStyle   = input.string("Solid",  "NY Day Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
nyLStyle   = input.string("Solid",  "NY Day Style", options=["Solid","Dashed","Dotted"], group=grpLineStyle)
lineWidth = input.int(1, "Line Width", minval=1, maxval=4, group=grpLineStyle)

grpHdrCol = "Header Colors"
hdrBgCol = input.color(color.new(#000000, 0), "Section Header / Accent", group=grpHdrCol, tooltip="Background color for the title and all section header rows. Black by default.")

grpALN = "ALN Pattern Tracker"
enableALN     = input.bool(true,  "Enable ALN engine", group=grpALN, tooltip="Tracks Asia→London range patterns (LEA/AEL/LPU/LPD) and how NY breaks Asia/London H/L levels.")
showALNRead   = input.bool(true,  "Show Today's Read card", group=grpALN)
showALNStats  = input.bool(true,  "Show Pattern Stats table (4-row grid)", group=grpALN)
showALNErosion = input.bool(true, "Show Edge Erosion", group=grpALN, tooltip="Shows how the LonH/LonL break rate drops when the opposite side breaks first — the standout nqstats insight.")
erosionFullTable = input.bool(false, "Edge Erosion: full 4-pattern table", group=grpALN, tooltip="When off (default): shows a single condensed row for today's pattern only. When on: shows the full table with all 4 patterns.")
killSwitchThreshold = input.int(10, "Kill Switch threshold (percentage points)", minval=1, maxval=50, group=grpALN, tooltip="If LonH/LonL edge drops by this many percentage points when the opposite side breaks first, the Today's Read card shows a kill switch warning.")

grpSit = "Situation Read Panel"
showSituation   = input.bool(true,  "Show Situation Read panel (always-on master read)", group=grpSit)
sitMinSample    = input.int(20, "Min sample size for a stat to count", minval=5, maxval=200, group=grpSit, tooltip="Stats below this n are treated as 'no edge' and greyed in the verdict.")
sitConfPct      = input.float(60.0, "Confirmation threshold (%)", minval=50, maxval=90, step=1.0, group=grpSit, tooltip="A directional read must clear this hit-rate to count as a confirming signal in the verdict.")
showSitTargets  = input.bool(true,  "Show target ladder rows", group=grpSit)
targetMode = input.string("Strongest (highest AtAge%)", "Headline TARGET selection", options=["Strongest (highest AtAge%)","Nearest","Highest Cum%"], group=grpSit, tooltip="How the TARGET headline picks among live levels within the distance band. Strongest = best touch odds at current age. Nearest = closest. Highest Cum% = best all-life odds.")
targetBandATR = input.float(1.0, "TARGET distance band (× daily ATR)", minval=0.25, maxval=5.0, step=0.25, group=grpSit, tooltip="Only levels within this multiple of the 14-day daily ATR are considered 'reachable today' for the headline. Levels beyond it are ignored unless none qualify, in which case the nearest is shown flagged '(far)'.")

grpSSS = "SSS Sequence Engine"
enableSSS  = input.bool(true, "Enable SSS color-sequence engine", group=grpSSS, tooltip="Tracks Asia/London close-vs-open coloring and the AL to NY sequence edge. Used as the confirm/veto filter in the Situation panel.")
sssColorMode = input.string("Open→Close", "Color Definition", options=["Open→Close","Prior Close→Close"], group=grpSSS, tooltip="Open to Close: green if session close > session open. Prior Close to Close: green if close > prior session close.")
showSSSStats = input.bool(false, "Show SSS Sequence Stats section", group=grpSSS, tooltip="Historical NY-green rate for each Asia→London color bucket (G-G / G-R / R-G / R-R). The standalone SSS edge table.")
sssStatsMode = input.string("Today's bucket only", "SSS Stats Mode", options=["Today's bucket only","Full grid (all 4 buckets)"], group=grpSSS, tooltip="Today's bucket: one condensed row for the current AL sequence. Full grid: all four buckets with NY-green% and sample size.")

grpMaster = "Stats Tables (master switch)"
showAllStatsTables = input.bool(true, "Master switch for all stats sections", group=grpMaster, tooltip="Global on/off for every stats section below the Situation panel. When OFF, only the Situation Read panel shows regardless of individual toggles. When ON, each section's own toggle decides whether it shows.")

grpShade = "Session Shading"
showAsiaShade = input.bool(true, "Show Asia Box",   group=grpShade, inline="sA")
asiaBoxBg     = input.color(color.new(#9A8F84, 90), "BG",     group=grpShade, inline="sA")
asiaBoxBorder = input.color(color.new(#9A8F84, 55), "Border", group=grpShade, inline="sA")
showLonShade  = input.bool(true, "Show London Box", group=grpShade, inline="sL")
lonBoxBg      = input.color(color.new(#84968C, 90), "BG",     group=grpShade, inline="sL")
lonBoxBorder  = input.color(color.new(#84968C, 55), "Border", group=grpShade, inline="sL")
showNyShade   = input.bool(true, "Show NY Box",     group=grpShade, inline="sN")
nyBoxBg       = input.color(color.new(#838EA3, 90), "BG",     group=grpShade, inline="sN")
nyBoxBorder   = input.color(color.new(#838EA3, 55), "Border", group=grpShade, inline="sN")
boxBorderStyle = input.string("Solid", "Box Border Style", options=["Solid","Dashed","Dotted","None"], group=grpShade)
boxBorderWidth = input.int(1, "Box Border Width", minval=1, maxval=4, group=grpShade)
boxMaxKeep    = input.int(20, "Max Session Boxes to Keep (per session)", minval=1, maxval=200, group=grpShade, tooltip="Older boxes are removed to keep chart performant")
showMidlines  = input.bool(false, "Show 50% midline in each box", group=grpShade, tooltip="Draws a subtle dotted line at the 50% midpoint of each session's range, inside the session box. Useful for spotting reversion to the Asia/London mid.")
midlineCol    = input.color(color.new(#B0B0B0, 35), "Midline Color", group=grpShade, tooltip="Color/transparency of the 50% midlines. Dimmer than the H/L lines by default.")

grpShadeLbl = "Session Labels"
showSessionLabels = input.bool(true, "Show session name above each box", group=grpShadeLbl)
sessionLblPos = input.string("Top of box", "Label Position", options=["Top of box","Bottom of box","Top of chart"], group=grpShadeLbl)
sessionLblSize = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"], group=grpShadeLbl)
sessionLblTxtCol = input.color(color.white, "Label Text Color", group=grpShadeLbl, inline="slbl")
sessionLblBgCol  = input.color(color.new(#000000, 70), "Label BG", group=grpShadeLbl, inline="slbl")
asiaLblText = input.string("ASIA",   "Asia Label Text",   group=grpShadeLbl)
lonLblText  = input.string("LONDON", "London Label Text", group=grpShadeLbl)
nyLblText   = input.string("NY",     "NY Label Text",     group=grpShadeLbl)

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════
C_BG   = color.new(#000000, 0)
C_CELL = color.new(#0A0A0A, 0)
C_TXT  = color.white

// Semantic colors for verdict / direction / warning rows: green = positive, red = negative.
f_pos(int transp) => color.new(#1F8A38, transp)
f_neg(int transp) => color.new(#B71C1C, transp)

f_pct_bg(pct) =>
    na(pct) ? C_CELL : pct >= 80 ? color.new(#1F8A38, 0) : pct >= 65 ? color.new(#1F8A38, 30) : pct >= 50 ? color.new(#1F8A38, 60) : pct >= 35 ? C_CELL : pct >= 20 ? color.new(#B71C1C, 60) : color.new(#B71C1C, 30)

f_cell_text(int n, int total) =>
    if total == 0
        "—"
    else
        pct = 100.0 * n / total
        pctStr = str.tostring(pct, "#.0") + "%"
        if not showCounts
            pctStr
        else
            countFormat == "n only" ? str.tostring(n) : countFormat == "n/total" ? str.tostring(n) + "/" + str.tostring(total) : pctStr + " (" + str.tostring(n) + ")"

txtSize() =>
    tableTextSize == "Large" ? size.large : tableTextSize == "Normal" ? size.normal : size.small

getPos() =>
    tablePosition == "Top Right" ? position.top_right : tablePosition == "Top Left" ? position.top_left : tablePosition == "Bottom Right" ? position.bottom_right : tablePosition == "Bottom Left" ? position.bottom_left : tablePosition == "Middle Right" ? position.middle_right : position.middle_left

resolveStyle(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

labelStyleConst = label.style_label_left

var int[]  aln_pattern  = array.new_int(0)
var bool[] aln_brAsiaH  = array.new_bool(0)
var bool[] aln_brAsiaL  = array.new_bool(0)
var bool[] aln_brLonH   = array.new_bool(0)
var bool[] aln_brLonL   = array.new_bool(0)
var int[]  aln_firstBr  = array.new_int(0)

alnPatternName(int p) =>
    p == 0 ? "LEA" : p == 1 ? "AEL" : p == 2 ? "LPU" : p == 3 ? "LPD" : "—"
alnPatternFullName(int p) =>
    p == 0 ? "London Engulfs Asia" : p == 1 ? "Asia Engulfs London" : p == 2 ? "London Partial Up" : p == 3 ? "London Partial Down" : "Unknown"

alnCountPattern(int p) =>
    cnt = 0
    cAH = 0
    cAL = 0
    cLH = 0
    cLL = 0
    cBoth = 0
    if array.size(aln_pattern) > 0
        for i = 0 to array.size(aln_pattern) - 1
            if array.get(aln_pattern, i) == p
                cnt += 1
                if array.get(aln_brAsiaH, i)
                    cAH += 1
                if array.get(aln_brAsiaL, i)
                    cAL += 1
                if array.get(aln_brLonH, i)
                    cLH += 1
                if array.get(aln_brLonL, i)
                    cLL += 1
                if array.get(aln_brLonH, i) and array.get(aln_brLonL, i)
                    cBoth += 1
    [cnt, cAH, cAL, cLH, cLL, cBoth]

alnCountConditional(int p, int firstIdx, int otherIdx) =>
    totalFirst = 0
    thenOther = 0
    if array.size(aln_pattern) > 0
        for i = 0 to array.size(aln_pattern) - 1
            if array.get(aln_pattern, i) == p and array.get(aln_firstBr, i) == firstIdx
                totalFirst += 1
                otherBroke = otherIdx == 0 ? array.get(aln_brAsiaH, i) : otherIdx == 1 ? array.get(aln_brAsiaL, i) : otherIdx == 2 ? array.get(aln_brLonH, i) : array.get(aln_brLonL, i)
                if otherBroke
                    thenOther += 1
    [totalFirst, thenOther]

alnPct(int n, int total) =>
    total == 0 ? na : 100.0 * n / total

mod_(h, m) => h * 60 + m
curMin = hour(time, tzInput) * 60 + minute(time, tzInput)

// Daily ATR (14) for the TARGET distance band — independent of chart timeframe.
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off)

asiaStart_ = mod_(asiaStartH, asiaStartM)
asiaEnd_   = mod_(asiaEndH, asiaEndM)
lonStart_  = mod_(lonStartH, lonStartM)
lonEnd_    = mod_(lonEndH, lonEndM)
nyStart_   = mod_(nyStartH, nyStartM)
nyEnd_     = mod_(nyEndH, nyEndM)

inSess(startM, endM) =>
    startM <= endM ? (curMin >= startM and curMin < endM) : (curMin >= startM or curMin < endM)

inAsia   = inSess(asiaStart_, asiaEnd_)
inLondon = inSess(lonStart_, lonEnd_)
inNY     = inSess(nyStart_, nyEnd_)

asiaJustStarted   = inAsia and not inAsia[1]
asiaJustEnded     = not inAsia and inAsia[1]
londonJustStarted = inLondon and not inLondon[1]
londonJustEnded   = not inLondon and inLondon[1]
nyJustStarted     = inNY and not inNY[1]
nyJustEnded       = not inNY and inNY[1]

// Stats gate: when start/end dates are set, only sessions within the window feed
// statistics. Keyed to the current bar's time (checked at NY-close finalize).
// Lets you pin a fixed sample for CSV/Python reconciliation.
statsActive = (not useStatsStart or time >= statsStartDate) and (not useStatsEnd or time <= statsEndDate)

var float asiaHigh = na
var float asiaLow  = na
var float lonHigh  = na
var float lonLow   = na

if asiaJustStarted
    asiaHigh := high
    asiaLow  := low
if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

if londonJustStarted
    lonHigh := high
    lonLow  := low
if inLondon
    lonHigh := math.max(lonHigh, high)
    lonLow  := math.min(lonLow, low)

var float nyHigh = na
var float nyLow  = na
if nyJustStarted
    nyHigh := high
    nyLow  := low
if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

nyDayStart_ = nyDayWindowMode == "Use custom RTH (09:30-16:00 ET)" ? mod_(9, 30) : nyDayWindowMode == "Custom hours" ? mod_(nyDayStartH, nyDayStartM) : nyStart_
nyDayEnd_   = nyDayWindowMode == "Use custom RTH (09:30-16:00 ET)" ? mod_(16, 0)  : nyDayWindowMode == "Custom hours" ? mod_(nyDayEndH, nyDayEndM)     : nyEnd_

inNyDay = inSess(nyDayStart_, nyDayEnd_)
nyDayJustStarted = inNyDay and not inNyDay[1]
nyDayJustEnded   = not inNyDay and inNyDay[1]

var float nyDayHigh = na
var float nyDayLow  = na
if nyDayJustStarted
    nyDayHigh := high
    nyDayLow  := low
if inNyDay
    nyDayHigh := math.max(nyDayHigh, high)
    nyDayLow  := math.min(nyDayLow, low)

// ════════════════════════════════════════════════════════════════════════════
// SESSION SHADING BOXES
// ════════════════════════════════════════════════════════════════════════════
resolveBoxStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

boxBorderStyleConst = resolveBoxStyle(boxBorderStyle)
boxBorderWidthEff = boxBorderStyle == "None" ? 0 : boxBorderWidth

resolveSessLblSize() =>
    sessionLblSize == "Tiny" ? size.tiny : sessionLblSize == "Small" ? size.small : sessionLblSize == "Normal" ? size.normal : size.large

sessLblY(top, bottom) =>
    sessionLblPos == "Bottom of box" ? bottom : top
sessLblStyle() =>
    sessionLblPos == "Bottom of box" ? label.style_label_up : label.style_label_down

var box   asiaLiveBox = na
var label asiaLiveLbl = na
var int   asiaStartBar = na
var box[] asiaBoxHistory = array.new_box(0)
var label[] asiaLblHistory = array.new_label(0)

var box   lonLiveBox = na
var label lonLiveLbl = na
var int   lonStartBar = na
var box[] lonBoxHistory = array.new_box(0)
var label[] lonLblHistory = array.new_label(0)

var box   nyLiveBox = na
var label nyLiveLbl = na
var int   nyStartBar = na
var box[] nyBoxHistory = array.new_box(0)
var label[] nyLblHistory = array.new_label(0)

// 50% midline state — one live line per session + history, mirrors the box pattern
var line   asiaLiveMid = na
var line[] asiaMidHistory = array.new_line(0)
var line   lonLiveMid = na
var line[] lonMidHistory = array.new_line(0)
var line   nyLiveMid = na
var line[] nyMidHistory = array.new_line(0)

pruneBoxes(boxArr) =>
    while array.size(boxArr) > boxMaxKeep
        oldB = array.shift(boxArr)
        if not na(oldB)
            box.delete(oldB)
pruneLabels(lblArr) =>
    while array.size(lblArr) > boxMaxKeep
        oldL = array.shift(lblArr)
        if not na(oldL)
            label.delete(oldL)
pruneLines(lnArr) =>
    while array.size(lnArr) > boxMaxKeep
        oldL = array.shift(lnArr)
        if not na(oldL)
            line.delete(oldL)

updateSessLabel(lbl, startBar, endBar, top, bottom, txt) =>
    midBar = math.round((startBar + endBar) / 2)
    rng = top - bottom
    yPos = sessionLblPos == "Top of chart" ? top + rng * 0.15 : sessLblY(top, bottom)
    lblStyle = sessionLblPos == "Top of chart" ? label.style_label_down : sessLblStyle()
    label.set_x(lbl, midBar)
    label.set_y(lbl, yPos)
    label.set_text(lbl, txt)
    label.set_style(lbl, lblStyle)

// Asia
if showAsiaShade and inAsia and not na(asiaHigh) and not na(asiaLow)
    if na(asiaLiveBox)
        asiaStartBar := bar_index
        asiaLiveBox := box.new(bar_index, asiaHigh, bar_index, asiaLow, bgcolor=asiaBoxBg, border_color=asiaBoxBorder, border_width=boxBorderWidthEff, border_style=boxBorderStyleConst)
        if showSessionLabels
            asiaLiveLbl := label.new(bar_index, asiaHigh, asiaLblText, color=sessionLblBgCol, textcolor=sessionLblTxtCol, style=sessLblStyle(), size=resolveSessLblSize())
        if showMidlines
            asiaLiveMid := line.new(bar_index, (asiaHigh+asiaLow)/2, bar_index, (asiaHigh+asiaLow)/2, color=midlineCol, width=1, style=line.style_dotted)
    else
        box.set_top(asiaLiveBox, asiaHigh)
        box.set_bottom(asiaLiveBox, asiaLow)
        box.set_right(asiaLiveBox, bar_index)
        if showSessionLabels and not na(asiaLiveLbl)
            updateSessLabel(asiaLiveLbl, asiaStartBar, bar_index, asiaHigh, asiaLow, asiaLblText)
        if showMidlines and not na(asiaLiveMid)
            mid = (asiaHigh+asiaLow)/2
            line.set_y1(asiaLiveMid, mid)
            line.set_y2(asiaLiveMid, mid)
            line.set_x2(asiaLiveMid, bar_index)
if showAsiaShade and asiaJustEnded and not na(asiaLiveBox)
    array.push(asiaBoxHistory, asiaLiveBox)
    pruneBoxes(asiaBoxHistory)
    asiaLiveBox := na
    if not na(asiaLiveLbl)
        array.push(asiaLblHistory, asiaLiveLbl)
        pruneLabels(asiaLblHistory)
        asiaLiveLbl := na
    if not na(asiaLiveMid)
        array.push(asiaMidHistory, asiaLiveMid)
        pruneLines(asiaMidHistory)
        asiaLiveMid := na

// London
if showLonShade and inLondon and not na(lonHigh) and not na(lonLow)
    if na(lonLiveBox)
        lonStartBar := bar_index
        lonLiveBox := box.new(bar_index, lonHigh, bar_index, lonLow, bgcolor=lonBoxBg, border_color=lonBoxBorder, border_width=boxBorderWidthEff, border_style=boxBorderStyleConst)
        if showSessionLabels
            lonLiveLbl := label.new(bar_index, lonHigh, lonLblText, color=sessionLblBgCol, textcolor=sessionLblTxtCol, style=sessLblStyle(), size=resolveSessLblSize())
        if showMidlines
            lonLiveMid := line.new(bar_index, (lonHigh+lonLow)/2, bar_index, (lonHigh+lonLow)/2, color=midlineCol, width=1, style=line.style_dotted)
    else
        box.set_top(lonLiveBox, lonHigh)
        box.set_bottom(lonLiveBox, lonLow)
        box.set_right(lonLiveBox, bar_index)
        if showSessionLabels and not na(lonLiveLbl)
            updateSessLabel(lonLiveLbl, lonStartBar, bar_index, lonHigh, lonLow, lonLblText)
        if showMidlines and not na(lonLiveMid)
            mid = (lonHigh+lonLow)/2
            line.set_y1(lonLiveMid, mid)
            line.set_y2(lonLiveMid, mid)
            line.set_x2(lonLiveMid, bar_index)
if showLonShade and londonJustEnded and not na(lonLiveBox)
    array.push(lonBoxHistory, lonLiveBox)
    pruneBoxes(lonBoxHistory)
    lonLiveBox := na
    if not na(lonLiveLbl)
        array.push(lonLblHistory, lonLiveLbl)
        pruneLabels(lonLblHistory)
        lonLiveLbl := na
    if not na(lonLiveMid)
        array.push(lonMidHistory, lonLiveMid)
        pruneLines(lonMidHistory)
        lonLiveMid := na

// NY
if showNyShade and inNY and not na(nyHigh) and not na(nyLow)
    if na(nyLiveBox)
        nyStartBar := bar_index
        nyLiveBox := box.new(bar_index, nyHigh, bar_index, nyLow, bgcolor=nyBoxBg, border_color=nyBoxBorder, border_width=boxBorderWidthEff, border_style=boxBorderStyleConst)
        if showSessionLabels
            nyLiveLbl := label.new(bar_index, nyHigh, nyLblText, color=sessionLblBgCol, textcolor=sessionLblTxtCol, style=sessLblStyle(), size=resolveSessLblSize())
        if showMidlines
            nyLiveMid := line.new(bar_index, (nyHigh+nyLow)/2, bar_index, (nyHigh+nyLow)/2, color=midlineCol, width=1, style=line.style_dotted)
    else
        box.set_top(nyLiveBox, nyHigh)
        box.set_bottom(nyLiveBox, nyLow)
        box.set_right(nyLiveBox, bar_index)
        if showSessionLabels and not na(nyLiveLbl)
            updateSessLabel(nyLiveLbl, nyStartBar, bar_index, nyHigh, nyLow, nyLblText)
        if showMidlines and not na(nyLiveMid)
            mid = (nyHigh+nyLow)/2
            line.set_y1(nyLiveMid, mid)
            line.set_y2(nyLiveMid, mid)
            line.set_x2(nyLiveMid, bar_index)
if showNyShade and nyJustEnded and not na(nyLiveBox)
    array.push(nyBoxHistory, nyLiveBox)
    pruneBoxes(nyBoxHistory)
    nyLiveBox := na
    if not na(nyLiveLbl)
        array.push(nyLblHistory, nyLiveLbl)
        pruneLabels(nyLblHistory)
        nyLiveLbl := na
    if not na(nyLiveMid)
        array.push(nyMidHistory, nyLiveMid)
        pruneLines(nyMidHistory)
        nyLiveMid := na

// ════════════════════════════════════════════════════════════════════════════
// CARRYOVER ARRAYS + STATS
// ════════════════════════════════════════════════════════════════════════════
var int[]   co_type   = array.new_int(0)
var float[] co_price  = array.new_float(0)
var int[]   co_birthSession = array.new_int(0)
var line[]  co_line   = array.new_line(0)
var label[] co_label  = array.new_label(0)

var bool[]  co_wickTested  = array.new_bool(0)
var int[]   co_wickAge     = array.new_int(0)
var bool[]  co_closeTested = array.new_bool(0)
var int[]   co_closeAge    = array.new_int(0)
var bool[]  co_isPending   = array.new_bool(0)
var int[]   co_sideAtOpen  = array.new_int(0)

var int sessionNum = 0

var int   curPattern = -1
var float curAsiaH   = na
var float curAsiaL   = na
var float curLonH    = na
var float curLonL    = na

var bool brokeAsiaH_today = false
var bool brokeAsiaL_today = false
var bool brokeLonH_today  = false
var bool brokeLonL_today  = false
var int  firstBreak_today = -1

var int[] stats_totalFinalized = array.new_int(6, 0)
var int[] stats_wickByAge      = array.new_int(36, 0)
var int[] stats_closeByAge     = array.new_int(36, 0)

ageBucket(sessionsToTest) =>
    sessionsToTest <= 1 ? 0 : sessionsToTest <= 2 ? 1 : sessionsToTest <= 3 ? 2 : sessionsToTest <= 4 ? 3 : sessionsToTest <= 5 ? 4 : -1

levelName(int ct) =>
    ct == 0 ? "Asia H" : ct == 1 ? "Asia L" : ct == 2 ? "Lon H" : ct == 3 ? "Lon L" : ct == 4 ? "NY H" : "NY L"
levelColor(int ct) =>
    ct == 0 ? asiaHCol : ct == 1 ? asiaLCol : ct == 2 ? lonHCol : ct == 3 ? lonLCol : ct == 4 ? nyHCol : nyLCol
levelIsHigh(int ct) =>
    ct == 0 or ct == 2 or ct == 4

recordFinalized(levelType, testedByWick, sWick, testedByClose, sClose) =>
    wB = testedByWick ? ageBucket(sWick) : -1
    cB = testedByClose ? ageBucket(sClose) : -1
    array.set(stats_totalFinalized, levelType, array.get(stats_totalFinalized, levelType) + 1)
    if wB >= 0
        for b = wB to 5
            idx = levelType * 6 + b
            array.set(stats_wickByAge, idx, array.get(stats_wickByAge, idx) + 1)
    if cB >= 0
        for b = cB to 5
            idx = levelType * 6 + b
            array.set(stats_closeByAge, idx, array.get(stats_closeByAge, idx) + 1)

addCarryover(int type, float price, string name, color col, string styleStr) =>
    ln = showLines ? line.new(bar_index - (extendLeft ? 50 : 0), price, bar_index + lineExtendBars, price, color=col, width=lineWidth, style=resolveStyle(styleStr)) : na
    lb = showLines and showLineLabels ? label.new(bar_index + lineExtendBars, price, name, style=labelStyleConst, color=color.new(color.black, 100), textcolor=col, size=size.small) : na
    bornPending = not (type == 4 or type == 5)
    array.push(co_type, type)
    array.push(co_price, price)
    array.push(co_birthSession, sessionNum)
    array.push(co_line, ln)
    array.push(co_label, lb)
    array.push(co_wickTested, false)
    array.push(co_wickAge, 0)
    array.push(co_closeTested, false)
    array.push(co_closeAge, 0)
    array.push(co_isPending, bornPending)
    array.push(co_sideAtOpen, 0)

hitWindowOpen = hitGateMode == "NY only" ? nyJustStarted : hitGateMode == "NY + London" ? (londonJustStarted and not inNY[1]) or (nyJustStarted and not inLondon[1]) : false

processCarryovers() =>
    inHitWindow = hitGateMode == "NY only" ? inNY : hitGateMode == "NY + London" ? (inNY or inLondon) : true
    if hitWindowOpen and array.size(co_type) > 0
        for i = 0 to array.size(co_type) - 1
            cp = array.get(co_price, i)
            side = cp > close ? 1 : cp < close ? -1 : 0
            array.set(co_sideAtOpen, i, side)
    if inHitWindow and array.size(co_type) > 0
        for i = array.size(co_type) - 1 to 0
            ct = array.get(co_type, i)
            cp = array.get(co_price, i)
            age = sessionNum - array.get(co_birthSession, i)
            side = array.get(co_sideAtOpen, i)
            if side == 0
                side := cp > close ? 1 : cp < close ? -1 : 0
                array.set(co_sideAtOpen, i, side)
            wickHit = side == 1 ? (high >= cp) : side == -1 ? (low <= cp) : false
            closeHit = side == 1 ? (close >= cp) : side == -1 ? (close <= cp) : false
            if wickHit and not array.get(co_wickTested, i)
                array.set(co_wickTested, i, true)
                array.set(co_wickAge, i, age == 0 ? 1 : age)
                if alertOnWick
                    alert(levelName(ct) + " Wick Break @ " + str.tostring(cp, format.mintick), alert.freq_once_per_bar)
            if closeHit and not array.get(co_closeTested, i)
                array.set(co_closeTested, i, true)
                array.set(co_closeAge, i, age == 0 ? 1 : age)
                if alertOnClose
                    alert(levelName(ct) + " Close Break @ " + str.tostring(cp, format.mintick), alert.freq_once_per_bar)

processCarryovers()

if asiaJustEnded
    if trackAsiaH and not na(asiaHigh)
        addCarryover(0, asiaHigh, "Asia H", asiaHCol, asiaHStyle)
    if trackAsiaL and not na(asiaLow)
        addCarryover(1, asiaLow, "Asia L", asiaLCol, asiaLStyle)

if londonJustEnded
    if trackLonH and not na(lonHigh)
        addCarryover(2, lonHigh, "Lon H", lonHCol, lonHStyle)
    if trackLonL and not na(lonLow)
        addCarryover(3, lonLow, "Lon L", lonLCol, lonLStyle)

if nyDayJustEnded
    if trackNyH and not na(nyDayHigh)
        addCarryover(4, nyDayHigh, "NY H", nyHCol, nyHStyle)
    if trackNyL and not na(nyDayLow)
        addCarryover(5, nyDayLow, "NY L", nyLCol, nyLStyle)

if enableALN and londonJustEnded and not na(asiaHigh) and not na(asiaLow) and not na(lonHigh) and not na(lonLow)
    curAsiaH := asiaHigh
    curAsiaL := asiaLow
    curLonH  := lonHigh
    curLonL  := lonLow
    if lonHigh > asiaHigh and lonLow < asiaLow
        curPattern := 0
    else if lonHigh < asiaHigh and lonLow > asiaLow
        curPattern := 1
    else if lonHigh > asiaHigh and lonLow >= asiaLow
        curPattern := 2
    else if lonLow < asiaLow and lonHigh <= asiaHigh
        curPattern := 3
    else
        curPattern := -1
    brokeAsiaH_today := false
    brokeAsiaL_today := false
    brokeLonH_today  := false
    brokeLonL_today  := false
    firstBreak_today := -1

if enableALN and inNY and curPattern >= 0
    // nqstats parity: a level "breaks" when NY trades through it at any point in
    // the session (high >= level for a high, low <= level for a low). No
    // directional/side gating — matches nqstats "did NY break London H/L" exactly.
    if not brokeAsiaH_today and not na(curAsiaH)
        if high >= curAsiaH
            brokeAsiaH_today := true
            if firstBreak_today == -1
                firstBreak_today := 0
    if not brokeAsiaL_today and not na(curAsiaL)
        if low <= curAsiaL
            brokeAsiaL_today := true
            if firstBreak_today == -1
                firstBreak_today := 1
    if not brokeLonH_today and not na(curLonH)
        if high >= curLonH
            brokeLonH_today := true
            if firstBreak_today == -1
                firstBreak_today := 2
    if not brokeLonL_today and not na(curLonL)
        if low <= curLonL
            brokeLonL_today := true
            if firstBreak_today == -1
                firstBreak_today := 3

if enableALN and nyJustEnded and curPattern >= 0 and statsActive
    array.push(aln_pattern,  curPattern)
    array.push(aln_brAsiaH,  brokeAsiaH_today)
    array.push(aln_brAsiaL,  brokeAsiaL_today)
    array.push(aln_brLonH,   brokeLonH_today)
    array.push(aln_brLonL,   brokeLonL_today)
    array.push(aln_firstBr,  firstBreak_today)

// ════════════════════════════════════════════════════════════════════════════
// SSS SEQUENCE ENGINE
// ════════════════════════════════════════════════════════════════════════════
var float sssAsiaOpen  = na
var float sssAsiaClose = na
var float sssLonOpen   = na
var float sssLonClose  = na
var float sssPrevAsiaClose = na
var float sssPrevLonClose  = na

if asiaJustStarted
    sssAsiaOpen := open
if inAsia
    sssAsiaClose := close
if londonJustStarted
    sssLonOpen := open
if inLondon
    sssLonClose := close

sssAsiaGreen() =>
    sssColorMode == "Open→Close" ? (sssAsiaClose > sssAsiaOpen) : na(sssPrevAsiaClose) ? (sssAsiaClose > sssAsiaOpen) : (sssAsiaClose > sssPrevAsiaClose)
sssLonGreen() =>
    sssColorMode == "Open→Close" ? (sssLonClose > sssLonOpen) : na(sssPrevLonClose) ? (sssLonClose > sssLonOpen) : (sssLonClose > sssPrevLonClose)

var int sssTodayAsiaG = na
var int sssTodayLonG  = na

if asiaJustEnded and not na(sssAsiaClose)
    sssTodayAsiaG := sssAsiaGreen() ? 1 : 0
    sssPrevAsiaClose := sssAsiaClose
if londonJustEnded and not na(sssLonClose)
    sssTodayLonG := sssLonGreen() ? 1 : 0
    sssPrevLonClose := sssLonClose

var int[]  sss_alBucket = array.new_int(0)
var bool[] sss_nyGreen  = array.new_bool(0)

var float sssNyOpen  = na
var float sssNyClose = na
var float sssPrevNyClose = na
if nyJustStarted
    sssNyOpen := open
if inNY
    sssNyClose := close

if enableSSS and nyJustEnded and not na(sssTodayAsiaG) and not na(sssTodayLonG) and not na(sssNyClose)
    nyG = sssColorMode == "Open→Close" ? (sssNyClose > sssNyOpen) : na(sssPrevNyClose) ? (sssNyClose > sssNyOpen) : (sssNyClose > sssPrevNyClose)
    sssPrevNyClose := sssNyClose
    bucket = (sssTodayAsiaG == 1 ? 2 : 0) + (sssTodayLonG == 1 ? 1 : 0)
    if statsActive
        array.push(sss_alBucket, bucket)
        array.push(sss_nyGreen, nyG)

if asiaJustStarted
    sssTodayAsiaG := na
    sssTodayLonG  := na
    // Clear yesterday's ALN pattern at the start of a new cycle. It stays
    // cleared until TODAY's London closes and reclassifies, so the read
    // correctly shows "Awaiting London close" instead of a stale pattern.
    curPattern := -1
    curAsiaH := na
    curAsiaL := na
    curLonH  := na
    curLonL  := na
    brokeAsiaH_today := false
    brokeAsiaL_today := false
    brokeLonH_today  := false
    brokeLonL_today  := false
    firstBreak_today := -1

sssBucketStats(int bucket) =>
    n = 0
    g = 0
    if array.size(sss_alBucket) > 0
        for i = 0 to array.size(sss_alBucket) - 1
            if array.get(sss_alBucket, i) == bucket
                n += 1
                if array.get(sss_nyGreen, i)
                    g += 1
    pct = n == 0 ? na : 100.0 * g / n
    [n, pct]

sssBucketName(int bucket) =>
    a = bucket >= 2 ? "G" : "R"
    l = (bucket % 2) == 1 ? "G" : "R"
    a + "-" + l

sssLiveRead() =>
    haveRead = enableSSS and not na(sssTodayAsiaG) and not na(sssTodayLonG)
    bucket = haveRead ? (sssTodayAsiaG == 1 ? 2 : 0) + (sssTodayLonG == 1 ? 1 : 0) : -1
    float pct = na
    n = 0
    leanTxt = "—"
    leanDir = 0
    if haveRead
        [bn, bp] = sssBucketStats(bucket)
        n := bn
        pct := bp
        if not na(bp) and bn >= sitMinSample
            if bp >= sitConfPct
                leanTxt := "NY Green " + str.tostring(bp, "#.0") + "% (n=" + str.tostring(bn) + ")"
                leanDir := 1
            else if bp <= (100.0 - sitConfPct)
                leanTxt := "NY Red " + str.tostring(100.0 - bp, "#.0") + "% (n=" + str.tostring(bn) + ")"
                leanDir := -1
            else
                leanTxt := "No edge (" + str.tostring(bp, "#.0") + "%, n=" + str.tostring(bn) + ")"
                leanDir := 0
        else
            leanTxt := "Low sample (n=" + str.tostring(bn) + ")"
            leanDir := 0
    [haveRead, bucket, pct, n, leanTxt, leanDir]

// ════════════════════════════════════════════════════════════════════════════
// FINALIZE AT NY CLOSE
// ════════════════════════════════════════════════════════════════════════════
if nyJustEnded
    sessionNum := sessionNum + 1
    if array.size(co_type) > 0
        for i = array.size(co_type) - 1 to 0
            ct = array.get(co_type, i)
            age = sessionNum - array.get(co_birthSession, i)
            wickT = array.get(co_wickTested, i)
            closeT = array.get(co_closeTested, i)
            wickAge = array.get(co_wickAge, i)
            closeAge = array.get(co_closeAge, i)
            wasPending = array.get(co_isPending, i)
            pendingBroken = wasPending and wickT
            agedOut = age >= maxAge
            fullyBroken = wickT and closeT
            if pendingBroken or agedOut or fullyBroken
                if statsActive
                    recordFinalized(ct, wickT, wickAge, closeT, closeAge)
                if not na(array.get(co_line, i))
                    line.delete(array.get(co_line, i))
                if not na(array.get(co_label, i))
                    label.delete(array.get(co_label, i))
                array.remove(co_type, i)
                array.remove(co_price, i)
                array.remove(co_birthSession, i)
                array.remove(co_line, i)
                array.remove(co_label, i)
                array.remove(co_wickTested, i)
                array.remove(co_wickAge, i)
                array.remove(co_closeTested, i)
                array.remove(co_closeAge, i)
                array.remove(co_isPending, i)
                array.remove(co_sideAtOpen, i)
            else
                array.set(co_isPending, i, false)

// ════════════════════════════════════════════════════════════════════════════
// VISUAL UPDATES (with close-label merging)
// ════════════════════════════════════════════════════════════════════════════
if barstate.islast and showLines and array.size(co_type) > 0
    nLev = array.size(co_type)
    // First pass: update all line geometry/colors
    for i = 0 to nLev - 1
        ct = array.get(co_type, i)
        cp = array.get(co_price, i)
        age = sessionNum - array.get(co_birthSession, i)
        isPending = array.get(co_isPending, i)
        broken = array.get(co_wickTested, i)
        ln = array.get(co_line, i)
        if not na(ln)
            if hideBroken and broken
                // Hide broken level's line entirely
                line.set_color(ln, color.new(color.black, 100))
            else
                line.set_x2(ln, bar_index + lineExtendBars)
                if fadeWithAge and not isPending
                    baseCol = levelColor(ct)
                    fade = math.min(75, age * 7)
                    line.set_color(ln, color.new(baseCol, fade))
                else
                    line.set_color(ln, levelColor(ct))

    // Second pass: label handling. If merging is off, simple per-label update.
    if showLineLabels
        if not mergeCloseLabels
            for i = 0 to nLev - 1
                ct = array.get(co_type, i)
                cp = array.get(co_price, i)
                age = sessionNum - array.get(co_birthSession, i)
                isPending = array.get(co_isPending, i)
                broken = array.get(co_wickTested, i)
                lb = array.get(co_label, i)
                if not na(lb)
                    if hideBroken and broken
                        label.set_text(lb, "")
                    else
                        name = levelName(ct)
                        hitText = showHitStatus ? (broken ? " ✓" : "") : ""
                        ageText = isPending ? "Today" : "D-" + str.tostring(age + 1)
                        label.set_text(lb, name + " " + ageText + "  " + str.tostring(cp, format.mintick) + hitText)
                        label.set_textcolor(lb, levelColor(ct))
                        label.set_x(lb, bar_index + lineExtendBars)
                        label.set_y(lb, cp)
        else
            // Merge mode: cluster levels within threshold, newest-level anchors label.
            // assigned[i] = true once a level has been folded into a cluster.
            thresh = close * mergeThreshPct / 100.0
            assigned = array.new_bool(nLev, false)
            // When hideBroken is on, pre-mark broken levels as assigned (skip from
            // clustering) and blank their labels so they vanish from the chart.
            if hideBroken
                for i = 0 to nLev - 1
                    if array.get(co_wickTested, i)
                        array.set(assigned, i, true)
                        lb = array.get(co_label, i)
                        if not na(lb)
                            label.set_text(lb, "")
            for i = 0 to nLev - 1
                if not array.get(assigned, i)
                    // Build cluster of all unassigned levels within thresh of level i's price
                    members = array.new_int(0)
                    array.push(members, i)
                    array.set(assigned, i, true)
                    cpi = array.get(co_price, i)
                    for j = 0 to nLev - 1
                        if j != i and not array.get(assigned, j)
                            if math.abs(array.get(co_price, j) - cpi) <= thresh
                                array.push(members, j)
                                array.set(assigned, j, true)
                    // Identify newest member (smallest age = newest; pending = age 0-ish)
                    // and price range across the cluster.
                    newestIdx = array.get(members, 0)
                    newestAge = sessionNum - array.get(co_birthSession, newestIdx)
                    minPx = array.get(co_price, newestIdx)
                    maxPx = minPx
                    for m = 0 to array.size(members) - 1
                        mi = array.get(members, m)
                        mAge = sessionNum - array.get(co_birthSession, mi)
                        mPx = array.get(co_price, mi)
                        if mAge < newestAge
                            newestAge := mAge
                            newestIdx := mi
                        minPx := math.min(minPx, mPx)
                        maxPx := math.max(maxPx, mPx)
                    // Sort members newest-first for the name list (simple selection sort by age)
                    sz_m = array.size(members)
                    if sz_m > 1
                        for a = 0 to sz_m - 2
                            for b = a + 1 to sz_m - 1
                                ageA = sessionNum - array.get(co_birthSession, array.get(members, a))
                                ageB = sessionNum - array.get(co_birthSession, array.get(members, b))
                                if ageB < ageA
                                    tmp = array.get(members, a)
                                    array.set(members, a, array.get(members, b))
                                    array.set(members, b, tmp)
                    // Build merged name string + hit marks
                    namesTxt = ""
                    anyHit = false
                    for m = 0 to sz_m - 1
                        mi = array.get(members, m)
                        namesTxt := namesTxt + (m == 0 ? "" : " / ") + levelName(array.get(co_type, mi))
                        if array.get(co_wickTested, mi)
                            anyHit := true
                    hitMark = showHitStatus and anyHit ? " ✓" : ""
                    // Price text: range if spread, single if identical (within 1 tick)
                    oneTick = syminfo.mintick
                    priceTxt = (maxPx - minPx) <= oneTick ? str.tostring(array.get(co_price, newestIdx), format.mintick) : str.tostring(minPx, format.mintick) + "–" + str.tostring(maxPx, format.mintick)
                    newestAgePending = array.get(co_isPending, newestIdx)
                    ageTxt = newestAgePending ? "Today" : "D-" + str.tostring(newestAge + 1)
                    mergedTxt = namesTxt + " " + ageTxt + "  " + priceTxt + hitMark
                    // Anchor merged label on the newest level's own label object; blank the rest.
                    isMerged = sz_m > 1
                    for m = 0 to sz_m - 1
                        mi = array.get(members, m)
                        lb = array.get(co_label, mi)
                        if not na(lb)
                            if mi == newestIdx
                                label.set_text(lb, mergedTxt)
                                label.set_textcolor(lb, isMerged ? color.white : levelColor(array.get(co_type, mi)))
                                label.set_x(lb, bar_index + lineExtendBars)
                                label.set_y(lb, array.get(co_price, newestIdx))
                            else
                                // Hide the non-anchor labels in the cluster
                                label.set_text(lb, "")
                                label.set_x(lb, bar_index + lineExtendBars)
                                label.set_y(lb, array.get(co_price, mi))


// ════════════════════════════════════════════════════════════════════════════
// TABLE
// ════════════════════════════════════════════════════════════════════════════
var table t = table.new(getPos(), 8, 90, bgcolor=C_BG, border_color=color.new(#1F1F1F, 0), border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 7, 89)
    sz = txtSize()
    r = 0
    table.cell(t, 0, r, "CARRYOVER LEVELS TRACKER · " + str.tostring(array.size(aln_pattern)) + " days", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
    table.merge_cells(t, 0, r, 7, r)
    r += 1

    // ════════════════════════════════════════════════════════════════════════
    // SITUATION READ PANEL (always-on master read)
    // ════════════════════════════════════════════════════════════════════════
    if showSituation
        table.cell(t, 0, r, "◆ SITUATION READ — LIVE", text_color=color.white, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 7, r)
        r += 1

        aln_have = enableALN and curPattern >= 0
        aln_thesisTxt = "—"
        aln_dir = 0
        aln_killed = false
        aln_armed = false
        float pLH = na
        float pLL = na
        float pAH = na
        float pAL = na
        aln_n = 0
        if aln_have
            [tCnt, tAH, tAL, tLH, tLL, tBoth] = alnCountPattern(curPattern)
            aln_n := tCnt
            pAH := alnPct(tAH, tCnt)
            pAL := alnPct(tAL, tCnt)
            pLH := alnPct(tLH, tCnt)
            pLL := alnPct(tLL, tCnt)
            if curPattern == 2
                aln_dir := 1
                aln_thesisTxt := "LPU — bullish lean, target Lon H"
                [nLL1, nLLthenLH] = alnCountConditional(2, 3, 2)
                pCond = alnPct(nLLthenLH, nLL1)
                // Fire only when the killing condition has actually triggered today:
                // for LPU that's Lon L breaking FIRST (firstBreak_today == 3).
                erosionSevere = not na(pCond) and not na(pLH) and (pLH - pCond) >= killSwitchThreshold
                if erosionSevere and firstBreak_today == 3
                    aln_killed := true
                else if erosionSevere and firstBreak_today == -1
                    aln_armed := true
            else if curPattern == 3
                aln_dir := -1
                aln_thesisTxt := "LPD — bearish lean, target Lon L"
                [nLH1, nLHthenLL] = alnCountConditional(3, 2, 3)
                pCond = alnPct(nLHthenLL, nLH1)
                // For LPD the killing condition is Lon H breaking FIRST (firstBreak_today == 2).
                erosionSevere = not na(pCond) and not na(pLL) and (pLL - pCond) >= killSwitchThreshold
                if erosionSevere and firstBreak_today == 2
                    aln_killed := true
                else if erosionSevere and firstBreak_today == -1
                    aln_armed := true
            else if curPattern == 0
                aln_dir := 0
                aln_thesisTxt := "LEA — two-way, range spent in London (revert bias)"
            else if curPattern == 1
                aln_dir := 0
                aln_thesisTxt := "AEL — compression, breakout pending (Asia H/L boundaries)"

        [sss_have, sss_bucket, sss_pct, sss_n, sss_leanTxt, sss_dir] = sssLiveRead()

        // ── Headline TARGET selection ──────────────────────────────────────
        // Among live levels in the thesis direction within the ATR band, pick by
        // the chosen mode (Strongest AtAge% / Nearest / Highest Cum%). If none
        // qualify in-band, fall back to the nearest in-thesis level flagged "(far)".
        bestTargetTxt = "—"
        float bestTargetPx = na
        bestTargetName = "—"
        float bestTargetPct = na
        bestTargetFar = false
        band = na(dailyATR) ? 1e18 : dailyATR * targetBandATR
        if array.size(co_type) > 0
            // Pass 1: in-band candidates scored by mode
            float bestScore = na
            float nearScore = 1e18      // for nearest fallback (smallest dist)
            int nearIdx = -1
            for i = 0 to array.size(co_type) - 1
                if not array.get(co_wickTested, i)
                    cp = array.get(co_price, i)
                    ct = array.get(co_type, i)
                    dist = math.abs(cp - close)
                    dirOk = aln_dir == 1 ? (cp > close) : aln_dir == -1 ? (cp < close) : true
                    if dirOk
                        // track nearest in-thesis level for fallback
                        if dist < nearScore
                            nearScore := dist
                            nearIdx := i
                        // in-band candidate scoring
                        if dist <= band
                            age = sessionNum - array.get(co_birthSession, i)
                            isPending = array.get(co_isPending, i)
                            tot = array.get(stats_totalFinalized, ct)
                            cumN = array.get(stats_wickByAge, ct * 6 + 4)
                            cumP = tot == 0 ? na : 100.0 * cumN / tot
                            dispAge = isPending ? 1 : age + 1
                            ab = ageBucket(dispAge)
                            atAgeP = (ab >= 0 and tot > 0) ? 100.0 * array.get(stats_wickByAge, ct * 6 + ab) / tot : na
                            score = targetMode == "Nearest" ? -dist : targetMode == "Highest Cum%" ? (na(cumP) ? -1.0 : cumP) : (na(atAgeP) ? -1.0 : atAgeP)
                            if na(bestScore) or score > bestScore
                                bestScore := score
                                bestTargetPx := cp
                                bestTargetName := levelName(ct)
                                bestTargetPct := targetMode == "Highest Cum%" ? cumP : atAgeP
            // Fallback: nothing in band → use nearest in-thesis, flag far
            if na(bestTargetPx) and nearIdx >= 0
                cp = array.get(co_price, nearIdx)
                ct = array.get(co_type, nearIdx)
                tot = array.get(stats_totalFinalized, ct)
                cumN = array.get(stats_wickByAge, ct * 6 + 4)
                bestTargetPx := cp
                bestTargetName := levelName(ct)
                bestTargetPct := tot == 0 ? na : 100.0 * cumN / tot
                bestTargetFar := true
        if not na(bestTargetPx)
            farTag = bestTargetFar ? "  (far)" : ""
            bestTargetTxt := bestTargetName + " @ " + str.tostring(bestTargetPx, format.mintick) + (na(bestTargetPct) ? "" : "  (" + str.tostring(bestTargetPct, "#.0") + "%)") + farTag

        table.cell(t, 0, r, "🎯 TARGET", text_color=color.white, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        table.cell(t, 2, r, bestTargetTxt, text_color=color.white, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 2, r, 7, r)
        r += 1

        verdictTxt = ""
        verdictBg = C_CELL
        if not aln_have
            verdictTxt := "Awaiting London close — no ALN pattern yet"
            verdictBg := C_CELL
        else if aln_killed
            verdictTxt := "⚠ KILL SWITCH — edge eroded, stand down on " + (aln_dir == 1 ? "longs" : "shorts")
            verdictBg := f_neg(0)
        else if aln_dir == 0
            verdictTxt := "Neutral / two-way — trade levels, no directional bias"
            verdictBg := C_CELL
        else
            agree = sss_have and sss_dir == aln_dir
            conflict = sss_have and sss_dir != 0 and sss_dir != aln_dir
            dirWord = aln_dir == 1 ? "LONG" : "SHORT"
            watchNote = aln_armed ? (aln_dir == 1 ? "  · watch: LonL-first kills it" : "  · watch: LonH-first kills it") : ""
            if agree
                verdictTxt := "✓ " + dirWord + " — ALN + SSS aligned" + watchNote
                verdictBg := aln_dir == 1 ? f_pos(0) : f_neg(0)
            else if conflict
                verdictTxt := "✗ CONFLICT — ALN says " + dirWord + ", SSS disagrees. Reduce size / wait"
                verdictBg := f_neg(45)
            else
                verdictTxt := "○ " + dirWord + " lean (ALN only — SSS neutral/low sample)" + watchNote
                verdictBg := aln_dir == 1 ? f_pos(45) : f_neg(55)
        table.cell(t, 0, r, "VERDICT", text_color=color.white, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        table.cell(t, 2, r, verdictTxt, text_color=color.white, bgcolor=verdictBg, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 2, r, 7, r)
        r += 1

        aln_cellTxt = aln_have ? aln_thesisTxt + "  (n=" + str.tostring(aln_n) + ")" : "Awaiting London close"
        aln_cellBg = aln_killed ? f_neg(40) : aln_dir == 1 ? f_pos(40) : aln_dir == -1 ? f_neg(55) : C_CELL
        table.cell(t, 0, r, "ALN", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 1, r, aln_cellTxt, text_color=C_TXT, bgcolor=aln_cellBg, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 1, r, 7, r)
        r += 1

        sss_cellTxt = sss_have ? sssBucketName(sss_bucket) + " → " + sss_leanTxt : "Awaiting London close"
        sss_cellBg = sss_dir == 1 ? f_pos(40) : sss_dir == -1 ? f_neg(55) : C_CELL
        table.cell(t, 0, r, "SSS", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 1, r, sss_cellTxt, text_color=C_TXT, bgcolor=sss_cellBg, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 1, r, 7, r)
        r += 1

        liveCount = 0
        brokenCount = 0
        if array.size(co_type) > 0
            for i = 0 to array.size(co_type) - 1
                if array.get(co_wickTested, i)
                    brokenCount += 1
                else
                    liveCount += 1
        clt_cellTxt = str.tostring(liveCount) + " live magnet(s), " + str.tostring(brokenCount) + " broken"
        table.cell(t, 0, r, "CLT", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 1, r, clt_cellTxt, text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 1, r, 7, r)
        r += 1

        if showSitTargets and array.size(co_type) > 0
            table.cell(t, 0, r, "── TARGET LADDER (live, nearest first) ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
            table.cell(t, 0, r, "Level", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 1, r, "Price", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 2, r, "Side", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 3, r, "Dist", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 4, r, "Age", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 5, r, "By Age%", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
            table.cell(t, 6, r, "By D5%", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 6, r, 7, r)
            r += 1
            ladderIdx = array.new_int(0)
            ladderDist = array.new_float(0)
            for i = 0 to array.size(co_type) - 1
                if not array.get(co_wickTested, i)
                    array.push(ladderIdx, i)
                    array.push(ladderDist, math.abs(array.get(co_price, i) - close))
            nLad = array.size(ladderIdx)
            if nLad > 1
                for a = 0 to nLad - 2
                    for b = a + 1 to nLad - 1
                        if array.get(ladderDist, b) < array.get(ladderDist, a)
                            di = array.get(ladderIdx, a)
                            dd = array.get(ladderDist, a)
                            array.set(ladderIdx, a, array.get(ladderIdx, b))
                            array.set(ladderDist, a, array.get(ladderDist, b))
                            array.set(ladderIdx, b, di)
                            array.set(ladderDist, b, dd)
            showN = math.min(nLad, 6)
            if showN > 0
                for k = 0 to showN - 1
                    i = array.get(ladderIdx, k)
                    ct = array.get(co_type, i)
                    cp = array.get(co_price, i)
                    age = sessionNum - array.get(co_birthSession, i)
                    isPending = array.get(co_isPending, i)
                    ageStr = isPending ? "Today" : "D-" + str.tostring(age + 1)
                    sideStr = cp > close ? "▲ above" : "▼ below"
                    sideCol = cp > close ? f_pos(0) : f_neg(0)
                    tot = array.get(stats_totalFinalized, ct)
                    // By D5% = touched at any point through D5 (bucket 4 = through-D5 cumulative)
                    nCum = array.get(stats_wickByAge, ct * 6 + 4)
                    cumPct = tot == 0 ? na : 100.0 * nCum / tot
                    // By Age% = touch rate by the level's CURRENT age (the day cutoff it has reached).
                    // Display age (Today=D1, D-2, ...) maps to bucket: Today->0, D-2->1, ...
                    dispAge = isPending ? 1 : age + 1
                    ab = ageBucket(dispAge)
                    atAgePct = (ab >= 0 and tot > 0) ? 100.0 * array.get(stats_wickByAge, ct * 6 + ab) / tot : na
                    dCut = math.min(dispAge, 5)   // cutoff day shown inline (caps at 5)
                    byAgeTxt = na(atAgePct) ? "—" : str.tostring(atAgePct, "#.0") + "% (D" + str.tostring(dCut) + ")"
                    table.cell(t, 0, r, levelName(ct), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                    table.cell(t, 1, r, str.tostring(cp, format.mintick), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                    table.cell(t, 2, r, sideStr, text_color=color.white, bgcolor=sideCol, text_size=sz)
                    table.cell(t, 3, r, str.tostring(math.abs(cp - close), format.mintick), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                    table.cell(t, 4, r, ageStr, text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                    table.cell(t, 5, r, byAgeTxt, text_color=C_TXT, bgcolor=f_pct_bg(atAgePct), text_size=sz, text_halign=text.align_center)
                    table.cell(t, 6, r, na(cumPct) ? "—" : str.tostring(cumPct, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(cumPct), text_size=sz, text_halign=text.align_center)
                    table.merge_cells(t, 6, r, 7, r)
                    r += 1
            // Legend: explain the two probability columns in plain terms
            table.cell(t, 0, r, "By Age% = hist. touch rate by its current day · By D5% = touched anytime in 5-day life", text_color=C_TXT, bgcolor=C_CELL, text_size=size.tiny, text_halign=text.align_left)
            table.merge_cells(t, 0, r, 7, r)
            r += 1

    if showAllStatsTables and showStatsTable
        maxB = 4
        headers = array.from("Level", "Today", "D2", "D3", "D4", "D5", "Total", "")
        levelLabels = array.from("Asia H", "Asia L", "Lon H", "Lon L", "NY H", "NY L")
        if showWickStats
            table.cell(t, 0, r, "── WICK TOUCH RATES (% through D5) ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
            for i = 0 to 6
                table.cell(t, i, r, array.get(headers, i), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            r += 1
            for lt = 0 to 5
                total = array.get(stats_totalFinalized, lt)
                table.cell(t, 0, r, array.get(levelLabels, lt), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                for b = 0 to maxB
                    n = array.get(stats_wickByAge, lt * 6 + b)
                    pct = total == 0 ? na : 100.0 * n / total
                    table.cell(t, 1 + b, r, f_cell_text(n, total), text_color=C_TXT, bgcolor=f_pct_bg(pct), text_size=sz)
                table.cell(t, 6, r, str.tostring(total), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                r += 1
        if showCloseStats
            table.cell(t, 0, r, "── CLOSE BREAK RATES (% through D5) ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
            for i = 0 to 6
                table.cell(t, i, r, array.get(headers, i), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            r += 1
            for lt = 0 to 5
                total = array.get(stats_totalFinalized, lt)
                table.cell(t, 0, r, array.get(levelLabels, lt), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                for b = 0 to maxB
                    n = array.get(stats_closeByAge, lt * 6 + b)
                    pct = total == 0 ? na : 100.0 * n / total
                    table.cell(t, 1 + b, r, f_cell_text(n, total), text_color=C_TXT, bgcolor=f_pct_bg(pct), text_size=sz)
                table.cell(t, 6, r, str.tostring(total), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                r += 1

    if showAllStatsTables and enableALN and showALNRead and curPattern >= 0
        [tCnt, tAH, tAL, tLH, tLL, tBoth] = alnCountPattern(curPattern)
        totalAllPatterns = array.size(aln_pattern)
        freqPct = totalAllPatterns == 0 ? na : 100.0 * tCnt / totalAllPatterns
        pAH = alnPct(tAH, tCnt)
        pAL = alnPct(tAL, tCnt)
        pLH = alnPct(tLH, tCnt)
        pLL = alnPct(tLL, tCnt)
        pBoth = alnPct(tBoth, tCnt)
        table.cell(t, 0, r, "── TODAY'S READ ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 7, r)
        r += 1
        bannerCol = curPattern == 0 ? C_CELL : curPattern == 1 ? hdrBgCol : curPattern == 2 ? f_pos(30) : f_neg(30)
        bannerTxt = alnPatternName(curPattern) + " — " + alnPatternFullName(curPattern)
        table.cell(t, 0, r, bannerTxt, text_color=C_TXT, bgcolor=bannerCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 5, r)
        table.cell(t, 6, r, "Freq", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 7, r, na(freqPct) ? "—" : str.tostring(freqPct, "#.1") + "%", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
        r += 1
        table.cell(t, 0, r, "Asia H", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 1, r, "Asia L", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 2, r, "Lon H",  text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 3, r, "Lon L",  text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 4, r, "Both",   text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.cell(t, 5, r, "n=" + str.tostring(tCnt), text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 5, r, 7, r)
        r += 1
        ahTxt = (na(pAH) ? "—" : str.tostring(pAH, "#.0") + "%") + (brokeAsiaH_today ? " ✓" : "")
        alTxt = (na(pAL) ? "—" : str.tostring(pAL, "#.0") + "%") + (brokeAsiaL_today ? " ✓" : "")
        lhTxt = (na(pLH) ? "—" : str.tostring(pLH, "#.0") + "%") + (brokeLonH_today ? " ✓" : "")
        llTxt = (na(pLL) ? "—" : str.tostring(pLL, "#.0") + "%") + (brokeLonL_today ? " ✓" : "")
        bothTxt = na(pBoth) ? "—" : str.tostring(pBoth, "#.0") + "%"
        table.cell(t, 0, r, ahTxt, text_color=C_TXT, bgcolor=f_pct_bg(pAH), text_size=sz)
        table.cell(t, 1, r, alTxt, text_color=C_TXT, bgcolor=f_pct_bg(pAL), text_size=sz)
        table.cell(t, 2, r, lhTxt, text_color=C_TXT, bgcolor=f_pct_bg(pLH), text_size=sz)
        table.cell(t, 3, r, llTxt, text_color=C_TXT, bgcolor=f_pct_bg(pLL), text_size=sz)
        table.cell(t, 4, r, bothTxt, text_color=C_TXT, bgcolor=f_pct_bg(pBoth), text_size=sz)
        table.cell(t, 5, r, "", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
        table.merge_cells(t, 5, r, 7, r)
        r += 1
        showConditionalRow = (curPattern == 2 or curPattern == 3 or curPattern == 0 or curPattern == 1)
        if showConditionalRow
            if curPattern == 2
                [nLL1, nLLthenLH] = alnCountConditional(2, 3, 2)
                pLLthenLH = alnPct(nLLthenLH, nLL1)
                table.cell(t, 0, r, "If LonH 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 1, r, "—", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                table.merge_cells(t, 1, r, 3, r)
                table.cell(t, 4, r, "If LonL 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 5, r, "→H " + (na(pLLthenLH) ? "—" : str.tostring(pLLthenLH, "#.0") + "% (n=" + str.tostring(nLL1) + ")"), text_color=C_TXT, bgcolor=f_pct_bg(pLLthenLH), text_size=sz)
                table.merge_cells(t, 5, r, 7, r)
                r += 1
                if not na(pLLthenLH) and not na(pLH) and (pLH - pLLthenLH) >= killSwitchThreshold and firstBreak_today == 3
                    killTxt = "⚠ KILL SWITCH FIRED — LonL broke 1st. LonH edge collapsed " + str.tostring(pLH, "#.0") + "% → " + str.tostring(pLLthenLH, "#.0") + "%. Long thesis dead — stand down."
                    table.cell(t, 0, r, killTxt, text_color=C_TXT, bgcolor=f_neg(20), text_size=sz, text_halign=text.align_center)
                    table.merge_cells(t, 0, r, 7, r)
                    r += 1
            else if curPattern == 3
                [nLH1, nLHthenLL] = alnCountConditional(3, 2, 3)
                pLHthenLL = alnPct(nLHthenLL, nLH1)
                table.cell(t, 0, r, "If LonH 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 1, r, "→L " + (na(pLHthenLL) ? "—" : str.tostring(pLHthenLL, "#.0") + "% (n=" + str.tostring(nLH1) + ")"), text_color=C_TXT, bgcolor=f_pct_bg(pLHthenLL), text_size=sz)
                table.merge_cells(t, 1, r, 3, r)
                table.cell(t, 4, r, "If LonL 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 5, r, "—", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                table.merge_cells(t, 5, r, 7, r)
                r += 1
                if not na(pLHthenLL) and not na(pLL) and (pLL - pLHthenLL) >= killSwitchThreshold and firstBreak_today == 2
                    killTxt = "⚠ KILL SWITCH FIRED — LonH broke 1st. LonL edge collapsed " + str.tostring(pLL, "#.0") + "% → " + str.tostring(pLHthenLL, "#.0") + "%. Short thesis dead — stand down."
                    table.cell(t, 0, r, killTxt, text_color=C_TXT, bgcolor=f_neg(20), text_size=sz, text_halign=text.align_center)
                    table.merge_cells(t, 0, r, 7, r)
                    r += 1
            else
                [nLH1, nLHthenLL] = alnCountConditional(curPattern, 2, 3)
                [nLL1, nLLthenLH] = alnCountConditional(curPattern, 3, 2)
                pLHthenLL = alnPct(nLHthenLL, nLH1)
                pLLthenLH = alnPct(nLLthenLH, nLL1)
                table.cell(t, 0, r, "If LonH 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 1, r, "→L " + (na(pLHthenLL) ? "—" : str.tostring(pLHthenLL, "#.0") + "% (n=" + str.tostring(nLH1) + ")"), text_color=C_TXT, bgcolor=f_pct_bg(pLHthenLL), text_size=sz)
                table.merge_cells(t, 1, r, 3, r)
                table.cell(t, 4, r, "If LonL 1st", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.cell(t, 5, r, "→H " + (na(pLLthenLH) ? "—" : str.tostring(pLLthenLH, "#.0") + "% (n=" + str.tostring(nLL1) + ")"), text_color=C_TXT, bgcolor=f_pct_bg(pLLthenLH), text_size=sz)
                table.merge_cells(t, 5, r, 7, r)
                r += 1
        biasTxt = curPattern == 0 ? "Two-way volatility (London expanded both sides of Asia)" : curPattern == 1 ? "Compression — London inside Asia (coiling for directional NY)" : curPattern == 2 ? "Bullish lean (London above Asia H)" : "Bearish lean (London below Asia L)"
        bestTarget = ""
        bestPct = 0.0
        if not na(pLH) and pLH >= bestPct
            bestPct := pLH
            bestTarget := "Lon H"
        if not na(pLL) and pLL > bestPct
            bestPct := pLL
            bestTarget := "Lon L"
        if not na(pAH) and pAH > bestPct
            bestPct := pAH
            bestTarget := "Asia H"
        if not na(pAL) and pAL > bestPct
            bestPct := pAL
            bestTarget := "Asia L"
        readTxt = biasTxt + ".  Best target: " + bestTarget + " (" + str.tostring(bestPct, "#.0") + "%)"
        table.cell(t, 0, r, readTxt, text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
        table.merge_cells(t, 0, r, 7, r)
        r += 1

    if showAllStatsTables and enableALN and showALNStats and array.size(aln_pattern) > 0
        table.cell(t, 0, r, "── PATTERN STATS ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 7, r)
        r += 1
        alnHeaders = array.from("Pattern", "Freq", "LonH%", "LonL%", "Both", "Days", "", "")
        for i = 0 to 5
            table.cell(t, i, r, array.get(alnHeaders, i), text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 5, r, 7, r)
        r += 1
        totalAll = array.size(aln_pattern)
        for p = 0 to 3
            [cnt, cAH, cAL, cLH, cLL, cBoth] = alnCountPattern(p)
            freqP = totalAll == 0 ? na : 100.0 * cnt / totalAll
            pLHp  = alnPct(cLH,   cnt)
            pLLp  = alnPct(cLL,   cnt)
            pBothp= alnPct(cBoth, cnt)
            isCur = (p == curPattern)
            nameTxt = alnPatternName(p) + (isCur ? " ← TODAY" : "")
            nameBg = isCur ? f_pos(30) : C_CELL
            table.cell(t, 0, r, nameTxt, text_color=C_TXT, bgcolor=nameBg, text_size=sz)
            table.cell(t, 1, r, na(freqP) ? "—" : str.tostring(freqP, "#.1") + "%", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.cell(t, 2, r, na(pLHp) ? "—" : str.tostring(pLHp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(pLHp), text_size=sz)
            table.cell(t, 3, r, na(pLLp) ? "—" : str.tostring(pLLp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(pLLp), text_size=sz)
            table.cell(t, 4, r, na(pBothp) ? "—" : str.tostring(pBothp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(pBothp), text_size=sz)
            table.cell(t, 5, r, str.tostring(cnt), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
            table.merge_cells(t, 5, r, 7, r)
            r += 1

    // ════════════════════════════════════════════════════════════════════════
    // SSS SEQUENCE STATS — NY-green rate per Asia→London color bucket
    // ════════════════════════════════════════════════════════════════════════
    if showAllStatsTables and enableSSS and showSSSStats and array.size(sss_alBucket) > 0
        totalSSS = array.size(sss_alBucket)
        // Condensed: only today's bucket (if both sessions have closed)
        if sssStatsMode == "Today's bucket only"
            [haveR, bkt, pctNa, nR, leanR, dirR] = sssLiveRead()
            table.cell(t, 0, r, "SSS Sequence:", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
            table.merge_cells(t, 0, r, 1, r)
            if haveR
                [bn, bp] = sssBucketStats(bkt)
                cellTxt = sssBucketName(bkt) + " → NY Green " + (na(bp) ? "—" : str.tostring(bp, "#.0") + "%") + " (n=" + str.tostring(bn) + ")"
                table.cell(t, 2, r, cellTxt, text_color=C_TXT, bgcolor=f_pct_bg(bp), text_size=sz, text_halign=text.align_left)
            else
                table.cell(t, 2, r, "Awaiting London close", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
            table.merge_cells(t, 2, r, 7, r)
            r += 1
        // Full grid: all 4 buckets
        else
            table.cell(t, 0, r, "── SSS SEQUENCE STATS ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
            sssHeaders = array.from("A→L", "NY Green%", "NY Red%", "n", "Freq", "", "", "")
            for i = 0 to 7
                table.cell(t, i, r, array.get(sssHeaders, i), text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
            r += 1
            [haveCur, curBkt, _p, _n, _l, _d] = sssLiveRead()
            // Display order: G-G(3), G-R(2), R-G(1), R-R(0)
            order = array.from(3, 2, 1, 0)
            for oi = 0 to 3
                bkt = array.get(order, oi)
                [bn, bp] = sssBucketStats(bkt)
                freqB = totalSSS == 0 ? na : 100.0 * bn / totalSSS
                redP = na(bp) ? na : 100.0 - bp
                isCur = haveCur and bkt == curBkt
                nameTxt = sssBucketName(bkt) + (isCur ? " ← NOW" : "")
                nameBg = isCur ? f_pos(30) : C_CELL
                table.cell(t, 0, r, nameTxt, text_color=C_TXT, bgcolor=nameBg, text_size=sz)
                table.cell(t, 1, r, na(bp) ? "—" : str.tostring(bp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(bp), text_size=sz)
                table.cell(t, 2, r, na(redP) ? "—" : str.tostring(redP, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(redP), text_size=sz)
                table.cell(t, 3, r, str.tostring(bn), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                table.cell(t, 4, r, na(freqB) ? "—" : str.tostring(freqB, "#.1") + "%", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                table.cell(t, 5, r, "", text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                table.merge_cells(t, 5, r, 7, r)
                r += 1

    if showAllStatsTables and enableALN and showALNErosion and array.size(aln_pattern) > 0
        if not erosionFullTable
            if curPattern >= 0
                [cnt, _cAH, _cAL, cLH, cLL, _cBoth] = alnCountPattern(curPattern)
                if cnt > 0
                    pLHp = alnPct(cLH, cnt)
                    pLLp = alnPct(cLL, cnt)
                    [nLL1, nLLthenLH] = alnCountConditional(curPattern, 3, 2)
                    [nLH1, nLHthenLL] = alnCountConditional(curPattern, 2, 3)
                    pLHgivenLL = alnPct(nLLthenLH, nLL1)
                    pLLgivenLH = alnPct(nLHthenLL, nLH1)
                    dLH = (not na(pLHp) and not na(pLHgivenLL)) ? pLHgivenLL - pLHp : na
                    dLL = (not na(pLLp) and not na(pLLgivenLH)) ? pLLgivenLH - pLLp : na
                    headline = ""
                    headlineBg = C_CELL
                    if not na(dLH) and not na(dLL)
                        worst = math.min(dLH, dLL)
                        headline := worst == dLH ? "Lon H " + str.tostring(pLHp, "#.0") + "% → " + str.tostring(pLHgivenLL, "#.0") + "% if LonL 1st (Δ " + str.tostring(dLH, "#.0") + ")" : "Lon L " + str.tostring(pLLp, "#.0") + "% → " + str.tostring(pLLgivenLH, "#.0") + "% if LonH 1st (Δ " + str.tostring(dLL, "#.0") + ")"
                        headlineBg := worst <= -10 ? f_neg(30) : worst <= -5 ? f_neg(60) : C_CELL
                    else if not na(dLH)
                        headline := "Lon H " + str.tostring(pLHp, "#.0") + "% → " + str.tostring(pLHgivenLL, "#.0") + "% if LonL 1st (Δ " + str.tostring(dLH, "#.0") + ")"
                        headlineBg := dLH <= -10 ? f_neg(30) : dLH <= -5 ? f_neg(60) : C_CELL
                    else if not na(dLL)
                        headline := "Lon L " + str.tostring(pLLp, "#.0") + "% → " + str.tostring(pLLgivenLH, "#.0") + "% if LonH 1st (Δ " + str.tostring(dLL, "#.0") + ")"
                        headlineBg := dLL <= -10 ? f_neg(30) : dLL <= -5 ? f_neg(60) : C_CELL
                    else
                        headline := "Insufficient data for conditional analysis"
                    table.cell(t, 0, r, "Edge Erosion (" + alnPatternName(curPattern) + "):", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_left)
                    table.merge_cells(t, 0, r, 1, r)
                    table.cell(t, 2, r, headline, text_color=C_TXT, bgcolor=headlineBg, text_size=sz, text_halign=text.align_left)
                    table.merge_cells(t, 2, r, 7, r)
                    r += 1
        else
            table.cell(t, 0, r, "── EDGE EROSION ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
            erHeaders = array.from("Pattern", "LonH%", "LonH| LonL 1st", "Δ", "LonL%", "LonL| LonH 1st", "Δ", "")
            for i = 0 to 7
                table.cell(t, i, r, array.get(erHeaders, i), text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
            r += 1
            for p = 0 to 3
                [cnt, _cAH, _cAL, cLH, cLL, _cBoth] = alnCountPattern(p)
                if cnt > 0
                    pLHp = alnPct(cLH, cnt)
                    pLLp = alnPct(cLL, cnt)
                    [nLL1, nLLthenLH] = alnCountConditional(p, 3, 2)
                    [nLH1, nLHthenLL] = alnCountConditional(p, 2, 3)
                    pLHgivenLL = alnPct(nLLthenLH, nLL1)
                    pLLgivenLH = alnPct(nLHthenLL, nLH1)
                    dLH = (not na(pLHp) and not na(pLHgivenLL)) ? pLHgivenLL - pLHp : na
                    dLL = (not na(pLLp) and not na(pLLgivenLH)) ? pLLgivenLH - pLLp : na
                    dLH_col = na(dLH) ? C_CELL : dLH <= -10 ? f_neg(30) : dLH <= -5 ? f_neg(60) : C_CELL
                    dLL_col = na(dLL) ? C_CELL : dLL <= -10 ? f_neg(30) : dLL <= -5 ? f_neg(60) : C_CELL
                    isCur = (p == curPattern)
                    nameBg = isCur ? f_pos(30) : C_CELL
                    table.cell(t, 0, r, alnPatternName(p), text_color=C_TXT, bgcolor=nameBg, text_size=sz)
                    table.cell(t, 1, r, na(pLHp) ? "—" : str.tostring(pLHp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(pLHp), text_size=sz)
                    table.cell(t, 2, r, na(pLHgivenLL) ? "—" : str.tostring(pLHgivenLL, "#.0") + "% (n=" + str.tostring(nLL1) + ")", text_color=C_TXT, bgcolor=f_pct_bg(pLHgivenLL), text_size=sz)
                    table.cell(t, 3, r, na(dLH) ? "—" : (dLH > 0 ? "+" : "") + str.tostring(dLH, "#.0"), text_color=C_TXT, bgcolor=dLH_col, text_size=sz)
                    table.cell(t, 4, r, na(pLLp) ? "—" : str.tostring(pLLp, "#.0") + "%", text_color=C_TXT, bgcolor=f_pct_bg(pLLp), text_size=sz)
                    table.cell(t, 5, r, na(pLLgivenLH) ? "—" : str.tostring(pLLgivenLH, "#.0") + "% (n=" + str.tostring(nLH1) + ")", text_color=C_TXT, bgcolor=f_pct_bg(pLLgivenLH), text_size=sz)
                    table.cell(t, 6, r, na(dLL) ? "—" : (dLL > 0 ? "+" : "") + str.tostring(dLL, "#.0"), text_color=C_TXT, bgcolor=dLL_col, text_size=sz)
                    table.cell(t, 7, r, str.tostring(cnt), text_color=C_TXT, bgcolor=C_CELL, text_size=sz)
                    r += 1

    if showAllStatsTables and showTodaysRead
        table.cell(t, 0, r, "── TODAY'S ACTIVE CARRYOVERS ──", text_color=C_TXT, bgcolor=hdrBgCol, text_size=sz, text_halign=text.align_center)
        table.merge_cells(t, 0, r, 7, r)
        r += 1
        if array.size(co_type) == 0
            table.cell(t, 0, r, "No active carryovers", text_color=C_TXT, bgcolor=C_CELL, text_halign=text.align_center)
            table.merge_cells(t, 0, r, 7, r)
            r += 1
        else
            // Sort all active carryovers by distance to current price (closest first).
            // When hideBroken is on, exclude wick-broken levels entirely.
            displayIdx = array.new_int(0)
            displayDist = array.new_float(0)
            for i = 0 to array.size(co_type) - 1
                if not (hideBroken and array.get(co_wickTested, i))
                    array.push(displayIdx, i)
                    array.push(displayDist, math.abs(array.get(co_price, i) - close))
            nDisp = array.size(displayIdx)
            if nDisp > 1
                for a = 0 to nDisp - 2
                    for b = a + 1 to nDisp - 1
                        if array.get(displayDist, b) < array.get(displayDist, a)
                            di = array.get(displayIdx, a)
                            dd = array.get(displayDist, a)
                            array.set(displayIdx, a, array.get(displayIdx, b))
                            array.set(displayDist, a, array.get(displayDist, b))
                            array.set(displayIdx, b, di)
                            array.set(displayDist, b, dd)
            displayCount = math.min(array.size(displayIdx), maxActiveDisplay)
            hiddenCount = array.size(displayIdx) - displayCount
            if displayCount == 0
                table.cell(t, 0, r, "No live carryovers", text_color=C_TXT, bgcolor=C_CELL, text_halign=text.align_center)
                table.merge_cells(t, 0, r, 7, r)
                r += 1
            for k = 0 to displayCount - 1
                if displayCount > 0
                    i = array.get(displayIdx, k)
                    ct = array.get(co_type, i)
                    cp = array.get(co_price, i)
                    age = sessionNum - array.get(co_birthSession, i)
                    isPending = array.get(co_isPending, i)
                    name = levelName(ct)
                    wickHit = array.get(co_wickTested, i)
                    ageStr = isPending ? "Today" : "D-" + str.tostring(age + 1)
                    table.cell(t, 0, r, name, text_color=C_TXT, bgcolor=C_CELL)
                    table.cell(t, 1, r, str.tostring(cp, format.mintick), text_color=C_TXT, bgcolor=C_CELL, text_size=size.normal)
                    table.cell(t, 2, r, ageStr, text_color=C_TXT, bgcolor=C_CELL)
                    table.cell(t, 3, r, wickHit ? "✓ Broken" : "— Live", text_color=C_TXT, bgcolor=C_CELL)
                    r += 1
            if hiddenCount > 0
                table.cell(t, 0, r, "+ " + str.tostring(hiddenCount) + " more hidden (raise cap to view)", text_color=C_TXT, bgcolor=C_CELL, text_size=sz, text_halign=text.align_center)
                table.merge_cells(t, 0, r, 7, r)
                r += 1
````
