<!-- tradingview-pine-id: PUB;d67b7b9461af4c6f88729358efe198ad -->
<!-- tradingviewscripts-format: 1 -->
# LASER Trading Cockpit v7.0

Source: https://www.tradingview.com/script/ddZWEGu4-LASER-Trading-Cockpit-v7-0/

## Description

LASER Trading Cockpit is a real-time market-state and trade-quality dashboard designed primarily for intraday futures trading. It combines auction structure, momentum, volume, RSI behavior, volatility compression, key levels, and risk/reward into a single compact decision-support system.

The goal of LASER is not to predict the next candle. It is designed to answer a more practical question:

“Is there currently enough structure, location, momentum confirmation, and available room to justify a trade?”

LASER organizes setups into two primary thesis families:

C — Continuation: A pullback or reaction within an existing directional auction where price shows evidence of resuming the prevailing move.

MR — Mean Reversion / Reversal: A stricter setup requiring a meaningful excursion or extreme, evidence of trend deterioration, a reaction at the extreme, momentum rotation, and a change of state. MR is intended to identify situations where the prior directional auction may be failing rather than simply fading price because it looks extended.

The cockpit continuously evaluates both long and short possibilities and assigns each qualifying thesis a score. Depending on the selected preset, the minimum qualification score is 60 for Aggressive, 70 for Neutral, or 80 for Conservative. A score alone does not generate a trade signal. Risk, stop distance, available room, direction settings, cooldown, and other execution gates must also pass before a FIRE can occur.

The HUD includes:

Regime: STRONG UP, TREND UP, STRONG DOWN, TREND DOWN, BALANCE, or TRANSITION, along with a balance score measuring rotational/choppy market behavior.
Auction: Displays whether price is inside value, testing beyond VAH/VAL, being accepted outside value, or experiencing a failed auction.
Long / Short Scores: Displays the strongest current Continuation or Mean-Reversion thesis for each direction.
RSI: Shows current RSI along with RSI rate of change and acceleration rather than relying only on traditional overbought/oversold readings.
RSI Divergence: Tracks recent bullish and bearish regular divergence. DIV+ identifies stronger divergence where price made a materially deeper extreme without equivalent RSI confirmation. The HUD also shows divergence age, price overshoot in ATR, and whether the RSI pivot occurred within a preferred contextual zone.
Squeeze / Energy: Internally evaluates Squeeze Momentum behavior and classifies states such as COMPRESSED, PRESSURIZED, EARLY EXPANSION, BULL/BEAR EXPAND, RE-EXPAND, and DECEL.
Evidence: Displays directional confluence using compact modifiers including DIV, DIV+, EXH, FA, SW, STR, ABS, BOA, SQZ, and HV.
Volume: Classifies supported, high, and extreme relative volume along with directional volume and possible absorption.
Risk / Room: Calculates the proposed stop distance in points and compares it with the distance to the nearest known opposing structure or key level. For example, L 18.0p / 2.0R means approximately 18 points of defined risk with two risk units of open space available before the nearest recognized resistance.
Trade State: Tracks the most recent LASER FIRE, entry, stop, TP1, and optional TP2.

Evidence abbreviations

DIV = RSI Divergence
DIV+ = Strong RSI Divergence
EXH = Exhaustion
FA = Failed Auction
SW = Liquidity Sweep
STR = Structure Shift / Retest
ABS = Absorption
BOA = Breakout Acceptance
SQZ = Squeeze / Volatility Expansion Evidence
HV = High Relative Volume

LASER also incorporates developing Volume Profile information including VAH, VAL, and POC, along with configurable previous-session, previous-week, Globex, Asia, London, and NYSE reference levels. These levels can be used internally by the decision engine without necessarily being displayed on the chart.

One important feature is the distinction between READY and FIRE. READY means a directional thesis has reached the required score. FIRE means the setup has also passed the final execution requirements such as acceptable stop size, minimum available room, cooldown, and direction filters.

Realtime behavior / repainting

LASER includes an optional Require Closed Candle setting. When enabled, FIRE signals require the candle to close before confirmation. When disabled, signals may appear, disappear, and reappear during the formation of the live candle as price, RSI, volume, structure, and momentum change. This is intentional realtime behavior and allows traders to see when a setup is approaching qualification.

LASER is intended as a decision-support and market-structure tool, not an automated trading system or guarantee of future performance. Users should apply their own risk management, execution judgment, and testing before using any signal in live trading.

The indicator was developed primarily around intraday futures trading, with particular emphasis on auction behavior, value migration, pullback continuation, exhaustion, failed auctions, momentum rotation, and defined-risk execution.

---

## Source Code

````pine
//@version=6
indicator(
     title = "LASER Trading Cockpit v7.0",
     shorttitle = "LASER7",
     overlay = true,
     max_bars_back = 5000,
     max_labels_count = 250,
     max_lines_count = 500)

//=============================================================================
// LASER v7.0 — TRADING COCKPIT
//
// L = Location
// A = Alignment
// S = Scenario / Thesis
// E = Execution / Change of State
// R = Reaction / Reward / Risk
//
// Designed for live decision support rather than historical research.
// Primary theses:
//   C  = Continuation pullback.
//   MR = Strict mean reversion / reversal after a genuine character change.
//
// Sweep, exhaustion, absorption, structure retest, RSI divergence, failed
// auction, accepted breakout and squeeze release are evidence/modifiers.
//
// RSI divergence findings incorporated into live logic:
// - Divergence is confirmation, not a standalone entry.
// - MR remains strict: genuine excursion -> reaction -> momentum rotation ->
//   change of state. Divergence cannot replace the excursion or reaction.
// - Regular pivot divergence remains valid context for up to 12 bars by default.
// - A meaningful price overshoot versus the prior pivot (default >= 0.30 ATR)
//   receives more weight than raw RSI pivot-gap size.
// - Divergence combined with exhaustion or failed auction receives a modest
//   synergy bonus after the setup is otherwise eligible.
// - No long/short asymmetry is hard-coded from the small research subsamples.
//
// Cockpit simplifications:
// - Historical research counters and research HUD pages removed.
// - Native 5/9 EMA crossover module removed entirely.
// - Compact live HUD only.
// - Signal tabs default to Latest Only; each tab carries a detailed tooltip.
// - VP labels are independently toggleable and default OFF.
// - Session key-level labels remain independently toggleable.
// - Current-only key levels stay non-progressive and can anchor to visible chart.
// - All normal line-width defaults remain 1.
// - ORB remains completely absent.
//=============================================================================

