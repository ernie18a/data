# Intraday Price Path Signature - London New York Tokyo Windows

- url: https://www.tradingview.com/script/RFsQG2f4-Intraday-Price-Path-Signature-London-New-York-Tokyo-Windows/
- type: indicator
- pine_id: PUB;4afb98071ab942c8941cf86ddfd54e02
- version: 1.0

## Description

Overview

Intraday Price Path Signature is a time-window price-action study for traders who want to examine how price movement develops inside selected intraday focus periods, including windows commonly monitored around the Tokyo/Asia, London and New York opens.

A conventional session highlighter mainly answers when a regional session is active. This indicator addresses a different question: how was price travel distributed and directed inside the selected window?

Each enabled window is divided into four equal clock-time phases, P1 through P4. The script measures the amount, direction and efficiency of price travel in each phase, classifies the completed sequence, and compares its phase concentration with prior occurrences of the same named window.

The result is a compact price-path signature rather than a broad session background, a set of session levels, or a buy/sell signal. It can be used to research London, New York, Tokyo/Asia or custom focus windows sometimes described by traders as kill zones, without assuming that any time window guarantees a particular outcome.

What makes this different

Most session tools focus on time identification through background shading, open/close markers, session ranges or active-session status. This script focuses on the internal formation of price movement inside a narrower research window.

Its main analytical differences are:

- Four-phase decomposition of every enabled window.
- True-range-style gross price travel that includes gaps between consecutive sampled bars.
- Directional-efficiency filtering so a phase is not called upward or downward merely because it finishes slightly above or below its start.
- A deterministic completed-window classification based on path efficiency, direction alignment, phase concentration and direction changes.
- Independent rolling comparisons for each named window and each matching phase.
- A completed phase strip that states the full P1-P4 sequence directly on the chart.
- A fixed panel that keeps live analytical context away from the candle area.

Core calculation

For each bar inside a focus window, gross bar travel is calculated as:

Gross bar travel = max(high - low, abs(high - previous sampled close), abs(low - previous sampled close))

The first sampled bar uses its own high-low range. This is a bar-based, true-range-style approximation of movement. It includes gaps, but it does not reconstruct the exact tick-by-tick path inside a candle.

The accumulated travel is divided among four equal clock-time phases:

Phase share = phase gross travel / completed-window gross travel

A phase share identifies which quarter of the configured time window contained the greatest portion of measured price travel. It is not a volume measure.

Phase direction is filtered by directional efficiency:

Phase directional efficiency = abs(phase close - phase open) / phase gross travel

When efficiency reaches the configurable threshold, the phase is classified as upward or downward according to its net displacement. When it does not, the phase is classified as rotational. This distinguishes an efficient directional move from a phase that travels extensively but finishes near its starting point.

The completed window also receives a path-efficiency value:

Window path efficiency = abs(window close - window open) / completed-window gross travel

Completed path classifications

A completed window is assigned one descriptive classification. When more than one condition is true, the first matching classification in the following priority order is used:

- Persistent rise or Persistent fall: sufficient window path efficiency and enough phase travel aligned with the completed direction.
- Rotational path: the phase sequence contains the configured number of directional changes and does not qualify as persistent.
- Front-loaded rise or Front-loaded fall: the first two phases contain the configured share of total travel.
- Late acceleration up or Late acceleration down: the final two phases contain the configured share of total travel.
- Phase concentration: one phase contains the configured dominant share of total travel.
- Evenly distributed: the difference between the largest and smallest phase shares remains within the configured tolerance.
- Mixed path: no earlier classification is satisfied.

These labels describe the completed structure under the selected thresholds. They are not forecasts, probabilities or trade recommendations.

Reading the completed phase strip

The default chart annotation is a two-line phase strip for each completed focus window. An example is:

● ASIA   P1↑   P2↔   P3↓   P4↑
Front-loaded rise  ·  Peak P2 35.8%

The first line shows the phase sequence:

- P1 through P4 identify the four equal clock-time phases.
- ↑ means the phase completed with sufficient upward directional efficiency.
- ↓ means the phase completed with sufficient downward directional efficiency.
- ↔ means the phase was rotational or did not meet the directional-efficiency threshold.
- · means the phase was not sufficiently observed.

The second line states the completed path classification and identifies the phase containing the largest share of gross price travel. The strip color identifies the configured window. By default, Asia is cyan, London is amber and New York is pink.

Completed strips are anchored to the final bar of their own window and rendered in front of the price chart. Their bodies extend to the left of the anchor so later bars to the right are less likely to pass underneath a historical strip.

The default Auto opposite close placement puts an upward-closing window below its protected price envelope and a downward-closing window above it. Automatic clearance considers the completed-window range, twelve preceding bars, opening and closing gaps, sampled internal gaps, the first bar after completion, local bar range, ATR and a small window-specific lane offset.

This system is designed to reduce candle overlap during normal chart use, including gap conditions. Because labels have a fixed screen-space size while chart scale and zoom remain user-controlled, extreme chart compression can still change the apparent distance between a label and nearby bars. Additional clearance is available in the settings.

Reading the fixed panel

The default bottom-left panel displays only enabled windows and keeps live detail away from the candles.

FOCUS shows the window icon, short code and configured local hours.

STATUS shows whether the window is live, closed or waiting. A live row also shows current completion progress.

PATH identifies the current phase and developing direction sequence while a window is live. After completion, it shows the most recent path classification.

PULSE shows four activity blocks representing the relative gross-price-travel share of P1 through P4. Taller block characters indicate a larger share. PULSE is a price-travel distribution, not volume or order flow.

CTX shows the developing price range during a live window. After completion, it shows the peak phase, its share and, when available, its empirical percentile. A diamond followed by a number is the percentile rank of that peak phase against the same phase of earlier occurrences of the same named window.

Independent historical comparison

Asia P1 is compared only with earlier Asia P1 observations. London P3 is compared only with earlier London P3 observations. New York, London Close and Custom maintain their own independent histories. Data from different named windows or different phase positions is not mixed.

The default rolling baseline contains 24 eligible completed windows and requires at least six prior samples before displaying percentiles. The current completed observation is ranked before it is added to its own history, so it does not inflate its own percentile. Tied values use a mid-rank treatment.

These percentiles are descriptive empirical ranks from the available rolling sample. They are not probabilities of future direction, continuation or reversal.

The following observations are excluded from the rolling baseline:

- A window first encountered after its configured start time because chart history began partway through it.
- A completed window with fewer than the required number of observed phases.
- A window with no measurable gross price travel.
- A window sampled on a chart environment that does not meet the selected timeframe or chart-type requirements.

Default focus windows

Asia Open: 09:00-10:00, Asia/Tokyo, enabled.
London Open: 08:00-10:00, Europe/London, enabled.
New York Open: 09:30-11:00, America/New_York, enabled.
London Close: 15:00-16:30, Europe/London, disabled by default.
Custom Focus: 12:00-13:00, Etc/UTC, disabled by default.

The default day mask is Monday through Friday. Each window has its own IANA timezone, so London and New York follow their selected local daylight-saving rules. These times are configurable research references, not universal exchange, broker or instrument schedules.

Display modes and customization

Phase strip is the publication default. It shows completed phase strips and the fixed panel without broad session shading.

Phase strip + adaptive lens adds a very light live background lens whose hue and transparency respond to the current phase direction and concentration.

Research detail enables optional legacy pulse blocks, block captions and larger research summaries.

Panel only removes bar-anchored chart annotations and leaves the fixed panel.

Users can adjust window names, codes, icons, hours, days, timezones, colors, panel placement, strip clearance, retention limits, analytical thresholds, historical lookback, minimum sample count, visual modes and alerts.

Suggested use

This indicator is intended for intraday research. Five-minute charts generally provide the clearest balance between phase detail and readability. The default maximum timeframe is 15 minutes and can be changed by the user.

Possible research questions include:

- Did most movement occur early or late in the selected window?
- Was the path persistent, rotational, evenly distributed or dominated by one phase?
- Did the largest phase have an ordinary or unusual share relative to recent matching windows?
- Do different instruments show different path signatures around the same local open?
- Does a custom focus period behave differently from the standard Asia, London or New York defaults?

The study can be applied to liquid intraday markets where time-of-day behavior is relevant, including FX, index products, futures, equities and cryptocurrencies. Users should adapt the configured times to the instrument and data feed being studied.

Alerts

Optional informational alerts are available for focus-window start, focus-window completion and unusually high phase concentration relative to the selected historical percentile threshold. Alerts describe an observed state. They are not entry or exit signals.

Limitations and data behavior

- The calculation uses chart bars, not tick data, and cannot reconstruct the exact intrabar route taken by price.
- PULSE measures price travel, not traded volume, liquidity or order flow.
- Historical percentiles depend on the amount and quality of chart history currently available.
- Missing bars, illiquid periods and data-feed differences can change phase sampling.
- Holidays, early closes, exchange-specific breaks and broker-specific schedules are not detected automatically.
- Live panel values develop as new bars arrive and are not final until the window completes.
- Completed phase strips are created from information available when the window ends. The script does not use future bars or lookahead data.
- No higher-timeframe price request is used; calculations are based on the current chart bars and configured local times.
- A standard chart type is required by default. Transformed chart types can alter measured paths and are therefore disabled unless the user overrides the requirement.
- Classification results depend on the selected thresholds. Changing inputs recalculates historical results under the new configuration.
- Automatic label clearance reduces overlap but cannot control every possible screen layout, zoom level or manual chart-scale compression.

What this indicator does not do

- It does not generate buy or sell signals.
- It does not provide entries, exits, targets, stops or position sizing.
- It does not predict the next phase or the next session.
- It does not claim a win rate, accuracy rate or profitability improvement.
- It is not a strategy or a backtest system.
- It is not financial advice.

Use the output as descriptive context alongside independent analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG Group

//@version=6
indicator(
     "Intraday Price Path Signature - London New York Tokyo Windows",
     overlay = true,
     behind_chart = false,
     max_bars_back = 5000,
     max_boxes_count = 300,
     max_labels_count = 200)

// The declaration intentionally omits the `scale` argument. In an overlay
// script, this makes all price-anchored boxes and labels inherit the chart's
// main price scale, so they remain locked to the candles during chart dragging.

//=============================================================================
// Purpose
//=============================================================================
// This indicator divides configurable intraday focus windows into four equal
// clock-time phases. It measures each phase's share of true-range-style price
// travel, net direction, directional efficiency, and percentile versus the
// same phase of prior occurrences of the same named window.
//
// Its default chart visual is one explicit two-line phase strip per completed
// focus window. The first line names P1-P4 and shows each phase direction with
// arrows. The second line states the completed path classification and peak
// concentration. Legacy pulse blocks remain available only as an option.
//
// It is a descriptive market-context study. It does not create trade signals,
// targets, stops, projections, or performance claims.

//=============================================================================
// Design constants
//=============================================================================

const int PHASE_COUNT = 4
const int WINDOW_COUNT = 5

//=============================================================================
// Input groups
//=============================================================================

