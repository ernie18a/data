# ICT Ghost Chart by camikazee

- url: https://www.tradingview.com/script/OVqPgRuP-ICT-Ghost-Chart-by-camikazee/
- type: indicator
- pine_id: PUB;2ba3eb6bd6b44b1aa7872a1c40296bf7
- version: 4.0

## Description

[b]ICT Ghost Chart by camikazee[/b]

[b]Professional ICT / SMC Trading Toolkit[/b]

ICT Ghost Chart is an advanced Smart Money Concepts (SMC) and ICT-based trading framework designed for discretionary traders, scalpers, day traders and swing traders.

The indicator combines market structure, liquidity, sessions, Fibonacci dealing ranges, SMT divergence, liquidity sweeps and institutional execution concepts into a single integrated workflow.

[b]The goal is simple:[/b]

Identify liquidity → confirm structure shift → locate optimal entry → define target liquidity.

━━━━━━━━━━━━━━━━━━━━

[b]Core Features[/b]

[b]Liquidity Purge Detection[/b]

Automatically detects:

[list]
[*]Sell-side liquidity sweeps
[*]Buy-side liquidity sweeps
[*]Weak sweeps
[*]Strong sweeps
[*]Institutional sweeps
[/list]

Provides visual confirmation when liquidity has been engineered and potentially taken.

━━━━━━━━━━━━━━━━━━━━

[b]Market Structure Engine[/b]

Tracks:

[list]
[*]MSS (Market Structure Shift)
[*]CHOCH (Change of Character)
[*]BOS (Break of Structure)
[*]External BOS
[*]External CHOCH
[/list]

Includes:

[list]
[*]Internal structure
[*]External structure
[*]Trend continuation
[*]Trend reversal detection
[/list]

━━━━━━━━━━━━━━━━━━━━

[b]Smart Fibonacci Engine[/b]

Dynamic ICT dealing range model.

Automatically plots:

[b]Internal Retracement Levels[/b]

[list]
[*]0.50
[*]0.618
[/list]

Used for:

[list]
[*]Retracement entries
[*]Discount / Premium analysis
[*]Optimal Trade Entry concepts
[/list]

[b]Expansion Targets[/b]

[list]
[*]1.27
[*]1.618
[/list]

Used for:

[list]
[*]Liquidity targets
[*]Profit targets
[*]Continuation projections
[/list]

━━━━━━━━━━━━━━━━━━━━

[b]Session Engine[/b]

Displays:

[list]
[*]Asia Session
[*]Europe Session
[*]USA Session
[/list]

Includes:

[list]
[*]Session Highs / Lows
[*]Session Ranges
[*]Session Boxes
[*]Current Session Mode
[/list]

━━━━━━━━━━━━━━━━━━━━

[b]ICT Killzones[/b]

Includes:

[list]
[*]London Killzone
[*]New York Killzone
[*]Silver Bullet AM
[*]Silver Bullet NY
[*]Silver Bullet PM
[*]Macro AM
[*]Macro MID
[/list]

Features:

[list]
[*]Current Killzone Mode
[*]Historical Killzone Filtering
[*]HTF Auto-Hide
[*]Scalp Mode
[*]Swing Mode
[*]Clean Mode
[/list]

━━━━━━━━━━━━━━━━━━━━

[b]Best Markets[/b]

[list]
[*]Nasdaq (NQ)
[*]S&P 500 (ES)
[*]Gold (XAUUSD)
[*]Bitcoin (BTC)
[*]Ethereum (ETH)
[*]Major Forex Pairs
[/list]

━━━━━━━━━━━━━━━━━━━━

[b]Developed By[/b]

[b]ICT Ghost Chart by camikazee[/b]

Professional ICT / Smart Money Concepts Trading Framework.

## Source Code

