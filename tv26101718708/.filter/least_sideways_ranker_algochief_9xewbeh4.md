# Least Sideways Ranker [AlgoChief]

- url: https://www.tradingview.com/script/9xEWBeh4-Least-Sideways-Ranker-AlgoChief/
- type: indicator
- pine_id: PUB;5a142a92df4c40caab5c16edfd8578db
- version: 1.0

## Description

Trading in sideways or choppy markets is one of the leading causes of drawdowns, whipsaws, and theta decay for option buyers and breakout traders. The Least Sideways Ranker solves this problem by scanning up to 10 customizable assets in real time and automatically ranking them from the least sideways (strongest one-way trend) to the most sideways (consolidation/chop).

Regardless of which chart you apply this indicator to, the dynamic dashboard immediately highlights your current active chart relative to the rest of the watchlist, helping you decide whether to take directional trades or stay aside.

HOW THE CALCULATION WORKS

The ranking engine combines two proven mathematical concepts to filter out market noise and quantify market state:

Choppiness Index (CHOP) The Choppiness Index measures whether the market is moving directionally or consolidating. A lower Choppiness value indicates that price is expanding over a wider range with minimal overlap, signaling a clean trending market.

Average Directional Index (ADX) ADX measures the strength of the prevailing trend without regard to direction. Higher ADX readings indicate robust directional momentum, while readings below 20 represent a weak, directionless market.

Composite Sidewaysness Percentage Both indicators are combined into a normalized 0% to 100% Sidewaysness Score: Sidewaysness % = (Choppiness Index * 0.6) + (Inverted ADX Component * 0.4)

A lower percentage score means less sideways movement and stronger trend momentum. The table automatically sorts all assets in ascending order, placing the asset with the cleanest trend at Rank 1.

HOW TO READ THE TABLE

Rank: Rank 1 represents the symbol with the least sideways action and highest active momentum across your watchlist.

Symbol: Displays the ticker symbol. The chart you are currently viewing is automatically labeled as (This) and highlighted in blue.

Sideways %:

Under 38% (Green): Least Sideways. Strong directional price expansion.
38% to 55% (Yellow): Moderate state. Balanced between trend and pullback.
Over 55% (Red): Pure Sideways. High consolidation and choppy price action.
ADX: Shows the current directional strength value for each symbol.

Trend: Identifies whether the underlying directional pressure is Bullish or Bearish using directional movement indicators (+DI / -DI).

Status: Provides an instant visual summary (Least Sideways, Moderate, Pure Sideways).

TRADING APPLICATIONS

Breakout and Momentum Traders: Focus primarily on Rank 1, 2, and 3 assets. These instruments have the lowest chop and highest likelihood of follow-through on breakout levels.

Option Buyers: Trade assets showing Green / Least Sideways status to minimize premium decay caused by flat, rangebound markets.

Filter False Breakouts: If your target asset is ranked near the bottom with a Sideways % above 55%, avoid taking directional breakout trades, as the probability of a fakeout is elevated.

CUSTOMIZATION OPTIONS

Calculation Period: Adjust the length for the Choppiness Index and ADX calculations (default is 14).
Table Size: Switch between Normal, Large, and Huge to fit different screen resolutions and laptop displays.
Watchlist Symbols: Customize up to 9 external symbols across Indices, Forex pairs, Crypto, Commodities, or Stocks directly from the settings panel.

DISCLAIMER

This indicator is designed purely for educational and analytical purposes. It does not provide automated buy or sell recommendations. Past market behavior and statistical ranking do not guarantee future price performance. Always implement proper risk management and position sizing.

## Source Code

````pine
//@version=6
indicator("Least Sideways Ranker [AlgoChief]", overlay=true)

// ======================== INPUTS ========================
grp_calc = "Settings"
calcLen  = input.int(14, "Calculation Period", group=grp_calc)
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

// Table Size Mapping (Only Valid Pine Script Sizes)
chosenSize = tblSizeOpt == "Huge" ? size.huge : tblSizeOpt == "Large" ? size.large : size.normal

// ======================== CALCULATION ========================
f_getSideways(len) =>
    trSum = math.sum(ta.tr, len)
    hiMin = ta.highest(high, len) - ta.lowest(low, len)
    chopVal = hiMin > 0 ? 100.0 * math.log10(trSum / hiMin) / math.log10(len) : 50.0
    [diplus, diminus, adxVal] = ta.dmi(len, len)
    isBull = diplus >= diminus ? 1.0 : -1.0
    adxComponent = math.max(0.0, 100.0 - math.min(adxVal * 2.0, 100.0))
    sidewaysPct = (chopVal * 0.6) + (adxComponent * 0.4)
    [sidewaysPct, adxVal, isBull]

