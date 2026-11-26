# RTH Previous Day Levels | VAH VAL POC PDH PDL

- url: https://www.tradingview.com/script/nGp5ElyS-RTH-Previous-Day-Levels-VAH-VAL-POC-PDH-PDL/
- type: indicator
- pine_id: PUB;fa14b960cde34ed9a338b00f5aaa2677
- version: 1.0

## Description

# Previous Day RTH Levels | VAH, VAL, POC, PDH & PDL

This indicator automatically plots five key price levels from the previous trading day's Regular Trading Hours (RTH) session, helping traders identify important areas of support, resistance, liquidity, and potential price acceptance or rejection.

Designed primarily for Nasdaq futures (NQ/MNQ), the indicator uses the New York RTH session (9:30 AM–4:00 PM ET).

### Key Features
- **PDH (Previous Day High):** The highest price reached during the previous RTH session.
- **PDL (Previous Day Low):** The lowest price reached during the previous RTH session.
- **VAH (Value Area High):** The upper boundary of the calculated value area.
- **VAL (Value Area Low):** The lower boundary of the calculated value area.
- **POC (Point of Control):** The price level with the highest estimated trading volume.

### Customization
- Individually enable or disable all five levels.
- Adjust volume profile resolution.
- Customize the value area percentage (70% default).
- Automatically updates levels for each new trading session.

### Trading Applications
Useful for identifying liquidity sweeps, breakouts, reversals, support and resistance, and price acceptance or rejection around previous-session levels.

### Important Notes
Volume profile levels are calculated using an estimated distribution of candle volume across price ranges. Results may differ from TradingView's built-in Volume Profile tools.

Designed for intraday charts, particularly the 5-minute timeframe.

**Disclaimer:** This indicator is intended for educational and technical analysis purposes only. It does not generate buy or sell signals and should not be considered financial advice.

## Source Code

````pine

 //@version=6
indicator("RTH Previous Day Levels | VAH VAL POC PDH PDL", overlay=true)

// SETTINGS
rows = input.int(50, "Volume Profile Rows", minval=10, maxval=150)
vaPercent = input.float(70.0, "Value Area %", minval=1, maxval=100)

showPDH = input.bool(true, "Show PDH")
showPDL = input.bool(true, "Show PDL")
showVAH = input.bool(true, "Show VAH")
showVAL = input.bool(true, "Show VAL")
showPOC = input.bool(true, "Show POC")

// NEW YORK REGULAR TRADING HOURS
rth = "0930-1600:23456"
tz = "America/New_York"

inRTH = not na(time(timeframe.period, rth, tz))
dateKey = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

var int lastDate = na
newSession = inRTH and (na(lastDate) or dateKey != lastDate)

// STORE RTH CANDLE DATA
var array<float> highs = array.new_float()
var array<float> lows = array.new_float()
var array<float> vols = array.new_float()

// PREVIOUS SESSION LEVELS
var float pdh = na
var float pdl = na
var float vah = na
var float val = na
var float poc = na

if newSession
    // Calculate completed previous session
    if array.size(highs) > 0
        pdh := array.max(highs)
        pdl := array.min(lows)

        step = pdh > pdl ? (pdh - pdl) / rows : syminfo.mintick
        bins = array.new_float(rows, 0.0)

        // Distribute candle volume across price bins
        for i = 0 to array.size(highs) - 1
            bh = array.get(highs, i)
            bl = array.get(lows, i)
            bv = array.get(vols, i)

            startBin = int(math.max(0, math.min(rows - 1, math.floor((bl - pdl) / step))))
            endBin = int(math.max(0, math.min(rows - 1, math.floor((bh - pdl) / step))))

            if bh > bl
                for j = startBin to endBin
                    binLow = pdl + j * step
                    binHigh = binLow + step
                    overlap = math.max(0.0, math.min(bh, binHigh) - math.max(bl, binLow))
                    amount = bv * overlap / (bh - bl)
                    array.set(bins, j, array.get(bins, j) + amount)
            else
                array.set(bins, startBin, array.get(bins, startBin) + bv)

        // Find Point of Control
        totalVol = 0.0
        maxVol = -1.0
        pocIndex = 0

        for j = 0 to rows - 1
            v = array.get(bins, j)
            totalVol += v
            if v > maxVol
                maxVol := v
                pocIndex := j

        // Expand Value Area outward from POC
        left = pocIndex
        right = pocIndex
        covered = array.get(bins, pocIndex)
        target = totalVol * vaPercent / 100.0

        while covered < target and (left > 0 or right < rows - 1)
            upVol = right < rows - 1 ? array.get(bins, right + 1) : -1.0
            downVol = left > 0 ? array.get(bins, left - 1) : -1.0

            if upVol >= downVol and right < rows - 1
                right += 1
                covered += array.get(bins, right)
            else if left > 0
                left -= 1
                covered += array.get(bins, left)

        poc := math.round_to_mintick(pdl + (pocIndex + 0.5) * step)
        vah := math.round_to_mintick(pdl + (right + 1) * step)
        val := math.round_to_mintick(pdl + left * step)

    array.clear(highs)
    array.clear(lows)
    array.clear(vols)
    lastDate := dateKey

if inRTH
    array.push(highs, high)
    array.push(lows, low)
    array.push(vols, nz(volume, 0))

// PLOT PREVIOUS DAY LEVELS
plot(showPDH ? pdh : na, "PDH", color=color.lime, linewidth=2, style=plot.style_stepline)
plot(showPDL ? pdl : na, "PDL", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showVAH ? vah : na, "VAH", color=color.aqua, linewidth=2, style=plot.style_stepline)
plot(showVAL ? val : na, "VAL", color=color.blue, linewidth=2, style=plot.style_stepline)
plot(showPOC ? poc : na, "POC", color=color.yellow, linewidth=2, style=plot.style_stepline)
````
