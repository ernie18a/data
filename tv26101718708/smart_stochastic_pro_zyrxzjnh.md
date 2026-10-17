# Smart Stochastic Pro

- url: https://www.tradingview.com/script/ZyRXZJnH-Smart-Stochastic-Pro/
- type: indicator
- pine_id: PUB;45ad5e9cfc244bc4a4c2582905a611ea
- version: 1.0

## Description

smart stochastic pro is a momentum oscillator built to read stochastic structure, buying and selling pressure, and multi-timeframe bias in one clean panel.

the script is designed for traders who want a visual way to track when the market is stretched, when pressure starts to shift, and when a reversal setup becomes more interesting. it does not predict price and it should not be used alone. it is meant to support analysis together with price action, market structure, support and resistance, volume, and risk management.

what the script does

smart stochastic pro uses a smoothed stochastic engine to create rounded %k and %d curves. the goal is to reduce visual noise while keeping the oscillator responsive enough for intraday and swing analysis.

the script includes:

* a smoothed stochastic %k and %d
* extreme overbought and oversold zones
* buying and selling pressure based on candle position and volume
* optional mtf calculation modes
* reversal detection after extreme zones
* optional candle coloring
* a compact dashboard
* visual pressure zones and signal labels

how to use it

add the script to a normal candlestick chart. for the clearest reading, start with the default settings and use a liquid market such as major crypto pairs, forex pairs, indices, or large-cap stocks.

the oscillator moves between 0 and 100.

basic reading:

* above 80 means price is in an overbought area
* below 20 means price is in an oversold area
* above 90 means extreme overbought
* below 10 means extreme oversold
* the 50 line is the neutral zone
* %k above %d shows bullish momentum
* %k below %d shows bearish momentum

the script works best when you do not take every cross. the main idea is to wait for a strong area first, then look for a confirmed shift.

beginner workflow

1. start on the chart mode

use:

calculation / visual mode: chart

this uses the current chart timeframe and is the easiest mode to understand.

2. wait for an extreme zone

for bullish setups, watch for %k to move into the extreme oversold area.

for bearish setups, watch for %k to move into the extreme overbought area.

this arms the setup. it does not mean enter immediately.

3. wait for confirmation

a bullish reversal becomes more interesting when:

* %k crosses above %d
* the oscillator starts rising
* buying pressure improves
* the signal appears after an oversold expansion

a bearish reversal becomes more interesting when:

* %k crosses below %d
* the oscillator starts falling
* selling pressure improves
* the signal appears after an overbought expansion

4. check the pressure

the pressure background and ribbons help show whether buyers or sellers are gaining control.

green pressure means buying is stronger.

red pressure means selling is stronger.

neutral pressure means the market may still be undecided.

5. use the dashboard

the dashboard summarizes:

* active mode
* current bias
* mtf bias
* slope
* oscillator zone
* buying or selling pressure
* %k and %d values
* signal strength
* armed state

for beginners, the most useful dashboard rows are state, zone, pressure, and armed.

recommended settings

for beginners:

* calculation / visual mode: chart
* require explosion first: true
* minimum confluence strength: 2
* hide mid-range noise: true
* show pressure: true
* show dashboard: true
* candle color: off at first

for cleaner signals:

* require explosion first: true
* minimum confluence strength: 3
* hide mid-range noise: true
* mtf bias filters signals: true

for faster signals:

* require explosion first: false
* minimum confluence strength: 2
* hide mid-range noise: true

for multi-timeframe use:

mtf strict shows the oscillator calculated directly from the selected higher timeframe.

mtf bias keeps the chart oscillator smoother while using the higher timeframe as a directional filter.

a simple setup is:

* chart timeframe: 5m or 15m
* mtf timeframe: 1h
* mtf bias filters signals: true

where to use it

the script can be used on:

* crypto
* forex
* indices
* stocks
* futures

it is usually cleaner on markets with good liquidity and enough volume. low-volume markets can create noisy pressure readings and weaker signal quality.

timeframes

for scalping, try 1m to 5m, but expect more noise.

for intraday trading, 5m to 30m is usually easier to read.

for swing trading, 1h to 4h gives slower but cleaner signals.

how not to use it

