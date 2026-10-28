# 1st Presented Fvg's [M1D]

- url: https://www.tradingview.com/script/F5NnGLLy-1st-Presented-Fvg-s-M1D/
- type: indicator
- pine_id: PUB;c2abb754e6c64dfdb8ac0d6eb54b4fc5
- version: 8.0

## Description

[b]OVERVIEW[/b]

1st Presented Fvg's (M1D) isolates the very first Fair Value Gap each hourly window prints —
the one everything else in that hour reacts to — and tracks its full lifecycle: does it
hold, does it fail, does it invert, and does the inversion validate on a retest. Instead of
marking every FVG on the chart, it keeps only the one gap the model cares about per hour and
reports what happened to it.

It is a single-timeframe, event-tracking tool rather than a signal generator. It tags one
gap per hourly window, runs a strict hold / fail / invert / validate state machine on it, and
rolls a running Hold %, Inverted count and Valid IFVG count into a small dashboard so you can
see how the current session is actually behaving.

Detection and every state transition evaluate on confirmed bars only — nothing is decided
intrabar, and the chart requires an intraday timeframe of 60 minutes or less.

[b]WHAT IT PLOTS[/b]

- 1st Presented FVG zone — a coloured box drawn from the exact three-candle gap, labelled
  with its hourly window (e.g. "1st - 2pm") and an optional macro-window time suffix (e.g.
  "1st - 2pm 1:50-2:10"). Zone colour cycles through your chosen palette by hour.
- NY Open tag — inside the 9:30-10:00 NY session specifically, the gap is labelled "1st -
  NY Open" instead of the generic hour label, and only appears once price has swept a recent
  pivot high or low first (see Key Definitions below).
- Inversion (IFVG) tag — a gap that held, then closed through, turns orange and is
  relabelled IFVG.
- Valid IFVG tag (✔) — once an inverted gap is retested (price trades back into it), it
  gains a check mark and a brighter fill, so a live, usable IFVG stands out from one still
  forming.
- Failed gap (optional) — a gap that closed through without ever holding can be kept on
  chart dimmed for context, or deleted outright; either way it is counted in the stats.
- Dashboard (M1D) — a small monospace table showing the current session, current time, and
  a Today vs. Total read of gaps tagged, gaps held, Hold %, gaps inverted, and validated
  IFVGs.

[b]KEY DEFINITIONS[/b]

- Held — the point at which a 1st Presented FVG is considered to have defended its zone,
  rather than just being tagged. Governed by the Hold Definition setting below.
- Reject & Close Away (default Hold Definition) — price must trade into the gap and then
  close back outside its proximal edge before it counts as held. A tap that closes through
  without that rejection is scored as a fail, not a hold — so Hold % reflects confirmed
  rejections, not every incidental touch.
- Touch & Hold (alternate Hold Definition) — any trade into the gap that doesn't close
  through it counts as held immediately, no rejection required.
- Inversion (IFVG) — a gap that held first, then later closed through it. This sequence is
  mandatory: a gap that runs straight through without ever holding is a fail, never an
  inversion.
- Valid IFVG — an inverted gap that price has subsequently traded back into.
- Hold % — held gaps ÷ gaps tagged, shown separately for Today and All-Time.
- NY Open liquidity sweep — inside the 9:30-10:00 New York session, the 1st Presented tag
  runs on its own daily slot, separate from the normal hourly one, so an earlier random gap
  in the same clock hour can't use up the slot before the open range even happens. That slot
  only fills once price has swept a recent confirmed swing pivot — a low for a bullish gap,
  a high for a bearish gap — immediately before the gap forms, so the tag reflects a genuine
  liquidity grab rather than the first random three-candle gap after 9:30.

[b]HOW TO USE IT[/b]

[b]Reading the state of the current gap[/b]
- A live-coloured zone with no orange means the 1st Presented FVG is still fresh or holding
  — treat it as an active zone.
- Orange means it has inverted — price closed through it after holding, so it now has the
  opposite role.
- Orange with a ✔ means the inversion has been retested and validated — the strongest read
  of the three, since price has both flipped the gap and come back to confirm it.
- A dimmed zone (if you keep failed gaps) means it closed through without ever holding —
  context only, not a level to lean on.

[b]Reading the dashboard[/b]
- Hold % (Today vs. All-Time) tells you how respected first-hour gaps have been — a low
  reading suggests today's imbalances are being run through rather than defended.
