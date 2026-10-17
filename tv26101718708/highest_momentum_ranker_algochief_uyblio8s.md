# Highest Momentum Ranker [AlgoChief]

- url: https://www.tradingview.com/script/UyBliO8S-Highest-Momentum-Ranker-AlgoChief/
- type: indicator
- pine_id: PUB;8b71978e9e8c49619de3c0f185a4ee85
- version: 1.0

## Description

Finding which asset has the strongest momentum in real-time is essential for day traders, scalpers, and breakout specialists. The Highest Momentum Ranker [AlgoChief] continuously tracks multiple assets across Forex, Crypto, Indices, and Commodities, quantitatively scoring and ranking them so you instantly spot where the fastest price action is taking place.

No matter which asset or timeframe you apply the indicator to, your active chart is automatically analyzed and highlighted in the dashboard, showing its precise momentum rank compared to the rest of the market.

HOW THE MOMENTUM ENGINE WORKS

Momentum is not just about price moving in one direction; it is about velocity, rate of change, and directional conviction. The indicator synthesizes two core analytical engines:

Relative Strength Index (RSI) Deviation Measures how aggressively buyers or sellers are pushing price away from equilibrium (50 level). Extreme readings above 65 or below 35 represent high directional drive.

Average Directional Movement (ADX Velocity) Measures the pure acceleration and strength of the price move regardless of whether it is an aggressive rally or an aggressive selloff.

Composite Momentum Intensity Score The score scales from 0 to 100 points: Momentum Score = (RSI Deviation * 0.5) + (ADX Component * 0.5)

The table automatically sorts all assets in descending order. The symbol experiencing the most intense velocity and directional power appears at Rank 1.

HOW TO READ THE DASHBOARD

Rank: Rank 1 indicates the instrument with the highest active momentum across your entire watchlist.

Symbol: The ticker name. The active chart you are looking at is marked as (This) and highlighted in purple.

Momentum Score:

Above 45 Points (Green - Explosive): Extremely fast, high-velocity price action.
28 to 44 Points (Cyan - High Speed): Healthy directional momentum.
18 to 27 Points (Yellow - Moderate): Normal drift or minor pullback.
Below 18 Points (Gray - Weak / Flat): Sideways grind with minimal volatility.
RSI: Displays real-time RSI reading for quick overbought/oversold context.

Velocity: Shows whether the primary force behind the momentum is Bullish Up or Bearish Down.

Status: Provides an instant visual snapshot of market velocity.

PRACTICAL STRATEGY USAGE

Momentum Breakouts: Focus your capital exclusively on Rank 1 and Rank 2 assets. When an asset has high momentum points and breaks a key support or resistance level, follow-through probability is significantly higher.

Scalping Volatility: Avoid instruments sitting at the bottom of the table in the Weak/Flat state. Direct your attention to Explosive assets where spreads are covered rapidly.

Trend Exhaustion Awareness: If an asset has an explosive momentum score with RSI exceeding 80 or dropping below 20, look for quick take-profit opportunities before a mean-reversion pullback occurs.

SETTINGS AND CUSTOMIZATION

RSI Length: Adjust the lookback period for momentum calculation (default is 14).
ADX Length: Adjust the lookback period for directional velocity (default is 14).
Table Size: Choose between Normal, Large, and Huge based on your screen layout.
Watchlist Symbols: Easily replace any of the 9 default symbols with your preferred tickers in the settings window.

DISCLAIMER

This indicator is provided strictly for educational and analytical purposes. It does not generate automatic buy or sell signals or financial advice. High momentum markets carry heightened volatility and risk. Always utilize sound risk management and appropriate position sizing.

## Source Code

````pine
//@version=6
indicator("Highest Momentum Ranker [AlgoChief]", overlay=true)

// ======================== SETTINGS ========================
grp_calc = "Settings"
lenRsi   = input.int(14, "RSI Length", group=grp_calc)
lenAdx   = input.int(14, "ADX Length", group=grp_calc)
tblSizeOpt = input.string("Large", "Table Size", options=["Normal", "Large", "Huge"], group=grp_calc)

