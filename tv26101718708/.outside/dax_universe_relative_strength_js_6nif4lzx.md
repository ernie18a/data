# DAX Universe Relative Strength [JS]

- url: https://www.tradingview.com/script/6niF4lZX/
- type: indicator
- pine_id: PUB;ea3c1236bb164392b7ec1134a5cb7349
- version: 1.0

## Description

DAX Universe Relative Strength [JS]

This indicator compares the current stock with an equal-weighted German stock market benchmark consisting of DAX, MDAX, SDAX and TecDAX.

Instead of comparing a stock only with one single index, the script creates a broader DAX Universe benchmark by calculating the average performance of the four major German equity indices over a selected lookback period.

The goal is to identify whether a stock is showing relative strength or relative weakness versus the broader German stock universe.

How it works:

1. The script measures the performance of the current stock over the selected comparison period.
2. It measures the performance of DAX, MDAX, SDAX and TecDAX over the same period.
3. It calculates the equal-weighted average performance of these four indices.
4. It compares the stock’s performance with this benchmark.
5. The result is plotted as a relative strength line.

Interpretation:

- RS above 0:
  The stock is outperforming the DAX Universe benchmark.

- RS below 0:
  The stock is underperforming the DAX Universe benchmark.

- RS above its moving average:
  Relative strength is improving.

- RS below its moving average:
  Relative strength is weakening.

- Strong RS signal:
  The stock is above the benchmark, above its RS moving average, and the RS moving average is rising.

This indicator is designed as a filter, not as a standalone buy or sell signal.

For pullback and swing trading, I use it to identify stocks that are stronger than the broader German market. A strong RS reading does not mean that a stock should be bought immediately. It only means that the stock deserves attention and may be worth adding to a watchlist.

A complete trade setup should also include:

- constructive trend structure
- price above important moving averages
- controlled pullback
- declining selling pressure
- clear pivot or trigger
- defined stop-loss
- attractive risk/reward ratio

The indicator includes:

- relative strength line
- moving average of the RS line
- zero line
- histogram
- background highlighting
- interpretation label
- alert conditions for RS changes

Suggested use cases:

- screening German stocks
- comparing DAX, MDAX, SDAX and TecDAX stocks
- identifying potential market leaders
- filtering pullback candidates
- avoiding stocks with persistent relative weakness

Important:

This script is for educational and analytical purposes only. It does not provide investment advice, buy signals or sell signals. Always combine relative strength analysis with your own chart analysis, risk management and trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JS_TechTrading

//@version=6
indicator("DAX Universe Relative Strength [JS]", shorttitle="DAX Universe RS [JS]", overlay=false, max_labels_count=50)

// ------------------------------------------------------------
// DAX Universe Relative Strength [JS]
// Vergleich einer Aktie gegen den gleichgewichteten Performance-Mittelwert
// aus DAX, MDAX, SDAX und TecDAX.
//
// Interpretation:
// RS > 0  = Aktie outperformt das DAX-Universum
// RS < 0  = Aktie underperformt das DAX-Universum
// RS > MA = relative Stärke verbessert sich
// RS < MA = relative Stärke schwächt sich ab
// ------------------------------------------------------------

// === Inputs ===
rsLen      = input.int(50, "RS-Vergleichsperiode", minval=1)
maLen      = input.int(10, "Glättung / MA der RS-Linie", minval=1)
showHist   = input.bool(true, "Histogramm anzeigen")
showLabel  = input.bool(true, "Interpretations-Label anzeigen")
showBg     = input.bool(true, "Hintergrund nach RS-Status einfärben")

symDAX     = input.symbol("XETR:DAX",  "DAX")
symMDAX    = input.symbol("XETR:MDAX", "MDAX")
symSDAX    = input.symbol("XETR:SDXP", "SDAX")
symTECDAX  = input.symbol("XETR:TDXP", "TecDAX")

