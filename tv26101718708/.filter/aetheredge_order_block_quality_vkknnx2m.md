# AetherEdge - Order Block Quality

- url: https://www.tradingview.com/script/VkKnnX2M/
- type: indicator
- pine_id: PUB;702085d9f756491f9576a8a85d717581
- version: 1.0

## Description

🖊️ Overview 

AE-OBQ does not just draw order blocks (OBs) — it learns and scores each one's quality = P(it holds and reacts), and applies the same learned model to scan a basket of symbols. Order blocks are not equal: some produce clean reactions, most do not. AE-OBQ learns the difference from the real outcome of past blocks (held / broken) and ranks which symbols currently show the highest-quality setups.

🔶 Key Features

Automatic order-block detection from a BOS plus strong displacement, drawn as zones
A quality score (ML) — online logistic learns P(hold and react) per OB; zone shading reflects quality
A multi-symbol screener — the identical learned model applied to up to 6 symbols, ranked by quality (symbol / bias / quality % / distance)
BUY/SELL signals on the first retest of a high-quality OB
ATR-normalized features so the learned quality model transfers across instruments
A gold HUD with active OB count, nearest OB's bias/quality/distance, and realized hold rate
OBs resolve on realized price — training and signals are no-repaint

🧠 Technical Architecture OB detection: 

when a break of the recent swing high/low (BOS) comes with strong displacement (body/ATR), the last opposing candle before it is taken as the order block and its high/low drawn as a zone. Quality model (ML): five features — OB size, displacement strength, trend alignment (higher trend vs OB direction), momentum, and formation volume ratio — are all ATR-normalized and bounded (no standardization layer), and an online logistic regression learns quality = P(hold and react). Each OB trains at resolution with its realized label (held = rejected after retest; broken = zone violated) — no lookahead. Because features are ATR-normalized, the same weights apply directly to other symbols. Screener: request.security fetches the same features for each symbol, and the chart-learned weights are applied as-is to produce a quality score. A selection sort ranks them descending; the chart symbol runs through the identical pipeline and appears first. Honest scope: a linear classifier over order-block features. Not deep learning, and not a guarantee of win rate.

⚙️ Recommended Settings & Tuning Guide 

Key parameters: structure length (swingLen), min displacement (body/ATR), quality threshold (qThr), resolve horizon (resN), screener symbols/timeframe.
Larger swingLen → only major BOS, focusing on important OBs; smaller → more detections
Raise min displacement → only blocks at the origin of forceful moves
Raise qThr → restrict highlights/signals to high-quality OBs
Crypto starting points (tune on your chart):
BTC / ETH (15m–4H): defaults are the baseline (swingLen 10, dispK 1.0, qThr 0.60)
SOL / XRP and high-vol alts: dispK 1.5 to exclude noisy OBs
Scalping (1–5m): swingLen ~5, shorter resN
Swing (4H–daily): swingLen 15+, longer resN to give the hold judgment room
Keep screener symbols within one asset class for stable quality comparison

💡 How to Use in Practice

Trade reactions off OBs: buy the dip when price returns to a high-quality bullish OB, sell the rally into a bearish one
Reading quality: a darker zone means the model rates it high quality; faint OBs are skip candidates
Hold rate: the share of OBs that actually held on this symbol/settings — a gauge of the model's reliability in that context
Use the screener: see at a glance which watchlist symbols currently rate highest, and focus on nearby high-quality OBs
Combinations: pair with AE-AMF's big-picture momentum or AE-FAM's anomaly detection, and use OBQ's quality to prioritize entry zones

⚠️ Important Notes

Learning period: no signals until warmup bars; the model needs enough resolved OBs to learn
Learning reset: changing inputs, symbol, or timeframe re-learns the weights
Screener granularity: the screener is a multi-symbol radar and computes each symbol's features with compact approximations (the chart symbol is the most precise) — confirm by charting the target symbol
Probability, not a guarantee: even high-quality OBs can break — use stops and position sizing