do not buy only because the oscillator is oversold.

do not sell only because the oscillator is overbought.

do not use one signal without checking market structure.

do not use it as a guaranteed entry system.

do not ignore risk management.

best practice

use the script as a timing and confirmation tool.

a stronger bullish setup usually has:

* price near support or after a liquidity sweep
* %k coming from oversold or extreme oversold
* buying pressure improving
* bullish signal strength at least 2 or 3
* mtf bias not fighting the trade

a stronger bearish setup usually has:

* price near resistance or after a failed breakout
* %k coming from overbought or extreme overbought
* selling pressure improving
* bearish signal strength at least 2 or 3
* mtf bias not fighting the trade

alerts

alerts are available for:

* bullish reversal after extreme oversold
* bearish reversal after extreme overbought
* extreme oversold
* extreme overbought
* pressure flip bullish
* pressure flip bearish

use alerts as reminders to check the chart, not as automatic trade entries.

notes

this script is an analysis tool. it does not guarantee results. all signals should be reviewed with price action, trend context, volatility, and personal risk rules before making a trade decision.

## Source Code

````pine
// ============================================================================
//
//       █████╗ ██╗     ██████╗ ██╗  ██╗ █████╗
//      ██╔══██╗██║     ██╔══██╗██║  ██║██╔══██╗
//      ███████║██║     ██████╔╝███████║███████║
//      ██╔══██║██║     ██╔═══╝ ██╔══██║██╔══██║
//      ██║  ██║███████╗██║     ██║  ██║██║  ██║
//      ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝
//
//      ██╗    ██╗██╗███████╗ █████╗ ██████╗ ██████╗
//      ██║    ██║██║╚══███╔╝██╔══██╗██╔══██╗██╔══██╗
//      ██║ █╗ ██║██║  ███╔╝ ███████║██████╔╝██║  ██║
//      ██║███╗██║██║ ███╔╝  ██╔══██║██╔══██╗██║  ██║
//      ╚███╔███╔╝██║███████╗██║  ██║██║  ██║██████╔╝
//       ╚══╝╚══╝ ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝
//
//               @ A L P H A   W I Z A R D
//
// ============================================================================

//@version=6

// ============================================================================
indicator("Smart Stochastic Pro", overlay = false, precision = 2, max_labels_count = 500)

// =========================== INPUTS — MTF MODE ===============================
g0 = "MTF MODE"

mtfMode = input.string(
     "Chart",
     "Calculation / Visual Mode",
     options = ["Chart", "MTF Strict", "MTF Bias"],
     group = g0,
     tooltip = "Chart = calcul normal. MTF Strict = lignes HTF exactes. MTF Bias = lignes chart fluides avec biais HTF."
)

mtfTf = input.timeframe("60", "MTF Timeframe", group = g0)

mtfBiasFilterSignals = input.bool(false, "MTF Bias Filters Signals", group = g0)
mtfSlopeFilterSignals = input.bool(false, "MTF Slope Filters Signals", group = g0)

// =========================== INPUTS — MOTEUR ================================
g1 = "STOCHASTIC ENGINE"

kLen     = input.int(14, "%K Length", minval = 1, group = g1)
kSmooth  = input.int(3, "%K Smoothing 1", minval = 1, group = g1)
kSmooth2 = input.int(3, "%K Smoothing 2", minval = 1, group = g1, tooltip = "Double lissage = courbes en dômes arrondis.")
dLen     = input.int(3, "%D Signal Length", minval = 1, group = g1)

// =========================== INPUTS — NIVEAUX ===============================
g2 = "LEVELS"

lvlExtOB = input.float(90, "Extreme Overbought (explosion)", group = g2)
lvlOB    = input.float(80, "Overbought", group = g2)
lvlMid   = input.float(50, "Midline", group = g2)
lvlOS    = input.float(20, "Oversold", group = g2)
lvlExtOS = input.float(10, "Extreme Oversold (explosion)", group = g2)

// =========================== INPUTS — PRESSION ==============================
g3 = "BUYING / SELLING PRESSURE"

