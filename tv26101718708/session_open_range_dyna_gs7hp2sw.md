# Session Open Range [DYNA]

- url: https://www.tradingview.com/script/gs7Hp2SW-Session-Open-Range-DYNA/
- type: indicator
- pine_id: PUB;0591bffd6ef44a23a633ae41922dd213
- version: 1.0

## Description

Session Open Range captures the high and low of the first few minutes of every trading session and tracks breakouts from that range for the rest of the day. The opening range is the session's initial balance: once it is set, the first decisive break above or below the range is a structural reference many traders watch for the day's directional bias. This indicator draws the opening range as a box, extends the high and low as dashed lines through the session, and marks the first breakout in each direction with a triangle.

Most ORB tools are hardcoded to a single exchange. Session Open Range is configurable end-to-end: pick any session window, any timezone, any OR duration. It works identically on a stock or index cash session, on NYSE 9:30--16:00 ET, on a London or Tokyo forex session, or on a custom 24h UTC-anchored crypto session. Only the first breakout in each direction fires per session, so you get one clean bullish signal and one clean bearish signal -- no noise from re-crosses.


[b]Key Features[/b]

[list]
[*] [b]Any Session, Any Timezone[/b] -- Uses TradingView's native session picker plus a timezone dropdown so the same indicator works across global markets without code edits.
[*] [b]Configurable OR Duration[/b] -- Opening range length is a free-text minute input. Scalpers can use 5 minutes, swing-oriented intraday traders 30 or 60.
[*] [b]Live OR Box[/b] -- The box forms bar-by-bar during the formation window, then freezes when the OR locks. A subtle background tint highlights the formation bars.
[*] [b]Dashed Extension Lines[/b] -- The OR high (green) and OR low (red) extend through the session as dashed horizontal levels, so you always know where price is relative to the initial balance.
[*] [b]First-Breakout Markers[/b] -- A green triangle marks the first bar that closes above the OR high; a red triangle marks the first close below the OR low. One per direction per session.
[*] [b]Multi-Session History[/b] -- Keep the last N sessions of boxes and lines on the chart to study how price reacts to recent opening ranges.
[*] [b]No Repainting[/b] -- All state transitions and signals are gated on confirmed bars. Arrows never move after they appear.
[/list]


[b]How It Works[/b]

At the start of each session (determined by your session window and timezone), the indicator begins tracking the high and low of every bar. During the formation window -- the first N minutes of the session -- the opening range box expands as each new bar's high or low extends the range. A light orange background tint marks the bars that are still inside the formation window so you can see it forming in real time.

When the formation window closes, the OR is locked: the box border changes to orange, and the OR high and OR low are extended forward as dashed horizontal lines (green for the high, red for the low). The indicator then watches every subsequent bar in the session. The first bar whose close breaks above the OR high gets a green triangle below it labeled "BO". The first bar whose close breaks below the OR low gets a red triangle above it labeled "BO". Only one arrow fires in each direction per session -- subsequent re-crosses are intentionally ignored, because only the first break of the initial balance carries structural significance.

When the session ends and a new one begins, the entire cycle resets. Older sessions are kept on the chart up to the configured history limit, then deleted automatically to prevent clutter.

[image]https://www.tradingview.com/x/oFd9UeVz/[/image]
[i]The opening range box forms during the first 15 minutes, freezes with an orange border, then extends the OR high and OR low forward as dashed lines. The first close above the OR high triggers a green breakout arrow.[/i]


[b]Settings[/b]

[b]Opening Range Period (min)[/b] (default: 15) defines how many minutes from session open are used to build the opening range. Common choices are 5 for scalpers, 15 for intraday traders, 30 or 60 for swing-oriented day traders. [b]Session Time[/b] (default: 0915-1530) is the trading session window; the TradingView session picker supports day-of-week masks for instruments that do not trade every day. [b]Timezone[/b] (default: Asia/Kolkata) interprets the session string -- match the exchange's local time to avoid DST errors.

[b]Max Sessions to Keep[/b] (default: 5) limits how many past sessions of boxes and extension lines are kept on the chart. Older drawings are deleted automatically, so the script stays within TradingView's drawing object budget even on long histories.

Visual toggles let you independently show or hide the OR box, the extension lines, the breakout arrows, and the formation-window tint. [b]Box Fill Transparency[/b] (default: 85) controls how see-through the box fill is. The two alert toggles enable or disable the bullish and bearish breakout alerts individually.


[b]Alerts[/b]

