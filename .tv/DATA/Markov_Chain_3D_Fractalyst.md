<!-- tradingview-pine-id: PUB;18a19d3c9ff249d3bdfb868a45234b57 -->
<!-- tradingviewscripts-format: 1 -->
# Markov Chain [3D] | Fractalyst

Source: https://www.tradingview.com/script/yA0KOPDO-Markov-Chain-3D-Fractalyst/

## Description

What exactly is a Markov Chain?

This indicator uses a Markov Chain model to analyze, quantify, and visualize the transitions between market regimes (Bull, Bear, Neutral) on your chart. It dynamically detects these regimes in real-time, calculates transition probabilities, and displays them as animated 3D spheres and arrows, giving traders intuitive insight into current and future market conditions.

https://www.tradingview.com/x/PDQNzeZR/

How does a Markov Chain work, and how should I read this spheres-and-arrows diagram?

Think of three weather modes: Sunny, Rainy, Cloudy. 

Each sphere is one mode. The loop on a sphere means “stay the same next step” (e.g., Sunny again tomorrow).

The arrows leaving a sphere show where things usually go next if they change (e.g., Sunny moving to Cloudy).

Some paths matter more than others. A more prominent loop means the current mode tends to persist. A more prominent outgoing arrow means a change to that destination is the usual next step.

Direction isn’t symmetric: moving Sunny→Cloudy can behave differently than Cloudy→Sunny.

Now relabel the spheres to markets: Bull, Bear, Neutral.

Spheres: market regimes (uptrend, downtrend, range).

Self‑loop: tendency for the current regime to continue on the next bar.

Arrows: the most common next regime if a switch happens.

How to read: Start at the sphere that matches current bar state. If the loop stands out, expect continuation. If one outgoing path stands out, that switch is the typical next step. Opposite directions can differ (Bear→Neutral doesn’t have to match Neutral→Bear).

https://www.tradingview.com/x/VwzFu0wv/

What states and transitions are shown?

The three market states visualized are:

Bullish (Bull): Upward or strong-market regime.

Bearish (Bear): Downward or weak-market regime.

Neutral: Sideways or range-bound regime.

Bidirectional animated arrows and probability labels show how likely the market is to move from one regime to another (e.g., Bull → Bear or Neutral → Bull).

https://www.tradingview.com/x/pJJ9w0gI/

How does the regime detection system work?

You can use either built-in price returns (based on adaptive Z-score normalization) or supply three custom indicators (such as volume, oscillators, etc.).

Values are statistically normalized (Z-scored) over a configurable lookback period.

The normalized outputs are classified into Bull, Bear, or Neutral zones.

If using three indicators, their regime signals are averaged and smoothed for robustness.

https://www.tradingview.com/x/zHHxJCTr/

How are transition probabilities calculated?

On every confirmed bar, the algorithm tracks the sequence of detected market states, then builds a rolling window of transitions.

The code maintains a transition count matrix for all regime pairs (e.g., Bull → Bear).

Transition probabilities are extracted for each possible state change using Laplace smoothing for numerical stability, and frequently updated in real-time.

https://www.tradingview.com/x/JxYxuoFG/

What is unique about the visualization?

3D animated spheres represent each regime and change visually when active.

Animated, bidirectional arrows reveal transition probabilities and allow you to see both dominant and less likely regime flows.

Particles (moving dots) animate along the arrows, enhancing the perception of regime flow direction and speed.

All elements dynamically update with each new price bar, providing a live market map in an intuitive, engaging format.

https://www.tradingview.com/x/6SnzUfnP/

Can I use custom indicators for regime classification?

Yes! Enable the "Custom Indicators" switch and select any three chart series as inputs. These will be normalized and combined (each with equal weight), broadening the regime classification beyond just price-based movement.

https://www.tradingview.com/x/7kmcnVEF/

What does the “Lookback Period” control?

Lookback Period (default: 100) sets how much historical data builds the probability matrix. Shorter periods adapt faster to regime changes but may be noisier. Longer periods are more stable but slower to adapt.

How is this different from a Hidden Markov Model (HMM)?

It sets the window for both regime detection and probability calculations. Lower values make the system more reactive, but potentially noisier. Higher values smooth estimates and make the system more robust.

https://www.tradingview.com/x/XHVqZgCu/

How is this Markov Chain different from a Hidden Markov Model (HMM)?

Markov Chain (as here): All market regimes (Bull, Bear, Neutral) are directly observable on the chart. The transition matrix is built from actual detected regimes, keeping the model simple and interpretable.

Hidden Markov Model: The actual regimes are unobservable ("hidden") and must be inferred from market output or indicator "emissions" using statistical learning algorithms. HMMs are more complex, can capture more subtle structure, but are harder to visualize and require additional machine learning steps for training.

https://www.tradingview.com/x/nNdmf6so/

A standard Markov Chain models transitions between observable states using a simple transition matrix, while a Hidden Markov Model assumes the true states are hidden (latent) and must be inferred from observable “emissions” like price or volume data. In practical terms, a Markov Chain is transparent and easier to implement and interpret; an HMM is more expressive but requires statistical inference to estimate hidden states from data.

Markov Chain: states are observable; you directly count or estimate transition probabilities between visible states. This makes it simpler, faster, and easier to validate and tune.

HMM: states are hidden; you only observe emissions generated by those latent states. Learning involves machine learning/statistical algorithms (commonly Baum–Welch/EM for training and Viterbi for decoding) to infer both the transition dynamics and the most likely hidden state sequence from data.

https://www.tradingview.com/x/782mA5Pz/

 How does the indicator avoid “repainting” or look-ahead bias?

All regime changes and matrix updates happen only on confirmed (closed) bars, so no future data is leaked, ensuring reliable real-time operation.

Are there practical tuning tips?

Tune the Lookback Period for your asset/timeframe: shorter for fast markets, longer for stability.

Use custom indicators if your asset has unique regime drivers.

Watch for rapid changes in transition probabilities as early warning of a possible regime shift.

https://www.tradingview.com/x/1kATaZ1K/

Who is this indicator for?

Quants and quantitative researchers exploring probabilistic market modeling, especially those interested in regime-switching dynamics and Markov models.

Programmers and system developers who need a probabilistic regime filter for systematic and algorithmic backtesting:

The Markov Chain [3D] indicator is ideally suited for programmatic integration via its bias output (1 = Bull, 0 = Neutral, -1 = Bear).

Although the visualization is engaging, the core output is designed for automated, rules-based workflows—not for discretionary/manual trading decisions.

Developers can connect the indicator’s output directly to their Pine Script logic (using input.source()), allowing rapid and robust backtesting of regime-based strategies.

It acts as a plug-and-play regime filter: simply plug the bias output into your entry/exit logic, and you have a scientifically robust, probabilistically-derived signal for filtering, timing, position sizing, or risk regimes.

The MC's output is intentionally "trinary" (1/0/-1), focusing on clear regime states for unambiguous decision-making in code. If you require nuanced, multi-probability or soft-label state vectors, consider expanding the indicator or stacking it with a probability-weighted logic layer in your scripting.

Because it avoids subjectivity, this approach is optimal for systematic quants, algo developers building backtested, repeatable strategies based on probabilistic regime analysis.

https://www.tradingview.com/x/3akjTYDN/

What's the mathematical foundation behind this?

The mathematical foundation behind this Markov Chain indicator—and probabilistic regime detection in finance—draws from two principal models: the (standard) Markov Chain and the Hidden Markov Model (HMM).

https://www.tradingview.com/x/OqFObOTz/

How to use this indicator programmatically?

The Markov Chain [3D] indicator automatically exports a bias value (+1 for Bullish, -1 for Bearish, 0 for Neutral) as a plot visible in the Data Window. This allows you to integrate its regime signal into your own scripts and strategies for backtesting, automation, or live trading.

Step-by-Step Integration with Pine Script (input.source)

Add the Markov Chain indicator to your chart.
This must be done first, since your custom script will "pull" the bias signal from the indicator's plot.

In your strategy, create an input using input.source()
Example:

[pine]//@version=5
strategy("MC Bias Strategy Example")

mcBias = input.source(close, "MC Bias Source")
[/pine]

After saving, go to your script’s settings. For the “MC Bias Source” input, select the plot/output of the Markov Chain indicator (typically its bias plot).

Use the bias in your trading logic
Example (long only on Bull, flat otherwise):
[pine]if mcBias == 1
    strategy.entry("Long", strategy.long)
else
    strategy.close("Long")
[/pine]

For more advanced workflows, combine mcBias with additional filters or trailing stops.

How does this work behind-the-scenes?

TradingView’s input.source() lets you use any plot from another indicator as a real-time, “live” data feed in your own script (source).

The selected bias signal is available to your Pine code as a variable, enabling logical decisions based on regime (trend-following, mean-reversion, etc.).

This enables powerful strategy modularity: decouple regime detection from entry/exit logic, allowing fast experimentation without rewriting core signal code.

Integrating 45+ Indicators with Your Markov Chain — How & Why

The Enhanced Custom Indicators Export script exports a massive suite of over 45 technical indicators—ranging from classic momentum (RSI, MACD, Stochastic, etc.) to trend, volume, volatility, and oscillator tools—all pre-calculated, centered/scaled, and available as plots.

[pine]// Enhanced Custom Indicators Export - 45 Technical Indicators
// Comprehensive technical analysis suite for advanced market regime detection
//@version=6
indicator('Enhanced Custom Indicators Export | Fractalyst', shorttitle='Enhanced CI Export', overlay=false, scale=scale.right, max_labels_count=500, max_lines_count=500)

// |----- Input Parameters -----| //
momentum_group = "Momentum Indicators"
trend_group = "Trend Indicators"
volume_group = "Volume Indicators"
volatility_group = "Volatility Indicators"
oscillator_group = "Oscillator Indicators"
display_group = "Display Settings"

// Common lengths
length_14 = input.int(14, "Standard Length (14)", minval=1, maxval=100, group=momentum_group)
length_20 = input.int(20, "Medium Length (20)", minval=1, maxval=200, group=trend_group)
length_50 = input.int(50, "Long Length (50)", minval=1, maxval=200, group=trend_group)

// Display options
show_table = input.bool(true, "Show Values Table", group=display_group)
table_size = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal"], group=display_group)

// |----- MOMENTUM INDICATORS (15 indicators) -----| //

// 1. RSI (Relative Strength Index)
rsi_14 = ta.rsi(close, length_14)
rsi_centered = rsi_14 - 50

