<!-- tradingview-pine-id: PUB;53c39189baf24d43a3b4b994f8598aab -->
<!-- tradingviewscripts-format: 1 -->
# Triple Supertrend Confluence [MarkitTick]

Source: https://www.tradingview.com/script/J3lVk5Qo-Triple-Supertrend-Confluence-MarkitTick/

## Description

💡 A triple-layer Supertrend confluence system that fuses adaptive volatility bands, multi-timeframe bias, momentum strength, volume conviction, and a cooldown throttle into a single, high-confidence trend signal — then automates the entire trade plan around it with ATR-scaled stop-loss and three staged take-profit levels.

✨ Originality and Utility
Most Supertrend implementations on the platform are single-instance: one ATR period, one multiplier, one line. This script restructures the classic Supertrend into a voting system. Three independently parameterized Supertrend instances (a primary "core" trend and two auxiliary "fast" and "slow" trackers) are calculated in parallel from the same underlying price source, and a signal is only treated as valid when a configurable number of these instances agree on direction. This confluence layer is what separates the tool from a standard Supertrend plot — it is designed to filter out the single biggest weakness of trend-following overlays: getting whipsawed by a solitary indicator flipping on marginal price action.

On top of the consensus layer, the script lets traders stack up to four independent, optional confirmation filters (trend strength via ADX/DMI, higher-timeframe directional bias, relative volume, and a bar-count cooldown) before a signal is considered "confirmed." Each filter can be toggled independently, so the tool scales from a bare-bones single Supertrend up to a fully gated, multi-condition trend-following system. A real-time dashboard keeps every filter's pass/fail state visible at a glance, and an automated trade-planning layer converts each confirmed flip into a structured entry/stop/three-tier-target plan, plotted directly on the chart and exposed through webhook-ready JSON alert payloads.

🔬 Methodology and Concepts
[image]https://www.tradingview.com/x/87cJ9Lnq/[/image]
• Core Supertrend Engine
The underlying trend engine follows the standard Supertrend construction: an ATR-derived envelope is built around a price source, with an upper band (source plus a multiple of ATR) and a lower band (source minus a multiple of ATR). These bands are "ratcheted" bar to bar — the lower band can only rise or reset if price closes below the prior lower band, and the upper band can only fall or reset if price closes above the prior upper band. The active trend line switches between the lower band (uptrend) and upper band (downtrend) whenever price closes through the opposite band, producing the familiar stepped Supertrend line. This engine is reused three times with different parameters to build the confluence system described below.

• Adaptive Source Smoothing
Rather than feeding raw HL2 price directly into the Supertrend engine, the script offers eight optional smoothing methods to pre-condition the source: Simple, Exponential, and Wilder's Moving Averages; a Double-Pass Weighted Moving Average; a Triple-Pass Volume-Weighted Moving Average; a Hull Moving Average; a custom slope-adjusted average (LLAMA) that blends a simple mean with a linear slope projection over the lookback window; and a single-state Kalman Filter that recursively updates an estimate and its error covariance bar by bar to produce a noise-adaptive average. Smoothing the source before it reaches the Supertrend calculation reduces false flips caused by single-bar noise spikes, at the cost of some responsiveness.

• Adaptive Volatility Factor
Instead of using a fixed ATR multiplier for the core Supertrend band width, the script can compute a percentile rank of current ATR against its own recent history (a lookback window of your choosing). This rank is then mapped linearly onto a user-defined minimum/maximum multiplier range. In practice, this means the band automatically widens during historically high-volatility regimes (reducing whipsaw) and tightens during historically low-volatility regimes (increasing sensitivity), rather than using one static multiplier across all conditions.

• Triple Consensus Voting
Two additional Supertrend instances — a faster-reacting pair (shorter ATR length, smaller multiplier) and a slower-reacting pair (longer ATR length, larger multiplier) — run alongside the core engine on the same smoothed source. When consensus mode is enabled, a signal is only marked confirmed if at least two of the three instances (including the core) agree on direction. This is a simple majority-vote filter designed to suppress signals that are specific to one particular band setting rather than representative of the broader trend structure.

• ADX / DMI Trend Strength Filter
An optional Average Directional Index filter, calculated using Wilder's Directional Movement methodology, requires ADX to be at or above a user-defined threshold before a flip is confirmed. This is a standard technique for distinguishing genuine directional moves from choppy, non-trending price action, since Supertrend-style systems are known to underperform in low-ADX ranging conditions.

