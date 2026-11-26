# QM Range (DAFE)

- url: https://www.tradingview.com/script/HHRVGKLr-QM-Range-DAFE/
- type: indicator
- pine_id: PUB;f1ee8dd284c74140a012cd300c74084f
- version: 1.0

## Description

[b]Quasimodo Range Engine[DAFE][/b]
[b]A Systematic Framework for Liquidity, Structure, and Range Analysis[/b]
A Mechanical Approach to Decoding Market Microstructure and Order Flow.

[b]🎓 THEORETICAL FOUNDATION[/b]

The Quasimodo Range Engine (QM-R) is a comprehensive analytical framework designed to map market structure by tracking the flow of liquidity. It is built on the premise that markets frequently engineer liquidity through temporary sweeps of established pivot points, trapping breakout participants before initiating a reversal that breaks local structure.
This specific sequence—a liquidity sweep followed by a structural failure—is classically known as the Quasimodo (QM) pattern. However, the QM-R engine goes beyond simply identifying isolated patterns. It utilizes these patterns as the foundational building blocks to define active trading ranges, track structural shifts (BOS/CHoCH), and project fading Supply and Demand zones.

[b]Architectural Pillars[/b]
[b]Pillar 1: 3-Candle Fractal (3CF) Liquidity Mapping[/b]
The engine continuously scans for 3-Candle Fractals to identify strict, algorithmic swing highs and lows. It projects horizontal "Liquidity Lines" forward in time from these pivots. These lines represent resting liquidity pools. When price intersects these lines, the engine monitors the reaction to determine if it is a genuine breakout or a liquidity sweep.

[b]Pillar 2: Mechanical Quasimodo Detection[/b]
A QM pattern is registered only when a strict sequence of events occurs within a user-defined validity window (QM Break Lookback):
[b]The Sweep:[/b] Price must cross a previously established 3CF Liquidity Line.
[b]The Rejection:[/b] Price must reverse, closing back within the previous structure.
[b]The Break:[/b] Price must then impulsively break the opposing fractal pivot that originated the sweep.
When this sequence completes, the engine draws the QM zone, labels the pattern, and plots a "Trap Vector" showing the mechanics of the sweep-and-break.

[b]Pillar 3: Automated Equilibrium Range Formation[/b]
A single QM pattern is a localized event; two opposing QM patterns define a market regime. When a Bullish QM and a Bearish QM form within a specific proximity to each other (Max QM1-QM2 Gap), the engine links them. It establishes the high and low of this sequence as an active Equilibrium Range (ERL/ERH), framing the current consolidated price action.

[b]Pillar 4: Structural Resolution (BOS / CHoCH)[/b]
Once a range is established, the engine monitors its boundaries. A confirmed candle close outside the Equilibrium Range signifies a structural resolution.
[b]Break of Structure (BOS):[/b] A break in the direction of the dominant macro trend.
[b]Change of Character (CHoCH):[/b] A break opposing the established range context.
Upon resolution, the active range is dissolved, and the broken boundary leaves behind a [b]Ghost Line[/b]—a historical memory of broken structure that often serves as future, flipped support/resistance.

[b]Pillar 5: Reactive Supply & Demand Origination[/b]
Immediately following a BOS or CHoCH, the engine traces back a user-defined number of bars (SD Formation Lookback) to locate the origin candle of the impulsive move. It automatically draws a Supply or Demand zone from this origin. Crucially, these zones feature a degradation mechanic: they fade in opacity with each subsequent price touch, visually representing the consumption of resting orders until they are completely invalidated.

[b]Pillar 6: Footprint Delta Integration & Trap Validation[/b]
To validate the "liquidity sweep" phase of the QM pattern, the engine integrates real order flow. If Footprint data is enabled, it analyzes the tick-level delta during the exact candle that swept the pivot.
If a Bullish QM features heavy negative delta (selling) during the downward sweep, it confirms that sellers were successfully trapped.
If Footprint data is unavailable, the engine automatically deploys a sophisticated OHLCV synthetic delta fallback to estimate the intrabar pressure.

[b]Pillar 7: Integrated Trade Evaluation Engine[/b]
The script includes an internal statistical engine that evaluates the hypothetical performance of every detected QM pattern based on user-defined Risk/Reward parameters (SL Ticks / TP Ticks). It calculates whether historical setups achieved the minimum required R:R, feeding this data into the dashboard to provide an objective win-rate metric for the current asset and timeframe.

[b]🔧 COMPREHENSIVE INPUT SYSTEM[/b]

[b]🔍 Detection Engine[/b]
[b]QM Break Lookback:[/b] The maximum allowable bars between a liquidity sweep and the subsequent structural break. Prevents identifying drawn-out, unrelated price action as a QM.
[b]Max QM1-QM2 Gap:[/b] The maximum bar distance between opposing QM patterns to form a valid Equilibrium Range.
[b]SD Formation Lookback:[/b] How far back the engine searches to find the origin candle for a Supply/Demand zone after a structural break.

[b]👣 Real Orderflow (Footprint)[/b]
[b]Enable Real Footprint Delta:[/b] Toggles the use of TradingView Premium tick-level data for precise trap validation and dashboard metrics.
[b]Ticks per Row / Value Area %:[/b] Granularity controls for the background footprint processing.

[b]📐 Trade Evaluation (SL/TP)[/b]
[b]Stop Loss / Take Profit (Ticks):[/b] The parameters used by the internal statistical engine to back-test the historical success rate of detected QM patterns.
[b]Min R:R Ratio:[/b] The threshold required for the dashboard to classify a historical pattern as "Profitable."

[b]⚡ Performance Settings[/b]
[b]Max History Limits:[/b] Memory management controls (Max 3CF, Max QM, Max Zones) to ensure the indicator runs smoothly on deep charts without exceeding Pine Script limits.
*[b]Zone Touch Limit:[/b] The exact number of times price can tap a Supply/Demand zone before it is permanently deleted from the chart.

[b]🎨 Display Options[/b]
Granular toggles for every visual element: 3CF Markers, Liquidity Lines, QM Patterns, Range Boundaries, BOS/CHoCH Lines, Ghost Lines, and Fading SD Zones.

[b]📊 ANALYTICS DASHBOARD[/b]
The script features a highly detailed, non-intrusive HUD (Heads-Up Display) that provides a real-time statistical overview of the market structure.
[b]Macro Context (RCM Integration):[/b] Displays the current market regime (Pro-Trend, Counter-Trend, Neutral) and Structural Integrity via the imported Ricci Curvature Machine (RCM) library.
[b]Footprint Data:[/b] Displays the live, tick-level Buy Volume, Sell Volume, Delta, Point of Control (POC), and Value Area (VAH/VAL) for the current developing bar.
[b]QM Metrics & Range State:[/b] Tracks whether an Equilibrium Range is currently active. Displays the total count of Bullish and Bearish QMs, calculating their exact percentage weighting in the current market.
[b]Structural Statistics:[/b] Maintains a running tally of Trapped Volume occurrences, Total Bull BOS, Total Bear CHoCH, Active SD Zones, and active Ghost Lines.
[b]Performance Evaluation:[/b] Outputs the percentage of historical QM patterns that successfully achieved the user's defined Risk:Reward ratio, alongside the average delta recorded during those setups.
[b]Narrative Footer:[/b] A dynamically updating text panel that translates the raw data into a readable market narrative (e.g., "Heavy directional dominance," "Order flow balanced").

[b]🎨 VISUAL SYSTEM[/b]

