# Heikin Ashi Reality Check: Real Fills Test [forexobroker]

- url: https://www.tradingview.com/script/YoeCbJDb-Heikin-Ashi-Reality-Check-Real-Fills-Test-forexobroker/
- type: strategy
- pine_id: PUB;537f5da87d1d4a84a208586c872c9f29
- version: 1.0

## Description

Heikin Ashi Reality Check: Real Fills Test [forexobroker]

🔶 OVERVIEW

Heikin Ashi Reality Check is a strategy that answers one question on your own chart: how much of a Heikin Ashi backtest is real? It runs one simple Heikin Ashi strategy and books the same signals three ways, side by side: at Heikin Ashi prices (what a backtest on a Heikin Ashi chart fills at by default), at real prices with the same orders, and with the "two-chart fix" (Heikin Ashi for the direction, real candles for the entry, stop and target). A table shows all three on four markets at once.

Heikin Ashi candles are averages. Their open is the midpoint of the previous Heikin Ashi body, not the price the market opened at, so a backtest that fills orders at Heikin Ashi prices can buy at prices that never traded. This script measures how big that gap is.

🔶 THE STRATEGY

- Trend: the 50 EMA of the Heikin Ashi close. Above it, buys only; below it, sells only.
- Pullback: a red Heikin Ashi candle in an uptrend (a green one in a downtrend).
- Signal: the first green Heikin Ashi close after the pullback (red for sells).
- Entry at the open of the next candle. Stop at the low of the signal candle (the high for sells). Target 1.5 times the risk.

Heikin Ashi is computed from the real candles with the standard formula: close = (open + high + low + close) / 4; open = (previous Heikin Ashi open + previous Heikin Ashi close) / 2; high and low include that open and close. The script computes it itself, so it works on a normal candle chart.

🔶 THE THREE LEDGERS

A. Heikin Ashi fills: the entry fills at the next Heikin Ashi open, the stop and target are checked against Heikin Ashi candles. This is what TradingView's Strategy Tester books on a Heikin Ashi chart when Properties > "Heikin Ashi mode" is left at "Heikin Ashi bars".

B. Real fills: the same orders, the same stop and target levels and the same size, filled at real prices. This is what the Strategy Tester books with "Heikin Ashi mode" set to "Standard bars". Results are in the same R units as A.

C. Two-chart fix: the signal still comes from Heikin Ashi, but the entry is the real next open, the stop goes under the real low of the pullback and the signal candle (over the real high for sells), and the target is 1.5 times that real risk. A setup whose real open is already beyond the stop is skipped.

Inside a candle the price path follows TradingView's broker emulator: the open, then the nearer of the high and the low, then the other. A stop or target already passed at the open fills at the open. One trade at a time per ledger. R = the result divided by the planned risk.

🔶 THE TABLE

- One row per market (four inputs, any symbols), plus "All four": wins out of trades and total R for A, B and C.
- "Real open worse": how often the real open was worse than the Heikin Ashi open, signal by signal.
- The average real risk as a multiple of the Heikin Ashi risk.
- The test window (start and end inputs), so the table stays fixed however long the chart stays open.
- A note that tells you whether the chart is a Heikin Ashi chart, and what that means for the Strategy Tester.

🔶 ON THE CHART

- Every signal, with its entry, stop and target lines.
- A pane with the real candles under the price chart, so both prices are visible at once on a Heikin Ashi chart.

🔶 STRATEGY TESTER SETTINGS (defaults)

- Initial capital 10,000; each order risks 1 % of the initial capital (input), sized from the entry-to-stop distance.
- Commission 0.01 % per order; slippage 0 ticks (the comparison isolates the fill price; add slippage in Properties for your market).
- Over the default test window on the 1-hour chart each market produces between 50 and 100 trades; extend the window for a larger sample.
- On a Heikin Ashi chart, set Properties > "Heikin Ashi mode" to "Standard bars" to get real fills (ledger B). On a normal candle chart the tester fills at real prices already.

🔶 SETTINGS

Strategy
- Trend EMA length (50), target in R (1.5), risk per trade for the Strategy Tester (1 %).

Test window
- Start and end dates (the same for every market).

Markets table
- Show the table, four markets, text size.

Display
- Real candles pane, the entry / stop / target lines, signal markers, colours.

🔶 LIMITATIONS

- The table counts the script's own rules on closed candles at the chart's timeframe; it shows costs only through the Strategy Tester's commission.
- Intrabar order is modelled the way TradingView's broker emulator does it; real fills can differ again with spread and slippage.
- Results depend on the market, the timeframe and the window. This is an analysis tool, not financial advice, and past performance does not guarantee future results.

