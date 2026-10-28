# Move Strength Index

- url: https://www.tradingview.com/script/CzWnIemm-Move-Strength-Index/
- type: indicator
- pine_id: PUB;e8aeb0a2c6414c03818f4b582578a569
- version: 1.0

## Description

Overview
An accurate relative-volume indicator with a genuinely clear signal:
column height shows the relative-volume multiple, color intensity
separately highlights which of those bars are actually unusual for that
specific symbol, and a distinct compression color flags the specific
case where heavy volume produces almost no range — a classic
effort-without-result signature that often precedes a sharp move.

How it's calculated
Relative volume is current volume divided by a smoothed (RMA) average of
the *prior* bars — the still-forming bar is excluded from its own
baseline (a common flaw in naive relative-volume scripts, which quietly
dampens real spikes), and the smoothed baseline decays gradually rather
than using a fixed rolling window, avoiding the "step" artifact that
occurs when an old outlier bar abruptly exits a fixed-length SMA window.
Color intensity is driven by the bar's percentile rank against its own
trailing history (default 100 bars), not a fixed multiple — a fixed
brightness cutoff only produces contrast if the symbol regularly reaches
that multiple, whereas percentile rank self-calibrates so the loudest
days for any given symbol are always vivid and quiet days are always
dim.

Direction is close vs. open — the same test used to color the candles on
the price chart itself, so MSI's green/red always agrees with what the
candle next to it shows.

A bar is recolored yellow (compression) when its volume ranks high
(top percentile, same threshold used for alerts) but its high-low range
is unusually narrow relative to ATR — heavy participation that isn't
moving price, which typically means one side is being absorbed at that
level. The live, still-forming bar is dimmed by default, since its
partial volume will always understate true relative volume until the
bar closes.

How to use it
Column height is the relative-volume multiple directly — a bar at 2.0
traded at twice its recent baseline volume. Brightness tells you whether
that reading is actually unusual for this symbol; a tall but dull column
means the symbol just runs volatile volume normally, while a vivid
column is a genuine standout. Green/red tells you which side controlled
the bar. A yellow bar is the one to watch closely — high volume with
nothing to show for it in price, often the setup before a breakout or
breakdown. Alerts fire separately for strong buying, strong selling, and
compression. On a symbol with no real volume data, the script raises a
clear error instead of rendering a blank pane.

## Source Code

````pine
//@version=6
indicator('Move Strength Index', shorttitle = 'MSI', overlay = false)

// Column height is relative volume — current bar vs. a smoothed,
// prior-bar-excluded baseline — so height reads as an intuitive "x average"
// multiple. Color intensity is driven separately, by the bar's percentile
// rank against its own recent history, not a fixed multiple: a fixed
// brightness cutoff (e.g. "full color at 3x") only works if a symbol
// regularly reaches 3x, and otherwise everything clusters in the same dim
// band with no contrast. Percentile rank self-calibrates per symbol and
// timeframe, so the loudest days for THIS symbol are always vivid and the
// quiet days are always dim, giving a genuinely clear signal either way.
//
// Direction is close vs. open, matching how the candles on the chart
// itself are colored — a range-position test (which half of the bar the
// close sits in) is arguably more information-rich, but it can disagree
// with the candle's own color on long-wick bars, which reads as a bug
// rather than a feature. Staying consistent with what's on screen matters
// more than the extra nuance.
//
// A bar is flagged as COMPRESSION (unusually high volume packed into an
// unusually narrow range) when volume ranks high but the bar's range is
// small relative to its normal ATR — classic effort-without-result: heavy
// participation that isn't moving price usually means one side is being
// absorbed at that level, which often precedes a sharp expansion move.

volLen           = input.int(20,  'Volume Average Length',    minval = 1,  tooltip = 'Smoothing length for the baseline average. The current bar is excluded from its own average.')
rankLen          = input.int(100, 'Percentile Rank Lookback', minval = 20, tooltip = 'How much trailing history defines what counts as unusual volume for this symbol.')
strongPercentile = input.float(85, 'Strong Signal Percentile (>=)', minval = 50, maxval = 99, step = 1, tooltip = 'Volume rank required to count as "high volume" for both alerts and compression detection.')
dimUnconfirmed   = input.bool(true, 'Dim Unconfirmed (Forming) Bar', tooltip = 'The current, still-forming bar only has partial volume and will understate relative volume until it closes — dim it so it is not misread as genuinely low volume.')

grpComp = 'Compression'
atrLen           = input.int(14, 'ATR Length', minval = 1, group = grpComp)
compressionRatio = input.float(0.6, 'Narrow Range Threshold (x ATR)', minval = 0.1, maxval = 1.0, step = 0.05, group = grpComp, tooltip = 'A bar counts as narrow-range when its high-low range is at or below this fraction of ATR.')

colUp    = input.color(#26a69a, 'Bullish (Buying) Color',            group = 'Colors')
colDown  = input.color(#ef5350, 'Bearish (Selling) Color',           group = 'Colors')
colComp  = input.color(#ffd600, 'Compression (Effort/Result) Color', group = 'Colors')

// ─── Relative volume ───────────────────────────────────────────────────
avgVol = ta.rma(volume[1], volLen)
relVol = avgVol > 0 ? volume / avgVol : na

rank   = ta.percentrank(relVol, rankLen)          // 0-100: how unusual this bar's volume is vs. its own recent history
transp = na(rank) ? 50 : int(78 - rank * 0.68)    // 78 (dim) at rank 0 -> 10 (vivid) at rank 100
transp := dimUnconfirmed and not barstate.isconfirmed ? math.max(transp, 65) : transp

isHighVol = not na(rank) and rank >= strongPercentile

// ─── Direction: matches how the candle itself is colored ──────────────
isBull = close >= open

// ─── Compression: high volume packed into a narrow range ──────────────
trueRange  = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
atr        = ta.rma(trueRange, atrLen)
rangeRatio = atr > 0 ? (high - low) / atr : na
isNarrow   = not na(rangeRatio) and rangeRatio <= compressionRatio
isCompression = isHighVol and isNarrow

barColor = isCompression ? color.new(colComp, transp) : color.new(isBull ? colUp : colDown, transp)

plot(relVol, 'Relative Volume', style = plot.style_columns, color = barColor, histbase = 0)
hline(1, 'Average Volume', color = color.new(color.gray, 50))

alertcondition(isHighVol and isBull and not isCompression,     'Strong Buying Volume',  'Volume ranks in the top percentile for this symbol on a buyer-dominated bar')
alertcondition(isHighVol and not isBull and not isCompression, 'Strong Selling Volume', 'Volume ranks in the top percentile for this symbol on a seller-dominated bar')
alertcondition(isCompression, 'Volume Compression', 'High volume packed into an unusually narrow range — possible absorption, a sharp move may follow')

// Raise an error if no volume data is available, rather than rendering blank.
if ta.cum(nz(volume)) == 0.0 and barstate.islastconfirmedhistory
    runtime.error("No volume is provided by the data vendor.")
````
