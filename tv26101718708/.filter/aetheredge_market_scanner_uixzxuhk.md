# AetherEdge - Market Scanner

- url: https://www.tradingview.com/script/uIXZXUhk/
- type: indicator
- pine_id: PUB;363b98df3afb4d388900a71c42452c8e
- version: 1.0

## Description

🖊️ Overview

AE-SCAN scans a basket of symbols and ranks them by a learned opportunity score and direction. The score isn't a hand-weighted formula — it's computed from weights learned online on the chart symbol's realized outcomes, and the same model applies to every scanned symbol because the features are ATR-normalized. A heatmap shows at a glance where the action is.

🔶 Key Features

Learned ranking — learns which factors matter now and sorts by opportunity score
Opportunity score — P(a ≥ k·ATR move within N bars) = how likely it is to move
Direction tag — a separate model learns P(up), shown as ▲/▼
Heatmap — each cell colored by score × direction (strong buy = deep green, strong sell = deep red)
Long/short filter and % change
Alert when a strong new opportunity tops the list
N-bar-lagged, bar-close training — no repaint

🧠 Technical Architecture

Features (f_scan): six ATR-normalized features computable in any symbol's context (trend, momentum, range compression, volatility regime, volume surge, position in range) plus % change.
ML (two online logistic regressions): trained on the chart symbol's N-bar-forward outcomes — an opportunity model = P(|N-bar move| ≥ k·ATR) and a direction model = P(up). Labels are N-bar-lagged, so no future data is used. Because features are ATR-normalized, the learned weights transfer across symbols (one model scores them all), and each scanned symbol is read with lookahead disabled.
Ranking: scores are recomputed each bar, sorted descending, and filtered (All/Long/Short) for display.
Honest scope: ranking by two linear classifiers over standard features (this tool uses no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: scan timeframe, opportunity horizon N, move size (k·ATR), learning rate, rows shown, alert threshold, symbol list.
N / k·ATR define what counts as an opportunity (smaller for short-term, larger for swing)
Pin the scan timeframe higher to rank by a higher timeframe regardless of your chart
Guide: crypto 15m–1H defaults (N=10, k=2.0); keep symbols within one asset class for stable comparison
Defaults are 16 major BINANCE pairs; swap any in the inputs (blank = skipped)
⚠️ TradingView caps the number of referenced symbols (security calls); be careful if you add many more

💡 How to Use in Practice

Top scores = most likely to move; use the ▲/▼ to pick long or short candidates
Set the filter to Long for bullish-only, Short for bearish-only
Check the deepest-colored symbols first
Use the alert to catch the moment a strong opportunity newly tops the list
Combine with single-symbol precision tools (AE-ACE / AE-BPE / AE-AVP, etc.) to dig in

⚠️ Important Notes

Needs a learning period (warmup); weights re-learn on parameter/timeframe change
The score is a probability of move size, not a guarantee of direction (direction is a separate model)
More scanned symbols means more computation
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Market Scanner  (AE-SCAN)  |  AetherEdge Series
//  Ranks a basket of symbols by a LEARNED opportunity score
//
//  A scanner is only as good as its scoring. Instead of a hand-weighted formula,
//  AE-SCAN learns the weights from realized outcomes and applies the same model
//  across every symbol:
//
//    * ML : two ONLINE LOGISTIC REGRESSIONS, trained on the CHART symbol's
//      realized N-bar outcomes, learn (1) an OPPORTUNITY score = P(a move of
//      >= k*ATR occurs within N bars) and (2) DIRECTION = P(up). Because the six
//      features are ATR-normalized, the learned weights transfer, so the same
//      model scores every scanned symbol (no lookahead -- labels are N-bar
//      lagged; cross-symbol reads use lookahead_off).
//
//  Symbols are ranked high-to-low by opportunity, coloured as a heatmap, tagged
//  with direction and % change, filterable to longs/shorts, with an alert when a
//  strong new opportunity tops the list. Honest scope: linear classifiers over
//  standard features -- not a neural net, not a guarantee. Training gates on bar
//  close.
// ============================================================================

//@version=6
indicator("AetherEdge - Market Scanner", "AE-SCAN", overlay = true)

// ----------------------------------------------------------------------------
//  THEME
// ----------------------------------------------------------------------------
cGold = #d4af37
cBg0  = #080b0a
cBg1  = #0f1614
cTxt  = #eef2f0
cBull = #26a69a
cBear = #ef5350
cWait = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpM = "Scanner model"
scanTF = input.timeframe("", "Scan timeframe", group = grpM)
horizon = input.int(10, "Opportunity horizon N (bars)", minval = 2, group = grpM)
kMove   = input.float(2.0, "Move size (ATR)", minval = 0.5, step = 0.1, group = grpM)
lr      = input.float(0.02, "Learning rate", minval = 0.0001, step = 0.005, group = grpM)
l2reg       = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpM)
warmup  = input.int(150, "Warmup bars", minval = 20, group = grpM)