🔶 RELEASE NOTES

v1.0 — Initial release. One Heikin Ashi strategy booked three ways (Heikin Ashi fills, real fills, two-chart fix) on four markets in one table, the real-open check, the real-risk ratio, a real-candle pane and a fixed test window.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © forexobroker
//@version=6
// ALGORITHM: Heikin Ashi Reality Check — one simple Heikin Ashi strategy, booked three ways on the same signals.
// THE STRATEGY: 50 EMA of the Heikin Ashi close sets the side (above = buys only, below = sells only). A red Heikin
//   Ashi candle is the pullback; the first green Heikin Ashi candle that closes after it is the buy signal (sells
//   mirror). The trade opens at the open of the next candle, the stop sits at the low of the signal candle (high for
//   sells) and the target is 1.5 times the risk.
// HEIKIN ASHI (standard formula, from the real prices): close = (open + high + low + close) / 4; open = (previous
//   Heikin Ashi open + previous Heikin Ashi close) / 2; high = the highest of the real high and that open and close;
//   low = the lowest of the real low and that open and close. These are averages: nobody ever traded at them.
// THE THREE LEDGERS (the table):
//   A "Heikin Ashi fills": what TradingView's Strategy Tester books on a Heikin Ashi chart by default. The entry fills
//     at the next Heikin Ashi open, and the stop and target are checked against Heikin Ashi candles.
//   B "Real fills": the same orders filled at real prices, what the tester books once Properties > "Heikin Ashi mode"
//     is set to "Standard bars" (older TradingView versions: the "Fill orders on standard OHLC" checkbox). Same stop and target levels, same position size, results in the same R units as A.
//   C "Two-chart fix": Heikin Ashi only gives the direction and the signal. The entry is the real next open, the stop
//     goes under the real low of the pullback and the signal candle (over the real high for sells), the target is
//     1.5 times that real risk. A setup whose real open is already beyond that level is skipped.
//   One trade at a time per ledger. Inside a candle the price path follows TradingView's broker emulator: open, then
//   the nearer of high and low, then the other one. A stop or target already passed at the open fills at the open.
//   R = profit or loss divided by the planned risk (A and B: entry to stop on the Heikin Ashi numbers; C: on the real
//   numbers). Costs are not in the table; the Strategy Tester applies the commission set in Properties.
// THE STRATEGY TESTER trades the chart's own market with A's orders; set "Heikin Ashi mode" to "Standard bars" to get B.
// Non-repainting: every decision is taken on a closed candle; the real prices come from the same timeframe.
strategy("Heikin Ashi Reality Check: Real Fills Test [forexobroker]", shorttitle="HARC [fob]", overlay=false,
     initial_capital=10000, default_qty_type=strategy.fixed, default_qty_value=1, pyramiding=0,
     commission_type=strategy.commission.percent, commission_value=0.01, slippage=0, margin_long=0, margin_short=0,
     fill_orders_on_standard_ohlc=false, process_orders_on_close=false, calc_on_every_tick=false,
     max_bars_back=5000, max_lines_count=150, max_labels_count=50)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_s = "Strategy"
int   emaLen  = input.int(50, "Trend EMA length (on the Heikin Ashi close)", minval=2, group=g_s)
float rr      = input.float(1.5, "Target (reward : risk)", minval=0.1, step=0.1, group=g_s)
float riskPct = input.float(1.0, "Risk per trade for the Strategy Tester (% of initial capital)", minval=0.01, step=0.1, group=g_s)

string g_t = "Test window (the same dates for every market)"
int tStart = input.time(timestamp("2026-09-05T00:00:00+00:00"), "Test starts at", group=g_t)
int tEnd   = input.time(timestamp("2026-10-14T00:00:00+00:00"), "Test ends at", group=g_t)

string g_m = "Markets table"
bool   showTable = input.bool(true, "Show the table", group=g_m)
string sym1 = input.symbol("OANDA:EURUSD", "Market 1", group=g_m)
string sym2 = input.symbol("OANDA:XAUUSD", "Market 2", group=g_m)
string sym3 = input.symbol("BINANCE:BTCUSDT", "Market 3", group=g_m)
string sym4 = input.symbol("OANDA:NAS100USD", "Market 4", group=g_m)
string tSize = input.string("Large", "Text size", options=["Normal", "Large", "Huge"], group=g_m)

