# ROC Momentum - Pace and Sensitivity

- url: https://www.tradingview.com/script/HHeZPCyn-ROC-Momentum-Pace-and-Sensitivity/
- type: indicator
- pine_id: PUB;d6a592b196134a67b0279341d70d2fe3
- version: 1.0

## Description

ROC Momentum - Pace and Sensitivity is an open-source Rate of Change research indicator that separates new price movement from changes in the historical comparison base. It keeps ordinary ROC visible, then examines which observed returns support its current sign and how that sign changes under explicitly defined removal and expiry scenarios.

A rising ROC does not necessarily mean that the newest price rose. An older negative return leaving the comparison window can also lift ROC. This indicator makes that distinction visible without replacing ROC with an opaque composite score.

The tool is intended for descriptive momentum research. It does not produce buy/sell instructions, forecast prices, estimate winning probabilities, execute orders or claim a profitable trading edge.

Getting started

Use standard chart bars and begin with ROC overview. The main line describes the whole-window return; the bottom strip describes confirmed recent-segment pace. The default readout shows ROC, confirmed pace, new-price contribution, expiring-base contribution and their combined change.

Change View to inspect plotted research. Change Readout page to inspect Sensitivity, Cluster stress, Path stress, Return details, Diagnostics or Legend.

Defaults are Close source, N=21 bars for ROC, H=1 bar for observed attribution, K=5 bars for hypothetical expiry, B=3 consecutive moves for block removal, and g=0 log bp/bar for future-path stress. N ranges from 3 to 600. H, K and B are independent inputs, each capped at N; effective values appear in the readout or its tooltip. These are research starting points, not optimized trading parameters.

Default visual language

The primary line is unsmoothed arithmetic ROC: green for positive, pink for negative, and neutral for numerically near-zero net return.

The default bottom strip describes recent-segment pace: green for upward acceleration, cyan for upward easing, pink for downward acceleration, orange for downward easing, and purple for steady or near-zero pace. These states compare recent and middle segments, not the one-bar slope of ROC. Positive whole-window ROC can coexist with Down accelerating because the recent segment may be falling while an earlier gain remains in the window.

The main line can instead follow confirmed pace or use one color. The strip can instead show the replacement driver: blue Price-led, yellow Expiry-led, violet Mixed or no meaningful change, and orange Offsetting. Custom colors are available.

Markers, glow and the omission line are off in the default overview but remain optional. Line widths, fills, contrast, table position, text size, precision and right padding are adjustable. Input and plot values stay out of the title's status line.

Seven display views

ROC overview: ordinary ROC with the selected state strip and compact attribution readout.

Removal sensitivity: actual ROC versus zeroing the largest direction-aligned return. The optional minimum/maximum range covers all individual omissions, not a confidence or prediction interval.

Segment pace: recent, middle and oldest mean log returns per bar. Middle is dashed; oldest is dotted.

Window replacement: actual H-bar ROC change, a blue new-price histogram and a yellow expiring-base line. Contributions add to the observed change in arithmetic percentage points.

Price-held baseline: actual ROC versus keeping the source at its observed H-bars-ago value while its comparison base advances. Optional shading separates these retrospective quantities.

Expiry requirements: average future log-return conditions for preserving today's ROC or reaching zero ROC after K bars. These are conditions at each observation, not forecasts on future bars.

Gap and body: total log return split into previous-Close-to-Open and Open-to-Close contributions. Requires Close and valid positive Open data.

Each plotted view uses one consistent unit. Arithmetic percent, changes in percentage points, log percentage points and log bp/bar are different units. Readout tooltips explain the fields and additional values.

ROC and segment pace

For positive source prices P:
ROC[t] = 100 * (P[t] / P[t-N] - 1).

One-bar log return in basis points:
r[t] = 10000 * log(P[t] / P[t-1]).

The N-bar log return is the sum of N one-bar returns. Divide log basis points by 100 for log percentage points; convert a cumulative log-bp value x to arithmetic percent using 100 * (exp(x/10000) - 1).

The N-bar window is partitioned into three adjacent segments. Extra bars go to newer segments, and each segment is divided by its own bar count. The default pace-change deadband is 5% of mean absolute one-bar movement; the near-zero pace deadband is 2%. Numerical floors also apply. These are adjustable descriptive filters, not statistical tests.

Acceleration is recent-minus-middle pace divided by the distance between segment centers, in log bp/bar squared. Three-segment ordering is available in tooltips, the Data Window and alerts.

A new categorical pace state normally needs two consecutive closed bars with the same raw classification. Persistent changes have one extra confirmation bar; interrupted changes may never confirm. The first valid state initializes immediately. A failed core check resets the filter. Confirmation=1 removes the extra delay. Numerical ROC and pace are never smoothed or shifted by this setting.

Observed price and expiry attribution

The attribution span H measures a change that has already happened. The indicator compares ROC now with ROC H bars ago.

Let:
G = P[t-H] / P[t-N-H]
a = P[t] / P[t-H]
b = P[t-N-H] / P[t-N]

The current gross return is G*a*b. The contributions are:

New price = 50 * G * (a-1) * (1+b)
Expiring base = 50 * G * (b-1) * (1+a)

Their sum equals ROC[t] - ROC[t-H], in arithmetic percentage points. The multiplicative interaction is shared equally between the two factors, equivalent to averaging their marginal contributions over the two application orders. This is an explicit allocation convention, not proof of a unique economic cause or evidence of order flow.

For H=1, the change in the window's log return is the newest return minus the return that just left the window. Larger H compares the multi-bar endpoints directly rather than summing previously allocated one-bar percentages.

Price-led and Expiry-led use absolute contribution shares. The default dominance threshold is 65%. When neither contribution meets it, the label is Mixed. Numerically cancelling changes are labelled Offsetting, while negligible factor changes are labelled No change. Mixed does not mean the two contributions have the same sign. Price/ROC conflict identifies a change in ROC that opposes the H-bar price return, including a numerically flat price return, because the comparison base changed.

For a simple mathematical example, consider prices 100, 98, 99, 101, 101 and N=3. ROC changes from +1.00% to about +3.0612% even though the newest price does not move. New-price contribution is zero; the advancing comparison base explains the increase. This illustrates the mechanism, not a trading result.

Price-held baseline

The baseline is:

Held ROC[t] = 100 * (P[t-H] / P[t-N] - 1).

Actual ROC minus Held ROC measures the recent price effect at the current comparison base. Held ROC minus ROC[t-H] measures the base-only change. These two sequential differences add to the observed H-bar ROC change.

This attribution order differs from the symmetric allocation in Window replacement. The two new-price measures can differ without either being incorrect. They must not be treated as independent confirming signals or interchanged under the same definition. The baseline supplies a visual comparison for the same price-history question, not a new data source.

Endpoint expiry requirements

For a horizon K no greater than N, divide the current log-return window into the oldest K returns that will leave it and the returns that will remain. Call their cumulative log returns Outgoing and Retained.

After K new bars:

Future N-bar log return = Retained + unknown future K-bar log return.

To preserve today's exact ROC, the unknown future cumulative log return must equal Outgoing. To reach zero ROC, it must equal -Retained. Dividing either quantity by K gives the average log bp/bar displayed in Expiry requirements. The readout also converts the cumulative conditions into arithmetic percent and reports ROC under a flat-source assumption.

These are endpoint identities. Equal individual future returns are not required: any future sequence with the same cumulative log return reaches the same endpoint. Above the mathematical zero boundary gives positive ROC; below it gives negative ROC. A negative preserve-ROC requirement is possible when the outgoing block was negative.

The two requirement lines are related algebraically: their difference is the current N-bar log return divided by K. They are not independent signals. Neither is an expected return, recommended holding period, target price or claim about what the market will do.

Single-move and arbitrary removal stress

An omission replaces an observed one-bar log return with zero. It does not delete its timestamp, shorten the window or identify a real economic cause.

The one-move range evaluates every individual omission. The largest direction-aligned omission gives the comparison line. When the current net return is numerically flat, there is no nonzero sign to erase and that directional comparison is unavailable.

The Sensitivity page extends the question to multiple moves. Returns aligned with the current net direction are sorted from largest to smallest. The first cumulative removal that eliminates the current sign gives the minimum number of moves required. Removing opposing returns cannot improve this minimum-cardinality result. Outcomes after exactly two and exactly three aligned omissions are also reported when enough such moves exist.

For example, a minimum count of three means no one- or two-move removal can erase the sign under the script's tolerance, but a targeted three-move removal can. This describes dependence on observed history, not resilience to future losses or a continuation probability.

Contiguous-block stress

The Cluster stress page restricts removal to one uninterrupted block. Opposing moves inside that block are also zeroed. This distinguishes dependence on isolated large moves from dependence on a concentrated run of adjacent moves.

The readout compares the arbitrary minimum count with the shortest consecutive block. Equal shortest blocks select the most recent one. Displayed ages are relative to the selected snapshot; age zero is its newest move.

A separate fixed-B calculation tests all N-B+1 possible B-move blocks and reports the minimum and maximum resulting ROC. A numerically flat current return has no sign-erasure count, but these fixed-block outcomes remain defined.

For example, 80,80,80,-40,-40,-40 and 80,-40,80,-40,80,-40 log bp contain the same moves and have the same current ROC. Both have an arbitrary minimum-erasure count of two, but their shortest contiguous erasures contain two and three moves respectively. These are constructed examples of temporal clustering, not trading-performance evidence.

Flat-source expiry and constant-pace paths

The flat-source expiry test assumes all new future returns are zero. Existing returns leave the window oldest first. It reports the first future bar count at which the current sign becomes zero, numerically near zero or opposite. The original sign can return later. By N bars, all original returns have expired; eventual zero is an identity, not a prediction.

Path stress distinguishes the K-th future close from every intermediate close. Here the assumption is stronger than an endpoint average: the source earns exactly g log bp on EACH of the next K bars.

At future step j:

Hypothetical window log return = Retained[j] + j*g.

For a currently positive sign, the mathematical All-close zero boundary is the maximum of -Retained[j]/j over j=1..K. For a negative sign, it is the minimum. Beyond the unrounded boundary in the appropriate direction, the mathematical sign is maintained at all those closes; equality touches zero at a binding horizon. These conditions do not follow merely from achieving the same final average return with a different path.

The readout gives Zero at K (math), All-close zero boundary, Scenario end ROC, First loss (tolerance), and the weakest signed margin with its future bar number. A positive signed margin means the original mathematical sign; a negative margin means the opposite sign.

The mathematical boundary and numerical classification are deliberately different. The sign-loss test treats a signed margin within 0.000001 log bp of zero as a loss, using the script's normalized numerical comparison. Thus, a very small mathematically positive margin can still count as numerical sign loss. A ~ prefix marks a rounded boundary display, not an exact executable cutoff. Changing text precision never changes the underlying classification.

With observed returns 150,-150,90 log bp and K=3, a hypothetical +10 log bp on every new bar produces positive terminal ROC but loses the original positive sign on the first future bar. The mathematical all-close boundary is +60 log bp/bar. This example demonstrates why endpoint and path conditions are separate questions.

