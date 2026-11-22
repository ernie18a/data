# Compare Overlay (Bottom of Screen)

- url: https://www.tradingview.com/script/hl0dYLXl-Compare-Overlay-Bottom-of-Screen/
- type: indicator
- pine_id: PUB;7b0754c7891f44a888d7f12bf7d4ffce
- version: 1.0

## Description

Plots a second symbol (ES1! by default) directly on your main chart, pinned to the bottom of the screen instead of in a separate pane. It works like TradingView's "Compare symbol" tool, but it runs on its own hidden scale, so it isn't tied to your main chart's price. You can drag, zoom or rescale the chart and the overlay stays in a band along the bottom edge.

Built for spotting SMT divergence between NQ and ES without giving up screen space to an extra pane.

HOW IT WORKS
The script plots the comparison symbol on a hidden "No scale" axis. It measures the symbol's high and low across the bars currently on screen, then places invisible anchors so the symbol fills a set band at the bottom of the chart. It recalculates whenever you scroll or zoom. Backup anchors on off-screen bars keep it near the bottom while the chart catches up during a zoom.

STYLES
- Line: a single line using your chosen price source (Open, High, Low, Close, HL2, HLC3, OHLC4)
- Candles / Hollow candles: full candles with wicks
- Bars: OHLC bars
- High/Low lines: two lines tracing every high and low. The cleanest option for SMT.

SETTINGS
- Symbol: any symbol you want to compare (ES, YM, RTY, DXY, etc.)
- Style, colours, line width, price label and price line
- Band height: how much of the screen the overlay uses
- Bottom padding: space between the overlay and the bottom edge
- Zoom stability: how many bars the backup anchors look at. Raise it if the overlay drifts up when you zoom out a long way.

TIPS
- For SMT, use High/Low lines or Bars so every wick is visible. Bearish SMT shows on the highs, bullish SMT on the lows.
- To have the overlay sit right on the bottom edge, set Bottom padding to 0 and set Chart settings > Canvas > Margins > Bottom to 0.
- If the overlay ever follows your main chart's price, right-click it and choose Pin to scale > No scale (full screen).

NOTES
- The overlay shows the shape of the second symbol's price action scaled to fit the band. It is not price-aligned with the main chart.
- It may shift briefly while you are actively zooming, then snap back once the chart finishes recalculating.

## Source Code

````pine
//@version=6
indicator("Overlay (Bottom of Screen)", shorttitle = "Overlay", overlay = true, scale = scale.none, max_labels_count = 1, max_lines_count = 1)

