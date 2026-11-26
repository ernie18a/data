# Triple Confluence Navigator [MarkitTick]

- url: https://www.tradingview.com/script/kcDuNMMA-Triple-Confluence-Navigator-MarkitTick/
- type: indicator
- pine_id: PUB;859d92c1561341428f1ad1ae7219b585
- version: 1.0

## Description

💡 A highly sophisticated analytical framework designed to identify high-probability market setups by demanding alignment across three distinct dimensions of market data: momentum crossovers, adaptive volatility momentum tracking, and structural price action. Instead of relying on a single lagging variable, this system synthesizes traditional oscillators, advanced digital signal processing (such as Kalman filtering), and structural swing analysis. By integrating automated risk management, multi-take-profit targeting, and a real-time tracking dashboard, it operates as a comprehensive suite for systematic market analysis.

[b]✨ Originality and Utility[/b]

[b]● A Multi-Dimensional Consensus Model[/b]
Most standard technical tools assess the market through a single lens, such as pure price action or pure momentum. The originality of this system lies in its stringent confluence requirements. It isolates three independent mathematical models and requires all of them to agree within a user-defined chronological window. This significantly filters out market noise and reduces the frequency of false positive signals commonly associated with sideways or choppy conditions.

[b]● Oscillatory Supertrend Application[/b]
While a Supertrend is traditionally overlaid on raw price action, this script innovates by calculating an Average True Range (ATR) directly on the Adaptive RSI (ARSI) oscillator. By establishing a Supertrend over momentum rather than price, the tool identifies the structural trend of the underlying momentum itself, offering a preemptive view of market shifts before they fully materialize in physical price movement.

[b]● Dynamic Risk-Bounding[/b]
The utility is heavily elevated by its integrated risk management architecture. Rather than relying on static pip/tick stops, the system calculates dynamic risk parameters comparing structural pivot ranges against ATR-capped maximums. This ensures that the generated stop-loss levels are mathematically sound, adapting to prevailing market volatility while adhering to strict structural invalidation points.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/1eN6LflE/[/image]
[b]• Pillar One: The Cardwell Momentum Averages[/b]
The first confluence pillar focuses on moving average crossovers applied to the Relative Strength Index (RSI). Instead of standard Simple Moving Averages, the system utilizes advanced smoothing algorithms—specifically Kalman Filters or Low Latency Adaptive Moving Averages (LLAMA). This separates the underlying momentum signal from high-frequency market noise, establishing a primary directional bias.

[b]• Pillar Two: Adaptive RSI and Oscillator Supertrend[/b]
The second pillar generates an Adaptive RSI (ARSI), normalizing the absolute differences of price movement against historical highest highs and lowest lows. This adaptive data stream is then heavily filtered and paired with a momentum-based Supertrend. A crossover between the ARSI and its own moving/volatility band dictates the secondary momentum confirmation.

[b]• Pillar Three: Market Structure and Swing Pivots[/b]
The third pillar grounds the mathematical momentum in tangible price action. The engine calculates precise pivot highs and pivot lows over a specified lookback period. A confirmed signal requires price to physically breach these structural swing levels, registering a Break of Structure (BoS) or a Change of Character (ChoCh).

[b]• The Confluence Window and HTF Bias[/b]
Signals from these three pillars rarely occur on the exact same bar. The system tracks the bars elapsed since each respective signal. If all three pillars trigger in the same direction within the defined confluence window, a master setup is generated. Furthermore, an overarching Higher Timeframe (HTF) security check ensures that these local confluences do not contradict the macro directional trend.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/LUy12iGy/[/image]
[b]• On-Chart Trade Mapping[/b]
[list]
[*]Entry Line: A dashed line indicating the exact closing price of the signal bar.
[*]Stop Loss (SL) Line: A dashed line representing the structural or volatility-based invalidation point, labeled with an X.
[*]Take Profit (TP) Lines: Three distinct dashed lines projecting the target levels based on the calculated risk multiplier.
[/list]

[b]• Signal Markers and Fills[/b]
[list]
[*]Labels: Distinct textual markers reading BUY or SELL highlight the precise candle where the triple confluence is met.
[*]Risk Zone: A translucent shaded area bridging the Entry line and the Stop Loss line, visualizing the total capital exposure.
[*]Reward Zone: A differently colored translucent shading extending from the Entry to the final Take Profit (TP3) level.
[/list]