The source and all inputs to these hypothetical calculations are known at the observation. No actual future prices are accessed, and no forecast price path is drawn on future chart bars.

Why the diagnostics add information

Consider three six-move histories in log bp, oldest first:

A: 20,20,20,20,20,20
B: 80,-40,80,-40,80,-40
C: -40,80,-40,80,-40,80

All have current ROC of about +1.2072% and the same three two-bar mean paces. Yet their arbitrary erasure counts are 6,2,2; their first flat-source sign losses are 6,3,6 bars; and their preserve-ROC requirements for K=3 are 20,40,0 log bp/bar.

This demonstrates information that a single current ROC value and those segment averages do not distinguish. It does not mean the complete historical ROC curves are identical, the mathematics is proprietary, or the calculations predict subsequent returns.

Concentration and gap/body details

Equivalent absolute-return bars = (sum of absolute log returns)^2 / sum of squared log returns. Equal nonzero absolute moves give N; one isolated move gives one; a completely flat window is displayed as zero. This is a concentration measure, not an independent sample size, statistical reliability score or probability.

Largest-move share divides the largest absolute log return by the sum of absolute log returns.

For Close, each move also splits into log(Open/previous Close) and log(Close/Open). These gap and body contributions add to total log return. Gap means the bridge between consecutive chart bars, not necessarily overnight. The quantities are log percentage points, not arithmetic percent. Return details retains these supporting diagnostics without adding more lines to the overview.

Historical inspection, realtime behavior and alerts

The table does not follow the crosshair. Enable Inspect a historical timestamp to select the last loaded, closed bar whose CLOSE time is no later than the As-of timestamp. The tooltip identifies that bar and its timezone. A timestamp before eligible history gives an unavailable message, not a later observation.

Inspection changes the table to AS OF, not the historical plots or live alert logic. Removal, cluster and path scans are latest/as-of snapshots, not complete historical series or an event-outcome backtest.

Display closed bars only defaults to on: the forming bar is blank and the table uses a closed observation. Off permits intrabar changes in raw values and snapshots. Pace confirmation and alerts still require bar close. Thus the table can differ from the chart's live price header.

Eight alert conditions cover ROC crossing above/below zero, confirmed pace changing, one-move sensitivity appearing, sign retention under every individual omission returning, three-segment ordering becoming rising/falling, and an expiry-driven price/ROC conflict appearing.

Alerts require valid basic calculations and a confirmed bar. Zero-crossing and tolerance-based sensitivity events have different definitions. Neither inspection nor hypothetical scenarios create forecast alerts. Marker spacing/history settings affect markers, not alert conditions. All events are descriptive, not trade instructions.

Diagnostics and numerical presentation

Core checks cover continuous return identities. Snapshot checks cover alignment and P01-P08: input prices, endpoint/sum agreement, individual omissions, arbitrary minimum removal, chronological expiry, endpoint requirements, contiguous blocks and constant-pace paths. Thirteen deterministic examples run at initialization, including mathematical-boundary versus numerical-tolerance cases.

Basic check failures suppress research lines, research fills, strips, exports and events. Valid ordinary ROC remains separate. Snapshot-specific failures suppress snapshot results and direct the readout to diagnostics; they do not alone invalidate otherwise valid core history. Diagnostic residuals stay visible.

The Data Window has 32 continuous outputs, including status and residuals. Snapshot-only counts are not misrepresented as historical series. Small nonzero table values use extra digits or scientific notation instead of appearing as exact zero.

PASS and CLOSED are internal labels, not TradingView certifications. Arithmetic consistency does not establish predictive power or profitable trading.

Scope and limitations

Use standard chart bars with positive prices. Non-standard charts are disabled. Missing/non-positive observations invalidate affected windows rather than being skipped. Attribution needs N+H valid return intervals; gap/body also needs valid Open values.

Durations count chart bars, not calendar time. For sources other than Close, hypothetical assumptions concern that selected series. Changing source, timeframe, session, history or parameters changes the research question. Related transformations of the same prices are not independent evidence.

Percentage conversion has an extreme-range guard at absolute natural-log magnitude 100; out-of-range percentage results are unavailable, not clipped. Numerical tolerances and rounding matter near boundaries. Closed-bar handling cannot prevent historical data revisions.

There are no external requests, imported libraries, higher-timeframe lookahead, negative plot offsets, pivot backdating, access gates or orders. The script does not automatically detect divergences, optimize strategies or estimate trading performance.

Its contribution is an integrated study of the finite ROC window: incoming movement, expiring history, retained movement and dependence on selected returns. Familiar ROC, pace colors, concentration and gap/body arithmetic support this purpose rather than being presented as inventions. Related mathematics may exist elsewhere; no worldwide uniqueness or trading-performance superiority is claimed.

The source is published under the Mozilla Public License 2.0.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG_Group
//@version=6
indicator("ROC Momentum - Pace and Sensitivity", overlay = false, precision = 3, max_bars_back = 2000, explicit_plot_zorder = true)

// Revision 4.1: distinguish mathematical path-zero boundaries from numerical
// sign-loss classification. Preserve v4 calculations, visuals and all features.
// Existing readable ROC/pace visuals and previous research are retained.
// Original implementation from elementary return arithmetic; no imports.
// Descriptive calculations and hypothetical stresses, NOT trade signals.
// No future data, negative offsets, orders, or statistical success claims.
// The full title is used intentionally; there is no abbreviated shorttitle.

// =========================== INPUTS ===========================
const string G1 = "01 - Calculation"
const string G2 = "02 - Display"
const string G3 = "03 - Inspection and events"
const string G4 = "04 - Custom colors"

string srcName = input.string("Close", "Price source", options = ["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4"], group = G1, display = display.none, tooltip = "Positive prices only. Gap/body decomposition is available only for Close. Other sources describe changes in that selected price series.")
int n = input.int(21, "ROC lookback", minval = 3, maxval = 600, group = G1, display = display.none, tooltip = "Three adjacent segments partition this exact window. Extra bars go to the newer segments. All durations are chart bars, not calendar time.")
int blockInput = input.int(3, "Fixed contiguous block: B moves", minval = 1, maxval = 600, group = G1, display = display.none, tooltip = "For the selected snapshot, zero every possible consecutive B-move block in turn. Effective B=min(input,N). Timestamps are retained. This is a stress of observed history, not removal of actual trading days.")
float scenarioPace = input.float(0.0, "Hypothetical future pace: log bp/bar", minval = -1000.0, maxval = 1000.0, step = 1.0, group = G1, display = display.none, tooltip = "Path stress ONLY: assume exactly this log return on EACH of the next K bars. Zero means a flat selected source. Terminal ROC, intermediate sign loss and the weakest signed margin are hypothetical, never forecasts.")
int spanInput = input.int(1, "Attribution span: H bars", minval = 1, maxval = 600, group = G1, display = display.none, tooltip = "Decompose the observed H-bar change in ROC. Effective H is min(this setting, ROC lookback), printed in the readout. H=1 reproduces one-bar replacement.")
int horizonInput = input.int(5, "Expiry requirement horizon: K bars", minval = 1, maxval = 600, group = G1, display = display.none, tooltip = "Effective K is min(this setting, ROC lookback). The requirements are arithmetic boundaries under unknown future returns, NOT predicted returns. No future prices are read.")
float changeTolerance = input.float(5.0, "Pace-change tolerance (%)", minval = 0, maxval = 100, step = 0.5, group = G1, display = display.none, tooltip = "Deadband as a percentage of the mean absolute one-bar log return. It is not a statistical significance threshold.")
float flatTolerance = input.float(2.0, "Near-zero pace tolerance (%)", minval = 0, maxval = 100, step = 0.5, group = G1, display = display.none)
int confirmBars = input.int(2, "Pace confirmation bars", minval = 1, maxval = 5, group = G1, display = display.none, tooltip = "The strip and confirmed pace state change only after this many consecutive CLOSED bars share a raw state. Default 2 adds a one-bar confirmation delay. Actual ROC and segment values are never smoothed.")
float dominantShare = input.float(65.0, "Change-driver dominance (%)", minval = 51, maxval = 95, step = 1, group = G1, display = display.none, tooltip = "Absolute contribution share required to label a ROC change price-led or expiry-led. An arithmetic description, not a probability or causal claim.")
bool closedOnly = input.bool(true, "Display closed bars only", group = G1, display = display.none, tooltip = "The forming bar is blank by default. Disable for live raw values. Pace confirmation and all alerts still require bar close. Historical inspection always uses closed bars.")

