<!-- tradingview-pine-id: PUB;349f4b7a516348f99433d673c2a6de0c -->
<!-- tradingviewscripts-format: 1 -->
# Strong Gold NN Forecast

Source: https://www.tradingview.com/script/JstD1T00-Strong-Gold-NN-Forecast-ProjectSyndicate/

## Description

Strong Gold NN Forecast turns the last five days of Gold into a single question, answered by a genuine neural network: where are today's HIGH and LOW most likely to land? Instead of a restyled oscillator, it runs a real multi-layer perceptron — trained offline on XAUUSD daily history, its weights baked into the script — and performs the forward pass live on your chart. Every new daily candle, it reads only completed bars, locks a forecast for that day's High, Low and Close at the open, and never moves it again. The whole network is drawn on the chart as an inspectable diagram — input, three hidden layers, output — with every node lit by its live activation and every connection weighted by the signal flowing through it. And every forecast that resolves is scored on a live accuracy panel against a naïve baseline — hits and misses alike — so you judge it on the instrument you trade, not on a number typed into a description.

🧠 Neural Core — the model is a 6·6·6·6·3 multi-layer perceptron: six inputs, three hidden layers of six tanh neurons, and three linear outputs, for 147 trained weights and biases. Its lifecycle each bar is FEATURE ▸ NORMALISE ▸ FORWARD ▸ RECONSTRUCT. The network was trained by backpropagation offline on XAUUSD daily data; the learned weight matrices are embedded directly in the script and the on-chart forward pass — weighted sums, biases, and tanh activations, layer by layer — reproduces the trained model exactly. Nothing is trained on your chart, so the mapping is fixed and deterministic.

🔢 Feature Anatomy — the fingerprint is six percentage-based ingredients, all derived from the last five completed days of OHLC plus RSI: 5-day momentum (mean daily return), range position (where the last close sits inside the 5-day high-low range), RSI(14) centred at 50, the 5-day average daily range %, the 5-day average candle body %, and a short-vs-medium momentum acceleration. Working in percentage space rather than raw price is what lets a model learn from a market that ran from the 2,600s into the 4,000s without the price level itself dominating the signal.

🧊 Frozen at the Open — this indicator does not repaint. Every input is read from candles that have already closed, and the forecast is anchored to the last completed close. That means the projected High, Low and Close for the current day are computed once when the candle opens and stay fixed until it closes — no sliding lines, no intrabar drift, no numbers that quietly improve as the session plays out.

🧭 No-Lookahead Normalisation — the part most on-chart ML gets wrong. Each feature is standardised against a causal rolling window of past bars only, computed live and identically to training. No future statistic ever touches a historical prediction: the forecast printed on any past bar is identical whether or not the bars after it exist. This is verified, not assumed.

📐 Volatility-Normalised Targets — the network does not predict raw High% and Low%; it predicts each excursion in units of the recent daily range, which the script measures live. The output is then rebuilt into a four-digit Gold price. Because the size of the move is expressed relative to current volatility, the same learned shape adapts automatically as the market shifts between calm and violent regimes instead of freezing the behaviour of the period it was trained on.

🕸️ Live Network Map — the model is not a black box. The full network is drawn to the right of price: an input column labelled with each feature, three hidden columns, and an output column carrying the four-digit High, Low and Close. Every node is shaded by its live activation and every connection is coloured by weight sign and brightened by the signal passing through it, so you can watch which inputs and pathways are actually driving today's forecast.

📊 Live Accuracy Panel — a compact dashboard reports, in real time: the setup and anchor close, the frozen High/Low/Close forecast with its implied % move and range, each input as a live z-score, and a running mean absolute error of the High and Low forecasts measured against the actual bars — shown next to the error of a naïve recent-range baseline. Every resolved forecast is counted, winners and misses in full, so the number is built live on your symbol and timeframe rather than advertised in advance.

🎚️ Controls — the map's size, horizontal position, column spacing, connection glow, node values and connection drawing are all adjustable, as are the forecast projection length, the shaded High-Low range, the historical prediction track, line width, two themes, and the dashboard's position and size. None of these change the model — they change how you read it.