The [b]Quasimodo Range Engine[/b] is fundamentally a visual tool. Every line, box, and label drawn on the chart is a direct representation of the engine's analytical process. It is designed to tell a clear, objective story of how liquidity is being engineered and how market structure is evolving in response. Understanding these visual components is key to leveraging the engine's full analytical power.

[b]Liquidity Mapping: 3CF Pivots & Lines[/b]
This is the foundational layer of the entire system.
[b]3CF Markers (○):[/b] A small, colored circle marks every confirmed 3-Candle Fractal pivot. These are the raw, objective swing points that the engine identifies as potential liquidity pools.
[b]Liquidity Lines (Dotted):[/b] A dotted horizontal line is projected forward in time from every 3CF Marker. This line represents the precise price level of untapped liquidity. The line continues to extend until price trades through it, at which point it stops, providing a clean visual confirmation that the liquidity at that level has been "swept" or "taken."
[image]https://www.tradingview.com/x/HtVAQLqb/[/image]

[b]The Quasimodo Pattern: A Complete Visual Narrative[/b]
When a full QM pattern is confirmed, the engine draws a composite visual to provide a complete summary of the event.
[b]The QM Zone (Box):[/b] A colored box highlights the entire price range of the QM pattern, from its origin pivot to the structural break. The color indicates its nature (Bullish or Bearish) and is brighter if a "trap" was detected, signaling higher conviction.
[b]Sweep & Break Lines:[/b] Two horizontal lines provide the core narrative. The dashed line marks the liquidity level that was swept, while the solid, thicker line marks the structural level that was subsequently broken. This visually dissects the two key events of the pattern.
[b]The Trap Vector (Arrow):[/b] A colored arrow connects the point of the liquidity sweep to the point of the structural break. This powerful visual illustrates the "trap-and-reverse" motion, graphically representing the path of the institutional move.
[b]The QM Label:[/b] Provides critical context at a glance, identifying the pattern as "Bullish QM" or "Bearish QM" and, through its RCM integration, classifying it as "Pro-Trend," "Counter-Trend," or "Neutral."
[image]https://www.tradingview.com/x/s18mag5C/[/image]

[b]Range Demarcation: Equilibrium Range (ERL/ERH)[/b]
When two opposing QM patterns form a valid range, the engine clearly demarcates it.
[b]Swing Point Markers (⭕):[/b] Large, hollow circles are placed on the absolute highest high and lowest low of the price action that formed the range, marking the outer boundaries of the entire consolidation structure.
[b]ERL/ERH Labels:[/b] "ERL" (Equilibrium Range Low/High) labels mark the specific structural break levels from the two QM patterns that define the range. These are the precise boundaries to monitor for a BOS or CHoCH.
[image]https://www.tradingview.com/x/5CXBpqwC/[/image]

[b]Structural Resolution: BOS, CHoCH & Ghost Lines[/b]
This visual layer tracks the outcome of range-bound price action.
[b]BOS/CHoCH Lines & Labels:[/b] When a range boundary is broken, a thick, solid line (green for Bullish BOS, red for Bearish CHoCH) is drawn at the broken level, accompanied by a clear label. This provides an un-missable confirmation that the market has shifted from balance to imbalance.
[b]Ghost Lines (Faded, Dashed):[/b] After a BOS or CHoCH occurs, the broken structural line does not disappear. It remains on the chart as a faded "Ghost Line." This represents the market's memory of that broken structure, as these levels frequently act as future support/resistance flip zones.
[image]https://www.tradingview.com/x/tie3k80F/[/image]

[b]Reactive Supply & Demand: Fading Zones[/b]
Following a structural break, the engine automatically draws the zone that originated the move.
[b]Supply & Demand Boxes:[/b] A red box is drawn for a Supply zone (origin of a down-move) and a green box for a Demand zone (origin of an up-move).
[b]Fading Mechanic:[/b] This is a critical visual feature. Each time price touches a zone, the box's opacity increases (it becomes more transparent). This visually represents the consumption of orders within the zone. After a user-defined number of touches (Zone Touch Limit), the zone is considered fully mitigated and is automatically removed from the chart.
[image]https://www.tradingview.com/x/AkoUmXd4/[/image]

[b]The Analytics Dashboards[/b]
To keep the chart clean, the bulk of the data is presented in two distinct dashboard panels.
[b]The Main Dashboard:[/b] Provides a comprehensive quantitative breakdown of all engine metrics, from real-time footprint data to the statistical performance of historical QM patterns.
[b]The Trend Narrative Panel:[/b] This qualitative panel translates the complex data from the engine and its integrated RCM library into simple, human-readable sentences, providing an instant summary of the market's condition regarding Regime, Kinetics, Structure, and Order Flow.
[image]https://www.tradingview.com/x/eiZCIgbD/[/image]

[b]⚖️ RESPONSIBLE USAGE & LIMITATIONS[/b]

[b]Analysis, Not Execution:[/b] This engine is a descriptive analytical framework designed to map market structure. It is not an automated trading strategy. The drawn QM patterns are historical and structural observations, not guaranteed buy/sell signals.
[b]Trade Evaluation is Hypothetical:[/b] The "Profitable QMs" metric displayed on the dashboard is a basic, rigid statistical evaluation based on fixed tick inputs. It does not account for slippage, commissions, spread, or dynamic trade management. It is designed to measure the general effectiveness of the pattern on a specific asset, not to simulate a live trading PnL.
[b]Data Requirements:[/b] The Footprint functionality requires access to tick data (typically a Premium subscription). Without this, the script functions entirely normally using its built-in mathematical OHLCV synthetic delta approximation, but will lack exact tick precision for the "Trap Absorbed" metric.

[b]🔮 CONCLUSION[/b]

The Quasimodo Range Engine brings a rigorous, mechanical approach to structural market analysis. By tracking the exact sequence of liquidity sweeps, structural breaks, and the subsequent formulation of trading ranges, it removes subjectivity from chart reading. It allows analysts to view price action as a continuous cycle of liquidity engineering, range expansion, and supply/demand mitigation, providing a deeply contextualized map of market behavior.

