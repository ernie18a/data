# Ultimate Moving Averages Crossover

- url: https://www.tradingview.com/script/BL8uRcZy-Ultimate-Moving-Averages-Crossover/
- type: indicator
- pine_id: PUB;cd65bc579af44dee84e5d5ffe27eed08
- version: 1.0

## Description

1. Massive Moving Average Library (19 Types)
Instead of loading a different indicator for each type of average, this script has a built-in mathematical library that calculates 19 unique MA formulas. You can select any of these for each line:

Basic MAs: SMA (Simple), EMA (Exponential), WMA (Weighted)
Smoothed MAs: RMA (Running), HMA (Hull), DEMA (Double EMA), TEMA (Triple EMA), ZLEMA (Zero-Lag EMA)
Adaptive MAs: KAMA (Kaufman Adaptive), FRAMA (Fractal Adaptive), VAMA (Volatility Adjusted), McGinley Dynamic
Advanced MAs: ALMA (Arnaud Legoux), LSMA (Least Squares / Regression), TMA (Triangular), T3 (Tillson)
Volume Weighted MAs: VWMA (Standard Volume Weighted), EVWMA (Elastic Volume Weighted)
Symmetrical MAs: SWMA (Symmetrically Weighted)
2. Multi-Line Architecture (Up to 10 Lines)
You can plot up to 10 independent moving average lines on a single chart. For each line, the settings UI allows you to fully configure:

Toggle On/Off: Only plot the lines you need.
Type Selection: Choose any of the 19 types from the dropdown.
Source Data: Calculate based on close, open, high, low, hl2, hlc3, etc.
Length (Period): Define the lookback period (e.g., 20, 50, 200).
Visuals: Customize the color and line thickness.
3. Integrated Crossover Engine
The script functions as a built-in crossover scanner. You can explicitly assign any of the 10 MAs to act as your "Fast MA" and "Slow MA":

Visual Signals: When the Fast MA crosses above the Slow MA, it plots a green "Bullish Cross" triangle below the candle. When it crosses below, it plots a red "Bearish Cross" triangle above the candle.
Automated Alerts: It includes alertcondition functions. You can set up TradingView alerts to ping your phone or webhook when a "Bullish MA Crossover" or "Bearish MA Crossover" occurs.
Summary
In essence, it is an All-in-One Trend & Confluence Hub. By combining 19 algorithms, 10 customizable lines, and an automated crossover detection system, it gives you complete freedom to build any moving average strategy—like a 3-EMA ribbon, a Golden Cross scanner, or a Hull MA scalping setup—without ever leaving the script's settings.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © greymyst

//@version=6
indicator("Greymyst Ultimate Moving Averages", shorttitle="GM Averages", overlay=true)

// =================================================================================================
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
// ║                                   GREYMYST ULTIMATE MOVING AVERAGES                           ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════╝
// =================================================================================================

// -------------------------------------------------------------------------------------------------
// CONSTANTS & TYPES
// -------------------------------------------------------------------------------------------------
string GRP_MA1  = "Moving Average 1"
string GRP_MA2  = "Moving Average 2"
string GRP_MA3  = "Moving Average 3"
string GRP_MA4  = "Moving Average 4"
string GRP_MA5  = "Moving Average 5"
string GRP_MA6  = "Moving Average 6"
string GRP_MA7  = "Moving Average 7"
string GRP_MA8  = "Moving Average 8"
string GRP_MA9  = "Moving Average 9"
string GRP_MA10 = "Moving Average 10"
string GRP_CROSS = "Crossover & Alerts"

string TYPE_SMA   = "SMA (Simple)"
string TYPE_EMA   = "EMA (Exponential)"
string TYPE_WMA   = "WMA (Weighted)"
string TYPE_RMA   = "RMA (Running / SMMA)"
string TYPE_HMA   = "HMA (Hull)"
string TYPE_VWMA  = "VWMA (Volume Weighted)"
string TYPE_ALMA  = "ALMA (Arnaud Legoux)"
string TYPE_LSMA  = "LSMA (Least Squares)"
string TYPE_DEMA  = "DEMA (Double Exponential)"
string TYPE_TEMA  = "TEMA (Triple Exponential)"
string TYPE_ZLEMA = "ZLEMA (Zero-Lag EMA)"
string TYPE_KAMA  = "KAMA (Kaufman Adaptive)"
string TYPE_TMA   = "TMA (Triangular)"
string TYPE_MCG   = "McGinley Dynamic"
string TYPE_VAMA  = "VAMA (Volatility Adjusted)"
string TYPE_FRAMA = "FRAMA (Fractal Adaptive)"
string TYPE_T3    = "T3 (Tillson T3)"
string TYPE_SWMA  = "SWMA (Symmetrically Weighted)"
string TYPE_EVWMA = "EVWMA (Elastic Volume Weighted)"

