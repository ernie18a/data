# TPP Quant Execution Engine v0.1

- url: https://www.tradingview.com/script/clCrLrng/
- type: indicator
- pine_id: PUB;f86b69b87f7f48f49332342a28ec8857
- version: 3.0

## Description

TPP Quant Execution Engine v0.1
TPP Quant Execution Engine (TPP QX) is a multi-layer technical analysis and execution-assistance framework designed to separate three different stages of a trading setup: Reaction, Entry and Exit.
The purpose of the indicator is to distinguish between a price reaction at an important level and an actual execution-ready setup.
A reaction does not automatically become an entry.
REACTION
The TPP Structure Engine identifies price interaction with higher-timeframe support and resistance levels and evaluates rejection quality using ATR-based zones, candle structure, wick behavior, local price extremes, RSI context and higher-timeframe confluence.
Reaction signals are displayed with an independent score. This score measures technical confluence around the reaction and should not be interpreted as a probability of future success.
ENTRY
The Execution Engine evaluates whether a detected market condition is suitable for a potential entry.
It combines:
• Market regime and directional expansion
• Higher-timeframe market structure
• TPP support and resistance reactions
• Momentum strength and acceleration
• Pullback confirmation
• Micro-structure breakout confirmation
• Relative volume
• Structural risk/reward availability
Two entry families are available:
Trend Continuation
Designed to identify continuation opportunities in an established directional regime after a valid pullback or structural reaction.
Confirmed Reversal
Designed to identify potential reversals only after the previous expansion begins to deteriorate and price, momentum and micro-structure confirm the opposite direction.
Entry signals are classified as:
• ▲ LONG ENTRY
• ▼ SHORT ENTRY
• ▲ REVERSAL LONG
• ▼ REVERSAL SHORT
• +▲ PRIME LONG
• +▼ PRIME SHORT
PRIME signals represent setups with a higher Execution Score according to the configured confluence model. They are not guarantees of market direction or profitability.
MARKET REGIME ENGINE
TPP QX continuously evaluates market state using directional movement, ADX, price efficiency, moving-average separation and trend slope.
The engine classifies the market into:
• Bull Expansion
• Bear Expansion
• Bull/Bear Transition
• Compression
Candle colors visually represent regime strength.
Cyan intensity increases as bullish directional strength increases, while ruby/crimson intensity increases during bearish expansion. Neutral grey represents compression or weak directional conditions.
TPP STRUCTURE ENGINE
Execution calculations use confirmed higher-timeframe support and resistance levels.
Visible TPP levels can optionally be displayed as either Dynamic or Closed levels. This allows traders to maintain a responsive visual reference without allowing developing higher-timeframe levels to alter the confirmed execution structure.
MOMENTUM AND PULLBACK ANALYSIS
Momentum is evaluated using RSI behavior, price velocity, rate of change and fast/slow trend alignment.
Pullbacks are evaluated around TPP levels and a dynamic equilibrium reference. In Scalping mode the equilibrium reference uses VWAP, while Swing mode uses the faster trend average.
RISK ENGINE
When an Entry signal is confirmed, TPP QX calculates:
• Entry price
• Structural Stop Loss
• TP1
• TP2
• TP3
Stop placement uses recent market structure with configurable ATR padding.
Profit targets are expressed as multiples of initial risk, allowing the trader to evaluate the setup using a consistent R-based framework.
MOMENTUM EXIT
TPP QX monitors deterioration in momentum after an active Entry. Exit markers can appear when multiple momentum conditions weaken, helping the trader reassess exposure or profit protection.
EXECUTION PROFILES
Scalping
Designed for 1-minute to 5-minute execution workflows using lower-timeframe momentum together with higher-timeframe structure and directional context.
Swing
Designed for 4-hour and higher charts using Daily structure and Weekly directional context by default.
TPP QX DASHBOARD
The real-time dashboard summarizes:
• Market Regime
• Higher-timeframe Structure
• Latest TPP Reaction
• Momentum
• Pullback status
• Relative Volume
• Execution Score
• Active Trade state
• Risk levels
• Current system status
ALERTS
Independent alert conditions are available for:
• BUY Reaction
• SELL Reaction
• LONG Entry
• SHORT Entry
• PRIME LONG
• PRIME SHORT
• Exit LONG
• Exit SHORT
• Bull Expansion
• Bear Expansion
IMPORTANT
TPP QX is an analytical and discretionary execution-support tool. Reaction Scores and Execution Scores represent the internal level of technical confluence detected by the model. They do not represent probabilities of success.
No signal guarantees future price movement. The indicator should be used together with appropriate position sizing, risk management and independent market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gerafitti

