# Correlation Matrix [AFD]

- url: https://www.tradingview.com/script/tqf4eAaM-Correlation-Matrix-AFD/
- type: indicator
- pine_id: PUB;68cc95aea1bb4cf8a3eec956006df5a7
- version: 1.0

## Description

Correlation Matrix [AFD] turns the active chart into a one-to-many cross-asset relationship monitor. It compares the chart symbol with up to eight instruments and brings slower and faster return correlation, fitted return sensitivity, matched spread distance, pair-specific correlation history, and data availability into one dashboard.

It is designed to answer practical research questions: Which selected markets have been moving with or against the chart symbol? Has recent co-movement departed from the slower relationship? How sensitive has the chart symbol been to each comparison? Is the matched spread unusually displaced for that pair? Is the reading supported by enough shared observations to interpret responsibly?

Built-in Symbol sets and Measurement presets provide repeatable samples. A Measurement preset selects a requested timeframe and Long/Short windows; it never changes the chart candles or requires a matching chart timeframe. Custom can follow the chart or request a fixed measurement timeframe. Optional rebased lines use a separate visual baseline. All outputs are descriptive measurements, not automated decisions.

[b]What It Is Useful For[/b]

[*][b]Cross-asset mapping:[/b] Place an index, sector, currency, commodity, rate-sensitive instrument, volatility index, or digital asset on the chart and compare it with a preset universe or a Custom basket. This helps organize intermarket context around one common reference symbol.

[*][b]Relationship-change monitoring:[/b] Treat Long Correlation as the slower context sample and Short Correlation as the faster sample. Correlation Difference shows how far the faster coefficient sits above or below the slower one, while the two coefficients preserve their direction and sign. It is a comparison of two estimates, not a formal regime or significance test.

[*][b]Benchmark and proxy research:[/b] Compare correlation with Beta to separate consistency of co-movement from fitted magnitude of response. This can help screen which selected benchmark, sector, or macro proxy has historically had the closest relationship to the chart symbol. It is not factor attribution.

[*][b]Candidate-hedge research:[/b] Screen for relationships that have been negative across the selected windows, then use Beta and Data Coverage as sensitivity and sample context. The output can narrow further research; it does not select a hedge, calculate contract quantities, or account for liquidity, basis, carry, costs, or portfolio constraints.

[*][b]Relative-value triage:[/b] Use Spread to identify a matched relationship that is unusually displaced from its own Long-window average, then use correlation, History, and usable-sample counts to judge whether the observation deserves investigation. Spread is not a cointegration test, regression residual, stationarity test, or mean-reversion forecast.

[*][b]Exposure-overlap review:[/b] Chart one holding at a time against a Custom basket to identify potentially redundant co-movement or sensitivity. This is useful for screening concentration questions, but it is not a portfolio covariance engine or risk model.

[*][b]Sample-integrity review:[/b] Read Data Coverage and the usable Long/Short return counts before interpreting a coefficient, especially across different sessions, holidays, young listings, or sparse feeds. These are availability disclosures, not confidence or quality scores.

[*][b]Event and baseline comparison:[/b] Rebase percentage paths from Session Open, Rolling N Bars, Year Open, or a Fixed Date to inspect divergence after a session boundary, calendar reset, or chosen event. These chart lines are visual comparisons and never feed the statistics.

[b]Capabilities[/b]

[image]https://www.tradingview.com/x/vBwfzImj/[/image]

[*]Eight configurable comparison slots. In Custom mode, each slot has a symbol, optional display name, color, Enabled switch, and Show comparison line switch. Blank slots remain hidden; an invalid or unavailable symbol displays No data without stopping valid rows.

[*]Five built-in Symbol sets: United States Indices, Risk On / Off, Major Foreign Exchange Pairs, Energy & Metals, and Crypto. Custom values are retained while a set temporarily supplies eight symbols and ticker-derived names. Risk On / Off supplies comparison instruments; it does not classify the market.

[*]Three Measurement presets plus Custom: Scalper requests 1 minute with Long 60 / Short 15; default Intraday requests 5 minutes with Long 78 / Short 20; Swing requests 1 day with Long 120 / Short 20. Swing on a 30-minute chart is an intended configuration, not an error: chart candles remain 30 minutes while completed 1-day observations drive measurements. Custom exposes the timeframe and both windows.

[*]Long Correlation, Short Correlation, Main Correlation, Correlation Difference, Long-window Beta, signed Spread z-score, optional History percentile, and Data Coverage. Tooltips disclose usable Long/Short returns and fresh-versus-eligible coverage counts.

[*]Contextual hover help on every dashboard heading and cell. It explains metric definitions, sample requirements, and unavailable states, with additional detail for Beta direction and fitted sensitivity, active Spread form and position, History's prior range and average, and Data Coverage endpoint counts.

[*]Context, Compact, Full, Minimal, and Custom dashboard views; an independent Correlation Difference switch; custom column overrides; nine table positions; slot, absolute Long Correlation, or absolute Spread sorting; and Heat or Mono cells.

[*]Optional rebased comparison lines with Auto from measurement preset, Session Open, Rolling N Bars, Year Open, and Fixed Date baselines. Seven appearances, a shared baseline marker, configurable line-end labels, and one-slot gap shading are included.

[*]Separate dashboard and comparison-line visibility switches. Measurements continue while either visual layer is hidden. Status text identifies chart and effective measurement timeframes; its tooltip also identifies the requested timeframe, completed higher-timeframe sampling, lower-timeframe fallback, active windows, adjusted Short window, and visual line baseline.

[*]Dashboard text, colors, backgrounds, transparency, alternating rows, borders, frame, line width/transparency, marker styling, label styling, gap colors, and a global master-opacity control can be adjusted without changing measurements.

[b]How the Statistics Work[/b]
Correlation is computed on log returns, never on raw price levels. Correlating two trending price series directly can produce a spuriously high reading that reflects their shared trend rather than how their returns move together.

[image]https://www.tradingview.com/x/4ms1b1l9/[/image]

Pearson correlation has no universal market timeframe or lookback. The effective measurement timeframe and window define the observations. A 120-bar window with 1-minute measurements and the same window with 5-minute measurements are different samples and can produce different coefficients.

Correlation runs from +100% through 0% to -100%. It standardizes direction and consistency of linear co-movement; it does not imply equal-sized returns. Correlation Difference is computed as Short minus Long and displayed as a rounded signed number in percentage points.

Beta uses Long-window matched returns and direct covariance/comparison-return variance. From the chart symbol's perspective, Beta +1.20 describes a fitted 1.20-unit chart-symbol log-return response per 1.00 unit of comparison-symbol return in that sample. It is directional and asymmetric, and is benchmark beta only when the comparison is the intended benchmark.
Spread is a signed population z-score of an equal-weight matched log spread. Non-negative Long Correlation selects log(chart) minus log(comparison); negative Long Correlation selects log(chart) plus log(comparison). Separate histories are maintained for the ratio and product forms. The tooltip identifies the active form and whether the latest spread is above or below its matched Long-window average.

When the chart symbol is selected as its own comparison under the same request context, the ratio log-spread has zero variation. Its z-score is therefore unavailable rather than 0.0; after warm-up, identical requested data with measurable return variation produce +100% correlation, zero Difference, and Beta 1.

[image]https://www.tradingview.com/x/cEf2dN39/[/image]

History ranks the current Main Correlation against only that pair's prior valid Main Correlation readings in the Historical window. A tie-aware midrank makes an all-tie sample read 50/100. It describes relative position inside the pair's own history, not statistical confidence or a forecast.
Data Coverage is fresh comparison endpoints divided by eligible Long-window measurement positions after the comparison first appears in loaded data. A carried timestamp is not counted twice. Coverage is distinct from the usable matched returns reported in the tooltips and does not alter any statistic.

[b]Shared-Endpoint Alignment and Confirmation[/b]
At each chart-base measurement observation, the script selects the latest completed comparison endpoint known by that base close and maps it to the nearer current or preceding base close; a tie remains on the current close. A return pair is created only between consecutive accepted endpoint pairs when both base and comparison timestamps strictly advance.

Missing bars, holidays, and session gaps accumulate both instruments from the same prior shared endpoint instead of pairing different elapsed intervals. The accumulated interval remains one observation; it is not duration-normalized or split into synthetic bars. An unmatched observation writes one unavailable window position. A star marks a latest fresh comparison endpoint mapped to the preceding base close.

A complete configured measurement window, at least three usable returns, and measurable variation are required before Pearson is shown. Beta requires measurable comparison-return variance. Blank results are intentional when these conditions are not met.

Equal-timeframe requests use lookahead off and statistical snapshots commit on chart confirmation. Fixed higher measurement timeframes use completed bars: every requested price and timestamp field is offset by one measurement bar before lookahead is enabled. The chart timeframe does not need to match. A requested measurement timeframe below the chart falls back to the chart timeframe and produces an amber warning.

The chart-base request retains the active chart's complete ticker context. A slot set to the chart symbol reuses that exact context; other nonblank comparisons inherit applicable session, price-adjustment, currency, and futures modifiers. TradingView ignores modifiers that do not apply to a comparison instrument. Changing an applicable modifier can change requested prices, timestamps, measurements, coverage, and rebased lines.

[b]The comparison lines are a ratio, not a 1:1 price overlay[/b]
The optional chart lines do not plot the other symbol's raw price or its correlation. Each line is tied to the chart symbol's measurement-timeframe price, then moved forward by the [i]percentage change[/i] of the compared symbol from that line baseline:

That is a ratio calculation, not a 1:1 mirror of price. Every drawn line uses the same baseline rule when measurement data is available, so its percentage path shares the chart's scale regardless of what either instrument costs.

Comparison line starting point is visual only. Auto from measurement preset uses Session Open for Scalper, Intraday, and Custom, and Year Open for Swing. Fixed Date sets the first base boundary on or after the date. Rolling N Bars moves the shared boundary. Each comparison waits for fresh eligible data, so a line can begin after the marker, remain blank, or jump as a rolling window changes. No line setting changes any dashboard measurement.

[b]Settings[/b]
[*][b]Quick Setup:[/b] Measurement preset selects timeframe and Long/Short windows without changing or requiring a matching chart. Dashboard view and Show correlation difference control columns. Symbol set controls the universe. Show dashboard and Show comparison lines control visual layers. Comparison line starting point controls rebased visuals.

[*][b]Symbols and slots:[/b] Custom is the default Symbol set. On an SPY chart, the starting Custom symbols are QQQ, DIA, and IWM; the remaining slots are blank. These are examples, not recommendations. A blank display name derives the ticker automatically. Built-in sets override retained Custom symbols and names until Custom is selected again.

[*][b]Custom measurements:[/b] Blank Custom timeframe follows the chart; a fixed selection at or above the chart holds its requested sampling without changing candles. Long defaults to 120 (range 10-1000); Short to 20 (range 5-200). If Short is not below Long, effective Short becomes Long minus one and appears in amber. Long changes Long, Difference, Beta, Spread, and Coverage; Short changes Short and Difference.

[*][b]Main Correlation and History:[/b] Main correlation window defaults to Short and selects the existing Long or Short result used by Main Correlation, History, and line-end correlation text. Historical comparison defaults off. Its window defaults to 750 and accepts 100-5000 effective measurement positions; History remains blank until the full measurement window exists.

[*][b]Dashboard views and columns:[/b] Default Context shows Symbol, Long, Short, Spread, and Coverage; Compact shows Symbol, Short, and Spread; Full shows Symbol, Long, Short, Beta, Spread, Coverage, and enabled History; Minimal shows Symbol and Main; Custom uses individual metric switches. Custom columns can override any view. Difference is independently on by default.

[*][b]Dashboard layout:[/b] Nine positions default to Top Right. Sorting uses Slot order, strongest absolute Long, or widest absolute Spread. Cells use Heat or Mono. Text, colors, backgrounds, transparency, row shading, borders, and frame are adjustable.

[*][b]Comparison line style:[/b] Solid is the default; Dashed, Dotted, Step, Step with diamonds, Points, and Crosses are available. Width defaults to 2 and transparency to 50. Area, histogram, and column modes are intentionally excluded because they can obscure candles or distort the price scale.

[*][b]Starting-point details:[/b] Rolling N Bars defaults to 120 and accepts 10-1000 effective measurement bars. Each line waits for its first fresh valid endpoint at or after the shared rolling boundary. Fixed Date is editable and defaults to 1 January 2026. The optional shared marker has style, color, transparency, and width controls.

[*][b]Gap shading and labels:[/b] Gap shading can fill between chart price and one selected rebased slot with separate chart-above/chart-below colors and transparency. Line-end labels can include display name, Main Correlation, and Spread, with size and slot/custom text-color controls.

[*][b]Global appearance:[/b] Master opacity adds fade to table cells/text, lines, marker, fill, and labels; table border and frame keep their own colors. Appearance, visibility, ordering, and baseline controls do not alter calculations.

[b]What It Does Not Do / Limitations[/b]

[*]This is a one-to-many dashboard: every row compares one instrument with the active chart symbol. It is not a full pairwise matrix among all eight comparisons, a covariance matrix, portfolio optimizer, factor model, value-at-risk calculation, or position-sizing engine.

[*]Correlation measures a historical linear relationship in returns. It does not establish causation, forecast persistence, detect nonlinear dependence, or label a pair bullish or bearish.

[*]Correlation Difference is not a hypothesis test or statistical regime detector. The indicator does not calculate p-values, confidence intervals, statistical significance, or multiple-comparison adjustments.

[*]Beta is a backward-looking fitted sensitivity with the chart symbol as the dependent return series. It is not symmetric and is not a dollar-, volatility-, or contract-neutral hedge ratio.

[*]Spread is an equal-weight log ratio/product z-score selected by the sign of Long Correlation. It does not establish cointegration, stationarity, fair value, or an expectation of mean reversion.

[*]History percentile and its Low-to-High context bands are relative only to that pair's prior Main Correlation. They are not confidence levels, relationship grades, decision rules, or forecasts.

[*]Data Coverage measures fresh endpoint availability, not data accuracy, sample quality, or statistical reliability. Markets with different sessions can supply fewer usable returns, and an interval accumulated across a gap remains one observation.

[*]Results depend on TradingView's feed, exchange and session coverage, loaded history, selected symbols, applicable chart modifiers, effective measurement timeframe, and window lengths. Changing session, price adjustment, currency conversion, supported futures settings, or other applicable data settings can change the values.

[*]The indicator requires standard, time-based candles. Non-standard chart types and tick charts halt with a runtime message because the measurement contract requires ordinary time-based OHLC bars rather than synthetic or tick-built observations.

[*]Blank Custom timeframe follows the chart. Built-in presets and fixed Custom timeframes do not require a chart match. A request below the chart falls back to the chart timeframe; a fixed higher timeframe excludes the developing measurement bar and can update up to one confirming chart bar later.

[*]Blank cells indicate insufficient measurement history, matched returns, or variation. A line can begin after its marker or remain blank when no fresh baseline observation exists. Rebased lines can stretch autoscale, and Rolling N Bars can jump as its denominator moves.

[*]The implementation keeps eight static comparison requests plus one chart-base request. Disabling a slot changes the display but does not remove its request or reduce the fixed request cost.

