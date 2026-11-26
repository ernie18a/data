# Weekly & Monthly Divider Lines v6

- url: https://www.tradingview.com/script/gOhdINEk/
- type: indicator
- pine_id: PUB;8aab449088cb4c1395f7b896d6963d97
- version: 1.0

## Description

📅 Weekly & Monthly Divider Lines

Cet indicateur trace automatiquement des lignes verticales au début 
de chaque semaine et de chaque mois directement sur votre graphique.
Conçu pour tous les traders qui structurent leur analyse par périodes 
de temps (swing trading, position trading, analyse multi-timeframe).

━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 FONCTIONNALITÉS
━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Ligne hebdomadaire — tracée au premier jour de chaque semaine de trading
✅ Ligne mensuelle — tracée strictement le 1er de chaque mois calendaire
✅ Fenêtre temporelle configurable — passé et futur en années
✅ Couleurs personnalisables indépendamment pour chaque type
✅ Largeur de ligne ajustable (1 à 5)
✅ Gestion automatique des lignes pour respecter les limites Pine Script
✅ Compatible Pine Script v6

━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ PARAMÈTRES
━━━━━━━━━━━━━━━━━━━━━━━━━

- Afficher / masquer les lignes hebdomadaires et mensuelles
- Nombre d'années à afficher dans le passé
- Nombre d'années à afficher dans le futur
- Couleur de chaque type de ligne
- Largeur de chaque type de ligne
- Nombre maximum de lignes conservées par type

━━━━━━━━━━━━━━━━━━━━━━━━━
💡 NOTES TECHNIQUES
━━━━━━━━━━━━━━━━━━━━━━━━━

- La ligne mensuelle se place précisément au 1er du mois, 
  indépendamment du premier jour de trading du mois.
- Un anti-doublon est intégré pour les timeframes intraday.
- Les lignes les plus anciennes sont supprimées automatiquement 
  pour rester dans la limite des 500 lignes de Pine Script.
- Recommandé sur des timeframes allant du 1H au Daily.

━━━━━━━━━━━━━━━━━━━━━━━━━
🖥️ TIMEFRAMES RECOMMANDÉS
━━━━━━━━━━━━━━━━━━━━━━━━━

1H · 4H · Daily

━━━━━━━━━━━━━━━━━━━━━━━━━
🔖 TAGS
━━━━━━━━━━━━━━━━━━━━━━━━━

weekly monthly divider separator lines structure swing 
multi-timeframe calendar session overlay pine-v6

## Source Code

````pine
//@version=6
indicator("Weekly & Monthly Divider Lines — v6", overlay=true, max_lines_count=500)

// --- Inputs ---
showWeekly      = input.bool(true,  "Afficher lignes hebdomadaires")
showMonthly     = input.bool(true,  "Afficher lignes mensuelles")
pastYears       = input.int(1,      "Années à afficher dans le passé",   minval=0)
futureYears     = input.int(1,      "Années à afficher dans le futur",   minval=0)

colWeekly       = input.color(color.new(color.teal,   0), "Couleur hebdomadaire")
colMonthly      = input.color(color.new(color.orange, 0), "Couleur mensuelle")

widthWeekly     = input.int(1, "Largeur ligne hebdo",      minval=1, maxval=5)
widthMonthly    = input.int(1, "Largeur ligne mensuelle",  minval=1, maxval=5)

// ✅ BUG 2 CORRIGÉ : maxval abaissé à 500 (limite globale Pine Script)
maxLinesPerType = input.int(250, "Max lignes gardées par type", minval=10, maxval=500)

// --- Arrays pour stocker les lignes ---
var line[] weeklyLinesArray  = array.new_line()
var line[] monthlyLinesArray = array.new_line()

// --- Fonction utilitaire : ajout + nettoyage ---
push_and_trim(_arr, _lineobj, _maxCount) =>
    array.push(_arr, _lineobj)
    if array.size(_arr) > _maxCount
        oldObj = array.shift(_arr)
        if not na(oldObj)
            line.delete(oldObj)

// ✅ BUG 3 CORRIGÉ : nz() protège contre na sur la 1ère barre
isNewWeek  = nz(ta.change(time("W"))) != 0
isNewMonth = nz(ta.change(time("M"))) != 0

// ✅ BUG 1 CORRIGÉ : timenow ancre la fenêtre sur l'année courante réelle
//    year(time) utilisait l'année de chaque barre → filtre inefficace
currentYear = year(timenow)
startTime   = timestamp(currentYear - pastYears,   1,  1,  0,  0)
endTime     = timestamp(currentYear + futureYears, 12, 31, 23, 59)

// --- Création des lignes ---
if showWeekly and isNewWeek and time >= startTime and time <= endTime
    l = line.new(bar_index, high, bar_index, low, extend=extend.both, color=colWeekly, width=widthWeekly)
    push_and_trim(weeklyLinesArray, l, maxLinesPerType)

if showMonthly and isNewMonth and time >= startTime and time <= endTime
    l2 = line.new(bar_index, high, bar_index, low, extend=extend.both, color=colMonthly, width=widthMonthly)
    push_and_trim(monthlyLinesArray, l2, maxLinesPerType)

// --- Plot invisible requis par Pine v6 ---
plot(na)
````
