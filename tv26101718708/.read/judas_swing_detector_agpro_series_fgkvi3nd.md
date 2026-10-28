# Judas Swing Detector [AGPro Series]

- url: https://www.tradingview.com/script/fgkVI3nD-Judas-Swing-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;5c01b099da684f539b7414e28769ab40
- version: 4.0

## Description

Judas Swing Detector [AGPro Series]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The Judas Swing is a well-known intraday pattern in ICT (Inner Circle Trader)
methodology describing how price often makes a deceptive initial move at the
London or New York session open — pulling in participants in one direction —
before reversing to reveal the session's true directional bias.

Judas Swing Detector systematically identifies, visualizes, and tracks this
pattern across every London and New York session open. It shades the trap
zone, flags the reversal bar, highlights the true-direction bias, and maintains
a rolling 20-session performance log so users can assess how consistently the
pattern resolves on their chosen symbol and timeframe.

IMPORTANT — Timeframe requirement: This indicator is designed for intraday
charts of 1 hour or lower (1m, 5m, 15m, 30m, 1h). Session windows anchor the
entire logic, and a 1-hour Judas window cannot be resolved on 4-hour or higher
charts. The panel always shows an "Optimal TF: 1m - 1h" footer, and the TF
status row turns yellow with "use <=1h" if the current chart exceeds this
range.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UNIQUE EDGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Unlike generic session-open or breakout indicators, Judas Swing Detector is
built around a defined four-state lifecycle (Pending → Active → Forming →
Confirmed / Failed) with ATR-normalized thresholds, so detection remains
stable across different volatility regimes and asset classes.

Three design choices make it distinct:

1. Independent two-way extremum tracking inside the Judas window — both the
   maximum upward and maximum downward excursion are recorded, and the larger
   of the two is declared the fake move when the window closes. This removes
   ambiguity in choppy openings.

2. Separate fake-move and reversal thresholds. The initial push must exceed
   a minimum ATR-scaled size to qualify, and the reversal must travel a second
   ATR-scaled distance beyond the session open — filtering out shallow round
   trips that would otherwise inflate the signal count.

3. Rolling 20-session statistics panel reporting success rate, average fake
   distance, and directional bias, giving discretionary traders an objective
   view of how the pattern is behaving on their instrument before they act on
   it.

4. Support/resistance-style invalidation zone drawn at the fake-move extremum
   after confirmation. This gives a clear visual anchor: if price later
   re-enters this zone from the opposite side during the session, the Judas
   read is considered broken. The zone is a reference, not an automatic
   signal.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
METHODOLOGY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1 — Session anchoring
At the first bar of the configured London or New York window the script
records the session open price, resets the two-way extremum trackers, and
transitions to the Active state.

Step 2 — Fake-move accumulation
During the window the script tracks both the maximum high and minimum low
relative to the session open. Neither is committed as the fake move until the
window closes.

Step 3 — Window-close evaluation
When the window ends the larger excursion (up vs down) becomes the fake
direction. If its size reaches the user-defined ATR multiple it qualifies and
the script transitions to the Forming state; otherwise it resets to idle.

Step 4 — Reversal confirmation
In the Forming state the script waits for price to cross the session open in
the opposite direction of the fake move and travel at least the configured
ATR-scaled distance beyond it. When that happens the swing is Confirmed and
the true direction is drawn on the chart. If the reversal window expires
without confirmation the swing is recorded as Failed.

Step 5 — History log
Every confirmed and failed outcome is appended to a rolling 20-session log
used by the statistics panel.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNALS & ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

On-chart visuals:
  • Dashed vertical line at session start (accent color)
  • "LON" or "NY" label at the session anchor bar (Balanced / Detailed only)
  • Shaded fake-move box from session open to fake extremum, colored opposite
    to the true direction (a bearish trap is shaded in the bear tone because
    the true direction is down — and vice versa)
  • Optional "Fake" distance label at the extremum (Detailed density only)
  • Reversal marker "X  UP" or "X  DOWN" at the confirmation bar, offset
    from the candles for readability
  • Horizontal support/resistance-style invalidation zone around the fake
    extremum, extending 40 bars to the right — a visual reference for where
    the Judas read would break down if price re-enters the zone

Alert conditions (toggle individually in settings):
  • Judas Swing Forming — fake move has qualified, waiting for reversal
  • Judas Swing Confirmed — reversal threshold crossed, true direction known
  • Judas Swing Failed — reversal window expired without confirmation


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KEY INPUTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session Windows
  • Track London Open — toggle London session monitoring
  • London Judas Window (NY time) — session string, default 0200-0300
  • Track New York Open — toggle NY session monitoring
  • NY Judas Window (NY time) — session string, default 0930-1030
  • Session Timezone — timezone used to interpret the windows
  • Reversal Window (minutes) — maximum time after window close in which a
    valid reversal can still be recorded

