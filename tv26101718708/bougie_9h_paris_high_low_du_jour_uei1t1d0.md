# Bougie 9h Paris - High & Low du jour

- url: https://www.tradingview.com/script/ueI1t1d0/
- type: indicator
- pine_id: PUB;10cfe83fa9464ab49260b4609bc15d28
- version: 1.0

## Description

📊 Bougie 9h Paris - High & Low
🎯 Objectif
Cet indicateur marque automatiquement le plus haut (High) et le plus bas (Low) de la bougie horaire de 9h00 (heure de Paris), un niveau clé largement utilisé par les traders sur les marchés européens (DAX, CAC40, indices européens, forex EUR…).
La bougie de 9h correspond à l'ouverture des marchés européens et concentre souvent une forte volatilité. Ses extrêmes servent fréquemment de niveaux de référence pour la session : cassure haussière, cassure baissière, retour dans le range, etc.
⚙️ Fonctionnalités principales
Détection automatique de la session

Repère la plage horaire 9h00-10h00 en heure de Paris (Europe/Paris)
Gère automatiquement les changements heure d'été / heure d'hiver
Plage horaire entièrement personnalisable (pour adapter à l'ouverture US 15h30, par exemple)

Affichage clair et épuré

Trace une ligne verte horizontale sur le High de la bougie de 9h
Trace une ligne rouge horizontale sur le Low de la bougie de 9h
Affiche une zone colorée entre les deux niveaux (range de 9h)
Étiquettes avec les valeurs exactes du High et du Low
Lignes prolongées jusqu'à la fin de la journée pour visualiser les retests

Nettoyage automatique

Seuls les niveaux du jour en cours sont affichés
Les niveaux des jours précédents disparaissent automatiquement à 9h le lendemain
Graphique propre, sans accumulation de tracés historiques

Alertes intégrées

🔔 Clôture de la bougie 9h : notification dès que les niveaux High/Low sont définitivement positionnés (à 10h)
🔔 Cassure du High : alerte lorsque le prix franchit le plus haut de 9h
🔔 Cassure du Low : alerte lorsque le prix franchit le plus bas de 9h

🛠️ Personnalisation
Tous les éléments visuels sont configurables via le panneau de paramètres :

Affichage des lignes, étiquettes et zone (activable/désactivable)
Couleurs des lignes High, Low et de la zone
Épaisseur des lignes
Plage horaire de la bougie cible
Prolongation des lignes jusqu'en fin de journée

📈 Comment l'utiliser

Ajoutez l'indicateur à votre graphique (timeframe recommandé : M1, M5, M15 ou H1)
À 10h00 heure de Paris, les niveaux High et Low s'affichent automatiquement
Surveillez les cassures ou les rejets sur ces niveaux pour identifier vos opportunités
Configurez les alertes pour ne rater aucun mouvement clé

💡 Stratégies compatibles

Breakout : entrée à la cassure du High ou du Low de 9h
Range trading : trading des rebonds entre les deux extrêmes
Niveau de référence : confirmation directionnelle pour la séance
Stop-loss / Take-profit : utilisation des niveaux comme zones techniques

⚠️ Recommandations

Fonctionne au mieux sur les unités de temps inférieures ou égales à 1h
Particulièrement efficace sur les indices européens, le forex et les futures actifs à l'ouverture européenne
À combiner avec votre analyse globale (tendance, volume, contexte macro)

## Source Code

````pine
//@version=5
indicator("Bougie 9h Paris - High & Low (jour en cours)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ===== PARAMÈTRES =====
grpStyle    = "Style"
showLines   = input.bool(true,  "Afficher les lignes High/Low", group=grpStyle)
showLabels  = input.bool(true,  "Afficher les étiquettes",      group=grpStyle)
showBox     = input.bool(true,  "Afficher la zone (range)",     group=grpStyle)
extendRight = input.bool(true,  "Prolonger jusqu'à fin de journée", group=grpStyle)

colHigh = input.color(color.new(color.green, 0), "Couleur High", group=grpStyle)
colLow  = input.color(color.new(color.red,   0), "Couleur Low",  group=grpStyle)
colBox  = input.color(color.new(color.blue, 85), "Couleur Box",  group=grpStyle)
lineWid = input.int(2, "Épaisseur ligne", minval=1, maxval=4, group=grpStyle)

grpTime  = "Plage horaire"
sessionH = input.session("0900-1000", "Bougie cible (heure de Paris)", group=grpTime, tooltip="Par défaut : la bougie de 9h00 à 10h00 (heure de Paris).")

// ===== DÉTECTION DE LA SESSION (Europe/Paris) =====
inSession = not na(time(timeframe.period, sessionH, "Europe/Paris"))
isFirstBarOfSession = inSession and not inSession[1]
sessionEnded = not inSession and inSession[1]

// ===== VARIABLES PERSISTANTES =====
var float sessHigh = na
var float sessLow  = na
var int   sessStartTime = na

// Objets graphiques persistants (on les supprime/recrée à chaque nouvelle session)
var line  hLine = na
var line  lLine = na
var label hLab  = na
var label lLab  = na
var box   rngBox = na

// ===== NOUVELLE SESSION : on efface les tracés précédents =====
if isFirstBarOfSession
    if not na(hLine)
        line.delete(hLine)
    if not na(lLine)
        line.delete(lLine)
    if not na(hLab)
        label.delete(hLab)
    if not na(lLab)
        label.delete(lLab)
    if not na(rngBox)
        box.delete(rngBox)

    sessHigh := high
    sessLow  := low
    sessStartTime := time
else if inSession
    sessHigh := math.max(sessHigh, high)
    sessLow  := math.min(sessLow,  low)

// ===== TRACÉ À LA FIN DE LA SESSION =====
if sessionEnded and not na(sessHigh) and not na(sessLow)
    endTime = extendRight ? timestamp("Europe/Paris", year, month, dayofmonth, 23, 59) : time

    if showLines
        hLine := line.new(x1=sessStartTime, y1=sessHigh, x2=endTime, y2=sessHigh, xloc=xloc.bar_time, color=colHigh, width=lineWid, style=line.style_solid)
        lLine := line.new(x1=sessStartTime, y1=sessLow,  x2=endTime, y2=sessLow,  xloc=xloc.bar_time, color=colLow,  width=lineWid, style=line.style_solid)

    if showLabels
        hLab := label.new(x=endTime, y=sessHigh, text="9h High " + str.tostring(sessHigh, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=colHigh, textcolor=color.white, size=size.small)
        lLab := label.new(x=endTime, y=sessLow,  text="9h Low "  + str.tostring(sessLow,  format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=colLow,  textcolor=color.white, size=size.small)

    if showBox
        rngBox := box.new(left=sessStartTime, top=sessHigh, right=endTime, bottom=sessLow, xloc=xloc.bar_time, bgcolor=colBox, border_color=color.new(color.blue, 50))

// ===== ALERTES =====
alertcondition(sessionEnded, title="Clôture bougie 9h", message="Fermeture de la bougie, les High Low sont en position")
alertcondition(ta.crossover(close,  sessHigh), title="Cassure du High de 9h", message="Le prix a cassé le High de la bougie de 9h")
alertcondition(ta.crossunder(close, sessLow),  title="Cassure du Low de 9h",  message="Le prix a cassé le Low de la bougie de 9h")
````
