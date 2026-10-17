# Calculateur Position CFD Forex Marshmello 

- url: https://www.tradingview.com/script/JBmXeIxW/
- type: indicator
- pine_id: PUB;52d56c797d0647a4b948aaa69cf75cb5
- version: 1.0

## Description

📊 CALCULATEUR DE POSITION CFD FOREX - Marshmello 

Ne calculez plus jamais votre taille de position à la main ! Cet indicateur calcule automatiquement le nombre exact de lots à trader en fonction de votre capital, votre pourcentage de risque et votre stop-loss.

━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 FONCTIONNALITÉS PRINCIPALES :

✅ Calcul automatique du nombre de lots
→ Entrez votre capital, votre risque en % et votre SL en pips
→ L'indicateur calcule instantanément la taille de position optimale

✅ 30+ paires Forex supportées
→ Majeures : EUR/USD, GBP/USD, USD/JPY, USD/CHF, AUD/USD, NZD/USD, USD/CAD
→ Croisées EUR : EUR/GBP, EUR/JPY, EUR/CHF, EUR/AUD, EUR/NZD, EUR/CAD
→ Croisées GBP : GBP/JPY, GBP/CHF, GBP/AUD, GBP/NZD, GBP/CAD
→ Croisées exotiques : AUD/JPY, AUD/NZD, NZD/JPY, CAD/JPY, CHF/JPY...
→ Métaux précieux : XAU/USD (Or), XAG/USD (Argent)

✅ Tous types de lots
→ Standard (100 000 unités)
→ Mini (10 000 unités)
→ Micro (1 000 unités)
→ Nano (100 unités)

✅ Lignes visuelles sur le graphique
→ Ligne d'entrée (bleue)
→ Ligne Stop-Loss (rouge)
→ Lignes Take-Profit (vertes)
→ Zones colorées entre les niveaux

✅ Take-profits multiples
→ TP1, TP2, TP3 avec ratios R:R personnalisables
→ Calcul automatique des gains potentiels

✅ Devise du compte flexible
→ EUR, USD, GBP, CHF, JPY, CAD, AUD

✅ Tableau d'information complet
→ Capital, risque, entrée, SL, TP
→ Valeur du pip, risque par lot
→ Nombre de lots recommandé
→ Risque réel après arrondi

✅ Couleurs personnalisables
→ Lignes, zones, labels, tableau
→ Adaptez l'indicateur à votre style de graphique

━━━━━━━━━━━━━━━━━━━━━━━━━

📈 COMMENT UTILISER :

