# VWAP Deviation Score [DYNA]

- url: https://www.tradingview.com/script/Vw8O2dSw-VWAP-Deviation-Score-DYNA/
- type: indicator
- pine_id: PUB;c01a7b0854fc4aac9e10780898e974e8
- version: 1.0

## Description

VWAP Deviation Score expresses how stretched price is from the session's VWAP as a single z-score number — the count of intraday standard deviations between the current close and the volume-weighted mean. Zero means price is sitting on VWAP. ±1 is one standard deviation away (~68% statistical envelope). ±2 is the alertable extreme (~95% envelope). Beyond ±2 is a statistically uncommon reading under a normal distribution.

The indicator lives in its own pane below price. The smoothed z-score line is colored by zone — green inside ±1σ, amber between ±1σ and ±2σ, red beyond ±2σ — so the current state is readable at a glance. Three confirmed-bar alerts cover the actionable transitions: extreme bullish stretch, extreme bearish stretch, and the return back to VWAP after an extreme reading.

Unlike rolling-window z-score indicators, this one anchors VWAP and the standard deviation to the session open. The dispersion measurement therefore reflects only today's price action, not yesterday's noise — every session starts fresh.


[b]Key Features[/b]

[list]
[*] [b]Session-Anchored Z-Score[/b] -- True intraday measurement of stretch from VWAP. Resets every session, no carryover from yesterday.
[*] [b]Three-Zone Coloring[/b] -- Normal (green), caution (amber), extreme (red). The line color tells you the regime before you read the number.
[*] [b]Configurable Thresholds[/b] -- Independent caution and extreme threshold inputs (defaults ±1σ and ±2σ). Adjust per instrument volatility.
[*] [b]EMA Smoothing[/b] -- Optional smoothing of the raw z-score (default length 3) to suppress threshold-flicker on noisy timeframes.
[*] [b]Three Alerts[/b] -- Extreme bullish deviation, extreme bearish deviation, return to VWAP after an extreme. All confirmed on bar close.
[*] [b]Early-Session Guard[/b] -- Configurable minimum-bars filter (default 5) prevents noise alerts when intraday standard deviation has not yet stabilised.
[*] [b]Compact Dashboard[/b] -- Top-right table shows current z-score, zone label, and bar count since session open.
[*] [b]Volume-Agnostic[/b] -- Works on instruments with or without published volume. Cash indices with no published volume fall back to a flat weight automatically.
[*] [b]No Repainting[/b] -- Signal conditions gated on confirmed bars; once an alert has fired, the historical signal does not move.
[/list]


[b]How It Works[/b]

At the start of each session the indicator begins accumulating volume-weighted sums of the source price and the source price squared. From these it derives the session VWAP (Σ src·vol / Σ vol) and the volume-weighted variance (Σ src²·vol / Σ vol − VWAP²). The standard deviation is the square root of the variance.

The raw z-score is then (close − VWAP) / σ — the number of standard deviations between the current close and the session mean. A short EMA is applied to the raw value to produce the smoothed signal line shown on the chart.

The score is classified into three zones: normal (|z| < caution), caution (caution ≤ |z| < extreme), and extreme (|z| ≥ extreme). The line colour, the pane background, and the dashboard all reflect the current zone.

Signals fire only on confirmed (closed) bars. "Extreme bullish deviation" fires the bar the smoothed z-score crosses above the extreme threshold; "extreme bearish deviation" mirrors it on the negative side. "Return to VWAP" fires when the score crosses zero after having been beyond the extreme threshold earlier in the same session — paired with the extreme alerts, it marks the completion of a mean-reversion round trip.

[image]https://www.tradingview.com/x/pbMDqjsl/[/image]
[i]Smoothed z-score (zone-coloured line) plotted in a separate pane with the VWAP at zero, ±1σ caution dotted lines, and ±2σ extreme dashed lines. Triangle markers fire on extreme deviations; the diamond marks the return back to VWAP.[/i]


