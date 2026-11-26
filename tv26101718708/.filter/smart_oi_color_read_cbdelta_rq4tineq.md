# Smart OI Color Read + CBDelta

- url: https://www.tradingview.com/script/Rq4tIneq-Smart-OI-Color-Read-CBDelta/
- type: indicator
- pine_id: PUB;f52a2c5eb7a247b682587b021eb2352b
- version: 3.0

## Description

Smart OI Color Read with CBDelta

Smart OI Color Read is an aggregated Open Interest visualization tool designed to help traders interpret derivatives positioning, liquidation behavior, and spot-vs-perpetual participation using a simplified candle-color framework.

The script combines:

* Aggregated Open Interest (OI)
* OBV (On-Balance Volume)
* CVD (Cumulative Volume Delta)
* CBDelta (Coinbase vs Bybit premium)

The objective is not to generate automatic buy/sell signals, but to provide a cleaner way to read participation mechanics and positioning shifts in real time.

━━━━━━━━━━━━━━━━━━
CORE CONCEPT
━━━━━━━━━━━━━━━━━━

The indicator focuses on the relationship between:

* Price movement
* Open Interest changes
* Aggressive flow context
* Spot vs perpetual participation

Instead of building a heavy signal engine, the script attempts to simplify positioning behavior into readable market states.

━━━━━━━━━━━━━━━━━━
OI COLOR LOGIC
━━━━━━━━━━━━━━━━━━

The main candle colors are based on price direction and Open Interest direction.

• Green → Price ↑ + OI ↑
New long positioning entering the market.
Bullish participation expansion.

• Red → Price ↓ + OI ↑
New short positioning entering the market.
Bearish participation expansion.

• Aqua → Price ↑ + OI ↓
Short covering.
Short positions closing while price rises.

• Orange → Price ↓ + OI ↓
Long liquidation / deleveraging.
Long positions closing while price falls.

• Blue → Aggressive short squeeze
A stronger version of short covering requiring:

* price rising,
* OI dropping,
* elevated relative volume,
* strong candle body relative to ATR.

This attempts to isolate more aggressive forced short exits instead of passive covering.

• Gray → Mixed / balanced positioning
No dominant participation behavior detected.

━━━━━━━━━━━━━━━━━━
PROBABILITY-BASED CLASSIFICATION
━━━━━━━━━━━━━━━━━━

The script does not rely exclusively on raw price direction.

When price action becomes mixed or unstable intrabar, the indicator attempts to infer the most probable participation state using:

* OI behavior,
* OBV slope,
* CVD slope,
* absorption context.

Examples:

* OI↓ + bullish flow context → likely short covering
* OI↓ + bearish flow context → likely long liquidation
* OI↑ + bullish flow context → likely long build
* OI↑ + bearish flow context → likely short build

This helps reduce ambiguous “OI unwind” states and instead favors probabilistic interpretation.

━━━━━━━━━━━━━━━━━━
CBDELTA PREMIUM LAYER
━━━━━━━━━━━━━━━━━━

The script also includes CBDelta:

* Coinbase price vs Bybit price premium.

Formula:

CBDelta = ((Bybit - Coinbase) / Coinbase) × 1000

Purpose:

* estimate whether market movement is primarily driven by spot demand or leveraged perpetual positioning.

Interpretation examples:

• Spot-led
Coinbase stronger than Bybit.
Often associated with healthier continuation.

• Perp-led / leverage crowding
Bybit trading above Coinbase.
Indicates stronger leveraged participation.

• Perp overheating
Strong positive perpetual premium.
Can indicate crowded long conditions.

• Perp panic / liquidation
Strong negative premium.
Can indicate forced deleveraging or panic conditions.

CBDelta is used only as contextual information inside the bottom read line.
It does not directly recolor candles.

━━━━━━━━━━━━━━━━━━
BOTTOM READ LINE
━━━━━━━━━━━━━━━━━━

The bottom-center read line summarizes:

* current OI positioning state,
* CVD direction,
* OBV direction,
* absorption context,
* spot-led vs perp-led participation.

The intention is to provide a compact participation read without large dashboards or complex signal tables.

━━━━━━━━━━━━━━━━━━
HOW IT CAN BE USED
━━━━━━━━━━━━━━━━━━

The indicator may help traders observe:

