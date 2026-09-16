<!-- tradingview-pine-id: PUB;bad26aaa51e949e1abec0a87c630c6f8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# QQE Trend Confluence [MarkitTick]

Source: https://www.tradingview.com/script/Yg0CNk0R-QQE-Trend-Confluence-MarkitTick/

## Description

💡 A dual-engine QQE (Quantitative Qualitative Estimation) confluence oscillator that layers eight selectable pre-smoothing algorithms, a secondary confirmation QQE pair, ADX and higher-timeframe bias gating, and a fully automated ATR-based trade planner with webhook-ready alert payloads on top of the classic Wilder RSI-trailing-stop concept.

✨ Originality and Utility

[*]This script does not simply reproduce the stock QQE oscillator. It restructures the calculation into a layered decision pipeline where a signal only qualifies after passing through several independent, user-toggleable filters, turning a single momentum flip into a multi-factor confluence check.
[*]The source price is first routed through a selectable pre-smoothing stage offering eight distinct algorithms, ranging from classic moving averages to a proprietary slope-projection method and a recursive Kalman estimator, before it ever reaches the QQE math. This changes the responsiveness and noise profile of every signal generated downstream.
[*]A second, independently parameterized QQE instance runs in parallel purely as a confirmation gate, meaning a raw crossover on the primary pair is discarded unless a slower QQE pair already agrees with its direction.
[*]An ADX/DMI strength filter and a non-repainting higher-timeframe bias filter can each independently veto a signal, so traders can require trend strength and multi-timeframe agreement without writing their own confluence logic.
[*]The script goes beyond signal generation into trade management: a built-in ATR trade planner converts a qualifying cross into a full stop-loss and three-tiered take-profit plan, drawn directly on the chart and tracked bar by bar.
[*]A structured JSON alert payload system is built into every signal and trade-management event, making the tool usable as the signal engine for an external automation or webhook pipeline without any manual message formatting.
[*]The combination of these components is deliberate rather than incidental: the pre-smoothing stage shapes what "signal" means, the dual-QQE and filter stack decides which of those signals are trustworthy, and the trade planner and alert system decide what to do once a signal is accepted. Removing any one layer would leave a materially different and less complete tool, which is why they are published together as a single confluence system rather than as separate scripts.

🔬 Methodology and Concepts

• Adaptive Pre-Smoothing Engine
Before the source price reaches the QQE engine, it can optionally be passed through one of eight smoothing or prediction methods, selectable from a dropdown. This determines how "clean" or "responsive" the underlying momentum reading is.

[*]Simple, Exponential and Wilder (RMA) moving averages behave as their standard definitions.
[*]A double weighted moving average applies a WMA to the result of a first WMA pass, compounding the weighting effect for extra lag reduction.
[*]A triple volume-weighted moving average chains three successive VWMA passes, folding volume into the trend estimate at each stage.
[*]The Hull Moving Average uses the standard weighted-difference technique to reduce lag relative to a simple weighted average.
[*]The proprietary LLAMA method computes a simple moving average baseline over the lookback window, then measures the linear slope of price across that same window (the difference between the current source and the value from "length" bars back, divided by length). That slope is then projected forward by half the lookback length and added to the SMA baseline. The practical effect is a moving average that leans ahead of price during a steady trend and collapses back toward a standard SMA when price is flat or choppy.
[*]The Kalman Filter option treats the source price as a noisy observation of an underlying "true" trend state. It maintains an internal estimate and error variance, computes a Kalman gain each bar from a length-derived process-noise assumption and a fixed measurement-noise assumption, and blends the new price observation into the estimate proportionally to that gain, producing a smoothing curve that adapts its own responsiveness over time.

• Dual QQE Core
The QQE concept itself works by smoothing an RSI reading with an EMA, then measuring the average magnitude of bar-to-bar changes in that smoothed RSI (a Wilder-style double-smoothed "ATR of RSI"), and multiplying it by a factor to build a trailing envelope around the smoothed RSI line. This trailing level only moves in the direction the RSI is already travelling and locks in place, ratchet-style, whenever RSI reverses, similar in spirit to a classic ATR trailing stop but applied in RSI space rather than price space. A cross of the smoothed RSI over or under this trailing level marks a momentum shift. This script runs two such QQE instances simultaneously: a faster primary pair that generates the raw crossover, and an optional slower secondary pair whose sole purpose is confirmation, a signal from the primary pair is only accepted if the secondary pair's RSI-to-trail relationship already agrees with the same direction.

• Confirmation Filters

