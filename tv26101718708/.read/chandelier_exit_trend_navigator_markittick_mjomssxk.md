# Chandelier Exit Trend Navigator [MarkitTick]

- url: https://www.tradingview.com/script/mjOmsSXk-Chandelier-Exit-Trend-Navigator-MarkitTick/
- type: indicator
- pine_id: PUB;d2a75700bd1d4ad882fe109ba89d0b7f
- version: 2.0

## Description

💡 A trend-following overlay that tracks directional shifts using a volatility-adaptive channel (Chandelier Exit methodology) and converts each flip into a fully structured trade plan — entry, stop-loss, and three R-multiple take-profit levels — displayed directly on the chart alongside a live status dashboard.

[b]✨ Originality and Utility[/b]
While the Chandelier Exit concept itself (anchoring a trailing stop to the highest high or lowest low over a lookback, offset by a multiple of ATR) is a well-documented volatility-stop technique, this script extends that foundation into a complete navigation system rather than a simple trailing line.

Three layers separate this tool from a stock Chandelier Exit plot:

[list]
[*]An optional adaptive pre-filter (Kalman Filter or a slope-adjusted moving average referred to here as LLAMA) that can be applied to the source series before the channel extremes are calculated, allowing the trend anchor itself to react differently to noise depending on which filter is selected.
[*]A full trade-management layer built on top of the directional flip: automatic stop-loss placement, three independently configurable take-profit levels defined in R-multiples, and live linefill zones that visually separate risk from reward.
[*]A condition-stacking filter system (higher-timeframe EMA bias and ADX strength) that must all align before a directional flip is treated as an actionable signal, reducing signals generated during weak or conflicting conditions.
[/list]

The combination is not an arbitrary mashup — the adaptive filter conditions the input to the channel calculation, the HTF/ADX filters condition which flips are considered valid, and the trade-management layer converts a validated flip into a concrete, risk-defined plan. Each component feeds the next in a single directional pipeline.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/IayySYvR/[/image]
[b]● Chandelier Exit Core[/b]
The core channel is built from Average True Range (ATR), calculated over a user-defined lookback. Two boundaries are computed each bar:
[list]
[*]A long-side stop, set below the highest value of the source over the lookback period, offset by a multiple of ATR.
[*]A short-side stop, set above the lowest value of the source over the same lookback, offset by the same ATR multiple.
[/list]
Users can choose whether the highest/lowest calculation uses close-based extremes or true high/low wicks, which changes how sensitive the channel is to intrabar spikes.

A persistent trailing line then locks in the tighter of the two boundaries as price develops: while the current directional state is bullish, the line only ratchets upward (never loosening on a pullback); while bearish, it only ratchets downward. A directional flip occurs when price closes beyond the opposite boundary from the prior bar, at which point the trailing line resets to anchor the new trend.

[b]● Adaptive Source Filtering[/b]
Before the channel extremes are calculated, the source price can optionally be passed through one of two smoothing methods:
[list]
[*]Kalman Filter — a recursive estimator that updates its estimate of the "true" price each bar based on a prediction-error and gain calculation, converging faster in stable conditions and adapting more cautiously during volatile ones.
[*]LLAMA — a linear-regression-style approach that takes a simple moving average of the source and adjusts it by the recent slope (rate of change) over the same lookback, projecting the average forward in the direction the price has been drifting.
[/list]
When neither is selected, the raw close is used directly, preserving the traditional Chandelier Exit behavior.

[b]● Confirmation Filters[/b]
Two independent filters can be layered on top of the raw directional flip before it is treated as a signal:
[list]
[*]A higher-timeframe EMA bias filter, which only allows long signals when price is trading above an EMA calculated on a higher timeframe, and only allows short signals when price is trading below it.
[*]An ADX-based strength filter, which requires the Average Directional Index to be at or above a user-defined threshold before any signal — long or short — is permitted, filtering out flips that occur during weak, non-trending conditions.
[/list]
Both filters default to off and can be combined or used independently.