[b]Settings[/b]

[b]Session Time[/b] (default: 0915-1530) and [b]Timezone[/b] (default: Asia/Kolkata) define the session window that anchors the VWAP. [b]VWAP Source[/b] (default: hlc3) sets the price used in the weighted average; hlc3 matches TradingView's built-in VWAP.

[b]Extreme Threshold[/b] (default: 2.0σ) is the alertable line. [b]Caution Threshold[/b] (default: 1.0σ) opens the amber zone but does not fire alerts -- it is purely a visual aid for the colour band. [b]Signal Smoothing[/b] (default: 3) is the EMA length applied to the raw z-score. [b]Min Bars Before Signals[/b] (default: 5) suppresses signals while the early-session standard deviation is still stabilising.

The [b]Visual[/b] toggles control the optional raw z-score line, the zone fills, the extreme background tint, and the dashboard table. The three [b]Alert[/b] toggles enable or disable each alert independently.


[b]Alerts[/b]

[list]
[*] [b]Extreme Bullish Deviation[/b] -- Fires on the bar the smoothed z-score crosses above the extreme threshold. Price is in the top tail of the intraday distribution. [i]"VWAP Deviation Score [DYNA]: Z-score crossed above the extreme upper threshold -- price stretched well above session VWAP."[/i]
[*] [b]Extreme Bearish Deviation[/b] -- Fires on the bar the smoothed z-score crosses below the negative extreme threshold. Mirror of the bullish case. [i]"VWAP Deviation Score [DYNA]: Z-score crossed below the extreme lower threshold -- price stretched well below session VWAP."[/i]
[*] [b]Return to VWAP[/b] -- Fires when the smoothed z-score crosses zero after having been beyond the extreme threshold earlier in the same session. Marks the completion of a mean-reversion round trip. [i]"VWAP Deviation Score [DYNA]: Z-score returned to zero after an extreme deviation -- mean-reversion to session VWAP confirmed."[/i]
[/list]

To set up alerts: click TradingView's Alerts button, choose "VWAP Deviation Score [DYNA]" from the condition dropdown, pick one of the three alert variants, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Read the line colour first, the number second. The zone tells you the regime; the exact value is for fine-tuning entries.
[*] Extreme readings mark the tails of the intraday distribution -- a zone many traders watch for potential mean-reversion. The "Return to VWAP" alert can mark when price has traded back to the session mean.
[*] Tune the extreme threshold per instrument. 2σ is a good default; raise to 2.5-3σ on highly volatile small-caps or crypto, lower to 1.5σ on slow-moving instruments.
[*] Combine with a higher-timeframe trend filter to choose which side of an extreme reading to take. With-trend extreme readings often mark continuation pullbacks; counter-trend extremes mark exhaustion.
[*] Give the indicator at least 5-7 bars after session open before reading it. The minimum-bars guard suppresses alerts but the visible value can still be unstable while standard deviation is stabilising.
[*] On cash-index charts with no published volume, treat this as a session-anchored standardised price oscillator rather than a true volume-weighted z-score. The signal logic is unchanged; only the per-bar weighting falls back to flat.
[/list]


[b]Part of the DYNA Ecosystem[/b]

VWAP Deviation Score is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// VWAP Deviation Score [DYNA]
// Quantifies how far price has stretched from session VWAP in standard-deviation units (z-score).
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("VWAP Deviation Score [DYNA]", shorttitle = "VWAPZ [DYNA]", overlay = false,
         max_labels_count = 500, max_lines_count = 500, precision = 2)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color ZONE_NORMAL   = #26a69a   // green — inside ±caution