1️⃣ Ajoutez l'indicateur à votre graphique
2️⃣ Ouvrez les paramètres (double-clic sur l'indicateur)
3️⃣ Configurez votre compte :
   • Capital (ex: 10 000 €)
   • Devise du compte (EUR, USD...)
   • Risque par trade (ex: 1%)

4️⃣ Configurez votre trade :
   • Sélectionnez la paire Forex
   • Choisissez le type de lot
   • Entrez votre stop-loss en pips
   • Choisissez la direction (Long/Short)

5️⃣ Lisez le résultat :
   • Le nombre de lots s'affiche dans le tableau
   • Les lignes SL/TP apparaissent sur le graphique
   • Les montants en €/$ sont calculés automatiquement

━━━━━━━━━━━━━━━━━━━━━━━━━

💡 EXEMPLE :

Capital : 10 000 €
Risque : 1% (100 €)
Paire : EUR/USD
Stop-Loss : 20 pips
Type de lot : Mini

→ Résultat : 0.50 lots mini
→ Risque réel : 100 €
→ TP1 (R:2) : +200 €

━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️ PARAMÈTRES DISPONIBLES :

💰 Compte : Capital, devise, % risque
📊 Paire : Sélection paire, type de lot
🛑 Stop-Loss : Mode pips ou prix
🎯 Take-Profit : Ratios R:R, multi-TP
📈 Position : Direction Long/Short
📏 Lignes : Affichage, longueur, épaisseur
🎨 Couleurs : Personnalisation complète
📋 Tableau : Position, taille

━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ AVERTISSEMENT :

Le trading sur le Forex comporte des risques significatifs de perte en capital. Cet indicateur est un outil d'aide à la décision et ne constitue pas un conseil en investissement. Tradez de manière responsable et n'investissez que ce que vous pouvez vous permettre de perdre.

## Source Code

````pine
//@version=5
indicator("Calculateur Position CFD Forex", overlay=true, max_lines_count=500, max_labels_count=500)
// ==========================================
// PARAMÈTRES UTILISATEUR
// ==========================================
// Compte et risque
accountSize = input.float(10000, "Capital du compte (€/$)", minval=100, step=1000, group="💰 Compte")
accountCurrency = input.string("EUR", "Devise du compte", options=["EUR", "USD", "GBP", "CHF", "JPY", "CAD", "AUD"], group="💰 Compte")
riskPercent = input.float(1.0, "Risque par trade (%)", minval=0.1, maxval=10, step=0.1, group="💰 Compte")
// Paire Forex
pairType = input.string("EUR/USD", "Paire Forex", options=[
     "EUR/USD", "GBP/USD", "USD/JPY", "USD/CHF", "AUD/USD", "NZD/USD", "USD/CAD",
     "EUR/GBP", "EUR/JPY", "EUR/CHF", "EUR/AUD", "EUR/NZD", "EUR/CAD",
     "GBP/JPY", "GBP/CHF", "GBP/AUD", "GBP/NZD", "GBP/CAD",
     "AUD/JPY", "AUD/NZD", "AUD/CAD", "AUD/CHF",
     "NZD/JPY", "NZD/CHF", "NZD/CAD",
     "CAD/JPY", "CAD/CHF",
     "CHF/JPY",
     "XAU/USD", "XAG/USD"
     ], group="📊 Paire")
// Type de lot
lotType = input.string("Standard", "Type de lot", options=["Standard", "Mini", "Micro", "Nano"], group="📊 Paire")
customPipValue = input.float(0, "Valeur pip personnalisée (0 = auto)", minval=0, step=0.1, group="📊 Paire")
// Stop-loss
slMode = input.string("Pips", "Mode Stop-Loss", options=["Pips", "Prix"], group="🛑 Stop-Loss")
slPips = input.float(20, "Stop-Loss (pips)", minval=0.1, maxval=1000, step=0.1, group="🛑 Stop-Loss")
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
tableHighlightColor = input.color(color.green, "Mise en évidence (lots)", group="🎨 Couleurs Tableau")
// Affichage tableau
showTable = input.bool(true, "Afficher tableau", group="📋 Tableau")
tablePosition = input.string("top_right", "Position du tableau", options=["top_right", "top_left", "bottom_right", "bottom_left"], group="📋 Tableau")
tableSize = input.string("normal", "Taille du tableau", options=["small", "normal", "large"], group="📋 Tableau")
// ==========================================
// VALEURS DES PAIRES FOREX
// ==========================================
// Détermine si la paire a JPY comme devise de cotation
isJPYQuote(pair) =>
    str.contains(pair, "/JPY")
// Détermine si c'est une paire métaux
isMetalPair(pair) =>
    str.contains(pair, "XAU") or str.contains(pair, "XAG")
// Valeur du pip selon la paire (pour 1 lot standard)
getPipValue(pair) =>
    if isMetalPair(pair)
        if str.contains(pair, "XAU")
            10.0  // Or: 1 pip = $10 pour 1 lot standard (100 oz)
        else
            50.0  // Argent: 1 pip = $50 pour 1 lot standard (5000 oz)
    else if isJPYQuote(pair)
        1000.0 / close  // Approximation pour les paires JPY
    else
        10.0  // Paires standard: 1 pip = $10 pour 1 lot standard
// Taille du pip selon la paire
getPipSize(pair) =>
    if isMetalPair(pair)
        if str.contains(pair, "XAU")
            0.1   // Or: 1 pip = 0.1
        else
            0.01  // Argent: 1 pip = 0.01
    else if isJPYQuote(pair)
        0.01  // Paires JPY: 1 pip = 0.01
    else
        0.0001  // Paires standard: 1 pip = 0.0001
// Multiplicateur selon le type de lot
getLotMultiplier(lotTypeInput) =>
    switch lotTypeInput
        "Standard" => 1.0
        "Mini" => 0.1
        "Micro" => 0.01
        "Nano" => 0.001
        => 1.0
// Taille du lot selon le type
getLotSize(lotTypeInput) =>
    switch lotTypeInput
        "Standard" => 100000.0
        "Mini" => 10000.0
        "Micro" => 1000.0
        "Nano" => 100.0
        => 100000.0
// ==========================================
// CALCULS
// ==========================================
pipSize = getPipSize(pairType)
basePipValue = customPipValue > 0 ? customPipValue : getPipValue(pairType)
lotMultiplier = getLotMultiplier(lotType)
pipValue = basePipValue * lotMultiplier
lotSize = getLotSize(lotType)
// Prix d'entrée
entryPrice = entryMode == "Prix personnalisé" and customEntry > 0 ? customEntry : close
// Montant risqué
riskAmount = accountSize * (riskPercent / 100)
// Calcul du SL en pips selon le mode
slInPips = switch slMode
    "Pips" => slPips
    "Prix" => slPrice > 0 ? math.abs(entryPrice - slPrice) / pipSize : slPips
    => slPips
// Distance SL en prix
slDistance = slInPips * pipSize
// Calcul du nombre de lots
riskPerLot = slInPips * pipValue
lots = riskPerLot > 0 ? riskAmount / riskPerLot : 0
lots := math.max(lots, 0)
// Arrondi des lots selon le type
lotsRounded = switch lotType
    "Standard" => math.floor(lots * 100) / 100
    "Mini" => math.floor(lots * 100) / 100
    "Micro" => math.floor(lots * 100) / 100
    "Nano" => math.floor(lots * 100) / 100
    => math.floor(lots * 100) / 100
// Risque réel
actualRisk = lotsRounded * slInPips * pipValue
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
// Pips TP
tp1Pips = slInPips * rrRatio
tp2Pips = slInPips * tp2Ratio
tp3Pips = slInPips * tp3Ratio
// Valeur de la position
positionValue = lotsRounded * lotSize
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
    
    // Précision d'affichage selon la paire
    priceFormat = isJPYQuote(pairType) ? "#.###" : isMetalPair(pairType) ? "#.##" : "#.#####"
    
    // Labels
    if showLabels
        labelStyle = label.style_label_left
        
        entryLabel := label.new(endBar, entryPrice, 
             "ENTRÉE: " + str.tostring(entryPrice, priceFormat) + "\n" + str.tostring(lotsRounded, "#.##") + " lots", 
             color=color.new(entryLabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        slLabel := label.new(endBar, slPriceLevel, 
             "SL: " + str.tostring(slPriceLevel, priceFormat) + "\n-" + str.tostring(actualRisk, "#.##") + " " + accountCurrency + "\n(" + str.tostring(slInPips, "#.#") + " pips)", 
             color=color.new(slLabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        if showTP
            tp1Label := label.new(endBar, tp1PriceLevel, 
                 "TP1: " + str.tostring(tp1PriceLevel, priceFormat) + "\n+" + str.tostring(tp1Amount, "#.##") + " " + accountCurrency + "\n(R:" + str.tostring(rrRatio, "#.#") + ")", 
                 color=color.new(tp1LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
        
        if showTP and useMultipleTP
            tp2Label := label.new(endBar, tp2PriceLevel, 
                 "TP2: " + str.tostring(tp2PriceLevel, priceFormat) + "\n+" + str.tostring(tp2Amount, "#.##") + " " + accountCurrency, 
                 color=color.new(tp2LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
            
            tp3Label := label.new(endBar, tp3PriceLevel, 
                 "TP3: " + str.tostring(tp3PriceLevel, priceFormat) + "\n+" + str.tostring(tp3Amount, "#.##") + " " + accountCurrency, 
                 color=color.new(tp3LabelColor, 70), textcolor=labelTextColor, style=labelStyle, size=size.small)
// ==========================================
// TABLEAU D'AFFICHAGE
// ==========================================
var table infoTable = table.new(
     tablePosition == "top_right" ? position.top_right : 
     tablePosition == "top_left" ? position.top_left : 
     tablePosition == "bottom_right" ? position.bottom_right : position.bottom_left,
     2, 16,
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
    table.cell(infoTable, 0, 0, directionText + " — " + pairType, text_color=tableTextColor, text_size=textSize, bgcolor=headerColor)
    table.merge_cells(infoTable, 0, 0, 1, 0)
    
    // Capital
    table.cell(infoTable, 0, 1, "Capital", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 1, str.tostring(accountSize, "#,##0") + " " + accountCurrency, text_color=tableTextColor, text_size=textSize)
    
    // Risque %
    table.cell(infoTable, 0, 2, "Risque", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 2, str.tostring(riskPercent, "#.#") + " % (" + str.tostring(riskAmount, "#,##0") + " " + accountCurrency + ")", text_color=color.orange, text_size=textSize)
    
    // Séparateur
    table.cell(infoTable, 0, 3, "─────────────", text_color=color.gray, text_size=textSize)
    table.merge_cells(infoTable, 0, 3, 1, 3)
    
    // Type de lot
    table.cell(infoTable, 0, 4, "Type de lot", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 4, lotType + " (" + str.tostring(lotSize, "#,##0") + " unités)", text_color=tableTextColor, text_size=textSize)
    
    // Entrée
    priceFormat = isJPYQuote(pairType) ? "#.###" : isMetalPair(pairType) ? "#.##" : "#.#####"
    table.cell(infoTable, 0, 5, "Entrée", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 5, str.tostring(entryPrice, priceFormat), text_color=entryColor, text_size=textSize)
    
    // Stop-loss
    table.cell(infoTable, 0, 6, "Stop-Loss", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 6, str.tostring(slPriceLevel, priceFormat) + " (" + str.tostring(slInPips, "#.#") + " pips)", text_color=slColor, text_size=textSize)
    
    // TP1
    if showTP
        table.cell(infoTable, 0, 7, "TP1 (R:" + str.tostring(rrRatio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 7, str.tostring(tp1PriceLevel, priceFormat) + " (+" + str.tostring(tp1Amount, "#,##0") + " " + accountCurrency + ")", text_color=tp1Color, text_size=textSize)
    
    // TP2 et TP3
    if showTP and useMultipleTP
        table.cell(infoTable, 0, 8, "TP2 (R:" + str.tostring(tp2Ratio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 8, str.tostring(tp2PriceLevel, priceFormat) + " (+" + str.tostring(tp2Amount, "#,##0") + " " + accountCurrency + ")", text_color=tp2Color, text_size=textSize)
        
        table.cell(infoTable, 0, 9, "TP3 (R:" + str.tostring(tp3Ratio, "#.#") + ")", text_color=color.gray, text_size=textSize)
        table.cell(infoTable, 1, 9, str.tostring(tp3PriceLevel, priceFormat) + " (+" + str.tostring(tp3Amount, "#,##0") + " " + accountCurrency + ")", text_color=tp3Color, text_size=textSize)
    
    // Séparateur
    table.cell(infoTable, 0, 10, "─────────────", text_color=color.gray, text_size=textSize)
    table.merge_cells(infoTable, 0, 10, 1, 10)
    
    // Valeur du pip
    table.cell(infoTable, 0, 11, "Valeur/pip", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 11, str.tostring(pipValue, "#.##") + " $", text_color=tableTextColor, text_size=textSize)
    
    // Perte par lot
    table.cell(infoTable, 0, 12, "Risque/lot", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 12, str.tostring(riskPerLot, "#,##0.00") + " $", text_color=slColor, text_size=textSize)
    
    // Valeur position
    table.cell(infoTable, 0, 13, "Valeur position", text_color=color.gray, text_size=textSize)
    table.cell(infoTable, 1, 13, str.tostring(positionValue, "#,##0") + " unités", text_color=tableTextColor, text_size=textSize)
    
    // LOTS
    table.cell(infoTable, 0, 14, "▶ LOTS", text_color=tableTextColor, text_size=textSize, bgcolor=color.new(tableHighlightColor, 60))
    table.cell(infoTable, 1, 14, str.tostring(lotsRounded, "#.##"), text_color=tableTextColor, text_size=textSize, bgcolor=color.new(tableHighlightColor, 60))
    
    // Risque réel
    table.cell(infoTable, 0, 15, "Risque réel", text_color=color.gray, text_size=textSize)
    riskColor = actualRiskPercent > riskPercent ? color.red : color.lime
    table.cell(infoTable, 1, 15, str.tostring(actualRisk, "#,##0.00") + " " + accountCurrency + " (" + str.tostring(actualRiskPercent, "#.##") + "%)", text_color=riskColor, text_size=textSize)
// ==========================================
// ALERTES
// ==========================================
alertcondition(lotsRounded == 0, title="Position impossible", message="Le risque défini ne permet pas d'ouvrir de position")
alertcondition(ta.crossunder(close, slPriceLevel) and isLong, title="SL touché (Long)", message="Stop-Loss atteint sur position Long")
alertcondition(ta.crossover(close, slPriceLevel) and not isLong, title="SL touché (Short)", message="Stop-Loss atteint sur position Short")
alertcondition(ta.crossover(close, tp1PriceLevel) and isLong, title="TP1 atteint (Long)", message="Take-Profit 1 atteint sur position Long")
alertcondition(ta.crossunder(close, tp1PriceLevel) and not isLong, title="TP1 atteint (Short)", message="Take-Profit 1 atteint sur position Short")
````
