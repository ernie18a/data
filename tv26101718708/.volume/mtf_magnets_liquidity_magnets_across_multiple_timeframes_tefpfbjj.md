# MTF Magnets: Liquidity Magnets Across Multiple Timeframes

- url: https://www.tradingview.com/script/TEfpFbJj-MTF-Magnets-Liquidity-Magnets-Across-Multiple-Timeframes/
- type: indicator
- pine_id: PUB;beb369b635584054b2dfabf6c9dcdb22
- version: 1.0

## Description

The indicator finds price levels where other traders' stop-losses and liquidations are clustered. Price is often drawn to these levels to collect that liquidity. It runs on 5 timeframes at once: the chart timeframe plus four you choose (15m, 1h, 4h and 1D by default). It also adds a technical rating for each timeframe and BUY/SELL signals.

1. How magnets are calculated
Three types of levels are collected:

Stops beyond swings. Swing highs and lows that price hasn't broken yet. Weight 2.
Previous day high/low, if it hasn't been touched today. Weight 2.
Estimated liquidations at 25x, 50x and 100x leverage, taken from candles with volume at least 2× above average. Weight 1. This is a model, not real exchange data.

Levels within 0.15% of each other are merged into one cluster.

Strength is the sum of the weights in a cluster, i.e. how much liquidity sits there.
Pull is strength divided by the distance from price in %, so it combines how much liquidity there is and how close it is.
The cluster with the highest pull above price is the upper magnet, and the same below price gives the lower magnet.

2. Technical rating
This rating uses 26 indicators: 15 moving averages and 11 oscillators (RSI, MACD, Stochastic and others). The rules are the same as TradingView's Technical Ratings. The result is one of Strong Buy / Buy / Neutral / Sell / Strong Sell.

3. Table (top right)

TF	Pull	Strength	Technicals
1h	▲ 9.1	▼ 11	Buy
Pull and Strength show the stronger side with an arrow. Green means up, red means down.
Below the table you'll find the current signal state and stats. The stats show the number of trades, win rate, total return in % after fees, max drawdown, and buy-and-hold for comparison.

4. Lines on the chart
Each timeframe's magnets are drawn in their own color: 15m yellow, 1h orange, 4h pink, 1D cyan. Higher timeframes get thicker lines. A solid line with ★ marks the stronger side, a dashed line the weaker side.

5. BUY / SELL signals

By default, signals come from technical analysis on the chart timeframe. BUY fires when the rating reaches Buy, SELL fires when it reaches Sell.
Signals don't repeat until a reversal: after a BUY, the next signal can only be a SELL.
Signals appear when the candle closes. Higher-timeframe values come from closed candles, so signals don't repaint on history.
You can also take signals from technicals across all timeframes, or from a combined Pull + Strength + Technicals vote across all timeframes.
BUY and SELL alerts are available.

Main settings

Timeframes: which timeframes appear in the table.
Magnets: swing length, cluster width, max search distance, and whether to include the previous day's high and low.
Signals: signal source, technicals threshold (0.1 = Buy/Sell, 0.5 = Strong), agreement threshold for the all-timeframes mode, and fee used in the stats.

Limitations

Liquidations are estimated. The indicator can't see real positions or leverage.
A magnet shows where liquidity sits, but price isn't guaranteed to go there.
Stats depend on the history TradingView loads. On low timeframes that history is short, and fees have a big impact on results.

## Source Code

````pine
//@version=6
indicator("Liquidity Magnets — Multi-Timeframe", shorttitle="MTF Magnets", overlay=true, max_lines_count=100, max_labels_count=500)

// Magnets are calculated separately on each timeframe:
//   untouched stops beyond swing highs/lows (weight 2), previous day high/low (weight 2),
//   estimated 25x/50x/100x liquidation levels from high-volume candles (weight 1).
// Levels are grouped into clusters; magnet = cluster with the highest pull (strength ÷ distance in %).
// The table shows all timeframes at once, lines show where the magnets are on the chart.

