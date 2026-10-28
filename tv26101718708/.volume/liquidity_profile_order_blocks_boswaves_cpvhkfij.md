# Liquidity Profile Order Blocks [BOSWaves]

- url: https://www.tradingview.com/script/CpvHKfIJ-Liquidity-Profile-Order-Blocks-BOSWaves/
- type: indicator
- pine_id: PUB;6316330f26f64299a6d42524df60bbab
- version: 1.0

## Description

[b]Liquidity Profile Order Blocks [BOSWaves] - Impulse-Validated Order Block Detection with Embedded Net Delta Volume Profiles[/b]

[b]Overview[/b]

Liquidity Profile Order Blocks [BOSWaves] is a pivot-anchored order block detection system that constructs supply and demand zones from impulse-validated swing events and embeds a live net delta volume profile inside each active block, where zone boundaries, profile distribution, and visual intensity are driven by measurable price displacement, volume-weighted directional flow at each price row, and real-time retest interaction rather than arbitrary candle pattern matching or static zone geometry.

[image]https://www.tradingview.com/x/5ieeEYep/[/image]

Instead of identifying order blocks through isolated candle formations or fixed lookback patterns, each block requires a confirmed swing pivot followed by a displacement move exceeding a configurable ATR multiple, ensuring that only structurally significant events with genuine impulse evidence behind them generate zones. The embedded net delta profile then maps the buy and sell volume distribution across the price rows of each block using the formation candles, identifying the Point of Control and revealing whether the underlying flow within the block was predominantly buying or selling pressure at each specific level.

This creates an order block framework that combines structural detection criteria with internal participation intelligence. Each zone simultaneously shows where price pivoted with sufficient impulse to warrant attention, how volume was distributed across its price range during formation, whether that distribution was net buy or net sell dominant at each level, and how the balance is evolving as price retests the zone. When price enters an active block the visual system responds with intensified borders, brightened profile rows, and a glow effect that makes active interaction immediately identifiable.

Price is therefore evaluated not just against zones that meet structural criteria but against zones with a fully mapped internal participation profile that reveals the order flow composition of the institutional activity that created them.

[b]Conceptual Framework[/b]

Liquidity Profile Order Blocks is founded on the principle that genuine order block zones carry two layers of evidence: a structural fingerprint in price behavior visible through pivot and impulse mechanics, and a participation fingerprint visible through the distribution of buying and selling volume across the zone's price range during its formation.

Traditional order block tools identify zones through candle pattern criteria alone and display them as uniform rectangles with no internal structure, treating all zones equally regardless of their internal flow composition. This framework adds the participation layer by building a per-row net delta profile inside each zone from the same bars that defined it, exposing how aggressively one side dominated at each price level and identifying the specific level within the zone where the greatest total participation was concentrated.

Three core principles guide the design:
[list=1]
[*]Order block detection should require both a confirmed swing pivot and a measurable impulse displacement, ensuring structural and momentum criteria are satisfied simultaneously before a zone is committed.
[*]Each zone should carry an embedded net delta profile derived from its formation bars, providing internal participation intelligence that distinguishes between zones with clean directional conviction and zones with contested or mixed flow composition.
[*]Zone visualization should respond dynamically to retest interaction, intensifying when price is actively engaging with a block to communicate the structural significance of the current price location in real time.
[/list]
This shifts order block analysis from pattern-matching zone marking into impulse-validated structural detection with embedded volume profile intelligence that reveals the institutional participation dynamics underlying each zone.

[b]Theoretical Foundation[/b]

The indicator combines pivot high and low detection for swing identification, ATR-normalized impulse measurement for displacement validation, multi-candle zone boundary construction from formation bars, per-row volume allocation using price overlap fractions, net delta calculation across profile rows, POC identification by maximum row volume, retest interaction detection for profile updates and active state management, and a multi-layer gradient visualization system with glow intensity scaling.

Pivot detection uses configurable left and right bar requirements to identify confirmed swing highs and lows. Impulse validation measures the price displacement from pivot to the detection bar relative to ATR, filtering for only the moves with sufficient momentum evidence. Zone boundaries are constructed from the configured number of formation candles preceding the pivot, with ATR-based minimum and maximum height constraints preventing zones from being either too thin to be meaningful or too wide to be actionable. Volume allocation to each profile row is proportional to the overlap between each formation bar's range and the row boundary, ensuring volume is distributed to the price levels where it actually traded rather than assigned uniformly.

Four internal systems operate in tandem:
[list]
[*][i]Impulse-Validated Detection Engine[/i]: Monitors confirmed pivot highs and lows and tests the displacement from pivot price to current close against the ATR multiple threshold, qualifying only structurally significant impulse events as order block origins.
[*][i]Zone Construction and Constraint System[/i]: Builds zone boundaries from formation candles with ATR-based height clamping, manages maximum zone count by removing oldest blocks when the limit is reached, and optionally removes overlapping same-side zones to maintain a clean active zone set.
[*][i]Net Delta Profile Engine[/i]: Allocates volume from formation bars to price rows via overlap-weighted fractions, tracks signed buy and sell volume per row to derive net delta ratios, identifies the POC as the maximum total volume row, and optionally updates the profile with additional volume on each confirmed retest bar.
[*][i]Retest Interaction and Visual System[/i]: Monitors price entry into each zone, tracks touch count and armed state, detects mid-level confirmation for active signal generation, scales visual intensity through glow, border weight, and profile row brightness based on interaction state, and invalidates zones on configurable close or wick breach conditions.
[/list]
This design ensures each zone carries both structural and participatory credentials while the visual system communicates interaction state dynamically throughout the zone's active lifecycle.

[b]How It Works[/b]

Liquidity Profile Order Blocks evaluates price through a sequence of structure-aware and participation-tracking processes:
[list=1]
[*][i]Pivot Detection[/i]: Swing highs and lows are confirmed when the configured number of bars to the left and right validate the pivot, identifying structurally significant turning points for impulse testing.
[*][i]Impulse Validation[/i]: On each confirmed pivot, the price displacement from the pivot level to the current close is measured in ATR multiples. Displacement exceeding the configured threshold qualifies the event as an order block origin.
[*][i]Zone Boundary Construction[/i]: The formation candle range spanning the configured number of bars before the pivot is used to derive zone top and bottom, with ATR-based minimum and maximum height constraints applied to ensure zone dimensions remain structurally meaningful.
[*][i]Overlap Removal[/i]: When enabled, a newly created zone checks for existing same-direction zones that overlap with its boundaries and removes the oldest overlapping zone, preserving the most recently formed level.
[*][i]Formation Profile Build[/i]: Each formation bar's volume is allocated to profile rows in proportion to the overlap between the bar's high-low range and each row boundary. Bullish formation bars contribute to buy volume and bearish bars to sell volume, building the initial net delta distribution across the zone's price rows.
[*][i]POC Identification[/i]: The row with the greatest total volume accumulation across all formation bars is identified as the Point of Control, receiving distinct highlighting and an optional midpoint line.
[*][i]Active State Monitoring[/i]: On each subsequent bar, price is tested for entry into each zone. Entry triggers a touch count increment and arms the zone for signal detection. When price closes beyond the midline in the zone direction after touching, the zone enters active state with intensified visual treatment.
[*][i]Retest Profile Update[/i]: When the retest profile update setting is enabled, each confirmed bar while price is inside a zone contributes additional volume to the net delta profile, keeping the participation distribution current as the auction continues.
[*][i]Visual Refresh[/i]: On every bar all active zones are redrawn with current glow intensity, border weight, profile row colors, and info box content reflecting the latest touch count, net delta percentage, total volume, and active state.
[*][i]Invalidation Testing[/i]: On each confirmed bar, close or wick price is tested against the zone boundary in the opposing direction. Breach triggers zone deletion with full cleanup of all associated visual objects.
[/list]
Together, these elements form a continuously updating order block system where structural credentials, internal participation profiles, and real-time retest dynamics are maintained simultaneously across all active zones.

