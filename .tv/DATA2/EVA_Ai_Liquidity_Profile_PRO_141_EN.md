<!-- tradingview-pine-id: PUB;a96b5766a8e74f41a462198fae78fd2c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 🧬 EVA Ai + Liquidity Profile PRO 1.4.1 EN

Source: https://www.tradingview.com/script/ADPEnnw7-eva-ai-poc-liquidity-smart-money/

## Description

## Overview

**EVA Ai+ Volume Profile — POC, Value Area & Liquidity** is a market-structure and volume-distribution indicator designed to analyze where trading activity is concentrated across price.

Its primary purpose is to combine price-based Volume Profile information with confirmed liquidity structure in one analytical framework.

The script calculates a horizontal volume distribution, Point of Control (POC), Value Area, High-Volume Nodes (HVN), Low-Volume Nodes (LVN), directional volume estimates, and confirmed buy-side/sell-side liquidity pools.

These components are not intended to function as independent entry signals. They are combined to help answer a specific analytical question:

**Where is price currently being accepted, where is participation relatively low, and where does confirmed unswept liquidity remain in relation to that auction structure?**

The indicator does **not** generate automatic LONG or SHORT recommendations and does not execute trades.

---

## Purpose of the combined architecture

Volume Profile and liquidity analysis describe different aspects of market behavior.

Volume Profile measures how the available volume data is distributed across price.

Liquidity structure identifies confirmed areas around comparable swing highs and lows that have not yet been fully cleared according to the script's rules.

EVA combines these concepts because either one viewed in isolation can omit relevant context.

For example:

* POC and Value Area describe the center and boundaries of accepted value;
* HVNs identify local concentrations of calculated participation;
* LVNs identify comparatively low-volume regions;
* directional volume provides context about the composition of the calculated profile;
* confirmed BSL/SSL pools identify unresolved liquidity structures;
* distance and quality calculations place those structures in relation to current volatility and price.

The intended result is a single auction map showing **value, participation, low-volume structure, and confirmed liquidity context together**.

This interaction is the principal reason these components are included in one script.

---

## Volume Profile

The script distributes the available volume across horizontal price rows within the active calculation range.

The profile is intended to show where the selected market spent comparatively more or less trading activity.

### Point of Control — POC

POC is the price row containing the largest amount of calculated profile volume.

It represents the highest-volume row of the current profile calculation.

It should not be interpreted as an automatic support, resistance, entry, or reversal signal.

### Value Area

The Value Area contains the configured percentage of calculated profile volume surrounding the profile's primary volume concentration.

A commonly used setting is 70%.

The script displays:

* **VAH** — Value Area High;
* **VAL** — Value Area Low.

Price inside the Value Area indicates that it is trading within the profile's calculated value region.

Price above VAH or below VAL indicates that it is outside that region, but this condition alone does not imply continuation or reversal.

---

## HVN and LVN structure

### High-Volume Nodes — HVN

HVNs are local concentrations within the calculated profile where neighboring rows contain comparatively high volume.

They can be used to identify areas of previous acceptance or repeated participation.

Possible market behavior around an HVN can include rotation, consolidation, retesting, support/resistance behavior, or no meaningful reaction at all.

The script does not assume that an HVN must hold.

### Low-Volume Nodes — LVN

LVNs are local low-volume regions between areas of greater calculated participation.

They can highlight portions of the profile where historical acceptance was comparatively limited.

Price may sometimes traverse these areas more quickly, but an LVN does not guarantee acceleration or determine direction.

HVN and LVN structures remain components of the calculated profile and can change when the active profile range changes.

---

## Directional volume context

When lower-timeframe data is available, the script classifies lower-timeframe volume according to candle direction and aggregates that information into the profile.

The resulting values are displayed as:

* Up Volume;
* Down Volume;
* Delta.

**Delta in this indicator is the difference between the script's classified Up Volume and Down Volume.**

It is important to distinguish this from exchange-level bid/ask order-flow delta.

Pine Script does not provide the script with a complete historical exchange order book or universal historical bid/ask footprint data.

Therefore, EVA does not claim to reconstruct those datasets.

Directional volume is an approximation derived from the available lower-timeframe OHLCV data.

---

## BSL and SSL liquidity structure

The liquidity component identifies confirmed structures around comparable pivot highs and lows.

### BSL — Buy-Side Liquidity

BSL structures are created above qualifying comparable swing highs.

### SSL — Sell-Side Liquidity

SSL structures are created below qualifying comparable swing lows.

The script does not label every swing high or swing low as liquidity.

A liquidity structure requires multiple confirmed pivot observations that satisfy the script's similarity, spacing, volatility, and quality conditions.

This filtering is intended to reduce the number of insignificant structures displayed on the chart.

Liquidity terminology in this script represents a technical model based on price structure. It does not imply direct observation of hidden orders or stop orders in an exchange order book.

---

## Liquidity Quality

Each qualifying liquidity structure receives a quality value based on several measurable properties of the detected structure.

Depending on the active configuration, these properties include factors such as:

* relative volume;
* rejection characteristics;
* spacing between qualifying pivots;
* volatility-adjusted geometry.

The quality value is used for filtering and ranking detected structures.

It is a relative analytical score created by this script. It is **not a probability of a profitable trade or a prediction that a liquidity level will be reached or swept**.

---

## Liquidity states

Detected pools can move through several states.

### FRESH

The qualifying structure has been confirmed and has not yet met the script's test or sweep conditions.

### TESTED

Price has interacted with the structure according to the configured testing rules without completing the full sweep condition.

### OFF

The structure remains internally valid but falls outside the configured volatility-adjusted working radius and is therefore not displayed as an active nearby structure.

### SWEPT

Price has crossed the structure's defined far boundary.

Once this condition is confirmed, the corresponding active pool drawings are removed.

The state system prevents historical liquidity structures from remaining visually active after the script considers them resolved.

---

## Nearest structural references

The dashboard identifies nearby calculated structures such as:

* BSL;
* SSL;
* HVN;
* LVN.

Distances can be normalized using ATR so that the displayed distance is comparable across instruments with different nominal prices and volatility.

These values describe **location**, not trade expectancy.

A nearby BSL, SSL, HVN, or LVN should not be interpreted as a recommendation to enter a position.

---

## Profile modes

The script supports several ways to define the profile range.

### Visible Range

The profile is calculated from the chart region used by the script's visible-range logic.

Changing the visible chart area can therefore change the profile.

This behavior is intentional.

A Visible Range profile is dynamic and should not be interpreted as an immutable historical signal.

### Session

The profile is calculated using the selected session boundaries.

This mode can be used to examine session-specific POC, Value Area, and volume distribution.

### Fixed Range

The profile is calculated between user-defined time boundaries.

This mode can be used to inspect a specific impulse, consolidation, expansion, or other manually selected market segment.

---

## Adaptive configuration

The optional adaptive mode adjusts selected calculation parameters according to chart conditions.

Depending on configuration, this can include:

* lower-timeframe selection;
* profile row density;
* HVN/LVN sensitivity;
* pivot sensitivity;
* liquidity-zone width;
* minimum liquidity-quality threshold;
* volatility-adjusted display radius.

The purpose of this mode is to maintain usable analytical resolution across different chart timeframes and price scales.

Adaptive configuration does not optimize for future profitability and does not predict future market direction.

Users can disable adaptive behavior and use manual settings where required.

---

## Dashboard

The dashboard summarizes the current calculated state of the indicator.

Depending on the selected configuration, it can display:

### Auction

The location of current price relative to VAH, VAL, and the calculated Value Area.

### Range / Source

The active profile mode and the data source currently used by the calculation.

### Rows × Step

The effective number of price rows and the price increment represented by each row.

### Up / Down / Delta

The directional volume classification generated from the available data.

### POC / Distance

The current POC and price distance from it.

### Nearest BSL / SSL

The nearest qualifying liquidity structure together with distance, quality, and state.

### Nearest HVN / LVN

The nearest calculated high-volume and low-volume structures.

### Structure

A descriptive classification of the current volume distribution.

### Status

Information concerning the current calculation mode and available data.

The dashboard summarizes calculated information; it does not produce trading instructions.

---

## How to interpret the map

### Price inside Value Area

Price inside VAH and VAL is trading within the profile's calculated value region.

POC and HVNs can help locate concentrations of historical participation.

This does not necessarily imply a ranging market or predict that price will remain inside the Value Area.

### Price above VAH

Price above VAH is outside the upper boundary of the calculated Value Area.

Whether the move continues or returns into value depends on subsequent market behavior.

VAH alone is not a breakout confirmation.

### Price below VAL

Price below VAL is outside the lower boundary of the calculated Value Area.

VAL alone does not confirm bearish continuation.

### Interaction with an LVN

An LVN identifies a region of comparatively low calculated participation.

It can be used to observe how price behaves when entering a low-volume region, but it does not guarantee rapid movement through that area.

### Interaction with liquidity

When price reaches a BSL or SSL structure, users can observe whether the level remains active, becomes tested, or satisfies the script's sweep condition.

A sweep is a structural event only.

**A liquidity sweep does not by itself imply a reversal or continuation.**

---

## Data handling and confirmation

Where available, lower-timeframe OHLCV data is used to improve the allocation of volume within higher-timeframe chart candles.

When the requested lower-timeframe sample is unavailable or insufficient for the selected calculation, the script can use its documented fallback calculation instead of presenting an incomplete lower-timeframe profile as if it were complete.

Liquidity structures are based on confirmed pivot events.

Because a pivot requires subsequent bars for confirmation, a newly confirmed liquidity structure can appear later than the historical bar on which the pivot itself occurred.

The script does not interpret this confirmation delay as advance knowledge.

Developing profiles can change as additional data arrives.

Visible Range profiles can also change when the chart viewport changes.

These behaviors are inherent to dynamic profile calculations and should not be interpreted as historical trade signals being rewritten.

---

## Originality and design rationale

The script uses established analytical concepts such as Volume Profile, POC, Value Area, pivots, ATR normalization, and liquidity terminology.

It does not claim that those individual concepts are proprietary.

The distinctive functionality of this implementation is their integration into a unified state-based analytical system.

Instead of independently displaying several unrelated indicators, EVA:

1. builds a common price-row volume model;
2. derives POC and Value Area from that same distribution;
3. identifies local HVN/LVN structure within the profile;
4. estimates directional volume from lower-timeframe data where available;
5. independently confirms comparable pivot structures;
6. applies volatility-, geometry-, and participation-based filtering to those structures;
7. maintains lifecycle states for active liquidity pools;
8. relates nearby volume and liquidity structures to current price using a common dashboard and normalized distance model;
9. provides explicit fallback behavior when detailed source data is unavailable.

The purpose of the integration is to provide one coherent representation of **auction value, relative participation, low-volume structure, and unresolved price-based liquidity** rather than a collection of independent signals.

---

## Why the source code is protected

The source code is protected to preserve the implementation of the script's integrated profile construction, adaptive parameter logic, node-classification methods, liquidity-quality filtering, state transitions, data-fallback handling, and visualization architecture.

Closed-source visibility is not intended to prevent users from understanding the indicator's behavior.

This description therefore documents the script's purpose, inputs, main calculations, interpretation, data limitations, and expected dynamic behavior without exposing implementation-specific formulas and thresholds.

---

## Important limitations

Users should understand the following limitations before using the indicator:

* The script only has access to data supplied to Pine Script by TradingView and the active symbol's data provider.
* Volume characteristics differ between markets and symbols.
* On some Forex instruments, the available volume can represent tick volume rather than centralized exchange volume.
* The script does not have access to a complete historical exchange order book.
* It does not know the location of actual individual traders' stop orders.
* BSL and SSL are price-structure models, not observations of hidden orders.
* Directional volume is derived from available candle data and is not equivalent to true exchange bid/ask footprint delta.
* Confirmed pivots necessarily introduce confirmation delay.
* Visible Range calculations can change when the chart viewport changes.
* Developing profiles can change as new bars or intrabars become available.
* HVNs, LVNs, POC, VAH, VAL, BSL, and SSL do not predict future price behavior.
* No individual component should be interpreted as a guaranteed support, resistance, breakout, reversal, entry, or target.
* Different symbols, sessions, timeframes, and data feeds can produce materially different profile structures.

---

## Intended use

EVA is intended as a **market-reading and contextual-analysis tool**.

A typical workflow is:

1. identify the current Value Area and POC;
2. inspect the shape of the volume distribution;
3. locate nearby HVN and LVN structures;
4. identify confirmed active BSL and SSL structures;
5. compare those structures with current price and volatility;
6. observe subsequent price and volume behavior;
7. perform an independent trade and risk assessment.

The indicator deliberately does not convert this information into automatic LONG or SHORT instructions.

---

## Risk disclosure

This script is an analytical indicator and does not execute orders.

It does not provide financial advice, guarantee trading outcomes, or predict future market behavior.

Historical structures and previous market reactions do not establish how price will behave in the future.

Users remain responsible for independent analysis, position sizing, execution decisions, and risk management.

---

## Source Code