[b]● Trade Level Construction[/b]
When a filtered directional flip is confirmed on a closed bar, the script anchors a trade plan to the prior bar's close:
[list]
[*]Risk per trade is defined as the prior bar's ATR multiplied by a user-set stop-loss multiplier.
[*]The stop-loss is placed one risk-unit away from the entry, in the direction opposite the trade.
[*]Three take-profit levels are placed at independently configurable R-multiples of that same risk distance (default 1R, 2R, and 3R), each extending in the direction of the trade.
[/list]
This means every signal comes with a symmetric, volatility-scaled risk framework rather than a fixed point value, so trade levels automatically widen or tighten with current market volatility.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/WzsTb6SP/[/image]
[list]
[*]Heatmap Candles — the chart's candle bodies and wicks are recolored to match the current directional state: teal/green while the trailing system is bullish, red while bearish, and gray when direction is undetermined (e.g. on the very first bar).
[*]Entry Line (blue, dashed) — marks the anchor price of the most recent confirmed trade signal.
[*]Stop-Loss Line (red, solid, thicker) — marks the calculated stop price for the active signal, labeled "✕ SL" with its price value.
[*]Take-Profit Lines (green, dashed, three separate levels) — TP1, TP2, and TP3, each drawn with progressively fuller opacity so TP3 is the most visually solid, labeled "◆ TP1", "✦ TP2", and "◆ TP3" respectively with their price values.
[*]Risk Zone Fill — a light red shaded region between the stop-loss and entry lines, visually sizing the risk portion of the trade.
[*]Reward Zone Fill — a light teal shaded region between the entry and TP3 lines, visually sizing the potential reward portion of the trade.
[*]Dashboard Table — a repositionable panel (default top-right) summarizing, in real time: Lock status, current Trend direction, HTF Bias reading, the numeric CE trailing-stop level, current ATR value, and the active Entry/SL prices. When enabled, it also displays the current ADX reading and which adaptive filter (if any) is active. A visual bar-and-percentage gauge shows the reward-to-risk ratio of the current trade relative to TP3, colored red/yellow/green depending on how favorable it is.
[*]📌 Note : the best way to resolve visual overlap is to navigate to the Object Tree and drag the indicator above the main chart layer, or simply hide the native candles in your chart settings.
[/list]

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/FPgzB8GR/[/image]
[list]
[*]A directional flip in the heatmap candle color, together with a new Entry/SL/TP level set appearing on the chart, indicates a fresh signal in that direction.
[*]The Stop-Loss line represents the level at which the trade thesis is considered invalidated under this system's logic.
[*]TP1, TP2, and TP3 represent successive profit-taking references at increasing R-multiples; price reaching a level does not close or resize the plotted level automatically — it is a visual reference for scaling decisions.
[*]The Risk and Reward zone fills give an immediate visual sense of the trade's risk framing without needing to read exact price values.
[*]The Dashboard's R:R (TP3) gauge offers a quick read on how the reward potential compares to the initial risk for the most recent signal.
[*]The Lock Signal input, when enabled, freezes the currently plotted levels in place and suppresses new signal generation — useful for reviewing a specific setup without the chart updating further trade plans in real time.
[*]When the HTF or ADX filters are enabled but conditions aren't met, no new signal will fire even if the raw directional flip occurs — check the Dashboard's HTF Bias and ADX rows to understand why a flip may not have produced a signal.
[/list]

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/FLfK7TJ3/[/image]
[list]
[*]ATR Len / ATR Mult — controls the lookback and volatility multiplier used to build the Chandelier channel; a longer length and/or larger multiplier produces a wider, slower-reacting trailing stop.
[*]Use Close Extremes — toggles between close-based and high/low-based channel construction, changing sensitivity to intrabar wicks.
[*]HTF Trend Filter / HTF TF / HTF EMA Len — enables and configures the higher-timeframe EMA bias filter that gates which direction of signal is permitted.
[*]Use ADX Filter / ADX Threshold / ADX Length — enables and configures the trend-strength filter that must be satisfied for any signal to fire.
[*]Adaptive Filter / Adaptive Filter Length — selects an optional smoothing method (Kalman Filter or LLAMA) applied to the source before channel calculation, and its lookback length.
[*]Lock Signal — freezes the currently displayed trade levels and halts new signal generation.
[*]SL ATR Mult — sets how many ATR units define one unit of risk for stop-loss placement.
[*]TP1 R / TP2 R / TP3 R — sets the R-multiple distance for each take-profit level relative to the calculated risk.
[*]Heatmap Candles / Show Trade Levels — toggle the directional candle coloring and the entry/SL/TP drawing layer independently.
[*]Dash Pos — repositions the dashboard to any chart corner.
[*]Color inputs — customize the bullish/bearish colors, stop-loss, entry, and take-profit line colors, and the dashboard's background, header, and text colors.
[*]Alert action fields (Long/Short/Close Long/Close Short) — customize the text string sent in the "action" field of the JSON alert payload, useful for routing signals to automated systems expecting specific action keywords.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The trailing-stop core of this script belongs to a family of volatility-adjusted stop techniques that use Average True Range as a normalization factor for price movement, an approach popularized in trend-following and volatility-breakout literature as a way to size stops relative to an instrument's current, rather than fixed, volatility regime. Anchoring the stop to a rolling extreme (highest high or lowest low) rather than a fixed percentage or point distance reflects the broader class of "channel breakout" trend systems, in which a directional bias persists until price violates a level defined by recent extremes — a structure with roots in classical trend-following systems that predate modern indicator platforms.

