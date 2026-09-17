<!-- tradingview-pine-id: PUB;213ba69a000c443ea3b6d429a06d9cf6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MLP AR — Next Open/Close (MAE on last 5)

Source: https://www.tradingview.com/script/YIkXcO2h-Autoregressive-Neural-Network-LSTM-Predict-next-price-close/

## Description

Online-trained neural network (MLP) that learns from every bar on the chart and forecasts the next bar's open and close. Written entirely in Pine Script, no external data or libraries.

═════════════════════════════════════════════
█ OVERVIEW

This indicator implements a small multilayer perceptron (MLP) in Pine Script with hand-written forward and backward passes. The network is trained incrementally as the chart plays out: on every bar it makes a prediction, compares it to what actually happened, and adjusts its weights by gradient descent. By the last bar it has learned from the entire price history available on the chart.

The output is a shaded box one bar to the right of the last candle showing the predicted open and close of the next bar, plus a strip at the bottom of the chart showing the fit quality on the most recent bars and the predicted next close.

═════════════════════════════════════════════
█ HOW IT WORKS

Inputs to the network
For each bar the network receives 2 x N features, where N is the "Window" input:

[*] the last N close-to-close log returns
[*] the last N overnight gaps (log of open / previous close)

All features are divided by a rolling standard deviation of returns, so the network sees volatility-normalized values rather than raw prices. This keeps the inputs on a similar scale regardless of the instrument or the year, which matters a lot for gradient training.

Architecture
Input layer (2N) -> hidden layers -> output layer (2 neurons: next open and next close, as normalized log returns from the current close).

The number of hidden layers ("Hidden layers") and neurons per layer ("Neurons per hidden layer") are user-configurable. The activation function can be tanh, ReLU or linear. Note that with "linear" the whole network collapses to a linear autoregressive model, which is useful as a baseline but not really a neural network.

Weights are initialized with Xavier/Glorot uniform initialization from a user-chosen seed, so results are reproducible.

Training
Training is online stochastic gradient descent:

[*] On each historical bar the network first predicts that bar from the previous N bars, then performs one or more gradient steps ("SGD steps per bar") using the actual open and close as targets. The prediction is always made before the update, so the network never sees the bar it is predicting.
[*] Optionally, at the last bar the network re-trains a few extra passes ("Replay epochs") over a buffer of the most recent bars ("Replay buffer") before producing the forecast. This refines the weights toward the current regime.

The loss is mean squared error on the two normalized outputs. Gradients are clipped to keep training stable on outlier bars.

Fit metric
After training, the network re-predicts the five most recent bars from their preceding N bars and computes the mean absolute error between predicted and actual close. The strip shows this as "Fit" = 100% - MAE%. A value of 99.2% means the predicted closes were on average 0.8% away from the actual closes.

Forecast
The trained network is fed the most recent N bars and its two outputs are converted back to price: next open = close x exp(predicted gap x volatility), next close = close x exp(predicted return x volatility). The box is green when the predicted close is above the predicted open, red otherwise.

═════════════════════════════════════════════
█ INPUTS

[*] Window (lags N) - how many past bars feed the network.
[*] Neurons per hidden layer and Hidden layers - network size. Larger is not automatically better; small networks (4-16 neurons, 1-2 layers) train faster and overfit less.
[*] Activation - tanh (default), relu, or linear.
[*] Learning rate - step size of gradient descent. Too high and the weights diverge; too low and the network barely moves from its random start.
[*] SGD steps per bar - extra training on each bar, spread across history.
[*] Replay epochs at last bar and Replay buffer - extra training at the last bar only. Keep the product of these small; Pine limits how long a single loop may run.
[*] Vol normalization length - lookback for the volatility used to scale inputs and outputs.
[*] Random seed - changes the initial weights.

═════════════════════════════════════════════
█ LIMITATIONS

[*] The "Fit" number is an in-sample fit on bars the network has already trained on. It measures how closely the model tracks recent prices, not how well it forecasts. Because daily moves are small relative to price, this number will be high (98-99.5%) for almost any model, including "next close = current close".
[*] One-bar-ahead price direction is very hard to predict on liquid instruments and daily timeframes. Do not expect this, or any similar tool, to reliably call the next candle. Treat the forecast box as a model output to study, not a trade signal.
[*] Training is a single pass in chart order with a small number of extra steps, which is much weaker than offline training with many epochs. This is a constraint of running inside Pine Script.
[*] On the live bar the training step uses the partially formed candle, so the forecast will move as the current bar develops.
[*] Setting Replay epochs x Replay buffer too high triggers Pine's "loop takes too long" error. Reduce either value if that happens.
[*] The indicator does not repaint historical bars, but the forecast box is recomputed on every tick of the last bar.