Detection Logic
  • Min Fake-Move Size (ATR mult) — minimum excursion required to qualify
  • Reversal Confirmation (ATR mult) — distance beyond session open needed
    to confirm the reversal
  • ATR Length — lookback for threshold scaling

Visuals
  • Show Session Start Line, Show Fake-Move Zone, Show Reversal Marker,
    Show Invalidation Zone — individual visual toggles
  • Label Density — Minimal / Balanced / Detailed
  • Font Size — tiny / small / normal / large (applies to labels and panel)
  • Theme — Dark / Light (panel only, chart candles unaffected)

Panel
  • Show Info Panel — master toggle
  • Panel Location — 6 chart positions
  • Always displays: current session, state, true direction, fake distance,
    rolling 20-session statistics (success rate, avg distance, bull/bear
    bias), current TF status, and a footer reminding the optimal timeframe
    range

Alerts — three individual toggles (Forming / Confirmed / Failed)


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Supported timeframes: 1m, 5m, 15m, 30m, 1h. These resolve a session's early
structure cleanly while keeping enough bars inside each Judas window for the
extremum tracker to work with. Recommended default: 15m or 1h.

Not supported: 4h, 1D, 1W. On these timeframes a single bar exceeds the
session window, so nothing is detected. The panel will show a yellow "use
<=1h" hint if you accidentally switch to one of these.

Recommended instruments: FX majors (EURUSD, GBPUSD, USDJPY), index futures
(NQ, ES), liquid crypto (BTC, ETH). The ATR-normalized thresholds keep the
logic portable across these asset classes.

Workflow suggestion:

1. Apply the indicator and let it observe several sessions so the panel
   populates a meaningful sample.
2. Review the 20-session success rate on your specific symbol and timeframe.
   This is not a forecast — it is a descriptive statistic of how the pattern
   has resolved in recent history on that chart.
3. Use the Forming alert as a heads-up, and the Confirmed alert as the main
   event. The true-direction arrow marks the bias of the remaining session,
   not a trade entry or exit.
4. Combine with your own structural context — higher timeframe bias, key
   levels, liquidity pools — before acting on any signal.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LIMITATIONS & TRANSPARENCY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Not a strategy. This is a discretionary analysis tool; it neither places
  orders nor implies any specific trade setup.
• Intraday timeframes only. The logic requires 1h or lower charts to resolve
  the session windows. On 4h, 1D or higher the indicator will not detect
  anything and the panel will show a "use <=1h" notice.
• No forecasting. Displayed statistics describe past behavior on the current
  chart only and do not imply future performance.
• Pattern-dependent. When price opens and trends cleanly in one direction
  without a fake move, the pattern legitimately will not trigger. Low
  signal count on such sessions is expected behavior, not a malfunction.
• Session boundary sensitivity. Results depend on the configured session
  windows and timezone. Outside the major FX and equities session hours the
  ICT framing may not translate cleanly.
• Extreme-volatility sessions. During very large gaps or news spikes the ATR
  thresholds can be dominated by a single bar; users should review the
  defaults in those conditions.
• Symbol coverage. Pip conversion handles forex and JPY pairs explicitly and
  falls back to tick-based sizing for other asset types. Values are intended
  as relative magnitudes, not broker-specific pip quotes.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RISK DISCLOSURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is provided for educational and analytical purposes only. It
does not constitute financial advice, a recommendation, or a solicitation to
buy or sell any instrument. Trading involves substantial risk of loss; past
pattern behavior is not indicative of future results. Users are responsible
for their own trading decisions and for verifying that any signal aligns with
their own methodology and risk management.

The source code is published under the Mozilla Public License 2.0. Feedback
and constructive suggestions are welcome.

## Source Code

````pine
// =============================================================================
// Judas Swing Detector [AGPro Series]
// -----------------------------------------------------------------------------
// Author  : AGProLabs | AGPro Series
// Version : 2.0
// =============================================================================
// Detects the "Judas Swing" — the deceptive first-move pattern during London
// and New York session opens where price initially pushes in one direction to
// trap early participants, then reverses to reveal the true intraday bias.
// Highlights the fake-move zone, flags the reversal bar, and tracks historical
// success metrics across the last 20 sessions.
//
// Designed for intraday timeframes of 1h or lower. The session windows that
// anchor the logic (1-hour Judas window by default) cannot be resolved on 4h
// or higher charts, so the panel will display "use <=1h" on those timeframes.
// =============================================================================
//@version=6
indicator("Judas Swing Detector [AGPro Series]",
     shorttitle = "AG Pro JS",
     overlay    = true,
     max_lines_count  = 300,
     max_labels_count = 300,
     max_boxes_count  = 200)