// 2. Stochastic Oscillator
stoch_k = ta.stoch(close, high, low, length_14)
stoch_d = ta.sma(stoch_k, 3)
stoch_centered = stoch_k - 50

// 3. Williams %R
williams_r = ta.stoch(close, high, low, length_14) - 100

// 4. MACD (Moving Average Convergence Divergence)
[macd_line, macd_signal, macd_histogram] = ta.macd(close, 12, 26, 9)

// 5. Momentum (Rate of Change)
momentum = ta.mom(close, length_14)
momentum_pct = (momentum / close[length_14]) * 100

// 6. Rate of Change (ROC)
roc = ta.roc(close, length_14)

// 7. Commodity Channel Index (CCI)
cci = ta.cci(close, length_20)

// 8. Money Flow Index (MFI)
mfi = ta.mfi(close, length_14)
mfi_centered = mfi - 50

// 9. Awesome Oscillator (AO)
ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)

// 10. Accelerator Oscillator (AC)
ac = ao - ta.sma(ao, 5)

// 11. Chande Momentum Oscillator (CMO)
cmo = ta.cmo(close, length_14)

// 12. Detrended Price Oscillator (DPO)
dpo = close - ta.sma(close, length_20)[math.floor(length_20/2) + 1]

// 13. Price Oscillator (PPO)
ppo = ta.sma(close, 12) - ta.sma(close, 26)
ppo_pct = (ppo / ta.sma(close, 26)) * 100

// 14. TRIX
trix_ema1 = ta.ema(close, length_14)
trix_ema2 = ta.ema(trix_ema1, length_14)
trix_ema3 = ta.ema(trix_ema2, length_14)
trix = ta.roc(trix_ema3, 1) * 10000

// 15. Klinger Oscillator
klinger = ta.ema(volume * (high + low + close) / 3, 34) - ta.ema(volume * (high + low + close) / 3, 55)

// 16. Fisher Transform
fisher_hl2 = 0.5 * (hl2 - ta.lowest(hl2, 10)) / (ta.highest(hl2, 10) - ta.lowest(hl2, 10)) - 0.25
fisher = 0.5 * math.log((1 + fisher_hl2) / (1 - fisher_hl2))

// 17. Stochastic RSI
stoch_rsi = ta.stoch(rsi_14, rsi_14, rsi_14, length_14)
stoch_rsi_centered = stoch_rsi - 50

// 18. Relative Vigor Index (RVI)
rvi_num = ta.swma(close - open)
rvi_den = ta.swma(high - low)
rvi = rvi_den != 0 ? rvi_num / rvi_den : 0

// 19. Balance of Power (BOP)
bop = (close - open) / (high - low)

// |----- TREND INDICATORS (10 indicators) -----| //

// 20. Simple Moving Average Momentum
sma_20 = ta.sma(close, length_20)
sma_momentum = ((close - sma_20) / sma_20) * 100

// 21. Exponential Moving Average Momentum
ema_20 = ta.ema(close, length_20)
ema_momentum = ((close - ema_20) / ema_20) * 100

// 22. Parabolic SAR
sar = ta.sar(0.02, 0.02, 0.2)
sar_trend = close > sar ? 1 : -1

// 23. Linear Regression Slope
lr_slope = ta.linreg(close, length_20, 0) - ta.linreg(close, length_20, 1)

// 24. Moving Average Convergence (MAC)
mac = ta.sma(close, 10) - ta.sma(close, 30)

// 25. Trend Intensity Index (TII)
tii_sum = 0.0
for i = 1 to length_20
    tii_sum += close > close ? 1 : 0
tii = (tii_sum / length_20) * 100

// 26. Ichimoku Cloud Components
ichimoku_tenkan = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
ichimoku_kijun = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
ichimoku_signal = ichimoku_tenkan > ichimoku_kijun ? 1 : -1

// 27. MESA Adaptive Moving Average (MAMA)
mama_alpha = 2.0 / (length_20 + 1)
mama = ta.ema(close, length_20)
mama_momentum = ((close - mama) / mama) * 100

// 28. Zero Lag Exponential Moving Average (ZLEMA)
zlema_lag = math.round((length_20 - 1) / 2)
zlema_data = close + (close - close[zlema_lag])
zlema = ta.ema(zlema_data, length_20)
zlema_momentum = ((close - zlema) / zlema) * 100

// |----- VOLUME INDICATORS (6 indicators) -----| //

// 29. On-Balance Volume (OBV)
obv = ta.obv

// 30. Volume Rate of Change (VROC)
vroc = ta.roc(volume, length_14)

// 31. Price Volume Trend (PVT)
pvt = ta.pvt

// 32. Negative Volume Index (NVI)
nvi = 0.0
nvi := volume < volume[1] ? nvi[1] + ((close - close[1]) / close[1]) * nvi[1] : nvi[1]

// 33. Positive Volume Index (PVI)
pvi = 0.0
pvi := volume > volume[1] ? pvi[1] + ((close - close[1]) / close[1]) * pvi[1] : pvi[1]

// 34. Volume Oscillator
vol_osc = ta.sma(volume, 5) - ta.sma(volume, 10)

// 35. Ease of Movement (EOM)
eom_distance = high - low
eom_box_height = volume / 1000000
eom = eom_box_height != 0 ? eom_distance / eom_box_height : 0
eom_sma = ta.sma(eom, length_14)

// 36. Force Index
force_index = volume * (close - close[1])
force_index_sma = ta.sma(force_index, length_14)

// |----- VOLATILITY INDICATORS (10 indicators) -----| //

// 37. Average True Range (ATR)
atr = ta.atr(length_14)
atr_pct = (atr / close) * 100

// 38. Bollinger Bands Position
bb_basis = ta.sma(close, length_20)
bb_dev = 2.0 * ta.stdev(close, length_20)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
bb_position = bb_dev != 0 ? (close - bb_basis) / bb_dev : 0
bb_width = bb_dev != 0 ? (bb_upper - bb_lower) / bb_basis * 100 : 0

// 39. Keltner Channels Position
kc_basis = ta.ema(close, length_20)
kc_range = ta.ema(ta.tr, length_20)
kc_upper = kc_basis + (2.0 * kc_range)
kc_lower = kc_basis - (2.0 * kc_range)
kc_position = kc_range != 0 ? (close - kc_basis) / kc_range : 0

// 40. Donchian Channels Position
dc_upper = ta.highest(high, length_20)
dc_lower = ta.lowest(low, length_20)
dc_basis = (dc_upper + dc_lower) / 2
dc_position = (dc_upper - dc_lower) != 0 ? (close - dc_basis) / (dc_upper - dc_lower) : 0

// 41. Standard Deviation
std_dev = ta.stdev(close, length_20)
std_dev_pct = (std_dev / close) * 100

// 42. Relative Volatility Index (RVI)
rvi_up = ta.stdev(close > close[1] ? close : 0, length_14)
rvi_down = ta.stdev(close < close[1] ? close : 0, length_14)
rvi_total = rvi_up + rvi_down
rvi_volatility = rvi_total != 0 ? (rvi_up / rvi_total) * 100 : 50

// 43. Historical Volatility
hv_returns = math.log(close / close[1])
hv = ta.stdev(hv_returns, length_20) * math.sqrt(252) * 100

// 44. Garman-Klass Volatility
gk_vol = math.log(high/low) * math.log(high/low) - (2*math.log(2)-1) * math.log(close/open) * math.log(close/open)
gk_volatility = math.sqrt(ta.sma(gk_vol, length_20)) * 100

// 45. Parkinson Volatility
park_vol = math.log(high/low) * math.log(high/low)
parkinson = math.sqrt(ta.sma(park_vol, length_20) / (4 * math.log(2))) * 100

// 46. Rogers-Satchell Volatility
rs_vol = math.log(high/close) * math.log(high/open) + math.log(low/close) * math.log(low/open)
rogers_satchell = math.sqrt(ta.sma(rs_vol, length_20)) * 100

// |----- OSCILLATOR INDICATORS (5 indicators) -----| //

// 47. Elder Ray Index
elder_bull = high - ta.ema(close, 13)
elder_bear = low - ta.ema(close, 13)
elder_power = elder_bull + elder_bear

// 48. Schaff Trend Cycle (STC)
stc_macd = ta.ema(close, 23) - ta.ema(close, 50)
stc_k = ta.stoch(stc_macd, stc_macd, stc_macd, 10)
stc_d = ta.ema(stc_k, 3)
stc = ta.stoch(stc_d, stc_d, stc_d, 10)

// 49. Coppock Curve
coppock_roc1 = ta.roc(close, 14)
coppock_roc2 = ta.roc(close, 11)
coppock = ta.wma(coppock_roc1 + coppock_roc2, 10)

// 50. Know Sure Thing (KST)
kst_roc1 = ta.roc(close, 10)
kst_roc2 = ta.roc(close, 15)
kst_roc3 = ta.roc(close, 20)
kst_roc4 = ta.roc(close, 30)
kst = ta.sma(kst_roc1, 10) + 2*ta.sma(kst_roc2, 10) + 3*ta.sma(kst_roc3, 10) + 4*ta.sma(kst_roc4, 15)

// 51. Percentage Price Oscillator (PPO)
ppo_line = ((ta.ema(close, 12) - ta.ema(close, 26)) / ta.ema(close, 26)) * 100
ppo_signal = ta.ema(ppo_line, 9)
ppo_histogram = ppo_line - ppo_signal

// |----- PLOT MAIN INDICATORS -----| //

// Plot key momentum indicators
plot(rsi_centered, title="01_RSI_Centered", color=color.purple, linewidth=1)
plot(stoch_centered, title="02_Stoch_Centered", color=color.blue, linewidth=1)
plot(williams_r, title="03_Williams_R", color=color.red, linewidth=1)
plot(macd_histogram, title="04_MACD_Histogram", color=color.orange, linewidth=1)
plot(cci, title="05_CCI", color=color.green, linewidth=1)

// Plot trend indicators
plot(sma_momentum, title="06_SMA_Momentum", color=color.navy, linewidth=1)
plot(ema_momentum, title="07_EMA_Momentum", color=color.maroon, linewidth=1)
plot(sar_trend, title="08_SAR_Trend", color=color.teal, linewidth=1)
plot(lr_slope, title="09_LR_Slope", color=color.lime, linewidth=1)
plot(mac, title="10_MAC", color=color.fuchsia, linewidth=1)

// Plot volatility indicators
plot(atr_pct, title="11_ATR_Pct", color=color.yellow, linewidth=1)
plot(bb_position, title="12_BB_Position", color=color.aqua, linewidth=1)
plot(kc_position, title="13_KC_Position", color=color.olive, linewidth=1)
plot(std_dev_pct, title="14_StdDev_Pct", color=color.silver, linewidth=1)
plot(bb_width, title="15_BB_Width", color=color.gray, linewidth=1)

