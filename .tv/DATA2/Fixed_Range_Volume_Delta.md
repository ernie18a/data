<!-- tradingview-pine-id: PUB;40a646e3429340af86cb425a3d1db21a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fixed Range Volume Delta

Source: https://www.tradingview.com/script/qLCgJTYm-Fixed-Range-Volume-Delta-By-Sarojh/

## Description

**Overview**

The **Fixed Range Volume Delta** indicator isolates any specific historical or active trading session and renders native intrabar Volume Delta candlesticks exclusively inside that window. In addition to displaying standard candle-by-candle delta action (open, high, low, close delta spreads), the indicator computes the total aggressive buy volume, aggressive sell volume, cumulative net delta, and overall traded volume across the selected range, summarized in an on-screen metrics dashboard.

---

**Key Features**

* **Custom Range Selection:** Define exact start and end timestamps via the calendar picker, or toggle **"Extend to Current Bar"** to track an accumulation or distribution structure up to the live candle.
* **Native Delta Candlesticks:** Uses `ta.requestVolumeDelta()` to construct precise intrabar delta candles (`openVolume`, `maxVolume`, `minVolume`, `lastVolume`) with visible wicks, matching native order-flow delta charts without distorting the pane's vertical price scale.
* **Separated Buy vs. Sell Volume Accounting:** Deconstructs net delta and gross volume to calculate true aggressive market buys ($V_{\text{buy}}$) and aggressive market sells ($V_{\text{sell}}$) across the entire selected range.
* **Range Metrics Dashboard:** A clean, auto-scaling table positioned in the top-right corner displaying:
* **Total Volume:** Gross volume transacted inside the window.
* **Buy Volume:** Aggressive market buy volume.
* **Sell Volume:** Aggressive market sell volume.
* **Net Delta:** Cumulative net difference ($V_{\text{buy}} - V_{\text{sell}}$) with dynamic teal/red status coloring.

* **Multi-Timeframe Granularity:** Select between standard time-based lower-timeframe aggregation or 1-tick aggregation (requires supported TradingView plans).

---

**How to Use & Read the Indicator**

1. **Spotting Absorption & Hidden Divergences:**
* **Bullish Absorption:** When price holds sideways or forms a consolidation base while Cumulative Net Delta is heavily negative, it signals that aggressive market sellers are being absorbed by passive institutional limit buy orders (bids).
* **Bearish Absorption:** When price consolidates near resistance while Cumulative Net Delta is heavily positive without making upward progress, it indicates that aggressive market buyers are being absorbed into passive sell orders (asks).

2. **Measuring Phase Turnover:** Isolate consolidation zones, Wyckoff accumulation/distribution ranges, or breakout retests to assess whether buyers or sellers were dominant during the sideways build-up.
3. **Session Anchoring:** Measure specific trading sessions (e.g., London Open to NY Close, or weekend crypto ranges) to gauge net inventory positioning leading into the next expansion.

---

**Settings**

* **Start Date & Time:** Sets the anchor point where accumulation and visual candle plotting begin.
* **Extend to Current Bar:** When enabled, ignores the fixed End Date and dynamically calculates volume up to the most recent bar.
* **End Date & Time:** Sets the cut-off timestamp for fixed historical ranges.
* **Data Aggregation:** Switch between **Time** (standard lower-timeframe approximation) and **1 tick** (exact tick-by-tick order execution).
* **Use Custom Timeframe:** Manually specify the lower timeframe resolution scanned for the delta calculation.

---

## Source Code

````pine
//@version=6
indicator("Fixed Range Volume Delta", format = format.volume)

import TradingView/ta/12

// --- Range Selection ---
grp_range = "Range Selection"
startTime = input.time(timestamp("2026-06-01 00:00"), "Start Date & Time", group = grp_range)
useCurrentBar = input.bool(false, "Extend to Current Bar (Ignore End Date)", group = grp_range)
endTime   = input.time(timestamp("2026-08-18 00:00"), "End Date & Time", group = grp_range, active = not useCurrentBar)

// --- Delta Calculation Settings ---
grp_delta = "Delta Calculation"
dataAggregationInput = input.string("Time", "Data aggregation", options = ["Time", "1 tick"], group = grp_delta)
useTicks = dataAggregationInput == "1 tick"

useCustomTimeframeInput = input.bool(false, "Use custom timeframe", group = grp_delta, active = not useTicks)
lowerTimeframeInput = input.timeframe("1", "Timeframe", group = grp_delta, active = useCustomTimeframeInput and not useTicks)

var lowerTimeframe = switch
    useTicks                => "1T"
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

// --- Delta & Volume Retrieval ---
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe)

delta    = nz(lastVolume)
totalVol = nz(volume)

buyVol   = math.max(0.0, (totalVol + delta) / 2.0)
sellVol  = math.max(0.0, (totalVol - delta) / 2.0)

// --- Range Boundary Logic & Accumulation ---
effectiveEndTime = useCurrentBar ? time_close : endTime
inRange = (time >= startTime) and (time <= effectiveEndTime)
isFirstRangeBar = inRange and not inRange[1]

var float cumBuy   = 0.0
var float cumSell  = 0.0
var float cumDelta = 0.0
var float cumTotal = 0.0

if isFirstRangeBar
    cumBuy   := 0.0
    cumSell  := 0.0
    cumDelta := 0.0
    cumTotal := 0.0

if inRange
    cumBuy   += buyVol
    cumSell  += sellVol
    cumDelta += delta
    cumTotal += totalVol

// --- Visual Plotting (Matches Volume Delta Pane Exactly) ---
candleColor = lastVolume > 0 ? color.teal : color.red

// Plot identical candlestick delta only within selected range
plotcandle(inRange ? openVolume : na, 
           inRange ? maxVolume : na, 
           inRange ? minVolume : na, 
           inRange ? lastVolume : na, 
           "Volume Delta", 
           color = candleColor, 
           bordercolor = candleColor, 
           wickcolor = candleColor)

hline(0, "Baseline (Zero)", color = color.gray, linestyle = hline.style_solid)
bgcolor(inRange ? color.new(color.blue, 92) : na, title = "Active Range Highlight")

// --- Summary Metric Box ---
var table metricTable = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 20), border_color = color.gray, border_width = 1)

f_formatVol(float val) =>
    math.abs(val) >= 1e6 ? str.tostring(val / 1e6, "#.##") + "M" :
     math.abs(val) >= 1e3 ? str.tostring(val / 1e3, "#.##") + "K" :
     str.tostring(val, "#.##")

if barstate.islast
    table.cell(metricTable, 0, 0, "Total Vol", text_color = color.white, text_size = size.small)
    table.cell(metricTable, 1, 0, f_formatVol(cumTotal), text_color = color.yellow, text_size = size.small)

    table.cell(metricTable, 0, 1, "Buy Vol", text_color = color.white, text_size = size.small)
    table.cell(metricTable, 1, 1, f_formatVol(cumBuy), text_color = color.teal, text_size = size.small)

    table.cell(metricTable, 0, 2, "Sell Vol", text_color = color.white, text_size = size.small)
    table.cell(metricTable, 1, 2, f_formatVol(cumSell), text_color = color.red, text_size = size.small)

    table.cell(metricTable, 0, 3, "Net Delta", text_color = color.white, text_size = size.small)
    table.cell(metricTable, 1, 3, f_formatVol(cumDelta), text_color = cumDelta >= 0 ? color.teal : color.red, text_size = size.small)
````
