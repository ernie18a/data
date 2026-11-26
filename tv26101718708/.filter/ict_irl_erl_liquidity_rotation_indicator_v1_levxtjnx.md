# ICT IRL ERL Liquidity Rotation Indicator v1

- url: https://www.tradingview.com/script/lEVXtJnx-ICT-IRL-ERL-Liquidity-Rotation-Indicator-v1/
- type: indicator
- pine_id: PUB;89a4266e27434fa884c73b469cacfcf9
- version: 2.0

## Description

This indicator automates a full ICT-style liquidity rotation model: it builds dealing ranges for the Daily, London, and NY AM sessions, plots OTE (Optimal Trade Entry) fib zones on each, locates a confirming Fair Value Gap inside that OTE zone across multiple timeframes (1H → 15m → 5m), and then tracks a full setup lifecycle — tap, manipulation leg, inversed-1m-FVG or CISD confirmation, and entry — from IDLE through HUNTING to TRIGGERED. A second, independent engine does the reverse: it watches key session highs/lows (London and Asia) for a liquidity sweep and runs the same manipulation-leg / iFVG / CISD confirmation logic in the opposite direction (ERL → IRL).

What it plots

Session highs/lows (Asia, London, NY AM, NY PM) with live and locked untaken-liquidity levels
NDOG/NWOG opening gaps
Daily, London, and NY Killzone dealing ranges with OTE fib levels (0, 0.5, 0.62, 0.705, 0.79, 1)
The specific FVG (labelled by timeframe and range) sitting inside each range's OTE zone
LONG/SHORT labels the moment a setup's entry trigger fires

How to use it

Run the indicator on a 1-minute chart — the entry-trigger logic is designed specifically for 1m confirmation.
Watch the two status tables (top-right: IRL→ERL per session; bottom-right: ERL→IRL per level) to see each setup's current state: IDLE (nothing happening), HUNTING (tapped and watching for confirmation), TRIGGERED (entry signal fired), or COMPLETED.
A LONG/SHORT forecast appears on the chart when a setup triggers — that's your entry signal.
All key parameters — session times, swing sensitivity, FVG timeframe priority, minimum displacement for a valid trigger — are adjustable in the settings.

Note: This is a decision-support tool, not signal-and-forget automation — always apply your own judgment and risk management before acting on any label.

## Source Code

