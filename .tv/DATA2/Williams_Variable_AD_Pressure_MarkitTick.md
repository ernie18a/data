<!-- tradingview-pine-id: PUB;f4e4a590dac94960b7da607204275047 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Williams Variable A/D Pressure [MarkitTick]

Source: https://www.tradingview.com/script/g3P0iG3j-Williams-Variable-A-D-Pressure-MarkitTick/

## Description

💡 This tool reframes Larry Williams' Variable Accumulation/Distribution concept as a fully adaptive, confluence-filtered oscillator, then extends it into a complete ATR-based trade-management layer with a live on-chart dashboard. Rather than reading a single fixed-formula line, traders get a volume-weighted pressure reading that can be reshaped through eight different smoothing engines, gated by a trend-strength filter and a higher-timeframe bias check, and translated directly into projected entry, stop, and take-profit levels the moment a qualifying signal appears.

✨ Originality and Utility
The core value of this script is not the Variable A/D formula itself — that calculation is decades old — but the pipeline built around it. Three distinct engineering layers are stacked with a specific purpose each, which is what justifies combining them into a single publication rather than three separate scripts:

[*]A selectable adaptive-smoothing stage that lets the trader choose how the raw pressure sum is denoised — from simple averaging to cascaded, lag-reduced, and custom recursive estimators — instead of being locked into one fixed filter shape.
[*]A dual confluence gate (trend-strength via ADX and directional bias via a higher timeframe) that suppresses crossovers occurring in weak or conflicting conditions, rather than firing on every raw cross of the smoothed line against its signal average.
[*]An execution layer that converts a confirmed crossover into a concrete, volatility-scaled trade plan (entry, stop, three take-profit tiers) with automatic on-chart tracking of which levels have been touched, plus JSON webhook payloads for each event so the signal can drive external automation without manual re-entry of parameters.

None of these layers is arbitrary window-dressing: the adaptive filter changes what "the trend" looks like, the confluence gate decides whether that trend is tradeable, and the trade-management layer answers the practical question of where to actually place risk once a decision has been made. Removing any one of the three would leave either a raw unfiltered oscillator, an unfiltered signal, or a signal with no execution framework.

🔬 Methodology and Concepts
• Williams Variable Accumulation/Distribution Core
For every bar, a raw pressure value is calculated as the bar's directional efficiency — (close − open) divided by the bar's full range (high − low) — multiplied by that bar's volume. This produces a signed, volume-weighted read of how much of the bar's traded volume pushed price toward its close relative to its open, scaled by how decisively the bar closed within its own range. This raw series is then summed over the WVAD Period using a simple moving average multiplied by the period length, which reconstructs a rolling total (rather than an average) of accumulated buying or selling pressure over that window — consistent with Williams' original "variable" accumulation/distribution concept, where the weighting factor varies bar to bar instead of using a fixed multiplier.

• Adaptive Filter Engine
The rolling WVAD sum is then optionally reshaped by one of eight selectable smoothing methods before it becomes the tool's working "WVAD" line:

[*]SMA / EMA / RMA — standard simple, exponential, and Wilder-style moving averages applied directly to the WVAD sum.
[*]Double WMA — a weighted moving average applied to the output of a first weighted moving average, compounding the weighting to reduce lag further than a single WMA pass.
[*]Triple VWMA — a volume-weighted moving average cascaded through itself three times, so the smoothing itself continues to lean on volume at each stage rather than only at the raw-pressure stage.
[*]HMA — a Hull Moving Average pass, used here for its reduced-lag response relative to standard averages.
[*]LLAMA — a proprietary in-house filter unique to this script. It combines a simple moving average of the WVAD sum with a linear extrapolation term: the average per-bar slope of the WVAD sum across the lookback window, scaled by half that window's length, is added back to the moving average. In practice this projects the average forward along its recent trend rather than leaving it lagging behind price the way a plain moving average would.
[*]Kalman Filter — also a proprietary, simplified single-state implementation rather than a textbook multi-variable Kalman filter. It maintains a running error estimate and a fixed process-noise term equal to the reciprocal of the selected length; on each bar it computes an adaptive gain from the ratio of predicted error to that error plus a fixed measurement-noise constant, then nudges its estimate toward the new WVAD value by that gain. Shorter lengths raise the process-noise term and make the filter react faster to new data; longer lengths make it progressively smoother and slower to adapt.

Selecting "None" bypasses this stage and the raw WVAD sum is used directly.

• Signal & Confluence Logic
A Signal Length moving average of the (optionally filtered) WVAD line produces the Signal line, and the difference between the two produces the histogram. A raw long or short bias is registered when the WVAD line crosses above or below its Signal line. That raw bias only becomes an active Long/Short signal when both confluence conditions pass: the ADX Filter, when enabled, requires the prior bar's ADX reading to be at or above the ADX Threshold before a crossover is accepted, filtering out signals born in low-trend-strength conditions; the HTF Confirmation filter, when enabled, requires the previous, fully closed candle on the selected higher timeframe to have closed bullish for long signals or bearish for short signals, filtering out crossovers that fight the higher-timeframe bias.

