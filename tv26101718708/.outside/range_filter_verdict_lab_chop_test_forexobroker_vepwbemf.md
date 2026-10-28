# Range Filter Verdict Lab: Chop Test [forexobroker]

- url: https://www.tradingview.com/script/VEPWBEmF-Range-Filter-Verdict-Lab-Chop-Test-forexobroker/
- type: strategy
- pine_id: PUB;68714d638f7d46daa9370fe89d8e9d0e
- version: 1.0

## Description

Range Filter Verdict Lab: Chop Test [forexobroker]

🔶 OVERVIEW

Range Filter Verdict Lab is a strategy that tests the popular Range Filter "Buy and Sell" signals on your own chart and shows where they work and where they don't. It books the same signals three ways, side by side, on four markets at once: always in the market (the way the signals are usually traded), with a stop and a target, and with one trend filter. It also counts the "fast flips": signals that come within 12 candles of the previous one, the moment the market goes sideways and the filter starts to whipsaw.

🔶 THE RANGE FILTER

The Range Filter formula was published by DonovanWall on TradingView; this script is a new, open-source implementation of that formula with the signal rules of the popular "Buy and Sell" strategy version.

- The range: the average absolute move from one close to the next over the sampling period (100), smoothed again over 2 x period - 1, times the multiplier (3.0).
- The filter line follows the close only when the close pulls more than one range away from it; otherwise it stays flat. The bands are the filter plus and minus one range.
- Buy: the close is above a rising filter for the first time since the last sell. Sell: the mirror image.

🔶 THE THREE VERSIONS

A. Default: always in the market. Every flip closes the open trade and opens the other way at the next candle's open.

B. Stop + target: one trade at a time. The stop sits on the filter's far band at the signal (filter minus the range for buys, plus the range for sells); the target is 1.5 times that risk (input).

C. B + chop filter: version B, taking only the signals that pass one filter at the signal candle. Choose it in the inputs: the side of the 200 EMA (buys only above it, sells only below it; the default), ADX(14) at or above a threshold, or a minimum distance from the filter in ranges.

R = the result divided by the planned risk; the planned risk is the distance from the signal close to the far band, the same unit for all three versions. Inside a candle the price path follows TradingView's broker emulator: the open, then the nearer of the high and the low, then the other. A stop or target already passed at the open fills at the open.

🔶 THE TABLE

- One row per market (four inputs, any symbols) plus "All four": the number of trades and the total R of A, B and C.
- Fast flips: how many signals came within 12 candles of the previous signal, out of all signals.
- The settings, the timeframe and the test window, so the table stays fixed however long the chart stays open. Table results are before costs.

🔶 ON THE CHART

- The filter line (green rising, red falling, orange flat) and its range bands.
- Buy and Sell labels.
- Optional: the 200 EMA that version C uses.

🔶 STRATEGY TESTER SETTINGS (defaults)

- The Strategy Tester runs the version chosen in the inputs (A by default) on the chart's market.
- Initial capital 10,000; each order risks 1 % of the initial capital (input), sized from the entry-to-band distance.
- Commission 0.01 % per order; slippage 0 ticks. Add slippage in Properties for your market: on short timeframes the cost per trade is large compared with the range.
- The test window defaults to 17 August - 15 October 2026; change it for your own test.

🔶 SETTINGS

Range Filter
- Sampling period (100), range multiplier (3.0).

Test
- The version the Strategy Tester runs, the target in R (1.5), the chop filter for C with its threshold or distance, risk per trade, the test window.

Markets table
- Show the table, four markets, text size, position.

Display
- Filter line, range bands, Buy / Sell labels, the 200 EMA, colours.

🔶 LIMITATIONS

- Every decision is taken on a closed candle; the signals do not repaint.
- The table counts the script's own rules at the chart's timeframe and shows costs only through the Strategy Tester's commission.
- Results depend on the market, the timeframe, the settings and the window. A setting that looks best on one period often does worse on the next. This is an analysis tool, not financial advice, and past performance does not guarantee future results.

🔶 RELEASE NOTES