// ───────── Inputs ─────────
sym        = input.symbol("CME_MINI:ES1!", "Symbol", group = "Inputs")
styleOpt   = input.string("Line", "Style", options = ["Line", "Candles", "Hollow candles", "Bars", "High/Low lines"], group = "Style")
srcOpt     = input.string("Close", "Price source (Line only)", options = ["Open", "High", "Low", "Close", "(H + L)/2", "(H + L + C)/3", "(O + H + L + C)/4"], group = "Style")
lineCol    = input.color(#2962FF, "Line", inline = "ln", group = "Style")
lineW      = input.int(2, "", minval = 1, maxval = 4, inline = "ln", group = "Style")
upCol      = input.color(#089981, "Up", inline = "cd", group = "Style")
downCol    = input.color(#F23645, "Down", inline = "cd", group = "Style")
showPLine  = input.bool(false, "Price line", group = "Style")
showLabel  = input.bool(true, "Price label", group = "Style")
bandPct    = input.float(20.0, "Band height (% of screen)", minval = 5, maxval = 100, group = "Placement")
padPct     = input.float(0.0, "Bottom padding (% of screen)", minval = 0, maxval = 50, group = "Placement")
stabLen    = input.int(1000, "Zoom stability (bars)", minval = 50, maxval = 5000, group = "Placement", tooltip = "Keeps ES near the bottom while you zoom out, before the chart finishes recalculating. Raise it if it still jumps when zooming out a long way.")

// ───────── ES data ─────────
[eO, eH, eL, eC] = request.security(sym, timeframe.period, [open, high, low, close])
esSrc = switch srcOpt
    "Open"              => eO
    "High"              => eH
    "Low"               => eL
    "(H + L)/2"         => (eH + eL) / 2
    "(H + L + C)/3"     => (eH + eL + eC) / 3
    "(O + H + L + C)/4" => (eO + eH + eL + eC) / 4
    => eC

isLine   = styleOpt == "Line"
isCandle = styleOpt == "Candles" or styleOpt == "Hollow candles"
isHollow = styleOpt == "Hollow candles"
isBars   = styleOpt == "Bars"
isHL     = styleOpt == "High/Low lines"

rangeHi = isLine ? esSrc : eH
rangeLo = isLine ? esSrc : eL
lastVal = isLine ? esSrc : eC

// ───────── ES range on screen ─────────
inView = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time

var float esHi = na
var float esLo = na
if inView and not na(rangeHi) and not na(rangeLo)
    esHi := na(esHi) ? rangeHi : math.max(esHi, rangeHi)
    esLo := na(esLo) ? rangeLo : math.min(esLo, rangeLo)

// ───────── Exact anchors (on the last visible bar) ─────────
isAnchorBar = inView and (time == chart.right_visible_bar_time or barstate.islast)
esRange     = esHi - esLo
span        = esRange > 0 ? esRange / (bandPct / 100) : esLo * 0.001
floorV      = isAnchorBar ? esLo - span * padPct / 100 : na
ceilV       = isAnchorBar ? floorV + span : na

// ───────── Backup anchors (on bars off-screen, used while zooming out) ─────────
rollHi    = ta.highest(rangeHi, stabLen)
rollLo    = ta.lowest(rangeLo, stabLen)
rollRange = rollHi - rollLo
fbCeil    = not inView and rollRange > 0 ? rollLo + rollRange / (bandPct / 100) : na

topV = isAnchorBar ? ceilV : fbCeil

plot(topV,   "Top anchor",    color = color.new(color.black, 100), style = plot.style_circles, editable = false, display = display.pane)
plot(floorV, "Bottom anchor", color = color.new(color.black, 100), style = plot.style_circles, editable = false, display = display.pane)

// ───────── Colours ─────────
isUp   = eC >= eO
barCol = isUp ? upCol : downCol
clear  = color.new(color.black, 100)

// ───────── Line ─────────
plot(isLine ? esSrc : na, "ES Line", color = lineCol, linewidth = lineW)

// ───────── Candles / Hollow candles ─────────
plotcandle(isCandle ? eO : na, isCandle ? eH : na, isCandle ? eL : na, isCandle ? eC : na, "ES Candles", color = isHollow and isUp ? clear : barCol, wickcolor = barCol, bordercolor = barCol)

// ───────── Bars (OHLC) ─────────
plotbar(isBars ? eO : na, isBars ? eH : na, isBars ? eL : na, isBars ? eC : na, "ES Bars", color = barCol)

// ───────── High / Low lines ─────────
plot(isHL ? eH : na, "ES High", color = lineCol, linewidth = lineW)
plot(isHL ? eL : na, "ES Low",  color = color.new(lineCol, 40), linewidth = lineW)

// ───────── Price label + price line ─────────
var label lbl   = na
var line  pLine = na
if barstate.islast
    lbl.delete()
    pLine.delete()
    tagCol = isLine or isHL ? lineCol : barCol
    if showLabel
        lbl := label.new(bar_index + 1, lastVal, str.tostring(lastVal, "#,##0.00"), style = label.style_label_left, color = tagCol, textcolor = color.white, size = size.small)
    if showPLine
        pLine := line.new(bar_index - 1, lastVal, bar_index, lastVal, extend = extend.both, color = tagCol, style = line.style_dotted, width = 1)
````
