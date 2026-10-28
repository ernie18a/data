# HAROLD PRO v3.1 - Institutional M/W/D + H4 Execution

- url: https://www.tradingview.com/script/GZHuTvdm/
- type: indicator
- pine_id: PUB;2975f29342bc4c2d8f10a4efb06b3a0f
- version: 1.0

## Description

institutional
orderblock
fibonacci
smart money
multi timeframe
momentum
trend analysis
bias

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © josehernandezvalcarcel

//@version=5
indicator("HAROLD PRO v3.1 - Institutional M/W/D + H4 Execution", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//========================
//=== TIMEFRAME SETUP ===
//========================
tfMonthly = "M"
tfWeekly  = "W"
tfDaily   = "D"
tfExec    = "240"

isExecTF  = timeframe.period == tfExec

tf = timeframe.period
showOBDaily   = timeframe.in_seconds(tf) <= timeframe.in_seconds("240")
showOBWeekly  = timeframe.in_seconds(tf) <= timeframe.in_seconds("D")
showOBMonthly = timeframe.in_seconds(tf) <= timeframe.in_seconds("W")

//========================
//=== INPUTS ============
//========================
showOB        = input.bool(true,  "Mostrar Order Blocks")
showFibo      = input.bool(true,  "Mostrar Fibo Semanal")
showPanel     = input.bool(true,  "Mostrar Tabla de Entradas")
useHybridExit = input.bool(true,  "Salida híbrida (Squeeze + Fibo + OB)")

useKillzone   = input.bool(false, "Filtrar por Killzones (London/NY)")
strictPDZone  = input.bool(true,  "Solo entrar en zona Premium/Discount válida")
lenSwing      = input.int(5,      "Longitud Swing Semanal", minval=2)
bosLen        = input.int(10,     "Lookback BOS Diario",    minval=3)

fib500  = 0.50
fib618  = 0.618
fib705  = 0.705
fib786  = 0.786
fib886  = 0.886
fib110  = 1.10
fib120  = 1.20
fib1272 = 1.272
fib130  = 1.30

//========================
//=== HTF DATA ==========
//========================
[mClose] = request.security(syminfo.tickerid, tfMonthly, [close], lookahead=barmerge.lookahead_off)
mMA = ta.sma(mClose, 10)
monthlyBull = not na(mMA) and mClose > mMA
monthlyBear = not na(mMA) and mClose < mMA

[wClose, wHigh, wLow] = request.security(syminfo.tickerid, tfWeekly, [close, high, low], lookahead=barmerge.lookahead_off)
wMA = ta.sma(wClose, 20)
weeklyBull = not na(wMA) and wClose > wMA
weeklyBear = not na(wMA) and wClose < wMA

[dHigh, dLow, dOpen, dClose] = request.security(syminfo.tickerid, tfDaily, [high, low, open, close], lookahead=barmerge.lookahead_off)

//========================
//=== IMPULSO SEMANAL + FIBO ===
//========================
wSwingHigh = ta.highest(wHigh[1], lenSwing)
wSwingLow  = ta.lowest(wLow[1],  lenSwing)

var float fibOrigin = na
var float fibTarget = na

if weeklyBull
    fibOrigin := wSwingLow
    fibTarget := wSwingHigh
else if weeklyBear
    fibOrigin := wSwingHigh
    fibTarget := wSwingLow

fibRange = fibTarget - fibOrigin

fibLvl500  = fibTarget - fibRange * fib500
fibLvl618  = fibTarget - fibRange * fib618
fibLvl705  = fibTarget - fibRange * fib705
fibLvl786  = fibTarget - fibRange * fib786
fibLvl886  = fibTarget - fibRange * fib886

fibLvl110  = fibTarget + fibRange * (fib110  - 1)
fibLvl120  = fibTarget + fibRange * (fib120  - 1)
fibLvl1272 = fibTarget + fibRange * (fib1272 - 1)
fibLvl130  = fibTarget + fibRange * (fib130  - 1)

inDiscount = close < fibLvl500
inPremium  = close > fibLvl500

fiboZoneTop    = math.max(fibLvl618, fibLvl886)
fiboZoneBottom = math.min(fibLvl618, fibLvl886)
inFiboZone     = close <= fiboZoneTop and close >= fiboZoneBottom

inFiboLong  = inFiboZone and (strictPDZone ? (weeklyBull and inDiscount) : weeklyBull)
inFiboShort = inFiboZone and (strictPDZone ? (weeklyBear and inPremium)  : weeklyBear)

var line lnFib500 = na
var line lnFib618 = na
var line lnFib705 = na
var line lnFib786 = na
var line lnFib886 = na
var line lnFibTgt = na

if showFibo and not na(fibTarget) and barstate.islast
    line.delete(lnFib500)
    line.delete(lnFib618)
    line.delete(lnFib705)
    line.delete(lnFib786)
    line.delete(lnFib886)
    line.delete(lnFibTgt)
    cF  = color.new(color.yellow, 40)
    cEq = color.new(color.aqua, 40)
    cTg = color.new(color.white, 60)
    lnFib500 := line.new(bar_index - 50, fibLvl500, bar_index, fibLvl500, extend=extend.right, color=cEq, width=1, style=line.style_dashed)
    lnFib618 := line.new(bar_index - 50, fibLvl618, bar_index, fibLvl618, extend=extend.right, color=cF, width=1)
    lnFib705 := line.new(bar_index - 50, fibLvl705, bar_index, fibLvl705, extend=extend.right, color=cF, width=1)
    lnFib786 := line.new(bar_index - 50, fibLvl786, bar_index, fibLvl786, extend=extend.right, color=cF, width=1)
    lnFib886 := line.new(bar_index - 50, fibLvl886, bar_index, fibLvl886, extend=extend.right, color=cF, width=1)
    lnFibTgt := line.new(bar_index - 50, fibLvl110, bar_index, fibLvl110, extend=extend.right, color=cTg, width=1, style=line.style_dotted)

//========================
//=== ORDER BLOCK DIARIO ===
//========================
bosUp   = dClose > ta.highest(dHigh[1], bosLen)
bosDown = dClose < ta.lowest(dLow[1],   bosLen)

var float obHighBull = na
var float obLowBull  = na
var float obHighBear = na
var float obLowBear  = na

if bosUp
    for i = 1 to 10
        if dClose[i] < dOpen[i]
            obHighBull := dHigh[i]
            obLowBull  := dLow[i]
            break

if bosDown
    for i = 1 to 10
        if dClose[i] > dOpen[i]
            obHighBear := dHigh[i]
            obLowBear  := dLow[i]
            break

if not na(obHighBull) and not na(obLowBull)
    obMidBull = (obHighBull + obLowBull) / 2
    if dClose < obMidBull
        obHighBull := na
        obLowBull  := na

if not na(obHighBear) and not na(obLowBear)
    obMidBear = (obHighBear + obLowBear) / 2
    if dClose > obMidBear
        obHighBear := na
        obLowBear  := na

// === FIX: Mostrar OB en una sola línea cada llamada ===
var box bxBull = na
var box bxBear = na

if showOB and showOBDaily and barstate.islast
    box.delete(bxBull)
    box.delete(bxBear)
    if not na(obHighBull) and not na(obLowBull)
        bxBull := box.new(bar_index - 30, obHighBull, bar_index + 10, obLowBull, bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 50))
    if not na(obHighBear) and not na(obLowBear)
        bxBear := box.new(bar_index - 30, obHighBear, bar_index + 10, obLowBear, bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 50))

