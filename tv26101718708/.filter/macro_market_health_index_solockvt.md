# Macro Market Health Index

- url: https://www.tradingview.com/script/SoLoCKvT-Macro-Market-Health-Index/
- type: indicator
- pine_id: PUB;5f0ff9882c6a4a009cd587982f19be25
- version: 1.0

## Description

This comprehensive indicator, Macro Market Health and Dynamic Regime Scoring, is a multi-asset "Risk-ON / Risk-OFF" framework designed to quantify market health by analyzing six specialized macro pillars. Unlike static indicators, this tool features an adaptive weighting engine that calibrates the importance of each macro block based on its real-time relationship with the specific asset currently on your chart
.
The Six Pillars of Market Health
The indicator processes raw data through six "Blocks," each utilizing specific mathematical models to score health from 0 to 1
:
Risk Block (Sentiment): Monitors the VIX (normalized against a baseline of 22), Gold, and the USD/JPY "Carry Trade"
. It calculates a blend of absolute levels (distance from the 200-day EMA) and momentum (9-day ROC of the 21-day EMA) to detect capital flight into safe havens
.
Breadth Block (Internal Strength): Uses the S5FI (S&P 500 stocks above their 50-day EMA) and the SPX/RSP Spread
. If the standard S&P 500 is significantly outperforming the equal-weighted version, it signals poor "under the hood" participation
.
Equity Block (Momentum & Volume): Analyzes the S&P 500 using a Gaussian "Sweet Spot" model
. It scores the trend highest when the price is in a healthy range above the 200-day EMA, while also penalizing the score if relative volume trends (21-day vs 251-day EMA) show exhaustion
.
Crypto Block (Risk Appetite): Serves as a high-beta proxy by measuring Bitcoin's distance from its 50, 100, and 200-day EMAs
. These are weighted (45% for 50-day, 32% for 100-day, 23% for 200-day) to capture multi-timeframe risk sentiment
.
Growth Block (Economic Context): Tracks Crude Oil and its 50-day correlation to equities
. It identifies whether energy prices are acting as a growth driver or a risk-off inflationary headwind
.
Credit Block (Fixed Income): Monitors the HYG (High Yield Corporate Bonds) as a leading indicator of credit stress
. It evaluates both the trend level and the rate of change in corporate bond demand
.
Advanced Mathematical Components
To ensure all data is comparable, the script employs several core math engines:
Sigmoid Normalization: Squashes all outputs into a standard 0 to 1 range for easy comparison
.
Z-Score Sigmoids: Normalizes volatility and momentum by measuring how many standard deviations a value is from its mean
.
Gaussian Probability: Uses a bell-curve distribution to score the "Equity Block," rewarding trends that stay within a specific volatility-adjusted distance from the mean
.
Distance/ATR Scaling: All price distances from moving averages are divided by the ATR (Average True Range) to ensure the scores are relative to current market volatility
.
Data-Driven Weighting: Tailored to YOUR Asset
The standout feature is the Weight Engine, which rejects the "one-size-fits-all" approach. It calculates weights against the specific ticker (hlc3) on your chart
:
Asset Correlation: The indicator measures the real-time statistical correlation between each macro block and the specific stock you are trading
. If your stock starts moving in lockstep with Credit or Crypto, those blocks are automatically given more weight
.
Dynamic Volatility Scaling: It calculates the ratio of a block's volatility (CV) to your stock's volatility (CV) to dynamically adjust the lookback period (between 50 and 300 bars)
Adaptive Lookback Engine: The index uses the Coefficient of Variation (CV) (StandardDeviation/Mean) to compare macro environment volatility against your stock's volatility
. This ratio automatically scales the lookback window between 50 bars (for high-volatility responsiveness) and 300 bars (for stable trend smoothing)
.
Weighting & Analytics: Final weights blend asset-specific correlation with Inverse Volatility (1/SD) to prioritize correlated, stable, low-noise signals
.
Signals and Predictive Analytics
Trade Status Overlay: Provides a definitive "TRADE" (Score > 0.58) or "NO TRADE" (Score < 0.45) signal
.
Regime Classification: Categorizes the market into BULL MARKET, EARLY BULL, NEUTRAL, or RISK OFF
.
Swing Probability: Uses a Gaussian Survival Model to estimate the conditional probability that a "Risk-ON" or "Risk-Off" (current identified) regime will last for a user-defined "Swing Duration" (e.g., the next 21 bars)
.
Reliability Index: Based on the number of historical samples collected for that specific asset, it labels the probability data as Adequate, Marginal, or Low
.

## Source Code

````pine
//@version=6
indicator("Macro Market Health (Fixed vs Data-Driven Weights)", overlay=false, precision=4)

// ======================================================================
// Helper Functions
// ======================================================================
sig01(x) =>
    1.0 / (1.0 + math.exp(-x))

z_sig(src, len) =>
    m  = ta.sma(src, len)
    sd = ta.stdev(src, len)
    z  = (src - m) / (sd + 1e-6)
    sig01(z)

f_gauss(x, mu, sigma) =>
    z = (x - mu) / sigma
    math.exp(-(z * z) / 2)

