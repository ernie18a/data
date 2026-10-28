# US Sector Rotation vs SPY - Relative Strength

- url: https://www.tradingview.com/script/7rNWTlrZ/
- type: indicator
- pine_id: PUB;5aa1fff0e5a848faa205a403360153ea
- version: 3.0

## Description

[b]US Sector Rotation vs SPY[/b] vergleicht die Performance der wichtigsten US-Sektor-ETFs mit dem S&P-500-Benchmark SPY.

Das Script dient dazu, relative Stärke und Schwäche einzelner Sektoren schneller zu erkennen. Dadurch lassen sich Marktrotationen besser einordnen und potenziell interessante Sektoren für die weitere Underlying-Auswahl identifizieren.

Enthalten sind unter anderem die großen US-Sektor-ETFs wie XLK, XLC, XLY, XLI, XLB, XLE, XLP, XLV, XLU, XLF und XLRE. SPY dient als Benchmark.

Das Script berechnet die Performance direkt im Pine Script. Deshalb sollte die TradingView-Skala regulär bleiben und nicht zusätzlich auf Prozent oder indexierte Darstellung umgestellt werden.
[b]Funktionen:[/b]
[list]
[*]Vergleich der absoluten Sektor-Performance
[*]Darstellung der relativen Performance gegenüber SPY
[*]wählbare Performance-Fenster: 21, 63, 126, 252 oder eigene Handelstage
[*]Standardwert für eigene Handelstage: 90
[*]Ranking-Tabelle nach relativer Stärke gegenüber SPY
[*]Startpunkt-Markierung der Performance-Berechnung
[*]optionale Endlabels mit Verbindungslinien
[/list]

[b]Interpretation:[/b]
Ein positiver Wert in der Spalte „vs SPY“ zeigt, dass der jeweilige Sektor den Gesamtmarkt im gewählten Zeitraum outperformt. Ein negativer Wert zeigt relative Schwäche gegenüber SPY.

Das Script ist kein Entry- oder Exit-Signal. Es ist als Analysewerkzeug gedacht, um Sektorrotation, relative Stärke und mögliche Underlying-Kandidaten besser vorzuselektieren.

Für Stillhalterstrategien wie Short Puts oder Bull Put Spreads kann die Ansicht helfen, Sektoren mit stabiler oder überdurchschnittlicher relativer Stärke zu identifizieren. Die finale Bewertung sollte jedoch immer zusätzlich Liquidität, IV Rank, Bid/Ask-Spreads, Unterstützungszonen, Earnings- und Eventrisiken sowie Positionsgröße berücksichtigen.

## Source Code

````pine
//@version=6
indicator("US Sector Rotation vs SPY - Relative-Strength", overlay=false, max_labels_count=150, max_lines_count=100)

// ---------------------------------------------------------
// Inputs
// ---------------------------------------------------------

groupGeneral = "General"

lookbackMode = input.string(
     "Custom Trading Days",
     "Performance Window",
     options = [
         "Custom Trading Days",
         "1M / 21 Trading Days",
         "3M / 63 Trading Days",
         "6M / 126 Trading Days",
         "12M / 252 Trading Days"
     ],
     group = groupGeneral)

customLookback = input.int(
     90,
     "Custom Number of Trading Days",
     minval = 1,
     maxval = 1000,
     step = 1,
     group = groupGeneral)

mode = input.string(
     "Absolute Performance",
     "Display Mode",
     options = [
         "Absolute Performance",
         "Relative to SPY"
     ],
     group = groupGeneral)

showTable = input.bool(true, "Show Ranking Table", group=groupGeneral)
showEndLabels = input.bool(true, "Show End Labels", group=groupGeneral)
showAnchor = input.bool(true, "Mark Start Point", group=groupGeneral)

tableRightSpacer = input.string(
     "Medium",
     "Table Right Spacer",
     options = [
         "None",
         "Small",
         "Medium",
         "Large"
     ],
     group = groupGeneral)

labelOffset = input.int(
     4,
     "Label Offset to the Right",
     minval = 0,
     maxval = 50,
     group = groupGeneral)

labelMinGap = input.float(
     1.2,
     "Minimum Label Gap in Percentage Points",
     minval = 0.1,
     maxval = 10.0,
     step = 0.1,
     group = groupGeneral)

showLabelConnectors = input.bool(
     true,
     "Show Label Connector Lines",
     group = groupGeneral)

lookback = switch lookbackMode
    "Custom Trading Days"    => customLookback
    "1M / 21 Trading Days"   => 21
    "3M / 63 Trading Days"   => 63
    "6M / 126 Trading Days"  => 126
    "12M / 252 Trading Days" => 252
    => 90

windowLabel = lookbackMode == "Custom Trading Days"
     ? str.tostring(customLookback) + " Trading Days"
     : lookbackMode

