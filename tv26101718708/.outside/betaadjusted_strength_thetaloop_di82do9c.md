# Beta-Adjusted Strength [ThetaLoop]

- url: https://www.tradingview.com/script/di82Do9C-Beta-Adjusted-Strength-ThetaLoop/
- type: indicator
- pine_id: PUB;0d04683d595043adad7cdae603f58f23
- version: 1.0

## Description

[b]A worked example first.[/b]

[b]Over the last 20 sessions:[/b]
- Stock: -21%
- Nasdaq 100 (QQQ): -8%
- The stock's beta to QQQ: 2.4

The move you would expect from beta alone is about -18%. The actual move was -21%. The beta-adjusted move is about -3%.

So the stock did not break. It did almost exactly what a 2.4-beta stock does when the index drops 8%. Nothing company-specific happened. It is the market, amplified.

Now change one number. Same index drop, but the stock's beta is 0.9. Expected: about -7%. Actual: -21%. Beta-adjusted: about -14%. That is a stock-specific story, and you want to know about it before you buy that dip.

This indicator does that arithmetic on every bar and puts the result into statistical context.

[b]What it calculates
[/b]1. Beta from log returns over the beta window (default 60 bars): beta = correlation x stdev(stock) / stdev(benchmark)
2. The residual of every bar: stock return minus beta x benchmark return. The beta of the previous bar is used, so the current bar cannot contaminate its own estimate.
3. The residuals are summed over the measurement window (default 20 bars) and normalized:
   z = sum of residuals / (stdev of residuals x square root of window)

The z-score answers a precise question: how unusual is this stock-specific move, given how much stock-specific noise this symbol normally produces? A volatile small cap and a sleepy large cap become comparable on the same scale.

[b]Reading it[/b]
- Columns above +2: outperformance beyond what beta explains. Real relative strength.
- Columns below -2: weakness beyond what beta explains. Something other than the market is hitting the stock.
- Columns near zero during a sharp drop: the drop is beta.
- Faded columns: same direction, but below the threshold.

The table opens with a plain-language reading (moving with the market, slightly stronger or weaker than beta, stock-specific strength or weakness) and then spells out the example from above for the current bar: beta as used in the calculation, correlation, stock move, benchmark move, expected move (beta x benchmark), beta-adjusted move and the z-score.

[b]Breadth check[/b]
An orange background marks bars where the benchmark closes at a new N-bar high while its equal-weight counterpart (QQQE by default) is still more than the tolerance below its own high. That is a rally carried by a few heavyweights. Useful context when the index looks fine but most of your watchlist does not.

[b]Alerts[/b]
- Beta-adjusted weakness: z crosses below the lower threshold
- Beta-adjusted strength: z crosses above the upper threshold
- Breadth non-confirmation: first bar of a new non-confirmed high

[b]Things to keep in mind
[/b]- Beta only means something when correlation does. With correlation below roughly 0.3, the "expected" move is weak, and the z-score is closer to plain relative performance.
- Choose a benchmark that trades in the same session as the symbol (QQQ, SMH, SPY for US stocks). Against a crypto chart, weekends show a flat benchmark.
- An earnings gap stays inside the measurement window until it rolls out. That is correct (an earnings reaction is stock-specific) but remember why the reading is extreme.
- Windows are counted in bars, so the script works on any timeframe. Defaults are tuned for daily charts.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThetaLoop
//@version=6
indicator("Beta-Adjusted Strength [ThetaLoop]", shorttitle = "β-Strength [TL]", overlay = false, precision = 2)

// ───────────────────────────── Inputs ─────────────────────────────
grpB     = "Benchmark"
benchSym = input.symbol("NASDAQ:QQQ", "Benchmark", group = grpB, tooltip = "Use a benchmark that trades in the same session as your symbol (e.g. QQQ, SMH, SPY for US stocks).")
betaLen  = input.int(60, "Beta window", minval = 20, group = grpB, tooltip = "Bars used to estimate beta and the stock's own (idiosyncratic) volatility.")
resLen   = input.int(20, "Measurement window", minval = 2, group = grpB, tooltip = "Bars over which the beta-adjusted move is summed.")
zThr     = input.float(2.0, "Signal threshold (z)", minval = 0.5, step = 0.1, group = grpB)

grpBr      = "Breadth check"
useBreadth = input.bool(true, "Flag benchmark highs without equal-weight confirmation", group = grpBr)
ewSym      = input.symbol("NASDAQ:QQQE", "Equal-weight counterpart", group = grpBr)
brLen      = input.int(50, "High lookback", minval = 10, group = grpBr)
brTol      = input.float(0.5, "Tolerance (%)", minval = 0.0, step = 0.1, group = grpBr, tooltip = "The equal-weight counterpart must be more than this far below its own high for the bar to be flagged.")

