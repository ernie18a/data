# Index Breadth % Above Key Moving Averages

- url: https://www.tradingview.com/script/xHxOfgUY-Index-Breadth-Above-Key-Moving-Averages/
- type: indicator
- pine_id: PUB;99f826d9e91f4a819b5f01fc1c620543
- version: 1.0

## Description

Description:
This indicator measures the percentage of constituents in a selected index trading above a chosen moving average — a core read on market breadth and internal market health, beyond what price action on the index itself reveals.

What it does

Rather than calculating breadth from individual constituents (which runs into symbol-count limitations), this script pulls pre-aggregated breadth data feeds covering the S&P 500 (including 10 individual sectors), Nasdaq, Nasdaq 100, Dow Jones, Russell 2000/3000, and the broader market. You can select any of these markets and check the percentage above the 20, 50, 100, 150, or 200-day moving average.

Breadth Moving Average (new)

A configurable moving average of the breadth line itself has been added, with a choice of SMA, EMA, WMA, or HMA. This lets you track breadth momentum rather than just the absolute reading — a cross above the MA after a period of depressed breadth often precedes broader market expansion, while a cross below can flag internal deterioration before it shows up in price.

Features

-Selectable market and moving average length
-Configurable Greed/Fear zone thresholds with visual fill highlighting
-Breadth MA with four smoothing options
-Crossover markers (triangles) flagging momentum shifts
-Built-in alerts for MA crossovers and Greed/Fear zone entries

How to use it
Watch for breadth crossing above its own moving average while still in or near the Fear zone — this combination has historically flagged durable turns rather than short-lived bounces. Conversely, breadth crossing below its MA while elevated can warn of distribution before the index itself rolls over. Cross-referencing breadth across multiple indices (e.g., S&P 500 vs. Nasdaq 100) helps identify whether market strength is broad-based or concentrated in a handful of names.

Credit
Original breadth data implementation by Esti0000. This version adds the breadth moving average, crossover detection, alert conditions, and visual enhancements. Published under the same Mozilla Public License 2.0.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original: © Esti0000 | Enhanced with Breadth MA by Vector Digital LP

//@version=6
indicator("Index Breadth % Above Key Moving Averages", shorttitle = '% Breadth', overlay = false)

// ─────────────────────────────────────────────
// USER INPUTS
// ─────────────────────────────────────────────

market = input.string(defval = "SP500", title = "Select Market",
     options = ["Overall", "SP500", "DJI", "Nasdaq", "Nasdaq100", "Russel2000", "Russel3000",
     "SP500 Financials", "SP500 Materials", "SP500 Energy", "SP500 Staples", "SP500 Discretionary",
     "SP500 Industrials", "SP500 Real Estate", "SP500 Utilities", "SP500 Technologies", "SP500 Heath Care"],
     group = '① Select Market')

dma = input.string(defval = "200", title = "Select DMA",
     options = ["20", "50", "100", "150", "200"],
     group = '② Select Moving Average')

greed = input.int(defval = 80, title = 'Greed Level', minval = 50, maxval = 99,  group = '③ Greed & Fear Zones')
fear  = input.int(defval = 20, title = 'Fear Level',  minval = 1,  maxval = 49,  group = '③ Greed & Fear Zones')

// ─────────────────────────────────────────────
// BREADTH MA INPUTS
// ─────────────────────────────────────────────

show_ma       = input.bool(defval = true,   title = "Show Breadth MA",         group = '④ Breadth Moving Average')
ma_type       = input.string(defval = "EMA", title = "MA Type",
     options = ["SMA", "EMA", "WMA", "HMA"],                                   group = '④ Breadth Moving Average')
ma_length     = input.int(defval = 20,       title = "MA Length", minval = 2,   group = '④ Breadth Moving Average')
show_ma_cross = input.bool(defval = true,   title = "Highlight MA Crossovers", group = '④ Breadth Moving Average')

// ─────────────────────────────────────────────
// TICKER SELECTION
// ─────────────────────────────────────────────

