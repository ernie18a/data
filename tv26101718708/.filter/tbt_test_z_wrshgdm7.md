# TBT TEST Z

- url: https://www.tradingview.com/script/WRsHGDM7/
- type: indicator
- pine_id: PUB;93ed59bb43404b16b074bb009caa2c0b
- version: 1.0

## Description

esto es un script de prueba para probar si funciona y hacer mas adelatne una version fginal

## Source Code

````pine
//@version=6
indicator("MNQ — pNQH / pNQL / pPOC día anterior", overlay=true, max_lines_count=20, max_labels_count=20)

// ── Sesión de cálculo ────────────────────────────────────
useRTH = input.bool(true, "Calcular con sesión RTH (si no, día completo)")
sess   = input.session("0930-1700", "Sesión RTH")
tz     = input.string("America/New_York", "Zona horaria sesión")
rows   = input.int(50, "Resolución del POC (nº de niveles)", minval=4, maxval=500)

// ── Ventana de dibujo ────────────────────────────────────
winTz  = input.string("America/New_York", "Zona horaria ventana")
hStart = input.int(3,  "Hora inicio", minval=0, maxval=23)
mStart = input.int(0,  "Min inicio",  minval=0, maxval=59)
hEnd   = input.int(17, "Hora cierre", minval=1, maxval=24)
mEnd   = input.int(0,  "Min cierre",  minval=0, maxval=59)

// ── Estilo ───────────────────────────────────────────────
colHL   = input.color(#4FC3F7,     "Color pNQH / pNQL")
colPOC  = input.color(color.white, "Color pPOC")
lw      = input.int(2, "Grosor", minval=1, maxval=5)
showLbl = input.bool(true, "Etiquetas")

// ── Detección de sesión ──────────────────────────────────
inSess  = not useRTH or not na(time(timeframe.period, sess, tz))
sessEnd = useRTH ? (not inSess and inSess[1]) : (ta.change(time("D")) != 0)
sessSt  = useRTH ? (inSess and not inSess[1]) : (ta.change(time("D")) != 0)

// ── Buffers / resultados ─────────────────────────────────
var array<float> hi  = array.new<float>()
var array<float> lo  = array.new<float>()
var array<float> vol = array.new<float>()
var float pNQH = na
var float pNQL = na
var float pPOC = na

if sessEnd and array.size(vol) > 0
    float dHigh = array.max(hi)
    float dLow  = array.min(lo)
    float step  = (dHigh - dLow) / rows
    if step > 0
        array<float> bins = array.new<float>(rows, 0.0)
        for i = 0 to array.size(vol) - 1
            int idxLo = math.max(0,        math.floor((array.get(lo, i) - dLow) / step))
            int idxHi = math.min(rows - 1, math.floor((array.get(hi, i) - dLow) / step))
            float vPer = array.get(vol, i) / (idxHi - idxLo + 1)
            for j = idxLo to idxHi
                array.set(bins, j, array.get(bins, j) + vPer)
        float maxV = 0.0
        int pocIdx = 0
        for i = 0 to rows - 1
            if array.get(bins, i) > maxV
                maxV   := array.get(bins, i)
                pocIdx := i
        pNQH := dHigh
        pNQL := dLow
        pPOC := dLow + (pocIdx + 0.5) * step
    array.clear(hi)
    array.clear(lo)
    array.clear(vol)

if sessSt
    array.clear(hi)
    array.clear(lo)
    array.clear(vol)

if inSess
    array.push(hi,  high)
    array.push(lo,  low)
    array.push(vol, volume)

// ── Dibujo (solo 1 día, borra el anterior) ───────────────
hNow     = hour(time, winTz)
inWin    = hNow >= hStart and hNow < hEnd
winStart = inWin and not inWin[1]

var line  lnH = na
var line  lnL = na
var line  lnP = na
var label lbH = na
var label lbL = na
var label lbP = na

if winStart and not na(pNQH)
    line.delete(lnH)
    line.delete(lnL)
    line.delete(lnP)
    label.delete(lbH)
    label.delete(lbL)
    label.delete(lbP)
    int y = year(time, winTz)
    int m = month(time, winTz)
    int d = dayofmonth(time, winTz)
    int xS = timestamp(winTz, y, m, d, hStart, mStart)
    int xE = timestamp(winTz, y, m, d, hEnd,   mEnd)
    lnH := line.new(xS, pNQH, xE, pNQH, xloc=xloc.bar_time, color=colHL,  width=lw)
    lnL := line.new(xS, pNQL, xE, pNQL, xloc=xloc.bar_time, color=colHL,  width=lw)
    lnP := line.new(xS, pPOC, xE, pPOC, xloc=xloc.bar_time, color=colPOC, width=lw)
    if showLbl
        lbH := label.new(xE, pNQH, "pNQH " + str.tostring(pNQH, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=colHL,  textcolor=color.black, size=size.small)
        lbL := label.new(xE, pNQL, "pNQL " + str.tostring(pNQL, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=colHL,  textcolor=color.black, size=size.small)
        lbP := label.new(xE, pPOC, "pPOC " + str.tostring(pPOC, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=colPOC, textcolor=color.black, size=size.small)
````
