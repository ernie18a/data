# Tribulus & Ginseng Power

- url: https://www.tradingview.com/script/LDHgRI5J/
- type: indicator
- pine_id: PUB;59f97bcad5664240a488ad72f117e33b
- version: 1.0

## Description

What is Tribulus & Ginseng Power?
Tribulus & Ginseng Power is an advanced inter-market macro strategy engine designed to identify institutional trend reversals and liquidity sweeps in high-volatility financial markets. Rather than analyzing an asset in isolation, this algorithm cross-examines live telemetry from three critical pillars of the crypto ecosystem simultaneously to confirm institutional dominance before executing order signals.

How the Multiverse Matrix Core Works:
The script acts as a command center analyzing three independent algorithmic engines:

The Main Asset Engine (M): Evaluates the selected chart using specialized swing detection, price action anomalies (Sushi Rolls), and premium kernel smoothing processes (Monalisa and UT Bot matrices) to find mathematical market exhaustion.

The Crypto Total Market Cap Engine (T): Requests live structural data behind the scenes from CRYPTOCAP:TOTAL to track whether global macro capital flow supports the localized trend breakout.

The Bitcoin Dominance Engine (D): Interrogates CRYPTOCAP:BTC.D to identify where global risk-on or risk-off sentiment is clustering (Bitcoin vs. Altcoins).

The Signal Breakdown Matrix:
By analyzing macro matrix alignments, the indicator prints institutional-tier alerts:

💎 PERFECT L: Global capital flows are expanding (TOTAL bullish), Bitcoin dominance matches, and the local chart confirms a bottom. High-probability premium bullish trigger.

🚀 ALT L (Altcoin Rally): Local price points upward while TOTAL cap rises and BTC.D drops, capturing the exact momentum shift where money floods into high-beta altcoins.

🩸 CRASH S: Direct macro distribution model. Major capitals are exiting the ecosystem while charts break local liquidity floors.

⚡ EARLY L / S (Early Macro Alignment): Fires instantly when the global macro telemetry matrices align before the local price reflects it, offering professional early entries before the momentum candle arrives.

Optimal Environments & Parameters:
Premium Assets: Highly volatile majors (BTC, ETH, high-cap layer-1 protocols) and major indices (NAS100, SPX).

Ideal Timeframes: Curated natively for 1-Hour (1h) and 4-Hour (4h) charts for long-form matrix confirmation. Can be scaled down to 15-Minute (15m) charts for intra-day trading.

Automation Ready: Configured with a stateful position lifecycle manager fully optimized for WunderTrading, 3Commas, or private server webhook routing. If a counter-signal is triggered, the system automatically executes a Close-First, Open-Next alert sequence to prevent cross-order jams on the exchange.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("Tribulus & Ginseng Power", overlay=true, max_labels_count=500, max_bars_back=500)

// =========================================================================
// --- GLOBAL INPUTS & SETTINGS ---
// =========================================================================
grp_m1 = "Engine 1: Sushi & Lux"
factor_sl     = input.int(1, "Engulfing Factor", group=grp_m1)
length_sl     = input.int(10, "Swing Detection", group=grp_m1)
mult_sl       = input.float(0.8, "Slope", minval = 0, step = .1, group=grp_m1)
calcMethod_sl = input.string("Atr", "Calculation Method", options = ["Atr","Stdev","Linreg"], group=grp_m1)

grp_m2_tf = "Engine 2: TrendFlex"
volThreshold  = input.int(10000, "Pump Volume Threshold", group=grp_m2_tf)
average       = input.int(5, "Pump MA Length", group=grp_m2_tf)
multipleX     = input.int(2, "Pump Multiplier", group=grp_m2_tf)

grp_m2_ml = "Engine 2: Monalisa"
h             = input.float(5.0, "Bandwidth Length", group=grp_m2_ml)
mult          = input.float(2.0, "Monalisa Multiplier", group=grp_m2_ml)

grp_m2_ut = "Engine 2: UT Bot"
aMultiplier   = input.float(1.0, "UT Bot Multiplier", group=grp_m2_ut)
aPeriod       = input.int(1, "UT Bot ATR Period", group=grp_m2_ut)

grp_m2_liq = "Engine 2: AFY Liquidity"
lookback      = input.int(24, "Liquidity Scan Lookback", group=grp_m2_liq)
use_afy       = input.bool(false, "Require AFY Liquidity Confirmation", group=grp_m2_liq)

grp_m2_adx = "Engine 2: ADX Filter"
use_adx       = input.bool(true, "ADX Trend Filter Active", group=grp_m2_adx)
adx_threshold = input.int(1, "Min ADX Strength Threshold", group=grp_m2_adx)

