# Confluence Flow

- url: https://www.tradingview.com/script/tmHHJLiN-Confluence-Flow/
- type: indicator
- pine_id: PUB;3f24f5268bfd4811b9af0b8eacae29d2
- version: 1.0

## Description

Confluence Flow — A multi-layer confluence system combining EVWAP, Adaptive Pivots, Impulse Council & Smart Candles

Confluence Flow unifies five analytical layers — Regime, Momentum, Structure, Pattern, and Confidence — into one powerful overlay. Instead of scattered signals, you get a coherent market narrative through intelligent candle coloring, adaptive levels, and a clean dashboard.

─────────────────────────────────────────────
EVWAP (Exponential Volume Weighted Average Price)
─────────────────────────────────────────────
The heart of the regime filter. This EVWAP dynamically anchors to the most recent significant swing high or low and uses an adaptive half-life that responds to market volatility. Fast markets = faster reaction. Quiet markets = smoother response.

Includes ±1σ and ±2σ bands that clearly show fair value, premium/discount zones, and statistical extremes.

─────────────────────────────────────────────
Adaptive Pivots (S9)
─────────────────────────────────────────────
A next-level dynamic support/resistance system. Band width adapts intelligently using a Trend Quality Index (TQI) based on efficiency, volume, structure, and momentum alignment. High-quality trends get tighter bands. Chop gets wider bands to reduce whipsaws.

─────────────────────────────────────────────
Impulse Council (4-School Voting)
─────────────────────────────────────────────
Four independent schools vote on momentum:

• OBV Flow & Divergence
• Volume Delta (VWMA)
• Wyckoff Springs & Upthrusts
• EMA Confluence (9/21 + 55 filter)

Minimum 2 agreeing schools required for a valid signal.

─────────────────────────────────────────────
Smart Candles
─────────────────────────────────────────────
Candles are colored on a gradient from deep maroon (strong bear) to bright cyan (strong bull) based on the composite bias. Both body and wicks adapt, giving instant visual conviction.

─────────────────────────────────────────────
Pattern Recognition & High-Confidence RR Boxes
─────────────────────────────────────────────
Detects 20 classical patterns with strength scoring and regime alignment filtering. Patterns that conflict with the prevailing regime are automatically dimmed on the chart — keeping your focus on high-probability setups and filtering out counter-trend noise. When a strong pattern aligns with high TQI, strong displacement, and volume — a ★ High Confidence signal triggers automatic 1:2 RR boxes with smart stop placement.

─────────────────────────────────────────────
Dashboard
─────────────────────────────────────────────
Real-time overview of Bias, Council votes, S9 trend, EVWAP direction, and SMA trend.

─────────────────────────────────────────────
Best Used As
─────────────────────────────────────────────
A powerful confluence tool for day traders and swing traders on 5min to 4H timeframes. The strongest setups occur when EVWAP, S9, Council, and Smart Candle bias all align.

Settings default to "Patterns Only" so you can add it without changing your chart's original candle look — toggle to "Candles + Patterns" to enable the full Smart Candle gradient coloring.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nun_Donna