[*]This measurement-only build does not generate alerts, classify relationships, automate decisions, execute orders, or provide position- or risk-management instructions.

[b]Design and Originality[/b]
Pearson correlation, covariance, Beta, and z-scores are standard statistics. This implementation integrates an eight-instrument universe, independent measurement and visual baselines, two return windows, causal shared-endpoint matching, sample disclosures, direct Beta, separate ratio/product spread histories, prior-only tie-aware History, sortable views, and fresh-boundary rebased lines.

The components share one confirmed measurement clock and interpretation surface. They combine slower/faster relationship context, fitted sensitivity, availability, spread displacement, pair history, and normalized paths without importing an external correlation series or creating a classification state.

[b]Open-source License[/b]
This is an open-source publication. The source is licensed under the Mozilla Public License 2.0 (MPL 2.0) and includes AuctionFoundry attribution. Reuse in another TradingView publication must first satisfy TradingView's open-source reuse rules; once those rules are met, the MPL 2.0 terms apply.

[b]Disclaimer[/b]
For educational and informational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuctionFoundry

//@version=6
indicator("Correlation Matrix [AFD]", shorttitle="Correlation Matrix [AFD]", overlay=true, max_lines_count=10, max_labels_count=10)

// Drawing limits cover one reusable baseline marker and up to eight reusable
// line-end labels.


// ───────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ───────────────────────────────────────────────────────────────────────────

const int SLOT_COUNT = 8
const float MOMENT_EPS = 1e-12

const string PG_INDICES = "United States Indices"
const string PG_RISK    = "Risk On / Off"
const string PG_FX      = "Major Foreign Exchange Pairs"
const string PG_COMMOD  = "Energy & Metals"
const string PG_CRYPTO  = "Crypto"
const string PG_CUSTOM  = "Custom"

// Measurement presets select a requested timeframe and correlation windows.
// They never change or require a matching chart timeframe.
const string TH_SCALPER  = "Scalper · 1-minute measurements · Long 60 / Short 15"
const string TH_INTRADAY = "Intraday · 5-minute measurements · Long 78 / Short 20"
const string TH_SWING    = "Swing · 1-day measurements · Long 120 / Short 20"
const string TH_CUSTOM   = "Custom"

const string VP_CONTEXT = "Context"
const string VP_FULL    = "Full"
const string VP_COMPACT = "Compact"
const string VP_MINIMAL = "Minimal"
const string VP_CUSTOM  = "Custom"

const string CM_HEAT  = "Heat"
const string CM_MONO  = "Mono"

const string SORT_SLOT = "Slot order"
const string SORT_R    = "Strongest correlation"
const string SORT_Z    = "Widest spread"

const string AN_AUTO    = "Auto from measurement preset"
const string AN_SESSION = "Session Open"
const string AN_BARS    = "Rolling N Bars"
const string AN_DATE    = "Fixed Date"
const string AN_YEAR    = "Year Open"

// Shared correlation source for dashboard percentages and line-end labels.
const string PS_LONG  = "Long"
const string PS_SHORT = "Short"

const string LC_SLOT   = "Slot color"
const string LC_CUSTOM = "Custom"

const string LS_AUTO = "Auto"

const string LA_SOLID        = "Solid line"
const string LA_DASHED       = "Dashed line"
const string LA_DOTTED       = "Dotted line"
const string LA_STEP         = "Step line"
const string LA_STEP_DIAMOND = "Step line with diamonds"
const string LA_POINTS       = "Points"
const string LA_CROSSES      = "Crosses"

const string G_SETUP = "Quick Setup"
const string G_WIN   = "Custom Measurements — Advanced"
const string G_DASH  = "Dashboard"
const string G_COLS  = "Dashboard Columns — Advanced"
const string G_TEXT  = "Dashboard Appearance — Advanced"
const string G_OVER  = "Comparison Line Style"
const string G_BASE  = "Comparison Line Starting Point — Advanced"
const string G_SHADE = "Comparison Line Gap Shading — Advanced"
const string G_LBL   = "Comparison Line Labels — Advanced"
const string G_VIS   = "Global Appearance — Advanced"

const string G_S1 = "Slot 1"
const string G_S2 = "Slot 2"
const string G_S3 = "Slot 3"
const string G_S4 = "Slot 4"
const string G_S5 = "Slot 5"
const string G_S6 = "Slot 6"
const string G_S7 = "Slot 7"
const string G_S8 = "Slot 8"

const string TT_SLOT_ID = "• Enabled — includes a nonblank slot in measurements and the dashboard.\n• Symbol — editable only while Symbol set is Custom; built-in sets temporarily override it.\n• Display name — blank uses the ticker name.\n• Request cost — every slot retains one static comparison request, including disabled slots."
const string TT_SLOT_SYMBOL = "• Instrument — compared with the chart symbol.\n• Data context — inherits applicable chart session, adjustment, currency, and futures modifiers.\n• Unsupported modifiers — ignored by TradingView.\n• Editing — available only while Symbol set is Custom.\n• Built-in sets — temporarily override the saved Custom symbol."
const string TT_SLOT_SYMBOL_BLANK = "• Instrument — compared with the chart symbol.\n• Blank — reuses the chart request context only as a safe fallback and remains hidden.\n• Editing — available only while Symbol set is Custom."
const string TT_SLOT_COLOR = "• Comparison line — always uses the slot color.\n• Dashboard symbol — uses it in Heat mode; Mono mode overrides it.\n• Line-end label — uses it only when Text color is Slot color."
const string TT_SLOT_LINE = "• Draws the slot's rebased percentage-change path.\n• Also requires a nonblank enabled slot, the master Show comparison lines switch, and valid baseline data.\n• Visual only — dashboard measurements do not change."


// ───────────────────────────────────────────────────────────────────────────
// DATA TYPE
// ───────────────────────────────────────────────────────────────────────────

type CorrSlot
    bool   enabled       = false
    string sym           = ""
    string disp          = ""
    float  r_long        = na
    float  r_short       = na
    float  dr            = na
    float  beta          = na     // cov(chart, sym) / var(sym)
    float  spread_z      = na
    float  match_pct     = na     // timestamp-advance coverage
    int    match_fresh   = 0
    int    match_eligible = 0
    int    n_long        = 0
    int    n_short       = 0
    bool   lag_adj       = false  // latest fresh comparison mapped to the prior base endpoint
    bool   data_seen     = false
    float  r_pct         = na     // r as a percentage, source per pct_src
    float  r_hist_rank   = na     // percentile rank of Main Correlation in its own history
    float  r_hist_lo     = na
    float  r_hist_hi     = na
    float  r_hist_avg    = na
    int    r_hist_n      = 0
    color  col           = color.gray


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Quick Setup, Symbol Presets & Slots
// ───────────────────────────────────────────────────────────────────────────

trading_horizon = input.string(TH_INTRADAY, "Measurement preset", options=[TH_SCALPER, TH_INTRADAY, TH_SWING, TH_CUSTOM], group=G_SETUP, display=display.none, tooltip="Selects the requested measurement timeframe and correlation windows.\n\n• Chart timeframe — never changed and does not need to match.\n• Scalper — 1-minute measurements; Long 60, Short 15.\n• Intraday — 5-minute measurements; Long 78, Short 20. Default.\n• Swing — 1-day measurements; Long 120, Short 20.\n• Custom — uses the editable measurement settings below.\n• Intended behavior — Swing can run on a 30-minute chart while measurements use completed 1-day bars.\n• Fallback — if the requested measurement timeframe is below the chart timeframe, measurements use the chart timeframe and an amber warning appears.\n\nPreset values are practical starting points, not statistical standards.")
visual_preset = input.string(VP_CONTEXT, "Dashboard view", options=[VP_CONTEXT, VP_COMPACT, VP_FULL, VP_MINIMAL, VP_CUSTOM], inline="setup_dashboard", group=G_SETUP, display=display.none)
show_difference = input.bool(true, "Show correlation difference", inline="setup_dashboard", group=G_SETUP, display=display.none, tooltip="Display only; calculations and comparison lines do not change.\n\n• Context — Symbol, Long, Short, Spread, and Coverage.\n• Compact — Symbol, Short, and Spread in tiny text.\n• Full — Symbol, Long, Short, Beta, Spread, Coverage, and History when enabled.\n• Minimal — Symbol and Main Correlation in tiny text.\n• Custom — uses the advanced column switches.\n• Custom override — Use custom dashboard columns can replace any preset view.\n• Correlation Difference — Short minus Long; calculated continuously and optionally displayed in every view.")
preset_group = input.string(PG_CUSTOM, "Symbol set", options=[PG_CUSTOM, PG_INDICES, PG_RISK, PG_FX, PG_COMMOD, PG_CRYPTO], group=G_SETUP, display=display.none, tooltip="• Custom — uses the Symbol fields in Slots 1–8.\n• Built-in set — temporarily overrides saved Custom symbols and names.\n• Slot switches — Enabled and Show comparison line still control each row and line.")
dash_en    = input.bool(true, "Show dashboard", inline="setup_visibility", group=G_SETUP, display=display.none)
overlay_en = input.bool(true, "Show comparison lines", inline="setup_visibility", group=G_SETUP, display=display.none, tooltip="Visibility only.\n\n• Dashboard — shows or hides the table.\n• Comparison lines — shows or hides rebased lines, marker, gap shading, and labels.\n• Calculations — continue while either visual layer is hidden.")
line_start = input.string(AN_AUTO, "Comparison line starting point (visual only)", options=[AN_AUTO, AN_SESSION, AN_BARS, AN_YEAR, AN_DATE], group=G_SETUP, display=display.none, active=overlay_en, tooltip="Visual only; dashboard measurements never change.\n\n• Auto from measurement preset — Session Open for Scalper, Intraday, and Custom; Year Open for Swing.\n• Session Open — uses the current measurement session boundary.\n• Rolling N Bars — moves the shared boundary each measurement bar; each line waits for fresh eligible data and can jump as the window rolls.\n• Year Open — uses the current calendar-year boundary.\n• Fixed Date — uses the first base measurement bar on or after the date; each line then waits for fresh eligible comparison data.\n• Output — rebased percentage-change paths, not correlation plots.")

string anchor_mode = line_start == AN_AUTO ? (trading_horizon == TH_SWING ? AN_YEAR : AN_SESSION) : line_start