grp_m3 = "Engine 3: Anomaly Filters"
use_rsi_filter  = input.bool(false, "Filter A: RSI Momentum", group=grp_m3)
rsi_len         = input.int(14, "RSI Period", group=grp_m3)
rsi_upper       = input.int(60, "RSI Overbought Boundary", group=grp_m3)
rsi_lower       = input.int(40, "RSI Oversold Boundary", group=grp_m3)
rsi_lookback    = input.int(5, "RSI Momentum Scan Lookback", group=grp_m3)
use_macd_filter = input.bool(false, "Filter B: MACD Momentum", group=grp_m3)
use_atr_filter  = input.bool(false, "Filter C: ATR Volatility Memory", group=grp_m3)
atr_len_filter  = input.int(14, "ATR Filter Period", group=grp_m3)
atr_mult_filter = input.float(1.2, "Candle Body Expansion Ratio", step=0.1, group=grp_m3)
atr_lookback    = input.int(5, "ATR Volatility Scan Lookback", group=grp_m3)

grp_macro = "Macro Matrix: Alignment Rules"
macro_lookback  = input.int(10, "Macro Signal Memory (Alignment Window)", group=grp_macro)

// =========================================================================
// --- SAFE CORE FUNCTIONS ---
// =========================================================================
f_mona(src, h_val) =>
    float den = 0.
    float out = 0.
    for i = 0 to 499
        float w = math.exp(-(math.pow(i, 2) / (h_val * h_val * 2)))
        out += nz(src[i]) * w
        den += w
    out / den

f_slope(src, len, mlt, typ, n) =>
    typ == "Atr" ? (ta.atr(len) / len * mlt) : typ == "Stdev" ? (ta.stdev(src, len) / len * mlt) : (math.abs(ta.sma(src * n, len) - ta.sma(src, len) * ta.sma(n, len)) / ta.variance(n, len) / 2 * mlt)

// =========================================================================
// --- INTER-ASSET MACRO TELEMETRY (INTER-MARKET) ---
// =========================================================================
[tot_o, tot_h, tot_l, tot_c, tot_v] = request.security("CRYPTOCAP:TOTAL", timeframe.period, [open, high, low, close, volume])
[dom_o, dom_h, dom_l, dom_c, dom_v] = request.security("CRYPTOCAP:BTC.D", timeframe.period, [open, high, low, close, volume])

[plusDI, minusDI, adxValue] = ta.dmi(14, 14)
bool adx_ok = not use_adx or (adxValue >= adx_threshold)
float n_idx = bar_index

// =========================================================================
// --- ENGINE 1: MAIN ASSET CHART DATA (M) ---
// =========================================================================
float rMax_m = ta.highest(high, factor_sl)
float rMin_m = ta.lowest(low, factor_sl)
float maxV_m = ta.highest(high, factor_sl * 2)
float minV_m = ta.lowest(low, factor_sl * 2)

bool valid_m = (rMin_m == minV_m) and (rMax_m == maxV_m) and nz(minV_m == low[factor_sl - 1] or maxV_m == high[factor_sl - 1])
bool sushi_m = valid_m and ta.barssince(valid_m[1]) >= factor_sl and barstate.isconfirmed

float lastMax_m = fixnan((sushi_m and not sushi_m[1]) and (rMax_m == maxV_m) ? maxV_m : na)
float lastMin_m = fixnan((sushi_m and not sushi_m[1]) ? minV_m : na)

var int dir_m = na
dir_m := ta.crossover(close, lastMax_m) ? 1 : ta.crossunder(close, lastMin_m) ? 0 : dir_m

bool sBull_m = (dir_m == 1) and nz(dir_m[1]) != 1
bool sBear_m = (dir_m == 0) and nz(dir_m[1]) != 0

float ph_m = ta.pivothigh(high, length_sl, length_sl)
float pl_m = ta.pivotlow(low, length_sl, length_sl)
float slope_m = f_slope(close, length_sl, mult_sl, calcMethod_sl, n_idx)

var float sph_m = 0., var float spl_m = 0.
sph_m := not na(ph_m) ? slope_m : sph_m
spl_m := not na(pl_m) ? slope_m : spl_m

var float up_m = 0., var float dn_m = 0.
up_m := not na(ph_m) ? ph_m : up_m - sph_m
dn_m := not na(pl_m) ? pl_m : dn_m + spl_m

var int upos_m = 0, var int dnos_m = 0
upos_m := not na(ph_m) ? 0 : close > up_m - sph_m * length_sl ? 1 : upos_m
dnos_m := not na(pl_m) ? 0 : close < dn_m + spl_m * length_sl ? 1 : dnos_m

bool lBull_m = upos_m > upos_m[1]
bool lBear_m = dnos_m > dnos_m[1]

var bool wS_L_m = false, var bool wL_L_m = false, var int t_L_m = 0
var bool wS_S_m = false, var bool wL_S_m = false, var int t_S_m = 0