//@version=6
indicator("TPP Quant Execution Engine v0.2", shorttitle="TPP QX v0.2", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ============================================================================
// 01. GROUPS
// ============================================================================
string G_MODEL   = "01 - Execution Model"
string G_TF      = "02 - Timeframes"
string G_REGIME  = "03 - Market Regime Engine"
string G_TPP     = "04 - TPP Structure & Reaction"
string G_EXEC    = "05 - Execution Engine"
string G_RISK    = "06 - Risk Engine"
string G_DISPLAY = "07 - Display"

// ============================================================================
// 02. EXECUTION MODEL
// ============================================================================
string profile = input.string("Scalping", "Execution Profile", options=["Scalping", "Swing"], group=G_MODEL,
     tooltip="Scalping is designed for 1m-5m charts. Swing is designed for 4H and higher charts.")
string signalFamily = input.string("Both", "Entry Family", options=["Both", "Trend Continuation", "Confirmed Reversal"], group=G_MODEL)
bool confirmedOnly = input.bool(true, "Confirm signals at candle close", group=G_MODEL)
int cooldownBars = input.int(4, "Entry cooldown bars", minval=0, maxval=50, group=G_MODEL)

// ============================================================================
// 03. TIMEFRAMES
// ============================================================================
string scalpStructureTF = input.timeframe("5", "Scalping structure TF", group=G_TF)
string scalpBiasTF      = input.timeframe("15", "Scalping bias TF", group=G_TF)
string swingStructureTF = input.timeframe("D", "Swing structure TF", group=G_TF)
string swingBiasTF      = input.timeframe("W", "Swing bias TF", group=G_TF)
string visualLevelMode  = input.string("Dynamic", "Visible TPP levels", options=["Dynamic", "Closed"], group=G_TF,
     tooltip="Execution always uses closed HTF levels. Dynamic only changes the visible reference lines.")

string structureTF = profile == "Scalping" ? scalpStructureTF : swingStructureTF
string biasTF      = profile == "Scalping" ? scalpBiasTF : swingBiasTF

// ============================================================================
// 04. PROFILE PARAMETERS
// ============================================================================
int scalpFastLen = input.int(9, "Scalp fast trend length", minval=2, group=G_REGIME)
int scalpSlowLen = input.int(21, "Scalp slow trend length", minval=5, group=G_REGIME)
int swingFastLen = input.int(21, "Swing fast trend length", minval=5, group=G_REGIME)
int swingSlowLen = input.int(55, "Swing slow trend length", minval=10, group=G_REGIME)
int scalpRegimeLookback = input.int(20, "Scalp regime lookback", minval=10, group=G_REGIME)
int swingRegimeLookback = input.int(40, "Swing regime lookback", minval=20, group=G_REGIME)
float trendStrengthMin = input.float(55.0, "Expansion threshold", minval=30, maxval=90, step=1, group=G_REGIME)
float compressionMax   = input.float(35.0, "Compression threshold", minval=10, maxval=60, step=1, group=G_REGIME)

int fastLen = profile == "Scalping" ? scalpFastLen : swingFastLen
int slowLen = profile == "Scalping" ? scalpSlowLen : swingSlowLen
int regimeLookback = profile == "Scalping" ? scalpRegimeLookback : swingRegimeLookback

// ============================================================================
// 05. TPP STRUCTURE & REACTION INPUTS
// ============================================================================
int atrLength = input.int(14, "ATR Length", minval=1, group=G_TPP)
float zoneATR = input.float(0.15, "TPP reaction zone x ATR", minval=0.01, step=0.05, group=G_TPP)
float minWickPct = input.float(0.35, "Minimum rejection wick ratio", minval=0.05, maxval=0.90, step=0.05, group=G_TPP)
int localLookback = input.int(12, "Local extreme lookback", minval=3, maxval=100, group=G_TPP)
float localToleranceATR = input.float(0.20, "Local extreme tolerance x ATR", minval=0.0, maxval=2.0, step=0.05, group=G_TPP)
int reactionMemoryBars = input.int(4, "Reaction memory bars", minval=0, maxval=20, group=G_TPP)

// ============================================================================
// 06. EXECUTION INPUTS
// ============================================================================
int rsiLength = input.int(14, "RSI Length", minval=2, group=G_EXEC)
int microLookbackScalp = input.int(3, "Scalp micro-structure lookback", minval=1, maxval=20, group=G_EXEC)
int microLookbackSwing = input.int(5, "Swing micro-structure lookback", minval=2, maxval=30, group=G_EXEC)
int microLookback = profile == "Scalping" ? microLookbackScalp : microLookbackSwing
float pullbackATR = input.float(0.25, "Equilibrium pullback tolerance x ATR", minval=0.05, maxval=1.0, step=0.05, group=G_EXEC)
float minRelVolume = input.float(0.90, "Minimum relative volume", minval=0.1, maxval=5.0, step=0.05, group=G_EXEC)
bool requireVolume = input.bool(true, "Require volume confirmation when available", group=G_EXEC)
float minMomentumScore = input.float(55, "Continuation momentum minimum", minval=0, maxval=100, step=5, group=G_EXEC)
float reversalMomentumScore = input.float(65, "Reversal momentum minimum", minval=0, maxval=100, step=5, group=G_EXEC)
float entryScoreMin = input.float(70, "ENTRY minimum score", minval=0, maxval=100, step=5, group=G_EXEC)
float primeScoreMin = input.float(85, "PRIME minimum score", minval=0, maxval=100, step=5, group=G_EXEC)
int reversalMemoryBars = input.int(8, "Prior opposite expansion memory", minval=1, maxval=50, group=G_EXEC)

// --- M1 Intrabar Inspector (Scalping profile) ---
bool useM1Intrabars = input.bool(true, "Inspect every M1 intrabar on higher chart bars", group=G_EXEC,
     tooltip="On M5, scans every available 1-minute intrabar using request.security_lower_tf(). Ignored by the Swing profile.")
string intrabarTF = input.timeframe("1", "Intrabar timeframe", group=G_EXEC)
float m1PulseMin = input.float(60, "M1 Pulse minimum score", minval=0, maxval=100, step=5, group=G_EXEC)
float m1HQMin = input.float(80, "M1 HQ Pulse score", minval=0, maxval=100, step=5, group=G_EXEC)
int m1MinSignals = input.int(1, "Minimum M1 pulses inside chart bar", minval=1, maxval=5, group=G_EXEC)
bool requireM1Pulse = input.bool(true, "Require M1 directional pulse for Scalping ENTRY", group=G_EXEC,
     tooltip="When enabled, a Scalping ENTRY requires directional evidence from the M1 intrabars contained in the chart bar.")

// ============================================================================
// 07. RISK INPUTS
// ============================================================================
int scalpStopLookback = input.int(5, "Scalp structural stop lookback", minval=2, maxval=30, group=G_RISK)
int swingStopLookback = input.int(10, "Swing structural stop lookback", minval=3, maxval=60, group=G_RISK)
int stopLookback = profile == "Scalping" ? scalpStopLookback : swingStopLookback
float stopAtrPad = input.float(0.20, "Stop ATR padding", minval=0.0, maxval=2.0, step=0.05, group=G_RISK)
float minRR = input.float(1.5, "Minimum structural R:R", minval=0.5, maxval=5.0, step=0.1, group=G_RISK)
float tp1R = input.float(1.0, "TP1 (R)", minval=0.5, step=0.25, group=G_RISK)
float tp2R = input.float(1.5, "TP2 (R)", minval=0.75, step=0.25, group=G_RISK)
float tp3R = input.float(2.0, "TP3 (R)", minval=1.0, step=0.25, group=G_RISK)

// ============================================================================
// 08. DISPLAY INPUTS
// ============================================================================
bool showRegimeColors = input.bool(true, "Color candles by market regime", group=G_DISPLAY)
bool showRegimeCloud  = input.bool(true, "Show regime cloud", group=G_DISPLAY)
bool showTPPLevels    = input.bool(true, "Show TPP support/resistance", group=G_DISPLAY)
bool showReactions    = input.bool(true, "Show REACTION labels", group=G_DISPLAY)
bool showEntries      = input.bool(true, "Show ENTRY labels", group=G_DISPLAY)
bool showRiskLevels   = input.bool(true, "Show latest SL/TP projection", group=G_DISPLAY)
bool showDashboard    = input.bool(true, "Show TPP QX dashboard", group=G_DISPLAY)
bool showM1PulseMarks = input.bool(true, "Show M1 intrabar pulse markers", group=G_DISPLAY)

color C_CYAN    = #00E5FF
color C_RUBY    = #D81B60
color C_GREEN   = #00BFA5
color C_RED     = #E53935
color C_GRAY    = #707782
color C_DARK    = #151A22
color C_AMBER   = #FFB300
color C_WHITE   = #F5F7FA

// ============================================================================
// 09. HELPERS
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_closed_high(string tf) =>
    request.security(syminfo.tickerid, tf, high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

f_closed_low(string tf) =>
    request.security(syminfo.tickerid, tf, low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

f_dynamic_high(string tf) =>
    request.security(syminfo.tickerid, tf, high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_dynamic_low(string tf) =>
    request.security(syminfo.tickerid, tf, low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_closed_close(string tf) =>
    request.security(syminfo.tickerid, tf, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

f_closed_ema(string tf, int len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

f_closed_ema_prev(string tf, int len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len)[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

f_touch_support(float level, float z) =>
    not na(level) and low <= level + z and high >= level - z

f_touch_resistance(float level, float z) =>
    not na(level) and high >= level - z and low <= level + z

f_levels_near(float a, float b, float z) =>
    not na(a) and not na(b) and math.abs(a - b) <= z

// M1 directional pulse. This is an execution-evidence engine, not a duplicate of TPP RSI PRO.
// It combines RSI turn, micro-structure, candle direction, EMA alignment and relative volume.
f_m1_pulse_pack() =>
    float lrsi = ta.rsi(close, rsiLength)
    float lFast = ta.ema(close, 9)
    float lSlow = ta.ema(close, 21)
    float lVolMA = ta.sma(volume, 20)
    bool lHasVol = not na(volume) and volume > 0 and not na(lVolMA) and lVolMA > 0
    float lRelVol = lHasVol ? volume / lVolMA : 1.0
    bool bullExtreme = lrsi[1] <= 30 and lrsi[1] < lrsi[2] and lrsi > lrsi[1]
    bool bearExtreme = lrsi[1] >= 70 and lrsi[1] > lrsi[2] and lrsi < lrsi[1]
    bool bullMomentum = lrsi[1] <= 35 and lrsi[1] > 30 and lrsi > lrsi[1]
    bool bearMomentum = lrsi[1] >= 65 and lrsi[1] < 70 and lrsi < lrsi[1]
    bool bullBreak = close > high[1]
    bool bearBreak = close < low[1]
    float bullScore = (bullExtreme ? 35.0 : bullMomentum ? 25.0 : lrsi > 50 and lrsi > lrsi[1] ? 12.0 : 0.0) + (close > open ? 10.0 : 0.0) + (bullBreak ? 20.0 : 0.0) + (lFast > lSlow ? 15.0 : 0.0) + (lRelVol >= 1.0 ? 10.0 : 0.0) + (lrsi > lrsi[1] and lrsi[1] > lrsi[2] ? 10.0 : 0.0)
    float bearScore = (bearExtreme ? 35.0 : bearMomentum ? 25.0 : lrsi < 50 and lrsi < lrsi[1] ? 12.0 : 0.0) + (close < open ? 10.0 : 0.0) + (bearBreak ? 20.0 : 0.0) + (lFast < lSlow ? 15.0 : 0.0) + (lRelVol >= 1.0 ? 10.0 : 0.0) + (lrsi < lrsi[1] and lrsi[1] < lrsi[2] ? 10.0 : 0.0)
    bool bullPulse = bullScore >= m1PulseMin and (bullExtreme or bullMomentum or bullBreak)
    bool bearPulse = bearScore >= m1PulseMin and (bearExtreme or bearMomentum or bearBreak)
    bool bullHQ = bullPulse and bullScore >= m1HQMin
    bool bearHQ = bearPulse and bearScore >= m1HQMin
    [bullScore, bearScore, bullPulse, bearPulse, bullHQ, bearHQ, time]

// ============================================================================
// 10. CORE DATA
// ============================================================================
float atr = ta.atr(atrLength)
float zone = atr * zoneATR
float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float rsi = ta.rsi(close, rsiLength)

float execResistance = f_closed_high(structureTF)
float execSupport    = f_closed_low(structureTF)
float biasResistance = f_closed_high(biasTF)
float biasSupport    = f_closed_low(biasTF)

float visualResistance = visualLevelMode == "Dynamic" ? f_dynamic_high(structureTF) : execResistance
float visualSupport    = visualLevelMode == "Dynamic" ? f_dynamic_low(structureTF) : execSupport

float biasClose   = f_closed_close(biasTF)
float biasEma     = f_closed_ema(biasTF, slowLen)
float biasEmaPrev = f_closed_ema_prev(biasTF, slowLen)
bool biasBull = biasClose > biasEma and biasEma > biasEmaPrev
bool biasBear = biasClose < biasEma and biasEma < biasEmaPrev
int structureDir = biasBull ? 1 : biasBear ? -1 : 0

// ============================================================================
// 10B. M1 INTRABAR INSPECTOR
// ============================================================================
// In Swing mode we request the chart timeframe itself, avoiding an unnecessary M1 history load.
string intrabarRequestTF = profile == "Scalping" and useM1Intrabars ? intrabarTF : timeframe.period
[m1BullScoreArr, m1BearScoreArr, m1BullPulseArr, m1BearPulseArr, m1BullHQArr, m1BearHQArr, m1TimeArr] = request.security_lower_tf(
     syminfo.tickerid, intrabarRequestTF, f_m1_pulse_pack(), ignore_invalid_timeframe=true)

int m1IntrabarCount = array.size(m1BullScoreArr)
float m1BestBull = 0.0
float m1BestBear = 0.0
int m1BullCount = 0
int m1BearCount = 0
bool m1BullHQFound = false
bool m1BearHQFound = false
int m1LastDir = 0
int m1LastSignalTime = na

if m1IntrabarCount > 0
    for i = 0 to m1IntrabarCount - 1
        float bs = array.get(m1BullScoreArr, i)
        float ss = array.get(m1BearScoreArr, i)
        bool bp = array.get(m1BullPulseArr, i)
        bool sp = array.get(m1BearPulseArr, i)
        bool bhq = array.get(m1BullHQArr, i)
        bool shq = array.get(m1BearHQArr, i)
        int it = array.get(m1TimeArr, i)
        m1BestBull := math.max(m1BestBull, bs)
        m1BestBear := math.max(m1BestBear, ss)
        if bp
            m1BullCount += 1
            m1BullHQFound := m1BullHQFound or bhq
            m1LastDir := 1
            m1LastSignalTime := it
        if sp
            m1BearCount += 1
            m1BearHQFound := m1BearHQFound or shq
            m1LastDir := -1
            m1LastSignalTime := it

bool m1DataAvailable = m1IntrabarCount > 0
bool m1InspectorActive = profile == "Scalping" and useM1Intrabars
bool m1LongEvidence = not m1InspectorActive or (m1DataAvailable and m1BullCount >= m1MinSignals and (m1LastDir == 1 or m1BestBull > m1BestBear))
bool m1ShortEvidence = not m1InspectorActive or (m1DataAvailable and m1BearCount >= m1MinSignals and (m1LastDir == -1 or m1BestBear > m1BestBull))
float m1LongScoreAdd = not m1InspectorActive ? 0.0 : m1BullHQFound ? 10.0 : m1LongEvidence ? 6.0 : 0.0
float m1ShortScoreAdd = not m1InspectorActive ? 0.0 : m1BearHQFound ? 10.0 : m1ShortEvidence ? 6.0 : 0.0

// ============================================================================
// 11. MARKET REGIME ENGINE
// ============================================================================
[diPlus, diMinus, adx] = ta.dmi(14, 14)
float erNet = math.abs(close - close[regimeLookback])
float erDen = math.sum(math.abs(close - close[1]), regimeLookback)
float efficiencyRatio = erDen > 0 ? erNet / erDen : 0.0
float emaSeparation = atr > 0 ? math.abs(emaFast - emaSlow) / atr : 0.0
float emaSlope = atr > 0 ? math.abs(emaSlow - emaSlow[3]) / atr : 0.0
float adxNorm = f_clamp(adx / 40.0, 0.0, 1.0)
float sepNorm = f_clamp(emaSeparation / 1.25, 0.0, 1.0)
float slopeNorm = f_clamp(emaSlope / 0.75, 0.0, 1.0)
float regimeStrength = 100.0 * (adxNorm * 0.35 + efficiencyRatio * 0.30 + sepNorm * 0.20 + slopeNorm * 0.15)

int trendDir = emaFast > emaSlow and emaSlow >= emaSlow[3] ? 1 : emaFast < emaSlow and emaSlow <= emaSlow[3] ? -1 : 0
bool bullExpansion = trendDir == 1 and regimeStrength >= trendStrengthMin
bool bearExpansion = trendDir == -1 and regimeStrength >= trendStrengthMin
bool compression = regimeStrength <= compressionMax or adx < 16
bool transition = not bullExpansion and not bearExpansion and not compression

float regimeVisualPower = f_clamp((regimeStrength - compressionMax) / math.max(100.0 - compressionMax, 1.0), 0.0, 1.0)
color bullGradient = color.from_gradient(regimeVisualPower, 0.0, 1.0, C_GRAY, C_CYAN)
color bearGradient = color.from_gradient(regimeVisualPower, 0.0, 1.0, C_GRAY, C_RUBY)
color regimeColor = compression ? C_GRAY : trendDir == 1 ? bullGradient : trendDir == -1 ? bearGradient : C_GRAY
barcolor(showRegimeColors ? regimeColor : na)

// ============================================================================
// 12. TPP REACTION ENGINE
// ============================================================================
float candleRange = math.max(high - low, syminfo.mintick)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickRatio = upperWick / candleRange
float lowerWickRatio = lowerWick / candleRange

bool touchSupport = f_touch_support(execSupport, zone)
bool touchResistance = f_touch_resistance(execResistance, zone)
bool reactionBuy = touchSupport and close > execSupport and lowerWickRatio >= minWickPct and close > open
bool reactionSell = touchResistance and close < execResistance and upperWickRatio >= minWickPct and close < open

float recentLow = ta.lowest(low, localLookback)
float recentHigh = ta.highest(high, localLookback)
float localTol = atr * localToleranceATR
bool buyAtExtreme = low <= recentLow + localTol
bool sellAtExtreme = high >= recentHigh - localTol

float wickRange = math.max(0.75 - minWickPct, 0.05)
float buyWickScore = reactionBuy ? f_clamp((lowerWickRatio - minWickPct) / wickRange * 15.0, 0.0, 15.0) : 0.0
float sellWickScore = reactionSell ? f_clamp((upperWickRatio - minWickPct) / wickRange * 15.0, 0.0, 15.0) : 0.0

bool rsiBullContext = (rsi <= 35 and rsi > rsi[1]) or (rsi > 45 and rsi > rsi[1])
bool rsiBearContext = (rsi >= 65 and rsi < rsi[1]) or (rsi < 55 and rsi < rsi[1])
float buyRsiScore = rsi <= 30 and rsi > rsi[1] ? 15.0 : rsiBullContext ? 10.0 : 0.0
float sellRsiScore = rsi >= 70 and rsi < rsi[1] ? 15.0 : rsiBearContext ? 10.0 : 0.0

float contextZone = atr * 0.30
float buyHTFScore = (f_levels_near(execSupport, biasSupport, contextZone) ? 10.0 : 0.0)
float sellHTFScore = (f_levels_near(execResistance, biasResistance, contextZone) ? 10.0 : 0.0)

float buyReactionScore = reactionBuy ? math.min(100.0, 40.0 + (buyAtExtreme ? 20.0 : 0.0) + buyWickScore + buyRsiScore + buyHTFScore) : 0.0
float sellReactionScore = reactionSell ? math.min(100.0, 40.0 + (sellAtExtreme ? 20.0 : 0.0) + sellWickScore + sellRsiScore + sellHTFScore) : 0.0

int buyReactionAge = ta.barssince(reactionBuy)
int sellReactionAge = ta.barssince(reactionSell)
bool buyReactionRecent = not na(buyReactionAge) and buyReactionAge <= reactionMemoryBars
bool sellReactionRecent = not na(sellReactionAge) and sellReactionAge <= reactionMemoryBars

// ============================================================================
// 13. MOMENTUM / VOLUME / PULLBACK ENGINE
// ============================================================================
float velocity = ta.ema(ta.change(close), 3)
float roc3 = ta.roc(close, 3)
float bullMomentumScore = (rsi >= 55 ? 25.0 : rsi >= 50 ? 18.0 : rsi >= 45 ? 10.0 : 0.0) + (rsi > rsi[1] ? 20.0 : 0.0) + (velocity > 0 ? 20.0 : 0.0) + (emaFast > emaSlow ? 20.0 : 0.0) + (roc3 > 0 ? 15.0 : 0.0)
float bearMomentumScore = (rsi <= 45 ? 25.0 : rsi <= 50 ? 18.0 : rsi <= 55 ? 10.0 : 0.0) + (rsi < rsi[1] ? 20.0 : 0.0) + (velocity < 0 ? 20.0 : 0.0) + (emaFast < emaSlow ? 20.0 : 0.0) + (roc3 < 0 ? 15.0 : 0.0)
bool bullAccelerating = bullMomentumScore >= 70 and bullMomentumScore > bullMomentumScore[1]
bool bearAccelerating = bearMomentumScore >= 70 and bearMomentumScore > bearMomentumScore[1]

float volMA = ta.sma(volume, 20)
bool hasVolume = not na(volume) and volume > 0 and not na(volMA) and volMA > 0
float relVolume = hasVolume ? volume / volMA : 1.0
bool volumeGate = not requireVolume or not hasVolume or relVolume >= minRelVolume
bool volumeStrong = not hasVolume or relVolume >= 1.15

float equilibrium = profile == "Scalping" ? ta.vwap(hlc3) : emaFast
bool equilibriumTouch = low <= equilibrium + atr * pullbackATR and high >= equilibrium - atr * pullbackATR
bool bullPullback = (touchSupport or equilibriumTouch) and close > open and close >= equilibrium
bool bearPullback = (touchResistance or equilibriumTouch) and close < open and close <= equilibrium
int bullPullbackAge = ta.barssince(bullPullback)
int bearPullbackAge = ta.barssince(bearPullback)
bool bullPullbackRecent = not na(bullPullbackAge) and bullPullbackAge <= reactionMemoryBars
bool bearPullbackRecent = not na(bearPullbackAge) and bearPullbackAge <= reactionMemoryBars

float priorMicroHigh = ta.highest(high[1], microLookback)
float priorMicroLow = ta.lowest(low[1], microLookback)
bool microBreakLong = close > priorMicroHigh
bool microBreakShort = close < priorMicroLow

// ============================================================================
// 14. RISK READINESS
// ============================================================================
float longStopCandidate = ta.lowest(low, stopLookback) - atr * stopAtrPad
float shortStopCandidate = ta.highest(high, stopLookback) + atr * stopAtrPad
float longRisk = math.max(close - longStopCandidate, syminfo.mintick)
float shortRisk = math.max(shortStopCandidate - close, syminfo.mintick)
float rrToResistance = execResistance > close ? (execResistance - close) / longRisk : minRR
float rrToSupport = execSupport < close ? (close - execSupport) / shortRisk : minRR
bool longRROK = rrToResistance >= minRR
bool shortRROK = rrToSupport >= minRR

// ============================================================================
// 15. ENTRY FAMILY LOGIC
// ============================================================================
int sinceBearExpansion = ta.barssince(bearExpansion)
int sinceBullExpansion = ta.barssince(bullExpansion)
bool bearExpansionRecent = not na(sinceBearExpansion) and sinceBearExpansion <= reversalMemoryBars
bool bullExpansionRecent = not na(sinceBullExpansion) and sinceBullExpansion <= reversalMemoryBars

float tcLongScore = math.min(100.0, (bullExpansion ? 25.0 : trendDir == 1 and transition ? 12.0 : 0.0) + (biasBull ? 15.0 : 0.0) + (buyReactionRecent ? 15.0 : bullPullbackRecent ? 12.0 : 0.0) + bullMomentumScore * 0.20 + (microBreakLong ? 10.0 : 0.0) + (volumeStrong ? 5.0 : 0.0) + (longRROK ? 10.0 : 0.0) + m1LongScoreAdd)
float tcShortScore = math.min(100.0, (bearExpansion ? 25.0 : trendDir == -1 and transition ? 12.0 : 0.0) + (biasBear ? 15.0 : 0.0) + (sellReactionRecent ? 15.0 : bearPullbackRecent ? 12.0 : 0.0) + bearMomentumScore * 0.20 + (microBreakShort ? 10.0 : 0.0) + (volumeStrong ? 5.0 : 0.0) + (shortRROK ? 10.0 : 0.0) + m1ShortScoreAdd)

float revLongScore = math.min(100.0, (bearExpansionRecent and not bearExpansion ? 20.0 : 0.0) + (buyReactionRecent ? 20.0 : 0.0) + bullMomentumScore * 0.20 + (microBreakLong ? 15.0 : 0.0) + (close > emaFast ? 10.0 : 0.0) + (volumeStrong ? 5.0 : 0.0) + (longRROK ? 10.0 : 0.0) + m1LongScoreAdd)
float revShortScore = math.min(100.0, (bullExpansionRecent and not bullExpansion ? 20.0 : 0.0) + (sellReactionRecent ? 20.0 : 0.0) + bearMomentumScore * 0.20 + (microBreakShort ? 15.0 : 0.0) + (close < emaFast ? 10.0 : 0.0) + (volumeStrong ? 5.0 : 0.0) + (shortRROK ? 10.0 : 0.0) + m1ShortScoreAdd)

bool m1LongGate = profile != "Scalping" or not requireM1Pulse or m1LongEvidence
bool m1ShortGate = profile != "Scalping" or not requireM1Pulse or m1ShortEvidence

bool tcLongCandidate = bullExpansion and biasBull and (buyReactionRecent or bullPullbackRecent) and microBreakLong and bullMomentumScore >= minMomentumScore and volumeGate and longRROK and m1LongGate
bool tcShortCandidate = bearExpansion and biasBear and (sellReactionRecent or bearPullbackRecent) and microBreakShort and bearMomentumScore >= minMomentumScore and volumeGate and shortRROK and m1ShortGate

bool revLongCandidate = bearExpansionRecent and not bearExpansion and buyReactionRecent and close > emaFast and microBreakLong and bullMomentumScore >= reversalMomentumScore and volumeGate and longRROK and m1LongGate
bool revShortCandidate = bullExpansionRecent and not bullExpansion and sellReactionRecent and close < emaFast and microBreakShort and bearMomentumScore >= reversalMomentumScore and volumeGate and shortRROK and m1ShortGate

bool allowTC = signalFamily == "Both" or signalFamily == "Trend Continuation"
bool allowREV = signalFamily == "Both" or signalFamily == "Confirmed Reversal"

bool useLongTC = allowTC and tcLongCandidate
bool useLongREV = allowREV and revLongCandidate
bool useShortTC = allowTC and tcShortCandidate
bool useShortREV = allowREV and revShortCandidate

float longExecutionScore = math.max(useLongTC ? tcLongScore : 0.0, useLongREV ? revLongScore : 0.0)
float shortExecutionScore = math.max(useShortTC ? tcShortScore : 0.0, useShortREV ? revShortScore : 0.0)
string longEntryFamily = useLongREV and revLongScore >= tcLongScore ? "REVERSAL" : "CONTINUATION"
string shortEntryFamily = useShortREV and revShortScore >= tcShortScore ? "REVERSAL" : "CONTINUATION"

bool confirmationOK = not confirmedOnly or barstate.isconfirmed
bool longReady = (useLongTC or useLongREV) and longExecutionScore >= entryScoreMin and confirmationOK
bool shortReady = (useShortTC or useShortREV) and shortExecutionScore >= entryScoreMin and confirmationOK

// ============================================================================
// 16. ENTRY STATE / COOLDOWN
// ============================================================================
var int activeTradeDir = 0
var int activeEntryBar = na
var int lastEntryBar = na
var float activeEntry = na
var float activeStop = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var float activeRisk = na
var string activeFamily = ""

bool cooldownOK = na(lastEntryBar) or bar_index - lastEntryBar > cooldownBars
bool freshLong = longReady and not longReady[1]
bool freshShort = shortReady and not shortReady[1]
bool entryLong = activeTradeDir == 0 and cooldownOK and freshLong and (not freshShort or longExecutionScore >= shortExecutionScore)
bool entryShort = activeTradeDir == 0 and cooldownOK and freshShort and (not freshLong or shortExecutionScore > longExecutionScore)

bool primeLong = entryLong and longExecutionScore >= primeScoreMin
bool primeShort = entryShort and shortExecutionScore >= primeScoreMin

// ============================================================================
// 17. TRADE MANAGEMENT OBJECTS
// ============================================================================
var line lnEntry = na
var line lnStop = na
var line lnTP1 = na
var line lnTP2 = na
var line lnTP3 = na
var label lbEntry = na
var label lbStop = na
var label lbTP1 = na
var label lbTP2 = na
var label lbTP3 = na

f_clear_trade_drawings() =>
    line.delete(lnEntry)
    line.delete(lnStop)
    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnTP3)
    label.delete(lbEntry)
    label.delete(lbStop)
    label.delete(lbTP1)
    label.delete(lbTP2)
    label.delete(lbTP3)

if entryLong
    f_clear_trade_drawings()
    activeTradeDir := 1
    activeEntryBar := bar_index
    lastEntryBar := bar_index
    activeEntry := close
    activeStop := longStopCandidate
    activeRisk := math.max(activeEntry - activeStop, syminfo.mintick)
    activeTP1 := activeEntry + activeRisk * tp1R
    activeTP2 := activeEntry + activeRisk * tp2R
    activeTP3 := activeEntry + activeRisk * tp3R
    activeFamily := longEntryFamily
    if showRiskLevels
        int x2 = bar_index + 20
        lnEntry := line.new(bar_index, activeEntry, x2, activeEntry, color=#94A3B8, style=line.style_dashed)
        lnStop := line.new(bar_index, activeStop, x2, activeStop, color=C_RED, width=2)
        lnTP1 := line.new(bar_index, activeTP1, x2, activeTP1, color=C_GREEN)
        lnTP2 := line.new(bar_index, activeTP2, x2, activeTP2, color=C_GREEN)
        lnTP3 := line.new(bar_index, activeTP3, x2, activeTP3, color=C_GREEN, width=2)
        lbEntry := label.new(x2, activeEntry, "ENTRY " + str.tostring(activeEntry, format.mintick), style=label.style_label_left, color=C_DARK, textcolor=C_WHITE, size=size.tiny)
        lbStop := label.new(x2, activeStop, "SL " + str.tostring(activeStop, format.mintick), style=label.style_label_left, color=C_RED, textcolor=C_WHITE, size=size.tiny)
        lbTP1 := label.new(x2, activeTP1, "TP1 " + str.tostring(activeTP1, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)
        lbTP2 := label.new(x2, activeTP2, "TP2 " + str.tostring(activeTP2, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)
        lbTP3 := label.new(x2, activeTP3, "TP3 " + str.tostring(activeTP3, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)

if entryShort
    f_clear_trade_drawings()
    activeTradeDir := -1
    activeEntryBar := bar_index
    lastEntryBar := bar_index
    activeEntry := close
    activeStop := shortStopCandidate
    activeRisk := math.max(activeStop - activeEntry, syminfo.mintick)
    activeTP1 := activeEntry - activeRisk * tp1R
    activeTP2 := activeEntry - activeRisk * tp2R
    activeTP3 := activeEntry - activeRisk * tp3R
    activeFamily := shortEntryFamily
    if showRiskLevels
        int x2 = bar_index + 20
        lnEntry := line.new(bar_index, activeEntry, x2, activeEntry, color=#94A3B8, style=line.style_dashed)
        lnStop := line.new(bar_index, activeStop, x2, activeStop, color=C_RED, width=2)
        lnTP1 := line.new(bar_index, activeTP1, x2, activeTP1, color=C_GREEN)
        lnTP2 := line.new(bar_index, activeTP2, x2, activeTP2, color=C_GREEN)
        lnTP3 := line.new(bar_index, activeTP3, x2, activeTP3, color=C_GREEN, width=2)
        lbEntry := label.new(x2, activeEntry, "ENTRY " + str.tostring(activeEntry, format.mintick), style=label.style_label_left, color=C_DARK, textcolor=C_WHITE, size=size.tiny)
        lbStop := label.new(x2, activeStop, "SL " + str.tostring(activeStop, format.mintick), style=label.style_label_left, color=C_RED, textcolor=C_WHITE, size=size.tiny)
        lbTP1 := label.new(x2, activeTP1, "TP1 " + str.tostring(activeTP1, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)
        lbTP2 := label.new(x2, activeTP2, "TP2 " + str.tostring(activeTP2, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)
        lbTP3 := label.new(x2, activeTP3, "TP3 " + str.tostring(activeTP3, format.mintick), style=label.style_label_left, color=C_GREEN, textcolor=C_WHITE, size=size.tiny)

// ============================================================================
// 18. MOMENTUM EXIT / TRADE LIFECYCLE
// ============================================================================
int longWeakCount = (close < emaFast ? 1 : 0) + (rsi < 50 ? 1 : 0) + (velocity < 0 ? 1 : 0)
int shortWeakCount = (close > emaFast ? 1 : 0) + (rsi > 50 ? 1 : 0) + (velocity > 0 ? 1 : 0)
bool momentumExitLong = activeTradeDir == 1 and bar_index > activeEntryBar and longWeakCount >= 2 and bullMomentumScore < 50
bool momentumExitShort = activeTradeDir == -1 and bar_index > activeEntryBar and shortWeakCount >= 2 and bearMomentumScore < 50
bool lifecycleEligible = activeTradeDir != 0 and bar_index > activeEntryBar
bool stopHit = lifecycleEligible ? (activeTradeDir == 1 ? low <= activeStop : high >= activeStop) : false
bool tp3Hit = lifecycleEligible ? (activeTradeDir == 1 ? high >= activeTP3 : low <= activeTP3) : false

bool exitLongEvent = activeTradeDir == 1 and (momentumExitLong or stopHit or tp3Hit)
bool exitShortEvent = activeTradeDir == -1 and (momentumExitShort or stopHit or tp3Hit)

if exitLongEvent or exitShortEvent
    activeTradeDir := 0

if showRiskLevels and activeTradeDir != 0 and barstate.islast
    int x2 = bar_index + 20
    line.set_x2(lnEntry, x2)
    line.set_x2(lnStop, x2)
    line.set_x2(lnTP1, x2)
    line.set_x2(lnTP2, x2)
    line.set_x2(lnTP3, x2)
    label.set_x(lbEntry, x2)
    label.set_x(lbStop, x2)
    label.set_x(lbTP1, x2)
    label.set_x(lbTP2, x2)
    label.set_x(lbTP3, x2)

// ============================================================================
// 19. VISUALS
// ============================================================================
plot(showTPPLevels ? visualResistance : na, "TPP Resistance", color=color.new(C_RED, 0), linewidth=2, style=plot.style_stepline)
plot(showTPPLevels ? visualSupport : na, "TPP Support", color=color.new(C_GREEN, 0), linewidth=2, style=plot.style_stepline)

float cloudHalf = atr * 0.35
pCloudHi = plot(showRegimeCloud ? equilibrium + cloudHalf : na, "Regime Cloud High", color=color.new(regimeColor, 100))
pCloudLo = plot(showRegimeCloud ? equilibrium - cloudHalf : na, "Regime Cloud Low", color=color.new(regimeColor, 100))
fill(pCloudHi, pCloudLo, color=showRegimeCloud ? color.new(regimeColor, 88) : na, title="Regime Cloud")

if showReactions and reactionBuy
    label.new(bar_index, low, "REACTION BUY\n" + str.tostring(math.round(buyReactionScore)) + "/100", style=label.style_label_up, color=color.new(C_GREEN, 25), textcolor=C_WHITE, size=size.tiny)
if showReactions and reactionSell
    label.new(bar_index, high, "REACTION SELL\n" + str.tostring(math.round(sellReactionScore)) + "/100", style=label.style_label_down, color=color.new(C_RED, 25), textcolor=C_WHITE, size=size.tiny)

if showEntries and entryLong
    string txt = primeLong ? "+▲ PRIME LONG" : longEntryFamily == "REVERSAL" ? "▲ REVERSAL LONG" : "▲ LONG ENTRY"
    label.new(bar_index, low, txt + "\nEXEC " + str.tostring(math.round(longExecutionScore)) + "/100", style=label.style_label_up, color=primeLong ? C_CYAN : C_GREEN, textcolor=C_DARK, size=primeLong ? size.normal : size.small)

if showEntries and entryShort
    string txt = primeShort ? "+▼ PRIME SHORT" : shortEntryFamily == "REVERSAL" ? "▼ REVERSAL SHORT" : "▼ SHORT ENTRY"
    label.new(bar_index, high, txt + "\nEXEC " + str.tostring(math.round(shortExecutionScore)) + "/100", style=label.style_label_down, color=primeShort ? C_RUBY : C_RED, textcolor=C_WHITE, size=primeShort ? size.normal : size.small)

plotchar(exitLongEvent, "Momentum Exit Long", "✕", location=location.abovebar, color=C_AMBER, size=size.small)
plotchar(exitShortEvent, "Momentum Exit Short", "✕", location=location.belowbar, color=C_AMBER, size=size.small)

plotshape(showM1PulseMarks and m1InspectorActive and m1BullHQFound, "M1 HQ Bull Pulse inside bar", style=shape.triangleup, location=location.belowbar, color=C_CYAN, size=size.tiny, text="M1")
plotshape(showM1PulseMarks and m1InspectorActive and m1BearHQFound, "M1 HQ Bear Pulse inside bar", style=shape.triangledown, location=location.abovebar, color=C_RUBY, size=size.tiny, text="M1")

// ============================================================================
// 20. DASHBOARD STATE
// ============================================================================
var int lastReactionDir = 0
var float lastReactionScore = na
if reactionBuy
    lastReactionDir := 1
    lastReactionScore := buyReactionScore
if reactionSell
    lastReactionDir := -1
    lastReactionScore := sellReactionScore

string regimeText = bullExpansion ? "BULL EXPANSION" : bearExpansion ? "BEAR EXPANSION" : compression ? "COMPRESSION" : trendDir == 1 ? "BULL TRANSITION" : trendDir == -1 ? "BEAR TRANSITION" : "TRANSITION"
color regimeCellColor = bullExpansion ? color.new(C_CYAN, 25) : bearExpansion ? color.new(C_RUBY, 15) : color.new(C_GRAY, 30)
string structureText = structureDir == 1 ? "BULLISH" : structureDir == -1 ? "BEARISH" : "NEUTRAL"
string reactionText = lastReactionDir == 1 ? "BUY " + str.tostring(math.round(lastReactionScore)) : lastReactionDir == -1 ? "SELL " + str.tostring(math.round(lastReactionScore)) : "NONE"
float bestMomentum = math.max(bullMomentumScore, bearMomentumScore)
string momentumText = bullMomentumScore > bearMomentumScore ? (bullAccelerating ? "BULL ACCEL" : "BULL " + str.tostring(math.round(bullMomentumScore))) : bearMomentumScore > bullMomentumScore ? (bearAccelerating ? "BEAR ACCEL" : "BEAR " + str.tostring(math.round(bearMomentumScore))) : "NEUTRAL"
string pullbackText = bullPullbackRecent ? "BULL CONFIRMED" : bearPullbackRecent ? "BEAR CONFIRMED" : "WAIT"
string volumeText = not hasVolume ? "N/A" : relVolume >= 1.15 ? "CONFIRMED " + str.tostring(relVolume, "#.00") + "x" : "NORMAL " + str.tostring(relVolume, "#.00") + "x"
float bestExecution = math.max(longExecutionScore, shortExecutionScore)
string executionText = longExecutionScore > shortExecutionScore ? "LONG " + str.tostring(math.round(longExecutionScore)) : shortExecutionScore > longExecutionScore ? "SHORT " + str.tostring(math.round(shortExecutionScore)) : "WAIT"
string tradeText = activeTradeDir == 1 ? "LONG " + activeFamily : activeTradeDir == -1 ? "SHORT " + activeFamily : "FLAT"
string riskText = activeTradeDir != 0 ? "SL " + str.tostring(activeStop, format.mintick) + " | TP2 " + str.tostring(activeTP2, format.mintick) : "WAIT ENTRY"

var table dash = table.new(position.top_right, 3, 12, bgcolor=C_DARK, border_color=color.new(C_GRAY, 50), border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "TPP QX", bgcolor=#0B1017, text_color=C_CYAN, text_size=size.small)
    table.cell(dash, 1, 0, profile == "Scalping" ? "SCALP" : "SWING", bgcolor=#0B1017, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 0, profile == "Scalping" ? "1m-5m" : "4H+", bgcolor=#0B1017, text_color=C_WHITE, text_size=size.small)

    table.cell(dash, 0, 1, "REGIME", text_color=C_WHITE)
    table.cell(dash, 1, 1, regimeText, bgcolor=regimeCellColor, text_color=C_WHITE)
    table.cell(dash, 2, 1, str.tostring(math.round(regimeStrength)) + "/100", text_color=C_WHITE)

    table.cell(dash, 0, 2, "STRUCTURE", text_color=C_WHITE)
    table.cell(dash, 1, 2, structureText, text_color=structureDir == 1 ? C_GREEN : structureDir == -1 ? C_RED : C_GRAY)
    table.cell(dash, 2, 2, biasTF, text_color=C_GRAY)

    table.cell(dash, 0, 3, "REACTION", text_color=C_WHITE)
    table.cell(dash, 1, 3, reactionText, text_color=lastReactionDir == 1 ? C_GREEN : lastReactionDir == -1 ? C_RED : C_GRAY)
    table.cell(dash, 2, 3, structureTF, text_color=C_GRAY)

    table.cell(dash, 0, 4, "MOMENTUM", text_color=C_WHITE)
    table.cell(dash, 1, 4, momentumText, text_color=bullMomentumScore > bearMomentumScore ? C_CYAN : C_RUBY)
    table.cell(dash, 2, 4, str.tostring(math.round(bestMomentum)) + "/100", text_color=C_WHITE)

    table.cell(dash, 0, 5, "PULLBACK", text_color=C_WHITE)
    table.cell(dash, 1, 5, pullbackText, text_color=pullbackText == "WAIT" ? C_GRAY : C_WHITE)
    table.cell(dash, 2, 5, "EQ", text_color=C_GRAY)

    table.cell(dash, 0, 6, "VOLUME", text_color=C_WHITE)
    table.cell(dash, 1, 6, volumeText, text_color=volumeStrong ? C_GREEN : C_GRAY)
    table.cell(dash, 2, 6, volumeGate ? "OK" : "LOW", text_color=volumeGate ? C_GREEN : C_RED)

    table.cell(dash, 0, 7, "EXECUTION", text_color=C_WHITE)
    table.cell(dash, 1, 7, executionText, text_color=longExecutionScore > shortExecutionScore ? C_GREEN : shortExecutionScore > longExecutionScore ? C_RED : C_GRAY)
    table.cell(dash, 2, 7, str.tostring(math.round(bestExecution)) + "/100", text_color=bestExecution >= primeScoreMin ? C_CYAN : C_WHITE)

    table.cell(dash, 0, 8, "TRADE", text_color=C_WHITE)
    table.cell(dash, 1, 8, tradeText, text_color=activeTradeDir == 1 ? C_GREEN : activeTradeDir == -1 ? C_RED : C_GRAY)
    table.cell(dash, 2, 8, activeTradeDir != 0 ? str.tostring(activeEntry, format.mintick) : "—", text_color=C_WHITE)

    table.cell(dash, 0, 9, "RISK", text_color=C_WHITE)
    table.cell(dash, 1, 9, riskText, text_color=C_WHITE)
    table.cell(dash, 2, 9, "Min " + str.tostring(minRR, "#.0") + "R", text_color=C_GRAY)

    table.cell(dash, 0, 10, "STATUS", text_color=C_WHITE)
    string statusText = entryLong ? (primeLong ? "PRIME LONG" : "LONG ENTRY") : entryShort ? (primeShort ? "PRIME SHORT" : "SHORT ENTRY") : activeTradeDir != 0 ? "MANAGE" : "WAIT TRIGGER"
    color statusColor = entryLong ? C_GREEN : entryShort ? C_RED : activeTradeDir != 0 ? C_AMBER : C_GRAY
    table.cell(dash, 1, 10, statusText, bgcolor=color.new(statusColor, 35), text_color=C_WHITE)
    table.cell(dash, 2, 10, confirmationOK ? "CONFIRMED" : "LIVE", text_color=C_WHITE)

    string m1Text = profile != "Scalping" ? "IGNORED" : not useM1Intrabars ? "OFF" : not m1DataAvailable ? "NO DATA" : m1LastDir == 1 ? "BULL x" + str.tostring(m1BullCount) : m1LastDir == -1 ? "BEAR x" + str.tostring(m1BearCount) : "NO PULSE"
    float m1Best = math.max(m1BestBull, m1BestBear)
    color m1Col = m1LastDir == 1 ? C_CYAN : m1LastDir == -1 ? C_RUBY : C_GRAY
    table.cell(dash, 0, 11, "M1 INTRABAR", text_color=C_WHITE)
    table.cell(dash, 1, 11, m1Text, text_color=m1Col)
    table.cell(dash, 2, 11, m1DataAvailable ? str.tostring(math.round(m1Best)) + "/100" : "—", text_color=C_WHITE)

// ============================================================================
// 21. ALERTS
// ============================================================================

// 1. PRIMERO: definir las condiciones FULL PRIME

bool fullPrimeLong =
     bullExpansion and
     biasBull and
     bullMomentumScore > bearMomentumScore and
     bullMomentumScore >= minMomentumScore and
     bullPullbackRecent and
     volumeGate and
     m1LongEvidence and
     m1LastDir == 1 and
     longExecutionScore >= primeScoreMin and
     longRROK and
     primeLong

bool fullPrimeShort =
     bearExpansion and
     biasBear and
     bearMomentumScore > bullMomentumScore and
     bearMomentumScore >= minMomentumScore and
     bearPullbackRecent and
     volumeGate and
     m1ShortEvidence and
     m1LastDir == -1 and
     shortExecutionScore >= primeScoreMin and
     shortRROK and
     primeShort


// 2. DESPUÉS: tus alertas actuales

alertcondition(reactionBuy, "TPP QX - BUY REACTION", "TPP QX BUY REACTION | {{ticker}} | {{interval}}")
alertcondition(reactionSell, "TPP QX - SELL REACTION", "TPP QX SELL REACTION | {{ticker}} | {{interval}}")
alertcondition(entryLong and not primeLong, "TPP QX - LONG ENTRY", "TPP QX LONG ENTRY | {{ticker}} | {{interval}} | {{close}}")
alertcondition(entryShort and not primeShort, "TPP QX - SHORT ENTRY", "TPP QX SHORT ENTRY | {{ticker}} | {{interval}} | {{close}}")
alertcondition(primeLong, "TPP QX - PRIME LONG", "TPP QX PRIME LONG | {{ticker}} | {{interval}} | {{close}}")
alertcondition(primeShort, "TPP QX - PRIME SHORT", "TPP QX PRIME SHORT | {{ticker}} | {{interval}} | {{close}}")
alertcondition(exitLongEvent, "TPP QX - EXIT LONG", "TPP QX MOMENTUM EXIT LONG | {{ticker}} | {{interval}} | {{close}}")
alertcondition(exitShortEvent, "TPP QX - EXIT SHORT", "TPP QX MOMENTUM EXIT SHORT | {{ticker}} | {{interval}} | {{close}}")
alertcondition(bullExpansion and not bullExpansion[1], "TPP QX - BULL EXPANSION", "TPP QX BULL EXPANSION | {{ticker}} | {{interval}}")
alertcondition(bearExpansion and not bearExpansion[1], "TPP QX - BEAR EXPANSION", "TPP QX BEAR EXPANSION | {{ticker}} | {{interval}}")
alertcondition(m1InspectorActive and m1BullHQFound, "TPP QX - M1 HQ BULL INSIDE BAR", "TPP QX M1 HQ BULL PULSE detected inside {{interval}} bar | {{ticker}}")
alertcondition(m1InspectorActive and m1BearHQFound, "TPP QX - M1 HQ BEAR INSIDE BAR", "TPP QX M1 HQ BEAR PULSE detected inside {{interval}} bar | {{ticker}}")

// 3. AL FINAL: las dos nuevas alertas

alertcondition(
     fullPrimeLong,
     title="TPP QX - FULL PRIME LONG",
     message="🟩 TPP QX FULL PRIME LONG | {{ticker}} | {{interval}} | Price {{close}}")

alertcondition(
     fullPrimeShort,
     title="TPP QX - FULL PRIME SHORT",
     message="🟥 TPP QX FULL PRIME SHORT | {{ticker}} | {{interval}} | Price {{close}}")
````
