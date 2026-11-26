# RKB_MechTrade

- url: https://www.tradingview.com/script/JTzybYaU-RKB-MechTrade/
- type: indicator
- pine_id: PUB;0b2488687e0543118a48c14c52c13c60
- version: 5.0

## Description

[b]The RKB MechTrade Momentm indicator[/b] is a comprehensive, all-in-one dashboard designed for Momentum and swing traders and investors. Upgraded to the latest Pine Script™ v6, it consolidates relative strength, volume analysis, trend momentum, and price-action proximity into a single, non-intrusive on-chart table.

Here is a breakdown of the core features and how to use them:

[b]1. 52-Week High & Customizable Pullback Bands[/b]
The indicator plots the 52-week highest high directly on your chart, serving as a primary benchmark for resistance and breakouts.

Dynamic Pullback Bands: Below the 52-week high, it plots two customizable percentage bands (defaulting to 10% and 23% below the high).

Use Case: These bands help visualize structural support zones and identify textbook pullback setups (like VCPs or flag patterns) relative to the yearly high.

[b]2. Z-Score of Returns (ZOR)[/b]
The ZOR module is the engine of the script's relative strength analysis.

How it works: It measures the performance of the base asset against a comparative benchmark (defaults to NSE:NIFTY) over multiple weighted timeframes (63, 126, 189, and 252 days).

The Score: It normalizes these weighted returns into a clean Z-Score. A score above 60 is highlighted in blue, indicating strong relative momentum and market outperformance. Values below 60 are flagged in red.

Note: To ensure data accuracy, ZOR is explicitly calculated and displayed only on the Daily timeframe.

[b]3. Price Proximity Metrics (DTH & DTE)[/b]
Knowing how extended a stock is can prevent buying at the top or shorting at the bottom.

Distance to High (DTH): Calculates the exact percentage gap between the current closing price and the 52-week high. If the stock is breaking out, it clearly states "At or Above 52W High".

Distance to EMA (DTE): Measures the percentage deviation from a user-defined EMA (default 21-period). This is an excellent metric for spotting mean-reversion opportunities or avoiding heavily overextended entries.

[b]4. Institutional Volume & Traded Value (Turnover)[/b]
Rather than just looking at raw volume bars, this script calculates the actual capital flowing into the asset.

Traded Value in Crores: It calculates the traded turnover (Volume × Close Price) and adapts automatically to your chart. On a Daily chart, it shows daily turnover; on a Weekly chart, it accumulates the weekly turnover.

Color-Coded Liquidity: The Traded Value cell changes color based on strict liquidity thresholds:

[list]
[*]Red: Less than 5 Cr (Low Liquidity)
[*]Amber: 5 Cr to 50 Cr (Moderate Liquidity)
[*]Green: Greater than 50 Cr (High Institutional Liquidity)
[/list]

Volume Context: It also compares current volume to a long-term average (default 500 periods), tagging the session as "Trade" (active) or "Low" (quiet).

[b]5. Trend Angle & Price Velocity[/b]
MA Angle (∠): Calculates the geometric slope/angle of a chosen Moving Average (defaults to a 20-period EMA). A positive angle indicates a clear uptrend, while a negative angle warns of a downtrend.

Velocity: Analyzes the current bar's High-Low range against a 14-period average. If the current range is wider than the average, it tags the market as "Fast" (expansion/volatility). If narrower, it tags it as "Slow" (contraction/consolidation).

[b]6. Interactive UI & Tooltips[/b]
Clean Table: All data is neatly organized in a vertical dashboard anchored to the bottom-right of the screen (fully customizable in the settings).

[b]Hover-to-Learn:[/b] Built using Pine Script™ v6 features, every single cell in the dashboard includes an interactive tooltip. Users can simply hover their mouse over any metric (like ZOR or Velocity) to instantly read a description of what it means and how it is calculated.

## Source Code

````pine
//@version=6
indicator("RKB_MechTrade_v3", overlay=true)

// =====================================================================
// 1. BANDS SETTINGS
// =====================================================================
upperBandPercent = input.float(10, title="Upper Band (%) Below 52W High", minval=0, maxval=100, group="Bands")
lowerBandPercent = input.float(23, title="Lower Band (%) Below 52W High", minval=0, maxval=100, group="Bands")

// Calculate available bars on the daily timeframe
daysOnChart = request.security(syminfo.tickerid, "D", bar_index)
lookbackPeriod = math.min(365, daysOnChart + 1) // bar_index starts at 0
highestHigh = request.security(syminfo.tickerid, "D", ta.highest(high, lookbackPeriod))