t_L_m := (wS_L_m or wL_L_m) ? t_L_m + 1 : t_L_m
t_S_m := (wS_S_m or wL_S_m) ? t_S_m + 1 : t_S_m

wS_L_m := t_L_m > 12 ? false : wS_L_m
wL_L_m := t_L_m > 12 ? false : wL_L_m
t_L_m := t_L_m > 12 ? 0 : t_L_m
wS_S_m := t_S_m > 12 ? false : wS_S_m
wL_S_m := t_S_m > 12 ? false : wL_S_m
t_S_m := t_S_m > 12 ? 0 : t_S_m

bool slL_m = false, bool slS_m = false

if sBull_m
    slL_m := (wL_L_m and t_L_m <= 12), wS_L_m := not slL_m, wL_L_m := false, t_L_m := 0
if lBull_m
    slL_m := (wS_L_m and t_L_m <= 12), wL_L_m := not slL_m, wS_L_m := false, t_L_m := 0
if sBear_m
    slS_m := (wL_S_m and t_S_m <= 12), wS_S_m := not slS_m, wL_S_m := false, t_S_m := 0
if lBear_m
    slS_m := (wS_S_m and t_S_m <= 12), wL_S_m := not slS_m, wS_S_m := false, t_S_m := 0

float fastTBO_m = ta.ema(close, 20)
bool pmp_m = (close > fastTBO_m and volume > volThreshold) or (close < fastTBO_m and volume > volThreshold)

bool swL_m = low < ta.lowest(low[1], lookback) and close > ta.lowest(low[1], lookback) 
bool swS_m = high > ta.highest(high[1], lookback) and close < ta.highest(high[1], lookback) 
bool afyL_m = not use_afy or ta.barssince(swL_m) <= 10
bool afyS_m = not use_afy or ta.barssince(swS_m) <= 10

float out_m = f_mona(close, h)
float mae_m = ta.sma(math.abs(close - out_m), 499) * mult
bool m_L_m = ta.crossunder(close, out_m - mae_m)
bool m_S_m = ta.crossover(close, out_m + mae_m)

var int mb_m = 0
mb_m := m_L_m ? 1 : m_S_m ? -1 : mb_m

float nL_m = aMultiplier * ta.atr(aPeriod)
var float xTS_m = 0.0
xTS_m := close > nz(xTS_m[1], 0) and close[1] > nz(xTS_m[1], 0) ? math.max(nz(xTS_m[1]), close - nL_m) : close < nz(xTS_m[1], 0) and close[1] < nz(xTS_m[1], 0) ? math.min(nz(xTS_m[1]), close + nL_m) : close > nz(xTS_m[1], 0) ? close - nL_m : close + nL_m

var int pos_m = 0
pos_m := close > nz(xTS_m[1], 0) and close[1] <= nz(xTS_m[1], 0) ? 1 : close < nz(xTS_m[1], 0) and close[1] >= nz(xTS_m[1], 0) ? -1 : nz(pos_m[1], 0)
bool uL_m = pos_m == 1 and pos_m[1] != 1
bool uS_m = pos_m == -1 and pos_m[1] != -1

bool rm_L_m = ((m_L_m and pos_m == 1) or (uL_m and mb_m == 1)) and afyL_m and adx_ok
bool rm_S_m = ((m_S_m and pos_m == -1) or (uS_m and mb_m == -1)) and afyS_m and adx_ok

var int phz_m = 0
phz_m := pmp_m ? 1 : phz_m
bool mhB_m = false, bool mhS_m = false

if phz_m == 1
    if rm_S_m
        mhB_m := true, phz_m := 2 
    else if rm_L_m
        mhS_m := true, phz_m := 2
else if phz_m == 2
    if rm_L_m
        mhB_m := true, phz_m := 0 
    else if rm_S_m
        mhS_m := true, phz_m := 0

var bool wMH_L_m = false, var bool wSL_L_m = false, var int tuL_m = 0
var bool wMH_S_m = false, var bool wSL_S_m = false, var int tuS_m = 0

tuL_m := (wMH_L_m or wSL_L_m) ? tuL_m + 1 : tuL_m
tuS_m := (wMH_S_m or wSL_S_m) ? tuS_m + 1 : tuS_m

wMH_L_m := tuL_m > 16 ? false : wMH_L_m
wSL_L_m := tuL_m > 16 ? false : wSL_L_m
tuL_m := tuL_m > 16 ? 0 : tuL_m
wMH_S_m := tuS_m > 16 ? false : wMH_S_m
wSL_S_m := tuS_m > 16 ? false : wSL_S_m
tuS_m := tuS_m > 16 ? 0 : tuS_m

bool ULT_L_m = false, bool ULT_S_m = false

if mhB_m
    ULT_L_m := (wSL_L_m and tuL_m <= 16), wMH_L_m := not ULT_L_m, wSL_L_m := false, tuL_m := 0