//========================
//=== SQUEEZE MOMENTUM ===
//========================
lengthBB = 20
multBB   = 2.0
lengthKC = 20
multKC   = 1.5

src     = close
basis   = ta.sma(src, lengthBB)
dev     = multBB * ta.stdev(src, lengthBB)
upperBB = basis + dev
lowerBB = basis - dev

maKC    = ta.sma(src, lengthKC)
rangeKC = ta.atr(lengthKC) * multKC
upperKC = maKC + rangeKC
lowerKC = maKC - rangeKC

squeezeOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
squeezeOff = (lowerBB < lowerKC) and (upperBB > upperKC)

val = src - ta.sma(src, lengthKC)
mom = ta.linreg(val, lengthKC, 0)

momUp   = mom > 0 and mom > mom[1]
momDown = mom < 0 and mom < mom[1]

//========================
//=== KILLZONE FILTER ===
//========================
inLondon = hour(time, "America/New_York") >= 2 and hour(time, "America/New_York") < 5
inNY     = hour(time, "America/New_York") >= 7 and hour(time, "America/New_York") < 10
inKZ     = inLondon or inNY
kzFilter = useKillzone ? inKZ : true

//========================
//=== CONDICIONES H4 ===
//========================
inOBBull = not na(obHighBull) and not na(obLowBull) and close <= obHighBull and close >= obLowBull
inOBBear = not na(obHighBear) and not na(obLowBear) and close <= obHighBear and close >= obLowBear

longSqueezeConfirm  = squeezeOff and momUp
shortSqueezeConfirm = squeezeOff and momDown

