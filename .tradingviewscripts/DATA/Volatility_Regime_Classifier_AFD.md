<!-- tradingview-pine-id: PUB;67926ba0be6f486c9656fbb11fdb2b29 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime Classifier [AFD]

Source: https://www.tradingview.com/script/jWfOkOan-Volatility-Regime-Classifier-AFD/

## Description

[image]https://www.tradingview.com/x/fz6ET8y2/[/image]

**What it does**
It answers one question: *is this symbol moving more, or less, than it usually does?*

It measures how far this symbol's own bars have been travelling, ranks that against its recent history, and states the answer as a percentile from 0 to 100 plus a named tier — **QUIET**, **NORMAL**, **ELEVATED** or **EXTREME**. Alongside it you get how the recent stretch compares with the longer one, whether the reading is rising or falling, and a plain-English line saying what that amounts to.

Everything comes from the chart you have open. No VIX, no options data, no implied volatility, no other symbol, and no `request.*()` call of any kind — so it behaves the same on a currency pair, a small-cap, a future or a crypto chart, none of which have an index volatility proxy to borrow.

**How it works**
Realized volatility is measured over three rolling windows — short, mid and long — and one **Sensitivity** setting picks them: Fast 5/15/30, Normal 10/30/60, Slow 20/60/120. Fast is the default.

Four estimators, and this choice matters more than any other setting:

[image]https://www.tradingview.com/x/hDU74ZuD/[/image]
- **Parkinson** (default) — reads the bar's high-low range.

[image]https://www.tradingview.com/x/IWIrdhg3/[/image]
- **Garman-Klass** — reads the range and the open-to-close move.

[image]https://www.tradingview.com/x/AwYDfN4w/[/image]
- **Close-to-close** — reads the dispersion of returns.

[image]https://www.tradingview.com/x/8Qc6VBng/[/image]
- **ATR** — a plain N-bar average of true range. **Not Wilder's smoothing**, so it will
  not match TradingView's built-in ATR at the same length. Deliberate, not a bug.

Parkinson is the default because of a specific failure of the close-to-close default it replaced. Close-to-close measures how *scattered* returns are; a chart reader measures how *far* price went. A clean one-way slide has every return pointing the same way, so its dispersion is genuinely low — and a choppy bounce covering the same ground scores higher than the slide did. Range-based estimators read what the eye reads.

The short-window reading is ranked against the last **400 bars** to give the percentile, and the tier follows from that rank with a **band around each boundary**, so a reading parked on a threshold does not flip back and forth on sampling noise. The panel tells you when the band is holding a tier back.

There is a second route into EXTREME, and it exists because a percentile is self-normalising: roughly a tenth of all bars sit in the top tier however quiet the year has actually been. So a bar is also called EXTREME when the short window reaches a set multiple of the long one, whatever its rank. The multiple differs per estimator, because the four do not put that ratio on the same scale.

On intraday charts the **session-gap return is excluded**. It spans a close and the next open, so it is not a return over one bar of trading, and leaving it in made every session open read as a volatility event that never happened. It is dropped, not zeroed.

**How to use it**
Add it and read the dashboard. It starts compact at four rows; switch **Compact dashboard** off for the full nine, which name every window, bound and setting actually in force rather than the defaults. Hover the marker at the end of the line for a glossary of every number, also built from your current settings.

- **The percentile line** in the lower pane, tier zones shaded behind it.

- **Price-chart markers** — the bar column painted when a tier you have chosen is reached, or a box spanning the whole episode. EXTREME is marked by default; QUIET, NORMAL, ELEVATED and RISING are all available, and a marked tier always beats RISING so an overlapping bar's colour is never an accident of ordering.

- **The market context box** on the price chart, at the corner you pick or off. A headline names the character of the tape — `RANGE EXPANDING`, `RANGE COMPRESSING`, `WIDE AND HOLDING` and eight others — over a line naming what to re-check, a line stating what the short-to-long ratio amounts to in words, and a standing line reading **`Size only - this says nothing about direction.`**

That last line has no off switch, and the vocabulary above it never uses the words "up or "down". `EXPANDING` is equally what a hard rally and a hard sell-off look like.

**Three alerts**, all evaluated on confirmed bars only: the regime tier changed, the short-vs-baseline state changed, and the EXTREME tier was entered.

**Repainting**
The script reads nothing but the current chart's own bars. There are no `request.*()` calls, no higher-timeframe data and no `barmerge.lookahead_on` anywhere in it, so there is no future data for it to borrow. Once a bar closes, its reading is settled and does not change afterwards.

The bar still forming is the ordinary exception, and it is worth being explicit about: its high, low and close are still moving, so the reading on it moves too, and the tier on the live bar can change before the bar is done. The three alert conditions are gated to confirmed bars for that reason. Drawn elements — the panel, the context box, the episode box — are drawn at the last bar and update with it.

**Why it is original**
It is built for the **Pine Screener**, which is unusual in this category. The first ten plots are the contract — percentile, tier code, ratio, short-vs-baseline code, acceleration tier, regime-changed flag, the two raw RV levels, the percentile's sample count, and a flag saying whether the outputs are fully defined — so you can rank or filter a whole watchlist by volatility regime instead of reading one chart at a time. Zero `request.*()` calls, and the warmup is sized to fit the Screener's 500-bar window.

The other difference is that **the regime is a number, not a colour.** The visual layer is drawn *from* the percentile and never replaces it; every tinted panel row still states its value in words, and the whole visual layer switches off without a single reported number changing.

**Limitations**
- **It says nothing about direction, and it is not a signal.** No entries, no exits, no targets, no probability, win-rate or expectancy language anywhere in the script. It describes what has already happened on the chart in front of you.

- **It needs history.** At the default Fast preset the percentile is undefined until bar 404 and shows blank until then. The size-based EXTREME route is defined from bar 30, so **a bar can legitimately show an EXTREME tier beside a blank percentile row** — the panel says which is which, and the `Outputs fully defined` plot flags it.

- **A percentile is relative to this symbol's own recent history.** QUIET on one instrument and QUIET on another are not the same absolute amount of movement. The panel carries the absolute RV level next to the rank for exactly this reason.

- **ATR here is a simple average, not Wilder's**, as above.

**Licence:** Mozilla Public License 2.0.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public
// License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry LLC

//@version=6
// Registry for the regime price boxes. 200, set below the platform's 500-ID
// ceiling; the default for any max_*_count is 50.
indicator("Volatility Regime Classifier [AFD]", "VRC [AFD]", overlay = false, max_boxes_count = 200)

// Volatility Regime Classifier -- classifies the chart symbol's own realized
// volatility, from this chart's own bars only. No implied volatility, no options
// data, no other symbol, no request.*() call of any kind.
//
// The specification is reference/vrc_oracle.py and reference/fixtures/ holds the
// parity targets. The windowed standard deviation and the percentile rank below
// are written out with explicit arrays rather than ta.stdev() / ta.percentrank(),
// so their conventions -- population versus sample, tie handling, window
// inclusion -- are the oracle's and not the platform's.

// ---------------------------------------------------------------------------
// Constants — the published code values. Frozen with BUILD_PLAN.md §8.1.
// ---------------------------------------------------------------------------

int TIER_QUIET    = 0
int TIER_NORMAL   = 1
int TIER_ELEVATED = 2
int TIER_EXTREME  = 3

// Where the short window sits against the long one. The identifiers keep their
// options-market names because reference/vrc_oracle.py and every test quote them
// verbatim; nothing a user reads says any of them, since tsName() maps each to
// plain English. The code values are published and frozen.
//   TS_CONTANGO      +1  short window below the long one  -> "BELOW BASELINE"
//   TS_BACKWARDATION -1  short window above the long one  -> "ABOVE BASELINE"
//   TS_FLAT           0  gap inside the tolerance         -> "IN LINE"
//   TS_MIXED          2  mid window outside both ends     -> "UNEVEN"
int TS_BACKWARDATION = -1
int TS_FLAT          = 0
int TS_CONTANGO      = 1
int TS_MIXED         = 2

int ACCEL_FALLING = -1
int ACCEL_FLAT    = 0
int ACCEL_RISING  = 1

// The two comparison modes, named for what they compare rather than for how
// many points they read.
string MODE_TWO_POINT   = "Short vs long"
string MODE_THREE_POINT = "Short, mid and long"

// How a marked regime is drawn on the main price chart. The price box is a
// rectangle spanning a whole episode, in the tier colour the pane's zones use.
string MARK_STYLE_COLUMN = "Bar column"
string MARK_STYLE_BOX    = "Price box"
string MARK_STYLE_BOTH   = "Both"

// The one marked state that is not a tier: RISING is an acceleration reading,
// offered because "show me where it is picking up" is a different question from
// "show me where it is high". Codes 0-3 are the tier codes above, reused so a
// marked tier and a reported tier cannot drift apart.
int MARK_STATE_RISING = 4

// Line colour modes, gradient presets, line styles and marker modes. Each is the
// literal an input's `options` list carries.
string LINE_MODE_GRADIENT = "Auto gradient"
string LINE_MODE_TIER     = "Tier colour"
string LINE_MODE_FIXED    = "Fixed colour"

string GRAD_SIGNAL = "Signal"
string GRAD_OCEAN  = "Ocean"
string GRAD_EMBER  = "Ember"
string GRAD_MONO   = "Mono"
string GRAD_CUSTOM = "Custom"

string STYLE_LINE      = "Line"
string STYLE_STEPLINE  = "Stepline"
string STYLE_HISTOGRAM = "Histogram"
string STYLE_CIRCLES   = "Circles"

string MARK_ENTRY = "Entry bar only"
string MARK_HOLD  = "Every bar in the tier"

// Panel chrome. The background is see-through because the percentile line runs
// the full width of the pane, so at some reading it passes under the panel at
// every corner; what the panel must not do is hide it. The panel stays in this
// pane by owner decision, not by platform limitation.
color DASH_BG     = color.new(color.black, 70)
color DASH_BORDER = color.new(color.gray, 50)
color DASH_LABEL  = color.silver
color DASH_VALUE  = color.white

// Ink for text that lands on a tier-coloured fill, and a fully transparent colour
// for wherever "draw nothing" has to be expressed as a colour rather than as a
// branch -- a plot, a fill and a table cell all take a colour, never an if.
//
// One ink covers all four tiers because every fill it lands on is transparent
// over a dark pane, so all four tier composites are dark. That is also why the
// glossary marker's chip is tinted rather than solid: an opaque bright fill is
// the one background this ink would not read on.
color DASH_NOTE   = #FFD54F
color TRANSPARENT = color.new(color.black, 100)

// Status colours. A dead market and a warming window are different events, and
// the panel says so in colour as well as in words.
color STATUS_ALERT   = #E57373
color STATUS_WARN    = #FFB74D
color STATUS_NEUTRAL = #78909C

// Gradient preset ramps: low end at percentile 0, mid at 50, high at 100.
color GRAD_SIGNAL_LOW  = #00B0FF
color GRAD_SIGNAL_MID  = #FFC400
color GRAD_SIGNAL_HIGH = #FF1744

color GRAD_OCEAN_LOW  = #01579B
color GRAD_OCEAN_MID  = #0288D1
color GRAD_OCEAN_HIGH = #4FC3F7

color GRAD_EMBER_LOW  = #4E342E
color GRAD_EMBER_MID  = #F4511E
color GRAD_EMBER_HIGH = #FFD54F

color GRAD_MONO_LOW  = #37474F
color GRAD_MONO_MID  = #90A4AE
color GRAD_MONO_HIGH = #ECEFF1

// Panel tint strengths. Higher is more transparent. The regime row is the
// strongest of the three so it reads as the panel's headline, without being
// opaque enough to hide the line behind it.
int TINT_REGIME = 45
int TINT_VALUE  = 68
int TINT_RATIO  = 76

// The market context box sits over candles rather than over an empty pane, so it
// is more see-through than the panel's headline row and less than its background.
int TINT_CONTEXT = 60

// The market context box's last line, written in every branch including the two
// status ones, with no input reaching it. It is what stops a box reading RANGE
// EXPANDING over a falling chart from being read as a call on the fall -- and
// this box is drawn over price, which is where that misreading is a glance away.
string CONTEXT_FOOTER = "Size only - this says nothing about direction."

// The box's bullet, named once so that a glyph rendering as a fallback box is a
// one-line fix. Headings are not bulletised: a bullet makes one a list item.
string BULLET = "• "

// Rows in the market context table. Fixed at creation, since a table cannot
// grow, so it is the deepest layout any branch needs: a top spacer, then
// headline, stats, state heading, body, disclosure. The status branch uses two
// of the five content rows and writes "" to the rest, because a cell keeps what
// it was last given until it is overwritten.
int CONTEXT_ROWS = 6

// Row 0 is a transparent spacer that pushes the box clear of the chart's own
// legend, which TradingView draws over the top-right of the pane. `table.cell()`
// takes `height` as a percentage of the pane's visible height, and that is the
// only displacement lever Pine offers -- `table.new()` has a position and no
// offset. Applied at top right only; at middle right the empty cell sizes itself
// to a hairline.
float CONTEXT_TOP_PAD = 5.0

// Volatility estimators. Each literal is what an input's `options` list carries
// and what the dashboard prints. reference/vrc_oracle.py defines all four.
string EST_CLOSE     = "Close-to-close"
string EST_PARKINSON = "Parkinson (high-low)"
string EST_GK        = "Garman-Klass (OHLC)"
string EST_ATR       = "ATR (average true range)"

// Garman-Klass and Parkinson both scale by ln 2. Computed rather than written as
// a decimal, so the constant cannot drift from the formula.
float LN2      = math.log(2.0)
float GK_COEFF = 2.0 * LN2 - 1.0

