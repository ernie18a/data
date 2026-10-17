# Mag7 + SPY Multi-Decade Seasonality

- url: https://www.tradingview.com/script/MeeGqeDH-Mag7-SPY-Multi-Decade-Seasonality/
- type: indicator
- pine_id: PUB;82525a801a844c9f80278324be85f026
- version: 1.0

## Description

📊 Overview

The Mag7 + SPY Seasonal Dashboard tracks historical monthly seasonality across the Magnificent 7 (AAPL, MSFT, AMZN, NVDA, GOOGL, META, TSLA) and the SPY benchmark.

It dynamically pulls monthly timeframe data (1M) for the current calendar month and calculates multi-period historical metrics over 10-Year and 20-Year lookback windows.

⚙️ Key Tracked Metrics:

- Avg Return (Avg): Average historical percentage return for the current calendar month.
- Win Rate (Pos%): Percentage of historical years where the current month closed positive.
- Volatility (StDev): Standard deviation of historical monthly returns for dispersion analysis.
- Institutional BIAS:
      🟢 BULLISH: Pos% (10Y) $\ge$ 70% AND Pos% (20Y) $\ge$ 60%.
      🔴 BEARISH: Pos% (10Y) $\le$ 40% OR Pos% (20Y) $\le$ 40%.
      ⚪ NEUTRAL: Mixed or balanced historical performance.

