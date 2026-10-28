# Candle Majick - Booby Trap Detector mk1

- url: https://www.tradingview.com/script/PvHtthaJ-Candle-Majick-Booby-Trap-Detector-mk1/
- type: indicator
- pine_id: PUB;e582e9397fd047d1afe1b54cfd06c722
- version: 1.0

## Description

CANDLE MAJICK - BOOBY TRAP DETECTOR mk1

INTRODUCTION

Candle Majick - Booby Trap Detector mk1 is an educational market-context indicator that evaluates apparent bullish and bearish reversal candles as developing hypotheses rather than automatic trade signals.

A reversal candle can look persuasive while still forming in a location where the market has not completed the structural work normally needed to support a genuine turn. This script was designed to examine that distinction.

Instead of asking only, “Is this a hammer, engulfing candle, pin bar, outside reversal, morning star, or evening star?”, the indicator asks a more useful question:

Has the surrounding market context earned the reversal thesis, or is the candle vulnerable to becoming a continuation trap?

WHAT THE SCRIPT ANALYZES

The indicator combines candle geometry with several independent context layers:

• Named intraday key-level zones:
  - Previous-Day High and Low
  - Developing Session High and Low
  - Session VWAP
  - Nearest configured Round Number

• Named swing key-level zones:
  - Previous-Week High and Low
  - Previous-Month High and Low
  - Confirmed Swing High and Low
  - Two optional user-defined manual levels

• Key-level distance and confluence

• Repeated-level testing and level-fatigue proxy

• Nearby confirmed swing references that may represent probable unswept liquidity

• Round-number surface-bounce behavior

• Relative-volume and true-range expansion used as a News-Like Event Proxy

• Three configurable higher-timeframe trend contexts:
  - Tactical
  - Structural
  - Macro

• Persistent candidate memory

• Early retail-trap warnings

• Confirmed reversal-failure events

HOW THE ENGINE WORKS

1. A supported reversal pattern is detected.

2. The pattern receives a raw geometry score based on measurable candle proportions.

3. Setup quality is adjusted according to location. A strong-looking candle that forms away from every enabled key level is downgraded.

4. Trap risk is calculated from contextual warnings, including poor location, nearby unswept swing references, repeated testing, round-number behavior, abnormal expansion, and higher-timeframe contradiction.

5. The candidate is preserved for a configurable evaluation window rather than being recreated on every bar.

6. A WARN event can appear when the reversal candle is contextually vulnerable but has not yet failed.

7. A confirmed BT event appears only when price later violates the stored reversal thesis.

This separation matters. A warning is not treated as a confirmed trap, and candle geometry is not treated as reversal proof.

HOW TO USE

Apply the indicator to the chart timeframe used for execution.

Configure the three higher timeframes so they represent the context relevant to your trading horizon. For example, a lower-timeframe trader may use 15 minutes, 1 hour, and 4 hours.

Keep the named zones visible while learning the chart map. The script can display abbreviated names such as PDH, PDL, PWH, PWL, PMH, PML, SH, SL, VWAP, and RN, or spell the names out fully.

The available chart-label modes are:

• Off — hides event labels.
• Stealth — shows confirmed booby traps only.
• Icon Only — uses minimal symbols while preserving hover explanations.
• Compact — shows short event codes and associated higher timeframes.
• Verbose — prints classifications, scores, and higher-timeframe conflict directly on the chart.

Interpret the events as follows:

• Grey candidate marker:
A reversal pattern has been detected. This is an observation, not an entry signal.

• WARN:
Contextual trap risk is elevated, but the candidate has not yet been invalidated.

• BT:
The stored reversal thesis failed during its evaluation window.

Hover over labels for the exact reasons that contributed to the event.

WHY THIS SCRIPT IS VALUABLE

Many candlestick scanners stop at pattern recognition. That can encourage traders to react to appearance without evaluating location, unfinished liquidity work, repeated level testing, abnormal expansion, or higher-timeframe continuation pressure.

Candle Majick - Booby Trap Detector mk1 is designed to fill that gap.

Its value is not that it finds more reversal candles. Its value is that it:

• downgrades unsupported reversal setups;
• distinguishes warnings from confirmed failures;
• preserves the original candidate context;
• associates trap events with three higher-timeframe regimes;
• provides named key-level zones for faster chart cognition;
• and explains why a candle received its classification.

ORIGINALITY AND SOURCE DISCLOSURE

This implementation was independently written for this project in Pine Script v6.

No third-party or previously published Pine source code was copied, adapted, translated, or incorporated into this implementation. The script uses TradingView’s documented Pine built-ins, standard mathematical operations, and original project-specific logic for candidate memory, scoring, key-level zoning, higher-timeframe context, event classification, visual presentation, and explanations.

EDUCATIONAL TOOLTIP NOTICE

The tooltips are included for education, transparency, and auditability. They explain which measured facts and explicitly identified proxies contributed to a warning or trap classification.

The tooltips are not advertising, financial advice, performance guarantees, or claims of predictive certainty.

IMPORTANT LIMITATIONS

This script does not have direct access to:

• resting orders;
• institutional intent;
• real stop orders;
• confirmed economic-news causation;
• bid/ask delta;
• cumulative volume delta;
• footprint imbalance;
• or market-by-order data.

Accordingly, terms such as Probable Liquidity, News-Like Event, Level Fatigue, and Trap Risk describe analytical proxies—not directly observed order-flow facts.

Higher-timeframe requests use lookahead disabled for trend calculations. Swing references use confirmed pivots. Candidate markers remain on their original bars, while warnings and confirmed failures appear only when those events are observed.

This indicator is an analytical and educational tool. It should be combined with independent judgment, risk management, and appropriate market knowledge.

## Source Code

````pine
//@version=6
indicator(
     title="Candle Majick - Booby Trap Detector mk1",
     shorttitle="Candle Majick - Booby Trap Detector mk1",
     overlay=true,
     max_bars_back=5000,
     max_labels_count=500,
     max_lines_count=100,
     max_boxes_count=50
)

// =================================================================================================
// CANDLE MAJICK - BOOBY TRAP DETECTOR mk1
// ORIGINAL EDUCATIONAL MARKET-CONTEXT INDICATOR
// =================================================================================================
//
// INTRODUCTION
// Candle Majick - Booby Trap Detector mk1 evaluates apparent bullish and bearish reversal candles
// as developing hypotheses rather than automatic trade signals. Its purpose is to help traders
// distinguish a reversal candle with meaningful structural support from a visually convincing candle
// that may be vulnerable to continuation through its invalidation level.
//
// The script combines candle geometry with:
// - proximity to named intraday and swing key-level zones,
// - repeated-level testing,
// - probable unswept swing-liquidity references,
// - round-number behavior,
// - abnormal volume/range expansion proxies,
// - three configurable higher-timeframe trend contexts,
// - persistent candidate memory,
// - early retail-trap warnings,
// - and confirmed failure events.
//
// SUMMARY OF OPERATION
// 1. Detect a supported reversal-candle pattern.
// 2. Score the candle's raw geometry.
// 3. Adjust setup quality according to key-level location and confluence.
// 4. Calculate contextual trap risk.
// 5. Preserve the candidate during a configurable evaluation window.
// 6. Warn when contextual evidence makes the reversal suspect.
// 7. Confirm a booby trap only if price later violates the reversal thesis.
//
// HOW TO USE
// - Apply the indicator to the chart timeframe used for execution.
// - Configure the three higher timeframes to represent tactical, structural, and macro context.
// - Keep named key-level zones visible until their placement and abbreviations are familiar.
// - Treat grey candidate markers as observations, not entries.
// - Hover over candidate, warning, and booby-trap labels for educational explanations.
// - A WARN label means the reversal candle has elevated contextual risk but has not yet failed.
// - A BT label appears only after price breaks the stored candidate invalidation boundary.
// - Use Icon Only or Stealth mode when chart cleanliness is more important than visible text.
// - Use Verbose mode during review and study.
//
// WHY THIS SCRIPT IS VALUABLE
// Conventional candlestick scanners often identify geometry without asking where the candle formed,
// what liquidity or structural work remains unfinished, whether key levels support the thesis, or
// whether higher-timeframe pressure still favors continuation. This indicator addresses that gap.
// Its value is not that it finds more reversal candles. Its value is that it downgrades unsupported
// reversal narratives, preserves the original context, and explains why a failed reversal may have
// trapped traders who reacted to candle appearance alone.
//
// ORIGINALITY AND SOURCE DISCLOSURE
// This implementation was independently written for this project in Pine Script v6.
// No third-party or previously published Pine source code was copied, adapted, translated, or
// incorporated into this implementation. The script uses TradingView's documented Pine built-ins,
// standard mathematical operations, and original project-specific state, scoring, display, and
// explanation logic.
//
// EDUCATIONAL TOOLTIP NOTICE
// Tooltips and chart explanations are included for education and transparency. They explain which
// measured facts and explicitly named proxies contributed to a classification. They are not
// advertising, performance claims, financial advice, or guarantees of future market behavior.
//
// DATA AND CLAIM LIMITATIONS
// The script does not claim access to resting orders, institutional intent, actual stop orders,
// economic-news causation, bid/ask delta, CVD, footprint imbalance, or market-by-order data.
// Terms such as "probable liquidity," "news-like event," and "trap risk" are analytical proxies.
// No historical or real-time classification should be interpreted as certainty.
//
// NON-REPAINTING INTENT
// Higher-timeframe requests use lookahead disabled for trend calculations. Confirmed pivots are used
// for swing references. Candidate markers remain on their original bars, while warnings and confirmed
// failures appear on the bars where those events are observed. No signal is intentionally back-placed
// to create false historical precision.
//
// =================================================================================================
//
// WHAT THIS PHASE ADDS
// - Bullish and bearish reversal-candle candidates.
// - Geometry-only pattern-quality scoring.
// - Persistent candidate memory.
// - Historical confirmed booby-trap markers.
// - Human-readable tooltip explanations.
// - Initial operational trap proxies:
//      1. Poor pattern location.
//      2. Nearby unswept swing liquidity.
//      3. Round-number surface bounce.
//      4. News-like volume/range event.
//      5. Higher-timeframe contradiction.
//      6. Repeated-level test proxy.
// - One trap decision per candidate.
// - Bounded historical labels.
//
// IMPORTANT
// - "Liquidity", "absorption", and "news" are proxy classifications.
// - This phase does not claim access to resting orders, bid/ask delta, footprint, MBO, or a news calendar.
// - Confirmation appears on the actual failure/continuation bar, never back-plotted.
// =================================================================================================