[list]
[*] [b]Bullish Breakout[/b] -- Fires the first time price closes above the OR high in a given session. [i]"Session Open Range [DYNA]: Bullish breakout above opening range high."[/i]
[*] [b]Bearish Breakout[/b] -- Fires the first time price closes below the OR low in a given session. [i]"Session Open Range [DYNA]: Bearish breakout below opening range low."[/i]
[/list]

To set up alerts: click TradingView's Alerts button, choose "Session Open Range [DYNA]" from the condition dropdown, pick Bullish Breakout or Bearish Breakout, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Pick an OR duration that aligns with whole bars on your chart timeframe. A 15-minute OR on a 5-minute chart builds from exactly three bars -- clean and unambiguous.
[*] On fast-moving sessions, a longer OR (30-60 minutes) filters out opening volatility. On quiet sessions, a shorter OR (5-15 minutes) gives signals sooner.
[*] Inside-range days (no arrow fires all session) often precede expansion. Watch for a breakout on the next session or just after the close.
[*] Combine with a higher-timeframe trend filter for directional bias -- take only bullish breakouts above the higher-timeframe EMA, bearish breakouts below.
[*] Reduce [b]Max Sessions to Keep[/b] to 1 or 2 if extension lines from older sessions crowd the chart.
[*] Always double-check that [b]Session Time[/b] and [b]Timezone[/b] match the actual trading hours of your instrument; a misaligned session is the most common source of weird-looking opening ranges.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Session Open Range is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Session Open Range [DYNA]
// Captures the first N minutes of each session as an opening range and marks the first breakout in each direction.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Session Open Range [DYNA]", shorttitle = "SOR [DYNA]", overlay = true,
         max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