// ─────────────────────────── Settings ───────────────────────────
grpT  = "Timeframes"
useCur = input.bool(true, "Chart timeframe", group=grpT)
use1  = input.bool(true, "", inline="t1", group=grpT)
tf1   = input.timeframe("15",  "TF 1", inline="t1", group=grpT)
use2  = input.bool(true, "", inline="t2", group=grpT)
tf2   = input.timeframe("60",  "TF 2", inline="t2", group=grpT)
use3  = input.bool(true, "", inline="t3", group=grpT)
tf3   = input.timeframe("240", "TF 3", inline="t3", group=grpT)
use4  = input.bool(true, "", inline="t4", group=grpT)
tf4   = input.timeframe("D",   "TF 4", inline="t4", group=grpT)

grpM     = "Magnets"
swingLen = input.int(5, "Swing length", minval=2, group=grpM)
maxPools = input.int(15, "Max stop levels per side", minval=3, maxval=50, group=grpM)
volLen   = input.int(20, "Average volume period", minval=2, group=grpM)
volMult  = input.float(2.0, "Liquidations: volume above average, x", minval=1.0, step=0.1, group=grpM)
mmr      = input.float(0.4, "Maintenance margin, %", minval=0.0, step=0.1, group=grpM) / 100
maxLiq   = input.int(30, "Max liquidation levels per side", minval=3, maxval=100, group=grpM)
band     = input.float(0.15, "Cluster width, %", minval=0.01, step=0.05, group=grpM) / 100
maxDist  = input.float(10.0, "Max distance from price, %", minval=0.5, step=0.5, group=grpM) / 100
usePD    = input.bool(true, "Include previous day high/low", group=grpM)

grpV      = "Display"
showLines = input.bool(true, "Magnet lines on chart", group=grpV)
lineLen   = input.int(30, "Line length, bars", minval=5, maxval=300, group=grpV)

grpS    = "Signals"
showSig = input.bool(true, "Show BUY / SELL", group=grpS)
sigSrc  = input.string("Technicals — chart TF", "Signal source", options=["Technicals — chart TF", "Technicals — all TFs", "Pull + Strength + Technicals — all TFs"], group=grpS)
taThr   = input.float(0.1, "Technicals threshold (0.1 = Buy/Sell, 0.5 = Strong)", minval=0.05, maxval=1.0, step=0.05, group=grpS)
sigThr  = input.int(60, "Signal when agreement ≥ %", minval=10, maxval=100, step=5, group=grpS, tooltip="Each enabled timeframe votes with Pull, Strength and Technicals (+1 up / −1 down). Agreement = sum of votes ÷ max possible.")
useP    = input.bool(true, "Pull", inline="v", group=grpS)
useS    = input.bool(true, "Strength", inline="v", group=grpS)
useT    = input.bool(true, "Technicals", inline="v", group=grpS)
feePct  = input.float(0.05, "Fee per side, % (for stats)", minval=0.0, step=0.01, group=grpS) / 100

// ─────────────────────────── Magnet calculation ───────────────────────────
dropHit(array<float> arr, bool above) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            float y = arr.get(i)
            if above ? high >= y : low <= y
                arr.remove(i)
    arr.size()

pushCap(array<float> arr, float v, int cap) =>
    arr.push(v)
    if arr.size() > cap
        arr.shift()
    arr.size()

collectSide(array<float> src, array<float> ys, array<float> ws, float w, bool above) =>
    if src.size() > 0
        for y in src
            if above ? y > close : y < close
                ys.push(y)
                ws.push(w)
    ys.size()

bestCluster(array<float> ys, array<float> ws) =>
    float bestY = na
    float bestS = 0.0
    float bestP = 0.0
    int cnt = ys.size()
    if cnt > 0
        for i = 0 to cnt - 1
            float yi = ys.get(i)
            if math.abs(yi - close) / close <= maxDist
                float s = 0.0
                float sy = 0.0
                for j = 0 to cnt - 1
                    float yj = ys.get(j)
                    if math.abs(yj - yi) <= yi * band
                        s  += ws.get(j)
                        sy += yj * ws.get(j)
                float cy = sy / s
                float pull = s / math.max(math.abs(cy - close) / close * 100, 0.01)
                if pull > bestP
                    bestP := pull
                    bestS := s
                    bestY := cy
    array.from(bestY, bestS, bestP)