````pine
//@version=6
indicator("🧬 EVA Ai + Liquidity Profile PRO 1.4.1 EN", shorttitle = "🧬 EVA Ai + LP PREMIUM EN", overlay = true,
     max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
// EVA Liquidity Profile PRO 1.4.1 • English interface
// POC • Value Area • VAH/VAL • HVN/LVN liquidity zones
// Visual Precision: aligned delta rail • fitted node geometry • ATR work radius
// Modes: Visible Range • Session HD • Fixed Range
//
// The script uses real volume supplied by the chart data feed. When enabled,
// lower-timeframe OHLCV bars improve price allocation. Pine Script has no access
// to historical bid/ask volume or the exchange order book, so no such data is
// fabricated here.
// =============================================================================

const string MODE_VISIBLE = "Visible Range"
const string MODE_SESSION = "Session HD"
const string MODE_FIXED   = "Fixed Range"

const string ROWS_AUTO  = "Auto Rows"
const string ROWS_TICKS = "Ticks per Row"

const string SIDE_RIGHT = "Right"
const string SIDE_LEFT  = "Left"

const string VIEW_TOTAL  = "Total Gradient"
const string VIEW_UPDOWN = "Up / Down"
const string VIEW_DELTA  = "Delta"

const string SWEEP_FULL  = "Full Sweep"
const string SWEEP_TOUCH = "First Touch"

const string G_AUTO   = "00 • EVA AUTOPILOT"
const string G_RANGE  = "01 • Range"
const string G_ENGINE = "02 • Profile and Precision"
const string G_LEVELS = "03 • POC and Value Area"
const string G_NODES  = "04 • HVN / LVN Profile Nodes"
const string G_POOLS  = "05 • Smart Liquidity Pools"
const string G_STYLE  = "06 • Neon Glow Style"
const string G_PANEL  = "07 • Dashboard"

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: autopilot
// ─────────────────────────────────────────────────────────────────────────────
bool autopilotInput = input.bool(true, "AUTOPILOT • adaptive mode", group = G_AUTO,
     tooltip = "Automatically selects the lower timeframe, profile row density, HVN/LVN thresholds and liquidity-confirmation parameters for the current timeframe and data volume.")
bool autopilotLiveProfileInput = input.bool(true, "Auto-update developing profile", group = G_AUTO,
     active = autopilotInput,
     tooltip = "Updates the active profile from incoming confirmed microbars. Smart Liquidity Pools are still created and removed only on closed chart bars.")

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: range
// ─────────────────────────────────────────────────────────────────────────────
string rangeModeInput = input.string(MODE_VISIBLE, "Profile mode",
     options = [MODE_VISIBLE, MODE_SESSION, MODE_FIXED], group = G_RANGE,
     tooltip = "Visible Range — visible candles only. Session HD — separate profiles for recent trading sessions. Fixed Range — the interval between two adjustable time markers.",
     display = display.none)

int fixedStartInput = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Fixed: start",
     group = G_RANGE, active = rangeModeInput == MODE_FIXED,
     tooltip = "Drag the marker directly on the chart.", display = display.none)
int fixedEndInput = input.time(timestamp("31 Dec 2027 23:59 +0000"), "Fixed: end",
     group = G_RANGE, active = rangeModeInput == MODE_FIXED,
     tooltip = "Drag the marker directly on the chart.", display = display.none)

string sessionHoursInput = input.session("0000-2359", "Session: trading hours",
     group = G_RANGE, active = rangeModeInput == MODE_SESSION,
     tooltip = "Uses the symbol exchange timezone. Keep 0000–2359 for a full trading day.",
     display = display.none)
int sessionProfilesInput = input.int(3, "Session: profiles on chart", minval = 1, maxval = 4,
     group = G_RANGE, active = rangeModeInput == MODE_SESSION, display = display.none)
int sessionLookbackBarsInput = input.int(3000, "Session: calculation depth, bars",
     minval = 500, maxval = 10000, step = 250, group = G_RANGE,
     active = rangeModeInput == MODE_SESSION,
     tooltip = "Limits session-history calculations and protects Pine from overload.",
     display = display.none)

bool confirmedOnlyInput = input.bool(true, "Closed bars only",
     group = G_RANGE, active = not autopilotInput,
     tooltip = "Enabled: ticks from the forming candle do not change the profile. Disabled: the current candle participates in the developing profile.")

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: profile engine
// ─────────────────────────────────────────────────────────────────────────────
string rowModeInput = input.string(ROWS_AUTO, "Row Size",
     options = [ROWS_AUTO, ROWS_TICKS], group = G_ENGINE, active = not autopilotInput,
     display = display.none)
int rowsInput = input.int(64, "Auto Rows: maximum rows", minval = 12, maxval = 80,
     group = G_ENGINE, active = rowModeInput == ROWS_AUTO and not autopilotInput,
     display = display.none)
int ticksPerRowInput = input.int(10, "Ticks per Row", minval = 1, maxval = 1000,
     group = G_ENGINE, active = rowModeInput == ROWS_TICKS and not autopilotInput,
     display = display.none)
int maxRowsInput = input.int(80, "Ticks per Row: maximum rows", minval = 12, maxval = 80,
     group = G_ENGINE, active = rowModeInput == ROWS_TICKS and not autopilotInput,
     tooltip = "If the selected step creates too many rows, the profile automatically increases the step size.",
     display = display.none)

string profileViewInput = input.string(VIEW_UPDOWN, "Histogram view",
     options = [VIEW_UPDOWN, VIEW_TOTAL, VIEW_DELTA], group = G_ENGINE,
     tooltip = "Up / Down — neutral volume profile with an aligned neon rail for the dominant side at the profile anchor. Total Gradient — classic profile without a directional rail. Delta — width by absolute Up-minus-Down imbalance plus the directional rail. Direction is calculated from lower-timeframe candles.",
     display = display.none)

bool useLtfInput = input.bool(true, "Enhanced lower-TF precision",
     group = G_ENGINE, active = not autopilotInput,
     tooltip = "Distributes volume using lower-timeframe candles. If intrabar data is incomplete, the full chart-candle dataset is used automatically.")
string lowerTfInput = input.timeframe("1", "Lower timeframe", group = G_ENGINE,
     active = useLtfInput and not autopilotInput, display = display.none)
int maxLtfSamplesInput = input.int(20000, "LTF candle limit", minval = 500, maxval = 60000,
     step = 500, group = G_ENGINE, active = useLtfInput or autopilotInput, display = display.none)
