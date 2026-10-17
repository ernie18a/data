# Futures Sessions with NY Opening Range, Levels, FVGs, & Holidays

- url: https://www.tradingview.com/script/ZD0tG4Lg-Futures-Sessions-with-NY-Opening-Range-Levels-FVGs-Holidays/
- type: indicator
- pine_id: PUB;5cdb7b3575454873ae2d2342a59ccf3e
- version: 3.0

## Description

This is a session-anchored intraday framework for futures. Every element on the chart is derived from the same session definitions, so the tools stay consistent with each other: the sessions paint the ranges, the completed ranges leave behind levels, the level lifecycle is tied to the session clock, the NY Opening Range anchors the morning, fair value gaps give context inside the ranges, and holiday markers explain the days when sessions are missing or shortened.

[b]Session Ranges[/b]
Each market session is defined using IANA names (America/New_York, Asia/Tokyo) – never fixed UTC offsets. The indicator renders identically no matter what timezone your chart is set to (Exchange, New York, etc). Daylight saving is handled automatically: New York flips between EST and EDT on its own, and Tokyo has no DST, so its position against the New York clock simply shifts with the US clock changes (Tokyo's 9:00 open lands at 20:00 New York in summer, 19:00 in winter).

Each session is a shaded fill: Asia in red, London in yellow, New York in blue as defaults.

NY Pre-Open: a dotted range tracks the morning trade from the ORB open at 8:00 America/New_York until the session fill starts at 9:30. It is derived from the ORB input, so moving the ORB moves it too.

Globex Open: the CME futures trading day opens at 18:00 America/New_York (17:00 Chicago), indicated by the pre-open dotted range before the session fill starts at Tokyo open when volume comes in.

[b]New York Opening Range (ORB)[/b]
The ORB captures the range of the America/New_York 8:00–8:15 candle, shown as a box with a dashed midline in maroon. It is visible on all smaller timeframes and up to 1h. The ORB ends on the last candle of the New York session — the end time is derived from the NY session input, so the two can never drift apart.

If the ORB range is oversized (18 or more points, configurable), the box is flagged with a red "ORB INVALID" label and shows the range in points.

[b]Sessions Levels (Untested Highs and Lows)[/b]
When a session completes, its final highs (black) and lows (teal) are drawn from the candle and extend to the right indefinitely until a level is tested on its first touch. You can configure whether a test means a wick touch (ICT/liquidity style, the default) or a candle close beyond the level (support/resistance style).

Tested levels stay on the chart until the session running at the time of the test ends, so you can use them as points of reference until then. During the London/NY overlap, New York counts as the running session. A level tested during a session gap survives the gap and is handed to the next session that opens. At the NY ORB open at 8:00, all tested levels are removed to prevent clutter.

Untested levels never expire. You can toggle the prices on the price scale on or off based on preference.

[b]Fair Value Gaps[/b]
Classic three-candle imbalances in both directions: bullish when a candle's low is above the high from two candles back, bearish when a candle's high is below the low from two candles back. Gaps are shaded in green (by default, configurable) from the middle candle and extend to the right until price trades fully through it (bullish: a low at or below the gap bottom; bearish: a high at or above the gap top), then it is removed. Each gap can draw its Consequent Encroachment — a dashed line at the 50% of the gap, the level where a gap is commonly considered mitigated. Inputs: fill color, CE toggle and color, minimum gap size in points (useful on low timeframes), and a cap on how many gaps are kept.

[b]Holiday Markers[/b]
US (NYSE) holidays: a dotted vertical line and a Statue of Liberty marker anchored to the ORB's first candle. Detection is fully rule-based — weekday-observance rules for every holiday, and Good Friday computed from the Easter algorithm (Butcher's computus), so nothing is hardcoded and no yearly maintenance is needed. 
Note: NYSE does not observe New Year's on the prior Friday when January 1 falls on a Saturday, and holidays observed on a Friday/Monday (like July 4 on a weekend) are marked on the actual closure day.

Japanese holidays: a dotted vertical line and a shrine marker anchored to the Tokyo session's first candle. Covers the fixed-date holidays, the Happy Monday holidays, both equinox holidays (astronomical formulas, valid through 2150), Monday substitute holidays, the occasional Silver Week citizens' holiday, and the TSE year-end closures (Dec 31, Jan 2, Jan 3).

Markers sit at the bottom of the pane. Days when CME is fully closed have no bars, so there is nothing to mark — markers appear on holidays with shortened or normal trading.

[b]Alert[/b]
One built-in alert condition: Tokyo Range Break — fires when price closes outside the completed Tokyo session range, active from the Tokyo close until 11:30 New York time.

[b]How to Use[/b]
Built for intraday charts of 1h and below (it draws nothing on higher timeframes). The ORB needs a 15-minute chart or lower to line up with whole candles. Defaults are tuned for CME index futures (ES/MES); the session inputs work on any symbol with continuous futures-style hours. Old drawings persist until Pine's 500-object limits trim the oldest.

These tools are combined because each one feeds the next: the sessions define the ranges, the completed ranges produce the levels, the level lifecycle runs on the session clock and the ORB open, the pre-open dotted ranges share the same derived timings, and the holiday markers explain the days when the rest of the framework is dark. Changing one session input moves everything that depends on it, consistently.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GodPlays888

