# ADK CVD

- url: https://www.tradingview.com/script/mxwilY1g-ADK-CVD/
- type: indicator
- pine_id: PUB;2fa0409ee2174c0989377e78d9b1e5c7
- version: 1.0

## Description

[b]"Cumulative Volume Delta & Volume OWI By ADK" aka "ADK CVD"[/b]
A powerful dual-purpose volume analysis tool that combines Cumulative Volume Delta (CVD) and Volume Order Wave Indicator (VOWI) in one script.
What does this indicator do?

[b]1. Cumulative Volume Delta (CVD)[/b]

Shows the net buying vs selling pressure using true volume delta calculation.

[list]
[*]Blue candles = Buying dominance
[*]Red candles = Selling dominance
[/list]
Built using TradingView’s official ta.requestVolumeDelta() for higher accuracy
Supports both Time-based and 1 Tick aggregation (tick mode available on Expert plans)
Fully customizable Anchor Period and lower timeframe settings

[b]2. Volume OWI (Order Wave Indicator)[/b]

[b]Visualizes Buy Volume vs Sell Volume as colored columns:[/b]

[list]
[*]Green columns = Buy Volume
[*]Red columns = Sell Volume (Total Volume)
[/list]
Helps traders quickly see which side is more aggressive on each bar.

[b]Key Features[/b]

[list]
[*]Toggle CVD and VOWI independently
[*]Advanced CVD settings (Anchor Period, Data Aggregation, Custom Lower Timeframe)
[*]Optional US Market Hours time filter for VOWI
[*]Clean and optimized Pine Script v6 code
[*]Works on all symbols that provide volume data
[/list]

How to use

Use CVD to track institutional buying/selling pressure and potential divergences with price.
Use VOWI to see real-time order flow strength (Buy vs Sell volume).
Best used on liquid instruments (stocks, futures, crypto with good volume).

[b]Recommended Settings:[/b]

[list=1]
[*]CVD Anchor: 1D or Session
[*]Data Aggregation: Time (or 1 Tick if available)
[*]VOWI: Enable Time Filter for US stocks/futures
[/list]


[b]Disclaimer[/b]

[i]This indicator is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Trading involves substantial risk of loss and is not suitable for every investor. Always do your own research and consult a qualified financial advisor before making any trading decisions. The authors and publishers of this script accept no liability for any losses incurred from its use.

Developed by ADK Team[/i]

## Source Code

````pine
//@ Made by ADK Team
//@version=6
indicator("Cumulative Volume Delta & Volume OWI By ADK", "CVD-VOWI By ADK", format = format.volume)

import TradingView/ta/12

// ==================== INPUTS ====================
showCVD  = input.bool(true,  "Show CVD", group = "CVD Settings")

anchorInput = input.timeframe("1D", "Anchor Period", group = "CVD Settings")

dataAggregationTooltip = "Defines how lower timeframe data is aggregated for the delta calculation. \"1 tick\" computes the delta on tick data and is available only on expert plans."
dataAggregationInput   = input.string("Time", "Data Aggregation", options = ["Time", "1 tick"], tooltip = dataAggregationTooltip, group = "CVD Settings")
useTicks               = dataAggregationInput == "1 tick"

lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
     + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(true, "Custom timeframe", tooltip = lowerTimeframeTooltip, active = not useTicks, group = "CVD Settings")
lowerTimeframeInput     = input.timeframe("", "Timeframe", active = useCustomTimeframeInput and not useTicks, group = "CVD Settings")

// ==================== CVD SECTION ====================
var lowerTimeframe = switch
    useTicks                  => "1T"
    useCustomTimeframeInput    => lowerTimeframeInput
    timeframe.isseconds        => "1S"
    timeframe.isintraday       => "1"
    timeframe.isdaily          => "5"
    => "60"

[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

// Color
col = lastVolume >= openVolume ? color.blue : color.red

// Always call plot functions in global scope
hline(0, "Zero", color = color.gray)

// Plot CVD only when enabled (use ternary with na)
plotcandle(
     showCVD ? openVolume  : na,
     showCVD ? maxVolume   : na,
     showCVD ? minVolume   : na,
     showCVD ? lastVolume  : na,
     "CVD",
     color      = col,
     bordercolor = col,
     wickcolor   = col)

// Runtime checks
var cumVol = 0.
cumVol += nz(volume)
deltaIsNa = na(openVolume) and na(maxVolume) and na(minVolume) and na(lastVolume)

if barstate.islast
    if cumVol == 0
        runtime.error("The data vendor doesn't provide volume data for this symbol.")
    if str.endswith(lowerTimeframe, "T") and deltaIsNa
        runtime.error("Not enough tick depth for the current anchor period. The available tick depth ends before reaching the start of the anchor period (" + anchorInput + "). Please shorten the 'Anchor period' input or switch the calculation base from '1 Tick' to 'Time' or higher custom timeframe.")

// ==================== VOWI SECTION ====================
showVOWI = input.bool(false,  "Show Vol-OWI", group = "VOWI Settings")
smaLength     = input.int(20, "SMA Length", group = "VOWI Settings")
useTimeFilter = input.bool(true, "Enable Time Filter", group = "VOWI Settings")
startHour     = input.int(9,  "Start Hour (ET)", group = "VOWI Settings")
startMinute   = input.int(45, "Start Minute (ET)", group = "VOWI Settings")
endHour       = input.int(16, "End Hour (ET)", group = "VOWI Settings")
endMinute     = input.int(15, "End Minute (ET)", group = "VOWI Settings")

// Volume calculations
buyVolume  = high == low ? 0.0 : volume * (close - low) / (high - low)
sellVolume = high == low ? 0.0 : volume * (high - close) / (high - low)

// Time filter
startTime      = timestamp("America/New_York", year, month, dayofmonth, startHour, startMinute)
endTime        = timestamp("America/New_York", year, month, dayofmonth, endHour, endMinute)
isUSMarketTime = time >= startTime and time <= endTime

// Plot volume columns (only when showVOWI is true)
plot(showVOWI ? volume     : na, "SELL V", color = color.red,   style = plot.style_columns)
plot(showVOWI ? buyVolume  : na, "BUY V",  color = color.green, style = plot.style_columns)
````
