# Rolling Correlation Viewer

- url: https://www.tradingview.com/script/tJgxte9S/
- type: indicator
- pine_id: PUB;08dccb0c7ffe449ca198e7baeeb90372
- version: 1.0

## Description

Pairwise rolling Pearson correlation between the chart symbol and up to three reference symbols (default SPY, QQQ, GLD) over a configurable window. Useful for seeing how diversification and co-movement shift across regimes. It does NOT generate buy or sell signals.

What it shows
- Rolling correlation of the chart symbol versus each of three reference symbols
- A table of the latest correlation values

Honest by design
- No buy/sell signals.
- Non-repainting: the reference symbols are pulled with lookahead off and correlations use confirmed close bars only. The current forming bar updates in real time, which is normal, not historical repaint.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Rolling Correlation viewer (multi-asset)
// Pairwise rolling Pearson correlations between the chart symbol and up
// to three additional reference symbols. Uses confirmed close bars only
// (lookahead off) so values do not repaint. Analytics only, no signals.
indicator("Rolling Correlation Viewer", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

corrLen = input.int(60, "Correlation window", minval = 5, group = "Window")
sym1    = input.symbol("SPY", "Asset 1", group = "References")
sym2    = input.symbol("QQQ", "Asset 2", group = "References")
sym3    = input.symbol("GLD", "Asset 3", group = "References")

baseRet = math.log(close / close[1])

s1 = request.security(sym1, timeframe.period, close,
     lookahead = barmerge.lookahead_off)
s2 = request.security(sym2, timeframe.period, close,
     lookahead = barmerge.lookahead_off)
s3 = request.security(sym3, timeframe.period, close,
     lookahead = barmerge.lookahead_off)

r1 = math.log(s1 / s1[1])
r2 = math.log(s2 / s2[1])
r3 = math.log(s3 / s3[1])

c1 = ta.correlation(baseRet, r1, corrLen)
c2 = ta.correlation(baseRet, r2, corrLen)
c3 = ta.correlation(baseRet, r3, corrLen)

plot(c1, title = "Corr vs Asset 1", color = color.new(color.aqua, 0))
plot(c2, title = "Corr vs Asset 2", color = color.new(color.orange, 0))
plot(c3, title = "Corr vs Asset 3", color = color.new(color.fuchsia, 0))
hline(0,  title = "zero",
     color = color.new(color.gray, 50), linestyle = hline.style_dashed)
hline(1,  title = "perfect positive",
     color = color.new(color.gray, 70), linestyle = hline.style_dotted)
hline(-1, title = "perfect negative",
     color = color.new(color.gray, 70), linestyle = hline.style_dotted)

var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Rolling Correlation",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, sym1)
    table.cell(t, 1, 1, str.tostring(c1, "#.##"))
    table.cell(t, 0, 2, sym2)
    table.cell(t, 1, 2, str.tostring(c2, "#.##"))
    table.cell(t, 0, 3, sym3)
    table.cell(t, 1, 3, str.tostring(c3, "#.##"))
````