* new long positioning,
* new short positioning,
* short covering,
* long liquidation,
* leverage crowding,
* squeeze attempts,
* trapped positioning environments,
* spot-led continuation,
* derivatives-driven reversals.

Many traders may combine it with:

* market structure,
* support/resistance,
* VWAP,
* EMA structure,
* liquidity analysis,
* orderflow tools.

━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━

* Aggregated OI depends on exchange data availability on TradingView.
* Open Interest alone does not determine market direction.
* Funding, OI, CVD, and price can diverge during volatile conditions.
* CBDelta is contextual and may behave differently across timeframes.
* Intrabar candle colors can temporarily fluctuate while candles are still forming.
* The script does not use future-looking data.

This indicator is intended as a positioning and participation analysis tool rather than a standalone trading system.

Built for traders interested in:

* derivatives positioning,
* liquidation mechanics,
* participation quality,
* and spot vs perpetual market behavior.

## Source Code

````pine
//@version=6
indicator("Smart OI Color Read + CBDelta", shorttitle="Smart OI CBD", overlay=false, format=format.volume, dynamic_requests=true, max_labels_count=50)

// Clean version:
// - Keeps aggregated OI candles.
// - Keeps original simple OI color map.
// - Removes signal marks, alertconditions, regime/legend/OI tables.
// - Adds one bottom-middle color-read line.
// - Appends CBDelta spot/perp premium context to the info line.
// - Uses probability-based fallback when price is flat/mixed, avoiding vague OI build/unwind reads.
// - Adds optional common-sense override ONLY for candles that remain mixed after the system classification.
// - Adds price EMA1 line on the main price chart, colored by the final OI classification colors.

import TradingView/ta/8 as tvTa

//=============================================================================
// INPUTS
//=============================================================================

grpEx = "Aggregated OI • Exchanges"
ex1   = input.bool(true,  "Binance", group=grpEx)
ex2   = input.bool(true,  "Bybit",   group=grpEx)
ex3   = input.bool(true,  "OKX",     group=grpEx)
ex5   = input.bool(true,  "Bitget",  group=grpEx)
ex6   = input.bool(true,  "Kraken",  group=grpEx)
ex7   = input.bool(true,  "HTX",     group=grpEx)
ex8   = input.bool(true,  "Deribit", group=grpEx)

