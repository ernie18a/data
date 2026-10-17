# Session Pulse [JOAT]

- url: https://www.tradingview.com/script/ccYTHr7K-Session-Pulse-JOAT/
- type: indicator
- pine_id: PUB;966b36eafdb445709df13eda328ef98f
- version: 1.0

## Description

[b]Session Pulse [JOAT][/b]

[b]Introduction[/b]

Session Pulse is an open-source multi-session gap statistics engine that tracks, categorizes, and accumulates gap data across Asia, London, and New York trading sessions, marks every session boundary transition with labeled vertical lines on the chart, and presents a unified session statistics dashboard. It answers a specific and persistent question that many traders examine manually: how often, in which direction, and by how much does this instrument gap between sessions?

Gap behavior is one of the most systematically consistent patterns across many instruments. Session close-to-open gaps represent a measurable directional displacement — one that either fills (mean reverts) or extends (confirms momentum) in predictable proportions over sufficiently large samples. Session Pulse automates the data collection and visualization for that entire analysis, providing live cumulative statistics on gap frequency, average gap size, maximum gap, and directional bias, refreshed on every bar.

[image]https://www.tradingview.com/x/cyQTrkXs/[/image]

[b]Core Concepts[/b]

[b]1. Session Detection[/b]

Each of the three sessions (Asia, London, New York) is detected using Pine Script's time() function with a user-configurable session string and timezone. Session transitions are identified by comparing the current bar's session membership to the previous bar's membership. A session start occurs on the first bar where the current bar is inside the session and the previous bar was outside:

[pine]
inAsia   = not na(time(timeframe.period, asiaSess,   tzString))
inLondon = not na(time(timeframe.period, londonSess, tzString))
inNY     = not na(time(timeframe.period, nySess,     tzString))

asiaStart   = inAsia   and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart     = inNY     and not inNY[1]
[/pine]

[b]2. Gap Calculation and Categorization[/b]

A gap is calculated at each session open as the difference between the current bar's open and the previous bar's close, expressed as a percentage of the previous close. Gaps are categorized as Gap Up (positive gap, open above prior close) or Gap Down (negative gap, open below prior close). A minimum gap percentage threshold filters out negligible noise-level gaps that do not qualify as meaningful session displacements:

[pine]
gapPct  = (open - close[1]) / close[1] * 100
isGapUp   = asiaStart  and gapPct  >  minGap
isGapDown = asiaStart  and gapPct  < -minGap
[/pine]

[b]3. Session Boundary Visualization[/b]

At each session start, a vertical dotted line is drawn extending across the chart, and a labeled arrow points down from the top of the price range with the session name (ASIA, LONDON, NEW YORK). This creates a clear visual demarcation of every session boundary on the chart without requiring manual annotation. The lines and labels are drawn live on the current bar and persist across the chart history:

