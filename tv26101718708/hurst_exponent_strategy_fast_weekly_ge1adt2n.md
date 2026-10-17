# Hurst Exponent Strategy [Fast + Weekly]

- url: https://www.tradingview.com/script/Ge1aDt2n/
- type: indicator
- pine_id: PUB;352188d8f31e43a09c73e88b4f7efb1c
- version: 1.0

## Description

## Overview
The **Hurst Exponent Strategy [Fast + Weekly]** is an advanced quantitative tool that calculates the Hurst Exponent ($H$) using the Rescaled Range ($R/S$) analysis. Instead of tracking directional momentum or price overlays, this indicator measures the **statistical memory** and fractal dimension of financial time series to detect market regimes.

It helps traders identify whether an asset is trending, mean-reverting, or trapped in a state of pure noise (chaos).

---

## The Mathematics of Market Regimes
The indicator evaluates the price action and plots values between 0 and 1, anchored to a theoretical center line of **0.5 (Random Walk)**:
- **$H > 0.60$ (Trend / Persistent):** The market possesses long-term memory. Price movements tend to be followed by movements in the same direction. Ideal for trend-following strategies.
- **$H < 0.45$ (Elastic / Anti-Persistent):** The market behaves like a rubber band (Mean Reversion). Price movements are consistently followed by reversals. Ideal for grid, mean-reversion, or range-bound strategies.
- **$0.45 \le H \le 0.60$ (Chaos / Random Walk):** The price action mimics a Brownian motion. Movements are random, noise is high, and directional edge is minimal.

---

## Dual Timeframe Framework
To avoid fighting macro market structures, this script calculates two separate Hurst metrics simultaneously:
1. **Fast Hurst (Cyan Line):** Calculated on the current chart timeframe. It responds quickly to micro-regime shifts, pinpointing when a consolidation is breaking into a trend or expanding into chaos.
2. **Macro Hurst (Orange Line):** Multi-timeframe execution locked exclusively to the **Weekly ("W") chart**. It acts as a structural filter, keeping you aligned with the true macro nature of the asset.

Both exponents feature an optional built-in **Smoothing filter (SMA)** to remove high-frequency mathematical noise without heavily lagging the structural reading.

---

## Real-Time Informative Legend
The top-right dashboard monitors the live mathematical output of both exponents:
- Displays exact numerical values down to 4 decimal places.
- Dynamically classifies the market state into **TREND** (Green), **ELASTICO** (Red), or **CAOS** (Gray) for instant visual confirmation.

---
Disclaimer: This tool calculates mathematical probabilities based on historical fractal dimensions. It does not provide entry/exit arrows or guarantee profits. Use it as a regime filter alongside your preferred execution strategy.

## Source Code

````pine
//@version=5
indicator("Hurst Exponent Strategy [Fast + Weekly]", overlay=false)

// ==========================================
// 1. INPUTS
// ==========================================
grp_fast = "Hurst Veloce (Chart Corrente)"
len_fast   = input.int(25, "Lunghezza Veloce", minval=2, group=grp_fast)
sm_fast    = input.bool(true, "Show Smooth Veloce", group=grp_fast)
sm_len_fast= input.int(10, "Smooth Length Veloce", minval=1, group=grp_fast)

grp_slow = "Hurst Macro (Sempre Weekly)"
len_slow   = input.int(64, "Lunghezza Macro", minval=2, group=grp_slow)
sm_slow    = input.bool(true, "Show Smooth Macro", group=grp_slow)
sm_len_slow= input.int(10, "Smooth Length Macro", minval=1, group=grp_slow)

// ==========================================
// 2. FUNZIONE DI CALCOLO (CORE)
// ==========================================
calc_hurst(_len, _smooth_len, _do_smooth) =>
    _priceChange = close / close[1] - 1
    _meanPriceChange = ta.sma(_priceChange, _len)
    
    _cumulativeChange = 0.0
    _minChange = 0.0
    _maxChange = 0.0
    _deviationSum = 0.0
    
    for i = 0 to _len - 1
        _val = _priceChange[i]
        _deviationSum := _deviationSum + math.pow(_val - _meanPriceChange, 2)
        _cumulativeChange := _cumulativeChange + (_val - _meanPriceChange)
        
        if i == 0
            _minChange := _cumulativeChange
            _maxChange := _cumulativeChange
        else
            _minChange := math.min(_minChange, _cumulativeChange)
            _maxChange := math.max(_maxChange, _cumulativeChange)
            
    _stdDev = math.sqrt(_deviationSum / (_len - 1))
    _rescaledRange = _stdDev != 0 ? (_maxChange - _minChange) / _stdDev : 0
    
    _hurstExponent = 0.0
    if _rescaledRange > 0
        _hurstExponent := math.log(_rescaledRange) / math.log(_len)
        
    _final = _do_smooth ? ta.sma(_hurstExponent, _smooth_len) : _hurstExponent
    _final

// ==========================================
// 3. CALCOLI
// ==========================================
h_fast = calc_hurst(len_fast, sm_len_fast, sm_fast)
h_slow = request.security(syminfo.tickerid, "W", calc_hurst(len_slow, sm_len_slow, sm_slow))

// ==========================================
// 4. PLOTTING
// ==========================================
hline(0.5, "Random Walk", color=color.gray, linestyle=hline.style_dashed)
// Uso i codici HEX per sicurezza, ma color.orange e color.cyan vanno bene con v5
plot(h_slow, "Hurst Weekly (Macro)", color=#FF8000, linewidth=3) 
plot(h_fast, "Hurst Veloce (Chart)", color=#00FFFF, linewidth=2)

// ==========================================
// 5. TABELLA INFORMATIVA (Legenda)
// ==========================================
var table leg_table = table.new(position.top_right, 3, 3, border_width=1, frame_color=color.gray, border_color=color.gray)

get_state_text(val) =>
    if val > 0.60
        "TREND"
    else if val < 0.45
        "ELASTICO"
    else
        "CAOS"

get_state_color(val) =>
    if val > 0.60
        color.green
    else if val < 0.45
        color.red
    else
        color.gray

if barstate.islast
    table.cell(leg_table, 0, 0, "Timeframe", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(leg_table, 1, 0, "Valore", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(leg_table, 2, 0, "Stato", bgcolor=color.new(color.gray, 80), text_color=color.white)
    
    table.cell(leg_table, 0, 1, "Chart (" + str.tostring(len_fast) + ")", text_color=#00FFFF, bgcolor=color.black)
    table.cell(leg_table, 1, 1, str.tostring(h_fast, "#.####"), text_color=color.white, bgcolor=color.black)
    table.cell(leg_table, 2, 1, get_state_text(h_fast), text_color=get_state_color(h_fast), bgcolor=color.black)

    table.cell(leg_table, 0, 2, "Weekly (" + str.tostring(len_slow) + ")", text_color=#FF8000, bgcolor=color.black)
    table.cell(leg_table, 1, 2, str.tostring(h_slow, "#.####"), text_color=color.white, bgcolor=color.black)
    table.cell(leg_table, 2, 2, get_state_text(h_slow), text_color=get_state_color(h_slow), bgcolor=color.black)
````
