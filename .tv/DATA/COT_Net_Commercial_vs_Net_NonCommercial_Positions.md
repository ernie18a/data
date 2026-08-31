<!-- tradingview-pine-id: PUB;wlddKBI8MV78BZK2se6wZ5ndZD4BQ26e -->
<!-- tradingviewscripts-format: 1 -->
# COT Net Commercial vs Net Non-Commercial Positions

Source: https://www.tradingview.com/script/KZJQxDgq-COT-Net-Non-Commercials-vs-Commercials-Updated-MTF-Non-Repaint/

## Description

Hello there,
With this script, you can see CFTC COT Non Commercial and Commercial Positions together.
This way, you can analyze net values ​​greater than 0 and smaller, as well as very dense and very shallow positions of producers and speculators. 

Green - Non Commercials - Speculators 
Red    - Commercials - Producers 

This script is multi time-frame and non-repaint script. 
Data  pulled through Quandl.
And the latest version codes have been used.

As time goes by, I will try to make useful modifications to this scheme.

Regards.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Noldo

//@version=6

// Inputs

bool hideCurrentWeek = true

bool showCommercials = true
bool showLarge = true
indicator("COT Net Commercial vs Net Non-Commercial Positions", shorttitle="COT COMM vs NON COMM", format=format.percent, precision=0)

import TradingView/LibraryCOT/2 as cot

var string Root_Symbol = syminfo.root
var string CFTC_Code_fixed = cot.convertRootToCOTCode("Auto")
if Root_Symbol == "HG"
    CFTC_Code_fixed := "085692"
else if Root_Symbol == "LBR"
    CFTC_Code_fixed := "058644"

dataRequest(metricName, direction) =>
    tickerId = cot.COTTickerid('Legacy', CFTC_Code_fixed, false, metricName, direction, "All")
    value = request.security(tickerId, "1D", close, ignore_invalid_symbol = true)
    if barstate.islastconfirmedhistory and na(value)
        runtime.error("Could not find relevant COT data based on the current symbol.")
    value

// Calculates net long positions for commercials
netLongCommercialPositions() =>
    commercialLong = dataRequest("Commercial Positions", "Long")
    commercialShort = dataRequest("Commercial Positions", "Short")
    commercialLong - commercialShort

// Calculates net long positions for traders
netLongLargePositions() =>
    largeSpecsLong = dataRequest("Noncommercial Positions", "Long")
    largeSpecsShort = dataRequest("Noncommercial Positions", "Short")
    largeSpecsLong - largeSpecsShort
//
netCommercials = netLongCommercialPositions()
netLarge = netLongLargePositions()

//
// Plot based on user input
plotValueCommercials = hideCurrentWeek ? (timenow >= time_close ? netCommercials : na) : na
plotValueLarge = hideCurrentWeek ? (timenow >= time_close ? netLarge : na) : na

// Plot the index and horizontal lines
hline(0.0,color = color.black)
plot(plotValueCommercials, "Commercials", color=color.green, style=plot.style_steplinebr, linewidth=2)
plot(plotValueLarge, "Large Traders", color=color.red, style=plot.style_steplinebr, linewidth=2)
//
````
