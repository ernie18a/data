# BTC-Macro 3D Chart Dashboard 

- url: https://www.tradingview.com/script/WNyfsGNQ-BTC-Macro-3D-Chart-Dashboard/
- type: indicator
- pine_id: PUB;3aadc7e109984e309058b5e8f7bb3ec1
- version: 1.0

## Description

BTC-Macro 3D Chart Oscillator is a multi-factor Bitcoin cycle indicator that combines on-chain metrics (MVRV, NUPL, Puell, Stock-to-Flow), macro data (M2, ISM), and price-based models (Pi Cycle, log regression, volume momentum) into one normalized signal.

The oscillator is designed to identify high-probability accumulation and distribution zones across market cycles.

Yellow zones highlight accumulation phases (potential long-term buy areas)
Red zones indicate distribution / overheated conditions (increased risk)
The white line represents the composite macro signal, with increased thickness during extremes for better visibility

This tool is best used on higher timeframes (1D–1W) to track Bitcoin’s macro cycle structure rather than short-term trading noise.

## Source Code

````pine
//@version=5
indicator("BTC-Macro 3D Chart Oscillator (Clean PRO)", overlay=false, max_bars_back=1000)

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

price = close
vol   = volume

//────────────────────────────────────────────
// Z SCORE
//────────────────────────────────────────────
zscore(src, len) =>
    mean = ta.sma(src, len)
    dev  = ta.stdev(src, len)
    dev == 0 ? 0 : (src - mean) / dev

len = 200

//────────────────────────────────────────────
// CORE MODEL
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
// OSCILLATOR
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

smooth = ta.ema(osc, 10)

//────────────────────────────────────────────
// LEVELS
//────────────────────────────────────────────
mid = 0.0
cycleLen = 365

meanOsc = ta.sma(smooth, cycleLen)
stdOsc  = ta.stdev(smooth, cycleLen)

over  = meanOsc + 1.5 * stdOsc
under = meanOsc - 1.5 * stdOsc

//────────────────────────────────────────────
// ZONES
//────────────────────────────────────────────
accum_zone      = smooth < mid
overbought_zone = smooth > over
extreme         = accum_zone or overbought_zone

//────────────────────────────────────────────
// BACKGROUND
//────────────────────────────────────────────
bgcolor(accum_zone ? color.new(color.yellow, 85) :
       overbought_zone ? color.new(color.red, 85) : na)

//────────────────────────────────────────────
// BUY / SELL DOTS
//────────────────────────────────────────────
plotshape(accum_zone, title="BUY DOT", style=shape.circle, location=location.bottom, color=color.green, size=size.tiny)
plotshape(overbought_zone, title="SELL DOT", style=shape.circle, location=location.top, color=color.red, size=size.tiny)

//────────────────────────────────────────────
// DASHBOARD
//────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 4, frame_color=color.gray)

regime = accum_zone ? "ACCUMULATION" : overbought_zone ? "DISTRIBUTION" : "NEUTRAL"
regimeColor = accum_zone ? color.green : overbought_zone ? color.red : color.gray

cycleState = smooth < 0 ? "ACCUM (BUY ZONE)" : smooth > over ? "TOP RISK" : "MID CYCLE"

if bar_index % 5 == 0
    table.cell(dash, 0, 0, "BTC MACRO 3D OSC", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "", bgcolor=color.black)

    table.cell(dash, 0, 1, "OSC VALUE", text_color=color.white, bgcolor=color.new(color.blue, 70))
    table.cell(dash, 1, 1, str.tostring(smooth, "#.##"), text_color=color.white, bgcolor=color.new(color.blue, 70))

    table.cell(dash, 0, 2, "REGIME", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, regime, text_color=color.white, bgcolor=regimeColor)

    table.cell(dash, 0, 3, "CYCLE STATE", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, cycleState, text_color=color.white, bgcolor=color.new(color.gray, 60))

//────────────────────────────────────────────
// CLEAN OSCILLATOR (NO GLOW)
//────────────────────────────────────────────
plot(smooth, title="Oscillator", color=color.white, linewidth=2)

// thicker during extremes
plot(extreme ? smooth : na, title="Extreme Boost", color=color.white, linewidth=4)

// levels
plot(over,  title="Adaptive Overheated",  color=color.new(color.red, 30), linewidth=1)
plot(under, title="Adaptive Undervalued", color=color.new(color.green, 30), linewidth=1)
plot(mid,   title="Midline", color=color.gray)
````
