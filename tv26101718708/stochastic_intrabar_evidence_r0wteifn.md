# Stochastic Intrabar Evidence

- url: https://www.tradingview.com/script/r0WteiFn-Stochastic-Intrabar-Evidence/
- type: indicator
- pine_id: PUB;5458264fa3924c8faf2c50570eb729e8
- version: 1.0

## Description

Stochastic Intrabar Evidence examines a question that a close-only stochastic chart cannot answer on its own: if the oscillator opened and closed on the same side of its reference, did it necessarily visit the opposite side inside that candle?

The indicator separates what a completed OHLC candle requires, leaves unresolved, or excludes. It combines familiar K/D lines with mathematically bounded intrabar evidence, excursion depth and an auditable event selection. It uses chart OHLC only, without requesting lower-timeframe data or inventing an observed tick path.

Its practical purpose is to distinguish an excursion established by the OHLC model from one that is merely possible. This is a completed-bar diagnostic for reviewing oscillator behavior, not an early signal, trade recommendation or performance forecast.

1. What to read first

The defaults are a 14-bar stochastic range, 3-period K smoothing, 3-period D smoothing and SMA. Cyan is K; gold is D. All evidence uses completed candles.

Evidence subject defaults to K versus D. Alternatives compare K with the upper or lower fixed reference, initially 80 and 20. The strict-side margin defaults to 0.05 oscillator points, not 0.05 percent and not a price tick. For K-D, above means greater than +0.05 and below means less than -0.05, subject to a separate numerical guard.

The opening oscillator position is calculated using this candle's Open and its opening running range. It is not the previous candle's closing oscillator value.

The primary verdict applies when the opening and closing positions are on the same strict side:

REQUIRED: every price-observation sequence compatible with the model visits the opposite side beyond the margin. This is a mathematical statement under the stated assumptions, not certainty about a trade.

UNRESOLVED: both a visit and a no-visit sequence fit the same OHLC. The indicator cannot establish which occurred. This is neither a known historical excursion nor a probability estimate.

EXCLUDED: no compatible sequence makes that margin-exceeding opposite-side visit. Smaller movements inside the margin are not excluded; future continuation is not implied.

BOUNDARY: an extremal bound is too close to a classification threshold for a definitive verdict. The separate numerical guard is 0.0000001 oscillator point.

NO SAME-SIDE PAIR: the opening and closing positions differ in side, or an endpoint is near the reference. This is not equivalent to EXCLUDED.

UNAVAILABLE: the data, retained range or calculation warm-up is insufficient.

2. Marker legend and excursion depth

Mint circle: REQUIRED opposite-side visit.
Amber diamond: UNRESOLVED opposite-side visit.
Upper lane: an upper-side visit while both endpoints are below the reference.
Lower lane: a lower-side visit while both endpoints are above the reference.

These are oscillator-side directions, not buy/sell signals or forecasts of price direction. Markers become available only after the candle closes.

The default Side lanes place marks above 100 or below 0 for separation from K/D. These coordinates are layout positions, not out-of-range stochastic readings. Lane gap is adjustable. Optional UP/DN text adds a question mark to unresolved marks; it is off by default to reduce clutter.

Evidence bounds is an alternative placement: circles use the required K extremum and diamonds the outer possible K extremum. These anchors remain bounds, not measured tick extrema.

Depth R / P reports required and possible maximum penetration beyond the opposite-side margin, in nonnegative oscillator points. An unresolved visit has zero required depth. Depth distinguishes a marginal excursion from a deeper one without treating either as a better trade.

The detailed Extreme R / P row uses signed extrema relative to K-D or K-level. Lower-side visits use minima, so the possible value can be more negative than the required value. Upper-side visits use maxima. Classification uses unrounded numbers; a positive depth smaller than the display unit is shown as less than that unit instead of zero.

3. Practical workflow

Start with standard candles and the default settings. Check the inspector's evidence-bar time before interpreting its verdict.

Use REQUIRED to identify a within-candle excursion that the two endpoints omit. Treat UNRESOLVED as a limit of the available data, not as a weaker confirmed event. Use EXCLUDED only to rule out the particular margin-exceeding visit under examination.

Then inspect Depth R / P and, when needed, the extrema bounds. Use All evidence (audit) when reviewing every qualifying candle instead of only changes in the event stream. Any trading application needs separate validation with an explicit rule, execution assumptions and costs.

4. Event selection, hidden marks and notifications

An eligible evidence event is a REQUIRED or UNRESOLVED same-side visit. The default Event repetition setting, Class or direction changes, reduces consecutive events with the same class and direction. A nonqualifying candle resets the comparison, so the same class may be reported again afterward.

Important: a change in depth alone does not create a new default event. A much deeper visit can therefore produce no new marker or event notification if its class and direction repeat. Select Every qualifying bar when that reduction is inappropriate for your research.

Marker mode offers three choices:
- Event stream: follow the selected repetition rule.
- All evidence (audit): bypass repetition and spacing; select every eligible evidence event.
- Spaced event stream: apply the repetition rule, then minimum marker spacing.

The default visible marker window is 160 chart bars. Counts show selected/all eligible events and the hidden total in that same window. A forming candle occupies a window slot but has no event marker. Older marks are display-clipped, not removed from historical calculations.

Counts describe coded selection, not actual alert delivery. Manually hiding individual plots in the Style tab is not detectable by Pine and does not change these counts or eligibility rules.

5. Inspector and historical inspection

Quick read is the default six-row inspector at Normal text size. It summarizes K/D, the opposite-side verdict, depth, evidence-bar times, marker counts and notification scope. Other pages are Decision, Extrema and endpoints, Event audit and Reading guide.

The inspector describes the latest completed candle, not the historical candle under the cursor. While a new candle is forming, it refers to the previous candle and indicates one chart bar of distance. This is not elapsed wall-clock time. For historical evidence, use the Data Window.

The time zone is explicit and defaults to UTC. Pine cannot read the chart's display time zone; select the desired evidence zone separately. Quick read compresses redundant date/time fields without dropping necessary sub-minute precision. Detailed pages, tooltips and descriptive alerts retain full timestamps. These are candle boundaries, not excursion times.

Sixteen evidence series supplement K/D in the Data Window: opening K; four K-extrema bounds; uncertainty width; above/below classes; same-side visit class; visit direction; two signed opposite extrema; two penetration depths; selected-mark flag before history clipping; and event-notification eligibility.

Class codes are 0 excluded, 1 unresolved, 2 required and 3 numerical boundary. Undefined data or absent context stays undefined where applicable. The secondary above/below detail uses FORCED/POSSIBLE terminology; an endpoint alone may imply those states, so they are not the main event diagnostic.

6. Alert setup

Adding the indicator does not create a running alert.

For detailed messages, leave Enable descriptive alert() messages enabled and create one TradingView alert using Any alert() function call. The script calls alerts only at bar close. Messages identify the symbol, timeframe, evidence-bar times, time zone, relation, margin, direction, class, signed extrema and depth. Coincident optional state information is combined into one message.

Event notification scope defaults to Match marker selection. This follows the same selection gate as the marks, including audit/spaced mode and Show directional event marks. Turning marks off suppresses matching event notices. On a realtime close, the newest event is within the visible marker window.

All event-stream events ignores marker visibility and spacing but still follows Event repetition. It does not include audit-only extra marks unless those also qualify for the selected event stream.

Optional endpoint-state notices are a separate channel and default to Off. Class change only reports changes in the above/below classification pair; Every closed bar sends deliberately repetitive state reports. These are not matching excursion markers.