//@version=6
indicator("Futures Sessions with NY Opening Range, Levels, FVGs, & Holidays", shorttitle="Sess Orb + Fvg", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// =====================================================================
// HOW TIMEZONES ARE HANDLED
// ---------------------------------------------------------------------
// Every session is defined in its OWN timezone using IANA names
// ("America/New_York", "Asia/Tokyo") passed directly to time() and
// timestamp(). TradingView converts those to bar time internally, so
// the drawing is identical no matter what timezone the chart is set
// to — Exchange, New York, UTC, Tokyo, anything.
//
// IANA names also track daylight saving automatically:
//   America/New_York = EST in winter (UTC-5), EDT in summer (UTC-4)
//   Asia/Tokyo       = JST always (UTC+9, no DST)
//
// HOW SESSIONS ARE DRAWN
// ---------------------------------------------------------------------
// Each session is shaded as a FILL between its running high and its
// running low — the color hugs the price action and expands as the
// session makes new highs/lows. No boxes, borders, or lines are drawn
// for sessions. The NY ORB is the only element drawn as a box.
//
// Sessions:
//   1. London        03:00-12:00 New York time
//   2. New York      09:30-17:00 New York time
//   3. Tokyo         09:00-15:30 Tokyo time (JST)
//   4. NY ORB        08:00-08:15 New York candle — box + dashed midline,
//                    ends exactly when the New York session ends
//   5. Session Levels — when a session completes, its high (black) and
//                    low (teal) extend right forever. A level dies once
//                    price tests it, BUT if the test happens during a
//                    running session the line stays until that session
//                    ends, and only then is removed.
//   6. Holiday Markers — US (NYSE) holidays: green dotted vertical line
//                    + 🗽 anchored to the NY ORB's first candle (derived
//                    from the ORB input). Japanese holidays: red dotted
//                    vertical line + ⛩️ anchored to the Tokyo session's
//                    first candle. Emojis are pinned to the BOTTOM of
//                    the pane, not to price. Rule-based detection, each
//                    in its own calendar's timezone.
// =====================================================================

string NY_TZ = "America/New_York"

// Draw only on intraday charts up to 60 minutes.
canDraw = timeframe.isintraday and timeframe.in_seconds() <= 3600

styleOf(string s) =>
    s == "solid" ? line.style_solid : s == "dashed" ? line.style_dashed : line.style_dotted

// =====================================================================
// INPUTS — SESSIONS (range fill only)
// =====================================================================
grpTok = "Tokyo Session (09:00-15:30 Tokyo time)"
showTokyo = input.bool(true,                      "Show Tokyo Session",                  group=grpTok)
tokyoSess = input.session("0900-1530",            "Session Hours (in session timezone)", group=grpTok)
tokyoTz   = input.string("Asia/Tokyo",            "Session Timezone (IANA name)",        group=grpTok)
tokyoFill = input.color(color.new(color.red, 85), "Range Fill Color",                    group=grpTok)
showTokPre = input.bool(true,                     "Show Globex Open Range (dotted, 18:00 NY until Tokyo open)", group=grpTok)
futOpenSess = input.session("1800-2000",          "Globex Open Window (New York time)",  group=grpTok)

grpLon = "London Session (03:00-12:00 New York time)"
showLondon = input.bool(true,                         "Show London Session",                 group=grpLon)
londonSess = input.session("0300-1200",               "Session Hours (in session timezone)", group=grpLon)
londonTz   = input.string("America/New_York",         "Session Timezone (IANA name)",        group=grpLon)
londonFill = input.color(color.new(color.yellow, 85), "Range Fill Color",                    group=grpLon)

grpNy = "New York Session (09:30-17:00 New York time)"
showNy = input.bool(true,                        "Show New York Session",               group=grpNy)
nySess = input.session("0930-1700",              "Session Hours (in session timezone)", group=grpNy)
nyTz   = input.string("America/New_York",        "Session Timezone (IANA name)",        group=grpNy)
nyFill = input.color(color.new(color.blue, 85),  "Range Fill Color",                    group=grpNy)
showNyPre = input.bool(true,                     "Show Futures Pre-Open Range (dotted, ORB start until session open)", group=grpNy)

// =====================================================================
// INPUTS — NY ORB (the only element drawn as a box)
// =====================================================================
grpOrb = "NY ORB (08:00-08:15 New York time candle, ends with NY session)"
showOrb   = input.bool(true,                          "Show NY ORB Box",                        group=grpOrb)
orbSess   = input.session("0800-0815",                "ORB Capture Window (New York time)",     group=grpOrb)
orbBorder = input.color(color.maroon,                 "Border Color",                           group=grpOrb)
orbBWidth = input.int(1,                              "Border Width", minval=1, maxval=5,       group=grpOrb)
orbFill   = input.color(color.new(color.maroon, 90),  "Box Fill",                               group=grpOrb)
orbMidCol = input.color(color.maroon,                 "Midline Color",                          group=grpOrb)
orbMidSty = input.string("dashed",                    "Midline Style", options=["solid","dashed","dotted"], group=grpOrb)
orbMaxPts = input.float(18.0,                         "Invalid if ORB Range ≥ (points)", minval=0.0, step=0.25, group=grpOrb)

// =====================================================================
// INPUTS — SESSION LEVELS
// =====================================================================
grpLvl = "Session Levels (post-session highs & lows)"
showLevels = input.bool(true,         "Show Session Levels", group=grpLvl)
lvlHighCol = input.color(color.black, "Session High Color",  group=grpLvl)
lvlLowCol  = input.color(color.aqua,  "Session Low Color",   group=grpLvl)
lvlWidth   = input.int(1,             "Line Width", minval=1, maxval=10, group=grpLvl)
lvlStyleIn = input.string("solid",    "Line Style", options=["solid","dashed","dotted"], group=grpLvl)
showLvlPx  = input.bool(true,         "Show Level Prices on Price Scale", group=grpLvl)
lvlTestIn  = input.string("Wick touch", "Level Test Trigger", options=["Wick touch", "Candle close"], group=grpLvl, tooltip="What counts as a test that invalidates a level. Wick touch: any touch of the level. Candle close: only a candle closing at or beyond the level.")
strongCol  = input.color(color.maroon, "Strong Level Color", group=grpLvl, tooltip="A level that has been wick-tapped on two separate occasions with no candle ever closing beyond it is promoted to this color — wicks alone could not break it. Normal removal rules still apply; a candle closing through it demotes it back.")
// Built-in (not user-configurable): live levels are capped at 150,
// trimmed outside-in (furthest from price first) so Pine's 500-line
// budget can never overflow and garbage-collect level lines.
int lvlMax = 150

// =====================================================================
// INPUTS — HOLIDAY MARKERS
// =====================================================================
grpHol = "Holiday Markers"
showUsHol  = input.bool(true,         "Mark US (NYSE) Holidays — 🗽 at NY ORB start", group=grpHol)
usHolColor = input.color(#089981,     "US Holiday Line Color",                        group=grpHol)
showJpHol  = input.bool(true,        "Mark Japanese Holidays — ⛩️ at Tokyo open",    group=grpHol)
jpHolColor = input.color(color.red,  "Japan Holiday Line Color",                     group=grpHol)

// =====================================================================
// INPUTS — FAIR VALUE GAPS
// =====================================================================
grpFvg = "Fair Value Gaps"
showFvg   = input.bool(true,                        "Show Fair Value Gaps",       group=grpFvg)
fvgColor  = input.color(color.new(#A5D6A7, 65),     "FVG Fill Color",             group=grpFvg)
fvgMinPts = input.float(0.0,                        "Minimum Gap Size (points)", minval=0.0, step=0.25, group=grpFvg)
fvgMax    = input.int(50,                           "Maximum FVGs Kept", minval=1, maxval=200, group=grpFvg)
fvgShowCE = input.bool(true,                        "Show CE Midline (50%)",      group=grpFvg)
fvgCECol  = input.color(#388E3C,                    "CE Midline Color",           group=grpFvg)
// Built-in retention (not user-configurable): pre-open dotted ranges,
// ORB boxes/midlines/labels older than 15 sessions are deleted so the
// drawing budgets can never overflow and garbage-collect level lines.
int keepDays = 15

// =====================================================================
// SESSION RANGE TRACKING
// =====================================================================
tokyoIn  = not na(time(timeframe.period, tokyoSess, tokyoTz))
londonIn = not na(time(timeframe.period, londonSess, londonTz))
nyIn     = not na(time(timeframe.period, nySess, nyTz))

trackHiLo(bool inSess) =>
    var float hi = na
    var float lo = na
    var int hiTime = na
    var int loTime = na
    if inSess and not inSess[1]
        hi := high
        lo := low
        hiTime := time
        loTime := time
    else if inSess
        if high > hi
            hi := high
            hiTime := time
        if low < lo
            lo := low
            loTime := time
    [hi, lo, hiTime, loTime]

[tokyoHi, tokyoLo, tokyoHiTime, tokyoLoTime]     = trackHiLo(tokyoIn)
[londonHi, londonLo, londonHiTime, londonLoTime] = trackHiLo(londonIn)
[nyHi, nyLo, nyHiTime, nyLoTime]                 = trackHiLo(nyIn)

// =====================================================================
// SESSION RANGE FILLS — shading between running session high and low.
// The plot lines themselves are fully transparent; only the fill shows.
// =====================================================================
invis = color.new(color.white, 100)

// display excludes the price scale so the session high/low plots never
// put labels on the price axis by default.
noScale = display.all - display.price_scale

pTokyoHi  = plot(showTokyo and tokyoIn and canDraw ? tokyoHi : na,   "Tokyo High",  color=invis, editable=false, display=noScale)
pTokyoLo  = plot(showTokyo and tokyoIn and canDraw ? tokyoLo : na,   "Tokyo Low",   color=invis, editable=false, display=noScale)
fill(pTokyoHi, pTokyoLo, color=tokyoFill, title="Tokyo Range Fill")

pLondonHi = plot(showLondon and londonIn and canDraw ? londonHi : na, "London High", color=invis, editable=false, display=noScale)
pLondonLo = plot(showLondon and londonIn and canDraw ? londonLo : na, "London Low",  color=invis, editable=false, display=noScale)
fill(pLondonHi, pLondonLo, color=londonFill, title="London Range Fill")

pNyHi     = plot(showNy and nyIn and canDraw ? nyHi : na,             "NY High",     color=invis, editable=false, display=noScale)
pNyLo     = plot(showNy and nyIn and canDraw ? nyLo : na,             "NY Low",      color=invis, editable=false, display=noScale)
fill(pNyHi, pNyLo, color=nyFill, title="NY Range Fill")

// =====================================================================
// PRE-OPEN DOTTED RANGES — futures trade before the shaded sessions
// begin, and these dotted outlines make that visible:
//  - Asia: the CME Globex daily open is 18:00 New York time (17:00
//    Chicago). A dotted range tracks the high/low from 18:00 NY until
//    the Tokyo fill starts. The window input reaches to 20:00 NY and
//    is cut off by the Tokyo session itself, so it self-adjusts when
//    Tokyo's 9:00 JST lands on 19:00 NY in winter.
//  - New York: a dotted range from the ORB capture open (8:00 NY by
//    default, derived from the ORB input) until the NY fill starts.
// The outline is the running high, running low, and a left edge at
// the open — drawn in the session's fill color at full opacity. Old
// days persist until the 500-line limit trims them.
// =====================================================================
drawPreRange(bool show, bool inPre, color col) =>
    var float hi = na
    var float lo = na
    var line top = na
    var line bot = na
    var line lft = na
    // Retention: only the last keepDays sessions' outlines are kept, so
    // these lines can never saturate Pine's global 500-line budget.
    var array<line> kept = array.new<line>()
    if inPre and not inPre[1]
        hi := high
        lo := low
        if show and canDraw
            top := line.new(time, hi, time, hi, xloc=xloc.bar_time, style=line.style_dotted, color=col, width=1)
            bot := line.new(time, lo, time, lo, xloc=xloc.bar_time, style=line.style_dotted, color=col, width=1)
            lft := line.new(time, hi, time, lo, xloc=xloc.bar_time, style=line.style_dotted, color=col, width=1)
            array.push(kept, top)
            array.push(kept, bot)
            array.push(kept, lft)
            while array.size(kept) > keepDays * 3
                line.delete(array.shift(kept))
    else if inPre
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        if not na(top)
            line.set_x2(top, time)
            line.set_y1(top, hi)
            line.set_y2(top, hi)
            line.set_x2(bot, time)
            line.set_y1(bot, lo)
            line.set_y2(bot, lo)
            line.set_y1(lft, hi)
            line.set_y2(lft, lo)
    // Explicit return so the if/else branches above don't need matching
    // types (Pine treats a function's last statement as its return).
    true

// NY pre-open: ORB start → NY session start, both derived from inputs.
nyPreStr = array.get(str.split(orbSess, "-"), 0) + "-" + array.get(str.split(array.get(str.split(nySess, "-"), 0), ":"), 0)
nyPreIn  = not na(time(timeframe.period, nyPreStr, NY_TZ)) and not nyIn
// Asia pre-open: Globex open window, cut off when Tokyo begins.
tokyoPreIn = not na(time(timeframe.period, futOpenSess, NY_TZ)) and not tokyoIn

drawPreRange(showNyPre, nyPreIn, color.new(nyFill, 0))
drawPreRange(showTokPre, tokyoPreIn, color.new(tokyoFill, 0))

// =====================================================================
// NY ORB — captures the 08:00-08:15 NY candle's range. The box grows
// bar by bar and stops on the last bar of the New York session, so it
// always ends exactly where the NY session fill ends — never projected
// into the overnight halt or the future.
// ---------------------------------------------------------------------
// Use a chart timeframe of 15 minutes or lower so the capture window
// lines up with whole candles (on a 15m chart it is exactly the 8:00
// candle). Old ORB boxes persist across days until the 500-object
// limit trims the oldest.
// =====================================================================
orbCapture = not na(time(timeframe.period, orbSess, NY_TZ))
// The ORB box only draws on 15m charts and below: coarser candles
// can't resolve the 8:00-8:15 window (a 1h chart would capture the
// whole 8:00-9:00 candle and flag "invalid" on a range that isn't the
// opening range at all). The 8:00 anchor itself — level purge, holiday
// marker — still works on every intraday timeframe.
orbTfOk = canDraw and timeframe.in_seconds() <= 900
// Display window runs from the ORB start to the NY session's end time
// (derived from the NY session input above), e.g. "0800-1700".
orbWinStr  = array.get(str.split(orbSess, "-"), 0) + "-" + array.get(str.split(array.get(str.split(nySess, "-"), 1), ":"), 0)
orbWindow  = not na(time(timeframe.period, orbWinStr, NY_TZ))
orbNew     = orbCapture and not orbCapture[1]
var float orbHi  = na
var float orbLo  = na
var box   orbBox = na
var line  orbMid = na
var label orbInvalidLbl = na
// Retention: past ORB days beyond keepDays are deleted so old boxes,
// midlines, and invalid labels can't exhaust the drawing budgets.
var array<box>   orbOldBoxes = array.new<box>()
var array<line>  orbOldMids  = array.new<line>()
var array<label> orbOldLbls  = array.new<label>()
if orbNew
    orbHi := high
    orbLo := low
    // New day, new ORB — drop the reference so a fresh warning label
    // can be created if today's range is also oversized. Old labels
    // stay on the chart with their boxes until retention trims them.
    orbInvalidLbl := na
    if showOrb and orbTfOk
        orbBox := box.new(time, orbHi, time, orbLo, xloc=xloc.bar_time, border_color=orbBorder, border_width=orbBWidth, border_style=line.style_solid, bgcolor=orbFill)
        orbMid := line.new(time, math.avg(orbHi, orbLo), time, math.avg(orbHi, orbLo), xloc=xloc.bar_time, color=orbMidCol, style=styleOf(orbMidSty), width=1)
        array.push(orbOldBoxes, orbBox)
        array.push(orbOldMids, orbMid)
        while array.size(orbOldBoxes) > keepDays
            box.delete(array.shift(orbOldBoxes))
            line.delete(array.shift(orbOldMids))
        while array.size(orbOldLbls) > keepDays
            label.delete(array.shift(orbOldLbls))
else if orbCapture
    orbHi := math.max(orbHi, high)
    orbLo := math.min(orbLo, low)
    if not na(orbBox)
        box.set_top(orbBox, orbHi)
        box.set_bottom(orbBox, orbLo)
        line.set_y1(orbMid, math.avg(orbHi, orbLo))
        line.set_y2(orbMid, math.avg(orbHi, orbLo))
// Extend the right edge only while the display window is open. The
// edge is pinned to the bar's OPEN time so the box terminates on the
// session's last candle itself — flush with the NY range fill, and
// never rendered at the halt seam where the crosshair reads the next
// day's 18:00 reopen.
if orbWindow and not na(orbBox)
    box.set_right(orbBox, time)
    line.set_x2(orbMid, time)
// Oversized ORB = invalid. Once the captured range reaches the
// threshold, a warning label is pinned to the box's top-left corner;
// it keeps updating while the capture window is still open (the range
// can only grow, so a box never goes back to valid).
if orbCapture and showOrb and orbTfOk and not na(orbBox) and orbHi - orbLo >= orbMaxPts
    if na(orbInvalidLbl)
        orbInvalidLbl := label.new(box.get_left(orbBox), orbHi, "", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.small)
        array.push(orbOldLbls, orbInvalidLbl)
    label.set_y(orbInvalidLbl, orbHi)
    label.set_text(orbInvalidLbl, "⚠ ORB INVALID — " + str.tostring(orbHi - orbLo, "#.##") + " pts")

// =====================================================================
// SESSION LEVELS — when a session completes, its final high (black)
// and low (teal) are drawn from the candle that made them and extend
// right indefinitely. A level is "tested" on its first touch (wick
// counts — the default, matching the untested-liquidity convention),
// or only on a candle close beyond it if the Level Test Trigger input
// is set to "Candle close".
// Grace rule: a level tested while a session is running stays on the
// chart until THAT session ends, then disappears. A level tested
// during a session gap (no session running) survives the gap and is
// handed to the NEXT session that opens — it stays until that session
// ends. Additionally, ALL tested levels are purged at the NY ORB open
// (8:00 New York by default) so the session overlap can't carry them
// into the New York morning. Untested levels never expire.
// =====================================================================
tokyoEnded  = tokyoIn[1] and not tokyoIn
londonEnded = londonIn[1] and not londonIn
nyEnded     = nyIn[1] and not nyIn
tokyoStarted  = tokyoIn and not tokyoIn[1]
londonStarted = londonIn and not londonIn[1]
nyStarted     = nyIn and not nyIn[1]

// Session ids for the grace bookkeeping. The "current" session during
// the London/NY overlap is New York — the most recently opened one.
// ID_NEXT marks a level tested during a gap, waiting to be adopted by
// the next session that opens.
ID_TOKYO  = 1
ID_LONDON = 2
ID_NY     = 3
ID_NEXT   = 4
currentSessId = nyIn ? ID_NY : londonIn ? ID_LONDON : tokyoIn ? ID_TOKYO : 0

var array<line>  lvlLines   = array.new<line>()
var array<float> lvlPrices  = array.new<float>()
var array<bool>  lvlIsHigh  = array.new<bool>()
var array<int>   lvlPending = array.new<int>()   // 0 = untested, else id of the session whose end removes it
var array<int>   lvlSrc     = array.new<int>()   // id of the session that produced the level
var array<int>   lvlTaps    = array.new<int>()   // count of separate wick-tap events on the level
var array<bool>  lvlTouchPrev = array.new<bool>()// whether the PREVIOUS bar touched (so consecutive touching bars count as one tap)
var array<bool>  lvlClosedThru = array.new<bool>()// a candle has closed beyond the level — disqualifies "strong" forever
var array<bool>  lvlStrong  = array.new<bool>()  // promoted to strong (recolored)

f_removeLevel(int i) =>
    line.delete(array.get(lvlLines, i))
    array.remove(lvlLines, i)
    array.remove(lvlPrices, i)
    array.remove(lvlIsHigh, i)
    array.remove(lvlPending, i)
    array.remove(lvlSrc, i)
    array.remove(lvlTaps, i)
    array.remove(lvlTouchPrev, i)
    array.remove(lvlClosedThru, i)
    array.remove(lvlStrong, i)

f_flushPending(int sid) =>
    if array.size(lvlLines) > 0
        for i = array.size(lvlLines) - 1 to 0
            if array.get(lvlPending, i) == sid
                f_removeLevel(i)

f_addLevels(float hi, float lo, int hiT, int loT, int sid) =>
    // x2 is anchored one bar-width right of x1 (extend.right makes the
    // exact x2 cosmetic). Using "now" as x2 breaks when the extreme was
    // made on the CURRENT candle — e.g. London topping right at the
    // 9:30 snapshot — because both points collapse into one and the
    // extended line renders vertical instead of horizontal.
    int lvlX2 = timeframe.in_seconds() * 1000
    array.push(lvlLines, line.new(hiT, hi, hiT + lvlX2, hi, xloc=xloc.bar_time, extend=extend.right, color=lvlHighCol, style=styleOf(lvlStyleIn), width=lvlWidth))
    array.push(lvlPrices, hi)
    array.push(lvlIsHigh, true)
    array.push(lvlPending, 0)
    array.push(lvlSrc, sid)
    array.push(lvlTaps, 0)
    array.push(lvlTouchPrev, true)   // creation bar can sit on the level; it is formation, not a tap
    array.push(lvlClosedThru, false)
    array.push(lvlStrong, false)
    array.push(lvlLines, line.new(loT, lo, loT + lvlX2, lo, xloc=xloc.bar_time, extend=extend.right, color=lvlLowCol, style=styleOf(lvlStyleIn), width=lvlWidth))
    array.push(lvlPrices, lo)
    array.push(lvlIsHigh, false)
    array.push(lvlPending, 0)
    array.push(lvlSrc, sid)
    array.push(lvlTaps, 0)
    array.push(lvlTouchPrev, true)
    array.push(lvlClosedThru, false)
    array.push(lvlStrong, false)

if showLevels and canDraw
    // 1) A session just ended → levels that were tested during it die now.
    if tokyoEnded
        f_flushPending(ID_TOKYO)
    if londonEnded
        f_flushPending(ID_LONDON)
    if nyEnded
        f_flushPending(ID_NY)
    // 1b) At the NY ORB open (8:00 New York by default, derived from
    //     the ORB input) every level that has already been tested is
    //     purged, whatever session it was tagged to — the London/NY
    //     overlap otherwise keeps overnight-tested levels lingering
    //     through the New York morning.
    if orbNew and array.size(lvlLines) > 0
        for i = array.size(lvlLines) - 1 to 0
            if array.get(lvlPending, i) != 0
                f_removeLevel(i)
    // 2) Completed sessions leave behind their high/low levels — except
    //    London, whose levels are DYNAMIC: they are snapshotted at the
    //    NYSE open (9:30 New York, the NY session start input) from
    //    London's running high/low, because from the cash open New York
    //    owns the tape — nobody trades London afterwards. From that
    //    moment they live by the same rules as every other level:
    //    tested during the still-running London session → removed when
    //    London ends.
    if tokyoEnded and showTokyo
        f_addLevels(tokyoHi, tokyoLo, tokyoHiTime, tokyoLoTime, ID_TOKYO)
    if nyStarted and showLondon and londonIn
        f_addLevels(londonHi, londonLo, londonHiTime, londonLoTime, ID_LONDON)
    if nyEnded and showNy
        f_addLevels(nyHi, nyLo, nyHiTime, nyLoTime, ID_NY)
    // 3) A session just opened → it adopts levels that were tested
    //    during the preceding gap; they die when this session ends.
    if array.size(lvlPending) > 0 and (tokyoStarted or londonStarted or nyStarted)
        adoptId = nyStarted ? ID_NY : londonStarted ? ID_LONDON : ID_TOKYO
        for i = 0 to array.size(lvlPending) - 1
            if array.get(lvlPending, i) == ID_NEXT
                array.set(lvlPending, i, adoptId)
    // 4) Test untested levels against this candle, per the Level Test
    //    Trigger input (wick touch or candle close). A test during a
    //    gap tags the level ID_NEXT instead of removing it.
    if array.size(lvlLines) > 0
        for i = array.size(lvlLines) - 1 to 0
            if array.get(lvlPending, i) == 0 and not array.get(lvlStrong, i)
                bool  isHi = array.get(lvlIsHigh, i)
                float p    = array.get(lvlPrices, i)
                float src  = lvlTestIn == "Candle close" ? close : isHi ? high : low
                if (isHi and src >= p) or (not isHi and src <= p)
                    array.set(lvlPending, i, currentSessId == 0 ? ID_NEXT : currentSessId)
    // 5) Strong levels: a level wick-tapped on two SEPARATE occasions
    //    (consecutive touching bars count as one tap) with no candle
    //    ever closing beyond it is promoted — wicks alone could not
    //    break it. Promotion CLEARS any tested state, so a strong
    //    level survives session-end removal and the 8:00 purge even
    //    in wick-touch mode; wicks can never remove it. Only a candle
    //    CLOSING through a strong level breaks it: it is demoted and
    //    marked tested at that moment, then follows the normal grace
    //    rules.
    if array.size(lvlLines) > 0
        for i = 0 to array.size(lvlLines) - 1
            bool  sHi   = array.get(lvlIsHigh, i)
            float sP    = array.get(lvlPrices, i)
            bool  touch = sHi ? high >= sP : low <= sP
            bool  thru  = sHi ? close > sP : close < sP
            if thru and not array.get(lvlClosedThru, i)
                array.set(lvlClosedThru, i, true)
                if array.get(lvlStrong, i)
                    array.set(lvlStrong, i, false)
                    line.set_color(array.get(lvlLines, i), sHi ? lvlHighCol : lvlLowCol)
                    array.set(lvlPending, i, currentSessId == 0 ? ID_NEXT : currentSessId)
            if touch and not array.get(lvlTouchPrev, i) and not array.get(lvlClosedThru, i)
                array.set(lvlTaps, i, array.get(lvlTaps, i) + 1)
                if array.get(lvlTaps, i) >= 2 and not array.get(lvlStrong, i)
                    array.set(lvlStrong, i, true)
                    line.set_color(array.get(lvlLines, i), strongCol)
                    array.set(lvlPending, i, 0)
            array.set(lvlTouchPrev, i, touch)
    // 6) Bound the live-level count so the total line count stays under
    //    Pine's 500-line budget and level lines can never be silently
    //    garbage-collected. Trimming works OUTSIDE-IN: the level
    //    furthest from the current price is dropped first, so the
    //    levels nearest to where price is trading are always kept.
    while array.size(lvlLines) > lvlMax
        int worst = 0
        float worstDist = math.abs(array.get(lvlPrices, 0) - close)
        for i = 1 to array.size(lvlPrices) - 1
            float d = math.abs(array.get(lvlPrices, i) - close)
            if d > worstDist
                worstDist := d
                worst := i
        f_removeLevel(worst)

// =====================================================================
// LEVEL PRICES ON THE PRICE SCALE — display.price_scale plots draw NO
// line on the chart, only the value bubble on the right axis. Pine
// cannot put arbitrary line drawings on the axis, so plots are used;
// a bubble disappears the moment its level is removed from the chart.
// =====================================================================
// Pine plot counts are fixed at compile time, so twelve slots label
// the twelve MOST RECENT levels still alive, whatever session they
// came from. Slot color follows the level type (high vs low).
f_lvlSlot(int idx) =>
    int n = array.size(lvlPrices)
    idx < n ? array.get(lvlPrices, n - 1 - idx) : float(na)
f_lvlSlotCol(int idx) =>
    int n = array.size(lvlIsHigh)
    idx < n and array.get(lvlIsHigh, n - 1 - idx) ? lvlHighCol : lvlLowCol

showPx = showLevels and showLvlPx and canDraw
plot(showPx ? f_lvlSlot(0)  : na, "Level Price 1",  color=f_lvlSlotCol(0),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(1)  : na, "Level Price 2",  color=f_lvlSlotCol(1),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(2)  : na, "Level Price 3",  color=f_lvlSlotCol(2),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(3)  : na, "Level Price 4",  color=f_lvlSlotCol(3),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(4)  : na, "Level Price 5",  color=f_lvlSlotCol(4),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(5)  : na, "Level Price 6",  color=f_lvlSlotCol(5),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(6)  : na, "Level Price 7",  color=f_lvlSlotCol(6),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(7)  : na, "Level Price 8",  color=f_lvlSlotCol(7),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(8)  : na, "Level Price 9",  color=f_lvlSlotCol(8),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(9)  : na, "Level Price 10", color=f_lvlSlotCol(9),  display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(10) : na, "Level Price 11", color=f_lvlSlotCol(10), display=display.price_scale, editable=false)
plot(showPx ? f_lvlSlot(11) : na, "Level Price 12", color=f_lvlSlotCol(11), display=display.price_scale, editable=false)

// =====================================================================
// ALERT — Tokyo range break, active after the Tokyo close until
// 11:30 New York time.
// =====================================================================
var bool tokyoAlertActive = false
var int  tokyoAlertUntil  = na
if tokyoEnded
    tokyoAlertUntil := timestamp(NY_TZ, year(time, NY_TZ), month(time, NY_TZ), dayofmonth(time, NY_TZ), 11, 30)
    tokyoAlertActive := tokyoAlertUntil > time
if tokyoAlertActive and (time >= tokyoAlertUntil or tokyoIn)
    tokyoAlertActive := false

tokyoBreakUp   = tokyoAlertActive and close > tokyoHi and close[1] <= tokyoHi
tokyoBreakDown = tokyoAlertActive and close < tokyoLo and close[1] >= tokyoLo
alertcondition(tokyoBreakUp or tokyoBreakDown, title="Tokyo Range Break", message="Price has closed outside the Tokyo session range.")

// =====================================================================
// HOLIDAY MARKERS
// ---------------------------------------------------------------------
// US (NYSE) holidays: green dotted vertical line + 🗽, anchored to the
// first candle of the NY ORB capture window — derived from the ORB
// input, so it always starts exactly where the ORB box starts.
// Japanese holidays: red dotted vertical line + ⛩️, anchored to the
// first candle of the Tokyo session. The vertical lines span the whole
// pane (extend.both); the emojis are plotted with location.bottom so
// they sit pinned to the bottom strip of the chart at any zoom or
// scroll — never attached to a candle or price level.
//
// Detection is rule-based on the calendar day in each market's OWN
// timezone, so it works on any chart timezone. NOTHING is hardcoded:
//  - Every US holiday is computed from weekday rules. Good Friday is
//    derived from Easter via Butcher's computus — the exact Gregorian
//    calendar algorithm, valid for every year. (NYSE does NOT observe
//    New Year's on the prior Friday when Jan 1 falls on a Saturday, so
//    unlike the other Saturday holidays there is no Dec 31 rule.)
//  - Japanese equinox holidays are astronomical; the standard formulas
//    used here cover 1980-2099 and 2100-2150. Monday substitute
//    holidays (furikae kyūjitsu) and the occasional Silver Week
//    citizens' holiday are handled. Dec 31 / Jan 2 / Jan 3 are
//    included as TSE year-end market closures.
//  - The one thing NO formula (or API) can predict is future
//    legislation — if a country adds or moves a holiday by law, the
//    rules here need a one-line update, same as every calendar library.
//  - Days when CME is fully closed have no bars at all, so nothing can
//    be marked there — markers appear on holidays with shortened or
//    normal trading.
// =====================================================================
// Good Friday = Easter Sunday - 2 days. Easter Sunday is computed with
// Butcher's computus (exact integer arithmetic on the Gregorian
// calendar, correct for all years — the same algorithm calendar
// libraries use). Returns the Good Friday [month, day] for the year.
f_goodFriday(int y) =>
    int a  = y % 19
    int b  = y / 100
    int c  = y % 100
    int dd = b / 4
    int e  = b % 4
    int f  = (b + 8) / 25
    int g  = (b - f + 1) / 3
    int h  = (19 * a + b - dd - g + 15) % 30
    int i  = c / 4
    int k  = c % 4
    int l  = (32 + 2 * e + 2 * i - h - k) % 7
    int mm = (a + 11 * h + 22 * l) / 451
    int easterMonth = (h + l - 7 * mm + 114) / 31
    int easterDay   = (h + l - 7 * mm + 114) % 31 + 1
    int gfTs = timestamp("GMT", y, easterMonth, easterDay, 12, 0) - 2 * 86400000
    [month(gfTs, "GMT"), dayofmonth(gfTs, "GMT")]

// dow convention everywhere below: 1=Sun, 2=Mon, … 7=Sat.
f_usHoliday(int y, int m, int d, int dow) =>
    bool weekday = dow != 1 and dow != 7
    bool nyd    = m == 1  and (d == 1 and weekday or d == 2 and dow == 2)
    bool mlk    = m == 1  and dow == 2 and d >= 15 and d <= 21
    bool pres   = m == 2  and dow == 2 and d >= 15 and d <= 21
    [gfMonth, gfDay] = f_goodFriday(y)
    bool gf     = m == gfMonth and d == gfDay
    bool mem    = m == 5  and dow == 2 and d >= 25
    bool jun    = m == 6  and (d == 19 and weekday or d == 18 and dow == 6 or d == 20 and dow == 2)
    bool jul4   = m == 7  and (d == 4  and weekday or d == 3  and dow == 6 or d == 5  and dow == 2)
    bool labor  = m == 9  and dow == 2 and d >= 1  and d <= 7
    bool thanks = m == 11 and dow == 5 and d >= 22 and d <= 28
    bool xmas   = m == 12 and (d == 25 and weekday or d == 24 and dow == 6 or d == 26 and dow == 2)
    string nm = nyd ? "New Year's Day" : mlk ? "Martin Luther King Jr. Day" : pres ? "Presidents Day" : gf ? "Good Friday" : mem ? "Memorial Day" : jun ? "Juneteenth" : jul4 ? "Independence Day" : labor ? "Labor Day" : thanks ? "Thanksgiving Day" : xmas ? "Christmas Day" : ""
    [nyd or mlk or pres or gf or mem or jun or jul4 or labor or thanks or xmas, nm]

// Standard astronomical equinox-day formulas. The leading constant is
// period-specific: one pair covers 1980-2099, the next 2100-2150.
f_vernalEq(int y)  => int(math.floor((y <= 2099 ? 20.8431 : 21.8510) + 0.242194 * (y - 1980)) - math.floor((y - 1980) / 4.0))
f_autumnEq(int y)  => int(math.floor((y <= 2099 ? 23.2488 : 24.2488) + 0.242194 * (y - 1980)) - math.floor((y - 1980) / 4.0))

f_jpHoliday(int y, int m, int d, int dow) =>
    int  veq = f_vernalEq(y)
    int  aeq = f_autumnEq(y)
    bool mon = dow == 2
    bool ganjitsu   = m == 1  and (d == 1 or d == 2 and mon)
    bool yearEnd    = m == 12 and d == 31 or m == 1 and (d == 2 or d == 3)
    bool comingAge  = m == 1  and mon and d >= 8 and d <= 14
    bool foundation = m == 2  and (d == 11 or d == 12 and mon)
    bool emperor    = m == 2  and (d == 23 or d == 24 and mon)
    bool vernal     = m == 3  and (d == veq or d == veq + 1 and mon)
    bool showa      = m == 4  and (d == 29 or d == 30 and mon)
    bool goldenWeek = m == 5  and (d == 3 or d == 4 or d == 5 or d == 6 and (dow == 2 or dow == 3 or dow == 4))
    bool marine     = m == 7  and mon and d >= 15 and d <= 21
    bool mountain   = m == 8  and (d == 11 or d == 12 and mon)
    bool aged       = m == 9  and mon and d >= 15 and d <= 21
    bool citizens   = m == 9  and dow == 3 and d >= 16 and d <= 22 and d == aeq - 1
    bool autumnal   = m == 9  and (d == aeq or d == aeq + 1 and mon)
    bool sports     = m == 10 and mon and d >= 8 and d <= 14
    bool culture    = m == 11 and (d == 3 or d == 4 and mon)
    bool laborThx   = m == 11 and (d == 23 or d == 24 and mon)
    string nm = ganjitsu ? "New Year's Day (Ganjitsu)" : comingAge ? "Coming of Age Day" : foundation ? "National Foundation Day" : emperor ? "Emperor's Birthday" : vernal ? "Vernal Equinox Day" : showa ? "Showa Day" : goldenWeek ? "Golden Week Holiday" : marine ? "Marine Day" : mountain ? "Mountain Day" : aged ? "Respect for the Aged Day" : citizens ? "Citizens' Holiday (Silver Week)" : autumnal ? "Autumnal Equinox Day" : sports ? "Sports Day" : culture ? "Culture Day" : laborThx ? "Labor Thanksgiving Day" : yearEnd ? "Year-End Market Closure (TSE)" : ""
    [ganjitsu or yearEnd or comingAge or foundation or emperor or vernal or showa or goldenWeek or marine or mountain or aged or citizens or autumnal or sports or culture or laborThx, nm]

[usHol, usHolName] = f_usHoliday(year(time, NY_TZ), month(time, NY_TZ), dayofmonth(time, NY_TZ), dayofweek(time, NY_TZ))
[jpHol, jpHolName] = f_jpHoliday(year(time, tokyoTz), month(time, tokyoTz), dayofmonth(time, tokyoTz), dayofweek(time, tokyoTz))

// Marker trigger bars: US on the ORB's first candle of a US-holiday NY
// calendar day; Japan on the Tokyo session's first candle of a
// Japanese-holiday JST calendar day.
usHolMark = showUsHol and canDraw and orbNew and usHol
jpHolMark = showJpHol and canDraw and tokyoStarted and jpHol

// Vertical pane-spanning dotted lines. x1 == x2 with extend.both makes
// the line vertical and infinite in both directions — BUT the two
// anchor points must never coincide: on a zero-range candle
// (low == high, common on thin overnight opens) an anchor of
// low/high collapses to a single point, the direction becomes
// undefined, and TradingView renders the extended line HORIZONTALLY
// at that price. Anchoring at close and close + one tick keeps the
// points distinct on every bar, so the line is always vertical.
if usHolMark
    line.new(bar_index, close, bar_index, close + syminfo.mintick, extend=extend.both, color=usHolColor, style=line.style_dotted, width=1)
if jpHolMark
    line.new(bar_index, close, bar_index, close + syminfo.mintick, extend=extend.both, color=jpHolColor, style=line.style_dotted, width=1)

// Emojis pinned to the bottom strip of the pane (location.bottom keeps
// them at the bottom of the visible chart regardless of price/zoom).
// plotchar is used because its character IS the plotted glyph and
// scales with `size` — plotshape renders text at a fixed tiny size,
// while even size.normal renders enormous; size.small is the balance.
plotchar(usHolMark, "US Holiday Marker (🗽)", char="🗽", location=location.bottom, color=chart.fg_color, size=size.small, editable=false)
// One size step below the US marker on purpose: wide, chunky glyphs
// (sushi, torii) fill far more of the em box than tall thin ones
// (statue), so tiny here visually matches small there.
plotchar(jpHolMark, "Japan Holiday Marker (⛩️)", char="⛩️", location=location.bottom, color=chart.fg_color, size=size.tiny, editable=false)

// =====================================================================
// FAIR VALUE GAPS — the classic 3-candle imbalance. Bullish: the
// current candle's low is above the high from two candles back, so the
// middle candle left an unfilled gap; bearish is the mirror image.
// Each gap is drawn as a borderless shaded box starting at the middle
// candle and extending right until price trades fully through the gap
// (bullish: a low at/below the gap bottom; bearish: a high at/above
// the gap top), at which point it is removed. The oldest boxes are
// trimmed once the kept-FVG cap is reached.
// =====================================================================
var array<box>  fvgBoxes  = array.new<box>()
var array<bool> fvgIsBull = array.new<bool>()
var array<line> fvgCELns  = array.new<line>()   // Consequent Encroachment (50% of the gap); na if disabled
var array<float> fvgCE    = array.new<float>()  // CE price — the gap's invalidation line, tracked even when the CE line is hidden

// Detection is PURE candle structure — three consecutive chart candles,
// no time or session awareness. An opening gap up/down counts because
// the gap exists in the candles themselves; how much closed-market
// time sits between the bars is irrelevant.
bullFvg = low > high[2] and low - high[2] >= fvgMinPts
bearFvg = high < low[2] and low[2] - high >= fvgMinPts

// One box per gap: around large gaps, several overlapping three-candle
// windows each "discover" the same untraded range. A new FVG is only
// created where no live same-direction FVG already covers that price —
// first discovery wins, so gaps never stack duplicates.
f_overlapsLive(bool wantBull, float top, float bottom) =>
    bool hit = false
    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            if array.get(fvgIsBull, i) == wantBull
                box b = array.get(fvgBoxes, i)
                if top > box.get_bottom(b) and bottom < box.get_top(b)
                    hit := true
    hit

f_ceLine(float top, float bottom) =>
    fvgShowCE ? line.new(bar_index - 1, math.avg(top, bottom), bar_index, math.avg(top, bottom), style=line.style_dashed, color=fvgCECol, width=1) : line(na)

if showFvg and canDraw
    // Boxes are anchored at the MIDDLE candle of the pattern — the
    // displacement candle whose body spans the gap — so intraday FVGs
    // start glued to the candle that created them. (A weekend/halt gap
    // has no candle spanning it by definition; its box starts on the
    // reopen candle at the seam.)
    if bullFvg and not f_overlapsLive(true, low, high[2])
        array.push(fvgBoxes, box.new(bar_index - 1, low, bar_index, high[2], border_color=na, bgcolor=fvgColor))
        array.push(fvgIsBull, true)
        array.push(fvgCELns, f_ceLine(low, high[2]))
        array.push(fvgCE, math.avg(low, high[2]))
    if bearFvg and not f_overlapsLive(false, low[2], high)
        array.push(fvgBoxes, box.new(bar_index - 1, low[2], bar_index, high, border_color=na, bgcolor=fvgColor))
        array.push(fvgIsBull, false)
        array.push(fvgCELns, f_ceLine(low[2], high))
        array.push(fvgCE, math.avg(low[2], high))
    while array.size(fvgBoxes) > fvgMax
        box.delete(array.shift(fvgBoxes))
        array.shift(fvgIsBull)
        line.delete(array.shift(fvgCELns))
        array.shift(fvgCE)
    if array.size(fvgBoxes) > 0
        for i = array.size(fvgBoxes) - 1 to 0
            box  b      = array.get(fvgBoxes, i)
            bool isBull = array.get(fvgIsBull, i)
            // A gap dies once price trades BEYOND its CE (the 50% of the
            // original gap): reaching the midpoint rebalances the
            // imbalance, so what would remain is no longer a valid FVG.
            float ce    = array.get(fvgCE, i)
            bool filled = isBull ? low < ce : high > ce
            if filled
                box.delete(b)
                line.delete(array.get(fvgCELns, i))
                array.remove(fvgBoxes, i)
                array.remove(fvgIsBull, i)
                array.remove(fvgCELns, i)
                array.remove(fvgCE, i)
            else
                box.set_right(b, bar_index)
                // Partial fills consume the box: the traded-through
                // portion is trimmed away, so the shading only covers
                // price the market still hasn't repaired. The CE line
                // stays at the ORIGINAL gap's 50% by convention.
                if isBull and low < box.get_top(b) and low > box.get_bottom(b)
                    box.set_top(b, low)
                if not isBull and high > box.get_bottom(b) and high < box.get_top(b)
                    box.set_bottom(b, high)
                if not na(array.get(fvgCELns, i))
                    line.set_x2(array.get(fvgCELns, i), bar_index)
````
