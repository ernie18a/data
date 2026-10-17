# IB Formation Order Box (Padded)

- url: https://www.tradingview.com/script/B6zvhtCU-IB-Formation-Order-Box-Padded/
- type: indicator
- pine_id: PUB;3b49406ced414f75858b741328fee4f7
- version: 1.0

## Description

This script is an intraday quantitative tool designed to track institutional order flow during the New York Open (09:30 AM – 10:30 AM EST) by analyzing the chronological formation of the Initial Balance (IB).In auction market theory, the first hour of the New York session represents the period of highest volume and volatility, where institutional buyers and sellers aggressively fight to establish the boundaries of fair value for the day.

How to Read the Bottom-Right BoxAt 10:30 AM EST, the fixed box in the bottom right corner of your chart will immediately lock into one of two primary structural states:

1. 🟢 IB Low First (Bullish Structure)The Price Action: Between 09:30 AM and 10:30 AM EST, the absolute lowest price point occurred before the highest price point. (e.g., the low was made at 09:35 AM and the high at 10:15 AM).

The Market Context: This indicates that aggressive institutional buyers stepped in immediately at the New York open to absorb supply. Because they successfully defended this lower boundary, the IB Low is highly likely to hold as a structural floor for the remainder of the trading day.

2. 🔴 IB High First (Bearish Structure)The Price Action: Between 09:30 AM and 10:30 AM EST, the absolute highest price point occurred before the lowest price point. (e.g., the high was hit at 09:40 AM and the market sold off to make a lower low at 10:25 AM).

The Market Context: This shows that large-scale institutional supply or profit-taking slammed the market right at the opening bell. Because sellers capped the upside early, the IB High acts as a firm structural ceiling that is very difficult for retail traders to break above during the quiet afternoon session.

## Source Code

````pine
//@version=6
indicator("IB Formation Order Box (v6)", overlay=true)

// Input for Session Time (Regular Trading Hours First Hour in EST)
ibSession = input.session("0930-1030", "IB Session Time (EST)", tooltip="Enter in Exchange time, usually 0930-1030 for US Equities/Futures")
timezone  = input.string("America/New_York", "Timezone")

// Check if current bar is inside the IB session
inSession = not na(time(timeframe.isintraday ? timeframe.period : "1", ibSession, timezone))

// Correctly track the edge transitions using built-in change detection
isNewSession = inSession and not inSession[1]
isSessionEnd = not inSession and inSession[1]

// Internal tracking variables with strict v6 type casting
var float ibHigh = na
var float ibLow = na
var int highTime = na
var int lowTime = na

// Persistent box values
var string boxText = "Waiting for IB..."
var color boxColor = color.gray

// Reset values at the start of the first hour
if isNewSession
    ibHigh := high
    ibLow := low
    highTime := time
    lowTime := time
    boxText := "Tracking IB..."
    boxColor := color.gray

// Track highs/lows and their timestamps during the hour
if inSession
    if na(ibHigh) or high > ibHigh
        ibHigh := high
        highTime := time
    if na(ibLow) or low < ibLow
        ibLow := low
        lowTime := time

// Evaluate results at exactly 10:30 AM EST
if isSessionEnd
    if highTime < lowTime
        boxText := "IB High First\n(Bearish)"
        boxColor := color.red
    else if lowTime < highTime
        boxText := "IB Low First\n(Bullish)"
        boxColor := color.green
    else
        boxText := "IB High/Low Joint"
        boxColor := color.orange

// Create a 1x1 table pinned strictly to the bottom right corner
var table ibDisplayTable = table.new(position = position.bottom_right, columns = 1, rows = 1)

if barstate.islast
    table.cell(
         table_id = ibDisplayTable, 
         column = 0, 
         row = 0, 
         text = boxText, 
         bgcolor = boxColor, 
         text_color = color.white, 
         text_size = size.small,
         width = 16,
         height = 8
         )
````
