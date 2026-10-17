# Daye's True Opens [Quarterly Theory]

- url: https://www.tradingview.com/script/AWcPTIRa-Daye-s-True-Opens-Quarterly-Theory/
- type: indicator
- pine_id: PUB;0cdd3d8bb3394b4cba018ec4d216c1ac
- version: 3.0

## Description

Daye's True Opens — Quarterly Theory
Plots the True Opens from Daye's Quarterly Theory across five timeframes: Session, Day, Week, Month, and Year. In QT, every cycle is divided into four quarters — Q1 (Accumulation), Q2 (Manipulation), Q3 (Distribution), Q4 (Continuation/Reversal). The "True Open" of any cycle is the open of Q2 — the level from which the manipulation phase begins, and one of the most reliable reference points for intraday and swing bias.

What it plots
True Session Open — Q2 of each 6-hour session (one line per session, kept independently):
Asia: 19:30 NY
London: 01:30 NY
NY AM: 07:30 NY
NY PM: 13:30 NY
True Day Open — 00:00 NY (Q2 of the daily cycle, which begins 18:00 NY)
True Week Open — Monday 18:00 NY (Q2 of the weekly cycle, which begins Sunday 18:00 NY)
True Month Open — 2nd Monday at 18:00 NY (open of the second weekly candle = Q2 of the month)
True Year Open — April 1, 00:00 NY (Q2 of the year: Jan–Mar / Apr–Jun / Jul–Sep / Oct–Dec)
Behavior
Each True Open type maintains only one current instance — the level updates automatically when the next cycle's Q2 begins. No clutter from historical levels.
Sessions are tracked per session type, so during London you'll still see the latest Asia, NY AM, and NY PM True Opens — not just the most recent of any session.
Lines extend from their origin bar to the current bar only (no infinite right-extension).
Labels sit just to the right of each line and include a tooltip explaining what the level represents.
Alerts available for every True Open type.
Inputs
Toggle each True Open type on/off independently.
Customize line color (per type), width, and style.
Configure label visibility and gap.
How traders use True Opens
Price reaction at a True Open often signals the direction of the manipulation-to-distribution leg of the cycle. Common uses:

Bias above/below the True Day Open to filter long/short setups.
True Week / Month Open as draw-on-liquidity targets or HTF mean-reversion levels.
True Session Open as an intraday pivot for the active session.
Notes
All times are anchored to America/New_York (handles DST automatically).
Best on intraday timeframes (1m–1H). On higher timeframes, intraday triggers may be missed — use the higher-TF cycles (Week/Month/Year).
The True Year Open requires April data to be loaded on the chart.

## Source Code

````pine
//@version=6
// =============================================================================
// Daye's Quarterly Theory — True Opens
// =============================================================================
// Always shows ONE current line per True Open type:
//   • True Session Open (TSO) : one line per session (Asia, London, NY AM, NY PM)
//   • True Day Open    (TDO) : single line, replaced at 00:00 NY each day.
//   • True Week Open   (TWO) : single line, replaced Mon 18:00 NY each week.
//   • True Month Open  (TMO) : single line, replaced 2nd Mon 18:00 NY each month.
//   • True Year Open   (TYO) : single line, replaced on the first bar of April.
//
// Lines extend only to the current bar; labels sit just to the right of the
// line and carry a tooltip explaining the level.
// =============================================================================
indicator("Daye's True Opens [Quarterly Theory]", "True Opens",
     overlay = true, max_lines_count = 50, max_labels_count = 50)
// ---------------------------------------------------------------- Inputs ----
gV = "Visibility"
showSessions = input.bool(false, "True Session Opens", group = gV,
     tooltip = "Shows the most recent True Open for each of the 4 sessions (Asia, London, NY AM, NY PM).")
showDay   = input.bool(true, "True Day Open  (00:00 NY)",        group = gV)
showWeek  = input.bool(true, "True Week Open (Mon 18:00 NY)",    group = gV)
showMonth = input.bool(true, "True Month Open (2nd Mon 18:00)",  group = gV)
showYear  = input.bool(true, "True Year Open (Apr 1, 00:00 NY)", group = gV)
gC  = "Colors"
DEF = #ff9900
sessionColor = input.color(DEF, "Session Color", group = gC)
dayColor     = input.color(DEF, "Day Color",     group = gC)
weekColor    = input.color(DEF, "Week Color",    group = gC)
monthColor   = input.color(DEF, "Month Color",   group = gC)
yearColor    = input.color(DEF, "Year Color",    group = gC)
gL = "Lines & Labels"
lineWidthIn = input.int(1, "Line Width", minval = 1, maxval = 5, group = gL)
lineStyleIn = input.string("solid", "Line Style",
     options = ["solid", "dashed", "dotted"], group = gL)
showLabels  = input.bool(true, "Show Labels", group = gL)
labelGap    = input.int(2, "Label Gap (bars right of line)", minval = 0, group = gL)
lineStyle = lineStyleIn == "dashed" ? line.style_dashed :
             lineStyleIn == "dotted" ? line.style_dotted : line.style_solid
// ----------------------------------------------------------- Time helpers ---
tz = "America/New_York"
f_isStart(string sessStr) =>
    t = time(timeframe.period, sessStr, tz)
    not na(t) and na(t[1])
