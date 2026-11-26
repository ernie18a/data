# PWVP PDVP OVP

- url: https://www.tradingview.com/script/Ww2hEvnR/
- type: indicator
- pine_id: PUB;36a04775ef9443be9de3aff89e976117
- version: 1.0

## Description

prev week vp levels: sunday open-friday close
prev day rth vp levels: 9:30-16:00
overnight vp levels: 18:00-9:29

## Source Code

````pine
//@version=6
// =============================================================================
//  TRIPLE FRVP — Weekly / Previous Day / Overnight (New York)  v7
// =============================================================================
indicator("Triple FRVP — NY v7", overlay=true, max_polylines_count=100, max_lines_count=200, max_labels_count=200)

TZ  = "America/New_York"
DAY = 24 * 60 * 60 * 1000

// ============================ INPUT ============================
g = "Generale"
ltf        = input.timeframe("1",  "Timeframe di calcolo", group=g)
rows       = input.int(100,   "Righe",           minval=10,  maxval=1000, group=g)
vaPct      = input.float(70,  "Value Area %",    minval=10,  maxval=99,   group=g) / 100.0
widthBars  = input.int(60,    "Larghezza istogramma (barre)", minval=5, maxval=500, group=g)
placeLeft  = input.string("Sinistra","Posizionamento", options=["Sinistra","Destra"], group=g) == "Sinistra"
showBuySell= input.bool(true, "Distingui acquisti/vendite", group=g)

gl = "Linee livelli"
showPoc = input.bool(true, "Mostra POC", group=gl)
showVah = input.bool(true, "Mostra VAH", group=gl)
showVal = input.bool(true, "Mostra VAL", group=gl)
lwPoc   = input.int(2, "Spessore POC",     minval=1, maxval=5, group=gl)
lwVa    = input.int(1, "Spessore VAH/VAL", minval=1, maxval=5, group=gl)
lsPocS  = input.string("Solida",   "Stile POC",     options=["Solida","Tratteggiata","Punteggiata"], group=gl)
lsVaS   = input.string("Solida",   "Stile VAH/VAL", options=["Solida","Tratteggiata","Punteggiata"], group=gl)

glab = "Etichette"
showLabels = input.bool(true,       "Mostra etichette",             group=glab)
labSize    = input.string("Normale","Dimensione", options=["Piccola","Normale","Grande"], group=glab)
labOffset  = input.int(3,           "Distanza a destra (barre)",    group=glab, minval=0, maxval=50)
labPrice   = input.bool(true,       "Mostra prezzo nell'etichetta", group=glab)

gh = "Livelli storici"
histN      = input.int(2,  "N. sessioni storiche", minval=0, maxval=6, group=gh)
histTransp = input.int(55, "Trasparenza storici",  minval=0, maxval=90, group=gh)
histDate   = input.bool(true, "Data nell'etichetta storica", group=gh)