// =================================================================================================
// 01. INPUTS — PATTERN DETECTION
// =================================================================================================

var string GRP_PATTERN = "1. Pattern Detection"

bool confirmedBarsOnly = input.bool(
     true,
     "Evaluate On Confirmed Bars",
     group=GRP_PATTERN,
     tooltip="When enabled, candidates and trap confirmations are created only after the chart bar closes."
)

bool enableHammerStar = input.bool(true, "Hammer / Shooting Star", group=GRP_PATTERN)
bool enableEngulfing = input.bool(true, "Bullish / Bearish Engulfing", group=GRP_PATTERN)
bool enablePinBars = input.bool(true, "Bullish / Bearish Pin Bars", group=GRP_PATTERN)
bool enableOutside = input.bool(true, "Bullish / Bearish Outside Reversal", group=GRP_PATTERN)
bool enableThreeBarStars = input.bool(true, "Morning / Evening Star", group=GRP_PATTERN)

float minPatternQuality = input.float(
     55.0,
     "Minimum Pattern Quality",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group=GRP_PATTERN,
     tooltip="Geometry-only threshold. Context and trap risk are evaluated separately."
)

float wickBodyRatio = input.float(
     2.0,
     "Primary Wick / Body Ratio",
     minval=1.0,
     maxval=10.0,
     step=0.25,
     group=GRP_PATTERN,
     tooltip="Minimum dominant-wick length compared with candle body for hammer, shooting-star, and pin-bar geometry."
)

float oppositeWickMaxBody = input.float(
     0.75,
     "Opposite Wick Maximum / Body",
     minval=0.0,
     maxval=3.0,
     step=0.05,
     group=GRP_PATTERN,
     tooltip="Maximum small-side wick compared with the candle body."
)

int candidateLifeBars = input.int(
     8,
     "Candidate Evaluation Window",
     minval=1,
     maxval=50,
     group=GRP_PATTERN,
     tooltip="Maximum bars allowed for a reversal candidate to prove itself or become a confirmed continuation trap."
)

float failureBufferATR = input.float(
     0.10,
     "Failure Break Buffer — ATR",
     minval=0.0,
     maxval=2.0,
     step=0.05,
     group=GRP_PATTERN,
     tooltip="Extra distance beyond the pattern extreme required to confirm that the reversal failed."
)


// =================================================================================================
// 02. INPUTS — LEVEL / LIQUIDITY / LOCATION
// =================================================================================================

var string GRP_CONTEXT = "2. Context and Trap Proxies"

int atrLength = input.int(14, "ATR Length", minval=1, maxval=200, group=GRP_CONTEXT)
int rangeLookback = input.int(
     50,
     "Location Range Lookback",
     minval=10,
     maxval=500,
     group=GRP_CONTEXT,
     tooltip="Defines the rolling range used to judge whether a reversal formed at an extreme or near equilibrium."
)

float middleZoneWidth = input.float(
     0.20,
     "Poor-Location Middle Zone",
     minval=0.05,
     maxval=0.45,
     step=0.05,
     group=GRP_CONTEXT,
     tooltip="Half-width around normalized range midpoint. Example: 0.20 treats range positions 0.30–0.70 as structurally mediocre."
)

int swingLeft = input.int(3, "Swing Left Bars", minval=1, maxval=20, group=GRP_CONTEXT)
int swingRight = input.int(3, "Swing Right Bars", minval=1, maxval=20, group=GRP_CONTEXT)

float nearbyLiquidityATR = input.float(
     1.25,
     "Nearby Unswept Liquidity — ATR",
     minval=0.10,
     maxval=10.0,
     step=0.05,
     group=GRP_CONTEXT,
     tooltip="Maximum distance from the candidate to a confirmed swing pool that remains beyond the reversal candle."
)

int touchLookback = input.int(
     100,
     "Repeated-Level Touch Lookback",
     minval=20,
     maxval=500,
     group=GRP_CONTEXT
)

float touchToleranceATR = input.float(
     0.12,
     "Touch Tolerance — ATR",
     minval=0.01,
     maxval=1.0,
     step=0.01,
     group=GRP_CONTEXT
)

int overTestedTouches = input.int(
     3,
     "Over-Tested Threshold",
     minval=2,
     maxval=10,
     group=GRP_CONTEXT,
     tooltip="Number of separated contacts required before the candidate level receives a fatigue warning."
)

int minimumTouchSeparation = input.int(
     4,
     "Minimum Bars Between Touches",
     minval=1,
     maxval=50,
     group=GRP_CONTEXT
)


// =================================================================================================
// 03. INPUTS — KEY LEVELS OF INTEREST
// =================================================================================================

var string GRP_KEY_LEVELS = "3. Key Levels of Interest"

bool usePreviousDayLevels = input.bool(
     true,
     "Previous-Day High / Low",
     group=GRP_KEY_LEVELS,
     tooltip="Includes the prior regular trading day high and low as major auction references."
)

bool useSessionExtremes = input.bool(
     true,
     "Current Session High / Low",
     group=GRP_KEY_LEVELS,
     tooltip="Includes the developing daily-session high and low. These are measured facts, not inferred liquidity."
)

bool useSwingKeyLevels = input.bool(
     true,
     "Confirmed Swing High / Low",
     group=GRP_KEY_LEVELS,
     tooltip="Includes the most recent confirmed pivot high and low. Pivots are confirmed only after the configured right-side bars."
)

bool useVwapKeyLevel = input.bool(
     true,
     "Session VWAP",
     group=GRP_KEY_LEVELS,
     tooltip="Includes TradingView session VWAP as a key auction reference when volume is available."
)

bool useRoundAsKeyLevel = input.bool(
     true,
     "Nearest Round Number",
     group=GRP_KEY_LEVELS,
     tooltip="Allows the nearest configured psychological number to contribute to key-level proximity."
)

bool useManualKeyLevel1 = input.bool(false, "Use Manual Key Level 1", group=GRP_KEY_LEVELS, inline="MAN1")
float manualKeyLevel1 = input.float(0.0, "Price", group=GRP_KEY_LEVELS, inline="MAN1")

bool useManualKeyLevel2 = input.bool(false, "Use Manual Key Level 2", group=GRP_KEY_LEVELS, inline="MAN2")
float manualKeyLevel2 = input.float(0.0, "Price", group=GRP_KEY_LEVELS, inline="MAN2")

float keyLevelProximityATR = input.float(
     0.75,
     "Maximum Key-Level Distance — ATR",
     minval=0.05,
     maxval=5.0,
     step=0.05,
     group=GRP_KEY_LEVELS,
     tooltip="A reversal candle farther than this distance from every enabled key level is treated as poor context."
)

float awayFromKeyLevelPenalty = input.float(
     35.0,
     "Setup-Quality Penalty Away From Levels",
     minval=0.0,
     maxval=90.0,
     step=5.0,
     group=GRP_KEY_LEVELS,
     tooltip="Percentage deducted from raw pattern quality when no enabled key level is nearby."
)

float keyLevelConfluenceBonus = input.float(
     5.0,
     "Quality Bonus Per Additional Key Level",
     minval=0.0,
     maxval=20.0,
     step=1.0,
     group=GRP_KEY_LEVELS,
     tooltip="Small bonus for multiple enabled key levels clustering near the pattern. The adjusted score remains capped at 100."
)


bool drawIntradayKeyZones = input.bool(
     true,
     "Draw Intraday Key Zones",
     group=GRP_KEY_LEVELS,
     tooltip="Draws current-session high/low, previous-day high/low, VWAP, and the nearest round-number zone when those sources are enabled."
)

bool drawSwingKeyZones = input.bool(
     true,
     "Draw Swing Key Zones",
     group=GRP_KEY_LEVELS,
     tooltip="Draws previous-week high/low, previous-month high/low, confirmed swing high/low, and enabled manual levels."
)

int intradayZoneThicknessTicks = input.int(
     8,
     "Intraday Zone Thickness — Ticks",
     minval=1,
     maxval=500,
     group=GRP_KEY_LEVELS,
     tooltip="Total vertical thickness of each intraday zone in minimum ticks. For NQ, 8 ticks equals 2.00 points."
)

int swingZoneThicknessTicks = input.int(
     20,
     "Swing Zone Thickness — Ticks",
     minval=1,
     maxval=2000,
     group=GRP_KEY_LEVELS,
     tooltip="Total vertical thickness of each swing zone in minimum ticks. Swing zones are normally broader than intraday zones."
)

int zoneLookbackBars = input.int(
     250,
     "Zone Left Lookback — Bars",
     minval=10,
     maxval=5000,
     group=GRP_KEY_LEVELS,
     tooltip="How far each active horizontal zone begins to the left of the current bar."
)

