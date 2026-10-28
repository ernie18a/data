# COT Index Spec und Commercials

- url: https://www.tradingview.com/script/ORSlj4Wg/
- type: indicator
- pine_id: PUB;070cdaed102b4e8dad7e78a2e7eb497c
- version: 1.0

## Description

Zeigt die relative Veränderung zum Maximalwert der letzten 13 bzw. 26 Wochen der Commercials und der Spekulanten um die Marktstruktur und deren Veränderung zu verstehen

## Source Code

````pine
//@version=5
indicator("COT Index", shorttitle="COT Index", format=format.percent, precision=0)

int weeks26 = input.int(26, "Number of weeks Commercials (26)", minval=1)
int weeks13 = input.int(13, "Number of weeks Commercials (13)", minval=1)
int specsWeeks13 = input.int(13, "Number of weeks Specs (13)", minval=1)

bool hideCurrentWeek = input(true, "Hide the current week until market close")
bool markExtremes = input(true, "Mark long and short extremes")
bool showSpecs13 = input(true, "Show Specs Index 13 weeks")

import TradingView/LibraryCOT/2 as cot

// Function to fix some symbols.
var string Root_Symbol = syminfo.root
var string CFTC_Code_fixed = cot.convertRootToCOTCode("Auto")

if Root_Symbol == "HG"
    CFTC_Code_fixed := "085692"
else if Root_Symbol == "LBR"
    CFTC_Code_fixed := "058644"

// Function to request COT data for Futures only.
dataRequest(metricName, isLong) =>
    tickerId = cot.COTTickerid(
         "Legacy",
         CFTC_Code_fixed,
         false,
         metricName,
         isLong ? "Long" : "Short",
         "All"
     )
    value = request.security(tickerId, "1D", close, ignore_invalid_symbol = true)

    if barstate.islastconfirmedhistory and na(value)
        runtime.error("Could not find relevant COT data based on the current symbol.")

    value

// Function to calculate net positions.
// Net position = Long positions - Short positions
netPositions(metricName) =>
    longPositions = dataRequest(metricName, true)
    shortPositions = dataRequest(metricName, false)
    longPositions - shortPositions

// Function to calculate COT Index.
// Index = current net position relative to highest/lowest net position in lookback period.
calcIndex(metricName, lookback) =>
    netPos = netPositions(metricName)
    minNetPos = ta.lowest(netPos, lookback)
    maxNetPos = ta.highest(netPos, lookback)

    if maxNetPos != minNetPos
        100 * (netPos - minNetPos) / (maxNetPos - minNetPos)
    else
        na

// Commercials COT Index
commercialsIndex26 = calcIndex("Commercial Positions", weeks26)
commercialsIndex13 = calcIndex("Commercial Positions", weeks13)

// Specs / Noncommercials COT Index
specsIndex13 = calcIndex("Noncommercial Positions", specsWeeks13)

// Conditional logic based on user input
plotValueCommercials26 = hideCurrentWeek ? (timenow >= time_close ? commercialsIndex26 : na) : commercialsIndex26
plotValueCommercials13 = hideCurrentWeek ? (timenow >= time_close ? commercialsIndex13 : na) : commercialsIndex13
plotValueSpecs13 = hideCurrentWeek ? (timenow >= time_close ? specsIndex13 : na) : specsIndex13

// Plot the indices
plot(plotValueCommercials26, color=color.blue, style=plot.style_line, linewidth=2, title="Commercials Index 26 Weeks")
plot(plotValueCommercials13, color=color.gray, style=plot.style_line, linewidth=1, title="Commercials Index 13 Weeks")
plot(showSpecs13 ? plotValueSpecs13 : na, color=color.green, style=plot.style_line, linewidth=2, title="Specs Index 13 Weeks")

// Horizontal threshold lines
hline(75, "Upper Threshold", color=color.green, linestyle=hline.style_solid, linewidth=1)
hline(25, "Lower Threshold", color=color.red, linestyle=hline.style_solid, linewidth=1)

// Marking Commercials extremes with background color.
// Background is still based on the 26-week Commercials Index.
bgcolor(markExtremes and commercialsIndex26 >= 75 ? color.new(color.green, 90) : na)
bgcolor(markExtremes and commercialsIndex26 <= 25 ? color.new(color.red, 90) : na)
````
