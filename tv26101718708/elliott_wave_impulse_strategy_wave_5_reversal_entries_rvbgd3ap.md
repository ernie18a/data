# Elliott Wave Impulse Strategy | Wave 5 & Reversal Entries

- url: https://www.tradingview.com/script/rvBgD3aP-Elliott-Wave-Impulse-Strategy-Wave-5-Reversal-Entries/
- type: strategy
- pine_id: PUB;122abcd3fbcf44d8882b7c928245eb71
- version: 1.0

## Description

[b]Credit and thanks[/b]
This strategy is built on “Elliott Wave [LuxAlgo]” by LuxAlgo, released under CC BY-NC-SA 4.0. Thank you to LuxAlgo for the original zigzag and wave-detection work. This script is for non-commercial use and is shared under the same license.

[b]How I adapted the indicator[/b]
The original is a visual tool that labels waves. I kept its core pieces and added a trading layer on top:
[list]
[*]Zigzag pivots, using the same alternating pivot logic.
[*]The same 5-wave impulse test: wave 3 cannot be the shortest, and waves 2 and 4 must respect the usual limits.
[*]The (0)–(5) wave labels and the 0.500 / 0.618 / 0.764 / 0.854 Fibonacci retracement lines, with the shaded zone between the last two.
[*]I removed the multi-degree zigzags and the ABC correction tracking to keep it simple, and added entries, stops, targets, position sizing and a stats dashboard.
[/list]

[b]How the strategy works[/b]
[list]
[*]It has two setups, selected with Entry Mode:
[*]Reversal. After a full 5-wave impulse completes and a confirmed pivot turns the other way, it trades against the move. The stop goes just beyond the wave 5 extreme and the target is a Fibonacci retracement of the whole impulse (0.5 by default).
[*]Wave 5. After waves 0–4 form and wave 4 retraces 23.6%–61.8% of wave 3 without breaking wave 1, it trades with the trend. The stop goes just beyond the wave 4 extreme and the target is the length of wave 1 projected from there.
[*]Every trade also has to pass these checks:
[*]The impulse (or wave 3 for the Wave 5 setup) must be at least 1.5 × ATR.
[*]Reward-to-risk must be at least 1.0.
[*]Only one position at a time, with no reversals.
[*]Any open trade closes after 100 bars if neither stop nor target was hit.
[/list]

[b]Features[/b]
[list]
[*]Two setups in one script, selectable or combined.
[*]Automatic wave labels and Fibonacci lines on the chart.
[*]Stop and target lines drawn at entry, with price labels.
[*]Position size set from risk (1% of equity by default), capped at 100% of equity so there is no leverage by default.
[*]Direction filter (long only, short only, both).
[*]Dashboard with position, last setup, net profit, trades, win rate, profit factor and max drawdown.
[*]Commission and slippage built in as realistic defaults.
[/list]

[b]Tips[/b]
[list]
[*]Test on 1 hour to 4 hour charts first and use a long history, because the setups are selective.
[*]ZigZag Length controls everything: smaller values find more, smaller waves; larger values find fewer, bigger ones.
[*]Run Entry Mode “Reversal” and “Wave 5” separately and compare profit factor to see which setup suits your market.
[*]Position size comes from the risk input, not the default order size in Properties.
[*]Judge results by profit factor and drawdown after costs, not by win rate alone.
[/list]

[b]Warnings[/b]
[list]
[*]Elliott Wave counting is subjective. This script applies one fixed set of rules and does not claim they are the “correct” count.
[*]Pivots confirm very quickly, so some detected waves will be false patterns, especially on low timeframes.
[*]The Reversal setup trades against the trend. When wave 5 extends or the trend simply continues, it will lose.
[*]The Wave 5 setup can fail if the count is wrong.
[*]Backtests are not predictions. Past performance does not guarantee future results, and results depend heavily on the market, timeframe and settings.
[*]Orders fill on the next bar, so real fills will differ from the signal bar’s close.
[*]This is not financial advice. Test on historical and paper data before using real money.
[/list]