— Dskyz, Trade with insight. Trade with anticipation. (Don't follow the trend, be the trend)

## Source Code

````pine
//@version=6
indicator("QM Range (DAFE)", shorttitle="⟡ QM-R", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)
// ═══════════════════════════════════════════════════════════════════════════════
//
//                      QUASIMODO RANGE ENGINE [DAFE]
//
// ═══════════════════════════════════════════════════════════════════════════════
//
//  PHILOSOPHY:
//  Markets are engineered around liquidity. The Quasimodo (QM) pattern is the
//  archetypal footprint of this process: a liquidity grab (the sweep of a
//  prior high/low) followed by a failure to continue, culminating in a
//  powerful reversal that breaks market structure. This signifies a trap where
//  "Smart Money" has absorbed breakout traders and initiated a new move.
//
//  This engine is designed to mechanically decode this institutional narrative. It
//  doesn't just find the pattern; it contextualizes it. Opposing QMs define
//  the boundaries of a trading range (ERL/ERH), and breaks of these ranges
//  signal true Changes of Character (CHoCH) or Breaks of Structure (BOS).
//
//  KEY FEATURES:
//  1. Quasimodo Pattern Detection: Automatically identifies both Bullish & Bearish
//     QM patterns, the core of the engine.
//
//  2. Automatic Range Formation: Defines the trading range (Equilibrium Range
//     Low/High) between two opposing QM patterns.
//
//  3. Smart Structure Analysis: Uses range boundaries to automatically detect
//     and label high-probability BOS and CHoCH events, leaving behind "Ghost
//     Lines" to track the memory of broken structure.
//
//  4. Footprint Delta Confirmation: Integrates real order flow to validate the
//     liquidity sweep, identifying "trapped" volume which adds immense
//     conviction to a QM setup.
//
//  5. RCM Regime Context: Leverages the Ricci Curvature Machine learning engine
//     to provide macro context, classifying each QM as Pro-Trend, Counter-Trend,
//     or Neutral.
//
//  6. Automated Supply & Demand: Automatically draws and fades reactive S/D
//     zones following a structural break, highlighting the origin of the move.
//
//  7. Integrated Analytics Dashboard: A comprehensive HUD displays all key
//     metrics, performance statistics, and live RCM/Footprint data in a clean,
//     unobtrusive interface.
//
// ==============================================================================
// 📦 LIBRARIES
// ==============================================================================
import DskyzInvestments/DafeVisLib/1 as viz
import DskyzInvestments/DafeRCMLib/1 as rcm
//==============================================================================
// 🎛️ INPUTS
//==============================================================================
groupDetection = "🔍 Detection Engine"
qmLookback     = input.int(50,  "QM Break Lookback",     minval=5,   maxval=100, group=groupDetection, tooltip="The maximum number of bars the script will wait for a structural break after a liquidity sweep has occurred. This acts as a 'validity window' for a pending QM pattern.\n\n" + "A Quasimodo setup is only valid if the break of structure happens relatively soon after the initial sweep. If it takes too long, the market context has likely changed, and the original setup is invalidated. This input defines that time limit.")
rangeGapLimit  = input.int(100, "Max QM1-QM2 Gap",       minval=10,  maxval=200, group=groupDetection, tooltip="The maximum number of bars allowed between two opposing Quasimodo patterns for them to be considered part of the same trading range.\n\n" + "This ensures that ranges are formed from recent and related price action. If the gap between a Bullish QM and a Bearish QM is too large, they are treated as separate market events rather than the boundaries of a consolidated range.")
sdBackBars     = input.int(15,  "SD Formation Lookback", minval=5,   maxval=30,  group=groupDetection, tooltip="The number of bars to look back from a structural break (BOS/CHoCH) to find the origin candle for the automatically drawn Supply or Demand zone.\n\n" + "The zone is drawn from the last opposing candle before the impulsive move that broke the structure. This setting defines how far back the engine will search for that origin candle.")
groupFP        = "👣 Real Orderflow (Footprint)"
useRealFP      = input.bool(true, "Enable Real Footprint Delta", group=groupFP, tooltip="If enabled, the script will request real-time, tick-level footprint data to analyze the order flow within the liquidity sweep bar of a QM pattern. This provides the ground truth for identifying 'Trapped' volume—a high-conviction confirmation.\n\n" + "If disabled or unavailable, the engine falls back to a sophisticated OHLCV-based 'Synthetic Delta' estimation.")
fpTicks        = input.int(10,  "Ticks per Footprint Row", minval=1, maxval=500, group=groupFP, tooltip="Defines the price granularity for the footprint data request. This is the number of ticks that are aggregated into a single row in the profile. Calibrate this to the specific instrument being traded for optimal accuracy.")
fpVA           = input.int(70,  "Value Area %",            minval=1, maxval=99,  group=groupFP, tooltip="The percentage of total volume to be included in the Value Area (VA) calculation. Used by the footprint engine to determine the VAH and VAL for the dashboard display.")
groupTE        = "📐 Trade Evaluation (SL/TP)"
evalSL_Ticks   = input.float(20.0, "Stop Loss (Ticks)",   minval=1,   step=1,   group=groupTE, tooltip="The Stop Loss size, measured in ticks, used by the *internal performance evaluation system*. This is NOT a live trade signal, but a parameter for the dashboard to calculate the potential profitability of each detected QM pattern.")
evalTP_Ticks   = input.float(60.0, "Take Profit (Ticks)", minval=1,   step=1,   group=groupTE, tooltip="The Take Profit size, measured in ticks, used by the internal performance evaluation system. This value, in conjunction with the Stop Loss, is used to calculate the R:R ratio for each setup.")
evalRR         = input.float(3.0,  "Min R:R Ratio",       minval=0.5, step=0.5, group=groupTE, tooltip="The minimum acceptable Risk:Reward Ratio. The dashboard will flag a QM pattern as 'Profitable' only if its calculated R:R (based on the SL/TP ticks above) meets or exceeds this threshold.")
showTradeEval  = input.bool(true,  "Show Trade Evaluation on QM", group=groupTE, tooltip="This setting is planned for a future update and is not currently active. It will be used to display potential entry/SL/TP levels directly on the chart for evaluated QM patterns.")
groupPerf      = "⚡ Performance Settings"
maxCFPoints    = input.int(400, "Max 3CF History",     minval=50,  maxval=2000, group=groupPerf, tooltip="The maximum number of recent 3-Candle Fractal pivots to keep in memory. This is a performance optimization setting to prevent the script from slowing down on very long historical data.")
maxQMHistory   = input.int(20,  "Max QM History",      minval=5,   maxval=50,   group=groupPerf, tooltip="The maximum number of confirmed Quasimodo patterns to keep in memory for statistical calculations on the dashboard.")
maxZoneHistory = input.int(30,  "Max SD Zone History", minval=5,   maxval=100,  group=groupPerf, tooltip="The maximum number of Supply/Demand zones (both active and broken) to store in memory. This is a performance optimization setting.")
zoneTouchLimit = input.int(3,   "Zone Touch Limit",    minval=1,   maxval=10,   group=groupPerf, tooltip="The number of times a Supply or Demand zone can be touched before it is considered invalidated and removed from the chart. This is based on the principle that zones weaken with each test.")
groupDisplay   = "🎨 Display Options"
show3CF        = input.bool(true,  "3CF Markers",                    group=groupDisplay, tooltip="Toggles the visibility of the '○' markers on 3-Candle Fractal pivots. These pivots are the foundational points used to identify liquidity sweeps.")
showLiqLines   = input.bool(true,  "Liquidity Lines",                group=groupDisplay, tooltip="Toggles the visibility of the dotted horizontal lines drawn from each 3CF pivot. These lines extend forward in time until price takes them out, providing a clear visual representation of untapped liquidity.")
showQM         = input.bool(true,  "QM Patterns",                    group=groupDisplay, tooltip="Toggles the visibility of all Quasimodo pattern drawings, including the main QM zone, labels, sweep/break lines, and the trap vector.")
showRanges     = input.bool(true,  "Range Detection",                group=groupDisplay, tooltip="Toggles the visibility of the Equilibrium Range markers (ERL/ERH) and the large '⭕' swing point markers that define an active trading range.")
showStructure  = input.bool(true,  "BOS/CHoCH Smart Lines & Ghosts", group=groupDisplay, tooltip="Toggles the visibility of the Break of Structure (BOS) and Change of Character (CHoCH) lines and labels. It also controls the 'Ghost Lines'—faded historical structure levels that remain on the chart until broken.")
showSD         = input.bool(true,  "Fading Supply/Demand Zones",     group=groupDisplay, tooltip="Toggles the visibility of the reactive Supply and Demand zones that are automatically drawn after a structural break. These zones fade with each touch to represent diminishing strength.")
cf3Size        = input.string("normal", "3CF Size", options=["small","normal","large"], group=groupDisplay, tooltip="Adjusts the size of the '○' markers for 3-Candle Fractal pivots.")
cf3ColorHigh   = input.color(color.red,  "3CF High Color", group=groupDisplay, tooltip="Sets the color for the high pivot markers.")
cf3ColorLow    = input.color(color.lime, "3CF Low Color",  group=groupDisplay, tooltip="Sets the color for the low pivot markers.")
maxActiveZones = input.int(3, "Max Visible SD Zones", minval=1, maxval=10, group=groupDisplay, tooltip="Controls the maximum number of active Supply/Demand zones displayed on the chart at any given time. This prevents chart clutter by automatically removing the oldest zones.")
maxActiveRanges= input.int(2, "Max Visible Ranges",   minval=1, maxval=5,  group=groupDisplay, tooltip="Controls the maximum number of active Ranges displayed on the chart. This keeps the analysis focused on the most recent market structures.")
groupDash      = "📈 Advanced Dashboard"
showDashboard  = input.bool(true, "Enable DAFE Analytics Dashboard", group=groupDash, tooltip="Master switch to show or hide the entire information dashboard. The dashboard provides a comprehensive real-time overview of all detected patterns, performance metrics, and market context.")
dashPosInput   = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=groupDash, tooltip="Sets the corner of the chart where the dashboard will appear.")
dashSizeInput  = input.string("Small", "Dashboard Size", options=["Tiny","Small","Normal","Large"], group=groupDash, tooltip="Adjusts the text size for all elements within the dashboard for better readability on different screen resolutions.")
//==============================================================================
// 🦶 FOOTPRINT
//==============================================================================
footprint reqFP = request.footprint(fpTicks, fpVA)
float fp_buyVol    = na
float fp_sellVol   = na
float fp_delta     = na
float fp_pocUp     = na
float fp_pocDn     = na
float fp_vahUp     = na
float fp_valDn     = na
bool  fp_available = false
if not na(reqFP)
    fp_available := true
    fp_buyVol    := reqFP.buy_volume()
    fp_sellVol   := reqFP.sell_volume()
    fp_delta     := reqFP.delta()
    volume_row pocRow = reqFP.poc()
    volume_row vahRow = reqFP.vah()
    volume_row valRow = reqFP.val()
    fp_pocUp     := pocRow.up_price()
    fp_pocDn     := pocRow.down_price()
    fp_vahUp     := vahRow.up_price()
    fp_valDn     := valRow.down_price()