// Data Fetch (Slot 0 is YOUR CURRENT CHART)
[sc0, ax0, dr0] = f_getSideways(calcLen)
[sc1, ax1, dr1] = request.security(s01, timeframe.period, f_getSideways(calcLen))
[sc2, ax2, dr2] = request.security(s02, timeframe.period, f_getSideways(calcLen))
[sc3, ax3, dr3] = request.security(s03, timeframe.period, f_getSideways(calcLen))
[sc4, ax4, dr4] = request.security(s04, timeframe.period, f_getSideways(calcLen))
[sc5, ax5, dr5] = request.security(s05, timeframe.period, f_getSideways(calcLen))
[sc6, ax6, dr6] = request.security(s06, timeframe.period, f_getSideways(calcLen))
[sc7, ax7, dr7] = request.security(s07, timeframe.period, f_getSideways(calcLen))
[sc8, ax8, dr8] = request.security(s08, timeframe.period, f_getSideways(calcLen))
[sc9, ax9, dr9] = request.security(s09, timeframe.period, f_getSideways(calcLen))

// ======================== SORT & RANK ========================
var symList   = array.new_string(10)
var scoreList = array.new_float(10)
var adxList   = array.new_float(10)
var dirList   = array.new_float(10)

if barstate.islast
    array.set(symList, 0, syminfo.ticker + " (This)")
    array.set(scoreList, 0, nz(sc0, 50.0))
    array.set(adxList, 0, nz(ax0, 0.0))
    array.set(dirList, 0, nz(dr0, 1.0))

    array.set(symList, 1, s01), array.set(scoreList, 1, nz(sc1, 50.0)), array.set(adxList, 1, nz(ax1, 0.0)), array.set(dirList, 1, nz(dr1, 1.0))
    array.set(symList, 2, s02), array.set(scoreList, 2, nz(sc2, 50.0)), array.set(adxList, 2, nz(ax2, 0.0)), array.set(dirList, 2, nz(dr2, 1.0))
    array.set(symList, 3, s03), array.set(scoreList, 3, nz(sc3, 50.0)), array.set(adxList, 3, nz(ax3, 0.0)), array.set(dirList, 3, nz(dr3, 1.0))
    array.set(symList, 4, s04), array.set(scoreList, 4, nz(sc4, 50.0)), array.set(adxList, 4, nz(ax4, 0.0)), array.set(dirList, 4, nz(dr4, 1.0))
    array.set(symList, 5, s05), array.set(scoreList, 5, nz(sc5, 50.0)), array.set(adxList, 5, nz(ax5, 0.0)), array.set(dirList, 5, nz(dr5, 1.0))
    array.set(symList, 6, s06), array.set(scoreList, 6, nz(sc6, 50.0)), array.set(adxList, 6, nz(ax6, 0.0)), array.set(dirList, 6, nz(dr6, 1.0))
    array.set(symList, 7, s07), array.set(scoreList, 7, nz(sc7, 50.0)), array.set(adxList, 7, nz(ax7, 0.0)), array.set(dirList, 7, nz(dr7, 1.0))
    array.set(symList, 8, s08), array.set(scoreList, 8, nz(sc8, 50.0)), array.set(adxList, 8, nz(ax8, 0.0)), array.set(dirList, 8, nz(dr8, 1.0))
    array.set(symList, 9, s09), array.set(scoreList, 9, nz(sc9, 50.0)), array.set(adxList, 9, nz(ax9, 0.0)), array.set(dirList, 9, nz(dr9, 1.0))

    // Sort: Lowest Sidewaysness score = Rank 1
    sortedIndices = array.sort_indices(scoreList, order.ascending)

    // Table Create
    var tbl = table.new(position.top_right, 6, 11, bgcolor=color.new(#131722, 10), border_color=color.new(color.gray, 40), border_width=2)

    // Header
    table.cell(tbl, 0, 0, "Rank", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 1, 0, "Symbol", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 2, 0, "Sideways %", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 3, 0, "ADX", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 4, 0, "Trend", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)
    table.cell(tbl, 5, 0, "Status", bgcolor=#2962FF, text_color=color.white, text_size=chosenSize)

    for i = 0 to 9
        idx = array.get(sortedIndices, i)
        sName = array.get(symList, idx)
        sScore = array.get(scoreList, idx)
        sAdx = array.get(adxList, idx)
        sDir = array.get(dirList, idx)

        string statusTxt = "Moderate"
        color statusCol = color.new(#FFD600, 30)

        if sScore <= 38.0
            statusTxt := "Least Sideways"
            statusCol := color.new(#00C853, 20)
        else if sScore >= 55.0
            statusTxt := "Pure Sideways"
            statusCol := color.new(#D50000, 30)

        string dirTxt = sDir > 0 ? "Bullish" : "Bearish"
        color dirCol = sDir > 0 ? #00E676 : #FF5252
        color rowBg = str.contains(sName, "(This)") ? color.new(#2962FF, 65) : color.new(#131722, 10)

        row = i + 1
        table.cell(tbl, 0, row, "#" + str.tostring(row), bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 1, row, sName, bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 2, row, str.tostring(sScore, "#.0") + "%", bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 3, row, str.tostring(sAdx, "#.0"), bgcolor=rowBg, text_color=color.white, text_size=chosenSize)
        table.cell(tbl, 4, row, dirTxt, bgcolor=rowBg, text_color=dirCol, text_size=chosenSize)
        table.cell(tbl, 5, row, statusTxt, bgcolor=statusCol, text_color=color.white, text_size=chosenSize)
````