[b]Interpretation[/b]

Liquidity Profile Order Blocks should be interpreted as an impulse-validated structural zone system with embedded participation intelligence and dynamic interaction tracking:
[list]
[*][i]Bullish Order Block (Green)[/i]: Zone formed below a confirmed swing low followed by a sufficient upward impulse, identifying a price region where buying activity concentrated before a displacement move higher.
[*][i]Bearish Order Block (Red)[/i]: Zone formed above a confirmed swing high followed by a sufficient downward impulse, identifying a price region where selling activity concentrated before a displacement move lower.
[*][i]Zone Body[/i]: The shaded rectangle spanning the formation candle range with gradient fill reflecting zone direction. Gradient intensity increases toward the dominant edge of the zone where institutional activity was most concentrated.
[*][i]Net Delta Profile Bars[/i]: Horizontal bars centered within the zone body extending left or right from the center line to reflect net buy or net sell dominance at each price row. Longer bars indicate more decisive directional dominance at that level.
[*][i]Point of Control Row[/i]: The profile row with the greatest total volume receives a distinct highlighted background and optional horizontal line, marking the price level of maximum participation concentration within the zone.
[*][i]Info Box[/i]: Panel extending to the right of each zone displaying zone direction, net delta percentage across all formation volume, and total formatted volume, providing a quick quantitative summary of the zone's participation profile.
[*][i]Midline[/i]: Dashed horizontal line at the zone center provides the reference level for mid-zone confirmation logic and serves as a precision target for entries and invalidation management.
[*][i]Active Retest Glow[/i]: When price enters a zone after prior interaction, borders intensify, the POC line brightens, profile rows saturate, and the seam line thickens, communicating active structural engagement with immediate visual clarity.
[*][i]Trend Cloud[/i]: Optional EMA fill and lines provide macro trend regime context, coloring in the bullish or bearish direction to help assess whether order block retests are occurring with or against the broader directional trend.
[/list]
Zone impulse strength, net delta profile composition, POC location, touch count, and active glow state collectively provide more structural intelligence than zone boundaries alone.

[b]Signal Logic & Visual Cues[/b]

Liquidity Profile Order Blocks generates retest confirmation signals when specific interaction conditions within active zones are met:
[list=1]
[*][i]Bullish Retest Confirmation[/i]: Generated when price enters a bullish order block, the zone is in armed state from a prior touch, and price closes above the zone midline after having been at or below it, suggesting buying pressure is reasserting within the demand zone.
[*][i]Bearish Retest Confirmation[/i]: Generated when price enters a bearish order block, the zone is in armed state from a prior touch, and price closes below the zone midline after having been at or above it, suggesting selling pressure is reasserting within the supply zone.
[/list]
Both signal types require prior zone interaction to arm the zone before confirmation can trigger, filtering out first-touch reactions and focusing on the mid-level confirmation that indicates directional intent within the block.

Alert generation covers bullish and bearish retest confirmations for systematic zone-based monitoring workflows.

[b]Strategy Integration[/b]