longCond  = isExecTF and monthlyBull and weeklyBull and inFiboLong  and inOBBull and longSqueezeConfirm  and kzFilter
shortCond = isExecTF and monthlyBear and weeklyBear and inFiboShort and inOBBear and shortSqueezeConfirm and kzFilter

//========================
//=== SALIDA HÍBRIDA ====
//========================
firstExtLong  = close >= fibLvl110
firstExtShort = close <= fibLvl110

exitByMomLong  = isExecTF and mom < mom[1] and mom[1] > 0
exitByMomShort = isExecTF and mom > mom[1] and mom[1] < 0

exitByFiboLong  = isExecTF and firstExtLong
exitByFiboShort = isExecTF and firstExtShort

exitByOBLong  = isExecTF and not na(obHighBear) and not na(obLowBear) and close >= obLowBear
exitByOBShort = isExecTF and not na(obHighBull) and not na(obLowBull) and close <= obHighBull

exitLong  = useHybridExit and (exitByMomLong  or exitByFiboLong  or exitByOBLong)
exitShort = useHybridExit and (exitByMomShort or exitByFiboShort or exitByOBShort)

//========================
//=== SEÑALES VISUALES ===
//========================
plotshape(longCond,  title="Harold LONG",  style=shape.triangleup,   color=color.new(color.lime, 0), size=size.large,  location=location.belowbar, text="HL", textcolor=color.white)
plotshape(shortCond, title="Harold SHORT", style=shape.triangledown, color=color.new(color.red, 0),  size=size.large,  location=location.abovebar, text="HS", textcolor=color.white)
plotshape(exitLong,  title="Harold EXIT LONG",  style=shape.xcross, color=color.new(color.orange, 0), size=size.normal, location=location.abovebar, text="XL", textcolor=color.white)
plotshape(exitShort, title="Harold EXIT SHORT", style=shape.xcross, color=color.new(color.orange, 0), size=size.normal, location=location.belowbar, text="XS", textcolor=color.white)

//========================
//=== ALERTAS ===========
//========================
alertcondition(longCond,  title="Harold LONG ENTRY",  message="Harold PRO: Entrada LONG en H4 {{ticker}} @ {{close}}")
alertcondition(shortCond, title="Harold SHORT ENTRY", message="Harold PRO: Entrada SHORT en H4 {{ticker}} @ {{close}}")
alertcondition(exitLong,  title="Harold LONG EXIT",   message="Harold PRO: Salida LONG en H4 {{ticker}} @ {{close}}")
alertcondition(exitShort, title="Harold SHORT EXIT",  message="Harold PRO: Salida SHORT en H4 {{ticker}} @ {{close}}")

//========================
//=== TABLA DE ESTADO ===
//========================
if showPanel and barstate.islast
    var table entradas = table.new(position.top_right, 2, 6, border_width=1)
    table.cell(entradas, 0, 0, "BIAS MENSUAL", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 0, monthlyBull ? "BULL" : monthlyBear ? "BEAR" : "—", text_color=color.white, bgcolor=monthlyBull ? color.new(color.green, 40) : monthlyBear ? color.new(color.red, 40) : color.new(color.gray, 80))
    table.cell(entradas, 0, 1, "BIAS SEMANAL", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 1, weeklyBull ? "BULL" : weeklyBear ? "BEAR" : "—", text_color=color.white, bgcolor=weeklyBull ? color.new(color.green, 40) : weeklyBear ? color.new(color.red, 40) : color.new(color.gray, 80))
    table.cell(entradas, 0, 2, "ZONA P/D", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 2, inDiscount ? "DISCOUNT" : inPremium ? "PREMIUM" : "—", text_color=color.white, bgcolor=inDiscount ? color.new(color.green, 40) : inPremium ? color.new(color.red, 40) : color.new(color.gray, 80))
    table.cell(entradas, 0, 3, "EN OB", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 3, inOBBull ? "OB BULL" : inOBBear ? "OB BEAR" : "—", text_color=color.white, bgcolor=inOBBull ? color.new(color.green, 40) : inOBBear ? color.new(color.red, 40) : color.new(color.gray, 80))
    table.cell(entradas, 0, 4, "SQUEEZE", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 4, squeezeOn ? "ON" : squeezeOff ? "OFF" : "—", text_color=color.white, bgcolor=squeezeOff ? color.new(color.yellow, 40) : color.new(color.gray, 80))
    table.cell(entradas, 0, 5, "ENTRADA H4", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(entradas, 1, 5, longCond ? "LONG ✓" : shortCond ? "SHORT ✓" : "ESPERAR", text_color=color.white, bgcolor=longCond ? color.new(color.green, 20) : shortCond ? color.new(color.red, 20) : color.new(color.gray, 80))
````