int zoneRightExtensionBars = input.int(
     50,
     "Zone Right Extension — Bars",
     minval=1,
     maxval=500,
     group=GRP_KEY_LEVELS,
     tooltip="How far active zones project beyond the current bar."
)

string zoneVisibilityMode = input.string(
     "Relevant",
     "Zone Visibility",
     options=["All", "Relevant"],
     group=GRP_KEY_LEVELS,
     tooltip="Relevant hides zones that are too far from current price. All renders every enabled zone."
)

float intradayRelevantDistanceATR = input.float(
     8.0,
     "Intraday Relevance Distance — ATR",
     minval=0.5,
     maxval=100.0,
     step=0.5,
     group=GRP_KEY_LEVELS,
     tooltip="In Relevant mode, intraday zones farther than this distance from price are hidden."
)

float swingRelevantDistanceATR = input.float(
     25.0,
     "Swing Relevance Distance — ATR",
     minval=1.0,
     maxval=250.0,
     step=1.0,
     group=GRP_KEY_LEVELS,
     tooltip="In Relevant mode, swing zones farther than this distance from price are hidden."
)

int intradayZoneTransparency = input.int(
     88,
     "Intraday Zone Transparency",
     minval=0,
     maxval=100,
     group=GRP_KEY_LEVELS
)

int swingZoneTransparency = input.int(
     91,
     "Swing Zone Transparency",
     minval=0,
     maxval=100,
     group=GRP_KEY_LEVELS
)


bool showZoneNames = input.bool(
     true,
     "Show Key-Level Names",
     group=GRP_KEY_LEVELS,
     tooltip="Places a persistent name at the right edge of each visible zone so the chart can be read without memorizing colors or line order."
)

string zoneNameMode = input.string(
     "Abbreviated",
     "Key-Level Name Style",
     options=["Abbreviated", "Full"],
     group=GRP_KEY_LEVELS,
     tooltip="Abbreviated uses PDH, PDL, PWH, PWL, PMH, PML, SH, SL, VWAP, and RN. Full spells out each level."
)

string zoneNameSizeInput = input.string(
     "Tiny",
     "Key-Level Name Size",
     options=["Tiny", "Small", "Normal"],
     group=GRP_KEY_LEVELS
)

int zoneNameRightOffsetBars = input.int(
     2,
     "Name Offset From Zone Edge — Bars",
     minval=0,
     maxval=50,
     group=GRP_KEY_LEVELS,
     tooltip="Moves key-level names to the right of the zone projection edge."
)

int zoneNameTransparency = input.int(
     12,
     "Key-Level Name Transparency",
     minval=0,
     maxval=100,
     group=GRP_KEY_LEVELS
)

color resistanceZoneColor = input.color(
     color.rgb(183, 28, 28),
     "Resistance Zones",
     group=GRP_KEY_LEVELS,
     inline="ZONECOL"
)

color supportZoneColor = input.color(
     color.rgb(0, 150, 136),
     "Support Zones",
     group=GRP_KEY_LEVELS,
     inline="ZONECOL"
)

color referenceZoneColor = input.color(
     color.rgb(117, 117, 117),
     "Reference Zones",
     group=GRP_KEY_LEVELS,
     inline="ZONECOL"
)


// =================================================================================================
// 04. INPUTS — ROUND NUMBERS
// =================================================================================================

var string GRP_ROUND = "3. Round Numbers"

string roundMode = input.string(
     "Auto",
     "Round Increment",
     options=["Auto", "1", "5", "10", "25", "50", "100", "250", "500", "1000", "Custom"],
     group=GRP_ROUND
)

float customRoundIncrement = input.float(100.0, "Custom Increment", minval=0.0000001, step=0.25, group=GRP_ROUND)

float roundToleranceATR = input.float(
     0.12,
     "Round Surface Tolerance — ATR",
     minval=0.01,
     maxval=1.0,
     step=0.01,
     group=GRP_ROUND
)


// =================================================================================================
// 05. INPUTS — VOLUME EVENT PROXY
// =================================================================================================

var string GRP_VOLUME = "5. Volume Event Proxy"

int volumeLength = input.int(50, "Relative Volume Length", minval=5, maxval=500, group=GRP_VOLUME)
int zLength = input.int(100, "Z-Score Length", minval=20, maxval=1000, group=GRP_VOLUME)

float newsRelVol = input.float(2.50, "News-Like Relative Volume", minval=1.0, maxval=20.0, step=0.10, group=GRP_VOLUME)
float newsVolumeZ = input.float(2.50, "News-Like Volume Z-Score", minval=0.5, maxval=10.0, step=0.10, group=GRP_VOLUME)
float newsRangeZ = input.float(2.00, "News-Like Range Z-Score", minval=0.5, maxval=10.0, step=0.10, group=GRP_VOLUME)


// =================================================================================================
// 06. INPUTS — HIGHER-TIMEFRAME CONTEXT
// =================================================================================================

var string GRP_HTF = "6. Higher-Timeframe Context"

string htfTimeframe1 = input.timeframe(
     "15",
     "HTF 1 — Tactical",
     group=GRP_HTF,
     tooltip="Fast contextual timeframe. On a 1–5 minute chart, 15 minutes is a practical tactical default."
)

string htfTimeframe2 = input.timeframe(
     "60",
     "HTF 2 — Structural",
     group=GRP_HTF,
     tooltip="Middle contextual timeframe. This is the primary structural filter by default."
)

string htfTimeframe3 = input.timeframe(
     "240",
     "HTF 3 — Macro",
     group=GRP_HTF,
     tooltip="Slow contextual timeframe used to detect broad continuation pressure against a lower-timeframe reversal."
)

int htfEmaFastLength = input.int(21, "HTF Fast EMA", minval=2, maxval=300, group=GRP_HTF)
int htfEmaSlowLength = input.int(55, "HTF Slow EMA", minval=3, maxval=500, group=GRP_HTF)

int minimumHtfContradictionsForWarning = input.int(
     1,
     "HTF Contradictions For Warning",
     minval=1,
     maxval=3,
     group=GRP_HTF,
     tooltip="Number of the three HTFs that must oppose the reversal before HTF conflict creates a visible warning."
)

float htfStackBonus = input.float(
     10.0,
     "Additional Trap Risk Per Extra HTF",
     minval=0.0,
     maxval=30.0,
     step=1.0,
     group=GRP_HTF,
     tooltip="Adds trap risk when two or three HTFs align against the apparent reversal. The normal HTF contradiction weight covers the first opposing timeframe."
)


// =================================================================================================
// 07. INPUTS — SCORING / VISUALS
// =================================================================================================

var string GRP_SCORE = "7. Scoring and Visuals"

float poorLocationWeight = input.float(15.0, "Trap Weight — Poor Location", minval=0.0, maxval=100.0, group=GRP_SCORE)
float unsweptLiquidityWeight = input.float(20.0, "Trap Weight — Unswept Liquidity", minval=0.0, maxval=100.0, group=GRP_SCORE)
float roundSurfaceWeight = input.float(10.0, "Trap Weight — Round Surface", minval=0.0, maxval=100.0, group=GRP_SCORE)
float newsLikeWeight = input.float(20.0, "Trap Weight — News-Like Event", minval=0.0, maxval=100.0, group=GRP_SCORE)
float htfContradictionWeight = input.float(20.0, "Trap Weight — HTF Contradiction", minval=0.0, maxval=100.0, group=GRP_SCORE)
float overTestedWeight = input.float(15.0, "Trap Weight — Repeated Level", minval=0.0, maxval=100.0, group=GRP_SCORE)
float awayFromKeyLevelWeight = input.float(
     25.0,
     "Trap Weight — Away From Key Levels",
     minval=0.0,
     maxval=100.0,
     group=GRP_SCORE,
     tooltip="Adds explicit trap risk when a reversal candle is unsupported by any enabled key level of interest."
)

float probableTrapScore = input.float(45.0, "Probable Trap Score", minval=0.0, maxval=100.0, group=GRP_SCORE)
float confirmedTrapScore = input.float(50.0, "Confirmed Trap Score", minval=0.0, maxval=100.0, group=GRP_SCORE)

string displayMode = input.string(
     "Compact",
     "Chart Label Mode",
     options=["Off", "Stealth", "Icon Only", "Compact", "Verbose"],
     group=GRP_SCORE,
     tooltip="Off hides event labels. Stealth shows confirmed booby traps only. Icon Only uses compact symbols with tooltips. Compact shows short codes and HTF association. Verbose prints the classification, score, and HTF conflict directly on the chart."
)

string candidateLabelSizeInput = input.string(
     "Tiny",
     "Candidate Label Size",
     options=["Tiny", "Small", "Normal"],
     group=GRP_SCORE
)

string warningLabelSizeInput = input.string(
     "Tiny",
     "Warning Label Size",
     options=["Tiny", "Small", "Normal"],
     group=GRP_SCORE
)

string trapLabelSizeInput = input.string(
     "Small",
     "Booby-Trap Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=GRP_SCORE
)

float warningTrapScore = input.float(
     30.0,
     "Retail Trap Warning Score",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=GRP_SCORE,
     tooltip="Creates an early warning on the pattern bar before failure is confirmed. Lower values produce more warnings."
)