• Confirmation & Non-Repainting Design
The script is built so that no decision depends on data that has not yet closed. The crossover check itself compares the previous bar's WVAD and Signal values, the ADX gate reads the previous bar's confirmed ADX value, and the higher-timeframe request pulls the prior, already-closed candle on that timeframe rather than the currently forming one. Entry price for a new trade plan is likewise taken from the previous bar's close rather than the live price. Entry/exit alerts only fire once a bar is fully confirmed. One practical consequence worth understanding: because the crossover and entry reference both use the prior bar, there is a small, consistent one-bar delay between the moment the underlying pressure line actually crosses its signal and the bar on which the trade plan is drawn and the alert can fire — this is a deliberate confirmation design choice, not an inconsistency. Take-profit and stop-loss "hit" detection, by contrast, is checked against each bar's own intrabar high/low as it happens and can alert in real time, since that behavior simply reports a price touching an already-fixed level rather than altering a prior signal.

🎨 Visual Guide

• Oscillator Pane

[*]The WVAD line plots the (optionally adaptively filtered) pressure sum.
[*]The Signal line plots its moving average.
[*]The Histogram, drawn as columns, shows the difference between the two and cycles through four shades: a solid strong color when rising above zero, a faded shade when falling but still above zero, a solid opposite color when falling below zero, and a faded shade when rising but still below zero — giving an at-a-glance read of both direction and momentum change.
[*]A flat Zero Line marks the neutral pressure boundary.
[*]BULL and BEAR text markers appear directly on the oscillator at the bar where a confirmed long or short signal registers.

• Price Chart Overlay Elements
Several elements are pushed onto the main price chart even though the indicator's native pane is the oscillator below it:

[*]Heatmap Candles optionally recolor the actual price candles' bodies, wicks, and borders based on whether the WVAD line is above, below, or equal to its Signal line — turning the price chart itself into a running visual of the underlying bias.
[*]A second copy of the BULL/BEAR marker is placed directly below or above the corresponding price bar, so the signal is visible on the price chart without needing to also watch the oscillator pane.

• Trade Level Projection
When a confirmed signal fires (and levels are not locked), five horizontal lines and matching labels are drawn from the signal bar forward: the Stop-Loss line and label, the Entry line and label, and three Take-Profit lines and labels (TP1–TP3). A shaded Risk fill spans the zone between stop and entry, and a shaded Reward fill spans between entry and TP3, giving an immediate visual sense of the risk/reward geometry. All five lines automatically extend to the right as new bars form. Once a take-profit or stop level is touched, its label text updates in place to show a hit confirmation and the resulting percentage gain or loss from entry — the lines are not redrawn or repositioned, only the label text and the ongoing color state update.

• Dashboard Panel
An optional table (position configurable) summarizes, in real time: the symbol and timeframe, whether Lock Signal is active, the current directional Bias, the raw WVAD and Signal values, the Histogram value, a filled-bar Strength readout (WVAD magnitude relative to its own 100-bar high), current Volume and a filled-bar Volume Ratio (versus its 20-bar average), the Higher-Timeframe Bias (only shown when that filter is enabled), the current ADX reading (only shown when the ADX filter is enabled), the active Adaptive Filter name (only shown when one is selected), and the live Trade direction with Entry, SL, and TP1–TP3 prices, each recoloring once its corresponding level has been hit.

📖 How to Use

[*]Treat a WVAD-over-Signal cross, confirmed by a BULL/BEAR marker and matching histogram color flip, as the core directional bias; the heatmap candles offer the fastest visual confirmation of that same bias directly on price.
[*]Enable the ADX Filter to require a minimum trend-strength reading before a crossover is accepted — useful for avoiding signals generated during flat, low-conviction chop.
[*]Enable HTF Confirmation and choose a higher timeframe to only accept longs when that timeframe's last closed candle was bullish, and shorts when it was bearish — this narrows signals to those aligned with the broader trend context.
[*]Use the Adaptive Filter dropdown to trade off responsiveness against smoothness: SMA/EMA/RMA are the most transparent baseline options, Double WMA and Triple VWMA add extra lag reduction (the latter leaning more heavily on volume), HMA targets minimal lag, and LLAMA and Kalman Filter are the script's proprietary adaptive options for traders who want the smoothing itself to react to changing conditions rather than stay fixed.
[*]Lock Signal freezes the currently displayed trade-level lines and labels so a new opposite signal will not replace them while it is enabled; it does not stop new BULL/BEAR markers, histogram behavior, or alert conditions from continuing to register — it only holds the visual trade plan in place.
[*]The Entry price used for any trade plan is the previous bar's close, not the live price at the moment the signal appears, so real-world fills will vary from the plotted entry level depending on slippage and gap risk.
[*]Configure the Alerts group's action-tag fields to match whatever automation system consumes the webhook payloads, then build a TradingView alert on this script using "Any alert() function call" to receive the JSON messages for entries, exits, and each TP/SL event.