if slL_m
    ULT_L_m := (wMH_L_m and tuL_m <= 16), wSL_L_m := not ULT_L_m, wMH_L_m := false, tuL_m := 0
if mhS_m
    ULT_S_m := (wSL_S_m and tuS_m <= 16), wMH_S_m := not ULT_S_m, wSL_S_m := false, tuS_m := 0
if slS_m
    ULT_S_m := (wMH_S_m and tuS_m <= 16), wSL_S_m := not ULT_S_m, wMH_S_m := false, tuS_m := 0

// =========================================================================
// --- ENGINE 2: TOTAL MARKET CAPMETRY (T) ---
// =========================================================================
float rMax_t = ta.highest(tot_h, factor_sl)
float rMin_t = ta.lowest(tot_l, factor_sl)
float maxV_t = ta.highest(tot_h, factor_sl * 2)
float minV_t = ta.lowest(tot_l, factor_sl * 2)

bool valid_t = (rMin_t == minV_t) and (rMax_t == maxV_t) and nz(minV_t == tot_l[factor_sl - 1] or maxV_t == tot_h[factor_sl - 1])
bool sushi_t = valid_t and ta.barssince(valid_t[1]) >= factor_sl and barstate.isconfirmed

float lastMax_t = fixnan((sushi_t and not sushi_t[1]) and (rMax_t == maxV_t) ? maxV_t : na)
float lastMin_t = fixnan((sushi_t and not sushi_t[1]) ? minV_t : na)

var int dir_t = na
dir_t := ta.crossover(tot_c, lastMax_t) ? 1 : ta.crossunder(tot_c, lastMin_t) ? 0 : dir_t

bool sBull_t = (dir_t == 1) and nz(dir_t[1]) != 1
bool sBear_t = (dir_t == 0) and nz(dir_t[1]) != 0

float ph_t = ta.pivothigh(tot_h, length_sl, length_sl)
float pl_t = ta.pivotlow(tot_l, length_sl, length_sl)
float tr_t = math.max(tot_h - tot_l, math.max(math.abs(tot_h - nz(tot_c[1])), math.abs(tot_l - nz(tot_c[1]))))
float atr_t = ta.sma(tr_t, length_sl)

float slope_t = calcMethod_sl == "Atr" ? (atr_t / length_sl * mult_sl) : calcMethod_sl == "Stdev" ? (ta.stdev(tot_c, length_sl) / length_sl * mult_sl) : (math.abs(ta.sma(tot_c * n_idx, length_sl) - ta.sma(tot_c, length_sl) * ta.sma(n_idx, length_sl)) / ta.variance(n_idx, length_sl) / 2 * mult_sl)

var float sph_t = 0., var float spl_t = 0.
sph_t := not na(ph_t) ? slope_t : sph_t
spl_t := not na(pl_t) ? slope_t : spl_t

var float up_t = 0., var float dn_t = 0.
up_t := not na(ph_t) ? ph_t : up_t - sph_t
dn_t := not na(pl_t) ? pl_t : dn_t + spl_t

var int upos_t = 0, var int dnos_t = 0
upos_t := not na(ph_t) ? 0 : tot_c > up_t - sph_t * length_sl ? 1 : upos_t
dnos_t := not na(pl_t) ? 0 : tot_c < dn_t + spl_t * length_sl ? 1 : dnos_t

bool lBull_t = upos_t > upos_t[1]
bool lBear_t = dnos_t > dnos_t[1]

var bool wS_L_t = false, var bool wL_L_t = false, var int t_L_t = 0
var bool wS_S_t = false, var bool wL_S_t = false, var int t_S_t = 0

t_L_t := (wS_L_t or wL_L_t) ? t_L_t + 1 : t_L_t
t_S_t := (wS_S_t or wL_S_t) ? t_S_t + 1 : t_S_t

wS_L_t := t_L_t > 12 ? false : wS_L_t
wL_L_t := t_L_t > 12 ? false : wL_L_t
t_L_t := t_L_t > 12 ? 0 : t_L_t
wS_S_t := t_S_t > 12 ? false : wS_S_t
wL_S_t := t_S_t > 12 ? false : wL_S_t
t_S_t := t_S_t > 12 ? 0 : t_S_t

bool slL_t = false, bool slS_t = false

if sBull_t
    slL_t := (wL_L_t and t_L_t <= 12), wS_L_t := not slL_t, wL_L_t := false, t_L_t := 0
if lBull_t
    slL_t := (wS_L_t and t_L_t <= 12), wL_L_t := not slL_t, wS_L_t := false, t_L_t := 0
if sBear_t
    slS_t := (wL_S_t and t_S_t <= 12), wS_S_t := not slS_t, wL_S_t := false, t_S_t := 0
if lBear_t
    slS_t := (wS_S_t and t_S_t <= 12), wL_S_t := not slS_t, wS_S_t := false, t_S_t := 0

bool pmp_t = tr_t > atr_t 

