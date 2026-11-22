# Comparative Relative Strength - SJ

- url: https://www.tradingview.com/script/wO9tQFSs-Comparative-Relative-Strength-SJ/
- type: indicator
- pine_id: PUB;971f5ffc010e4a258ca6bac4cb1a5cce
- version: 1.0

## Description

OVERVIEW
Comparative Relative Strength (CRS) measures how a symbol is performing against a benchmark index, rather than on its own. It answers a single question: is this stock doing better or worse than the market it trades in? The script is built for traders who use the Wyckoff method, where a key buying condition is a stock that is stronger than the market, and a key selling condition is a stock that is weaker than the market.

HOW IT WORKS
1. The CRS line (grey) is the ratio of the chart symbol's close to the benchmark's close on the same timeframe. When the line rises, the symbol is outperforming the benchmark. When it falls, the symbol is underperforming, even if its price is rising.
2. The smoothed line (navy) is a moving average of the CRS line (EMA by default, 22 bars, which is about one trading month on a daily chart). It shows the underlying relative-strength trend and filters out single-bar noise.
3. The fill between the two lines is green when CRS is above its average (relative strength improving) and red when it is below (relative strength deteriorating).
4. Turn markers: a green dot at the bottom marks the bar on which CRS crosses above its average. A red dot at the top marks the bar on which it crosses below.
5. ROC mode: the raw ratio depends on the price levels of the two instruments, so ratio values cannot be compared between symbols. ROC mode plots the percentage rate of change of the ratio instead. This number is scale-free and means the same thing on every symbol. It is also output to the Data Window, where it can be read by a screener to rank symbols by relative strength.

HOW TO USE IT
- Choose the benchmark that matches the market the symbol trades in (for example, a Saudi stock against the TASI index, or a US technology stock against the Nasdaq 100). A mismatched benchmark gives a meaningless reading.
- For long setups, look for symbols whose CRS is rising and above its average while the benchmark is flat or falling. Such a stock is being supported against the market and often leads when the market turns up.
- For short setups or exits, look for CRS falling below its average while the benchmark is flat or rising. The stock is lagging and failing to join the market's strength.
- Use ROC mode when comparing several symbols. The symbol with the highest positive ROC is the strongest relative to the benchmark over the chosen period.
- CRS is a filter for choosing what to trade, not a timing signal on its own. Combine it with price and volume analysis of the symbol itself.

INPUTS
- Benchmark index: the symbol used as the comparison.
- Smoothing length: the length of the average (default 22).
- Smoothing type: EMA or SMA.
- Mode: Ratio (for reading one chart) or ROC (for comparing symbols).
- ROC length: the look-back for ROC mode (default 22).
- Mark the turns: shows or hides the crossover dots.

ALERTS
- CRS turn up: CRS crossed above its average.
- CRS turn down: CRS crossed below its average.

LIMITATIONS
- Crossovers are frequent in sideways conditions and will produce several turn markers in a short period. Read them together with the direction of the smoothed line.
- If the symbol and the benchmark trade on different days or sessions, the script uses the benchmark's last available close on bars where the benchmark did not trade. Readings on those bars can lag.
- Values are calculated on bar close; the reading on the current, unfinished bar will change until the bar closes. The script does not repaint closed bars and does not use future data.
- Relative strength describes the past. It does not predict future performance.

## Source Code

````pine
//@version=6
// Comparative Relative Strength - SJ
// Compares the MOMENTUM of the stock against the index of the market.
// Two display modes:
//   RATIO mode - stock / benchmark. Good for READING one chart.
//   ROC mode   - rate of change of that ratio. Scale-free, so it is the one
//                that can be RANKED ACROSS SYMBOLS in a scanner.
indicator("Comparative Relative Strength - SJ", shorttitle = "CRS-SJ", overlay = false)

// ---------------- inputs ----------------
benchSym = input.symbol("NASDAQ:NDX", "Benchmark index")
maLen    = input.int(22, "Smoothing length", minval = 1, tooltip = "22 = one trading month on daily")
maType   = input.string("EMA", "Smoothing type", options = ["EMA", "SMA"])
mode     = input.string("Ratio", "Mode", options = ["Ratio", "ROC"])
rocLen   = input.int(22, "ROC length", minval = 1)
showTurn = input.bool(true, "Mark the turns")

// ---------------- data ----------------
benchRaw = request.security(benchSym, timeframe.period, close, ignore_invalid_symbol = true)

// a halted or missing benchmark print must not blow the series up
benchOk = not na(benchRaw) and benchRaw != 0
bench   = benchOk ? benchRaw : na

crs = close / bench

crsMa = maType == "EMA" ? ta.ema(crs, maLen) : ta.sma(crs, maLen)

// scale-free form - comparable between different symbols
crsRoc   = ta.roc(crs, rocLen)
crsRocMa = maType == "EMA" ? ta.ema(crsRoc, maLen) : ta.sma(crsRoc, maLen)

isRoc = mode == "ROC"

lineRaw = isRoc ? crsRoc : crs
lineMa  = isRoc ? crsRocMa : crsMa

// ---------------- plots ----------------
pRaw = plot(lineRaw, "CRS", color = color.new(color.gray, 0))
pMa  = plot(lineMa, "CRS smoothed", color = color.navy, linewidth = 2)

plot(isRoc ? 0.0 : na, "Zero", color = color.new(color.gray, 40))

fill(pRaw, pMa, color = lineRaw > lineMa ? color.new(color.green, 88) : color.new(color.red, 88))

// ---------------- state ----------------
outperforming = lineRaw > lineMa
turnUp = ta.crossover(lineRaw, lineMa)
turnDn = ta.crossunder(lineRaw, lineMa)

plotshape(showTurn and turnUp, "CRS turns up", shape.circle, location.bottom, color.new(color.green, 0), size = size.tiny)
plotshape(showTurn and turnDn, "CRS turns down", shape.circle, location.top, color.new(color.red, 0), size = size.tiny)

alertcondition(turnUp, "CRS turn up", "CRS crossed above its average - stock beginning to beat the index")
alertcondition(turnDn, "CRS turn down", "CRS crossed below its average - stock beginning to lag the index")

// ---------------- scanner value ----------------
// Plot this (ROC mode) invisibly so a screener column can read one number
// that means the same thing on every symbol.
plot(crsRoc, "SCAN: CRS ROC %", color = color.new(color.gray, 100), display = display.data_window)
````