roc9_ema21_atr21(src, symbol) =>
    ema21 = ta.ema(src, 21)
    atr21 = request.security(symbol, timeframe.period, ta.atr(21))
    (ema21 - ema21[9]) / (atr21 + 1e-6)

normDistEma(src, symbol, len) => 
    emaVal = ta.ema(src, len) 
    atr21 = request.security(symbol, timeframe.period, ta.atr(21)) 
    (src - emaVal) * 0.5 / (atr21 + 1e-6)
// ======================================================================
// Inputs
// ======================================================================
stdLen      = input.int(50, "Normalization Length", minval=10)
rocLen      = input.int(5,  "ROC Lookback", minval=1)
smoothMHI   = input.int(5,  "Smoothing Length", minval=1)
showTable   = input.bool(true, "Show Dashboard?")
useOverlay  = input.bool(true, "Show Status Overlay?")
showWeightTable = input.bool(false, "Show Weight Engine Table?")

cl          = input.int(21,   "Correlation Length",       minval=10)
corrLook    = input.int(252,  "Corr Percentile Lookback", minval=200)
alphaBlend  = input.float(0.7,"Blend Corr vs InvSD",      minval=0, maxval=1)

trendW = 0.70
rocW   = 0.30

spx_gauss_center = input.float(3.43, "SPX Distance Gaussian Center", step=0.1, group="Equity Block")
spx_gauss_width  = input.float(1.96, "SPX Distance Gaussian Width",  step=0.1, group="Equity Block")

// ======================================================================
// Macro Data
// ======================================================================
spx     = request.security("SP:SPX",          timeframe.period, ta.vwma(hlc3, 5))
rsp     = request.security("RSP",             timeframe.period, ta.vwma(hlc3, 5))
vix     = request.security("CBOE:VIX",        timeframe.period, close)
gold    = request.security("OANDA:XAUUSD",    timeframe.period, close)
crude   = request.security("NYMEX:CL1!",      timeframe.period, close)
btc     = request.security("BINANCE:BTCUSDT", timeframe.period, close)
usdjpy  = request.security("FX:USDJPY",       timeframe.period, close)
hyg     = request.security("HYG",             timeframe.period, ta.vwma(hlc3, 5))
breadth = request.security("S5FI",            timeframe.period, close)

// ======================================================================
// Distance from EMA / ATR normalization
// ======================================================================
normDist(src, symbol) =>
    ema200 = ta.ema(src, 200)
    atr20  = request.security(symbol, timeframe.period, ta.atr(20))
    (src - ema200) * 0.5 / (atr20 + 1e-6)

spx_dist    = normDist(spx,    "SP:SPX")
btc_dist    = normDist(btc,    "BINANCE:BTCUSDT")
gold_dist   = normDist(gold,   "OANDA:XAUUSD")
crude_dist  = normDist(crude,  "NYMEX:CL1!")
usdjpy_dist = normDist(usdjpy, "FX:USDJPY")
hyg_dist    = normDist(hyg,    "HYG")

// ======================================================================
// RISK BLOCK
// ======================================================================
k         = 3.0
vix_norm  = (vix - 22) / 22
vix_level = sig01(-k * vix_norm)
vix_z_inv = 1 - z_sig(vix, stdLen)
vix_n     = 0.5 * vix_level + 0.5 * vix_z_inv

gold_level  = sig01(-gold_dist)
carry_level = sig01(usdjpy_dist)

gold_roc_raw  = roc9_ema21_atr21(gold, "OANDA:XAUUSD")
carry_roc_raw = roc9_ema21_atr21(usdjpy, "FX:USDJPY")

gold_roc_n  = 1 - sig01(gold_roc_raw)
carry_roc_n = sig01(carry_roc_raw)

gold_n =
     0.70 * gold_level +
     0.30 * gold_roc_n

carry_n =
     0.70 * carry_level +
     0.30 * carry_roc_n

risk_block = (vix_n + gold_n + carry_n) / 3

// ======================================================================
// BREADTH BLOCK
// ======================================================================
breadth_s5fi_level = breadth / 100.0

breadth_s5fi_roc_raw = breadth_s5fi_level - breadth_s5fi_level[rocLen]
breadth_s5fi_roc_n   = sig01(breadth_s5fi_roc_raw * 10)

breadth_s5fi =
     0.70 * breadth_s5fi_level +
     0.30 * breadth_s5fi_roc_n

spx_ema        = ta.ema(spx, 14)
rsp_ema        = ta.ema(rsp, 14)
spx_pct        = (spx - spx_ema) / (spx_ema + 1e-6)
rsp_pct        = (rsp - rsp_ema) / (rsp_ema + 1e-6)
breadth_spread = spx_pct - rsp_pct
breadth_ratio  = z_sig(-breadth_spread, stdLen)

breadth_block  = 0.7 * breadth_s5fi + 0.3 * breadth_ratio

// ======================================================================
// EQUITY BLOCK
// ======================================================================
trend_component = spx_dist > 0 ? f_gauss(spx_dist, spx_gauss_center, spx_gauss_width) : 0.0