// All state lives inside the function so it can run on any timeframe via request.security
magnets() =>
    var array<float> hiP  = array.new<float>()
    var array<float> loP  = array.new<float>()
    var array<float> sLiq = array.new<float>()
    var array<float> lLiq = array.new<float>()
    dropHit(hiP, true)
    dropHit(sLiq, true)
    dropHit(loP, false)
    dropHit(lLiq, false)

    float ph = ta.pivothigh(high, swingLen, swingLen)
    float pl = ta.pivotlow(low, swingLen, swingLen)
    if not na(ph)
        pushCap(hiP, ph, maxPools)
    if not na(pl)
        pushCap(loP, pl, maxPools)

    float vAvg = ta.sma(volume, volLen)
    if not na(vAvg) and volume > vAvg * volMult
        for lev in array.from(25.0, 50.0, 100.0)
            pushCap(lLiq, close * (1 - 1 / lev + mmr), maxLiq)
            pushCap(sLiq, close * (1 + 1 / lev - mmr), maxLiq)

    bool nd = timeframe.change("D")
    var float curH = na
    var float curL = na
    var float prvH = na
    var float prvL = na
    if nd
        prvH := curH
        prvL := curL
        curH := high
        curL := low
    else
        curH := na(curH) ? high : math.max(curH, high)
        curL := na(curL) ? low : math.min(curL, low)

    array<float> ysU = array.new<float>()
    array<float> wsU = array.new<float>()
    array<float> ysD = array.new<float>()
    array<float> wsD = array.new<float>()
    collectSide(hiP,  ysU, wsU, 2.0, true)
    collectSide(sLiq, ysU, wsU, 1.0, true)
    collectSide(loP,  ysD, wsD, 2.0, false)
    collectSide(lLiq, ysD, wsD, 1.0, false)
    if usePD and not na(prvH) and curH < prvH and prvH > close
        ysU.push(prvH)
        wsU.push(2.0)
    if usePD and not na(prvL) and curL > prvL and prvL < close
        ysD.push(prvL)
        wsD.push(2.0)

    array<float> u = bestCluster(ysU, wsU)
    array<float> d = bestCluster(ysD, wsD)
    [u.get(0), u.get(1), u.get(2), d.get(0), d.get(1), d.get(2)]

[c_uy, c_us, c_up, c_dy, c_ds, c_dp] = magnets()
[a_uy, a_us, a_up, a_dy, a_ds, a_dp] = request.security(syminfo.tickerid, tf1, magnets())
[b_uy, b_us, b_up, b_dy, b_ds, b_dp] = request.security(syminfo.tickerid, tf2, magnets())
[e_uy, e_us, e_up, e_dy, e_ds, e_dp] = request.security(syminfo.tickerid, tf3, magnets())
[f_uy, f_us, f_up, f_dy, f_ds, f_dp] = request.security(syminfo.tickerid, tf4, magnets())

// ─────────────────────────── Technical rating (moving averages + oscillators) ───────────────────────────
maAct(float ma) =>
    na(ma) ? 0 : ma < close ? 1 : ma > close ? -1 : 0

ichAct() =>
    float conv  = math.avg(ta.highest(9), ta.lowest(9))
    float base  = math.avg(ta.highest(26), ta.lowest(26))
    float spanA = math.avg(conv, base)
    float spanB = math.avg(ta.highest(52), ta.lowest(52))
    float a = spanA[25]
    float b = spanB[25]
    close > math.max(a, b) and conv > base ? 1 : close < math.min(a, b) and conv < base ? -1 : 0