gw = "1) Weekly"
wShow   = input.bool(true, "Mostra", group=gw)
wPfx    = input.string("W",  "Prefisso", group=gw)
wOpenH  = input.int(18, "Apertura dom — ora",    minval=0, maxval=23, group=gw)
wOpenM  = input.int(0,  "Apertura dom — minuto", minval=0, maxval=59, group=gw)
wCloseH = input.int(16, "Chiusura ven — ora",    minval=0, maxval=23, group=gw)
wCloseM = input.int(0,  "Chiusura ven — minuto", minval=0, maxval=59, group=gw)
wBuy    = input.color(color.new(#26a69a, 35), "Vol acquisti",     group=gw)
wSell   = input.color(color.new(#26a69a, 70), "Vol vendite",      group=gw)
wVaBuy  = input.color(color.new(#80cbc4, 25), "VA acquisti",      group=gw)
wVaSell = input.color(color.new(#80cbc4, 55), "VA vendite",       group=gw)
wPoc    = input.color(color.red,   "POC",     group=gw)
wVa     = input.color(color.aqua,  "VAH/VAL", group=gw)

gd = "2) Previous Day (RTH)"
dShow   = input.bool(true, "Mostra", group=gd)
dPfx    = input.string("PD", "Prefisso", group=gd)
dOpenH  = input.int(9,  "Apertura — ora",    minval=0, maxval=23, group=gd)
dOpenM  = input.int(30, "Apertura — minuto", minval=0, maxval=59, group=gd)
dCloseH = input.int(16, "Chiusura — ora",    minval=0, maxval=23, group=gd)
dCloseM = input.int(0,  "Chiusura — minuto", minval=0, maxval=59, group=gd)
dBuy    = input.color(color.new(#ff9800, 35), "Vol acquisti",     group=gd)
dSell   = input.color(color.new(#ff9800, 70), "Vol vendite",      group=gd)
dVaBuy  = input.color(color.new(#ffcc80, 25), "VA acquisti",      group=gd)
dVaSell = input.color(color.new(#ffcc80, 55), "VA vendite",       group=gd)
dPoc    = input.color(color.red,    "POC",     group=gd)
dVa     = input.color(color.yellow, "VAH/VAL", group=gd)

gn = "3) Overnight"
nShow   = input.bool(true, "Mostra", group=gn)
nPfx    = input.string("O",  "Prefisso", group=gn)
nOpenH  = input.int(18, "Inizio — ora",    minval=0, maxval=23, group=gn)
nOpenM  = input.int(0,  "Inizio — minuto", minval=0, maxval=59, group=gn)
nCloseH = input.int(9,  "Fine — ora",      minval=0, maxval=23, group=gn)
nCloseM = input.int(29, "Fine — minuto",   minval=0, maxval=59, group=gn)
nBuy    = input.color(color.new(#ab47bc, 35), "Vol acquisti",     group=gn)
nSell   = input.color(color.new(#ab47bc, 70), "Vol vendite",      group=gn)
nVaBuy  = input.color(color.new(#ce93d8, 25), "VA acquisti",      group=gn)
nVaSell = input.color(color.new(#ce93d8, 55), "VA vendite",       group=gn)
nPoc    = input.color(color.red,     "POC",     group=gn)
nVa     = input.color(color.fuchsia, "VAH/VAL", group=gn)
nDev    = input.bool(true, "Mostra overnight in sviluppo (dalle 18:00)", group=gn)

wOpen=wOpenH*60+wOpenM, wClose=wCloseH*60+wCloseM
dOpen=dOpenH*60+dOpenM, dClose=dCloseH*60+dCloseM
nOpen=nOpenH*60+nOpenM, nClose=nCloseH*60+nCloseM

f_ls(string s) => s=="Tratteggiata" ? line.style_dashed : s=="Punteggiata" ? line.style_dotted : line.style_solid
labSz = labSize=="Piccola" ? size.small : labSize=="Grande" ? size.large : size.normal

// ============================ TIPI ============================
type Prof
    array<float> buy
    array<float> sell
    float minP
    float maxP
    float binSize
    int   pocBin
    int   vahBin
    int   valBin
    float maxTot

type Saved
    Prof prof
    int  startT
    int  endT

type Sess
    int activeId
    int startT
    int lastT
    array<float> hi
    array<float> lo
    array<float> bv
    array<float> sv
    array<Saved> store

newSess() => Sess.new(na, na, na, array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<Saved>())

// ============================ PROFILO ============================
buildProf(array<float> aHi, array<float> aLo, array<float> aBv, array<float> aSv) =>
    Prof res = na
    int sz = array.size(aHi)
    if sz > 0
        float minP = array.min(aLo)
        float maxP = array.max(aHi)
        if maxP > minP
            float binSize = (maxP - minP) / rows
            array<float> buy  = array.new<float>(rows, 0.0)
            array<float> sell = array.new<float>(rows, 0.0)
            for i = 0 to sz - 1
                float h  = array.get(aHi, i)
                float l  = array.get(aLo, i)
                float bvv= array.get(aBv, i)
                float svv= array.get(aSv, i)
                int b0 = math.max(0, math.min(rows-1, int(math.floor((l-minP)/binSize))))
                int b1 = math.max(0, math.min(rows-1, int(math.floor((h-minP)/binSize))))
                int nb = b1 - b0 + 1
                for bi = b0 to b1
                    array.set(buy,  bi, array.get(buy,  bi) + bvv/nb)
                    array.set(sell, bi, array.get(sell, bi) + svv/nb)
            int pocBin = 0
            float maxTot = 0.0
            for i = 0 to rows - 1
                float tt = array.get(buy, i) + array.get(sell, i)
                if tt > maxTot
                    maxTot := tt
                    pocBin := i
            float total = 0.0
            for i = 0 to rows - 1
                total += array.get(buy, i) + array.get(sell, i)
            float acc = array.get(buy, pocBin) + array.get(sell, pocBin)
            int up = pocBin, dn = pocBin
            while acc < total * vaPct and (up < rows-1 or dn > 0)
                float vU = up < rows-1 ? array.get(buy,up+1)+array.get(sell,up+1) : -1.0
                float vD = dn > 0       ? array.get(buy,dn-1)+array.get(sell,dn-1) : -1.0
                if vU >= vD
                    up += 1
                    acc += math.max(vU, 0.0)
                else
                    dn -= 1
                    acc += math.max(vD, 0.0)
            res := Prof.new(buy, sell, minP, maxP, binSize, pocBin, up, dn, maxTot)
    res

// ============================ DISEGNO ============================
var array<polyline> POLYS  = array.new<polyline>()
var array<line>     LINES  = array.new<line>()
var array<label>    LABELS = array.new<label>()

clearAll() =>
    for p in POLYS
        polyline.delete(p)
    array.clear(POLYS)
    for l in LINES
        line.delete(l)
    array.clear(LINES)
    for lb in LABELS
        label.delete(lb)
    array.clear(LABELS)

rangePolys(Prof p, int lo, int hi, int anchorT, float maxW, color totCol, color buyCol) =>
    if hi >= lo and p.maxTot > 0
        float denom = p.maxTot
        array<chart.point> a = array.new<chart.point>()
        array.push(a, chart.point.from_time(anchorT, p.minP + lo*p.binSize))
        for i = lo to hi
            float tot = array.get(p.buy, i) + array.get(p.sell, i)
            int   x   = placeLeft ? anchorT + int(maxW * tot/denom) : anchorT - int(maxW * tot/denom)
            array.push(a, chart.point.from_time(x, p.minP + i*p.binSize))
            array.push(a, chart.point.from_time(x, p.minP + (i+1)*p.binSize))
        array.push(a, chart.point.from_time(anchorT, p.minP + (hi+1)*p.binSize))
        array.push(POLYS, polyline.new(a, closed=true, xloc=xloc.bar_time, line_color=na, fill_color=totCol))
        if showBuySell
            array<chart.point> b = array.new<chart.point>()
            array.push(b, chart.point.from_time(anchorT, p.minP + lo*p.binSize))
            for i = lo to hi
                int x = placeLeft ? anchorT + int(maxW * array.get(p.buy,i)/denom) : anchorT - int(maxW * array.get(p.buy,i)/denom)
                array.push(b, chart.point.from_time(x, p.minP + i*p.binSize))
                array.push(b, chart.point.from_time(x, p.minP + (i+1)*p.binSize))
            array.push(b, chart.point.from_time(anchorT, p.minP + (hi+1)*p.binSize))
            array.push(POLYS, polyline.new(b, closed=true, xloc=xloc.bar_time, line_color=na, fill_color=buyCol))

mkLine(int x1, int x2, float y, color c, int w, string st) =>
    array.push(LINES, line.new(x1, y, x2, y, xloc=xloc.bar_time, color=c, width=w, style=f_ls(st)))

mkLabel(int x, float y, string txt, color c) =>
    if showLabels
        array.push(LABELS, label.new(x, y, txt, xloc=xloc.bar_time, style=label.style_none, textcolor=c, size=labSz))

drawProfile(Saved s, int x2, color buyCol, color sellCol, color vaBuyCol, color vaSellCol, color pocCol, color vaCol, string pfx, bool isActive) =>
    if not na(s)
        Prof p = s.prof
        int barMs  = timeframe.in_seconds() * 1000
        float maxW = widthBars * barMs
        int anchorT = placeLeft ? s.startT : s.endT
        rangePolys(p, 0,          p.valBin-1, anchorT, maxW, sellCol,   buyCol)
        rangePolys(p, p.valBin,   p.vahBin,   anchorT, maxW, vaSellCol, vaBuyCol)
        rangePolys(p, p.vahBin+1, rows-1,     anchorT, maxW, sellCol,   buyCol)
        color pc = isActive ? pocCol : color.new(pocCol, histTransp)
        color vc = isActive ? vaCol  : color.new(vaCol,  histTransp)
        int   wP = isActive ? lwPoc  : 1
        int   wV = isActive ? lwVa   : 1
        string sP = isActive ? lsPocS : "Punteggiata"
        string sV = isActive ? lsVaS  : "Punteggiata"
        string dt = (not isActive and histDate) ? " " + str.format_time(s.startT, "dd/MM", TZ) : ""
        int lblX  = x2 + labOffset * barMs
        float pocP = p.minP + (p.pocBin + 0.5) * p.binSize
        float vahP = p.minP + (p.vahBin + 1) * p.binSize
        float valP = p.minP + p.valBin * p.binSize
        if showPoc
            mkLine(s.startT, x2, pocP, pc, wP, sP)
            mkLabel(lblX, pocP, pfx + "POC" + (labPrice ? " " + str.tostring(pocP, format.mintick) : "") + dt, pc)
        if showVah
            mkLine(s.startT, x2, vahP, vc, wV, sV)
            mkLabel(lblX, vahP, pfx + "VAH" + (labPrice ? " " + str.tostring(vahP, format.mintick) : "") + dt, vc)
        if showVal
            mkLine(s.startT, x2, valP, vc, wV, sV)
            mkLabel(lblX, valP, pfx + "VAL" + (labPrice ? " " + str.tostring(valP, format.mintick) : "") + dt, vc)

drawSet(Sess s, bool show, color buyCol, color sellCol, color vaBuyCol, color vaSellCol, color pocCol, color vaCol, string pfx) =>
    if show
        int sz = array.size(s.store)
        if sz > 0
            drawProfile(array.last(s.store), time, buyCol, sellCol, vaBuyCol, vaSellCol, pocCol, vaCol, pfx, true)
            if histN > 0 and sz > 1
                for hh = 1 to histN
                    int j = sz - 1 - hh
                    if j >= 0
                        Saved hs = array.get(s.store, j)
                        drawProfile(hs, hs.endT, buyCol, sellCol, vaBuyCol, vaSellCol, pocCol, vaCol, pfx, false)

// ============================ MOTORE SESSIONE ============================
process(Sess s, bool show, bool inSess, int sessId, int t, float h, float l, float bv, float sv, int cap) =>
    if show
        if inSess
            if na(s.activeId) or sessId != s.activeId
                array.clear(s.hi), array.clear(s.lo), array.clear(s.bv), array.clear(s.sv)
                s.activeId := sessId
                s.startT   := t
            array.push(s.hi, h), array.push(s.lo, l), array.push(s.bv, bv), array.push(s.sv, sv)
            s.lastT := t
        else
            if not na(s.activeId)
                if array.size(s.hi) > 0
                    Prof p = buildProf(s.hi, s.lo, s.bv, s.sv)
                    if not na(p)
                        array.push(s.store, Saved.new(p, s.startT, s.lastT))
                        while array.size(s.store) > cap
                            array.shift(s.store)
                array.clear(s.hi), array.clear(s.lo), array.clear(s.bv), array.clear(s.sv)
                s.activeId := na

// ============================ SESSIONI ============================
f_week(int t) =>
    int dw = dayofweek(t, TZ)
    int td = hour(t,TZ)*60 + minute(t,TZ)
    bool inS = (dw==1 and td>=wOpen) or (dw>=2 and dw<=5) or (dw==6 and td<=wClose)
    int sun = timestamp(TZ, year(t,TZ), month(t,TZ), dayofmonth(t,TZ), 0, 0) - (dw-1)*DAY + 12*60*60*1000
    int id  = year(sun,TZ)*10000 + month(sun,TZ)*100 + dayofmonth(sun,TZ)
    [inS, id]

f_rth(int t) =>
    int dw = dayofweek(t, TZ)
    int td = hour(t,TZ)*60 + minute(t,TZ)
    bool inS = (dw>=2 and dw<=6) and td>=dOpen and td<dClose
    int id  = year(t,TZ)*10000 + month(t,TZ)*100 + dayofmonth(t,TZ)
    [inS, id]

f_on(int t) =>
    int td = hour(t,TZ)*60 + minute(t,TZ)
    bool eve = td >= nOpen
    bool inS = eve or td <= nClose
    int ty = t - DAY
    int id = eve ? (year(t,TZ)*10000+month(t,TZ)*100+dayofmonth(t,TZ)) : (year(ty,TZ)*10000+month(ty,TZ)*100+dayofmonth(ty,TZ))
    [inS, id]

// ============================ STATO ============================
var Sess W = newSess()
var Sess D = newSess()
var Sess N = newSess()

// ============================ SORGENTE DATI ============================
ltfSec   = timeframe.in_seconds(ltf)
chartSec = timeframe.in_seconds()
useLTF   = chartSec > ltfSec

aT = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, time)   : na
aH = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, high)   : na
aL = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, low)    : na
aO = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, open)   : na
aC = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, close)  : na
aV = useLTF ? request.security_lower_tf(syminfo.tickerid, ltf, volume) : na

feed(int st, float sh, float sl, float so, float sc, float vv) =>
    if not na(st) and not na(sh) and not na(sl) and not na(vv)
        float bvol = sc >= so ? vv : 0.0
        float svol = sc >= so ? 0.0 : vv
        [wIn, wId] = f_week(st)
        [rIn, rId] = f_rth(st)
        [oIn, oId] = f_on(st)
        process(W, wShow, wIn, wId, st, sh, sl, bvol, svol, 1 + histN)
        process(D, dShow, rIn, rId, st, sh, sl, bvol, svol, 1 + histN)
        process(N, nShow, oIn, oId, st, sh, sl, bvol, svol, 1 + histN)

if barstate.isconfirmed
    if useLTF
        int nn = na(aT) ? 0 : array.size(aT)
        if nn > 0
            for k = 0 to nn - 1
                feed(array.get(aT,k), array.get(aH,k), array.get(aL,k), array.get(aO,k), array.get(aC,k), array.get(aV,k))
        else
            // lower_tf non disponibile per questa barra (storia lontana) → uso la barra del grafico
            feed(time, high, low, open, close, volume)
    else
        feed(time, high, low, open, close, volume)

// ============================ DISEGNO FINALE ============================
var int lastDraw = na
if barstate.islast and (na(lastDraw) or time != lastDraw)
    lastDraw := time
    clearAll()
    // Profili completati — livelli avanzano col prezzo (x2 = time)
    drawSet(D, dShow, dBuy, dSell, dVaBuy, dVaSell, dPoc, dVa, dPfx)
    drawSet(N, nShow, nBuy, nSell, nVaBuy, nVaSell, nPoc, nVa, nPfx)
    drawSet(W, wShow, wBuy, wSell, wVaBuy, wVaSell, wPoc, wVa, wPfx)
    // Overnight in sviluppo: mostra la sessione che si sta formando dalle 18:00
    if nShow and nDev and not na(N.activeId) and array.size(N.hi) > 0
        Prof devP = buildProf(N.hi, N.lo, N.bv, N.sv)
        if not na(devP)
            Saved devS = Saved.new(devP, N.startT, time)
            drawProfile(devS, time, nBuy, nSell, nVaBuy, nVaSell, nPoc, nVa, nPfx + "dev", true)
````