- Inverted vs. Valid IFVG counts show how often a failed gap actually resolves into a
  confirmed continuation level (✔) rather than just failing outright.
- Session tells you which killzone you're in without leaving the chart.

[b]Choosing your settings[/b]
- Use Reject & Close Away when you only want gaps that show a confirmed rejection —
  Touch & Hold is looser and counts the first touch, useful for comparing how often price
  even reaches the gap versus how often it truly holds.
- Switch Mode to First Of Each Direction if you want to track a bullish and a bearish 1st
  gap side-by-side within the same hour, instead of only the first of either.
- Turn on the Displacement Filter if you want the tag to skip small, low-conviction gaps in
  favour of the next one that clears your ATR multiple.
- Leave NY Open: Require Liquidity Sweep on if you specifically want the opening-range gap
  isolated from the generic hourly noise; adjust Pivot Lookback to make the swing-pivot
  reference tighter (fewer bars, more sensitive) or wider (more bars, more established swings).

[b]SETTINGS[/b]

- Detection — 1st FVG Mode (First Of Either / First Of Each Direction), Hourly Window
  Timezone, Displacement Filter (ATR × multiple), Restrict To Time Window, NY Open (9:30-
  10:00): Require Liquidity Sweep, Pivot Lookback.
- Inversion (IFVG) — Track Inversions toggle, Hold Definition (Touch & Hold / Reject &
  Close Away).
- Labels — Show Labels, Label Text prefix, Show Macro Window Time, Label Size, Label
  Colour.
- Colours — Colours In Cycle (2 or 3), the cycle colours, Inversion Colour, Zone
  Transparency.
- Display — Gap Lifetime (Until Invalidated / End Of Hour / End Of Day), Keep Failed Gaps
  (Dimmed), Max Gaps On Chart.
- Stats Table — Show Stats Table, Position, Text Size.

This is a decision-support and context tool for discretionary ICT trading. It does not
generate buy or sell signals and does not place trades. This is not financial advice, and no
market's past behaviour is indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © M1D