s1_en  = input.bool(true,  "Enabled", inline="s1a", group=G_S1, display=display.none)
s1_sym = input.symbol("NASDAQ:QQQ", "Symbol", inline="s1a", group=G_S1, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL)
s1_lbl = input.string("", "Display name", inline="s1a", group=G_S1, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s1_col  = input.color(#64b5f6, "Color", inline="s1b", group=G_S1, display=display.none, tooltip=TT_SLOT_COLOR)
s1_show = input.bool(true, "Show comparison line", inline="s1b", group=G_S1, display=display.none, tooltip=TT_SLOT_LINE)

s2_en  = input.bool(true,  "Enabled", inline="s2a", group=G_S2, display=display.none)
s2_sym = input.symbol("AMEX:DIA", "Symbol", inline="s2a", group=G_S2, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL)
s2_lbl = input.string("", "Display name", inline="s2a", group=G_S2, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s2_col  = input.color(#ffb74d, "Color", inline="s2b", group=G_S2, display=display.none, tooltip=TT_SLOT_COLOR)
s2_show = input.bool(true, "Show comparison line", inline="s2b", group=G_S2, display=display.none, tooltip=TT_SLOT_LINE)

s3_en  = input.bool(true,  "Enabled", inline="s3a", group=G_S3, display=display.none)
s3_sym = input.symbol("AMEX:IWM", "Symbol", inline="s3a", group=G_S3, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL)
s3_lbl = input.string("", "Display name", inline="s3a", group=G_S3, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s3_col  = input.color(#4dd0e1, "Color", inline="s3b", group=G_S3, display=display.none, tooltip=TT_SLOT_COLOR)
s3_show = input.bool(true, "Show comparison line", inline="s3b", group=G_S3, display=display.none, tooltip=TT_SLOT_LINE)

s4_en  = input.bool(true,  "Enabled", inline="s4a", group=G_S4, display=display.none)
s4_sym = input.symbol("", "Symbol", inline="s4a", group=G_S4, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL_BLANK)
s4_lbl = input.string("", "Display name", inline="s4a", group=G_S4, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s4_col  = input.color(#ba68c8, "Color", inline="s4b", group=G_S4, display=display.none, tooltip=TT_SLOT_COLOR)
s4_show = input.bool(true, "Show comparison line", inline="s4b", group=G_S4, display=display.none, tooltip=TT_SLOT_LINE)

s5_en  = input.bool(true,  "Enabled", inline="s5a", group=G_S5, display=display.none)
s5_sym = input.symbol("", "Symbol", inline="s5a", group=G_S5, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL_BLANK)
s5_lbl = input.string("", "Display name", inline="s5a", group=G_S5, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s5_col  = input.color(#81c784, "Color", inline="s5b", group=G_S5, display=display.none, tooltip=TT_SLOT_COLOR)
s5_show = input.bool(true, "Show comparison line", inline="s5b", group=G_S5, display=display.none, tooltip=TT_SLOT_LINE)

s6_en  = input.bool(true, "Enabled", inline="s6a", group=G_S6, display=display.none)
s6_sym = input.symbol("", "Symbol", inline="s6a", group=G_S6, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL_BLANK)
s6_lbl = input.string("", "Display name", inline="s6a", group=G_S6, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s6_col  = input.color(#ffd54f, "Color", inline="s6b", group=G_S6, display=display.none, tooltip=TT_SLOT_COLOR)
s6_show = input.bool(true, "Show comparison line", inline="s6b", group=G_S6, display=display.none, tooltip=TT_SLOT_LINE)

s7_en  = input.bool(true, "Enabled", inline="s7a", group=G_S7, display=display.none)
s7_sym = input.symbol("", "Symbol", inline="s7a", group=G_S7, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL_BLANK)
s7_lbl = input.string("", "Display name", inline="s7a", group=G_S7, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s7_col  = input.color(#f06292, "Color", inline="s7b", group=G_S7, display=display.none, tooltip=TT_SLOT_COLOR)
s7_show = input.bool(true, "Show comparison line", inline="s7b", group=G_S7, display=display.none, tooltip=TT_SLOT_LINE)

s8_en  = input.bool(true, "Enabled", inline="s8a", group=G_S8, display=display.none)
s8_sym = input.symbol("", "Symbol", inline="s8a", group=G_S8, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_SYMBOL_BLANK)
s8_lbl = input.string("", "Display name", inline="s8a", group=G_S8, display=display.none, active=preset_group == PG_CUSTOM, tooltip=TT_SLOT_ID)
s8_col  = input.color(#bcaaa4, "Color", inline="s8b", group=G_S8, display=display.none, tooltip=TT_SLOT_COLOR)
s8_show = input.bool(true, "Show comparison line", inline="s8b", group=G_S8, display=display.none, tooltip=TT_SLOT_LINE)


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Custom Measurements
// ───────────────────────────────────────────────────────────────────────────

custom_calc_tf   = input.timeframe("", "Custom measurement timeframe", group=G_WIN, display=display.none, active=trading_horizon == TH_CUSTOM, tooltip="Used only when Measurement preset is Custom.\n\n• Purpose — selects Custom measurement sampling and comparison-line source updates.\n• Chart candles — never changed.\n• Blank — follows the chart timeframe.\n• Fixed at or above chart — holds the requested sampling across chart views.\n• Higher than chart — uses completed measurement bars only.\n• Lower than chart — falls back to the chart timeframe with an amber warning.\n• Starting point — separately selects the visual comparison-line baseline.")
custom_long_len  = input.int(120, "Long correlation window", minval=10, maxval=1000, inline="custom_windows", group=G_WIN, display=display.none, active=trading_horizon == TH_CUSTOM)
custom_short_len = input.int(20, "Short correlation window", minval=5, maxval=200, inline="custom_windows", group=G_WIN, display=display.none, active=trading_horizon == TH_CUSTOM, tooltip="Used only when Measurement preset is Custom. Both values count effective measurement bars, not calendar days or visible chart bars.\n\n• Long — changes Long Correlation, Difference, Beta, Spread, and Coverage.\n• Short — changes Short Correlation and Difference.\n• Comparison lines — neither window moves them.\n• Adjustment — if Short is at or above Long, effective Short becomes Long minus one.")

// Preset values are resolved once; all measurement paths use these effective
// values rather than inactive Custom fields.
int long_len = switch trading_horizon
    TH_SCALPER  => 60
    TH_INTRADAY => 78
    TH_SWING    => 120
    => custom_long_len

int short_len = switch trading_horizon
    TH_SCALPER  => 15
    TH_INTRADAY => 20
    TH_SWING    => 20
    => custom_short_len

string calc_tf = switch trading_horizon
    TH_SCALPER  => "1"
    TH_INTRADAY => "5"
    TH_SWING    => "1D"
    => custom_calc_tf

pct_src  = input.string(PS_SHORT, "Main correlation window", options=[PS_LONG, PS_SHORT], inline="history_mode", group=G_WIN, display=display.none)
hist_en  = input.bool(false, "Historical comparison", inline="history_mode", group=G_WIN, display=display.none, tooltip="• Main correlation window — selects the existing Long or Short result for Main Correlation, History, and line-end text.\n• Historical comparison — ranks that Main Correlation against the pair's prior valid readings.\n• Default — Short is the faster reading; Long is the slower context.")

// Main Correlation selects the Long or Short result used by percentage text,
// History, and line-end labels.
bool pct_is_long = pct_src == PS_LONG
int  current_len = math.max(5, math.min(short_len, long_len - 1))
int  pct_len     = pct_is_long ? long_len : current_len
bool short_adjusted = trading_horizon == TH_CUSTOM and current_len != custom_short_len

hist_len = input.int(750, "Historical window", minval=100, maxval=5000, group=G_WIN, display=display.none, active=hist_en, tooltip="• Window — counts effective measurement positions.\n• Daily context — 750 is roughly three trading years only with daily measurements.\n• Intraday context — 750 means 750 intraday measurement positions.\n• Requirements — a complete window, valid current Main Correlation, and at least one prior valid reading.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Dashboard
// ───────────────────────────────────────────────────────────────────────────

dash_pos   = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline="dashboard_layout", group=G_DASH, display=display.none)
dash_sort  = input.string(SORT_SLOT, "Sort rows by", options=[SORT_SLOT, SORT_R, SORT_Z], inline="dashboard_layout", group=G_DASH, display=display.none, tooltip="• Position — sets the table location; Top Right is default.\n• Slot order — preserves configured row order.\n• Strongest correlation — sorts by absolute Long Correlation.\n• Widest spread — sorts by absolute Spread.")
color_mode = input.string(CM_HEAT, "Cell coloring", options=[CM_HEAT, CM_MONO], group=G_DASH, display=display.none, tooltip="• Heat — heat-maps valid correlation-cell backgrounds. Default.\n• Mono — removes correlation heat backgrounds and uses Mono color for dashboard body text.\n• Comparison lines — retain their slot colors in either mode.")

custom_columns_override = input.bool(false, "Use custom dashboard columns", group=G_COLS, display=display.none, tooltip="Display only.\n\n• On — column switches replace the selected Dashboard view.\n• Off — restores the selected view.\n• Custom view — always uses the switches.\n• Measurements and lines — unchanged.")
bool use_custom_columns = visual_preset == VP_CUSTOM or custom_columns_override
col_pct   = input.bool(true,  "Show main correlation", inline="columns_1", group=G_COLS, display=display.none, active=use_custom_columns)
col_rl    = input.bool(false, "Show long correlation", inline="columns_1", group=G_COLS, display=display.none, active=use_custom_columns, tooltip="• Main Correlation — the Long or Short result selected by Main correlation window.\n• Long Correlation — the slower Long-window Pearson correlation.\n• Display — both use signed percentages.")
col_rc    = input.bool(false, "Show short correlation", inline="columns_2", group=G_COLS, display=display.none, active=use_custom_columns)
col_beta  = input.bool(false, "Show beta", inline="columns_2", group=G_COLS, display=display.none, active=use_custom_columns, tooltip="• Short Correlation — the faster Short-window Pearson correlation.\n• Beta — chart-symbol log-return sensitivity to comparison-symbol log returns over the Long window.\n• Beta sign/magnitude — direction and relative fitted sensitivity.")
col_z     = input.bool(false, "Show spread", inline="columns_3", group=G_COLS, display=display.none, active=use_custom_columns)
col_hist  = input.bool(false, "Show history", inline="columns_3", group=G_COLS, display=display.none, active=use_custom_columns and hist_en, tooltip="• Spread — distance from the matched Long-window log-spread average, in standard deviations.\n• History — Main Correlation ranked within prior valid pair readings.\n• Requirement — Historical comparison must also be enabled.")
col_match = input.bool(false, "Show data coverage", group=G_COLS, display=display.none, active=use_custom_columns, tooltip="• Calculation — fresh comparison endpoints divided by eligible Long-window measurement positions.\n• Meaning — endpoint availability only; not quality, confidence, or correlation strength.\n• Return counts — usable Long/Short matched returns are reported separately.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Dashboard Style
// ───────────────────────────────────────────────────────────────────────────

hdr_size   = input.string("Small",  "Header text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], inline="dashboard_sizes", group=G_TEXT, display=display.none)
body_size  = input.string("Small",  "Body text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], inline="dashboard_sizes", group=G_TEXT, display=display.none, tooltip="• Header — title, measurement status, and column headings.\n• Body — data rows and line-end labels when Text size is Auto.")
hdr_txt_c  = input.color(color.white, "Header text color", inline="dashboard_text", group=G_TEXT, display=display.none)
body_txt_c = input.color(color.white, "Body text color", inline="dashboard_text", group=G_TEXT, display=display.none, tooltip="• Header text color — title, status, and headings.\n• Body text color — non-heat data cells.\n• Heat cells — use contrasting text automatically.")
hdr_bg_c   = input.color(#1e222d, "Header background", inline="dashboard_background", group=G_TEXT, display=display.none)
body_bg_c  = input.color(#131722, "Body background", inline="dashboard_background", group=G_TEXT, display=display.none, tooltip="• Header background — title, status, and headings.\n• Body background — non-heat data rows.")
tbl_bg_transp = input.int(10, "Background transparency", minval=0, maxval=100, group=G_TEXT, display=display.none, tooltip="• Higher — table cells become more transparent.\n• Lower — table cells become more opaque.\n• Master opacity — adds further fade to table cells and text, not the border or frame.")
stripe_en  = input.bool(true, "Alternating row shading", inline="dashboard_stripes", group=G_TEXT, display=display.none)
stripe_c   = input.color(#1e222d, "Row shading color", inline="dashboard_stripes", group=G_TEXT, display=display.none, active=stripe_en)
stripe_transp = input.int(40, "Row shading transparency", minval=0, maxval=100, inline="dashboard_stripes", group=G_TEXT, display=display.none, active=stripe_en, tooltip="• Color — shaded-row background.\n• Transparency — higher values make stripes fainter.\n• Master opacity — adds further fade to table cells, not the border or frame.")
border_w   = input.int(1, "Border width", minval=0, maxval=4, inline="dashboard_border", group=G_TEXT, display=display.none)
border_c   = input.color(#2a2e39, "Border color", inline="dashboard_border", group=G_TEXT, display=display.none, tooltip="• Width 0 — hides the cell grid.\n• Color — sets visible grid lines.")
frame_w    = input.int(1, "Frame width", minval=0, maxval=4, inline="dashboard_frame", group=G_TEXT, display=display.none)
frame_c    = input.color(#2a2e39, "Frame color", inline="dashboard_frame", group=G_TEXT, display=display.none, tooltip="• Width 0 — hides the outer frame.\n• Color — sets the visible frame.")
mono_c     = input.color(#787b86, "Mono coloring", group=G_TEXT, display=display.none, active=color_mode == CM_MONO, tooltip="• Dashboard — sets body text and non-heat correlation-cell color in Mono mode.\n• Comparison lines — retain slot colors.")



// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Comparison Line Style
// ───────────────────────────────────────────────────────────────────────────

reb_style   = input.string(LA_SOLID, "Line appearance", options=[LA_SOLID, LA_DASHED, LA_DOTTED, LA_STEP, LA_STEP_DIAMOND, LA_POINTS, LA_CROSSES], group=G_OVER, display=display.none, active=overlay_en, tooltip="• Solid, dashed, dotted — connected line patterns.\n• Step line — holds each value until the next bar.\n• Step with diamonds — marks value changes.\n• Points or Crosses — one marker per bar.")
reb_width   = input.int(2, "Line width", minval=1, maxval=4, inline="comparison_weight", group=G_OVER, display=display.none, active=overlay_en)
line_transp = input.int(50, "Line transparency", minval=0, maxval=100, inline="comparison_weight", group=G_OVER, display=display.none, active=overlay_en, tooltip="• Width — higher values make lines or markers more visible.\n• Transparency — higher values make them fainter.\n• Master opacity — adds further fade.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Comparison Line Starting-Point Details
// ───────────────────────────────────────────────────────────────────────────

anchor_bars = input.int(120, "Rolling bars", minval=10, maxval=1000, group=G_BASE, display=display.none, active=overlay_en and line_start == AN_BARS, tooltip="Visual only; used with Rolling N Bars.\n\n• Window — counts effective measurement bars.\n• Boundary — moves forward on each new measurement bar.\n• Each line — waits at or after that boundary for its first fresh valid endpoint.\n• Effect — a line can begin after the marker, remain blank, or jump as an old gap or move leaves the window.")
anchor_date = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Fixed date", group=G_BASE, display=display.none, active=overlay_en and line_start == AN_DATE, tooltip="Visual only; used with Fixed Date.\n\n• Base boundary — first chart-symbol measurement bar on or after the date.\n• Each line — waits at or after that boundary for fresh eligible comparison data.")
marker_en   = input.bool(true, "Show starting-point marker", inline="marker_main", group=G_BASE, display=display.none, active=overlay_en)
anc_style   = input.string("Dotted", "Marker style", options=["Solid", "Dashed", "Dotted"], inline="marker_main", group=G_BASE, display=display.none, active=overlay_en and marker_en, tooltip="Visual only.\n\n• Show starting-point marker — draws one vertical marker at the chart-symbol comparison-line boundary.\n• Marker style — selects its solid, dashed, or dotted stroke.")
anc_col     = input.color(#787b86, "Marker color", inline="marker_color", group=G_BASE, display=display.none, active=overlay_en and marker_en)
anc_transp  = input.int(50, "Marker transparency", minval=0, maxval=100, inline="marker_color", group=G_BASE, display=display.none, active=overlay_en and marker_en, tooltip="Visual only.\n\n• Color — starting-point marker color.\n• Transparency — higher values make it fainter.")
anc_width   = input.int(1, "Marker width", minval=1, maxval=4, group=G_BASE, display=display.none, active=overlay_en and marker_en, tooltip="Visual only. Sets the starting-point marker thickness.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Gap Shading
// ───────────────────────────────────────────────────────────────────────────

shade_slot   = input.int(0, "Shaded slot", minval=0, maxval=SLOT_COUNT, inline="gap_main", group=G_SHADE, display=display.none, active=overlay_en)
fill_en      = input.bool(true, "Shade the gap", inline="gap_main", group=G_SHADE, display=display.none, active=overlay_en and shade_slot > 0, tooltip="Visual only.\n\n• Shaded slot 0 turns shading off; 1–8 selects one comparison line.\n• Shade the gap fills between chart price and the selected rebased line.")
fill_up_c    = input.color(#4caf50, "Chart above color", inline="gap_colors", group=G_SHADE, display=display.none, active=overlay_en and shade_slot > 0 and fill_en)
fill_dn_c    = input.color(#ff5252, "Chart below color", inline="gap_colors", group=G_SHADE, display=display.none, active=overlay_en and shade_slot > 0 and fill_en, tooltip="Visual only.\n\n• Chart above color — used when chart price is at or above the rebased line.\n• Chart below color — used when chart price is below the rebased line.")
fill_transp  = input.int(85, "Fill transparency", minval=0, maxval=100, group=G_SHADE, display=display.none, active=overlay_en and shade_slot > 0 and fill_en, tooltip="Visual only. Higher values make the gap fill fainter.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Line-End Labels
// ───────────────────────────────────────────────────────────────────────────

end_lbl_en   = input.bool(true, "Show line-end labels", group=G_LBL, display=display.none, active=overlay_en, tooltip="Visual only. Shows configurable text at the right edge of each drawn comparison line.")
end_lbl_sym  = input.bool(true, "Include symbol name", inline="label_parts", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en)
end_lbl_pct  = input.bool(true, "Include main correlation", inline="label_parts", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en)
end_lbl_z    = input.bool(true, "Include spread", inline="label_parts", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en, tooltip="• Symbol name — slot display name.\n• Main correlation — Long or Short selected by Main correlation window.\n• Spread — signed matched Long-window z-score when available.")
end_lbl_size = input.string("Normal", "Text size", options=[LS_AUTO, "Tiny", "Small", "Normal", "Large", "Huge"], inline="label_text", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en)
end_lbl_cmode= input.string(LC_SLOT, "Text color", options=[LC_SLOT, LC_CUSTOM], inline="label_text", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en, tooltip="• Text size Auto — follows dashboard Body text size.\n• Slot color — follows each slot.\n• Custom — uses one shared label color.")
end_lbl_c    = input.color(color.white, "Custom text color", group=G_LBL, display=display.none, active=overlay_en and end_lbl_en and end_lbl_cmode == LC_CUSTOM, tooltip="Used only when Text color is Custom.")


// ───────────────────────────────────────────────────────────────────────────
// INPUTS — Global
// ───────────────────────────────────────────────────────────────────────────

master_opacity = input.int(0, "Master opacity shift", minval=0, maxval=100, group=G_VIS, display=display.none, tooltip="Adds transparency to the indicator's rendered colors.\n\n• 0 — no additional fade. Default.\n• 100 — affected colors become transparent.\n• Affected — table cells/text, comparison lines, marker, fill, and labels.\n• Excluded — table border and frame retain their own colors.")


// ───────────────────────────────────────────────────────────────────────────
// STYLE HELPERS
// Table cells/text, plots, fills, markers, and labels pass through
// applyOpacity(). Table border and frame colors do not.
// ───────────────────────────────────────────────────────────────────────────

applyOpacity(color c, int base_transp) =>
    color.new(c, math.min(100, base_transp + master_opacity))

txtSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

tblPos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.middle_right

lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Blank display names resolve to the ticker suffix.
// "NASDAQ:QQQ" -> "QQQ"
shortName(string full) =>
    parts = str.split(full, ":")
    n = array.size(parts)
    n > 0 ? array.get(parts, n - 1) : full

string chart_request_id = syminfo.main_tickerid
string chart_standard_id = ticker.standard(chart_request_id)

chartContextSymbol(simple string raw_symbol) =>
    string standard_symbol = ticker.standard(raw_symbol)
    standard_symbol == chart_standard_id ? chart_request_id : ticker.inherit(chart_request_id, standard_symbol)


// ───────────────────────────────────────────────────────────────────────────
// PRESET RESOLUTION
// Each slot resolves independently so every static request site has an explicit
// symbol identity and predictable resource cost.
// ───────────────────────────────────────────────────────────────────────────

sym1 = switch preset_group
    PG_INDICES => "AMEX:SPY"
    PG_RISK    => "SP:SPX"
    PG_FX      => "FX:EURUSD"
    PG_COMMOD  => "TVC:USOIL"
    PG_CRYPTO  => "BITSTAMP:BTCUSD"
    => s1_sym

sym2 = switch preset_group
    PG_INDICES => "NASDAQ:QQQ"
    PG_RISK    => "TVC:DXY"
    PG_FX      => "FX:GBPUSD"
    PG_COMMOD  => "TVC:UKOIL"
    PG_CRYPTO  => "BITSTAMP:ETHUSD"
    => s2_sym

sym3 = switch preset_group
    PG_INDICES => "AMEX:IWM"
    PG_RISK    => "NASDAQ:TLT"
    PG_FX      => "FX:USDJPY"
    PG_COMMOD  => "TVC:GOLD"
    PG_CRYPTO  => "BINANCE:SOLUSDT"
    => s3_sym

sym4 = switch preset_group
    PG_INDICES => "AMEX:DIA"
    PG_RISK    => "TVC:GOLD"
    PG_FX      => "FX:AUDUSD"
    PG_COMMOD  => "TVC:SILVER"
    PG_CRYPTO  => "BINANCE:BNBUSDT"
    => s4_sym

sym5 = switch preset_group
    PG_INDICES => "AMEX:XLK"
    PG_RISK    => "BITSTAMP:BTCUSD"
    PG_FX      => "FX:USDCAD"
    PG_COMMOD  => "COMEX:HG1!"
    PG_CRYPTO  => "BINANCE:XRPUSDT"
    => s5_sym

sym6 = switch preset_group
    PG_INDICES => "AMEX:XLF"
    PG_RISK    => "TVC:VIX"
    PG_FX      => "FX:USDCHF"
    PG_COMMOD  => "NYMEX:NG1!"
    PG_CRYPTO  => "BINANCE:ADAUSDT"
    => s6_sym

sym7 = switch preset_group
    PG_INDICES => "AMEX:XLE"
    PG_RISK    => "AMEX:HYG"
    PG_FX      => "FX:NZDUSD"
    PG_COMMOD  => "TVC:PLATINUM"
    PG_CRYPTO  => "BINANCE:AVAXUSDT"
    => s7_sym

sym8 = switch preset_group
    PG_INDICES => "AMEX:XLV"
    PG_RISK    => "TVC:USOIL"
    PG_FX      => "TVC:DXY"
    PG_COMMOD  => "CBOT:ZC1!"
    PG_CRYPTO  => "BINANCE:DOGEUSDT"
    => s8_sym


// ───────────────────────────────────────────────────────────────────────────
// REQUEST CONTEXT
// Nonblank slots inherit applicable chart modifiers. Matching standardized
// tickers reuse the exact chart request ID. Blank fallbacks remain hidden.
// ───────────────────────────────────────────────────────────────────────────

bool blank1 = str.length(sym1) == 0
bool blank2 = str.length(sym2) == 0
bool blank3 = str.length(sym3) == 0
bool blank4 = str.length(sym4) == 0
bool blank5 = str.length(sym5) == 0
bool blank6 = str.length(sym6) == 0
bool blank7 = str.length(sym7) == 0
bool blank8 = str.length(sym8) == 0

bool active1 = s1_en and not blank1
bool active2 = s2_en and not blank2
bool active3 = s3_en and not blank3
bool active4 = s4_en and not blank4
bool active5 = s5_en and not blank5
bool active6 = s6_en and not blank6
bool active7 = s7_en and not blank7
bool active8 = s8_en and not blank8

string fsym1 = blank1 ? chart_request_id : chartContextSymbol(sym1)
string fsym2 = blank2 ? chart_request_id : chartContextSymbol(sym2)
string fsym3 = blank3 ? chart_request_id : chartContextSymbol(sym3)
string fsym4 = blank4 ? chart_request_id : chartContextSymbol(sym4)
string fsym5 = blank5 ? chart_request_id : chartContextSymbol(sym5)
string fsym6 = blank6 ? chart_request_id : chartContextSymbol(sym6)
string fsym7 = blank7 ? chart_request_id : chartContextSymbol(sym7)
string fsym8 = blank8 ? chart_request_id : chartContextSymbol(sym8)


// ───────────────────────────────────────────────────────────────────────────
// SLOT CONSTRUCTION
// ───────────────────────────────────────────────────────────────────────────

var array<CorrSlot> slots = array.new<CorrSlot>()

if barstate.isfirst
    syms   = array.from(sym1, sym2, sym3, sym4, sym5, sym6, sym7, sym8)
    labels = array.from(s1_lbl, s2_lbl, s3_lbl, s4_lbl, s5_lbl, s6_lbl, s7_lbl, s8_lbl)
    enab   = array.from(active1, active2, active3, active4, active5, active6, active7, active8)
    cols   = array.from(s1_col, s2_col, s3_col, s4_col, s5_col, s6_col, s7_col, s8_col)

    if array.size(syms) >= SLOT_COUNT
        for i = 0 to SLOT_COUNT - 1
            tkr = array.get(syms, i)
            lbl = preset_group == PG_CUSTOM ? array.get(labels, i) : ""
            array.push(slots, CorrSlot.new(enabled = array.get(enab, i), sym = tkr, disp = str.length(lbl) > 0 ? lbl : shortName(tkr), col = array.get(cols, i)))


// ───────────────────────────────────────────────────────────────────────────
// DATA FETCH
// Nine static request sites make request identity and resource use predictable.
// Every tuple keeps prices and source timestamps under one confirmation policy.
// Each request exposes literal current/prior fields. For higher timeframes,
// chart-context selectors pass only confirmed prior fields downstream; current
// fields returned under lookahead_on never enter calculations. Equal-timeframe
// requests use lookahead_off and commit only on chart confirmation. Lower
// selections fall back to the chart.
// ───────────────────────────────────────────────────────────────────────────

if not chart.is_standard or timeframe.isticks
    runtime.error("Correlation Matrix [AFD] requires standard time-based candles.")

selectRequestedBase(bool use_prior, float c0, float c1, float c2, float o0, float o1, int t0, int t1, int tc0, int tc1, int tc2, int session0, int session1, int year0, int year1) =>
    [use_prior ? c1 : c0, use_prior ? c2 : c1, use_prior ? o1 : o0, use_prior ? t1 : t0, use_prior ? tc1 : tc0, use_prior ? tc2 : tc1, use_prior ? session1 : session0, use_prior ? year1 : year0]

selectRequestedComparison(bool use_prior, float c0, float c1, float c2, float o0, float o1, float o2, int t0, int t1, int t2, int tc0, int tc1, int tc2) =>
    [use_prior ? c1 : c0, use_prior ? c2 : c1, use_prior ? o1 : o0, use_prior ? o2 : o1, use_prior ? t1 : t0, use_prior ? t2 : t1, use_prior ? tc1 : tc0, use_prior ? tc2 : tc1]

bool  calc_follows_chart = calc_tf == ""
string req_tf = calc_follows_chart ? timeframe.period : calc_tf
float chart_tf_sec = timeframe.in_seconds(timeframe.period)
float req_tf_sec   = timeframe.in_seconds(req_tf)
bool  lower_tf     = not na(chart_tf_sec) and not na(req_tf_sec) and req_tf_sec < chart_tf_sec
string calc_req_tf = lower_tf ? timeframe.period : req_tf
float calc_tf_sec  = timeframe.in_seconds(calc_req_tf)
bool  higher_tf    = not na(chart_tf_sec) and not na(calc_tf_sec) and calc_tf_sec > chart_tf_sec

[base_c0, base_c1, base_c2, base_o0, base_o1, base_t0, base_t1, base_tc0, base_tc1, base_tc2, base_session0, base_session1, base_year0, base_year1] = request.security(chart_request_id, calc_req_tf, [close, close[1], close[2], open, open[1], time, time[1], time_close, time_close[1], time_close[2], time("D"), time("D")[1], year, year[1]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off)

[c1_0, c1_1, c1_2, o1_0, o1_1, o1_2, t1_0, t1_1, t1_2, tc1_0, tc1_1, tc1_2] = request.security(fsym1, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c2_0, c2_1, c2_2, o2_0, o2_1, o2_2, t2_0, t2_1, t2_2, tc2_0, tc2_1, tc2_2] = request.security(fsym2, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c3_0, c3_1, c3_2, o3_0, o3_1, o3_2, t3_0, t3_1, t3_2, tc3_0, tc3_1, tc3_2] = request.security(fsym3, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c4_0, c4_1, c4_2, o4_0, o4_1, o4_2, t4_0, t4_1, t4_2, tc4_0, tc4_1, tc4_2] = request.security(fsym4, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c5_0, c5_1, c5_2, o5_0, o5_1, o5_2, t5_0, t5_1, t5_2, tc5_0, tc5_1, tc5_2] = request.security(fsym5, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c6_0, c6_1, c6_2, o6_0, o6_1, o6_2, t6_0, t6_1, t6_2, tc6_0, tc6_1, tc6_2] = request.security(fsym6, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c7_0, c7_1, c7_2, o7_0, o7_1, o7_2, t7_0, t7_1, t7_2, tc7_0, tc7_1, tc7_2] = request.security(fsym7, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
[c8_0, c8_1, c8_2, o8_0, o8_1, o8_2, t8_0, t8_1, t8_2, tc8_0, tc8_1, tc8_2] = request.security(fsym8, calc_req_tf, [close, close[1], close[2], open, open[1], open[2], time, time[1], time[2], time_close, time_close[1], time_close[2]], gaps=barmerge.gaps_off, lookahead=higher_tf ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)

[base_c, base_prev_c, base_o, base_t, base_tc, base_prev_tc, base_session_t, base_year] = selectRequestedBase(higher_tf, base_c0, base_c1, base_c2, base_o0, base_o1, base_t0, base_t1, base_tc0, base_tc1, base_tc2, base_session0, base_session1, base_year0, base_year1)

[c1_raw, c1_prev_raw, o1_raw, o1_prev_raw, t1_raw, t1_prev_raw, tc1_raw, tc1_prev_raw] = selectRequestedComparison(higher_tf, c1_0, c1_1, c1_2, o1_0, o1_1, o1_2, t1_0, t1_1, t1_2, tc1_0, tc1_1, tc1_2)
[c2_raw, c2_prev_raw, o2_raw, o2_prev_raw, t2_raw, t2_prev_raw, tc2_raw, tc2_prev_raw] = selectRequestedComparison(higher_tf, c2_0, c2_1, c2_2, o2_0, o2_1, o2_2, t2_0, t2_1, t2_2, tc2_0, tc2_1, tc2_2)
[c3_raw, c3_prev_raw, o3_raw, o3_prev_raw, t3_raw, t3_prev_raw, tc3_raw, tc3_prev_raw] = selectRequestedComparison(higher_tf, c3_0, c3_1, c3_2, o3_0, o3_1, o3_2, t3_0, t3_1, t3_2, tc3_0, tc3_1, tc3_2)
[c4_raw, c4_prev_raw, o4_raw, o4_prev_raw, t4_raw, t4_prev_raw, tc4_raw, tc4_prev_raw] = selectRequestedComparison(higher_tf, c4_0, c4_1, c4_2, o4_0, o4_1, o4_2, t4_0, t4_1, t4_2, tc4_0, tc4_1, tc4_2)
[c5_raw, c5_prev_raw, o5_raw, o5_prev_raw, t5_raw, t5_prev_raw, tc5_raw, tc5_prev_raw] = selectRequestedComparison(higher_tf, c5_0, c5_1, c5_2, o5_0, o5_1, o5_2, t5_0, t5_1, t5_2, tc5_0, tc5_1, tc5_2)
[c6_raw, c6_prev_raw, o6_raw, o6_prev_raw, t6_raw, t6_prev_raw, tc6_raw, tc6_prev_raw] = selectRequestedComparison(higher_tf, c6_0, c6_1, c6_2, o6_0, o6_1, o6_2, t6_0, t6_1, t6_2, tc6_0, tc6_1, tc6_2)
[c7_raw, c7_prev_raw, o7_raw, o7_prev_raw, t7_raw, t7_prev_raw, tc7_raw, tc7_prev_raw] = selectRequestedComparison(higher_tf, c7_0, c7_1, c7_2, o7_0, o7_1, o7_2, t7_0, t7_1, t7_2, tc7_0, tc7_1, tc7_2)
[c8_raw, c8_prev_raw, o8_raw, o8_prev_raw, t8_raw, t8_prev_raw, tc8_raw, tc8_prev_raw] = selectRequestedComparison(higher_tf, c8_0, c8_1, c8_2, o8_0, o8_1, o8_2, t8_0, t8_1, t8_2, tc8_0, tc8_1, tc8_2)

// The latest comparison endpoint known by the base close is mapped to the
// nearer current or prior base close. A tie stays on the current base endpoint.
// Returns are later formed between consecutive shared endpoint pairs.
resolveSource(float src_c, float src_prev, float src_o, float src_prev_o, int src_t, int src_prev_t, int src_tc, int src_prev_tc) =>
    bool use_prior_source = not na(base_tc) and not na(src_tc) and src_tc > base_tc
    float selected_c = use_prior_source ? src_prev : src_c
    float selected_o = use_prior_source ? src_prev_o : src_o
    int selected_t = use_prior_source ? src_prev_t : src_t
    int selected_tc = use_prior_source ? src_prev_tc : src_tc
    bool causal = not na(base_tc) and not na(selected_tc) and selected_tc <= base_tc
    int current_distance = causal ? math.abs(base_tc - selected_tc) : int(na)
    int prior_distance = causal and not na(base_prev_tc) ? math.abs(base_prev_tc - selected_tc) : int(na)
    bool use_prior_base = not na(prior_distance) and (na(current_distance) or prior_distance < current_distance)
    float paired_base_c = use_prior_base ? base_prev_c : base_c
    int paired_base_tc = use_prior_base ? base_prev_tc : base_tc
    [causal ? selected_c : float(na), causal ? selected_o : float(na), causal ? selected_t : int(na), causal ? selected_tc : int(na), causal ? paired_base_c : float(na), causal ? paired_base_tc : int(na), causal and use_prior_base]

[c1, o1, t1, tc1, bc1, btc1, lg1] = resolveSource(c1_raw, c1_prev_raw, o1_raw, o1_prev_raw, t1_raw, t1_prev_raw, tc1_raw, tc1_prev_raw)
[c2, o2, t2, tc2, bc2, btc2, lg2] = resolveSource(c2_raw, c2_prev_raw, o2_raw, o2_prev_raw, t2_raw, t2_prev_raw, tc2_raw, tc2_prev_raw)
[c3, o3, t3, tc3, bc3, btc3, lg3] = resolveSource(c3_raw, c3_prev_raw, o3_raw, o3_prev_raw, t3_raw, t3_prev_raw, tc3_raw, tc3_prev_raw)
[c4, o4, t4, tc4, bc4, btc4, lg4] = resolveSource(c4_raw, c4_prev_raw, o4_raw, o4_prev_raw, t4_raw, t4_prev_raw, tc4_raw, tc4_prev_raw)
[c5, o5, t5, tc5, bc5, btc5, lg5] = resolveSource(c5_raw, c5_prev_raw, o5_raw, o5_prev_raw, t5_raw, t5_prev_raw, tc5_raw, tc5_prev_raw)
[c6, o6, t6, tc6, bc6, btc6, lg6] = resolveSource(c6_raw, c6_prev_raw, o6_raw, o6_prev_raw, t6_raw, t6_prev_raw, tc6_raw, tc6_prev_raw)
[c7, o7, t7, tc7, bc7, btc7, lg7] = resolveSource(c7_raw, c7_prev_raw, o7_raw, o7_prev_raw, t7_raw, t7_prev_raw, tc7_raw, tc7_prev_raw)
[c8, o8, t8, tc8, bc8, btc8, lg8] = resolveSource(c8_raw, c8_prev_raw, o8_raw, o8_prev_raw, t8_raw, t8_prev_raw, tc8_raw, tc8_prev_raw)


// ───────────────────────────────────────────────────────────────────────────
// DATA COVERAGE
// gaps_off can repeat a source tuple on later chart bars. Timestamp advancement
// identifies fresh comparison observations and excludes repeated tuples.
// Each written function call maintains independent `var` history for one slot.
// ───────────────────────────────────────────────────────────────────────────

printedBar(int t) =>
    na(t) ? false : na(t[1]) ? true : t != t[1]

// Comparison timestamp advancement is sampled whenever the chart-base timestamp
// advances, preserving observations from asynchronously closing sessions.
advancedAtBase(int sym_tc, bool base_hit, bool active) =>
    var int prior_sym_tc = na
    bool advanced = false
    if base_hit and active
        advanced := not na(sym_tc) and (na(prior_sym_tc) or sym_tc != prior_sym_tc)
        if not na(sym_tc)
            prior_sym_tc := sym_tc
    advanced

matchStats(bool base_hit, bool sym_hit, bool sym_exists, bool active, int len) =>
    var array<bool> hits   = array.new<bool>()
    var array<bool> exists = array.new<bool>()
    var int fresh_count = 0
    var int eligible_count = 0
    var float cached_pct = na
    if base_hit and active
        array.push(hits, sym_hit)
        array.push(exists, sym_exists)
        fresh_count += sym_hit ? 1 : 0
        eligible_count += sym_exists ? 1 : 0
        if array.size(hits) > len
            bool removed_hit = array.shift(hits)
            bool removed_exists = array.shift(exists)
            fresh_count -= removed_hit ? 1 : 0
            eligible_count -= removed_exists ? 1 : 0
        // Coverage is normalized over chart-base observations after the
        // comparison symbol first existed.
        cached_pct := array.size(hits) < len or eligible_count <= 0 ? float(na) : math.min(100.0, fresh_count / eligible_count * 100.0)
    [active ? cached_pct : float(na), active ? fresh_count : 0, active ? eligible_count : 0]

// printedBar() reads history and therefore executes before lazy expressions.
bool base_printed = printedBar(base_tc)
// Every persistent measurement window advances once, on chart confirmation. A
// higher-timeframe tuple is already confirmed by its expression offset;
// waiting for this chart confirmation prevents repeated realtime-tick scans.
bool source_sample = base_printed and barstate.isconfirmed

bool sym1_at_base = advancedAtBase(tc1, source_sample, active1)
bool sym2_at_base = advancedAtBase(tc2, source_sample, active2)
bool sym3_at_base = advancedAtBase(tc3, source_sample, active3)
bool sym4_at_base = advancedAtBase(tc4, source_sample, active4)
bool sym5_at_base = advancedAtBase(tc5, source_sample, active5)
bool sym6_at_base = advancedAtBase(tc6, source_sample, active6)
bool sym7_at_base = advancedAtBase(tc7, source_sample, active7)
bool sym8_at_base = advancedAtBase(tc8, source_sample, active8)

[mp1, mf1, me1] = matchStats(source_sample, sym1_at_base, not na(tc1), active1, long_len)
[mp2, mf2, me2] = matchStats(source_sample, sym2_at_base, not na(tc2), active2, long_len)
[mp3, mf3, me3] = matchStats(source_sample, sym3_at_base, not na(tc3), active3, long_len)
[mp4, mf4, me4] = matchStats(source_sample, sym4_at_base, not na(tc4), active4, long_len)
[mp5, mf5, me5] = matchStats(source_sample, sym5_at_base, not na(tc5), active5, long_len)
[mp6, mf6, me6] = matchStats(source_sample, sym6_at_base, not na(tc6), active6, long_len)
[mp7, mf7, me7] = matchStats(source_sample, sym7_at_base, not na(tc7), active7, long_len)
[mp8, mf8, me8] = matchStats(source_sample, sym8_at_base, not na(tc8), active8, long_len)


// ───────────────────────────────────────────────────────────────────────────
// CORRELATION, BETA, AND SPREAD
// Pearson correlation and beta use centered online moments for numerical
// stability. Ratio-form and product-form log-spread histories remain separate
// and are selected by the sign of Long Correlation.
// ───────────────────────────────────────────────────────────────────────────

arrayMoments(array<float> xs, array<float> ys, int len) =>
    int total = math.min(array.size(xs), array.size(ys))
    int used  = math.min(total, len)
    bool full_window = total >= len
    int n = 0
    float mean_x = 0.0
    float mean_y = 0.0
    float m2_x = 0.0
    float m2_y = 0.0
    float co_moment = 0.0
    if used > 0
        int first = total - used
        for j = first to total - 1
            float x = array.get(xs, j)
            float y = array.get(ys, j)
            if not na(x) and not na(y)
                n += 1
                float dx = x - mean_x
                mean_x += dx / n
                float dy = y - mean_y
                mean_y += dy / n
                m2_x += dx * (x - mean_x)
                m2_y += dy * (y - mean_y)
                co_moment += dx * (y - mean_y)
    bool sample_valid = full_window and n >= 3
    float variance_x = n > 0 ? m2_x / n : float(na)
    float variance_y = n > 0 ? m2_y / n : float(na)
    bool corr_valid = sample_valid and variance_x > MOMENT_EPS and variance_y > MOMENT_EPS
    bool beta_valid = sample_valid and variance_y > MOMENT_EPS
    float r = corr_valid ? co_moment / math.sqrt(m2_x * m2_y) : float(na)
    float beta = beta_valid ? co_moment / m2_y : float(na)
    [r, beta, n]

arrayZ(array<float> values, int len) =>
    int total = array.size(values)
    int used  = math.min(total, len)
    bool full_window = total >= len
    int n = 0
    float mean = 0.0
    float m2 = 0.0
    if used > 0
        int first = total - used
        for j = first to total - 1
            float v = array.get(values, j)
            if not na(v)
                n += 1
                float delta = v - mean
                mean += delta / n
                m2 += delta * (v - mean)
    float variance = n > 0 ? m2 / n : float(na)
    float dev = not full_window or n < 2 or variance <= MOMENT_EPS ? float(na) : math.sqrt(variance)
    float last = total > 0 ? array.get(values, total - 1) : float(na)
    na(last) or na(dev) ? float(na) : (last - mean) / dev

// Every calculation path uses one buffer position per chart-base measurement
// observation. Unmatched comparisons append na, preserving an N-position
// window. A fresh endpoint pair is measured from the preceding accepted pair,
// so both log returns cover the same shared interval after gaps.
sourceMath(float base_px, int base_end_tc, float sym_px, int sym_end_tc, bool fresh, bool active, int len_l, int len_s) =>
    var array<float> xs      = array.new<float>()
    var array<float> ys      = array.new<float>()
    var array<float> sp_difs = array.new<float>()
    var array<float> sp_sums = array.new<float>()
    var float prior_base_px = na
    var float prior_sym_px = na
    var int prior_base_tc = na
    var int prior_sym_tc = na
    var float cached_rl   = na
    var float cached_rs   = na
    var float cached_dr   = na
    var float cached_beta = na
    var float cached_z    = na
    var int cached_nl = 0
    var int cached_ns = 0

    if source_sample and active
        float ret_base = na
        float ret_sym = na
        bool endpoint_valid = fresh and not na(base_px) and base_px > 0 and not na(sym_px) and sym_px > 0 and not na(base_end_tc) and not na(sym_end_tc)
        if fresh
            if endpoint_valid
                bool has_prior = not na(prior_base_px) and not na(prior_sym_px) and not na(prior_base_tc) and not na(prior_sym_tc)
                bool advances = has_prior and base_end_tc > prior_base_tc and sym_end_tc > prior_sym_tc
                if not has_prior or advances
                    if advances
                        ret_base := math.log(base_px / prior_base_px)
                        ret_sym := math.log(sym_px / prior_sym_px)
                    prior_base_px := base_px
                    prior_sym_px := sym_px
                    prior_base_tc := base_end_tc
                    prior_sym_tc := sym_end_tc
            else
                prior_base_px := na
                prior_sym_px := na
                prior_base_tc := na
                prior_sym_tc := na

        bool pair_ok = not na(ret_base) and not na(ret_sym)
        array.push(xs, pair_ok ? ret_base : float(na))
        array.push(ys, pair_ok ? ret_sym : float(na))
        array.push(sp_difs, pair_ok ? math.log(base_px) - math.log(sym_px) : float(na))
        array.push(sp_sums, pair_ok ? math.log(base_px) + math.log(sym_px) : float(na))
        if array.size(xs) > len_l
            array.shift(xs)
            array.shift(ys)
            array.shift(sp_difs)
            array.shift(sp_sums)

        [next_rl, next_beta, next_nl] = arrayMoments(xs, ys, len_l)
        [next_rs, _, next_ns] = arrayMoments(xs, ys, len_s)
        next_rl := na(next_rl) ? na : math.max(-1.0, math.min(1.0, next_rl))
        next_rs := na(next_rs) ? na : math.max(-1.0, math.min(1.0, next_rs))
        float next_dr = na(next_rl) or na(next_rs) ? na : next_rs - next_rl
        float z_dif = arrayZ(sp_difs, len_l)
        float z_sum = arrayZ(sp_sums, len_l)
        float next_z = na(next_rl) ? float(na) : next_rl >= 0 ? z_dif : z_sum
        cached_rl   := next_rl
        cached_rs   := next_rs
        cached_dr   := next_dr
        cached_beta := next_beta
        cached_z    := next_z
        cached_nl   := next_nl
        cached_ns   := next_ns

    [active ? cached_rl : float(na), active ? cached_rs : float(na), active ? cached_dr : float(na), active ? cached_beta : float(na), active ? cached_z : float(na), active ? cached_nl : 0, active ? cached_ns : 0]

// ── Percent readout and historical context ─────────────────────────────────
// The selected correlation source feeds both dashboard and line-end percentage
// text. Historical statistics use the same measurement clock.
pctSrcVal(float rl, float rs) =>
    pct_is_long ? rl : rs

pctOf(float rl, float rs) =>
    float r = pctSrcVal(rl, rs)
    na(r) ? float(na) : r * 100.0

histStats(float src, int len, bool active) =>
    var array<float> source_values = array.new<float>()
    var float cached_rank = na
    var float cached_lo   = na
    var float cached_hi   = na
    var float cached_avg  = na
    var int cached_n = 0
    if hist_en and active
        if source_sample
            array.push(source_values, src)
            if array.size(source_values) > len
                array.shift(source_values)
        int total = array.size(source_values)
        if total >= len and (barstate.islastconfirmedhistory or (source_sample and barstate.islast))
            cached_rank := na
            cached_lo   := na
            cached_hi   := na
            cached_avg  := na
            cached_n    := 0
            float current = array.get(source_values, total - 1)
            float source_sum = 0.0
            int lower = 0
            int equal = 0
            if not na(current)
                for j = 0 to total - 2
                    float v = array.get(source_values, j)
                    if not na(v)
                        cached_n += 1
                        source_sum += v
                        cached_lo := na(cached_lo) ? v : math.min(cached_lo, v)
                        cached_hi := na(cached_hi) ? v : math.max(cached_hi, v)
                        if v < current
                            lower += 1
                        else if v == current
                            equal += 1
                cached_avg := cached_n > 0 ? source_sum / cached_n : float(na)
                cached_rank := cached_n > 0 ? (lower + 0.5 * equal) / cached_n * 100.0 : float(na)

    [hist_en and active ? cached_rank : float(na), hist_en and active ? cached_lo : float(na), hist_en and active ? cached_hi : float(na), hist_en and active ? cached_avg : float(na), hist_en and active ? cached_n : 0]

bool m1 = source_sample and sym1_at_base and not na(c1) and c1 > 0 and not na(bc1) and bc1 > 0 and not na(tc1) and not na(btc1)
bool m2 = source_sample and sym2_at_base and not na(c2) and c2 > 0 and not na(bc2) and bc2 > 0 and not na(tc2) and not na(btc2)
bool m3 = source_sample and sym3_at_base and not na(c3) and c3 > 0 and not na(bc3) and bc3 > 0 and not na(tc3) and not na(btc3)
bool m4 = source_sample and sym4_at_base and not na(c4) and c4 > 0 and not na(bc4) and bc4 > 0 and not na(tc4) and not na(btc4)
bool m5 = source_sample and sym5_at_base and not na(c5) and c5 > 0 and not na(bc5) and bc5 > 0 and not na(tc5) and not na(btc5)
bool m6 = source_sample and sym6_at_base and not na(c6) and c6 > 0 and not na(bc6) and bc6 > 0 and not na(tc6) and not na(btc6)
bool m7 = source_sample and sym7_at_base and not na(c7) and c7 > 0 and not na(bc7) and bc7 > 0 and not na(tc7) and not na(btc7)
bool m8 = source_sample and sym8_at_base and not na(c8) and c8 > 0 and not na(bc8) and bc8 > 0 and not na(tc8) and not na(btc8)

[rl1, rs1, dr1, bt1, z1, nl1, ns1] = sourceMath(bc1, btc1, c1, tc1, sym1_at_base, active1, long_len, current_len)
[rl2, rs2, dr2, bt2, z2, nl2, ns2] = sourceMath(bc2, btc2, c2, tc2, sym2_at_base, active2, long_len, current_len)
[rl3, rs3, dr3, bt3, z3, nl3, ns3] = sourceMath(bc3, btc3, c3, tc3, sym3_at_base, active3, long_len, current_len)
[rl4, rs4, dr4, bt4, z4, nl4, ns4] = sourceMath(bc4, btc4, c4, tc4, sym4_at_base, active4, long_len, current_len)
[rl5, rs5, dr5, bt5, z5, nl5, ns5] = sourceMath(bc5, btc5, c5, tc5, sym5_at_base, active5, long_len, current_len)
[rl6, rs6, dr6, bt6, z6, nl6, ns6] = sourceMath(bc6, btc6, c6, tc6, sym6_at_base, active6, long_len, current_len)
[rl7, rs7, dr7, bt7, z7, nl7, ns7] = sourceMath(bc7, btc7, c7, tc7, sym7_at_base, active7, long_len, current_len)
[rl8, rs8, dr8, bt8, z8, nl8, ns8] = sourceMath(bc8, btc8, c8, tc8, sym8_at_base, active8, long_len, current_len)

pc1 = pctOf(rl1, rs1)
pc2 = pctOf(rl2, rs2)
pc3 = pctOf(rl3, rs3)
pc4 = pctOf(rl4, rs4)
pc5 = pctOf(rl5, rs5)
pc6 = pctOf(rl6, rs6)
pc7 = pctOf(rl7, rs7)
pc8 = pctOf(rl8, rs8)

[hk1, hlo1, hh1, ha1, hn1] = histStats(pctSrcVal(rl1, rs1), hist_len, active1)
[hk2, hlo2, hh2, ha2, hn2] = histStats(pctSrcVal(rl2, rs2), hist_len, active2)
[hk3, hlo3, hh3, ha3, hn3] = histStats(pctSrcVal(rl3, rs3), hist_len, active3)
[hk4, hlo4, hh4, ha4, hn4] = histStats(pctSrcVal(rl4, rs4), hist_len, active4)
[hk5, hlo5, hh5, ha5, hn5] = histStats(pctSrcVal(rl5, rs5), hist_len, active5)
[hk6, hlo6, hh6, ha6, hn6] = histStats(pctSrcVal(rl6, rs6), hist_len, active6)
[hk7, hlo7, hh7, ha7, hn7] = histStats(pctSrcVal(rl7, rs7), hist_len, active7)
[hk8, hlo8, hh8, ha8, hn8] = histStats(pctSrcVal(rl8, rs8), hist_len, active8)


// ───────────────────────────────────────────────────────────────────────────
// SLOT WRITE-BACK
// Equal-timeframe values commit on their chart bar. Higher-timeframe values
// commit when the first chart bar carrying the new confirmed tuple closes.
// ───────────────────────────────────────────────────────────────────────────

bar_closes = array.from(c1,  c2,  c3,  c4,  c5,  c6,  c7,  c8)
bar_match  = array.from(mp1, mp2, mp3, mp4, mp5, mp6, mp7, mp8)
bar_fresh  = array.from(mf1, mf2, mf3, mf4, mf5, mf6, mf7, mf8)
bar_eligible = array.from(me1, me2, me3, me4, me5, me6, me7, me8)
bar_sample = array.from(m1,  m2,  m3,  m4,  m5,  m6,  m7,  m8)
bar_lag    = array.from(lg1, lg2, lg3, lg4, lg5, lg6, lg7, lg8)
bar_active = array.from(active1, active2, active3, active4, active5, active6, active7, active8)
bar_rl     = array.from(rl1, rl2, rl3, rl4, rl5, rl6, rl7, rl8)
bar_rs     = array.from(rs1, rs2, rs3, rs4, rs5, rs6, rs7, rs8)
bar_nl     = array.from(nl1, nl2, nl3, nl4, nl5, nl6, nl7, nl8)
bar_ns     = array.from(ns1, ns2, ns3, ns4, ns5, ns6, ns7, ns8)
bar_dr     = array.from(dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8)
bar_beta   = array.from(bt1, bt2, bt3, bt4, bt5, bt6, bt7, bt8)
bar_z      = array.from(z1,  z2,  z3,  z4,  z5,  z6,  z7,  z8)
bar_pct    = array.from(pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8)
bar_hrank  = array.from(hk1, hk2, hk3, hk4, hk5, hk6, hk7, hk8)
bar_hlo    = array.from(hlo1, hlo2, hlo3, hlo4, hlo5, hlo6, hlo7, hlo8)
bar_hhi    = array.from(hh1, hh2, hh3, hh4, hh5, hh6, hh7, hh8)
bar_havg   = array.from(ha1, ha2, ha3, ha4, ha5, ha6, ha7, ha8)
bar_hn     = array.from(hn1, hn2, hn3, hn4, hn5, hn6, hn7, hn8)

bool measurement_ready = source_sample or (hist_en and barstate.islastconfirmedhistory)

if measurement_ready and array.size(slots) == SLOT_COUNT
    for i = 0 to SLOT_COUNT - 1
        CorrSlot s = array.get(slots, i)
        s.match_pct  := array.get(bar_match,  i)
        s.match_fresh := array.get(bar_fresh, i)
        s.match_eligible := array.get(bar_eligible, i)
        s.n_long     := array.get(bar_nl, i)
        s.n_short    := array.get(bar_ns, i)
        bool slot_active = array.get(bar_active, i)
        float slot_close = array.get(bar_closes, i)
        s.data_seen  := s.data_seen or (slot_active and not na(slot_close) and slot_close > 0)
        bool matched_now = array.get(bar_sample, i)
        if matched_now
            s.lag_adj := array.get(bar_lag, i)
        s.r_long      := array.get(bar_rl,     i)
        s.r_short     := array.get(bar_rs,     i)
        s.dr          := array.get(bar_dr,     i)
        s.beta        := array.get(bar_beta,   i)
        s.spread_z    := array.get(bar_z,      i)
        s.r_pct       := array.get(bar_pct,    i)
        s.r_hist_rank := array.get(bar_hrank,  i)
        s.r_hist_lo   := array.get(bar_hlo,    i)
        s.r_hist_hi   := array.get(bar_hhi,    i)
        s.r_hist_avg  := array.get(bar_havg,   i)
        s.r_hist_n    := array.get(bar_hn,     i)
// ───────────────────────────────────────────────────────────────────────────
// DASHBOARD VIEW RESOLUTION
// Resolved e_* values apply either the selected Dashboard view or the explicit
// custom column override.
//   Context — Symbol · Long · Short · Spread · Data Coverage.
//   Compact — Symbol · Short · Spread at tiny text.
//   Full    — all non-duplicate measurements plus optional History.
//   Minimal — Symbol · Main Correlation at tiny text.
// Correlation Difference is independently available in every view.
// Dashboard views never affect chart drawings.
// ───────────────────────────────────────────────────────────────────────────

bool p_comp = visual_preset == VP_COMPACT
bool p_min  = visual_preset == VP_MINIMAL

e_col_rl = use_custom_columns ? col_rl : (visual_preset == VP_CONTEXT or visual_preset == VP_FULL)

e_col_rc = use_custom_columns ? col_rc : (visual_preset == VP_CONTEXT or visual_preset == VP_COMPACT or visual_preset == VP_FULL)

e_col_dr = show_difference

e_col_beta = use_custom_columns ? col_beta : visual_preset == VP_FULL

e_col_z = use_custom_columns ? col_z : (visual_preset == VP_CONTEXT or visual_preset == VP_COMPACT or visual_preset == VP_FULL)

e_col_match = use_custom_columns ? col_match : (visual_preset == VP_CONTEXT or visual_preset == VP_FULL)

e_col_pct = use_custom_columns ? col_pct : visual_preset == VP_MINIMAL

e_col_hist = use_custom_columns ? (col_hist and hist_en) : (visual_preset == VP_FULL and hist_en)

e_hdr_size  = p_comp or p_min ? "Tiny" : hdr_size
e_body_size = p_comp or p_min ? "Tiny" : body_size

e_overlay_en = overlay_en


// ───────────────────────────────────────────────────────────────────────────
// SLOT DRAW SELECTION
// Enabled, nonblank slots draw independently. Disabled and blank slots remain
// hidden from both the dashboard and chart.
// ───────────────────────────────────────────────────────────────────────────

bool dw1 = e_overlay_en and s1_en and s1_show and not blank1
bool dw2 = e_overlay_en and s2_en and s2_show and not blank2
bool dw3 = e_overlay_en and s3_en and s3_show and not blank3
bool dw4 = e_overlay_en and s4_en and s4_show and not blank4
bool dw5 = e_overlay_en and s5_en and s5_show and not blank5
bool dw6 = e_overlay_en and s6_en and s6_show and not blank6
bool dw7 = e_overlay_en and s7_en and s7_show and not blank7
bool dw8 = e_overlay_en and s8_en and s8_show and not blank8

bool any_draw = dw1 or dw2 or dw3 or dw4 or dw5 or dw6 or dw7 or dw8


// ───────────────────────────────────────────────────────────────────────────
// DASHBOARD
// The table is allocated once and populated on the last bar.
// ───────────────────────────────────────────────────────────────────────────

num(float v, string fmt) =>
    na(v) ? "—" : str.tostring(v, fmt)

pctText(float v) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "#") + "%"

corrText(float r) =>
    na(r) ? "—" : pctText(r * 100.0)

// Difference is Short minus Long and displays in rounded whole percentage points.
drText(float v) =>
    int points = int(math.round(v * 100.0))
    na(v) ? "—" : (points > 0 ? "+" : "") + str.tostring(points, "#")

histBand(float p) =>
    na(p) ? "" : p < 20 ? "Low" : p < 40 ? "Below Usual" : p < 60 ? "Usual" : p < 80 ? "Above Usual" : "High"

histText(float p) =>
    na(p) ? "—" : str.tostring(p, "#") + "/100 " + histBand(p)

tfLabel(string tf, float seconds) =>
    string out = tf
    if not na(seconds)
        int whole_seconds = int(seconds)
        int whole_minutes = int(seconds / 60.0)
        if seconds < 60
            out := str.tostring(whole_seconds) + (whole_seconds == 1 ? " second" : " seconds")
        else if seconds < 3600
            out := str.tostring(whole_minutes) + (whole_minutes == 1 ? " minute" : " minutes")
        else if seconds < 86400
            int whole_hours = int(whole_minutes / 60)
            out := whole_minutes % 60 == 0 ? str.tostring(whole_hours) + (whole_hours == 1 ? " hour" : " hours") : str.tostring(whole_minutes) + " minutes"
        else if seconds < 604800
            int whole_days = int(seconds / 86400.0)
            out := str.tostring(whole_days) + (whole_days == 1 ? " day" : " days")
        else if seconds < 2629800
            int whole_weeks = int(seconds / 604800.0)
            out := str.tostring(whole_weeks) + (whole_weeks == 1 ? " week" : " weeks")
    out

string chart_tf_text    = tfLabel(timeframe.period, chart_tf_sec)
string selected_tf_text = tfLabel(req_tf, req_tf_sec)
string calc_tf_text     = tfLabel(calc_req_tf, calc_tf_sec)

presetName(string preset) =>
    switch preset
        TH_SCALPER  => "Scalper"
        TH_INTRADAY => "Intraday"
        TH_SWING    => "Swing"
        => "Custom"

sourceWindow(int len) =>
    str.tostring(len) + " measurement bars at " + calc_tf_text

sampleStatus(int n, int len) =>
    str.tostring(n) + " usable shared-interval returns in " + str.tostring(len) + " measurement positions"

unavailableTip(CorrSlot s, string metric, int n, int len) =>
    not s.data_seen ? "• Status — no completed data for " + s.sym + ".\n• Check — symbol and market-data availability." : "• Status — " + metric + " is unavailable.\n• Sample — " + sampleStatus(n, len) + ".\n• Requirements — complete configured window, at least three usable returns, and metric-specific variation."

// Heat coloring applies only to correlation values bounded by [-1, 1].
heatColor(float r) =>
    na(r) ? mono_c : r >= 0 ? color.from_gradient(r, 0, 1, mono_c, color.green) : color.from_gradient(r, -1, 0, color.blue, mono_c)

cellColor(float r, bool heatable) =>
    switch color_mode
        CM_MONO => mono_c
        CM_HEAT => heatable ? heatColor(r) : body_txt_c
        =>         body_txt_c

headTip(string kind) =>
    switch kind
        "sym"   => "• Comparison — each row measures one instrument against " + syminfo.ticker + ".\n• Star — latest fresh comparison close mapped to the preceding chart-symbol endpoint.\n• Returns — both instruments still span the same consecutive endpoint pair."
        "rl"    => "• Metric — Pearson correlation of timestamp-matched log returns.\n• Window — " + sourceWindow(long_len) + ".\n• Display — -100% to +100%.\n• Affects — Long, Difference, Beta, Spread, and Coverage; never comparison lines."
        "rc"    => "• Metric — Pearson correlation of timestamp-matched log returns.\n• Window — " + sourceWindow(current_len) + ".\n• Display — -100% to +100%.\n• Affects — Short and Difference only; never comparison lines."
        "pct"   => "• Source — existing " + (pct_is_long ? "Long" : "Short") + " result.\n• Window — " + sourceWindow(pct_len) + ".\n• Also used by — History and optional line-end correlation text.\n• Recalculation — Long and Short results do not change."
        "hist"  => "• Metric — current Main Correlation ranked against prior valid pair readings.\n• Window — " + sourceWindow(hist_len) + ".\n• Ties — all-equal history ranks 50/100.\n• Changes with — effective measurement timeframe, Main correlation window, or Historical window.\n• Interpretation — descriptive rank, not probability or a signal."
        "dr"    => "• Formula — Short Correlation minus Long Correlation.\n• Samples — " + sourceWindow(current_len) + " versus " + sourceWindow(long_len) + ".\n• Display — rounded whole percentage points.\n• Near zero — both samples currently produce similar coefficients."
        "beta"  => "• Formula — covariance(chart returns, comparison returns) / variance(comparison returns).\n• Window — " + sourceWindow(long_len) + ".\n• Sign — fitted return direction.\n• Absolute magnitude — relative fitted sensitivity."
        "z"     => "• Metric — signed population-standard-deviation distance from the matched Long-window average.\n• Window — " + sourceWindow(long_len) + ".\n• Non-negative Long — ratio spread: log(chart) - log(comparison).\n• Negative Long — product spread: log(chart) + log(comparison)."
        "match" => "• Formula — fresh comparison endpoints / eligible Long-window measurement positions.\n• Meaning — endpoint availability only.\n• Return counts — usable Long/Short shared returns appear in each cell tooltip.\n• Effect — does not score, classify, or modify correlation."
        =>         ""

cellTip(string kind, CorrSlot s) =>
    string out = ""
    if kind == "sym"
        out := not s.data_seen ? "• Status — no completed data for " + s.sym + ".\n• Check — symbol and market-data availability." : "• Symbol — " + s.sym + (s.lag_adj ? "\n• Star — latest fresh comparison close mapped to the preceding " + syminfo.ticker + " endpoint.\n• Returns — both instruments span consecutive shared endpoint pairs." : "")
    else if kind == "rl"
        out := na(s.r_long) ? unavailableTip(s, "Long Correlation", s.n_long, long_len) : "• Long Correlation — " + corrText(s.r_long) + ".\n• Pair — " + syminfo.ticker + " / " + s.disp + ".\n• Sample — " + sampleStatus(s.n_long, long_len) + "."
    else if kind == "rc"
        out := na(s.r_short) ? unavailableTip(s, "Short Correlation", s.n_short, current_len) : "• Short Correlation — " + corrText(s.r_short) + ".\n• Pair — " + syminfo.ticker + " / " + s.disp + ".\n• Sample — " + sampleStatus(s.n_short, current_len) + "."
    else if kind == "hist"
        out := not s.data_seen ? "• Status — no completed data for " + s.sym + "." : na(s.r_hist_rank) ? "• Status — History unavailable.\n• Requirements — complete " + sourceWindow(hist_len) + ", valid current Main Correlation, and at least one prior valid reading." : "• Current Main — " + pctText(s.r_pct) + ".\n• History rank — " + str.tostring(s.r_hist_rank, "#") + "/100, " + histBand(s.r_hist_rank) + ".\n• Prior valid readings — " + str.tostring(s.r_hist_n) + ".\n• Prior range — " + pctText(s.r_hist_lo * 100.0) + " to " + pctText(s.r_hist_hi * 100.0) + "; average " + pctText(s.r_hist_avg * 100.0) + "."
    else if kind == "pct"
        int main_n = pct_is_long ? s.n_long : s.n_short
        out := na(s.r_pct) ? unavailableTip(s, "Main Correlation", main_n, pct_len) : "• Main Correlation — " + pctText(s.r_pct) + ".\n• Source — " + (pct_is_long ? "Long" : "Short") + " window.\n• Pair — " + syminfo.ticker + " / " + s.disp + ".\n• Sample — " + sampleStatus(main_n, pct_len) + "." + (s.r_pct < 0 ? "\n• Sign — opposite-direction linear relationship." : "")
    else if kind == "z"
        string spread_mode = not na(s.r_long) and s.r_long < 0 ? "Product log-spread: log(chart) + log(comparison)" : "Ratio log-spread: log(chart) - log(comparison)"
        string spread_direction = na(s.spread_z) ? "" : s.spread_z > 0 ? "above" : s.spread_z < 0 ? "below" : "at"
        out := na(s.spread_z) ? unavailableTip(s, "Spread", s.n_long, long_len) : "• Form — " + spread_mode + ".\n• Signed z-score — " + (s.spread_z > 0 ? "+" : "") + str.tostring(s.spread_z, "0.0") + ".\n• Position — " + (s.spread_z == 0 ? "at" : str.tostring(math.abs(s.spread_z), "0.0") + " standard deviations " + spread_direction) + " its own Long-window average."
    else if kind == "match"
        out := not s.data_seen ? "• Status — no completed data for " + s.sym + "." : na(s.match_pct) ? "• Status — Coverage unavailable until a complete " + sourceWindow(long_len) + ".\n• Endpoints — " + str.tostring(s.match_fresh) + " fresh / " + str.tostring(s.match_eligible) + " eligible." : "• Data Coverage — " + str.tostring(s.match_pct, "#") + "%.\n• Endpoints — " + str.tostring(s.match_fresh) + " fresh / " + str.tostring(s.match_eligible) + " eligible.\n• Usable returns — Long " + str.tostring(s.n_long) + "/" + str.tostring(long_len) + "; Short " + str.tostring(s.n_short) + "/" + str.tostring(current_len) + ".\n• Lower coverage — usually different sessions, missing bars, or sparse data."
    else if kind == "beta"
        string beta_meaning = na(s.beta) ? "" : s.beta < 0 ? "The negative sign indicates opposite-direction return sensitivity." : s.beta > 0 ? "The positive sign indicates same-direction return sensitivity." : "Zero indicates no fitted directional return sensitivity in this sample."
        out := not s.data_seen ? "• Status — no completed data for " + s.sym + "." : na(s.beta) ? "• Status — Beta unavailable.\n• Sample — " + sampleStatus(s.n_long, long_len) + ".\n• Requirements — complete configured window, at least three usable returns, and measurable comparison-return variation." : "• Beta — " + str.tostring(s.beta, "0.00") + " for " + syminfo.ticker + " relative to " + s.disp + ".\n• Sample — " + sampleStatus(s.n_long, long_len) + ".\n• Direction — " + beta_meaning + "\n• Absolute sensitivity — " + str.tostring(math.abs(s.beta), "0.00") + "."
    else if kind == "dr"
        int diff_points = na(s.dr) ? 0 : int(math.round(s.dr * 100.0))
        out := na(s.dr) ? (not s.data_seen ? "• Status — no completed data for " + s.sym + "." : "• Status — Difference requires valid Long and Short Correlations.\n• Usable returns — Long " + str.tostring(s.n_long) + "/" + str.tostring(long_len) + "; Short " + str.tostring(s.n_short) + "/" + str.tostring(current_len) + ".") : s.dr == 0 ? "• Difference — 0 percentage points.\n• Result — Short and Long Correlation are equal." : diff_points == 0 ? "• Displayed Difference — 0 rounded percentage points.\n• Unrounded order — Short is slightly " + (s.dr > 0 ? "above" : "below") + " Long." : "• Difference — " + str.tostring(math.abs(diff_points)) + " percentage points.\n• Result — Short is " + (s.dr > 0 ? "above" : "below") + " Long.\n• Short sample — " + sourceWindow(current_len) + ".\n• Long sample — " + sourceWindow(long_len) + "."
    out

sortKey(CorrSlot s) =>
    float k = switch dash_sort
        SORT_R => na(s.r_long)   ? -1.0 : math.abs(s.r_long)
        SORT_Z => na(s.spread_z) ? -1.0 : math.abs(s.spread_z)
        =>        0.0
    k

orderedIdx() =>
    array<int> order = array.new<int>()
    // Slot access remains gated until initialization completes.
    if array.size(slots) == SLOT_COUNT
        for i = 0 to SLOT_COUNT - 1
            CorrSlot s = array.get(slots, i)
            if s.enabled
                array.push(order, i)
    if dash_sort != SORT_SLOT and array.size(order) > 1
        for a = 0 to array.size(order) - 2
            int best = a
            for b = a + 1 to array.size(order) - 1
                if sortKey(array.get(slots, array.get(order, b))) > sortKey(array.get(slots, array.get(order, best)))
                    best := b
            if best != a
                int tmp = array.get(order, a)
                array.set(order, a, array.get(order, best))
                array.set(order, best, tmp)
    order

const int MAX_COLS = 10
const int MAX_ROWS = SLOT_COUNT + 3   // title, measurement status, column headers, slots

var table dash = table.new(tblPos(dash_pos), MAX_COLS, MAX_ROWS, border_width = border_w, border_color = border_c, frame_width = frame_w, frame_color = frame_c)

if barstate.islast and dash_en and array.size(slots) == SLOT_COUNT
    table.clear(dash, 0, 0, MAX_COLS - 1, MAX_ROWS - 1)

    color hdr_bg  = applyOpacity(hdr_bg_c, tbl_bg_transp)
    color hdr_tx  = applyOpacity(hdr_txt_c, 0)
    string h_size = txtSize(e_hdr_size)
    string b_size = txtSize(e_body_size)

    array<string> heads = array.new<string>()
    array<string> kinds = array.new<string>()
    array.push(heads, "Symbol")
    array.push(kinds, "sym")
    if e_col_rl
        array.push(heads, "Long\nCorrelation")
        array.push(kinds, "rl")
    if e_col_rc
        array.push(heads, "Short\nCorrelation")
        array.push(kinds, "rc")
    if e_col_pct
        array.push(heads, "Main\nCorrelation")
        array.push(kinds, "pct")
    if e_col_hist
        array.push(heads, "History")
        array.push(kinds, "hist")
    if e_col_dr
        array.push(heads, "Correlation\nDifference\n(Rounded pp)")
        array.push(kinds, "dr")
    if e_col_beta
        array.push(heads, "Beta\n(Chart / Symbol)")
        array.push(kinds, "beta")
    if e_col_z
        array.push(heads, "Spread\n(Standard Deviations)")
        array.push(kinds, "z")
    if e_col_match
        array.push(heads, "Data\nCoverage")
        array.push(kinds, "match")

    int ncols = array.size(kinds)

    string preset_status = presetName(trading_horizon)
    string baseline_status = anchor_mode == AN_BARS ? "Rolling " + str.tostring(anchor_bars) + " measurement bars" : anchor_mode
    string line_status = "Comparison lines · Measurement: " + calc_tf_text + " · Start: " + baseline_status + (anchor_mode == AN_BARS ? " · fresh endpoint required" : "") + " · visual only"
    string sample_mode = calc_follows_chart ? "follows chart" : lower_tf ? "chart fallback" : higher_tf ? "completed bars" : "matches chart"
    string window_status = "Long: " + str.tostring(long_len) + " measurement bars · Short: " + str.tostring(current_len) + " measurement bars"
    string measurement_status = lower_tf ? "⚠ " + preset_status + " measurement preset · Chart: " + chart_tf_text + "\nRequested: " + selected_tf_text + " · Measurements: " + calc_tf_text + " (" + sample_mode + ")\n" + window_status : preset_status + " measurement preset · Chart: " + chart_tf_text + "\nMeasurements: " + calc_tf_text + " (" + sample_mode + ")\n" + window_status
    if short_adjusted
        measurement_status := measurement_status + "\n⚠ Short adjusted: selected " + str.tostring(custom_short_len) + " · effective " + str.tostring(current_len) + " measurement bars"
    string status_text = measurement_status + (any_draw ? "\n" + line_status : "")
    string column_status = use_custom_columns ? "Custom selection" : (visual_preset + " preset")
    string title_tip = "• Comparison — " + syminfo.ticker + " versus enabled slots.\n• Data context — comparison requests inherit applicable chart session, adjustment, currency, and futures modifiers.\n• Chart timeframe — " + chart_tf_text + "; chart candles never change.\n• Measurement preset — " + preset_status + ".\n• Requested measurement timeframe — " + selected_tf_text + ".\n• Effective measurement timeframe — " + calc_tf_text + " (" + sample_mode + ").\n• Long window — " + str.tostring(long_len) + " measurement bars.\n• Short window — " + str.tostring(current_len) + " measurement bars.\n• Alignment — returns share consecutive matched endpoints; gaps accumulate both instruments over the same interval.\n• Dashboard columns — " + column_status + "; display only."
    if calc_follows_chart
        title_tip := title_tip + "\n• Custom blank behavior — measurements follow the chart; changing chart timeframe changes the sample."
    else if lower_tf
        title_tip := title_tip + "\n• Fallback — requested " + selected_tf_text + " is below chart " + chart_tf_text + "; measurements use " + chart_tf_text + ". Chart candles remain unchanged."
    else if higher_tf
        title_tip := title_tip + "\n• Intended higher-timeframe behavior — the chart remains " + chart_tf_text + " while measurements use completed " + calc_tf_text + " bars; matching chart timeframe is not required.\n• Update timing — a completed measurement tuple commits when the first " + chart_tf_text + " chart bar carrying it confirms."
    else
        title_tip := title_tip + "\n• Timeframe relationship — the fixed measurement timeframe matches the chart."
    if short_adjusted
        title_tip := title_tip + "\n• Short adjustment — selected " + str.tostring(custom_short_len) + "; effective " + str.tostring(current_len) + " measurement bars because Short must remain below Long."
    if any_draw
        title_tip := title_tip + "\n• Comparison-line start — " + baseline_status + "; visual only and never used by dashboard measurements." + (anchor_mode == AN_BARS ? "\n• Rolling boundary — each line waits for its first fresh valid endpoint at or after the shared boundary." : "")
    color status_bg = lower_tf or short_adjusted ? applyOpacity(#9a6700, tbl_bg_transp) : hdr_bg

    table.cell(dash, 0, 0, "Correlation · " + syminfo.ticker, text_color = hdr_tx, bgcolor = hdr_bg, text_size = h_size, tooltip = title_tip)
    table.cell(dash, 0, 1, status_text, text_color = hdr_tx, bgcolor = status_bg, text_size = h_size, tooltip = title_tip)
    // Recreate the title and status merges after clearing the table.
    if ncols > 1
        for c = 1 to ncols - 1
            table.cell(dash, c, 0, "", bgcolor = hdr_bg, text_size = h_size, tooltip = title_tip)
            table.cell(dash, c, 1, "", bgcolor = status_bg, text_size = h_size, tooltip = title_tip)
        table.merge_cells(dash, 0, 0, ncols - 1, 0)
        table.merge_cells(dash, 0, 1, ncols - 1, 1)

    for c = 0 to ncols - 1
        string k = array.get(kinds, c)
        table.cell(dash, c, 2, array.get(heads, c), text_color = hdr_tx, bgcolor = hdr_bg, text_size = h_size, tooltip = headTip(k))

    array<int> order = orderedIdx()
    if array.size(order) > 0
        for pos = 0 to array.size(order) - 1
            CorrSlot s = array.get(slots, array.get(order, pos))
            int   row  = pos + 3
            color bg   = applyOpacity(stripe_en and pos % 2 == 1 ? stripe_c : body_bg_c, stripe_en and pos % 2 == 1 ? stripe_transp : tbl_bg_transp)

            bool z_blank = na(s.spread_z)

            for c = 0 to ncols - 1
                string kind = array.get(kinds, c)
                // A star marks the latest fresh comparison mapped to the prior base endpoint.
                string txt  = switch kind
                    "sym"   => s.disp + (not s.data_seen ? " · No data" : s.lag_adj ? " *" : "")
                    "rl"    => corrText(s.r_long)
                    "rc"    => corrText(s.r_short)
                    "pct"   => pctText(s.r_pct)
                    "hist"  => histText(s.r_hist_rank)
                    "dr"    => drText(s.dr)
                    "beta"  => num(s.beta,    "0.00")
                    "z"     => z_blank ? "—" : (s.spread_z > 0 ? "+" : "") + str.tostring(s.spread_z, "0.0")
                    "match" => na(s.match_pct) ? "—" : str.tostring(s.match_pct, "#") + "%"
                    =>         ""
                color tc = switch kind
                    "sym"   => color_mode == CM_MONO ? mono_c : s.col
                    "rl"    => cellColor(s.r_long, true)
                    "rc"    => cellColor(s.r_short, true)
                    // Percentage correlation is rescaled to the heat-map domain.
                    "pct"   => cellColor(na(s.r_pct) ? float(na) : s.r_pct / 100.0, true)
                    "dr"    => cellColor(s.dr, false)
                    =>         cellColor(float(na), false)
                // Heat mode colors correlation backgrounds and uses white text;
                // Mono mode retains the neutral row background.
                float heat_val = switch kind
                    "rl"  => s.r_long
                    "rc"  => s.r_short
                    "pct" => na(s.r_pct) ? float(na) : s.r_pct / 100.0
                    =>       float(na)
                bool  heat_cell = color_mode == CM_HEAT and not na(heat_val)
                color cell_bg   = heat_cell ? applyOpacity(heatColor(heat_val), 0) : bg
                color cell_tc   = heat_cell ? color.white : tc
                table.cell(dash, c, row, txt, text_color = applyOpacity(cell_tc, 0), bgcolor = cell_bg, text_size = b_size, tooltip = cellTip(kind, s))
    else
        color empty_bg = applyOpacity(body_bg_c, tbl_bg_transp)
        string empty_tip = "Enable at least one nonblank slot in Settings to begin a comparison."
        table.cell(dash, 0, 3, "No active symbols", text_color = applyOpacity(body_txt_c, 0), bgcolor = empty_bg, text_size = b_size, tooltip = empty_tip)
        if ncols > 1
            for c = 1 to ncols - 1
                table.cell(dash, c, 3, "", bgcolor = empty_bg, text_size = b_size, tooltip = empty_tip)
            table.merge_cells(dash, 0, 3, ncols - 1, 3)


// Accessors apply one initialization guard to all draw sites.
slotDisp(int i) =>
    string out = ""
    if array.size(slots) == SLOT_COUNT
        CorrSlot s = array.get(slots, i)
        out := s.disp
    out

slotPct(int i) =>
    float out = float(na)
    if array.size(slots) == SLOT_COUNT
        CorrSlot s = array.get(slots, i)
        out := s.r_pct
    out


// ───────────────────────────────────────────────────────────────────────────
// COMPARISON LINE STARTING POINT
//
//   rebased = base_source_price[baseline] *
//             (sym_source_close / sym_source_price[baseline])
//
// Baselines use the effective measurement clock. Session Open, Year Open, and
// Fixed Date latch base values. Rolling N Bars keeps one position per base
// observation and selects the first fresh valid comparison endpoint at or after
// the shared rolling boundary.
// ───────────────────────────────────────────────────────────────────────────

// Requested daily bucket and year values identify measurement-session boundaries.
bool source_new_session = not na(base_session_t) and (na(base_session_t[1]) or base_session_t != base_session_t[1])
bool source_new_year    = not na(base_year) and (na(base_year[1]) or base_year != base_year[1])

rebase(float sym_c, float sym_o, int sym_t, float aligned_base_c, int aligned_base_tc, bool sym_fresh, bool mapped_prior, bool on) =>
    var float anc_c = na
    var float anc_s = na
    var float boundary_base_o = na
    var float boundary_base_c = na
    var int   boundary_base_t = na
    var int   boundary_sym_t = na
    var bool  fixed_armed = false
    var array<float> rolling_base = array.new<float>()
    var array<float> rolling_sym  = array.new<float>()
    var array<int> rolling_pair_tc = array.new<int>()
    var array<int> rolling_source_t = array.new<int>()
    var float rolling_anc_c = na
    var float rolling_anc_s = na

    if source_sample and on and anchor_mode == AN_BARS
        bool rolling_fresh = sym_fresh and not na(aligned_base_c) and aligned_base_c > 0 and not na(aligned_base_tc) and not na(sym_c) and sym_c > 0
        array.push(rolling_base, rolling_fresh ? aligned_base_c : float(na))
        array.push(rolling_sym, rolling_fresh ? sym_c : float(na))
        array.push(rolling_pair_tc, rolling_fresh ? aligned_base_tc : int(na))
        array.push(rolling_source_t, base_t)
        if array.size(rolling_base) > anchor_bars + 1
            array.shift(rolling_base)
            array.shift(rolling_sym)
            array.shift(rolling_pair_tc)
            array.shift(rolling_source_t)
        rolling_anc_c := na
        rolling_anc_s := na
        int rolling_total = math.min(array.size(rolling_base), array.size(rolling_sym))
        int rolling_start = rolling_total - 1 - anchor_bars
        if rolling_start >= 0
            int rolling_boundary_t = array.get(rolling_source_t, rolling_start)
            for j = rolling_start to rolling_total - 1
                float candidate_base = array.get(rolling_base, j)
                float candidate_sym = array.get(rolling_sym, j)
                int candidate_base_tc = array.get(rolling_pair_tc, j)
                bool at_or_after_boundary = not na(rolling_boundary_t) and not na(candidate_base_tc) and candidate_base_tc >= rolling_boundary_t
                if na(rolling_anc_s) and at_or_after_boundary and not na(candidate_base) and candidate_base > 0 and not na(candidate_sym) and candidate_sym > 0
                    rolling_anc_c := candidate_base
                    rolling_anc_s := candidate_sym

    if on
        if anchor_mode == AN_SESSION
            if source_sample and (na(boundary_base_t) or source_new_session)
                boundary_base_o := base_o
                boundary_base_t := base_t
                boundary_sym_t := sym_t
                anc_c := na
                anc_s := na
            bool session_ready = sym_fresh and (not mapped_prior or na(boundary_sym_t) or (not na(sym_t) and sym_t != boundary_sym_t))
            if source_sample and na(anc_s) and session_ready and not na(boundary_base_t) and not na(boundary_base_o) and boundary_base_o > 0 and not na(sym_o) and sym_o > 0
                anc_c := boundary_base_o
                anc_s := sym_o
        else if anchor_mode == AN_YEAR
            if source_sample and (na(boundary_base_t) or source_new_year)
                boundary_base_o := base_o
                boundary_base_t := base_t
                boundary_sym_t := sym_t
                anc_c := na
                anc_s := na
            bool year_ready = sym_fresh and (not mapped_prior or na(boundary_sym_t) or (not na(sym_t) and sym_t != boundary_sym_t))
            if source_sample and na(anc_s) and year_ready and not na(boundary_base_t) and not na(boundary_base_o) and boundary_base_o > 0 and not na(sym_o) and sym_o > 0
                anc_c := boundary_base_o
                anc_s := sym_o
        else if anchor_mode == AN_DATE
            if source_sample and not fixed_armed and base_t >= anchor_date
                fixed_armed := true
                boundary_base_c := base_c
                boundary_sym_t := sym_t
            bool date_ready = fixed_armed and sym_fresh and (not mapped_prior or na(boundary_sym_t) or (not na(sym_t) and sym_t != boundary_sym_t))
            if source_sample and na(anc_s) and date_ready and not na(boundary_base_c) and boundary_base_c > 0 and not na(sym_c) and sym_c > 0
                anc_c := boundary_base_c
                anc_s := sym_c

    float out = float(na)
    if on
        if anchor_mode == AN_BARS
            out := na(rolling_anc_c) or na(rolling_anc_s) or rolling_anc_s <= 0 or na(sym_c) or sym_c <= 0 ? float(na) : rolling_anc_c * (sym_c / rolling_anc_s)
        else
            out := na(anc_c) or na(anc_s) or anc_s <= 0 or na(sym_c) ? float(na) : anc_c * (sym_c / anc_s)
    out

rb1 = rebase(c1, o1, t1, bc1, btc1, sym1_at_base, lg1, dw1)
rb2 = rebase(c2, o2, t2, bc2, btc2, sym2_at_base, lg2, dw2)
rb3 = rebase(c3, o3, t3, bc3, btc3, sym3_at_base, lg3, dw3)
rb4 = rebase(c4, o4, t4, bc4, btc4, sym4_at_base, lg4, dw4)
rb5 = rebase(c5, o5, t5, bc5, btc5, sym5_at_base, lg5, dw5)
rb6 = rebase(c6, o6, t6, bc6, btc6, sym6_at_base, lg6, dw6)
rb7 = rebase(c7, o7, t7, bc7, btc7, sym7_at_base, lg7, dw7)
rb8 = rebase(c8, o8, t8, bc8, btc8, sym8_at_base, lg8, dw8)

// The shared marker follows the chart-base measurement timestamp.
var array<int> rolling_times = array.new<int>()
if source_sample
    array.push(rolling_times, base_t)
    if array.size(rolling_times) > anchor_bars + 1
        array.shift(rolling_times)

int rolling_total = array.size(rolling_times)
int rolling_time_idx = rolling_total - 1 - anchor_bars
int rolling_anchor_t = rolling_time_idx >= 0 ? array.get(rolling_times, rolling_time_idx) : int(na)

var int anchor_t = na
if source_sample
    if anchor_mode == AN_SESSION and (na(anchor_t) or source_new_session)
        anchor_t := base_t
    else if anchor_mode == AN_YEAR and (na(anchor_t) or source_new_year)
        anchor_t := base_t
    else if anchor_mode == AN_DATE and na(anchor_t) and base_t >= anchor_date
        anchor_t := base_t


// ───────────────────────────────────────────────────────────────────────────
// OVERLAY DRAW
// Each slot uses one plot; the global appearance selects its line or marker style.
// Gap shading uses a separate non-editable hidden plot pair for fill().
// ───────────────────────────────────────────────────────────────────────────

color rc1 = applyOpacity(s1_col, line_transp)
color rc2 = applyOpacity(s2_col, line_transp)
color rc3 = applyOpacity(s3_col, line_transp)
color rc4 = applyOpacity(s4_col, line_transp)
color rc5 = applyOpacity(s5_col, line_transp)
color rc6 = applyOpacity(s6_col, line_transp)
color rc7 = applyOpacity(s7_col, line_transp)
color rc8 = applyOpacity(s8_col, line_transp)

reb_plot_style = switch reb_style
    LA_STEP         => plot.style_stepline
    LA_STEP_DIAMOND => plot.style_stepline_diamond
    LA_POINTS       => plot.style_circles
    LA_CROSSES      => plot.style_cross
    =>                 plot.style_line

reb_line_style = switch reb_style
    LA_DASHED => plot.linestyle_dashed
    LA_DOTTED => plot.linestyle_dotted
    =>           plot.linestyle_solid

plot(dw1 ? rb1 : na, "Slot 1 — comparison line", color=rc1, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw2 ? rb2 : na, "Slot 2 — comparison line", color=rc2, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw3 ? rb3 : na, "Slot 3 — comparison line", color=rc3, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw4 ? rb4 : na, "Slot 4 — comparison line", color=rc4, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw5 ? rb5 : na, "Slot 5 — comparison line", color=rc5, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw6 ? rb6 : na, "Slot 6 — comparison line", color=rc6, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw7 ? rb7 : na, "Slot 7 — comparison line", color=rc7, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)
plot(dw8 ? rb8 : na, "Slot 8 — comparison line", color=rc8, linewidth=reb_width, style=reb_plot_style, display=display.pane, editable=false, linestyle=reb_line_style)

// ── Gap shading ────────────────────────────────────────────────────────────
float shd_reb = switch shade_slot
    1 => rb1
    2 => rb2
    3 => rb3
    4 => rb4
    5 => rb5
    6 => rb6
    7 => rb7
    8 => rb8
    => float(na)

bool shd_dw = switch shade_slot
    1 => dw1
    2 => dw2
    3 => dw3
    4 => dw4
    5 => dw5
    6 => dw6
    7 => dw7
    8 => dw8
    => false

bool shd_on = shd_dw and fill_en

p_close_h = plot(shd_on ? close   : na, "Fill baseline — chart",   display=display.none, editable=false)
p_reb_h   = plot(shd_on ? shd_reb : na, "Fill baseline — rebased", display=display.none, editable=false)

// Fill uses the configured chart-above or chart-below color.
bool  shd_above = close >= shd_reb
color shd_c     = applyOpacity(shd_above ? fill_up_c : fill_dn_c, fill_transp)

fill(p_close_h, p_reb_h, shd_c, title="Gap shading", editable=false)


// ───────────────────────────────────────────────────────────────────────────
// STARTING-POINT MARKER AND LINE-END LABELS
// One marker and one persistent label are reused per slot.
// ───────────────────────────────────────────────────────────────────────────

var line anc_ln = na

if barstate.islast
    int mark_t = anchor_mode == AN_BARS ? rolling_anchor_t : anchor_t
    bool mark_on = any_draw and marker_en and not na(mark_t)

    if mark_on
        if na(anc_ln)
            anc_ln := line.new(mark_t, low, mark_t, high, xloc = xloc.bar_time, extend = extend.both, color = applyOpacity(anc_col, anc_transp), width = anc_width, style = lineStyle(anc_style))
        else
            line.set_xy1(anc_ln, mark_t, low)
            line.set_xy2(anc_ln, mark_t, high)
            line.set_color(anc_ln, applyOpacity(anc_col, anc_transp))
            line.set_width(anc_ln, anc_width)
            line.set_style(anc_ln, lineStyle(anc_style))
    else if not na(anc_ln)
        line.delete(anc_ln)
        anc_ln := na

// Each function instance runs on every bar to maintain continuous `var` state.
// The trailing label value keeps one return type on every path.
endLabel(bool on, float y, string disp, float pct, float z, color col) =>
    var label lb = na
    if on
        string txt = end_lbl_sym ? disp : ""
        if end_lbl_pct
            string pt = "Corr (" + (pct_is_long ? "Long" : "Short") + ") " + pctText(pct)
            txt := txt == "" ? pt : txt + " · " + pt
        if end_lbl_z and not na(z)
            string zt = "Spread z " + (z > 0 ? "+" : "") + str.tostring(z, "0.0")
            txt := txt == "" ? zt : txt + " · " + zt
        color  tcol = applyOpacity(end_lbl_cmode == LC_CUSTOM ? end_lbl_c : col, line_transp)
        string tsz  = end_lbl_size == LS_AUTO ? txtSize(e_body_size) : txtSize(end_lbl_size)
        if na(lb)
            lb := label.new(bar_index, y, txt, style = label.style_label_left, color = applyOpacity(color.black, 100), textcolor = tcol, size = tsz)
        if not na(lb)
            label.set_xy(lb, bar_index, y)
            label.set_text(lb, txt)
            label.set_textcolor(lb, tcol)
            label.set_size(lb, tsz)
    else if not na(lb)
        label.delete(lb)
        lb := na
    lb

bool lbl_base = end_lbl_en and barstate.islast

lb1 = endLabel(lbl_base and dw1 and not na(rb1), rb1, slotDisp(0), slotPct(0), z1, s1_col)
lb2 = endLabel(lbl_base and dw2 and not na(rb2), rb2, slotDisp(1), slotPct(1), z2, s2_col)
lb3 = endLabel(lbl_base and dw3 and not na(rb3), rb3, slotDisp(2), slotPct(2), z3, s3_col)
lb4 = endLabel(lbl_base and dw4 and not na(rb4), rb4, slotDisp(3), slotPct(3), z4, s4_col)
lb5 = endLabel(lbl_base and dw5 and not na(rb5), rb5, slotDisp(4), slotPct(4), z5, s5_col)
lb6 = endLabel(lbl_base and dw6 and not na(rb6), rb6, slotDisp(5), slotPct(5), z6, s6_col)
lb7 = endLabel(lbl_base and dw7 and not na(rb7), rb7, slotDisp(6), slotPct(6), z7, s7_col)
lb8 = endLabel(lbl_base and dw8 and not na(rb8), rb8, slotDisp(7), slotPct(7), z8, s8_col)
````