bool swL_t = tot_l < ta.lowest(tot_l[1], lookback) and tot_c > ta.lowest(tot_l[1], lookback) 
bool swS_t = tot_h > ta.highest(tot_h[1], lookback) and tot_c < ta.highest(tot_h[1], lookback) 
bool afyL_t = not use_afy or ta.barssince(swL_t) <= 10
bool afyS_t = not use_afy or ta.barssince(swS_t) <= 10

float out_t = f_mona(tot_c, h)
float mae_t = ta.sma(math.abs(tot_c - out_t), 499) * mult
bool m_L_t = ta.crossunder(tot_c, out_t - mae_t)
bool m_S_t = ta.crossover(tot_c, out_t + mae_t)

var int mb_t = 0
mb_t := m_L_t ? 1 : m_S_t ? -1 : mb_t

float nL_t = aMultiplier * ta.sma(tr_t, aPeriod)
var float xTS_t = 0.0
xTS_t := tot_c > nz(xTS_t[1], 0) and tot_c[1] > nz(xTS_t[1], 0) ? math.max(nz(xTS_t[1]), tot_c - nL_t) : tot_c < nz(xTS_t[1], 0) and tot_c[1] < nz(xTS_t[1], 0) ? math.min(nz(xTS_t[1]), tot_c + nL_t) : tot_c > nz(xTS_t[1], 0) ? tot_c - nL_t : tot_c + nL_t

var int pos_t = 0
pos_t := tot_c > nz(xTS_t[1], 0) and tot_c[1] <= nz(xTS_t[1], 0) ? 1 : tot_c < nz(xTS_t[1], 0) and tot_c[1] >= nz(xTS_t[1], 0) ? -1 : nz(pos_t[1], 0)
bool uL_t = pos_t == 1 and pos_t[1] != 1
bool uS_t = pos_t == -1 and pos_t[1] != -1

bool rm_L_t = ((m_L_t and pos_t == 1) or (uL_t and mb_t == 1)) and afyL_t
bool rm_S_t = ((m_S_t and pos_t == -1) or (uS_t and mb_t == -1)) and afyS_t

var int phz_t = 0
phz_t := pmp_t ? 1 : phz_t
bool mhB_t = false, bool mhS_t = false

if phz_t == 1
    if rm_S_t
        mhB_t := true, phz_t := 2 
    else if rm_L_t
        mhS_t := true, phz_t := 2
else if phz_t == 2
    if rm_L_t
        mhB_t := true, phz_t := 0 
    else if rm_S_t
        mhS_t := true, phz_t := 0

var bool wMH_L_t = false, var bool wSL_L_t = false, var int tuL_t = 0
var bool wMH_S_t = false, var bool wSL_S_t = false, var int tuS_t = 0

tuL_t := (wMH_L_t or wSL_L_t) ? tuL_t + 1 : tuL_t
tuS_t := (wMH_S_t or wSL_S_t) ? tuS_t + 1 : tuS_t

wMH_L_t := tuL_t > 16 ? false : wMH_L_t
wSL_L_t := tuL_t > 16 ? false : wSL_L_t
tuL_t := tuL_t > 16 ? 0 : tuL_t
wMH_S_t := tuS_t > 16 ? false : wMH_S_t
wSL_S_t := tuS_t > 16 ? false : wSL_S_t
tuS_t := tuS_t > 16 ? 0 : tuS_t

bool ULT_L_t = false, bool ULT_S_t = false

if mhB_t
    ULT_L_t := (wSL_L_t and tuL_t <= 16), wMH_L_t := not ULT_L_t, wSL_L_t := false, tuL_t := 0
if slL_t
    ULT_L_t := (wMH_L_t and tuL_t <= 16), wSL_L_t := not ULT_L_t, wMH_L_t := false, tuL_t := 0
if mhS_t
    ULT_S_t := (wSL_S_t and tuS_t <= 16), wMH_S_t := not ULT_S_t, wSL_S_t := false, tuS_t := 0
if slS_t
    ULT_S_t := (wMH_S_t and tuS_t <= 16), wSL_S_t := not ULT_S_t, wMH_S_t := false, tuS_t := 0

// =========================================================================
// --- ENGINE 3: BTC DOMINANCE STRUCT (D) ---
// =========================================================================
float rMax_d = ta.highest(dom_h, factor_sl)
float rMin_d = ta.lowest(dom_l, factor_sl)
float maxV_d = ta.highest(dom_h, factor_sl * 2)
float minV_d = ta.lowest(dom_l, factor_sl * 2)

bool valid_d = (rMin_d == minV_d) and (rMax_d == maxV_d) and nz(minV_d == dom_l[factor_sl - 1] or maxV_d == dom_h[factor_sl - 1])
bool sushi_d = valid_d and ta.barssince(valid_d[1]) >= factor_sl and barstate.isconfirmed