🚨 Disclaimer 

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Order Block Quality  (AE-OBQ)  |  AetherEdge Series
//  Order blocks scored by a LEARNED quality model + a multi-symbol screener
//
//  Most order-block tools draw every block the same. But blocks are not equal --
//  some hold and produce clean reactions, most do not. AE-OBQ learns the
//  difference and ranks symbols by it:
//
//    * ML : an ONLINE LOGISTIC REGRESSION scores each order block's quality =
//      P(it holds and reacts) from block size, displacement strength, trend
//      alignment, momentum and participation. It trains on the realized outcome
//      of past blocks (held / broken), so the score is earned, not assumed.
//      Features are ATR-normalized and bounded, so the SAME learned weights
//      transfer across instruments.
//
//    * Screener : the identical model is applied to a basket of symbols via
//      request.security, ranking which ones currently show the highest-quality
//      block setups and how far price sits from each zone.
//
//  Honest scope: a linear classifier over order-block features -- not a neural
//  net, not a guarantee. No-repaint: blocks resolve on realized price, training
//  and signals gate on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Order Block Quality", "AE-OBQ", overlay = true, max_boxes_count = 500, max_labels_count = 300)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cWait    = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpOB = "Order block detection"
swingLen = input.int(10, "Structure length", minval = 2, group = grpOB, tooltip = "A break of the highest high / lowest low over this window is a BOS.")
obLook   = input.int(10, "Origin lookback", minval = 1, group = grpOB, tooltip = "How far back to find the last opposing candle (the order block).")
dispK    = input.float(1.0, "Min displacement (body/ATR)", minval = 0.1, step = 0.1, group = grpOB)
atrLen   = input.int(14, "ATR length", minval = 1, group = grpOB)
maxOB    = input.int(8, "Max active blocks", minval = 1, maxval = 20, group = grpOB)

grpML = "Quality model"
lr      = input.float(0.03, "Learning rate", minval = 0.0001, step = 0.005, group = grpML)
l2      = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpML)
resN    = input.int(30, "Resolve horizon (bars)", minval = 2, group = grpML, tooltip = "A block is judged held / broken within this many bars of forming.")
warmup  = input.int(120, "Warmup bars", minval = 20, group = grpML)
qThr    = input.float(0.60, "Quality threshold", minval = 0.5, maxval = 0.95, step = 0.01, group = grpML)

grpScr = "Screener (same learned model, other symbols)"
useScr  = input.bool(true, "Show screener", group = grpScr)
scrTF   = input.timeframe("", "Screener timeframe", group = grpScr)
sym1 = input.symbol("BINANCE:BTCUSDT", "Symbol 1", group = grpScr)
sym2 = input.symbol("BINANCE:ETHUSDT", "Symbol 2", group = grpScr)
sym3 = input.symbol("BINANCE:SOLUSDT", "Symbol 3", group = grpScr)
sym4 = input.symbol("BINANCE:XRPUSDT", "Symbol 4", group = grpScr)
sym5 = input.symbol("", "Symbol 5", group = grpScr)
sym6 = input.symbol("", "Symbol 6", group = grpScr)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))
f_tanh(float x) => 2.0 / (1.0 + math.exp(-2.0 * f_clamp(x, -10.0, 10.0))) - 1.0

f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    f_sigmoid(z)

f_train(array<float> w, array<float> x, float y, float lrr, float l2r) =>
    p   = f_predict(w, x)
    err = p - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        g = err * array.get(x, i) + l2r * array.get(w, i + 1)
        array.set(w, i + 1, array.get(w, i + 1) - lrr * g)

