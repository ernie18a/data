# Edge Scanner v4

- url: https://www.tradingview.com/script/NuDlt8RJ-Edge-Scanner-v4/
- type: indicator
- pine_id: PUB;ee80030207e9484fbb6b077f5cd8c837
- version: 1.0

## Description

follow your favorite coins near supply and demand lines

## Source Code

````pine
//@version=6
indicator("Edge Scanner v3", overlay=true)

//=====================
// Inputs
//=====================
scanTf      = input.timeframe("15", "Scan Timeframe")
lookback    = input.int(12, "Range Lookback", minval=5)
edgePercent = input.float(30.0, "Edge Zone %", minval=1.0, maxval=49.0, step=1.0)
tablePos    = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// Table size option
tableTextSize = input.string("Large", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

f_textSize() =>
    tableTextSize == "Tiny" ? size.tiny :
     tableTextSize == "Small" ? size.small :
     tableTextSize == "Normal" ? size.normal :
     tableTextSize == "Huge" ? size.huge :
     size.large

// Symbols
sym1  = input.symbol("BINANCE:BTCUSDT",  "Symbol 1")
sym2  = input.symbol("BINANCE:ETHUSDT",  "Symbol 2")
sym3  = input.symbol("BINANCE:SOLUSDT",  "Symbol 3")
sym4  = input.symbol("BINANCE:ICPUSDT",  "Symbol 4")
sym5  = input.symbol("BINANCE:ADAUSDT",  "Symbol 5")
sym6  = input.symbol("BINANCE:DOGEUSDT", "Symbol 6")
sym7  = input.symbol("BINANCE:LINKUSDT", "Symbol 7")
sym8  = input.symbol("BINANCE:AVAXUSDT", "Symbol 8")
sym9  = input.symbol("BINANCE:PEPEUSDT", "Symbol 9")
sym10 = input.symbol("BINANCE:XRPUSDT",  "Symbol 10")

//=====================
// Table position
//=====================
f_tablePos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

var table edgeTable = table.new(f_tablePos(tablePos), 6, 11, border_width=1, border_color=color.rgb(90, 90, 90))

//=====================
// Helpers
//=====================
f_rangeHigh() =>
    ta.highest(high, lookback)

f_rangeLow() =>
    ta.lowest(low, lookback)

f_priceInRangePercent(_price, _low, _high) =>
    _high > _low ? ((_price - _low) / (_high - _low)) * 100.0 : na

f_location(_price, _low, _high, _edgePct) =>
    _range = _high - _low
    _topZone = _high - (_range * (_edgePct / 100.0))
    _bottomZone = _low + (_range * (_edgePct / 100.0))
    _high <= _low ? "Waiting" :
     _price >= _topZone ? "Near High" :
     _price <= _bottomZone ? "Near Low" :
     "Middle"

f_bias(_price, _low, _high) =>
    _mid = (_high + _low) / 2.0
    _high <= _low ? "Neutral" :
     _price > _mid ? "Bullish" :
     _price < _mid ? "Bearish" :
     "Neutral"

f_action(_loc, _bias, _pct) =>
    _loc == "Near Low" and _bias == "Bullish" and _pct <= 10 ? "Strong Long" :
     _loc == "Near High" and _bias == "Bearish" and _pct >= 90 ? "Strong Short" :
     _loc == "Near Low" and _bias == "Bullish" ? "Look Long" :
     _loc == "Near High" and _bias == "Bearish" ? "Look Short" :
     _loc == "Near High" ? "Caution" :
     _loc == "Near Low" ? "Watch Bounce" :
     "Wait"

// brighter text colors
f_locColor(_loc) =>
    _loc == "Near High" ? color.rgb(255, 55, 55) :
     _loc == "Near Low" ? color.rgb(0, 255, 120) :
     _loc == "Middle" ? color.rgb(255, 240, 0) :
     color.rgb(180, 180, 180)

f_biasColor(_bias) =>
    _bias == "Bullish" ? color.rgb(0, 255, 80) :
     _bias == "Bearish" ? color.rgb(255, 65, 65) :
     color.rgb(220, 220, 220)

f_actionColor(_action) =>
    _action == "Strong Long" ? color.rgb(0, 255, 120) :
     _action == "Strong Short" ? color.rgb(255, 55, 55) :
     _action == "Look Long" ? color.rgb(0, 255, 120) :
     _action == "Look Short" ? color.rgb(255, 55, 55) :
     _action == "Caution" ? color.rgb(255, 165, 0) :
     _action == "Watch Bounce" ? color.rgb(0, 230, 255) :
     color.rgb(240, 240, 240)

// better row backgrounds
f_rowBg(_loc, _pct) =>
    _loc == "Near High" and _pct >= 90 ? color.rgb(75, 0, 0) :
     _loc == "Near Low" and _pct <= 10 ? color.rgb(0, 55, 20) :
     _loc == "Near High" ? color.rgb(48, 10, 10) :
     _loc == "Near Low" ? color.rgb(5, 38, 18) :
     color.rgb(18, 22, 30)

f_shortName(_sym) =>
    str.replace_all(str.replace_all(_sym, "BINANCE:", ""), "USDT", "")

f_fillRow(_row, _sym) =>
    _symbol = _sym

    _close = request.security(_symbol, scanTf, close)
    _high  = request.security(_symbol, scanTf, f_rangeHigh())
    _low   = request.security(_symbol, scanTf, f_rangeLow())

    _loc    = f_location(_close, _low, _high, edgePercent)
    _pct    = f_priceInRangePercent(_close, _low, _high)
    _biasV  = f_bias(_close, _low, _high)
    _action = f_action(_loc, _biasV, _pct)

    _priceText = na(_close) ? "na" : str.tostring(_close)
    _pctText   = na(_pct) ? "na" : str.tostring(math.round(_pct)) + "%"
    _bg = f_rowBg(_loc, _pct)

    table.cell(edgeTable, 0, _row, f_shortName(_sym), text_color=color.white, bgcolor=_bg, text_size=f_textSize())
    table.cell(edgeTable, 1, _row, _priceText, text_color=color.white, bgcolor=_bg, text_size=f_textSize())
    table.cell(edgeTable, 2, _row, _loc, text_color=f_locColor(_loc), bgcolor=_bg, text_size=f_textSize())
    table.cell(edgeTable, 3, _row, _biasV, text_color=f_biasColor(_biasV), bgcolor=_bg, text_size=f_textSize())
    table.cell(edgeTable, 4, _row, _action, text_color=f_actionColor(_action), bgcolor=_bg, text_size=f_textSize())
    table.cell(edgeTable, 5, _row, _pctText, text_color=color.white, bgcolor=_bg, text_size=f_textSize())

//=====================
// Header
//=====================
if barstate.isfirst
    _headerBg = color.rgb(0, 0, 0)
    table.cell(edgeTable, 0, 0, "Symbol",   text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())
    table.cell(edgeTable, 1, 0, "Price",    text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())
    table.cell(edgeTable, 2, 0, "Location", text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())
    table.cell(edgeTable, 3, 0, "Bias",     text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())
    table.cell(edgeTable, 4, 0, "Action",   text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())
    table.cell(edgeTable, 5, 0, "% Range",  text_color=color.white, bgcolor=_headerBg, text_size=f_textSize())

//=====================
// Refresh table
//=====================
f_fillRow(1, sym1)
f_fillRow(2, sym2)
f_fillRow(3, sym3)
f_fillRow(4, sym4)
f_fillRow(5, sym5)
f_fillRow(6, sym6)
f_fillRow(7, sym7)
f_fillRow(8, sym8)
f_fillRow(9, sym9)
f_fillRow(10, sym10)
````
