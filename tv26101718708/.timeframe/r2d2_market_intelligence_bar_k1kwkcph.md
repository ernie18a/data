# R2D2 Market Intelligence Bar

- url: https://www.tradingview.com/script/K1KwKcph-R2D2-Market-Intelligence-Bar/
- type: indicator
- pine_id: PUB;01c862856c1540b2ab4e6debf8ca6388
- version: 2.0

## Description

[b]R2D2 Market Intelligence Bar: The Ultimate All-In-One Dashboard[/b]

Overview
The R2D2 Market Intelligence Bar is a comprehensive, customizable dashboard designed to give traders and investors an immediate, high-level read of an asset’s technical and fundamental health. Positioned neatly at the top right of your chart, this indicator eliminates the need to constantly switch tabs or clutter your screen with a dozen different sub-charts.

Whether you are scanning a watchlist for momentum setups or doing due diligence on a long-term investment, the R2D2 bar consolidates the most critical quantitative metrics into a single, color-coded heads-up display.

[b]Key Features & Metrics[/b]
The dashboard bridges the gap between technical price action and fundamental valuation. It includes:

1. The Performance Matrix (1W, 1M, 2M, 3M, 6M, 1Y, 2Y)
Instantly view the asset's rolling percentage returns across seven distinct timeframes. The background color of these cells acts as a visual heat map:

Light Green: Exceptional gains (+100% or more)

Lime Green: Standard positive returns

Bright Red: Standard negative returns

Dark Red: Severe drawdowns (-10% or worse)

[b]2. Risk & Volatility Management[/b]

ATR %: The Average True Range expressed as a percentage of the current price, showing how much the asset swings daily.

Volatility Status: Automatically categorizes current volatility as Low, Normal, or Elevated based on the ATR percentage.

TS (Trail Stop): A dynamically calculated trailing stop-loss level, derived directly from your custom ATR multiplier settings.

Volume (V %): Shows current volume momentum by comparing today's volume against the 20-day Simple Moving Average (SMA).

[b]3. Quantitative & Fundamental Health[/b]

SPX Beta: Measures the asset's 1-year volatility and correlation relative to a benchmark (default is the S&P 500 / SPY). A Beta over 1.0 means it is more volatile than the broader market.

Sharpe Ratio: Evaluates the 1-year annualized risk-adjusted return. The dashboard automatically grades the Sharpe ratio as Good, OK, or Poor.

PE Ratio: Trailing Twelve Months (TTM) Price-to-Earnings ratio.

Net Income Margin (NIM): Shows the fundamental profitability of the company.

Dividend Yield: The current TTM yield for income investors.

[b]Complete Customization[/b]
Every trader's strategy is different. The R2D2 Intelligence Bar features a robust Dashboard Visibility menu that allows you to toggle every single metric on or off.

Only care about technicals? Turn off the PE, Yield, and NIM. Want a cleaner screen on a smaller monitor? Drop the text size down to "Tiny" or hide the longer timeframes. The dashboard dynamically resizes itself so there are no empty, dead spaces. You can also adjust the core technical settings, including the ATR Length, the Trail Stop Multiplier, and the benchmark ticker used for the Beta calculation.

[b]Important Notes for Users[/b]
Asset Limitations: Fundamental metrics (PE Ratio, Net Income Margin, and Dividend Yield) utilize TradingView's request.financial() functions. These metrics will only populate when viewing Equities (Stocks). If you apply this indicator to Crypto, Forex, or Futures, those specific cells will gracefully display as "N/A" or "0%" while the technical and performance metrics continue to calculate perfectly.

Sharpe Ratio: The Sharpe ratio calculated in this script is a simplified 1-year annualized metric assuming a 0% risk-free rate, designed specifically for quick relative comparison between equities.

[b]How to Use[/b]
Add the indicator to your chart.

Double-click the R2D2 bar (or open the indicator settings gear icon).

Under Technical Settings, define your risk tolerance by adjusting the ATR length and Trail Stop multiplier.

Under Dashboard Visibility, toggle the metrics to fit your exact trading style.
[i]
Trade smarter, not harder. Let R2D2 do the scanning.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © R2D2_4Life

//@version=6
indicator("R2D2 Market Intelligence Bar V2.5", overlay=true)

// ==============================================================================
// INPUTS
// ==============================================================================
grpTech = "Technical Settings"
atrLen = input.int(14, title="ATR Length", group=grpTech)
tsMult = input.float(2.0, title="Trail Stop Multiplier", group=grpTech)
benchSym = input.symbol("SPY", title="Beta Benchmark", group=grpTech)

grpMarket = "Market Data Type"
marketSchedule = input.string("24/7 (Crypto)", title="Market Schedule", options=["24/7 (Crypto)", "24/5 (Equities)"], group=grpMarket)