[*]An optional ADX/DMI filter, built on Wilder's Average Directional Index, requires trend strength to be above a user-defined threshold before a signal is allowed through, filtering out crosses that occur during flat, directionless conditions.
[*]An optional higher-timeframe bias filter pulls the same QQE relationship (smoothed RSI versus trailing level) from a user-selected higher timeframe and requires it to agree with the direction of the current-timeframe signal. This request is built using the previous, already-confirmed value on the higher timeframe combined with lookahead-on merging, which is the standard non-repainting pattern for higher-timeframe data: the value shown on any historical bar is the same value that would have been available to a trader watching in real time.

• ATR-Based Trade Planner
Once a signal clears every enabled filter, the script computes a stop-loss using the 14-period Average True Range multiplied by a user-defined multiple, anchored to the prior bar's close. Three take-profit levels are then derived from that risk distance using independently configurable risk:reward ratios. These levels are drawn as extending price lines with labels and shaded risk/reward zone fills, and the script continuously checks, bar by bar, whether price has touched each take-profit or the stop-loss, retiring the plan once the final target or the stop is hit. A lock control can freeze the currently displayed plan so it does not get replaced by a new signal while a trade is being managed.

• Signal Confirmation Behavior
The crossover state that drives every signal is always evaluated using the prior, already-completed bar's smoothed RSI and trailing-level relationship rather than the still-forming current bar. In practical terms, this means a BULL or BEAR marker only ever prints once the underlying cross is confirmed, and it does not shift position or disappear on subsequent price updates within the same bar.

• Automation-Ready Alerts
Every entry, exit, and trade-management event (long entry, short entry, close-long, close-short, and each of the three take-profit levels plus stop-loss) is wrapped in its own alert condition and also emits a structured JSON message through a single dynamic alert call, gated to fire only once per confirmed bar close for entries. Each JSON message includes the instrument, timeframe, and an editable action keyword, allowing the same signal engine to be wired directly into an external automation or webhook workflow.

🎨 Visual Guide

[*]In the indicator's own pane: the blue RSI MA line is the primary smoothed-RSI reading, the yellow Smoothed Trail line is its dynamic trailing envelope, and the histogram plotted around the zero line reflects the distance between the two, colored teal on the bullish side and red on the bearish side.
[*]Dashed reference lines at 70 and 30 mark overbought and oversold RSI zones with a light shaded fill between each level and the 50 midline when enabled.
[*]On the price chart itself: candles can be recolored using a four-tone scheme, strong bullish teal and weak bullish dark teal, or strong bearish red and weak bearish dark red, with a neutral gray used whenever the current QQE distance is smaller than its own running average, giving an at-a-glance read on momentum strength as well as direction.
[*]BULL and BEAR labeled arrows print just below or above the triggering candle whenever a fully confirmed signal fires.
[*]When trade levels are enabled, dashed lines and small labels for the stop-loss, entry, and three take-profit levels extend to the right from the signal bar, with the area between entry and stop shaded as a risk zone and the area between entry and the furthest target shaded as a reward zone.
[*]An optional multi-row dashboard panel, placeable in any chart corner, summarizes the instrument and timeframe, lock status, current bias, the raw RSI MA and Trail Level values, an ASCII progress-bar style RSI strength meter, the secondary confluence state, the higher-timeframe bias, the ADX reading and pass/fail color, the currently active pre-smoothing method, the ATR value, the DI+/DI- readings, a momentum strength bar, and the active trade's direction and price levels.

📖 How to Use

[*]Treat a BULL or BEAR arrow as the point where every enabled filter, the primary cross, the secondary QQE confirmation, the ADX gate, and the higher-timeframe bias, has already agreed on a direction.
[*]Use candle color intensity and histogram height as a secondary read on how strong the current momentum reading is relative to its own recent average, rather than as a standalone signal.
[*]Scan the dashboard's Bias, Confluence, and HTF Bias rows for a fast multi-factor summary without needing to inspect the oscillator pane directly.
[*]Enable the trade levels option to have the script draw a stop-loss and three take-profit targets automatically on each qualifying signal, and use the lock control to freeze that plan in place while managing an open position.
[*]Adjust the ATR stop multiple and the three risk:reward ratios to match your own risk tolerance before relying on the drawn levels.
[*]For automation, create a TradingView alert using the "Any alert() function call" option to receive the full JSON payload stream, or use the individual named alert conditions if only a single event type is needed.
[*]This tool is a momentum and confluence framework, not a complete trading system on its own. Combine it with your own market structure, support/resistance, or volatility context before acting on any signal.

⚙️ Inputs and Settings