grpF = "Display"
filterMode = input.string("All", "Filter", options = ["All","Long","Short"], group = grpF)
maxRows  = input.int(17, "Rows shown", minval = 3, maxval = 40, group = grpF)
alertThr = input.float(70, "Alert when top score >=", minval = 1, maxval = 100, group = grpF)
hudSize  = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpF)
tblPos   = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left","middle_right"], group = grpF)

grpS = "Symbols"
sym1  = input.symbol("BINANCE:BTCUSDT",  "01", group = grpS)
sym2  = input.symbol("BINANCE:ETHUSDT",  "02", group = grpS)
sym3  = input.symbol("BINANCE:SOLUSDT",  "03", group = grpS)
sym4  = input.symbol("BINANCE:XRPUSDT",  "04", group = grpS)
sym5  = input.symbol("BINANCE:BNBUSDT",  "05", group = grpS)
sym6  = input.symbol("BINANCE:ADAUSDT",  "06", group = grpS)
sym7  = input.symbol("BINANCE:DOGEUSDT", "07", group = grpS)
sym8  = input.symbol("BINANCE:AVAXUSDT", "08", group = grpS)
sym9  = input.symbol("BINANCE:LINKUSDT", "09", group = grpS)
sym10 = input.symbol("BINANCE:DOTUSDT",  "10", group = grpS)
sym11 = input.symbol("BINANCE:LTCUSDT",  "11", group = grpS)
sym12 = input.symbol("BINANCE:ATOMUSDT", "12", group = grpS)
sym13 = input.symbol("BINANCE:NEARUSDT", "13", group = grpS)
sym14 = input.symbol("BINANCE:APTUSDT",  "14", group = grpS)
sym15 = input.symbol("BINANCE:INJUSDT",  "15", group = grpS)
sym16 = input.symbol("BINANCE:TIAUSDT",  "16", group = grpS)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))
f_tanh(float x) => 2.0 / (1.0 + math.exp(-2.0 * f_clamp(x, -10.0, 10.0))) - 1.0
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal
f_pos() => tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : tblPos == "bottom_left" ? position.bottom_left : tblPos == "middle_right" ? position.middle_right : position.top_right
f_tk(string s) =>
    p = str.pos(s, ":")
    s == "" ? "" : na(p) ? s : str.substring(s, p + 1)
f_pass(float dir) => filterMode == "All" or (filterMode == "Long" and dir >= 0.5) or (filterMode == "Short" and dir < 0.5)

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

// ATR-normalized feature set (computed in any symbol's context)
f_scan() =>
    eF = ta.ema(close, 21)
    eS = ta.ema(close, 50)
    rsi = ta.rsi(close, 14)
    a = math.max(ta.atr(14), 1e-8)
    hh = ta.highest(high, 20)
    ll = ta.lowest(low, 20)
    mid = (hh + ll) / 2.0
    f1 = f_clamp(f_tanh((eF - eS) / a), -1.0, 1.0)
    f2 = f_clamp((rsi - 50.0) / 50.0, -1.0, 1.0)
    f3 = f_clamp(1.0 - ta.sma(high - low, 5) / math.max(ta.sma(high - low, 20), 1e-8), -1.0, 1.0)
    f4 = f_clamp(a / math.max(ta.sma(a, 50), 1e-8) - 1.0, -1.0, 2.0)
    f5 = f_clamp(volume / math.max(ta.sma(volume, 20), 1e-8) - 1.0, -1.0, 3.0)
    f6 = f_clamp((close - mid) / a, -3.0, 3.0)
    chg = (close / close[20] - 1.0) * 100.0
    [f1, f2, f3, f4, f5, f6, chg]

