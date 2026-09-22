<!-- tradingview-pine-id: PUB;a25a0804b9a74b639ffbed5066d6d35e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# COT Index - Commercial Positioning (Weekly)

Source: https://www.tradingview.com/script/vouxNO8g-COT-Index-Commercial-Positioning-Weekly/

## Description

Overview

This indicator helps futures traders identify relative Commercial Trader positioning extremes using weekly Commitment of Traders (COT) data from the CFTC.

How It Works

The script calculates Commercial Net Position each week:
Commercial Net Position = Commercial Long - Commercial Short

It then normalizes this value against its own recent history over a configurable lookback period:
COT Index = 100 * (Net Position - Lowest Net Position) / (Highest Net Position - Lowest Net Position)

This shows where current Commercial positioning stands relative to its own recent range, rather than looking at absolute long/short numbers in isolation.

The script runs its core calculation on a fixed Weekly timeframe internally, regardless of the chart timeframe it's added to — so it stays useful on daily, 4H, 1H and intraday charts while still showing correct weekly positioning context. COT data is requested with lookahead disabled, so the indicator does not repaint.

Default Settings

Lookback period: 26 weeks
Upper threshold: 75
Lower threshold: 25
Neutral midpoint: 50
All adjustable in the script's Settings.

Interpretation

A high COT Index indicates Commercial Traders are positioned relatively bullish compared to their own recent history.
A low COT Index indicates Commercial Traders are positioned relatively bearish compared to their own recent history.
Readings above the upper threshold (default 75) may indicate elevated Commercial positioning.
Readings below the lower threshold (default 25) may indicate depressed Commercial positioning.
Typical Use Cases

Identify relative Commercial positioning extremes
Add COT context to futures swing trades
Compare positioning across different futures markets
Combine COT data with seasonality, price structure, trend and market regime analysis
Support commodity research and trade planning
Limitations

COT data is weekly and delayed: the report reflects positions as of Tuesday and is usually published the following Friday. This indicator is not designed for intraday timing and is not a standalone trading system. Extreme COT readings are not automatic reversal signals. Commercial positioning can remain elevated or depressed for extended periods, especially in strong trending markets. Past positioning patterns do not guarantee future price behavior.

Symbol Support

Designed for futures and continuous futures charts. Some micro contracts, CFDs, broker-specific symbols or otherwise unsupported markets may not return valid COT data.

Originality

COT data retrieval uses the public TradingView "LibraryCOT" community library. The Commercial Net Position calculation, the lookback-based normalization into a 0-100 COT Index, the configurable thresholds, and the visualization are original to this script.

For educational and research purposes only. This is not financial advice.

---

## Source Code

````pine
//@version=6
// COT Index - Commercial Positioning (Weekly)
// Uses TradingView LibraryCOT data source
// Formula: Commercial Net Position normalized over a selectable weekly lookback period

indicator(
     title          = "COT Index - Commercial Positioning (Weekly)",
     shorttitle     = "COT Index",
     format         = format.percent,
     precision      = 0,
     timeframe      = "W",
     timeframe_gaps = false
)

//────────────────────────────────────────────────────────────────────
// Imports
//────────────────────────────────────────────────────────────────────

import TradingView/LibraryCOT/2 as cot

//────────────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────────────

lookbackWeeks = input.int(
     defval  = 26,
     title   = "COT Index Lookback in Weeks",
     minval  = 1,
     tooltip = "Number of weekly COT data points used for the normalization."
)

upperLevel = input.float(
     defval = 75,
     title  = "Upper Extreme Level",
     minval = 0,
     maxval = 100
)

lowerLevel = input.float(
     defval = 25,
     title  = "Lower Extreme Level",
     minval = 0,
     maxval = 100
)

showBackground = input.bool(
     defval = true,
     title  = "Highlight Extremes"
)

showMiddleLine = input.bool(
     defval = true,
     title  = "Show 50 Line"
)

//────────────────────────────────────────────────────────────────────
// CFTC Code Handling
//────────────────────────────────────────────────────────────────────

rootSymbol = str.upper(syminfo.root)

f_getCftcCode() =>
    string autoCode = cot.convertRootToCOTCode("Auto")

    // Known fixes / special cases
    if rootSymbol == "HG"
        autoCode := "085692"
    else if rootSymbol == "LBR"
        autoCode := "058644"

    autoCode

cftcCode = f_getCftcCode()

//────────────────────────────────────────────────────────────────────
// COT Data Request
// Script itself runs on Weekly timeframe.
// Therefore all ta.lowest / ta.highest calculations are true weekly.
//────────────────────────────────────────────────────────────────────

f_requestCot(metricName, direction) =>
    string cotTicker = cot.COTTickerid(
         "Legacy",
         cftcCode,
         false,
         metricName,
         direction,
         "All"
    )

    float cotValue = request.security(
         cotTicker,
         "1D",
         close,
         gaps                  = barmerge.gaps_off,
         lookahead             = barmerge.lookahead_off,
         ignore_invalid_symbol = true
    )

    if barstate.islastconfirmedhistory and na(cotValue)
        runtime.error("No matching COT data found for this futures symbol.")

    cotValue

//────────────────────────────────────────────────────────────────────
// Commercial Net Position
//────────────────────────────────────────────────────────────────────

commercialLong  = f_requestCot("Commercial Positions", "Long")
commercialShort = f_requestCot("Commercial Positions", "Short")

commercialNet = commercialLong - commercialShort

//────────────────────────────────────────────────────────────────────
// Weekly COT Index Calculation
//────────────────────────────────────────────────────────────────────

lowestNet  = ta.lowest(commercialNet, lookbackWeeks)
highestNet = ta.highest(commercialNet, lookbackWeeks)

cotIndex =
     highestNet != lowestNet
     ? 100 * (commercialNet - lowestNet) / (highestNet - lowestNet)
     : na

//────────────────────────────────────────────────────────────────────
// Plotting
//────────────────────────────────────────────────────────────────────

plot(
     cotIndex,
     title     = "Commercials COT Index Weekly",
     color     = color.blue,
     linewidth = 2
)

hline(
     upperLevel,
     title     = "Upper Extreme",
     color     = color.new(color.lime, 0),
     linestyle = hline.style_solid
)

hline(
     lowerLevel,
     title     = "Lower Extreme",
     color     = color.new(color.red, 0),
     linestyle = hline.style_solid
)

hline(
     50,
     title     = "Middle Line",
     color     = showMiddleLine ? color.new(color.gray, 40) : color.new(color.gray, 100),
     linestyle = hline.style_dotted
)

bgcolor(
     showBackground and cotIndex >= upperLevel
     ? color.new(color.lime, 88)
     : na,
     title = "Bullish Commercial Extreme Background"
)

bgcolor(
     showBackground and cotIndex <= lowerLevel
     ? color.new(color.red, 88)
     : na,
     title = "Bearish Commercial Extreme Background"
)

//────────────────────────────────────────────────────────────────────
// Data Window Outputs
//────────────────────────────────────────────────────────────────────

plot(
     commercialNet,
     title   = "Commercial Net Position",
     display = display.data_window,
     color   = color.new(color.gray, 100)
)

plot(
     commercialLong,
     title   = "Commercial Long Positions",
     display = display.data_window,
     color   = color.new(color.gray, 100)
)

plot(
     commercialShort,
     title   = "Commercial Short Positions",
     display = display.data_window,
     color   = color.new(color.gray, 100)
)
````
