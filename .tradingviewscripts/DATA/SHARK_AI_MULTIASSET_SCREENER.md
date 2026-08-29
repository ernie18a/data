<!-- tradingview-pine-id: PUB;18aca75167a241198b6ad013aa1e8e8a -->
<!-- tradingviewscripts-format: 1 -->
# SHARK AI MULTI-ASSET SCREENER

Source: https://www.tradingview.com/script/rlc8tj89-MULTI-ASSET-SCREENER/

## Description

Multi-Asset Screener is a market analysis and multi-timeframe screening tool designed to provide a clear overview of trend direction, market strength, structure, directional bias, and key support and resistance zones.

The indicator combines multiple layers of market analysis into a compact dashboard, allowing traders to evaluate both individual assets and the current chart across several timeframes.

Key Features

Multi-Asset Screener
Simultaneously monitors BTCUSD, XAUUSD, and NASDAQ, with customizable symbols available in the indicator settings.

Multi-Timeframe Analysis
Analyzes the current asset across M1, M5, M15, M30, H1, H4, and D1 timeframes.

Trend Detection
Classifies current market conditions as:

BULLISH
BEARISH
NEUTRAL

Market Strength
Displays a dynamic strength score from 0% to 100%, helping identify stronger and weaker directional conditions.

---

## Source Code

````pine
//@version=6
indicator("SHARK AI MULTI-ASSET SCREENER", overlay=true)

// === INPUTS ===
showDashboard = input.bool(true, "Show SHARK Screener")

symbol1 = input.symbol("BITSTAMP:BTCUSD", "Asset 1 - BTCUSD")
symbol2 = input.symbol("OANDA:XAUUSD", "Asset 2 - XAUUSD")
symbol3 = input.symbol("OANDA:NAS100USD", "Asset 3 - NASDAQ")

minStrength = input.int(25, "Minimum Strength", minval=1, maxval=100)

swingLen = input.int(5, "Swing Confirmation Length", minval=2, maxval=20)
structureMemoryBars = input.int(20, "Show BOS/CHOCH For X Bars", minval=1, maxval=100)

// === CORE LOGIC ===
f_sharkLogic() =>
    ema9 = ta.ema(close, 9)
    sma20 = ta.sma(close, 20)
    atr = ta.atr(14)

    distance = math.abs(ema9 - sma20)
    strengthRaw = atr > 0 ? distance / atr * 100 : 0
    strength = math.min(100, strengthRaw)

    bullish = ema9 > sma20 and close > ema9 and close > sma20
    bearish = ema9 < sma20 and close < ema9 and close < sma20

    trend = bullish ? 1 : bearish ? -1 : 0

    pivotHigh = ta.pivothigh(high, swingLen, swingLen)
    pivotLow  = ta.pivotlow(low, swingLen, swingLen)

    var float lastSwingHigh = na
    var float lastSwingLow = na
    var int marketStructure = 0
    var int lastStructureCode = 0
    var int lastStructureBar = na

    if not na(pivotHigh)
        lastSwingHigh := pivotHigh

    if not na(pivotLow)
        lastSwingLow := pivotLow

    breakHigh = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
    breakLow  = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

    if breakHigh
        lastStructureCode := marketStructure == -1 ? 1 : 2
        marketStructure := 1
        lastStructureBar := bar_index

    if breakLow
        lastStructureCode := marketStructure == 1 ? -1 : -2
        marketStructure := -1
        lastStructureBar := bar_index

    structureVisible = not na(lastStructureBar) and bar_index - lastStructureBar <= structureMemoryBars
    structure = structureVisible ? lastStructureCode : 0

    bias =
         trend == 1 and strength >= minStrength and (structure == 2 or structure == 1) ? 2 :
         trend == -1 and strength >= minStrength and (structure == -2 or structure == -1) ? -2 :
         trend == 1 and strength >= minStrength ? 1 :
         trend == -1 and strength >= minStrength ? -1 :
         0

    [trend, strength, structure, bias]

// === MULTI ASSET DATA ===
[dir1, str1, bos1, bias1] = request.security(symbol1, timeframe.period, f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dir2, str2, bos2, bias2] = request.security(symbol2, timeframe.period, f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dir3, str3, bos3, bias3] = request.security(symbol3, timeframe.period, f_sharkLogic(), lookahead=barmerge.lookahead_off)

// === CURRENT SYMBOL MULTI TIMEFRAME DATA ===
[dirM1, strM1, bosM1, biasM1] = request.security(syminfo.tickerid, "1", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirM5, strM5, bosM5, biasM5] = request.security(syminfo.tickerid, "5", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirM15, strM15, bosM15, biasM15] = request.security(syminfo.tickerid, "15", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirM30, strM30, bosM30, biasM30] = request.security(syminfo.tickerid, "30", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirH1, strH1, bosH1, biasH1] = request.security(syminfo.tickerid, "60", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirH4, strH4, bosH4, biasH4] = request.security(syminfo.tickerid, "240", f_sharkLogic(), lookahead=barmerge.lookahead_off)
[dirD1, strD1, bosD1, biasD1] = request.security(syminfo.tickerid, "D", f_sharkLogic(), lookahead=barmerge.lookahead_off)