string view = input.string("ROC overview", "View", options = ["ROC overview", "Removal sensitivity", "Segment pace", "Window replacement", "Price-held baseline", "Expiry requirements", "Gap and body"], group = G2, display = display.none, tooltip = "ROC and price-held baseline: arithmetic %. Pace and requirements: log bp/bar. Replacement: CHANGE in arithmetic percentage points. Gap/body: log percentage points. One unit per view. New snapshot-only stresses are under Readout page.")
string colorMode = input.string("ROC sign", "ROC main-line color", options = ["ROC sign", "Confirmed pace", "Single color"], group = G2, display = display.none, tooltip = "Default: green above zero, pink below zero. Pace colors are separated into the bottom strip. Confirmed pace coloring intentionally describes recent pace, not whole-window ROC sign.")
bool overviewReference = input.bool(false, "Show omission line in overview", group = G2, display = display.none)
bool showReference = input.bool(true, "Show comparison in research views", group = G2, display = display.none, tooltip = "Sensitivity: largest aligned omission. Baseline: source frozen at its H-bars-ago value. Pace: middle segment. Replacement: expiry contribution. Requirements: zero boundary. Gap/body: gap contribution.")
bool showEnvelope = input.bool(false, "Show one-bar omission range", group = G2, display = display.none, tooltip = "ROC views only. Exact minimum/maximum after zeroing one observed return. Not a prediction band or confidence interval.")
bool showArea = input.bool(true, "Show faint ROC-to-zero fill", group = G2, display = display.none)
bool showBaselineFill = input.bool(true, "Fill actual / price-held baseline", group = G2, display = display.none, tooltip = "Only the price-held baseline view. Disable to keep both lines without shading their difference.")
bool showComparisonFill = input.bool(false, "Fill main/comparison difference", group = G2, display = display.none)
bool showPaceStrip = input.bool(true, "Show bottom state strip", group = G2, display = display.none, tooltip = "ROC views only. Green: up accelerating. Cyan: up easing. Pink: down accelerating. Orange: down easing. Purple: steady or near zero.")
string stripMode = input.string("Confirmed pace", "Bottom strip meaning", options = ["Confirmed pace", "Replacement driver"], group = G2, display = display.none, tooltip = "Replacement driver: blue price-led, yellow expiry-led, violet mixed, orange offsetting. The main ROC line is unchanged.")
bool showGlow = input.bool(false, "Show subtle line glow", group = G2, display = display.none)
bool showZero = input.bool(true, "Show zero guide", group = G2, display = display.none)
int mainWidth = input.int(3, "Main line width", minval = 1, maxval = 5, group = G2, display = display.none)
int fillAlpha = input.int(92, "Fill transparency", minval = 80, maxval = 98, group = G2, display = display.none)
string theme = input.string("Auto contrast", "Color theme", options = ["Auto contrast", "Vivid dark", "Light contrast", "Custom"], group = G2, display = display.none)
bool showPanel = input.bool(true, "Show five-metric readout", group = G2, display = display.none)
string panelPage = input.string("Follow view", "Readout page", options = ["Follow view", "Sensitivity", "Cluster stress", "Path stress", "Expiry requirements", "Return details", "Diagnostics", "Legend"], group = G2, display = display.none, tooltip = "Cluster stress adds consecutive-block dependence. Path stress checks an explicit constant-pace future through every one of K closes. These pages are latest/as-of snapshots, NOT historical plot series. Diagnostics separates base, snapshot and extension checks.")
string panelPos = input.string("Top right", "Readout position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = G2, display = display.none)
string numberMode = input.string("Adaptive", "Readout number precision", options = ["Adaptive", "2 decimals", "4 decimals", "6 decimals"], group = G2, display = display.none, tooltip = "Adaptive uses more digits for small contributions. Any nonzero value that would round to zero uses scientific notation instead. Display formatting never changes calculations or thresholds.")
string panelSize = input.string("Normal", "Readout text size", options = ["Small", "Normal", "Large"], group = G2, display = display.none)
int rightPad = input.int(2, "Readout right padding (%)", minval = 0, maxval = 10, group = G2, display = display.none)

bool inspect = input.bool(false, "Inspect a historical timestamp", group = G3, display = display.none)
int inspectTime = input.time(timestamp("01 Jan 2025 00:00 +0000"), "As-of timestamp", group = G3, display = display.none, active = inspect, tooltip = "The readout uses the last loaded bar whose CLOSE time is at or before this timestamp. It never uses a bar that closes after the selected time. Plots and alerts are unchanged.")
string markerMode = input.string("Off", "Event markers", options = ["Off", "Expiry conflict", "One-bar sensitivity", "ROC zero crossing", "Pace change"], group = G3, display = display.none)
int markerCooldown = input.int(6, "Minimum bars between markers", minval = 1, maxval = 100, group = G3, display = display.none, tooltip = "Visual filtering only. It does not suppress alert conditions or change calculations.")
int markerHistory = input.int(300, "Marker display history", minval = 50, maxval = 5000, group = G3, display = display.none)

color customUp = input.color(#42F5AC, "Positive / up accelerating", group = G4, display = display.none, active = theme == "Custom")
color customUpSlow = input.color(#41D8FF, "Up easing", group = G4, display = display.none, active = theme == "Custom")
color customDown = input.color(#FF55AD, "Negative / down accelerating", group = G4, display = display.none, active = theme == "Custom")
color customDownSlow = input.color(#FFAD4D, "Down easing", group = G4, display = display.none, active = theme == "Custom")
color customSteady = input.color(#AB9DFF, "Steady / oldest pace", group = G4, display = display.none, active = theme == "Custom")
color customRef = input.color(#FFD15C, "Comparison / expiry", group = G4, display = display.none, active = theme == "Custom")
color customNew = input.color(#42BAFF, "New-price / body", group = G4, display = display.none, active = theme == "Custom")
color customText = input.color(#F0F5FF, "Text / single-color line", group = G4, display = display.none, active = theme == "Custom")
color customPanel = input.color(#111827, "Readout background", group = G4, display = display.none, active = theme == "Custom")

// =========================== NUMERICAL HELPERS ===========================
// All internal return arithmetic uses LOG BASIS POINTS (log return * 10000).
// Pine rounds float operands during comparisons. Compare dimensionless ratios
// around 1 rather than testing 1e-12-sized raw log returns directly.
const float ZERO_BP = 0.000001
const float AUDIT_BP = 0.0001
const float MAX_LOG = 100.0

f_pos(float x) =>
    not na(x) and math.sign(x) == 1.0

f_state(float x, float tolerance) =>
    float z = x / tolerance
    na(z) ? 0 : z > 1.0 ? 1 : z < -1.0 ? -1 : 0

f_near(float x, float y, float tolerance) =>
    not na(x) and not na(y) and math.abs(x - y) / tolerance <= 1.0

f_em1(float x) =>
    // Avoid cancellation in exp(x)-1 for small x. Six-term Taylor polynomial.
    math.abs(x) < 0.001 ? x * (1.0 + x * (0.5 + x * (1.0 / 6.0 + x * (1.0 / 24.0 + x * (1.0 / 120.0 + x / 720.0))))) : math.exp(x) - 1.0

f_pct(float bp) =>
    not na(bp) and math.abs(bp) / 10000.0 <= MAX_LOG ? 100.0 * f_em1(bp / 10000.0) : na

f_number(float x, bool signedValue) =>
    string result = "n/a"
    if not na(x)
        float magnitude = math.abs(x)
        int digits = numberMode == "2 decimals" ? 2 : numberMode == "4 decimals" ? 4 : numberMode == "6 decimals" ? 6 : magnitude >= 1.0 ? 2 : magnitude >= 0.01 ? 4 : 6
        string mask = digits == 2 ? "0.00" : digits == 4 ? "0.0000" : "0.000000"
        string zeroText = digits == 2 ? "0.00" : digits == 4 ? "0.0000" : "0.000000"
        string bodyText = str.tostring(magnitude, mask)
        if math.sign(magnitude) == 1.0 and bodyText == zeroText
            int power = int(math.floor(math.log10(magnitude)))
            float mantissa = magnitude / math.pow(10.0, power)
            bodyText := str.tostring(mantissa, "0.000") + "e" + str.tostring(power)
        string signText = math.sign(x) == -1.0 ? "-" : signedValue and math.sign(x) == 1.0 ? "+" : ""
        result := signText + bodyText
    result

f_num(float x) =>
    f_number(x, false)

f_signed(float x) =>
    f_number(x, true)

f_pass(bool x) =>
    x ? "PASS" : "FAIL"

f_phase(int p) =>
    switch p
        1 => "Up accelerating"
        2 => "Up easing"
        3 => "Down accelerating"
        4 => "Down easing"
        5 => "Up steady"
        6 => "Down steady"
        => "Near-zero pace"

f_sequence(int s) =>
    s == 1 ? "Recent > Middle > Oldest" : s == -1 ? "Recent < Middle < Oldest" : s == 2 ? "Three similar paces" : "Mixed pace sequence"

f_driver(int d) =>
    d == 1 ? "Price-led" : d == 2 ? "Expiry-led" : d == 3 ? "Mixed" : d == 4 ? "Offsetting" : "No change"

float luma = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
bool light = theme == "Light contrast" or (theme == "Auto contrast" and luma > 150)
bool custom = theme == "Custom"

color cUp = custom ? customUp : light ? #008C57 : #42F5AC
color cUpSlow = custom ? customUpSlow : light ? #007FAD : #41D8FF
color cDown = custom ? customDown : light ? #C51A72 : #FF55AD
color cDownSlow = custom ? customDownSlow : light ? #AD6100 : #FFAD4D
color cSteady = custom ? customSteady : light ? #6B50AD : #AB9DFF
color cRef = custom ? customRef : light ? #946900 : #FFD15C
color cNew = custom ? customNew : light ? #1672BA : #42BAFF
color cText = custom ? customText : light ? #182638 : #F0F5FF
color cPanel = custom ? customPanel : light ? #F1F5FA : #111827

f_phaseColor(int p) =>
    p == 1 ? cUp : p == 2 ? cUpSlow : p == 3 ? cDown : p == 4 ? cDownSlow : cSteady

// =========================== CONTINUOUS CORE ===========================
float src = switch srcName
    "Open" => open
    "High" => high
    "Low" => low
    "HL2" => hl2
    "HLC3" => hlc3
    "OHLC4" => ohlc4
    => close

int h = math.min(spanInput, n)
int bSize = math.min(blockInput, n)
int kH = math.min(horizonInput, n)
int base = int(math.floor(n / 3.0))
int rem = n % 3
int nr = base + (rem > 0 ? 1 : 0)
int nm = base + (rem > 1 ? 1 : 0)
int no = base

float logP = f_pos(src) ? math.log(src) : na
bool validStep = not na(logP) and not na(logP[1])
float rBP = validStep ? 10000.0 * (logP - logP[1]) : na
float workBP = nz(rBP, 0.0)

// Every history-dependent function below executes on every bar.
float validCount = math.sum(validStep ? 1.0 : 0.0, n)
float rollingBP = math.sum(workBP, n)
float rawAbsBP = math.sum(math.abs(workBP), n)
float rawSquaresBP = math.sum(workBP * workBP, n)
float highBP = ta.highest(workBP, n)
float lowBP = ta.lowest(workBP, n)

// A truly motionless window must not inherit rolling-sum roundoff residue.
bool motionless = math.sign(highBP) == 0.0 and math.sign(lowBP) == 0.0
float absBP = motionless ? 0.0 : rawAbsBP
float squaresBP = motionless ? 0.0 : rawSquaresBP

bool ready = chart.is_standard and bar_index >= n and validCount == n and not na(logP[n])
float totalBP = ready ? 10000.0 * (logP - logP[n]) : na
bool rangeOK = ready and math.abs(totalBP) / 10000.0 <= MAX_LOG
float roc = rangeOK ? 100.0 * (src / src[n] - 1.0) : na
int netSign = ready ? f_state(totalBP, ZERO_BP) : 0
bool flatNet = ready and netSign == 0

// Segment endpoints eliminate conditional rolling-sum history references.
float recent = ready ? 10000.0 * (logP - logP[nr]) / nr : na
float middle = ready ? 10000.0 * (logP[nr] - logP[nr + nm]) / nm : na
float oldest = ready ? 10000.0 * (logP[nr + nm] - logP[n]) / no : na
float tolerance = ready ? math.max(ZERO_BP, absBP / n * changeTolerance / 100.0) : na
float flatBand = ready ? math.max(ZERO_BP, absBP / n * flatTolerance / 100.0) : na

int recentSide = f_state(recent, flatBand)
int changeSide = f_state(recent - middle, tolerance)
int olderChangeSide = f_state(middle - oldest, tolerance)
float acceleration = (recent - middle) / ((nr + nm) / 2.0)

int rawPhase = recentSide == 1 ? (changeSide == 1 ? 1 : changeSide == -1 ? 2 : 5) : recentSide == -1 ? (changeSide == -1 ? 3 : changeSide == 1 ? 4 : 6) : 0
int sequence = changeSide == 1 and olderChangeSide == 1 ? 1 : changeSide == -1 and olderChangeSide == -1 ? -1 : changeSide == 0 and olderChangeSide == 0 ? 2 : 0

float omitLowBP = ready ? totalBP - highBP : na
float omitHighBP = ready ? totalBP - lowBP : na
float omitLow = f_pct(omitLowBP)
float omitHigh = f_pct(omitHighBP)
float ex1 = not flatNet and ready ? f_pct(netSign == 1 ? omitLowBP : omitHighBP) : na
bool sensitive = ready and not flatNet and (netSign == 1 ? f_state(omitLowBP, ZERO_BP) <= 0 : f_state(omitHighBP, ZERO_BP) >= 0)

float eqRaw = ready and f_pos(squaresBP) ? absBP * absBP / squaresBP : na
float equivalent = ready ? (na(eqRaw) ? 0.0 : math.min(float(n), math.max(1.0, eqRaw))) : na
float largest = ready ? (f_pos(absBP) ? 100.0 * math.max(math.abs(highBP), math.abs(lowBP)) / absBP : 0.0) : na

// =========================== GAP / BODY ===========================
bool validOHLC = f_pos(open) and f_pos(close) and f_pos(close[1])
float gapStep = validOHLC ? 10000.0 * (math.log(open) - math.log(close[1])) : 0.0
float bodyStep = validOHLC ? 10000.0 * (math.log(close) - math.log(open)) : 0.0
float ohlcCount = math.sum(validOHLC ? 1.0 : 0.0, n)
float gapSum = math.sum(gapStep, n)
float bodySum = math.sum(bodyStep, n)
bool gapReady = ready and srcName == "Close" and ohlcCount == n
float gap = gapReady ? gapSum / 100.0 : na
float body = gapReady ? bodySum / 100.0 : na

// =========================== H-BAR WINDOW REPLACEMENT ===========================
// Current/previous windows overlap because H <= N. Both must be fully valid.
// G=old gross ROC; A=new-price factor; B=changing-base factor.
// New = 50*G*(A-1)*(1+B); Expiry = 50*G*(B-1)*(1+A).
// Sum = ROC[t]-ROC[t-H]. Interaction is shared equally, not causally identified.
bool rollReady = rangeOK and rangeOK[h]
float aLog = rollReady ? logP - logP[h] : na
float bLog = rollReady ? logP[n + h] - logP[n] : na
bool rollRangeOK = rollReady and math.abs(aLog) <= MAX_LOG and math.abs(bLog) <= MAX_LOG
float gross = rollRangeOK ? math.exp(totalBP[h] / 10000.0) : na
float newPP = rollRangeOK ? 50.0 * gross * f_em1(aLog) * (1.0 + math.exp(bLog)) : na
float expiryPP = rollRangeOK ? 50.0 * gross * f_em1(bLog) * (1.0 + math.exp(aLog)) : na
float deltaROC = rollRangeOK ? roc - roc[h] : na
float newBP = rollRangeOK ? aLog * 10000.0 : na
float expiredBP = rollRangeOK ? bLog * 10000.0 : na
float changeBP = newBP + expiredBP
float massPP = math.abs(newPP) + math.abs(expiryPP)
float newShare = rollRangeOK and f_pos(massPP) ? 100.0 * math.abs(newPP) / massPP : na

int driver = not rollRangeOK or (f_state(newBP, ZERO_BP) == 0 and f_state(expiredBP, ZERO_BP) == 0) ? 0 : f_state(changeBP, ZERO_BP) == 0 ? 4 : newShare >= dominantShare ? 1 : newShare <= 100.0 - dominantShare ? 2 : 3
int changeSign = f_state(changeBP, ZERO_BP)
int priceSign = f_state(newBP, ZERO_BP)
bool expiryConflict = rollRangeOK and changeSign != 0 and priceSign != changeSign and f_state(expiredBP, ZERO_BP) == changeSign

// Price-held baseline: hold the numerator at its observed H-bars-ago price
// but let the comparison base advance to its actual current position.
// This is a SEQUENTIAL counterfactual, not the symmetric allocation above.
float baselineBP = rollRangeOK ? 10000.0 * (logP[h] - logP[n]) : na
bool baselineRangeOK = rollRangeOK and math.abs(baselineBP) / 10000.0 <= MAX_LOG
float baselineROC = baselineRangeOK ? f_pct(baselineBP) : na
float versusBaseline = baselineRangeOK ? roc - baselineROC : na
float baseOnlyChange = baselineRangeOK ? baselineROC - roc[h] : na

// =========================== K-BAR EXPIRY REQUIREMENTS ===========================
// After K bars, R_future = retained_log_return + unknown_future_log_return.
// To keep today's ROC: future log return must equal the outgoing K returns.
// To reach zero ROC: future log return must cancel the retained returns.
// These are algebraic boundaries, NOT expected returns or price targets.
float outgoingK = ready ? 10000.0 * (logP[n - kH] - logP[n]) : na
float retainedK = ready ? 10000.0 * (logP - logP[n - kH]) : na
float holdPace = ready ? outgoingK / kH : na
float zeroPace = ready ? -retainedK / kH : na
float flatKROC = f_pct(retainedK)

// =========================== CONTINUOUS AUDITS ===========================
float sumError = ready ? math.abs(rollingBP - totalBP) : na
float segmentError = ready ? math.abs(totalBP - recent * nr - middle * nm - oldest * no) : na
float gapError = gapReady ? math.abs(totalBP - gapSum - bodySum) : 0.0
float replacementErrorBP = rollRangeOK ? math.abs(totalBP - totalBP[h] - changeBP) : 0.0
float requirementError = ready ? math.abs(totalBP - outgoingK - retainedK) : na
float logError = ready ? math.max(math.max(sumError, segmentError), math.max(gapError, math.max(replacementErrorBP, requirementError))) : na
float ppError = rollRangeOK ? math.abs(deltaROC - newPP - expiryPP) : 0.0

bool ppOK = not rollRangeOK or f_near(deltaROC, newPP + expiryPP, 0.000001 * (1.0 + massPP))
bool eqOK = ready and (motionless or (f_pos(squaresBP) and f_pos(absBP) and eqRaw >= 1.0 - 0.000001 and eqRaw <= n + 0.000001))
bool baselineOK = not baselineRangeOK or f_near(baseOnlyChange + versusBaseline, deltaROC, 0.000001 * (1.0 + math.abs(baseOnlyChange) + math.abs(versusBaseline)))
bool coreOK = rangeOK and f_near(logError, 0.0, AUDIT_BP) and ppOK and eqOK and baselineOK

var int heldPhase = 0
var int candidate = -1
var int streak = 0

if barstate.isconfirmed
    if not coreOK
        heldPhase := 0
        candidate := -1
        streak := 0
    else
        streak := candidate == rawPhase ? streak + 1 : 1
        candidate := rawPhase
        if not coreOK[1] or streak >= confirmBars
            heldPhase := rawPhase

// =========================== PURE SNAPSHOT ENGINE ===========================
// No [] history operator, ta.*, or math.sum() inside this engine.
// One immutable-in-use, chronological array owns all N+1 prices in a sample.

// Largest directed block sum among ALL nonempty blocks of at most limit.
// A sliding minimum-prefix queue is an independent minimality audit for P07.
f_best_block(array<float> prefix, int limit) =>
    int m = array.size(prefix) - 1
    array<int> queue = array.new<int>(m + 1, 0)
    int first = 0
    int last = 1
    float best = na
    if limit > 0
        for j = 1 to m
            while first < last and array.get(queue, first) < j - limit
                first += 1
            if first < last
                float candidateSum = array.get(prefix, j) - array.get(prefix, array.get(queue, first))
                best := na(best) ? candidateSum : math.max(best, candidateSum)
            while first < last and math.sign(array.get(prefix, j) - array.get(prefix, array.get(queue, last - 1))) <= 0.0
                last -= 1
            array.set(queue, last, j)
            last += 1
    best

type Probe
    bool dataOK = false
    bool sumOK = false
    bool omissionOK = false
    bool minimumOK = false
    bool expiryOK = false
    bool budgetOK = false
    bool blockOK = false
    bool pathOK = false
    int blockK = na
    int blockStart = na
    int blockEnd = na
    int bottleneck = na
    int scenarioFirst = na
    int scenarioWorstAt = na
    float blockROC = na
    float blockLow = na
    float blockHigh = na
    float pathBoundary = na
    float scenarioEnd = na
    float scenarioWorst = na
    int eraseK = na
    int expiryK = na
    float ex2 = na
    float ex3 = na
    float nextFlat = na
    float residualBP = na
    float expiryResidualBP = na
    string code = "P01"

f_cluster(Probe result, array<float> logs, array<float> moves, int blockLength) =>
    int m = array.size(logs) - 1
    float l0 = array.get(logs, 0)
    float ln = array.get(logs, m)
    float net = 10000.0 * (ln - l0)
    int direction = f_state(net, ZERO_BP)
    float target = math.abs(net)

    // P07: minimum CONTIGUOUS block, including opposing moves inside it.
    // Directed prefix sums + threshold queue: O(N); handles negative moves.
    array<float> prefix = array.new<float>(1, 0.0)
    for j = 0 to m - 1
        array.push(prefix, array.get(prefix, j) + direction * array.get(moves, j))

    if direction != 0
        array<int> queue = array.new<int>(m + 1, 0)
        int front = 0
        int tail = 1
        for j = 1 to m
            float current = array.get(prefix, j)
            while front < tail and f_state(target - (current - array.get(prefix, array.get(queue, front))), ZERO_BP) <= 0
                int start = array.get(queue, front)
                int width = j - start

                // Equal shortest blocks: prefer the most recent block.
                if na(result.blockK) or width <= result.blockK
                    result.blockK := width
                    result.blockStart := start
                    result.blockEnd := j - 1

                front += 1

            while front < tail and math.sign(current - array.get(prefix, array.get(queue, tail - 1))) <= 0.0
                tail -= 1

            array.set(queue, tail, j)
            tail += 1

        if not na(result.blockK)
            float leftLog = array.get(logs, result.blockStart)
            float rightLog = array.get(logs, result.blockEnd + 1)
            float afterBlock = 10000.0 * ((leftLog - l0) + (ln - rightLog))
            result.blockROC := f_pct(afterBlock)

            float bestHere = f_best_block(prefix, result.blockK)
            float bestShorter = f_best_block(prefix, result.blockK - 1)

            result.blockOK := not na(result.eraseK) and result.blockK >= result.eraseK and result.blockK == result.blockEnd - result.blockStart + 1 and f_state(direction * afterBlock, ZERO_BP) <= 0 and f_state(target - bestHere, ZERO_BP) <= 0 and (result.blockK == 1 or f_state(target - bestShorter, ZERO_BP) == 1)
    else
        result.blockOK := true

    // Every fixed-B deletion is checked by a second rolling-move sum.
    float fixedSum = 0.0
    for j = 0 to blockLength - 1
        fixedSum += array.get(moves, j)

    float fixedLow = na
    float fixedHigh = na
    bool fixedOK = true

    for j = 0 to m - blockLength
        if j > 0
            fixedSum += array.get(moves, j + blockLength - 1) - array.get(moves, j - 1)

        float withoutBlock = 10000.0 * ((array.get(logs, j) - l0) + (ln - array.get(logs, j + blockLength)))
        fixedOK := fixedOK and f_near(withoutBlock, net - fixedSum, AUDIT_BP)
        fixedLow := na(fixedLow) ? withoutBlock : math.min(fixedLow, withoutBlock)
        fixedHigh := na(fixedHigh) ? withoutBlock : math.max(fixedHigh, withoutBlock)

    result.blockLow := f_pct(fixedLow)
    result.blockHigh := f_pct(fixedHigh)
    result.blockOK := result.blockOK and fixedOK
    result

f_path(Probe result, array<float> logs, array<float> moves, int horizon, float futurePace) =>
    int m = array.size(logs) - 1
    float l0 = array.get(logs, 0)
    float ln = array.get(logs, m)
    float net = 10000.0 * (ln - l0)
    int direction = f_state(net, ZERO_BP)
    float retained = 10000.0 * (ln - array.get(logs, horizon))

    // P08: endpoint versus EVERY intermediate close under constant g.
    // Positive sign: g must exceed max(-retained[j]/j).
    // Negative sign: g must be below min(-retained[j]/j).
    // These are mathematical zero boundaries, NOT the tolerance-aware test.
    // scenarioFirst separately applies f_state(margin, ZERO_BP) at each close.
    float oldOut = 0.0
    bool scenarioOK = true

    for j = 1 to horizon
        oldOut += array.get(moves, j - 1)
        float remainder = 10000.0 * (ln - array.get(logs, j))
        float bound = -remainder / j
        float futureNet = remainder + j * futurePace
        scenarioOK := scenarioOK and f_near(futureNet, net - oldOut + j * futurePace, AUDIT_BP)

        if direction != 0
            if na(result.pathBoundary) or math.sign(direction * (bound - result.pathBoundary)) == 1.0
                result.pathBoundary := bound
                result.bottleneck := j

            float margin = direction * futureNet

            if na(result.scenarioWorst) or math.sign(margin - result.scenarioWorst) == -1.0
                result.scenarioWorst := margin
                result.scenarioWorstAt := j

            if na(result.scenarioFirst) and f_state(margin, ZERO_BP) <= 0
                result.scenarioFirst := j

        if j == horizon
            result.scenarioEnd := f_pct(futureNet)

    result.pathOK := scenarioOK

    if direction != 0
        float minimumAtBoundary = na

        for j = 1 to horizon
            float remainder = 10000.0 * (ln - array.get(logs, j))
            float margin = direction * (remainder + j * result.pathBoundary)
            minimumAtBoundary := na(minimumAtBoundary) ? margin : math.min(minimumAtBoundary, margin)

        float bindingRemainder = 10000.0 * (ln - array.get(logs, result.bottleneck))
        bool endBoundOK = f_state(direction * (result.pathBoundary + retained / horizon), ZERO_BP) >= 0 and f_near(bindingRemainder + result.bottleneck * result.pathBoundary, 0.0, AUDIT_BP)

        result.pathOK := result.pathOK and f_near(minimumAtBoundary, 0.0, AUDIT_BP) and endBoundOK and not na(result.bottleneck) and ((not na(result.scenarioFirst)) == (f_state(result.scenarioWorst, ZERO_BP) <= 0))

    result

f_probe(array<float> prices, float expectedBP, float expectedLowBP, float expectedHighBP, int horizon, float expectedOutBP, float expectedRetBP, int blockLength, float futurePace) =>
    Probe result = Probe.new()
    int m = array.size(prices) - 1
    array<float> logs = array.new<float>(0)
    bool valid = m >= 1 and horizon >= 1 and horizon <= m and blockLength >= 1 and blockLength <= m and not na(futurePace)

    if m >= 1
        for i = 0 to m
            float price = array.get(prices, i)
            valid := valid and f_pos(price)
            array.push(logs, f_pos(price) ? math.log(price) : na)

    result.dataOK := valid

    if valid
        float l0 = array.get(logs, 0)
        float ln = array.get(logs, m)
        float net = 10000.0 * (ln - l0)
        int direction = f_state(net, ZERO_BP)
        float target = math.abs(net)
        array<float> moves = array.new<float>(0)
        array<float> aligned = array.new<float>(0)
        float rebuilt = 0.0
        float directLow = na
        float directHigh = na

        for i = 0 to m - 1
            float move = 10000.0 * (array.get(logs, i + 1) - array.get(logs, i))
            array.push(moves, move)
            rebuilt += move
            float contribution = direction * move

            if math.sign(contribution) == 1.0
                array.push(aligned, contribution)

            // Rebuild both unaffected price segments, instead of net - move.
            float without = 10000.0 * ((array.get(logs, i) - l0) + (ln - array.get(logs, i + 1)))
            directLow := na(directLow) ? without : math.min(directLow, without)
            directHigh := na(directHigh) ? without : math.max(directHigh, without)

        result.residualBP := math.max(math.abs(net - expectedBP), math.abs(rebuilt - net))
        result.sumOK := f_near(result.residualBP, 0.0, AUDIT_BP)
        result.omissionOK := f_near(directLow, expectedLowBP, AUDIT_BP) and f_near(directHigh, expectedHighBP, AUDIT_BP)

        array.sort(aligned, order.descending)
        float removed = 0.0
        float beforeK = na
        float atK = na
        int count = array.size(aligned)
        bool sortedOK = true

        if direction != 0 and count > 0
            for i = 0 to count - 1
                if i > 0
                    sortedOK := sortedOK and f_state(array.get(aligned, i - 1) - array.get(aligned, i), ZERO_BP) >= 0

                float before = removed
                removed += array.get(aligned, i)

                if na(result.eraseK) and f_state(target - removed, ZERO_BP) <= 0
                    result.eraseK := i + 1
                    beforeK := before
                    atK := removed

                if i == 1
                    result.ex2 := f_pct(net - direction * removed)
                if i == 2
                    result.ex3 := f_pct(net - direction * removed)

        bool oneSensitive = direction != 0 and (direction == 1 ? f_state(directLow, ZERO_BP) <= 0 : f_state(directHigh, ZERO_BP) >= 0)
        result.minimumOK := direction == 0 or (sortedOK and not na(result.eraseK) and f_state(target - beforeK, ZERO_BP) == 1 and f_state(target - atK, ZERO_BP) <= 0 and ((result.eraseK == 1) == oneSensitive))

        float expired = 0.0
        float expiryError = 0.0

        for j = 1 to m
            expired += array.get(moves, j - 1)
            float remaining = 10000.0 * (ln - array.get(logs, j))
            expiryError := math.max(expiryError, math.abs(remaining - (net - expired)))

            if direction != 0 and na(result.expiryK) and f_state(direction * remaining, ZERO_BP) <= 0
                result.expiryK := j

        result.expiryResidualBP := expiryError
        result.expiryOK := f_near(expiryError, 0.0, AUDIT_BP) and (direction == 0 or (not na(result.expiryK) and result.expiryK >= 1 and result.expiryK <= m))
        result.nextFlat := f_pct(10000.0 * (ln - array.get(logs, 1)))

        float retained = 10000.0 * (ln - array.get(logs, horizon))
        float outgoing = 10000.0 * (array.get(logs, horizon) - l0)
        float expiredScan = 0.0

        for j = 0 to horizon - 1
            expiredScan += array.get(moves, j)

        result.budgetOK := f_near(outgoing, expectedOutBP, AUDIT_BP) and f_near(retained, expectedRetBP, AUDIT_BP) and f_near(outgoing, expiredScan, AUDIT_BP) and f_near(retained + outgoing, net, AUDIT_BP)

        result := f_cluster(result, logs, moves, blockLength)
        result := f_path(result, logs, moves, horizon, futurePace)

        result.code := (result.sumOK ? "" : "P02 ") + (result.omissionOK ? "" : "P03 ") + (result.minimumOK ? "" : "P04 ") + (result.expiryOK ? "" : "P05 ") + (result.budgetOK ? "" : "P06 ") + (result.blockOK ? "" : "P07 ") + (result.pathOK ? "" : "P08 ")

        if result.code == ""
            result.code := "PASS"

    result

// Deterministic in-Pine checks, run once. Includes both signs and a flat case.
f_example(array<float> steps) =>
    array<float> prices = array.new<float>(1, 100.0)
    float cumulative = 0.0

    for i = 0 to array.size(steps) - 1
        cumulative += array.get(steps, i)
        array.push(prices, 100.0 * math.exp(cumulative / 10000.0))

    prices

var bool selfOK = true

if barstate.isfirst
    for test = 0 to 6
        array<float> steps = test % 3 == 0 ? array.from(20.0, 20.0, 20.0, 20.0, 20.0, 20.0) : test % 3 == 1 ? array.from(80.0, -40.0, 80.0, -40.0, 80.0, -40.0) : array.from(-40.0, 80.0, -40.0, 80.0, -40.0, 80.0)

        if test >= 3
            for i = 0 to 5
                array.set(steps, i, test == 6 ? 0.0 : -array.get(steps, i))

        float net = test == 6 ? 0.0 : test < 3 ? 120.0 : -120.0
        float lo = net - array.max(steps)
        float hi = net - array.min(steps)
        float testOut = array.get(steps, 0) + array.get(steps, 1) + array.get(steps, 2)

        Probe example = f_probe(f_example(steps), net, lo, hi, 3, testOut, net - testOut, 3, 0.0)
        int expectedK = test % 3 == 0 ? 6 : 2
        int expectedExpiry = test % 3 == 1 ? 3 : 6
        bool countsOK = test == 6 ? na(example.eraseK) and na(example.expiryK) : example.eraseK == expectedK and example.expiryK == expectedExpiry
        int expectedBlock = test % 3 == 0 ? 6 : 3
        bool blockCountOK = test == 6 ? na(example.blockK) : example.blockK == expectedBlock

        selfOK := selfOK and example.code == "PASS" and countsOK and blockCountOK

    // Terminal sign can survive while an earlier hypothetical close fails.
    for side = 0 to 1
        float d = side == 0 ? 1.0 : -1.0
        array<float> steps = array.from(150.0 * d, -150.0 * d, 90.0 * d)

        Probe example = f_probe(f_example(steps), 90.0 * d, 90.0 * d - array.max(steps), 90.0 * d - array.min(steps), 3, 90.0 * d, 0.0, 2, 10.0 * d)

        selfOK := selfOK and example.code == "PASS" and example.blockK == 1 and example.scenarioFirst == 1 and example.bottleneck == 1 and f_near(example.pathBoundary, 60.0 * d, AUDIT_BP) and f_near(example.scenarioWorst, -50.0, AUDIT_BP)

        // Four boundary regressions across the two signs. A positive signed
        // margin can still be numerically neutral: do not equate the two tests.
        for edge = 0 to 1
            float excess = ZERO_BP * (edge == 0 ? 0.5 : 2.0)
            float testPace = example.pathBoundary + d * excess
            Probe boundaryCase = f_probe(f_example(steps), 90.0 * d, 90.0 * d - array.max(steps), 90.0 * d - array.min(steps), 3, 90.0 * d, 0.0, 2, testPace)
            bool expectedClass = edge == 0 ? boundaryCase.scenarioFirst == 1 and f_state(boundaryCase.scenarioWorst, ZERO_BP) == 0 : na(boundaryCase.scenarioFirst) and f_state(boundaryCase.scenarioWorst, ZERO_BP) == 1
            selfOK := selfOK and boundaryCase.code == "PASS" and math.sign(boundaryCase.scenarioWorst) == 1.0 and expectedClass

// Shared fail-closed research gate. Native ROC remains independent.
bool researchOK = coreOK and selfOK

// =========================== ATOMIC SNAPSHOTS ===========================
// A fixed ring receives the current source on EVERY execution. Normal `var`
// rollback makes intrabar writes provisional. Never use varip for this buffer.
int capacity = n + 2
var array<float> priceRing = array.new<float>(capacity, na)
var int head = -1
head := (head + 1) % capacity
array.set(priceRing, head, src)

type Observation
    int index = na
    int closeTime = na
    bool closed = true
    bool ready = false
    bool checked = false
    bool aligned = false
    bool gapReady = false
    bool rollReady = false
    bool baselineReady = false
    bool sensitive = false
    bool conflict = false
    int netSign = 0
    int phase = 0
    int raw = 0
    int sequence = 0
    int driver = 0
    float roc = na
    float ex1 = na
    float lo = na
    float hi = na
    float netBP = na
    float recent = na
    float middle = na
    float oldest = na
    float acceleration = na
    float equivalent = na
    float largest = na
    float gap = na
    float body = na
    float newPP = na
    float expiryPP = na
    float delta = na
    float share = na
    float baseline = na
    float versus = na
    float baseOnly = na
    float holdPace = na
    float zeroPace = na
    float flatK = na
    float logError = na
    float ppError = na
    float count = na

var Observation snap = Observation.new()
var Probe probe = Probe.new()

bool asOfEligible = barstate.isconfirmed and not na(time_close) and (not inspect or time_close <= inspectTime)
bool inspectionBoundary = inspect and not asOfEligible and asOfEligible[1]
int shift = na

if inspect
    if asOfEligible and (barstate.islast or barstate.islastconfirmedhistory)
        shift := 0
    else if inspectionBoundary
        shift := 1
else
    if barstate.islastconfirmedhistory
        shift := 0
    if barstate.islast
        shift := closedOnly and not barstate.isconfirmed ? 1 : 0

if not na(shift) and bar_index >= shift
    // Series lookups occur here against global, continuously evaluated values.
    // The array engine receives no series history or scheduling responsibility.
    snap := Observation.new()
    snap.index := bar_index - shift
    snap.closeTime := time_close[shift]
    snap.closed := shift == 1 or barstate.isconfirmed
    snap.ready := ready[shift]
    snap.checked := coreOK[shift]
    snap.gapReady := gapReady[shift]
    snap.rollReady := rollRangeOK[shift]
    snap.baselineReady := baselineRangeOK[shift]
    snap.sensitive := sensitive[shift]
    snap.conflict := expiryConflict[shift]
    snap.netSign := netSign[shift]
    snap.phase := heldPhase[shift]
    snap.raw := rawPhase[shift]
    snap.sequence := sequence[shift]
    snap.driver := driver[shift]
    snap.roc := roc[shift]
    snap.ex1 := ex1[shift]
    snap.lo := omitLow[shift]
    snap.hi := omitHigh[shift]
    snap.netBP := totalBP[shift]
    snap.recent := recent[shift]
    snap.middle := middle[shift]
    snap.oldest := oldest[shift]
    snap.acceleration := acceleration[shift]
    snap.equivalent := equivalent[shift]
    snap.largest := largest[shift]
    snap.gap := gap[shift]
    snap.body := body[shift]
    snap.newPP := newPP[shift]
    snap.expiryPP := expiryPP[shift]
    snap.delta := deltaROC[shift]
    snap.share := newShare[shift]
    snap.baseline := baselineROC[shift]
    snap.versus := versusBaseline[shift]
    snap.baseOnly := baseOnlyChange[shift]
    snap.holdPace := holdPace[shift]
    snap.zeroPace := zeroPace[shift]
    snap.flatK := flatKROC[shift]
    snap.logError := logError[shift]
    snap.ppError := ppError[shift]
    snap.count := validCount[shift]
    probe := Probe.new()

    if snap.ready
        array<float> sample = array.new<float>(0)

        for j = 0 to n
            int slot = (head - shift - n + j + capacity) % capacity
            array.push(sample, array.get(priceRing, slot))

        float arrayLast = array.get(sample, n)
        float arrayFirst = array.get(sample, 0)

        snap.aligned := f_pos(arrayLast) and f_pos(arrayFirst) and f_near(10000.0 * (math.log(arrayLast) - logP[shift]), 0.0, ZERO_BP) and f_near(10000.0 * (math.log(arrayFirst) - logP[n + shift]), 0.0, ZERO_BP)
        probe := f_probe(sample, snap.netBP, omitLowBP[shift], omitHighBP[shift], kH, snap.holdPace * kH, -snap.zeroPace * kH, bSize, scenarioPace)

// =========================== CLOSED-BAR EVENTS ===========================
bool crossedUp = ta.crossover(totalBP, 0.0)
bool crossedDown = ta.crossunder(totalBP, 0.0)
bool eventReady = researchOK and researchOK[1] and barstate.isconfirmed

bool eventUp = eventReady and crossedUp
bool eventDown = eventReady and crossedDown
bool eventPace = eventReady and heldPhase != heldPhase[1]
bool eventSensitive = eventReady and sensitive and not sensitive[1]
bool eventRetained = eventReady and not sensitive and sensitive[1] and not flatNet
bool eventRising = eventReady and sequence == 1 and sequence[1] != 1
bool eventFalling = eventReady and sequence == -1 and sequence[1] != -1
bool eventExpiry = eventReady and rollRangeOK and rollRangeOK[1] and expiryConflict and not expiryConflict[1]

// =========================== VISUALS ===========================
bool overview = view == "ROC overview"
bool removalView = view == "Removal sensitivity"
bool baselineView = view == "Price-held baseline"
bool rocView = overview or removalView or baselineView
bool paceView = view == "Segment pace"
bool rollView = view == "Window replacement"
bool budgetView = view == "Expiry requirements"
bool gapView = view == "Gap and body"
bool eligible = not closedOnly or barstate.isconfirmed

// Native vs research are separate for ALL lines, fills, strips and exports.
// Snapshot-only failures suppress snapshot metrics, not unrelated history.
bool nativeDraw = ready and rangeOK and eligible
bool researchDraw = nativeDraw and researchOK
bool mainDraw = rocView ? nativeDraw : researchDraw and (not rollView or rollRangeOK) and (not gapView or gapReady)
bool referenceDraw = researchDraw and (not rollView or rollRangeOK) and (not gapView or gapReady) and (not baselineView or baselineRangeOK)
bool refVisible = overview ? overviewReference : showReference

float main = rocView ? roc : paceView ? recent : rollView ? deltaROC : budgetView ? holdPace : totalBP / 100.0
float reference = baselineView ? baselineROC : rocView ? ex1 : paceView ? middle : rollView ? expiryPP : budgetView ? zeroPace : gap
float component = rollView and rollRangeOK ? newPP : gapView and gapReady ? body : na

color signColor = netSign == 0 ? cSteady : netSign == 1 ? cUp : cDown
color paceColor = f_phaseColor(heldPhase)
color driverColor = driver == 1 ? cNew : driver == 2 ? cRef : driver == 4 ? cDownSlow : cSteady
color rocColor = colorMode == "Single color" ? cText : colorMode == "Confirmed pace" and researchOK ? paceColor : signColor
color mainColor = rocView ? rocColor : paceView ? paceColor : budgetView ? cNew : cText
color stripColor = stripMode == "Confirmed pace" ? paceColor : driverColor

pZero = plot(mainDraw and (showZero or (showArea and rocView)) ? 0.0 : na, "Zero guide", color = showZero ? color.new(chart.fg_color, 60) : na, linewidth = 1, display = display.pane)
pLow = plot(researchDraw and (overview or removalView) and showEnvelope ? omitLow : na, "One-bar omission minimum (%)", color = color.new(cRef, 45), linewidth = 1, style = plot.style_linebr, display = display.pane, linestyle = plot.linestyle_dotted)
pHigh = plot(researchDraw and (overview or removalView) and showEnvelope ? omitHigh : na, "One-bar omission maximum (%)", color = color.new(cRef, 45), linewidth = 1, style = plot.style_linebr, display = display.pane, linestyle = plot.linestyle_dotted)

fill(pLow, pHigh, color = researchDraw ? color.new(cRef, fillAlpha) : na, title = "Omission range - not a forecast", fillgaps = false)

plot(researchDraw ? component : na, "New-price or body contribution - view units", color = color.new(cNew, 30), style = plot.style_histogram, linewidth = 3, display = display.pane)
plot(researchDraw and paceView ? oldest : na, "Oldest pace (log bp/bar)", color = cSteady, linewidth = 1, style = plot.style_linebr, display = display.pane, linestyle = plot.linestyle_dotted)
plot(mainDraw and showGlow ? main : na, "Subtle line glow", color = color.new(mainColor, 88), linewidth = mainWidth + 3, style = plot.style_linebr, display = display.pane, editable = false)

pRef = plot(referenceDraw and refVisible ? reference : na, "Comparison - units follow view", color = cRef, linewidth = 1, style = plot.style_linebr, display = display.pane, linestyle = plot.linestyle_dashed)
pMain = plot(mainDraw ? main : na, "Main - units follow view", color = mainColor, linewidth = mainWidth, style = plot.style_linebr, display = display.pane)

fill(pMain, pZero, color = showArea and rocView ? color.new(signColor, fillAlpha) : na, title = "ROC to zero", fillgaps = false)
fill(pMain, pRef, color = referenceDraw and (baselineView ? showBaselineFill : showComparisonFill) and (rocView or paceView) ? color.new(cRef, fillAlpha) : na, title = "Comparison difference", fillgaps = false)

plotshape(researchDraw and rocView and showPaceStrip and (stripMode == "Confirmed pace" or rollRangeOK), "Selected state strip", style = shape.square, location = location.bottom, color = stripColor, size = size.tiny, display = display.pane)

bool chosenEvent = markerMode == "Expiry conflict" ? eventExpiry : markerMode == "One-bar sensitivity" ? eventSensitive : markerMode == "ROC zero crossing" ? eventUp or eventDown : markerMode == "Pace change" ? eventPace : false
var int lastMarker = na
bool paintMarker = researchDraw and mainDraw and chosenEvent and (na(lastMarker) or bar_index - lastMarker >= markerCooldown)

if paintMarker
    lastMarker := bar_index

plotshape(paintMarker ? main : na, "Selected closed-bar event", style = shape.diamond, location = location.absolute, color = cRef, size = size.tiny, show_last = markerHistory, display = display.pane)

// =========================== DATA WINDOW: 32 SERIES ===========================
// No current-only stress is falsely exported as a historical series.
bool out = researchDraw

plot(nativeDraw ? roc : na, "ROC (%)", display = display.data_window)
plot(out ? ex1 : na, "ROC excluding largest aligned move (%)", display = display.data_window)
plot(out ? omitLow : na, "Omission minimum (%)", display = display.data_window)
plot(out ? omitHigh : na, "Omission maximum (%)", display = display.data_window)
plot(out ? recent : na, "Recent pace (log bp/bar)", display = display.data_window)
plot(out ? middle : na, "Middle pace (log bp/bar)", display = display.data_window)
plot(out ? oldest : na, "Oldest pace (log bp/bar)", display = display.data_window)
plot(out ? acceleration : na, "Segment acceleration (log bp/bar^2)", display = display.data_window)
plot(out ? equivalent : na, "Equivalent absolute-return bars - not sample size", display = display.data_window)
plot(out ? largest : na, "Largest absolute-return share (%)", display = display.data_window)
plot(out ? gap : na, "Gap (log percentage points)", display = display.data_window)
plot(out ? body : na, "Body (log percentage points)", display = display.data_window)
plot(out ? totalBP / 100.0 : na, "Total log return (log percentage points)", display = display.data_window)
plot(out ? rawPhase : na, "Raw pace state (0-6; see source)", display = display.data_window)
plot(out ? heldPhase : na, "Confirmed pace state (0-6)", display = display.data_window)
plot(out ? sequence : na, "Sequence (-1 falling, 0 mixed, 1 rising, 2 similar)", display = display.data_window)
plot(out ? (sensitive ? 1 : 0) : na, "One-bar sign sensitivity (1=yes)", display = display.data_window)
plot(out ? newPP : na, "H-bar new-price contribution (ROC pp)", display = display.data_window)
plot(out ? expiryPP : na, "H-bar expiring-base contribution (ROC pp)", display = display.data_window)
plot(out ? deltaROC : na, "Actual H-bar ROC change (pp)", display = display.data_window)
plot(out ? newBP : na, "New H-bar return (log bp)", display = display.data_window)
plot(out ? expiredBP : na, "Expired H-bar effect (log bp)", display = display.data_window)
plot(out ? newShare : na, "New-price absolute contribution share (%)", display = display.data_window)
plot(out and rollRangeOK ? (expiryConflict ? 1 : 0) : na, "ROC change opposes new price (1=yes)", display = display.data_window)

plot(eligible and ready ? logError : na, "Maximum identity residual (log bp)", display = display.data_window, precision = 9)
plot(eligible and ready and rollRangeOK ? ppError : na, "ROC-change residual (pp)", display = display.data_window, precision = 9)
plot(eligible and ready ? (researchOK ? 1 : 0) : na, "Research gate (1=pass)", display = display.data_window)

plot(out ? holdPace : na, "K-bar requirement to preserve ROC (log bp/bar)", display = display.data_window)
plot(out ? zeroPace : na, "K-bar zero-ROC boundary (log bp/bar)", display = display.data_window)
plot(out ? flatKROC : na, "ROC after K bars IF source flat (%)", display = display.data_window)
plot(out and baselineRangeOK ? baselineROC : na, "H-bar price-held baseline ROC (%)", display = display.data_window)
plot(out and baselineRangeOK ? versusBaseline : na, "Actual ROC minus price-held baseline (pp)", display = display.data_window)

// =========================== FIVE-METRIC READOUT ===========================
string anchor = panelPos == "Bottom right" ? position.bottom_right : panelPos == "Top left" ? position.top_left : panelPos == "Bottom left" ? position.bottom_left : position.top_right
string textSize = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal
bool rightSide = panelPos == "Top right" or panelPos == "Bottom right"

var table panel = table.new(anchor, 3, 6, frame_width = 0, border_width = 0)

f_row(int row, string name, string value, color valueColor, string tip) =>
    color bg = row == 0 ? color.new(cSteady, 78) : cPanel
    table.cell(panel, 0, row, name, text_color = cText, bgcolor = bg, text_size = textSize, text_halign = text.align_left, text_formatting = text.format_bold, tooltip = tip)
    table.cell(panel, 1, row, value, text_color = valueColor, bgcolor = bg, text_size = textSize, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = tip)

if barstate.islast
    table.clear(panel, 0, 0, 2, 5)

    bool missing = na(snap.index)
    bool stressesOK = snap.ready and snap.checked and snap.aligned and probe.code == "PASS" and selfOK
    bool invalidView = (gapView and not snap.gapReady) or (rollView and not snap.rollReady) or (baselineView and not snap.baselineReady)
    bool failure = snap.ready and not stressesOK
    bool warning = not chart.is_standard or missing or not snap.ready or failure or invalidView

    if showPanel or warning
        string stamp = missing ? "No eligible bar" : str.format_time(snap.closeTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " / " + syminfo.timezone
        string page = panelPage == "Follow view" ? (removalView ? "Sensitivity" : budgetView ? "Expiry requirements" : paceView ? "Pace" : gapView ? "Components" : baselineView ? "Baseline" : "Attribution") : panelPage

        if failure
            page := "Diagnostics"

        string status = warning ? "CHECK" : inspect ? "AS OF" : snap.closed ? "CLOSED" : "LIVE"
        string heading = page == "Diagnostics" ? "AUDIT v4.1" : page == "Cluster stress" ? "CLUSTERS B=" + str.tostring(bSize) : page == "Path stress" ? "PATH K=" + str.tostring(kH) : page == "Baseline" ? "BASELINE H=" + str.tostring(h) : page == "Sensitivity" ? "SENSITIVITY" : page == "Expiry requirements" ? "REQUIREMENTS K=" + str.tostring(kH) : page == "Pace" ? "PACE: log bp/bar" : page == "Components" ? "GAP / BODY: log pp" : "ROC %"
        string headerTip = "Bar close: " + stamp + "\nBar index: " + str.tostring(snap.index) + ". Source: " + srcName + ".\nN=" + str.tostring(n) + "; attribution H=" + str.tostring(h) + "; requirement K=" + str.tostring(kH) + "; block B=" + str.tostring(bSize) + ".\nSegments=" + str.tostring(nr) + "/" + str.tostring(nm) + "/" + str.tostring(no) + ".\nUse timestamp inspection, not the crosshair, for snapshot stresses. All calculations describe chart bars, not calendar time."

        f_row(0, heading + " | " + str.tostring(n), status, warning ? cRef : cText, headerTip)

        if rightSide and rightPad > 0
            table.cell(panel, 2, 0, "", width = rightPad, bgcolor = color.new(cPanel, 100))

        if not chart.is_standard or missing or not snap.ready
            string reason = not chart.is_standard ? "Use standard candles/bars" : missing ? "No closed bar at selected time" : "Need positive-price history"
            f_row(1, "Status", reason, cRef, headerTip)
            f_row(2, "Valid moves", f_num(snap.count) + " / " + str.tostring(n), cText, "Missing or non-positive observations invalidate the entire contaminated window. No silent skipping.")
        else
            string returnTip = "Arithmetic ROC=" + f_signed(snap.roc) + "%.\nOmit the largest aligned move=" + f_signed(snap.ex1) + "%.\nAll one-move omissions=" + f_signed(snap.lo) + "% to " + f_signed(snap.hi) + "%.\nZero a log return without removing its timestamp. No confidence interval."
            string paceTip = "Recent " + f_signed(snap.recent) + ", middle " + f_signed(snap.middle) + ", oldest " + f_signed(snap.oldest) + " log bp/bar.\nRaw=" + f_phase(snap.raw) + "; confirmed=" + f_phase(snap.phase) + ".\nConfirmation requires " + str.tostring(confirmBars) + " closes; first valid state initializes immediately.\nAcceleration=" + f_signed(snap.acceleration) + " log bp/bar^2.\n" + f_sequence(snap.sequence)
            string attrTip = "Observed H=" + str.tostring(h) + " bar ROC change=" + f_signed(snap.delta) + " pp.\nNew price=" + f_signed(snap.newPP) + "; expiring base=" + f_signed(snap.expiryPP) + " pp. They add to the observed change.\nInteraction is split equally between the two factors; not a causal model.\nNew-price absolute share=" + f_num(snap.share) + "%.\nPrice/ROC direction conflict=" + (snap.conflict ? "YES" : "NO")
            string removalTip = "Minimum number of observed returns to zero to lose the current nonzero sign. Largest direction-aligned returns are selected first. The window is not shortened.\nErase two=" + f_signed(probe.ex2) + "%; erase three=" + f_signed(probe.ex3) + "%. n/a if too few aligned moves.\nTargeted sensitivity of history, not future-shock resistance or predictive confidence."
            string expiryTip = "ASSUMPTION: the selected source stays exactly flat after this observation.\nFirst future bar count where the CURRENT sign is lost; the sign can reappear later. All N bars eventually expire.\nNext-bar hypothetical ROC=" + f_signed(probe.nextFlat) + "%.\nNot a forecast, expected duration, half-life or holding period."
            string budgetTip = "Horizon K=" + str.tostring(kH) + " chart bars.\nPreserve ROC: required future cumulative log return equals the outgoing K-bar log return.\nReach zero: required future cumulative log return cancels the retained log return.\nValues divided by K are average log bp/bar, not assumed or forecast future returns. Above the zero boundary produces positive ROC; below it produces negative ROC.\nNo future prices are read."
            string spreadTip = "Equivalent bars=(sum |log returns|)^2 / sum(log returns^2).\nThis is concentration, NOT independent sample size or probability.\nLargest move=" + f_num(snap.largest) + "% of total absolute movement."
            string gapTip = "Gap bridges previous Close to current Open; body is Open to Close. They add to total log return.\nLog pp is NOT arithmetic percent. Gap is not necessarily overnight. Requires Close and valid positive Open values."
            string diagTip = "P01: input array; P02: endpoint/sum; P03: all one-move omissions; P04: minimal count and one-move agreement; P05: chronological expiry; P06: requirement identity; P07: minimum/fixed contiguous block; P08: all-close boundary/scenario.\nAlignment: array endpoints vs selected global prices.\nCore max residual=" + str.tostring(snap.logError, "0.000000000") + " log bp.\nROC attribution residual=" + str.tostring(snap.ppError, "0.000000000") + " pp.\nSnapshot residual=" + str.tostring(probe.residualBP, "0.000000000") + " log bp.\nExpiry residual=" + str.tostring(probe.expiryResidualBP, "0.000000000") + " log bp.\nCode=" + probe.code + ". Arithmetic checks do not validate trading performance."

            if page == "Diagnostics"
                f_row(1, "Core identities", f_pass(snap.checked), snap.checked ? cText : cRef, diagTip)
                f_row(2, "Alignment / P01 P02", f_pass(snap.aligned and probe.dataOK and probe.sumOK), snap.aligned and probe.dataOK and probe.sumOK ? cText : cRef, diagTip)
                f_row(3, "Omit P03 / count P04", f_pass(probe.omissionOK) + " / " + f_pass(probe.minimumOK), probe.omissionOK and probe.minimumOK ? cText : cRef, diagTip)
                f_row(4, "Expiry P05 / K P06", f_pass(probe.expiryOK) + " / " + f_pass(probe.budgetOK), probe.expiryOK and probe.budgetOK ? cText : cRef, diagTip)
                f_row(5, "Blocks / Path / Self", f_pass(probe.blockOK) + " / " + f_pass(probe.pathOK) + " / " + f_pass(selfOK), probe.blockOK and probe.pathOK and selfOK ? cText : cRef, diagTip + "\nThirteen deterministic cases, including four path-boundary tolerance regressions. Diagnostics are never silently forced to PASS.")

            else if page == "Legend"
                f_row(1, "ROC sign", "Green + / Pink -", cText, returnTip)
                f_row(2, "Pace strip", "Green/cyan up; pink/orange down", cText, paceTip)
                f_row(3, "Driver strip", "Blue price / Yellow expiry", cText, attrTip)
                f_row(4, "Research units", "ROC % / Change pp / Pace log bp", cText, budgetTip)
                f_row(5, "Snapshot", status + " | " + stamp, cText, headerTip)

            else if page == "Cluster stress"
                string clusterTip = "Zero one CONTIGUOUS block, retaining all timestamps and all other returns. Opposing moves inside the block are also zeroed. Minimum length is audited against the maximum sum of EVERY block of any shorter length. Equal shortest blocks: most recent chosen. Ages are relative to this snapshot; newest move is age 0.\nFixed B=" + str.tostring(bSize) + " scans " + str.tostring(n - bSize + 1) + " positions. Bounds are sensitivity outcomes, not price forecasts.\nPost-minimum-block ROC=" + f_signed(probe.blockROC) + "%."
                f_row(1, "ROC", f_signed(snap.roc) + "%", cText, returnTip)
                f_row(2, "Any moves / in a row", snap.netSign == 0 ? "Flat net / n/a" : str.tostring(probe.eraseK) + " / " + str.tostring(probe.blockK), cRef, removalTip + "\n" + clusterTip)
                f_row(3, "Consecutive ages", snap.netSign == 0 ? "n/a" : str.tostring(n - 1 - probe.blockStart) + " to " + str.tostring(n - 1 - probe.blockEnd) + " bars ago", cText, clusterTip)
                f_row(4, "Fixed B: minimum", f_signed(probe.blockLow) + "% ROC", cDown, clusterTip)
                f_row(5, "Fixed B: maximum", f_signed(probe.blockHigh) + "% ROC", cUp, clusterTip)

            else if page == "Path stress"
                string pathTip = "ASSUMPTION: the selected source earns constant log pace g on EACH future bar, not merely an average by K.\nAll-close zero boundary is mathematical: positive current sign requires g above the unrounded boundary; negative current sign requires g below. Equality touches exactly zero at the binding horizon. This condition does NOT include the numerical zero tolerance.\nThe ~ prefix marks a rounded boundary display, NOT an exact executable cutoff. Rounding can hide small differences.\nFirst loss (tolerance) is computed separately at full internal precision using f_state(signed margin, ZERO_BP) at EACH close. Opposite sign and numerical near-zero both count as loss. Tolerance=" + str.tostring(ZERO_BP, "0.000000000") + " log bp; floating-point comparisons apply.\nEven beyond the mathematical boundary, a small positive signed margin can be within tolerance and count as a loss. Positive margin denotes the original MATHEMATICAL sign, not necessarily numerical retention.\nBinding horizon=+" + str.tostring(probe.bottleneck) + " bars. Terminal sign can return after an earlier loss.\nScenario g=" + f_signed(scenarioPace) + " log bp/bar. This is NOT probability, advice or an expected path."

                f_row(1, "Zero at K (math)", "~" + f_signed(snap.zeroPace) + " log bp/bar", cRef, budgetTip + "\nThis is a rounded mathematical zero boundary, not the tolerance-aware sign-loss test. See the next row tooltip.")
                f_row(2, "All-close zero boundary", snap.netSign == 0 ? "Flat net / n/a" : "~" + f_signed(probe.pathBoundary) + " log bp/bar", cNew, pathTip)
                f_row(3, "Scenario end ROC", f_signed(probe.scenarioEnd) + "%", cText, pathTip)
                f_row(4, "First loss (tolerance)", snap.netSign == 0 ? "n/a" : na(probe.scenarioFirst) ? "None through K=" + str.tostring(kH) : "+" + str.tostring(probe.scenarioFirst) + " bars", cText, pathTip)
                f_row(5, "Weakest signed margin", snap.netSign == 0 ? "n/a" : f_signed(probe.scenarioWorst) + " log bp @ +" + str.tostring(probe.scenarioWorstAt), cText, pathTip)

            else if page == "Baseline"
                string baselineTip = "Counterfactual: the source remains at its observed H-bars-ago value while the comparison base advances normally. Baseline=100*(P[t-H]/P[t-N]-1).\nActual-minus-baseline measures new-price impact at the CURRENT base. Base-only change plus that impact equals actual H-bar ROC change. These sequential contributions DIFFER from the symmetric attribution; do not interchange them. No future price, forecast or trade signal."
                f_row(1, "Actual ROC", f_signed(snap.roc) + "%", cText, returnTip)
                f_row(2, "Price-held ROC", snap.baselineReady ? f_signed(snap.baseline) + "%" : "More history / range check", cRef, baselineTip)
                f_row(3, "Actual minus held", f_signed(snap.versus) + " pp", cNew, baselineTip)
                f_row(4, "Base-only change", f_signed(snap.baseOnly) + " pp", cRef, baselineTip)
                f_row(5, "Total H-bar change", f_signed(snap.delta) + " pp", cText, baselineTip)

            else if page == "Sensitivity"
                f_row(1, "ROC / omit 1", f_signed(snap.roc) + "% / " + f_signed(snap.ex1) + "%", cText, returnTip)
                f_row(2, "Erase current sign", snap.netSign == 0 ? "Flat net / n/a" : str.tostring(probe.eraseK) + " / " + str.tostring(n) + " moves", snap.sensitive ? cRef : cText, removalTip)
                f_row(3, "If source stays flat", snap.netSign == 0 ? "Flat net / n/a" : "First loss +" + str.tostring(probe.expiryK) + " bars", cText, expiryTip)
                f_row(4, "Omit 2 / omit 3", f_signed(probe.ex2) + "% / " + f_signed(probe.ex3) + "%", cText, removalTip)
                f_row(5, "Equivalent bars", f_num(snap.equivalent) + " / " + str.tostring(n), cText, spreadTip)

            else if page == "Expiry requirements"
                f_row(1, "To preserve ROC", f_signed(snap.holdPace) + " log bp/bar", cNew, budgetTip)
                f_row(2, "Zero-ROC boundary", f_signed(snap.zeroPace) + " log bp/bar", cRef, budgetTip)
                f_row(3, "If flat for K bars", f_signed(snap.flatK) + "% ROC", cText, budgetTip)
                f_row(4, "Preserve: total return", f_signed(f_pct(snap.holdPace * kH)) + "% over K", cNew, budgetTip)
                f_row(5, "Zero: total return", f_signed(f_pct(snap.zeroPace * kH)) + "% over K", cRef, budgetTip)

            else if page == "Pace"
                f_row(1, "Recent / " + str.tostring(nr), f_signed(snap.recent) + " log bp/bar", f_phaseColor(snap.phase), paceTip)
                f_row(2, "Middle / " + str.tostring(nm), f_signed(snap.middle) + " log bp/bar", cRef, paceTip)
                f_row(3, "Oldest / " + str.tostring(no), f_signed(snap.oldest) + " log bp/bar", cSteady, paceTip)
                f_row(4, "Acceleration", f_signed(snap.acceleration) + " log bp/bar^2", cText, paceTip)
                f_row(5, "Confirmed pace", f_phase(snap.phase), f_phaseColor(snap.phase), paceTip)

            else if page == "Components" or page == "Return details"
                f_row(1, "ROC / total log", f_signed(snap.roc) + "% / " + f_signed(snap.netBP / 100.0) + " log pp", cText, returnTip)
                f_row(2, "Gap contribution", snap.gapReady ? f_signed(snap.gap) + " log pp" : "Close + valid Open required", cRef, gapTip)
                f_row(3, "Body contribution", snap.gapReady ? f_signed(snap.body) + " log pp" : "n/a", cNew, gapTip)
                f_row(4, "Equivalent bars", f_num(snap.equivalent) + " / " + str.tostring(n), cText, spreadTip)
                f_row(5, "Largest move", f_num(snap.largest) + "% of |moves|", cText, spreadTip)

            else
                f_row(1, "ROC", f_signed(snap.roc) + "%", snap.netSign == 1 ? cUp : snap.netSign == -1 ? cDown : cText, returnTip)
                f_row(2, "Confirmed pace", f_phase(snap.phase), f_phaseColor(snap.phase), paceTip)
                f_row(3, "New price / H=" + str.tostring(h), snap.rollReady ? f_signed(snap.newPP) + " pp" : "More history needed", cNew, attrTip)
                f_row(4, "Expiring base / H=" + str.tostring(h), snap.rollReady ? f_signed(snap.expiryPP) + " pp" : "More history needed", cRef, attrTip)
                f_row(5, "ROC change", snap.rollReady ? f_driver(snap.driver) + " " + f_signed(snap.delta) + " pp" : "n/a", snap.conflict ? cRef : cText, attrTip)

// Snapshot tests do not create time-series events. Alerts describe the live
// chart, never the historical inspection or hypothetical future requirements.
alertcondition(eventUp, "ROC crossed above zero", "ROC crossed above zero on a closed bar. {{ticker}} {{interval}}. Descriptive event only.")
alertcondition(eventDown, "ROC crossed below zero", "ROC crossed below zero on a closed bar. {{ticker}} {{interval}}. Descriptive event only.")
alertcondition(eventPace, "Confirmed pace changed", "The confirmed segment-pace state changed. {{ticker}} {{interval}}. Closed bar; not a forecast.")
alertcondition(eventSensitive, "One-bar sign sensitivity appeared", "Zeroing one observed move can remove the current ROC sign. {{ticker}} {{interval}}. Closed bar; sensitivity only.")
alertcondition(eventRetained, "One-bar omission sign became retained", "Every individual one-bar omission retains the current nonzero ROC sign. {{ticker}} {{interval}}. Not a continuation forecast.")
alertcondition(eventRising, "Three-segment pace became rising", "Recent > middle > oldest pace beyond the configured tolerance. {{ticker}} {{interval}}. Closed bar; descriptive only.")
alertcondition(eventFalling, "Three-segment pace became falling", "Recent < middle < oldest pace beyond the configured tolerance. {{ticker}} {{interval}}. Closed bar; descriptive only.")
alertcondition(eventExpiry, "Expiry-driven ROC and price conflict appeared", "ROC change opposed the new-price return over the configured attribution span because the old base expired. {{ticker}} {{interval}}. Closed bar; not a trade instruction.")
````
