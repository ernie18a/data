<!-- tradingview-pine-id: PUB;459eda910145405fb02cbfd81b16ca74 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NRTR Adaptive Trailing Reverse [MarkitTick]

Source: https://www.tradingview.com/script/txN4hMDM-NRTR-Adaptive-Trailing-Reverse-MarkitTick/

## Description

💡 An adaptive trailing-stop and reversal system built around the Nick Rypock Trailing Reverse (NRTR) algorithm, extended with a configurable smoothing engine, ADX confluence filtering, automatic risk-based trade level projection, and a live position-sizing dashboard. Rather than applying NRTR to raw closing price, this tool lets the trailing calculation run on top of one of eight selectable smoothing methods, giving traders control over how reactive or how filtered the underlying trend estimate is before the trailing stop is derived from it.

✨ Originality and Utility
The classic NRTR trailing stop is normally computed directly from price. This script decouples the "source" the trailing calculation reacts to from raw price by routing it through a selectable adaptive filter stage first — SMA, EMA, RMA, Double WMA, Triple VWMA, HMA, a custom LLAMA slope-projection filter, or a Kalman filter. This means the trailing envelope itself can be smoothed, decoupled from tick-level noise, or shaped to lag less than a conventional moving average, without changing the core NRTR ratchet-and-flip mechanic.

Beyond the trailing engine, the script closes the loop between "signal" and "trade management," which most trailing-stop tools leave to the user. Once a trend flip is confirmed, it automatically derives a stop-loss from the NRTR level itself and projects three risk-multiple take-profit targets, tracks whether each has been hit, calculates a suggested position size from a risk percentage or fixed-dollar risk model, and optionally suppresses new signals for a cooldown period after a stop-out. An ADX confluence filter can additionally require a minimum trend strength reading before a flip is treated as valid. The combination is justified because each component consumes the output of the one before it: the adaptive filter conditions the source, the NRTR logic converts that source into a trailing stop and flip signal, the ADX filter validates the flip's context, and the risk/sizing engine turns the validated flip into an actionable, fully quantified trade plan — a single coherent pipeline rather than an arbitrary bundling of unrelated indicators.

🔬 Methodology and Concepts
• The Adaptive Source Filter
Before any trailing-stop math happens, closing price is optionally passed through one of these transformations, selected from the "Adapt Filter" input:

[*]SMA / EMA / RMA — standard moving averages, included as familiar baselines.
[*]Double WMA — a Weighted Moving Average applied twice in succession (a WMA of a WMA), which produces a lower-lag response than a single WMA of the same length.
[*]Triple VWMA — a Volume Weighted Moving Average cascaded three times, folding volume-weighting into a lower-lag smoothing chain.
[*]HMA — the Hull Moving Average, using weighted-moving-average differencing to reduce lag relative to standard smoothing.
[*]LLAMA — a proprietary two-part filter that combines a simple moving average of the source with a linear slope term measured over the same lookback (the rate of change between the current source value and the value from `length` bars ago, divided by `length`). The slope is scaled by half the filter length and added to the SMA, producing a trend-projected estimate that leans ahead of a plain average in the direction of the recent slope.
[*]Kalman Filter — a lightweight recursive estimator that updates a running estimate of the "true" price using a prediction/correction cycle. It maintains an internal error estimate and a gain term derived from the ratio of process noise (set by the inverse of the filter length) to measurement noise, blending each new price observation into the estimate proportionally to that gain.
[*]None — the trailing logic operates directly on closing price.

When "None" is selected, the tool behaves as a standard price-based NRTR. Any other selection substitutes that smoothed series as the "source" for every downstream calculation.

• NRTR Trailing Calculation
The script offers two modes for sizing the trailing offset, chosen via "NRTR Mode":

[*]Percent — the offset is a fixed percentage of the (lagged) adaptive source value.
[*]ATR — the offset is a multiple of the Average True Range over a configurable lookback, scaling the trailing distance to current volatility rather than a fixed percentage.