showPres  = input.bool(true, "Show Pressure", group = g3)
presLen   = input.int(14, "Pressure Smoothing", minval = 1, group = g3)
presBoost = input.float(1.5, "Pressure Visual Boost", minval = 0.5, maxval = 4.0, step = 0.1, group = g3)

// =========================== INPUTS — SIGNAUX ===============================
g4 = "REVERSAL DETECTION"

useArmLogic   = input.bool(true, "Require Explosion First", group = g4)
armWindow     = input.int(8, "Arming Window (bars)", minval = 1, maxval = 50, group = g4)
minStrength   = input.int(2, "Minimum Confluence Strength", minval = 1, maxval = 4, group = g4)
hideMidNoise  = input.bool(true, "Hide Mid-Range Noise", group = g4)
showTinySignals = input.bool(true, "Show Tiny Signal Labels", group = g4)

// =========================== INPUTS — CANDLE COLOR ==========================
g6 = "CANDLE COLOR MODE"

showCandleColor = input.bool(false, "Enable Candle Color Bull/Bear", group = g6)

candleColorSource = input.string(
     "Active Mode Bias",
     "Candle Color Source",
     options = ["Active Mode Bias", "Chart Bias", "MTF Bias"],
     group = g6
)

candleColorLogic = input.string(
     "Bias",
     "Candle Color Logic",
     options = ["Bias", "Signal Only", "Armed", "Pressure"],
     group = g6
)

candleColorTransp = input.int(0, "Candle Color Transparency", minval = 0, maxval = 100, group = g6)

// =========================== INPUTS — STYLE =================================
g5 = "AESTHETIC / COLORS"