[*]Core Settings: RSI Length and RSI EMA Smoothing control the primary QQE's momentum lookback and responsiveness; QQE Factor scales how wide the trailing envelope sits from the smoothed RSI; Source selects the price series feeding the whole calculation; the secondary QQE toggle, along with its own EMA smoothing and factor, controls the confirmation pair.
[*]Filters: the ADX toggle, length, and threshold control the trend-strength gate; the Adaptive Filter dropdown and length select which of the eight pre-smoothing methods (including LLAMA and the Kalman Filter) is applied to price before the QQE math runs; the HTF filter toggle and timeframe control the higher-timeframe bias confirmation.
[*]Trade Tools: toggles for showing trade levels and locking the current signal, an ATR multiple for stop-loss distance, and three independent risk:reward ratios for the three take-profit targets.
[*]Visuals: independent toggles for the overbought/oversold zone fill, the histogram, the crossover arrows, and the color-matched candles.
[*]Dashboard: a toggle to show or hide the panel and a dropdown to choose which chart corner it docks to.
[*]Alerts: editable text fields defining the action keyword sent in the JSON payload for each of the eight tracked events, letting the output match whatever automation platform is receiving it.
[*]Colors: a full set of color pickers covering the oscillator lines, histogram, zones, arrows, candle tones, trade-planning lines and fills, and dashboard styling, purely cosmetic and with no effect on calculations.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

[*]The foundation of the oscillator is J. Welles Wilder Jr.'s Relative Strength Index and his broader family of smoothed volatility and trend-strength tools, including the Average True Range concept and the Average Directional Index used here as an optional filter.
[*]The QQE structure itself extends Wilder's trailing-stop logic, normally applied to price, into RSI space: an ATR-style measure of RSI's own volatility is used to build a ratcheting trailing envelope around the smoothed RSI line, conceptually related to other ATR-trailing-stop tools such as Chandelier Exit or SuperTrend but operating on a momentum oscillator rather than raw price.
[*]The Hull Moving Average option is built on Alan Hull's weighted-difference technique for reducing the inherent lag of weighted moving averages.
[*]The LLAMA pre-smoothing option applies a basic linear extrapolation principle, projecting a simple moving average forward using the measured slope of price across the same lookback window, a lightweight analogue of trend-extrapolation methods used in linear regression forecasting.
[*]The Kalman Filter option is a direct application of Rudolf Kálmán's recursive estimation framework, treating price as a noisy observation of an unobserved underlying trend state and updating that estimate bar by bar using a dynamically computed gain, a technique widely used in modern adaptive filtering and signal processing.
[*]The ATR trade planner applies standard volatility-based position planning, using a multiple of Average True Range to size a stop distance and deriving profit targets from fixed risk:reward multiples of that same distance.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator(title="QQE Trend Confluence [MarkitTick]", overlay=false, precision=2)

// ── INPUTS ─────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_rsiLen    = input.int(14,   "RSI Length",       group=GRP_CORE, minval=2)
i_sf        = input.int(5,    "RSI EMA Smoothing", group=GRP_CORE, minval=1)
i_qqeFactor = input.float(4.236, "QQE Factor",    group=GRP_CORE, minval=0.1, step=0.001)
i_src       = input.source(close, "Source",       group=GRP_CORE)
i_useSecond = input.bool(true, "🌊 Use 2nd QQE (Confluence)", group=GRP_CORE, tooltip="Second slower QQE pair used for confluence confirmation")
i_sf2       = input.int(12,   "2nd RSI EMA Smoothing", group=GRP_CORE, minval=1)
i_qqeFactor2 = input.float(1.618, "2nd QQE Factor", group=GRP_CORE, minval=0.1, step=0.001)