// The three window sets, as the literals the Sensitivity dropdown carries.
string SENS_FAST   = "Fast"
string SENS_NORMAL = "Normal"
string SENS_SLOW   = "Slow"

// ---------------------------------------------------------------------------
// Fixed configuration
//
// Each value below was an input once. None of them is a setting a reader can
// calibrate -- a tolerance, a deadband, three tier bounds, a lookback and a
// comparison mode -- and all of them change every number on the panel, so they
// are constants with a measurement behind each in reference/.
//
// Nothing became less visible. The dashboard names the lookback, the band, the
// mode, the tolerance and all three windows every time it is drawn.
// ---------------------------------------------------------------------------

// A shorter lookback decayed back toward the middle while the market was still
// moving, so the rank forgot what it was ranking against. 400 is the largest
// value whose warmup still fits the Pine Screener's 500-bar window: warmup is
// shortLen + 399, which is 404 bars at the default Sensitivity.
int PCT_LOOKBACK = 400

// Tier bounds, as percentile values.
float QUIET_TH    = 25.0
float ELEVATED_TH = 75.0
float EXTREME_TH  = 85.0

// The regime band, in percentile points.
float TIER_BAND = 1.0

// The shape comparison. Two-point is the shipped mode; the three-point path
// stays defined because TS_MIXED is a frozen published code, and a mode that
// cannot be reached must still be a mode that is defined.
string TS_MODE      = MODE_TWO_POINT
float TS_TOLERANCE  = 0.10
float ACCEL_DEADBAND = 0.05

// ---------------------------------------------------------------------------
// The absolute EXTREME override
//
// A percentile cannot call a whole stretch extreme. It is self-normalising by
// construction: once a volatile stretch fills the lookback the reading decays
// toward the middle while nothing has calmed down, and a 4x expansion and a 1.2x
// expansion both read 100 if each is the maximum of its own window. These
// thresholds answer the question the rank structurally cannot.
//
// Four values and not one, because the estimators do not put that ratio on the
// same scale. Measured over twelve seeds x 900 bars at the shipped windows
// (reference/vrc_oracle.py DEFAULT_EXTREME_RATIO):
//
//   estimator        median     p90     p99     max    ceiling
//   Close-to-close    0.917   1.360   2.054   2.318   2.449
//   Parkinson         0.988   1.178   1.369   1.611   2.449
//   Garman-Klass      0.990   1.155   1.302   1.556   2.449
//   ATR               0.992   1.193   1.393   1.745   6.000
//
// Each value below is p99 of its own distribution, rounded, and each fires on
// 1.6-2.5% of classified bars. A single shared threshold of 1.8 would have sat
// above Parkinson's observed maximum and never once fired on the default.
// ---------------------------------------------------------------------------
float OVERRIDE_CLOSE     = 2.00
float OVERRIDE_PARKINSON = 1.35
float OVERRIDE_GK        = 1.30
float OVERRIDE_ATR       = 1.40

// One trading day in seconds, for the intraday test below.
int SECONDS_PER_DAY = 86400

// Sentinel bounds for the tier band's open ends. No reading can reach one: the
// percentile is always within [0, 100] and the band is capped at 25.
float BOUND_OPEN_LOW  = -1000000.0
float BOUND_OPEN_HIGH = 1000000.0

string GRP_BASIS   = "Basis"
string GRP_DISPLAY = "Display"
string GRP_TIER    = "Tier colours"
string GRP_LINE    = "Line"
string GRP_FILL    = "Fill and zones"
string GRP_MARK    = "Price-chart markers"

// ---------------------------------------------------------------------------
// Inputs — order, names and defaults are BUILD_PLAN.md §3 and are frozen once
// published. New inputs append to their group; none is ever reordered.
// ---------------------------------------------------------------------------

// The Basis group is declared first because it decides what every later number
// means.
//
// TOOLTIP POLICY. A tooltip states what the setting does, what it interacts
// with, and which other setting must be on for it to be read at all. It does not
// date changes and does not justify past decisions. The form is one summary
// line, then one "- " bullet per fact, in ASCII only.
//
// Every int, float and string input carries `display = display.none`, which
// keeps its value out of the run of bare numbers the platform otherwise prints
// beside the script title. Bool and colour inputs default to that already.
//
// The panel remains the disclosure surface. Nothing is hidden by this: the
// dashboard names the estimator, the windows, the lookback, the sample count,
// the mode and the band every time it is drawn.
string estimatorInput = input.string(EST_PARKINSON, "Volatility estimator",
     options = [EST_PARKINSON, EST_CLOSE, EST_GK, EST_ATR], group = GRP_BASIS,
     display = display.none,
     tooltip = "How each bar's movement is measured." +
     "\n- Parkinson: the bar's high-low range. The default." +
     "\n- Close-to-close: the spread of returns between closes." +
     "\n- Garman-Klass: the range and the open-to-close move together." +
     "\n- ATR: average true range as a fraction of price. A simple N-bar average, not Wilder's smoothing, so it will not match the platform's built-in ATR at the same length." +
     "\n- Choosing between them: the three range estimators measure how FAR price went, which is what your eye measures. Close-to-close measures how SCATTERED the returns are, so a clean one-way slide scores lower on it than a choppy recovery covering the same ground." +
     "\n- Close-to-close and ATR read across the bar boundary, so Exclude the session gap applies to those two only." +
     "\n- All four describe chart history. None is a forecast."
     )
string sensitivityInput = input.string(SENS_FAST, "Sensitivity",
     options = [SENS_FAST, SENS_NORMAL, SENS_SLOW], group = GRP_BASIS,
     display = display.none,
     tooltip = "How many bars each reading covers." +
     "\n- Fast: 5 bars against 30. The default. Reacts within minutes on an intraday chart." +
     "\n- Normal: 10 against 60." +
     "\n- Slow: 20 against 120. Fewer regime changes, later." +
     "\n- The long window is six times the short one at every setting, so the short-vs-long number means the same thing on all three and only the timescale changes." +
     "\n- The panel's Setup row names the three windows in force."
     )
bool extremeBySizeInput = input.bool(true, "Also call EXTREME by absolute size",
     group = GRP_BASIS,
     tooltip = "Adds a second route into the EXTREME tier, for the case the percentile cannot reach." +
     "\n- The percentile ranks this bar against recent history, so once a violent stretch fills that history the rank drifts back to the middle while nothing has calmed down." +
     "\n- With this on, a bar is EXTREME whenever the short window reaches a set multiple of the long one, whatever its rank." +
     "\n- The multiple is set for you and differs by estimator, because the four do not produce numbers on the same scale: 1.35x on Parkinson, 2.00x on close-to-close, 1.30x on Garman-Klass, 1.40x on ATR. The panel names the one in force." +
     "\n- It also classifies bars before the ranking window is full, which is most of the first 404 bars on any chart at the default Sensitivity." +
     "\n- The panel says so whenever a bar reached EXTREME this way rather than by rank."
     )
bool excludeSessionGapInput = input.bool(true, "Exclude the session gap",
     group = GRP_BASIS,
     tooltip = "Drops the reading that spans the overnight break, on the first bar of each session." +
     "\n- That reading covers the previous close and the new open, so it is not one bar of trading." +
     "\n- Left in, it dominates every window it sits in and makes each session open read as a volatility event that did not happen." +
     "\n- Dropped, not zeroed: the windows keep a full count and simply reach further back." +
     "\n- Applies to Close-to-close and to ATR, the two that read across a bar boundary. Parkinson and Garman-Klass read inside a single bar and are unaffected, so on the default estimator this setting does nothing." +
     "\n- Inert on daily and higher, where a bar is already a session."
     )
bool showDashboardInput = input.bool(true, "Show dashboard", group = GRP_DISPLAY,
     tooltip = "Hides or shows the whole panel." +
     "\n- No single row can be hidden on its own." +
     "\n- The windows, the lookback, the sample count, the mode and the estimator are what give the percentile its meaning, so they travel together.")
bool dashCompactInput = input.bool(true, "Compact dashboard", group = GRP_DISPLAY,
     active = showDashboardInput,
     tooltip = "Folds the panel from nine rows to four." +
     "\n- Keeps: the regime, the plain-English sentence, short vs long, and acceleration." +
     "\n- The estimator, the windows, the lookback, the band and the size rule move to the hover glossary, which is forced on while this is on. Nothing is dropped." +
     "\n- Sample n and the percentile leave the panel in this mode. The plain-English row already states where the reading sits, and on a warming chart the top row reads 'WARMING UP - n of N'.")
string dashPositionInput = input.string("Top right", "Dashboard position",
     options = ["Top left", "Top center", "Top right", "Bottom left", "Bottom center", "Bottom right"],
     display = display.none, group = GRP_DISPLAY, active = showDashboardInput,
     tooltip = "Which corner of THIS pane the panel sits in." +
     "\n- It moves the panel only. The Market context box, under Price-chart markers, is a separate setting on a separate pane and is not affected by this one." +
     "\n- The percentile line runs the full width of the pane, so at some reading the line passes under the panel at every corner. The panel background is see-through for that reason.")
string dashTextSizeInput = input.string("Small", "Dashboard text size",
     options = ["Tiny", "Small", "Normal", "Large"], display = display.none, group = GRP_DISPLAY, active = showDashboardInput,
     tooltip = "Text size for the panel only." +
     "\n- Larger sizes make the panel taller, and a table is clipped at the pane boundary rather than scrolled, so the full nine-row panel may not fit at Large in a short pane.")
bool colorDashboardInput = input.bool(true, "Colour the dashboard by regime", group = GRP_DISPLAY,
     active = showDashboardInput,
     tooltip = "Tints four rows of the panel." +
     "\n- Regime row: the tier colour." +
     "\n- Percentile row: the gradient colour at that percentile." +
     "\n- Short vs long row: whether the short window is running above or below the long one." +
     "\n- Acceleration row: its direction." +
     "\n- Colour never replaces a word. Every tinted row still spells its state out, so the panel reads the same with the tint off and to anyone who does not separate these colours.")
bool showInfoMarkerInput = input.bool(true, "Show the hover glossary marker", group = GRP_DISPLAY,
     tooltip = "Puts one small chip at the right-hand end of the percentile line." +
     "\n- Its text is the current tier." +
     "\n- Hovering it defines every number this script reports, using the windows and lookback currently set." +
     "\n- Forced on while Compact dashboard is on, whatever this is set to, because the glossary is then the only place the configuration is stated.")

color tierQuietColorInput = input.color(#26C6DA, "QUIET", group = GRP_TIER,
     tooltip = "Used by the dashboard tint, by the Tier colour line mode, and by the hover chip.")
