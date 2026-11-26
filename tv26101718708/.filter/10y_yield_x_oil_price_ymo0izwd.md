# 10Y Yield x Oil Price

- url: https://www.tradingview.com/script/Ymo0iZwd-10Y-Yield-x-Oil-Price/
- type: indicator
- pine_id: PUB;70dbe31a462d4107a1fcc5870f5a8a65
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

This indicator plots the product of the US 10-Year Treasury yield and the price of crude oil. The resulting composite captures a specific macro stress condition: when the cost of money and the cost of energy are both elevated simultaneously, the real economy is being squeezed from two directions at once. Historically, extreme readings in this product have preceded severe economic contractions.

The concept is drawn from Luke Gromen's macro framework at FFTT, where he identifies this combined measure as a concise summary of stagflationary pressure on the economy.


═══════════════════════════════════════════════════════════════════


█ [b]CONCEPT[/b]

Interest rates and energy prices are the two most pervasive input costs in any modern economy. Elevated rates raise the cost of capital, slow credit creation, and compress asset valuations. Elevated oil prices increase transportation, manufacturing, and agricultural input costs, feeding directly into consumer prices. When both are high simultaneously, the economy faces a pincer: tightening financial conditions on one side, rising real-world costs on the other.

Neither variable in isolation tells the full story. Rates can be high during healthy expansion (late 1990s), and oil can be high during loose monetary policy (2005 to 2007). The product of the two, however, spikes only when both pressures converge. This convergence historically coincides with or immediately precedes recessions.


═══════════════════════════════════════════════════════════════════


█ [b]HISTORICAL REFERENCE POINTS[/b]

Going back to 1980, the yield × oil product has reached extreme levels only twice before:

 • [b]January 1980[/b]: The Fed funds rate had been ratcheted above 13% and oil had doubled following the Iranian Revolution. What followed was a vicious double-dip recession (January to July 1980, then July 1981 to November 1982) that drove unemployment above 10%.

 • [b]March 2008[/b]: The 10-year yield sat above 3.5% while oil surged past $100 on its way to $147 in July. The global financial crisis was already underway, with Bear Stearns collapsing that same month. The S&P 500 would lose more than half its value over the following year.

Both prior extremes resolved through demand destruction and economic contraction severe enough to pull one or both inputs sharply lower. The indicator's current reading context is left to the chart.


═══════════════════════════════════════════════════════════════════


█ [b]HOW TO USE[/b]

This is a macro context indicator, not a trade signal generator. It belongs on a weekly or monthly chart as a background condition monitor alongside your existing framework.

[b]Reading the chart[/b]

 • [b]Rising toward or above the red reference line[/b]: The economy is experiencing the same dual squeeze that preceded the two worst economic outcomes of the last 45 years. Risk management should be prioritized over return seeking.

 • [b]Between the yellow and red reference lines[/b]: Elevated but not extreme. Conditions are stressful but not historically unprecedented. Warrants caution.

 • [b]Below the yellow reference line[/b]: The dual squeeze is not present. Either rates, oil, or both are low enough that the economy is not being compressed from both sides.

[b]Important caveats[/b]

 • The reference hlines are approximate visual guides, not precise thresholds. The exact values of the January 1980 and March 2008 peaks depend on whether you use spot or front-month oil, daily or monthly yield data, and which exact date you measure. Adjust the hline levels to match what you see on your chart's data.

 • This indicator says nothing about [i]when[/i] the resolution occurs. January 1980 conditions persisted for months before the recession officially began. March 2008 was already in crisis but the worst was still six months away. Extreme readings are a condition, not a timer.

 • The product can decline by either input falling. A drop driven by collapsing oil demand (2008 scenario) means something very different from a drop driven by rate cuts (stimulative policy). The direction of the decline matters as much as the decline itself.


═══════════════════════════════════════════════════════════════════


█ [b]SETTINGS[/b]

 • [b]10-Year Yield Symbol[/b]: defaults to [i]TVC:US10Y[/i]. Can be changed to [i]FRED:DGS10[/i] or any other yield source.

 • [b]Oil Symbol[/b]: defaults to [i]NYMEX:CL1![/i] (WTI front-month continuous). Can be changed to [i]TVC:USOIL[/i], [i]NYMEX:BZ1![/i] (Brent), or any other crude benchmark.


═══════════════════════════════════════════════════════════════════


█ [b]ATTRIBUTION[/b]

The yield × oil product as a macro stress indicator is attributed to Luke Gromen, founder of [b]FFTT[/b] (Forest for the Trees). Gromen has highlighted this combined metric in his subscriber research and public commentary as a concise measure of stagflationary pressure, noting that its extreme readings have historically coincided with only the most severe economic stress episodes since 1980.

[b]Disclaimer[/b]: This indicator is an educational and analytical tool. It does not constitute investment advice. Past historical patterns do not guarantee future outcomes. Always conduct your own research and risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 

//@version=6
indicator("10Y Yield × Oil Price", shorttitle="10Y×Oil", overlay=false)

// ─── Inputs ───
yieldSymbol = input.string("TVC:US10Y",   "10-Year Yield Symbol")
oilSymbol   = input.string("NYMEX:CL1!",  "Oil Symbol")

// ─── Data ───
yieldVal = request.security(yieldSymbol, timeframe.period, close)
oilVal   = request.security(oilSymbol,   timeframe.period, close)

combined = yieldVal * oilVal

// ─── Plot ───
plot(combined, "10Y Yield × Oil", color=color.new(color.white, 0), linewidth=2)

// ─── Historical reference levels ───
// Jan 1980 and Mar 2008 peaks per Gromen's framework
h1 = hline(600, "Jan 1980 / Mar 2008 Zone", color=color.new(color.red, 40), linestyle=hline.style_dashed)
h2 = hline(500, "Caution Zone",             color=color.new(color.yellow, 40), linestyle=hline.style_dotted)
````
