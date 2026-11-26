# ATR Stop Loss Calibrator - Volatility Exit Ladder

- url: https://www.tradingview.com/script/Ok4jNqzt-ATR-Stop-Loss-Calibrator-Volatility-Exit-Ladder/
- type: indicator
- pine_id: PUB;587bcc35ca7344f0a19a9fa3224631f9
- version: 1.0

## Description

ATR Stop Loss Calibrator - Volatility Exit Ladder is an ATR-based exit-reference overlay designed to compare multiple volatility-scaled price distances from a user-selected reference.

The script does not generate entries, market-direction signals, take-profit targets, position sizes, trade recommendations, or broker orders. The terms "Long" and "Short" only identify whether an ATR distance is drawn below or above the active reference price.

Its primary purpose is to help users study how different ATR multipliers, reference models, ATR update policies, and ratcheting methods affect potential exit-reference levels.

Core calculation

The script first calculates True Range as:

True Range = max(
    High - Low,
    abs(High - Previous Close),
    abs(Low - Previous Close)
)

The selected smoothing method is then applied to True Range to calculate ATR.

The available ATR smoothing methods are:

Wilder RMA
EMA
SMA
WMA

Each ladder level is calculated from the active reference price and the ATR value currently in use:

Long Tier n = Reference - ATR Used x Tier Multiplier n

Short Tier n = Reference + ATR Used x Tier Multiplier n

The default multipliers are:

Tier 1 = 1.0 ATR
Tier 2 = 2.0 ATR
Tier 3 = 3.0 ATR

Users can freely modify all three multipliers.

The script keeps the effective tiers in strictly ascending order. If the entered values are out of sequence, the levels are normalized using a minimum 0.05 ATR separation. The readout reports when this normalization has occurred.

Core tier

One of the three tiers can be selected as the Core reference tier.

The Core tier:

Receives the strongest visual emphasis
Is used for the Long and Short cushion calculations
Is used by the reach-state logic
Is used by the core-level alert conditions

The other two tiers remain visible as secondary reference distances.

This makes it possible to compare a primary exit-distance assumption against tighter and wider alternatives without treating every line as equally important.

Reference models

The script provides six reference models.

1. Confirmed bar step

This is the default model.

It uses the selected source value from the previous completed bar together with the previous completed ATR value.

With the default Close source, the levels are recalculated from the prior bar's confirmed close.

This mode updates once per completed bar and is intended for users who prefer stable, confirmed-bar reference values.

2. Live rolling

This model uses the selected source value and developing ATR value from the current bar.

The levels can therefore move while the realtime bar is open.

This mode is intended for users who deliberately want an intrabar volatility ruler rather than a completed-bar reference.

3. Daily snapshot

This model creates a reference at the beginning of each new daily period.

The reference can use either:

The new period's opening price
The previous chart bar's closing price

4. Weekly snapshot

This model uses the same snapshot process at the beginning of each new weekly period.

5. Monthly snapshot

This model uses the same snapshot process at the beginning of each new monthly period.

6. Manual anchor

This model allows the user to enter an independent reference price and start time.

The anchor begins on the first chart bar whose opening time is at or after the selected timestamp.

This can be used to study ATR distances from a price chosen through the user's own analysis. The script does not decide where the manual reference should be placed.

ATR behavior for locked references

Daily, Weekly, Monthly, and Manual references are locked-reference models.

For these models, the ATR value can operate in one of three ways.

Frozen at anchor

The ATR captured when the reference begins remains fixed until the reference resets.

This creates a stable volatility unit for the entire reference cycle.

Confirmed each bar

The reference price remains locked, while the ATR distance is recalculated from the previous completed bar.

This allows the ladder width to adapt to confirmed changes in volatility without moving the underlying reference price.

Live each bar

The reference price remains locked, while the developing ATR value is used.

The ladder can therefore expand or contract while the realtime bar is open.

Exit-distance behavior

Locked-reference models also provide three level behaviors.

1. Non-ratcheting ladder

Each level remains a direct ATR distance from the locked reference.

The levels may still change if Confirmed each bar or Live each bar is selected as the ATR update policy.

2. Immediate ratchet

The ratchet activates as soon as the reference cycle begins.

For the Long side, the script tracks the highest favorable price reached after the anchor and allows the levels to move upward, but not downward.

For the Short side, the script tracks the lowest favorable price reached after the anchor and allows the levels to move downward, but not upward.

3. Delayed ratchet

The ratchet remains inactive until price has moved favorably by a user-selected number of anchor ATR units.

The activation distance is measured from the locked reference using the ATR captured when the reference cycle began.

After activation, the Long levels can only tighten upward and the Short levels can only tighten downward.

Ratchet update timing

Ratchet calculations can use either:

Confirmed bars
Live extremes

Confirmed bars update the favorable extreme and ratchet levels only after a bar closes.

Live extremes allow the ratchet to respond to the developing high or low of the current realtime bar.

Reach evaluation

The selected Core tier can be evaluated using either Close or Wick logic.

Close mode

A Long Core level is considered reached when the closing price is at or below the level.

A Short Core level is considered reached when the closing price is at or above the level.

Wick mode

A Long Core level is considered reached when the bar's low touches or crosses the level.

A Short Core level is considered reached when the bar's high touches or crosses the level.

Confirmed-bar events are enabled by default.

When confirmed-bar ratcheting is used, the current bar is evaluated against the level that existed before that bar was completed. The script does not tighten a level from the current bar's favorable extreme and then assume that the same bar subsequently reached that newly calculated level.

This avoids making an unsupported assumption about whether the bar's high or low occurred first.

The detailed readout can distinguish between:

Not reached
Wick reached
Close beyond

Visual design

The default chart view uses a compact current-level projection rail near the latest bars.

It does not draw six full-width historical bands across the entire chart by default.

The rail includes:

A dashed reference level
Three optional Long-side ATR levels
Three optional Short-side ATR levels
A solid, visually emphasized Core tier
Dotted or dashed secondary tiers
A compact vertical spine connecting each side's visible levels

The Long side uses cyan by default.

The Short side uses pink by default.

The active reference uses yellow by default.

All colors, line widths, visible tiers, rail length, right extension, tag size, and display options can be modified.

Right-edge tags

The default Core only setting displays no more than three primary tags:

Reference
Long Core
Short Core

An All tiers mode is available for users who want to inspect every individual level.

The tags can also be disabled.

Historical research view

The historical ATR path is disabled by default to preserve candle visibility.

When enabled, it displays the recent history of the reference and selected tiers over a user-defined number of bars.

An optional historical ribbon can be added between the reference and the selected Core tier.

The historical view is intended for research and comparison. The compact current rail remains the default presentation.

Readout

The compact readout summarizes:

Active reference price
ATR value in use
ATR as a percentage of the reference
Selected Core tier and multiplier
Long Core price and remaining cushion in ATR units
Short Core price and remaining cushion in ATR units
Current display status

The detailed layout additionally shows:

Reference model
Locked-reference behavior
Ratchet activation state
Core-level reach state

The panel location and text size can be changed from the settings.

Data Window outputs

The script provides the following research values in TradingView's Data Window:

Active reference
ATR used
ATR as a percentage of the reference
Long Tier 1
Long Tier 2
Long Tier 3
Short Tier 1
Short Tier 2
Short Tier 3
Long Core
Short Core
Long cushion in ATR units
Short cushion in ATR units

These outputs allow users to inspect exact numerical values without adding more text to the chart or indicator status line.

Alerts

The following alert conditions are available:

Long ATR Core reference reached
Short ATR Core reference reached
Any displayed ATR Core reference reached
Long delayed ratchet activated
Short delayed ratchet activated
Locked ATR reference reset