````pine
//@version=6
indicator("ICT IRL/ERL Liquidity Rotation Model V1.0", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

if timeframe.period != "1"
    runtime.error("This indicator only supports the 1-minute timeframe. Please switch to the 1-minute timeframe!")

// =============================================================================
// PHASE 1a — SESSION INFRASTRUCTURE & HIGH/LOW LEVELS
// =============================================================================
// This is the foundation layer of the full model. It does two things:
//   1. Defines the 4 daily sessions (Asia / London / NY AM / NY PM) in your
//      local UK time.
//   2. Tracks each session's high/low live as it forms, then "locks in" the
//      completed session's high/low as an untaken liquidity level that stays
//      on the chart (and visually fades once price trades through it).
//
// =============================================================================

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------
i_timezone     = input.string("Europe/London", "Timezone (your local time)", group="Sessions")

i_asiaSess     = input.session("2300-0800", "Asia Session (prev night 11pm – 8am)",  group="Sessions")
i_londonSess   = input.session("0800-1430", "London Session (8am – 2:30pm)",         group="Sessions")
i_nyamSess     = input.session("1430-1700", "NY AM Session (2:30pm – 5pm)",          group="Sessions")
i_nypmSess     = input.session("1700-2300", "NY PM Session (5pm – 11pm)",            group="Sessions")

// Parse nykz start
int nykzStartHour = int(str.tonumber(str.substring(i_nyamSess, 0, 2)))
int nykzStartMin  = int(str.tonumber(str.substring(i_nyamSess, 2, 4)))
// nykz end
int _totalMins = nykzStartHour * 60 + nykzStartMin + 90
int nykzEndHour = _totalMins / 60
int nykzEndMin  = _totalMins % 60

i_showAsia     = input.bool(true, "Show Asia Levels",    group="Display")
i_showLondon   = input.bool(true, "Show London Levels",  group="Display")
i_showNYAM     = input.bool(true, "Show NY AM Levels",   group="Display")
i_showNYPM     = input.bool(true, "Show NY PM Levels",   group="Display")

c_asia   = color.new(color.red,   0)
c_london = color.new(color.teal,  0)
c_nyam   = color.new(#787B86,     0)   // TradingView's darkest grey swatch
c_nypm   = color.new(#787B86,     0)   // same dark grey for both NY AM and NY PM

c_labelGrey = color.new(#575757, 0)   // uniform dark grey for all text/labels

var int lonRangeStartTime  = na
var int dlyRangeStartTime  = na
var int nykzRangeStartTime = na

// -----------------------------------------------------------------------------
// FUNCTION: f_inSession
// Returns true while the current bar falls inside the given session string,
// evaluated in the chosen timezone (this is what makes BST/GMT handling
// automatic — Pine's time() function does the DST math for us).
// -----------------------------------------------------------------------------
f_inSession(_sess) =>
    not na(time(timeframe.period, _sess, i_timezone))

inAsia   = f_inSession(i_asiaSess)
inLondon = f_inSession(i_londonSess)
inNYAM   = f_inSession(i_nyamSess)
inNYPM   = f_inSession(i_nypmSess)


// -----------------------------------------------------------------------------
// FUNCTION: f_sessionTrack
// Tracks one session's high/low while it is forming, AND remembers which bar
// each extreme actually occurred on (highBar/lowBar). That bar index is what
// lets us anchor lines to the real wick instead of the session start/end bar.
// Each place this function is CALLED gets its own independent persistent
// memory (Pine keeps "var" state per call-site), so calling it 4 times below
// gives us 4 separate trackers without any extra bookkeeping.
//
// Returns: sessionHigh, sessionLow, highBar, lowBar, justStarted, justEnded
// -----------------------------------------------------------------------------
f_sessionTrack(_inSession) =>
    var float _high    = na
    var float _low     = na
    var int   _highBar = na
    var int   _lowBar  = na
    bool _started = _inSession and not _inSession[1]   // session just began this bar
    bool _ended   = not _inSession and _inSession[1]    // session just finished this bar

    if _started
        _high    := high
        _low     := low
        _highBar := bar_index
        _lowBar  := bar_index
    else if _inSession
        if high > _high
            _high    := high
            _highBar := bar_index
        if low < _low
            _low    := low
            _lowBar := bar_index

    [_high, _low, _highBar, _lowBar, _started, _ended]

[asiaHigh,   asiaLow,   asiaHighBar,   asiaLowBar,   asiaStarted,   asiaEnded]   = f_sessionTrack(inAsia)
[londonHigh, londonLow, londonHighBar, londonLowBar, londonStarted, londonEnded] = f_sessionTrack(inLondon)
[nyamHigh,   nyamLow,   nyamHighBar,   nyamLowBar,   nyamStarted,   nyamEnded]   = f_sessionTrack(inNYAM)
[nypmHigh,   nypmLow,   nypmHighBar,   nypmLowBar,   nypmStarted,   nypmEnded]   = f_sessionTrack(inNYPM)


// -----------------------------------------------------------------------------
// FUNCTION: f_drawLiveLevel
// Draws a dotted line + label for the CURRENTLY FORMING session high or low,
// anchored to the EXACT BAR where that high/low actually occurred (not just
// the session start bar) -- so the line visually touches the real wick
// instead of floating disconnected from it. As the running high/low updates
// to a new extreme, the left anchor moves to that new bar too.
// When the session ends, the live objects are deleted — the completed level
// then gets handed off to f_lockCompletedLevel below.
// -----------------------------------------------------------------------------
f_drawLiveLevel(_price, _extremeBar, _active, _sessionStarted, _col, _labelTxt) =>
    var line  _ln = na
    var label _lb = na

    if _active
        if _sessionStarted or na(_ln)
            // fresh session (or first run) -> start a new line/label
            if not na(_ln)
                line.delete(_ln)
                label.delete(_lb)
            _ln := line.new(_extremeBar, _price, bar_index, _price, color=_col, style=line.style_dotted, width=1)
            _lb := label.new(bar_index, _price, _labelTxt, color=color.new(_col, 100), textcolor=c_labelGrey, style=label.style_label_left, size=size.small)
        else
            // Update BOTH endpoints every bar: left anchor tracks to whichever
            // bar currently holds the extreme (so it stays glued to the real
            // wick even as the high/low updates), right anchor extends to now.
            line.set_xy1(_ln, _extremeBar, _price)
            line.set_xy2(_ln, bar_index, _price)
            label.set_xy(_lb, bar_index, _price)
    else if not na(_ln)
        // session ended -> remove the "live" objects (the locked version takes over)
        line.delete(_ln)
        label.delete(_lb)
        _ln := na
        _lb := na
    true


// -----------------------------------------------------------------------------
// FUNCTION: f_lockCompletedLevel
// When a session ends, this "locks in" its high/low as a persistent untaken
// liquidity level, anchored to the EXACT BAR where that high/low occurred
// (not the bar the session happened to end on) -- so it visually touches the
// real wick instead of floating off to one side of it.
// The line keeps extending right every bar until price trades through it —
// per ICT convention, a WICK through the level counts as taken, not just a
// close. Once taken, the line fades and stops extending.
// -----------------------------------------------------------------------------
f_lockCompletedLevel(_ended, _price, _extremeBar, _isHigh, _col, _labelTxt) =>
    var float _lockedPrice = na
    var line  _ln          = na
    var label _lb          = na
    var bool  _taken       = true

    if _ended
        // a freshly completed session always overrides the previous locked level.
        // delete the OLD locked line/label first, or it sits there orphaned and
        // frozen forever once the script stops updating it
        if not na(_ln)
            line.delete(_ln)
            label.delete(_lb)
        _lockedPrice := _price
        _taken := false
        _ln := line.new(_extremeBar, _price, bar_index, _price, color=_col, style=line.style_solid, width=1)
        _lb := label.new(bar_index, _price, _labelTxt, color=color.new(_col, 100), textcolor=c_labelGrey,
                          style=_isHigh ? label.style_label_down : label.style_label_up, size=size.small)
    else if not na(_lockedPrice) and not _taken
        line.set_xy2(_ln, bar_index, _lockedPrice)
        bool _justTaken = _isHigh ? high >= _lockedPrice : low <= _lockedPrice
        if _justTaken
            _taken := true
            line.set_color(_ln, color.new(_col, 70))
            line.set_style(_ln, line.style_dashed)

    [_lockedPrice, _taken]


// -----------------------------------------------------------------------------
// DRAW: live forming session levels
// -----------------------------------------------------------------------------
if i_showAsia
    f_drawLiveLevel(asiaHigh, asiaHighBar, inAsia, asiaStarted, c_asia, "Asia High")
    f_drawLiveLevel(asiaLow,  asiaLowBar,  inAsia, asiaStarted, c_asia, "Asia Low")
if i_showLondon
    f_drawLiveLevel(londonHigh, londonHighBar, inLondon, londonStarted, c_london, "London High")
    f_drawLiveLevel(londonLow,  londonLowBar,  inLondon, londonStarted, c_london, "London Low")
if i_showNYAM
    f_drawLiveLevel(nyamHigh, nyamHighBar, inNYAM, nyamStarted, c_nyam, "NY AM High")
    f_drawLiveLevel(nyamLow,  nyamLowBar,  inNYAM, nyamStarted, c_nyam, "NY AM Low")
if i_showNYPM
    f_drawLiveLevel(nypmHigh, nypmHighBar, inNYPM, nypmStarted, c_nypm, "NY PM High")
    f_drawLiveLevel(nypmLow,  nypmLowBar,  inNYPM, nypmStarted, c_nypm, "NY PM Low")


// -----------------------------------------------------------------------------
// DRAW: previous completed session levels (untaken liquidity)
// -----------------------------------------------------------------------------
if i_showAsia
    f_lockCompletedLevel(asiaEnded, asiaHigh, asiaHighBar, true,  c_asia, "Asia High")
    f_lockCompletedLevel(asiaEnded, asiaLow,  asiaLowBar,  false, c_asia, "Asia Low")
if i_showLondon
    f_lockCompletedLevel(londonEnded, londonHigh, londonHighBar, true,  c_london, "London High")
    f_lockCompletedLevel(londonEnded, londonLow,  londonLowBar,  false, c_london, "London Low")
if i_showNYAM
    f_lockCompletedLevel(nyamEnded, nyamHigh, nyamHighBar, true,  c_nyam, "NY AM High")
    f_lockCompletedLevel(nyamEnded, nyamLow,  nyamLowBar,  false, c_nyam, "NY AM Low")
if i_showNYPM
    f_lockCompletedLevel(nypmEnded, nypmHigh, nypmHighBar, true,  c_nypm, "NY PM High")
    f_lockCompletedLevel(nypmEnded, nypmLow,  nypmLowBar,  false, c_nypm, "NY PM Low")


// =============================================================================
// PHASE 1b — NDOG / NWOG (New Day / New Week Opening Gap)
// =============================================================================
// If the new session opens on a Sunday (i.e. straight after the weekend
// close), it's a WEEKLY gap (NWOG). Any other night, it's a DAILY gap
// (NDOG). Most weeknights this will be tiny or non-existent since index
// futures trade nearly continuously -- that's expected, not a bug.
// =============================================================================

i_showGaps      = input.bool(true, "Show NDOG / NWOG", group="Gaps")
i_bullGapColor  = input.color(color.new(color.blue, 80), "Bullish Gap Color (gap up)",   group="Gaps")
i_bearGapColor  = input.color(color.new(#787B86, 80),    "Bearish Gap Color (gap down)", group="Gaps")

// -----------------------------------------------------------------------------
// FUNCTION: f_drawGap
// Draws a box from the previous bar's close to the new bar's open whenever a
// genuine price gap exists at a day/week boundary. The box keeps extending
// right each bar until price trades back into that price zone, at which
// point it's marked "filled" -- fades out and stops extending.
//
// Color reflects DIRECTION (bullish gap up = blue, bearish gap down = grey),
// independent of whether it's labelled NDOG or NWOG.
// -----------------------------------------------------------------------------
f_drawGap(_trigger, _bullColor, _bearColor, _labelTxt) =>
    var box   _bx     = na
    var float _top    = na
    var float _bottom = na
    var bool  _filled = true
    var color _col    = na

    if _trigger
        float _gapTop    = math.max(close[1], open)
        float _gapBottom = math.min(close[1], open)
        bool  _hasGap    = (_gapTop - _gapBottom) > syminfo.mintick   // ignore rounding noise / non-gaps
        bool  _isBullish = open > close[1]                            // gapped UP = bullish

        if _hasGap
            if not na(_bx)
                box.delete(_bx)   // only keep the most recent NDOG/NWOG box per type, same pattern as Phase 1a
            _top    := _gapTop
            _bottom := _gapBottom
            _filled := false
            _col    := _isBullish ? _bullColor : _bearColor
            _bx := box.new(bar_index[1], _top, bar_index, _bottom, border_color=color.new(_col, 0),
                            bgcolor=_col, text=_labelTxt, text_color=c_labelGrey, text_size=size.normal)
    else if not na(_bx) and not _filled
        box.set_right(_bx, bar_index)
        bool _justFilled = high >= _bottom and low <= _top   // any wick trading back into the gap zone counts
        if _justFilled
            _filled := true
            box.set_bgcolor(_bx, color.new(_col, 95))
            box.set_border_color(_bx, color.new(_col, 60))

    true

// -----------------------------------------------------------------------------
// DRAW: NDOG / NWOG
// -----------------------------------------------------------------------------
bool   isWeeklyGap = asiaStarted and dayofweek == dayofweek.sunday
string gapLabelTxt = isWeeklyGap ? "NWOG" : "NDOG"

if i_showGaps
    f_drawGap(asiaStarted, i_bullGapColor, i_bearGapColor, gapLabelTxt)


// =============================================================================
// PHASE 2a — SWING HIGH / LOW DETECTION (on-chart, 1-minute resolution)
// =============================================================================
// This is the foundation for dealing ranges, ERL/IRL marking, and OTE levels.
// A "swing" here is a simple local-extreme pivot: a high/low with at least
// `i_swingLeft` bars lower/higher on the left and `i_swingRight` bars on the
// right -- "local extremes" as you described.
//
// IMPORTANT -- this now runs directly on your CURRENT chart timeframe
// (intended to be 1-minute, matching your entry-trigger timeframe), not a
// fixed higher timeframe via request.security().
// A pivot can only be CONFIRMED once `i_swingRight` bars have printed after
// it -- so there's an inherent few-bar lag before a swing appears live.
// =============================================================================

i_swingLeft   = input.int(2, "Swing Lookback (bars left)",  minval=1, group="Swings")
i_swingRight  = input.int(2, "Swing Lookback (bars right)", minval=1, group="Swings")

// ta.pivothigh/ta.pivotlow are Pine's built-in pivot functions -- they return
// the pivot PRICE on the bar it's confirmed, or na otherwise.
swingHighPrice = ta.pivothigh(i_swingLeft, i_swingRight)
swingLowPrice  = ta.pivotlow(i_swingLeft, i_swingRight)

// The actual bar this pivot occurred on is i_swingRight bars back from the
// confirmation bar -- used both for plotting offset and (later) for the
// dealing range window-inclusion logic.
swingHighTime = time[i_swingRight]
swingLowTime  = time[i_swingRight]

// =============================================================================
// PHASE 2b — DEALING RANGES (Premarket / London / Daily)
// =============================================================================
// A dealing range here = the highest confirmed swing high and lowest
// confirmed swing low that occur WHILE a given window is active. That top/
// bottom pair becomes the range. Drawn as a box that grows live while the
// window is open, then freezes once the window closes (same live-then-locked
// pattern as the Phase 1a session levels, just driven by swings instead of
// raw candle highs/lows).
//
// London's window already exists from Phase 1a (inLondon/londonStarted) --
// reused directly here rather than redefining it.
// =============================================================================

i_premarketSess = input.session("1230-1430", "Premarket Window (12:30pm - 2:30pm)", group="Dealing Ranges")
i_dailyDRSess   = input.session("2300-1430", "Daily Window (11pm - 2:30pm)",    group="Dealing Ranges")

i_showLondonDR    = input.bool(true, "Show London Dealing Range",    group="Dealing Ranges")
i_showDailyDR     = input.bool(true, "Show Daily Dealing Range",     group="Dealing Ranges")

c_dailyDR     = color.new(color.white,  0)

inDailyDR   = f_inSession(i_dailyDRSess)
bool dailyDRStarted   = inDailyDR and not inDailyDR[1]

// -----------------------------------------------------------------------------
// FUNCTION: f_dealingRangeTrack
// Tracks the ABSOLUTE EXTREMES (highest swing high, lowest swing low) within
// a window. Used for London DR and Daily DR -- we want the widest range the
// whole session produced.
// Also tracks WHEN each extreme was confirmed (topTime/bottomTime) so
// f_drawOTE can determine leg direction.
// -----------------------------------------------------------------------------
f_dealingRangeTrack(_active, _windowStarted, _rangeStartTime) =>
    var float _top        = na
    var float _bottom     = na
    var int   _topTime    = na
    var int   _bottomTime = na

    if _windowStarted
        // Reset everything when the window freshly opens each day.
        _top        := na
        _bottom     := na
        _topTime    := na
        _bottomTime := na

    if _active
        // Only update the top if the new swing is HIGHER than the current top.
        // This means _top always holds the session's absolute highest swing.
        if not na(swingHighPrice) and (na(_top) or swingHighPrice > _top) and swingHighTime >= _rangeStartTime
            _top     := swingHighPrice
            _topTime := swingHighTime
        // Same logic inverted for the bottom.
        if not na(swingLowPrice) and (na(_bottom) or swingLowPrice < _bottom) and swingLowTime >= _rangeStartTime
            _bottom     := swingLowPrice
            _bottomTime := swingLowTime

    [_top, _bottom, _topTime, _bottomTime]


[lonTop, lonBottom, lonTopTime, lonBottomTime] = f_dealingRangeTrack(inLondon,    londonStarted, lonRangeStartTime)
[dlyTop, dlyBottom, dlyTopTime, dlyBottomTime] = f_dealingRangeTrack(inDailyDR,   asiaStarted, dlyRangeStartTime)

if londonStarted
    lonRangeStartTime := time
if dailyDRStarted
    dlyRangeStartTime := time

// -----------------------------------------------------------------------------
// FUNCTION: f_drawRangeBox
// Clears the previous box the moment a new window starts (so stale data
// doesn't linger), then creates/extends the box once a valid top AND bottom
// exist (there may be a few bars at the very start of a window before any
// swing has confirmed yet -- that's expected, not a bug).
// -----------------------------------------------------------------------------
f_drawRangeBox(_top, _bottom, _active, oteSideBroken, _windowStarted, _col, _labelTxt) =>
    var box _bx       = na
    var int _startBar = na
    var int invalidated = 0

    if oteSideBroken and time >= nykzRangeStartTime
        invalidated := invalidated + 1

    if _windowStarted
        if not na(_bx)
            box.delete(_bx)
            _bx := na
        _startBar := bar_index

    if _active and not na(_top) and not na(_bottom)
        if na(_bx)
            _bx := box.new(_startBar, _top, bar_index, _bottom, border_color=_col,
                            bgcolor=color.new(_col, 90), text=_labelTxt, text_color=_col, text_size=size.small)
        else
            box.set_top(_bx, _top)
            box.set_bottom(_bx, _bottom)
            box.set_right(_bx, bar_index)

    true

// — OTE (OPTIMAL TRADE ENTRY) FIB LEVELS
// =============================================================================
// For each dealing range, draws 0, 0.5, 0.62, 0.705, 0.79, 1 fib levels plus
// a shaded box for the 0.62-0.79 OTE zone specifically.
//
// DIRECTION LOGIC: whichever extreme (top or bottom) was confirmed MORE
// RECENTLY tells us the current leg:
//   - top more recent -> BULLISH leg: 0% anchors at the HIGH, retracing DOWN
//     toward the low. This puts the 0.62-0.79 OTE zone in the DISCOUNT
//     (lower) part of the range -- the long entry zone.
//   - bottom more recent -> BEARISH leg: 0% anchors at the LOW, retracing UP
//     toward the high. This puts OTE in the PREMIUM (upper) part of the
//     range -- the short entry zone.
// This mirrors how the fib retracement tool works when you drag from the
// most recent extreme back to the start of the move.
// =============================================================================

i_showOTE = input.bool(true, "Show OTE Levels", group="Dealing Ranges")

// -----------------------------------------------------------------------------
// FUNCTION: f_drawOTE
// Draws the 6 fib levels + OTE zone box for one dealing range. Returns the
// OTE zone's [top, bottom] prices so later phases (FVG-in-OTE detection) can
// check overlap against it without recomputing everything.
// -----------------------------------------------------------------------------
f_drawOTE(_top, _bottom, _topTime, _bottomTime, _active, _windowStarted, _col, _labelPrefix) =>
    var int   _startBar   = na
    var line  ln0         = na
    var line  ln50        = na
    var line  ln62        = na
    var line  ln705       = na
    var line  ln79        = na
    var line  ln100       = na
    var box   oteZone     = na
    var float _oteTop     = na
    var float _oteBottom  = na

    if _windowStarted
        _startBar := bar_index
        if not na(ln0)
            line.delete(ln0)
            line.delete(ln50)
            line.delete(ln62)
            line.delete(ln705)
            line.delete(ln79)
            line.delete(ln100)
            box.delete(oteZone)
        ln0        := na
        ln50       := na
        ln62       := na
        ln705      := na
        ln79       := na
        ln100      := na
        oteZone    := na
        _oteTop    := na
        _oteBottom := na

    bool _validRange = not na(_top) and not na(_bottom) and not na(_topTime) and not na(_bottomTime)

    if _active and _validRange
        bool  _bullishLeg = _topTime > _bottomTime
        float _range = _top - _bottom

        // 0% and 100% are just the two extremes themselves -- which one is
        // "0" depends on direction, since 0% = the most recent extreme.
        float p0   = _bullishLeg ? _top : _bottom
        float p50  = _bullishLeg ? _top - 0.5   * _range : _bottom + 0.5   * _range
        float p62  = _bullishLeg ? _top - 0.62  * _range : _bottom + 0.62  * _range
        float p705 = _bullishLeg ? _top - 0.705 * _range : _bottom + 0.705 * _range
        float p79  = _bullishLeg ? _top - 0.79  * _range : _bottom + 0.79  * _range
        float p100 = _bullishLeg ? _bottom : _top

        _oteTop    := math.max(p62, p79)
        _oteBottom := math.min(p62, p79)

        if na(ln0)
            ln0   := line.new(_startBar, p0,   bar_index, p0,   color=_col, style=line.style_dotted, width=1)
            ln50  := line.new(_startBar, p50,  bar_index, p50,  color=_col, style=line.style_dotted, width=1)
            ln62  := line.new(_startBar, p62,  bar_index, p62,  color=_col, style=line.style_solid,  width=1)
            ln705 := line.new(_startBar, p705, bar_index, p705, color=_col, style=line.style_dotted, width=1)
            ln79  := line.new(_startBar, p79,  bar_index, p79,  color=_col, style=line.style_solid,  width=1)
            ln100 := line.new(_startBar, p100, bar_index, p100, color=_col, style=line.style_dotted, width=1)
            oteZone := box.new(_startBar, _oteTop, bar_index, _oteBottom, border_color=color.new(_col, 50), bgcolor=color.new(_col, 85))
        else
            line.set_xy1(ln0,   _startBar, p0)
            line.set_xy2(ln0,   bar_index, p0)
            line.set_xy1(ln50,  _startBar, p50)
            line.set_xy2(ln50,  bar_index, p50)
            line.set_xy1(ln62,  _startBar, p62)
            line.set_xy2(ln62,  bar_index, p62)
            line.set_xy1(ln705, _startBar, p705)
            line.set_xy2(ln705, bar_index, p705)
            line.set_xy1(ln79,  _startBar, p79)
            line.set_xy2(ln79,  bar_index, p79)
            line.set_xy1(ln100, _startBar, p100)
            line.set_xy2(ln100, bar_index, p100)
            box.set_top(oteZone, _oteTop)
            box.set_bottom(oteZone, _oteBottom)
            box.set_right(oteZone, bar_index)

    [_oteTop, _oteBottom]

// =============================================================================
// OTE EXTENSION LOGIC
// =============================================================================
// Problem: when London/Premarket closes at 2:30pm, the range and OTE levels
// freeze. But if the OTE zone was never tapped during London, the leg is still
// developing -- the "real" dealing range isn't complete yet. We need the range
// to keep absorbing new NY swings until the OTE zone is actually tapped.
//
// HOW IT WORKS (per range):
//   1. When the window closes (londonEnded), we check if the OTE zone was
//      ever tapped. If NOT tapped, we set a `var bool _extending = true` flag.
//   2. While extending, we feed new confirmed swings into the range top/bottom
//      using the same update logic as the tracker functions above. The range
//      box and OTE fib levels redraw automatically since f_drawOTE runs every
//      bar and just needs updated values.
//   3. The moment any 1m candle's wick enters the OTE zone (high >= oteBottom
//      AND low <= oteTop), we set _extending = false and the range locks.
//
// We use separate `var` variables (rather than modifying the tracker function)
// because by the time we know whether to extend, f_dealingRangeTrack has
// already run for this bar -- we can't go back and change its output.
// Instead we hold our own mutable copies of top/bottom/time that start from
// the tracker's last values and keep updating independently.
// =============================================================================

// Pre-declare OTE zone bounds so the extension logic below can reference them.
// These get overwritten by f_drawOTE() further down -- the extension tap-check
// uses the PREVIOUS bar's computed values (one bar stale), which is fine.
var float lonOteTop    = na
var float lonOteBottom = na
//var float pmOteTop     = na
//var float pmOteBottom  = na
var float dlyOteTop    = na
var float dlyOteBottom = na

// --- Mutable copies of London range that can extend past the window close ---
// These start as na and get seeded from the tracker output the moment London
// ends. While extending, new swings update them directly.
var float lonExtTop         = na
var float lonExtBottom      = na
var int   lonExtTopTime     = na
var int   lonExtBottomTime  = na
var bool  lonExtending      = false

var float dlyExtTop         = na
var float dlyExtBottom      = na
var int   dlyExtTopTime     = na
var int   dlyExtBottomTime  = na
var bool  dlyExtending      = false


// londonEnded is already declared in Phase 1a (from f_sessionTrack) --
// it's true for exactly ONE bar (the first bar after London closes).
// That's when we seed the extension copies and decide whether to extend.

if londonEnded
    // Seed our mutable copies from whatever the tracker produced.
    lonExtTop        := lonTop
    lonExtBottom     := lonBottom
    lonExtTopTime    := lonTopTime
    lonExtBottomTime := lonBottomTime

    dlyExtTop        := dlyTop
    dlyExtBottom     := dlyBottom
    dlyExtTopTime    := dlyTopTime
    dlyExtBottomTime := dlyBottomTime
    // The OTE values aren't available yet at this exact bar (f_drawOTE hasn't
    // run yet for the post-close bars), so we check on the NEXT bar instead
    // by simply always starting extension -- it self-terminates the moment
    // the OTE zone is tapped (see below). On days where the OTE was already
    // tapped during London, the extension will immediately terminate on the
    // very first bar after close.
    lonExtending := true
    dlyExtending := true

if nypmEnded
    lonExtending := false
    dlyExtending := false

if lonExtending
    // Keep folding in new confirmed swings -- same logic as f_dealingRangeTrack
    // but applied to our mutable copies instead of inside the function.
    if not na(swingHighPrice) and (na(lonExtTop) or swingHighPrice > lonExtTop)
        lonExtTop     := swingHighPrice
        lonExtTopTime := swingHighTime
    if not na(swingLowPrice) and (na(lonExtBottom) or swingLowPrice < lonExtBottom)
        lonExtBottom     := swingLowPrice
        lonExtBottomTime := swingLowTime

    // Check if a wick has entered the OTE zone. We use the values from the
    // PREVIOUS bar's OTE computation (lonOteTop/lonOteBottom from below) --
    // but since those don't exist until after this block runs on the first
    // extension bar, we guard with na() checks.
    // A wick entering means: candle high reached into the bottom of OTE zone
    // (for a bearish leg where OTE is in premium) OR candle low reached into
    // the top of OTE zone (for a bullish leg where OTE is in discount).
    // Simplest universal check: any wick overlap with the OTE box at all.
    if not na(lonOteTop) and not na(lonOteBottom)
        bool _lonOteTapped = high >= lonOteBottom and low <= lonOteTop
        if _lonOteTapped
            lonExtending := false

if dlyExtending
    if not na(swingHighPrice) and (na(dlyExtTop) or swingHighPrice > dlyExtTop)
        dlyExtTop     := swingHighPrice
        dlyExtTopTime := swingHighTime
    if not na(swingLowPrice) and (na(dlyExtBottom) or swingLowPrice < dlyExtBottom)
        dlyExtBottom     := swingLowPrice
        dlyExtBottomTime := swingLowTime

    if not na(dlyOteTop) and not na(dlyOteBottom)
        bool _dlyOteTapped = high >= dlyOteBottom and low <= dlyOteTop
        if _dlyOteTapped
            dlyExtending := false

// Now decide what to pass to f_drawOTE:
// - While London is open: use the live tracker values (lonTop etc.)
// - After close, while extending: use the mutable extension copies (lonExtTop etc.)
// - After extension ends (OTE tapped): keep showing the frozen extension values
float lonDrawTop         = lonExtending or (not inLondon and not na(lonExtTop)) ? lonExtTop         : lonTop
float lonDrawBottom      = lonExtending or (not inLondon and not na(lonExtTop)) ? lonExtBottom      : lonBottom
float lonDrawTopTime     = lonExtending or (not inLondon and not na(lonExtTop)) ? lonExtTopTime     : lonTopTime
float lonDrawBottomTime  = lonExtending or (not inLondon and not na(lonExtTop)) ? lonExtBottomTime  : lonBottomTime

float dlyDrawTop         = dlyExtending or (not inLondon and not inAsia and not na(dlyExtTop)) ? dlyExtTop         : dlyTop
float dlyDrawBottom      = dlyExtending or (not inLondon and not inAsia and not na(dlyExtTop)) ? dlyExtBottom      : dlyBottom
float dlyDrawTopTime     = dlyExtending or (not inLondon and not inAsia and not na(dlyExtTop)) ? dlyExtTopTime     : dlyTopTime
float dlyDrawBottomTime  = dlyExtending or (not inLondon and not inAsia and not na(dlyExtTop)) ? dlyExtBottomTime  : dlyBottomTime

// OTE side broken invalidation check
bool lonLegBullish = not na(lonDrawTopTime) and not na(lonDrawBottomTime) and lonDrawTopTime > lonDrawBottomTime
bool lonLegBearish = not na(lonDrawTopTime) and not na(lonDrawBottomTime) and lonDrawBottomTime > lonDrawTopTime
bool lonOteSideBroken = (lonLegBullish and low < lonDrawBottom) or (lonLegBearish and high > lonDrawTop)

bool dlyLegBullish = not na(dlyDrawTopTime) and not na(dlyDrawBottomTime) and dlyDrawTopTime > dlyDrawBottomTime
bool dlyLegBearish = not na(dlyDrawTopTime) and not na(dlyDrawBottomTime) and dlyDrawBottomTime > dlyDrawTopTime
bool dlyOteSideBroken = (dlyLegBullish and low < dlyDrawBottom) or (dlyLegBearish and high > dlyDrawTop)

// Active flag: London window OR currently extending
bool lonDrawActive = (inLondon or lonExtending or (not inLondon and not na(lonExtTop))) and not lonOteSideBroken
bool dlyDrawActive = (inLondon or dlyExtending or (not inLondon and not na(dlyExtTop))) and not dlyOteSideBroken
// Assign into the pre-declared vars (not re-declared with []) so the
[_lonOteTop, _lonOteBtm] = f_drawOTE(lonDrawTop, lonDrawBottom, lonDrawTopTime, lonDrawBottomTime, lonDrawActive and i_showOTE and i_showLondonDR,    londonStarted, c_london,    "LON")
[_dlyOteTop, _dlyOteBtm] = f_drawOTE(dlyDrawTop, dlyDrawBottom, dlyDrawTopTime, dlyDrawBottomTime, dlyDrawActive and i_showOTE and i_showDailyDR, dailyDRStarted, c_dailyDR, "DLY")

lonOteTop    := _lonOteTop
lonOteBottom := _lonOteBtm
dlyOteTop    := _dlyOteTop
dlyOteBottom := _dlyOteBtm

if lonOteSideBroken
    lonOteTop    := na
    lonOteBottom := na
if dlyOteSideBroken
    dlyOteTop    := na
    dlyOteBottom := na

// -----------------------------------------------------------------------------
// DRAW: Range boxes
// These calls are placed HERE (after all extension logic and OTE computation)
// because f_drawRangeBox needs lonDrawActive/pmDrawActive/lonDrawTop etc.,
// which are only defined once the extension logic above has run. Pine
// evaluates top-to-bottom so calling this earlier would fail with
// "undeclared identifier" errors.
// -----------------------------------------------------------------------------
if i_showLondonDR
    f_drawRangeBox(lonDrawTop, lonDrawBottom, lonDrawActive, lonOteSideBroken, londonStarted, c_london,    "London DR")
if i_showDailyDR
    f_drawRangeBox(dlyDrawTop, dlyDrawBottom, dlyDrawActive, dlyOteSideBroken, asiaStarted, c_dailyDR, "Daily DR")





// =============================================================================
// PHASE 2c — NY KILLZONE: SEQUENTIAL DEALING RANGES (9:30am NY – 4pm NY)
// =============================================================================
// Tracking begins the instant NY killzone opens and runs continuously.
// A range stays live and keeps updating with new swings until price trades
// through the extreme nearest the OTE zone (the "far"/100% extreme, the one
// the leg originated from) -- wick OR body, since a raw high/low breach
// already covers both. At that point:
//   - the range is INVALIDATED (box + OTE deleted, nothing frozen/kept)
//   - a NEW, OPPOSITE-direction range begins immediately on the same bar
//   - the extreme that did NOT break carries over unchanged (same price,
//     same original time) into the new range
//   - the extreme that DID break reseeds live from the current bar's
//     high/low and starts tracking fresh from here
// =============================================================================

i_nyKillzoneSess = input.session("1430-2100", "NY Killzone Window (9:30am NY - 4pm NY, in UK time)", group="NY Killzone")
i_showNYKZ       = input.bool(true, "Show NY Killzone Ranges", group="NY Killzone")

c_nykz = color.orange

inNYKZ            = f_inSession(i_nyKillzoneSess)
nykzWindowStarted = inNYKZ and not inNYKZ[1]
nykzWindowEnded   = not inNYKZ and inNYKZ[1]

// -----------------------------------------------------------------------------
// FUNCTION: f_drawRangeBoxLive
// Two modes only now: _active (create/update) and _invalidate (delete +
// release reference so the next _active bar builds a genuinely new box).
// -----------------------------------------------------------------------------
f_drawRangeBoxLive(_top, _bottom, _active, _invalidate, _col, _labelTxt) =>
    var box _bx       = na
    var int _startBar = na

    if _invalidate and not na(_bx)
        box.delete(_bx)
        _bx := na

    if _active and not na(_top) and not na(_bottom)
        if na(_bx)
            _startBar := bar_index
            _bx := box.new(_startBar, _top, bar_index, _bottom, border_color=_col,
                            bgcolor=color.new(_col, 90), text=_labelTxt, text_color=_col, text_size=size.small)
        else
            box.set_top(_bx, _top)
            box.set_bottom(_bx, _bottom)
            box.set_right(_bx, bar_index)

    true

// -----------------------------------------------------------------------------
// FUNCTION: f_drawOTELive
// Same two-mode pattern applied to the 6 fib lines/labels + OTE zone box.
// -----------------------------------------------------------------------------
f_drawOTELive(_top, _bottom, _topTime, _bottomTime, _active, _invalidate, _col, _labelPrefix) =>
    var line  ln0        = na
    var line  ln50       = na
    var line  ln62       = na
    var line  ln705      = na
    var line  ln79       = na
    var line  ln100      = na
    var box   oteZone    = na
    var int   _startBar  = na
    var float _oteTop    = na
    var float _oteBottom = na

    if _invalidate and not na(ln0)
        line.delete(ln0)
        line.delete(ln50)
        line.delete(ln62)
        line.delete(ln705)
        line.delete(ln79)
        line.delete(ln100)
        box.delete(oteZone)
        ln0        := na
        oteZone    := na
        _oteTop    := na
        _oteBottom := na

    bool _validRange = not na(_top) and not na(_bottom) and not na(_topTime) and not na(_bottomTime)

    if _active and _validRange
        bool  _bullishLeg = _topTime > _bottomTime
        float _range = _top - _bottom
        float p0   = _bullishLeg ? _top : _bottom
        float p50  = _bullishLeg ? _top - 0.5   * _range : _bottom + 0.5   * _range
        float p62  = _bullishLeg ? _top - 0.62  * _range : _bottom + 0.62  * _range
        float p705 = _bullishLeg ? _top - 0.705 * _range : _bottom + 0.705 * _range
        float p79  = _bullishLeg ? _top - 0.79  * _range : _bottom + 0.79  * _range
        float p100 = _bullishLeg ? _bottom : _top

        _oteTop    := math.max(p62, p79)
        _oteBottom := math.min(p62, p79)

        if na(ln0)
            _startBar := bar_index
            ln0   := line.new(_startBar, p0,   bar_index, p0,   color=_col, style=line.style_dotted, width=1)
            ln50  := line.new(_startBar, p50,  bar_index, p50,  color=_col, style=line.style_dotted, width=1)
            ln62  := line.new(_startBar, p62,  bar_index, p62,  color=_col, style=line.style_solid,  width=1)
            ln705 := line.new(_startBar, p705, bar_index, p705, color=_col, style=line.style_dotted, width=1)
            ln79  := line.new(_startBar, p79,  bar_index, p79,  color=_col, style=line.style_solid,  width=1)
            ln100 := line.new(_startBar, p100, bar_index, p100, color=_col, style=line.style_dotted, width=1)
            oteZone := box.new(_startBar, _oteTop, bar_index, _oteBottom, border_color=color.new(_col, 50), bgcolor=color.new(_col, 85))
        else
            line.set_xy1(ln0,   _startBar, p0)
            line.set_xy2(ln0,   bar_index, p0)
            line.set_xy1(ln50,  _startBar, p50)
            line.set_xy2(ln50,  bar_index, p50)
            line.set_xy1(ln62,  _startBar, p62)
            line.set_xy2(ln62,  bar_index, p62)
            line.set_xy1(ln705, _startBar, p705)
            line.set_xy2(ln705, bar_index, p705)
            line.set_xy1(ln79,  _startBar, p79)
            line.set_xy2(ln79,  bar_index, p79)
            line.set_xy1(ln100, _startBar, p100)
            line.set_xy2(ln100, bar_index, p100)
            box.set_top(oteZone, _oteTop)
            box.set_bottom(oteZone, _oteBottom)
            box.set_right(oteZone, bar_index)

    [_oteTop, _oteBottom]

// -----------------------------------------------------------------------------
// STATE
// -----------------------------------------------------------------------------
var float nykzTop        = na
var float nykzBottom     = na
var int   nykzTopTime    = na
var int   nykzBottomTime = na
var bool  nykzTracking   = false
var int   nykzRangeCount = 0

bool nykzInvalidate = false
bool nykzLegBullish = false
bool nykzLegBearish = false

// New day: clear yesterday's leftover range and begin range #1 immediately.
if nykzWindowStarted
    nykzInvalidate  := true
    nykzTracking    := true
    nykzTop         := na
    nykzBottom      := na
    nykzTopTime     := na
    nykzBottomTime  := na
    nykzRangeCount  += 1
    nykzRangeStartTime := time

if nykzWindowEnded
    nykzTracking := false   // stops updating -> last range simply stays as last drawn

// -----------------------------------------------------------------------------
// ACCUMULATE + DETECT INVALIDATION (using values BEFORE any reseed happens)
// -----------------------------------------------------------------------------
if nykzTracking
    if not na(swingHighPrice) and (na(nykzTop) or swingHighPrice > nykzTop)
        nykzTop     := swingHighPrice
        nykzTopTime := swingHighTime
    if not na(swingLowPrice) and (na(nykzBottom) or swingLowPrice < nykzBottom)
        nykzBottom     := swingLowPrice
        nykzBottomTime := swingLowTime

    bool haveDirection = not na(nykzTopTime) and not na(nykzBottomTime)
    nykzLegBullish := haveDirection and nykzTopTime > nykzBottomTime
    nykzLegBearish := haveDirection and nykzBottomTime > nykzTopTime

    // The extreme nearest the OTE zone is the ORIGIN extreme -- top for a
    // bearish leg, bottom for a bullish leg (see explanation below). If raw
    // price trades through THAT extreme, the leg fully round-tripped and the
    // range is invalid.
    bool oteSideBroken = (nykzLegBullish and low < nykzBottom) or (nykzLegBearish and high > nykzTop)

    if oteSideBroken
        nykzInvalidate := true

bool nykzActive = nykzTracking and not nykzInvalidate

// -----------------------------------------------------------------------------
// DRAW — runs BEFORE the reseed below, so an invalidate bar's last update
// (via f_drawOTELive/f_drawRangeBoxLive) reflects the OLD range's final
// wick, and the deletion above still fires this same bar.
// -----------------------------------------------------------------------------
string nykzLabel = "NYKZ" + str.tostring(nykzRangeCount)

[_nykzOteTop, _nykzOteBtm] = f_drawOTELive(nykzTop, nykzBottom, nykzTopTime, nykzBottomTime, nykzActive and i_showOTE and i_showNYKZ, nykzInvalidate, c_nykz, nykzLabel)

if i_showNYKZ
    f_drawRangeBoxLive(nykzTop, nykzBottom, nykzActive, nykzInvalidate, c_nykz, nykzLabel + " Range")

// -----------------------------------------------------------------------------
// RESEED — carry the surviving extreme into the new range, reseed the
// broken side from current price. Skipped on the window-open invalidate
// (that one should start from nothing, not carry over from yesterday).
// -----------------------------------------------------------------------------
if nykzInvalidate and not nykzWindowStarted
    if nykzLegBullish
        // bottom broke -> keep prev range's TOP, reseed bottom from live low
        nykzBottom     := low
        nykzBottomTime := time
    else if nykzLegBearish
        // top broke -> keep prev range's BOTTOM, reseed top from live high
        nykzTop     := high
        nykzTopTime := time
    nykzRangeCount += 1
    nykzRangeStartTime := time


// =============================================================================
// PHASE 3 — FVG DETECTION (MULTI-TIMEFRAME, PER DEALING RANGE, ARRAY-BASED)
// =============================================================================
// Each timeframe keeps an ARRAY of unfilled FVGs (not just the single most
// recent one) so a range's OTE zone can align with an OLDER gap even after
// newer ones have formed on the same timeframe.
//
// An FVG is only ever REMOVED from its array when it is fully INVERTED --
// a CLOSED candle on that FVG's own timeframe closing all the way through the
// zone (body close beyond the far side), not just a wick tap. Simple overlap
// checks (like OTE alignment) never remove anything from the array.
// =============================================================================

i_showFVG = input.bool(true, "Show FVGs", group="FVG")
i_fvgTF1  = input.timeframe("60", "FVG Priority 1", group="FVG")
i_fvgTF2  = input.timeframe("15", "FVG Priority 2", group="FVG")
i_fvgTF3  = input.timeframe("5",  "FVG Priority 3", group="FVG")
//i_fvgTF4  = input.timeframe("1",  "FVG Priority 4", group="FVG")
i_fvgMaxPerTF = input.int(20, "Max stored FVGs per timeframe", minval=1, maxval=100, group="FVG")

c_fvgBull = i_bullGapColor
c_fvgBear = i_bearGapColor

// -----------------------------------------------------------------------------
// FUNCTION: f_getHtfOffsets
// Wrapping the historical-offset tuple in its own function is what makes
// request.security accept it reliably (this was the fix for the earlier na
// bug -- passing the raw [high[1], low[1], ...] literal directly into
// request.security's expression argument was not resolving correctly).
// -----------------------------------------------------------------------------
f_getHtfOffsets() =>
    [high[1], low[1], high[2], low[2], high[3], low[3], close[1], time]

// -----------------------------------------------------------------------------
// FUNCTION: f_htfFVGArray
// For ONE timeframe, maintains an array of unfilled FVGs found on that
// timeframe. Each entry is stored as 3 parallel arrays (top/bottom/isBull) --
// Pine doesn't support arrays-of-structs, so parallel arrays at the same
// index represent one FVG.
//
// Each bar:
//   1. DETECT (only on a new HTF bar close): check the last 3 closed HTF
//      candles for a gap. If found, APPEND it to the arrays (never overwrite
//      -- older gaps stay right where they are).
//   2. INVERT CHECK (only on a new HTF bar close, using the HTF candle that
//      just closed): for every stored gap on THIS timeframe, if the new HTF
//      candle's CLOSE fully closed through the gap (past the far side, not
//      just a wick), remove that gap from the arrays. Checked oldest-first,
//      iterating backwards so removal-by-index is safe.
//   3. CAP: if the array grows past i_fvgMaxPerTF, drop the oldest entry so
//      memory doesn't grow unbounded over a long chart history.
// -----------------------------------------------------------------------------
f_htfFVGArray(_tf) =>
    [h1, l1, h2, l2, h3, l3, c1, htfTime] = request.security(syminfo.tickerid, _tf, f_getHtfOffsets(), lookahead=barmerge.lookahead_off)

    var float[] _tops      = array.new_float()
    var float[] _bottoms   = array.new_float()
    var bool[]  _bulls     = array.new_bool()
    var int[]   _times     = array.new_int()
    var int[]   _pushBars  = array.new_int()
    var int     _lastHtfTime = na
    var bool    _initialized = false

    bool _newHtfBar = not _initialized or htfTime != _lastHtfTime

    if _newHtfBar
        _initialized := true
        _lastHtfTime := htfTime

        if array.size(_tops) > 0
            for i = array.size(_tops) - 1 to 0
                float _gTop  = array.get(_tops, i)
                float _gBot  = array.get(_bottoms, i)
                bool  _gBull = array.get(_bulls, i)
                bool _inverted = _gBull ? (c1 < _gBot) : (c1 > _gTop)
                if _inverted
                    array.remove(_tops, i)
                    array.remove(_bottoms, i)
                    array.remove(_bulls, i)
                    array.remove(_times, i)
                    array.remove(_pushBars, i)

        bool _bullGap = l1 > h3
        bool _bearGap = h1 < l3
        if _bullGap
            array.push(_tops, l1)
            array.push(_bottoms, h3)
            array.push(_bulls, true)
            array.push(_times, htfTime)
            array.push(_pushBars, bar_index)
        else if _bearGap
            array.push(_tops, l3)
            array.push(_bottoms, h1)
            array.push(_bulls, false)
            array.push(_times, htfTime)
            array.push(_pushBars, bar_index)

        if array.size(_tops) > i_fvgMaxPerTF
            array.shift(_tops)
            array.shift(_bottoms)
            array.shift(_bulls)
            array.shift(_times)
            array.shift(_pushBars)

    [_tops, _bottoms, _bulls, _times, _pushBars]
// -----------------------------------------------------------------------------
// One array-set per priority timeframe, called once at top level (shared
// across all dealing ranges, same reasoning as before).
// -----------------------------------------------------------------------------
[fvg1Tops, fvg1Bots, fvg1Bulls, fvg1Times, fvg1PushBars] = f_htfFVGArray(i_fvgTF1)
[fvg2Tops, fvg2Bots, fvg2Bulls, fvg2Times, fvg2PushBars] = f_htfFVGArray(i_fvgTF2)
[fvg3Tops, fvg3Bots, fvg3Bulls, fvg3Times, fvg3PushBars] = f_htfFVGArray(i_fvgTF3)
//[fvg4Tops, fvg4Bots, fvg4Bulls, fvg4Times, fvg4PushBars] = f_htfFVGArray(i_fvgTF4)

// -----------------------------------------------------------------------------
// FUNCTION: f_findOverlapInArray
// Scans one timeframe's array set for ANY stored gap overlapping the given
// OTE bounds. Searches NEWEST-first (highest index first) since the most
// recently formed gap on a timeframe is generally the most relevant one.
// Returns [top, bottom, isBull, found].
// -----------------------------------------------------------------------------

f_findOverlapInArray(_tops, _bottoms, _bulls, _times, _pushBars, _oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime) =>
    float top      = na
    float bot      = na
    bool  bull     = false
    bool  found    = false
    int   startBar = na

    bool _haveOte = not na(_oteTop) and not na(_oteBottom) and not na(_rangeStartTime)

    float oteMid = (_oteTop + _oteBottom) / 2
    float rangeMid = (_rangeTop + _rangeBottom) / 2

    bool _rangeBull = oteMid < rangeMid

    if _haveOte and array.size(_tops) > 0
        for i = array.size(_tops) - 1 to 0
            if not found
                float _gTop  = array.get(_tops, i)
                float _gBot  = array.get(_bottoms, i)
                int   _gTime = array.get(_times, i)
                bool _gBull = array.get(_bulls, i)
                if _gTime >= _rangeStartTime and _gTop >= _oteBottom and _gBot <= _oteTop and _gBull == _rangeBull
                    top      := _gTop
                    bot      := _gBot
                    bull     := array.get(_bulls, i)
                    startBar := array.get(_pushBars, i)
                    found    := true

    [top, bot, bull, found, startBar]

// -----------------------------------------------------------------------------
// FUNCTION: f_pickFVG
// Given one dealing range's OTE bounds, walks the 4 timeframe arrays in
// priority order and returns the first overlapping gap found, tagging WHICH
// timeframe it came from (as a display string) so the box can be labelled.
// Returns [top, bottom, isBullish, found, tfLabel].
// -----------------------------------------------------------------------------
f_pickFVG(_oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime) =>
    [t1, b1, u1, f1, s1] = f_findOverlapInArray(fvg1Tops, fvg1Bots, fvg1Bulls, fvg1Times, fvg1PushBars, _oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime)
    [t2, b2, u2, f2, s2] = f_findOverlapInArray(fvg2Tops, fvg2Bots, fvg2Bulls, fvg2Times, fvg2PushBars, _oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime)
    [t3, b3, u3, f3, s3] = f_findOverlapInArray(fvg3Tops, fvg3Bots, fvg3Bulls, fvg3Times, fvg3PushBars, _oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime)
    //[t4, b4, u4, f4, s4] = f_findOverlapInArray(fvg4Tops, fvg4Bots, fvg4Bulls, fvg4Times, fvg4PushBars, _oteTop, _oteBottom, _rangeTop, _rangeBottom, _rangeStartTime)

    float  top   = na
    float  bot   = na
    bool   bull  = false
    bool   found = false
    int    startBar = na
    string tfLabel = ""

    if f1
        top := t1
        bot := b1
        bull := u1
        found := true
        startBar := s1
        tfLabel := i_fvgTF1 == "60" ? "1H" : i_fvgTF1 + "m"
    else if f2
        top := t2
        bot := b2
        bull := u2
        found := true
        startBar := s2
        tfLabel := i_fvgTF2 == "60" ? "1H" : i_fvgTF2 + "m"
    else if f3
        top := t3
        bot := b3
        bull := u3
        found := true
        startBar := s3
        tfLabel := i_fvgTF3 == "60" ? "1H" : i_fvgTF3 + "m"
    // else if f4
    //     top := t4
    //     bot := b4
    //     bull := u4
    //     found := true
    //     startBar := s4
    //     tfLabel := i_fvgTF4 == "60" ? "1H" : i_fvgTF4 + "m"

    [top, bot, bull, found, startBar, tfLabel]

// -----------------------------------------------------------------------------
// FUNCTION: f_drawRangeFVG
// Draws/updates/removes ONE box for a dealing range's currently selected FVG.
// Label now includes the source timeframe, e.g. "15m FVG (LON)".
// -----------------------------------------------------------------------------
f_drawRangeFVG(_top, _bottom, _found, _isBull, _startBar, _tfLabel, _rangeLabel) =>
    var box   _bx      = na
    var float _prevTop = na
    var float _prevBot = na

    bool _changed = _found and (na(_prevTop) or _top != _prevTop or _bottom != _prevBot)

    if (not _found or _changed) and not na(_bx)
        box.delete(_bx)
        _bx := na

    if _found
        color _col = _isBull ? c_fvgBull : c_fvgBear
        string _txt = _tfLabel + " (" + _rangeLabel + ")"
        // Shift the left edge back by 2 × the FVG timeframe (expressed in 1m bars)
        int _tfMinutes = _tfLabel == "1H" ? 60 : int(str.tonumber(str.replace(_tfLabel, "m", "")))

        int _leftBar = _startBar - (2 * _tfMinutes)
        if na(_bx)
            _bx := box.new(_leftBar, _top, bar_index, _bottom, border_color=_col, border_width=0,
                            bgcolor=color.new(_col, 75), text=_txt,
                            text_color=c_labelGrey, text_size=size.small)
        else
            box.set_right(_bx, bar_index)
        _prevTop := _top
        _prevBot := _bottom
    else
        _prevTop := na
        _prevBot := na

    true

// -----------------------------------------------------------------------------
// DRAW: FVG for each dealing range, checked against that range's own OTE
// -----------------------------------------------------------------------------
[dlyFvgTop, dlyFvgBot, dlyFvgBull, dlyFvgFound, dlyFvgStartBar, dlyFvgTf] = f_pickFVG(dlyOteTop, dlyOteBottom, dlyTop, dlyBottom, dlyRangeStartTime)
f_drawRangeFVG(dlyFvgTop, dlyFvgBot, dlyFvgFound, dlyFvgBull, dlyFvgStartBar, dlyFvgTf, "DLY")

[lonFvgTop, lonFvgBot, lonFvgBull, lonFvgFound, lonFvgStartBar, lonFvgTf] = f_pickFVG(lonOteTop, lonOteBottom, lonTop, lonBottom, lonRangeStartTime)
f_drawRangeFVG(lonFvgTop, lonFvgBot, lonFvgFound, lonFvgBull, lonFvgStartBar, lonFvgTf, "LON")

[nykzFvgTop, nykzFvgBot, nykzFvgBull, nykzFvgFound, nykzFvgStartBar, nykzFvgTf] = f_pickFVG(_nykzOteTop, _nykzOteBtm, nykzTop, nykzBottom, nykzRangeStartTime)
f_drawRangeFVG(nykzFvgTop, nykzFvgBot, nykzFvgFound, nykzFvgBull, nykzFvgStartBar, nykzFvgTf, "NYKZ")

STATE_IDLE = 0
STATE_HUNTING = 1
STATE_TRIGGERED = 2
STATE_COMPLETED = 3

minDisplacement = input.float(3.0, "Minimum Displacement For Valid Entry Trigger (pts)")
cisdIgnoreBodyPts = input.float(5.0, "CISD Ignore Opposing Body (pts)")

// find manipulation leg origin swing + 1m FVGs
f_findManipulationLeg(_tipBar, _lookingForLong) =>
    float swingPrice = na
    int swingBar = na
    // parallel arrays for storing 1m FVGs
    fvgTopArr    = array.new_float()
    fvgBotArr    = array.new_float()
    fvgBarArr    = array.new_int()
    fvgBullArr   = array.new_bool()
    fvgInversedArr   = array.new_bool()
    fvgTouchedArr   = array.new_bool() // TO DO: integrate ts to fix IFVG logic
    // CISD candle
    float cisdPrice = na
    int cisdBar = na

    int tipOffset = bar_index - _tipBar
    int start = math.max(0, tipOffset-1) // -1 handles the fvg edge case where the candle immediately after the tip bar creates an fvg
    //label.new(bar_index, high, str.tostring(tipOffset-1))
    for i = start to 50
        //label.new(bar_index - i, high[i], str.tostring(i))
        // 1m FVG detection
        if i + 2 <= bar_index
            if _lookingForLong
                bearishFVG = high[i] < low[i + 2]
                if bearishFVG
                    array.push(fvgTopArr, low[i + 2])
                    array.push(fvgBotArr, high[i])
                    array.push(fvgBarArr, bar_index - i)
                    array.push(fvgBullArr, false)
                    array.push(fvgInversedArr, false)
                    array.push(fvgTouchedArr, false)
            else
                bullishFVG = low[i] > high[i + 2]
                if bullishFVG
                    array.push(fvgTopArr, low[i])
                    array.push(fvgBotArr, high[i + 2])
                    array.push(fvgBarArr, bar_index - i)
                    array.push(fvgBullArr, true)
                    array.push(fvgInversedArr, false)
                    array.push(fvgTouchedArr, false)

        // CISD level detection (open of first candle in final consecutive same-colour run)
        if na(cisdPrice)
            if _lookingForLong
                bool bear = close[i] < open[i]
                if bear
                    bool stop = false
                    // Normal end of run
                    if close[i + 1] >= open[i + 1]
                        float body = math.abs(close[i + 1] - open[i + 1])
                        bool ignore = body <= cisdIgnoreBodyPts and i + 2 <= 50 and close[i + 2] < open[i + 2]
                        stop := not ignore
                    if stop
                        cisdPrice := open[i]
                        cisdBar := bar_index - i
            else
                bool bull = close[i] > open[i]
                if bull
                    bool stop = false
                    // Normal end of run
                    if close[i + 1] <= open[i + 1]
                        float body = math.abs(close[i + 1] - open[i + 1])
                        bool ignore = body <= cisdIgnoreBodyPts and i + 2 <= 50 and close[i + 2] > open[i + 2]
                        stop := not ignore
                    if stop
                        cisdPrice := open[i]
                        cisdBar := bar_index - i

        // only check swing when i has enough bars either side
        if i >= 2 and i + 2 <= bar_index
            bool found = _lookingForLong ? (high[i] > high[i + 2] and high[i] > high[i + 1] and high[i] > high[i - 2] and high[i] > high[i - 1]) : (low[i] < low[i + 2] and low[i] < low[i + 1] and low[i] < low[i - 2] and low[i] < low[i - 1])

            if found
                swingPrice := _lookingForLong ? high[i] : low[i]
                swingBar := bar_index - i
                break

    [swingPrice, swingBar, fvgTopArr, fvgBotArr, fvgBarArr, fvgBullArr, fvgInversedArr, fvgTouchedArr, cisdPrice, cisdBar]


// IFVG trigger using the chained 1m FVG rule
f_checkIFVGs(_topArr, _botArr, _bullArr, _fvgInversedArr, _fvgTouchedArr) =>
    bool ready = false
    int IFVGs = 0
    if array.size(_topArr) > 0
        ready := true
        for i = 0 to array.size(_topArr) - 1
            float top = array.get(_topArr, i)
            float bot = array.get(_botArr, i)
            bool bull = array.get(_bullArr, i)
            if bull ? close < (bot - minDisplacement) : close > (top + minDisplacement)
                array.set(_fvgInversedArr, i, true)
            bool inversed = array.get(_fvgInversedArr, i)
            if bull ? close >= bot and low < top : close <= top and high > bot
                array.set(_fvgTouchedArr, i, true)
            bool touched = array.get(_fvgTouchedArr, i)
            if (not inversed and touched) or (not inversed and IFVGs == 0)
                ready := false
                break
            IFVGs := IFVGs + 1
    // if IFVGs >= 1
    //     ready := true
    //label.new(bar_index, high, str.tostring(IFVGs))
    ready

// CISD trigger also checking if uninversed 1m is touched
f_checkCISD(_cisdPrice, _topArr, _botArr, _bullArr, _lookingForLong) =>
    bool ready = false
    bool cisdCleared = false
    if _lookingForLong
        if close >= (_cisdPrice + minDisplacement)
            ready := true
            cisdCleared:= true
    else
        if close <= (_cisdPrice - minDisplacement)
            ready := true
            cisdCleared:= true
    if array.size(_topArr) > 0
        for i = 0 to array.size(_topArr) - 1
            float top = array.get(_topArr, i)
            float bot = array.get(_botArr, i)
            bool bull = array.get(_bullArr, i)
            bool inside = bull ? close >= bot and low <= top : close <= top and high >= bot
            if inside
                ready := false
                break
    [ready, cisdCleared]

// update setup states for IRL->ERL and ERL->IRL
f_oteTapChecker(_fvgTop, _fvgBottom, _fvgFound, _fvgBull, _rangeTop, _rangeBottom, _oteTop, _oteBottom, _session) =>
    var int _IRLState = STATE_IDLE
    var float _tipPrice = na
    var int   _tipBar   = na
    var float _originPrice = na
    var int   _originBar   = na
    var fvgTopArr    = array.new_float()
    var fvgBotArr    = array.new_float()
    var fvgBarArr    = array.new_int()
    var fvgBullArr   = array.new_bool()
    var fvgInversedArr   = array.new_bool()
    var fvgTouchedArr = array.new_bool()
    var float _cisdPrice = na
    var int _cisdBar = na
    // trade levels
    var float _SLPrice = na
    var float _TPPrice = na
    var float _entryPrice = na
    // delivered counter 
    var int _deliveredCounter = 0

    // reset at NY open and ny kz end (if note an active triggered setup)
    if (hour(time, i_timezone) ==nykzStartHour and minute(time, i_timezone) == nykzStartMin) or (hour(time, i_timezone) == nykzEndHour and minute(time, i_timezone) == nykzEndMin and _IRLState != STATE_TRIGGERED)
        _IRLState := STATE_IDLE
        _tipPrice := na
        _tipBar   := na
        _originPrice := na
        _originBar := na
        fvgTopArr    := array.new_float()
        fvgBotArr    := array.new_float()
        fvgBarArr    := array.new_int()
        fvgBullArr   := array.new_bool()
        fvgInversedArr   := array.new_bool()
        fvgTouchedArr := array.new_bool()
        _cisdPrice := na
        _cisdBar := na
        _SLPrice := na
        _TPPrice := na
        _entryPrice := na
        _deliveredCounter := 0

    // only active during NY AM KZ
    if (hour(time, i_timezone) == nykzStartHour ? minute(time, i_timezone) >= nykzStartMin : hour(time, i_timezone) > nykzStartHour and hour(time, i_timezone) < nykzEndHour)
        // IRL state resets if OTE FVG gets inversed
        if _IRLState == STATE_HUNTING and not _fvgFound
            _IRLState := STATE_IDLE
            _tipPrice := na
            _tipBar   := na
            _originPrice := na
            _originBar := na
            fvgTopArr    := array.new_float()
            fvgBotArr    := array.new_float()
            fvgBarArr    := array.new_int()
            fvgBullArr   := array.new_bool()
            fvgInversedArr   := array.new_bool()
            fvgTouchedArr := array.new_bool()
            _cisdPrice := na
            _cisdBar := na
            _SLPrice := na
            _TPPrice := na
            _entryPrice := na
        // IRL state resets if ERL is reached
        bool _delivered = _fvgBull ? (high >= _rangeTop) : (low <= _rangeBottom)
        if (_IRLState == STATE_HUNTING or _IRLState == STATE_TRIGGERED) and _delivered
            _IRLState := STATE_IDLE
            _tipPrice := na
            _tipBar   := na
            _originPrice := na
            _originBar := na
            fvgTopArr    := array.new_float()
            fvgBotArr    := array.new_float()
            fvgBarArr    := array.new_int()
            fvgBullArr   := array.new_bool()
            fvgInversedArr   := array.new_bool()
            fvgTouchedArr := array.new_bool()
            _cisdPrice := na
            _cisdBar := na
            _SLPrice := na
            _TPPrice := na
            _entryPrice := na
            _deliveredCounter := _deliveredCounter + 1
        // IRL state resets if SL raided (tip price)
        bool _SLHit = _fvgBull ? low <= _SLPrice : high >= _SLPrice
        if _IRLState == STATE_TRIGGERED and _SLHit
            _IRLState := STATE_IDLE
            _tipPrice := na
            _tipBar   := na
            _originPrice := na
            _originBar := na
            fvgTopArr    := array.new_float()
            fvgBotArr    := array.new_float()
            fvgBarArr    := array.new_int()
            fvgBullArr   := array.new_bool()
            fvgInversedArr   := array.new_bool()
            fvgTouchedArr := array.new_bool()
            _cisdPrice := na
            _cisdBar := na
            _SLPrice := na
            _TPPrice := na
            _entryPrice := na
            
        // IRL state enters hunting if OTE FVG is tapped (max 1 delivered setup for DLY and LON)
        bool _tapNow = _fvgFound and _fvgBull ? low <= _fvgTop : high >= _fvgBottom
        if _IRLState == STATE_IDLE and _tapNow and (_session != "NY" ? _deliveredCounter < 1 : true)
            _IRLState := STATE_HUNTING
            // set the tip value
            _tipPrice := _fvgBull ? low : high
            _tipBar   := bar_index
            // calculate origin from newest tip
            [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, _fvgBull)
            _originPrice := _originPriceResult
            _originBar := _originBarResult
            fvgTopArr   := fvgTopArrResult
            fvgBotArr   := fvgBotArrResult
            fvgBarArr   := fvgBarArrResult
            fvgBullArr  := fvgBullArrResult
            fvgInversedArr := fvgInversedArrResult
            fvgTouchedArr := fvgTouchedArrResult
            _cisdPrice := _cisdPriceResult
            _cisdBar := _cisdBarResult
        
        // handle FVG edge case - the immediate candle after the tip creates FVG
        if _tipBar == bar_index - 1
            // re-search the manipulation leg to catch the edge case FVG
            [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, _fvgBull)
            _originPrice := _originPriceResult
            _originBar := _originBarResult
            fvgTopArr   := fvgTopArrResult
            fvgBotArr   := fvgBotArrResult
            fvgBarArr   := fvgBarArrResult
            fvgBullArr  := fvgBullArrResult
            fvgInversedArr := fvgInversedArrResult
            fvgTouchedArr := fvgTouchedArrResult
            _cisdPrice := _cisdPriceResult
            _cisdBar := _cisdBarResult

        // update tip value
        if _IRLState == STATE_HUNTING
            if _fvgBull // longs
                if low < _tipPrice
                    _tipPrice := low
                    _tipBar := bar_index
                    // recalculate origin from newest tip
                    [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, _fvgBull)
                    _originPrice := _originPriceResult
                    _originBar := _originBarResult
                    fvgTopArr   := fvgTopArrResult
                    fvgBotArr   := fvgBotArrResult
                    fvgBarArr   := fvgBarArrResult
                    fvgBullArr  := fvgBullArrResult
                    fvgInversedArr := fvgInversedArrResult
                    fvgTouchedArr := fvgTouchedArrResult
                    _cisdPrice := _cisdPriceResult
                    _cisdBar := _cisdBarResult
            else // shorts
                if high > _tipPrice
                    _tipPrice := high
                    _tipBar := bar_index
                    // recalculate origin from newest tip
                    [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, _fvgBull)
                    _originPrice := _originPriceResult
                    _originBar := _originBarResult
                    fvgTopArr   := fvgTopArrResult
                    fvgBotArr   := fvgBotArrResult
                    fvgBarArr   := fvgBarArrResult
                    fvgBullArr  := fvgBullArrResult
                    fvgInversedArr := fvgInversedArrResult
                    fvgTouchedArr := fvgTouchedArrResult
                    _cisdPrice := _cisdPriceResult
                    _cisdBar := _cisdBarResult

        // IFVG/CISD ENTRY TRIGGER
        if _IRLState == STATE_HUNTING
            ifvgTrigger = f_checkIFVGs(fvgTopArr, fvgBotArr, fvgBullArr, fvgInversedArr, fvgTouchedArr)
            [cisdTrigger, cisdCleared] = f_checkCISD(_cisdPrice, fvgTopArr, fvgBotArr, fvgBullArr, _fvgBull)
            if cisdCleared
                _cisdPrice := na
            if ifvgTrigger or cisdTrigger
                _SLPrice := _tipPrice
                _TPPrice := _fvgBull ? _rangeTop : _rangeBottom
                _entryPrice := close
                // rule out negative RR setups i.e. < 1:1
                if math.abs(_entryPrice - _SLPrice) < math.abs(_TPPrice - _entryPrice)
                    _IRLState := STATE_TRIGGERED
                    label.new(bar_index, high, _fvgBull ? "LONG" : "SHORT")
                    // Draw SL & TP lines
                    line.new(x1 = bar_index, y1 = _SLPrice, x2 = bar_index + 20, y2 = _SLPrice, color = color.red, width = 2)
                    line.new(x1 = bar_index, y1 = _TPPrice, x2 = bar_index + 20, y2 = _TPPrice, color = color.green, width = 2)
                    line.new(x1 = bar_index, y1 = _entryPrice, x2 = bar_index + 20, y2 = _entryPrice, color = color.blue, width = 2)
                    label.new(bar_index + 27, _SLPrice, "SL: " + str.tostring(_SLPrice, format.mintick), style=label.style_none, color=color.red, textcolor=color.red, size=size.small)
                    label.new(bar_index + 27, _TPPrice, "TP: " + str.tostring(_TPPrice, format.mintick), style=label.style_none, color=color.green, textcolor=color.green, size=size.small)
                    label.new(bar_index + 27, _entryPrice, "ENTRY: " + str.tostring(_entryPrice, format.mintick), style=label.style_none, color=color.blue, textcolor=color.blue, size=size.small)
                    box.new(left=bar_index, right=bar_index+20, top=math.max(_entryPrice, _TPPrice), bottom=math.min(_entryPrice, _TPPrice), bgcolor=color.new(color.blue, 85), border_color=na)
                    box.new(left=bar_index, right=bar_index+20, top=math.max(_entryPrice, _SLPrice), bottom=math.min(_entryPrice, _SLPrice), bgcolor=color.new(#787b86, 85), border_color=na)
    [_IRLState, _tipPrice, _tipBar, _originPrice, _originBar, fvgTopArr, fvgBotArr, fvgBarArr, fvgBullArr, fvgInversedArr, fvgTouchedArr, _cisdPrice, _cisdBar]

f_sweepChecker(_level, _isHigh) =>
    var int _ERLState = STATE_IDLE
    var int _touchCounter = 0
    var float _sweepPrice = na
    var float _tipPrice = na
    var int   _tipBar   = na
    var float _originPrice = na
    var int   _originBar   = na
    var fvgTopArr    = array.new_float()
    var fvgBotArr    = array.new_float()
    var fvgBarArr    = array.new_int()
    var fvgBullArr   = array.new_bool()
    var fvgInversedArr   = array.new_bool()
    var fvgTouchedArr = array.new_bool()
    var float _cisdPrice = na
    var int _cisdBar = na
    // trade levels
    var float _SLPrice = na
    var float _TPPrice = na
    var float _entryPrice = na

    // check completion conditions
    if _ERLState == STATE_TRIGGERED
        bool SLHit = _isHigh ? high > _SLPrice : low < _SLPrice
        bool TPHit = _isHigh ? low < _TPPrice : high > _TPPrice
        if SLHit or TPHit
            if hour(time, i_timezone) >= nykzEndHour
                _ERLState := STATE_IDLE
            else
                _ERLState := STATE_COMPLETED

    // reset at NY open and at ny kz end (if not an active triggered trade)
    if (hour(time, i_timezone) == nykzStartHour and minute(time, i_timezone) == nykzStartMin) or (hour(time, i_timezone) == nykzEndHour and minute(time, i_timezone) == nykzEndHour and _ERLState != STATE_TRIGGERED)
        _ERLState := STATE_IDLE
        _touchCounter := 0
        _tipPrice := na
        _tipBar   := na
        _originPrice := na
        _originBar := na
        fvgTopArr    := array.new_float()
        fvgBotArr    := array.new_float()
        fvgBarArr    := array.new_int()
        fvgBullArr   := array.new_bool()
        fvgInversedArr   := array.new_bool()
        _cisdPrice := na
        _cisdBar := na
        _SLPrice := na
        _TPPrice := na
        _entryPrice := na

    // only active during NY AM KZ
    if (hour(time, i_timezone) == nykzStartHour ? minute(time, i_timezone) >= nykzStartMin : hour(time, i_timezone) > nykzStartHour and hour(time, i_timezone) < nykzEndHour)
        // ERL state enters hunting if level is swept
        bool _sweepNow = _isHigh ? high >= _level : low <= _level
        if _ERLState == STATE_IDLE and _sweepNow
            _touchCounter := _touchCounter + 1
            _ERLState := STATE_HUNTING
            // set tip value
            _tipPrice := _isHigh ? high : low
            _tipBar   := bar_index
            // search the manipulation leg
            [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, not _isHigh)
            _originPrice := _originPriceResult
            _originBar := _originBarResult
            fvgTopArr   := fvgTopArrResult
            fvgBotArr   := fvgBotArrResult
            fvgBarArr   := fvgBarArrResult
            fvgBullArr  := fvgBullArrResult
            fvgInversedArr := fvgInversedArrResult
            fvgTouchedArr := fvgTouchedArrResult
            _cisdPrice := _cisdPriceResult
            _cisdBar := _cisdBarResult

        // handle FVG edge case - the immediate candle after the tip creates FVG
        if _tipBar == bar_index - 1
            // re-search the manipulation leg to catch the edge case FVG
            [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, not _isHigh)
            _originPrice := _originPriceResult
            _originBar := _originBarResult
            fvgTopArr   := fvgTopArrResult
            fvgBotArr   := fvgBotArrResult
            fvgBarArr   := fvgBarArrResult
            fvgBullArr  := fvgBullArrResult
            fvgInversedArr := fvgInversedArrResult
            fvgTouchedArr := fvgTouchedArrResult
            _cisdPrice := _cisdPriceResult
            _cisdBar := _cisdBarResult

        // update tip value
        if _ERLState == STATE_HUNTING
            if not _isHigh // longs
                if low < _tipPrice
                    _tipPrice := low
                    _tipBar := bar_index
                    // recalculate origin from newest tip
                    [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, not _isHigh)
                    _originPrice := _originPriceResult
                    _originBar := _originBarResult
                    fvgTopArr   := fvgTopArrResult
                    fvgBotArr   := fvgBotArrResult
                    fvgBarArr   := fvgBarArrResult
                    fvgBullArr  := fvgBullArrResult
                    fvgInversedArr := fvgInversedArrResult
                    fvgTouchedArr := fvgTouchedArrResult
                    _cisdPrice := _cisdPriceResult
                    _cisdBar := _cisdBarResult
            else // shorts
                if high > _tipPrice
                    _tipPrice := high
                    _tipBar := bar_index
                    // recalculate origin from newest tip
                    [_originPriceResult, _originBarResult, fvgTopArrResult, fvgBotArrResult, fvgBarArrResult, fvgBullArrResult, fvgInversedArrResult, fvgTouchedArrResult, _cisdPriceResult, _cisdBarResult] = f_findManipulationLeg(_tipBar, not _isHigh)
                    _originPrice := _originPriceResult
                    _originBar := _originBarResult
                    fvgTopArr   := fvgTopArrResult
                    fvgBotArr   := fvgBotArrResult
                    fvgBarArr   := fvgBarArrResult
                    fvgBullArr  := fvgBullArrResult
                    fvgInversedArr := fvgInversedArrResult
                    fvgTouchedArr := fvgTouchedArrResult
                    _cisdPrice := _cisdPriceResult
                    _cisdBar := _cisdBarResult
            
        // IFVG/CISD ENTRY TRIGGER
        if _ERLState == STATE_HUNTING
            ifvgTrigger = f_checkIFVGs(fvgTopArr, fvgBotArr, fvgBullArr, fvgInversedArr, fvgTouchedArr)
            [cisdTrigger, cisdCleared] = f_checkCISD(_cisdPrice, fvgTopArr, fvgBotArr, fvgBullArr, not _isHigh)
            if cisdCleared
                _cisdPrice := na
            if ifvgTrigger or cisdTrigger
                //_ERLState := STATE_TRIGGERED
                _SLPrice := _tipPrice
                // find IRL OTE for TP
                int swingRange = 50
                float majorSwing = na
                int majorSwingBar = na
                for i = swingRange to 500
                    bool isSwing = true
                    for j = 1 to swingRange
                        if _isHigh ? low[i] >= low[i - j] or low[i] > low[i + j] : high[i] <= high[i - j] or high[i] < high[i + j]
                            isSwing := false
                            break
                    if isSwing
                        majorSwing := high[i]
                        majorSwingBar := bar_index - i
                        break
                _TPPrice := _isHigh ? _SLPrice - (_SLPrice - majorSwing) * 0.62 : _SLPrice + (majorSwing - _SLPrice) * 0.62
                _entryPrice := close
                // rule out negative RR setups i.e. < 1:1
                if math.abs(_entryPrice - _SLPrice) <= math.abs(_TPPrice - _entryPrice)
                    _ERLState := STATE_TRIGGERED
                    label.new(bar_index, high, _isHigh ? "SHORT" : "LONG")
                    // Draw SL & TP lines
                    line.new(x1 = bar_index, y1 = _SLPrice, x2 = bar_index + 20, y2 = _SLPrice, color = color.red, width = 2)
                    line.new(x1 = bar_index, y1 = _TPPrice, x2 = bar_index + 20, y2 = _TPPrice, color = color.green, width = 2)
                    line.new(x1 = bar_index, y1 = _entryPrice, x2 = bar_index + 20, y2 = _entryPrice, color = color.blue, width = 2)
                    label.new(bar_index + 27, _SLPrice, "SL: " + str.tostring(_SLPrice, format.mintick), style=label.style_none, color=color.red, textcolor=color.red, size=size.small)
                    label.new(bar_index + 27, _TPPrice, "TP: " + str.tostring(_TPPrice, format.mintick), style=label.style_none, color=color.green, textcolor=color.green, size=size.small)
                    label.new(bar_index + 27, _entryPrice, "ENTRY: " + str.tostring(_entryPrice, format.mintick), style=label.style_none, color=color.blue, textcolor=color.blue, size=size.small)
                    box.new(left=bar_index, right=bar_index+20, top=math.max(_entryPrice, _TPPrice), bottom=math.min(_entryPrice, _TPPrice), bgcolor=color.new(color.blue, 85), border_color=na)
                    box.new(left=bar_index, right=bar_index+20, top=math.max(_entryPrice, _SLPrice), bottom=math.min(_entryPrice, _SLPrice), bgcolor=color.new(color.gray, 85), border_color=na)
                else 
                    _ERLState := STATE_COMPLETED

    [_ERLState, _tipPrice, _tipBar,  _originPrice, _originBar, fvgTopArr, fvgBotArr, fvgBarArr, fvgBullArr, fvgInversedArr, fvgTouchedArr, _cisdPrice, _cisdBar]

[dlyIRLState, _dlyTipPrice, _dlyTipBar, _dlyOriginPrice, _dlyOriginBar, dlyFvgTopArr, dlyFvgBotArr, dlyFvgBarArr, dlyFvgBullArr, dlyFvgInversedArr, dlyFvgTouchedArr, _dlyCisdPrice, _dlyCisdBar] = f_oteTapChecker(dlyFvgTop, dlyFvgBot, dlyFvgFound, dlyFvgBull, dlyExtTop, dlyExtBottom, dlyOteTop, dlyOteBottom, "DLY")
[lonIRLState, _lonTipPrice, _lonTipBar, _lonOriginPrice, _lonOriginBar, lonFvgTopArr, lonFvgBotArr, lonFvgBarArr, lonFvgBullArr, lonFvgInversedArr, lonFvgTouchedArr, _lonCisdPrice, _lonCisdBar] = f_oteTapChecker(lonFvgTop, lonFvgBot, lonFvgFound, lonFvgBull, lonExtTop, lonExtBottom, lonOteTop, lonOteBottom, "LON")
[nykzIRLState, _nykzTipPrice, _nykzTipBar, _nykzOriginPrice, _nykzOriginBar, nykzFvgTopArr, nykzFvgBotArr, nykzFvgBarArr, nykzFvgBullArr, nykzFvgInversedArr, nykzFvgTouchedArr, _nykzCisdPrice, _nykzCisdBar] = f_oteTapChecker(nykzFvgTop, nykzFvgBot, nykzFvgFound, nykzFvgBull, nykzTop, nykzBottom, _nykzOteTop, _nykzOteBtm, "NY")

// London range has engulfed Asia High or Low
bool asiaHighEngulfed = not na(lonTop) and lonTop >= asiaHigh
bool asiaLowEngulfed = not na(lonBottom) and lonBottom <= asiaLow

[lonHERLState, _lonHTipPrice, _lonHTipBar, _lonHOriginPrice, _lonHOriginBar, lonHFvgTopArr, lonHFvgBotArr, lonHFvgBarArr, lonHFvgBullArr, lonHFvgInversedArr, lonHFvgTouchedArr, _lonHCisdPrice, _lonHCisdBar] = f_sweepChecker(londonHigh, _isHigh=true)
[lonLERLState, _lonLTipPrice, _lonLTipBar, _lonLOriginPrice, _lonLOriginBar, lonLFvgTopArr, lonLFvgBotArr, lonLFvgBarArr, lonLFvgBullArr, lonLFvgInversedArr, lonLFvgTouchedArr, _lonLCisdPrice, _lonLCisdBar] = f_sweepChecker(londonLow, _isHigh=false)

[asiaHERLState, _asiaHTipPrice, _asiaHTipBar, _asiaHOriginPrice, _asiaHOriginBar, asiaHFvgTopArr, asiaHFvgBotArr, asiaHFvgBarArr, asiaHFvgBullArr, asiaHFvgInversedArr, asiaHFvgTouchedArr, _asiaHCisdPrice, _asiaHCisdBar] = f_sweepChecker(asiaHigh, _isHigh=true)
[asiaLERLState, _asiaLTipPrice, _asiaLTipBar, _asiaLOriginPrice, _asiaLOriginBar, asiaLFvgTopArr, asiaLFvgBotArr, asiaLFvgBarArr, asiaLFvgBullArr, asiaLFvgInversedArr, asiaLFvgTouchedArr, _asiaLCisdPrice, _asiaLCisdBar] = f_sweepChecker(asiaLow, _isHigh=false)
if asiaHighEngulfed
    asiaHERLState := STATE_IDLE
if asiaLowEngulfed
    asiaLERLState := STATE_IDLE

// if barstate.islast
//     var table setupTable = table.new(position.bottom_left, 1, 1, bgcolor=color.new(color.black, 20))
    
//     table.cell(setupTable, 0, 0, str.tostring(londonHigh),     text_color=color.white)

// // debug tip, origin and cisd values
// if barstate.islast
//     var table setupTable = table.new(position.bottom_left, 2, 3, bgcolor=color.new(color.black, 20))
    
//     table.cell(setupTable, 0, 0, "tip price",     text_color=color.white)
//     table.cell(setupTable, 1, 0, str.tostring(_dlyTipPrice),     text_color=color.white)
//     table.cell(setupTable, 0, 1, "origin price",     text_color=color.white)
//     table.cell(setupTable, 1, 1, str.tostring(_dlyOriginPrice),     text_color=color.white)
//     table.cell(setupTable, 0, 2, "cisd price",     text_color=color.white)
//     table.cell(setupTable, 1, 2, str.tostring(_dlyCisdPrice),     text_color=color.white)

// // debug lonH FVG values
// if barstate.islast
//     var table nykzFvgTable = table.new(position.middle_left, 7, 20, bgcolor=color.new(color.black, 20))

//     table.cell(nykzFvgTable, 0, 0, "Index", text_color=color.white)
//     table.cell(nykzFvgTable, 1, 0, "FVG Top", text_color=color.white)
//     table.cell(nykzFvgTable, 2, 0, "FVG Bot", text_color=color.white)
//     table.cell(nykzFvgTable, 3, 0, "FVG Bar", text_color=color.white)
//     table.cell(nykzFvgTable, 4, 0, "Bull", text_color=color.white)
//     table.cell(nykzFvgTable, 5, 0, "Inversed", text_color=color.white)
//     table.cell(nykzFvgTable, 6, 0, "Touched", text_color=color.white)

//     if array.size(asiaHFvgTopArr) > 0
//         for i = 0 to math.min(array.size(asiaHFvgTopArr), 19) - 1
//             table.cell(nykzFvgTable, 0, i + 1, str.tostring(i), text_color=color.white)
//             table.cell(nykzFvgTable, 1, i + 1, str.tostring(array.get(asiaHFvgTopArr, i)), text_color=color.white)
//             table.cell(nykzFvgTable, 2, i + 1, str.tostring(array.get(asiaHFvgBotArr, i)), text_color=color.white)
//             table.cell(nykzFvgTable, 3, i + 1, str.tostring(array.get(asiaHFvgBarArr, i)), text_color=color.white)
//             table.cell(nykzFvgTable, 4, i + 1, str.tostring(array.get(asiaHFvgBullArr, i)), text_color=color.white)
//             table.cell(nykzFvgTable, 5, i + 1, str.tostring(array.get(asiaHFvgInversedArr, i)), text_color=color.white)
//             table.cell(nykzFvgTable, 6, i + 1, str.tostring(array.get(asiaHFvgTouchedArr, i)), text_color=color.white)
//     else
//         table.cell(nykzFvgTable, 0, 1, "No FVGs", text_color=color.white)

f_stateToString(_state) =>
    switch _state
        STATE_IDLE => "IDLE"
        STATE_HUNTING => "HUNTING"
        STATE_TRIGGERED => "TRIGGERED"
        STATE_COMPLETED => "COMPLETED"
        => "ERROR"
f_stateColor(_state) =>
    switch _state
        STATE_IDLE => color.white
        STATE_HUNTING => color.blue
        STATE_TRIGGERED => color.green
        STATE_COMPLETED => color.gray
        => color.gray

// UI
if barstate.islast
    var table setupTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20))

    table.cell(setupTable, 0, 0, "Session", text_color=color.white)
    table.cell(setupTable, 1, 0, "IRL->ERL", text_color=color.white)

    table.cell(setupTable, 0, 1, "DLY", text_color=color.white)
    table.cell(setupTable, 1, 1,  f_stateToString(dlyIRLState), text_color=f_stateColor(dlyIRLState))
    
    table.cell(setupTable, 0, 2, "LON", text_color=color.white)
    table.cell(setupTable, 1, 2,  f_stateToString(lonIRLState), text_color=f_stateColor(lonIRLState))
    
    table.cell(setupTable, 0, 3, "NY AM", text_color=color.white)
    table.cell(setupTable, 1, 3,  f_stateToString(nykzIRLState), text_color=f_stateColor(nykzIRLState))

if barstate.islast
    var table setupTable = table.new(position.bottom_right, 2, 5, bgcolor=color.new(color.black, 20))

    table.cell(setupTable, 0, 0, "Level", text_color=color.white)
    table.cell(setupTable, 1, 0, "ERL->IRL", text_color=color.white)

    table.cell(setupTable, 0, 1, "LON.H", text_color=color.white)
    table.cell(setupTable, 1, 1,  f_stateToString(lonHERLState), text_color=f_stateColor(lonHERLState))
    
    table.cell(setupTable, 0, 2, "LON.L", text_color=color.white)
    table.cell(setupTable, 1, 2,  f_stateToString(lonLERLState), text_color=f_stateColor(lonLERLState))
    
    table.cell(setupTable, 0, 3, "ASIA.H", text_color=color.white)
    table.cell(setupTable, 1, 3,  f_stateToString(asiaHERLState), text_color=f_stateColor(asiaHERLState))

    table.cell(setupTable, 0, 4, "ASIA.L", text_color=color.white)
    table.cell(setupTable, 1, 4,  f_stateToString(asiaLERLState), text_color=f_stateColor(asiaLERLState))
````