spacerText = switch tableRightSpacer
    "None"   => ""
    "Small"  => "      "
    "Medium" => "            "
    "Large"  => "                  "
    => "            "

groupSymbols = "Symbols"

sym_spy  = input.symbol("AMEX:SPY",  "SPY Benchmark", group=groupSymbols)
sym_xlk  = input.symbol("AMEX:XLK",  "XLK Technology", group=groupSymbols)
sym_xlc  = input.symbol("AMEX:XLC",  "XLC Communication Services", group=groupSymbols)
sym_xly  = input.symbol("AMEX:XLY",  "XLY Consumer Discretionary", group=groupSymbols)
sym_xli  = input.symbol("AMEX:XLI",  "XLI Industrials", group=groupSymbols)
sym_xlb  = input.symbol("AMEX:XLB",  "XLB Materials", group=groupSymbols)
sym_xle  = input.symbol("AMEX:XLE",  "XLE Energy", group=groupSymbols)
sym_xlp  = input.symbol("AMEX:XLP",  "XLP Consumer Staples", group=groupSymbols)
sym_xlv  = input.symbol("AMEX:XLV",  "XLV Health Care", group=groupSymbols)
sym_xlu  = input.symbol("AMEX:XLU",  "XLU Utilities", group=groupSymbols)
sym_xlf  = input.symbol("AMEX:XLF",  "XLF Financials", group=groupSymbols)
sym_xlre = input.symbol("AMEX:XLRE", "XLRE Real Estate", group=groupSymbols)

groupColors = "Colors"