// -------------------------------------------------------------------------------------------------
// HELPER FUNCTIONS FOR AVERAGES
// -------------------------------------------------------------------------------------------------
// DEMA
f_dema(src, len) =>
    e = ta.ema(src, len)
    2 * e - ta.ema(e, len)

// TEMA
f_tema(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    3 * (e1 - e2) + e3

// ZLEMA
f_zlema(src, len) =>
    lag = math.round((len - 1) / 2)
    ema_data = src + (src - src[lag])
    ta.ema(ema_data, len)

// KAMA
f_kama(src, len) =>
    change = math.abs(src - src[len])
    volatility = math.sum(math.abs(src - src[1]), len)
    er = volatility == 0 ? 0 : change / volatility
    fastAlpha = 2 / (2 + 1)
    slowAlpha = 2 / (30 + 1)
    sc = math.pow(er * (fastAlpha - slowAlpha) + slowAlpha, 2)
    float k = na
    k := nz(k[1], src) + sc * (src - nz(k[1], src))
    k

// TMA
f_tma(src, len) =>
    half = math.ceil(len / 2)
    ta.sma(ta.sma(src, half), half)

// McGinley Dynamic
f_mcg(src, len) =>
    float mg = na
    float ema_val = ta.ema(src, len)
    mg := na(mg[1]) ? ema_val : mg[1] + (src - mg[1]) / (len * math.pow(src / mg[1], 4))
    mg

// VAMA
f_vama(src, len) =>
    vol = ta.stdev(src, len)
    vSum = math.sum(vol, len)
    vAvg = vSum / len
    float weight = vol / vAvg
    math.sum(src * weight, len) / math.sum(weight, len)

// FRAMA
f_frama(src, len) =>
    w = len
    N1 = (math.max(high, w/2) - math.min(low, w/2)) / (w/2)
    N2 = (math.max(high[w/2], w/2) - math.min(low[w/2], w/2)) / (w/2)
    N3 = (math.max(high, w) - math.min(low, w)) / w
    D = (math.log(N1 + N2) - math.log(N3)) / math.log(2)
    alpha = math.exp(-4.6 * (D - 1))
    alpha := math.max(math.min(alpha, 1), 0.01)
    float frama = na
    frama := na(frama[1]) ? src : alpha * src + (1 - alpha) * nz(frama[1])
    frama

// T3
f_t3(src, len) =>
    vfactor = 0.7
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    e4 = ta.ema(e3, len)
    e5 = ta.ema(e4, len)
    e6 = ta.ema(e5, len)
    c1 = -vfactor * vfactor * vfactor
    c2 = 3 * vfactor * vfactor + 3 * vfactor * vfactor * vfactor
    c3 = -6 * vfactor * vfactor - 3 * vfactor - 3 * vfactor * vfactor * vfactor
    c4 = 1 + 3 * vfactor + vfactor * vfactor * vfactor + 3 * vfactor * vfactor
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

// EVWMA
f_evwma(src, len) =>
    float vol_sum = math.sum(volume, len)
    float evwma = na
    evwma := na(evwma[1]) ? src : (evwma[1] * (vol_sum - volume) + src * volume) / vol_sum
    evwma


// MASTER CALCULATION FUNCTION
f_get_ma(src, len, ma_type) =>
    float ma = na
    switch ma_type
        TYPE_SMA   => ma := ta.sma(src, len)
        TYPE_EMA   => ma := ta.ema(src, len)
        TYPE_WMA   => ma := ta.wma(src, len)
        TYPE_RMA   => ma := ta.rma(src, len)
        TYPE_HMA   => ma := ta.hma(src, len)
        TYPE_VWMA  => ma := ta.vwma(src, len)
        TYPE_ALMA  => ma := ta.alma(src, len, 0.85, 6)
        TYPE_LSMA  => ma := ta.linreg(src, len, 0)
        TYPE_DEMA  => ma := f_dema(src, len)
        TYPE_TEMA  => ma := f_tema(src, len)
        TYPE_ZLEMA => ma := f_zlema(src, len)
        TYPE_KAMA  => ma := f_kama(src, len)
        TYPE_TMA   => ma := f_tma(src, len)
        TYPE_MCG   => ma := f_mcg(src, len)
        TYPE_VAMA  => ma := f_vama(src, len)
        TYPE_FRAMA => ma := f_frama(src, len)
        TYPE_T3    => ma := f_t3(src, len)
        TYPE_SWMA  => 
            float swma_val = ta.swma(src)
            float sma_val = ta.sma(src, len)
            ma := len == 4 ? swma_val : sma_val // SWMA only supports len 4 in built-in
        TYPE_EVWMA => ma := f_evwma(src, len)
        => ma := ta.sma(src, len)
    ma


// -------------------------------------------------------------------------------------------------
// INPUTS
// -------------------------------------------------------------------------------------------------
string[] all_types = array.from(TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA)

// MA 1
en1    = input.bool(true, title="Enable MA 1", group=GRP_MA1)
type1  = input.string(TYPE_EMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA1)
src1   = input.source(close, "Source", group=GRP_MA1)
len1   = input.int(20, "Length", minval=1, group=GRP_MA1)
col1   = input.color(color.new(#2196F3, 0), "Color", group=GRP_MA1)

// MA 2
en2    = input.bool(true, title="Enable MA 2", group=GRP_MA2)
type2  = input.string(TYPE_EMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA2)
src2   = input.source(close, "Source", group=GRP_MA2)
len2   = input.int(50, "Length", minval=1, group=GRP_MA2)
col2   = input.color(color.new(#FF9800, 0), "Color", group=GRP_MA2)

// MA 3
en3    = input.bool(true, title="Enable MA 3", group=GRP_MA3)
type3  = input.string(TYPE_EMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA3)
src3   = input.source(close, "Source", group=GRP_MA3)
len3   = input.int(100, "Length", minval=1, group=GRP_MA3)
col3   = input.color(color.new(#E91E63, 0), "Color", group=GRP_MA3)

// MA 4
en4    = input.bool(true, title="Enable MA 4", group=GRP_MA4)
type4  = input.string(TYPE_EMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA4)
src4   = input.source(close, "Source", group=GRP_MA4)
len4   = input.int(200, "Length", minval=1, group=GRP_MA4)
col4   = input.color(color.new(#9C27B0, 0), "Color", group=GRP_MA4)

// MA 5
en5    = input.bool(false, title="Enable MA 5", group=GRP_MA5)
type5  = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA5)
src5   = input.source(close, "Source", group=GRP_MA5)
len5   = input.int(10, "Length", minval=1, group=GRP_MA5)
col5   = input.color(color.new(#00BCD4, 0), "Color", group=GRP_MA5)

// MA 6
en6    = input.bool(false, title="Enable MA 6", group=GRP_MA6)
type6  = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA6)
src6   = input.source(close, "Source", group=GRP_MA6)
len6   = input.int(21, "Length", minval=1, group=GRP_MA6)
col6   = input.color(color.new(#4CAF50, 0), "Color", group=GRP_MA6)

// MA 7
en7    = input.bool(false, title="Enable MA 7", group=GRP_MA7)
type7  = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA7)
src7   = input.source(close, "Source", group=GRP_MA7)
len7   = input.int(34, "Length", minval=1, group=GRP_MA7)
col7   = input.color(color.new(#CDDC39, 0), "Color", group=GRP_MA7)

// MA 8
en8    = input.bool(false, title="Enable MA 8", group=GRP_MA8)
type8  = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA8)
src8   = input.source(close, "Source", group=GRP_MA8)
len8   = input.int(55, "Length", minval=1, group=GRP_MA8)
col8   = input.color(color.new(#FFEB3B, 0), "Color", group=GRP_MA8)

// MA 9
en9    = input.bool(false, title="Enable MA 9", group=GRP_MA9)
type9  = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA9)
src9   = input.source(close, "Source", group=GRP_MA9)
len9   = input.int(89, "Length", minval=1, group=GRP_MA9)
col9   = input.color(color.new(#FFC107, 0), "Color", group=GRP_MA9)

// MA 10
en10   = input.bool(false, title="Enable MA 10", group=GRP_MA10)
type10 = input.string(TYPE_SMA, "Type", options=[TYPE_SMA, TYPE_EMA, TYPE_WMA, TYPE_RMA, TYPE_HMA, TYPE_VWMA, TYPE_ALMA, TYPE_LSMA, TYPE_DEMA, TYPE_TEMA, TYPE_ZLEMA, TYPE_KAMA, TYPE_TMA, TYPE_MCG, TYPE_VAMA, TYPE_FRAMA, TYPE_T3, TYPE_SWMA, TYPE_EVWMA], group=GRP_MA10)
src10  = input.source(close, "Source", group=GRP_MA10)
len10  = input.int(144, "Length", minval=1, group=GRP_MA10)
col10  = input.color(color.new(#795548, 0), "Color", group=GRP_MA10)

// CROSSOVER SETTINGS
en_cross    = input.bool(true, "Enable Crossover Markers", group=GRP_CROSS)
cross_fast  = input.string("MA 1", "Fast MA", options=["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], group=GRP_CROSS)
cross_slow  = input.string("MA 2", "Slow MA", options=["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], group=GRP_CROSS)
cross_colUp = input.color(color.new(#00E676, 0), "Bullish Cross Color", group=GRP_CROSS)
cross_colDn = input.color(color.new(#FF5252, 0), "Bearish Cross Color", group=GRP_CROSS)

// -------------------------------------------------------------------------------------------------
// CALCULATIONS
// -------------------------------------------------------------------------------------------------
ma1  = en1  ? f_get_ma(src1,  len1,  type1)  : na
ma2  = en2  ? f_get_ma(src2,  len2,  type2)  : na
ma3  = en3  ? f_get_ma(src3,  len3,  type3)  : na
ma4  = en4  ? f_get_ma(src4,  len4,  type4)  : na
ma5  = en5  ? f_get_ma(src5,  len5,  type5)  : na
ma6  = en6  ? f_get_ma(src6,  len6,  type6)  : na
ma7  = en7  ? f_get_ma(src7,  len7,  type7)  : na
ma8  = en8  ? f_get_ma(src8,  len8,  type8)  : na
ma9  = en9  ? f_get_ma(src9,  len9,  type9)  : na
ma10 = en10 ? f_get_ma(src10, len10, type10) : na

// Dynamic crossover selection
f_get_selected_ma(selection) =>
    float res = na
    switch selection
        "MA 1" => res := ma1
        "MA 2" => res := ma2
        "MA 3" => res := ma3
        "MA 4" => res := ma4
        "MA 5" => res := ma5
        "MA 6" => res := ma6
        "MA 7" => res := ma7
        "MA 8" => res := ma8
        "MA 9" => res := ma9
        "MA 10" => res := ma10
    res

fast_ma = f_get_selected_ma(cross_fast)
slow_ma = f_get_selected_ma(cross_slow)

// CROSS LOGIC
bull_cross = ta.crossover(fast_ma, slow_ma)
bear_cross = ta.crossunder(fast_ma, slow_ma)

// -------------------------------------------------------------------------------------------------
// PLOTTING
// -------------------------------------------------------------------------------------------------
plot(ma1,  "MA 1",  en1  ? col1  : na, linewidth=2)
plot(ma2,  "MA 2",  en2  ? col2  : na, linewidth=2)
plot(ma3,  "MA 3",  en3  ? col3  : na, linewidth=2)
plot(ma4,  "MA 4",  en4  ? col4  : na, linewidth=2)
plot(ma5,  "MA 5",  en5  ? col5  : na, linewidth=1)
plot(ma6,  "MA 6",  en6  ? col6  : na, linewidth=1)
plot(ma7,  "MA 7",  en7  ? col7  : na, linewidth=1)
plot(ma8,  "MA 8",  en8  ? col8  : na, linewidth=1)
plot(ma9,  "MA 9",  en9  ? col9  : na, linewidth=1)
plot(ma10, "MA 10", en10 ? col10 : na, linewidth=1)

plotshape(en_cross and bull_cross, title="Bullish Cross", style=shape.triangleup,   location=location.belowbar, color=cross_colUp, size=size.small)
plotshape(en_cross and bear_cross, title="Bearish Cross", style=shape.triangledown, location=location.abovebar, color=cross_colDn, size=size.small)

// -------------------------------------------------------------------------------------------------
// ALERTS
// -------------------------------------------------------------------------------------------------
alertcondition(bull_cross, title="Bullish MA Crossover", message="Greymyst MA: Fast MA crossed above Slow MA!")
alertcondition(bear_cross, title="Bearish MA Crossover", message="Greymyst MA: Fast MA crossed below Slow MA!")
````