int maxProfileBarsInput = input.int(3000, "Range candle limit", minval = 500, maxval = 10000,
     step = 250, group = G_ENGINE,
     tooltip = "If the limit is exceeded, the dashboard shows a warning. A silently truncated profile is never used.",
     display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: POC / Value Area
// ─────────────────────────────────────────────────────────────────────────────
float valueAreaPctInput = input.float(70.0, "Value Area, %", minval = 50.0, maxval = 95.0,
     step = 0.5, group = G_LEVELS, display = display.none)
bool showProfileInput = input.bool(true, "Show histogram", group = G_LEVELS)
bool showValueAreaFillInput = input.bool(false, "Highlight Value Area", group = G_LEVELS,
     tooltip = "Disabled by default: rows inside VA are already highlighted, keeping the chart clean.")
bool showLevelsInput = input.bool(true, "POC / VAH / VAL lines", group = G_LEVELS)
bool extendLevelsInput = input.bool(true, "Extend levels right", group = G_LEVELS,
     active = showLevelsInput)
bool showLevelLabelsInput = input.bool(true, "Level labels", group = G_LEVELS,
     active = showLevelsInput)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: HVN / LVN liquidity zones
// ─────────────────────────────────────────────────────────────────────────────
bool showHvnInput = input.bool(true, "HVN — high-volume zones", group = G_NODES)
int hvnCountInput = input.int(3, "HVN: maximum zones", minval = 1, maxval = 6,
     group = G_NODES, active = showHvnInput and not autopilotInput, display = display.none)
float hvnThresholdInput = input.float(55.0, "HVN: volume vs POC, %", minval = 20.0,
     maxval = 95.0, step = 1.0, group = G_NODES, active = showHvnInput and not autopilotInput,
     display = display.none)

bool showLvnInput = input.bool(true, "LVN — low-volume zones", group = G_NODES)
int lvnCountInput = input.int(3, "LVN: maximum zones", minval = 1, maxval = 6,
     group = G_NODES, active = showLvnInput and not autopilotInput, display = display.none)
float lvnThresholdInput = input.float(22.0, "LVN: maximum volume vs POC, %", minval = 1.0,
     maxval = 60.0, step = 1.0, group = G_NODES, active = showLvnInput and not autopilotInput,
     display = display.none)
float lvnProminenceInput = input.float(12.0, "LVN: minimum depth, %", minval = 0.0,
     maxval = 100.0, step = 1.0, group = G_NODES, active = showLvnInput and not autopilotInput,
     tooltip = "How much more volume adjacent rows must contain versus the local trough.",
     display = display.none)

int nodeSeparationInput = input.int(3, "Minimum node separation, rows", minval = 1,
     maxval = 12, group = G_NODES, active = not autopilotInput, display = display.none)
bool adaptiveNodeZonesInput = input.bool(true, "Adaptive zone thickness", group = G_NODES,
     tooltip = "Expands HVN/LVN across adjacent rows belonging to the same volume structure.")
int nodeThicknessInput = input.int(1, "Fixed thickness, rows", minval = 1,
     maxval = 5, group = G_NODES, active = not adaptiveNodeZonesInput,
     display = display.none)
int nodeMaxThicknessInput = input.int(4, "Adaptive: maximum rows", minval = 1,
     maxval = 7, group = G_NODES, active = adaptiveNodeZonesInput,
     display = display.none)
bool extendNodeZonesInput = input.bool(true, "Short right projection", group = G_NODES,
     tooltip = "Projects HVN/LVN only into the nearest working area: 8% of the range, capped at 30 bars. Infinite fills are disabled.")
bool showNodeLabelsInput = input.bool(true, "HVN / LVN labels", group = G_NODES)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: confirmed stop-liquidity pools
// ─────────────────────────────────────────────────────────────────────────────
bool showLiquidityPoolsInput = input.bool(true, "Smart Liquidity Pools", group = G_POOLS,
     tooltip = "BSL forms at confirmed equal swing highs; SSL forms at equal swing lows. At least two touches and a passed quality filter are required.")
int liquidityPivotInput = input.int(4, "Swing: pivot strength", minval = 2, maxval = 12,
     group = G_POOLS, active = showLiquidityPoolsInput and not autopilotInput,
     display = display.none)
float liquidityAtrWidthInput = input.float(0.10, "Zone width, ATR", minval = 0.03,
     maxval = 0.40, step = 0.01, group = G_POOLS,
     active = showLiquidityPoolsInput and not autopilotInput, display = display.none)
float liquidityQualityInput = input.float(72.0, "Minimum quality, Q", minval = 50.0,
     maxval = 95.0, step = 1.0, group = G_POOLS,
     active = showLiquidityPoolsInput and not autopilotInput, display = display.none)
int liquidityLookbackInput = input.int(500, "Validity period, bars", minval = 100,
     maxval = 2000, step = 50, group = G_POOLS, active = showLiquidityPoolsInput,
     display = display.none)
float liquidityVisibilityAtrInput = input.float(8.0, "Zone visibility, ATR", minval = 2.0,
     maxval = 30.0, step = 0.5, group = G_POOLS,
     active = showLiquidityPoolsInput and not autopilotInput, display = display.none,
     tooltip = "Distant zones remain in the calculation but are hidden until price returns to the active ATR radius.")
int maxLiquidityZonesInput = input.int(6, "Maximum active zones", minval = 2,
     maxval = 10, group = G_POOLS, active = showLiquidityPoolsInput,
     display = display.none)
string liquiditySweepModeInput = input.string(SWEEP_FULL, "When a pool is collected",
     options = [SWEEP_FULL, SWEEP_TOUCH], group = G_POOLS,
     active = showLiquidityPoolsInput, display = display.none,
     tooltip = "Full Sweep — delete after price clears the far boundary. First Touch — delete as soon as price first enters the zone.")
bool showLiquidityLabelsInput = input.bool(true, "BSL / SSL labels and quality", group = G_POOLS,
     active = showLiquidityPoolsInput)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: style
// ─────────────────────────────────────────────────────────────────────────────
string profileSideInput = input.string(SIDE_RIGHT, "Profile side",
     options = [SIDE_RIGHT, SIDE_LEFT], group = G_STYLE, display = display.none)
float profileWidthPctInput = input.float(27.0, "Profile width, % of range",
     minval = 10.0, maxval = 70.0, step = 1.0, group = G_STYLE,
     display = display.none)
bool gradientOpacityInput = input.bool(true, "Volume opacity gradient", group = G_STYLE)
float rowGapPctInput = input.float(16.0, "Gap between rows, %", minval = 0.0,
     maxval = 35.0, step = 1.0, group = G_STYLE, display = display.none,
     tooltip = "A small gap keeps row boundaries crisp and removes the blurred-fill effect.")

color outsideColorInput = input.color(color.rgb(98, 111, 176), "Volume outside VA", group = G_STYLE)
color valueAreaColorInput = input.color(color.rgb(0, 225, 196), "Value Area", group = G_STYLE)
color upVolumeColorInput = input.color(color.rgb(0, 238, 202), "Up Volume", group = G_STYLE)
color downVolumeColorInput = input.color(color.rgb(255, 75, 137), "Down Volume", group = G_STYLE)
color pocColorInput = input.color(color.rgb(255, 45, 139), "POC", group = G_STYLE)
color vahColorInput = input.color(color.rgb(0, 232, 194), "VAH", group = G_STYLE)
color valColorInput = input.color(color.rgb(75, 142, 255), "VAL", group = G_STYLE)
color hvnColorInput = input.color(color.rgb(41, 190, 255), "HVN", group = G_STYLE)
color lvnColorInput = input.color(color.rgb(255, 183, 64), "LVN", group = G_STYLE)
color buyLiquidityColorInput = input.color(color.rgb(180, 105, 255), "BSL • Buy-side liquidity", group = G_STYLE)
color sellLiquidityColorInput = input.color(color.rgb(0, 205, 255), "SSL • Sell-side liquidity", group = G_STYLE)

int outsideTransparencyInput = input.int(84, "Transparency outside VA", minval = 0,
     maxval = 100, group = G_STYLE, display = display.none)
int valueAreaTransparencyInput = input.int(62, "VA transparency", minval = 0,
     maxval = 100, group = G_STYLE, display = display.none)
int zoneTransparencyInput = input.int(96, "Zone transparency", minval = 85,
     maxval = 99, group = G_STYLE, display = display.none)

bool showDashboardInput = input.bool(true, "Show dashboard", group = G_PANEL)

// ─────────────────────────────────────────────────────────────────────────────
// Storage
// ─────────────────────────────────────────────────────────────────────────────
var array<float> barOpenSamples   = array.new<float>()
var array<float> barHighSamples   = array.new<float>()
var array<float> barLowSamples    = array.new<float>()
var array<float> barCloseSamples  = array.new<float>()
var array<float> barVolumeSamples = array.new<float>()

var array<float> ltfOpenSamples   = array.new<float>()
var array<float> ltfHighSamples   = array.new<float>()
var array<float> ltfLowSamples    = array.new<float>()
var array<float> ltfCloseSamples  = array.new<float>()
var array<float> ltfVolumeSamples = array.new<float>()

var array<box> currentBoxes   = array.new<box>()
var array<line> currentLines  = array.new<line>()
var array<label> currentLabels = array.new<label>()

var array<box> historyBoxes   = array.new<box>()
var array<line> historyLines  = array.new<line>()
var array<label> historyLabels = array.new<label>()
var array<int> historyBoxCounts   = array.new<int>()
var array<int> historyLineCounts  = array.new<int>()
var array<int> historyLabelCounts = array.new<int>()

var int rangeLeftTime  = na
var int rangeRightTime = na
var int rangeLeftIndex = na
var int rangeRightIndex = na
var bool ltfIncomplete = false
var bool ltfOverflow   = false
var bool barOverflow   = false
var bool sessionStartedClean = false

var float currentPoc = na
var float currentVah = na
var float currentVal = na
var float currentTotalVolume = na
var float currentRowStep = na
var float currentRowCount = na
var float currentSampleCount = na
var float currentUpVolume = na
var float currentDownVolume = na
var float currentDeltaPct = na
var float currentActualVaPct = na
var float currentPocPosition = na
var float currentNearestHvn = na
var float currentNearestLvn = na
var int currentHvnCount = 0
var int currentLvnCount = 0

// Recent confirmed pivot candidates.
var array<float> highCandidatePrices = array.new<float>()
var array<float> highCandidateHalves = array.new<float>()
var array<float> highCandidateEvidence = array.new<float>()
var array<int> highCandidateIndices = array.new<int>()
var array<float> lowCandidatePrices = array.new<float>()
var array<float> lowCandidateHalves = array.new<float>()
var array<float> lowCandidateEvidence = array.new<float>()
var array<int> lowCandidateIndices = array.new<int>()

// Active confirmed BSL / SSL zones and their layered glow drawings.
var array<float> liquidityCenters = array.new<float>()
var array<float> liquidityTops = array.new<float>()
var array<float> liquidityBottoms = array.new<float>()
var array<float> liquidityQualities = array.new<float>()
var array<bool> liquidityIsBuySide = array.new<bool>()
var array<int> liquidityTouches = array.new<int>()
var array<bool> liquidityTested = array.new<bool>()
var array<int> liquidityCreatedBars = array.new<int>()
var array<int> liquiditySourceIndices = array.new<int>()
var array<box> liquidityGlowBoxes = array.new<box>()
var array<box> liquidityCoreBoxes = array.new<box>()
var array<line> liquidityCoreLines = array.new<line>()
var array<label> liquidityPoolLabels = array.new<label>()

float chartSeconds = timeframe.in_seconds()
int chartBarMs = na(chartSeconds) ? 60000 : int(chartSeconds * 1000.0)
string autopilotLowerTf = na(chartSeconds) ? "1" : chartSeconds <= 1800.0 ? "1" : chartSeconds <= 7200.0 ? "5" : chartSeconds <= 86400.0 ? "15" : "60"
string effectiveLowerTf = autopilotInput ? autopilotLowerTf : lowerTfInput
bool effectiveUseLtf = autopilotInput or useLtfInput
bool effectiveConfirmedOnly = autopilotInput ? not autopilotLiveProfileInput : confirmedOnlyInput
int effectiveLiquidityPivot = autopilotInput ? (na(chartSeconds) ? 4 : chartSeconds <= 900.0 ? 3 : chartSeconds <= 3600.0 ? 4 : 5) : liquidityPivotInput
float effectiveLiquidityAtrWidth = autopilotInput ? (na(chartSeconds) ? 0.10 : chartSeconds <= 900.0 ? 0.08 : chartSeconds <= 3600.0 ? 0.10 : 0.12) : liquidityAtrWidthInput
float effectiveLiquidityQuality = autopilotInput ? (na(chartSeconds) ? 72.0 : chartSeconds <= 900.0 ? 74.0 : chartSeconds <= 3600.0 ? 72.0 : 70.0) : liquidityQualityInput
float effectiveLiquidityVisibilityAtr = autopilotInput ? (na(chartSeconds) ? 6.0 : chartSeconds <= 900.0 ? 5.5 : chartSeconds <= 3600.0 ? 6.5 : 8.0) : liquidityVisibilityAtrInput

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_clear_samples() =>
    array.clear(barOpenSamples)
    array.clear(barHighSamples)
    array.clear(barLowSamples)
    array.clear(barCloseSamples)
    array.clear(barVolumeSamples)
    array.clear(ltfOpenSamples)
    array.clear(ltfHighSamples)
    array.clear(ltfLowSamples)
    array.clear(ltfCloseSamples)
    array.clear(ltfVolumeSamples)

f_delete_drawings(array<box> boxes, array<line> lines, array<label> labels) =>
    for boxId in boxes
        box.delete(boxId)
    for lineId in lines
        line.delete(lineId)
    for labelId in labels
        label.delete(labelId)
    array.clear(boxes)
    array.clear(lines)
    array.clear(labels)

f_trim_history(int keepGroups) =>
    while array.size(historyBoxCounts) > keepGroups
        int boxesToDelete = array.shift(historyBoxCounts)
        int linesToDelete = array.shift(historyLineCounts)
        int labelsToDelete = array.shift(historyLabelCounts)
        if boxesToDelete > 0
            for i = 0 to boxesToDelete - 1
                if array.size(historyBoxes) > 0
                    box.delete(array.shift(historyBoxes))
        if linesToDelete > 0
            for i = 0 to linesToDelete - 1
                if array.size(historyLines) > 0
                    line.delete(array.shift(historyLines))
        if labelsToDelete > 0
            for i = 0 to labelsToDelete - 1
                if array.size(historyLabels) > 0
                    label.delete(array.shift(historyLabels))

f_is_near(array<int> selected, int candidate, int separation) =>
    bool result = false
    for selectedIndex in selected
        if math.abs(selectedIndex - candidate) < separation
            result := true
    result

// Expands a node around its centre without crossing the structural threshold.
// For an HVN, the denser neighbour wins; for an LVN, the thinner one wins.
f_node_bounds(array<float> volumes, int centreIndex, int maximumRows,
     bool highVolumeNode, float boundaryVolume) =>
    int lowIndex = centreIndex
    int highIndex = centreIndex
    bool expanding = true
    while expanding and highIndex - lowIndex + 1 < maximumRows
        bool canExpandLow = lowIndex > 0 and (highVolumeNode ? array.get(volumes, lowIndex - 1) >= boundaryVolume : array.get(volumes, lowIndex - 1) <= boundaryVolume)
        bool canExpandHigh = highIndex < array.size(volumes) - 1 and (highVolumeNode ? array.get(volumes, highIndex + 1) >= boundaryVolume : array.get(volumes, highIndex + 1) <= boundaryVolume)
        if not canExpandLow and not canExpandHigh
            expanding := false
        else if canExpandLow and not canExpandHigh
            lowIndex -= 1
        else if canExpandHigh and not canExpandLow
            highIndex += 1
        else
            float lowVolume = array.get(volumes, lowIndex - 1)
            float highVolume = array.get(volumes, highIndex + 1)
            bool chooseLow = highVolumeNode ? lowVolume >= highVolume : lowVolume <= highVolume
            if chooseLow
                lowIndex -= 1
            else
                highIndex += 1
    [lowIndex, highIndex]

f_get_sample(bool useLtf, int sampleIndex) =>
    float sampleOpen = useLtf ? array.get(ltfOpenSamples, sampleIndex) : array.get(barOpenSamples, sampleIndex)
    float sampleHigh = useLtf ? array.get(ltfHighSamples, sampleIndex) : array.get(barHighSamples, sampleIndex)
    float sampleLow = useLtf ? array.get(ltfLowSamples, sampleIndex) : array.get(barLowSamples, sampleIndex)
    float sampleClose = useLtf ? array.get(ltfCloseSamples, sampleIndex) : array.get(barCloseSamples, sampleIndex)
    float sampleVolume = useLtf ? array.get(ltfVolumeSamples, sampleIndex) : array.get(barVolumeSamples, sampleIndex)
    [sampleOpen, sampleHigh, sampleLow, sampleClose, sampleVolume]

f_format_price(float price) =>
    na(price) ? "—" : str.tostring(price, format.mintick)

f_format_volume(float value) =>
    string result = "—"
    if not na(value)
        float absoluteValue = math.abs(value)
        float divisor = absoluteValue >= 1000000000.0 ? 1000000000.0 : absoluteValue >= 1000000.0 ? 1000000.0 : absoluteValue >= 1000.0 ? 1000.0 : 1.0
        string suffix = divisor == 1000000000.0 ? "B" : divisor == 1000000.0 ? "M" : divisor == 1000.0 ? "K" : ""
        result := str.tostring(value / divisor, "#.##") + suffix
    result

f_format_percent(float value) =>
    na(value) ? "—" : str.tostring(value, "#.0") + "%"

f_liquidity_text(bool isBuySide, float quality, bool tested) =>
    (isBuySide ? "BSL" : "SSL") + "  Q" + str.tostring(int(math.round(quality))) + "  " + (tested ? "TESTED" : "FRESH")

f_liquidity_tooltip(bool isBuySide, float bottom, float top, float quality, int touches, bool tested) =>
    string sideText = isBuySide ? "BSL — buy-side liquidity above equal swing highs" : "SSL — sell-side liquidity below equal swing lows"
    string stateText = tested ? "TESTED — price entered the zone and partially weakened the pool" : "FRESH — the confirmed pool has not been tested"
    string collectionText = liquiditySweepModeInput == SWEEP_FULL ? "delete after a full sweep of the far boundary" : "delete on first price entry"
    sideText + "\nState: " + stateText + "\nConfirmations: " + str.tostring(touches) + "\nQuality: Q" + str.tostring(int(math.round(quality))) + "/100\nRange: " + f_format_price(bottom) + " — " + f_format_price(top) + "\nQuality logic: equal swing levels + relative volume + rejection wick + spacing.\nLiquidity collection: " + collectionText + "."

f_delete_liquidity_zone(int zoneIndex) =>
    if zoneIndex >= 0 and zoneIndex < array.size(liquidityCenters)
        box.delete(array.get(liquidityGlowBoxes, zoneIndex))
        box.delete(array.get(liquidityCoreBoxes, zoneIndex))
        line.delete(array.get(liquidityCoreLines, zoneIndex))
        label.delete(array.get(liquidityPoolLabels, zoneIndex))
        array.remove(liquidityCenters, zoneIndex)
        array.remove(liquidityTops, zoneIndex)
        array.remove(liquidityBottoms, zoneIndex)
        array.remove(liquidityQualities, zoneIndex)
        array.remove(liquidityIsBuySide, zoneIndex)
        array.remove(liquidityTested, zoneIndex)
        array.remove(liquidityTouches, zoneIndex)
        array.remove(liquidityCreatedBars, zoneIndex)
        array.remove(liquiditySourceIndices, zoneIndex)
        array.remove(liquidityGlowBoxes, zoneIndex)
        array.remove(liquidityCoreBoxes, zoneIndex)
        array.remove(liquidityCoreLines, zoneIndex)
        array.remove(liquidityPoolLabels, zoneIndex)

f_upsert_liquidity_zone(bool isBuySide, float centrePrice, float halfWidth,
     float quality, int sourceIndex, int maximumZones) =>
    color zoneColor = isBuySide ? buyLiquidityColorInput : sellLiquidityColorInput
    int matchedIndex = -1
    float bestDistance = 1e20
    if array.size(liquidityCenters) > 0
        for zoneIndex = 0 to array.size(liquidityCenters) - 1
            bool sameSide = array.get(liquidityIsBuySide, zoneIndex) == isBuySide
            float oldCentre = array.get(liquidityCenters, zoneIndex)
            float oldHalf = (array.get(liquidityTops, zoneIndex) - array.get(liquidityBottoms, zoneIndex)) * 0.5
            float distance = math.abs(centrePrice - oldCentre)
            if sameSide and distance <= math.max(halfWidth, oldHalf) * 1.25 and distance < bestDistance
                matchedIndex := zoneIndex
                bestDistance := distance

    if matchedIndex >= 0
        int oldTouches = array.get(liquidityTouches, matchedIndex)
        int newTouches = oldTouches + 1
        float oldCentre = array.get(liquidityCenters, matchedIndex)
        float oldHalf = (array.get(liquidityTops, matchedIndex) - array.get(liquidityBottoms, matchedIndex)) * 0.5
        float updatedCentre = (oldCentre * oldTouches + centrePrice) / newTouches
        float updatedHalf = math.max(oldHalf, halfWidth)
        float updatedTop = updatedCentre + updatedHalf
        float updatedBottom = updatedCentre - updatedHalf
        float oldQuality = array.get(liquidityQualities, matchedIndex)
        float touchBoost = math.min(8.0, math.max(0.0, (newTouches - 2.0) * 3.0))
        float updatedQuality = math.min(100.0, math.max(oldQuality, quality) + touchBoost)
        int updatedSource = math.min(sourceIndex, array.get(liquiditySourceIndices, matchedIndex))

        array.set(liquidityCenters, matchedIndex, updatedCentre)
        array.set(liquidityTops, matchedIndex, updatedTop)
        array.set(liquidityBottoms, matchedIndex, updatedBottom)
        array.set(liquidityQualities, matchedIndex, updatedQuality)
        array.set(liquidityTested, matchedIndex, false)
        array.set(liquidityTouches, matchedIndex, newTouches)
        array.set(liquidityCreatedBars, matchedIndex, bar_index)
        array.set(liquiditySourceIndices, matchedIndex, updatedSource)

        box glowBox = array.get(liquidityGlowBoxes, matchedIndex)
        box coreBox = array.get(liquidityCoreBoxes, matchedIndex)
        line coreLine = array.get(liquidityCoreLines, matchedIndex)
        label poolLabel = array.get(liquidityPoolLabels, matchedIndex)
        box.set_left(glowBox, updatedSource)
        box.set_right(glowBox, bar_index + 1)
        box.set_top(glowBox, updatedCentre + updatedHalf * 1.75)
        box.set_bottom(glowBox, updatedCentre - updatedHalf * 1.75)
        box.set_bgcolor(glowBox, color.new(zoneColor, 96))
        box.set_left(coreBox, updatedSource)
        box.set_right(coreBox, bar_index + 1)
        box.set_top(coreBox, updatedTop)
        box.set_bottom(coreBox, updatedBottom)
        box.set_border_color(coreBox, color.new(zoneColor, 18))
        box.set_bgcolor(coreBox, color.new(zoneColor, 88))
        line.set_xy1(coreLine, updatedSource, updatedCentre)
        line.set_xy2(coreLine, bar_index + 1, updatedCentre)
        line.set_color(coreLine, color.new(zoneColor, 4))
        label.set_xy(poolLabel, bar_index + 1, updatedCentre)
        label.set_text(poolLabel, showLiquidityLabelsInput ? f_liquidity_text(isBuySide, updatedQuality, false) : "")
        label.set_color(poolLabel, showLiquidityLabelsInput ? color.new(zoneColor, 18) : color.new(zoneColor, 100))
        label.set_tooltip(poolLabel, f_liquidity_tooltip(isBuySide, updatedBottom, updatedTop, updatedQuality, newTouches, false))
    else
        float zoneTop = centrePrice + halfWidth
        float zoneBottom = centrePrice - halfWidth
        box glowBox = box.new(left = sourceIndex, top = centrePrice + halfWidth * 1.75,
             right = bar_index + 1, bottom = centrePrice - halfWidth * 1.75,
             xloc = xloc.bar_index, extend = extend.right, border_color = na,
             bgcolor = color.new(zoneColor, 96))
        box coreBox = box.new(left = sourceIndex, top = zoneTop,
             right = bar_index + 1, bottom = zoneBottom,
             xloc = xloc.bar_index, extend = extend.right,
             border_color = color.new(zoneColor, 18), border_width = 1,
             bgcolor = color.new(zoneColor, 88))
        line coreLine = line.new(x1 = sourceIndex, y1 = centrePrice,
             x2 = bar_index + 1, y2 = centrePrice, xloc = xloc.bar_index,
             extend = extend.right, color = color.new(zoneColor, 4),
             style = line.style_dashed, width = 2)
        string labelText = showLiquidityLabelsInput ? f_liquidity_text(isBuySide, quality, false) : ""
        label poolLabel = label.new(x = bar_index + 1, y = centrePrice,
             text = labelText, xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_left,
             color = showLiquidityLabelsInput ? color.new(zoneColor, 18) : color.new(zoneColor, 100),
             textcolor = color.white, size = size.tiny,
             tooltip = f_liquidity_tooltip(isBuySide, zoneBottom, zoneTop, quality, 2, false))

        array.push(liquidityCenters, centrePrice)
        array.push(liquidityTops, zoneTop)
        array.push(liquidityBottoms, zoneBottom)
        array.push(liquidityQualities, quality)
        array.push(liquidityIsBuySide, isBuySide)
        array.push(liquidityTested, false)
        array.push(liquidityTouches, 2)
        array.push(liquidityCreatedBars, bar_index)
        array.push(liquiditySourceIndices, sourceIndex)
        array.push(liquidityGlowBoxes, glowBox)
        array.push(liquidityCoreBoxes, coreBox)
        array.push(liquidityCoreLines, coreLine)
        array.push(liquidityPoolLabels, poolLabel)

    while array.size(liquidityCenters) > maximumZones
        int weakestIndex = 0
        float weakestQuality = array.get(liquidityQualities, 0)
        if array.size(liquidityCenters) > 1
            for zoneIndex = 1 to array.size(liquidityCenters) - 1
                float candidateQuality = array.get(liquidityQualities, zoneIndex)
                if candidateQuality < weakestQuality
                    weakestQuality := candidateQuality
                    weakestIndex := zoneIndex
        f_delete_liquidity_zone(weakestIndex)

// Calculates and renders one complete profile. Volume is distributed by the
// vertical overlap between each source candle and each price row. Up/Down is
// classified from the direction of each source candle (close >= open = Up).
f_render_profile(bool useLtf, int leftTime, int rightTime, int leftIndex, int rightIndex, bool isCurrent,
     bool drawNodes, array<box> outBoxes, array<line> outLines, array<label> outLabels) =>
    float outPoc = na
    float outVah = na
    float outVal = na
    float outTotalVolume = na
    float outRowStep = na
    float outRowCount = na
    float outSampleCount = na
    float outUpVolume = na
    float outDownVolume = na
    float outDeltaPct = na
    float outActualVaPct = na
    float outPocPosition = na
    float outNearestHvn = na
    float outNearestLvn = na
    int outHvnCount = 0
    int outLvnCount = 0

    int sampleCount = useLtf ? array.size(ltfOpenSamples) : array.size(barOpenSamples)
    if sampleCount > 0 and not na(leftTime) and not na(rightTime) and not na(leftIndex) and not na(rightIndex)
        float rawHigh = na
        float rawLow = na
        int validSamples = 0

        for sampleIndex = 0 to sampleCount - 1
            [sampleOpen, sampleHigh, sampleLow, sampleClose, sampleVolume] = f_get_sample(useLtf, sampleIndex)
            bool validSample = not na(sampleOpen) and not na(sampleHigh) and not na(sampleLow) and not na(sampleClose) and not na(sampleVolume) and sampleVolume > 0.0
            if validSample
                rawHigh := na(rawHigh) ? sampleHigh : math.max(rawHigh, sampleHigh)
                rawLow := na(rawLow) ? sampleLow : math.min(rawLow, sampleLow)
                validSamples += 1

        if validSamples > 0 and not na(rawHigh) and not na(rawLow)
            float rawRange = math.max(0.0, rawHigh - rawLow)
            float rowStep = syminfo.mintick
            float profileLow = rawLow
            int rowCount = 1
            int autopilotRows = validSamples < 300 ? 36 : validSamples < 900 ? 48 : validSamples < 2400 ? 60 : validSamples < 6000 ? 72 : 80
            int effectiveAutoRows = autopilotInput ? autopilotRows : rowsInput

            if rawRange <= syminfo.mintick * 0.01
                rowStep := syminfo.mintick
                profileLow := rawLow - rowStep * 0.5
                rowCount := 1
            else if rowModeInput == ROWS_TICKS and not autopilotInput
                float requestedStep = math.max(syminfo.mintick, syminfo.mintick * ticksPerRowInput)
                float alignedLow = math.floor(rawLow / requestedStep) * requestedStep
                float alignedHigh = math.ceil(rawHigh / requestedStep) * requestedStep
                int requestedRows = math.max(1, int(math.round((alignedHigh - alignedLow) / requestedStep)))
                if requestedRows > maxRowsInput
                    rowCount := maxRowsInput
                    profileLow := alignedLow
                    rowStep := (alignedHigh - alignedLow) / rowCount
                else
                    rowCount := requestedRows
                    profileLow := alignedLow
                    rowStep := requestedStep
            else
                float autoStep = math.max(syminfo.mintick, math.ceil(rawRange / math.max(1, effectiveAutoRows - 1) / syminfo.mintick) * syminfo.mintick)
                profileLow := math.floor(rawLow / autoStep) * autoStep
                rowStep := autoStep
                rowCount := math.max(1, math.min(effectiveAutoRows, int(math.ceil((rawHigh - profileLow) / rowStep))))

            array<float> rowVolumes = array.new<float>(rowCount, 0.0)
            array<float> upVolumes = array.new<float>(rowCount, 0.0)
            array<float> downVolumes = array.new<float>(rowCount, 0.0)
            // Difference arrays keep distribution O(samples + rows).
            array<float> interiorVolumeDiff = array.new<float>(rowCount + 1, 0.0)
            array<float> upInteriorDiff = array.new<float>(rowCount + 1, 0.0)
            array<float> downInteriorDiff = array.new<float>(rowCount + 1, 0.0)

            for sampleIndex = 0 to sampleCount - 1
                [sampleOpen, sampleHigh, sampleLow, sampleClose, sampleVolume] = f_get_sample(useLtf, sampleIndex)
                bool validSample = not na(sampleOpen) and not na(sampleHigh) and not na(sampleLow) and not na(sampleClose) and not na(sampleVolume) and sampleVolume > 0.0
                if validSample
                    bool isUpSample = sampleClose >= sampleOpen
                    float candleLow = math.min(sampleLow, sampleHigh)
                    float candleHigh = math.max(sampleLow, sampleHigh)
                    float candleRange = candleHigh - candleLow
                    if candleRange <= syminfo.mintick * 0.01
                        int rowIndex = math.max(0, math.min(rowCount - 1, int(math.floor((sampleClose - profileLow) / rowStep))))
                        array.set(rowVolumes, rowIndex, array.get(rowVolumes, rowIndex) + sampleVolume)
                        if isUpSample
                            array.set(upVolumes, rowIndex, array.get(upVolumes, rowIndex) + sampleVolume)
                        else
                            array.set(downVolumes, rowIndex, array.get(downVolumes, rowIndex) + sampleVolume)
                    else
                        int firstRow = math.max(0, math.min(rowCount - 1, int(math.floor((candleLow - profileLow) / rowStep))))
                        int lastRow = math.max(0, math.min(rowCount - 1, int(math.floor((candleHigh - profileLow) / rowStep))))
                        float firstBottom = profileLow + firstRow * rowStep
                        float firstTop = firstBottom + rowStep
                        float firstOverlap = math.max(0.0, math.min(candleHigh, firstTop) - math.max(candleLow, firstBottom))

                        if firstRow == lastRow
                            float allocatedVolume = sampleVolume * firstOverlap / candleRange
                            array.set(rowVolumes, firstRow, array.get(rowVolumes, firstRow) + allocatedVolume)
                            if isUpSample
                                array.set(upVolumes, firstRow, array.get(upVolumes, firstRow) + allocatedVolume)
                            else
                                array.set(downVolumes, firstRow, array.get(downVolumes, firstRow) + allocatedVolume)
                        else
                            float lastBottom = profileLow + lastRow * rowStep
                            float lastTop = lastBottom + rowStep
                            float lastOverlap = math.max(0.0, math.min(candleHigh, lastTop) - math.max(candleLow, lastBottom))
                            float firstVolume = sampleVolume * firstOverlap / candleRange
                            float lastVolume = sampleVolume * lastOverlap / candleRange
                            array.set(rowVolumes, firstRow, array.get(rowVolumes, firstRow) + firstVolume)
                            array.set(rowVolumes, lastRow, array.get(rowVolumes, lastRow) + lastVolume)
                            if isUpSample
                                array.set(upVolumes, firstRow, array.get(upVolumes, firstRow) + firstVolume)
                                array.set(upVolumes, lastRow, array.get(upVolumes, lastRow) + lastVolume)
                            else
                                array.set(downVolumes, firstRow, array.get(downVolumes, firstRow) + firstVolume)
                                array.set(downVolumes, lastRow, array.get(downVolumes, lastRow) + lastVolume)

                            int interiorStart = firstRow + 1
                            int interiorEnd = lastRow - 1
                            if interiorStart <= interiorEnd
                                float fullRowVolume = sampleVolume * rowStep / candleRange
                                array.set(interiorVolumeDiff, interiorStart, array.get(interiorVolumeDiff, interiorStart) + fullRowVolume)
                                array.set(interiorVolumeDiff, interiorEnd + 1, array.get(interiorVolumeDiff, interiorEnd + 1) - fullRowVolume)
                                if isUpSample
                                    array.set(upInteriorDiff, interiorStart, array.get(upInteriorDiff, interiorStart) + fullRowVolume)
                                    array.set(upInteriorDiff, interiorEnd + 1, array.get(upInteriorDiff, interiorEnd + 1) - fullRowVolume)
                                else
                                    array.set(downInteriorDiff, interiorStart, array.get(downInteriorDiff, interiorStart) + fullRowVolume)
                                    array.set(downInteriorDiff, interiorEnd + 1, array.get(downInteriorDiff, interiorEnd + 1) - fullRowVolume)

            float runningInteriorVolume = 0.0
            float runningUpVolume = 0.0
            float runningDownVolume = 0.0
            for rowIndex = 0 to rowCount - 1
                runningInteriorVolume += array.get(interiorVolumeDiff, rowIndex)
                runningUpVolume += array.get(upInteriorDiff, rowIndex)
                runningDownVolume += array.get(downInteriorDiff, rowIndex)
                if runningInteriorVolume != 0.0
                    array.set(rowVolumes, rowIndex, array.get(rowVolumes, rowIndex) + runningInteriorVolume)
                if runningUpVolume != 0.0
                    array.set(upVolumes, rowIndex, array.get(upVolumes, rowIndex) + runningUpVolume)
                if runningDownVolume != 0.0
                    array.set(downVolumes, rowIndex, array.get(downVolumes, rowIndex) + runningDownVolume)

            float totalVolume = array.sum(rowVolumes)
            float totalUpVolume = array.sum(upVolumes)
            float totalDownVolume = array.sum(downVolumes)
            float maxVolume = array.max(rowVolumes)
            float maxAbsDelta = 0.0
            for rowIndex = 0 to rowCount - 1
                maxAbsDelta := math.max(maxAbsDelta, math.abs(array.get(upVolumes, rowIndex) - array.get(downVolumes, rowIndex)))

            if totalVolume > 0.0 and maxVolume > 0.0
                // A POC tie is resolved by proximity to profile centre.
                int pocIndex = 0
                float bestPocDistance = 1e20
                float profileMidIndex = (rowCount - 1) * 0.5
                for rowIndex = 0 to rowCount - 1
                    float rowVolume = array.get(rowVolumes, rowIndex)
                    bool tiedForMax = math.abs(rowVolume - maxVolume) <= math.max(1e-10, maxVolume * 1e-10)
                    float distanceToMiddle = math.abs(rowIndex - profileMidIndex)
                    if tiedForMax and distanceToMiddle < bestPocDistance
                        pocIndex := rowIndex
                        bestPocDistance := distanceToMiddle

                // TradingView-style VA expansion: compare the next rows, favour
                // the larger one, break ties by distance then the upper row, and
                // stop before the next row would overshoot the target.
                int valueLowIndex = pocIndex
                int valueHighIndex = pocIndex
                float accumulatedValueVolume = array.get(rowVolumes, pocIndex)
                float targetValueVolume = totalVolume * valueAreaPctInput * 0.01
                float targetTolerance = math.max(1e-10, totalVolume * 1e-10)
                bool buildingValueArea = true

                while buildingValueArea and accumulatedValueVolume < targetValueVolume and (valueLowIndex > 0 or valueHighIndex < rowCount - 1)
                    bool hasLower = valueLowIndex > 0
                    bool hasUpper = valueHighIndex < rowCount - 1
                    float lowerVolume = hasLower ? array.get(rowVolumes, valueLowIndex - 1) : -1.0
                    float upperVolume = hasUpper ? array.get(rowVolumes, valueHighIndex + 1) : -1.0
                    bool chooseUpper = false
                    if not hasLower
                        chooseUpper := true
                    else if not hasUpper
                        chooseUpper := false
                    else if upperVolume > lowerVolume
                        chooseUpper := true
                    else if lowerVolume > upperVolume
                        chooseUpper := false
                    else
                        int upperDistance = valueHighIndex + 1 - pocIndex
                        int lowerDistance = pocIndex - (valueLowIndex - 1)
                        chooseUpper := upperDistance <= lowerDistance

                    float chosenVolume = math.max(0.0, chooseUpper ? upperVolume : lowerVolume)
                    if accumulatedValueVolume + chosenVolume <= targetValueVolume + targetTolerance
                        if chooseUpper
                            valueHighIndex += 1
                        else
                            valueLowIndex -= 1
                        accumulatedValueVolume += chosenVolume
                    else
                        buildingValueArea := false

                float pocPrice = profileLow + (pocIndex + 0.5) * rowStep
                float vahPrice = profileLow + (valueHighIndex + 1.0) * rowStep
                float valPrice = profileLow + valueLowIndex * rowStep
                float actualVaPct = accumulatedValueVolume / totalVolume * 100.0
                float deltaPct = (totalUpVolume - totalDownVolume) / totalVolume * 100.0
                float pocPosition = rowCount <= 1 ? 0.5 : (pocIndex + 0.5) / rowCount
                float pocSharePct = maxVolume / totalVolume * 100.0

                int effectiveRightTime = math.max(rightTime, leftTime + chartBarMs)
                int effectiveRightIndex = math.max(rightIndex, leftIndex)
                int rangeSpanBars = math.max(1, effectiveRightIndex - leftIndex + 1)
                float effectiveWidthPct = isCurrent ? profileWidthPctInput : math.min(profileWidthPctInput, 18.0)
                int maxProfileWidthBars = math.max(1, int(math.round(rangeSpanBars * effectiveWidthPct * 0.01)))
                int profileRightIndex = effectiveRightIndex + 1
                int nodeProjectionBars = isCurrent and extendNodeZonesInput ? math.max(6, math.min(30, int(math.round(rangeSpanBars * 0.08)))) : 0

                if showValueAreaFillInput
                    box valueAreaBox = box.new(left = leftTime, top = vahPrice,
                         right = effectiveRightTime, bottom = valPrice, xloc = xloc.bar_time,
                         border_color = color.new(valueAreaColorInput, 88), border_width = 1,
                         bgcolor = color.new(valueAreaColorInput, 96))
                    array.push(outBoxes, valueAreaBox)

                // A light 1-2-1 kernel stabilises node detection without moving POC.
                array<float> smoothVolumes = array.new<float>(rowCount, 0.0)
                for rowIndex = 0 to rowCount - 1
                    float centreVolume = array.get(rowVolumes, rowIndex)
                    float lowerNeighbour = rowIndex > 0 ? array.get(rowVolumes, rowIndex - 1) : centreVolume
                    float upperNeighbour = rowIndex < rowCount - 1 ? array.get(rowVolumes, rowIndex + 1) : centreVolume
                    array.set(smoothVolumes, rowIndex, lowerNeighbour * 0.25 + centreVolume * 0.50 + upperNeighbour * 0.25)

                float effectiveHvnThreshold = autopilotInput ? math.max(48.0, math.min(62.0, 49.0 + pocSharePct * 0.55)) : hvnThresholdInput
                float effectiveLvnThreshold = autopilotInput ? math.max(13.0, math.min(24.0, 25.0 - pocSharePct * 0.45)) : lvnThresholdInput
                int effectiveNodeSeparation = autopilotInput ? math.max(2, int(math.round(rowCount / 22.0))) : nodeSeparationInput
                int effectiveHvnCount = autopilotInput ? 2 : hvnCountInput
                int effectiveLvnCount = autopilotInput ? 2 : lvnCountInput

                if drawNodes and rowCount >= 3
                    array<int> selectedHvn = array.new<int>()
                    array<int> selectedLvn = array.new<int>()

                    if showHvnInput
                        // First pass: genuine local peaks.
                        for pick = 0 to effectiveHvnCount - 1
                            int bestIndex = -1
                            float bestScore = -1.0
                            for rowIndex = 1 to rowCount - 2
                                float nodeVolume = array.get(smoothVolumes, rowIndex)
                                float lowerNodeVolume = array.get(smoothVolumes, rowIndex - 1)
                                float upperNodeVolume = array.get(smoothVolumes, rowIndex + 1)
                                bool localPeak = (nodeVolume >= lowerNodeVolume and nodeVolume > upperNodeVolume) or (nodeVolume > lowerNodeVolume and nodeVolume >= upperNodeVolume)
                                bool aboveThreshold = nodeVolume >= maxVolume * effectiveHvnThreshold * 0.01
                                bool awayFromPoc = math.abs(rowIndex - pocIndex) >= effectiveNodeSeparation
                                bool separated = not f_is_near(selectedHvn, rowIndex, effectiveNodeSeparation)
                                if localPeak and aboveThreshold and awayFromPoc and separated and nodeVolume > bestScore
                                    bestIndex := rowIndex
                                    bestScore := nodeVolume
                            if bestIndex >= 0
                                array.push(selectedHvn, bestIndex)

                        // Second pass: strongest remaining shelves on smooth profiles.
                        for pick = 0 to effectiveHvnCount - 1
                            if array.size(selectedHvn) < effectiveHvnCount
                                int bestIndex = -1
                                float bestScore = -1.0
                                for rowIndex = 1 to rowCount - 2
                                    float nodeVolume = array.get(smoothVolumes, rowIndex)
                                    bool aboveThreshold = nodeVolume >= maxVolume * effectiveHvnThreshold * 0.01
                                    bool awayFromPoc = math.abs(rowIndex - pocIndex) >= effectiveNodeSeparation
                                    bool separated = not f_is_near(selectedHvn, rowIndex, effectiveNodeSeparation)
                                    if aboveThreshold and awayFromPoc and separated and nodeVolume > bestScore
                                        bestIndex := rowIndex
                                        bestScore := nodeVolume
                                if bestIndex >= 0
                                    array.push(selectedHvn, bestIndex)

                    float occupiedFloor = maxVolume * 0.005
                    int firstOccupied = pocIndex
                    int lastOccupied = pocIndex
                    for rowIndex = 0 to rowCount - 1
                        if array.get(rowVolumes, rowIndex) > occupiedFloor
                            firstOccupied := math.min(firstOccupied, rowIndex)
                            lastOccupied := math.max(lastOccupied, rowIndex)

                    if showLvnInput
                        // First pass: prominent local troughs inside traded structure.
                        for pick = 0 to effectiveLvnCount - 1
                            int bestIndex = -1
                            float bestScore = -1.0
                            for rowIndex = 1 to rowCount - 2
                                float nodeVolume = array.get(smoothVolumes, rowIndex)
                                float lowerNodeVolume = array.get(smoothVolumes, rowIndex - 1)
                                float upperNodeVolume = array.get(smoothVolumes, rowIndex + 1)
                                float smallerNeighbour = math.min(lowerNodeVolume, upperNodeVolume)
                                bool localTrough = nodeVolume <= lowerNodeVolume and nodeVolume <= upperNodeVolume and (nodeVolume < lowerNodeVolume or nodeVolume < upperNodeVolume)
                                bool belowThreshold = nodeVolume <= maxVolume * effectiveLvnThreshold * 0.01
                                bool insideMarket = rowIndex > firstOccupied and rowIndex < lastOccupied
                                bool prominent = nodeVolume <= 0.0 ? smallerNeighbour > 0.0 : smallerNeighbour >= nodeVolume * (1.0 + lvnProminenceInput * 0.01)
                                bool awayFromPoc = math.abs(rowIndex - pocIndex) >= effectiveNodeSeparation
                                bool separated = not f_is_near(selectedLvn, rowIndex, effectiveNodeSeparation) and not f_is_near(selectedHvn, rowIndex, effectiveNodeSeparation)
                                float depthScore = math.max(0.0, smallerNeighbour - nodeVolume)
                                if localTrough and belowThreshold and insideMarket and prominent and awayFromPoc and separated and depthScore > bestScore
                                    bestIndex := rowIndex
                                    bestScore := depthScore
                            if bestIndex >= 0
                                array.push(selectedLvn, bestIndex)

                        // Fallback: lowest remaining shelves, never empty tails.
                        for pick = 0 to effectiveLvnCount - 1
                            if array.size(selectedLvn) < effectiveLvnCount
                                int bestIndex = -1
                                float bestScore = 1e20
                                for rowIndex = 1 to rowCount - 2
                                    float nodeVolume = array.get(smoothVolumes, rowIndex)
                                    bool belowThreshold = nodeVolume <= maxVolume * effectiveLvnThreshold * 0.01
                                    bool insideMarket = rowIndex > firstOccupied and rowIndex < lastOccupied
                                    bool awayFromPoc = math.abs(rowIndex - pocIndex) >= effectiveNodeSeparation
                                    bool separated = not f_is_near(selectedLvn, rowIndex, effectiveNodeSeparation) and not f_is_near(selectedHvn, rowIndex, effectiveNodeSeparation)
                                    if belowThreshold and insideMarket and awayFromPoc and separated and nodeVolume < bestScore
                                        bestIndex := rowIndex
                                        bestScore := nodeVolume
                                if bestIndex >= 0
                                    array.push(selectedLvn, bestIndex)

                    outHvnCount := array.size(selectedHvn)
                    outLvnCount := array.size(selectedLvn)

                    for nodeIndex in selectedHvn
                        int nodeLowIndex = math.max(0, nodeIndex - int(math.floor((nodeThicknessInput - 1) * 0.5)))
                        int nodeHighIndex = math.min(rowCount - 1, nodeLowIndex + nodeThicknessInput - 1)
                        if adaptiveNodeZonesInput
                            float expansionBoundary = array.get(smoothVolumes, nodeIndex) * 0.72
                            int hvnMaxThickness = autopilotInput ? 2 : nodeMaxThicknessInput
                            [expandedLow, expandedHigh] = f_node_bounds(smoothVolumes, nodeIndex, hvnMaxThickness, true, expansionBoundary)
                            nodeLowIndex := expandedLow
                            nodeHighIndex := expandedHigh
                        else
                            nodeLowIndex := math.max(0, nodeHighIndex - nodeThicknessInput + 1)
                        float zoneBottom = profileLow + nodeLowIndex * rowStep
                        float zoneTop = profileLow + (nodeHighIndex + 1.0) * rowStep
                        float nodePrice = profileLow + (nodeIndex + 0.5) * rowStep
                        float nodePct = array.get(smoothVolumes, nodeIndex) / maxVolume * 100.0
                        float hvnStrength = math.max(0.0, math.min(1.0, (nodePct - effectiveHvnThreshold) / math.max(1.0, 100.0 - effectiveHvnThreshold)))
                        int hvnWidthBars = math.max(2, int(math.round(maxProfileWidthBars * nodePct * 0.01)))
                        int hvnZoneLeftIndex = profileSideInput == SIDE_RIGHT ? profileRightIndex - hvnWidthBars : leftIndex
                        int hvnZoneRightIndex = (profileSideInput == SIDE_RIGHT ? profileRightIndex : leftIndex + hvnWidthBars) + nodeProjectionBars
                        int hvnFillTransparency = math.max(96, math.min(99, 98 - int(math.round(hvnStrength * 2.0))))
                        int hvnBorderTransparency = math.max(38, 62 - int(math.round(hvnStrength * 24.0)))
                        box hvnBox = box.new(left = hvnZoneLeftIndex, top = zoneTop,
                             right = hvnZoneRightIndex, bottom = zoneBottom, xloc = xloc.bar_index,
                             extend = extend.none,
                             border_color = color.new(hvnColorInput, hvnBorderTransparency), border_width = 1,
                             bgcolor = color.new(hvnColorInput, hvnFillTransparency))
                        array.push(outBoxes, hvnBox)
                        if na(outNearestHvn) or math.abs(close - nodePrice) < math.abs(close - outNearestHvn)
                            outNearestHvn := nodePrice
                        if isCurrent and showNodeLabelsInput
                            string hvnTooltip = "HVN — price acceptance zone\nRange: " + f_format_price(zoneBottom) + " — " + f_format_price(zoneTop) + "\nDensity: " + f_format_percent(nodePct) + " of POC\nExpectation: balance, slowdown or retest."
                            label hvnLabel = label.new(x = hvnZoneRightIndex, y = nodePrice,
                                 text = "HVN", xloc = xloc.bar_index, yloc = yloc.price,
                                 style = label.style_label_left, color = color.new(hvnColorInput, 24),
                                 textcolor = color.white, size = size.tiny, tooltip = hvnTooltip)
                            array.push(outLabels, hvnLabel)

                    for nodeIndex in selectedLvn
                        int nodeLowIndex = math.max(0, nodeIndex - int(math.floor((nodeThicknessInput - 1) * 0.5)))
                        int nodeHighIndex = math.min(rowCount - 1, nodeLowIndex + nodeThicknessInput - 1)
                        if adaptiveNodeZonesInput
                            float expansionBoundary = maxVolume * effectiveLvnThreshold * 0.01
                            int lvnMaxThickness = autopilotInput ? 1 : nodeMaxThicknessInput
                            [expandedLow, expandedHigh] = f_node_bounds(smoothVolumes, nodeIndex, lvnMaxThickness, false, expansionBoundary)
                            nodeLowIndex := expandedLow
                            nodeHighIndex := expandedHigh
                        else
                            nodeLowIndex := math.max(0, nodeHighIndex - nodeThicknessInput + 1)
                        float zoneBottom = profileLow + nodeLowIndex * rowStep
                        float zoneTop = profileLow + (nodeHighIndex + 1.0) * rowStep
                        float nodePrice = profileLow + (nodeIndex + 0.5) * rowStep
                        float nodePct = array.get(smoothVolumes, nodeIndex) / maxVolume * 100.0
                        float lvnStrength = math.max(0.0, math.min(1.0, 1.0 - nodePct / math.max(1.0, effectiveLvnThreshold)))
                        int lvnWidthBars = math.max(2, int(math.round(maxProfileWidthBars * nodePct * 0.01)))
                        int lvnZoneLeftIndex = profileSideInput == SIDE_RIGHT ? profileRightIndex - lvnWidthBars : leftIndex
                        int lvnZoneRightIndex = (profileSideInput == SIDE_RIGHT ? profileRightIndex : leftIndex + lvnWidthBars) + nodeProjectionBars
                        int lvnFillTransparency = math.max(97, math.min(99, 99 - int(math.round(lvnStrength * 2.0))))
                        int lvnBorderTransparency = math.max(40, 64 - int(math.round(lvnStrength * 24.0)))
                        box lvnBox = box.new(left = lvnZoneLeftIndex, top = zoneTop,
                             right = lvnZoneRightIndex, bottom = zoneBottom, xloc = xloc.bar_index,
                             extend = extend.none,
                             border_color = color.new(lvnColorInput, lvnBorderTransparency), border_width = 1,
                             bgcolor = color.new(lvnColorInput, lvnFillTransparency))
                        array.push(outBoxes, lvnBox)
                        if na(outNearestLvn) or math.abs(close - nodePrice) < math.abs(close - outNearestLvn)
                            outNearestLvn := nodePrice
                        if isCurrent and showNodeLabelsInput
                            string lvnTooltip = "LVN — price rejection zone\nRange: " + f_format_price(zoneBottom) + " — " + f_format_price(zoneTop) + "\nDensity: " + f_format_percent(nodePct) + " of POC\nExpectation: fast travel or sharp rejection."
                            label lvnLabel = label.new(x = lvnZoneRightIndex, y = nodePrice,
                                 text = "LVN", xloc = xloc.bar_index, yloc = yloc.price,
                                 style = label.style_label_left, color = color.new(lvnColorInput, 24),
                                 textcolor = color.white, size = size.tiny, tooltip = lvnTooltip)
                            array.push(outLabels, lvnLabel)

                // Histogram geometry uses bar indexes, not calendar time. This
                // keeps its visual width exact across weekends and session gaps.
                if showProfileInput
                    bool renderUpDown = isCurrent and profileViewInput == VIEW_UPDOWN
                    bool renderDelta = isCurrent and profileViewInput == VIEW_DELTA
                    for rowIndex = 0 to rowCount - 1
                        float rowVolume = array.get(rowVolumes, rowIndex)
                        float rowUpVolume = array.get(upVolumes, rowIndex)
                        float rowDownVolume = array.get(downVolumes, rowIndex)
                        float rowDelta = rowUpVolume - rowDownVolume
                        float widthBasis = renderDelta ? math.abs(rowDelta) : rowVolume
                        float maximumBasis = renderDelta ? maxAbsDelta : maxVolume
                        if widthBasis > 0.0 and maximumBasis > 0.0
                            float relativeWidth = widthBasis / maximumBasis
                            float relativeTotal = rowVolume / maxVolume
                            int rowWidthBars = math.max(1, int(math.round(maxProfileWidthBars * relativeWidth)))
                            int boxLeftIndex = profileSideInput == SIDE_RIGHT ? profileRightIndex - rowWidthBars : leftIndex
                            int boxRightIndex = profileSideInput == SIDE_RIGHT ? profileRightIndex : leftIndex + rowWidthBars
                            float rowInset = rowStep * rowGapPctInput * 0.005
                            float rowBottom = profileLow + rowIndex * rowStep + rowInset
                            float rowTop = profileLow + (rowIndex + 1.0) * rowStep - rowInset
                            bool isPocRow = rowIndex == pocIndex
                            bool isValueRow = rowIndex >= valueLowIndex and rowIndex <= valueHighIndex
                            int baseTransparency = isValueRow ? valueAreaTransparencyInput : outsideTransparencyInput
                            int gradientBoost = gradientOpacityInput ? int(math.round((1.0 - relativeTotal) * 9.0)) : 0
                            int rowTransparency = math.min(96, baseTransparency + gradientBoost)
                            color rowBorderColor = isPocRow ? color.new(pocColorInput, 8) : na
                            int rowBorderWidth = isPocRow ? 1 : 0
                            float deltaStrength = math.abs(rowDelta) / math.max(rowVolume, 1e-10)
                            bool directionalView = renderUpDown or renderDelta
                            color directionalColor = deltaStrength < 0.04 ? outsideColorInput : rowDelta >= 0.0 ? upVolumeColorInput : downVolumeColorInput
                            color baseRowColor = isPocRow ? pocColorInput : isValueRow ? valueAreaColorInput : outsideColorInput
                            int finalTransparency = isPocRow ? math.max(12, rowTransparency - 28) : rowTransparency
                            box volumeBox = box.new(left = boxLeftIndex, top = rowTop,
                                 right = boxRightIndex, bottom = rowBottom, xloc = xloc.bar_index,
                                 border_color = rowBorderColor, border_width = rowBorderWidth,
                                 bgcolor = color.new(baseRowColor, finalTransparency))
                            array.push(outBoxes, volumeBox)
                            if directionalView and deltaStrength >= 0.08 and not isPocRow
                                // One aligned rail at the profile anchor replaces
                                // scattered coloured tips and keeps the silhouette clean.
                                int railLeftIndex = profileSideInput == SIDE_RIGHT ? math.max(boxLeftIndex, boxRightIndex - 1) : boxLeftIndex
                                int railRightIndex = profileSideInput == SIDE_RIGHT ? boxRightIndex : math.min(boxRightIndex, boxLeftIndex + 1)
                                int railTransparency = math.max(16, math.min(68, int(math.round(58.0 - deltaStrength * 40.0 + gradientBoost * 0.30))))
                                int railBorderTransparency = math.max(0, railTransparency - 14)
                                box deltaRail = box.new(left = railLeftIndex, top = rowTop,
                                     right = railRightIndex, bottom = rowBottom, xloc = xloc.bar_index,
                                     border_color = color.new(directionalColor, railBorderTransparency), border_width = 1,
                                     bgcolor = color.new(directionalColor, railTransparency))
                                array.push(outBoxes, deltaRail)

                if showLevelsInput
                    if isCurrent
                        line pocGlowLine = line.new(x1 = leftTime, y1 = pocPrice, x2 = effectiveRightTime, y2 = pocPrice,
                             xloc = xloc.bar_time, extend = extendLevelsInput ? extend.right : extend.none,
                             color = color.new(pocColorInput, 82), style = line.style_solid, width = 8)
                        line vahGlowLine = line.new(x1 = leftTime, y1 = vahPrice, x2 = effectiveRightTime, y2 = vahPrice,
                             xloc = xloc.bar_time, extend = extendLevelsInput ? extend.right : extend.none,
                             color = color.new(vahColorInput, 88), style = line.style_solid, width = 6)
                        line valGlowLine = line.new(x1 = leftTime, y1 = valPrice, x2 = effectiveRightTime, y2 = valPrice,
                             xloc = xloc.bar_time, extend = extendLevelsInput ? extend.right : extend.none,
                             color = color.new(valColorInput, 88), style = line.style_solid, width = 6)
                        array.push(outLines, pocGlowLine)
                        array.push(outLines, vahGlowLine)
                        array.push(outLines, valGlowLine)

                    line pocLine = line.new(x1 = leftTime, y1 = pocPrice, x2 = effectiveRightTime, y2 = pocPrice,
                         xloc = xloc.bar_time, extend = isCurrent and extendLevelsInput ? extend.right : extend.none,
                         color = pocColorInput, style = line.style_solid, width = 2)
                    line vahLine = line.new(x1 = leftTime, y1 = vahPrice, x2 = effectiveRightTime, y2 = vahPrice,
                         xloc = xloc.bar_time, extend = isCurrent and extendLevelsInput ? extend.right : extend.none,
                         color = vahColorInput, style = line.style_dashed, width = 2)
                    line valLine = line.new(x1 = leftTime, y1 = valPrice, x2 = effectiveRightTime, y2 = valPrice,
                         xloc = xloc.bar_time, extend = isCurrent and extendLevelsInput ? extend.right : extend.none,
                         color = valColorInput, style = line.style_dashed, width = 2)
                    array.push(outLines, pocLine)
                    array.push(outLines, vahLine)
                    array.push(outLines, valLine)

                    if isCurrent and showLevelLabelsInput
                        float pocDistancePct = close == 0.0 ? na : (close / pocPrice - 1.0) * 100.0
                        string pocTooltip = "POC — maximum accepted volume\nPrice: " + f_format_price(pocPrice) + "\nRow volume: " + f_format_volume(maxVolume) + " (" + f_format_percent(pocSharePct) + " of profile)\nPrice distance: " + f_format_percent(pocDistancePct)
                        string vahTooltip = "VAH — upper Value Area boundary\nPrice: " + f_format_price(vahPrice) + "\nActual VA: " + f_format_percent(actualVaPct) + "\nAbove VAH, the market enters price discovery."
                        string valTooltip = "VAL — lower Value Area boundary\nPrice: " + f_format_price(valPrice) + "\nActual VA: " + f_format_percent(actualVaPct) + "\nBelow VAL, the market enters price discovery."
                        label pocLabel = label.new(x = effectiveRightTime, y = pocPrice,
                             text = "POC  " + f_format_price(pocPrice), xloc = xloc.bar_time, yloc = yloc.price,
                             style = label.style_label_left, color = pocColorInput,
                             textcolor = color.white, size = size.small, tooltip = pocTooltip)
                        label vahLabel = label.new(x = effectiveRightTime, y = vahPrice,
                             text = "VAH  " + f_format_price(vahPrice), xloc = xloc.bar_time, yloc = yloc.price,
                             style = label.style_label_left, color = color.new(vahColorInput, 12),
                             textcolor = color.white, size = size.tiny, tooltip = vahTooltip)
                        label valLabel = label.new(x = effectiveRightTime, y = valPrice,
                             text = "VAL  " + f_format_price(valPrice), xloc = xloc.bar_time, yloc = yloc.price,
                             style = label.style_label_left, color = color.new(valColorInput, 12),
                             textcolor = color.white, size = size.tiny, tooltip = valTooltip)
                        array.push(outLabels, pocLabel)
                        array.push(outLabels, vahLabel)
                        array.push(outLabels, valLabel)

                outPoc := pocPrice
                outVah := vahPrice
                outVal := valPrice
                outTotalVolume := totalVolume
                outRowStep := rowStep
                outRowCount := rowCount
                outSampleCount := validSamples
                outUpVolume := totalUpVolume
                outDownVolume := totalDownVolume
                outDeltaPct := deltaPct
                outActualVaPct := actualVaPct
                outPocPosition := pocPosition

    [outPoc, outVah, outVal, outTotalVolume, outRowStep, outRowCount, outSampleCount,
     outUpVolume, outDownVolume, outDeltaPct, outActualVaPct, outPocPosition,
     outNearestHvn, outNearestLvn, outHvnCount, outLvnCount]

// ─────────────────────────────────────────────────────────────────────────────
// Lower-timeframe request. Invalid or unavailable LTF data never stops the
// script; the engine falls back to the complete chart-bar sample set.
// ─────────────────────────────────────────────────────────────────────────────
[ltfOpenData, ltfHighData, ltfLowData, ltfCloseData, ltfVolumeData] = request.security_lower_tf(
     syminfo.tickerid, effectiveLowerTf, [open, high, low, close, volume],
     ignore_invalid_timeframe = true, calc_bars_count = 5000)

float lowerTfSeconds = timeframe.in_seconds(effectiveLowerTf)
bool lowerTfIsValid = not na(lowerTfSeconds) and not na(chartSeconds) and lowerTfSeconds <= chartSeconds

// ─────────────────────────────────────────────────────────────────────────────
// Range state and sampling
// ─────────────────────────────────────────────────────────────────────────────
bool inSession = not na(time(timeframe.period, sessionHoursInput))
bool previousInSession = bar_index > 0 ? inSession[1] : false
bool newTradingDay = bar_index > 0 and time_tradingday != time_tradingday[1]
bool newSession = inSession and (not previousInSession or newTradingDay)
bool sessionRelevant = bar_index >= math.max(0, last_bar_index - sessionLookbackBarsInput)

if rangeModeInput == MODE_SESSION and sessionRelevant and newSession
    if array.size(barOpenSamples) > 0 and sessionStartedClean
        bool historyUseLtf = effectiveUseLtf and lowerTfIsValid and not ltfIncomplete and not ltfOverflow and array.size(ltfOpenSamples) > 0
        bool historyCanRender = historyUseLtf or not barOverflow
        if historyCanRender
            int boxesBefore = array.size(historyBoxes)
            int linesBefore = array.size(historyLines)
            int labelsBefore = array.size(historyLabels)
            [historyPoc, historyVah, historyVal, historyVolume, historyStep, historyRows, historySamples,
             historyUp, historyDown, historyDelta, historyVaPct, historyPocPosition,
             historyNearestHvn, historyNearestLvn, historyHvnCount, historyLvnCount] = f_render_profile(
                 historyUseLtf, rangeLeftTime, rangeRightTime, rangeLeftIndex, rangeRightIndex, false, false,
                 historyBoxes, historyLines, historyLabels)
            array.push(historyBoxCounts, array.size(historyBoxes) - boxesBefore)
            array.push(historyLineCounts, array.size(historyLines) - linesBefore)
            array.push(historyLabelCounts, array.size(historyLabels) - labelsBefore)
            f_trim_history(math.max(0, sessionProfilesInput - 1))

    f_clear_samples()
    rangeLeftTime := na
    rangeRightTime := na
    rangeLeftIndex := na
    rangeRightIndex := na
    ltfIncomplete := false
    ltfOverflow := false
    barOverflow := false
    sessionStartedClean := true

int fixedFrom = math.min(fixedStartInput, fixedEndInput)
int fixedTo = math.max(fixedStartInput, fixedEndInput)

bool inSelectedRange = switch rangeModeInput
    MODE_VISIBLE => time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    MODE_FIXED   => time >= fixedFrom and time <= fixedTo
    => sessionRelevant and inSession

bool includeBar = inSelectedRange and (not effectiveConfirmedOnly or barstate.isconfirmed)

if includeBar
    int sampleRightTime = na(time_close) ? time + chartBarMs : time_close
    rangeLeftTime := na(rangeLeftTime) ? time : math.min(rangeLeftTime, time)
    rangeRightTime := na(rangeRightTime) ? sampleRightTime : math.max(rangeRightTime, sampleRightTime)
    rangeLeftIndex := na(rangeLeftIndex) ? bar_index : math.min(rangeLeftIndex, bar_index)
    rangeRightIndex := na(rangeRightIndex) ? bar_index : math.max(rangeRightIndex, bar_index)

    bool validChartSample = not na(open) and not na(high) and not na(low) and not na(close) and not na(volume) and volume > 0.0
    if validChartSample
        if array.size(barOpenSamples) < maxProfileBarsInput
            array.push(barOpenSamples, open)
            array.push(barHighSamples, high)
            array.push(barLowSamples, low)
            array.push(barCloseSamples, close)
            array.push(barVolumeSamples, volume)
        else
            barOverflow := true

    if effectiveUseLtf
        int intrabarCount = lowerTfIsValid and not na(ltfOpenData) ? array.size(ltfOpenData) : 0
        if intrabarCount == 0
            ltfIncomplete := true
        else if array.size(ltfOpenSamples) + intrabarCount > maxLtfSamplesInput
            ltfOverflow := true
        else if not ltfOverflow
            int validIntrabars = 0
            for intrabarIndex = 0 to intrabarCount - 1
                float intrabarOpen = array.get(ltfOpenData, intrabarIndex)
                float intrabarHigh = array.get(ltfHighData, intrabarIndex)
                float intrabarLow = array.get(ltfLowData, intrabarIndex)
                float intrabarClose = array.get(ltfCloseData, intrabarIndex)
                float intrabarVolume = array.get(ltfVolumeData, intrabarIndex)
                bool validIntrabar = not na(intrabarOpen) and not na(intrabarHigh) and not na(intrabarLow) and not na(intrabarClose) and not na(intrabarVolume) and intrabarVolume > 0.0
                if validIntrabar
                    array.push(ltfOpenSamples, intrabarOpen)
                    array.push(ltfHighSamples, intrabarHigh)
                    array.push(ltfLowSamples, intrabarLow)
                    array.push(ltfCloseSamples, intrabarClose)
                    array.push(ltfVolumeSamples, intrabarVolume)
                    validIntrabars += 1
            if validIntrabars == 0
                ltfIncomplete := true

// ─────────────────────────────────────────────────────────────────────────────
// Smart Liquidity Pools
// Confirmed equal swing highs/lows only. Candidate pools and active zones are
// invalidated when price sweeps them; no historical object is kept afterwards.
// ─────────────────────────────────────────────────────────────────────────────
float liquidityAtr = ta.atr(14)
float liquidityVolumeMean = ta.sma(volume, 20)
float confirmedPivotHigh = ta.pivothigh(high, effectiveLiquidityPivot, effectiveLiquidityPivot)
float confirmedPivotLow = ta.pivotlow(low, effectiveLiquidityPivot, effectiveLiquidityPivot)
bool newBslEvent = false
bool newSslEvent = false
bool collectedBslEvent = false
bool collectedSslEvent = false

if showLiquidityPoolsInput and barstate.isconfirmed
    // Remove swept or stale unconfirmed candidates first. This prevents two
    // old pivots from creating a zone after their liquidity was already taken.
    if array.size(highCandidatePrices) > 0
        int highCandidateCount = array.size(highCandidatePrices)
        for offset = 0 to highCandidateCount - 1
            int candidateIndex = highCandidateCount - 1 - offset
            float candidatePrice = array.get(highCandidatePrices, candidateIndex)
            float candidateHalf = array.get(highCandidateHalves, candidateIndex)
            int candidateBar = array.get(highCandidateIndices, candidateIndex)
            bool expired = bar_index - candidateBar > liquidityLookbackInput
            bool swept = bar_index > candidateBar + effectiveLiquidityPivot and high >= candidatePrice + candidateHalf
            if expired or swept
                array.remove(highCandidatePrices, candidateIndex)
                array.remove(highCandidateHalves, candidateIndex)
                array.remove(highCandidateEvidence, candidateIndex)
                array.remove(highCandidateIndices, candidateIndex)

    if array.size(lowCandidatePrices) > 0
        int lowCandidateCount = array.size(lowCandidatePrices)
        for offset = 0 to lowCandidateCount - 1
            int candidateIndex = lowCandidateCount - 1 - offset
            float candidatePrice = array.get(lowCandidatePrices, candidateIndex)
            float candidateHalf = array.get(lowCandidateHalves, candidateIndex)
            int candidateBar = array.get(lowCandidateIndices, candidateIndex)
            bool expired = bar_index - candidateBar > liquidityLookbackInput
            bool swept = bar_index > candidateBar + effectiveLiquidityPivot and low <= candidatePrice - candidateHalf
            if expired or swept
                array.remove(lowCandidatePrices, candidateIndex)
                array.remove(lowCandidateHalves, candidateIndex)
                array.remove(lowCandidateEvidence, candidateIndex)
                array.remove(lowCandidateIndices, candidateIndex)

    // State machine: FRESH -> TESTED -> SWEPT. A partial entry weakens the
    // presentation; a confirmed full sweep deletes every drawing immediately.
    if array.size(liquidityCenters) > 0
        int activeZoneCount = array.size(liquidityCenters)
        for offset = 0 to activeZoneCount - 1
            int zoneIndex = activeZoneCount - 1 - offset
            bool isBuySide = array.get(liquidityIsBuySide, zoneIndex)
            float zoneTop = array.get(liquidityTops, zoneIndex)
            float zoneBottom = array.get(liquidityBottoms, zoneIndex)
            int createdBar = array.get(liquidityCreatedBars, zoneIndex)
            bool fullSweep = isBuySide ? high >= zoneTop : low <= zoneBottom
            bool firstTouch = isBuySide ? high >= zoneBottom : low <= zoneTop
            bool collected = bar_index > createdBar and (liquiditySweepModeInput == SWEEP_FULL ? fullSweep : firstTouch)
            bool expired = bar_index - createdBar > liquidityLookbackInput
            if collected or expired
                if collected
                    collectedBslEvent := collectedBslEvent or isBuySide
                    collectedSslEvent := collectedSslEvent or not isBuySide
                f_delete_liquidity_zone(zoneIndex)
            else
                bool tested = array.get(liquidityTested, zoneIndex)
                if bar_index > createdBar and firstTouch and not fullSweep and liquiditySweepModeInput == SWEEP_FULL
                    tested := true
                    array.set(liquidityTested, zoneIndex, true)

                float zoneCentre = array.get(liquidityCenters, zoneIndex)
                float zoneQuality = array.get(liquidityQualities, zoneIndex)
                int zoneTouches = array.get(liquidityTouches, zoneIndex)
                color zoneColor = isBuySide ? buyLiquidityColorInput : sellLiquidityColorInput
                float safeLiquidityAtr = math.max(nz(liquidityAtr, syminfo.mintick * 10.0), syminfo.mintick)
                float distanceAtr = math.abs(zoneCentre - close) / safeLiquidityAtr
                bool zoneVisible = distanceAtr <= effectiveLiquidityVisibilityAtr
                int glowTransparency = not zoneVisible ? 100 : tested ? 98 : 96
                int coreTransparency = not zoneVisible ? 100 : tested ? 94 : 88
                int borderTransparency = not zoneVisible ? 100 : tested ? 55 : 18
                int lineTransparency = not zoneVisible ? 100 : tested ? 48 : 4
                int labelTransparency = not zoneVisible ? 100 : tested ? 50 : 18

                box glowBox = array.get(liquidityGlowBoxes, zoneIndex)
                box coreBox = array.get(liquidityCoreBoxes, zoneIndex)
                line coreLine = array.get(liquidityCoreLines, zoneIndex)
                label poolLabel = array.get(liquidityPoolLabels, zoneIndex)
                box.set_right(glowBox, bar_index + 1)
                box.set_bgcolor(glowBox, color.new(zoneColor, glowTransparency))
                box.set_right(coreBox, bar_index + 1)
                box.set_border_color(coreBox, color.new(zoneColor, borderTransparency))
                box.set_bgcolor(coreBox, color.new(zoneColor, coreTransparency))
                line.set_x2(coreLine, bar_index + 1)
                line.set_color(coreLine, color.new(zoneColor, lineTransparency))
                label.set_x(poolLabel, bar_index + 1)
                label.set_text(poolLabel, zoneVisible and showLiquidityLabelsInput ? f_liquidity_text(isBuySide, zoneQuality, tested) : "")
                label.set_color(poolLabel, color.new(zoneColor, labelTransparency))
                label.set_tooltip(poolLabel, f_liquidity_tooltip(isBuySide, zoneBottom, zoneTop, zoneQuality, zoneTouches, tested))

    // BSL candidate: a confirmed swing high with measurable volume and wick.
    if not na(confirmedPivotHigh)
        int pivotIndex = bar_index - effectiveLiquidityPivot
        float pivotAtr = nz(liquidityAtr[effectiveLiquidityPivot], syminfo.mintick * 10.0)
        float pivotHalf = math.max(syminfo.mintick * 2.0, pivotAtr * effectiveLiquidityAtrWidth)
        float pivotRange = math.max(syminfo.mintick, high[effectiveLiquidityPivot] - low[effectiveLiquidityPivot])
        float pivotWick = high[effectiveLiquidityPivot] - math.max(open[effectiveLiquidityPivot], close[effectiveLiquidityPivot])
        float wickRatio = math.max(0.0, pivotWick / pivotRange)
        float volumeRatio = volume[effectiveLiquidityPivot] / math.max(1e-10, nz(liquidityVolumeMean[effectiveLiquidityPivot], volume[effectiveLiquidityPivot]))
        float evidence = math.min(25.0, math.max(0.0, volumeRatio / 1.5 * 25.0)) + math.min(20.0, wickRatio / 0.45 * 20.0)
        int matchedCandidate = -1
        float bestDistance = 1e20
        if array.size(highCandidatePrices) > 0
            for candidateIndex = 0 to array.size(highCandidatePrices) - 1
                float oldPrice = array.get(highCandidatePrices, candidateIndex)
                float oldHalf = array.get(highCandidateHalves, candidateIndex)
                int oldIndex = array.get(highCandidateIndices, candidateIndex)
                int separation = pivotIndex - oldIndex
                float distance = math.abs(confirmedPivotHigh - oldPrice)
                bool validAge = separation >= effectiveLiquidityPivot * 2 and separation <= liquidityLookbackInput
                bool equalHigh = distance <= math.max(pivotHalf, oldHalf) * 1.25
                if validAge and equalHigh and distance < bestDistance
                    matchedCandidate := candidateIndex
                    bestDistance := distance

        if matchedCandidate >= 0
            float oldPrice = array.get(highCandidatePrices, matchedCandidate)
            float oldHalf = array.get(highCandidateHalves, matchedCandidate)
            float oldEvidence = array.get(highCandidateEvidence, matchedCandidate)
            int oldIndex = array.get(highCandidateIndices, matchedCandidate)
            int separation = pivotIndex - oldIndex
            float spacingScore = math.min(10.0, separation / math.max(1.0, effectiveLiquidityPivot * 8.0) * 10.0)
            float quality = math.min(100.0, 45.0 + (evidence + oldEvidence) * 0.5 + spacingScore)
            if quality >= effectiveLiquidityQuality
                float centre = (confirmedPivotHigh + oldPrice) * 0.5
                f_upsert_liquidity_zone(true, centre, math.max(pivotHalf, oldHalf), quality, bar_index, maxLiquidityZonesInput)
                newBslEvent := true

        array.push(highCandidatePrices, confirmedPivotHigh)
        array.push(highCandidateHalves, pivotHalf)
        array.push(highCandidateEvidence, evidence)
        array.push(highCandidateIndices, pivotIndex)
        if array.size(highCandidatePrices) > 24
            array.shift(highCandidatePrices)
            array.shift(highCandidateHalves)
            array.shift(highCandidateEvidence)
            array.shift(highCandidateIndices)

    // SSL candidate: mirrored confirmed swing low.
    if not na(confirmedPivotLow)
        int pivotIndex = bar_index - effectiveLiquidityPivot
        float pivotAtr = nz(liquidityAtr[effectiveLiquidityPivot], syminfo.mintick * 10.0)
        float pivotHalf = math.max(syminfo.mintick * 2.0, pivotAtr * effectiveLiquidityAtrWidth)
        float pivotRange = math.max(syminfo.mintick, high[effectiveLiquidityPivot] - low[effectiveLiquidityPivot])
        float pivotWick = math.min(open[effectiveLiquidityPivot], close[effectiveLiquidityPivot]) - low[effectiveLiquidityPivot]
        float wickRatio = math.max(0.0, pivotWick / pivotRange)
        float volumeRatio = volume[effectiveLiquidityPivot] / math.max(1e-10, nz(liquidityVolumeMean[effectiveLiquidityPivot], volume[effectiveLiquidityPivot]))
        float evidence = math.min(25.0, math.max(0.0, volumeRatio / 1.5 * 25.0)) + math.min(20.0, wickRatio / 0.45 * 20.0)
        int matchedCandidate = -1
        float bestDistance = 1e20
        if array.size(lowCandidatePrices) > 0
            for candidateIndex = 0 to array.size(lowCandidatePrices) - 1
                float oldPrice = array.get(lowCandidatePrices, candidateIndex)
                float oldHalf = array.get(lowCandidateHalves, candidateIndex)
                int oldIndex = array.get(lowCandidateIndices, candidateIndex)
                int separation = pivotIndex - oldIndex
                float distance = math.abs(confirmedPivotLow - oldPrice)
                bool validAge = separation >= effectiveLiquidityPivot * 2 and separation <= liquidityLookbackInput
                bool equalLow = distance <= math.max(pivotHalf, oldHalf) * 1.25
                if validAge and equalLow and distance < bestDistance
                    matchedCandidate := candidateIndex
                    bestDistance := distance

        if matchedCandidate >= 0
            float oldPrice = array.get(lowCandidatePrices, matchedCandidate)
            float oldHalf = array.get(lowCandidateHalves, matchedCandidate)
            float oldEvidence = array.get(lowCandidateEvidence, matchedCandidate)
            int oldIndex = array.get(lowCandidateIndices, matchedCandidate)
            int separation = pivotIndex - oldIndex
            float spacingScore = math.min(10.0, separation / math.max(1.0, effectiveLiquidityPivot * 8.0) * 10.0)
            float quality = math.min(100.0, 45.0 + (evidence + oldEvidence) * 0.5 + spacingScore)
            if quality >= effectiveLiquidityQuality
                float centre = (confirmedPivotLow + oldPrice) * 0.5
                f_upsert_liquidity_zone(false, centre, math.max(pivotHalf, oldHalf), quality, bar_index, maxLiquidityZonesInput)
                newSslEvent := true

        array.push(lowCandidatePrices, confirmedPivotLow)
        array.push(lowCandidateHalves, pivotHalf)
        array.push(lowCandidateEvidence, evidence)
        array.push(lowCandidateIndices, pivotIndex)
        if array.size(lowCandidatePrices) > 24
            array.shift(lowCandidatePrices)
            array.shift(lowCandidateHalves)
            array.shift(lowCandidateEvidence)
            array.shift(lowCandidateIndices)

// ─────────────────────────────────────────────────────────────────────────────
// Render active profile
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    f_delete_drawings(currentBoxes, currentLines, currentLabels)

    bool currentUseLtf = effectiveUseLtf and lowerTfIsValid and not ltfIncomplete and not ltfOverflow and array.size(ltfOpenSamples) > 0
    bool currentCanRender = currentUseLtf or not barOverflow
    if currentCanRender
        [renderedPoc, renderedVah, renderedVal, renderedVolume, renderedStep, renderedRows, renderedSamples,
         renderedUp, renderedDown, renderedDelta, renderedVaPct, renderedPocPosition,
         renderedNearestHvn, renderedNearestLvn, renderedHvnCount, renderedLvnCount] = f_render_profile(
             currentUseLtf, rangeLeftTime, rangeRightTime, rangeLeftIndex, rangeRightIndex, true, true,
             currentBoxes, currentLines, currentLabels)

        currentPoc := renderedPoc
        currentVah := renderedVah
        currentVal := renderedVal
        currentTotalVolume := renderedVolume
        currentRowStep := renderedStep
        currentRowCount := renderedRows
        currentSampleCount := renderedSamples
        currentUpVolume := renderedUp
        currentDownVolume := renderedDown
        currentDeltaPct := renderedDelta
        currentActualVaPct := renderedVaPct
        currentPocPosition := renderedPocPosition
        currentNearestHvn := renderedNearestHvn
        currentNearestLvn := renderedNearestLvn
        currentHvnCount := renderedHvnCount
        currentLvnCount := renderedLvnCount
    else
        currentPoc := na
        currentVah := na
        currentVal := na
        currentTotalVolume := na
        currentRowStep := na
        currentRowCount := na
        currentSampleCount := na
        currentUpVolume := na
        currentDownVolume := na
        currentDeltaPct := na
        currentActualVaPct := na
        currentPocPosition := na
        currentNearestHvn := na
        currentNearestLvn := na
        currentHvnCount := 0
        currentLvnCount := 0

// Data Window values do not add lines to the chart.
plot(currentPoc, "POC", color = pocColorInput, display = display.data_window)
plot(currentVah, "VAH", color = vahColorInput, display = display.data_window)
plot(currentVal, "VAL", color = valColorInput, display = display.data_window)
plot(currentNearestHvn, "Nearest HVN", color = hvnColorInput, display = display.data_window)
plot(currentNearestLvn, "Nearest LVN", color = lvnColorInput, display = display.data_window)
plot(currentDeltaPct, "Up/Down Delta, %", color = currentDeltaPct >= 0.0 ? upVolumeColorInput : downVolumeColorInput, display = display.data_window)

// Alert-ready auction events. They create no extra markers on the chart.
bool confirmedProfileEvent = barstate.isconfirmed and not na(currentPoc) and not na(currentVah) and not na(currentVal)
bool pocTouchEvent = confirmedProfileEvent and low <= currentPoc and high >= currentPoc
bool vahBreakEvent = confirmedProfileEvent and ta.crossover(close, currentVah)
bool valBreakEvent = confirmedProfileEvent and ta.crossunder(close, currentVal)
bool returnToValueEvent = confirmedProfileEvent and close <= currentVah and close >= currentVal and (close[1] > currentVah[1] or close[1] < currentVal[1])

alertcondition(pocTouchEvent, "EVA • POC touch", "{{ticker}}: price touched POC at {{close}}")
alertcondition(vahBreakEvent, "EVA • VAH breakout", "{{ticker}}: confirmed breakout above VAH at {{close}}")
alertcondition(valBreakEvent, "EVA • VAL breakdown", "{{ticker}}: confirmed breakdown below VAL at {{close}}")
alertcondition(returnToValueEvent, "EVA • Return to Value", "{{ticker}}: price returned inside Value Area at {{close}}")
alertcondition(newBslEvent, "EVA • New BSL pool", "{{ticker}}: a quality BSL pool was confirmed above equal swing highs")
alertcondition(newSslEvent, "EVA • New SSL pool", "{{ticker}}: a quality SSL pool was confirmed below equal swing lows")
alertcondition(collectedBslEvent, "EVA • BSL collected", "{{ticker}}: buy-side liquidity was collected; the BSL pool was deleted")
alertcondition(collectedSslEvent, "EVA • SSL collected", "{{ticker}}: sell-side liquidity was collected; the SSL pool was deleted")

// ─────────────────────────────────────────────────────────────────────────────
// Premium auction dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 17,
     bgcolor = color.new(color.rgb(12, 17, 28), 8),
     frame_color = color.new(color.rgb(91, 107, 140), 55), frame_width = 1,
     border_color = color.new(color.rgb(91, 107, 140), 75), border_width = 1)