🎯 Why this is different — most "AI" indicators restyle an oscillator and call the top; most that claim a neural network never show one. This runs an actual trained MLP, draws it live, normalises its inputs causally so there is no lookahead, freezes each forecast at the open so it cannot repaint, and reports an honest error tracked against a baseline instead of a marketing figure. You can see the network, see the inputs, and see how it has actually done on your chart.

🚀 Where to use it — the model was trained specifically on XAUUSD on the Daily timeframe, and that is where it is designed to run; the dashboard flags the setup when the symbol or timeframe differs. The first bars of any chart are a warm-up while the causal normalisation window fills, after which the forecast and the live accuracy panel come alive.

🎯 How to trade it

1  Apply it to XAUUSD on the Daily chart and let the causal window warm up until the dashboard reads a live forecast and the accuracy panel starts counting.

2  At each new daily candle, read the frozen High / Low / Close forecast and the shaded projected range — it is locked at the open and will not move.

3  Check the Live Accuracy panel: the High and Low mean-absolute-error against the naïve baseline tells you, on your own data, whether the model is adding anything right now.

4  Use the projected High and Low as context for where the session may stretch to — a reference for targets, fades, and stop placement — not as an automatic entry.

5  Combine the forecast with your own structure, levels, and risk management. It describes a likely daily envelope; it is not an entry-and-exit system on its own.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. It is a fixed, pre-trained model: the weights were learned once on XAUUSD daily history and do not adapt on your chart, so bars inside that training period are in-sample by nature — genuine out-of-sample behaviour is what you see going forward on the live panel. In leakage-free walk-forward testing the network's High/Low error modestly beat a naïve recent-range baseline (strongest on the Low), at roughly 0.7–0.9% of price; that is a small, real edge, not a crystal ball, and on some periods it will sit close to the baseline. Forecasting a single day's exact high and low is inherently hard, and a sharp regime shift or a shock can run straight through any daily envelope. It is deliberately a small network — larger nets overfit this much daily data and test worse. Always wait for the candle to open so the forecast is frozen, and test it on your own data before trading it live.

---

## Source Code

````pine
//@version=6

indicator("Strong Gold NN Forecast", "Strong Gold NN", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50, max_bars_back=500)

var string G_FC = "◈ Forecast"
var string G_NN = "◈ Neural Network Map"
var string G_DS = "◈ Dashboard"
var string G_TH = "◈ Theme"

showForecast = input.bool(true,  "Show forecast lines & labels",        group=G_FC)
projBars     = input.int(6,      "Projection length (bars)", minval=1, maxval=60, group=G_FC)
showBox      = input.bool(true,  "Shade forecast High–Low range",       group=G_FC)
showTrack    = input.bool(true,  "Plot historical High/Low predictions",group=G_FC)
lineW        = input.int(2,      "Forecast line width", minval=1, maxval=5, group=G_FC)

showNet      = input.bool(true,  "Show neural network map",             group=G_NN)
netOffset    = input.int(8,      "Map offset from last bar (bars)", minval=2, maxval=100, group=G_NN)
netColGap    = input.int(11,     "Column spacing (bars)",  minval=4, maxval=40, group=G_NN)
netHeight    = input.float(9.0,  "Map height (% of price)", minval=2.0, maxval=40.0, step=0.5, group=G_NN)
showEdges    = input.bool(true,  "Draw weighted connections",           group=G_NN)
showNodeVal  = input.bool(true,  "Show node values",                    group=G_NN)
edgeK        = input.float(6.0,  "Connection glow ×", minval=1.0, maxval=20.0, step=0.5, group=G_NN)

showDash     = input.bool(true,  "Show dashboard",                      group=G_DS)
dashPosIn    = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=G_DS)
dashSzIn     = input.string("Normal", "Dashboard size", options=["Tiny","Small","Normal"], group=G_DS)

themeIn      = input.string("Aurora", "Theme", options=["Aurora","Mono"], group=G_TH)

