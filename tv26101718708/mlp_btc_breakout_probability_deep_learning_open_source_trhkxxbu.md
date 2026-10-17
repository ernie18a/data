# MLP - BTC Breakout Probability [Deep Learning] [Open Source]

- url: https://www.tradingview.com/script/tRHkxXBU/
- type: indicator
- pine_id: PUB;6f6b413e28ed4049ab662666037e5f50
- version: 1.0

## Description

I trained a single Multilayer Perceptron on 13 years of Bitcoin price history and open-sourced the result. Not because it's perfect, but because the idea is worth sharing.

[b]The concept is simple.[/b]
Most breakout strategies are rule-based. Fixed levels, static conditions. This one is different, instead of predicting direction, the model learned the distribution of Bitcoin's daily price moves. You pick a threshold, it gives you the probability. Same model, any level.

[b]How to use it[/b]
Pick a percentage threshold , by doing that you're asking the model to evaluate. When price breaks that level and the model is showing meaningful confidence, a label is shown on the chart.. [b]Daily only.[/b] [b]BTC only.[/b]

[b]Under the hood[/b]
A lightweight Multilayer Perceptron (MLP) trained on ~4,700 daily candles of raw OHLC data from [b]May 2009 to May 2022[/b]. The architecture is two hidden layers (16→8), ReLU activations throughout, and a sigmoid output that squashes the result into a clean 0–1 probability score. ReLU keeps the internal representations sparse and non-linear, sigmoid makes the output as a probability.
What makes this interesting is that the model didn't just learn a raw number, it learned the underlying distribution of Bitcoin's daily price moves. That's what allows a single model to answer probability questions across different thresholds rather than being hardcoded to one fixed level. 
The output isn't a prediction, it's a calibrated belief about where price is likely to go, derived from 13 years of market structure.

[b]Honest limitations[/b]
Fat tails eat this model alive. The features are correlated and the model has no concept of liquidity. It underestimates the extremes. 
Daily timeframe only. Bitcoin only. Long only.

This was built as a personal project, mostly for fun and to serve as a working example of how ML concepts can be applied to market data.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, trading recommendations, or a guarantee of future results. Past performance does not predict future returns. You alone are responsible for your trading decisions. Always test thoroughly in a simulated environment before trading with real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © finalTAboss

//@version=6
indicator("MLP - Breakout Probability [Machine Learning] [Open Source]", overlay = true, max_labels_count = 500)
src = input.source(close, "Source")
tt_threshold = "Minimum price move (as a percentage) required to consider a signal. Values from 0.1%-0.001% can be entered manually."
tt_conf_min = "Only print a Label if the model's confidence is above this value AND the price move exceeds the 'Threshold'."
per = input.float(2.0, "At percent (%)",  minval=0.1, maxval=10, step=0.1, tooltip=tt_threshold)
conf_min = input.float(0.75, "Min confidence", minval=0.01, maxval=0.99, step=0.01, tooltip=tt_conf_min)

if timeframe.period != "1D"
    runtime.error("This script only runs on the Daily (1D) timeframe.")

if not str.contains(str.upper(syminfo.basecurrency), "BTC") and not str.contains(str.upper(syminfo.ticker), "BTC")
    runtime.error("This script only works on Bitcoin (BTC) charts.")

o_chg = open / open[1] - 1
sma_o_chg_3 = ta.sma(o_chg, 3)
sma_c_chg_3 = ta.sma(close / close[1] - 1, 3)
sma_o_chg_5 = ta.sma(o_chg, 5)
sma_h_chg_5 = ta.sma(high / high[1] - 1, 5)
sma_l_chg_10 = ta.sma(low  / low[1]  - 1, 10)
sma_h_chg_20 = ta.sma(high / high[1] - 1, 20)
sma_l_chg_20 = ta.sma(low  / low[1]  - 1, 20)
sma_c_chg_20 = ta.sma(close / close[1] - 1, 20)

