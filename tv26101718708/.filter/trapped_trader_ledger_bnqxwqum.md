# Trapped Trader Ledger

- url: https://www.tradingview.com/script/BNqxWqUm-Trapped-Trader-Ledger/
- type: indicator
- pine_id: PUB;5f91c08888384c3ca1a22548d0abd1d8
- version: 2.0

## Description

The primary purpose of the "Trapped Trader Ledger" is to provide a real-time, order-flow-based visualization of market liquidity and directional imbalance within a defined lookback window. By partitioning the price range into discrete volume bins, the indicator systematically categorizes buying and selling pressure, allowing you to instantly identify where significant volume has accumulated and where the market is currently experiencing "trapped" liquidity. It transforms raw volume data into a structured profile, effectively exposing the battle between supply and demand that often dictates future price action.

To use this tool effectively, monitor the dashboard on your desired timeframe while paying close attention to the Point of Control (POC), highlighted in yellow both on the chart and in the table. The table serves as your primary diagnostic tool: look for rows where the Ratio and Delta columns indicate high directional dominance, as these are the zones where trapped participants are most likely to react if price returns to their position. Use the widthScale input to adjust the visual histogram intensity to your preference, and ensure your lookback window is set to a length that captures the relevant market cycle you are currently trading.

The rationale behind this approach is rooted in the "Value Area" theory, which posits that price tends to gravitate toward areas of high volume accumulation. By calculating the Delta and Relative Volume for each specific price bin, the script filters out market noise and focuses on "high-conviction" levels—where the discrepancy between buyers and sellers is largest. This methodology assumes that when price leaves an area of high volume imbalance, the participants who were positioned on the losing side become "trapped," creating significant pressure for a potential reversal or liquidity-driven breakout when those levels are re-tested.

## Source Code

````pine
//@version=6
indicator("Trapped Trader Ledger (Corrected POC + Improved Table)", overlay=true, max_lines_count=500)

// === Inputs ===
int lookback = input.int(200, "Window Size")
int numBins = input.int(10, "Number of Bins")
float widthScale = input.float(100.0, "Width Multiplier")

// === Arrays ===
var float[] longLedger = array.new_float(numBins, 0.0)
var float[] shortLedger = array.new_float(numBins, 0.0)
var float[] barLong = array.new_float(0)
var float[] barShort = array.new_float(0)
var int[] barBin = array.new_int(0)
var line[] visualLines = array.new_line(numBins)

// === Volume Split ===
priceRange = math.max(high - low, syminfo.mintick)
askVol = volume * (close - low) / priceRange
bidVol = volume * (high - close) / priceRange

// === Rolling Window Price Range ===
minPrice = ta.lowest(low, lookback)
maxPrice = ta.highest(high, lookback)
priceSpan = math.max(maxPrice - minPrice, syminfo.mintick)
binSize = priceSpan / numBins

// === Correct Bin Assignment ===
float priceForBin = close
int binIdx = math.floor((priceForBin - minPrice) / binSize)
binIdx := binIdx < 0 ? 0 : binIdx > numBins - 1 ? numBins - 1 : binIdx

// === Update Ledgers ===
array.set(longLedger, binIdx, array.get(longLedger, binIdx) + askVol)
array.set(shortLedger, binIdx, array.get(shortLedger, binIdx) + bidVol)

array.push(barLong, askVol)
array.push(barShort, bidVol)
array.push(barBin, binIdx)

// === Remove Oldest ===
if array.size(barLong) > lookback
    int oldBin = array.shift(barBin)
    array.set(longLedger, oldBin, array.get(longLedger, oldBin) - array.shift(barLong))
    array.set(shortLedger, oldBin, array.get(shortLedger, oldBin) - array.shift(barShort))

// === On Last Bar ===
if barstate.islast
    // === Compute POC ===
    float maxVol = 0.0
    int pocBin = 0
    for i = 0 to numBins - 1
        float vol = array.get(longLedger, i) + array.get(shortLedger, i)
        if vol > maxVol
            maxVol := vol
            pocBin := i

    // === Global Totals for Ratios ===
    float globalTotalVol = 0.0
    float globalTotalDelta = 0.0
    for i = 0 to numBins - 1
        float b = array.get(longLedger, i)
        float s = array.get(shortLedger, i)
        globalTotalVol += (b + s)
        globalTotalDelta += math.abs(b - s)

    // === Table ===
    var table dataTable = table.new(position.top_right, 8, numBins + 1, bgcolor=color.new(color.black, 85), border_width=1)

    string[] headers = array.from("Price", "Vol", "Buy", "Sell", "Delta", "D.Ratio", "Imb%", "Rel.Vol")
    for j = 0 to 7
        table.cell(dataTable, j, 0, array.get(headers, j), text_color=color.white, bgcolor=color.new(color.black, 0))

    // === Draw Lines + Fill Table ===
    for i = numBins - 1 to 0
        float b = array.get(longLedger, i)
        float s = array.get(shortLedger, i)
        float total = b + s

        // Delete old line
        line old = array.get(visualLines, i)
        if not na(old)
            line.delete(old)

        // Draw new line
        if total > 0
            float levelPrice = minPrice + (i * binSize)
            float barWidth = (total / maxVol) * widthScale

            bool bullish = (b > s)
            color base = bullish ? color.green : color.red

            array.set(
                visualLines, i,
                line.new(
                    bar_index, levelPrice,
                    bar_index - int(barWidth), levelPrice,
                    color = (i == pocBin ? color.yellow : color.new(base, 40)),
                    width = (i == pocBin ? 6 : 4)
                )
            )

            // === Table Row ===
            int rowIdx = numBins - i

            float delta = b - s
            float absDelta = math.abs(delta)
            float imbalance = total > 0 ? absDelta / total : 0
            float relDeltaRatio = globalTotalDelta > 0 ? (absDelta / globalTotalDelta) * 100 : 0
            float relativeVol = globalTotalVol > 0 ? (total / globalTotalVol) * 100 : 0

            // === Background Highlighting ===
            color bg = color.new(color.black, 85)
            if close >= levelPrice and close < (levelPrice + binSize)
                bg := color.new(color.aqua, 70)
            else if i == pocBin
                bg := color.new(color.orange, 50)

            // === Fill Table Cells ===
            table.cell(dataTable, 0, rowIdx, str.tostring(levelPrice, format.mintick), text_color=color.white, bgcolor=bg)
            table.cell(dataTable, 1, rowIdx, str.tostring(total, format.volume), text_color=color.white, bgcolor=bg)
            table.cell(dataTable, 2, rowIdx, str.tostring(b, format.volume), text_color=color.green, bgcolor=bg)
            table.cell(dataTable, 3, rowIdx, str.tostring(s, format.volume), text_color=color.red, bgcolor=bg)
            table.cell(dataTable, 4, rowIdx, str.tostring(delta, format.volume), text_color=(delta >= 0 ? color.green : color.red), bgcolor=bg)
            table.cell(dataTable, 5, rowIdx, str.tostring(relDeltaRatio, "#.##") + "%", text_color=(delta >= 0 ? color.green : color.red), bgcolor=bg)
            table.cell(dataTable, 6, rowIdx, str.tostring(imbalance * 100, "#.##") + "%", text_color=(delta >= 0 ? color.green : color.red), bgcolor=bg)
            table.cell(dataTable, 7, rowIdx, str.tostring(relativeVol, "#.##") + "%", text_color=color.white, bgcolor=bg)
````