In an uptrend, the script tracks the highest adaptive-source value reached since the last flip (the "extreme") and subtracts the offset from it to produce a trailing level that can only rise or stay flat — never fall — while the trend persists. In a downtrend, the mirror logic tracks the lowest extreme and adds the offset, producing a level that can only fall or stay flat. A trend flip occurs the moment the prior bar's adaptive source closes beyond the trailing level: closing below it in an uptrend flips the state to a downtrend (and vice versa), at which point the extreme and trailing level reset and begin tracking in the new direction. Because the ratchet only ever tightens toward price, this produces the classic NRTR "stair-step" trailing behavior rather than a smooth curve.

• Confirmation and Non-Repainting Behavior
The trend-state comparison that triggers a flip always references the previous bar's confirmed adaptive-source value, and every alert condition is additionally gated behind `barstate.isconfirmed`. This means a signal only fires once its triggering bar has fully closed — the trailing level and trend state do not repaint once a bar is confirmed, and alerts cannot fire prematurely intrabar.

• ADX Confluence Filter
When enabled, a flip is only accepted as a valid trading signal if the prior bar's ADX reading (calculated over the same configurable length for both DI and ADX smoothing) is at or above the threshold input. This is intended to suppress flips that occur while the market lacks directional strength, where trailing-stop whipsaws are most common.

• Cooldown Guard
When enabled, a stop-loss hit on one side of the market starts a bar-count cooldown during which a new signal in that same direction is suppressed, intended to reduce immediate re-entry into a level that has just failed.

• Trade Level Projection and Position Sizing
On a valid signal, the entry is taken at the current close, the stop-loss is set to the NRTR trailing level at that moment, and the initial risk distance (entry-to-stop) is multiplied by three independently configurable multiples to project TP1, TP2, and TP3. Each target and the stop are tracked bar-by-bar for whether price has traded through them, updating their on-chart labels accordingly. A suggested position size is calculated from either a percentage of a user-defined account size or a fixed dollar risk amount, divided by the entry-to-stop distance in price, giving a size that risks a consistent dollar or percentage amount regardless of current volatility.

🎨 Visual Guide

[*]NRTR Line — a grey step-line plotting the current trailing-stop level.
[*]Heatmap Candles — the chart's candles are recolored using the Bull/Bear color inputs (teal/red by default) to reflect the current trend state directly on price, rather than requiring a separate indicator pane.
[*]Cooldown Background — a shaded background tint appears while a directional cooldown is active after a stop-out, using the Cooldown BG color.
[*]Trade Level Lines and Labels (on signal) — a solid red Stop Loss line, a dashed blue Entry line, and three dashed green Take Profit lines (TP1 lightest, TP3 most opaque) extend from the signal bar. Each carries a right-aligned label showing its exact price; once a target or stop is touched, its label updates in place to show the hit and the resulting percentage gain or loss from entry.
[*]Risk/Reward Shading — a light red fill shades the zone between Entry and Stop Loss (the risk side), and a light green fill shades the zone between Entry and TP3 (the full reward side), giving an immediate visual sense of the trade's risk-to-reward geometry.
[*]Dashboard Table — a corner-anchored panel (position configurable) summarizing, in real time: current trend direction, Lock status, the live NRTR level, active entry/stop/TP1 prices, the current ADX reading (colored by pass/fail against the threshold), the active adaptive filter, cooldown status and remaining bars, the calculated risk amount, the suggested position size, and a filled bar-graph showing how close price currently sits to the trailing stop as a percentage of the total offset distance.

📖 How to Use

[*]A flip from red to teal candles (and the NRTR line stepping below price) signals a potential long entry; the mirror flip signals a potential short.
[*]Use the auto-drawn Entry, Stop Loss, and Take Profit lines as a starting risk/reward framework — the SL is anchored to the trailing level at the moment of the flip, not an arbitrary distance.
[*]Enable the ADX Filter if you want flips confirmed only during periods of measurable trend strength, which reduces (but does not eliminate) signals generated in choppy, low-ADX conditions.
[*]Enable Cooldown Guard if you want to avoid immediate re-entry into a direction that was just stopped out — useful in ranging conditions prone to repeated whipsaws.
[*]Enable Lock Signal to freeze the currently displayed trade levels in place (rather than having them update to the latest signal), useful for reviewing a specific historical setup without it being overwritten by newer signals.
[*]Watch the "Dist Trail" bar in the dashboard as a quick visual read of how far price currently sits from the trailing stop relative to the configured offset — a nearly full bar means price is close to triggering a flip.
[*]The built-in alert payloads are formatted as JSON and include action, ticker, timeframe, direction, entry, stop, and target fields, making them usable directly as webhook bodies for external automation without additional parsing.

