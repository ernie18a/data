# Reversal + Key Candles (Augusto)

- url: https://www.tradingview.com/script/YxVKAjgH-Reversal-Key-Candles-Augusto/
- type: indicator
- pine_id: PUB;62a5f230c67b4522a250a88e14805263
- version: 1.0

## Description

Multi-Indicator Divergence & Reversal Suite

This script combines RSI, OBV, MACD, and Momentum divergence detection with key reversal candle analysis to help you spot potential trend pivots.

Customizable divergence scoring.

Key Reversal candle detection.

Smoothing MA and trend analysis tools.

A comprehensive tool designed for technical traders. It integrates divergence signals from multiple oscillators with key reversal candle patterns, allowing for higher confluence in your trade setups. Includes customizable sensitivity and scoring.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// DIVAP HORISTIC v8 — RSI Div + Score + RVOL + Key Reversal independente
//@version=6
indicator(
     title          = "DIVAP HORISTIC",
     shorttitle     = "DIVAP",
     format         = format.price,
     precision      = 2,
     timeframe      = "",
     timeframe_gaps = true,
     overlay        = false)

// ═══════════════════════════════════════════════════════════════════
//  RSI SETTINGS
// ═══════════════════════════════════════════════════════════════════
GRP_RSI             = "RSI Settings"
rsiLengthInput      = input.int(14,      "RSI Length",   minval=1,  group=GRP_RSI)
rsiSourceInput      = input.source(close,"Source",                  group=GRP_RSI)
calculateDivergence = input.bool(true,   "Show Divergence",         group=GRP_RSI)
showAverage         = input.bool(false,  "Show Average",            group=GRP_RSI)

// ═══════════════════════════════════════════════════════════════════
//  DIVERGENCE SETTINGS
// ═══════════════════════════════════════════════════════════════════
GRP_DIV  = "Divergence Settings"
lbLeft   = input.int(3,  "Pivot Left  Bars", minval=1, maxval=20, group=GRP_DIV)
lbRight  = input.int(3,  "Pivot Right Bars", minval=1, maxval=20, group=GRP_DIV)
rngLow   = input.int(3,  "Range Min (bars)", minval=1,            group=GRP_DIV)
rngHigh  = input.int(50, "Range Max (bars)", minval=5,            group=GRP_DIV)

// Multi-indicator divergence
GRP_MULTI  = "Multi-Indicator Divergence"
useRSIdiv  = input.bool(true,  "RSI Divergence",      group=GRP_MULTI)
useOBVdiv  = input.bool(false, "OBV Divergence",      group=GRP_MULTI)
useMACDdiv = input.bool(false, "MACD Histogram Div",  group=GRP_MULTI)
useMOMdiv  = input.bool(false, "Momentum Divergence", group=GRP_MULTI)
minDivScore= input.int(1, "Min Divergence Score", minval=1, maxval=4, group=GRP_MULTI,
     tooltip="Quantos indicadores precisam confirmar a divergência")

// ═══════════════════════════════════════════════════════════════════
//  SMOOTHING MA
// ═══════════════════════════════════════════════════════════════════
GRP_SMOOTH    = "Smoothing"
TT_BB         = "Only applies when 'SMA + Bollinger Bands' is selected."
maTypeInput   = input.string("SMA","Type",
     options   = ["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"],
     group=GRP_SMOOTH, display=display.none)
maLengthInput = input.int(14,    "Length",    group=GRP_SMOOTH, display=display.none)
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5,
     tooltip=TT_BB, group=GRP_SMOOTH, display=display.none)
var bool isBB     = maTypeInput == "SMA + Bollinger Bands"
var bool enableMA = maTypeInput != "None"

