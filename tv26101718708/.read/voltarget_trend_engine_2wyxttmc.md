# Vol-Target Trend Engine

- url: https://www.tradingview.com/script/2wyXTTMc-Vol-Target-Trend-Engine/
- type: strategy
- pine_id: PUB;c753cb806b364d93a86b1468bca5d44b
- version: 1.0

## Description

WHAT IT DOES

VTTE is a leveraged-ETF allocation engine. It holds a 3x index ETF (built for TQQQ/UPRO) only during favorable regimes, and lets realized volatility set the position size. There is no entry signal being predicted anywhere in the script - the edge is the risk-allocation policy itself, which is why the system has almost no tunable surface to overfit.

HOW IT WORKS

1) REGIME GATE - the position exists only while price trades above its 200-day SMA. Leveraged ETFs suffer volatility decay fastest in downtrends; the gate removes the catastrophic left tail instead of trying to predict it. Below the SMA the system is 100% cash.

2) VOLATILITY TARGETING - exposure = min(100%, target vol / realized vol), using 20-day realized volatility annualized against a 45% target. This is the same architecture vol-control indices and risk-parity desks run: position size shrinks mechanically as volatility expands, which front-runs drawdowns because volatility clusters.

3) REBALANCING - weekly, inside a 10% tolerance band to keep turnover and commission drag low, with an immediate de-risk override when held exposure runs 1.5x over target. Regime flips act immediately.

BACKTEST PROPERTIES (fully disclosed)

0.05% commission per side, 1 tick slippage, fills on close, $10,000 initial. TQQQ daily Feb 2010 - Aug 2026: +3,862% realized net, profit factor 3.33, 155 rebalance events (67.7% profitable), max drawdown 41.9%. Buy-and-hold TQQQ returned more over the same window (+20,107%) but with multiple drawdowns beyond 80%; the S&P 500 returned roughly +630%. The honest comparison is CAGR ~26% at roughly half of buy-and-hold's worst drawdown.

WHAT WAS TESTED AND REJECTED

A faster variant (5-day vol estimate, de-risk any day of the week) was tested and REJECTED with numbers: turnover more than doubled, the system repeatedly sold volatility spikes at their lows and re-bought higher, net return fell from +3,862% to +2,158%, profit factor 3.33 to 1.98, and max drawdown got WORSE (41.9% to 49.6%). Slow rebalancing is a feature, not a limitation.

INPUTS

Realized vol lookback (20d), target annualized vol (45%), regime SMA length (200), rebalance band (10%), fast de-risk toggle.

LIMITATIONS

Single instrument, single history, in-sample. TQQQ's listed history begins in 2010 - a mostly secular-bull window; the regime gate carries the 2020 and 2022 stress periods, but the configuration has not been walk-forward validated yet. Treat every figure as an upper bound on expectancy, not a forecast. Not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────
//  VOL-TARGET TREND ENGINE  (VTTE)
//  Author: Mateo Sandoval
//
//  A leveraged-ETF allocation engine built on two institutional techniques:
//
//  1) REGIME GATE — hold the position only while price trades above its
//     200-day SMA. Leveraged ETFs suffer volatility decay fastest in
//     downtrends; the gate removes the catastrophic left tail instead of
//     trying to predict it.
//
//  2) VOLATILITY TARGETING — exposure = min(100%, targetVol / realizedVol).
//     The technique vol-control indices and risk-parity desks run: position
//     size shrinks mechanically as realized volatility expands. Rebalanced
//     on the WEEKLY cycle inside a tolerance band — design note: a faster
//     variant (5-day vol, de-risk daily) was tested and REJECTED: it more
//     than doubled turnover, sold vol spikes at their lows, and cut the
//     backtest from +3,862% to +2,158% while worsening drawdown. Slow
//     rebalancing is a feature, not a limitation.
//
//  There is no entry "signal" being predicted. The edge is risk allocation,
//  not timing — which is why it has almost no tunable surface to overfit.
//  Designed for leveraged index ETFs (TQQQ/UPRO) on the daily timeframe.
// ─────────────────────────────────────────────────────────────────────────
strategy("Vol-Target Trend Engine", shorttitle="VTTE", overlay=true,
     initial_capital=10000, commission_type=strategy.commission.percent,
     commission_value=0.05, slippage=1, pyramiding=500,
     process_orders_on_close=true, calc_on_every_tick=false)

volLen    = input.int(20,    "Realized vol lookback (days)",  minval=5)
targetVol = input.float(45.0,"Target annualized vol (%)",     minval=5,  step=1.0)
smaLen    = input.int(200,   "Regime SMA length",             minval=50)
band      = input.float(10.0,"Rebalance band (% of target)",  minval=1,  step=1.0)
fastDrisk = input.bool(true, "Immediate de-risk at 1.5x over target")

retD    = close / close[1] - 1.0
realVol = ta.stdev(retD, volLen) * math.sqrt(252) * 100.0
smaReg  = ta.sma(close, smaLen)
regime  = close > smaReg

frac      = math.min(1.0, targetVol / math.max(realVol, 1.0))
targetQty = regime ? strategy.equity * frac / close : 0.0
posQty    = strategy.position_size
delta     = targetQty - posQty

weekTurn   = timeframe.change("1W")
regimeFlip = regime != regime[1]
overExp    = fastDrisk and posQty > 0 and targetQty > 0 and posQty > targetQty * 1.5

if weekTurn or regimeFlip or overExp
    if not regime and posQty > 0
        strategy.close_all(comment="regime off")
    else if regime and math.abs(delta) > targetQty * band / 100.0
        if delta > 0
            strategy.order("Add",  strategy.long,  qty=delta,  comment="scale up")
        else
            strategy.order("Trim", strategy.short, qty=-delta, comment="de-risk")

expNow  = strategy.equity > 0 ? strategy.position_size * close / strategy.equity : 0.0
colUp   = #26a69a
colDn   = #ef5350
smaCol  = regime ? color.new(colUp, 0) : color.new(colDn, 0)
plot(smaReg, "Regime SMA", color=smaCol, linewidth=2)

tint = regime ? math.max(85, 97 - int(expNow * 12.0)) : 96
bgcolor(color.new(regime ? colUp : colDn, tint))

plotshape(regime and not regime[1], "Risk ON",  style=shape.triangleup,
     location=location.belowbar, color=color.new(colUp, 0), size=size.small)
plotshape(not regime and regime[1], "Risk OFF", style=shape.triangledown,
     location=location.abovebar, color=color.new(colDn, 0), size=size.small)

var table tb = table.new(position.top_right, 2, 5,
     bgcolor=color.new(#0c0e15, 15), border_width=1,
     border_color=color.new(color.gray, 70))
if barstate.islast
    hdrCol = color.new(#d1d4dc, 0)
    valCol = regime ? color.new(colUp, 0) : color.new(colDn, 0)
    table.cell(tb, 0, 0, "VTTE",          text_color=hdrCol, text_size=size.normal)
    table.cell(tb, 1, 0, regime ? "RISK ON" : "RISK OFF", text_color=valCol, text_size=size.normal)
    table.cell(tb, 0, 1, "Realized vol",  text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 1, str.tostring(realVol, "#.0") + "%", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 2, "Target exp",    text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 2, str.tostring(frac * 100.0, "#.0") + "%", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 3, "Held exp",      text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 3, str.tostring(expNow * 100.0, "#.0") + "%", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 4, "Vol target",    text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 4, str.tostring(targetVol, "#") + "%", text_color=hdrCol, text_size=size.small)
````