Liquidity Profile Order Blocks fits within institutional order flow and structural zone-based trading approaches:
[list]
[*][i]POC-Precise Entries[/i]: Use the POC row within each zone as the highest-precision entry reference rather than the full zone boundary, placing entries at the level of maximum prior participation where the institutional activity was most concentrated.
[*][i]Net Delta Zone Selection[/i]: Prioritize bullish zones showing net buy dominance in the profile and bearish zones showing net sell dominance, as aligned delta composition confirms that the formation volume was directionally consistent with the expected zone function.
[*][i]Mid-Level Confirmation Entries[/i]: Use the midline confirmation signal as an entry trigger rather than entering on initial zone touch, waiting for price to demonstrate directional intent by closing beyond the zone center in the expected direction.
[*][i]Touch Count Conviction Weighting[/i]: Assign higher confidence to zones with lower touch counts. Fresh zones with zero prior retests carry the most unmitigated institutional order potential. Zones with multiple touches have progressively absorbed more of the original order flow.
[*][i]Retest Profile Monitoring[/i]: Monitor the net delta profile as it updates during retests with the Update Net Profile on Retest setting enabled. Profile composition shifting against the zone direction during a retest suggests absorption rather than continuation, warranting reduced confidence in zone integrity.
[*][i]Invalidation Mode Selection[/i]: Use Close invalidation for stricter zone management that requires a full bar close beyond the boundary. Use Wick invalidation for earlier removal when any price excursion beyond the zone boundary is sufficient to consider the level structurally violated.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Detection Engine[/i]: Pivot high and low confirmation with ATR-normalized displacement measurement for impulse validation
[*][i]Zone Construction[/i]: Multi-candle formation boundary derivation with ATR min and max height clamping and optional overlap removal
[*][i]Profile System[/i]: Per-row volume allocation via high-low overlap fractions with signed net delta accumulation and maximum volume POC identification
[*][i]Interaction Logic[/i]: Touch count tracking, armed state management, mid-level confirmation detection, and optional retest profile accumulation
[*][i]Visual System[/i]: Multi-layer gradient zone fill, glow-scaled borders and lines, net delta profile bars, POC row and line highlighting, and info box with live metrics
[*][i]Invalidation[/i]: Configurable close or wick breach detection with full object cleanup on zone removal
[*][i]Trend Context[/i]: Dual EMA regime cloud with configurable fast and slow lengths for directional bias overlay
[*][i]Performance Profile[/i]: Optimized with configurable maximum block count and array-based object management supporting real-time execution across all timeframes
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday order block mapping for scalping with shorter pivot length and tighter impulse threshold for responsive zone formation on smaller structural moves
[*][i]15 - 60 min[/i]: Session-level institutional zone identification with balanced pivot and impulse settings producing zones aligned with meaningful intraday structural events
[*][i]4H - Daily[/i]: Swing-level demand and supply zone mapping with higher pivot requirements and wider impulse thresholds reflecting larger structural displacements
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Pivot Length[/i]: 8
[*][i]Impulse Size (ATR)[/i]: 1.10
[*][i]Formation Candles[/i]: 4
[*][i]Remove Overlapping Same-Side Blocks[/i]: Enabled
[*][i]Minimum Zone Height (ATR)[/i]: 0.12
[*][i]Maximum Zone Height (ATR)[/i]: 1.20
[*][i]Maximum Blocks[/i]: 6
[*][i]Invalidation[/i]: Close
[*][i]Profile Granularity[/i]: 12
[*][i]POC Highlight[/i]: Both
[*][i]Update Net Profile On Retest[/i]: Enabled
[*][i]Active Retest Glow[/i]: Enabled
[*][i]Show Info Box[/i]: Enabled
[*][i]Show MA Fill[/i]: Disabled
[*][i]Show MA Lines[/i]: Disabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, typical impulse behavior, and preferred zone density, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too many zones forming[/i]: Increase Impulse Size to demand a stronger displacement move after each pivot, or increase Pivot Length to require more structurally significant swing confirmation before an order block qualifies.
[*][i]Zones not forming frequently enough[/i]: Decrease Impulse Size toward 0.5 for more inclusive displacement qualification, or decrease Pivot Length toward 3 for faster pivot confirmation on shorter swing structures.
[*][i]Zone boundaries too wide[/i]: Decrease Maximum Zone Height ATR multiplier to compress oversized zones, or decrease Formation Candles to limit the boundary range to fewer formation bars.
[*][i]Zone boundaries too narrow[/i]: Increase Minimum Zone Height ATR multiplier to expand zones that are structurally too thin to provide meaningful interaction space.
[*][i]Profile too granular or too coarse[/i]: Adjust Profile Granularity to increase or decrease the number of price rows, calibrating profile resolution to the zone height and the instrument's typical price movement within order block regions.
[*][i]Zones invalidating too quickly[/i]: Switch Invalidation to Close mode to require a full bar close beyond the boundary rather than a wick excursion, reducing premature zone removal on temporary price spikes.
[*][i]Too many zones overlapping[/i]: Enable Remove Overlapping Same-Side Blocks to automatically clean older zones when new ones form at the same area, or reduce Maximum Blocks to limit total active zone count.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear impulse moves following swing pivots where order block zones consistently align with subsequent pullback reaction levels
[*]Liquid instruments with consistent volume where the net delta profile produces meaningful row-level participation distributions that accurately reflect institutional flow composition
[*]Institutional zone-based trading approaches where POC precision entries and net delta filtering provide higher-quality trade framing than conventional order block boundary entries
[*]Multi-timeframe workflows where higher-timeframe order block zones provide directional structural context for lower-timeframe entry timing
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, range-bound markets where frequent small swing pivots generate overlapping zones without the sustained impulse displacement required for meaningful structural significance
[*]Low-liquidity instruments where thin volume produces sparse net delta profiles with insufficient row-level differentiation to distinguish POC and flow composition reliably
[*]News-driven or gap-heavy markets where impulse moves occur on discontinuous price action that distorts zone boundary derivation relative to actual institutional entry levels
[*]Instruments with irregular volume distribution where the net delta profile loses compositional accuracy due to inconsistent participation patterns across formation bars
[*]Extreme volatility environments where ATR-based zone constraints produce inconsistent zone sizes that do not reflect the structural significance of the underlying pivot events
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves momentum tools, volume analysis, or structural break indicators to validate order block retests with broader analytical context before acting on mid-level confirmation signals
[*][i]Profile Composition Awareness[/i]: Treat net delta profile composition as a zone quality indicator. Zones with clean directional dominance across most rows carry higher conviction than zones with mixed or opposing flow across their price range.
[*][i]POC Respect[/i]: Use the POC row as the precision reference for entry placement and invalidation management. The maximum participation level within the zone represents the most meaningful price within the block from an institutional activity perspective.
[*][i]Touch Count Discipline[/i]: Reduce position sizing or confidence on zones that have been retested multiple times. Each touch consumes a portion of the original order flow that created the zone, reducing the probability of a sustained reaction on subsequent tests.
[*][i]Active Glow Response[/i]: Treat the active glow state as an immediate visual alert that price is engaging with a structurally significant level. Use this as a cue to increase monitoring frequency and prepare for confirmation or invalidation rather than acting immediately on zone entry alone.
[/list]
[b]Disclaimer[/b]

Liquidity Profile Order Blocks [BOSWaves] is a professional-grade order block detection and volume profile analysis tool. It uses impulse-validated pivot detection with per-row net delta profiling but does not access true exchange-level order book data. All volume distribution and flow measurements are derived from OHLCV data and represent best-approximation estimates of institutional participation rather than actual order book information. Results depend on instrument liquidity, volume reliability, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates momentum context, trend structure, and comprehensive risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

