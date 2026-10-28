# DAX Universe Relative Strength & Volume Quality  [JS]

- url: https://www.tradingview.com/script/r4rTT5PA/
- type: indicator
- pine_id: PUB;d541896959164badb4c52d62381c4549
- version: 1.0

## Description

DAX Universe RS & Volume Quality [JS] is a relative strength and pullback quality indicator designed for German stocks from the DAX, MDAX, SDAX and TecDAX universe.

The indicator measures a stock’s weighted relative performance against an equal-weighted German equity benchmark made from DAX, MDAX, SDAX and TecDAX. The relative strength model is inspired by IBD / Minervini-style momentum analysis, giving more weight to recent performance while still considering the medium- and longer-term trend.

Relative Strength Model:
• 40% weight: approx. 3-month performance
• 20% weight: approx. 6-month performance
• 20% weight: approx. 9-month performance
• 20% weight: approx. 12-month performance

The result is displayed as a percentage relative to the German stock universe benchmark:
• RS above 0% = the stock is outperforming the benchmark
• RS below 0% = the stock is underperforming the benchmark
• RS above the user-defined strength threshold = RS STARK / strong relative strength

In addition to relative strength, the indicator includes a High-Volume Down-Day filter. This helps assess whether a pullback is still constructive or whether distribution pressure may be increasing. The user can define:
• Lookback period
• Minimum loss required for a down-day to count
• Volume moving average length
• High-volume factor
• Maximum allowed High-Volume Down-Days

The simplified status box highlights the current setup condition using color:
• Green = strong relative strength and acceptable volume quality
• Yellow = positive or improving relative strength, but not yet ideal
• Red = weak relative strength or too many High-Volume Down-Days

The textbox position, size, width and height can be adjusted in the indicator settings.

This indicator is designed as a decision-support and screening tool for relative strength, pullback quality and German stock leadership analysis. It is not an official IBD RS Rating and does not provide financial advice or automatic buy/sell recommendations. Always combine it with your own chart analysis, risk management and market context.

## Source Code

````pine
 // This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
 // © JS_TechTrading

//@version=6
indicator("DAX Universe Relative Strength [JS]", shorttitle="DAX RS", overlay=false, max_labels_count=50)

// ------------------------------------------------------------
// DAX Universe Relative Strength [JS]
// Optimized Pine v6 version
//
// Relative strength of a stock versus an equal-weighted benchmark
// made from DAX, MDAX, SDAX and TecDAX.
//
// RS logic:
// Minervini / IBD-style weighted relative momentum:
//
// 40% = 3-month relative performance
// 20% = 6-month relative performance
// 20% = 9-month relative performance
// 20% = 12-month relative performance
//
// Textbox:
// Simplified and adjustable.
// Default width = 25
// Default height = 20
// Default position = middle
// ------------------------------------------------------------

// ============================================================
// Input groups
// ============================================================
groupRS      = "Weighted Relative Strength"
groupBench   = "Benchmark"
groupHV      = "High-Volume Down-Days"
groupDisplay = "Display"

// === Weighted Relative Strength Inputs ===
rsPeriod1 = input.int(63, "Recent RS period, default 3 months", minval=5, maxval=500, group=groupRS)
rsPeriod2 = input.int(126, "Medium RS period, default 6 months", minval=5, maxval=500, group=groupRS)
rsPeriod3 = input.int(189, "Long RS period, default 9 months", minval=5, maxval=500, group=groupRS)
rsPeriod4 = input.int(252, "Very long RS period, default 12 months", minval=5, maxval=750, group=groupRS)

rsWeight1 = input.float(0.40, "Weight recent period", minval=0.0, maxval=1.0, step=0.05, group=groupRS)
rsWeight2 = input.float(0.20, "Weight medium period", minval=0.0, maxval=1.0, step=0.05, group=groupRS)
rsWeight3 = input.float(0.20, "Weight long period", minval=0.0, maxval=1.0, step=0.05, group=groupRS)
rsWeight4 = input.float(0.20, "Weight very long period", minval=0.0, maxval=1.0, step=0.05, group=groupRS)

maLen = input.int(10, "RS smoothing MA", minval=1, group=groupRS)

rsStrongThreshold = input.float(10.0, "RS strong threshold %", minval=0.0, maxval=200.0, step=0.5, group=groupRS)