// Plot volume indicators
plot(vroc, title="16_VROC", color=color.blue, linewidth=1)
plot(eom_sma, title="17_EOM", color=color.red, linewidth=1)
plot(vol_osc, title="18_Vol_Osc", color=color.green, linewidth=1)
plot(force_index_sma, title="19_Force_Index", color=color.orange, linewidth=1)
plot(obv, title="20_OBV", color=color.purple, linewidth=1)

// Plot additional oscillators
plot(ao, title="21_Awesome_Osc", color=color.navy, linewidth=1)
plot(cmo, title="22_CMO", color=color.maroon, linewidth=1)
plot(dpo, title="23_DPO", color=color.teal, linewidth=1)
plot(trix, title="24_TRIX", color=color.lime, linewidth=1)
plot(fisher, title="25_Fisher", color=color.fuchsia, linewidth=1)

// Plot more momentum indicators
plot(mfi_centered, title="26_MFI_Centered", color=color.yellow, linewidth=1)
plot(ac, title="27_AC", color=color.aqua, linewidth=1)
plot(ppo_pct, title="28_PPO_Pct", color=color.olive, linewidth=1)
plot(stoch_rsi_centered, title="29_StochRSI_Centered", color=color.silver, linewidth=1)
plot(klinger, title="30_Klinger", color=color.gray, linewidth=1)

// Plot trend continuation
plot(tii, title="31_TII", color=color.blue, linewidth=1)
plot(ichimoku_signal, title="32_Ichimoku_Signal", color=color.red, linewidth=1)
plot(mama_momentum, title="33_MAMA_Momentum", color=color.green, linewidth=1)
plot(zlema_momentum, title="34_ZLEMA_Momentum", color=color.orange, linewidth=1)
plot(bop, title="35_BOP", color=color.purple, linewidth=1)

// Plot volume continuation
plot(nvi, title="36_NVI", color=color.navy, linewidth=1)
plot(pvi, title="37_PVI", color=color.maroon, linewidth=1)
plot(momentum_pct, title="38_Momentum_Pct", color=color.teal, linewidth=1)
plot(roc, title="39_ROC", color=color.lime, linewidth=1)
plot(rvi, title="40_RVI", color=color.fuchsia, linewidth=1)

// Plot volatility continuation
plot(dc_position, title="41_DC_Position", color=color.yellow, linewidth=1)
plot(rvi_volatility, title="42_RVI_Volatility", color=color.aqua, linewidth=1)
plot(hv, title="43_Historical_Vol", color=color.olive, linewidth=1)
plot(gk_volatility, title="44_GK_Volatility", color=color.silver, linewidth=1)
plot(parkinson, title="45_Parkinson_Vol", color=color.gray, linewidth=1)

// Plot final oscillators
plot(rogers_satchell, title="46_RS_Volatility", color=color.blue, linewidth=1)
plot(elder_power, title="47_Elder_Power", color=color.red, linewidth=1)
plot(stc, title="48_STC", color=color.green, linewidth=1)
plot(coppock, title="49_Coppock", color=color.orange, linewidth=1)
plot(kst, title="50_KST", color=color.purple, linewidth=1)

// Plot final indicators
plot(ppo_histogram, title="51_PPO_Histogram", color=color.navy, linewidth=1)
plot(pvt, title="52_PVT", color=color.maroon, linewidth=1)

// |----- Reference Lines -----| //
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed, linewidth=1)
hline(50, "Midline", color=color.gray, linestyle=hline.style_dotted, linewidth=1)
hline(-50, "Lower Midline", color=color.gray, linestyle=hline.style_dotted, linewidth=1)
hline(25, "Upper Threshold", color=color.gray, linestyle=hline.style_dotted, linewidth=1)
hline(-25, "Lower Threshold", color=color.gray, linestyle=hline.style_dotted, linewidth=1)

// |----- Enhanced Information Table -----| //
if show_table and barstate.islast
    table_position = position.top_right
    table_text_size = table_size == "Tiny" ? size.tiny : table_size == "Small" ? size.small : size.normal
    
    var table info_table = table.new(table_position, 3, 18, bgcolor=color.new(color.white, 85), border_width=1, border_color=color.gray)
    
    // Headers
    table.cell(info_table, 0, 0, 'Category', text_color=color.black, text_size=table_text_size, bgcolor=color.new(color.blue, 70))
    table.cell(info_table, 1, 0, 'Indicator', text_color=color.black, text_size=table_text_size, bgcolor=color.new(color.blue, 70))
    table.cell(info_table, 2, 0, 'Value', text_color=color.black, text_size=table_text_size, bgcolor=color.new(color.blue, 70))
    
    // Key Momentum Indicators
    table.cell(info_table, 0, 1, 'MOMENTUM', text_color=color.purple, text_size=table_text_size, bgcolor=color.new(color.purple, 90))
    table.cell(info_table, 1, 1, 'RSI Centered', text_color=color.purple, text_size=table_text_size)
    table.cell(info_table, 2, 1, str.tostring(rsi_centered, '0.00'), text_color=color.purple, text_size=table_text_size)
    
    table.cell(info_table, 0, 2, '', text_color=color.blue, text_size=table_text_size)
    table.cell(info_table, 1, 2, 'Stoch Centered', text_color=color.blue, text_size=table_text_size)
    table.cell(info_table, 2, 2, str.tostring(stoch_centered, '0.00'), text_color=color.blue, text_size=table_text_size)
    
    table.cell(info_table, 0, 3, '', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 1, 3, 'Williams %R', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 2, 3, str.tostring(williams_r, '0.00'), text_color=color.red, text_size=table_text_size)
    
    table.cell(info_table, 0, 4, '', text_color=color.orange, text_size=table_text_size)
    table.cell(info_table, 1, 4, 'MACD Histogram', text_color=color.orange, text_size=table_text_size)
    table.cell(info_table, 2, 4, str.tostring(macd_histogram, '0.000'), text_color=color.orange, text_size=table_text_size)
    
    table.cell(info_table, 0, 5, '', text_color=color.green, text_size=table_text_size)
    table.cell(info_table, 1, 5, 'CCI', text_color=color.green, text_size=table_text_size)
    table.cell(info_table, 2, 5, str.tostring(cci, '0.00'), text_color=color.green, text_size=table_text_size)
    
    // Key Trend Indicators
    table.cell(info_table, 0, 6, 'TREND', text_color=color.navy, text_size=table_text_size, bgcolor=color.new(color.navy, 90))
    table.cell(info_table, 1, 6, 'SMA Momentum %', text_color=color.navy, text_size=table_text_size)
    table.cell(info_table, 2, 6, str.tostring(sma_momentum, '0.00'), text_color=color.navy, text_size=table_text_size)
    
    table.cell(info_table, 0, 7, '', text_color=color.maroon, text_size=table_text_size)
    table.cell(info_table, 1, 7, 'EMA Momentum %', text_color=color.maroon, text_size=table_text_size)
    table.cell(info_table, 2, 7, str.tostring(ema_momentum, '0.00'), text_color=color.maroon, text_size=table_text_size)
    
    table.cell(info_table, 0, 8, '', text_color=color.teal, text_size=table_text_size)
    table.cell(info_table, 1, 8, 'SAR Trend', text_color=color.teal, text_size=table_text_size)
    table.cell(info_table, 2, 8, str.tostring(sar_trend, '0'), text_color=color.teal, text_size=table_text_size)
    
    table.cell(info_table, 0, 9, '', text_color=color.lime, text_size=table_text_size)
    table.cell(info_table, 1, 9, 'Linear Regression', text_color=color.lime, text_size=table_text_size)
    table.cell(info_table, 2, 9, str.tostring(lr_slope, '0.000'), text_color=color.lime, text_size=table_text_size)
    
    // Key Volatility Indicators
    table.cell(info_table, 0, 10, 'VOLATILITY', text_color=color.yellow, text_size=table_text_size, bgcolor=color.new(color.yellow, 90))
    table.cell(info_table, 1, 10, 'ATR %', text_color=color.yellow, text_size=table_text_size)
    table.cell(info_table, 2, 10, str.tostring(atr_pct, '0.00'), text_color=color.yellow, text_size=table_text_size)
    
    table.cell(info_table, 0, 11, '', text_color=color.aqua, text_size=table_text_size)
    table.cell(info_table, 1, 11, 'BB Position', text_color=color.aqua, text_size=table_text_size)
    table.cell(info_table, 2, 11, str.tostring(bb_position, '0.00'), text_color=color.aqua, text_size=table_text_size)
    
    table.cell(info_table, 0, 12, '', text_color=color.olive, text_size=table_text_size)
    table.cell(info_table, 1, 12, 'KC Position', text_color=color.olive, text_size=table_text_size)
    table.cell(info_table, 2, 12, str.tostring(kc_position, '0.00'), text_color=color.olive, text_size=table_text_size)
    
    // Key Volume Indicators
    table.cell(info_table, 0, 13, 'VOLUME', text_color=color.blue, text_size=table_text_size, bgcolor=color.new(color.blue, 90))
    table.cell(info_table, 1, 13, 'Volume ROC', text_color=color.blue, text_size=table_text_size)
    table.cell(info_table, 2, 13, str.tostring(vroc, '0.00'), text_color=color.blue, text_size=table_text_size)
    
    table.cell(info_table, 0, 14, '', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 1, 14, 'EOM', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 2, 14, str.tostring(eom_sma, '0.000'), text_color=color.red, text_size=table_text_size)
    
    // Key Oscillators
    table.cell(info_table, 0, 15, 'OSCILLATORS', text_color=color.purple, text_size=table_text_size, bgcolor=color.new(color.purple, 90))
    table.cell(info_table, 1, 15, 'Awesome Osc', text_color=color.blue, text_size=table_text_size)
    table.cell(info_table, 2, 15, str.tostring(ao, '0.000'), text_color=color.blue, text_size=table_text_size)
    
    table.cell(info_table, 0, 16, '', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 1, 16, 'Fisher Transform', text_color=color.red, text_size=table_text_size)
    table.cell(info_table, 2, 16, str.tostring(fisher, '0.000'), text_color=color.red, text_size=table_text_size)
    
    // Summary Statistics
    table.cell(info_table, 0, 17, 'SUMMARY', text_color=color.black, text_size=table_text_size, bgcolor=color.new(color.gray, 70))
    table.cell(info_table, 1, 17, 'Total Indicators: 52', text_color=color.black, text_size=table_text_size)
    regime_color = rsi_centered > 10 ? color.green : rsi_centered < -10 ? color.red : color.gray
    regime_text = rsi_centered > 10 ? "BULLISH" : rsi_centered < -10 ? "BEARISH" : "NEUTRAL"
    table.cell(info_table, 2, 17, regime_text, text_color=regime_color, text_size=table_text_size)[/pine]

