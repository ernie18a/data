# Custom Fractals

- url: https://www.tradingview.com/script/gUjMbQNc-Custom-Fractals/
- type: indicator
- pine_id: PUB;49eaefdd21794893bdd234acc1a72d1d
- version: 2.0

## Description

This indicator detects custom bullish and bearish fractal formations by identifying confirmed swing highs and swing lows based on user-defined candle structure. A bearish fractal forms when a candle’s high is greater than the surrounding candles, while a bullish fractal forms when a candle’s low is lower than the surrounding candles. Optional RSI confirmation can be applied to filter signals so that bearish fractals only appear in overbought conditions and bullish fractals only appear in oversold conditions. The script can also draw horizontal pivot levels from each confirmed fractal to help visualize potential support and resistance zones.

“Bars Before” controls how many candles to the left of the pivot must confirm the fractal structure, while “Bars After” determines how many candles to the right are required before the signal becomes confirmed. Larger settings create stronger but less frequent fractals, while smaller settings react faster and generate more signals. “Non-Repaint Signals” waits for candle close confirmation before plotting signals to reduce repaint behavior during live market conditions. “Draw Horizontal Pivot Lines” displays support and resistance lines extending from confirmed fractals.

“Limit to Recent Signals Only” restricts how many historical fractals remain visible on the chart, while “Recent Signal Count” defines the maximum number of stored signals and pivot lines. “Use RSI Confirmation” enables momentum filtering using the Relative Strength Index. “RSI Length” controls the RSI calculation period, “RSI Source” selects the price source used for RSI calculations, and the “RSI Overbought” and “RSI Oversold” levels determine where RSI confirmation is required for bearish and bullish fractals.

The pivot line settings allow full customization of the horizontal structure levels. “Pivot Line Length” controls how far the level extends into future candles, while the color, width, and style settings customize the appearance of bullish and bearish pivot zones.

This tool is designed for traders who want to identify potential reversal zones, short-term exhaustion points, and key support or resistance levels using price structure and optional momentum confirmation.

## Source Code

````pine
//@version=6
indicator(
     "Custom Fractals",
     shorttitle="Custom Fractals",
     format=format.price,
     precision=0,
     overlay=true,
     max_lines_count=500,
     max_labels_count=500
)

// User inputs
leftBars          = input.int(title="Bars Before", defval=50, minval=1, maxval=200, step=1)
rightBars         = input.int(title="Bars After", defval=5, minval=1, maxval=100, step=1)
nonRepaintSignals = input.bool(title="Non-Repaint Signals (bar close only)", defval=true)
drawPivotLines    = input.bool(title="Draw Horizontal Pivot Lines", defval=true)
drawTriangles     = input.bool(title="Draw Triangles", defval=true)

// Historical lookback controls
useHistoricalLookback = input.bool(title="Limit to Recent Signals Only", defval=true)
historicalSignalCount = input.int(title="Recent Signal Count", defval=20, minval=1)

// RSI confirmation controls
useRsiConfirm = input.bool(title="Use RSI Confirmation", defval=false)
rsiLength     = input.int(title="RSI Length", defval=14, minval=1)
rsiSource     = input.source(title="RSI Source", defval=close)
rsiOverbought = input.float(title="RSI Overbought Level", defval=65.0, minval=0.0, maxval=100.0, step=1)
rsiOversold   = input.float(title="RSI Oversold Level", defval=35.0, minval=0.0, maxval=100.0, step=1)

// Pivot line controls
pivotLineBars   = input.int(title="Pivot Line Length (Bars)", defval=8, minval=1)
pivotHighColor  = input.color(title="High Pivot Line Color", defval=color.red)
pivotLowColor   = input.color(title="Low Pivot Line Color", defval=color.green)
pivotLineWidth  = input.int(title="Pivot Line Width", defval=2, minval=1, maxval=5)
pivotLineStyle  = input.string(title="Pivot Line Style", defval="Solid", options=["Solid", "Dashed", "Dotted"])

// Convert style input to Pine constant
lineStyle = line.style_solid
if pivotLineStyle == "Dashed"
    lineStyle := line.style_dashed
else if pivotLineStyle == "Dotted"
    lineStyle := line.style_dotted