const string GROUP_GENERAL = "1. General"
const string GROUP_VISUALS = "2. Visuals"
const string GROUP_SIGNATURE = "3. Price path signature"
const string GROUP_HISTORY = "4. Historical comparison"
const string GROUP_ALERTS = "5. Alerts"
const string GROUP_ASIA = "6. Asia open window"
const string GROUP_LONDON = "7. London open window"
const string GROUP_NEW_YORK = "8. New York open window"
const string GROUP_LONDON_CLOSE = "9. London close window"
const string GROUP_CUSTOM = "10. Custom window"

//=============================================================================
// General inputs
//=============================================================================

int maximumTimeframeMinutes = input.int(
     15,
     "Maximum chart timeframe (minutes)",
     minval = 1,
     maxval = 240,
     tooltip = "The study is intended for intraday research. Five-minute charts usually provide the clearest four-phase structure. Sparse windows are excluded from historical baselines.",
     group = GROUP_GENERAL,
     display = display.none)

bool requireStandardChart = input.bool(
     true,
     "Require a standard chart type",
     tooltip = "When enabled, the study remains idle on Heikin-Ashi, Renko, Range, Kagi, Line Break, and Point & Figure charts because their transformed bars can alter the measured price path.",
     group = GROUP_GENERAL,
     display = display.none)

int minimumObservedPhases = input.int(
     4,
     "Minimum observed phases for baseline",
     minval = 2,
     maxval = PHASE_COUNT,
     tooltip = "A completed window must contain at least this many sampled phases before it can enter its rolling historical baseline.",
     group = GROUP_GENERAL,
     display = display.none)

int retainedCompletedWindows = input.int(
     18,
     "Retained completed fingerprints",
     minval = 5,
     maxval = 50,
     tooltip = "Each completed focus window uses four compact fingerprint blocks. Older drawings are removed automatically to keep object use bounded.",
     group = GROUP_GENERAL,
     display = display.none)

int retainedTextWindows = input.int(
     0,
     "Retained research-text fingerprints",
     minval = 0,
     maxval = 20,
     tooltip = "The default ribbon has no text. In Research detail, older fingerprint captions are removed while the geometric fingerprint remains.",
     group = GROUP_GENERAL,
     display = display.none)

int retainedCompletionGlyphs = input.int(
     9,
     "Retained completed phase strips",
     minval = 0,
     maxval = 50,
     tooltip = "Each completed focus window can display one explicit, candle-anchored phase strip with a detailed hover tooltip.",
     group = GROUP_GENERAL,
     display = display.none)

int retainedSummaryLabels = input.int(
     0,
     "Retained research summary labels",
     minval = 0,
     maxval = 30,
     group = GROUP_GENERAL,
     display = display.none)

//=============================================================================
// Visual inputs
//=============================================================================

string visualLayout = input.string(
     "Phase strip",
     "Visual layout",
     options = ["Phase strip", "Phase strip + adaptive lens", "Research detail", "Panel only"],
     tooltip = "Phase strip is the publication default. The chart annotation is one explicit, candle-anchored strip per completed focus window. Phase strip + adaptive lens adds an optional full-height phase tint whose intensity changes with live path concentration. Research detail unlocks legacy block captions and summary labels. Panel only removes all bar-anchored drawings.",
     group = GROUP_VISUALS,
     display = display.none)

bool showFocusPanel = input.bool(
     true,
     "Show fixed price-path panel",
     tooltip = "The fixed panel uses icons, state badges, directional marks, and a four-character activity fingerprint so the analytical detail remains away from candles and the price scale.",
     group = GROUP_VISUALS,
     display = display.none)

string focusPanelPosition = input.string(
     "Bottom left",
     "Price-path panel position",
     options = ["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left"],
     group = GROUP_VISUALS,
     display = display.none)

string focusPanelTextSize = input.string(
     "Normal",
     "Price-path panel text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_VISUALS,
     display = display.none)

int focusPanelTransparency = input.int(
     8,
     "Price-path panel transparency",
     minval = 0,
     maxval = 50,
     group = GROUP_VISUALS,
     display = display.none)

string chartVisualMode = input.string(
     "Phase strip",
     "Chart visual mode",
     options = ["Phase strip", "Pulse blocks", "Phase strip + pulse blocks", "Off"],
     tooltip = "Phase strip is the publication default. It uses one clearly worded, candle-anchored label per completed focus window: P1-P4 directional arrows on the first line and the path classification plus peak phase on the second. Pulse blocks preserves the older geometric research view.",
     group = GROUP_VISUALS,
     display = display.none)

bool showFingerprintRibbon = input.bool(
     true,
     "Allow legacy four-phase pulse blocks",
     tooltip = "Used only when Chart visual mode includes Pulse blocks. The blocks remain available for research, but they are not part of the publication default.",
     group = GROUP_VISUALS,
     display = display.none)

string fingerprintPlacement = input.string(
     "Auto opposite close",
     "Chart annotation placement",
     options = ["Below window", "Above window", "Auto opposite close"],
     tooltip = "Below and Above are stable placements. Auto opposite close places an upward-closing completed window below the full completed-window range and a downward-closing completed window above it. All modes use an automatic clearance corridor to avoid candle overlap.",
     group = GROUP_VISUALS,
     display = display.none)

float fingerprintHeightPercent = input.float(
     12.0,
     "Maximum ribbon height (% of window range)",
     minval = 4.0,
     maxval = 30.0,
     step = 1.0,
     tooltip = "The most concentrated phase can reach this height. Less active phases remain shorter, producing a compact four-column fingerprint.",
     group = GROUP_VISUALS,
     display = display.none)

float fingerprintGapPercent = input.float(
     3.0,
     "Ribbon gap from window (% of range)",
     minval = 0.0,
     maxval = 20.0,
     step = 0.5,
     group = GROUP_VISUALS,
     display = display.none)

int fingerprintBaseTransparency = input.int(
     28,
     "Ribbon base transparency",
     minval = 0,
     maxval = 85,
     group = GROUP_VISUALS,
     display = display.none)

int activeFingerprintEmphasis = input.int(
     10,
     "Live ribbon emphasis",
     minval = 0,
     maxval = 30,
     tooltip = "Reduces transparency on the currently developing phase.",
     group = GROUP_VISUALS,
     display = display.none)

bool showCompletionGlyphs = input.bool(
     true,
     "Show completed phase strips",
     tooltip = "Displays one explicit two-line strip at each completed focus window. Line 1 shows P1-P4 with upward, downward, or rotational arrows. Line 2 names the completed path structure and its peak phase. Hovering reveals the full analytical tooltip.",
     group = GROUP_VISUALS,
     display = display.none)

string completionGlyphSizeInput = input.string(
     "Small",
     "Phase-strip text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_VISUALS,
     display = display.none)

float completionGlyphOffsetPercent = input.float(
     0.0,
     "Additional phase-strip clearance (% of full window range)",
     minval = 0.0,
     maxval = 50.0,
     step = 1.0,
     tooltip = "The phase strip already uses an automatic no-overlap corridor outside the completed window's full high-low range. Increase this only when extra separation is preferred.",
     group = GROUP_VISUALS,
     display = display.none)

bool showAdaptivePhaseLens = input.bool(
     true,
     "Enable adaptive phase lens in supported layouts",
     tooltip = "Unlike static session shading, the lens changes hue and transparency with the current phase's directional efficiency and path concentration. It is disabled in the default Phase strip layout.",
     group = GROUP_VISUALS,
     display = display.none)

int adaptiveLensTransparency = input.int(
     96,
     "Adaptive phase-lens transparency",
     minval = 85,
     maxval = 100,
     group = GROUP_VISUALS,
     display = display.none)

color overlapColor = input.color(
     color.rgb(213, 0, 249),
     "Overlapping-window color",
     group = GROUP_VISUALS,
     display = display.none)

string phaseTextMode = input.string(
     "Off",
     "Research ribbon text",
     options = ["Off", "Direction only", "Direction and share", "Direction share and percentile"],
     tooltip = "Text is available only in Research detail because the publication default deliberately keeps the price area free of small captions.",
     group = GROUP_VISUALS,
     display = display.none)

string phaseTextSizeInput = input.string(
     "Tiny",
     "Research ribbon text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_VISUALS,
     display = display.none)

bool showSummaryLabels = input.bool(
     false,
     "Show research summary labels",
     tooltip = "Large price-anchored labels are disabled by default. The compact signature glyph and fixed panel are intended for normal use.",
     group = GROUP_VISUALS,
     display = display.none)

string summaryDetailMode = input.string(
     "Compact",
     "Research summary detail",
     options = ["Compact", "Detailed"],
     group = GROUP_VISUALS,
     display = display.none)

string summaryTextSizeInput = input.string(
     "Small",
     "Research summary text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_VISUALS,
     display = display.none)

float summaryOffsetPercent = input.float(
     8.0,
     "Research summary offset (% of window range)",
     minval = 0.0,
     maxval = 50.0,
     step = 1.0,
     group = GROUP_VISUALS,
     display = display.none)

color upperDirectionColor = input.color(
     color.rgb(0, 230, 118),
     "Upper-direction accent",
     group = GROUP_VISUALS,
     display = display.none)

color lowerDirectionColor = input.color(
     color.rgb(255, 82, 82),
     "Lower-direction accent",
     group = GROUP_VISUALS,
     display = display.none)

color rotationalDirectionColor = input.color(
     color.rgb(176, 190, 197),
     "Rotational-phase accent",
     group = GROUP_VISUALS,
     display = display.none)

//=============================================================================
// Signature inputs
//=============================================================================

float phaseDirectionalEfficiencyThreshold = input.float(
     0.28,
     "Phase directional-efficiency threshold",
     minval = 0.01,
     maxval = 1.0,
     step = 0.01,
     tooltip = "A phase is described as UP or DOWN only when absolute phase displacement divided by gross phase path reaches this value. Otherwise it is described as ROT.",
     group = GROUP_SIGNATURE,
     display = display.none)

float persistentPathEfficiencyThreshold = input.float(
     0.32,
     "Persistent-window path-efficiency threshold",
     minval = 0.01,
     maxval = 1.0,
     step = 0.01,
     tooltip = "Window path efficiency is absolute window displacement divided by accumulated true-range-style price travel inside the window.",
     group = GROUP_SIGNATURE,
     display = display.none)

float persistentAlignmentThreshold = input.float(
     0.67,
     "Persistent direction alignment",
     minval = 0.50,
     maxval = 1.0,
     step = 0.01,
     tooltip = "Minimum share of total path contributed by phases whose net direction agrees with the completed window direction.",
     group = GROUP_SIGNATURE,
     display = display.none)

float frontLoadedShareThreshold = input.float(
     0.62,
     "Front-loaded first-half share",
     minval = 0.51,
     maxval = 0.90,
     step = 0.01,
     group = GROUP_SIGNATURE,
     display = display.none)

float backLoadedShareThreshold = input.float(
     0.62,
     "Late-acceleration second-half share",
     minval = 0.51,
     maxval = 0.90,
     step = 0.01,
     group = GROUP_SIGNATURE,
     display = display.none)

float dominantPhaseShareThreshold = input.float(
     0.42,
     "Single-phase concentration threshold",
     minval = 0.26,
     maxval = 0.90,
     step = 0.01,
     group = GROUP_SIGNATURE,
     display = display.none)

