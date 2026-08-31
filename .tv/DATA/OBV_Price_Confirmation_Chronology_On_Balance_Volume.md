<!-- tradingview-pine-id: PUB;b94669ed1f23497dabeaed29be98251b -->
<!-- tradingviewscripts-format: 1 -->
# OBV Price Confirmation Chronology - On Balance Volume

Source: https://www.tradingview.com/script/gLD0ggTQ-OBV-Price-Confirmation-Chronology-On-Balance-Volume/

## Description

OBV Price Confirmation Chronology is a price-volume research indicator that compares the timing of rolling record events in price and classical On-Balance Volume (OBV).

A standard OBV line shows how directionally signed volume has accumulated. This script adds a different analytical layer: when price and OBV establish corresponding upper or lower records, which one occurred first, did both occur on the same bar, or did one remain unmatched beyond the selected tolerance?

The purpose is to help users study whether the available volume series is confirming, leading, lagging, or failing to match new price records.

This is a descriptive context tool. It is not a trading system and does not generate buy or sell instructions, entries, exits, targets, stops, position sizes, probability estimates, or performance claims.

CORE IDEA

The script separately observes two event families:

- High-side records
- Low-side records

A high-side event occurs when price or classical OBV establishes a new upper record relative to its selected rolling lookback.

A low-side event occurs when price or classical OBV establishes a new lower record relative to its selected rolling lookback.

Price and OBV events are then paired within a configurable number of chart bars.

The resulting chronology state describes the order in which the matching records occurred:

- OBV led
- Price led
- Synchronized
- Price only
- OBV only

High-side and low-side states are calculated independently.

"High" and "Low" describe the direction of the rolling record. They are not long or short recommendations.

WHAT MAKES IT DIFFERENT

The classical OBV calculation itself is a standard technical-analysis foundation. The original contribution of this script is the chronology engine built around it.

The script does not simply plot OBV, detect an OBV moving-average crossover, or mark a one-sided OBV breakout.

Its distinguishing features include:

- Symmetrical high-side and low-side record analysis
- Independent price-record and OBV-record detection
- Bar-by-bar measurement of which record occurred first
- Synchronized-event classification when both records occur together
- Pending-event storage within a configurable pairing tolerance
- Unpaired-event classification when the tolerance expires
- Deterministic oldest-first event pairing
- Breakout-sequence compression to reduce repeated record events
- Optional sampled-record mode for more frequent research events
- A normalized OBV-versus-price range-position gap
- Compact historical markers
- Separate latest high-side and low-side labels
- A concise current-state table
- Confirmed-bar event handling by default

This is not a classic pivot-divergence indicator.

It does not wait for confirmed swing pivots, draw divergence lines between historical pivots, or classify regular and hidden divergence. It instead studies the chronology of rolling price and OBV records.

CLASSICAL OBV CALCULATION

Classical OBV is calculated from the selected Direction source.

When the source rises from the previous bar:

- The current available volume is added.

When the source falls from the previous bar:

- The current available volume is subtracted.

When the source is unchanged:

- Zero is added.

Close is the default Direction source.

The chronology engine always uses classical cumulative OBV, regardless of the selected visual display mode.

PRICE RECORDS

The Price record source can use:

- High / Low
- Close

With High / Low selected:

- High-side records are calculated from price highs.
- Low-side records are calculated from price lows.

With Close selected:

- Both upper and lower price records are calculated from closing prices.

A price record must exceed the previous rolling record by the configured Minimum price record extension.

The default extension is one minimum tick. This helps avoid treating insignificant floating-point or feed-level differences as meaningful new price records.

Setting the extension to zero accepts any strictly higher or lower value.

OBV RECORDS

A high-side OBV record occurs when classical OBV exceeds its previous rolling maximum.

A low-side OBV record occurs when classical OBV falls below its previous rolling minimum.

A usable positive volume input is required for a new OBV record event.

EVENT SAMPLING MODES

Breakout sequence start is the default event mode.

This mode groups a sustained run of repeated rolling records into a cleaner event sequence. A new event is allowed only after the selected number of reset bars has separated it from the preceding record run.

This reduces repeated markers during a continuous expansion.

Sampled rolling records is an alternative research mode.

It allows record events to appear more frequently, subject to the selected minimum number of bars between sampled events.

PAIRING LOGIC

High-side and low-side events maintain separate pending states.

When a price record occurs without a matching OBV record, the price event waits for the configured Pair tolerance bars.

When an OBV record occurs without a matching price record, the OBV event waits in the same way.

If the opposite record occurs within the tolerance, the events form a completed pair.

The script gives priority to the oldest valid unmatched event. A new event from the same source does not overwrite an older valid pending event.

The classifications are:

OBV led

The OBV record occurred first and the matching price record occurred later within the tolerance.

Price led

The price record occurred first and the matching OBV record occurred later within the tolerance.

Synchronized

The price and OBV records occurred on the same chart bar when no older opposite-source pending event had priority.

Price only

A price record remained unmatched after the tolerance expired.

OBV only

An OBV record remained unmatched after the tolerance expired.

The tolerance is measured in chart bars, not clock time.

A setting of eight therefore means eight bars on the active chart timeframe.

READING THE +N VALUE

A compact label such as:

OBV +3

means that the matching OBV record occurred three chart bars before the price record.

A compact label such as:

Price +2

means that the matching price record occurred two chart bars before the OBV record.

The number is not:

- Signal strength
- Price distance
- Volume percentage
- Expected return
- Reversal probability
- Continuation probability

It is only the number of chart bars separating the two record events.

VISUAL LANGUAGE

The default visual structure keeps the OBV series as the primary layer.

Default line colors:

- Cyan: displayed OBV series
- Yellow: selected smoothing line

Historical event markers:

- Diamond: completed price-OBV pair
- X: pending event expired without a matching event

Default marker colors:

- Blue: OBV led
- Gold: Price led
- White: Synchronized
- Gold X: Price only
- Violet X: OBV only

Marker position identifies the event side:

- Markers above the displayed OBV line represent high-side events.
- Markers below the displayed OBV line represent low-side events.

The latest high-side state is shown with a green label.

The latest low-side state is shown with a pink label.

Only one latest high-side label and one latest low-side label are maintained. Older event history remains available through the smaller markers.

All primary colors, line widths, label sizes, table settings, and visual layers can be customized.

STATUS TABLE

The default Compact table contains four rows:

High

Shows the latest completed or expired high-side chronology state.

Low

Shows the latest completed or expired low-side chronology state.

Pending

Shows whether a price or OBV record is currently waiting for a matching event.

A pending value such as:

H Price 3/8

means that a high-side price record has waited three bars out of an eight-bar tolerance.

Gap

Shows which series currently occupies the stronger relative position inside its own recent range.

The table can be moved to any corner of the indicator pane.

A Detailed table mode is also available for users who want additional state and environment information.

RANGE-POSITION GAP

Price and classical OBV are independently normalized to positions from 0 to 100 inside their respective recent ranges.

The calculation is:

OBV range position - Price range position

A positive result means OBV is positioned higher inside its own recent range than price is positioned inside its price range.

