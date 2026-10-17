# FX Market Sessions By YukoInvest

- url: https://www.tradingview.com/script/E8eBpQRh/
- type: indicator
- pine_id: PUB;8a495ebe8f1d4579953f0cd4cad2c39b
- version: 1.0

## Description

Fatigué des boîtes de session qui "flottent" au milieu de l'écran quand vous dézoomez ou bougez l'axe des prix ?

Cet indicateur FX Market Sessions By YukoInvest a été spécialement codé pour résoudre le bug d'affichage le plus frustrant de TradingView : le détachement de l'échelle des prix. Grâce à un moteur de rendu optimisé (basé sur une logique de suppression/recréation à chaque tick et un ancrage temporel absolu), vos Killzones resteront physiquement soudées à vos bougies, peu importe comment vous manipulez votre graphique.

Idéal pour les traders ICT, SMC, et Breakout qui ont besoin de visualiser proprement les sessions asiatiques, européennes et américaines.

🌟 Fonctionnalités Clés :
Technologie Anti-Flottement (Anti-Floating Boxes) : Les boîtes utilisent xloc.bar_time et un moteur "Delete & Redraw" robuste. Fini les rectangles qui se baladent dans le vide quand vous modifiez l'échelle verticale !

5 Sessions Intégrées (Personnalisables) :

🇦🇺 Sydney (20:00 - 05:00)

🇯🇵 Tokyo (00:00 - 09:00)

🇩🇪 Frankfurt (07:00 - 16:00)

🇬🇧 London (08:00 - 17:00)

🇺🇸 New York (13:00 - 22:00)

Gestion Dynamique du Fuseau Horaire (Timezone) : Pas besoin de calculer les décalages UTC dans votre tête. Un menu déroulant vous permet d'aligner l'indicateur sur l'heure de New York, Londres, Paris, Tokyo ou UTC en un clic.

Design Épuré : Bordures en pointillés discrètes et fonds semi-transparents color-codés pour ne pas surcharger votre analyse (Price Action d'abord).

⚙️ Comment l'utiliser au mieux :
Timeframes recommandés : Cet indicateur est conçu pour le Day Trading et le Scalping. Utilisez-le sur les unités de temps allant de M1 à H1 (idéalement M5 ou M15).

Superposition : Assurez-vous que l'indicateur est bien lié à la même échelle de prix que votre graphique principal (c'est configuré par défaut dans le code).

Code optimisé en Pine Script v5 pour une gestion parfaite de la mémoire et des limites d'objets (Max Boxes : 500).

Tradez intelligemment, tradez proprement.
© YukoInvest

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YukoInvest

//@version=5
indicator("FX Market Sessions By YukoInvest", overlay=true, max_boxes_count=500)

// --- Inputs Globaux ---
tz_input = input.string("UTC", "Timezone", options=["UTC", "America/New_York", "Europe/Paris", "Europe/London", "Asia/Tokyo"], group="Global")

// --- Configuration des 5 Sessions ---
s1_t = input.session("2000-0500", "1. Sydney", group="Sessions")
s1_c = input.color(color.new(#FB71A3, 85), "Color Sydney", group="Sessions")

s2_t = input.session("0000-0900", "2. Tokyo", group="Sessions")
s2_c = input.color(color.new(#AE81FF, 85), "Color Tokyo", group="Sessions")

s3_t = input.session("0700-1600", "3. Frankfurt", group="Sessions")
s3_c = input.color(color.new(#FFFFFF, 85), "Color Frankfurt", group="Sessions")

s4_t = input.session("0800-1700", "4. London", group="Sessions")
s4_c = input.color(color.new(#66D9EF, 85), "Color London", group="Sessions")

s5_t = input.session("1300-2200", "5. New York", group="Sessions")
s5_c = input.color(color.new(#FD971F, 85), "Color New York", group="Sessions")

// --- LOGIQUE IDENTIQUE AU SCRIPT V4 ---
draw_session(tradeRange, sessColor, tz) =>
    // Détection
    timeIsAllowed = not na(time(timeframe.period, tradeRange, tz))
    newSession = timeIsAllowed and not timeIsAllowed[1]
    
    // Variables persistantes comme dans le v4
    var float refHigh = na
    var float refLow = na
    var int x = na
    var box box1 = na
    
    // 1. Première bougie de la session
    if newSession
        refHigh := high
        refLow := low
        x := time
        // On crée la nouvelle boîte (et on laisse l'ancienne de la veille s'ancrer définitivement)
        box1 := box.new(left=x, top=refHigh, right=time, bottom=refLow, border_color=sessColor, border_width=1, border_style=line.style_dotted, extend=extend.none, xloc=xloc.bar_time, bgcolor=sessColor)
        
    // 2. Pendant la session
    if timeIsAllowed and not newSession
        refHigh := high > refHigh ? high : refHigh
        refLow := low < refLow ? low : refLow
        // Le "Delete & Redraw" exact de ton script de référence
        box.delete(box1)
        box1 := box.new(left=x, top=refHigh, right=time, bottom=refLow, border_color=sessColor, border_width=1, border_style=line.style_dotted, extend=extend.none, xloc=xloc.bar_time, bgcolor=sessColor)

// --- Exécution des 5 Sessions ---
draw_session(s1_t, s1_c, tz_input)
draw_session(s2_t, s2_c, tz_input)
draw_session(s3_t, s3_c, tz_input)
draw_session(s4_t, s4_c, tz_input)
draw_session(s5_t, s5_c, tz_input)
````