var string GRP_FILT = "🕯️ Filters"
i_useAdxFilter = input.bool(false, "📈 Use ADX Filter", group=GRP_FILT)
i_adxLen       = input.int(14,     "ADX Length",         group=GRP_FILT, minval=1)
i_adxThresh    = input.float(20.0, "ADX Threshold",      group=GRP_FILT, minval=0, step=0.5)
i_adaptFilterType = input.string("None", "🧠 Adaptive Filter", options=["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group=GRP_FILT)
i_adaptFilterLen   = input.int(20,        "Adaptive Filter Length", group=GRP_FILT, minval=1)
i_useHtfFilter  = input.bool(false, "⏱️ Use HTF Bias Filter", group=GRP_FILT)
i_htfTimeframe  = input.timeframe("60", "HTF Bias Timeframe", group=GRP_FILT)

var string GRP_TRADE = "📐 Trade Tools"
i_showLevels  = input.bool(false, "📐 Show Trade Levels", group=GRP_TRADE, tooltip="Draw SL / Entry / TP lines and labels on signal")
i_lockSignal  = input.bool(false, "🔒 Lock Signal", group=GRP_TRADE, tooltip="Freeze current signal · block new ones")
i_slAtrMult   = input.float(1.5, "SL ATR Multiple", group=GRP_TRADE, minval=0.1, step=0.1)
i_tp1Rr       = input.float(1.0, "TP1 Risk:Reward", group=GRP_TRADE, minval=0.1, step=0.1)
i_tp2Rr       = input.float(2.0, "TP2 Risk:Reward", group=GRP_TRADE, minval=0.1, step=0.1)
i_tp3Rr       = input.float(3.0, "TP3 Risk:Reward", group=GRP_TRADE, minval=0.1, step=0.1)

var string GRP_VIS = "🎨 Visuals"
i_showBands     = input.bool(true, "Show Overbought/Oversold Zones", group=GRP_VIS)
i_showHist      = input.bool(true, "Show QQE Histogram", group=GRP_VIS)
i_showArrows    = input.bool(true, "Show Crossover Arrows", group=GRP_VIS)
i_showCandles   = input.bool(true, "Show Color Matched Candles", group=GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
i_showDash    = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos     = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_DASH)

var string GRP_WH = "🔔 Alerts"
i_actionLong      = input.string("long",       "↑ Long Action",       group=GRP_WH)
i_actionShort     = input.string("short",      "↓ Short Action",      group=GRP_WH)
i_actionCloseLong = input.string("closelong",  "✕ Close Long Action", group=GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)
i_actionTp1        = input.string("tp1hit",     "◆ TP1 Hit Action",   group=GRP_WH)
i_actionTp2        = input.string("tp2hit",     "✦ TP2 Hit Action",   group=GRP_WH)
i_actionTp3        = input.string("tp3hit",     "◆ TP3 Hit Action",   group=GRP_WH)
i_actionSlHit      = input.string("slhit",      "✕ SL Hit Action",    group=GRP_WH)

var string GRP_COL = "🌈 Colors"
c_rsiMa       = input.color(#2196f3, "RSI MA Line",         group=GRP_COL)
c_trLevel     = input.color(#ffe500, "Smoothed Trail Line", group=GRP_COL)
c_histBull    = input.color(color.new(#26a69a, 40), "Histogram Bull", group=GRP_COL)
c_histBear    = input.color(color.new(#ef5350, 40), "Histogram Bear", group=GRP_COL)
c_hlineRef    = input.color(color.new(#787b86, 70), "Reference Lines", group=GRP_COL)
c_hlineMid    = input.color(color.new(#787b86, 50), "Midline Line",    group=GRP_COL)
c_zoneOb      = input.color(color.new(#ef5350, 90), "Overbought Zone", group=GRP_COL)
c_zoneOs      = input.color(color.new(#26a69a, 90), "Oversold Zone",   group=GRP_COL)
c_arrowUp     = input.color(#26a69a, "Bull Arrow", group=GRP_COL)
c_arrowDn     = input.color(#ef5350, "Bear Arrow", group=GRP_COL)
c_arrowText   = input.color(color.white, "Arrow Text", group=GRP_COL)
c_candleUpStrong = input.color(color.new(#26a69a, 0),  "Candle Up Strong", group=GRP_COL)
c_candleUpWeak   = input.color(color.new(#0d4d43, 0),  "Candle Up Weak",   group=GRP_COL)
c_candleDnStrong = input.color(color.new(#ef5350, 0),  "Candle Down Strong", group=GRP_COL)
c_candleDnWeak   = input.color(color.new(#5c1f1d, 0),  "Candle Down Weak",   group=GRP_COL)
c_candleNeutral  = input.color(color.rgb(80,90,110),   "Candle Neutral",     group=GRP_COL)
c_slColor     = input.color(#ef5350, "SL Line", group=GRP_COL)
c_entryColor  = input.color(#2196f3, "Entry Line", group=GRP_COL)
c_tp1Color    = input.color(color.new(#26a69a, 40), "TP1 Line", group=GRP_COL)
c_tp2Color    = input.color(color.new(#26a69a, 20), "TP2 Line", group=GRP_COL)
c_tp3Color    = input.color(color.new(#26a69a, 0),  "TP3 Line", group=GRP_COL)
c_riskFill    = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group=GRP_COL)
c_rewardFill  = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group=GRP_COL)
C_DASH_HDR    = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group=GRP_COL)
C_DASH_BG     = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group=GRP_COL)
C_DASH_TXT    = input.color(color.new(#ffffff, 0),  "Dashboard Text",   group=GRP_COL)
C_SUP         = input.color(#26a69a, "Bullish State Color", group=GRP_COL)
C_RES         = input.color(#ef5350, "Bearish State Color", group=GRP_COL)

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

float _adaptedSrc = i_adaptFilterType == "SMA"         ? f_sma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "EMA"         ? f_ema(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "RMA"         ? f_rma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA"  ? f_doubleWma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "HMA"         ? f_hma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA"       ? f_llama(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(i_src, i_adaptFilterLen) : i_src

f_qqe(float src, int rsiLen, int sf, float factor) =>
    int _wildersLen = rsiLen * 2 - 1
    float _rsi = ta.rsi(src, rsiLen)
    float _rsiMa = ta.ema(_rsi, sf)
    float _atrRsi = na(_rsiMa[1]) ? na : math.abs(_rsiMa[1] - _rsiMa)
    float _maAtrRsi = ta.ema(_atrRsi, _wildersLen)
    float _dar = ta.ema(_maAtrRsi, _wildersLen) * factor
    var float _trLevel = na
    bool _warmedUp = not na(_dar)
    float _prevTr = na(_trLevel) ? _rsiMa : _trLevel
    float _rsi0 = _rsiMa
    float _rsi1 = na(_rsiMa[1]) ? _rsiMa : _rsiMa[1]
    if _warmedUp
        if _rsi0 < _prevTr
            _trLevel := _rsi0 + _dar
            if _rsi1 < _prevTr and _trLevel > _prevTr
                _trLevel := _prevTr
        else if _rsi0 > _prevTr
            _trLevel := _rsi0 - _dar
            if _rsi1 > _prevTr and _trLevel < _prevTr
                _trLevel := _prevTr
        else
            _trLevel := _prevTr
    [_rsiMa, _trLevel]

[rsiMa, trLevel] = f_qqe(_adaptedSrc, i_rsiLen, i_sf, i_qqeFactor)
[rsiMa2, trLevel2] = f_qqe(_adaptedSrc, i_rsiLen, i_sf2, i_qqeFactor2)

var int _qqeSide = 0
float _rsiMaC = rsiMa[1]
float _trLevelC = trLevel[1]
int _qqeSideNow = _rsiMaC > _trLevelC ? 1 : _rsiMaC < _trLevelC ? -1 : _qqeSide
bool _rawCrossUp = _qqeSideNow == 1 and _qqeSide == -1
bool _rawCrossDn = _qqeSideNow == -1 and _qqeSide == 1
_qqeSide := _qqeSideNow
bool _confluenceBull = not i_useSecond or rsiMa2[1] > trLevel2[1]
bool _confluenceBear = not i_useSecond or rsiMa2[1] < trLevel2[1]

[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal[1] >= i_adxThresh

float _htfRsiMa = request.security(syminfo.tickerid, i_htfTimeframe, rsiMa[1], lookahead=barmerge.lookahead_on)
float _htfTrLevel = request.security(syminfo.tickerid, i_htfTimeframe, trLevel[1], lookahead=barmerge.lookahead_on)
bool _htfBullBias = not i_useHtfFilter or _htfRsiMa > _htfTrLevel
bool _htfBearBias = not i_useHtfFilter or _htfRsiMa < _htfTrLevel

bool longSignal  = _rawCrossUp and _confluenceBull and _adxPass and _htfBullBias
bool shortSignal = _rawCrossDn and _confluenceBear and _adxPass and _htfBearBias

float _levelAtr = ta.atr(14)
float entryPriceLong  = close[1]
float slPriceLong     = entryPriceLong - _levelAtr * i_slAtrMult
float _riskLong        = entryPriceLong - slPriceLong
float tp1PriceLong     = entryPriceLong + _riskLong * i_tp1Rr
float tp2PriceLong     = entryPriceLong + _riskLong * i_tp2Rr
float tp3PriceLong     = entryPriceLong + _riskLong * i_tp3Rr
float entryPriceShort  = close[1]
float slPriceShort     = entryPriceShort + _levelAtr * i_slAtrMult
float _riskShort        = slPriceShort - entryPriceShort
float tp1PriceShort     = entryPriceShort - _riskShort * i_tp1Rr
float tp2PriceShort     = entryPriceShort - _riskShort * i_tp2Rr
float tp3PriceShort     = entryPriceShort - _riskShort * i_tp3Rr

bool _locked = i_lockSignal and barstate.islast

var string _activeDir = na
var float _activeSl   = na
var float _activeTp1  = na
var float _activeTp2  = na
var float _activeTp3  = na

if i_showLevels and longSignal and not _locked
    _activeDir := "long"
    _activeSl   := slPriceLong
    _activeTp1  := tp1PriceLong
    _activeTp2  := tp2PriceLong
    _activeTp3  := tp3PriceLong
if i_showLevels and shortSignal and not _locked
    _activeDir := "short"
    _activeSl   := slPriceShort
    _activeTp1  := tp1PriceShort
    _activeTp2  := tp2PriceShort
    _activeTp3  := tp3PriceShort

bool tp1Hit = _activeDir == "long"  and not na(_activeTp1) and high >= _activeTp1 or _activeDir == "short" and not na(_activeTp1) and low <= _activeTp1
bool tp2Hit = _activeDir == "long"  and not na(_activeTp2) and high >= _activeTp2 or _activeDir == "short" and not na(_activeTp2) and low <= _activeTp2
bool tp3Hit = _activeDir == "long"  and not na(_activeTp3) and high >= _activeTp3 or _activeDir == "short" and not na(_activeTp3) and low <= _activeTp3
bool slHit  = _activeDir == "long"  and not na(_activeSl)  and low  <= _activeSl  or _activeDir == "short" and not na(_activeSl)  and high >= _activeSl

if tp3Hit or slHit
    _activeDir := na
    _activeSl   := na
    _activeTp1  := na
    _activeTp2  := na
    _activeTp3  := na

float _qqeDist = rsiMa - trLevel
bool _isBullBias = _qqeDist > 0
bool _isBearBias = _qqeDist < 0
float _distAvg = ta.rma(math.abs(_qqeDist), i_rsiLen)
bool _isStrong = math.abs(_qqeDist) >= _distAvg
color _baseCandleColor = _isBullBias ? (_isStrong ? c_candleUpStrong : c_candleUpWeak) : _isBearBias ? (_isStrong ? c_candleDnStrong : c_candleDnWeak) : c_candleNeutral
bool _isGreenShade = _baseCandleColor == c_candleUpStrong or _baseCandleColor == c_candleUpWeak
bool _isRedShade   = _baseCandleColor == c_candleDnStrong or _baseCandleColor == c_candleDnWeak
color candleColor = _isGreenShade and rsiMa < trLevel ? c_candleNeutral : _isRedShade and rsiMa > trLevel ? c_candleNeutral : _baseCandleColor

// ── ALERTS ──────────────────────────────────────────────────────
string _longInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","rsi_ma":"{3}","trail":"{4}"',
 i_actionLong, syminfo.tickerid, timeframe.period,
 str.tostring(rsiMa, "#.##"), str.tostring(trLevel, "#.##"))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","rsi_ma":"{3}","trail":"{4}"',
 i_actionShort, syminfo.tickerid, timeframe.period,
 str.tostring(rsiMa, "#.##"), str.tostring(trLevel, "#.##"))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"',
 i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"',
 i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

string _tp1Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","price":"{4}"',
 i_actionTp1, syminfo.tickerid, timeframe.period, _activeDir, str.tostring(_activeTp1, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"

string _tp2Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","price":"{4}"',
 i_actionTp2, syminfo.tickerid, timeframe.period, _activeDir, str.tostring(_activeTp2, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"

string _tp3Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","price":"{4}"',
 i_actionTp3, syminfo.tickerid, timeframe.period, _activeDir, str.tostring(_activeTp3, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

string _slHitInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","price":"{4}"',
 i_actionSlHit, syminfo.tickerid, timeframe.period, _activeDir, str.tostring(_activeSl, format.mintick))
string slHitPayload = "{" + _slHitInner + "}"

if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)

if i_showLevels and tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if i_showLevels and tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if i_showLevels and tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)
if i_showLevels and slHit
    alert(slHitPayload, alert.freq_once_per_bar)

alertcondition(longSignal  and barstate.isconfirmed, "BUY Signal",         "MarkitTick QQE — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick QQE — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick QQE — Close Long")
alertcondition(longSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick QQE — Close Short")
alertcondition(tp1Hit, "TP1 Hit", "MarkitTick QQE — TP1 Hit")
alertcondition(tp2Hit, "TP2 Hit", "MarkitTick QQE — TP2 Hit")
alertcondition(tp3Hit, "TP3 Hit", "MarkitTick QQE — TP3 Hit")
alertcondition(slHit,  "SL Hit",  "MarkitTick QQE — SL Hit")

// ── VISUALS ────────────────────────────────────────────────────
hl70 = hline(i_showBands ? 70 : na, "Overbought", color=c_hlineRef)
hl50 = hline(50, "Midline", color=c_hlineMid)
hl30 = hline(i_showBands ? 30 : na, "Oversold", color=c_hlineRef)
fill(hl70, hl50, i_showBands ? c_zoneOb : na, title="OB Zone")
fill(hl30, hl50, i_showBands ? c_zoneOs : na, title="OS Zone")

hist_val = _qqeDist
hist_color = hist_val >= 0 ? c_histBull : c_histBear
plot(i_showHist ? hist_val : na, "Histogram", color=hist_color, style=plot.style_histogram, linewidth=1)

plot(trLevel, "Smoothed Trail", color=c_trLevel, linewidth=1)
plot(rsiMa, "RSI MA", color=c_rsiMa, linewidth=2)

plotshape(i_showArrows and longSignal  ? trLevel : na, "Bull Signal", style=shape.labelup,   location=location.absolute, color=c_arrowUp, textcolor=c_arrowText, text="BULL", size=size.tiny)
plotshape(i_showArrows and shortSignal ? trLevel : na, "Bear Signal", style=shape.labeldown, location=location.absolute, color=c_arrowDn, textcolor=c_arrowText, text="BEAR", size=size.tiny)

float _priceOffset = ta.atr(14) * 0.5
plotshape(i_showArrows and longSignal  ? low - _priceOffset  : na, "Bull Signal (Candles)", style=shape.labelup,   location=location.absolute, color=c_arrowUp, textcolor=c_arrowText, text="BULL", size=size.tiny, force_overlay=true)
plotshape(i_showArrows and shortSignal ? high + _priceOffset : na, "Bear Signal (Candles)", style=shape.labeldown, location=location.absolute, color=c_arrowDn, textcolor=c_arrowText, text="BEAR", size=size.tiny, force_overlay=true)

candle_col = i_showCandles ? candleColor : na
plotcandle(i_showCandles ? open : na, i_showCandles ? high : na, i_showCandles ? low : na, i_showCandles ? close : na, title="QQE Matched Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true)
barcolor(i_showCandles ? candle_col : na)

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

if i_showLevels and longSignal and not _locked
    f_deleteLevels()
    slLine := line.new(bar_index, slPriceLong, bar_index, slPriceLong, color=c_slColor, style=line.style_dashed, width=2, force_overlay=true)
    entryLine := line.new(bar_index, entryPriceLong, bar_index, entryPriceLong, color=c_entryColor, style=line.style_dashed, width=1, force_overlay=true)
    tp1Line := line.new(bar_index, tp1PriceLong, bar_index, tp1PriceLong, color=c_tp1Color, style=line.style_dashed, width=1, force_overlay=true)
    tp2Line := line.new(bar_index, tp2PriceLong, bar_index, tp2PriceLong, color=c_tp2Color, style=line.style_dashed, width=1, force_overlay=true)
    tp3Line := line.new(bar_index, tp3PriceLong, bar_index, tp3PriceLong, color=c_tp3Color, style=line.style_dashed, width=1, force_overlay=true)
    slLbl := label.new(bar_index, slPriceLong, "✕ SL " + str.tostring(slPriceLong, format.mintick), style=label.style_label_left, color=c_slColor, textcolor=color.white, size=size.small, force_overlay=true)
    entryLbl := label.new(bar_index, entryPriceLong, "▶ Entry " + str.tostring(entryPriceLong, format.mintick), style=label.style_label_left, color=c_entryColor, textcolor=color.white, size=size.small, force_overlay=true)
    tp1Lbl := label.new(bar_index, tp1PriceLong, "◆ TP1 " + str.tostring(tp1PriceLong, format.mintick), style=label.style_label_left, color=c_tp1Color, textcolor=color.white, size=size.small, force_overlay=true)
    tp2Lbl := label.new(bar_index, tp2PriceLong, "✦ TP2 " + str.tostring(tp2PriceLong, format.mintick), style=label.style_label_left, color=c_tp2Color, textcolor=color.white, size=size.small, force_overlay=true)
    tp3Lbl := label.new(bar_index, tp3PriceLong, "◆ TP3 " + str.tostring(tp3PriceLong, format.mintick), style=label.style_label_left, color=c_tp3Color, textcolor=color.white, size=size.small, force_overlay=true)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)
    lastSignalBar := bar_index

if i_showLevels and shortSignal and not _locked
    f_deleteLevels()
    slLine := line.new(bar_index, slPriceShort, bar_index, slPriceShort, color=c_slColor, style=line.style_dashed, width=2, force_overlay=true)
    entryLine := line.new(bar_index, entryPriceShort, bar_index, entryPriceShort, color=c_entryColor, style=line.style_dashed, width=1, force_overlay=true)
    tp1Line := line.new(bar_index, tp1PriceShort, bar_index, tp1PriceShort, color=c_tp1Color, style=line.style_dashed, width=1, force_overlay=true)
    tp2Line := line.new(bar_index, tp2PriceShort, bar_index, tp2PriceShort, color=c_tp2Color, style=line.style_dashed, width=1, force_overlay=true)
    tp3Line := line.new(bar_index, tp3PriceShort, bar_index, tp3PriceShort, color=c_tp3Color, style=line.style_dashed, width=1, force_overlay=true)
    slLbl := label.new(bar_index, slPriceShort, "✕ SL " + str.tostring(slPriceShort, format.mintick), style=label.style_label_left, color=c_slColor, textcolor=color.white, size=size.small, force_overlay=true)
    entryLbl := label.new(bar_index, entryPriceShort, "▶ Entry " + str.tostring(entryPriceShort, format.mintick), style=label.style_label_left, color=c_entryColor, textcolor=color.white, size=size.small, force_overlay=true)
    tp1Lbl := label.new(bar_index, tp1PriceShort, "◆ TP1 " + str.tostring(tp1PriceShort, format.mintick), style=label.style_label_left, color=c_tp1Color, textcolor=color.white, size=size.small, force_overlay=true)
    tp2Lbl := label.new(bar_index, tp2PriceShort, "✦ TP2 " + str.tostring(tp2PriceShort, format.mintick), style=label.style_label_left, color=c_tp2Color, textcolor=color.white, size=size.small, force_overlay=true)
    tp3Lbl := label.new(bar_index, tp3PriceShort, "◆ TP3 " + str.tostring(tp3PriceShort, format.mintick), style=label.style_label_left, color=c_tp3Color, textcolor=color.white, size=size.small, force_overlay=true)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)
    lastSignalBar := bar_index

if i_showLevels and not na(slLine) and (i_lockSignal or bar_index <= lastSignalBar + 10)
    int _extX = i_lockSignal ? bar_index + 10 : lastSignalBar + 10
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

// ── DASHBOARD ──────────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int _filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string _bar = ""
    for i = 1 to 10
        _bar += i <= _filled ? "█" : "░"
    _bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

var string _dashPosMap = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(_dashPosMap, 2, 16, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40), force_overlay=true)

if i_showDash
    string _biasTxt = rsiMa > trLevel ? "BULLISH" : "BEARISH"
    color _biasCol = rsiMa > trLevel ? C_SUP : C_RES
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)

    table.cell(dash, 0, 0, "QQE Pro", text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 1, "  Lock", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, i_lockSignal ? "ACTIVE  " : "OFF  ", text_color=i_lockSignal ? C_RES : C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 2, "  Bias", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, _biasTxt + "  ", text_color=_biasCol, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 3, "  RSI MA", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(rsiMa, "#.##") + "  ", text_color=C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 4, "  Trail Level", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(trLevel, "#.##") + "  ", text_color=C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 5, "  RSI Strength", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, f_bar(rsiMa, 100), text_color=f_barColor(rsiMa / 100), bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 6, "  Confluence", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, i_useSecond ? (_confluenceBull ? "BULL  " : _confluenceBear ? "BEAR  " : "MIXED  ") : "OFF  ", text_color=i_useSecond ? (_confluenceBull ? C_SUP : C_RES) : C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 7, "  HTF Bias", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, i_useHtfFilter ? (_htfBullBias ? "BULL  " : "BEAR  ") : "OFF  ", text_color=i_useHtfFilter ? (_htfBullBias ? C_SUP : C_RES) : C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 8, "  ADX", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(_adxVal, "#.##") + "  ", text_color=_adxPass ? C_SUP : C_RES, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 9, "  Adapt Filter", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, i_adaptFilterType + "  ", text_color=C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 10, "  ATR", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(_levelAtr, format.mintick) + "  ", text_color=C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 11, "  DI+ / DI-", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 11, str.tostring(_diPlus, "#.##") + " / " + str.tostring(_diMinus, "#.##") + "  ", text_color=_diPlus > _diMinus ? C_SUP : C_RES, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 12, "  Momentum", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    float _momMax = _distAvg * 2
    table.cell(dash, 1, 12, not na(_momMax) and _momMax > 0 ? f_bar(math.abs(_qqeDist), _momMax) : "—", text_color=not na(_momMax) and _momMax > 0 ? f_barColor(math.abs(_qqeDist) / _momMax) : C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 13, "  Active Trade", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 13, i_showLevels ? (na(_activeDir) ? "NONE  " : str.upper(_activeDir) + "  ") : "OFF  ", text_color=_activeDir == "long" ? C_SUP : _activeDir == "short" ? C_RES : C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 14, "  SL / TP1", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 14, i_showLevels and not na(_activeDir) ? str.tostring(_activeSl, format.mintick) + " / " + str.tostring(_activeTp1, format.mintick) + "  " : "—  ", text_color=C_DASH_TXT, bgcolor=row_b, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 15, "  TP2 / TP3", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 15, i_showLevels and not na(_activeDir) ? str.tostring(_activeTp2, format.mintick) + " / " + str.tostring(_activeTp3, format.mintick) + "  " : "—  ", text_color=C_DASH_TXT, bgcolor=row_a, text_size=size.small, text_halign=text.align_right)
````