// === Benchmark Symbols ===
symDAX    = input.symbol("XETR:DAX", "DAX", group=groupBench)
symMDAX   = input.symbol("XETR:MDAX", "MDAX", group=groupBench)
symSDAX   = input.symbol("XETR:SDXP", "SDAX", group=groupBench)
symTECDAX = input.symbol("XETR:TDXP", "TecDAX", group=groupBench)

// === High-Volume Down-Day Settings ===
showHVInfo    = input.bool(true, "Show HV Down-Day info in box", group=groupHV)
showHVMarkers = input.bool(true, "Show HV Down-Day markers", group=groupHV)

hvLookback       = input.int(10, "Lookback period", minval=2, maxval=50, group=groupHV)
minDownDayLossPc = input.float(0.0, "Minimum down-day loss %", minval=0.0, maxval=20.0, step=0.1, group=groupHV)
volMaLen         = input.int(50, "Volume MA length", minval=5, maxval=200, group=groupHV)
highVolFactor    = input.float(1.25, "High-volume factor", minval=1.00, maxval=3.00, step=0.05, group=groupHV)
maxHVDays        = input.int(2, "Allowed HV Down-Days", minval=0, maxval=10, group=groupHV)

// === Display Inputs ===
showHist    = input.bool(true, "Show histogram", group=groupDisplay)
showLabel   = input.bool(true, "Show interpretation box", group=groupDisplay)
showBg      = input.bool(true, "Color background by setup status", group=groupDisplay)
showSignals = input.bool(true, "Show RS cross signals", group=groupDisplay)

boxSizeInput = input.string(
     "Large",
     "Textbox text size",
     options=["Small", "Normal", "Large", "Huge"],
     group=groupDisplay
)

boxPositionInput = input.string(
     "Mitte",
     "Textbox position",
     options=["Links", "Mitte", "Rechts"],
     group=groupDisplay
)

boxWidthInput = input.int(
     25,
     "Textbox width",
     minval=10,
     maxval=100,
     group=groupDisplay
)

boxHeightInput = input.int(
     20,
     "Textbox height",
     minval=3,
     maxval=50,
     group=groupDisplay
)

boxTextSize =
     boxSizeInput == "Huge" ? size.huge :
     boxSizeInput == "Large" ? size.large :
     boxSizeInput == "Normal" ? size.normal :
     size.small

boxPosition =
     boxPositionInput == "Links" ? position.middle_left :
     boxPositionInput == "Rechts" ? position.middle_right :
     position.middle_center

// ============================================================
// Helper functions
// ============================================================