bool showCandidateMarkers = input.bool(true, "Show Explained Candidate Labels", group=GRP_SCORE)
bool showHistoricalTrapLabels = input.bool(true, "Show Historical Trap Labels", group=GRP_SCORE)
bool showFailedReversalLabels = input.bool(
     false,
     "Show Low-Score Failure Labels",
     group=GRP_SCORE,
     tooltip="Review-only by default. Keeps normal trading views focused on warnings and confirmed traps."
)
bool showOnlyHighRiskCandidates = input.bool(false, "Only Create High-Risk Candidates", group=GRP_SCORE)
float trapLabelOffsetATR = input.float(
     0.35,
     "Trap Label Offset — ATR",
     minval=0.10,
     maxval=3.0,
     step=0.05,
     group=GRP_SCORE,
     tooltip="Moves historical BT labels away from candle bodies to reduce overlap."
)
bool showDashboard = input.bool(true, "Show Dashboard", group=GRP_SCORE)
bool showDebug = input.bool(false, "Show Debug Table", group=GRP_SCORE)

int maximumHistoricalLabels = input.int(
     100,
     "Maximum Historical Trap Labels",
     minval=10,
     maxval=400,
     group=GRP_SCORE,
     tooltip="Old labels are deleted after this bounded limit is reached."
)

color bullColor = input.color(color.rgb(0, 150, 136), "Bullish", group=GRP_SCORE, inline="COL")
color bearColor = input.color(color.rgb(183, 28, 28), "Bearish", group=GRP_SCORE, inline="COL")
color trapColor = input.color(color.rgb(255, 152, 0), "Trap", group=GRP_SCORE, inline="COL")
color neutralColor = input.color(color.rgb(117, 117, 117), "Neutral", group=GRP_SCORE, inline="COL")


// =================================================================================================
// 07. UTILITY FUNCTIONS
// =================================================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.min(math.max(value, minimum), maximum)

f_safeDiv(float numerator, float denominator, float fallback) =>
    na(numerator) or na(denominator) or denominator == 0.0 ? fallback : numerator / denominator

f_scoreText(float value) =>
    str.tostring(math.round(f_clamp(value, 0.0, 100.0)))

f_directionText(int direction) =>
    direction == 1 ? "Bullish" : direction == -1 ? "Bearish" : "Neutral"

f_roundIncrement(string mode, float customValue) =>
    float result = customValue
    if mode == "1"
        result := 1.0
    else if mode == "5"
        result := 5.0
    else if mode == "10"
        result := 10.0
    else if mode == "25"
        result := 25.0
    else if mode == "50"
        result := 50.0
    else if mode == "100"
        result := 100.0
    else if mode == "250"
        result := 250.0
    else if mode == "500"
        result := 500.0
    else if mode == "1000"
        result := 1000.0
    else if mode == "Auto"
        float px = math.max(math.abs(close), syminfo.mintick)
        float magnitude = math.pow(10.0, math.floor(math.log10(px)) - 2.0)
        result := math.max(syminfo.mintick, magnitude)
    math.max(result, syminfo.mintick)

f_countTouches(float level, float tolerance, int lookback, int separation) =>
    int count = 0
    int lastTouchOffset = 1000000
    for i = 1 to lookback
        bool touched = low[i] <= level + tolerance and high[i] >= level - tolerance
        if touched and lastTouchOffset - i >= separation
            count += 1
            lastTouchOffset := i
    count

f_appendReason(string existing, bool condition, string reason) =>
    condition ? (existing == "" ? "• " + reason : existing + "\n• " + reason) : existing

f_minEnabledDistance(float currentMinimum, bool enabled, float referencePrice, float candidatePrice) =>
    enabled and not na(referencePrice) ? math.min(currentMinimum, math.abs(candidatePrice - referencePrice)) : currentMinimum

f_countEnabledNear(int currentCount, bool enabled, float referencePrice, float candidatePrice, float maximumDistance) =>
    enabled and not na(referencePrice) and math.abs(candidatePrice - referencePrice) <= maximumDistance ? currentCount + 1 : currentCount

f_labelSize(string selectedSize) =>
    switch selectedSize
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.tiny

f_tfText(string tf) =>
    tf == "1" ? "1m" :
     tf == "3" ? "3m" :
     tf == "5" ? "5m" :
     tf == "15" ? "15m" :
     tf == "30" ? "30m" :
     tf == "60" ? "1H" :
     tf == "120" ? "2H" :
     tf == "240" ? "4H" :
     tf == "D" ? "1D" :
     tf == "W" ? "1W" :
     tf


f_zoneRelevant(float levelPrice, float currentAtr, float maximumDistanceATR) =>
    not na(levelPrice) and (
         zoneVisibilityMode == "All" or
         (not na(currentAtr) and currentAtr > 0.0 and math.abs(close - levelPrice) <= currentAtr * maximumDistanceATR)
    )

f_updateZone(
     box existingZone,
     bool shouldShow,
     float levelPrice,
     float totalThickness,
     color zoneColor,
     int transparency
) =>
    box result = existingZone
    if shouldShow and not na(levelPrice)
        float halfThickness = totalThickness * 0.5
        float zoneTop = levelPrice + halfThickness
        float zoneBottom = levelPrice - halfThickness
        int zoneLeft = math.max(0, bar_index - zoneLookbackBars)
        int zoneRight = bar_index + zoneRightExtensionBars

        if na(result)
            result := box.new(
                 zoneLeft,
                 zoneTop,
                 zoneRight,
                 zoneBottom,
                 xloc=xloc.bar_index,
                 border_color=color.new(zoneColor, math.max(transparency - 18, 0)),
                 border_width=1,
                 bgcolor=color.new(zoneColor, transparency)
            )
        else
            box.set_lefttop(result, zoneLeft, zoneTop)
            box.set_rightbottom(result, zoneRight, zoneBottom)
            box.set_border_color(result, color.new(zoneColor, math.max(transparency - 18, 0)))
            box.set_bgcolor(result, color.new(zoneColor, transparency))
    else
        if not na(result)
            box.delete(result)
            result := na
    result


f_zoneNameText(string abbreviatedName, string fullName) =>
    zoneNameMode == "Full" ? fullName : abbreviatedName

f_updateZoneName(
     label existingLabel,
     bool shouldShow,
     float levelPrice,
     string displayName,
     string fullDescription,
     color zoneColor
) =>
    label result = existingLabel
    bool renderName = showZoneNames and shouldShow and not na(levelPrice)

    if renderName
        int labelX = bar_index + zoneRightExtensionBars + zoneNameRightOffsetBars
        string tooltipText =
             fullDescription + "\n" +
             "Price: " + str.tostring(levelPrice, format.mintick) + "\n" +
             "Zone thickness is configured in minimum ticks."

        if na(result)
            result := label.new(
                 labelX,
                 levelPrice,
                 displayName,
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=color.new(zoneColor, zoneNameTransparency),
                 textcolor=color.white,
                 size=f_labelSize(zoneNameSizeInput)
            )
        else
            label.set_xy(result, labelX, levelPrice)
            label.set_text(result, displayName)
            label.set_color(result, color.new(zoneColor, zoneNameTransparency))
            label.set_textcolor(result, color.white)
            label.set_size(result, f_labelSize(zoneNameSizeInput))

        label.set_tooltip(result, tooltipText)
    else
        if not na(result)
            label.delete(result)
            result := na

    result

f_candidateChartText(string mode, string abbreviation, string fullName, float quality) =>
    mode == "Icon Only" ? "•" :
     mode == "Verbose" ? fullName + "\nQ " + f_scoreText(quality) :
     abbreviation

f_warningChartText(string mode, string opposingHtf, float score) =>
    string htfText = opposingHtf == "" ? "" : " " + opposingHtf
    mode == "Icon Only" ? "!" :
     mode == "Verbose" ? "RETAIL TRAP WARNING" + htfText + "\nRisk " + f_scoreText(score) :
     "WARN" + htfText

f_trapChartText(string mode, string opposingHtf, float score) =>
    string htfText = opposingHtf == "None" ? "" : " " + opposingHtf
    mode == "Icon Only" ? "BT" :
     mode == "Verbose" ? "CONFIRMED BOOBY TRAP" + htfText + "\nRisk " + f_scoreText(score) :
     "BT" + htfText


// =================================================================================================
// 08. BASE SERIES
// =================================================================================================

bool evaluationGate = confirmedBarsOnly ? barstate.isconfirmed : true

float atrValue = ta.atr(atrLength)
float candleRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float bodyPct = f_safeDiv(candleBody, candleRange, 0.0)
float closeLocation = f_safeDiv(close - low, candleRange, 0.5)

float rollingHigh = ta.highest(high, rangeLookback)
float rollingLow = ta.lowest(low, rangeLookback)
float rollingRange = math.max(rollingHigh - rollingLow, syminfo.mintick)
float rangePosition = f_safeDiv(close - rollingLow, rollingRange, 0.5)
bool poorLocation = rangePosition >= 0.5 - middleZoneWidth and rangePosition <= 0.5 + middleZoneWidth

float confirmedSwingHigh = ta.pivothigh(high, swingLeft, swingRight)
float confirmedSwingLow = ta.pivotlow(low, swingLeft, swingRight)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(confirmedSwingHigh)
    lastSwingHigh := confirmedSwingHigh

if not na(confirmedSwingLow)
    lastSwingLow := confirmedSwingLow

float previousDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

float previousDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)


