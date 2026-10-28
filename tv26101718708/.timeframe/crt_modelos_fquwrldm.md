# CRT Modelos

- url: https://www.tradingview.com/script/FQuWrLdM/
- type: indicator
- pine_id: PUB;ad1c1fc46e814bb8a147c35c6738601e
- version: 1.0

## Description

📐 Qué es
Este indicador detecta y dibuja modelos basados en la Teoría del Rango de la Vela (CRT): cada vela es un rango; si se rompe ese rango para engañar al mercado, el precio reacciona de forma predecible.

Analiza patrones de 2 velas (Vela 1 de referencia + Vela 2 de ruptura), proyecta objetivos de ganancias/pérdidas y muestra estadísticas de acierto.

⚙️ Cómo funciona
La Vela 2 (V2) rompe el máximo o mínimo de la Vela 1 (V1). Según cómo cierre la V2, se activa un modelo:

M1 — En Espera
Qué es: V2 ha roto el rango de V1, pero aún no se ha cerrado.

Visual: Recuadro de puntos para anticipar el movimiento.

M2 — Giro (Reversión)
Qué es: V2 rompe a V1, pero vuelve a cerrar dentro del rango de V1 (falso rompimiento).

Niveles:

T1 / T2 (Ganancias): Extremos opuestos de V2 y V1.

SL (Pérdidas): Extremo por donde rompió la V2.

M3 — Continuación
Qué es: V2 rompe a V1 y cierra fuera, a favor de la rotura. El precio sigue la tendencia.

Niveles: TP en el extremo a favor de tendencia; SL en el extremo opuesto de V2.

M3+ — Continuación Fuerte
Qué es: V2 rompe ambos lados de V1 (limpieza doble) y cierra fuera. Señal de alta probabilidad.

Niveles: TP a favor del cierre; SL en el punto más lejano del engaño.

🧭 Dirección del Precio
M2: Va al revés. Si rompe primero por arriba, va hacia abajo. Si rompe primero por abajo, va hacia arriba.

M3: Sigue la rotura. Rompe arriba = compra; rompe abajo = venta.

M3+: Mira el primer engaño y va al revés. Si rompe primero abajo, el movimiento final será hacia arriba.

🔧 Funciones Clave
Multitemporalidad: Muestra niveles de gráficos mayores (ej. 1 hora) mientras operas en gráficos menores (ej. 5 minutos).

Filtro ATR: Opcional. Ignora movimientos pequeños; solo detecta roturas con fuerza real.

Filtro de Sesión: Limita la búsqueda de modelos a tus horas operativas (ej. Nueva York o Londres).

Resolución Inteligente: Si el precio toca las ganancias y las pérdidas en la misma vela, calcula cuál tocó primero según el precio de apertura.

Historial Visual: Los modelos activos muestran recuadros y líneas. Los cerrados se vuelven transparentes, dejando marcado en verde si se ganó o en rojo si se perdió.

Tabla de Estadísticas: Cuadro en el gráfico con el porcentaje de aciertos real de cada modelo.

Alertas: Configurable para avisar al móvil/PC en cada fase (M1, confirmación, TP o SL).

📋 Configuración Básica (Inputs)
Temporalidad: Selector para activar el gráfico mayor.

Filtros: Sensibilidad del filtro ATR y filtro de huecos del mercado (Gaps).

Sesión: Horarios activos y zona horaria (GMT).

Visual y Colores: Colores por modelo, transparencias y límite de objetos en pantalla.

Alertas: Activación independiente para cada tipo de aviso.

## Source Code