// --------------------------------------------------------- Open triggers ---
isAsia    = f_isStart("1930-1931:1234567")
isLondon  = f_isStart("0130-0131:1234567")
isNYAM    = f_isStart("0730-0731:1234567")
isNYPM    = f_isStart("1330-1331:1234567")
isTrueDay = f_isStart("0000-0001:1234567")
isTrueWk  = f_isStart("1800-1801:2")
mondayAt18 = f_isStart("1800-1801:2")
nyMonth    = month(time, tz)
nyYear     = year(time, tz)
var int mondayCount = 0
if nyMonth != nyMonth[1]
    mondayCount := 0
if mondayAt18
    mondayCount += 1
isTrueMo = mondayAt18 and mondayCount == 2
// True Year Open: first bar of April (NY) — Q2 of the year cycle.
isTrueYr = nyMonth == 4 and nyMonth[1] != 4
// --------------------------------------------------------- Storage (×1) ----
var array<line>  asiaLn   = array.new<line>()
var array<label> asiaLb   = array.new<label>()
var array<line>  londonLn = array.new<line>()
var array<label> londonLb = array.new<label>()
var array<line>  nyamLn   = array.new<line>()
var array<label> nyamLb   = array.new<label>()
var array<line>  nypmLn   = array.new<line>()
var array<label> nypmLb   = array.new<label>()
var array<line>  dayLn    = array.new<line>()
var array<label> dayLb    = array.new<label>()
var array<line>  wkLn     = array.new<line>()
var array<label> wkLb     = array.new<label>()
var array<line>  moLn     = array.new<line>()
var array<label> moLb     = array.new<label>()
var array<line>  yrLn     = array.new<line>()
var array<label> yrLb     = array.new<label>()
// --------------------------------------------------------- Helpers ---------
f_create(array<line> lns, array<label> lbs, float price, color col,
         string txt, string tip) =>
    ln = line.new(bar_index, price, bar_index, price,
         color = col, width = lineWidthIn, style = lineStyle, extend = extend.none)
    array.push(lns, ln)
    if showLabels
        lb = label.new(bar_index + labelGap, price, txt,
             color = color.new(col, 100), textcolor = col,
             style = label.style_label_left, size = size.small, tooltip = tip)
        array.push(lbs, lb)
    while array.size(lns) > 1
        line.delete(array.shift(lns))
    while array.size(lbs) > 1
        label.delete(array.shift(lbs))
f_extend(array<line> lns, array<label> lbs) =>
    if array.size(lns) > 0
        line.set_x2(array.get(lns, 0), bar_index)
    if array.size(lbs) > 0
        label.set_x(array.get(lbs, 0), bar_index + labelGap)
// --------------------------------------------------------- Tooltips --------
tipAsia   = "True Session Open (Asia)\nDaye Quarterly Theory — Q2 open of the Asia session (19:30 NY)."
tipLondon = "True Session Open (London)\nDaye Quarterly Theory — Q2 open of the London session (01:30 NY)."
tipNYAM   = "True Session Open (NY AM)\nDaye Quarterly Theory — Q2 open of the NY AM session (07:30 NY)."
tipNYPM   = "True Session Open (NY PM)\nDaye Quarterly Theory — Q2 open of the NY PM session (13:30 NY)."
tipDay    = "True Day Open\nDaye Quarterly Theory — Q2 open of the daily cycle (00:00 NY).\nThe day begins 18:00 NY; this is where Q1 → Q2 transitions."
tipWeek   = "True Week Open\nDaye Quarterly Theory — Q2 open of the weekly cycle (Mon 18:00 NY)."
tipMonth  = "True Month Open\nDaye Quarterly Theory — Q2 open of the monthly cycle (2nd Monday 18:00 NY)."
tipYear   = "True Year Open\nDaye Quarterly Theory — Q2 open of the yearly cycle (April 1, 00:00 NY).\nYear quarters: Q1 Jan-Mar, Q2 Apr-Jun, Q3 Jul-Sep, Q4 Oct-Dec."
// --------------------------------------------------------- Plot ------------
if showSessions and isAsia
    f_create(asiaLn,   asiaLb,   open, sessionColor, "TSO Asia",   tipAsia)
if showSessions and isLondon
    f_create(londonLn, londonLb, open, sessionColor, "TSO London", tipLondon)
if showSessions and isNYAM
    f_create(nyamLn,   nyamLb,   open, sessionColor, "TSO NY AM",  tipNYAM)
if showSessions and isNYPM
    f_create(nypmLn,   nypmLb,   open, sessionColor, "TSO NY PM",  tipNYPM)
if showDay   and isTrueDay
    f_create(dayLn, dayLb, open, dayColor,   "TDO", tipDay)
if showWeek  and isTrueWk
    f_create(wkLn,  wkLb,  open, weekColor,  "TWO", tipWeek)
if showMonth and isTrueMo
    f_create(moLn,  moLb,  open, monthColor, "TMO", tipMonth)
if showYear  and isTrueYr
    f_create(yrLn,  yrLb,  open, yearColor,  "TYO", tipYear)
// Stretch each line to the current bar and reposition its label every bar.
f_extend(asiaLn,   asiaLb)
f_extend(londonLn, londonLb)
f_extend(nyamLn,   nyamLb)
f_extend(nypmLn,   nypmLb)
f_extend(dayLn,    dayLb)
f_extend(wkLn,     wkLb)
f_extend(moLn,     moLb)
f_extend(yrLn,     yrLb)
````