⚙️ Inputs and Settings

• Core Settings

[*]WVAD Period — the summation length for the raw Variable A/D pressure calculation.
[*]Signal Length — the moving-average length used to derive the Signal line from the (filtered) WVAD line.

• Filters

[*]Use HTF Confirmation / HTF Timeframe — enables the higher-timeframe directional gate and sets which timeframe it checks.
[*]Use ADX Filter / ADX Threshold / ADX Length — enables the trend-strength gate and sets its minimum qualifying reading and DMI length.
[*]Adaptive Filter / Adaptive Filter Length — selects which of the eight smoothing methods (or none) is applied to the WVAD sum, and its lookback length.

• Trade Tools

[*]Lock Signal — freezes the current trade-level projection against replacement by a new signal, as described above.
[*]Show Trade Levels — toggles whether entry/SL/TP lines, labels, and fills are drawn at all.
[*]SL × ATR — sets the stop distance as a multiple of ATR from the entry reference price.
[*]TP1 × R / TP2 × R / TP3 × R — set each take-profit distance as a multiple of the initial risk (R) defined by the stop distance.
[*]ATR Length — the lookback used for the ATR value driving stop and target distances.

• Visuals

[*]Show Histogram, Show WVAD/Signal Lines, Show Signal Markers, Show Zero Line, and Color Candles independently toggle each corresponding chart element described in the Visual Guide.

• Dashboard

[*]Show Dashboard and Position control whether the summary table is displayed and which corner it occupies.

• Alerts

[*]Long / Short / Close Long / Close Short Action and TP1 / TP2 / TP3 / SL Hit Action — free-text tags inserted into each event's JSON webhook payload (alongside ticker, timeframe, and relevant price fields) so external automation can route each message correctly.

Colors for every line, fill, label, candle state, and dashboard element are independently configurable and are purely cosmetic.

🔍 Deconstruction of the Underlying Scientific and Academic Framework
The foundation is Larry Williams' Variable Accumulation/Distribution concept: a price-volume flow measure in the same family as Chaikin's Accumulation/Distribution Line, but weighting each bar's volume by its own directional efficiency — (close − open)/(high − low) — rather than the Close Location Value used in Chaikin's version, making the "variable" weighting bar-specific rather than fixed.

The adaptive-smoothing stage draws on several established ideas from technical filtering theory: cascaded weighted and volume-weighted averaging (repeated WMA/VWMA passes) as a lag-reduction technique, Alan Hull's reduced-lag moving average construction, and the broader concept of adaptive filters that vary their responsiveness with market conditions rather than using a static weighting scheme — the category popularized by adaptive moving-average research such as Kaufman's work. Within that category, this script's LLAMA and Kalman Filter options are simplified, single-parameter, in-house approximations: LLAMA borrows the linear-extrapolation logic underlying least-squares/regression-adjusted moving averages (projecting a simple average forward using its own recent slope), while the Kalman Filter option implements a single-state recursive estimator in the spirit of Kalman filtering — updating an estimate and its error term each bar based on a fixed process/measurement noise ratio — rather than the multi-state, matrix-based formulation used in full Kalman filter implementations.

The ADX/DMI confluence gate is drawn from Welles Wilder's Directional Movement System, using ADX as a proxy for trend strength independent of direction. The higher-timeframe confirmation gate reflects standard multi-timeframe analysis practice, where aligning a lower-timeframe signal with a higher-timeframe directional read is used to reduce signals that contradict the broader trend. Finally, the ATR-based stop and R-multiple take-profit structure reflects standard volatility-adjusted position and risk management practice, sizing trade levels to each instrument's own recent average range rather than to a fixed point or percentage value.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator(title = "Williams Variable A/D Pressure [MarkitTick]", overlay = false, precision = 2, format = format.volume, max_labels_count = 500)

// ── INPUTS ─────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_wvadLen  = input.int(20, "WVAD Period", group = GRP_CORE, minval = 1, tooltip = "Summation length for Williams' Variable A/D")
i_sigLen   = input.int(9, "Signal Length", group = GRP_CORE, minval = 1)