//==============================================================================
// 🧠 DATA STRUCTURES
//==============================================================================
type ThreeCF
    bool  isHigh
    bool  isLow
    float level
    int   bar
    label marker
    line  liqLine
    bool  isTaken
type QM
    string typ
    int    originBar
    float  sweepLvl
    int    sweepBar
    float  breakLvl
    int    breakBar
    line   sweepLine
    line   breakLine
    line   trapVector
    label  qmLabel
    box    qmZone
    bool   evalProfitable
    float  evalRR
    bool   isTrap
    float  delta
type RangeRec
    string typ
    float  high
    int    highBar
    float  low
    int    lowBar
    int    startBar
    bool   active
    label  highMarker
    label  lowMarker
    label  erlHighLabel
    label  erlLowLabel
    float  swingHigh
    int    swingHighBar
    float  swingLow
    int    swingLowBar
type SDZone
    string typ
    float  high
    float  low
    int    originBar
    int    touchCount
    bool   active
    bool   broken
    box    bx
type GhostLine
    float lvl
    bool  isSupport
    int   spawnBar
    bool  broken
//==============================================================================
// 🗄️ PERSISTENT STATE
//==============================================================================
var array<ThreeCF>   CF         = array.new<ThreeCF>()
var array<QM>        QMs        = array.new<QM>()
var array<RangeRec>  Ranges     = array.new<RangeRec>()
var array<SDZone>    Zones      = array.new<SDZone>()
var array<GhostLine> ghostLines = array.new<GhostLine>()
var array<line>      ghostDrawn = array.new<line>()
var bool alert_bullQM = false, var bool alert_bearQM = false
var bool alert_bullTrap = false, var bool alert_bearTrap = false
var bool alert_newRange = false
var bool alert_bos = false, var bool alert_choch = false
var bool alert_newSupply = false, var bool alert_newDemand = false
var bool alert_touchSupply = false, var bool alert_touchDemand = false
var QM       lastQM                = QM.new()
var RangeRec activeRange           = na
var bool     hasActiveRange        = false
var string   pendingQM_Type        = na
var float    pendingQM_BreakLevel  = na
var int      pendingQM_OriginBar   = na
var float    pendingQM_SweepLevel  = na
var int      pendingQM_SweepBar    = na
var int      lastStructureBreakBar = -1
var int   totalBOS          = 0
var int   totalCHoCH        = 0
var int   totalBullQM       = 0
var int   totalBearQM       = 0
var int   totalTrapQM       = 0
var int   totalProfitableQM = 0
var float totalDelta        = 0.0
var bool  lastFpAvailable = false
var float lastPocLevel    = na
var float lastVahLevel    = na
var float lastValLevel    = na
var float lastBuyVol      = na
var float lastSellVol     = na
var float lastFpDelta     = na
//==============================================================================
// ⚙️ RCM ENGINE
//==============================================================================
var rcm.RCMState  rcmState = rcm.RCMState.new()
var rcm.RCMConfig rcmCfg   = rcm.default_config()
rcmState := rcm.update(rcmState, rcmCfg)
//==============================================================================
// 🛠️ HELPERS
//==============================================================================
f_getExtremeInRange(isHigh, startBar, endBar) =>
    int   fromBar    = math.min(startBar, endBar)
    int   toBar      = math.max(startBar, endBar)
    float extreme    = isHigh ? -1e10 : 1e10
    int   extremeBar = fromBar
    int   lookback   = math.min(bar_index - fromBar, toBar - fromBar)
    for i = 0 to lookback
        int idx = bar_index - fromBar - i
        if idx >= 0 and idx < bar_index
            if isHigh
                if high[idx] > extreme
                    extreme    := high[idx]
                    extremeBar := fromBar + i
            else
                if low[idx] < extreme
                    extreme    := low[idx]
                    extremeBar := fromBar + i
    [extreme, extremeBar]
f_deleteQM(qm) =>
    if not na(qm.sweepLine)
        line.delete(qm.sweepLine)
    if not na(qm.breakLine)
        line.delete(qm.breakLine)
    if not na(qm.trapVector)
        line.delete(qm.trapVector)
    if not na(qm.qmLabel)
        label.delete(qm.qmLabel)
    if not na(qm.qmZone)
        box.delete(qm.qmZone)
f_deleteRange(rng) =>
    if not na(rng.highMarker)
        label.delete(rng.highMarker)
    if not na(rng.lowMarker)
        label.delete(rng.lowMarker)
    if not na(rng.erlHighLabel)
        label.delete(rng.erlHighLabel)
    if not na(rng.erlLowLabel)
        label.delete(rng.erlLowLabel)
f_deleteZone(z) =>
    if not na(z.bx)
        box.delete(z.bx)
f_cleanOldQMs() =>
    while array.size(QMs) > maxQMHistory
        f_deleteQM(array.shift(QMs))
f_cleanOldRanges() =>
    int cnt = 0
    for i = array.size(Ranges) - 1 to 0
        RangeRec rng = array.get(Ranges, i)
        if rng.active
            cnt += 1
            if cnt > maxActiveRanges
                rng.active := false
                f_deleteRange(rng)
                array.remove(Ranges, i)