A negative result means price is positioned higher inside its own recent range than OBV is positioned inside its OBV range.

In Compact mode, the table displays the stronger side and the absolute difference.

For example:

OBV 22.5

means OBV is 22.5 normalized range-position points above price.

Price 31.0

means price is 31.0 normalized range-position points above OBV.

The Gap value is not a price percentage, volume percentage, probability, forecast, or signal-strength score.

An optional subtle background tint can highlight larger positive or negative gaps. It is disabled by default to preserve visual clarity.

DISPLAY MODES

Classic OBV

Displays classical cumulative OBV.

This is the default mode because it matches the series used by the chronology engine.

Rolling zero-base OBV

Displays the current classical OBV value minus its value a selected number of bars ago.

This can make recent movement easier to compare visually, but it does not change chronology calculations.

Directional balance %

Measures net directionally signed volume relative to gross directionally signed volume over the selected lookback and displays the result on a scale from -100 to +100.

This mode changes only the visible pane series.

Chronology events always remain based on classical cumulative OBV.

SMOOTHING

An optional smoothing line is enabled by default.

Available methods:

- EMA
- SMA
- RMA
- WMA

The smoothing line is a visual reference only. It does not change price-record detection, OBV-record detection, pairing, pending events, expiration, or alert conditions.

ALERTS

The script provides separate alert conditions for:

- High-side OBV led
- High-side Price led
- High-side Synchronized
- Low-side OBV led
- Low-side Price led
- Low-side Synchronized
- Unpaired chronology expiration

The unpaired alert is disabled by default.

All alerts are restricted to confirmed bar closes.

Alert events describe completed chronology conditions only. They are not trade instructions.

LIVE AND HISTORICAL BEHAVIOR

Evaluate confirmed bars only is enabled by default.

With this setting enabled:

- Persistent chronology states update only when the current chart bar closes.
- Pending records do not pair or expire during an unfinished bar.
- Historical and realtime event handling remain aligned around confirmed chart bars.

The displayed OBV line, smoothing line, and range-position gap can still update while the current bar is forming because their underlying price and volume values are live.

If confirmed-bar evaluation is disabled, chronology events become a provisional intrabar preview. Those states can change before the bar closes.

Alerts remain confirmed-bar events even when intrabar preview is enabled.

The script uses the current chart timeframe only.

It does not request higher-timeframe or lower-timeframe data, does not use lookahead, and does not use future bars.

An unpaired X marker appears on the bar where the expiration becomes knowable, not retrospectively on the original pending-event bar.

NON-STANDARD CHARTS

Chronology-event processing is paused by default on non-standard chart types, including synthetic price constructions such as:

- Heikin Ashi
- Renko
- Kagi
- Point & Figure
- Range
- Line Break

Standard candlestick or bar charts are recommended.

INPUTS AND CUSTOMIZATION

Users can adjust:

- OBV Direction source
- Visible display mode
- Rolling zero-base length
- Directional-balance length
- Smoothing method and length
- Price record source
- Record lookback
- Record event mode
- Sequence reset bars
- Sampled-event spacing
- Pair tolerance
- Minimum price-record extension
- Confirmed-bar behavior
- Non-standard-chart behavior
- Historical markers
- Latest labels
- Label style and size
- Table position
- Compact or Detailed table density
- Table text size and formatting
- OBV and smoothing line widths
- Range-position lookback
- Gap threshold and optional tint
- Primary colors
- Alert availability

Visual settings do not change the underlying chronology calculations.

SUGGESTED WORKFLOW

1. Use a standard candlestick chart with a consistent and meaningful volume series.

2. Begin with Classic OBV so the displayed series matches the chronology basis.

3. Review the High and Low rows separately. They represent different record directions and can show different chronology states at the same time.

4. Use the historical diamonds to locate completed price-OBV pairs.

5. Use the historical X markers to locate events that expired without confirmation.

6. Read the +N value only as a bar-count lead or lag.

7. Review Pending to see whether a price or OBV record is still waiting for a counterpart.

8. Use Gap as secondary range-position context, not as a trade trigger.

9. Adjust Record lookback, Sequence reset bars, and Pair tolerance for the timeframe and research horizon.

10. Combine the observations with independent price structure, trend, volatility, liquidity, and risk analysis.

LIMITATIONS

OBV is derived from the volume series supplied for the selected symbol and data provider.

Depending on the market, the available series may represent:

- Exchange trade volume
- Exchange-specific crypto volume
- Broker-specific volume
- Tick volume
- Limited volume
- No usable volume

The interpretation and quality of all OBV-based calculations therefore depend on the symbol and feed.

If no usable volume is available, the OBV series may remain flat or the chronology may not provide meaningful events.

The absolute numerical level of cumulative OBV is not directly comparable between unrelated symbols.

Large isolated volume events can affect the cumulative OBV path for an extended period.

Corporate actions, session changes, market gaps, futures contract rolls, and provider-specific data changes can affect price and volume records.

Record events depend on the selected lookback and price source.

Pairing results depend on the selected tolerance.

Lower timeframes can produce more frequent and noisier events.

Higher timeframes generally produce fewer events and require more elapsed time for pending states to complete or expire.

Price-only and OBV-only states do not predict reversal or continuation.

OBV leadership does not guarantee that price will follow.

Price leadership does not guarantee that OBV will confirm.

Synchronized records do not guarantee trend persistence.

Range-position Gap does not represent a trading edge or future probability.

Default parameters are research starting points and are not optimized for any symbol, timeframe, market, or trading method.

This indicator should be used as one descriptive price-volume perspective within a broader analytical process.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG Group

//@version=6
indicator(
     title = "OBV Price Confirmation Chronology - On Balance Volume",
     shorttitle = "OBV Price Confirmation Chronology",
     overlay = false,
     format = format.volume,
     precision = 2,
     max_bars_back = 5000,
     explicit_plot_zorder = true,
     max_lines_count = 50,
     max_labels_count = 20
)

// ============================================================================
// PURPOSE
// ============================================================================
// Mandatory-fix release 3.4.
//
// The previous revisions still carried too much on-chart narration. This
// version reduces visual noise and makes the reading sequence obvious:
// 1) OBV line and smoothing line are the primary layer.
// 2) Completed chronology events are shown only with compact markers.
// 3) Unpaired events are shown only with compact X markers.
// 4) Only one latest high-side label and one latest low-side label remain.
// 5) A slightly larger, bold four-row table improves legibility without dominating the pane.
// 6) Confirmed-bar state commits, safe volume handling, explicit warmup gates,
//    deterministic oldest-first pairing, and strict pending expiration improve
//    live-chart consistency.
// 7) Persistent labels are updated in place to reduce drawing-object churn.
//
// High-side events are always plotted above the line.
// Low-side events are always plotted below the line.
// Marker COLOR answers “who led?” while marker POSITION answers “which side?”
//
// This is a descriptive research indicator. It does not issue buy/sell signals.
// Default chronology state and all alerts are confirmed at bar close. Optional
// intrabar evaluation is explicitly provisional and can change before close.