═════════════════════════════════════════════
█ NOTES

The code is fully open. The forward pass, backpropagation, and weight storage (flat arrays with layer offsets) are all in the script, so it can be used as a starting point for other Pine Script machine-learning experiments: adding volume or range as inputs, changing the loss, or predicting a different target such as volatility.

---

## Source Code

````pine
//@version=6
indicator("MLP AR — Next Open/Close (MAE on last 5)", overlay = true)

p        = input.int(5,     "Window (lags N)",           minval = 1, maxval = 30)
n_hid    = input.int(8,     "Neurons per hidden layer",  minval = 1, maxval = 64)
depth    = input.int(1,     "Hidden layers (depth)",     minval = 0, maxval = 5)
act      = input.string("tanh", "Activation", options = ["linear", "tanh", "relu"])
lr       = input.float(0.002, "Learning rate",           minval = 0.00001, step = 0.0005)
steps    = input.int(2,     "SGD steps per bar",         minval = 1, maxval = 20,
         tooltip = "Extra training spread across bars — cannot hit the loop time limit.")
epochs   = input.int(1,     "Replay epochs at last bar", minval = 0, maxval = 50,
         tooltip = "Runs in ONE loop at the last bar. epochs × replay buffer × network size must stay small or Pine errors with 'loop takes too long'.")
replay_n = input.int(100,   "Replay buffer (bars)",      minval = 10, maxval = 2000)
vol_len  = input.int(20,    "Vol normalization length",  minval = 2)
seed     = input.int(42,    "Random seed")
MAE_N    = 5

n_in  = 2 * p           // p returns + p gaps
n_out = 2               // [open, close]
n_wl  = depth + 1

// ---------- helpers ----------
f_clip(float x, float c) => math.max(-c, math.min(c, x))
f_tanh(float z) => 2.0 / (1.0 + math.exp(-2.0 * f_clip(z, 20))) - 1.0
f_act(float z, string a) => a == "tanh" ? f_tanh(z) : a == "relu" ? math.max(0.0, z) : z
f_dact(float z, string a) => a == "tanh" ? 1.0 - math.pow(f_tanh(z), 2) : a == "relu" ? (z > 0 ? 1.0 : 0.0) : 1.0

// ---------- network (flat arrays) ----------
var array<int>   sz    = array.new<int>(0)
var array<int>   w_off = array.new<int>(0)
var array<int>   a_off = array.new<int>(0)
var array<float> W     = array.new<float>(0)
var array<float> A     = array.new<float>(0)
var array<float> Z     = array.new<float>(0)
var array<float> D     = array.new<float>(0)

if barstate.isfirst
    for l = 0 to n_wl
        array.push(sz, l == 0 ? n_in : l == n_wl ? n_out : n_hid)
    wo = 0, ao = 0
    for l = 0 to n_wl
        array.push(a_off, ao)
        ao += array.get(sz, l)
        if l >= 1
            array.push(w_off, wo)
            wo += array.get(sz, l) * array.get(sz, l - 1) + array.get(sz, l)
    for i = 0 to wo - 1
        array.push(W, 0.0)
    for i = 0 to ao - 1
        array.push(A, 0.0), array.push(Z, 0.0), array.push(D, 0.0)
    for l = 1 to n_wl
        nin = array.get(sz, l - 1), nout = array.get(sz, l)
        lim = math.sqrt(6.0 / (nin + nout))
        for i = 0 to nout * nin - 1
            array.set(W, array.get(w_off, l - 1) + i, (math.random(0, 1, seed + l * 100000 + i) * 2 - 1) * lim)

f_forward(string a) =>
    nl = array.size(sz) - 1
    for l = 1 to nl
        nin = array.get(sz, l - 1), nout = array.get(sz, l)
        wo = array.get(w_off, l - 1), ai = array.get(a_off, l - 1), ao = array.get(a_off, l)
        for i = 0 to nout - 1
            z = array.get(W, wo + nout * nin + i)
            for k = 0 to nin - 1
                z += array.get(W, wo + i * nin + k) * array.get(A, ai + k)
            array.set(Z, ao + i, z)
            array.set(A, ao + i, l == nl ? z : f_act(z, a))
    true

