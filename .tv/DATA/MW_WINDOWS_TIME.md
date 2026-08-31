<!-- tradingview-pine-id: PUB;abdcb3899f5f44ab965c7403ac1489fc -->
<!-- tradingviewscripts-format: 1 -->
# MW WINDOWS TIME

Source: https://www.tradingview.com/script/ZSGjhJSR/

## Description

🇫🇷 Français

MW WINDOWS TIME est un indicateur TradingView simple et visuel conçu pour cadrer les principales fenêtres horaires de trading sur MGC et MNQ.

Il affiche automatiquement deux zones directement sur le graphique :

08h45 → 11h00 : fenêtre Europe, priorité MGC
14h15 → 17h30 : fenêtre US, priorité MNQ + MGC

Pendant chaque fenêtre, l’indicateur crée une boîte qui s’adapte automatiquement au plus haut et au plus bas des bougies de la période. À la fin de la fenêtre, la boîte reste figée afin de conserver un repère visuel clair.

Le nom de l’actif à privilégier est affiché sous chaque boîte :
MGC le matin, puis MNQ • MGC l’après-midi.

L’utilisateur peut personnaliser les couleurs, l’opacité, les bordures, la taille du texte et la position des labels.

Le fuseau horaire peut être réglé manuellement entre UTC+2 et UTC+1 afin de s’adapter au passage heure d’été / heure d’hiver.

L’objectif du script est simple : savoir immédiatement quand chercher un setup et éviter de trader en dehors des fenêtres prévues.

🇬🇧 English

MW WINDOWS TIME is a simple and visual TradingView indicator designed to highlight the main trading windows for MGC and MNQ.

It automatically displays two trading windows directly on the chart:

08:45 → 11:00: European session, priority MGC
14:15 → 17:30: US session, priority MNQ + MGC

During each window, the indicator creates a box that automatically adjusts to the highest and lowest price reached during the session. Once the time window is over, the box remains fixed on the chart for clear historical reference.

The preferred trading instrument is displayed below each box:
MGC during the morning session and MNQ • MGC during the US session.

Users can customize the box colors, opacity, border colors and thickness, text colors, label size, and label position.

The timezone can be manually switched between UTC+2 and UTC+1 to adapt to summer and winter time changes.

The purpose of the script is simple: clearly identify when to look for trading opportunities and avoid trading outside the planned windows.

---

## Source Code

````pine
//@version=6
indicator(
     "MW WINDOWS TIME",
     overlay = true,
     max_boxes_count = 500,
     max_labels_count = 500
)

// =====================================================
// 1. FUSEAU HORAIRE
// =====================================================
string G_TIME = "1. HORAIRES"

string timezone = input.string(
     "UTC+2",
     "Fuseau horaire",
     options = ["UTC+2", "UTC+1"],
     group = G_TIME,
     tooltip = "Été France : UTC+2\nHiver France : UTC+1"
)

string sessionEurope = input.session(
     "0845-1100",
     "Fenêtre Europe — MGC",
     group = G_TIME
)

string sessionUS = input.session(
     "1415-1730",
     "Fenêtre US — MNQ + MGC",
     group = G_TIME
)


// =====================================================
// 2. AFFICHAGE EUROPE
// =====================================================
string G_EU = "2. EUROPE — MGC"

color euColor = input.color(
     color.rgb(255, 170, 0),
     "Couleur boîte",
     group = G_EU
)

int euOpacity = input.int(
     15,
     "Opacité remplissage %",
     minval = 0,
     maxval = 100,
     group = G_EU
)

color euBorder = input.color(
     color.rgb(255, 170, 0),
     "Couleur bordure",
     group = G_EU
)

int euBorderWidth = input.int(
     1,
     "Épaisseur bordure",
     minval = 1,
     maxval = 4,
     group = G_EU
)

color euTextColor = input.color(
     color.rgb(255, 170, 0),
     "Couleur texte",
     group = G_EU
)


// =====================================================
// 3. AFFICHAGE US
// =====================================================
string G_US = "3. US — MNQ + MGC"

color usColor = input.color(
     color.rgb(0, 140, 255),
     "Couleur boîte",
     group = G_US
)

int usOpacity = input.int(
     15,
     "Opacité remplissage %",
     minval = 0,
     maxval = 100,
     group = G_US
)