darkBg   = input.bool(true, "Black Background", group = g5)
colBull  = input.color(#00E676, "Bull Color (green)", group = g5)
colBear  = input.color(#FF1744, "Bear Color (red)", group = g5)
colK     = input.color(#26C6DA, "%K Line (cyan)", group = g5)
colD     = input.color(#E91E63, "%D Signal (magenta)", group = g5)
colMid   = input.color(#546E7A, "Midline Color", group = g5)
colLvl   = input.color(#37474F, "Level Lines", group = g5)
glow     = input.bool(true, "Glow Effect on %K", group = g5)
dynamicK = input.bool(true, "Dynamic %K Bull/Bear Color", group = g5)
showDash = input.bool(true, "Show Dashboard", group = g5)

// ================================ ENGINE ====================================
f_engine() =>
    float _rawK = ta.stoch(close, high, low, kLen)
    float _k = ta.ema(ta.ema(_rawK, kSmooth), kSmooth2)
    float _d = ta.sma(_k, dLen)

    float _range = math.max(high - low, syminfo.mintick)
    float _buyRaw = (close - low) / _range
    float _sellRaw = (high - close) / _range
    float _volMa = ta.sma(volume, 20)
    float _volNorm = _volMa > 0 ? volume / _volMa : 1.0

    float _buyPow = ta.ema(_buyRaw * _volNorm, presLen) * 100
    float _sellPow = ta.ema(_sellRaw * _volNorm, presLen) * 100
    float _netPres = _buyPow - _sellPow

    float _kSlope = _k - _k[1]
    float _dSlope = _d - _d[1]

    bool _kRising = _k > _k[1] and _k[1] > _k[2]
    bool _kFalling = _k < _k[1] and _k[1] < _k[2]

    var int _armedBearBar = na
    var int _armedBullBar = na

    if _k >= lvlExtOB
        _armedBearBar := bar_index

    if _k <= lvlExtOS
        _armedBullBar := bar_index

    bool _armedBear = not na(_armedBearBar) and (bar_index - _armedBearBar) <= armWindow
    bool _armedBull = not na(_armedBullBar) and (bar_index - _armedBullBar) <= armWindow

    bool _bearCross = ta.crossunder(_k, _d)
    bool _bullCross = ta.crossover(_k, _d)

    int _bearStr = 0
    if _bearCross
        _bearStr += 1
    if _armedBear or _k >= lvlOB
        _bearStr += 1
    if _kFalling
        _bearStr += 1
    if _netPres < 0
        _bearStr += 1

    int _bullStr = 0
    if _bullCross
        _bullStr += 1
    if _armedBull or _k <= lvlOS
        _bullStr += 1
    if _kRising
        _bullStr += 1
    if _netPres > 0
        _bullStr += 1

    bool _inMidNoise = _k > 40 and _k < 60

    bool _explosionFilterBear = useArmLogic ? _armedBear : true
    bool _explosionFilterBull = useArmLogic ? _armedBull : true
    bool _noiseFilter = hideMidNoise ? not _inMidNoise : true

    bool _bearSignal = _bearCross and _explosionFilterBear and _bearStr >= minStrength and _noiseFilter
    bool _bullSignal = _bullCross and _explosionFilterBull and _bullStr >= minStrength and _noiseFilter

    if _bearSignal
        _armedBearBar := na

    if _bullSignal
        _armedBullBar := na

    bool _bullBias = _k > lvlMid and _k > _d and _netPres > 0
    bool _bearBias = _k < lvlMid and _k < _d and _netPres < 0

    bool _slopeBull = _kSlope > 0 and _dSlope >= 0
    bool _slopeBear = _kSlope < 0 and _dSlope <= 0

    [_rawK, _k, _d, _buyPow, _sellPow, _netPres, _kSlope, _dSlope, _kRising, _kFalling, _armedBear, _armedBull, _bearStr, _bullStr, _bearSignal, _bullSignal, _bullBias, _bearBias, _slopeBull, _slopeBear]

// ================================ VALUES ====================================
[rawK_chart, k_chart, d_chart, buyPow_chart, sellPow_chart, netPres_chart, kSlope_chart, dSlope_chart, kRising_chart, kFalling_chart, armedBear_chart, armedBull_chart, bearStr_chart, bullStr_chart, bearSignalRaw_chart, bullSignalRaw_chart, bullBias_chart, bearBias_chart, slopeBull_chart, slopeBear_chart] = f_engine()

[rawK_mtf, k_mtf, d_mtf, buyPow_mtf, sellPow_mtf, netPres_mtf, kSlope_mtf, dSlope_mtf, kRising_mtf, kFalling_mtf, armedBear_mtf, armedBull_mtf, bearStr_mtf, bullStr_mtf, bearSignalRaw_mtf, bullSignalRaw_mtf, bullBias_mtf, bearBias_mtf, slopeBull_mtf, slopeBear_mtf] = request.security(
     syminfo.tickerid,
     mtfTf,
     f_engine(),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

// Active visual mode
bool isChartMode = mtfMode == "Chart"
bool isMtfStrict = mtfMode == "MTF Strict"
bool isMtfBias = mtfMode == "MTF Bias"

// Plot values
raw_k = isMtfStrict ? rawK_mtf : rawK_chart
k = isMtfStrict ? k_mtf : k_chart
d = isMtfStrict ? d_mtf : d_chart
buyPow = isMtfStrict ? buyPow_mtf : buyPow_chart
sellPow = isMtfStrict ? sellPow_mtf : sellPow_chart
netPres = isMtfStrict ? netPres_mtf : netPres_chart
kSlope = isMtfStrict ? kSlope_mtf : kSlope_chart
dSlope = isMtfStrict ? dSlope_mtf : dSlope_chart
kRising = isMtfStrict ? kRising_mtf : kRising_chart
kFalling = isMtfStrict ? kFalling_mtf : kFalling_chart
armedBear = isMtfStrict ? armedBear_mtf : armedBear_chart
armedBull = isMtfStrict ? armedBull_mtf : armedBull_chart
bearStr = isMtfStrict ? bearStr_mtf : bearStr_chart
bullStr = isMtfStrict ? bullStr_mtf : bullStr_chart

// Bias source
activeBullBias = isMtfBias ? bullBias_mtf : isMtfStrict ? bullBias_mtf : bullBias_chart
activeBearBias = isMtfBias ? bearBias_mtf : isMtfStrict ? bearBias_mtf : bearBias_chart
activeSlopeBull = isMtfBias ? slopeBull_mtf : isMtfStrict ? slopeBull_mtf : slopeBull_chart
activeSlopeBear = isMtfBias ? slopeBear_mtf : isMtfStrict ? slopeBear_mtf : slopeBear_chart

// Signals
baseBearSignalRaw = isMtfStrict ? bearSignalRaw_mtf : bearSignalRaw_chart
baseBullSignalRaw = isMtfStrict ? bullSignalRaw_mtf : bullSignalRaw_chart

baseBearSignal = baseBearSignalRaw and not baseBearSignalRaw[1]
baseBullSignal = baseBullSignalRaw and not baseBullSignalRaw[1]

bullSignal =
     baseBullSignal and
     (not mtfBiasFilterSignals or activeBullBias) and
     (not mtfSlopeFilterSignals or activeSlopeBull)

bearSignal =
     baseBearSignal and
     (not mtfBiasFilterSignals or activeBearBias) and
     (not mtfSlopeFilterSignals or activeSlopeBear)

// ============================== BACKGROUND ==================================
bgcolor(darkBg ? color.new(#000000, 0) : na)

presIntensity = math.min(math.abs(netPres) * presBoost, 100)
presBgTransp = math.max(96 - presIntensity / 3, 80)

bgcolor(
     showPres ?
         netPres > 5 ? color.new(colBull, presBgTransp) :
         netPres < -5 ? color.new(colBear, presBgTransp) :
         na
     : na
)

// ============================ NIVEAUX / GRILLE ==============================
hline(100, "Top", color = color.new(colLvl, 60))
hExtOB = hline(lvlExtOB, "Extreme OB", color = color.new(colBear, 50), linestyle = hline.style_dotted)
hOB = hline(lvlOB, "OB", color = color.new(colBear, 30))
hMid = hline(lvlMid, "Mid", color = color.new(colMid, 0))
hOS = hline(lvlOS, "OS", color = color.new(colBull, 30))
hExtOS = hline(lvlExtOS, "Extreme OS", color = color.new(colBull, 50), linestyle = hline.style_dotted)
hline(0, "Bottom", color = color.new(colLvl, 60))

hTop = hline(100, "", color = color.new(#000000, 100), display = display.none)
hBot = hline(0, "", color = color.new(#000000, 100), display = display.none)

fill(hOB, hTop, top_value = 100, bottom_value = lvlOB, top_color = color.new(colBear, 75), bottom_color = color.new(colBear, 95), title = "OB Zone Tint")
fill(hOS, hBot, top_value = lvlOS, bottom_value = 0, top_color = color.new(colBull, 95), bottom_color = color.new(colBull, 75), title = "OS Zone Tint")

// ==================== BULL / BEAR DOMES =====================================
bullTop = plot(math.max(k, lvlMid), "bullTop", display = display.none)
bullBase = plot(lvlMid, "bullBase", display = display.none)

fill(
     bullTop,
     bullBase,
     top_value = 100,
     bottom_value = lvlMid,
     top_color = color.new(colBull, 20),
     bottom_color = color.new(colBull, 92),
     title = "Bull Dome"
)

bearTop = plot(lvlMid, "bearTop", display = display.none)
bearBase = plot(math.min(k, lvlMid), "bearBase", display = display.none)

fill(
     bearTop,
     bearBase,
     top_value = lvlMid,
     bottom_value = 0,
     top_color = color.new(colBear, 92),
     bottom_color = color.new(colBear, 20),
     title = "Bear Dome"
)

// =========================== DYNAMIC COLORS =================================
kDynColor =
     dynamicK ?
         activeBullBias ? colBull :
         activeBearBias ? colBear :
         colK
     : colK

kGlowOuterColor = color.new(kDynColor, 80)
kGlowInnerColor = color.new(kDynColor, 55)

// =========================== %K / %D ========================================
plot(glow ? k : na, "%K Glow Outer", color = kGlowOuterColor, linewidth = 5)
plot(glow ? k : na, "%K Glow Inner", color = kGlowInnerColor, linewidth = 3)
plot(k, "%K Line", color = kDynColor, linewidth = 2)
plot(d, "%D Signal", color = color.new(colD, 25), linewidth = 1, style = plot.style_line)

// ====================== PRESSURE RIBBONS ====================================
buyRibbon = math.min(buyPow * presBoost * 0.3, 20)
sellRibbon = 100 - math.min(sellPow * presBoost * 0.3, 20)

pBuyTop = plot(showPres ? buyRibbon : na, "Buy Ribbon", display = display.none)
pBuyBot = plot(showPres ? 0 : na, "", display = display.none)

fill(
     pBuyTop,
     pBuyBot,
     top_value = 20,
     bottom_value = 0,
     top_color = color.new(colBull, 88),
     bottom_color = color.new(colBull, 50),
     title = "Buying Pressure"
)

pSellTop = plot(showPres ? 100 : na, "", display = display.none)
pSellBot = plot(showPres ? sellRibbon : na, "Sell Ribbon", display = display.none)

fill(
     pSellTop,
     pSellBot,
     top_value = 100,
     bottom_value = 80,
     top_color = color.new(colBear, 50),
     bottom_color = color.new(colBear, 88),
     title = "Selling Pressure"
)

// =============================== SIGNAUX ====================================
f_tinySignalLabel(bool show, string txt, float yPos, color col, bool isBull) =>
    if show
        label.new(
             bar_index,
             yPos,
             txt,
             color = color.new(col, 100),
             textcolor = col,
             size = size.tiny,
             style = isBull ? label.style_label_up : label.style_label_down,
             yloc = yloc.price
        )

if bullSignal and showTinySignals
    f_tinySignalLabel(true, "B" + str.tostring(bullStr), 2, colBull, true)

if bearSignal and showTinySignals
    f_tinySignalLabel(true, "S" + str.tostring(bearStr), 98, colBear, false)

// Armed dots kept
plot(armedBull and not bullSignal and k < lvlOS ? k : na, "Armed Bull", color = color.new(colBull, 40), style = plot.style_circles, linewidth = 2)
plot(armedBear and not bearSignal and k > lvlOB ? k : na, "Armed Bear", color = color.new(colBear, 40), style = plot.style_circles, linewidth = 2)

// =========================== CANDLE COLOR MODE ===============================
candleBullBiasSource =
     candleColorSource == "MTF Bias" ? bullBias_mtf :
     candleColorSource == "Chart Bias" ? bullBias_chart :
     activeBullBias

candleBearBiasSource =
     candleColorSource == "MTF Bias" ? bearBias_mtf :
     candleColorSource == "Chart Bias" ? bearBias_chart :
     activeBearBias

candleArmedBullSource =
     candleColorSource == "MTF Bias" ? armedBull_mtf :
     candleColorSource == "Chart Bias" ? armedBull_chart :
     armedBull

candleArmedBearSource =
     candleColorSource == "MTF Bias" ? armedBear_mtf :
     candleColorSource == "Chart Bias" ? armedBear_chart :
     armedBear

candleNetPresSource =
     candleColorSource == "MTF Bias" ? netPres_mtf :
     candleColorSource == "Chart Bias" ? netPres_chart :
     netPres

candleBull =
     candleColorLogic == "Bias" ?
         candleBullBiasSource :
     candleColorLogic == "Signal Only" ?
         bullSignal :
     candleColorLogic == "Armed" ?
         candleArmedBullSource :
     candleColorLogic == "Pressure" ?
         candleNetPresSource > 10 :
         false

candleBear =
     candleColorLogic == "Bias" ?
         candleBearBiasSource :
     candleColorLogic == "Signal Only" ?
         bearSignal :
     candleColorLogic == "Armed" ?
         candleArmedBearSource :
     candleColorLogic == "Pressure" ?
         candleNetPresSource < -10 :
         false

barcolor(
     showCandleColor ?
         candleBull ? color.new(colBull, candleColorTransp) :
         candleBear ? color.new(colBear, candleColorTransp) :
         na
     : na
)

// =============================== DASHBOARD ==================================
if showDash and barstate.islast
    var table dash = table.new(
         position.top_right,
         2,
         9,
         border_width = 1,
         border_color = color.new(#263238, 60),
         frame_width = 1,
         frame_color = color.new(#263238, 30)
    )

    string modeTxt = mtfMode == "Chart" ? "CHART" : mtfMode == "MTF Strict" ? "MTF STRICT " + mtfTf : "MTF BIAS " + mtfTf

    string trend =
         activeBullBias ? "▲ BULL" :
         activeBearBias ? "▼ BEAR" :
         "● NEUTRAL"

    color trendCol =
         activeBullBias ? colBull :
         activeBearBias ? colBear :
         colMid

    string slopeTxt =
         activeSlopeBull ? "RISING" :
         activeSlopeBear ? "FALLING" :
         "FLAT"

    color slopeCol =
         activeSlopeBull ? colBull :
         activeSlopeBear ? colBear :
         colMid

    string presLabel =
         netPres > 10 ? "BUYING" :
         netPres < -10 ? "SELLING" :
         "BALANCED"

    color presCol =
         netPres > 10 ? colBull :
         netPres < -10 ? colBear :
         colMid

    string zone =
         k >= lvlExtOB ? "EXTREME OB" :
         k >= lvlOB ? "OVERBOUGHT" :
         k <= lvlExtOS ? "EXTREME OS" :
         k <= lvlOS ? "OVERSOLD" :
         "NEUTRAL"

    color zoneCol =
         k >= lvlOB ? colBear :
         k <= lvlOS ? colBull :
         colMid

    string armState =
         armedBull ? "ARMED BULL" :
         armedBear ? "ARMED BEAR" :
         "—"

    color armCol =
         armedBull ? colBull :
         armedBear ? colBear :
         colMid

    string mtfBiasTxt =
         bullBias_mtf ? "MTF BULL" :
         bearBias_mtf ? "MTF BEAR" :
         "MTF NEUTRAL"

    color mtfBiasCol =
         bullBias_mtf ? colBull :
         bearBias_mtf ? colBear :
         colMid

    table.cell(dash, 0, 0, "MODE", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 0, modeTxt, bgcolor = color.new(#0D1B2A, 0), text_color = mtfMode == "Chart" ? color.white : color.orange, text_size = size.tiny)

    table.cell(dash, 0, 1, "STATE", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 1, trend, bgcolor = color.new(#0D1B2A, 0), text_color = trendCol, text_size = size.tiny)

    table.cell(dash, 0, 2, "MTF BIAS", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 2, mtfBiasTxt, bgcolor = color.new(#0D1B2A, 0), text_color = mtfBiasCol, text_size = size.tiny)

    table.cell(dash, 0, 3, "SLOPE", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 3, slopeTxt, bgcolor = color.new(#0D1B2A, 0), text_color = slopeCol, text_size = size.tiny)

    table.cell(dash, 0, 4, "ZONE", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 4, zone, bgcolor = color.new(#0D1B2A, 0), text_color = zoneCol, text_size = size.tiny)

    table.cell(dash, 0, 5, "PRESSURE", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 5, presLabel + " " + str.tostring(netPres, "#.0"), bgcolor = color.new(#0D1B2A, 0), text_color = presCol, text_size = size.tiny)

    table.cell(dash, 0, 6, "%K / %D", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 6, str.tostring(k, "#.0") + " / " + str.tostring(d, "#.0"), bgcolor = color.new(#0D1B2A, 0), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 7, "STRENGTH", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 7, "B" + str.tostring(bullStr) + " / S" + str.tostring(bearStr), bgcolor = color.new(#0D1B2A, 0), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 8, "ARMED", bgcolor = color.new(#0D1B2A, 0), text_color = #B0BEC5, text_size = size.tiny)
    table.cell(dash, 1, 8, armState, bgcolor = color.new(#0D1B2A, 0), text_color = armCol, text_size = size.tiny)

// =============================== ALERTS =====================================
alertcondition(bullSignal, "Bull Reversal (After Explosion)", "SMART STOCH: Bull reversal confirmed after oversold explosion.")
alertcondition(bearSignal, "Bear Reversal (After Explosion)", "SMART STOCH: Bear reversal confirmed after overbought explosion.")
alertcondition(k <= lvlExtOS, "Extreme Oversold", "SMART STOCH: K entered extreme oversold zone.")
alertcondition(k >= lvlExtOB, "Extreme Overbought", "SMART STOCH: K entered extreme overbought zone.")
alertcondition(ta.crossover(netPres, 0), "Pressure Flip Bull", "SMART STOCH: Net pressure flipped bullish.")
alertcondition(ta.crossunder(netPres, 0), "Pressure Flip Bear", "SMART STOCH: Net pressure flipped bearish.")
````