• Higher-Timeframe Bias Filter
An optional filter pulls the trend direction of the same Supertrend engine calculated on a higher, user-selected timeframe, and only confirms a signal if it aligns with that higher-timeframe bias. The higher-timeframe value is read from the prior, fully closed bar on that timeframe to avoid any intra-bar recalculation, ensuring the filter reflects only confirmed historical structure rather than an in-progress bar.

• Volume Confirmation Filter
An optional filter compares current bar volume against its own moving average, requiring volume to exceed the average by a user-defined multiple before a signal is confirmed. This is a simple conviction check: trend changes accompanied by above-average participation are treated as more reliable than those occurring on thin volume.

• Cooldown Guard
An optional bar-count throttle prevents a new confirmed signal in the same direction as a recent prior signal if too few bars have elapsed since that prior signal within the same directional segment, reducing rapid re-signaling during choppy transition periods.

• Confirmation Lag Notice
All confirmation logic (consensus vote, ADX filter, HTF bias, volume filter, cooldown guard) and the resulting BULL/BEAR labels, alerts, and trade-level plotting are evaluated strictly on confirmed, closed bars using barstate.isconfirmed. This means every signal displayed or alerted is final and will not repaint once printed. However, users should be aware that a signal is only confirmed one bar after the actual Supertrend flip occurs, since the confirmation checks (particularly the higher-timeframe bias filter) require a fully closed bar to evaluate safely. This introduces a small, deliberate one-bar lag between the raw trend flip and the confirmed signal in exchange for eliminating repainting.

• Automated Trade Level Engine
On every confirmed flip, the script calculates a full trade plan from the entry price (the confirmed close), an ATR-scaled stop-loss (a user-defined multiple of ATR away from entry), and three take-profit levels defined as user-configurable risk:reward multiples of the initial stop distance. These levels are drawn as extending lines and labels, with shaded risk and reward zones between them, and refresh automatically on each new confirmed signal unless the signal is manually locked.

🎨 Visual Guide
[image]https://www.tradingview.com/x/ze1qfNT4/[/image]

[*]Stepped trend line (color reflects the Up/Down Color inputs): traces the active Supertrend band. It plots along the lower band while price is in an uptrend and the upper band while price is in a downtrend.
[*]Muted/gray trend line: when a filter is active but not yet satisfied, the trend line temporarily switches to the Unconfirmed Color to signal that the raw trend has flipped but confirmation is still pending.
[*]Soft background fill (Up Fill / Down Fill colors): a translucent shaded region behind price reinforcing the current trend direction.
[*]Heatmap candles: when enabled, candle bodies and wicks are recolored using the Heatmap Up/Down colors to match the current trend direction, offering an at-a-glance visual of trend state independent of the line itself.
[*]"BULL" / "BEAR" labels: printed below or above the bar respectively, only on confirmed flips that pass every active filter.
[*]Gray cooldown background: a shaded band that appears across the chart while the Cooldown Guard is actively suppressing new signals.
[*]Trade level lines: a solid red Stop-Loss line, a dashed blue Entry line, and three dashed teal Take-Profit lines (TP1 lightest, TP3 most opaque), each extending to the right of the current bar with a price label attached, shown only when Show Trade Levels is enabled.
[*]Shaded risk/reward zones: a light red fill between Stop-Loss and Entry (the risk zone) and a light teal fill between Entry and TP3 (the reward zone).
[*]On-chart dashboard table: displays symbol/timeframe, Lock status, current Trend direction, Confirmed state, ADX value with a color-coded strength percentage, active Adaptive Filter type, Consensus vote count, HTF Bias direction and pass/fail, Volume filter pass/fail, and remaining Cooldown bars — all updating on the most recent bar.

📖 How to Use
[image]https://www.tradingview.com/x/BLZMeXzb/[/image]

[*]Use the stepped trend line and background fill as the primary trend read: price above the line with an up-colored fill suggests an uptrend context; price below with a down-colored fill suggests a downtrend context.
[*]Treat a "BULL" or "BEAR" label as the actionable signal rather than the raw line flip — labels only appear once every enabled filter has passed, meaning the signal has already been screened for trend strength, higher-timeframe alignment, volume conviction, and cooldown status.
[*]If the trend line is showing the Unconfirmed Color, the underlying trend has technically flipped but is still waiting on one or more active filters — treat this as a "watch" state rather than a trade trigger.
[*]Check the dashboard on each new bar to see exactly which filter(s) are passing or failing before a signal can confirm; this is useful for understanding why an expected signal did not appear.
[*]When Show Trade Levels is enabled, use the plotted Stop-Loss, Entry, and TP1/TP2/TP3 lines as a starting reference for structuring a trade around a confirmed signal — adjust position sizing and targets to your own risk tolerance.
[*]Enable Lock Signal to freeze the current trade-level plot in place (useful for screenshots or reviewing a specific setup) without it being overwritten by a new signal.
[*]The JSON alert payloads are formatted for direct use in webhook-based automation, carrying action, ticker, timeframe, direction, and price fields for long entries, short entries, and their corresponding close-position triggers.

