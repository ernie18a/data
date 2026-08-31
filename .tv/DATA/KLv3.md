<!-- tradingview-pine-id: PUB;0e4520fc617e496d84db1afafb185deb -->
<!-- tradingviewscripts-format: 1 -->
# KLv3

Source: https://www.tradingview.com/script/7Z3GNIgl/

## Description

piazza kl da solo , facendo uno studio multitimeframe.

---

## Source Code

````pine
//@version=6
indicator("KLv3", shorttitle="KLv3", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// Script dedicato a XAUUSD (OANDA) - Livelli Ancorati e Fissi
// Tabelle Dashboard Compatte e Ottimizzate
// ============================================================

// ============ INPUT ============
grpGen = "Impostazioni generali"
lookbackDays = input.int(90, "Giorni di storico da analizzare", minval=1, group=grpGen)
leftBars = input.int(3, "Fractal - barre a sinistra", minval=1, maxval=30, group=grpGen)
rightBars = input.int(3, "Fractal - barre a destra", minval=1, maxval=30, group=grpGen)

grpMerge = "Filtro anti-affollamento (Distanza Livelli)"
mergeDistancePips = input.float(10.0, "Soglia accorpamento pivot (pips)", minval=0.0, step=1.0, group=grpMerge)
minLevelDistancePips = input.float(20.0, "Distanza MINIMA tra linee (pips)", minval=1.0, step=1.0, group=grpMerge)

grpFilter = "Filtro anti-breakout (Role Reversal)"
maxOvershootPips = input.float(15.0, "Overshoot max consentito (pips)", minval=0.0, step=0.5, group=grpFilter)
pipSize = input.float(0.1, "Valore di 1 pip in prezzo (XAUUSD)", minval=0.00001, step=0.0001, group=grpFilter)

grpTF = "Timeframe da analizzare"
showW  = input.bool(true, "Mostra Weekly", group=grpTF)
showD  = input.bool(true, "Mostra Daily", group=grpTF)
showH4 = input.bool(true, "Mostra H4", group=grpTF)
showH1 = input.bool(true, "Mostra H1", group=grpTF)

grpScore = "Score & Punteggio (Max 300)"
scoreThreshold = input.int(80, "Score minimo da visualizzare", minval=0, maxval=300, group=grpScore)
minKLCount     = input.int(5, "Numero minimo di KL da mostrare", minval=0, maxval=50, group=grpScore)
maxPipsPointsCap = input.float(50.0, "Tetto Massimo punti per Reazione Pips", minval=10.0, maxval=100.0, step=5.0, group=grpScore)

grpStyle = "Stile"
colKL                 = input.color(color.new(color.purple, 0), "Colore linea KL", group=grpStyle)
colTxt                = input.color(color.white, "Colore testo etichetta", group=grpStyle)
labelOffsetPips       = input.float(30.0, "Distanza etichetta (in pips)", minval=0.0, maxval=1000.0, step=5.0, group=grpStyle)
showFirstTouchCircles = input.bool(true, "Mostra cerchi sul primo tocco", group=grpStyle)
colFirstSup           = input.color(color.new(color.lime, 0), "Colore cerchio supporto", group=grpStyle)
colFirstRes           = input.color(color.new(color.red, 0), "Colore cerchio resistenza", group=grpStyle)

grpTable = "Impostazioni Tabella Dashboard"
showTable        = input.bool(true, "Mostra Tabella Livelli Chiave (Origine)", group=grpTable)
tablePosStr      = input.string("In alto a destra", "Posizione Tabella Origine", options=["In alto a destra", "In basso a destra", "In alto a sinistra", "In basso a sinistra"], group=grpTable)

showScoreTable   = input.bool(true, "Mostra Tabella Dettaglio Score", group=grpTable)
scoreTablePosStr = input.string("In basso a destra", "Posizione Tabella Score", options=["In alto a destra", "In basso a destra", "In alto a sinistra", "In basso a sinistra"], group=grpTable)

// ============ SOGLIE FILTRO ============
maxOvershoot      = maxOvershootPips * pipSize
mergeDistPrice    = mergeDistancePips * pipSize
minLevelDistPrice = minLevelDistancePips * pipSize

// ============ RECUPERO RIGIDO DEI PIVOT ============
f_get_pivots(tfStr, isEnabled) =>
    float ph = na
    float pl = na
    int   pTime = na
    if isEnabled
        ph    := request.security(syminfo.tickerid, tfStr, ta.pivothigh(high, leftBars, rightBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        pl    := request.security(syminfo.tickerid, tfStr, ta.pivotlow(low, leftBars, rightBars),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        pTime := request.security(syminfo.tickerid, tfStr, time[rightBars], lookahead=barmerge.lookahead_off)
    [ph, pl, pTime]

[pH_W,  pL_W,  t_W]  = f_get_pivots("W",   showW)
[pH_D,  pL_D,  t_D]  = f_get_pivots("D",   showD)
[pH_H4, pL_H4, t_H4] = f_get_pivots("240", showH4)
[pH_H1, pL_H1, t_H1] = f_get_pivots("60",  showH1)

type PivotNode
    float price
    string tf
    bool isHigh
    int tStamp
    float reactionPips 

var array<PivotNode> allPivots = array.new<PivotNode>()

f_store_pivot(price, tfLabel, isHigh, tStamp) =>
    limitTime = timenow - (lookbackDays * 86400000)
    if not na(price) and not na(tStamp) and tStamp >= limitTime
        exists = false
        if array.size(allPivots) > 0
            for i = 0 to array.size(allPivots) - 1
                node = array.get(allPivots, i)
                if math.abs(node.price - price) < 0.001 and node.tf == tfLabel and node.tStamp == tStamp
                    exists := true
                    break
        if not exists
            array.push(allPivots, PivotNode.new(price, tfLabel, isHigh, tStamp, 0.0))

f_store_pivot(pH_W,  "W",  true,  t_W)
f_store_pivot(pL_W,  "W",  false, t_W)
f_store_pivot(pH_D,  "D",  true,  t_D)
f_store_pivot(pL_D,  "D",  false, t_D)
f_store_pivot(pH_H4, "H4", true,  t_H4)
f_store_pivot(pL_H4, "H4", false, t_H4)
f_store_pivot(pH_H1, "H1", true,  t_H1)
f_store_pivot(pL_H1, "H1", false, t_H1)

// ============ BLOCCO DATI DI FONDO SU H1 (COERENZA MULTI-TF) ============
H1_high  = request.security(syminfo.tickerid, "60", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
H1_low   = request.security(syminfo.tickerid, "60", low,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
H1_time  = request.security(syminfo.tickerid, "60", time, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ============ RENDERING E CALCOLI SULL'ULTIMA BARRA ============
var array<line>  drawnLines  = array.new<line>()
var array<label> drawnLabels = array.new<label>()

if barstate.islast
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))
    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))

    xPosTime = H1_time + (30 * 3600 * 1000)
    nPivots = array.size(allPivots)

    // --- FASE 0: ORDINE CRONOLOGICO E CALCOLO REAZIONI SU BASE H1 ---
    if nPivots > 0
        int[] times = array.new<int>()
        for i = 0 to nPivots - 1
            array.push(times, array.get(allPivots, i).tStamp)
        
        int[] sortedIdxPivots = array.sort_indices(times)
        PivotNode[] sortedPivots = array.new<PivotNode>()
        for i = 0 to nPivots - 1
            array.push(sortedPivots, array.get(allPivots, array.get(sortedIdxPivots, i)))
        allPivots := sortedPivots

        for i = 0 to nPivots - 1
            node = array.get(allPivots, i)
            float distReaction = 0.0
            
            if node.isHigh
                float minReached = node.price
                bool isBroken = false
                if i < nPivots - 1
                    for j = i + 1 to nPivots - 1
                        nextNode = array.get(allPivots, j)
                        if nextNode.price < minReached
                            minReached := nextNode.price
                        if nextNode.price > node.price
                            isBroken := true
                            break
                if not isBroken
                    minReached := math.min(minReached, H1_low)
                distReaction := node.price - minReached
            else
                float maxReached = node.price
                bool isBroken = false
                if i < nPivots - 1
                    for j = i + 1 to nPivots - 1
                        nextNode = array.get(allPivots, j)
                        if nextNode.price > maxReached
                            maxReached := nextNode.price
                        if nextNode.price < node.price
                            isBroken := true
                            break
                if not isBroken
                    maxReached := math.max(maxReached, H1_high)
                distReaction := maxReached - node.price
                
            float reactPips = distReaction / pipSize
            node.reactionPips := reactPips 
            array.set(allPivots, i, node)


    // --- FASE 1: RAGGRUPPAMENTO LIVELLI ---
    lvlPrice        = array.new<float>()
    lvlResCount     = array.new<int>()
    lvlSupCount     = array.new<int>()
    lvlTFs          = array.new<string>()
    lvlMaxWeight    = array.new<float>()
    lvlFirstResT    = array.new<int>()
    lvlFirstSupT    = array.new<int>()
    lvlOriginIsHigh = array.new<bool>()
    lvlConfirmed    = array.new<bool>()
    lvlMaxReactPips = array.new<float>() 
    lvlTouchPts     = array.new<float>() 

    if nPivots > 0
        for i = 0 to nPivots - 1
            node = array.get(allPivots, i)
            p = node.price
            tfL = node.tf
            
            matched = -1
            nLvl = array.size(lvlPrice)
            if nLvl > 0
                for j = 0 to nLvl - 1
                    if math.abs(array.get(lvlPrice, j) - p) <= mergeDistPrice
                        matched := j
                        break

            baseW = tfL == "W" ? 90.0 : tfL == "D" ? 60.0 : tfL == "H4" ? 30.0 : 10.0
            tPts = tfL == "W" ? 12.0 : tfL == "D" ? 8.0 : tfL == "H4" ? 5.0 : 2.0

            if matched == -1
                array.push(lvlPrice, p)
                array.push(lvlResCount, node.isHigh ? 1 : 0)
                array.push(lvlSupCount, node.isHigh ? 0 : 1)
                array.push(lvlTFs, tfL)
                array.push(lvlMaxWeight, baseW)
                array.push(lvlFirstResT, node.isHigh ? node.tStamp : na)
                array.push(lvlFirstSupT, node.isHigh ? na : node.tStamp)
                array.push(lvlOriginIsHigh, node.isHigh)
                array.push(lvlConfirmed, false)
                array.push(lvlMaxReactPips, node.reactionPips)
                array.push(lvlTouchPts, tPts)
            else
                if node.isHigh
                    array.set(lvlResCount, matched, array.get(lvlResCount, matched) + 1)
                    if na(array.get(lvlFirstResT, matched)) or node.tStamp < array.get(lvlFirstResT, matched)
                        array.set(lvlFirstResT, matched, node.tStamp)
                else
                    array.set(lvlSupCount, matched, array.get(lvlSupCount, matched) + 1)
                    if na(array.get(lvlFirstSupT, matched)) or node.tStamp < array.get(lvlFirstSupT, matched)
                        array.set(lvlFirstSupT, matched, node.tStamp)

                existingTFs = array.get(lvlTFs, matched)
                if not str.contains(existingTFs, tfL)
                    array.set(lvlTFs, matched, existingTFs + "," + tfL)
                
                if baseW > array.get(lvlMaxWeight, matched)
                    array.set(lvlMaxWeight, matched, baseW)

                if node.reactionPips > array.get(lvlMaxReactPips, matched)
                    array.set(lvlMaxReactPips, matched, node.reactionPips)

                array.set(lvlTouchPts, matched, array.get(lvlTouchPts, matched) + tPts)

                originWasHigh = array.get(lvlOriginIsHigh, matched)
                if node.isHigh != originWasHigh
                    distToOrigin = math.abs(p - array.get(lvlPrice, matched))
                    if distToOrigin <= maxOvershoot
                        array.set(lvlConfirmed, matched, true)

    // --- FASE 2: CALCOLO DELLO SCORE ---
    validPrice  = array.new<float>()
    validScore  = array.new<float>()
    validTF     = array.new<string>()
    validNTF    = array.new<int>()
    validFResT  = array.new<int>()
    validFSupT  = array.new<int>()
    validOrigin = array.new<bool>() 
    
    validBasePts      = array.new<float>()
    validConflPts     = array.new<float>()
    validTouchPts     = array.new<float>()
    validPipsPts      = array.new<float>()
    validMaxPips      = array.new<float>() 
    validTotalTouches = array.new<int>() 

    nLvlTotal = array.size(lvlPrice)
    if nLvlTotal > 0
        for j = 0 to nLvlTotal - 1
            isLevelConfirmed = array.get(lvlConfirmed, j)

            if isLevelConfirmed
                lvl = array.get(lvlPrice, j)
                tfList = array.get(lvlTFs, j)
                maxW = array.get(lvlMaxWeight, j)
                nTF = array.size(str.split(tfList, ","))
                
                float conflPts = 0.0
                if nTF >= 4
                    conflPts := 80.0
                else if nTF == 3
                    conflPts := 50.0
                else if nTF == 2
                    conflPts := 25.0

                float touchPts = array.get(lvlTouchPts, j)
                int totalTouches = array.get(lvlResCount, j) + array.get(lvlSupCount, j)
                
                float maxPips = array.get(lvlMaxReactPips, j)
                float pipsPtsRaw = math.floor(maxPips / 100.0) * 2.0
                float pipsPts = math.min(pipsPtsRaw, maxPipsPointsCap) 

                float rawScore = maxW + conflPts + touchPts + pipsPts
                float finalScore = math.min(rawScore, 300.0)

                array.push(validPrice, lvl)
                array.push(validScore, finalScore)
                array.push(validTF, tfList)
                array.push(validNTF, nTF)
                array.push(validFResT, array.get(lvlFirstResT, j))
                array.push(validFSupT, array.get(lvlFirstSupT, j))
                array.push(validOrigin, array.get(lvlOriginIsHigh, j))
                
                array.push(validBasePts, maxW)
                array.push(validConflPts, conflPts)
                array.push(validTouchPts, touchPts)
                array.push(validPipsPts, pipsPts)
                array.push(validMaxPips, maxPips)
                array.push(validTotalTouches, totalTouches)

    // --- FASE 3: DEDUPLICAZIONE GRAFICA ---
    nValid = array.size(validScore)
    
    dedupPrices = array.new<float>()
    dedupScores = array.new<float>()
    dedupTF     = array.new<string>()
    dedupNTF    = array.new<int>()
    dedupFResT  = array.new<int>()
    dedupFSupT  = array.new<int>()
    dedupOrigin = array.new<bool>() 
    dedupBasePts      = array.new<float>()
    dedupConflPts     = array.new<float>()
    dedupTouchPts     = array.new<float>()
    dedupPipsPts      = array.new<float>()
    dedupMaxPips      = array.new<float>()
    dedupTotalTouches = array.new<int>()

    if nValid > 0
        sortedIdx = array.sort_indices(validScore, order.descending)
        for rank = 0 to nValid - 1
            idx = array.get(sortedIdx, rank)
            pCandidate = array.get(validPrice, idx)
            
            tooClose = false
            if array.size(dedupPrices) > 0
                for f = 0 to array.size(dedupPrices) - 1
                    if math.abs(array.get(dedupPrices, f) - pCandidate) < minLevelDistPrice
                        tooClose := true
                        break
            
            if not tooClose
                array.push(dedupPrices, pCandidate)
                array.push(dedupScores, array.get(validScore, idx))
                array.push(dedupTF, array.get(validTF, idx))
                array.push(dedupNTF, array.get(validNTF, idx))
                array.push(dedupFResT, array.get(validFResT, idx))
                array.push(dedupFSupT, array.get(validFSupT, idx))
                array.push(dedupOrigin, array.get(validOrigin, idx))
                array.push(dedupBasePts, array.get(validBasePts, idx))
                array.push(dedupConflPts, array.get(validConflPts, idx))
                array.push(dedupTouchPts, array.get(validTouchPts, idx))
                array.push(dedupPipsPts, array.get(validPipsPts, idx))
                array.push(dedupMaxPips, array.get(validMaxPips, idx))
                array.push(dedupTotalTouches, array.get(validTotalTouches, idx))

    // --- FASE 3.5: ORDINAMENTO DECRESCENTE PER PREZZO DEI KL ---
    finalPrices = array.new<float>()
    finalScores = array.new<float>()
    finalTF     = array.new<string>()
    finalNTF    = array.new<int>()
    finalFResT  = array.new<int>()
    finalFSupT  = array.new<int>()
    finalOrigin = array.new<bool>() 
    finalBasePts      = array.new<float>()
    finalConflPts     = array.new<float>()
    finalTouchPts     = array.new<float>()
    finalPipsPts      = array.new<float>()
    finalMaxPips      = array.new<float>()
    finalTotalTouches = array.new<int>()

    nDedup = array.size(dedupPrices)
    if nDedup > 0
        sortPriceIdx = array.sort_indices(dedupPrices, order.descending)
        
        for i = 0 to nDedup - 1
            pIdx = array.get(sortPriceIdx, i)
            array.push(finalPrices, array.get(dedupPrices, pIdx))
            array.push(finalScores, array.get(dedupScores, pIdx))
            array.push(finalTF, array.get(dedupTF, pIdx))
            array.push(finalNTF, array.get(dedupNTF, pIdx))
            array.push(finalFResT, array.get(dedupFResT, pIdx))
            array.push(finalFSupT, array.get(dedupFSupT, pIdx))
            array.push(finalOrigin, array.get(dedupOrigin, pIdx))
            array.push(finalBasePts, array.get(dedupBasePts, pIdx))
            array.push(finalConflPts, array.get(dedupConflPts, pIdx))
            array.push(finalTouchPts, array.get(dedupTouchPts, pIdx))
            array.push(finalPipsPts, array.get(dedupPipsPts, pIdx))
            array.push(finalMaxPips, array.get(dedupMaxPips, pIdx))
            array.push(finalTotalTouches, array.get(dedupTotalTouches, pIdx))

    // --- FASE 4: DISEGNO GRAFICO E TABELLE COMPATTE ---
    nFinal = array.size(finalScores)
    int righeValide = 0
    if nFinal > 0
        for rank = 0 to nFinal - 1
            if array.get(finalScores, rank) >= scoreThreshold or rank < minKLCount
                righeValide += 1

    if nFinal > 0
        posTabella = tablePosStr == "In alto a destra" ? position.top_right : tablePosStr == "In basso a destra" ? position.bottom_right : tablePosStr == "In alto a sinistra" ? position.top_left : position.bottom_left
        // Usiamo table.new con stile pulito
        t = showTable and righeValide > 0 ? table.new(posTabella, 3, righeValide + 1, border_width=1, border_color=color.new(color.gray, 60)) : na
        
        if not na(t)
            table.cell(t, 0, 0, "Prezzo KL", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=size.small)
            table.cell(t, 1, 0, "Origine", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=size.small)
            table.cell(t, 2, 0, "Data 1° Tocco", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=size.small)

        posScoreTabella = scoreTablePosStr == "In alto a destra" ? position.top_right : scoreTablePosStr == "In basso a destra" ? position.bottom_right : scoreTablePosStr == "In alto a sinistra" ? position.top_left : position.bottom_left
        tScore = showScoreTable and righeValide > 0 ? table.new(posScoreTabella, 6, righeValide + 1, border_width=1, border_color=color.new(color.gray, 60)) : na
        
        if not na(tScore)
            table.cell(tScore, 0, 0, "Prezzo KL", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)
            table.cell(tScore, 1, 0, "Base TF", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)
            table.cell(tScore, 2, 0, "Confl. MTF", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)
            table.cell(tScore, 3, 0, "Tocchi (Pts)", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)
            table.cell(tScore, 4, 0, "Max Pips (Pts)", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)
            table.cell(tScore, 5, 0, "TOTALE", text_color=color.white, bgcolor=color.new(color.purple, 60), text_size=size.small)

        int rowIdx = 1

        for rank = 0 to nFinal - 1
            sc = array.get(finalScores, rank)
            if sc >= scoreThreshold or rank < minKLCount
                lvl    = array.get(finalPrices, rank)
                tfList = array.get(finalTF, rank)
                nTF    = array.get(finalNTF, rank)
                isResOrigin = array.get(finalOrigin, rank)

                ln = line.new(time - (timeframe.in_seconds() * 500 * 1000), lvl, time + (timeframe.in_seconds() * 20 * 1000), lvl, xloc=xloc.bar_time, color=colKL, width=nTF > 1 ? 2 : 1, style=line.style_solid, extend=extend.right)
                array.push(drawnLines, ln)

                lblTxt = str.tostring(lvl, format.mintick) + "  |  " + tfList + "  |  Score: " + str.tostring(math.round(sc))
                lbl = label.new(H1_time + (5 * 3600 * 1000), lvl + labelOffsetPips * pipSize, lblTxt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colKL, 80), textcolor=colTxt, size=size.small)
                array.push(drawnLabels, lbl)

                if showFirstTouchCircles
                    fResT = array.get(finalFResT, rank)
                    if not na(fResT)
                        cRes = label.new(x=fResT, y=lvl, text="○", xloc=xloc.bar_time, style=label.style_none, textcolor=colFirstRes, size=size.normal)
                        label.set_tooltip(cRes, "1° Tocco Resistenza")
                        array.push(drawnLabels, cRes)
                    fSupT = array.get(finalFSupT, rank)
                    if not na(fSupT)
                        cSup = label.new(x=fSupT, y=lvl, text="○", xloc=xloc.bar_time, style=label.style_none, textcolor=colFirstSup, size=size.normal)
                        label.set_tooltip(cSup, "1° Tocco Supporto")
                        array.push(drawnLabels, cSup)

                if not na(t)
                    originTime = isResOrigin ? array.get(finalFResT, rank) : array.get(finalFSupT, rank)
                    txtNato = isResOrigin ? "Resistenza" : "Supporto"
                    colNato = isResOrigin ? color.new(color.red, 0) : color.new(color.lime, 0)
                    
                    table.cell(t, 0, rowIdx, str.tostring(lvl, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(t, 1, rowIdx, txtNato, text_color=colNato, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(t, 2, rowIdx, str.format("{0,date,dd/MM/yy HH:mm}", originTime), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                
                if not na(tScore)
                    baseP   = array.get(finalBasePts, rank)
                    conflP  = array.get(finalConflPts, rank)
                    touchP  = array.get(finalTouchPts, rank)
                    pipsP   = array.get(finalPipsPts, rank)
                    mPips   = array.get(finalMaxPips, rank)
                    totT    = array.get(finalTotalTouches, rank)
                    
                    touchTxt = str.tostring(totT) + " (" + str.tostring(math.round(touchP)) + ")"
                    pipsTxt  = str.tostring(math.round(mPips)) + " (" + str.tostring(math.round(pipsP)) + ")"
                    
                    table.cell(tScore, 0, rowIdx, str.tostring(lvl, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(tScore, 1, rowIdx, str.tostring(math.round(baseP)), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(tScore, 2, rowIdx, str.tostring(math.round(conflP)), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(tScore, 3, rowIdx, touchTxt, text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(tScore, 4, rowIdx, pipsTxt, text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
                    table.cell(tScore, 5, rowIdx, str.tostring(math.round(sc)), text_color=color.new(color.lime, 0), bgcolor=color.new(color.black, 70), text_size=size.small)
                
                rowIdx += 1
````