// ----------------------------------------------------------------------------
//  CHART-SYMBOL LEARNING  (trains the two models; weights transfer to all)
// ----------------------------------------------------------------------------
var array<float> wMove = array.new_float(7, 0.0)
var array<float> wDir  = array.new_float(7, 0.0)

[c1, c2, c3, c4, c5, c6, cChg] = f_scan()
atrC = math.max(ta.atr(14), 1e-8)
warmOK = bar_index > warmup

if barstate.isconfirmed and bar_index > horizon
    fl = array.from(c1[horizon], c2[horizon], c3[horizon], c4[horizon], c5[horizon], c6[horizon])
    netMove = (close - close[horizon]) / atrC
    bigMove = math.abs(netMove) >= kMove
    f_train(wMove, fl, bigMove ? 1.0 : 0.0, lr, l2reg)
    f_train(wDir, fl, close > close[horizon] ? 1.0 : 0.0, lr, l2reg)

chartScore = f_predict(wMove, array.from(c1, c2, c3, c4, c5, c6)) * 100.0
chartDir   = f_predict(wDir, array.from(c1, c2, c3, c4, c5, c6))

// ----------------------------------------------------------------------------
//  FETCH + SCORE EACH SYMBOL
// ----------------------------------------------------------------------------
[a1, a2, a3, a4, a5, a6, ac] = request.security(sym1  == "" ? syminfo.tickerid : sym1,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[b1, b2, b3, b4, b5, b6, bc] = request.security(sym2  == "" ? syminfo.tickerid : sym2,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[d1, d2, d3, d4, d5, d6, dc] = request.security(sym3  == "" ? syminfo.tickerid : sym3,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[e1, e2, e3, e4, e5, e6, ecg] = request.security(sym4 == "" ? syminfo.tickerid : sym4,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[g1, g2, g3, g4, g5, g6, gc] = request.security(sym5  == "" ? syminfo.tickerid : sym5,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[h1, h2, h3, h4, h5, h6, hc] = request.security(sym6  == "" ? syminfo.tickerid : sym6,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[i1, i2, i3, i4, i5, i6, icg] = request.security(sym7 == "" ? syminfo.tickerid : sym7,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[j1, j2, j3, j4, j5, j6, jc] = request.security(sym8  == "" ? syminfo.tickerid : sym8,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[k1, k2, k3, k4, k5, k6, kc] = request.security(sym9  == "" ? syminfo.tickerid : sym9,  scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[l1, l2, l3, l4, l5, l6, lc] = request.security(sym10 == "" ? syminfo.tickerid : sym10, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[m1, m2, m3, m4, m5, m6, mc] = request.security(sym11 == "" ? syminfo.tickerid : sym11, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[n1, n2, n3, n4, n5, n6, ncg] = request.security(sym12 == "" ? syminfo.tickerid : sym12, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[o1, o2, o3, o4, o5, o6, oc] = request.security(sym13 == "" ? syminfo.tickerid : sym13, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[p1, p2, p3, p4, p5, p6, pc] = request.security(sym14 == "" ? syminfo.tickerid : sym14, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[q1, q2, q3, q4, q5, q6, qc] = request.security(sym15 == "" ? syminfo.tickerid : sym15, scanTF, f_scan(), lookahead = barmerge.lookahead_off)
[r1, r2, r3, r4, r5, r6, rc] = request.security(sym16 == "" ? syminfo.tickerid : sym16, scanTF, f_scan(), lookahead = barmerge.lookahead_off)

sA = f_predict(wMove, array.from(a1, a2, a3, a4, a5, a6)) * 100.0
sB = f_predict(wMove, array.from(b1, b2, b3, b4, b5, b6)) * 100.0
sD = f_predict(wMove, array.from(d1, d2, d3, d4, d5, d6)) * 100.0
sE = f_predict(wMove, array.from(e1, e2, e3, e4, e5, e6)) * 100.0
sG = f_predict(wMove, array.from(g1, g2, g3, g4, g5, g6)) * 100.0
sH = f_predict(wMove, array.from(h1, h2, h3, h4, h5, h6)) * 100.0
sI = f_predict(wMove, array.from(i1, i2, i3, i4, i5, i6)) * 100.0
sJ = f_predict(wMove, array.from(j1, j2, j3, j4, j5, j6)) * 100.0
sK = f_predict(wMove, array.from(k1, k2, k3, k4, k5, k6)) * 100.0
sL = f_predict(wMove, array.from(l1, l2, l3, l4, l5, l6)) * 100.0
sM = f_predict(wMove, array.from(m1, m2, m3, m4, m5, m6)) * 100.0
sN = f_predict(wMove, array.from(n1, n2, n3, n4, n5, n6)) * 100.0
sO = f_predict(wMove, array.from(o1, o2, o3, o4, o5, o6)) * 100.0
sP = f_predict(wMove, array.from(p1, p2, p3, p4, p5, p6)) * 100.0
sQ = f_predict(wMove, array.from(q1, q2, q3, q4, q5, q6)) * 100.0
sR = f_predict(wMove, array.from(r1, r2, r3, r4, r5, r6)) * 100.0

dA = f_predict(wDir, array.from(a1, a2, a3, a4, a5, a6))
dB = f_predict(wDir, array.from(b1, b2, b3, b4, b5, b6))
dD = f_predict(wDir, array.from(d1, d2, d3, d4, d5, d6))
dE = f_predict(wDir, array.from(e1, e2, e3, e4, e5, e6))
dG = f_predict(wDir, array.from(g1, g2, g3, g4, g5, g6))
dH = f_predict(wDir, array.from(h1, h2, h3, h4, h5, h6))
dI = f_predict(wDir, array.from(i1, i2, i3, i4, i5, i6))
dJ = f_predict(wDir, array.from(j1, j2, j3, j4, j5, j6))
dK = f_predict(wDir, array.from(k1, k2, k3, k4, k5, k6))
dL = f_predict(wDir, array.from(l1, l2, l3, l4, l5, l6))
dM = f_predict(wDir, array.from(m1, m2, m3, m4, m5, m6))
dN = f_predict(wDir, array.from(n1, n2, n3, n4, n5, n6))
dO = f_predict(wDir, array.from(o1, o2, o3, o4, o5, o6))
dP = f_predict(wDir, array.from(p1, p2, p3, p4, p5, p6))
dQ = f_predict(wDir, array.from(q1, q2, q3, q4, q5, q6))
dR = f_predict(wDir, array.from(r1, r2, r3, r4, r5, r6))

// ----------------------------------------------------------------------------
//  BUILD RANKING  (each bar; honors the long/short filter)
// ----------------------------------------------------------------------------
var array<string> nm = array.new_string(0)
var array<float>  sc = array.new_float(0)
var array<float>  dr = array.new_float(0)
var array<float>  cg = array.new_float(0)

f_add(array<string> nmA, array<float> scA, array<float> drA, array<float> cgA, string name, float score, float dir, float chg) =>
    if name != "" and f_pass(dir)
        array.push(nmA, f_tk(name))
        array.push(scA, score)
        array.push(drA, dir)
        array.push(cgA, chg)

if barstate.isconfirmed or barstate.islast
    array.clear(nm)
    array.clear(sc)
    array.clear(dr)
    array.clear(cg)
    f_add(nm, sc, dr, cg, sym1, sA, dA, ac)
    f_add(nm, sc, dr, cg, sym2, sB, dB, bc)
    f_add(nm, sc, dr, cg, sym3, sD, dD, dc)
    f_add(nm, sc, dr, cg, sym4, sE, dE, ecg)
    f_add(nm, sc, dr, cg, sym5, sG, dG, gc)
    f_add(nm, sc, dr, cg, sym6, sH, dH, hc)
    f_add(nm, sc, dr, cg, sym7, sI, dI, icg)
    f_add(nm, sc, dr, cg, sym8, sJ, dJ, jc)
    f_add(nm, sc, dr, cg, sym9, sK, dK, kc)
    f_add(nm, sc, dr, cg, sym10, sL, dL, lc)
    f_add(nm, sc, dr, cg, sym11, sM, dM, mc)
    f_add(nm, sc, dr, cg, sym12, sN, dN, ncg)
    f_add(nm, sc, dr, cg, sym13, sO, dO, oc)
    f_add(nm, sc, dr, cg, sym14, sP, dP, pc)
    f_add(nm, sc, dr, cg, sym15, sQ, dQ, qc)
    f_add(nm, sc, dr, cg, sym16, sR, dR, rc)

// order = indices sorted by score desc (selection sort; guarded for n<=1)
var array<int> order = array.new_int(0)
int n = array.size(nm)
array.clear(order)
if n > 0
    for i = 0 to n - 1
        array.push(order, i)
if n > 1
    for i = 0 to n - 2
        best = i
        for j = i + 1 to n - 1
            if array.get(sc, array.get(order, j)) > array.get(sc, array.get(order, best))
                best := j
        tmp = array.get(order, i)
        array.set(order, i, array.get(order, best))
        array.set(order, best, tmp)

// ----------------------------------------------------------------------------
//  ALERT  (strong new top opportunity)
// ----------------------------------------------------------------------------
string topName = n > 0 ? array.get(nm, array.get(order, 0)) : ""
float  topScore = n > 0 ? array.get(sc, array.get(order, 0)) : na
var string prevTop = ""
newTop = warmOK and topName != "" and topName != prevTop and not na(topScore) and topScore >= alertThr
if barstate.isconfirmed
    prevTop := topName

alertcondition(newTop, "AE-SCAN Top Opportunity", "AE-SCAN: a strong new symbol topped the scanner")
if newTop
    alert("AE-SCAN top: " + topName + " score " + str.tostring(math.round(topScore)) + "%", alert.freq_once_per_bar_close)

// ----------------------------------------------------------------------------
//  TABLE + HEATMAP
// ----------------------------------------------------------------------------
f_heat(float score, float dir) =>
    base = dir >= 0.5 ? cBull : cBear
    color.new(base, int(f_clamp(92.0 - score * 0.72, 12.0, 92.0)))

var table tbl = table.new(f_pos(), 5, 42, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 70), border_width = 1)
if barstate.islast
    table.clear(tbl, 0, 0, 4, 41)
    ts = f_txtSize()
    table.cell(tbl, 0, 0, "AE-SCAN", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 1, 0, "Symbol", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 2, 0, "Score", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 3, 0, "Dir", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 4, 0, "Δ%", text_color = cGold, bgcolor = cBg0, text_size = ts)
    int shown = math.min(n, maxRows)
    if shown < 1
        table.cell(tbl, 0, 1, "—", text_color = cWait, text_size = ts)
        table.cell(tbl, 1, 1, warmOK ? "no matches" : "learning", text_color = cWait, text_size = ts)
    else
        for rr = 0 to shown - 1
            idx = array.get(order, rr)
            s = array.get(sc, idx)
            d = array.get(dr, idx)
            c = array.get(cg, idx)
            table.cell(tbl, 0, rr + 1, str.tostring(rr + 1), text_color = cTxt, text_size = ts)
            table.cell(tbl, 1, rr + 1, array.get(nm, idx), text_color = cTxt, text_size = ts)
            table.cell(tbl, 2, rr + 1, str.tostring(math.round(s)) + "%", text_color = cBg0, bgcolor = f_heat(s, d), text_size = ts)
            table.cell(tbl, 3, rr + 1, d >= 0.5 ? "▲" : "▼", text_color = d >= 0.5 ? cBull : cBear, text_size = ts)
            table.cell(tbl, 4, rr + 1, str.tostring(c, "#.#") + "%", text_color = c >= 0 ? cBull : cBear, text_size = ts)
    int footRow = shown < 1 ? 2 : shown + 1
    table.cell(tbl, 0, footRow, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 1, footRow, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 2, footRow, "by P(" + str.tostring(kMove, "#.#") + "·ATR)", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 3, footRow, filterMode, text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 4, footRow, str.tostring(n), text_color = cWait, bgcolor = cBg0, text_size = ts)
````