````pine
//@version=6
indicator("CRT — Candle Range Theory Engine", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

iUseHtf = input.bool(false, "Activate Custom HTF", group="Temporality")
iHtfTf = input.timeframe("60", "HTF Timeframe", group="Temporality")

iUseAtrFilter = input.bool(true, "Activate ATR Filter", group="Filters")
iMinManipAtr = input.float(15.0, "Min Manipulation (% ATR)", minval=0.1, maxval=100, step=0.5, group="Filters")
iMinCloseAtr = input.float(10.0, "Min Close Beyond V1 (% ATR)", minval=0.0, maxval=100, step=0.5, group="Filters")
iAtrLen = input.int(14, "ATR Length", minval=1, group="Filters")
iFilterGaps = input.bool(false, "Filter Gaps", group="Filters")
iGapAtrPct = input.float(20.0, "Gap Size Threshold (% ATR)", minval=1.0, group="Filters")

iUseSession = input.bool(false, "Activate Session Filter", group="Session")
iGmtOffset = input.int(-4, "Chart GMT Offset", minval=-12, maxval=14, group="Session")
iSessOpen = input.string("08:00", "Session Open (HH:MM)", group="Session")
iSessClose = input.string("17:00", "Session Close (HH:MM)", group="Session")

iMaxActive = input.int(20, "Max Active Models", minval=1, maxval=30, group="Display")
iShowHist = input.bool(true, "Show Closed Models", group="Display")
iMaxHistVis = input.int(50, "Max Closed Models Shown", minval=1, maxval=200, group="Display")
iHistTrans = input.int(85, "Closed Models Transparency", minval=0, maxval=100, group="Display")
iShowM1 = input.bool(true, "Show M1 (Live)", group="Display")

iShowStats = input.bool(true, "Show Stats Table", group="Statistics")
iStatsPos = input.string("Bottom Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
iStatsTrans = input.int(40, "Stats Background Transparency", minval=0, maxval=100, group="Statistics")

iAlertM1 = input.bool(true, "Alert on M1 Manipulation", group="Alerts")
iAlertConfirm = input.bool(true, "Alert on Model Confirmation", group="Alerts")
iAlertTp = input.bool(true, "Alert on Target Hit", group="Alerts")
iAlertSl = input.bool(true, "Alert on Invalidative Hit", group="Alerts")

cM1 = input.color(color.new(#FFEB3B, 80), "M1 Color", group="Colors")
cM2Bull = input.color(color.new(#2196F3, 88), "M2 Bull", group="Colors")
cM2Bear = input.color(color.new(#FF9800, 88), "M2 Bear", group="Colors")
cM3Bull = input.color(color.new(#4CAF50, 88), "M3 Bull", group="Colors")
cM3Bear = input.color(color.new(#F44336, 88), "M3 Bear", group="Colors")
cM3pBull = input.color(color.new(#00E676, 88), "M3+ Bull", group="Colors")
cM3pBear = input.color(color.new(#D50000, 88), "M3+ Bear", group="Colors")
cTpLine = input.color(#00E676, "Target Line", group="Colors")
cSlLine = input.color(#FF1744, "SL Line", group="Colors")

// ═══════════════════════════════════════════════════════════════════════════════
// TYPES & ARRAYS
// ═══════════════════════════════════════════════════════════════════════════════

type V1Candle
    float h
    float l
    int timeOpen
    int timeClose
    bool highSwept
    bool lowSwept
    int firstSweep
    bool consumed

type CrtModel
    string id
    int mtype
    int dir
    int status
    int closeTime
    float v1h
    float v1l
    int v1Open
    float tp1
    float tp2
    float sl
    box bx
    line lnTp1
    line lnTp2
    line lnSl
    label lbl
    label lblSl

var V1Candle[] v1Pool = array.new<V1Candle>()
var CrtModel[] activeModels = array.new<CrtModel>()
var CrtModel[] histModels = array.new<CrtModel>()

var int[] sT1 = array.from(0,0,0,0,0,0)
var int[] sT2 = array.from(0,0,0,0,0,0)
var int[] sL = array.from(0,0,0,0,0,0)

var float sH = na
var float sLw = na
var float sO = na
var float sC = na
var int sOpTime = na
var int sTimeH = na
var int sTimeL = na

var float p_H = na
var float p_L = na
var float p_O = na
var float p_C = na
var int p_OpTime = na
var int p_ClTime = na
var int p_TimeH = na
var int p_TimeL = na

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS & ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

f_parseHM(string s) =>
    int hh = math.round(str.tonumber(str.substring(s, 0, 2)))
    int mm = math.round(str.tonumber(str.substring(s, 3, 5)))
    hh * 60 + mm

f_inSession() =>
    bool ok = true
    if iUseSession
        int adjustedTime = time + iGmtOffset * 3600 * 1000
        int curMin = (hour(adjustedTime, "UTC") * 60) + minute(adjustedTime, "UTC")
        int openMin = f_parseHM(iSessOpen)
        int closeMin = f_parseHM(iSessClose)
        if closeMin == 0
            closeMin := 24 * 60
        if openMin < closeMin
            ok := curMin >= openMin and curMin < closeMin
        else
            ok := curMin >= openMin or curMin < closeMin
    ok

effTf = iUseHtf ? iHtfTf : timeframe.period
isNewHtf = ta.change(time(effTf)) != 0

if isNewHtf
    if not na(sH)
        p_H := sH
        p_L := sLw
        p_O := sO
        p_C := sC
        p_OpTime := sOpTime
        p_ClTime := time
        p_TimeH := sTimeH
        p_TimeL := sTimeL
    sH := high
    sLw := low
    sO := open
    sOpTime := time
    sTimeH := time
    sTimeL := time
else
    if high > nz(sH, high)
        sH := high
        sTimeH := time
    else if na(sH)
        sH := high
        sTimeH := time
        
    if low < nz(sLw, low)
        sLw := low
        sTimeL := time
    else if na(sLw)
        sLw := low
        sTimeL := time
sC := close

atrLocal = ta.atr(iAtrLen)
atrVal = iUseHtf ? request.security(syminfo.tickerid, effTf, ta.atr(iAtrLen)) : atrLocal
manipReq = iUseAtrFilter and not na(atrVal) ? atrVal * (iMinManipAtr / 100.0) : 0.0
closeReq = iUseAtrFilter and not na(atrVal) ? atrVal * (iMinCloseAtr / 100.0) : 0.0

gapOk = true
if iFilterGaps and not na(atrLocal) and atrLocal > 0
    float gapSize = math.abs(open - close[1])
    float gapPct = gapSize / atrLocal * 100
    gapOk := gapPct < iGapAtrPct

f_getCol(mtype, dir, alive) =>
    color c = cM2Bull
    if mtype == 2
        c := dir == 1 ? cM2Bull : cM2Bear
    else if mtype == 3
        c := dir == 1 ? cM3Bull : cM3Bear
    else if mtype == 4
        c := dir == 1 ? cM3pBull : cM3pBear
    if not alive
        c := color.new(c, iHistTrans)
    c

f_getBor(mtype, dir, alive) =>
    color c = cM2Bull
    if mtype == 2
        c := dir == 1 ? color.new(cM2Bull, 0) : color.new(cM2Bear, 0)
    else if mtype == 3
        c := dir == 1 ? color.new(cM3Bull, 0) : color.new(cM3Bear, 0)
    else if mtype == 4
        c := dir == 1 ? color.new(cM3pBull, 0) : color.new(cM3pBear, 0)
    if not alive
        c := color.new(c, iHistTrans - 20)
    c

f_lbl(mtype, dir) =>
    string p = mtype == 2 ? "M2" : mtype == 3 ? "M3" : "M3+"
    string d = dir == 1 ? " ↑" : " ↓"
    p + d

f_idx(mtype, dir) =>
    int idx = 0
    if mtype == 2
        idx := dir == 1 ? 0 : 1
    else if mtype == 3
        idx := dir == 1 ? 2 : 3
    else
        idx := dir == 1 ? 4 : 5
    idx

f_clearAll(CrtModel m) =>
    if not na(m.bx)
        box.delete(m.bx)
    if not na(m.lnTp1)
        line.delete(m.lnTp1)
    if not na(m.lnTp2)
        line.delete(m.lnTp2)
    if not na(m.lnSl)
        line.delete(m.lnSl)
    if not na(m.lbl)
        label.delete(m.lbl)
    if not na(m.lblSl)
        label.delete(m.lblSl)

// ═══════════════════════════════════════════════════════════════════════════════
// MODEL CREATION
// ═══════════════════════════════════════════════════════════════════════════════

inSess = f_inSession()

if isNewHtf and not na(p_H) and inSess and gapOk
    if array.size(v1Pool) > 0
        for i = array.size(v1Pool) - 1 to 0
            v1 = array.get(v1Pool, i)
            if v1.consumed
                continue
            
            bool mBull = (p_H - v1.h) >= manipReq
            bool mBear = (v1.l - p_L) >= manipReq
            bool cIn = p_C <= v1.h and p_C >= v1.l
            bool cAbv = p_C > v1.h and (p_C - v1.h) >= closeReq
            bool cBel = p_C < v1.l and (v1.l - p_C) >= closeReq
            
            int mType = 0
            int mDir = 0
            float mTp1 = na
            float mTp2 = na
            float mSl = na
            int mSlTime = p_ClTime
            
            if mBull and mBear
                if p_C > p_O and cAbv
                    mType := 4
                    mDir := 1
                    mTp1 := p_H
                    mSl := v1.l
                    mSlTime := p_ClTime
                else if p_C < p_O and cBel
                    mType := 4
                    mDir := -1
                    mTp1 := p_L
                    mSl := v1.h
                    mSlTime := p_ClTime
                else if cIn
                    mType := 2
                    mDir := p_C > p_O ? 1 : -1
                    if mDir == 1
                        mTp1 := p_H
                        mTp2 := v1.h
                        mSl := p_L
                        mSlTime := p_TimeL
                    else
                        mTp1 := p_L
                        mTp2 := v1.l
                        mSl := p_H
                        mSlTime := p_TimeH
            else if mBull and not mBear
                if cAbv
                    mType := 3
                    mDir := 1
                    mTp1 := p_H
                    mSl := p_L
                    mSlTime := p_TimeL
                else if p_C <= v1.h
                    mType := 2
                    mDir := -1
                    mTp1 := p_L
                    mTp2 := v1.l
                    mSl := p_H
                    mSlTime := p_TimeH
            else if mBear and not mBull
                if cBel
                    mType := 3
                    mDir := -1
                    mTp1 := p_L
                    mSl := p_H
                    mSlTime := p_TimeH
                else if p_C >= v1.l
                    mType := 2
                    mDir := 1
                    mTp1 := p_H
                    mTp2 := v1.h
                    mSl := p_L
                    mSlTime := p_TimeL

            if mType > 0
                while array.size(activeModels) >= iMaxActive
                    f_clearAll(array.shift(activeModels))
                
                color bCol = f_getCol(mType, mDir, true)
                color bBor = f_getBor(mType, mDir, true)
                
                box bx = box.new(v1.timeOpen, v1.h, p_ClTime, v1.l, xloc=xloc.bar_time, bgcolor=bCol, border_color=bBor)
                line lT1 = line.new(p_ClTime, mTp1, p_ClTime, mTp1, xloc=xloc.bar_time, color=cTpLine)
                line lT2 = na(mTp2) ? na : line.new(p_ClTime, mTp2, p_ClTime, mTp2, xloc=xloc.bar_time, color=cTpLine, style=line.style_dotted)
                line lSl = line.new(mSlTime, mSl, p_ClTime, mSl, xloc=xloc.bar_time, color=cSlLine, style=line.style_dashed)
                
                float ly = mDir == 1 ? v1.l : v1.h
                string lSty = mDir == 1 ? label.style_label_upper_right : label.style_label_lower_left
                label lb = label.new(p_ClTime, ly, f_lbl(mType, mDir), xloc=xloc.bar_time, style=lSty, color=bBor, textcolor=color.white, size=size.small)
                label ls = label.new(mSlTime, mSl, "●", xloc=xloc.bar_time, style=label.style_none, textcolor=cSlLine, size=size.tiny)
                
                array.push(activeModels, CrtModel.new(f_lbl(mType, mDir), mType, mDir, 0, na, v1.h, v1.l, v1.timeOpen, mTp1, mTp2, mSl, bx, lT1, lT2, lSl, lb, ls))
                v1.consumed := true
                if iAlertConfirm
                    alert("CRT Model Confirmed: " + f_lbl(mType, mDir), alert.freq_once_per_bar)
            else
                v1.highSwept := false
                v1.lowSwept := false
                v1.firstSweep := 0

    array.push(v1Pool, V1Candle.new(p_H, p_L, p_OpTime, p_ClTime, false, false, 0, false))
    while array.size(v1Pool) > 200
        array.shift(v1Pool)

// ═══════════════════════════════════════════════════════════════════════════════
// M1 DETECTION & DRAWING
// ═══════════════════════════════════════════════════════════════════════════════

if array.size(v1Pool) > 0 and inSess
    for i = 0 to array.size(v1Pool) - 1
        v1 = array.get(v1Pool, i)
        if v1.consumed
            continue
        if not v1.highSwept and high > v1.h
            v1.highSwept := true
            if v1.firstSweep == 0
                v1.firstSweep := 1
            if iAlertM1
                alert("CRT M1 High Sweep Detected", alert.freq_once_per_bar)
        if not v1.lowSwept and low < v1.l
            v1.lowSwept := true
            if v1.firstSweep == 0
                v1.firstSweep := -1
            if iAlertM1
                alert("CRT M1 Low Sweep Detected", alert.freq_once_per_bar)

var box[] m1Bxs = array.new<box>()
var label[] m1Lbs = array.new<label>()
while array.size(m1Bxs) > 0
    box.delete(array.pop(m1Bxs))
while array.size(m1Lbs) > 0
    label.delete(array.pop(m1Lbs))

if iShowM1 and array.size(v1Pool) > 0 and inSess
    for i = array.size(v1Pool) - 1 to 0
        v1 = array.get(v1Pool, i)
        if v1.consumed or (not v1.highSwept and not v1.lowSwept)
            continue
        
        int md = v1.firstSweep == 1 ? -1 : 1
        array.push(m1Bxs, box.new(v1.timeOpen, v1.h, time, v1.l, xloc=xloc.bar_time, bgcolor=color.new(cM1, 85), border_color=color.new(cM1, 30), border_style=line.style_dashed))
        array.push(m1Lbs, label.new(time, v1.h, "M1" + (md == 1 ? " ↑" : " ↓"), xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(cM1, 0), size=size.small))

// ═══════════════════════════════════════════════════════════════════════════════
// LIFECYCLE & HISTORICAL DRAWING
// ═══════════════════════════════════════════════════════════════════════════════

if array.size(activeModels) > 0
    for i = array.size(activeModels) - 1 to 0
        m = array.get(activeModels, i)
        
        bool hT1 = (m.dir == 1 and high >= m.tp1) or (m.dir == -1 and low <= m.tp1)
        bool hT2 = not na(m.tp2) and ((m.dir == 1 and high >= m.tp2) or (m.dir == -1 and low <= m.tp2))
        bool hSl = (m.dir == 1 and low <= m.sl) or (m.dir == -1 and high >= m.sl)
        
        if m.status == 0
            if hT1 and hSl
                float dT1 = math.abs(open - m.tp1)
                float dSl = math.abs(open - m.sl)
                if dT1 < dSl
                    m.status := na(m.tp2) ? 2 : 1
                else
                    m.status := -1
            else if hSl
                m.status := -1
            else if hT2
                m.status := 2
            else if hT1
                m.status := na(m.tp2) ? 2 : 1
                
        else if m.status == 1
            if hT2 and hSl
                float dT2 = math.abs(open - m.tp2)
                float dSl = math.abs(open - m.sl)
                m.status := dT2 < dSl ? 2 : 3
            else if hT2
                m.status := 2
            else if hSl
                m.status := 3

        if m.status != 0 and m.status != 1
            m.closeTime := time
            int ix = f_idx(m.mtype, m.dir)
            if m.status == 2
                if m.mtype == 2
                    array.set(sT2, ix, array.get(sT2, ix) + 1)
                array.set(sT1, ix, array.get(sT1, ix) + 1)
                if iAlertTp
                    alert("CRT Target Reached", alert.freq_once_per_bar)
            else if m.status == -1
                array.set(sL, ix, array.get(sL, ix) + 1)
                if iAlertSl
                    alert("CRT Stop Loss Hit", alert.freq_once_per_bar)
            else if m.status == 3
                array.set(sT1, ix, array.get(sT1, ix) + 1)
                
            if iShowHist
                color baseCol = f_getCol(m.mtype, m.dir, false)
                color baseBor = f_getBor(m.mtype, m.dir, false)
                
                box.set_bgcolor(m.bx, baseCol)
                box.set_border_color(m.bx, baseBor)
                box.set_right(m.bx, time)
                
                line.set_x2(m.lnTp1, time)
                line.set_x2(m.lnSl, time)
                if not na(m.lnTp2)
                    line.set_x2(m.lnTp2, time)
                
                color t1c = color.new(cTpLine, 80)
                color t2c = color.new(cTpLine, 80)
                color slc = color.new(cSlLine, 80)
                string lTxt = m.id
                
                if m.status == 2
                    if m.mtype == 2
                        t2c := color.new(cTpLine, 0)
                    else
                        t1c := color.new(cTpLine, 0)
                    lTxt := m.id + " ✓"
                else if m.status == 1 or m.status == 3
                    t1c := color.new(cTpLine, 0)
                    slc := color.new(cSlLine, 0)
                    lTxt := m.id + " BE"
                else if m.status == -1
                    slc := color.new(cSlLine, 0)
                    lTxt := m.id + " ✗"
                    
                line.set_color(m.lnTp1, t1c)
                if not na(m.lnTp2)
                    line.set_color(m.lnTp2, t2c)
                line.set_color(m.lnSl, slc)
                
                label.set_text(m.lbl, lTxt)
                label.set_color(m.lbl, baseBor)
                label.set_x(m.lbl, time)
            else
                f_clearAll(m)
                
            array.push(histModels, m)
            while array.size(histModels) > iMaxHistVis
                f_clearAll(array.shift(histModels))
            array.remove(activeModels, i)
        else
            box.set_right(m.bx, time)
            line.set_x2(m.lnTp1, time)
            line.set_x2(m.lnSl, time)
            if not na(m.lnTp2)
                line.set_x2(m.lnTp2, time)
            label.set_x(m.lbl, time)
            if m.status == 1 and not na(m.lnTp2)
                line.set_width(m.lnTp1, 2)

// ═══════════════════════════════════════════════════════════════════════════════
// STATS TABLE
// ═══════════════════════════════════════════════════════════════════════════════

if iShowStats and barstate.islast
    string p = iStatsPos == "Top Right" ? position.top_right : iStatsPos == "Top Left" ? position.top_left : iStatsPos == "Bottom Left" ? position.bottom_left : position.bottom_right
    table tbl = table.new(p, 5, 8, bgcolor=color.new(color.black, iStatsTrans), border_color=color.new(color.gray, iStatsTrans), border_width=1, frame_color=color.new(color.gray, iStatsTrans), frame_width=1)
    
    table.cell(tbl, 0, 0, "Model", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, "T1", text_color=color.white, text_size=size.small)
    table.cell(tbl, 2, 0, "T2", text_color=color.white, text_size=size.small)
    table.cell(tbl, 3, 0, "Loss", text_color=color.white, text_size=size.small)
    table.cell(tbl, 4, 0, "WR%", text_color=color.white, text_size=size.small)
    
    string[] rL = array.from("M2 ↑", "M2 ↓", "M3 ↑", "M3 ↓", "M3+ ↑", "M3+ ↓")
    color[] rC = array.from(cM2Bull, cM2Bear, cM3Bull, cM3Bear, cM3pBull, cM3pBear)
    
    int tT1 = 0
    int tT2 = 0
    int tL = 0
    
    for r = 0 to 5
        int w = array.get(sT1, r)
        int t2 = array.get(sT2, r)
        int l = array.get(sL, r)
        int tot = w + l
        string wr = tot > 0 ? str.tostring(math.round(w * 100.0 / tot)) + "%" : "—"
        
        tT1 += w
        tT2 += t2
        tL += l
        
        table.cell(tbl, 0, r+1, array.get(rL, r), text_color=color.white, text_size=size.small, bgcolor=color.new(array.get(rC, r), iStatsTrans))
        table.cell(tbl, 1, r+1, str.tostring(w), text_color=color.white, text_size=size.small)
        table.cell(tbl, 2, r+1, r < 2 ? str.tostring(t2) : "—", text_color=color.white, text_size=size.small)
        table.cell(tbl, 3, r+1, str.tostring(l), text_color=color.white, text_size=size.small)
        table.cell(tbl, 4, r+1, wr, text_color=color.white, text_size=size.small)
        
    string tWr = (tT1 + tL) > 0 ? str.tostring(math.round(tT1 * 100.0 / (tT1 + tL))) + "%" : "—"
    table.cell(tbl, 0, 7, "TOTAL", text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(tT1), text_color=color.white, text_size=size.small)
    table.cell(tbl, 2, 7, str.tostring(tT2), text_color=color.white, text_size=size.small)
    table.cell(tbl, 3, 7, str.tostring(tL), text_color=color.white, text_size=size.small)
    table.cell(tbl, 4, 7, tWr, text_color=color.yellow, text_size=size.small)
````