Reach alerts follow the selected Close or Wick test and the Confirmed-bar events setting.

Suggested workflow

1. Select whether to display Both sides, Long only, or Short only.

2. Choose the reference model that matches the intended study.

3. Select the ATR length and smoothing method.

4. Enter three ATR multipliers and choose the primary Core tier.

5. For Daily, Weekly, Monthly, or Manual references, select the ATR update policy and optional ratchet behavior.

6. Select Close or Wick reach evaluation.

7. Keep Confirmed-bar events enabled when stable completed-bar alerts are preferred.

8. Use the compact current rail for normal chart viewing.

9. Enable the historical path only when reviewing how the levels behaved across recent bars.

Example research configurations

Confirmed bar step can be used to compare current price with ATR distances calculated from the prior completed bar.

Daily snapshot with Frozen at anchor can be used to maintain one fixed volatility unit from the daily period open or previous close.

Manual anchor with Delayed ratchet can be used to study how an independently selected reference would behave after a favorable ATR-based excursion.

These are research configurations, not trade recommendations.

Default configuration

The default configuration uses:

Both Long and Short sides
Confirmed bar step
Close as the rolling reference source
ATR length 14
Wilder RMA smoothing
1.0, 2.0, and 3.0 ATR tiers
Tier 2 as the Core tier
Non-ratcheting behavior
Close-based reach evaluation
Confirmed-bar events
Current projection rail enabled
Historical path disabled
Reach markers disabled
Core-only right-edge tags
Compact readout

Calculation behavior

The default Confirmed bar step model uses completed-bar source and ATR values.

The default confirmed event setting also waits for the bar to close before generating a reach event.

Live rolling, Live each bar, Live extremes, or disabling confirmed-bar events intentionally allows values or event states to change while the realtime bar is developing.

The lines projected to the right side of the latest bar are visual extensions only. They do not access future prices or future chart data.

Limitations

ATR is a backward-looking measurement of historical price range. It does not predict future volatility, market direction, reversal probability, or execution quality.

The displayed levels are analytical references. They are not stop orders and are not transmitted to a broker.

Actual order execution may differ from a displayed level because of gaps, spread, slippage, liquidity, market closures, broker rules, or instrument-specific contract conditions.

Results depend on the chart symbol, timeframe, available price history, exchange calendar, and data feed.

Synthetic chart types can produce levels from synthetic OHLC values rather than directly traded prices. Standard price charts are preferable when the levels are being compared with executable market prices.

A narrower ATR multiple is not automatically better, and a wider multiple is not automatically safer. Appropriate distances depend on the user's method, holding period, instrument, risk limits, and execution environment.

"Calibrator" refers to the visual comparison of user-selected ATR distances. The script does not optimize settings, score multipliers, or identify a best parameter.

This indicator is provided for analytical and educational use. It does not constitute investment, financial, or trading advice. All analysis, risk decisions, and order placement remain the user's responsibility.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG Group

//@version=6
indicator(
     "ATR Stop Loss Calibrator - Volatility Exit Ladder",
     overlay = true,
     behind_chart = true,
     max_labels_count = 100,
     max_lines_count = 50)

// ============================================================================
// ATR Stop Loss Calibrator - Volatility Exit Ladder
// ----------------------------------------------------------------------------
// This open-source indicator visualizes ATR-scaled exit-reference distances.
// It does not create entries, targets, position sizes, trade directions, or
// performance claims. "Long" and "Short" only identify which side of a user-
// selected reference price the corresponding distance ladder is drawn.
//
// Design goals:
// 1) A compact current-level projection rail instead of a full-chart color mass.
// 2) Three ATR distance tiers with a visually dominant user-selected core tier.
// 3) Confirmed-step, live, calendar-snapshot, and manual-anchor models.
// 4) Optional non-ratcheting, immediate-ratchet, and delayed-ratchet behavior.
// 5) Optional recent history, factual reach events, and Data Window research values.
// 6) Clean status line: inputs and plot values are hidden from the status line.
//
// Cohesion: every visual, readout value, and alert consumes the same active
// reference state and ATR state. The modules do not stack unrelated signals.
// Values are analytical references, not instructions or recommendations.
// "Calibrator" means visual comparison of user-selected distances; the script
// does not optimize, score, or select a best ATR multiplier.
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const string GRP_REFERENCE = "01 — Reference model"
const string GRP_ATR       = "02 — ATR engine"
const string GRP_LADDER    = "03 — Exit-distance ladder"
const string GRP_EVENTS    = "04 — Reach events"
const string GRP_VISUALS   = "05 — Visual design"
const string GRP_READOUT   = "06 — Readout"

const string DIR_BOTH  = "Both"
const string DIR_LONG  = "Long"
const string DIR_SHORT = "Short"

const string MODEL_STEP   = "Confirmed bar step"
const string MODEL_LIVE   = "Live rolling"
const string MODEL_DAY    = "Daily snapshot"
const string MODEL_WEEK   = "Weekly snapshot"
const string MODEL_MONTH  = "Monthly snapshot"
const string MODEL_MANUAL = "Manual anchor"

const string BASIS_OPEN = "Period open"
const string BASIS_PREV = "Previous close"

const string ATR_LOCKED    = "Frozen at anchor"
const string ATR_CONFIRMED = "Confirmed each bar"
const string ATR_LIVE      = "Live each bar"

const string ATR_RMA = "Wilder RMA"
const string ATR_EMA = "EMA"
const string ATR_SMA = "SMA"
const string ATR_WMA = "WMA"

const string BEHAVIOR_FIXED   = "Non-ratcheting ladder"
const string BEHAVIOR_RATCHET = "Immediate ratchet"
const string BEHAVIOR_DELAYED = "Delayed ratchet"

const string RATCHET_CONFIRMED = "Confirmed bars"
const string RATCHET_LIVE      = "Live extremes"

const string TEST_CLOSE = "Close"
const string TEST_WICK  = "Wick"

const string SIZE_SMALL  = "Small"
const string SIZE_NORMAL = "Normal"
const string SIZE_LARGE  = "Large"

const string POS_TOP_RIGHT    = "Top right"
const string POS_MIDDLE_RIGHT = "Middle right"
const string POS_BOTTOM_RIGHT = "Bottom right"
const string POS_BOTTOM_LEFT  = "Bottom left"

const string LAYOUT_COMPACT  = "Compact"
const string LAYOUT_DETAILED = "Detailed"

const string TAG_CORE = "Core only"
const string TAG_ALL  = "All tiers"
const string TAG_OFF  = "Off"

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string directionMode = input.string(
     DIR_BOTH, "Displayed side",
     options = [DIR_BOTH, DIR_LONG, DIR_SHORT],
     group = GRP_REFERENCE, display = display.none)

string referenceModel = input.string(
     MODEL_STEP, "Reference model",
     options = [MODEL_STEP, MODEL_LIVE, MODEL_DAY, MODEL_WEEK, MODEL_MONTH, MODEL_MANUAL],
     group = GRP_REFERENCE, display = display.none,
     tooltip = "Confirmed bar step uses the prior closed bar's source and ATR. Live rolling updates with the current bar. Snapshot models lock a calendar reference. Manual anchor begins at the selected time and price.")

float referenceSource = input.source(
     close, "Rolling reference source",
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_STEP or referenceModel == MODEL_LIVE)

string snapshotBasis = input.string(
     BASIS_OPEN, "Snapshot price",
     options = [BASIS_OPEN, BASIS_PREV],
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_DAY or referenceModel == MODEL_WEEK or referenceModel == MODEL_MONTH,
     tooltip = "Period open uses the first available chart bar of the new calendar period. Previous close uses the chart bar immediately before that reset.")