## Source Code

````pine
// Pivot logic, 5-wave impulse test and fib visuals adapted from "Elliott Wave [LuxAlgo]"
// © LuxAlgo — CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
// Strategy layer added. Non-commercial use only; derivatives must keep the same license.

//@version=6
strategy(
     title              = "Elliott Wave Impulse Strategy | Wave 5 & Reversal Entries",
     shorttitle         = "EW-S",
     overlay            = true,
     initial_capital    = 10000,
     default_qty_type   = strategy.percent_of_equity,
     default_qty_value  = 25,
     commission_type    = strategy.commission.percent,
     commission_value   = 0.05,
     slippage           = 2,
     pyramiding         = 0,
     calc_on_every_tick = false,
     max_bars_back      = 500,
     max_lines_count    = 500,
     max_labels_count   = 500)

// ── Inputs ──
zzLen      = input.int(5, "ZigZag Length", minval = 2, group = "ZigZag")
zzCol      = input.color(color.blue, "ZigZag / Wave Color", group = "ZigZag")
showZZ     = input.bool(false, "Show ZigZag Line", group = "ZigZag")

fib1       = input.float(0.500, "Fib Level 1", minval = 0, maxval = 1, step = 0.01, group = "Fibonacci")
fib2       = input.float(0.618, "Fib Level 2", minval = 0, maxval = 1, step = 0.01, group = "Fibonacci")
fib3       = input.float(0.764, "Fib Level 3", minval = 0, maxval = 1, step = 0.01, group = "Fibonacci")
fib4       = input.float(0.854, "Fib Level 4", minval = 0, maxval = 1, step = 0.01, group = "Fibonacci")

entryMode   = input.string("Both", "Entry Mode", options = ["Reversal", "Wave 5", "Both"], group = "Strategy",
     tooltip = "Reversal: fade the end of a finished 5-wave impulse.\nWave 5: trade with the trend after wave 4 is confirmed.\nBoth: either setup.")
tradeDir    = input.string("Both", "Direction", options = ["Both", "Long Only", "Short Only"], group = "Strategy")
tgtFib      = input.float(0.5, "Reversal Target (retracement of impulse)", minval = 0.2, maxval = 1.0, step = 0.01, group = "Strategy")
w5Ext       = input.float(1.0, "Wave 5 Target (× wave 1)", minval = 0.3, step = 0.1, group = "Strategy")
minRet4     = input.float(0.236, "Wave 4 Min Retracement of Wave 3", minval = 0.05, maxval = 0.9, step = 0.01, group = "Strategy")
maxRet4     = input.float(0.618, "Wave 4 Max Retracement of Wave 3", minval = 0.1, maxval = 0.99, step = 0.01, group = "Strategy")
minImp      = input.float(1.5, "Min Impulse Size (× ATR)", minval = 0.5, step = 0.5, group = "Strategy")
stopBuf     = input.float(0.2, "Stop Buffer (× ATR)", minval = 0.0, step = 0.1, group = "Strategy")
minRR       = input.float(1.0, "Min Reward:Risk", minval = 0.5, step = 0.1, group = "Strategy")
maxBars     = input.int(100, "Time Stop (Bars)", minval = 5, group = "Strategy")
atrLen      = input.int(14, "ATR Length", minval = 2, group = "Strategy")
riskPct     = input.float(1.0, "Risk Per Trade (% of equity)", minval = 0.1, maxval = 10.0, step = 0.1, group = "Strategy")
maxNotional = input.float(100.0, "Max Position Size (% of equity)", minval = 10.0, maxval = 500.0, step = 10.0, group = "Strategy", tooltip = "100 = no leverage.")
showDash    = input.bool(true, "Show Dashboard", group = "Strategy")