f_cleanOldZones() =>
    int cnt = 0
    for i = array.size(Zones) - 1 to 0
        SDZone z = array.get(Zones, i)
        if z.active and not z.broken
            cnt += 1
            if cnt > maxActiveZones
                f_deleteZone(z)
                array.remove(Zones, i)
        else if z.broken
            f_deleteZone(z)
            array.remove(Zones, i)
f_getLabelSize() =>
    switch cf3Size
        "small" => size.small
        "large" => size.large
        =>         size.normal
f_getDashPos() =>
    switch dashPosInput
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right
f_getDashSize() =>
    switch dashSizeInput
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small
f_getLastCF(isHigh, maxBarsBack) =>
    float lvl = na
    int   b   = na
    if array.size(CF) > 0
        for i = array.size(CF) - 1 to 0
            ThreeCF p = array.get(CF, i)
            if bar_index - p.bar > maxBarsBack
                break
            if (isHigh and p.isHigh) or (not isHigh and p.isLow)
                lvl := p.level
                b   := p.bar
                break
    [lvl, b]
f_syntheticDelta(barsBack) =>
    float v   = volume[barsBack]
    float h   = high[barsBack]
    float l   = low[barsBack]
    float c   = close[barsBack]
    float rng = h - l
    float bp  = rng > 0 ? (c - l) / rng : 0.5
    v * bp - v * (1.0 - bp)
//==============================================================================
// 🔵 3CF PIVOT DETECTION
//==============================================================================
if bar_index > 2
    bool isHighPivot = high[1] > high[2] and high[1] > high[0]
    bool isLowPivot  = low[1]  < low[2]  and low[1]  < low[0]
    if isHighPivot
        label mk = show3CF
             ? label.new(bar_index - 1, high[1], "○", style=label.style_label_center, color=color(na), textcolor=cf3ColorHigh, size=f_getLabelSize())
             : na
        line ll = showLiqLines
             ? line.new(bar_index - 1, high[1], bar_index, high[1], color=color.new(color.blue, 30), style=line.style_dotted)
             : na
        array.push(CF, ThreeCF.new(true, false, high[1], bar_index - 1, mk, ll, false))
    if isLowPivot
        label mk = show3CF
             ? label.new(bar_index - 1, low[1], "○", style=label.style_label_center, color=color(na), textcolor=cf3ColorLow, size=f_getLabelSize())
             : na
        line ll = showLiqLines
             ? line.new(bar_index - 1, low[1], bar_index, low[1], color=color.new(color.blue, 30), style=line.style_dotted)
             : na
        array.push(CF, ThreeCF.new(false, true, low[1], bar_index - 1, mk, ll, false))
// Extend / close liquidity lines
if showLiqLines and array.size(CF) > 0
    for cf in CF
        if not cf.isTaken and not na(cf.liqLine)
            if (cf.isHigh and high >= cf.level) or (cf.isLow and low <= cf.level)
                cf.isTaken := true
                line.set_x2(cf.liqLine, bar_index)
            else
                line.set_x2(cf.liqLine, bar_index + 1)
// Trim old CF entries
while array.size(CF) > maxCFPoints
    ThreeCF old = array.shift(CF)
    if not na(old.marker)
        label.delete(old.marker)
    if not na(old.liqLine)
        line.delete(old.liqLine)
//==============================================================================
// 🔍 QM DETECTION ENGINE
//==============================================================================
[lastHigh, highBar] = f_getLastCF(true,  500)
[lastLow,  lowBar]  = f_getLastCF(false, 500)
if not na(lastHigh) and high > lastHigh and close <= lastHigh
    [lowestLow, lowestBar] = f_getExtremeInRange(false, highBar, bar_index)
    if not na(lowestLow)
        pendingQM_Type       := "Bearish"
        pendingQM_BreakLevel := lowestLow
        pendingQM_OriginBar  := highBar
        pendingQM_SweepLevel := lastHigh
        pendingQM_SweepBar   := bar_index
if not na(lastLow) and low < lastLow and close >= lastLow
    [highestHigh, highestBar] = f_getExtremeInRange(true, lowBar, bar_index)
    if not na(highestHigh)
        pendingQM_Type       := "Bullish"
        pendingQM_BreakLevel := highestHigh
        pendingQM_OriginBar  := lowBar
        pendingQM_SweepLevel := lastLow
        pendingQM_SweepBar   := bar_index
// Timeout / invalidation
if not na(pendingQM_Type)
    if bar_index - pendingQM_SweepBar > qmLookback
        pendingQM_Type := na
    if not na(pendingQM_Type)
        if pendingQM_Type == "Bullish" and close < pendingQM_SweepLevel
            pendingQM_Type := na
        if pendingQM_Type == "Bearish" and close > pendingQM_SweepLevel
            pendingQM_Type := na
// Confirm QM on structural break
bool qmFormed = false
QM   newQM    = QM.new()
if not na(pendingQM_Type)
    if pendingQM_Type == "Bullish" and close > pendingQM_BreakLevel
        newQM    := QM.new("Bullish", pendingQM_OriginBar, pendingQM_SweepLevel,
             pendingQM_SweepBar, pendingQM_BreakLevel, bar_index,
             na, na, na, na, na, false, 0.0, false, 0.0)
        qmFormed := true
        pendingQM_Type := na
    else if pendingQM_Type == "Bearish" and close < pendingQM_BreakLevel
        newQM    := QM.new("Bearish", pendingQM_OriginBar, pendingQM_SweepLevel,
             pendingQM_SweepBar, pendingQM_BreakLevel, bar_index,
             na, na, na, na, na, false, 0.0, false, 0.0)
        qmFormed := true
        pendingQM_Type := na
