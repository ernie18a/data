# RSI Microstruttura MTF Auto

- url: https://www.tradingview.com/script/hoxlbNKc/
- type: indicator
- pine_id: PUB;73389b9c219545a7bcffe3ac01256e90
- version: 1.0

## Description

This indicator reads the RSI of the timeframes immediately below your chart to judge whether an RSI move is backed by real underlying momentum or likely to fail.
It auto-detects your chart timeframe and pulls the RSI from the 5 standard grades directly beneath it — no manual setup. On a daily chart it reads 4h, 3h, 2h, 1h and 45m.
Two lines are plotted. The thick line is the "micro" average: the mean RSI across those 5 lower timeframes. The orange line is the average of their moving averages (SMA 14 by default, matching the standard RSI's MA). The signal is their crossover, not a fixed level — when the micro crosses above its moving-average line, lower-timeframe momentum is turning up; below, it's turning down.
Crossovers are graded by internal agreement: a triangle marks a confirmed cross where the majority of lower grades sit on the same side of their own MA; an orange X marks a weak cross where the grades are split — the classic move that won't hold.
A side table lists every timeframe in use with its live RSI, color-coded by whether it has yet to cross up (green) or already has (red).
Works best on 15m and above, where all 5 lower grades exist. Alerts included for confirmed crosses.

## Source Code

````pine
//@version=6
indicator("RSI Microstruttura MTF Auto", shorttitle="RSI-MTF-Auto", overlay=false, precision=2)

// ===================== INPUT =====================
grpR = "RSI"
len  = input.int(14, "Lunghezza RSI", minval=1, group=grpR)
src  = input.source(close, "Sorgente", group=grpR)

grpM = "Media mobile (segnale)"
maLen  = input.int(14, "Periodo MA (come RSI 14 standard)", minval=1, group=grpM)
maType = input.string("SMA", "Tipo MA", options=["SMA","EMA","RMA","WMA"], group=grpM, tooltip="L'RSI standard di TradingView usa SMA 14 per la sua linea MA. Lascia SMA per replicarlo.")

grpD = "Visualizzazione"
showSig  = input.bool(true, "Mostra linea media delle medie mobili", group=grpD)
obLvl    = input.int(70, "Ipercomprato", group=grpD)
osLvl    = input.int(30, "Ipervenduto", group=grpD)
showTbl  = input.bool(true, "Mostra tabella valori", group=grpD)

grpS = "Segnali"
showCr   = input.bool(true, "Mostra incroci", group=grpS)
reqAgree = input.bool(true, "Richiedi accordo dei TF inferiori", group=grpS, tooltip="Cross 'confermato' solo se la maggioranza dei 5 TF inferiori ha l'RSI dallo stesso lato della propria MA.")

// ===================== SCALA TIMEFRAME (completa) =====================
// 1,3,5,15,30,45,60,120,180,240,D,W,M  ->  idx 0..12
fIdx(s) =>
    s <= 60 ? 0 : s <= 180 ? 1 : s <= 300 ? 2 : s <= 900 ? 3 : s <= 1800 ? 4 : s <= 2700 ? 5 : s <= 3600 ? 6 : s <= 7200 ? 7 : s <= 10800 ? 8 : s <= 14400 ? 9 : s <= 86400 ? 10 : s <= 604800 ? 11 : 12
fTf(i) =>
    i == 0 ? "1" : i == 1 ? "3" : i == 2 ? "5" : i == 3 ? "15" : i == 4 ? "30" : i == 5 ? "45" : i == 6 ? "60" : i == 7 ? "120" : i == 8 ? "180" : i == 9 ? "240" : i == 10 ? "D" : i == 11 ? "W" : "M"
fLabel(i) =>
    i == 0 ? "1m" : i == 1 ? "3m" : i == 2 ? "5m" : i == 3 ? "15m" : i == 4 ? "30m" : i == 5 ? "45m" : i == 6 ? "1h" : i == 7 ? "2h" : i == 8 ? "3h" : i == 9 ? "4h" : i == 10 ? "D" : i == 11 ? "W" : "M"

chartSec = timeframe.in_seconds(timeframe.period)
cIdx = fIdx(chartSec)

lvl1 = cIdx - 1
lvl2 = cIdx - 2
lvl3 = cIdx - 3
lvl4 = cIdx - 4
lvl5 = cIdx - 5

tf1 = fTf(lvl1 < 0 ? 0 : lvl1)
tf2 = fTf(lvl2 < 0 ? 0 : lvl2)
tf3 = fTf(lvl3 < 0 ? 0 : lvl3)
tf4 = fTf(lvl4 < 0 ? 0 : lvl4)
tf5 = fTf(lvl5 < 0 ? 0 : lvl5)

v1 = lvl1 >= 0
v2 = lvl2 >= 0
v3 = lvl3 >= 0
v4 = lvl4 >= 0
v5 = lvl5 >= 0

// ===================== FUNZIONI =====================
maOf(series float x) =>
    maType == "EMA" ? ta.ema(x, maLen) : maType == "RMA" ? ta.rma(x, maLen) : maType == "WMA" ? ta.wma(x, maLen) : ta.sma(x, maLen)
rsiMa() =>
    maOf(ta.rsi(src, len))

// ===================== CALCOLO =====================
rsiNat  = ta.rsi(src, len)
chartMa = maOf(rsiNat)

r1 = request.security(syminfo.tickerid, tf1, ta.rsi(src, len))
r2 = request.security(syminfo.tickerid, tf2, ta.rsi(src, len))
r3 = request.security(syminfo.tickerid, tf3, ta.rsi(src, len))
r4 = request.security(syminfo.tickerid, tf4, ta.rsi(src, len))
r5 = request.security(syminfo.tickerid, tf5, ta.rsi(src, len))

m1 = request.security(syminfo.tickerid, tf1, rsiMa())
m2 = request.security(syminfo.tickerid, tf2, rsiMa())
m3 = request.security(syminfo.tickerid, tf3, rsiMa())
m4 = request.security(syminfo.tickerid, tf4, rsiMa())
m5 = request.security(syminfo.tickerid, tf5, rsiMa())

// --- media micro (RSI) e media delle medie mobili (MA), solo TF validi ---
sumR = 0.0
sumM = 0.0
cnt  = 0
above = 0
below = 0
if v1 and not na(r1) and not na(m1)
    sumR := sumR + r1
    sumM := sumM + m1
    cnt  := cnt + 1
    above := above + (r1 >= m1 ? 1 : 0)
    below := below + (r1 <  m1 ? 1 : 0)
if v2 and not na(r2) and not na(m2)
    sumR := sumR + r2
    sumM := sumM + m2
    cnt  := cnt + 1
    above := above + (r2 >= m2 ? 1 : 0)
    below := below + (r2 <  m2 ? 1 : 0)
if v3 and not na(r3) and not na(m3)
    sumR := sumR + r3
    sumM := sumM + m3
    cnt  := cnt + 1
    above := above + (r3 >= m3 ? 1 : 0)
    below := below + (r3 <  m3 ? 1 : 0)
if v4 and not na(r4) and not na(m4)
    sumR := sumR + r4
    sumM := sumM + m4
    cnt  := cnt + 1
    above := above + (r4 >= m4 ? 1 : 0)
    below := below + (r4 <  m4 ? 1 : 0)
if v5 and not na(r5) and not na(m5)
    sumR := sumR + r5
    sumM := sumM + m5
    cnt  := cnt + 1
    above := above + (r5 >= m5 ? 1 : 0)
    below := below + (r5 <  m5 ? 1 : 0)

mediaMicro = cnt > 0 ? sumR / cnt : na
mediaMA    = cnt > 0 ? sumM / cnt : na

// ===================== PLOT =====================
hline(obLvl, "OB", color=color.new(color.gray, 60))
hline(50, "Mid", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(osLvl, "OS", color=color.new(color.gray, 60))

plot(showSig ? mediaMA : na, "Media delle medie mobili", color=color.new(color.orange, 0), linewidth=1)
plot(mediaMicro, "Media micro (microstruttura)", color=(mediaMicro >= mediaMA ? color.teal : color.red), linewidth=2)

// ===================== SEGNALI =====================
crossUp = ta.crossover(mediaMicro, mediaMA)
crossDn = ta.crossunder(mediaMicro, mediaMA)
agreeUp = above > below
agreeDn = below > above

confUp  = crossUp and (not reqAgree or agreeUp)
confDn  = crossDn and (not reqAgree or agreeDn)
falseUp = crossUp and not agreeUp
falseDn = crossDn and not agreeDn

plotshape(showCr and confUp,  "Rialzista confermato",  shape.triangleup,   location.bottom, color.teal,   size=size.tiny)
plotshape(showCr and confDn,  "Ribassista confermato", shape.triangledown, location.top,    color.red,    size=size.tiny)
plotshape(showCr and falseUp, "Rialzista debole",      shape.xcross,       location.bottom, color.orange, size=size.tiny)
plotshape(showCr and falseDn, "Ribassista debole",     shape.xcross,       location.top,    color.orange, size=size.tiny)

alertcondition(confUp, "Incrocio rialzista confermato",  "RSI MTF: media micro incrocia al rialzo la media delle medie mobili, confermata dai TF inferiori")
alertcondition(confDn, "Incrocio ribassista confermato", "RSI MTF: media micro incrocia al ribasso la media delle medie mobili, confermata dai TF inferiori")

// ===================== TABELLA =====================
// Colore cella: VERDE = RSI ancora sotto la sua MA (deve ancora incrociare al rialzo)
//               ROSSO = RSI già sopra la sua MA (ha già incrociato al rialzo)
cCol(x, m) => (na(x) or na(m)) ? color.gray : (x < m ? color.green : color.red)
f_txt(x) => na(x) ? "—" : str.tostring(x, "#.0")
tfBg = color.new(color.gray, 20)
if showTbl and barstate.islast
    var table tb = table.new(position.top_right, 2, 8, border_width=1)
    table.cell(tb, 0, 0, "TF",  text_color=color.white, bgcolor=color.new(color.gray, 0))
    table.cell(tb, 1, 0, "RSI", text_color=color.white, bgcolor=color.new(color.gray, 0))
    table.cell(tb, 0, 1, fLabel(cIdx) + " (grafico, rif.)", text_color=color.white, bgcolor=color.new(color.gray, 45))
    table.cell(tb, 1, 1, f_txt(rsiNat), text_color=color.white, bgcolor=color.new(cCol(rsiNat, chartMa), 70))
    table.cell(tb, 0, 2, v1 ? fLabel(lvl1) : "—", text_color=color.white, bgcolor=tfBg)
    table.cell(tb, 1, 2, v1 ? f_txt(r1) : "—", text_color=color.white, bgcolor=color.new(cCol(v1 ? r1 : na, m1), 55))
    table.cell(tb, 0, 3, v2 ? fLabel(lvl2) : "—", text_color=color.white, bgcolor=tfBg)
    table.cell(tb, 1, 3, v2 ? f_txt(r2) : "—", text_color=color.white, bgcolor=color.new(cCol(v2 ? r2 : na, m2), 55))
    table.cell(tb, 0, 4, v3 ? fLabel(lvl3) : "—", text_color=color.white, bgcolor=tfBg)
    table.cell(tb, 1, 4, v3 ? f_txt(r3) : "—", text_color=color.white, bgcolor=color.new(cCol(v3 ? r3 : na, m3), 55))
    table.cell(tb, 0, 5, v4 ? fLabel(lvl4) : "—", text_color=color.white, bgcolor=tfBg)
    table.cell(tb, 1, 5, v4 ? f_txt(r4) : "—", text_color=color.white, bgcolor=color.new(cCol(v4 ? r4 : na, m4), 55))
    table.cell(tb, 0, 6, v5 ? fLabel(lvl5) : "—", text_color=color.white, bgcolor=tfBg)
    table.cell(tb, 1, 6, v5 ? f_txt(r5) : "—", text_color=color.white, bgcolor=color.new(cCol(v5 ? r5 : na, m5), 55))
    table.cell(tb, 0, 7, "MEDIA MICRO", text_color=color.white, bgcolor=color.new(color.gray, 10))
    table.cell(tb, 1, 7, f_txt(mediaMicro), text_color=color.white, bgcolor=color.new(cCol(mediaMicro, mediaMA), 30))
````