// ── 5-wave impulse check (p0 oldest, p5 newest; d = 1 bullish, -1 bearish) ──
isImpulse(float p0, float p1, float p2, float p3, float p4, float p5, int d) =>
    bool ok = false
    if d == 1
        float w1 = p1 - p0
        float w3 = p3 - p2
        float w5 = p5 - p4
        ok := w3 != math.min(w1, w3, w5) and p5 > p3 and p2 > p0 and p4 > p1
    else
        float w1 = p0 - p1
        float w3 = p2 - p3
        float w5 = p4 - p5
        ok := w3 != math.min(w1, w3, w5) and p3 > p5 and p0 > p2 and p1 > p4
    ok

// ── Position size from risk ──
calcQty(float riskDist) =>
    float byRisk = riskDist > 0 ? strategy.equity * riskPct / 100.0 / riskDist : 0.0
    float byCap  = strategy.equity * maxNotional / 100.0 / close
    math.min(byRisk, byCap)

// ── ZigZag pivots ──
float atr = ta.atr(atrLen)
float ph  = ta.pivothigh(high, zzLen, 1)
float pl  = ta.pivotlow(low,  zzLen, 1)

var array<int>   zx   = array.new<int>()
var array<float> zy   = array.new<float>()
var int          zdir = 0
bool flipped = false

if not na(ph)
    int   x2 = bar_index - 1
    float y2 = nz(high[1])
    if zdir < 1
        zx.unshift(x2)
        zy.unshift(y2)
        zdir := 1
        flipped := true
        if showZZ and zx.size() > 1
            line.new(zx.get(1), zy.get(1), x2, y2, color = zzCol)
    else if ph > zy.get(0)
        zx.set(0, x2)
        zy.set(0, y2)

if not na(pl)
    int   x2 = bar_index - 1
    float y2 = nz(low[1])
    if zdir > -1
        zx.unshift(x2)
        zy.unshift(y2)
        zdir := -1
        flipped := true
        if showZZ and zx.size() > 1
            line.new(zx.get(1), zy.get(1), x2, y2, color = zzCol)
    else if pl < zy.get(0)
        zx.set(0, x2)
        zy.set(0, y2)

if zx.size() > 8
    zx.pop()
    zy.pop()

// ── Find setups ──
var array<line> fibLines = array.new<line>()
var linefill    fibFill  = na

int    sigDir  = 0
float  sigStop = na
float  sigTgt  = na
float  sigImp  = na
string sigType = ""

// Reversal: a finished 5-wave impulse, then a turn
if flipped and zy.size() >= 7 and entryMode != "Wave 5"
    int   d  = zdir == -1 ? 1 : -1
    float p0 = zy.get(6)
    float p1 = zy.get(5)
    float p2 = zy.get(4)
    float p3 = zy.get(3)
    float p4 = zy.get(2)
    float p5 = zy.get(1)

    if isImpulse(p0, p1, p2, p3, p4, p5, d)
        float diff = math.abs(p5 - p0)
        int   x5   = zx.get(1)

        for j = 0 to 5
            int   idx    = 6 - j
            int   x      = zx.get(idx)
            float y      = zy.get(idx)
            bool  isHigh = d == 1 ? j % 2 == 1 : j % 2 == 0
            label.new(x, y, j == 0 ? "0" : "(" + str.tostring(j) + ")",
                 style = isHigh ? label.style_label_down : label.style_label_up,
                 textcolor = zzCol, color = color.new(zzCol, 100))
            if j > 0
                line.new(zx.get(idx + 1), zy.get(idx + 1), x, y, color = zzCol, width = 2)

        for l in fibLines
            line.delete(l)
        fibLines.clear()
        if not na(fibFill)
            linefill.delete(fibFill)

        float sgn = d == 1 ? -1.0 : 1.0
        line l1 = line.new(x5, p5 + sgn * diff * fib1, bar_index + 10, p5 + sgn * diff * fib1, color = color.new(zzCol, 50))
        line l2 = line.new(x5, p5 + sgn * diff * fib2, bar_index + 10, p5 + sgn * diff * fib2, color = color.new(zzCol, 38))
        line l3 = line.new(x5, p5 + sgn * diff * fib3, bar_index + 10, p5 + sgn * diff * fib3, color = color.new(zzCol, 24))
        line l4 = line.new(x5, p5 + sgn * diff * fib4, bar_index + 10, p5 + sgn * diff * fib4, color = color.new(zzCol, 15))
        fibLines.push(l1)
        fibLines.push(l2)
        fibLines.push(l3)
        fibLines.push(l4)
        fibFill := linefill.new(l3, l4, color.new(color.lime, 90))

        sigDir  := d == 1 ? -1 : 1
        sigStop := d == 1 ? p5 + stopBuf * atr : p5 - stopBuf * atr
        sigTgt  := p5 + sgn * diff * tgtFib
        sigImp  := diff
        sigType := "Reversal"