// === Daten abrufen ===
daxClose = request.security(
     symDAX,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

mdaxClose = request.security(
     symMDAX,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

sdaxClose = request.security(
     symSDAX,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

tecdaxClose = request.security(
     symTECDAX,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

// === Performance-Funktion ===
// Gibt die Performance als Faktor zurück.
// Beispiel: 1.10 = +10 %, 0.95 = -5 %
f_perf(src, len) =>
    not na(src) and not na(src[len]) and src[len] != 0 ? src / src[len] : na

// === Performance der Aktie und der vier Indizes ===
stockPerf  = f_perf(close, rsLen)
daxPerf    = f_perf(daxClose, rsLen)
mdaxPerf   = f_perf(mdaxClose, rsLen)
sdaxPerf   = f_perf(sdaxClose, rsLen)
tecdaxPerf = f_perf(tecdaxClose, rsLen)

// === Gleichgewichteter DAX-Universum-Benchmark ===
// Falls ein Symbol keine Daten liefert, wird es nicht in den Mittelwert einbezogen.
benchCount =
     (na(daxPerf) ? 0 : 1) +
     (na(mdaxPerf) ? 0 : 1) +
     (na(sdaxPerf) ? 0 : 1) +
     (na(tecdaxPerf) ? 0 : 1)

benchSum =
     nz(daxPerf) +
     nz(mdaxPerf) +
     nz(sdaxPerf) +
     nz(tecdaxPerf)

benchPerf = benchCount > 0 ? benchSum / benchCount : na

// === Relative Stärke ===
// RS > 0: Aktie outperformt den DAX-Universum-Benchmark.
// RS < 0: Aktie underperformt den DAX-Universum-Benchmark.
rs = not na(stockPerf) and not na(benchPerf) and benchPerf != 0 ? (stockPerf / benchPerf - 1.0) * 100.0 : na
rsMA = ta.sma(rs, maLen)

// === Statuslogik ===
rsStrong    = not na(rs) and not na(rsMA) and not na(rsMA[1]) and rs > 0 and rs > rsMA and rsMA > rsMA[1]
rsPositive  = not na(rs) and not na(rsMA) and rs > 0 and rs > rsMA and not rsStrong
rsImproving = not na(rs) and not na(rsMA) and rs < 0 and rs > rsMA
rsWeak      = not na(rs) and not na(rsMA) and rs < 0 and rs < rsMA

statusText =
     rsStrong ? "RS STARK" :
     rsPositive ? "RS POSITIV" :
     rsImproving ? "RS VERBESSERT SICH" :
     rsWeak ? "RS SCHWACH" :
     "RS NEUTRAL"

interpretationText =
     rsStrong ? "Aktie outperformt das DAX-Universum mit positivem Momentum." :
     rsPositive ? "Aktie outperformt das DAX-Universum." :
     rsImproving ? "Aktie ist noch schwächer, verbessert sich aber relativ." :
     rsWeak ? "Aktie underperformt das DAX-Universum." :
     "Keine klare relative Stärke."

statusColor =
     rsStrong ? color.new(color.green, 0) :
     rsPositive ? color.new(color.lime, 0) :
     rsImproving ? color.new(color.orange, 0) :
     rsWeak ? color.new(color.red, 0) :
     color.new(color.gray, 0)

plotColor = not na(rs) and not na(rsMA) and rs >= rsMA ? color.new(color.green, 0) : color.new(color.orange, 0)

// === Plots ===
zeroPlot = plot(0, title="Null-Linie", color=color.new(color.gray, 40), linewidth=1)
rsPlot   = plot(rs, title="Relative Stärke vs. DAX-Universum (%)", color=plotColor, linewidth=2)
maPlot   = plot(rsMA, title="MA der RS-Linie", color=color.new(color.blue, 0), linewidth=1)

plot(
     showHist ? rs : na,
     title="RS-Histogramm",
     style=plot.style_columns,
     color=color.new(plotColor, 80)
)

fill(
     rsPlot,
     zeroPlot,
     title="RS-Zone",
     color=color.new(plotColor, 88)
)

// Hintergrund dezent nach Status einfärben
bgcolor(showBg ? color.new(statusColor, 92) : na)

// === Kleines Interpretations-Label im Chartfenster ===
var label rsLabel = na

labelText =
     statusText +
     "\nRS: " + str.tostring(rs, "#.##") + "%" +
     "\nMA: " + str.tostring(rsMA, "#.##") + "%" +
     "\nBenchmark: DAX/MDAX/SDAX/TecDAX" +
     "\n" + interpretationText

if barstate.islast and showLabel
    label.delete(rsLabel)
    rsLabel := label.new(
         x=bar_index,
         y=na(rs) ? 0 : rs,
         text=labelText,
         style=label.style_label_left,
         color=statusColor,
         textcolor=color.white,
         size=size.small
    )

if barstate.islast and not showLabel
    label.delete(rsLabel)

// === Signale / Alerts ===
rsCrossAboveZero = ta.crossover(rs, 0)
rsCrossBelowZero = ta.crossunder(rs, 0)
rsCrossAboveMA   = ta.crossover(rs, rsMA)
rsCrossBelowMA   = ta.crossunder(rs, rsMA)

plotshape(
     rsCrossAboveZero,
     title="RS über Null",
     style=shape.triangleup,
     location=location.bottom,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="RS+"
)

plotshape(
     rsCrossBelowZero,
     title="RS unter Null",
     style=shape.triangledown,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="RS-"
)

alertcondition(
     rsCrossAboveZero,
     title="RS wird positiv",
     message="{{ticker}} zeigt neue relative Stärke gegenüber dem DAX-Universum."
)

alertcondition(
     rsCrossBelowZero,
     title="RS wird negativ",
     message="{{ticker}} zeigt relative Schwäche gegenüber dem DAX-Universum."
)

alertcondition(
     rsCrossAboveMA,
     title="RS kreuzt MA nach oben",
     message="{{ticker}}: RS-Linie kreuzt ihre Glättung nach oben."
)

alertcondition(
     rsCrossBelowMA,
     title="RS kreuzt MA nach unten",
     message="{{ticker}}: RS-Linie kreuzt ihre Glättung nach unten."
)
````