This makes it the perfect “indicator backbone” for quantitative and systematic traders who want to prototype, combine, and test new regime detection models—especially in combination with the Markov Chain [3D] indicator.

How to use this script with the Markov Chain for research and backtesting:

Add the Enhanced Indicator Export to your chart.
Every calculated indicator is available as an individual data stream.

Connect the indicator(s) you want as custom input(s) to the Markov Chain’s “Custom Indicators” option.

In the Markov Chain indicator’s settings, turn ON the custom indicator mode.

For each of the three custom indicator inputs, select the exported plot from the Enhanced Export script—the menu lists all 45+ signals by name.

This creates a powerful, modular regime-detection engine where you can mix-and-match momentum, trend, volume, or custom combinations for advanced filtering.

Backtest regime logic directly.

Once you’ve connected your chosen indicators, the Markov Chain script performs regime detection (Bull/Neutral/Bear) based on your selected features—not just price returns.

The regime detection is robust, automatically normalized (using Z-score), and outputs bias (1, -1, 0) for plug-and-play integration.

Export the regime bias for programmatic use.

As described above, use input.source() in your Pine Script strategy or system and link the bias output.

You can now filter signals, control trade direction/size, or design pairs-trading that respect true, indicator-driven market regimes.

With this framework, you’re not limited to static or simplistic regime filters. You can rigorously define, test, and refine what “market regime” means for your strategies—using the technical features that matter most to you.

Optimize your signal generation by backtesting across a universe of meaningful indicator blends.

Enhance risk management with objective, real-time regime boundaries.

Accelerate your research: iterate quickly, swap indicator components, and see results with minimal code changes.

Automate multi-asset or pairs-trading by integrating regime context directly into strategy logic.

Add both scripts to your chart, connect your preferred features, and start investigating your best regime-based trades—entirely within the TradingView ecosystem.

References & Further Reading

Ang, A., & Bekaert, G. (2002). “Regime Switches in Interest Rates.” Journal of Business & Economic Statistics, 20(2), 163–182.
Hamilton, J. D. (1989). “A New Approach to the Economic Analysis of Nonstationary Time Series and the Business Cycle.” Econometrica, 57(2), 357–384.
Markov, A. A. (1906). "Extension of the Limit Theorems of Probability Theory to a Sum of Variables Connected in a Chain." The Notes of the Imperial Academy of Sciences of St. Petersburg.
Guidolin, M., & Timmermann, A. (2007). “Asset Allocation under Multivariate Regime Switching.” Journal of Economic Dynamics and Control, 31(11), 3503–3544.
Murphy, J. J. (1999). Technical Analysis of the Financial Markets. New York Institute of Finance.
Brock, W., Lakonishok, J., & LeBaron, B. (1992). “Simple Technical Trading Rules and the Stochastic Properties of Stock Returns.” Journal of Finance, 47(5), 1731–1764.
Zucchini, W., MacDonald, I. L., & Langrock, R. (2017). Hidden Markov Models for Time Series: An Introduction Using R (2nd ed.). Chapman and Hall/CRC.

On Quantitative Finance and Markov Models:

Lo, A. W., & Hasanhodzic, J. (2009). The Heretics of Finance: Conversations with Leading Practitioners of Technical Analysis. Bloomberg Press. [Contains interview and insights from Jim Simons on the use of statistical models, regime analysis, and the potential role of hidden Markov models in Renaissance Technologies’ strategies.]

Patterson, S. (2016). The Man Who Solved the Market: How Jim Simons Launched the Quant Revolution. Penguin Press. [Describes regime detection concepts, advanced statistical modeling, and alludes to hidden Markov methods as deployed by Renaissance Technologies.]

TradingView Pine Script Documentation: https://www.tradingview.com/pine-script-docs/

TradingView Blog: “Use an Input From Another Indicator With Your Strategy” https://www.tradingview.com/blog/en/use-an-input-from-another-indicator-with-your-strategy-19584/

GeeksforGeeks: “What is the Difference Between Markov Chains and Hidden Markov Models?” https://www.geeksforgeeks.org/artificial-intelligence/what-is-the-difference-between-markov-chains-and-hidden-markov-models/

What makes this indicator original and unique?
- On‑chart, real‑time Markov. The chain is drawn directly on your chart. You see the current regime, its tendency to stay (self‑loop), and the usual next step (arrows) as bars confirm.
- Source‑agnostic by design. The engine runs on any series you select via input.source() — price, your own oscillator, a composite score, anything you compute in the script.
- Automatic normalization + regime mapping. Different inputs live on different scales. The script standardizes your chosen source and maps it into clear regimes (e.g., Bull / Bear / Neutral) without you micromanaging thresholds each time.
- Rolling, bar‑by‑bar learning. Transition tendencies are computed from a rolling window of confirmed bars. What you see is exactly what the market did in that window.
- Fast experimentation. Switch the source, adjust the window, and the Markov view updates instantly. It’s a rapid way to test ideas and feel regime persistence/switch behavior.
Integrate your own signals (using input.source())
- In settings, choose the Source. This is powered by input.source().
- Feed it price, an indicator you compute inside the script, or a custom composite series.
- The script will automatically normalize that series and process it through the Markov engine, mapping it to regimes and updating the on‑chart spheres/arrows in real time.

Credits:

Deep gratitude to @RicardoSantos for both the foundational Markov chain processing engine and inspiring open-source contributions, which made advanced probabilistic market modeling accessible to the TradingView community.

Special thanks to @Alien_Algorithms for the innovative and visually stunning 3D sphere logic that powers the indicator’s animated, regime-based visualization.

Disclaimer
This tool summarizes recent behavior. It is not financial advice and not a guarantee of future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ║                                              MARKOV CHAIN [3D]                                                                                                     ║
// ║                                                                                                                                                                    ║
// ║                                                                                                                                                                    ║
// ║  A lookback-based Markov Chain indicator that visualizes market regimes using transition probabilities                                                             ║
// ║  with animated 3D spheres representing Bull, Bear, and Neutral states and their transition probabilities                                                           ║  
// ║                                                                                                                                                                    ║
// ║  Features:                                                                                                                                                         ║
// ║  • Real-time regime detection using price returns or custom indicators                                                                                             ║
// ║  • Dynamic transition probability calculation                                                                                                                      ║
// ║  • Interactive 3D visualization with animated spheres                                                                                                              ║
// ║  • Bidirectional arrows showing state transitions                                                                                                                  ║
// ║  • Moving particle effects along transition paths                                                                                                                  ║
// ║                                                                                                                                                                    ║
// ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
// =============================================================================
// MARKOV CHAIN [3D] — Open‑Source
// Credits:
// - 3D sphere rendering technique inspired by @Alien_Algorithms
//   Source: https://www.tradingview.com/script/bT8hx615-Solar-System-in-3D-Astro-Tool-w-Zodiac/
// - Portions of Markov chain logic adapted from @RicardoSantos — MarkovChain (library)
//   Source: https://www.tradingview.com/script/gPZKYCjK-MarkovChain/
//
// Significant improvements:
// - Z‑score regime engine (price/custom features), hysteresis, bias output (+1/0/−1)
// - Rolling transition matrix with Laplace smoothing; updates only on confirmed bars
// - Advanced 3D animation (grid spheres, dynamic tilt/rotation) + particle flow arrows
// - input.source() integration for 3 normalized custom indicators; configurable visuals
indicator('Markov Chain [3D] | Fractalyst', overlay = false, max_polylines_count = 100, max_labels_count = 100, max_bars_back=500, scale = scale.right)
// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                      MODEL CONFIGURATION                                                        │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

model_group = "Markov Chain Model"
var int lookback_period = input.int(50, "Lookback Period", minval=5, maxval=100, group=model_group, tooltip="Lookback window for transition probabilities and Z-score baseline. Lower = more reactive; higher = smoother, more stable")
bool use_custom_indicators = input.bool(false, "Enable Custom Indicators", group=model_group, tooltip="Enable to use external indicators instead of price-based regime detection. When disabled, uses adaptive Z-score analysis of price returns")
ind1 = input.source(volume, "Custom Indicator 1", group=model_group, active = use_custom_indicators, tooltip="First custom indicator source for regime detection. Will be Z-score normalized over the lookback period")
ind2 = input.source(volume, "Custom Indicator 2", group=model_group, active = use_custom_indicators, tooltip="Second custom indicator source for regime detection. Will be Z-score normalized over the lookback period")
ind3 = input.source(volume, "Custom Indicator 3", group=model_group, active = use_custom_indicators, tooltip="Third custom indicator source for regime detection. Will be Z-score normalized over the lookback period")

// Market regime detection now uses Z-score statistical approach (see regime detection engine)

// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                      VISUAL CONFIGURATION                                                       │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

visual_group = 'Visual Settings'
var float scale_factor = input.float(800, 'Scale Factor', minval = 100, maxval = 1500, group = visual_group, tooltip="Controls overall size of the 3D visualization. Lower values for compact display, higher values for larger, more detailed spheres")
var int gui_shift = -int(input.int(200, 'Horizontal Shift', group = visual_group, tooltip="Radius of the 3D regime spheres. Affects sphere detail, arrow positioning, and particle animation paths"))
var float node_size = input.float(80, 'Node Size', minval = 30, maxval = 150, group = visual_group, tooltip="Horizontal position adjustment for the entire visualization. Useful for avoiding overlap with other indicators")