grpAgg = "Aggregated OI • Visual"
typ             = input.string("OI", "Mode", options=["OI", "OI delta"], group=grpAgg)
typ2            = input.string("COIN", "Units", options=["USD", "COIN"], group=grpAgg)
oiColorMode     = input.string("Positioning Map", "OI candle coloring", options=["Standard", "Positioning Map"], group=grpAgg)
showOICandles   = input.bool(true, "Show aggregated OI candles", group=grpAgg)
cBullOI         = input.color(#2962ffa7, "Bull OI color", group=grpAgg)
cBearOI         = input.color(#e91e62a6, "Bear OI color", group=grpAgg)
cLongBuild      = input.color(color.lime,   "Green: price↑ + OI↑", group=grpAgg)
cShortBuild     = input.color(color.red,    "Red: price↓ + OI↑", group=grpAgg)
cShortCover     = input.color(color.aqua,   "Aqua: price↑ + OI↓", group=grpAgg)
cShortLiq       = input.color(color.blue,   "Blue: short squeeze / strong covering", group=grpAgg)
cLongLiq        = input.color(color.orange, "Orange: price↓ + OI↓", group=grpAgg)
cOIMixed        = input.color(color.gray,   "Gray: mixed / flat", group=grpAgg)
enableMixedOverride = input.bool(true, "Override mixed candles with price/OI logic", group=grpAgg)
shortLiqVolMult = input.float(1.5, "Blue squeeze: volume multiplier", minval=0.1, step=0.1, group=grpAgg)
shortLiqAtrMult = input.float(0.8, "Blue squeeze: body ATR multiplier", minval=0.1, step=0.1, group=grpAgg)
shortLiqOiDropPct = input.float(0.5, "Blue squeeze: OI drop % threshold", minval=0.05, step=0.05, group=grpAgg)

grpCore = "OBV / CVD Context"
lenEMA = input.int(21, "Smoothing EMA", minval=1, group=grpCore)
lenROC = input.int(5, "Slope length ROC", minval=1, group=grpCore)
thr    = input.float(0.0, "Slope threshold", step=0.01, group=grpCore)
volLen = input.int(20, "Volume MA length", minval=1, group=grpCore)
atrLen = input.int(14, "ATR length", minval=1, group=grpCore)

grpCVD = "CVD Core"
cvdAnchorInput           = input.timeframe("", "Anchor period", group=grpCVD)
cvdUseCustomTF           = input.bool(false, "Use custom lower timeframe", group=grpCVD)
cvdLowerTFInput          = input.timeframe("1", "Custom lower timeframe", group=grpCVD)
cvdMaLen                 = input.int(14, "CVD EMA length", minval=1, group=grpCVD)
cvdUseVolWeighting       = input.bool(true, "Volume-weight oscillator", group=grpCVD)
cvdOscLookback           = input.int(50, "Oscillator lookback", minval=5, group=grpCVD)
cvdSpikeMultiplier       = input.float(2.0, "Divergence spike threshold", minval=0.5, step=0.1, group=grpCVD)
cvdAbsorptionThreshold   = input.float(0.60, "Absorption threshold", minval=0.05, step=0.05, group=grpCVD)

grpCBD = "CBDelta Premium Context"
enableCBDelta = input.bool(true, "Enable CBDelta spot/perp read", group=grpCBD)
cbDeltaSymbolSpot = input.symbol("COINBASE:BTCUSD", "Spot reference", group=grpCBD)
cbDeltaSymbolPerp = input.symbol("BYBIT:BTCUSD", "Perp reference", group=grpCBD)
cbDeltaTf = input.timeframe("1", "CBDelta timeframe", group=grpCBD)
cbDeltaEmaLen = input.int(5, "CBDelta EMA length", minval=1, maxval=50, group=grpCBD)
crowdLevel = input.float(0.5, "Perp crowding threshold", step=0.1, group=grpCBD)
overheatLevel = input.float(1.5, "Perp overheating threshold", step=0.1, group=grpCBD)
spotLedLevel = input.float(-0.5, "Spot-led threshold", step=0.1, group=grpCBD)
panicLevel = input.float(-1.5, "Perp panic threshold", step=0.1, group=grpCBD)

grpRead = "One-Line Color Read"
showColorReadTable = input.bool(true, "Show one-line color read", group=grpRead)
readTableTextSize  = input.string("normal", "Text size", options=["tiny", "small", "normal", "large"], group=grpRead)

grpPrice = "Price EMA • OI Colored"
showPriceEMA1 = input.bool(true, "Show price EMA1 colored by OI", group=grpPrice)
priceEmaLen   = input.int(1, "Price EMA length", minval=1, group=grpPrice)
priceEmaWidth = input.int(3, "Price EMA line width", minval=1, maxval=5, group=grpPrice)

//=============================================================================
// HELPERS
//=============================================================================

eps = 1e-10
barsBack = 10000

f_oiConvert(_v, _ex, _app) =>
    _tmp = ((_app == "USD.P" and (_ex == "Binance" or _ex == "Bybit" or _ex == "Kraken")) or _ex == "OKX" or _ex == "Deribit") ?
      _v * (_ex == "Binance" ? (syminfo.basecurrency == "BTC" ? 100 : 10) : 1) / close : _v
    typ2 == "USD" ? _tmp * close : _tmp

f_arrow(_up, _dn) =>
    _up ? "↑" : _dn ? "↓" : "→"

f_size(_s) =>
    _s == "tiny" ? size.tiny : _s == "small" ? size.small : _s == "large" ? size.large : size.normal

f_oiPosColor(_probLongBuild, _probShortBuild, _probShortCover, _probLongLiq, _oiUpBar, _oiDnBar, _shortLiqBar) =>
    oiColorMode == "Standard" ? (_oiUpBar ? cBullOI : _oiDnBar ? cBearOI : cOIMixed) :
     _shortLiqBar       ? cShortLiq :
     _probLongBuild     ? cLongBuild :
     _probShortBuild    ? cShortBuild :
     _probShortCover    ? cShortCover :
     _probLongLiq       ? cLongLiq :
     _oiUpBar           ? cBullOI :
     _oiDnBar           ? cBearOI :
     cOIMixed

//=============================================================================
// 1) AGGREGATED OPEN INTEREST
//=============================================================================

var string[] appendixes = array.from("USDT.P", "USD.P", "USDC.P", "USD.PM")
var string[] exchangeNames = array.from("Binance", "Bybit", "OKX", "Bitget", "Kraken", "HTX", "Deribit")

sumO = 0.0
sumH = 0.0
sumL = 0.0
sumC = 0.0
sources = 0

for exIdx = 0 to array.size(exchangeNames) - 1
    exName = array.get(exchangeNames, exIdx)
    exEnabled =
         exIdx == 0 ? ex1 :
         exIdx == 1 ? ex2 :
         exIdx == 2 ? ex3 :
         exIdx == 3 ? ex5 :
         exIdx == 4 ? ex6 :
         exIdx == 5 ? ex7 :
         ex8
    if exEnabled
        for appIdx = 0 to array.size(appendixes) - 1
            app = array.get(appendixes, appIdx)
            sym = exName + ":" + syminfo.basecurrency + app + "_OI"
            [o_, h_, l_, c_] = request.security(sym, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true, calc_bars_count=barsBack)
            if not na(c_)
                sumO += f_oiConvert(o_, exName, app)
                sumH += f_oiConvert(h_, exName, app)
                sumL += f_oiConvert(l_, exName, app)
                sumC += f_oiConvert(c_, exName, app)
                sources += 1

oiO = sumO
oiH = sumH
oiL = sumL
oiC = sumC

hasAggOI = sources > 0 and not na(oiC) and oiC != 0
if barstate.islastconfirmedhistory and not hasAggOI
    runtime.error("No aggregated Open Interest data found for the selected exchanges.")

deltaOI = oiC - oiO

//=============================================================================
// 2) OBV
//=============================================================================

var float cumVol = 0.0
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

obv = ta.cum(math.sign(ta.change(close)) * volume)

//=============================================================================
// 3) CVD CORE
//=============================================================================

var string cvdLowerTF = ""
if cvdUseCustomTF
    cvdLowerTF := cvdLowerTFInput
else
    if timeframe.isseconds
        cvdLowerTF := "1S"
    else if timeframe.isintraday
        cvdLowerTF := "1"
    else if timeframe.isdaily
        cvdLowerTF := "5"
    else
        cvdLowerTF := "60"

[cvdOpenRaw, cvdMaxRaw, cvdMinRaw, cvdLastRaw] = tvTa.requestVolumeDelta(cvdLowerTF, cvdAnchorInput)

var float cvdCum = 0.0
var float cumVolLine = na
if cvdAnchorInput == ""
    bool dataAppeared = not na(cvdLastRaw) and na(cvdLastRaw[1])
    bool anchorChange = timeframe.change(timeframe.period) or dataAppeared
    float cvdOpenTmp = anchorChange ? 0.0 : nz(cvdCum[1])
    cvdCum := cvdOpenTmp + nz(cvdLastRaw)
    cumVolLine := cvdCum
else
    cumVolLine := cvdLastRaw

price_ma = ta.ema(close, cvdMaLen)
cvd_ma   = ta.ema(cumVolLine, cvdMaLen)
cvd_ma_mean   = ta.ema(cvd_ma, cvdMaLen)
cvd_ma_std    = ta.stdev(cvd_ma, cvdMaLen)
cvd_ma_norm   = cvd_ma_std != 0 ? (cvd_ma - cvd_ma_mean) / cvd_ma_std : 0.0
price_ma_mean = ta.ema(price_ma, cvdMaLen)
price_ma_std  = ta.stdev(price_ma, cvdMaLen)
price_ma_norm = price_ma_std != 0 ? (price_ma - price_ma_mean) / price_ma_std : 0.0

raw_oscillator = cvd_ma_norm - price_ma_norm
vol_ma_cvd   = ta.ema(volume, cvdOscLookback)
volumeFactor = nz(volume / math.max(vol_ma_cvd, eps), 1.0)
cvdOsc       = cvdUseVolWeighting ? raw_oscillator * volumeFactor : raw_oscillator
weightedOsc  = raw_oscillator * volumeFactor
weightedOscMean  = ta.sma(weightedOsc, cvdOscLookback)
weightedOscStd   = ta.stdev(weightedOsc, cvdOscLookback)
divergenceSpike  = not na(weightedOscStd) and weightedOscStd > 0 and math.abs(weightedOsc - weightedOscMean) > cvdSpikeMultiplier * weightedOscStd

cvdBullSpike = divergenceSpike and weightedOsc < 0
cvdBearSpike = divergenceSpike and weightedOsc > 0
cvdBearAbsorption = cvdOsc > cvdAbsorptionThreshold
cvdBullAbsorption = cvdOsc < -cvdAbsorptionThreshold

//=============================================================================
// 3B) CBDELTA PREMIUM CONTEXT
// Coinbase vs Bybit premium is used only in the bottom read line.
// It does not alter OI candle colors.
//=============================================================================

cbSpotPrice = request.security(cbDeltaSymbolSpot, cbDeltaTf, close, ignore_invalid_symbol=true)
cbPerpPrice = request.security(cbDeltaSymbolPerp, cbDeltaTf, close, ignore_invalid_symbol=true)
cbDelta = not na(cbSpotPrice) and not na(cbPerpPrice) and cbSpotPrice != 0 ? ((cbPerpPrice - cbSpotPrice) / cbSpotPrice) * 1000.0 : na
cbDeltaEma = ta.ema(cbDelta, cbDeltaEmaLen)

premiumStateRead =
     not enableCBDelta ? "CBDelta off" :
     na(cbDeltaEma) ? "CBDelta unavailable" :
     cbDeltaEma > overheatLevel ? "Perp overheating" :
     cbDeltaEma > crowdLevel ? "Perp-led / leverage crowding" :
     cbDeltaEma < panicLevel ? "Perp panic / liquidation" :
     cbDeltaEma < spotLedLevel ? "Spot-led strength" :
     "Premium neutral"

//=============================================================================
// 4) CORE STATES
//=============================================================================

oi_s   = ta.ema(oiC, lenEMA)
oi_roc = ta.roc(oi_s, lenROC)
obv_s   = ta.ema(obv, lenEMA)
obv_roc = ta.roc(obv_s, lenROC)
cvd_s   = ta.ema(cumVolLine, lenEMA)
cvd_roc = ta.roc(cvd_s, lenROC)

obvUp = obv_roc >  thr
obvDn = obv_roc < -thr
oiUp  = oi_roc  >  thr
oiDn  = oi_roc  < -thr
cvdUp = cvd_roc >  thr
cvdDn = cvd_roc < -thr

priceUpBar = close > close[1]
priceDnBar = close < close[1]
oiUpBar    = deltaOI > 0
oiDnBar    = deltaOI < 0

volMA = ta.sma(volume, volLen)
atr = ta.atr(atrLen)
body = math.abs(close - open)
oiDeltaPct = oiO != 0 ? (deltaOI / oiO) * 100.0 : 0.0

// Probability engine for ambiguous / flat candles.
// Price direction gets more weight, but CVD and OBV help decide whether OI build/unwind
// is more likely long build, short build, short covering or long liquidation.
bullForceScore = (priceUpBar ? 2 : 0) + (cvdUp ? 1 : 0) + (obvUp ? 1 : 0)
bearForceScore = (priceDnBar ? 2 : 0) + (cvdDn ? 1 : 0) + (obvDn ? 1 : 0)
probBullForce = bullForceScore > bearForceScore
probBearForce = bearForceScore > bullForceScore

probLongBuild = oiUpBar and probBullForce
probShortBuild = oiUpBar and probBearForce
probShortCover = oiDnBar and probBullForce
probLongLiq = oiDnBar and probBearForce

shortCoveringBar = probShortCover
shortLiqBar =
     shortCoveringBar and
     volume > volMA * shortLiqVolMult and
     body > atr * shortLiqAtrMult and
     math.abs(oiDeltaPct) > shortLiqOiDropPct

// Common-sense override ONLY for candles that the probability system still leaves mixed.
// Confident system classifications remain untouched.
systemCertain =
     shortLiqBar or
     probLongBuild or
     probShortBuild or
     probShortCover or
     probLongLiq

mixedOverrideAllowed = enableMixedOverride and not systemCertain

csLongBuild  = mixedOverrideAllowed and priceUpBar and oiUpBar
csShortBuild = mixedOverrideAllowed and priceDnBar and oiUpBar
csShortCover = mixedOverrideAllowed and priceUpBar and oiDnBar
csLongLiq    = mixedOverrideAllowed and priceDnBar and oiDnBar

oiCol = f_oiPosColor(
     probLongBuild or csLongBuild,
     probShortBuild or csShortBuild,
     probShortCover or csShortCover,
     probLongLiq or csLongLiq,
     oiUpBar,
     oiDnBar,
     shortLiqBar)
deltaCol = oiUpBar ? cBullOI : oiDnBar ? cBearOI : cOIMixed

//=============================================================================
// 5) COLOR READ
//=============================================================================

mechanicalRead =
     shortLiqBar ? "Blue squeeze: OI↓ + bullish force + strong volume/body = forced short covering" :
     probLongBuild ? (priceUpBar ? "Green long build: price↑ + OI↑ = new upside positioning" : "Green probable long build: OI↑ + CVD/OBV bullish") :
     probShortBuild ? (priceDnBar ? "Red short build: price↓ + OI↑ = new downside positioning" : "Red probable short build: OI↑ + CVD/OBV bearish") :
     probShortCover ? (priceUpBar ? "Aqua short covering: price↑ + OI↓ = shorts closing" : "Aqua probable short covering: OI↓ + CVD/OBV bullish") :
     probLongLiq ? (priceDnBar ? "Orange long flush: price↓ + OI↓ = longs closing / deleveraging" : "Orange probable long liquidation: OI↓ + CVD/OBV bearish") :
     csLongBuild ? "Override green: mixed evidence, but price↑ + OI↑ = likely long building" :
     csShortBuild ? "Override red: mixed evidence, but price↓ + OI↑ = likely shorts building" :
     csShortCover ? "Override aqua: mixed evidence, but price↑ + OI↓ = likely short covering" :
     csLongLiq ? "Override orange: mixed evidence, but price↓ + OI↓ = likely long liquidation / deleveraging" :
     oiUpBar ? "Mixed OI build: OI↑ but force evidence balanced" :
     oiDnBar ? "Mixed OI unwind: OI↓ but force evidence balanced" :
     "Mixed / flat OI"

cvdRead =
     cvdUp ? "CVD↑" :
     cvdDn ? "CVD↓" :
     "CVD→"

obvRead =
     obvUp ? "OBV↑" :
     obvDn ? "OBV↓" :
     "OBV→"

absorbRead =
     cvdBullAbsorption ? "bull absorption" :
     cvdBearAbsorption ? "bear absorption" :
     cvdBullSpike ? "bull CVD spike" :
     cvdBearSpike ? "bear CVD spike" :
     "no absorption spike"

oiReadLine =
     mechanicalRead +
     " | " + cvdRead +
     " | " + obvRead +
     " | " + absorbRead +
     " | " + premiumStateRead

//=============================================================================
// 6) PLOTS
//=============================================================================

priceEMA1 = ta.ema(close, priceEmaLen)

plot(showPriceEMA1 ? priceEMA1 : na,
     title="Price EMA1 • OI Colored",
     color=oiCol,
     linewidth=priceEmaWidth,
     force_overlay=true)

plotcandle(showOICandles and typ == "OI" ? oiO : na,
     showOICandles and typ == "OI" ? oiH : na,
     showOICandles and typ == "OI" ? oiL : na,
     showOICandles and typ == "OI" ? oiC : na,
     title="Aggregated OI",
     color=oiCol,
     wickcolor=oiCol,
     bordercolor=oiCol)

plot(typ == "OI delta" ? deltaOI : na, title="OI delta", color=deltaCol, linewidth=1, style=plot.style_columns)

//=============================================================================
// 7) ONE-LINE READ TABLE
//=============================================================================

var table readTable = table.new(position.bottom_center, 1, 1, border_width=1, bgcolor=color.new(color.black, 0), force_overlay=false)

if barstate.islast
    table.clear(readTable, 0, 0, 0, 0)
    if showColorReadTable
        table.cell(readTable, 0, 0, oiReadLine, bgcolor=oiCol, text_color=color.black, text_size=f_size(readTableTextSize), tooltip="Clean OI color read: confident system classifications stay untouched. If a candle remains mixed, optional override applies simple price/OI common sense. CBDelta is context only.")
````
