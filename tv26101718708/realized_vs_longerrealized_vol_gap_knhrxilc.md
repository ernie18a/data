# Realized vs Longer-Realized Vol Gap

- url: https://www.tradingview.com/script/KNhrxILC/
- type: indicator
- pine_id: PUB;1ef5590beebc4839aee58c8267609d75
- version: 1.0

## Description

Short-window realized volatility versus long-window realized volatility, and the gap between them, as a proxy for volatility expansion and compression when true implied volatility is unavailable on the symbol. It does NOT generate buy or sell signals.

What it shows
- Short-window and long-window annualised realized volatility
- The gap and the gap as a percent of the long baseline

Honest by design
- No buy/sell signals. This is honestly an RV-vs-RV proxy, not true implied volatility; set the annualisation factor to sqrt(periods per year) for your timeframe.
- Non-repainting: rolling standard deviations on confirmed bars.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Realized vs Longer-Realized Volatility Gap
// True implied volatility is unavailable on most TradingView free
// symbols, so this indicator uses a proxy: short-window realized
// volatility vs long-window realized volatility. The gap highlights
// vol expansions and compressions relative to a longer baseline.
// Analytics panel. No signals, non-repainting.
indicator("Realized vs Longer-Realized Vol Gap", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

shortLen = input.int(20, "Short RV window", minval = 2, group = "Windows")
longLen  = input.int(120, "Long RV window", minval = 10, group = "Windows")
annFac   = input.float(15.87, "Annualisation factor",
     minval = 1.0, step = 0.1,
     tooltip = "Use sqrt(periods per year). Daily stocks ~15.87, daily crypto ~19.10.",
     group = "Display")

logRet = math.log(close / close[1])
rvShort = ta.stdev(logRet, shortLen) * annFac
rvLong  = ta.stdev(logRet, longLen) * annFac
gap = rvShort - rvLong
gapPct = rvLong > 0 ? (gap / rvLong) * 100.0 : na

plot(rvShort, title = "Short RV", color = color.new(color.aqua, 0), linewidth = 2)
plot(rvLong,  title = "Long RV",  color = color.new(color.gray, 0), linewidth = 2)
plot(gap,     title = "Gap",      color = gap >= 0 ? color.new(color.red, 0) : color.new(color.green, 0))
hline(0, title = "zero gap", color = color.new(color.gray, 50), linestyle = hline.style_dashed)

var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "RV Gap", text_color = color.white,
         bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Short RV (ann)")
    table.cell(t, 1, 1, str.tostring(rvShort, "#.####"))
    table.cell(t, 0, 2, "Long RV (ann)")
    table.cell(t, 1, 2, str.tostring(rvLong, "#.####"))
    table.cell(t, 0, 3, "Gap %")
    table.cell(t, 1, 3, na(gapPct) ? "na" : str.tostring(gapPct, "#.##") + "%")
````