float lastMax_d = fixnan((sushi_d and not sushi_d[1]) and (rMax_d == maxV_d) ? maxV_d : na)
float lastMin_d = fixnan((sushi_d and not sushi_d[1]) ? minV_d : na)

var int dir_d = na
dir_d := ta.crossover(dom_c, lastMax_d) ? 1 : ta.crossunder(dom_c, lastMin_d) ? 0 : dir_d

bool sBull_d = (dir_d == 1) and nz(dir_d[1]) != 1
bool sBear_d = (dir_d == 0) and nz(dir_d[1]) != 0

float ph_d = ta.pivothigh(dom_h, length_sl, length_sl)
float pl_d = ta.pivotlow(dom_l, length_sl, length_sl)
float tr_d = math.max(dom_h - dom_l, math.max(math.abs(dom_h - nz(dom_c[1])), math.abs(dom_l - nz(dom_c[1]))))
float atr_d = ta.sma(tr_d, length_sl)

float slope_d = calcMethod_sl == "Atr" ? (atr_d / length_sl * mult_sl) : calcMethod_sl == "Stdev" ? (ta.stdev(dom_c, length_sl) / length_sl * mult_sl) : (math.abs(ta.sma(dom_c * n_idx, length_sl) - ta.sma(dom_c, length_sl) * ta.sma(n_idx, length_sl)) / ta.variance(n_idx, length_sl) / 2 * mult_sl)

var float sph_d = 0., var float spl_d = 0.
sph_d := not na(ph_d) ? slope_d : sph_d
spl_d := not na(pl_d) ? slope_d : spl_d

var float up_d = 0., var float dn_d = 0.
up_d := not na(ph_d) ? ph_d : up_d - sph_d
dn_d := not na(pl_d) ? pl_d : dn_d + spl_d

var int upos_d = 0, var int dnos_d = 0
upos_d := not na(ph_d) ? 0 : dom_c > up_d - sph_d * length_sl ? 1 : upos_d
dnos_d := not na(pl_d) ? 0 : dom_c < dn_d + spl_d * length_sl ? 1 : dnos_d

bool lBull_d = upos_d > upos_d[1]
bool lBear_d = dnos_d > dnos_d[1]

var bool wS_L_d = false, var bool wL_L_d = false, var int t_L_d = 0
var bool wS_S_d = false, var bool wL_S_d = false, var int t_S_d = 0

t_L_d := (wS_L_d or wL_L_d) ? t_L_d + 1 : t_L_d
t_S_d := (wS_S_d or wL_S_d) ? t_S_d + 1 : t_S_d

wS_L_d := t_L_d > 12 ? false : wS_L_d
wL_L_d := t_L_d > 12 ? false : wL_L_d
t_L_d := t_L_d > 12 ? 0 : t_L_d
wS_S_d := t_S_d > 12 ? false : wS_S_d
wL_S_d := t_S_d > 12 ? false : wL_S_d
t_S_d := t_S_d > 12 ? 0 : t_S_d

bool slL_d = false, bool slS_d = false

if sBull_d
    slL_d := (wL_L_d and t_L_d <= 12), wS_L_d := not slL_d, wL_L_d := false, t_L_d := 0
if lBull_d
    slL_d := (wS_L_d and t_L_d <= 12), wL_L_d := not slL_d, wS_L_d := false, t_L_d := 0
if sBear_d
    slS_d := (wL_S_d and t_S_d <= 12), wS_S_d := not slS_d, wL_S_d := false, t_S_d := 0
if lBear_d
    slS_d := (wS_S_d and t_S_d <= 12), wL_S_d := not slS_d, wS_S_d := false, t_S_d := 0

bool pmp_d = tr_d > atr_d 

bool swL_d = dom_l < ta.lowest(dom_l[1], lookback) and dom_c > ta.lowest(dom_l[1], lookback) 
bool swS_d = dom_h > ta.highest(dom_h[1], lookback) and dom_c < ta.highest(dom_h[1], lookback) 
bool afyL_d = not use_afy or ta.barssince(swL_d) <= 10
bool afyS_d = not use_afy or ta.barssince(swS_d) <= 10

float out_d = f_mona(dom_c, h)
float mae_d = ta.sma(math.abs(dom_c - out_d), 499) * mult
bool m_L_d = ta.crossunder(dom_c, out_d - mae_d)
bool m_S_d = ta.crossover(dom_c, out_d + mae_d)

var int mb_d = 0
mb_d := m_L_d ? 1 : m_S_d ? -1 : mb_d

float nL_d = aMultiplier * ta.sma(tr_d, aPeriod)
var float xTS_d = 0.0
xTS_d := dom_c > nz(xTS_d[1], 0) and dom_c[1] > nz(xTS_d[1], 0) ? math.max(nz(xTS_d[1]), dom_c - nL_d) : dom_c < nz(xTS_d[1], 0) and dom_c[1] < nz(xTS_d[1], 0) ? math.min(nz(xTS_d[1]), dom_c + nL_d) : dom_c > nz(xTS_d[1], 0) ? dom_c - nL_d : dom_c + nL_d