maList() =>
    array.from(maAct(ta.sma(close, 10)), maAct(ta.ema(close, 10)), maAct(ta.sma(close, 20)), maAct(ta.ema(close, 20)), maAct(ta.sma(close, 30)), maAct(ta.ema(close, 30)), maAct(ta.sma(close, 50)), maAct(ta.ema(close, 50)), maAct(ta.sma(close, 100)), maAct(ta.ema(close, 100)), maAct(ta.sma(close, 200)), maAct(ta.ema(close, 200)), ichAct(), maAct(ta.vwma(close, 20)), maAct(ta.hma(close, 9)))

// ─────────────────────────── Oscillators ───────────────────────────
rsiAct() =>
    float r = ta.rsi(close, 14)
    r < 30 and r > r[1] ? 1 : r > 70 and r < r[1] ? -1 : 0

stochAct() =>
    float k = ta.sma(ta.stoch(close, high, low, 14), 3)
    float d = ta.sma(k, 3)
    k < 20 and d < 20 and k > d ? 1 : k > 80 and d > 80 and k < d ? -1 : 0

cciAct() =>
    float c = ta.cci(close, 20)
    c < -100 and c > c[1] ? 1 : c > 100 and c < c[1] ? -1 : 0

adxAct() =>
    [p, m, a] = ta.dmi(14, 14)
    a > 20 and p > m and a > a[1] ? 1 : a > 20 and m > p and a > a[1] ? -1 : 0

aoAct() =>
    float ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
    ao > 0 and ao > ao[1] ? 1 : ao < 0 and ao < ao[1] ? -1 : 0

momAct() =>
    float m = ta.mom(close, 10)
    m > m[1] ? 1 : m < m[1] ? -1 : 0

macdAct() =>
    [m, s, h] = ta.macd(close, 12, 26, 9)
    m > s ? 1 : m < s ? -1 : 0

srsiAct() =>
    float r = ta.rsi(close, 14)
    float k = ta.sma(ta.stoch(r, r, r, 14), 3)
    float d = ta.sma(k, 3)
    k < 20 and d < 20 and k > d ? 1 : k > 80 and d > 80 and k < d ? -1 : 0

wprAct() =>
    float w = ta.wpr(14)
    w < -80 and w > w[1] ? 1 : w > -20 and w < w[1] ? -1 : 0

bbpAct() =>
    float e  = ta.ema(close, 13)
    float bp = (high - e) + (low - e)
    bp > 0 and bp > bp[1] ? 1 : bp < 0 and bp < bp[1] ? -1 : 0

uoAct() =>
    float bpv = close - math.min(low, close[1])
    float trv = math.max(high, close[1]) - math.min(low, close[1])
    float a7  = math.sum(bpv, 7) / math.sum(trv, 7)
    float a14 = math.sum(bpv, 14) / math.sum(trv, 14)
    float a28 = math.sum(bpv, 28) / math.sum(trv, 28)
    float uo  = 100 * (4 * a7 + 2 * a14 + a28) / 7
    uo > 70 ? 1 : uo < 30 ? -1 : 0

oscList() =>
    array.from(rsiAct(), stochAct(), cciAct(), adxAct(), aoAct(), momAct(), macdAct(), srsiAct(), wprAct(), bbpAct(), uoAct())

// ─────────────────────────── Rating ───────────────────────────
// Returns [total, MA rating, oscillator rating, MA buys, MA sells, osc buys, osc sells]
rating() =>
    array<int> ma = maList()
    array<int> os = oscList()
    int mb = 0
    int ms = 0
    int ob = 0
    int osl = 0
    for v in ma
        mb += v == 1 ? 1 : 0
        ms += v == -1 ? 1 : 0
    for v in os
        ob  += v == 1 ? 1 : 0
        osl += v == -1 ? 1 : 0
    float maR = float(mb - ms) / ma.size()
    float osR = float(ob - osl) / os.size()
    [(maR + osR) / 2, maR, osR, mb, ms, ob, osl]


taRating() =>
    [tot, maR, osR, mb, ms, ob, osl] = rating()
    tot