// Wave 5: trade with the trend after wave 4 ends
if flipped and sigDir == 0 and zy.size() >= 5 and entryMode != "Reversal"
    int   d  = zdir == -1 ? 1 : -1
    float p4 = zy.get(0)
    float p3 = zy.get(1)
    float p2 = zy.get(2)
    float p1 = zy.get(3)
    float p0 = zy.get(4)

    bool  ok = false
    float w1 = 0.0
    float w3 = 0.0
    if d == 1
        w1 := p1 - p0
        w3 := p3 - p2
        float ret = w3 > 0 ? (p3 - p4) / w3 : na
        ok := w3 > w1 and w1 > 0 and p2 > p0 and p4 > p1 and not na(ret) and ret >= minRet4 and ret <= maxRet4
    else
        w1 := p0 - p1
        w3 := p2 - p3
        float ret = w3 > 0 ? (p4 - p3) / w3 : na
        ok := w3 > w1 and w1 > 0 and p0 > p2 and p1 > p4 and not na(ret) and ret >= minRet4 and ret <= maxRet4

    if ok
        for j = 0 to 4
            int   idx    = 4 - j
            int   x      = zx.get(idx)
            float y      = zy.get(idx)
            bool  isHigh = d == 1 ? j % 2 == 1 : j % 2 == 0
            label.new(x, y, j == 0 ? "0" : "(" + str.tostring(j) + ")",
                 style = isHigh ? label.style_label_down : label.style_label_up,
                 textcolor = zzCol, color = color.new(zzCol, 100))
            if j > 0
                line.new(zx.get(idx + 1), zy.get(idx + 1), x, y, color = zzCol, width = 2)

        sigDir  := d
        sigStop := d == 1 ? p4 - stopBuf * atr : p4 + stopBuf * atr
        sigTgt  := d == 1 ? p4 + w1 * w5Ext : p4 - w1 * w5Ext
        sigImp  := w3
        sigType := "Wave 5"

// ── Orders ──
float risk   = sigDir == -1 ? sigStop - close : sigDir == 1 ? close - sigStop : na
float reward = sigDir == -1 ? close - sigTgt  : sigDir == 1 ? sigTgt - close  : na
float rr     = not na(risk) and risk > 0 and not na(reward) and reward > 0 ? reward / risk : 0.0
bool  okSize = not na(sigImp) and not na(atr) and sigImp >= minImp * atr

bool canTrade = strategy.position_size == 0 and barstate.isconfirmed and bar_index > 50
bool longSig  = canTrade and sigDir == 1  and okSize and rr >= minRR and tradeDir != "Short Only"
bool shortSig = canTrade and sigDir == -1 and okSize and rr >= minRR and tradeDir != "Long Only"

var float  curStop  = na
var float  curTgt   = na
var int    entryBar = na
var string lastType = "—"

if longSig
    curStop  := sigStop
    curTgt   := sigTgt
    lastType := sigType + " ▲"
    strategy.entry("EW Long", strategy.long, qty = calcQty(risk), comment = lastType)
    strategy.exit("X Long", "EW Long", stop = curStop, limit = curTgt)

