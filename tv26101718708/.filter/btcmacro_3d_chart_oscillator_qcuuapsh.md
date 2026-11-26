# BTC-Macro 3D chart Oscillator

- url: https://www.tradingview.com/script/QcuuaPsh-BTC-Macro-3D-chart-Oscillator/
- type: indicator
- pine_id: PUB;4930e41660d04fffa04a9bfe05680013
- version: 1.0

## Description

Super easy to find tops and lows  , buy zones and sell zones . super easy to use

## Source Code

````pine
//@version=5
indicator("BTC Macro Composite Oscillator (FINAL CLEAN LABELS)", overlay=false, max_bars_back=1000)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
mvrv     = input.source(close, "MVRV (external)")
nupl     = input.source(close, "NUPL (external)")
puell    = input.source(close, "Puell Multiple (external)")
s2f      = input.source(close, "Stock-to-Flow (external)")
riskwave = input.source(close, "Risk Wave BTC (external)")

m2       = input.source(close, "M2 Supply")
ism      = input.source(close, "ISM/PMI")

price    = close
vol      = volume

//────────────────────────────────────────────
// Z-SCORE FUNCTION
//────────────────────────────────────────────
zscore(src, len) =>
    mean = ta.sma(src, len)
    dev  = ta.stdev(src, len)
    dev == 0 ? 0 : (src - mean) / dev

len = input.int(200, "Normalization Length")

//────────────────────────────────────────────
// CORE MODELS
//────────────────────────────────────────────
ma111 = ta.sma(price, 111)
ma350 = ta.sma(price, 350)
pi_cycle = (ma111 * 2) / ma350 - 1

log_price  = math.log(price)
regression = ta.linreg(log_price, 200, 0)
log_dev    = log_price - regression

btc_m2  = price / m2
vol_mom = ta.roc(vol, 20)

//────────────────────────────────────────────
// NORMALIZATION
//────────────────────────────────────────────
n_pi     = zscore(pi_cycle, len)
n_mvrv   = zscore(mvrv, len)
n_nupl   = zscore(nupl, len)
n_puell  = zscore(puell, len)
n_s2f    = zscore(s2f, len)
n_risk   = zscore(riskwave, len)
n_logdev = zscore(log_dev, len)
n_btm2   = zscore(btc_m2, len)
n_ism    = zscore(ism, len)
n_vol    = zscore(vol_mom, len)

//────────────────────────────────────────────
// COMPOSITE OSCILLATOR
//────────────────────────────────────────────
osc =
     (n_pi     * 0.15) +
     (n_mvrv   * 0.15) +
     (n_nupl   * 0.10) +
     (n_puell  * 0.10) +
     (n_s2f    * 0.10) +
     (n_risk   * 0.10) +
     (n_logdev * 0.10) +
     (n_btm2   * 0.10) +
     (n_ism    * 0.05) +
     (n_vol    * 0.05)

// smoothing
smooth = ta.ema(osc, 10)

//────────────────────────────────────────────
// LEVELS
//────────────────────────────────────────────
mid = 0.0

cycleLen = input.int(365, "Cycle Adaptation Length")

meanOsc = ta.sma(smooth, cycleLen)
stdOsc  = ta.stdev(smooth, cycleLen)

over  = meanOsc + 1.5 * stdOsc
under = meanOsc - 1.5 * stdOsc

//────────────────────────────────────────────
// ZONES
//────────────────────────────────────────────
accum_zone      = smooth < mid
overbought_zone = smooth > over

//────────────────────────────────────────────
// BACKGROUND
//────────────────────────────────────────────
bgcolor(accum_zone ? color.new(color.yellow, 85) : overbought_zone ? color.new(color.red, 85) : na)

//────────────────────────────────────────────
// SMALL LABELS (UPDATED)
//────────────────────────────────────────────
var label accumLabel = na
var label distLabel  = na

if accum_zone
    label.delete(accumLabel)
    accumLabel := label.new(bar_index, smooth, "ACUM",
         style=label.style_label_up,
         textcolor=color.black,
         color=color.yellow,
         size=size.tiny)

if overbought_zone
    label.delete(distLabel)
    distLabel := label.new(bar_index, smooth, "DIST",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.red,
         size=size.tiny)

//────────────────────────────────────────────
// PLOTS
//────────────────────────────────────────────
plot(smooth, title="Composite Oscillator", linewidth=2, color=color.blue)

plot(over,  title="Adaptive Overheated",  color=color.new(color.red, 30), linewidth=1)
plot(under, title="Adaptive Undervalued", color=color.new(color.green, 30), linewidth=1)
plot(mid,   title="Midline", color=color.gray)
````