⚙️ Inputs and Settings
[image]https://www.tradingview.com/x/PTixNCg2/[/image]

[*]ATR Len / Factor: the ATR lookback and multiplier for the core Supertrend engine; higher Factor values produce a looser band and fewer, larger-magnitude signals.
[*]Adaptive Factor (and Min/Max/Rank Len): when enabled, replaces the fixed Factor with a volatility-percentile-driven multiplier that ranges between Factor Min and Factor Max based on where current ATR sits within its own recent history.
[*]Use ADX Filter / ADX Threshold / ADX Length: gates signal confirmation on trend strength; raise the threshold to demand stronger directional conviction before confirming.
[*]Adaptive Filter / Adaptive Filter Len: selects the source-smoothing method applied before the Supertrend calculation, and its lookback length.
[*]Use HTF Confluence / HTF: requires the selected higher timeframe's own Supertrend direction to agree before confirming a signal.
[*]Use Volume Filter / Volume Avg Len / Volume Mult: requires current volume to exceed its moving average by the given multiple before confirming.
[*]Use Cooldown Guard / Cooldown Bars: suppresses new same-direction signals for a set number of bars following a recent prior signal in the same directional segment.
[*]Use Triple Consensus / Fast Factor / Fast ATR Len / Slow Factor / Slow ATR Len: enables the majority-vote filter and configures the auxiliary fast and slow Supertrend instances used to build consensus.
[*]Lock Signal: freezes the currently plotted trade levels, preventing them from updating on a new signal.
[*]Show Trade Levels: toggles the automated Entry/SL/TP1-3 line and label plotting.
[*]SL ATR Mult: the ATR multiple used to place the stop-loss distance from entry.
[*]TP1/TP2/TP3 R:R: the risk:reward multiples used to place each take-profit level relative to the stop distance.
[*]Heatmap Candles / BULL-BEAR Labels / Show Dashboard / Position: visual display toggles and dashboard placement.
[*]Long/Short/Close Long/Close Short Action: customizable string values embedded in the JSON alert payload's "action" field, for mapping to specific webhook automation commands.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

• Volatility-Based Trend Following (Supertrend / ATR Envelopes)
The core engine descends from the broader family of volatility-adjusted trend-following bands, which use Average True Range (a measure of typical price movement magnitude popularized by J. Welles Wilder) to scale a trailing stop-and-reverse line to prevailing market volatility rather than a fixed price distance. The ratcheting band logic ensures the line never moves against the prevailing trend, which is the defining mechanical property of a trailing-stop-style trend system as opposed to a simple moving average crossover.

• Percentile Ranking for Regime Adaptation
The adaptive factor mechanism applies percentile rank normalization — expressing current ATR as its standing relative to a distribution of its own recent historical values — as a way of contextualizing volatility without relying on a fixed absolute threshold, which allows the same logic to be meaningfully applied across instruments and timeframes with very different baseline volatility levels.

• Ensemble / Majority-Vote Filtering
The Triple Consensus mechanism is a straightforward application of ensemble logic: combining multiple independent estimators (in this case, differently parameterized instances of the same underlying model) and requiring agreement among a majority before acting. This is a well-established technique for variance reduction in signal processing and forecasting contexts, on the premise that independent estimators are less likely to agree by chance during noise-driven, non-trending conditions than during genuine directional moves.

• Wilder's Directional Movement / ADX
The ADX filter is drawn directly from J. Welles Wilder's Directional Movement System, which decomposes price movement into positive and negative directional components and derives a smoothed index (ADX) representing trend strength independent of direction. ADX below common threshold levels is widely associated with range-bound, non-trending conditions in technical analysis literature.

• Recursive State Estimation (Kalman Filtering)
The optional Kalman Filter smoothing method applies a simplified single-state form of the Kalman recursive estimation framework from control theory and signal processing, in which a running estimate is continuously updated by weighting new observations against the estimate's own error covariance, producing a smoothing average that adapts its responsiveness based on recent prediction error rather than using a fixed lookback window.

• Slope-Adjusted Trend Extrapolation (LLAMA)
The LLAMA smoothing option combines a simple arithmetic mean with a linear slope term derived from the change in price over the lookback window, projecting the average forward along the recent trend direction — a lightweight application of linear extrapolation principles used to reduce the inherent lag of simple averaging methods.