spx_vol   = request.security("SP:SPX", timeframe.period, volume)
v_long    = ta.ema(spx_vol, 251)
v_short   = ta.ema(spx_vol, 21)
vol_raw   = (v_long - v_short) / (v_long + 1e-6)
vol_block = sig01(-vol_raw)

equity_level = 0.75 * trend_component + 0.25 * vol_block

equity_roc_raw = equity_level - equity_level[rocLen]
equity_roc_n   = sig01(equity_roc_raw * 10)

equity_block =
     0.75 * equity_level +
     0.25 * equity_roc_n

// ======================================================================
// OTHER BLOCKS
// ======================================================================
btc50 = normDistEma(btc, "BINANCE:BTCUSDT", 50) 
btc100 = normDistEma(btc, "BINANCE:BTCUSDT", 100) 
btc200 = normDistEma(btc, "BINANCE:BTCUSDT", 200) 
btc_combo = 0.453 * btc50 + 0.32 * btc100 + 0.227 * btc200 
crypto_block = sig01(btc_combo)

corr_crude   = ta.correlation(crude, spx, 50)
growth_sign  = corr_crude >= 0 ? 1 : -1
growth_block = sig01(growth_sign * crude_dist)

credit_level = sig01(hyg_dist)

credit_roc_raw = roc9_ema21_atr21(hyg, "HYG")
credit_roc_n   = sig01(credit_roc_raw)

credit_block =
     0.70 * credit_level +
     0.30 * credit_roc_n

// ======================================================================
// FIXED-WEIGHT MHI
// ======================================================================
w_risk   = 0.30
w_bread  = 0.20
w_equity = 0.15
w_crypto = 0.10
w_growth = 0.10
w_credit = 0.15

MHI_trend   = w_risk   * risk_block   +
              w_bread  * breadth_block +
              w_equity * equity_block  +
              w_crypto * crypto_block  +
              w_growth * growth_block  +
              w_credit * credit_block

MHI_trend_s = ta.ema(MHI_trend, smoothMHI)
MHI_roc     = z_sig(MHI_trend_s - MHI_trend_s[rocLen], stdLen)
MHI_Final   = trendW * MHI_trend_s + rocW * MHI_roc

// ======================================================================
// DATA-DRIVEN WEIGHTS
// ======================================================================
stockSdLen = input.int(21,  "Stock SD Length",           minval=5)
blockSdLen = input.int(251, "Block SD Length",            minval=50)
ratioLook  = input.int(252, "Ratio Percentile Lookback",  minval=100)
minSdLen   = input.int(50,  "Min Dynamic SD Len",         minval=20)
maxSdLen   = input.int(300, "Max Dynamic SD Len",         minval=50)

eps         = 1e-6
fallbackLen = blockSdLen
stockSD     = ta.stdev(hlc3, stockSdLen) / (ta.sma(hlc3, stockSdLen) + eps)

clamp01(x) =>
    math.max(0.0, math.min(x, 1.0))

dynLenFromRatio(block) =>
    blockSD  = ta.stdev(block, blockSdLen) / (ta.sma(block, blockSdLen) + eps)
    ratio_   = blockSD / (stockSD + eps)
    q25      = ta.lowest(ratio_,  ratioLook)
    q75      = ta.highest(ratio_, ratioLook)
    band     = q75 - q25
    rawLen   = na(q25) or na(q75) or na(ratio_) or band <= 0 ? fallbackLen :
               math.round(maxSdLen - clamp01((ratio_ - q25) / (band + eps)) * (maxSdLen - minSdLen))
    var int stableLen = na
    stableLen := na(stableLen[1]) ? int(rawLen) : na(rawLen) ? stableLen[1] : int(rawLen)
    math.max(minSdLen, math.min(stableLen, maxSdLen))

dynLen_risk = math.max(
     dynLenFromRatio(vix),
     math.max(dynLenFromRatio(gold), dynLenFromRatio(usdjpy)))

dynLen_breadth = math.max(dynLenFromRatio(breadth), dynLenFromRatio(rsp))
dynLen_equity  = dynLenFromRatio(spx)
dynLen_crypto  = dynLenFromRatio(btc)
dynLen_growth  = dynLenFromRatio(crude)
dynLen_credit  = dynLenFromRatio(hyg)

inv_risk    = 1 / (ta.stdev(risk_block,    dynLen_risk)    + eps)
inv_breadth = 1 / (ta.stdev(breadth_block, dynLen_breadth) + eps)
inv_equity  = 1 / (ta.stdev(equity_block,  dynLen_equity)  + eps)
inv_crypto  = 1 / (ta.stdev(crypto_block,  dynLen_crypto)  + eps)
inv_growth  = 1 / (ta.stdev(growth_block,  dynLen_growth)  + eps)
inv_credit  = 1 / (ta.stdev(credit_block,  dynLen_credit)  + eps)

spx_state = hlc3

corr(src) => ta.correlation(src, spx_state, cl)
corrQ(x)  => ta.percentile_linear_interpolation(x, corrLook, 75)

r_risk    = corrQ(corr(risk_block))
r_breadth = corrQ(corr(breadth_block))
r_equity  = corrQ(corr(equity_block))
r_crypto  = corrQ(corr(crypto_block))
r_growth  = corrQ(corr(growth_block))
r_credit  = corrQ(corr(credit_block))