// © BOSWaves
//@version=6
indicator("Liquidity Profile Order Blocks [BOSWaves]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ┌────────────────────────────── BOSWaves ─ Groups ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string GRP_DETECT = "Order Block Detection"
const string GRP_ZONE   = "Zone Construction"
const string GRP_PROF   = "Net Profile"
const string GRP_TREND  = "Trend Cloud"
const string GRP_VIS    = "Visualization"
const string GRP_ALERTS = "Alerts"

// ┌────────────────────────────── BOSWaves ─ Tooltips ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string tt_pivotLen       = "Bars left and right required to confirm a swing high or low. Higher = fewer but more structurally significant pivot points."
const string tt_impulseATR     = "Minimum displacement after a pivot in ATR multiples for an order block to qualify. Higher = only the strongest impulse moves form blocks."
const string tt_baseCandles    = "Number of candles before the pivot used to define the order block zone boundaries. Higher = wider zone capturing more formation context."
const string tt_removeOverlap  = "When enabled, a newly formed block on the same side removes any existing block that overlaps with it, keeping only the most recent zone."
const string tt_atrLen         = "ATR lookback used for zone height constraints. Higher = smoother volatility measurement, slower adaptation to sudden range changes."
const string tt_minZoneATR     = "Minimum zone height as an ATR multiple. Zones narrower than this are expanded to the minimum. Higher = forces wider minimum zones."
const string tt_maxZoneATR     = "Maximum zone height as an ATR multiple. Zones taller than this are compressed to the maximum. Lower = keeps all zones tighter."
const string tt_extendBars     = "How far the info box extends to the right of the order block body in bars."
const string tt_maxBlocks      = "Maximum number of active order blocks tracked. Oldest blocks are removed first when the limit is reached."
const string tt_invalidation   = "Close = block removed when price closes beyond its boundary. Wick = block removed when price wicks beyond its boundary."
const string tt_rows           = "Number of price rows in the net delta profile. Higher = finer granularity and more detailed flow distribution per block."
const string tt_profileWidth   = "How much of the block width the net profile bars occupy. 1.0 = full width, 0.5 = half width."
const string tt_profilePadding = "Horizontal padding between the block edges and the profile area as a fraction of block width."
const string tt_buildOnRetest  = "When enabled, the net profile accumulates new volume data each time price retests the block, keeping the profile current."
const string tt_pocStyle       = "How the Point of Control is displayed. Line = horizontal line at POC. Row = highlighted row. Both = line and row. None = hidden."
const string tt_profileGlow    = "Adds a glow highlight to the POC row within the net profile for easier identification at a glance."
const string tt_showCloud      = "Shows a gradient fill between the fast and slow MAs reflecting the current trend regime direction."
const string tt_showMAs        = "Shows the fast and slow EMA lines on the chart colored by current trend regime."
const string tt_fastLen        = "Fast EMA length used for the trend cloud and regime coloring. Lower = more reactive to recent price movement."
const string tt_slowLen        = "Slow EMA length used for the trend cloud and regime coloring. Higher = smoother trend reference."
const string tt_showMidline    = "Shows a dashed midline at the vertical center of each order block zone."
const string tt_showCenter     = "Shows a dotted vertical line at the left edge of each block marking the zone origin bar."
const string tt_showInfoBox    = "Shows the info panel to the right of each block displaying zone type, net delta percentage, and total volume."
const string tt_gradientMode   = "None = flat fill. Soft = subtle gradient across the block body. Strong = more pronounced gradient intensity."
const string tt_gradientLayers = "Number of gradient layers rendering the block fill. Higher = smoother gradient transition across the zone."
const string tt_borderMode     = "Clean = standard thin border. Heavy = thicker border. Glow = dynamic border that intensifies during active retests."
const string tt_infoShade      = "Background opacity of the info box. Light = more transparent, Medium = balanced, Dark = more opaque."
const string tt_activeGlow     = "Intensifies borders, midline, POC line, and profile rows when price is actively retesting the block."
const string tt_bullColor      = "Color applied to bullish order blocks, their profile buy rows, and all associated visual elements."
const string tt_bearColor      = "Color applied to bearish order blocks, their profile sell rows, and all associated visual elements."
const string tt_buyColor       = "Color applied to net buy rows in the delta profile when buying pressure dominates that price level."
const string tt_sellColor      = "Color applied to net sell rows in the delta profile when selling pressure dominates that price level."
const string tt_alerts         = "Enables alert conditions that fire when price confirms a bullish or bearish order block retest."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int   i_pivotLen        = input.int(8, "Pivot Length", minval = 2, maxval = 50, group = GRP_DETECT, tooltip = tt_pivotLen)
float i_impulseATR      = input.float(1.10, "Impulse Size (ATR)", minval = 0.10, maxval = 10.0, step = 0.05, group = GRP_DETECT, tooltip = tt_impulseATR)
int   i_baseCandles     = input.int(4, "Formation Candles", minval = 2, maxval = 10, group = GRP_DETECT, tooltip = tt_baseCandles)
bool  i_removeOverlap   = input.bool(true, "Remove Overlapping Same-Side Blocks", group = GRP_DETECT, tooltip = tt_removeOverlap)

int   i_atrLen          = input.int(14, "ATR Length", minval = 1, group = GRP_ZONE, tooltip = tt_atrLen)
float i_minZoneATR      = input.float(0.12, "Minimum Zone Height (ATR)", minval = 0.01, maxval = 3.0, step = 0.01, group = GRP_ZONE, tooltip = tt_minZoneATR)
float i_maxZoneATR      = input.float(1.20, "Maximum Zone Height (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = GRP_ZONE, tooltip = tt_maxZoneATR)
int   i_extendBars      = input.int(54, "Info Box Extension Bars", minval = 1, maxval = 100, group = GRP_ZONE, tooltip = tt_extendBars)
int   i_maxBlocks       = input.int(6, "Maximum Blocks", minval = 1, maxval = 20, group = GRP_ZONE, tooltip = tt_maxBlocks)
string i_invalidation   = input.string("Close", "Invalidation", options = ["Close", "Wick"], group = GRP_ZONE, tooltip = tt_invalidation)

int   i_rows            = input.int(12, "Profile Granularity", minval = 4, maxval = 30, group = GRP_PROF, tooltip = tt_rows)
float i_profileWidth    = input.float(0.88, "Profile Width Inside OB", minval = 0.30, maxval = 1.00, step = 0.01, group = GRP_PROF, tooltip = tt_profileWidth)
float i_profilePadding  = input.float(0.04, "Profile Padding", minval = 0.00, maxval = 0.25, step = 0.01, group = GRP_PROF, tooltip = tt_profilePadding)
bool  i_buildOnRetest   = input.bool(true, "Update Net Profile On Retest", group = GRP_PROF, tooltip = tt_buildOnRetest)
string i_pocStyle       = input.string("Both", "POC Highlight", options = ["Line", "Row", "Both", "None"], group = GRP_PROF, tooltip = tt_pocStyle)
bool  i_profileGlow     = input.bool(true, "Profile Row Glow", group = GRP_PROF, tooltip = tt_profileGlow)

bool  i_showTrendCloud  = input.bool(false, "Show MA Fill", group = GRP_TREND, tooltip = tt_showCloud)
bool  i_showMAs         = input.bool(false, "Show MA Lines", group = GRP_TREND, tooltip = tt_showMAs)
int   i_fastLen         = input.int(8, "Fast MA", minval = 1, group = GRP_TREND, tooltip = tt_fastLen)
int   i_slowLen         = input.int(21, "Slow MA", minval = 2, group = GRP_TREND, tooltip = tt_slowLen)

bool  i_showMidline     = input.bool(true, "Show Midline", group = GRP_VIS, tooltip = tt_showMidline)
bool  i_showCenterLine  = input.bool(true, "Show Net Center Line", group = GRP_VIS, tooltip = tt_showCenter)
bool  i_showInfoBox     = input.bool(true, "Show Info Box", group = GRP_VIS, tooltip = tt_showInfoBox)
color i_textColor       = input.color(color.white, "Info Text Color", group = GRP_VIS)

string i_gradientMode   = input.string("Soft", "Box Gradient", options = ["None", "Soft", "Strong"], group = GRP_VIS, tooltip = tt_gradientMode)
int    i_gradientLayers = input.int(6, "Gradient Layers", minval = 3, maxval = 10, group = GRP_VIS, tooltip = tt_gradientLayers)
string i_borderMode     = input.string("Glow", "Border Style", options = ["Clean", "Heavy", "Glow"], group = GRP_VIS, tooltip = tt_borderMode)
string i_infoShade      = input.string("Dark", "Info Box Shade", options = ["Light", "Medium", "Dark"], group = GRP_VIS, tooltip = tt_infoShade)
bool   i_activeGlow     = input.bool(true, "Active Retest Glow", group = GRP_VIS, tooltip = tt_activeGlow)

color i_bullColor       = input.color(#00ff88, "Bullish OB", group = GRP_VIS, tooltip = tt_bullColor)
color i_bearColor       = input.color(#ff3355, "Bearish OB", group = GRP_VIS, tooltip = tt_bearColor)
color i_buyColor        = input.color(#00ff88, "Net Buy", group = GRP_VIS, tooltip = tt_buyColor)
color i_sellColor       = input.color(#ff3355, "Net Sell", group = GRP_VIS, tooltip = tt_sellColor)

bool  i_enableAlerts    = input.bool(true, "Enable Retest Alerts", group = GRP_ALERTS, tooltip = tt_alerts)

// ┌────────────────────────────── BOSWaves ─ Helpers ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
clamp_float(float v, float lo, float hi) =>
    math.max(lo, math.min(v, hi))

zones_overlap(float topA, float botA, float topB, float botB) =>
    botA <= topB and topA >= botB

fmt_vol(float v) =>
    float av = math.abs(v)
    string sign = v < 0 ? "-" : ""
    av >= 1000000000 ? sign + str.tostring(math.round(av / 1000000000 * 100.0) / 100.0) + "B" :
     av >= 1000000   ? sign + str.tostring(math.round(av / 1000000 * 100.0) / 100.0) + "M" :
     av >= 1000      ? sign + str.tostring(math.round(av / 1000 * 100.0) / 100.0) + "K" :
                       sign + str.tostring(math.round(av))

info_alpha() =>
    switch i_infoShade
        "Light"  => 94
        "Medium" => 90
        "Dark"   => 84

base_border_width() =>
    switch i_borderMode
        "Clean" => 2
        "Heavy" => 3
        "Glow"  => 3

top_bottom_width() =>
    switch i_borderMode
        "Clean" => 3
        "Heavy" => 4
        "Glow"  => 4

gradient_alpha(float intensity, bool active) =>
    int weak = i_gradientMode == "Strong" ? 97 : 98
    int strong = i_gradientMode == "Strong" ? 76 : 86
    int out = int(weak - intensity * (weak - strong))
    active and i_activeGlow ? math.max(out - 5, 55) : out

// ┌────────────────────────────── BOSWaves ─ Core Series ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float atrVal = ta.atr(i_atrLen)

float fastMA = ta.ema(close, i_fastLen)
float slowMA = ta.ema(close, i_slowLen)

bool bullRegime = fastMA >= slowMA
color regimeColor = bullRegime ? i_bullColor : i_bearColor

plot(i_showMAs ? fastMA : na, "Fast MA", color = color.new(regimeColor, 0), linewidth = 2)
plot(i_showMAs ? slowMA : na, "Slow MA", color = color.new(regimeColor, 45), linewidth = 2)

pFast = plot(i_showTrendCloud ? fastMA : na, "", display = display.none, editable = false)
pSlow = plot(i_showTrendCloud ? slowMA : na, "", display = display.none, editable = false)
fill(pFast, pSlow, i_showTrendCloud ? color.new(regimeColor, 88) : na)

float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low, i_pivotLen, i_pivotLen)

bool newBullOB = not na(pl) and close - low[i_pivotLen] >= atrVal[i_pivotLen] * i_impulseATR
bool newBearOB = not na(ph) and high[i_pivotLen] - close >= atrVal[i_pivotLen] * i_impulseATR

// ┌────────────────────────────── BOSWaves ─ Types ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type NetOB
    box          zone_box
    box          info_box
    box          poc_row_box
    line         top_line
    line         bottom_line
    line         mid_line
    line         center_line
    line         seam_line
    line         poc_line
    array<box>   shade_boxes
    array<box>   net_boxes
    array<float> net_prof
    array<float> total_prof
    bool         is_bull
    float        top
    float        bottom
    float        mid
    float        strength
    float        buy_vol
    float        sell_vol
    float        total_vol
    float        net_vol
    int          poc_row
    int          left_index
    int          touches
    bool         armed
    bool         active
    bool         was_inside

var NetOB[] obs = array.new<NetOB>()

// ┌────────────────────────────── BOSWaves ─ Rebuild Helper ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
rebuild_ob(NetOB ob, float buyVol, float sellVol, float totalVol, float netVol, int pocRow, int touches, bool armed, bool active, bool wasInside) =>
    NetOB.new(
         ob.zone_box,
         ob.info_box,
         ob.poc_row_box,
         ob.top_line,
         ob.bottom_line,
         ob.mid_line,
         ob.center_line,
         ob.seam_line,
         ob.poc_line,
         ob.shade_boxes,
         ob.net_boxes,
         ob.net_prof,
         ob.total_prof,
         ob.is_bull,
         ob.top,
         ob.bottom,
         ob.mid,
         ob.strength,
         buyVol,
         sellVol,
         totalVol,
         netVol,
         pocRow,
         ob.left_index,
         touches,
         armed,
         active,
         wasInside
    )

// ┌────────────────────────────── BOSWaves ─ Delete OB ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
delete_ob(NetOB ob) =>
    if not na(ob.zone_box)
        box.delete(ob.zone_box)
    if not na(ob.info_box)
        box.delete(ob.info_box)
    if not na(ob.poc_row_box)
        box.delete(ob.poc_row_box)
    if not na(ob.top_line)
        line.delete(ob.top_line)
    if not na(ob.bottom_line)
        line.delete(ob.bottom_line)
    if not na(ob.mid_line)
        line.delete(ob.mid_line)
    if not na(ob.center_line)
        line.delete(ob.center_line)
    if not na(ob.seam_line)
        line.delete(ob.seam_line)
    if not na(ob.poc_line)
        line.delete(ob.poc_line)

    if array.size(ob.shade_boxes) > 0
        for i = 0 to array.size(ob.shade_boxes) - 1
            box sb = array.get(ob.shade_boxes, i)
            if not na(sb)
                box.delete(sb)

    if array.size(ob.net_boxes) > 0
        for i = 0 to array.size(ob.net_boxes) - 1
            box nb = array.get(ob.net_boxes, i)
            if not na(nb)
                box.delete(nb)

// ┌────────────────────────────── BOSWaves ─ Profile Allocation ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
profile_add(NetOB ob, float cHigh, float cLow, float cVol, bool isBuy) =>
    float zoneH  = math.max(ob.top - ob.bottom, syminfo.mintick)
    float rowH   = zoneH / i_rows
    float cRange = math.max(cHigh - cLow, syminfo.mintick)
    float addVol = 0.0

    for r = 0 to i_rows - 1
        float rowBot = ob.bottom + r * rowH
        float rowTop = rowBot + rowH
        float overlap = math.max(0.0, math.min(cHigh, rowTop) - math.max(cLow, rowBot))

        if overlap > 0
            float alloc = cVol * (overlap / cRange)
            float signedAlloc = isBuy ? alloc : -alloc

            array.set(ob.net_prof, r, array.get(ob.net_prof, r) + signedAlloc)
            array.set(ob.total_prof, r, array.get(ob.total_prof, r) + alloc)

            addVol += alloc

    float buyVol = ob.buy_vol + (isBuy ? addVol : 0.0)
    float sellVol = ob.sell_vol + (isBuy ? 0.0 : addVol)
    float totalVol = buyVol + sellVol
    float netVol = buyVol - sellVol

    rebuild_ob(ob, buyVol, sellVol, totalVol, netVol, ob.poc_row, ob.touches, ob.armed, ob.active, ob.was_inside)

// ┌────────────────────────────── BOSWaves ─ Create OB ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
create_ob(bool isBull, int pivotOffset) =>
    int oldest = pivotOffset
    int newest = math.max(pivotOffset - i_baseCandles + 1, 1)

    float rawTop = na
    float rawBot = na

    if isBull
        rawTop := math.max(open[oldest], close[oldest])
        rawBot := low[oldest]

        for i = newest to oldest
            rawTop := math.max(rawTop, math.max(open[i], close[i]))
            rawBot := math.min(rawBot, low[i])
    else
        rawTop := high[oldest]
        rawBot := math.min(open[oldest], close[oldest])

        for i = newest to oldest
            rawTop := math.max(rawTop, high[i])
            rawBot := math.min(rawBot, math.min(open[i], close[i]))

    float pivotATR = math.max(atrVal[pivotOffset], syminfo.mintick)
    float zoneH = rawTop - rawBot
    float minH = pivotATR * i_minZoneATR
    float maxH = pivotATR * i_maxZoneATR

    if zoneH < minH
        float m = math.avg(rawTop, rawBot)
        rawTop := m + minH * 0.5
        rawBot := m - minH * 0.5

    if rawTop - rawBot > maxH
        float m = math.avg(rawTop, rawBot)
        rawTop := m + maxH * 0.5
        rawBot := m - maxH * 0.5

    float obTop = rawTop
    float obBot = rawBot
    float obMid = math.avg(obTop, obBot)

    float dispScore = isBull ? (close - low[pivotOffset]) / pivotATR : (high[pivotOffset] - close) / pivotATR
    float strength = clamp_float(0.30 + math.min(dispScore, 3.0) * 0.18, 0.20, 1.0)

    int leftIdx = bar_index - oldest
    int bodyRightIdx = bar_index
    int infoRightIdx = bar_index + i_extendBars

    color baseCol = isBull ? i_bullColor : i_bearColor

    box z = box.new(leftIdx, obTop, bodyRightIdx, obBot,
         xloc = xloc.bar_index,
         bgcolor = color.new(baseCol, 91),
         border_color = color.new(baseCol, 36),
         border_width = base_border_width())

    array<box> shadeBoxes = array.new<box>()

    for s = 0 to i_gradientLayers - 1
        box sb = box.new(leftIdx, obTop, bodyRightIdx, obBot,
             xloc = xloc.bar_index,
             bgcolor = color.new(baseCol, 100),
             border_color = color.new(baseCol, 100),
             border_width = 1)

        array.push(shadeBoxes, sb)

    box pocRowBox = box.new(leftIdx, obMid, bodyRightIdx, obMid,
         xloc = xloc.bar_index,
         bgcolor = color.new(baseCol, 100),
         border_color = color.new(baseCol, 100),
         border_width = 1)

    array<box> netBoxes = array.new<box>()
    array<float> netProf = array.new<float>()
    array<float> totalProf = array.new<float>()

    for r = 0 to i_rows - 1
        box nb = box.new(leftIdx, obTop, leftIdx, obBot,
             xloc = xloc.bar_index,
             bgcolor = color.new(baseCol, 80),
             border_color = color.new(baseCol, 100),
             border_width = 1)

        array.push(netBoxes, nb)
        array.push(netProf, 0.0)
        array.push(totalProf, 0.0)

    box info = box.new(bodyRightIdx, obTop, infoRightIdx, obBot,
         xloc = xloc.bar_index,
         bgcolor = color.new(baseCol, info_alpha()),
         border_color = color.new(baseCol, 42),
         border_width = base_border_width(),
         text_size = size.auto,
         text_halign = text.align_center,
         text_valign = text.align_center,
         text_color = i_textColor)

    line tl = line.new(leftIdx, obTop, infoRightIdx, obTop,
         xloc = xloc.bar_index,
         color = color.new(baseCol, 8),
         width = top_bottom_width())

    line bl = line.new(leftIdx, obBot, infoRightIdx, obBot,
         xloc = xloc.bar_index,
         color = color.new(baseCol, 8),
         width = top_bottom_width())

    line ml = line.new(leftIdx, obMid, bodyRightIdx, obMid,
         xloc = xloc.bar_index,
         color = i_showMidline ? color.new(chart.fg_color, 70) : na,
         style = line.style_dashed,
         width = 1)

    line cl = line.new(leftIdx, obTop, leftIdx, obBot,
         xloc = xloc.bar_index,
         color = i_showCenterLine ? color.new(chart.fg_color, 82) : na,
         style = line.style_dotted,
         width = 1)

    line seam = line.new(bodyRightIdx, obTop, bodyRightIdx, obBot,
         xloc = xloc.bar_index,
         color = color.new(baseCol, 55),
         style = line.style_solid,
         width = 1)

    line poc = line.new(leftIdx, obMid, bodyRightIdx, obMid,
         xloc = xloc.bar_index,
         color = (i_pocStyle == "Line" or i_pocStyle == "Both") ? color.new(baseCol, 15) : na,
         width = 2)

    NetOB ob = NetOB.new(
         z,
         info,
         pocRowBox,
         tl,
         bl,
         ml,
         cl,
         seam,
         poc,
         shadeBoxes,
         netBoxes,
         netProf,
         totalProf,
         isBull,
         obTop,
         obBot,
         obMid,
         strength,
         0.0,
         0.0,
         0.0,
         0.0,
         0,
         leftIdx,
         0,
         false,
         false,
         false
    )

    for i = newest to oldest
        bool isBuy = close[i] >= open[i]
        ob := profile_add(ob, high[i], low[i], volume[i], isBuy)

    ob

// ┌────────────────────────────── BOSWaves ─ Refresh OB ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
refresh_ob(NetOB ob) =>
    color baseCol = ob.is_bull ? i_bullColor : i_bearColor

    int bodyRightIdx = bar_index
    int infoRightIdx = bar_index + i_extendBars

    float glow = clamp_float(ob.strength * 0.45 + ob.touches * 0.05 + (ob.active and i_activeGlow ? 0.30 : 0.0), 0.0, 1.0)

    int bodyAlpha = int(clamp_float(92.0 - glow * 20.0, 60.0, 94.0))
    int borderAlpha = int(clamp_float(55.0 - glow * 46.0, 2.0, 70.0))

    int bw = base_border_width() + (ob.active and i_activeGlow ? 1 : 0)
    int edgeW = top_bottom_width() + (ob.active and i_activeGlow ? 1 : 0)

    box.set_left(ob.zone_box, ob.left_index)
    box.set_right(ob.zone_box, bodyRightIdx)
    box.set_top(ob.zone_box, ob.top)
    box.set_bottom(ob.zone_box, ob.bottom)
    box.set_bgcolor(ob.zone_box, color.new(baseCol, bodyAlpha))
    box.set_border_color(ob.zone_box, color.new(baseCol, borderAlpha))
    box.set_border_width(ob.zone_box, bw)

    if array.size(ob.shade_boxes) > 0
        float zoneHShade = math.max(ob.top - ob.bottom, syminfo.mintick)
        float layerH = zoneHShade / array.size(ob.shade_boxes)

        for s = 0 to array.size(ob.shade_boxes) - 1
            box sb = array.get(ob.shade_boxes, s)

            float botY = ob.bottom + s * layerH
            float topY = botY + layerH

            float pos = array.size(ob.shade_boxes) > 1 ? s / (array.size(ob.shade_boxes) - 1.0) : 0.0
            float intensity = ob.is_bull ? 1.0 - pos : pos

            int a = i_gradientMode == "None" ? 100 : gradient_alpha(intensity, ob.active)

            box.set_left(sb, ob.left_index)
            box.set_right(sb, bodyRightIdx)
            box.set_top(sb, topY)
            box.set_bottom(sb, botY)
            box.set_bgcolor(sb, color.new(baseCol, a))
            box.set_border_color(sb, color.new(baseCol, 100))

    box.set_left(ob.info_box, bodyRightIdx)
    box.set_right(ob.info_box, infoRightIdx)
    box.set_top(ob.info_box, ob.top)
    box.set_bottom(ob.info_box, ob.bottom)
    box.set_border_width(ob.info_box, bw)
    box.set_border_color(ob.info_box, color.new(baseCol, ob.active and i_activeGlow ? 18 : 42))

    line.set_x1(ob.top_line, ob.left_index)
    line.set_x2(ob.top_line, infoRightIdx)
    line.set_y1(ob.top_line, ob.top)
    line.set_y2(ob.top_line, ob.top)
    line.set_width(ob.top_line, edgeW)
    line.set_color(ob.top_line, color.new(baseCol, ob.active and not ob.is_bull and i_activeGlow ? 0 : 10))

    line.set_x1(ob.bottom_line, ob.left_index)
    line.set_x2(ob.bottom_line, infoRightIdx)
    line.set_y1(ob.bottom_line, ob.bottom)
    line.set_y2(ob.bottom_line, ob.bottom)
    line.set_width(ob.bottom_line, edgeW)
    line.set_color(ob.bottom_line, color.new(baseCol, ob.active and ob.is_bull and i_activeGlow ? 0 : 10))

    line.set_x1(ob.mid_line, ob.left_index)
    line.set_x2(ob.mid_line, bodyRightIdx)
    line.set_y1(ob.mid_line, ob.mid)
    line.set_y2(ob.mid_line, ob.mid)
    line.set_color(ob.mid_line, i_showMidline ? color.new(chart.fg_color, ob.active and i_activeGlow ? 55 : 72) : na)

    line.set_x1(ob.seam_line, bodyRightIdx)
    line.set_x2(ob.seam_line, bodyRightIdx)
    line.set_y1(ob.seam_line, ob.top)
    line.set_y2(ob.seam_line, ob.bottom)
    line.set_color(ob.seam_line, color.new(baseCol, ob.active and i_activeGlow ? 30 : 58))
    line.set_width(ob.seam_line, ob.active and i_activeGlow ? 2 : 1)

    int bodySpan = math.max(bodyRightIdx - ob.left_index, 2)
    int padBars = int(math.round(bodySpan * i_profilePadding))
    int availableLeft = ob.left_index + padBars
    int availableRight = bodyRightIdx - padBars
    int availableSpan = math.max(availableRight - availableLeft, 2)

    int profileSpan = int(math.max(2, math.round(availableSpan * i_profileWidth)))
    int profileLeft = availableLeft + int(math.round((availableSpan - profileSpan) * 0.5))
    int profileRight = profileLeft + profileSpan
    int centerX = profileLeft + int(math.round(profileSpan * 0.5))
    int halfSpan = int(math.max(1, math.round(profileSpan * 0.5)))

    line.set_x1(ob.center_line, centerX)
    line.set_x2(ob.center_line, centerX)
    line.set_y1(ob.center_line, ob.top)
    line.set_y2(ob.center_line, ob.bottom)
    line.set_color(ob.center_line, i_showCenterLine ? color.new(chart.fg_color, ob.active and i_activeGlow ? 68 : 82) : na)

    float zoneH = math.max(ob.top - ob.bottom, syminfo.mintick)
    float rowH = zoneH / i_rows

    float maxAbsNet = 0.0
    float maxTotal = 0.0
    int pocRow = 0

    for r = 0 to i_rows - 1
        float absNet = math.abs(array.get(ob.net_prof, r))
        float totalR = array.get(ob.total_prof, r)

        maxAbsNet := math.max(maxAbsNet, absNet)

        if totalR > maxTotal
            maxTotal := totalR
            pocRow := r

    maxAbsNet := math.max(maxAbsNet, 1.0)

    bool showPocRow = i_pocStyle == "Row" or i_pocStyle == "Both"
    bool showPocLine = i_pocStyle == "Line" or i_pocStyle == "Both"

    float pocBot = ob.bottom + pocRow * rowH
    float pocTop = pocBot + rowH

    box.set_left(ob.poc_row_box, profileLeft)
    box.set_right(ob.poc_row_box, profileRight)
    box.set_top(ob.poc_row_box, pocTop)
    box.set_bottom(ob.poc_row_box, pocBot)
    box.set_bgcolor(ob.poc_row_box, showPocRow ? color.new(baseCol, ob.active and i_activeGlow ? 76 : 86) : color.new(baseCol, 100))
    box.set_border_color(ob.poc_row_box, showPocRow ? color.new(baseCol, 70) : color.new(baseCol, 100))

    for r = 0 to i_rows - 1
        float rowBot = ob.bottom + r * rowH
        float rowTop = rowBot + rowH

        float netV = array.get(ob.net_prof, r)
        float frac = clamp_float(math.abs(netV) / maxAbsNet, 0.0, 1.0)

        bool netBuy = netV >= 0

        int rawLeftX = netBuy ? centerX : centerX - int(math.round(halfSpan * frac))
        int rawRightX = netBuy ? centerX + int(math.round(halfSpan * frac)) : centerX

        int leftX = math.max(profileLeft, math.min(rawLeftX, profileRight))
        int rightX = math.max(profileLeft, math.min(rawRightX, profileRight))

        color rowCol = netBuy ? i_buyColor : i_sellColor

        bool isPoc = r == pocRow
        float glowBoost = i_profileGlow and isPoc ? 12.0 : 0.0
        float activeBoost = ob.active and i_activeGlow ? 8.0 : 0.0

        int rowAlpha = int(clamp_float(88.0 - frac * 66.0 - glowBoost - activeBoost, 6.0, 92.0))

        box nb = array.get(ob.net_boxes, r)

        box.set_left(nb, leftX)
        box.set_right(nb, rightX)
        box.set_top(nb, rowTop)
        box.set_bottom(nb, rowBot)
        box.set_bgcolor(nb, color.new(rowCol, rowAlpha))
        box.set_border_color(nb, isPoc and i_profileGlow ? color.new(rowCol, 55) : color.new(rowCol, 100))

    float pocY = ob.bottom + (pocRow + 0.5) * rowH

    line.set_x1(ob.poc_line, profileLeft)
    line.set_x2(ob.poc_line, profileRight)
    line.set_y1(ob.poc_line, pocY)
    line.set_y2(ob.poc_line, pocY)
    line.set_color(ob.poc_line, showPocLine ? color.new(baseCol, ob.active and i_activeGlow ? 0 : 22) : na)
    line.set_width(ob.poc_line, ob.active and i_activeGlow ? 3 : 2)

    if i_showInfoBox
        float netPct = ob.total_vol > 0 ? ob.net_vol / ob.total_vol * 100.0 : 0.0
        string netSign = netPct >= 0 ? "+" : ""
        string sideTxt = ob.is_bull ? "Bullish OB" : "Bearish OB"
        string netTxt = netSign + str.tostring(math.round(netPct * 10.0) / 10.0) + "%"
        string txt = sideTxt + "\nNet: " + netTxt + "\nVol: " + fmt_vol(ob.total_vol)

        box.set_bgcolor(ob.info_box, color.new(baseCol, info_alpha()))
        box.set_text(ob.info_box, txt)
        box.set_text_color(ob.info_box, i_textColor)
        box.set_text_size(ob.info_box, size.auto)
        box.set_text_halign(ob.info_box, text.align_center)
        box.set_text_valign(ob.info_box, text.align_center)
        box.set_text_font_family(ob.info_box, font.family_monospace)
    else
        box.set_bgcolor(ob.info_box, color.new(baseCol, 100))
        box.set_border_color(ob.info_box, color.new(baseCol, 100))
        box.set_text(ob.info_box, "")

    rebuild_ob(ob, ob.buy_vol, ob.sell_vol, ob.total_vol, ob.net_vol, pocRow, ob.touches, ob.armed, ob.active, ob.was_inside)

// ┌────────────────────────────── BOSWaves ─ Interact OB ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
interact_ob(NetOB ob) =>
    bool longSig = false
    bool shortSig = false

    bool inside = high >= ob.bottom and low <= ob.top

    int touches = ob.touches
    bool armed = ob.armed
    bool active = false
    bool wasInside = ob.was_inside

    NetOB working = ob

    if barstate.isconfirmed and inside and not wasInside
        touches += 1
        armed := true

    if barstate.isconfirmed and inside and i_buildOnRetest
        bool isBuy = close >= open
        working := profile_add(working, high, low, volume, isBuy)

    bool longConfirm =
         inside and working.is_bull and
         close > working.mid and (close[1] <= working.mid or low <= working.mid)

    bool shortConfirm =
         inside and not working.is_bull and
         close < working.mid and (close[1] >= working.mid or high >= working.mid)

    if barstate.isconfirmed and armed
        if longConfirm
            active := true
            armed := false
            longSig := true

        if shortConfirm
            active := true
            armed := false
            shortSig := true

    wasInside := inside

    NetOB out = rebuild_ob(
         working,
         working.buy_vol,
         working.sell_vol,
         working.total_vol,
         working.net_vol,
         working.poc_row,
         touches,
         armed,
         active,
         wasInside
    )

    [out, longSig, shortSig]

// ┌────────────────────────────── BOSWaves ─ Add New OBs ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if newBullOB
    NetOB nb = create_ob(true, i_pivotLen)

    if i_removeOverlap and array.size(obs) > 0
        int idx = array.size(obs) - 1
        while idx >= 0
            NetOB old = array.get(obs, idx)
            if old.is_bull and zones_overlap(nb.top, nb.bottom, old.top, old.bottom)
                delete_ob(old)
                array.remove(obs, idx)
                break
            idx -= 1

    if array.size(obs) >= i_maxBlocks
        NetOB oldest = array.shift(obs)
        delete_ob(oldest)

    array.push(obs, nb)

if newBearOB
    NetOB nb = create_ob(false, i_pivotLen)

    if i_removeOverlap and array.size(obs) > 0
        int idx = array.size(obs) - 1
        while idx >= 0
            NetOB old = array.get(obs, idx)
            if not old.is_bull and zones_overlap(nb.top, nb.bottom, old.top, old.bottom)
                delete_ob(old)
                array.remove(obs, idx)
                break
            idx -= 1

    if array.size(obs) >= i_maxBlocks
        NetOB oldest = array.shift(obs)
        delete_ob(oldest)

    array.push(obs, nb)

// ┌────────────────────────────── BOSWaves ─ Manage OBs ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var bool bullSignal = false
var bool bearSignal = false

bullSignal := false
bearSignal := false

if array.size(obs) > 0
    int idx = array.size(obs) - 1

    while idx >= 0
        NetOB ob = array.get(obs, idx)

        [updatedOb, sigBull, sigBear] = interact_ob(ob)
        ob := updatedOb
        ob := refresh_ob(ob)

        bullSignal := bullSignal or sigBull
        bearSignal := bearSignal or sigBear

        bool broken = i_invalidation == "Close" ? (ob.is_bull ? close < ob.bottom : close > ob.top) : (ob.is_bull ? low < ob.bottom : high > ob.top)

        if barstate.isconfirmed and broken
            delete_ob(ob)
            array.remove(obs, idx)
        else
            array.set(obs, idx, ob)

        idx -= 1

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(i_enableAlerts and bullSignal, title = "Bullish Net Profile Order Blocks", message = "Net Profile Order Blocks [BOSWaves]: bullish retest confirmation")
alertcondition(i_enableAlerts and bearSignal, title = "Bearish Net Profile Order Blocks", message = "Net Profile Order Blocks [BOSWaves]: bearish retest confirmation")
````