string snapshotAtrUpdate = input.string(
     ATR_LOCKED, "Snapshot / manual ATR update",
     options = [ATR_LOCKED, ATR_CONFIRMED, ATR_LIVE],
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_DAY or referenceModel == MODEL_WEEK or referenceModel == MODEL_MONTH or referenceModel == MODEL_MANUAL,
     tooltip = "Frozen at anchor preserves the ATR captured when the reference begins. Confirmed each bar uses the prior closed bar's ATR. Live each bar uses the developing ATR.")

bool manualAnchorEnabled = input.bool(
     false, "Enable manual anchor",
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_MANUAL)

float manualPrice = input.float(
     0.0, "Manual reference price",
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_MANUAL and manualAnchorEnabled,
     tooltip = "Used only by Manual anchor. Zero and negative values are supported for instruments whose price history requires them.")

int manualStartTime = input.time(
     1577836800000, "Manual anchor start time",
     group = GRP_REFERENCE, display = display.none,
     active = referenceModel == MODEL_MANUAL and manualAnchorEnabled,
     tooltip = "The first chart bar whose opening time is at or after this timestamp begins the manual anchor.")

int atrLength = input.int(
     14, "ATR length",
     minval = 1, maxval = 1000,
     group = GRP_ATR, display = display.none)

string atrMethod = input.string(
     ATR_RMA, "ATR smoothing",
     options = [ATR_RMA, ATR_EMA, ATR_SMA, ATR_WMA],
     group = GRP_ATR, display = display.none)

float tier1Input = input.float(
     1.0, "Tier 1 multiplier",
     minval = 0.05, maxval = 100.0, step = 0.05,
     group = GRP_LADDER, inline = "tiers", display = display.none)

float tier2Input = input.float(
     2.0, "Tier 2",
     minval = 0.05, maxval = 100.0, step = 0.05,
     group = GRP_LADDER, inline = "tiers", display = display.none)

float tier3Input = input.float(
     3.0, "Tier 3",
     minval = 0.05, maxval = 100.0, step = 0.05,
     group = GRP_LADDER, inline = "tiers", display = display.none,
     tooltip = "Effective tiers are kept strictly ascending. Out-of-order values are lifted by a 0.05 minimum gap and reported in the readout.")

int coreTier = input.int(
     2, "Core reference tier",
     minval = 1, maxval = 3,
     group = GRP_LADDER, display = display.none,
     tooltip = "The selected tier receives the strongest visual emphasis and is used by reach events and cushion calculations.")

string stopBehavior = input.string(
     BEHAVIOR_FIXED, "Locked-model behavior",
     options = [BEHAVIOR_FIXED, BEHAVIOR_RATCHET, BEHAVIOR_DELAYED],
     group = GRP_LADDER, display = display.none,
     active = referenceModel == MODEL_DAY or referenceModel == MODEL_WEEK or referenceModel == MODEL_MONTH or referenceModel == MODEL_MANUAL,
     tooltip = "Ratchet modes are available for Daily, Weekly, Monthly, and Manual anchor models. Rolling models remain fixed-distance ladders by design.")

float ratchetActivationAtr = input.float(
     1.0, "Delayed-ratchet activation",
     minval = 0.0, maxval = 100.0, step = 0.05,
     group = GRP_LADDER, display = display.none,
     active = (referenceModel == MODEL_DAY or referenceModel == MODEL_WEEK or referenceModel == MODEL_MONTH or referenceModel == MODEL_MANUAL) and stopBehavior == BEHAVIOR_DELAYED,
     tooltip = "Favorable excursion from the locked reference, measured in the ATR captured at the anchor.")

string ratchetUpdateMode = input.string(
     RATCHET_CONFIRMED, "Ratchet updates",
     options = [RATCHET_CONFIRMED, RATCHET_LIVE],
     group = GRP_LADDER, display = display.none,
     active = (referenceModel == MODEL_DAY or referenceModel == MODEL_WEEK or referenceModel == MODEL_MONTH or referenceModel == MODEL_MANUAL) and stopBehavior != BEHAVIOR_FIXED,
     tooltip = "Confirmed bars tighten only after a bar closes. Live extremes can tighten while the current bar is developing.")

string reachTest = input.string(
     TEST_CLOSE, "Event test",
     options = [TEST_CLOSE, TEST_WICK],
     group = GRP_EVENTS, display = display.none,
     tooltip = "Close tests only the closing price. Wick tests the full high-low range against the selected core tier.")

bool confirmedEventsOnly = input.bool(
     true, "Confirmed-bar events only",
     group = GRP_EVENTS, display = display.none,
     tooltip = "Enabled by default to prevent intrabar alert changes. Disable only when developing-bar events are intentionally required.")

bool showReachMarkers = input.bool(
     false, "Show core-reach markers",
     group = GRP_EVENTS, display = display.none,
     tooltip = "Disabled by default to keep the chart clean. When enabled, markers are limited to the selected recent-bar window.")

int eventMarkerLookback = input.int(
     200, "Marker lookback bars",
     minval = 10, maxval = 5000,
     group = GRP_EVENTS, display = display.none,
     active = showReachMarkers)

bool showCurrentRail = input.bool(
     true, "Show current projection rail",
     group = GRP_VISUALS, display = display.none,
     tooltip = "Draws only the currently active ATR levels as a compact horizontal rail near the latest bars. This is the clean default view.")

int railLookback = input.int(
     8, "Rail length to the left",
     minval = 3, maxval = 250,
     group = GRP_VISUALS, inline = "rail", display = display.none,
     active = showCurrentRail)

int railForward = input.int(
     6, "Right extension",
     minval = 1, maxval = 100,
     group = GRP_VISUALS, inline = "rail", display = display.none,
     active = showCurrentRail)

bool showHistoricalPath = input.bool(
     false, "Show historical ATR path",
     group = GRP_VISUALS, display = display.none,
     tooltip = "Optional research view. Disabled by default because six rolling ATR paths can obscure price action.")

int historicalLookback = input.int(
     200, "Historical path bars",
     minval = 20, maxval = 5000,
     group = GRP_VISUALS, display = display.none,
     active = showHistoricalPath)

bool showReferenceLine = input.bool(
     true, "Show reference level",
     group = GRP_VISUALS, display = display.none)

bool showTier1 = input.bool(
     true, "Show tier 1",
     group = GRP_VISUALS, inline = "showtiers", display = display.none)

bool showTier2 = input.bool(
     true, "Tier 2",
     group = GRP_VISUALS, inline = "showtiers", display = display.none)

bool showTier3 = input.bool(
     true, "Tier 3",
     group = GRP_VISUALS, inline = "showtiers", display = display.none)

bool showDistanceRibbon = input.bool(
     false, "Show historical core ribbon",
     group = GRP_VISUALS, display = display.none,
     active = showHistoricalPath,
     tooltip = "Applies only to the optional historical path. The current projection rail remains unfilled for maximum candle visibility.")

string tagMode = input.string(
     TAG_CORE, "Right-edge tags",
     options = [TAG_CORE, TAG_ALL, TAG_OFF],
     group = GRP_VISUALS, display = display.none,
     tooltip = "Core only shows at most three tags: reference, long core, and short core. All tiers is available for detailed inspection.")

int tagOffset = input.int(
     1, "Tag offset",
     minval = 0, maxval = 50,
     group = GRP_VISUALS, display = display.none,
     active = tagMode != TAG_OFF)