// =============================================================================
// INPUTS
// =============================================================================
grpSession = "Session Windows"
useLondon       = input.bool(true,  "Track London Open",         group = grpSession, tooltip = "Monitors the London session open for Judas Swing formation. London typically runs 02:00-05:00 New York time.")
londonStart     = input.session("0200-0300", "  London Judas Window (NY time)", group = grpSession, tooltip = "Window during which the initial fake move must form, measured in New York exchange time. Default covers the first hour of London open.")
useNY           = input.bool(true,  "Track New York Open",       group = grpSession, tooltip = "Monitors the New York equities open for Judas Swing formation. NY typically runs 09:30-12:00 NY time.")
nyStart         = input.session("0930-1030", "  NY Judas Window (NY time)",     group = grpSession, tooltip = "Window during which the initial fake move must form after NY open. Default covers the first hour after cash open.")
sessionTZ       = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "Europe/London", "Asia/Tokyo", "UTC"], group = grpSession, tooltip = "Timezone used to interpret the session windows above. Default is New York time, which is the standard reference for ICT methodology.")
reversalWindow  = input.int(180, "Reversal Window (minutes)", minval = 30, maxval = 480, step = 15, group = grpSession, tooltip = "Maximum minutes after Judas window ends during which a valid reversal can still be recorded. Default 180 minutes (3 hours) covers the bulk of the session's true directional move.")

grpDetection = "Detection Logic"
minPipDistATR   = input.float(0.5, "Min Fake-Move Size (ATR mult)", minval = 0.1, maxval = 3.0, step = 0.1, group = grpDetection, tooltip = "Minimum size of the initial fake move, expressed as a multiple of 14-period ATR. Filters out flat openings where no meaningful Judas can form. Lower = more signals, higher = higher quality.")
reversalATR     = input.float(0.75, "Reversal Confirmation (ATR mult)", minval = 0.25, maxval = 3.0, step = 0.05, group = grpDetection, tooltip = "Distance price must travel BEYOND the session open in the opposite direction for the reversal to be confirmed. Higher values produce cleaner but fewer signals.")
atrLen          = input.int(14, "ATR Length", minval = 5, maxval = 50, group = grpDetection, tooltip = "Length of the ATR used to size the fake-move and reversal thresholds dynamically across volatility regimes.")

grpVisual = "Visuals"
showSessionLine = input.bool(false, "Show Session Start Line", group = grpVisual, tooltip = "Optionally draws a vertical dashed line at the start of each monitored session window. Disabled by default to keep price structure visually clean.")
showTrapZone    = input.bool(true,  "Show Fake-Move Zone",     group = grpVisual, tooltip = "Shades the box bounded by the session open and the fake-move extremum, visualizing the trap.")
showReversalMrk = input.bool(true,  "Show Reversal Marker",    group = grpVisual, tooltip = "Shows the confirmed Judas direction. When the invalidation zone is enabled, direction is integrated into the centered zone badge to prevent duplicate labels.")
showInvalZone   = input.bool(true,  "Show Invalidation Zone",  group = grpVisual, tooltip = "Draws a horizontal support/resistance-style band around the fake-move extremum after confirmation. The centered badge identifies both Judas direction and invalidation context. Nearby same-direction zones are consolidated, and only the five most recent distinct zones remain visible.")
invalZoneBars   = input.int(40, "Invalidation Zone Length", minval = 10, maxval = 120, group = grpVisual, tooltip = "Number of bars projected to the right for each confirmed Judas invalidation zone.")
labelDensity    = input.string("Minimal", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual, tooltip = "Controls how many on-chart labels are shown. Minimal (default) = reversal marker only, cleanest look. Balanced = adds session start label. Detailed = adds fake-extremum label. The optional session-start line is controlled separately.")
fontSize        = input.string("normal", "Font Size", options = ["tiny", "small", "normal", "large"], group = grpVisual, tooltip = "Font size used across labels and panel values. Default 'normal' is optimized for most chart scales.")
theme           = input.string("Dark", "Theme", options = ["Dark", "Light"], group = grpVisual, tooltip = "Color theme for the panel. Chart candles are unaffected.")