var int pos_d = 0
pos_d := dom_c > nz(xTS_d[1], 0) and dom_c[1] <= nz(xTS_d[1], 0) ? 1 : dom_c < nz(xTS_d[1], 0) and dom_c[1] >= nz(xTS_d[1], 0) ? -1 : nz(pos_d[1], 0)
bool uL_d = pos_d == 1 and pos_d[1] != 1
bool uS_d = pos_d == -1 and pos_d[1] != -1

bool rm_L_d = ((m_L_d and pos_d == 1) or (uL_d and mb_d == 1)) and afyL_d
bool rm_S_d = ((m_S_d and pos_d == -1) or (uS_d and mb_d == -1)) and afyS_d

var int phz_d = 0
phz_d := pmp_d ? 1 : phz_d
bool mhB_d = false, bool mhS_d = false

if phz_d == 1
    if rm_S_d
        mhB_d := true, phz_d := 2 
    else if rm_L_d
        mhS_d := true, phz_d := 2
else if phz_d == 2
    if rm_L_d
        mhB_d := true, phz_d := 0 
    else if rm_S_d
        mhS_d := true, phz_d := 0

var bool wMH_L_d = false, var bool wSL_L_d = false, var int tuL_d = 0
var bool wMH_S_d = false, var bool wSL_S_d = false, var int tuS_d = 0

tuL_d := (wMH_L_d or wSL_L_d) ? tuL_d + 1 : tuL_d
tuS_d := (wMH_S_d or wSL_S_d) ? tuS_d + 1 : tuS_d

wMH_L_d := tuL_d > 16 ? false : wMH_L_d
wSL_L_d := tuL_d > 16 ? false : wSL_L_d
tuL_d := tuL_d > 16 ? 0 : tuL_d
wMH_S_d := tuS_d > 16 ? false : wMH_S_d
wSL_S_d := tuS_d > 16 ? false : wSL_S_d
tuS_d := tuS_d > 16 ? 0 : tuS_d

bool ULT_L_d = false, bool ULT_S_d = false

if mhB_d
    ULT_L_d := (wSL_L_d and tuL_d <= 16), wMH_L_d := not ULT_L_d, wSL_L_d := false, tuL_d := 0
if slL_d
    ULT_L_d := (wMH_L_d and tuL_d <= 16), wSL_L_d := not ULT_L_d, wMH_L_d := false, tuL_d := 0
if mhS_d
    ULT_S_d := (wSL_S_d and tuS_d <= 16), wMH_S_d := not ULT_S_d, wSL_S_d := false, tuS_d := 0
if slS_d
    ULT_S_d := (wMH_S_d and tuS_d <= 16), wSL_S_d := not ULT_S_d, wMH_S_d := false, tuS_d := 0

// =========================================================================
// --- ALGORITHMIC COUNTER-TREND INVERSION CORE ---
// =========================================================================
bool MAIN_L = ULT_S_m
bool MAIN_S = ULT_L_m

bool TOT_L = ULT_S_t
bool TOT_S = ULT_L_t

bool DOM_L = ULT_S_d
bool DOM_S = ULT_L_d

float rsi_m = ta.rsi(close, rsi_len)
bool bkS_m = use_rsi_filter and (ta.highest(rsi_m, rsi_lookback) > rsi_upper) 
bool bkL_m = use_rsi_filter and (ta.lowest(rsi_m, rsi_lookback) < rsi_lower) 

[mLine_m, sLine_m, hLine_m] = ta.macd(close, 12, 26, 9)
bool bkS_macd = use_macd_filter and (hLine_m > 0 and hLine_m > hLine_m[1])
bool bkL_macd = use_macd_filter and (hLine_m < 0 and hLine_m < hLine_m[1])

float atrV_m = ta.atr(atr_len_filter)
float cb_m = math.abs(close - open)
float g_cb_m = close > open ? cb_m : 0
float r_cb_m = close < open ? cb_m : 0
bool bkS_atr = use_atr_filter and (ta.highest(g_cb_m, atr_lookback) > atrV_m * atr_mult_filter)
bool bkL_atr = use_atr_filter and (ta.highest(r_cb_m, atr_lookback) > atrV_m * atr_mult_filter)

bool BLOCK_S = bkS_m or bkS_macd or bkS_atr
bool BLOCK_L = bkL_m or bkL_macd or bkL_atr

bool FINAL_MAIN_L = MAIN_L and not BLOCK_L
bool FINAL_MAIN_S = MAIN_S and not BLOCK_S

