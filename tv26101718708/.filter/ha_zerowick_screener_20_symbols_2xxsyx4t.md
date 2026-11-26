# HA Zero-Wick Screener (20 Symbols)

- url: https://www.tradingview.com/script/2xXsYx4T-HA-Zero-Wick-Screener-20-Symbols/
- type: indicator
- pine_id: PUB;61cd084cc5e24933ab307eeb1c132ee6
- version: 1.0

## Description

Heikin Ashi terms:

Bullish setup: Previous HA candle is green (bullish) with no lower wick (HA_Open = HA_Low, i.e., a "clean" green candle), AND current HA candle is also green and closes above the previous candle's close.
Bearish setup: Previous HA candle is red (bearish) with no upper wick (HA_Open = HA_High, i.e., a "clean" red candle), AND current HA candle is also red and closes below the previous candle's close.

Before I write the Pine Script, let me check a couple of things with you.Q: For the 'no wick' condition, how strict should it be?
A: Exactly zero wick (HA_Open = HA_Low/High exactly)Q: What format do you want the final output in?
A: Pine Script strategy/indicator with a screener table (shows on chart)Q: Do you want this to scan a fixed watchlist of symbols you input, or work as an indicator applied per-chart (and you use TradingView's built-in Screener with 'Add indicator' filter)?
A: Fixed list of symbols typed into the script (table shows all at once)Show moreNow I'll build a Pine Script indicator that:

Lets you type in a list of symbols (editable in settings, plus an on-chart way to note which ones you're tracking)
Computes Heikin Ashi values for each symbol using request.security
Checks your exact bullish/bearish wick conditions
Displays everything in a clean table on the chart

A few technical notes before the code:

Exact zero wick on Heikin Ashi is rare on live/unclosed candles (HA smooths values), so I'll check it on the last closed bar to get true zero-wick detection, and I'll also add a tiny epsilon-safe comparison purely to avoid floating point rounding issues (not a "tolerance" for the pattern itself — this is standard practice for equality checks in Pine).
TradingView limits request.security calls — a table-based multi-symbol screener can safely hold around 40 symbols per script. I'll set it up so you can easily edit the list.
I'll show: Symbol, Last Close, Signal (Bullish/Bearish/None), and the candle color for context.

Let me write this now.Ran 2 commands, created a file, read a fileRan 2 commands, created a file, read a fileHow to use it:

Open TradingView → Pine Editor → paste the script → "Add to Chart."
Click the gear icon (settings) on the indicator → edit the Symbols field (comma-separated, e.g. NSE:RELIANCE,NSE:TCS,...) to add/remove tickers.
Choose your Timeframe (defaults to Daily) and toggle "Show only rows with a signal" to filter the table down to just Bullish/Bearish hits.

How the logic works:

Bullish: previous HA candle is green with HA_Open == HA_Low (zero lower wick) AND current HA candle is green AND current HA close > previous HA close.
Bearish: previous HA candle is red with HA_Open == HA_High (zero upper wick) AND current HA candle is red AND current HA close < previous HA close.
Table shows Symbol, Last Close, HA candle color, and Signal, color-coded (green row = bullish, red row = bearish).

Important limitations to know:

TradingView caps request.security calls per script at 40. The script above has 10 example symbols — you can extend up to 40 total before it'll throw an error. If you need more, you'd need multiple copies of the script or TradingView's actual Stock Screener with a custom Pine screener script (separate product from indicators, works differently).
Exact-zero-wick is a strict condition — on many stocks this will rarely trigger since HA candles usually have at least a tiny wick. If you find signals are too rare, you may want to loosen this later (I can add a small tolerance % as an input if needed).
This works as a chart overlay, not inside TradingView's native "Screener" UI panel — it's a table drawn on whatever chart you apply it to, showing all your symbols regardless of which chart is open.

## Source Code

````pine
//@version=6
indicator("HA Zero-Wick Screener (20 Symbols)", overlay = true, max_labels_count = 500)

// ============================================================================
// SYMBOLS — up to 20 slots. Leave a slot's "Enable" box unchecked to skip it.
// (Pine Script requires request.security's symbol argument to be a "simple
// string" set directly by an input — a pasted/looped list cannot satisfy
// this, which is why each slot is its own field.)
// ============================================================================
sym1  = input.symbol("NSE:RELIANCE",  "Symbol 1")
use1  = input.bool(true, "Enable 1", inline = "e1")
sym2  = input.symbol("NSE:TCS",       "Symbol 2")
use2  = input.bool(true, "Enable 2", inline = "e2")
sym3  = input.symbol("NSE:INFY",      "Symbol 3")
use3  = input.bool(true, "Enable 3", inline = "e3")
sym4  = input.symbol("NSE:HDFCBANK",  "Symbol 4")
use4  = input.bool(true, "Enable 4", inline = "e4")
sym5  = input.symbol("NSE:ICICIBANK", "Symbol 5")
use5  = input.bool(true, "Enable 5", inline = "e5")
sym6  = input.symbol("NSE:SBIN",      "Symbol 6")
use6  = input.bool(true, "Enable 6", inline = "e6")
sym7  = input.symbol("NSE:AXISBANK",  "Symbol 7")
use7  = input.bool(true, "Enable 7", inline = "e7")
sym8  = input.symbol("NSE:ITC",       "Symbol 8")
use8  = input.bool(true, "Enable 8", inline = "e8")
sym9  = input.symbol("NSE:LT",        "Symbol 9")
use9  = input.bool(true, "Enable 9", inline = "e9")
sym10 = input.symbol("NSE:KOTAKBANK", "Symbol 10")
use10 = input.bool(true, "Enable 10", inline = "e10")
sym11 = input.symbol("NSE:BAJFINANCE","Symbol 11")
use11 = input.bool(false, "Enable 11", inline = "e11")
sym12 = input.symbol("NSE:MARUTI",    "Symbol 12")
use12 = input.bool(false, "Enable 12", inline = "e12")
sym13 = input.symbol("NSE:SUNPHARMA", "Symbol 13")
use13 = input.bool(false, "Enable 13", inline = "e13")
sym14 = input.symbol("NSE:TATAMOTORS","Symbol 14")
use14 = input.bool(false, "Enable 14", inline = "e14")
sym15 = input.symbol("NSE:WIPRO",     "Symbol 15")
use15 = input.bool(false, "Enable 15", inline = "e15")
sym16 = input.symbol("NSE:HCLTECH",   "Symbol 16")
use16 = input.bool(false, "Enable 16", inline = "e16")
sym17 = input.symbol("NSE:ADANIENT",  "Symbol 17")
use17 = input.bool(false, "Enable 17", inline = "e17")
sym18 = input.symbol("NSE:ONGC",      "Symbol 18")
use18 = input.bool(false, "Enable 18", inline = "e18")
sym19 = input.symbol("NSE:NTPC",      "Symbol 19")
use19 = input.bool(false, "Enable 19", inline = "e19")
sym20 = input.symbol("NSE:POWERGRID", "Symbol 20")
use20 = input.bool(false, "Enable 20", inline = "e20")

tf = input.timeframe("D", "Timeframe for HA analysis")
showOnlySignals = input.bool(false, "Show only rows with a signal (Bullish/Bearish)")
tablePosition = input.string("top_right", "Table Position", options = ["top_right", "top_left", "bottom_right", "bottom_left"])

// ============================================================================
// HA signal helper (pure function — no request.security inside)
// ============================================================================
f_haSignal(float o, float h, float l, float c) =>
    var float haClose = na
    var float haOpen  = na
    var float haHigh  = na
    var float haLow   = na

    haClose := (o + h + l + c) / 4.0
    haOpen  := na(haOpen[1]) ? (o + c) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
    haHigh  := math.max(h, math.max(haOpen, haClose))
    haLow   := math.min(l, math.min(haOpen, haClose))

    isGreen = haClose >= haOpen
    isRed   = haClose < haOpen

    noLowerWick = haOpen == haLow
    noUpperWick = haOpen == haHigh

    prevIsGreen     = isGreen[1]
    prevIsRed       = isRed[1]
    prevNoLowerWick = noLowerWick[1]
    prevNoUpperWick = noUpperWick[1]
    prevClose       = haClose[1]

    bullishSignal = prevIsGreen and prevNoLowerWick and isGreen and (haClose > prevClose)
    bearishSignal = prevIsRed and prevNoUpperWick and isRed and (haClose < prevClose)

    signalText = bullishSignal ? "BULLISH" : bearishSignal ? "BEARISH" : "-"
    colorText  = isGreen ? "Green" : "Red"

    [haClose, signalText, colorText, bullishSignal, bearishSignal]

// ============================================================================
// Top-level request.security calls — one per symbol slot, unconditional
// ============================================================================
[o1, h1, l1, c1]   = request.security(sym1, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o2, h2, l2, c2]   = request.security(sym2, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o3, h3, l3, c3]   = request.security(sym3, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o4, h4, l4, c4]   = request.security(sym4, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o5, h5, l5, c5]   = request.security(sym5, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o6, h6, l6, c6]   = request.security(sym6, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o7, h7, l7, c7]   = request.security(sym7, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o8, h8, l8, c8]   = request.security(sym8, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o9, h9, l9, c9]   = request.security(sym9, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o10, h10, l10, c10] = request.security(sym10, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o11, h11, l11, c11] = request.security(sym11, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o12, h12, l12, c12] = request.security(sym12, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o13, h13, l13, c13] = request.security(sym13, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o14, h14, l14, c14] = request.security(sym14, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o15, h15, l15, c15] = request.security(sym15, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o16, h16, l16, c16] = request.security(sym16, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o17, h17, l17, c17] = request.security(sym17, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o18, h18, l18, c18] = request.security(sym18, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o19, h19, l19, c19] = request.security(sym19, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)
[o20, h20, l20, c20] = request.security(sym20, tf, [open, high, low, close], lookahead = barmerge.lookahead_off)

[close1, sig1, col1, bull1, bear1]     = f_haSignal(o1, h1, l1, c1)
[close2, sig2, col2, bull2, bear2]     = f_haSignal(o2, h2, l2, c2)
[close3, sig3, col3, bull3, bear3]     = f_haSignal(o3, h3, l3, c3)
[close4, sig4, col4, bull4, bear4]     = f_haSignal(o4, h4, l4, c4)
[close5, sig5, col5, bull5, bear5]     = f_haSignal(o5, h5, l5, c5)
[close6, sig6, col6, bull6, bear6]     = f_haSignal(o6, h6, l6, c6)
[close7, sig7, col7, bull7, bear7]     = f_haSignal(o7, h7, l7, c7)
[close8, sig8, col8, bull8, bear8]     = f_haSignal(o8, h8, l8, c8)
[close9, sig9, col9, bull9, bear9]     = f_haSignal(o9, h9, l9, c9)
[close10, sig10, col10, bull10, bear10] = f_haSignal(o10, h10, l10, c10)
[close11, sig11, col11, bull11, bear11] = f_haSignal(o11, h11, l11, c11)
[close12, sig12, col12, bull12, bear12] = f_haSignal(o12, h12, l12, c12)
[close13, sig13, col13, bull13, bear13] = f_haSignal(o13, h13, l13, c13)
[close14, sig14, col14, bull14, bear14] = f_haSignal(o14, h14, l14, c14)
[close15, sig15, col15, bull15, bear15] = f_haSignal(o15, h15, l15, c15)
[close16, sig16, col16, bull16, bear16] = f_haSignal(o16, h16, l16, c16)
[close17, sig17, col17, bull17, bear17] = f_haSignal(o17, h17, l17, c17)
[close18, sig18, col18, bull18, bear18] = f_haSignal(o18, h18, l18, c18)
[close19, sig19, col19, bull19, bear19] = f_haSignal(o19, h19, l19, c19)
[close20, sig20, col20, bull20, bear20] = f_haSignal(o20, h20, l20, c20)

// ============================================================================
// Table rendering
// ============================================================================
tablePosResolved = tablePosition == "top_right" ? position.top_right : tablePosition == "top_left" ? position.top_left : tablePosition == "bottom_right" ? position.bottom_right : position.bottom_left

var table screenerTable = table.new(tablePosResolved, 4, 21, border_width = 1, frame_color = color.gray, frame_width = 1)

f_addRow(table t, int rowIdx, string symName, float lastClose, string colText, string sigText, bool isBull, bool isBear) =>
    rowBg = isBull ? color.new(color.green, 80) : isBear ? color.new(color.red, 80) : color.new(color.gray, 90)
    sigColor = isBull ? color.lime : isBear ? color.red : color.gray
    table.cell(t, 0, rowIdx, symName, bgcolor = rowBg, text_color = color.white)
    table.cell(t, 1, rowIdx, na(lastClose) ? "-" : str.tostring(lastClose, format.mintick), bgcolor = rowBg, text_color = color.white)
    table.cell(t, 2, rowIdx, colText, bgcolor = rowBg, text_color = colText == "Green" ? color.lime : color.red)
    table.cell(t, 3, rowIdx, sigText, bgcolor = rowBg, text_color = sigColor)

if barstate.islast
    table.cell(screenerTable, 0, 0, "Symbol", bgcolor = color.new(color.gray, 0), text_color = color.white)
    table.cell(screenerTable, 1, 0, "Last Close", bgcolor = color.new(color.gray, 0), text_color = color.white)
    table.cell(screenerTable, 2, 0, "HA Color", bgcolor = color.new(color.gray, 0), text_color = color.white)
    table.cell(screenerTable, 3, 0, "Signal", bgcolor = color.new(color.gray, 0), text_color = color.white)

    var int rowIdx = 1
    rowIdx := 1

    if use1 and (not showOnlySignals or bull1 or bear1)
        f_addRow(screenerTable, rowIdx, sym1, close1, col1, sig1, bull1, bear1)
        rowIdx := rowIdx + 1
    if use2 and (not showOnlySignals or bull2 or bear2)
        f_addRow(screenerTable, rowIdx, sym2, close2, col2, sig2, bull2, bear2)
        rowIdx := rowIdx + 1
    if use3 and (not showOnlySignals or bull3 or bear3)
        f_addRow(screenerTable, rowIdx, sym3, close3, col3, sig3, bull3, bear3)
        rowIdx := rowIdx + 1
    if use4 and (not showOnlySignals or bull4 or bear4)
        f_addRow(screenerTable, rowIdx, sym4, close4, col4, sig4, bull4, bear4)
        rowIdx := rowIdx + 1
    if use5 and (not showOnlySignals or bull5 or bear5)
        f_addRow(screenerTable, rowIdx, sym5, close5, col5, sig5, bull5, bear5)
        rowIdx := rowIdx + 1
    if use6 and (not showOnlySignals or bull6 or bear6)
        f_addRow(screenerTable, rowIdx, sym6, close6, col6, sig6, bull6, bear6)
        rowIdx := rowIdx + 1
    if use7 and (not showOnlySignals or bull7 or bear7)
        f_addRow(screenerTable, rowIdx, sym7, close7, col7, sig7, bull7, bear7)
        rowIdx := rowIdx + 1
    if use8 and (not showOnlySignals or bull8 or bear8)
        f_addRow(screenerTable, rowIdx, sym8, close8, col8, sig8, bull8, bear8)
        rowIdx := rowIdx + 1
    if use9 and (not showOnlySignals or bull9 or bear9)
        f_addRow(screenerTable, rowIdx, sym9, close9, col9, sig9, bull9, bear9)
        rowIdx := rowIdx + 1
    if use10 and (not showOnlySignals or bull10 or bear10)
        f_addRow(screenerTable, rowIdx, sym10, close10, col10, sig10, bull10, bear10)
        rowIdx := rowIdx + 1
    if use11 and (not showOnlySignals or bull11 or bear11)
        f_addRow(screenerTable, rowIdx, sym11, close11, col11, sig11, bull11, bear11)
        rowIdx := rowIdx + 1
    if use12 and (not showOnlySignals or bull12 or bear12)
        f_addRow(screenerTable, rowIdx, sym12, close12, col12, sig12, bull12, bear12)
        rowIdx := rowIdx + 1
    if use13 and (not showOnlySignals or bull13 or bear13)
        f_addRow(screenerTable, rowIdx, sym13, close13, col13, sig13, bull13, bear13)
        rowIdx := rowIdx + 1
    if use14 and (not showOnlySignals or bull14 or bear14)
        f_addRow(screenerTable, rowIdx, sym14, close14, col14, sig14, bull14, bear14)
        rowIdx := rowIdx + 1
    if use15 and (not showOnlySignals or bull15 or bear15)
        f_addRow(screenerTable, rowIdx, sym15, close15, col15, sig15, bull15, bear15)
        rowIdx := rowIdx + 1
    if use16 and (not showOnlySignals or bull16 or bear16)
        f_addRow(screenerTable, rowIdx, sym16, close16, col16, sig16, bull16, bear16)
        rowIdx := rowIdx + 1
    if use17 and (not showOnlySignals or bull17 or bear17)
        f_addRow(screenerTable, rowIdx, sym17, close17, col17, sig17, bull17, bear17)
        rowIdx := rowIdx + 1
    if use18 and (not showOnlySignals or bull18 or bear18)
        f_addRow(screenerTable, rowIdx, sym18, close18, col18, sig18, bull18, bear18)
        rowIdx := rowIdx + 1
    if use19 and (not showOnlySignals or bull19 or bear19)
        f_addRow(screenerTable, rowIdx, sym19, close19, col19, sig19, bull19, bear19)
        rowIdx := rowIdx + 1
    if use20 and (not showOnlySignals or bull20 or bear20)
        f_addRow(screenerTable, rowIdx, sym20, close20, col20, sig20, bull20, bear20)
        rowIdx := rowIdx + 1
````