• Volume as a Conviction Proxy
The volume filter reflects the broader technical-analysis principle that price movements accompanied by above-average participation carry more informational weight than those on thin volume, a concept with roots in classical volume-price analysis dating back to early technical analysis literature (e.g., Dow Theory's treatment of volume as a confirming factor).

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Triple Supertrend Confluence [MarkitTick]", overlay = true)

// ── INPUTS ──────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
var string GRP_FILT = "🕯️ Filters"
var string GRP_CONF = "🧭 Consensus"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS  = "🎨 Visuals"
var string _mt741a = "📊 Dashboard"
var string GRP_WH   = "🔔 Alerts"
var string GRP_COL  = "🌈 Colors"
i_atrPeriod       = input.int(10, "ATR Len", group = GRP_CORE, minval = 1)
i_factor          = input.float(3.0, "Factor", group = GRP_CORE, minval = 0.01, step = 0.01)
i_useAdaptFactor  = input.bool(true, "🌊 Adaptive Factor", group = GRP_CORE, tooltip = "")
i_factorMin       = input.float(1.5, "Factor Min", group = GRP_CORE, minval = 0.01, step = 0.01)
i_factorMax       = input.float(4.5, "Factor Max", group = GRP_CORE, minval = 0.01, step = 0.01)
i_factorRankLen   = input.int(100, "Factor Rank Len", group = GRP_CORE, minval = 10)
i_useAdxFilter    = input.bool(true, "📈 Use ADX Filter", group = GRP_FILT)
i_adxThresh       = input.float(20.0, "ADX Threshold", group = GRP_FILT, minval = 0, step = 0.5)
i_adxLen          = input.int(14, "ADX Length", group = GRP_FILT, minval = 1)
i_adaptFilterType = input.string("None", "🧠 Adaptive Filter", options = ["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group = GRP_FILT)
i_adaptFilterLen  = input.int(20, "Adaptive Filter Len", group = GRP_FILT, minval = 1)
i_useHtf          = input.bool(false, "🕐 Use HTF Confluence", group = GRP_FILT)
i_htfTf           = input.timeframe("240", "HTF", group = GRP_FILT)
i_useVolFilter    = input.bool(false, "📊 Use Volume Filter", group = GRP_FILT)
i_volLen          = input.int(20, "Volume Avg Len", group = GRP_FILT, minval = 1)
i_volMult         = input.float(1.2, "Volume Mult", group = GRP_FILT, minval = 0.1, step = 0.1)
i_useCooldown     = input.bool(false, "🧊 Use Cooldown Guard", group = GRP_FILT, tooltip = "")
i_cooldownBars    = input.int(10, "Cooldown Bars", group = GRP_FILT, minval = 1)
i_useConsensus    = input.bool(true, "🧭 Use Triple Consensus", group = GRP_CONF)
i_factorFast      = input.float(2.0, "Fast Factor", group = GRP_CONF, minval = 0.01, step = 0.01)
i_periodFast      = input.int(7, "Fast ATR Len", group = GRP_CONF, minval = 1)
i_factorSlow      = input.float(4.0, "Slow Factor", group = GRP_CONF, minval = 0.01, step = 0.01)
i_periodSlow      = input.int(14, "Slow ATR Len", group = GRP_CONF, minval = 1)
i_lockSignal      = input.bool(false, "🔒 Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_showLevels      = input.bool(true, "📌 Show Trade Levels", group = GRP_TRADE, tooltip = "Draw SL/Entry/TP lines and labels on new confirmed signals")
i_slAtrMult       = input.float(1.5, "SL ATR Mult", group = GRP_TRADE, minval = 0.01, step = 0.1)
i_tp1RR           = input.float(1.0, "TP1 R:R", group = GRP_TRADE, minval = 0.01, step = 0.1)
i_tp2RR           = input.float(2.0, "TP2 R:R", group = GRP_TRADE, minval = 0.01, step = 0.1)
i_tp3RR           = input.float(3.0, "TP3 R:R", group = GRP_TRADE, minval = 0.01, step = 0.1)
i_showHeatmap     = input.bool(true, "🕯️ Heatmap Candles", group = GRP_VIS)
i_showLabels      = input.bool(true, "🏷️ BULL/BEAR Labels", group = GRP_VIS)
i_showDash        = input.bool(true, "📊 Show Dashboard", group = _mt741a)
i_dashPos         = input.string("Top Right", "Position", group = _mt741a, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
i_actionLong      = input.string("long", "↑ Long Action", group = GRP_WH)
i_actionShort     = input.string("short", "↓ Short Action", group = GRP_WH)
i_actionCloseLong  = input.string("closelong", "✕ Close Long Action", group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
c_up              = input.color(color.green, "Up Color", group = GRP_COL)
c_down            = input.color(color.red, "Down Color", group = GRP_COL)
c_unconfirmed     = input.color(color.gray, "Unconfirmed Color", group = GRP_COL)
c_fillUp          = input.color(color.new(color.green, 90), "Up Fill", group = GRP_COL)
c_fillDown        = input.color(color.new(color.red, 90), "Down Fill", group = GRP_COL)
c_cooldownBg      = input.color(color.new(#787b86, 85), "Cooldown BG", group = GRP_COL)
c_heatUp          = input.color(color.new(color.green, 0), "Heatmap Up", group = GRP_COL)
c_heatDown        = input.color(color.new(color.red, 0), "Heatmap Down", group = GRP_COL)
c_bullLbl         = input.color(color.new(color.green, 0), "Bull Label", group = GRP_COL)
c_bearLbl         = input.color(color.new(color.red, 0), "Bear Label", group = GRP_COL)
C_DASH_HDR        = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL)
C_DASH_BG         = input.color(color.new(#0a0f1a, 10), "Dash BG", group = GRP_COL)
C_DASH_TXT        = input.color(color.new(#ffffff, 0), "Dash Text", group = GRP_COL)
c_slColor         = input.color(#ef5350, "SL Color", group = GRP_COL)
c_entryColor      = input.color(#2196f3, "Entry Color", group = GRP_COL)
c_tp1Color        = input.color(color.new(#26a69a, 40), "TP1 Color", group = GRP_COL)
c_tp2Color        = input.color(color.new(#26a69a, 20), "TP2 Color", group = GRP_COL)
c_tp3Color        = input.color(color.new(#26a69a, 0), "TP3 Color", group = GRP_COL)
c_riskFill        = input.color(color.new(#ef5350, 80), "Risk Fill", group = GRP_COL)
c_rewardFill      = input.color(color.new(#26a69a, 85), "Reward Fill", group = GRP_COL)

// ── CORE LOGIC ──────────────────────────────────────────────
f_sma(float src, int len) =>
    ta.sma(src, len)
f_ema(float src, int len) =>
    ta.ema(src, len)
f_rma(float src, int len) =>
    ta.rma(src, len)
f_doubleWma(float src, int len) =>
    float _w1 = ta.wma(src, len)
    float _w2 = ta.wma(_w1, len)
    _w2
f_tripleVwma(float src, int len) =>
    float _v1 = ta.vwma(src, len)
    float _v2 = ta.vwma(_v1, len)
    float _v3 = ta.vwma(_v2, len)
    _v3
f_hma(float src, int len) =>
    ta.hma(src, len)
f_llama(float src, int len) =>
    float _mean  = ta.sma(src, len)
    float _slope = (src - src[len]) / len
    _mean + _slope * (len / 2)
f_kalman(float src, int len) =>
    var float _est = na
    var float _err = 1.0
    float _q = 1.0 / len
    float _r = 1.0
    _est := na(_est) ? src : _est
    float _predErr = _err + _q
    float _gain = _predErr / (_predErr + _r)
    _est := _est + _gain * (src - _est)
    _err := (1 - _gain) * _predErr
    _est
float _mt741b = i_adaptFilterType == "SMA" ? f_sma(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "EMA" ? f_ema(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "RMA" ? f_rma(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA" ? f_doubleWma(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "HMA" ? f_hma(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA" ? f_llama(hl2, i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(hl2, i_adaptFilterLen) : hl2
[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh
float _atrRaw = ta.atr(i_atrPeriod)
float _atrPctRank = ta.percentrank(_atrRaw, i_factorRankLen)
float _adaptiveFactor = i_useAdaptFactor ? (na(_atrPctRank) ? i_factor : i_factorMin + (i_factorMax - i_factorMin) * (_atrPctRank / 100)) : i_factor
f_supertrend(float src, float factor, int atrPeriod) =>
    float _atr = ta.atr(atrPeriod)
    float _upperBand = src + factor * _atr
    float _lowerBand = src - factor * _atr
    float _prevLowerBand = nz(_lowerBand[1])
    float _prevUpperBand = nz(_upperBand[1])
    _lowerBand := _lowerBand > _prevLowerBand or close[1] < _prevLowerBand ? _lowerBand : _prevLowerBand
    _upperBand := _upperBand < _prevUpperBand or close[1] > _prevUpperBand ? _upperBand : _prevUpperBand
    int _dir = na
    float _st = na
    float _prevSt = _st[1]
    if na(_atr[1])
        _dir := 1
    else if _prevSt == _prevUpperBand
        _dir := close > _upperBand ? -1 : 1
    else
        _dir := close < _lowerBand ? 1 : -1
    _st := _dir == -1 ? _lowerBand : _upperBand
    [_st, _dir]
[supertrend, direction] = f_supertrend(_mt741b, _adaptiveFactor, i_atrPeriod)
[_stFast, _dirFast] = f_supertrend(_mt741b, i_factorFast, i_periodFast)
[_stSlow, _dirSlow] = f_supertrend(_mt741b, i_factorSlow, i_periodSlow)
int _agreeCount = (direction == _dirFast ? 1 : 0) + (direction == _dirSlow ? 1 : 0) + 1
bool _consensusPass = not i_useConsensus or _agreeCount >= 2
f_htfDirection() =>
    [_htfSt, _htfDir] = f_supertrend(hl2, i_factor, i_atrPeriod)
    _htfDir
float _htfDirRaw = request.security(syminfo.tickerid, i_htfTf, f_htfDirection()[1], lookahead = barmerge.lookahead_on)
bool _htfPass = not i_useHtf or (direction == -1 ? _htfDirRaw == -1 : _htfDirRaw == 1)
float _volSma = ta.sma(volume, i_volLen)
bool _hasVolume = not na(volume) and volume > 0
bool _volPass = not i_useVolFilter or not _hasVolume or volume >= _volSma * i_volMult
bool _flip = direction != direction[1]
var int _lastFlipBar = 0
var int _longCooldownEnd = na
var int _shortCooldownEnd = na
bool _flipConfirmed = direction[1] != direction[2]
if _flipConfirmed
    int _segLen = (bar_index - 1) - _lastFlipBar
    if _segLen <= i_cooldownBars
        if direction[2] == -1
            _longCooldownEnd := (bar_index - 1) + i_cooldownBars
        else
            _shortCooldownEnd := (bar_index - 1) + i_cooldownBars
    _lastFlipBar := bar_index - 1
bool _longCooldownActive = i_useCooldown and not na(_longCooldownEnd) and bar_index <= _longCooldownEnd
bool _shortCooldownActive = i_useCooldown and not na(_shortCooldownEnd) and bar_index <= _shortCooldownEnd
bool _cooldownPass = direction == -1 ? not _longCooldownActive : not _shortCooldownActive
bool _confirmed = _adxPass and _consensusPass and _htfPass and _volPass and _cooldownPass
bool _confirmedFlipUp = _flip and direction == -1 and _confirmed
bool _confirmedFlipDown = _flip and direction == 1 and _confirmed
float _atrForLevels = ta.atr(i_atrPeriod)
float _entryPriceLong = close
float _slPriceLong = close - _atrForLevels * i_slAtrMult
float _tp1PriceLong = close + (close - _slPriceLong) * i_tp1RR
float _tp2PriceLong = close + (close - _slPriceLong) * i_tp2RR
float _tp3PriceLong = close + (close - _slPriceLong) * i_tp3RR
float _entryPriceShort = close
float _slPriceShort = close + _atrForLevels * i_slAtrMult
float _tp1PriceShort = close - (_slPriceShort - close) * i_tp1RR
float _tp2PriceShort = close - (_slPriceShort - close) * i_tp2RR
float _tp3PriceShort = close - (_slPriceShort - close) * i_tp3RR
bool _locked = i_lockSignal and barstate.islast
var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na
var int lastSignalBar = na
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

// ── ALERTS ──────────────────────────────────────────────────
string _longInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","price":"{3}"',
 i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string _shortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","price":"{3}"',
 i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string _closeLongInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","price":"{3}"',
 i_actionCloseLong, syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string _closeShortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","price":"{3}"',
 i_actionCloseShort, syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string longPayload = "{" + _longInner + "}"
string shortPayload = "{" + _shortInner + "}"
string closeLongPayload = "{" + _closeLongInner + "}"
string closeShortPayload = "{" + _closeShortInner + "}"
if _confirmedFlipUp and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if _confirmedFlipDown and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if _confirmedFlipDown and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if _confirmedFlipUp and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
alertcondition(_confirmedFlipUp and barstate.isconfirmed, title = "Downtrend to Uptrend", message = "Supertrend switched Downtrend to Uptrend (confirmed)")
alertcondition(_confirmedFlipDown and barstate.isconfirmed, title = "Uptrend to Downtrend", message = "Supertrend switched Uptrend to Downtrend (confirmed)")
alertcondition(_confirmedFlipDown and barstate.isconfirmed, title = "Close Long Signal", message = "MarkitTick — Close Long")
alertcondition(_confirmedFlipUp and barstate.isconfirmed, title = "Close Short Signal", message = "MarkitTick — Close Short")
alertcondition((_confirmedFlipUp or _confirmedFlipDown) and barstate.isconfirmed, title = "Trend Change", message = "Supertrend confirmed trend change")

// ── VISUALS ──────────────────────────────────────────────────
color _mt741c = _confirmed ? c_up : c_unconfirmed
color _lineColorDown = _confirmed ? c_down : c_unconfirmed
upTrend = plot(direction == -1 ? supertrend : na, "Up Trend", color = _mt741c, style = plot.style_linebr)
downTrend = plot(direction == 1 ? supertrend : na, "Down Trend", color = _lineColorDown, style = plot.style_linebr)
bodyMiddle = plot((open + close) / 2, "Body Middle", display = display.none)
fill(bodyMiddle, upTrend, title = "Uptrend BG", color = direction == -1 ? c_fillUp : na, fillgaps = false)
fill(bodyMiddle, downTrend, title = "Downtrend BG", color = direction == 1 ? c_fillDown : na, fillgaps = false)
bgcolor(_longCooldownActive or _shortCooldownActive ? c_cooldownBg : na, title = "Cooldown Active")
color _heatBody = direction == -1 ? c_heatUp : c_heatDown
plotcandle(i_showHeatmap ? open : na, high, low, close,
 title       = "Heatmap Candles",
 color       = _heatBody,
 wickcolor   = _heatBody,
 bordercolor = _heatBody)
if i_showLabels and _confirmedFlipUp and barstate.isconfirmed
    label.new(bar_index, low, "BULL", style = label.style_label_up, color = c_bullLbl, textcolor = color.white, size = size.small)
if i_showLabels and _confirmedFlipDown and barstate.isconfirmed
    label.new(bar_index, high, "BEAR", style = label.style_label_down, color = c_bearLbl, textcolor = color.white, size = size.small)
if i_showLevels and _confirmedFlipUp and barstate.isconfirmed and not _locked
    f_deleteLevels()
    slLine := line.new(bar_index, _slPriceLong, bar_index, _slPriceLong, color = c_slColor, style = line.style_solid, width = 2)
    entryLine := line.new(bar_index, _entryPriceLong, bar_index, _entryPriceLong, color = c_entryColor, style = line.style_dashed, width = 1)
    tp1Line := line.new(bar_index, _tp1PriceLong, bar_index, _tp1PriceLong, color = c_tp1Color, style = line.style_dashed, width = 1)
    tp2Line := line.new(bar_index, _tp2PriceLong, bar_index, _tp2PriceLong, color = c_tp2Color, style = line.style_dashed, width = 1)
    tp3Line := line.new(bar_index, _tp3PriceLong, bar_index, _tp3PriceLong, color = c_tp3Color, style = line.style_dashed, width = 1)
    slLbl := label.new(bar_index, _slPriceLong, "✕ SL " + str.tostring(_slPriceLong, format.mintick), style = label.style_label_left, color = c_slColor, textcolor = color.white, size = size.small)
    entryLbl := label.new(bar_index, _entryPriceLong, "▶ Entry " + str.tostring(_entryPriceLong, format.mintick), style = label.style_label_left, color = c_entryColor, textcolor = color.white, size = size.small)
    tp1Lbl := label.new(bar_index, _tp1PriceLong, "◆ TP1 " + str.tostring(_tp1PriceLong, format.mintick), style = label.style_label_left, color = c_tp1Color, textcolor = color.white, size = size.small)
    tp2Lbl := label.new(bar_index, _tp2PriceLong, "✦ TP2 " + str.tostring(_tp2PriceLong, format.mintick), style = label.style_label_left, color = c_tp2Color, textcolor = color.white, size = size.small)
    tp3Lbl := label.new(bar_index, _tp3PriceLong, "◆ TP3 " + str.tostring(_tp3PriceLong, format.mintick), style = label.style_label_left, color = c_tp3Color, textcolor = color.white, size = size.small)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)
    lastSignalBar := bar_index
if i_showLevels and _confirmedFlipDown and barstate.isconfirmed and not _locked
    f_deleteLevels()
    slLine := line.new(bar_index, _slPriceShort, bar_index, _slPriceShort, color = c_slColor, style = line.style_solid, width = 2)
    entryLine := line.new(bar_index, _entryPriceShort, bar_index, _entryPriceShort, color = c_entryColor, style = line.style_dashed, width = 1)
    tp1Line := line.new(bar_index, _tp1PriceShort, bar_index, _tp1PriceShort, color = c_tp1Color, style = line.style_dashed, width = 1)
    tp2Line := line.new(bar_index, _tp2PriceShort, bar_index, _tp2PriceShort, color = c_tp2Color, style = line.style_dashed, width = 1)
    tp3Line := line.new(bar_index, _tp3PriceShort, bar_index, _tp3PriceShort, color = c_tp3Color, style = line.style_dashed, width = 1)
    slLbl := label.new(bar_index, _slPriceShort, "✕ SL " + str.tostring(_slPriceShort, format.mintick), style = label.style_label_left, color = c_slColor, textcolor = color.white, size = size.small)
    entryLbl := label.new(bar_index, _entryPriceShort, "▶ Entry " + str.tostring(_entryPriceShort, format.mintick), style = label.style_label_left, color = c_entryColor, textcolor = color.white, size = size.small)
    tp1Lbl := label.new(bar_index, _tp1PriceShort, "◆ TP1 " + str.tostring(_tp1PriceShort, format.mintick), style = label.style_label_left, color = c_tp1Color, textcolor = color.white, size = size.small)
    tp2Lbl := label.new(bar_index, _tp2PriceShort, "✦ TP2 " + str.tostring(_tp2PriceShort, format.mintick), style = label.style_label_left, color = c_tp2Color, textcolor = color.white, size = size.small)
    tp3Lbl := label.new(bar_index, _tp3PriceShort, "◆ TP3 " + str.tostring(_tp3PriceShort, format.mintick), style = label.style_label_left, color = c_tp3Color, textcolor = color.white, size = size.small)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)
    lastSignalBar := bar_index
if i_showLevels and not na(slLine) and barstate.islast
    int _extX = i_lockSignal ? bar_index + 10 : last_bar_index + 10
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    label.set_x(tp2Lbl, _extX)
    label.set_x(tp3Lbl, _extX)

// ── DASHBOARD ──────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
var table dash = table.new(i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left, 2, 10, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))
if i_showDash and barstate.islast
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)
    table.cell(dash, 0, 0, "Supertrend", text_color = C_DASH_TXT, bgcolor = C_DASH_HDR, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color = C_DASH_TXT, bgcolor = C_DASH_HDR, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 1, "  Lock", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE" : "OFF") + "  ", text_color = i_lockSignal ? c_down : C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
    color _dirCol = direction == -1 ? c_up : c_down
    table.cell(dash, 0, 2, "  Trend", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, (direction == -1 ? "UP" : "DOWN") + "  ", text_color = _dirCol, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "  Confirmed", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, (_confirmed ? "YES" : "NO") + "  ", text_color = _confirmed ? c_up : c_down, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
    float _adxPct = math.min(_adxVal / 50.0, 1.0)
    table.cell(dash, 0, 4, "  ADX", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, (i_useAdxFilter ? str.tostring(_adxVal, "#.##") + "  " + str.tostring(math.round(_adxPct * 100)) + "%" : "OFF") + "  ", text_color = i_useAdxFilter ? f_barColor(_adxPct) : C_DASH_TXT, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "  Adapt Filter", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, i_adaptFilterType + "  ", text_color = C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "  Consensus", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, (i_useConsensus ? str.tostring(_agreeCount) + "/3" : "OFF") + "  ", text_color = i_useConsensus ? (_consensusPass ? c_up : c_down) : C_DASH_TXT, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 7, "  HTF Bias", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, (i_useHtf ? (_htfDirRaw == -1 ? "UP" : "DOWN") : "OFF") + "  ", text_color = i_useHtf ? (_htfPass ? c_up : c_down) : C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 8, "  Volume", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, (i_useVolFilter ? (_volPass ? "PASS" : "FAIL") : "OFF") + "  ", text_color = i_useVolFilter ? (_volPass ? c_up : c_down) : C_DASH_TXT, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 9, "  Cooldown", text_color = color.new(C_DASH_TXT, 25), bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 9, (i_useCooldown ? (_longCooldownActive ? "LONG " + str.tostring(_longCooldownEnd - bar_index) + "b" : _shortCooldownActive ? "SHORT " + str.tostring(_shortCooldownEnd - bar_index) + "b" : "OFF") : "OFF") + "  ", text_color = (_longCooldownActive or _shortCooldownActive) ? c_down : C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
````