var float[] l1w0  = array.from(-0.142376,-1.630116,-1.194026,-1.495841, 3.477488, 1.085355, 0.029492, 1.705865,-1.077097,-0.000071,-0.927027)
var float[] l1w1  = array.from(-0.105385,-2.814526, 3.91971,  2.016826, 0.063381, 0.174143,-4.294409, 3.292528,-1.10443, -0.177641, 0.035032)
var float[] l1w2  = array.from( 0.397616, 1.069576,-0.489521,-1.569795, 0.071626, 0.701507, 4.607964, 0.055146,-1.967006,-1.350415,-0.202375)
var float[] l1w3  = array.from( 0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0     )
var float[] l1w4  = array.from( 0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0     )
var float[] l1w5  = array.from(-0.080505, 0.589033,-2.0245,   5.150016,-2.493071,-1.419171, 0.235309, 2.702715,-2.902807,-0.468048, 0.473023)
var float[] l1w6  = array.from( 0.487294, 0.048332,-0.562695,-0.684971,-2.549705, 0.342365,-1.112234, 3.194757, 2.16156,  1.263576, 0.152846)
var float[] l1w7  = array.from( 0.207114, 0.706155,-4.754064, 2.112804, 3.142773, 2.709993,-0.130911, 0.030079,-3.271604,-0.10017, -1.494047)
var float[] l1w8  = array.from( 0.529162, 1.487795, 3.369485, 2.967577,-0.060756, 0.562023,-0.279102, 2.669727, 4.557076,-0.163887, 0.022489)
var float[] l1w9  = array.from(-0.352487, 1.119541, 0.813899, 2.683094,-1.500835,-1.860581,-1.090438, 0.886003,-3.738915, 0.564293, 0.111742)
var float[] l1w10 = array.from( 0.156703,-0.592636, 0.980891, 1.511458, 0.007552,-0.503076, 0.099718,-1.204206,-3.989572, 2.162915,-0.185409)
var float[] l1w11 = array.from( 0.138725, 0.420453,-0.242725,-0.757486, 0.515139,-0.223789, 0.098729,-1.534735, 0.888073,-5.816155,-0.012434)
var float[] l1w12 = array.from( 0.051223, 2.326556,-0.645417,-0.819583,-1.140807,-2.845483,-4.064593, 1.456686,-5.064623,-0.040363,-0.024135)
var float[] l1w13 = array.from( 0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0     )
var float[] l1w14 = array.from( 0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,      0.0     )
var float[] l1w15 = array.from( 0.062834,-2.405236,-2.376154,-1.203988,-4.962941,-0.18494, -0.986293, 0.32604, -0.175602,-0.564892,-0.192626)

var float[] l1b   = array.from( 0.224409,-0.015589, 0.50288, -0.372207,-0.149844,-0.479233, 0.120552,-0.014804,-0.029147, 0.008653, 0.397252, 0.147431, 0.018085,-0.243384,-0.383626, 0.240223)

var float[] l2w0 = array.from( 0.506386,-0.44323, -0.746412, 0.0,      0.0,      1.234973, 1.116182, 0.482163,-0.01842,  0.805172, 1.502334,-0.915548,-2.098372, 0.0,      0.0,     -0.887703)
var float[] l2w1 = array.from(-1.674799, 0.078577, 0.720607, 0.0,      0.0,     -0.88905, -0.057253, 0.7199,  -1.618915,-0.703546, 1.075168,-0.544961, 0.245859, 0.0,      0.0,      1.742472)
var float[] l2w2 = array.from( 0.617668,-0.569665, 0.431726, 0.0,      0.0,      0.135551, 0.702159,-1.653719,-0.53373,  1.184171, 0.449945,-0.794138,-3.459311, 0.0,      0.0,     -1.139224)
var float[] l2w3 = array.from(-0.302179, 0.617013, 1.757996, 0.0,      0.0,      0.651105,-0.119684, 0.188948,-0.621912,-0.073504,-0.186008, 1.678564, 0.65178,  0.0,      0.0,      0.996787)
var float[] l2w4 = array.from(-0.391151,-3.026041,-0.413105, 0.0,      0.0,     -0.756251,-0.682637,-4.971617,-4.386641,-0.389913, 0.431224,-0.104295, 0.188571, 0.0,      0.0,     -0.300606)
var float[] l2w5 = array.from( 2.270454,-1.679889,-0.042532, 0.0,      0.0,     -0.304263, 1.433992,-1.88156, -0.007915, 0.757805,-0.159872,-1.702596,-0.741289, 0.0,      0.0,     -0.839537)
var float[] l2w6 = array.from( 0.357779,-1.902937, 1.234522, 0.0,      0.0,     -1.580412, 0.182543,-1.548246,-1.337889, 0.609712, 0.372205,-0.350647,-1.908554, 0.0,      0.0,     -1.14123 )
var float[] l2w7 = array.from(-0.236399, 0.358945, 0.514753, 0.0,      0.0,     -4.927803, 0.096437, 0.268808,-0.194024, 0.782189, 1.112894,-0.758274,-0.049461, 0.0,      0.0,     -0.262219)