grpPanel = "Panel"
showPanel     = input.bool(true, "Show Info Panel", group = grpPanel, tooltip = "Toggles the statistics panel in the corner of the chart.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel, tooltip = "Position of the statistics panel on the chart.")

grpAlerts = "Alerts"
alertOnForming   = input.bool(true, "Alert on Judas Forming",   group = grpAlerts, tooltip = "Fires when the fake-move threshold is reached and a reversal is now possible.")
alertOnConfirmed = input.bool(true, "Alert on Judas Confirmed", group = grpAlerts, tooltip = "Fires when price crosses the session open in the opposite direction and passes the reversal threshold.")
alertOnFailed    = input.bool(false,"Alert on Judas Failed",    group = grpAlerts, tooltip = "Fires when the reversal window expires without a valid reversal.")

// =============================================================================
// COLOR PALETTE (AGPro Standard)
// =============================================================================
// Brand
headerBg      = color.rgb(37, 99, 235)      // #2563EB
headerText    = color.rgb(245, 247, 250)    // #F5F7FA
// Panel (dark default)
panelBgDark       = color.rgb(15, 23, 42)      // #0F172A
panelBorderDark   = color.rgb(51, 65, 85)      // #334155
panelLabelColDark = color.rgb(148, 163, 184)   // #94A3B8
panelValueColDark = color.rgb(226, 232, 240)   // #E2E8F0
// Panel (light)
panelBgLight       = color.rgb(248, 250, 252)  // #F8FAFC
panelBorderLight   = color.rgb(203, 213, 225)  // #CBD5E1
panelLabelColLight = color.rgb(71, 85, 105)    // #475569
panelValueColLight = color.rgb(15, 23, 42)     // #0F172A
// Resolved panel colors
panelBg       = theme == "Dark" ? panelBgDark       : panelBgLight
panelBorder   = theme == "Dark" ? panelBorderDark   : panelBorderLight
panelLabelCol = theme == "Dark" ? panelLabelColDark : panelLabelColLight
panelValueCol = theme == "Dark" ? panelValueColDark : panelValueColLight
// States
bullColor     = color.rgb(34, 197, 166)     // #22C5A6
bearColor     = color.rgb(244, 114, 182)    // #F472B6
neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
accentColor   = color.rgb(129, 140, 248)    // #818CF8

// =============================================================================
// HELPERS
// =============================================================================
// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_panelPos(loc) =>
    switch loc
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        =>                 position.top_right

// Convert a price difference to a human-readable distance.
// FX pairs: pips (0.0001, JPY = 0.01). Non-FX: raw points (price delta).
f_dist(diff) =>
    typ   = syminfo.type
    sym   = syminfo.ticker
    isFX  = typ == "forex"
    isJPY = isFX and str.contains(sym, "JPY")
    mult  = isJPY ? 100.0 : isFX ? 10000.0 : 1.0
    math.abs(diff) * mult

// Unit string for the current symbol (used in panel + labels).
f_distUnit() =>
    syminfo.type == "forex" ? "p" : "pt"

// Format distance with adaptive precision:
//   FX: 1 decimal ("12.3p")
//   Non-FX: if value > 100 → 0 decimals, else 1 decimal (e.g. "1087pt" / "12.3pt")
f_distFmt(v) =>
    unit = f_distUnit()
    fmt  = syminfo.type == "forex" ? "#.#" : (v >= 100 ? "#" : "#.#")
    str.tostring(v, fmt) + unit

f_fontPx() =>
    switch fontSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>          size.normal

// Reversal marker with vertical anti-collision against recent markers.
f_add_reversal(array<label> arr, int x, float y, string txt, color bg, color tx, bool up, float gapPrice) =>
    float adjY = y
    int guard = 0
    bool moved = true
    while moved and guard < 14
        moved := false
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                label ex = array.get(arr, i)
                if math.abs(label.get_x(ex) - x) <= 6 and math.abs(label.get_y(ex) - adjY) < gapPrice
                    adjY := up ? adjY - gapPrice : adjY + gapPrice
                    moved := true
                    break
        guard += 1
    label lbl = label.new(x, adjY, txt, xloc = xloc.bar_index, yloc = yloc.price, style = up ? label.style_label_up : label.style_label_down, textcolor = tx, color = bg, size = f_fontPx())
    array.push(arr, lbl)
    while array.size(arr) > 30
        label.delete(array.shift(arr))
    lbl

// =============================================================================
// SESSION DETECTION
// =============================================================================
isLondonWin = useLondon and not na(time(timeframe.period, londonStart, sessionTZ))
isNYWin     = useNY     and not na(time(timeframe.period, nyStart,     sessionTZ))

londonStarted = isLondonWin and not (isLondonWin[1])
nyStarted     = isNYWin     and not (isNYWin[1])
londonEnded   = (isLondonWin[1]) and not isLondonWin
nyEnded       = (isNYWin[1])     and not isNYWin

// =============================================================================
// STATE MACHINE
// =============================================================================
// 0 = Idle, 1 = Active (inside Judas window), 2 = Forming (fake move qualified),
// 3 = Confirmed, 4 = Failed
var int    state            = 0
var int    activeSession    = 0       // 1 = London, 2 = NY
var float  sessionOpenPx    = na
var float  fakeExtremumPx   = na
var int    fakeExtremumBar  = na
var int    fakeDirection    = 0       // 1 = up-fake (bearish Judas), -1 = down-fake (bullish Judas)
var int    sessionStartBar  = na
var int    sessionStartTime = na
var int    reversalDeadline = na
var int    confirmedBar     = na
var float  confirmedPx      = na
var float  maxUpExt         = na      // max high during window
var int    maxUpBar         = na
var float  maxDownExt       = na      // min low during window
var int    maxDownBar       = na

// Last completed lifecycle snapshot keeps the panel informative during standby.
var int    lastSession      = 0       // 1 = London, 2 = New York
var int    lastOutcome      = -1      // 1 = confirmed, 0 = failed, -1 = none yet
var int    lastTrueDir      = 0       // 1 = up, -1 = down, 0 = unconfirmed
var float  lastFakeDist     = na

// =============================================================================
// HISTORY TRACKING (last 20 sessions)
// =============================================================================
var array<int>   histOutcome = array.new<int>(0)    // 1 = confirmed, 0 = failed
var array<float> histPips    = array.new<float>(0)
var array<int>   histDir     = array.new<int>(0)    // 1 = bullish true dir, -1 = bearish true dir
maxHistory = 20

f_pushHistory(outcome, pips, dir) =>
    array.push(histOutcome, outcome)
    array.push(histPips, pips)
    array.push(histDir, dir)
    if array.size(histOutcome) > maxHistory
        array.shift(histOutcome)
        array.shift(histPips)
        array.shift(histDir)

// =============================================================================
// ATR & THRESHOLDS
// =============================================================================
atr          = ta.atr(atrLen)
minFakeDist  = atr * minPipDistATR
reversalDist = atr * reversalATR

// =============================================================================
// VISUAL ARTIFACTS (per-session)
// =============================================================================
var line    sessLine    = na
var box     trapBox     = na
var box     invBox      = na
var label   fakeLbl     = na
var label   sessLbl     = na
var array<label> reversalLabels = array.new<label>()
var array<box>   invalidationBoxes  = array.new<box>()
var array<label> invalidationBadges = array.new<label>()
var array<float> invalidationPrices = array.new<float>()
var array<int>   invalidationDirs   = array.new<int>()
maxVisibleInvalidations = 5

// =============================================================================
// SESSION OPEN: INITIALIZE NEW JUDAS TRACKING
// =============================================================================
// If a new session arrives while the previous one is still Active/Forming,
// gracefully finalize the previous (as Failed) so the new session can start.
newSessionArrives = londonStarted or nyStarted

if newSessionArrives and (state == 1 or state == 2)
    if state == 2
        fakeSizePending = math.abs(fakeExtremumPx - sessionOpenPx)
        f_pushHistory(0, f_dist(fakeSizePending), 0)
        lastSession  := activeSession
        lastOutcome  := 0
        lastTrueDir  := 0
        lastFakeDist := f_dist(fakeSizePending)
    state         := 0
    activeSession := 0

newSession = newSessionArrives and state == 0

if newSession
    state            := 1
    activeSession    := londonStarted ? 1 : 2
    sessionOpenPx    := open
    fakeExtremumPx   := open
    fakeExtremumBar  := bar_index
    fakeDirection    := 0
    sessionStartBar  := bar_index
    sessionStartTime := time
    reversalDeadline := na
    confirmedBar     := na
    confirmedPx      := na
    maxUpExt         := open
    maxUpBar         := bar_index
    maxDownExt       := open
    maxDownBar       := bar_index

    if showSessionLine
        sessLine := line.new(bar_index, low - atr * 2, bar_index, high + atr * 2,
             xloc = xloc.bar_index, extend = extend.none,
             color = color.new(accentColor, 50), style = line.style_dashed, width = 1)

    if labelDensity == "Balanced" or labelDensity == "Detailed"
        sessName = activeSession == 1 ? "LON" : "NY"
        sessLbl := label.new(bar_index, high + atr * 0.8, sessName,
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(accentColor, 25), textcolor = f_text_on(accentColor),
             style = label.style_label_down, size = f_fontPx())

// =============================================================================
// ACTIVE WINDOW: TRACK FAKE EXTREMUM (both directions independently)
// =============================================================================
insideJudasWin = (activeSession == 1 and isLondonWin) or (activeSession == 2 and isNYWin)

if state == 1 and insideJudasWin
    if high > maxUpExt
        maxUpExt := high
        maxUpBar := bar_index
    if low < maxDownExt
        maxDownExt := low
        maxDownBar := bar_index

// =============================================================================
// WINDOW CLOSED: EVALUATE IF FAKE MOVE QUALIFIED
// =============================================================================
windowJustClosed = (activeSession == 1 and londonEnded) or (activeSession == 2 and nyEnded)

if state == 1 and windowJustClosed
    upSize   = maxUpExt   - sessionOpenPx
    downSize = sessionOpenPx - maxDownExt
    // Determine which push was the fake (dominant push)
    if upSize >= downSize
        fakeExtremumPx  := maxUpExt
        fakeExtremumBar := maxUpBar
        fakeDirection   := 1
    else
        fakeExtremumPx  := maxDownExt
        fakeExtremumBar := maxDownBar
        fakeDirection   := -1
    fakeSize = math.abs(fakeExtremumPx - sessionOpenPx)
    if fakeSize >= minFakeDist and fakeDirection != 0
        state            := 2  // Forming — wait for reversal
        reversalDeadline := time + reversalWindow * 60 * 1000
        if showTrapZone
            trapColor = fakeDirection == 1 ? bearColor : bullColor
            trapBox := box.new(sessionStartBar, math.max(sessionOpenPx, fakeExtremumPx),
                 bar_index, math.min(sessionOpenPx, fakeExtremumPx),
                 border_color = color.new(trapColor, 30),
                 bgcolor      = color.new(trapColor, 78),
                 border_width = 1)
        if labelDensity == "Detailed"
            fakeLblY = fakeDirection == 1 ? fakeExtremumPx + atr * 0.4 : fakeExtremumPx - atr * 0.4
            fakeLbl := label.new(fakeExtremumBar, fakeLblY, "Fake " + f_distFmt(f_dist(fakeSize)),
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(fakeDirection == 1 ? bearColor : bullColor, 20),
                 textcolor = f_text_on(fakeDirection == 1 ? bearColor : bullColor),
                 style     = fakeDirection == 1 ? label.style_label_down : label.style_label_up,
                 size      = f_fontPx())
        if alertOnForming
            alert("Judas Swing Forming on " + (activeSession == 1 ? "London" : "NY") + " session - awaiting reversal.", alert.freq_once_per_bar_close)
    else
        // Did not qualify — reset
        state         := 0
        activeSession := 0

// =============================================================================
// FORMING: WAIT FOR REVERSAL
// =============================================================================
if state == 2
    // Reversal = price has crossed session open in opposite direction of fake move,
    // by at least reversalDist from the session open
    reversalTriggered = false
    if fakeDirection == 1  // fake was up → expect down reversal
        if low <= sessionOpenPx - reversalDist
            reversalTriggered := true
    else if fakeDirection == -1  // fake was down → expect up reversal
        if high >= sessionOpenPx + reversalDist
            reversalTriggered := true

    if reversalTriggered
        state         := 3
        confirmedBar  := bar_index
        confirmedPx   := fakeDirection == 1 ? sessionOpenPx - reversalDist : sessionOpenPx + reversalDist

        trueDir  = -fakeDirection  // real direction is opposite of fake
        trueDirCol = trueDir == 1 ? bullColor : bearColor

        // A standalone reversal marker is only needed when the integrated
        // invalidation-zone badge is not visible. This prevents duplicate narration.
        if showReversalMrk and not showInvalZone
            reversalTxt = trueDir == 1 ? "JUDAS UP" : "JUDAS DOWN"
            reversalLblY = trueDir == 1 ? low - atr * 0.5 : high + atr * 0.5
            f_add_reversal(reversalLabels, bar_index, reversalLblY, reversalTxt, color.new(trueDirCol, 15), f_text_on(trueDirCol), trueDir == 1, atr * 0.9)

        if showInvalZone
            invColor = fakeDirection == 1 ? bearColor : bullColor
            // Replace an older same-direction zone when its price band is close
            // enough to represent the same operational reference cluster.
            int invIdx = array.size(invalidationBoxes) - 1
            while invIdx >= 0
                float priorInvPrice = array.get(invalidationPrices, invIdx)
                int priorInvDir = array.get(invalidationDirs, invIdx)
                bool sameInvCluster = priorInvDir == trueDir and math.abs(priorInvPrice - fakeExtremumPx) <= atr * 0.75
                if sameInvCluster
                    box.delete(array.get(invalidationBoxes, invIdx))
                    label.delete(array.get(invalidationBadges, invIdx))
                    array.remove(invalidationBoxes, invIdx)
                    array.remove(invalidationBadges, invIdx)
                    array.remove(invalidationPrices, invIdx)
                    array.remove(invalidationDirs, invIdx)
                invIdx -= 1
            invBox := box.new(bar_index, fakeExtremumPx + atr * 0.25,
                 bar_index + invalZoneBars, fakeExtremumPx - atr * 0.25,
                 xloc         = xloc.bar_index,
                 border_color = color.new(invColor, 30),
                 bgcolor      = color.new(invColor, 78),
                 border_width = 1,
                 border_style = line.style_solid)
            invBadgeText = (trueDir == 1 ? "JUDAS UP" : "JUDAS DOWN") + "\nINVALIDATION"
            invBadge = label.new(bar_index + int(invalZoneBars / 2), fakeExtremumPx, invBadgeText,
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(invColor, 10),
                 textcolor = f_text_on(invColor),
                 style     = label.style_label_center,
                 size      = f_fontPx())
            array.push(invalidationBoxes, invBox)
            array.push(invalidationBadges, invBadge)
            array.push(invalidationPrices, fakeExtremumPx)
            array.push(invalidationDirs, trueDir)
            while array.size(invalidationBoxes) > maxVisibleInvalidations
                box.delete(array.shift(invalidationBoxes))
                label.delete(array.shift(invalidationBadges))
                array.shift(invalidationPrices)
                array.shift(invalidationDirs)

        // Record history
        fakeSize = math.abs(fakeExtremumPx - sessionOpenPx)
        f_pushHistory(1, f_dist(fakeSize), trueDir)
        lastSession  := activeSession
        lastOutcome  := 1
        lastTrueDir  := trueDir
        lastFakeDist := f_dist(fakeSize)

        if alertOnConfirmed
            dirTxt = trueDir == 1 ? "BULLISH" : "BEARISH"
            alert("Judas Swing CONFIRMED on " + (activeSession == 1 ? "London" : "NY") + " - true direction: " + dirTxt, alert.freq_once_per_bar_close)

    else if time >= reversalDeadline
        // Deadline passed — failed
        state := 4
        fakeSize = math.abs(fakeExtremumPx - sessionOpenPx)
        f_pushHistory(0, f_dist(fakeSize), 0)
        lastSession  := activeSession
        lastOutcome  := 0
        lastTrueDir  := 0
        lastFakeDist := f_dist(fakeSize)
        if alertOnFailed
            alert("Judas Swing FAILED on " + (activeSession == 1 ? "London" : "NY") + " - no reversal before deadline.", alert.freq_once_per_bar_close)

// =============================================================================
// RESET AT DAY CHANGE OR ONCE CONFIRMED/FAILED STATE PERSISTS PAST DEADLINE
// =============================================================================
dayChange = ta.change(time("D")) != 0
if (state == 3 or state == 4) and time >= reversalDeadline + 3600 * 1000
    state         := 0
    activeSession := 0

if dayChange and state != 0 and state != 2
    // Only hard-reset at day change if not mid-formation
    if state != 1
        state         := 0
        activeSession := 0

// =============================================================================
// INFO PANEL
// =============================================================================
var table panel = na
if barstate.islast and showPanel
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(panelLocation), 2, 11,
         bgcolor      = panelBg,
         border_color = panelBorder,
         border_width = 1,
         frame_color  = panelBorder,
         frame_width  = 1)

    // Row 0: Title (merged)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Judas Swing Detector",
         bgcolor = headerBg, text_color = f_text_on(headerBg), text_size = f_fontPx(), text_halign = text.align_center)

    // Timeframe helper — detect if current TF is suitable for session tracking
    tfOk = timeframe.isintraday and timeframe.in_seconds() <= 3600

    // Stats
    total  = array.size(histOutcome)
    wins   = 0
    sumP   = 0.0
    bulls  = 0
    bears  = 0
    if total > 0
        for i = 0 to total - 1
            wins  += array.get(histOutcome, i)
            sumP  += array.get(histPips, i)
            d      = array.get(histDir, i)
            bulls += d ==  1 ? 1 : 0
            bears += d == -1 ? 1 : 0
    successRate = total > 0 ? wins * 100.0 / total : 0.0
    avgPip      = total > 0 ? sumP / total         : 0.0

    // Current session status
    statusTxt   = state == 0 ? "Standby"      : state == 1 ? "Active"         :
                  state == 2 ? "Forming"      : state == 3 ? "Confirmed"      :
                  state == 4 ? "Failed"       : "-"
    statusCol   = state == 0 ? neutralColor   : state == 1 ? accentColor      :
                  state == 2 ? neutralColor   : state == 3 ? bullColor        :
                  state == 4 ? bearColor      : panelValueCol
    isStandby   = state == 0
    trackingTxt = useLondon and useNY ? "London + New York" : useLondon ? "London" : useNY ? "New York" : "Disabled"
    sessTxt     = isStandby ? trackingTxt : activeSession == 1 ? "London" : activeSession == 2 ? "New York" : "Awaiting window"

    // Current Judas data
    curDist      = state >= 2 and not na(fakeExtremumPx) and not na(sessionOpenPx) ? f_dist(fakeExtremumPx - sessionOpenPx) : isStandby ? lastFakeDist : na
    lastSessTxt  = lastSession == 1 ? "London" : lastSession == 2 ? "New York" : ""
    lastReadTxt  = lastOutcome == 1 ? (lastTrueDir == 1 ? "Up" : "Down") + " / " + lastSessTxt : lastOutcome == 0 ? "Failed / " + lastSessTxt : "Awaiting first result"
    liveReadTxt  = state >= 2 ? (fakeDirection == 1 ? "Down (faked up)" : "Up (faked down)") : state == 1 ? "Building range" : lastReadTxt
    curDirTxt    = isStandby ? lastReadTxt : liveReadTxt
    curDirCol    = isStandby ? (lastOutcome == 1 ? (lastTrueDir == 1 ? bullColor : bearColor) : lastOutcome == 0 ? neutralColor : panelValueCol) : state >= 2 ? (fakeDirection == 1 ? bearColor : bullColor) : accentColor
    sessionLabel = isStandby ? "Tracking" : "Session"
    dirLabel     = isStandby ? "Last Result" : state == 1 ? "Read" : "True Dir"
    distLabel    = isStandby ? "Last Fake Dist" : "Fake Dist"
    distTxt      = state == 1 ? "Measuring" : na(curDist) ? "No sample yet" : f_distFmt(curDist)

    // Row 1: Session
    table.cell(panel, 0, 1, sessionLabel, bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 1, sessTxt,     bgcolor = panelBg, text_color = panelValueCol, text_size = f_fontPx(), text_halign = text.align_right)
    // Row 2: State
    table.cell(panel, 0, 2, "State",     bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 2, statusTxt,   bgcolor = panelBg, text_color = statusCol,     text_size = f_fontPx(), text_halign = text.align_right)
    // Row 3: Current dir
    table.cell(panel, 0, 3, dirLabel,     bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 3, curDirTxt,   bgcolor = panelBg, text_color = curDirCol,     text_size = f_fontPx(), text_halign = text.align_right)
    // Row 4: Current fake distance
    table.cell(panel, 0, 4, distLabel,    bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 4, distTxt,
         bgcolor = panelBg, text_color = panelValueCol, text_size = f_fontPx(), text_halign = text.align_right)
    // Row 5: Divider-style label
    table.cell(panel, 0, 5, "Last " + str.tostring(total) + " Sessions", bgcolor = panelBg, text_color = accentColor, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 5, "",          bgcolor = panelBg, text_color = panelValueCol, text_size = f_fontPx(), text_halign = text.align_right)
    // Row 6: Success rate
    table.cell(panel, 0, 6, "Success",   bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    srCol = successRate >= 65 ? bullColor : successRate >= 45 ? neutralColor : bearColor
    table.cell(panel, 1, 6, total > 0 ? str.tostring(successRate, "#.#") + "%" : "-",
         bgcolor = panelBg, text_color = srCol, text_size = f_fontPx(), text_halign = text.align_right)
    // Row 7: Avg distance
    table.cell(panel, 0, 7, "Avg Dist",  bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    table.cell(panel, 1, 7, total > 0 ? f_distFmt(avgPip) : "-",
         bgcolor = panelBg, text_color = panelValueCol, text_size = f_fontPx(), text_halign = text.align_right)
    // Row 8: Bias
    table.cell(panel, 0, 8, "Bias",      bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    biasTxt = total > 0 ? str.tostring(bulls) + "U / " + str.tostring(bears) + "D" : "-"
    biasCol = bulls > bears ? bullColor : bears > bulls ? bearColor : neutralColor
    table.cell(panel, 1, 8, biasTxt,     bgcolor = panelBg, text_color = biasCol,       text_size = f_fontPx(), text_halign = text.align_right)
    // Row 9: Timeframe status
    table.cell(panel, 0, 9, "TF",        bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_left)
    tfTxt = tfOk ? timeframe.period + " OK" : "use <=1h"
    tfCol = tfOk ? bullColor : neutralColor
    table.cell(panel, 1, 9, tfTxt,       bgcolor = panelBg, text_color = tfCol,          text_size = f_fontPx(), text_halign = text.align_right)
    // Row 10: Footer — always-visible usage hint (merged)
    table.merge_cells(panel, 0, 10, 1, 10)
    table.cell(panel, 0, 10, "Optimal TF: 1m - 1h",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = f_fontPx(), text_halign = text.align_center)

// =============================================================================
// SESSION LINE EXTENSION (keep the dashed line spanning the session)
// =============================================================================
if state >= 1 and not na(sessLine) and showSessionLine
    line.set_y1(sessLine, low  - atr * 2)
    line.set_y2(sessLine, high + atr * 2)

// =============================================================================
// END OF SCRIPT
// =============================================================================
````