ticker =
     ("Overall" == market)             ? ("200" == dma) ? "MMTH" : ("150" == dma) ? "MMOF" : ("100" == dma) ? "MMOH" : ("50" == dma) ? "MMFI" : "MMTW" :
     ("SP500" == market)               ? ("200" == dma) ? "S5TH" : ("150" == dma) ? "S5OF" : ("100" == dma) ? "S5OH" : ("50" == dma) ? "S5FI" : "S5TW" :
     ("DJI" == market)                 ? ("200" == dma) ? "DITH" : ("150" == dma) ? "DIOF" : ("100" == dma) ? "DIOH" : ("50" == dma) ? "DIFI" : "DITW" :
     ("Nasdaq" == market)              ? ("200" == dma) ? "NCTH" : ("150" == dma) ? "NCOF" : ("100" == dma) ? "NCOH" : ("50" == dma) ? "NCFI" : "NCTW" :
     ("Nasdaq100" == market)           ? ("200" == dma) ? "NDTH" : ("150" == dma) ? "NDOF" : ("100" == dma) ? "NDOH" : ("50" == dma) ? "NDFI" : "NDTW" :
     ("Russel2000" == market)          ? ("200" == dma) ? "R2TH" : ("150" == dma) ? "R2OF" : ("100" == dma) ? "R2OH" : ("50" == dma) ? "R2FI" : "R2TW" :
     ("Russel3000" == market)          ? ("200" == dma) ? "R3TH" : ("150" == dma) ? "R3OF" : ("100" == dma) ? "R3OH" : ("50" == dma) ? "R3FI" : "R3TW" :
     ("SP500 Financials" == market)    ? ("200" == dma) ? "SFTH" : ("150" == dma) ? "SFOF" : ("100" == dma) ? "SFOH" : ("50" == dma) ? "SFFI" : "SFTW" :
     ("SP500 Materials" == market)     ? ("200" == dma) ? "SBTH" : ("150" == dma) ? "SBOF" : ("100" == dma) ? "SBOH" : ("50" == dma) ? "SBFI" : "SBTW" :
     ("SP500 Energy" == market)        ? ("200" == dma) ? "SETH" : ("150" == dma) ? "SEOF" : ("100" == dma) ? "SEOH" : ("50" == dma) ? "SEFI" : "SETW" :
     ("SP500 Staples" == market)       ? ("200" == dma) ? "SPTH" : ("150" == dma) ? "SPOF" : ("100" == dma) ? "SPOH" : ("50" == dma) ? "SPFI" : "SPTW" :
     ("SP500 Discretionary" == market) ? ("200" == dma) ? "SYTH" : ("150" == dma) ? "SYOF" : ("100" == dma) ? "SYOH" : ("50" == dma) ? "SYFI" : "SYTW" :
     ("SP500 Industrials" == market)   ? ("200" == dma) ? "SITH" : ("150" == dma) ? "SIOF" : ("100" == dma) ? "SIOH" : ("50" == dma) ? "SIFI" : "SITW" :
     ("SP500 Real Estate" == market)   ? ("200" == dma) ? "SSTH" : ("150" == dma) ? "SSOF" : ("100" == dma) ? "SSOH" : ("50" == dma) ? "SSFI" : "SSTW" :
     ("SP500 Utilities" == market)     ? ("200" == dma) ? "SUTH" : ("150" == dma) ? "SUOF" : ("100" == dma) ? "SUOH" : ("50" == dma) ? "SUFI" : "SUTW" :
     ("SP500 Technologies" == market)  ? ("200" == dma) ? "SKTH" : ("150" == dma) ? "SKOF" : ("100" == dma) ? "SKOH" : ("50" == dma) ? "SKFI" : "SKTW" :
     ("SP500 Heath Care" == market)    ? ("200" == dma) ? "SVTH" : ("150" == dma) ? "SVOF" : ("100" == dma) ? "SVOH" : ("50" == dma) ? "SVFI" : "SVTW" :
     na

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────

breadth = request.security(ticker, timeframe.period, close)

// Breadth MA calculation
breadth_ma =
     ("SMA" == ma_type) ? ta.sma(breadth, ma_length) :
     ("EMA" == ma_type) ? ta.ema(breadth, ma_length) :
     ("WMA" == ma_type) ? ta.wma(breadth, ma_length) :
     ("HMA" == ma_type) ? ta.hma(breadth, ma_length) :
     na

// Crossover/under detection
cross_above = ta.crossover(breadth,  breadth_ma)
cross_below = ta.crossunder(breadth, breadth_ma)

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────

breadth_color = breadth >= greed ? color.new(color.red, 0) : breadth <= fear ? color.new(color.lime, 0) : color.new(color.blue, 0)

ma_color      = color.new(color.orange, 0)

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

// Reference lines
hline(50,    "Midline",     color = color.new(color.gray, 60),  linestyle = hline.style_dotted, linewidth = 1)
greed_line = hline(greed, "Greed Zone", color = color.new(color.red,  50),  linestyle = hline.style_dashed, linewidth = 1)
fear_line  = hline(fear,  "Fear Zone",  color = color.new(color.lime, 50),  linestyle = hline.style_dashed, linewidth = 1)

// Breadth line
p_breadth = plot(breadth, title = "Breadth %", color = breadth_color, linewidth = 2)

// MA line
p_ma = plot(show_ma ? breadth_ma : na, title = "Breadth MA", color = ma_color, linewidth = 1, style = plot.style_line)

// Greed/Fear fill zones
fear_fill  = plot(breadth < fear  ? fear  : na, display = display.none)
greed_fill = plot(breadth > greed ? greed : na, display = display.none)
fill(fear_fill,  p_breadth, color = color.new(color.lime, 80), title = "Fear Fill")
fill(greed_fill, p_breadth, color = color.new(color.red,  80), title = "Greed Fill")

// MA crossover markers
plotshape(show_ma and show_ma_cross and cross_above, title = "Cross Above MA",
     style = shape.triangleup,   location = location.belowbar,
     color = color.new(color.lime, 0), size = size.small)

plotshape(show_ma and show_ma_cross and cross_below, title = "Cross Below MA",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(color.red,  0), size = size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(cross_above, title = "Breadth crossed ABOVE MA", message = "Breadth momentum turning bullish — crossed above MA")
alertcondition(cross_below, title = "Breadth crossed BELOW MA", message = "Breadth momentum turning bearish — crossed below MA")
alertcondition(breadth < fear,  title = "Breadth in Fear Zone",  message = "Breadth has entered Fear Zone — potential accumulation area")
alertcondition(breadth > greed, title = "Breadth in Greed Zone", message = "Breadth has entered Greed Zone — potential distribution area")
````
