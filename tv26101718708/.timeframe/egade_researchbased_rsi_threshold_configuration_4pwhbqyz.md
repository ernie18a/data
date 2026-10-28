# EGADE Research-Based RSI Threshold Configuration

- url: https://www.tradingview.com/script/4pwHBqyZ-EGADE-Research-Based-RSI-Threshold-Configuration/
- type: indicator
- pine_id: PUB;ca63b92a09ff420dab563b40c953fa44
- version: 1.0

## Description

[b]EGADE Research-Based RSI Threshold Configuration[/b] is an empirical RSI decision-support indicator based on the findings of research by [url=https://orcid.org/0000-0001-5816-7290]Hatem Mabrouk[/url], [url=https://orcid.org/0000-0002-8686-6643]Federico Trigos[/url], and [url=https://orcid.org/0000-0002-7160-8836]Francisco Valderrey[/url], Tecnologico de Monterrey, EGADE Business School, Mexico

The underlying study systematically evaluated nine RSI threshold configurations across nine major cryptocurrencies and the S&P 500 using weekly RSI(14) data. The findings challenge the conventional assumption that the standard 30/70 configuration is universally optimal and identify asset-specific dominant threshold configurations based on win rate, geometric weekly return, and average holding period.

This indicator operationalizes those empirical findings directly within TradingView. For assets included in the study, it automatically displays the research-based RSI threshold configuration identified by the empirical analysis.

The indicator provides three display modes:

• [b]Research-Based:[/b] Displays the empirically identified threshold configuration for the selected asset.

• [b]Conventional 30/70:[/b] Displays the traditional RSI 30/70 configuration.

• [b]Compare Both:[/b] Displays the research-based and conventional configurations simultaneously for direct comparison.

The indicator uses weekly RSI(14) regardless of the chart timeframe and provides visual entry and exit zones, threshold-entry markers, alerts, and an information dashboard.

[b]Assets currently supported by the empirical research:[/b] BTC, ETH, ADA, AVAX, BNB, DOGE, SOL, TRX, XRP, and the S&P 500.

[b]Disclaimer:[/b] The findings and information presented through this indicator are intended exclusively for academic, research, educational, and decision-support purposes. Nothing contained in the underlying study or this indicator constitutes financial or investment advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Historical empirical performance does not guarantee future results. Users should conduct their own analysis and exercise independent judgment when making financial or investment decisions.

## Source Code

````pine
//@version=6
indicator("Research-Based RSI Threshold Configuration", shorttitle="RSI Research", overlay=false)

// ==========================================================
// RESEARCH-BASED RSI THRESHOLD CONFIGURATION INDICATOR
// Based on the empirical research of:
// Hatem Mabrouk, Federico Trigos, and Francisco Valderrey
//
// RSI period: 14
// Research timeframe: Weekly
// For research and educational purposes only.
// ==========================================================


// ----------------------------------------------------------
// 1. USER SETTINGS
// ----------------------------------------------------------

displayMode = input.string(
     "Compare Both",
     title="Display Mode",
     options=[
          "Compare Both",
          "Research-Based",
          "Conventional 30/70"
     ]
)


// ----------------------------------------------------------
// 2. WEEKLY RSI
// ----------------------------------------------------------

weeklyRSI = request.security(
     syminfo.tickerid,
     "W",
     ta.rsi(close, 14)
)

ticker = syminfo.ticker


// ----------------------------------------------------------
// 3. DEFAULT VALUES
// ----------------------------------------------------------

float buyThreshold = 30.0
float sellThreshold = 70.0

string researchConfiguration = "Not studied"
bool studiedAsset = false


// ----------------------------------------------------------
// 4. RESEARCH-BASED CONFIGURATIONS
// ----------------------------------------------------------

if ticker == "BTCUSD" or ticker == "BTCUSDT"
    buyThreshold := 30
    sellThreshold := 65
    researchConfiguration := "30 / 65"
    studiedAsset := true

else if ticker == "ETHUSD" or ticker == "ETHUSDT"
    buyThreshold := 35
    sellThreshold := 65
    researchConfiguration := "35 / 65"
    studiedAsset := true

else if ticker == "BNBUSD" or ticker == "BNBUSDT"
    buyThreshold := 35
    sellThreshold := 75
    researchConfiguration := "35 / 75"
    studiedAsset := true

else if ticker == "DOGEUSD" or ticker == "DOGEUSDT"
    buyThreshold := 35
    sellThreshold := 75
    researchConfiguration := "35 / 75"
    studiedAsset := true

else if ticker == "SOLUSD" or ticker == "SOLUSDT"
    buyThreshold := 30
    sellThreshold := 75
    researchConfiguration := "30 / 75"
    studiedAsset := true

else if ticker == "TRXUSD" or ticker == "TRXUSDT"
    buyThreshold := 35
    sellThreshold := 70
    researchConfiguration := "35 / 70"
    studiedAsset := true

else if ticker == "XRPUSD" or ticker == "XRPUSDT"
    buyThreshold := 35
    sellThreshold := 70
    researchConfiguration := "35 / 70"
    studiedAsset := true

else if ticker == "ADAUSD" or ticker == "ADAUSDT"
    buyThreshold := 30
    sellThreshold := 70
    researchConfiguration := "30 / 70 (tie)"
    studiedAsset := true

else if ticker == "AVAXUSD" or ticker == "AVAXUSDT"
    buyThreshold := 30
    sellThreshold := 65
    researchConfiguration := "30 / 65 (tie)"
    studiedAsset := true

else if ticker == "SPX"
    buyThreshold := 25
    sellThreshold := 70
    researchConfiguration := "25 / 70"
    studiedAsset := true


// ----------------------------------------------------------
// 5. DISPLAY MODE LOGIC
// ----------------------------------------------------------

bool showResearch =
     displayMode == "Compare Both" or
     displayMode == "Research-Based"

bool showConventional =
     displayMode == "Compare Both" or
     displayMode == "Conventional 30/70"


// ----------------------------------------------------------
// 6. CURRENT CONDITIONS
// ----------------------------------------------------------

bool researchEntryZone =
     studiedAsset and weeklyRSI <= buyThreshold

bool researchExitZone =
     studiedAsset and weeklyRSI >= sellThreshold

bool conventionalEntryZone =
     weeklyRSI <= 30

bool conventionalExitZone =
     weeklyRSI >= 70


// ----------------------------------------------------------
// 7. DASHBOARD STATUS
// ----------------------------------------------------------

string currentStatus = "Neutral"

if displayMode == "Research-Based" or displayMode == "Compare Both"

    if not studiedAsset
        currentStatus := "Asset not studied"

    else if researchEntryZone
        currentStatus := "Research Entry Zone"

    else if researchExitZone
        currentStatus := "Research Exit Zone"

else if displayMode == "Conventional 30/70"

    if conventionalEntryZone
        currentStatus := "Conventional Entry Zone"

    else if conventionalExitZone
        currentStatus := "Conventional Exit Zone"


// ----------------------------------------------------------
// 8. WEEKLY RSI LINE
// ----------------------------------------------------------

plot(
     weeklyRSI,
     title="Weekly RSI (14)",
     color=color.blue,
     linewidth=2
)


// ----------------------------------------------------------
// 9. RESEARCH THRESHOLDS
// ----------------------------------------------------------

plot(
     showResearch and studiedAsset ? buyThreshold : na,
     title="Research Buy Threshold",
     color=color.green,
     linewidth=2
)

plot(
     showResearch and studiedAsset ? sellThreshold : na,
     title="Research Sell Threshold",
     color=color.red,
     linewidth=2
)


// ----------------------------------------------------------
// 10. CONVENTIONAL 30/70 THRESHOLDS
//
// display.status_line is intentionally excluded so these
// values do not clutter the indicator's top status line.
// ----------------------------------------------------------

plot(
     showConventional ? 30 : na,
     title="Conventional Oversold 30",
     color=color.gray,
     linewidth=1,
     display=display.pane
)

plot(
     showConventional ? 70 : na,
     title="Conventional Overbought 70",
     color=color.gray,
     linewidth=1,
     display=display.pane
)


// ----------------------------------------------------------
// 11. RSI MIDPOINT
// ----------------------------------------------------------

hline(
     50,
     title="RSI Midpoint",
     color=color.gray,
     linestyle=hline.style_dotted
)


// ----------------------------------------------------------
// 12. BACKGROUND HIGHLIGHTING
// ----------------------------------------------------------

bool activeEntryZone =
     displayMode == "Conventional 30/70"
     ? conventionalEntryZone
     : researchEntryZone

bool activeExitZone =
     displayMode == "Conventional 30/70"
     ? conventionalExitZone
     : researchExitZone

bgcolor(
     activeEntryZone
     ? color.new(color.green, 88)
     : activeExitZone
     ? color.new(color.red, 88)
     : na
)


// ----------------------------------------------------------
// 13. RESEARCH SIGNAL MARKERS
// ----------------------------------------------------------

researchEntryMarker =
     studiedAsset and
     weeklyRSI <= buyThreshold and
     weeklyRSI[1] > buyThreshold

researchExitMarker =
     studiedAsset and
     weeklyRSI >= sellThreshold and
     weeklyRSI[1] < sellThreshold

plotshape(
     showResearch and researchEntryMarker,
     title="Research Entry",
     style=shape.triangleup,
     location=location.bottom,
     color=color.green,
     size=size.tiny,
     display=display.pane
)

plotshape(
     showResearch and researchExitMarker,
     title="Research Exit",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny,
     display=display.pane
)


// ----------------------------------------------------------
// 14. CONVENTIONAL SIGNAL MARKERS
// ----------------------------------------------------------

conventionalEntryMarker =
     weeklyRSI <= 30 and
     weeklyRSI[1] > 30

conventionalExitMarker =
     weeklyRSI >= 70 and
     weeklyRSI[1] < 70

plotshape(
     displayMode == "Conventional 30/70" and conventionalEntryMarker,
     title="Conventional Entry",
     style=shape.circle,
     location=location.bottom,
     color=color.gray,
     size=size.tiny,
     display=display.pane
)

plotshape(
     displayMode == "Conventional 30/70" and conventionalExitMarker,
     title="Conventional Exit",
     style=shape.circle,
     location=location.top,
     color=color.gray,
     size=size.tiny,
     display=display.pane
)


// ----------------------------------------------------------
// 15. COMPACT DASHBOARD
// ----------------------------------------------------------

var table dashboard = table.new(
     position.bottom_right,
     2,
     7,
     border_width=1
)

if barstate.islast

    table.cell(
         dashboard,
         0,
         0,
         "RSI RESEARCH",
         text_size=size.small
    )

    table.cell(
         dashboard,
         1,
         0,
         ticker,
         text_size=size.small
    )

    table.cell(
         dashboard,
         0,
         1,
         "Display Mode",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         1,
         displayMode,
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         0,
         2,
         "Research",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         2,
         researchConfiguration,
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         0,
         3,
         "Conventional",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         3,
         "30 / 70",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         0,
         4,
         "Weekly RSI (14)",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(weeklyRSI, "#.##"),
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         0,
         5,
         "Status",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         5,
         currentStatus,
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         0,
         6,
         "Data Timeframe",
         text_size=size.tiny
    )

    table.cell(
         dashboard,
         1,
         6,
         "Weekly",
         text_size=size.tiny
    )


// ----------------------------------------------------------
// 16. ALERTS
// ----------------------------------------------------------

alertcondition(
     researchEntryMarker,
     title="Research RSI Entry",
     message="Weekly RSI has entered the research-based entry zone."
)

alertcondition(
     researchExitMarker,
     title="Research RSI Exit",
     message="Weekly RSI has entered the research-based exit zone."
)

alertcondition(
     conventionalEntryMarker,
     title="Conventional RSI Entry",
     message="Weekly RSI has entered the conventional 30 RSI entry zone."
)

alertcondition(
     conventionalExitMarker,
     title="Conventional RSI Exit",
     message="Weekly RSI has entered the conventional 70 RSI exit zone."
)
````