//@version=6
indicator("1st Presented FVG+ (M1D)", "1st PFVG+", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// The 1st Presented FVG of the New York open, kept as a reference level.
//
// ANCHORS. On each weekday the first gap whose gap candle opens inside 9:31-10:00 New York is that
// day's anchor. The 9:30 candle may start a gap but is never the gap. It stays on the chart for a set span from the candle that made it, because that
// is the horizon it gets traded back to over. Every anchor ends on one shared right edge a set number
// of bars ahead of price. Charts of five minutes and below only.
//
// BODY-READ EDGES. A gap is found wick to wick, then each edge is pulled in to the body where the
// neighbouring bodies already sit clear of one another, on the reading that the consequential part
// of a gap is the part no body traded through. Off, it stays wick to wick, which is the wider reading.

// == CONSTANTS ==
string NY_TZ     = "America/New_York"
int    ST_FRESH  = 0     // formed, untested
int    ST_HELD   = 1     // traded into and held price
int    ST_TAPPED = 2     // entered the gap, rejection not yet confirmed
int    ST_BROKEN = 3     // price has closed through - still drawn for its span

// == INPUTS ==
string GRP_A = "Anchors"
string GRP_D = "Detection"
string GRP_L = "Labels"
string GRP_C = "Colours"
string GRP_T = "Table"

bool   anchorMon   = input.bool(true, "Mon", inline = "ad", group = GRP_A, tooltip = "The weekdays that get a anchor. Untick a day to drop its anchor.")
bool   anchorTue   = input.bool(true, "Tue", inline = "ad", group = GRP_A)
bool   anchorWed   = input.bool(true, "Wed", inline = "ad", group = GRP_A)
bool   anchorThu   = input.bool(true, "Thu", inline = "ad", group = GRP_A)
bool   anchorFri   = input.bool(true, "Fri", inline = "ad", group = GRP_A)
int    anchorFromM = input.int(571, "Window opens (minutes past midnight NY)", minval = 0, maxval = 1439, group = GRP_A, tooltip = "571 = 9:31. The GAP candle - the middle one of the three - must open at 9:31 or later, so the 9:30 candle can never be the gap itself. It can still be the FIRST candle of the three: on a 1-minute chart the earliest pattern is 9:30, 9:31, 9:32. On a 5-minute chart it is 9:30, 9:35, 9:40.")
int    anchorToM   = input.int(600, "Window closes", minval = 0, maxval = 1439, group = GRP_A, tooltip = "600 = 10:00. The third candle of the gap must CLOSE by this time.")
float  anchorWeeks = input.float(2.0, "Keep for (weeks)", minval = 0.0, maxval = 8.0, step = 0.5, group = GRP_A, tooltip = "How long a anchor stays live FROM THE CANDLE THAT MADE IT. Once the span has passed the anchor stops at its end date and no longer rides ahead of price. 0 = no time limit. CALENDAR time, so 2 weeks reads as about 10 trading days.")
int    edgeBars    = input.int(100, "Right edge (bars ahead of price)", minval = 1, maxval = 500, group = GRP_A, tooltip = "Every live anchor ends on ONE shared right edge this many bars ahead of the live candle, and its label sits at that edge. Counted in chart bars, so the edge sits the same distance on screen on a 1-minute and a 5-minute chart.")
int    anchorWidth = input.int(1, "Border width", minval = 1, maxval = 4, group = GRP_A)
int    maxKeepInput = input.int(18, "Max anchors on chart", minval = 4, maxval = 96, group = GRP_A, tooltip = "The oldest anchor past its span goes first. A live anchor is never removed to make room.")

bool   bodyRefine    = input.bool(true, "Read gap edges from the BODIES when the prints sit outside", group = GRP_D, tooltip = "A gap is found wick-to-wick, then each edge is pulled in to the BODY where the neighbouring bodies already sit clear of one another - the consequential part of the gap is the part no body traded through. Off = pure wick-to-wick, the wider reading.")
bool   showSb        = input.bool(true, "Detect Suspension Blocks", group = GRP_D, tooltip = "Three same-direction candles, each opening beyond the previous close: a volume imbalance on both seams. The zone runs from the first close to the last open and is labelled SB. It only replaces the gap it sits on, so which gap is the 1st Presented does not change.")
int    minTicks      = input.int(4, "Minimum gap size (ticks)", minval = 1, group = GRP_D, tooltip = "A floor in ticks, independent of the ATR filter below, so a one-tick gap is never the 1st Presented of anything.")
bool   dispOnInput   = input.bool(false, "Displacement Filter", group = GRP_D, inline = "d1")
float  dispMultInput = input.float(0.4, "ATR ×", minval = 0.0, step = 0.1, group = GRP_D, inline = "d1", tooltip = "Minimum gap height as a multiple of ATR(14). A smaller gap is skipped and the next qualifying gap in the window becomes the 1st Presented.")
int    maxTfMin      = input.int(5, "Highest chart timeframe (minutes)", minval = 1, maxval = 60, group = GRP_D, tooltip = "A 1st Presented FVG is a low-timeframe reading. Above this the script draws nothing rather than drawing something it does not mean.")
string holdDefInput  = input.string("Reject & Close Away", "Hold definition (Held alert)", options = ["Touch & Hold", "Reject & Close Away"], group = GRP_D, tooltip = "When the Held alert fires. Touch & Hold: any trade into the gap that does not close through. Reject & Close Away: price enters the gap AND closes back outside its proximal edge.")

bool   showLblInput  = input.bool(true, "Show labels", group = GRP_L, tooltip = "The name sits inside the zone at its right edge, centred on the midline, and carries the day and the date.")
bool   dateInLbl     = input.bool(true, "Date in the label", group = GRP_L, tooltip = "Renders as e.g. \"1st P.FVG Thu 10/9\" - the day, then day/month.")
string prefixInput   = input.string("1st", "Label prefix", group = GRP_L, tooltip = "Default renders as e.g. '1st P.FVG Thu 10/9'.")
string lblSizeInput  = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = GRP_L)
color  lblColInput   = input.color(#000000, "Label colour", group = GRP_L)
bool   showMidInput  = input.bool(true, "Consequent encroachment line", group = GRP_L, tooltip = "The dotted midline through the gap, running to the zone's right edge.")

color  bisiColInput  = input.color(#0069d3, "BISI colour", group = GRP_C, tooltip = "A bullish gap. The zone, its midline and its table row take this colour.")
color  sibiColInput  = input.color(#F23645, "SIBI colour", group = GRP_C, tooltip = "A bearish gap. The zone, its midline and its table row take this colour.")
int    transpInput   = input.int(65, "Zone transparency", minval = 0, maxval = 95, group = GRP_C)

bool   showTblInput  = input.bool(true, "Show table", group = GRP_T)
float  nearPtsInput  = input.float(100.0, "Near (points)", minval = 0.0, step = 5.0, group = GRP_T, tooltip = "A anchor reads NEAR when price is within this many points of its nearest edge. 100 by default for NQ; MNQ trades the same price so the same number applies. Set it for any other instrument.")
string tblPosInput   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_T)
string tblSizeInput  = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = GRP_T)
string layoutIn = input.string("Desktop", "Layout", options = ["Desktop", "Phone"], group = GRP_T, tooltip = "Phone: the table in tiny text with its main rows only, for a narrow portrait screen. Nothing else on the chart changes.")
bool   phone    = layoutIn == "Phone"

// == TYPES ==
type FPFVG
    float  top                  // upper boundary of the gap
    float  bottom               // lower boundary of the gap
    int    dir                  // 1 = BISI (support), -1 = SIBI (resistance)
    int    state     = 0        // lifecycle state (ST_* constants)
    int    fwdEnd    = 0        // end of the anchor's span, 0 = none
    int    bornT     = 0        // bar time of the candle that completed the gap
    box    zone      = na
    label  tag       = na       // the right-edge label
    line   mid       = na       // dotted consequent-encroachment line
    bool   sb        = false    // the gap sits on a suspension block, and the zone is the block

// == FUNCTIONS ==
//@function The macro window ending on a given New York hour, e.g. 5 -> "04:50-05:10".
//@param h (int) Hour the macro ends on, 0-23.
//@returns (string) The window, 24-hour.
f_macroTxt(int h) =>
    str.format("{0,number,00}:50-{1,number,00}:10", (h + 23) % 24, h)

//@function The table reading for the hourly macro: the one running now, otherwise the last one to
//          finish. Macros run from :50 to :10 past the next hour, New York time.
//@returns (string) e.g. "Now 05:50-06:10" or "04:50-05:10".
f_macroNow() =>
    int h = hour(timenow, NY_TZ)
    int m = minute(timenow, NY_TZ)
    m >= 50 ? "Now " + f_macroTxt((h + 1) % 24) : m < 10 ? "Now " + f_macroTxt(h) : f_macroTxt(h)

//@function Whether this bar completes a gap inside the window on a anchor weekday: the GAP candle
//          (the middle of the three) opens at or after the window opens, and the third closes by the
//          time it closes. The opening candle may start a gap but can never be the gap.
//@returns (bool) True when a anchor may be tagged on this bar.
f_inAnchorWindow() =>
    int d = dayofweek(time, NY_TZ)
    bool dayOk  = (d == dayofweek.monday and anchorMon) or (d == dayofweek.tuesday and anchorTue) or (d == dayofweek.wednesday and anchorWed) or (d == dayofweek.thursday and anchorThu) or (d == dayofweek.friday and anchorFri)
    int startM  = hour(time[1], NY_TZ) * 60 + minute(time[1], NY_TZ)
    // Read one millisecond before the close, so a candle closing at midnight stays on its own day.
    // Read at the close itself, 23:59 closes at 00:00 = minute 0, which passed "closes by 10:00" and let
    // a 11:58 PM gap take the next day's anchor before the New York open had printed.
    int endM    = hour(time_close - 1, NY_TZ) * 60 + minute(time_close - 1, NY_TZ)
    dayOk and startM >= anchorFromM and endM < anchorToM and dayofmonth(time[2], NY_TZ) == dayofmonth(time, NY_TZ)

//@function A short day name, e.g. "Mon".
//@param t (int) Bar time.
//@returns (string) Three-letter day name.
f_dayName(int t) =>
    int d = dayofweek(t, NY_TZ)
    string r = switch d
        dayofweek.monday    => "Mon"
        dayofweek.tuesday   => "Tue"
        dayofweek.wednesday => "Wed"
        dayofweek.thursday  => "Thu"
        =>                     "Fri"
    r

//@function Pulls a wick-to-wick gap in to its body edges where the neighbouring bodies already sit
//          clear of one another. Only the edges that qualify move, so a gap whose bodies overlap
//          keeps its wick boundary on that side.
//@param isBull (bool) Direction of the gap.
//@param wTop (float) Wick-derived top.
//@param wBot (float) Wick-derived bottom.
//@returns ([float, float]) The refined top and bottom.
f_bodyRefine(bool isBull, float wTop, float wBot) =>
    float rTop = wTop
    float rBot = wBot
    if bodyRefine and bar_index > 2
        float body2Top = math.max(close[2], open[2])
        float body2Bot = math.min(close[2], open[2])
        float body1Top = math.max(close[1], open[1])
        float body1Bot = math.min(close[1], open[1])
        float body0Top = math.max(close, open)
        float body0Bot = math.min(close, open)
        if isBull
            if body2Top < body1Bot
                rBot := body2Top
            if body1Top < body0Bot
                rTop := body0Bot
        else
            if body2Bot > body1Top
                rTop := body2Bot
            if body1Bot > body0Top
                rBot := body0Top
    [rTop, rBot]

//@function Resolves a size string input to a size.* constant.
//@param s (string) "tiny" | "small" | "normal".
//@returns (string) size.* constant.
f_size(string s) =>
    string r = switch s
        "tiny"  => size.tiny
        "small" => size.small
        =>         size.normal
    r

//@function Classifies the currently active session, New York time.
//@returns (string) Active session name.
f_session() =>
    int m = hour(timenow, NY_TZ) * 60 + minute(timenow, NY_TZ)
    string s = switch
        m >= 120  and m < 300  => "London KZ"
        m >= 300  and m < 510  => "Pre-NY"
        m >= 510  and m < 630  => "NY KZ"
        m >= 630  and m < 1080 => "Post-NY"
        m >= 1080 and m < 1320 => "Asia KZ"
        =>                        "Dead Zone"
    s

//@function Whether a anchor is still inside its span.
//@param g (FPFVG) The anchor.
//@returns (bool) True while live.
f_live(FPFVG g) =>
    g.fwdEnd == 0 or g.fwdEnd > time

//@function The distance from price to a gap's nearest edge, 0 when price is inside it.
//@param g (FPFVG) The gap.
//@returns (float) Distance in points.
f_dist(FPFVG g) =>
    close > g.top ? close - g.top : close < g.bottom ? g.bottom - close : 0.0

// == BASE SERIES ==
float  atrVal  = ta.atr(14)
bool   newDay  = bool(ta.change(time("D")))
bool   tfOk    = timeframe.isintraday and timeframe.in_seconds() <= maxTfMin * 60
int    rightT  = na(time_close) ? time : time_close
// The one shared right edge: the close time of the bar `edgeBars` ahead, read from the symbol's own
// session calendar so a Friday edge lands in Sunday's bars rather than inside the weekend.
int    projT   = nz(time_close(timeframe.period, bars_back = -edgeBars), rightT)
string lblSize = f_size(lblSizeInput)

// == STATE ==
//@variable Every anchor kept on the chart.
var array<FPFVG> gaps = array.new<FPFVG>(0)

//@variable One anchor per day.
var bool taggedAnchor = false
if newDay
    taggedAnchor := false

// Per-bar event counters — alert booleans derive from these at script scope
int evCntNew  = 0
int evCntHeld = 0

// == HOLD TRACKING (confirmed bars only) ==
// Transitions read st0, the state at loop entry, so a gap cannot be tapped and held on the same bar.
// This loop runs BEFORE detection, so a gap's own formation bar can never move it.
if barstate.isconfirmed
    for g in gaps
        int st0 = g.state
        if st0 != ST_BROKEN
            bool through = g.dir == 1 ? close < g.bottom : close > g.top
            bool into    = g.dir == 1 ? close >= g.bottom and low <= g.top : close <= g.top and high >= g.bottom
            bool reject  = g.dir == 1 ? close >= g.top : close <= g.bottom
            if through
                g.state := ST_BROKEN
            if not through and st0 == ST_FRESH and into
                if holdDefInput == "Touch & Hold"
                    g.state   := ST_HELD
                    evCntHeld += 1
                if holdDefInput == "Reject & Close Away"
                    g.state := ST_TAPPED
            if not through and st0 == ST_TAPPED and reject
                g.state   := ST_HELD
                evCntHeld += 1

// == DETECTION ==
bool  rawBull = bar_index > 1 and low > high[2]
bool  rawBear = bar_index > 1 and high < low[2]
float wickTop = rawBull ? low : low[2]
float wickBot = rawBull ? high[2] : high
[refTop, refBot] = f_bodyRefine(rawBull, wickTop, wickBot)

// A suspension block: three same-direction candles, each opening beyond the previous close, so the
// bodies never trade back through the leg. The block's span always contains the wick gap's, so on a
// gap that is also a block the zone becomes the block. A join across a session break is not one.
float sbBarMs = timeframe.in_seconds(timeframe.period) * 1000.0
bool  sbContig = (time - time[1]) <= sbBarMs * 1.5 and (time[1] - time[2]) <= sbBarMs * 1.5
bool  sbUp  = showSb and rawBull and sbContig and close[2] > open[2] and close[1] > open[1] and close > open and open[1] > close[2] and open > close[1]
bool  sbDn  = showSb and rawBear and sbContig and close[2] < open[2] and close[1] < open[1] and close < open and open[1] < close[2] and open < close[1]
bool  isSb  = sbUp or sbDn
float gapTop = isSb ? (sbUp ? open : close[2]) : refTop
float gapBot = isSb ? (sbUp ? close[2] : open) : refBot

// Two independent floors: one in ticks so a one-tick gap is never "the 1st Presented", and the ATR
// filter on top when it is switched on.
// Sized on the gap itself, before any volume imbalance or block widens it, so the widening never
// changes WHICH gap is the 1st Presented.
bool  ticksOk = (refTop - refBot) >= minTicks * syminfo.mintick
bool  sizeOk  = ticksOk and (not dispOnInput or (refTop - refBot) >= atrVal * dispMultInput)

bool  inWin   = f_inAnchorWindow()
bool  tagOk   = barstate.isconfirmed and tfOk and sizeOk and not taggedAnchor and inWin
bool  tagBull = tagOk and rawBull
bool  tagBear = tagOk and rawBear

if tagBull or tagBear
    int    gDir   = tagBull ? 1 : -1
    color  gCol   = tagBull ? bisiColInput : sibiColInput
    string dstr   = str.tostring(dayofmonth(time, NY_TZ)) + "/" + str.tostring(month(time, NY_TZ))
    string txt    = prefixInput + (isSb ? " P.SB " : " P.FVG ") + f_dayName(time) + (dateInLbl ? " " + dstr : "")
    // End of the span: fixed from the candle that MADE the gap. Until then the anchor rides the shared
    // edge; after it, the zone stops at that date. 0 = no end.
    int    ancEnd = anchorWeeks == 0.0 ? 0 : int(time + anchorWeeks * 7.0 * 86400000.0)
    int    gRight = ancEnd != 0 ? math.min(projT, ancEnd) : projT
    float  gMidPx = math.avg(gapTop, gapBot)
    box gBox = box.new(isSb ? time[2] : time[1], gapTop, gRight, gapBot,
         xloc         = xloc.bar_time,
         border_color = color.new(gCol, transpInput),
         border_width = anchorWidth,
         border_style = line.style_solid,
         bgcolor      = color.new(gCol, transpInput))
    // A real label, never box text: inside the zone at its RIGHT edge, centred on the midline, the
    // text running back left.
    label gLbl = na
    if showLblInput
        gLbl := label.new(gRight, gMidPx, txt,
             xloc      = xloc.bar_time,
             yloc      = yloc.price,
             style     = label.style_label_right,
             color     = color.new(color.white, 100),
             textcolor = lblColInput,
             size      = lblSize,
             text_formatting = text.format_bold + text.format_italic)
    // The consequent encroachment. Dotted, so it never reads as a boundary; it runs to the zone's
    // right edge.
    line gMid = na
    if showMidInput
        gMid := line.new(isSb ? time[2] : time[1], gMidPx, gRight, gMidPx,
             xloc  = xloc.bar_time,
             color = color.new(gCol, math.min(50, transpInput + 10)),
             style = line.style_dotted,
             width = 1)
    gaps.push(FPFVG.new(top = gapTop, bottom = gapBot, dir = gDir, state = ST_FRESH, fwdEnd = ancEnd, bornT = time, zone = gBox, tag = gLbl, mid = gMid, sb = isSb))
    taggedAnchor := true
    evCntNew     += 1

// == OBJECT CAP ==
// The oldest anchor past its span goes first. A live anchor is never removed; if every anchor held is
// live, the cap yields.
while gaps.size() > maxKeepInput
    int drop = -1
    int scan = 0
    while drop == -1 and scan < gaps.size()
        if not f_live(gaps.get(scan))
            drop := scan
        scan += 1
    if drop == -1
        break
    FPFVG old = gaps.remove(drop)
    box.delete(old.zone)
    if not na(old.tag)
        label.delete(old.tag)
    if not na(old.mid)
        line.delete(old.mid)

// == ROLL RIGHT EDGE ==
// Every anchor ends on ONE shared edge a fixed number of bars ahead of price, or at the end of its
// span once that has passed, with the label on that edge.
for g in gaps
    int rt = g.fwdEnd != 0 ? math.min(projT, g.fwdEnd) : projT
    g.zone.set_right(rt)
    if not na(g.mid)
        line.set_x2(g.mid, rt)
    if not na(g.tag)
        label.set_x(g.tag, rt)

// == TABLE ==
string tblPos = switch tblPosInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

string tblSize = phone ? size.tiny : f_size(tblSizeInput)

//@variable Table instance: two columns, name and reading, no merged cells.
var table stats = na
if showTblInput and na(stats)
    stats := table.new(tblPos, 2, 5, bgcolor = color.new(#ffffff, 100), frame_color = color.new(#000000, 0), frame_width = 1, border_color = color.new(#000000, 0), border_width = 1)

//@function Writes one name/reading row of the table.
//@param r    (int) Row index.
//@param name (string) Row name.
//@param val  (string) Reading.
//@param col  (color) Text colour for both cells.
//@param tip  (string) Tooltip on the reading.
//@returns (void)
f_row(int r, string name, string val, color col, string tip) =>
    table.cell(stats, 0, r, name, text_color = col, text_size = tblSize, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_bold + text.format_italic)
    table.cell(stats, 1, r, val, text_color = col, text_size = tblSize, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = tip)

//@function The table row for the most recent live anchor made on one weekday. Draws nothing when
//          there is none, so the row drops rather than reading "none".
//@param r   (int) Row index to write.
//@param dow (int) dayofweek.* of the anchor to find.
//@returns (int) The next free row.
f_dayRow(int r, int dow) =>
    int next = r
    FPFVG hit = na
    int n = gaps.size()
    if n > 0
        for k = n - 1 to 0
            FPFVG c = gaps.get(k)
            if na(hit) and f_live(c) and dayofweek(c.bornT, NY_TZ) == dow
                hit := c
    if not na(hit)
        float d    = f_dist(hit)
        string pts = str.tostring(d, format.mintick)
        string val = d == 0.0 ? "Inside" : d <= nearPtsInput ? "Near · " + pts + " pts" : pts + " pts"
        string nm  = f_dayName(hit.bornT) + " " + str.tostring(dayofmonth(hit.bornT, NY_TZ)) + "/" + str.tostring(month(hit.bornT, NY_TZ)) + (hit.sb ? (hit.dir == 1 ? " SB+" : " SB-") : hit.dir == 1 ? " BISI" : " SIBI")
        f_row(r, nm, val, hit.dir == 1 ? #000000 : sibiColInput, "Distance from the close to the zone's nearest edge: " + str.tostring(hit.bottom, format.mintick) + " - " + str.tostring(hit.top, format.mintick) + ". Near = within " + str.tostring(nearPtsInput) + " pts.")
        next := r + 1
    next

if showTblInput and barstate.islast
    table.clear(stats, 0, 0, 1, 4)
    int live = 0
    for g in gaps
        if f_live(g)
            live += 1
    f_row(0, "1st PFVG+", tfOk ? f_session() : "Use <= " + str.tostring(maxTfMin) + "m chart", #000000, "Current New York session.")
    if not phone
        f_row(1, "Active", str.tostring(live) + " on chart", #000000, "Anchors still inside their span.")
        f_row(2, "Macro", f_macroNow(), #000000, "The hourly macro, New York time: :50 to :10 past the next hour. Reads Now while one is running, otherwise the last one to finish.")
    int nextRow = f_dayRow(phone ? 1 : 3, dayofweek.monday)
    f_dayRow(nextRow, dayofweek.friday)

// == ALERTS ==
bool ev1st  = evCntNew > 0
bool evHeld = evCntHeld > 0

alertcondition(ev1st,  "1st Presented FVG", "1st Presented FVG on {{ticker}} ({{interval}})")
alertcondition(evHeld, "1st FVG Held",      "1st Presented FVG held price on {{ticker}} @ {{close}}")

max_bars_back(time, 500)
````
