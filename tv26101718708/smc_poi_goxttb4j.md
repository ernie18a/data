# SMC POI 

- url: https://www.tradingview.com/script/GOxTTb4j/
- type: indicator
- pine_id: PUB;3c3eb07b55bc4cacafc829395b3120ab
- version: 1.0

## Description

SMC POI DETECTOR

Manipulation SMC, and mark box

Config bar, candle, and pois

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════
//  SMC – POI de Continuidade  v3
//  Pine Script v6
//
//  CORREÇÕES v3:
//  • Caixa POI cobre SOMENTE a perna [BOS1 → FakeCHoCH] — para de
//    acumular extremos assim que o FakeCHoCH é confirmado (Fase 3
//    não acumula mais)
//  • Labels de BOS e FakeCHoCH exibidos SOMENTE nas estruturas que
//    completaram o padrão (evita poluição visual de candidatos falhos)
//  • Filtro de proximidade: ignora novo POI se já existe uma caixa
//    ativa cuja zona se sobrepõe verticalmente (evita duplicatas)
//  • Parâmetros padrão ajustados para melhor resultado no 5min
// ══════════════════════════════════════════════════════════════════════

//@version=6
indicator("SMC – POI Continuidade v3", overlay=true,
          max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────

var string G0 = "⚙️  Estrutura & Detecção"
maxCandles = input.int(25,  "Máx. candles por fase [A]→[D]",
                        minval=6, maxval=150, group=G0,
                        tooltip="Janela máxima (barras) para a sequência completa [A→D]. Candidatos mais velhos expiram.")
swLen      = input.int(3,   "Swing Length [barras cada lado]",
                        minval=1, maxval=15, group=G0,
                        tooltip="Barras confirmadas de cada lado para validar um swing high/low.")
showBull   = input.bool(true, "Detectar Bull POI", group=G0)
showBear   = input.bool(true, "Detectar Bear POI", group=G0)
bosMode    = input.string("High/Low", "Confirmar BOS/FakeCHoCH por",
                        options=["High/Low","Close"], group=G0,
                        tooltip="High/Low: qualquer spike conta (mais sinais). Close: apenas fechamento além do nível (mais conservador).")

var string G1 = "🕯️  Filtros do BOS2 (confirmação)"
atrLen        = input.int(14,    "Período ATR",                   minval=2,  maxval=100, group=G1)
useBodyFilter = input.bool(true,  "Filtrar % do corpo (BOS2)",    group=G1)
minBodyPct    = input.float(35.0, "Corpo mínimo BOS2 (% range)", minval=5.0, maxval=95.0, step=5.0, group=G1,
                        tooltip="O candle BOS2 deve ter |close-open| ≥ X% de (high-low).")
useRangeFilter= input.bool(true,  "Filtrar range vs ATR (BOS2)", group=G1)
minRangeMult  = input.float(0.4,  "Range mínimo BOS2 (× ATR)",  minval=0.1, maxval=5.0,  step=0.1, group=G1,
                        tooltip="O candle BOS2 deve ter range ≥ X × ATR.")
reqDirection  = input.bool(true,  "BOS2 deve ser candle direcional", group=G1,
                        tooltip="Bull POI → BOS2 verde. Bear POI → BOS2 vermelho.")

var string G2 = "📦  Zona POI"
extendBars    = input.int(60,    "Extensão à direita (barras)", minval=0,   maxval=2000, group=G2)
maxBoxes      = input.int(10,    "Máx. zonas simultâneas",      minval=1,   maxval=100,  group=G2,
                        tooltip="Caixas mais antigas são removidas automaticamente quando o limite é atingido.")
mitigClose    = input.bool(true,  "Mitigar ao fechar dentro da zona", group=G2,
                        tooltip="Remove o POI quando o close penetra a zona (POI consumido).")
mitigTouch    = input.bool(false, "Mitigar ao tocar (wick)",          group=G2)
useProximFilt = input.bool(true,  "Filtro de proximidade (anti-duplicata)", group=G2,
                        tooltip="Ignora novo POI se já existe uma caixa ativa que se sobrepõe verticalmente.")

var string G3 = "🎨  Aparência"
bullFill      = input.color(color.new(#00C087, 82), "Fill Bull POI",  group=G3)
bearFill      = input.color(color.new(#FF3B30, 82), "Fill Bear POI",  group=G3)
bullBrd       = input.color(#00C087,                "Borda Bull",      group=G3)
bearBrd       = input.color(#FF3B30,                "Borda Bear",      group=G3)
brdW          = input.int(1,    "Espessura da borda",  minval=1, maxval=4, group=G3)

showZoneLbl   = input.bool(true,  "Label 'POI' na zona",  group=G3)
txtBull       = input.string("POI ▲", "Texto Bull",       group=G3)
txtBear       = input.string("POI ▼", "Texto Bear",       group=G3)

// Labels somente para estruturas COMPLETAS (que geraram POI)
showBOSLbl    = input.bool(true,  "Labels BOS (somente em POIs confirmados)",       group=G3)
showFCLbl     = input.bool(true,  "Label Fake CHoCH (somente em POIs confirmados)", group=G3)

showBOSLines  = input.bool(true,  "Linhas de nível BOS",       group=G3)
bosCol        = input.color(#FFD600, "Cor das linhas BOS",      group=G3)
bosW          = input.int(1,  "Espessura BOS",  minval=1, maxval=4, group=G3)
bosSt         = input.string("Dashed","Estilo BOS", options=["Solid","Dashed","Dotted"], group=G3)
fcCol         = input.color(#FF9800, "Cor label Fake CHoCH",   group=G3)

var string G4 = "🔔  Alertas"
doAlert       = input.bool(true, "Alertar ao criar novo POI", group=G4)

// ─────────────────────────────────────────────────────────────────────────────
//  FUNÇÕES AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

atr = ta.atr(atrLen)

// Filtro de força no BOS2
f_qualBos2() =>
    rng    = high - low
    body   = math.abs(close - open)
    okBody = not useBodyFilter  or (rng > 0 and (body / rng * 100.0) >= minBodyPct)
    okRng  = not useRangeFilter or rng >= minRangeMult * atr
    okBody and okRng

f_isBull() => close >= open
f_isBear() => close <= open

f_lineStyle() =>
    bosSt == "Dashed" ? line.style_dashed :
     bosSt == "Dotted" ? line.style_dotted : line.style_solid

// Penetração de nível
f_above(lvl) => bosMode == "Close" ? close > lvl : high > lvl
f_below(lvl) => bosMode == "Close" ? close < lvl : low  < lvl

// Verifica sobreposição vertical com caixas ativas
f_overlaps(zTop, zBot, liveBoxes) =>
    overlaps = false
    if array.size(liveBoxes) > 0
        for k = 0 to array.size(liveBoxes) - 1
            b  = array.get(liveBoxes, k)
            bT = box.get_top(b)
            bB = box.get_bottom(b)
            // Sobreposição: as zonas se tocam verticalmente
            if zTop >= bB and zBot <= bT
                overlaps := true
                break
    overlaps
// ─────────────────────────────────────────────────────────────────────────────
//  SWINGS INTERNOS
// ─────────────────────────────────────────────────────────────────────────────

swH = ta.pivothigh(high, swLen, swLen)
swL = ta.pivotlow (low,  swLen, swLen)

// ─────────────────────────────────────────────────────────────────────────────
//  ARRAYS DE ESTADO (multi-candidato)
//  Fase 1 → aguarda BOS1
//  Fase 2 → aguarda FakeCHoCH  (acumula extremos da perna)
//  Fase 3 → aguarda BOS2       (NÃO acumula mais extremos — caixa já definida)
// ─────────────────────────────────────────────────────────────────────────────

var int[]   a_typ    = array.new<int>()
var int[]   a_bar0   = array.new<int>()
var float[] a_swLvl  = array.new<float>()
var float[] a_bos1H  = array.new<float>()   // high do candle BOS1
var float[] a_bos1L  = array.new<float>()   // low  do candle BOS1
var int[]   a_bos1B  = array.new<int>()     // bar_index BOS1
var float[] a_fcH    = array.new<float>()   // high acumulado da perna manipulação (fixo após FakeCHoCH)
var float[] a_fcL    = array.new<float>()   // low  acumulado da perna manipulação (fixo após FakeCHoCH)
var int[]   a_fcBarS = array.new<int>()     // barra início da manipulação (= barra BOS1)
var int[]   a_fcBarE = array.new<int>()     // barra do FakeCHoCH confirmado
var int[]   a_phase  = array.new<int>()

// Caixas vivas
var box[]   liveBoxes = array.new<box>()
var int[]   liveTypes = array.new<int>()

// Buffers para labels/linhas pendentes (só desenhados se o POI confirmar)
// Armazenamos como primitivos nos arrays de estado; desenhamos no momento do BOS2.

// ─────────────────────────────────────────────────────────────────────────────
//  REGISTRAR NOVOS CANDIDATOS
// ─────────────────────────────────────────────────────────────────────────────

if not na(swH) and showBull
    swBar = bar_index - swLen
    array.push(a_typ,    1)
    array.push(a_bar0,   swBar)
    array.push(a_swLvl,  swH)
    array.push(a_bos1H,  na)
    array.push(a_bos1L,  na)
    array.push(a_bos1B,  -1)
    array.push(a_fcH,    na)
    array.push(a_fcL,    na)
    array.push(a_fcBarS, -1)
    array.push(a_fcBarE, -1)
    array.push(a_phase,  1)

if not na(swL) and showBear
    swBar = bar_index - swLen
    array.push(a_typ,    -1)
    array.push(a_bar0,   swBar)
    array.push(a_swLvl,  swL)
    array.push(a_bos1H,  na)
    array.push(a_bos1L,  na)
    array.push(a_bos1B,  -1)
    array.push(a_fcH,    na)
    array.push(a_fcL,    na)
    array.push(a_fcBarS, -1)
    array.push(a_fcBarE, -1)
    array.push(a_phase,  1)

// ─────────────────────────────────────────────────────────────────────────────
//  LOOP PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

var int ii = 0
ii := 0

while ii < array.size(a_typ)

    typ   = array.get(a_typ,    ii)
    bar0  = array.get(a_bar0,   ii)
    swLvl = array.get(a_swLvl,  ii)
    b1H   = array.get(a_bos1H,  ii)
    b1L   = array.get(a_bos1L,  ii)
    b1Bar = array.get(a_bos1B,  ii)
    fH    = array.get(a_fcH,    ii)
    fL    = array.get(a_fcL,    ii)
    fBarS = array.get(a_fcBarS, ii)
    fBarE = array.get(a_fcBarE, ii)
    ph    = array.get(a_phase,  ii)
    age   = bar_index - bar0

    // ── Expirar ──────────────────────────────────────────────────────────────
    if age > maxCandles
        array.remove(a_typ,    ii)
        array.remove(a_bar0,   ii)
        array.remove(a_swLvl,  ii)
        array.remove(a_bos1H,  ii)
        array.remove(a_bos1L,  ii)
        array.remove(a_bos1B,  ii)
        array.remove(a_fcH,    ii)
        array.remove(a_fcL,    ii)
        array.remove(a_fcBarS, ii)
        array.remove(a_fcBarE, ii)
        array.remove(a_phase,  ii)
        continue

    // ════════════════════════════════════════════════════════════════════════
    //  FASE 1 — Aguarda BOS1
    // ════════════════════════════════════════════════════════════════════════
    if ph == 1
        bos1hit = (typ ==  1 and f_above(swLvl)) or
                   (typ == -1 and f_below(swLvl))

        if bos1hit
            array.set(a_bos1H,  ii, high)
            array.set(a_bos1L,  ii, low)
            array.set(a_bos1B,  ii, bar_index)
            // Inicia acúmulo da perna com este próprio candle BOS1
            array.set(a_fcH,    ii, high)
            array.set(a_fcL,    ii, low)
            array.set(a_fcBarS, ii, bar_index)
            array.set(a_phase,  ii, 2)

        ii += 1
        continue

    // ════════════════════════════════════════════════════════════════════════
    //  FASE 2 — Aguarda FakeCHoCH
    //  Acumula os extremos candle a candle (High/Low piores da perna)
    //  A caixa POI final cobrirá APENAS esta perna [BOS1 → FakeCHoCH]
    // ════════════════════════════════════════════════════════════════════════
    if ph == 2
        // Acumula extremos da perna de manipulação
        curFH = na(fH) ? high : math.max(fH, high)
        curFL = na(fL) ? low  : math.min(fL, low)
        array.set(a_fcH, ii, curFH)
        array.set(a_fcL, ii, curFL)

        barsSinceBos1 = bar_index - b1Bar

        if barsSinceBos1 >= 1
            fchit = false
            if typ ==  1 and f_below(b1L)
                fchit := true
            if typ == -1 and f_above(b1H)
                fchit := true

            if fchit
                // ── FakeCHoCH confirmado: congela os extremos aqui ──
                // A partir deste ponto (Fase 3) os extremos NÃO mudam mais.
                array.set(a_fcBarE, ii, bar_index)
                array.set(a_phase,  ii, 3)

        ii += 1
        continue

    // ════════════════════════════════════════════════════════════════════════
    //  FASE 3 — Aguarda BOS2 (confirmação)
    //  NÃO acumula mais extremos — a caixa POI já está definida.
    // ════════════════════════════════════════════════════════════════════════
    if ph == 3
        bos2hit = false
        if typ ==  1
            okDir  = not reqDirection or f_isBull()
            bos2hit := f_above(b1H) and f_qualBos2() and okDir
        else
            okDir  = not reqDirection or f_isBear()
            bos2hit := f_below(b1L) and f_qualBos2() and okDir

        if bos2hit
            bxT = array.get(a_fcH,    ii)
            bxB = array.get(a_fcL,    ii)
            bxL = array.get(a_fcBarS, ii)
            bxR = bar_index + extendBars
            if not na(bxT) and not na(bxB) and bxL >= 0
         // --- Filtro de proximidade / anti-duplicata
                skipBox = useProximFilt and f_overlaps(bxT, bxB, liveBoxes)

                if not skipBox
                    bc   = typ ==  1 ? bullFill : bearFill
                    brd  = typ ==  1 ? bullBrd  : bearBrd
                    lTxt = typ ==  1 ? txtBull  : txtBear

                    newB = box.new(bxL, bxT, bxR, bxB,
                                   border_color=brd, border_width=brdW,
                                   bgcolor=bc, xloc=xloc.bar_index)

                    if array.size(liveBoxes) >= maxBoxes
                        box.delete(array.shift(liveBoxes))
                        array.shift(liveTypes)

                    array.push(liveBoxes, newB)
                    array.push(liveTypes, typ)

                    // ── Label central da zona ──────────────────────────────
                    if showZoneLbl
                        midX = bxL + math.round((bar_index - bxL) / 2)
                        midY = (bxT + bxB) / 2.0
                        label.new(midX, midY, lTxt,
                                  style=label.style_label_center,
                                  color=color.new(color.white, 100),
                                  textcolor=brd, size=size.small,
                                  xloc=xloc.bar_index)

                    // ── BOS1: linha + label (retroativo, só se confirmado) ──
                    if showBOSLines
                        ls = f_lineStyle()
                        line.new(b1Bar - 1, swLvl, b1Bar + 3, swLvl,
                                 color=bosCol, width=bosW, style=ls,
                                 xloc=xloc.bar_index)

                    if showBOSLbl
                        lbl_y1 = typ == 1 ? high[bar_index - b1Bar] + atr * 0.3
                                          : low[bar_index - b1Bar]  - atr * 0.3
                        lbl_st = typ == 1 ? label.style_label_down : label.style_label_up
                        // BOS1 label no nível do swing
                        label.new(b1Bar,
                                  typ == 1 ? swLvl + atr * 0.3 : swLvl - atr * 0.3,
                                  "BOS",
                                  style=lbl_st, color=color.new(bosCol, 20),
                                  textcolor=color.white, size=size.tiny,
                                  xloc=xloc.bar_index)

                    // ── FakeCHoCH label (retroativo, só se confirmado) ─────
                    if showFCLbl
                        fcBarE_ = array.get(a_fcBarE, ii)
                        if fcBarE_ >= 0
                            fcIdx  = bar_index - fcBarE_
                            yPos   = typ ==  1 ? low[fcIdx]  - atr * 0.5
                                               : high[fcIdx] + atr * 0.5
                            lstyle = typ ==  1 ? label.style_label_up
                                               : label.style_label_down
                            label.new(fcBarE_, yPos, "Fake CHoCH",
                                      style=lstyle,
                                      color=color.new(fcCol, 10),
                                      textcolor=color.white, size=size.tiny,
                                      xloc=xloc.bar_index)

                    // ── BOS2: linha + label ────────────────────────────────
                    if showBOSLines
                        ls  = f_lineStyle()
                        lvl = typ ==  1 ? b1H : b1L
                        line.new(bar_index - 1, lvl, bar_index + 3, lvl,
                                 color=bosCol, width=bosW, style=ls,
                                 xloc=xloc.bar_index)

                    if showBOSLbl
                        lbl_st2 = typ == 1 ? label.style_label_down : label.style_label_up
                        label.new(bar_index,
                                  typ == 1 ? high + atr * 0.3 : low - atr * 0.3,
                                  "BOS",
                                  style=lbl_st2, color=color.new(bosCol, 20),
                                  textcolor=color.white, size=size.tiny,
                                  xloc=xloc.bar_index)

                    if doAlert
                        alert("SMC POI " + (typ == 1 ? "Bull ▲" : "Bear ▼") +
                              " confirmado @ " +
                              str.tostring(math.round((bxT + bxB) / 2.0, 2)),
                              alert.freq_once_per_bar_close)

            // Remove candidato resolvido (independente do filtro)
            array.remove(a_typ,    ii)
            array.remove(a_bar0,   ii)
            array.remove(a_swLvl,  ii)
            array.remove(a_bos1H,  ii)
            array.remove(a_bos1L,  ii)
            array.remove(a_bos1B,  ii)
            array.remove(a_fcH,    ii)
            array.remove(a_fcL,    ii)
            array.remove(a_fcBarS, ii)
            array.remove(a_fcBarE, ii)
            array.remove(a_phase,  ii)
            continue   // não incrementa ii

        ii += 1
        continue

    ii += 1

// ─────────────────────────────────────────────────────────────────────────────
//  GERENCIAMENTO DAS ZONAS ATIVAS (extensão + mitigação)
// ─────────────────────────────────────────────────────────────────────────────

var int jj = 0
jj := 0

while jj < array.size(liveBoxes)
    b   = array.get(liveBoxes, jj)
    bT  = array.get(liveTypes, jj)
    zT  = box.get_top(b)
    zB  = box.get_bottom(b)

    mit = false
    if mitigClose
        // Bull: mitigado quando close fecha ABAIXO da base do POI
        // Bear: mitigado quando close fecha ACIMA do topo do POI
        mit := (bT ==  1 and close < zB) or
               (bT == -1 and close > zT)
    if mitigTouch and not mit
        mit := (bT ==  1 and low   < zB) or
               (bT == -1 and high  > zT)

    if mit
        box.delete(b)
        array.remove(liveBoxes, jj)
        array.remove(liveTypes, jj)
        continue

    box.set_right(b, bar_index + extendBars)
    jj += 1

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTCONDITION
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(true, "SMC POI v3 – Novo POI", "Nova zona POI SMC confirmada.")
````