color tierNormalColorInput = input.color(#66BB6A, "NORMAL", group = GRP_TIER)
color tierElevatedColorInput = input.color(#FFA726, "ELEVATED", group = GRP_TIER)
color tierExtremeColorInput = input.color(#EF5350, "EXTREME", group = GRP_TIER)

string lineColorModeInput = input.string(LINE_MODE_GRADIENT, "Line colour mode",
     options = [LINE_MODE_GRADIENT, LINE_MODE_TIER, LINE_MODE_FIXED], display = display.none, group = GRP_LINE,
     tooltip = "What decides the percentile line's colour." +
     "\n- Auto gradient: ramps continuously with the percentile, so the colour is the number." +
     "\n- Tier colour: one flat colour per tier, so the colour is the classification and changes only when the tier does." +
     "\n- Fixed colour: one colour at all times.")
string lineGradientInput = input.string(GRAD_SIGNAL, "Gradient preset",
     options = [GRAD_SIGNAL, GRAD_OCEAN, GRAD_EMBER, GRAD_MONO, GRAD_CUSTOM], display = display.none, group = GRP_LINE,
     tooltip = "The ramp used by Auto gradient." +
     "\n- Every preset is three stops: the low colour at percentile 0, the middle at 50, the high at 100." +
     "\n- Custom takes the two pickers below and interpolates straight between them.")
// The pickers below carry NO `active` argument, and that is the fix rather than
// an omission. It left them dimmed and therefore unreachable at two separate
// builds, and an input that cannot be reached is a shipped defect where one that
// does not dim is a cosmetic loss. The tooltips say when each one is read.
color gradientLowInput = input.color(#00B0FF, "Custom gradient - low end", group = GRP_LINE,
     tooltip = "The colour at percentile 0." +
     "\n- Read only when Line colour mode is Auto gradient and Gradient preset is Custom. Both must be set or this picker does nothing." +
     "\n- Set the opacity in the picker; the line uses the colour exactly as picked.")
color gradientHighInput = input.color(#FF1744, "Custom gradient - high end", group = GRP_LINE,
     tooltip = "The colour at percentile 100." +
     "\n- Read only when Line colour mode is Auto gradient and Gradient preset is Custom. Both must be set or this picker does nothing." +
     "\n- Set the opacity in the picker; the line uses the colour exactly as picked.")
// `active` dropped here for the same reason and in the same edit.
color lineColorInput = input.color(#2962FF, "Fixed line colour", group = GRP_LINE,
     tooltip = "The line's colour when Line colour mode is Fixed colour." +
     "\n- It is also the colour the line takes on any bar the percentile is undefined, in every mode, so it is read whatever Line colour mode is set to.")
string lineStyleInput = input.string(STYLE_LINE, "Line style",
     options = [STYLE_LINE, STYLE_STEPLINE, STYLE_HISTOGRAM, STYLE_CIRCLES], display = display.none, group = GRP_LINE,
     tooltip = "How the percentile series is drawn." +
     "\n- Stepline holds each bar's value flat until the next, which reads honestly on a value that updates once per bar." +
     "\n- Histogram draws from zero." +
     "\n- The fill below is independent of this choice, and is usually turned off for Histogram.")
int lineWidthInput = input.int(2, "Line width", minval = 1, maxval = 5, display = display.none, group = GRP_LINE,
     tooltip = "Thickness of the percentile line, 1 to 5.")

bool showFillInput = input.bool(true, "Fill under the line", group = GRP_FILL,
     tooltip = "Shades the area between the percentile line and zero." +
     "\n- The fill takes the line's own colour on every bar." +
     "\n- With Auto gradient selected the shaded area is itself a gradient that follows the percentile.")
int fillOpacityInput = input.int(88, "Fill transparency", minval = 0, maxval = 100, display = display.none, group = GRP_FILL,
     active = showFillInput,
     tooltip = "0 is opaque, 100 is invisible.")
bool showZonesInput = input.bool(true, "Shade the tier zones", group = GRP_FILL,
     tooltip = "Bands the pane into the four tiers, each in its tier colour." +
     "\n- The line's tier is then readable from the background without reading the panel." +
     "\n- The bands sit at the tier thresholds, and the panel's Percentile row names the reading being cut.")
int zoneOpacityInput = input.int(92, "Zone transparency", minval = 0, maxval = 100, display = display.none, group = GRP_FILL,
     active = showZonesInput,
     tooltip = "0 is opaque, 100 is invisible.")
bool showBoundsInput = input.bool(true, "Draw the threshold lines", group = GRP_FILL,
     tooltip = "Draws a horizontal line at each of the QUIET, ELEVATED and EXTREME bounds, and at 0 and 100.")

// Which states get marked. Every marker takes its colour from the tier palette
// above, which makes "the marker matches the pane's zone" true by construction
// rather than by two defaults happening to agree.
bool markQuietInput = input.bool(false, "Mark QUIET", group = GRP_MARK,
     tooltip = "Marks the main price chart, not only this pane, while the regime is QUIET.")
bool markNormalInput = input.bool(false, "Mark NORMAL", group = GRP_MARK,
     tooltip = "Rarely wanted: NORMAL is the widest tier by default, so marking it colours most of the chart.")
bool markElevatedInput = input.bool(false, "Mark ELEVATED", group = GRP_MARK,
     tooltip = "Marks the price chart while the regime is ELEVATED, which is the band below EXTREME.")
bool markExtremeInput = input.bool(true, "Mark EXTREME", group = GRP_MARK,
     tooltip = "Marks the price chart while the regime is EXTREME." +
     "\n- Every marker here describes the bars it is drawn on. None is a signal and none is a forecast.")
bool markRisingInput = input.bool(false, "Mark RISING", group = GRP_MARK,
     tooltip = "The one marked state that is not a tier." +
     "\n- Marks bars whose acceleration reads RISING, whatever tier they are in - 'where is it picking up' rather than 'where is it high'." +
     "\n- A tier marked above always wins: RISING only paints bars whose own tier is not being marked." +
     "\n- It borrows the ELEVATED colour, as the panel's acceleration tint already does.")

// The marker style. The price box is a rectangle bounding one whole episode.
string markStyleInput = input.string(MARK_STYLE_COLUMN, "Marker style",
     options = [MARK_STYLE_COLUMN, MARK_STYLE_BOX, MARK_STYLE_BOTH], group = GRP_MARK,
     display = display.none,
     tooltip = "How a marked state is drawn on the price chart." +
     "\n- Bar column: colours the full height of each marked bar." +
     "\n- Price box: one rectangle per episode, from the first marked bar to the last, spanning the highest high and lowest low reached inside it." +
     "\n- Both: draws each of them." +
     "\n- The box always covers the whole episode, so the Marker mode below applies to the bar column only.")
string markModeInput = input.string(MARK_ENTRY, "Marker mode", options = [MARK_ENTRY, MARK_HOLD],
     group = GRP_MARK, display = display.none,
     tooltip = "How much of an episode the bar column paints." +
     "\n- Entry bar only: the single bar the state was entered on, which reads as a vertical rule." +
     "\n- Every bar in the tier: paints for as long as the state holds, which reads as a shaded region." +
     "\n- The price box ignores this and always spans the whole episode.")
int markOpacityInput = input.int(82, "Bar column transparency", minval = 0, maxval = 100,
     group = GRP_MARK, display = display.none,
     tooltip = "0 is opaque, 100 is invisible." +
     "\n- Read only when Marker style is Bar column or Both." +
     "\n- Deliberately faint: this paints a full bar column and it has to sit behind the candles, not over them.")
int boxOpacityInput = input.int(90, "Price box transparency", minval = 0, maxval = 100,
     group = GRP_MARK, display = display.none,
     tooltip = "0 is opaque, 100 is invisible." +
     "\n- Read only when Marker style is Price box or Both." +
     "\n- Fainter than the bar column by default: a box covers the candles inside it, not just the space around them.")
bool boxBorderInput = input.bool(true, "Outline the price box", group = GRP_MARK,
     tooltip = "Draws the box's edge in the same colour at a stronger opacity, so an episode's start and end stay readable at a high box transparency." +
     "\n- Read only when Marker style is Price box or Both.")
bool markPaneInput = input.bool(true, "Also mark in this pane", group = GRP_MARK,
     tooltip = "Paints the same bar columns behind the percentile line." +
     "\n- Lets a marker on the price chart be lined up with the value that produced it." +
     "\n- Bar columns only; the pane has no price axis for a box to span.")

// The market context box. It carries what the panel's numbers amount to, in
// words, on the price chart -- the reading a user otherwise has to make for
// themselves by looking down at the pane and translating.
//
// It is a force_overlay table pinned to a corner of the price pane. Both
// positions are the same object and differ only in which corner. "Middle right"
// is the default -- it is the one edge the chart's own legend cannot reach.
//
// A third position, "Above price", was a label riding the last bar. It is
// removed: a label body extends to the RIGHT of its anchor, and the anchor is
// the last bar, so on a chart sitting where the platform leaves it the box was
// almost entirely off-screen. It also could not be styled -- a label takes one
// text_size, one text_color and one text_formatting for the whole object, so it
// showed the box's five styled rows as one flat block. Both were observed on a
// chart on 2026-08-02.
string contextBoxInput = input.string("Middle right", "Market context box",
     options = ["Off", "Top right", "Middle right"], group = GRP_MARK, display = display.none,
     tooltip = "Draws a summary box on the price chart, coloured by the same tier colour as the dashboard." +
     "\n- Off: no box." +
     "\n- Top right: pinned to the top-right corner of the price chart. It does not move when price does." +
     "\n- Middle right: pinned to the middle-right edge of the price chart. The default, and the one corner the chart's own legend cannot reach." +
     "\n- Either way the box stays where you put it while the chart is scrolled and zoomed. It always reports the last bar." +
     "\n- This is a separate setting from Dashboard position, which moves the panel inside this pane. Neither one affects the other." +
     "\n- If the box does not appear, check whether Dashboard position is set to the same corner and move one of them. The two are drawn in different panes, but the platform documents one table per position." +
     "\n- The two headings print one size larger than the body, in bold and in yellow." +
     "\n- It reports size only and says nothing about direction. That line is part of the box and has no off switch.")
// Named rather than written inline into `active` below: a bool built from
// comparing two string inputs is the one shape known to have failed there.
bool contextBoxOn = contextBoxInput != "Off"
string contextSizeInput = input.string("Small", "Market context text size",
     options = ["Tiny", "Small", "Normal", "Large"], group = GRP_MARK, display = display.none,
     active = contextBoxOn,
     tooltip = "Text size for the market context box only. It does not change the panel, which has its own size setting under Display." +
     "\n- The two headings print one size larger than this, so raising this raises both together." +
     "\n- Large sets the headings to the largest size the platform offers, so they stop growing there while the body text does not.")

// ---------------------------------------------------------------------------
// Functions
// ---------------------------------------------------------------------------

// Population standard deviation (divide by N) of the last `length` elements of
// `buf`, in ascending buffer order -- the same accumulation order as
// vrc_oracle.stdev_pop, so the two agree bit for bit. na until the buffer holds
// `length` elements.
stdevPop(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        for i = n - length to n - 1
            total += array.get(buf, i)
        float mean = total / length
        float sq = 0.0
        for i = n - length to n - 1
            float d = array.get(buf, i) - mean
            sq += d * d
        result := math.sqrt(sq / length)
    result

// One bar's contribution to the Parkinson variance estimate. A bar with no range
// contributes exactly zero, which is correct rather than degenerate.
parkinsonBar(h, l) =>
    float result = na
    if not na(h) and not na(l) and h > 0 and l > 0 and h >= l
        float logRange = math.log(h / l)
        result := logRange * logRange / (4.0 * LN2)
    result

// One bar's contribution to the Garman-Klass variance estimate. Non-negative on
// every well-formed bar; it goes negative only when a feed reports a close or an
// open outside the high-low range, which is what rvFromTerms()'s clamp is for.
garmanKlassBar(o, h, l, c) =>
    float result = na
    if not na(o) and not na(h) and not na(l) and not na(c) and o > 0 and h > 0 and l > 0 and c > 0 and h >= l
        float logRange = math.log(h / l)
        float logBody = math.log(c / o)
        result := 0.5 * logRange * logRange - GK_COEFF * logBody * logBody
    result

// Root of the mean of the last `length` per-bar variance terms, clamped at zero.
// An undefined term anywhere in the window makes the whole window undefined
// rather than quietly shrinking it.
rvFromTerms(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        bool valid = true
        for i = n - length to n - 1
            float v = array.get(buf, i)
            if na(v)
                valid := false
            else
                total += v
        if valid
            float mean = total / length
            result := mean > 0 ? math.sqrt(mean) : 0.0
    result

// One bar's true range as a fraction of that bar's own close. True range is
// written as max(h, prevClose) - min(l, prevClose), which equals the usual
// three-way max on every input and needs no absolute value.
//
// Dividing by the bar's OWN close rather than by the latest one makes the
// measure invariant to price drift across the window: a symbol that doubled over
// sixty bars would otherwise have its oldest ranges measured against today.
atrBar(h, l, pc, c) =>
    float result = na
    if not na(h) and not na(l) and not na(pc) and not na(c) and h > 0 and l > 0 and pc > 0 and c > 0
        result := (math.max(h, pc) - math.min(l, pc)) / c
    result

// The clamped MEAN of the last `length` per-bar terms, with no square root. This
// is ATR's window statistic and the one place the four estimators are not
// interchangeable: a true range is a level, not a variance, so rooting the mean
// would be wrong -- and silently so, since the root of a small positive number
// is another small positive number.
//
// It is a simple mean over exactly `length` bars, NOT Wilder's recursive RMA.
// RMA has infinite memory and so no bar at which it is first defined, which
// would make the reading depend on how much history the chart happened to load.
// The consequence is disclosed rather than hidden: this number does not equal
// the platform's built-in ATR at the same length.
meanFromTerms(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        bool valid = true
        for i = n - length to n - 1
            float v = array.get(buf, i)
            if na(v)
                valid := false
            else
                total += v
        if valid
            float mean = total / length
            result := mean > 0 ? mean : 0.0
    result

// Realized volatility over one window, by the selected estimator. The bar_index
// guard reproduces the oracle's estimator-INDEPENDENT warmup: a range estimator
// could answer one bar earlier than close-to-close and deliberately does not, so
// changing the estimator never moves warmup and never moves how much of the Pine
// Screener's 500-bar window is left for signal.
realizedVol(returnBuffer, termBuffer, length, mode) =>
    float result = na
    if bar_index >= length
        result := mode == EST_CLOSE ? stdevPop(returnBuffer, length) : mode == EST_ATR ? meanFromTerms(termBuffer, length) : rvFromTerms(termBuffer, length)
    result

// 100 * (count of elements <= `current`) / size. `current` is already in `buf`,
// so the current bar is included and ties count as at-or-below.
percentileRank(buf, current) =>
    float result = na
    int n = array.size(buf)
    if n > 0
        int hits = 0
        for i = 0 to n - 1
            if array.get(buf, i) <= current
                hits += 1
        result := 100.0 * hits / n
    result

// Ring buffer push: append, then drop the oldest while over `cap`.
pushCapped(buf, value, cap) =>
    array.push(buf, value)
    if array.size(buf) > cap
        array.shift(buf)

// `x` is meaningfully below `y` when the gap is more than `tol` of `y`. The
// inequality is strict, so at exactly the tolerance the answer is no.
meaningfullyBelow(x, y, tol) =>
    (y - x) > tol * y

// Two-point term structure: the ends decide, the mid window is not consulted.
// MIXED cannot occur in this mode.
termStructureTwoPoint(rvS, rvL, tol) =>
    int result = TS_FLAT
    if meaningfullyBelow(rvS, rvL, tol)
        result := TS_CONTANGO
    else if meaningfullyBelow(rvL, rvS, tol)
        result := TS_BACKWARDATION
    result

// Three-point term structure: the ends decide direction exactly as above, and
// the mid window only flags a non-monotone shape — meaningfully above both
// ends is a hump, meaningfully below both is a dip, and either is MIXED.
termStructureThreePoint(rvS, rvM, rvL, tol) =>
    bool hump = meaningfullyBelow(rvS, rvM, tol) and meaningfullyBelow(rvL, rvM, tol)
    bool dip = meaningfullyBelow(rvM, rvS, tol) and meaningfullyBelow(rvM, rvL, tol)
    int result = termStructureTwoPoint(rvS, rvL, tol)
    if hump or dip
        result := TS_MIXED
    result

// Relative change with a symmetric deadband; both comparisons are strict, so
// exactly the deadband is FLAT.
accelTierOf(a, deadband) =>
    int result = ACCEL_FLAT
    if a > deadband
        result := ACCEL_RISING
    else if a < -deadband
        result := ACCEL_FALLING
    result

// Tier from the percentile. Each threshold is the lower bound of the tier
// above it: a percentile of exactly 25 is NORMAL, exactly 90 is EXTREME.
tierOf(p, quietTh, elevatedTh, extremeTh) =>
    int result = TIER_EXTREME
    if p < quietTh
        result := TIER_QUIET
    else if p < elevatedTh
        result := TIER_NORMAL
    else if p < extremeTh
        result := TIER_ELEVATED
    result

// The bounds of a tier, as percentile values. The two outer tiers have one open
// end each, and the sentinel stands in for it.
tierBoundLow(t, quietTh, elevatedTh, extremeTh) =>
    float result = BOUND_OPEN_LOW
    if t == TIER_NORMAL
        result := quietTh
    else if t == TIER_ELEVATED
        result := elevatedTh
    else if t == TIER_EXTREME
        result := extremeTh
    result

tierBoundHigh(t, quietTh, elevatedTh, extremeTh) =>
    float result = BOUND_OPEN_HIGH
    if t == TIER_QUIET
        result := quietTh
    else if t == TIER_NORMAL
        result := elevatedTh
    else if t == TIER_ELEVATED
        result := extremeTh
    result

// The reported tier, given the raw tier and the tier currently held. `held` is
// the last REPORTED tier, never the last raw one: measuring the band from a
// bound the reading has already crossed would defeat it after a single bar. Once
// the move is allowed the raw tier is adopted in full, so a two-tier jump stays
// a two-tier jump.
applyHysteresis(raw, held, p, quietTh, elevatedTh, extremeTh, band) =>
    int result = raw
    if not na(held) and held != raw and band > 0
        if raw > held
            result := p >= tierBoundHigh(held, quietTh, elevatedTh, extremeTh) + band ? raw : held
        else
            result := p < tierBoundLow(held, quietTh, elevatedTh, extremeTh) - band ? raw : held
    result

// Name lookups for the dashboard. An undefined code reads as a dash rather than
// as a state, so an unclassified bar never shows a regime it does not have.
tierName(t) =>
    string result = "-"
    if t == TIER_QUIET
        result := "QUIET"
    else if t == TIER_NORMAL
        result := "NORMAL"
    else if t == TIER_ELEVATED
        result := "ELEVATED"
    else if t == TIER_EXTREME
        result := "EXTREME"
    result

// Plain English for the four shape codes. The codes underneath are unchanged and
// still carry the frozen values the Screener filter and the alerts quote.
tsName(s) =>
    string result = "-"
    if s == TS_CONTANGO
        result := "BELOW BASELINE"
    else if s == TS_BACKWARDATION
        result := "ABOVE BASELINE"
    else if s == TS_FLAT
        result := "IN LINE"
    else if s == TS_MIXED
        result := "UNEVEN"
    result

accelName(a) =>
    string result = "-"
    if a == ACCEL_RISING
        result := "RISING"
    else if a == ACCEL_FALLING
        result := "FALLING"
    else if a == ACCEL_FLAT
        result := "STEADY"
    result

// The market context headline: what the tier and the acceleration amount to,
// said once, in words a reader who knows none of this vocabulary can still use.
// It is a pure mapping over two codes the product already computes and measures
// nothing of its own, so it cannot become a second opinion the panel disagrees
// with.
//
// Every string names the RANGE, and none uses the words "up" or "down". This box
// is drawn on the price chart, where "PICKING UP" beside a candle reads as a
// claim about the candle. EXPANDING is equally what a hard rally and a hard
// sell-off look like, which is the property that makes this classification
// honest and also what makes it useless as a signal -- so the caller pairs every
// one of these with the standing size-only line.
//
// Each tier has a fourth string for an undefined acceleration. "WIDE AND
// HOLDING" asserts that the reading is not moving, and a bar whose acceleration
// could not be computed has not earned that claim.
contextHeadline(t, a) =>
    string result = "-"
    if t == TIER_ELEVATED or t == TIER_EXTREME
        result := a == ACCEL_RISING ? "RANGE EXPANDING" : a == ACCEL_FALLING ? "STILL WIDE, SETTLING" : a == ACCEL_FLAT ? "WIDE AND HOLDING" : "RANGE IS WIDE"
    else if t == TIER_NORMAL
        result := a == ACCEL_RISING ? "RANGE WIDENING" : a == ACCEL_FALLING ? "RANGE SETTLING" : "TYPICAL FOR THIS SYMBOL"
    else if t == TIER_QUIET
        result := a == ACCEL_RISING ? "NARROW, WIDENING" : a == ACCEL_FALLING ? "RANGE COMPRESSING" : a == ACCEL_FLAT ? "NARROW AND HOLDING" : "RANGE IS NARROW"
    result

// The re-measure prompt: the headline said what the tape is doing, and this says
// what that changes about anything the reader has already sized.
//
// This is the most permissive claim class in the product, and its boundary is
// written into AGENTS.md § Claim rules rather than left to judgement:
//
//   the box may say what to re-measure. It may never say what to trade.
//
// "Check your stops and zones" names something the reader already has on their
// chart and asks them to compare it against a number this script just printed.
// It states no direction, no entry, no exit and no outcome, and it is true
// whether or not they are in a position at all. Two consequences of the banned
// vocabulary before editing a string: "target" is on the list, so these say
// "stops and zones"; and "up" and "down" are banned as substrings, so say the
// bars are getting bigger instead.
contextCheck(t, a) =>
    string result = ""
    if t == TIER_ELEVATED or t == TIER_EXTREME
        result := a == ACCEL_RISING ? "Bars are getting bigger. Check your stops and zones." : a == ACCEL_FALLING ? "Still wide but easing. Anything sized at the widest point is looser than this bar needs." : a == ACCEL_FLAT ? "Wide and steady. Check that your stops and zones fit a bar this size." : "Bars are wide. Check that your stops and zones fit a bar this size."
    else if t == TIER_NORMAL
        result := a == ACCEL_RISING ? "Bars are growing. Check that your stops and zones keep pace." : a == ACCEL_FALLING ? "Bars are shrinking toward typical. Recent sizing is wider than this bar needs." : "Bar size is typical here. Recent sizing still fits."
    else if t == TIER_QUIET
        result := a == ACCEL_RISING ? "Narrow but widening. Re-check anything sized during the quiet stretch." : a == ACCEL_FALLING ? "Bars are shrinking. Stops sized for a wider tape sit far from price." : a == ACCEL_FLAT ? "Narrow and steady. Stops sized for a wider tape sit far from price." : "Bars are narrow. Stops sized for a wider tape sit far from price."
    result

// Tier colour lookup. An undefined tier takes the fallback rather than borrowing
// a neighbour's, so a warming bar is never coloured as though classified.
tierColorOf(t, cQuiet, cNormal, cElevated, cExtreme, fallback) =>
    color result = fallback
    if t == TIER_QUIET
        result := cQuiet
    else if t == TIER_NORMAL
        result := cNormal
    else if t == TIER_ELEVATED
        result := cElevated
    else if t == TIER_EXTREME
        result := cExtreme
    result

// Acceleration colour, reusing the tier palette rather than adding two pickers:
// rising borrows the ELEVATED colour, falling the QUIET colour, steady neutral.
accelColorOf(a, cRising, cFalling, fallback) =>
    color result = fallback
    if a == ACCEL_RISING
        result := cRising
    else if a == ACCEL_FALLING
        result := cFalling
    result

// Three-stop ramp: `lowColor` at 0, `midColor` at 50, `highColor` at 100.
// color.from_gradient() interpolates every RGBA component, so the endpoints'
// transparency ramps with their colour. The caller guarantees `value` is
// defined; an undefined percentile never reaches here.
gradientAt(value, lowColor, midColor, highColor) =>
    value < 50.0 ? color.from_gradient(value, 0.0, 50.0, lowColor, midColor) : color.from_gradient(value, 50.0, 100.0, midColor, highColor)

// One rounded number as a string, or a dash when it is undefined.
numText(x, digits) =>
    na(x) ? "-" : str.tostring(math.round(x, digits))

// ---------------------------------------------------------------------------
// Calculations
// ---------------------------------------------------------------------------

// --- The window set the Sensitivity dropdown selects ------------------------
//
// One dropdown sets all four, because they are not independent. Two invariants
// hold across all three presets:
//
//   - The acceleration window equals the short window. Two RV windows closer
//     together than the window is long share observations, so the comparison
//     moves on that overlap rather than on volatility.
//   - The mid and long windows are 3x and 6x the short one. Holding that ratio
//     fixed is what makes "1.4x" on the short-vs-long row mean the same thing on
//     Fast as on Slow.
//
// reference/vrc_oracle.py PRESETS carries the same table and the parity rows
// compare the two.
int shortLenInput = sensitivityInput == SENS_FAST ? 5 : sensitivityInput == SENS_SLOW ? 20 : 10
int midLenInput   = sensitivityInput == SENS_FAST ? 15 : sensitivityInput == SENS_SLOW ? 60 : 30
int longLenInput  = sensitivityInput == SENS_FAST ? 30 : sensitivityInput == SENS_SLOW ? 120 : 60
int accelLenInput = shortLenInput

// --- The absolute EXTREME override ------------------------------------------
//
// The threshold in force, or 0 when the override is switched off. It is resolved
// per estimator; the constants block above carries the measurement.
float extremeRatioNow = not extremeBySizeInput ? 0.0 : estimatorInput == EST_CLOSE ? OVERRIDE_CLOSE : estimatorInput == EST_PARKINSON ? OVERRIDE_PARKINSON : estimatorInput == EST_GK ? OVERRIDE_GK : OVERRIDE_ATR

// The largest value the short-over-long ratio can take, which is a fact about
// the arithmetic and not a setting. The long window CONTAINS the short one, so
// the ratio is bounded and the bound is attained:
//
//   Variance family (close-to-close, Parkinson, Garman-Klass). RV is the root of
//   a mean of non-negative terms, so the ratio cannot exceed sqrt(L/S).
//   Level family (ATR). RV is a plain mean and takes no root, so the bound is
//   L/S -- the square of the other one.
//
// At the shipped windows that is 2.4495 for three of them and 6.0 for ATR, both
// confirmed numerically over 4000 adversarial series per estimator. The panel
// discloses it, because a threshold means nothing without the range it sits in.
float ratioSpan    = 1.0 * longLenInput / shortLenInput
float ratioCeiling = estimatorInput == EST_ATR ? ratioSpan : math.sqrt(ratioSpan)

// Whether this chart's bars are shorter than a day. timeframe.in_seconds() is
// used rather than timeframe.isintraday, which could not be verified on any page
// that renders.
bool isIntraday = timeframe.in_seconds() < SECONDS_PER_DAY

// The bar whose incoming return spans a session boundary. On daily and higher a
// bar IS a session, so without the intraday guard this would exclude every
// return on the chart and leave the script with nothing to measure.
bool sessionOpenBar = isIntraday and session.isfirstbar

// Two of the four estimators read across a bar boundary, so those two are the
// ones a session gap can reach: close-to-close through the ratio of two closes,
// and ATR through the previous close inside true range. Parkinson and
// Garman-Klass read inside a single bar and are immune by construction.
bool gapSensitiveEstimator = estimatorInput == EST_CLOSE or estimatorInput == EST_ATR
bool dropGapNow = excludeSessionGapInput and gapSensitiveEstimator and sessionOpenBar

// Log return, defined from the second bar. A dropped session-gap return is na
// and never enters a window, so each window reaches further back in bars while
// still holding a full count of returns. Dropping is not zeroing -- a zero
// return is a measurement that price did not move, which would be false.
float logReturn = bar_index > 0 and close > 0 and close[1] > 0 and not dropGapNow ? math.log(close / close[1]) : na

// One return buffer serves all three windows: it holds the most recent
// `bufCap` returns, and each realized-vol window reads its own tail of it.
int bufCap = math.max(longLenInput, math.max(midLenInput, shortLenInput))

var array<float> retBuf = array.new<float>(0)
if not na(logReturn)
    pushCapped(retBuf, logReturn, bufCap)

// One term buffer serves the three non-close estimators; only one is ever active,
// so they cannot collide. What differs is the push rule. Parkinson and
// Garman-Klass are pushed on every bar including the first, since they read
// within a single bar. ATR is pushed only when its term is DEFINED: bar 0 has no
// previous close, and an excluded session-gap term must be dropped rather than
// left as a hole in the window.
var array<float> termBuf = array.new<float>(0)
float barTerm = estimatorInput == EST_PARKINSON ? parkinsonBar(high, low) : estimatorInput == EST_GK ? garmanKlassBar(open, high, low, close) : na
float atrTerm = estimatorInput == EST_ATR and bar_index > 0 and not dropGapNow ? atrBar(high, low, close[1], close) : na
if estimatorInput == EST_ATR
    if not na(atrTerm)
        pushCapped(termBuf, atrTerm, bufCap)
else if estimatorInput != EST_CLOSE
    pushCapped(termBuf, barTerm, bufCap)

float rvShort = realizedVol(retBuf, termBuf, shortLenInput, estimatorInput)
float rvMid   = realizedVol(retBuf, termBuf, midLenInput, estimatorInput)
float rvLong  = realizedVol(retBuf, termBuf, longLenInput, estimatorInput)

// Short-over-long expansion ratio. Undefined when the long window is dead flat.
float volRatio = not na(rvShort) and not na(rvLong) and rvLong > 0 ? rvShort / rvLong : na

// Percentile of the current short-window realized vol against the trailing
// lookback of short-window values, current bar included. It stays na until the
// window is full -- a rank against a partial window is a different statistic,
// and `sampleN` discloses the fill.
var array<float> pctBuf = array.new<float>(0)
if not na(rvShort)
    pushCapped(pctBuf, rvShort, PCT_LOOKBACK)

int sampleN = array.size(pctBuf)
float volPercentile = not na(rvShort) and sampleN == PCT_LOOKBACK ? percentileRank(pctBuf, rvShort) : na

// Acceleration compares the current short-window realized vol against its own
// value `accelLenInput` bars back. The buffer carries one entry per bar,
// including na entries during warmup, so index 0 is that bar and not merely the
// n-th defined value back.
var array<float> accelBuf = array.new<float>(0)
pushCapped(accelBuf, rvShort, accelLenInput + 1)

float rvShortBack = array.size(accelBuf) == accelLenInput + 1 ? array.get(accelBuf, 0) : na
float volAccel = not na(rvShort) and not na(rvShortBack) and rvShortBack > 0 ? (rvShort - rvShortBack) / rvShortBack : na

// --- Classification --------------------------------------------------------

// Each mode requires exactly the windows it reads, and needs the divisors of its
// own tolerance tests to be positive. The two-point mode does not require the
// mid window it never reads: rvMid > 0 is not implied by rvLong > 0, because a
// flat 30-bar window can sit inside a 60-bar window that moved, and those bars
// report the true shape rather than no shape at all.
int tsState = na
if TS_MODE == MODE_TWO_POINT
    if not na(rvShort) and not na(rvLong) and rvLong > 0 and rvShort >= 0
        tsState := termStructureTwoPoint(rvShort, rvLong, TS_TOLERANCE)
else
    if not na(rvShort) and not na(rvMid) and not na(rvLong) and rvLong > 0 and rvMid > 0 and rvShort >= 0
        tsState := termStructureThreePoint(rvShort, rvMid, rvLong, TS_TOLERANCE)

// Zero-vol degeneracy: on a series whose long window is entirely flat the
// percentile formula returns 100, because every 0 is <= 0, which would label a
// dead market EXTREME. The tier is suppressed rather than drawn wrong.
//
// The raw tier is what the percentile alone implies; the reported tier is what
// survives the regime band. `heldTier` carries the last REPORTED tier across
// bars, for the reason applyHysteresis() records.
// The absolute override, tested before the rank because it answers a question
// the rank cannot. `volRatio` being defined already implies both windows are
// defined and the long one is above zero, so no further guard is written.
bool extremeOverrideNow = extremeRatioNow > 0 and not na(volRatio) and volRatio >= extremeRatioNow

var int heldTier = na
int rawTier = na
int volTier = na
if extremeOverrideNow
// Three deliberate properties, each pinned by reference/test_oracle.py.
// It sets the RAW tier as well as the reported one, so the panel never
// reads "band holding" merely because an override fired. It BYPASSES the
// band, because a reading at this multiple is not a borderline crossing.
// And it fires WITHOUT a percentile: the ratio is defined at bar
// max(short, long) while the rank waits 400 bars longer, which is what
// makes a 400-bar lookback affordable at all.
    rawTier := TIER_EXTREME
    volTier := TIER_EXTREME
    heldTier := volTier
else if not na(volPercentile) and not na(rvLong) and rvLong > 0
    rawTier := tierOf(volPercentile, QUIET_TH, ELEVATED_TH, EXTREME_TH)
    volTier := applyHysteresis(rawTier, heldTier, volPercentile, QUIET_TH, ELEVATED_TH, EXTREME_TH, TIER_BAND)
    heldTier := volTier

// True on a bar the band actually acted on. The panel says so in words; it is
// not left to be inferred from a tier that failed to move.
bool tierHeldNow = not na(rawTier) and not na(volTier) and rawTier != volTier

int accelTier = na
if not na(volAccel)
    accelTier := accelTierOf(volAccel, ACCEL_DEADBAND)

// A regime change compares against the previous bar on which both the tier and
// the shape state were defined. The first such bar is not a change.
var int prevTier = na
var int prevTsState = na

bool tierChangedNow = false
bool tsChangedNow = false
if not na(volTier) and not na(tsState)
    if not na(prevTier) and not na(prevTsState)
        tierChangedNow := volTier != prevTier
        tsChangedNow := tsState != prevTsState
    prevTier := volTier
    prevTsState := tsState

bool regimeChanged = tierChangedNow or tsChangedNow

// Every output defined and the percentile window full.
bool outputsSufficient = sampleN == PCT_LOOKBACK and not na(volPercentile) and not na(volRatio) and not na(tsState) and not na(accelTier)

// --- Outputs ----------------------------------------------------------------

float outPercentile    = volPercentile
float outTier          = volTier
float outRatio         = volRatio
float outTsState       = tsState
float outAccelTier     = accelTier
float outRegimeChanged = regimeChanged ? 1 : 0
float outRvShort       = rvShort
float outRvLong        = rvLong
float outSampleN       = sampleN
float outSufficient    = outputsSufficient ? 1 : 0

// Three diagnostics, carried as plots 11 to 13 -- after the ten the Screener
// exposes, so the frozen contract of BUILD_PLAN.md §8.1 is untouched. They let a
// verification row see a mechanism working rather than infer it.
float outRawTier  = rawTier
float outTierHeld = tierHeldNow ? 1 : 0
float outOverride = extremeOverrideNow ? 1 : 0

// The acceleration as a percentage, for the panel only. Plot 5 carries the tier
// code, which is the filterable form.
float outAccelPct = not na(volAccel) ? volAccel * 100.0 : na

// --- Colour ----------------------------------------------------------------
//
// Everything below is presentation. Not one line of it feeds back into a value
// the ten contract plots carry.

// The active gradient ramp, as an if/else chain over `==` -- the form this file
// already uses for every classification. Custom interpolates straight between
// the two pickers, expressed by putting a midpoint of that same ramp at 50.
color rampLow = GRAD_SIGNAL_LOW
color rampMid = GRAD_SIGNAL_MID
color rampHigh = GRAD_SIGNAL_HIGH
if lineGradientInput == GRAD_OCEAN
    rampLow := GRAD_OCEAN_LOW
    rampMid := GRAD_OCEAN_MID
    rampHigh := GRAD_OCEAN_HIGH
else if lineGradientInput == GRAD_EMBER
    rampLow := GRAD_EMBER_LOW
    rampMid := GRAD_EMBER_MID
    rampHigh := GRAD_EMBER_HIGH
else if lineGradientInput == GRAD_MONO
    rampLow := GRAD_MONO_LOW
    rampMid := GRAD_MONO_MID
    rampHigh := GRAD_MONO_HIGH
else if lineGradientInput == GRAD_CUSTOM
    rampLow := gradientLowInput
    rampMid := color.from_gradient(50.0, 0.0, 100.0, gradientLowInput, gradientHighInput)
    rampHigh := gradientHighInput

color tierColorNow = tierColorOf(outTier, tierQuietColorInput, tierNormalColorInput,
     tierElevatedColorInput, tierExtremeColorInput, lineColorInput)

color accelColorNow = accelColorOf(outAccelTier, tierElevatedColorInput, tierQuietColorInput, STATUS_NEUTRAL)

// The gradient colour at this bar's percentile. An undefined percentile falls
// back to the fixed colour rather than to an end of the ramp, so a warming bar
// is never coloured as though it were at percentile 0.
color gradientColorNow = na(outPercentile) ? lineColorInput : gradientAt(outPercentile, rampLow, rampMid, rampHigh)

color lineColorNow = gradientColorNow
if lineColorModeInput == LINE_MODE_TIER
    lineColorNow := tierColorNow
else if lineColorModeInput == LINE_MODE_FIXED
    lineColorNow := lineColorInput

// The fill takes the line's own colour, so Auto gradient shades the area under
// the line with the same ramp the line is drawn in.
color fillColorNow = showFillInput ? color.new(lineColorNow, fillOpacityInput) : TRANSPARENT

// The tier bands and their bounds. Both switches express "off" as a fully
// transparent colour, because an hline and a fill each take a colour and neither
// can be placed inside an if.
color boundColor = showBoundsInput ? color.new(color.gray, 55) : TRANSPARENT
color edgeColor = showBoundsInput ? color.new(color.gray, 75) : TRANSPARENT

color zoneQuietColor = showZonesInput ? color.new(tierQuietColorInput, zoneOpacityInput) : TRANSPARENT
color zoneNormalColor = showZonesInput ? color.new(tierNormalColorInput, zoneOpacityInput) : TRANSPARENT
color zoneElevatedColor = showZonesInput ? color.new(tierElevatedColorInput, zoneOpacityInput) : TRANSPARENT
color zoneExtremeColor = showZonesInput ? color.new(tierExtremeColorInput, zoneOpacityInput) : TRANSPARENT

// --- Extreme markers -------------------------------------------------------

// The EXTREME entry is computed independently of whether EXTREME is being
// marked: it is what the third alertcondition fires on, and an alert whose
// behaviour depended on a display setting would be a defect.
bool extremeEntryNow = tierChangedNow and not na(volTier) and volTier == TIER_EXTREME

// The state this bar is marked for, or na for none. A marked tier always wins
// over RISING -- the two questions overlap, and the tier is the product's
// headline classification while RISING is a qualifier on it, so RISING paints
// only where the tier itself is not being painted.
bool tierIsMarked = not na(volTier) and (volTier == TIER_QUIET ? markQuietInput : volTier == TIER_NORMAL ? markNormalInput : volTier == TIER_ELEVATED ? markElevatedInput : markExtremeInput)
bool risingIsMarked = markRisingInput and not na(accelTier) and accelTier == ACCEL_RISING

int markState = na
if tierIsMarked
    markState := volTier
else if risingIsMarked
    markState := MARK_STATE_RISING

// An episode is a run of bars carrying the SAME marked state. It ends when that
// state changes, which is not the same event as a tier change: an ELEVATED
// stretch flowing into an EXTREME one is two episodes when both are marked, and
// one RISING run can span several tiers when none of them is.
//
// The previous bar's state is carried in a `var` rather than read with
// `markState[1]`. A history reference on a variable that is na across long
// stretches is the shape that provokes Pine's "cannot determine the referencing
// length" error and a max_bars_back argument to answer it.
var int prevMarkState = na
bool markStateChanged = not na(markState) and (na(prevMarkState) or markState != prevMarkState)
bool markBarNow = not na(markState) and (markModeInput == MARK_ENTRY ? markStateChanged : true)
prevMarkState := markState

// Every marker takes its colour from the tier palette, so a marker and the pane
// zone it corresponds to are the same colour by construction.
color markStateColor = markState == MARK_STATE_RISING ? tierElevatedColorInput : tierColorOf(markState, tierQuietColorInput, tierNormalColorInput, tierElevatedColorInput, tierExtremeColorInput, TRANSPARENT)

// One colour expression drives both the price-chart marker and the pane marker,
// so the two can never disagree about which bar was in which state.
color markColorNow = markBarNow ? color.new(markStateColor, markOpacityInput) : color(na)

// Which of the two price-chart forms is drawn. "Both" selects neither literal,
// so each test is written against the form it excludes.
bool drawMarkColumns = markStyleInput != MARK_STYLE_BOX
bool drawMarkBoxes = markStyleInput != MARK_STYLE_COLUMN

// The box reads the state directly rather than markColorNow, because a box
// always spans the whole episode and markColorNow may be a single bar.
bool inMarkedState = not na(markState)

// --- Dashboard state -------------------------------------------------------

// Display mappings and panel strings are calculations, so they sit here rather
// than in the visuals section.
string dashPosition = switch dashPositionInput
    "Top left" => position.top_left
    "Top center" => position.top_center
    "Top right" => position.top_right
    "Bottom left" => position.bottom_left
    "Bottom center" => position.bottom_center
    => position.bottom_right

string dashTextSize = switch dashTextSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

string contextSize = switch contextSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

// The box's two headings, one step up the same ladder, so that "slightly bigger"
// tracks the user's size setting instead of being a fixed figure. At the "Large"
// setting the step lands on size.huge, the top of the ladder, and stops there.
string contextHeadSize = switch contextSizeInput
    "Tiny" => size.small
    "Small" => size.normal
    "Normal" => size.large
    => size.huge

// The market context table's corner, resolved at global scope for the same
// reason `dashPosition` above is: that is the shape the tables page documents.
// `Off` never reaches a draw, so the two live positions are the whole domain.
string contextPosition = contextBoxInput == "Middle right" ? position.middle_right : position.top_right

// Every degeneracy states itself here rather than being drawn as a number, and
// each carries its own colour: a dead market is a different event from a warming
// window and does not deserve the same chip.
//
// The override can classify a bar the percentile cannot rank, so the panel can
// be reporting a real EXTREME tier while the rank behind it is still filling.
// The regime row says which, and this row keeps naming the fill.
string statusText = ""
color statusColor = STATUS_WARN
if not na(rvLong) and rvLong == 0
    statusText := "NO MOVEMENT - realized volatility is zero across the long window"
    statusColor := STATUS_NEUTRAL
else if not outputsSufficient
    statusText := "WARMING UP - " + str.tostring(sampleN) + " of " + str.tostring(PCT_LOOKBACK) + " bars"
    statusColor := STATUS_WARN

bool hasStatus = statusText != ""

// The regime row is the tier and nothing else; the row below says the whole
// thing in a sentence. A bar can reach EXTREME two ways, and a reader seeing
// EXTREME beside a percentile of 40 would reasonably conclude the script was
// broken -- so the suffix is the disclosure: the tier, the reason, and the
// number that produced it.
string overrideNote = not extremeOverrideNow ? "" : " | by size: " + numText(outRatio, 2) + "x, at or past " + numText(extremeRatioNow, 2) + "x"
string regimeText = tierName(outTier) + overrideNote

// One sentence naming what the panel is reporting -- the row a reader who knows
// none of the vocabulary can still act on, and deliberately the second row
// rather than a footnote. It states where this reading sits among past readings
// and which way the recent ones have moved, and nothing about what comes next.
string trendClause = na(outAccelTier) ? "" : outAccelTier == ACCEL_RISING ? ", and rising" : outAccelTier == ACCEL_FALLING ? ", and falling" : ", and steady"
string plainText = "Not enough history yet to rank this bar."
if not na(outPercentile)
    plainText := "Volatility over the last " + str.tostring(shortLenInput) + " bars is higher than\n" + numText(outPercentile, 0) + "% of the last " + str.tostring(PCT_LOOKBACK) + " readings" + trendClause + "."
if extremeOverrideNow
// Two different sentences, because the two cases are genuinely different.
// With a rank present the override is saying the rank is understating
// things; without one it is the only reading there is, and "not enough
// history" beside a live EXTREME tier would be a straight contradiction.
    plainText := na(outPercentile) ? "The last " + str.tostring(shortLenInput) + " bars are " + numText(outRatio, 2) + "x as volatile as the last " + str.tostring(longLenInput) + " -\nextreme by size, before there is enough history to rank it" + trendClause + "." : "The last " + str.tostring(shortLenInput) + " bars are " + numText(outRatio, 2) + "x as volatile as the last " + str.tostring(longLenInput) + ",\nwhich is extreme by size whatever the " + numText(outPercentile, 0) + "% rank says" + trendClause + "."

string accelText = accelName(outAccelTier) + (na(outAccelPct) ? "" : " | " + numText(outAccelPct, 1) + "% vs " + str.tostring(accelLenInput) + " bars ago")

// The short-vs-long row names both windows and states the gap as a percentage,
// rather than leaving the reader to know that 1.34 is a ratio and which way up
// it is. The gap is folded positive by the same conditional that chooses the
// word, so the number and the "more"/"less" beside it cannot disagree.
string ratioText = "-"
if not na(outRatio)
    bool shortIsHotter = outRatio >= 1.0
    float ratioGapPct = (shortIsHotter ? outRatio - 1.0 : 1.0 - outRatio) * 100.0
    ratioText := numText(outRatio, 2) + "x - the last " + str.tostring(shortLenInput) + " bars are\n" + numText(ratioGapPct, 0) + "% " + (shortIsHotter ? "more" : "less") + " volatile than the last " + str.tostring(longLenInput)

// The shape, with the mode that produced it, both in plain words.
string shapeText = tsName(outTsState) + " | " + TS_MODE + ", tolerance " + numText(TS_TOLERANCE, 2)

// The absolute level, standing next to the rank. A percentile is
// self-normalising: about a tenth of all bars sit in the top tier however quiet
// the year has been, so the top of a dead six months reads EXTREME exactly as a
// genuine storm does. This row is what tells them apart. Unannualised, in the
// same units as the returns, as a percentage per bar.
string levelText = na(outRvShort) or na(outRvLong) ? "-" : numText(outRvShort * 100.0, 3) + "% short / " + numText(outRvLong * 100.0, 3) + "% long, per bar"

// The band, and whether it is holding a tier back on this bar. When it is, the
// raw tier is named too, so the reader can see the reading that was refused.
//
// The override's own row states the threshold, whether it is firing, and the
// ceiling the ratio cannot exceed -- a threshold without the range it sits in is
// not a number a reader can judge.
string sizeRuleText = extremeRatioNow == 0.0 ? "off" : "EXTREME at " + numText(extremeRatioNow, 2) + "x of " + numText(ratioCeiling, 2) + "x max" + (extremeOverrideNow ? " | firing now" : "")

string bandText = TIER_BAND == 0.0 ? "off" : numText(TIER_BAND, 1) + " pts" + (tierHeldNow ? " | holding " + tierName(outTier) + ", raw " + tierName(outRawTier) : "")

// The basis names the estimator actually in force. A panel that kept saying
// "close-to-close" while measuring something else would be worse than no panel.
string basisText = estimatorInput + (gapSensitiveEstimator and excludeSessionGapInput and isIntraday ? " | session gap excluded" : "")

// The compact panel's two folded strings. `setupText` is the whole of the full
// panel's configuration disclosure on one line: the estimator and its gap
// treatment, all three windows, the lookback, the band, and the comparison mode
// with its tolerance. AGENTS.md forbids a disclosure from acquiring an off
// switch, and a compact mode that simply dropped those rows would be exactly
// that. Folding is not hiding.
//
// Two rows genuinely leave, and each has somewhere else to be. `Sample n` has
// nothing to report once the window is full, and the Status row reads
// "WARMING UP - n of N" in its place. The band's holding note moves onto the
// regime row, where the tier it qualifies already sits.
string setupText = basisText +
     " | windows " + str.tostring(shortLenInput) + "/" + str.tostring(midLenInput) + "/" + str.tostring(longLenInput) +
     " | lookback " + str.tostring(PCT_LOOKBACK) +
     " | band " + (TIER_BAND == 0.0 ? "off" : numText(TIER_BAND, 1) + " pts") +
     " | size rule " + (extremeRatioNow == 0.0 ? "off" : numText(extremeRatioNow, 2) + "x of " + numText(ratioCeiling, 2) + "x max") +
     " | " + TS_MODE + ", tol " + numText(TS_TOLERANCE, 2)

string regimeCompactText = tierName(outTier) + overrideNote + (tierHeldNow ? " | band holding, raw " + tierName(outRawTier) : "")

// --- Market context text ----------------------------------------------------
//
// The price chart's summary. It exists because the panel reports numbers and a
// reader still has to translate them.
//
// It restates the panel's own figures rather than computing its own: two
// surfaces reporting the same reading must not be able to disagree, so every
// number below is the same variable the panel cell reads, formatted by the same
// numText() helper.
//
// One line is generated rather than chosen, and it is the line that has to
// survive a publication review.
//
// `outRatio` is the SHORT window over the long one, so the gap it yields is a
// statement about the short window, and the sentence must have the short window
// -- current bar size -- as its subject. At 1.69x the current bar is 69% wider
// than a distance measured over the longer stretch. The MIRROR of that sentence
// is not true with the same number: the longer stretch is 1/1.69 of current,
// which is 41% short, not 69%. Reading the gap onto the wrong subject is the
// defect this line shipped with until it was found on a chart -- the direction
// was right and the magnitude was not (TEST_LEDGER.md row 57).
//
// The number is deliberately the same one the panel's `Short vs long` row
// prints, so the two surfaces cannot disagree about a figure a reader sees
// twice. Stating the consequence of a measurement is description; naming what
// the reader should then do about it is not, and is written nowhere here.
string contextRatioLine = ""
if not na(outRatio)
    bool contextShortHotter = outRatio >= 1.0
    float contextGapPct = (contextShortHotter ? outRatio - 1.0 : 1.0 - outRatio) * 100.0
    contextRatioLine := "Current bar size is " + numText(contextGapPct, 0) + "% " + (contextShortHotter ? "wider than" : "short of") + " anything measured on the last " + str.tostring(longLenInput) + " bars."

// The box is assembled as four NAMED BLOCKS plus the disclosure, rather than as
// one paragraph, because each block is a table cell and a TABLE CELL takes its
// own `text_size`, `text_color` and `text_formatting`. That is what buys the
// headings a size step, bold and yellow over a regular white body.
//
// It is worth knowing why the blocks are separate rather than one string: the
// box used to have a third position drawn as a LABEL, and a label takes one of
// each for the WHOLE object, so that path could only ever show this as one flat
// block. The label is gone and the asymmetry with it, but the block structure
// is kept because it is also the right shape for a table.
//
// Pine has no other bold: there is no font-weight argument anywhere in the
// language, and the only other lever on emphasis is `text_size`. Neither is
// faked with Unicode bold glyphs, which would render as fallback boxes wherever
// the chart's font lacks the block.
string contextTier  = statusText
string contextStats = ""
string contextHead  = ""
string contextBody  = ""

// A status wins over everything, and takes the stats, the heading and the ratio
// line with it. A context claim with no data behind it would be the panel
// asserting a reading it has just said it cannot make.
if not hasStatus
    contextTier := tierName(outTier) + (na(outPercentile) ? "" : "  " + numText(outPercentile, 2))
    contextStats := BULLET + "Short vs long  " + (na(outRatio) ? "-" : numText(outRatio, 2) + "x") +
         "\n" + BULLET + "Acceleration  " + accelName(outAccelTier)
    contextHead := extremeOverrideNow and na(outPercentile) ? "EXTREME BY SIZE" : contextHeadline(outTier, outAccelTier)
    string contextPlain = na(outPercentile) ? "" : BULLET + "Volatility over the last " + str.tostring(shortLenInput) + " bars is higher than " + numText(outPercentile, 0) + "% of the last " + str.tostring(PCT_LOOKBACK) + " readings."
// The re-measure prompt and the ratio line are one paragraph, because they
// are one thought: the first names what to look at and the second is the
// number that says by how much. Two bullets in one cell for that reason,
// rather than two cells.
//
// An unclassified tier gets no prompt, and the EXTREME-by-size override is
// not an exception. The override reaches the headline because a bar can be
// huge before the percentile window has filled, but contextCheck() is still
// asked about `outTier` and still answers "" when there is no tier.
    string contextCheckLine = contextCheck(outTier, outAccelTier)
    string contextPrompts = contextCheckLine == "" ? "" : BULLET + contextCheckLine
    if contextRatioLine != ""
        contextPrompts := contextPrompts + (contextPrompts == "" ? "" : "\n") + BULLET + contextRatioLine
// The plain-English line and the prompts share one cell, as consecutive
// bullets with no blank line between them -- a blank line inside a bulleted
// list breaks the list in two. Either can be absent, the first when there is
// no percentile and the second when there is no tier, and joining them here
// rather than giving them a row each is what stops an absent one leaving a
// blank row in the middle of the box.
    contextBody := contextPlain
    if contextPrompts != ""
        contextBody := contextBody + (contextBody == "" ? "" : "\n") + contextPrompts

// Row tints. With the tint switched off every one of them is fully transparent,
// which is how "no fill" is expressed for a table cell.
color tintHeader = colorDashboardInput ? color.new(hasStatus ? statusColor : tierColorNow, TINT_REGIME) : TRANSPARENT
color tintPercentile = colorDashboardInput and not na(outPercentile) ? color.new(gradientColorNow, TINT_VALUE) : TRANSPARENT
color tintRatio = colorDashboardInput and not na(outRatio) ? color.new(outRatio >= 1.0 ? tierElevatedColorInput : tierQuietColorInput, TINT_RATIO) : TRANSPARENT
color tintAccel = colorDashboardInput and not na(outAccelTier) ? color.new(accelColorNow, TINT_RATIO) : TRANSPARENT

// The size rule tints only while it is firing, so the row reads as a live state
// rather than as a setting. It takes the EXTREME colour, the tier it produces.
color tintOverride = colorDashboardInput and extremeOverrideNow ? color.new(tierExtremeColorInput, TINT_RATIO) : TRANSPARENT

// The header row is the only near-opaque chip, so it is the only row whose text
// needs an ink chosen against the fill rather than against the pane. Every other
// row is mostly pane, so white reads on all of them whatever the tier.
color headerInk = colorDashboardInput ? DASH_NOTE : DASH_VALUE

// --- Hover glossary --------------------------------------------------------
//
// The definitions a reader needs in order to know what the panel is saying,
// carried on one label's tooltip and built from the settings actually in force.
// Every sentence defines or measures; none advises and none forecasts.

// The SETUP line is the string the compact panel used to print as its own row.
// It was the widest string in the table by a margin, so it set the panel's width
// on its own and the panel overlapped the line it describes. `table.cell()` has
// no `tooltip` parameter, so this label's tooltip is the only hover surface this
// product has. The full panel still itemises all of it row by row.
string glossaryText = "VOLATILITY REGIME CLASSIFIER - what each number means" +
     "\n" +
     "\nSETUP. " + setupText +
     "\n" +
     "\nWHAT THIS DOES, IN ONE PARAGRAPH. It measures how much this symbol has been" +
     "\nmoving over the last " + str.tostring(shortLenInput) + " bars, then asks where that amount sits among" +
     "\nthe symbol's own recent history. It says nothing about direction: a hard" +
     "\nrally and a hard sell-off of the same size read identically. The headline" +
     "\nnumber is a rank from 0 to 100, not a price and not a target, and one" +
     "\nbar in fifty is called EXTREME by absolute size instead - see below." +
     "\nA reading of" +
     "\n90 means this stretch has been more volatile than 90% of the last " + str.tostring(PCT_LOOKBACK) +
     "\nreadings of the same measure, on this symbol and this timeframe. Every" +
     "\nother row either feeds that rank or qualifies it." +
     "\n" +
     "\nBASIS. Every number below comes from this chart, this timeframe and this" +
     "\nsymbol, and from nothing else. No implied volatility, no options data, no" +
     "\nother symbol. The estimator in force is " + estimatorInput + "." +
     (gapSensitiveEstimator and excludeSessionGapInput and isIntraday ?
     "\nThe reading on the first bar of each session is excluded: it spans the" +
     "\nprevious close and the new open, so it is not one bar of trading. It is" +
     "\ndropped, not set to zero, so the windows still hold a full count and" +
     "\nsimply reach further back. This applies to Close-to-close and to ATR," +
     "\nthe two that read across a bar boundary." : "") +
     "\n" +
     "\nSENSITIVITY. " + sensitivityInput + " - windows of " + str.tostring(shortLenInput) + " / " + str.tostring(midLenInput) + " / " + str.tostring(longLenInput) + " bars. The long" +
     "\nwindow is six times the short one at every setting, so the short-vs-long" +
     "\nnumber means the same thing on all three and only the timescale moves." +
     "\n" +
     "\nRV SHORT / MID / LONG. Realized volatility over N = " + str.tostring(shortLenInput) + " / " + str.tostring(midLenInput) + " / " + str.tostring(longLenInput) + " bars," +
     "\nunannualised. " +
     (estimatorInput == EST_CLOSE ? "The population standard deviation of the last N log returns." :
      estimatorInput == EST_PARKINSON ? "The root mean of ln(high/low) squared over the last N bars, scaled by 4 ln 2. It reads the bar's range, so a bar that travels a long way and closes where it opened is not recorded as stillness." :
      estimatorInput == EST_ATR ? "The plain mean, over the last N bars, of each bar's true range divided by that bar's own close. True range is max(high, previous close) minus min(low, previous close). Two things to know about this one: it is a simple N-bar average and not Wilder's recursive smoothing, so it will not equal the platform's built-in ATR at the same length; and it is the only one of the four whose window statistic is a mean rather than the root of a mean, because a range is a level and not a variance." :
      "The root mean over the last N bars of half ln(high/low) squared less 0.386 times ln(close/open) squared. It reads the range and the body together.") +
     "\n" +
     "\nPERCENTILE. Where this bar's short-window realized volatility sits among" +
     "\nthe last " + str.tostring(PCT_LOOKBACK) + " values of that same measure: the percentage of them at or" +
     "\nbelow the current one, current bar included, ties counted as at-or-below." +
     "\nChange the lookback and the same bar reports a different number, which is" +
     "\nwhy the lookback is on the panel every time the panel is drawn." +
     "\n" +
     "\nSAMPLE N. How many of those " + str.tostring(PCT_LOOKBACK) + " values exist yet. Until it reaches " + str.tostring(PCT_LOOKBACK) + "," +
     "\nthe percentile is left undefined rather than ranked against a short window," +
     "\nbecause a rank against a partial window is a different statistic." +
     "\n" +
     "\nREGIME TIER. The percentile cut at three fixed bounds:" +
     "\nQUIET below " + numText(QUIET_TH, 1) + ", NORMAL to " + numText(ELEVATED_TH, 1) + ", ELEVATED to " + numText(EXTREME_TH, 1) + ", EXTREME at or above it." +
     "\nEach bound is the lower edge of the tier above it." +
     "\n" +
     "\nEXTREME BY SIZE. " + (extremeRatioNow == 0.0 ? "Off. Only the rank can reach the EXTREME tier." :
     "A second route into the EXTREME tier, for the case the rank cannot" +
     "\nreach. A percentile is self-normalising: once a violent stretch fills" +
     "\nthe lookback, the rank drifts back toward the middle while nothing has" +
     "\ncalmed down, and a 4x expansion and a 1.2x expansion both read 100 if" +
     "\neach is the maximum of its own window. So whenever RV short reaches " + numText(extremeRatioNow, 2) + "x" +
     "\nRV long, this bar is EXTREME whatever its rank." +
     "\nThat multiple is set for you and it differs by estimator, because the" +
     "\nfour do not produce numbers on the same scale - the range estimators" +
     "\nare less noisy, which compresses this ratio toward 1. Measured over" +
     "\ntwelve seeds: 1.35x on Parkinson, 2.00x on close-to-close, 1.30x on" +
     "\nGarman-Klass, 1.40x on ATR, each firing on about 2% of bars." +
     "\nThe ratio cannot exceed " + numText(ratioCeiling, 2) + "x on this setting, and that is arithmetic" +
     "\nrather than a choice: the long window contains the short one." +
     "\nIt also classifies bars before the ranking window is full, which is" +
     "\nthe first " + str.tostring(shortLenInput + PCT_LOOKBACK - 1) + " bars of any chart. On those bars the tier is real and" +
     "\nthe percentile is still blank; the panel says so rather than showing" +
     "\none without the other.") +
     "\n" +
     "\nREGIME BAND. " + (TIER_BAND == 0.0 ? "Off. The tier changes the moment the percentile crosses a bound." :
     "How far past a bound the percentile must go before the tier actually" +
     "\nchanges, currently " + numText(TIER_BAND, 1) + " points. Holding NORMAL, the reading must reach " + numText(ELEVATED_TH + TIER_BAND, 1) + " to" +
     "\nbecome ELEVATED; holding ELEVATED, it must fall below " + numText(ELEVATED_TH - TIER_BAND, 1) + " to become" +
     "\nNORMAL. The short window is a small sample and its percentile crosses a" +
     "\nnearby bound repeatedly without the market having done anything; the band" +
     "\nresists that and nothing else. Once a bound is genuinely cleared the tier" +
     "\nmoves the whole way, two tiers at a time if that is what the reading says." +
     "\nThe panel names the raw tier on any bar the band is holding one back.") +
     "\n" +
     "\nSHORT VS LONG. RV short divided by RV long, shown as a multiple and as the" +
     "\npercentage gap. Above 1 the recent stretch has been moving more than the" +
     "\nlonger one; below 1, less. This row and the percentile answer two different" +
     "\nquestions: this one is whether things are picking up or settling down right" +
     "\nnow, the percentile is whether the current amount is a lot by this symbol's" +
     "\nown standards." +
     "\n" +
     "\nSHORT VS BASELINE. The same comparison, classified rather than measured, at" +
     "\na tolerance of " + numText(TS_TOLERANCE, 2) + ". ABOVE BASELINE means the short window is" +
     "\nmeaningfully above the long one; BELOW BASELINE is the reverse; IN LINE" +
     "\nmeans the gap is inside the tolerance and is not being called either way." +
     "\nWith all three windows compared, UNEVEN means the mid window sits outside" +
     "\nboth ends - above both, or below both - so the three do not line up in" +
     "\norder and no single direction describes them." +
     "\n" +
     "\nACCELERATION. The relative change in RV short against its own value " + str.tostring(accelLenInput) + " bars" +
     "\nago. RISING or FALLING once that change passes the deadband of " + numText(ACCEL_DEADBAND * 100.0, 1) + "%," +
     "\nSTEADY inside it." +
     "\n" +
     "\nAll of this describes the chart history up to this bar. None of it is a" +
     "\nforecast, and no part of it states or implies a probability."

// ---------------------------------------------------------------------------
// Visuals
//
// The first ten plots are a frozen public contract (BUILD_PLAN.md §8.1): the
// Pine Screener exposes the first ten plots as filters, so their order, their
// titles and their code values never change after publication. New plots append;
// none is ever inserted.
//
// All ten carry a compile-time constant colour. The limitations page charges a
// plot() call two counts instead of one when its colour argument carries a
// stronger qualified type, so keeping every one of the ten at a single count
// makes the contract hold under either reading. That is why each user-coloured
// visual is an ADDITIONAL plot, declared after the tenth.
// ---------------------------------------------------------------------------

plot(outPercentile, "Vol percentile", color = color.blue, display = display.data_window)
plot(outTier, "Regime tier code", color = color.gray, display = display.data_window)
plot(outRatio, "Vol ratio (short/long)", color = color.gray, display = display.data_window)
plot(outTsState, "Short vs baseline code", color = color.gray, display = display.data_window)
plot(outAccelTier, "Acceleration tier", color = color.gray, display = display.data_window)
plot(outRegimeChanged, "Regime changed", color = color.gray, display = display.data_window)
plot(outRvShort, "RV short", color = color.gray, display = display.data_window)
plot(outRvLong, "RV long", color = color.gray, display = display.data_window)
plot(outSampleN, "Percentile sample n", color = color.gray, display = display.data_window)
plot(outSufficient, "Outputs fully defined", color = color.gray, display = display.data_window)

// Plots 11, 12 and 13 — deliberately after the tenth. Everything above this line
// is the Screener contract; everything below it is free to change.
plot(outRawTier, "Regime tier code before the band", color = color.gray, display = display.data_window)
plot(outTierHeld, "Band held the tier", color = color.gray, display = display.data_window)
plot(outOverride, "EXTREME by absolute size", color = color.gray, display = display.data_window)

// --- The styled percentile line ---------------------------------------------
//
// One plot per line style, each carrying the percentile only when its style is
// the selected one and na otherwise, so exactly one of the four ever draws. A
// single plot whose `style` came from an input would need `style` to accept an
// input-qualified argument, which the plots page does not state.
//
// All four are display.pane, so none appears in the Data Window or the status
// line -- the contract plot above is what a reader and the Screener see there.

float lineSeries = lineStyleInput == STYLE_LINE ? outPercentile : na
float steplineSeries = lineStyleInput == STYLE_STEPLINE ? outPercentile : na
float histogramSeries = lineStyleInput == STYLE_HISTOGRAM ? outPercentile : na
float circlesSeries = lineStyleInput == STYLE_CIRCLES ? outPercentile : na

// `linewidth` takes an "input int", which `lineWidthInput` is, so the width does
// take effect. It may appear not to until the line style is changed: the
// Settings > Style tab carries a width entry PER PLOT, and once an instance
// holds one it wins over the argument, so switching style hands the series to a
// different plot whose entry has not been touched. V-CH-37 separates that from
// the simpler explanation, that a width change on a thin line is less visible
// than on histogram bars.
plot(lineSeries, "Percentile line", color = lineColorNow, linewidth = lineWidthInput,
     style = plot.style_line, display = display.pane)
plot(steplineSeries, "Percentile stepline", color = lineColorNow, linewidth = lineWidthInput,
     style = plot.style_stepline, display = display.pane)
plot(histogramSeries, "Percentile histogram", color = lineColorNow, linewidth = lineWidthInput,
     style = plot.style_histogram, display = display.pane)
plot(circlesSeries, "Percentile circles", color = lineColorNow, linewidth = lineWidthInput,
     style = plot.style_circles, display = display.pane)

// The status-line and price-scale chip. It carries the styled colour so the
// number in the scale matches the line, and draws nothing in the pane, so it
// cannot double it.
plot(outPercentile, "Percentile", color = lineColorNow,
     display = display.status_line + display.price_scale)

// --- Fill under the line ----------------------------------------------------
//
// fill() requires two plot IDs and will not mix a plot with an hline, so the
// area under the line is anchored by two plots of its own. Both are drawn fully
// transparent rather than hidden with display.none, since a hidden plot's effect
// on its fill is not stated anywhere that renders. Neither appears in the Data
// Window or the status line.

fillTopPlotID = plot(showFillInput ? outPercentile : na, "Fill top", color = TRANSPARENT,
     display = display.pane)
fillBasePlotID = plot(showFillInput ? 0.0 : na, "Fill base", color = TRANSPARENT,
     display = display.pane)

fill(fillTopPlotID, fillBasePlotID, fillColorNow, "Percentile fill")

// --- Tier zones -------------------------------------------------------------
//
// The four tiers as bands. The bounds and the bands are separately switchable,
// because one reader wants the lines and another wants only the wash.

// The hline IDs are untyped, and so are the two plot IDs above -- not a style
// departure but the only legal form. The type-system page: "Pine does not
// include type keywords for specifying variables of the 'plot' or 'hline' type."
floorHline = hline(0.0, "Floor", color = edgeColor, linestyle = hline.style_dotted)
quietHline = hline(QUIET_TH, "QUIET bound", color = boundColor, linestyle = hline.style_dashed)
elevatedHline = hline(ELEVATED_TH, "ELEVATED bound", color = boundColor, linestyle = hline.style_dashed)
extremeHline = hline(EXTREME_TH, "EXTREME bound", color = boundColor, linestyle = hline.style_dashed)
ceilingHline = hline(100.0, "Ceiling", color = edgeColor, linestyle = hline.style_dotted)

fill(floorHline, quietHline, zoneQuietColor, "QUIET zone")
fill(quietHline, elevatedHline, zoneNormalColor, "NORMAL zone")
fill(elevatedHline, extremeHline, zoneElevatedColor, "ELEVATED zone")
fill(extremeHline, ceilingHline, zoneExtremeColor, "EXTREME zone")

// --- Price-chart markers ----------------------------------------------------
//
// force_overlay puts the price-chart marker on the main pane from a script that
// declares overlay = false. The pane copy is a second bgcolor() call, because
// one bgcolor() paints one pane.
//
// Both forms express "off" as a colour rather than as a branch: a plot-family
// call cannot be placed inside a conditional. The boxes below are the exception
// -- a drawing may be created in a local scope, and this one is.

bgcolor(drawMarkColumns ? markColorNow : color(na), title = "Regime marker (price chart)", force_overlay = true)
bgcolor(markPaneInput and drawMarkColumns ? markColorNow : color(na), title = "Regime marker (pane)")

// --- Regime price boxes -----------------------------------------------------
//
// One rectangle per marked episode, on the main price chart, in the tier colour
// the pane's zones already use.
//
// The box is created once, on the first bar of an episode, and then UPDATED for
// as long as the episode runs -- never deleted and redrawn. That is the FAQ's
// technique for a drawing meant to reach the current bar, and it is a budget
// decision: redrawing would create one box per bar per episode against the
// 200-box registry, instead of one box per episode.
//
// The running high and low are carried in two var floats rather than read back
// with box.get_top() / box.get_bottom(), which no page that renders names.

var box regimeBox = na
var bool regimeBoxOpen = false
var float regimeBoxTop = na
var float regimeBoxBottom = na

if drawMarkBoxes
    if inMarkedState and regimeBoxOpen and not markStateChanged
        regimeBoxTop := math.max(regimeBoxTop, high)
        regimeBoxBottom := math.min(regimeBoxBottom, low)
        box.set_right(regimeBox, bar_index)
        box.set_top(regimeBox, regimeBoxTop)
        box.set_bottom(regimeBox, regimeBoxBottom)
    else if inMarkedState
// Either the first marked bar of the chart, or the bar the marked state
// changed on. A state change ends one episode and opens another even when
// both states are marked.
        regimeBoxTop := high
        regimeBoxBottom := low
        regimeBox := box.new(bar_index, high, bar_index, low,
             border_color = boxBorderInput ? color.new(markStateColor, 30) : TRANSPARENT,
             border_width = 1, bgcolor = color.new(markStateColor, boxOpacityInput),
             force_overlay = true)
        regimeBoxOpen := true
    else
        regimeBoxOpen := false

// --- Dashboard --------------------------------------------------------------
//
// The panel is the disclosure surface. It names the windows, the lookback, the
// sample count, the mode and the estimator in force every time it is drawn,
// because a percentile without its lookback is not the same number twice --
// BUILD_PLAN.md §4 Q-2 puts the mean shift at 10.5 percentile points between a
// 126-bar and a 252-bar lookback on the same series. No row has its own switch,
// and every tinted row still spells its state out in words.

var table dashboardTable = na

if showDashboardInput and barstate.islast
// The row count comes from an input, which is the shape the tables page
// documents. Sizing the table to the mode beats declaring nine rows and
// filling four.
//
// The full panel is NINE rows drawing TEN lines. A table is clipped at its
// pane's boundary and does not scroll, and at twelve rows the last one fell
// outside it -- so `Sample n` joined the Percentile row it qualifies, and
// `Windows`, `Regime band` and `Basis` joined one `Setup` row. That fold
// counted ROWS, and a table is charged in LINES, so the embedded newlines in
// the value cells were folded out afterwards too, all but the one in `Setup`
// that keeps the widest string off a single line. Nothing was dropped: each
// fold replaced a newline with the " | " separator used everywhere else.
    if na(dashboardTable)
        dashboardTable := table.new(position = dashPosition, columns = 2, rows = dashCompactInput ? 4 : 9,
             bgcolor = DASH_BG, border_color = DASH_BORDER, border_width = 1)
// The whole of column 0 and both cells of the header row are BOLD -- every
// row label plus the tier line, so the panel's two axes are what carry
// weight. The value cells are deliberately NOT: six of the nine hold a
// sentence, and bold prose at `size.small` on a tinted fill is less legible
// than regular. The panel keeps its cell borders, unlike the market context
// table, because it has no spacer row to hide.
    if dashCompactInput
        table.cell(dashboardTable, 0, 0, hasStatus ? "Status" : "Regime", text_color = headerInk, text_size = dashTextSize, text_formatting = text.format_bold, bgcolor = tintHeader)
        table.cell(dashboardTable, 1, 0, hasStatus ? statusText : regimeCompactText, text_color = headerInk, text_size = dashTextSize, text_formatting = text.format_bold, bgcolor = tintHeader)
        table.cell(dashboardTable, 0, 1, "In plain terms", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 1, plainText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintPercentile)
        table.cell(dashboardTable, 0, 2, "Short vs long", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 2, ratioText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintRatio)
        table.cell(dashboardTable, 0, 3, "Acceleration", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 3, accelText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintAccel)
    else
        table.cell(dashboardTable, 0, 0, hasStatus ? "Status" : "Regime", text_color = headerInk, text_size = dashTextSize, text_formatting = text.format_bold, bgcolor = tintHeader)
        table.cell(dashboardTable, 1, 0, hasStatus ? statusText : regimeText, text_color = headerInk, text_size = dashTextSize, text_formatting = text.format_bold, bgcolor = tintHeader)
        table.cell(dashboardTable, 0, 1, "In plain terms", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 1, plainText, text_color = DASH_VALUE, text_size = dashTextSize)
        table.cell(dashboardTable, 0, 2, "Percentile", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 2, numText(outPercentile, 1) + " of the last " + str.tostring(PCT_LOOKBACK) + " bars | sample " + numText(outSampleN, 0) + " of " + str.tostring(PCT_LOOKBACK), text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintPercentile)
        table.cell(dashboardTable, 0, 3, "Short vs long", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 3, ratioText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintRatio)
        table.cell(dashboardTable, 0, 4, "Volatility level", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 4, levelText, text_color = DASH_VALUE, text_size = dashTextSize)
        table.cell(dashboardTable, 0, 5, "Acceleration", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 5, accelText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintAccel)
        table.cell(dashboardTable, 0, 6, "Short vs baseline", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 6, shapeText, text_color = DASH_VALUE, text_size = dashTextSize)
        table.cell(dashboardTable, 0, 7, "Size rule", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 7, sizeRuleText, text_color = DASH_VALUE, text_size = dashTextSize, bgcolor = tintOverride)
        table.cell(dashboardTable, 0, 8, "Setup", text_color = DASH_LABEL, text_size = dashTextSize, text_formatting = text.format_bold)
        table.cell(dashboardTable, 1, 8, basisText + " | " + str.tostring(shortLenInput) + "/" + str.tostring(midLenInput) + "/" + str.tostring(longLenInput) + " bars, " + sensitivityInput + "\nband " + bandText, text_color = DASH_VALUE, text_size = dashTextSize)

// --- Hover glossary marker --------------------------------------------------
//
// One label, created once and moved thereafter, riding the right-hand end of the
// percentile line. Its text is the tier and its tooltip is the glossary above.

var label infoLabel = na

// The marker is forced on in compact mode, whatever the input says: the glossary
// is then the only place the configuration is stated, and an off switch on a
// disclosure is the one thing PHASE_GATES.md G-5 forbids. With the full panel the
// rows state it outright, so hiding the marker there stays the user's choice.
bool markerRequired = dashCompactInput and showDashboardInput
if (showInfoMarkerInput or markerRequired) and barstate.islast
    float anchorY = na(outPercentile) ? 50.0 : outPercentile
    if na(infoLabel)
        infoLabel := label.new(bar_index, anchorY, "?", xloc = xloc.bar_index,
             style = label.style_label_left, size = size.normal)
    label.set_xy(infoLabel, bar_index, anchorY)
    label.set_text(infoLabel, hasStatus ? "?" : tierName(outTier))
// The chip takes the panel header's tint rather than a solid fill, so the
// one bright ink reads on it and it stops hiding the line it sits on.
    label.set_color(infoLabel, color.new(hasStatus ? statusColor : tierColorNow, TINT_REGIME))
    label.set_textcolor(infoLabel, DASH_NOTE)
    label.set_tooltip(infoLabel, glossaryText)

// --- Market context box -----------------------------------------------------
//
// The only visual this product puts on the price chart that carries words.
//
// A TABLE anchors to one of nine positions in a pane and does not move when
// price does, which is what a corner setting has to mean. `force_overlay = true`
// is what puts it on the PRICE pane from a script declared overlay = false --
// the visuals overview lists the argument as available on "all plot*()
// functions, bgcolor(), and all drawing *.new() constructor functions".
//
// It is created once and rewritten thereafter, never deleted and redrawn, so a
// per-bar refresh cannot charge one object per bar against a registry.
//
// There used to be a second form here, a label for an "Above price" position,
// and its removal is the whole of amendment A-21's second half. Two reasons,
// both observed on a chart: a label body extends to the right of its anchor and
// the anchor is the last bar, so at the platform's own default scroll the box
// sat off the right-hand edge; and a label carries one text_size, one
// text_color and one text_formatting for the entire object, so it could not
// render the five styled rows below.
//
// BUDGET. Two tables against a ceiling of nine -- "scripts can display a
// maximum of nine tables on the chart, one for each of the possible locations".
// ONE label, down from two, against a max_*_count default of 50 and a 500-ID
// ceiling; the survivor is the hover glossary chip. Both figures read live from
// the limitations page on 2026-08-02. Neither is declared, so the indicator()
// line is untouched -- which matters to whoever verifies this, because a
// declaration change needs the script removed and re-added rather than saved.
//
// Documented but not observed: the tables page says "multiple tables can be used
// in one script, as long as they are each anchored to a different position", and
// says nothing about two tables in two different panes. Whether the panel and
// this box collide at the same corner has a verification row of its own.
var table contextTable = na

if contextBoxOn and barstate.islast
    color contextBg = color.new(hasStatus ? statusColor : tierColorNow, TINT_CONTEXT)
    if na(contextTable)
        contextTable := table.new(position = contextPosition, columns = 1, rows = CONTEXT_ROWS,
             bgcolor = TRANSPARENT, border_color = TRANSPARENT, border_width = 0,
             force_overlay = true)
    // The table's own background is transparent and each content cell
    // paints its own fill, which is what makes the spacer row invisible: a
    // transparent cell over a coloured TABLE would have shown the table's
    // colour through it and displaced the box with a coloured band.
    //
    // The cell borders went with it, because a border is drawn per cell
    // with no way to exclude one, and keeping them would have outlined the
    // empty spacer as a floating rectangle. The rows are distinguished by
    // size, weight and colour instead.
    table.set_bgcolor(contextTable, TRANSPARENT)
    // Every cell is left-aligned. These hold prose, and centred prose is
    // read line by line rather than at a glance; the panel's cells take the
    // table default because each holds one short value.
    //
    // The rows are written out rather than looped so that every style
    // argument stays a compile-time constant: `text_size`, `text_color` and
    // `text_formatting` have no verified qualified type. The cost is that a
    // branch which does not fill a row writes "" to it. Row 0 is the spacer,
    // transparent so that what it displaces is empty chart.
    table.cell(contextTable, 0, 0, "", bgcolor = TRANSPARENT,
         height = contextPosition == position.top_right ? CONTEXT_TOP_PAD : 0.0)
    // The two headings take the same yellow as the panel's regime row, so
    // the two surfaces name the same tier in the same colour.
    if hasStatus
        table.cell(contextTable, 0, 1, contextTier, text_color = DASH_NOTE,
             text_size = contextHeadSize, text_halign = text.align_left,
             text_formatting = text.format_bold, bgcolor = contextBg)
        table.cell(contextTable, 0, 2, CONTEXT_FOOTER, text_color = DASH_NOTE,
             text_size = contextSize, text_halign = text.align_left, bgcolor = contextBg)
        // The status box is two rows deep and the table has five for
        // content. These three are cleared because a cell keeps whatever
        // it was last written until it is written again.
        table.cell(contextTable, 0, 3, "", bgcolor = contextBg)
        table.cell(contextTable, 0, 4, "", bgcolor = contextBg)
        table.cell(contextTable, 0, 5, "", bgcolor = contextBg)
    else
        table.cell(contextTable, 0, 1, contextTier, text_color = DASH_NOTE,
             text_size = contextHeadSize, text_halign = text.align_left,
             text_formatting = text.format_bold, bgcolor = contextBg)
        table.cell(contextTable, 0, 2, contextStats, text_color = DASH_VALUE,
             text_size = contextSize, text_halign = text.align_left, bgcolor = contextBg)
        table.cell(contextTable, 0, 3, contextHead, text_color = DASH_NOTE,
             text_size = contextHeadSize, text_halign = text.align_left,
             text_formatting = text.format_bold, bgcolor = contextBg)
        table.cell(contextTable, 0, 4, contextBody, text_color = DASH_VALUE,
             text_size = contextSize, text_halign = text.align_left, bgcolor = contextBg)
        table.cell(contextTable, 0, 5, CONTEXT_FOOTER, text_color = DASH_NOTE,
             text_size = contextSize, text_halign = text.align_left, bgcolor = contextBg)

// ---------------------------------------------------------------------------
// Alerts
//
// Three conditions, in the order BUILD_PLAN.md §7 freezes them. The order is part
// of the public contract and is the order the Pine Screener presents them in: the
// Screener adds no alert condition automatically and offers all three on demand
// under "Add new filter" -> "Alert conditions".
//
// Every condition is gated on barstate.isconfirmed, which is true on all
// historical bars and on the last update of a realtime bar -- so an alert fires
// once, on a closed bar, and never on an intrabar value that can still change.
// ---------------------------------------------------------------------------

bool alertTierChanged = barstate.isconfirmed and tierChangedNow
bool alertTsChanged = barstate.isconfirmed and tsChangedNow
bool alertExtremeEntry = barstate.isconfirmed and extremeEntryNow

alertcondition(alertTierChanged, "Regime tier changed",
     'VRC: the realized-volatility tier changed on {{ticker}} {{interval}}. Percentile {{plot("Vol percentile")}}, tier code {{plot("Regime tier code")}} (0 quiet, 1 normal, 2 elevated, 3 extreme). This describes the chart history up to this bar and is not a forecast.')

// The {{plot()}} placeholder must keep quoting the plot title exactly -- a
// placeholder naming a plot that does not exist renders as literal text in the
// fired alert.
alertcondition(alertTsChanged, "Short vs baseline changed",
     'VRC: the short volatility window changed its position against the long one on {{ticker}} {{interval}}. Code {{plot("Short vs baseline code")}}: -1 short above long, 1 short below long, 0 in line, 2 uneven across the three windows. This describes the chart history up to this bar and is not a forecast.')

alertcondition(alertExtremeEntry, "Entered the EXTREME tier",
     'VRC: realized volatility entered the EXTREME tier on {{ticker}} {{interval}}. Percentile {{plot("Vol percentile")}} of the configured lookback. This describes the chart history up to this bar and is not a forecast.')
````