````pine
//@version=6
indicator("ICT Ghost Chart by camikazee", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

max_bars_back(time, 5000)

// =====================================================
// INTERNAL VERSION
// =====================================================
SCRIPT_VERSION = "1.3.12"

// =====================================================
// ICT / SMC TOOLKIT
// Liquidity Sweep + MSS + FVG + SMT + Sessions + EMA + Dynamic FIBO + OB + CHOCH/BOS
// =====================================================

// =====================================================
// MAIN INPUTS
// =====================================================
showPDH_PDL      = input.bool(true, "Show PDH / PDL", group="Main")
showPWH_PWL      = input.bool(true, "Show PWH / PWL", group="Main")
showPMH_PML      = input.bool(false, "Show PMH / PML", group="Main")
showMidnightOpen = input.bool(true, "Show Midnight Open", group="Main")
showSweeps       = input.bool(false, "Show Liquidity Sweeps", group="Main")
showMSS          = input.bool(true, "Show MSS markers", group="Main")
showFVG          = input.bool(true, "Show FVG boxes", group="Main")
showRR           = input.bool(true, "Show Entry / SL / TP", group="Main")
showSMT          = input.bool(true, "Show SMT widget", group="Main")
rr               = input.float(2.0, "Fallback Risk : Reward", minval=0.5, step=0.25, group="Main")

// =====================================================
// STRUCTURE INPUTS
// =====================================================
swingLen           = input.int(4, "Internal swing length", minval=1, maxval=20, group="Structure")
externalSwingLen   = input.int(12, "External swing length", minval=3, maxval=50, group="Structure")
showExternalStructure = input.bool(true, "Show External Structure", group="Structure")
maxBarsAfterSweep  = input.int(25, "Max bars after sweep to find MSS", minval=1, maxval=200, group="Structure")
usePDH_PDL         = input.bool(true, "Sweeps: PDH / PDL", group="Structure")
useEQH_EQL         = input.bool(true, "Sweeps: EQH / EQL", group="Structure")
eqLookback         = input.int(30, "EQH/EQL lookback", minval=5, maxval=300, group="Structure")
eqToleranceTicks   = input.int(10, "EQH/EQL tolerance in ticks", minval=1, maxval=200, group="Structure")
showCHOCH          = input.bool(true, "Show CHOCH", group="Structure")
showBOS            = input.bool(true, "Show BOS", group="Structure")
showInducement     = input.bool(false, "Show Inducement", group="Structure")
inducementPivotLen = input.int(3, "Inducement pivot length", minval=1, maxval=10, group="Structure")
inducementMinWickAtr = input.float(0.10, "Inducement min wick ATR", minval=0.0, step=0.05, group="Structure")
inducementMinSweepAtr = input.float(0.03, "Inducement min sweep ATR", minval=0.0, step=0.01, group="Structure")
inducementCooldownBars = input.int(5, "Inducement cooldown bars", minval=1, maxval=50, group="Structure")
inducementTrendFilter = input.bool(true, "Inducement follow market structure", group="Structure")
showConfirmedCHOCH = input.bool(true, "Show confirmed CHOCH only", group="Structure")
structure2Enabled = input.bool(true, "Structure Engine 2.0", group="Structure")
showInternalStructure2 = input.bool(true, "Show internal BOS / CHOCH lines", group="Structure")
showSwingStructure2 = input.bool(true, "Show swing BOS / CHOCH lines", group="Structure")
structure2InternalLen = input.int(5, "Internal structure pivot length", minval=2, maxval=20, group="Structure")
structure2SwingLen = input.int(20, "Swing structure pivot length", minval=5, maxval=100, group="Structure")
structureAtrFilter = input.float(0.8, "Structure displacement ATR filter", minval=0.1, step=0.1, group="Structure")
mssBodyAtrFilter   = input.float(0.6, "MSS minimum body ATR", minval=0.1, step=0.1, group="Structure")
useMssEmaSlopeFilter = input.bool(true, "Use EMA slope confirmation for MSS", group="Structure")
mssContinuationBars = input.int(2, "MSS continuation lookback", minval=1, maxval=5, group="Structure")
mssMinDistanceFromEmaAtr = input.float(0.4, "MSS min distance from EMA ATR", minval=0.0, step=0.1, group="Structure")
requireTwoDisplacementCandles = input.bool(true, "Require 2 displacement candles for FIB", group="Structure")

// =====================================================
// HTF BIAS ENGINE
// =====================================================
showHTFBias = input.bool(true, "Show HTF Bias", group="HTF Bias")
htfTf       = input.timeframe("240", "HTF timeframe", group="HTF Bias")
showPDZones = input.bool(true, "Show Premium / Discount EQ line", group="HTF Bias")
showPDBackground = input.bool(false, "Show Premium / Discount background", group="HTF Bias")

// =====================================================
// KILLZONES / ICT TIME WINDOWS
// Times are intended for New York time.
// =====================================================
showKillzones    = input.bool(true, "Show Killzones", group="Killzones")
showWindowLines  = input.bool(true, "Show START / END vertical lines", group="Killzones")
showWindowLabels = input.bool(true, "Show window labels", group="Killzones")
killzoneTimezone = input.string("America/New_York", "ICT windows timezone", group="Killzones")

londonKillzone  = input.session("0200-0500", "London Killzone", group="Killzones")
nyKillzone      = input.session("0830-1100", "New York Judas / AM Killzone", group="Killzones")
sbAMSession     = input.session("0300-0400", "Silver Bullet AM", group="Killzones")
sbNYSession     = input.session("1000-1100", "Silver Bullet NY", group="Killzones")
sbPMSession     = input.session("1400-1500", "Silver Bullet PM", group="Killzones")
macroAMSession  = input.session("0950-1010", "Macro Window AM", group="Killzones")
macroMIDSession = input.session("1050-1110", "Macro Window MID", group="Killzones")

londonKzColor = input.color(color.new(color.green, 94), "London KZ color", group="Killzones")
nyKzColor     = input.color(color.new(color.red, 94), "NY KZ color", group="Killzones")
silverColor   = input.color(color.new(color.aqua, 93), "Silver Bullet color", group="Killzones")
macroColor    = input.color(color.new(color.orange, 92), "Macro Window color", group="Killzones")

// =====================================================
// FILTERS / SCORING
// =====================================================
useDisplacement  = input.bool(true, "Use displacement filter", group="Filters")
atrMultiplier    = input.float(1.5, "ATR displacement multiplier", minval=0.5, step=0.1, group="Filters")
useVolumeFilter  = input.bool(true, "Use volume spike filter", group="Filters")
volumeMultiplier = input.float(1.5, "Volume spike multiplier", minval=1.0, step=0.1, group="Filters")

showTradeScore      = input.bool(true, "Show trade score", group="Scoring")
showOnlyAPlusSetups = input.bool(false, "Only A+ setups", group="Scoring")
minimumScore        = input.int(7, "Minimum score", minval=1, maxval=10, group="Scoring")
aPlusScore          = input.int(8, "A+ minimum score", minval=7, maxval=10, group="Scoring")
useTrendScoreFilter = input.bool(true, "Use Trend Score Filter", group="Scoring")
minimumTrendScore   = input.int(2, "Minimum Trend Score", minval=1, maxval=4, group="Scoring")
useMssTrendFilter   = input.bool(false, "Filter MSS by EMA trend", group="Scoring")
showProbabilityScore = input.bool(true, "Show Probability Score", group="Scoring")
minimumProbabilityScore = input.int(7, "Minimum Probability Score", minval=1, maxval=12, group="Scoring")

// =====================================================
// SESSION / MARKET HOURS
// =====================================================
showSessions     = input.bool(true, "Show market sessions", group="Sessions")
showSessionBoxes = input.bool(true, "Show session boxes", group="Sessions")
showHistoricalSessionBoxes = input.bool(false, "Show historical session boxes", group="Sessions")
sessionHistoryDays = input.int(5, "Historical sessions: days", minval=1, maxval=365, group="Sessions")
maxHistoricalSessionBoxes = input.int(300, "Maximum historical session boxes", minval=10, maxval=400, group="Sessions")
historyKeepAsia = input.bool(true, "History: Asia", group="Sessions")
historyKeepLondon = input.bool(true, "History: London", group="Sessions")
historyKeepNewYork = input.bool(true, "History: New York", group="Sessions")
historyKeepPreSessions = input.bool(false, "History: Pre-sessions", group="Sessions")
historicalSessionTransparency = input.int(70, "Historical fill transparency (v1.3.7)", minval=0, maxval=100, group="Sessions")
historicalBorderTransparency = input.int(20, "Historical border transparency", minval=0, maxval=100, group="Sessions")
historicalPreSessionExtraFade = input.int(10, "Pre-session extra transparency", minval=0, maxval=40, group="Sessions")
historicalAsiaColor = input.color(color.rgb(50, 110, 215), "Historical Asia color", group="Sessions")
historicalEuropeColor = input.color(color.rgb(215, 170, 40), "Historical London color", group="Sessions")
historicalUSAColor = input.color(color.rgb(30, 165, 140), "Historical USA color", group="Sessions")
historicalEuropePreColor = input.color(color.rgb(145, 115, 185), "Historical Europe pre-session color", group="Sessions")
historicalUSAPreColor = input.color(color.rgb(175, 115, 165), "Historical USA pre-session color", group="Sessions")
showHistoricalSessionNames = input.bool(true, "Label historical session boxes (<= H1)", group="Sessions")
historicalSessionTextColor = input.color(color.new(color.white, 0), "Historical session label color", group="Sessions")

showUSABox = input.bool(true, "Show USA session box", group="Sessions")
usaBoxTransparency = input.int(93, "USA box transparency", minval=0, maxval=100, group="Sessions")
showEuropePreSession = input.bool(true, "Show Europe pre-session", group="Sessions")
showUSAPreSession = input.bool(true, "Show USA pre-session", group="Sessions")
preSessionTransparency = input.int(96, "Pre-session transparency", minval=0, maxval=100, group="Sessions")
usaBoxMode = input.string("Full Session", "USA box mode (legacy)", options=["Full Session", "Manipulation Only"], group="Sessions")
showSessionHL    = input.bool(true, "Show session High / Low lines", group="Sessions")
showSessionTable = input.bool(true, "Show session hours widget", group="Sessions")
extendAsiaBoxToRight = input.bool(true, "Extend Asia H/L to current bar (legacy)", group="Sessions")
extendEuropeBoxToRight = input.bool(false, "Extend Europe H/L to current bar (legacy)", group="Sessions")
extendUSABoxToRight = input.bool(false, "Extend USA H/L to current bar (legacy)", group="Sessions")
limitUSABoxToManipulation = input.bool(true, "Limit USA / NY box to manipulation phase", group="Sessions")
usaManipulationBars = input.int(6, "USA / NY manipulation box bars", minval=1, maxval=60, group="Sessions")
dynamicUSABoxEnd = input.bool(true, "End USA / NY box after displacement or MSS", group="Sessions")
showOnlyCurrentAsiaHL = input.bool(false, "Show only current Asia H/L", group="Sessions")

sessionTimezone = input.string("Etc/UTC", "Asia session timezone", group="Sessions")
europeSessionTimezone = input.string("Europe/London", "Europe session timezone", group="Sessions")
usaSessionTimezone = input.string("America/New_York", "USA session timezone", group="Sessions")
asiaSession     = input.session("0000-0600", "Asia session", group="Sessions")
europeSession   = input.session("0800-1630", "Europe / London session", group="Sessions")
usaSession      = input.session("0930-1600", "USA / NY session", group="Sessions")
europePreSession = input.session("0700-0800", "Europe pre-session", group="Sessions")
usaPreSession = input.session("0830-0930", "USA pre-session", group="Sessions")

asiaColor   = input.color(color.new(color.blue, 88), "Asia color", group="Sessions")
europeColor = input.color(color.new(color.yellow, 88), "Europe color", group="Sessions")
usaColor    = input.color(color.new(color.purple, 88), "USA color", group="Sessions")
europePreColor = input.color(color.new(color.yellow, 90), "Europe pre-session color", group="Sessions")
usaPreColor = input.color(color.new(color.teal, 90), "USA pre-session color", group="Sessions")

// =====================================================
// HTF SUPPORT / RESISTANCE ENGINE
// =====================================================
showHTFSR = input.bool(true, "Show HTF Support / Resistance", group="HTF S/R")
showH1SR = input.bool(true, "Show H1 S/R", group="HTF S/R")
showH4SR = input.bool(true, "Show H4 S/R", group="HTF S/R")
showD1SR = input.bool(true, "Show D1 S/R", group="HTF S/R")
htfPivotLen = input.int(3, "HTF pivot strength", minval=2, maxval=10, group="HTF S/R")
srAtrMerge = input.float(0.20, "Confluence merge distance ATR", minval=0.05, maxval=1.0, step=0.05, group="HTF S/R")
showConfluenceZones = input.bool(true, "Show HTF confluence zones", group="HTF S/R")
srExtendBars = input.int(150, "S/R extension bars", minval=20, maxval=500, group="HTF S/R")
showVolumeStrength = input.bool(true, "Use volume strength confirmation", group="HTF S/R")
volumeStrengthLen = input.int(50, "Volume strength lookback", minval=10, maxval=300, group="HTF S/R")

// =====================================================
// EMA INPUTS
// =====================================================
autoEmaPreset = input.bool(true, "Auto EMA preset by market", group="EMA")
useCryptoEmaPreset = input.bool(false, "Manual crypto EMA preset 9/21/100", group="EMA")
showEMA21   = input.bool(true, "Show EMA 21 / 34", group="EMA")
showEMA50   = input.bool(true, "Show EMA 50 / 89", group="EMA")
showEMA100  = input.bool(true, "Show EMA 100 / 200", group="EMA")
ema21Color  = input.color(color.new(color.lime, 0), "EMA 21 color", group="EMA")
ema21Width  = input.int(2, "EMA 21 width", minval=1, maxval=10, group="EMA")
ema50Color  = input.color(color.new(color.red, 0), "EMA 50 color", group="EMA")
ema50Width  = input.int(2, "EMA 50 width", minval=1, maxval=10, group="EMA")
ema100Color = input.color(color.new(color.white, 25), "EMA 100 color", group="EMA")
ema100Width = input.int(1, "EMA 100 width", minval=1, maxval=10, group="EMA")
adaptiveSlowEmaWidth = input.bool(true, "Adaptive slow EMA width", group="EMA")

// =====================================================
// LEVEL LABELS
// =====================================================
showLevelLabels   = input.bool(true, "Show short level labels", group="Levels")
fadeEndedSessionHL = input.bool(true, "Fade ended session H/L labels", group="Levels")
fadeBrokenSessionHL = input.bool(true, "Fade broken session H/L", group="Levels")
thinHTFLevels = input.bool(true, "Thin HTF levels", group="Levels")
levelLookbackBars = input.int(300, "Level line lookback bars", minval=20, maxval=2000, group="Levels")
lineColor         = input.color(color.new(color.gray, 0), "HTF level line color", group="Levels")

// =====================================================
// VISIBILITY / HTF CLEAN MODE
// =====================================================
hideLtfObjectsAbove = input.timeframe("15", "Hide LTF objects above TF", group="Visibility")
hideKillzonesFromTf = input.timeframe("60", "Hide killzones from TF", group="Visibility")
hideWindowLabelsFromTf = input.timeframe("60", "Hide Macro/SB/Judas labels from TF", group="Visibility")
softenActiveKillzones = input.bool(true, "Soften active killzones", group="Visibility")
killzoneLineTransparency = input.int(88, "Killzone vertical line transparency", minval=0, maxval=100, group="Visibility")
showHistoricalKillzones = input.bool(false, "Show historical killzones", group="Visibility")
currentKillzoneOnly = input.bool(true, "Current killzone only", group="Visibility")
killzoneRecentBars = input.int(60, "Current killzone lookback bars", minval=20, maxval=2000, group="Visibility")
displayMode = input.string("Scalp", "Display mode", options=["Scalp", "Swing", "Clean"], group="Visibility")
declutterWeakMarkers = input.bool(true, "Declutter weak IND / EXD markers", group="Visibility")
weakMarkerTransparency = input.int(85, "Weak marker transparency", minval=0, maxval=100, group="Visibility")
priorityStructureMarkers = input.bool(true, "Prioritize MSS / CHOCH markers", group="Visibility")
maxWeakLabelsVisible = input.int(30, "Max weak labels visible", minval=5, maxval=200, group="Visibility")
showHTFCleanModeInfo = input.bool(true, "Show HTF clean mode info", group="Visibility")
fadeInactiveSessions = input.bool(true, "Fade inactive session background", group="Visibility")
cleanNyJudasMode = input.bool(true, "Cleaner NY Judas mode", group="Visibility")
hideNyJudasBox = input.bool(true, "Hide NY Judas box / keep lines only", group="Visibility")

autoHideMicroOverlaysAbove15m = input.bool(true, "Auto hide micro overlays above 15m", group="Visibility")
isHigherTF = timeframe.in_seconds(timeframe.period) > timeframe.in_seconds(hideLtfObjectsAbove)
isSwingMode = displayMode == "Swing"
isCleanMode = displayMode == "Clean"
isTrueHTFMode = isSwingMode or isCleanMode or timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds("60")
structureShowAllowed = not isCleanMode
isMicroHiddenTF = autoHideMicroOverlaysAbove15m and timeframe.isminutes and timeframe.multiplier > 15
showLtfFVG = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showLtfFib = not isHigherTF
showLtfSweepLabels = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showLtfMSS = (not isHigherTF and not isMicroHiddenTF) and structureShowAllowed
showLtfInternal = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showLtfInducement = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showLtfExhaustion = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showLtfOB = (not isHigherTF and not isMicroHiddenTF) and not isTrueHTFMode
showH1StructuralZones = timeframe.isminutes and timeframe.multiplier == 60
showStructuralFVG = showLtfFVG or showH1StructuralZones
showStructuralOB = showLtfOB or showH1StructuralZones
showKillzoneTfAllowed = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(hideKillzonesFromTf)
windowLabelTfAllowed = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(hideWindowLabelsFromTf)
showLtfKillzones = not isHigherTF and showKillzoneTfAllowed and not isTrueHTFMode
killzoneCurrentOnlyAllowed = not currentKillzoneOnly or bar_index >= last_bar_index - killzoneRecentBars
killzoneRenderAllowed = showLtfKillzones and (showHistoricalKillzones or killzoneCurrentOnlyAllowed)
killzoneLabelAllowed = killzoneRenderAllowed and windowLabelTfAllowed

// =====================================================
// FVG INPUTS
// =====================================================
showAllValidFVG     = input.bool(true, "Show valid FVG zones independently", group="FVG")
fvgMaxActivePerSide = input.int(1, "Max active FVG per side", minval=1, maxval=5, group="FVG")
fvgMitigationMode = input.string("CE 50%", "FVG mitigation", options=["Touch", "CE 50%", "Full Fill"], group="FVG")
showFvgCE = input.bool(false, "Show FVG CE line", group="FVG")
showFvgLabels = input.bool(true, "Show small FVG labels", group="FVG")
fvgFillTransparency = input.int(90, "FVG fill transparency", minval=60, maxval=100, group="FVG")
fvgBorderTransparency = input.int(75, "FVG border transparency", minval=20, maxval=100, group="FVG")
fvg2MinAtr = input.float(0.12, "Minimum FVG size ATR", minval=0.01, step=0.01, group="FVG")
fvg2DisplacementAtr = input.float(0.70, "FVG displacement body ATR", minval=0.1, step=0.05, group="FVG")
fvgExtendBars      = input.int(30, "FVG box extension bars", minval=5, maxval=300, group="FVG")
bullFvgColor       = input.color(color.new(color.lime, 68), "Bullish FVG color", group="FVG")
bearFvgColor       = input.color(color.new(color.red, 68), "Bearish FVG color", group="FVG")
fvgBorderWidth     = input.int(2, "FVG border width", minval=1, maxval=5, group="FVG")
fvgMode            = input.string("Balanced", "FVG Mode", options=["Conservative", "Balanced", "Aggressive"], group="FVG")
mitigateFVG        = input.bool(true, "Fade mitigated FVG", group="FVG")
removeMitigatedFVG = input.bool(true, "Delete mitigated FVG", group="FVG")
mitigatedFvgColor  = input.color(color.new(color.gray, 90), "Mitigated FVG color", group="FVG")

// =====================================================
// ORDER BLOCK INPUTS
// =====================================================
showOB          = input.bool(true, "Show Order Blocks", group="Order Blocks")
showAllStructuralOB = input.bool(true, "Show structural OB zones", group="Order Blocks")
ob2Enabled = input.bool(true, "Order Block Engine 2.0", group="Order Blocks")
ob2SearchBars = input.int(12, "OB origin search bars", minval=2, maxval=50, group="Order Blocks")
ob2MaxActive = input.int(3, "Max active structural OB per side", minval=1, maxval=10, group="Order Blocks")
showObLabels = input.bool(true, "Show small OB labels", group="Order Blocks")
maxOBBoxes      = input.int(6, "Max active OB boxes", minval=1, maxval=30, group="Order Blocks")
obExtendBars    = input.int(40, "OB extend bars", minval=5, maxval=300, group="Order Blocks")
bullOBColor     = input.color(color.new(color.lime, 82), "Bull OB color", group="Order Blocks")
bearOBColor     = input.color(color.new(color.red, 82), "Bear OB color", group="Order Blocks")
mitigateOB      = input.bool(true, "Fade mitigated OB", group="Order Blocks")
deleteInvalidOB = input.bool(true, "Delete invalidated OB", group="Order Blocks")

// =====================================================
// EXHAUSTION INPUTS
// =====================================================
showExhaustion   = input.bool(true, "Show Exhaustion", group="Exhaustion")
exhaustionRsiLen = input.int(14, "RSI length", minval=2, maxval=50, group="Exhaustion")
useStrictExhaustion = input.bool(true, "Strict exhaustion filter", group="Exhaustion")
exhaustionMinWickAtr = input.float(0.35, "EXH min wick ATR", minval=0.0, step=0.05, group="Exhaustion")
exhaustionOnlyAfterSweep = input.bool(true, "EXH only after liquidity sweep", group="Exhaustion")
exhaustionPremiumDiscountOnly = input.bool(true, "EXH only in premium/discount", group="Exhaustion")

// =====================================================
// SMT INPUTS
// =====================================================
smtSymbol             = input.symbol("CME_MINI:ES1!", "SMT correlated symbol", group="SMT")
smtLookback           = input.int(10, "SMT swing lookback", minval=2, maxval=100, group="SMT")
showSMTMarkers        = input.bool(false, "Show SMT markers on chart", group="SMT")
showSMTOnlyInKillzone = input.bool(true, "Show SMT only in ICT windows", group="SMT")

// =====================================================
// FIBO / FIBONACCI INPUTS
// Dynamic ICT FIBO: active impulse only.
// Internal: 0.5 / 0.618. External targets: 1.27 / 1.618.
// =====================================================
showAutoFibo          = input.bool(false, "Show ICT Auto FIBO", group="FIBO")
showFiboInternal      = input.bool(true, "Show internal fib 0.5 / 0.618", group="FIBO")
showFiboExternal      = input.bool(true, "Show external fib 1.27 / 1.618", group="FIBO")
fiboLookbackBars      = input.int(120, "FIBO line lookback bars", minval=20, maxval=1000, group="FIBO")
fiboLineWidth         = input.int(3, "FIBO line width", minval=1, maxval=8, group="FIBO")
fibo50Color           = input.color(color.new(color.yellow, 0), "FIB 0.5 color", group="FIBO")
fibo618Color          = input.color(color.new(color.orange, 0), "FIB 0.618 color", group="FIBO")
fibo127Color          = input.color(color.new(color.red, 0), "FIB 1.27 target color", group="FIBO")
fibo1618Color         = input.color(color.new(color.fuchsia, 0), "FIB 1.618 target color", group="FIBO")
fiboShowPrice         = input.bool(true, "Show fib price in label", group="FIBO")
fiboLabelOffsetBars   = input.int(6, "FIB label right offset bars", minval=0, maxval=50, group="FIBO")
fiboLabelStackAtr     = input.float(0.12, "FIB label stack ATR offset", minval=0.0, step=0.01, group="FIBO")
fiboAvoidEmaLabels    = input.bool(true, "Move FIB labels away from EMA", group="FIBO")
fiboEmaAvoidAtr       = input.float(0.25, "FIB EMA avoid ATR", minval=0.0, step=0.05, group="FIBO")
removeFibTargetHit    = input.bool(true, "Hide fib target after hit", group="FIBO")
resetFibOnNewMSS      = input.bool(true, "Reset FIBO on confirmed impulse", group="FIBO")
fiboUseSweepOrigin    = input.bool(true, "Use sweep low/high as FIBO origin", group="FIBO")
fiboRequireDisplacement = input.bool(true, "Require displacement for new FIBO", group="FIBO")
useDisplacementLegOnly = input.bool(true, "Use displacement leg only", group="FIBO")
fiboImpulseLookback = input.int(12, "ICT impulse leg lookback", minval=2, maxval=50, group="FIBO")
dealingLegLookback = input.int(36, "ICT dealing leg origin lookback", minval=5, maxval=150, group="FIBO")
minImpulseATR = input.float(3.0, "Minimum FIB impulse ATR", minval=0.5, step=0.25, group="FIBO")
invalidateFibOn100Break = input.bool(true, "Hide FIBO after 100% invalidation", group="FIBO")
fastFiboReset5m = input.bool(true, "Fast FIBO reset for M1/M5", group="FIBO")
smartFibLock = input.bool(true, "Smart FIB Lock", group="FIBO")
minBarsBetweenFibReset = input.int(5, "Min bars between FIB resets", minval=1, maxval=50, group="FIBO")
hideFibAfterFullInvalidation = input.bool(true, "Auto hide FIB after full invalidation", group="FIBO")
fadeInternalFibAfterContinuation = input.bool(true, "Hide internal FIB after continuation break", group="FIBO")
smarterContinuationFib = input.bool(true, "Smarter continuation FIB", group="FIBO")
useConfirmedDealingLegOnly = input.bool(true, "Use confirmed dealing leg only", group="FIBO")
hideFibAfterEqMitigation = input.bool(false, "Hide FIB after 50% mitigation", group="FIBO")
adaptiveCryptoTargets = input.bool(true, "Adaptive crypto FIB targets", group="FIBO")
cryptoTarget1 = input.float(1.13, "Crypto target 1", minval=1.01, step=0.01, group="FIBO")
cryptoTarget2 = input.float(1.21, "Crypto target 2", minval=1.01, step=0.01, group="FIBO")

// =====================================================
// HTF BIAS + PREMIUM / DISCOUNT
// =====================================================
htfHigh = request.security(syminfo.tickerid, htfTf, ta.highest(high, 20))
htfLow  = request.security(syminfo.tickerid, htfTf, ta.lowest(low, 20))
htfEq   = (htfHigh + htfLow) / 2.0

premiumZone = close > htfEq
discountZone = close < htfEq
bullBias = close > htfEq
bearBias = close < htfEq

plot(showPDZones ? htfEq : na, "HTF Equilibrium", color=color.new(color.white, 0), linewidth=2)
bgcolor(showPDBackground and premiumZone ? color.new(color.red, 96) : na)
bgcolor(showPDBackground and discountZone ? color.new(color.green, 96) : na)

var table biasTable = table.new(position.top_left, 1, 3, border_width=1)
if barstate.islast and showHTFBias
    biasText = bullBias ? "Bullish Bias" : "Bearish Bias"
    biasColor = bullBias ? color.new(color.green, 0) : color.new(color.red, 0)
    table.cell(biasTable, 0, 0, "HTF Bias", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(biasTable, 0, 1, biasText, bgcolor=biasColor, text_color=color.white)
    table.cell(biasTable, 0, 2, "EQ: " + str.tostring(htfEq, format.mintick), bgcolor=color.new(color.black, 0), text_color=color.white)

// =====================================================
// KILLZONES / ICT TIME WINDOWS
// =====================================================
inLondonKZ = not na(time(timeframe.period, londonKillzone, killzoneTimezone))
inNYKZ = not na(time(timeframe.period, nyKillzone, killzoneTimezone))
inSB_AM = not na(time(timeframe.period, sbAMSession, killzoneTimezone))
inSB_NY = not na(time(timeframe.period, sbNYSession, killzoneTimezone))
inSB_PM = not na(time(timeframe.period, sbPMSession, killzoneTimezone))
inMacroAM = not na(time(timeframe.period, macroAMSession, killzoneTimezone))
inMacroMID = not na(time(timeframe.period, macroMIDSession, killzoneTimezone))
validICTWindow = inLondonKZ or inNYKZ or inSB_AM or inSB_NY or inSB_PM or inMacroAM or inMacroMID
useNyJudasOnlyAfterSweep = input.bool(true, "NY Judas only after liquidity sweep", group="Structure")
nyJudasAllowed = not useNyJudasOnlyAfterSweep

bgcolor(showKillzones and killzoneRenderAllowed and inLondonKZ ? londonKzColor : na)
bgcolor(showKillzones and killzoneRenderAllowed and inNYKZ and not hideNyJudasBox ? (cleanNyJudasMode ? color.new(color.red, softenActiveKillzones ? 99 : 97) : nyKzColor) : na)
bgcolor(showKillzones and killzoneRenderAllowed and (inSB_AM or inSB_NY or inSB_PM) ? silverColor : na)
bgcolor(showKillzones and killzoneRenderAllowed and (inMacroAM or inMacroMID) ? (cleanNyJudasMode ? color.new(color.orange, softenActiveKillzones ? 99 : 98) : color.new(color.orange, softenActiveKillzones ? 98 : 96)) : na)

f_drawWindowBoundary(_start, _end, _name, _color) =>
    if showKillzones and killzoneLabelAllowed and showWindowLines and _start
        if killzoneLabelAllowed
            line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(_color, killzoneLineTransparency), style=line.style_dashed, width=1)
        if showWindowLabels and killzoneLabelAllowed
            label.new(bar_index, high, _name + " START", style=label.style_label_down, color=_color, textcolor=color.white, size=size.tiny)
    if showKillzones and killzoneLabelAllowed and showWindowLines and _end
        if killzoneLabelAllowed
            line.new(bar_index, low, bar_index, high, extend=extend.both, color=_color, style=line.style_dotted, width=1)
        if showWindowLabels and killzoneLabelAllowed
            label.new(bar_index, low, _name + " END", style=label.style_label_up, color=_color, textcolor=color.white, size=size.tiny)

f_drawWindowBoundary(inLondonKZ and not inLondonKZ[1], not inLondonKZ and inLondonKZ[1], "London KZ", color.new(color.green, 0))
f_drawWindowBoundary(inNYKZ and not inNYKZ[1], not inNYKZ and inNYKZ[1], "NY Judas", color.new(color.red, 0))
f_drawWindowBoundary(inSB_AM and not inSB_AM[1], not inSB_AM and inSB_AM[1], "SB AM", color.new(color.aqua, 0))
f_drawWindowBoundary(inSB_NY and not inSB_NY[1], not inSB_NY and inSB_NY[1], "SB NY", color.new(color.aqua, 0))
f_drawWindowBoundary(inSB_PM and not inSB_PM[1], not inSB_PM and inSB_PM[1], "SB PM", color.new(color.aqua, 0))
f_drawWindowBoundary(inMacroAM and not inMacroAM[1], not inMacroAM and inMacroAM[1], "Macro AM", color.new(color.orange, 0))
f_drawWindowBoundary(inMacroMID and not inMacroMID[1], not inMacroMID and inMacroMID[1], "Macro MID", color.new(color.orange, 0))

// =====================================================
// EMA 21 / 50 / 100
// =====================================================
isCryptoMarket = syminfo.type == "crypto"
useCryptoEma = autoEmaPreset ? isCryptoMarket : useCryptoEmaPreset
emaFastLen = useCryptoEma ? 9 : 21
emaMidLen = useCryptoEma ? 21 : 50
emaSlowLen = useCryptoEma ? 100 : 100
ema21 = ta.ema(close, emaFastLen)
ema50 = ta.ema(close, emaMidLen)
ema100 = ta.ema(close, emaSlowLen)
plot(showEMA21 ? ema21 : na, "EMA Fast", color=ema21Color, linewidth=ema21Width)
plot(showEMA50 ? ema50 : na, "EMA Mid", color=ema50Color, linewidth=ema50Width)
plot(showEMA100 and adaptiveSlowEmaWidth and timeframe.isminutes and timeframe.multiplier <= 5 ? ema100 : na, title="EMA Slow Thin", color=ema100Color, linewidth=1)
plot(showEMA100 and not (adaptiveSlowEmaWidth and timeframe.isminutes and timeframe.multiplier <= 5) ? ema100 : na, title="EMA Slow Normal", color=ema100Color, linewidth=ema100Width)
// Core volatility / body / volume definitions must be declared before MSS filters.
atr = ta.atr(14)
bodySize = math.abs(close - open)
avgVolume = ta.sma(volume, 20)
volumeSpike = volume > avgVolume * volumeMultiplier

trendScoreBull = 0
trendScoreBull += close > ema21 ? 1 : 0
trendScoreBull += ema21 > ema50 ? 1 : 0
trendScoreBull += ema50 > ema100 ? 1 : 0
trendScoreBull += discountZone ? 1 : 0

trendScoreBear = 0
trendScoreBear += close < ema21 ? 1 : 0
trendScoreBear += ema21 < ema50 ? 1 : 0
trendScoreBear += ema50 < ema100 ? 1 : 0
trendScoreBear += premiumZone ? 1 : 0

trendBull = ema21 > ema50 and ema50 > ema100
trendBear = ema21 < ema50 and ema50 < ema100
emaSlopeBull = ema21 > ema21[mssContinuationBars]
emaSlopeBear = ema21 < ema21[mssContinuationBars]
mssDistanceFromEmaOk = math.abs(close - ema21) > atr * mssMinDistanceFromEmaAtr
mssMinRangeAtr = input.float(1.2, "MSS min local range ATR", minval=0.0, step=0.1, group="Structure")
mssLocalRangeOk = (ta.highest(high, swingLen * 2 + 1) - ta.lowest(low, swingLen * 2 + 1)) > atr * mssMinRangeAtr
bullTrendScoreOk = not useTrendScoreFilter or trendScoreBull >= minimumTrendScore
bearTrendScoreOk = not useTrendScoreFilter or trendScoreBear >= minimumTrendScore

// =====================================================
// MARKET SESSIONS: LATEST H/L ONLY, TO LAST CANDLE
// =====================================================
inAsia = not na(time(timeframe.period, asiaSession, sessionTimezone))
inEurope = not na(time(timeframe.period, europeSession, europeSessionTimezone))
inUSA = not na(time(timeframe.period, usaSession, usaSessionTimezone))
inEuropePre = not na(time(timeframe.period, europePreSession, europeSessionTimezone))
inUSAPre = not na(time(timeframe.period, usaPreSession, usaSessionTimezone))
// Session-aligned timestamps. Unlike bar_index these preserve session boundaries
// when switching between M15, M30 and H1.
asiaSessionOpenTime = time(timeframe.period, asiaSession, sessionTimezone)
asiaSessionCloseTime = time_close(timeframe.period, asiaSession, sessionTimezone)
europeSessionOpenTime = time(timeframe.period, europeSession, europeSessionTimezone)
europeSessionCloseTime = time_close(timeframe.period, europeSession, europeSessionTimezone)
usaSessionOpenTime = time(timeframe.period, usaSession, usaSessionTimezone)
usaSessionCloseTime = time_close(timeframe.period, usaSession, usaSessionTimezone)
europePreOpenTime = time(timeframe.period, europePreSession, europeSessionTimezone)
europePreCloseTime = time_close(timeframe.period, europePreSession, europeSessionTimezone)
usaPreOpenTime = time(timeframe.period, usaPreSession, usaSessionTimezone)
usaPreCloseTime = time_close(timeframe.period, usaPreSession, usaSessionTimezone)
var int asiaLastSessionCloseTime = na
var int europeLastSessionCloseTime = na
var int usaLastSessionCloseTime = na
var int europePreLastCloseTime = na
var int usaPreLastCloseTime = na
if inAsia
    asiaLastSessionCloseTime := asiaSessionCloseTime
if inEurope
    europeLastSessionCloseTime := europeSessionCloseTime
if inUSA
    usaLastSessionCloseTime := usaSessionCloseTime
if inEuropePre
    europePreLastCloseTime := europePreCloseTime
if inUSAPre
    usaPreLastCloseTime := usaPreCloseTime


asiaSessionDayKey = not na(asiaSessionOpenTime) ? year(asiaSessionOpenTime, sessionTimezone) * 10000 + month(asiaSessionOpenTime, sessionTimezone) * 100 + dayofmonth(asiaSessionOpenTime, sessionTimezone) : na
asiaStart = inAsia and (not inAsia[1] or (not na(asiaSessionDayKey[1]) and asiaSessionDayKey != asiaSessionDayKey[1]))
europeSessionDayKey = not na(europeSessionOpenTime) ? year(europeSessionOpenTime, europeSessionTimezone) * 10000 + month(europeSessionOpenTime, europeSessionTimezone) * 100 + dayofmonth(europeSessionOpenTime, europeSessionTimezone) : na
europeStart = inEurope and (not inEurope[1] or (not na(europeSessionDayKey[1]) and europeSessionDayKey != europeSessionDayKey[1]))
usaSessionDayKey = not na(usaSessionOpenTime) ? year(usaSessionOpenTime, usaSessionTimezone) * 10000 + month(usaSessionOpenTime, usaSessionTimezone) * 100 + dayofmonth(usaSessionOpenTime, usaSessionTimezone) : na
usaStart = inUSA and (not inUSA[1] or (not na(usaSessionDayKey[1]) and usaSessionDayKey != usaSessionDayKey[1]))

var float asiaHigh = na
var float asiaLow = na
var int asiaStartBar = na
var int asiaEndBar = na

var float europeHigh = na
var float europeLow = na
var int europeStartBar = na
var int europeEndBar = na

var float usaHigh = na
var float usaLow = na
var int usaStartBar = na
var int usaEndBar = na
var int usaManipulationEndBar = na

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaStartBar := bar_index
    asiaEndBar := na
else if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)