float evenDistributionTolerance = input.float(
     0.12,
     "Even-distribution max phase spread",
     minval = 0.01,
     maxval = 0.40,
     step = 0.01,
     tooltip = "The difference between the largest and smallest phase shares must remain at or below this value for an evenly distributed classification.",
     group = GROUP_SIGNATURE,
     display = display.none)

int rotationalFlipThreshold = input.int(
     2,
     "Rotational direction-flip threshold",
     minval = 1,
     maxval = 3,
     group = GROUP_SIGNATURE,
     display = display.none)

//=============================================================================
// Historical comparison inputs
//=============================================================================

int historicalLookback = input.int(
     24,
     "Completed windows in each baseline",
     minval = 5,
     maxval = 100,
     tooltip = "Each named window maintains an independent history of its four phase shares. Data is never mixed between the Asia, London, New York, London close, and custom windows.",
     group = GROUP_HISTORY,
     display = display.none)

int minimumBaselineSamples = input.int(
     6,
     "Minimum samples before percentiles",
     minval = 3,
     maxval = 30,
     group = GROUP_HISTORY,
     display = display.none)

string completedHeatMode = input.string(
     "Historical phase percentile",
     "Completed ribbon intensity",
     options = ["Historical phase percentile", "Current phase share", "Uniform"],
     tooltip = "Historical phase percentile changes each completed fingerprint block according to the same phase of prior occurrences of the same named window.",
     group = GROUP_HISTORY,
     display = display.none)

float unusualPhasePercentile = input.float(
     85.0,
     "Unusual concentration percentile",
     minval = 50.0,
     maxval = 100.0,
     step = 1.0,
     tooltip = "Used only by the optional concentration alert and detailed historical context.",
     group = GROUP_HISTORY,
     display = display.none)

//=============================================================================
// Alert inputs
//=============================================================================

bool alertWindowStarts = input.bool(
     false,
     "Alert when a window starts",
     group = GROUP_ALERTS,
     display = display.none)

bool alertWindowCompletes = input.bool(
     false,
     "Alert when a window completes",
     group = GROUP_ALERTS,
     display = display.none)

bool alertUnusualConcentration = input.bool(
     false,
     "Alert when a completed phase is unusually concentrated",
     tooltip = "The alert is factual and descriptive. It is not a trade signal.",
     group = GROUP_ALERTS,
     display = display.none)

//=============================================================================
// Window inputs
//=============================================================================

// Asia open
bool asiaEnabled = input.bool(true, "Enable", inline = "asia_enable", group = GROUP_ASIA, display = display.none)
color asiaColor = input.color(color.rgb(0, 229, 255), "Color", inline = "asia_enable", group = GROUP_ASIA, display = display.none)
string asiaIcon = input.string("●", "Panel and chart icon", group = GROUP_ASIA, display = display.none)
string asiaName = input.string("Asia Open", "Display name", group = GROUP_ASIA, display = display.none)
string asiaCode = input.string("ASIA", "Short code", group = GROUP_ASIA, display = display.none)
string asiaHours = input.session("0900-1000", "Local hours", group = GROUP_ASIA, display = display.none)
string asiaDays = input.string("23456", "Active days", tooltip = "1 = Sunday, 2 = Monday, ... 7 = Saturday.", group = GROUP_ASIA, display = display.none)
string asiaTimezone = input.string("Asia/Tokyo", "IANA timezone", group = GROUP_ASIA, display = display.none)

// London open
bool londonEnabled = input.bool(true, "Enable", inline = "london_enable", group = GROUP_LONDON, display = display.none)
color londonColor = input.color(color.rgb(255, 193, 7), "Color", inline = "london_enable", group = GROUP_LONDON, display = display.none)
string londonIcon = input.string("◆", "Panel and chart icon", group = GROUP_LONDON, display = display.none)
string londonName = input.string("London Open", "Display name", group = GROUP_LONDON, display = display.none)
string londonCode = input.string("LDN", "Short code", group = GROUP_LONDON, display = display.none)
string londonHours = input.session("0800-1000", "Local hours", group = GROUP_LONDON, display = display.none)
string londonDays = input.string("23456", "Active days", tooltip = "1 = Sunday, 2 = Monday, ... 7 = Saturday.", group = GROUP_LONDON, display = display.none)
string londonTimezone = input.string("Europe/London", "IANA timezone", group = GROUP_LONDON, display = display.none)

// New York open
bool newYorkEnabled = input.bool(true, "Enable", inline = "newyork_enable", group = GROUP_NEW_YORK, display = display.none)
color newYorkColor = input.color(color.rgb(255, 64, 129), "Color", inline = "newyork_enable", group = GROUP_NEW_YORK, display = display.none)
string newYorkIcon = input.string("▲", "Panel and chart icon", group = GROUP_NEW_YORK, display = display.none)
string newYorkName = input.string("New York Open", "Display name", group = GROUP_NEW_YORK, display = display.none)
string newYorkCode = input.string("NY", "Short code", group = GROUP_NEW_YORK, display = display.none)
string newYorkHours = input.session("0930-1100", "Local hours", group = GROUP_NEW_YORK, display = display.none)
string newYorkDays = input.string("23456", "Active days", tooltip = "1 = Sunday, 2 = Monday, ... 7 = Saturday.", group = GROUP_NEW_YORK, display = display.none)
string newYorkTimezone = input.string("America/New_York", "IANA timezone", group = GROUP_NEW_YORK, display = display.none)

