# Multi-Length Displaced MA Indicator

- url: https://www.tradingview.com/script/gcPZFTFt-Multi-Length-Displaced-MA-Indicator/
- type: indicator
- pine_id: PUB;791e22a9eed046d5aaf4539e445b2ea0
- version: 1.0

## Description

Multi-Length Displaced MA Indicator

This script is a professional-grade trend and momentum visualization tool designed specifically for technical traders who need to balance immediate momentum with macro trend confirmation. By utilizing Displaced Moving Averages (DMA) alongside standard SMA, EMA, and VWMA indicators, this indicator provides a "forward-looking" buffer to filter out market noise and identify high-probability pivot zones.

Key Features:
Dynamic Logic Hierarchy: The script is organized into five distinct "roles," ranging from the hyper-responsive Momentum Trigger to the macro Trend Anchor.
Time-Shifted Analysis: Each of the five moving averages includes an independent Displacement (Offset) input. Shifting lines forward (positive displacement) helps visualize the "buffer" between price and the average, while shifting backward (negative displacement) can help identify historical lead/lag relationships.
Flexible MA Types: Users can toggle between Simple, Exponential, Volume Weighted, and Displaced (SMA-based) averages for each of the five slots.

Multi-Layer Strategy: The logic behind the default settings (though fully user-adjustable):
MA1=Momentum Trigger: 5 Length / 3 Offset; Identifies immediate momentum shifts; the "early warning" system for options traders.
MA2=Short-Term Trend: 9 Length / 5 Offset; The core trend line for fast-moving tech and growth stocks.
MA3=Institutional Pivot: 21 Length; Monitors the "mean reversion" zone where institutions typically defend positions.
MA4=Decision Line: 50 Length; Psychological "bull/bear" threshold for intermediate-term swings.
MA5=Trend Anchor: 200 Length; The ultimate macro trend line; determines the overall market bias.

How to Use:
Crossovers: Watch for the Momentum Trigger (MA 1) to cross the Short-Term Trend (MA 2) for entry and exit signals.
Support/Resistance: Use the Institutional Pivot (MA 3) and Decision Line (MA 4) as areas to add to winning positions or set stop-losses.
Noise Filtering: Use the Displacement feature on MA 1 to ensure a breakout is sustainable before committing capital to short-dated options.

Note: This indicator is optimized for high-liquidity assets (Indices and Tech) and provides the visual clarity needed to manage complex options portfolios with multiple expiration dates.

Script by // © TylerisTrading

## Source Code

````pine
//@version=6
// © TylerisTrading
indicator("Multi-Length Displaced MA Indicator", overlay=true)

// --- Types and Inputs ---
enum MaType
    SMA  = "Simple"
    EMA  = "Exponential"
    DMA  = "Displaced (SMA)"
    VWMA = "Volume Weighted"

// Function to calculate the selected MA type
get_ma(source, length, type) =>
    switch type
        MaType.SMA  => ta.sma(source, length)
        MaType.EMA  => ta.ema(source, length)
        MaType.DMA  => ta.sma(source, length) // Base calculation for DMA
        MaType.VWMA => ta.vwma(source, length)
        => na

// --- Input Groups ---
// MA 1
show1   = input.bool(true, "Momentum Trigger", group="MA 1")
len1    = input.int(5, "Length 1", minval=1, group="MA 1")
type1   = input.enum(MaType.DMA, "Type 1", group="MA 1")
off1    = input.int(3, "Displacement 1", group="MA 1") // Added offset
col1    = input.color(color.rgb(0, 221, 255), "Color 1", group="MA 1")

// MA 2
show2   = input.bool(true, "Short-Term Trend", group="MA 2")
len2    = input.int(9, "Length 2", minval=1, group="MA 2")
type2   = input.enum(MaType.EMA, "Type 2", group="MA 2")
off2    = input.int(0, "Displacement 2", group="MA 2") // Added offset
col2    = input.color(color.rgb(246, 221, 0), "Color 2", group="MA 2")

// MA 3
show3   = input.bool(false, "Institutional Pivot", group="MA 3")
len3    = input.int(21, "Length 3", minval=1, group="MA 3")
type3   = input.enum(MaType.DMA, "Type 3", group="MA 3")
off3    = input.int(5, "Displacement 3", group="MA 3") // Added offset (default 5 for DMA)
col3    = input.color(color.red, "Color 3", group="MA 3")

// MA 4
show4   = input.bool(false, "Decision Line", group="MA 4")
len4    = input.int(50, "Length 4", minval=1, group="MA 4")
type4   = input.enum(MaType.SMA, "Type 4", group="MA 4")
off4    = input.int(0, "Displacement 4", group="MA 4") // Added offset
col4    = input.color(color.purple, "Color 4", group="MA 4")

// MA 5
show5   = input.bool(false, "Trend Anchor", group="MA 5")
len5    = input.int(200, "Length 5", minval=1, group="MA 5")
type5   = input.enum(MaType.DMA, "Type 5", group="MA 5")
off5    = input.int(0, "Displacement 5", group="MA 5") // Added offset
col5    = input.color(color.white, "Color 5", group="MA 5")

// --- Calculations and Plotting ---
// The 'offset' parameter in plot() handles the displacement visual
plot(show1 ? get_ma(close, len1, type1) : na, "MA 1", color=col1, linewidth=2, offset=off1)
plot(show2 ? get_ma(close, len2, type2) : na, "MA 2", color=col2, linewidth=2, offset=off2)
plot(show3 ? get_ma(close, len3, type3) : na, "MA 3", color=col3, linewidth=2, offset=off3)
plot(show4 ? get_ma(close, len4, type4) : na, "MA 4", color=col4, linewidth=2, offset=off4)
plot(show5 ? get_ma(close, len5, type5) : na, "MA 5", color=col5, linewidth=2, offset=off5)
````