[b]• Real-Time Dashboard[/b]
The Heads-Up Display (HUD) is a table anchored to the chart corner. It outputs the live status of the Cardwell MA, Adaptive ARSI, and Structure modules. It includes dynamic visual bars indicating current RSI and ADX levels, displays the state of the HTF bias, and calculates the live floating risk-to-reward ratio of an active setup. 

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/C2pYzuiK/[/image]
[b]• Identifying Setups[/b]
Monitor the chart for the appearance of the signal labels. When a setup is validated, the system will immediately draft the Entry, SL, and TP lines on the chart. Assess the Risk Zone and Reward Zone visuals to ensure the potential setup aligns with your personal risk tolerance.

[b]• Dashboard Monitoring[/b]
Use the dashboard to evaluate the health of the confluence. If the ADX visual bar is extremely low, it indicates market chop, suggesting that even a confluence signal might suffer from lack of follow-through. Monitor the structural trend state in the dashboard to understand the broader context of the immediate signal.

[b]• Trade Management[/b]
The predefined TP1, TP2, and TP3 lines serve as partial profit-taking areas. As price achieves TP1, consider shifting risk to breakeven, utilizing the subsequent lines as trailing markers. The HUD's Live R metric tracks the real-time fractional gain or loss based on the initial risk unit.

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/lAHYJm6I/[/image]
[b]• Momentum & Averages[/b]
[list]
[*]RSI Len: Defines the lookback period for the base oscillator.
[*]Fast/Slow Len: Defines the lookback for the moving averages applied to the oscillator.
[*]Filter Type: Dropdown to select between standard RMA, recursive Kalman Filtering, or adaptive LLAMA.
[/list]

[b]• Adaptive Volatility[/b]
[list]
[*]Kalman Process & Measurement Noise: Granular inputs adjusting the responsiveness and smoothness of the Kalman state estimation.
[*]LLAMA Min/Max Alpha: Bounds for the dynamic efficiency ratio used in the adaptive moving average.
[*]ST Factor: The volatility multiplier that determines the width of the ARSI Supertrend band.
[/list]

[b]• Structure & Trade Configuration[/b]
[list]
[*]Swing Len: The number of bars required to confirm a structural high or low.
[*]SL ATR Mult: The maximum allowable distance for a stop loss, based on True Range.
[*]SL Struct Buffer: The fractional ATR distance placed beyond a swing pivot to prevent premature stop outs.
[*]TP1/TP2/TP3 R:R: The dynamic risk multiples used to project the take profit levels.
[*]Confluence Window: The maximum number of bars allowed to pass between the three distinct pillar signals for them to remain valid together.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]• Recursive State Estimation (Kalman Filter)[/b]
The inclusion of a Kalman-inspired filter applies concepts from control theory and digital signal processing. Unlike simple averaging which inherently introduces phase lag, this algorithm estimates the true state of the momentum by predicting the next value and updating its estimation based on the actual measured value. By weighing the process noise against the measurement noise, the script aggressively smooths erratic momentum spikes while instantly snapping to genuine directional shifts.

[b]• Adaptive Linear Regression (LLAMA)[/b]
The Low Latency Adaptive Moving Average applies statistical regression to determine the current market phase. It calculates the slope of the data over a set period and compares it to the absolute range of that period to derive an Efficiency Ratio. This ratio acts as a dynamic alpha coefficient. In highly efficient, directional markets, the alpha increases, forcing the average to tightly track the data. In inefficient, mean-reverting markets, the alpha decreases, flattening the average to ignore statistical noise.