// London close. Disabled by default to keep the first-load chart uncluttered because it can overlap New York.
bool londonCloseEnabled = input.bool(false, "Enable", inline = "londonclose_enable", group = GROUP_LONDON_CLOSE, display = display.none)
color londonCloseColor = input.color(color.rgb(179, 136, 255), "Color", inline = "londonclose_enable", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseIcon = input.string("■", "Panel and chart icon", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseName = input.string("London Close", "Display name", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseCode = input.string("LCL", "Short code", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseHours = input.session("1500-1630", "Local hours", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseDays = input.string("23456", "Active days", tooltip = "1 = Sunday, 2 = Monday, ... 7 = Saturday.", group = GROUP_LONDON_CLOSE, display = display.none)
string londonCloseTimezone = input.string("Europe/London", "IANA timezone", group = GROUP_LONDON_CLOSE, display = display.none)

// Custom
bool customEnabled = input.bool(false, "Enable", inline = "custom_enable", group = GROUP_CUSTOM, display = display.none)
color customColor = input.color(color.rgb(118, 255, 3), "Color", inline = "custom_enable", group = GROUP_CUSTOM, display = display.none)
string customIcon = input.string("✦", "Panel and chart icon", group = GROUP_CUSTOM, display = display.none)
string customName = input.string("Custom Focus", "Display name", group = GROUP_CUSTOM, display = display.none)
string customCode = input.string("CUS", "Short code", group = GROUP_CUSTOM, display = display.none)
string customHours = input.session("1200-1300", "Local hours", group = GROUP_CUSTOM, display = display.none)
string customDays = input.string("23456", "Active days", tooltip = "1 = Sunday, 2 = Monday, ... 7 = Saturday.", group = GROUP_CUSTOM, display = display.none)
string customTimezone = input.string("Etc/UTC", "IANA timezone", group = GROUP_CUSTOM, display = display.none)

int enabledWindowCount =
     (asiaEnabled ? 1 : 0) +
     (londonEnabled ? 1 : 0) +
     (newYorkEnabled ? 1 : 0) +
     (londonCloseEnabled ? 1 : 0) +
     (customEnabled ? 1 : 0)
int panelRowCount = math.max(enabledWindowCount, 1) + 3
int panelMaxRowIndex = panelRowCount - 1
int panelSpacerRow = panelRowCount - 1

// Collision metrics are evaluated on every bar so completed phase strips can
// reserve space around pre-window candles, opening/closing gaps, and the first
// bar after a focus window without relying on conditionally evaluated TA calls.
float annotationPreWindowHigh = ta.highest(high[1], 12)
float annotationPreWindowLow = ta.lowest(low[1], 12)
float annotationAtr = ta.atr(14)

//=============================================================================
// Utility functions
//=============================================================================

f_clampInt(int value, int minimum, int maximum) =>
    int(math.max(minimum, math.min(maximum, value)))

f_clampFloat(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_textSize(string setting) =>
    setting == "Tiny" ? size.tiny : setting == "Normal" ? size.normal : size.small

f_panelPosition(string setting) =>
    setting == "Top right" ? position.top_right :
     setting == "Middle right" ? position.middle_right :
     setting == "Top left" ? position.top_left :
     setting == "Middle left" ? position.middle_left :
     setting == "Bottom left" ? position.bottom_left : position.bottom_right

f_blendColor(color baseColor, color accentColor, float accentWeight) =>
    float weight = f_clampFloat(accentWeight, 0.0, 1.0)
    int red = int(math.round(color.r(baseColor) * (1.0 - weight) + color.r(accentColor) * weight))
    int green = int(math.round(color.g(baseColor) * (1.0 - weight) + color.g(accentColor) * weight))
    int blue = int(math.round(color.b(baseColor) * (1.0 - weight) + color.b(accentColor) * weight))
    color.rgb(red, green, blue)

f_phaseArrow(int direction) =>
    direction > 0 ? "↑" : direction < 0 ? "↓" : "•"

f_stripPhaseArrow(int direction) =>
    direction > 0 ? "↑" : direction < 0 ? "↓" : "↔"

f_signaturePlainText(string signature, int peakPhase) =>
    string result = "Mixed path"
    if signature == "Persistent upper"
        result := "Persistent rise"
    else if signature == "Persistent lower"
        result := "Persistent fall"
    else if signature == "Rotational sequence"
        result := "Rotational path"
    else if signature == "Front-loaded upper"
        result := "Front-loaded rise"
    else if signature == "Front-loaded lower"
        result := "Front-loaded fall"
    else if signature == "Late acceleration upper"
        result := "Late acceleration up"
    else if signature == "Late acceleration lower"
        result := "Late acceleration down"
    else if signature == "Evenly distributed"
        result := "Evenly distributed"
    else if str.contains(signature, "concentration")
        result := "Phase " + str.tostring(peakPhase + 1) + " concentration"
    else if str.contains(signature, "excluded")
        result := "Excluded sample"
    result

f_shareBlock(float share) =>
    string result = "·"
    if not na(share)
        result := share < 0.08 ? "▁" :
         share < 0.14 ? "▂" :
         share < 0.20 ? "▃" :
         share < 0.26 ? "▄" :
         share < 0.32 ? "▅" :
         share < 0.39 ? "▆" :
         share < 0.47 ? "▇" : "█"
    result

f_signatureIcon(string signature, float openPrice, float closePrice) =>
    string result = "·"
    if signature == "Persistent upper"
        result := "↗"
    else if signature == "Persistent lower"
        result := "↘"
    else if signature == "Rotational sequence"
        result := "⟳"
    else if signature == "Front-loaded upper" or signature == "Front-loaded lower"
        result := "◀"
    else if signature == "Late acceleration upper" or signature == "Late acceleration lower"
        result := "▶"
    else if signature == "Evenly distributed"
        result := "≋"
    else if str.contains(signature, "concentration")
        result := "◉"
    else if signature == "Mixed price path"
        result := "◇"
    else if str.contains(signature, "excluded")
        result := "×"
    else if signature != ""
        result := closePrice > openPrice ? "↗" : closePrice < openPrice ? "↘" : "•"
    result


f_signatureBadgeText(string signature, int peakPhase, float openPrice, float closePrice) =>
    string result = "↔ Setup"
    if signature == "Persistent upper"
        result := "▲ Trend"
    else if signature == "Persistent lower"
        result := "▼ Trend"
    else if signature == "Rotational sequence"
        result := "↔ Rotation"
    else if signature == "Front-loaded upper" or signature == "Front-loaded lower"
        result := "◀ Front"
    else if signature == "Late acceleration upper" or signature == "Late acceleration lower"
        result := "▶ Late"
    else if signature == "Evenly distributed"
        result := "≋ Even"
    else if str.contains(signature, "concentration")
        result := "◉ P" + str.tostring(peakPhase + 1) + " Focus"
    else if signature == "Mixed price path"
        result := "◇ Mixed"
    else if str.contains(signature, "excluded")
        result := "× Excluded"
    result

f_ribbonAbove(string placement, float openPrice, float closePrice) =>
    placement == "Above window" or placement == "Auto opposite close" and closePrice < openPrice

f_sessionDisplay(string sessionHours) =>
    string startHour = str.substring(sessionHours, 0, 2)
    string startMinute = str.substring(sessionHours, 2, 4)
    string endHour = str.substring(sessionHours, 5, 7)
    string endMinute = str.substring(sessionHours, 7, 9)
    startHour + ":" + startMinute + "–" + endHour + ":" + endMinute

f_shortSignature(string signature, int peakPhase, float openPrice, float closePrice) =>
    string result = "· Waiting"
    if signature != ""
        string icon = f_signatureIcon(signature, openPrice, closePrice)
        bool excluded = signature == "Partial window - excluded" or signature == "Sparse phase sample - excluded" or signature == "No measurable path - excluded"
        if signature == "Persistent upper"
            result := icon + " Persistent"
        else if signature == "Persistent lower"
            result := icon + " Persistent"
        else if signature == "Rotational sequence"
            result := icon + " Rotation"
        else if signature == "Front-loaded upper" or signature == "Front-loaded lower"
            result := icon + " Front load"
        else if signature == "Late acceleration upper" or signature == "Late acceleration lower"
            result := icon + " Late accel."
        else if signature == "Evenly distributed"
            result := icon + " Even"
        else if signature == "Mixed price path"
            result := icon + " Mixed"
        else if excluded
            result := icon + " Excluded"
        else
            result := icon + " P" + str.tostring(peakPhase + 1) + " focus"
    result

f_fillTextColor(color baseColor) =>
    float luminance = 0.299 * color.r(baseColor) + 0.587 * color.g(baseColor) + 0.114 * color.b(baseColor)
    luminance >= 155.0 ? color.rgb(15, 23, 42) : color.white

f_percentText(float value) =>
    na(value) ? "n/a" : str.tostring(value * 100.0, "#.0") + "%"

f_percentileText(float value) =>
    na(value) ? "P--" : "P" + str.tostring(int(math.round(value)))

f_parseClockMinute(string sessionHours, bool useEnd) =>
    int offset = useEnd ? 5 : 0
    int parsedHour = int(str.tonumber(str.substring(sessionHours, offset, offset + 2)))
    int parsedMinute = int(str.tonumber(str.substring(sessionHours, offset + 2, offset + 4)))
    parsedHour * 60 + parsedMinute

f_sessionDurationMinutes(string sessionHours) =>
    int startMinute = f_parseClockMinute(sessionHours, false)
    int endMinute = f_parseClockMinute(sessionHours, true)
    int duration = (endMinute - startMinute + 1440) % 1440
    duration == 0 ? 1440 : duration

f_phaseDirection(float phaseOpen, float phaseClose, float grossPath, float efficiencyThreshold) =>
    int result = 0
    if not na(phaseOpen) and not na(phaseClose) and grossPath > 0.0
        float displacement = phaseClose - phaseOpen
        float efficiency = math.abs(displacement) / grossPath
        if efficiency >= efficiencyThreshold
            result := displacement > 0.0 ? 1 : displacement < 0.0 ? -1 : 0
    result

f_directionWord(int direction) =>
    direction > 0 ? "UP" : direction < 0 ? "DOWN" : "ROT"

f_directionColor(int direction, color upperColor, color lowerColor, color rotationalColor) =>
    direction > 0 ? upperColor : direction < 0 ? lowerColor : rotationalColor

f_shareHeatScore(float share) =>
    // Equal four-phase activity maps to 50. Twice the equal share maps to 100.
    f_clampFloat(share * PHASE_COUNT * 50.0, 0.0, 100.0)

f_heatTransparency(int baseTransparency, float heatScore) =>
    float centered = f_clampFloat(heatScore, 0.0, 100.0) - 50.0
    int adjustment = int(math.round(centered / 50.0 * 16.0))
    f_clampInt(baseTransparency - adjustment, 0, 98)

f_percentileRank(array<float> values, float value) =>
    // Midrank handling keeps tied samples centered instead of assigning every tie
    // to the top of its empirical rank group.
    float result = na
    int count = values.size()
    if count > 0 and not na(value)
        int less = 0
        int equal = 0
        for sample in values
            if sample < value
                less += 1
            else if sample == value
                equal += 1
        result := 100.0 * (less + 0.5 * equal) / count
    result

//=============================================================================
// Collection methods
//=============================================================================

method pushLimited(array<float> values, float value, int limit) =>
    if not na(value)
        values.push(value)
        while values.size() > limit
            values.shift()
    values

method keepBox(array<box> boxes, box id, int limit) =>
    if not na(id)
        boxes.push(id)
        while boxes.size() > limit
            box oldBox = boxes.shift()
            oldBox.delete()
    boxes

method keepCaptionBox(array<box> boxes, box id, int limit) =>
    if not na(id)
        boxes.push(id)
        while boxes.size() > limit
            box oldCaptionBox = boxes.shift()
            oldCaptionBox.set_text("")
    boxes

method keepLabel(array<label> labels, label id, int limit) =>
    if not na(id)
        labels.push(id)
        while labels.size() > limit
            label oldLabel = labels.shift()
            oldLabel.delete()
    labels

//=============================================================================
// Per-window state object
//=============================================================================

type ActivityWindow
    string name
    string code
    string icon
    int slot
    bool enabled
    string hours
    string days
    string timezone
    color baseColor
    int startMinute
    int durationMinutes
    bool active = false
    bool partialStart = false
    int startBar = na
    int endBar = na
    int currentPhase = na
    int observedPhaseCount = 0
    int barCount = 0
    float openPrice = na
    float highPrice = na
    float lowPrice = na
    float closePrice = na
    float lastBarHigh = na
    float lastBarLow = na
    float collisionHigh = na
    float collisionLow = na
    float startGap = 0.0
    float completionGap = 0.0
    float completionAtr = na
    float totalGrossPath = 0.0
    float pathEfficiency = na
    float frontShare = na
    float backShare = na
    float alignedShare = na
    float peakShare = na
    int peakPhase = na
    float peakPercentile = na
    int directionFlips = 0
    string signature = ""
    array<float> phaseGrossPath = na
    array<float> phaseOpen = na
    array<float> phaseHigh = na
    array<float> phaseLow = na
    array<float> phaseClose = na
    array<int> phaseBars = na
    array<float> phaseShares = na
    array<float> phasePercentiles = na
    array<box> phaseBoxes = na
    array<float> phase1History = na
    array<float> phase2History = na
    array<float> phase3History = na
    array<float> phase4History = na

method sessionString(ActivityWindow window) =>
    window.hours + ":" + window.days

method isInside(ActivityWindow window) =>
    not na(time(timeframe.period, window.sessionString(), window.timezone))

method localMinute(ActivityWindow window) =>
    hour(time, window.timezone) * 60 + minute(time, window.timezone)

method phaseIndex(ActivityWindow window) =>
    int elapsedMinute = (window.localMinute() - window.startMinute + 1440) % 1440
    int rawPhase = int(math.floor(float(elapsedMinute) / window.durationMinutes * PHASE_COUNT))
    f_clampInt(rawPhase, 0, PHASE_COUNT - 1)

method historyForPhase(ActivityWindow window, int phaseIndex) =>
    array<float> result = window.phase1History
    if phaseIndex == 1
        result := window.phase2History
    else if phaseIndex == 2
        result := window.phase3History
    else if phaseIndex == 3
        result := window.phase4History
    result

method baselineSamples(ActivityWindow window) =>
    window.phase1History.size()

method resetCurrentState(ActivityWindow window) =>
    window.active := true
    // Any first sampled bar that does not begin at the configured clock boundary
    // is treated as partial and kept out of the empirical baseline.
    window.partialStart := window.localMinute() != window.startMinute
    window.startBar := bar_index
    window.endBar := na
    window.currentPhase := na
    window.observedPhaseCount := 0
    window.barCount := 0
    window.openPrice := open
    window.highPrice := high
    window.lowPrice := low
    window.closePrice := close
    window.lastBarHigh := high
    window.lastBarLow := low
    float previousClose = nz(close[1], open)
    float preWindowHigh = nz(annotationPreWindowHigh, high)
    float preWindowLow = nz(annotationPreWindowLow, low)
    window.collisionHigh := math.max(math.max(high, preWindowHigh), math.max(open, previousClose))
    window.collisionLow := math.min(math.min(low, preWindowLow), math.min(open, previousClose))
    window.startGap := math.abs(open - previousClose)
    window.completionGap := 0.0
    window.completionAtr := nz(annotationAtr, math.max(high - low, syminfo.mintick * 20.0))
    window.totalGrossPath := 0.0
    window.pathEfficiency := na
    window.frontShare := na
    window.backShare := na
    window.alignedShare := na
    window.peakShare := na
    window.peakPhase := na
    window.peakPercentile := na
    window.directionFlips := 0
    window.signature := ""
    window.phaseGrossPath := array.new<float>(PHASE_COUNT, 0.0)
    window.phaseOpen := array.new<float>(PHASE_COUNT)
    window.phaseHigh := array.new<float>(PHASE_COUNT)
    window.phaseLow := array.new<float>(PHASE_COUNT)
    window.phaseClose := array.new<float>(PHASE_COUNT)
    window.phaseBars := array.new<int>(PHASE_COUNT, 0)
    window.phaseShares := array.new<float>(PHASE_COUNT, 0.0)
    window.phasePercentiles := array.new<float>(PHASE_COUNT)
    window.phaseBoxes := array.new<box>(PHASE_COUNT)
    window

method createPhaseBox(
     ActivityWindow window,
     int phaseIndex,
     array<box> boxQueue,
     int boxLimit,
     int baseTransparency,
     string textSize) =>
    box phaseBox = box.new(
         left = bar_index,
         top = window.highPrice,
         right = bar_index + 1,
         bottom = window.lowPrice,
         xloc = xloc.bar_index,
         border_color = color.new(window.baseColor, 0),
         border_width = 2,
         border_style = line.style_solid,
         bgcolor = color.new(window.baseColor, baseTransparency),
         text = "",
         text_size = f_textSize(textSize),
         text_color = chart.fg_color,
         text_halign = text.align_center,
         text_valign = text.align_center)
    window.phaseBoxes.set(phaseIndex, phaseBox)
    boxQueue.keepBox(phaseBox, boxLimit)
    phaseBox

method refreshShares(ActivityWindow window) =>
    if window.totalGrossPath > 0.0
        for phaseIndex = 0 to PHASE_COUNT - 1
            float share = window.phaseGrossPath.get(phaseIndex) / window.totalGrossPath
            window.phaseShares.set(phaseIndex, share)
    else
        window.phaseShares.fill(0.0)
    window

method phaseWord(ActivityWindow window, int phaseIndex, float efficiencyThreshold) =>
    string result = "NA"
    if window.phaseBars.get(phaseIndex) > 0
        result := f_directionWord(f_phaseDirection(
             window.phaseOpen.get(phaseIndex),
             window.phaseClose.get(phaseIndex),
             window.phaseGrossPath.get(phaseIndex),
             efficiencyThreshold))
    result

method phaseBoxText(
     ActivityWindow window,
     int phaseIndex,
     string textMode,
     float efficiencyThreshold,
     bool completed,
     int minimumSamples) =>
    string result = ""
    if textMode != "Off"
        string baseText = "P" + str.tostring(phaseIndex + 1) + " " + window.phaseWord(phaseIndex, efficiencyThreshold)
        if textMode == "Direction only"
            result := baseText
        else
            float share = window.phaseShares.get(phaseIndex)
            result := baseText + "\n" + f_percentText(share)
            float percentile = window.phasePercentiles.get(phaseIndex)
            if textMode == "Direction share and percentile" and completed and window.baselineSamples() >= minimumSamples and not na(percentile)
                result += " " + f_percentileText(percentile)
    result

method updatePhaseVisuals(
     ActivityWindow window,
     bool completed,
     int baseTransparency,
     int activeEmphasis,
     string heatMode,
     string textMode,
     string textSize,
     int minimumSamples,
     float efficiencyThreshold,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     color upperColor,
     color lowerColor,
     color rotationalColor) =>
    window.refreshShares()
    int samples = window.baselineSamples()
    float windowRange = math.max(window.highPrice - window.lowPrice, syminfo.mintick * 20.0)
    float maximumHeight = windowRange * maximumHeightPercent / 100.0
    float ribbonGap = windowRange * gapPercent / 100.0
    bool placeAbove = f_ribbonAbove(placement, window.openPrice, window.closePrice)
    float ribbonAnchor = placeAbove ? window.highPrice + ribbonGap : window.lowPrice - ribbonGap

    for phaseIndex = 0 to PHASE_COUNT - 1
        box phaseBox = window.phaseBoxes.get(phaseIndex)
        if not na(phaseBox)
            float share = window.phaseShares.get(phaseIndex)
            float percentile = window.phasePercentiles.get(phaseIndex)
            float heatScore = 50.0
            if completed
                heatScore := heatMode == "Uniform" ? 50.0 : heatMode == "Historical phase percentile" and samples >= minimumSamples and not na(percentile) ? percentile : f_shareHeatScore(share)
            else
                heatScore := f_shareHeatScore(share)

            int transparency = f_heatTransparency(baseTransparency, heatScore)
            if not completed and phaseIndex == window.currentPhase
                transparency := f_clampInt(transparency - activeEmphasis, 0, 98)

            float phaseOpenPrice = window.phaseOpen.get(phaseIndex)
            float phaseClosePrice = window.phaseClose.get(phaseIndex)
            float grossPath = window.phaseGrossPath.get(phaseIndex)
            int direction = f_phaseDirection(phaseOpenPrice, phaseClosePrice, grossPath, efficiencyThreshold)
            color directionColor = f_directionColor(direction, upperColor, lowerColor, rotationalColor)
            color blendedFill = f_blendColor(window.baseColor, directionColor, direction == 0 ? 0.18 : 0.34)

            float relativeActivity = f_clampFloat(share * PHASE_COUNT, 0.0, 2.0)
            float heightScale = window.phaseBars.get(phaseIndex) > 0 ? f_clampFloat(0.18 + relativeActivity * 0.41, 0.18, 1.0) : 0.0
            float blockHeight = math.max(maximumHeight * heightScale, syminfo.mintick * 2.0)
            float blockTop = placeAbove ? ribbonAnchor + blockHeight : ribbonAnchor
            float blockBottom = placeAbove ? ribbonAnchor : ribbonAnchor - blockHeight

            int borderWidth = not completed and phaseIndex == window.currentPhase ? 3 : completed and not na(percentile) and percentile >= 85.0 ? 3 : completed and not na(percentile) and percentile >= 65.0 ? 2 : 1
            string borderStyle = direction == 0 ? line.style_dotted : line.style_solid

            phaseBox.set_top(blockTop)
            phaseBox.set_bottom(blockBottom)
            phaseBox.set_bgcolor(color.new(blendedFill, transparency))
            phaseBox.set_border_color(color.new(directionColor, completed ? 5 : 0))
            phaseBox.set_border_width(borderWidth)
            phaseBox.set_border_style(borderStyle)
            phaseBox.set_text(window.phaseBoxText(phaseIndex, textMode, efficiencyThreshold, completed, minimumSamples))
            phaseBox.set_text_size(f_textSize(textSize))
            phaseBox.set_text_color(f_fillTextColor(blendedFill))
    window

method addCurrentBar(
     ActivityWindow window,
     array<box> boxQueue,
     int boxLimit,
     bool drawBoxes,
     int baseTransparency,
     int activeEmphasis,
     string heatMode,
     string textMode,
     string textSize,
     int minimumSamples,
     float efficiencyThreshold,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     color upperColor,
     color lowerColor,
     color rotationalColor) =>
    int phaseIndex = window.phaseIndex()
    bool hasPriorWindowBar = window.barCount > 0
    float previousWindowClose = hasPriorWindowBar ? window.closePrice : open
    float barGrossPath = hasPriorWindowBar ? math.max(high - low, math.max(math.abs(high - previousWindowClose), math.abs(low - previousWindowClose))) : high - low

    if window.phaseBars.get(phaseIndex) == 0
        window.observedPhaseCount += 1
        window.phaseOpen.set(phaseIndex, hasPriorWindowBar ? previousWindowClose : open)
        window.phaseHigh.set(phaseIndex, high)
        window.phaseLow.set(phaseIndex, low)
        if drawBoxes
            window.createPhaseBox(phaseIndex, boxQueue, boxLimit, baseTransparency, textSize)
    else
        window.phaseHigh.set(phaseIndex, math.max(window.phaseHigh.get(phaseIndex), high))
        window.phaseLow.set(phaseIndex, math.min(window.phaseLow.get(phaseIndex), low))

    window.currentPhase := phaseIndex
    window.highPrice := math.max(window.highPrice, high)
    window.lowPrice := math.min(window.lowPrice, low)
    window.closePrice := close
    window.lastBarHigh := high
    window.lastBarLow := low
    float currentGapReference = nz(close[1], open)
    window.collisionHigh := math.max(window.collisionHigh, math.max(math.max(high, open), currentGapReference))
    window.collisionLow := math.min(window.collisionLow, math.min(math.min(low, open), currentGapReference))
    window.startGap := math.max(window.startGap, math.abs(open - currentGapReference))
    window.totalGrossPath += math.max(barGrossPath, 0.0)
    window.phaseGrossPath.set(phaseIndex, window.phaseGrossPath.get(phaseIndex) + math.max(barGrossPath, 0.0))
    window.phaseClose.set(phaseIndex, close)
    window.phaseBars.set(phaseIndex, window.phaseBars.get(phaseIndex) + 1)
    window.barCount += 1

    box currentBox = window.phaseBoxes.get(phaseIndex)
    if not na(currentBox)
        currentBox.set_right(bar_index + 1)

    if drawBoxes
        window.updatePhaseVisuals(
             false,
             baseTransparency,
             activeEmphasis,
             heatMode,
             textMode,
             textSize,
             minimumSamples,
             efficiencyThreshold,
             placement,
             maximumHeightPercent,
             gapPercent,
             upperColor,
             lowerColor,
             rotationalColor)
    window

method calculatePhasePercentiles(ActivityWindow window, int minimumSamples) =>
    int samples = window.baselineSamples()
    for phaseIndex = 0 to PHASE_COUNT - 1
        float percentile = na
        if samples >= minimumSamples
            array<float> history = window.historyForPhase(phaseIndex)
            percentile := f_percentileRank(history, window.phaseShares.get(phaseIndex))
        window.phasePercentiles.set(phaseIndex, percentile)
    window

method calculateCompletedSignature(
     ActivityWindow window,
     int requiredObservedPhases,
     float phaseEfficiencyThreshold,
     float persistentEfficiencyThreshold,
     float alignmentThreshold,
     float frontThreshold,
     float backThreshold,
     float dominantThreshold,
     float evenTolerance,
     int flipThreshold) =>
    window.refreshShares()

    float totalDisplacement = window.closePrice - window.openPrice
    int overallDirection = totalDisplacement > syminfo.mintick ? 1 : totalDisplacement < -syminfo.mintick ? -1 : 0
    window.pathEfficiency := window.totalGrossPath > 0.0 ? math.abs(totalDisplacement) / window.totalGrossPath : 0.0
    window.frontShare := window.phaseShares.get(0) + window.phaseShares.get(1)
    window.backShare := window.phaseShares.get(2) + window.phaseShares.get(3)

    float largestShare = -1.0
    float smallestShare = 2.0
    int largestPhase = 0
    float alignedPathShare = 0.0
    int flips = 0
    int previousDirectionalPhase = 0

    for phaseIndex = 0 to PHASE_COUNT - 1
        float share = window.phaseShares.get(phaseIndex)
        float grossPath = window.phaseGrossPath.get(phaseIndex)
        float phaseOpenPrice = window.phaseOpen.get(phaseIndex)
        float phaseClosePrice = window.phaseClose.get(phaseIndex)
        int phaseDirection = f_phaseDirection(phaseOpenPrice, phaseClosePrice, grossPath, phaseEfficiencyThreshold)

        if share > largestShare
            largestShare := share
            largestPhase := phaseIndex
        smallestShare := math.min(smallestShare, share)

        if overallDirection != 0 and phaseDirection == overallDirection
            alignedPathShare += share

        if phaseDirection != 0
            if previousDirectionalPhase != 0 and phaseDirection != previousDirectionalPhase
                flips += 1
            previousDirectionalPhase := phaseDirection

    window.alignedShare := alignedPathShare
    window.peakShare := largestShare
    window.peakPhase := largestPhase
    window.peakPercentile := window.phasePercentiles.get(largestPhase)
    window.directionFlips := flips

    string directionSuffix = overallDirection > 0 ? " upper" : overallDirection < 0 ? " lower" : ""
    bool persistent = overallDirection != 0 and window.pathEfficiency >= persistentEfficiencyThreshold and alignedPathShare >= alignmentThreshold
    bool frontLoaded = window.frontShare >= frontThreshold
    bool backLoaded = window.backShare >= backThreshold
    bool concentrated = largestShare >= dominantThreshold
    bool evenlyDistributed = largestShare - smallestShare <= evenTolerance
    bool rotational = flips >= flipThreshold and not persistent

    string result = "Mixed price path"
    if window.partialStart
        result := "Partial window - excluded"
    else if window.observedPhaseCount < requiredObservedPhases
        result := "Sparse phase sample - excluded"
    else if window.totalGrossPath <= 0.0
        result := "No measurable path - excluded"
    else if persistent
        result := "Persistent" + directionSuffix
    else if rotational
        result := "Rotational sequence"
    else if frontLoaded
        result := "Front-loaded" + directionSuffix
    else if backLoaded
        result := "Late acceleration" + directionSuffix
    else if concentrated
        result := "Phase " + str.tostring(largestPhase + 1) + " concentration" + directionSuffix
    else if evenlyDistributed
        result := "Evenly distributed"
    window.signature := result
    window

method phaseSequence(ActivityWindow window, float efficiencyThreshold) =>
    string result = ""
    for phaseIndex = 0 to PHASE_COUNT - 1
        result += (phaseIndex == 0 ? "" : " · ") + window.phaseWord(phaseIndex, efficiencyThreshold)
    result

method phaseStripText(ActivityWindow window, float efficiencyThreshold) =>
    string firstLine = window.icon + " " + window.code + "   "
    for phaseIndex = 0 to PHASE_COUNT - 1
        string separator = phaseIndex == PHASE_COUNT - 1 ? "" : "   "
        if window.phaseBars.get(phaseIndex) > 0
            int direction = f_phaseDirection(
                 window.phaseOpen.get(phaseIndex),
                 window.phaseClose.get(phaseIndex),
                 window.phaseGrossPath.get(phaseIndex),
                 efficiencyThreshold)
            firstLine += "P" + str.tostring(phaseIndex + 1) + f_stripPhaseArrow(direction) + separator
        else
            firstLine += "P" + str.tostring(phaseIndex + 1) + "·" + separator

    string secondLine = f_signaturePlainText(window.signature, window.peakPhase)
    if not na(window.peakPhase) and not na(window.peakShare)
        secondLine += "  ·  Peak P" + str.tostring(window.peakPhase + 1) + " " + f_percentText(window.peakShare)
    firstLine + "\n" + secondLine

method summaryText(ActivityWindow window, string detailMode, float efficiencyThreshold) =>
    string result = window.code + " · " + window.signature
    if detailMode == "Compact"
        result += "\nPeak P" + str.tostring(window.peakPhase + 1) + " " + f_percentText(window.peakShare)
        if not na(window.peakPercentile)
            result += " " + f_percentileText(window.peakPercentile)
    else
        result += "\n" + window.phaseSequence(efficiencyThreshold)
        result += "\nP1 " + f_percentText(window.phaseShares.get(0)) + "  P2 " + f_percentText(window.phaseShares.get(1))
        result += "\nP3 " + f_percentText(window.phaseShares.get(2)) + "  P4 " + f_percentText(window.phaseShares.get(3))
        result += "\nEfficiency " + f_percentText(window.pathEfficiency) + " · flips " + str.tostring(window.directionFlips)
    result

method summaryTooltip(ActivityWindow window, float efficiencyThreshold) =>
    string result = window.name + " price path signature"
    result += "\nClassification: " + window.signature
    result += "\nGross path uses true-range-style bar travel and includes gaps between consecutive bars inside the window."
    result += "\nWindow path efficiency: " + f_percentText(window.pathEfficiency)
    result += "\nFirst-half share: " + f_percentText(window.frontShare)
    result += "\nSecond-half share: " + f_percentText(window.backShare)
    result += "\nAligned path share: " + f_percentText(window.alignedShare)
    result += "\nDirection flips: " + str.tostring(window.directionFlips)
    result += "\nPhase sequence: " + window.phaseSequence(efficiencyThreshold)
    for phaseIndex = 0 to PHASE_COUNT - 1
        result += "\nP" + str.tostring(phaseIndex + 1) + ": " + window.phaseWord(phaseIndex, efficiencyThreshold) + ", share " + f_percentText(window.phaseShares.get(phaseIndex)) + ", " + f_percentileText(window.phasePercentiles.get(phaseIndex))
    result

method signatureGlyphPrice(
     ActivityWindow window,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     float glyphOffsetPercent) =>
    // The protected envelope includes: the full focus-window range, twelve
    // pre-window bars, every sampled gap inside the window, and the first bar
    // after completion. The label body is then oriented away from this envelope.
    float envelopeHigh = math.max(window.highPrice, nz(window.collisionHigh, window.highPrice))
    float envelopeLow = math.min(window.lowPrice, nz(window.collisionLow, window.lowPrice))
    float windowRange = math.max(window.highPrice - window.lowPrice, syminfo.mintick * 20.0)
    float envelopeRange = math.max(envelopeHigh - envelopeLow, windowRange)
    float localRange = math.max(nz(window.lastBarHigh, window.highPrice) - nz(window.lastBarLow, window.lowPrice), syminfo.mintick * 8.0)
    float gapMagnitude = math.max(window.startGap, window.completionGap)
    float volatilityClearance = nz(window.completionAtr, windowRange) * 0.55
    float automaticClearance = math.max(
         envelopeRange * 0.10,
         math.max(
              windowRange * 0.16,
              math.max(
                   localRange * 1.10,
                   math.max(gapMagnitude * 0.40, math.max(volatilityClearance, syminfo.mintick * 12.0)))))
    float manualClearance = envelopeRange * glyphOffsetPercent / 100.0
    float laneClearance = math.max(windowRange, nz(window.completionAtr, windowRange)) * 0.07 * float(window.slot % 3)
    float totalClearance = automaticClearance + manualClearance + laneClearance
    bool placeAbove = f_ribbonAbove(placement, window.openPrice, window.closePrice)
    placeAbove ? envelopeHigh + totalClearance : envelopeLow - totalClearance

method signatureGlyphX(ActivityWindow window) =>
    // The strip's right edge is locked to the final bar of its own completed
    // window. Its entire body extends left into already-known bars, so a later
    // gap or impulse to the right cannot run underneath a historical strip.
    window.endBar

method activeLensColor(
     ActivityWindow window,
     float efficiencyThreshold,
     color upperColor,
     color lowerColor,
     color rotationalColor) =>
    color result = window.baseColor
    if window.active and not na(window.currentPhase)
        float phaseOpenPrice = window.phaseOpen.get(window.currentPhase)
        float phaseClosePrice = window.phaseClose.get(window.currentPhase)
        float grossPath = window.phaseGrossPath.get(window.currentPhase)
        int direction = f_phaseDirection(phaseOpenPrice, phaseClosePrice, grossPath, efficiencyThreshold)
        color accentColor = f_directionColor(direction, upperColor, lowerColor, rotationalColor)
        result := f_blendColor(window.baseColor, accentColor, direction == 0 ? 0.16 : 0.30)
    result

method activeLensTransparency(ActivityWindow window, int baseTransparency) =>
    int result = baseTransparency
    if window.active and not na(window.currentPhase)
        window.refreshShares()
        float heatScore = f_shareHeatScore(window.phaseShares.get(window.currentPhase))
        result := f_heatTransparency(baseTransparency, heatScore)
        result := f_clampInt(result, 86, 100)
    result

method panelProgress(ActivityWindow window) =>
    int elapsedMinute = (window.localMinute() - window.startMinute + 1440) % 1440
    float progress = window.durationMinutes > 0 ? float(elapsedMinute) / window.durationMinutes : 0.0
    f_clampFloat(progress, 0.0, 1.0)

method panelStateText(ActivityWindow window) =>
    string result = "× OFF"
    if window.enabled
        if window.active
            result := "● LIVE " + str.tostring(int(math.round(window.panelProgress() * 100.0))) + "%"
        else
            result := window.signature == "" ? "· WAIT" : "○ CLOSED"
    result

method panelDirectionSequence(ActivityWindow window, float efficiencyThreshold) =>
    string result = ""
    for phaseIndex = 0 to PHASE_COUNT - 1
        string symbol = "·"
        if window.phaseBars.get(phaseIndex) > 0
            int direction = f_phaseDirection(
                 window.phaseOpen.get(phaseIndex),
                 window.phaseClose.get(phaseIndex),
                 window.phaseGrossPath.get(phaseIndex),
                 efficiencyThreshold)
            symbol := f_phaseArrow(direction)
        result += symbol
    result

method panelFingerprintText(ActivityWindow window) =>
    string result = "····"
    if window.barCount > 0
        window.refreshShares()
        result := ""
        for phaseIndex = 0 to PHASE_COUNT - 1
            result += window.phaseBars.get(phaseIndex) > 0 ? f_shareBlock(window.phaseShares.get(phaseIndex)) : "·"
    result

method panelPathText(ActivityWindow window, float efficiencyThreshold) =>
    string result = "—"
    if window.enabled
        if window.active and not na(window.currentPhase)
            int currentDirection = f_phaseDirection(
                 window.phaseOpen.get(window.currentPhase),
                 window.phaseClose.get(window.currentPhase),
                 window.phaseGrossPath.get(window.currentPhase),
                 efficiencyThreshold)
            result := "P" + str.tostring(window.currentPhase + 1) + " " + f_phaseArrow(currentDirection) + "  " + window.panelDirectionSequence(efficiencyThreshold)
        else
            result := f_shortSignature(window.signature, window.peakPhase, window.openPrice, window.closePrice)
    result

method panelContextText(ActivityWindow window) =>
    string result = "—"
    if window.enabled
        if window.active
            float activeRange = math.max(window.highPrice - window.lowPrice, 0.0)
            result := "R " + str.tostring(activeRange, format.mintick)
        else if window.signature != "" and not na(window.peakPhase)
            string rarity = not na(window.peakPercentile) ? "  ◆" + str.tostring(int(math.round(window.peakPercentile))) : ""
            result := "P" + str.tostring(window.peakPhase + 1) + " " + f_percentText(window.peakShare) + rarity
        else
            result := "No sample"
    result

method storeCompletedShares(ActivityWindow window, int historyLimit) =>
    for phaseIndex = 0 to PHASE_COUNT - 1
        array<float> history = window.historyForPhase(phaseIndex)
        history.pushLimited(window.phaseShares.get(phaseIndex), historyLimit)
    window

method finishWindow(
     ActivityWindow window,
     array<box> captionQueue,
     array<label> summaryQueue,
     array<label> glyphQueue,
     int captionLimit,
     int summaryLimit,
     int glyphLimit,
     bool drawBoxes,
     int baseTransparency,
     string heatMode,
     string textMode,
     string textSize,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     bool drawGlyphs,
     string glyphSize,
     float glyphOffsetPercent,
     bool drawSummary,
     string summaryMode,
     string summarySize,
     float summaryOffset,
     int historyLimit,
     int minimumSamples,
     int requiredObservedPhases,
     float phaseEfficiencyThreshold,
     float persistentEfficiencyThreshold,
     float alignmentThreshold,
     float frontThreshold,
     float backThreshold,
     float dominantThreshold,
     float evenTolerance,
     int flipThreshold,
     float concentrationPercentile,
     color upperColor,
     color lowerColor,
     color rotationalColor,
     bool completionAlerts,
     bool concentrationAlerts) =>
    window.active := false
    window.endBar := math.max(window.startBar, bar_index - 1)
    float completionReference = nz(close[1], window.closePrice)
    window.completionGap := math.abs(open - completionReference)
    window.completionAtr := nz(annotationAtr, math.max(window.highPrice - window.lowPrice, syminfo.mintick * 20.0))
    window.collisionHigh := math.max(window.collisionHigh, math.max(math.max(high, open), completionReference))
    window.collisionLow := math.min(window.collisionLow, math.min(math.min(low, open), completionReference))

    window.refreshShares()
    bool baselineEligible = not window.partialStart and window.observedPhaseCount >= requiredObservedPhases and window.totalGrossPath > 0.0
    if baselineEligible
        window.calculatePhasePercentiles(minimumSamples)
    else
        for phaseIndex = 0 to PHASE_COUNT - 1
            window.phasePercentiles.set(phaseIndex, na)
    window.calculateCompletedSignature(
         requiredObservedPhases,
         phaseEfficiencyThreshold,
         persistentEfficiencyThreshold,
         alignmentThreshold,
         frontThreshold,
         backThreshold,
         dominantThreshold,
         evenTolerance,
         flipThreshold)

    if drawBoxes
        window.updatePhaseVisuals(
             true,
             baseTransparency,
             0,
             heatMode,
             textMode,
             textSize,
             minimumSamples,
             phaseEfficiencyThreshold,
             placement,
             maximumHeightPercent,
             gapPercent,
             upperColor,
             lowerColor,
             rotationalColor)

        for phaseIndex = 0 to PHASE_COUNT - 1
            box phaseBox = window.phaseBoxes.get(phaseIndex)
            if not na(phaseBox)
                if textMode != "Off" and captionLimit > 0
                    captionQueue.keepCaptionBox(phaseBox, captionLimit)
                else
                    phaseBox.set_text("")

    if drawGlyphs and glyphLimit > 0
        string glyphText = window.phaseStripText(phaseEfficiencyThreshold)
        float glyphPrice = window.signatureGlyphPrice(
             placement,
             maximumHeightPercent,
             gapPercent,
             glyphOffsetPercent)
        bool glyphAbove = f_ribbonAbove(placement, window.openPrice, window.closePrice)
        label glyphLabel = label.new(
             x = window.signatureGlyphX(),
             y = glyphPrice,
             text = glyphText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = glyphAbove ? label.style_label_lower_right : label.style_label_upper_right,
             color = color.new(window.baseColor, 4),
             textcolor = f_fillTextColor(window.baseColor),
             size = f_textSize(glyphSize),
             textalign = text.align_left,
             tooltip = window.summaryTooltip(phaseEfficiencyThreshold))
        glyphQueue.keepLabel(glyphLabel, glyphLimit)

    if drawSummary and summaryLimit > 0
        float totalDisplacement = window.closePrice - window.openPrice
        bool placeAbove = totalDisplacement >= 0.0
        float windowRange = math.max(window.highPrice - window.lowPrice, syminfo.mintick * 10.0)
        float labelOffset = windowRange * summaryOffset / 100.0
        float labelPrice = placeAbove ? window.highPrice + labelOffset : window.lowPrice - labelOffset
        label summaryLabel = label.new(
             x = window.endBar,
             y = labelPrice,
             text = window.summaryText(summaryMode, phaseEfficiencyThreshold),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = placeAbove ? label.style_label_down : label.style_label_up,
             color = window.baseColor,
             textcolor = f_fillTextColor(window.baseColor),
             size = f_textSize(summarySize),
             tooltip = window.summaryTooltip(phaseEfficiencyThreshold))
        summaryQueue.keepLabel(summaryLabel, summaryLimit)

    if completionAlerts and barstate.isnew
        alert(window.name + " completed on " + syminfo.ticker + " (" + timeframe.period + "): " + window.signature, alert.freq_all)

    if concentrationAlerts and barstate.isnew and baselineEligible and not na(window.peakPercentile) and window.peakPercentile >= concentrationPercentile
        alert(window.name + " completed with unusual Phase " + str.tostring(window.peakPhase + 1) + " concentration: " + f_percentileText(window.peakPercentile) + " on " + syminfo.ticker, alert.freq_all)

    if baselineEligible
        window.storeCompletedShares(historyLimit)
    window

method beginWindow(
     ActivityWindow window,
     array<box> boxQueue,
     int boxLimit,
     bool drawBoxes,
     int baseTransparency,
     int activeEmphasis,
     string heatMode,
     string textMode,
     string textSize,
     int minimumSamples,
     float phaseEfficiencyThreshold,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     color upperColor,
     color lowerColor,
     color rotationalColor,
     bool startAlerts) =>
    window.resetCurrentState()
    window.addCurrentBar(
         boxQueue,
         boxLimit,
         drawBoxes,
         baseTransparency,
         activeEmphasis,
         heatMode,
         textMode,
         textSize,
         minimumSamples,
         phaseEfficiencyThreshold,
         placement,
         maximumHeightPercent,
         gapPercent,
         upperColor,
         lowerColor,
         rotationalColor)
    if startAlerts and barstate.isnew
        alert(window.name + " started on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_all)
    window

method process(
     ActivityWindow window,
     bool environmentEligible,
     array<box> boxQueue,
     array<box> captionQueue,
     array<label> summaryQueue,
     array<label> glyphQueue,
     int boxLimit,
     int captionLimit,
     int summaryLimit,
     int glyphLimit,
     bool drawBoxes,
     int baseTransparency,
     int activeEmphasis,
     string heatMode,
     string textMode,
     string textSize,
     string placement,
     float maximumHeightPercent,
     float gapPercent,
     bool drawGlyphs,
     string glyphSize,
     float glyphOffsetPercent,
     bool drawSummary,
     string summaryMode,
     string summarySize,
     float summaryOffset,
     int historyLimit,
     int minimumSamples,
     int requiredObservedPhases,
     float phaseEfficiencyThreshold,
     float persistentEfficiencyThreshold,
     float alignmentThreshold,
     float frontThreshold,
     float backThreshold,
     float dominantThreshold,
     float evenTolerance,
     int flipThreshold,
     float concentrationPercentile,
     color upperColor,
     color lowerColor,
     color rotationalColor,
     bool startAlerts,
     bool completionAlerts,
     bool concentrationAlerts) =>
    bool insideNow = environmentEligible and window.enabled and window.isInside()

    if insideNow and not window.active
        window.beginWindow(
             boxQueue,
             boxLimit,
             drawBoxes,
             baseTransparency,
             activeEmphasis,
             heatMode,
             textMode,
             textSize,
             minimumSamples,
             phaseEfficiencyThreshold,
             placement,
             maximumHeightPercent,
             gapPercent,
             upperColor,
             lowerColor,
             rotationalColor,
             startAlerts)
    else if insideNow and window.active
        window.addCurrentBar(
             boxQueue,
             boxLimit,
             drawBoxes,
             baseTransparency,
             activeEmphasis,
             heatMode,
             textMode,
             textSize,
             minimumSamples,
             phaseEfficiencyThreshold,
             placement,
             maximumHeightPercent,
             gapPercent,
             upperColor,
             lowerColor,
             rotationalColor)
    else if not insideNow and window.active
        window.finishWindow(
             captionQueue,
             summaryQueue,
             glyphQueue,
             captionLimit,
             summaryLimit,
             glyphLimit,
             drawBoxes,
             baseTransparency,
             heatMode,
             textMode,
             textSize,
             placement,
             maximumHeightPercent,
             gapPercent,
             drawGlyphs,
             glyphSize,
             glyphOffsetPercent,
             drawSummary,
             summaryMode,
             summarySize,
             summaryOffset,
             historyLimit,
             minimumSamples,
             requiredObservedPhases,
             phaseEfficiencyThreshold,
             persistentEfficiencyThreshold,
             alignmentThreshold,
             frontThreshold,
             backThreshold,
             dominantThreshold,
             evenTolerance,
             flipThreshold,
             concentrationPercentile,
             upperColor,
             lowerColor,
             rotationalColor,
             completionAlerts,
             concentrationAlerts)
    insideNow

//=============================================================================
// Initialize window objects and drawing queues
//=============================================================================

var array<ActivityWindow> windows = array.new<ActivityWindow>()
var array<box> allPhaseBoxes = array.new<box>()
var array<box> captionPhaseBoxes = array.new<box>()
var array<label> summaryLabels = array.new<label>()
var array<label> signatureGlyphs = array.new<label>()
var table focusPanel = table.new(
     f_panelPosition(focusPanelPosition),
     5,
     panelRowCount,
     bgcolor = color.new(chart.bg_color, focusPanelTransparency),
     frame_color = color.new(chart.fg_color, 72),
     frame_width = 1,
     border_color = color.new(chart.fg_color, 88),
     border_width = 1)

if barstate.isfirst
    ActivityWindow asiaWindow = ActivityWindow.new(
         asiaName, asiaCode, asiaIcon, 0, asiaEnabled, asiaHours, asiaDays, asiaTimezone, asiaColor,
         f_parseClockMinute(asiaHours, false), f_sessionDurationMinutes(asiaHours))
    asiaWindow.phase1History := array.new<float>()
    asiaWindow.phase2History := array.new<float>()
    asiaWindow.phase3History := array.new<float>()
    asiaWindow.phase4History := array.new<float>()
    windows.push(asiaWindow)

    ActivityWindow londonWindow = ActivityWindow.new(
         londonName, londonCode, londonIcon, 1, londonEnabled, londonHours, londonDays, londonTimezone, londonColor,
         f_parseClockMinute(londonHours, false), f_sessionDurationMinutes(londonHours))
    londonWindow.phase1History := array.new<float>()
    londonWindow.phase2History := array.new<float>()
    londonWindow.phase3History := array.new<float>()
    londonWindow.phase4History := array.new<float>()
    windows.push(londonWindow)

    ActivityWindow newYorkWindow = ActivityWindow.new(
         newYorkName, newYorkCode, newYorkIcon, 2, newYorkEnabled, newYorkHours, newYorkDays, newYorkTimezone, newYorkColor,
         f_parseClockMinute(newYorkHours, false), f_sessionDurationMinutes(newYorkHours))
    newYorkWindow.phase1History := array.new<float>()
    newYorkWindow.phase2History := array.new<float>()
    newYorkWindow.phase3History := array.new<float>()
    newYorkWindow.phase4History := array.new<float>()
    windows.push(newYorkWindow)

    ActivityWindow londonCloseWindow = ActivityWindow.new(
         londonCloseName, londonCloseCode, londonCloseIcon, 3, londonCloseEnabled, londonCloseHours, londonCloseDays, londonCloseTimezone, londonCloseColor,
         f_parseClockMinute(londonCloseHours, false), f_sessionDurationMinutes(londonCloseHours))
    londonCloseWindow.phase1History := array.new<float>()
    londonCloseWindow.phase2History := array.new<float>()
    londonCloseWindow.phase3History := array.new<float>()
    londonCloseWindow.phase4History := array.new<float>()
    windows.push(londonCloseWindow)

    ActivityWindow customWindow = ActivityWindow.new(
         customName, customCode, customIcon, 4, customEnabled, customHours, customDays, customTimezone, customColor,
         f_parseClockMinute(customHours, false), f_sessionDurationMinutes(customHours))
    customWindow.phase1History := array.new<float>()
    customWindow.phase2History := array.new<float>()
    customWindow.phase3History := array.new<float>()
    customWindow.phase4History := array.new<float>()
    windows.push(customWindow)

//=============================================================================
// Main execution
//=============================================================================

float chartTimeframeSeconds = timeframe.in_seconds()
bool timeframeEligible = timeframe.isintraday and not na(chartTimeframeSeconds) and chartTimeframeSeconds <= maximumTimeframeMinutes * 60
bool chartTypeEligible = not requireStandardChart or chart.is_standard
bool environmentEligible = timeframeEligible and chartTypeEligible
int effectiveMinimumSamples = math.min(minimumBaselineSamples, historicalLookback)
int effectiveBoxLimit = math.min(300, retainedCompletedWindows * PHASE_COUNT + WINDOW_COUNT * PHASE_COUNT)
int effectiveCaptionLimit = math.min(retainedCompletedWindows, retainedTextWindows) * PHASE_COUNT
int effectiveSummaryLimit = math.min(60, retainedSummaryLabels)
int effectiveGlyphLimit = math.min(120, retainedCompletionGlyphs)
bool researchLayout = visualLayout == "Research detail"
bool panelOnlyLayout = visualLayout == "Panel only"
bool lensLayout = visualLayout == "Phase strip + adaptive lens"
bool phaseStripMode = chartVisualMode == "Phase strip" or chartVisualMode == "Phase strip + pulse blocks"
bool pulseBlockMode = chartVisualMode == "Pulse blocks" or chartVisualMode == "Phase strip + pulse blocks"
bool effectiveShowFingerprint = showFingerprintRibbon and not panelOnlyLayout and pulseBlockMode
bool effectiveShowCompletionGlyphs = showCompletionGlyphs and not panelOnlyLayout and phaseStripMode
bool effectiveShowSummaryLabels = researchLayout and showSummaryLabels
bool effectiveShowFocusPanel = showFocusPanel
bool effectiveShowAdaptiveLens = showAdaptivePhaseLens and (lensLayout or researchLayout)
string effectivePhaseTextMode = researchLayout ? phaseTextMode : "Off"

int activeWindowCount = 0
color activeLensBaseColor = na
int activeLensAlpha = adaptiveLensTransparency

for index = 0 to windows.size() - 1
    ActivityWindow currentWindow = windows.get(index)
    bool insideCurrentWindow = currentWindow.process(
         environmentEligible,
         allPhaseBoxes,
         captionPhaseBoxes,
         summaryLabels,
         signatureGlyphs,
         effectiveBoxLimit,
         effectiveCaptionLimit,
         effectiveSummaryLimit,
         effectiveGlyphLimit,
         effectiveShowFingerprint,
         fingerprintBaseTransparency,
         activeFingerprintEmphasis,
         completedHeatMode,
         effectivePhaseTextMode,
         phaseTextSizeInput,
         fingerprintPlacement,
         fingerprintHeightPercent,
         fingerprintGapPercent,
         effectiveShowCompletionGlyphs,
         completionGlyphSizeInput,
         completionGlyphOffsetPercent,
         effectiveShowSummaryLabels,
         summaryDetailMode,
         summaryTextSizeInput,
         summaryOffsetPercent,
         historicalLookback,
         effectiveMinimumSamples,
         minimumObservedPhases,
         phaseDirectionalEfficiencyThreshold,
         persistentPathEfficiencyThreshold,
         persistentAlignmentThreshold,
         frontLoadedShareThreshold,
         backLoadedShareThreshold,
         dominantPhaseShareThreshold,
         evenDistributionTolerance,
         rotationalFlipThreshold,
         unusualPhasePercentile,
         upperDirectionColor,
         lowerDirectionColor,
         rotationalDirectionColor,
         alertWindowStarts,
         alertWindowCompletes,
         alertUnusualConcentration)

    if insideCurrentWindow
        activeWindowCount += 1
        color candidateLensColor = currentWindow.activeLensColor(
             phaseDirectionalEfficiencyThreshold,
             upperDirectionColor,
             lowerDirectionColor,
             rotationalDirectionColor)
        int candidateLensAlpha = currentWindow.activeLensTransparency(adaptiveLensTransparency)
        if activeWindowCount == 1
            activeLensBaseColor := candidateLensColor
            activeLensAlpha := candidateLensAlpha
        else
            activeLensBaseColor := overlapColor
            activeLensAlpha := math.min(activeLensAlpha, candidateLensAlpha)

color adaptiveLens = effectiveShowAdaptiveLens and environmentEligible and activeWindowCount > 0 ? color.new(activeLensBaseColor, activeLensAlpha) : na
bgcolor(
     adaptiveLens,
     title = "Adaptive price-path phase lens",
     editable = false)

if barstate.islast
    color panelBase = color.new(chart.bg_color, focusPanelTransparency)
    color panelHeader = color.new(chart.fg_color, 86)
    color panelGrid = color.new(chart.fg_color, 88)
    table.set_bgcolor(focusPanel, panelBase)
    table.set_frame_color(focusPanel, color.new(chart.fg_color, 68))
    table.set_border_color(focusPanel, panelGrid)

    if effectiveShowFocusPanel
        string activityBadge = activeWindowCount > 0 ? "● " + str.tostring(activeWindowCount) + " LIVE" : "○ IDLE"
        color activityColor = activeWindowCount > 0 ? activeLensBaseColor : color.new(chart.fg_color, 35)

        table.cell(focusPanel, 0, 0, "◈ PATH PULSE", text_color = chart.fg_color, text_size = f_textSize(focusPanelTextSize), bgcolor = panelHeader, text_halign = text.align_left)
        table.cell(focusPanel, 1, 0, "", text_color = chart.fg_color, text_size = f_textSize(focusPanelTextSize), bgcolor = panelHeader)
        table.cell(focusPanel, 2, 0, "", text_color = chart.fg_color, text_size = f_textSize(focusPanelTextSize), bgcolor = panelHeader)
        table.cell(focusPanel, 3, 0, "", text_color = chart.fg_color, text_size = f_textSize(focusPanelTextSize), bgcolor = panelHeader)
        table.cell(focusPanel, 4, 0, activityBadge, text_color = activityColor, text_size = size.small, bgcolor = panelHeader, text_halign = text.align_right)

        table.cell(focusPanel, 0, 1, "FOCUS", text_color = color.new(chart.fg_color, 15), text_size = size.tiny, bgcolor = panelBase, text_halign = text.align_left)
        table.cell(focusPanel, 1, 1, "STATUS", text_color = color.new(chart.fg_color, 15), text_size = size.tiny, bgcolor = panelBase, text_halign = text.align_center)
        table.cell(focusPanel, 2, 1, "PATH", text_color = color.new(chart.fg_color, 15), text_size = size.tiny, bgcolor = panelBase, text_halign = text.align_center)
        table.cell(focusPanel, 3, 1, "PULSE", text_color = color.new(chart.fg_color, 15), text_size = size.tiny, bgcolor = panelBase, text_halign = text.align_center)
        table.cell(focusPanel, 4, 1, "CTX", text_color = color.new(chart.fg_color, 15), text_size = size.tiny, bgcolor = panelBase, text_halign = text.align_right)

        int panelRow = 2
        for panelIndex = 0 to windows.size() - 1
            ActivityWindow panelWindow = windows.get(panelIndex)
            if panelWindow.enabled
                bool liveRow = panelWindow.active
                color rowBackground = liveRow ? color.new(panelWindow.baseColor, 84) : panelBase
                color identityBackground = liveRow ? color.new(panelWindow.baseColor, 70) : color.new(panelWindow.baseColor, 92)
                color stateText = liveRow ? panelWindow.baseColor : color.new(chart.fg_color, 12)
                color pathText = liveRow ? chart.fg_color : panelWindow.baseColor
                if liveRow and not na(panelWindow.currentPhase)
                    int liveDirection = f_phaseDirection(
                         panelWindow.phaseOpen.get(panelWindow.currentPhase),
                         panelWindow.phaseClose.get(panelWindow.currentPhase),
                         panelWindow.phaseGrossPath.get(panelWindow.currentPhase),
                         phaseDirectionalEfficiencyThreshold)
                    pathText := f_directionColor(liveDirection, upperDirectionColor, lowerDirectionColor, rotationalDirectionColor)

                string windowText = panelWindow.icon + " " + panelWindow.code + " " + f_sessionDisplay(panelWindow.hours)
                table.cell(focusPanel, 0, panelRow, windowText, text_color = panelWindow.baseColor, text_size = f_textSize(focusPanelTextSize), bgcolor = identityBackground, text_halign = text.align_left)
                table.cell(focusPanel, 1, panelRow, panelWindow.panelStateText(), text_color = stateText, text_size = f_textSize(focusPanelTextSize), bgcolor = rowBackground, text_halign = text.align_center)
                table.cell(focusPanel, 2, panelRow, panelWindow.panelPathText(phaseDirectionalEfficiencyThreshold), text_color = pathText, text_size = f_textSize(focusPanelTextSize), bgcolor = rowBackground, text_halign = text.align_center)
                table.cell(focusPanel, 3, panelRow, panelWindow.panelFingerprintText(), text_color = panelWindow.baseColor, text_size = f_textSize(focusPanelTextSize), bgcolor = rowBackground, text_halign = text.align_center)
                table.cell(focusPanel, 4, panelRow, panelWindow.panelContextText(), text_color = chart.fg_color, text_size = f_textSize(focusPanelTextSize), bgcolor = rowBackground, text_halign = text.align_right)
                panelRow += 1

        if panelRow <= panelMaxRowIndex
            for clearRow = panelRow to panelMaxRowIndex
                for clearColumn = 0 to 4
                    table.cell(focusPanel, clearColumn, clearRow, "", bgcolor = color.new(chart.bg_color, 100))

        int spacerRow = panelSpacerRow
        string spacerText = focusPanelPosition == "Bottom left" ? " " : ""
        for spacerColumn = 0 to 4
            table.cell(focusPanel, spacerColumn, spacerRow, spacerText, text_color = color.new(chart.bg_color, 100), text_size = size.tiny, bgcolor = color.new(chart.bg_color, 100))
    else
        table.set_frame_color(focusPanel, color.new(chart.fg_color, 100))
        table.set_border_color(focusPanel, color.new(chart.fg_color, 100))
        for clearRow = 0 to panelMaxRowIndex
            for clearColumn = 0 to 4
                table.cell(focusPanel, clearColumn, clearRow, "", bgcolor = color.new(chart.bg_color, 100))

// A single factual notice appears only when the selected chart timeframe is unsupported.
var label timeframeNotice = na
if barstate.islast
    if not environmentEligible
        string noticeText = not timeframeEligible ? "Use an intraday timeframe at or below " + str.tostring(maximumTimeframeMinutes) + " minutes." : "Use a standard chart type or disable the standard-chart requirement."
        if na(timeframeNotice)
            timeframeNotice := label.new(
                 x = bar_index,
                 y = high,
                 text = noticeText,
                 xloc = xloc.bar_index,
                 yloc = yloc.abovebar,
                 style = label.style_label_down,
                 color = color.rgb(255, 193, 7),
                 textcolor = color.rgb(15, 23, 42),
                 size = size.small)
        else
            timeframeNotice.set_xy(bar_index, high)
            timeframeNotice.set_text(noticeText)
    else if not na(timeframeNotice)
        timeframeNotice.delete()
        timeframeNotice := na
````