if shortSig
    curStop  := sigStop
    curTgt   := sigTgt
    lastType := sigType + " ▼"
    strategy.entry("EW Short", strategy.short, qty = calcQty(risk), comment = lastType)
    strategy.exit("X Short", "EW Short", stop = curStop, limit = curTgt)

// Draw stop and target when a trade opens
bool opened = strategy.position_size != 0 and strategy.position_size[1] == 0
if opened
    entryBar := bar_index
    if not na(curStop) and not na(curTgt)
        line.new(bar_index, curStop, bar_index + 20, curStop, color = color.red,  width = 2)
        line.new(bar_index, curTgt,  bar_index + 20, curTgt,  color = color.lime, style = line.style_dashed)
        label.new(bar_index + 21, curStop, "SL "  + str.tostring(curStop, format.mintick), style = label.style_label_left, color = color.red,  textcolor = color.white, size = size.tiny)
        label.new(bar_index + 21, curTgt,  "TGT " + str.tostring(curTgt,  format.mintick), style = label.style_label_left, color = color.lime, textcolor = color.black, size = size.tiny)

// Keep exits active and close on time stop
if strategy.position_size > 0
    strategy.exit("X Long", "EW Long", stop = curStop, limit = curTgt)
    if not na(entryBar) and bar_index - entryBar >= maxBars
        strategy.close("EW Long", comment = "Time stop")

if strategy.position_size < 0
    strategy.exit("X Short", "EW Short", stop = curStop, limit = curTgt)
    if not na(entryBar) and bar_index - entryBar >= maxBars
        strategy.close("EW Short", comment = "Time stop")

// ── Entry markers ──
bool isW5 = sigType == "Wave 5"

plotshape(longSig and isW5,      "Long W5",   shape.labelup,   location.belowbar, color = color.lime, textcolor = color.black, text = "W5 ▲",  size = size.small)
plotshape(longSig and not isW5,  "Long Rev",  shape.labelup,   location.belowbar, color = color.lime, textcolor = color.black, text = "Rev ▲", size = size.small)
plotshape(shortSig and isW5,     "Short W5",  shape.labeldown, location.abovebar, color = color.red,  textcolor = color.white, text = "W5 ▼",  size = size.small)
plotshape(shortSig and not isW5, "Short Rev", shape.labeldown, location.abovebar, color = color.red,  textcolor = color.white, text = "Rev ▼", size = size.small)

// ── Dashboard ──
var table dash = table.new(position.top_right, 2, 7, bgcolor = #131722, border_color = #2A2E39, border_width = 1, frame_color = #2A2E39, frame_width = 1)

f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color = #9E9E9E, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = c,       text_size = size.small, text_halign = text.align_left)

if barstate.islast and showDash
    int   closed  = strategy.closedtrades
    float winRate = closed > 0 ? strategy.wintrades / closed * 100.0 : na
    float pf      = strategy.grossloss > 0 ? strategy.grossprofit / strategy.grossloss : na
    color netCol  = strategy.netprofit > 0 ? #00E676 : strategy.netprofit < 0 ? #FF5252 : #E0E0E0

    f_row(0, "Position",      strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "Flat", #E0E0E0)
    f_row(1, "Last setup",    lastType, #E0E0E0)
    f_row(2, "Net profit",    str.tostring(strategy.netprofit, "#.##"), netCol)
    f_row(3, "Trades",        str.tostring(closed) + "  (W " + str.tostring(strategy.wintrades) + " / L " + str.tostring(strategy.losstrades) + ")", #E0E0E0)
    f_row(4, "Win rate",      na(winRate) ? "—" : str.tostring(winRate, "#.#") + "%", #E0E0E0)
    f_row(5, "Profit factor", na(pf) ? "—" : str.tostring(pf, "#.##"), #E0E0E0)
    f_row(6, "Max drawdown",  str.tostring(strategy.max_drawdown, "#.##"), #FF5252)
````