⚙️ Inputs and Settings

[*]NRTR Mode — switches the trailing offset calculation between a fixed Percent of price and a volatility-adaptive ATR multiple.
[*]NRTR % / ATR Len / ATR Mult — control the magnitude of the trailing offset in each respective mode; larger values produce a looser trail with fewer, later flips, smaller values produce a tighter trail with more frequent flips.
[*]Use ADX Filter / ADX Len / ADX Thresh — toggle and configure the trend-strength confluence filter described above.
[*]Adapt Filter / Adapt Len — select the smoothing method applied to price before the NRTR calculation, and its lookback length.
[*]Cooldown Guard / Cooldown Bars — toggle and configure the post-stop-out re-entry suppression window.
[*]Lock Signal — freezes the currently plotted trade levels rather than letting them advance to the newest signal.
[*]Position Sizing / Sizing Mode / Risk % Trade / Fixed Risk $ / Account $ — configure whether suggested size is derived from a percentage of account equity or a fixed dollar risk figure, and the inputs feeding that calculation.
[*]TP1/TP2/TP3 Mult — the risk multiples applied to the entry-to-stop distance to project each take-profit level.
[*]Heatmap Candles / NRTR Line / Trade Levels — independently toggle each visual layer on or off.
[*]Dash Pos / Show Dash — position and visibility of the dashboard table.
[*]Alert Action fields (Long/Short/Close Long/Close Short) — customize the "action" string embedded in each webhook JSON payload, useful for matching the field names expected by a specific external automation system.
[*]Color inputs — independently customize every plotted and dashboard color.

🔍 Deconstruction of the Underlying Scientific and Academic Framework
The NRTR mechanic itself belongs to a family of stop-and-reverse trailing systems related conceptually to Wilder's Parabolic SAR and to chandelier-style trailing stops: all three share the property that the trailing level is a one-directional ratchet — it can only move in the direction that tightens toward price — which is what mechanically prevents the trailing stop from ever "giving back" more than the configured offset once a trend is underway. Where NRTR differs is in decoupling the ratchet from a fixed acceleration curve (as in Parabolic SAR) and instead deriving it directly from a percentage or volatility-scaled offset off a tracked local extreme, which is closer in spirit to a Donchian- or Chandelier-style trailing construction.

The ATR-based offset mode draws on Welles Wilder's concept of using recent true-range volatility, rather than a fixed percentage, to size a trailing distance — the rationale being that a constant percentage offset is too tight in high-volatility regimes (generating premature stop-outs) and too loose in low-volatility regimes (giving back excess profit), while an ATR-scaled offset expands and contracts with the instrument's own recent behavior.

The Double WMA and Triple VWMA filters are cascaded-smoothing constructions in the same family as Hull's differencing approach: repeatedly passing a series through a weighted average and recombining the outputs is a general technique for pushing a smoothing filter's group delay down without simply shortening its lookback (which would otherwise increase noise sensitivity). The Kalman filter option applies a simplified, single-state version of the classic recursive Bayesian estimator from control theory, where each new observation is blended into a running estimate according to a gain term balancing assumed process noise against assumed measurement noise — conceptually the same estimation framework used in tracking and signal-processing applications outside of finance. The custom LLAMA filter combines a central-tendency estimate (a simple moving average) with a first-order trend term (a discrete slope measured over the same window), an approach related in principle to linear trend-projection and regression-based smoothing techniques that attempt to reduce lag by explicitly modeling the direction a series is moving rather than only its recent average level.