// === TEXT HELPERS ===
f_trendText(dir) =>
    dir == 1 ? "BULLISH" : dir == -1 ? "BEARISH" : "NEUTRAL"

f_structureText(code) =>
    code == 2 ? "BOS UP" :
     code == 1 ? "CHOCH UP" :
     code == -1 ? "CHOCH DOWN" :
     code == -2 ? "BOS DOWN" :
     "NO BREAK"

f_biasText(code) =>
    code == 2 ? "A+ BUY BIAS" :
     code == -2 ? "A+ SELL BIAS" :
     code == 1 ? "BUY BIAS" :
     code == -1 ? "SELL BIAS" :
     "WAIT"

f_dirColor(dir) =>
    dir == 1 ? color.lime : dir == -1 ? color.red : color.orange

f_strengthColor(strength) =>
    strength >= 75 ? color.lime :
     strength >= 50 ? color.yellow :
     strength >= 25 ? color.orange :
     color.red

f_structureColor(code) =>
    code == 2 or code == 1 ? color.lime :
     code == -2 or code == -1 ? color.red :
     color.orange

f_biasColor(code) =>
    code == 2 ? color.lime :
     code == -2 ? color.red :
     code == 1 ? color.new(color.lime, 10) :
     code == -1 ? color.new(color.red, 10) :
     color.orange

// === TABLE ===
var table dash = table.new(position.top_right, 5, 15, border_width=1)

f_row(row, name, dir, strength, structure, bias) =>
    table.cell(dash, 0, row, name, bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, row, f_trendText(dir), bgcolor=f_dirColor(dir), text_color=color.black)
    table.cell(dash, 2, row, str.tostring(strength, "#.##") + "%", bgcolor=f_strengthColor(strength), text_color=color.black)
    table.cell(dash, 3, row, f_structureText(structure), bgcolor=f_structureColor(structure), text_color=color.black)
    table.cell(dash, 4, row, f_biasText(bias), bgcolor=f_biasColor(bias), text_color=color.black)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, " SHARK AI MULTI-ASSET SCREENER ", bgcolor=color.black, text_color=color.aqua)
    table.cell(dash, 1, 0, "TREND", bgcolor=color.black, text_color=color.yellow)
    table.cell(dash, 2, 0, "STRENGTH", bgcolor=color.black, text_color=color.yellow)
    table.cell(dash, 3, 0, "BOS/CHOCH", bgcolor=color.black, text_color=color.yellow)
    table.cell(dash, 4, 0, "AI BIAS", bgcolor=color.black, text_color=color.yellow)

    f_row(1, "BTCUSD", dir1, str1, bos1, bias1)
    f_row(2, "XAUUSD", dir2, str2, bos2, bias2)
    f_row(3, "NASDAQ", dir3, str3, bos3, bias3)

    table.cell(dash, 0, 4, " CURRENT ASSET MTF ", bgcolor=color.aqua, text_color=color.black)
    table.cell(dash, 1, 4, syminfo.ticker, bgcolor=color.aqua, text_color=color.black)
    table.cell(dash, 2, 4, "TIMEFRAMES", bgcolor=color.aqua, text_color=color.black)
    table.cell(dash, 3, 4, "STRUCTURE", bgcolor=color.aqua, text_color=color.black)
    table.cell(dash, 4, 4, "FINAL BIAS", bgcolor=color.aqua, text_color=color.black)

    f_row(5, "M1", dirM1, strM1, bosM1, biasM1)
    f_row(6, "M5", dirM5, strM5, bosM5, biasM5)
    f_row(7, "M15", dirM15, strM15, bosM15, biasM15)
    f_row(8, "M30", dirM30, strM30, bosM30, biasM30)
    f_row(9, "H1", dirH1, strH1, bosH1, biasH1)
    f_row(10, "H4", dirH4, strH4, bosH4, biasH4)
    f_row(11, "D1", dirD1, strD1, bosD1, biasD1)

    table.cell(dash, 0, 12, "ENGINE", bgcolor=color.black, text_color=color.aqua)
    table.cell(dash, 1, 12, "EMA9/SMA20", bgcolor=color.black, text_color=color.orange)
    table.cell(dash, 2, 12, "MIN " + str.tostring(minStrength) + "%", bgcolor=color.black, text_color=color.yellow)
    table.cell(dash, 3, 12, "SWING BOS/CHOCH", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 4, 12, "NO ENTRIES", bgcolor=color.black, text_color=color.lime)
````
