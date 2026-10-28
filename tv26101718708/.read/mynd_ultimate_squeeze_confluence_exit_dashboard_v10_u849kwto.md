# MYND Ultimate Squeeze Confluence & Exit Dashboard v1.0

- url: https://www.tradingview.com/script/U849kwTO-MYND-Ultimate-Squeeze-Confluence-Exit-Dashboard-v1-0/
- type: indicator
- pine_id: PUB;118c8ac4c2654720a6d23b9d098dc0b7
- version: 1.0

## Description

MYND Ultimate Squeeze Confluence & Exit Dashboard [v1.0]

Multi-timeframe squeeze confluence for catching coiled setups before they fire - now paired with a genuine chart-resolution Exit Engine that tells you when the ride is over.

WHAT IT DOES

This is a two-sided squeeze tool. The ENTRY side scans up to 15 independent, user-configurable timeframes at once for TTM-Squeeze-Pro-style compression (a 3-tier Bollinger-inside-Keltner read), and flags when several timeframes fire together in the same direction - true multi-timeframe "coiled and ready" confluence, not just a single-timeframe squeeze. The EXIT side runs at your chart's own resolution and watches an active fired trade for momentum deceleration, a volatility/ATR climax, fresh re-compression forming again, higher-timeframe alignment breaking down, and staleness - combined into a single Squeeze Exit Score and a HOLD/CAUTION/EXIT read.

HOW IT WORKS

Each of your 15 configured timeframes is checked for a Bollinger Band sitting inside 3 nested Keltner Channel bands (tightest to loosest = deeper compression tier). A squeeze "fires" when the bands release. The entry engine tallies how many timeframes are squeezed, how deep, which direction they lean, and whether fires are volume-confirmed and holding - rolled into a 0-100 Squeeze Ready Score and a separate Direction Confidence Score. An HTF Alignment check keeps you from entering a move on one timeframe that's firing into an opposing move on a higher one, with a mirrored LTF Pre-Confirm check for early lower-timeframe agreement. Once a trade fires on your chart's own timeframe, the Exit Engine takes over: it watches momentum's acceleration for signs of thrust fading, volume/range for a climax/rejection signature, the squeeze engine itself for fresh re-compression, and the higher timeframes for alignment breaking down - all weighted into the Squeeze Exit Score.

KEY FEATURES

A dynamic heatmap strip and detail table covering all 15 timeframes (tightest-first sort, HTF Align and LTF Pre-Confirm columns, volume/anti-fakeout confirmation). Squeeze Ready Score, Direction Confidence Score, and a rolling Live Signal Accuracy tracker split Bullish/Bearish. A dedicated Exit Engine section with 5 independent exit signals rolled into one Squeeze Exit Score and state. CMF/price divergence detection and a projected earnings countdown. Full Light/Dark/Custom theming plus a Colorblind-Safe Okabe-Ito option, complete color customization, and tooltips throughout.

HOW TO USE IT

Configure your 15 timeframes (defaults: 5m, 15m, 1H, 4H, Daily, Weekly) and watch the heatmap/table for multiple timeframes compressing together. When several fire the same direction with HTF alignment intact, that's your entry read - check the Direction Confidence Score for how clear the direction actually is, not just how coiled it is. Once you're in the trade, watch the Exit Engine section: CAUTION means tighten your management, EXIT means multiple exhaustion signals are agreeing.

SETTINGS WORTH TUNING FIRST

Minimum Timeframes Firing Same Direction for Alert - how many of your 15 need to agree before the entry alert fires. Squeeze Exit Score CAUTION/EXIT Levels - the sensitivity dial for the exit read. Typical Hold (bars) - set this to roughly your own usual swing hold length so the staleness flag means something on your timeframe.

ALERTS

9 alerts total, all standard alertcondition() alerts - no special setup required. Individual alerts cover Bullish/Bearish Multi-Timeframe Squeeze Fire, Squeeze Exit CAUTION/EXIT, Post-Fire Re-Compression Detected, and a Live Accuracy Warning. Three combo alerts bundle these down: ALL Entries, ALL Exits, and ALL Signals.

This tool can only tell you what squeeze/momentum/volatility behavior has looked like recently on this symbol/timeframe - it is not a guarantee of future performance. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("MYND Ultimate Squeeze Confluence & Exit Dashboard v1.0", shorttitle="MYND USqCE v1.0", overlay=true, max_labels_count=500)
// =====================================================================================
// MYND ULTIMATE SQUEEZE CONFLUENCE & EXIT DASHBOARD - v1.0
// Tool #80 in the MYND swing-trading indicator set.
// =====================================================================================

//
//  1. EXIT ENGINE  Runs at CHART resolution (the timeframe you're actually trading), independent of the 15 entry-side timeframe
//     slots, since a trade's exit has to be read on the timeframe you're actually IN.
//     Four techniques, each reusing a method already proven elsewhere in this suite
//     rather than inventing new math:
//       a. Momentum Curvature Deceleration - reuses #7 Ignition/Exhaustion Curvature's
//          technique (RSI -> smoothed momentum -> velocity -> acceleration -> rolling
//          z-score). A sharp deceleration (negative acceleration z-score) while price is
//          still trending in the fired direction reads as "this move is losing thrust."
//       b. Volatility/ATR Climax - reuses #31 Distribution/Capitulation Exit Engine's
//          technique (volume z-score spike + expanded-range bar + close position in that
//          range as a rejection read). Reads as "this move just had its blow-off."
//       c. Post-Fire Re-Compression - novel to this build, but needs no new math: the
//          exact same squeeze-detection engine used for ENTRIES simply keeps running on
//          the chart's own bars after a fire, and a fresh squeeze forming again soon after
//          is a well-known "the move is stalling, energy rebuilding for a new decision"
//          signal.
//       d. HTF Alignment as an exit trigger - the entry engine already computes, for each
//          of the 15 configured timeframes, whether it agrees with every enabled HIGHER-
//          duration timeframe's tier-weighted net lean (htfAlignArr). This adds the SAME
//          check anchored to the CHART's own timeframe (not just the 15 slots), so it can
//          also serve as an exit trigger, not just an entry gate: if a chart-resolution
//          trade was aligned with the higher timeframes at entry and that alignment later
//          flips to Conflicts, that is an early exit warning.
//     Plus a Bars-Since-Fired staleness flag (chart resolution trade has run past your own
//     configured "typical hold" expectation with no fresh confirmation), all rolled into a
//     single weighted 0-100 "Squeeze Exit Score" mirroring the existing "Squeeze Ready
//     Score" architecture, resolved into a 3-state HOLD / CAUTION / EXIT read.
//
//  2. CONFLUENCE-SHARPENING (entry side):
//       a. LTF Pre-Confirm - the existing MTF Alignment check only looked at HIGHER-
//          duration timeframes. This adds the mirror: for each enabled timeframe, whether
//          every enabled LOWER-duration timeframe already agrees with ITS lean - an early,
//          faster-timeframe pre-confirmation read, alongside the existing HTF Align column.
//       b. Direction Confidence Score - a new, separate 0-100 score isolating "how sure
//          are we of the DIRECTION" (agreement ratio + tier-weighted lean magnitude) from
//          the existing Squeeze Ready Score, which blends direction together with squeeze
//          magnitude/depth. Tight-but-undirected and directionally-clear-but-loose setups
//          now read differently instead of collapsing into one number.
//       c. Live Signal Accuracy - a genuine rolling self-tracker (none existed before),
//          grading the multi-timeframe group-fire event's forward return, split Bullish
//          vs. Bearish, same pattern as #7's split Ignition/Exhaustion accuracy.
//       d. RAR-style candle-quality enrichment - the Exit Engine's Volatility Climax
//          sub-score folds in body-to-range ratio and wick-rejection quality (the same
//          candle-quality read behind #59's Relative Aggressiveness Ratio concept),
//          not just raw volume, for a sharper climax read.
//
//  3. FULL MYND STANDARDS RETROFIT: Combo Alert Bundling (was 1 bare alertcondition, now a
//     full set covering entries, exits, and bundled combos); Total Control (distinct table
//     header background/text color controls, 5-tier text size including "Huge", full color
//     customization checklist); Theme & Accessibility (Dark/Light/Custom preserved from the
//     original, PLUS a new Colorblind-Safe Okabe-Ito toggle collapsing bull/bear colors);
//     Tooltip Coverage on every non-cosmetic input; ran through MYND's mandatory Full
//     Pre-Delivery Review before delivery (see MYND_Project_Notes.md for the review notes).