if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 1, 0)

if barstate.islast
    if showDashboardInput
        bool dashboardUseLtf = effectiveUseLtf and lowerTfIsValid and not ltfIncomplete and not ltfOverflow and array.size(ltfOpenSamples) > 0
        string sourceText = dashboardUseLtf ? "LTF " + effectiveLowerTf : "Chart candles"
        string rangeText = str.tostring(array.size(barOpenSamples)) + " bars • " + str.tostring(int(nz(currentSampleCount, 0))) + " samples"
        string rowsText = na(currentRowCount) ? "—" : str.tostring(int(currentRowCount)) + " × " + f_format_price(currentRowStep)
        string statusText = barOverflow and not dashboardUseLtf ? "⚠ Range limit exceeded" : na(currentPoc) ? "No volume data" : effectiveUseLtf and (ltfOverflow or ltfIncomplete or not lowerTfIsValid) ? "Complete-data fallback" : effectiveConfirmedOnly ? "Closed bars" : "Developing / auto"
        color statusColor = na(currentPoc) or barOverflow ? color.rgb(255, 105, 105) : effectiveUseLtf and (ltfOverflow or ltfIncomplete or not lowerTfIsValid) ? color.rgb(255, 190, 85) : color.rgb(79, 224, 177)
        float upSharePct = na(currentTotalVolume) or currentTotalVolume <= 0.0 ? na : currentUpVolume / currentTotalVolume * 100.0
        string compositionText = na(upSharePct) ? "—" : f_format_percent(upSharePct) + " / " + f_format_percent(100.0 - upSharePct)
        color deltaColor = na(currentDeltaPct) ? color.white : currentDeltaPct >= 0.0 ? upVolumeColorInput : downVolumeColorInput
        string deltaText = na(currentDeltaPct) ? "—" : (currentDeltaPct > 0.0 ? "+" : "") + f_format_percent(currentDeltaPct)
        float pocDistancePct = na(currentPoc) or currentPoc == 0.0 ? na : (close / currentPoc - 1.0) * 100.0
        string pocText = f_format_price(currentPoc) + (na(pocDistancePct) ? "" : " • " + (pocDistancePct > 0.0 ? "+" : "") + f_format_percent(pocDistancePct))
        string valueBoundsText = f_format_price(currentVal) + " — " + f_format_price(currentVah)
        string vaText = f_format_percent(currentActualVaPct) + " / target " + f_format_percent(valueAreaPctInput)
        string nodesText = "H " + f_format_price(currentNearestHvn) + " • L " + f_format_price(currentNearestLvn)
        string structureText = na(currentPocPosition) ? "—" : currentPocPosition > 0.62 ? "Upper concentration" : currentPocPosition < 0.38 ? "Lower concentration" : "Balanced"
        string auctionText = na(currentPoc) ? "NO PROFILE" : close > currentVah ? "ABOVE VAH • DISCOVERY ↑" : close < currentVal ? "BELOW VAL • DISCOVERY ↓" : "INSIDE VA • BALANCE"
        color auctionColor = na(currentPoc) ? color.rgb(255, 105, 105) : close > currentVah ? upVolumeColorInput : close < currentVal ? downVolumeColorInput : color.rgb(90, 176, 255)
        float nearestBsl = na
        float nearestBslQuality = na
        float nearestBslDistance = 1e20
        bool nearestBslTested = false
        float nearestSsl = na
        float nearestSslQuality = na
        float nearestSslDistance = 1e20
        bool nearestSslTested = false
        if array.size(liquidityCenters) > 0
            for zoneIndex = 0 to array.size(liquidityCenters) - 1
                float zoneCentre = array.get(liquidityCenters, zoneIndex)
                float zoneQuality = array.get(liquidityQualities, zoneIndex)
                bool zoneTested = array.get(liquidityTested, zoneIndex)
                float zoneDistance = math.abs(close - zoneCentre)
                if array.get(liquidityIsBuySide, zoneIndex) and zoneDistance < nearestBslDistance
                    nearestBsl := zoneCentre
                    nearestBslQuality := zoneQuality
                    nearestBslDistance := zoneDistance
                    nearestBslTested := zoneTested
                else if not array.get(liquidityIsBuySide, zoneIndex) and zoneDistance < nearestSslDistance
                    nearestSsl := zoneCentre
                    nearestSslQuality := zoneQuality
                    nearestSslDistance := zoneDistance
                    nearestSslTested := zoneTested
        float safeDashboardAtr = math.max(nz(liquidityAtr, syminfo.mintick * 10.0), syminfo.mintick)
        float bslDistanceAtr = na(nearestBsl) ? na : nearestBslDistance / safeDashboardAtr
        float sslDistanceAtr = na(nearestSsl) ? na : nearestSslDistance / safeDashboardAtr
        bool bslInWorkRadius = not na(bslDistanceAtr) and bslDistanceAtr <= effectiveLiquidityVisibilityAtr
        bool sslInWorkRadius = not na(sslDistanceAtr) and sslDistanceAtr <= effectiveLiquidityVisibilityAtr
        string bslStateText = not bslInWorkRadius ? "OFF" : nearestBslTested ? "TESTED" : "FRESH"
        string sslStateText = not sslInWorkRadius ? "OFF" : nearestSslTested ? "TESTED" : "FRESH"
        string bslText = na(nearestBsl) ? "—" : f_format_price(nearestBsl) + " • " + str.tostring(bslDistanceAtr, "#.1") + "A • Q" + str.tostring(int(math.round(nearestBslQuality))) + " " + bslStateText
        string sslText = na(nearestSsl) ? "—" : f_format_price(nearestSsl) + " • " + str.tostring(sslDistanceAtr, "#.1") + "A • Q" + str.tostring(int(math.round(nearestSslQuality))) + " " + sslStateText
        color bslPanelColor = na(nearestBsl) or not bslInWorkRadius ? color.rgb(125, 137, 160) : buyLiquidityColorInput
        color sslPanelColor = na(nearestSsl) or not sslInWorkRadius ? color.rgb(125, 137, 160) : sellLiquidityColorInput
        string autopilotText = autopilotInput ? "ACTIVE • LTF " + effectiveLowerTf + " • Q≥" + str.tostring(int(effectiveLiquidityQuality)) : "MANUAL"
        color autopilotColor = autopilotInput ? color.rgb(0, 238, 202) : color.rgb(180, 188, 210)

        table.cell(dashboard, 0, 0, "EVA LIQUIDITY • CALCULATED",
             text_color = color.white, text_size = size.small,
             bgcolor = color.new(color.rgb(26, 35, 57), 0))
        table.cell(dashboard, 0, 1, "Autopilot", text_color = color.rgb(155, 169, 198), text_size = size.tiny, bgcolor = color.new(autopilotColor, 90))
        table.cell(dashboard, 1, 1, autopilotText, text_color = autopilotColor, text_size = size.tiny, bgcolor = color.new(autopilotColor, 90))
        table.cell(dashboard, 0, 2, "Auction", text_color = color.rgb(155, 169, 198), text_size = size.tiny, bgcolor = color.new(auctionColor, 88))
        table.cell(dashboard, 1, 2, auctionText, text_color = auctionColor, text_size = size.tiny, bgcolor = color.new(auctionColor, 88))
        table.cell(dashboard, 0, 3, "Mode", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 3, rangeModeInput + " • " + profileViewInput, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 4, "Source", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 4, sourceText, text_color = dashboardUseLtf ? color.rgb(79, 224, 177) : color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 5, "Range", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 5, rangeText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 6, "Rows × step", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 6, rowsText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 7, "Up / Down", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 7, compositionText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 8, "Delta", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 8, deltaText, text_color = deltaColor, text_size = size.tiny)
        table.cell(dashboard, 0, 9, "POC / dist", text_color = pocColorInput, text_size = size.tiny)
        table.cell(dashboard, 1, 9, pocText, text_color = pocColorInput, text_size = size.tiny)
        table.cell(dashboard, 0, 10, "VAL — VAH", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 10, valueBoundsText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 11, "Value Area", text_color = valueAreaColorInput, text_size = size.tiny)
        table.cell(dashboard, 1, 11, vaText, text_color = valueAreaColorInput, text_size = size.tiny)
        table.cell(dashboard, 0, 12, "Nearest BSL", text_color = buyLiquidityColorInput, text_size = size.tiny)
        table.cell(dashboard, 1, 12, bslText, text_color = bslPanelColor, text_size = size.tiny)
        table.cell(dashboard, 0, 13, "Nearest SSL", text_color = sellLiquidityColorInput, text_size = size.tiny)
        table.cell(dashboard, 1, 13, sslText, text_color = sslPanelColor, text_size = size.tiny)
        table.cell(dashboard, 0, 14, "Nearest HVN/LVN", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 14, nodesText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 15, "Structure", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 15, structureText, text_color = color.white, text_size = size.tiny)
        table.cell(dashboard, 0, 16, "Status", text_color = color.rgb(155, 169, 198), text_size = size.tiny)
        table.cell(dashboard, 1, 16, statusText, text_color = statusColor, text_size = size.tiny)
    else
        table.cell(dashboard, 0, 0, "", bgcolor = color.new(color.black, 100))
        for column = 0 to 1
            for row = 1 to 16
                table.cell(dashboard, column, row, "", bgcolor = color.new(color.black, 100))
````