//=============================================================================
// 01 — MASTER / COCKPIT
//=============================================================================
string G_MASTER = "01 — LASER Trading Cockpit"
string preset = input.string("Neutral", "Qualification Preset", options = ["Aggressive", "Neutral", "Conservative"], group = G_MASTER)
string tradeDirection = input.string("Both", "Direction", options = ["Both", "Long Only", "Short Only"], group = G_MASTER)
bool requireClosedBar = input.bool(true, "Require Closed Candle", group = G_MASTER)
int signalCooldown = input.int(3, "Signal Cooldown Bars", minval = 0, group = G_MASTER)
bool showHUD = input.bool(true, "Show Cockpit HUD", group = G_MASTER)
string hudSizeInput = input.string("Small", "HUD Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_MASTER)
hudTextSize = switch hudSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small
string signalDisplayMode = input.string("Latest Only", "Trade Signal Tabs", options = ["Off", "Latest Only", "All Fires"], group = G_MASTER, tooltip = "Latest Only keeps the chart clean. All Fires leaves historical signal/outcome tabs on the chart. Every signal tab has a detailed tooltip.")
bool showOutcomes = input.bool(true, "Show Latest TP / SL Outcome", group = G_MASTER)
bool showActiveLevels = input.bool(true, "Show Active Entry / SL / TP", group = G_MASTER)
bool trackTP2 = input.bool(false, "Track TP2", group = G_MASTER)
string signalTabSizeInput = input.string("Auto", "Trade Tab Size", options = ["Auto", "Tiny", "Small", "Normal", "Large"], group = G_MASTER)
string signalTabTextMode = input.string("With Modifiers", "Trade Tab Text", options = ["Short", "With Modifiers"], group = G_MASTER)

//=============================================================================
// 02 — PRIMARY THESES / EVIDENCE
//=============================================================================
string G_THESIS = "02 — Primary Theses / Evidence"
bool enableContinuation = input.bool(true, "C — Continuation Pullback", group = G_THESIS)
bool enableMeanReversion = input.bool(true, "MR — Mean Reversion / Reversal", group = G_THESIS)
bool useSweepEvidence = input.bool(true, "Use Sweep / Reclaim Evidence", group = G_THESIS)
bool useExhaustionEvidence = input.bool(true, "Use Exhaustion Evidence", group = G_THESIS)
bool useAbsorptionEvidence = input.bool(true, "Use Absorption Evidence", group = G_THESIS)
bool useStructureRetestEvidence = input.bool(true, "Use Structure-Break Retest Evidence", group = G_THESIS)
bool useRsiDivEvidence = input.bool(true, "Use RSI Divergence Evidence", group = G_THESIS)
bool useFailedAuctionEvidence = input.bool(true, "Use Failed-Auction Evidence", group = G_THESIS)
bool useBreakoutAcceptanceEvidence = input.bool(true, "Use Accepted-Breakout Continuation Evidence", group = G_THESIS)

//=============================================================================
// 03 — EMA / VWAP VISUAL MODULE
//=============================================================================
string G_EMA1 = "03A — 1-Minute EMA Profile"
string G_EMAMTF = "03B — Higher-TF EMA Source"
string G_EMA5 = "03C — Native 5-Minute Profile"
string G_EMAOTHER = "03D — Other Native Timeframes"
string G_VWAP = "03E — VWAP"
string G_VWAPSD = "03F — VWAP Standard Deviations"
string G_STYLE = "03G — EMA / VWAP Style"

bool enable1m = input.bool(true, "Enable 1-minute profile", group = G_EMA1)
bool show1mFast = input.bool(true, "Show Fast EMA", inline = "1mf", group = G_EMA1)
int length1mFast = input.int(5, "", minval = 1, inline = "1mf", group = G_EMA1)
bool show1mSlow = input.bool(true, "Show Slow EMA", inline = "1ms", group = G_EMA1)
int length1mSlow = input.int(13, "", minval = 1, inline = "1ms", group = G_EMA1)
bool show1mTrend = input.bool(true, "Show Trend EMA", inline = "1mt", group = G_EMA1)
int length1mTrend = input.int(50, "", minval = 1, inline = "1mt", group = G_EMA1)
bool show1mRegime = input.bool(true, "Show Regime EMA", inline = "1mr", group = G_EMA1)
int length1mRegime = input.int(200, "", minval = 1, inline = "1mr", group = G_EMA1)

bool use1mEmasOn5m = input.bool(true, "Use 1-minute EMAs on 5-minute chart", group = G_EMAMTF)
bool use1mEmasOnOther = input.bool(true, "Use 1-minute EMAs on other higher timeframes", group = G_EMAMTF)
bool show2m200On5m = input.bool(false, "Show 2-minute 200 EMA on 5-minute chart", group = G_EMAMTF)

bool enable5m = input.bool(true, "Enable 5-minute profile", group = G_EMA5)
bool show5mFast = input.bool(true, "Show Fast EMA", inline = "5mf", group = G_EMA5)
int length5mFast = input.int(20, "", minval = 1, inline = "5mf", group = G_EMA5)
bool show5mTrend = input.bool(true, "Show Trend EMA", inline = "5mt", group = G_EMA5)
int length5mTrend = input.int(50, "", minval = 1, inline = "5mt", group = G_EMA5)
bool show5mRegime = input.bool(true, "Show Regime EMA", inline = "5mr", group = G_EMA5)
int length5mRegime = input.int(200, "", minval = 1, inline = "5mr", group = G_EMA5)

bool enableOther = input.bool(false, "Enable on other timeframes", group = G_EMAOTHER)
bool showOtherFast = input.bool(true, "Show Fast EMA", inline = "of", group = G_EMAOTHER)
int lengthOtherFast = input.int(20, "", minval = 1, inline = "of", group = G_EMAOTHER)
bool showOtherTrend = input.bool(true, "Show Trend EMA", inline = "ot", group = G_EMAOTHER)
int lengthOtherTrend = input.int(50, "", minval = 1, inline = "ot", group = G_EMAOTHER)
bool showOtherRegime = input.bool(true, "Show Regime EMA", inline = "or", group = G_EMAOTHER)
int lengthOtherRegime = input.int(200, "", minval = 1, inline = "or", group = G_EMAOTHER)

bool showSessionVwap1m = input.bool(true, "Show futures-session VWAP on 1-minute", group = G_VWAP)
bool showSessionVwap5m = input.bool(true, "Show futures-session VWAP on 5-minute", group = G_VWAP)
bool showSessionVwapOther = input.bool(false, "Show futures-session VWAP on other timeframes", group = G_VWAP)
bool showRthVwap = input.bool(false, "Show optional NYSE RTH VWAP", group = G_VWAP)
bool showRthVwap1m = input.bool(true, "Show RTH VWAP on 1-minute", group = G_VWAP)
bool showRthVwap5m = input.bool(true, "Show RTH VWAP on 5-minute", group = G_VWAP)
string rthVwapSession = input.session("0830-1500", "NYSE RTH Session", group = G_VWAP)
string sessionTimezone = input.string("America/Chicago", "Session Time Zone", group = G_VWAP)

bool showVwapSdBands = input.bool(false, "Show futures VWAP standard deviation bands", group = G_VWAPSD)
bool showVwapSdBand1 = input.bool(true, "Show Band 1", inline = "sd1", group = G_VWAPSD)
float vwapSdMultiplier1 = input.float(1.0, "×", minval = 0.1, step = 0.25, inline = "sd1", group = G_VWAPSD)
bool showVwapSdBand2 = input.bool(true, "Show Band 2", inline = "sd2", group = G_VWAPSD)
float vwapSdMultiplier2 = input.float(2.0, "×", minval = 0.1, step = 0.25, inline = "sd2", group = G_VWAPSD)
bool showVwapSdBand3 = input.bool(false, "Show Band 3", inline = "sd3", group = G_VWAPSD)
float vwapSdMultiplier3 = input.float(3.0, "×", minval = 0.1, step = 0.25, inline = "sd3", group = G_VWAPSD)

color fast1mColor = input.color(color.orange, "1m Fast EMA", group = G_STYLE)
color slow1mColor = input.color(color.aqua, "1m Slow EMA", group = G_STYLE)
color fast5mColor = input.color(color.lime, "5m Fast EMA", group = G_STYLE)
color trendColor = input.color(color.purple, "Trend EMA", group = G_STYLE)
color regimeColor = input.color(color.white, "Regime EMA", group = G_STYLE)
color ema2m200Color = input.color(color.fuchsia, "2m 200 EMA", group = G_STYLE)
color sessionVwapColor = input.color(color.blue, "Futures Session VWAP", group = G_STYLE)
color rthVwapColor = input.color(color.yellow, "NYSE RTH VWAP", group = G_STYLE)
color vwapSdColor1 = input.color(color.gray, "VWAP SD 1", group = G_STYLE)
color vwapSdColor2 = input.color(color.silver, "VWAP SD 2", group = G_STYLE)
color vwapSdColor3 = input.color(color.white, "VWAP SD 3", group = G_STYLE)
int emaLineWidth = input.int(1, "EMA line width", minval = 1, maxval = 4, group = G_STYLE)
int vwapLineWidth = input.int(1, "VWAP line width", minval = 1, maxval = 4, group = G_STYLE)
int vwapSdLineWidth = input.int(1, "VWAP SD line width", minval = 1, maxval = 4, group = G_STYLE)

//=============================================================================
// 04 — ACTIVE VOLUME PROFILE
//=============================================================================
string G_VP = "04 — Active Volume Profile"
string vpMode = input.string("Globex Developing", "VP Source — what you see = what LASER reads", options = ["Globex Developing", "NYSE RTH Snapshot", "Visible Range", "Fixed Lookback"], group = G_VP)
string vpLowerTF = input.timeframe("1", "Globex Source TF", group = G_VP)
float vpPrimaryPoints = input.float(2.0, "Mechanical Globex Bin — points", minval = 0.25, step = 0.25, group = G_VP)
float vpValueAreaPct = input.float(70.0, "Value Area %", minval = 50, maxval = 95, step = 1, group = G_VP)
int vpRows = input.int(120, "Right-Side Profile Rows", minval = 20, maxval = 300, group = G_VP)
int vpThickness = input.int(3, "Right-Side Row Thickness", minval = 1, maxval = 10, group = G_VP)
int vpWidth = input.int(20, "Right-Side Profile Width", minval = 1, maxval = 50, group = G_VP)
int vpRightOffset = input.int(40, "Right-Side Offset", minval = 0, maxval = 400, group = G_VP)
int vpFixedLookback = input.int(300, "Fixed Lookback Bars", minval = 10, maxval = 3000, group = G_VP)
string vpRthSession = input.session("0830-1500", "NYSE RTH Profile Session", group = G_VP)
bool showRightProfile = input.bool(true, "Show Right-Side Profile", group = G_VP)
bool showActiveVpLines = input.bool(true, "Show Active VAH / POC / VAL", group = G_VP)
bool showVpLevelLabels = input.bool(false, "Label VAH / POC / VAL", group = G_VP, tooltip = "Off by default for the trading cockpit. The lines remain visible without chart text.")
int vpLevelLineWidth = input.int(1, "VAH / POC / VAL Line Width", minval = 1, maxval = 4, group = G_VP)
color vpOutsideColor = input.color(color.new(color.gray, 55), "Outside Value", group = G_VP)
color vpValueColor = input.color(color.new(color.blue, 10), "Value Area", group = G_VP)
color vpPocColor = input.color(color.yellow, "POC", group = G_VP)
color vpLineColor = input.color(color.orange, "VAH / VAL Lines", group = G_VP)

//=============================================================================
// 05 — SESSION KEY LEVELS
//=============================================================================
string G_SESS = "05 — Previous Session High / Low"
bool usePrevAsiaHL = input.bool(true, "Use Previous Asia H/L", group = G_SESS)
bool usePrevLondonHL = input.bool(true, "Use Previous London H/L", group = G_SESS)
bool usePrevNyseHL = input.bool(true, "Use Previous NYSE H/L", group = G_SESS)
bool usePreviousGlobexHL = input.bool(true, "Use Previous Globex H/L", group = G_SESS)
bool usePreviousWeek = input.bool(true, "Use Previous Week H/L", group = G_SESS)
string asiaSession = input.session("1900-0200", "Asia Session — CT", group = G_SESS, tooltip = "Editable. Default 7:00 PM–2:00 AM Central.")
string londonSession = input.session("0200-0500", "London Session — CT", group = G_SESS, tooltip = "Editable. Default 2:00–5:00 AM Central.")
string nyseSession = input.session("0830-1500", "NYSE Session — CT", group = G_SESS)
bool showPrevAsiaHL = input.bool(false, "Show Previous Asia H/L", group = G_SESS)
bool showPrevLondonHL = input.bool(false, "Show Previous London H/L", group = G_SESS)
bool showPrevNyseHL = input.bool(true, "Show Previous NYSE H/L", group = G_SESS)
bool showPreviousGlobexLines = input.bool(false, "Show Previous Globex H/L", group = G_SESS)
bool showPreviousWeekLines = input.bool(false, "Show Previous Week H/L", group = G_SESS)

bool showSessionLevelLabels = input.bool(true, "Show Session / Week Level Labels", group = G_SESS)
bool showKeyLevelPrices = input.bool(false, "Show Prices in Session Labels", group = G_SESS)
int keyLevelLineWidth = input.int(1, "Key Level Line Width", minval = 1, maxval = 4, group = G_SESS)
string keyLevelAnchorMode = input.string("Visible Chart", "Key Level Horizontal Anchor", options = ["Visible Chart", "Fixed Bars"], group = G_SESS, tooltip = "Visible Chart pins current key levels to the visible chart edges and updates when you zoom/pan. Fixed Bars uses the bar-length/offset settings below.")
int keyLevelBarsBack = input.int(150, "Fixed Mode — Line Length Bars", minval = 10, maxval = 1000, group = G_SESS)
int keyLabelOffset = input.int(8, "Fixed Mode — Label Offset Bars", minval = 1, maxval = 50, group = G_SESS)
int keyLabelGapBars = input.int(2, "Gap Before Label — Bars", minval = 0, maxval = 10, group = G_SESS)
string keyLabelSizeInput = input.string("Small", "Key Level Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_SESS)
keyLabelTextSize = switch keyLabelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

color asiaColor = input.color(color.new(color.aqua, 45), "Asia H/L Color", group = G_SESS)
color londonColor = input.color(color.new(color.fuchsia, 45), "London H/L Color", group = G_SESS)
color nyseColor = input.color(color.new(color.yellow, 35), "NYSE H/L Color", group = G_SESS)
color globexColor = input.color(color.new(color.gray, 45), "Globex H/L Color", group = G_SESS)
color weekColor = input.color(color.new(color.white, 45), "Week H/L Color", group = G_SESS)

//=============================================================================
// 06 — INTERNAL RSI
//=============================================================================
string G_RSI = "06 — Internal RSI — mirrors separate RSI pane"
int rsiLength = input.int(14, "RSI Length", minval = 2, group = G_RSI)
int rsiComparisonBars = input.int(4, "RSI Slope / ROC Window", minval = 2, maxval = 20, group = G_RSI)
float sharpRsiROC = input.float(4.0, "RSI Shock Threshold", minval = 0.5, step = 0.5, group = G_RSI)
bool useRsiDivergence = input.bool(true, "Use RSI divergence as confluence", group = G_RSI)
int rsiDivLeft = input.int(5, "RSI Divergence Pivot Left", minval = 1, maxval = 20, group = G_RSI)
int rsiDivRight = input.int(5, "RSI Divergence Pivot Right", minval = 1, maxval = 20, group = G_RSI)

//=============================================================================
// 06B — RSI DIVERGENCE COCKPIT LOGIC
//=============================================================================
string G_RSILAB = "06B — RSI Divergence Confirmation"
int rsiDivMemoryBars = input.int(12, "Divergence Context Memory — Bars", minval = 1, maxval = 30, group = G_RSILAB, tooltip = "Research showed useful divergence context persisted across the tested 0-12 bar window; this is context memory, not a trigger timer.")
float divStrongPriceATR = input.float(0.30, "Strong DIV — Minimum Price Overshoot (ATR)", minval = 0.0, step = 0.05, group = G_RSILAB, tooltip = "A materially deeper price extreme without RSI confirmation was more informative than raw RSI pivot-gap size in the research sample.")
float bullDivZone = input.float(40.0, "Bull DIV Context Zone ≤", minval = 0, maxval = 50, step = 1, group = G_RSILAB)
float bearDivZone = input.float(60.0, "Bear DIV Context Zone ≥", minval = 50, maxval = 100, step = 1, group = G_RSILAB)
bool showRsiDivMarkers = input.bool(false, "Show RSI Divergence Confirmation Markers", group = G_RSILAB, tooltip = "Markers appear on the confirmation bar, never back-painted onto the earlier pivot.")

//=============================================================================
// 07 — INTERNAL SQZMOM — corrected authoritative baseline
//=============================================================================
string G_SQZ = "07 — Internal Squeeze Momentum — mirrors separate pane"
int bbLength = input.int(20, "BB Length", minval = 1, group = G_SQZ)
float bbMult = input.float(2.0, "BB Mult", minval = 0.1, step = 0.1, group = G_SQZ)
int kcLength = input.int(20, "KC Length", minval = 1, group = G_SQZ)
float kcMult = input.float(1.5, "KC Mult", minval = 0.1, step = 0.1, group = G_SQZ)
bool sqzUseTrueRange = input.bool(true, "Use True Range", group = G_SQZ)
int pressureSqueezeBars = input.int(6, "Long Compression Threshold", minval = 2, group = G_SQZ)
int recentReleaseBars = input.int(6, "Recent Release Memory", minval = 1, maxval = 30, group = G_SQZ)
int matureMomentumBars = input.int(6, "Mature Momentum Cycle Bars", minval = 2, maxval = 30, group = G_SQZ)
bool showSqueezeFires = input.bool(true, "Mark True Squeeze Fires on Price Chart", group = G_SQZ)
string squeezeFireSizeInput = input.string("Micro", "Squeeze Fire Marker Size", options = ["Micro", "Tiny", "Small", "Normal"], group = G_SQZ)
squeezeFireTextSize = switch squeezeFireSizeInput
    "Micro"  => size.tiny
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.tiny
string squeezeFireSymbol = squeezeFireSizeInput == "Micro" ? "·" : "•"

//=============================================================================
// 08 — VOLUME / ABSORPTION CANDLES
//=============================================================================
string G_VOL = "08 — Volume / Absorption Candles"
bool showVolumeMoves = input.bool(true, "Show Volume-Supported Moves", group = G_VOL)
bool showAbsorption = input.bool(true, "Show Possible Absorption", group = G_VOL)
bool volumeRequireClose = input.bool(false, "Require Completed Candle", group = G_VOL)
int volumeAvgLength = input.int(20, "Volume Average Length", minval = 1, group = G_VOL)
int volumeATRLength = input.int(14, "Volume Candle ATR Length", minval = 1, group = G_VOL)
float moveVolumeMult = input.float(1.65, "Relative Volume ×", minval = 1, step = 0.05, group = G_VOL)
float moveRangeATR = input.float(0.90, "Minimum Range — ATR", minval = 0, step = 0.05, group = G_VOL)
float moveBodyPct = input.float(60, "Minimum Body %", minval = 0, maxval = 100, group = G_VOL)
float moveClosePct = input.float(20, "Close Within % of Extreme", minval = 0, maxval = 50, group = G_VOL)
float absVolumeMult = input.float(1.50, "Absorption Relative Volume ×", minval = 1, step = 0.05, group = G_VOL)
float absMaxBody = input.float(40, "Absorption Maximum Body %", minval = 0, maxval = 100, group = G_VOL)
float absMinWick = input.float(35, "Minimum Rejection Wick %", minval = 0, maxval = 100, group = G_VOL)
float absWickDominance = input.float(1.50, "Rejection Wick Dominance", minval = 1, step = 0.10, group = G_VOL)
bool absRequireMidpoint = input.bool(true, "Require Close Beyond Midpoint", group = G_VOL)
color bullMoveColor = input.color(color.lime, "Bullish Move", group = G_VOL)
color bearMoveColor = input.color(color.red, "Bearish Move", group = G_VOL)
color bullAbsorbColor = input.color(color.lime, "Selling Absorbed — Hollow", group = G_VOL)
color bearAbsorbColor = input.color(color.red, "Buying Absorbed — Hollow", group = G_VOL)

//=============================================================================
// 09 — STRUCTURE / BALANCE / AUCTION
//=============================================================================
string G_STRUCT = "09 — Structure / Balance / Auction"
int structureLookback = input.int(12, "Major Structure Lookback", minval = 3, group = G_STRUCT)
int microLookback = input.int(4, "Micro Structure Lookback", minval = 2, group = G_STRUCT)
int structureBreakMemory = input.int(8, "Structure-Break Retest Memory", minval = 2, maxval = 20, group = G_STRUCT)
int matureImpulseLookback = input.int(20, "Mature Impulse Lookback", minval = 5, group = G_STRUCT)
float matureImpulseATR = input.float(2.5, "Mature Impulse — ATR", minval = 0.5, step = 0.25, group = G_STRUCT)
int efficiencyLookback = input.int(12, "Directional Efficiency Lookback", minval = 5, maxval = 30, group = G_STRUCT)
int overlapLookback = input.int(8, "Candle Overlap Lookback", minval = 3, maxval = 20, group = G_STRUCT)
int meanCrossLookback = input.int(12, "Mean Crossing Lookback", minval = 5, maxval = 30, group = G_STRUCT)
float hardBalanceThreshold = input.float(65, "Hard Balance Score", minval = 40, maxval = 95, step = 5, group = G_STRUCT)
float softBalanceThreshold = input.float(50, "Soft Balance Score", minval = 25, maxval = 90, step = 5, group = G_STRUCT)
int acceptanceLookback = input.int(4, "Acceptance Lookback Bars", minval = 2, maxval = 10, group = G_STRUCT)
int acceptanceCloses = input.int(2, "Closes Required Beyond VA Boundary", minval = 1, maxval = 5, group = G_STRUCT)
int pressureTestLookback = input.int(10, "Repeated Test Lookback", minval = 4, maxval = 30, group = G_STRUCT)
int minimumBoundaryTests = input.int(3, "Minimum Boundary Tests", minval = 2, maxval = 8, group = G_STRUCT)
float boundaryToleranceATR = input.float(0.20, "Boundary Test Tolerance — ATR", minval = 0.05, maxval = 1, step = 0.05, group = G_STRUCT)
int failedAuctionMemory = input.int(5, "Failed Auction Memory Bars", minval = 1, maxval = 15, group = G_STRUCT)

//=============================================================================
// 10 — LOCATION / RISK
//=============================================================================
string G_LOC = "10 — Location / Risk"
int atrLength = input.int(14, "ATR Length", minval = 1, group = G_LOC)
float locationATR = input.float(0.25, "Location Proximity — ATR", minval = 0.05, step = 0.05, group = G_LOC)
float stopBufferATR = input.float(0.10, "Stop Buffer — ATR", minval = 0, step = 0.05, group = G_LOC)
float maximumStop = input.float(40.0, "Maximum Stop — Points", minval = 1, step = 5, group = G_LOC)
float tp1R = input.float(1.0, "TP1 — R", minval = 0.25, step = 0.25, group = G_LOC)
float tp2R = input.float(2.0, "TP2 — R", minval = 0.5, step = 0.25, group = G_LOC)
float minimumRoomR = input.float(1.0, "Minimum Open Space — R", minval = 0.25, step = 0.25, group = G_LOC)

//=============================================================================
// 11 — HELPERS
//=============================================================================
f_near(float level, float atrValue, float proximity) => not na(level) and math.abs(close - level) <= atrValue * proximity
f_longRisk(float stopPrice) => na(stopPrice) ? na : close - stopPrice
f_shortRisk(float stopPrice) => na(stopPrice) ? na : stopPrice - close
f_riskPass(float risk) => not na(risk) and risk > syminfo.mintick and risk <= maximumStop
f_countTrue(bool condition, int length) =>
    int result = 0
    for i = 0 to length - 1
        if condition[i]
            result += 1
    result

f_above(float candidate, float existing) =>
    float result = existing
    if not na(candidate) and candidate > close
        if na(result) or candidate < result
            result := candidate
    result

f_below(float candidate, float existing) =>
    float result = existing
    if not na(candidate) and candidate < close
        if na(result) or candidate > result
            result := candidate
    result

//=============================================================================
// 12 — TIMEFRAME / EMA CALCULATIONS
//=============================================================================
bool is1m = timeframe.isminutes and timeframe.multiplier == 1
bool is5m = timeframe.isminutes and timeframe.multiplier == 5
bool isOther = not is1m and not is5m
bool profileEnabled = is1m ? enable1m : is5m ? enable5m : enableOther

float ema1mFastNative = ta.ema(close, length1mFast)
float ema1mSlowNative = ta.ema(close, length1mSlow)
float ema1mTrendNative = ta.ema(close, length1mTrend)
float ema1mRegimeNative = ta.ema(close, length1mRegime)

[ema1mFastHtf, ema1mSlowHtf, ema1mTrendHtf, ema1mRegimeHtf] = request.security(
     syminfo.tickerid, "1",
     [ta.ema(close, length1mFast), ta.ema(close, length1mSlow), ta.ema(close, length1mTrend), ta.ema(close, length1mRegime)],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

float ema2m200 = request.security(syminfo.tickerid, "2", ta.ema(close, 200), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float ema5mFast = ta.ema(close, length5mFast)
float ema5mTrend = ta.ema(close, length5mTrend)
float ema5mRegime = ta.ema(close, length5mRegime)
float emaOtherFast = ta.ema(close, lengthOtherFast)
float emaOtherTrend = ta.ema(close, lengthOtherTrend)
float emaOtherRegime = ta.ema(close, lengthOtherRegime)

bool useProjected1mNow = (is5m and enable5m and use1mEmasOn5m) or (isOther and enableOther and use1mEmasOnOther)
float laserFastEma = is1m ? ema1mFastNative : useProjected1mNow ? ema1mFastHtf : is5m ? ema5mFast : emaOtherFast
float laserTrendEma = is1m ? ema1mTrendNative : useProjected1mNow ? ema1mTrendHtf : is5m ? ema5mTrend : emaOtherTrend
float laserRegimeEma = is1m ? ema1mRegimeNative : useProjected1mNow ? ema1mRegimeHtf : is5m ? ema5mRegime : emaOtherRegime
float laserSlowEma = is1m ? ema1mSlowNative : useProjected1mNow ? ema1mSlowHtf : na

// Futures-session VWAP
bool newFuturesSession = session.isfirstbar
float futuresSessionVwap = ta.vwap(hlc3, newFuturesSession)
[vwapSdBase, vwapSdUpperBase, vwapSdLowerBase] = ta.vwap(hlc3, newFuturesSession, 1.0)
float futuresVwapSd = vwapSdUpperBase - vwapSdBase
float futuresVwapUpper1 = futuresSessionVwap + futuresVwapSd * vwapSdMultiplier1
float futuresVwapLower1 = futuresSessionVwap - futuresVwapSd * vwapSdMultiplier1
float futuresVwapUpper2 = futuresSessionVwap + futuresVwapSd * vwapSdMultiplier2
float futuresVwapLower2 = futuresSessionVwap - futuresVwapSd * vwapSdMultiplier2
float futuresVwapUpper3 = futuresSessionVwap + futuresVwapSd * vwapSdMultiplier3
float futuresVwapLower3 = futuresSessionVwap - futuresVwapSd * vwapSdMultiplier3

bool inRthVwap = not na(time(timeframe.period, rthVwapSession, sessionTimezone))
bool newRthVwap = inRthVwap and (bar_index == 0 or not inRthVwap[1])
var float rthCumPV = 0.0
var float rthCumV = 0.0
if newRthVwap
    rthCumPV := hlc3 * nz(volume, 0)
    rthCumV := nz(volume, 0)
else if inRthVwap
    rthCumPV += hlc3 * nz(volume, 0)
    rthCumV += nz(volume, 0)
float rthVwap = rthCumV > 0 ? rthCumPV / rthCumV : na

// EMA / VWAP plots
//
// IMPORTANT: Pine caps scripts at 64 plot counts. Input/series colors can make
// one plot() consume TWO counts. The old version used separate plot() calls for
// native 1m, projected 1m, native 5m, and native higher-TF EMAs. They were
// visually mutually exclusive, so v5.1 routes each conceptual EMA through ONE
// plot. This preserves the displayed values while saving ~20 plot counts.

bool displayFast =
     (is1m and enable1m and show1mFast) or
     (useProjected1mNow and show1mFast) or
     (is5m and enable5m and not use1mEmasOn5m and show5mFast) or
     (isOther and enableOther and not use1mEmasOnOther and showOtherFast)

bool displaySlow =
     (is1m and enable1m and show1mSlow) or
     (useProjected1mNow and show1mSlow)

bool displayTrend =
     (is1m and enable1m and show1mTrend) or
     (useProjected1mNow and show1mTrend) or
     (is5m and enable5m and not use1mEmasOn5m and show5mTrend) or
     (isOther and enableOther and not use1mEmasOnOther and showOtherTrend)

bool displayRegime =
     (is1m and enable1m and show1mRegime) or
     (useProjected1mNow and show1mRegime) or
     (is5m and enable5m and not use1mEmasOn5m and show5mRegime) or
     (isOther and enableOther and not use1mEmasOnOther and showOtherRegime)

color activeFastColor =
     (is1m or useProjected1mNow) ? fast1mColor : fast5mColor

plot(displayFast ? laserFastEma : na, "Active Fast EMA", activeFastColor, emaLineWidth)
plot(displaySlow ? laserSlowEma : na, "Active Slow EMA", slow1mColor, emaLineWidth)
plot(displayTrend ? laserTrendEma : na, "Active Trend EMA", trendColor, emaLineWidth)
plot(displayRegime ? laserRegimeEma : na, "Active Regime EMA", regimeColor, emaLineWidth)
plot(is5m and enable5m and show2m200On5m ? ema2m200 : na, "2m 200 EMA on 5m", ema2m200Color, emaLineWidth)

bool showSessionVwapNow = profileEnabled and (is1m ? showSessionVwap1m : is5m ? showSessionVwap5m : showSessionVwapOther)
plot(showSessionVwapNow ? futuresSessionVwap : na, "Futures Session VWAP", sessionVwapColor, vwapLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand1 ? futuresVwapUpper1 : na, "VWAP +SD1", vwapSdColor1, vwapSdLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand1 ? futuresVwapLower1 : na, "VWAP -SD1", vwapSdColor1, vwapSdLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand2 ? futuresVwapUpper2 : na, "VWAP +SD2", vwapSdColor2, vwapSdLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand2 ? futuresVwapLower2 : na, "VWAP -SD2", vwapSdColor2, vwapSdLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand3 ? futuresVwapUpper3 : na, "VWAP +SD3", vwapSdColor3, vwapSdLineWidth)
plot(showSessionVwapNow and showVwapSdBands and showVwapSdBand3 ? futuresVwapLower3 : na, "VWAP -SD3", vwapSdColor3, vwapSdLineWidth)
bool showRthVwapNow = showRthVwap and inRthVwap and profileEnabled and (is1m ? showRthVwap1m : is5m ? showRthVwap5m : false)
plot(showRthVwapNow ? rthVwap : na, "NYSE RTH VWAP", rthVwapColor, vwapLineWidth)

//=============================================================================
// 13 — INTERNAL RSI
//=============================================================================
float rsi = ta.rsi(close, rsiLength)
float rsiROC = rsi - rsi[1]
float rsiAccel = rsiROC - rsiROC[1]
float rsiSlope = ta.linreg(rsi, rsiComparisonBars, 0) - ta.linreg(rsi, rsiComparisonBars, 1)
bool rsiSharpDown = rsiROC <= -sharpRsiROC
bool rsiSharpUp = rsiROC >= sharpRsiROC
bool rsiAbove50 = rsi > 50
bool rsiBelow50 = rsi < 50

// Regular pivot divergence.
// Bullish: price makes LL while RSI makes HL.
// Bearish: price makes HH while RSI makes LH.
bool rsiPlFound = not na(ta.pivotlow(rsi, rsiDivLeft, rsiDivRight))
bool rsiPhFound = not na(ta.pivothigh(rsi, rsiDivLeft, rsiDivRight))
float rsiLBR = rsi[rsiDivRight]
float priceLowLBR = low[rsiDivRight]
float priceHighLBR = high[rsiDivRight]

float prevRsiLowPivot = ta.valuewhen(rsiPlFound, rsiLBR, 1)
float prevRsiHighPivot = ta.valuewhen(rsiPhFound, rsiLBR, 1)
float prevPriceLowPivot = ta.valuewhen(rsiPlFound, priceLowLBR, 1)
float prevPriceHighPivot = ta.valuewhen(rsiPhFound, priceHighLBR, 1)

// Regular pivot divergence only.
bool rsiBullDiv = useRsiDivergence and rsiPlFound and rsiLBR > prevRsiLowPivot and priceLowLBR < prevPriceLowPivot
bool rsiBearDiv = useRsiDivergence and rsiPhFound and rsiLBR < prevRsiHighPivot and priceHighLBR > prevPriceHighPivot

// Divergence quality measurements. Price overshoot is emphasized in the cockpit;
// raw RSI pivot separation is retained for explanation but is not given an extra
// quality bonus by itself.
float divAtrSeries = ta.atr(atrLength)
float pivotAtr = divAtrSeries[rsiDivRight]
float bullDivRsiGapNow = rsiBullDiv ? rsiLBR - prevRsiLowPivot : na
float bearDivRsiGapNow = rsiBearDiv ? prevRsiHighPivot - rsiLBR : na
float bullDivPriceAtrNow = rsiBullDiv and not na(pivotAtr) and pivotAtr > 0 ? (prevPriceLowPivot - priceLowLBR) / pivotAtr : na
float bearDivPriceAtrNow = rsiBearDiv and not na(pivotAtr) and pivotAtr > 0 ? (priceHighLBR - prevPriceHighPivot) / pivotAtr : na

var float lastBullDivRsiGap = na
var float lastBearDivRsiGap = na
var float lastBullDivPriceAtr = na
var float lastBearDivPriceAtr = na
var float lastBullDivPivotRsi = na
var float lastBearDivPivotRsi = na

if rsiBullDiv
    lastBullDivRsiGap := bullDivRsiGapNow
    lastBullDivPriceAtr := bullDivPriceAtrNow
    lastBullDivPivotRsi := rsiLBR

if rsiBearDiv
    lastBearDivRsiGap := bearDivRsiGapNow
    lastBearDivPriceAtr := bearDivPriceAtrNow
    lastBearDivPivotRsi := rsiLBR

int barsSinceRsiBullDiv = ta.barssince(rsiBullDiv)
int barsSinceRsiBearDiv = ta.barssince(rsiBearDiv)
bool recentRsiBullDiv = not na(barsSinceRsiBullDiv) and barsSinceRsiBullDiv <= rsiDivMemoryBars
bool recentRsiBearDiv = not na(barsSinceRsiBearDiv) and barsSinceRsiBearDiv <= rsiDivMemoryBars
bool bullDivStrongPrice = recentRsiBullDiv and not na(lastBullDivPriceAtr) and lastBullDivPriceAtr >= divStrongPriceATR
bool bearDivStrongPrice = recentRsiBearDiv and not na(lastBearDivPriceAtr) and lastBearDivPriceAtr >= divStrongPriceATR
bool bullDivInZone = recentRsiBullDiv and not na(lastBullDivPivotRsi) and lastBullDivPivotRsi <= bullDivZone
bool bearDivInZone = recentRsiBearDiv and not na(lastBearDivPivotRsi) and lastBearDivPivotRsi >= bearDivZone

// Confirmation markers are optional and are placed on the bar where divergence
// becomes knowable, not on the earlier pivot bar.
if showRsiDivMarkers and rsiBullDiv
    string bullDivTooltip = "Bullish RSI divergence confirmed.\nPivot was " + str.tostring(rsiDivRight) + " bars earlier.\nRSI pivot separation: " + str.tostring(bullDivRsiGapNow, "#.1") + "\nPrice overshoot: " + str.tostring(bullDivPriceAtrNow, "#.2") + " ATR"
    label.new(bar_index, low, "B DIV", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.green, 45), textcolor = color.white, size = size.tiny, tooltip = bullDivTooltip)

if showRsiDivMarkers and rsiBearDiv
    string bearDivTooltip = "Bearish RSI divergence confirmed.\nPivot was " + str.tostring(rsiDivRight) + " bars earlier.\nRSI pivot separation: " + str.tostring(bearDivRsiGapNow, "#.1") + "\nPrice overshoot: " + str.tostring(bearDivPriceAtrNow, "#.2") + " ATR"
    label.new(bar_index, high, "S DIV", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.red, 45), textcolor = color.white, size = size.tiny, tooltip = bearDivTooltip)

//=============================================================================
// 14 — INTERNAL SQZMOM — corrected BB multiplier
//=============================================================================
float bbBasis = ta.sma(close, bbLength)
float bbDeviation = bbMult * ta.stdev(close, bbLength)
float upperBB = bbBasis + bbDeviation
float lowerBB = bbBasis - bbDeviation
float kcBasis = ta.sma(close, kcLength)
float kcRange = sqzUseTrueRange ? ta.tr(true) : high - low
float kcRangeMA = ta.sma(kcRange, kcLength)
float upperKC = kcBasis + kcRangeMA * kcMult
float lowerKC = kcBasis - kcRangeMA * kcMult
bool squeezeOn = lowerBB > lowerKC and upperBB < upperKC
bool squeezeOff = lowerBB < lowerKC and upperBB > upperKC
bool squeezeFired = squeezeOn[1] and squeezeOff
float rangeMiddle = math.avg(ta.highest(high, kcLength), ta.lowest(low, kcLength))
float momentumBasis = math.avg(rangeMiddle, ta.sma(close, kcLength))
float sqzMomentum = ta.linreg(close - momentumBasis, kcLength, 0)
float sqzROC = sqzMomentum - sqzMomentum[1]
float sqzAccel = sqzROC - sqzROC[1]
bool sqzBullAccel = sqzMomentum > 0 and sqzROC > 0
bool sqzBullDecel = sqzMomentum > 0 and sqzROC < 0
bool sqzBearAccel = sqzMomentum < 0 and sqzROC < 0
bool sqzBearDecel = sqzMomentum < 0 and sqzROC > 0
bool sqzBullReAccel = sqzBullAccel and sqzAccel > 0
bool sqzBearReAccel = sqzBearAccel and sqzAccel < 0
bool bullZeroCross = ta.crossover(sqzMomentum, 0)
bool bearZeroCross = ta.crossunder(sqzMomentum, 0)
var int squeezeBars = 0
var int positiveMomentumBars = 0
var int negativeMomentumBars = 0
if squeezeOn
    squeezeBars += 1
else
    squeezeBars := 0
if sqzMomentum > 0
    positiveMomentumBars += 1
    negativeMomentumBars := 0
else if sqzMomentum < 0
    negativeMomentumBars += 1
    positiveMomentumBars := 0
else
    positiveMomentumBars := 0
    negativeMomentumBars := 0
int barsSinceRelease = ta.barssince(squeezeFired)
bool recentRelease = not na(barsSinceRelease) and barsSinceRelease <= recentReleaseBars
bool prolongedCompression = squeezeOn and squeezeBars >= pressureSqueezeBars
bool matureBearMomentum = negativeMomentumBars[1] >= matureMomentumBars
bool matureBullMomentum = positiveMomentumBars[1] >= matureMomentumBars
// Small text-dot drawing object instead of a circle label.
// "Micro" is deliberately smaller than Pine's label.style_circle at size.tiny.
if showSqueezeFires and squeezeFired
    label.new(
         bar_index,
         low,
         squeezeFireSymbol,
         yloc = yloc.belowbar,
         style = label.style_none,
         color = color.new(color.white, 100),
         textcolor = color.white,
         size = squeezeFireTextSize)

//=============================================================================
// 15 — VOLUME / ABSORPTION
//=============================================================================
float avgVolume = ta.sma(volume, volumeAvgLength)
float relativeVolume = avgVolume > 0 ? volume / avgVolume : 0
float volumeATR = ta.atr(volumeATRLength)
float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyPct = candleRange > 0 ? candleBody / candleRange * 100 : 0
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickPct = candleRange > 0 ? upperWick / candleRange * 100 : 0
float lowerWickPct = candleRange > 0 ? lowerWick / candleRange * 100 : 0
float candleMid = (high + low) / 2
bool volumeSignalAllowed = not volumeRequireClose or barstate.isconfirmed
bool volumeBullMove = showVolumeMoves and volumeSignalAllowed and close > open and relativeVolume >= moveVolumeMult and candleRange >= volumeATR * moveRangeATR and bodyPct >= moveBodyPct and close >= high - candleRange * moveClosePct / 100
bool volumeBearMove = showVolumeMoves and volumeSignalAllowed and close < open and relativeVolume >= moveVolumeMult and candleRange >= volumeATR * moveRangeATR and bodyPct >= moveBodyPct and close <= low + candleRange * moveClosePct / 100
bool sellingAbsorbed = showAbsorption and volumeSignalAllowed and relativeVolume >= absVolumeMult and bodyPct <= absMaxBody and lowerWickPct >= absMinWick and lowerWick >= upperWick * absWickDominance and (not absRequireMidpoint or close >= candleMid)
bool buyingAbsorbed = showAbsorption and volumeSignalAllowed and relativeVolume >= absVolumeMult and bodyPct <= absMaxBody and upperWickPct >= absMinWick and upperWick >= lowerWick * absWickDominance and (not absRequireMidpoint or close <= candleMid)
bool finalBullMove = volumeBullMove and not sellingAbsorbed and not buyingAbsorbed
bool finalBearMove = volumeBearMove and not sellingAbsorbed and not buyingAbsorbed
bool volumeCandleSignal = finalBullMove or finalBearMove or sellingAbsorbed or buyingAbsorbed
color signalBody = na
color signalWick = na
color signalBorder = na
if sellingAbsorbed
    signalBody := color.new(bullAbsorbColor, 100)
    signalWick := bullAbsorbColor
    signalBorder := bullAbsorbColor
else if buyingAbsorbed
    signalBody := color.new(bearAbsorbColor, 100)
    signalWick := bearAbsorbColor
    signalBorder := bearAbsorbColor
else if finalBullMove
    signalBody := bullMoveColor
    signalWick := bullMoveColor
    signalBorder := bullMoveColor
else if finalBearMove
    signalBody := bearMoveColor
    signalWick := bearMoveColor
    signalBorder := bearMoveColor
barcolor(volumeCandleSignal ? color.new(color.white, 100) : na)
plotcandle(volumeCandleSignal ? open : na, volumeCandleSignal ? high : na, volumeCandleSignal ? low : na, volumeCandleSignal ? close : na, title = "Volume Signal Candles", color = signalBody, wickcolor = signalWick, bordercolor = signalBorder)

//=============================================================================
// 16 — PREVIOUS ASIA / LONDON / NYSE SESSION H/L
//=============================================================================
bool inAsia = not na(time(timeframe.period, asiaSession, sessionTimezone))
bool asiaStart = inAsia and (bar_index == 0 or not inAsia[1])
bool asiaEnd = not inAsia and bar_index > 0 and inAsia[1]
var float asiaCurH = na
var float asiaCurL = na
var float prevAsiaH = na
var float prevAsiaL = na
if asiaStart
    asiaCurH := high
    asiaCurL := low
else if inAsia
    asiaCurH := na(asiaCurH) ? high : math.max(asiaCurH, high)
    asiaCurL := na(asiaCurL) ? low : math.min(asiaCurL, low)
if asiaEnd
    prevAsiaH := asiaCurH
    prevAsiaL := asiaCurL

bool inLondon = not na(time(timeframe.period, londonSession, sessionTimezone))
bool londonStart = inLondon and (bar_index == 0 or not inLondon[1])
bool londonEnd = not inLondon and bar_index > 0 and inLondon[1]
var float londonCurH = na
var float londonCurL = na
var float prevLondonH = na
var float prevLondonL = na
if londonStart
    londonCurH := high
    londonCurL := low
else if inLondon
    londonCurH := na(londonCurH) ? high : math.max(londonCurH, high)
    londonCurL := na(londonCurL) ? low : math.min(londonCurL, low)
if londonEnd
    prevLondonH := londonCurH
    prevLondonL := londonCurL

bool inNyse = not na(time(timeframe.period, nyseSession, sessionTimezone))
bool nyseStart = inNyse and (bar_index == 0 or not inNyse[1])
bool nyseEnd = not inNyse and bar_index > 0 and inNyse[1]
var float nyseCurH = na
var float nyseCurL = na
var float prevNyseH = na
var float prevNyseL = na
if nyseStart
    nyseCurH := high
    nyseCurL := low
else if inNyse
    nyseCurH := na(nyseCurH) ? high : math.max(nyseCurH, high)
    nyseCurL := na(nyseCurL) ? low : math.min(nyseCurL, low)
if nyseEnd
    prevNyseH := nyseCurH
    prevNyseL := nyseCurL

float pwh = request.security(syminfo.tickerid, "W", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float pwl = request.security(syminfo.tickerid, "W", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

//=============================================================================
// 17 — MECHANICAL DEVELOPING GLOBEX VP + PREVIOUS GLOBEX H/L
//=============================================================================
[ltTime, ltHigh, ltLow, ltVolume] = request.security_lower_tf(syminfo.tickerid, vpLowerTF, [time, high, low, volume], ignore_invalid_timeframe = true, calc_bars_count = 100000)
int ltCount = array.size(ltTime)
bool haveIntrabarData = ltCount > 0
var map<int, float> globexMap = map.new<int, float>()
var int globexMinKey = na
var int globexMaxKey = na
var int currentGlobexKey = na
var bool currentGlobexClean = false
var float globexDevH = na
var float globexDevL = na
var float previousGlobexHigh = na
var float previousGlobexLow = na
var float globexPOC = na
var float globexVAH = na
var float globexVAL = na

f_globexKey(int ts) =>
    int h = hour(ts, sessionTimezone)
    int y = year(ts, sessionTimezone)
    int m = month(ts, sessionTimezone)
    int d = dayofmonth(ts, sessionTimezone)
    int addDay = h >= 17 ? 1 : 0
    timestamp(sessionTimezone, y, m, d + addDay, 12, 0)

f_profile(map<int, float> profile, int minKey, int maxKey, float binSize, float vaPct) =>
    float outPOC = na
    float outVAH = na
    float outVAL = na
    if profile.size() > 0 and not na(minKey) and not na(maxKey)
        float totalVol = 0.0
        float maxVol = -1.0
        int pocKey = minKey
        for k = minKey to maxKey
            float v = profile.contains(k) ? profile.get(k) : 0.0
            totalVol += v
            if v > maxVol
                maxVol := v
                pocKey := k
        float target = totalVol * vaPct / 100
        int vaLo = pocKey
        int vaHi = pocKey
        float acc = profile.contains(pocKey) ? profile.get(pocKey) : 0.0
        while acc < target and (vaLo > minKey or vaHi < maxKey)
            float below = vaLo > minKey ? (profile.contains(vaLo - 1) ? profile.get(vaLo - 1) : 0.0) : -1.0
            float above = vaHi < maxKey ? (profile.contains(vaHi + 1) ? profile.get(vaHi + 1) : 0.0) : -1.0
            if above >= below and vaHi < maxKey
                vaHi += 1
                acc += profile.contains(vaHi) ? profile.get(vaHi) : 0.0
            else if vaLo > minKey
                vaLo -= 1
                acc += profile.contains(vaLo) ? profile.get(vaLo) : 0.0
            else
                vaHi += 1
                acc += profile.contains(vaHi) ? profile.get(vaHi) : 0.0
        outPOC := (pocKey + 0.5) * binSize
        outVAL := vaLo * binSize
        outVAH := (vaHi + 1.0) * binSize
    [outPOC, outVAH, outVAL]

if barstate.isconfirmed and haveIntrabarData
    for i = 0 to ltCount - 1
        int t = array.get(ltTime, i)
        float hi = array.get(ltHigh, i)
        float lo = array.get(ltLow, i)
        float vol = array.get(ltVolume, i)
        int h = hour(t, sessionTimezone)
        bool insideGlobex = h >= 17 or h < 16
        if insideGlobex
            int thisKey = f_globexKey(t)
            if na(currentGlobexKey)
                currentGlobexKey := thisKey
                currentGlobexClean := h >= 17
            else if thisKey != currentGlobexKey
                if currentGlobexClean
                    previousGlobexHigh := globexDevH
                    previousGlobexLow := globexDevL
                globexMap.clear()
                globexMinKey := na
                globexMaxKey := na
                globexDevH := na
                globexDevL := na
                currentGlobexKey := thisKey
                currentGlobexClean := true
            globexDevH := na(globexDevH) ? hi : math.max(globexDevH, hi)
            globexDevL := na(globexDevL) ? lo : math.min(globexDevL, lo)
            int lowKey = int(math.floor(lo / vpPrimaryPoints))
            int highKey = int(math.floor(hi / vpPrimaryPoints))
            globexMinKey := na(globexMinKey) ? lowKey : math.min(globexMinKey, lowKey)
            globexMaxKey := na(globexMaxKey) ? highKey : math.max(globexMaxKey, highKey)
            float rng = hi - lo
            if rng <= 0
                float old = globexMap.contains(lowKey) ? globexMap.get(lowKey) : 0.0
                globexMap.put(lowKey, old + vol)
            else
                for k = lowKey to highKey
                    float binLo = k * vpPrimaryPoints
                    float binHi = binLo + vpPrimaryPoints
                    float overlap = math.max(math.min(hi, binHi) - math.max(lo, binLo), 0)
                    if overlap > 0
                        float alloc = vol * overlap / rng
                        float old = globexMap.contains(k) ? globexMap.get(k) : 0.0
                        globexMap.put(k, old + alloc)

[gPOC, gVAH, gVAL] = f_profile(globexMap, globexMinKey, globexMaxKey, vpPrimaryPoints, vpValueAreaPct)
if currentGlobexClean and not na(gPOC)
    globexPOC := gPOC
    globexVAH := gVAH
    globexVAL := gVAL

//=============================================================================
// 18 — RIGHT-SIDE ACTIVE PROFILE
// For RTH / Visible / Fixed modes, this exact profile supplies LASER live VAH/POC/VAL.
// Non-Globex modes suppress historical FIREs to avoid non-causal backtest claims.
// The histogram shows distribution shape only; POC is shown once as the thin POC line.
//=============================================================================
int visibleLeftTime = na(chart.left_visible_bar_time) ? time : chart.left_visible_bar_time
int visibleRightTime = na(chart.right_visible_bar_time) ? time : chart.right_visible_bar_time
int barDurationMS = math.max(1, int(timeframe.in_seconds() * 1000))
bool newTradingDay = ta.change(time_tradingday) != 0
int currentSessionBars = nz(ta.barssince(newTradingDay), 0) + 1
int visibleRangeBars = math.max(1, math.round((visibleRightTime - visibleLeftTime) / barDurationMS) + 1)

bool vpInRth = not na(time(timeframe.period, vpRthSession, sessionTimezone))
bool vpRthOpen = vpInRth and (bar_index == 0 or not vpInRth[1])
var int vpRthStart = na
var int vpRthEnd = na
if vpRthOpen
    vpRthStart := bar_index
    vpRthEnd := bar_index
else if vpInRth
    if na(vpRthStart)
        vpRthStart := bar_index
    vpRthEnd := bar_index

int requestedBars = vpMode == "Visible Range" ? visibleRangeBars : vpMode == "Fixed Lookback" ? vpFixedLookback : currentSessionBars
int contiguousBars = math.max(1, math.min(requestedBars, math.min(3000, bar_index + 1)))
int vpNewestOffset = 0
int vpOldestOffset = contiguousBars - 1
int vpBarCount = contiguousBars
bool visualVpValid = true
if vpMode == "NYSE RTH Snapshot"
    visualVpValid := not na(vpRthStart) and not na(vpRthEnd)
    if visualVpValid
        vpNewestOffset := bar_index - vpRthEnd
        vpOldestOffset := bar_index - vpRthStart
        vpBarCount := vpRthEnd - vpRthStart + 1
        if vpNewestOffset < 0 or vpOldestOffset < vpNewestOffset or vpOldestOffset > 4999
            visualVpValid := false

var array<line> vpRowLines = array.new_line()
var array<float> vpVolumes = array.new_float()
var line vpPocLine = na
var line vpVahLine = na
var line vpValLine = na
var float liveVisualPOC = na
var float liveVisualVAH = na
var float liveVisualVAL = na

if barstate.isfirst
    for i = 0 to vpRows - 1
        array.push(vpRowLines, line.new(bar_index, close, bar_index, close, width = vpThickness))
        array.push(vpVolumes, 0.0)
    vpPocLine := line.new(time, close, time, close, xloc = xloc.bar_time)
    vpVahLine := line.new(time, close, time, close, xloc = xloc.bar_time)
    vpValLine := line.new(time, close, time, close, xloc = xloc.bar_time)

if barstate.islast and visualVpValid and array.size(vpVolumes) == vpRows
    array.fill(vpVolumes, 0.0)
    float vpHighest = high[vpNewestOffset]
    float vpLowest = low[vpNewestOffset]
    for i = vpNewestOffset to vpOldestOffset
        vpHighest := math.max(vpHighest, high[i])
        vpLowest := math.min(vpLowest, low[i])
    float vpInterval = math.max((vpHighest - vpLowest) / math.max(vpRows - 1, 1), syminfo.mintick)
    for i = vpNewestOffset to vpOldestOffset
        for j = 0 to vpRows - 1
            float level = vpLowest + vpInterval * j
            if level >= low[i] and level < high[i]
                array.set(vpVolumes, j, array.get(vpVolumes, j) + volume[i])
    float maxVol = array.max(vpVolumes)
    int maxIdx = array.indexof(vpVolumes, maxVol)
    float totalVol = array.sum(vpVolumes)
    float targetVA = totalVol * vpValueAreaPct / 100
    int vaDn = maxIdx
    int vaUp = maxIdx
    float vaSum = maxVol
    while vaSum < targetVA
        float upVol = vaUp < vpRows - 1 ? array.get(vpVolumes, vaUp + 1) : 0
        float dnVol = vaDn > 0 ? array.get(vpVolumes, vaDn - 1) : 0
        if upVol == 0 and dnVol == 0
            break
        if upVol >= dnVol
            vaUp += 1
            vaSum += upVol
        else
            vaDn -= 1
            vaSum += dnVol
    liveVisualPOC := vpLowest + vpInterval * maxIdx
    liveVisualVAH := vpLowest + vpInterval * vaUp
    liveVisualVAL := vpLowest + vpInterval * vaDn
    int x2 = bar_index + vpRightOffset
    float divisor = maxVol / math.max(vpBarCount, 1) / (vpWidth / 100.0)
    if showRightProfile
        for i = 0 to vpRows - 1
            float rowVol = array.get(vpVolumes, i)
            int scaled = divisor > 0 ? math.round(rowVol / divisor) : 0
            float y = vpLowest + vpInterval * i
            line row = array.get(vpRowLines, i)
            line.set_xy1(row, x2 - scaled, y)
            line.set_xy2(row, x2, y)
            line.set_width(row, vpThickness)
            bool inVA = y >= liveVisualVAL and y <= liveVisualVAH
            line.set_color(row, inVA ? vpValueColor : vpOutsideColor)
    else
        for i = 0 to vpRows - 1
            line.set_color(array.get(vpRowLines, i), color.new(vpOutsideColor, 100))

float activePOC = vpMode == "Globex Developing" ? globexPOC : liveVisualPOC
float activeVAH = vpMode == "Globex Developing" ? globexVAH : liveVisualVAH
float activeVAL = vpMode == "Globex Developing" ? globexVAL : liveVisualVAL
bool liveOnlyVpMode = vpMode != "Globex Developing"
string vpState = vpMode == "Globex Developing" ? "GLOBEX DEV" : vpMode == "NYSE RTH Snapshot" ? "RTH SNAP" : vpMode == "Visible Range" ? "VISIBLE" : "FIXED"

f_keyGeometry() =>
    int rightT = keyLevelAnchorMode == "Visible Chart" ? visibleRightTime : time + keyLabelOffset * barDurationMS
    int leftT = keyLevelAnchorMode == "Visible Chart" ? visibleLeftTime : (na(time[keyLevelBarsBack]) ? time : time[keyLevelBarsBack])
    int lineEndT = rightT - keyLabelGapBars * barDurationMS
    if lineEndT <= leftT
        lineEndT := rightT
    [leftT, lineEndT, rightT]

[levelLeftTime, levelEndTime, levelLabelTime] = f_keyGeometry()

if barstate.islast
    if showActiveVpLines and not na(activePOC) and not na(activeVAH) and not na(activeVAL)
        int vpDisplayEndTime = showVpLevelLabels ? levelEndTime : levelLabelTime
        line.set_xy1(vpPocLine, levelLeftTime, activePOC)
        line.set_xy2(vpPocLine, vpDisplayEndTime, activePOC)
        line.set_color(vpPocLine, vpPocColor)
        line.set_width(vpPocLine, vpLevelLineWidth)

        line.set_xy1(vpVahLine, levelLeftTime, activeVAH)
        line.set_xy2(vpVahLine, vpDisplayEndTime, activeVAH)
        line.set_color(vpVahLine, vpLineColor)
        line.set_width(vpVahLine, vpLevelLineWidth)

        line.set_xy1(vpValLine, levelLeftTime, activeVAL)
        line.set_xy2(vpValLine, vpDisplayEndTime, activeVAL)
        line.set_color(vpValLine, vpLineColor)
        line.set_width(vpValLine, vpLevelLineWidth)
    else
        line.set_color(vpPocLine, color.new(vpPocColor, 100))
        line.set_color(vpVahLine, color.new(vpLineColor, 100))
        line.set_color(vpValLine, color.new(vpLineColor, 100))

//=============================================================================
// 18B — CURRENT KEY LEVEL DISPLAY
// Current-only drawing objects: no progressive/stair-step history.
// Visible Chart mode anchors the levels to the chart window itself.
// Lines stop before labels so the text is never struck through.
//=============================================================================

var line asiaHighLine = na
var line asiaLowLine = na
var line londonHighLine = na
var line londonLowLine = na
var line nyseHighLine = na
var line nyseLowLine = na
var line globexHighLine = na
var line globexLowLine = na
var line weekHighLine = na
var line weekLowLine = na

var label asiaHighLabel = na
var label asiaLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na
var label nyseHighLabel = na
var label nyseLowLabel = na
var label globexHighLabel = na
var label globexLowLabel = na
var label weekHighLabel = na
var label weekLowLabel = na
var label vahLabel = na
var label pocLabel = na
var label valLabel = na

f_updateLevelLine(line existingLine, bool showLabel, bool showLevel, float level, color levelColor) =>
    line result = existingLine
    int displayEndTime = showLabel ? levelEndTime : levelLabelTime
    if showLevel and not na(level)
        if na(result)
            result := line.new(
                 levelLeftTime, level,
                 displayEndTime, level,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = levelColor,
                 width = keyLevelLineWidth)
        else
            line.set_xy1(result, levelLeftTime, level)
            line.set_xy2(result, displayEndTime, level)
            line.set_color(result, levelColor)
            line.set_width(result, keyLevelLineWidth)
    else
        if not na(result)
            line.delete(result)
        result := na
    result

f_updateLevelLabel(label existingLabel, bool showLabel, bool showLevel, float level, string levelName, color levelColor) =>
    label result = existingLabel
    if showLabel and showLevel and not na(level)
        string txt = showKeyLevelPrices ? levelName + "  " + str.tostring(level, format.mintick) : levelName
        if na(result)
            result := label.new(
                 levelLabelTime,
                 level,
                 txt,
                 xloc = xloc.bar_time,
                 yloc = yloc.price,
                 style = label.style_none,
                 color = color.new(color.black, 100),
                 textcolor = levelColor,
                 size = keyLabelTextSize)
        else
            label.set_xy(result, levelLabelTime, level)
            label.set_text(result, txt)
            label.set_textcolor(result, levelColor)
            label.set_color(result, color.new(color.black, 100))
            label.set_style(result, label.style_none)
            label.set_size(result, keyLabelTextSize)
    else
        if not na(result)
            label.delete(result)
        result := na
    result

if barstate.islast
    asiaHighLine := f_updateLevelLine(asiaHighLine, showSessionLevelLabels, showPrevAsiaHL, prevAsiaH, asiaColor)
    asiaLowLine := f_updateLevelLine(asiaLowLine, showSessionLevelLabels, showPrevAsiaHL, prevAsiaL, asiaColor)
    londonHighLine := f_updateLevelLine(londonHighLine, showSessionLevelLabels, showPrevLondonHL, prevLondonH, londonColor)
    londonLowLine := f_updateLevelLine(londonLowLine, showSessionLevelLabels, showPrevLondonHL, prevLondonL, londonColor)
    nyseHighLine := f_updateLevelLine(nyseHighLine, showSessionLevelLabels, showPrevNyseHL, prevNyseH, nyseColor)
    nyseLowLine := f_updateLevelLine(nyseLowLine, showSessionLevelLabels, showPrevNyseHL, prevNyseL, nyseColor)
    globexHighLine := f_updateLevelLine(globexHighLine, showSessionLevelLabels, showPreviousGlobexLines, previousGlobexHigh, globexColor)
    globexLowLine := f_updateLevelLine(globexLowLine, showSessionLevelLabels, showPreviousGlobexLines, previousGlobexLow, globexColor)
    weekHighLine := f_updateLevelLine(weekHighLine, showSessionLevelLabels, showPreviousWeekLines, pwh, weekColor)
    weekLowLine := f_updateLevelLine(weekLowLine, showSessionLevelLabels, showPreviousWeekLines, pwl, weekColor)

    asiaHighLabel := f_updateLevelLabel(asiaHighLabel, showSessionLevelLabels, showPrevAsiaHL, prevAsiaH, "Asia H", asiaColor)
    asiaLowLabel := f_updateLevelLabel(asiaLowLabel, showSessionLevelLabels, showPrevAsiaHL, prevAsiaL, "Asia L", asiaColor)
    londonHighLabel := f_updateLevelLabel(londonHighLabel, showSessionLevelLabels, showPrevLondonHL, prevLondonH, "London H", londonColor)
    londonLowLabel := f_updateLevelLabel(londonLowLabel, showSessionLevelLabels, showPrevLondonHL, prevLondonL, "London L", londonColor)
    nyseHighLabel := f_updateLevelLabel(nyseHighLabel, showSessionLevelLabels, showPrevNyseHL, prevNyseH, "NYSE H", nyseColor)
    nyseLowLabel := f_updateLevelLabel(nyseLowLabel, showSessionLevelLabels, showPrevNyseHL, prevNyseL, "NYSE L", nyseColor)
    globexHighLabel := f_updateLevelLabel(globexHighLabel, showSessionLevelLabels, showPreviousGlobexLines, previousGlobexHigh, "PGH", globexColor)
    globexLowLabel := f_updateLevelLabel(globexLowLabel, showSessionLevelLabels, showPreviousGlobexLines, previousGlobexLow, "PGL", globexColor)
    weekHighLabel := f_updateLevelLabel(weekHighLabel, showSessionLevelLabels, showPreviousWeekLines, pwh, "PWH", weekColor)
    weekLowLabel := f_updateLevelLabel(weekLowLabel, showSessionLevelLabels, showPreviousWeekLines, pwl, "PWL", weekColor)

    vahLabel := f_updateLevelLabel(vahLabel, showVpLevelLabels, showActiveVpLines, activeVAH, "VAH", vpLineColor)
    pocLabel := f_updateLevelLabel(pocLabel, showVpLevelLabels, showActiveVpLines, activePOC, "POC", vpPocColor)
    valLabel := f_updateLevelLabel(valLabel, showVpLevelLabels, showActiveVpLines, activeVAL, "VAL", vpLineColor)

//=============================================================================
// 19 — STRUCTURE / PRICE-MOMENTUM DISAGREEMENT
//=============================================================================
float atr = ta.atr(atrLength)
float priorResistance = ta.highest(high[1], structureLookback)
float priorSupport = ta.lowest(low[1], structureLookback)
float microResistance = ta.highest(high[1], microLookback)
float microSupport = ta.lowest(low[1], microLookback)
bool breakResistance = close > priorResistance
bool breakSupport = close < priorSupport
bool microBullBreak = close > microResistance
bool microBearBreak = close < microSupport
bool sweepHigh = high > priorResistance and close < priorResistance
bool sweepLow = low < priorSupport and close > priorSupport
int barsSinceSweepHigh = ta.barssince(sweepHigh)
int barsSinceSweepLow = ta.barssince(sweepLow)
bool freshSweepHigh = not na(barsSinceSweepHigh) and barsSinceSweepHigh <= 1
bool freshSweepLow = not na(barsSinceSweepLow) and barsSinceSweepLow <= 1
float lastSweepHigh = ta.valuewhen(sweepHigh, high, 0)
float lastSweepLow = ta.valuewhen(sweepLow, low, 0)
bool higherLow = low > low[1] and low[1] >= low[2]
bool lowerHigh = high < high[1] and high[1] <= high[2]

float rawBody = math.max(math.abs(close - open), syminfo.mintick)
float rawLowerWick = math.min(open, close) - low
float rawUpperWick = high - math.max(open, close)
bool bullReject = close > open and rawLowerWick > rawBody
bool bearReject = close < open and rawUpperWick > rawBody
bool bullImpulse = close > open and close > close[1]
bool bearImpulse = close < open and close < close[1]

float priceChange = close - close[rsiComparisonBars - 1]
float priceSlope = ta.linreg(close, rsiComparisonBars, 0) - ta.linreg(close, rsiComparisonBars, 1)
float sqzSlope = ta.linreg(sqzMomentum, rsiComparisonBars, 0) - ta.linreg(sqzMomentum, rsiComparisonBars, 1)
bool bearishDisagreement = priceChange >= 5 and priceSlope > 0 and rsiSlope < 0 and sqzSlope < 0
bool bullishDisagreement = priceChange <= -5 and priceSlope < 0 and rsiSlope > 0 and sqzSlope > 0

//=============================================================================
// 20 — TREND / BALANCE REGIME
//=============================================================================
float close15 = request.security(syminfo.tickerid, "15", close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float ema15 = request.security(syminfo.tickerid, "15", ta.ema(close, 50), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float close60 = request.security(syminfo.tickerid, "60", close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float ema60 = request.security(syminfo.tickerid, "60", ta.ema(close, 50), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float trendEmaSlope = laserTrendEma - laserTrendEma[3]
float bullTrendScore = (close > futuresSessionVwap ? 1.0 : 0.0) + (laserFastEma > laserTrendEma ? 1.0 : 0.0) + (trendEmaSlope > 0 ? 1.0 : 0.0) + (close15 > ema15 ? 1.0 : 0.0) + (close60 > ema60 ? 1.0 : 0.0)
float bearTrendScore = (close < futuresSessionVwap ? 1.0 : 0.0) + (laserFastEma < laserTrendEma ? 1.0 : 0.0) + (trendEmaSlope < 0 ? 1.0 : 0.0) + (close15 < ema15 ? 1.0 : 0.0) + (close60 < ema60 ? 1.0 : 0.0)
bool strongBullTrend = bullTrendScore >= 4
bool strongBearTrend = bearTrendScore >= 4
bool bullTrend = bullTrendScore >= 3
bool bearTrend = bearTrendScore >= 3

float efficiencyTravel = 0.0
for i = 0 to efficiencyLookback - 2
    efficiencyTravel += math.abs(close[i] - close[i + 1])
float efficiencyNet = math.abs(close - close[efficiencyLookback - 1])
float directionalEfficiency = efficiencyTravel > 0 ? efficiencyNet / efficiencyTravel : 0
float meanClusterHigh = math.max(futuresSessionVwap, math.max(laserFastEma, laserTrendEma))
float meanClusterLow = math.min(futuresSessionVwap, math.min(laserFastEma, laserTrendEma))
bool meanClusterCompressed = meanClusterHigh - meanClusterLow <= atr * 0.75
bool crossedFast = ta.cross(close, laserFastEma)
bool crossedTrend = ta.cross(close, laserTrendEma)
bool crossedVWAP = ta.cross(close, futuresSessionVwap)
int meanCrossCount = 0
for i = 0 to meanCrossLookback - 1
    if crossedFast[i]
        meanCrossCount += 1
    if crossedTrend[i]
        meanCrossCount += 1
    if crossedVWAP[i]
        meanCrossCount += 1
float currentRange = math.max(high - low, syminfo.mintick)
float previousRange = math.max(high[1] - low[1], syminfo.mintick)
float overlapAmount = math.max(0, math.min(high, high[1]) - math.max(low, low[1]))
float overlapRatio = overlapAmount / math.min(currentRange, previousRange)
float averageOverlap = ta.sma(overlapRatio, overlapLookback)
bool validValueArea = not na(activeVAH) and not na(activeVAL) and activeVAH > activeVAL
bool deepInsideValue = validValueArea and close < activeVAH - (activeVAH - activeVAL) * 0.15 and close > activeVAL + (activeVAH - activeVAL) * 0.15
float balanceScore = 0
if directionalEfficiency <= 0.30
    balanceScore += 25
if meanClusterCompressed
    balanceScore += 20
if meanCrossCount >= 5
    balanceScore += 20
else if meanCrossCount >= 3
    balanceScore += 10
if averageOverlap >= 0.45
    balanceScore += 20
else if averageOverlap >= 0.30
    balanceScore += 10
if deepInsideValue
    balanceScore += 10
if relativeVolume <= 0.70
    balanceScore += 5
balanceScore := math.min(balanceScore, 100)
bool hardBalanceRegime = balanceScore >= hardBalanceThreshold and not strongBullTrend and not strongBearTrend
bool balanceRegime = balanceScore >= softBalanceThreshold and not strongBullTrend and not strongBearTrend
string regime = hardBalanceRegime ? "BALANCE" : strongBullTrend ? "STRONG UP" : strongBearTrend ? "STRONG DOWN" : bullTrend ? "TREND UP" : bearTrend ? "TREND DOWN" : balanceRegime ? "BALANCE" : "TRANSITION"

float bullImpulseSize = close - ta.lowest(low, matureImpulseLookback)
float bearImpulseSize = ta.highest(high, matureImpulseLookback) - close
bool matureBullImpulse = bullImpulseSize >= atr * matureImpulseATR
bool matureBearImpulse = bearImpulseSize >= atr * matureImpulseATR
float recentHigh = ta.highest(high[1], 5)
float recentLow = ta.lowest(low[1], 5)
bool bullProgressFailure = high <= recentHigh and (bearReject or buyingAbsorbed or close < open)
bool bearProgressFailure = low >= recentLow and (bullReject or sellingAbsorbed or close > open)
int barsSinceBullProgressFailure = ta.barssince(bullProgressFailure)
int barsSinceBearProgressFailure = ta.barssince(bearProgressFailure)
bool recentBullProgressFailure = not na(barsSinceBullProgressFailure) and barsSinceBullProgressFailure <= failedAuctionMemory
bool recentBearProgressFailure = not na(barsSinceBearProgressFailure) and barsSinceBearProgressFailure <= failedAuctionMemory

//=============================================================================
// 21 — LOCATION STATES / WEIGHTING
//=============================================================================
bool nearVAH = f_near(activeVAH, atr, locationATR)
bool nearVAL = f_near(activeVAL, atr, locationATR)
bool nearPOC = f_near(activePOC, atr, locationATR)
bool nearPGH = usePreviousGlobexHL and f_near(previousGlobexHigh, atr, locationATR)
bool nearPGL = usePreviousGlobexHL and f_near(previousGlobexLow, atr, locationATR)
bool nearPWH = usePreviousWeek and f_near(pwh, atr, locationATR)
bool nearPWL = usePreviousWeek and f_near(pwl, atr, locationATR)
bool nearPAH = usePrevAsiaHL and f_near(prevAsiaH, atr, locationATR)
bool nearPAL = usePrevAsiaHL and f_near(prevAsiaL, atr, locationATR)
bool nearPLH = usePrevLondonHL and f_near(prevLondonH, atr, locationATR)
bool nearPLL = usePrevLondonHL and f_near(prevLondonL, atr, locationATR)
bool nearPNH = usePrevNyseHL and f_near(prevNyseH, atr, locationATR)
bool nearPNL = usePrevNyseHL and f_near(prevNyseL, atr, locationATR)
bool nearVWAP = f_near(futuresSessionVwap, atr, locationATR)
bool near1m200 = f_near(ema1mRegimeHtf, atr, locationATR)
bool near2m200 = f_near(ema2m200, atr, locationATR)
bool nearStructureHigh = f_near(priorResistance, atr, locationATR)
bool nearStructureLow = f_near(priorSupport, atr, locationATR)

float supportLocation = 0
float resistanceLocation = 0
string supportWhy = ""
string resistanceWhy = ""

if nearVAH
    if close >= activeVAH
        supportLocation += 5
        supportWhy += "VAH; "
    if close <= activeVAH
        resistanceLocation += 5
        resistanceWhy += "VAH; "
if nearVAL
    if close >= activeVAL
        supportLocation += 5
        supportWhy += "VAL; "
    if close <= activeVAL
        resistanceLocation += 5
        resistanceWhy += "VAL; "
if nearPOC
    if close >= activePOC
        supportLocation += 4
        supportWhy += "POC; "
    if close <= activePOC
        resistanceLocation += 4
        resistanceWhy += "POC; "

// Globex/week retain higher weighting.
if nearPGH
    if close >= previousGlobexHigh
        supportLocation += 4.5
        supportWhy += "PGH; "
    if close <= previousGlobexHigh
        resistanceLocation += 4.5
        resistanceWhy += "PGH; "
if nearPGL
    if close >= previousGlobexLow
        supportLocation += 4.5
        supportWhy += "PGL; "
    if close <= previousGlobexLow
        resistanceLocation += 4.5
        resistanceWhy += "PGL; "
if nearPWH
    if close >= pwh
        supportLocation += 4.5
        supportWhy += "PWH; "
    if close <= pwh
        resistanceLocation += 4.5
        resistanceWhy += "PWH; "
if nearPWL
    if close >= pwl
        supportLocation += 4.5
        supportWhy += "PWL; "
    if close <= pwl
        resistanceLocation += 4.5
        resistanceWhy += "PWL; "

// Previous NYSE > London > Asia by default.
if nearPNH
    if close >= prevNyseH
        supportLocation += 4.0
        supportWhy += "P-NYSE-H; "
    if close <= prevNyseH
        resistanceLocation += 4.0
        resistanceWhy += "P-NYSE-H; "
if nearPNL
    if close >= prevNyseL
        supportLocation += 4.0
        supportWhy += "P-NYSE-L; "
    if close <= prevNyseL
        resistanceLocation += 4.0
        resistanceWhy += "P-NYSE-L; "
if nearPLH
    if close >= prevLondonH
        supportLocation += 3.5
        supportWhy += "P-LON-H; "
    if close <= prevLondonH
        resistanceLocation += 3.5
        resistanceWhy += "P-LON-H; "
if nearPLL
    if close >= prevLondonL
        supportLocation += 3.5
        supportWhy += "P-LON-L; "
    if close <= prevLondonL
        resistanceLocation += 3.5
        resistanceWhy += "P-LON-L; "
if nearPAH
    if close >= prevAsiaH
        supportLocation += 3.0
        supportWhy += "P-ASIA-H; "
    if close <= prevAsiaH
        resistanceLocation += 3.0
        resistanceWhy += "P-ASIA-H; "
if nearPAL
    if close >= prevAsiaL
        supportLocation += 3.0
        supportWhy += "P-ASIA-L; "
    if close <= prevAsiaL
        resistanceLocation += 3.0
        resistanceWhy += "P-ASIA-L; "

if nearStructureLow
    supportLocation += 4
    supportWhy += "Structure; "
if nearStructureHigh
    resistanceLocation += 4
    resistanceWhy += "Structure; "
if nearVWAP
    if close >= futuresSessionVwap
        supportLocation += 3.5
        supportWhy += "VWAP; "
    if close <= futuresSessionVwap
        resistanceLocation += 3.5
        resistanceWhy += "VWAP; "
if near1m200
    if close >= ema1mRegimeHtf
        supportLocation += 3
        supportWhy += "1m200; "
    if close <= ema1mRegimeHtf
        resistanceLocation += 3
        resistanceWhy += "1m200; "
if near2m200
    if close >= ema2m200
        supportLocation += 2.5
        supportWhy += "2m200; "
    if close <= ema2m200
        resistanceLocation += 2.5
        resistanceWhy += "2m200; "
supportLocation := math.min(supportLocation, 10)
resistanceLocation := math.min(resistanceLocation, 10)

//=============================================================================
// 22 — AUCTION STATE / PRESSURE
//=============================================================================
bool aboveVAH = not na(activeVAH) and close > activeVAH
bool belowVAL = not na(activeVAL) and close < activeVAL
int closesAboveVAH = f_countTrue(aboveVAH, acceptanceLookback)
int closesBelowVAL = f_countTrue(belowVAL, acceptanceLookback)
bool acceptedAboveVAH = aboveVAH and closesAboveVAH >= acceptanceCloses
bool acceptedBelowVAL = belowVAL and closesBelowVAL >= acceptanceCloses
bool excursionAboveVAH = not na(activeVAH) and high > activeVAH and not acceptedAboveVAH
bool excursionBelowVAL = not na(activeVAL) and low < activeVAL and not acceptedBelowVAL
bool failedAuctionAboveVAH = not na(activeVAH) and high > activeVAH and close < activeVAH and (buyingAbsorbed or bearReject or rsiROC < 0)
bool failedAuctionBelowVAL = not na(activeVAL) and low < activeVAL and close > activeVAL and (sellingAbsorbed or bullReject or rsiROC > 0)
int barsSinceFailedVAH = ta.barssince(failedAuctionAboveVAH)
int barsSinceFailedVAL = ta.barssince(failedAuctionBelowVAL)
bool recentFailedVAH = not na(barsSinceFailedVAH) and barsSinceFailedVAH <= failedAuctionMemory
bool recentFailedVAL = not na(barsSinceFailedVAL) and barsSinceFailedVAL <= failedAuctionMemory
string auctionState = acceptedAboveVAH ? "ACCEPT > VAH" : acceptedBelowVAL ? "ACCEPT < VAL" : failedAuctionAboveVAH ? "FAIL > VAH" : failedAuctionBelowVAL ? "FAIL < VAL" : excursionAboveVAH ? "TEST > VAH" : excursionBelowVAL ? "TEST < VAL" : "INSIDE VALUE"

bool resistanceTest = not na(priorResistance) and high >= priorResistance - atr * boundaryToleranceATR
bool supportTest = not na(priorSupport) and low <= priorSupport + atr * boundaryToleranceATR
int resistanceTests = f_countTrue(resistanceTest, pressureTestLookback)
int supportTests = f_countTrue(supportTest, pressureTestLookback)
bool repeatedResistancePressure = resistanceTests >= minimumBoundaryTests
bool repeatedSupportPressure = supportTests >= minimumBoundaryTests
bool bullPressureShape = higherLow and repeatedResistancePressure
bool bearPressureShape = lowerHigh and repeatedSupportPressure
float compressionRange = ta.highest(high, structureLookback) - ta.lowest(low, structureLookback)
float compressionRangeATR = atr > 0 ? compressionRange / atr : 0
bool majorHTFClose = (timeframe.change("15") ? 1 : 0) + (timeframe.change("30") ? 1 : 0) + (timeframe.change("60") ? 1 : 0) + (timeframe.change("240") ? 1 : 0) >= 3
float pressureScore = 0
if squeezeOn
    pressureScore += 20
if prolongedCompression
    pressureScore += 15
if squeezeBars >= 12
    pressureScore += 20
else if squeezeBars >= 6
    pressureScore += 10
if bullPressureShape or bearPressureShape
    pressureScore += 20
if math.abs(sqzMomentum) <= atr * 0.50
    pressureScore += 10
if compressionRangeATR <= 3
    pressureScore += 10
if majorHTFClose
    pressureScore += 5
pressureScore := math.min(pressureScore, 100)
string energyState = squeezeOn and pressureScore >= 70 ? "PRESSURIZED" : squeezeOn ? "COMPRESSED" : squeezeFired ? "EARLY EXPANSION" : sqzBullReAccel ? "BULL RE-EXPAND" : sqzBearReAccel ? "BEAR RE-EXPAND" : sqzBullAccel ? "BULL EXPAND" : sqzBearAccel ? "BEAR EXPAND" : sqzBullDecel ? "BULL DECEL" : sqzBearDecel ? "BEAR DECEL" : "NEUTRAL"

//=============================================================================
// 23 — STRUCTURE SHIFT / RETEST
//=============================================================================
bool bearishStructureShift = microBearBreak and (recentBullProgressFailure or recentFailedVAH or buyingAbsorbed or bearishDisagreement or recentRsiBearDiv)
bool bullishStructureShift = microBullBreak and (recentBearProgressFailure or recentFailedVAL or sellingAbsorbed or bullishDisagreement or recentRsiBullDiv)
int barsSinceBearShift = ta.barssince(bearishStructureShift)
int barsSinceBullShift = ta.barssince(bullishStructureShift)
bool recentBearShift = not na(barsSinceBearShift) and barsSinceBearShift <= structureBreakMemory
bool recentBullShift = not na(barsSinceBullShift) and barsSinceBullShift <= structureBreakMemory
float bearShiftLevel = ta.valuewhen(bearishStructureShift, microSupport, 0)
float bullShiftLevel = ta.valuewhen(bullishStructureShift, microResistance, 0)
bool bearShiftRetest = recentBearShift and ((high >= ema1mRegimeHtf - atr * locationATR and close < ema1mRegimeHtf) or (not na(bearShiftLevel) and high >= bearShiftLevel - atr * locationATR and close < bearShiftLevel))
bool bullShiftRetest = recentBullShift and ((low <= ema1mRegimeHtf + atr * locationATR and close > ema1mRegimeHtf) or (not na(bullShiftLevel) and low <= bullShiftLevel + atr * locationATR and close > bullShiftLevel))

//=============================================================================
// 24 — ROOM / STOPS
//=============================================================================
float nearestAbove = na
float nearestBelow = na
nearestAbove := f_above(priorResistance, nearestAbove)
nearestBelow := f_below(priorSupport, nearestBelow)
nearestAbove := f_above(activeVAH, nearestAbove)
nearestAbove := f_above(activePOC, nearestAbove)
nearestAbove := f_above(activeVAL, nearestAbove)
nearestBelow := f_below(activeVAH, nearestBelow)
nearestBelow := f_below(activePOC, nearestBelow)
nearestBelow := f_below(activeVAL, nearestBelow)
if usePreviousGlobexHL
    nearestAbove := f_above(previousGlobexHigh, nearestAbove)
    nearestAbove := f_above(previousGlobexLow, nearestAbove)
    nearestBelow := f_below(previousGlobexHigh, nearestBelow)
    nearestBelow := f_below(previousGlobexLow, nearestBelow)
if usePreviousWeek
    nearestAbove := f_above(pwh, nearestAbove)
    nearestAbove := f_above(pwl, nearestAbove)
    nearestBelow := f_below(pwh, nearestBelow)
    nearestBelow := f_below(pwl, nearestBelow)
if usePrevAsiaHL
    nearestAbove := f_above(prevAsiaH, nearestAbove)
    nearestAbove := f_above(prevAsiaL, nearestAbove)
    nearestBelow := f_below(prevAsiaH, nearestBelow)
    nearestBelow := f_below(prevAsiaL, nearestBelow)
if usePrevLondonHL
    nearestAbove := f_above(prevLondonH, nearestAbove)
    nearestAbove := f_above(prevLondonL, nearestAbove)
    nearestBelow := f_below(prevLondonH, nearestBelow)
    nearestBelow := f_below(prevLondonL, nearestBelow)
if usePrevNyseHL
    nearestAbove := f_above(prevNyseH, nearestAbove)
    nearestAbove := f_above(prevNyseL, nearestAbove)
    nearestBelow := f_below(prevNyseH, nearestBelow)
    nearestBelow := f_below(prevNyseL, nearestBelow)

f_longRoom(float risk) =>
    float result = 0
    if not na(risk) and risk > 0
        float roomPts = na(nearestAbove) ? risk * 10 : nearestAbove - close
        result := roomPts / risk
    result

f_shortRoom(float risk) =>
    float result = 0
    if not na(risk) and risk > 0
        float roomPts = na(nearestBelow) ? risk * 10 : close - nearestBelow
        result := roomPts / risk
    result

float contLongBase = ta.lowest(low, microLookback)
float contShortBase = ta.highest(high, microLookback)
float mrFallbackLow = ta.lowest(low, 3)
float mrFallbackHigh = ta.highest(high, 3)
float contLongStop = contLongBase - atr * stopBufferATR
float contShortStop = contShortBase + atr * stopBufferATR
float mrLongStop = freshSweepLow and not na(lastSweepLow) ? lastSweepLow - atr * stopBufferATR : mrFallbackLow - atr * stopBufferATR
float mrShortStop = freshSweepHigh and not na(lastSweepHigh) ? lastSweepHigh + atr * stopBufferATR : mrFallbackHigh + atr * stopBufferATR

float contLongRisk = f_longRisk(contLongStop)
float contShortRisk = f_shortRisk(contShortStop)
float mrLongRisk = f_longRisk(mrLongStop)
float mrShortRisk = f_shortRisk(mrShortStop)
float contLongRoom = f_longRoom(contLongRisk)
float contShortRoom = f_shortRoom(contShortRisk)
float mrLongRoom = f_longRoom(mrLongRisk)
float mrShortRoom = f_shortRoom(mrShortRisk)

//=============================================================================
// 25 — PULLBACK STATE / EVIDENCE MODIFIERS
//=============================================================================
float longTouchStrength = supportLocation
float shortTouchStrength = resistanceLocation
if near1m200
    longTouchStrength := math.max(longTouchStrength, 4)
    shortTouchStrength := math.max(shortTouchStrength, 4)
if near2m200
    longTouchStrength := math.max(longTouchStrength, 3.5)
    shortTouchStrength := math.max(shortTouchStrength, 3.5)
if low <= laserFastEma
    longTouchStrength := math.max(longTouchStrength, 2.5)
if low <= laserTrendEma
    longTouchStrength := math.max(longTouchStrength, 3)
if high >= laserFastEma
    shortTouchStrength := math.max(shortTouchStrength, 2.5)
if high >= laserTrendEma
    shortTouchStrength := math.max(shortTouchStrength, 3)

bool continuationLongContext = bullTrend or acceptedAboveVAH
bool continuationShortContext = bearTrend or acceptedBelowVAL
bool longPullbackTouch = continuationLongContext and longTouchStrength >= 2.5
bool shortPullbackTouch = continuationShortContext and shortTouchStrength >= 2.5
int barsSinceLongPB = ta.barssince(longPullbackTouch)
int barsSinceShortPB = ta.barssince(shortPullbackTouch)
bool recentLongPB = not na(barsSinceLongPB) and barsSinceLongPB <= 3
bool recentShortPB = not na(barsSinceShortPB) and barsSinceShortPB <= 3
float longTouchScore = nz(ta.valuewhen(longPullbackTouch, longTouchStrength, 0), 0)
float shortTouchScore = nz(ta.valuewhen(shortPullbackTouch, shortTouchStrength, 0), 0)
bool longReAccel = rsiROC > 0 and (sqzBullAccel or sqzBullReAccel or bullImpulse)
bool shortReAccel = rsiROC < 0 and (sqzBearAccel or sqzBearReAccel or bearImpulse)

int bullDeterioration = (rsiSharpDown ? 1 : 0) + (sqzBullDecel ? 1 : 0) + (bearishDisagreement ? 1 : 0) + (bullProgressFailure ? 1 : 0) + (recentRsiBearDiv ? 1 : 0)
int bearDeterioration = (rsiSharpUp ? 1 : 0) + (sqzBearDecel ? 1 : 0) + (bullishDisagreement ? 1 : 0) + (bearProgressFailure ? 1 : 0) + (recentRsiBullDiv ? 1 : 0)

bool sweepLongEvidence = useSweepEvidence and freshSweepLow
bool sweepShortEvidence = useSweepEvidence and freshSweepHigh
bool exhaustionLongEvidence = useExhaustionEvidence and matureBearImpulse and bearDeterioration >= 2
bool exhaustionShortEvidence = useExhaustionEvidence and matureBullImpulse and bullDeterioration >= 2
bool absorptionLongEvidence = useAbsorptionEvidence and sellingAbsorbed
bool absorptionShortEvidence = useAbsorptionEvidence and buyingAbsorbed
bool structureLongEvidence = useStructureRetestEvidence and bullShiftRetest
bool structureShortEvidence = useStructureRetestEvidence and bearShiftRetest
bool rsiDivLongEvidence = useRsiDivEvidence and recentRsiBullDiv
bool rsiDivShortEvidence = useRsiDivEvidence and recentRsiBearDiv
bool failedAuctionLongEvidence = useFailedAuctionEvidence and recentFailedVAL
bool failedAuctionShortEvidence = useFailedAuctionEvidence and recentFailedVAH
bool breakoutLongEvidence = useBreakoutAcceptanceEvidence and acceptedAboveVAH
bool breakoutShortEvidence = useBreakoutAcceptanceEvidence and acceptedBelowVAL
bool squeezeLongEvidence = recentRelease or squeezeFired or sqzBullReAccel
bool squeezeShortEvidence = recentRelease or squeezeFired or sqzBearReAccel
bool supportedVolume = relativeVolume >= 1.50
bool highVolume = relativeVolume >= 1.75
bool extremeVolume = relativeVolume >= 2.25

// RSI divergence quality / synergy. These remain modifiers; none can create an
// excursion, reaction or change-of-state by themselves.
bool divLongStrong = rsiDivLongEvidence and bullDivStrongPrice
bool divShortStrong = rsiDivShortEvidence and bearDivStrongPrice
bool divLongZone = rsiDivLongEvidence and bullDivInZone
bool divShortZone = rsiDivShortEvidence and bearDivInZone
bool divLongExhaustionCombo = rsiDivLongEvidence and exhaustionLongEvidence
bool divShortExhaustionCombo = rsiDivShortEvidence and exhaustionShortEvidence
bool divLongFailedAuctionCombo = rsiDivLongEvidence and failedAuctionLongEvidence
bool divShortFailedAuctionCombo = rsiDivShortEvidence and failedAuctionShortEvidence

bool meaningfulLongExtreme = matureBearImpulse and (nearVAL or nearPGL or nearPWL or nearPNL or nearPLL or nearPAL or freshSweepLow or supportLocation >= 4)
bool meaningfulShortExtreme = matureBullImpulse and (nearVAH or nearPGH or nearPWH or nearPNH or nearPLH or nearPAH or freshSweepHigh or resistanceLocation >= 4)

bool contTrendLongBase = enableContinuation and bullTrend and recentLongPB and longReAccel and close > laserFastEma
bool contTrendShortBase = enableContinuation and bearTrend and recentShortPB and shortReAccel and close < laserFastEma
bool contStructLongBase = enableContinuation and structureLongEvidence and rsiROC > 0 and (sqzBearDecel or sqzBullAccel or bullImpulse)
bool contStructShortBase = enableContinuation and structureShortEvidence and rsiROC < 0 and (sqzBullDecel or sqzBearAccel or bearImpulse)
bool continuationLongEligible = (contTrendLongBase or contStructLongBase) and not hardBalanceRegime
bool continuationShortEligible = (contTrendShortBase or contStructShortBase) and not hardBalanceRegime

// MR is deliberately strict: a genuine extreme must exist first.
// Sweep/exhaustion are evidence about that excursion, not substitutes for it.
// A sweep by itself also cannot satisfy the reaction gate.
bool mrLongReaction = absorptionLongEvidence or bullReject or failedAuctionLongEvidence
bool mrShortReaction = absorptionShortEvidence or bearReject or failedAuctionShortEvidence
bool mrLongMomentumRotation = sqzBearDecel or rsiSharpUp or bullishDisagreement or bullZeroCross or rsiDivLongEvidence
bool mrShortMomentumRotation = sqzBullDecel or rsiSharpDown or bearishDisagreement or bearZeroCross or rsiDivShortEvidence
bool mrLongChangeState = microBullBreak or bullImpulse or bullZeroCross
bool mrShortChangeState = microBearBreak or bearImpulse or bearZeroCross
bool mrLongExcursion = meaningfulLongExtreme
bool mrShortExcursion = meaningfulShortExtreme
bool meanReversionLongEligible = enableMeanReversion and mrLongExcursion and mrLongReaction and mrLongMomentumRotation and mrLongChangeState
bool meanReversionShortEligible = enableMeanReversion and mrShortExcursion and mrShortReaction and mrShortMomentumRotation and mrShortChangeState

//=============================================================================
// 26 — CONTINUATION / MEAN-REVERSION SCORING
// Selective baseline retained. Divergence quality adds modest confirmation weight,
// but modifiers cannot manufacture the required setup sequence by themselves.
//=============================================================================
float continuationLongScore = 0
float continuationShortScore = 0

if contTrendLongBase
    continuationLongScore += math.min(longTouchScore * 2, 20) + bullTrendScore * 5
    if higherLow
        continuationLongScore += 10
    if sqzBullReAccel
        continuationLongScore += 10
    if absorptionLongEvidence
        continuationLongScore += 12
    if finalBullMove
        continuationLongScore += 10
    if rsiDivLongEvidence
        continuationLongScore += 5
    if divLongStrong
        continuationLongScore += 3
    if divLongZone
        continuationLongScore += 1
    if divLongExhaustionCombo
        continuationLongScore += 2
    if divLongFailedAuctionCombo
        continuationLongScore += 2
    if absorptionShortEvidence or finalBearMove
        continuationLongScore -= 10
    if f_riskPass(contLongRisk) and contLongRoom >= minimumRoomR
        continuationLongScore += 15

if contStructLongBase
    float structureScoreLong = 55
    if absorptionLongEvidence
        structureScoreLong += 12
    if near1m200
        structureScoreLong += 12
    if nearVWAP
        structureScoreLong += 8
    if sqzBearDecel
        structureScoreLong += 8
    if sqzBullAccel
        structureScoreLong += 10
    if finalBullMove
        structureScoreLong += 10
    if rsiDivLongEvidence
        structureScoreLong += 5
    if divLongStrong
        structureScoreLong += 3
    if divLongZone
        structureScoreLong += 1
    if divLongExhaustionCombo
        structureScoreLong += 2
    if divLongFailedAuctionCombo
        structureScoreLong += 2
    if structureScoreLong > continuationLongScore
        continuationLongScore := structureScoreLong

if contTrendShortBase
    continuationShortScore += math.min(shortTouchScore * 2, 20) + bearTrendScore * 5
    if lowerHigh
        continuationShortScore += 10
    if sqzBearReAccel
        continuationShortScore += 10
    if absorptionShortEvidence
        continuationShortScore += 12
    if finalBearMove
        continuationShortScore += 10
    if rsiDivShortEvidence
        continuationShortScore += 5
    if divShortStrong
        continuationShortScore += 3
    if divShortZone
        continuationShortScore += 1
    if divShortExhaustionCombo
        continuationShortScore += 2
    if divShortFailedAuctionCombo
        continuationShortScore += 2
    if absorptionLongEvidence or finalBullMove
        continuationShortScore -= 10
    if f_riskPass(contShortRisk) and contShortRoom >= minimumRoomR
        continuationShortScore += 15

if contStructShortBase
    float structureScoreShort = 55
    if absorptionShortEvidence
        structureScoreShort += 12
    if near1m200
        structureScoreShort += 12
    if nearVWAP
        structureScoreShort += 8
    if sqzBullDecel
        structureScoreShort += 8
    if sqzBearAccel
        structureScoreShort += 10
    if finalBearMove
        structureScoreShort += 10
    if rsiDivShortEvidence
        structureScoreShort += 5
    if divShortStrong
        structureScoreShort += 3
    if divShortZone
        structureScoreShort += 1
    if divShortExhaustionCombo
        structureScoreShort += 2
    if divShortFailedAuctionCombo
        structureScoreShort += 2
    if structureScoreShort > continuationShortScore
        continuationShortScore := structureScoreShort

continuationLongScore := math.max(0, math.min(continuationLongScore, 100))
continuationShortScore := math.max(0, math.min(continuationShortScore, 100))

float meanReversionLongScore = 0
float meanReversionShortScore = 0

if meanReversionLongEligible
    meanReversionLongScore += 25 + math.min(supportLocation * 2, 20)
    if matureBearMomentum
        meanReversionLongScore += 10
    if absorptionLongEvidence
        meanReversionLongScore += 20
    if bearProgressFailure
        meanReversionLongScore += 10
    if sqzBearDecel
        meanReversionLongScore += 10
    if rsiSharpUp
        meanReversionLongScore += 8
    if rsiDivLongEvidence
        meanReversionLongScore += 8
    if divLongStrong
        meanReversionLongScore += 4
    if divLongZone
        meanReversionLongScore += 2
    if divLongExhaustionCombo
        meanReversionLongScore += 3
    if divLongFailedAuctionCombo
        meanReversionLongScore += 4
    if microBullBreak
        meanReversionLongScore += 10
    if bullZeroCross
        meanReversionLongScore += 8
    if finalBearMove
        meanReversionLongScore -= 15
    if f_riskPass(mrLongRisk) and mrLongRoom >= minimumRoomR
        meanReversionLongScore += 10

if meanReversionShortEligible
    meanReversionShortScore += 25 + math.min(resistanceLocation * 2, 20)
    if matureBullMomentum
        meanReversionShortScore += 10
    if absorptionShortEvidence
        meanReversionShortScore += 20
    if bullProgressFailure
        meanReversionShortScore += 10
    if sqzBullDecel
        meanReversionShortScore += 10
    if rsiSharpDown
        meanReversionShortScore += 8
    if rsiDivShortEvidence
        meanReversionShortScore += 8
    if divShortStrong
        meanReversionShortScore += 4
    if divShortZone
        meanReversionShortScore += 2
    if divShortExhaustionCombo
        meanReversionShortScore += 3
    if divShortFailedAuctionCombo
        meanReversionShortScore += 4
    if microBearBreak
        meanReversionShortScore += 10
    if bearZeroCross
        meanReversionShortScore += 8
    if finalBullMove
        meanReversionShortScore -= 15
    if f_riskPass(mrShortRisk) and mrShortRoom >= minimumRoomR
        meanReversionShortScore += 10

meanReversionLongScore := math.max(0, math.min(meanReversionLongScore, 100))
meanReversionShortScore := math.max(0, math.min(meanReversionShortScore, 100))

//=============================================================================
// 27 — ROUTER / DECISION
//=============================================================================
float requiredScore = preset == "Aggressive" ? 60 : preset == "Conservative" ? 80 : 70

float bestLongScore = 0
string bestLongCode = ""
if continuationLongEligible and continuationLongScore > bestLongScore
    bestLongScore := continuationLongScore
    bestLongCode := "C"
if meanReversionLongEligible and meanReversionLongScore > bestLongScore
    bestLongScore := meanReversionLongScore
    bestLongCode := "MR"

float bestShortScore = 0
string bestShortCode = ""
if continuationShortEligible and continuationShortScore > bestShortScore
    bestShortScore := continuationShortScore
    bestShortCode := "C"
if meanReversionShortEligible and meanReversionShortScore > bestShortScore
    bestShortScore := meanReversionShortScore
    bestShortCode := "MR"

float bestLongStop = bestLongCode == "C" ? contLongStop : bestLongCode == "MR" ? mrLongStop : na
float bestShortStop = bestShortCode == "C" ? contShortStop : bestShortCode == "MR" ? mrShortStop : na
float bestLongRisk = f_longRisk(bestLongStop)
float bestShortRisk = f_shortRisk(bestShortStop)
float bestLongRoom = f_longRoom(bestLongRisk)
float bestShortRoom = f_shortRoom(bestShortRisk)

bool haveQualifiedLong = bestLongCode != "" and bestLongScore >= requiredScore
bool haveQualifiedShort = bestShortCode != "" and bestShortScore >= requiredScore
string thesisState = hardBalanceRegime and not haveQualifiedLong and not haveQualifiedShort ? "WAIT — BALANCE" : haveQualifiedLong and not haveQualifiedShort ? "LONG " + bestLongCode : haveQualifiedShort and not haveQualifiedLong ? "SHORT " + bestShortCode : haveQualifiedLong and haveQualifiedShort ? (bestLongScore > bestShortScore ? "LONG " + bestLongCode : bestShortScore > bestLongScore ? "SHORT " + bestShortCode : "CONFLICT") : "WAIT"

// Viewport-dependent VP modes are live-only; developing Globex can evaluate normally.
bool vpSignalAllowed = not liveOnlyVpMode or barstate.islast

//=============================================================================
// 28 — FIRE / ACTIVE TRADE STATE
//=============================================================================
// Lightweight live state only. Historical research counters are intentionally
// absent from the cockpit build.
var bool tradeActive = false
var int tradeDirectionState = 0
var int tradeEntryBar = na
var float tradeEntry = na
var float tradeStop = na
var float tradeTP1 = na
var float tradeTP2 = na
var float tradeRisk = na
var float tradeScore = na
var string tradeCode = ""
var string tradeGrade = ""
var string tradeReason = ""
var string tradeModifiers = ""
var bool tradeTP1Done = false
var int lastSignalBar = na
var string lastTradeSummary = "—"

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var label latestTradeLabel = na
var label latestOutcomeLabel = na

int visibleSignalBars = math.max(1, math.round((visibleRightTime - visibleLeftTime) / barDurationMS) + 1)
signalTabTextSize = switch signalTabSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => visibleSignalBars >= 140 ? size.tiny : visibleSignalBars >= 70 ? size.small : size.normal

f_modifiers(bool sw, bool exh, bool absb, bool strc, bool div, bool fa, bool boa, bool sqz, bool hv, bool strongDiv) =>
    string t = ""
    if div
        t += strongDiv ? "DIV+ " : "DIV "
    if exh
        t += "EXH "
    if fa
        t += "FA "
    if sw
        t += "SW "
    if strc
        t += "STR "
    if absb
        t += "ABS "
    if boa
        t += "BOA "
    if sqz
        t += "SQZ "
    if hv
        t += "HV "
    t == "" ? "—" : t

f_grade(float score, bool divPresent, bool divStrongPriceNow, bool divExh, bool divFa) =>
    string g = score >= 90 ? "A+" : score >= 80 ? "A" : "B"
    if divPresent and divStrongPriceNow and (divExh or divFa)
        g := "A+"
    else if divPresent and (divStrongPriceNow or divExh or divFa) and g == "B"
        g := "A"
    g

f_divHud(bool recentDiv, bool strongPriceDiv, bool inZone, int age, float priceAtr) =>
    string d = "—"
    if recentDiv
        d := strongPriceDiv ? "DIV+" : "DIV"
        d += " a" + str.tostring(age)
        if not na(priceAtr)
            d += " " + str.tostring(priceAtr, "#.2") + "A"
        if inZone
            d += " Z"
    d

bool barAllowed = (not requireClosedBar or barstate.isconfirmed) and vpSignalAllowed
bool cooldownComplete = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldown
bool allowLong = tradeDirection != "Short Only"
bool allowShort = tradeDirection != "Long Only"
bool longQualified = not tradeActive and allowLong and barAllowed and cooldownComplete and haveQualifiedLong and f_riskPass(bestLongRisk) and bestLongRoom >= minimumRoomR
bool shortQualified = not tradeActive and allowShort and barAllowed and cooldownComplete and haveQualifiedShort and f_riskPass(bestShortRisk) and bestShortRoom >= minimumRoomR
bool longFire = longQualified and (not shortQualified or bestLongScore > bestShortScore)
bool shortFire = shortQualified and (not longQualified or bestShortScore > bestLongScore)

if longFire or shortFire
    bool fireLong = longFire
    float fireScore = fireLong ? bestLongScore : bestShortScore
    string fireCode = fireLong ? bestLongCode : bestShortCode
    float fireStop = fireLong ? bestLongStop : bestShortStop
    float fireRisk = fireLong ? bestLongRisk : bestShortRisk
    float fireRoom = fireLong ? bestLongRoom : bestShortRoom
    float fireLocation = fireLong ? supportLocation : resistanceLocation
    string fireWhy = fireLong ? supportWhy : resistanceWhy

    bool fireSweep = fireLong ? sweepLongEvidence : sweepShortEvidence
    bool fireExhaustion = fireLong ? exhaustionLongEvidence : exhaustionShortEvidence
    bool fireAbsorption = fireLong ? absorptionLongEvidence : absorptionShortEvidence
    bool fireStructure = fireLong ? structureLongEvidence : structureShortEvidence
    bool fireDiv = fireLong ? rsiDivLongEvidence : rsiDivShortEvidence
    bool fireFa = fireLong ? failedAuctionLongEvidence : failedAuctionShortEvidence
    bool fireBoa = fireLong ? breakoutLongEvidence : breakoutShortEvidence
    bool fireSqz = fireLong ? squeezeLongEvidence : squeezeShortEvidence
    bool fireStrongDiv = fireLong ? divLongStrong : divShortStrong
    bool fireDivZone = fireLong ? divLongZone : divShortZone
    bool fireDivExh = fireLong ? divLongExhaustionCombo : divShortExhaustionCombo
    bool fireDivFa = fireLong ? divLongFailedAuctionCombo : divShortFailedAuctionCombo
    int fireDivAge = fireDiv ? (fireLong ? barsSinceRsiBullDiv : barsSinceRsiBearDiv) : na
    float fireDivGap = fireDiv ? (fireLong ? lastBullDivRsiGap : lastBearDivRsiGap) : na
    float fireDivPriceAtr = fireDiv ? (fireLong ? lastBullDivPriceAtr : lastBearDivPriceAtr) : na
    float fireDivPivotRsi = fireDiv ? (fireLong ? lastBullDivPivotRsi : lastBearDivPivotRsi) : na

    string mods = f_modifiers(fireSweep, fireExhaustion, fireAbsorption, fireStructure, fireDiv, fireFa, fireBoa, fireSqz, highVolume, fireStrongDiv)
    string grade = f_grade(fireScore, fireDiv, fireStrongDiv, fireDivExh, fireDivFa)
    string thesisExplanation = fireCode == "MR" ? "STRICT MR: genuine excursion + reaction + momentum rotation + change of state." : "CONTINUATION: pullback is resolving with the prevailing directional auction."

    string reason = (fireLong ? "LASER LONG " : "LASER SHORT ") + fireCode + "  [" + grade + "]"
    reason += "\n" + thesisExplanation
    reason += "\nScore: " + str.tostring(fireScore, "#.0") + "/100  |  Required: " + str.tostring(requiredScore, "#")
    reason += "\nModifiers: " + mods
    reason += "\n\nRegime: " + regime + "  |  Balance: " + str.tostring(balanceScore, "#") + "%"
    reason += "\nAuction: " + auctionState + "  |  Energy: " + energyState
    reason += "\nLocation: " + str.tostring(fireLocation, "#.0") + "/10  |  " + (fireWhy == "" ? "No named level" : fireWhy)
    reason += "\nVolume: " + str.tostring(relativeVolume, "#.00") + "x"
    reason += "\nRSI: " + str.tostring(rsi, "#.1") + "  Δ " + str.tostring(rsiROC, "#.00") + "  A " + str.tostring(rsiAccel, "#.00")
    if fireDiv
        reason += "\n\nRSI DIVERGENCE CONFIRMATION"
        reason += "\nAge: " + str.tostring(fireDivAge) + " bars since confirmation"
        reason += "\nPrice overshoot: " + str.tostring(fireDivPriceAtr, "#.2") + " ATR" + (fireStrongDiv ? "  [STRONG]" : "")
        reason += "\nRSI pivot separation: " + str.tostring(fireDivGap, "#.1") + " points"
        reason += "\nSecond-pivot RSI: " + str.tostring(fireDivPivotRsi, "#.1") + (fireDivZone ? "  [ZONE]" : "")
        if fireDivExh
            reason += "\nDIV + exhaustion confluence"
        if fireDivFa
            reason += "\nDIV + failed-auction confluence"
    reason += "\nSQZ: " + str.tostring(sqzMomentum, "#.00") + "  Δ " + str.tostring(sqzROC, "#.00") + "  A " + str.tostring(sqzAccel, "#.00")
    reason += "\n\nRisk: " + str.tostring(fireRisk, "#.1") + " pts  |  Room: " + str.tostring(fireRoom, "#.2") + "R"
    reason += "\nEntry: " + str.tostring(close, format.mintick) + "  |  SL: " + str.tostring(fireStop, format.mintick)
    reason += "\nTP1: " + str.tostring(fireLong ? close + fireRisk * tp1R : close - fireRisk * tp1R, format.mintick)

    tradeActive := true
    tradeDirectionState := fireLong ? 1 : -1
    tradeEntryBar := bar_index
    tradeEntry := close
    tradeStop := fireStop
    tradeRisk := fireRisk
    tradeTP1 := fireLong ? tradeEntry + tradeRisk * tp1R : tradeEntry - tradeRisk * tp1R
    tradeTP2 := fireLong ? tradeEntry + tradeRisk * tp2R : tradeEntry - tradeRisk * tp2R
    tradeScore := fireScore
    tradeCode := fireCode
    tradeGrade := grade
    tradeReason := reason
    tradeModifiers := mods
    tradeTP1Done := false
    lastSignalBar := bar_index
    lastTradeSummary := (fireLong ? "L " : "S ") + fireCode + " " + grade + " ACTIVE"

    if signalDisplayMode != "Off"
        if signalDisplayMode == "Latest Only"
            if not na(latestTradeLabel)
                label.delete(latestTradeLabel)
            if not na(latestOutcomeLabel)
                label.delete(latestOutcomeLabel)
                latestOutcomeLabel := na
        string tabText = (fireLong ? "L " : "S ") + fireCode + " " + grade
        if signalTabTextMode == "With Modifiers" and mods != "—"
            tabText += "\n" + mods
        label newTradeLabel = label.new(bar_index, fireLong ? low : high, tabText, yloc = fireLong ? yloc.belowbar : yloc.abovebar, style = fireLong ? label.style_label_up : label.style_label_down, color = fireCode == "MR" ? color.new(color.orange, 0) : color.new(color.blue, 0), textcolor = color.white, size = signalTabTextSize, tooltip = reason)
        if signalDisplayMode == "Latest Only"
            latestTradeLabel := newTradeLabel

// Active trade horizontal levels.
if showActiveLevels and tradeActive
    int activeRight = bar_index + 10
    if na(entryLine)
        entryLine := line.new(tradeEntryBar, tradeEntry, activeRight, tradeEntry, xloc = xloc.bar_index, color = color.new(color.white, 15), width = 1)
        stopLine := line.new(tradeEntryBar, tradeStop, activeRight, tradeStop, xloc = xloc.bar_index, color = color.new(color.red, 0), width = 1)
        tp1Line := line.new(tradeEntryBar, tradeTP1, activeRight, tradeTP1, xloc = xloc.bar_index, color = color.new(color.green, 0), width = 1)
        if trackTP2
            tp2Line := line.new(tradeEntryBar, tradeTP2, activeRight, tradeTP2, xloc = xloc.bar_index, color = color.new(color.green, 45), width = 1)
    else
        line.set_xy2(entryLine, activeRight, tradeEntry)
        line.set_xy2(stopLine, activeRight, tradeStop)
        line.set_xy2(tp1Line, activeRight, tradeTP1)
        if trackTP2 and not na(tp2Line)
            line.set_xy2(tp2Line, activeRight, tradeTP2)

// Resolve only after the fire bar. Same-bar SL/TP ambiguity is not guessed.
if tradeActive and bar_index > tradeEntryBar
    bool stopTouched = tradeDirectionState == 1 ? low <= tradeStop : high >= tradeStop
    bool tp1Touched = tradeDirectionState == 1 ? high >= tradeTP1 : low <= tradeTP1
    bool tp2Touched = tradeDirectionState == 1 ? high >= tradeTP2 : low <= tradeTP2

    if not tradeTP1Done
        if stopTouched and tp1Touched
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " ?"
            if showOutcomes and signalDisplayMode != "Off"
                if signalDisplayMode == "Latest Only" and not na(latestOutcomeLabel)
                    label.delete(latestOutcomeLabel)
                label outLabel = label.new(bar_index, close, "?", yloc = yloc.price, style = label.style_label_left, color = color.orange, textcolor = color.white, size = signalTabTextSize, tooltip = "TP1 and SL were both touched inside the same chart bar; sequence is ambiguous.\n\n" + tradeReason)
                if signalDisplayMode == "Latest Only"
                    latestOutcomeLabel := outLabel
            tradeActive := false
        else if stopTouched
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " SL"
            if showOutcomes and signalDisplayMode != "Off"
                if signalDisplayMode == "Latest Only" and not na(latestOutcomeLabel)
                    label.delete(latestOutcomeLabel)
                label outLabel = label.new(bar_index, tradeStop, "SL", yloc = yloc.price, style = label.style_label_left, color = color.red, textcolor = color.white, size = signalTabTextSize, tooltip = "SL before TP1.\n\n" + tradeReason)
                if signalDisplayMode == "Latest Only"
                    latestOutcomeLabel := outLabel
            tradeActive := false
        else if tp1Touched
            tradeTP1Done := true
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " TP1✓"
            if showOutcomes and signalDisplayMode != "Off"
                if signalDisplayMode == "Latest Only" and not na(latestOutcomeLabel)
                    label.delete(latestOutcomeLabel)
                label outLabel = label.new(bar_index, tradeTP1, "TP1✓", yloc = yloc.price, style = label.style_label_left, color = color.green, textcolor = color.white, size = signalTabTextSize, tooltip = "TP1 reached.\n\n" + tradeReason)
                if signalDisplayMode == "Latest Only"
                    latestOutcomeLabel := outLabel
            if not trackTP2
                tradeActive := false
            else if tp2Touched
                lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " TP2✓"
                tradeActive := false
    else if trackTP2
        if stopTouched and tp2Touched
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " ?2"
            tradeActive := false
        else if tp2Touched
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " TP2✓"
            if showOutcomes and signalDisplayMode != "Off"
                if signalDisplayMode == "Latest Only" and not na(latestOutcomeLabel)
                    label.delete(latestOutcomeLabel)
                label outLabel = label.new(bar_index, tradeTP2, "TP2✓", yloc = yloc.price, style = label.style_label_left, color = color.new(color.green, 25), textcolor = color.white, size = signalTabTextSize, tooltip = "TP2 reached.\n\n" + tradeReason)
                if signalDisplayMode == "Latest Only"
                    latestOutcomeLabel := outLabel
            tradeActive := false
        else if stopTouched
            lastTradeSummary := (tradeDirectionState == 1 ? "L " : "S ") + tradeCode + " TP1✓→SL"
            tradeActive := false

if not tradeActive
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    entryLine := na
    stopLine := na
    tp1Line := na
    tp2Line := na

//=============================================================================
// 29 — TRADING COCKPIT HUD
//=============================================================================
string volumeTier = extremeVolume ? "EXT" : highVolume ? "HIGH" : supportedVolume ? "SUPP" : "—"
string volumeState = sellingAbsorbed ? "ABS SELL" : buyingAbsorbed ? "ABS BUY" : finalBullMove ? "BULL " + volumeTier : finalBearMove ? "BEAR " + volumeTier : volumeTier
string bullDivHud = f_divHud(recentRsiBullDiv, bullDivStrongPrice, bullDivInZone, barsSinceRsiBullDiv, lastBullDivPriceAtr)
string bearDivHud = f_divHud(recentRsiBearDiv, bearDivStrongPrice, bearDivInZone, barsSinceRsiBearDiv, lastBearDivPriceAtr)
string longModsNow = f_modifiers(sweepLongEvidence, exhaustionLongEvidence, absorptionLongEvidence, structureLongEvidence, rsiDivLongEvidence, failedAuctionLongEvidence, breakoutLongEvidence, squeezeLongEvidence, highVolume, divLongStrong)
string shortModsNow = f_modifiers(sweepShortEvidence, exhaustionShortEvidence, absorptionShortEvidence, structureShortEvidence, rsiDivShortEvidence, failedAuctionShortEvidence, breakoutShortEvidence, squeezeShortEvidence, highVolume, divShortStrong)
string longCandidate = bestLongCode == "" ? "—" : bestLongCode + " " + str.tostring(bestLongScore, "#")
string shortCandidate = bestShortCode == "" ? "—" : bestShortCode + " " + str.tostring(bestShortScore, "#")
string longRiskHud = not na(bestLongRisk) ? str.tostring(bestLongRisk, "#.0") + "p / " + str.tostring(bestLongRoom, "#.1") + "R" : "—"
string shortRiskHud = not na(bestShortRisk) ? str.tostring(bestShortRisk, "#.0") + "p / " + str.tostring(bestShortRoom, "#.1") + "R" : "—"
string statusText = tradeActive ? "ACTIVE" : thesisState == "WAIT" or thesisState == "WAIT — BALANCE" ? "NO TRADE" : "READY"
color statusColor = tradeActive ? color.lime : thesisState == "WAIT" or thesisState == "WAIT — BALANCE" ? color.silver : color.orange

var table hud = table.new(position.top_right, 3, 12, border_width = 1)
if barstate.islast
    table.clear(hud, 0, 0, 2, 11)
    if showHUD
        color bg = color.new(color.black, 8)
        table.cell(hud, 0, 0, "LASER", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 0, tradeActive ? (tradeDirectionState == 1 ? "LONG " : "SHORT ") + tradeCode : thesisState, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 0, tradeActive ? tradeGrade : statusText, bgcolor = bg, text_color = statusColor, text_size = hudTextSize)

        table.cell(hud, 0, 1, "Regime", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 1, regime, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 1, "BAL " + str.tostring(balanceScore, "#") + "%", bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 2, "Auction", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 2, auctionState, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 2, vpState, bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 3, "Scores", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 3, "L " + longCandidate, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 3, "S " + shortCandidate, bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 4, "RSI", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 4, str.tostring(rsi, "#.1") + " Δ" + str.tostring(rsiROC, "#.1"), bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 4, "A " + str.tostring(rsiAccel, "#.1"), bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 5, "RSI DIV", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 5, "B " + bullDivHud, bgcolor = bg, text_color = recentRsiBullDiv ? color.lime : color.white, text_size = hudTextSize)
        table.cell(hud, 2, 5, "S " + bearDivHud, bgcolor = bg, text_color = recentRsiBearDiv ? color.red : color.white, text_size = hudTextSize)

        table.cell(hud, 0, 6, "SQZ", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 6, energyState, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 6, "Δ" + str.tostring(sqzROC, "#.1") + " A" + str.tostring(sqzAccel, "#.1"), bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 7, "Evidence", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 7, "L " + longModsNow, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 7, "S " + shortModsNow, bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 8, "Volume", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 8, volumeState, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 8, str.tostring(relativeVolume, "#.00") + "x", bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 9, "Risk/Room", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 9, "L " + longRiskHud, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 9, "S " + shortRiskHud, bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 10, "Trade", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 10, lastTradeSummary, bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 10, "Req " + str.tostring(requiredScore, "#"), bgcolor = bg, text_color = color.white, text_size = hudTextSize)

        table.cell(hud, 0, 11, "Levels", bgcolor = bg, text_color = color.silver, text_size = hudTextSize)
        table.cell(hud, 1, 11, tradeActive ? "E " + str.tostring(tradeEntry, format.mintick) + "  SL " + str.tostring(tradeStop, format.mintick) : "VAH " + str.tostring(activeVAH, format.mintick), bgcolor = bg, text_color = color.white, text_size = hudTextSize)
        table.cell(hud, 2, 11, tradeActive ? "T1 " + str.tostring(tradeTP1, format.mintick) : "POC " + str.tostring(activePOC, format.mintick), bgcolor = bg, text_color = color.white, text_size = hudTextSize)

//=============================================================================
// 30 — ALERTS
//=============================================================================
alertcondition(longFire, "LASER Long FIRE", "LASER qualified LONG on {{ticker}} {{interval}}.")
alertcondition(shortFire, "LASER Short FIRE", "LASER qualified SHORT on {{ticker}} {{interval}}.")
alertcondition(rsiBullDiv, "LASER Bullish RSI Divergence", "{{ticker}} {{interval}} bullish RSI divergence confirmed.")
alertcondition(rsiBearDiv, "LASER Bearish RSI Divergence", "{{ticker}} {{interval}} bearish RSI divergence confirmed.")
alertcondition(squeezeFired, "LASER Squeeze Fired", "{{ticker}} {{interval}} squeeze released.")
alertcondition(sellingAbsorbed, "LASER Selling Absorbed", "{{ticker}} {{interval}} possible high-volume selling absorption.")
alertcondition(buyingAbsorbed, "LASER Buying Absorbed", "{{ticker}} {{interval}} possible high-volume buying absorption.")
alertcondition(failedAuctionAboveVAH, "LASER Failed Auction Above VAH", "{{ticker}} {{interval}} rejected an excursion above VAH.")
alertcondition(failedAuctionBelowVAL, "LASER Failed Auction Below VAL", "{{ticker}} {{interval}} rejected an excursion below VAL.")
````