// ============================================================================
// INPUT GROUPS
// ============================================================================
string GROUP_CORE       = "1. OBV Core"
string GROUP_CHRONOLOGY = "2. Record Chronology"
string GROUP_DISPLAY    = "3. Display"
string GROUP_CONTEXT    = "4. Context"
string GROUP_COLORS     = "5. Colors"
string GROUP_ALERTS     = "6. Alerts"

// ============================================================================
// INPUTS: CORE
// ============================================================================
float directionSource = input.source(
     close,
     "Direction source",
     tooltip = "Close reproduces classical OBV behavior. A rising source adds volume, a falling source subtracts volume, and an unchanged source adds zero.",
     group = GROUP_CORE,
     display = display.none
)

string displayMode = input.string(
     "Classic OBV",
     "Display mode",
     options = ["Classic OBV", "Rolling zero-base OBV", "Directional balance %"],
     tooltip = "Classic OBV is the default so the visible series matches the chronology basis. Rolling zero-base OBV and Directional balance % are optional display transforms only; chronology events always use classical cumulative OBV.",
     group = GROUP_CORE,
     display = display.none
)

int rollingDisplayLength = input.int(
     120,
     "Rolling zero-base length",
     minval = 2,
     maxval = 3000,
     tooltip = "Used when Display mode is Rolling zero-base OBV.",
     group = GROUP_CORE,
     display = display.none,
     active = displayMode == "Rolling zero-base OBV"
)

int directionalBalanceLength = input.int(
     55,
     "Directional balance length",
     minval = 2,
     maxval = 1000,
     tooltip = "Used when Display mode is Directional balance %.",
     group = GROUP_CORE,
     display = display.none,
     active = displayMode == "Directional balance %"
)

bool showSmooth = input.bool(
     true,
     "Show smoothing line",
     group = GROUP_CORE,
     display = display.none
)

string smoothType = input.string(
     "EMA",
     "Smoothing type",
     options = ["EMA", "SMA", "RMA", "WMA"],
     group = GROUP_CORE,
     display = display.none,
     active = showSmooth
)

int smoothLength = input.int(
     9,
     "Smoothing length",
     minval = 1,
     maxval = 500,
     group = GROUP_CORE,
     display = display.none,
     active = showSmooth
)

