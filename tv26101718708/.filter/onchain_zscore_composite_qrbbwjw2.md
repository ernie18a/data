# On-Chain Z-Score Composite

- url: https://www.tradingview.com/script/qrBbwjW2/
- type: indicator
- pine_id: PUB;2268fca1763d4ce09bf7e2dcad4296f3
- version: 1.0

## Description

A structured on-chain regime model for Bitcoin. This indicator aggregates multiple fundamental data sources into a single smoothed Z-score and translates them into clear market states—without noise and without a neutral zone.

🔍 What this indicator does

This system normalizes four key on-chain metrics using Z-scores and combines them into a weighted composite:

NVT – valuation relative to network activity
MVRV – market value vs. realized value
AVIV (Realized Price Trend) – long-term price anchoring
SOPR – realized profit/loss behavior

Each component is:

normalized (Z-score)
smoothed (SMA/EMA)
weighted into the composite

Result: a consistent, comparable view of the overall market condition.

⚙️ Core logic
The composite is additionally smoothed (MA)
Two adjustable thresholds define the regime:
Long Threshold
Short Threshold
There is no neutral state

Instead:

Above Long Threshold → Bull regime
Below Short Threshold → Bear regime
In between → previous state persists (state memory)

This removes constant flipping and significantly reduces noise.

🎯 Why it matters

Typical Z-score indicators tend to generate false signals in sideways markets. This system addresses that by:

Using regime logic instead of signal flipping
Combining multiple independent data sources
Applying multi-layer smoothing
Maintaining persistent states instead of a neutral zone

The result is a much cleaner and more stable representation of market phases.

📊 How to use
Identify macro bull and bear regimes
Filter trade entries (only trade in the aligned regime)
Spot extreme conditions (overextended vs. undervalued)
Combine with technical setups for timing
⚙️ Settings

Each metric is fully configurable:

Z-score lookback
MA length & type (SMA / EMA)
Visibility toggle

Composite:

Individual weights per component
Overall smoothing (MA)
Thresholds (adjustable in 0.01 steps)
Visible threshold lines on the chart
⚠️ Notes
On-chain data is best suited for mid- to long-term analysis
This is not a standalone trading signal, but a context and regime tool
Data quality depends on external providers (Glassnode, CoinMetrics, etc.)
🧠 Bottom line

This is not just another oscillator—it’s a framework for understanding market structure.

Stop reacting to every move. Start identifying the regime you're in. That shift alone improves decision-making significantly.

## Source Code

````pine
//@version=5
indicator("On-Chain Z-Score Composite", shorttitle="On-Chain Z-Score composite", overlay=false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_ma(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

f_z(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s != 0 ? (src - m) / s : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mc_nvt = request.security("BCHAIN/MKTCP", "D", close)
tx_vol = request.security("GLASSNODE:BTC_TXS", "D", close)
nvt_raw = tx_vol != 0 ? mc_nvt / tx_vol : na

mc  = request.security("GLASSNODE:BTC_MARKETCAP", "D", close)
mcr = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
mvrv_raw = mcr != 0 ? mc / mcr : na

realCap = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
supply  = request.security("GLASSNODE:BTC_SUPPLY", "D", close)
realPrice = supply != 0 ? realCap / supply : na
aviv_raw = ta.ema(realPrice, 365)
aviv_ratio = aviv_raw != 0 ? close / aviv_raw : na

sopr_raw = request.security("GLASSNODE:BTC_SOPR", "D", close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NVT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group_nvt = "NVT"

nvt_zLen   = input.int(97, "Z Lookback", group=group_nvt)
nvt_maLen  = input.int(7, "MA Length", group=group_nvt)
nvt_maType = input.string("EMA", "MA Type", options=["SMA","EMA"], group=group_nvt)
show_nvt   = input.bool(true, "Show", group=group_nvt)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MVRV SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group_mvrv = "MVRV"

mvrv_zLen   = input.int(168, "Z Lookback", group=group_mvrv)
mvrv_maLen  = input.int(1, "MA Length", group=group_mvrv)
mvrv_maType = input.string("EMA", "MA Type", options=["SMA","EMA"], group=group_mvrv)
show_mvrv   = input.bool(true, "Show", group=group_mvrv)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AVIV SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group_aviv = "AVIV"

aviv_zLen   = input.int(130, "Z Lookback", group=group_aviv)
aviv_maLen  = input.int(1, "MA Length", group=group_aviv)
aviv_maType = input.string("EMA", "MA Type", options=["SMA","EMA"], group=group_aviv)
show_aviv   = input.bool(true, "Show", group=group_aviv)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOPR SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group_sopr = "SOPR"

sopr_zLen   = input.int(150, "Z Lookback", group=group_sopr)
sopr_maLen  = input.int(8, "MA Length", group=group_sopr)
sopr_maType = input.string("EMA", "MA Type", options=["SMA","EMA"], group=group_sopr)
show_sopr   = input.bool(true, "Show", group=group_sopr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPOSITE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group_comp = "COMPOSITE"

show_comp = input.bool(true, "Show Composite", group=group_comp)

w_nvt  = input.float(1, "NVT Weight", group=group_comp)
w_mvrv = input.float(1, "MVRV Weight", group=group_comp)
w_aviv = input.float(1, "AVIV Weight", group=group_comp)
w_sopr = input.float(1, "SOPR Weight", group=group_comp)

comp_maType = input.string("SMA", "MA Type", options=["SMA","EMA"], group=group_comp)
comp_maLen  = input.int(3, "MA Length", group=group_comp)

longTh  = input.float(0, "Long Threshold", group=group_comp, step=0.01)
shortTh = input.float(0, "Short Threshold", group=group_comp, step=0.01)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
z_nvt  = f_z(nvt_raw, nvt_zLen)
z_mvrv = f_z(mvrv_raw, mvrv_zLen)
z_aviv = f_z(aviv_ratio, aviv_zLen)
z_sopr = f_z(sopr_raw, sopr_zLen)

nvt_s  = f_ma(z_nvt,  nvt_maLen,  nvt_maType)
mvrv_s = f_ma(z_mvrv, mvrv_maLen, mvrv_maType)
aviv_s = f_ma(z_aviv, aviv_maLen, aviv_maType)
sopr_s = f_ma(z_sopr, sopr_maLen, sopr_maType)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPOSITE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sum = 0.0
cnt = 0.0

sum += nvt_s  * w_nvt
sum += mvrv_s * w_mvrv
sum += aviv_s * w_aviv
sum += sopr_s * w_sopr

cnt := w_nvt + w_mvrv + w_aviv + w_sopr

comp = cnt != 0 ? sum / cnt : na
comp_ma = f_ma(comp, comp_maLen, comp_maType)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE (PERSISTENT, NO NEUTRAL)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int state = 0

state := comp_ma > longTh ? 1 :
         comp_ma < shortTh ? -1 :
         state

compColor = state == 1 ? color.green : color.red

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THRESHOLD LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hline(longTh,  "Long Threshold",  color=color.green, linestyle=hline.style_dashed)
hline(shortTh, "Short Threshold", color=color.red,  linestyle=hline.style_dashed)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(show_nvt  ? nvt_s  : na, "NVT", color=color.yellow)
plot(show_mvrv ? mvrv_s : na, "MVRV", color=color.blue)
plot(show_aviv ? aviv_s : na, "AVIV", color=color.orange)
plot(show_sopr ? sopr_s : na, "SOPR", color=color.purple)

plot(show_comp ? comp_ma : na, "COMPOSITE", color=compColor, linewidth=2)
````