[pine]
if showSessLns and londonStart
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=color.new(#01579B, 55), style=line.style_dotted,
         width=2, extend=extend.both)
    label.new(bar_index, high, "LONDON",
         style=label.style_label_down,
         color=color.new(#01579B, 50), textcolor=color.white, size=size.tiny)
[/pine]

[b]4. Cumulative Statistics Accumulation[/b]

Statistics are accumulated across the full chart history using running counters and accumulators for each direction. For each session type (Asia, London, NY), the indicator tracks: total gap count by direction, cumulative gap size sum for average computation, and the maximum gap in each direction. These statistics build bar by bar and display the full historical picture at any point in time:

[pine]
if isGapUp
    upCount   += 1
    upTotal   += gapPct
    upMax     := math.max(upMax, gapPct)
[/pine]

[b]5. Unified Statistics Dashboard[/b]

A single unified table presents all gap statistics in a structured layout: Gap Up rows at the top, a separator, Gap Down rows below, a final separator, and a summary row showing total gap count and the percentage of gaps that were up (directional bias). The entire table is positioned at a single user-configurable location on the chart, eliminating split-panel layouts:

[pine]
// Row 0-1: Gap Up (Count, Avg, Max)
// Row 2: Separator
// Row 3-4: Gap Down (Count, Avg, Max)
// Row 5: Separator
// Row 6: Summary (Total, Up Bias %)
[/pine]

[image]https://www.tradingview.com/x/fkIf9uzg/[/image]

[b]Features[/b]

[list]
[*][b]Three-session gap tracking:[/b] Asia, London, and New York sessions each independently tracked with configurable session strings
[*][b]Session boundary vertical lines:[/b] Dotted vertical lines with session name labels (ASIA, LONDON, NEW YORK) at every session transition
[*][b]Gap categorization:[/b] Gap Up and Gap Down separated by direction with independent counters, average, and maximum for each
[*][b]Minimum gap filter:[/b] Configurable threshold eliminates negligible gaps below a specified percentage
[*][b]Directional bias calculation:[/b] Summary row shows Up Bias % — what proportion of all detected gaps have been upward
[*][b]Unified statistics table:[/b] Single table with Gap Up, separator, Gap Down, separator, and summary rows at a single configurable position
[*][b]Table position selector:[/b] Top-right, bottom-right, bottom-left, or bottom-center placement
[*][b]Session boundary line toggle:[/b] Session vertical lines and labels can be independently enabled or disabled
[*][b]Configurable session strings:[/b] All three session time windows are fully user-adjustable for different broker timezones
[*][b]Timezone input:[/b] Single timezone string applied consistently to all three session detectors
[*][b]Alerts:[/b] Six alertconditions — Gap Up and Gap Down for each of the three sessions, plus Asia, London, and New York session open alerts
[/list]

[b]Input Parameters[/b]

[b]Session Settings:[/b]
[list]
[*]Timezone: Timezone string for session detection (default: America/New_York)
[*]Asia Session: Session time string (default: 1800-0000)
[*]London Session: Session time string (default: 0200-0500)
[*]New York Session: Session time string (default: 0930-1600)
[/list]

[b]Gap Detection:[/b]
[list]
[*]Min Gap %: Minimum gap size to qualify as a gap event (default: 0.05%)
[*]Enable Gap Tracking toggles per session
[/list]

[b]Display:[/b]
[list]
[*]Show Session Lines toggle
[*]Show Stats Table toggle
[*]Table Position: Top Right, Bottom Right, Bottom Left, Bottom Center
[*]Session line colors for Asia, London, and New York
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Directional Bias[/b]
The summary row of the statistics table shows Up Bias % — the percentage of all gaps that have been upward. An Up Bias above 60% on a large sample indicates this instrument has a persistent tendency to gap up at session opens. This is the first, most actionable piece of information from the table.

[b]Step 2: Compare Average Gap Sizes[/b]
The average gap rows for Gap Up and Gap Down show the typical magnitude of each type. If the average Gap Down is significantly larger than the average Gap Up, the downside gaps — when they occur — tend to be more violent even if they are less frequent. This asymmetry has implications for stop sizing around session opens.

[b]Step 3: Use Maximum Gap for Range Planning[/b]
The maximum gap rows show the largest gap in each direction recorded on the chart. This establishes the worst-case session displacement for this instrument at the current timeframe — useful for setting session-open risk boundaries.

[b]Step 4: Use Session Boundary Lines for Chart Context[/b]
The vertical lines with session name labels divide the chart into session periods. On lower timeframes this makes it immediately clear which session each group of bars belongs to, providing context for patterns that occur predominantly in specific sessions.

[b]Step 5: Monitor for Session Open Alerts[/b]
Set the session open alerts to receive notifications at each session transition. This is particularly useful on instruments where specific sessions (London or New York) have consistent volatility expansion patterns at open.

[b]Indicator Limitations[/b]

[list]
[*]Gap detection measures the open of the first bar inside a session versus the close of the last bar outside the session. On timeframes where session transitions do not align cleanly with bar boundaries, gaps may be slightly misattributed
[*]On instruments that trade continuously (24/7 crypto) with no actual session close, the concept of a gap between sessions is less meaningful — the session boundaries exist but price does not actually stop between them
[*]The minimum gap filter is a flat percentage threshold. Instruments with different typical volatility levels require different minimum gap values to produce meaningful categorization
[*]Statistics accumulate from the beginning of the chart's data history. On very long charts or charts with intraday data going back years, early data may represent a different market regime than the current one, diluting the relevance of cumulative statistics
[*]This indicator tracks and categorizes gaps. It does not predict gap fill probability, gap extension probability, or provide entry/exit signals
[/list]

[b]Originality Statement[/b]

Session Pulse is original in its simultaneous three-session gap tracking system with unified cumulative statistics, directional bias calculation, and session boundary visualization integrated into a single tool. This indicator is published because:

[list]
[*]Tracking gap statistics across three named, independently configurable sessions simultaneously — with separate counters, averages, and maximums for each direction per session — in a single unified table is uncommon in published open-source Pine Script
[*]The directional bias percentage (Up Bias %) derived from cumulative historical gap data provides a single, immediately actionable summary statistic that characterizes the instrument's session gap behavior over the entire charted history
[*]The session boundary vertical lines with labeled session name arrows provide a visual calendar overlay that applies the same session detection logic used for gap calculation to the chart itself, creating consistency between the chart elements and the statistical table
[*]The unified single-table layout with section separators — merging Gap Up, Gap Down, and summary into one table at one position — avoids the visual fragmentation of split multi-table layouts
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Session gap statistics reflect historical data and do not guarantee future gaps will occur with the same frequency, size, or direction. The directional bias percentage is a historical observation, not a predictive probability. Session open behavior is subject to news, earnings, and macroeconomic events that historical statistics do not account for. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Session Pulse [JOAT]", shorttitle="Sess Pulse [JOAT]", overlay=true,
     max_boxes_count=300, max_labels_count=300, max_lines_count=300)
// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpGap = "Gap Detection"
gapDnThres = input.float(-1.0, "Gap-Down Threshold %", maxval=0.0, step=0.1, group=grpGap)
gapUpThres = input.float(1.0,  "Gap-Up Threshold %",   minval=0.0, step=0.1, group=grpGap)
showGapBox = input.bool(true,  "Show Gap Zone Boxes",   group=grpGap)
showGapLbl = input.bool(true,  "Show Gap % Labels",     group=grpGap)

grpSession = "Sessions"
utcOffset   = input.int(0,     "UTC Offset (hours)",   minval=-12, maxval=14,  group=grpSession)
showAsiaBg  = input.bool(false,"Asia Background",       group=grpSession)
showLonBg   = input.bool(false,"London Background",     group=grpSession)
showNYBg    = input.bool(false,"New York Background",   group=grpSession)
showSessLns = input.bool(true, "Session Boundary Lines",group=grpSession,
     tooltip="Draws a vertical line and session name label at the start of each session.")
asiaRange   = input.session("0000-0800", "Asia Range",   group=grpSession)
londonRange = input.session("0700-1600", "London Range", group=grpSession)
nyRange     = input.session("1300-2200", "NY Range",     group=grpSession)

grpDisplay = "Display"
showDash   = input.bool(true, "Show Status Dashboard",  group=grpDisplay)
showTable  = input.bool(true, "Show Gap Stats Table",   group=grpDisplay)
tablePos   = input.string("Bottom Right", "Stats Table Position",
     options=["Bottom Right","Bottom Left","Top Right","Top Left"], group=grpDisplay)

grpColors = "Colors"
gapDnCol  = input.color(color.new(#B71C1C, 70), "Gap Down Zone", group=grpColors)
gapUpCol  = input.color(color.new(#1B5E20, 70), "Gap Up Zone",   group=grpColors)
asiaBgCol = input.color(color.new(#6A1B9A, 96), "Asia BG",       group=grpColors)
lonBgCol  = input.color(color.new(#01579B, 96), "London BG",     group=grpColors)
nyBgCol   = input.color(color.new(#E65100, 96), "NY BG",         group=grpColors)

// ─── SESSION HELPERS ───────────────────────────────────────────────────────────
getTZ() =>
    "UTC" + (utcOffset >= 0 ? "+" + str.tostring(utcOffset) : str.tostring(utcOffset))

inAsia   = not na(time(timeframe.period, asiaRange,   getTZ()))
inLondon = not na(time(timeframe.period, londonRange, getTZ()))
inNY     = not na(time(timeframe.period, nyRange,     getTZ()))

sessionName() =>
    inNY and inLondon ? "LN + NY" : inNY ? "New York" : inLondon ? "London" : inAsia ? "Asia" : "Off-Hours"

bgcolor(showAsiaBg and inAsia   ? asiaBgCol : na, title="Asia BG")
bgcolor(showLonBg  and inLondon ? lonBgCol  : na, title="London BG")
bgcolor(showNYBg   and inNY     ? nyBgCol   : na, title="NY BG")

// ─── SESSION BOUNDARY DETECTION ────────────────────────────────────────────────
// Detect transition into each session (first bar of session)
sessAsiaStart   = inAsia   and not inAsia[1]
sessLondonStart = inLondon and not inLondon[1]
sessNYStart     = inNY     and not inNY[1]

// Draw session boundary lines and labels on chart
if showSessLns and sessAsiaStart
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=color.new(#6A1B9A, 55), style=line.style_dotted, width=2,
         extend=extend.both)
    label.new(bar_index, high, "ASIA",
         style=label.style_label_down, color=color.new(#6A1B9A, 50),
         textcolor=color.white, size=size.tiny)

if showSessLns and sessLondonStart
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=color.new(#01579B, 55), style=line.style_dotted, width=2,
         extend=extend.both)
    label.new(bar_index, high, "LONDON",
         style=label.style_label_down, color=color.new(#01579B, 50),
         textcolor=color.white, size=size.tiny)

if showSessLns and sessNYStart
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=color.new(#E65100, 55), style=line.style_dotted, width=2,
         extend=extend.both)
    label.new(bar_index, high, "NEW YORK",
         style=label.style_label_down, color=color.new(#E65100, 50),
         textcolor=color.white, size=size.tiny)

// ─── GAP DETECTION ─────────────────────────────────────────────────────────────
gapPct    = (open - close[1]) / close[1] * 100
isGapDown = gapPct <= gapDnThres
isGapUp   = gapPct >= gapUpThres

oToH = (high  - open) / open * 100
oToL = (low   - open) / open * 100
oToC = (close - open) / open * 100

// ─── FORMATTERS ────────────────────────────────────────────────────────────────
fmt(float v) => str.tostring(math.round(v, 2)) + "%"
signClr(float v) => v >= 0 ? color.new(#00897B, 0) : color.new(#B71C1C, 0)

// ─── LAST GAP TRACKING ─────────────────────────────────────────────────────────
var float lastGapPct  = na
var bool  lastGapIsUp = false

if isGapUp or isGapDown
    lastGapPct  := gapPct
    lastGapIsUp := isGapUp

// ─── GAP DOWN ACCUMULATORS ─────────────────────────────────────────────────────
var int   dn_total       = 0
var float dn_sumGap      = 0.0
var int   dn_contCount   = 0
var float dn_contSumC    = 0.0
var int   dn_bounceCount = 0
var float dn_bounceSumC  = 0.0

if isGapDown
    dn_total  += 1
    dn_sumGap += gapPct
    if close < open
        dn_contCount += 1
        dn_contSumC  += oToC
    else
        dn_bounceCount += 1
        dn_bounceSumC  += oToC

// ─── GAP UP ACCUMULATORS ───────────────────────────────────────────────────────
var int   up_total     = 0
var float up_sumGap    = 0.0
var int   up_contCount = 0
var float up_contSumC  = 0.0
var int   up_fadeCount = 0
var float up_fadeSumC  = 0.0

if isGapUp
    up_total  += 1
    up_sumGap += gapPct
    if close >= open
        up_contCount += 1
        up_contSumC  += oToC
    else
        up_fadeCount += 1
        up_fadeSumC  += oToC

// ─── DERIVED AVERAGES ──────────────────────────────────────────────────────────
dn_avgGap    = dn_total > 0       ? dn_sumGap    / dn_total        : 0.0
dn_contPct   = dn_total > 0       ? dn_contCount * 100.0 / dn_total : 0.0
dn_avgContC  = dn_contCount > 0   ? dn_contSumC  / dn_contCount    : 0.0
dn_bouncePct = dn_total > 0       ? dn_bounceCount * 100.0 / dn_total : 0.0
dn_avgBncC   = dn_bounceCount > 0 ? dn_bounceSumC / dn_bounceCount : 0.0

up_avgGap   = up_total > 0      ? up_sumGap    / up_total        : 0.0
up_contPct  = up_total > 0      ? up_contCount * 100.0 / up_total : 0.0
up_avgContC = up_contCount > 0  ? up_contSumC  / up_contCount    : 0.0
up_fadePct  = up_total > 0      ? up_fadeCount * 100.0 / up_total : 0.0
up_avgFadeC = up_fadeCount > 0  ? up_fadeSumC  / up_fadeCount    : 0.0

// ─── GAP VISUALS ───────────────────────────────────────────────────────────────
if showGapBox and isGapDown
    box.new(bar_index - 1, close[1], bar_index, open,
         border_color=color.new(#B71C1C, 30), border_width=1,
         bgcolor=gapDnCol, border_style=line.style_dashed)
    if showGapLbl
        label.new(bar_index, math.avg(open, close[1]), fmt(gapPct),
             style=label.style_none, textcolor=color.new(#B71C1C, 0), size=size.small)

if showGapBox and isGapUp
    box.new(bar_index - 1, close[1], bar_index, open,
         border_color=color.new(#1B5E20, 30), border_width=1,
         bgcolor=gapUpCol, border_style=line.style_dashed)
    if showGapLbl
        label.new(bar_index, math.avg(open, close[1]), "+" + fmt(gapPct),
             style=label.style_none, textcolor=color.new(#1B5E20, 0), size=size.small)

bgcolor(isGapDown ? color.new(#B71C1C, 92) : na, title="Gap Down Highlight")
bgcolor(isGapUp   ? color.new(#1B5E20, 92) : na, title="Gap Up Highlight")

// ─── STATUS DASHBOARD — TOP RIGHT ──────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 11,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#546E7A, 50),
     frame_width=1)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)

    string sessStr = sessionName()
    color  sessCol = inNY and inLondon ? color.new(#FFB300, 0) : inNY ? color.new(#E65100, 0) :
         inLondon ? color.new(#01579B, 0) : inAsia ? color.new(#6A1B9A, 0) : color.new(#546E7A, 0)

    string gapStateStr = isGapUp ? "GAP UP  +" + str.tostring(math.round(gapPct, 2)) + "%" :
         isGapDown ? "GAP DN  " + str.tostring(math.round(gapPct, 2)) + "%" : "No Gap"
    color  gapStateCol = isGapUp ? color.new(#1B5E20, 0) : isGapDown ? color.new(#B71C1C, 0) : LBL_C

    string lastGapStr = not na(lastGapPct) ?
         (lastGapIsUp ? "+" : "") + str.tostring(math.round(lastGapPct, 2)) + "%" : "---"
    color  lastGapCol = not na(lastGapPct) ?
         (lastGapIsUp ? color.new(#1B5E20, 0) : color.new(#B71C1C, 0)) : LBL_C

    table.cell(dash, 0, 0, "SESSION PULSE", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[JOAT]",        text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    table.cell(dash, 0, 2, "Session",       text_color=LBL_C,   text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 2, sessStr,         text_color=sessCol, text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Gap State",     text_color=LBL_C,       text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 3, gapStateStr,     text_color=gapStateCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 4, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 4, "", bgcolor=SEP_BG, text_size=size.tiny)

    table.cell(dash, 0, 5, "Gaps Up",       text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(up_total) + " events",
         text_color=color.new(#1B5E20, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Gaps Down",     text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(dn_total) + " events",
         text_color=color.new(#B71C1C, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 7, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 7, "", bgcolor=SEP_BG, text_size=size.tiny)

    table.cell(dash, 0, 8, "Last Gap",      text_color=LBL_C,        text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 8, lastGapStr,      text_color=lastGapCol,   text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 9, "Up Cont %",     text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 9, fmt(up_contPct),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    table.cell(dash, 0, 10, "Dn Cont %",    text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 10, fmt(dn_contPct),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── UNIFIED GAP STATISTICS TABLE ──────────────────────────────────────────────
// Gap Up rows appear ABOVE Gap Down rows — both in a single table at selected position.
resolvePos(string p) =>
    switch p
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        => position.bottom_right

var table tblStats = na

if barstate.islast and showTable
    color cBg   = color.new(#0D1117, 5)
    color cSep  = color.new(#080D13, 0)
    color cHdr  = color.new(#0D1117, 0)
    color cGray = color.new(#546E7A, 0)
    color cWht  = color.new(#B0BEC5, 0)

    tblStats := table.new(resolvePos(tablePos), 6, 7,
         border_color=color.new(#546E7A, 60), border_width=1,
         frame_color=color.new(#546E7A, 50), frame_width=1)

    // ── GAP UP section (rows 0-2) ──────────────────────────────────────────
    table.cell(tblStats, 0, 0, "GAP UP",   bgcolor=cHdr, text_color=color.new(#1B5E20, 0), text_size=size.small)
    table.cell(tblStats, 1, 0, "Avg Gap",  bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 2, 0, "Cont %",   bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 3, 0, "Cont O-C", bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 4, 0, "Fade %",   bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 5, 0, "n=" + str.tostring(up_total), bgcolor=cHdr, text_color=color.new(#0097A7, 0), text_size=size.tiny)

    table.cell(tblStats, 0, 1, "Stats",              bgcolor=cBg, text_color=cWht,                    text_size=size.tiny)
    table.cell(tblStats, 1, 1, "+" + fmt(up_avgGap), bgcolor=cBg, text_color=color.new(#1B5E20, 0),   text_size=size.tiny)
    table.cell(tblStats, 2, 1, fmt(up_contPct),      bgcolor=cBg, text_color=cWht,                    text_size=size.tiny)
    table.cell(tblStats, 3, 1, fmt(up_avgContC),     bgcolor=cBg, text_color=signClr(up_avgContC),    text_size=size.tiny)
    table.cell(tblStats, 4, 1, fmt(up_fadePct),      bgcolor=cBg, text_color=cWht,                    text_size=size.tiny)
    table.cell(tblStats, 5, 1, fmt(up_avgFadeC),     bgcolor=cBg, text_color=signClr(up_avgFadeC),    text_size=size.tiny)

    // ── Separator row ──────────────────────────────────────────────────────
    for col = 0 to 5
        table.cell(tblStats, col, 2, "", bgcolor=cSep, text_size=size.tiny)

    // ── GAP DOWN section (rows 3-5) ────────────────────────────────────────
    table.cell(tblStats, 0, 3, "GAP DN",   bgcolor=cHdr, text_color=color.new(#B71C1C, 0), text_size=size.small)
    table.cell(tblStats, 1, 3, "Avg Gap",  bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 2, 3, "Cont %",   bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 3, 3, "Cont O-C", bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 4, 3, "Bnc %",    bgcolor=cHdr, text_color=cGray, text_size=size.tiny)
    table.cell(tblStats, 5, 3, "n=" + str.tostring(dn_total), bgcolor=cHdr, text_color=color.new(#0097A7, 0), text_size=size.tiny)

    table.cell(tblStats, 0, 4, "Stats",           bgcolor=cBg, text_color=cWht,                 text_size=size.tiny)
    table.cell(tblStats, 1, 4, fmt(dn_avgGap),    bgcolor=cBg, text_color=color.new(#B71C1C, 0),text_size=size.tiny)
    table.cell(tblStats, 2, 4, fmt(dn_contPct),   bgcolor=cBg, text_color=cWht,                 text_size=size.tiny)
    table.cell(tblStats, 3, 4, fmt(dn_avgContC),  bgcolor=cBg, text_color=signClr(dn_avgContC), text_size=size.tiny)
    table.cell(tblStats, 4, 4, fmt(dn_bouncePct), bgcolor=cBg, text_color=cWht,                 text_size=size.tiny)
    table.cell(tblStats, 5, 4, fmt(dn_avgBncC),   bgcolor=cBg, text_color=signClr(dn_avgBncC),  text_size=size.tiny)

    // ── Summary row ────────────────────────────────────────────────────────
    for col = 0 to 5
        table.cell(tblStats, col, 5, "", bgcolor=cSep, text_size=size.tiny)

    int totalGaps = up_total + dn_total
    table.cell(tblStats, 0, 6, "Total Gaps", bgcolor=cHdr, text_color=cGray,               text_size=size.tiny)
    table.cell(tblStats, 1, 6, str.tostring(totalGaps), bgcolor=cHdr, text_color=cWht,    text_size=size.tiny)
    table.cell(tblStats, 2, 6, "Up Bias",    bgcolor=cHdr, text_color=cGray,               text_size=size.tiny)
    float upBias = totalGaps > 0 ? up_total * 100.0 / totalGaps : 0.0
    table.cell(tblStats, 3, 6, fmt(upBias),  bgcolor=cHdr, text_color=signClr(upBias - 50), text_size=size.tiny)
    table.cell(tblStats, 4, 6, "",           bgcolor=cHdr, text_size=size.tiny)
    table.cell(tblStats, 5, 6, "",           bgcolor=cHdr, text_size=size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(isGapDown,       "Gap Down Detected",  "Session Pulse: Gap Down detected")
alertcondition(isGapUp,         "Gap Up Detected",    "Session Pulse: Gap Up detected")
alertcondition(sessAsiaStart,   "Asia Session Open",  "Session Pulse: Asia session opened")
alertcondition(sessLondonStart, "London Session Open","Session Pulse: London session opened")
alertcondition(sessNYStart,     "NY Session Open",    "Session Pulse: New York session opened")
````