// ═══════════════════════════════════════════════════════════════════
//  DIVAP CANDLE COLORS
// ═══════════════════════════════════════════════════════════════════
GRP_DIVAP       = "DIVAP Settings"
showDivapColor  = input.bool(true,  "Show DIVAP Candle Color",         group=GRP_DIVAP)
useWick         = input.bool(false, "Use Wick",                         group=GRP_DIVAP)
bullCandleColor = input.color(color.new(#00E676, 0), "Candle Color Bullish (Divergence)", group=GRP_DIVAP)
bearCandleColor = input.color(color.new(#FFD700, 0), "Candle Color Bearish (Divergence)", group=GRP_DIVAP)

// Key Reversal / Force candle — independent signal
GRP_KR          = "Key Reversal (Volume Force)"
useKeyRevStand  = input.bool(true,  "Show Key Reversal + RVOL Candles (no divergence needed)", group=GRP_KR,
     tooltip="Pinta candles de força com Key Reversal + RVOL alto, independente de divergência RSI")
krBullColor     = input.color(color.new(#000af9, 0), "KR Bull Color (Blue)",  group=GRP_KR)
krBearColor     = input.color(color.new(#000af9, 0), "KR Bear Color (Orange)",group=GRP_KR)
krRvolMin       = input.float(2.5, "RVOL Min for KR Signal", minval=1.0, step=0.5, group=GRP_KR,
     tooltip="Volume relativo mínimo para ativar o sinal de Key Reversal independente")

// ═══════════════════════════════════════════════════════════════════
//  CANDLESTICK PATTERNS
// ═══════════════════════════════════════════════════════════════════
GRP_CANDLE       = "Candlestick Patterns"
useCandleFilter  = input.bool(true,  "Require Candlestick Pattern (for Divergence signal)", group=GRP_CANDLE)
use_hammer       = input.bool(true,  "Hammer / Inverted Hammer",       group=GRP_CANDLE)
use_engulf       = input.bool(true,  "Engulfing",                      group=GRP_CANDLE)
use_pinbar       = input.bool(true,  "Pin Bar",                        group=GRP_CANDLE)
use_doji         = input.bool(true,  "Doji / Dragonfly / Gravestone",  group=GRP_CANDLE)
use_morning      = input.bool(true,  "Morning Star",                   group=GRP_CANDLE)
use_evening      = input.bool(true,  "Evening Star",                   group=GRP_CANDLE)
use_shooting     = input.bool(true,  "Shooting Star / Hanging Man",    group=GRP_CANDLE)
use_keyrev       = input.bool(true,  "Key Reversal Bar",               group=GRP_CANDLE)
candleWindow     = input.int(2, "Pattern Search Window", minval=0, maxval=5, group=GRP_CANDLE)
wickRatio        = input.float(1.5, "Min Wick/Body Ratio", minval=0.5, step=0.1, group=GRP_CANDLE)
dojiBodyPct      = input.float(0.1, "Max Doji Body/Range", minval=0.01, step=0.01, group=GRP_CANDLE)

// ═══════════════════════════════════════════════════════════════════
//  VOLUME & RVOL
// ═══════════════════════════════════════════════════════════════════
GRP_VOL      = "Volume Settings"
useVolFilter = input.bool(true,  "Volume Above Average (Divergence signal)", group=GRP_VOL)
volMaLen     = input.int(20,     "Volume MA Length", minval=2,               group=GRP_VOL)
volMaType    = input.string("SMA","Volume MA Type",
     options=["SMA","EMA","WMA","RMA"],                                      group=GRP_VOL)
useRVOL      = input.bool(true,  "RVOL Boost (bypasses Fibonacci filter)",   group=GRP_VOL)
rvolThresh   = input.float(2.0,  "RVOL Threshold (×avg)", step=0.5, minval=1.0, group=GRP_VOL)

// ═══════════════════════════════════════════════════════════════════
//  FIBONACCI ZONE
// ═══════════════════════════════════════════════════════════════════
GRP_FIB      = "Fibonacci Settings"
useFibFilter = input.bool(true,  "Price in Fibonacci Zone", group=GRP_FIB)
fibPivotLB   = input.int(50,     "Fib Pivot Lookback", minval=10, group=GRP_FIB)
fibProxPct   = input.float(2.0,  "Fib Zone Width (%)", step=0.1,  group=GRP_FIB)

// ═══════════════════════════════════════════════════════════════════
//  SIGNAL SCORE
// ═══════════════════════════════════════════════════════════════════
GRP_SCORE = "Signal Score"
minScore  = input.int(3, "Min Score to Paint Divergence Candle", minval=1, maxval=6, group=GRP_SCORE,
     tooltip="1=Divergência | 2=Candle | 3=Volume | 4=Fibonacci | 5=RVOL Boost")

// ═══════════════════════════════════════════════════════════════════
//  RSI CALCULATION
// ═══════════════════════════════════════════════════════════════════
rsi_change = ta.change(rsiSourceInput)
rsi_up     = ta.rma(math.max(rsi_change, 0), rsiLengthInput)
rsi_down   = ta.rma(-math.min(rsi_change, 0), rsiLengthInput)
rsi        = rsi_down == 0 ? 100 : rsi_up == 0 ? 0 : 100 - (100 / (1 + rsi_up / rsi_down))

// ═══════════════════════════════════════════════════════════════════
//  SMOOTHING MA
// ═══════════════════════════════════════════════════════════════════
f_ma(src, len, t) =>
    switch t
        "SMA"                   => ta.sma(src, len)
        "SMA + Bollinger Bands" => ta.sma(src, len)
        "EMA"                   => ta.ema(src, len)
        "SMMA (RMA)"            => ta.rma(src, len)
        "WMA"                   => ta.wma(src, len)
        "VWMA"                  => ta.vwma(src, len)
        =>                         ta.sma(src, len)

smoothingMA    = showAverage and enableMA ? f_ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na

// ═══════════════════════════════════════════════════════════════════
//  DIVERGENCE — pré-calculados fora de if (fix CW10002)
// ═══════════════════════════════════════════════════════════════════
// RSI
plRaw   = ta.pivotlow(rsi,  lbLeft, lbRight)
phRaw   = ta.pivothigh(rsi, lbLeft, lbRight)
plFound = not na(plRaw)
phFound = not na(phRaw)

rsiLBR  = rsi[lbRight]
lowLBR  = low[lbRight]
highLBR = high[lbRight]

bars_pl    = ta.barssince(plFound[1])
bars_ph    = ta.barssince(phFound[1])
inRange_pl = rngLow <= bars_pl  and bars_pl  <= rngHigh
inRange_ph = rngLow <= bars_ph  and bars_ph  <= rngHigh
vw_rsi_pl  = ta.valuewhen(plFound, rsiLBR,  1)
vw_low_pl  = ta.valuewhen(plFound, lowLBR,  1)
vw_rsi_ph  = ta.valuewhen(phFound, rsiLBR,  1)
vw_high_ph = ta.valuewhen(phFound, highLBR, 1)

// OBV
obv_val    = ta.obv
plOBV      = not na(ta.pivotlow(obv_val,  lbLeft, lbRight))
phOBV      = not na(ta.pivothigh(obv_val, lbLeft, lbRight))
obvLBR     = obv_val[lbRight]
bs_obv_pl  = ta.barssince(plOBV[1])
bs_obv_ph  = ta.barssince(phOBV[1])
inR_obv_pl = rngLow <= bs_obv_pl and bs_obv_pl <= rngHigh
inR_obv_ph = rngLow <= bs_obv_ph and bs_obv_ph <= rngHigh
vw_obv_pl  = ta.valuewhen(plOBV, obvLBR,              1)
vw_obv_lpl = ta.valuewhen(plOBV, low[lbRight],         1)
vw_obv_ph  = ta.valuewhen(phOBV, obvLBR,               1)
vw_obv_hph = ta.valuewhen(phOBV, high[lbRight],        1)

// MACD Histogram
[_ml, _ms, macd_hist] = ta.macd(close, 12, 26, 9)
plMACD     = not na(ta.pivotlow(macd_hist,  lbLeft, lbRight))
phMACD     = not na(ta.pivothigh(macd_hist, lbLeft, lbRight))
macdLBR    = macd_hist[lbRight]
bs_m_pl    = ta.barssince(plMACD[1])
bs_m_ph    = ta.barssince(phMACD[1])
inR_m_pl   = rngLow <= bs_m_pl and bs_m_pl <= rngHigh
inR_m_ph   = rngLow <= bs_m_ph and bs_m_ph <= rngHigh
vw_m_pl    = ta.valuewhen(plMACD, macdLBR,            1)
vw_m_lpl   = ta.valuewhen(plMACD, low[lbRight],        1)
vw_m_ph    = ta.valuewhen(phMACD, macdLBR,             1)
vw_m_hph   = ta.valuewhen(phMACD, high[lbRight],       1)

// Momentum
mom_val    = ta.mom(close, 10)
plMOM      = not na(ta.pivotlow(mom_val,  lbLeft, lbRight))
phMOM      = not na(ta.pivothigh(mom_val, lbLeft, lbRight))
momLBR     = mom_val[lbRight]
bs_mo_pl   = ta.barssince(plMOM[1])
bs_mo_ph   = ta.barssince(phMOM[1])
inR_mo_pl  = rngLow <= bs_mo_pl and bs_mo_pl <= rngHigh
inR_mo_ph  = rngLow <= bs_mo_ph and bs_mo_ph <= rngHigh
vw_mo_pl   = ta.valuewhen(plMOM, momLBR,              1)
vw_mo_lpl  = ta.valuewhen(plMOM, low[lbRight],         1)
vw_mo_ph   = ta.valuewhen(phMOM, momLBR,               1)
vw_mo_hph  = ta.valuewhen(phMOM, high[lbRight],        1)

// ── Divergence per indicator
rsi_bull = useRSIdiv  and plFound and (rsiLBR  > vw_rsi_pl)  and (lowLBR  < vw_low_pl)  and inRange_pl
rsi_bear = useRSIdiv  and phFound and (rsiLBR  < vw_rsi_ph)  and (highLBR > vw_high_ph) and inRange_ph
obv_bull = useOBVdiv  and plOBV   and (obvLBR  > vw_obv_pl)  and (lowLBR  < vw_obv_lpl) and inR_obv_pl
obv_bear = useOBVdiv  and phOBV   and (obvLBR  < vw_obv_ph)  and (highLBR > vw_obv_hph) and inR_obv_ph
mac_bull = useMACDdiv and plMACD  and (macdLBR > vw_m_pl)    and (lowLBR  < vw_m_lpl)   and inR_m_pl
mac_bear = useMACDdiv and phMACD  and (macdLBR < vw_m_ph)    and (highLBR > vw_m_hph)   and inR_m_ph
mom_bull = useMOMdiv  and plMOM   and (momLBR  > vw_mo_pl)   and (lowLBR  < vw_mo_lpl)  and inR_mo_pl
mom_bear = useMOMdiv  and phMOM   and (momLBR  < vw_mo_ph)   and (highLBR > vw_mo_hph)  and inR_mo_ph

div_bull_score = (rsi_bull ? 1 : 0) + (obv_bull ? 1 : 0) + (mac_bull ? 1 : 0) + (mom_bull ? 1 : 0)
div_bear_score = (rsi_bear ? 1 : 0) + (obv_bear ? 1 : 0) + (mac_bear ? 1 : 0) + (mom_bear ? 1 : 0)

bullCond     = calculateDivergence and div_bull_score >= minDivScore
bearCond     = calculateDivergence and div_bear_score >= minDivScore
bullCond_rsi = calculateDivergence and rsi_bull
bearCond_rsi = calculateDivergence and rsi_bear

// ═══════════════════════════════════════════════════════════════════
//  VOLUME & RVOL
// ═══════════════════════════════════════════════════════════════════
f_vol_ma(len, t) =>
    switch t
        "EMA" => ta.ema(volume, len)
        "WMA" => ta.wma(volume, len)
        "RMA" => ta.rma(volume, len)
        =>       ta.sma(volume, len)

vol_ma = f_vol_ma(volMaLen, volMaType)

// Volume window for divergence signal
volWin = false
for i = 0 to lbRight + 2
    if volume[i] > vol_ma[i]
        volWin := true
volOk = useVolFilter ? volWin : true

// RVOL: peak volume in window ÷ average
rvolPeak = 0.0
for i = 0 to lbRight + 2
    if volume[i] > rvolPeak
        rvolPeak := volume[i]
rvolVal  = vol_ma[lbRight] > 0 ? rvolPeak / vol_ma[lbRight] : 0.0
rvolHigh = useRVOL and rvolVal >= rvolThresh

// RVOL at current bar (for standalone Key Reversal signal)
rvolCurrent = vol_ma[0] > 0 ? volume[0] / vol_ma[0] : 0.0

// ═══════════════════════════════════════════════════════════════════
//  FIBONACCI ZONE
// ═══════════════════════════════════════════════════════════════════
lb_half = math.max(fibPivotLB / 2, 5)
sw_high = ta.pivothigh(high, lb_half, lb_half)
sw_low  = ta.pivotlow(low,   lb_half, lb_half)

var float fib_hi = na
var float fib_lo = na
if not na(sw_high)
    fib_hi := sw_high
if not na(sw_low)
    fib_lo := sw_low

fib_range = na(fib_hi) or na(fib_lo) ? na : fib_hi - fib_lo
fib_236   = na(fib_range) ? na : fib_hi - fib_range * 0.236
fib_382   = na(fib_range) ? na : fib_hi - fib_range * 0.382
fib_500   = na(fib_range) ? na : fib_hi - fib_range * 0.500
fib_618   = na(fib_range) ? na : fib_hi - fib_range * 0.618
fib_786   = na(fib_range) ? na : fib_hi - fib_range * 0.786

tol    = close[lbRight] * (fibProxPct / 100.0)
low_s  = low[lbRight]
high_s = high[lbRight]

f_nearFib(float price) =>
    not na(fib_range) and (
     math.abs(price - fib_lo)  <= tol or
     math.abs(price - fib_236) <= tol or
     math.abs(price - fib_382) <= tol or
     math.abs(price - fib_500) <= tol or
     math.abs(price - fib_618) <= tol or
     math.abs(price - fib_786) <= tol or
     math.abs(price - fib_hi)  <= tol)

fibOk_bull = useFibFilter ? (rvolHigh or f_nearFib(low_s))  : true
fibOk_bear = useFibFilter ? (rvolHigh or f_nearFib(high_s)) : true

// ═══════════════════════════════════════════════════════════════════
//  CANDLESTICK PATTERNS
// ═══════════════════════════════════════════════════════════════════
f_candle_bull(int off) =>
    o   = open [off]
    h   = high [off]
    l   = low  [off]
    c   = close[off]
    o1  = open [off + 1]
    h1  = high [off + 1]
    l1  = low  [off + 1]
    c1  = close[off + 1]
    o2  = open [off + 2]
    h2  = high [off + 2]
    l2  = low  [off + 2]
    c2  = close[off + 2]

    body      = math.abs(c - o)
    rng       = h - l
    uw        = h - math.max(o, c)
    lw        = math.min(o, c) - l
    sr        = math.max(rng,  0.0001)
    sb        = math.max(body, 0.0001)
    is_bull_c = c >= o
    body1     = math.abs(c1 - o1)
    rng1      = h1 - l1
    body2     = math.abs(c2 - o2)
    rng2      = h2 - l2
    sr2       = math.max(rng2, 0.0001)

    hammer      = use_hammer  and lw/sr >= 0.40 and lw >= body*wickRatio and uw <= body*0.5
    inv_hammer  = use_hammer  and is_bull_c and uw >= body*wickRatio and lw <= body*0.5 and uw/sr >= 0.35
    bull_engulf = use_engulf  and is_bull_c and (c1 < o1) and c > o1 and o < c1 and body > body1*0.8
    bull_pin    = use_pinbar  and lw/sr >= 0.55 and uw/sr <= 0.25
    dragonfly   = use_doji    and lw/sr >= 0.60 and body/sr <= 0.15
    doji_b      = use_doji    and body/sr <= dojiBodyPct and rng > 0
    ms_v2       = (c2 < o2) and (body2/sr2 >= 0.45)
    ms_v1       = body1 / math.max(rng1, 0.0001) <= 0.35
    ms_v0       = is_bull_c and c >= (o2 + c2) / 2
    morning     = use_morning and ms_v2 and ms_v1 and ms_v0
    // Key Reversal Bull: breaks prev low, closes above prev close, rejection tail
    kr_bull     = use_keyrev  and l < l1 and c > c1 and lw/sr >= 0.30 and (c - l)/sr >= 0.50

    hammer or inv_hammer or bull_engulf or bull_pin or dragonfly or doji_b or morning or kr_bull

f_candle_bear(int off) =>
    o   = open [off]
    h   = high [off]
    l   = low  [off]
    c   = close[off]
    o1  = open [off + 1]
    h1  = high [off + 1]
    l1  = low  [off + 1]
    c1  = close[off + 1]
    o2  = open [off + 2]
    h2  = high [off + 2]
    l2  = low  [off + 2]
    c2  = close[off + 2]

    body      = math.abs(c - o)
    rng       = h - l
    uw        = h - math.max(o, c)
    lw        = math.min(o, c) - l
    sr        = math.max(rng,  0.0001)
    is_bear_c = c <= o
    body1     = math.abs(c1 - o1)
    rng1      = h1 - l1
    body2     = math.abs(c2 - o2)
    rng2      = h2 - l2
    sr2       = math.max(rng2, 0.0001)

    shooting    = use_shooting and uw/sr >= 0.40 and uw >= body*wickRatio and lw <= body*0.5
    bear_engulf = use_engulf   and is_bear_c and (c1 > o1) and c < o1 and o > c1 and body > body1*0.8
    bear_pin    = use_pinbar   and uw/sr >= 0.55 and lw/sr <= 0.25
    gravestone  = use_doji     and uw/sr >= 0.60 and body/sr <= 0.15
    doji_b      = use_doji     and body/sr <= dojiBodyPct and rng > 0
    es_v2       = (c2 > o2) and (body2/sr2 >= 0.45)
    es_v1       = body1 / math.max(rng1, 0.0001) <= 0.35
    es_v0       = is_bear_c and c <= (o2 + c2) / 2
    evening     = use_evening  and es_v2 and es_v1 and es_v0
    // Key Reversal Bear: breaks prev high, closes below prev close, rejection tail
    kr_bear     = use_keyrev   and h > h1 and c < c1 and uw/sr >= 0.30 and (h - c)/sr >= 0.50

    shooting or bear_engulf or bear_pin or gravestone or doji_b or evening or kr_bear

// Scan window [lbRight .. lbRight + candleWindow]
bullPatFound = false
bearPatFound = false
for i = lbRight to lbRight + candleWindow
    if f_candle_bull(i)
        bullPatFound := true
    if f_candle_bear(i)
        bearPatFound := true

candleOk_bull = useCandleFilter ? bullPatFound : true
candleOk_bear = useCandleFilter ? bearPatFound : true

// ═══════════════════════════════════════════════════════════════════
//  STANDALONE KEY REVERSAL at current bar (offset = 0)
//  No divergence needed — fires on RVOL + Key Reversal pattern only
// ═══════════════════════════════════════════════════════════════════
// Key Reversal Bull at bar[0]
kr_now_bull = use_keyrev and useKeyRevStand and
     low[0]  < low[1]  and
     close[0] > close[1] and
     (math.min(open[0], close[0]) - low[0]) / math.max(high[0] - low[0], 0.0001) >= 0.30 and
     (close[0] - low[0]) / math.max(high[0] - low[0], 0.0001) >= 0.50 and
     rvolCurrent >= krRvolMin

// Key Reversal Bear at bar[0]
kr_now_bear = use_keyrev and useKeyRevStand and
     high[0]  > high[1] and
     close[0] < close[1] and
     (high[0] - math.max(open[0], close[0])) / math.max(high[0] - low[0], 0.0001) >= 0.30 and
     (high[0] - close[0]) / math.max(high[0] - low[0], 0.0001) >= 0.50 and
     rvolCurrent >= krRvolMin

// ═══════════════════════════════════════════════════════════════════
//  DIVERGENCE SIGNAL SCORE
//  1=Div | 2=Candle | 3=Volume | 4=Fibonacci | 5=RVOL
// ═══════════════════════════════════════════════════════════════════
score_bull = (bullCond      ? 1 : 0) +
             (candleOk_bull ? 1 : 0) +
             (volOk         ? 1 : 0) +
             (fibOk_bull    ? 1 : 0) +
             (rvolHigh      ? 1 : 0)

score_bear = (bearCond      ? 1 : 0) +
             (candleOk_bear ? 1 : 0) +
             (volOk         ? 1 : 0) +
             (fibOk_bear    ? 1 : 0) +
             (rvolHigh      ? 1 : 0)

divapBull = bullCond and score_bull >= minScore
divapBear = bearCond and score_bear >= minScore

// ═══════════════════════════════════════════════════════════════════
//  BARCOLOR — priority: Divergence > Key Reversal standalone
//  Divergence signal: offset = -lbRight (pivot bar)
//  Key Reversal standalone: offset = 0 (current bar)
// ═══════════════════════════════════════════════════════════════════
// Divergence candles (pivot bar)
barcolor(showDivapColor and divapBull ? bullCandleColor : na,
     offset=-lbRight, title="DIVAP Bull Candle")
barcolor(showDivapColor and divapBear ? bearCandleColor : na,
     offset=-lbRight, title="DIVAP Bear Candle")

// Standalone Key Reversal candles (current bar, no divergence needed)
barcolor(showDivapColor and useKeyRevStand and kr_now_bull and not divapBull ? krBullColor : na,
     offset=0, title="KR Bull Candle (Blue)")
barcolor(showDivapColor and useKeyRevStand and kr_now_bear and not divapBear ? krBearColor : na,
     offset=0, title="KR Bear Candle (Orange)")

// ═══════════════════════════════════════════════════════════════════
//  RSI PANEL
// ═══════════════════════════════════════════════════════════════════
noneColor    = color.new(color.white, 100)
bearColorDiv = color.red
bullColorDiv = color.green
textColorDiv = color.white

rsiPlot      = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band",  color=#787B86)
midline      = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band",  color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126,87,194,90), title="RSI Background Fill")
midLinePlot = plot(50, color=na, editable=false, display=display.none)
fill(rsiPlot, midLinePlot, 100, 70,
     top_color=color.new(color.green,0), bottom_color=color.new(color.green,100),
     title="Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30, 0,
     top_color=color.new(color.red,100), bottom_color=color.new(color.red,0),
     title="Oversold Gradient Fill")

plot(smoothingMA, "RSI-based MA", color=color.yellow,
     display=showAverage and enableMA ? display.all : display.none, editable=enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, "Upper Bollinger Band", color=color.green,
     display=isBB ? display.all : display.none, editable=isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, "Lower Bollinger Band", color=color.green,
     display=isBB ? display.all : display.none, editable=isBB)
fill(bbUpperBand, bbLowerBand,
     color=isBB ? color.new(color.green,90) : na,
     title="Bollinger Bands Background Fill",
     display=isBB ? display.all : display.none, editable=isBB)

// RSI divergence lines + labels
plot(plFound ? rsiLBR : na,
     offset=-lbRight, title="Regular Bullish", linewidth=2,
     color=bullCond_rsi ? bullColorDiv : noneColor,
     display=display.pane, editable=calculateDivergence)
plotshape(bullCond_rsi ? rsiLBR : na,
     offset=-lbRight, title="Regular Bullish Label",
     text=" Bull ", style=shape.labelup, location=location.absolute,
     color=bullColorDiv, textcolor=textColorDiv,
     display=display.pane, editable=calculateDivergence)

plot(phFound ? rsiLBR : na,
     offset=-lbRight, title="Regular Bearish", linewidth=2,
     color=bearCond_rsi ? bearColorDiv : noneColor,
     display=display.pane, editable=calculateDivergence)
plotshape(bearCond_rsi ? rsiLBR : na,
     offset=-lbRight, title="Regular Bearish Label",
     text=" Bear ", style=shape.labeldown, location=location.absolute,
     color=bearColorDiv, textcolor=textColorDiv,
     display=display.pane, editable=calculateDivergence)

// DIVAP markers (divergence signals)
plotshape(divapBull ? rsiLBR : na,
     offset=-lbRight, title="DIVAP Bull Marker",
     style=shape.circle, location=location.absolute,
     size=size.small, color=bullCandleColor, display=display.pane)
plotshape(divapBear ? rsiLBR : na,
     offset=-lbRight, title="DIVAP Bear Marker",
     style=shape.circle, location=location.absolute,
     size=size.small, color=bearCandleColor, display=display.pane)

// KR standalone markers no painel RSI
plotshape(kr_now_bull and not divapBull ? rsi : na,
     title="KR Bull Marker", style=shape.diamond,
     location=location.absolute, size=size.tiny,
     color=krBullColor, display=display.pane)
plotshape(kr_now_bear and not divapBear ? rsi : na,
     title="KR Bear Marker", style=shape.diamond,
     location=location.absolute, size=size.tiny,
     color=krBearColor, display=display.pane)

// ═══════════════════════════════════════════════════════════════════
//  ALERTAS
// ═══════════════════════════════════════════════════════════════════
alertcondition(bullCond_rsi,
     title="RSI Bullish Divergence",
     message="[DIVAP] Bullish RSI Div em {{ticker}} @ {{close}}")
alertcondition(bearCond_rsi,
     title="RSI Bearish Divergence",
     message="[DIVAP] Bearish RSI Div em {{ticker}} @ {{close}}")
alertcondition(divapBull,
     title="DIVAP Bull — Confluencia",
     message="[DIVAP] BULL {{ticker}} @ {{close}} — RSI+Candle+Vol+Fib")
alertcondition(divapBear,
     title="DIVAP Bear — Confluencia",
     message="[DIVAP] BEAR {{ticker}} @ {{close}} — RSI+Candle+Vol+Fib")
alertcondition(kr_now_bull,
     title="Key Reversal Bull (RVOL)",
     message="[DIVAP] KR BULL {{ticker}} @ {{close}} — Key Reversal + RVOL Alto")
alertcondition(kr_now_bear,
     title="Key Reversal Bear (RVOL)",
     message="[DIVAP] KR BEAR {{ticker}} @ {{close}} — Key Reversal + RVOL Alto")
````