// =====================================================================================
// ---------------------------------------------------------------------------------------
// INPUTS - Timeframes (blank = unused slot). Unchanged from the ported v4.
// ---------------------------------------------------------------------------------------
tf1  = input.timeframe("5",   "Timeframe 1",                    group = "Timeframes", tooltip = "One of up to 15 independent, arbitrary timeframes this tool scans for squeeze confluence. Blank = unused slot.")
tf2  = input.timeframe("15",  "Timeframe 2",                    group = "Timeframes")
tf3  = input.timeframe("60",  "Timeframe 3",                    group = "Timeframes")
tf4  = input.timeframe("240", "Timeframe 4",                    group = "Timeframes")
tf5  = input.timeframe("D",   "Timeframe 5",                    group = "Timeframes")
tf6  = input.timeframe("W",   "Timeframe 6",                    group = "Timeframes")
tf7  = input.timeframe("",    "Timeframe 7 (blank = unused)",   group = "Timeframes")
tf8  = input.timeframe("",    "Timeframe 8 (blank = unused)",   group = "Timeframes")
tf9  = input.timeframe("",    "Timeframe 9 (blank = unused)",   group = "Timeframes")
tf10 = input.timeframe("",    "Timeframe 10 (blank = unused)",  group = "Timeframes")
tf11 = input.timeframe("",    "Timeframe 11 (blank = unused)",  group = "Timeframes")
tf12 = input.timeframe("",    "Timeframe 12 (blank = unused)",  group = "Timeframes")
tf13 = input.timeframe("",    "Timeframe 13 (blank = unused)",  group = "Timeframes")
tf14 = input.timeframe("",    "Timeframe 14 (blank = unused)",  group = "Timeframes")
tf15 = input.timeframe("",    "Timeframe 15 (blank = unused)",  group = "Timeframes")
// ---------------------------------------------------------------------------------------
// INPUTS - Squeeze Calculation (TTM Squeeze Pro-style 3-tier read). Unchanged from v4.
// ---------------------------------------------------------------------------------------
sqzLen        = input.int(13, "BB / KC / Momentum Length", minval = 1, group = "Squeeze Calculation", tooltip = "Shared length for the Bollinger Band, all 3 Keltner Channel tiers, and the momentum linreg used by the entry engine.")
sqzBbMult     = input.float(1.8, "Bollinger Band Multiplier", minval = 0.1, step = 0.1, group = "Squeeze Calculation", tooltip = "Standard-deviation multiplier for the Bollinger Band used in the squeeze test.")
sqzKcHighMult = input.float(1.0, "Keltner Multiplier - High (tightest tier)", minval = 0.1, step = 0.1, group = "Squeeze Calculation", tooltip = "Tightest Keltner band - BB inside this = Tier 3 (deepest compression). Corrected 2026-08-19 from 1.5 to the verified real TTM Squeeze Pro standard of 1.0 (2 independent sources) - see MYND_Project_Notes.md, Standing Design Convention #8.")
sqzKcMidMult  = input.float(1.5, "Keltner Multiplier - Mid tier", minval = 0.1, step = 0.1, group = "Squeeze Calculation", tooltip = "Middle Keltner band - BB inside this (but not High) = Tier 2.")
sqzKcLowMult  = input.float(2.0, "Keltner Multiplier - Low (loosest, = squeeze on/off)", minval = 0.1, step = 0.1, group = "Squeeze Calculation", tooltip = "Loosest Keltner band - this is the actual squeeze on/off test (BB inside Low band). Tier 1 if only this one is met.")
// ---------------------------------------------------------------------------------------
// INPUTS - Volume & Anti-Fakeout Confirmation (entry side). Unchanged from v4.
// ---------------------------------------------------------------------------------------
volAvgLen           = input.int(20, "Volume Average Length", minval = 1, group = "Volume & Anti-Fakeout Confirmation", tooltip = "Rolling average length volume is compared against, both for entry-side fire confirmation and (reused) the Exit Engine's climax check.")
volContractMult     = input.float(0.8, "Contraction Threshold (x average, squeeze building)", minval = 0.1, step = 0.05, group = "Volume & Anti-Fakeout Confirmation", tooltip = "Volume below this multiple of average, while squeezed, is flagged as a healthy low-participation compression.")
volExpandMult       = input.float(1.5, "Expansion Threshold (x average, confirms a fire)", minval = 0.1, step = 0.1, group = "Volume & Anti-Fakeout Confirmation", tooltip = "Volume at or above this multiple of average, on the fire bar, is required to mark that fire as volume-confirmed.")
antiFakeoutHoldBars = input.int(3, "Anti-Fakeout Hold Bars (direction must hold this long post-fire)", minval = 1, group = "Volume & Anti-Fakeout Confirmation", tooltip = "How many bars a fired direction must keep agreeing with the timeframe's own lean before that fire is marked 'Confirmed' rather than 'Holding' or 'Weak/Reversed'.")
// ---------------------------------------------------------------------------------------
// INPUTS - Squeeze Ready Score (entry-side composite). Unchanged from v4.
// ---------------------------------------------------------------------------------------
wSqueezed        = input.float(1.0, "Weight: Squeezed Count", minval = 0, group = "Squeeze Ready Score", tooltip = "How much weight the fraction of enabled timeframes currently squeezed carries in the 0-100 Squeeze Ready Score.")
wTier            = input.float(1.0, "Weight: Compression Depth (Tier Sum)", minval = 0, group = "Squeeze Ready Score", tooltip = "How much weight total compression depth (sum of Tier 0-3 across enabled timeframes) carries.")
wAgree           = input.float(1.0, "Weight: Directional Agreement", minval = 0, group = "Squeeze Ready Score", tooltip = "How much weight the fraction of enabled timeframes leaning the same direction carries.")
wFire            = input.float(1.5, "Weight: High-Confidence Fires", minval = 0, group = "Squeeze Ready Score", tooltip = "How much weight timeframes that have fired AND passed both the volume and hold-bars anti-fakeout checks carry.")
useRegimePenalty = input.bool(true, "Apply Choppy-Regime Penalty (chart resolution, -15%)", group = "Squeeze Ready Score", tooltip = "When on, the Squeeze Ready Score is shrunk 15% if the chart-resolution Choppiness Index says the market isn't trending enough to trust a breakout right now.")
chopLen          = input.int(14, "Choppiness Index Length", minval = 2, group = "Squeeze Ready Score")
chopThreshold    = input.float(61.8, "Max Choppiness Allowed (below = trending enough)", minval = 0, maxval = 100, group = "Squeeze Ready Score", tooltip = "Choppiness Index below this level is considered 'trending enough' - at or above it, the regime penalty applies (if enabled).")
// ---------------------------------------------------------------------------------------
// INPUTS - Divergence Detection (chart resolution CMF/price). Unchanged from v4.
// ---------------------------------------------------------------------------------------
useCmfDivergence = input.bool(true, "Use CMF/Price Divergence Detection", group = "Divergence Detection", tooltip = "Chaikin Money Flow vs. price pivot divergence, computed at chart resolution.")
cmfLen           = input.int(21, "CMF Length", minval = 1, group = "Divergence Detection")
divLeft          = input.int(5, "Pivot Left Bars", minval = 1, group = "Divergence Detection")
divRight         = input.int(5, "Pivot Right Bars", minval = 1, group = "Divergence Detection")
divMaxLookback   = input.int(60, "Max Bars Between Pivots", minval = 1, group = "Divergence Detection")
divPersistBars   = input.int(10, "'Recent' Window (bars)", minval = 1, group = "Divergence Detection")
showDivMarkers   = input.bool(true, "Show On-Chart Divergence Markers", group = "Divergence Detection")
divMarkerSize    = input.string("Normal", "Divergence Marker Size", options = ["Small", "Normal", "Large"], group = "Divergence Detection")
bullDivColor     = input.color(#00E5FF, "Bullish Divergence Marker", group = "Divergence Detection")
bearDivColor     = input.color(#FF6E40, "Bearish Divergence Marker", group = "Divergence Detection")
// ---------------------------------------------------------------------------------------
// INPUTS - MTF Alignment (entry-side HTF gate + new LTF Pre-Confirm). HTF half unchanged
// from v4; LTF Pre-Confirm is new in v1.0 (confluence-sharpening item 2a).
// ---------------------------------------------------------------------------------------
requireHtfAlignForFire = input.bool(true, "Require HTF Alignment for Group-Fire Alert (suppresses alert/marker on conflict)", group = "MTF Alignment", tooltip = "When on, the multi-timeframe group-fire alert/marker is suppressed if the firing direction conflicts with a higher enabled timeframe's net lean - directly prevents entering a move on one timeframe that fires into an opposing move on a higher one.")
showLtfPreConfirm      = input.bool(true, "Show LTF Pre-Confirm Column (lower-timeframe early agreement)", group = "MTF Alignment", tooltip = "New in v1.0: mirrors the HTF Align check downward - for each enabled timeframe, whether every enabled LOWER-duration timeframe already agrees with its lean, an earlier/faster pre-confirmation read.")
htfAlignConflictColor  = input.color(#FF9100, "HTF/LTF Conflict Highlight (orange)", group = "MTF Alignment")
// ---------------------------------------------------------------------------------------
// INPUTS - Exit Engine (NEW in v1.0). Runs at chart resolution - the timeframe you're
// actually trading. Defaults are Claude's own judgment call (flagged to Travis, same as
// every other new-default in this project), built by reusing #7's curvature technique and
// #31's climax technique rather than inventing new math.
// ---------------------------------------------------------------------------------------
exitRsiLen        = input.int(14, "Momentum RSI Length (Exit Engine)", minval = 1, group = "Exit Engine", tooltip = "RSI feeding the smoothed momentum line the curvature-deceleration exit check is built from. Same technique as MYND Ignition/Exhaustion Curvature (#7).")
exitSmoothLen     = input.int(5, "Momentum Smoothing (EMA)", minval = 1, group = "Exit Engine")
exitVelSmoothLen  = input.int(3, "Velocity Smoothing (EMA)", minval = 1, group = "Exit Engine")
exitAccelSmoothLen = input.int(3, "Acceleration Smoothing (EMA)", minval = 1, group = "Exit Engine")
exitZLen          = input.int(50, "Acceleration Z-Score Lookback", minval = 5, group = "Exit Engine")
exitDecelZThreshold = input.float(-1.5, "Deceleration Z-Score Threshold (negative = thrust fading)", maxval = 0, group = "Exit Engine", tooltip = "Acceleration z-score at or below this, while price is still trending in the fired direction, flags momentum-curvature deceleration - the move that fired out of the squeeze is running out of thrust.")
exitVolAvgLenClimax = input.int(20, "Climax Volume Average Length", minval = 1, group = "Exit Engine")
exitVolZThreshold  = input.float(2.0, "Climax Volume Z-Score Threshold", minval = 0.1, step = 0.1, group = "Exit Engine", tooltip = "Volume z-score at or above this counts toward a Volatility/ATR Climax read - same technique as MYND Distribution/Capitulation Exit Engine (#31).")
exitAtrLen         = input.int(14, "Climax ATR Length", minval = 1, group = "Exit Engine")
exitRangeAtrMult   = input.float(1.2, "Climax Minimum Bar Range (x ATR)", minval = 0.1, step = 0.1, group = "Exit Engine")
exitClosePosMin    = input.float(0.6, "Climax Close-Position-in-Range Threshold", minval = 0, maxval = 1, step = 0.05, group = "Exit Engine", tooltip = "0 = bar closed at its low, 1 = closed at its high. For a long, a LOW close position (close near the low of an expanded-range bar) reads as rejection/climax; for a short, mirrored. Also folds in wick-rejection candle quality (RAR-style, see #59 concept) rather than raw volume alone.")
recompressWindowBars = input.int(5, "Re-Compression Watch Window (bars after fire)", minval = 1, group = "Exit Engine", tooltip = "How many bars after a chart-resolution fire the tool watches for a fresh squeeze re-forming - a fast re-compression reads as the move stalling and energy rebuilding.")
typicalHoldBars    = input.int(15, "Typical Hold (bars) Before Staleness Flag", minval = 1, group = "Exit Engine", tooltip = "How many bars a chart-resolution trade can run past its fire with no fresh confirmation before the Exit Engine flags it as stale. Set to roughly your own typical swing hold length.")
wDecel  = input.float(1.0, "Exit Weight: Momentum Deceleration", minval = 0, group = "Exit Engine")
wClimax = input.float(1.0, "Exit Weight: Volatility/ATR Climax", minval = 0, group = "Exit Engine")
wRecomp = input.float(1.0, "Exit Weight: Post-Fire Re-Compression", minval = 0, group = "Exit Engine")
wHtfExit = input.float(1.0, "Exit Weight: HTF Alignment Conflict", minval = 0, group = "Exit Engine")
wStale  = input.float(0.5, "Exit Weight: Staleness", minval = 0, group = "Exit Engine")
exitCautionLevel = input.float(40, "Squeeze Exit Score: CAUTION Level", minval = 0, maxval = 100, group = "Exit Engine", tooltip = "Squeeze Exit Score at or above this (but below the EXIT level) reads as CAUTION - thrust is fading, tighten your own stop/management.")
exitExitLevel     = input.float(70, "Squeeze Exit Score: EXIT Level", minval = 0, maxval = 100, group = "Exit Engine", tooltip = "Squeeze Exit Score at or above this reads as EXIT - multiple exhaustion signals agreeing.")
// ---------------------------------------------------------------------------------------
// INPUTS - Direction Confidence Score (NEW, confluence-sharpening item 2b).
// ---------------------------------------------------------------------------------------
showDirConfidence = input.bool(true, "Show Direction Confidence Score", group = "Direction Confidence", tooltip = "A separate 0-100 score isolating how sure the entry engine is of the DIRECTION (agreement ratio + tier-weighted lean magnitude), distinct from the Squeeze Ready Score which blends direction together with squeeze magnitude/depth.")
// ---------------------------------------------------------------------------------------
// INPUTS - Live Signal Accuracy (NEW, confluence-sharpening item 2c). Grades the
// multi-timeframe group-fire event's forward return, split Bullish vs. Bearish.
// ---------------------------------------------------------------------------------------
evalForwardBars     = input.int(5, "Evaluation Forward Bars", minval = 1, group = "Live Signal Accuracy", tooltip = "How many bars forward each group-fire's outcome is measured over when grading rolling accuracy - should roughly match your intended holding period.")
accRollingWindow    = input.int(20, "Accuracy Rolling Window (signals)", minval = 5, group = "Live Signal Accuracy", tooltip = "How many of each direction's (Bullish/Bearish) most recent graded group-fires its accuracy % is based on - rolling, not all-time.")
accuracyWarnLevel   = input.float(45, "Accuracy Warning Level (%)", minval = 1, maxval = 99, group = "Live Signal Accuracy", tooltip = "If either direction's Live Accuracy falls below this (with enough tracked signals), the Live Accuracy Warning alert fires.")
minTrackedForAlert  = input.int(10, "Minimum Tracked Signals for Accuracy Alert", minval = 1, group = "Live Signal Accuracy", tooltip = "The accuracy alert stays silent until a direction has at least this many graded group-fires, to avoid an unreliable early read.")
// ---------------------------------------------------------------------------------------
// INPUTS - Display
// ---------------------------------------------------------------------------------------
showHeatmap        = input.bool(true, "Show Heatmap Strip", group = "Display")
showTable          = input.bool(true, "Show Detail Table (includes Composite Summary + Exit Engine)", group = "Display")
showComposite       = input.bool(true, "Include Composite Summary Rows in Detail Table", group = "Display")
showExitEngineRows = input.bool(true, "Include Exit Engine Rows in Detail Table", group = "Display", tooltip = "Adds the chart-resolution Exit Engine section (Momentum Decel, Volatility Climax, Re-Compression, HTF Alignment, Staleness, Squeeze Exit Score, Exit State) to the bottom of the Detail Table.")
showMarker         = input.bool(true, "Show On-Chart Fire Marker", group = "Display")
showExitMarker     = input.bool(true, "Show On-Chart Exit Markers", group = "Display", tooltip = "Shows a marker when the Exit Engine crosses into CAUTION or EXIT, and a distinct marker for Re-Compression detected.")
fireMarkerSize     = input.string("Normal", "Fire Marker Size", options = ["Small", "Normal", "Large"], group = "Display")
boldText           = input.bool(true, "Bold Text / Symbols", group = "Display")
heatmapPos         = input.string("top_right", "Heatmap Position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = "Display")
tablePos           = input.string("bottom_right", "Detail Table Position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = "Display")
heatmapTextSize    = input.string("small", "Heatmap Text Size", options = ["tiny", "small", "normal", "large", "huge"], group = "Display")
detailTableTextSize = input.string("small", "Detail Table Text Size", options = ["tiny", "small", "normal", "large", "huge"], group = "Display")
sortByCompression  = input.bool(true, "Sort Rows/Columns by Compression (Tightest First)", group = "Display")
// ---------------------------------------------------------------------------------------
// INPUTS - Colors & Theme. Dark/Light/Custom preserved from v4; Colorblind-Safe Okabe-Ito
// toggle is NEW in v1.0 (MYND Theme & Accessibility standard), plus NEW distinct table
// header background/text color controls (Total Control standard - previously the header
// row shared the same color as the body text with no separate control).
// ---------------------------------------------------------------------------------------
colorTheme = input.string("Dark", "Color Theme", options = ["Dark", "Light", "Custom"], group = "Colors & Theme", tooltip = "Dark/Light apply a curated palette matched to that chart background. Custom uses the individual color pickers below instead.")
colorblindMode = input.bool(false, "Colorblind-Safe Bull/Bear Colors (Okabe-Ito)", group = "Colors & Theme", tooltip = "When on, collapses all bullish/bearish colors throughout (arrows, fire markers, table cells) to the colorblind-safe Okabe-Ito blue/orange pair - overrides Theme Preset or Custom bull/bear colors. Direction is still distinguished by arrow shape and text (up/down, FIRED, BULLISH/BEARISH), not color alone.")
compressLowColor = input.color(#123B12, "Compression: Loose (dark green)", group = "Colors & Theme")
bullColorCustom  = input.color(#2196F3, "Bullish Direction (Custom theme)", group = "Colors & Theme")
bearColorCustom  = input.color(#FF0000, "Bearish Direction (Custom theme)", group = "Colors & Theme")
alignAgreeColor  = input.color(#2196F3, "Alignment: Agrees (blue)", group = "Colors & Theme")
borderColor      = input.color(color.gray, "Table Border", group = "Colors & Theme")
customTableBg      = input.color(color.new(color.black, 0), "Custom Theme: Table Background", group = "Colors & Theme (Custom theme only)")
customHeaderBg     = input.color(color.new(color.navy, 0), "Custom Theme: Table Header Background (NEW)", group = "Colors & Theme (Custom theme only)", tooltip = "Total Control: distinct header row background, previously not separately configurable.")
customHeaderText   = input.color(color.new(color.white, 0), "Custom Theme: Table Header Text (NEW)", group = "Colors & Theme (Custom theme only)")
customHeatmapText  = input.color(color.white, "Custom Theme: Heatmap Base Text", group = "Colors & Theme (Custom theme only)")
customDetailText   = input.color(color.white, "Custom Theme: Detail Table Base Text", group = "Colors & Theme (Custom theme only)")
customNeutralText  = input.color(#D3D3D3, "Custom Theme: Neutral Text", group = "Colors & Theme (Custom theme only)")
customNoSqueezeBg  = input.color(#1A1A1A, "Custom Theme: No-Squeeze Cell Background", group = "Colors & Theme (Custom theme only)")
customCompressHigh = input.color(#FFD700, "Custom Theme: Compression Tight Color", group = "Colors & Theme (Custom theme only)")
customConflictBg   = input.color(color.new(#B8860B, 70), "Custom Theme: Conflict Highlight Background", group = "Colors & Theme (Custom theme only)")
alignConflictColor = input.color(#000000, "Alignment: Conflicts (black text, always paired with an explicit light highlight bg)", group = "Colors & Theme")
// ---------------------------------------------------------------------------------------
// INPUTS - Alerts
// ---------------------------------------------------------------------------------------
minAgreeForAlert = input.int(4, "Minimum Timeframes Firing Same Direction for Alert", minval = 1, group = "Alerts")
// ---------------------------------------------------------------------------------------
// INPUTS - Earnings
// ---------------------------------------------------------------------------------------
showEarningsCountdown = input.bool(true, "Show Projected Next-Earnings Countdown", group = "Earnings", tooltip = "PROJECTION only, built from the average interval between past reports - request.earnings() cannot return a real calendar date paired with its value the way request.security() can.")
earningsWarnDays      = input.int(7, "Warn Inside This Many Days", minval = 0, group = "Earnings")
// =====================================================================================
// THEME RESOLUTION - Dark/Light/Custom base palette, then Colorblind-Safe Okabe-Ito
// override on top (same layered pattern as MYND Ignition/Exhaustion Curvature v2.0).
// =====================================================================================
f_themeColor(theme, darkVal, lightVal, customVal) =>
    theme == "Dark" ? darkVal : theme == "Light" ? lightVal : customVal
tableBgColor      = f_themeColor(colorTheme, color.new(color.black, 0), color.white, customTableBg)
headerBgColor     = f_themeColor(colorTheme, color.new(#1A1F2E, 0), color.new(color.navy, 0), customHeaderBg)
headerTextColor   = f_themeColor(colorTheme, color.new(#E0E0E0, 0), color.new(color.white, 0), customHeaderText)
heatmapTextColor  = f_themeColor(colorTheme, color.white, color.black, customHeatmapText)
detailTextColor   = f_themeColor(colorTheme, color.white, color.black, customDetailText)
neutralTextColor  = f_themeColor(colorTheme, #D3D3D3, #5A5A5A, customNeutralText)
alignNeutralColor = neutralTextColor
noSqueezeColor    = f_themeColor(colorTheme, #1A1A1A, #E8E8E8, customNoSqueezeBg)
compressHighColor = f_themeColor(colorTheme, #FFD700, #B8860B, customCompressHigh)
conflictBgColor   = f_themeColor(colorTheme, color.new(#B8860B, 70), color.new(#FFF3CD, 0), customConflictBg)
textFormat        = boldText ? text.format_bold : text.format_none
// Colorblind-Safe Okabe-Ito override (blue/orange) - takes priority over theme/custom bull-
// bear colors when on; direction is still distinguished by shape/text, not color alone.
cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)
bullColor = colorblindMode ? cbBullish : bullColorCustom
bearColor = colorblindMode ? cbBearish : bearColorCustom
// ---------------------------------------------------------------------------------------
// SQUEEZE BUNDLE - one function, called once per configured timeframe via request.security().
// Unchanged from v4 (see the ported original file for full inline documentation of every
// field). sqzOn/compressionScore/etc. use the Low (loosest) Keltner band; sqzTier (0-3)
// reports how many of the 3 nested bands the BB currently sits inside.
// ---------------------------------------------------------------------------------------
f_sqzBundle() =>
    bbBasis = ta.sma(close, sqzLen)
    bbDev = sqzBbMult * ta.stdev(close, sqzLen)
    bbUpper = bbBasis + bbDev
    bbLower = bbBasis - bbDev
    kcBasis = ta.sma(close, sqzLen)
    kcRangeMa = ta.sma(ta.tr, sqzLen)
    kcHighUpper = kcBasis + sqzKcHighMult * kcRangeMa
    kcHighLower = kcBasis - sqzKcHighMult * kcRangeMa
    kcMidUpper = kcBasis + sqzKcMidMult * kcRangeMa
    kcMidLower = kcBasis - sqzKcMidMult * kcRangeMa
    kcLowUpper = kcBasis + sqzKcLowMult * kcRangeMa
    kcLowLower = kcBasis - sqzKcLowMult * kcRangeMa
    sqzOnHigh = bbLower > kcHighLower and bbUpper < kcHighUpper
    sqzOnMid = bbLower > kcMidLower and bbUpper < kcMidUpper
    sqzOnLow = bbLower > kcLowLower and bbUpper < kcLowUpper
    sqzOn = sqzOnLow
    sqzTier = sqzOnHigh ? 3 : sqzOnMid ? 2 : sqzOnLow ? 1 : 0
    bbWidth = bbUpper - bbLower
    kcLowWidth = kcLowUpper - kcLowLower
    compressionRaw = kcLowWidth == 0.0 ? 0.0 : 1.0 - (bbWidth / kcLowWidth)
    compressionScore = math.max(0.0, math.min(1.0, compressionRaw))
    hh = ta.highest(high, sqzLen)
    ll = ta.lowest(low, sqzLen)
    avgHL = (hh + ll) / 2.0
    avgHLC = (avgHL + ta.sma(close, sqzLen)) / 2.0
    mom = ta.linreg(close - avgHLC, sqzLen, 0)
    leanDir = mom > 0.0 ? 1 : mom < 0.0 ? -1 : 0
    var int barsInSqz = 0
    barsInSqz := sqzOn ? barsInSqz + 1 : 0
    firedNow = sqzOn[1] and not sqzOn
    var int lastFiredDir = 0
    lastFiredDir := firedNow ? leanDir : lastFiredDir
    var int barsSinceFired = -1
    barsSinceFired := firedNow ? 0 : (barsSinceFired < 0 ? -1 : barsSinceFired + 1)
    volAvg = ta.sma(volume, volAvgLen)
    volRatio = volAvg == 0.0 ? 1.0 : volume / volAvg
    var bool fireVolConfirmed = false
    fireVolConfirmed := firedNow ? (volRatio >= volExpandMult) : fireVolConfirmed
    var int holdBarsCount = 0
    holdBarsCount := firedNow ? 0 : (lastFiredDir != 0 and leanDir == lastFiredDir ? holdBarsCount + 1 : 0)
    // Anti-repaint [1] offset applied to EACH individual return value here, inside the
    // function - Pine's [] operator only accepts a single series, not a tuple (confirmed
    // via a real compiler error on this exact function in the original project - see
    // MYND_Project_Notes.md / project memory for the [1]-on-a-tuple bug class).
    [sqzOn[1], compressionScore[1], leanDir[1], firedNow[1], lastFiredDir[1], barsInSqz[1], barsSinceFired[1], sqzTier[1], volRatio[1], fireVolConfirmed[1], holdBarsCount[1]]
// ---------------------------------------------------------------------------------------
// PER-TIMEFRAME FETCHES - 15 static call sites. Unchanged from v4.
// ---------------------------------------------------------------------------------------
tf1Str = tf1 == "" ? "D" : tf1
tf2Str = tf2 == "" ? "D" : tf2
tf3Str = tf3 == "" ? "D" : tf3
tf4Str = tf4 == "" ? "D" : tf4
tf5Str = tf5 == "" ? "D" : tf5
tf6Str = tf6 == "" ? "D" : tf6
tf7Str = tf7 == "" ? "D" : tf7
tf8Str = tf8 == "" ? "D" : tf8
tf9Str = tf9 == "" ? "D" : tf9
tf10Str = tf10 == "" ? "D" : tf10
tf11Str = tf11 == "" ? "D" : tf11
tf12Str = tf12 == "" ? "D" : tf12
tf13Str = tf13 == "" ? "D" : tf13
tf14Str = tf14 == "" ? "D" : tf14
tf15Str = tf15 == "" ? "D" : tf15
[sq1, cp1, ln1, fr1, fd1, bi1, sf1, ti1, vr1, vc1, hc1] = request.security(syminfo.tickerid, tf1Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq2, cp2, ln2, fr2, fd2, bi2, sf2, ti2, vr2, vc2, hc2] = request.security(syminfo.tickerid, tf2Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq3, cp3, ln3, fr3, fd3, bi3, sf3, ti3, vr3, vc3, hc3] = request.security(syminfo.tickerid, tf3Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq4, cp4, ln4, fr4, fd4, bi4, sf4, ti4, vr4, vc4, hc4] = request.security(syminfo.tickerid, tf4Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq5, cp5, ln5, fr5, fd5, bi5, sf5, ti5, vr5, vc5, hc5] = request.security(syminfo.tickerid, tf5Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq6, cp6, ln6, fr6, fd6, bi6, sf6, ti6, vr6, vc6, hc6] = request.security(syminfo.tickerid, tf6Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq7, cp7, ln7, fr7, fd7, bi7, sf7, ti7, vr7, vc7, hc7] = request.security(syminfo.tickerid, tf7Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq8, cp8, ln8, fr8, fd8, bi8, sf8, ti8, vr8, vc8, hc8] = request.security(syminfo.tickerid, tf8Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq9, cp9, ln9, fr9, fd9, bi9, sf9, ti9, vr9, vc9, hc9] = request.security(syminfo.tickerid, tf9Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq10, cp10, ln10, fr10, fd10, bi10, sf10, ti10, vr10, vc10, hc10] = request.security(syminfo.tickerid, tf10Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq11, cp11, ln11, fr11, fd11, bi11, sf11, ti11, vr11, vc11, hc11] = request.security(syminfo.tickerid, tf11Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq12, cp12, ln12, fr12, fd12, bi12, sf12, ti12, vr12, vc12, hc12] = request.security(syminfo.tickerid, tf12Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq13, cp13, ln13, fr13, fd13, bi13, sf13, ti13, vr13, vc13, hc13] = request.security(syminfo.tickerid, tf13Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq14, cp14, ln14, fr14, fd14, bi14, sf14, ti14, vr14, vc14, hc14] = request.security(syminfo.tickerid, tf14Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
[sq15, cp15, ln15, fr15, fd15, bi15, sf15, ti15, vr15, vc15, hc15] = request.security(syminfo.tickerid, tf15Str, f_sqzBundle(), lookahead = barmerge.lookahead_on)
var array<string> tfLabelArr = array.new_string(15)
var array<bool> tfEnabledArr = array.new_bool(15)
var array<bool> sqzOnArr = array.new_bool(15)
var array<float> compArr = array.new_float(15)
var array<int> leanArr = array.new_int(15)
var array<bool> firedArr = array.new_bool(15)
var array<int> firedDirArr = array.new_int(15)
var array<int> barsInArr = array.new_int(15)
var array<int> sinceFiredArr = array.new_int(15)
var array<int> tierArr = array.new_int(15)
var array<float> volRatioArr = array.new_float(15)
var array<bool> volConfirmArr = array.new_bool(15)
var array<int> holdCountArr = array.new_int(15)
array.set(tfLabelArr, 0, tf1)
array.set(tfEnabledArr, 0, tf1 != "")
array.set(sqzOnArr, 0, sq1)
array.set(compArr, 0, cp1)
array.set(leanArr, 0, ln1)
array.set(firedArr, 0, fr1)
array.set(firedDirArr, 0, fd1)
array.set(barsInArr, 0, bi1)
array.set(sinceFiredArr, 0, sf1)
array.set(tierArr, 0, ti1)
array.set(volRatioArr, 0, vr1)
array.set(volConfirmArr, 0, vc1)
array.set(holdCountArr, 0, hc1)
array.set(tfLabelArr, 1, tf2)
array.set(tfEnabledArr, 1, tf2 != "")
array.set(sqzOnArr, 1, sq2)
array.set(compArr, 1, cp2)
array.set(leanArr, 1, ln2)
array.set(firedArr, 1, fr2)
array.set(firedDirArr, 1, fd2)
array.set(barsInArr, 1, bi2)
array.set(sinceFiredArr, 1, sf2)
array.set(tierArr, 1, ti2)
array.set(volRatioArr, 1, vr2)
array.set(volConfirmArr, 1, vc2)
array.set(holdCountArr, 1, hc2)
array.set(tfLabelArr, 2, tf3)
array.set(tfEnabledArr, 2, tf3 != "")
array.set(sqzOnArr, 2, sq3)
array.set(compArr, 2, cp3)
array.set(leanArr, 2, ln3)
array.set(firedArr, 2, fr3)
array.set(firedDirArr, 2, fd3)
array.set(barsInArr, 2, bi3)
array.set(sinceFiredArr, 2, sf3)
array.set(tierArr, 2, ti3)
array.set(volRatioArr, 2, vr3)
array.set(volConfirmArr, 2, vc3)
array.set(holdCountArr, 2, hc3)
array.set(tfLabelArr, 3, tf4)
array.set(tfEnabledArr, 3, tf4 != "")
array.set(sqzOnArr, 3, sq4)
array.set(compArr, 3, cp4)
array.set(leanArr, 3, ln4)
array.set(firedArr, 3, fr4)
array.set(firedDirArr, 3, fd4)
array.set(barsInArr, 3, bi4)
array.set(sinceFiredArr, 3, sf4)
array.set(tierArr, 3, ti4)
array.set(volRatioArr, 3, vr4)
array.set(volConfirmArr, 3, vc4)
array.set(holdCountArr, 3, hc4)
array.set(tfLabelArr, 4, tf5)
array.set(tfEnabledArr, 4, tf5 != "")
array.set(sqzOnArr, 4, sq5)
array.set(compArr, 4, cp5)
array.set(leanArr, 4, ln5)
array.set(firedArr, 4, fr5)
array.set(firedDirArr, 4, fd5)
array.set(barsInArr, 4, bi5)
array.set(sinceFiredArr, 4, sf5)
array.set(tierArr, 4, ti5)
array.set(volRatioArr, 4, vr5)
array.set(volConfirmArr, 4, vc5)
array.set(holdCountArr, 4, hc5)
array.set(tfLabelArr, 5, tf6)
array.set(tfEnabledArr, 5, tf6 != "")
array.set(sqzOnArr, 5, sq6)
array.set(compArr, 5, cp6)
array.set(leanArr, 5, ln6)
array.set(firedArr, 5, fr6)
array.set(firedDirArr, 5, fd6)
array.set(barsInArr, 5, bi6)
array.set(sinceFiredArr, 5, sf6)
array.set(tierArr, 5, ti6)
array.set(volRatioArr, 5, vr6)
array.set(volConfirmArr, 5, vc6)
array.set(holdCountArr, 5, hc6)
array.set(tfLabelArr, 6, tf7)
array.set(tfEnabledArr, 6, tf7 != "")
array.set(sqzOnArr, 6, sq7)
array.set(compArr, 6, cp7)
array.set(leanArr, 6, ln7)
array.set(firedArr, 6, fr7)
array.set(firedDirArr, 6, fd7)
array.set(barsInArr, 6, bi7)
array.set(sinceFiredArr, 6, sf7)
array.set(tierArr, 6, ti7)
array.set(volRatioArr, 6, vr7)
array.set(volConfirmArr, 6, vc7)
array.set(holdCountArr, 6, hc7)
array.set(tfLabelArr, 7, tf8)
array.set(tfEnabledArr, 7, tf8 != "")
array.set(sqzOnArr, 7, sq8)
array.set(compArr, 7, cp8)
array.set(leanArr, 7, ln8)
array.set(firedArr, 7, fr8)
array.set(firedDirArr, 7, fd8)
array.set(barsInArr, 7, bi8)
array.set(sinceFiredArr, 7, sf8)
array.set(tierArr, 7, ti8)
array.set(volRatioArr, 7, vr8)
array.set(volConfirmArr, 7, vc8)
array.set(holdCountArr, 7, hc8)
array.set(tfLabelArr, 8, tf9)
array.set(tfEnabledArr, 8, tf9 != "")
array.set(sqzOnArr, 8, sq9)
array.set(compArr, 8, cp9)
array.set(leanArr, 8, ln9)
array.set(firedArr, 8, fr9)
array.set(firedDirArr, 8, fd9)
array.set(barsInArr, 8, bi9)
array.set(sinceFiredArr, 8, sf9)
array.set(tierArr, 8, ti9)
array.set(volRatioArr, 8, vr9)
array.set(volConfirmArr, 8, vc9)
array.set(holdCountArr, 8, hc9)
array.set(tfLabelArr, 9, tf10)
array.set(tfEnabledArr, 9, tf10 != "")
array.set(sqzOnArr, 9, sq10)
array.set(compArr, 9, cp10)
array.set(leanArr, 9, ln10)
array.set(firedArr, 9, fr10)
array.set(firedDirArr, 9, fd10)
array.set(barsInArr, 9, bi10)
array.set(sinceFiredArr, 9, sf10)
array.set(tierArr, 9, ti10)
array.set(volRatioArr, 9, vr10)
array.set(volConfirmArr, 9, vc10)
array.set(holdCountArr, 9, hc10)
array.set(tfLabelArr, 10, tf11)
array.set(tfEnabledArr, 10, tf11 != "")
array.set(sqzOnArr, 10, sq11)
array.set(compArr, 10, cp11)
array.set(leanArr, 10, ln11)
array.set(firedArr, 10, fr11)
array.set(firedDirArr, 10, fd11)
array.set(barsInArr, 10, bi11)
array.set(sinceFiredArr, 10, sf11)
array.set(tierArr, 10, ti11)
array.set(volRatioArr, 10, vr11)
array.set(volConfirmArr, 10, vc11)
array.set(holdCountArr, 10, hc11)
array.set(tfLabelArr, 11, tf12)
array.set(tfEnabledArr, 11, tf12 != "")
array.set(sqzOnArr, 11, sq12)
array.set(compArr, 11, cp12)
array.set(leanArr, 11, ln12)
array.set(firedArr, 11, fr12)
array.set(firedDirArr, 11, fd12)
array.set(barsInArr, 11, bi12)
array.set(sinceFiredArr, 11, sf12)
array.set(tierArr, 11, ti12)
array.set(volRatioArr, 11, vr12)
array.set(volConfirmArr, 11, vc12)
array.set(holdCountArr, 11, hc12)
array.set(tfLabelArr, 12, tf13)
array.set(tfEnabledArr, 12, tf13 != "")
array.set(sqzOnArr, 12, sq13)
array.set(compArr, 12, cp13)
array.set(leanArr, 12, ln13)
array.set(firedArr, 12, fr13)
array.set(firedDirArr, 12, fd13)
array.set(barsInArr, 12, bi13)
array.set(sinceFiredArr, 12, sf13)
array.set(tierArr, 12, ti13)
array.set(volRatioArr, 12, vr13)
array.set(volConfirmArr, 12, vc13)
array.set(holdCountArr, 12, hc13)
array.set(tfLabelArr, 13, tf14)
array.set(tfEnabledArr, 13, tf14 != "")
array.set(sqzOnArr, 13, sq14)
array.set(compArr, 13, cp14)
array.set(leanArr, 13, ln14)
array.set(firedArr, 13, fr14)
array.set(firedDirArr, 13, fd14)
array.set(barsInArr, 13, bi14)
array.set(sinceFiredArr, 13, sf14)
array.set(tierArr, 13, ti14)
array.set(volRatioArr, 13, vr14)
array.set(volConfirmArr, 13, vc14)
array.set(holdCountArr, 13, hc14)
array.set(tfLabelArr, 14, tf15)
array.set(tfEnabledArr, 14, tf15 != "")
array.set(sqzOnArr, 14, sq15)
array.set(compArr, 14, cp15)
array.set(leanArr, 14, ln15)
array.set(firedArr, 14, fr15)
array.set(firedDirArr, 14, fd15)
array.set(barsInArr, 14, bi15)
array.set(sinceFiredArr, 14, sf15)
array.set(tierArr, 14, ti15)
array.set(volRatioArr, 14, vr15)
array.set(volConfirmArr, 14, vc15)
array.set(holdCountArr, 14, hc15)
// ---------------------------------------------------------------------------------------
// Per-timeframe duration in seconds (timeframe.in_seconds()) - used by both the HTF Align
// (existing) and new LTF Pre-Confirm checks below. Unchanged from v4.
// ---------------------------------------------------------------------------------------
var array<float> durArr = array.new_float(15)
array.set(durArr, 0, timeframe.in_seconds(tf1Str))
array.set(durArr, 1, timeframe.in_seconds(tf2Str))
array.set(durArr, 2, timeframe.in_seconds(tf3Str))
array.set(durArr, 3, timeframe.in_seconds(tf4Str))
array.set(durArr, 4, timeframe.in_seconds(tf5Str))
array.set(durArr, 5, timeframe.in_seconds(tf6Str))
array.set(durArr, 6, timeframe.in_seconds(tf7Str))
array.set(durArr, 7, timeframe.in_seconds(tf8Str))
array.set(durArr, 8, timeframe.in_seconds(tf9Str))
array.set(durArr, 9, timeframe.in_seconds(tf10Str))
array.set(durArr, 10, timeframe.in_seconds(tf11Str))
array.set(durArr, 11, timeframe.in_seconds(tf12Str))
array.set(durArr, 12, timeframe.in_seconds(tf13Str))
array.set(durArr, 13, timeframe.in_seconds(tf14Str))
array.set(durArr, 14, timeframe.in_seconds(tf15Str))
// ---------------------------------------------------------------------------------------
// MTF ALIGNMENT CHECK - HTF half unchanged from v4. NEW: LTF Pre-Confirm half (confluence-
// sharpening item 2a) mirrors the same computation against every enabled LOWER-duration
// timeframe instead of higher, giving an earlier/faster pre-confirmation read alongside the
// existing HTF gate.
// ---------------------------------------------------------------------------------------
var array<int> htfAlignArr = array.new_int(15)
var array<bool> htfHasHigherArr = array.new_bool(15)
var array<int> ltfAlignArr = array.new_int(15)
var array<bool> ltfHasLowerArr = array.new_bool(15)
for i = 0 to 14
    if array.get(tfEnabledArr, i)
        durI = array.get(durArr, i)
        ownFiredI = array.get(firedArr, i)
        ownDirI = ownFiredI ? array.get(firedDirArr, i) : array.get(leanArr, i)
        htfWeighted = 0.0
        hasHigher = false
        ltfWeighted = 0.0
        hasLower = false
        for j = 0 to 14
            if array.get(tfEnabledArr, j) and j != i
                durJ = array.get(durArr, j)
                leanJ = array.get(leanArr, j)
                tierJ = array.get(tierArr, j)
                voteJ = leanJ > 0 ? tierJ + 1 : leanJ < 0 ? -(tierJ + 1) : 0
                if durJ > durI
                    hasHigher := true
                    htfWeighted := htfWeighted + voteJ
                if durJ < durI
                    hasLower := true
                    ltfWeighted := ltfWeighted + voteJ
        htfNetSign = htfWeighted > 0.0 ? 1 : htfWeighted < 0.0 ? -1 : 0
        ltfNetSign = ltfWeighted > 0.0 ? 1 : ltfWeighted < 0.0 ? -1 : 0
        alignCode = not hasHigher ? 0 : (ownDirI == 0 or htfNetSign == 0) ? 0 : (ownDirI == htfNetSign ? 1 : -1)
        ltfCode = not hasLower ? 0 : (ownDirI == 0 or ltfNetSign == 0) ? 0 : (ownDirI == ltfNetSign ? 1 : -1)
        array.set(htfAlignArr, i, alignCode)
        array.set(htfHasHigherArr, i, hasHigher)
        array.set(ltfAlignArr, i, ltfCode)
        array.set(ltfHasLowerArr, i, hasLower)
// ---------------------------------------------------------------------------------------
// HELPERS - position/text-size string-to-constant mapping. Text size now has 5 tiers
// (added "huge" - Total Control standard) instead of v4's 4.
// ---------------------------------------------------------------------------------------
f_posFromString(p) =>
    switch p
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.top_right
f_tsize(sz) =>
    switch sz
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        "huge" => size.huge
        => size.small
// ---------------------------------------------------------------------------------------
// COMPOSITE TALLIES - computed unconditionally every bar. Unchanged from v4 except where
// noted (htfConflictActiveCount already existed; nothing new required here for LTF).
// ---------------------------------------------------------------------------------------
var int enabledCount = 0
var int squeezedCount = 0
var int bullLeanCount = 0
var int bearLeanCount = 0
var int firedBullCount = 0
var int firedBearCount = 0
var int fireEventCount = 0
var int volConfirmedCount = 0
var int holdConfirmedCount = 0
var int highConfidenceCount = 0
var int tierSum = 0
var int bullTierWeighted = 0
var int bearTierWeighted = 0
var int htfConflictActiveCount = 0
var float highestDur = -1.0
var int highestTfIdx = -1
enabledCount := 0
squeezedCount := 0
bullLeanCount := 0
bearLeanCount := 0
firedBullCount := 0
firedBearCount := 0
fireEventCount := 0
volConfirmedCount := 0
holdConfirmedCount := 0
highConfidenceCount := 0
tierSum := 0
bullTierWeighted := 0
bearTierWeighted := 0
htfConflictActiveCount := 0
highestDur := -1.0
highestTfIdx := -1
for i = 0 to 14
    if array.get(tfEnabledArr, i)
        enabledCount := enabledCount + 1
        tierI = array.get(tierArr, i)
        tierSum := tierSum + tierI
        if array.get(sqzOnArr, i)
            squeezedCount := squeezedCount + 1
        leanI = array.get(leanArr, i)
        if leanI > 0
            bullLeanCount := bullLeanCount + 1
            bullTierWeighted := bullTierWeighted + tierI + 1
        if leanI < 0
            bearLeanCount := bearLeanCount + 1
            bearTierWeighted := bearTierWeighted + tierI + 1
        if array.get(firedArr, i)
            firedDirI = array.get(firedDirArr, i)
            if firedDirI > 0
                firedBullCount := firedBullCount + 1
            if firedDirI < 0
                firedBearCount := firedBearCount + 1
        lastFiredDirI = array.get(firedDirArr, i)
        if lastFiredDirI != 0
            fireEventCount := fireEventCount + 1
            volConfI = array.get(volConfirmArr, i)
            holdConfI = array.get(holdCountArr, i) >= antiFakeoutHoldBars
            if volConfI
                volConfirmedCount := volConfirmedCount + 1
            if holdConfI
                holdConfirmedCount := holdConfirmedCount + 1
            if volConfI and holdConfI
                highConfidenceCount := highConfidenceCount + 1
            if array.get(htfAlignArr, i) == -1
                htfConflictActiveCount := htfConflictActiveCount + 1
        durI = array.get(durArr, i)
        if durI > highestDur
            highestDur := durI
            highestTfIdx := i
netLeanSign = bullLeanCount > bearLeanCount ? 1 : bullLeanCount < bearLeanCount ? -1 : 0
bullFireGroupEvent = firedBullCount >= minAgreeForAlert and firedBullCount > firedBearCount
bearFireGroupEvent = firedBearCount >= minAgreeForAlert and firedBearCount > firedBullCount
anyFireGroupEventRaw = bullFireGroupEvent or bearFireGroupEvent
groupFireDir = bullFireGroupEvent ? 1 : bearFireGroupEvent ? -1 : 0
groupFireHtfConflict = false
if groupFireDir != 0
    for i = 0 to 14
        if array.get(tfEnabledArr, i) and array.get(firedArr, i) and array.get(firedDirArr, i) == groupFireDir and array.get(htfAlignArr, i) == -1
            groupFireHtfConflict := true
anyFireGroupEvent = anyFireGroupEventRaw and not (requireHtfAlignForFire and groupFireHtfConflict)
// v1.0 CHANGED - v4 had exactly 1 alertcondition (the unsplit group-fire). This splits it
// into Bullish/Bearish so each can be added individually, per the MYND Combo Alert
// Bundling standard - the combined "ALL Entries" bundle is defined further down alongside
// the new Exit Engine alerts.
bullGroupFireFinal = anyFireGroupEvent and bullFireGroupEvent
bearGroupFireFinal = anyFireGroupEvent and bearFireGroupEvent
alertcondition(bullGroupFireFinal, title = "Bullish Multi-Timeframe Squeeze Fire", message = "MYND USqCE: BULLISH multi-timeframe squeeze fire on {{ticker}} ({{interval}})")
alertcondition(bearGroupFireFinal, title = "Bearish Multi-Timeframe Squeeze Fire", message = "MYND USqCE: BEARISH multi-timeframe squeeze fire on {{ticker}} ({{interval}})")
if anyFireGroupEvent
    dirLabel = bullFireGroupEvent ? "BULLISH" : "BEARISH"
    fireCount = bullFireGroupEvent ? firedBullCount : firedBearCount
    alert("MYND USqCE: " + dirLabel + " group fire (" + str.tostring(fireCount) + "/" + str.tostring(enabledCount) + " timeframes)", alert.freq_once_per_bar_close)
markerColor = bullFireGroupEvent ? bullColor : bearColor
if showMarker and anyFireGroupEvent
    dirArrow = bullFireGroupEvent ? "▲" : "▼"
    htfNote = groupFireHtfConflict ? " [HTF conflict]" : ""
    fireLabelText = "SQZ FIRE " + dirArrow + " (" + str.tostring(bullFireGroupEvent ? firedBullCount : firedBearCount) + "/" + str.tostring(enabledCount) + ")" + htfNote
    fireLabelStyle = bullFireGroupEvent ? label.style_label_up : label.style_label_down
    fireLabelPrice = bullFireGroupEvent ? low : high
    if fireMarkerSize == "Small"
        label.new(bar_index, fireLabelPrice, fireLabelText, style = fireLabelStyle, color = markerColor, textcolor = color.white, size = size.small)
    else if fireMarkerSize == "Large"
        label.new(bar_index, fireLabelPrice, fireLabelText, style = fireLabelStyle, color = markerColor, textcolor = color.white, size = size.large)
    else
        label.new(bar_index, fireLabelPrice, fireLabelText, style = fireLabelStyle, color = markerColor, textcolor = color.white, size = size.normal)
// ---------------------------------------------------------------------------------------
// EARNINGS - projected countdown. Unchanged from v4 (PROJECTION, not a pulled calendar
// date - see header note).
// ---------------------------------------------------------------------------------------
earningsActual = request.earnings(syminfo.tickerid, earnings.actual, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
reportChanged = not na(earningsActual) and not na(earningsActual[1]) and earningsActual != earningsActual[1]
var float lastReportTime = na
var float prevReportTime = na
var float avgIntervalDays = 91.0
if reportChanged
    if not na(prevReportTime)
        avgIntervalDays := (time - prevReportTime) / 86400000.0
    prevReportTime := lastReportTime
    lastReportTime := time
projectedNextReportTime = na(lastReportTime) ? na : lastReportTime + avgIntervalDays * 86400000.0
daysToProjectedEarnings = math.round((projectedNextReportTime - time) / 86400000.0)
// ---------------------------------------------------------------------------------------
// CMF/PRICE DIVERGENCE DETECTION (chart resolution). Unchanged from v4.
// ---------------------------------------------------------------------------------------
cmfRange = high - low
cmfMoneyFlowMultiplier = cmfRange == 0 ? 0.0 : ((close - low) - (high - close)) / cmfRange
cmfMoneyFlowVolume = cmfMoneyFlowMultiplier * volume
cmfVolSum = math.sum(volume, cmfLen)
cmfMoneyFlowVolumeSum = math.sum(cmfMoneyFlowVolume, cmfLen)
cmfValue = cmfVolSum == 0 ? 0.0 : cmfMoneyFlowVolumeSum / cmfVolSum
pivLowPrice = ta.pivotlow(low, divLeft, divRight)
pivHighPrice = ta.pivothigh(high, divLeft, divRight)
pivLowCmf = ta.pivotlow(cmfValue, divLeft, divRight)
pivHighCmf = ta.pivothigh(cmfValue, divLeft, divRight)
var float lastPivLowPrice = na
var float lastPivLowCmf = na
var int lastPivLowBar = na
var float lastPivHighPrice = na
var float lastPivHighCmf = na
var int lastPivHighBar = na
bullishDivNow = false
bearishDivNow = false
if not na(pivLowPrice)
    curLowBar = bar_index - divRight
    if not na(lastPivLowPrice) and (curLowBar - lastPivLowBar) <= divMaxLookback and pivLowPrice < lastPivLowPrice and pivLowCmf > lastPivLowCmf
        bullishDivNow := true
    lastPivLowPrice := pivLowPrice
    lastPivLowCmf := pivLowCmf
    lastPivLowBar := curLowBar
if not na(pivHighPrice)
    curHighBar = bar_index - divRight
    if not na(lastPivHighPrice) and (curHighBar - lastPivHighBar) <= divMaxLookback and pivHighPrice > lastPivHighPrice and pivHighCmf < lastPivHighCmf
        bearishDivNow := true
    lastPivHighPrice := pivHighPrice
    lastPivHighCmf := pivHighCmf
    lastPivHighBar := curHighBar
var int barsSinceBullDiv = 999999
var int barsSinceBearDiv = 999999
barsSinceBullDiv := bullishDivNow ? 0 : barsSinceBullDiv + 1
barsSinceBearDiv := bearishDivNow ? 0 : barsSinceBearDiv + 1
recentBullDiv = barsSinceBullDiv <= divPersistBars
recentBearDiv = barsSinceBearDiv <= divPersistBars
plotshape(showDivMarkers and useCmfDivergence and bullishDivNow and divMarkerSize == "Small", title = "Bullish CMF Divergence (Small)", style = shape.diamond, location = location.belowbar, color = bullDivColor, size = size.small)
plotshape(showDivMarkers and useCmfDivergence and bullishDivNow and divMarkerSize == "Normal", title = "Bullish CMF Divergence (Normal)", style = shape.diamond, location = location.belowbar, color = bullDivColor, size = size.normal)
plotshape(showDivMarkers and useCmfDivergence and bullishDivNow and divMarkerSize == "Large", title = "Bullish CMF Divergence (Large)", style = shape.diamond, location = location.belowbar, color = bullDivColor, size = size.large)
plotshape(showDivMarkers and useCmfDivergence and bearishDivNow and divMarkerSize == "Small", title = "Bearish CMF Divergence (Small)", style = shape.diamond, location = location.abovebar, color = bearDivColor, size = size.small)
plotshape(showDivMarkers and useCmfDivergence and bearishDivNow and divMarkerSize == "Normal", title = "Bearish CMF Divergence (Normal)", style = shape.diamond, location = location.abovebar, color = bearDivColor, size = size.normal)
plotshape(showDivMarkers and useCmfDivergence and bearishDivNow and divMarkerSize == "Large", title = "Bearish CMF Divergence (Large)", style = shape.diamond, location = location.abovebar, color = bearDivColor, size = size.large)
// ---------------------------------------------------------------------------------------
// Chart-resolution Choppiness Index - unchanged from v4, feeds the Squeeze Ready Score's
// optional regime penalty.
// ---------------------------------------------------------------------------------------
chopValue = 100.0 * math.log10(math.sum(ta.tr, chopLen) / (ta.highest(high, chopLen) - ta.lowest(low, chopLen))) / math.log10(chopLen)
isTrending = chopValue < chopThreshold
// ---------------------------------------------------------------------------------------
// SQUEEZE READY SCORE - unchanged from v4. NEW alongside it: DIRECTION CONFIDENCE SCORE
// (confluence-sharpening item 2b) - isolates "how sure are we of the DIRECTION" from the
// Ready Score's blend of direction with squeeze magnitude/depth. Two independent 0-100
// reads: a tight-but-undirected setup and a directionally-clear-but-loose setup now look
// different instead of collapsing into one composite.
// ---------------------------------------------------------------------------------------
agreementCount = math.max(bullLeanCount, bearLeanCount)
readyWeightSum = wSqueezed + wTier + wAgree + wFire
squeezeReadyScoreRaw = (enabledCount == 0 or readyWeightSum == 0.0) ? 0.0 : ((squeezedCount / float(enabledCount) * wSqueezed) + (tierSum / (float(enabledCount) * 3.0) * wTier) + (agreementCount / float(enabledCount) * wAgree) + (highConfidenceCount / float(enabledCount) * wFire)) / readyWeightSum * 100.0
squeezeReadyScore = squeezeReadyScoreRaw * (useRegimePenalty ? (isTrending ? 1.0 : 0.85) : 1.0)
netTierWeightedLean = bullTierWeighted - bearTierWeighted
maxTierWeighted = enabledCount * 4
dirConfAgreeTerm = enabledCount == 0 ? 0.0 : agreementCount / float(enabledCount)
dirConfMagTerm = maxTierWeighted == 0 ? 0.0 : math.abs(netTierWeightedLean) / float(maxTierWeighted)
directionConfidenceScore = (dirConfAgreeTerm * 0.5 + dirConfMagTerm * 0.5) * 100.0
// ---------------------------------------------------------------------------------------
// Tightest-first display ordering - unchanged from v4.
// ---------------------------------------------------------------------------------------
enabledIdxArr = array.new_int(0)
sortKeyArr = array.new_float(0)
for i = 0 to 14
    if array.get(tfEnabledArr, i)
        array.push(enabledIdxArr, i)
        array.push(sortKeyArr, array.get(tierArr, i) * 1000.0 + array.get(compArr, i) * 100.0)
displayOrderArr = array.new_int(0)
if enabledCount > 0
    if sortByCompression
        displayOrderArr := array.sort_indices(sortKeyArr, order.descending)
    else
        for k = 0 to enabledCount - 1
            array.push(displayOrderArr, k)
// =====================================================================================
// EXIT ENGINE (NEW in v1.0) - runs at CHART resolution, the timeframe you're actually
// trading, independent of the 15 entry-side timeframe slots. See header note for the full
// rationale on each of the 4 techniques, each reused from an already-proven MYND tool.
// =====================================================================================
// Chart-resolution squeeze bundle, computed DIRECTLY (no request.security wrapper, so no
// [1] offset needed - this is the chart's own live series, the same as every other chart-
// resolution indicator in this suite; the current forming bar naturally updates intrabar,
// which is expected real-time-indicator behavior, not the security()-repaint bug class).
f_sqzChart() =>
    bbBasisC = ta.sma(close, sqzLen)
    bbDevC = sqzBbMult * ta.stdev(close, sqzLen)
    bbUpperC = bbBasisC + bbDevC
    bbLowerC = bbBasisC - bbDevC
    kcRangeMaC = ta.sma(ta.tr, sqzLen)
    kcLowUpperC = bbBasisC + sqzKcLowMult * kcRangeMaC
    kcLowLowerC = bbBasisC - sqzKcLowMult * kcRangeMaC
    sqzOnC = bbLowerC > kcLowLowerC and bbUpperC < kcLowUpperC
    hhC = ta.highest(high, sqzLen)
    llC = ta.lowest(low, sqzLen)
    avgHLC_ = (hhC + llC) / 2.0
    avgHLCC = (avgHLC_ + ta.sma(close, sqzLen)) / 2.0
    momC = ta.linreg(close - avgHLCC, sqzLen, 0)
    leanDirC = momC > 0.0 ? 1 : momC < 0.0 ? -1 : 0
    [sqzOnC, leanDirC]
[sqzOnChart, leanDirChart] = f_sqzChart()
var int lastFiredDirChart = 0
var int barsSinceFiredChart = -1
firedNowChart = sqzOnChart[1] and not sqzOnChart
lastFiredDirChart := firedNowChart ? leanDirChart : lastFiredDirChart
barsSinceFiredChart := firedNowChart ? 0 : (barsSinceFiredChart < 0 ? -1 : barsSinceFiredChart + 1)
hasActiveFireChart = lastFiredDirChart != 0

// --- 1. Momentum Curvature Deceleration (reuses #7 Ignition/Exhaustion Curvature's technique) ---
exitMomentumRaw = ta.rsi(close, exitRsiLen)
exitMomentum = ta.ema(exitMomentumRaw, exitSmoothLen)
exitVelocityRaw = exitMomentum - exitMomentum[1]
exitVelocity = ta.ema(exitVelocityRaw, exitVelSmoothLen)
exitAccelRaw = exitVelocity - exitVelocity[1]
exitAccel = ta.ema(exitAccelRaw, exitAccelSmoothLen)
exitAccelMean = ta.sma(exitAccel, exitZLen)
exitAccelStdev = ta.stdev(exitAccel, exitZLen)
exitAccelZ = exitAccelStdev == 0.0 ? 0.0 : (exitAccel - exitAccelMean) / exitAccelStdev
decelSignal = lastFiredDirChart > 0 ? (exitAccelZ <= exitDecelZThreshold) : lastFiredDirChart < 0 ? (exitAccelZ >= -exitDecelZThreshold) : false
decelTerm = not decelSignal ? 0.0 : math.min(1.0, math.abs(exitAccelZ) / (math.abs(exitDecelZThreshold) * 2.0))

// --- 2. Volatility/ATR Climax (reuses #31 Distribution/Capitulation Exit Engine's technique, ---
// --- plus RAR-style wick-rejection candle quality per confluence-sharpening item 2d) ---
exitVolMean = ta.sma(volume, exitVolAvgLenClimax)
exitVolStdev = ta.stdev(volume, exitVolAvgLenClimax)
exitVolZ = exitVolStdev == 0.0 ? 0.0 : (volume - exitVolMean) / exitVolStdev
exitAtr = ta.atr(exitAtrLen)
exitBarRange = high - low
exitRangeExpanded = exitAtr > 0 and exitBarRange >= exitRangeAtrMult * exitAtr
exitClosePos = exitBarRange == 0.0 ? 0.5 : (close - low) / exitBarRange
exitUpperWickRatio = exitBarRange == 0.0 ? 0.0 : (high - math.max(close, open)) / exitBarRange
exitLowerWickRatio = exitBarRange == 0.0 ? 0.0 : (math.min(close, open) - low) / exitBarRange
climaxRejectionLong = exitClosePos <= (1.0 - exitClosePosMin) or exitUpperWickRatio >= exitClosePosMin
climaxRejectionShort = exitClosePos >= exitClosePosMin or exitLowerWickRatio >= exitClosePosMin
climaxDirRejection = lastFiredDirChart > 0 ? climaxRejectionLong : lastFiredDirChart < 0 ? climaxRejectionShort : false
climaxSignal = lastFiredDirChart != 0 and exitVolZ >= exitVolZThreshold and exitRangeExpanded and climaxDirRejection
climaxTerm = not climaxSignal ? 0.0 : math.min(1.0, exitVolZ / (exitVolZThreshold * 2.0))

// --- 3. Post-Fire Re-Compression (reuses the entry engine's own squeeze detection) ---
var bool recompressDetected = false
recompressDetected := firedNowChart ? false : (hasActiveFireChart and barsSinceFiredChart >= 1 and barsSinceFiredChart <= recompressWindowBars and sqzOnChart ? true : recompressDetected)
recompTerm = recompressDetected ? 1.0 : 0.0

// --- 4. HTF Alignment as an exit trigger (reuses the entry engine's HTF Alignment check, ---
// --- anchored to the CHART's own duration instead of one of the 15 slots) ---
chartDur = timeframe.in_seconds(timeframe.period)
chartHtfWeighted = 0.0
chartHasHigher = false
for j = 0 to 14
    if array.get(tfEnabledArr, j) and array.get(durArr, j) > chartDur
        chartHasHigher := true
        leanJc = array.get(leanArr, j)
        tierJc = array.get(tierArr, j)
        chartHtfWeighted := chartHtfWeighted + (leanJc > 0 ? tierJc + 1 : leanJc < 0 ? -(tierJc + 1) : 0)
chartHtfNetSign = chartHtfWeighted > 0.0 ? 1 : chartHtfWeighted < 0.0 ? -1 : 0
chartHtfConflictNow = hasActiveFireChart and chartHasHigher and chartHtfNetSign != 0 and chartHtfNetSign != lastFiredDirChart
htfExitTerm = chartHtfConflictNow ? 1.0 : 0.0

// --- Staleness flag ---
staleFlagChart = hasActiveFireChart and barsSinceFiredChart > typicalHoldBars
staleTerm = not staleFlagChart ? 0.0 : math.min(1.0, (barsSinceFiredChart - typicalHoldBars) / float(typicalHoldBars))

// --- Squeeze Exit Score composite (mirrors the Squeeze Ready Score architecture) ---
exitWeightSum = wDecel + wClimax + wRecomp + wHtfExit + wStale
squeezeExitScore = (not hasActiveFireChart or exitWeightSum == 0.0) ? 0.0 : (decelTerm * wDecel + climaxTerm * wClimax + recompTerm * wRecomp + htfExitTerm * wHtfExit + staleTerm * wStale) / exitWeightSum * 100.0
exitState = not hasActiveFireChart ? "No Active Fire" : squeezeExitScore >= exitExitLevel ? "EXIT" : squeezeExitScore >= exitCautionLevel ? "CAUTION" : "HOLD"
exitStateJustEnteredCaution = hasActiveFireChart and exitState == "CAUTION" and exitState[1] == "HOLD"
exitStateJustEnteredExit = hasActiveFireChart and exitState == "EXIT" and exitState[1] != "EXIT"
recompressJustDetected = recompressDetected and not recompressDetected[1]
// =====================================================================================
// LIVE SIGNAL ACCURACY (NEW in v1.0, confluence-sharpening item 2c) - grades the multi-
// timeframe group-fire event's forward return, split Bullish vs. Bearish, same rolling-
// window pattern as MYND Ignition/Exhaustion Curvature (#7)'s split accuracy tracker.
// =====================================================================================
var array<float> bullFireResults = array.new_float(0)
var array<float> bearFireResults = array.new_float(0)
hasHistoryAcc = bar_index >= evalForwardBars
bullFireToGrade = hasHistoryAcc ? bullGroupFireFinal[evalForwardBars] : false
bearFireToGrade = hasHistoryAcc ? bearGroupFireFinal[evalForwardBars] : false
if bullFireToGrade
    priorCloseBull = close[evalForwardBars]
    outcomeReturnBull = priorCloseBull > 0 ? (close - priorCloseBull) / priorCloseBull : 0.0
    array.push(bullFireResults, outcomeReturnBull > 0 ? 1.0 : 0.0)
    if array.size(bullFireResults) > accRollingWindow
        array.shift(bullFireResults)
if bearFireToGrade
    priorCloseBear = close[evalForwardBars]
    outcomeReturnBear = priorCloseBear > 0 ? (close - priorCloseBear) / priorCloseBear : 0.0
    array.push(bearFireResults, outcomeReturnBear < 0 ? 1.0 : 0.0)
    if array.size(bearFireResults) > accRollingWindow
        array.shift(bearFireResults)
bullAccPct = array.size(bullFireResults) > 0 ? array.avg(bullFireResults) * 100 : na
bearAccPct = array.size(bearFireResults) > 0 ? array.avg(bearFireResults) * 100 : na
bullTrackedN = array.size(bullFireResults)
bearTrackedN = array.size(bearFireResults)
bullAccLow = bullTrackedN >= minTrackedForAlert and not na(bullAccPct) and bullAccPct < accuracyWarnLevel
bearAccLow = bearTrackedN >= minTrackedForAlert and not na(bearAccPct) and bearAccPct < accuracyWarnLevel
accuracyLowAlert = bullAccLow or bearAccLow
// =====================================================================================
// HEATMAP STRIP - 2 rows x enabledCount cols. Unchanged from v4 (dynamic sizing, tightest-
// first draw order) except bullColor/bearColor now resolve through the Colorblind-Safe
// Okabe-Ito override when on.
// =====================================================================================
var table heatmapTable = table.new(f_posFromString(heatmapPos), math.max(enabledCount, 1), 2, bgcolor = tableBgColor, border_color = borderColor, border_width = 1)
if showHeatmap and enabledCount > 0
    hSz = f_tsize(heatmapTextSize)
    for j = 0 to enabledCount - 1
        i = array.get(enabledIdxArr, array.get(displayOrderArr, j))
        compI = array.get(compArr, i)
        sqzOnI = array.get(sqzOnArr, i)
        leanI = array.get(leanArr, i)
        firedI = array.get(firedArr, i)
        firedDirI = array.get(firedDirArr, i)
        cellColor = sqzOnI ? color.from_gradient(compI, 0.0, 1.0, compressLowColor, compressHighColor) : noSqueezeColor
        arrowChar = firedI ? (firedDirI > 0 ? "▲" : firedDirI < 0 ? "▼" : "•") : (leanI > 0 ? "△" : leanI < 0 ? "▽" : "•")
        arrowColor = firedI ? (firedDirI > 0 ? bullColor : firedDirI < 0 ? bearColor : neutralTextColor) : (leanI > 0 ? bullColor : leanI < 0 ? bearColor : neutralTextColor)
        table.cell(heatmapTable, j, 0, array.get(tfLabelArr, i), text_color = heatmapTextColor, bgcolor = cellColor, text_size = hSz, text_formatting = textFormat)
        table.cell(heatmapTable, j, 1, arrowChar, text_color = arrowColor, bgcolor = cellColor, text_size = hSz, text_formatting = textFormat)
// =====================================================================================
// DETAIL TABLE - 12 columns (v4's 11 + new LTF Pre-Confirm) x dynamic rows (1 header +
// enabledCount timeframe rows + 13 Composite Summary rows if shown [v4's 11 + new Direction
// Confidence + Live Accuracy] + 8 Exit Engine rows if shown [all new]).
// =====================================================================================
compositeRowsCount = showComposite ? 13 : 0
exitRowsCount = showExitEngineRows ? 8 : 0
detailRows = math.max(1, 1 + enabledCount + compositeRowsCount + exitRowsCount)
var table detailTable = table.new(f_posFromString(tablePos), 12, detailRows, bgcolor = tableBgColor, border_color = borderColor, border_width = 1)
if showTable
    tsz = f_tsize(detailTableTextSize)
    // Total Control retrofit - header row now has its own distinct background/text color
    // (headerBgColor/headerTextColor), previously it shared the body's detailTextColor with
    // no separate control.
    table.cell(detailTable, 0, 0, "Timeframe", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 1, 0, "Squeeze", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 2, 0, "Compression", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 3, 0, "Bars In", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 4, 0, "Since Fired", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 5, 0, "Lean", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 6, 0, "Fired", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 7, 0, "Agrees w/ Group", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 8, 0, "Volume", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 9, 0, "Anti-Fakeout", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 10, 0, "HTF Align", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    table.cell(detailTable, 11, 0, "LTF Pre-Confirm", text_color = headerTextColor, bgcolor = headerBgColor, text_size = tsz, text_formatting = textFormat)
    rowN = 0
    if enabledCount > 0
        for j = 0 to enabledCount - 1
            i = array.get(enabledIdxArr, array.get(displayOrderArr, j))
            rowN := j + 1
            sqzOnI = array.get(sqzOnArr, i)
            compI = array.get(compArr, i)
            tierI = array.get(tierArr, i)
            leanI = array.get(leanArr, i)
            firedI = array.get(firedArr, i)
            firedDirI = array.get(firedDirArr, i)
            barsInI = array.get(barsInArr, i)
            sinceFiredI = array.get(sinceFiredArr, i)
            agreesGroup = leanI != 0 and netLeanSign != 0 and leanI == netLeanSign
            volRatioI = array.get(volRatioArr, i)
            holdCntI = array.get(holdCountArr, i)
            volContractingNow = sqzOnI and volRatioI < volContractMult
            volExpandingOnFire = firedI and volRatioI >= volExpandMult
            volBg = volContractingNow ? color.new(compressLowColor, 60) : (volExpandingOnFire ? color.new(alignAgreeColor, 60) : color(na))
            holdConfirmed = firedDirI != 0 and holdCntI >= antiFakeoutHoldBars
            leanAgreesWithFire = firedDirI != 0 and leanI == firedDirI
            antiFakeoutText = firedDirI == 0 ? "-" : (holdConfirmed ? "Confirmed" : (leanAgreesWithFire ? "Holding (" + str.tostring(holdCntI) + ")" : "Weak/Reversed"))
            antiFakeoutColor = firedDirI == 0 ? neutralTextColor : (holdConfirmed ? alignAgreeColor : (leanAgreesWithFire ? neutralTextColor : alignConflictColor))
            antiFakeoutBg = (firedDirI != 0 and not holdConfirmed and not leanAgreesWithFire) ? conflictBgColor : color(na)
            alignCodeI = array.get(htfAlignArr, i)
            hasHigherI = array.get(htfHasHigherArr, i)
            htfAlignText = not hasHigherI ? "Highest TF" : alignCodeI == 1 ? "Aligned" : alignCodeI == -1 ? "Conflicts" : "Neutral"
            htfAlignColor = not hasHigherI ? neutralTextColor : alignCodeI == 1 ? alignAgreeColor : alignCodeI == -1 ? alignConflictColor : neutralTextColor
            htfAlignBg = alignCodeI == -1 ? color.new(htfAlignConflictColor, 60) : color(na)
            // NEW - LTF Pre-Confirm column (confluence-sharpening item 2a), only populated
            // when showLtfPreConfirm is on (otherwise reads "Off" throughout).
            ltfCodeI = array.get(ltfAlignArr, i)
            hasLowerI = array.get(ltfHasLowerArr, i)
            ltfText = not showLtfPreConfirm ? "Off" : not hasLowerI ? "Lowest TF" : ltfCodeI == 1 ? "Confirmed" : ltfCodeI == -1 ? "Conflicts" : "Neutral"
            ltfColor = not showLtfPreConfirm ? neutralTextColor : not hasLowerI ? neutralTextColor : ltfCodeI == 1 ? alignAgreeColor : ltfCodeI == -1 ? alignConflictColor : neutralTextColor
            ltfBg = showLtfPreConfirm and ltfCodeI == -1 ? color.new(htfAlignConflictColor, 60) : color(na)
            table.cell(detailTable, 0, rowN, array.get(tfLabelArr, i), text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 1, rowN, sqzOnI ? "ON" : "off", text_color = color.white, bgcolor = sqzOnI ? color.from_gradient(compI, 0.0, 1.0, compressLowColor, compressHighColor) : noSqueezeColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 2, rowN, str.tostring(compI * 100, "#") + "% (T" + str.tostring(tierI) + ")", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 3, rowN, str.tostring(barsInI), text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 4, rowN, sinceFiredI < 0 ? "-" : str.tostring(sinceFiredI), text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 5, rowN, leanI > 0 ? "▲" : leanI < 0 ? "▽" : "-", text_color = leanI > 0 ? bullColor : leanI < 0 ? bearColor : neutralTextColor, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 6, rowN, firedI ? (firedDirI > 0 ? "FIRED ▲" : "FIRED ▽") : "-", text_color = firedI ? (firedDirI > 0 ? bullColor : bearColor) : neutralTextColor, text_size = tsz, text_formatting = textFormat)
            conflictCellBg = (not agreesGroup and leanI != 0) ? conflictBgColor : color(na)
            table.cell(detailTable, 7, rowN, agreesGroup ? "Yes" : (leanI == 0 ? "-" : "No"), text_color = agreesGroup ? alignAgreeColor : (leanI == 0 ? alignNeutralColor : alignConflictColor), bgcolor = conflictCellBg, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 8, rowN, str.tostring(volRatioI, "#.##") + "x", text_color = detailTextColor, bgcolor = volBg, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 9, rowN, antiFakeoutText, text_color = antiFakeoutColor, bgcolor = antiFakeoutBg, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 10, rowN, htfAlignText, text_color = htfAlignColor, bgcolor = htfAlignBg, text_size = tsz, text_formatting = textFormat)
            table.cell(detailTable, 11, rowN, ltfText, text_color = ltfColor, bgcolor = ltfBg, text_size = tsz, text_formatting = textFormat)
    // ---- COMPOSITE SUMMARY (13 rows: v4's original 11 + NEW Direction Confidence Score +
    // NEW Live Signal Accuracy) - label spans columns 0-3, value spans columns 4-11 (was
    // 4-10 in v4's 11-column table, widened for the new 12th column). ----
    if showComposite
        biasText = bullLeanCount > bearLeanCount ? "Bullish" : bullLeanCount < bearLeanCount ? "Bearish" : "Neutral"
        biasColor = bullLeanCount > bearLeanCount ? bullColor : bullLeanCount < bearLeanCount ? bearColor : neutralTextColor
        lastFireText = anyFireGroupEvent ? (bullFireGroupEvent ? "Bullish (" + str.tostring(firedBullCount) + "/" + str.tostring(enabledCount) + ")" : "Bearish (" + str.tostring(firedBearCount) + "/" + str.tostring(enabledCount) + ")") : "No group fire this bar"
        highConfText = fireEventCount == 0 ? "No fires yet" : str.tostring(highConfidenceCount) + " / " + str.tostring(fireEventCount)
        tierLeanText = str.tostring(netTierWeightedLean) + (netTierWeightedLean > 0 ? " (Bullish)" : netTierWeightedLean < 0 ? " (Bearish)" : " (Neutral)")
        tierLeanColor = netTierWeightedLean > 0 ? bullColor : netTierWeightedLean < 0 ? bearColor : neutralTextColor
        readyScoreText = str.tostring(squeezeReadyScore, "#.#") + " / 100"
        readyScoreColor = squeezeReadyScore >= 70.0 ? alignAgreeColor : detailTextColor
        dirConfText = showDirConfidence ? str.tostring(directionConfidenceScore, "#.#") + " / 100" : "Off"
        dirConfColor = showDirConfidence and directionConfidenceScore >= 70.0 ? alignAgreeColor : detailTextColor
        htfConflictText = fireEventCount == 0 ? "No active fires" : str.tostring(htfConflictActiveCount) + " / " + str.tostring(fireEventCount) + " conflict with a higher TF"
        htfConflictColor = htfConflictActiveCount > 0 ? alignConflictColor : detailTextColor
        htfConflictBg = htfConflictActiveCount > 0 ? conflictBgColor : color(na)
        highestTfLabel = highestTfIdx >= 0 ? array.get(tfLabelArr, highestTfIdx) : "-"
        highestTfLean = highestTfIdx >= 0 ? array.get(leanArr, highestTfIdx) : 0
        highestTfTier = highestTfIdx >= 0 ? array.get(tierArr, highestTfIdx) : 0
        highestTfBiasText = highestTfIdx < 0 ? "No timeframes enabled" : highestTfLabel + ": " + (highestTfLean > 0 ? "Bullish" : highestTfLean < 0 ? "Bearish" : "Flat") + " (T" + str.tostring(highestTfTier) + ")"
        highestTfBiasColor = highestTfLean > 0 ? bullColor : highestTfLean < 0 ? bearColor : neutralTextColor
        cmfDivText = recentBullDiv and not recentBearDiv ? "Bullish (recent)" : recentBearDiv and not recentBullDiv ? "Bearish (recent)" : "None"
        cmfDivColor = recentBullDiv and not recentBearDiv ? bullColor : recentBearDiv and not recentBullDiv ? bearColor : neutralTextColor
        bullAccText = bullTrackedN == 0 ? "Building..." : str.tostring(bullAccPct, "#.#") + "% (n=" + str.tostring(bullTrackedN) + ")"
        bearAccText = bearTrackedN == 0 ? "Building..." : str.tostring(bearAccPct, "#.#") + "% (n=" + str.tostring(bearTrackedN) + ")"
        liveAccText = "Bull " + bullAccText + " / Bear " + bearAccText
        liveAccColor = (bullAccLow or bearAccLow) ? alignConflictColor : detailTextColor
        compRow0 = rowN + 1
        table.cell(detailTable, 0, compRow0, "Composite Summary", text_color = detailTextColor, text_size = tsz, text_formatting = text.format_bold)
        table.merge_cells(detailTable, 0, compRow0, 11, compRow0)
        table.cell(detailTable, 0, compRow0 + 1, "Squeezed", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 1, 3, compRow0 + 1)
        table.cell(detailTable, 4, compRow0 + 1, str.tostring(squeezedCount) + " / " + str.tostring(enabledCount), text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 1, 11, compRow0 + 1)
        table.cell(detailTable, 0, compRow0 + 2, "Net Bias", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 2, 3, compRow0 + 2)
        table.cell(detailTable, 4, compRow0 + 2, biasText, text_color = biasColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 2, 11, compRow0 + 2)
        table.cell(detailTable, 0, compRow0 + 3, "Tier-Weighted Net Lean", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 3, 3, compRow0 + 3)
        table.cell(detailTable, 4, compRow0 + 3, tierLeanText, text_color = tierLeanColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 3, 11, compRow0 + 3)
        table.cell(detailTable, 0, compRow0 + 4, "Squeeze Ready Score", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 4, 3, compRow0 + 4)
        table.cell(detailTable, 4, compRow0 + 4, readyScoreText, text_color = readyScoreColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 4, 11, compRow0 + 4)
        table.cell(detailTable, 0, compRow0 + 5, "Direction Confidence Score (NEW)", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 5, 3, compRow0 + 5)
        table.cell(detailTable, 4, compRow0 + 5, dirConfText, text_color = dirConfColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 5, 11, compRow0 + 5)
        table.cell(detailTable, 0, compRow0 + 6, "Last Group Fire", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 6, 3, compRow0 + 6)
        table.cell(detailTable, 4, compRow0 + 6, lastFireText, text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 6, 11, compRow0 + 6)
        table.cell(detailTable, 0, compRow0 + 7, "High-Confidence Fires", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 7, 3, compRow0 + 7)
        table.cell(detailTable, 4, compRow0 + 7, highConfText, text_color = highConfidenceCount > 0 ? alignAgreeColor : detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 7, 11, compRow0 + 7)
        table.cell(detailTable, 0, compRow0 + 8, "HTF Conflicts (of Active)", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 8, 3, compRow0 + 8)
        table.cell(detailTable, 4, compRow0 + 8, htfConflictText, text_color = htfConflictColor, bgcolor = htfConflictBg, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 8, 11, compRow0 + 8)
        table.cell(detailTable, 0, compRow0 + 9, "Highest-TF Bias", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 9, 3, compRow0 + 9)
        table.cell(detailTable, 4, compRow0 + 9, highestTfBiasText, text_color = highestTfBiasColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 9, 11, compRow0 + 9)
        table.cell(detailTable, 0, compRow0 + 10, "CMF Divergence", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 10, 3, compRow0 + 10)
        table.cell(detailTable, 4, compRow0 + 10, cmfDivText, text_color = cmfDivColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 10, 11, compRow0 + 10)
        table.cell(detailTable, 0, compRow0 + 11, "Live Signal Accuracy (NEW)", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, compRow0 + 11, 3, compRow0 + 11)
        table.cell(detailTable, 4, compRow0 + 11, liveAccText, text_color = liveAccColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, compRow0 + 11, 11, compRow0 + 11)
        if showEarningsCountdown
            earningsText = na(daysToProjectedEarnings) ? "No report history yet" : "~" + str.tostring(daysToProjectedEarnings) + "d (projected)"
            earningsColor = na(daysToProjectedEarnings) ? neutralTextColor : (daysToProjectedEarnings <= earningsWarnDays ? bearColor : detailTextColor)
            table.cell(detailTable, 0, compRow0 + 12, "Next Earnings", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
            table.merge_cells(detailTable, 0, compRow0 + 12, 3, compRow0 + 12)
            table.cell(detailTable, 4, compRow0 + 12, earningsText, text_color = earningsColor, text_size = tsz, text_formatting = textFormat)
            table.merge_cells(detailTable, 4, compRow0 + 12, 11, compRow0 + 12)
        else
            table.cell(detailTable, 0, compRow0 + 12, "Next Earnings", text_color = neutralTextColor, text_size = tsz, text_formatting = textFormat)
            table.merge_cells(detailTable, 0, compRow0 + 12, 3, compRow0 + 12)
            table.cell(detailTable, 4, compRow0 + 12, "off", text_color = neutralTextColor, text_size = tsz, text_formatting = textFormat)
            table.merge_cells(detailTable, 4, compRow0 + 12, 11, compRow0 + 12)
    // ---- EXIT ENGINE (NEW, 8 rows: header + 7 data rows) - chart-resolution trade
    // management, independent of the 15 entry-side timeframe slots. ----
    if showExitEngineRows
        exitRow0 = (showComposite ? rowN + 1 + 13 : rowN + 1)
        activeDirText = not hasActiveFireChart ? "No active fire on this chart" : (lastFiredDirChart > 0 ? "BULLISH" : "BEARISH") + " - fired " + str.tostring(barsSinceFiredChart) + " bars ago"
        activeDirColor = not hasActiveFireChart ? neutralTextColor : (lastFiredDirChart > 0 ? bullColor : bearColor)
        decelText = not hasActiveFireChart ? "N/A" : (decelSignal ? "DECELERATING (z=" + str.tostring(exitAccelZ, "#.##") + ")" : "Thrust OK (z=" + str.tostring(exitAccelZ, "#.##") + ")")
        decelColor = decelSignal ? alignConflictColor : detailTextColor
        climaxText = not hasActiveFireChart ? "N/A" : (climaxSignal ? "CLIMAX (vol z=" + str.tostring(exitVolZ, "#.#") + ")" : "Normal")
        climaxColor = climaxSignal ? alignConflictColor : detailTextColor
        recompText = not hasActiveFireChart ? "N/A" : (recompressDetected ? "RE-COMPRESSING" : "No re-compression")
        recompColor = recompressDetected ? alignConflictColor : detailTextColor
        chartHtfText = not hasActiveFireChart ? "N/A" : (not chartHasHigher ? "No higher TF configured" : chartHtfConflictNow ? "CONFLICTS w/ higher TF" : "Aligned / neutral")
        chartHtfColor = chartHtfConflictNow ? alignConflictColor : detailTextColor
        staleText = not hasActiveFireChart ? "N/A" : (staleFlagChart ? "STALE (" + str.tostring(barsSinceFiredChart) + " > " + str.tostring(typicalHoldBars) + " typical)" : str.tostring(barsSinceFiredChart) + " / " + str.tostring(typicalHoldBars) + " typical bars")
        staleColor = staleFlagChart ? alignConflictColor : detailTextColor
        exitScoreText = not hasActiveFireChart ? "N/A" : str.tostring(squeezeExitScore, "#.#") + " / 100 (" + exitState + ")"
        exitScoreColor = exitState == "EXIT" ? bearColor : exitState == "CAUTION" ? htfAlignConflictColor : detailTextColor
        table.cell(detailTable, 0, exitRow0, "Exit Engine (Chart Timeframe)", text_color = detailTextColor, text_size = tsz, text_formatting = text.format_bold)
        table.merge_cells(detailTable, 0, exitRow0, 11, exitRow0)
        table.cell(detailTable, 0, exitRow0 + 1, "Active Fire", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 1, 3, exitRow0 + 1)
        table.cell(detailTable, 4, exitRow0 + 1, activeDirText, text_color = activeDirColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 1, 11, exitRow0 + 1)
        table.cell(detailTable, 0, exitRow0 + 2, "Momentum Deceleration", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 2, 3, exitRow0 + 2)
        table.cell(detailTable, 4, exitRow0 + 2, decelText, text_color = decelColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 2, 11, exitRow0 + 2)
        table.cell(detailTable, 0, exitRow0 + 3, "Volatility/ATR Climax", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 3, 3, exitRow0 + 3)
        table.cell(detailTable, 4, exitRow0 + 3, climaxText, text_color = climaxColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 3, 11, exitRow0 + 3)
        table.cell(detailTable, 0, exitRow0 + 4, "Post-Fire Re-Compression", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 4, 3, exitRow0 + 4)
        table.cell(detailTable, 4, exitRow0 + 4, recompText, text_color = recompColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 4, 11, exitRow0 + 4)
        table.cell(detailTable, 0, exitRow0 + 5, "HTF Alignment (Chart)", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 5, 3, exitRow0 + 5)
        table.cell(detailTable, 4, exitRow0 + 5, chartHtfText, text_color = chartHtfColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 5, 11, exitRow0 + 5)
        table.cell(detailTable, 0, exitRow0 + 6, "Staleness", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 6, 3, exitRow0 + 6)
        table.cell(detailTable, 4, exitRow0 + 6, staleText, text_color = staleColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 6, 11, exitRow0 + 6)
        table.cell(detailTable, 0, exitRow0 + 7, "Squeeze Exit Score", text_color = detailTextColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 0, exitRow0 + 7, 3, exitRow0 + 7)
        table.cell(detailTable, 4, exitRow0 + 7, exitScoreText, text_color = exitScoreColor, text_size = tsz, text_formatting = textFormat)
        table.merge_cells(detailTable, 4, exitRow0 + 7, 11, exitRow0 + 7)
// =====================================================================================
// EXIT ENGINE - ON-CHART MARKERS (NEW). One plotshape()/label.new() call per literal size
// option where relevant - Pine's size= argument requires a true compile-time const, the
// same proven workaround used throughout this project (bug class #6, project memory).
// =====================================================================================
if showExitMarker and exitStateJustEnteredCaution
    label.new(bar_index, lastFiredDirChart > 0 ? high : low, "SQZ CAUTION", style = lastFiredDirChart > 0 ? label.style_label_down : label.style_label_up, color = color.new(htfAlignConflictColor, 0), textcolor = color.white, size = size.small)
if showExitMarker and exitStateJustEnteredExit
    label.new(bar_index, lastFiredDirChart > 0 ? high : low, "SQZ EXIT", style = lastFiredDirChart > 0 ? label.style_label_down : label.style_label_up, color = color.new(bearColor, 0), textcolor = color.white, size = size.normal)
if showExitMarker and recompressJustDetected
    label.new(bar_index, hl2, "RE-COMPRESS", style = label.style_label_left, color = color.new(color.gray, 20), textcolor = color.white, size = size.tiny)
// =====================================================================================
// ALERTS - Combo Alert Bundling (NEW/expanded in v1.0). v4 shipped with exactly 1
// alertcondition (the unsplit group-fire). This is the full MYND-standard set: individual
// entry alerts, individual exit alerts, and combo bundles for both sides.
// =====================================================================================
alertcondition(exitStateJustEnteredCaution, title = "Squeeze Exit: CAUTION", message = "MYND USqCE: Exit Engine entered CAUTION on {{ticker}} ({{interval}}) - momentum/climax/re-compression/HTF/staleness signals building")
alertcondition(exitStateJustEnteredExit, title = "Squeeze Exit: EXIT", message = "MYND USqCE: Exit Engine reached EXIT on {{ticker}} ({{interval}}) - multiple exhaustion signals agreeing, consider closing")
alertcondition(recompressJustDetected, title = "Post-Fire Re-Compression Detected", message = "MYND USqCE: Fresh re-compression detected on {{ticker}} ({{interval}}) after the last fire - the move may be stalling")
alertcondition(accuracyLowAlert, title = "Live Accuracy Warning", message = "MYND USqCE: Live Signal Accuracy (Bull or Bear) has dropped below your warning level on {{ticker}} ({{interval}})")
allEntries = bullGroupFireFinal or bearGroupFireFinal
allExits = exitStateJustEnteredCaution or exitStateJustEnteredExit or recompressJustDetected
allSignals = allEntries or allExits
alertcondition(allEntries, title = "ALL Entries (combo)", message = "MYND USqCE: Entry signal (Bullish or Bearish group fire) on {{ticker}} ({{interval}})")
alertcondition(allExits, title = "ALL Exits (combo)", message = "MYND USqCE: Exit-side signal (Caution, Exit, or Re-Compression) on {{ticker}} ({{interval}})")
alertcondition(allSignals, title = "ALL Signals (combo)", message = "MYND USqCE: Signal on {{ticker}} ({{interval}}) - check chart/dashboard")
// =====================================================================================
// END OF SCRIPT
// =====================================================================================
````