color usBorder = input.color(
     color.rgb(0, 140, 255),
     "Couleur bordure",
     group = G_US
)

int usBorderWidth = input.int(
     1,
     "Épaisseur bordure",
     minval = 1,
     maxval = 4,
     group = G_US
)

color usTextColor = input.color(
     color.rgb(0, 140, 255),
     "Couleur texte",
     group = G_US
)


// =====================================================
// 4. LABELS
// =====================================================
string G_LABEL = "4. LABELS"

float labelOffsetPct = input.float(
     12.0,
     "Distance sous la boîte %",
     minval = 1.0,
     maxval = 50.0,
     step = 1.0,
     group = G_LABEL
)

string labelSizeInput = input.string(
     "Normal",
     "Taille texte",
     options = ["Petit", "Normal", "Grand"],
     group = G_LABEL
)

string labelSize = switch labelSizeInput
    "Petit"  => size.small
    "Grand"  => size.large
    => size.normal


// =====================================================
// 5. DÉTECTION DES FENÊTRES
// Lundi → Vendredi uniquement
// =====================================================
string weekdays = ":23456"

bool inEurope = not na(
     time(
         timeframe.period,
         sessionEurope + weekdays,
         timezone
     )
)

bool inUS = not na(
     time(
         timeframe.period,
         sessionUS + weekdays,
         timezone
     )
)

bool startEurope = inEurope and not inEurope[1]
bool startUS     = inUS and not inUS[1]


// =====================================================
// 6. VARIABLES EUROPE
// =====================================================
var box   euBox      = na
var label euLabel    = na
var float euHigh     = na
var float euLow      = na
var int   euStartBar = na


// =====================================================
// 7. CONSTRUCTION BOÎTE EUROPE
// =====================================================
if startEurope
    euHigh     := high
    euLow      := low
    euStartBar := bar_index

    euBox := box.new(
         left = bar_index,
         top = euHigh,
         right = bar_index,
         bottom = euLow,
         xloc = xloc.bar_index,
         bgcolor = color.new(euColor, 100 - euOpacity),
         border_color = euBorder,
         border_width = euBorderWidth
    )

    euLabel := label.new(
         x = bar_index,
         y = euLow,
         text = "MGC",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = euTextColor,
         size = labelSize
    )

if inEurope and not na(euBox)
    euHigh := math.max(euHigh, high)
    euLow  := math.min(euLow, low)

    box.set_right(euBox, bar_index)
    box.set_top(euBox, euHigh)
    box.set_bottom(euBox, euLow)

    float euRange  = math.max(euHigh - euLow, syminfo.mintick * 20)
    float euLabelY = euLow - euRange * labelOffsetPct / 100.0

    int euCenter = int(math.floor((euStartBar + bar_index) / 2.0))

    label.set_x(euLabel, euCenter)
    label.set_y(euLabel, euLabelY)


// =====================================================
// 8. VARIABLES US
// =====================================================
var box   usBox      = na
var label usLabel    = na
var float usHigh     = na
var float usLow      = na
var int   usStartBar = na


// =====================================================
// 9. CONSTRUCTION BOÎTE US
// =====================================================
if startUS
    usHigh     := high
    usLow      := low
    usStartBar := bar_index

    usBox := box.new(
         left = bar_index,
         top = usHigh,
         right = bar_index,
         bottom = usLow,
         xloc = xloc.bar_index,
         bgcolor = color.new(usColor, 100 - usOpacity),
         border_color = usBorder,
         border_width = usBorderWidth
    )

    usLabel := label.new(
         x = bar_index,
         y = usLow,
         text = "MNQ  •  MGC",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = usTextColor,
         size = labelSize
    )

if inUS and not na(usBox)
    usHigh := math.max(usHigh, high)
    usLow  := math.min(usLow, low)

    box.set_right(usBox, bar_index)
    box.set_top(usBox, usHigh)
    box.set_bottom(usBox, usLow)

    float usRange  = math.max(usHigh - usLow, syminfo.mintick * 20)
    float usLabelY = usLow - usRange * labelOffsetPct / 100.0

    int usCenter = int(math.floor((usStartBar + bar_index) / 2.0))

    label.set_x(usLabel, usCenter)
    label.set_y(usLabel, usLabelY)
````