if not inAsia and inAsia[1]
    asiaEndBar := bar_index - 1

if europeStart
    europeHigh := high
    europeLow := low
    europeStartBar := bar_index
    europeEndBar := na
else if inEurope
    europeHigh := math.max(nz(europeHigh, high), high)
    europeLow := math.min(nz(europeLow, low), low)

if not inEurope and inEurope[1]
    europeEndBar := bar_index - 1

if usaStart
    usaHigh := high
    usaLow := low
    usaStartBar := bar_index
    usaEndBar := na
    usaManipulationEndBar := na
else if inUSA
    usaHigh := math.max(nz(usaHigh, high), high)
    usaLow := math.min(nz(usaLow, low), low)

if not inUSA and inUSA[1]
    usaEndBar := bar_index - 1


var float europePreHigh = na
var float europePreLow = na
var int europePreStartBar = na
var int europePreEndBar = na
var float usaPreHigh = na
var float usaPreLow = na
var int usaPreStartBar = na
var int usaPreEndBar = na

europePreSessionDayKey = not na(europePreOpenTime) ? year(europePreOpenTime, europeSessionTimezone) * 10000 + month(europePreOpenTime, europeSessionTimezone) * 100 + dayofmonth(europePreOpenTime, europeSessionTimezone) : na
europePreStart = inEuropePre and (not inEuropePre[1] or (not na(europePreSessionDayKey[1]) and europePreSessionDayKey != europePreSessionDayKey[1]))
usaPreSessionDayKey = not na(usaPreOpenTime) ? year(usaPreOpenTime, usaSessionTimezone) * 10000 + month(usaPreOpenTime, usaSessionTimezone) * 100 + dayofmonth(usaPreOpenTime, usaSessionTimezone) : na
usaPreStart = inUSAPre and (not inUSAPre[1] or (not na(usaPreSessionDayKey[1]) and usaPreSessionDayKey != usaPreSessionDayKey[1]))

if europePreStart
    europePreHigh := high
    europePreLow := low
    europePreStartBar := bar_index
    europePreEndBar := na
else if inEuropePre
    europePreHigh := math.max(nz(europePreHigh, high), high)
    europePreLow := math.min(nz(europePreLow, low), low)

if not inEuropePre and inEuropePre[1]
    europePreEndBar := bar_index - 1

if usaPreStart
    usaPreHigh := high
    usaPreLow := low
    usaPreStartBar := bar_index
    usaPreEndBar := na
else if inUSAPre
    usaPreHigh := math.max(nz(usaPreHigh, high), high)
    usaPreLow := math.min(nz(usaPreLow, low), low)

if not inUSAPre and inUSAPre[1]
    usaPreEndBar := bar_index - 1

// Session boxes: one active object per session type, optional retained history.
var box asiaVisualBoxFinal = na
var box europeVisualBoxFinal = na
var box usaVisualBoxFinal = na
var box europePreVisualBox = na
var box usaPreVisualBox = na
var box[] sessionHistoryBoxes = array.new_box()
var int[] sessionHistoryEndTimes = array.new_int()

// Historical boxes have independent colors and optional names on H1 or below.
// The labels are part of each box, so they are deleted together with the box.
historyNamesAllowed = showHistoricalSessionNames and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("60")
f_keepSessionHistory(box b, int closedAt, color historyColor, string sessionName) =>
    if not na(b)
        bool allowedHistory = sessionName == "ASIA" ? historyKeepAsia : sessionName == "LONDON" ? historyKeepLondon : sessionName == "NEW YORK" ? historyKeepNewYork : historyKeepPreSessions
        if showHistoricalSessionBoxes and allowedHistory
            bool isPreSession = sessionName == "EU PRE" or sessionName == "US PRE"
            int fillAlpha = isPreSession ? math.min(100, historicalSessionTransparency + historicalPreSessionExtraFade) : historicalSessionTransparency
            box.set_bgcolor(b, color.new(historyColor, fillAlpha))
            box.set_border_color(b, color.new(historyColor, historicalBorderTransparency))
            box.set_text(b, historyNamesAllowed ? sessionName : "")
            box.set_text_color(b, historicalSessionTextColor)
            box.set_text_size(b, size.small)
            box.set_text_halign(b, text.align_center)
            box.set_text_valign(b, text.align_top)
            array.push(sessionHistoryBoxes, b)
            array.push(sessionHistoryEndTimes, closedAt)
        else
            box.delete(b)