//==============================================================================
// 🖊️ QM RENDERING + TRADE EVALUATION
//==============================================================================
if qmFormed
    int   barsBack  = bar_index - newQM.sweepBar
    float usedDelta = useRealFP and fp_available ? fp_delta : f_syntheticDelta(barsBack)
    newQM.delta    := usedDelta
    // ── Trap check ────────────────────────────────────────────────────────
    bool isTrap = false
    if not na(usedDelta)
        if newQM.typ == "Bullish" and usedDelta < 0
            isTrap := true
        if newQM.typ == "Bearish" and usedDelta > 0
            isTrap := true
    newQM.isTrap := isTrap
    // ── Trade eval ────────────────────────────────────────────────────────
    float sl     = evalSL_Ticks * syminfo.mintick
    float tp     = evalTP_Ticks * syminfo.mintick
    float rr     = tp / sl
    bool  isGood = rr >= evalRR
    newQM.evalProfitable := isGood
    newQM.evalRR         := rr
    // ── RCM context ───────────────────────────────────────────────────────
    string ctx = ""
    if newQM.typ == "Bullish"
        ctx := rcmState.state == 1 ? "▲ Pro-Trend" : rcmState.state == -1 ? "▼ Counter" : "◆ Neutral"
    else
        ctx := rcmState.state == -1 ? "▼ Pro-Trend" : rcmState.state == 1 ? "▲ Counter" : "◆ Neutral"
    // ── Label text ────────────────────────────────────────────────────────
    string qmText = newQM.typ + " QM\n" + ctx
    // ── Colours ───────────────────────────────────────────────────────────
    color baseCol = newQM.typ == "Bullish" ? color.lime : color.red
    color drawCol = isTrap ? color.new(baseCol, 0) : color.new(baseCol, 30)
    // ── Visuals ───────────────────────────────────────────────────────────
    if showQM
        [patternHigh, _phBar] = f_getExtremeInRange(true,  newQM.originBar, newQM.breakBar)
        [patternLow,  _plBar] = f_getExtremeInRange(false, newQM.originBar, newQM.breakBar)
        float boxTop = newQM.typ == "Bearish" ? patternHigh : newQM.breakLvl
        float boxBot = newQM.typ == "Bearish" ? newQM.breakLvl : patternLow
        newQM.qmZone    := box.new(newQM.originBar, boxTop, newQM.breakBar, boxBot, bgcolor=color.new(drawCol, 88), border_color=color.new(drawCol, 60))
        newQM.sweepLine := line.new(newQM.originBar, newQM.sweepLvl, newQM.sweepBar,  newQM.sweepLvl, color=drawCol, style=line.style_dashed)
        newQM.breakLine := line.new(newQM.originBar, newQM.breakLvl, newQM.breakBar,  newQM.breakLvl, color=drawCol, style=line.style_solid, width=2)
        newQM.trapVector := line.new(newQM.sweepBar, newQM.sweepLvl, newQM.breakBar, newQM.breakLvl, color=color.new(drawCol, 50), width=2, style=line.style_arrow_right)
        newQM.qmLabel := label.new(newQM.originBar, newQM.sweepLvl, qmText, style=label.style_label_right, textcolor=baseCol, color=color(na), size=size.small)
    // ── Counters ──────────────────────────────────────────────────────────
    if newQM.typ == "Bullish"
        totalBullQM += 1
    else
        totalBearQM += 1
    if isTrap
        totalTrapQM += 1
    if isGood
        totalProfitableQM += 1
    if not na(usedDelta)
        totalDelta += usedDelta
    array.push(QMs, newQM)
    f_cleanOldQMs()
    // ── Range formation ───────────────────────────────────────────────────
    if not na(lastQM.typ) and lastQM.typ != newQM.typ
             and bar_index - lastQM.breakBar <= rangeGapLimit
        if hasActiveRange and not na(activeRange)
            activeRange.active := false
            f_deleteRange(activeRange)
        RangeRec nr  = RangeRec.new()
        nr.typ       := lastQM.typ
        nr.high      := math.max(lastQM.sweepLvl, lastQM.breakLvl, newQM.sweepLvl, newQM.breakLvl)
        nr.low       := math.min(lastQM.sweepLvl, lastQM.breakLvl, newQM.sweepLvl, newQM.breakLvl)
        nr.startBar  := lastQM.originBar
        nr.active    := true
        nr.highBar   := bar_index
        nr.lowBar    := bar_index
        [swH, swHBar] = f_getExtremeInRange(true,  lastQM.originBar, newQM.breakBar)
        [swL, swLBar] = f_getExtremeInRange(false, lastQM.originBar, newQM.breakBar)
        nr.swingHigh    := swH
        nr.swingHighBar := swHBar
        nr.swingLow     := swL
        nr.swingLowBar  := swLBar
        if showRanges
            nr.highMarker := label.new(swHBar, swH, "⭕", color=color(na), textcolor=color.red,  size=size.large, style=label.style_label_center)
            nr.lowMarker  := label.new(swLBar, swL, "⭕", color=color(na), textcolor=color.lime, size=size.large, style=label.style_label_center)
        nr.erlHighLabel := label.new(bar_index, nr.high, "ERL", style=label.style_label_left, textcolor=color.white, color=color(na), size=size.tiny)
        nr.erlLowLabel  := label.new(bar_index, nr.low,  "ERL", style=label.style_label_left, textcolor=color.white, color=color(na), size=size.tiny)
        array.push(Ranges, nr)
        activeRange    := nr
        hasActiveRange := true
        f_cleanOldRanges()
    lastQM := newQM
//==============================================================================
// 👻 GHOST LINE SYSTEM
//==============================================================================
if array.size(ghostLines) > 0
    for i = array.size(ghostLines) - 1 to 0
        GhostLine gl = array.get(ghostLines, i)
        if not gl.broken
            if gl.isSupport and close < gl.lvl
                gl.broken := true
            else if not gl.isSupport and close > gl.lvl
                gl.broken := true
if array.size(ghostDrawn) > 0
    for l in ghostDrawn
        line.delete(l)
    array.clear(ghostDrawn)
if showStructure and array.size(ghostLines) > 0
    for gl in ghostLines
        if not gl.broken
            color ghostCol = gl.isSupport
                 ? color.new(color.lime, 55)
                 : color.new(color.red,  55)
            line newL = line.new(bar_index, gl.lvl, bar_index, gl.lvl, color=ghostCol, style=line.style_dashed, width=1, extend=extend.both)
            array.push(ghostDrawn, newL)
//==============================================================================
// 🏛️ STRUCTURE BREAK DETECTION (BOS / CHoCH)
//==============================================================================
if hasActiveRange and not na(activeRange) and bar_index > lastStructureBreakBar
    if activeRange.active
        if not na(activeRange.erlHighLabel)
            label.set_x(activeRange.erlHighLabel, bar_index)
        if not na(activeRange.erlLowLabel)
            label.set_x(activeRange.erlLowLabel,  bar_index)
        // ── BULLISH BOS ──────────────────────────────────────────────────
        if close > activeRange.high
            if showStructure
                int   bosBar   = not na(activeRange.swingHighBar)
                     ? activeRange.swingHighBar : activeRange.highBar
                float bosLevel = not na(activeRange.swingHigh)
                     ? activeRange.swingHigh    : activeRange.high
                line.new(bosBar, bosLevel, bar_index, bosLevel, color=color.lime, width=2)
                label.new(bosBar, bosLevel, "BOS\n" + str.tostring(bosLevel, format.mintick), style=label.style_label_right, color=color(na), textcolor=color.lime, size=size.small)
                array.push(ghostLines, GhostLine.new(bosLevel, true, bar_index, false))
            totalBOS             += 1
            activeRange.active    := false
            lastStructureBreakBar := bar_index
            if showSD
                for i = 1 to sdBackBars
                    if close[i] < open[i]
                        SDZone nz = SDZone.new("Demand", high[i], low[i], bar_index - i, 0, true, false, na)
                        nz.bx := box.new(bar_index - i, high[i], bar_index, low[i], bgcolor=color.new(color.lime, 80), border_color=color.new(color.lime, 40))
                        array.push(Zones, nz)
                        f_cleanOldZones()
                        break
            f_deleteRange(activeRange)
            activeRange    := na
            hasActiveRange := false
        // ── BEARISH CHoCH ────────────────────────────────────────────────
        else if close < activeRange.low
            if showStructure
                int   chochBar   = not na(activeRange.swingLowBar)
                     ? activeRange.swingLowBar : activeRange.lowBar
                float chochLevel = not na(activeRange.swingLow)
                     ? activeRange.swingLow    : activeRange.low
                line.new(chochBar, chochLevel, bar_index, chochLevel, color=color.red, width=2)
                label.new(chochBar, chochLevel, "CHoCH\n" + str.tostring(chochLevel, format.mintick), style=label.style_label_right, color=color(na), textcolor=color.red, size=size.small)
                // Register ghost data entry
                array.push(ghostLines, GhostLine.new(chochLevel, false, bar_index, false))
            totalCHoCH           += 1
            activeRange.active    := false
            lastStructureBreakBar := bar_index
            if showSD
                for i = 1 to sdBackBars
                    if close[i] > open[i]
                        SDZone nz = SDZone.new("Supply", high[i], low[i], bar_index - i, 0, true, false, na)
                        nz.bx := box.new(bar_index - i, high[i], bar_index, low[i], bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 40))
                        array.push(Zones, nz)
                        f_cleanOldZones()
                        break
            f_deleteRange(activeRange)
            activeRange    := na
            hasActiveRange := false