v1.0 — Initial release. The Range Filter's Buy and Sell signals booked three ways (always in, stop + 1.5R, stop + 1.5R with a chop filter) on four markets in one table, the fast-flip count, a fixed test window and the Strategy Tester on any version.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © forexobroker
//@version=6
// ALGORITHM: Range Filter Verdict Lab — the popular "Range Filter Buy and Sell" signals, booked three ways on the same flips.
// THE RANGE FILTER (the formula published by DonovanWall, as used by the "Range Filter Buy and Sell 5min" strategy):
//   range  = EMA( EMA(|close - previous close|, period), 2 x period - 1 ) x multiplier
//   filter = follows the close only when the close pulls more than one range away from it; otherwise it stays flat.
//   Buy  = the close is above a rising filter for the first time since the last sell. Sell mirrors it.
// THE THREE LEDGERS (the table: the same flips, every market at once):
//   A "Default"      always in the market: every flip closes the trade and opens the other way at the next open.
//   B "Stop + 1.5R"  one trade at a time: the stop sits on the filter's far band (filter -/+ range at the signal),
//                    the target is 1.5 times that risk.
//   C "Fix"          B, plus one chop filter at the signal candle (ADX, the 200 EMA side, or distance from the filter).
//   R = result / planned risk. Planned risk = the signal close to the far band (the same unit for A, B and C).
//   "Fast flips" = flips that came 12 candles or less after the previous one (the market went sideways).
//   Inside a candle the price path follows TradingView's broker emulator: open, the nearer of high and low, the other.
//   Results in the table are before costs; the Strategy Tester applies the commission set in Properties.
// THE STRATEGY TESTER runs the version chosen in the inputs on this chart's market.
// Non-repainting: every decision is taken on a closed candle.
strategy("Range Filter Verdict Lab: Chop Test [forexobroker]", shorttitle="RFVL [fob]", overlay=true,
     initial_capital=10000, default_qty_type=strategy.fixed, default_qty_value=1, pyramiding=0,
     commission_type=strategy.commission.percent, commission_value=0.01, slippage=0, margin_long=0, margin_short=0,
     process_orders_on_close=false, calc_on_every_tick=false, max_bars_back=5000, max_labels_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_r = "Range Filter"
int   per  = input.int(100, "Sampling period", minval=2, group=g_r)
float mult = input.float(3.0, "Range multiplier", minval=0.1, step=0.1, group=g_r)

string verA = "A  Default (always in, every flip reverses)"
string verB = "B  Stop on the band + target"
string verC = "C  B + chop filter"
string fADX = "ADX(14) at least"
string fEMA = "200 EMA side"
string fDST = "Distance from the filter"
string g_s = "Test"
string ver   = input.string(verA, "Strategy Tester runs", options=[verA, verB, verC], group=g_s)
float  rr    = input.float(1.5, "Target for B and C (reward : risk)", minval=0.1, step=0.1, group=g_s)
string cf    = input.string(fEMA, "Chop filter for C", options=[fADX, fEMA, fDST], group=g_s)
float  thr   = input.float(20.0, "ADX threshold", minval=0, step=1, group=g_s)
float  kD    = input.float(0.5, "Distance, in ranges", minval=0, step=0.1, group=g_s)
float riskPct = input.float(1.0, "Risk per trade for the Strategy Tester (% of initial capital)", minval=0.01, step=0.1, group=g_s)
int tStart = input.time(timestamp("2026-08-17T00:00:00+00:00"), "Test starts at", group=g_s)
int tEnd   = input.time(timestamp("2026-10-15T00:00:00+00:00"), "Test ends at", group=g_s)

string g_m = "Markets table"
bool   showTable = input.bool(true, "Show the table", group=g_m)
string sym1 = input.symbol("OANDA:EURUSD", "Market 1", group=g_m)
string sym2 = input.symbol("OANDA:XAUUSD", "Market 2", group=g_m)
string sym3 = input.symbol("BINANCE:BTCUSDT", "Market 3", group=g_m)
string sym4 = input.symbol("OANDA:NAS100USD", "Market 4", group=g_m)
string tSize = input.string("Large", "Text size", options=["Normal", "Large", "Huge"], group=g_m)
string tPos  = input.string("Top right", "Table position", options=["Top right", "Bottom right", "Bottom left", "Top left"], group=g_m)

string g_d = "Display"
bool  showFilt  = input.bool(true, "Filter line", group=g_d)
bool  showBands = input.bool(true, "Range bands", group=g_d)
bool  showSigs  = input.bool(true, "Buy / Sell labels", group=g_d)
bool  showEma   = input.bool(false, "200 EMA (version C's filter)", group=g_d)
color cUp   = input.color(#26a69a, "Up", group=g_d)
color cDn   = input.color(#ef5350, "Down", group=g_d)
color cFlat = input.color(#f5a623, "Flat", group=g_d)

// ─── THE RANGE FILTER ──────────────────────────────────────────────────────────
f_rf(float x, int p, float m) =>
    float avr = ta.ema(math.abs(x - x[1]), p)
    float smr = ta.ema(avr, p * 2 - 1) * m
    float f = x
    f := x > nz(f[1]) ? (x - smr < nz(f[1]) ? nz(f[1]) : x - smr) : (x + smr > nz(f[1]) ? nz(f[1]) : x + smr)
    float up = 0.0
    up := f > f[1] ? nz(up[1]) + 1 : f < f[1] ? 0 : nz(up[1])
    float dn = 0.0
    dn := f < f[1] ? nz(dn[1]) + 1 : f > f[1] ? 0 : nz(dn[1])
    bool lc = x > f and x > x[1] and up > 0 or x > f and x < x[1] and up > 0
    bool sc = x < f and x < x[1] and dn > 0 or x < f and x > x[1] and dn > 0
    int ci = 0
    ci := lc ? 1 : sc ? -1 : ci[1]
    [f, smr, lc and ci[1] == -1, sc and ci[1] == 1]

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

f_ok(string cfIn, int d, float c, float f, float smr, float adx, float e200, float thrIn, float kIn) =>
    cfIn == fADX ? (not na(adx) and adx >= thrIn) : cfIn == fEMA ? (not na(e200) and d * (c - e200) > 0) : d * (c - f) >= kIn * smr

type Led
    int   pend = 0
    float pSt  = na
    float pTg  = na
    float pRk  = na
    int   pos  = 0
    float e    = na
    float st   = na
    float tg   = na
    float rk   = na
    int   n    = 0
    int   w    = 0
    float sumR = 0.0

method book(Led L, float x) =>
    float r = L.pos * (x - L.e) / L.rk
    L.n += 1
    L.w += r > 0 ? 1 : 0
    L.sumR += r
    L.pos := 0

// B and C: fill a pending entry at the open, then check the exits along the candle's path.
method stepBC(Led L, float o, float h, float l) =>
    if L.pend != 0
        L.pos := L.pend
        L.e := o
        L.st := L.pSt
        L.tg := L.pTg
        L.rk := L.pRk
        L.pend := 0
    if L.pos != 0
        float x = f_exit(L.pos, o, h, l, L.st, L.tg)
        if not na(x)
            L.book(x)

// The whole test on one market (runs in that market's own context).
f_engine(int t0, int t1, int p, float m, float rrIn, string cfIn, float thrIn, float kIn) =>
    float o = open, h = high, l = low, c = close
    [f, smr, ls, ss] = f_rf(c, p, m)
    [dip, dim, adx] = ta.dmi(14, 14)
    float e200 = ta.ema(c, 200)
    var Led A = Led.new()
    var Led B = Led.new()
    var Led C = Led.new()
    var bool aClose = false
    var int nFlip = 0
    var int nFast = 0
    var int lastFlip = na
    // this candle's open: fills and exits
    if aClose and A.pos != 0
        A.book(o)
    aClose := false
    if A.pend != 0
        if A.pos != 0
            A.book(o)
        A.pos := A.pend
        A.e := o
        A.rk := A.pRk
        A.pend := 0
    B.stepBC(o, h, l)
    C.stepBC(o, h, l)
    // its close: the window end or a new flip
    if time > t1
        if A.pos != 0 and A.pend == 0
            aClose := true
    else if barstate.isconfirmed and time >= t0 and (ls or ss)
        int d = ls ? 1 : -1
        float st = d == 1 ? f - smr : f + smr
        float rk = d * (c - st)
        float tg = c + d * rrIn * rk
        bool ok = f_ok(cfIn, d, c, f, smr, adx, e200, thrIn, kIn)
        nFlip += 1
        if not na(lastFlip) and bar_index - lastFlip <= 12
            nFast += 1
        lastFlip := bar_index
        if A.pend == 0
            A.pend := d
            A.pRk := rk
        if B.pos == 0 and B.pend == 0
            B.pend := d
            B.pSt := st
            B.pTg := tg
            B.pRk := rk
        if ok and C.pos == 0 and C.pend == 0
            C.pend := d
            C.pSt := st
            C.pTg := tg
            C.pRk := rk
    [A.n, A.w, A.sumR, B.n, B.w, B.sumR, C.n, C.w, C.sumR, nFlip, nFast]

// ─── THIS CHART ────────────────────────────────────────────────────────────────
[filt, smrng, longSig, shortSig] = f_rf(close, per, mult)
float hband = filt + smrng
float lband = filt - smrng
color fCol = filt > filt[1] ? cUp : filt < filt[1] ? cDn : cFlat
pF = plot(showFilt ? filt : na, "Range Filter", color=fCol, linewidth=3, display=display.pane + display.data_window)
pH = plot(showBands ? hband : na, "High band", color=color.new(cUp, 60), linewidth=1, display=display.pane + display.data_window)
pL = plot(showBands ? lband : na, "Low band", color=color.new(cDn, 60), linewidth=1, display=display.pane + display.data_window)
fill(pH, pF, color=color.new(cUp, 92), title="Upper range")
fill(pF, pL, color=color.new(cDn, 92), title="Lower range")
plotshape(showSigs and longSig, "Buy", shape.labelup, location.belowbar, cUp, text="Buy", textcolor=color.white, size=size.small)
plotshape(showSigs and shortSig, "Sell", shape.labeldown, location.abovebar, cDn, text="Sell", textcolor=color.white, size=size.small)

// Strategy Tester orders: the version chosen in the inputs.
[dip0, dim0, adx0] = ta.dmi(14, 14)
float e2000 = ta.ema(close, 200)
plot(adx0, "ADX (14)", display=display.data_window)
plot(showEma ? e2000 : na, "200 EMA", color=color.new(#e0e3eb, 0), linewidth=2, display=display.pane + display.data_window)
bool inWindow = time >= tStart and time <= tEnd
float riskMoney = strategy.initial_capital * riskPct / 100
if barstate.isconfirmed and inWindow and (longSig or shortSig)
    int d = longSig ? 1 : -1
    float st = d == 1 ? lband : hband
    float rk = d * (close - st)
    float tg = close + d * rr * rk
    float q = riskMoney / rk
    string id = d == 1 ? "Buy" : "Sell"
    if ver == verA
        strategy.entry(id, d == 1 ? strategy.long : strategy.short, qty=q)
    else if strategy.position_size == 0 and (ver == verB or f_ok(cf, d, close, filt, smrng, adx0, e2000, thr, kD))
        strategy.entry(id, d == 1 ? strategy.long : strategy.short, qty=q)
        strategy.exit(id + " exit", id, stop=st, limit=tg)
if ver == verA and barstate.isconfirmed and time > tEnd and strategy.position_size != 0
    strategy.close_all(comment="Test window ended")

// ─── THE TABLE ─────────────────────────────────────────────────────────────────
[a1n, a1w, a1r, b1n, b1w, b1r, c1n, c1w, c1r, f1n, f1f] = request.security(ticker.standard(sym1), timeframe.period, f_engine(tStart, tEnd, per, mult, rr, cf, thr, kD))
[a2n, a2w, a2r, b2n, b2w, b2r, c2n, c2w, c2r, f2n, f2f] = request.security(ticker.standard(sym2), timeframe.period, f_engine(tStart, tEnd, per, mult, rr, cf, thr, kD))
[a3n, a3w, a3r, b3n, b3w, b3r, c3n, c3w, c3r, f3n, f3f] = request.security(ticker.standard(sym3), timeframe.period, f_engine(tStart, tEnd, per, mult, rr, cf, thr, kD))
[a4n, a4w, a4r, b4n, b4w, b4r, c4n, c4w, c4r, f4n, f4f] = request.security(ticker.standard(sym4), timeframe.period, f_engine(tStart, tEnd, per, mult, rr, cf, thr, kD))

f_rtxt(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.0") + "R"
f_name(string s) => array.last(str.split(s, ":"))
f_led(int w, int n, float r) => str.tostring(n) + " trades   " + f_rtxt(r)

string posTxt = tPos
var table tb = table.new(posTxt == "Top right" ? position.top_right : posTxt == "Bottom right" ? position.bottom_right : posTxt == "Bottom left" ? position.bottom_left : position.top_left,
     5, 8, bgcolor=color.new(#131722, 6), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)
if showTable and (barstate.islastconfirmedhistory or barstate.isrealtime)
    string ts = tSize == "Huge" ? size.huge : tSize == "Large" ? size.large : size.normal
    color hd = color.new(color.white, 0)
    color mu = color.new(#b2b5be, 0)
    string cName = cf == fADX ? "ADX " + str.tostring(thr, "#") + "+" : cf == fEMA ? "200 EMA side" : str.tostring(kD, "0.0#") + " range away"
    table.cell(tb, 0, 0, "Same flips", text_color=mu, text_size=ts)
    table.cell(tb, 1, 0, "A  Default", text_color=hd, text_size=ts)
    table.cell(tb, 2, 0, "B  Stop + " + str.tostring(rr, "0.0#") + "R", text_color=hd, text_size=ts)
    table.cell(tb, 3, 0, "C  Fix: " + cName, text_color=hd, text_size=ts)
    table.cell(tb, 4, 0, "Fast flips", text_color=mu, text_size=ts)
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
    array<int>   fn = array.from(f1n, f2n, f3n, f4n)
    array<int>   ff = array.from(f1f, f2f, f3f, f4f)
    int tan = 0
    int tbn = 0
    int tcn = 0
    int tfn = 0
    int tff = 0
    float tar = 0.0
    float tbr = 0.0
    float tcr = 0.0
    for i = 0 to 3
        int row = i + 1
        table.cell(tb, 0, row, array.get(names, i), text_color=hd, text_size=ts, text_halign=text.align_left)
        table.cell(tb, 1, row, f_led(array.get(aw, i), array.get(an, i), array.get(ar, i)), text_color=array.get(ar, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 2, row, f_led(array.get(bw, i), array.get(bn, i), array.get(br, i)), text_color=array.get(br, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 3, row, f_led(array.get(cw, i), array.get(cn, i), array.get(cr, i)), text_color=array.get(cr, i) >= 0 ? cUp : cDn, text_size=ts)
        table.cell(tb, 4, row, str.tostring(array.get(ff, i)) + " of " + str.tostring(array.get(fn, i)), text_color=mu, text_size=ts)
        tan += array.get(an, i)
        tar += array.get(ar, i)
        tbn += array.get(bn, i)
        tbr += array.get(br, i)
        tcn += array.get(cn, i)
        tcr += array.get(cr, i)
        tfn += array.get(fn, i)
        tff += array.get(ff, i)
    table.cell(tb, 0, 5, "All four", text_color=hd, text_size=ts, text_halign=text.align_left)
    table.cell(tb, 1, 5, f_led(0, tan, tar), text_color=tar >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 2, 5, f_led(0, tbn, tbr), text_color=tbr >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 3, 5, f_led(0, tcn, tcr), text_color=tcr >= 0 ? cUp : cDn, text_size=ts)
    table.cell(tb, 4, 5, str.tostring(tff) + " of " + str.tostring(tfn), text_color=mu, text_size=ts)
    table.cell(tb, 0, 6, "Range Filter " + str.tostring(per) + " / " + str.tostring(mult, "0.0#") + " · " + timeframe.period + " min · " + str.format_time(tStart, "yyyy-MM-dd", "UTC") + " to " + str.format_time(tEnd, "yyyy-MM-dd", "UTC") + " · before costs", text_color=mu, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 6, 4, 6)
    table.cell(tb, 0, 7, "Fast flip = the next flip came within 12 candles: the market went sideways", text_color=mu, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 7, 4, 7)
````