if showSessionBoxes and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("60")
    if asiaStart
        f_keepSessionHistory(asiaVisualBoxFinal, asiaLastSessionCloseTime, historicalAsiaColor, "ASIA")
        asiaVisualBoxFinal := box.new(asiaSessionOpenTime, asiaHigh, asiaSessionCloseTime, asiaLow, bgcolor=asiaColor, border_color=color.new(asiaColor, 65), xloc=xloc.bar_time)
    if inAsia and na(asiaVisualBoxFinal) and not na(asiaStartBar)
        asiaVisualBoxFinal := box.new(asiaSessionOpenTime, asiaHigh, asiaSessionCloseTime, asiaLow, bgcolor=asiaColor, border_color=color.new(asiaColor, 65), xloc=xloc.bar_time)
    if inAsia and not na(asiaVisualBoxFinal)
        box.set_right(asiaVisualBoxFinal, asiaSessionCloseTime)
        box.set_top(asiaVisualBoxFinal, asiaHigh)
        box.set_bottom(asiaVisualBoxFinal, asiaLow)
    if (not inAsia and inAsia[1]) and not na(asiaVisualBoxFinal)
        box.set_right(asiaVisualBoxFinal, asiaLastSessionCloseTime)

    if europeStart
        f_keepSessionHistory(europeVisualBoxFinal, europeLastSessionCloseTime, historicalEuropeColor, "LONDON")
        europeVisualBoxFinal := box.new(europeSessionOpenTime, europeHigh, europeSessionCloseTime, europeLow, bgcolor=europeColor, border_color=color.new(europeColor, 65), xloc=xloc.bar_time)
    if inEurope and na(europeVisualBoxFinal) and not na(europeStartBar)
        europeVisualBoxFinal := box.new(europeSessionOpenTime, europeHigh, europeSessionCloseTime, europeLow, bgcolor=europeColor, border_color=color.new(europeColor, 65), xloc=xloc.bar_time)
    if inEurope and not na(europeVisualBoxFinal)
        box.set_right(europeVisualBoxFinal, europeSessionCloseTime)
        box.set_top(europeVisualBoxFinal, europeHigh)
        box.set_bottom(europeVisualBoxFinal, europeLow)
    if (not inEurope and inEurope[1]) and not na(europeVisualBoxFinal)
        box.set_right(europeVisualBoxFinal, europeLastSessionCloseTime)

    if showUSABox
        if usaStart
            f_keepSessionHistory(usaVisualBoxFinal, usaLastSessionCloseTime, historicalUSAColor, "NEW YORK")
            usaVisualBoxFinal := box.new(usaSessionOpenTime, usaHigh, usaSessionCloseTime, usaLow, bgcolor=color.new(usaColor, usaBoxTransparency), border_color=color.new(usaColor, 65), xloc=xloc.bar_time)
        if inUSA and na(usaVisualBoxFinal) and not na(usaStartBar)
            usaVisualBoxFinal := box.new(usaSessionOpenTime, usaHigh, usaSessionCloseTime, usaLow, bgcolor=color.new(usaColor, usaBoxTransparency), border_color=color.new(usaColor, 65), xloc=xloc.bar_time)
        if inUSA and not na(usaVisualBoxFinal)
            box.set_right(usaVisualBoxFinal, usaSessionCloseTime)
            box.set_top(usaVisualBoxFinal, usaHigh)
            box.set_bottom(usaVisualBoxFinal, usaLow)
        if (not inUSA and inUSA[1]) and not na(usaVisualBoxFinal)
            box.set_right(usaVisualBoxFinal, usaLastSessionCloseTime)

    if showEuropePreSession
        if europePreStart
            f_keepSessionHistory(europePreVisualBox, europePreLastCloseTime, historicalEuropePreColor, "EU PRE")
            europePreVisualBox := box.new(europePreOpenTime, europePreHigh, europePreCloseTime, europePreLow, bgcolor=color.new(europePreColor, preSessionTransparency), border_color=color.new(europePreColor, 85), xloc=xloc.bar_time)
        if inEuropePre and not na(europePreVisualBox)
            box.set_right(europePreVisualBox, europePreCloseTime)
            box.set_top(europePreVisualBox, europePreHigh)
            box.set_bottom(europePreVisualBox, europePreLow)
        if (not inEuropePre and inEuropePre[1]) and not na(europePreVisualBox)
            box.set_right(europePreVisualBox, europePreLastCloseTime)

    if showUSAPreSession
        if usaPreStart
            f_keepSessionHistory(usaPreVisualBox, usaPreLastCloseTime, historicalUSAPreColor, "US PRE")
            usaPreVisualBox := box.new(usaPreOpenTime, usaPreHigh, usaPreCloseTime, usaPreLow, bgcolor=color.new(usaPreColor, preSessionTransparency), border_color=color.new(usaPreColor, 85), xloc=xloc.bar_time)
        if inUSAPre and not na(usaPreVisualBox)
            box.set_right(usaPreVisualBox, usaPreCloseTime)
            box.set_top(usaPreVisualBox, usaPreHigh)
            box.set_bottom(usaPreVisualBox, usaPreLow)
        if (not inUSAPre and inUSAPre[1]) and not na(usaPreVisualBox)
            box.set_right(usaPreVisualBox, usaPreLastCloseTime)

// Keep the most recent N calendar days, and cap object usage.
if array.size(sessionHistoryBoxes) > 0
    for i = array.size(sessionHistoryBoxes) - 1 to 0
        expired = array.get(sessionHistoryEndTimes, i) < last_bar_time - sessionHistoryDays * 86400000
        if expired
            box.delete(array.get(sessionHistoryBoxes, i))
            array.remove(sessionHistoryBoxes, i)
            array.remove(sessionHistoryEndTimes, i)
while array.size(sessionHistoryBoxes) > maxHistoricalSessionBoxes
    box.delete(array.shift(sessionHistoryBoxes))
    array.shift(sessionHistoryEndTimes)

asiaHLVisible = not showOnlyCurrentAsiaHL or inAsia
asiaHighBroken = fadeBrokenSessionHL and not na(asiaHigh) and close > asiaHigh
asiaLowBroken = fadeBrokenSessionHL and not na(asiaLow) and close < asiaLow
europeHighBroken = fadeBrokenSessionHL and not na(europeHigh) and close > europeHigh
europeLowBroken = fadeBrokenSessionHL and not na(europeLow) and close < europeLow
usaHighBroken = fadeBrokenSessionHL and not na(usaHigh) and close > usaHigh
usaLowBroken = fadeBrokenSessionHL and not na(usaLow) and close < usaLow


var line asiaHighLine = na
var line asiaLowLine = na
var line europeHighLine = na
var line europeLowLine = na
var line usaHighLine = na
var line usaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na
var label europeHighLabel = na
var label europeLowLabel = na
var label usaHighLabel = na
var label usaLowLabel = na

if barstate.islast and showSessionHL
    if not na(asiaHighLine)
        line.delete(asiaHighLine)
    if not na(asiaLowLine)
        line.delete(asiaLowLine)
    if not na(europeHighLine)
        line.delete(europeHighLine)
    if not na(europeLowLine)
        line.delete(europeLowLine)
    if not na(usaHighLine)
        line.delete(usaHighLine)
    if not na(usaLowLine)
        line.delete(usaLowLine)
    if not na(asiaHighLabel)
        label.delete(asiaHighLabel)
    if not na(asiaLowLabel)
        label.delete(asiaLowLabel)
    if not na(europeHighLabel)
        label.delete(europeHighLabel)
    if not na(europeLowLabel)
        label.delete(europeLowLabel)
    if not na(usaHighLabel)
        label.delete(usaHighLabel)
    if not na(usaLowLabel)
        label.delete(usaLowLabel)

    if asiaHLVisible and not na(asiaStartBar) and not na(asiaHigh) and not na(asiaLow)
        asiaLineStart = math.max(asiaStartBar, bar_index - levelLookbackBars)
        asiaHighLine := line.new(asiaLineStart, asiaHigh, bar_index, asiaHigh, color=asiaHighBroken ? color.new(color.blue, 75) : color.new(color.blue, 0), style=line.style_dashed, width=1)
        asiaLowLine := line.new(asiaLineStart, asiaLow, bar_index, asiaLow, color=asiaLowBroken ? color.new(color.blue, 75) : color.new(color.blue, 0), style=line.style_dashed, width=1)
        if showLevelLabels
            asiaHighLabel := label.new(bar_index, asiaHigh, "Asia H", style=label.style_label_left, color=(fadeEndedSessionHL and not inAsia) or asiaHighBroken ? color.new(color.blue, 75) : color.new(color.blue, 0), textcolor=color.white, size=size.tiny)
            asiaLowLabel := label.new(bar_index, asiaLow, "Asia L", style=label.style_label_left, color=(fadeEndedSessionHL and not inAsia) or asiaLowBroken ? color.new(color.blue, 75) : color.new(color.blue, 0), textcolor=color.white, size=size.tiny)

    if not na(europeStartBar) and not na(europeHigh) and not na(europeLow)
        europeLineStart = math.max(europeStartBar, bar_index - levelLookbackBars)
        europeHighLine := line.new(europeLineStart, europeHigh, bar_index, europeHigh, color=europeHighBroken ? color.new(color.yellow, 70) : color.new(color.yellow, 0), style=line.style_dashed, width=1)
        europeLowLine := line.new(europeLineStart, europeLow, bar_index, europeLow, color=europeLowBroken ? color.new(color.yellow, 70) : color.new(color.yellow, 0), style=line.style_dashed, width=1)
        if showLevelLabels
            europeHighLabel := label.new(bar_index, europeHigh, "EU H", style=label.style_label_left, color=(fadeEndedSessionHL and not inEurope) or europeHighBroken ? color.new(color.yellow, 70) : color.new(color.yellow, 0), textcolor=color.black, size=size.tiny)
            europeLowLabel := label.new(bar_index, europeLow, "EU L", style=label.style_label_left, color=(fadeEndedSessionHL and not inEurope) or europeLowBroken ? color.new(color.yellow, 70) : color.new(color.yellow, 0), textcolor=color.black, size=size.tiny)

    if not na(usaStartBar) and not na(usaHigh) and not na(usaLow)
        usaLineStart = math.max(usaStartBar, bar_index - levelLookbackBars)
        usaHighLine := line.new(usaLineStart, usaHigh, bar_index, usaHigh, color=usaHighBroken ? color.new(color.purple, 70) : color.new(color.purple, 0), style=line.style_dashed, width=1)
        usaLowLine := line.new(usaLineStart, usaLow, bar_index, usaLow, color=usaLowBroken ? color.new(color.purple, 70) : color.new(color.purple, 0), style=line.style_dashed, width=1)
        if showLevelLabels
            usaHighLabel := label.new(bar_index, usaHigh, "US H", style=label.style_label_left, color=(fadeEndedSessionHL and not inUSA) or usaHighBroken ? color.new(color.purple, 70) : color.new(color.purple, 0), textcolor=color.white, size=size.tiny)
            usaLowLabel := label.new(bar_index, usaLow, "US L", style=label.style_label_left, color=(fadeEndedSessionHL and not inUSA) or usaLowBroken ? color.new(color.purple, 70) : color.new(color.purple, 0), textcolor=color.white, size=size.tiny)

