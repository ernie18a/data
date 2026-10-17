# Williams %X (Jurik Smoothed %R)

- url: https://www.tradingview.com/script/L5X4f9bG-Williams-X-Jurik-Smoothed-R/
- type: indicator
- pine_id: PUB;9228796f86b3472b9c76ba873fff3da6
- version: 1.0

## Description

SOlves jaggedness in the williams %R by applying the Jurik smoothing filter

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//@version=6
indicator("Williams %X (Jurik Smoothed %R)", shorttitle="W%X", overlay=false)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
string MODE_1 = "W%X (Standard Jurik Smoothed)"
string MODE_2 = "DW%X (Double Jurik Smoothed)"
string MODE_3 = "NG-W%X (No-Gap Jurik Smoothed)"

string modeInput = input.string(MODE_1, "Calculation Mode", options=[MODE_1, MODE_2, MODE_3])
int lengthInput  = input.int(14, "Lookback Length", minval=2)

//---------------------------------------------------------------------------------------------------------------------}
// Math Functions
//---------------------------------------------------------------------------------------------------------------------{
// Standard Williams %R
f_calc_wpr(float src, float h, float l, series int len) =>
    float highestHigh = ta.highest(h, len)
    float lowestLow   = ta.lowest(l, len)
    float denominator = highestHigh - lowestLow
    float safeDenom   = denominator == 0 ? 0.0001 : denominator
    -100.0 * (highestHigh - src) / safeDenom

// Jurik Moving Average (JMA) Filter Matrix
f_jma(float _src, int _length) =>
    float phaseRatio = 1.5 + 50.0 / 100.0
    float beta = 0.45 * (_length - 1) / (0.45 * (_length - 1) + 2)
    float alpha = math.pow(beta, 2.0)
    
    // Safely isolated variable declarations
    var float jma = 0.0
    var float e0 = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    
    e0 := (1 - alpha) * _src + alpha * nz(e0[1], _src)
    e1 := (_src - e0) * (1 - beta) + beta * nz(e1[1], 0)
    e2 := (e0 + phaseRatio * e1 - nz(jma[1], _src)) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1], 0)
    jma := e2 + nz(jma[1], _src)
    jma

//---------------------------------------------------------------------------------------------------------------------}
// Core Computations
//---------------------------------------------------------------------------------------------------------------------{
// 1. Core Williams %R
float wpr_raw = f_calc_wpr(close, high, low, lengthInput)

// 2. Standard W%X
float wpr_wpx = f_jma(wpr_raw, lengthInput)

// 3. Double Smoothed W%X
float wpr_dwpx = f_jma(wpr_wpx, lengthInput)

// 4. No-Gap W%X (Guarded Inline Calculation)
float trueHigh = math.max(nz(high), nz(close[1], nz(high)))
float trueLow  = math.min(nz(low), nz(close[1], nz(low)))

float hh_nogap = ta.highest(trueHigh, lengthInput)
float ll_nogap = ta.lowest(trueLow, lengthInput)
float denom_nogap = hh_nogap - ll_nogap
float safe_denom_nogap = denom_nogap == 0 ? 0.0001 : denom_nogap

float wpr_nogap_raw = nz(-100.0 * (hh_nogap - nz(close)) / safe_denom_nogap, -50.0)
float wpr_ngwpx = f_jma(wpr_nogap_raw, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// Signal Routing
//---------------------------------------------------------------------------------------------------------------------{
float final_osc = switch modeInput
    MODE_1 => wpr_wpx
    MODE_2 => wpr_dwpx
    MODE_3 => wpr_ngwpx
    => wpr_wpx

//---------------------------------------------------------------------------------------------------------------------}
// Visuals
//---------------------------------------------------------------------------------------------------------------------{
color COLOR_BULL = #089981
color COLOR_BEAR = #f23645
color COLOR_NEUT = color.gray

hline(-20, "Overbought", color.new(COLOR_BEAR, 50), hline.style_dashed)
hline(-80, "Oversold",   color.new(COLOR_BULL, 50), hline.style_dashed)
hline(-50, "Median",     color.new(COLOR_NEUT, 50), hline.style_dotted)

color osc_color = final_osc > nz(final_osc[1]) ? COLOR_BULL : COLOR_BEAR
plot(final_osc, title="W%X Oscillator", color=osc_color, linewidth=2)
//---------------------------------------------------------------------------------------------------------------------}
````