//@version=6
indicator('Confluence Flow', overlay=true, max_bars_back=1000, max_lines_count=200, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════
// Confluence Flow
// Architecture: Regime → Bias → Trigger → Confluency
// ═══════════════════════════════════════════════════════════════

// ─── DISPLAY ─────────────────────────────────────────────────
grp_d = "Display"
themeMode    = input.string("Candles + Patterns", "Theme",
     options=["Candles Only","Patterns Only","Candles + Patterns"], group=grp_d)
show_evwap   = input.bool(true,  "EVWAP",                  group=grp_d)
show_s9      = input.bool(true,  "Adaptive Pivots",        group=grp_d)
show_rr      = input.bool(true,  "RR Boxes on High Conf",  group=grp_d)
show_signals = input.bool(true,  "Show Candle Signals",    group=grp_d,
     tooltip="Toggle all pattern labels and high-confidence signals. EVWAP and Adaptive Pivots remain visible regardless.")
dashPos      = input.string("Top Right", "Dashboard",
     options=["Top Right","Top Left","Bottom Right","Bottom Left","Hide"], group=grp_d)

bool showCandles  = themeMode != "Patterns Only"
bool showPatterns = themeMode != "Candles Only" and show_signals

// ─── CANDLE COLORS ───────────────────────────────────────────
grp_c = "Candle Colors"
c_cyan_hi   = input.color(color.rgb(0,229,255),   "Full Bull Bright", group=grp_c)
c_cyan_lo   = input.color(color.rgb(0,131,143),   "Full Bull Dark",   group=grp_c)
c_green_hi  = input.color(color.rgb(56,222,185),  "Bull Bright",      group=grp_c)
c_green_lo  = input.color(color.rgb(0,105,92),    "Bull Dark",        group=grp_c)
c_yellow_hi = input.color(color.rgb(255,241,118), "Neutral Bright",   group=grp_c)
c_yellow_lo = input.color(color.rgb(181,159,0),   "Neutral Dark",     group=grp_c)
c_red_hi    = input.color(color.rgb(255,110,100), "Bear Bright",      group=grp_c)
c_red_lo    = input.color(color.rgb(183,28,28),   "Bear Dark",        group=grp_c)
c_maroon_hi = input.color(color.rgb(194,24,91),   "Full Bear Bright", group=grp_c)
c_maroon_lo = input.color(color.rgb(93,0,45),     "Full Bear Dark",   group=grp_c)

// ─── IMPULSE SCHOOLS ─────────────────────────────────────────
grp_imp = "Impulse Schools"
use_s1_obv  = input.bool(true, "School 1: OBV Flow",        group=grp_imp,
     tooltip="On-Balance Volume trend and acceleration. Detects divergence between price and cumulative volume flow.")
use_s2_vwma = input.bool(true, "School 2: Volume Delta",    group=grp_imp,
     tooltip="Short vs long VWMA momentum. Positive when buyers dominate recent volume-weighted price activity.")
use_s3_wyck = input.bool(true, "School 3: Wyckoff",         group=grp_imp,
     tooltip="Spring and upthrust detection based on Wyckoff methodology. Identifies low-risk entries after pullbacks to key levels.")
use_s4_ema  = input.bool(true, "School 4: EMA Confluence",  group=grp_imp,
     tooltip="EMA 9/21 crossover filtered by position relative to EMA 55 and RSI. Classic trend-following entry trigger.")
cooldown    = input.int(25,    "Signal Cooldown (bars)",    group=grp_imp, minval=5,
     tooltip="Minimum bars between council signals. Prevents signal clustering in fast-moving markets.")

// ─── ADAPTIVE PIVOTS (S9) ────────────────────────────────────
grp_s9 = "Adaptive Pivots"
use_s9      = input.bool(true,  "Enable",              group=grp_s9)
s9_atrLen   = input.int(13,     "ATR Length",          group=grp_s9, minval=5,
     tooltip="ATR period used for band width calculation.")
s9_baseMult = input.float(2.0,  "Band Width (xATR)",   group=grp_s9, step=0.1,
     tooltip="Base multiplier for band width. Higher values produce wider bands and fewer flips.")
s9_erLen    = input.int(20,     "Efficiency Window",   group=grp_s9, minval=5,
     tooltip="Lookback for Efficiency Ratio. Measures the directional quality of the current move.")
s9_qStr     = input.float(0.4,  "Quality Influence",   group=grp_s9, step=0.05,
     tooltip="How strongly the TQI quality score affects band width. 0 = fixed, 1 = fully adaptive.")
s9_pivLen   = input.int(3,      "Pivot Length",        group=grp_s9, minval=2,
     tooltip="Bars on each side required to confirm a pivot high or low.")
bullCol     = input.color(color.rgb(38,166,154), "Bull Color", group=grp_s9)
bearCol     = input.color(color.rgb(239,83,80),  "Bear Color", group=grp_s9)

// ─── EVWAP ───────────────────────────────────────────────────
grp_vw = "EVWAP"
swingPeriod  = input.int(55,   "Swing Period",           group=grp_vw, minval=10,
     tooltip="Lookback for swing high/low detection. The EVWAP anchors to the most recent swing pivot within this window.")
hullLen      = input.int(14,   "Hull Smooth Length",     group=grp_vw, minval=5,
     tooltip="HMA smoothing applied to the raw EVWAP. Higher values produce a smoother but slower line.")
ew_base_hl   = input.int(21,   "Base Half-Life",         group=grp_vw, minval=5, maxval=100,
     tooltip="Starting half-life for the exponential weighting. Adjusted dynamically by the volatility ratio. Higher = slower default response.")
ew_vol_bias  = input.float(1.2,"Volatility Bias",        group=grp_vw, minval=0.1, maxval=3.0, step=0.1,
     tooltip="Controls how strongly volatility affects the half-life. 1.0 = linear. Higher values make the EVWAP react faster in volatile conditions.")
ew_hl_min    = input.int(8,    "Min Half-Life (fast)",   group=grp_vw, minval=2, maxval=50,
     tooltip="Floor for the adaptive half-life. Prevents the EVWAP from reacting too aggressively in extreme volatility.")
ew_hl_max    = input.int(50,   "Max Half-Life (slow)",   group=grp_vw, minval=10, maxval=200,
     tooltip="Ceiling for the adaptive half-life. Prevents over-smoothing in very quiet market conditions.")

show_ew_bands = input.bool(true,  "Show Sigma Bands",    group=grp_vw,
     tooltip="Standard deviation bands around the EVWAP. ±1σ = fair value zone. ±2σ = premium/discount extremes.")
ew_band_len   = input.int(50,     "Sigma Lookback",      group=grp_vw, minval=10, maxval=200,
     tooltip="Number of bars used to calculate the standard deviation for the sigma bands.")
col_band_bull = input.color(color.new(#00C896, 85), "Band Color Bull", group=grp_vw)
col_band_bear = input.color(color.new(#F23645, 85), "Band Color Bear", group=grp_vw)

// ─── PATTERNS ────────────────────────────────────────────────
grp_pat = "Patterns"
maxPattern   = input.int(20,   "Max Labels",           group=grp_pat, minval=1, maxval=200,
     tooltip="Maximum number of pattern labels shown simultaneously. Oldest are removed first.")
maxCheck     = input.int(10,   "Engulfing Check Bars", group=grp_pat, minval=1,
     tooltip="How many prior bars to check when scoring an engulfing pattern.")
trendPeriod  = input.int(20,   "Trend SMA Period",     group=grp_pat, minval=5,
     tooltip="SMA period for trend context filter. Patterns conflicting with the trend are shown dimmed.")
showTrendCtx = input.bool(true,"Trend Context Filter", group=grp_pat,
     tooltip="When enabled, patterns that conflict with the prevailing SMA trend are dimmed rather than shown in full color.")

grp_sty = "Pattern Colors"
col_bullish = input.color(color.green,  "Strong Bull", group=grp_sty)
col_bearish = input.color(color.red,    "Strong Bear", group=grp_sty)
col_special = input.color(color.yellow, "Special",     group=grp_sty)
col_txt     = input.color(color.white,  "Text",        group=grp_sty)

// ═══════════════════════════════════════════════════════════════
// LAYER 0 — CORE
// ═══════════════════════════════════════════════════════════════
atr   = ta.atr(14)
n     = bar_index
tp3   = (high + low + close) / 3.0
ema20 = ta.ema(close, 20)
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)
rsi14 = ta.rsi(close, 14)

float volMean   = ta.sma(volume, 20)
float volStd    = ta.stdev(volume, 20)
float volZ      = volStd > 0 ? (volume - volMean) / volStd : 0.0
bool  volHigh   = volZ >= 1.5
float bodyRatio = (high - low) > 0 ? math.abs(close - open) / (high - low) : 0.0

// ─── LAYER 1 — REGIME ────────────────────────────────────────
hbars = ta.highestbars(high, swingPeriod)
lbars = ta.lowestbars(low,  swingPeriod)
bool isSwingHigh = hbars == 0
bool isSwingLow  = lbars == 0

var float swHi = na, var float swLo = na
var float prevSwHi = na, var float prevSwLo = na
if isSwingHigh
    prevSwHi := swHi
    swHi     := high
if isSwingLow
    prevSwLo := swLo
    swLo     := low

// ─── EVWAP ───────────────────────────────────────────────────
var float ew_ph = na, var float ew_pl = na
var int   ew_phL = 0, var int ew_plL = 0
ew_ph  := isSwingHigh ? high : ew_ph
ew_pl  := isSwingLow  ? low  : ew_pl
ew_phL := isSwingHigh ? n : ew_phL
ew_plL := isSwingLow  ? n : ew_plL

int  ew_dir  = ew_phL > ew_plL ? 1 : -1
bool dirChgd = ew_dir != ew_dir[1]

float volSma20   = nz(ta.sma(volume, 20), 1.0)
float volMed50   = nz(ta.median(volume, 50), 1.0)
float volCap     = math.max(volSma20 * 3.0, 1.0)
float ew_atr_raw = ta.atr(50)
float ew_atr_avg = ta.rma(ew_atr_raw, 50)
float ew_ratio   = ew_atr_avg > 0 ? ew_atr_raw / ew_atr_avg : 1.0
float ew_hl_raw  = ew_base_hl / math.pow(ew_ratio, ew_vol_bias)
float ew_hl      = math.max(float(ew_hl_min), math.min(float(ew_hl_max), ew_hl_raw))
float ewAlpha    = 1.0 - math.exp(-math.log(2.0) / ew_hl)

getCapVol(int offset) =>
    float raw = nz(volume[offset], 0.0)
    math.max(math.min(raw > 0 ? raw : volMed50, volCap), 1.0)

var float ewP = 0.0, var float ewV = 0.0, var int ewAncDir = 1

if dirChgd
    int pivBar = ew_dir > 0 ? ew_plL : ew_phL
    int safeBk = math.min(math.max(n - pivBar, 0), math.min(4999, n - 1))
    ewP      := tp3[safeBk] * getCapVol(safeBk)
    ewV      := getCapVol(safeBk)
    ewAncDir := ew_dir
    if safeBk > 1
        for i = (safeBk - 1) to 0 by 1
            float ramp = (safeBk - i) <= 5 ? 0.5 + 0.5 * (safeBk - i) / 5.0 : 1.0
            float a    = ewAlpha * ramp
            float vi   = getCapVol(i)
            ewP := (1.0 - a) * ewP + a * tp3[i] * vi
            ewV := (1.0 - a) * ewV + a * vi
    else if safeBk == 1
        float vi = getCapVol(0)
        ewP := (1.0 - ewAlpha * 0.75) * ewP + ewAlpha * 0.75 * tp3 * vi
        ewV := (1.0 - ewAlpha * 0.75) * ewV + ewAlpha * 0.75 * vi
else
    ewAncDir := ew_dir
    float vi  = getCapVol(0)
    ewP := (1.0 - ewAlpha) * ewP + ewAlpha * tp3 * vi
    ewV := (1.0 - ewAlpha) * ewV + ewAlpha * vi

float ewVwap     = ewV > 0 ? ewP / ewV : close
float ewSmoothed = ta.hma(ewVwap, hullLen)
float ewPlot     = dirChgd ? na : ewSmoothed
color ewCol      = ewAncDir > 0 ? bullCol : bearCol

float ew_dev      = ta.stdev(close - ewSmoothed, ew_band_len)
float ew_band1u   = ewSmoothed + ew_dev * 1.0
float ew_band2u   = ewSmoothed + ew_dev * 2.0
float ew_band1d   = ewSmoothed - ew_dev * 1.0
float ew_band2d   = ewSmoothed - ew_dev * 2.0
color ew_band_col = ewAncDir > 0 ? col_band_bull : col_band_bear

// ─── S9 ADAPTIVE PIVOTS ──────────────────────────────────────
float s9_atr    = ta.atr(s9_atrLen)
float s9_chg    = math.abs(close - close[s9_erLen])
float s9_path   = math.sum(math.abs(close - close[1]), s9_erLen)
float s9_er     = s9_path > 0 ? s9_chg / s9_path : 0.0
float s9_effAtr = s9_atr * (0.5 + 0.5 * s9_er)

float s9_vMean  = ta.sma(volume, 20)
float s9_vStd   = ta.stdev(volume, 20)
float s9_volZ   = s9_vStd > 0 ? (volume - s9_vMean) / s9_vStd : 0.0
float s9_tqiVol = math.max(0.0, math.min(1.0, (s9_volZ + 1.0) / 3.0))

float s9_sHi   = ta.highest(high, 20)
float s9_sLo   = ta.lowest(low, 20)
float s9_sRng  = s9_sHi - s9_sLo
float s9_pos   = s9_sRng > 0 ? (close - s9_sLo) / s9_sRng : 0.5
float s9_tqiSt = math.max(0.0, math.min(1.0, math.abs(s9_pos - 0.5) * 2.0))

float s9_wChg = close - close[10]
int   s9_aln  = 0
for i = 0 to 9
    float bc = close[i] - close[i + 1]
    if (s9_wChg > 0 and bc > 0) or (s9_wChg < 0 and bc < 0)
        s9_aln += 1
float s9_tqiMom = float(s9_aln) / 10.0
float s9_tqiEr  = math.max(0.0, math.min(1.0, s9_er))
float s9_tqi    = math.max(0.0, math.min(1.0,
     s9_tqiEr * 0.35 + s9_tqiVol * 0.20 + s9_tqiSt * 0.25 + s9_tqiMom * 0.20))

float s9_qDev = math.pow(1.0 - s9_tqi, 1.5)
float s9_tqiM = 1.0 - s9_qStr + s9_qStr * (0.6 + 0.8 * s9_qDev)
float s9_symM = s9_baseMult * s9_tqiM

float s9_alpha_act = 0.22
float s9_alpha_pas = 0.08
var float s9_actSm = na, var float s9_pasSm = na
s9_actSm := na(s9_actSm[1]) ? s9_symM : s9_actSm[1] + s9_alpha_act * (s9_symM - s9_actSm[1])
s9_pasSm := na(s9_pasSm[1]) ? s9_symM : s9_pasSm[1] + s9_alpha_pas * (s9_symM - s9_pasSm[1])

var float s9_lower = na, var float s9_upper = na, var int s9_trend = 1
int s9_prev = na(s9_trend[1]) ? 1 : s9_trend[1]
float s9_lM   = s9_prev == 1 ? s9_actSm : s9_pasSm
float s9_uM   = s9_prev == 1 ? s9_pasSm : s9_actSm
float s9_lRaw = close - s9_lM * s9_effAtr
float s9_uRaw = close + s9_uM * s9_effAtr
s9_lower := na(s9_lower[1]) ? s9_lRaw : (close[1] > s9_lower[1] ? math.max(s9_lRaw, s9_lower[1]) : s9_lRaw)
s9_upper := na(s9_upper[1]) ? s9_uRaw : (close[1] < s9_upper[1] ? math.min(s9_uRaw, s9_upper[1]) : s9_uRaw)

bool s9_flipUp = s9_prev == -1 and close > s9_upper[1]
bool s9_flipDn = s9_prev ==  1 and close < s9_lower[1]
s9_trend := s9_flipUp ? 1 : s9_flipDn ? -1 : s9_prev

float s9_pivH = ta.pivothigh(high, s9_pivLen, s9_pivLen)
float s9_pivL = ta.pivotlow(low,  s9_pivLen, s9_pivLen)
var float s9_lastPivH = na, var float s9_lastPivL = na
if not na(s9_pivH)
    s9_lastPivH := s9_pivH
if not na(s9_pivL)
    s9_lastPivL := s9_pivL

// ═══════════════════════════════════════════════════════════════
// LAYER 2 — IMPULSE (4-School Council)
// ═══════════════════════════════════════════════════════════════

// School 1: OBV Flow
var float obv = 0.0
obv += close > close[1] ? volume : close < close[1] ? -volume : 0.0
float obvSma    = ta.sma(obv, 20)
float obvSlope  = obv - nz(obv[5])
float obvHi20   = ta.highest(obv, 20)
float obvLo20   = ta.lowest(obv, 20)
float hiRng     = ta.highest(high, 20) - ta.lowest(low, 20)
float obvRng    = obvHi20 - obvLo20
float priceLo20 = ta.lowest(low, 20)
float priceHi20 = ta.highest(high, 20)

bool obvAccUp = obvSlope > 0 and obvSlope > nz(obvSlope[5])
bool obvAccDn = obvSlope < 0 and obvSlope < nz(obvSlope[5])

bool s1_bullDiv = hiRng > 0 and obvRng > 0 and
     (low - priceLo20) / hiRng < 0.05 and
     (obv - obvLo20) / obvRng > 0.15
bool s1_bearDiv = hiRng > 0 and obvRng > 0 and
     (priceHi20 - high) / hiRng < 0.05 and
     (obvHi20 - obv) / obvRng > 0.15

bool s1_bull = use_s1_obv and (s1_bullDiv or (obv > obvSma and obvAccUp))
bool s1_bear = use_s1_obv and (s1_bearDiv or (obv < obvSma and obvAccDn))

// School 2: Volume Delta (VWMA)
float vwmaS      = ta.vwma(close, 5)
float vwmaL      = ta.vwma(close, 30)
float vwmaDelta  = vwmaS - vwmaL
float deltaRma   = ta.rma(vwmaDelta, 30)
float deltaSlope = deltaRma - nz(deltaRma[3], deltaRma)

bool s2_bull = use_s2_vwma and deltaRma > 0 and deltaSlope > 0
bool s2_bear = use_s2_vwma and deltaRma < 0 and deltaSlope < 0

// School 3: Wyckoff Spring / Upthrust
var bool  w_inPull   = false
var bool  w_pullBull = false
var int   w_bars     = 0
var float w_volSum   = 0.0
var float w_preVol   = 0.0
var float w_bodySum  = 0.0

bool aboveEma  = close > ema20
bool belowEma  = close < ema20
bool startBull = aboveEma[1] and belowEma and not w_inPull
bool startBear = belowEma[1] and aboveEma and not w_inPull
float preSma5  = nz(ta.sma(volume, 5)[1], volMean)

if startBull
    w_inPull   := true
    w_pullBull := true
    w_bars     := 1
    w_volSum   := volume
    w_preVol   := preSma5
    w_bodySum  := bodyRatio
if startBear
    w_inPull   := true
    w_pullBull := false
    w_bars     := 1
    w_volSum   := volume
    w_preVol   := preSma5
    w_bodySum  := bodyRatio
if w_inPull and not startBull and not startBear
    if (w_pullBull and belowEma) or (not w_pullBull and aboveEma)
        w_bars    += 1
        w_volSum  += volume
        w_bodySum += bodyRatio
if w_inPull and w_bars > 50
    w_inPull := false

bool w_bounceUp     = w_inPull and w_pullBull and aboveEma
bool w_bounceDn     = w_inPull and not w_pullBull and belowEma
float w_avgVol      = w_bars > 0 ? w_volSum / w_bars : volMean
bool w_dryPull      = w_bars >= 2 and (w_avgVol < w_preVol or (w_bodySum / w_bars < 0.45))
bool w_strongBounce = bodyRatio > 0.5 and volume > w_avgVol

bool w_spring   = not na(prevSwLo) and low < prevSwLo and close > prevSwLo and close > open and volume > volMean
bool w_upthrust = not na(prevSwHi) and high > prevSwHi and close < prevSwHi and close < open and volume > volMean

bool s3_bull = use_s3_wyck and ((w_bounceUp and w_bars >= 3 and w_dryPull and w_strongBounce) or w_spring)
bool s3_bear = use_s3_wyck and ((w_bounceDn and w_bars >= 3 and w_dryPull and w_strongBounce) or w_upthrust)

if w_bounceUp or w_bounceDn
    w_inPull := false

// School 4: EMA Confluence
bool cross_up_s4 = ta.crossover(ema9,  ema21)
bool cross_dn_s4 = ta.crossunder(ema9, ema21)

bool s4_bull = use_s4_ema and cross_up_s4 and close > ema55 and rsi14 < 70
bool s4_bear = use_s4_ema and cross_dn_s4 and close < ema55 and rsi14 > 30

// Council voting
agreement_window = input.int(4, "Agreement Window (bars)", group=grp_imp, minval=1, maxval=10,
     tooltip="Bars within which a school vote remains active for the council decision. Lower = stricter time alignment required.")

var int s1_lastBull = -999, var int s1_lastBear = -999
var int s2_lastBull = -999, var int s2_lastBear = -999
var int s3_lastBull = -999, var int s3_lastBear = -999
var int s4_lastBull = -999, var int s4_lastBear = -999

if s1_bull
    s1_lastBull := n
if s1_bear
    s1_lastBear := n
if s2_bull
    s2_lastBull := n
if s2_bear
    s2_lastBear := n
if s3_bull
    s3_lastBull := n
if s3_bear
    s3_lastBear := n
if s4_bull
    s4_lastBull := n
if s4_bear
    s4_lastBear := n

bool s1_bR  = n - s1_lastBull <= agreement_window
bool s1_beR = n - s1_lastBear <= agreement_window
bool s2_bR  = n - s2_lastBull <= agreement_window
bool s2_beR = n - s2_lastBear <= agreement_window
bool s3_bR  = n - s3_lastBull <= agreement_window
bool s3_beR = n - s3_lastBear <= agreement_window
bool s4_bR  = n - s4_lastBull <= agreement_window
bool s4_beR = n - s4_lastBear <= agreement_window

int bullVotes = (s1_bR ? 1 : 0) + (s2_bR ? 1 : 0) + (s3_bR ? 1 : 0) + (s4_bR ? 1 : 0)
int bearVotes = (s1_beR ? 1 : 0) + (s2_beR ? 1 : 0) + (s3_beR ? 1 : 0) + (s4_beR ? 1 : 0)

var int lastBullBar = -999, var int lastBearBar = -999
bool bullCool = n - lastBullBar > cooldown
bool bearCool = n - lastBearBar > cooldown

bool sigUp   = bullVotes >= 2 and bullVotes > bearVotes and bullCool
bool sigDown = bearVotes >= 2 and bearVotes > bullVotes and bearCool

if sigUp
    lastBullBar := n
if sigDown
    lastBearBar := n

var int lastSigDir = 0
if sigUp
    lastSigDir := 1
if sigDown
    lastSigDir := -1

float sc_impAge   = float(n - (lastSigDir == 1 ? lastBullBar : lastBearBar))
float sc_impDecay = math.max(0.0, 1.0 - sc_impAge / float(cooldown))
float sc_impF     = float(lastSigDir) * sc_impDecay

float sc_regF   = use_s9 ? float(s9_trend) * math.max(0.2, s9_tqi) : 0.0
float sc_ewDist = atr > 0 ? math.abs(close - ewSmoothed) / atr : 0.0
float sc_trnF   = float(ew_dir) * math.max(0.2, math.min(1.0, sc_ewDist / 1.5))

float sc_raw  = sc_impF + sc_regF + sc_trnF
float sc_norm = math.max(-1.0, math.min(1.0, sc_raw / 3.0))

// ═══════════════════════════════════════════════════════════════
// LAYER 3 — PATTERN RECOGNITION
// ═══════════════════════════════════════════════════════════════
type PatternCandidate
    int    strength = 0
    string shortTxt = ""
    string fullTxt  = ""
    color  col      = color.white
    bool   isBull   = false

var PatternCandidate best = PatternCandidate.new()
var array<label> patternLabels = array.new_label()
var int bullEngulfCount = 0
var int bearEngulfCount = 0

const float MARUBOZU_RATIO    = 0.9
const float BODY_RATIO_MIN    = 0.6
const float STRONG_BODY_RATIO = 0.7
const float SMALL_BODY_RATIO  = 0.3
const float SHADOW_LIMIT      = 0.2
const float DOJI_RATIO        = 0.05

f_addPat(bool cond, string sh, string full, color col, bool isBull, int str) =>
    if cond and str > best.strength
        best.strength := str
        best.shortTxt := sh
        best.fullTxt  := full
        best.col      := col
        best.isBull   := isBull

f_metrics(int offset) =>
    float bs = math.abs(close[offset] - open[offset])
    float rn = high[offset] - low[offset]
    float br = rn != 0 ? bs / rn : 0.0
    float us = high[offset] - math.max(open[offset], close[offset])
    float ls = math.min(open[offset], close[offset]) - low[offset]
    [bs, rn, br, us, ls]

best.strength := 0

[bs0, rn0, br0, us0, ls0] = f_metrics(0)
[bs1, rn1, br1, us1, ls1] = f_metrics(1)
[bs2, rn2, br2, us2, ls2] = f_metrics(2)
[bs3, rn3, br3, us3, ls3] = f_metrics(3)

float tSMA  = ta.sma(close, trendPeriod)
float tSMA5 = tSMA[5]
bool isUp   = not na(tSMA) and not na(tSMA5) and close > tSMA and tSMA > tSMA5
bool isDn   = not na(tSMA) and not na(tSMA5) and close < tSMA and tSMA < tSMA5
bool tUp    = not showTrendCtx or isUp
bool tDn    = not showTrendCtx or isDn

float o  = open,    float c  = close,    float h  = high,    float l  = low
float o1 = open[1], float c1 = close[1], float h1 = high[1], float l1 = low[1]
float o2 = open[2], float c2 = close[2], float h2 = high[2], float l2 = low[2]
float o3 = open[3], float c3 = close[3], float h3 = high[3], float l3 = low[3]
float o4 = open[4], float c4 = close[4], float h4 = high[4], float l4 = low[4]

bool iBull   = c > o,   bool iBear   = o > c
bool iBull1  = c1 > o1, bool iBear1  = o1 > c1
bool isDoji1 = br1 <= DOJI_RATIO
bool isDoji2 = br2 <= DOJI_RATIO

bool isBullEngulf = iBear1 and iBull and c >= o1 and c1 >= o and bs0 > bs1 and tDn
bool isBearEngulf = iBull1 and iBear and o >= c1 and o1 >= c and bs0 > bs1 and tUp

bullEngulfCount := 0
bearEngulfCount := 0
if isBullEngulf or isBearEngulf
    float cMax = math.max(o, c)
    float cMin = math.min(o, c)
    if isBullEngulf
        for i = 1 to maxCheck
            if cMax >= math.max(open[i], close[i]) and cMin <= math.min(open[i], close[i]) and bs0 > math.abs(open[i] - close[i])
                bullEngulfCount += 1
            else
                break
    if isBearEngulf
        for i = 1 to maxCheck
            if cMax >= math.max(open[i], close[i]) and cMin <= math.min(open[i], close[i]) and bs0 > math.abs(open[i] - close[i])
                bearEngulfCount += 1
            else
                break

int bullES = bullEngulfCount > 1 ? 5 : 4
int bearES = bearEngulfCount > 1 ? 5 : 4

float fcMid = (c2 + o2) * 0.5

bool isMornStar = c2 < o2 and br1 < SMALL_BODY_RATIO and math.max(o1,c1) < l2 and o > math.max(o1,c1) and iBull and c > fcMid and tDn
bool isEvnStar  = c2 > o2 and br1 < SMALL_BODY_RATIO and math.min(o1,c1) > h2 and o < math.min(o1,c1) and iBear and c < fcMid and tUp
bool isMornDoji = c2 < o2 and isDoji1 and math.max(o1,c1) < c2 and o > math.max(o1,c1) and iBull and c > fcMid and tDn
bool isEvnDoji  = c2 > o2 and isDoji1 and math.min(o1,c1) > c2 and o < math.min(o1,c1) and iBear and c < fcMid and tUp
bool isAbbBull  = c2 < o2 and h1 < low[2] and h1 < l and iBull and isDoji1 and tDn
bool isAbbBear  = c2 > o2 and l1 > high[2] and l1 > h and iBear and isDoji1 and tUp
bool isMzBull   = iBull and br0 >= MARUBOZU_RATIO
bool isMzBear   = iBear and br0 >= MARUBOZU_RATIO
bool sBKu       = iBear1 and o > h1 and iBull and br0 >= BODY_RATIO_MIN and br1 >= BODY_RATIO_MIN
bool sBKd       = iBull1 and o < l1 and iBear and br0 >= BODY_RATIO_MIN and br1 >= BODY_RATIO_MIN

bool s3WS = c2>o2 and c1>o1 and iBull and c>c1 and c1>c2 and o1>o2 and o1<c2 and o>o1 and o<c1 and
     (h2-c2)<=(c2-o2)*SHADOW_LIMIT and (h1-c1)<=(c1-o1)*SHADOW_LIMIT and (h-c)<=(c-o)*SHADOW_LIMIT and tDn
bool s3BC = c2<o2 and c1<o1 and iBear and c<c1 and c1<c2 and o1<o2 and o1>c2 and o<o1 and o>c1 and
     (c2-l2)<=(o2-c2)*SHADOW_LIMIT and (c1-l1)<=(o1-c1)*SHADOW_LIMIT and (c-l)<=(o-c)*SHADOW_LIMIT and tUp
bool sR3M = c4>o4 and c3<o3 and c2<o2 and c1<o1 and h3<h4 and l3>l4 and h2<h4 and l2>l4 and h1<h4 and l1>l4 and iBull and c>c4 and tUp
bool sF3M = c4<o4 and c3>o3 and c2>o2 and c1>o1 and h3<h4 and l3>l4 and h2<h4 and l2>l4 and h1<h4 and l1>l4 and iBear and c<c4 and tDn
bool sUTG = c2>o2 and c1>o1 and l1>h2 and iBear and o<c1 and o>o1 and c>h2 and c<=l1 and tUp
bool sDTG = c2<o2 and c1<o1 and h1<l2 and iBull and o>c1 and o<o1 and c<l2 and c>=h1 and tDn
bool s3LSu = c3<o3 and c2<o2 and c1<o1 and c2<c3 and c1<c2 and iBull and c>o3 and o<=c1 and br0>=STRONG_BODY_RATIO and tDn
bool s3LSd = c3>o3 and c2>o2 and c1>o1 and c2>c3 and c1>c2 and iBear and c<o3 and o>=c1 and br0>=STRONG_BODY_RATIO and tUp

f_addPat(isBullEngulf, 'BE+',  'Bullish Engulfing',      col_bullish, true,  bullES)
f_addPat(isBearEngulf, 'BE-',  'Bearish Engulfing',      col_bearish, false, bearES)
f_addPat(isMornStar,   'MS',   'Morning Star',           col_bullish, true,  4)
f_addPat(isEvnStar,    'ES',   'Evening Star',           col_bearish, false, 4)
f_addPat(isMornDoji,   'MDS',  'Morning Doji Star',      col_bullish, true,  4)
f_addPat(isEvnDoji,    'EDS',  'Evening Doji Star',      col_bearish, false, 4)
f_addPat(isAbbBull,    'ABB+', 'Abandoned Baby Bull',    col_bullish, true,  4)
f_addPat(isAbbBear,    'ABB-', 'Abandoned Baby Bear',    col_bearish, false, 4)
f_addPat(isMzBull,     'MZ+',  'Bullish Marubozu',       col_bullish, true,  4)
f_addPat(isMzBear,     'MZ-',  'Bearish Marubozu',       col_bearish, false, 4)
f_addPat(s3LSu,        '3LS+', 'Three Line Strike Bull', col_special, true,  4)
f_addPat(s3LSd,        '3LS-', 'Three Line Strike Bear', col_special, false, 4)
f_addPat(s3WS, '3WS', 'Three White Soldiers',  col_bullish, true,  5)
f_addPat(s3BC, '3BC', 'Three Black Crows',     col_bearish, false, 5)
f_addPat(sBKu, 'BK+', 'Bullish Kicker',        col_bullish, true,  5)
f_addPat(sBKd, 'BK-', 'Bearish Kicker',        col_bearish, false, 5)
f_addPat(sR3M, 'R3M', 'Rising Three Methods',  col_bullish, true,  5)
f_addPat(sF3M, 'F3M', 'Falling Three Methods', col_bearish, false, 5)
f_addPat(sUTG, 'UTG', 'Upside Tasuki Gap',     col_bullish, true,  5)
f_addPat(sDTG, 'DTG', 'Downside Tasuki Gap',   col_bearish, false, 5)

// Pattern boost
float pat_boost  = best.strength == 5 ? (best.isBull ? 0.25 : -0.25) :
                   best.strength == 4 ? (best.isBull ? 0.10 : -0.10) : 0.0
float sc_boosted = math.max(-1.0, math.min(1.0, sc_norm + pat_boost))

// ─── LAYER 4 — CONFIDENCE ENGINE ─────────────────────────────
float disp_body      = math.abs(close - open)
float disp_threshold = 0.90 - s9_tqi * 0.25
bool  strong_disp    = disp_body > atr * disp_threshold and volume > volMean * 1.6

bool high_conf_bull = best.strength >= 4
     and best.isBull
     and sc_boosted > 0.40
     and strong_disp
     and s9_tqi > 0.65

bool high_conf_bear = best.strength >= 4
     and not best.isBull
     and sc_boosted < -0.40
     and strong_disp
     and s9_tqi > 0.65

bool conf_conflict = best.strength >= 4 and
     ((best.isBull and sc_boosted < -0.2) or (not best.isBull and sc_boosted > 0.2))

// ═══════════════════════════════════════════════════════════════
// LAYER 5 — VISUALIZATION
// ═══════════════════════════════════════════════════════════════

color sc_bright = sc_boosted <= -0.5 ? color.from_gradient(sc_boosted, -1.0, -0.5, c_maroon_hi, c_red_hi) :
     sc_boosted <=  0.0 ? color.from_gradient(sc_boosted, -0.5,  0.0, c_red_hi,    c_yellow_hi) :
     sc_boosted <=  0.5 ? color.from_gradient(sc_boosted,  0.0,  0.5, c_yellow_hi, c_green_hi)  :
                          color.from_gradient(sc_boosted,  0.5,  1.0, c_green_hi,  c_cyan_hi)

color sc_dark = sc_boosted <= -0.5 ? color.from_gradient(sc_boosted, -1.0, -0.5, c_maroon_lo, c_red_lo) :
     sc_boosted <=  0.0 ? color.from_gradient(sc_boosted, -0.5,  0.0, c_red_lo,    c_yellow_lo) :
     sc_boosted <=  0.5 ? color.from_gradient(sc_boosted,  0.0,  0.5, c_yellow_lo, c_green_lo)  :
                          color.from_gradient(sc_boosted,  0.5,  1.0, c_green_lo,  c_cyan_lo)

bool  sc_bull = close >= open
color sc_col  = sc_bull ? sc_bright : sc_dark

plotcandle(open, high, low, close, "Smart Candles",
     color       = showCandles ? (sc_bull ? na : sc_col) : na,
     wickcolor   = showCandles ? sc_col : na,
     bordercolor = showCandles ? sc_col : na)

// EVWAP + Sigma Bands
plot(show_evwap ? ewPlot : na, "EVWAP", color=ewCol, linewidth=2, style=plot.style_linebr)
plot(show_evwap and show_ew_bands ? ew_band1u : na, "EVWAP +1σ", color=color.new(ew_band_col, 60), linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dashed)
plot(show_evwap and show_ew_bands ? ew_band2u : na, "EVWAP +2σ", color=color.new(ew_band_col, 40), linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dotted)
plot(show_evwap and show_ew_bands ? ew_band1d : na, "EVWAP -1σ", color=color.new(ew_band_col, 60), linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dashed)
plot(show_evwap and show_ew_bands ? ew_band2d : na, "EVWAP -2σ", color=color.new(ew_band_col, 40), linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dotted)

p_band1u = plot(show_evwap and show_ew_bands ? ew_band1u : na, display=display.none)
p_band1d = plot(show_evwap and show_ew_bands ? ew_band1d : na, display=display.none)
fill(p_band1u, p_band1d, color=color.new(ew_band_col, 93), title="EVWAP Fair Value Zone")

var label ewLbl = na
if show_evwap and not na(ewPlot)
    label.delete(ewLbl)
    ewLbl := label.new(n, ewSmoothed, "⧭", style=label.style_none, textcolor=ewCol, size=size.normal)

// Adaptive Pivot lines + flip labels
plot(show_s9 and use_s9 ? (s9_trend ==  1 ? s9_lower : na) : na, "S9 Bull",
     color=bullCol, linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dotted)
plot(show_s9 and use_s9 ? (s9_trend == -1 ? s9_upper : na) : na, "S9 Bear",
     color=bearCol, linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dotted)

if show_s9 and use_s9
    if s9_flipUp
        label.new(n, s9_lower,
             text      = "▲",
             style     = label.style_none,
             color     = color.new(color.yellow, 0),
             textcolor = color.yellow,
             size      = size.small)
    if s9_flipDn
        label.new(n, s9_upper,
             text      = "▼",
             style     = label.style_none,
             color     = color.new(color.yellow, 0),
             textcolor = color.yellow,
             size      = size.small)

// Pattern classification
bool is_reversal = best.shortTxt == "BE+"  or best.shortTxt == "BE-"  or
     best.shortTxt == "MS"   or best.shortTxt == "ES"   or
     best.shortTxt == "MDS"  or best.shortTxt == "EDS"  or
     best.shortTxt == "ABB+" or best.shortTxt == "ABB-" or
     best.shortTxt == "BK+"  or best.shortTxt == "BK-"

bool is_continuation = best.shortTxt == "MZ+"  or best.shortTxt == "MZ-"  or
     best.shortTxt == "3WS"  or best.shortTxt == "3BC"  or
     best.shortTxt == "R3M"  or best.shortTxt == "F3M"  or
     best.shortTxt == "UTG"  or best.shortTxt == "DTG"  or
     best.shortTxt == "3LS+" or best.shortTxt == "3LS-"

bool regime_bull    = s9_trend == 1  and ew_dir == 1
bool regime_bear    = s9_trend == -1 and ew_dir == -1
bool regime_aligned = (best.isBull and regime_bull) or (not best.isBull and regime_bear)

float rev_limit  = s9_tqi > 0.75 ? 0.35 : s9_tqi > 0.60 ? 0.45 : 0.60
bool soft_conflict = math.abs(sc_boosted) < rev_limit
bool show_full     = (is_reversal and soft_conflict) or (is_continuation and regime_aligned)

if showPatterns and best.strength >= 4
    if array.size(patternLabels) >= maxPattern
        label.delete(array.shift(patternLabels))

    float  ypos     = best.isBull ? l * 0.999 : h * 1.001
    string sty      = best.isBull ? label.style_label_up : label.style_label_down
    string strTx    = best.strength == 5 ? "Very Strong" : "Strong"
    string confTx   = high_conf_bull or high_conf_bear ? " ★" : ""
    string rev_mark = is_reversal and not regime_aligned ? " ↩" : ""
    color  lbl_col  = show_full ? best.col : color.new(color.gray, 30)
    color  lbl_txt  = show_full ? col_txt  : color.new(color.gray, 60)
    string lbl_tip  = is_reversal and not regime_aligned
         ? best.fullTxt + " | ↩ Early Reversal — regime not yet confirmed"
         : show_full
         ? best.fullTxt + (high_conf_bull or high_conf_bear ? " | ★ HIGH CONF" : "")
         : best.fullTxt + " | ~ Continuation against prevailing regime"
    string lbl_text = best.shortTxt + "\n" + strTx + confTx + rev_mark

    label lbl = label.new(n, ypos,
         text      = lbl_text,
         style     = sty,
         color     = lbl_col,
         textcolor = lbl_txt,
         size      = show_full ? size.small : size.tiny,
         tooltip   = lbl_tip)
    array.push(patternLabels, lbl)

// RR Boxes
float max_risk_atr = 2.5
if show_rr and show_signals
    if high_conf_bull
        bool swing_recent_bull = not na(prevSwLo) and (n - ew_plL) < 25
        float sl        = swing_recent_bull ? prevSwLo - atr * 0.15 : l - atr * 0.5
        float risk_raw  = close - sl
        float risk      = math.min(risk_raw, atr * max_risk_atr)
        float sl_capped = close - risk
        float tp        = close + risk * 2.0
        box.new(n, tp,         n + 20, close,     bgcolor=color.new(color.white, 90), border_color=color.new(color.white, 30), border_style=line.style_dotted)
        box.new(n, close,      n + 20, sl_capped, bgcolor=color.new(color.blue,  90), border_color=color.new(color.blue,  30), border_style=line.style_dotted)
    if high_conf_bear
        bool swing_recent_bear = not na(prevSwHi) and (n - ew_phL) < 25
        float sl        = swing_recent_bear ? prevSwHi + atr * 0.15 : h + atr * 0.5
        float risk_raw  = sl - close
        float risk      = math.min(risk_raw, atr * max_risk_atr)
        float sl_capped = close + risk
        float tp        = close - risk * 2.0
        box.new(n, sl_capped,  n + 20, close, bgcolor=color.new(color.blue,  90), border_color=color.new(color.blue,  30), border_style=line.style_dotted)
        box.new(n, close,      n + 20, tp,    bgcolor=color.new(color.white, 90), border_color=color.new(color.white, 30), border_style=line.style_dotted)

// ─── DASHBOARD (5 rows: Bias, Council, S9, EVWAP, Trend) ─────
if dashPos != "Hide" and barstate.isconfirmed
    dPos = dashPos == "Top Left"     ? position.top_left     :
           dashPos == "Bottom Right" ? position.bottom_right :
           dashPos == "Bottom Left"  ? position.bottom_left  : position.top_right

    var table dash = table.new(dPos, 2, 6,
         bgcolor      = color.new(color.rgb(10, 14, 23), 15),
         border_color = color.rgb(42, 46, 55),
         border_width = 1)

    color col_muted = color.rgb(156, 163, 175)
    color col_gold  = color.rgb(255, 215, 0)

    // Header
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 0, "Confluence Flow",
         text_color=col_gold, text_size=size.small, bgcolor=color.rgb(10, 14, 23))

    // Row 1: Bias
    string biasStr = sc_boosted >  0.5 ? "Full Bull ↑" :
                     sc_boosted >  0.1 ? "Bull ↑"      :
                     sc_boosted >= -0.1 ? "Neutral"    :
                     sc_boosted >= -0.5 ? "Bear ↓"     : "Full Bear ↓"
    table.cell(dash, 0, 1, "Bias",    text_color=col_muted, text_size=size.small)
    table.cell(dash, 1, 1, biasStr + " (" + str.tostring(sc_boosted, "#.##") + ")",
         text_color=sc_col, text_size=size.small)

    // Row 2: Council
    string voteStr = str.tostring(bullVotes) + "↑ / " + str.tostring(bearVotes) + "↓"
    color  voteCol = bullVotes > bearVotes ? bullCol : bearVotes > bullVotes ? bearCol : col_muted
    table.cell(dash, 0, 2, "Council", text_color=col_muted, text_size=size.small)
    table.cell(dash, 1, 2, voteStr,   text_color=voteCol,   text_size=size.small)

    // Row 3: S9 Adaptive Pivots
    table.cell(dash, 0, 3, "S9",      text_color=col_muted, text_size=size.small)
    table.cell(dash, 1, 3, s9_trend == 1 ? "Bull ↑" : "Bear ↓",
         text_color=s9_trend == 1 ? bullCol : bearCol, text_size=size.small)

    // Row 4: EVWAP
    table.cell(dash, 0, 4, "EVWAP",   text_color=col_muted, text_size=size.small)
    table.cell(dash, 1, 4, ewAncDir > 0 ? "Bull ↑" : "Bear ↓",
         text_color=ewCol, text_size=size.small)

    // Row 5: Trend
    table.cell(dash, 0, 5, "Trend",   text_color=col_muted, text_size=size.small)
    table.cell(dash, 1, 5, isUp ? "Up ↑" : isDn ? "Down ↓" : "Sideways",
         text_color=isUp ? bullCol : isDn ? bearCol : col_muted, text_size=size.small)

// ─── ALERTS ──────────────────────────────────────────────────
alertcondition(high_conf_bull, "High Conf Long",  "Smart Candle Fusion v11: High Confidence Long")
alertcondition(high_conf_bear, "High Conf Short", "Smart Candle Fusion v11: High Confidence Short")
alertcondition(conf_conflict,  "Conflict",        "Smart Candle Fusion v11: Pattern vs Regime Conflict")
alertcondition(sigUp,          "Council Bull",    "Smart Candle Fusion v11: Council 2+ Bull votes")
alertcondition(sigDown,        "Council Bear",    "Smart Candle Fusion v11: Council 2+ Bear votes")
````