ratingTxt(float r) =>
    na(r) ? "—" : r > 0.5 ? "Strong Buy" : r > 0.1 ? "Buy" : r < -0.5 ? "Strong Sell" : r < -0.1 ? "Sell" : "Neutral"

ratingCol(float r) =>
    na(r) ? color.gray : r > 0.5 ? color.new(color.teal, 0) : r > 0.1 ? color.new(color.teal, 40) : r < -0.5 ? color.new(color.red, 0) : r < -0.1 ? color.new(color.red, 40) : color.new(color.gray, 30)


c_ta = taRating()
a_ta = request.security(syminfo.tickerid, tf1, taRating())
b_ta = request.security(syminfo.tickerid, tf2, taRating())
e_ta = request.security(syminfo.tickerid, tf3, taRating())
f_ta = request.security(syminfo.tickerid, tf4, taRating())

// ─────────────── Closed higher-timeframe values for signals (no repainting) ───────────────
magnetsC() =>
    [uy, us, up, dy, ds, dp] = magnets()
    [uy[1], us[1], up[1], dy[1], ds[1], dp[1]]

taC() =>
    float t = taRating()
    t[1]

[a1_uy, a1_us, a1_up, a1_dy, a1_ds, a1_dp] = request.security(syminfo.tickerid, tf1, magnetsC(), lookahead=barmerge.lookahead_on)
[b1_uy, b1_us, b1_up, b1_dy, b1_ds, b1_dp] = request.security(syminfo.tickerid, tf2, magnetsC(), lookahead=barmerge.lookahead_on)
[e1_uy, e1_us, e1_up, e1_dy, e1_ds, e1_dp] = request.security(syminfo.tickerid, tf3, magnetsC(), lookahead=barmerge.lookahead_on)
[f1_uy, f1_us, f1_up, f1_dy, f1_ds, f1_dp] = request.security(syminfo.tickerid, tf4, magnetsC(), lookahead=barmerge.lookahead_on)
a1_ta = request.security(syminfo.tickerid, tf1, taC(), lookahead=barmerge.lookahead_on)
b1_ta = request.security(syminfo.tickerid, tf2, taC(), lookahead=barmerge.lookahead_on)
e1_ta = request.security(syminfo.tickerid, tf3, taC(), lookahead=barmerge.lookahead_on)
f1_ta = request.security(syminfo.tickerid, tf4, taC(), lookahead=barmerge.lookahead_on)

// One timeframe's vote: Pull, Strength, Technicals → +1 up / −1 down each
vote(bool on, float uy, float us, float up, float dy, float ds, float dp, float ta) =>
    int sc = 0
    int mx = 0
    if on
        bool onlyT = sigSrc != "Pull + Strength + Technicals — all TFs"
        if useP and not onlyT
            mx += 1
            sc += not na(up) and (na(dp) or up > dp) ? 1 : not na(dp) and (na(up) or dp > up) ? -1 : 0
        if useS and not onlyT
            float sU = na(uy) ? na : us
            float sD = na(dy) ? na : ds
            mx += 1
            sc += not na(sU) and (na(sD) or sU > sD) ? 1 : not na(sD) and (na(sU) or sD > sU) ? -1 : 0
        if useT or onlyT
            mx += 1
            sc += na(ta) ? 0 : ta >= taThr ? 1 : ta <= -taThr ? -1 : 0
    [sc, mx]

[v0, m0] = vote(useCur, c_uy, c_us, c_up, c_dy, c_ds, c_dp, c_ta)
[v1, m1] = vote(use1, a1_uy, a1_us, a1_up, a1_dy, a1_ds, a1_dp, a1_ta)
[v2, m2] = vote(use2, b1_uy, b1_us, b1_up, b1_dy, b1_ds, b1_dp, b1_ta)
[v3, m3] = vote(use3, e1_uy, e1_us, e1_up, e1_dy, e1_ds, e1_dp, e1_ta)
[v4, m4] = vote(use4, f1_uy, f1_us, f1_up, f1_dy, f1_ds, f1_dp, f1_ta)
int   vSum  = v0 + v1 + v2 + v3 + v4
int   vMax  = m0 + m1 + m2 + m3 + m4
float agree = vMax > 0 ? vSum * 100.0 / vMax : na

