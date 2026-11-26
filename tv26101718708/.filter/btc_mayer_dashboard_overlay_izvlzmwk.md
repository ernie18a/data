# BTC Mayer Dashboard Overlay

- url: https://www.tradingview.com/script/iZvLzMwk-BTC-Mayer-Dashboard-Overlay/
- type: indicator
- pine_id: PUB;72d599307ff3414788afd4d64825039a
- version: 3.0

## Description

This idea has always found the bottoms and tops for bitcoin.  The table will adjust as price moves up or down.  It provides fair value avg, projected bottom, and projected top based on overheated or oversold conditions.

## Source Code

````pine
//@version=6
indicator("BTC Mayer Dashboard Overlay", shorttitle="MayerDash", overlay=true, scale=scale.right, precision=2)

//====================================================
// INPUTS
//====================================================

useChartSymbol = input.bool(true, "Use chart symbol instead of BTC source?")
btcSymbol      = input.symbol("COINBASE:BTCUSD", "BTC Source")
calcTf         = input.timeframe("D", "Calculation Timeframe")
maLen          = input.int(365, "Mayer MA Length", minval=50)

tablePos       = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
showPriceLvls  = input.bool(false, "Plot Mayer Price Levels on Main Chart?")

deepLevel      = input.float(0.50, "Deep Buy Level", step=0.05)
accumLevel     = input.float(0.80, "Accumulation Level", step=0.05)
hotLevel       = input.float(2.40, "Overheated Level", step=0.10)

//====================================================
// DATA
//====================================================

calcSymbol = useChartSymbol ? syminfo.tickerid : btcSymbol

[dClose, dMa365] = request.security(
     calcSymbol,
     calcTf,
     [close, ta.sma(close, maLen)],
     barmerge.gaps_off,
     barmerge.lookahead_off)

mayer = dMa365 > 0.0 ? dClose / dMa365 : na

deepPrice  = dMa365 * deepLevel
accumPrice = dMa365 * accumLevel
hotPrice   = dMa365 * hotLevel

//====================================================
// COLORS / HELPERS
//====================================================

deepColor  = color.rgb(0, 180, 90)
accumColor = color.rgb(40, 150, 90)
fairColor  = color.rgb(75, 90, 120)
hotColor   = color.rgb(210, 65, 65)
darkBg     = color.rgb(20, 22, 28)
headBg     = color.rgb(35, 38, 48)

f_zoneName(_m) =>
    _m <= deepLevel ? "Deep Buy" :
     _m <= accumLevel ? "Accumulation" :
     _m < hotLevel ? "Normal Range" :
     "Overheated"

f_zoneColor(_m) =>
    _m <= deepLevel ? deepColor :
     _m <= accumLevel ? accumColor :
     _m < hotLevel ? fairColor :
     hotColor

f_fmt(_v) =>
    na(_v) ? "na" : str.tostring(_v, "#.##")

f_fmt3(_v) =>
    na(_v) ? "na" : str.tostring(_v, "#.###")

f_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     position.top_right

//====================================================
// OPTIONAL MAIN-CHART PRICE LEVELS
//====================================================

plot(showPriceLvls ? deepPrice : na, "0.5 Deep Buy Price", color=color.new(deepColor, 0), linewidth=2)
plot(showPriceLvls ? accumPrice : na, "0.8 Accumulation Price", color=color.new(accumColor, 0), linewidth=1)
plot(showPriceLvls ? hotPrice : na, "2.4 Overheated Price", color=color.new(hotColor, 0), linewidth=1)

//====================================================
// DASHBOARD TABLE
//====================================================

var table dash = table.new(f_pos(tablePos), 2, 9, border_width=1)

if barstate.islast
    zName = f_zoneName(mayer)
    zCol  = f_zoneColor(mayer)

    table.cell(dash, 0, 0, "BTC Mayer Dashboard", text_color=color.white, bgcolor=headBg)
    table.cell(dash, 1, 0, "Simple View", text_color=color.white, bgcolor=headBg)

    table.cell(dash, 0, 1, "Source", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 1, calcSymbol, text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 2, "BTC Price", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 2, "$" + f_fmt(dClose), text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 3, "365D MA", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 3, "$" + f_fmt(dMa365), text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 4, "Mayer Multiple", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 4, f_fmt3(mayer), text_color=color.white, bgcolor=zCol)

    table.cell(dash, 0, 5, "Current Zone", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 5, zName, text_color=color.white, bgcolor=zCol)

    table.cell(dash, 0, 6, "0.5 Deep Buy", text_color=color.white, bgcolor=color.new(deepColor, 20))
    table.cell(dash, 1, 6, "$" + f_fmt(deepPrice), text_color=color.white, bgcolor=color.new(deepColor, 20))

    table.cell(dash, 0, 7, "0.8 Accumulation", text_color=color.white, bgcolor=color.new(accumColor, 25))
    table.cell(dash, 1, 7, "$" + f_fmt(accumPrice), text_color=color.white, bgcolor=color.new(accumColor, 25))

    table.cell(dash, 0, 8, "2.4 Overheated", text_color=color.white, bgcolor=color.new(hotColor, 20))
    table.cell(dash, 1, 8, "$" + f_fmt(hotPrice), text_color=color.white, bgcolor=color.new(hotColor, 20))
````