// Color settings
color_group = 'Color Settings'
var color bull_color = input.color(#00b9ff, 'Bullish', group = visual_group, tooltip="Color for the Bull market regime sphere and associated visual elements")
var color neutral_color = input.color(#787b86, 'Neutral', group = visual_group, tooltip="Color for the Neutral/Sideways market regime sphere and associated visual elements")
var color bear_color = input.color(#ff0051, 'Bearish', group = visual_group, tooltip="Color for the Bear market regime sphere and associated visual elements")
// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                   CUSTOM INDICATOR SETTINGS                                                     │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

// Normalized thresholds for custom indicators (±1 standard deviations)
var float ind1_bull_threshold = +1
var float ind1_bear_threshold = -1
var float ind2_bull_threshold = +1
var float ind2_bear_threshold = -1
var float ind3_bull_threshold = +1
var float ind3_bear_threshold = -1

// Equal weighting for indicator combination
var float ind1_weight = 1/3
var float ind2_weight = 1/3
var float ind3_weight = 1/3

// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                    INDICATOR NORMALIZATION                                                      │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/// Normalizes indicator values using Z-score standardization
/// @param value Current indicator value
/// @param lookback_length Period for calculating mean and standard deviation
/// @returns Normalized value clamped between -3 and +3 standard deviations
normalize_indicator(float value, float lookback_length) =>
    // Calculate rolling statistics
    float mean_val = ta.sma(value, int(lookback_length))
    float stdev_val = ta.stdev(value, int(lookback_length))
    
    // Z-score normalization
    normalized = stdev_val > 0 ? (value - mean_val) / stdev_val : 0.0
    
    // Clamp to ±3 standard deviations to prevent extreme outliers
    math.max(-3.0, math.min(3.0, normalized))


/// Converts normalized indicator value to regime signal
/// @param normalized_value Z-score normalized indicator value
/// @param bull_threshold Threshold for bullish regime
/// @param bear_threshold Threshold for bearish regime
/// @returns 1.0 (Bull), -1.0 (Bear), or 0.0 (Neutral)
get_indicator_regime_signal(float normalized_value, float bull_threshold, float bear_threshold) =>
    if normalized_value > bull_threshold
        1.0  // Bullish regime
    else if normalized_value < bear_threshold
        -1.0 // Bearish regime
    else
        0.0  // Neutral regime


// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                     REGIME DETECTION ENGINE                                                     │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/// Main regime detection function combining multiple indicators or price-based signals
/// @returns Market regime: 1 (Bull), -1 (Bear), 0 (Neutral)
get_combined_regime_signal() =>
    if use_custom_indicators
        // ── Custom Indicator Mode ──
        // Normalize all three indicators
        norm_ind1 = normalize_indicator(ind1, lookback_period)
        norm_ind2 = normalize_indicator(ind2, lookback_period)
        norm_ind3 = normalize_indicator(ind3, lookback_period)
        
        // Convert to regime signals
        signal1 = get_indicator_regime_signal(norm_ind1, ind1_bull_threshold, ind1_bear_threshold)
        signal2 = get_indicator_regime_signal(norm_ind2, ind2_bull_threshold, ind2_bear_threshold)
        signal3 = get_indicator_regime_signal(norm_ind3, ind3_bull_threshold, ind3_bear_threshold)
        
        // Weighted combination of signals
        total_weight = ind1_weight + ind2_weight + ind3_weight
        if total_weight > 0
            combined_signal = (signal1 * ind1_weight + signal2 * ind2_weight + signal3 * ind3_weight) / total_weight
            
            // Apply hysteresis to prevent noise
            if combined_signal > 0.05
                1   // Bullish consensus
            else if combined_signal < -0.05
                -1  // Bearish consensus
            else
                0   // Neutral/Mixed signals
        else
            0
    else
        // ── Price-Based Mode ──
        // Use Z-score of returns for statistically significant regime detection
        
        // Calculate percentage returns (more stable than absolute changes)
        returns = ta.change(close) / close[1]
        
        // Calculate rolling statistics for Z-score normalization
        lookback_len = lookback_period  // Use configured lookback period for statistical baseline
        returns_mean = ta.sma(returns, lookback_len)
        returns_stdev = ta.stdev(returns, lookback_len)
        
        // Calculate Z-score: (current_value - mean) / standard_deviation
        // Z-score tells us how many standard deviations away from normal
        z_score = returns_stdev > 0 ? (returns - returns_mean) / returns_stdev : 0
        
        // Statistical significance thresholds (balanced for practical regime detection)
        // Z-score > 0.33 = movement beyond ~63% of normal distribution
        // This gives roughly balanced regime distribution (~37% each for bull/bear, ~26% neutral)
        z_bull_threshold = +(1/3)   // Bullish when returns > 0.33 std dev above mean
        z_bear_threshold = -(1/3)   // Bearish when returns > 0.33 std dev below mean
        
        if z_score > z_bull_threshold
            1   // Statistically significant upward movement
        else if z_score < z_bear_threshold
            -1  // Statistically significant downward movement
        else
            0   // Normal range (within 1 standard deviation)

// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                      MARKET STATE TRACKING                                                     │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

// Get current market regime and prevent repainting on unconfirmed bars
market_state = get_combined_regime_signal()
market_state := barstate.isconfirmed ? market_state : market_state[1]


// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                    MARKOV CHAIN MATRICES                                                       │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

// Core Markov Chain data structures
// Matrix indices: 0=Bull, 1=Bear, 2=Neutral
var matrix<float> transition_matrix = matrix.new<float>(3, 3, 0.0)  // 3x3 transition count matrix
var array<int> state_counts = array.new<int>(3, 0)                 // State frequency counters
var int total_transitions = 0                                       // Total observed transitions
// Rolling window of recent confirmed states (as indices 0=Bull,1=Bear,2=Neutral)
var array<int> recent_states = array.new<int>()


// ── Transition Matrix Updates (bar-close, rolling window) ──
// Update counts only on confirmed bars and maintain a rolling window of size `lookback_period`
if barstate.isconfirmed and not na(market_state)
    // Map current market_state to index
    curr_state_idx = market_state == 1 ? 0 : market_state == -1 ? 1 : 2

    // Append current state; ensure window holds last `lookback_period`+1 states (for `lookback_period` transitions)
    array.push(recent_states, curr_state_idx)
    while array.size(recent_states) > lookback_period + 1
        array.shift(recent_states)

    // Rebuild matrices from the rolling window
    // Reset transition matrix to zeros
    for r = 0 to 2
        for c = 0 to 2
            matrix.set(transition_matrix, r, c, 0.0)
    // Reset state counts
    for s = 0 to 2
        array.set(state_counts, s, 0)

    // Recompute counts from recent_states
    sz = array.size(recent_states)
    if sz > 0
        // State occupancy over the window
        for i = 0 to sz - 1
            sidx = array.get(recent_states, i)
            array.set(state_counts, sidx, array.get(state_counts, sidx) + 1)
        // Transitions between consecutive states (sz-1 transitions)
        if sz > 1
            for i = 1 to sz - 1
                prev_idx = array.get(recent_states, i - 1)
                next_idx = array.get(recent_states, i)
                count_val = matrix.get(transition_matrix, prev_idx, next_idx)
                matrix.set(transition_matrix, prev_idx, next_idx, count_val + 1)
        total_transitions := sz > 0 ? sz - 1 : 0


/// Calculates transition probability from one state to another
/// @param from_state Source state index (0=Bull, 1=Bear, 2=Neutral)
/// @param to_state Target state index (0=Bull, 1=Bear, 2=Neutral)
/// @returns Probability of transitioning from source to target state
get_transition_probability(int from_state, int to_state) =>
    // Calculate row sum (total transitions from source state)
    // Apply Laplace smoothing (+1 per outcome) for stability with sparse data
    row_sum = 0.0
    for j = 0 to 2
        row_sum += (matrix.get(transition_matrix, from_state, j) + 1.0)

    // With Laplace smoothing, row_sum cannot be zero; still keep guard for safety
    if row_sum == 0
        0.0
    else
        (matrix.get(transition_matrix, from_state, to_state) + 1.0) / row_sum


// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                      3D GRAPHICS ENGINE                                                       │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/// 3D point structure for sphere generation and transformations
type Point3D
	float x  // X coordinate in 3D space
	float y  // Y coordinate in 3D space
	float z  // Z coordinate in 3D space

// ── 3D Rendering Constants ──
var float DEG_TO_RAD = math.pi / 180          // Degree to radian conversion
var float CAMERA_ANGLE = 45.0                 // Camera viewing angle
var float CAMERA_COS = math.cos(CAMERA_ANGLE * DEG_TO_RAD)  // Precomputed cosine
var float CAMERA_SIN = math.sin(CAMERA_ANGLE * DEG_TO_RAD)  // Precomputed sine
var int SEGMENTS = 12                         // Sphere tessellation resolution


/// Generates 3D sphere vertices using spherical coordinates
/// @param radius Sphere radius
/// @returns Array of 3D points forming a sphere
f_generate_sphere_points(radius) =>
    points = array.new<Point3D>()
    // Generate sphere using latitude-longitude parameterization
    for i = 0 to SEGMENTS by 1
        lat = math.pi * (-0.5 + i / SEGMENTS)  // Latitude: -π/2 to π/2
        for j = 0 to SEGMENTS by 1
            lon = 2 * math.pi * j / SEGMENTS   // Longitude: 0 to 2π
            // Convert spherical to Cartesian coordinates
            x = radius * math.cos(lat) * math.cos(lon)
            y = radius * math.sin(lat)
            z = radius * math.cos(lat) * math.sin(lon)
            array.push(points, Point3D.new(x, y, z))
    points


/// Applies X-axis rotation to a 3D point (camera perspective)
/// @param point Input 3D point
/// @returns Rotated 3D point
rotate_x(Point3D point) =>
    // Rotation matrix around X-axis
    y = point.y * CAMERA_COS - point.z * CAMERA_SIN
    z = point.y * CAMERA_SIN + point.z * CAMERA_COS
    Point3D.new(point.x, y, z)


/// Transforms and projects 3D sphere points to 2D chart coordinates
/// @param points Array of 3D sphere vertices
/// @param center_x X position of sphere center
/// @param center_y Y position of sphere center  
/// @param center_z Z position of sphere center
/// @param tilt Tilt angle in degrees
/// @param rotation Rotation angle in radians
/// @returns Array of 2D chart points ready for rendering
update_sphere(array<Point3D> points, float center_x, float center_y, float center_z, float tilt, float rotation) =>
    projected_points = array.new<chart.point>()
    
    // Precompute trigonometric values for performance
    cos_rotation = math.cos(rotation)
    sin_rotation = math.sin(rotation)
    cos_tilt = math.cos(tilt * DEG_TO_RAD)
    sin_tilt = math.sin(tilt * DEG_TO_RAD)

    for point in points
        // Apply Y-axis rotation (spinning animation)
        rotated_x = point.x * cos_rotation - point.z * sin_rotation
        rotated_z = point.x * sin_rotation + point.z * cos_rotation

        // Apply X-axis tilt (3D perspective effect)
        tilted_y = point.y * cos_tilt - rotated_z * sin_tilt
        tilted_z_final = point.y * sin_tilt + rotated_z * cos_tilt

        // Project to 2D screen coordinates
        projected_x = rotated_x + center_x
        projected_y = tilted_y + center_y

        array.push(projected_points, chart.point.from_index(gui_shift + bar_index + int(projected_x), projected_y + scale_factor))
    projected_points


/// Renders 3D sphere using polylines for latitude and longitude grid
/// @param projected_points Array of 2D chart points from sphere projection
/// @param col Color for sphere wireframe
draw_3d_sphere(array<chart.point> projected_points, color col, int poly_width = 1) =>
    // Draw latitude lines (horizontal circles)
    for i = 0 to SEGMENTS by 1
        lat_points = array.new<chart.point>()
        for j = 0 to SEGMENTS by 1
            idx = i * (SEGMENTS + 1) + j
            if idx < array.size(projected_points)
                array.push(lat_points, array.get(projected_points, idx))
        if array.size(lat_points) > 1
            polyline.new(lat_points, line_color = col, line_width = poly_width)
    
    // Draw longitude lines (vertical curves)
    for j = 0 to SEGMENTS by 1
        lon_points = array.new<chart.point>()
        for i = 0 to SEGMENTS by 1
            idx = i * (SEGMENTS + 1) + j
            if idx < array.size(projected_points)
                array.push(lon_points, array.get(projected_points, idx))
        if array.size(lon_points) > 1
            polyline.new(lon_points, line_color = col, line_width = poly_width)


// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                     PARTICLE ANIMATION SYSTEM                                                  │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/// Creates animated particle flow between two points with color gradients
/// @param start_x Starting X coordinate
/// @param start_y Starting Y coordinate
/// @param end_x Ending X coordinate
/// @param end_y Ending Y coordinate
/// @param animation_time Current animation time for phase calculation
/// @param start_color Color at animation start
/// @param end_color Color at animation end
/// @param offset_x Additional X offset for positioning
/// @param offset_y Additional Y offset for positioning
draw_moving_circles(float start_x, float start_y, float end_x, float end_y, float animation_time, color start_color, color end_color, float offset_x, float offset_y) =>
    // Number of particles in the animation stream
    num_circles = 6
    
    // Calculate direction vector and length
    dx = end_x - start_x
    dy = end_y - start_y
    length = math.sqrt(dx * dx + dy * dy)
    
    // Calculate perpendicular vector for alternating particle paths
    perp_x = length > 0 ? -dy / length : 0
    perp_y = length > 0 ? dx / length : 0
    
    // Offset distance for alternating sides
    edge_offset = 1.5
    
    // Generate animated particles with staggered phases
    for i = 0 to num_circles - 1
        // Create unique phase offset for each particle
        phase_offset = i * (2 * math.pi / num_circles)
        
        // Calculate sinusoidal oscillation for smooth animation
        oscillation = math.sin(animation_time * 2 + phase_offset)
        
        // Convert oscillation (-1 to 1) to progress (0 to 1)
        progress = (oscillation + 1) / 2
        
        // Calculate particle position along the path
        base_x = start_x + (end_x - start_x) * progress + offset_x
        base_y = start_y + (end_y - start_y) * progress + offset_y
        
        // Alternate particles between two parallel paths
        side_multiplier = (i % 2 == 0) ? 1 : -1
        circle_x = base_x + perp_x * edge_offset * side_multiplier
        circle_y = base_y + perp_y * edge_offset * side_multiplier
        
        // Extract RGB components for gradient calculation
        start_r = color.r(start_color)
        start_g = color.g(start_color)
        start_b = color.b(start_color)
        
        end_r = color.r(end_color)
        end_g = color.g(end_color)
        end_b = color.b(end_color)
        
        // Interpolate colors based on particle progress
        gradient_r = start_r + (end_r - start_r) * progress
        gradient_g = start_g + (end_g - start_g) * progress
        gradient_b = start_b + (end_b - start_b) * progress
        
        // Create final gradient color
        gradient_color = color.rgb(gradient_r, gradient_g, gradient_b)
        
        // Render particle as colored circle
        label.new(gui_shift + bar_index + int(circle_x), circle_y + scale_factor, 
                  "", 
                  color=gradient_color, 
                  size= 1, 
                  style=label.style_circle, 
                  xloc=xloc.bar_index)


// ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                    MARKET REGIME NODE RENDERING                                                │
// └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/// Renders an animated 3D sphere representing a market regime state
/// @param x X position of the node center
/// @param y Y position of the node center
/// @param label_text Text label for the node
/// @param node_color Primary color for the node
/// @param prob Probability value to display
/// @param rotation Animation rotation time
/// @param node_type Type of node ("Bull", "Bear", "Neutral")
/// @param current_market_state Current active market state
draw_market_node(float x, float y, string label_text, color node_color, float prob, float rotation, string node_type, int current_market_state) =>
    // Generate base sphere geometry
    sphere_points = f_generate_sphere_points(node_size * 0.8)

    // Calculate complex rotation animations for organic movement
    base_rotation = rotation * 0.8
    x_rotation = rotation * 0.6 + (x * 0.01)
    y_rotation = rotation * 1.2 + (y * 0.01)
    z_rotation = rotation * 0.9 + math.sin(rotation * 0.3) * 0.5
    
    // Dynamic tilt with multiple harmonic components for natural movement
    tilt = 15.0 + 8.0 * math.sin(rotation * 0.4) + 5.0 * math.cos(rotation * 0.7) + 3.0 * math.sin(rotation * 1.1)
    
    // Combine rotation components for complex 3D animation
    combined_rotation = base_rotation + math.sin(x_rotation) * 0.3 + math.cos(y_rotation) * 0.2

    // Project 3D sphere to 2D chart coordinates
    projected_points = update_sphere(sphere_points, x, y, 0, tilt, combined_rotation)


    // ── Active State Detection ──
    // Determine if this node represents the currently active market regime
    should_have_inner_circle = false
    market_sphere_index = market_state == 1 ? 0 : (market_state == -1 ? 1 : 2)
    sphere_index = node_type == 'Bull' ? 0 : (node_type == 'Bear' ? 1 : 2)
    should_have_inner_circle := (market_sphere_index == sphere_index)
    
    // ── Dynamic Color Calculation ──
    color sphere_color = na
    if should_have_inner_circle
        // Active state: High opacity, bright appearance
        sphere_color := color.new(node_color, 20)
    else
        // Inactive states: Apply special effects based on node type
        if node_type == 'Neutral'
            // Neutral node gets animated lighting effect
            light_intensity = math.sin(rotation * 1.5) * 0.3 + 0.7
            
            // Extract base gray color components
            base_gray_r = color.r(node_color)
            base_gray_g = color.g(node_color)
            base_gray_b = color.b(node_color)
            
            // Calculate color influences for warm lighting
            blue_influence = 15 * light_intensity
            red_influence = 12 * light_intensity
            
            // Apply lighting to create dynamic color shifting
            lit_r = math.min(255, base_gray_r + red_influence)
            lit_g = math.min(255, base_gray_g + (blue_influence + red_influence) * 0.3)
            lit_b = math.min(255, base_gray_b + blue_influence)
            
            // Create final lit color with transparency
            lit_gray_color = color.rgb(lit_r, lit_g, lit_b)
            sphere_color := color.new(lit_gray_color, 60)
        else
            // Bull/Bear nodes: Standard dimmed appearance when inactive
            sphere_color := color.new(node_color, 60)
    // ── Render Main Sphere ──
    draw_3d_sphere(projected_points, sphere_color)
    
    // ── Active State Inner Sphere Animation ──
    if should_have_inner_circle
        // Create pulsing animation for active state indicator
        pulse_factor = 0.15 * math.sin(rotation * 3.0)
        
        // Dynamic transparency based on pulse
        circle_transparency = int(5 + math.abs(pulse_factor * 10))
        
        // Create pulsing inner sphere color
        inner_circle_color = color.new(node_color, circle_transparency)
        
        // Calculate pulsing size (30% base + pulse variation)
        inner_circle_size = node_size * (0.3 + pulse_factor)
        inner_circle_points = f_generate_sphere_points(inner_circle_size)
        inner_circle_projected = update_sphere(inner_circle_points, x, y, 0, tilt, combined_rotation * 1.5)
        draw_3d_sphere(inner_circle_projected, inner_circle_color, 2)
    
    // ── Render Node Labels ──

    if node_type == 'Bull' or node_type == 'Bear'

        label_y = y + node_size * 0.85
        
        // Determine label transparency based on inner circle presence (same logic as sphere)
        label_text_transparency = should_have_inner_circle ? 0 : 30  // Bright when active, dimmed when inactive
        

        label.new(gui_shift + bar_index + int(x), label_y + scale_factor, 
                  str.tostring(prob * 100, '0.00') + '%', 
                  color=color.new(color.white, 100), textcolor=color.new(node_color, label_text_transparency), 
                  size=size.normal, style=label.style_label_down, xloc=xloc.bar_index, 
                  text_formatting=text.format_bold)
    else if node_type == 'Neutral'

        label_y = y - node_size * 0.85
        
        // Determine label transparency based on inner circle presence (same logic as sphere)
        label_text_transparency = should_have_inner_circle ? 0 : 30  // Bright when active, dimmed when inactive
        

        label.new(gui_shift + bar_index + int(x), label_y + scale_factor, 
                  str.tostring(prob * 100, '0.00') + '%', 
                  color=color.new(color.white, 100), textcolor=color.new(node_color, label_text_transparency), 
                  size=size.normal, style=label.style_label_up, xloc=xloc.bar_index, 
                  text_formatting=text.format_bold)


// ═══════════════════════════════════════════════════════════════════════════
// ███ BIDIRECTIONAL TRANSITION ARROW VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════
// Renders animated bidirectional arrows between market regime nodes to visualize
// transition probabilities in both directions. Arrows are offset to prevent overlap
// and include animated segments with probability labels.
//
// Parameters:
// • start_x/y, end_x/y: Coordinates of connected regime nodes
// • prob1, prob2: Transition probabilities for each direction
// • start_color, end_color: Colors of the connected regimes
// • connection_type: Layout type (horizontal, diagonal) for label positioning
// • animation_time: Time factor for animated effects
// ═══════════════════════════════════════════════════════════════════════════
draw_bidirectional_arrows(start_x, start_y, end_x, end_y, prob1, prob2, start_color, end_color, connection_type, animation_time) =>

    // ── Vector Calculations ──
    // Calculate direction vector between nodes
    dx = end_x - start_x
    dy = end_y - start_y
    length = math.sqrt(dx * dx + dy * dy)
    
    // Normalize direction vector for unit length
    norm_dx = dx / length
    norm_dy = dy / length
    
    // Calculate perpendicular vector for arrow offset
    // Perpendicular to (dx, dy) is (-dy, dx)
    perp_x = -norm_dy
    perp_y = norm_dx
    
    // ── Arrow Offset Configuration ──
    // Offset arrows to prevent overlap (20% of node size)
    offset = node_size * 0.2
    
    // ── Sphere Boundary Adjustment ──
    // Adjust arrow endpoints to start/end at sphere boundaries
    // rather than at center points (90% of node radius)
    sphere_radius = node_size * 0.9
    adj_start_x = start_x + norm_dx * sphere_radius
    adj_start_y = start_y + norm_dy * sphere_radius
    adj_end_x = end_x - norm_dx * sphere_radius
    adj_end_y = end_y - norm_dy * sphere_radius
    
    // ── First Arrow Path Calculation ──
    // Offset in positive perpendicular direction
    offset_start_x1 = adj_start_x + perp_x * offset
    offset_start_y1 = adj_start_y + perp_y * offset
    offset_end_x1 = adj_end_x + perp_x * offset
    offset_end_y1 = adj_end_y + perp_y * offset
    
    // ── Second Arrow Path Calculation ──
    // Offset in negative perpendicular direction (opposite side)
    offset_start_x2 = adj_end_x - perp_x * offset
    offset_start_y2 = adj_end_y - perp_y * offset
    offset_end_x2 = adj_start_x - perp_x * offset
    offset_end_y2 = adj_start_y - perp_y * offset
    

    // ── Arrow Segmentation Configuration ──
    // Divide arrows into segments for animated/styled rendering
    num_segments = 8
    
    // ═══════════════════════════════════════════════════════════════════════════
    // ▶ FIRST DIRECTIONAL ARROW RENDERING
    // ═══════════════════════════════════════════════════════════════════════════
    for i = 0 to num_segments - 1
        // Calculate segment position (0 to 1 normalized)
        segment_start = i / num_segments
        segment_end = (i + 1) / num_segments
        
        // ── Segment Coordinate Interpolation ──
        // Linear interpolation along arrow path
        seg_start_x = offset_start_x1 + (offset_end_x1 - offset_start_x1) * segment_start
        seg_start_y = offset_start_y1 + (offset_end_y1 - offset_start_y1) * segment_start
        seg_end_x = offset_start_x1 + (offset_end_x1 - offset_start_x1) * segment_end
        seg_end_y = offset_start_y1 + (offset_end_y1 - offset_start_y1) * segment_end
        
        // ── Segment Styling ──
        // Semi-transparent foreground color for visibility
        segment_color = color.new(chart.fg_color, 35)
        
        // Add arrowhead to final segment
        line_style = (i == num_segments - 1) ? line.style_arrow_right : line.style_solid
        
        // Draw segment line
        line.new(gui_shift + bar_index + int(seg_start_x), seg_start_y + scale_factor,
                 gui_shift + bar_index + int(seg_end_x), seg_end_y + scale_factor,
                 color=segment_color, style=line_style, width=2, xloc=xloc.bar_index)
    

    // ═══════════════════════════════════════════════════════════════════════════
    // ◀ SECOND DIRECTIONAL ARROW RENDERING (REVERSE)
    // ═══════════════════════════════════════════════════════════════════════════
    for i = 0 to num_segments - 1
        // Calculate segment position (0 to 1 normalized)
        segment_start = i / num_segments
        segment_end = (i + 1) / num_segments
        
        // ── Segment Coordinate Interpolation ──
        // Linear interpolation along reverse arrow path
        seg_start_x = offset_start_x2 + (offset_end_x2 - offset_start_x2) * segment_start
        seg_start_y = offset_start_y2 + (offset_end_y2 - offset_start_y2) * segment_start
        seg_end_x = offset_start_x2 + (offset_end_x2 - offset_start_x2) * segment_end
        seg_end_y = offset_start_y2 + (offset_end_y2 - offset_start_y2) * segment_end
        
        // ── Segment Styling ──
        // Matching style with first arrow for consistency
        segment_color = color.new(chart.fg_color, 35)
        
        // Add arrowhead to final segment
        line_style = (i == num_segments - 1) ? line.style_arrow_right : line.style_solid
        
        // Draw segment line
        line.new(gui_shift + bar_index + int(seg_start_x), seg_start_y + scale_factor,
                 gui_shift + bar_index + int(seg_end_x), seg_end_y + scale_factor,
                 color=segment_color, style=line_style, width=2, xloc=xloc.bar_index)
    

    // ═══════════════════════════════════════════════════════════════════════════
    // 🏷️ TRANSITION PROBABILITY LABELS
    // ═══════════════════════════════════════════════════════════════════════════
    
    // ── Label Position Calculation ──
    // Place labels at midpoint of each arrow
    mid_x1 = (offset_start_x1 + offset_end_x1) / 2
    mid_y1 = (offset_start_y1 + offset_end_y1) / 2
    mid_x2 = (offset_start_x2 + offset_end_x2) / 2
    mid_y2 = (offset_start_y2 + offset_end_y2) / 2
    
    // ── Dynamic Label Style Selection ──
    // Adjust label orientation based on connection type
    first_label_style = label.style_label_up
    second_label_style = label.style_label_down
    
    if connection_type == "horizontal"
        // For horizontal connections, place labels above/below arrows
        upper_arrow_y = math.max(mid_y1, mid_y2)
        first_label_style := mid_y1 == upper_arrow_y ? label.style_label_down : label.style_label_up
        second_label_style := mid_y2 == upper_arrow_y ? label.style_label_down : label.style_label_up
    else if connection_type == "left_diagonal"
        // For left diagonal, use corner label styles
        first_label_style := label.style_label_lower_left
        second_label_style := label.style_label_upper_right
    else if connection_type == "right_diagonal"
        // For right diagonal, use opposite corner styles
        first_label_style := label.style_label_upper_left
        second_label_style := label.style_label_lower_right
    
    // ── First Arrow Probability Label ──
    // Display transition probability as percentage
    label.new(gui_shift + bar_index + int(mid_x1), mid_y1 + scale_factor, 
              str.tostring(prob1 * 100, '0.00') + '%', 
              color=color.new(color.white, 100), textcolor= color.new(chart.fg_color,5), size=size.normal, 
              style=first_label_style, xloc=xloc.bar_index, text_formatting = text.format_bold)
    
    // ── Second Arrow Probability Label ──
    // Display reverse transition probability
    label.new(gui_shift + bar_index + int(mid_x2), mid_y2 + scale_factor,
              str.tostring(prob2 * 100, '0.00') + '%', 
              color=color.new(color.white, 100), textcolor= color.new(chart.fg_color,5), size=size.normal, 
              style=second_label_style, xloc=xloc.bar_index, text_formatting = text.format_bold)




// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 MAIN MARKOV CHAIN VISUALIZATION ENGINE                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
// Master function that orchestrates the entire 3D Markov Chain visualization.
// Combines all visual elements: animated spheres, transition arrows, particles,
// and probability labels to create an interactive market regime display.
//
// Parameters:
// • rotation: Global animation time factor for synchronized animations
// ═══════════════════════════════════════════════════════════════════════════
draw_markov_chain_with_regime_data(float rotation) =>

    // ── Clear Previous Frame ──
    // Remove all visual elements from previous render
    for poly in polyline.all
        polyline.delete(poly)
    for lbl in label.all
        label.delete(lbl)
    for ln in line.all
        line.delete(ln)

    // Show warming-up notice until we have at least one transition (2 states)
    warmup_sz = array.size(recent_states)
    if warmup_sz < 2
        label.new(gui_shift + bar_index, scale_factor + 20,
                  "Warming up: collecting transitions...",
                  color = color.new(color.white, 100), textcolor = chart.fg_color,
                  xloc = xloc.bar_index, style = label.style_none, size = size.small,
                  text_formatting = text.format_bold)

    // ═══════════════════════════════════════════════════════════════════════════
    // 📍 NODE POSITION CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════
    // Fixed positions for regime nodes in triangular arrangement
    bull_x = -150.0    // Left position
    bull_y = 50.0      // Upper level
    bear_x = 150.0     // Right position
    bear_y = 50.0      // Upper level
    neutral_x = 0.0    // Center position
    neutral_y = -100.0 // Lower level

    // ═══════════════════════════════════════════════════════════════════════════
    // 📊 STATE PROBABILITY CALCULATIONS
    // ═══════════════════════════════════════════════════════════════════════════
    // Calculate empirical probabilities from historical state counts
    total_states = array.get(state_counts, 0) + array.get(state_counts, 1) + array.get(state_counts, 2)
    bull_prob = total_states > 0 ? array.get(state_counts, 0) / total_states : 1.0/3.0
    bear_prob = total_states > 0 ? array.get(state_counts, 1) / total_states : 1.0/3.0
    neutral_prob = total_states > 0 ? array.get(state_counts, 2) / total_states : 1.0/3.0

    // ═══════════════════════════════════════════════════════════════════════════
    // 🔄 TRANSITION PROBABILITY EXTRACTION
    // ═══════════════════════════════════════════════════════════════════════════
    // Extract all pairwise transition probabilities from Markov matrix
    bull_to_bear_prob = get_transition_probability(0, 1)     // Bull → Bear
    bear_to_bull_prob = get_transition_probability(1, 0)     // Bear → Bull
    bull_to_neutral_prob = get_transition_probability(0, 2)  // Bull → Neutral
    neutral_to_bull_prob = get_transition_probability(2, 0)  // Neutral → Bull
    bear_to_neutral_prob = get_transition_probability(1, 2)  // Bear → Neutral
    neutral_to_bear_prob = get_transition_probability(2, 1)  // Neutral → Bear
    bull_self_prob = get_transition_probability(0, 0)       // Bull → Bull (self)
    bear_self_prob = get_transition_probability(1, 1)       // Bear → Bear (self)
    neutral_self_prob = get_transition_probability(2, 2)     // Neutral → Neutral (self)

    // ═══════════════════════════════════════════════════════════════════════════
    // 🔮 3D MARKET REGIME NODE RENDERING
    // ═══════════════════════════════════════════════════════════════════════════
    // Render animated 3D spheres for each market regime
    // Active regime has pulsing inner sphere and brighter colors
    draw_market_node(bull_x, bull_y, 'Bull\nmarket', bull_color, bull_self_prob, rotation, 'Bull', market_state)
    draw_market_node(bear_x, bear_y, 'Bear\nmarket', bear_color, bear_self_prob, rotation, 'Bear', market_state)
    draw_market_node(neutral_x, neutral_y, 'Neutral\nmarket', neutral_color, neutral_self_prob, rotation, 'Neutral', market_state)

    // ═══════════════════════════════════════════════════════════════════════════
    // ↔️ TRANSITION ARROW RENDERING
    // ═══════════════════════════════════════════════════════════════════════════
    // Draw bidirectional arrows between all regime pairs
    // Bull ↔ Bear (horizontal layout)
    draw_bidirectional_arrows(bull_x, bull_y, bear_x, bear_y, bull_to_bear_prob, bear_to_bull_prob, bull_color, bear_color, "horizontal", rotation)
    
    // Bull ↔ Neutral (left diagonal layout)
    draw_bidirectional_arrows(bull_x, bull_y, neutral_x, neutral_y, bull_to_neutral_prob, neutral_to_bull_prob, bull_color, neutral_color, "left_diagonal", rotation)
    
    // Bear ↔ Neutral (right diagonal layout)
    draw_bidirectional_arrows(bear_x, bear_y, neutral_x, neutral_y, bear_to_neutral_prob, neutral_to_bear_prob, bear_color, neutral_color, "right_diagonal", rotation)
    

    // ═══════════════════════════════════════════════════════════════════════════
    // ✨ PARTICLE ANIMATION SYSTEM
    // ═══════════════════════════════════════════════════════════════════════════
    // Animated particles flow along transition paths to visualize
    // the dynamic nature of regime transitions. Particles use color
    // gradients from source to destination regime.
    
    // ── Particle Path Configuration ──
    arrow_color = color.new(chart.fg_color,35)
    offset = node_size * 0.2        // Path offset to align with arrows
    sphere_radius = node_size * 0.9  // Start/end at sphere boundaries
    
    // ════════════════════════════════════════════════════════════════════
    // 🔵↔️🔴 BULL-BEAR PARTICLE ANIMATIONS
    // ════════════════════════════════════════════════════════════════════
    // Calculate normalized direction vectors for Bull-Bear connection
    bull_bear_dx = bear_x - bull_x
    bull_bear_dy = bear_y - bull_y
    bull_bear_length = math.sqrt(bull_bear_dx * bull_bear_dx + bull_bear_dy * bull_bear_dy)
    bull_bear_norm_dx = bull_bear_dx / bull_bear_length
    bull_bear_norm_dy = bull_bear_dy / bull_bear_length
    bull_bear_perp_x = -bull_bear_norm_dy  // Perpendicular for offset
    bull_bear_perp_y = bull_bear_norm_dx
    
    // ── Forward Path (Bull → Bear) ──
    // Calculate particle path with positive offset
    bull_bear_start_x1 = bull_x + bull_bear_norm_dx * sphere_radius + bull_bear_perp_x * offset
    bull_bear_start_y1 = bull_y + bull_bear_norm_dy * sphere_radius + bull_bear_perp_y * offset
    bull_bear_end_x1 = bear_x - bull_bear_norm_dx * sphere_radius + bull_bear_perp_x * offset
    bull_bear_end_y1 = bear_y - bull_bear_norm_dy * sphere_radius + bull_bear_perp_y * offset
    
    // ── Reverse Path (Bear → Bull) ──
    // Calculate particle path with negative offset
    bull_bear_start_x2 = bear_x - bull_bear_norm_dx * sphere_radius - bull_bear_perp_x * offset
    bull_bear_start_y2 = bear_y - bull_bear_norm_dy * sphere_radius - bull_bear_perp_y * offset
    bull_bear_end_x2 = bull_x + bull_bear_norm_dx * sphere_radius - bull_bear_perp_x * offset
    bull_bear_end_y2 = bull_y + bull_bear_norm_dy * sphere_radius - bull_bear_perp_y * offset
    
    // Render animated particles with color gradients
    draw_moving_circles(bull_bear_start_x1, bull_bear_start_y1, bull_bear_end_x1, bull_bear_end_y1, rotation, bull_color, bear_color, 0, 0)
    draw_moving_circles(bull_bear_start_x2, bull_bear_start_y2, bull_bear_end_x2, bull_bear_end_y2, rotation, bear_color, bull_color, 0, 0)
    

    // ════════════════════════════════════════════════════════════════════
    // 🔵↔️⚪ BULL-NEUTRAL PARTICLE ANIMATIONS
    // ════════════════════════════════════════════════════════════════════
    // Calculate normalized direction vectors for Bull-Neutral connection
    bull_neutral_dx = neutral_x - bull_x
    bull_neutral_dy = neutral_y - bull_y
    bull_neutral_length = math.sqrt(bull_neutral_dx * bull_neutral_dx + bull_neutral_dy * bull_neutral_dy)
    bull_neutral_norm_dx = bull_neutral_dx / bull_neutral_length
    bull_neutral_norm_dy = bull_neutral_dy / bull_neutral_length
    bull_neutral_perp_x = -bull_neutral_norm_dy  // Perpendicular for offset
    bull_neutral_perp_y = bull_neutral_norm_dx
    
    // ── Forward Path (Bull → Neutral) ──
    // Calculate particle path with positive offset
    bull_neutral_start_x1 = bull_x + bull_neutral_norm_dx * sphere_radius + bull_neutral_perp_x * offset
    bull_neutral_start_y1 = bull_y + bull_neutral_norm_dy * sphere_radius + bull_neutral_perp_y * offset
    bull_neutral_end_x1 = neutral_x - bull_neutral_norm_dx * sphere_radius + bull_neutral_perp_x * offset
    bull_neutral_end_y1 = neutral_y - bull_neutral_norm_dy * sphere_radius + bull_neutral_perp_y * offset
    
    // ── Reverse Path (Neutral → Bull) ──
    // Calculate particle path with negative offset
    bull_neutral_start_x2 = neutral_x - bull_neutral_norm_dx * sphere_radius - bull_neutral_perp_x * offset
    bull_neutral_start_y2 = neutral_y - bull_neutral_norm_dy * sphere_radius - bull_neutral_perp_y * offset
    bull_neutral_end_x2 = bull_x + bull_neutral_norm_dx * sphere_radius - bull_neutral_perp_x * offset
    bull_neutral_end_y2 = bull_y + bull_neutral_norm_dy * sphere_radius - bull_neutral_perp_y * offset
    
    // Render animated particles with color gradients
    draw_moving_circles(bull_neutral_start_x1, bull_neutral_start_y1, bull_neutral_end_x1, bull_neutral_end_y1, rotation, bull_color, neutral_color, 0, 0)
    draw_moving_circles(bull_neutral_start_x2, bull_neutral_start_y2, bull_neutral_end_x2, bull_neutral_end_y2, rotation, neutral_color, bull_color, 0, 0)
    

    // ════════════════════════════════════════════════════════════════════
    // 🔴↔️⚪ BEAR-NEUTRAL PARTICLE ANIMATIONS
    // ════════════════════════════════════════════════════════════════════
    // Calculate normalized direction vectors for Bear-Neutral connection
    bear_neutral_dx = neutral_x - bear_x
    bear_neutral_dy = neutral_y - bear_y
    bear_neutral_length = math.sqrt(bear_neutral_dx * bear_neutral_dx + bear_neutral_dy * bear_neutral_dy)
    bear_neutral_norm_dx = bear_neutral_dx / bear_neutral_length
    bear_neutral_norm_dy = bear_neutral_dy / bear_neutral_length
    bear_neutral_perp_x = -bear_neutral_norm_dy  // Perpendicular for offset
    bear_neutral_perp_y = bear_neutral_norm_dx
    
    // ── Forward Path (Bear → Neutral) ──
    // Calculate particle path with positive offset
    bear_neutral_start_x1 = bear_x + bear_neutral_norm_dx * sphere_radius + bear_neutral_perp_x * offset
    bear_neutral_start_y1 = bear_y + bear_neutral_norm_dy * sphere_radius + bear_neutral_perp_y * offset
    bear_neutral_end_x1 = neutral_x - bear_neutral_norm_dx * sphere_radius + bear_neutral_perp_x * offset
    bear_neutral_end_y1 = neutral_y - bear_neutral_norm_dy * sphere_radius + bear_neutral_perp_y * offset
    
    // ── Reverse Path (Neutral → Bear) ──
    // Calculate particle path with negative offset
    bear_neutral_start_x2 = neutral_x - bear_neutral_norm_dx * sphere_radius - bear_neutral_perp_x * offset
    bear_neutral_start_y2 = neutral_y - bear_neutral_norm_dy * sphere_radius - bear_neutral_perp_y * offset
    bear_neutral_end_x2 = bear_x + bear_neutral_norm_dx * sphere_radius - bear_neutral_perp_x * offset
    bear_neutral_end_y2 = bear_y + bear_neutral_norm_dy * sphere_radius - bear_neutral_perp_y * offset
    
    // Render animated particles with color gradients
    draw_moving_circles(bear_neutral_start_x1, bear_neutral_start_y1, bear_neutral_end_x1, bear_neutral_end_y1, rotation, bear_color, neutral_color, 0, 0)
    draw_moving_circles(bear_neutral_start_x2, bear_neutral_start_y2, bear_neutral_end_x2, bear_neutral_end_y2, rotation, neutral_color, bear_color, 0, 0)


// ═══════════════════════════════════════════════════════════════════════════
// ⚙️ ANIMATION ENGINE & MAIN EXECUTION
// ═══════════════════════════════════════════════════════════════════════════
// Controls the animation timing and triggers the main visualization rendering
// on the last bar. The rotation_time variable provides synchronized animation
// across all visual elements.

// ── Animation State Variables ──
var bool init = false              // Initialization flag (unused in current version)
varip float rotation_time = 0.0    // Global animation timer (persistent across bars)

// ── Main Rendering Loop ──
// Execute visualization only on the last bar to optimize performance
if barstate.islast
    // Increment animation timer for smooth continuous rotation
    rotation_time := rotation_time + 0.05
    
    // Render complete Markov Chain visualization
    draw_markov_chain_with_regime_data(rotation_time)

// ═══════════════════════════════════════════════════════════════════════════
// 📊 DATA WINDOW OUTPUT
// ═══════════════════════════════════════════════════════════════════════════
// Export current market state to data window for external analysis
color regime_color = market_state == 1 ? bull_color : market_state == -1 ? bear_color : neutral_color
plot(market_state, "Current Market State", regime_color, linewidth=2,display = display.data_window, editable = false)
// Plot market regime on candles
plotcandle(open,high,low,close,"Regime state",regime_color,regime_color, force_overlay = true,editable = true,display = display.none)
````