// ─────────────── BUY / SELL — no repeats until the opposite signal ───────────────
var int lastSig = 0
bool buySig  = false
bool sellSig = false
bool chartOnly = sigSrc == "Technicals — chart TF"
bool upNow = chartOnly ? (not na(c_ta) and c_ta >= taThr) : (not na(agree) and agree >= sigThr)
bool dnNow = chartOnly ? (not na(c_ta) and c_ta <= -taThr) : (not na(agree) and agree <= -sigThr)
if barstate.isconfirmed
    if upNow and lastSig != 1
        buySig := true
    else if dnNow and lastSig != -1
        sellSig := true

if showSig and buySig
    label.new(bar_index, low, "BUY", yloc=yloc.belowbar, style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.small, tooltip="Technicals (chart): " + str.tostring(c_ta, "#.##") + "\nAgreement: " + str.tostring(agree, "#") + "%")
if showSig and sellSig
    label.new(bar_index, high, "SELL", yloc=yloc.abovebar, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small, tooltip="Technicals (chart): " + str.tostring(c_ta, "#.##") + "\nAgreement: " + str.tostring(agree, "#") + "%")

// ─────────────── Stats: trade from each signal to the opposite one ───────────────
var float entryPx = na
var int   nTr  = 0
var int   nWin = 0
var float eq   = 1.0
var float pkEq = 1.0
var float mdd  = 0.0
var float firstPx = na

if buySig or sellSig
    if not na(entryPx) and lastSig != 0
        float ret = (lastSig == 1 ? close / entryPx - 1 : entryPx / close - 1) - 2 * feePct
        nTr  += 1
        nWin += ret > 0 ? 1 : 0
        eq   *= 1 + ret
    if na(firstPx)
        firstPx := close
    entryPx := close
    lastSig := buySig ? 1 : -1

if barstate.isconfirmed and not na(entryPx)
    float openRet = lastSig == 1 ? close / entryPx - 1 : entryPx / close - 1
    float eqNow = eq * (1 + openRet)
    pkEq := math.max(pkEq, eqNow)
    mdd  := math.max(mdd, 1 - eqNow / pkEq)

alertcondition(buySig,  "BUY",  "MTF Magnets: BUY")
alertcondition(sellSig, "SELL", "MTF Magnets: SELL")

// ─────────────────────────── Display ───────────────────────────
tfName(string tf) =>
    tf == "" ? timeframe.period : tf == "60" ? "1h" : tf == "120" ? "2h" : tf == "240" ? "4h" : tf == "D" or tf == "1D" ? "1D" : tf == "W" or tf == "1W" ? "1W" : str.contains(tf, "S") ? tf : tf + "m"

var table tb = table.new(position.top_right, 4, 8, border_width=1)
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

drawMag(float y, float p, bool star, bool up, string name, color col, int width, int slot) =>
    if showLines and not na(y)
        int x2 = bar_index + 3 + slot * 6
        lns.push(line.new(bar_index - lineLen, y, x2, y, color=color.new(col, star ? 0 : 50), width=star ? width + 1 : width, style=star ? line.style_solid : line.style_dashed))
        lbs.push(label.new(x2, y, name + (up ? " ▲ " : " ▼ ") + str.tostring(p, "#.#") + (star ? " ★" : ""), style=label.style_label_left, color=color.new(col, star ? 10 : 60), textcolor=color.black, size=size.tiny))
    0