string rightLabelSize = input.string(
     SIZE_NORMAL, "Tag size",
     options = [SIZE_SMALL, SIZE_NORMAL, SIZE_LARGE],
     group = GRP_VISUALS, display = display.none,
     active = tagMode != TAG_OFF)

int secondaryWidth = input.int(
     1, "Secondary line width",
     minval = 1, maxval = 3,
     group = GRP_VISUALS, display = display.none)

int coreWidth = input.int(
     3, "Core line width",
     minval = 2, maxval = 6,
     group = GRP_VISUALS, display = display.none)

int ribbonTransparency = input.int(
     92, "Historical ribbon transparency",
     minval = 75, maxval = 100,
     group = GRP_VISUALS, display = display.none,
     active = showHistoricalPath and showDistanceRibbon)

color longColor = input.color(
     color.rgb(0, 229, 255), "Long-side color",
     group = GRP_VISUALS, inline = "colors1", display = display.none)

color shortColor = input.color(
     color.rgb(255, 64, 129), "Short-side color",
     group = GRP_VISUALS, inline = "colors1", display = display.none)

color referenceColor = input.color(
     color.rgb(255, 214, 10), "Reference color",
     group = GRP_VISUALS, inline = "colors2", display = display.none)

color eventColor = input.color(
     color.rgb(255, 152, 0), "Reach-marker color",
     group = GRP_VISUALS, inline = "colors2", display = display.none)

bool showReadout = input.bool(
     true, "Show readout",
     group = GRP_READOUT, display = display.none)

string readoutLayout = input.string(
     LAYOUT_COMPACT, "Readout layout",
     options = [LAYOUT_COMPACT, LAYOUT_DETAILED],
     group = GRP_READOUT, display = display.none,
     active = showReadout)

string readoutPosition = input.string(
     POS_BOTTOM_RIGHT, "Readout position",
     options = [POS_TOP_RIGHT, POS_MIDDLE_RIGHT, POS_BOTTOM_RIGHT, POS_BOTTOM_LEFT],
     group = GRP_READOUT, display = display.none,
     active = showReadout)

string readoutSize = input.string(
     SIZE_NORMAL, "Readout text size",
     options = [SIZE_SMALL, SIZE_NORMAL, SIZE_LARGE],
     group = GRP_READOUT, display = display.none,
     active = showReadout)

// ─────────────────────────────────────────────────────────────────────────────
// Utility functions
// ─────────────────────────────────────────────────────────────────────────────
f_atr_smooth(float value, simple int length, simple string smoothingMode) =>
    switch smoothingMode
        ATR_EMA => ta.ema(value, length)
        ATR_SMA => ta.sma(value, length)
        ATR_WMA => ta.wma(value, length)
        => ta.rma(value, length)

f_size(simple string selected) =>
    switch selected
        SIZE_SMALL => size.small
        SIZE_LARGE => size.large
        => size.normal