//==============================================================================
// 🌊 FADING SD ZONES
//==============================================================================
if showSD and array.size(Zones) > 0
    for i = array.size(Zones) - 1 to 0
        SDZone z = array.get(Zones, i)
        if z.active
            color col = z.typ == "Supply" ? color.red : color.lime
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
            bool touched = (z.typ == "Supply" and high >= z.low) or (z.typ == "Demand" and low  <= z.high)
            if touched
                z.touchCount += 1
                if z.touchCount >= zoneTouchLimit
                    z.active := false
                    array.remove(Zones, i)
                    continue
                else
                    int fadeFill = math.min(95, 80 + z.touchCount * 8)
                    int fadeBord = math.min(95, 40 + z.touchCount * 20)
                    box.set_bgcolor(z.bx,      color.new(col, fadeFill))
                    box.set_border_color(z.bx, color.new(col, fadeBord))
        else
            if not na(z.bx)
                box.delete(z.bx)
            array.remove(Zones, i)
if fp_available
    lastFpAvailable := true
    lastPocLevel    := fp_pocUp
    lastVahLevel    := fp_vahUp
    lastValLevel    := fp_valDn
    lastBuyVol      := fp_buyVol
    lastSellVol     := fp_sellVol
    lastFpDelta     := fp_delta