c_spy  = input.color(#808080, "SPY Benchmark", group=groupColors)
c_xlk  = input.color(#00C853, "XLK Technology", group=groupColors)
c_xlc  = input.color(#1E88E5, "XLC Communication Services", group=groupColors)
c_xly  = input.color(#FB8C00, "XLY Consumer Discretionary", group=groupColors)
c_xli  = input.color(#607D8B, "XLI Industrials", group=groupColors)
c_xlb  = input.color(#00ACC1, "XLB Materials", group=groupColors)
c_xle  = input.color(#795548, "XLE Energy", group=groupColors)
c_xlp  = input.color(#689F38, "XLP Consumer Staples", group=groupColors)
c_xlv  = input.color(#AD1457, "XLV Health Care", group=groupColors)
c_xlu  = input.color(#7E57C2, "XLU Utilities", group=groupColors)
c_xlf  = input.color(#D32F2F, "XLF Financials", group=groupColors)
c_xlre = input.color(#8E24AA, "XLRE Real Estate", group=groupColors)

// ---------------------------------------------------------
// Data
// ---------------------------------------------------------

f_close(symbol) =>
    request.security(
         symbol,
         timeframe.period,
         close,
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

spy_close  = f_close(sym_spy)
xlk_close  = f_close(sym_xlk)
xlc_close  = f_close(sym_xlc)
xly_close  = f_close(sym_xly)
xli_close  = f_close(sym_xli)
xlb_close  = f_close(sym_xlb)
xle_close  = f_close(sym_xle)
xlp_close  = f_close(sym_xlp)
xlv_close  = f_close(sym_xlv)
xlu_close  = f_close(sym_xlu)
xlf_close  = f_close(sym_xlf)
xlre_close = f_close(sym_xlre)

// ---------------------------------------------------------
// PerfChart-style anchored performance
// ---------------------------------------------------------

anchorBarRaw = last_bar_index - lookback
anchorBar = math.max(anchorBarRaw, 0)
inWindow = bar_index >= anchorBar

f_perf(src) =>
    base = ta.valuewhen(bar_index == anchorBar, src, 0)
    inWindow and not na(base) ? 100.0 * (src / base - 1.0) : na

spy_perf  = f_perf(spy_close)
xlk_perf  = f_perf(xlk_close)
xlc_perf  = f_perf(xlc_close)
xly_perf  = f_perf(xly_close)
xli_perf  = f_perf(xli_close)
xlb_perf  = f_perf(xlb_close)
xle_perf  = f_perf(xle_close)
xlp_perf  = f_perf(xlp_close)
xlv_perf  = f_perf(xlv_close)
xlu_perf  = f_perf(xlu_close)
xlf_perf  = f_perf(xlf_close)
xlre_perf = f_perf(xlre_close)

f_line(value) =>
    mode == "Relative to SPY" ? value - spy_perf : value

spy_line  = mode == "Relative to SPY" ? (inWindow ? 0.0 : na) : spy_perf
xlk_line  = f_line(xlk_perf)
xlc_line  = f_line(xlc_perf)
xly_line  = f_line(xly_perf)
xli_line  = f_line(xli_perf)
xlb_line  = f_line(xlb_perf)
xle_line  = f_line(xle_perf)
xlp_line  = f_line(xlp_perf)
xlv_line  = f_line(xlv_perf)
xlu_line  = f_line(xlu_perf)
xlf_line  = f_line(xlf_perf)
xlre_line = f_line(xlre_perf)

// ---------------------------------------------------------
// Plots
// ---------------------------------------------------------

hline(0, "Zero Line / SPY Baseline", color=color.new(color.gray, 40))

plot(spy_line,  "SPY Benchmark",              color=c_spy,  linewidth=3)
plot(xlk_line,  "XLK Technology",             color=c_xlk,  linewidth=2)
plot(xlc_line,  "XLC Communication Services", color=c_xlc,  linewidth=2)
plot(xly_line,  "XLY Consumer Discretionary", color=c_xly,  linewidth=2)
plot(xli_line,  "XLI Industrials",            color=c_xli,  linewidth=2)
plot(xlb_line,  "XLB Materials",              color=c_xlb,  linewidth=2)
plot(xle_line,  "XLE Energy",                 color=c_xle,  linewidth=2)
plot(xlp_line,  "XLP Consumer Staples",       color=c_xlp,  linewidth=2)
plot(xlv_line,  "XLV Health Care",            color=c_xlv,  linewidth=2)
plot(xlu_line,  "XLU Utilities",              color=c_xlu,  linewidth=2)
plot(xlf_line,  "XLF Financials",             color=c_xlf,  linewidth=2)
plot(xlre_line, "XLRE Real Estate",           color=c_xlre, linewidth=2)

// ---------------------------------------------------------
// Anchor marker
// ---------------------------------------------------------

var line anchorLine = na
var label anchorLabel = na

if barstate.islast
    line.delete(anchorLine)
    label.delete(anchorLabel)

    if showAnchor
        anchorLine := line.new(
             anchorBar,
             0,
             anchorBar,
             1,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = color.new(color.gray, 55),
             style = line.style_dashed,
             width = 1)

        anchorLabel := label.new(
             anchorBar,
             0,
             "Start " + windowLabel,
             xloc = xloc.bar_index,
             style = label.style_label_up,
             color = color.new(color.gray, 20),
             textcolor = color.white,
             size = size.small)

// ---------------------------------------------------------
// Helper functions
// ---------------------------------------------------------

swapFloat(array<float> a, int i, int j) =>
    tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

swapString(array<string> a, int i, int j) =>
    tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

swapColor(array<color> a, int i, int j) =>
    tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

f_fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

// ---------------------------------------------------------
// Ranking table
// ---------------------------------------------------------

var table t = table.new(position.top_right, 6, 13, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 5, 12)

    // Right spacer column to prevent TradingView buttons from covering the actual table
    for padRow = 0 to 12
        table.cell(
             t,
             5,
             padRow,
             spacerText,
             bgcolor = color.new(color.black, 100),
             text_color = color.new(color.white, 100))

    if showTable
        tickers = array.from(
             "XLK",
             "XLC",
             "XLY",
             "XLI",
             "XLB",
             "XLE",
             "XLP",
             "XLV",
             "XLU",
             "XLF",
             "XLRE")

        sectors = array.from(
             "Technology",
             "Communication",
             "Discretionary",
             "Industrials",
             "Materials",
             "Energy",
             "Staples",
             "Health Care",
             "Utilities",
             "Financials",
             "Real Estate")

        returns = array.from(
             xlk_perf,
             xlc_perf,
             xly_perf,
             xli_perf,
             xlb_perf,
             xle_perf,
             xlp_perf,
             xlv_perf,
             xlu_perf,
             xlf_perf,
             xlre_perf)

        rels = array.from(
             xlk_perf - spy_perf,
             xlc_perf - spy_perf,
             xly_perf - spy_perf,
             xli_perf - spy_perf,
             xlb_perf - spy_perf,
             xle_perf - spy_perf,
             xlp_perf - spy_perf,
             xlv_perf - spy_perf,
             xlu_perf - spy_perf,
             xlf_perf - spy_perf,
             xlre_perf - spy_perf)

        cols = array.from(
             c_xlk,
             c_xlc,
             c_xly,
             c_xli,
             c_xlb,
             c_xle,
             c_xlp,
             c_xlv,
             c_xlu,
             c_xlf,
             c_xlre)

        for i = 0 to array.size(rels) - 2
            for j = i + 1 to array.size(rels) - 1
                left = array.get(rels, i)
                right = array.get(rels, j)

                if not na(right) and (na(left) or right > left)
                    swapFloat(rels, i, j)
                    swapFloat(returns, i, j)
                    swapString(tickers, i, j)
                    swapString(sectors, i, j)
                    swapColor(cols, i, j)

        headerBg = color.new(color.gray, 65)
        titleBg = color.new(color.gray, 75)

        table.cell(t, 0, 0, "Window", bgcolor=titleBg, text_color=color.white)
        table.cell(t, 1, 0, windowLabel, bgcolor=titleBg, text_color=color.white)
        table.cell(t, 2, 0, mode, bgcolor=titleBg, text_color=color.white)
        table.cell(t, 3, 0, "SPY", bgcolor=titleBg, text_color=color.white)
        table.cell(t, 4, 0, f_fmt(spy_perf), bgcolor=titleBg, text_color=color.white)

        table.cell(t, 0, 1, "Rank", bgcolor=headerBg, text_color=color.white)
        table.cell(t, 1, 1, "ETF", bgcolor=headerBg, text_color=color.white)
        table.cell(t, 2, 1, "Sector", bgcolor=headerBg, text_color=color.white)
        table.cell(t, 3, 1, "Perf.", bgcolor=headerBg, text_color=color.white)
        table.cell(t, 4, 1, "vs SPY", bgcolor=headerBg, text_color=color.white)

        for r = 0 to array.size(tickers) - 1
            row = r + 2
            rowColor = color.new(array.get(cols, r), 82)

            table.cell(t, 0, row, str.tostring(r + 1), bgcolor=rowColor, text_color=color.white)
            table.cell(t, 1, row, array.get(tickers, r), bgcolor=rowColor, text_color=color.white)
            table.cell(t, 2, row, array.get(sectors, r), bgcolor=rowColor, text_color=color.white)
            table.cell(t, 3, row, f_fmt(array.get(returns, r)), bgcolor=rowColor, text_color=color.white)
            table.cell(t, 4, row, f_fmt(array.get(rels, r)), bgcolor=rowColor, text_color=color.white)

// ---------------------------------------------------------
// Staggered end labels
// ---------------------------------------------------------

var label[] endLabels = array.new<label>()
var line[] endLabelLines = array.new<line>()

if barstate.islast
    if array.size(endLabels) > 0
        for i = 0 to array.size(endLabels) - 1
            label.delete(array.get(endLabels, i))
    array.clear(endLabels)

    if array.size(endLabelLines) > 0
        for i = 0 to array.size(endLabelLines) - 1
            line.delete(array.get(endLabelLines, i))
    array.clear(endLabelLines)

    if showEndLabels
        labelNames = array.from(
             "SPY Benchmark",
             "Technology (XLK)",
             "Communication Services (XLC)",
             "Consumer Discretionary (XLY)",
             "Industrials (XLI)",
             "Materials (XLB)",
             "Energy (XLE)",
             "Consumer Staples (XLP)",
             "Health Care (XLV)",
             "Utilities (XLU)",
             "Financials (XLF)",
             "Real Estate (XLRE)")

        labelValues = array.from(
             spy_line,
             xlk_line,
             xlc_line,
             xly_line,
             xli_line,
             xlb_line,
             xle_line,
             xlp_line,
             xlv_line,
             xlu_line,
             xlf_line,
             xlre_line)

        labelColors = array.from(
             c_spy,
             c_xlk,
             c_xlc,
             c_xly,
             c_xli,
             c_xlb,
             c_xle,
             c_xlp,
             c_xlv,
             c_xlu,
             c_xlf,
             c_xlre)

        for i = 0 to array.size(labelValues) - 2
            for j = i + 1 to array.size(labelValues) - 1
                left = array.get(labelValues, i)
                right = array.get(labelValues, j)

                if not na(right) and (na(left) or right > left)
                    swapFloat(labelValues, i, j)
                    swapString(labelNames, i, j)
                    swapColor(labelColors, i, j)

        float lastLabelY = na

        for r = 0 to array.size(labelNames) - 1
            rawY = array.get(labelValues, r)

            if not na(rawY)
                adjustedY = na(lastLabelY) ? rawY : math.min(rawY, lastLabelY - labelMinGap)
                lastLabelY := adjustedY

                col = array.get(labelColors, r)
                txt = array.get(labelNames, r)

                newLabel = label.new(
                     bar_index + labelOffset,
                     adjustedY,
                     txt,
                     xloc = xloc.bar_index,
                     style = label.style_label_left,
                     color = color.new(col, 0),
                     textcolor = color.white,
                     size = size.small)

                array.push(endLabels, newLabel)

                if showLabelConnectors and math.abs(adjustedY - rawY) > 0.0001
                    connector = line.new(
                         bar_index,
                         rawY,
                         bar_index + labelOffset,
                         adjustedY,
                         xloc = xloc.bar_index,
                         extend = extend.none,
                         color = color.new(col, 55),
                         style = line.style_dotted,
                         width = 1)

                    array.push(endLabelLines, connector)
````