grp_sym = "Watchlist Symbols"
s01 = input.symbol("FX:GBPJPY", "Symbol 1", group=grp_sym)
s02 = input.symbol("FX:EURUSD", "Symbol 2", group=grp_sym)
s03 = input.symbol("FX:USDJPY", "Symbol 3", group=grp_sym)
s04 = input.symbol("FX:GBPUSD", "Symbol 4", group=grp_sym)
s05 = input.symbol("OANDA:NAS100USD", "Symbol 5", group=grp_sym)
s06 = input.symbol("OANDA:US30USD", "Symbol 6", group=grp_sym)
s07 = input.symbol("OANDA:SPX500USD", "Symbol 7", group=grp_sym)
s08 = input.symbol("OANDA:XAUUSD", "Symbol 8 (Gold)", group=grp_sym)
s09 = input.symbol("BINANCE:BTCUSDT", "Symbol 9 (Crypto)", group=grp_sym)

// Table Size Mapping
chosenSize = tblSizeOpt == "Huge" ? size.huge : tblSizeOpt == "Large" ? size.large : size.normal

// ======================== MOMENTUM ENGINE ========================
// Momentum Score (0 to 100): Combines ADX Velocity + RSI Deviation
f_calcMomentum(lRsi, lAdx) =>
    rsiVal = ta.rsi(close, lRsi)
    [diplus, diminus, adxVal] = ta.dmi(lAdx, lAdx)
    
    // RSI deviation from center (50)
    rsiDev = math.abs(rsiVal - 50.0) * 1.5
    // ADX velocity component
    adxComponent = adxVal * 1.0
    
    // Combined Momentum Intensity (Max 100)
    momScore = math.min(100.0, math.max(0.0, (rsiDev * 0.5) + (adxComponent * 0.5)))
    
    // Direction: 1 = Bullish Velocity, -1 = Bearish Velocity
    dirVal = diplus >= diminus ? 1.0 : -1.0
    
    [momScore, rsiVal, adxVal, dirVal]

// ======================== DATA FETCH ========================
// Slot 0 evaluates your current active chart automatically
[m0, r0, a0, d0] = f_calcMomentum(lenRsi, lenAdx)
[m1, r1, a1, d1] = request.security(s01, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m2, r2, a2, d2] = request.security(s02, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m3, r3, a3, d3] = request.security(s03, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m4, r4, a4, d4] = request.security(s04, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m5, r5, a5, d5] = request.security(s05, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m6, r6, a6, d6] = request.security(s06, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m7, r7, a7, d7] = request.security(s07, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m8, r8, a8, d8] = request.security(s08, timeframe.period, f_calcMomentum(lenRsi, lenAdx))
[m9, r9, a9, d9] = request.security(s09, timeframe.period, f_calcMomentum(lenRsi, lenAdx))

// ======================== SORT & RANK ========================
var symList   = array.new_string(10)
var scoreList = array.new_float(10)
var rsiList   = array.new_float(10)
var adxList   = array.new_float(10)
var dirList   = array.new_float(10)