// Order-block feature builder (ATR-normalized, bounded -> transfers across symbols).
// Evaluated both on-chart and inside request.security. Returns dir + 5 features + distance.
f_scan() =>
    atrS = math.max(ta.atr(atrLen), 1e-8)
    bUp = ta.crossover(close, ta.highest(high, swingLen)[1])
    bDn = ta.crossunder(close, ta.lowest(low, swingLen)[1])
    var int   d   = 0
    var float oH  = na
    var float oP  = na
    var float oV  = na
    if bUp
        d := 1
        oH := high[1] - low[1]
        oP := low[1]
        oV := volume[1]
    if bDn
        d := -1
        oH := high[1] - low[1]
        oP := high[1]
        oV := volume[1]
    obSize = f_clamp(nz(oH) / atrS, 0.0, 10.0)
    dispStr = f_clamp(math.abs(close - open) / atrS, 0.0, 10.0)
    trendAlign = f_clamp(f_tanh((ta.ema(close, 50) - ta.ema(close, 200)) / atrS) * d, -3.0, 3.0)
    mom = f_clamp((ta.rsi(close, 14) - 50.0) / 50.0 * d, -1.0, 1.0)
    volRel = f_clamp(nz(oV) / math.max(ta.sma(volume, 20), 1e-8), 0.0, 5.0)
    dist = na(oP) ? 5.0 : f_clamp(math.abs(close - oP) / atrS, 0.0, 10.0)
    [d, obSize, dispStr, trendAlign, mom, volRel, dist]

f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

// ----------------------------------------------------------------------------
//  TYPES
// ----------------------------------------------------------------------------
type OB
    bool         dirUp
    float        top
    float        bot
    int          bornBar
    array<float> feat
    float        quality
    bool         retested
    bool         signaled
    bool         resolved
    box          bx

// ----------------------------------------------------------------------------
//  CHART: DETECTION + QUALITY MODEL
// ----------------------------------------------------------------------------
int NF = 5
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

var array<float> wOB = array.new_float(NF + 1, 0.0)
var array<OB> obs = array.new<OB>()
var int wins = 0
var int totalRes = 0

bosUp = ta.crossover(close, ta.highest(high, swingLen)[1])
bosDn = ta.crossunder(close, ta.lowest(low, swingLen)[1])
dispOK = (math.abs(close - open) / atrSafe) > dispK

// Build the standardized-ish feature vector for a forming OB of direction dir at origin index oi.
f_obFeat(int dir, int oi) =>
    top = high[oi]
    bot = low[oi]
    obSize = f_clamp((top - bot) / atrSafe, 0.0, 10.0)
    dispStr = f_clamp(math.abs(close - open) / atrSafe, 0.0, 10.0)
    trendAlign = f_clamp(f_tanh((ta.ema(close, 50) - ta.ema(close, 200)) / atrSafe) * dir, -3.0, 3.0)
    mom = f_clamp((ta.rsi(close, 14) - 50.0) / 50.0 * dir, -1.0, 1.0)
    volRel = f_clamp(volume[oi] / math.max(ta.sma(volume, 20), 1e-8), 0.0, 5.0)
    array.from(obSize, dispStr, trendAlign, mom, volRel)

if barstate.isconfirmed and dispOK and (bosUp or bosDn)
    dir = bosUp ? 1 : -1
    int oi = -1
    for i = 1 to obLook
        if (dir == 1 and close[i] < open[i]) or (dir == -1 and close[i] > open[i])
            oi := i
            break
    if oi >= 0
        ft = f_obFeat(dir, oi)
        q  = f_predict(wOB, ft)
        col = dir == 1 ? cBull : cBear
        bx = box.new(bar_index - oi, high[oi], bar_index, low[oi], xloc = xloc.bar_index, border_color = color.new(col, 40), bgcolor = color.new(col, 80 + int(15 * (1 - q))))
        array.push(obs, OB.new(dir == 1, high[oi], low[oi], bar_index, ft, q, false, false, false, bx))
        if array.size(obs) > maxOB
            old = array.shift(obs)
            box.delete(old.bx)