color cInput = themeIn == "Aurora" ? #1E7BFF : #4C8DFF
color cHid   = themeIn == "Aurora" ? #21D3C4 : #34C6E0
color cUp    = #24C08A
color cDn    = #FF4D6D
color cMid   = #F5B301
color cPos   = themeIn == "Aurora" ? #38BDF8 : #7FB2FF
color cNeg   = themeIn == "Aurora" ? #F472B6 : #E06A6A
color cDim   = #2A3346
color cTxt   = #E6EDF3
color cTxtMut= #8B94A6
color cPanel = color.new(#0D1117, 8)
color cPanel2= color.new(#161B22, 0)
color cHdr   = color.new(#0D1117, 0)
color cGrid  = color.new(#30363D, 30)

var W0 = array.from(-0.016437, -0.049519, -0.048021, 0.090770, 0.056462, 0.055741, -0.014619, 0.011218, 0.009433, -0.005029, 0.011325, -0.010975, -0.043614, -0.184092, -0.309350, 0.464082, 0.194277, 0.223950, -0.004933, 0.075567, -0.000487, 0.070679, 0.005761, -0.018558, -0.024455, -0.016671, -0.024296, 0.063582, 0.045213, 0.032457, 0.009682, 0.058880, 0.046494, -0.025372, -0.018548, -0.046886)
var B0 = array.from(0.483945, 0.019767, 0.298471, -0.558298, -0.280925, -0.229825)

var W1 = array.from(-0.006024, -0.038671, -0.000695, 0.074737, -0.027921, 0.003494, -0.148122, -0.161206, -0.049975, 0.084334, 0.041295, -0.004448, -0.167930, -0.200587, -0.057010, 0.180196, 0.002088, -0.006965, 0.239595, 0.311982, 0.092811, -0.229649, -0.009308, 0.005570, 0.100114, 0.134184, 0.041749, -0.141555, 0.002002, 0.017568, 0.139181, 0.174077, 0.044996, -0.101441, -0.020729, 0.001627)
var B1 = array.from(-0.275359, -0.225095, -0.313704, 0.118809, -0.554719, 0.686911)

var W2 = array.from(0.153436, 0.224378, 0.048825, 0.199323, -0.020802, -0.073807, 0.190941, 0.285684, 0.082872, 0.236279, -0.038708, -0.088554, 0.056669, 0.095064, 0.017878, 0.071278, -0.005834, -0.025291, -0.144312, -0.207242, -0.061443, -0.163340, 0.005235, 0.006768, -0.025966, 0.016969, -0.031211, -0.022361, -0.000707, 0.025661, 0.041593, -0.031020, 0.041194, 0.008008, 0.015720, -0.016676)
var B2 = array.from(0.113540, 0.108651, -0.730301, 0.191984, 0.629444, -0.904978)

var W3 = array.from(0.121509, 0.014769, 0.099316, 0.157540, 0.021358, 0.137839, 0.057456, -0.037051, -0.011098, 0.150178, 0.019466, 0.114424, -0.002781, 0.047883, 0.035443, -0.046171, -0.025780, -0.088955)
var B3 = array.from(0.604565, 0.433807, 0.028369)

f_tanh(float z) =>
    float zz = math.max(-20.0, math.min(20.0, z))
    float e  = math.exp(2.0 * zz)
    (e - 1.0) / (e + 1.0)

f_layer(array<float> a, array<float> W, array<float> B, int nin, int nout, bool act) =>
    array<float> o = array.new<float>(nout, 0.0)
    for j = 0 to nout - 1
        float z = array.get(B, j)
        for i = 0 to nin - 1
            z += array.get(a, i) * array.get(W, i * nout + j)
        array.set(o, j, act ? f_tanh(z) : z)
    o

rsiVal  = ta.rsi(close, 14)[1]
anchorC = close[1]

ret0 = close[1] / close[2] - 1.0
ret1 = close[2] / close[3] - 1.0
ret2 = close[3] / close[4] - 1.0
ret3 = close[4] / close[5] - 1.0
ret4 = close[5] / close[6] - 1.0

hi5   = ta.highest(high, 5)[1]
lo5   = ta.lowest(low, 5)[1]
stoch = hi5 > lo5 ? (close[1] - lo5) / (hi5 - lo5) : 0.5

rng0 = (high[1] - low[1]) / close[1]
rng1 = (high[2] - low[2]) / close[2]
rng2 = (high[3] - low[3]) / close[3]
rng3 = (high[4] - low[4]) / close[4]
rng4 = (high[5] - low[5]) / close[5]

bod0 = (close[1] - open[1]) / open[1]
bod1 = (close[2] - open[2]) / open[2]
bod2 = (close[3] - open[3]) / open[3]
bod3 = (close[4] - open[4]) / open[4]
bod4 = (close[5] - open[5]) / open[5]

f1 = (ret0 + ret1 + ret2 + ret3 + ret4) / 5.0
f2 = 2.0 * stoch - 1.0
f3 = (rsiVal - 50.0) / 50.0
f4 = (rng0 + rng1 + rng2 + rng3 + rng4) / 5.0
f5 = (bod0 + bod1 + bod2 + bod3 + bod4) / 5.0
f6 = (ret0 + ret1) / 2.0 - f1
ar = f4

mu1 = ta.sma(f1, 60)
sd1 = ta.stdev(f1, 60)
z1 = sd1 > 0 ? (f1 - mu1) / sd1 : 0.0
mu2 = ta.sma(f2, 60)
sd2 = ta.stdev(f2, 60)
z2 = sd2 > 0 ? (f2 - mu2) / sd2 : 0.0
mu3 = ta.sma(f3, 60)
sd3 = ta.stdev(f3, 60)
z3 = sd3 > 0 ? (f3 - mu3) / sd3 : 0.0
mu4 = ta.sma(f4, 60)
sd4 = ta.stdev(f4, 60)
z4 = sd4 > 0 ? (f4 - mu4) / sd4 : 0.0
mu5 = ta.sma(f5, 60)
sd5 = ta.stdev(f5, 60)
z5 = sd5 > 0 ? (f5 - mu5) / sd5 : 0.0
mu6 = ta.sma(f6, 60)
sd6 = ta.stdev(f6, 60)
z6 = sd6 > 0 ? (f6 - mu6) / sd6 : 0.0

ready = bar_index > 60 + 8 and not na(rsiVal) and not na(ret4) and not na(z1)

f_predict() =>
    array<float> xin = array.new<float>(6)
    array.set(xin, 0, z1)
    array.set(xin, 1, z2)
    array.set(xin, 2, z3)
    array.set(xin, 3, z4)
    array.set(xin, 4, z5)
    array.set(xin, 5, z6)
    array<float> a1 = f_layer(xin, W0, B0, 6, 6, true)
    array<float> a2 = f_layer(a1,  W1, B1, 6, 6, true)
    array<float> a3 = f_layer(a2,  W2, B2, 6, 6, true)
    array<float> op = f_layer(a3,  W3, B3, 6, 3, false)
    float yUp = array.get(op,0)
    float yDn = array.get(op,1)
    float yC  = array.get(op,2)
    float pH = anchorC * (1.0 + yUp * ar)
    float pL = anchorC * (1.0 - yDn * ar)
    float pC = anchorC * (1.0 + yC  * ar)
    [pH, pL, pC, xin, a1, a2, a3]

[predH, predL, predC, XIN, A1, A2, A3] = f_predict()

blUpU = ((high[1]-close[1])/close[1] + (high[2]-close[2])/close[2] + (high[3]-close[3])/close[3] + (high[4]-close[4])/close[4] + (high[5]-close[5])/close[5]) / 5.0
blDnU = ((close[1]-low[1])/close[1] + (close[2]-low[2])/close[2] + (close[3]-low[3])/close[3] + (close[4]-low[4])/close[4] + (close[5]-low[5])/close[5]) / 5.0
blH = anchorC * (1.0 + blUpU)
blL = anchorC * (1.0 - blDnU)

var float sumErrH = 0.0
var float sumErrL = 0.0
var float sumBlH  = 0.0
var float sumBlL  = 0.0
var int   nScored = 0
if barstate.isconfirmed and ready and not na(predH) and bar_index > 26
    sumErrH += math.abs(high - predH)
    sumErrL += math.abs(low  - predL)
    sumBlH  += math.abs(high - blH)
    sumBlL  += math.abs(low  - blL)
    nScored += 1
float maeH   = nScored > 0 ? sumErrH / nScored : na
float maeL   = nScored > 0 ? sumErrL / nScored : na
float blMaeH = nScored > 0 ? sumBlH  / nScored : na
float blMaeL = nScored > 0 ? sumBlL  / nScored : na

plot(showTrack and ready ? predH : na, "Pred High", color=color.new(cUp, 30), linewidth=1)
plot(showTrack and ready ? predL : na, "Pred Low",  color=color.new(cDn, 30), linewidth=1)

var array<line>  netLines = array.new<line>()
var array<label> netLabs  = array.new<label>()
var array<line>  fcLines  = array.new<line>()
var array<label> fcLabs   = array.new<label>()
var box          fcBox    = na

f_clearArr(array<line> la, array<label> lb) =>
    if array.size(la) > 0
        for i = 0 to array.size(la) - 1
            line.delete(array.get(la, i))
        array.clear(la)
    if array.size(lb) > 0
        for i = 0 to array.size(lb) - 1
            label.delete(array.get(lb, i))
        array.clear(lb)

centerY = close
spanH   = close * netHeight / 100.0
f_colY(int k, int cnt) => cnt <= 1 ? centerY : centerY + spanH / 2.0 - spanH * k / (cnt - 1)

f_node(int x, float y, color col, string val) =>
    label lb = label.new(x, y, "", xloc=xloc.bar_index, style=label.style_circle, color=col, size=size.normal)
    array.push(netLabs, lb)
    if showNodeVal and val != ""
        label vt = label.new(x, y, val, xloc=xloc.bar_index, style=label.style_none, textcolor=cTxt, size=size.tiny)
        array.push(netLabs, vt)

f_edges(int x0, array<float> src, int nin, int x1, array<float> W, int nout) =>
    for i = 0 to nin - 1
        float yi = f_colY(i, nin)
        float ai = array.get(src, i)
        for j = 0 to nout - 1
            float w = array.get(W, i * nout + j)
            float inten = math.min(1.0, math.abs(w * ai) * edgeK)
            int tp = math.round(66 - inten * 51)
            int lw = inten > 0.55 ? 2 : 1
            color col = w >= 0 ? color.new(cPos, tp) : color.new(cNeg, tp)
            line ln = line.new(x0, yi, x1, f_colY(j, nout), xloc=xloc.bar_index, color=col, width=lw)
            array.push(netLines, ln)

if barstate.islast and ready

    f_clearArr(fcLines, fcLabs)
    if not na(fcBox)
        box.delete(fcBox)
        fcBox := na
    if showForecast
        int xa = bar_index
        int xb = bar_index + projBars
        line lH = line.new(xa, predH, xb, predH, xloc=xloc.bar_index, color=cUp,  width=lineW, style=line.style_solid)
        line lL = line.new(xa, predL, xb, predL, xloc=xloc.bar_index, color=cDn,  width=lineW, style=line.style_solid)
        line lC = line.new(xa, predC, xb, predC, xloc=xloc.bar_index, color=cMid, width=1,     style=line.style_dashed)
        array.push(fcLines, lH)
        array.push(fcLines, lL)
        array.push(fcLines, lC)
        if showBox
            fcBox := box.new(xa, predH, xb, predL, xloc=xloc.bar_index, border_color=color.new(cMid, 60), border_width=1, bgcolor=color.new(cMid, 92))
        label tH = label.new(xb, predH, "▲ H  " + str.tostring(predH, "#.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cUp, 12), textcolor=#08131A, size=size.small)
        label tL = label.new(xb, predL, "▼ L  " + str.tostring(predL, "#.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cDn, 12), textcolor=#1A0810, size=size.small)
        label tC = label.new(xb, predC, "≈ C  " + str.tostring(predC, "#.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cMid, 20), textcolor=#1A1400, size=size.tiny)
        array.push(fcLabs, tH)
        array.push(fcLabs, tL)
        array.push(fcLabs, tC)

    f_clearArr(netLines, netLabs)
    if showNet
        int x0 = bar_index + netOffset
        int x1 = x0 + netColGap
        int x2 = x0 + netColGap * 2
        int x3 = x0 + netColGap * 3
        int x4 = x0 + netColGap * 4

        if showEdges
            f_edges(x0, XIN, 6, x1, W0, 6)
            f_edges(x1, A1,  6, x2, W1, 6)
            f_edges(x2, A2,  6, x3, W2, 6)
            f_edges(x3, A3,  6, x4, W3, 3)

        float yTop = centerY + spanH / 2.0 + spanH * 0.14
        label c0 = label.new(x0, yTop, "INPUT",  xloc=xloc.bar_index, style=label.style_none, textcolor=cInput, size=size.small)
        label c1 = label.new(x2, yTop, "HIDDEN ×3", xloc=xloc.bar_index, style=label.style_none, textcolor=cHid, size=size.small)
        label c4 = label.new(x4, yTop, "OUTPUT", xloc=xloc.bar_index, style=label.style_none, textcolor=cPos, size=size.small)
        array.push(netLabs, c0)
        array.push(netLabs, c1)
        array.push(netLabs, c4)

        fname = array.from("5D MOM", "RANGE POS", "RSI-50", "5D RNG%", "5D BODY", "ACCEL")
        for i = 0 to 5
            float z = array.get(XIN, i)
            color col = color.from_gradient(math.abs(z), 0.0, 2.5, color.new(cInput, 42), cInput)
            f_node(x0, f_colY(i, 6), col, str.tostring(z, "#.0"))
            label nm = label.new(x0 - math.round(netColGap * 0.42), f_colY(i, 6), array.get(fname, i), xloc=xloc.bar_index, style=label.style_none, textcolor=cTxtMut, size=size.tiny)
            array.push(netLabs, nm)

        for i = 0 to 5
            float a = array.get(A1, i)
            color col = color.from_gradient(math.abs(a), 0.0, 1.0, color.new(cHid, 45), cHid)
            f_node(x1, f_colY(i, 6), col, str.tostring(a, "#.0"))

        for i = 0 to 5
            float a = array.get(A2, i)
            color col = color.from_gradient(math.abs(a), 0.0, 1.0, color.new(cHid, 45), cHid)
            f_node(x2, f_colY(i, 6), col, str.tostring(a, "#.0"))

        for i = 0 to 5
            float a = array.get(A3, i)
            color col = color.from_gradient(math.abs(a), 0.0, 1.0, color.new(cHid, 45), cHid)
            f_node(x3, f_colY(i, 6), col, str.tostring(a, "#.0"))

        outCol = array.from(cUp, cDn, cMid)
        outNm  = array.from("HIGH", "LOW", "CLOSE")
        outVal = array.from(predH, predL, predC)
        for i = 0 to 2
            f_node(x4, f_colY(i, 3), array.get(outCol, i), "")
            label pv = label.new(x4 + math.round(netColGap * 0.30), f_colY(i, 3), array.get(outNm, i) + "\n" + str.tostring(array.get(outVal, i), "#.##"), xloc=xloc.bar_index, style=label.style_none, textcolor=array.get(outCol, i), size=size.small)
            array.push(netLabs, pv)

f_dpos() =>
    switch dashPosIn
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_dsz() =>
    switch dashSzIn
        "Tiny"  => size.tiny
        "Small" => size.small
        => size.normal

var table dash = table.new(f_dpos(), 2, 17, bgcolor=cPanel, border_color=cGrid, border_width=1, frame_color=cGrid, frame_width=1)
f_cell(int c, int r, string t, color tc, color bg) =>
    table.cell(dash, c, r, t, text_color=tc, text_size=f_dsz(), bgcolor=bg, text_halign = c == 0 ? text.align_left : text.align_right)
f_feat(int r, string nm, float z) =>
    color fc = z > 0.4 ? cUp : z < -0.4 ? cDn : cTxtMut
    f_cell(0, r, nm, cTxtMut, cPanel2)
    f_cell(1, r, str.tostring(z, "#.00") + "σ", fc, cPanel)
f_sgn(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##")

if showDash and barstate.islast
    bool okTF  = timeframe.period == "1D"
    bool okSym = str.contains(str.upper(syminfo.ticker), "XAU") or str.contains(str.upper(syminfo.ticker), "GOLD")
    f_cell(0, 0, "Strong Gold NN Forecast", cPos, cHdr)
    f_cell(1, 0, "6·6·6·6·3 MLP", cTxtMut, cHdr)
    f_cell(0, 1, "Setup", cTxtMut, cPanel2)
    f_cell(1, 1, (okSym ? "XAU " : "≠XAU ") + timeframe.period, okSym and okTF ? cUp : cMid, cPanel)
    f_cell(0, 2, "Anchor (prev close)", cTxtMut, cPanel2)
    f_cell(1, 2, str.tostring(anchorC, "#.##"), cTxt, cPanel)
    f_cell(0, 3, "── This Candle (frozen) ──", cTxtMut, cPanel2)
    f_cell(1, 3, "", cTxtMut, cPanel)
    f_cell(0, 4, "Pred HIGH", cTxtMut, cPanel2)
    f_cell(1, 4, str.tostring(predH, "#.##") + "  (" + f_sgn((predH/anchorC-1)*100) + "%)", cUp, cPanel)
    f_cell(0, 5, "Pred LOW", cTxtMut, cPanel2)
    f_cell(1, 5, str.tostring(predL, "#.##") + "  (" + f_sgn((predL/anchorC-1)*100) + "%)", cDn, cPanel)
    f_cell(0, 6, "Pred CLOSE", cTxtMut, cPanel2)
    f_cell(1, 6, str.tostring(predC, "#.##") + "  (" + f_sgn((predC/anchorC-1)*100) + "%)", cMid, cPanel)
    f_cell(0, 7, "Pred Range", cTxtMut, cPanel2)
    f_cell(1, 7, str.tostring(predH - predL, "#.##") + "  (" + str.tostring((predH-predL)/anchorC*100, "#.##") + "%)", cTxt, cPanel)
    f_cell(0, 8, "── Inputs (z) ──", cTxtMut, cPanel2)
    f_cell(1, 8, "RSI " + str.tostring(rsiVal, "#.0"), cTxtMut, cPanel)
    f_feat(9,  "5D Momentum", array.get(XIN,0))
    f_feat(10, "Range Pos",   array.get(XIN,1))
    f_feat(11, "RSI-50",      array.get(XIN,2))
    f_feat(12, "5D Range%",   array.get(XIN,3))
    f_feat(13, "5D Body%",    array.get(XIN,4))
    f_feat(14, "Accel",       array.get(XIN,5))
    f_cell(0, 15, "── Live Accuracy ──", cTxtMut, cPanel2)
    f_cell(1, 15, "n=" + str.tostring(nScored), cTxtMut, cPanel)
    color accCol = na(maeH) ? cTxtMut : (maeH < blMaeH and maeL < blMaeL) ? cUp : (maeH < blMaeH or maeL < blMaeL) ? cMid : cDn
    string accTxt = na(maeH) ? "warming up…" : "H " + str.tostring(maeH, "#.#") + " / L " + str.tostring(maeL, "#.#") + " $"
    f_cell(0, 16, "MAE vs base " + (na(blMaeH) ? "" : str.tostring((blMaeH+blMaeL)/2, "#.#")), cTxtMut, cPanel2)
    f_cell(1, 16, accTxt, accCol, cPanel)

alertcondition(barstate.isconfirmed and ready, "New Daily Forecast", "Gold NN: new next-day High/Low forecast ready")
````
