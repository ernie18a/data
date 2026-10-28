# High&Low - Monthly, Weekly, Daily

- url: https://www.tradingview.com/script/SMlh97Wh/
- type: indicator
- pine_id: PUB;0c08ebc100334ab385a012f6312053fb
- version: 1.0

## Description

Découvrez un indicateur conçu pour les traders qui recherchent des zones de réaction précises et une lecture claire du marché.

Cet outil affiche automatiquement les niveaux clés les plus importants à surveiller en utilisant :

les plus hauts et les plus bas du mois précédent
les plus hauts et les plus bas de la semaine précédente
les plus hauts et les plus bas du jour précédent

Ces niveaux permettent d’identifier rapidement les zones où le marché réagit le plus souvent : liquidité, prises de profits, retournements, cassures ou accélérations.

L’objectif est simple : offrir une vision claire des zones institutionnelles importantes afin d’améliorer le timing d’entrée, le risk management et la prise de décision.

Que vous soyez scalpeur ou day trader, cet indicateur vous aide à :

repérer les supports et résistances majeurs
anticiper les réactions du prix sur des niveaux stratégiques
éviter les entrées au milieu de zones sans intérêt
travailler avec une structure de marché plus propre et plus professionnelle
améliorer votre précision d’exécution

Grâce à une interface claire et épurée, les niveaux restent parfaitement lisibles même sur les unités de temps rapides, ce qui en fait un véritable outil de travail au quotidien pour les traders techniques et les traders orientés price action / orderflow.

Un indicateur pensé pour ceux qui veulent arrêter de trader au hasard et commencer à travailler avec des zones réellement pertinentes du marché.

## Source Code

````pine
// @version=5
indicator("High&Low - Scalping", overlay=true)

// ─────────────────────────────
// 1. INPUTS COULEURS
// ─────────────────────────────

// Monthly
color_month_high = input.color(color.white,  "Month High Color", group="Monthly")
color_month_low  = input.color(color.silver, "Month Low Color",  group="Monthly")

// Weekly
color_week_high  = input.color(color.orange, "Week High Color",  group="Weekly")
color_week_low   = input.color(#FFD580,      "Week Low Color",   group="Weekly")

// Daily
color_day_high   = input.color(color.blue,   "Day High Color",   group="Daily")
color_day_low    = input.color(#80CFFF,      "Day Low Color",    group="Daily")

// ─────────────────────────────
// 2. RÉCUPÉRATION DES DONNÉES
// ─────────────────────────────

phm = request.security(syminfo.tickerid, "1M", high[1], lookahead=barmerge.lookahead_on)
plm = request.security(syminfo.tickerid, "1M", low[1],  lookahead=barmerge.lookahead_on)

phw = request.security(syminfo.tickerid, "1W", high[1], lookahead=barmerge.lookahead_on)
plw = request.security(syminfo.tickerid, "1W", low[1],  lookahead=barmerge.lookahead_on)

phd = request.security(syminfo.tickerid, "1D", high[1], lookahead=barmerge.lookahead_on)
pld = request.security(syminfo.tickerid, "1D", low[1],  lookahead=barmerge.lookahead_on)

// ─────────────────────────────
// 3. LOGIQUE DE VISIBILITÉ
// ─────────────────────────────

is_daily_or_lower   = timeframe.isintraday or timeframe.isdaily
is_weekly_or_lower  = timeframe.isintraday or timeframe.isdaily or timeframe.isweekly

// ─────────────────────────────
// 4. FONCTION DE TRACÉ
// ─────────────────────────────

drawLine(level, col, labelText) =>
    
    // Ligne
    var line l = line.new(
         bar_index,
         level,
         bar_index + 1,
         level,
         color=col,
         width=2,
         style=line.style_solid,
         extend=extend.right)

    line.set_xy1(l, bar_index[1], level)
    line.set_xy2(l, bar_index, level)
    line.set_color(l, col)

    // Label
    var label lbl = label.new(
         bar_index,
         level,
         labelText,
         color=color.new(col, 100),
         style=label.style_label_lower_left,
         textcolor=col,
         size=size.small)

    label.set_xy(lbl, bar_index + 10, level)
    label.set_textcolor(lbl, col)

// ─────────────────────────────
// 5. EXÉCUTION
// ─────────────────────────────

if barstate.islast

    // MONTHLY
    drawLine(phm, color_month_high, "Prev Month High")
    drawLine(plm, color_month_low,  "Prev Month Low")

    // WEEKLY
    if is_weekly_or_lower
        drawLine(phw, color_week_high, "Prev Week High")
        drawLine(plw, color_week_low,  "Prev Week Low")

    // DAILY
    if is_daily_or_lower
        drawLine(phd, color_day_high, "Prev Day High")
        drawLine(pld, color_day_low,  "Prev Day Low")
````
