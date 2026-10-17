# Calculateur Position Futures Marshmello 

- url: https://www.tradingview.com/script/4XdoRPTE/
- type: indicator
- pine_id: PUB;fdd8a0ab7db3469c9a0a0edd040647b7
- version: 1.0

## Description

📊 CALCULATEUR DE POSITION FUTURES

Calculez automatiquement votre taille de position en fonction de :
✅ Votre capital
✅ Votre % de risque par trade
✅ Votre stop-loss en ticks

🎯 Fonctionnalités :
• Calcul automatique du nombre de contrats
• Lignes visuelles SL/TP sur le graphique
• Support multi-contrats (ES, MES, NQ, MNQ, CL, GC, etc.)
• Take-profits multiples avec ratio R:R personnalisable
• Couleurs entièrement personnalisables.

Have fun

## Source Code

````pine
//@version=5
indicator("Calculateur Position Futures", overlay=true, max_lines_count=500, max_labels_count=500)
// ==========================================
// PARAMÈTRES UTILISATEUR
// ==========================================
// Compte et risque
accountSize = input.float(50000, "Capital du compte (€/$)", minval=100, step=1000, group="💰 Compte")
riskPercent = input.float(1.0, "Risque par trade (%)", minval=0.1, maxval=10, step=0.1, group="💰 Compte")
// Contrat
contractType = input.string("/MNQ", "Contrat", options=["/ES", "/MES", "/NQ", "/MNQ", "/YM", "/MYM", "/RTY", "/M2K", "/CL", "/MCL", "/GC", "/MGC"], group="📊 Contrat")
customTickValue = input.float(0, "Valeur tick personnalisée (0 = auto)", minval=0, step=0.1, group="📊 Contrat")
// Stop-loss
slMode = input.string("Ticks", "Mode Stop-Loss", options=["Ticks", "Points", "Prix"], group="🛑 Stop-Loss")
slTicks = input.int(20, "Stop-Loss (ticks)", minval=1, maxval=500, group="🛑 Stop-Loss")
slPrice = input.float(0, "Prix Stop-Loss (si mode Prix)", minval=0, group="🛑 Stop-Loss")
// Take-profit
showTP = input.bool(true, "Afficher Take-Profit", group="🎯 Take-Profit")
rrRatio = input.float(2.0, "Ratio Risk/Reward", minval=0.5, maxval=10, step=0.5, group="🎯 Take-Profit")
useMultipleTP = input.bool(false, "Utiliser plusieurs TP", group="🎯 Take-Profit")
tp2Ratio = input.float(3.0, "TP2 Ratio R:R", minval=1, maxval=15, step=0.5, group="🎯 Take-Profit")
tp3Ratio = input.float(4.0, "TP3 Ratio R:R", minval=1, maxval=20, step=0.5, group="🎯 Take-Profit")
// Direction du trade
tradeDirection = input.string("Long", "Direction du trade", options=["Long", "Short"], group="📈 Position")
entryMode = input.string("Prix actuel", "Prix d'entrée", options=["Prix actuel", "Prix personnalisé"], group="📈 Position")
customEntry = input.float(0, "Prix d'entrée personnalisé", minval=0, group="📈 Position")
// Lignes visuelles
showLines = input.bool(true, "Afficher lignes SL/TP", group="📏 Lignes Visuelles")
lineLength = input.int(50, "Longueur des lignes (barres)", minval=10, maxval=200, group="📏 Lignes Visuelles")
lineWidth = input.int(2, "Épaisseur des lignes", minval=1, maxval=5, group="📏 Lignes Visuelles")
showLabels = input.bool(true, "Afficher labels prix", group="📏 Lignes Visuelles")
showZone = input.bool(true, "Afficher zones colorées", group="📏 Lignes Visuelles")
zoneTransparency = input.int(85, "Transparence zones", minval=50, maxval=95, group="📏 Lignes Visuelles")
// ==========================================
// COULEURS PERSONNALISABLES
// ==========================================
// Couleurs des lignes
entryColor = input.color(color.blue, "Ligne entrée", group="🎨 Couleurs Lignes")
slColor = input.color(color.red, "Ligne Stop-Loss", group="🎨 Couleurs Lignes")
tp1Color = input.color(color.green, "Ligne TP1", group="🎨 Couleurs Lignes")
tp2Color = input.color(color.lime, "Ligne TP2", group="🎨 Couleurs Lignes")
tp3Color = input.color(color.teal, "Ligne TP3", group="🎨 Couleurs Lignes")
// Couleurs des zones
slZoneColor = input.color(color.red, "Zone Stop-Loss", group="🎨 Couleurs Zones")
tpZoneColor = input.color(color.green, "Zone Take-Profit", group="🎨 Couleurs Zones")
// Couleurs des labels
entryLabelColor = input.color(color.blue, "Label entrée", group="🎨 Couleurs Labels")
slLabelColor = input.color(color.red, "Label Stop-Loss", group="🎨 Couleurs Labels")
tp1LabelColor = input.color(color.green, "Label TP1", group="🎨 Couleurs Labels")
tp2LabelColor = input.color(color.lime, "Label TP2", group="🎨 Couleurs Labels")
tp3LabelColor = input.color(color.teal, "Label TP3", group="🎨 Couleurs Labels")
labelTextColor = input.color(color.white, "Texte des labels", group="🎨 Couleurs Labels")
// Couleurs du tableau
tableBackgroundColor = input.color(color.black, "Fond du tableau", group="🎨 Couleurs Tableau")
tableTextColor = input.color(color.white, "Texte du tableau", group="🎨 Couleurs Tableau")
tableHeaderColor = input.color(color.blue, "En-tête du tableau", group="🎨 Couleurs Tableau")
tableBorderColor = input.color(color.gray, "Bordure du tableau", group="🎨 Couleurs Tableau")
tableHighlightColor = input.color(color.green, "Mise en évidence (contrats)", group="🎨 Couleurs Tableau")
// Affichage tableau
showTable = input.bool(true, "Afficher tableau", group="📋 Tableau")
tablePosition = input.string("top_right", "Position du tableau", options=["top_right", "top_left", "bottom_right", "bottom_left"], group="📋 Tableau")
tableSize = input.string("normal", "Taille du tableau", options=["small", "normal", "large"], group="📋 Tableau")
// ==========================================
// VALEURS DES CONTRATS
// ==========================================
getTickValue(contract) =>
    switch contract
        "/ES" => 12.50
        "/MES" => 1.25
        "/NQ" => 5.00
        "/MNQ" => 0.50
        "/YM" => 5.00
        "/MYM" => 0.50
        "/RTY" => 5.00
        "/M2K" => 0.50
        "/CL" => 10.00
        "/MCL" => 1.00
        "/GC" => 10.00
        "/MGC" => 1.00
        => 1.00