float previousWeekHigh = request.security(
     syminfo.tickerid,
     "W",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

float previousWeekLow = request.security(
     syminfo.tickerid,
     "W",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

float previousMonthHigh = request.security(
     syminfo.tickerid,
     "M",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

float previousMonthLow = request.security(
     syminfo.tickerid,
     "M",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

bool newDailySession = ta.change(time("D")) != 0
var float currentSessionHigh = na
var float currentSessionLow = na

if na(currentSessionHigh) or newDailySession
    currentSessionHigh := high
    currentSessionLow := low
else
    currentSessionHigh := math.max(currentSessionHigh, high)
    currentSessionLow := math.min(currentSessionLow, low)

float sessionVwap = ta.vwap(hlc3)

float avgVolume = ta.sma(volume, volumeLength)
float relVolume = not na(avgVolume) and avgVolume > 0.0 ? volume / avgVolume : na

float volumeMean = ta.sma(volume, zLength)
float volumeDev = ta.stdev(volume, zLength)
float volumeZ = not na(volumeDev) and volumeDev > 0.0 ? (volume - volumeMean) / volumeDev : na

float trueRangeValue = ta.tr(true)
float rangeMean = ta.sma(trueRangeValue, zLength)
float rangeDev = ta.stdev(trueRangeValue, zLength)
float rangeZ = not na(rangeDev) and rangeDev > 0.0 ? (trueRangeValue - rangeMean) / rangeDev : na

bool newsLikeEvent =
     not na(relVolume) and
     not na(volumeZ) and
     not na(rangeZ) and
     relVolume >= newsRelVol and
     volumeZ >= newsVolumeZ and
     rangeZ >= newsRangeZ

float htfClose1 = request.security(syminfo.tickerid, htfTimeframe1, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfFast1 = request.security(syminfo.tickerid, htfTimeframe1, ta.ema(close, htfEmaFastLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfSlow1 = request.security(syminfo.tickerid, htfTimeframe1, ta.ema(close, htfEmaSlowLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

float htfClose2 = request.security(syminfo.tickerid, htfTimeframe2, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfFast2 = request.security(syminfo.tickerid, htfTimeframe2, ta.ema(close, htfEmaFastLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfSlow2 = request.security(syminfo.tickerid, htfTimeframe2, ta.ema(close, htfEmaSlowLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

float htfClose3 = request.security(syminfo.tickerid, htfTimeframe3, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfFast3 = request.security(syminfo.tickerid, htfTimeframe3, ta.ema(close, htfEmaFastLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfSlow3 = request.security(syminfo.tickerid, htfTimeframe3, ta.ema(close, htfEmaSlowLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

int htfDirection1 = htfFast1 > htfSlow1 and htfClose1 > htfFast1 ? 1 : htfFast1 < htfSlow1 and htfClose1 < htfFast1 ? -1 : 0
int htfDirection2 = htfFast2 > htfSlow2 and htfClose2 > htfFast2 ? 1 : htfFast2 < htfSlow2 and htfClose2 < htfFast2 ? -1 : 0
int htfDirection3 = htfFast3 > htfSlow3 and htfClose3 > htfFast3 ? 1 : htfFast3 < htfSlow3 and htfClose3 < htfFast3 ? -1 : 0

float roundIncrement = f_roundIncrement(roundMode, customRoundIncrement)
float nearestRound = math.round(close / roundIncrement) * roundIncrement
float roundDistance = math.abs(close - nearestRound)
bool nearRoundSurface = roundDistance <= atrValue * roundToleranceATR


float intradayZoneThicknessPrice = syminfo.mintick * intradayZoneThicknessTicks
float swingZoneThicknessPrice = syminfo.mintick * swingZoneThicknessTicks

bool showPdhZone = drawIntradayKeyZones and usePreviousDayLevels and f_zoneRelevant(previousDayHigh, atrValue, intradayRelevantDistanceATR)
bool showPdlZone = drawIntradayKeyZones and usePreviousDayLevels and f_zoneRelevant(previousDayLow, atrValue, intradayRelevantDistanceATR)
bool showSessionHighZone = drawIntradayKeyZones and useSessionExtremes and f_zoneRelevant(currentSessionHigh, atrValue, intradayRelevantDistanceATR)
bool showSessionLowZone = drawIntradayKeyZones and useSessionExtremes and f_zoneRelevant(currentSessionLow, atrValue, intradayRelevantDistanceATR)
bool showVwapZone = drawIntradayKeyZones and useVwapKeyLevel and f_zoneRelevant(sessionVwap, atrValue, intradayRelevantDistanceATR)
bool showRoundZone = drawIntradayKeyZones and useRoundAsKeyLevel and f_zoneRelevant(nearestRound, atrValue, intradayRelevantDistanceATR)

bool showPwhZone = drawSwingKeyZones and f_zoneRelevant(previousWeekHigh, atrValue, swingRelevantDistanceATR)
bool showPwlZone = drawSwingKeyZones and f_zoneRelevant(previousWeekLow, atrValue, swingRelevantDistanceATR)
bool showPmhZone = drawSwingKeyZones and f_zoneRelevant(previousMonthHigh, atrValue, swingRelevantDistanceATR)
bool showPmlZone = drawSwingKeyZones and f_zoneRelevant(previousMonthLow, atrValue, swingRelevantDistanceATR)
bool showSwingHighZone = drawSwingKeyZones and useSwingKeyLevels and f_zoneRelevant(lastSwingHigh, atrValue, swingRelevantDistanceATR)
bool showSwingLowZone = drawSwingKeyZones and useSwingKeyLevels and f_zoneRelevant(lastSwingLow, atrValue, swingRelevantDistanceATR)
bool showManual1Zone = drawSwingKeyZones and useManualKeyLevel1 and f_zoneRelevant(manualKeyLevel1, atrValue, swingRelevantDistanceATR)
bool showManual2Zone = drawSwingKeyZones and useManualKeyLevel2 and f_zoneRelevant(manualKeyLevel2, atrValue, swingRelevantDistanceATR)

var box pdhZone = na
var box pdlZone = na
var box sessionHighZone = na
var box sessionLowZone = na
var box vwapZone = na
var box roundZone = na
var box pwhZone = na
var box pwlZone = na
var box pmhZone = na
var box pmlZone = na
var box swingHighZone = na
var box swingLowZone = na
var box manual1Zone = na
var box manual2Zone = na


var label pdhZoneName = na
var label pdlZoneName = na
var label sessionHighZoneName = na
var label sessionLowZoneName = na
var label vwapZoneName = na
var label roundZoneName = na
var label pwhZoneName = na
var label pwlZoneName = na
var label pmhZoneName = na
var label pmlZoneName = na
var label swingHighZoneName = na
var label swingLowZoneName = na
var label manual1ZoneName = na
var label manual2ZoneName = na

pdhZone := f_updateZone(pdhZone, showPdhZone, previousDayHigh, intradayZoneThicknessPrice, resistanceZoneColor, intradayZoneTransparency)
pdlZone := f_updateZone(pdlZone, showPdlZone, previousDayLow, intradayZoneThicknessPrice, supportZoneColor, intradayZoneTransparency)
sessionHighZone := f_updateZone(sessionHighZone, showSessionHighZone, currentSessionHigh, intradayZoneThicknessPrice, resistanceZoneColor, intradayZoneTransparency)
sessionLowZone := f_updateZone(sessionLowZone, showSessionLowZone, currentSessionLow, intradayZoneThicknessPrice, supportZoneColor, intradayZoneTransparency)
vwapZone := f_updateZone(vwapZone, showVwapZone, sessionVwap, intradayZoneThicknessPrice, referenceZoneColor, intradayZoneTransparency)
roundZone := f_updateZone(roundZone, showRoundZone, nearestRound, intradayZoneThicknessPrice, referenceZoneColor, intradayZoneTransparency)

pwhZone := f_updateZone(pwhZone, showPwhZone, previousWeekHigh, swingZoneThicknessPrice, resistanceZoneColor, swingZoneTransparency)
pwlZone := f_updateZone(pwlZone, showPwlZone, previousWeekLow, swingZoneThicknessPrice, supportZoneColor, swingZoneTransparency)
pmhZone := f_updateZone(pmhZone, showPmhZone, previousMonthHigh, swingZoneThicknessPrice, resistanceZoneColor, swingZoneTransparency)
pmlZone := f_updateZone(pmlZone, showPmlZone, previousMonthLow, swingZoneThicknessPrice, supportZoneColor, swingZoneTransparency)
swingHighZone := f_updateZone(swingHighZone, showSwingHighZone, lastSwingHigh, swingZoneThicknessPrice, resistanceZoneColor, swingZoneTransparency)
swingLowZone := f_updateZone(swingLowZone, showSwingLowZone, lastSwingLow, swingZoneThicknessPrice, supportZoneColor, swingZoneTransparency)
manual1Zone := f_updateZone(manual1Zone, showManual1Zone, manualKeyLevel1, swingZoneThicknessPrice, referenceZoneColor, swingZoneTransparency)
manual2Zone := f_updateZone(manual2Zone, showManual2Zone, manualKeyLevel2, swingZoneThicknessPrice, referenceZoneColor, swingZoneTransparency)


pdhZoneName := f_updateZoneName(
     pdhZoneName,
     showPdhZone,
     previousDayHigh,
     f_zoneNameText("PDH", "Previous-Day High"),
     "Previous-Day High — prior daily auction high and common intraday resistance/liquidity reference.",
     resistanceZoneColor
)

pdlZoneName := f_updateZoneName(
     pdlZoneName,
     showPdlZone,
     previousDayLow,
     f_zoneNameText("PDL", "Previous-Day Low"),
     "Previous-Day Low — prior daily auction low and common intraday support/liquidity reference.",
     supportZoneColor
)

sessionHighZoneName := f_updateZoneName(
     sessionHighZoneName,
     showSessionHighZone,
     currentSessionHigh,
     f_zoneNameText("SESH", "Session High"),
     "Current Session High — developing high of the active daily session.",
     resistanceZoneColor
)

sessionLowZoneName := f_updateZoneName(
     sessionLowZoneName,
     showSessionLowZone,
     currentSessionLow,
     f_zoneNameText("SESL", "Session Low"),
     "Current Session Low — developing low of the active daily session.",
     supportZoneColor
)

vwapZoneName := f_updateZoneName(
     vwapZoneName,
     showVwapZone,
     sessionVwap,
     f_zoneNameText("VWAP", "Session VWAP"),
     "Session VWAP — volume-weighted mean price for the active session.",
     referenceZoneColor
)

roundZoneName := f_updateZoneName(
     roundZoneName,
     showRoundZone,
     nearestRound,
     f_zoneNameText("RN", "Round Number"),
     "Nearest Round Number — configured psychological-price reference.",
     referenceZoneColor
)

pwhZoneName := f_updateZoneName(
     pwhZoneName,
     showPwhZone,
     previousWeekHigh,
     f_zoneNameText("PWH", "Previous-Week High"),
     "Previous-Week High — completed weekly auction high and swing reference.",
     resistanceZoneColor
)

pwlZoneName := f_updateZoneName(
     pwlZoneName,
     showPwlZone,
     previousWeekLow,
     f_zoneNameText("PWL", "Previous-Week Low"),
     "Previous-Week Low — completed weekly auction low and swing reference.",
     supportZoneColor
)

pmhZoneName := f_updateZoneName(
     pmhZoneName,
     showPmhZone,
     previousMonthHigh,
     f_zoneNameText("PMH", "Previous-Month High"),
     "Previous-Month High — completed monthly auction high and macro resistance reference.",
     resistanceZoneColor
)

pmlZoneName := f_updateZoneName(
     pmlZoneName,
     showPmlZone,
     previousMonthLow,
     f_zoneNameText("PML", "Previous-Month Low"),
     "Previous-Month Low — completed monthly auction low and macro support reference.",
     supportZoneColor
)

swingHighZoneName := f_updateZoneName(
     swingHighZoneName,
     showSwingHighZone,
     lastSwingHigh,
     f_zoneNameText("SH", "Confirmed Swing High"),
     "Confirmed Swing High — most recent pivot high confirmed after the configured right-side bars.",
     resistanceZoneColor
)

swingLowZoneName := f_updateZoneName(
     swingLowZoneName,
     showSwingLowZone,
     lastSwingLow,
     f_zoneNameText("SL", "Confirmed Swing Low"),
     "Confirmed Swing Low — most recent pivot low confirmed after the configured right-side bars.",
     supportZoneColor
)

manual1ZoneName := f_updateZoneName(
     manual1ZoneName,
     showManual1Zone,
     manualKeyLevel1,
     f_zoneNameText("M1", "Manual Key Level 1"),
     "Manual Key Level 1 — user-defined price reference.",
     referenceZoneColor
)

manual2ZoneName := f_updateZoneName(
     manual2ZoneName,
     showManual2Zone,
     manualKeyLevel2,
     f_zoneNameText("M2", "Manual Key Level 2"),
     "Manual Key Level 2 — user-defined price reference.",
     referenceZoneColor
)


// =================================================================================================
// 09. PATTERN ENGINE — GEOMETRY ONLY
// =================================================================================================

bool bullishHammer =
     enableHammerStar and
     lowerWick >= candleBody * wickBodyRatio and
     upperWick <= candleBody * oppositeWickMaxBody and
     closeLocation >= 0.55

bool bearishShootingStar =
     enableHammerStar and
     upperWick >= candleBody * wickBodyRatio and
     lowerWick <= candleBody * oppositeWickMaxBody and
     closeLocation <= 0.45

bool bullishEngulfing =
     enableEngulfing and
     close > open and
     close[1] < open[1] and
     open <= close[1] and
     close >= open[1]

bool bearishEngulfing =
     enableEngulfing and
     close < open and
     close[1] > open[1] and
     open >= close[1] and
     close <= open[1]

bool bullishPin =
     enablePinBars and
     lowerWick >= candleRange * 0.55 and
     closeLocation >= 0.60 and
     bodyPct <= 0.35

bool bearishPin =
     enablePinBars and
     upperWick >= candleRange * 0.55 and
     closeLocation <= 0.40 and
     bodyPct <= 0.35

bool bullishOutside =
     enableOutside and
     high > high[1] and
     low < low[1] and
     close > open and
     close > (high + low) / 2.0

bool bearishOutside =
     enableOutside and
     high > high[1] and
     low < low[1] and
     close < open and
     close < (high + low) / 2.0

bool morningStar =
     enableThreeBarStars and
     close[2] < open[2] and
     math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.35 and
     close > open and
     close >= (open[2] + close[2]) / 2.0

bool eveningStar =
     enableThreeBarStars and
     close[2] > open[2] and
     math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.35 and
     close < open and
     close <= (open[2] + close[2]) / 2.0

int patternDirection =
     bullishHammer or bullishEngulfing or bullishPin or bullishOutside or morningStar ? 1 :
     bearishShootingStar or bearishEngulfing or bearishPin or bearishOutside or eveningStar ? -1 :
     0

string patternName =
     bullishHammer ? "Bullish Hammer" :
     bearishShootingStar ? "Bearish Shooting Star" :
     bullishEngulfing ? "Bullish Engulfing" :
     bearishEngulfing ? "Bearish Engulfing" :
     bullishPin ? "Bullish Pin Bar" :
     bearishPin ? "Bearish Pin Bar" :
     bullishOutside ? "Bullish Outside Reversal" :
     bearishOutside ? "Bearish Outside Reversal" :
     morningStar ? "Morning Star" :
     eveningStar ? "Evening Star" :
     "None"

string patternAbbreviation =
     bullishHammer ? "HM" :
     bearishShootingStar ? "SS" :
     bullishEngulfing or bearishEngulfing ? "ENG" :
     bullishPin or bearishPin ? "PIN" :
     bullishOutside or bearishOutside ? "OUT" :
     morningStar ? "MS" :
     eveningStar ? "ES" :
     ""

float wickDominance =
     patternDirection == 1 ? f_safeDiv(lowerWick, candleRange, 0.0) :
     patternDirection == -1 ? f_safeDiv(upperWick, candleRange, 0.0) :
     0.0

float directionalCloseQuality =
     patternDirection == 1 ? closeLocation :
     patternDirection == -1 ? 1.0 - closeLocation :
     0.0

float patternQuality = f_clamp(
     wickDominance * 45.0 +
     directionalCloseQuality * 35.0 +
     (1.0 - bodyPct) * 20.0,
     0.0,
     100.0
)

bool rawPatternDetected = patternDirection != 0 and patternQuality >= minPatternQuality


// =================================================================================================
// 10. CANDIDATE CONTEXT SNAPSHOT
// =================================================================================================

bool bullishUnsweptLiquidity =
     patternDirection == 1 and
     not na(lastSwingLow) and
     lastSwingLow < low and
     low - lastSwingLow <= atrValue * nearbyLiquidityATR

bool bearishUnsweptLiquidity =
     patternDirection == -1 and
     not na(lastSwingHigh) and
     lastSwingHigh > high and
     lastSwingHigh - high <= atrValue * nearbyLiquidityATR

bool nearbyUnsweptLiquidity = bullishUnsweptLiquidity or bearishUnsweptLiquidity

bool htfContradiction1 =
     patternDirection == 1 and htfDirection1 == -1 or
     patternDirection == -1 and htfDirection1 == 1

bool htfContradiction2 =
     patternDirection == 1 and htfDirection2 == -1 or
     patternDirection == -1 and htfDirection2 == 1

bool htfContradiction3 =
     patternDirection == 1 and htfDirection3 == -1 or
     patternDirection == -1 and htfDirection3 == 1

int htfContradictionCount =
     (htfContradiction1 ? 1 : 0) +
     (htfContradiction2 ? 1 : 0) +
     (htfContradiction3 ? 1 : 0)

bool htfContradiction = htfContradictionCount >= minimumHtfContradictionsForWarning

string htfOppositionText = ""
htfOppositionText := htfContradiction1 ? f_tfText(htfTimeframe1) : htfOppositionText
htfOppositionText := htfContradiction2 ? (htfOppositionText == "" ? f_tfText(htfTimeframe2) : htfOppositionText + "+" + f_tfText(htfTimeframe2)) : htfOppositionText
htfOppositionText := htfContradiction3 ? (htfOppositionText == "" ? f_tfText(htfTimeframe3) : htfOppositionText + "+" + f_tfText(htfTimeframe3)) : htfOppositionText

bool roundSurfaceBounce =
     nearRoundSurface and
     (
          patternDirection == 1 and low >= nearestRound or
          patternDirection == -1 and high <= nearestRound
     )

float candidateLevel = patternDirection == 1 ? low : high
int candidateTouchCount = patternDirection != 0 ? f_countTouches(candidateLevel, atrValue * touchToleranceATR, touchLookback, minimumTouchSeparation) : 0
bool repeatedLevel = candidateTouchCount >= overTestedTouches

float keyDistanceRaw = 1.0e10
int keyConfluenceCount = 0
float keyThresholdPrice = atrValue * keyLevelProximityATR

if patternDirection == 1
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, usePreviousDayLevels, previousDayLow, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useSessionExtremes, currentSessionLow, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useSwingKeyLevels, lastSwingLow, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useVwapKeyLevel, sessionVwap, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useRoundAsKeyLevel, nearestRound, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useManualKeyLevel1, manualKeyLevel1, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useManualKeyLevel2, manualKeyLevel2, candidateLevel)

    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, usePreviousDayLevels, previousDayLow, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useSessionExtremes, currentSessionLow, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useSwingKeyLevels, lastSwingLow, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useVwapKeyLevel, sessionVwap, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useRoundAsKeyLevel, nearestRound, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useManualKeyLevel1, manualKeyLevel1, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useManualKeyLevel2, manualKeyLevel2, candidateLevel, keyThresholdPrice)
else if patternDirection == -1
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, usePreviousDayLevels, previousDayHigh, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useSessionExtremes, currentSessionHigh, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useSwingKeyLevels, lastSwingHigh, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useVwapKeyLevel, sessionVwap, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useRoundAsKeyLevel, nearestRound, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useManualKeyLevel1, manualKeyLevel1, candidateLevel)
    keyDistanceRaw := f_minEnabledDistance(keyDistanceRaw, useManualKeyLevel2, manualKeyLevel2, candidateLevel)

    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, usePreviousDayLevels, previousDayHigh, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useSessionExtremes, currentSessionHigh, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useSwingKeyLevels, lastSwingHigh, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useVwapKeyLevel, sessionVwap, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useRoundAsKeyLevel, nearestRound, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useManualKeyLevel1, manualKeyLevel1, candidateLevel, keyThresholdPrice)
    keyConfluenceCount := f_countEnabledNear(keyConfluenceCount, useManualKeyLevel2, manualKeyLevel2, candidateLevel, keyThresholdPrice)

float nearestKeyLevelDistanceATR = keyDistanceRaw >= 1.0e9 ? na : f_safeDiv(keyDistanceRaw, atrValue, na)
bool nearKeyLevel = not na(nearestKeyLevelDistanceATR) and nearestKeyLevelDistanceATR <= keyLevelProximityATR
bool awayFromKeyLevels = patternDirection != 0 and not nearKeyLevel

float locationPenaltyMultiplier = awayFromKeyLevels ? math.max(0.0, 1.0 - awayFromKeyLevelPenalty / 100.0) : 1.0
float confluenceBonus = nearKeyLevel ? math.max(keyConfluenceCount - 1, 0) * keyLevelConfluenceBonus : 0.0
float adjustedSetupQuality = f_clamp(patternQuality * locationPenaltyMultiplier + confluenceBonus, 0.0, 100.0)

float liveTrapScore =
     (poorLocation ? poorLocationWeight : 0.0) +
     (nearbyUnsweptLiquidity ? unsweptLiquidityWeight : 0.0) +
     (roundSurfaceBounce ? roundSurfaceWeight : 0.0) +
     (newsLikeEvent ? newsLikeWeight : 0.0) +
     (htfContradiction ? htfContradictionWeight : 0.0) +
     (htfContradictionCount > 1 ? (htfContradictionCount - 1) * htfStackBonus : 0.0) +
     (repeatedLevel ? overTestedWeight : 0.0) +
     (awayFromKeyLevels ? awayFromKeyLevelWeight : 0.0)

liveTrapScore := f_clamp(liveTrapScore, 0.0, 100.0)

string liveReasons = ""
liveReasons := f_appendReason(liveReasons, awayFromKeyLevels, "The candle pattern formed away from every enabled key level of interest. Geometry without location is a retail lure, not confirmation.")
liveReasons := f_appendReason(liveReasons, nearKeyLevel and keyConfluenceCount == 1, "Only one enabled key level supports the reversal location.")
liveReasons := f_appendReason(liveReasons, poorLocation, "Textbook reversal formed near rolling-range equilibrium, not at a meaningful extreme.")
liveReasons := f_appendReason(liveReasons, nearbyUnsweptLiquidity, patternDirection == 1 ? "A confirmed swing low remains unswept below the bullish reversal." : "A confirmed swing high remains unswept above the bearish reversal.")
liveReasons := f_appendReason(liveReasons, roundSurfaceBounce, "Price touched a psychological number without first sweeping and reclaiming it.")
liveReasons := f_appendReason(liveReasons, newsLikeEvent, "Abnormal volume and true-range expansion resembles a news-like conviction event; ordinary reversal logic is suppressed.")
liveReasons := f_appendReason(liveReasons, htfContradiction, "The reversal opposes " + str.tostring(htfContradictionCount) + " of 3 HTFs: " + htfOppositionText + ". This supports continuation against the apparent reversal.")
liveReasons := f_appendReason(liveReasons, repeatedLevel, "The candidate level has already been tested " + str.tostring(candidateTouchCount) + " times; repeated defense may be weakening.")

// =================================================================================================
// 11. PERSISTENT CANDIDATE STATE
// =================================================================================================

var bool candidateActive = false
var int candidateId = 0
var int candidateDirection = 0
var int candidateBirthBar = na
var int candidateBirthTime = na
var float candidateHigh = na
var float candidateLow = na
var float candidateMid = na
var float candidatePatternQuality = na
var float candidateTrapScore = na
var string candidatePatternName = "None"
var string candidateReasons = ""
var string candidateHtfOpposition = "None"
var int candidateHtfContradictionCount = 0
var bool candidateWarningIssued = false
var bool candidateTrapIssued = false

bool candidateExpired = candidateActive and bar_index - candidateBirthBar > candidateLifeBars

bool bullishFailure =
     candidateActive and
     candidateDirection == 1 and
     close < candidateLow - atrValue * failureBufferATR

bool bearishFailure =
     candidateActive and
     candidateDirection == -1 and
     close > candidateHigh + atrValue * failureBufferATR

bool reversalFailure = evaluationGate and (bullishFailure or bearishFailure)

bool candidateReversalProgress =
     candidateActive and
     (
          candidateDirection == 1 and close > candidateHigh or
          candidateDirection == -1 and close < candidateLow
     )

if candidateExpired or candidateReversalProgress
    candidateActive := false
    candidateWarningIssued := false
    candidateTrapIssued := false

bool allowNewCandidate = not candidateActive

bool createCandidate =
     evaluationGate and
     adjustedSetupQuality >= minPatternQuality and
     allowNewCandidate and
     (not showOnlyHighRiskCandidates or liveTrapScore >= probableTrapScore)

if createCandidate
    candidateId += 1
    candidateActive := true
    candidateDirection := patternDirection
    candidateBirthBar := bar_index
    candidateBirthTime := time
    candidateHigh := high
    candidateLow := low
    candidateMid := (high + low) / 2.0
    candidatePatternQuality := adjustedSetupQuality
    candidateTrapScore := liveTrapScore
    candidatePatternName := patternName
    candidateReasons := liveReasons == "" ? "• No major trap proxy was active on the pattern bar; confirmation is still required." : liveReasons
    candidateHtfOpposition := htfOppositionText == "" ? "None" : htfOppositionText
    candidateHtfContradictionCount := htfContradictionCount
    candidateWarningIssued := false
    candidateTrapIssued := false

bool retailTrapWarning =
     createCandidate and
     liveTrapScore >= warningTrapScore

bool confirmedBoobyTrap =
     reversalFailure and
     not candidateTrapIssued and
     candidateTrapScore >= confirmedTrapScore

bool lowScoreFailure =
     reversalFailure and
     not candidateTrapIssued and
     candidateTrapScore < confirmedTrapScore

if reversalFailure
    candidateTrapIssued := true
    candidateActive := false


// =================================================================================================
// 12. HISTORICAL MARKERS AND EXPLANATIONS
// =================================================================================================

// Candidate and warning events use label objects because plotshape() cannot carry hover tooltips.
// Labels are bounded and recycled to preserve performance.

bool displayOff = displayMode == "Off"
bool stealthMode = displayMode == "Stealth"
bool iconOnlyMode = displayMode == "Icon Only"
bool compactMode = displayMode == "Compact"
bool verboseMode = displayMode == "Verbose"

string candidateTooltip =
     patternName + " — REVERSAL CANDIDATE\n\n" +
     "Adjusted Setup Quality: " + f_scoreText(adjustedSetupQuality) + "\n" +
     "Trap Risk At Birth: " + f_scoreText(liveTrapScore) + "\n" +
     "Key-Level Distance: " + (na(nearestKeyLevelDistanceATR) ? "n/a" : str.tostring(nearestKeyLevelDistanceATR, "#.##") + " ATR") + "\n" +
     "Key-Level Confluence: " + str.tostring(keyConfluenceCount) + "\n" +
     "Opposing HTFs: " + (htfOppositionText == "" ? "None" : htfOppositionText) + "\n\n" +
     "Context:\n" + (liveReasons == "" ? "• No major trap proxy active yet. Await structural confirmation." : liveReasons) + "\n\n" +
     "Retail warning:\nA reversal candle is only a candidate. Location, liquidity sequence, HTF permission, and follow-through remain unproven."

string warningTooltip =
     patternName + " — RETAIL TRAP WARNING\n\n" +
     "Trap Risk: " + f_scoreText(liveTrapScore) + "\n" +
     "Opposing HTFs: " + (htfOppositionText == "" ? "None" : htfOppositionText) + "\n" +
     "Adjusted Quality: " + f_scoreText(adjustedSetupQuality) + "\n\n" +
     "Why caution is elevated:\n" + (liveReasons == "" ? "• Context has not justified reversal confirmation." : liveReasons) + "\n\n" +
     "Decision:\nWAIT. Do not treat candle geometry as reversal proof."

var array<label> candidateLabels = array.new<label>()
var array<label> warningLabels = array.new<label>()

if not displayOff and not stealthMode and showCandidateMarkers and createCandidate
    float candidateY = patternDirection == 1 ? low - atrValue * 0.12 : high + atrValue * 0.12
    label candidateLabel = label.new(
         bar_index,
         candidateY,
         f_candidateChartText(displayMode, patternAbbreviation, patternName, adjustedSetupQuality),
         xloc=xloc.bar_index,
         style=patternDirection == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(neutralColor, 35),
         textcolor=color.white,
         size=f_labelSize(candidateLabelSizeInput)
    )
    label.set_tooltip(candidateLabel, candidateTooltip)
    array.push(candidateLabels, candidateLabel)

    if array.size(candidateLabels) > maximumHistoricalLabels
        label oldestCandidate = array.shift(candidateLabels)
        label.delete(oldestCandidate)

if not displayOff and not stealthMode and retailTrapWarning
    float warningY = patternDirection == 1 ? high + atrValue * 0.20 : low - atrValue * 0.20
    string warningText = f_warningChartText(displayMode, htfOppositionText, liveTrapScore)
    label warningLabel = label.new(
         bar_index,
         warningY,
         warningText,
         xloc=xloc.bar_index,
         style=patternDirection == 1 ? label.style_label_down : label.style_label_up,
         color=trapColor,
         textcolor=color.white,
         size=f_labelSize(warningLabelSizeInput)
    )
    label.set_tooltip(warningLabel, warningTooltip)
    array.push(warningLabels, warningLabel)

    if array.size(warningLabels) > maximumHistoricalLabels
        label oldestWarning = array.shift(warningLabels)
        label.delete(oldestWarning)

var array<label> trapLabels = array.new<label>()

if not displayOff and showHistoricalTrapLabels and (confirmedBoobyTrap or (verboseMode and showFailedReversalLabels and lowScoreFailure))
    string classification = confirmedBoobyTrap ? "CONFIRMED BOOBY TRAP" : "FAILED REVERSAL — LOW CONTEXT SCORE"
    string continuationText =
         candidateDirection == 1 ?
         "Retail saw a bullish reversal. Price instead broke beneath the candidate low and resumed bearish auction." :
         "Retail saw a bearish reversal. Price instead broke above the candidate high and resumed bullish auction."

    string tooltipText =
         candidatePatternName + " — " + classification + "\n\n" +
         "Pattern Quality: " + f_scoreText(candidatePatternQuality) + "\n" +
         "Trap Risk At Birth: " + f_scoreText(candidateTrapScore) + "\n" +
         "Candidate ID: " + str.tostring(candidateId) + "\n" +
         "Associated Opposing HTFs: " + candidateHtfOpposition + "\n" +
         "HTF Conflict Count: " + str.tostring(candidateHtfContradictionCount) + " of 3\n\n" +
         "Why retail could be trapped:\n" +
         candidateReasons + "\n\n" +
         "Observed failure:\n• " + continuationText + "\n\n" +
         "Decision:\n" + (confirmedBoobyTrap ? "AVOID / CONTINUATION TRAP CONFIRMED" : "REVERSAL FAILED, BUT INITIAL TRAP EVIDENCE WAS LIMITED")

    float labelY = candidateDirection == 1 ? high + atrValue * trapLabelOffsetATR : low - atrValue * trapLabelOffsetATR
    label trapLabel = label.new(
         bar_index,
         labelY,
         confirmedBoobyTrap ? f_trapChartText(displayMode, candidateHtfOpposition, candidateTrapScore) : "FAIL",
         xloc=xloc.bar_index,
         style=candidateDirection == 1 ? label.style_label_down : label.style_label_up,
         color=confirmedBoobyTrap ? trapColor : neutralColor,
         textcolor=color.white,
         size=f_labelSize(trapLabelSizeInput)
    )
    label.set_tooltip(trapLabel, tooltipText)
    array.push(trapLabels, trapLabel)

    if array.size(trapLabels) > maximumHistoricalLabels
        label oldestLabel = array.shift(trapLabels)
        label.delete(oldestLabel)


// =================================================================================================
// 13. DASHBOARD
// =================================================================================================

var table dashboard = na

if showDashboard and na(dashboard)
    dashboard := table.new(position.top_right, 2, 18, border_width=1)

if showDashboard and barstate.islast and not na(dashboard)
    color panelBg = color.new(color.black, 74)
    color valueBg = color.new(neutralColor, 82)
    color headerBg = color.new(candidateActive ? trapColor : neutralColor, 55)

    table.cell(dashboard, 0, 0, "BOOBY TRAP DETECTOR", text_color=color.white, bgcolor=headerBg, text_size=size.tiny)
    table.cell(dashboard, 1, 0, "PHASE 1F", text_color=color.white, bgcolor=headerBg, text_size=size.tiny)

    table.cell(dashboard, 0, 1, "Candidate", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 1, candidateActive ? candidatePatternName : "None", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 2, "Direction", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 2, candidateActive ? f_directionText(candidateDirection) : "Neutral", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 3, "Adjusted Quality", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 3, candidateActive ? f_scoreText(candidatePatternQuality) : "n/a", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 4, "Trap Risk", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 4, candidateActive ? f_scoreText(candidateTrapScore) : "n/a", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 5, "Range Position", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 5, str.tostring(rangePosition, "#.##"), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 6, "Nearest Swing Low", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 6, na(lastSwingLow) ? "n/a" : str.tostring(lastSwingLow, format.mintick), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 7, "Nearest Swing High", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 7, na(lastSwingHigh) ? "n/a" : str.tostring(lastSwingHigh, format.mintick), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 8, "HTF 1 " + f_tfText(htfTimeframe1), text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 8, f_directionText(htfDirection1), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 9, "HTF 2 " + f_tfText(htfTimeframe2), text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 9, f_directionText(htfDirection2), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 10, "HTF 3 " + f_tfText(htfTimeframe3), text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 10, f_directionText(htfDirection3), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 11, "Opposing HTFs", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 11, htfOppositionText == "" ? "None" : htfOppositionText, text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 12, "Volume Event", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 12, newsLikeEvent ? "NEWS-LIKE PROXY" : "Normal", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 13, "Key-Level Distance", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 13, na(nearestKeyLevelDistanceATR) ? "n/a" : str.tostring(nearestKeyLevelDistanceATR, "#.##") + " ATR", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 14, "Key Confluence", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 14, str.tostring(keyConfluenceCount), text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 15, "Intraday Zones", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 15, drawIntradayKeyZones ? zoneVisibilityMode : "Off", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 16, "Swing Zones", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 16, drawSwingKeyZones ? zoneVisibilityMode : "Off", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

    table.cell(dashboard, 0, 17, "Decision", text_color=color.white, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 17, candidateActive ? (candidateTrapScore >= warningTrapScore ? "RETAIL WARNING / WAIT" : awayFromKeyLevels ? "LOW QUALITY / WAIT" : "MONITOR") : "NO ACTIVE CANDIDATE", text_color=color.white, bgcolor=valueBg, text_size=size.tiny)

if not showDashboard and not na(dashboard)
    table.delete(dashboard)
    dashboard := na


// =================================================================================================
// 14. DEBUG TABLE
// =================================================================================================

var table debugTable = na

if showDebug and na(debugTable)
    debugTable := table.new(position.bottom_right, 2, 15, border_width=1)

if showDebug and barstate.islast and not na(debugTable)
    color debugBg = color.new(color.black, 72)
    color debugValueBg = color.new(neutralColor, 82)

    table.cell(debugTable, 0, 0, "DEBUG", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 0, "PHASE 1F", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)

    table.cell(debugTable, 0, 1, "patternDirection", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 1, str.tostring(patternDirection), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 2, "patternQuality", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 2, f_scoreText(patternQuality), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 3, "rangePosition", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 3, str.tostring(rangePosition, "#.###"), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 4, "touchCount", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 4, str.tostring(candidateTouchCount), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 5, "unsweptLiquidity", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 5, str.tostring(nearbyUnsweptLiquidity), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 6, "roundSurface", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 6, str.tostring(roundSurfaceBounce), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 7, "relativeVolume", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 7, na(relVolume) ? "n/a" : str.tostring(relVolume, "#.##"), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 8, "volumeZ", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 8, na(volumeZ) ? "n/a" : str.tostring(volumeZ, "#.##"), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 9, "rangeZ", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 9, na(rangeZ) ? "n/a" : str.tostring(rangeZ, "#.##"), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 10, "htfDirections", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 10, str.tostring(htfDirection1) + "/" + str.tostring(htfDirection2) + "/" + str.tostring(htfDirection3), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 11, "liveTrapScore", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 11, f_scoreText(liveTrapScore), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 12, "adjustedQuality", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 12, f_scoreText(adjustedSetupQuality), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 13, "keyDistanceATR", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 13, na(nearestKeyLevelDistanceATR) ? "n/a" : str.tostring(nearestKeyLevelDistanceATR, "#.###"), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

    table.cell(debugTable, 0, 14, "keyConfluence", text_color=color.white, bgcolor=debugBg, text_size=size.tiny)
    table.cell(debugTable, 1, 14, str.tostring(keyConfluenceCount), text_color=color.white, bgcolor=debugValueBg, text_size=size.tiny)

if not showDebug and not na(debugTable)
    table.delete(debugTable)
    debugTable := na


// =================================================================================================
// 15. ALERTS
// =================================================================================================

alertcondition(createCandidate, "BTD — New Reversal Candidate", "Candle Majick: new reversal candidate. Review the dashboard and pattern-bar context.")
alertcondition(retailTrapWarning, "BTD — Retail Trap Warning", "Candle Majick: reversal candle has elevated trap risk before confirmation.")
alertcondition(confirmedBoobyTrap, "BTD — Confirmed Booby Trap", "Candle Majick: reversal failed and continuation trap is confirmed.")
alertcondition(lowScoreFailure, "BTD — Failed Reversal", "Candle Majick: reversal candidate failed, but initial trap context score was below the confirmed threshold.")
````