sumR = math.abs(r_risk)   + math.abs(r_breadth) + math.abs(r_equity) +
       math.abs(r_crypto) + math.abs(r_growth)  + math.abs(r_credit) + 1e-6

wC_risk    = r_risk    / sumR
wC_breadth = r_breadth / sumR
wC_equity  = r_equity  / sumR
wC_crypto  = r_crypto  / sumR
wC_growth  = r_growth  / sumR
wC_credit  = r_credit  / sumR

sumInv = inv_risk + inv_breadth + inv_equity +
         inv_crypto + inv_growth + inv_credit + 1e-6

wI_risk    = inv_risk    / sumInv
wI_breadth = inv_breadth / sumInv
wI_equity  = inv_equity  / sumInv
wI_crypto  = inv_crypto  / sumInv
wI_growth  = inv_growth  / sumInv
wI_credit  = inv_credit  / sumInv

blend(a, b) => alphaBlend * a + (1 - alphaBlend) * b

w_risk_f    = math.sign(r_risk)    * blend(math.abs(wC_risk),    wI_risk)
w_breadth_f = math.sign(r_breadth) * blend(math.abs(wC_breadth), wI_breadth)
w_equity_f  = math.sign(r_equity)  * blend(math.abs(wC_equity),  wI_equity)
w_crypto_f  = math.sign(r_crypto)  * blend(math.abs(wC_crypto),  wI_crypto)
w_growth_f  = math.sign(r_growth)  * blend(math.abs(wC_growth),  wI_growth)
w_credit_f  = math.sign(r_credit)  * blend(math.abs(wC_credit),  wI_credit)

sumF = math.abs(w_risk_f)   + math.abs(w_breadth_f) + math.abs(w_equity_f) +
       math.abs(w_crypto_f) + math.abs(w_growth_f)  + math.abs(w_credit_f) + 1e-6

w_risk_f    /= sumF
w_breadth_f /= sumF
w_equity_f  /= sumF
w_crypto_f  /= sumF
w_growth_f  /= sumF
w_credit_f  /= sumF

// ======================================================================
// DATA-DRIVEN SCORE
// ======================================================================
NewW_trend = w_risk_f    * risk_block    +
             w_breadth_f * breadth_block +
             w_equity_f  * equity_block  +
             w_crypto_f  * crypto_block  +
             w_growth_f  * growth_block  +
             w_credit_f  * credit_block

NewW_trend_s   = ta.ema(NewW_trend, smoothMHI)
NewW_roc       = z_sig(NewW_trend_s - NewW_trend_s[rocLen], stdLen)
NewWeightScore = trendW * NewW_trend_s + rocW * NewW_roc

// ======================================================================
// PLOTS
// ======================================================================
plot(MHI_Final,      "MHI (Fixed)", color=color.new(color.blue,   0), linewidth=2)
plot(NewWeightScore, "MHI (Data)",  color=color.new(color.purple, 0), linewidth=2)

// ======================================================================
// DASHBOARD TABLE WITH COMPONENT DIRECTION COLUMN
// ======================================================================
tableDeltaThresh = input.float(0.002, "Table Delta Threshold", step=0.001)

heatColor(v) =>
    v > 0.70 ? color.new(color.green,  0)  :
     v > 0.55 ? color.new(color.green, 40) :
     v > 0.45 ? color.new(color.yellow,40) :
     v > 0.30 ? color.new(color.red,   20) :
                 color.new(color.red,    0)

deltaArrow(v) =>
    d = v - nz(v[1], v)
    d > tableDeltaThresh  ? "▲" :
     d < -tableDeltaThresh ? "▼" : "→"

deltaColor(v) =>
    d = v - nz(v[1], v)
    d > tableDeltaThresh  ? color.new(color.green, 0) :
     d < -tableDeltaThresh ? color.new(color.red,   0) :
                              color.new(color.yellow, 0)

var table dash = na