// Larger of the two sides: "▲ 9.1" or "▼ 11"
maxCell(int c, int r, float vu, float vd, string fmt) =>
    bool upW = not na(vu) and (na(vd) or vu >= vd)
    bool dnW = not na(vd) and (na(vu) or vd > vu)
    string t = upW ? "▲ " + str.tostring(vu, fmt) : dnW ? "▼ " + str.tostring(vd, fmt) : "—"
    color bg = upW ? color.new(color.teal, 20) : dnW ? color.new(color.red, 20) : color.new(color.gray, 50)
    table.cell(tb, c, r, t, text_color=color.white, bgcolor=bg, text_size=size.small)

row(int r, bool on, string name, float uy, float us, float up, float dy, float ds, float dp, float ta, color col, int width, int slot) =>
    if on
        bool starU = not na(up) and (na(dp) or up > dp)
        bool starD = not na(dp) and (na(up) or dp > up)
        float sU = na(uy) ? na : us
        float sD = na(dy) ? na : ds
        table.cell(tb, 0, r, name, text_color=color.black, bgcolor=color.new(col, 20), text_size=size.small)
        maxCell(1, r, up, dp, "#.#")
        maxCell(2, r, sU, sD, "#")
        table.cell(tb, 3, r, ratingTxt(ta), text_color=color.white, bgcolor=ratingCol(ta), text_size=size.small)
        drawMag(uy, up, starU, true, name, col, width, slot)
        drawMag(dy, dp, starD, false, name, col, width, slot)
    0

if barstate.islast
    for l in lns
        line.delete(l)
    for l in lbs
        label.delete(l)
    lns.clear()
    lbs.clear()

    array<string> hdr = array.from("TF", "Pull", "Strength", "Technicals")
    for i = 0 to 3
        table.cell(tb, i, 0, hdr.get(i), text_color=color.white, bgcolor=color.new(color.gray, 10), text_size=size.small)

    row(1, useCur, tfName("") + " (chart)", c_uy, c_us, c_up, c_dy, c_ds, c_dp, c_ta, color.silver, 1, 0)
    row(2, use1, tfName(tf1), a_uy, a_us, a_up, a_dy, a_ds, a_dp, a_ta, color.yellow, 1, 1)
    row(3, use2, tfName(tf2), b_uy, b_us, b_up, b_dy, b_ds, b_dp, b_ta, color.orange, 2, 2)
    row(4, use3, tfName(tf3), e_uy, e_us, e_up, e_dy, e_ds, e_dp, e_ta, color.fuchsia, 2, 3)
    row(5, use4, tfName(tf4), f_uy, f_us, f_up, f_dy, f_ds, f_dp, f_ta, color.aqua, 3, 4)

    string ag = na(agree) ? "—" : (agree > 0 ? "+" : "") + str.tostring(agree, "#") + "%"
    color agC = na(agree) ? color.new(color.gray, 30) : agree >= sigThr ? color.new(color.teal, 0) : agree <= -sigThr ? color.new(color.red, 0) : color.new(color.gray, 30)
    string srcTxt = chartOnly ? "Signal: Technicals " + timeframe.period + " ≥ ±" + str.tostring(taThr) : "Agreement " + ag + "  ·  signal at ±" + str.tostring(sigThr) + "%"
    color srcC = chartOnly ? (upNow ? color.new(color.teal, 0) : dnNow ? color.new(color.red, 0) : color.new(color.gray, 30)) : agC
    table.cell(tb, 0, 6, srcTxt, text_color=color.white, bgcolor=srcC, text_size=size.small)
    table.merge_cells(tb, 0, 6, 3, 6)
    string st = "Trades: " + str.tostring(nTr) + "  ·  win " + (nTr > 0 ? str.tostring(nWin * 100.0 / nTr, "#") + "%" : "—") + "  ·  total " + (nTr > 0 ? str.tostring((eq - 1) * 100, "#.#") + "%" : "—") + "  ·  max DD −" + str.tostring(mdd * 100, "#") + "%  ·  hold " + (na(firstPx) ? "—" : str.tostring((close / firstPx - 1) * 100, "#.#") + "%")
    table.cell(tb, 0, 7, st, text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.merge_cells(tb, 0, 7, 3, 7)
````