f_backward(string a, float y0, float y1, float eta) =>
    nl = array.size(sz) - 1
    ao_out = array.get(a_off, nl)
    array.set(D, ao_out,     f_clip(array.get(A, ao_out)     - y0, 5))
    array.set(D, ao_out + 1, f_clip(array.get(A, ao_out + 1) - y1, 5))
    for l = nl to 1
        nin = array.get(sz, l - 1), nout = array.get(sz, l)
        wo = array.get(w_off, l - 1), ai = array.get(a_off, l - 1), ao = array.get(a_off, l)
        if l > 1
            for k = 0 to nin - 1
                s = 0.0
                for i = 0 to nout - 1
                    s += array.get(W, wo + i * nin + k) * array.get(D, ao + i)
                array.set(D, ai + k, s * f_dact(array.get(Z, ai + k), a))
        for i = 0 to nout - 1
            d = array.get(D, ao + i)
            for k = 0 to nin - 1
                idx = wo + i * nin + k
                array.set(W, idx, array.get(W, idx) - eta * d * array.get(A, ai + k))
            bidx = wo + nout * nin + i
            array.set(W, bidx, array.get(W, bidx) - eta * d)
    true

// ---------- data ----------
r_raw = math.log(close / close[1])         // close-to-close
g_raw = math.log(open  / close[1])         // gap: open vs previous close
vol_c = ta.stdev(r_raw, vol_len)
f_vol(int k) => nz(vol_c[k], 0.01) == 0 ? 0.01 : nz(vol_c[k], 0.01)

in0   = array.get(a_off, 0)
out0  = array.get(a_off, n_wl)
ready = bar_index > p + vol_len + 1

// inputs for bar (k back): features of bars k+1..k+p, vol known at bar k+1
f_load(int k) =>
    v = f_vol(k + 1)
    for j = 1 to p
        array.set(A, in0 + j - 1,     nz(r_raw[k + j]) / v)
        array.set(A, in0 + p + j - 1, nz(g_raw[k + j]) / v)
    v

// ---------- online training on every bar ----------
var array<float> fx = array.new<float>(0)
var array<float> fy = array.new<float>(0)
if ready
    v   = f_load(0)
    y_o = g_raw / v
    y_c = r_raw / v
    for k = 0 to n_in - 1
        array.push(fx, array.get(A, in0 + k))
    array.push(fy, y_o), array.push(fy, y_c)
    if array.size(fy) > 2 * replay_n
        for k = 0 to n_in - 1
            array.shift(fx)
        array.shift(fy), array.shift(fy)
    for e = 1 to steps
        f_forward(act)
        f_backward(act, y_o, y_c, lr)

// ---------- at last bar ----------
var table t  = table.new(position.bottom_left, 1, 1, border_color = color.gray, border_width = 1)
var box   fc = na
if barstate.islast and ready
    ns = array.size(fy) / 2
    if epochs > 0 and ns > 0
        for e = 1 to epochs
            for s = 0 to ns - 1
                for k = 0 to n_in - 1
                    array.set(A, in0 + k, array.get(fx, s * n_in + k))
                f_forward(act)
                f_backward(act, array.get(fy, 2 * s), array.get(fy, 2 * s + 1), lr)

    // MAE on the 5 rightmost bars (close and open)
    ae_c = 0.0, ae_o = 0.0, pe_c = 0.0
    for k = 0 to MAE_N - 1
        v = f_load(k)
        f_forward(act)
        pred_o = close[k + 1] * math.exp(array.get(A, out0)     * v)
        pred_c = close[k + 1] * math.exp(array.get(A, out0 + 1) * v)
        ae_o += math.abs(pred_o - open[k])
        ae_c += math.abs(pred_c - close[k])
        pe_c += math.abs(pred_c - close[k]) / close[k]
    mae_c   = ae_c / MAE_N
    mae_o   = ae_o / MAE_N
    fit_pct = 100 - 100 * pe_c / MAE_N

    // next bar forecast
    vnow = f_vol(0)
    for j = 1 to p
        array.set(A, in0 + j - 1,     nz(r_raw[j - 1]) / vnow)
        array.set(A, in0 + p + j - 1, nz(g_raw[j - 1]) / vnow)
    f_forward(act)
    n_open  = close * math.exp(array.get(A, out0)     * vnow)
    n_close = close * math.exp(array.get(A, out0 + 1) * vnow)

    box.delete(fc)
    fc := box.new(bar_index + 1, math.max(n_open, n_close), bar_index + 2, math.min(n_open, n_close),
         border_color = color.gray, bgcolor = color.new(n_close >= n_open ? color.rgb(49, 235, 46) : color.red, 60))

    txt = "Fit: (1-MAE) last 5 candles " + str.tostring(fit_pct, "#.##") + "%  |  next close: " + str.tostring(n_close, format.mintick)
    table.cell(t, 0, 0, txt, bgcolor = color.new(n_close >= close ? color.rgb(49, 240, 55) : color.red, 75),
         text_color = color.black, text_size = size.large)
````