[b]• Statistical Variance and Orthogonal Agreement[/b]
By mandating a Triple Confluence, the system relies on the reduction of statistical variance. The three pillars—price structure, base momentum, and adaptive momentum bands—are mathematically orthogonal; they calculate market state using distinctly different algorithms. The probability of all three aligning purely by chance (random walk) is exceptionally low. Therefore, when confluence is achieved, it represents a statistically significant deviation from market equilibrium, highlighting a high-probability directional vector.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Triple Confluence Navigator [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500)
// ── INPUTS ─────────────────────────────────────────────────────
const string G_RSI    = "⚙️ Cardwell RSI"
const string G_MA     = "⚙️ Cardwell MA"
const string G_ARSI   = "🌊 Adaptive RSI"
const string G_ST     = "🌊 Supertrend"
const string G_BOS    = "🧱 Structure"
const string G_HTF    = "🕯️ HTF Filter"
const string G_CHOP   = "🕯️ Choppiness"
const string G_TRADE  = "📐 Trade Setup"
const string G_VIS    = "🎨 Visuals"
const string G_DASH   = "📊 Dash"
const string G_COL    = "🌈 Colors"
int    rsiLen        = input.int(14, "RSI Len", minval=2, group=G_RSI)
int    rmaFastLen    = input.int(9, "Fast Len", minval=2, group=G_MA)
int    rmaSlowLen    = input.int(45, "Slow Len", minval=2, group=G_MA)
string maType         = input.string("Kalman", "Filter Type", options=["RMA", "Kalman", "LLAMA"], group=G_MA)
int    arsiLen        = input.int(14, "ARSI Len", minval=2, group=G_ARSI)
int    arsiSigLen     = input.int(14, "Signal Len", minval=1, group=G_ARSI)
string arsiFiltType    = input.string("Kalman Filter", "Filter Type", options=["RMA", "Kalman Filter", "LLAMA"], group=G_ARSI)
float  kalmanProcN    = input.float(0.01, "Kalman Proc N", minval=0.0001, step=0.001, group=G_ARSI)
float  kalmanMeasN    = input.float(0.10, "Kalman Meas N", minval=0.0001, step=0.01, group=G_ARSI)
float  llamaAlphaMin  = input.float(0.05, "LLAMA Min α", minval=0.01, maxval=0.99, step=0.01, group=G_ARSI)
float  llamaAlphaMax  = input.float(0.50, "LLAMA Max α", minval=0.01, maxval=0.99, step=0.01, group=G_ARSI)
int    stAtrLen       = input.int(14, "ST ATR Len", minval=1, group=G_ST)
float  stFactor       = input.float(2.0, "ST Factor", minval=0.1, step=0.1, group=G_ST)
int    swingLen        = input.int(5, "Swing Len", minval=3, maxval=50, group=G_BOS)
int    atrLen         = input.int(14, "ATR Len", minval=1, group=G_TRADE)
float  atrMultSl       = input.float(1.5, "SL ATR Mult", minval=0.1, step=0.1, group=G_TRADE)
float  slStructBuf      = input.float(0.25, "SL Struct Buffer (ATR)", minval=0.0, step=0.05, group=G_TRADE)
float  rr1            = input.float(1.0, "TP1 R:R", minval=0.1, step=0.1, group=G_TRADE)
float  rr2            = input.float(2.0, "TP2 R:R", minval=0.1, step=0.1, group=G_TRADE)
float  rr3            = input.float(3.0, "TP3 R:R", minval=0.1, step=0.1, group=G_TRADE)
int    confluenceWindow = input.int(5, "Confluence Window", minval=1, maxval=50, group=G_TRADE)
bool   useHtfFilter    = input.bool(false, "Enable HTF Filter", group=G_HTF)
string htfTimeframe    = input.timeframe("240", "HTF TF", group=G_HTF)
bool   useChopFilter    = input.bool(false, "Enable ADX Filter", group=G_CHOP)
int    adxLen          = input.int(14, "ADX Len", minval=1, group=G_CHOP)
float  adxMinLevel     = input.float(20.0, "Min ADX", minval=1.0, step=1.0, group=G_CHOP)
bool   showDash         = input.bool(true, "Show Dashboard", group=G_DASH)
string dashPos          = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
var string GRP_WH        = "🔔 Alerts"
i_actionLong              = input.string("long", "↑ Long Action", group=GRP_WH)
i_actionShort             = input.string("short", "↓ Short Action", group=GRP_WH)
i_actionCloseLong         = input.string("closelong", "✕ Close Long Action", group=GRP_WH)
i_actionCloseShort        = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)
color  colEntry         = input.color(#1e3a5c, "Entry", group=G_COL)
color  colSl           = input.color(#7a1f1f, "SL", group=G_COL)
color  colTp1           = input.color(#0e5c4a, "TP1", group=G_COL)
color  colTp2           = input.color(#0e6e52, "TP2", group=G_COL)
color  colTp3           = input.color(#12a382, "TP3", group=G_COL)
color  colBuyLbl        = input.color(#26a69a, "Buy Label", group=G_COL)
color  colSellLbl       = input.color(#ef5350, "Sell Label", group=G_COL)
color  zoneRiskColor    = input.color(color.new(#7a1f1f,55), "Risk Zone Fill", group=G_COL)
color  zoneRewardColor  = input.color(color.new(#0e5c4a,70), "Reward Zone Fill", group=G_COL)
color  dashBgColor      = input.color(color.new(#0a0f1a,10), "BG", group=G_COL)
color  dashHdrColor     = input.color(color.new(#14b5cb,20), "Header BG", group=G_COL)
color  dashLabelColor    = input.color(color.new(#ffffff,30), "Label Text", group=G_COL)
color  dashValueColor    = input.color(color.new(#ffffff,0), "Value Text", group=G_COL)
// ── CORE LOGIC ─────────────────────────────────────────────────
f_kalman(float src, float procN, float measN) =>
    var float _est = na
    var float _cov = 1.0
    if na(_est)
        _est := src
    _cov := _cov + procN
    float _gain = _cov / (_cov + measN)
    _est := _est + _gain * (src - _est)
    _cov := (1 - _gain) * _cov
    _est
f_llama(float src, int len, float aMin, float aMax) =>
    var float _out = na
    if na(_out)
        _out := src
    float _slope = (src - src[len]) / len
    float _range = ta.highest(src, len) - ta.lowest(src, len)
    float _eff   = _range != 0 ? math.min(math.abs(_slope * len) / _range, 1.0) : 0.0
    float _alpha = aMin + _eff * (aMax - aMin)
    _out := _out + _alpha * (src - _out)
    _out
f_arsi(int len) =>
    float u = ta.highest(close, len)
    float l = ta.lowest(close, len)
    float _r = u - l
    float _d = close - close[1]
    float _diff = u > u[1] ? _r : l < l[1] ? -_r : _d
    float _num = ta.rma(_diff, len)
    float _den = ta.rma(math.abs(_diff), len)
    _den != 0 ? _num / _den * 50 + 50 : 50
f_arsiFilter(float src, int len, string mode, float procN, float measN, float aMin, float aMax) =>
    float _rmaOut    = ta.rma(src, len)
    float _kalmanOut = f_kalman(src, procN, measN)
    float _llamaOut  = f_llama(src, len, aMin, aMax)
    mode == "RMA" ? _rmaOut : mode == "Kalman Filter" ? _kalmanOut : _llamaOut
f_blockBar(float rawVal, float domainMax) =>
    float pct = math.min(math.max(rawVal / domainMax * 100.0, 0.0), 100.0)
    int   n   = math.round(pct / 10.0)
    string s  = ''
    for i = 1 to 10
        s += i <= n ? '█' : '░'
    s + '  ' + str.tostring(math.round(pct), '##0') + '%'
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a,0) : pct >= 0.33 ? color.new(#f9a825,0) : color.new(#ef5350,0)
float rsiValue   = ta.rsi(close, rsiLen)
var float _kfFastX = na
var float _kfFastP = 1.0
var float _kfSlowX = na
var float _kfSlowP = 1.0
float _kfQ = 0.001
float _kfR = 0.01
float _kfFastK = _kfFastP / (_kfFastP + _kfR)
_kfFastX := nz(_kfFastX, rsiValue) + _kfFastK * (rsiValue - nz(_kfFastX, rsiValue))
_kfFastP := (1.0 - _kfFastK) * _kfFastP + _kfQ
float _kfSlowK = _kfSlowP / (_kfSlowP + _kfR * (rmaSlowLen / rmaFastLen))
_kfSlowX := nz(_kfSlowX, rsiValue) + _kfSlowK * (rsiValue - nz(_kfSlowX, rsiValue))
_kfSlowP := (1.0 - _kfSlowK) * _kfSlowP + _kfQ
float rmaFast = maType == "Kalman" ? _kfFastX : maType == "LLAMA" ? ta.linreg(rsiValue, rmaFastLen, 0) : ta.rma(rsiValue, rmaFastLen)
float rmaSlow = maType == "Kalman" ? _kfSlowX : maType == "LLAMA" ? ta.linreg(rsiValue, rmaSlowLen, 0) : ta.rma(rsiValue, rmaSlowLen)
bool rawBullCross = rmaFast[1] > rmaSlow[1] and rmaFast[2] <= rmaSlow[2]
bool rawBearCross = rmaFast[1] < rmaSlow[1] and rmaFast[2] >= rmaSlow[2]
float atrValue  = ta.atr(atrLen)
float atrValue1 = nz(atrValue[1], atrValue)
float htfRmaFast = request.security(syminfo.tickerid, htfTimeframe, ta.rma(ta.rsi(close, rsiLen), rmaFastLen)[1], lookahead=barmerge.lookahead_on)
float htfRmaSlow = request.security(syminfo.tickerid, htfTimeframe, ta.rma(ta.rsi(close, rsiLen), rmaSlowLen)[1], lookahead=barmerge.lookahead_on)
bool  htfBullBias = htfRmaFast > htfRmaSlow
bool  htfBearBias = htfRmaFast < htfRmaSlow
bool bullCross1 = rawBullCross and (not useHtfFilter or htfBullBias)
bool bearCross1 = rawBearCross and (not useHtfFilter or htfBearBias)
[adxPlusDi, adxMinusDi, adxValue] = ta.dmi(adxLen, adxLen)
bool chopOk = not useChopFilter or adxValue[1] >= adxMinLevel
bool bullSignal1 = bullCross1 and chopOk
bool bearSignal1 = bearCross1 and chopOk
float arsi        = f_arsi(arsiLen)
float arsiSignal  = f_arsiFilter(arsi, arsiSigLen, arsiFiltType, kalmanProcN, kalmanMeasN, llamaAlphaMin, llamaAlphaMax)
float arsiAtr      = ta.rma(math.abs(arsi - arsi[1]), stAtrLen)
float upperBand    = arsi + stFactor * arsiAtr
float lowerBand    = arsi - stFactor * arsiAtr
var float supertrend = na
var bool  trendUp     = true
float prevSupertrend = supertrend
bool  prevTrendUp    = trendUp
if na(prevSupertrend)
    supertrend := upperBand
    trendUp    := true
else
    if arsi > prevSupertrend
        trendUp := true
    else if arsi < prevSupertrend
        trendUp := false
    else
        trendUp := prevTrendUp
    supertrend := trendUp ? math.max(lowerBand, prevSupertrend) : math.min(upperBand, prevSupertrend)
float rawMerged   = na(supertrend) ? arsiSignal : (arsiSignal + supertrend) / 2
bool rawBullCross2 = ta.crossover(arsi[1], rawMerged[1])
bool rawBearCross2 = ta.crossunder(arsi[1], rawMerged[1])
float htfArsiRaw = request.security(syminfo.tickerid, htfTimeframe, f_arsi(arsiLen)[1], lookahead=barmerge.lookahead_on)
bool  htfArsiBull = htfArsiRaw >= 50.0
bool  htfArsiBear = htfArsiRaw < 50.0
bool bullSignal2 = rawBullCross2 and (not useHtfFilter or htfArsiBull)
bool bearSignal2 = rawBearCross2 and (not useHtfFilter or htfArsiBear)
float htfRsiRaw = request.security(syminfo.tickerid, htfTimeframe, ta.rsi(close, rsiLen)[1], lookahead=barmerge.lookahead_on)
bool  htfBull3   = htfRsiRaw > 50.0
bool  htfBear3   = htfRsiRaw < 50.0
bool  htfOkBull3 = not useHtfFilter or htfBull3
bool  htfOkBear3 = not useHtfFilter or htfBear3
f_pivotHigh(int len) =>
    float _c = high[len]
    bool  _ok = barstate.isconfirmed
    for i = 0 to len - 1
        if high[i] >= _c
            _ok := false
    for i = len + 1 to len * 2
        if high[i] > _c
            _ok := false
    _ok ? _c : na
f_pivotLow(int len) =>
    float _c = low[len]
    bool  _ok = barstate.isconfirmed
    for i = 0 to len - 1
        if low[i] <= _c
            _ok := false
    for i = len + 1 to len * 2
        if low[i] < _c
            _ok := false
    _ok ? _c : na
float ph = f_pivotHigh(swingLen)
float pl = f_pivotLow(swingLen)
var float lastSwingHigh        = na
var float lastSwingLow         = na
var int   lastSwingHighBar     = na
var int   lastSwingLowBar      = na
var int   lastProcessedHighBar = na
var int   lastProcessedLowBar  = na
var int   trend3               = 0
if not na(ph)
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - swingLen
if not na(pl)
    lastSwingLow     := pl
    lastSwingLowBar  := bar_index - swingLen
bool breakUp   = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and htfOkBull3 and (na(lastProcessedHighBar) or lastSwingHighBar != lastProcessedHighBar)
bool breakDown = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and htfOkBear3 and (na(lastProcessedLowBar) or lastSwingLowBar != lastProcessedLowBar)
bool bosBull   = breakUp and trend3 >= 0
bool bosBear   = breakDown and trend3 <= 0
bool chochBull = breakUp and trend3 == -1
bool chochBear = breakDown and trend3 == 1
if breakUp
    lastProcessedHighBar := lastSwingHighBar
    trend3 := 1
if breakDown
    lastProcessedLowBar := lastSwingLowBar
    trend3 := -1
bool bullSignal3 = breakUp
bool bearSignal3 = breakDown
var int barsSinceBull1 = 9999
var int barsSinceBear1 = 9999
var int barsSinceBull2 = 9999
var int barsSinceBear2 = 9999
var int barsSinceBull3 = 9999
var int barsSinceBear3 = 9999
barsSinceBull1 := bullSignal1 ? 0 : barsSinceBull1 + 1
barsSinceBear1 := bearSignal1 ? 0 : barsSinceBear1 + 1
barsSinceBull2 := bullSignal2 ? 0 : barsSinceBull2 + 1
barsSinceBear2 := bearSignal2 ? 0 : barsSinceBear2 + 1
barsSinceBull3 := bullSignal3 ? 0 : barsSinceBull3 + 1
barsSinceBear3 := bearSignal3 ? 0 : barsSinceBear3 + 1
bool bullConfluence = barsSinceBull1 <= confluenceWindow and barsSinceBull2 <= confluenceWindow and barsSinceBull3 <= confluenceWindow
bool bearConfluence = barsSinceBear1 <= confluenceWindow and barsSinceBear2 <= confluenceWindow and barsSinceBear3 <= confluenceWindow
bool longSignal  = bullConfluence and not bullConfluence[1] and barstate.isconfirmed
bool shortSignal = bearConfluence and not bearConfluence[1] and barstate.isconfirmed
var bool  tradeActive = false
var bool  tradeIsLong = true
var float trkSl       = na
var float trkTp1      = na
var float trkTp2      = na
var float trkTp3      = na
var float trkEntry    = na
var line  slLine    = na
var line  entryLine = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var label slLbl     = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var linefill riskFill   = na
var linefill rewardFill = na
var int   trkStartBar   = na
f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)
if longSignal
    f_deleteLevels()
    float entryPrice   = close[1]
    float atrCapDist   = atrValue1 * atrMultSl
    float structDist   = na(lastSwingLow) ? na : entryPrice - (lastSwingLow - atrValue1 * slStructBuf)
    float riskDist      = na(structDist) or structDist <= 0 ? atrCapDist : math.min(structDist, atrCapDist)
    float slPrice    = entryPrice - riskDist
    float tp1Price   = entryPrice + riskDist * rr1
    float tp2Price   = entryPrice + riskDist * rr2
    float tp3Price   = entryPrice + riskDist * rr3
    int x1 = bar_index
    slLine    := line.new(x1, slPrice, x1, slPrice, color=colSl, width=1, style=line.style_dashed)
    entryLine := line.new(x1, entryPrice, x1, entryPrice, color=colEntry, width=1, style=line.style_dashed)
    tp1Line   := line.new(x1, tp1Price, x1, tp1Price, color=colTp1, width=1, style=line.style_dashed)
    tp2Line   := line.new(x1, tp2Price, x1, tp2Price, color=colTp2, width=1, style=line.style_dashed)
    tp3Line   := line.new(x1, tp3Price, x1, tp3Price, color=colTp3, width=1, style=line.style_dashed)
    riskFill   := linefill.new(slLine, entryLine, zoneRiskColor)
    rewardFill := linefill.new(entryLine, tp3Line, zoneRewardColor)
    slLbl    := label.new(x1, slPrice, "✕ SL  " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=colSl, textcolor=color.white, size=size.small)
    entryLbl := label.new(x1, entryPrice, "▶ Entry  " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=colEntry, textcolor=color.white, size=size.small)
    tp1Lbl   := label.new(x1, tp1Price, "● TP1  " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=colTp1, textcolor=color.white, size=size.small)
    tp2Lbl   := label.new(x1, tp2Price, "★ TP2  " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=colTp2, textcolor=color.white, size=size.small)
    tp3Lbl   := label.new(x1, tp3Price, "◆ TP3  " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=colTp3, textcolor=color.white, size=size.small)
    tradeActive := true
    tradeIsLong := true
    trkSl       := slPrice
    trkTp1      := tp1Price
    trkTp2      := tp2Price
    trkTp3      := tp3Price
    trkEntry    := entryPrice
    trkStartBar := x1
if shortSignal
    f_deleteLevels()
    float entryPrice   = close[1]
    float atrCapDist   = atrValue1 * atrMultSl
    float structDist   = na(lastSwingHigh) ? na : (lastSwingHigh + atrValue1 * slStructBuf) - entryPrice
    float riskDist      = na(structDist) or structDist <= 0 ? atrCapDist : math.min(structDist, atrCapDist)
    float slPrice    = entryPrice + riskDist
    float tp1Price   = entryPrice - riskDist * rr1
    float tp2Price   = entryPrice - riskDist * rr2
    float tp3Price   = entryPrice - riskDist * rr3
    int x1 = bar_index
    slLine    := line.new(x1, slPrice, x1, slPrice, color=colSl, width=1, style=line.style_dashed)
    entryLine := line.new(x1, entryPrice, x1, entryPrice, color=colEntry, width=1, style=line.style_dashed)
    tp1Line   := line.new(x1, tp1Price, x1, tp1Price, color=colTp1, width=1, style=line.style_dashed)
    tp2Line   := line.new(x1, tp2Price, x1, tp2Price, color=colTp2, width=1, style=line.style_dashed)
    tp3Line   := line.new(x1, tp3Price, x1, tp3Price, color=colTp3, width=1, style=line.style_dashed)
    riskFill   := linefill.new(slLine, entryLine, zoneRiskColor)
    rewardFill := linefill.new(entryLine, tp3Line, zoneRewardColor)
    slLbl    := label.new(x1, slPrice, "✕ SL  " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=colSl, textcolor=color.white, size=size.small)
    entryLbl := label.new(x1, entryPrice, "▶ Entry  " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=colEntry, textcolor=color.white, size=size.small)
    tp1Lbl   := label.new(x1, tp1Price, "● TP1  " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=colTp1, textcolor=color.white, size=size.small)
    tp2Lbl   := label.new(x1, tp2Price, "★ TP2  " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=colTp2, textcolor=color.white, size=size.small)
    tp3Lbl   := label.new(x1, tp3Price, "◆ TP3  " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=colTp3, textcolor=color.white, size=size.small)
    tradeActive := true
    tradeIsLong := false
    trkSl       := slPrice
    trkTp1      := tp1Price
    trkTp2      := tp2Price
    trkTp3      := tp3Price
    trkEntry    := entryPrice
    trkStartBar := x1
if not na(slLine)
    int x2 = math.min(bar_index, trkStartBar + 50)
    line.set_x2(slLine, x2)
    line.set_x2(entryLine, x2)
    line.set_x2(tp1Line, x2)
    line.set_x2(tp2Line, x2)
    line.set_x2(tp3Line, x2)
    label.set_x(slLbl, x2)
    label.set_x(entryLbl, x2)
    label.set_x(tp1Lbl, x2)
    label.set_x(tp2Lbl, x2)
    label.set_x(tp3Lbl, x2)
// ── ALERTS ─────────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(trkSl, format.mintick),
     str.tostring(trkTp1, format.mintick),
     str.tostring(trkTp2, format.mintick),
     str.tostring(trkTp3, format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(trkSl, format.mintick),
     str.tostring(trkTp1, format.mintick),
     str.tostring(trkTp2, format.mintick),
     str.tostring(trkTp3, format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"
string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
alertcondition(longSignal and barstate.isconfirmed, "BUY Signal", "MarkitTick — Triple Confluence BUY")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal", "MarkitTick — Triple Confluence SELL")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
// ── VISUALS ──────────────────────────────────────────────────
if longSignal
    label.new(bar_index, low, "BUY", yloc=yloc.belowbar, style=label.style_label_up, color=colBuyLbl, textcolor=color.white, size=size.small)
if shortSignal
    label.new(bar_index, high, "SELL", yloc=yloc.abovebar, style=label.style_label_down, color=colSellLbl, textcolor=color.white, size=size.small)
// ── DASHBOARD ───────────────────────────────────────────────────
f_dashPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(f_dashPos(dashPos), 2, 9, border_width=1, border_color=color.new(#14b5cb,60), frame_width=1, frame_color=color.new(#14b5cb,60))
if showDash
    table.cell(dash, 0, 0, "Triple Confluence", text_color=dashValueColor, bgcolor=dashHdrColor, text_halign=text.align_left, text_size=size.normal)
    table.cell(dash, 1, 0, "", bgcolor=dashHdrColor, text_size=size.normal)
    table.cell(dash, 0, 1, "Cardwell", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, bullSignal1 ? "▲ Bull" : bearSignal1 ? "▼ Bear" : "● Wait", text_color=bullSignal1 ? #26a69a : bearSignal1 ? #ef5350 : #f9a825, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 2, "Adaptive ARSI", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, bullSignal2 ? "▲ Bull" : bearSignal2 ? "▼ Bear" : "● Wait", text_color=bullSignal2 ? #26a69a : bearSignal2 ? #ef5350 : #f9a825, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 3, "Structure", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    string _structStr = bullSignal3 ? "▲ Bull" : bearSignal3 ? "▼ Bear" : trend3 == 1 ? "▲ Bull" : trend3 == -1 ? "▼ Bear" : "● Wait"
    color  _structCol = bullSignal3 ? #26a69a : bearSignal3 ? #ef5350 : trend3 == 1 ? #26a69a : trend3 == -1 ? #ef5350 : #f9a825
    table.cell(dash, 1, 3, _structStr, text_color=_structCol, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 4, "RSI", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, f_blockBar(rsiValue,100.0), text_color=f_barColor(rsiValue/100.0), bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 5, "ADX", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 5, f_blockBar(adxValue,50.0), text_color=f_barColor(adxValue/50.0), bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 6, "HTF Bias", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, useHtfFilter ? (htfBullBias ? "📈 Bull" : "📉 Bear") : "Off", text_color=useHtfFilter ? (htfBullBias ? #26a69a : #ef5350) : color.gray, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 7, "Trade", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 7, tradeActive ? (tradeIsLong ? "▲ Long" : "▼ Short") : "—", text_color=tradeActive ? (tradeIsLong ? #26a69a : #ef5350) : color.gray, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
    float riskUnit = math.abs(trkEntry - trkSl)
    float currentR = tradeActive and not na(riskUnit) and riskUnit > 0 ? (tradeIsLong ? (close - trkEntry) / riskUnit : (trkEntry - close) / riskUnit) : na
    table.cell(dash, 0, 8, "Live R", text_color=dashLabelColor, bgcolor=color.new(#0a0f1a,0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 8, na(currentR) ? "—" : (currentR >= 0 ? "+" : "") + str.tostring(currentR, "#.##") + "R", text_color=na(currentR) ? color.gray : currentR >= 0 ? #26a69a : #ef5350, bgcolor=color.new(#0d1117,0), text_halign=text.align_right, text_size=size.small)
````