//==============================================================================
// 🖥️ Dashboard
//==============================================================================
var table dashTable = na
if barstate.islast and showDashboard
    int activeZoneCount = 0
    for z in Zones
        if z.active and not z.broken
            activeZoneCount += 1
    int   totalQMs  = totalBullQM + totalBearQM
    float bullPct   = totalQMs > 0 ? (totalBullQM       / totalQMs) * 100 : 50.0
    float bearPct   = totalQMs > 0 ? (totalBearQM       / totalQMs) * 100 : 50.0
    float trapPct   = totalQMs > 0 ? (totalTrapQM       / totalQMs) * 100 : 0.0
    float profitPct = totalQMs > 0 ? (totalProfitableQM / totalQMs) * 100 : 0.0
    float avgDelta  = totalQMs > 0 ? totalDelta / totalQMs : 0.0
    string rcmReg    = rcm.get_regime(rcmState)
    string rcmInt    = rcm.integrity_text(rcmState)
    color  rcmRegC   = rcm.state_color(rcmState, color.lime, color.red, color.orange)
    color  rcmIntC   = rcm.integrity_color(rcmState, color.lime, color.red)
    [narTxt, narCol] = rcm.narrative_regime(rcmState, color.lime, color.red, color.orange, color.rgb(148, 163, 184))
    // ── Palette ───────────────────────────────────────────────────────────
    color C_BG     = color.rgb(8,   10,  18)
    color C_PANEL  = color.rgb(14,  18,  30)
    color C_BORDER = color.rgb(30,  41,  65)
    color C_ACCENT = color.rgb(41,  98,  255)
    color C_PURP   = color.rgb(139, 92,  246)
    color C_BULL   = color.rgb(0,   230, 118)
    color C_BEAR   = color.rgb(255, 59,  59)
    color C_WARN   = color.rgb(255, 184, 0)
    color C_INFO   = color.rgb(56,  189, 248)
    color C_DIM    = color.rgb(100, 116, 139)
    color C_WHITE  = color.white
    color C_GHOST  = color.rgb(148, 163, 184)
    string sz   = f_getDashSize()
    string MONO = font.family_monospace
    if na(dashTable)
        dashTable := table.new(f_getDashPos(), 3, 32, bgcolor=C_BG, border_width=1, border_color=C_BORDER, frame_width=2, frame_color=C_ACCENT)
    table.cell(dashTable, 0, 0, "⚡  QM - Range  [DAFE]", text_color=C_ACCENT, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_ACCENT, 82))
    table.merge_cells(dashTable, 0, 0, 2, 0)
    table.cell(dashTable, 0, 1, "─── MACRO CONTEXT ───", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_PANEL, 20))
    table.merge_cells(dashTable, 0, 1, 2, 1)
    table.cell(dashTable, 0, 2, " RCM Regime", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 2, rcmReg, text_color=rcmRegC, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 2, rcmState.state == 1 ? "▲" : rcmState.state == -1 ? "▼" : "◆", text_color=rcmRegC, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 3, " RCM Integrity", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 3, rcmInt, text_color=rcmIntC, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 3, "●", text_color=rcmIntC, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    string fpSrcStr = useRealFP ? "● REAL" : "● SYNTH"
    color  fpSrcCol = useRealFP ? C_INFO   : C_WARN
    table.cell(dashTable, 0, 4, " FP Source", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 4, fpSrcStr, text_color=fpSrcCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 4, useRealFP ? "R" : "S", text_color=fpSrcCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 5, "─── FOOTPRINT DATA ───", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_PANEL, 20))
    table.merge_cells(dashTable, 0, 5, 2, 5)
    string buyStr = lastFpAvailable ? str.tostring(lastBuyVol,  "#,###.#") : "—"
    string selStr = lastFpAvailable ? str.tostring(lastSellVol, "#,###.#") : "—"
    string delStr = lastFpAvailable ? str.tostring(lastFpDelta, "+#,###;-#,###") : "—"
    string pocStr = lastFpAvailable ? str.tostring(lastPocLevel, format.mintick)  : "—"
    string vaStr  = lastFpAvailable
         ? str.tostring(lastVahLevel, format.mintick) + " / " + str.tostring(lastValLevel, format.mintick)
         : "—"
    color delCol  = lastFpAvailable ? (lastFpDelta >= 0 ? C_BULL : C_BEAR) : C_DIM
    table.cell(dashTable, 0, 6, " Buy Volume", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 6, buyStr, text_color=C_BULL, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 6, "▲", text_color=C_BULL, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 7, " Sell Volume", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 7, selStr, text_color=C_BEAR, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 7, "▼", text_color=C_BEAR, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 8, " Delta", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 8, delStr, text_color=delCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 8, lastFpAvailable ? (lastFpDelta >= 0 ? "▲" : "▼") : "—", text_color=delCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 9, " POC", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 9, pocStr, text_color=C_PURP, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 9, "◉", text_color=C_PURP, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 10, " VAH / VAL", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 10, vaStr, text_color=C_INFO, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 10, "≡", text_color=C_INFO, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 11, "─── QM METRICS ───", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_PANEL, 20))
    table.merge_cells(dashTable, 0, 11, 2, 11)
    string rngStr = hasActiveRange ? "● ACTIVE" : "○ None"
    color  rngCol = hasActiveRange ? C_ACCENT   : C_DIM
    table.cell(dashTable, 0, 12, " Range State", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 12, rngStr, text_color=rngCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 12, hasActiveRange ? "⊡" : "□", text_color=rngCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 13, " Total QMs", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 13, str.tostring(totalQMs), text_color=C_WHITE, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 13, "QM", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 14, " Bull QMs", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 14, str.tostring(totalBullQM) + "  " + str.tostring(bullPct, "#.#") + "%", text_color=C_BULL, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 14, viz.draw_bar(bullPct, 5), text_color=C_BULL, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 15, " Bear QMs", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 15, str.tostring(totalBearQM) + "  " + str.tostring(bearPct, "#.#") + "%", text_color=C_BEAR, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 15, viz.draw_bar(bearPct, 5), text_color=C_BEAR, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 16, " Trap Absorbed", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 16, str.tostring(totalTrapQM) + "  " + str.tostring(trapPct, "#.#") + "%", text_color=C_WARN, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 16, "⚡", text_color=C_WARN, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 17, " Bull BOS", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 17, str.tostring(totalBOS), text_color=C_BULL, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 17, "↑", text_color=C_BULL, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 18, " Bear CHoCH", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 18, str.tostring(totalCHoCH), text_color=C_BEAR, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 18, "↓", text_color=C_BEAR, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 19, " Active SD Zones", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 19, str.tostring(activeZoneCount), text_color=color.orange, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 19, "▣", text_color=color.orange, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 20, " Ghost Lines", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 20, str.tostring(array.size(ghostLines)), text_color=C_INFO, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 20, "~", text_color=C_INFO, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 21, "─── PERFORMANCE ───", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_PANEL, 20))
    table.merge_cells(dashTable, 0, 21, 2, 21)
    string profStr  = str.tostring(totalProfitableQM) + "  " + str.tostring(profitPct, "#.#") + "%"
    color  profCol  = profitPct >= 50 ? C_BULL : C_BEAR
    string aDeltStr = str.tostring(avgDelta, "+#.##;-#.##")
    color  aDeltCol = avgDelta >= 0 ? C_BULL : C_BEAR
    table.cell(dashTable, 0, 22, " Profitable QMs", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 22, profStr, text_color=profCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 22, profitPct >= 50 ? "✓" : "✗", text_color=profCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 23, " Min R:R", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 23, "1 : " + str.tostring(evalRR, "#.#"), text_color=C_WARN, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 23, "R", text_color=C_WARN, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 24, " SL / TP", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 24, str.tostring(evalSL_Ticks, "#") + "t / " + str.tostring(evalTP_Ticks, "#") + "t", text_color=C_INFO, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 24, "⊕", text_color=C_INFO, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 25, " Avg QM Delta", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 25, aDeltStr, text_color=aDeltCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 25, aDeltCol == C_BULL ? "▲" : "▼", text_color=aDeltCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 26, " Bull Weight", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 26, viz.draw_bar(bullPct, 8) + " " + str.tostring(bullPct, "#") + "%", text_color=C_BULL, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 26, "█", text_color=C_BULL, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 27, " Bear Weight", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 27, viz.draw_bar(bearPct, 8) + " " + str.tostring(bearPct, "#") + "%", text_color=C_BEAR, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.cell(dashTable, 2, 27, "█", text_color=C_BEAR, text_size=sz, text_halign=text.align_center, text_font_family=MONO)
    table.cell(dashTable, 0, 28, "─── SIGNAL STATUS ───", text_color=C_DIM, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(C_PANEL, 20))
    table.merge_cells(dashTable, 0, 28, 2, 28)
    string lqStr = not na(lastQM.typ)
         ? lastQM.typ + " QM @ " + str.tostring(lastQM.breakLvl, format.mintick) : "—"
    color  lqCol = not na(lastQM.typ)
         ? (lastQM.typ == "Bullish" ? C_BULL : C_BEAR) : C_DIM
    table.cell(dashTable, 0, 29, " Last QM", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 29, lqStr, text_color=lqCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.merge_cells(dashTable, 1, 29, 2, 29)
    string leTxt = not na(lastQM.typ)
         ? (lastQM.isTrap ? "⚡ Trapped" : "○ Clean") + "  RR:" + str.tostring(lastQM.evalRR, "#.##") : "—"
    color  leCol = not na(lastQM.typ) ? (lastQM.isTrap ? C_WARN : C_DIM) : C_DIM
    table.cell(dashTable, 0, 30, " QM Eval", text_color=C_GHOST, text_size=sz, text_halign=text.align_left, text_font_family=MONO)
    table.cell(dashTable, 1, 30, leTxt, text_color=leCol, text_size=sz, text_halign=text.align_right, text_font_family=MONO)
    table.merge_cells(dashTable, 1, 30, 2, 30)
    table.cell(dashTable, 0, 31, narTxt, text_color=narCol, text_size=sz, text_halign=text.align_center, text_font_family=MONO, bgcolor=color.new(narCol, 88))
    table.merge_cells(dashTable, 0, 31, 2, 31)
//==============================================================================
// 🔔 Alerts
//==============================================================================
// --- 1. Quasimodo Pattern Confirmation Alerts ---
alertcondition(alert_bullQM and not alert_bullTrap, "Bullish QM Confirmed", "⟡ Bullish Quasimodo Pattern Confirmed on {{ticker}} at {{close}}. Sweep: {{plot_1}}, Break: {{plot_2}}.")
alertcondition(alert_bearQM and not alert_bearTrap, "Bearish QM Confirmed", "⟡ Bearish Quasimodo Pattern Confirmed on {{ticker}} at {{close}}. Sweep: {{plot_3}}, Break: {{plot_4}}.")
alertcondition(alert_bullTrap, "HIGH CONVICTION: Bullish QM (Trap Detected)", "⚡ TRAP DETECTED: Bullish QM on {{ticker}} at {{close}}. Negative delta confirms trapped sellers. Sweep: {{plot_1}}, Break: {{plot_2}}.")
alertcondition(alert_bearTrap, "HIGH CONVICTION: Bearish QM (Trap Detected)", "⚡ TRAP DETECTED: Bearish QM on {{ticker}} at {{close}}. Positive delta confirms trapped buyers. Sweep: {{plot_3}}, Break: {{plot_4}}.")
// --- 2. Structural Break Alerts ---
alertcondition(alert_bos, "Break of Structure (BOS)", "▲ BOS Confirmed on {{ticker}}. Price broke above Equilibrium Range High, signaling bullish continuation.")
alertcondition(alert_choch, "Change of Character (CHoCH)", "▼ CHoCH Confirmed on {{ticker}}. Price broke below Equilibrium Range Low, signaling potential bearish reversal.")
// --- 3. Range & Zone Alerts ---
alertcondition(alert_newRange, "New Equilibrium Range Formed", "Range Detected on {{ticker}}. Opposing QM patterns have defined a new trading range.")
alertcondition(alert_newSupply, "New Supply Zone Created", "New Supply Zone formed on {{ticker}} following a structural break. Monitor this area for potential short entries.")
alertcondition(alert_newDemand, "New Demand Zone Created", "New Demand Zone formed on {{ticker}} following a structural break. Monitor this area for potential long entries.")
alertcondition(alert_touchSupply, "Price Entering Supply Zone", "Price is now testing a fresh Supply Zone on {{ticker}}. Watch for rejection.")
alertcondition(alert_touchDemand, "Price Entering Demand Zone", "Price is now testing a fresh Demand Zone on {{ticker}}. Watch for support.")
if barstate.isconfirmed
    alert_bullQM := false, alert_bearQM := false
    alert_bullTrap := false, alert_bearTrap := false
    alert_newRange := false
    alert_bos := false, alert_choch := false
    alert_newSupply := false, alert_newDemand := false
    alert_touchSupply := false, alert_touchDemand := false
plot(na(lastQM.typ) or lastQM.typ == "Bearish" ? na : lastQM.sweepLvl, "Bull QMSweep", display=display.none)
plot(na(lastQM.typ) or lastQM.typ == "Bearish" ? na : lastQM.breakLvl, "Bull QMBreak", display=display.none)
plot(na(lastQM.typ) or lastQM.typ == "Bullish" ? na : lastQM.sweepLvl, "Bear QMSweep", display=display.none)
plot(na(lastQM.typ) or lastQM.typ == "Bullish" ? na : lastQM.breakLvl, "Bear QMBreak", display=display.none)
````
