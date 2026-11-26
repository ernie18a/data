# Relative Strength Rotation Strategy [Jayadev Rana]

- url: https://www.tradingview.com/script/3F1KQb6D-Relative-Strength-Rotation-Strategy-Jayadev-Rana/
- type: strategy
- pine_id: PUB;c878f15b8e8c437a80454973127b6b3d
- version: 1.0

## Description

WHAT IT IS

Relative Strength Rotation Strategy trades a symbol on how it performs against a benchmark rather than on its own price alone. The idea comes from rotation and relative-strength investing: capital flows toward what is outperforming and leaves what is underperforming, and that flow tends to persist for a while. The script builds a relative-strength line, scores it in three complementary ways and rotates into the symbol while the score says it is gaining ground on the benchmark, and out when that advantage fades.

HOW IT WORKS

1. Benchmark. Leave the benchmark input blank and the script selects one by asset class (a crypto total-cap index for crypto, the dollar index for forex, the S and P 500 index for everything else), or type any symbol. The benchmark close is requested on the chart timeframe without lookahead and forward-filled across bars the benchmark does not trade.

2. Relative strength line. RS = natural log of (symbol close / benchmark close). Rising RS means the symbol is outperforming.

3. Three scores.
- Rotation score (0 to 100): RS momentum over three horizons (default 20, 50 and 100 bars) is each ranked against its own history over the percentile window, and the three ranks are averaged. A high score means RS is accelerating on short, medium and long horizons at once.
- Mansfield relative strength: the symbol-to-benchmark ratio divided by its long simple moving average, minus one, in percent. Positive means the symbol is above its normal relative performance.
- RS slope z-score: the one-bar change of a linear regression of RS, divided by its standard deviation. It measures how steep the current RS move is compared with the usual.

4. Entries. A long opens when the rotation score crosses above the entry level (default 70) while the Mansfield RS is positive, the slope z-score is above its threshold and, optionally, price is above its own EMA. A short opens on the mirrored conditions below 100 minus the entry level. A cooldown prevents immediate re-entry after an exit.

5. Exits. The position is closed when the rotation score falls back through the exit level (default 50) or the Mansfield RS flips sign, whichever comes first. A wide ATR-based catastrophic stop protects against gaps. Each optional filter can be switched off.

ON THE CHART

BUY and SELL labels mark entries, crosses mark exits, the price EMA and the active ATR stop are drawn, and the background is shaded from red to green by the rotation score. The status table shows the benchmark in use, the score with its three component ranks, Mansfield RS, slope z-score, price versus EMA, position, which side is currently allowed by the filters, and the closed-trade count. Data-window plots expose the score, Mansfield RS, slope z-score and the raw ratio.

STRATEGY PROPERTIES USED

Initial capital 10,000. Order size 20% of equity. Commission 0.05% per side. Slippage 2 ticks. Fills on the next bar open. No pyramiding. Adjust to your instrument and account.

INPUTS

Benchmark: symbol override.
Relative strength scoring: three momentum horizons, percentile window, Mansfield average length, slope length.
Entries and exits: entry and exit score levels, Mansfield and slope filters, slope threshold, price EMA filter and length, long and short switches, ATR stop multiple, cooldown.
Display: status table, background shading.

ALERTS

The strategy calls alert() on long entry, short entry and position close.

INTENDED USE

Daily and 4-hour charts of stocks, sector ETFs, index futures and major crypto pairs against a suitable benchmark. The method is slow by design and aims to hold through sustained periods of relative outperformance; it is not a scalping tool.

LIMITATIONS

Relative strength is a lagging measure and reverses after the fact. If the benchmark is poorly chosen the signals are meaningless, so check the benchmark row in the table. Benchmarks with a different trading calendar are forward-filled, which flattens RS on bars where the benchmark is closed. The score depends on the percentile window and is undefined until that many bars have loaded. Backtest results vary strongly with the symbol and benchmark pair.