f_sec(sym) =>
    request.security(sym, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

f_perf(src, len) =>
    not na(src) and not na(src[len]) and src[len] != 0 ? src / src[len] : na

f_weightedMomentum(src) =>
    perf1 = f_perf(src, rsPeriod1)
    perf2 = f_perf(src, rsPeriod2)
    perf3 = f_perf(src, rsPeriod3)
    perf4 = f_perf(src, rsPeriod4)

    validWeight =
         (na(perf1) ? 0.0 : rsWeight1) +
         (na(perf2) ? 0.0 : rsWeight2) +
         (na(perf3) ? 0.0 : rsWeight3) +
         (na(perf4) ? 0.0 : rsWeight4)

    weightedSum =
         nz(perf1) * rsWeight1 +
         nz(perf2) * rsWeight2 +
         nz(perf3) * rsWeight3 +
         nz(perf4) * rsWeight4

    validWeight > 0 ? weightedSum / validWeight : na

// ============================================================
// Benchmark data
// ============================================================

daxClose    = f_sec(symDAX)
mdaxClose   = f_sec(symMDAX)
sdaxClose   = f_sec(symSDAX)
tecdaxClose = f_sec(symTECDAX)

// ============================================================
// Weighted RS calculation
// ============================================================

stockMomentum  = f_weightedMomentum(close)
daxMomentum    = f_weightedMomentum(daxClose)
mdaxMomentum   = f_weightedMomentum(mdaxClose)
sdaxMomentum   = f_weightedMomentum(sdaxClose)
tecdaxMomentum = f_weightedMomentum(tecdaxClose)

benchCount =
     (na(daxMomentum) ? 0 : 1) +
     (na(mdaxMomentum) ? 0 : 1) +
     (na(sdaxMomentum) ? 0 : 1) +
     (na(tecdaxMomentum) ? 0 : 1)

benchSum =
     nz(daxMomentum) +
     nz(mdaxMomentum) +
     nz(sdaxMomentum) +
     nz(tecdaxMomentum)

benchMomentum =
     benchCount > 0 ? benchSum / benchCount : na

rs =
     not na(stockMomentum) and
     not na(benchMomentum) and
     benchMomentum != 0 ?
     (stockMomentum / benchMomentum - 1.0) * 100.0 :
     na

rsMA = ta.sma(rs, maLen)

// ============================================================
// High-Volume Down-Day logic
// ============================================================

volMA = ta.sma(volume, volMaLen)

dayChangePct =
     close[1] != 0 ?
     (close / close[1] - 1.0) * 100.0 :
     na

downDayLossPct =
     not na(dayChangePct) and dayChangePct < 0 ?
     math.abs(dayChangePct) :
     0.0

isDownDay =
     not na(dayChangePct) and
     close < close[1] and
     downDayLossPct >= minDownDayLossPc

isHighVolume =
     not na(volMA) and
     volume > volMA * highVolFactor

highVolDownDay =
     isDownDay and isHighVolume

downDayCount =
     math.sum(isDownDay ? 1 : 0, hvLookback)

highVolDownCount =
     math.sum(highVolDownDay ? 1 : 0, hvLookback)

hvFilterOk =
     highVolDownCount <= maxHVDays

volumeDanger =
     not hvFilterOk

hvDetailText =
     "Down-Days: " + str.tostring(downDayCount, "#") + " / " + str.tostring(hvLookback, "#") +
     " (>=" + str.tostring(minDownDayLossPc, "#.##") + "%)" +
     ", HV DDays: " + str.tostring(highVolDownCount, "#") + " / " + str.tostring(maxHVDays, "#")

// ============================================================
// RS status logic
// ============================================================

rsReady =
     not na(rs) and
     not na(rsMA) and
     not na(rsMA[1])

rsStrong =
     rsReady and
     rs >= rsStrongThreshold

rsPositive =
     rsReady and
     rs > 0 and
     rs < rsStrongThreshold

rsImproving =
     rsReady and
     rs < 0 and
     rsMA > rsMA[1]

rsWeak =
     rsReady and
     rs < 0 and
     not rsImproving

statusText =
     rsStrong ? "RS STARK" :
     rsPositive ? "RS POSITIV" :
     rsImproving ? "RS VERBESSERT SICH" :
     rsWeak ? "RS SCHWACH" :
     "RS NEUTRAL"

// ============================================================
// Entry quality / Textbox color logic
// ============================================================

hvAtLimit =
     hvFilterOk and
     highVolDownCount == maxHVDays and
     maxHVDays > 0

entryGreen =
     rsStrong and
     hvFilterOk and
     not hvAtLimit

entryYellow =
     hvFilterOk and
     (
         rsPositive or
         rsImproving or
         (rsStrong and hvAtLimit)
     )

entryRed =
     not entryGreen and
     not entryYellow

statusColor =
     entryGreen ? color.new(color.green, 0) :
     entryYellow ? color.new(color.yellow, 0) :
     color.new(color.red, 0)

boxTextColor =
     entryYellow ? color.black : color.white

plotColor =
     volumeDanger ? color.new(color.red, 0) :
     rsReady and rs >= rsStrongThreshold ? color.new(color.green, 0) :
     rsReady and rs > 0 ? color.new(color.lime, 0) :
     rsReady and rs < 0 ? color.new(color.orange, 0) :
     color.new(color.gray, 0)

// ============================================================
// Plots
// ============================================================

zeroPlot = plot(0, title="Zero line", color=color.new(color.gray, 40), linewidth=1)

rsPlot = plot(
     rs,
     title="Weighted Relative Strength vs. DAX Universe (%)",
     color=plotColor,
     linewidth=2
)

maPlot = plot(
     rsMA,
     title="Weighted RS Moving Average",
     color=color.new(color.blue, 0),
     linewidth=1
)

strongThresholdPlot = plot(
     rsStrongThreshold,
     title="RS Strong Threshold",
     color=color.new(color.green, 55),
     linewidth=1,
     style=plot.style_line
)

plot(
     showHist ? rs : na,
     title="Weighted RS Histogram",
     style=plot.style_columns,
     color=color.new(plotColor, 80)
)

fill(
     rsPlot,
     zeroPlot,
     title="RS Zone",
     color=color.new(plotColor, 88)
)

bgcolor(showBg ? color.new(statusColor, 92) : na)

// ============================================================
// Markers
// ============================================================

plotshape(
     showHVMarkers and highVolDownDay,
     title="High-Volume Down-Day",
     style=shape.triangledown,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="HV"
)

rsCrossAboveZero = ta.crossover(rs, 0)
rsCrossBelowZero = ta.crossunder(rs, 0)
rsCrossAboveMA   = ta.crossover(rs, rsMA)
rsCrossBelowMA   = ta.crossunder(rs, rsMA)
rsCrossAboveStrongThreshold = ta.crossover(rs, rsStrongThreshold)
rsCrossBelowStrongThreshold = ta.crossunder(rs, rsStrongThreshold)

plotshape(
     showSignals and rsCrossAboveZero,
     title="RS above zero",
     style=shape.triangleup,
     location=location.bottom,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="RS+"
)

plotshape(
     showSignals and rsCrossBelowZero,
     title="RS below zero",
     style=shape.triangledown,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="RS-"
)

plotshape(
     showSignals and rsCrossAboveStrongThreshold,
     title="RS above strong threshold",
     style=shape.triangleup,
     location=location.bottom,
     color=color.new(color.lime, 0),
     size=size.tiny,
     text="STR"
)

// ============================================================
// Adjustable interpretation box
// ============================================================

var table rsTable = table.new(
     boxPosition,
     1,
     1,
     border_width=2,
     frame_width=2,
     frame_color=color.new(color.white, 55),
     border_color=color.new(color.white, 55)
)

labelText =
     statusText + " | RS: " + str.tostring(rs, "#.##") + "% | MA: " + str.tostring(rsMA, "#.##") + "%" +
     (showHVInfo ? "\n" + hvDetailText : "")

if barstate.islast
    if showLabel
        table.cell(
             rsTable,
             0,
             0,
             labelText,
             width=boxWidthInput,
             height=boxHeightInput,
             text_color=boxTextColor,
             bgcolor=statusColor,
             text_size=boxTextSize,
             text_halign=text.align_left,
             text_valign=text.align_center
        )
    else
        table.cell(
             rsTable,
             0,
             0,
             "",
             width=boxWidthInput,
             height=boxHeightInput,
             text_color=color.white,
             bgcolor=color.new(color.black, 100),
             text_size=boxTextSize
        )

// ============================================================
// Alerts
// ============================================================

volumeDangerStart =
     volumeDanger and
     not volumeDanger[1]

hvFilterBackToOk =
     hvFilterOk and
     not hvFilterOk[1]

entryGreenSignal =
     entryGreen and
     not entryGreen[1]

entryYellowSignal =
     entryYellow and
     not entryYellow[1]

entryRedSignal =
     entryRed and
     not entryRed[1]

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

alertcondition(
     rsCrossAboveStrongThreshold,
     title="RS überschreitet Stark-Schwellenwert",
     message="{{ticker}}: RS überschreitet den definierten Stark-Schwellenwert."
)

alertcondition(
     rsCrossBelowStrongThreshold,
     title="RS fällt unter Stark-Schwellenwert",
     message="{{ticker}}: RS fällt unter den definierten Stark-Schwellenwert."
)

alertcondition(
     highVolDownDay,
     title="High-Volume Down-Day erkannt",
     message="{{ticker}}: High-Volume Down-Day erkannt."
)

alertcondition(
     volumeDangerStart,
     title="Zu viele High-Volume Down-Days",
     message="{{ticker}}: Mehr High-Volume Down-Days als erlaubt im gewählten Lookback-Zeitraum."
)

alertcondition(
     hvFilterBackToOk,
     title="High-Volume Down-Day Filter wieder OK",
     message="{{ticker}}: High-Volume Down-Day Filter ist wieder innerhalb des erlaubten Bereichs."
)

alertcondition(
     entryGreenSignal,
     title="Setup: Einstieg OK",
     message="{{ticker}}: Setup ist grün. RS liegt über dem Stark-Schwellenwert und High-Volume Down-Day Filter ist konstruktiv."
)

alertcondition(
     entryYellowSignal,
     title="Setup: Grenzbereich / Watchlist",
     message="{{ticker}}: Setup ist gelb. Aktie gehört auf die Watchlist, aber Einstieg ist noch nicht ideal."
)

alertcondition(
     entryRedSignal,
     title="Setup: Kein Einstieg",
     message="{{ticker}}: Setup ist rot. Einstieg aktuell nicht empfohlen."
)
````
