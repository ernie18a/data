# Quanloki QQE + Smart TP/SL + Points Counter - Highlighted Table

- url: https://www.tradingview.com/script/Doc6ZYai/
- type: indicator
- pine_id: PUB;7220c74a305f4ead8d0f7a73634334df
- version: 1.0

## Description

Quanloki QQE + Smart TP/SL + Points Counter - Highlighted Table

## Source Code

````pine
//@version=6
indicator("Quanloki QQE + Smart TP/SL + Points Counter - Highlighted Table", overlay=true, max_labels_count=500)

// === Inputs ===
RSI_Period = input.int(14, "RSI Length")
SF = input.int(5, "RSI Smoothing")
QQE = input.float(4.238, "Fast QQE Factor")

showTPSL = input.bool(true, "Pokaż TP/SL")
showStats = input.bool(true, "Pokaż tabelę punktów")

entryPriceType = input.string("close", "Entry Price", options=["open", "close", "open_next"])

useTP = input.bool(true, "Zamykaj po TP")
useSL = input.bool(true, "Zamykaj po SL")
useOppositeExit = input.bool(true, "Zamykaj po sygnale przeciwnym")

pivotLen = input.int(5, "Pivot Length")

// === Core QQE ===
src = close
Wilders_Period = RSI_Period * 2 - 1

Rsi = ta.rsi(src, RSI_Period)
RsiMa = ta.ema(Rsi, SF)
AtrRsi = math.abs(RsiMa[1] - RsiMa)
MaAtrRsi = ta.ema(AtrRsi, Wilders_Period)
dar = ta.ema(MaAtrRsi, Wilders_Period) * QQE

var float longband = na
var float shortband = na
var int trend = 0

DeltaFastAtrRsi = dar
RSIndex = RsiMa
newshortband = RSIndex + DeltaFastAtrRsi
newlongband = RSIndex - DeltaFastAtrRsi

longband := RSIndex[1] > nz(longband[1]) and RSIndex > nz(longband[1]) ? math.max(nz(longband[1]), newlongband) : newlongband
shortband := RSIndex[1] < nz(shortband[1]) and RSIndex < nz(shortband[1]) ? math.min(nz(shortband[1]), newshortband) : newshortband

cross_1 = ta.cross(longband[1], RSIndex)
trend := ta.cross(RSIndex, shortband[1]) ? 1 : cross_1 ? -1 : nz(trend[1], 1)

FastAtrRsiTL = trend == 1 ? longband : shortband

// === Entry signals ===
QQExlong = FastAtrRsiTL < RSIndex and FastAtrRsiTL[1] >= RSIndex[1]
QQExshort = FastAtrRsiTL > RSIndex and FastAtrRsiTL[1] <= RSIndex[1]

// === Dynamic Support / Resistance ===
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPH = na
var float lastPL = na

if not na(ph)
    lastPH := ph

if not na(pl)
    lastPL := pl

// === Virtual trade state ===
var int pos = 0
var float entryPrice = na
var float tradeTP = na
var float tradeSL = na
var int entryBar = na

var float totalPoints = 0.0
var float lastPoints = 0.0
var int trades = 0
var int wins = 0
var int losses = 0

var int pendingDir = 0

// === Entry execution price ===
f_entry_price() =>
    entryPriceType == "open" ? open : close

// === Close trade function ===
f_close_trade(_exitPrice, _reason) =>
    float pts = pos == 1 ? _exitPrice - entryPrice : entryPrice - _exitPrice
    pts

// === Execute pending open_next entry ===
if pendingDir != 0 and pos == 0
    pos := pendingDir
    entryPrice := open
    entryBar := bar_index

    tradeTP := pendingDir == 1 ? lastPH : lastPL
    tradeSL := pendingDir == 1 ? lastPL : lastPH

    label.new(bar_index, entryPrice,
         pendingDir == 1 ? "LONG\n" + str.tostring(entryPrice, format.mintick) : "SHORT\n" + str.tostring(entryPrice, format.mintick),
         style=pendingDir == 1 ? label.style_label_up : label.style_label_down,
         color=pendingDir == 1 ? color.new(color.green, 0) : color.new(color.red, 0),
         textcolor=color.white,
         yloc=pendingDir == 1 ? yloc.belowbar : yloc.abovebar)

    if showTPSL
        if not na(tradeSL)
            label.new(bar_index, tradeSL, "SL\n" + str.tostring(tradeSL, format.mintick),
                 style=label.style_label_down, color=color.new(color.red, 60), textcolor=color.white)
        if not na(tradeTP)
            label.new(bar_index, tradeTP, "TP\n" + str.tostring(tradeTP, format.mintick),
                 style=label.style_label_up, color=color.new(color.green, 60), textcolor=color.white)

    pendingDir := 0

// === Exit logic ===
exitNow = false
exitPrice = close
exitReason = ""

if pos == 1
    if useSL and not na(tradeSL) and low <= tradeSL
        exitNow := true
        exitPrice := tradeSL
        exitReason := "SL"
    else if useTP and not na(tradeTP) and high >= tradeTP
        exitNow := true
        exitPrice := tradeTP
        exitReason := "TP"
    else if useOppositeExit and QQExshort
        exitNow := true
        exitPrice := close
        exitReason := "REV"

if pos == -1
    if useSL and not na(tradeSL) and high >= tradeSL
        exitNow := true
        exitPrice := tradeSL
        exitReason := "SL"
    else if useTP and not na(tradeTP) and low <= tradeTP
        exitNow := true
        exitPrice := tradeTP
        exitReason := "TP"
    else if useOppositeExit and QQExlong
        exitNow := true
        exitPrice := close
        exitReason := "REV"