Two alternative alert conditions are provided:
- Selected required opposite-side visit
- Selected unresolved opposite-side visit

They follow the same event scope but provide less detail than the dynamic messages. Use one route unless duplicate notifications are intended. Existing alerts retain their creation-time script/settings snapshot; recreate them after changing the intended configuration. Historical eligibility is not proof that a message was sent or received.

7. How the bounds are calculated

The retained range uses the preceding N-1 chart bars. The current bar begins at Open; its running high and low then expand with observations.

A compatible sequence begins at Open, ends at Close, stays within the candle's final Low and High, and reaches both extremes. Repeated visits and jumps between observations are allowed. The calculation assumes no specific high/low order and assigns no probabilities to possible paths.

Let [a,b] be the retained low/high. Let [L,H] be that range expanded by the current candle's Low/High, and [Lo,Ho] the retained range expanded only by Open. Define F(p,h,l) = 100 * (p-l) / (h-l).

RawOpen = F(Open,Ho,Lo)
RawClose = F(Close,H,L)
Possible minimum floor = F(Low,H,L)
Required minimum ceiling = min(RawOpen, RawClose, F(Low,Ho,L))
Required maximum floor = max(RawOpen, RawClose, F(High,H,Lo))
Possible maximum ceiling = F(High,H,L)

The unknown intrabar minimum lies between its floor and ceiling; the maximum lies between its floor and ceiling. Each endpoint is attainable separately within this model. The four endpoints do not identify one actual path. High-first and low-first sequences demonstrate attainable bounds; neither is assumed to be the observed order.

Completed smoothing history stays fixed inside the candle. A candidate current observation replaces the current sample rather than adding another bar. Candidate D is updated together with candidate K:

Candidate K = final K + wK * (candidate Raw - final Raw)
Candidate D = final D + wD * (candidate K - final K)
Candidate K-D = final K-D + (1-wD) * (candidate K - final K)

SMA uses weight 1/n. EMA uses 2/(n+1) after a complete SMA seed; RMA uses 1/n. Undefined inputs restart contiguous warm-up. Seed behavior can differ from other implementations. With D length 1, K equals D and there is no strict K-D side.

For visit direction +1 (upper) or -1 (lower), penetration is max(0, direction * signed extreme - margin).

8. Optional extrema display

Show intrabar extrema bounds is off by default. When enabled, blue shows the necessary extrema span and amber edges show uncertainty in the extrema. These are not volatility bands, confidence intervals or future targets.

Because jumps are allowed, the span does not assert that every intermediate value was observed. Connections between adjacent bars are visual interpolation. If the candle remains inside the retained range, extrema uncertainty is zero, but order, duration and crossing count can remain unknown. Envelope visibility does not alter event selection.

9. Reproducible examples

These are synthetic arithmetic examples, not market-performance results. Use 14/3/3 SMA, a 0.05-point margin and fully initialized history.

Required lower visit: retained range 0 to 100, preceding Raw values stable at 50; current O=60, H=61, L=10, C=60. Opening and closing K-D are approximately +2.222. The minimum is approximately -8.889, giving required/possible penetration of 8.839/8.839 points. The endpoints omit the excursion; no profitable reversal is implied.

Unresolved lower visit: retained range 99 to 100, preceding Raw values stable at 60; O=100, H=101, L=100, C=101. Both endpoint spreads are approximately +8.889. Depending on the unknown order, the minimum can lie from -2.222 to +8.889. Required/possible penetration is 0/2.172 points. The diamond does not identify which path occurred.

Excluded upper visit: retained range 0 to 100, preceding Raw values stable at 50; O=40, H=41, L=39, C=40. Both endpoints are below D, and even the largest possible K-D is approximately -2.000. An upper visit beyond +0.05 is excluded under the model.

10. Contribution and customization

The stochastic and moving-average formulas are established tools, not novelty claims. The contribution is the combined treatment of tight OHLC-consistent intrabar bounds, same-side opposite visits, signed excursion depth and transparent event/notification selection. It addresses what the available data can establish, rather than adding another crossover signal, composite score or assumed tick path. No claim of worldwide exclusivity is made.

Users can change reference lengths, SMA/EMA/RMA smoothing, comparison subject, margin, minimum usable range, repetition, marker selection, placement, history, spacing, alerts, colors, line widths and inspector settings. These are research controls, not optimized trading presets. On narrow panes, reduce the inspector text size or hide it; there is no automatic viewport adaptation.

The Pine source is open under Mozilla Public License 2.0 for inspection, learning and modification, subject to the license and applicable publication rules.

11. Data and interpretation limits

- Standard OHLC charts only. Nonstandard charts are disabled. Close is the only supported source.
- A complete valid H/L/C window, valid current Open, initialized smoothing and a usable preceding N-1-bar range are required. A flat retained range can leave evidence unavailable even when K/D becomes available.
- Evidence, markers, inspector and alerts use completed candles. Preview live K/D only affects the reference lines, not the evidence.
- No lower-timeframe requests, lookahead or intrabar-persistent latch is used. Data corrections, missing bars, loaded starting history and input changes can still alter recalculated results; this is not an unconditional never-repaint promise.
- An opposite-side visit is not a replay of ta.crossover or ta.crossunder. Those functions compare with the preceding chart bar, not the preceding tick. The indicator cannot establish whether an arbitrary alert fired.
- Actual tick order, exact crossing count, excursion time, dwell time, execution price and fills are not recovered.
- Event frequency and depth are not win rates, confidence scores or evidence of trading advantage. No order execution, transaction-cost analysis or out-of-sample strategy performance is supplied.

Use the study to understand the information limits of a closed-bar oscillator. Any trading decision requires separate analysis and risk management.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG_Group
//@version=6
indicator("Stochastic Intrabar Evidence", overlay = false, precision = 3, max_bars_back = 2500, explicit_plot_zorder = true)

// V4.2: readability-only revision. Evidence mathematics and event gates unchanged.
// Quiet default: side-lane marks, no repeated text, six-row Quick read inspector.
// Unchanged V4 OHLC bounds and K/D candidate arithmetic. No future prices,
// lower-timeframe requests, assumed H/L order or actual-alert reconstruction.
// A same-side revisit is not equivalent to ta.crossover/ta.crossunder: those
// functions compare the current observation with the PREVIOUS BAR, not tick.
// Shared stochastic/average formulas are not claimed as original.

const string G_CORE = "01 - Stochastic reference"
const string G_RESEARCH = "02 - Intrabar evidence"
const string G_VIEW = "03 - Display and event stream"
const string G_PANEL = "04 - Inspector"
const string G_ALERT = "05 - Alerts"
const string G_COLOR = "06 - Colors"
const float NUM_EPS = 1e-7

int rangeLength = input.int(14, "Range length", minval = 2, maxval = 500, group = G_CORE, display = display.none)
int kLength = input.int(3, "K smoothing", minval = 1, maxval = 100, group = G_CORE, display = display.none)
int dLength = input.int(3, "D smoothing", minval = 1, maxval = 100, group = G_CORE, display = display.none)
string averageType = input.string("SMA", "Smoothing method", options = ["SMA", "EMA", "RMA"], tooltip = "EMA/RMA use complete SMA seeds and reset after undefined inputs. A candidate observation replaces the current chart-bar observation; it is not another bar.", group = G_CORE, display = display.none)
float upper = input.float(80.0, "Upper K reference", minval = 51.0, maxval = 99.0, step = 1.0, group = G_CORE, display = display.none)
float lower = input.float(20.0, "Lower K reference", minval = 1.0, maxval = 49.0, step = 1.0, group = G_CORE, display = display.none)

