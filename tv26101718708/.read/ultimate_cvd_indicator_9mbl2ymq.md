# Ultimate CVD Indicator

- url: https://www.tradingview.com/script/9MBl2yMq-Ultimate-CVD-Indicator/
- type: indicator
- pine_id: PUB;4b7580c41e964f69b30fc6c7ae722ec3
- version: 1.0

## Description

Cumulative Volume Delta indicator that plots CVD and flags potential absorption and exhaustion divergences between price and volume flow.
Core Features

CVD Calculation — Builds a running cumulative delta using a price-positioned volume approximation: ((close - low) - (high - close)) / range × volume.
CVD + MA Overlay — Plots the raw CVD line with an optional moving average and a fill that changes color based on whether CVD is above or below its average.
Pivot-Based Divergence Detection — Identifies pivot highs and lows on the CVD series and compares consecutive pivots (within a configurable bar range) against the corresponding price action.

Four Signal Types:

Bullish Exhaustion (EXH) — Price makes a lower low while CVD makes a higher low.
Bullish Absorption (ABS) — Price makes a higher low while CVD makes a lower low.
Bearish Exhaustion (EXH) — Price makes a higher high while CVD makes a lower high.
Bearish Absorption (ABS) — Price makes a lower high while CVD makes a higher high.

Visual Markers — Draws small labels (“EXH” or “ABS”) and connecting lines on the CVD pane at confirmed pivots. Lines are automatically managed and limited so the chart doesn’t become cluttered.
Customizable Settings — Pivot lookback lengths, minimum/maximum search range between pivots, MA length, and maximum number of lines to retain.

The indicator is designed for the lower pane (non-overlay) and focuses on highlighting possible points of interest where price and cumulative volume delta diverge.

CVD divergences compare how price is moving against how Cumulative Volume Delta is moving. The indicator focuses on four specific types that often appear at potential turning or continuation points.
Bullish Signals (usually near lows)

Bullish Exhaustion

Price makes a lower low, but CVD makes a higher low.
Sellers are pushing price down, yet cumulative buy pressure is improving. This often suggests selling is losing strength and a bounce or reversal may be developing.

Bullish Absorption

Price makes a higher low, but CVD makes a lower low.
Price is holding up (or rising slightly) while CVD is weaker. Buyers are absorbing selling pressure without price falling further. This can indicate accumulation and potential upside continuation.

Bearish Signals (usually near highs)

Bearish Exhaustion

Price makes a higher high, but CVD makes a lower high.
Buyers are pushing price up, yet cumulative sell pressure is increasing (or buy pressure is fading). This often suggests buying is exhausted and a pullback or reversal may be near.

Bearish Absorption

Price makes a lower high, but CVD makes a higher high.
Price is failing to make progress upward while CVD remains strong. Sellers are absorbing buying pressure. This can indicate distribution and potential downside continuation.

## Source Code

````pine
// © Fundorin89 / Ultimate
//@version=6
indicator(title="Ultimate CVD Indicator", shorttitle="CVD Ultimate", overlay=false, format=format.price, max_lines_count=500)

// --- Inputs ---
periodMa   = input.int(20, "MA Length", minval=1)
plotMa     = input.bool(true, "Plot MA?")
lbR        = input.int(3, "Pivot Lookback Right")
lbL        = input.int(5, "Pivot Lookback Left")
rangeUpper = input.int(60, "Max Search Range")
rangeLower = input.int(5, "Min Search Range")
maxLines   = input.int(50, "Max Lines to Keep", minval=10, maxval=200)

// Colors
exhColor   = color.new(color.gray, 40)
absBullCol = color.new(#00ffbb, 0)
absBearCol = color.new(#ff0055, 0)

// --- CVD Calculation ---
calc_cvd() =>
    float _range = high - low
    _range == 0 ? 0.0 : ((close - low) - (high - close)) / _range * volume

var float cumDelta = 0.0
cumDelta += calc_cvd()
cvdMa = ta.sma(cumDelta, periodMa)

// --- CVD Plotting ---
plotRef1 = plot(cumDelta, color=color.new(color.yellow, 0), title="CVD")
plotRef2 = plot(plotMa ? cvdMa : na, color=color.new(color.white, 50), title="CVD MA")
fill(plotRef1, plotRef2, cumDelta > cvdMa ? color.new(color.teal, 85) : color.new(color.red, 85))

// --- Pivot Detection ---
ph = ta.pivothigh(cumDelta, lbL, lbR)
pl = ta.pivotlow(cumDelta, lbL, lbR)

// Stored previous pivots
var float prevPlCvd   = na
var float prevPlPrice = na
var int   prevPlIdx   = na

var float prevPhCvd   = na
var float prevPhPrice = na
var int   prevPhIdx   = na

// Line management
var array<line> bullLines = array.new<line>()
var array<line> bearLines = array.new<line>()

f_manageLine(array<line> arr, line ln) =>
    array.push(arr, ln)
    if array.size(arr) > maxLines
        line.delete(array.shift(arr))

// --- Process Pivot Lows (Bullish) ---
if not na(pl)
    float currCvd   = cumDelta[lbR]
    float currPrice = low[lbR]
    int   currIdx   = bar_index[lbR]

    if not na(prevPlIdx)
        int barsBetween = currIdx - prevPlIdx
        if barsBetween >= rangeLower and barsBetween <= rangeUpper
            bool bullExh = currPrice < prevPlPrice and currCvd > prevPlCvd
            bool bullAbs = currPrice > prevPlPrice and currCvd < prevPlCvd

            if bullExh or bullAbs
                label.new(currIdx, currCvd, bullExh ? "EXH" : "ABS",
                     style=label.style_label_up,
                     color=bullExh ? exhColor : absBullCol,
                     textcolor=color.white,
                     size=size.tiny)

                line ln = line.new(prevPlIdx, prevPlCvd, currIdx, currCvd,
                     color=bullExh ? exhColor : absBullCol, width=2)
                f_manageLine(bullLines, ln)

    // Update stored previous
    prevPlCvd   := currCvd
    prevPlPrice := currPrice
    prevPlIdx   := currIdx

// --- Process Pivot Highs (Bearish) ---
if not na(ph)
    float currCvd   = cumDelta[lbR]
    float currPrice = high[lbR]
    int   currIdx   = bar_index[lbR]

    if not na(prevPhIdx)
        int barsBetween = currIdx - prevPhIdx
        if barsBetween >= rangeLower and barsBetween <= rangeUpper
            bool bearExh = currPrice > prevPhPrice and currCvd < prevPhCvd
            bool bearAbs = currPrice < prevPhPrice and currCvd > prevPhCvd

            if bearExh or bearAbs
                label.new(currIdx, currCvd, bearExh ? "EXH" : "ABS",
                     style=label.style_label_down,
                     color=bearExh ? exhColor : absBearCol,
                     textcolor=color.white,
                     size=size.tiny)

                line ln = line.new(prevPhIdx, prevPhCvd, currIdx, currCvd,
                     color=bearExh ? exhColor : absBearCol, width=2)
                f_manageLine(bearLines, ln)

    // Update stored previous
    prevPhCvd   := currCvd
    prevPhPrice := currPrice
    prevPhIdx   := currIdx
````
