<!-- tradingview-pine-id: PUB;b6c70b371de649f78a3061f5e161ad03 -->
<!-- tradingviewscripts-format: 1 -->
# Market Manipulation Index (MMI)

Source: https://www.tradingview.com/script/EOLvUvxl-Market-Manipulation-Index-MMI/

## Description

The Composite Manipulation Index (CMI) is a structural integrity tool that quantifies how chaotic or orderly current market conditions are, with the aim of detecting potentially manipulated or unstable environments. It blends two distinct mathematical models that assess price behavior in terms of both structural rhythm and predictability.

1. Sine-Fit Deviation Model:
This component assumes that ideal, low-manipulation price behavior resembles a smooth oscillation, such as a sine wave. It generates a synthetic sine wave using a user-defined period and compares it to actual price movement over an adaptive window. The error between the real price and this synthetic wave—normalized by price variance—forms the Sine-Based Manipulation Index. A high error indicates deviation from natural rhythm, suggesting structural disorder.

2. Predictability-Based Model:
The second component estimates how well current price can be predicted using recent price lags. A two-variable rolling linear regression is computed between the current price and two lagged inputs (close[1] and close[2]). If the predicted price diverges from the actual price, this error—also normalized by price variance—reflects unpredictability. High prediction error implies a more manipulated or erratic environment.

3. Adaptive Mechanism:
Both components are calculated using an adaptive smoothing window based on the Average True Range (ATR). This allows the indicator to respond proportionally to market volatility. During high volatility, the analysis window expands to avoid over-sensitivity; during calm periods, it contracts for better responsiveness.

4. Composite Output:
The two normalized metrics are averaged to form the final CMI value, which is then optionally smoothed further. The output is scaled between 0 and 1:

0 indicates a highly structured, orderly market.

1 indicates complete structural breakdown or randomness.

Suggested Interpretation:

CMI < 0.3: Market is clean and structured. Trend-following or breakout strategies may perform better.

CMI > 0.7: Market is structurally unstable. Choppy price action, fakeouts, or manipulative behavior may dominate.

CMI 0.3–0.7: Transitional zone. Caution or reduced risk may be warranted.

This indicator is designed to serve as a contextual filter, helping traders assess whether current market conditions are conducive to structured strategies, or if discretion and defense are more appropriate.

---

## Source Code

````pine
//@version=5
indicator("Market Manipulation Index (MMI)", "MMI", overlay=false)

// ── Inputs
baseWin  = input.int(50, "Base Window Length", minval=10)
sineLen  = input.int(20, "Sine Reference Period", minval=5)
smooth   = input.int(5,  "Final Smoothing", minval=1)
atrMult  = input.float(1.0, "ATR Multiplier for Adaptivity", minval=0.1)
atrLen   = input.int(14, "ATR Period for Window Scaling", minval=1)

// ── Adaptive Window (safe handling with fallback)
atr_val = ta.atr(atrLen)
adaptiveWin_raw = baseWin * (atr_val / close) * atrMult
adaptiveWin = math.max(10, math.round(nz(adaptiveWin_raw, baseWin)))

// ── Manual EMA with adaptive length
ema_adaptive(src, len) =>
    alpha = 2 / (len + 1)
    var float ema = na
    ema := na(ema[1]) ? src : alpha * src + (1 - alpha) * ema[1]

// ── Sine-Fit Based MI
sine_wave = math.sin(2 * math.pi * bar_index / sineLen)
price     = close
price_dev = price - ema_adaptive(close, adaptiveWin)
sine_dev  = sine_wave - ema_adaptive(sine_wave, adaptiveWin)
mse_sine  = ema_adaptive(math.pow(price_dev - sine_dev, 2), adaptiveWin)
var_price = ta.variance(price, baseWin)  // Using fixed window for stability
mi_sine   = math.min(1.0, math.max(0.0, mse_sine / var_price))

// ── Predictability-Based MI
x1 = nz(close[1])
x2 = nz(close[2])
sum_x1     = ema_adaptive(x1, adaptiveWin)
sum_x2     = ema_adaptive(x2, adaptiveWin)
sum_y      = ema_adaptive(close, adaptiveWin)
sum_x1x1   = ema_adaptive(x1 * x1, adaptiveWin)
sum_x2x2   = ema_adaptive(x2 * x2, adaptiveWin)
sum_x1y    = ema_adaptive(x1 * close,  adaptiveWin)
sum_x2y    = ema_adaptive(x2 * close,  adaptiveWin)
sum_x1x2   = ema_adaptive(x1 * x2, adaptiveWin)

denom = (sum_x1x1 * sum_x2x2 - sum_x1x2 * sum_x1x2)
var float a = na
var float b = na
if denom != 0
    a := (sum_x2x2 * sum_x1y - sum_x1x2 * sum_x2y) / denom
    b := (sum_x1x1 * sum_x2y - sum_x1x2 * sum_x1y) / denom

y_hat = a * x1 + b * x2
residual = close - y_hat
mse_pred = ema_adaptive(math.pow(residual, 2), adaptiveWin)
mi_pred  = math.min(1.0, math.max(0.0, mse_pred / var_price))

// ── Spectral Energy Component (Approximate Frequency Analysis)
lowBand  = ta.ema(price, 34) - ta.ema(price, 89)   // slow structure
highBand = price - ta.ema(price, 8)               // fast noise

energyLow  = ta.variance(lowBand, baseWin)
energyHigh = ta.variance(highBand, baseWin)

spectralRatio = energyHigh / (energyHigh + energyLow)
mi_spectral = math.min(1.0, math.max(0.0, spectralRatio))

// ── Composite CMI (with Spectral Component)
cmi_raw = (mi_sine + mi_pred + mi_spectral) / 3
cmi = ta.ema(cmi_raw, smooth)

// ── Plotting
plot(cmi, title="Composite Manipulation Index", color=color.red, linewidth=2)
hline(0.3, "Low MI (Clean)", color=color.green, linestyle=hline.style_dashed)
hline(0.7, "High MI (Choppy/Manipulated)", color=color.orange, linestyle=hline.style_dashed)
bgcolor(cmi > 0.7 ? color.new(color.red, 85) : cmi < 0.3 ? color.new(color.green, 85) : na, title="Background Highlight")
````