The optional Kalman Filter smoothing draws on recursive Bayesian estimation theory, originally developed for tracking dynamic systems under measurement uncertainty. Applied to price, it treats each new close as a noisy observation of an underlying "true" value, blending the prior estimate with the new observation according to a gain term that adjusts based on estimated error — a formulation with parallels to adaptive filtering approaches used in signal processing and, more recently, in quantitative finance research on noise-reduction for price series.

The LLAMA-labeled alternative combines a simple moving average with a linear slope projection, conceptually related to local linear regression and momentum-adjusted smoothing techniques, where a lagging average is advanced along the estimated trend direction to partially compensate for the inherent lag of moving-average-based estimators.

The ADX-based strength filter draws on Welles Wilder's Directional Movement framework, which quantifies trend strength independently of trend direction; requiring a minimum ADX reading before accepting a signal reflects a common risk-management heuristic in trend-following systems — that directional signals generated during low ADX (ranging/choppy) conditions have historically shown less reliability than those generated during elevated trend strength, though this relationship is probabilistic rather than deterministic and varies across instruments and regimes.

The take-profit structure, expressed in R-multiples of the initial risk rather than fixed price or percentage targets, reflects standard position-sizing and risk-management theory in which trade outcomes are measured relative to the capital placed at risk, allowing performance to be evaluated on a risk-normalized basis rather than in absolute price terms.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Chandelier Exit Trend Navigator [MarkitTick]", overlay=true, max_lines_count=50, max_labels_count=50)
// ── INPUTS ──────────────────────────────────────────────────
var string GRP_CORE  = "⚙️ Core"
var string GRP_FILT  = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS   = "🎨 Visuals"
var string GRP_DASH  = "📊 Dashboard"
var string GRP_WH    = "🔔 Alerts"
var string GRP_COL   = "🌈 Colors"
i_atrLen      = input.int(22, "ATR Len", minval=1, group=GRP_CORE)
i_atrMult     = input.float(3.0, "ATR Mult", minval=0.1, step=0.1, group=GRP_CORE)
i_useCloseExt = input.bool(true, "Use Close Extremes", group=GRP_CORE, tooltip="Use highest/lowest of close instead of high/low")
i_htfFilterOn = input.bool(false, "HTF Trend Filter", group=GRP_FILT)
i_htfTF       = input.timeframe("240", "HTF TF", group=GRP_FILT)
i_htfLen      = input.int(63, "HTF EMA Len", minval=1, group=GRP_FILT)
i_useAdxFilter = input.bool(false, "📈 Use ADX Filter", group=GRP_FILT)
i_adxThresh    = input.float(20.0, "ADX Threshold", group=GRP_FILT, minval=0, step=0.5)
i_adxLen       = input.int(14, "ADX Length", group=GRP_FILT, minval=1)
i_adaptFilterType = input.string("None", "🧠 Adaptive Filter", options=["None", "Kalman Filter", "LLAMA"], group=GRP_FILT)
i_adaptFilterLen   = input.int(20, "Adaptive Filter Length", group=GRP_FILT, minval=1)
i_lockSignal  = input.bool(false, "🔒 Lock Signal", group=GRP_TRADE, tooltip="Freeze current signal · block new ones")
i_slAtrMult   = input.float(1.0, "SL ATR Mult", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp1R        = input.float(1.0, "TP1 R", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp2R        = input.float(2.0, "TP2 R", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp3R        = input.float(3.0, "TP3 R", minval=0.1, step=0.1, group=GRP_TRADE)
i_showCandles = input.bool(true, "Heatmap Candles", group=GRP_VIS)
i_showLevels  = input.bool(true, "Show Trade Levels", group=GRP_VIS)
_mt741a      = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos     = input.string("Top Right", "Dash Pos", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_DASH)
_mt741b        = input.string("long",        "↑ Long Action",        group=GRP_WH)
i_actionShort       = input.string("short",       "↓ Short Action",       group=GRP_WH)
i_actionCloseLong   = input.string("closelong",   "✕ Close Long Action",  group=GRP_WH)
i_actionCloseShort  = input.string("closeshort",  "✕ Close Short Action", group=GRP_WH)
c_bull        = input.color(#26a69a, "Bull", group=GRP_COL)
c_bear        = input.color(#ef5350, "Bear", group=GRP_COL)
c_sl          = input.color(#ef5350, "SL", group=GRP_COL)
c_entry       = input.color(#2196f3, "Entry", group=GRP_COL)
c_tp          = input.color(#26a69a, "TP", group=GRP_COL)
_mt741c    = input.color(color.new(#3a2a6d, 55), "Dash Hdr", group=GRP_COL)
C_DASH_BG     = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COL)
C_DASH_TXT    = input.color(#ffffff, "Dash Txt", group=GRP_COL)
// ── CORE LOGIC ──────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh
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
float _adaptedSrc = i_adaptFilterType == "Kalman Filter" ? f_kalman(close, i_adaptFilterLen) : i_adaptFilterType == "LLAMA" ? f_llama(close, i_adaptFilterLen) : close
float hh = i_useCloseExt ? ta.highest(_adaptedSrc, i_atrLen) : ta.highest(high, i_atrLen)
float ll = i_useCloseExt ? ta.lowest(_adaptedSrc, i_atrLen) : ta.lowest(low, i_atrLen)
float ceLong  = hh - atrVal * i_atrMult
float ceShort = ll + atrVal * i_atrMult
var float ceLine = na
var int _dir = 0
_dir := bar_index == 0 ? (close >= open ? 1 : -1) : close > ceShort[1] ? 1 : close < ceLong[1] ? -1 : _dir[1]
ceLine := bar_index == 0 ? (_dir == 1 ? ceLong : ceShort) : _dir == 1 ? math.max(ceLong, ceLine[1]) : _dir == -1 ? math.min(ceShort, ceLine[1]) : ceLine[1]
float htfEma = request.security(syminfo.tickerid, i_htfTF, ta.ema(close, i_htfLen)[1], lookahead=barmerge.lookahead_on)
bool htfBull = not i_htfFilterOn or close > htfEma
bool htfBear = not i_htfFilterOn or close < htfEma
bool _rawLong  = _dir == 1 and _dir[1] == -1 and htfBull and _adxPass
bool _rawShort = _dir == -1 and _dir[1] == 1 and htfBear and _adxPass
bool longSignal = false
bool shortSignal = false
if _rawLong and barstate.isconfirmed
    longSignal := true
if _rawShort and barstate.isconfirmed
    shortSignal := true
bool _locked = i_lockSignal and barstate.islast
color bodyColor = _dir == 1 ? c_bull : _dir == -1 ? c_bear : color.gray
color borderColor = bodyColor
var float entryPrice = na
var float slPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var int lastSignalBar = na
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
if (longSignal or shortSignal) and not _locked and i_showLevels
    f_deleteLevels()
    entryPrice := close
    float _risk = atrVal * i_slAtrMult
    slPrice := longSignal ? entryPrice - _risk : entryPrice + _risk
    tp1Price := longSignal ? entryPrice + _risk * i_tp1R : entryPrice - _risk * i_tp1R
    tp2Price := longSignal ? entryPrice + _risk * i_tp2R : entryPrice - _risk * i_tp2R
    tp3Price := longSignal ? entryPrice + _risk * i_tp3R : entryPrice - _risk * i_tp3R
    lastSignalBar := bar_index
    color _slC = longSignal ? c_sl : c_sl
    color _tpC1 = color.new(c_tp, 40)
    color _tpC2 = color.new(c_tp, 20)
    color _tpC3 = color.new(c_tp, 0)
    slLine := line.new(bar_index, slPrice, bar_index, slPrice, color=_slC, style=line.style_solid, width=2)
    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=c_entry, style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, tp1Price, bar_index, tp1Price, color=_tpC1, style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, tp2Price, bar_index, tp2Price, color=_tpC2, style=line.style_dashed, width=1)
    tp3Line := line.new(bar_index, tp3Price, bar_index, tp3Price, color=_tpC3, style=line.style_dashed, width=1)
    slLbl := label.new(bar_index, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=_slC, textcolor=#ffffff, size=size.small)
    entryLbl := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=c_entry, textcolor=#ffffff, size=size.small)
    tp1Lbl := label.new(bar_index, tp1Price, "◆ TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=_tpC1, textcolor=#ffffff, size=size.small)
    tp2Lbl := label.new(bar_index, tp2Price, "✦ TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=_tpC2, textcolor=#ffffff, size=size.small)
    tp3Lbl := label.new(bar_index, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=_tpC3, textcolor=#ffffff, size=size.small)
    riskFill := linefill.new(slLine, entryLine, color.new(c_sl, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(c_tp, 85))
if not na(slLine) and barstate.islast
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
var bool _tp1Done = false
var bool _tp2Done = false
var bool _tp3Done = false
if (longSignal or shortSignal) and not _locked and i_showLevels
    _tp1Done := false
    _tp2Done := false
    _tp3Done := false
bool _tp1Raw = not na(tp1Price) and (entryPrice < slPrice ? high >= tp1Price : low <= tp1Price)
bool _tp2Raw = not na(tp2Price) and (entryPrice < slPrice ? high >= tp2Price : low <= tp2Price)
bool _tp3Raw = not na(tp3Price) and (entryPrice < slPrice ? high >= tp3Price : low <= tp3Price)
bool tp1Hit = _tp1Raw and not _tp1Done
bool tp2Hit = _tp2Raw and not _tp2Done
bool tp3Hit = _tp3Raw and not _tp3Done
if tp1Hit
    _tp1Done := true
if tp2Hit
    _tp2Done := true
if tp3Hit
    _tp3Done := true
// ── ALERTS ──────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}"',
     _mt741b, syminfo.tickerid, timeframe.period,
     str.tostring(close, format.mintick),
     str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close, format.mintick),
     str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"
string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"
string _tp1Inner = str.format('"action":"tp1","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"tp2","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"tp3","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp3Price, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)
alertcondition(longSignal and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
// ── VISUALS ─────────────────────────────────────────────────
plotcandle(i_showCandles ? open : na, i_showCandles ? high : na, i_showCandles ? low : na, i_showCandles ? close : na,
     title       = "Heatmap Candles",
     color       = bodyColor,
     wickcolor   = borderColor,
     bordercolor = borderColor)
// ── DASHBOARD ───────────────────────────────────────────────
f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
string _dashPos = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(_dashPos, 2, 11, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
if _mt741a
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)
    table.cell(dash, 0, 0, "CE Nav", text_color=C_DASH_TXT, bgcolor=_mt741c, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, bgcolor=_mt741c, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 1, "  Lock", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE  " : "OFF  "), text_color=i_lockSignal ? c_bear : C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 2, "  Trend", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, (_dir == 1 ? "▲ Bull  " : _dir == -1 ? "▼ Bear  " : "Flat  "), text_color=_dir == 1 ? c_bull : _dir == -1 ? c_bear : C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 3, "  HTF Bias", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, (htfBull and not htfBear ? "📈 Bullish  " : htfBear and not htfBull ? "📉 Bearish  " : "Neutral  "), text_color=htfBull and not htfBear ? c_bull : htfBear and not htfBull ? c_bear : C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 4, "  CE Level", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(ceLine, format.mintick) + "  ", text_color=color.rgb(200,200,60), bgcolor=row_b, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 5, "  ATR", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atrVal, format.mintick) + "  ", text_color=color.rgb(200,200,60), bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 6, "  Entry", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, (na(entryPrice) ? "—  " : str.tostring(entryPrice, format.mintick) + "  "), text_color=color.rgb(200,200,60), bgcolor=row_b, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 7, "  SL", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, (na(slPrice) ? "—  " : str.tostring(slPrice, format.mintick) + "  "), text_color=c_bear, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
    float _rr = na(entryPrice) or na(slPrice) or entryPrice == slPrice ? na : math.abs(tp3Price - entryPrice) / math.abs(entryPrice - slPrice)
    table.cell(dash, 0, 8, "  R:R (TP3)", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, (na(_rr) ? "—  " : f_bar(_rr, 5.0) + "  "), text_color=na(_rr) ? C_DASH_TXT : f_barColor(math.min(_rr / 5.0, 1.0)), bgcolor=row_b, text_size=size.small, text_halign=text.align_right)
    if i_useAdxFilter
        table.cell(dash, 0, 9, "  ADX", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 9, str.tostring(_adxVal, "#.##") + "  ", text_color=_adxPass ? c_bull : c_bear, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
    if i_adaptFilterType != "None"
        table.cell(dash, 0, 10, "  Adapt Filter", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 10, i_adaptFilterType + "  ", text_color=C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)
````
