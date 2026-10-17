# Alligator - Cross Signals-False signals

- url: https://www.tradingview.com/script/nrhHEvt6/
- type: indicator
- pine_id: PUB;f5c901a232874c5cb02ab9d0bf29248a
- version: 1.0

## Description

This very simple indicator generates buy and sell signals at each crossover of the alligator's lips, offering good visual readability. If a signal is contradicted by an opposite signal within the following two candles, an alert signal is triggered. When combined with a 200-period EMA and an MACD, it can help improve entry and exit points, although the trader's own analysis remains essential.

## Source Code

````pine
//@version=6
indicator("Alligator - Cross Signals", overlay=true)

// ============================================
// 1. PARAMETRES
// ============================================

// Alligator
jawLen = input.int(13, "Machoire (Lente)")
teethLen = input.int(8, "Dents (Moyenne)")
lipsLen = input.int(5, "Levres (Rapide)")

// ============================================
// 2. ALLIGATOR
// ============================================
jaw = ta.sma(close, jawLen)
teeth = ta.sma(close, teethLen)
lips = ta.sma(close, lipsLen)

// ============================================
// 3. CROISEMENTS DES LIGNES
// ============================================

// SIGNAL ACHAT : JAW passe en dessous de LIPS (croisement haussier)
buySignal = ta.crossunder(jaw, lips)

// SIGNAL VENTE : JAW passe au-dessus de LIPS (croisement baissier)
sellSignal = ta.crossover(jaw, lips)

// ============================================
// 4. DETECTION SIGNAL CONTRAIRE DANS LES 2 BOUGIES SUIVANTES
// ============================================

// Fonction pour vérifier si un signal contraire est apparu dans les 2 bougies suivantes
contraireDansLes2Suivantes(signal, signalContraire) =>
    resultat = false
    // Vérifie les 2 bougies suivantes (index 1 et 2)
    if signal[0]
        // Si le signal est un achat, vérifier si un signal vente apparait dans les 2 prochaines bougies
        if signalContraire[1] or signalContraire[2]
            resultat := true
    resultat

// Vérifier si un signal contraire apparait après un signal d'achat
buyContraire = buySignal and (sellSignal[1] or sellSignal[2])

// Vérifier si un signal contraire apparait après un signal de vente
sellContraire = sellSignal and (buySignal[1] or buySignal[2])

// ============================================
// 5. AFFICHAGE - ALLIGATOR
// ============================================
plot(jaw, "Machoire (JAW)", color.new(color.blue, 0), linewidth=2)
plot(teeth, "Dents", color.new(color.red, 70), linewidth=2)
plot(lips, "Levres (LIPS)", color.new(color.green, 0), linewidth=2)

// ============================================
// 6. AFFICHAGE DES SIGNAL (TRIANGLES PETITS)
// ============================================

// SIGNAL ACHAT - Devient blanc si signal contraire dans les 2 bougies suivantes
plotshape(buySignal and not buyContraire, "SIGNAL ACHAT VALIDE", shape.triangleup, location.belowbar, 
         color.new(color.lime, 0), size=size.tiny, text="A")

plotshape(buyContraire, "SIGNAL ACHAT INVALIDE (contraire dans 2 bougies)", shape.triangleup, location.belowbar, 
         color.new(color.white, 0), size=size.tiny, text="A")

// SIGNAL VENTE - Devient blanc si signal contraire dans les 2 bougies suivantes
plotshape(sellSignal and not sellContraire, "SIGNAL VENTE VALIDE", shape.triangledown, location.abovebar, 
         color.new(color.red, 0), size=size.tiny, text="V")

plotshape(sellContraire, "SIGNAL VENTE INVALIDE (contraire dans 2 bougies)", shape.triangledown, location.abovebar, 
         color.new(color.white, 0), size=size.tiny, text="V")

// ============================================
// 7. AFFICHAGE TEXTE D'AVERTISSEMENT SUR LE GRAPHIQUE
// ============================================

// Affiche un texte d'avertissement lorsque le signal est invalidé
plotchar(buyContraire, "⚠️ Signal Achat annulé", "⚠️", location.belowbar, color.new(color.yellow, 0), size=size.small)
plotchar(sellContraire, "⚠️ Signal Vente annulé", "⚠️", location.abovebar, color.new(color.yellow, 0), size=size.small)

// ============================================
// 8. ZONES COLORÉES POUR VISUALISER
// ============================================

// Fond vert quand JAW est sous LIPS (tendance haussière)
bgcolor(jaw < lips ? color.new(color.green, 85) : na)

// Fond rouge quand JAW est au-dessus de LIPS (tendance baissière)
bgcolor(jaw > lips ? color.new(color.red, 85) : na)

// ============================================
// 9. TABLEAU DE BORD
// ============================================
var table dashboard = table.new(position.bottom_right, 2, 6, bgcolor=color.new(color.black, 85), border_color=color.white)

if barstate.islast
    // État actuel des lignes
    jawLipsRelation = jaw < lips ? "JAW < LIPS (HAUSSIER)" : jaw > lips ? "JAW > LIPS (BAISSIER)" : "JAW = LIPS"
    relationColor = jaw < lips ? color.green : jaw > lips ? color.red : color.gray
    
    // Dernier signal
    lastSignal = buySignal ? "ACHAT (JAW passe sous LIPS)" : sellSignal ? "VENTE (JAW passe au-dessus LIPS)" : "AUCUN"
    signalColor = buySignal ? color.green : sellSignal ? color.red : color.gray
    
    // Statut du signal (valide ou annulé)
    signalStatus = buyContraire ? "⚠️ ACHAT ANNULE" : sellContraire ? "⚠️ VENTE ANNULE" : "SIGNAL VALIDE"
    statusColor = buyContraire or sellContraire ? color.yellow : color.lime
    
    // Entetes
    table.cell(dashboard, 0, 0, "INFORMATION", text_color=color.yellow, text_size=size.small)
    table.cell(dashboard, 1, 0, "VALEUR", text_color=color.yellow, text_size=size.small)
    
    // Lignes
    table.cell(dashboard, 0, 1, "JAW", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 1, str.tostring(jaw, "#.##"), text_color=color.blue, text_size=size.small)
    
    table.cell(dashboard, 0, 2, "LIPS", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 2, str.tostring(lips, "#.##"), text_color=color.green, text_size=size.small)
    
    table.cell(dashboard, 0, 3, "RELATION", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 3, jawLipsRelation, text_color=relationColor, text_size=size.small)
    
    table.cell(dashboard, 0, 4, "DERNIER SIGNAL", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 4, lastSignal, text_color=signalColor, text_size=size.normal)
    
    table.cell(dashboard, 0, 5, "STATUT", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 5, signalStatus, text_color=statusColor, text_size=size.normal)

// ============================================
// 10. ALERTES
// ============================================
alertcondition(buySignal and not buyContraire, "SIGNAL ACHAT VALIDE", "JAW passe en dessous de LIPS - ENTRER ACHAT")
alertcondition(sellSignal and not sellContraire, "SIGNAL VENTE VALIDE", "JAW passe au-dessus de LIPS - ENTRER VENTE")
alertcondition(buyContraire, "⚠️ SIGNAL ACHAT ANNULE", "Signal d'achat annulé - Signal vente dans les 2 bougies suivantes")
alertcondition(sellContraire, "⚠️ SIGNAL VENTE ANNULE", "Signal de vente annulé - Signal achat dans les 2 bougies suivantes")
````