string g_d = "Display"
bool showReal   = input.bool(true, "Real candles in this pane (the prices under the Heikin Ashi chart)", group=g_d)
bool showLevels = input.bool(true, "Entry, stop and target of each Strategy Tester order", group=g_d)
bool showSigs   = input.bool(true, "Signal markers", group=g_d)
color cUp   = input.color(#26a69a, "Up", group=g_d)
color cDn   = input.color(#ef5350, "Down", group=g_d)
color cEma  = input.color(#f5a623, "50 EMA", group=g_d)

// ─── HEIKIN ASHI FROM REAL PRICES ──────────────────────────────────────────────
f_ha(float o, float h, float l, float c) =>
    float hc = (o + h + l + c) / 4
    float ho = na
    ho := na(ho[1]) ? (o + c) / 2 : (ho[1] + hc[1]) / 2
    [ho, math.max(h, ho, hc), math.min(l, ho, hc), hc]

// The broker emulator's exit price for one candle (na = no exit). dir 1 = long, -1 = short.
f_exit(int dir, float o, float h, float l, float st, float tg) =>
    float x = na
    bool highFirst = (h - o) < (o - l)
    if dir == 1
        if o <= st
            x := o
        else if o >= tg
            x := o
        else if highFirst
            x := h >= tg ? tg : l <= st ? st : na
        else
            x := l <= st ? st : h >= tg ? tg : na
    else
        if o >= st
            x := o
        else if o <= tg
            x := o
        else if highFirst
            x := h >= st ? st : l <= tg ? tg : na
        else
            x := l <= tg ? tg : h >= st ? st : na
    x

type Led
    int   kind
    int   pend  = 0
    float pStop = na
    float pTgt  = na
    float pRisk = na
    int   pos   = 0
    float e     = na
    float st    = na
    float tg    = na
    float rk    = na
    int   n     = 0
    int   w     = 0
    float sumR  = 0.0
    int   skipped = 0

// One candle for one ledger: fill a pending entry at the open, then check the exits along the candle's path.
method step(Led L, float o, float h, float l, float rrIn) =>
    if L.pend != 0
        int d = L.pend
        if L.kind == 2
            float rk = d * (o - L.pStop)
            if rk <= 0
                L.skipped += 1
            else
                L.pos := d
                L.e := o
                L.st := L.pStop
                L.tg := o + d * rrIn * rk
                L.rk := rk
        else
            L.pos := d
            L.e := o
            L.st := L.pStop
            L.tg := L.pTgt
            L.rk := L.pRisk
        L.pend := 0
    if L.pos != 0
        float x = f_exit(L.pos, o, h, l, L.st, L.tg)
        if not na(x)
            float r = L.pos * (x - L.e) / L.rk
            L.n += 1
            L.w += r > 0 ? 1 : 0
            L.sumR += r
            L.pos := 0

// The whole test on one market (runs in that market's real-price context).
f_engine(int t0, int t1, float rrIn, int len) =>
    float o = open, h = high, l = low, c = close
    [ho, hh, hl, hc] = f_ha(o, h, l, c)
    float em = ta.ema(hc, len)
    bool g = hc > ho
    bool r = hc < ho
    bool sL = g and r[1] and hc > em
    bool sS = r and g[1] and hc < em
    var Led A = Led.new(0)
    var Led B = Led.new(1)
    var Led C = Led.new(2)
    var int   nSig = 0
    var int   nWorse = 0
    var float sumRatio = 0.0
    var int   mDir = 0
    var float mE = na
    var float mSt = na
    var float mRk = na
    // this candle: fills and exits
    A.step(ho, hh, hl, rrIn)
    B.step(o, h, l, rrIn)
    C.step(o, h, l, rrIn)
    if mDir != 0
        nSig += 1
        nWorse += mDir * (o - mE) > 0 ? 1 : 0
        sumRatio += mDir * (o - mSt) / mRk
        mDir := 0
    // its close: a new signal
    if barstate.isconfirmed and time >= t0 and time <= t1 and (sL or sS)
        int d = sL ? 1 : -1
        float eA = (ho + hc) / 2
        float stHA = d == 1 ? hl : hh
        float rkA = d * (eA - stHA)
        if rkA > 0
            float tgA = eA + d * rrIn * rkA
            if A.pos == 0 and A.pend == 0
                A.pend := d
                A.pStop := stHA
                A.pTgt := tgA
                A.pRisk := rkA
            if B.pos == 0 and B.pend == 0
                B.pend := d
                B.pStop := stHA
                B.pTgt := tgA
                B.pRisk := rkA
            if C.pos == 0 and C.pend == 0
                C.pend := d
                C.pStop := d == 1 ? math.min(l, l[1]) : math.max(h, h[1])
            mDir := d
            mE := eA
            mSt := stHA
            mRk := rkA
    [A.n, A.w, A.sumR, B.n, B.w, B.sumR, C.n, C.w, C.sumR, C.skipped, nSig, nWorse, nSig > 0 ? sumRatio / nSig : na]

// ─── THIS CHART ────────────────────────────────────────────────────────────────
string realTick = ticker.standard(syminfo.tickerid)
[ro, rh, rl, rc] = request.security(realTick, timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)
[ho, hh, hl, hc] = f_ha(ro, rh, rl, rc)
float ema = ta.ema(hc, emaLen)
bool green = hc > ho
bool red = hc < ho
bool longSig = green and red[1] and hc > ema
bool shortSig = red and green[1] and hc < ema
bool inWindow = time >= tStart and time <= tEnd

plot(ema, "50 EMA (Heikin Ashi close)", color=cEma, linewidth=2, force_overlay=true)
plotshape(showSigs and inWindow and longSig, "Buy signal", shape.triangleup, location.belowbar, cUp, size=size.small, force_overlay=true)
plotshape(showSigs and inWindow and shortSig, "Sell signal", shape.triangledown, location.abovebar, cDn, size=size.small, force_overlay=true)
plotcandle(showReal ? ro : na, showReal ? rh : na, showReal ? rl : na, showReal ? rc : na, "Real candles",
     color=rc >= ro ? cUp : cDn, wickcolor=rc >= ro ? cUp : cDn, bordercolor=rc >= ro ? cUp : cDn)

// Strategy Tester orders = ledger A's rules (B once the Properties box is ticked).
float riskMoney = strategy.initial_capital * riskPct / 100
if barstate.isconfirmed and inWindow and strategy.position_size == 0 and (longSig or shortSig)
    int d = longSig ? 1 : -1
    float eA = (ho + hc) / 2
    float st = d == 1 ? hl : hh
    float rk = d * (eA - st)
    if rk > 0
        float tg = eA + d * rr * rk
        float q = riskMoney / rk
        if d == 1
            strategy.entry("Buy", strategy.long, qty=q)
            strategy.exit("Buy exit", "Buy", stop=st, limit=tg)
        else
            strategy.entry("Sell", strategy.short, qty=q)
            strategy.exit("Sell exit", "Sell", stop=st, limit=tg)
        if showLevels
            line.new(bar_index + 1, eA, bar_index + 9, eA, color=color.new(color.gray, 0), width=2, force_overlay=true)
            line.new(bar_index + 1, st, bar_index + 9, st, color=cDn, width=2, force_overlay=true)
            line.new(bar_index + 1, tg, bar_index + 9, tg, color=cUp, width=2, force_overlay=true)

// ─── THE TABLE ─────────────────────────────────────────────────────────────────
[a1n, a1w, a1r, b1n, b1w, b1r, c1n, c1w, c1r, c1s, s1n, s1w, s1q] = request.security(ticker.standard(sym1), timeframe.period, f_engine(tStart, tEnd, rr, emaLen))
[a2n, a2w, a2r, b2n, b2w, b2r, c2n, c2w, c2r, c2s, s2n, s2w, s2q] = request.security(ticker.standard(sym2), timeframe.period, f_engine(tStart, tEnd, rr, emaLen))
[a3n, a3w, a3r, b3n, b3w, b3r, c3n, c3w, c3r, c3s, s3n, s3w, s3q] = request.security(ticker.standard(sym3), timeframe.period, f_engine(tStart, tEnd, rr, emaLen))
[a4n, a4w, a4r, b4n, b4w, b4r, c4n, c4w, c4r, c4s, s4n, s4w, s4q] = request.security(ticker.standard(sym4), timeframe.period, f_engine(tStart, tEnd, rr, emaLen))

f_rtxt(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.0") + "R"
f_name(string s) => array.last(str.split(s, ":"))
f_wtxt(int w, int n) => str.tostring(w) + " of " + str.tostring(n)

var table tb = table.new(position.top_right, 5, 9, bgcolor=color.new(#131722, 8), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1, force_overlay=true)
if showTable and (barstate.islastconfirmedhistory or barstate.isrealtime)
    string ts = tSize == "Huge" ? size.huge : tSize == "Large" ? size.large : size.normal
    color hd = color.new(color.white, 0)
    color mu = color.new(#b2b5be, 0)
    table.cell(tb, 0, 0, "Same signals", text_color=mu, text_size=ts)
    table.cell(tb, 1, 0, "A  Heikin Ashi fills", text_color=hd, text_size=ts)
    table.cell(tb, 2, 0, "B  Real fills", text_color=hd, text_size=ts)
    table.cell(tb, 3, 0, "C  Two-chart fix", text_color=hd, text_size=ts)
    table.cell(tb, 4, 0, "Real open worse", text_color=mu, text_size=ts)
    array<string> names = array.from(f_name(sym1), f_name(sym2), f_name(sym3), f_name(sym4))
    array<int>   an = array.from(a1n, a2n, a3n, a4n)
    array<int>   aw = array.from(a1w, a2w, a3w, a4w)
    array<float> ar = array.from(a1r, a2r, a3r, a4r)
    array<int>   bn = array.from(b1n, b2n, b3n, b4n)
    array<int>   bw = array.from(b1w, b2w, b3w, b4w)
    array<float> br = array.from(b1r, b2r, b3r, b4r)
    array<int>   cn = array.from(c1n, c2n, c3n, c4n)
    array<int>   cw = array.from(c1w, c2w, c3w, c4w)
    array<float> cr = array.from(c1r, c2r, c3r, c4r)
    array<int>   sn = array.from(s1n, s2n, s3n, s4n)
    array<int>   sw = array.from(s1w, s2w, s3w, s4w)
    int tan = 0
    int taw = 0
    int tbn = 0
    int tbw = 0
    int tcn = 0
    int tcw = 0
    int tsn = 0
    int tsw = 0
    float tar = 0.0
    float tbr = 0.0
    float tcr = 0.0
    for i = 0 to 3
        int row = i + 1
        table.cell(tb, 0, row, array.get(names, i), text_color=hd, text_size=ts, text_halign=text.align_left)
        table.cell(tb, 1, row, f_wtxt(array.get(aw, i), array.get(an, i)) + "   " + f_rtxt(array.get(ar, i)), text_color=array.get(ar, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 2, row, f_wtxt(array.get(bw, i), array.get(bn, i)) + "   " + f_rtxt(array.get(br, i)), text_color=array.get(br, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 3, row, f_wtxt(array.get(cw, i), array.get(cn, i)) + "   " + f_rtxt(array.get(cr, i)), text_color=array.get(cr, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 4, row, f_wtxt(array.get(sw, i), array.get(sn, i)), text_color=mu, text_size=ts)
        tan += array.get(an, i)
        taw += array.get(aw, i)
        tar += array.get(ar, i)
        tbn += array.get(bn, i)
        tbw += array.get(bw, i)
        tbr += array.get(br, i)
        tcn += array.get(cn, i)
        tcw += array.get(cw, i)
        tcr += array.get(cr, i)
        tsn += array.get(sn, i)
        tsw += array.get(sw, i)
    table.cell(tb, 0, 5, "All four", text_color=hd, text_size=ts, text_halign=text.align_left)
    table.cell(tb, 1, 5, f_wtxt(taw, tan) + "   " + f_rtxt(tar), text_color=tar >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 2, 5, f_wtxt(tbw, tbn) + "   " + f_rtxt(tbr), text_color=tbr >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 3, 5, f_wtxt(tcw, tcn) + "   " + f_rtxt(tcr), text_color=tcr >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 4, 5, f_wtxt(tsw, tsn), text_color=mu, text_size=ts)
    float q = (s1q * s1n + s2q * s2n + s3q * s3n + s4q * s4n) / math.max(1, tsn)
    table.cell(tb, 0, 6, "Real risk vs Heikin Ashi risk: " + str.tostring(q, "0.00") + "x on average", text_color=mu, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 6, 4, 6)
    table.cell(tb, 0, 7, "Window " + str.format_time(tStart, "yyyy-MM-dd", "UTC") + " to " + str.format_time(tEnd, "yyyy-MM-dd", "UTC") + " · " + timeframe.period + " min · results before costs", text_color=mu, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 7, 4, 7)
    table.cell(tb, 0, 8, chart.is_heikinashi ? "This chart: Heikin Ashi. The Strategy Tester fills at these averaged prices unless Properties > Heikin Ashi mode is set to Standard bars." : "This chart: real candles. The Strategy Tester fills at real prices.", text_color=chart.is_heikinashi ? #f5a623 : mu, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 8, 4, 8)
````