// Calculate the customizable bands based on user input
upperBand = highestHigh * (1 - upperBandPercent / 100)
lowerBand = highestHigh * (1 - lowerBandPercent / 100)

// Assign the named plots to variables with dashed styles
p1 = plot(upperBand, title="Upper Band", color=color.new(color.blue, 0), linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)
p2 = plot(lowerBand, title="Lower Band", color=color.new(color.red, 0), linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)
fill(p1, p2, color=color.new(#d3d8ec, 80), title="Plots Background")
plot(highestHigh, title="52-Week High", color=color.new(color.green, 50), linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)


// =====================================================================
// 2. UI / DISPLAY SETTINGS - 
// =====================================================================
displayInColumn = input.bool(true, title="Display indicators in one column", group="Display Settings")
labelPos        = input.string("Bottom Right", title="Label Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group="Display Settings")
fontSize        = input.string("Small", title="Font Size", options=["Tiny", "Small", "Medium", "Large"], group="Display Settings")

showSymbol      = input.bool(false, "Show Symbol", group="Display Settings")
showSector      = input.bool(true, "Show Sector", group="Display Settings")
showIndustry    = input.bool(true, "Show Industry", group="Display Settings")
showCapCat      = input.bool(false, "Show Market Cap Category", group="Display Settings")
showMcapValue   = input.bool(true, "Show Market Cap (₹ Cr)", group="Display Settings")

// Table Position Mapping
tablePos = switch labelPos
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left" => position.middle_left
    => position.bottom_right

// Font Size Mapping
textSize = switch fontSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Medium" => size.normal
    "Large" => size.large
    => size.small


// =====================================================================
// 3. INDICATOR INPUTS (Momentum & Distance)
// =====================================================================
showzor             = input.bool(true, title="Show ZOR", group="Indicator Settings")
comparativeTickerId = input.symbol('NSE:NIFTY', title='Comparative Symbol', group="Indicator Settings")
strictMode          = input.bool(true, title="Strict Mode (Requires 252 bars)", group="Indicator Settings")
ma63                = input.int(40, minval=0, title='MA63 Weight %', group="Indicator Settings")
ma126               = input.int(20, minval=0, title='MA126 Weight %', group="Indicator Settings")
ma189               = input.int(20, minval=0, title='MA189 Weight %', group="Indicator Settings")
ma252               = input.int(20, minval=0, title='MA252 Weight %', group="Indicator Settings")

showdth             = input.bool(true, title="Show Distance to High", group="Indicator Settings") 
showdtema           = input.bool(true, title="Show Distance to EMA", group="Indicator Settings") 
emalen              = input.int(21, title="Distance to EMA Length", group="Indicator Settings")

volLookback         = input.int(50, minval=1, title="Volume Avg Lookback", group="Indicator Settings")
ma1Type             = input.string(title="MA1 Type (Angle)", defval="EMA", options=["SMA", "EMA", "HMA"], group="Indicator Settings")
ma1Length           = input.int(title="MA1 Length (Angle)", defval=21, minval=1, group="Indicator Settings")
velocityLookback    = input.int(title="Velocity Lookback Periods", defval=14, minval=1, group="Indicator Settings")


// =====================================================================
// 4. RISK & TREND METRIC INPUTS
// =====================================================================
showBeta            = input.bool(true, title="Show Beta 1Y", group="Risk & Trend Settings")
showVolatility      = input.bool(true, title="Show Volatility 1W", group="Risk & Trend Settings")
showAtr             = input.bool(true, title="Show ATR %", group="Risk & Trend Settings")
showAdx             = input.bool(true, title="Show ADX", group="Risk & Trend Settings")


// =====================================================================
// 5. HELPER FUNCTIONS
// =====================================================================
calcMA(src, length, type) =>
    switch type
        "EMA" => ta.ema(src, length)
        "HMA" => ta.hma(src, length)
        => ta.sma(src, length)

fmtCr(x) => str.tostring(x, "#.##")
f_format_num(num) => na(num) ? "N/A" : str.format("{0,number,#,###}", num)


// =====================================================================
// 6. CORE CALCULATIONS (ZOR, Velocity, Distance)
// =====================================================================
source = input(title='Source', defval=close, display=display.none)
baseSymbol = request.security(syminfo.tickerid, timeframe.period, source)
comparativeSymbol = request.security(comparativeTickerId, timeframe.period, source)

calcZOR() =>
    float vb63 = na
    if baseSymbol[63] != 0 and comparativeSymbol[63] != 0
        vb63 := ma63 * (baseSymbol[0] / baseSymbol[63] / (comparativeSymbol[0] / comparativeSymbol[63]) - 1)
    float vb126 = 0
    if baseSymbol[126] != 0 and comparativeSymbol[126] != 0
        vb126 := ma126 * (baseSymbol[0] / baseSymbol[126] / (comparativeSymbol[0] / comparativeSymbol[126]) - 1)
    else
        vb126 := vb63 / 2
    float vb189 = 0
    if baseSymbol[189] != 0 and comparativeSymbol[189] != 0
        vb189 := ma189 * (baseSymbol[0] / baseSymbol[189] / (comparativeSymbol[0] / comparativeSymbol[189]) - 1)
    else
        vb189 := vb126
    float vb252 = 0
    if baseSymbol[252] != 0 and comparativeSymbol[252] != 0
        vb252 := ma252 * (baseSymbol[0] / baseSymbol[252] / (comparativeSymbol[0] / comparativeSymbol[252]) - 1)
    else
        vb252 := vb189

    vb0 = (nz(vb63) + vb126 + vb189 + vb252)
    zor = 40 + (vb0 < 0 ? -1 : 1) * (math.sqrt(math.abs(vb0)) * 6.4881)
    math.round(math.min(zor, 99))

// FIX: Calculate unconditionally to maintain history state
rawZor = calcZOR()
score = (strictMode and bar_index < 252) ? 0 : rawZor

// Extra Metrics
volumeAvg = ta.sma(volume, volLookback)
volumeIsLow = volume < volumeAvg
volumeText = volumeIsLow ? "Low" : "Trade"
volumeBg = volumeIsLow ? color.rgb(251, 101, 101) : color.rgb(100, 190, 120)
volumeTx = volumeIsLow ? color.white : color.black

ma1 = calcMA(close, ma1Length, ma1Type)
angle1 = math.todegrees(math.atan(((ma1 - ma1[1]) / ma1[1]) * 100))
angleText1 = str.tostring(math.floor(angle1)) + "°"
angleBg1 = angle1 > 0 ? color.rgb(100, 190, 120) : color.rgb(251, 101, 101)
angleTx1 = angle1 > 0 ? color.black : color.white

highLowDiff = high - low
avgHighLowDiff = ta.sma(highLowDiff, velocityLookback)
velocityIsSlow = highLowDiff < avgHighLowDiff
velocityText = velocityIsSlow ? "Slow" : "Fast"
velocityBg = velocityIsSlow ? color.rgb(251, 101, 101) : color.rgb(100, 190, 120)
velocityTx = velocityIsSlow ? color.white : color.black

volValueCr = (volume * close) / 10000000.0
avgVolValueCr10 = ta.sma(volume * close, 10) / 10000000.0
valBgColor = volValueCr < 5 ? color.rgb(251, 101, 101) : (volValueCr <= 50 ? color.rgb(255, 152, 0) : color.rgb(100, 190, 120))

// DTH & DTE
s = syminfo.tickerid
tf = timeframe.period
closeDa = request.security(s, tf, close)
_52wHigh = request.security(s, 'W', ta.highest(51))
perc_52wHigh = 100 * (closeDa/_52wHigh-1)
emaValue = request.security(s, 'D', ta.ema(closeDa, emalen))
distancetoema = (closeDa / emaValue * 100) - 100


// =====================================================================
// 7. RISK & TREND CALCULATIONS
// =====================================================================
// Logarithmic returns: ln(Close / Close[1])
baseRet = math.log(close / nz(close[1], close))
idxRet  = math.log(comparativeSymbol / nz(comparativeSymbol[1], comparativeSymbol))

// --- Beta 1Y & Volatility ---
float beta1Y = na
float vol1W  = na

// FIX: Mathematical rewrite of Beta -> Beta = Correlation * (Stdev Base / Stdev Idx)
if timeframe.isdaily
    corrDaily      = ta.correlation(baseRet, idxRet, 252)
    stdevDailyBase = ta.stdev(baseRet, 252)
    stdevDailyIdx  = ta.stdev(idxRet, 252)
    
    beta1Y        := stdevDailyIdx != 0 ? corrDaily * (stdevDailyBase / stdevDailyIdx) : na
    vol1W         := stdevDailyBase * math.sqrt(5) * 100
    
else if timeframe.isweekly
    corrWeekly      = ta.correlation(baseRet, idxRet, 52)
    stdevWeeklyBase = ta.stdev(baseRet, 52)
    stdevWeeklyIdx  = ta.stdev(idxRet, 52)
    
    beta1Y         := stdevWeeklyIdx != 0 ? corrWeekly * (stdevWeeklyBase / stdevWeeklyIdx) : na
    vol1W          := stdevWeeklyBase * 100

// --- ATR % ---
atr14 = ta.atr(14)
atrPct = (atr14 / close) * 100

// --- ADX ---
[diplus, diminus, adxVal] = ta.dmi(14, 14)


// =====================================================================
// 8. MCAP & FUNDAMENTALS
// =====================================================================
ticker   = syminfo.ticker
exchange = syminfo.prefix
sector   = syminfo.sector
industry = syminfo.industry

sector_text   = na(sector) ? "N/A" : sector
industry_text = na(industry) ? "N/A" : industry

shares_outstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
market_cap_raw     = na(shares_outstanding) ? na : shares_outstanding * close
market_cap_cr      = na(market_cap_raw) ? na : (market_cap_raw / 1e7)
market_cap_text    = na(market_cap_cr) ? "N/A" : "₹ " + f_format_num(math.round(market_cap_cr)) + " Cr"

f_cap_category(mcap) =>
    if na(mcap)
        "N/A"
    else if mcap >= 20000
        "LARGE CAP"
    else if mcap >= 5000
        "MID CAP"
    else
        "SMALL CAP"
cap_category = f_cap_category(market_cap_cr)


// =====================================================================
// 9. DYNAMIC TABLE RENDER
// =====================================================================
// Determine if Timeframe is valid for the dashboard
isValidTimeframe = timeframe.isdaily or timeframe.isweekly

var table infoTable = table.new(tablePos, 20, 20, border_width=1)

// Helper Function for appending cells
f_add_cell(tbl, isCol, idx, _text, _txColor, _bgColor, _tooltip, _tSize) =>
    if isCol
        table.cell(tbl, 0, idx, _text, text_color=_txColor, text_size=_tSize, bgcolor=_bgColor, tooltip=_tooltip)
    else
        table.cell(tbl, idx, 0, _text, text_color=_txColor, text_size=_tSize, bgcolor=_bgColor, tooltip=_tooltip)
    idx + 1

if barstate.islast
    table.clear(infoTable, 0, 0, 19, 19)
    int current_idx = 0

    if not isValidTimeframe
        // Trigger Warning Message if chart is not D or W
        f_add_cell(infoTable, displayInColumn, current_idx, "⚠️ Dashboard designed for Daily and Weekly charts", color.white, color.rgb(251, 101, 101), "Switch timeframe to Daily or Weekly to view metrics.", textSize)
    
    else
        // -----------------------------------------------------------------
        // FUNDAMENTAL INFO
        // -----------------------------------------------------------------
        infoBgColor = color.white
        if showSymbol
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Sym: " + exchange + ":" + ticker, color.black, infoBgColor, "Current Symbol", textSize)
        if showSector
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Sec: " + sector_text, color.black, infoBgColor, "Market Sector", textSize)
        if showIndustry
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Ind: " + industry_text, color.black, infoBgColor, "Market Industry", textSize)
        if showCapCat
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Cat: " + cap_category, color.black, infoBgColor, "Market Capitalization Category", textSize)
        if showMcapValue
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "MCap: " + market_cap_text, color.blue, infoBgColor, "Total Market Capitalization (Crores)", textSize)

        // -----------------------------------------------------------------
        // RISK & TREND QUALITY MODULE
        // -----------------------------------------------------------------
       
        // Beta 1Y
        if showBeta
            betaTooltip = "Beta Interpretation\n<0.8 Defensive\n0.8-1.2 Market-like\n1.2-1.5 Aggressive\n>1.5 High-Beta Momentum"
            betaStr = na(beta1Y) ? "N/A" : str.tostring(beta1Y, "#.##")
            
            // Updated Color Logic: <0.8 Red | 0.8-1.2 Grey | 1.2-1.5 Blue | >1.5 Green
            betaBgColor = na(beta1Y) ? color.gray : (beta1Y < 0.8 ? color.rgb(251, 101, 101) : (beta1Y <= 1.2 ? color.gray : (beta1Y <= 1.5 ? color.blue : color.rgb(100, 190, 120))))
            
            betaTxColor = color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Beta 1Y: " + betaStr, betaTxColor, betaBgColor, betaTooltip, textSize)
        
        // Volatility 1W
        if showVolatility
            volTooltip = "Volatility Interpretation\n<2% Low-Risk Trend\n2-4% Normal Momentum\n>4% High-Risk Momentum"
            volStr = na(vol1W) ? "N/A" : str.tostring(vol1W, "#.##") + "%"
            volBgColor = na(vol1W) ? color.gray : (vol1W < 2.0 ? color.rgb(100, 190, 120) : (vol1W <= 4.0 ? color.orange : color.red))
            volTxColor = color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Vol 1W: " + volStr, volTxColor, volBgColor, volTooltip, textSize)

        // ATR %
        if showAtr
            atrTooltip = "ATR% Interpretation\n<2% Low Volatility\n2-5% Normal Volatility\n>5% High Volatility"
            atrStr = na(atrPct) ? "N/A" : str.tostring(atrPct, "#.##") + "%"
            atrBgColor = na(atrPct) ? color.gray : (atrPct < 2.0 ? color.rgb(100, 190, 120) : (atrPct <= 5.0 ? color.orange : color.red))
            atrTxColor = color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "ATR%: " + atrStr, atrTxColor, atrBgColor, atrTooltip, textSize)

        // ADX
        if showAdx
            adxTooltip = "ADX Interpretation\n<20 Weak Trend\n20-25 Emerging Trend\n25-40 Strong Trend\n>40 Very Strong Trend"
            adxStr = na(adxVal) ? "N/A" : str.tostring(adxVal, "#.#")
            adxBgColor = na(adxVal) ? color.gray : (adxVal < 20 ? color.rgb(158, 158, 158) : (adxVal <= 25 ? color.rgb(255, 235, 59) : (adxVal <= 40 ? color.rgb(100, 190, 120) : color.rgb(34, 139, 34))))
            adxTxColor = (adxVal >= 20 and adxVal <= 25) ? color.black : color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "ADX: " + adxStr, adxTxColor, adxBgColor, adxTooltip, textSize)


        // -----------------------------------------------------------------
        // ORIGINAL MECHANIC METRICS
        // -----------------------------------------------------------------
        // ZOR
        zorTooltip = "Z-Score of Returns (ZOR): Evaluates relative momentum against a base symbol utilizing varying MA lengths. Higher score = Strong relative strength."
        if showzor and not na(score)
            scoreStr = score == 0 ? "0" : str.tostring(score, '#')
            zorColor = score < 60 ? color.rgb(251, 101, 101) : color.blue
            zorTx = score < 60 ? color.black : color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "ZOR: " + scoreStr, zorTx, zorColor, zorTooltip, textSize)

        // Distance to High
        if showdth
            highText = perc_52wHigh >= 0 ? "At or Above 52W High" : str.tostring(math.abs(perc_52wHigh), "#.##") + "% to 52W High"
            highBgColor = perc_52wHigh >= 0 ? color.rgb(128,128,128) : color.rgb(0, 128, 0)
            highTextColor = perc_52wHigh >= 0 ? color.black : color.white
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, highText, highTextColor, highBgColor, "Distance to 52W High", textSize)

        // Enhanced Distance to EMA
        if showdtema
            dteTooltip = "Distance to EMA(" + str.tostring(emalen) + ")"
            dteBgColor = distancetoema < 0 ? color.rgb(251, 101, 101) : (distancetoema <= 10 ? color.rgb(100, 190, 120) : (distancetoema < 20 ? color.rgb(255, 152, 0) : color.rgb(251, 101, 101)))
            dteTxColor = distancetoema < 0 ? color.white : (distancetoema < 20 and distancetoema > 10 ? color.black : color.white)
            current_idx := f_add_cell(infoTable, displayInColumn, current_idx, str.tostring(distancetoema, format.mintick) + "% From EMA(" + str.tostring(emalen) + ")", dteTxColor, dteBgColor, dteTooltip, textSize)

        // Volume
        current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Vol: " + volumeText, volumeTx, volumeBg, "Volume Context", textSize)
        
        // MA Angle
        current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "MA1 ∠: " + angleText1, angleTx1, angleBg1, "MA Angle in degrees", textSize)
        
        // Velocity
        current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Vel: " + velocityText, velocityTx, velocityBg, "Price Velocity Expansion/Contraction", textSize)

        // Volume Value
        tfLbl = timeframe.isweekly ? "W" : "D"
        current_idx := f_add_cell(infoTable, displayInColumn, current_idx, tfLbl + " Vol Val: " + fmtCr(volValueCr) + " Cr", color.white, valBgColor, "Traded Capital in Crores", textSize)
        
        // Average Volume Value
        current_idx := f_add_cell(infoTable, displayInColumn, current_idx, "Avg " + tfLbl + " VV(10): " + fmtCr(avgVolValueCr10) + " Cr", color.white, color.rgb(70, 70, 90), "10-period Average Traded Capital", textSize)

// ZOR Data Window Output
plot(score, title="ZOR Score", display=display.data_window)
````
