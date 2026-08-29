<!-- tradingview-pine-id: PUB;8162c3639e5e46c7a68b72580cafc29d -->
<!-- tradingviewscripts-format: 1 -->
# Volume Candles by SPPATLE

Source: https://www.tradingview.com/script/tZtTBSGA-Volume-Candles-by-SPPATLE/

## Description

volume candle hilighter by SPPATLE to filter high volume candles

---

## Source Code

````pine

// @author SPPATLE
// © spp2788

//@version=6
indicator('Volume Candles by SPPATLE', overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Input Parameters ---
rvolLen = input.int(100, title = 'RVOL Average Period', minval = 1)
rvolThreshold = input.float(1.5, title = 'RVOL Threshold', step = 0.1)

// Color Options
c_bull = input.color(color.green, title = 'Bullish Candle Color')
c_bear = input.color(color.red, title = 'Bearish Candle Color')
c_white = color.white

// --- RVOL Calculation ---
volSMA = ta.sma(volume, rvolLen)
rvol = volSMA > 0 ? volume / volSMA : 0.0

// --- Logic ---
isBull = close >= open
isHighRvol = rvol >= rvolThreshold

// Assign bar colors
candleColor = isHighRvol ? c_white : isBull ? c_bull : c_bear
barcolor(candleColor)

// --- Dynamic Height Highlight Scaled with RVOL ---
candleRange = math.max(high - low, close * 0.005)
topPrice = high + candleRange * (rvol / 2)
bottomPrice = low - candleRange * (rvol / 2)

if isHighRvol
    line.new(bar_index, topPrice, bar_index, bottomPrice, color = color.new(color.white, 75), width = 12)
    label.new(bar_index, topPrice, text = str.tostring(rvol, '#.##'), yloc = yloc.price, color = color.white, textcolor = color.black, style = label.style_label_down, size = size.small)
````