Published for study and research only. Not financial advice. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// ============================================================================
//  Relative Strength Rotation Strategy [Jayadev Rana]
//  Trades the chart symbol on the strength of its performance RELATIVE to a
//  benchmark, not on its own price alone. The relative-strength line
//  (log ratio of symbol to benchmark) is scored three ways: multi-horizon RS
//  momentum ranked against its own history, a Mansfield-style RS deviation
//  from its long moving average, and the volatility-normalised slope of the
//  RS line. Longs rotate in when the symbol is gaining strength against the
//  benchmark and rotate out when that strength decays; shorts mirror it.
// ============================================================================
strategy("Relative Strength Rotation Strategy [Jayadev Rana]", shorttitle = "RSRS", overlay = true, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 20, commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2, pyramiding = 0, margin_long = 100, margin_short = 100, calc_on_every_tick = false, max_labels_count = 100)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gB = "Benchmark"
benchIn = input.string("", "Benchmark symbol (blank = auto)", group = gB, tooltip = "Leave blank to pick CRYPTOCAP:TOTAL for crypto, TVC:DXY for forex, SP:SPX for everything else. Enter any symbol (e.g. NASDAQ:QQQ, NSE:NIFTY) to override.")

gS = "Relative strength scoring"
h1 = input.int(20, "RS momentum horizon 1", minval = 2, group = gS)
h2 = input.int(50, "RS momentum horizon 2", minval = 2, group = gS)
h3 = input.int(100, "RS momentum horizon 3", minval = 2, group = gS)
rankLen = input.int(250, "Percentile window", minval = 50, maxval = 2000, group = gS, tooltip = "Each RS momentum horizon is ranked against its own last N values; the score is the average of the three ranks (0-100).")
mansLen = input.int(52, "Mansfield RS average length", minval = 10, maxval = 500, group = gS, tooltip = "Mansfield RS = ratio / its simple moving average - 1. Positive means the symbol is above its average relative performance.")
slopeLen = input.int(20, "RS slope length", minval = 5, maxval = 200, group = gS)

gE = "Entries and exits"
entryScore = input.float(70, "Long entry score", minval = 50, maxval = 95, step = 1, group = gE)
exitScore  = input.float(50, "Long exit score", minval = 20, maxval = 80, step = 1, group = gE)
needMans   = input.bool(true, "Require Mansfield RS on the trade side", group = gE)
needSlope  = input.bool(true, "Require RS slope z-score on the trade side", group = gE)
slopeZ     = input.float(0.5, "RS slope z-score threshold", minval = 0, maxval = 3, step = 0.1, group = gE)
usePx      = input.bool(true, "Require price above / below its own EMA", group = gE)
pxLen      = input.int(100, "Price EMA length", minval = 10, maxval = 500, group = gE)
allowL     = input.bool(true, "Allow longs", group = gE)
allowS     = input.bool(true, "Allow shorts", group = gE, tooltip = "Shorts use the mirrored thresholds: entry below 100 - long entry score, exit above 100 - long exit score.")
atrStop    = input.float(3.0, "Catastrophic ATR stop (x)", minval = 0.5, maxval = 10, step = 0.5, group = gE)
cooldown   = input.int(5, "Cooldown after exit (bars)", minval = 0, maxval = 100, group = gE)

gV = "Display"
showTbl = input.bool(true, "Status table", group = gV)
showBg  = input.bool(true, "Shade background by score", group = gV)

// ───────────────────────────── 2. Relative strength ─────────────────────────────
autoBench = syminfo.type == "crypto" ? "CRYPTOCAP:TOTAL" : syminfo.type == "forex" ? "TVC:DXY" : "SP:SPX"
bench  = benchIn == "" ? autoBench : benchIn
bRaw   = request.security(bench, timeframe.period, close, lookahead = barmerge.lookahead_off)
bClose = fixnan(bRaw)
ratio  = bClose > 0 ? close / bClose : na
rs     = math.log(ratio)

m1 = rs - rs[h1]
m2 = rs - rs[h2]
m3 = rs - rs[h3]
r1 = ta.percentrank(m1, rankLen)
r2 = ta.percentrank(m2, rankLen)
r3 = ta.percentrank(m3, rankLen)
score = (r1 + r2 + r3) / 3.0

mansAvg = ta.sma(ratio, mansLen)
mans    = mansAvg > 0 ? (ratio / mansAvg - 1) * 100 : 0.0
slope   = ta.linreg(rs, slopeLen, 0) - ta.linreg(rs, slopeLen, 1)
slopeSd = ta.stdev(slope, rankLen)
sZ      = slopeSd > 0 ? slope / slopeSd : 0.0

emaPx = ta.ema(close, pxLen)
atr   = ta.atr(14)

longOk  = (not needMans or mans > 0) and (not needSlope or sZ > slopeZ) and (not usePx or close > emaPx)
shortOk = (not needMans or mans < 0) and (not needSlope or sZ < -slopeZ) and (not usePx or close < emaPx)