// Safety: only evaluate once enough bars exist
enoughBars = bar_index >= leftBars + rightBars

// RSI
rsiValue     = ta.rsi(rsiSource, rsiLength)
candidateRsi = enoughBars ? rsiValue[rightBars] : na

// Candidate bar is rightBars bars back from the current bar
candidateHigh = enoughBars ? high[rightBars] : na
candidateLow  = enoughBars ? low[rightBars]  : na

// -------------------------
// High Fractal
// -------------------------
bool highLeftOk  = false
bool highRightOk = false

if enoughBars
    highLeftOk  := true
    highRightOk := true

    for i = 1 to leftBars
        highLeftOk := highLeftOk and (high[rightBars + i] < candidateHigh)

    for i = 1 to rightBars
        highRightOk := highRightOk and (high[rightBars - i] < candidateHigh)

highFractalRaw = enoughBars and highLeftOk and highRightOk

// -------------------------
// Low Fractal
// -------------------------
bool lowLeftOk  = false
bool lowRightOk = false

if enoughBars
    lowLeftOk  := true
    lowRightOk := true

    for i = 1 to leftBars
        lowLeftOk := lowLeftOk and (low[rightBars + i] > candidateLow)

    for i = 1 to rightBars
        lowRightOk := lowRightOk and (low[rightBars - i] > candidateLow)

lowFractalRaw = enoughBars and lowLeftOk and lowRightOk

// -------------------------
// RSI confirmation logic
// -------------------------
highRsiOk = not useRsiConfirm or (not na(candidateRsi) and candidateRsi > rsiOverbought)
lowRsiOk  = not useRsiConfirm or (not na(candidateRsi) and candidateRsi < rsiOversold)

// -------------------------
// Final signal logic
// -------------------------
highFractalBase = highFractalRaw and highRsiOk
lowFractalBase  = lowFractalRaw and lowRsiOk

highFractal = nonRepaintSignals ? (highFractalBase and barstate.isconfirmed) : highFractalBase
lowFractal  = nonRepaintSignals ? (lowFractalBase  and barstate.isconfirmed) : lowFractalBase

// -------------------------
// Object storage
// -------------------------
var label[] signalLabels = array.new_label()
var line[]  signalLines  = array.new_line()

// -------------------------
// Create and retain only last N signals
// -------------------------
if highFractal
    pivotBarIndex = bar_index - rightBars

    if drawTriangles
        lbl = label.new(
             x=pivotBarIndex,
             y=na,
             text="",
             yloc=yloc.abovebar,
             style=label.style_triangledown,
             color=color.red,
             textcolor=color.red,
             size=size.tiny
        )
        array.push(signalLabels, lbl)
    else
        array.push(signalLabels, na)

    if drawPivotLines
        ln = line.new(
             x1=pivotBarIndex,
             y1=candidateHigh,
             x2=pivotBarIndex + pivotLineBars,
             y2=candidateHigh,
             color=pivotHighColor,
             width=pivotLineWidth,
             style=lineStyle
        )
        array.push(signalLines, ln)
    else
        array.push(signalLines, na)

if lowFractal
    pivotBarIndex = bar_index - rightBars

    if drawTriangles
        lbl = label.new(
             x=pivotBarIndex,
             y=na,
             text="",
             yloc=yloc.belowbar,
             style=label.style_triangleup,
             color=color.green,
             textcolor=color.green,
             size=size.tiny
        )
        array.push(signalLabels, lbl)
    else
        array.push(signalLabels, na)

    if drawPivotLines
        ln = line.new(
             x1=pivotBarIndex,
             y1=candidateLow,
             x2=pivotBarIndex + pivotLineBars,
             y2=candidateLow,
             color=pivotLowColor,
             width=pivotLineWidth,
             style=lineStyle
        )
        array.push(signalLines, ln)
    else
        array.push(signalLines, na)

// Delete oldest objects if limit exceeded
limitCount = useHistoricalLookback ? historicalSignalCount : 100000

while array.size(signalLabels) > limitCount
    oldLbl = array.shift(signalLabels)
    if not na(oldLbl)
        label.delete(oldLbl)

    oldLn = array.shift(signalLines)
    if not na(oldLn)
        line.delete(oldLn)
````
