# Relative Strength vs Benchmark

- url: https://www.tradingview.com/script/dhN73EBl-Relative-Strength-vs-Benchmark/
- type: indicator
- pine_id: PUB;833df3506f204af3a304c945204824a3
- version: 1.0

## Description

Plots (stock return - benchmark return) over a lookback window. Above zero =
 outperforming. The background turns green on a "bullish decoupling": the
 benchmark drops materially while the stock holds.

 Set the benchmark to the sector ETF (e.g. a gold/junior-miner ETF) or a
 commodity proxy relevant to the name.

## Source Code

````pine
//@version=6
// =============================================================================
// Relative Strength vs Benchmark — TradingView companion
// =============================================================================
// Is the stock HOLDING while its sector ETF
// or the relevant commodity sells off? That decoupling is often institutional
// support (relative strength). Mirrors the beta-decoupling module from the
// original screener, but live on the chart.
//
// Plots (stock return - benchmark return) over a lookback window. Above zero =
// outperforming. The background turns green on a "bullish decoupling": the
// benchmark drops materially while the stock holds.
//
// Set the benchmark to the sector ETF (e.g. a gold/junior-miner ETF) or a
// commodity proxy relevant to the name.
// =============================================================================

indicator("Relative Strength vs Benchmark", shorttitle="RS", overlay=false)

cmp     = input.symbol("AMEX:GDXJ", "Benchmark (sector ETF / commodity)")
len     = input.int(20,    "Return window (bars)", minval=2)
dropThr = input.float(-0.04, "Benchmark drop threshold (decouple)", step=0.01)
holdThr = input.float(-0.01, "Stock hold threshold (decouple)", step=0.01)

benchClose = request.security(cmp, timeframe.period, close)

stockRet = close / close[len] - 1
benchRet = benchClose / benchClose[len] - 1
rs = stockRet - benchRet

plot(rs * 100, "Stock - Benchmark return (%)",
     color = rs >= 0 ? color.teal : color.red, linewidth=2)
hline(0, "Even", color=color.gray, linestyle=hline.style_dotted)

decouple = benchRet <= dropThr and stockRet >= holdThr
bgcolor(decouple ? color.new(color.lime, 85) : na, title="Bullish decoupling")
alertcondition(decouple, "Bullish decoupling",
     "Benchmark selling off while the stock holds — relative strength")
````