string subject = input.string("K versus D", "Evidence subject", options = ["K versus D", "K versus upper", "K versus lower"], tooltip = "K versus D updates candidate D as well as K. Level modes compare K with the selected fixed level. The main finding concerns an opposite-side visit when this bar opens and closes on the same strict side.", group = G_RESEARCH, display = display.none)
float margin = input.float(0.05, "Strict-side margin in oscillator points", minval = 0.0, maxval = 5.0, step = 0.01, tooltip = "ABOVE means K-D (or K-level) > +margin; BELOW means < -margin. Values within 1e-7 point of a classification boundary are BOUNDARY. EXCLUDED does not rule out movement inside this margin. This is not confidence or a price tick.", group = G_RESEARCH, display = display.none)
float minimumTicks = input.float(0.0, "Minimum usable retained range in ticks", minval = 0.0, maxval = 1000.0, step = 0.5, tooltip = "The preceding N-1 bars must already have positive usable width. The same width guard applies to the stochastic. If only the current bar creates a range, K/D may be available while evidence is not.", group = G_RESEARCH, display = display.none)

bool showEnvelope = input.bool(false, "Show intrabar extrema bounds", tooltip = "Blue is the necessary extrema span, not an observed path. Amber edges show uncertainty in extrema. Zero width identifies extrema, not order or trade quality. Lines between bars are visual interpolation only.", group = G_VIEW, display = display.none)
bool showMarks = input.bool(true, "Show directional event marks", tooltip = "Circle = required visit; diamond = unresolved visit. UP/DN refer to the oscillator side visited, NOT a buy/sell direction. Marks are computed only after close. Hide this switch also suppresses event notifications when their scope is Match marker selection.", group = G_VIEW, display = display.none)
string markerPlacement = input.string("Side lanes", "Marker placement", options = ["Side lanes", "Evidence bounds"], tooltip = "Side lanes keep marks away from K/D: upper lane = upper-side visit; lower lane = lower-side visit. Lane coordinates are layout positions, NOT oscillator values. Circle = required; diamond = unresolved. Evidence bounds restores the former extremum anchors. No event selection changes.", group = G_VIEW, display = display.none)
bool showMarkText = input.bool(false, "Show UP/DN text on marks", tooltip = "Off by default to avoid overlapping text. Direction is already encoded by upper/lower lane. Optional text adds UP/DN, with a question mark for unresolved visits. These are not buy/sell signals.", group = G_VIEW, display = display.none)
float laneGap = input.float(5.0, "Lane gap outside 0-100", minval = 2.0, maxval = 12.0, step = 0.5, tooltip = "Layout spacing in oscillator-axis units, used only in Side lanes mode. Does not alter the evidence or alerts.", group = G_VIEW, display = display.none)
string eventRepeat = input.string("Class or direction changes", "Event repetition", options = ["Class or direction changes", "Every qualifying bar"], tooltip = "A new event is a change in required/unresolved class or visit direction. A bar with no qualifying revisit resets the comparison. Every qualifying bar retains consecutive events. All evidence (audit) markers bypass this reduction.", group = G_VIEW, display = display.none)
string markerMode = input.string("Event stream", "Marker mode", options = ["Event stream", "All evidence (audit)", "Spaced event stream"], tooltip = "Event stream follows Event repetition. All evidence (audit) bypasses repetition/spacing and marks every required or unresolved revisit in the visible history. Spaced event stream adds the spacing filter. With matching alert scope, event notifications use the same selected marks.", group = G_VIEW, display = display.none)
int markHistory = input.int(160, "Visible marker window in chart bars", minval = 20, maxval = 2000, tooltip = "The window includes a forming chart bar, even though no event is drawn on it. Inspector counts use exactly this same window. Older marks are display-clipped; calculations remain available in the Data Window.", group = G_VIEW, display = display.none)
int markSpacing = input.int(3, "Spacing for Spaced event stream", minval = 1, maxval = 50, group = G_VIEW, display = display.none)
bool liveReference = input.bool(false, "Preview live K/D only", tooltip = "Only K/D may preview the forming bar. All evidence, marks, inspector and alerts remain closed-bar. This preview is not an early version of the closed-bar certificate.", group = G_VIEW, display = display.none)
int kWidth = input.int(3, "K line width", minval = 1, maxval = 5, group = G_VIEW, display = display.none)
int dWidth = input.int(2, "D line width", minval = 1, maxval = 5, group = G_VIEW, display = display.none)
int edgeOpacity = input.int(83, "Uncertainty-edge transparency", minval = 55, maxval = 98, group = G_VIEW, display = display.none)