var table sessionTable = table.new(position.bottom_right, 1, 6, border_width=1)
if barstate.islast and showSessionTable
    activeSession = inAsia ? "Asia OPEN" : inEuropePre ? "Europe PRE" : inEurope ? "Europe OPEN" : inUSAPre ? "USA PRE" : inUSA ? "USA OPEN" : "No main session"
    activeColor = inAsia ? color.new(color.blue, 0) : inEuropePre ? color.new(color.yellow, 35) : inEurope ? color.new(color.yellow, 0) : inUSAPre ? color.new(color.teal, 35) : inUSA ? color.new(color.purple, 0) : color.new(color.gray, 30)
    table.cell(sessionTable, 0, 0, "Market Sessions", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(sessionTable, 0, 1, "TZ Asia: " + sessionTimezone + " | EU: London | US: New York", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(sessionTable, 0, 2, "Asia: " + asiaSession + " | Europe: " + europeSession, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(sessionTable, 0, 3, "USA: " + usaSession, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(sessionTable, 0, 4, activeSession, bgcolor=activeColor, text_color=color.white)
    if showHTFCleanModeInfo
        table.cell(sessionTable, 0, 5, (showH1StructuralZones ? "H1 STRUCTURAL MODE" : isHigherTF ? "HTF CLEAN MODE" : "LTF FULL MODE") + " | v" + SCRIPT_VERSION, bgcolor=isHigherTF ? color.new(color.gray, 15) : color.new(color.green, 15), text_color=color.white)

// =====================================================
// HTF LEVELS: PDH / PDL / MOP TO LAST CANDLE
// =====================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

plot(showPWH_PWL ? pwh : na, "PWH", color=color.new(color.purple, thinHTFLevels ? 45 : 20), linewidth=1, style=plot.style_linebr)
plot(showPWH_PWL ? pwl : na, "PWL", color=color.new(color.purple, thinHTFLevels ? 45 : 20), linewidth=1, style=plot.style_linebr)
plot(showPMH_PML ? pmh : na, "PMH", color=color.new(color.white, 10), linewidth=2, style=plot.style_linebr)
plot(showPMH_PML ? pml : na, "PML", color=color.new(color.white, 10), linewidth=2, style=plot.style_linebr)

isNewDay = ta.change(time("D")) != 0
var float midnightOpen = na
if isNewDay
    midnightOpen := open

var line pdhLine = na
var line pdlLine = na
var line moLine = na
var label pdhLabel = na
var label pdlLabel = na
var label moLabel = na

if barstate.islast
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(moLine)
        line.delete(moLine)
    if not na(pdhLabel)
        label.delete(pdhLabel)
    if not na(pdlLabel)
        label.delete(pdlLabel)
    if not na(moLabel)
        label.delete(moLabel)

    if showPDH_PDL
        pdhLine := line.new(bar_index - levelLookbackBars, pdh, bar_index, pdh, color=lineColor, width=1)
        pdlLine := line.new(bar_index - levelLookbackBars, pdl, bar_index, pdl, color=lineColor, width=1)
        if showLevelLabels
            pdhLabel := label.new(bar_index, pdh, "PDH", style=label.style_label_left, color=lineColor, textcolor=color.white, size=size.tiny)
            pdlLabel := label.new(bar_index, pdl, "PDL", style=label.style_label_left, color=lineColor, textcolor=color.white, size=size.tiny)

    if showMidnightOpen and not na(midnightOpen)
        moLine := line.new(bar_index - levelLookbackBars, midnightOpen, bar_index, midnightOpen, color=color.new(color.orange, 0), width=1)
        if showLevelLabels
            moLabel := label.new(bar_index, midnightOpen, "MOP", style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)

// =====================================================
// EQH / EQL + LIQUIDITY SWEEP
// =====================================================
recentHigh = ta.highest(high[1], eqLookback)
recentLow = ta.lowest(low[1], eqLookback)

sweepPDLLong = usePDH_PDL and low < pdl and close > pdl
sweepPDHShort = usePDH_PDL and high > pdh and close < pdh
sweepEQLLong = useEQH_EQL and low < recentLow and close > recentLow
sweepEQHShort = useEQH_EQL and high > recentHigh and close < recentHigh

bullSweep = sweepPDLLong or sweepEQLLong
bearSweep = sweepPDHShort or sweepEQHShort
bullSweepLevel = sweepPDLLong ? pdl : recentLow
bearSweepLevel = sweepPDHShort ? pdh : recentHigh

var int lastBullSweepBar = na
var int lastBearSweepBar = na
var float lastBullSweepLow = na
var float lastBearSweepHigh = na

// Smart FIB Lock: when a valid dealing range is active,
// new sweeps do not overwrite the origin anchors until invalidation.
var bool fibLocked = false
maxLiquidityLabels = input.int(25, "Max liquidity labels", minval=5, maxval=200, group="Structure")
liquidityClusterBars = input.int(5, "Liquidity cluster bars", minval=1, maxval=30, group="Structure")
liquidityClusterAtr = input.float(0.20, "Liquidity cluster distance ATR", minval=0.0, step=0.05, group="Structure")
var label[] liquidityLabels = array.new_label()
var label lastBullLiquidityLabel = na
var label lastBearLiquidityLabel = na
var int lastBullLiquidityEventBar = na
var int lastBearLiquidityEventBar = na
var float lastBullLiquidityEventLevel = na
var float lastBearLiquidityEventLevel = na
var int lastBullLiquidityGrade = 0
var int lastBearLiquidityGrade = 0
var label[] weakStructureLabels = array.new_label()

f_trackWeakLabel(_lbl) =>
    if declutterWeakMarkers
        array.push(weakStructureLabels, _lbl)
        if array.size(weakStructureLabels) > maxWeakLabelsVisible
            label.delete(array.shift(weakStructureLabels))


if bullSweep and not fibLocked
    lastBullSweepBar := bar_index
    lastBullSweepLow := low

if bearSweep and not fibLocked
    lastBearSweepBar := bar_index
    lastBearSweepHigh := high

// ATR, body size and volume spike must be defined before sweep grading.

bullRejectWick = bullSweep ? math.min(open, close) - low : 0.0
bearRejectWick = bearSweep ? high - math.max(open, close) : 0.0
bullSweepInstitutional = bullSweep and volumeSpike and bullRejectWick > atr * 0.4
bearSweepInstitutional = bearSweep and volumeSpike and bearRejectWick > atr * 0.4
bullSweepStrong = bullSweep and (close > open or bullRejectWick > atr * 0.25)
bearSweepStrong = bearSweep and (close < open or bearRejectWick > atr * 0.25)
bullSweepGrade = bullSweepInstitutional ? "Institutional" : bullSweepStrong ? "Strong" : "Weak"
bearSweepGrade = bearSweepInstitutional ? "Institutional" : bearSweepStrong ? "Strong" : "Weak"
bullSweepGradeValue = bullSweepInstitutional ? 3 : bullSweepStrong ? 2 : 1
bearSweepGradeValue = bearSweepInstitutional ? 3 : bearSweepStrong ? 2 : 1

bullLiquiditySameCluster = bullSweep and not na(lastBullLiquidityEventBar) and bar_index - lastBullLiquidityEventBar <= liquidityClusterBars and not na(lastBullLiquidityEventLevel) and math.abs(bullSweepLevel - lastBullLiquidityEventLevel) <= atr * liquidityClusterAtr
bearLiquiditySameCluster = bearSweep and not na(lastBearLiquidityEventBar) and bar_index - lastBearLiquidityEventBar <= liquidityClusterBars and not na(lastBearLiquidityEventLevel) and math.abs(bearSweepLevel - lastBearLiquidityEventLevel) <= atr * liquidityClusterAtr

if showSweeps and bullSweep
    if bullLiquiditySameCluster
        lastBullLiquidityEventBar := bar_index
        lastBullLiquidityEventLevel := bullSweepLevel
        if showLtfSweepLabels and not na(lastBullLiquidityLabel) and bullSweepGradeValue > lastBullLiquidityGrade
            label.set_text(lastBullLiquidityLabel, "Liquidity Purge - Sell-side | " + bullSweepGrade)
            label.set_xy(lastBullLiquidityLabel, bar_index, bullSweepLevel)
            lastBullLiquidityGrade := bullSweepGradeValue
    else
        line.new(bar_index - 1, bullSweepLevel, bar_index + 10, bullSweepLevel, color=color.new(color.lime, 0), style=line.style_dashed, width=1)
        if showLtfSweepLabels
            lastBullLiquidityLabel := label.new(bar_index, bullSweepLevel, "Liquidity Purge - Sell-side | " + bullSweepGrade, style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)
            array.push(liquidityLabels, lastBullLiquidityLabel)
            if array.size(liquidityLabels) > maxLiquidityLabels
                label.delete(array.shift(liquidityLabels))
        lastBullLiquidityEventBar := bar_index
        lastBullLiquidityEventLevel := bullSweepLevel
        lastBullLiquidityGrade := bullSweepGradeValue

if showSweeps and bearSweep
    if bearLiquiditySameCluster
        lastBearLiquidityEventBar := bar_index
        lastBearLiquidityEventLevel := bearSweepLevel
        if showLtfSweepLabels and not na(lastBearLiquidityLabel) and bearSweepGradeValue > lastBearLiquidityGrade
            label.set_text(lastBearLiquidityLabel, "Liquidity Purge - Buy-side | " + bearSweepGrade)
            label.set_xy(lastBearLiquidityLabel, bar_index, bearSweepLevel)
            lastBearLiquidityGrade := bearSweepGradeValue
    else
        line.new(bar_index - 1, bearSweepLevel, bar_index + 10, bearSweepLevel, color=color.new(color.red, 0), style=line.style_dashed, width=1)
        if showLtfSweepLabels
            lastBearLiquidityLabel := label.new(bar_index, bearSweepLevel, "Liquidity Purge - Buy-side | " + bearSweepGrade, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
            array.push(liquidityLabels, lastBearLiquidityLabel)
            if array.size(liquidityLabels) > maxLiquidityLabels
                label.delete(array.shift(liquidityLabels))
        lastBearLiquidityEventBar := bar_index
        lastBearLiquidityEventLevel := bearSweepLevel
        lastBearLiquidityGrade := bearSweepGradeValue

// =====================================================
// MARKET STRUCTURE: INTERNAL / EXTERNAL SWINGS, MSS, CHOCH, BOS, INDUCEMENT, EXHAUSTION
// =====================================================
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)
extPivotHigh = ta.pivothigh(high, externalSwingLen, externalSwingLen)
extPivotLow = ta.pivotlow(low, externalSwingLen, externalSwingLen)

var float lastSwingHigh = na
var int lastSwingHighBar = na
var float lastSwingLow = na
var int lastSwingLowBar = na

var float lastExtSwingHigh = na
var int lastExtSwingHighBar = na
var float lastExtSwingLow = na
var int lastExtSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - swingLen

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - swingLen

if not na(extPivotHigh)
    lastExtSwingHigh := extPivotHigh
    lastExtSwingHighBar := bar_index - externalSwingLen

if not na(extPivotLow)
    lastExtSwingLow := extPivotLow
    lastExtSwingLowBar := bar_index - externalSwingLen

bullSweepActive = not na(lastBullSweepBar) and bar_index - lastBullSweepBar <= maxBarsAfterSweep
bearSweepActive = not na(lastBearSweepBar) and bar_index - lastBearSweepBar <= maxBarsAfterSweep
nyJudasAllowedAfterSweep = not useNyJudasOnlyAfterSweep or bullSweepActive or bearSweepActive

bullDisplacement = close > open and bodySize > atr * atrMultiplier
bearDisplacement = close < open and bodySize > atr * atrMultiplier
bullDisplacementConfirmed = not requireTwoDisplacementCandles or (bullDisplacement and bullDisplacement[1])
bearDisplacementConfirmed = not requireTwoDisplacementCandles or (bearDisplacement and bearDisplacement[1])

bullMssContinuationOk = bullDisplacementConfirmed or (bullDisplacement and bodySize > atr * (mssBodyAtrFilter + 0.35))
bearMssContinuationOk = bearDisplacementConfirmed or (bearDisplacement and bodySize > atr * (mssBodyAtrFilter + 0.35))

// MSS must break structure with real candle body and displacement.
bullMSS = bullSweepActive and not na(lastSwingHigh) and close > lastSwingHigh and open < lastSwingHigh and bodySize > atr * mssBodyAtrFilter and bullMssContinuationOk and mssDistanceFromEmaOk and (not useMssEmaSlopeFilter or emaSlopeBull) and bar_index > lastBullSweepBar
bearMSS = bearSweepActive and not na(lastSwingLow) and close < lastSwingLow and open > lastSwingLow and bodySize > atr * mssBodyAtrFilter and bearMssContinuationOk and mssDistanceFromEmaOk and (not useMssEmaSlopeFilter or emaSlopeBear) and bar_index > lastBearSweepBar

bullMSS := useMssTrendFilter ? bullMSS and trendBull : bullMSS
bearMSS := useMssTrendFilter ? bearMSS and trendBear : bearMSS

strongBullImpulse = bullDisplacement and volumeSpike and bullMSS
strongBearImpulse = bearDisplacement and volumeSpike and bearMSS

if dynamicUSABoxEnd and inUSA and na(usaManipulationEndBar)
    if bullMSS or bearMSS or strongBullImpulse or strongBearImpulse
        usaManipulationEndBar := bar_index
bgcolor(strongBullImpulse and showLtfInternal ? color.new(color.lime, 88) : na)
bgcolor(strongBearImpulse and showLtfInternal ? color.new(color.red, 88) : na)

// NORMAL MSS
plotshape(showMSS and showLtfMSS and bullMSS and not strongBullImpulse, title="Bullish MSS", text="MSS", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 20), textcolor=color.black, size=size.small)
plotshape(showMSS and showLtfMSS and bearMSS and not strongBearImpulse, title="Bearish MSS", text="MSS", style=shape.triangledown, location=location.abovebar, color=color.new(color.orange, 20), textcolor=color.white, size=size.small)

// STRONG MSS
plotshape(showMSS and showLtfMSS and strongBullImpulse, title="Strong Bullish MSS", text="STRONG MSS", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
plotshape(showMSS and showLtfMSS and strongBearImpulse, title="Strong Bearish MSS", text="STRONG MSS", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

// Market state:
//  1 = bullish delivery
// -1 = bearish delivery
//  0 = neutral / undefined
var int marketState = 0

rawBullBreak = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
rawBearBreak = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

structureBullDisplacement = close > open and bodySize > atr * structureAtrFilter
structureBearDisplacement = close < open and bodySize > atr * structureAtrFilter

// CHOCH should represent change of character, not every local swing break.
// It is stronger when it appears against the current market state and has displacement.
// True CHOCH / BOS separation.
// CHOCH = first change of character against current delivery.
// BOS = continuation break in the current delivery direction.
bullCHOCH = rawBullBreak and (not showConfirmedCHOCH or (marketState <= 0 and structureBullDisplacement))
bearCHOCH = rawBearBreak and (not showConfirmedCHOCH or (marketState >= 0 and structureBearDisplacement))

bullBOS = rawBullBreak and structureBullDisplacement and marketState > 0
bearBOS = rawBearBreak and structureBearDisplacement and marketState < 0

externalBullBreak = not na(lastExtSwingHigh) and close > lastExtSwingHigh and close[1] <= lastExtSwingHigh
externalBearBreak = not na(lastExtSwingLow) and close < lastExtSwingLow and close[1] >= lastExtSwingLow
externalBullBOS = externalBullBreak and structureBullDisplacement
externalBearBOS = externalBearBreak and structureBearDisplacement
externalBullCHOCH = externalBullBreak and marketState <= 0 and structureBullDisplacement
externalBearCHOCH = externalBearBreak and marketState >= 0 and structureBearDisplacement

if bullCHOCH or bullBOS
    marketState := 1
if bearCHOCH or bearBOS
    marketState := -1

plotshape((showCHOCH and showLtfInternal and bullCHOCH) and not isTrueHTFMode, title="Bullish CHOCH", text="CHOCH", style=shape.labelup, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.small)
plotshape((showCHOCH and showLtfInternal and bearCHOCH) and not isTrueHTFMode, title="Bearish CHOCH", text="CHOCH", style=shape.labeldown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
plotshape((showBOS and showLtfInternal and bullBOS) and not isTrueHTFMode, title="Bullish BOS", text="BOS", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.tiny)
plotshape((showBOS and showLtfInternal and bearBOS) and not isTrueHTFMode, title="Bearish BOS", text="BOS", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

plotshape((showExternalStructure and externalBullCHOCH) and not isTrueHTFMode, title="External Bullish CHOCH", text="EXT CHOCH", style=shape.labelup, location=location.belowbar, color=color.new(color.blue, 0), textcolor=color.white, size=size.small)
plotshape((showExternalStructure and externalBearCHOCH) and not isTrueHTFMode, title="External Bearish CHOCH", text="EXT CHOCH", style=shape.labeldown, location=location.abovebar, color=color.new(color.purple, 0), textcolor=color.white, size=size.small)
plotshape((showExternalStructure and externalBullBOS and not externalBullCHOCH) and not isTrueHTFMode, title="External Bullish BOS", text="EXT BOS", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
plotshape((showExternalStructure and externalBearBOS and not externalBearCHOCH) and not isTrueHTFMode, title="External Bearish BOS", text="EXT BOS", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

// Smart Inducement: confirmed local pivot liquidity sweep + rejection.
indPivotHigh = ta.pivothigh(high, inducementPivotLen, inducementPivotLen)
indPivotLow = ta.pivotlow(low, inducementPivotLen, inducementPivotLen)
var float lastIndPivotHigh = na
var float lastIndPivotLow = na
var int lastBullInducementBar = na
var int lastBearInducementBar = na
var float lastBullInducementLevel = na
var float lastBearInducementLevel = na
if not na(indPivotHigh)
    lastIndPivotHigh := indPivotHigh
if not na(indPivotLow)
    lastIndPivotLow := indPivotLow
bullIndWick = math.min(open, close) - low
bearIndWick = high - math.max(open, close)
bullIndCooldownOk = na(lastBullInducementBar) or bar_index - lastBullInducementBar >= inducementCooldownBars
bearIndCooldownOk = na(lastBearInducementBar) or bar_index - lastBearInducementBar >= inducementCooldownBars
bullIndNewLevel = na(lastBullInducementLevel) or na(lastIndPivotLow) or math.abs(lastIndPivotLow - lastBullInducementLevel) > atr * inducementMinSweepAtr
bearIndNewLevel = na(lastBearInducementLevel) or na(lastIndPivotHigh) or math.abs(lastIndPivotHigh - lastBearInducementLevel) > atr * inducementMinSweepAtr
bullIndTrendOk = not inducementTrendFilter or marketState >= 0
bearIndTrendOk = not inducementTrendFilter or marketState <= 0
bullInducement = not na(lastIndPivotLow) and low < lastIndPivotLow - atr * inducementMinSweepAtr and close > lastIndPivotLow and bullIndWick >= atr * inducementMinWickAtr and bullIndCooldownOk and bullIndNewLevel and bullIndTrendOk
bearInducement = not na(lastIndPivotHigh) and high > lastIndPivotHigh + atr * inducementMinSweepAtr and close < lastIndPivotHigh and bearIndWick >= atr * inducementMinWickAtr and bearIndCooldownOk and bearIndNewLevel and bearIndTrendOk
if bullInducement
    lastBullInducementBar := bar_index
    lastBullInducementLevel := lastIndPivotLow
if bearInducement
    lastBearInducementBar := bar_index
    lastBearInducementLevel := lastIndPivotHigh

// Exhaustion: lokalny sweep bez kontynuacji impulsu.
// Filtry ograniczają szum: knot ATR, sweep liquidity i premium/discount.
bullExhWick = high - math.max(open, close)
bearExhWick = math.min(open, close) - low
bullExhBase = high > high[1] and close < high[1]
bearExhBase = low < low[1] and close > low[1]
bullExhStrictOk = not useStrictExhaustion or (bullExhWick > atr * exhaustionMinWickAtr and (not exhaustionOnlyAfterSweep or bearSweep) and (not exhaustionPremiumDiscountOnly or premiumZone))
bearExhStrictOk = not useStrictExhaustion or (bearExhWick > atr * exhaustionMinWickAtr and (not exhaustionOnlyAfterSweep or bullSweep) and (not exhaustionPremiumDiscountOnly or discountZone))
bullExhaustion = bullExhBase and bullExhStrictOk
bearExhaustion = bearExhBase and bearExhStrictOk
plotshape(showInducement and showLtfInducement and bullInducement and not isTrueHTFMode, title="Bull Inducement", text="IND", style=shape.diamond, location=location.belowbar, color=color.new(color.orange, declutterWeakMarkers ? weakMarkerTransparency : 0), textcolor=color.black, size=size.tiny)
plotshape(showInducement and showLtfInducement and bearInducement and not isTrueHTFMode, title="Bear Inducement", text="IND", style=shape.diamond, location=location.abovebar, color=color.new(color.orange, declutterWeakMarkers ? weakMarkerTransparency : 0), textcolor=color.black, size=size.tiny)

plotshape(showExhaustion and bullExhaustion and not isTrueHTFMode, title="Bull Exhaustion", text="EXH", style=shape.circle, location=location.abovebar, color=color.new(color.red, declutterWeakMarkers ? weakMarkerTransparency : 0), textcolor=color.white, size=size.tiny)
plotshape(showExhaustion and bearExhaustion and not isTrueHTFMode, title="Bear Exhaustion", text="EXH", style=shape.circle, location=location.belowbar, color=color.new(color.lime, declutterWeakMarkers ? weakMarkerTransparency : 0), textcolor=color.black, size=size.tiny)

// =====================================================
// STRUCTURE ENGINE 2.0
// Pivot -> first valid close through pivot -> finite BOS/CHOCH line.
// Each pivot can be crossed only once.
// =====================================================
var float s2IntHigh = na
var float s2IntLow = na
var int s2IntHighBar = na
var int s2IntLowBar = na
var bool s2IntHighCrossed = false
var bool s2IntLowCrossed = false
var int s2IntBias = 0

var float s2SwingHigh = na
var float s2SwingLow = na
var int s2SwingHighBar = na
var int s2SwingLowBar = na
var bool s2SwingHighCrossed = false
var bool s2SwingLowCrossed = false
var int s2SwingBias = 0

s2IntPH = ta.pivothigh(high, structure2InternalLen, structure2InternalLen)
s2IntPL = ta.pivotlow(low, structure2InternalLen, structure2InternalLen)
s2SwingPH = ta.pivothigh(high, structure2SwingLen, structure2SwingLen)
s2SwingPL = ta.pivotlow(low, structure2SwingLen, structure2SwingLen)

if not na(s2IntPH)
    s2IntHigh := s2IntPH
    s2IntHighBar := bar_index - structure2InternalLen
    s2IntHighCrossed := false
if not na(s2IntPL)
    s2IntLow := s2IntPL
    s2IntLowBar := bar_index - structure2InternalLen
    s2IntLowCrossed := false
if not na(s2SwingPH)
    s2SwingHigh := s2SwingPH
    s2SwingHighBar := bar_index - structure2SwingLen
    s2SwingHighCrossed := false
if not na(s2SwingPL)
    s2SwingLow := s2SwingPL
    s2SwingLowBar := bar_index - structure2SwingLen
    s2SwingLowCrossed := false

s2IntBullBreak = structure2Enabled and not na(s2IntHigh) and not s2IntHighCrossed and close > s2IntHigh
s2IntBearBreak = structure2Enabled and not na(s2IntLow) and not s2IntLowCrossed and close < s2IntLow
s2SwingBullBreak = structure2Enabled and not na(s2SwingHigh) and not s2SwingHighCrossed and close > s2SwingHigh
s2SwingBearBreak = structure2Enabled and not na(s2SwingLow) and not s2SwingLowCrossed and close < s2SwingLow

s2IntBullCHOCH = s2IntBullBreak and s2IntBias == -1
s2IntBearCHOCH = s2IntBearBreak and s2IntBias == 1
s2SwingBullCHOCH = s2SwingBullBreak and s2SwingBias == -1
s2SwingBearCHOCH = s2SwingBearBreak and s2SwingBias == 1

if s2IntBullBreak
    s2IntHighCrossed := true
    if showInternalStructure2 and showLtfInternal
        line.new(s2IntHighBar, s2IntHigh, bar_index, s2IntHigh, color=color.new(color.teal, 45), style=line.style_dashed, width=1)
        label.new(math.round((s2IntHighBar + bar_index) / 2), s2IntHigh, s2IntBullCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=color.new(color.teal, 25), size=size.tiny)
    s2IntBias := 1

if s2IntBearBreak
    s2IntLowCrossed := true
    if showInternalStructure2 and showLtfInternal
        line.new(s2IntLowBar, s2IntLow, bar_index, s2IntLow, color=color.new(color.red, 45), style=line.style_dashed, width=1)
        label.new(math.round((s2IntLowBar + bar_index) / 2), s2IntLow, s2IntBearCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=color.new(color.red, 25), size=size.tiny)
    s2IntBias := -1

if s2SwingBullBreak
    s2SwingHighCrossed := true
    if showSwingStructure2 and structureShowAllowed
        line.new(s2SwingHighBar, s2SwingHigh, bar_index, s2SwingHigh, color=color.new(color.aqua, 0), style=line.style_solid, width=2)
        label.new(math.round((s2SwingHighBar + bar_index) / 2), s2SwingHigh, s2SwingBullCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=color.aqua, size=size.small)
    s2SwingBias := 1

if s2SwingBearBreak
    s2SwingLowCrossed := true
    if showSwingStructure2 and structureShowAllowed
        line.new(s2SwingLowBar, s2SwingLow, bar_index, s2SwingLow, color=color.new(color.red, 0), style=line.style_solid, width=2)
        label.new(math.round((s2SwingLowBar + bar_index) / 2), s2SwingLow, s2SwingBearCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=color.red, size=size.small)
    s2SwingBias := -1

// =====================================================
// DYNAMIC ICT FIBO ENGINE
// =====================================================
var float activeSwingLow = na
var float activeSwingHigh = na
var int activeSwingStartBar = na
var bool fibBullish = false
var bool fibDirectionValid = false
var bool fib127Active = false
var bool fib1618Active = false
var bool fibInvalidated = false
var bool activeDealingRange = false
var int lastFibResetBar = na

var float fib050 = na
var float fib0618 = na
var float fib127 = na
var float fib1618 = na
var bool fibInternalActive = true

// New FIBO range should be created only from a real impulse:
// sweep -> MSS/CHOCH/BOS -> displacement.
// Origin is preferably the swept low/high, not the nearest micro swing.
bullTrendAligned = ema21 > ema50 and close > ema50
bearTrendAligned = ema21 < ema50 and close < ema50
isFastIntraday = timeframe.isminutes and timeframe.multiplier <= 5

if fastFiboReset5m and isFastIntraday and activeDealingRange and fibDirectionValid
    if fibBullish and bearMSS and bearDisplacement and close < ema21
        fibInvalidated := true
        fibLocked := false
        fib127Active := false
        fib1618Active := false
        activeDealingRange := false
    if not fibBullish and bullMSS and bullDisplacement and close > ema21
        fibInvalidated := true
        fibLocked := false
        fib127Active := false
        fib1618Active := false
        activeDealingRange := false

// ICT intraday impulse leg anchors.
// For M1/M5 we measure the latest delivery leg instead of the whole large swing.
bullImpulseLow = ta.lowest(low[1], fiboImpulseLookback)
bullImpulseLowBarOffset = ta.lowestbars(low[1], fiboImpulseLookback)
bullImpulseLowBar = bar_index - 1 - math.abs(bullImpulseLowBarOffset)

bearImpulseHigh = ta.highest(high[1], fiboImpulseLookback)
bearImpulseHighBarOffset = ta.highestbars(high[1], fiboImpulseLookback)
bearImpulseHighBar = bar_index - 1 - math.abs(bearImpulseHighBarOffset)

// Wider ICT dealing-leg anchors.
// These prevent FIB from using a tiny NY Judas / micro pullback candle as origin.
bullDealingLow = ta.lowest(low[1], dealingLegLookback)
bullDealingLowBarOffset = ta.lowestbars(low[1], dealingLegLookback)
bullDealingLowBar = bar_index - 1 - math.abs(bullDealingLowBarOffset)

bearDealingHigh = ta.highest(high[1], dealingLegLookback)
bearDealingHighBarOffset = ta.highestbars(high[1], dealingLegLookback)
bearDealingHighBar = bar_index - 1 - math.abs(bearDealingHighBarOffset)

candidateBullRange = math.abs(high - bullDealingLow)
candidateBearRange = math.abs(bearDealingHigh - low)
bullImpulseSizeOk = candidateBullRange >= atr * minImpulseATR
bearImpulseSizeOk = candidateBearRange >= atr * minImpulseATR

validBullFibImpulse = (bullMSS or bullCHOCH or bullBOS) and bullDisplacementConfirmed and bullImpulseSizeOk
validBearFibImpulse = (bearMSS or bearCHOCH or bearBOS) and bearDisplacementConfirmed and bearImpulseSizeOk
externalStructureShift = externalBullCHOCH or externalBearCHOCH or externalBullBOS or externalBearBOS
fibResetCooldownOk = not smartFibLock or na(lastFibResetBar) or bar_index - lastFibResetBar >= (smarterContinuationFib ? minBarsBetweenFibReset * 2 : minBarsBetweenFibReset)
allowNewFibRange = fibResetCooldownOk and (not activeDealingRange or fibInvalidated or (not fib127Active and not fib1618Active) or externalStructureShift)

if resetFibOnNewMSS and validBullFibImpulse and allowNewFibRange
    fibInvalidated := false
    // If enabled, measure the whole displacement leg, not only one candle.
    // Bullish leg: last internal swing low -> current displacement high.
    fibOriginLow = useConfirmedDealingLegOnly and not na(bullDealingLow) ? bullDealingLow : useDisplacementLegOnly and not na(bullDealingLow) ? bullDealingLow : fiboUseSweepOrigin and not na(lastBullSweepLow) ? lastBullSweepLow : lastSwingLow
    fibOriginHigh = high
    fibOriginBar = useConfirmedDealingLegOnly and not na(bullDealingLowBar) ? bullDealingLowBar : useDisplacementLegOnly and not na(bullDealingLowBar) ? bullDealingLowBar : fiboUseSweepOrigin and not na(lastBullSweepBar) ? lastBullSweepBar : lastSwingLowBar
    activeSwingLow := fibOriginLow
    activeSwingHigh := fibOriginHigh
    activeSwingStartBar := na(fibOriginBar) ? bar_index : fibOriginBar
    fibBullish := true
    fibDirectionValid := true
    fibLocked := true
    fib127Active := true
    fib1618Active := true
    fibInternalActive := true
    fibInvalidated := false
    activeDealingRange := true
    lastFibResetBar := bar_index

if resetFibOnNewMSS and validBearFibImpulse and allowNewFibRange
    fibInvalidated := false
    // If enabled, measure the whole displacement leg, not only one candle.
    // Bearish leg: last internal swing high -> current displacement low.
    fibOriginHigh = useConfirmedDealingLegOnly and not na(bearDealingHigh) ? bearDealingHigh : useDisplacementLegOnly and not na(bearDealingHigh) ? bearDealingHigh : fiboUseSweepOrigin and not na(lastBearSweepHigh) ? lastBearSweepHigh : lastSwingHigh
    fibOriginLow = low
    fibOriginBar = useConfirmedDealingLegOnly and not na(bearDealingHighBar) ? bearDealingHighBar : useDisplacementLegOnly and not na(bearDealingHighBar) ? bearDealingHighBar : fiboUseSweepOrigin and not na(lastBearSweepBar) ? lastBearSweepBar : lastSwingHighBar
    activeSwingHigh := fibOriginHigh
    activeSwingLow := fibOriginLow
    activeSwingStartBar := na(fibOriginBar) ? bar_index : fibOriginBar
    fibBullish := false
    fibDirectionValid := true
    fibLocked := true
    fib127Active := true
    fib1618Active := true
    fibInternalActive := true
    fibInvalidated := false
    activeDealingRange := true
    lastFibResetBar := bar_index

fibRange = math.abs(activeSwingHigh - activeSwingLow)
dealingEq = (activeSwingHigh + activeSwingLow) / 2.0
fibTarget1Mult = adaptiveCryptoTargets and isCryptoMarket ? cryptoTarget1 : 1.27
fibTarget2Mult = adaptiveCryptoTargets and isCryptoMarket ? cryptoTarget2 : 1.618

if invalidateFibOn100Break and not na(activeSwingLow) and not na(activeSwingHigh) and fibDirectionValid
    // Bullish dealing range invalidation: price closes below 100% origin.
    if fibBullish and close < activeSwingLow
        fibInvalidated := true
        fibLocked := false
        fib127Active := false
        fib1618Active := false
        activeDealingRange := false

    // Bearish dealing range invalidation: price closes above 100% origin.
    if not fibBullish and close > activeSwingHigh
        fibInvalidated := true
        fibLocked := false
        fib127Active := false
        fib1618Active := false
        activeDealingRange := false

// Early invalidation of active dealing range after opposite MSS + displacement.
// This prevents old bullish/bearish range from staying alive after real reversal.
invalidateBullRangeEarly = not na(dealingEq) and fibBullish and bearMSS and bearDisplacement and close < dealingEq and close < ema21
invalidateBearRangeEarly = not na(dealingEq) and not fibBullish and bullMSS and bullDisplacement and close > dealingEq and close > ema21

if invalidateBullRangeEarly or invalidateBearRangeEarly
    fibInvalidated := true
    fibLocked := false
    fib127Active := false
    fib1618Active := false
    activeDealingRange := false

if hideFibAfterEqMitigation and showAutoFibo and showLtfFib and not fibInvalidated and not na(activeSwingLow) and not na(activeSwingHigh) and fibRange > syminfo.mintick
    if fibBullish and low <= dealingEq
        fibInvalidated := true
        fibLocked := false
        activeDealingRange := false
    if not fibBullish and high >= dealingEq
        fibInvalidated := true
        fibLocked := false
        activeDealingRange := false

validFib = showAutoFibo and showLtfFib and not fibInvalidated and not na(activeSwingLow) and not na(activeSwingHigh) and fibRange > syminfo.mintick

if fadeInternalFibAfterContinuation and validFib
    if fibBullish and close > activeSwingHigh and close[1] <= activeSwingHigh
        fibInternalActive := false
    if not fibBullish and close < activeSwingLow and close[1] >= activeSwingLow
        fibInternalActive := false
plot(validFib ? dealingEq : na, title="ICT Active Dealing Range EQ", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr)
fibPremium = validFib and close > dealingEq
fibDiscount = validFib and close < dealingEq
bgcolor(showPDBackground and fibPremium ? color.new(color.red, 94) : na)
bgcolor(showPDBackground and fibDiscount ? color.new(color.green, 94) : na)

if validFib
    if fibBullish
        fib050 := activeSwingHigh - fibRange * 0.5
        fib0618 := activeSwingHigh - fibRange * 0.618
        fib127 := activeSwingLow + fibRange * fibTarget1Mult
        fib1618 := activeSwingLow + fibRange * fibTarget2Mult
    else
        fib050 := activeSwingLow + fibRange * 0.5
        fib0618 := activeSwingLow + fibRange * 0.618
        fib127 := activeSwingHigh - fibRange * fibTarget1Mult
        fib1618 := activeSwingHigh - fibRange * fibTarget2Mult

    if removeFibTargetHit and fib127Active
        if fibBullish and high >= fib127
            fib127Active := false
        if not fibBullish and low <= fib127
            fib127Active := false

    if removeFibTargetHit and fib1618Active
        if fibBullish and high >= fib1618
            fib1618Active := false
        if not fibBullish and low <= fib1618
            fib1618Active := false

    if not fib127Active and not fib1618Active
        fibLocked := false
        activeDealingRange := false

var line fib050Line = na
var line fib0618Line = na
var line fib127Line = na
var line fib1618Line = na
var label fib050Label = na
var label fib0618Label = na
var label fib127Label = na
var label fib1618Label = na

if barstate.islast
    if not na(fib050Line)
        line.delete(fib050Line)
    if not na(fib0618Line)
        line.delete(fib0618Line)
    if not na(fib127Line)
        line.delete(fib127Line)
    if not na(fib1618Line)
        line.delete(fib1618Line)
    if not na(fib050Label)
        label.delete(fib050Label)
    if not na(fib0618Label)
        label.delete(fib0618Label)
    if not na(fib127Label)
        label.delete(fib127Label)
    if not na(fib1618Label)
        label.delete(fib1618Label)

    if validFib
        fibStartBar = na(activeSwingStartBar) ? bar_index - fiboLookbackBars : math.max(activeSwingStartBar, bar_index - fiboLookbackBars)
        fibLabelX = bar_index + fiboLabelOffsetBars
        fibStackOffset = atr * fiboLabelStackAtr
        fib050LabelY = fiboAvoidEmaLabels and math.abs(fib050 - ema100) < atr * fiboEmaAvoidAtr ? fib050 + atr * fiboEmaAvoidAtr : fib050
        fib0618LabelY = fiboAvoidEmaLabels and math.abs(fib0618 - ema100) < atr * fiboEmaAvoidAtr ? fib0618 - atr * fiboEmaAvoidAtr : fib0618
        if showFiboInternal and fibInternalActive
            fib050Line := line.new(fibStartBar, fib050, bar_index, fib050, color=fibo50Color, style=line.style_solid, width=fiboLineWidth)
            fib0618Line := line.new(fibStartBar, fib0618, bar_index, fib0618, color=fibo618Color, style=line.style_solid, width=fiboLineWidth)
            fib050Label := label.new(fibLabelX, fib050LabelY + fibStackOffset, fiboShowPrice ? "FIB 0.5 " + str.tostring(fib050, format.mintick) : "FIB 0.5", style=label.style_label_left, color=fibo50Color, textcolor=color.black, size=size.small)
            fib0618Label := label.new(fibLabelX, fib0618LabelY - fibStackOffset, fiboShowPrice ? "FIB 0.618 " + str.tostring(fib0618, format.mintick) : "FIB 0.618", style=label.style_label_left, color=fibo618Color, textcolor=color.black, size=size.small)
        if showFiboExternal and fib127Active
            fib127Line := line.new(fibStartBar, fib127, bar_index, fib127, color=fibo127Color, style=line.style_dashed, width=fiboLineWidth)
            fib127Label := label.new(fibLabelX, fib127, fiboShowPrice ? "TP " + str.tostring(fibTarget1Mult) + " " + str.tostring(fib127, format.mintick) : "TP " + str.tostring(fibTarget1Mult), style=label.style_label_left, color=fibo127Color, textcolor=color.white, size=size.small)
        if showFiboExternal and fib1618Active
            fib1618Line := line.new(fibStartBar, fib1618, bar_index, fib1618, color=fibo1618Color, style=line.style_dashed, width=fiboLineWidth)
            fib1618Label := label.new(fibLabelX, fib1618, fiboShowPrice ? "TP " + str.tostring(fibTarget2Mult) + " " + str.tostring(fib1618, format.mintick) : "TP " + str.tostring(fibTarget2Mult), style=label.style_label_left, color=fibo1618Color, textcolor=color.white, size=size.small)

// Reset sweep after MSS, but after FIBO can read it.
if bullMSS and not fibLocked
    lastBullSweepBar := na
if bearMSS and not fibLocked
    lastBearSweepBar := na

// =====================================================
// FVG DETECTION + SIGNALS
// =====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]
fvgQuality = bodySize > atr * 2 and volumeSpike ? 3 : bodySize > atr * 1.5 ? 2 : 1
highQualityFVG = fvgQuality >= 2
fvgStrength = fvgQuality == 3 ? "A+" : fvgQuality == 2 ? "A" : "B"

// =====================================================
// SMT CALCULATION
// =====================================================
corHigh = request.security(smtSymbol, timeframe.period, high)
corLow = request.security(smtSymbol, timeframe.period, low)
corClose = request.security(smtSymbol, timeframe.period, close)

thisLL = low < ta.lowest(low[1], smtLookback)
corLL = corLow < ta.lowest(corLow[1], smtLookback)
thisHH = high > ta.highest(high[1], smtLookback)
corHH = corHigh > ta.highest(corHigh[1], smtLookback)

bullSMT = thisLL and not corLL
bearSMT = thisHH and not corHH

// =====================================================
// PROBABILITY SCORE ENGINE
// =====================================================
bullProbScore = 0
bullProbScore += bullSweep ? 2 : 0
bullProbScore += bullMSS ? 3 : 0
bullProbScore += bullCHOCH ? 2 : 0
bullProbScore += bullBOS ? 2 : 0
bullProbScore += discountZone ? 1 : 0
bullProbScore += bullDisplacement ? 2 : 0
bullProbScore += volumeSpike ? 1 : 0
bullProbScore += validICTWindow ? 1 : 0
bullProbScore += bullSMT ? 2 : 0
bullProbScore += trendBull ? 1 : 0

bearProbScore = 0
bearProbScore += bearSweep ? 2 : 0
bearProbScore += bearMSS ? 3 : 0
bearProbScore += bearCHOCH ? 2 : 0
bearProbScore += bearBOS ? 2 : 0
bearProbScore += premiumZone ? 1 : 0
bearProbScore += bearDisplacement ? 2 : 0
bearProbScore += volumeSpike ? 1 : 0
bearProbScore += validICTWindow ? 1 : 0
bearProbScore += bearSMT ? 2 : 0
bearProbScore += trendBear ? 1 : 0

bullProbOk = not showProbabilityScore or bullProbScore >= minimumProbabilityScore
bearProbOk = not showProbabilityScore or bearProbScore >= minimumProbabilityScore

// =====================================================
// TRADE SCORING ENGINE
// =====================================================
bullScore = 0
bullScore += bullSweep ? 2 : 0
bullScore += bullMSS ? 2 : 0
bullScore += bullDisplacement ? 2 : 0
bullScore += bullSMT ? 2 : 0
bullScore += discountZone ? 2 : 0
bullScore += validICTWindow ? 1 : 0
bullScore += volumeSpike ? 1 : 0

bearScore = 0
bearScore += bearSweep ? 2 : 0
bearScore += bearMSS ? 2 : 0
bearScore += bearDisplacement ? 2 : 0
bearScore += bearSMT ? 2 : 0
bearScore += premiumZone ? 2 : 0
bearScore += validICTWindow ? 1 : 0
bearScore += volumeSpike ? 1 : 0

scoreThreshold = showOnlyAPlusSetups ? aPlusScore : minimumScore
bullSignalBase = bullMSS and bullFVG and discountZone and validICTWindow
bearSignalBase = bearMSS and bearFVG and premiumZone and validICTWindow
bullSignal = (fvgMode == "Aggressive" ? bullSignalBase : fvgMode == "Balanced" ? bullSignalBase and bullScore >= minimumScore and (not useDisplacement or bullDisplacement) : bullSignalBase and bullScore >= aPlusScore and (not useDisplacement or bullDisplacement) and (not useVolumeFilter or volumeSpike)) and highQualityFVG and bullTrendScoreOk and bullImpulseSizeOk and bullProbOk
bearSignal = (fvgMode == "Aggressive" ? bearSignalBase : fvgMode == "Balanced" ? bearSignalBase and bearScore >= minimumScore and (not useDisplacement or bearDisplacement) : bearSignalBase and bearScore >= aPlusScore and (not useDisplacement or bearDisplacement) and (not useVolumeFilter or volumeSpike)) and highQualityFVG and bearTrendScoreOk and bearImpulseSizeOk and bearProbOk

// =====================================================
// ORDER BLOCK ENGINE 2.0
// Searches backwards from a structure break for the origin opposite candle.
// Active zones extend until invalidated; no "Mitigated OB" text.
var box[] obBoxes = array.new_box()
var float[] obTops = array.new_float()
var float[] obBottoms = array.new_float()
var int[] obDirs = array.new_int()
var label[] obLabels = array.new_label()

newBullStructureBreak = showH1StructuralZones ? s2SwingBullBreak : (s2IntBullBreak or s2SwingBullBreak)
newBearStructureBreak = showH1StructuralZones ? s2SwingBearBreak : (s2IntBearBreak or s2SwingBearBreak)

if showOB and ob2Enabled and showStructuralOB and newBullStructureBreak
    int origin = na
    for k = 1 to ob2SearchBars
        if na(origin) and close[k] < open[k]
            origin := k
    if not na(origin)
        top = high[origin]
        bottom = low[origin]
        ob = box.new(bar_index - origin, top, bar_index, bottom, bgcolor=bullOBColor, border_color=color.new(color.lime, 45))
        array.push(obBoxes, ob), array.push(obTops, top), array.push(obBottoms, bottom), array.push(obDirs, 1)
        array.push(obLabels, label.new(bar_index, math.avg(top, bottom), "OB", style=label.style_label_left, color=color.new(color.green, 82), textcolor=color.white, size=size.tiny))

if showOB and ob2Enabled and showStructuralOB and newBearStructureBreak
    int origin = na
    for k = 1 to ob2SearchBars
        if na(origin) and close[k] > open[k]
            origin := k
    if not na(origin)
        top = high[origin]
        bottom = low[origin]
        ob = box.new(bar_index - origin, top, bar_index, bottom, bgcolor=bearOBColor, border_color=color.new(color.red, 45))
        array.push(obBoxes, ob), array.push(obTops, top), array.push(obBottoms, bottom), array.push(obDirs, -1)
        array.push(obLabels, label.new(bar_index, math.avg(top, bottom), "OB", style=label.style_label_left, color=color.new(color.red, 82), textcolor=color.white, size=size.tiny))

if array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0
        obx = array.get(obBoxes, i)
        top = array.get(obTops, i)
        bottom = array.get(obBottoms, i)
        dir = array.get(obDirs, i)
        box.set_right(obx, bar_index)
        obLbl = array.get(obLabels, i)
        label.set_x(obLbl, bar_index)
        label.set_y(obLbl, math.avg(top, bottom))
        label.set_text(obLbl, showObLabels ? "OB" : "")
        invalid = dir == 1 ? close < bottom : close > top
        if invalid
            box.delete(obx)
            array.remove(obBoxes, i), array.remove(obTops, i), array.remove(obBottoms, i), array.remove(obDirs, i)
            label.delete(array.get(obLabels, i))
            array.remove(obLabels, i)

obActiveLimit = showH1StructuralZones ? 4 : ob2MaxActive * 2
while array.size(obBoxes) > obActiveLimit
    old = array.shift(obBoxes)
    box.delete(old)
    array.shift(obTops), array.shift(obBottoms), array.shift(obDirs)
    oldLbl = array.shift(obLabels)
    label.delete(oldLbl)

// FVG BOXES - CURRENT / ACTIVE ONLY
// No historical mitigated zones and no text inside the box.
var box[] fvgBoxes = array.new_box()
var line[] fvgCeLines = array.new_line()
var bool[] fvgIsBull = array.new_bool()
var float[] fvgCePrices = array.new_float()
var float[] fvgFarEdges = array.new_float()
var label[] fvgLabels = array.new_label()

// New bullish FVG.
if showFVG and showAllValidFVG and showStructuralFVG and bullFVG and highQualityFVG and (low - high[2]) >= atr * (showH1StructuralZones ? math.max(fvg2MinAtr, 0.20) : fvg2MinAtr) and math.abs(close[1] - open[1]) >= atr * (showH1StructuralZones ? math.max(fvg2DisplacementAtr, 0.90) : fvg2DisplacementAtr)
    // Keep only the configured number of newest bullish zones.
    bullCount = 0
    if array.size(fvgBoxes) > 0
        for j = 0 to array.size(fvgBoxes) - 1
            if array.get(fvgIsBull, j)
                bullCount += 1
    fvgSideLimitBull = showH1StructuralZones ? 1 : fvgMaxActivePerSide
    if bullCount >= fvgSideLimitBull
        for j = 0 to array.size(fvgBoxes) - 1
            if array.get(fvgIsBull, j)
                box.delete(array.get(fvgBoxes, j))
                line.delete(array.get(fvgCeLines, j))
                array.remove(fvgBoxes, j)
                array.remove(fvgCeLines, j)
                array.remove(fvgIsBull, j)
                array.remove(fvgCePrices, j)
                array.remove(fvgFarEdges, j)
                label.delete(array.get(fvgLabels, j))
                array.remove(fvgLabels, j)
                break
    ce = (low + high[2]) / 2.0
    bx = box.new(left=bar_index - 2, top=low, right=bar_index, bottom=high[2], bgcolor=color.new(bullFvgColor, fvgFillTransparency), border_color=color.new(color.lime, fvgBorderTransparency), border_width=1)
    ceLine = line.new(bar_index - 2, ce, bar_index, ce, color=showFvgCE ? color.new(color.lime, 55) : color.new(color.lime, 100), style=line.style_dotted, width=1)
    array.push(fvgBoxes, bx)
    array.push(fvgCeLines, ceLine)
    array.push(fvgIsBull, true)
    array.push(fvgCePrices, ce)
    array.push(fvgFarEdges, high[2])
    fvgLbl = label.new(bar_index, low, "FVG", style=label.style_none, textcolor=color.new(color.lime, 20), size=size.tiny)
    array.push(fvgLabels, fvgLbl)

// New bearish FVG.
if showFVG and showAllValidFVG and showStructuralFVG and bearFVG and highQualityFVG and (low[2] - high) >= atr * (showH1StructuralZones ? math.max(fvg2MinAtr, 0.20) : fvg2MinAtr) and math.abs(close[1] - open[1]) >= atr * (showH1StructuralZones ? math.max(fvg2DisplacementAtr, 0.90) : fvg2DisplacementAtr)
    bearCount = 0
    if array.size(fvgBoxes) > 0
        for j = 0 to array.size(fvgBoxes) - 1
            if not array.get(fvgIsBull, j)
                bearCount += 1
    fvgSideLimitBear = showH1StructuralZones ? 1 : fvgMaxActivePerSide
    if bearCount >= fvgSideLimitBear
        for j = 0 to array.size(fvgBoxes) - 1
            if not array.get(fvgIsBull, j)
                box.delete(array.get(fvgBoxes, j))
                line.delete(array.get(fvgCeLines, j))
                array.remove(fvgBoxes, j)
                array.remove(fvgCeLines, j)
                array.remove(fvgIsBull, j)
                array.remove(fvgCePrices, j)
                array.remove(fvgFarEdges, j)
                label.delete(array.get(fvgLabels, j))
                array.remove(fvgLabels, j)
                break
    ce = (low[2] + high) / 2.0
    bx = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high, bgcolor=color.new(bearFvgColor, fvgFillTransparency), border_color=color.new(color.red, fvgBorderTransparency), border_width=1)
    ceLine = line.new(bar_index - 2, ce, bar_index, ce, color=showFvgCE ? color.new(color.red, 55) : color.new(color.red, 100), style=line.style_dotted, width=1)
    array.push(fvgBoxes, bx)
    array.push(fvgCeLines, ceLine)
    array.push(fvgIsBull, false)
    array.push(fvgCePrices, ce)
    array.push(fvgFarEdges, low[2])
    fvgLbl = label.new(bar_index, low[2], "FVG", style=label.style_none, textcolor=color.new(color.red, 20), size=size.tiny)
    array.push(fvgLabels, fvgLbl)

// Extend only currently active FVGs to the current bar.
// Delete immediately after configured mitigation.
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        bx = array.get(fvgBoxes, i)
        ceLine = array.get(fvgCeLines, i)
        isBull = array.get(fvgIsBull, i)
        ce = array.get(fvgCePrices, i)
        farEdge = array.get(fvgFarEdges, i)

        box.set_right(bx, bar_index)
        line.set_x2(ceLine, bar_index)
        fvgLbl = array.get(fvgLabels, i)
        label.set_x(fvgLbl, bar_index)
        label.set_y(fvgLbl, box.get_top(bx))
        label.set_text(fvgLbl, showFvgLabels ? (isBull ? "Bull FVG" : "Bear FVG") : "")

        touchLevel = isBull ? box.get_top(bx) : box.get_bottom(bx)
        mitigated = fvgMitigationMode == "Touch" ? (isBull ? low <= touchLevel : high >= touchLevel) : fvgMitigationMode == "CE 50%" ? (isBull ? low <= ce : high >= ce) : (isBull ? low <= farEdge : high >= farEdge)

        if mitigated
            box.delete(bx)
            line.delete(ceLine)
            array.remove(fvgBoxes, i)
            array.remove(fvgCeLines, i)
            array.remove(fvgIsBull, i)
            array.remove(fvgCePrices, i)
            array.remove(fvgFarEdges, i)
            label.delete(array.get(fvgLabels, i))
            array.remove(fvgLabels, i)

// =====================================================
// ENTRY / SL / TP
// Target hierarchy: liquidity first, then active FIBO, then fallback RR.
// =====================================================
if showRR and showLtfFVG and bullSignal
    ce = (low + high[2]) / 2.0
    entry = ce
    sl = na(lastBullSweepLow) ? low[2] : lastBullSweepLow
    risk = entry - sl
    fibTargetLong = not na(fib127) and fib127Active ? fib127 : entry + risk * rr
    liquidityTargetLong = not na(pdh) and pdh > entry ? pdh : fibTargetLong
    tp = liquidityTargetLong
    line.new(bar_index, ce, bar_index + fvgExtendBars, ce, color=color.new(color.yellow, 0), style=line.style_dotted, width=2)
    if showTradeScore
        label.new(bar_index, high, "Score: " + str.tostring(bullScore) + "/10", style=label.style_label_down, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
    if showProbabilityScore
        label.new(bar_index, high + atr * 0.7, "P: " + str.tostring(bullProbScore), style=label.style_label_down, color=color.new(color.aqua, 0), textcolor=color.black, size=size.small)
    label.new(bar_index, entry, "LONG | Entry: " + str.tostring(entry, format.mintick) + " | SL: " + str.tostring(sl, format.mintick) + " | TP: " + str.tostring(tp, format.mintick), style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
    line.new(bar_index, entry, bar_index + fvgExtendBars, entry, color=color.new(color.blue, 0), width=1)
    line.new(bar_index, sl, bar_index + fvgExtendBars, sl, color=color.new(color.red, 0), width=1)
    line.new(bar_index, tp, bar_index + fvgExtendBars, tp, color=color.new(color.green, 0), width=1)

if showRR and showLtfFVG and bearSignal
    ce = (low[2] + high) / 2.0
    entry = ce
    sl = na(lastBearSweepHigh) ? high[2] : lastBearSweepHigh
    risk = sl - entry
    fibTargetShort = not na(fib127) and fib127Active ? fib127 : entry - risk * rr
    liquidityTargetShort = not na(pdl) and pdl < entry ? pdl : fibTargetShort
    tp = liquidityTargetShort
    line.new(bar_index, ce, bar_index + fvgExtendBars, ce, color=color.new(color.yellow, 0), style=line.style_dotted, width=2)
    if showTradeScore
        label.new(bar_index, low, "Score: " + str.tostring(bearScore) + "/10", style=label.style_label_up, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    if showProbabilityScore
        label.new(bar_index, low - atr * 0.7, "P: " + str.tostring(bearProbScore), style=label.style_label_up, color=color.new(color.orange, 0), textcolor=color.black, size=size.small)
    label.new(bar_index, entry, "SHORT | Entry: " + str.tostring(entry, format.mintick) + " | SL: " + str.tostring(sl, format.mintick) + " | TP: " + str.tostring(tp, format.mintick), style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    line.new(bar_index, entry, bar_index + fvgExtendBars, entry, color=color.new(color.blue, 0), width=1)
    line.new(bar_index, sl, bar_index + fvgExtendBars, sl, color=color.new(color.red, 0), width=1)
    line.new(bar_index, tp, bar_index + fvgExtendBars, tp, color=color.new(color.green, 0), width=1)

// =====================================================
// SMT WIDGET + OPTIONAL MARKERS
// =====================================================
var table smtTable = table.new(position.top_right, 1, 4, border_width=1)
if barstate.islast and showSMT
    smtText = bullSMT ? "Bullish SMT" : bearSMT ? "Bearish SMT" : "No SMT"
    smtColor = bullSMT ? color.new(color.lime, 0) : bearSMT ? color.new(color.red, 0) : color.new(color.gray, 30)
    table.cell(smtTable, 0, 0, "SMT Ghost Chart v" + SCRIPT_VERSION, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(smtTable, 0, 1, "Pair: " + smtSymbol, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(smtTable, 0, 2, smtText, bgcolor=smtColor, text_color=color.white)
    table.cell(smtTable, 0, 3, "Cor close: " + str.tostring(corClose, format.mintick), bgcolor=color.new(color.black, 0), text_color=color.white)

smtMarkerWindow = not showSMTOnlyInKillzone or validICTWindow
plotshape(showSMT and showSMTMarkers and smtMarkerWindow and bullSMT, title="Bullish SMT", text="SMT", style=shape.circle, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.tiny)
plotshape(showSMT and showSMTMarkers and smtMarkerWindow and bearSMT, title="Bearish SMT", text="SMT", style=shape.circle, location=location.abovebar, color=color.new(color.fuchsia, 0), textcolor=color.white, size=size.tiny)

// =====================================================
// HTF SUPPORT / RESISTANCE ENGINE
// H1/H4/D1 confirmed pivots + simple volume-strength weighting.
// Confluence zones are formed when levels from multiple HTFs cluster.
// =====================================================
h1PH = request.security(syminfo.tickerid, "60", ta.pivothigh(high, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)
h1PL = request.security(syminfo.tickerid, "60", ta.pivotlow(low, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)
h4PH = request.security(syminfo.tickerid, "240", ta.pivothigh(high, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)
h4PL = request.security(syminfo.tickerid, "240", ta.pivotlow(low, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)
d1PH = request.security(syminfo.tickerid, "D", ta.pivothigh(high, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)
d1PL = request.security(syminfo.tickerid, "D", ta.pivotlow(low, htfPivotLen, htfPivotLen), lookahead=barmerge.lookahead_off)

h1Vol = request.security(syminfo.tickerid, "60", volume, lookahead=barmerge.lookahead_off)
h4Vol = request.security(syminfo.tickerid, "240", volume, lookahead=barmerge.lookahead_off)
d1Vol = request.security(syminfo.tickerid, "D", volume, lookahead=barmerge.lookahead_off)
h1VolAvg = ta.sma(h1Vol, volumeStrengthLen)
h4VolAvg = ta.sma(h4Vol, volumeStrengthLen)
d1VolAvg = ta.sma(d1Vol, volumeStrengthLen)

h1Strong = not showVolumeStrength or h1Vol >= h1VolAvg
h4Strong = not showVolumeStrength or h4Vol >= h4VolAvg
d1Strong = not showVolumeStrength or d1Vol >= d1VolAvg

var line h1ResLine = na
var line h1SupLine = na
var line h4ResLine = na
var line h4SupLine = na
var line d1ResLine = na
var line d1SupLine = na
var label h1ResLabel = na
var label h1SupLabel = na
var label h4ResLabel = na
var label h4SupLabel = na
var label d1ResLabel = na
var label d1SupLabel = na
var box htfConfluenceResBox = na
var box htfConfluenceSupBox = na

if barstate.islast and showHTFSR
    if not na(h1ResLine)
        line.delete(h1ResLine)
    if not na(h1SupLine)
        line.delete(h1SupLine)
    if not na(h4ResLine)
        line.delete(h4ResLine)
    if not na(h4SupLine)
        line.delete(h4SupLine)
    if not na(d1ResLine)
        line.delete(d1ResLine)
    if not na(d1SupLine)
        line.delete(d1SupLine)
    if not na(h1ResLabel)
        label.delete(h1ResLabel)
    if not na(h1SupLabel)
        label.delete(h1SupLabel)
    if not na(h4ResLabel)
        label.delete(h4ResLabel)
    if not na(h4SupLabel)
        label.delete(h4SupLabel)
    if not na(d1ResLabel)
        label.delete(d1ResLabel)
    if not na(d1SupLabel)
        label.delete(d1SupLabel)
    if not na(htfConfluenceResBox)
        box.delete(htfConfluenceResBox)
    if not na(htfConfluenceSupBox)
        box.delete(htfConfluenceSupBox)

    leftBar = math.max(0, bar_index - srExtendBars)

    if showH1SR and not na(h1PH)
        h1ResLine := line.new(leftBar, h1PH, bar_index + 20, h1PH, color=color.new(color.orange, h1Strong ? 15 : 55), width=h1Strong ? 2 : 1)
        h1ResLabel := label.new(bar_index, h1PH, "H1 R", style=label.style_label_left, color=color.new(color.orange, 20), textcolor=color.white, size=size.tiny)
    if showH1SR and not na(h1PL)
        h1SupLine := line.new(leftBar, h1PL, bar_index + 20, h1PL, color=color.new(color.aqua, h1Strong ? 15 : 55), width=h1Strong ? 2 : 1)
        h1SupLabel := label.new(bar_index, h1PL, "H1 S", style=label.style_label_left, color=color.new(color.aqua, 20), textcolor=color.black, size=size.tiny)

    if showH4SR and not na(h4PH)
        h4ResLine := line.new(leftBar, h4PH, bar_index + 25, h4PH, color=color.new(color.red, h4Strong ? 5 : 45), width=h4Strong ? 3 : 2)
        h4ResLabel := label.new(bar_index, h4PH, "H4 R", style=label.style_label_left, color=color.new(color.red, 15), textcolor=color.white, size=size.tiny)
    if showH4SR and not na(h4PL)
        h4SupLine := line.new(leftBar, h4PL, bar_index + 25, h4PL, color=color.new(color.lime, h4Strong ? 5 : 45), width=h4Strong ? 3 : 2)
        h4SupLabel := label.new(bar_index, h4PL, "H4 S", style=label.style_label_left, color=color.new(color.lime, 15), textcolor=color.black, size=size.tiny)

    if showD1SR and not na(d1PH)
        d1ResLine := line.new(leftBar, d1PH, bar_index + 30, d1PH, color=color.new(color.fuchsia, d1Strong ? 0 : 35), width=d1Strong ? 4 : 3)
        d1ResLabel := label.new(bar_index, d1PH, "D1 R", style=label.style_label_left, color=color.new(color.fuchsia, 10), textcolor=color.white, size=size.tiny)
    if showD1SR and not na(d1PL)
        d1SupLine := line.new(leftBar, d1PL, bar_index + 30, d1PL, color=color.new(color.blue, d1Strong ? 0 : 35), width=d1Strong ? 4 : 3)
        d1SupLabel := label.new(bar_index, d1PL, "D1 S", style=label.style_label_left, color=color.new(color.blue, 10), textcolor=color.white, size=size.tiny)

    // Confluence: two or more HTFs within configured ATR distance.
    res12 = not na(h1PH) and not na(h4PH) and math.abs(h1PH - h4PH) <= atr * srAtrMerge
    res14 = not na(h1PH) and not na(d1PH) and math.abs(h1PH - d1PH) <= atr * srAtrMerge
    res24 = not na(h4PH) and not na(d1PH) and math.abs(h4PH - d1PH) <= atr * srAtrMerge
    sup12 = not na(h1PL) and not na(h4PL) and math.abs(h1PL - h4PL) <= atr * srAtrMerge
    sup14 = not na(h1PL) and not na(d1PL) and math.abs(h1PL - d1PL) <= atr * srAtrMerge
    sup24 = not na(h4PL) and not na(d1PL) and math.abs(h4PL - d1PL) <= atr * srAtrMerge

    if showConfluenceZones and (res12 or res14 or res24)
        r1 = res24 ? h4PH : h1PH
        r2 = res24 ? d1PH : res14 ? d1PH : h4PH
        rTop = math.max(r1, r2)
        rBot = math.min(r1, r2)
        htfConfluenceResBox := box.new(leftBar, rTop + atr * 0.03, bar_index + 30, rBot - atr * 0.03, bgcolor=color.new(color.red, 91), border_color=color.new(color.red, 45), text="HTF Resistance", text_size=size.tiny)

    if showConfluenceZones and (sup12 or sup14 or sup24)
        s1 = sup24 ? h4PL : h1PL
        s2 = sup24 ? d1PL : sup14 ? d1PL : h4PL
        sTop = math.max(s1, s2)
        sBot = math.min(s1, s2)
        htfConfluenceSupBox := box.new(leftBar, sTop + atr * 0.03, bar_index + 30, sBot - atr * 0.03, bgcolor=color.new(color.green, 91), border_color=color.new(color.green, 45), text="HTF Support", text_size=size.tiny)

// =====================================================
// ALERTS
// =====================================================
alertcondition(bullSignal, title="ICT Long Signal", message="ICT Long: Liquidity Sweep + MSS + Bullish FVG")
alertcondition(bearSignal, title="ICT Short Signal", message="ICT Short: Liquidity Sweep + MSS + Bearish FVG")
alertcondition(bullSMT, title="Bullish SMT", message="Bullish SMT divergence detected")
alertcondition(bearSMT, title="Bearish SMT", message="Bearish SMT divergence detected")
alertcondition(bullCHOCH, title="Bullish CHOCH", message="Bullish CHOCH detected")
alertcondition(bearCHOCH, title="Bearish CHOCH", message="Bearish CHOCH detected")
alertcondition(bullBOS, title="Bullish BOS", message="Bullish BOS detected")
alertcondition(bearBOS, title="Bearish BOS", message="Bearish BOS detected")
alertcondition(externalBullCHOCH, title="External Bullish CHOCH", message="External Bullish CHOCH detected")
alertcondition(externalBearCHOCH, title="External Bearish CHOCH", message="External Bearish CHOCH detected")
alertcondition(externalBullBOS, title="External Bullish BOS", message="External Bullish BOS detected")
alertcondition(externalBearBOS, title="External Bearish BOS", message="External Bearish BOS detected")
````