grpD      = "Display"
showTable = input.bool(true, "Show stats table", group = grpD)
upCol     = input.color(#26a69a, "Strength", group = grpD, inline = "c")
dnCol     = input.color(#ef5350, "Weakness", group = grpD, inline = "c")

// ───────────────────────────── Data ─────────────────────────────
bClose = request.security(benchSym, timeframe.period, close)
eClose = request.security(ewSym, timeframe.period, close)

// ───────────────────────────── Beta & residual ─────────────────────────────
r      = math.log(close / close[1])
rb     = math.log(bClose / bClose[1])
corr   = ta.correlation(r, rb, betaLen)
sdR    = ta.stdev(r, betaLen)
sdB    = ta.stdev(rb, betaLen)
beta   = sdB > 0 ? corr * sdR / sdB : na
bUse   = beta[1]                              // previous estimate → current bar does not contaminate beta
res    = r - bUse * rb                        // idiosyncratic (stock-specific) return of this bar
sdRes  = ta.stdev(res, betaLen)
cumRes = math.sum(res, resLen)
z      = sdRes[1] > 0 ? cumRes / (sdRes[1] * math.sqrt(resLen)) : na

// window moves for the table (simple %)
stockMv = (close / close[resLen] - 1) * 100
benchMv = (bClose / bClose[resLen] - 1) * 100
expMv   = (math.exp(bUse * math.log(bClose / bClose[resLen])) - 1) * 100
resMv   = stockMv - expMv

// ───────────────────────────── Plots ─────────────────────────────
zCol = z >= zThr ? upCol : z > 0 ? color.new(upCol, 60) : z <= -zThr ? dnCol : color.new(dnCol, 60)
plot(z, "Beta-adjusted z-score", color = zCol, style = plot.style_columns)
plot(cumRes * 100, "Residual (log %, window)", display = display.data_window)
plot(beta, "Beta", display = display.data_window)
plot(corr, "Correlation", display = display.data_window)
hline(0, "Zero", color = color.new(#787b86, 40), linestyle = hline.style_solid)
hline(zThr, "Upper threshold", color = color.new(#26a69a, 40), linestyle = hline.style_dashed)
hline(-zThr, "Lower threshold", color = color.new(#ef5350, 40), linestyle = hline.style_dashed)

// ───────────────────────────── Breadth check ─────────────────────────────
bHH     = ta.highest(bClose, brLen)
eHH     = ta.highest(eClose, brLen)
nonConf = useBreadth and bClose >= bHH and eClose < eHH * (1 - brTol / 100)
bgcolor(nonConf ? color.new(#ff9800, 85) : na, title = "Breadth non-confirmation")

// ───────────────────────────── Alerts ─────────────────────────────
alertcondition(ta.crossunder(z, -zThr), "Beta-adjusted weakness", "{{ticker}}: beta-adjusted move crossed below the lower threshold")
alertcondition(ta.crossover(z, zThr), "Beta-adjusted strength", "{{ticker}}: beta-adjusted move crossed above the upper threshold")
alertcondition(nonConf and not nonConf[1], "Breadth non-confirmation", "Benchmark at a new high without equal-weight confirmation")

// ───────────────────────────── Table ─────────────────────────────
f_pct(float x) => na(x) ? "–" : (x >= 0 ? "+" : "") + str.tostring(x, "0.0") + " %"

var table st = table.new(position.top_right, 2, 9, bgcolor = color.new(#131722, 10), border_color = color.new(color.gray, 70), border_width = 1)

if barstate.islast and showTable
    table.clear(st, 0, 0, 1, 8)
    resC = resMv >= 0 ? upCol : dnCol
    zC   = z >= zThr ? upCol : z <= -zThr ? dnCol : color.white
    // plain-language reading of the z-score
    verdict = na(z) ? "not enough data" : z >= zThr ? "Stock-specific strength" : z <= -zThr ? "Stock-specific weakness" : z >= 1 ? "Slightly stronger than beta" : z <= -1 ? "Slightly weaker than beta" : "Moving with the market"
    vC      = na(z) ? color.gray : z >= zThr ? upCol : z <= -zThr ? dnCol : z >= 1 ? color.new(upCol, 30) : z <= -1 ? color.new(dnCol, 30) : color.white
    table.cell(st, 0, 0, "vs " + benchSym, text_color = color.silver, text_size = size.small)
    table.cell(st, 1, 0, str.tostring(resLen) + " bars", text_color = color.silver, text_size = size.small)
    table.cell(st, 0, 1, "Reading", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 1, verdict, text_color = vC, text_size = size.small)
    // beta as used in the calculation (previous bar's estimate)
    table.cell(st, 0, 2, "Beta (" + str.tostring(betaLen) + ")", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 2, na(bUse) ? "–" : str.tostring(bUse, "0.00"), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 3, "Correlation", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 3, na(corr) ? "–" : str.tostring(corr, "0.00"), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 4, "Stock move", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 4, f_pct(stockMv), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 5, "Benchmark move", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 5, f_pct(benchMv), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 6, "Expected (β × bench)", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 6, f_pct(expMv), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 7, "Beta-adjusted", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 7, f_pct(resMv), text_color = resC, text_size = size.small)
    table.cell(st, 0, 8, "z-score", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(st, 1, 8, na(z) ? "–" : str.tostring(z, "0.0"), text_color = zC, text_size = size.small)
````