color ZONE_CAUTION  = #ffb74d   // amber — between ±caution and ±extreme
color ZONE_EXTREME  = #ef5350   // red   — beyond ±extreme
color VWAP_LINE     = #2962ff   // blue  — zero (VWAP) reference

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_SIG   = "Signal Detection"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
string i_session    = input.session("0915-1530", "Session Time", group = GRP_CORE, tooltip = "Session window that anchors the VWAP. Z-score and accumulators reset at the start of every new session.")
string i_timezone   = input.string("Asia/Kolkata", "Timezone", options = ["Asia/Kolkata", "America/New_York", "America/Chicago", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore", "Australia/Sydney"], group = GRP_CORE, tooltip = "Timezone used to interpret the session window. Match the exchange's local time to avoid DST drift.")
i_source            = input.source(hlc3, "VWAP Source", group = GRP_CORE, tooltip = "Price source used in the VWAP calculation. Default hlc3 matches TradingView's built-in VWAP.")

// --- Signal Detection ---
float i_extreme     = input.float(2.0, "Extreme Threshold (σ)", minval = 0.5, maxval = 6.0, step = 0.1, group = GRP_SIG, tooltip = "Z-score level that defines an extreme (alertable) deviation. ±2σ ≈ statistical 95% envelope under a normal distribution.")
float i_caution     = input.float(1.0, "Caution Threshold (σ)", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_SIG, tooltip = "Z-score level that defines the caution zone. Must be smaller than the extreme threshold. ±1σ ≈ ~68% envelope.")
int   i_smoothing   = input.int(3, "Signal Smoothing", minval = 1, maxval = 50, group = GRP_SIG, tooltip = "EMA length applied to the raw z-score. Higher = smoother signal, fewer false flips at the threshold.")
int   i_minBars     = input.int(5, "Min Bars Before Signals", minval = 2, maxval = 50, group = GRP_SIG, tooltip = "Minimum number of in-session bars required before signals can fire. Early-session standard deviation is unstable — this guard prevents noise alerts.")

// --- Visual ---
bool i_showRaw      = input.bool(false, "Show Raw Z-Score (faded)", group = GRP_VIS, tooltip = "Display the unsmoothed z-score as a faded reference line behind the smoothed signal.")
bool i_fillZones    = input.bool(true,  "Shade Zones",              group = GRP_VIS, tooltip = "Fill the normal (green) and caution (amber) bands between the threshold lines.")
bool i_showBgExtreme = input.bool(true, "Background on Extreme",    group = GRP_VIS, tooltip = "Tint the pane background red while the smoothed z-score is beyond the extreme threshold.")
bool i_showDashboard = input.bool(true, "Show Dashboard",           group = GRP_VIS, tooltip = "Display a small table with the current z-score, zone, and session bar count.")

// --- Alerts ---
bool i_alertExtremeBull = input.bool(true, "Alert: Extreme Bullish Deviation", group = GRP_ALERT, tooltip = "Fire when the smoothed z-score crosses above the extreme threshold.")
bool i_alertExtremeBear = input.bool(true, "Alert: Extreme Bearish Deviation", group = GRP_ALERT, tooltip = "Fire when the smoothed z-score crosses below the negative extreme threshold.")
bool i_alertReturn      = input.bool(true, "Alert: Return to VWAP",            group = GRP_ALERT, tooltip = "Fire when the smoothed z-score crosses zero after having been beyond the extreme threshold.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Effective thresholds (caution must stay below extreme) ---
float caution = math.min(i_caution, i_extreme - 0.1)
float extreme = i_extreme

// --- Session anchoring ---
// `time("D", session, tz)` returns the session's daily start timestamp on every
// in-session bar and `na` outside, regardless of whether off-hours bars are
// hidden — robust to chart settings.
int  sessionDay = time("D", i_session, i_timezone)
bool inSession  = not na(sessionDay)
bool newSession = inSession and (na(sessionDay[1]) or sessionDay != sessionDay[1])

// --- Per-session cumulative accumulators ---
var float sumPV     = 0.0
var float sumV      = 0.0
var float sumPPV    = 0.0
var int   sessBars  = 0

if newSession
    sumPV    := 0.0
    sumV     := 0.0
    sumPPV   := 0.0
    sessBars := 0

if inSession
    float v = math.max(nz(volume, 0.0), 1.0)
    sumPV    := sumPV  + i_source * v
    sumV     := sumV   + v
    sumPPV   := sumPPV + i_source * i_source * v
    sessBars := sessBars + 1

// --- VWAP, variance, standard deviation ---
float vwap     = sumV > 0 ? sumPV / sumV : na
float variance = sumV > 0 and not na(vwap) ? math.max(sumPPV / sumV - vwap * vwap, 0.0) : na
float stdev    = na(variance) ? na : math.sqrt(variance)

// --- Z-score (raw) and session-resetting EMA smoothing ---
// Guard: stdev must be > 0 and we must have enough in-session bars accumulated.
// We roll our own EMA so it can reset at the session boundary — built-in ta.ema
// would carry yesterday's value into today's first bars, which is meaningless
// for a session-anchored z-score.
bool  zValid = inSession and sessBars >= i_minBars and not na(stdev) and stdev > 0
float zRaw   = zValid ? (close - vwap) / stdev : na

var float zSmoothed = na
if newSession
    zSmoothed := na
if not na(zRaw)
    if na(zSmoothed)
        zSmoothed := zRaw
    else
        float alpha = 2.0 / (i_smoothing + 1)
        zSmoothed := alpha * zRaw + (1.0 - alpha) * zSmoothed

// --- Zone classification (current bar) ---
float absZ      = na(zSmoothed) ? 0.0 : math.abs(zSmoothed)
bool  inCaution = not na(zSmoothed) and absZ >= caution and absZ < extreme
bool  inExtreme = not na(zSmoothed) and absZ >= extreme

// --- No-repaint signals (confirmed bar only, threshold crosses) ---
// ta.crossover/crossunder use [1] internally; gating with barstate.isconfirmed
// ensures the signal only emits on the closed bar, not intra-bar.
bool confirmed   = barstate.isconfirmed
bool extremeBull = confirmed and ta.crossover(zSmoothed,  extreme)
bool extremeBear = confirmed and ta.crossunder(zSmoothed, -extreme)

// "Return to VWAP" — track whether we've been beyond ±extreme since the last
// zero-cross, then fire on the bar the smoothed z-score crosses zero.
var bool wasExtended = false

if newSession
    wasExtended := false

// Guard against the session-boundary bar where zSmoothed[1] would still
// reference yesterday's final value — we only want to track extensions that
// happened *within* the current session.
if confirmed and not newSession and not na(zSmoothed[1]) and math.abs(zSmoothed[1]) >= extreme
    wasExtended := true

bool zeroCross    = confirmed and not na(zSmoothed) and not na(zSmoothed[1]) and ((zSmoothed > 0 and zSmoothed[1] <= 0) or (zSmoothed < 0 and zSmoothed[1] >= 0))
bool returnToVwap = zeroCross and wasExtended

if returnToVwap
    wasExtended := false

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Per-bar line color by zone ---
color zoneColor = inExtreme ? ZONE_EXTREME : inCaution ? ZONE_CAUTION : ZONE_NORMAL

// --- Threshold reference lines (hlines so they appear in the legend cleanly) ---
hExtUp = hline( extreme, "+ Extreme", color = color.new(BEAR_COLOR, 40),    linestyle = hline.style_dashed)
hCauUp = hline( caution, "+ Caution", color = color.new(WARNING_COLOR, 60), linestyle = hline.style_dotted)
hZero  = hline( 0.0,     "VWAP (0)",  color = color.new(VWAP_LINE, 20),     linestyle = hline.style_solid, linewidth = 1)
hCauDn = hline(-caution, "- Caution", color = color.new(WARNING_COLOR, 60), linestyle = hline.style_dotted)
hExtDn = hline(-extreme, "- Extreme", color = color.new(BULL_COLOR, 40),    linestyle = hline.style_dashed)

// --- Zone fills (between adjacent hlines) ---
fill(hCauUp, hCauDn, color = i_fillZones ? color.new(ZONE_NORMAL, 92)  : na, title = "Normal Zone")
fill(hExtUp, hCauUp, color = i_fillZones ? color.new(ZONE_CAUTION, 88) : na, title = "Upper Caution")
fill(hCauDn, hExtDn, color = i_fillZones ? color.new(ZONE_CAUTION, 88) : na, title = "Lower Caution")

// --- Plots ---
plot(i_showRaw ? zRaw : na, "Raw Z-Score", color = color.new(NEUTRAL_COLOR, 60), linewidth = 1)
plot(zSmoothed,             "Z-Score",     color = zoneColor, linewidth = 2)

// --- Background tint when in extreme zone ---
bgcolor(i_showBgExtreme and inExtreme and not na(zSmoothed) ? color.new(zSmoothed > 0 ? BEAR_COLOR : BULL_COLOR, 92) : na, title = "Extreme Background")

// --- Signal markers in the pane ---
// plotshape with location.absolute treats the series as a Y-coordinate, so we
// must feed `na` on non-signal bars — a boolean `false` coerces to 0 and would
// draw a shape at y=0 on every bar.
plotshape(extremeBull  ?  extreme : na, title = "Extreme Bull", style = shape.triangledown, location = location.absolute, color = BEAR_COLOR, size = size.tiny, text = "EXT", textcolor = BEAR_COLOR)
plotshape(extremeBear  ? -extreme : na, title = "Extreme Bear", style = shape.triangleup,   location = location.absolute, color = BULL_COLOR, size = size.tiny, text = "EXT", textcolor = BULL_COLOR)
plotshape(returnToVwap ?      0.0 : na, title = "Return VWAP",  style = shape.diamond,      location = location.absolute, color = VWAP_LINE,  size = size.tiny)

// --- Dashboard ---
var table dashboard = table.new(position.top_right, 2, 4,
     bgcolor = color.new(#131722, 10), border_width = 1,
     border_color = color.new(NEUTRAL_COLOR, 60))

if i_showDashboard and barstate.islast
    string zText = na(zSmoothed) ? "—" : str.tostring(zSmoothed, "0.00") + "σ"
    string zone  = inExtreme ? (zSmoothed > 0 ? "EXTREME +" : "EXTREME −") : inCaution ? (zSmoothed > 0 ? "CAUTION +" : "CAUTION −") : "NORMAL"
    color  zCol  = inExtreme ? ZONE_EXTREME : inCaution ? ZONE_CAUTION : ZONE_NORMAL

    table.cell(dashboard, 0, 0, "VWAPZ",   text_color = color.white,   text_size = size.small)
    table.cell(dashboard, 1, 0, "[DYNA]",  text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 0, 1, "Score",   text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 1, zText,     text_color = zCol,          text_size = size.normal)
    table.cell(dashboard, 0, 2, "Zone",    text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 2, zone,      text_color = zCol,          text_size = size.small, bgcolor = color.new(zCol, 80))
    table.cell(dashboard, 0, 3, "Bar #",   text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 3, str.tostring(sessBars), text_color = color.white, text_size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(extremeBull  and i_alertExtremeBull, title = "Extreme Bullish Deviation",
    message = "VWAP Deviation Score [DYNA]: Z-score crossed above the extreme upper threshold — price stretched well above session VWAP.")
alertcondition(extremeBear  and i_alertExtremeBear, title = "Extreme Bearish Deviation",
    message = "VWAP Deviation Score [DYNA]: Z-score crossed below the extreme lower threshold — price stretched well below session VWAP.")
alertcondition(returnToVwap and i_alertReturn,      title = "Return to VWAP",
    message = "VWAP Deviation Score [DYNA]: Z-score returned to zero after an extreme deviation — mean-reversion to session VWAP confirmed.")
````