if exitNow and pos != 0
    lastPoints := f_close_trade(exitPrice, exitReason)
    totalPoints += lastPoints
    trades += 1

    if lastPoints > 0
        wins += 1
    else
        losses += 1

    label.new(bar_index, exitPrice,
         exitReason + "\n" + str.tostring(lastPoints, format.mintick) + " pkt",
         style=label.style_label_left,
         color=lastPoints >= 0 ? color.new(color.green, 0) : color.new(color.red, 0),
         textcolor=color.white)

    pos := 0
    entryPrice := na
    tradeTP := na
    tradeSL := na
    entryBar := na

// === New entries ===
canEnter = pos == 0 and pendingDir == 0

if canEnter and QQExlong
    if entryPriceType == "open_next"
        pendingDir := 1
    else
        pos := 1
        entryPrice := f_entry_price()
        entryBar := bar_index
        tradeTP := lastPH
        tradeSL := lastPL

        label.new(bar_index, entryPrice,
             "LONG\n" + str.tostring(entryPrice, format.mintick),
             style=label.style_label_up, color=color.new(color.green, 0),
             textcolor=color.white, yloc=yloc.belowbar)

        if showTPSL
            if not na(tradeSL)
                label.new(bar_index, tradeSL, "SL\n" + str.tostring(tradeSL, format.mintick),
                     style=label.style_label_down, color=color.new(color.red, 60), textcolor=color.white)
            if not na(tradeTP)
                label.new(bar_index, tradeTP, "TP\n" + str.tostring(tradeTP, format.mintick),
                     style=label.style_label_up, color=color.new(color.green, 60), textcolor=color.white)

if canEnter and QQExshort
    if entryPriceType == "open_next"
        pendingDir := -1
    else
        pos := -1
        entryPrice := f_entry_price()
        entryBar := bar_index
        tradeTP := lastPL
        tradeSL := lastPH

        label.new(bar_index, entryPrice,
             "SHORT\n" + str.tostring(entryPrice, format.mintick),
             style=label.style_label_down, color=color.new(color.red, 0),
             textcolor=color.white, yloc=yloc.abovebar)

        if showTPSL
            if not na(tradeSL)
                label.new(bar_index, tradeSL, "SL\n" + str.tostring(tradeSL, format.mintick),
                     style=label.style_label_up, color=color.new(color.red, 60), textcolor=color.white)
            if not na(tradeTP)
                label.new(bar_index, tradeTP, "TP\n" + str.tostring(tradeTP, format.mintick),
                     style=label.style_label_down, color=color.new(color.green, 60), textcolor=color.white)

// === Plot active TP/SL ===
plot(pos != 0 ? tradeTP : na, "Active TP", color=color.new(color.green, 0), style=plot.style_linebr)
plot(pos != 0 ? tradeSL : na, "Active SL", color=color.new(color.red, 0), style=plot.style_linebr)
plot(pos != 0 ? entryPrice : na, "Entry", color=color.new(color.blue, 0), style=plot.style_linebr)

// === Stats Table - Highlighted ===
var table stats = table.new(
     position.top_right,
     2,
     7,
     border_width = 3,
     frame_color = color.yellow,
     frame_width = 3)

winrate = trades > 0 ? wins * 100.0 / trades : na
openPoints = pos == 1 ? close - entryPrice : pos == -1 ? entryPrice - close : na

if showStats and barstate.islast
    totalColor = totalPoints >= 0 ? color.lime : color.red
    lastColor = lastPoints >= 0 ? color.lime : color.red
    openColor = na(openPoints) ? color.gray : openPoints >= 0 ? color.lime : color.red
    wrColor = na(winrate) ? color.gray : winrate >= 50 ? color.lime : color.red

    table.cell(stats, 0, 0, "QQE SYSTEM", bgcolor=color.black, text_color=color.yellow, text_size=size.large)
    table.cell(stats, 1, 0, "STATS", bgcolor=color.black, text_color=color.yellow, text_size=size.large)

    table.cell(stats, 0, 1, "SUMA PKT", bgcolor=color.rgb(15,15,15), text_color=color.white, text_size=size.normal)
    table.cell(stats, 1, 1, str.tostring(totalPoints, "#.##"), bgcolor=totalColor, text_color=color.black, text_size=size.huge)

    table.cell(stats, 0, 2, "OSTATNI", bgcolor=color.rgb(15,15,15), text_color=color.white)
    table.cell(stats, 1, 2, str.tostring(lastPoints, "#.##"), bgcolor=lastColor, text_color=color.black, text_size=size.large)

    table.cell(stats, 0, 3, "OPEN", bgcolor=color.rgb(15,15,15), text_color=color.white)
    table.cell(stats, 1, 3, pos != 0 ? str.tostring(openPoints, "#.##") : "-", bgcolor=openColor, text_color=color.black, text_size=size.large)

    table.cell(stats, 0, 4, "TRADES", bgcolor=color.rgb(15,15,15), text_color=color.white)
    table.cell(stats, 1, 4, str.tostring(trades), bgcolor=color.silver, text_color=color.black, text_size=size.large)

    table.cell(stats, 0, 5, "WIN / LOSS", bgcolor=color.rgb(15,15,15), text_color=color.white)
    table.cell(stats, 1, 5, str.tostring(wins) + " / " + str.tostring(losses), bgcolor=color.orange, text_color=color.black, text_size=size.large)

    table.cell(stats, 0, 6, "WINRATE", bgcolor=color.rgb(15,15,15), text_color=color.white)
    table.cell(stats, 1, 6, trades > 0 ? str.tostring(winrate, "#.##") + "%" : "-", bgcolor=wrColor, text_color=color.black, text_size=size.huge)

// === Alerts ===
alertcondition(QQExlong, title="Long", message="QQE Long Signal")
alertcondition(QQExshort, title="Short", message="QQE Short Signal")
````