if barstate.islast
    array.set(symList, 0, syminfo.ticker + " (This)")
    array.set(scoreList, 0, nz(m0, 0.0))
    array.set(rsiList, 0, nz(r0, 50.0))
    array.set(adxList, 0, nz(a0, 0.0))
    array.set(dirList, 0, nz(d0, 1.0))

    array.set(symList, 1, s01), array.set(scoreList, 1, nz(m1, 0.0)), array.set(rsiList, 1, nz(r1, 50.0)), array.set(adxList, 1, nz(a1, 0.0)), array.set(dirList, 1, nz(d1, 1.0))
    array.set(symList, 2, s02), array.set(scoreList, 2, nz(m2, 0.0)), array.set(rsiList, 2, nz(r2, 50.0)), array.set(adxList, 2, nz(a2, 0.0)), array.set(dirList, 2, nz(d2, 1.0))
    array.set(symList, 3, s03), array.set(scoreList, 3, nz(m3, 0.0)), array.set(rsiList, 3, nz(r3, 50.0)), array.set(adxList, 3, nz(a3, 0.0)), array.set(dirList, 3, nz(d3, 1.0))
    array.set(symList, 4, s04), array.set(scoreList, 4, nz(m4, 0.0)), array.set(rsiList, 4, nz(r4, 50.0)), array.set(adxList, 4, nz(a4, 0.0)), array.set(dirList, 4, nz(d4, 1.0))
    array.set(symList, 5, s05), array.set(scoreList, 5, nz(m5, 0.0)), array.set(rsiList, 5, nz(r5, 50.0)), array.set(adxList, 5, nz(a5, 0.0)), array.set(dirList, 5, nz(d5, 1.0))
    array.set(symList, 6, s06), array.set(scoreList, 6, nz(m6, 0.0)), array.set(rsiList, 6, nz(r6, 50.0)), array.set(adxList, 6, nz(a6, 0.0)), array.set(dirList, 6, nz(d6, 1.0))
    array.set(symList, 7, s07), array.set(scoreList, 7, nz(m7, 0.0)), array.set(rsiList, 7, nz(r7, 50.0)), array.set(adxList, 7, nz(a7, 0.0)), array.set(dirList, 7, nz(d7, 1.0))
    array.set(symList, 8, s08), array.set(scoreList, 8, nz(m8, 0.0)), array.set(rsiList, 8, nz(r8, 50.0)), array.set(adxList, 8, nz(a8, 0.0)), array.set(dirList, 8, nz(d8, 1.0))
    array.set(symList, 9, s09), array.set(scoreList, 9, nz(m9, 0.0)), array.set(rsiList, 9, nz(r9, 50.0)), array.set(adxList, 9, nz(a9, 0.0)), array.set(dirList, 9, nz(d9, 1.0))

    // Sort: Highest Momentum Score = Rank 1 (Descending)
    sortedIndices = array.sort_indices(scoreList, order.descending)

    // Create Table
    var tbl = table.new(position.top_right, 6, 11, bgcolor=color.new(#131722, 10), border_color=color.new(color.gray, 40), border_width=2)

    // Header
    table.cell(tbl, 0, 0, "Rank", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 1, 0, "Symbol", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 2, 0, "Momentum", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 3, 0, "RSI", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 4, 0, "Velocity", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 5, 0, "Status", bgcolor=#6200EA, text_color=color.white, text_size=chosenSize)

    for i = 0 to 9
        idx = array.get(sortedIndices, i)
        sName = array.get(symList, idx)
        sScore = array.get(scoreList, idx)
        sRsi = array.get(rsiList, idx)
        sDir = array.get(dirList, idx)

        string statusTxt = "Weak / Flat"
        color statusCol = color.new(#757575, 40)

        if sScore >= 45.0
            statusTxt := "Explosive"
            statusCol := color.new(#00C853, 20)
        else if sScore >= 28.0
            statusTxt := "High Speed"
            statusCol := color.new(#00B0FF, 30)
        else if sScore >= 18.0
            statusTxt := "Moderate"
            statusCol := color.new(#FFD600, 30)

        string velTxt = sDir > 0 ? "Bullish Up" : "Bearish Down"
        color velCol = sDir > 0 ? #00E676 : #FF5252
        color rowBg = str.contains(sName, "(This)") ? color.new(#6200EA, 65) : color.new(#131722, 10)

        row = i + 1
        table.cell(tbl, 0, row, "#" + str.tostring(row), bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 1, row, sName, bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 2, row, str.tostring(sScore, "#.0") + " pts", bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 3, row, str.tostring(sRsi, "#.0"), bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 4, row, velTxt, bgcolor=rowBg, text_color=velCol, text_size=chosenSize)
        table.cell(tbl, 5, row, statusTxt, bgcolor=statusCol, text_color=color.white, text_size=chosenSize)
````