The ADX component derives from Wilder's Directional Movement System, in which ADX quantifies the strength (not direction) of a trend by smoothing the divergence between positive and negative directional movement — using it as a confluence filter reflects the broader technical-analysis principle that trend-following and trailing-stop methods perform better in the specific market regime (trending, directional) they are designed for, and using a strength filter is one common approach to distinguishing that regime from a ranging one.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("NRTR Adaptive Trailing Reverse [MarkitTick]", overlay=true, max_lines_count=50, max_labels_count=50, max_bars_back=500)
// ── INPUTS ─────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
var string GRP_FILT = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade"
var string GRP_VIS = "🎨 Vis"
var string GRP_DASH = "📊 Dash"
var string GRP_WH = "🔔 Alerts"
var string GRP_COL = "🌈 Colors"
i_mode = input.string("ATR", "NRTR Mode", options=["Percent", "ATR"], group=GRP_CORE)
i_pct = input.float(2.0, "NRTR %", group=GRP_CORE, minval=0.01, step=0.1)
i_atrLen = input.int(14, "ATR Len", group=GRP_CORE, minval=1)
i_atrMult = input.float(2.5, "ATR Mult", group=GRP_CORE, minval=0.1, step=0.1)
i_useAdxFilter = input.bool(false, "📈 Use ADX Filter", group=GRP_FILT)
i_adxLen = input.int(14, "ADX Len", group=GRP_FILT, minval=1)
i_adxThresh = input.float(20.0, "ADX Thresh", group=GRP_FILT, minval=0, step=0.5)
i_adaptFilterType = input.string("None", "🧠 Adapt Filter", options=["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group=GRP_FILT)
i_adaptFilterLen = input.int(20, "Adapt Len", group=GRP_FILT, minval=1)
i_useCooldown = input.bool(false, "🧊 Cooldown Guard", group=GRP_FILT, tooltip="")
i_cooldownBars = input.int(10, "Cooldown Bars", group=GRP_FILT, minval=1)
i_lockSignal = input.bool(false, "🔒 Lock Signal", group=GRP_TRADE, tooltip="")
i_useSizing = input.bool(false, "🧮 Position Sizing", group=GRP_TRADE, tooltip="")
i_sizingMode = input.string("Risk %", "Sizing Mode", group=GRP_TRADE, options=["Risk %", "Fixed $"])
i_riskPct = input.float(1.0, "Risk % Trade", group=GRP_TRADE, minval=0.01, step=0.1)
i_riskFixed = input.float(100.0, "Fixed Risk $", group=GRP_TRADE, minval=0)
i_tpMult1 = input.float(1.5, "TP1 Mult", group=GRP_TRADE, minval=0.1, step=0.1)
i_tpMult2 = input.float(2.5, "TP2 Mult", group=GRP_TRADE, minval=0.1, step=0.1)
i_tpMult3 = input.float(4.0, "TP3 Mult", group=GRP_TRADE, minval=0.1, step=0.1)
i_accountSize = input.float(10000.0, "Account $", group=GRP_TRADE, minval=0)
i_showCandles = input.bool(true, "Heatmap Candles", group=GRP_VIS)
i_showNrtrLine = input.bool(true, "NRTR Line", group=GRP_VIS)
i_showLevels = input.bool(true, "Trade Levels", group=GRP_VIS)
i_dashPos = input.string("Top Right", "Dash Pos", group=GRP_DASH, options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
i_showDash = input.bool(true, "Show Dash", group=GRP_DASH)
i_actionLong = input.string("long", "↑ Long Action", group=GRP_WH)
i_actionShort = input.string("short", "↓ Short Action", group=GRP_WH)
i_actionCloseLong = input.string("closelong", "✕ Close Long", group=GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short", group=GRP_WH)
c_bull = input.color(#26a69a, "Bull", group=GRP_COL)
c_bear = input.color(#ef5350, "Bear", group=GRP_COL)
c_nrtrLine = input.color(#787b86, "NRTR Ln", group=GRP_COL)
c_slColor = input.color(#ef5350, "SL", group=GRP_COL)
c_entryColor = input.color(#2196f3, "Entry", group=GRP_COL)
c_tpColor = input.color(#26a69a, "TP", group=GRP_COL)
c_lblTxt = input.color(#ffffff, "Lbl Txt", group=GRP_COL)
c_cooldownBg = input.color(color.new(#787b86, 85), "Cooldown BG", group=GRP_COL)
C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dash Hdr", group=GRP_COL)
C_DASH_BG = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COL)
C_DASH_TXT = input.color(#ffffff, "Dash Txt", group=GRP_COL)
C_SUP = input.color(#26a69a, "Bull Txt", group=GRP_COL)
C_RES = input.color(#ef5350, "Bear Txt", group=GRP_COL)
// ── CORE LOGIC ─────────────────────────────────────────────────
f_sma(float src, int len) =>
    ta.sma(src, len)
f_ema(float src, int len) =>
    ta.ema(src, len)
f_rma(float src, int len) =>
    ta.rma(src, len)
f_doubleWma(float src, int len) =>
    float _wma1 = ta.wma(src, len)
    float _wma2 = ta.wma(_wma1, len)
    _wma2
f_tripleVwma(float src, int len) =>
    float _vwma1 = ta.vwma(src, len)
    float _vwma2 = ta.vwma(_vwma1, len)
    float _vwma3 = ta.vwma(_vwma2, len)
    _vwma3
f_hma(float src, int len) =>
    ta.hma(src, len)
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
f_llama(float src, int len) =>
    float _mean = ta.sma(src, len)
    float _slope = (src - src[len]) / len
    _mean + _slope * (len / 2)
float _adaptedSrc = i_adaptFilterType == "SMA" ? f_sma(close, i_adaptFilterLen) :
 i_adaptFilterType == "EMA" ? f_ema(close, i_adaptFilterLen) :
 i_adaptFilterType == "RMA" ? f_rma(close, i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA" ? f_doubleWma(close, i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(close, i_adaptFilterLen) :
 i_adaptFilterType == "HMA" ? f_hma(close, i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA" ? f_llama(close, i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(close, i_adaptFilterLen) : close
float _atrVal = ta.atr(i_atrLen)
float _kFactor = i_mode == "Percent" ? _adaptedSrc[1] * (i_pct / 100) : _atrVal[1] * i_atrMult
var int _trend = 1
var float _nrtr = na
var float _extreme = na
if bar_index == 0
    _extreme := _adaptedSrc
    _nrtr := _adaptedSrc - _kFactor
else
    if _trend == 1
        _extreme := math.max(nz(_extreme[1]), _adaptedSrc[1])
        float _candidate = _extreme - _kFactor
        _nrtr := _candidate > nz(_nrtr[1]) ? _candidate : nz(_nrtr[1])
        if _adaptedSrc[1] < _nrtr
            _trend := -1
            _extreme := _adaptedSrc[1]
            _nrtr := _extreme + _kFactor
    else
        _extreme := math.min(nz(_extreme[1]), _adaptedSrc[1])
        float _candidate = _extreme + _kFactor
        _nrtr := _candidate < nz(_nrtr[1]) ? _candidate : nz(_nrtr[1])
        if _adaptedSrc[1] > _nrtr
            _trend := 1
            _extreme := _adaptedSrc[1]
            _nrtr := _extreme - _kFactor
[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal[1] >= i_adxThresh
bool _rawLongSignal = _trend == 1 and _trend[1] == -1
bool _rawShortSignal = _trend == -1 and _trend[1] == 1
float slPriceLong = na
float slPriceShort = na
float entryPriceLong = na
float entryPriceShort = na
if _rawLongSignal
    entryPriceLong := close[1]
    slPriceLong := _nrtr
if _rawShortSignal
    entryPriceShort := close[1]
    slPriceShort := _nrtr
bool _slHitLong = not na(slPriceLong) and low <= slPriceLong
bool _slHitShort = not na(slPriceShort) and high >= slPriceShort
var int _longCooldownEnd = na
var int _shortCooldownEnd = na
if _slHitLong
    _longCooldownEnd := bar_index + i_cooldownBars
if _slHitShort
    _shortCooldownEnd := bar_index + i_cooldownBars
bool _longCooldownActive = i_useCooldown and not na(_longCooldownEnd) and bar_index <= _longCooldownEnd
bool _shortCooldownActive = i_useCooldown and not na(_shortCooldownEnd) and bar_index <= _shortCooldownEnd
bool longSignal = _rawLongSignal and _adxPass and not _longCooldownActive
bool shortSignal = _rawShortSignal and _adxPass and not _shortCooldownActive
bool _locked = i_lockSignal and barstate.islast
var float slLong = na
var float slShort = na
var float entryLong = na
var float entryShort = na
var float tp1Long = na
var float tp2Long = na
var float tp3Long = na
var float tp1Short = na
var float tp2Short = na
var float tp3Short = na
var int lastSignalBar = na
if longSignal and not _locked
    entryLong := close
    slLong := _nrtr
    float _risk = math.abs(entryLong - slLong)
    tp1Long := entryLong + _risk * i_tpMult1
    tp2Long := entryLong + _risk * i_tpMult2
    tp3Long := entryLong + _risk * i_tpMult3
    entryShort := na
    slShort := na
    tp1Short := na
    tp2Short := na
    tp3Short := na
    lastSignalBar := bar_index
if shortSignal and not _locked
    entryShort := close
    slShort := _nrtr
    float _risk = math.abs(slShort - entryShort)
    tp1Short := entryShort - _risk * i_tpMult1
    tp2Short := entryShort - _risk * i_tpMult2
    tp3Short := entryShort - _risk * i_tpMult3
    entryLong := na
    slLong := na
    tp1Long := na
    tp2Long := na
    tp3Long := na
    lastSignalBar := bar_index
bool tp1Hit = (not na(tp1Long) and high >= tp1Long) or (not na(tp1Short) and low <= tp1Short)
bool tp2Hit = (not na(tp2Long) and high >= tp2Long) or (not na(tp2Short) and low <= tp2Short)
bool tp3Hit = (not na(tp3Long) and high >= tp3Long) or (not na(tp3Short) and low <= tp3Short)
float _riskAmount = i_sizingMode == "Risk %" ? i_accountSize * (i_riskPct / 100) : i_riskFixed
float _slDistanceLong = not na(entryLong) and not na(slLong) ? math.abs(entryLong - slLong) : na
float _slDistanceShort = not na(entryShort) and not na(slShort) ? math.abs(slShort - entryShort) : na
float _posSizeLong = _slDistanceLong > 0 ? _riskAmount / _slDistanceLong : na
float _posSizeShort = _slDistanceShort > 0 ? _riskAmount / _slDistanceShort : na
var string _activeSizeDir = na
var float _activeSize = na
if longSignal and not _locked
    _activeSizeDir := "long"
    _activeSize := _posSizeLong
if shortSignal and not _locked
    _activeSizeDir := "short"
    _activeSize := _posSizeShort
bool _positionClosed = (_activeSizeDir == "long" and (_slHitLong or tp3Hit)) or (_activeSizeDir == "short" and (_slHitShort or tp3Hit))
if _positionClosed
    _activeSizeDir := na
    _activeSize := na
color bodyColor = _trend == 1 ? c_bull : c_bear
color borderColor = _trend == 1 ? c_bull : c_bear
// ── ALERTS ─────────────────────────────────────────────────────
string _longInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}"', i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick), str.tostring(slLong, format.mintick), str.tostring(tp1Long, format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}"', i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick), str.tostring(slShort, format.mintick), str.tostring(tp1Short, format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _closeLongInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"
string _closeShortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"
string _tp1Inner = str.format('"action":"tp1hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"tp2hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"tp3hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(close, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if tp1Hit and barstate.isconfirmed
    alert(tp1Payload, alert.freq_once_per_bar_close)
if tp2Hit and barstate.isconfirmed
    alert(tp2Payload, alert.freq_once_per_bar_close)
if tp3Hit and barstate.isconfirmed
    alert(tp3Payload, alert.freq_once_per_bar_close)
alertcondition(longSignal and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
alertcondition(tp1Hit and barstate.isconfirmed, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2Hit and barstate.isconfirmed, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3Hit and barstate.isconfirmed, "TP3 Hit", "MarkitTick — TP3 Hit")
// ── VISUALS ────────────────────────────────────────────────────
plot(i_showNrtrLine ? _nrtr : na, "NRTR", color=c_nrtrLine, linewidth=2)
bgcolor(_longCooldownActive or _shortCooldownActive ? c_cooldownBg : na, title="Cooldown Active")
plotcandle(i_showCandles ? open : na, i_showCandles ? high : na, i_showCandles ? low : na, i_showCandles ? close : na, title="Heatmap Candles", color=bodyColor, wickcolor=borderColor, bordercolor=borderColor, force_overlay=true)
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
if i_showLevels and (longSignal or shortSignal) and not _locked
    f_deleteLevels()
    float _sl = longSignal ? slLong : slShort
    float _entry = longSignal ? entryLong : entryShort
    float _tp1 = longSignal ? tp1Long : tp1Short
    float _tp2 = longSignal ? tp2Long : tp2Short
    float _tp3 = longSignal ? tp3Long : tp3Short
    slLine := line.new(bar_index, _sl, bar_index + 10, _sl, color=c_slColor, style=line.style_solid, width=2)
    entryLine := line.new(bar_index, _entry, bar_index + 10, _entry, color=c_entryColor, style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, _tp1, bar_index + 10, _tp1, color=color.new(c_tpColor, 40), style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, _tp2, bar_index + 10, _tp2, color=color.new(c_tpColor, 20), style=line.style_dashed, width=1)
    tp3Line := line.new(bar_index, _tp3, bar_index + 10, _tp3, color=color.new(c_tpColor, 0), style=line.style_dashed, width=1)
    slLbl := label.new(bar_index + 10, _sl, "✕ SL " + str.tostring(_sl, format.mintick), style=label.style_label_left, color=c_slColor, textcolor=c_lblTxt, size=size.small)
    entryLbl := label.new(bar_index + 10, _entry, "▶ Entry " + str.tostring(_entry, format.mintick), style=label.style_label_left, color=c_entryColor, textcolor=c_lblTxt, size=size.small)
    tp1Lbl := label.new(bar_index + 10, _tp1, "◆ TP1 " + str.tostring(_tp1, format.mintick), style=label.style_label_left, color=c_tpColor, textcolor=c_lblTxt, size=size.small)
    tp2Lbl := label.new(bar_index + 10, _tp2, "✦ TP2 " + str.tostring(_tp2, format.mintick), style=label.style_label_left, color=c_tpColor, textcolor=c_lblTxt, size=size.small)
    tp3Lbl := label.new(bar_index + 10, _tp3, "◆ TP3 " + str.tostring(_tp3, format.mintick), style=label.style_label_left, color=c_tpColor, textcolor=c_lblTxt, size=size.small)
    riskFill := linefill.new(slLine, entryLine, color.new(c_slColor, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(c_tpColor, 85))
if not na(slLine) and (i_lockSignal or barstate.islast)
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
f_pct(_from, _to, _isLong) =>
    _isLong ? (_to - _from) / _from * 100 : (_from - _to) / _from * 100
if tp1Hit and not na(tp1Lbl)
    bool _isLong = not na(entryLong)
    float _hitPrice = _isLong ? tp1Long : tp1Short
    float _entryPrice = _isLong ? entryLong : entryShort
    float _tp1Pct = f_pct(_entryPrice, _hitPrice, _isLong)
    label.set_text(tp1Lbl, "◆ TP1 ✓ HIT " + (_tp1Pct >= 0 ? "+" : "") + str.tostring(_tp1Pct, "#.##") + "%")
if tp2Hit and not na(tp2Lbl)
    bool _isLong = not na(entryLong)
    float _hitPrice = _isLong ? tp2Long : tp2Short
    float _entryPrice = _isLong ? entryLong : entryShort
    float _tp2Pct = f_pct(_entryPrice, _hitPrice, _isLong)
    label.set_text(tp2Lbl, "✦ TP2 ✓ HIT " + (_tp2Pct >= 0 ? "+" : "") + str.tostring(_tp2Pct, "#.##") + "%")
if tp3Hit and not na(tp3Lbl)
    bool _isLong = not na(entryLong)
    float _hitPrice = _isLong ? tp3Long : tp3Short
    float _entryPrice = _isLong ? entryLong : entryShort
    float _tp3Pct = f_pct(_entryPrice, _hitPrice, _isLong)
    label.set_text(tp3Lbl, "◆ TP3 ✓ HIT " + (_tp3Pct >= 0 ? "+" : "") + str.tostring(_tp3Pct, "#.##") + "%")
if (_slHitLong or _slHitShort) and not na(slLbl)
    bool _isLong = not na(entryLong)
    float _entryPrice = _isLong ? entryLong : entryShort
    float _slPrice = _isLong ? slLong : slShort
    float _slPct = f_pct(_entryPrice, _slPrice, _isLong)
    label.set_text(slLbl, "✕ SL ✓ HIT " + str.tostring(_slPct, "#.##") + "%")
// ── DASHBOARD ──────────────────────────────────────────────────
f_bar(float val, float maxVal, color clr) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
string _dashPosResolved = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(_dashPosResolved, 2, 13, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
if i_showDash
    table.cell(dash, 0, 0, "NRTR", text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 1, "  Lock", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE  " : "OFF  "), text_color=(i_lockSignal ? C_RES : C_DASH_TXT), bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 2, "  Trend", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, (_trend == 1 ? "▲ Bull  " : "▼ Bear  "), text_color=(_trend == 1 ? C_SUP : C_RES), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 3, "  NRTR Lvl", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(_nrtr, format.mintick) + "  ", text_color=C_DASH_TXT, bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 4, "  Entry", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, (not na(entryLong) ? str.tostring(entryLong, format.mintick) : not na(entryShort) ? str.tostring(entryShort, format.mintick) : "—") + "  ", text_color=C_DASH_TXT, bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 5, "  SL", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 5, (not na(slLong) ? str.tostring(slLong, format.mintick) : not na(slShort) ? str.tostring(slShort, format.mintick) : "—") + "  ", text_color=C_RES, bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 6, "  TP1", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, (not na(tp1Long) ? str.tostring(tp1Long, format.mintick) : not na(tp1Short) ? str.tostring(tp1Short, format.mintick) : "—") + "  ", text_color=C_SUP, bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 7, "  ADX", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(_adxVal, "#.##") + "  ", text_color=(_adxPass ? C_SUP : C_RES), bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 8, "  Adapt Filter", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 8, i_adaptFilterType + "  ", text_color=C_DASH_TXT, bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 9, "  Cooldown", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 9, (_longCooldownActive ? "LONG " + str.tostring(_longCooldownEnd - bar_index) + "b" : _shortCooldownActive ? "SHORT " + str.tostring(_shortCooldownEnd - bar_index) + "b" : "OFF") + "  ", text_color=(_longCooldownActive or _shortCooldownActive ? C_RES : C_DASH_TXT), bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 10, "  Risk Amt", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(_riskAmount, "#.##") + "  ", text_color=C_DASH_TXT, bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 11, "  Sugg Size", text_color=color.new(C_DASH_TXT, 25), bgcolor=C_DASH_BG, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 11, (not na(_activeSize) ? str.tostring(_activeSize, "#.####") : "—") + "  ", text_color=C_DASH_TXT, bgcolor=C_DASH_BG, text_halign=text.align_right, text_size=size.small)
    float _distPct = math.min(math.abs(_adaptedSrc - _nrtr) / _adaptedSrc * 100 / (i_mode == "Percent" ? i_pct : (_atrVal * i_atrMult / _adaptedSrc * 100)), 1.0)
    table.cell(dash, 0, 12, "  Dist Trail", text_color=color.new(C_DASH_TXT, 25), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 12, f_bar(_distPct, 1.0, f_barColor(_distPct)) + "  ", text_color=f_barColor(_distPct), bgcolor=color.new(C_DASH_BG, 40), text_halign=text.align_right, text_size=size.small)
````