getTickSize(contract) =>
    switch contract
        "/ES" => 0.25
        "/MES" => 0.25
        "/NQ" => 0.25
        "/MNQ" => 0.25
        "/YM" => 1.00
        "/MYM" => 1.00
        "/RTY" => 0.10
        "/M2K" => 0.10
        "/CL" => 0.01
        "/MCL" => 0.01
        "/GC" => 0.10
        "/MGC" => 0.10
        => 0.01
// ==========================================
// CALCULS
// ==========================================
tickValue = customTickValue > 0 ? customTickValue : getTickValue(contractType)
tickSize = getTickSize(contractType)
// Prix d'entrée
entryPrice = entryMode == "Prix personnalisé" and customEntry > 0 ? customEntry : close
// Montant risqué
riskAmount = accountSize * (riskPercent / 100)
// Calcul du SL en ticks selon le mode
slInTicks = switch slMode
    "Ticks" => slTicks
    "Points" => math.round(slTicks / tickSize)
    "Prix" => slPrice > 0 ? math.round(math.abs(entryPrice - slPrice) / tickSize) : slTicks
    => slTicks
// Distance SL en prix
slDistance = slInTicks * tickSize
// Calcul du nombre de contrats
riskPerContract = slInTicks * tickValue
contracts = riskPerContract > 0 ? math.floor(riskAmount / riskPerContract) : 0
contracts := math.max(contracts, 0)
// Risque réel
actualRisk = contracts * riskPerContract
actualRiskPercent = accountSize > 0 ? (actualRisk / accountSize) * 100 : 0
// Calcul des niveaux de prix
isLong = tradeDirection == "Long"
slPriceLevel = isLong ? entryPrice - slDistance : entryPrice + slDistance
tp1Distance = slDistance * rrRatio
tp2Distance = slDistance * tp2Ratio
tp3Distance = slDistance * tp3Ratio
tp1PriceLevel = isLong ? entryPrice + tp1Distance : entryPrice - tp1Distance
tp2PriceLevel = isLong ? entryPrice + tp2Distance : entryPrice - tp2Distance
tp3PriceLevel = isLong ? entryPrice + tp3Distance : entryPrice - tp3Distance
// Montants TP
tp1Amount = actualRisk * rrRatio
tp2Amount = actualRisk * tp2Ratio
tp3Amount = actualRisk * tp3Ratio
// ==========================================
// LIGNES VISUELLES SL/TP
// ==========================================
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var linefill slZone = na
var linefill tp1Zone = na
var linefill tp2Zone = na
var linefill tp3Zone = na
if barstate.islast and showLines
    // Supprimer les anciennes lignes
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    
    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    
    linefill.delete(slZone)
    linefill.delete(tp1Zone)
    linefill.delete(tp2Zone)
    linefill.delete(tp3Zone)
    
    // Coordonnées
    startBar = bar_index
    endBar = bar_index + lineLength
    
    // Ligne d'entrée
    entryLine := line.new(startBar, entryPrice, endBar, entryPrice, color=entryColor, width=lineWidth, style=line.style_solid)
    
    // Ligne Stop-Loss
    slLine := line.new(startBar, slPriceLevel, endBar, slPriceLevel, color=slColor, width=lineWidth, style=line.style_solid)
    
    // Ligne TP1
    if showTP
        tp1Line := line.new(startBar, tp1PriceLevel, endBar, tp1PriceLevel, color=tp1Color, width=lineWidth, style=line.style_solid)
    
    // Lignes TP2 et TP3
    if showTP and useMultipleTP
        tp2Line := line.new(startBar, tp2PriceLevel, endBar, tp2PriceLevel, color=tp2Color, width=lineWidth, style=line.style_dashed)
        tp3Line := line.new(startBar, tp3PriceLevel, endBar, tp3PriceLevel, color=tp3Color, width=lineWidth, style=line.style_dashed)
    
    // Zones colorées
    if showZone
        slZone := linefill.new(entryLine, slLine, color.new(slZoneColor, zoneTransparency))
        if showTP
            tp1Zone := linefill.new(entryLine, tp1Line, color.new(tpZoneColor, zoneTransparency))
    
    // Labels
    if showLabels
        labelStyle = label.style_label_left
        
        entryLabel := label.new(endBar, entryPrice, 
             "ENTRÉE: " + str.tostring(entryPrice, "#.##") + "\n" + str.tostring(contracts) + " contrats", 
             color=color.new(entryLabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        slLabel := label.new(endBar, slPriceLevel, 
             "SL: " + str.tostring(slPriceLevel, "#.##") + "\n-" + str.tostring(actualRisk, "#.##") + " €\n(" + str.tostring(slInTicks) + " ticks)", 
             color=color.new(slLabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        if showTP
            tp1Label := label.new(endBar, tp1PriceLevel, 
                 "TP1: " + str.tostring(tp1PriceLevel, "#.##") + "\n+" + str.tostring(tp1Amount, "#.##") + " €\n(R:" + str.tostring(rrRatio, "#.#") + ")", 
                 color=color.new(tp1LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        if showTP and useMultipleTP
            tp2Label := label.new(endBar, tp2PriceLevel, 
                 "TP2: " + str.tostring(tp2PriceLevel, "#.##") + "\n+" + str.tostring(tp2Amount, "#.##") + " €", 
                 color=color.new(tp2LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
            
            tp3Label := label.new(endBar, tp3PriceLevel, 
                 "TP3: " + str.tostring(tp3PriceLevel, "#.##") + "\n+" + str.tostring(tp3Amount, "#.##") + " €", 
                 color=color.new(tp3LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
// ==========================================
// TABLEAU D'AFFICHAGE
// ==========================================
var table infoTable = table.new(
     tablePosition == "top_right" ? position.top_right : 
     tablePosition == "top_left" ? position.top_left : 
     tablePosition == "bottom_right" ? position.bottom_right : position.bottom_left,
     2, 14,
     bgcolor = color.new(tableBackgroundColor, 85),
     border_width = 1,
     border_color = tableBorderColor)
textSize = switch tableSize
    "small" => size.small
    "normal" => size.normal
    "large" => size.large
    => size.normal
if barstate.islast and showTable
    // En-tête
    headerColor = isLong ? color.new(color.green, 70) : color.new(color.red, 70)
    directionText = isLong ? "📈 LONG" : "📉 SHORT"
    table.cell(infoTable, 0, 0, directionText + " — " + contractType, text_color=tableTextColor, text_size=textSize, bgcolor=headerColor)
    table.merge_cells(infoTable, 0, 0, 1, 0)
    
    // Capital
    table.cell(infoTable, 0, 1, "Capital", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 1, str.tostring(accountSize, "#,##0") + " €", text_color=tableTextColor, text_size=textSize)
    
    // Risque %
    table.cell(infoTable, 0, 2, "Risque", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 2, str.tostring(riskPercent, "#.#") + " % (" + str.tostring(riskAmount, "#,##0") + " €)", text_color=color.orange, text_size=textSize)
    
    // Séparateur
    table.cell(infoTable, 0, 3, "─────────────", text_color=color.gray, text_size=textSize)
    table.merge_cells(infoTable, 0, 3, 1, 3)
    
    // Entrée
    table.cell(infoTable, 0, 4, "Entrée", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 4, str.tostring(entryPrice, "#.##"), text_color=entryColor, text_size=textSize)
    
    // Stop-loss
    table.cell(infoTable, 0, 5, "Stop-Loss", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 5, str.tostring(slPriceLevel, "#.##") + " (" + str.tostring(slInTicks) + " ticks)", text_color=slColor, text_size=textSize)
    
    // TP1
    if showTP
        table.cell(infoTable, 0, 6, "TP1 (R:" + str.tostring(rrRatio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 6, str.tostring(tp1PriceLevel, "#.##") + " (+" + str.tostring(tp1Amount, "#,##0") + " €)", text_color=tp1Color, text_size=textSize)
    
    // TP2 et TP3
    if showTP and useMultipleTP
        table.cell(infoTable, 0, 7, "TP2 (R:" + str.tostring(tp2Ratio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 7, str.tostring(tp2PriceLevel, "#.##") + " (+" + str.tostring(tp2Amount, "#,##0") + " €)", text_color=tp2Color, text_size=textSize)
        
        table.cell(infoTable, 0, 8, "TP3 (R:" + str.tostring(tp3Ratio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 8, str.tostring(tp3PriceLevel, "#.##") + " (+" + str.tostring(tp3Amount, "#,##0") + " €)", text_color=tp3Color, text_size=textSize)
    
    // Séparateur
    table.cell(infoTable, 0, 9, "─────────────", text_color=color.gray, text_size=textSize)
    table.merge_cells(infoTable, 0, 9, 1, 9)
    
    // Valeur tick
    table.cell(infoTable, 0, 10, "Valeur/tick", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 10, str.tostring(tickValue, "#.##") + " $", text_color=tableTextColor, text_size=textSize)
    
    // Perte par contrat
    table.cell(infoTable, 0, 11, "Risque/contrat", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 11, str.tostring(riskPerContract, "#,##0.00") + " $", text_color=slColor, text_size=textSize)
    
    // CONTRATS
    table.cell(infoTable, 0, 12, "▶ CONTRATS", text_color=tableTextColor, text_size=textSize, bgcolor=color.new(tableHighlightColor, 60))
    table.cell(infoTable, 1, 12, str.tostring(contracts), text_color=tableTextColor, text_size=textSize, bgcolor=color.new(tableHighlightColor, 60))
    
    // Risque réel
    table.cell(infoTable, 0, 13, "Risque réel", text_color=color.gray, text_size=textSize)
    riskColor = actualRiskPercent > riskPercent ? color.red : color.lime
    table.cell(infoTable, 1, 13, str.tostring(actualRisk, "#,##0.00") + " € (" + str.tostring(actualRiskPercent, "#.##") + "%)", text_color=riskColor, text_size=textSize)
// ==========================================
// ALERTES
// ==========================================
alertcondition(contracts == 0, title="Position impossible", message="Le risque défini ne permet pas d'ouvrir de position")
alertcondition(ta.crossunder(close, slPriceLevel) and isLong, title="SL touché (Long)", message="Stop-Loss atteint sur position Long")
alertcondition(ta.crossover(close, slPriceLevel) and not isLong, title="SL touché (Short)", message="Stop-Loss atteint sur position Short")
alertcondition(ta.crossover(close, tp1PriceLevel) and isLong, title="TP1 atteint (Long)", message="Take-Profit 1 atteint sur position Long")
alertcondition(ta.crossunder(close, tp1PriceLevel) and not isLong, title="TP1 atteint (Short)", message="Take-Profit 1 atteint sur position Short")
````