// =========================================================================
// --- MACRO MATRIX COMBINATIONS & STRATEGY INDEXING ---
// =========================================================================
int b_tot_L = ta.barssince(TOT_L)
int b_tot_S = ta.barssince(TOT_S)
int b_dom_L = ta.barssince(DOM_L)
int b_dom_S = ta.barssince(DOM_S)

bool tot_L_active = not na(b_tot_L) and (b_tot_L <= macro_lookback)
bool tot_S_active = not na(b_tot_S) and (b_tot_S <= macro_lookback)
bool dom_L_active = not na(b_dom_L) and (b_dom_L <= macro_lookback)
bool dom_S_active = not na(b_dom_S) and (b_dom_S <= macro_lookback)

// Core Macro System Combinations
bool combo_PerfectBull  = FINAL_MAIN_L and tot_L_active and dom_L_active
bool combo_AltcoinRally = FINAL_MAIN_L and tot_L_active and dom_S_active
bool combo_SafeHaven    = FINAL_MAIN_S and tot_S_active and dom_L_active 
bool combo_PerfectBear   = FINAL_MAIN_S and tot_S_active and dom_S_active

// Inter-Market Matrix Early Alignment Triggers
bool alignment_bull = tot_L_active and dom_L_active
bool alignment_bear  = tot_S_active and dom_S_active

bool EARLY_L = alignment_bull and not alignment_bull[1] and not FINAL_MAIN_L
bool EARLY_S = alignment_bear  and not alignment_bear[1]  and not FINAL_MAIN_S

// --- ON-CHART VISUAL LABELS ---
plotshape(FINAL_MAIN_L and not combo_PerfectBull and not combo_AltcoinRally, "Standard L", shape.labelup, location.belowbar, color=#00FF00, size=size.normal, text="L", textcolor=color.black)
plotshape(FINAL_MAIN_S and not combo_PerfectBear and not combo_SafeHaven, "Standard S", shape.labeldown, location.abovebar, color=#FF0000, size=size.normal, text="S", textcolor=color.white)

plotshape(combo_PerfectBull, "PERFECT BULLISH L", shape.labelup, location.belowbar, color=color.new(#00FF00, 0), size=size.large, text="💎\nPERFECT L", textcolor=color.black)
plotshape(combo_AltcoinRally, "ALTCOIN RALLY L", shape.labelup, location.belowbar, color=color.new(#00FFFF, 0), size=size.large, text="🚀\nALT L", textcolor=color.black)

plotshape(combo_PerfectBear, "MARKET CRASH S", shape.labeldown, location.abovebar, color=color.new(#FF0000, 0), size=size.large, text="🩸\nCRASH S", textcolor=color.white)
plotshape(combo_SafeHaven, "SAFE HAVEN S", shape.labeldown, location.abovebar, color=color.new(#FFA500, 0), size=size.large, text="🛡️\nHAVEN S", textcolor=color.white)

plotshape(EARLY_L, "EARLY MACRO ALIGNMENT L", shape.labelup, location.belowbar, color=color.new(color.orange, 0), size=size.large, text="⚡\nEARLY L", textcolor=color.black)
plotshape(EARLY_S, "EARLY MACRO ALIGNMENT S", shape.labeldown, location.abovebar, color=color.new(color.fuchsia, 0), size=size.large, text="⚡\nEARLY S", textcolor=color.white)

// =========================================================================
// --- WEBHOOK ROUTING AUTOMATION (ORDER EXECUTION SEQUENCE) ---
// =========================================================================
bool ALL_LONG_CONDITIONS  = FINAL_MAIN_L or combo_PerfectBull or combo_AltcoinRally or EARLY_L
bool ALL_SHORT_CONDITIONS = FINAL_MAIN_S or combo_PerfectBear or combo_SafeHaven or EARLY_S

grp_bot = "🤖 BOT WEBHOOK MESSAGES"
txt_long_ac     = input.string("ENTER-LONG...", "1️⃣ LONG ENTRY", group=grp_bot)
txt_long_kapat  = input.string("EXIT-LONG...", "2️⃣ LONG EXIT", group=grp_bot)
txt_short_ac    = input.string("ENTER-SHORT...", "3️⃣ SHORT ENTRY", group=grp_bot)
txt_short_kapat = input.string("EXIT-SHORT...", "4️⃣ SHORT EXIT", group=grp_bot)

var int position_state = 0 // 1 = Long Active, -1 = Short Active, 0 = Flat

if ALL_LONG_CONDITIONS and position_state != 1
    if position_state == -1
        alert(txt_short_kapat, alert.freq_once_per_bar_close)
    alert(txt_long_ac, alert.freq_once_per_bar_close)
    position_state := 1

if ALL_SHORT_CONDITIONS and position_state != -1
    if position_state == 1
        alert(txt_long_kapat, alert.freq_once_per_bar_close)
    alert(txt_short_ac, alert.freq_once_per_bar_close)
    position_state := -1
````