bool showPanel = input.bool(true, "Show inspector", group = G_PANEL, display = display.none)
string panelPage = input.string("Quick read", "Inspector page", options = ["Quick read", "Decision", "Extrema and endpoints", "Event audit", "Reading guide"], group = G_PANEL, display = display.none)
string panelCorner = input.string("Top right", "Inspector position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = G_PANEL, display = display.none)
string panelSize = input.string("Normal", "Inspector text size", options = ["Small", "Normal", "Large"], tooltip = "Quick read uses six rows at the Normal size by default. Detailed pages retain all diagnostics. Use Small or hide the inspector on very narrow panes. Pine cannot detect viewport width. Quick read keeps compact bar times; full timestamps remain in its tooltip and all detailed pages.", group = G_PANEL, display = display.none)
string zoneChoice = input.string("UTC", "Evidence time zone", options = ["UTC", "Exchange", "Asia/Tokyo", "America/New_York", "Europe/London"], tooltip = "Pine cannot read your chart's display time zone. Choose the intended zone explicitly. Timestamp labels identify this zone; IANA zones follow daylight-saving rules.", group = G_PANEL, display = display.none)
int evidenceDecimals = input.int(3, "Evidence decimal places", minval = 2, maxval = 6, tooltip = "Display precision only. Classification always uses unrounded values. Increase precision near a threshold; a displayed rounded zero is not mathematical equality.", group = G_PANEL, display = display.none)

string eventAlertScope = input.string("Match marker selection", "Event notification scope", options = ["Match marker selection", "All event-stream events"], tooltip = "Match marker selection shares the marker-selection gate, including audit/spaced mode and Show marks. On a realtime close the newest bar is always inside the visible window. All event-stream events ignores visibility/spacing but still follows Event repetition. These are eligibility rules, not proof of actual delivery.", group = G_ALERT, display = display.none)
string stateAlertMode = input.string("Off", "Optional endpoint-state notices", options = ["Off", "Class change only", "Every closed bar"], tooltip = "Separate optional channel: above/below-side classes, which may be implied by the endpoints alone. Off by default. Every closed bar is deliberately repetitive. State notices do not have matching event marks and are never trade signals.", group = G_ALERT, display = display.none)
bool dynamicMessages = input.bool(true, "Enable descriptive alert() messages", tooltip = "Create one TradingView alert using Any alert() function call. Messages include symbol, timeframe, evidence time, relation, direction and depth. Alternatively choose one of the two event alertconditions. Do not create both routes unless duplicate delivery is intended. Changing code/inputs does not update existing alert snapshots.", group = G_ALERT, display = display.none)

color kColor = input.color(#18DFFF, "K", group = G_COLOR, display = display.none)
color dColor = input.color(#FFD166, "D", group = G_COLOR, display = display.none)
color forcedColor = input.color(#67EDB1, "Required visit / circle", group = G_COLOR, display = display.none)
color possibleColor = input.color(#FFB85C, "Unresolved visit / diamond", group = G_COLOR, display = display.none)
color envelopeColor = input.color(#78B7FF, "Necessary extrema span", group = G_COLOR, display = display.none)
color neutralColor = input.color(#93A2BB, "Excluded / guides", group = G_COLOR, display = display.none)
color boundaryColor = input.color(#D0A5FF, "Boundary / unavailable", group = G_COLOR, display = display.none)
color panelBackground = input.color(#101827, "Inspector background", group = G_COLOR, display = display.none)
color panelText = input.color(#F0F5FF, "Inspector text", group = G_COLOR, display = display.none)

// -------------------- Unchanged, independently checked V4 core --------------------
f_order(float a, float b) =>
    float dt = (a - b) / syminfo.mintick
    na(dt) ? int(na) : dt > 0.0 ? 1 : dt < 0.0 ? -1 : 0

f_hlc_valid(float h, float l, float c) =>
    not na(h) and not na(l) and not na(c) and syminfo.mintick > 0.0 and f_order(h, l) >= 0 and f_order(c, l) >= 0 and f_order(c, h) <= 0

f_width_ok(float h, float l) =>
    float wt = (h - l) / syminfo.mintick
    float guard = math.max(1e-7, 8.881784197001252e-16 * math.max(math.abs(h), math.abs(l)) / syminfo.mintick)
    not na(wt) and wt > 0.0 and (minimumTicks == 0.0 or wt - guard >= minimumTicks)

f_raw(float p, float h, float l) =>
    f_width_ok(h, l) ? 100.0 * ((p - l) / (h - l)) : na

// Each written call owns its state. Calls execute unconditionally on every bar.
f_average(float x, simple int n, simple string kind) =>
    var int run = 0
    var float result = na
    run := na(x) ? 0 : run + 1
    float seed = ta.sma(x, n)
    float alpha = kind == "EMA" ? 2.0 / (n + 1.0) : 1.0 / n
    if run < n
        result := na
    else if kind == "SMA"
        result := seed
    else
        result := na(result[1]) ? seed : result[1] + alpha * (x - result[1])
    result

f_weight(float previous, simple int n, simple string kind) =>
    kind == "SMA" or na(previous) ? 1.0 / n : kind == "EMA" ? 2.0 / (n + 1.0) : 1.0 / n

// Upper-excursion trivalence with a separate numerical-boundary state:
// 2 forced; 1 possible but not forced; 0 excluded; 3 boundary; na unavailable.
f_above(float mustMax, float mayMax, float cutoff) =>
    na(mustMax) or na(mayMax) ? int(na) : mustMax > cutoff + NUM_EPS ? 2 : mayMax < cutoff - NUM_EPS ? 0 : mustMax < cutoff - NUM_EPS and mayMax > cutoff + NUM_EPS ? 1 : 3

f_name(int code) =>
    na(code) ? "UNAVAILABLE" : code == 2 ? "FORCED" : code == 1 ? "POSSIBLE" : code == 0 ? "EXCLUDED" : "BOUNDARY"

f_ink(int code) =>
    na(code) or code == 3 ? boundaryColor : code == 2 ? forcedColor : code == 1 ? possibleColor : neutralColor

f_num(float value) =>
    na(value) ? "n/a" : str.tostring(value, evidenceDecimals == 2 ? "0.00" : evidenceDecimals == 3 ? "0.000" : evidenceDecimals == 4 ? "0.0000" : evidenceDecimals == 5 ? "0.00000" : "0.000000")

f_interval(float a, float b) =>
    f_num(a) + " .. " + f_num(b)

f_side(float value) =>
    na(value) ? "n/a" : value > margin + NUM_EPS ? "ABOVE" : value < -margin - NUM_EPS ? "BELOW" : "NEAR"

f_row(table t, int row, string label, string value, color ink, string font, string tip, bool emphasis = false) =>
    color rowBackground = emphasis ? color.new(ink, 88) : panelBackground
    table.cell(t, 0, row, label, text_color = panelText, text_size = font, bgcolor = rowBackground, text_halign = text.align_left, tooltip = tip)
    table.cell(t, 1, row, value, text_color = ink, text_size = font, bgcolor = rowBackground, text_halign = text.align_right, tooltip = tip, text_formatting = emphasis ? text.format_bold : text.format_none)

// -------------------------- Standard reference ---------------------------
bool validHlc = chart.is_standard and f_hlc_valid(high, low, close)
var int consecutive = 0
consecutive := validHlc ? consecutive + 1 : 0
float finalHi = ta.highest(high, rangeLength)
float finalLo = ta.lowest(low, rangeLength)
float priorHi = ta.highest(high[1], rangeLength - 1)
float priorLo = ta.lowest(low[1], rangeLength - 1)
bool fullWindow = consecutive >= rangeLength
float raw = fullWindow ? f_raw(close, finalHi, finalLo) : na
float k = f_average(raw, kLength, averageType)
float d = f_average(k, dLength, averageType)
float wk = f_weight(k[1], kLength, averageType)
float wd = f_weight(d[1], dLength, averageType)
bool validOpen = not na(open) and f_order(open, low) >= 0 and f_order(open, high) <= 0
bool inputReady = fullWindow and validOpen and not na(k) and not na(d) and f_width_ok(priorHi, priorLo)

// -------------------- Tight OHLC-consistent raw bounds --------------------
// Let [priorLo,priorHi] be the N-1 retained chart bars, NOT yesterday's whole
// N-bar range. Current-bar running extrema start at Open, then expand.
// Admissible sequences begin at O, end at C, stay in [L,H], and visit H and L.
// Repeated visits and gaps between price observations are allowed. No assumed
// H/L order, linear interpolation, exchange tick count or path probabilities.
float openHi = math.max(priorHi, open)
float openLo = math.min(priorLo, open)
float rawOpen = inputReady ? f_raw(open, openHi, openLo) : na
float highBeforeLow = inputReady ? f_raw(high, finalHi, openLo) : na
float lowBeforeHigh = inputReady ? f_raw(low, openHi, finalLo) : na
float rawMinPossible = inputReady ? f_raw(low, finalHi, finalLo) : na
float rawMaxPossible = inputReady ? f_raw(high, finalHi, finalLo) : na
float rawMinRequired = inputReady ? math.min(rawOpen, math.min(raw, lowBeforeHigh)) : na
float rawMaxRequired = inputReady ? math.max(rawOpen, math.max(raw, highBeforeLow)) : na

// For EVERY admissible sequence:
//   rawMinPossible <= its intrabar minimum <= rawMinRequired
//   rawMaxRequired <= its intrabar maximum <= rawMaxPossible.
// Both endpoints of each interval are attainable (separately). O-H-L-C and
// O-L-H-C witness them; they do not enumerate all possible return sequences.
// The four endpoints together need not describe a SINGLE actual path.

// Pine rollback fixes all completed smoothing history within the current bar.
// Substitute the current Raw only. Update D as well, never compare candidate
// K with the final actual D. Affine weights are nonnegative; wd=1 is legal.
float kOpen = k + wk * (rawOpen - raw)
float kMinPossible = k + wk * (rawMinPossible - raw)
float kMinRequired = k + wk * (rawMinRequired - raw)
float kMaxRequired = k + wk * (rawMaxRequired - raw)
float kMaxPossible = k + wk * (rawMaxPossible - raw)
float ambiguity = (kMinRequired - kMinPossible) + (kMaxPossible - kMaxRequired)

bool rawBoundsOk = inputReady and rawMinPossible >= -NUM_EPS and rawMaxPossible <= 100.0 + NUM_EPS and rawMinPossible <= rawMinRequired + NUM_EPS and rawMaxRequired <= rawMaxPossible + NUM_EPS and rawMinRequired <= math.min(rawOpen, raw) + NUM_EPS and rawMaxRequired >= math.max(rawOpen, raw) - NUM_EPS
bool evidenceReady = rawBoundsOk and ambiguity >= -NUM_EPS and kMinPossible >= -NUM_EPS and kMaxPossible <= 100.0 + NUM_EPS
float target = subject == "K versus upper" ? upper : lower
float metricClose = subject == "K versus D" ? k - d : k - target
float metricWeight = subject == "K versus D" ? 1.0 - wd : 1.0
float metricOpen = metricClose + metricWeight * (kOpen - k)
float metricMinPossible = metricClose + metricWeight * (kMinPossible - k)
float metricMinRequired = metricClose + metricWeight * (kMinRequired - k)
float metricMaxRequired = metricClose + metricWeight * (kMaxRequired - k)
float metricMaxPossible = metricClose + metricWeight * (kMaxPossible - k)
int aboveCode = evidenceReady ? f_above(metricMaxRequired, metricMaxPossible, margin) : int(na)
int belowCode = evidenceReady ? f_above(-metricMinRequired, -metricMinPossible, margin) : int(na)
int closeSide = metricClose > margin + NUM_EPS ? 1 : metricClose < -margin - NUM_EPS ? -1 : 0
int openSide = metricOpen > margin + NUM_EPS ? 1 : metricOpen < -margin - NUM_EPS ? -1 : 0
bool sameSide = evidenceReady and closeSide != 0 and openSide == closeSide
int revisitCode = evidenceReady and sameSide ? (closeSide == 1 ? belowCode : aboveCode) : int(na)
bool forcedRevisit = evidenceReady and sameSide and revisitCode == 2
bool possibleRevisit = evidenceReady and sameSide and revisitCode == 1

// -------------------- Direction, signed extrema and penetration --------------------
// visitSide is the side VISITED, the opposite of the shared opening/closing side.
// For a lower-side visit, the required/possible extrema are signed minima.
// For an upper-side visit, they are signed maxima. Neither is a future target.
int visitSide = sameSide ? -closeSide : int(na)
float oppositeRequired = sameSide ? (visitSide == 1 ? metricMaxRequired : metricMinRequired) : na
float oppositePossible = sameSide ? (visitSide == 1 ? metricMaxPossible : metricMinPossible) : na
float requiredDepth = sameSide ? math.max(0.0, visitSide * oppositeRequired - margin) : na
float possibleDepth = sameSide ? math.max(0.0, visitSide * oppositePossible - margin) : na
// Depth is a nonnegative excess BEYOND the selected strict-side margin.
// For an unresolved visit the guaranteed depth is zero, not a small probability.

f_signed(float value) =>
    na(value) ? "n/a" : (value > 0.0 ? "+" : "") + f_num(value)

f_depth(float value) =>
    float unit = math.pow(10.0, -evidenceDecimals)
    na(value) ? "n/a" : value > 0.0 and value < unit ? "<" + f_num(unit) : f_num(value)

f_visit(int dir) =>
    na(dir) ? "n/a" : dir == 1 ? "UPPER" : "LOWER"

f_result(int code, bool context) =>
    not context ? "NO SAME-SIDE PAIR" : code == 2 ? "REQUIRED" : code == 1 ? "UNRESOLVED" : code == 0 ? "EXCLUDED" : code == 3 ? "BOUNDARY" : "UNAVAILABLE"

string timeZone = zoneChoice == "Exchange" ? syminfo.timezone : zoneChoice
string relationName = subject == "K versus D" ? "K - D" : "K - " + f_num(target)
f_stamp(int timestamp) =>
    na(timestamp) ? "n/a" : str.format_time(timestamp, "yyyy-MM-dd HH:mm:ss.SSS", timeZone)

f_bar_range(int opened, int ended) =>
    f_stamp(opened) + "\n" + f_stamp(ended)


// Compact formatting removes repeated dates/zero sub-minute fields, not precision.
// Sub-minute bars retain seconds; nonzero millisecond timestamps retain milliseconds.
// Exact full timestamps remain in detail pages, tooltips and alert messages.
f_quick_range(int opened, int ended) =>
    string compact = "n/a"
    if not na(opened) and not na(ended)
        string dayOpen = str.format_time(opened, "yyyy-MM-dd", timeZone)
        string dayClose = str.format_time(ended, "yyyy-MM-dd", timeZone)
        bool milliseconds = opened % 1000 != 0 or ended % 1000 != 0
        bool seconds = opened % 60000 != 0 or ended % 60000 != 0
        bool offsetChanges = str.format_time(opened, "Z", timeZone) != str.format_time(ended, "Z", timeZone)
        string clockFormat = (milliseconds ? "HH:mm:ss.SSS" : seconds ? "HH:mm:ss" : "HH:mm") + (offsetChanges ? " Z" : "")
        string startClock = str.format_time(opened, clockFormat, timeZone)
        string endClock = str.format_time(ended, clockFormat, timeZone)
        compact := dayOpen == dayClose ? dayOpen + "\n" + startClock + " - " + endClock : dayOpen + " " + startClock + "\n" + dayClose + " " + endClock
    compact

// -------------------- One auditable event-selection pipeline --------------------
bool closed = barstate.isconfirmed
bool allEvidenceEvent = closed and (forcedRevisit or possibleRevisit)
int eventKey = allEvidenceEvent ? visitSide * revisitCode : 0
bool changedEvidence = allEvidenceEvent and eventKey != nz(eventKey[1], 0)
bool streamEvent = allEvidenceEvent and (eventRepeat == "Every qualifying bar" or changedEvidence)
bool markerCandidate = markerMode == "All evidence (audit)" ? allEvidenceEvent : streamEvent
var int lastMark = na
bool spacingPass = markerMode != "Spaced event stream" or na(lastMark) or bar_index - lastMark >= markSpacing
bool drawEvent = closed and showMarks and markerCandidate and spacingPass
if drawEvent
    lastMark := bar_index
bool eventNotification = closed and (eventAlertScope == "Match marker selection" ? drawEvent : streamEvent)
int stateKey = evidenceReady ? aboveCode * 5 + belowCode : int(na)
bool stateNotification = closed and evidenceReady and stateAlertMode != "Off" and (stateAlertMode == "Every closed bar" or na(stateKey[1]) or stateKey != stateKey[1])

// Cumulative totals are evaluated on every bar. The inspector subtracts the
// bar just OUTSIDE the show_last window, including its forming-bar adjustment.
float totalEvidence = ta.cum(allEvidenceEvent ? 1.0 : 0.0)
float totalStream = ta.cum(streamEvent ? 1.0 : 0.0)
float totalCandidates = ta.cum(markerCandidate ? 1.0 : 0.0)
float totalDrawn = ta.cum(drawEvent ? 1.0 : 0.0)
float totalEventNotices = ta.cum(eventNotification ? 1.0 : 0.0)

// -------------------- Closed-bar visual layer --------------------
bool referenceVisible = closed or liveReference
bool boundsVisible = closed and evidenceReady and showEnvelope
pMinPossible = plot(boundsVisible ? kMinPossible : na, "K minimum - possible floor", color = color.new(possibleColor, 70), linewidth = 1, style = plot.style_linebr, display = display.pane)
pMinRequired = plot(boundsVisible ? kMinRequired : na, "K minimum - required ceiling", color = color.new(envelopeColor, 65), linewidth = 1, style = plot.style_linebr, display = display.pane)
pMaxRequired = plot(boundsVisible ? kMaxRequired : na, "K maximum - required floor", color = color.new(envelopeColor, 65), linewidth = 1, style = plot.style_linebr, display = display.pane)
pMaxPossible = plot(boundsVisible ? kMaxPossible : na, "K maximum - possible ceiling", color = color.new(possibleColor, 70), linewidth = 1, style = plot.style_linebr, display = display.pane)
fill(pMinPossible, pMinRequired, color = color.new(possibleColor, edgeOpacity), title = "Uncertainty in K minimum", fillgaps = false)
fill(pMaxRequired, pMaxPossible, color = color.new(possibleColor, edgeOpacity), title = "Uncertainty in K maximum", fillgaps = false)
fill(pMinRequired, pMaxRequired, color = color.new(envelopeColor, 94), title = "Necessary extrema span - not a reconstructed path", fillgaps = false)
hline(100.0, "Scale top", color = color.new(neutralColor, 80), linestyle = hline.style_dotted)
hline(upper, "Upper reference", color = color.new(neutralColor, 35), linestyle = hline.style_dashed)
hline(50.0, "Middle reference", color = color.new(neutralColor, 75), linestyle = hline.style_dotted)
hline(lower, "Lower reference", color = color.new(neutralColor, 35), linestyle = hline.style_dashed)
hline(0.0, "Scale bottom", color = color.new(neutralColor, 80), linestyle = hline.style_dotted)
plot(referenceVisible ? d : na, "D", color = dColor, linewidth = dWidth, style = plot.style_linebr, display = display.pane + display.data_window)
plot(referenceVisible ? k : na, "K", color = kColor, linewidth = kWidth, style = plot.style_linebr, display = display.pane + display.data_window)
// Side-lane coordinates are layout-only, never measured K extrema or trade targets.
// Evidence bounds mode restores the V4.1 extremum anchors without changing events.
bool sideLanes = markerPlacement == "Side lanes"
float requiredUpperY = sideLanes ? 100.0 + laneGap : kMaxRequired
float requiredLowerY = sideLanes ? -laneGap : kMinRequired
float possibleUpperY = sideLanes ? 100.0 + laneGap : kMaxPossible
float possibleLowerY = sideLanes ? -laneGap : kMinPossible
color requiredText = showMarkText ? forcedColor : color.new(forcedColor, 100)
color unresolvedText = showMarkText ? possibleColor : color.new(possibleColor, 100)
plotshape(drawEvent and forcedRevisit and visitSide == 1 ? requiredUpperY : na, "Required upper-side visit", style = shape.circle, location = location.absolute, color = forcedColor, text = "UP", textcolor = requiredText, size = size.tiny, show_last = markHistory, display = display.pane)
plotshape(drawEvent and forcedRevisit and visitSide == -1 ? requiredLowerY : na, "Required lower-side visit", style = shape.circle, location = location.absolute, color = forcedColor, text = "DN", textcolor = requiredText, size = size.tiny, show_last = markHistory, display = display.pane)
plotshape(drawEvent and possibleRevisit and visitSide == 1 ? possibleUpperY : na, "Unresolved upper-side visit", style = shape.diamond, location = location.absolute, color = possibleColor, text = "UP?", textcolor = unresolvedText, size = size.tiny, show_last = markHistory, display = display.pane)
plotshape(drawEvent and possibleRevisit and visitSide == -1 ? possibleLowerY : na, "Unresolved lower-side visit", style = shape.diamond, location = location.absolute, color = possibleColor, text = "DN?", textcolor = unresolvedText, size = size.tiny, show_last = markHistory, display = display.pane)

// Sixteen fixed Data Window channels; classes are 0 excluded, 1 unresolved,
// 2 required, 3 boundary, na unavailable/context absent. Flags are eligibility,
// not proof of actual on-screen pixels or alert delivery.
plot(closed and evidenceReady ? kOpen : na, "Evidence - K at bar open", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? kMinPossible : na, "Evidence - minimum lower bound", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? kMinRequired : na, "Evidence - minimum upper bound", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? kMaxRequired : na, "Evidence - maximum lower bound", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? kMaxPossible : na, "Evidence - maximum upper bound", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? math.max(0.0, ambiguity) : na, "Evidence - extrema uncertainty width", color = neutralColor, display = display.data_window)
plot(closed ? aboveCode : na, "Evidence - above code: 0 excluded 1 unresolved 2 required 3 boundary", color = neutralColor, display = display.data_window)
plot(closed ? belowCode : na, "Evidence - below code: 0 excluded 1 unresolved 2 required 3 boundary", color = neutralColor, display = display.data_window)
plot(closed ? revisitCode : na, "Evidence - same-side revisit code", color = neutralColor, display = display.data_window)
plot(closed ? visitSide : na, "Visit direction: +1 upper -1 lower", color = neutralColor, display = display.data_window)
plot(closed ? oppositeRequired : na, "Opposite extreme required", color = neutralColor, display = display.data_window)
plot(closed ? oppositePossible : na, "Opposite extreme possible", color = neutralColor, display = display.data_window)
plot(closed ? requiredDepth : na, "Penetration required beyond margin", color = neutralColor, display = display.data_window)
plot(closed ? possibleDepth : na, "Penetration possible beyond margin", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? (drawEvent ? 1.0 : 0.0) : na, "Event mark selected before history clipping", color = neutralColor, display = display.data_window)
plot(closed and evidenceReady ? (eventNotification ? 1.0 : 0.0) : na, "Event notification eligible - not actual delivery", color = neutralColor, display = display.data_window)

// -------------------- Last closed-bar decision inspector --------------------
string corner = switch panelCorner
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
string font = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal
var table inspector = table.new(corner, 2, 10, bgcolor = panelBackground, frame_color = color.new(neutralColor, 65), frame_width = 1)
if barstate.islast
    table.clear(inspector, 0, 0, 1, 9)
    if showPanel
        int s = closed ? 0 : 1
        bool ready = evidenceReady[s]
        bool context = sameSide[s]
        string availability = not chart.is_standard ? "STANDARD ONLY" : not validHlc[s] ? "INVALID HLC" : not fullWindow[s] ? "WINDOW WARM-UP" : na(k[s]) or na(d[s]) ? "K/D WARM-UP" : not validOpen[s] ? "INVALID OPEN" : not f_width_ok(priorHi[s], priorLo[s]) ? "RETAINED N/A" : not ready ? "BOUND CHECK" : "CLOSED / " + str.tostring(s) + "b AGO"
        int availableBars = math.max(0, math.min(markHistory, bar_index + 1) - s)
        int eligibleCount = int(nz(totalEvidence[s]) - nz(totalEvidence[markHistory]))
        int streamCount = int(nz(totalStream[s]) - nz(totalStream[markHistory]))
        int candidateCount = int(nz(totalCandidates[s]) - nz(totalCandidates[markHistory]))
        int drawnCount = int(nz(totalDrawn[s]) - nz(totalDrawn[markHistory]))
        int noticeCount = int(nz(totalEventNotices[s]) - nz(totalEventNotices[markHistory]))
        int reducedCount = eligibleCount - candidateCount
        int omittedCount = eligibleCount - drawnCount
        string verdict = not ready ? "UNAVAILABLE" : not context ? "NO SAME-SIDE PAIR" : f_visit(visitSide[s]) + ": " + f_result(revisitCode[s], true)
        string modeShort = markerMode == "All evidence (audit)" ? "ALL / AUDIT" : markerMode == "Spaced event stream" ? "SPACED" : "EVENT STREAM"
        string alertShort = eventAlertScope == "Match marker selection" ? "MATCH MARKS" : "ALL STREAM"
        if panelPage == "Quick read"
            string quickRelation = subject == "K versus D" ? "K-D" : "K-" + str.tostring(target, "0.0")
            string quickKD = (na(k[s]) ? "n/a" : str.tostring(k[s], "0.0")) + " / " + (na(d[s]) ? "n/a" : str.tostring(d[s], "0.0"))
            string quickDepth = context ? f_depth(requiredDepth[s]) + " / " + f_depth(possibleDepth[s]) + " pts" : "n/a"
            string quickAlerts = alertShort + (stateAlertMode == "Off" ? " | S:OFF" : " | S:ON")
            color verdictInk = not ready ? boundaryColor : context ? f_ink(revisitCode[s]) : neutralColor
            f_row(inspector, 0, "K / D", quickKD, kColor, font, "Last completed-bar K/D, rounded here to one decimal for readability. Full configured precision remains on Extrema and endpoints. Status: " + availability + ".")
            f_row(inspector, 1, "Visit | " + quickRelation, verdict, verdictInk, font, "Opposite-side visit within the same closed bar. Circle = required, diamond = unresolved; upper lane = upper visit, lower lane = lower visit. Margin: +/- " + f_num(margin) + " oscillator pts. " + (ready ? "Open/close: " + f_side(metricOpen[s]) + " / " + f_side(metricClose[s]) + "." : availability) + " No trade or forecast.", true)
            f_row(inspector, 2, "Depth R / P", quickDepth, verdictInk, font, "Required / possible maximum penetration BEYOND the opposite-side margin, in oscillator points. Not confidence or return. Signed extrema remain on Decision and in the Data Window.")
            f_row(inspector, 3, timeZone + "\nCLOSED / " + str.tostring(s) + "b", f_quick_range(time[s], time_close[s]), panelText, font, "Evidence bar OPEN / CLOSE in " + timeZone + ":\n" + f_bar_range(time[s], time_close[s]) + "\nSame-day dates and zero second fields are compacted; sub-minute precision is retained when needed. These are bar boundaries, not excursion timestamps. Status: " + availability + ".")
            f_row(inspector, 4, "Marks [" + str.tostring(markHistory) + "]", str.tostring(drawnCount) + "/" + str.tostring(eligibleCount) + " | hidden " + str.tostring(omittedCount), panelText, font, "Selected / all eligible events in the exact window. Top lane = upper-side visit, bottom lane = lower-side visit. Circle = REQUIRED, diamond = UNRESOLVED. " + modeShort + ". Hidden = repetition, spacing or Show marks; manual Style visibility is not detectable. Switch to Event audit for the full breakdown.")
            f_row(inspector, 5, "Event alerts", quickAlerts, panelText, font, "MARKS = Match marker selection; STREAM = All event-stream events. S = separate endpoint-state notices: " + stateAlertMode + ". Eligibility is not actual delivery. Current display-only changes do not change notification conditions.")
        else
            f_row(inspector, 0, "Stochastic Intrabar\nEvidence", availability, ready ? panelText : boundaryColor, font, "V4.2. Closed OHLC evidence only. Bars ago is relative to the last chart bar, not elapsed wall-clock time. Nothing here predicts a trade.")
            f_row(inspector, 1, "Bar: " + timeZone + "\nopen / close", f_bar_range(time[s], time_close[s]), panelText, font, "These are the evidence bar's opening and closing timestamps in the displayed zone, NOT the time of an intrabar excursion. Pine cannot read the chart's selected display time zone.")
            if panelPage == "Decision"
                f_row(inspector, 2, "Opposite visit", verdict, not ready ? boundaryColor : context ? f_ink(revisitCode[s]) : neutralColor, font, "The main finding, conditional on this bar opening and closing on the SAME strict side. REQUIRED means every compatible price sequence visits the opposite side beyond the margin. UNRESOLVED means some do and some do not. EXCLUDED rules out that margin-exceeding visit, not future reversal or near-boundary movement.")
                f_row(inspector, 3, "Relation / margin", relationName + "\n+/- " + f_num(margin) + " pts", panelText, font, "All signed extrema and depths on this page use K-D or K minus the fixed level. Oscillator points, not ticks, percentages, confidence or returns.")
                f_row(inspector, 4, "Open -> close", ready ? f_side(metricOpen[s]) + " -> " + f_side(metricClose[s]) : "n/a", panelText, font, "Both endpoints belong to this same evidence bar. An endpoint change or NEAR endpoint has no same-side revisit verdict; it is not counted as excluded.")
                f_row(inspector, 5, "Extreme R / P", context ? f_signed(oppositeRequired[s]) + " / " + f_signed(oppositePossible[s]) : "n/a", context ? f_ink(revisitCode[s]) : neutralColor, font, "R = required extremum, P = possible outer extremum, signed relative to the selected relation. Lower visits use minima (P can be more negative); upper visits use maxima. In an unresolved case R need not lie on the opposite side. Not a future target.")
                f_row(inspector, 6, "Beyond margin\nR / P", context ? f_depth(requiredDepth[s]) + " / " + f_depth(possibleDepth[s]) + " pts" : "n/a", context ? f_ink(revisitCode[s]) : neutralColor, font, "Guaranteed/possible maximum penetration past the opposite strict-side boundary. Required depth is zero when an opposite visit is not guaranteed. A positive sub-display-unit depth is shown as <unit, not zero. Magnitude is not trade quality or expected return. Display rounding does not control classification.")
                string useText = not ready ? "WAIT FOR VALID DATA" : not context ? "ENDPOINTS NOT SAME SIDE" : revisitCode[s] == 2 ? "CLOSE OMITS AN EXCURSION" : revisitCode[s] == 1 ? "OHLC CANNOT RESOLVE IT" : revisitCode[s] == 0 ? "NO OPPOSITE MARGIN VISIT" : "NUMERICAL BOUNDARY"
                f_row(inspector, 7, "What is known", useText, panelText, font, "A practical reading of historical information, not an entry, trend-quality label or live-alert replay. ta.crossover/ta.crossunder use the prior completed BAR, not the prior tick.")
            else if panelPage == "Extrema and endpoints"
                f_row(inspector, 2, "K / D", f_num(k[s]) + " / " + f_num(d[s]), kColor, font, "Conventional reference values at this bar's close. Their endpoint relation alone can imply a side visit, which is why endpoint-state notices are optional and off by default.")
                f_row(inspector, 3, "K minimum", ready ? f_interval(kMinPossible[s], kMinRequired[s]) : "n/a", possibleColor, font, "Lower/upper bound of the unknown intrabar K minimum; endpoints are separately attainable.")
                f_row(inspector, 4, "K maximum", ready ? f_interval(kMaxRequired[s], kMaxPossible[s]) : "n/a", possibleColor, font, "Lower/upper bound of the unknown intrabar K maximum. Four extrema endpoints are not one actual path.")
                f_row(inspector, 5, "Extrema uncertainty", ready ? f_num(math.max(0.0, ambiguity[s])) + " K pts" : "n/a", boundaryColor, font, "Zero when the extrema are identified, often because this bar stays inside the retained range. Zero does not identify order, timing, dwell or crossing count.")
                f_row(inspector, 6, "Above / below\nendpoint states", f_name(aboveCode[s]) + " / " + f_name(belowCode[s]), neutralColor, font, "Secondary side-visit classes. These may already be implied by Open or Close. FORCED corresponds to REQUIRED in the main verdict. Neither class is a signal-quality score.")
                f_row(inspector, 7, "Input / smoothing", "CLOSE / " + averageType + "\n" + str.tostring(rangeLength) + "/" + str.tostring(kLength) + "/" + str.tostring(dLength), panelText, font, "Close only: another source has different intrabar evolution. EMA/RMA use complete SMA seeds. No order, feed or lower-timeframe requests.")
            else if panelPage == "Event audit"
                f_row(inspector, 2, "Window / closed", str.tostring(markHistory) + " chart bars\n" + str.tostring(availableBars) + " closed", panelText, font, "Exactly the plot show_last window. A forming bar consumes one chart-bar slot, so counts deliberately exclude it. Counts describe available loaded history only.")
                f_row(inspector, 3, "All evidence", str.tostring(eligibleCount), panelText, font, "Every required or unresolved same-side revisit in the window, before repetition/spacing/visibility reduction. Excluded, boundary and absent-context cases are not marker events.")
                f_row(inspector, 4, "Event stream", str.tostring(streamCount) + "\n" + eventRepeat, panelText, font, "Class/direction changes remove immediately repeated identical evidence keys. A non-event resets the sequence; every-bar mode retains all eligible events.")
                f_row(inspector, 5, "Omitted / reduced", str.tostring(omittedCount) + " total\n" + str.tostring(reducedCount) + " by repetition", neutralColor, font, "Omitted = all evidence minus drawn marks. Repetition reduction uses the selected marker mode (zero in audit mode). Remaining omissions come from spacing or Show marks being off. Outside-window history is not included.")
                f_row(inspector, 6, "Event notice\neligibility", str.tostring(noticeCount) + " / " + alertShort, panelText, font, "Retrospective eligibility count, NOT messages actually delivered. Actual alerts start only after a user creates an alert and are subject to platform behavior. Optional state notices are a separate channel.")
                f_row(inspector, 7, "State notices", stateAlertMode, stateAlertMode == "Off" ? neutralColor : possibleColor, font, "Off by default. Optional endpoint-state notices are deliberately separate from revisit marks. Class change only notices when the above/below pair changes; Every closed bar is a repeated state report.")
            else
                f_row(inspector, 2, "Circle / diamond", "REQUIRED / UNRESOLVED", forcedColor, font, "Circle: every OHLC-consistent sequence has the margin-exceeding visit. Diamond: both visit and no-visit sequences are compatible. Neither is a buy/sell instruction.")
                f_row(inspector, 3, "UP / DN", "SIDE VISITED", possibleColor, font, "UP visits the upper oscillator side and returns lower; DN visits lower and returns upper. Side lanes: top = upper visit, bottom = lower visit. Lane coordinates are layout-only. Evidence bounds uses extremum bounds, not measured ticks.")
                f_row(inspector, 4, "R / P", "REQUIRED / POSSIBLE", panelText, font, "Signed extrema describe the selected K-D or K-level metric. Nonnegative depths measure excess beyond the margin; unresolved depth has a zero lower bound.")
                f_row(inspector, 5, "All evidence", "AUDIT MODE", panelText, font, "Choose All evidence (audit) to bypass repetition and spacing. Match marker selection applies the identical current-bar selection to event notifications, including Show marks.")
                f_row(inspector, 6, "Not a replay", "NO TICK ORDER / COUNT", boundaryColor, font, "A same-side revisit is not proof that a particular ta.crossover alert fired. Cross functions reference the preceding chart bar. No intrabar timestamps, trade fills or alert deliveries are reconstructed.")
                f_row(inspector, 7, "Use / limit", "AUDIT PAST OHLC\nNOT FUTURE PERFORMANCE", panelText, font, "Use the study to separate known versus unresolved excursions in close-only charts. EXCLUDED is not trend quality. There is no tested profitability or win-rate claim.")
            f_row(inspector, 8, "Marks [" + str.tostring(markHistory) + "b]", str.tostring(drawnCount) + "/" + str.tostring(eligibleCount) + " | hidden " + str.tostring(omittedCount) + "\n" + modeShort, panelText, font, "Drawn/all eligible events in the exact visible chart-bar window. Hidden includes repetition, spacing and Show marks. Plot Style visibility changed manually in TradingView cannot be detected by Pine.")
            f_row(inspector, 9, "Event alerts", alertShort + "\nSTATE: " + stateAlertMode, panelText, font, "Alert routing is independent of the inspector's visibility. Select Any alert() function call for descriptive messages, or a static event condition, not both unless duplicates are intended. Updating inputs/code does not update existing alert snapshots.")


// -------------------- Explicit closed-bar notifications --------------------
// The dynamic route includes direction, signed extrema, depth and source-bar time.
// Only one call per close even when an optional state notice coincides with an event.
if barstate.isconfirmed and dynamicMessages and (eventNotification or stateNotification)
    string body = "Stochastic Intrabar Evidence | " + syminfo.tickerid + " | TF " + timeframe.period + "\nCLOSED BAR " + timeZone + " open/close:\n" + f_bar_range(time, time_close) + "\nRelation " + relationName + " | margin " + f_num(margin) + " oscillator pts."
    if eventNotification
        body := body + "\nOPPOSITE VISIT: " + f_visit(visitSide) + " " + f_result(revisitCode, sameSide) + ". Open/close: " + f_side(metricOpen) + "/" + f_side(metricClose) + ". Signed extreme R/P: " + f_signed(oppositeRequired) + "/" + f_signed(oppositePossible) + ". Beyond margin R/P: " + f_depth(requiredDepth) + "/" + f_depth(possibleDepth) + " pts. Event scope: " + eventAlertScope + "."
    if stateNotification
        body := body + "\nOPTIONAL STATE ONLY: above " + f_name(aboveCode) + ", below " + f_name(belowCode) + ". May be implied by endpoints alone; not a new-excursion signal."
    alert(body + "\nRetrospective OHLC evidence. Not a trade, tick replay, cross-function history or performance forecast.", alert.freq_once_per_bar_close)

// Alternate static route. Direction +1=upper visit, -1=lower visit.
// {{time}} is the chart bar OPEN time, not the excursion time. Use dynamic messages
// for named relation, configured timezone, closed-bar timestamp and rounded depth.
alertcondition(barstate.isconfirmed and eventNotification and forcedRevisit, "Selected required opposite-side visit", "Stochastic Intrabar Evidence | {{ticker}} | {{interval}} | bar open {{time}}. REQUIRED visit. Direction +1 upper/-1 lower: {{plot(\"Visit direction: +1 upper -1 lower\")}}. Signed required/possible extremes: {{plot(\"Opposite extreme required\")}} / {{plot(\"Opposite extreme possible\")}}. Retrospective OHLC evidence, not a trade or tick-alert replay.")
alertcondition(barstate.isconfirmed and eventNotification and possibleRevisit, "Selected unresolved opposite-side visit", "Stochastic Intrabar Evidence | {{ticker}} | {{interval}} | bar open {{time}}. UNRESOLVED visit, not a known event. Direction +1 upper/-1 lower: {{plot(\"Visit direction: +1 upper -1 lower\")}}. Signed required/possible extremes: {{plot(\"Opposite extreme required\")}} / {{plot(\"Opposite extreme possible\")}}. Retrospective OHLC evidence, not a trade or tick-alert replay.")
````