// ============================================================================
// INPUTS: CHRONOLOGY
// ============================================================================
string recordSourceMode = input.string(
     "High / Low",
     "Price record source",
     options = ["High / Low", "Close"],
     tooltip = "High / Low uses highs for upper records and lows for lower records. Close uses close-only records for both directions.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

string recordEventMode = input.string(
     "Breakout sequence start",
     "Record event mode",
     options = ["Breakout sequence start", "Sampled rolling records"],
     tooltip = "Breakout sequence start collapses consecutive record bars into one cleaner event. Sampled rolling records allows more frequent events for research.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

int recordLength = input.int(
     34,
     "Record lookback",
     minval = 2,
     maxval = 1000,
     group = GROUP_CHRONOLOGY,
     display = display.none
)

int sequenceResetBars = input.int(
     3,
     "Sequence reset bars",
     minval = 1,
     maxval = 50,
     tooltip = "Only used by Breakout sequence start. A new event is allowed after this many bars pass without another record of the same type.",
     group = GROUP_CHRONOLOGY,
     display = display.none,
     active = recordEventMode == "Breakout sequence start"
)

int sampledGapBars = input.int(
     5,
     "Minimum bars between sampled events",
     minval = 1,
     maxval = 100,
     tooltip = "Only used by Sampled rolling records.",
     group = GROUP_CHRONOLOGY,
     display = display.none,
     active = recordEventMode == "Sampled rolling records"
)

int pairToleranceBars = input.int(
     8,
     "Pair tolerance bars",
     minval = 0,
     maxval = 100,
     tooltip = "Maximum number of bars allowed between matching price and OBV record events.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

int minimumPriceRecordTicks = input.int(
     1,
     "Minimum price record extension (ticks)",
     minval = 0,
     maxval = 100,
     tooltip = "Requires a new price record to extend the prior record by at least this many minimum ticks. One tick is the robust default. Zero accepts any strictly higher or lower value.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

bool evaluateConfirmedBarsOnly = input.bool(
     true,
     "Evaluate confirmed bars only",
     tooltip = "Recommended. When enabled, all persistent chronology state changes occur only after the bar closes. Disabling it enables a provisional intrabar preview; alerts still wait for bar close.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

bool suppressOnNonStandardChart = input.bool(
     true,
     "Pause event logic on non-standard charts",
     tooltip = "Prevents chronology events on chart types such as Heikin Ashi, Renko, Kagi, Point & Figure, Range, and Line Break.",
     group = GROUP_CHRONOLOGY,
     display = display.none
)

// ============================================================================
// INPUTS: DISPLAY
// ============================================================================
bool showHistoricalMarkers = input.bool(
     true,
     "Show historical event markers",
     tooltip = "Completed pairs are shown with small diamonds. Unpaired expirations are shown with small X markers.",
     group = GROUP_DISPLAY,
     display = display.none
)

bool showLatestHighLabel = input.bool(
     true,
     "Show latest high-side label",
     group = GROUP_DISPLAY,
     display = display.none
)

bool showLatestLowLabel = input.bool(
     true,
     "Show latest low-side label",
     group = GROUP_DISPLAY,
     display = display.none
)

string latestLabelStyle = input.string(
     "Compact",
     "Latest label text style",
     options = ["Compact", "Detailed"],
     group = GROUP_DISPLAY,
     display = display.none
)

string latestLabelSizeInput = input.string(
     "Normal",
     "Latest label size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_DISPLAY,
     display = display.none
)

bool showStatusTable = input.bool(
     true,
     "Show status table",
     group = GROUP_DISPLAY,
     display = display.none
)

string statusTablePositionInput = input.string(
     "Top Right",
     "Status table position",
     options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"],
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable
)

string statusTableDensity = input.string(
     "Compact",
     "Status table density",
     options = ["Compact", "Detailed"],
     tooltip = "Compact uses four short rows and is the default. Detailed restores the longer research readout.",
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable
)

string statusTableTextSizeInput = input.string(
     "Small",
     "Status table text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable
)

bool boldStatusTableText = input.bool(
     true,
     "Bold status table text",
     tooltip = "Uses Pine v6 text formatting to strengthen readability without adding rows or changing the compact table content.",
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable
)

bool showTableLegendRow = input.bool(
     false,
     "Show legend row in detailed table",
     tooltip = "Available only in Detailed density. Compact density omits the legend to preserve space.",
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable and statusTableDensity == "Detailed"
)

int statusTableTransparency = input.int(
     10,
     "Status table transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_DISPLAY,
     display = display.none,
     active = showStatusTable
)

int lineWidthObv = input.int(
     3,
     "OBV line width",
     minval = 1,
     maxval = 6,
     group = GROUP_DISPLAY,
     display = display.none
)

int lineWidthSmooth = input.int(
     2,
     "Smoothing line width",
     minval = 1,
     maxval = 6,
     group = GROUP_DISPLAY,
     display = display.none,
     active = showSmooth
)

// ============================================================================
// INPUTS: CONTEXT
// ============================================================================
int positionLookback = input.int(
     55,
     "Range-position lookback",
     minval = 5,
     maxval = 1000,
     tooltip = "Used to compare where price and OBV sit inside their own recent ranges.",
     group = GROUP_CONTEXT,
     display = display.none
)

float positionGapHighlightThreshold = input.float(
     18.0,
     "Range-position gap threshold",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     tooltip = "A positive gap means OBV is stronger inside its own range than price is inside its range. A negative gap means the opposite.",
     group = GROUP_CONTEXT,
     display = display.none
)

bool showGapTint = input.bool(
     false,
     "Show subtle gap tint",
     tooltip = "Disabled by default for cleaner visuals. When enabled, the pane background is lightly tinted only when the range-position gap is materially large.",
     group = GROUP_CONTEXT,
     display = display.none
)

// ============================================================================
// INPUTS: COLORS
// ============================================================================
color obvLineColor = input.color(
     color.rgb(42, 224, 255),
     "OBV line",
     group = GROUP_COLORS,
     display = display.none
)

color smoothLineColor = input.color(
     color.rgb(255, 211, 59),
     "Smoothing line",
     group = GROUP_COLORS,
     display = display.none,
     active = showSmooth
)

color highSideLabelColor = input.color(
     color.rgb(25, 227, 133),
     "High-side latest label",
     group = GROUP_COLORS,
     display = display.none
)

color lowSideLabelColor = input.color(
     color.rgb(255, 67, 176),
     "Low-side latest label",
     group = GROUP_COLORS,
     display = display.none
)

color obvLedMarkerColor = input.color(
     color.rgb(70, 115, 255),
     "OBV-led marker",
     group = GROUP_COLORS,
     display = display.none
)

color priceLedMarkerColor = input.color(
     color.rgb(255, 187, 0),
     "Price-led marker",
     group = GROUP_COLORS,
     display = display.none
)

color synchronizedMarkerColor = input.color(
     color.rgb(255, 255, 255),
     "Synchronized marker",
     group = GROUP_COLORS,
     display = display.none
)

color unpairedPriceMarkerColor = input.color(
     color.rgb(255, 187, 0),
     "Unpaired price marker",
     group = GROUP_COLORS,
     display = display.none
)

color unpairedObvMarkerColor = input.color(
     color.rgb(164, 96, 255),
     "Unpaired OBV marker",
     group = GROUP_COLORS,
     display = display.none
)

color statusHeaderColor = input.color(
     color.rgb(118, 81, 255),
     "Status table header",
     group = GROUP_COLORS,
     display = display.none,
     active = showStatusTable
)

color statusBodyColor = input.color(
     color.rgb(41, 49, 69),
     "Status table body",
     group = GROUP_COLORS,
     display = display.none,
     active = showStatusTable
)

color statusBorderColor = input.color(
     color.rgb(137, 148, 177),
     "Status table border",
     group = GROUP_COLORS,
     display = display.none,
     active = showStatusTable
)

// ============================================================================
// INPUTS: ALERTS
// ============================================================================
bool enableHighObvLedAlert = input.bool(true, "Alert: high-side OBV led", group = GROUP_ALERTS, display = display.none)
bool enableHighPriceLedAlert = input.bool(true, "Alert: high-side price led", group = GROUP_ALERTS, display = display.none)
bool enableHighSyncAlert     = input.bool(true, "Alert: high-side synchronized", group = GROUP_ALERTS, display = display.none)
bool enableLowObvLedAlert    = input.bool(true, "Alert: low-side OBV led", group = GROUP_ALERTS, display = display.none)
bool enableLowPriceLedAlert  = input.bool(true, "Alert: low-side price led", group = GROUP_ALERTS, display = display.none)
bool enableLowSyncAlert      = input.bool(true, "Alert: low-side synchronized", group = GROUP_ALERTS, display = display.none)
bool enableUnpairedAlert     = input.bool(false, "Alert: unpaired expirations", group = GROUP_ALERTS, display = display.none)

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================
f_smooth(series float src, simple string maType, simple int length) =>
    length <= 1 ? src :
         maType == "EMA" ? ta.ema(src, length) :
         maType == "SMA" ? ta.sma(src, length) :
         maType == "RMA" ? ta.rma(src, length) :
         ta.wma(src, length)

f_compact_leader_text(string leaderCode, int leadBars) =>
    leaderCode == "OBV"   ? "OBV +" + str.tostring(leadBars) :
     leaderCode == "Price" ? "Price +" + str.tostring(leadBars) :
     leaderCode == "Sync"  ? "Sync" :
     leaderCode == "PriceOnly" ? "Price only" :
     leaderCode == "OBVOnly"   ? "OBV only" :
     "None"

f_detailed_leader_text(string sideName, string leaderCode, int leadBars) =>
    leaderCode == "OBV" ? sideName + " side\nOBV led by " + str.tostring(leadBars) + " bar" + (leadBars == 1 ? "" : "s") :
     leaderCode == "Price" ? sideName + " side\nPrice led by " + str.tostring(leadBars) + " bar" + (leadBars == 1 ? "" : "s") :
     leaderCode == "Sync" ? sideName + " side\nSynchronized" :
     leaderCode == "PriceOnly" ? sideName + " side\nPrice only" :
     leaderCode == "OBVOnly" ? sideName + " side\nOBV only" :
     sideName + " side\nNone"

f_latest_label_text(string sideName, string leaderCode, int leadBars, string styleName) =>
    styleName == "Detailed" ? f_detailed_leader_text(sideName, leaderCode, leadBars) : sideName + "\n" + f_compact_leader_text(leaderCode, leadBars)

f_status_phrase(string leaderCode, int leadBars) =>
    leaderCode == "OBV" ? "OBV led by " + str.tostring(leadBars) + " bar" + (leadBars == 1 ? "" : "s") :
     leaderCode == "Price" ? "Price led by " + str.tostring(leadBars) + " bar" + (leadBars == 1 ? "" : "s") :
     leaderCode == "Sync" ? "Synchronized" :
     leaderCode == "PriceOnly" ? "Price only" :
     leaderCode == "OBVOnly" ? "OBV only" :
     "None"

f_table_position(string positionInput) =>
    positionInput == "Top Right" ? position.top_right :
     positionInput == "Bottom Right" ? position.bottom_right :
     positionInput == "Top Left" ? position.top_left :
     position.bottom_left

f_label_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     size.normal

f_table_text_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     size.normal

f_range_position(series float src, simple int lookback) =>
    float lo = ta.lowest(src, lookback)
    float hi = ta.highest(src, lookback)
    float span = hi - lo
    float rawPosition = not na(src) and not na(lo) and not na(hi) and span > 0.0 ? 100.0 * (src - lo) / span : 50.0
    math.max(0.0, math.min(100.0, rawPosition))

// ============================================================================
// DATA VALIDITY AND LIVE-STATE GATING
// ============================================================================
float safeVolume = na(volume) ? 0.0 : math.max(volume, 0.0)
var float cumulativeObservedVolume = 0.0
cumulativeObservedVolume += safeVolume

bool currentBarVolumeAvailable = not na(volume) and volume >= 0.0
bool directionSourceAvailable = not na(directionSource) and not na(directionSource[1])
bool volumeReady = cumulativeObservedVolume > 0.0
bool chartAllowed = not suppressOnNonStandardChart or chart.is_standard
bool barTimingAllowed = not evaluateConfirmedBarsOnly or barstate.isconfirmed
int stateDisplayBarIndex = evaluateConfirmedBarsOnly and not barstate.isconfirmed ? math.max(bar_index - 1, 0) : bar_index
bool recordWindowReady = bar_index >= recordLength
bool contextWindowReady = bar_index >= positionLookback - 1

// All persistent chronology mutations share one gate. With the default
// confirmed-bar policy, pending states cannot pair or expire on an unfinished
// realtime bar. The warmup gate prevents partial record windows from emitting
// early-dataset events.
bool stateCycleEnabled = volumeReady and chartAllowed and barTimingAllowed and recordWindowReady
bool recordEvaluationEnabled = stateCycleEnabled and currentBarVolumeAvailable and directionSourceAvailable

// ============================================================================
// CLASSICAL OBV WITH SAFE VOLUME HANDLING
// ============================================================================
float sourceDelta = directionSourceAvailable ? directionSource - directionSource[1] : 0.0
float signedVolume = sourceDelta > 0.0 ? safeVolume : sourceDelta < 0.0 ? -safeVolume : 0.0
float classicalObv = ta.cum(signedVolume)

// ============================================================================
// DISPLAY SERIES
// ============================================================================
float rollingBase = nz(classicalObv[rollingDisplayLength], 0.0)
float rollingZeroBaseObv = classicalObv - rollingBase
float grossDirectedVolume = nz(math.sum(math.abs(signedVolume), directionalBalanceLength), 0.0)
float netDirectedVolume = nz(math.sum(signedVolume, directionalBalanceLength), 0.0)
float directionalBalanceRaw = grossDirectedVolume > 0.0 ? 100.0 * netDirectedVolume / grossDirectedVolume : 0.0
float directionalBalance = math.max(-100.0, math.min(100.0, directionalBalanceRaw))

float displaySeries =
     displayMode == "Classic OBV" ? classicalObv :
     displayMode == "Directional balance %" ? directionalBalance :
     rollingZeroBaseObv

float smoothSeries = showSmooth ? f_smooth(displaySeries, smoothType, smoothLength) : na

// ============================================================================
// RANGE-POSITION CONTEXT
// ============================================================================
float priceBasisForContext = close
bool contextReady = volumeReady and contextWindowReady

// History-dependent range functions must execute on every bar. The readiness
// gate is applied only to their exposed values, not to the function calls.
float priceRangePositionRaw = f_range_position(priceBasisForContext, positionLookback)
float obvRangePositionRaw = f_range_position(classicalObv, positionLookback)
float priceRangePosition = contextReady ? priceRangePositionRaw : 50.0
float obvRangePosition = contextReady ? obvRangePositionRaw : 50.0
float rangePositionGap = contextReady ? obvRangePosition - priceRangePosition : 0.0
bool gapPositive = contextReady and rangePositionGap >= positionGapHighlightThreshold
bool gapNegative = contextReady and rangePositionGap <= -positionGapHighlightThreshold

bgcolor(showGapTint and gapPositive ? color.new(obvLedMarkerColor, 92) : na)
bgcolor(showGapTint and gapNegative ? color.new(priceLedMarkerColor, 92) : na)

// ============================================================================
// RECORD DETECTION
// ============================================================================
float priceHighProbe = recordSourceMode == "Close" ? close : high
float priceLowProbe  = recordSourceMode == "Close" ? close : low

float priorHighestPrice = ta.highest(priceHighProbe[1], recordLength)
float priorLowestPrice  = ta.lowest(priceLowProbe[1], recordLength)
float priorHighestObv   = ta.highest(classicalObv[1], recordLength)
float priorLowestObv    = ta.lowest(classicalObv[1], recordLength)

float priceRecordStep = syminfo.mintick * minimumPriceRecordTicks
bool priceHighExtended = minimumPriceRecordTicks == 0 ? priceHighProbe > priorHighestPrice : priceHighProbe >= priorHighestPrice + priceRecordStep
bool priceLowExtended = minimumPriceRecordTicks == 0 ? priceLowProbe < priorLowestPrice : priceLowProbe <= priorLowestPrice - priceRecordStep

bool priceHighRecordRaw = recordEvaluationEnabled and not na(priorHighestPrice) and priceHighExtended
bool priceLowRecordRaw  = recordEvaluationEnabled and not na(priorLowestPrice) and priceLowExtended
bool obvHighRecordRaw   = recordEvaluationEnabled and safeVolume > 0.0 and not na(priorHighestObv) and classicalObv > priorHighestObv
bool obvLowRecordRaw    = recordEvaluationEnabled and safeVolume > 0.0 and not na(priorLowestObv) and classicalObv < priorLowestObv

var int lastTruePriceHighBar = na
var int lastTruePriceLowBar  = na
var int lastTrueObvHighBar   = na
var int lastTrueObvLowBar    = na

var int lastEventPriceHighBar = na
var int lastEventPriceLowBar  = na
var int lastEventObvHighBar   = na
var int lastEventObvLowBar    = na

bool priceHighEvent = false
bool priceLowEvent  = false
bool obvHighEvent   = false
bool obvLowEvent    = false

if priceHighRecordRaw
    if recordEventMode == "Breakout sequence start"
        if na(lastTruePriceHighBar) or bar_index - lastTruePriceHighBar > sequenceResetBars
            priceHighEvent := true
            lastEventPriceHighBar := bar_index
        lastTruePriceHighBar := bar_index
    else
        if na(lastEventPriceHighBar) or bar_index - lastEventPriceHighBar >= sampledGapBars
            priceHighEvent := true
            lastEventPriceHighBar := bar_index

if priceLowRecordRaw
    if recordEventMode == "Breakout sequence start"
        if na(lastTruePriceLowBar) or bar_index - lastTruePriceLowBar > sequenceResetBars
            priceLowEvent := true
            lastEventPriceLowBar := bar_index
        lastTruePriceLowBar := bar_index
    else
        if na(lastEventPriceLowBar) or bar_index - lastEventPriceLowBar >= sampledGapBars
            priceLowEvent := true
            lastEventPriceLowBar := bar_index

if obvHighRecordRaw
    if recordEventMode == "Breakout sequence start"
        if na(lastTrueObvHighBar) or bar_index - lastTrueObvHighBar > sequenceResetBars
            obvHighEvent := true
            lastEventObvHighBar := bar_index
        lastTrueObvHighBar := bar_index
    else
        if na(lastEventObvHighBar) or bar_index - lastEventObvHighBar >= sampledGapBars
            obvHighEvent := true
            lastEventObvHighBar := bar_index

if obvLowRecordRaw
    if recordEventMode == "Breakout sequence start"
        if na(lastTrueObvLowBar) or bar_index - lastTrueObvLowBar > sequenceResetBars
            obvLowEvent := true
            lastEventObvLowBar := bar_index
        lastTrueObvLowBar := bar_index
    else
        if na(lastEventObvLowBar) or bar_index - lastEventObvLowBar >= sampledGapBars
            obvLowEvent := true
            lastEventObvLowBar := bar_index

// ============================================================================
// VISUAL OFFSETS
// ============================================================================
float paneHigh = ta.highest(displaySeries, 200)
float paneLow = ta.lowest(displaySeries, 200)
float rawPaneSpan = paneHigh - paneLow
float fallbackPaneSpan = displayMode == "Directional balance %" ? 10.0 : math.max(math.abs(nz(displaySeries, 0.0)) * 0.10, 1.0)
float paneSpan = not na(rawPaneSpan) and rawPaneSpan > 0.0 ? rawPaneSpan : fallbackPaneSpan
float markerOffset = paneSpan * 0.05
float labelOffset = paneSpan * 0.12
float highMarkerY = displaySeries + markerOffset
float lowMarkerY = displaySeries - markerOffset
float highLabelY = displaySeries + labelOffset
float lowLabelY = displaySeries - labelOffset

// ============================================================================
// PENDING STATE STORAGE
// ============================================================================
// One oldest unmatched price event or OBV event can be pending on each side.
// New same-source events never overwrite an older valid pending event.
var int pendingPriceHighBar = na
var int pendingObvHighBar = na
var int pendingPriceLowBar = na
var int pendingObvLowBar = na

// ============================================================================
// EVENT OUTPUTS FOR THIS BAR
// ============================================================================
bool eventHighObvLed = false
bool eventHighPriceLed = false
bool eventHighSync = false
bool eventLowObvLed = false
bool eventLowPriceLed = false
bool eventLowSync = false

bool eventHighPriceOnly = false
bool eventHighObvOnly = false
bool eventLowPriceOnly = false
bool eventLowObvOnly = false

float eventHighPairY = na
float eventLowPairY = na
float eventHighUnpairedY = na
float eventLowUnpairedY = na

int eventHighLeadBars = na
int eventLowLeadBars = na

// ============================================================================
// HIGH-SIDE CHRONOLOGY — DETERMINISTIC OLDEST-FIRST MATCHING
// ============================================================================
if stateCycleEnabled
    // Expire stale pending records before ingesting new events. This prevents a
    // pending event from pairing one bar beyond the selected tolerance.
    if not na(pendingPriceHighBar) and bar_index - pendingPriceHighBar > pairToleranceBars
        eventHighPriceOnly := true
        eventHighUnpairedY := highMarkerY
        pendingPriceHighBar := na

    if not na(pendingObvHighBar) and bar_index - pendingObvHighBar > pairToleranceBars
        eventHighObvOnly := true
        eventHighUnpairedY := highMarkerY
        pendingObvHighBar := na

    bool highPriceConsumed = false
    bool highObvConsumed = false

    // Existing opposite-source pending events take priority. When both current
    // sources fire, the unused event remains pending instead of being discarded.
    if priceHighEvent and not na(pendingObvHighBar)
        eventHighLeadBars := bar_index - pendingObvHighBar
        eventHighObvLed := true
        eventHighPairY := highMarkerY
        pendingObvHighBar := na
        highPriceConsumed := true
    else if obvHighEvent and not na(pendingPriceHighBar)
        eventHighLeadBars := bar_index - pendingPriceHighBar
        eventHighPriceLed := true
        eventHighPairY := highMarkerY
        pendingPriceHighBar := na
        highObvConsumed := true
    else if priceHighEvent and obvHighEvent
        eventHighLeadBars := 0
        eventHighSync := true
        eventHighPairY := highMarkerY
        highPriceConsumed := true
        highObvConsumed := true

    if priceHighEvent and not highPriceConsumed and na(pendingPriceHighBar)
        pendingPriceHighBar := bar_index

    if obvHighEvent and not highObvConsumed and na(pendingObvHighBar)
        pendingObvHighBar := bar_index

// ============================================================================
// LOW-SIDE CHRONOLOGY — DETERMINISTIC OLDEST-FIRST MATCHING
// ============================================================================
if stateCycleEnabled
    if not na(pendingPriceLowBar) and bar_index - pendingPriceLowBar > pairToleranceBars
        eventLowPriceOnly := true
        eventLowUnpairedY := lowMarkerY
        pendingPriceLowBar := na

    if not na(pendingObvLowBar) and bar_index - pendingObvLowBar > pairToleranceBars
        eventLowObvOnly := true
        eventLowUnpairedY := lowMarkerY
        pendingObvLowBar := na

    bool lowPriceConsumed = false
    bool lowObvConsumed = false

    if priceLowEvent and not na(pendingObvLowBar)
        eventLowLeadBars := bar_index - pendingObvLowBar
        eventLowObvLed := true
        eventLowPairY := lowMarkerY
        pendingObvLowBar := na
        lowPriceConsumed := true
    else if obvLowEvent and not na(pendingPriceLowBar)
        eventLowLeadBars := bar_index - pendingPriceLowBar
        eventLowPriceLed := true
        eventLowPairY := lowMarkerY
        pendingPriceLowBar := na
        lowObvConsumed := true
    else if priceLowEvent and obvLowEvent
        eventLowLeadBars := 0
        eventLowSync := true
        eventLowPairY := lowMarkerY
        lowPriceConsumed := true
        lowObvConsumed := true

    if priceLowEvent and not lowPriceConsumed and na(pendingPriceLowBar)
        pendingPriceLowBar := bar_index

    if obvLowEvent and not lowObvConsumed and na(pendingObvLowBar)
        pendingObvLowBar := bar_index

// ============================================================================
// LATEST EVENT SUMMARIES
// ============================================================================
var string latestHighLeaderCode = "None"
var int latestHighLeadBars = na
var string latestLowLeaderCode = "None"
var int latestLowLeadBars = na

// A completed pair takes precedence if an older pending expiration occurs on
// the same bar as a new completed chronology event.
if eventHighSync
    latestHighLeaderCode := "Sync"
    latestHighLeadBars := 0
else if eventHighObvLed
    latestHighLeaderCode := "OBV"
    latestHighLeadBars := eventHighLeadBars
else if eventHighPriceLed
    latestHighLeaderCode := "Price"
    latestHighLeadBars := eventHighLeadBars
else if eventHighPriceOnly
    latestHighLeaderCode := "PriceOnly"
    latestHighLeadBars := na
else if eventHighObvOnly
    latestHighLeaderCode := "OBVOnly"
    latestHighLeadBars := na

if eventLowSync
    latestLowLeaderCode := "Sync"
    latestLowLeadBars := 0
else if eventLowObvLed
    latestLowLeaderCode := "OBV"
    latestLowLeadBars := eventLowLeadBars
else if eventLowPriceLed
    latestLowLeaderCode := "Price"
    latestLowLeadBars := eventLowLeadBars
else if eventLowPriceOnly
    latestLowLeaderCode := "PriceOnly"
    latestLowLeadBars := na
else if eventLowObvOnly
    latestLowLeaderCode := "OBVOnly"
    latestLowLeadBars := na

// ============================================================================
// LATEST LABELS
// ============================================================================
var label latestHighLabel = na
var label latestLowLabel = na
latestLabelSize = f_label_size(latestLabelSizeInput)

bool anyHighStatusEvent = eventHighObvLed or eventHighPriceLed or eventHighSync or eventHighPriceOnly or eventHighObvOnly
bool anyLowStatusEvent = eventLowObvLed or eventLowPriceLed or eventLowSync or eventLowPriceOnly or eventLowObvOnly

if anyHighStatusEvent and showLatestHighLabel
    string highText = f_latest_label_text("High", latestHighLeaderCode, nz(latestHighLeadBars, 0), latestLabelStyle)
    if na(latestHighLabel)
        latestHighLabel := label.new(
             x = bar_index,
             y = highLabelY,
             text = highText,
             style = label.style_label_down,
             color = highSideLabelColor,
             textcolor = color.white,
             size = latestLabelSize,
             text_formatting = text.format_bold,
             tooltip = "Latest high-side chronology state"
        )
    else
        label.set_xy(latestHighLabel, bar_index, highLabelY)
        label.set_text(latestHighLabel, highText)
        label.set_color(latestHighLabel, highSideLabelColor)
        label.set_textcolor(latestHighLabel, color.white)
        label.set_size(latestHighLabel, latestLabelSize)
        label.set_text_formatting(latestHighLabel, text.format_bold)
        label.set_tooltip(latestHighLabel, "Latest high-side chronology state")

if anyLowStatusEvent and showLatestLowLabel
    string lowText = f_latest_label_text("Low", latestLowLeaderCode, nz(latestLowLeadBars, 0), latestLabelStyle)
    if na(latestLowLabel)
        latestLowLabel := label.new(
             x = bar_index,
             y = lowLabelY,
             text = lowText,
             style = label.style_label_up,
             color = lowSideLabelColor,
             textcolor = color.white,
             size = latestLabelSize,
             text_formatting = text.format_bold,
             tooltip = "Latest low-side chronology state"
        )
    else
        label.set_xy(latestLowLabel, bar_index, lowLabelY)
        label.set_text(latestLowLabel, lowText)
        label.set_color(latestLowLabel, lowSideLabelColor)
        label.set_textcolor(latestLowLabel, color.white)
        label.set_size(latestLowLabel, latestLabelSize)
        label.set_text_formatting(latestLowLabel, text.format_bold)
        label.set_tooltip(latestLowLabel, "Latest low-side chronology state")

// ============================================================================
// PLOTS
// ============================================================================
plot(
     displaySeries,
     title = "OBV Price Confirmation Chronology",
     color = obvLineColor,
     linewidth = lineWidthObv,
     display = display.pane
)

plot(
     showSmooth ? smoothSeries : na,
     title = "Smoothing",
     color = smoothLineColor,
     linewidth = lineWidthSmooth,
     display = display.pane
)

plotshape(showHistoricalMarkers and eventHighObvLed ? eventHighPairY : na, title = "High side completed | OBV led", style = shape.diamond, location = location.absolute, color = obvLedMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventHighPriceLed ? eventHighPairY : na, title = "High side completed | Price led", style = shape.diamond, location = location.absolute, color = priceLedMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventHighSync ? eventHighPairY : na, title = "High side completed | Synchronized", style = shape.diamond, location = location.absolute, color = synchronizedMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventLowObvLed ? eventLowPairY : na, title = "Low side completed | OBV led", style = shape.diamond, location = location.absolute, color = obvLedMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventLowPriceLed ? eventLowPairY : na, title = "Low side completed | Price led", style = shape.diamond, location = location.absolute, color = priceLedMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventLowSync ? eventLowPairY : na, title = "Low side completed | Synchronized", style = shape.diamond, location = location.absolute, color = synchronizedMarkerColor, size = size.tiny, text = "", display = display.pane)

plotshape(showHistoricalMarkers and eventHighPriceOnly ? eventHighUnpairedY : na, title = "High side unpaired | Price only", style = shape.xcross, location = location.absolute, color = unpairedPriceMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventHighObvOnly ? eventHighUnpairedY : na, title = "High side unpaired | OBV only", style = shape.xcross, location = location.absolute, color = unpairedObvMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventLowPriceOnly ? eventLowUnpairedY : na, title = "Low side unpaired | Price only", style = shape.xcross, location = location.absolute, color = unpairedPriceMarkerColor, size = size.tiny, text = "", display = display.pane)
plotshape(showHistoricalMarkers and eventLowObvOnly ? eventLowUnpairedY : na, title = "Low side unpaired | OBV only", style = shape.xcross, location = location.absolute, color = unpairedObvMarkerColor, size = size.tiny, text = "", display = display.pane)

// ============================================================================
// STATUS TABLE
// ============================================================================
var table statusTable = table.new(
     position = f_table_position(statusTablePositionInput),
     columns = 2,
     rows = 8,
     frame_color = color.new(statusBorderColor, 38),
     frame_width = 1,
     border_color = color.new(statusBorderColor, 62),
     border_width = 1
)

statusTableTextSize = f_table_text_size(statusTableTextSizeInput)
statusTableTextFormatting = boldStatusTableText ? text.format_bold : text.format_none

if barstate.islast
    table.clear(statusTable, 0, 0, 1, 7)

    if showStatusTable
        string compactHighReading = f_compact_leader_text(latestHighLeaderCode, nz(latestHighLeadBars, 0))
        string compactLowReading = f_compact_leader_text(latestLowLeaderCode, nz(latestLowLeadBars, 0))

        string pendingHighCompact =
             not na(pendingPriceHighBar) ? "Price " + str.tostring(stateDisplayBarIndex - pendingPriceHighBar) + "/" + str.tostring(pairToleranceBars) :
             not na(pendingObvHighBar) ? "OBV " + str.tostring(stateDisplayBarIndex - pendingObvHighBar) + "/" + str.tostring(pairToleranceBars) :
             "—"

        string pendingLowCompact =
             not na(pendingPriceLowBar) ? "Price " + str.tostring(stateDisplayBarIndex - pendingPriceLowBar) + "/" + str.tostring(pairToleranceBars) :
             not na(pendingObvLowBar) ? "OBV " + str.tostring(stateDisplayBarIndex - pendingObvLowBar) + "/" + str.tostring(pairToleranceBars) :
             "—"

        string gapBiasCompact =
             not volumeReady ? "No volume" :
             not contextWindowReady ? "Warmup" :
             rangePositionGap > positionGapHighlightThreshold ? "OBV" :
             rangePositionGap < -positionGapHighlightThreshold ? "Price" :
             "Balanced"

        string lineReadingCompact =
             na(smoothSeries) ? "OBV only" :
             displaySeries > smoothSeries ? "Above smooth" :
             displaySeries < smoothSeries ? "Below smooth" :
             "On smooth"

        color headerBackground = color.new(statusHeaderColor, statusTableTransparency)
        color bodyValueBackground = color.new(statusBodyColor, statusTableTransparency)
        color bodyKeyBackground = color.new(statusHeaderColor, math.min(statusTableTransparency + 44, 95))

        if statusTableDensity == "Compact"
            string compactPendingReading = pendingHighCompact == "—" and pendingLowCompact == "—" ? "None" : "H " + pendingHighCompact + " | L " + pendingLowCompact
            string compactGapReading = not volumeReady ? "Unavailable" : not contextWindowReady ? "Warmup" : gapBiasCompact + " " + str.tostring(math.abs(rangePositionGap), "#.0")

            color highKeyBackground = color.new(highSideLabelColor, math.min(statusTableTransparency + 8, 90))
            color highValueBackground = color.new(highSideLabelColor, math.min(statusTableTransparency + 58, 95))
            color lowKeyBackground = color.new(lowSideLabelColor, math.min(statusTableTransparency + 8, 90))
            color lowValueBackground = color.new(lowSideLabelColor, math.min(statusTableTransparency + 58, 95))
            color highKeyTextColor = color.rgb(5, 27, 18)
            color lowKeyTextColor = color.rgb(35, 7, 24)

            table.cell(statusTable, 0, 0, "High", text_color = highKeyTextColor, bgcolor = highKeyBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, 0, compactHighReading, text_color = color.white, bgcolor = highValueBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)

            table.cell(statusTable, 0, 1, "Low", text_color = lowKeyTextColor, bgcolor = lowKeyBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, 1, compactLowReading, text_color = color.white, bgcolor = lowValueBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)

            table.cell(statusTable, 0, 2, "Pending", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, 2, compactPendingReading, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)

            table.cell(statusTable, 0, 3, "Gap", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, 3, compactGapReading, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_valign = text.align_center, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
        else
            string chronologyReading = latestHighLeaderCode == "None" and latestLowLeaderCode == "None" ? "Waiting for records" : "H: " + f_status_phrase(latestHighLeaderCode, nz(latestHighLeadBars, 0)) + " | L: " + f_status_phrase(latestLowLeaderCode, nz(latestLowLeadBars, 0))
            string pendingHighReading = pendingHighCompact == "—" ? "None" : pendingHighCompact
            string pendingLowReading = pendingLowCompact == "—" ? "None" : pendingLowCompact
            string environmentReading = (chartAllowed ? "Standard" : "Paused") + " | " + (volumeReady ? "Volume ok" : "No volume") + " | " + (recordWindowReady ? "Ready" : "Warmup") + " | " + (evaluateConfirmedBarsOnly ? "Bar close" : "Intrabar preview")
            string legendReading = "Diamond paired | X unpaired | Blue OBV | Gold Price | White Sync"

            int row = 0
            table.cell(statusTable, 0, row, "Chronology", text_color = color.white, bgcolor = headerBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, chronologyReading, text_color = color.white, bgcolor = headerBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            row += 1

            table.cell(statusTable, 0, row, "High", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, f_status_phrase(latestHighLeaderCode, nz(latestHighLeadBars, 0)), text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            row += 1

            table.cell(statusTable, 0, row, "Low", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, f_status_phrase(latestLowLeaderCode, nz(latestLowLeadBars, 0)), text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            row += 1

            table.cell(statusTable, 0, row, "Pending", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, "H " + pendingHighReading + " | L " + pendingLowReading, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            row += 1

            table.cell(statusTable, 0, row, "Gap", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, not volumeReady ? "Unavailable" : not contextWindowReady ? "Warmup" : str.tostring(rangePositionGap, "#.0") + " | " + gapBiasCompact, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            row += 1

            table.cell(statusTable, 0, row, "Reading", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
            table.cell(statusTable, 1, row, lineReadingCompact + " | " + environmentReading, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)

            if showTableLegendRow
                row += 1
                table.cell(statusTable, 0, row, "Legend", text_color = color.white, bgcolor = bodyKeyBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)
                table.cell(statusTable, 1, row, legendReading, text_color = color.white, bgcolor = bodyValueBackground, text_halign = text.align_left, text_size = statusTableTextSize, text_formatting = statusTableTextFormatting)

// ============================================================================
// DATA WINDOW FIELDS
// ============================================================================
plot(priceRangePosition, title = "Price range position", color = color.new(color.gray, 100), display = display.data_window)
plot(obvRangePosition, title = "OBV range position", color = color.new(color.gray, 100), display = display.data_window)
plot(rangePositionGap, title = "OBV-price range-position gap", color = color.new(color.gray, 100), display = display.data_window)
plot(volumeReady ? 1.0 : 0.0, title = "Usable volume data", color = color.new(color.gray, 100), display = display.data_window)
plot(recordWindowReady ? 1.0 : 0.0, title = "Record lookback ready", color = color.new(color.gray, 100), display = display.data_window)
plot(contextReady ? 1.0 : 0.0, title = "Context lookback ready", color = color.new(color.gray, 100), display = display.data_window)
plot(not na(pendingPriceHighBar) ? stateDisplayBarIndex - pendingPriceHighBar : na, title = "Pending price high age", color = color.new(color.gray, 100), display = display.data_window)
plot(not na(pendingObvHighBar) ? stateDisplayBarIndex - pendingObvHighBar : na, title = "Pending OBV high age", color = color.new(color.gray, 100), display = display.data_window)
plot(not na(pendingPriceLowBar) ? stateDisplayBarIndex - pendingPriceLowBar : na, title = "Pending price low age", color = color.new(color.gray, 100), display = display.data_window)
plot(not na(pendingObvLowBar) ? stateDisplayBarIndex - pendingObvLowBar : na, title = "Pending OBV low age", color = color.new(color.gray, 100), display = display.data_window)

// ============================================================================
// ALERTS — CONFIRMED BAR CLOSE ONLY
// ============================================================================
// Alerts remain confirmed-bar events even when intrabar preview is enabled.
bool confirmedAlertCycle = barstate.isconfirmed

alertcondition(enableHighObvLedAlert and confirmedAlertCycle and eventHighObvLed, title = "High-side OBV led", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | High side | OBV led | Close {{close}} | Confirmed bar close")
alertcondition(enableHighPriceLedAlert and confirmedAlertCycle and eventHighPriceLed, title = "High-side price led", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | High side | Price led | Close {{close}} | Confirmed bar close")
alertcondition(enableHighSyncAlert and confirmedAlertCycle and eventHighSync, title = "High-side synchronized", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | High side | Synchronized | Close {{close}} | Confirmed bar close")
alertcondition(enableLowObvLedAlert and confirmedAlertCycle and eventLowObvLed, title = "Low-side OBV led", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | Low side | OBV led | Close {{close}} | Confirmed bar close")
alertcondition(enableLowPriceLedAlert and confirmedAlertCycle and eventLowPriceLed, title = "Low-side price led", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | Low side | Price led | Close {{close}} | Confirmed bar close")
alertcondition(enableLowSyncAlert and confirmedAlertCycle and eventLowSync, title = "Low-side synchronized", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | Low side | Synchronized | Close {{close}} | Confirmed bar close")
alertcondition(enableUnpairedAlert and confirmedAlertCycle and (eventHighPriceOnly or eventHighObvOnly or eventLowPriceOnly or eventLowObvOnly), title = "Unpaired chronology expiration", message = "OBV Price Confirmation Chronology | {{ticker}} | {{interval}} | Pending record expired unpaired | Close {{close}} | Confirmed bar close")
````