grpVis = "Dashboard Visibility"
txtSizeStr = input.string("Small", title="Text Size", options=["Tiny", "Small"], group=grpVis)
txtSize = txtSizeStr == "Tiny" ? size.tiny : size.small

showPE = input.bool(true, title="Show PE", group=grpVis)
show1W = input.bool(true, title="Show 1W", group=grpVis)
show1M = input.bool(true, title="Show 1M", group=grpVis)
show2M = input.bool(true, title="Show 2M", group=grpVis)
show3M = input.bool(true, title="Show 3M", group=grpVis)
show6M = input.bool(true, title="Show 6M", group=grpVis)
show1Y = input.bool(true, title="Show 1Y", group=grpVis)
show2Y = input.bool(true, title="Show 2Y", group=grpVis)
showATR = input.bool(true, title="Show ATR", group=grpVis)
showTS = input.bool(true, title="Show Trail Stop", group=grpVis)
showVol = input.bool(true, title="Show Volume %", group=grpVis)
showYield = input.bool(true, title="Show Div Yield", group=grpVis)
showNIM = input.bool(true, title="Show NIM", group=grpVis)
showBeta = input.bool(true, title="Show SPX Beta", group=grpVis)
showVolLbl = input.bool(true, title="Show Volatility Status", group=grpVis)
showSharpe = input.bool(true, title="Show Sharpe", group=grpVis)

isCrypto = marketSchedule == "24/7 (Crypto)"

// ==============================================================================
// DAILY CALCULATIONS - Optimized (No nested security inside function)
// ==============================================================================
dailyCalc() =>
    anchor = close[1]
    
    p1W = close[8]  > 0 ? (anchor - close[8])  / close[8]  * 100 : 0.0
    p1M = close[31] > 0 ? (anchor - close[31]) / close[31] * 100 : 0.0
    p2M = close[61] > 0 ? (anchor - close[61]) / close[61] * 100 : 0.0
    p3M = close[91] > 0 ? (anchor - close[91]) / close[91] * 100 : 0.0
    p6M = close[181]> 0 ? (anchor - close[181])/ close[181]* 100 : 0.0
    p1Y = close[366]> 0 ? (anchor - close[366])/ close[366]* 100 : 0.0
    p2Y = close[731]> 0 ? (anchor - close[731])/ close[731]* 100 : 0.0
    
    ret = ta.roc(close, 1) / 100
    lenSharpe = isCrypto ? 365 : 252
    smaRet = ta.sma(ret, lenSharpe)
    stdRet = ta.stdev(ret, lenSharpe)
    shp = stdRet > 0 ? (smaRet / stdRet) * math.sqrt(lenSharpe) : na
    
    dAtr = ta.atr(atrLen)
    dVol = volume
    dVolSma = ta.sma(volume, 20)
    
    stockRet = ta.roc(close, 1)
    
    [p1W, p1M, p2M, p3M, p6M, p1Y, p2Y, shp, dAtr, dVol, dVolSma, stockRet]

[d_p1W, d_p1M, d_p2M, d_p3M, d_p6M, d_p1Y, d_p2Y, d_shp, d_atr, d_vol, d_volSma, d_stockRet] = 
     request.security(syminfo.tickerid, "D", dailyCalc(), lookahead=barmerge.lookahead_off)

// === Beta Calculation (Separate, lighter request) ===
benchRetD = request.security(benchSym, "D", ta.roc(close, 1), lookahead=barmerge.lookahead_off)
lenBeta = isCrypto ? 365 : 252
corr = ta.correlation(d_stockRet, benchRetD, lenBeta)
stdS = ta.stdev(d_stockRet, lenBeta)
stdB = ta.stdev(benchRetD, lenBeta)
beta = stdB > 0 ? corr * (stdS / stdB) : na

// Assign values
perf1W = d_p1W
perf1M = d_p1M
perf2M = d_p2M
perf3M = d_p3M
perf6M = d_p6M
perf1Y = d_p1Y
perf2Y = d_p2Y
sharpe = d_shp

atrPct   = (d_atr / close) * 100
volPct   = d_volSma > 0 ? ((d_vol - d_volSma) / d_volSma) * 100 : 0.0
volStatus = atrPct > 5 ? "Elevated" : atrPct > 2 ? "Normal" : "Low"
trailStop = close - (d_atr * tsMult)

// Fundamentals
eps = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "TTM", ignore_invalid_symbol=true)
pe = eps > 0 ? close / eps : na
divYield = request.financial(syminfo.tickerid, "DIVIDEND_YIELD", "TTM", ignore_invalid_symbol=true)
nim = request.financial(syminfo.tickerid, "NET_MARGIN", "TTM", ignore_invalid_symbol=true)