f_position(simple string selected) =>
    switch selected
        POS_TOP_RIGHT    => position.top_right
        POS_MIDDLE_RIGHT => position.middle_right
        POS_BOTTOM_LEFT  => position.bottom_left
        => position.bottom_right

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_decimal(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_percent(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_mult(float value) =>
    str.tostring(value, "#.##") + "×"

f_bars(int value) =>
    na(value) ? "" : str.tostring(value) + (value == 1 ? " bar" : " bars")

f_reach_state(float coreLevel, bool isLong) =>
    string state = "n/a"
    if not na(coreLevel)
        bool closeBeyond = isLong ? close <= coreLevel : close >= coreLevel
        bool wickReached = isLong ? low <= coreLevel : high >= coreLevel
        state := closeBeyond ? "Close beyond" : wickReached ? "Wick reached" : "Not reached"
    state

f_state_bg(string state, color activeColor, color warningColor, color neutralColor) =>
    state == "Close beyond" ? color.new(color.rgb(239, 68, 68), 8) :
     state == "Wick reached" ? color.new(warningColor, 8) :
     state == "Not reached" ? color.new(activeColor, 82) :
     neutralColor

f_tag(bool enabled, int x, float y, string labelText, color background, color foreground, simple string selectedSize) =>
    label tag = na
    if enabled and not na(y)
        tag := label.new(
             x, y, labelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = background,
             textcolor = foreground,
             size = f_size(selectedSize),
             text_formatting = text.format_bold)
    tag

f_level_line(line currentLine, bool enabled, int x1, int x2, float y, color lineColor, int lineWidth, string selectedStyle) =>
    line result = currentLine
    if enabled and not na(y)
        if na(result)
            result := line.new(
                 x1, y, x2, y,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = lineColor,
                 width = lineWidth,
                 style = selectedStyle)
        else
            line.set_xy1(result, x1, y)
            line.set_xy2(result, x2, y)
            line.set_color(result, lineColor)
            line.set_width(result, lineWidth)
            line.set_style(result, selectedStyle)
    else if not na(result)
        line.delete(result)
        result := na
    result

f_spine_line(line currentLine, bool enabled, int x, float y1, float y2, color lineColor) =>
    line result = currentLine
    if enabled and not na(y1) and not na(y2)
        if na(result)
            result := line.new(
                 x, y1, x, y2,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = lineColor,
                 width = 1,
                 style = line.style_solid)
        else
            line.set_xy1(result, x, y1)
            line.set_xy2(result, x, y2)
            line.set_color(result, lineColor)
    else if not na(result)
        line.delete(result)
        result := na
    result

f_model_short(simple string selected) =>
    switch selected
        MODEL_STEP   => "Confirmed step"
        MODEL_LIVE   => "Live rolling"
        MODEL_DAY    => "Daily snapshot"
        MODEL_WEEK   => "Weekly snapshot"
        MODEL_MONTH  => "Monthly snapshot"
        MODEL_MANUAL => "Manual anchor"
        => selected

f_row(table panel, int row, string leftText, string rightText, color rightBackground, color rightForeground, simple string selectedSize) =>
    color leftBackground = color.new(color.rgb(15, 23, 42), 6)
    color leftForeground = color.rgb(203, 213, 225)
    table.cell(panel, 0, row, leftText,
         bgcolor = leftBackground, text_color = leftForeground,
         text_halign = text.align_left, text_size = f_size(selectedSize),
         text_formatting = text.format_bold)
    table.cell(panel, 1, row, rightText,
         bgcolor = rightBackground, text_color = rightForeground,
         text_halign = text.align_right, text_size = f_size(selectedSize))
    table.cell(panel, 2, row, "  ",
         bgcolor = color.new(color.rgb(15, 23, 42), 100), text_color = color.new(color.rgb(15, 23, 42), 100),
         text_halign = text.align_left, text_size = f_size(selectedSize))

// ─────────────────────────────────────────────────────────────────────────────
// ATR engine
// ─────────────────────────────────────────────────────────────────────────────
float trueRange = ta.tr(true)
float atrRaw = f_atr_smooth(trueRange, atrLength, atrMethod)
float atrConfirmed = atrRaw[1]

// ─────────────────────────────────────────────────────────────────────────────
// Reference engine
// ─────────────────────────────────────────────────────────────────────────────
bool isStepModel = referenceModel == MODEL_STEP
bool isLiveModel = referenceModel == MODEL_LIVE
bool isDailyModel = referenceModel == MODEL_DAY
bool isWeeklyModel = referenceModel == MODEL_WEEK
bool isMonthlyModel = referenceModel == MODEL_MONTH
bool isManualModel = referenceModel == MODEL_MANUAL
bool isSnapshotModel = isDailyModel or isWeeklyModel or isMonthlyModel
bool isLockedModel = isSnapshotModel or isManualModel

bool newDay = timeframe.change("1D")
bool newWeek = timeframe.change("1W")
bool newMonth = timeframe.change("1M")

bool calendarReset =
     isDailyModel ? newDay :
     isWeeklyModel ? newWeek :
     isMonthlyModel ? newMonth :
     false

bool manualEligible = manualAnchorEnabled and time >= manualStartTime
bool manualStart = manualEligible and (barstate.isfirst or not manualEligible[1])

bool referenceReset =
     isSnapshotModel ? (barstate.isfirst or calendarReset) :
     isManualModel ? manualStart :
     false

var float lockedReference = na
var float lockedAtr = na
var int lockedBar = na

if isSnapshotModel
    if referenceReset or na(lockedReference)
        lockedReference := snapshotBasis == BASIS_OPEN ? open : nz(close[1], open)
        lockedAtr := nz(atrConfirmed, atrRaw)
        lockedBar := bar_index
    if not na(lockedReference) and na(lockedAtr) and not na(atrConfirmed)
        lockedAtr := atrConfirmed
else if isManualModel
    if not manualAnchorEnabled
        lockedReference := na
        lockedAtr := na
        lockedBar := na
    else if manualEligible and (referenceReset or na(lockedBar))
        lockedReference := manualPrice
        lockedAtr := nz(atrConfirmed, atrRaw)
        lockedBar := bar_index
    if manualAnchorEnabled and not na(lockedReference) and na(lockedAtr) and not na(atrConfirmed)
        lockedAtr := atrConfirmed
else
    lockedReference := na
    lockedAtr := na
    lockedBar := na

float activeReference =
     isStepModel ? referenceSource[1] :
     isLiveModel ? referenceSource :
     lockedReference

float lockedModelAtr =
     snapshotAtrUpdate == ATR_CONFIRMED ? atrConfirmed :
     snapshotAtrUpdate == ATR_LIVE ? atrRaw :
     lockedAtr

float atrUsed =
     isStepModel ? atrConfirmed :
     isLiveModel ? atrRaw :
     lockedModelAtr

bool manualReady = not isManualModel or (manualAnchorEnabled and manualEligible)
bool calculationReady = manualReady and not na(activeReference) and not na(atrUsed) and atrUsed > 0.0

int activeReferenceBar =
     isStepModel ? bar_index - 1 :
     isLiveModel ? bar_index :
     lockedBar

int referenceAge = calculationReady and not na(activeReferenceBar) ? math.max(bar_index - activeReferenceBar, 0) : na

// Enforce a strictly ascending effective ladder without rejecting user input.
float tier1 = math.max(tier1Input, 0.05)
float tier2 = math.max(tier2Input, tier1 + 0.05)
float tier3 = math.max(tier3Input, tier2 + 0.05)
bool tiersNormalized = tier1 != tier1Input or tier2 != tier2Input or tier3 != tier3Input

// ─────────────────────────────────────────────────────────────────────────────
// Non-ratcheting ladder
// ─────────────────────────────────────────────────────────────────────────────
float fixedLong1 = calculationReady ? activeReference - atrUsed * tier1 : na
float fixedLong2 = calculationReady ? activeReference - atrUsed * tier2 : na
float fixedLong3 = calculationReady ? activeReference - atrUsed * tier3 : na

float fixedShort1 = calculationReady ? activeReference + atrUsed * tier1 : na
float fixedShort2 = calculationReady ? activeReference + atrUsed * tier2 : na
float fixedShort3 = calculationReady ? activeReference + atrUsed * tier3 : na

// ─────────────────────────────────────────────────────────────────────────────
// Optional locked-reference ratchet
// ─────────────────────────────────────────────────────────────────────────────
string effectiveBehavior = isLockedModel ? stopBehavior : BEHAVIOR_FIXED
bool useImmediateRatchet = effectiveBehavior == BEHAVIOR_RATCHET
bool useDelayedRatchet = effectiveBehavior == BEHAVIOR_DELAYED
bool useAnyRatchet = useImmediateRatchet or useDelayedRatchet
bool ratchetMayUpdate = ratchetUpdateMode == RATCHET_LIVE or barstate.isconfirmed
bool trailReset = calculationReady and (referenceReset or barstate.isfirst or not calculationReady[1])

var float cycleAtr = na
var float longExtreme = na
var float shortExtreme = na
var bool longRatchetActive = false
var bool shortRatchetActive = false

var float ratchetLong1 = na
var float ratchetLong2 = na
var float ratchetLong3 = na
var float ratchetShort1 = na
var float ratchetShort2 = na
var float ratchetShort3 = na

if not calculationReady or not isLockedModel
    cycleAtr := na
    longExtreme := na
    shortExtreme := na
    longRatchetActive := false
    shortRatchetActive := false
    ratchetLong1 := na
    ratchetLong2 := na
    ratchetLong3 := na
    ratchetShort1 := na
    ratchetShort2 := na
    ratchetShort3 := na
else
    if trailReset
        cycleAtr := atrUsed
        longExtreme := activeReference
        shortExtreme := activeReference
        longRatchetActive := useImmediateRatchet
        shortRatchetActive := useImmediateRatchet

    if ratchetMayUpdate
        longExtreme := math.max(nz(longExtreme, activeReference), high)
        shortExtreme := math.min(nz(shortExtreme, activeReference), low)

        if useImmediateRatchet
            longRatchetActive := true
            shortRatchetActive := true
        else if useDelayedRatchet
            float activationDistance = nz(cycleAtr, atrUsed) * ratchetActivationAtr
            longRatchetActive := longRatchetActive or longExtreme - activeReference >= activationDistance
            shortRatchetActive := shortRatchetActive or activeReference - shortExtreme >= activationDistance
        else
            longRatchetActive := false
            shortRatchetActive := false

    float cycleAtrSafe = nz(cycleAtr, atrUsed)

    float initialLong1 = activeReference - cycleAtrSafe * tier1
    float initialLong2 = activeReference - cycleAtrSafe * tier2
    float initialLong3 = activeReference - cycleAtrSafe * tier3
    float initialShort1 = activeReference + cycleAtrSafe * tier1
    float initialShort2 = activeReference + cycleAtrSafe * tier2
    float initialShort3 = activeReference + cycleAtrSafe * tier3

    if trailReset
        ratchetLong1 := initialLong1
        ratchetLong2 := initialLong2
        ratchetLong3 := initialLong3
        ratchetShort1 := initialShort1
        ratchetShort2 := initialShort2
        ratchetShort3 := initialShort3

    // Before a delayed ratchet activates, the ladder can still reflect the
    // selected ATR update policy. Once activated, it can only tighten.
    if useDelayedRatchet and ratchetMayUpdate
        if not longRatchetActive
            ratchetLong1 := activeReference - atrUsed * tier1
            ratchetLong2 := activeReference - atrUsed * tier2
            ratchetLong3 := activeReference - atrUsed * tier3
        if not shortRatchetActive
            ratchetShort1 := activeReference + atrUsed * tier1
            ratchetShort2 := activeReference + atrUsed * tier2
            ratchetShort3 := activeReference + atrUsed * tier3

    if useAnyRatchet and ratchetMayUpdate
        if longRatchetActive
            ratchetLong1 := math.max(nz(ratchetLong1, initialLong1), longExtreme - atrUsed * tier1)
            ratchetLong2 := math.max(nz(ratchetLong2, initialLong2), longExtreme - atrUsed * tier2)
            ratchetLong3 := math.max(nz(ratchetLong3, initialLong3), longExtreme - atrUsed * tier3)
        if shortRatchetActive
            ratchetShort1 := math.min(nz(ratchetShort1, initialShort1), shortExtreme + atrUsed * tier1)
            ratchetShort2 := math.min(nz(ratchetShort2, initialShort2), shortExtreme + atrUsed * tier2)
            ratchetShort3 := math.min(nz(ratchetShort3, initialShort3), shortExtreme + atrUsed * tier3)

// Effective displayed levels.
float long1 = useAnyRatchet and isLockedModel ? ratchetLong1 : fixedLong1
float long2 = useAnyRatchet and isLockedModel ? ratchetLong2 : fixedLong2
float long3 = useAnyRatchet and isLockedModel ? ratchetLong3 : fixedLong3

float short1 = useAnyRatchet and isLockedModel ? ratchetShort1 : fixedShort1
float short2 = useAnyRatchet and isLockedModel ? ratchetShort2 : fixedShort2
float short3 = useAnyRatchet and isLockedModel ? ratchetShort3 : fixedShort3

float longCore = coreTier == 1 ? long1 : coreTier == 2 ? long2 : long3
float shortCore = coreTier == 1 ? short1 : coreTier == 2 ? short2 : short3
float coreMultiplier = coreTier == 1 ? tier1 : coreTier == 2 ? tier2 : tier3

bool displayLong = directionMode == DIR_BOTH or directionMode == DIR_LONG
bool displayShort = directionMode == DIR_BOTH or directionMode == DIR_SHORT

// ─────────────────────────────────────────────────────────────────────────────
// Reach context and factual events
// ─────────────────────────────────────────────────────────────────────────────
// Confirmed ratchets are tested against the level established before the
// current bar. This avoids same-bar high/low ordering assumptions.
bool usePriorRatchetEventLevel =
     confirmedEventsOnly and isLockedModel and useAnyRatchet and
     ratchetUpdateMode == RATCHET_CONFIRMED and not referenceReset

float fixedLongCore = coreTier == 1 ? fixedLong1 : coreTier == 2 ? fixedLong2 : fixedLong3
float fixedShortCore = coreTier == 1 ? fixedShort1 : coreTier == 2 ? fixedShort2 : fixedShort3

float longEventLevel =
     usePriorRatchetEventLevel ? nz(longCore[1], fixedLongCore) :
     referenceReset and useAnyRatchet ? fixedLongCore :
     longCore

float shortEventLevel =
     usePriorRatchetEventLevel ? nz(shortCore[1], fixedShortCore) :
     referenceReset and useAnyRatchet ? fixedShortCore :
     shortCore

bool longReachedNow =
     calculationReady and displayLong and
     (reachTest == TEST_CLOSE ? close <= longEventLevel : low <= longEventLevel)

bool shortReachedNow =
     calculationReady and displayShort and
     (reachTest == TEST_CLOSE ? close >= shortEventLevel : high >= shortEventLevel)

bool eventGate = not confirmedEventsOnly or barstate.isconfirmed
bool longReachEvent = eventGate and longReachedNow and (referenceReset or not longReachedNow[1])
bool shortReachEvent = eventGate and shortReachedNow and (referenceReset or not shortReachedNow[1])

bool longRatchetActivationEvent =
     eventGate and isLockedModel and useDelayedRatchet and
     longRatchetActive and (referenceReset or not longRatchetActive[1])

bool shortRatchetActivationEvent =
     eventGate and isLockedModel and useDelayedRatchet and
     shortRatchetActive and (referenceReset or not shortRatchetActive[1])

string longReachState = displayLong ? f_reach_state(longCore, true) : "Off"
string shortReachState = displayShort ? f_reach_state(shortCore, false) : "Off"

float longCushionPrice = calculationReady and displayLong ? close - longCore : na
float shortCushionPrice = calculationReady and displayShort ? shortCore - close : na
float longCushionAtr = not na(longCushionPrice) ? longCushionPrice / atrUsed : na
float shortCushionAtr = not na(shortCushionPrice) ? shortCushionPrice / atrUsed : na
float atrPercent = calculationReady and math.abs(activeReference) > syminfo.mintick ? atrUsed / math.abs(activeReference) * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────────
// Main chart visuals
// The clean default is a compact current-level projection rail. Historical paths
// are optional and deliberately disabled by default.
// ─────────────────────────────────────────────────────────────────────────────
color longTier1Color = color.new(longColor, coreTier == 1 ? 0 : 48)
color longTier2Color = color.new(longColor, coreTier == 2 ? 0 : 30)
color longTier3Color = color.new(longColor, coreTier == 3 ? 0 : 48)

color shortTier1Color = color.new(shortColor, coreTier == 1 ? 0 : 48)
color shortTier2Color = color.new(shortColor, coreTier == 2 ? 0 : 30)
color shortTier3Color = color.new(shortColor, coreTier == 3 ? 0 : 48)

int width1 = coreTier == 1 ? coreWidth : secondaryWidth
int width2 = coreTier == 2 ? coreWidth : secondaryWidth
int width3 = coreTier == 3 ? coreWidth : secondaryWidth

string style1 = coreTier == 1 ? line.style_solid : line.style_dotted
string style2 = coreTier == 2 ? line.style_solid : line.style_dashed
string style3 = coreTier == 3 ? line.style_solid : line.style_dashed

bool historicalBarVisible = showHistoricalPath and bar_index >= last_bar_index - historicalLookback

referencePlot = plot(
     historicalBarVisible and calculationReady and showReferenceLine ? activeReference : na,
     "Reference history",
     color = color.new(referenceColor, 28),
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

long1Plot = plot(
     historicalBarVisible and displayLong and showTier1 ? long1 : na,
     "Long tier 1 history",
     color = color.new(longTier1Color, 18),
     linewidth = coreTier == 1 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

long2Plot = plot(
     historicalBarVisible and displayLong and showTier2 ? long2 : na,
     "Long tier 2 history",
     color = color.new(longTier2Color, 18),
     linewidth = coreTier == 2 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

long3Plot = plot(
     historicalBarVisible and displayLong and showTier3 ? long3 : na,
     "Long tier 3 history",
     color = color.new(longTier3Color, 18),
     linewidth = coreTier == 3 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

short1Plot = plot(
     historicalBarVisible and displayShort and showTier1 ? short1 : na,
     "Short tier 1 history",
     color = color.new(shortTier1Color, 18),
     linewidth = coreTier == 1 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

short2Plot = plot(
     historicalBarVisible and displayShort and showTier2 ? short2 : na,
     "Short tier 2 history",
     color = color.new(shortTier2Color, 18),
     linewidth = coreTier == 2 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

short3Plot = plot(
     historicalBarVisible and displayShort and showTier3 ? short3 : na,
     "Short tier 3 history",
     color = color.new(shortTier3Color, 18),
     linewidth = coreTier == 3 ? 2 : 1,
     style = plot.style_linebr,
     display = display.pane,
     editable = true)

fill(
     referencePlot, long1Plot,
     color = showDistanceRibbon and displayLong and coreTier == 1 ? color.new(longColor, ribbonTransparency) : na,
     title = "Long tier 1 historical ribbon",
     fillgaps = false,
     editable = true)

fill(
     referencePlot, long2Plot,
     color = showDistanceRibbon and displayLong and coreTier == 2 ? color.new(longColor, ribbonTransparency) : na,
     title = "Long tier 2 historical ribbon",
     fillgaps = false,
     editable = true)

fill(
     referencePlot, long3Plot,
     color = showDistanceRibbon and displayLong and coreTier == 3 ? color.new(longColor, ribbonTransparency) : na,
     title = "Long tier 3 historical ribbon",
     fillgaps = false,
     editable = true)

fill(
     referencePlot, short1Plot,
     color = showDistanceRibbon and displayShort and coreTier == 1 ? color.new(shortColor, ribbonTransparency) : na,
     title = "Short tier 1 historical ribbon",
     fillgaps = false,
     editable = true)

fill(
     referencePlot, short2Plot,
     color = showDistanceRibbon and displayShort and coreTier == 2 ? color.new(shortColor, ribbonTransparency) : na,
     title = "Short tier 2 historical ribbon",
     fillgaps = false,
     editable = true)

fill(
     referencePlot, short3Plot,
     color = showDistanceRibbon and displayShort and coreTier == 3 ? color.new(shortColor, ribbonTransparency) : na,
     title = "Short tier 3 historical ribbon",
     fillgaps = false,
     editable = true)

// Compact current-level projection rail.
var line referenceRail = na
var line long1Rail = na
var line long2Rail = na
var line long3Rail = na
var line short1Rail = na
var line short2Rail = na
var line short3Rail = na
var line longSpine = na
var line shortSpine = na

if barstate.islast
    int railX1 = math.max(bar_index - railLookback, 0)
    int railX2 = bar_index + railForward
    bool railReady = showCurrentRail and calculationReady

    referenceRail := f_level_line(
         referenceRail,
         railReady and showReferenceLine,
         railX1, railX2, activeReference,
         color.new(referenceColor, 4), 2, line.style_dashed)

    long1Rail := f_level_line(
         long1Rail,
         railReady and displayLong and showTier1,
         railX1, railX2, long1,
         longTier1Color, width1, style1)

    long2Rail := f_level_line(
         long2Rail,
         railReady and displayLong and showTier2,
         railX1, railX2, long2,
         longTier2Color, width2, style2)

    long3Rail := f_level_line(
         long3Rail,
         railReady and displayLong and showTier3,
         railX1, railX2, long3,
         longTier3Color, width3, style3)

    short1Rail := f_level_line(
         short1Rail,
         railReady and displayShort and showTier1,
         railX1, railX2, short1,
         shortTier1Color, width1, style1)

    short2Rail := f_level_line(
         short2Rail,
         railReady and displayShort and showTier2,
         railX1, railX2, short2,
         shortTier2Color, width2, style2)

    short3Rail := f_level_line(
         short3Rail,
         railReady and displayShort and showTier3,
         railX1, railX2, short3,
         shortTier3Color, width3, style3)

    bool anyLongTier = displayLong and (showTier1 or showTier2 or showTier3)
    bool anyShortTier = displayShort and (showTier1 or showTier2 or showTier3)

    float longSpineTop = showTier1 ? long1 : showTier2 ? long2 : showTier3 ? long3 : na
    float longSpineBottom = showTier3 ? long3 : showTier2 ? long2 : showTier1 ? long1 : na
    float shortSpineBottom = showTier1 ? short1 : showTier2 ? short2 : showTier3 ? short3 : na
    float shortSpineTop = showTier3 ? short3 : showTier2 ? short2 : showTier1 ? short1 : na

    longSpine := f_spine_line(
         longSpine,
         railReady and anyLongTier,
         railX1, longSpineTop, longSpineBottom,
         color.new(longColor, 62))

    shortSpine := f_spine_line(
         shortSpine,
         railReady and anyShortTier,
         railX1, shortSpineBottom, shortSpineTop,
         color.new(shortColor, 62))

bool markerBarVisible = bar_index >= last_bar_index - eventMarkerLookback

plotshape(
     showReachMarkers and markerBarVisible and longReachEvent ? longEventLevel : na,
     title = "Long core reference reached",
     style = shape.xcross,
     location = location.absolute,
     color = eventColor,
     size = size.tiny,
     text = "L",
     textcolor = color.rgb(15, 23, 42),
     display = display.pane,
     editable = true)

plotshape(
     showReachMarkers and markerBarVisible and shortReachEvent ? shortEventLevel : na,
     title = "Short core reference reached",
     style = shape.xcross,
     location = location.absolute,
     color = eventColor,
     size = size.tiny,
     text = "S",
     textcolor = color.rgb(15, 23, 42),
     display = display.pane,
     editable = true)

// Research outputs remain available in the Data Window without adding status-line text.
plot(activeReference, "Data: Active reference", color = referenceColor, display = display.data_window, editable = false)
plot(atrUsed, "Data: ATR used", color = referenceColor, display = display.data_window, editable = false)
plot(atrPercent, "Data: ATR as reference percent", color = referenceColor, display = display.data_window, editable = false)
plot(long1, "Data: Long tier 1", color = longColor, display = display.data_window, editable = false)
plot(long2, "Data: Long tier 2", color = longColor, display = display.data_window, editable = false)
plot(long3, "Data: Long tier 3", color = longColor, display = display.data_window, editable = false)
plot(short1, "Data: Short tier 1", color = shortColor, display = display.data_window, editable = false)
plot(short2, "Data: Short tier 2", color = shortColor, display = display.data_window, editable = false)
plot(short3, "Data: Short tier 3", color = shortColor, display = display.data_window, editable = false)
plot(longCore, "Data: Long core", color = longColor, display = display.data_window, editable = false)
plot(shortCore, "Data: Short core", color = shortColor, display = display.data_window, editable = false)
plot(longCushionAtr, "Data: Long cushion in ATR", color = longColor, display = display.data_window, editable = false)
plot(shortCushionAtr, "Data: Short cushion in ATR", color = shortColor, display = display.data_window, editable = false)

// ─────────────────────────────────────────────────────────────────────────────
// Right-edge tags
// ─────────────────────────────────────────────────────────────────────────────
var label referenceTag = na
var label longCoreTag = na
var label shortCoreTag = na
var label long1Tag = na
var label long2Tag = na
var label long3Tag = na
var label short1Tag = na
var label short2Tag = na
var label short3Tag = na

if barstate.islast
    label.delete(referenceTag)
    label.delete(longCoreTag)
    label.delete(shortCoreTag)
    label.delete(long1Tag)
    label.delete(long2Tag)
    label.delete(long3Tag)
    label.delete(short1Tag)
    label.delete(short2Tag)
    label.delete(short3Tag)

    int tagBaseX = showCurrentRail ? bar_index + railForward : bar_index
    int tagX = tagBaseX + tagOffset
    color darkText = color.rgb(15, 23, 42)
    bool tagsEnabled = tagMode != TAG_OFF and calculationReady
    bool coreTags = tagMode == TAG_CORE
    bool allTags = tagMode == TAG_ALL

    referenceTag := f_tag(
         tagsEnabled and showReferenceLine,
         tagX, activeReference,
         "REF · " + f_price(activeReference),
         referenceColor, darkText, rightLabelSize)

    longCoreTag := f_tag(
         coreTags and displayLong,
         tagX, longCore,
         "LONG · CORE " + f_mult(coreMultiplier) + " · " + f_price(longCore),
         longColor, darkText, rightLabelSize)

    shortCoreTag := f_tag(
         coreTags and displayShort,
         tagX, shortCore,
         "SHORT · CORE " + f_mult(coreMultiplier) + " · " + f_price(shortCore),
         shortColor, darkText, rightLabelSize)

    long1Tag := f_tag(
         allTags and displayLong and showTier1,
         tagX, long1,
         "L1 · " + f_mult(tier1) + (coreTier == 1 ? " · CORE" : "") + " · " + f_price(long1),
         longTier1Color, darkText, rightLabelSize)

    long2Tag := f_tag(
         allTags and displayLong and showTier2,
         tagX, long2,
         "L2 · " + f_mult(tier2) + (coreTier == 2 ? " · CORE" : "") + " · " + f_price(long2),
         longTier2Color, darkText, rightLabelSize)

    long3Tag := f_tag(
         allTags and displayLong and showTier3,
         tagX, long3,
         "L3 · " + f_mult(tier3) + (coreTier == 3 ? " · CORE" : "") + " · " + f_price(long3),
         longTier3Color, darkText, rightLabelSize)

    short1Tag := f_tag(
         allTags and displayShort and showTier1,
         tagX, short1,
         "S1 · " + f_mult(tier1) + (coreTier == 1 ? " · CORE" : "") + " · " + f_price(short1),
         shortTier1Color, darkText, rightLabelSize)

    short2Tag := f_tag(
         allTags and displayShort and showTier2,
         tagX, short2,
         "S2 · " + f_mult(tier2) + (coreTier == 2 ? " · CORE" : "") + " · " + f_price(short2),
         shortTier2Color, darkText, rightLabelSize)

    short3Tag := f_tag(
         allTags and displayShort and showTier3,
         tagX, short3,
         "S3 · " + f_mult(tier3) + (coreTier == 3 ? " · CORE" : "") + " · " + f_price(short3),
         shortTier3Color, darkText, rightLabelSize)

// ─────────────────────────────────────────────────────────────────────────────
// Readout
// ─────────────────────────────────────────────────────────────────────────────
color panelBackground = color.new(color.rgb(15, 23, 42), 5)
color panelBorder = color.new(color.rgb(148, 163, 184), 52)
color panelText = color.rgb(241, 245, 249)
color neutralCell = color.new(color.rgb(30, 41, 59), 10)
color warningCell = color.new(eventColor, 12)

var table readout = table.new(
     f_position(readoutPosition), 3, 11,
     bgcolor = panelBackground,
     frame_color = panelBorder,
     frame_width = 1,
     border_color = color.new(panelBorder, 20),
     border_width = 1)

if barstate.isfirst
    table.merge_cells(readout, 0, 0, 1, 0)

if barstate.islast
    table.clear(readout, 0, 0, 2, 10)

    if showReadout
        table.cell(
             readout, 0, 0,
             "◈ ATR EXIT GUIDE",
             bgcolor = color.new(referenceColor, 3),
             text_color = color.rgb(15, 23, 42),
             text_halign = text.align_center,
             text_size = f_size(readoutSize),
             text_formatting = text.format_bold)
        table.cell(
             readout, 2, 0,
             "  ",
             bgcolor = color.new(color.rgb(15, 23, 42), 100),
             text_color = color.new(color.rgb(15, 23, 42), 100),
             text_halign = text.align_left,
             text_size = f_size(readoutSize))

        int row = 1

        if readoutLayout == LAYOUT_DETAILED
            string modelText = f_model_short(referenceModel) + (isLockedModel ? " · " + snapshotAtrUpdate : "")
            f_row(readout, row, "⚙ MODEL", modelText, neutralCell, panelText, readoutSize)
            row += 1

        f_row(
             readout, row, "◆ REF",
             f_price(activeReference) + (na(referenceAge) ? "" : " · " + f_bars(referenceAge)),
             color.new(referenceColor, 76), panelText, readoutSize)
        row += 1

        f_row(
             readout, row, "◈ ATR",
             f_price(atrUsed) + " · " + f_percent(atrPercent),
             neutralCell, panelText, readoutSize)
        row += 1

        f_row(
             readout, row, "◎ CORE",
             "Tier " + str.tostring(coreTier) + " · " + f_mult(coreMultiplier),
             neutralCell, panelText, readoutSize)
        row += 1

        if readoutLayout == LAYOUT_DETAILED
            string ratchetStateText =
                 directionMode == DIR_LONG ? (longRatchetActive ? "Long active" : "Long waiting") :
                 directionMode == DIR_SHORT ? (shortRatchetActive ? "Short active" : "Short waiting") :
                 "L " + (longRatchetActive ? "active" : "waiting") + " · S " + (shortRatchetActive ? "active" : "waiting")

            string behaviorText =
                 effectiveBehavior == BEHAVIOR_FIXED ? "Fixed" :
                 effectiveBehavior == BEHAVIOR_RATCHET ? "Immediate · " + ratchetStateText :
                 "Delayed " + f_mult(ratchetActivationAtr) + " · " + ratchetStateText

            f_row(readout, row, "⇄ BEHAVIOR", behaviorText, neutralCell, panelText, readoutSize)
            row += 1

        string longCoreText = displayLong ? f_price(longCore) + " · " + f_decimal(longCushionAtr) + " ATR" : "Off"
        f_row(
             readout, row, "▲ LONG CORE",
             longCoreText,
             displayLong ? color.new(longColor, 76) : neutralCell,
             panelText, readoutSize)
        row += 1

        string shortCoreText = displayShort ? f_price(shortCore) + " · " + f_decimal(shortCushionAtr) + " ATR" : "Off"
        f_row(
             readout, row, "▼ SHORT CORE",
             shortCoreText,
             displayShort ? color.new(shortColor, 76) : neutralCell,
             panelText, readoutSize)
        row += 1

        if readoutLayout == LAYOUT_DETAILED
            string combinedReach =
                 directionMode == DIR_LONG ? longReachState :
                 directionMode == DIR_SHORT ? shortReachState :
                 "L " + longReachState + " · S " + shortReachState

            color combinedBg =
                 longReachState == "Close beyond" or shortReachState == "Close beyond" ? color.new(color.rgb(239, 68, 68), 10) :
                 longReachState == "Wick reached" or shortReachState == "Wick reached" ? warningCell :
                 neutralCell

            f_row(readout, row, "✦ REACH", combinedReach, combinedBg, panelText, readoutSize)
            row += 1

        string statusText =
             isManualModel and not manualAnchorEnabled ? "Enable manual anchor" :
             isManualModel and not manualEligible ? "Waiting for anchor time" :
             not calculationReady ? "ATR warming up" :
             tiersNormalized ? "Tier order normalized" :
             showCurrentRail and showHistoricalPath ? "Rail + recent path" :
             showCurrentRail ? "Current rail" :
             showHistoricalPath ? "Recent path" :
             "Data only"

        color statusBg =
             isManualModel and not manualAnchorEnabled ? warningCell :
             isManualModel and not manualEligible ? neutralCell :
             not calculationReady ? neutralCell :
             tiersNormalized ? warningCell :
             color.new(color.rgb(34, 197, 94), 78)

        f_row(readout, row, "✓ STATUS", statusText, statusBg, panelText, readoutSize)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(
     longReachEvent,
     "Long ATR core reference reached",
     "The selected long-side ATR core reference was reached on {{ticker}} ({{interval}}).")

alertcondition(
     shortReachEvent,
     "Short ATR core reference reached",
     "The selected short-side ATR core reference was reached on {{ticker}} ({{interval}}).")

alertcondition(
     longReachEvent or shortReachEvent,
     "Any ATR core reference reached",
     "At least one displayed ATR core reference was reached on {{ticker}} ({{interval}}).")

alertcondition(
     longRatchetActivationEvent,
     "Long ATR ratchet activated",
     "The long-side delayed ATR ratchet became active on {{ticker}} ({{interval}}).")

alertcondition(
     shortRatchetActivationEvent,
     "Short ATR ratchet activated",
     "The short-side delayed ATR ratchet became active on {{ticker}} ({{interval}}).")

alertcondition(
     eventGate and referenceReset and calculationReady,
     "ATR reference reset",
     "The selected locked ATR reference reset on {{ticker}} ({{interval}}).")
````
