# nichoxbt's NUPL ratio 

- url: https://www.tradingview.com/script/Usgyuefq-nichoxbt-s-NUPL-ratio/
- type: indicator
- pine_id: PUB;1e69bf21ca6d4a54b9c13a99679da8c5
- version: 1.0

## Description

[b]BTC NUPL (Net Unrealized Profit/Loss)[/b] is an on-chain indicator that measures the overall profitability of Bitcoin holders by comparing Market Cap and Realized Cap.

It provides a clear view of market cycles by showing whether investors are, on average, in profit or loss — making it a powerful tool for identifying long-term tops and bottoms.

[b]NUPL is calculated as:[/b]
- Market Cap → current value of all BTC
- Realized Cap → aggregate cost basis of all BTC
By comparing the two, the indicator reveals the level of unrealized profit in the market.

[b]Explanation:[/b]
- Green = Capitulation/Pain zone, perfect for accumulating because macro bottom is likely to form
- Blue = Hope/Slow recovery, good for accumulating since its not likely to bottom yet
- Orange = Belief/Growth, start scalling out slowly because macro top is near
- Red = Euphoria/Greed, its highly recommended to take profits because macro top is likely to form

[b]Conclusion:[/b]
Green, Blue = Buy (Bear market bottom)
Orange, Red = Sell (Bull market top)

[b]Important Notes[/b]
This is a macro-level indicator, not designed for short-term trading signals
Best used for cycle analysis and long-term positioning
Works strongest when combined with other tools and market context

## Source Code

````pine
//@version=6
indicator("BTC NUPL (Real On-Chain)", shorttitle="NUPL", overlay=false)

// === SYMBOLS (based on your data) ===
marketCapSymbol   = input.symbol("CRYPTOCAP:BTC", "BTC Market Cap")
realizedCapSymbol = input.symbol("BTC_MARKETCAPREAL", "BTC Realized Cap")

tf = input.timeframe("D", "Timeframe")

// === GET DATA ===
marketCap = request.security(marketCapSymbol, tf, close)
realizedCap = request.security(realizedCapSymbol, tf, close)

// === CALCULATION ===
nupl = (marketCap - realizedCap) / marketCap
nuplPct = nupl * 100

// === COLOR LOGIC (same idea as your chart) ===
colorNupl =
     nuplPct < 0 ? color.lime :
     nuplPct < 25 ? color.blue :
     nuplPct < 50 ? color.orange :
     color.red

// === PLOT ===
plot(nuplPct, title="NUPL %", color=colorNupl, linewidth=2)

// === LEVELS ===
hline(0, "Capitulation", color=color.gray)
hline(25, "Hope / Fear", color=color.blue)
hline(50, "Belief / Denial", color=color.orange)
hline(75, "Euphoria", color=color.red)

// === BACKGROUND ZONES ===
bgcolor(nuplPct < 0 ? color.new(color.green, 90) : na)
bgcolor(nuplPct >= 0 and nuplPct < 25 ? color.new(color.blue, 92) : na)
bgcolor(nuplPct >= 25 and nuplPct < 50 ? color.new(color.orange, 92) : na)
bgcolor(nuplPct >= 50 ? color.new(color.red, 92) : na)

// === LABEL ===
if barstate.islast
    label.new(bar_index, nuplPct,
     text="NUPL: " + str.tostring(nuplPct, "#.##") + "%",
     style=label.style_label_left,
     textcolor=color.white,
     color=color.black)
````