// Resolve + train, extend boxes.
bool longSig  = false
bool shortSig = false
if barstate.isconfirmed and array.size(obs) > 0
    for i = array.size(obs) - 1 to 0
        ob = array.get(obs, i)
        box.set_right(ob.bx, bar_index + 2)
        if not ob.resolved
            age = bar_index - ob.bornBar
            if ob.dirUp
                if not ob.retested and low <= ob.top
                    ob.retested := true
                    if ob.quality >= qThr and not ob.signaled
                        ob.signaled := true
                        longSig := true
                if close < ob.bot
                    f_train(wOB, ob.feat, 0.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    box.set_bgcolor(ob.bx, color.new(cBear, 92))
                else if ob.retested and close > ob.top
                    f_train(wOB, ob.feat, 1.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    wins += 1
                else if age >= resN
                    f_train(wOB, ob.feat, ob.retested ? 1.0 : 0.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    wins += ob.retested ? 1 : 0
            else
                if not ob.retested and high >= ob.bot
                    ob.retested := true
                    if ob.quality >= qThr and not ob.signaled
                        ob.signaled := true
                        shortSig := true
                if close > ob.top
                    f_train(wOB, ob.feat, 0.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    box.set_bgcolor(ob.bx, color.new(cBear, 92))
                else if ob.retested and close < ob.bot
                    f_train(wOB, ob.feat, 1.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    wins += 1
                else if age >= resN
                    f_train(wOB, ob.feat, ob.retested ? 1.0 : 0.0, lr, l2)
                    ob.resolved := true
                    totalRes += 1
                    wins += ob.retested ? 1 : 0

warmOK = bar_index > warmup
longSig  := longSig and warmOK
shortSig := shortSig and warmOK

// Nearest active block (for HUD).
float nearDist = na
float nearQ = na
bool  nearBull = true
if array.size(obs) > 0
    for i = 0 to array.size(obs) - 1
        ob = array.get(obs, i)
        if not ob.resolved
            mid = (ob.top + ob.bot) / 2.0
            dst = math.abs(close - mid) / atrSafe
            if na(nearDist) or dst < nearDist
                nearDist := dst
                nearQ := ob.quality
                nearBull := ob.dirUp

// ----------------------------------------------------------------------------
//  SIGNALS PLOT
// ----------------------------------------------------------------------------
plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "OB", textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "OB", textcolor = cBear)

// ----------------------------------------------------------------------------
//  SCREENER  (same learned model on other symbols)
// ----------------------------------------------------------------------------
f_q(int d, float a, float b, float c, float e, float f) =>
    f_predict(wOB, array.from(a, b, c, e, f))

[cd, ca, cb, cc, ce, cf, cdist] = f_scan()                                  // chart symbol (local)

[d1, a1, b1, c1, e1, f1, g1] = request.security(sym1, scrTF, f_scan(), lookahead = barmerge.lookahead_off)
[d2, a2, b2, c2, e2, f2, g2] = request.security(sym2, scrTF, f_scan(), lookahead = barmerge.lookahead_off)
[d3, a3, b3, c3, e3, f3, g3] = request.security(sym3, scrTF, f_scan(), lookahead = barmerge.lookahead_off)
[d4, a4, b4, c4, e4, f4, g4] = request.security(sym4, scrTF, f_scan(), lookahead = barmerge.lookahead_off)
[d5, a5, b5, c5, e5, f5, g5] = request.security(sym5, scrTF, f_scan(), lookahead = barmerge.lookahead_off)
[d6, a6, b6, c6, e6, f6, g6] = request.security(sym6, scrTF, f_scan(), lookahead = barmerge.lookahead_off)

f_tk(string s) =>
    p = str.pos(s, ":")
    s == "" ? "" : na(p) ? s : str.substring(s, p + 1)

var array<string> scName = array.new_string(0)
var array<float>  scQ    = array.new_float(0)
var array<int>    scDir   = array.new_int(0)
var array<float>  scDist  = array.new_float(0)

if barstate.islast and useScr
    array.clear(scName)
    array.clear(scQ)
    array.clear(scDir)
    array.clear(scDist)
    array.push(scName, f_tk(syminfo.tickerid))
    array.push(scQ, f_q(cd, ca, cb, cc, ce, cf))
    array.push(scDir, cd)
    array.push(scDist, cdist)
    if sym1 != ""
        array.push(scName, f_tk(sym1))
        array.push(scQ, f_q(d1, a1, b1, c1, e1, f1))
        array.push(scDir, d1)
        array.push(scDist, g1)
    if sym2 != ""
        array.push(scName, f_tk(sym2))
        array.push(scQ, f_q(d2, a2, b2, c2, e2, f2))
        array.push(scDir, d2)
        array.push(scDist, g2)
    if sym3 != ""
        array.push(scName, f_tk(sym3))
        array.push(scQ, f_q(d3, a3, b3, c3, e3, f3))
        array.push(scDir, d3)
        array.push(scDist, g3)
    if sym4 != ""
        array.push(scName, f_tk(sym4))
        array.push(scQ, f_q(d4, a4, b4, c4, e4, f4))
        array.push(scDir, d4)
        array.push(scDist, g4)
    if sym5 != ""
        array.push(scName, f_tk(sym5))
        array.push(scQ, f_q(d5, a5, b5, c5, e5, f5))
        array.push(scDir, d5)
        array.push(scDist, g5)
    if sym6 != ""
        array.push(scName, f_tk(sym6))
        array.push(scQ, f_q(d6, a6, b6, c6, e6, f6))
        array.push(scDir, d6)
        array.push(scDist, g6)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
var table hud = table.new(position.top_right, 2, 7, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    winR = totalRes > 0 ? wins / totalRes : na
    table.cell(hud, 0, 0, "AE-OBQ", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "OB QUALITY", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Active OBs", text_color = cTxt, text_size = ts)
    int act = 0
    if array.size(obs) > 0
        for i = 0 to array.size(obs) - 1
            act += array.get(obs, i).resolved ? 0 : 1
    table.cell(hud, 1, 1, str.tostring(act), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 2, "Nearest",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, na(nearQ) ? "-" : (nearBull ? "BULL" : "BEAR"), text_color = na(nearQ) ? cWait : nearBull ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 3, "Quality",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, na(nearQ) ? "-" : str.tostring(math.round(nearQ * 100)) + "%", text_color = na(nearQ) ? cWait : nearQ >= qThr ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 4, "Distance",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, na(nearDist) ? "-" : str.tostring(nearDist, "#.#") + " ATR", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Hold rate", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, na(winR) ? "-" : str.tostring(math.round(winR * 100)) + "% (" + str.tostring(totalRes) + ")", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 6, "Model",     text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 6, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  SCREENER TABLE  (ranked by quality)
// ----------------------------------------------------------------------------
var table scr = table.new(position.bottom_right, 4, 8, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if useScr and barstate.islast and array.size(scName) > 0
    ts = f_txtSize()
    table.cell(scr, 0, 0, "SCREENER", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(scr, 1, 0, "Bias", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(scr, 2, 0, "Quality", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(scr, 3, 0, "Dist", text_color = cGold, bgcolor = cBg0, text_size = ts)
    // selection sort by quality (desc), <=7 rows
    int n = array.size(scName)
    order = array.new_int(0)
    for i = 0 to n - 1
        array.push(order, i)
    for i = 0 to n - 2
        best = i
        for j = i + 1 to n - 1
            if array.get(scQ, array.get(order, j)) > array.get(scQ, array.get(order, best))
                best := j
        tmp = array.get(order, i)
        array.set(order, i, array.get(order, best))
        array.set(order, best, tmp)
    rows = math.min(n, 7)
    for r = 0 to rows - 1
        idx = array.get(order, r)
        q = array.get(scQ, idx)
        di = array.get(scDir, idx)
        table.cell(scr, 0, r + 1, array.get(scName, idx), text_color = cTxt, text_size = ts)
        table.cell(scr, 1, r + 1, di > 0 ? "UP" : di < 0 ? "DN" : "-", text_color = di > 0 ? cBull : di < 0 ? cBear : cWait, text_size = ts)
        table.cell(scr, 2, r + 1, str.tostring(math.round(q * 100)) + "%", text_color = q >= qThr ? cBull : cTxt, text_size = ts)
        table.cell(scr, 3, r + 1, str.tostring(array.get(scDist, idx), "#.#"), text_color = cTxt, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-OBQ Long",  "AE-OBQ high-quality bullish block retest")
alertcondition(shortSig, "AE-OBQ Short", "AE-OBQ high-quality bearish block retest")

if longSig
    alert("AE-OBQ BUY | quality " + str.tostring(math.round(nz(nearQ) * 100)) + "%", alert.freq_once_per_bar_close)
if shortSig
    alert("AE-OBQ SELL | quality " + str.tostring(math.round(nz(nearQ) * 100)) + "%", alert.freq_once_per_bar_close)
````