// ───────────────────────────── 3. Orders ─────────────────────────────
var int lastExit = -100000
flat    = strategy.position_size == 0
inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0
coolOk  = bar_index - lastExit > cooldown
ready   = not na(score) and not na(mans) and bar_index > rankLen

xUp = ta.crossover(score, entryScore)
xDn = ta.crossunder(score, 100 - entryScore)
enterL = ready and flat and coolOk and allowL and xUp and longOk
enterS = ready and flat and coolOk and allowS and xDn and shortOk
exitL  = inLong and (score < exitScore or (needMans and mans < 0))
exitS  = inShort and (score > 100 - exitScore or (needMans and mans > 0))

if enterL
    strategy.entry("Long", strategy.long, comment = "BUY")
if enterS
    strategy.entry("Short", strategy.short, comment = "SELL")
if inLong
    strategy.exit("Long stop", "Long", stop = strategy.position_avg_price - atrStop * atr, comment = "ATR STOP")
    if exitL
        strategy.close("Long", comment = "RS EXIT")
if inShort
    strategy.exit("Short stop", "Short", stop = strategy.position_avg_price + atrStop * atr, comment = "ATR STOP")
    if exitS
        strategy.close("Short", comment = "RS EXIT")
if flat and not flat[1]
    lastExit := bar_index

// ───────────────────────────── 4. Visuals ─────────────────────────────
cBull = color.new(#26a69a, 0)
cBear = color.new(#ef5350, 0)
longEntry  = inLong and not inLong[1]
shortEntry = inShort and not inShort[1]
exitBar    = flat and not flat[1]
plotshape(longEntry, "BUY", shape.labelup, location.belowbar, cBull, text = "BUY", textcolor = color.white, size = size.small)
plotshape(shortEntry, "SELL", shape.labeldown, location.abovebar, cBear, text = "SELL", textcolor = color.white, size = size.small)
plotshape(exitBar, "EXIT", shape.xcross, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
plot(emaPx, "Price EMA", color.new(color.gray, 40), 1)
plot(inLong ? strategy.position_avg_price - atrStop * atr : inShort ? strategy.position_avg_price + atrStop * atr : na, "ATR stop", cBear, 1, plot.style_linebr)
bgcolor(showBg and ready ? color.new(color.from_gradient(score, 0, 100, cBear, cBull), 90) : na)
plot(score, "RS rotation score", display = display.data_window)
plot(mans, "Mansfield RS %", display = display.data_window)
plot(sZ, "RS slope z-score", display = display.data_window)
plot(ratio, "Symbol / benchmark ratio", display = display.data_window)

var table tbl = na
row(int r, string a, string b, color tc = color.white) =>
    table.cell(tbl, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(tbl, 1, r, b, text_color = tc, text_size = size.small)
if showTbl and (barstate.islastconfirmedhistory or barstate.isrealtime)
    if na(tbl)
        tbl := table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    row(0, "Benchmark", bench)
    row(1, "Rotation score", str.tostring(score, "#.#") + "  (ranks " + str.tostring(r1, "#") + "/" + str.tostring(r2, "#") + "/" + str.tostring(r3, "#") + ")", score >= entryScore ? cBull : score <= 100 - entryScore ? cBear : color.white)
    row(2, "Mansfield RS", str.tostring(mans, "#.##") + "%", mans > 0 ? cBull : cBear)
    row(3, "RS slope z", str.tostring(sZ, "#.##"), sZ > slopeZ ? cBull : sZ < -slopeZ ? cBear : color.white)
    row(4, "Price vs EMA", close > emaPx ? "above" : "below", close > emaPx ? cBull : cBear)
    row(5, "Position", inLong ? "LONG" : inShort ? "SHORT" : "flat", inLong ? cBull : inShort ? cBear : color.white)
    row(6, "Filters", (longOk ? "long ok" : "long blocked") + " / " + (shortOk ? "short ok" : "short blocked"))
    row(7, "Closed trades", str.tostring(strategy.closedtrades) + "  (" + str.tostring(strategy.wintrades) + " wins)")

// ───────────────────────────── 5. Alerts ─────────────────────────────
if longEntry
    alert("RS Rotation: long entry on " + syminfo.ticker + " vs " + bench, alert.freq_once_per_bar_close)
if shortEntry
    alert("RS Rotation: short entry on " + syminfo.ticker + " vs " + bench, alert.freq_once_per_bar_close)
if exitBar
    alert("RS Rotation: position closed on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