// ==============================================================================
// COLORS + FUNCTIONS
// ==============================================================================
getPerfColor(val) =>
    if val <= -10
        color.new(#8B0000, 0)
    else if val < 0
        color.new(#FF0000, 0)
    else if val >= 100
        color.new(#90EE90, 0)
    else
        color.new(#32CD32, 0)

getSharpeColor(val) =>
    na(val) ? color.white : val >= 1.0 ? #32CD32 : val >= 0 ? #90EE90 : #FF0000

c_r2d2 = color.new(color.white, 0)
c_pe   = color.new(#32CD32, 0)
c_atr  = color.new(color.yellow, 0)
c_ts   = color.new(#9370DB, 0)
c_vol  = color.new(color.white, 0)
c_yield= color.new(#48D1CC, 0)
c_nim  = color.new(#48D1CC, 0)
c_beta = color.new(color.yellow, 0)
txt_c  = color.black

sharpeText = na(sharpe) ? "Sharpe N/A" : "Sharpe " + str.tostring(sharpe, "#.##") + 
             (sharpe >= 1.0 ? " Good" : sharpe >= 0 ? " OK" : " Poor")

// ==============================================================================
// TABLE
// ==============================================================================
var table dashTable = table.new(position.top_right, columns=17, rows=1, bgcolor=color.black, border_width=1, border_color=color.black)

if barstate.islast
    int c = 0
    table.cell(dashTable, c, 0, "R2D2", text_color=txt_c, bgcolor=c_r2d2, text_size=txtSize)
    c += 1
    
    if showPE
        table.cell(dashTable, c, 0, na(pe) ? "PE N/A" : "PE " + str.tostring(pe, "#.##"), text_color=txt_c, bgcolor=c_pe, text_size=txtSize)
        c += 1
    if show1W
        table.cell(dashTable, c, 0, "1W " + str.tostring(perf1W, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf1W), text_size=txtSize)
        c += 1
    if show1M
        table.cell(dashTable, c, 0, "1M " + str.tostring(perf1M, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf1M), text_size=txtSize)
        c += 1
    if show2M
        table.cell(dashTable, c, 0, "2M " + str.tostring(perf2M, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf2M), text_size=txtSize)
        c += 1
    if show3M
        table.cell(dashTable, c, 0, "3M " + str.tostring(perf3M, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf3M), text_size=txtSize)
        c += 1
    if show6M
        table.cell(dashTable, c, 0, "6M " + str.tostring(perf6M, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf6M), text_size=txtSize)
        c += 1
    if show1Y
        table.cell(dashTable, c, 0, "1Y " + str.tostring(perf1Y, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf1Y), text_size=txtSize)
        c += 1
    if show2Y
        table.cell(dashTable, c, 0, "2Y " + str.tostring(perf2Y, "#.#") + "%", text_color=txt_c, bgcolor=getPerfColor(perf2Y), text_size=txtSize)
        c += 1
    if showATR
        table.cell(dashTable, c, 0, "ATR " + str.tostring(atrPct, "#.#") + "%", text_color=txt_c, bgcolor=c_atr, text_size=txtSize)
        c += 1
    if showTS
        table.cell(dashTable, c, 0, "TS " + str.tostring(trailStop, "#.##"), text_color=txt_c, bgcolor=c_ts, text_size=txtSize)
        c += 1
    if showVol
        table.cell(dashTable, c, 0, "V " + str.tostring(volPct, "#.#") + "%", text_color=txt_c, bgcolor=c_vol, text_size=txtSize)
        c += 1
    if showYield
        table.cell(dashTable, c, 0, na(divYield) ? "0% D.Yield" : str.tostring(divYield, "#.#") + "% D.Yield", text_color=txt_c, bgcolor=c_yield, text_size=txtSize)
        c += 1
    if showNIM
        table.cell(dashTable, c, 0, na(nim) ? "NIM N/A" : "NIM " + str.tostring(nim, "#.#") + "%", text_color=txt_c, bgcolor=c_nim, text_size=txtSize)
        c += 1
    if showBeta
        table.cell(dashTable, c, 0, na(beta) ? "Beta N/A" : "SPX Beta " + str.tostring(beta, "#.##"), text_color=txt_c, bgcolor=c_beta, text_size=txtSize)
        c += 1
    if showVolLbl
        table.cell(dashTable, c, 0, "Volatility " + volStatus, text_color=txt_c, bgcolor=c_atr, text_size=txtSize)
        c += 1
    if showSharpe
        table.cell(dashTable, c, 0, sharpeText, text_color=txt_c, bgcolor=getSharpeColor(sharpe), text_size=txtSize)
        c += 1
    
    if c <= 16
        for i = c to 16
            table.cell(dashTable, i, 0, "", bgcolor=na)
````
