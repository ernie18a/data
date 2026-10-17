# Daily separator

- url: https://www.tradingview.com/script/DrpqDrNv/
- type: indicator
- pine_id: PUB;29c64b3ca958477583912776dfa1810b
- version: 1.0

## Description

Affiche une barre en pointillé verticale dès sur les unités de temps inférieures à daily

## Source Code

````pine
//@version=6
indicator("Séparateur Daily 23h (décalé -6h)", overlay = true, max_lines_count = 500)

// Paramètres configurables
couleur   = input.color(color.new(color.gray, 30), "Couleur")
epaisseur = input.int(1, "Épaisseur", minval = 1, maxval = 4)
// 23 = heure "cible" dans le fuseau du graphique (heure FR si ton chart est en Europe/Paris)
heure_ref = input.int(23, "Heure de séparation (0-23)", minval = 0, maxval = 23)
// Décalage en heures vers le passé (ici 6h)
decalage_heures = input.int(6, "Décalage vers le passé (heures)", minval = 0, maxval = 24)

// Heure/minute de la bougie actuelle (timezone du graphique)
currentHour   = hour(time)
currentMinute = minute(time)

// Condition : UT intraday + première bougie de l'heure choisie
nouvelle_journee = timeframe.isintraday and currentHour == heure_ref and currentMinute == 0

// Tracé de la ligne verticale décalée de N heures dans le passé
if nouvelle_journee
    // On va chercher la bougie d'il y a N heures
    // Sur des UT intraday régulières, N heures ≈ N * (60min / timeframe) bougies
    bars_back = math.round(decalage_heures * 60 / timeframe.multiplier)

    idx = bar_index - bars_back
    // Sécurité : on s'assure de ne pas aller avant le début de l'historique
    if idx >= 0
        line.new(
            x1    = idx,
            y1    = high[bars_back],
            x2    = idx,
            y2    = low[bars_back],
            color = couleur,
            style = line.style_dashed,
            width = epaisseur,
            extend = extend.both
        )
````