var float[] l2b  = array.from(-0.063966,-0.189284,-0.287881, 1.250168, 0.440556, 0.062981,-0.4271,   0.031489)
var float[] l3w  = array.from(-1.851339,-2.424456,-2.82807,  2.299782,-5.622211,-2.589424,-4.051791,-2.233056)
var float   l3b  = 0.507956
threshold = per / 100

relu(v) => math.max(0.0, v)
sigmoid(v) => 1.0 / (1.0 + math.exp(-v))

dot(w, x) =>
    float s = 0.0
    for i = 0 to array.size(x) - 1
        s += array.get(w, i) * array.get(x, i)
    s

var float[] xvec = array.new_float(11)
array.set(xvec, 0, o_chg)
array.set(xvec, 1, sma_o_chg_3)
array.set(xvec, 2, sma_c_chg_3)
array.set(xvec, 3, sma_o_chg_5)
array.set(xvec, 4, sma_h_chg_5)
array.set(xvec, 5, sma_l_chg_10)
array.set(xvec, 6, sma_h_chg_20)
array.set(xvec, 7, sma_l_chg_20)
array.set(xvec, 8, sma_c_chg_20)
array.set(xvec, 9, threshold)
array.set(xvec, 10, 1)

var float[] h1 = array.new_float(16)

layer1(x) =>
    float[] out = array.new_float(16)
    array.set(out, 0, relu(dot(l1w0, x) + array.get(l1b, 0)))
    array.set(out, 1, relu(dot(l1w1, x) + array.get(l1b, 1)))
    array.set(out, 2, relu(dot(l1w2, x) + array.get(l1b, 2)))
    array.set(out, 3, relu(dot(l1w3, x) + array.get(l1b, 3)))
    array.set(out, 4, relu(dot(l1w4, x) + array.get(l1b, 4)))
    array.set(out, 5, relu(dot(l1w5, x) + array.get(l1b, 5)))
    array.set(out, 6, relu(dot(l1w6, x) + array.get(l1b, 6)))
    array.set(out, 7, relu(dot(l1w7, x) + array.get(l1b, 7)))
    array.set(out, 8, relu(dot(l1w8, x) + array.get(l1b, 8)))
    array.set(out, 9, relu(dot(l1w9, x) + array.get(l1b, 9)))
    array.set(out, 10, relu(dot(l1w10, x) + array.get(l1b, 10)))
    array.set(out, 11, relu(dot(l1w11, x) + array.get(l1b, 11)))
    array.set(out, 12, relu(dot(l1w12, x) + array.get(l1b, 12)))
    array.set(out, 13, relu(dot(l1w13, x) + array.get(l1b, 13)))
    array.set(out, 14, relu(dot(l1w14, x) + array.get(l1b, 14)))
    array.set(out, 15, relu(dot(l1w15, x) + array.get(l1b, 15)))
    out

layer2(x) =>
    float[] out = array.new_float(8)
    array.set(out, 0, relu(dot(l2w0, x) + array.get(l2b, 0)))
    array.set(out, 1, relu(dot(l2w1, x) + array.get(l2b, 1)))
    array.set(out, 2, relu(dot(l2w2, x) + array.get(l2b, 2)))
    array.set(out, 3, relu(dot(l2w3, x) + array.get(l2b, 3)))
    array.set(out, 4, relu(dot(l2w4, x) + array.get(l2b, 4)))
    array.set(out, 5, relu(dot(l2w5, x) + array.get(l2b, 5)))
    array.set(out, 6, relu(dot(l2w6, x) + array.get(l2b, 6)))
    array.set(out, 7, relu(dot(l2w7, x) + array.get(l2b, 7)))
    out

float[] out1 = layer1(xvec)
float[] out2 = layer2(out1)
prob = sigmoid(dot(l3w, out2) + l3b)
lvl = open * (1 + (per / 100))
signal = prob >= conf_min and src > lvl

oos_start = timestamp(2022, 12, 25, 9, 36)
timecond = time > oos_start
plot(lvl, title = "Threshold", style=plot.style_stepline, color=color.lime)

if signal and timecond
    label.new(bar_index, low, str.format("{0,number,#.###}", prob),
              color=color.rgb(76, 175, 79, 15),
              textcolor=color.white, style=label.style_label_up, size=size.tiny)
````