if showTable
    if barstate.isfirst
        dash := table.new(position.top_right, 4, 9, border_width=1)

        table.cell(dash, 0, 0, "Component", bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(dash, 1, 0, "Score",     bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(dash, 2, 0, "Trend",     bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(dash, 3, 0, "Weight",    bgcolor=color.new(color.black, 0), text_color=color.white)

        table.cell(dash, 0, 1, "Risk",      text_color=color.white)
        table.cell(dash, 0, 2, "Breadth",   text_color=color.white)
        table.cell(dash, 0, 3, "Equity",    text_color=color.white)
        table.cell(dash, 0, 4, "Crypto",    text_color=color.white)
        table.cell(dash, 0, 5, "Growth",    text_color=color.white)
        table.cell(dash, 0, 6, "Credit",    text_color=color.white)
        table.cell(dash, 0, 7, "MHI Fixed", text_color=color.white)
        table.cell(dash, 0, 8, "MHI Data",  text_color=color.white)

    if barstate.islast
        table.cell(dash, 1, 1, str.tostring(risk_block,     "#.##"), bgcolor=heatColor(risk_block),     text_color=color.white)
        table.cell(dash, 1, 2, str.tostring(breadth_block,  "#.##"), bgcolor=heatColor(breadth_block),  text_color=color.white)
        table.cell(dash, 1, 3, str.tostring(equity_block,   "#.##"), bgcolor=heatColor(equity_block),   text_color=color.white)
        table.cell(dash, 1, 4, str.tostring(crypto_block,   "#.##"), bgcolor=heatColor(crypto_block),   text_color=color.white)
        table.cell(dash, 1, 5, str.tostring(growth_block,   "#.##"), bgcolor=heatColor(growth_block),   text_color=color.white)
        table.cell(dash, 1, 6, str.tostring(credit_block,   "#.##"), bgcolor=heatColor(credit_block),   text_color=color.white)
        table.cell(dash, 1, 7, str.tostring(MHI_Final,      "#.##"), bgcolor=heatColor(MHI_Final),      text_color=color.white)
        table.cell(dash, 1, 8, str.tostring(NewWeightScore, "#.##"), bgcolor=heatColor(NewWeightScore), text_color=color.white)

        table.cell(dash, 2, 1, deltaArrow(risk_block),     bgcolor=deltaColor(risk_block),     text_color=color.white)
        table.cell(dash, 2, 2, deltaArrow(breadth_block),  bgcolor=deltaColor(breadth_block),  text_color=color.white)
        table.cell(dash, 2, 3, deltaArrow(equity_block),   bgcolor=deltaColor(equity_block),   text_color=color.white)
        table.cell(dash, 2, 4, deltaArrow(crypto_block),   bgcolor=deltaColor(crypto_block),   text_color=color.white)
        table.cell(dash, 2, 5, deltaArrow(growth_block),   bgcolor=deltaColor(growth_block),   text_color=color.white)
        table.cell(dash, 2, 6, deltaArrow(credit_block),   bgcolor=deltaColor(credit_block),   text_color=color.white)
        table.cell(dash, 2, 7, deltaArrow(MHI_Final),      bgcolor=deltaColor(MHI_Final),      text_color=color.white)
        table.cell(dash, 2, 8, deltaArrow(NewWeightScore), bgcolor=deltaColor(NewWeightScore), text_color=color.white)

        table.cell(dash, 3, 1, str.tostring(w_risk_f,    "#.##"), text_color=color.white)
        table.cell(dash, 3, 2, str.tostring(w_breadth_f, "#.##"), text_color=color.white)
        table.cell(dash, 3, 3, str.tostring(w_equity_f,  "#.##"), text_color=color.white)
        table.cell(dash, 3, 4, str.tostring(w_crypto_f,  "#.##"), text_color=color.white)
        table.cell(dash, 3, 5, str.tostring(w_growth_f,  "#.##"), text_color=color.white)
        table.cell(dash, 3, 6, str.tostring(w_credit_f,  "#.##"), text_color=color.white)
        table.cell(dash, 3, 7, "Fixed", text_color=color.white)
        table.cell(dash, 3, 8, "Data",  text_color=color.white)
// ======================================================================
// STATUS OVERLAY
// ======================================================================
onLevel  = 0.58
offLevel = 0.45

var bool tradeON = false
if NewWeightScore > onLevel
    tradeON := true
if NewWeightScore < offLevel
    tradeON := false

tradeText  = tradeON ? "TRADE" : "NO TRADE"
tradeColor = tradeON ? color.new(color.green, 0) : color.new(color.red, 0)

slope      = NewWeightScore - NewWeightScore[5]
trendArrow = slope > 0.005 ? "▲" : slope < -0.005 ? "▼" : "→"
trendColor = slope > 0.005 ? color.new(color.green,  0) :
             slope < -0.005 ? color.new(color.red,   0) :
                              color.new(color.yellow, 0)

marketText  = MHI_Final > 0.70 ? "BULL MARKET" :
              MHI_Final > 0.55 ? "EARLY BULL"  :
              MHI_Final > 0.45 ? "NEUTRAL"      : "RISK OFF"
marketColor = MHI_Final > 0.70 ? color.new(color.green,  0)  :
              MHI_Final > 0.55 ? color.new(color.green,  40) :
              MHI_Final > 0.45 ? color.new(color.yellow, 40) :
                                 color.new(color.red,     0)

agreement  = 1.0 - math.abs(MHI_Final - NewWeightScore)
agreeText  = "Agreement: " + str.tostring(agreement * 100, "#.#") + "%"
agreeColor = agreement > 0.80 ? color.new(color.green,  0) : agreement > 0.60 ? color.new(color.yellow, 0) : color.new(color.red,    0)

greenCount  = 0
greenCount += risk_block    > 0.55 ? 1 : 0
greenCount += breadth_block > 0.55 ? 1 : 0
greenCount += equity_block  > 0.55 ? 1 : 0
greenCount += crypto_block  > 0.55 ? 1 : 0
greenCount += growth_block  > 0.55 ? 1 : 0
greenCount += credit_block  > 0.55 ? 1 : 0

greenPct   = greenCount / 6.0
greenText  = "Blocks Green: " + str.tostring(greenCount) + "/6 (" +
             str.tostring(greenPct * 100, "#") + "%)"
greenColor = greenPct >= 0.83 ? color.new(color.green,  0) :
             greenPct >= 0.50 ? color.new(color.yellow, 0) :
                                 color.new(color.red,    0)

if useOverlay
    var table statusTbl = na
    if barstate.isfirst
        statusTbl := table.new(position.top_right, 1, 5, border_width=1, force_overlay=true)
    if barstate.islast
        table.cell(statusTbl, 0, 0, tradeText,
             bgcolor=tradeColor,  text_color=color.white)
        table.cell(statusTbl, 0, 1, "Stock Macro Trend: " + trendArrow,
             bgcolor=trendColor,  text_color=color.white)
        table.cell(statusTbl, 0, 2, "Market Regime: " + marketText,
             bgcolor=marketColor, text_color=color.white)
        table.cell(statusTbl, 0, 3, agreeText,
             bgcolor=agreeColor,  text_color=color.white)
        table.cell(statusTbl, 0, 4, greenText,
             bgcolor=greenColor,  text_color=color.white)

// ======================================================================
// WEIGHT ENGINE DIAGNOSTIC TABLE
// ======================================================================
var table wtTbl = na

if showWeightTable
    if barstate.isfirst
        wtTbl := table.new(position.top_right, 7, 7, border_width=1)
        table.cell(wtTbl, 0, 0, "Block",  bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 1, 0, "Corr",   bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 2, 0, "wCorr",  bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 3, 0, "SD Len", bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 4, 0, "1/SD",   bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 5, 0, "wInvSD", bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 6, 0, "Final",  bgcolor=color.new(color.blue,70), text_color=color.white)
        table.cell(wtTbl, 0, 1, "Risk",text_color=color.white)
        table.cell(wtTbl, 0, 2, "Breadth",text_color=color.white)
        table.cell(wtTbl, 0, 3, "Equity",text_color=color.white)
        table.cell(wtTbl, 0, 4, "Crypto",text_color=color.white)
        table.cell(wtTbl, 0, 5, "Growth",text_color=color.white)
        table.cell(wtTbl, 0, 6, "Credit",text_color=color.white)

    if barstate.islast
        table.cell(wtTbl, 1, 1, str.tostring(r_risk,    "#.###"))
        table.cell(wtTbl, 1, 2, str.tostring(r_breadth, "#.###"))
        table.cell(wtTbl, 1, 3, str.tostring(r_equity,  "#.###"))
        table.cell(wtTbl, 1, 4, str.tostring(r_crypto,  "#.###"))
        table.cell(wtTbl, 1, 5, str.tostring(r_growth,  "#.###"))
        table.cell(wtTbl, 1, 6, str.tostring(r_credit,  "#.###"))
        table.cell(wtTbl, 2, 1, str.tostring(wC_risk,    "#.###"))
        table.cell(wtTbl, 2, 2, str.tostring(wC_breadth, "#.###"))
        table.cell(wtTbl, 2, 3, str.tostring(wC_equity,  "#.###"))
        table.cell(wtTbl, 2, 4, str.tostring(wC_crypto,  "#.###"))
        table.cell(wtTbl, 2, 5, str.tostring(wC_growth,  "#.###"))
        table.cell(wtTbl, 2, 6, str.tostring(wC_credit,  "#.###"))
        table.cell(wtTbl, 3, 1, str.tostring(dynLen_risk))
        table.cell(wtTbl, 3, 2, str.tostring(dynLen_breadth))
        table.cell(wtTbl, 3, 3, str.tostring(dynLen_equity))
        table.cell(wtTbl, 3, 4, str.tostring(dynLen_crypto))
        table.cell(wtTbl, 3, 5, str.tostring(dynLen_growth))
        table.cell(wtTbl, 3, 6, str.tostring(dynLen_credit))
        table.cell(wtTbl, 4, 1, str.tostring(inv_risk,    "#.###"))
        table.cell(wtTbl, 4, 2, str.tostring(inv_breadth, "#.###"))
        table.cell(wtTbl, 4, 3, str.tostring(inv_equity,  "#.###"))
        table.cell(wtTbl, 4, 4, str.tostring(inv_crypto,  "#.###"))
        table.cell(wtTbl, 4, 5, str.tostring(inv_growth,  "#.###"))
        table.cell(wtTbl, 4, 6, str.tostring(inv_credit,  "#.###"))
        table.cell(wtTbl, 5, 1, str.tostring(wI_risk,    "#.###"))
        table.cell(wtTbl, 5, 2, str.tostring(wI_breadth, "#.###"))
        table.cell(wtTbl, 5, 3, str.tostring(wI_equity,  "#.###"))
        table.cell(wtTbl, 5, 4, str.tostring(wI_crypto,  "#.###"))
        table.cell(wtTbl, 5, 5, str.tostring(wI_growth,  "#.###"))
        table.cell(wtTbl, 5, 6, str.tostring(wI_credit,  "#.###"))
        table.cell(wtTbl, 6, 1, str.tostring(w_risk_f,    "#.###"))
        table.cell(wtTbl, 6, 2, str.tostring(w_breadth_f, "#.###"))
        table.cell(wtTbl, 6, 3, str.tostring(w_equity_f,  "#.###"))
        table.cell(wtTbl, 6, 4, str.tostring(w_crypto_f,  "#.###"))
        table.cell(wtTbl, 6, 5, str.tostring(w_growth_f,  "#.###"))
        table.cell(wtTbl, 6, 6, str.tostring(w_credit_f,  "#.###"))
// ======================================================================
// RISK STATE DURATION STATS + CONDITIONAL GAUSSIAN SWING PROBABILITY
// ======================================================================
showDurationTable = input.bool(true, "Show Risk Duration Table?")
swingDuration     = input.int(21, "Defined Swing Duration", minval=1)
maxStoredDuration = input.int(500, "Max Stored Duration Filter", minval=20)

var int currentDuration = 0
var int prevState = na
var bool hasSeenFirstChange = false

var int[] onDurations  = array.new_int()
var int[] offDurations = array.new_int()

// Track duration
currentDuration := (na(prevState) or tradeON == (prevState == 1)) ? currentDuration + 1 : 1

// Detect state change
stateChanged = not na(prevState) and tradeON != (prevState == 1)

// Store completed durations
if stateChanged
    if hasSeenFirstChange
        completedDuration = currentDuration[1]
        if completedDuration <= maxStoredDuration
            if prevState == 1
                array.push(onDurations, completedDuration)
            else
                array.push(offDurations, completedDuration)
    hasSeenFirstChange := true

prevState := tradeON ? 1 : 0

// ======================================================================
// FUNCTION: compute stats
// ======================================================================
f_stats(arr) =>
    sz = array.size(arr)
    if sz == 0
        [na, na, na, na]
    else
        sum  = 0.0
        minv = array.get(arr, 0)
        maxv = array.get(arr, 0)
        for i = 0 to sz - 1
            v    = array.get(arr, i)
            sum += v
            minv := math.min(minv, v)
            maxv := math.max(maxv, v)
        avg    = sum / sz
        varSum = 0.0
        for i = 0 to sz - 1
            v       = array.get(arr, i)
            varSum += math.pow(v - avg, 2)
        sd = math.sqrt(varSum / sz)
        [avg, sd, minv, maxv]

// ======================================================================
// NORMAL CDF APPROXIMATION
// ======================================================================
f_norm_cdf(x) =>
    t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    d = 0.3989423 * math.exp(-x * x / 2.0)
    p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    x > 0 ? 1.0 - p : p

f_survival(x, avg, sd) =>
    na(avg) or na(sd) or sd <= 0 ? na :
     1.0 - f_norm_cdf((x - avg) / sd)

// ======================================================================
// FIXED: forward-looking conditional probability
// P(regime lasts swingDuration MORE bars | already lasted currentDuration)
// ======================================================================
f_conditional_full_swing_prob(avg, sd, currentDur, swingLen) =>
    if na(avg) or na(sd) or sd <= 0
        na
    else
        target      = float(currentDur + swingLen)
        survTarget  = f_survival(target,             avg, sd)
        survCurrent = f_survival(float(currentDur),  avg, sd)
        na(survTarget) or na(survCurrent) or survCurrent <= 0 ? na :
         survTarget / survCurrent

// ======================================================================
// COMPUTE STATS
// ======================================================================
[onAvg,  onSD,  onMin,  onMax]  = f_stats(onDurations)
[offAvg, offSD, offMin, offMax] = f_stats(offDurations)

activeAvg = tradeON ? onAvg : offAvg
activeSD  = tradeON ? onSD  : offSD

onSamples     = array.size(onDurations)
offSamples    = array.size(offDurations)
activeSamples = tradeON ? onSamples : offSamples

// Point estimate
probFullSwing = f_conditional_full_swing_prob(
     activeAvg, activeSD, currentDuration, swingDuration)

// Confidence interval using SE of mean
sampleSE = na(activeSD) or activeSamples <= 0 ? na :
           activeSD / math.sqrt(float(activeSamples))

// Pessimistic — avg shifted down by 1 SE
probLow  = na(sampleSE) ? na : f_conditional_full_swing_prob(
     activeAvg - sampleSE, activeSD, currentDuration, swingDuration)

// Optimistic — avg shifted up by 1 SE
probHigh = na(sampleSE) ? na : f_conditional_full_swing_prob(
     activeAvg + sampleSE, activeSD, currentDuration, swingDuration)

// Display as range when both bounds available, else point estimate
probText = na(probFullSwing) ? "NA" :
           na(probLow) or na(probHigh) ?
           str.tostring(probFullSwing * 100, "#.0") + "%" :
           str.tostring(math.max(probLow,  0) * 100, "#.0") + "–" +
           str.tostring(math.min(probHigh, 1) * 100, "#.0") + "%"

// Color based on point estimate
probColor = na(probFullSwing)      ? color.new(color.gray,   70) : probFullSwing >= 0.70  ? color.new(color.green,  30) :probFullSwing >= 0.45  ? color.new(color.yellow, 30) : color.new(color.red,    30)

// Reliability based on sample size — calibrated for 20-30 range
reliabilityText =
     activeSamples >= 30 ? "Adequate"     :
     activeSamples >= 20 ? "Marginal"     :
     activeSamples >= 10 ? "Low"          : "Insufficient"

reliabilityColor =
     activeSamples >= 30 ? color.new(color.green,  30) :
     activeSamples >= 20 ? color.new(color.yellow, 30) :
     activeSamples >= 10 ? color.new(color.orange, 30) :
                           color.new(color.red,    30)

currentStateText = tradeON ? "Risk ON" : "Risk OFF"

// ======================================================================
// TABLE 
// ======================================================================
var table durTbl = na

// Color scheme
bgHeader   = color.new(color.black, 0)
bgON       = color.new(color.green, 80)
bgOFF      = color.new(color.red,   80)
bgNeutral  = color.new(color.gray,  85)
bgHighlight= color.new(color.blue,  80)

txtWhite   = color.white
txtBlack   = color.black

if showDurationTable
    if barstate.isfirst
        durTbl := table.new(position.bottom_left, 5, 8, border_width=1)

        // Headers
        table.cell(durTbl, 0, 0, "State", bgcolor=bgHeader, text_color=txtWhite)
        table.cell(durTbl, 1, 0, "Avg",   bgcolor=bgHeader, text_color=txtWhite)
        table.cell(durTbl, 2, 0, "SD",    bgcolor=bgHeader, text_color=txtWhite)
        table.cell(durTbl, 3, 0, "Min",   bgcolor=bgHeader, text_color=txtWhite)
        table.cell(durTbl, 4, 0, "Max",   bgcolor=bgHeader, text_color=txtWhite)

        table.cell(durTbl, 0, 1, "Risk ON",  text_color=txtWhite)
        table.cell(durTbl, 0, 2, "Risk OFF", text_color=txtWhite)
        table.cell(durTbl, 0, 3, "Current",  text_color=txtWhite)
        table.cell(durTbl, 0, 4, "Swing Target", text_color=txtWhite)
        table.cell(durTbl, 0, 5, "Prob Next", text_color=txtWhite)
        table.cell(durTbl, 0, 6, "Reliability", text_color=txtWhite)
        table.cell(durTbl, 0, 7, "Samples", text_color=txtWhite)

    if barstate.islast
        // ======================
        // Risk ON
        // ======================
        table.cell(durTbl, 1, 1, na(onAvg) ? "NA" : str.tostring(onAvg, "#.0"),
            bgcolor=bgON, text_color=txtWhite)

        table.cell(durTbl, 2, 1, na(onSD) ? "NA" : str.tostring(onSD, "#.0"),
            bgcolor=bgON, text_color=txtWhite)

        table.cell(durTbl, 3, 1, na(onMin) ? "NA" : str.tostring(onMin),
            bgcolor=bgON, text_color=txtWhite)

        table.cell(durTbl, 4, 1, na(onMax) ? "NA" : str.tostring(onMax),
            bgcolor=bgON, text_color=txtWhite)

        // ======================
        // Risk OFF
        // ======================
        table.cell(durTbl, 1, 2, na(offAvg) ? "NA" : str.tostring(offAvg, "#.0"),
            bgcolor=bgOFF, text_color=txtWhite)

        table.cell(durTbl, 2, 2, na(offSD) ? "NA" : str.tostring(offSD, "#.0"),
            bgcolor=bgOFF, text_color=txtWhite)

        table.cell(durTbl, 3, 2, na(offMin) ? "NA" : str.tostring(offMin),
            bgcolor=bgOFF, text_color=txtWhite)

        table.cell(durTbl, 4, 2, na(offMax) ? "NA" : str.tostring(offMax),
            bgcolor=bgOFF, text_color=txtWhite)

        // ======================
        // Current state
        // ======================
        table.cell(durTbl, 1, 3, currentStateText,
            bgcolor=bgHighlight, text_color=txtWhite)

        table.cell(durTbl, 2, 3, str.tostring(currentDuration),
            bgcolor=tradeON ? color.new(color.green, 40) : color.new(color.red, 40),
            text_color=txtWhite)

        // ======================
        // Swing target
        // ======================
        table.cell(durTbl, 1, 4,
            str.tostring(currentDuration) + "+" +
            str.tostring(swingDuration) + "=" +
            str.tostring(currentDuration + swingDuration),
            bgcolor=bgNeutral, text_color=txtWhite)

        // ======================
        // Probability
        // ======================
        table.cell(durTbl, 1, 5, probText,
            bgcolor=probColor, text_color=txtWhite)

        // ======================
        // Reliability
        // ======================
        table.cell(durTbl, 1, 6, reliabilityText,
            bgcolor=reliabilityColor, text_color=txtWhite)

        table.cell(durTbl, 2, 6, "n=" + str.tostring(activeSamples),
            bgcolor=reliabilityColor, text_color=txtWhite)

        // ======================
        // Samples
        // ======================
        table.cell(durTbl, 1, 7, "ON: " + str.tostring(onSamples),
            bgcolor=bgON, text_color=txtWhite)

        table.cell(durTbl, 2, 7, "OFF: " + str.tostring(offSamples),
            bgcolor=bgOFF, text_color=txtWhite)
````