int    i_orPeriod    = input.int(15, "Opening Range Period (min)", minval = 1, maxval = 240, step = 1, group = GRP_CORE, tooltip = "Minutes from session open used to build the opening range. Common values: 5, 15, 30, 60.")
string i_session     = input.session("0915-1530", "Session Time", group = GRP_CORE, tooltip = "Session window during which the opening range is tracked. Uses the native TradingView session picker.")
string i_timezone    = input.string("Asia/Kolkata", "Timezone", options = ["Asia/Kolkata", "America/New_York", "America/Chicago", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore", "Australia/Sydney"], group = GRP_CORE, tooltip = "Timezone used to interpret the session window. Match the exchange's local time to avoid DST drift.")
int    i_maxSessions = input.int(5, "Max Sessions to Keep", minval = 1, maxval = 20, group = GRP_CORE, tooltip = "How many past sessions worth of boxes and extension lines to keep on the chart. Older drawings are deleted automatically.")

// --- Visual ---
bool i_showBox     = input.bool(true, "Show OR Box", group = GRP_VIS, tooltip = "Display the shaded opening range box.")
bool i_extendLines = input.bool(true, "Show Extension Lines", group = GRP_VIS, tooltip = "Draw the OR high and low as dashed horizontal lines that extend forward through the session.")
bool i_showArrows  = input.bool(true, "Show Breakout Arrows", group = GRP_VIS, tooltip = "Mark the bar that first closes beyond the OR high or OR low in each session.")
bool i_tintWindow  = input.bool(true, "Highlight Formation Window", group = GRP_VIS, tooltip = "Add a subtle background tint during the opening range formation window.")
int  i_boxOpacity  = input.int(85, "Box Fill Transparency", minval = 50, maxval = 95, group = GRP_VIS, tooltip = "Higher = more transparent box fill.")

// --- Alerts ---
bool i_alertBull = input.bool(true, "Alert: Bullish Breakout", group = GRP_ALERT, tooltip = "Fire an alert the first time price closes above the OR high during the session.")
bool i_alertBear = input.bool(true, "Alert: Bearish Breakout", group = GRP_ALERT, tooltip = "Fire an alert the first time price closes below the OR low during the session.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Session anchoring ---
// `sessionDay` returns a constant timestamp (the session's daily start) for every
// bar that falls inside the configured session window, and `na` otherwise.
// Detecting newSession via `sessionDay != sessionDay[1]` is robust whether or not
// the chart shows off-hours bars -- plain `na(sessionBar[1])` breaks when
// TradingView hides out-of-session bars (the common default for intraday charts).
int  sessionDay = time("D", i_session, i_timezone)
bool inSession  = not na(sessionDay)
bool newSession = inSession and (na(sessionDay[1]) or sessionDay != sessionDay[1])

// --- Per-session persistent state ---
var float orHigh           = na
var float orLow            = na
var int   orStartBar       = na
var int   orEndBar         = na
var int   sessionStartTime = na
var bool  bullBroken       = false
var bool  bearBroken       = false
var bool  formationClosed  = false

// --- Draw handle storage (history + current-session pointers) ---
var array<box>  boxHandles = array.new<box>()
var array<line> highLines  = array.new<line>()
var array<line> lowLines   = array.new<line>()

var box  activeBox        = na
var line currentHighLine  = na
var line currentLowLine   = na

// --- Formation window gate (uses elapsed minutes inside the current session) ---
int  elapsedMin  = inSession and not na(sessionStartTime) ? math.floor((time - sessionStartTime) / 60000) : na
bool inFormation = inSession and not na(elapsedMin) and elapsedMin < i_orPeriod

// --- Signals (reset each bar) ---
bool bullBreak = false
bool bearBreak = false

if barstate.isconfirmed
    if newSession
        // --- Start a new session: reset state, seed OR with first bar ---
        orHigh           := high
        orLow            := low
        orStartBar       := bar_index
        orEndBar         := bar_index
        sessionStartTime := time
        bullBroken       := false
        bearBroken       := false
        formationClosed  := false
        activeBox        := na
        currentHighLine  := na
        currentLowLine   := na

        if i_showBox
            activeBox := box.new(orStartBar, orHigh, orEndBar, orLow,
                                 border_color = NEUTRAL_COLOR,
                                 border_width = 1,
                                 bgcolor = color.new(NEUTRAL_COLOR, i_boxOpacity))
            array.push(boxHandles, activeBox)
            while array.size(boxHandles) > i_maxSessions
                box old = array.shift(boxHandles)
                if not na(old)
                    box.delete(old)

    else if inSession and inFormation
        // --- Inside formation window: expand OR high/low ---
        orHigh   := math.max(nz(orHigh, high), high)
        orLow    := math.min(nz(orLow,  low),  low)
        orEndBar := bar_index
        if i_showBox and not na(activeBox)
            box.set_top(activeBox, orHigh)
            box.set_bottom(activeBox, orLow)
            box.set_right(activeBox, orEndBar)

    else if inSession and not inFormation and not formationClosed and not na(orHigh)
        // --- Formation just closed: lock box, draw extension lines ---
        formationClosed := true
        if i_showBox and not na(activeBox)
            box.set_right(activeBox, orEndBar)
            box.set_border_color(activeBox, WARNING_COLOR)
        if i_extendLines
            currentHighLine := line.new(orEndBar, orHigh, bar_index, orHigh,
                                        color = BULL_COLOR, style = line.style_dashed, width = 1)
            currentLowLine  := line.new(orEndBar, orLow,  bar_index, orLow,
                                        color = BEAR_COLOR, style = line.style_dashed, width = 1)
            array.push(highLines, currentHighLine)
            array.push(lowLines,  currentLowLine)
            while array.size(highLines) > i_maxSessions
                line oldH = array.shift(highLines)
                if not na(oldH)
                    line.delete(oldH)
            while array.size(lowLines) > i_maxSessions
                line oldL = array.shift(lowLines)
                if not na(oldL)
                    line.delete(oldL)

    // --- Keep extension lines tracking the right edge of the current session ---
    if inSession and formationClosed and i_extendLines
        if not na(currentHighLine)
            line.set_x2(currentHighLine, bar_index)
        if not na(currentLowLine)
            line.set_x2(currentLowLine, bar_index)

    // --- First-breakout detection (one per direction per session) ---
    if inSession and formationClosed and not na(orHigh)
        if not bullBroken and close > orHigh
            bullBroken := true
            bullBreak  := true
        if not bearBroken and close < orLow
            bearBroken := true
            bearBreak  := true

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Breakout arrows ---
plotshape(i_showArrows and bullBreak ? true : false, title = "Bullish Breakout",
          style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.small, text = "BO", textcolor = BULL_COLOR)
plotshape(i_showArrows and bearBreak ? true : false, title = "Bearish Breakout",
          style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.small, text = "BO", textcolor = BEAR_COLOR)

// --- Formation window tint ---
bgcolor(i_tintWindow and inFormation ? color.new(WARNING_COLOR, 92) : na, title = "OR Formation Window")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullBreak and i_alertBull, title = "Bullish Breakout",
    message = "Session Open Range [DYNA]: Bullish breakout above opening range high.")
alertcondition(bearBreak and i_alertBear, title = "Bearish Breakout",
    message = "Session Open Range [DYNA]: Bearish breakout below opening range low.")
````