var string GRP_FILT = "🕯️ Filters"
i_useHtf        = input.bool(false, "🕐 Use HTF Confirmation", group = GRP_FILT)
i_htfTf         = input.timeframe("60", "HTF Timeframe", group = GRP_FILT)
i_useAdxFilter  = input.bool(false, "📈 Use ADX Filter", group = GRP_FILT)
i_adxThresh     = input.float(20.0, "ADX Threshold", group = GRP_FILT, minval = 0, step = 0.5)
i_adxLen        = input.int(14, "ADX Length", group = GRP_FILT, minval = 1)
i_adaptFilterType = input.string("SMA", "🧠 Adaptive Filter", options = ["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group = GRP_FILT)
i_adaptFilterLen  = input.int(9, "Adaptive Filter Length", group = GRP_FILT, minval = 1, maxval = 500)

var string GRP_TRADE = "📐 Trade Tools"
i_lockSignal = input.bool(false, "🔒 Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_showLevels = input.bool(true, "Show Trade Levels", group = GRP_TRADE)
i_slMult     = input.float(1.5, "SL × ATR", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp1Mult    = input.float(1.0, "TP1 × R", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp2Mult    = input.float(2.0, "TP2 × R", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp3Mult    = input.float(3.0, "TP3 × R", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_atrLen     = input.int(14, "ATR Length", group = GRP_TRADE, minval = 1)

var string GRP_VIS = "🎨 Visuals"
i_showHist    = input.bool(true, "Show Histogram", group = GRP_VIS)
i_showLines   = input.bool(true, "Show WVAD/Signal Lines", group = GRP_VIS)
i_showMarkers = input.bool(true, "Show Signal Markers", group = GRP_VIS)
i_showZero    = input.bool(true, "Show Zero Line", group = GRP_VIS)
i_showCandles = input.bool(true, "Color Candles", group = GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
i_showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
i_dashPos  = input.string("Top Right", "Position", group = GRP_DASH, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

var string GRP_WH = "🔔 Alerts"
i_actionLong       = input.string("long", "↑ Long Action", group = GRP_WH)
i_actionShort      = input.string("short", "↓ Short Action", group = GRP_WH)
i_actionCloseLong  = input.string("closelong", "✕ Close Long Action", group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
i_actionTp1        = input.string("tp1", "◆ TP1 Hit Action", group = GRP_WH)
i_actionTp2        = input.string("tp2", "✦ TP2 Hit Action", group = GRP_WH)
i_actionTp3        = input.string("tp3", "◆ TP3 Hit Action", group = GRP_WH)
i_actionSl          = input.string("sl", "✕ SL Hit Action", group = GRP_WH)

var string GRP_COL = "🌈 Colors"
c_wvadLine    = input.color(color.new(#2196f3, 0), "WVAD Line", group = GRP_COL)
c_sigLine     = input.color(color.new(#ff9800, 0), "Signal Line", group = GRP_COL)
c_histUp1     = input.color(color.new(#26a69a, 0), "Hist Rising +", group = GRP_COL)
c_histUp2     = input.color(color.new(#26a69a, 60), "Hist Falling +", group = GRP_COL)
c_histDn1     = input.color(color.new(#ef5350, 0), "Hist Falling -", group = GRP_COL)
c_histDn2     = input.color(color.new(#ef5350, 60), "Hist Rising -", group = GRP_COL)
c_zeroLine    = input.color(color.new(#787b86, 50), "Zero Line", group = GRP_COL)
c_markerLong  = input.color(color.new(#26a69a, 0), "Long Marker", group = GRP_COL)
c_markerShort = input.color(color.new(#ef5350, 0), "Short Marker", group = GRP_COL)
c_markerTxt   = input.color(color.new(#ffffff, 0), "Signal Marker Text", group = GRP_COL)
c_candBullBody = input.color(color.new(#26a69a, 0), "Candle Bull Body", group = GRP_COL)
c_candBearBody = input.color(color.new(#ef5350, 0), "Candle Bear Body", group = GRP_COL)
c_candNeutBody = input.color(color.new(#787b86, 0), "Candle Neutral Body", group = GRP_COL)
c_candBullBrd  = input.color(color.new(#26a69a, 0), "Candle Bull Border", group = GRP_COL)
c_candBearBrd  = input.color(color.new(#ef5350, 0), "Candle Bear Border", group = GRP_COL)
c_candNeutBrd  = input.color(color.new(#787b86, 0), "Candle Neutral Border", group = GRP_COL)
c_slLevel      = input.color(color.new(#ef5350, 0), "SL Level", group = GRP_COL)
c_entryLevel   = input.color(color.new(#2196f3, 0), "Entry Level", group = GRP_COL)
c_tp1Level     = input.color(color.new(#26a69a, 40), "TP1 Level", group = GRP_COL)
c_tp2Level     = input.color(color.new(#26a69a, 20), "TP2 Level", group = GRP_COL)
c_tp3Level     = input.color(color.new(#26a69a, 0), "TP3 Level", group = GRP_COL)
c_riskFill     = input.color(color.new(#ef5350, 80), "Risk Fill", group = GRP_COL)
c_rewardFill   = input.color(color.new(#26a69a, 85), "Reward Fill", group = GRP_COL)
c_lvlTxt       = input.color(color.new(#ffffff, 0), "Level Label Text", group = GRP_COL)
C_DASH_HDR    = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL)
C_DASH_BG     = input.color(color.new(#0a0f1a, 10), "Dash Background", group = GRP_COL)
C_DASH_TXT    = input.color(color.new(#ffffff, 0), "Dash Text", group = GRP_COL)
C_SUP         = input.color(color.new(#26a69a, 0), "Bullish Value", group = GRP_COL)
C_RES         = input.color(color.new(#ef5350, 0), "Bearish Value", group = GRP_COL)

// ── CORE LOGIC ────────────────────────────────────────────
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

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(math.min(val / maxVal, 1.0) * 100)) + "%"

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_tf() =>
    string _u = str.substring(timeframe.period, str.length(timeframe.period) - 1, str.length(timeframe.period))
    float _tfNum = str.tonumber(timeframe.period)
    _u == "S" ? timeframe.period :
     _u == "D" ? timeframe.period :
     _u == "W" ? timeframe.period :
     _u == "M" ? timeframe.period :
     na(_tfNum) ? timeframe.period :
     _tfNum % 60 == 0 ? str.tostring(_tfNum / 60) + "H" :
     timeframe.period + "m"

f_num(float val) =>
    float _a = math.abs(val)
    string _s = val < 0 ? "-" : ""
    _a >= 1000000000 ? _s + str.tostring(_a / 1000000000, "#.#") + "B" :
     _a >= 1000000 ? _s + str.tostring(_a / 1000000, "#.#") + "M" :
     _a >= 1000 ? _s + str.tostring(_a / 1000, "#.#") + "K" :
     _s + str.tostring(_a, "#")

float rawWvad = high != low ? (close - open) / (high - low) * volume : 0.0
float wvadSum = ta.sma(rawWvad, i_wvadLen) * i_wvadLen
max_bars_back(wvadSum, 500)

float _adaptedSrc = i_adaptFilterType == "SMA"           ? f_sma(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "EMA"           ? f_ema(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "RMA"           ? f_rma(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA"    ? f_doubleWma(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA"   ? f_tripleVwma(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "HMA"           ? f_hma(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA"         ? f_llama(wvadSum, i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(wvadSum, i_adaptFilterLen) : wvadSum

float finalWvad = _adaptedSrc
float signalLine = ta.sma(finalWvad, i_sigLen)
float histWvad = finalWvad - signalLine

[_, __, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal[1] >= i_adxThresh

[htfClose, htfOpen] = request.security(syminfo.tickerid, i_htfTf, [close[1], open[1]], lookahead = barmerge.lookahead_on)
bool htfBullish = htfClose > htfOpen
bool htfBearish = htfClose < htfOpen
bool _htfPassLong  = not i_useHtf or htfBullish
bool _htfPassShort = not i_useHtf or htfBearish

bool _rawLongSignal  = ta.crossover(finalWvad[1], signalLine[1])
bool _rawShortSignal = ta.crossunder(finalWvad[1], signalLine[1])

bool longSignal  = _rawLongSignal  and _adxPass and _htfPassLong
bool shortSignal = _rawShortSignal and _adxPass and _htfPassShort

float avgVol = ta.sma(volume, 20)
float volRatio = avgVol > 0 ? volume / avgVol : 0.0
float volPct = avgVol > 0 ? math.min(volRatio / 2.0, 1.0) : 0.0

float strengthMax = ta.highest(math.abs(finalWvad), 100)
float strengthRaw = strengthMax > 0 ? math.abs(finalWvad) / strengthMax : 0.0

float _atr = ta.atr(i_atrLen)

var line slLine     = na
var line entryLine  = na
var line tp1Line    = na
var line tp2Line    = na
var line tp3Line    = na
var label slLbl     = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var linefill riskFill   = na
var linefill rewardFill = na

var float entryPrice = na
var float slPrice    = na
var float tp1Price   = na
var float tp2Price   = na
var float tp3Price   = na
var bool  isLong     = false
var bool  tp1Hit     = false
var bool  tp2Hit     = false
var bool  tp3Hit     = false
var bool  slHit      = false

bool _locked     = i_lockSignal and barstate.islast
bool _calcLevels = (longSignal or shortSignal) and not _locked
bool _drawLevels = i_showLevels and _calcLevels

var int _closeBar = na

f_pctTxt(float lvl, float entry, bool dir) =>
    float _p = (dir ? lvl - entry : entry - lvl) / entry * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"

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

if _calcLevels
    tp1Hit    := false
    tp2Hit    := false
    tp3Hit    := false
    slHit     := false
    _closeBar := na
    isLong     := longSignal
    entryPrice := close[1]
    float _risk = _atr[1] * i_slMult
    slPrice  := longSignal ? close[1] - _risk : close[1] + _risk
    tp1Price := longSignal ? close[1] + _risk * i_tp1Mult : close[1] - _risk * i_tp1Mult
    tp2Price := longSignal ? close[1] + _risk * i_tp2Mult : close[1] - _risk * i_tp2Mult
    tp3Price := longSignal ? close[1] + _risk * i_tp3Mult : close[1] - _risk * i_tp3Mult

bool _tp1Cross = not na(tp1Price) and (isLong ? high >= tp1Price : low  <= tp1Price)
bool _tp2Cross = not na(tp2Price) and (isLong ? high >= tp2Price : low  <= tp2Price)
bool _tp3Cross = not na(tp3Price) and (isLong ? high >= tp3Price : low  <= tp3Price)
bool _slCross  = not na(slPrice)  and (isLong ? low  <= slPrice  : high >= slPrice)

bool _tp1Fire = not na(tp1Price) and not tp1Hit and not slHit and _tp1Cross
bool _tp2Fire = not na(tp2Price) and not tp2Hit and not slHit and _tp2Cross
bool _tp3Fire = not na(tp3Price) and not tp3Hit and not slHit and _tp3Cross
bool _slFire  = not na(slPrice)  and not slHit  and _slCross

// ── ALERTS ────────────────────────────────────────────────
string _longInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","wvad":"{4}","signal":"{5}"',
 i_actionLong, syminfo.tickerid, timeframe.period,
 str.tostring(entryPrice, format.mintick),
 str.tostring(finalWvad, format.mintick),
 str.tostring(signalLine, format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","wvad":"{4}","signal":"{5}"',
 i_actionShort, syminfo.tickerid, timeframe.period,
 str.tostring(entryPrice, format.mintick),
 str.tostring(finalWvad, format.mintick),
 str.tostring(signalLine, format.mintick))
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
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)

alertcondition(longSignal  and barstate.isconfirmed, "BUY Signal",         "MarkitTick — WVADP BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick — WVADP SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(longSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")

string _tpDir = isLong ? "long" : "short"
string _tp1Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"',
 i_actionTp1, syminfo.tickerid, timeframe.period, _tpDir,
 str.tostring(entryPrice, format.mintick),
 str.tostring(tp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"

string _tp2Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"',
 i_actionTp2, syminfo.tickerid, timeframe.period, _tpDir,
 str.tostring(entryPrice, format.mintick),
 str.tostring(tp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"

string _tp3Inner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"',
 i_actionTp3, syminfo.tickerid, timeframe.period, _tpDir,
 str.tostring(entryPrice, format.mintick),
 str.tostring(tp3Price, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

string _slInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","sl":"{5}"',
 i_actionSl, syminfo.tickerid, timeframe.period, _tpDir,
 str.tostring(entryPrice, format.mintick),
 str.tostring(slPrice, format.mintick))
string slPayload = "{" + _slInner + "}"

if _tp1Fire
    alert(tp1Payload, alert.freq_once_per_bar)
if _tp2Fire
    alert(tp2Payload, alert.freq_once_per_bar)
if _tp3Fire
    alert(tp3Payload, alert.freq_once_per_bar)
if _slFire
    alert(slPayload, alert.freq_once_per_bar)

alertcondition(_tp1Fire, "TP1 Hit", "MarkitTick — WVADP TP1 Hit")
alertcondition(_tp2Fire, "TP2 Hit", "MarkitTick — WVADP TP2 Hit")
alertcondition(_tp3Fire, "TP3 Hit", "MarkitTick — WVADP TP3 Hit")
alertcondition(_slFire, "SL Hit", "MarkitTick — WVADP SL Hit")

// ── VISUALS ───────────────────────────────────────────────
color _histColor = histWvad >= 0 ? (histWvad >= histWvad[1] ? c_histUp1 : c_histUp2) : (histWvad <= histWvad[1] ? c_histDn1 : c_histDn2)
plot(i_showZero ? 0.0 : na, "Zero Line", color = c_zeroLine, style = plot.style_line, linewidth = 1)
plot(i_showHist ? histWvad : na, "Histogram", color = _histColor, style = plot.style_columns)
plot(i_showLines ? finalWvad : na, "WVAD", color = c_wvadLine, linewidth = 2)
plot(i_showLines ? signalLine : na, "Signal", color = c_sigLine, linewidth = 1)
if i_showMarkers and longSignal
    label.new(bar_index, finalWvad, "BULL", style = label.style_label_up, color = c_markerLong, textcolor = c_markerTxt, size = size.small)
    label.new(bar_index, na, "BULL", yloc = yloc.belowbar, style = label.style_label_up, color = c_markerLong, textcolor = c_markerTxt, size = size.small, force_overlay = true)
if i_showMarkers and shortSignal
    label.new(bar_index, finalWvad, "BEAR", style = label.style_label_down, color = c_markerShort, textcolor = c_markerTxt, size = size.small)
    label.new(bar_index, na, "BEAR", yloc = yloc.abovebar, style = label.style_label_down, color = c_markerShort, textcolor = c_markerTxt, size = size.small, force_overlay = true)
color _candleBody   = finalWvad > signalLine ? c_candBullBody : finalWvad < signalLine ? c_candBearBody : c_candNeutBody
color _candleBorder = finalWvad > signalLine ? c_candBullBrd  : finalWvad < signalLine ? c_candBearBrd  : c_candNeutBrd
plotcandle(i_showCandles ? open : na, i_showCandles ? high : na, i_showCandles ? low : na, i_showCandles ? close : na,
 title         = "Heatmap Candles",
 color         = _candleBody,
 wickcolor     = _candleBorder,
 bordercolor   = _candleBorder,
 force_overlay = true)

if _drawLevels
    f_deleteLevels()
    int _x2 = bar_index + 10
    slLine    := line.new(bar_index, slPrice,    _x2, slPrice,    color = c_slLevel,    style = line.style_solid,  width = 2, force_overlay = true)
    entryLine := line.new(bar_index, entryPrice, _x2, entryPrice, color = c_entryLevel, style = line.style_dashed, width = 1, force_overlay = true)
    tp1Line   := line.new(bar_index, tp1Price,   _x2, tp1Price,   color = c_tp1Level,   style = line.style_dashed, width = 1, force_overlay = true)
    tp2Line   := line.new(bar_index, tp2Price,   _x2, tp2Price,   color = c_tp2Level,   style = line.style_dashed, width = 1, force_overlay = true)
    tp3Line   := line.new(bar_index, tp3Price,   _x2, tp3Price,   color = c_tp3Level,   style = line.style_dashed, width = 1, force_overlay = true)
    slLbl    := label.new(_x2, slPrice,    "✕ SL "    + str.tostring(slPrice,    format.mintick), style = label.style_label_left, color = c_slLevel,    textcolor = c_lvlTxt, size = size.small, force_overlay = true)
    entryLbl := label.new(_x2, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = c_entryLevel, textcolor = c_lvlTxt, size = size.small, force_overlay = true)
    tp1Lbl   := label.new(_x2, tp1Price,   "◆ TP1 "   + str.tostring(tp1Price,   format.mintick), style = label.style_label_left, color = c_tp1Level,   textcolor = c_lvlTxt, size = size.small, force_overlay = true)
    tp2Lbl   := label.new(_x2, tp2Price,   "✦ TP2 "   + str.tostring(tp2Price,   format.mintick), style = label.style_label_left, color = c_tp2Level,   textcolor = c_lvlTxt, size = size.small, force_overlay = true)
    tp3Lbl   := label.new(_x2, tp3Price,   "◆ TP3 "   + str.tostring(tp3Price,   format.mintick), style = label.style_label_left, color = c_tp3Level,   textcolor = c_lvlTxt, size = size.small, force_overlay = true)
    riskFill   := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)

if _tp1Fire
    tp1Hit := true
    label.set_text(tp1Lbl, "TP1 ✓ HIT " + f_pctTxt(tp1Price, entryPrice, isLong))
if _tp2Fire
    tp2Hit := true
    label.set_text(tp2Lbl, "TP2 ✓ HIT " + f_pctTxt(tp2Price, entryPrice, isLong))
if _tp3Fire
    tp3Hit := true
    label.set_text(tp3Lbl, "TP3 ✓ HIT " + f_pctTxt(tp3Price, entryPrice, isLong))
if _slFire
    slHit := true
    label.set_text(slLbl, "SL ✓ HIT " + f_pctTxt(slPrice, entryPrice, isLong))

bool _tradeClosed = slHit or tp3Hit
if not na(slLine) and _tradeClosed and na(_closeBar)
    _closeBar := bar_index

bool _extUpdate = _tradeClosed ? _closeBar == bar_index : barstate.islast
if not na(slLine) and _extUpdate
    int _extX = _tradeClosed ? _closeBar + 10 : last_bar_index + 10
    line.set_x2(slLine,    _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line,   _extX)
    line.set_x2(tp2Line,   _extX)
    line.set_x2(tp3Line,   _extX)
    label.set_x(slLbl,     _extX)
    label.set_x(entryLbl,  _extX)
    label.set_x(tp1Lbl,    _extX)
    label.set_x(tp2Lbl,    _extX)
    label.set_x(tp3Lbl,    _extX)

// ── DASHBOARD ─────────────────────────────────────────────
var string tablePosition = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(tablePosition, 2, 18, bgcolor = na, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40), force_overlay = true)

color row_a = C_DASH_BG
color row_b = color.new(C_DASH_BG, 40)
color lbl_col = color.new(C_DASH_TXT, 25)

string biasStr = finalWvad > signalLine ? "BULLISH  " : finalWvad < signalLine ? "BEARISH  " : "NEUTRAL  "
color biasColor = finalWvad > signalLine ? C_SUP : finalWvad < signalLine ? C_RES : C_DASH_TXT
color wvadColor = finalWvad >= 0 ? C_SUP : C_RES
color histColorTxt = histWvad >= 0 ? C_SUP : C_RES
string htfBiasStr = not i_useHtf ? "OFF  " : htfBullish ? "BULL  " : htfBearish ? "BEAR  " : "FLAT  "
color htfColor = not i_useHtf ? C_DASH_TXT : htfBullish ? C_SUP : htfBearish ? C_RES : C_DASH_TXT
color adxColor = _adxPass ? C_SUP : C_RES
string lockStr  = i_lockSignal ? "ACTIVE  " : "OFF  "
color  lockCol  = i_lockSignal ? C_RES : C_DASH_TXT
string tradeStr = na(entryPrice) ? "—  " : isLong ? "LONG  " : "SHORT  "
color  tradeCol = na(entryPrice) ? C_DASH_TXT : isLong ? C_SUP : C_RES
string entryStr = na(entryPrice) ? "—  " : str.tostring(entryPrice, format.mintick) + "  "
string slStr    = na(slPrice)  ? "—  " : str.tostring(slPrice,  format.mintick) + "  "
string tp1Str   = na(tp1Price) ? "—  " : str.tostring(tp1Price, format.mintick) + "  "
string tp2Str   = na(tp2Price) ? "—  " : str.tostring(tp2Price, format.mintick) + "  "
string tp3Str   = na(tp3Price) ? "—  " : str.tostring(tp3Price, format.mintick) + "  "
color  slCol    = slHit  ? C_RES : C_DASH_TXT
color  tp1Col   = tp1Hit ? C_SUP : C_DASH_TXT
color  tp2Col   = tp2Hit ? C_SUP : C_DASH_TXT
color  tp3Col   = tp3Hit ? C_SUP : C_DASH_TXT

if i_showDash
    table.cell(dash, 0, 0, "WVADP", text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_HDR)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + f_tf(), text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = C_DASH_HDR)

    table.cell(dash, 0, 1, "  Lock", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_a)
    table.cell(dash, 1, 1, lockStr, text_color = lockCol, text_size = size.small, text_halign = text.align_right, bgcolor = row_a)

    table.cell(dash, 0, 2, "  Bias", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_b)
    table.cell(dash, 1, 2, biasStr, text_color = biasColor, text_size = size.small, text_halign = text.align_right, bgcolor = row_b)

    table.cell(dash, 0, 3, "  WVAD", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_a)
    table.cell(dash, 1, 3, str.tostring(finalWvad, "#.##") + "  ", text_color = wvadColor, text_size = size.small, text_halign = text.align_right, bgcolor = row_a)

    table.cell(dash, 0, 4, "  Signal", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_b)
    table.cell(dash, 1, 4, str.tostring(signalLine, "#.##") + "  ", text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = row_b)

    table.cell(dash, 0, 5, "  Histogram", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_a)
    table.cell(dash, 1, 5, str.tostring(histWvad, "#.##") + "  ", text_color = histColorTxt, text_size = size.small, text_halign = text.align_right, bgcolor = row_a)

    table.cell(dash, 0, 6, "  Strength", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_b)
    table.cell(dash, 1, 6, f_bar(strengthRaw, 1.0) + "  ", text_color = f_barColor(strengthRaw), text_size = size.small, text_halign = text.align_right, bgcolor = row_b)

    table.cell(dash, 0, 7, "  Volume", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_a)
    table.cell(dash, 1, 7, f_num(volume) + "  ", text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = row_a)

    table.cell(dash, 0, 8, "  Vol Ratio", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = row_b)
    table.cell(dash, 1, 8, f_bar(volRatio, 2.0) + "  ", text_color = f_barColor(volPct), text_size = size.small, text_halign = text.align_right, bgcolor = row_b)

    int _row = 9

    if i_useHtf
        color _rowBg = _row % 2 == 1 ? row_a : row_b
        table.cell(dash, 0, _row, "  HTF Bias", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBg)
        table.cell(dash, 1, _row, htfBiasStr, text_color = htfColor, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBg)
        _row += 1

    if i_useAdxFilter
        color _rowBg = _row % 2 == 1 ? row_a : row_b
        table.cell(dash, 0, _row, "  ADX", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBg)
        table.cell(dash, 1, _row, str.tostring(_adxVal, "#.##") + "  ", text_color = adxColor, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBg)
        _row += 1

    if i_adaptFilterType != "None"
        color _rowBg = _row % 2 == 1 ? row_a : row_b
        table.cell(dash, 0, _row, "  Adapt Filter", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBg)
        table.cell(dash, 1, _row, i_adaptFilterType + "  ", text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBg)
        _row += 1

    color _rowBgTrade = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  Trade", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgTrade)
    table.cell(dash, 1, _row, tradeStr, text_color = tradeCol, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgTrade)
    _row += 1

    color _rowBgEntry = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  Entry", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgEntry)
    table.cell(dash, 1, _row, entryStr, text_color = C_DASH_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgEntry)
    _row += 1

    color _rowBgSl = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  SL", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgSl)
    table.cell(dash, 1, _row, slStr, text_color = slCol, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgSl)
    _row += 1

    color _rowBgTp1 = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  TP1", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgTp1)
    table.cell(dash, 1, _row, tp1Str, text_color = tp1Col, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgTp1)
    _row += 1

    color _rowBgTp2 = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  TP2", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgTp2)
    table.cell(dash, 1, _row, tp2Str, text_color = tp2Col, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgTp2)
    _row += 1

    color _rowBgTp3 = _row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, _row, "  TP3", text_color = lbl_col, text_size = size.small, text_halign = text.align_left, bgcolor = _rowBgTp3)
    table.cell(dash, 1, _row, tp3Str, text_color = tp3Col, text_size = size.small, text_halign = text.align_right, bgcolor = _rowBgTp3)
    _row += 1
````