🎯 How to Use:

   - Apply the indicator overlay to any chart (the dashboard uses fixed 1M security requests, so chart timeframe won't alter the table).
   - Scan the BIAS column for strong cross-period alignment between the 10-year and 20-year windows.
   - Combine directional seasonal bias with technical market structure and intraday execution triggers.

## Source Code

````pine
//@version=6
indicator("Mag7 + SPY Seasonal Dashboard (Large)", overlay = true)

//#region ———————————————————— Inputs & Configuration
string GRP_PROP = "Dashboard Appearance"
string tablePositionInput = input.string("Bottom Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GRP_PROP)

// Institutional colors for quick bias recognition
color colorStrongBull = color.new(#089981, 20) 
color colorBull       = color.new(#089981, 55) 
color colorNeutral    = color.new(color.gray, 75)
color colorBear       = color.new(#F23745, 55) 
color colorStrongBear = color.new(#F23745, 20) 
//#endregion

//#region ———————————————————— Core Logic & Rendering Functions

type TickerMetrics
    string ticker
    float  avg10Y
    float  avg20Y
    float  pos10Y
    float  pos20Y
    float  stdev10Y
    float  stdev20Y

getMetricsForMonth(int targetMonth, int lookbackYears, int currentY) =>
    int minYear = currentY - lookbackYears + 1
    int nonNA = 0
    int posCount = 0
    float sum = 0.0
    
    array<float> values = array.new<float>()
    
    for i = 1 to 500
        if na(close[i])
            break
        int barY = year(time[i])
        int barM = month(time[i])
        
        if barM == targetMonth and barY >= minYear and barY <= currentY
            float prevClose = close[i+1]
            if not na(prevClose) and prevClose != 0
                float pct = 100.0 * (close[i] - prevClose) / math.abs(prevClose)
                sum := sum + pct
                nonNA := nonNA + 1
                if pct >= 0
                    posCount := posCount + 1
                array.push(values, pct)
                
    float finalAvg = nonNA == 0 ? 0.0 : sum / nonNA
    float finalPos = nonNA == 0 ? 0.0 : (100.0 * posCount / nonNA)
    float finalStDev = array.size(values) > 1 ? array.stdev(values, false) : 0.0
    [finalAvg, finalPos, finalStDev]

executeCalculations(string tickerSymbol, int m, int y) =>
    var TickerMetrics mData = TickerMetrics.new(tickerSymbol)
    [a10, p10, s10] = getMetricsForMonth(m, 10, y)
    [a20, p20, s20] = getMetricsForMonth(m, 20, y)
    mData.avg10Y := a10, mData.pos10Y := p10, mData.stdev10Y := s10
    mData.avg20Y := a20, mData.pos20Y := p20, mData.stdev20Y := s20
    [mData.avg10Y, mData.pos10Y, mData.stdev10Y, mData.avg20Y, mData.pos20Y, mData.stdev20Y]

getCellBg(posPct) =>
    color resultColor = colorNeutral
    if posPct >= 70.0      
        resultColor := colorStrongBull
    else if posPct >= 55.0 
        resultColor := colorBull
    else if posPct <= 35.0 
        resultColor := colorStrongBear
    else if posPct <= 45.0 
        resultColor := colorBear
    resultColor

renderRow(dashTable, r, tk, a10, p10, s10, a20, p20, s20) =>
    color rowBg = getCellBg(p10)
    
    // Bias Configuration
    string actionLabel = "⚪ NEUTRAL"
    color actionBg     = colorNeutral
    
    if p10 >= 70.0 and p20 >= 60.0
        actionLabel := "🟢 BULLISH"
        actionBg    := colorStrongBull
    else if p10 <= 40.0 or p20 <= 40.0
        actionLabel := "🔴 BEARISH"
        actionBg    := colorStrongBear

    table.cell(dashTable, 0, r, tk,                         bgcolor = color.new(color.gray, 60), text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 1, r, str.tostring(a10, "#.##") + "%",     bgcolor = rowBg, text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 2, r, str.tostring(p10, "#") + "%",        bgcolor = rowBg, text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 3, r, str.tostring(s10, "#.##"),           bgcolor = rowBg, text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 4, r, str.tostring(a20, "#.##") + "%",     bgcolor = getCellBg(p20), text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 5, r, str.tostring(p20, "#") + "%",        bgcolor = getCellBg(p20), text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 6, r, str.tostring(s20, "#.##"),           bgcolor = getCellBg(p20), text_color = chart.fg_color, text_size = size.large)
    table.cell(dashTable, 7, r, actionLabel,                         bgcolor = actionBg, text_color = color.white, text_size = size.large)
//#endregion

//#region ———————————————————— Execution & Data Gathering
// Fixed with timenow to prevent mismatches caused by timezones or active bar
int m = month(timenow) 
int y = year(timenow)  

[spyAvg10, spyPos10, spySd10, spyAvg20, spyPos20, spySd20] = request.security("SPY", "1M", executeCalculations("SPY", m, y))
[aaplAvg10, aaplPos10, aaplSd10, aaplAvg20, aaplPos20, aaplSd20] = request.security("AAPL", "1M", executeCalculations("AAPL", m, y))
[msftAvg10, msftPos10, msftSd10, msftAvg20, msftPos20, msftSd20] = request.security("MSFT", "1M", executeCalculations("MSFT", m, y))
[amznAvg10, amznPos10, amznSd10, amznAvg20, amznPos20, amznSd20] = request.security("AMZN", "1M", executeCalculations("AMZN", m, y))
[nvdaAvg10, nvdaPos10, nvdaSd10, nvdaAvg20, nvdaPos20, nvdaSd20] = request.security("NVDA", "1M", executeCalculations("NVDA", m, y))
[googlAvg10, googlPos10, googlSd10, googlAvg20, googlPos20, googlSd20] = request.security("GOOGL", "1M", executeCalculations("GOOGL", m, y))
[metaAvg10, metaPos10, metaSd10, metaAvg20, metaPos20, metaSd20] = request.security("META", "1M", executeCalculations("META", m, y))
[tslaAvg10, tslaPos10, tslaSd10, tslaAvg20, tslaPos20, tslaSd20] = request.security("TSLA", "1M", executeCalculations("TSLA", m, y))
//#endregion

//#region ———————————————————— Dashboard Rendering
if barstate.islast
    pos = switch tablePositionInput
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left

    table dash = table.new(pos, 8, 9, border_color = color.new(color.gray, 40), border_width = 2)
    
    color hBg = color.new(color.gray, 20)
    color hText = chart.fg_color
    
    table.cell(dash, 0, 0, "Ticker",       bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 1, 0, "Avg (10Y)",    bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 2, 0, "Pos% (10Y)",   bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 3, 0, "StDev (10Y)",  bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 4, 0, "Avg (20Y)",    bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 5, 0, "Pos% (20Y)",   bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 6, 0, "StDev (20Y)",  bgcolor = hBg, text_color = hText, text_size = size.large)
    table.cell(dash, 7, 0, "BIAS",         bgcolor = hBg, text_color = hText, text_size = size.large)

    renderRow(dash, 1, "SPY", spyAvg10, spyPos10, spySd10, spyAvg20, spyPos20, spySd20)
    renderRow(dash, 2, "AAPL", aaplAvg10, aaplPos10, aaplSd10, aaplAvg20, aaplPos20, aaplSd20)
    renderRow(dash, 3, "MSFT", msftAvg10, msftPos10, msftSd10, msftAvg20, msftPos20, msftSd20)
    renderRow(dash, 4, "AMZN", amznAvg10, amznPos10, amznSd10, amznAvg20, amznPos20, amznSd20)
    renderRow(dash, 5, "NVDA", nvdaAvg10, nvdaPos10, nvdaSd10, nvdaAvg20, nvdaPos20, nvdaSd20)
    renderRow(dash, 6, "GOOGL", googlAvg10, googlPos10, googlSd10, googlAvg20, googlPos20, googlSd20)
    renderRow(dash, 7, "META", metaAvg10, metaPos10, metaSd10, metaAvg20, metaPos20, metaSd20)
    renderRow(dash, 8, "TSLA", tslaAvg10, tslaPos10, tslaSd10, tslaAvg20, tslaPos20, tslaSd20)
//#endregion
````
