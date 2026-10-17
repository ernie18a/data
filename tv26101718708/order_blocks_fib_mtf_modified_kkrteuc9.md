# Order Blocks + Fib MTF [Modified]

- url: https://www.tradingview.com/script/KkrTEuc9/
- type: indicator
- pine_id: PUB;0f9f40633da44df5a6a01be255c5e5b9
- version: 1.0

## Description

Voici une description TradingView propre et publiée-ready pour ton indicateur 👇
Order Blocks + Fib MTF [Modified]
By LZ — Order Blocks, Major High/Low, Fibonacci avancé et labels MTF à droite
Order Blocks + Fib MTF [Modified] est un indicateur conçu pour repérer les zones d’Order Block, afficher les Major High / Major Low, et projeter automatiquement une grille de Fibonacci précise basée sur la structure active du marché.
L’objectif est simple : combiner structure, zones institutionnelles et niveaux de retracement / extension dans un seul outil visuel, propre et rapide à lire.
Fonctionnalités principales
1. Détection automatique des Order Blocks
L’indicateur identifie automatiquement les :
Demand Zones (zones de demande)
Supply Zones (zones d’offre)
Chaque zone peut être :
affichée brute
ou raffinée avec un algorithme de correction
Deux modes de refinement sont disponibles :
Defensive → zone plus resserrée
Aggressive → zone plus large
2. Affichage des Major High / Major Low
L’indicateur détecte et affiche les :
Major High Levels
Major Low Levels
Ces niveaux servent de base au calcul Fibonacci et permettent de visualiser rapidement la structure dominante du marché.
3. Fibonacci automatique entre Major High et Major Low
Une grille Fibonacci complète est calculée à partir des extrêmes majeurs détectés.
Logique utilisée
Demand (zone verte)
0 = Major Low
1 = Major High
Supply (zone rouge)
0 = Major High
1 = Major Low
Cela permet d’avoir une lecture cohérente selon le sens de la zone active.
Niveaux disponibles
L’indicateur intègre une large sélection de niveaux personnalisables :
0.0 / 0.05 / 0.13 / 0.144 / 0.233 / 0.275 / 0.31 / 0.34 / 0.382 / 0.5 / 0.55 / 0.618 / 0.786 / 0.865 / 0.895 / 1.0 / 1.1 / 1.618
Chaque niveau peut être :
activé ou désactivé
personnalisé en couleur
4. Labels Fibonacci Multi-Timeframe à droite
L’indicateur peut afficher les niveaux Fibonacci de plusieurs unités de temps directement à droite du graphique, sous forme de labels.
Exemple :
0.618 1h
0.5 4h
0.895 1D
Cela permet d’obtenir rapidement une lecture de la confluence multi-timeframe sans surcharger le graphique avec trop de lignes.
MTF disponibles
MTF 1
MTF 2
MTF 3
Chaque timeframe peut être :
activée ou désactivée
choisie librement
affichée avec une taille de label personnalisable
5. Support / Resistance
L’indicateur peut également afficher :
le dernier support
la dernière résistance
Cela ajoute une lecture structurelle complémentaire à l’analyse des zones.
6. Système d’alertes intégré
L’indicateur inclut un système d’alertes permettant de recevoir des signaux lorsque le prix revient dans les zones détectées.
Options disponibles :
activation / désactivation des alertes
fréquence du message
fuseau horaire
message personnalisé bull / bear
Utilisation recommandée
Cet indicateur est particulièrement utile pour :
repérer les zones de réaction probables
surveiller les retests d’Order Blocks
travailler les entrées en confluence avec Fibonacci
comparer plusieurs timeframes en un coup d’œil
améliorer le timing sur des setups basés sur la structure
Il peut être utilisé seul, mais il devient encore plus puissant lorsqu’il est combiné avec :
action du prix
volume
RSI MTF
confirmations de retournement
contexte HTF
Points forts
lecture visuelle claire
Fibonacci avancé et personnalisable
logique différente selon Demand / Supply
confluence MTF sans surcharge
support et résistance intégrés
alertes prêtes à l’emploi
Remarques
Cet indicateur est un outil d’analyse visuelle et structurelle.
Il ne garantit pas à lui seul la réussite d’un trade et doit être utilisé avec une gestion du risque adaptée.
Crédits
Modification et adaptation par LZ
Basé sur une logique d’Order Blocks + Structure + Fibonacci MTF
Si tu veux, je peux maintenant te faire aussi une version plus “pro/prestige” pour publication publique TradingView, ou une version plus agressive marketing.

Affichage de fibo lZ.txt en cours...

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//  BY LZ Fibonacci between Major High/Low + MTF labels on the right
//@version=5

/////////////////////////////////////////////////////////
//    {Vectorize Code Version(Without using loop!)}    //
/////////////////////////////////////////////////////////
indicator("Order Blocks + Fib MTF [Modified]", "OB + Fib MTF", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//Import library
import TFlab/AlertSenderLibrary_TradingFinder/1 as Alert

//=========================================================================
//                       ORIGINAL USER SETTINGS
//=========================================================================
OBRefine = input.string('On', 'Order Block Refine', ['On' , 'Off'],
 tooltip = 'If Order Block Refine is Turned on, an Attempt is made to Detect the Optimal Range for the Order Block Using an Error Correction Algorithm.' , group = 'Order Block Setting')

RefineType = input.string('Defensive', 'Refine Type', ['Defensive' , 'Aggressive'],
 tooltip = 'By Using Aggressive Error Correction Algorithm, a Large Range is Identified as Block Order. The Defensive Algorithm Detect a Small Range.' ,  group = 'Order Block Setting')

Show_High = input.string('No', 'Show High Level', ['No' , 'Yes'], tooltip = 'High Major Levels' , group = 'Major Levels')
Show_Low  = input.string('No', 'Show Low Level',  ['No' , 'Yes'], tooltip = 'Low Major Levels'  , group = 'Major Levels')

Show_Support    = input.string('No', 'Show Last Support',    ['No' , 'Yes'], tooltip = 'Last Support'    , group = 'Support and Resistance')
Show_Resistance = input.string('No', 'Show Last Resistance', ['No' , 'Yes'], tooltip = 'Last Resistance' , group = 'Support and Resistance')

DemBxColor = input.color(color.rgb(105,191,111 , 50), 'Demand Zone Color', group =  ' Color Setting')
SupBxColor = input.color(color.rgb(242,34,51,60)    , 'Supply Zone Color', group =  ' Color Setting')

Alert_       = input.string('On' , 'Alert' , ['On', 'Off'], 'If you turn on the Alert, you can receive alerts and notifications after setting the "Alert".' , group = 'Alert')
AlertName    = input.string('Order Blocks Finder [TradingFinder]', 'Alert Name', group = 'Alert')
Frequncy     = input.string('Once Per Bar' , 'Message Frequency' , ['All', 'Once Per Bar' , 'Per Bar Close'], group = 'Alert')
UTC          = input.string('UTC' , 'Show Alert time by Time Zone', group = 'Alert')
MoreInfo     = input.string('On', 'Display More Info', ['On', 'Off'], group = 'Alert')
MessageBull  = input.text_area('Long Position', 'Long Signal Message' ,group = 'Alert')
MessageBear  = input.text_area('Short Position','Short Signal Message' , group = 'Alert')

//=========================================================================
//                       FIBONACCI SETTINGS
//=========================================================================
// RULE (final, validated) :
//   Demand (vert)  → 0 = Major LOW  (bas) / 1 = Major HIGH (haut)
//   Supply (rouge) → 0 = Major HIGH (haut) / 1 = Major LOW  (bas)
// Points 0 and 1 are the Major High and Major Low (same lines as "Show High/Low Level").
//=========================================================================
fibGroup = '━━━ Fibonacci ━━━'

//----------------- LEVELS (exact list from image 2) --------------------
fibLvlGroup = '━━━ Fibonacci Levels ━━━'

en_0    = input.bool(true,  '0.0',   inline='L1', group=fibLvlGroup)
col_0   = input.color(color.white, '', inline='L1', group=fibLvlGroup)
en_005  = input.bool(true,  '0.05',  inline='L1', group=fibLvlGroup)
col_005 = input.color(color.rgb(160, 32, 240), '', inline='L1', group=fibLvlGroup)

en_013  = input.bool(true,  '0.13',  inline='L2', group=fibLvlGroup)
col_013 = input.color(color.teal, '', inline='L2', group=fibLvlGroup)
en_0144 = input.bool(true,  '0.144', inline='L2', group=fibLvlGroup)
col_0144= input.color(color.orange, '', inline='L2', group=fibLvlGroup)

en_0233 = input.bool(true,  '0.233', inline='L3', group=fibLvlGroup)
col_0233= input.color(color.rgb(233, 30, 99), '', inline='L3', group=fibLvlGroup)
en_0275 = input.bool(true,  '0.275', inline='L3', group=fibLvlGroup)
col_0275= input.color(color.teal, '', inline='L3', group=fibLvlGroup)

en_031  = input.bool(true,  '0.31',  inline='L4', group=fibLvlGroup)
col_031 = input.color(color.red, '', inline='L4', group=fibLvlGroup)
en_034  = input.bool(true,  '0.34',  inline='L4', group=fibLvlGroup)
col_034 = input.color(color.yellow, '', inline='L4', group=fibLvlGroup)

en_0382 = input.bool(true,  '0.382', inline='L5', group=fibLvlGroup)
col_0382= input.color(color.white, '', inline='L5', group=fibLvlGroup)
en_05   = input.bool(true,  '0.5',   inline='L5', group=fibLvlGroup)
col_05  = input.color(color.rgb(144, 238, 144), '', inline='L5', group=fibLvlGroup)

en_055  = input.bool(true,  '0.55',  inline='L6', group=fibLvlGroup)
col_055 = input.color(color.teal, '', inline='L6', group=fibLvlGroup)
en_0618 = input.bool(true,  '0.618', inline='L6', group=fibLvlGroup)
col_0618= input.color(color.blue, '', inline='L6', group=fibLvlGroup)

en_0786 = input.bool(true,  '0.786', inline='L7', group=fibLvlGroup)
col_0786= input.color(color.orange, '', inline='L7', group=fibLvlGroup)
en_0865 = input.bool(true,  '0.865', inline='L7', group=fibLvlGroup)
col_0865= input.color(color.teal, '', inline='L7', group=fibLvlGroup)

en_0895 = input.bool(true,  '0.895', inline='L8', group=fibLvlGroup)
col_0895= input.color(color.yellow, '', inline='L8', group=fibLvlGroup)
en_1    = input.bool(true,  '1.0',   inline='L8', group=fibLvlGroup)
col_1   = input.color(color.white, '', inline='L8', group=fibLvlGroup)

en_11   = input.bool(true,  '1.1',   inline='L9', group=fibLvlGroup)
col_11  = input.color(color.white, '', inline='L9', group=fibLvlGroup)
en_1618 = input.bool(true,  '1.618', inline='L9', group=fibLvlGroup)
col_1618= input.color(color.red, '', inline='L9', group=fibLvlGroup)

//=========================================================================
//                         MTF SETTINGS
//=========================================================================
mtfGroup = '━━━ MTF Fibonacci (Labels only, right-side) ━━━'
mtf_label_size_s = input.string('small', 'MTF Label Size', ['tiny', 'small', 'normal', 'large'], group=mtfGroup)
mtf_label_offset = input.int(30, 'MTF Label Offset (bars right of last bar)', minval=1, maxval=100, group=mtfGroup, tooltip='Horizontal position of MTF labels to the right of the current bar.')

mtf1_en = input.bool(true,  'Enable MTF 1', inline='mtf1', group='MTF 1')
mtf1_tf = input.timeframe('60', '', inline='mtf1', group='MTF 1')

mtf2_en = input.bool(false, 'Enable MTF 2', inline='mtf2', group='MTF 2')
mtf2_tf = input.timeframe('240', '', inline='mtf2', group='MTF 2')

mtf3_en = input.bool(false, 'Enable MTF 3', inline='mtf3', group='MTF 3')
mtf3_tf = input.timeframe('D', '', inline='mtf3', group='MTF 3')

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Candle Range
Candle_Range = high - low
Candle_Body  = close - open
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Candle Trend Detector
Candle_Trend = if Candle_Body > 0
    "Candle Positive"
else if Candle_Body < 0
    "Candle Negative"
else
    "Candle no Trend"
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Candle Break Detector
Candle_Break = if close > high[1]
    "Candle Bull Break"
else if close < low[1]
    "Candle Bear Break"
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//High and Low Detector
bar_index_bull = ta.valuewhen(close > high[1] , bar_index,0)
bar_index_bear = ta.valuewhen(close < low[1]  , bar_index,0)

var int start_bar_index_high = 0 
var int start_bar_index_low  = 0

lenHighest  = bar_index - bar_index_bear + 5
lenLowest   = bar_index - bar_index_bull + 5
lenHighest1 = bar_index - bar_index_bear + 3
lenLowest1  = bar_index - bar_index_bull + 3

HighestLen  = not na(lenHighest)  ? lenHighest  : 1
LowestLen   = not na(lenLowest)   ? lenLowest   : 1
HighestLen1 = not na(lenHighest1) ? lenHighest1 : 1
LowestLen1  = not na(lenLowest1)  ? lenLowest1  : 1

High_first  = ta.highest(high, HighestLen)
Low_first   = ta.lowest (low , LowestLen)
High_first1 = ta.highest(high, HighestLen1)
Low_first1  = ta.lowest (low , LowestLen1)

var float High_Correct = 0.0 
var float Low_Correct  = 0.0

High_sec = if Candle_Break == "Candle Bear Break" and Candle_Break[1] == "Candle Bull Break"
    start_bar_index_high := bar_index
    High_Correct[1] == High_first ? High_first1 : High_first

Low_sec = if (Candle_Break == "Candle Bull Break" and Candle_Break[1] == "Candle Bear Break") 
    start_bar_index_low := bar_index
    Low_Correct[1] == Low_first ? Low_first1 : Low_first

High_Correct := not na(High_sec) ? High_sec : High_sec[1]
Low_Correct  := not na(Low_sec)  ? Low_sec  : Low_sec[1]

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var int bar_index_bull_BoS = 0
var int bar_index_bear_BoS = 0
var string BoS = "Hi"

var float High_Correct_f = 0.0
var float Low_Correct_f  = 0.0

//Major Correct High and Low Detector
High_Correct_f := if High_Correct_f == 0
    High_Correct
else if High_Correct > High_Correct_f[1] and High_Correct_f != 0
    High_Correct
else if High_Correct < High_Correct_f[1]
    if BoS == 'Bear BoS' and (bar_index_bear_BoS >= start_bar_index_high)
        High_Correct
    else 
        High_Correct_f
else if High_Correct_f == High_Correct_f[1] and High_Correct_f != 0
    High_Correct_f
else 
    High_Correct

Low_Correct_f := if Low_Correct_f == 0 
    Low_Correct
else if Low_Correct < Low_Correct_f[1] and Low_Correct_f != 0
    Low_Correct
else if Low_Correct > Low_Correct_f[1]
    if BoS == 'Bull BoS' and  (bar_index_bull_BoS >= start_bar_index_low)
        Low_Correct
    else 
        Low_Correct_f
else if Low_Correct_f == Low_Correct_f[1] and Low_Correct_f != 0
    Low_Correct_f
else 
    Low_Correct

//Drawing Last Support and Resistance Line
var line Sline = na
var line Rline = na
float LV = Low_Correct_f
int   LI = 0
float HV = High_Correct_f
int   HI = 0
if LV != LV[1] and Show_Support == 'Yes'
    line.delete(Sline[1])
    LI := bar_index
    Sline := line.new(LI, LV , LI+1 , LV , extend = extend.right , style = line.style_dotted , color = color.rgb(0, 82, 3))
if HV != HV[1] and  Show_Resistance == 'Yes'
    line.delete(Rline[1])
    HI := bar_index
    Rline := line.new(HI, HV , HI+1 , HV , extend = extend.right , style = line.style_dotted , color = color.rgb(146, 33, 33) )

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//High and Low Drawing
color_High = High_Correct_f == High_Correct_f[1] ? color.rgb(5, 148, 10) : na 
color_Low  = Low_Correct_f  == Low_Correct_f[1]  ? color.rgb(184, 0, 0)  : na

plot(High_Correct_f,'Major High Levels' ,color = Show_High == 'Yes' ? color_High : na )
plot(Low_Correct_f ,'Major Low Levels'  ,color = Show_Low  == 'Yes' ? color_Low  : na)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BoS Detector
if close > High_Correct_f and close[1] <= High_Correct_f
    BoS := "Bull BoS"
    bar_index_bull_BoS := bar_index
else if close < Low_Correct_f and close[1] >= Low_Correct_f
    BoS := "Bear BoS"
    bar_index_bear_BoS := bar_index
else
    BoS := '0'

//Trend Detector
var string Trend = "Hi"
if BoS == "Bull BoS" and bar_index_bull_BoS[1] > bar_index_bear_BoS
    Trend := "Up Trend"
else if BoS == "Bear BoS" and bar_index_bear_BoS[1] > bar_index_bull_BoS 
    Trend := "Down Trend"
else if Trend == "Up Trend" and close < Low_Correct_f or Trend == "Down Trend" and close > High_Correct_f
    Trend := "No Trend"
else 
    Trend := Trend

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Order Block Detector
bar_index_Supply_OB = ta.valuewhen(High_Correct != High_Correct[1], bar_index[1],0)
bar_index_Demand_OB = ta.valuewhen(Low_Correct  != Low_Correct[1],  bar_index[1],0)

var DOB_index    = 0
var SOB_index    = 0
var PerDOB_index = 0
var PerSOB_index = 0

var int DemandCheck = 0
var int SupplyCheck = 0

DOB_index := ta.valuewhen((BoS == "Bull BoS" and bar_index_bull_BoS[1] > bar_index_bear_BoS ) or
 (BoS =="Bull BoS" and bar_index_bull_BoS > bar_index_bear_BoS ), bar_index, 0)

SOB_index := ta.valuewhen((BoS == "Bear BoS" and bar_index_bear_BoS[1] >  bar_index_bull_BoS ) or
 (BoS == "Bear BoS" and bar_index_bear_BoS >  bar_index_bull_BoS ), bar_index, 0)

PerDOB_index := ta.valuewhen((BoS == "Bull BoS" and bar_index_bull_BoS[1] > bar_index_bear_BoS ) or
 (BoS =="Bull BoS" and bar_index_bull_BoS > bar_index_bear_BoS ), bar_index, 1)

PerSOB_index := ta.valuewhen((BoS == "Bear BoS" and bar_index_bear_BoS[1] >  bar_index_bull_BoS ) or
 (BoS == "Bear BoS" and bar_index_bear_BoS >  bar_index_bull_BoS ), bar_index, 1)

Demand_OB_Condition = (((BoS == "Bull BoS" and bar_index_bull_BoS[1] > bar_index_bear_BoS ) or
     (BoS =="Bull BoS" and bar_index_bull_BoS > bar_index_bear_BoS ))) and
     DemandCheck != bar_index_Demand_OB

Supply_OB_Condition = (((BoS == "Bear BoS" and bar_index_bear_BoS[1] >  bar_index_bull_BoS ) or
     (BoS == "Bear BoS" and bar_index_bear_BoS >  bar_index_bull_BoS))) and 
     SupplyCheck != bar_index_Supply_OB

//BOX Drawing Data
var float YDp12 = 0.0
var int   XDp1  = 0
var int   XDp2  = 0
var float YDd12 = 0.0
var int   XDd1  = 0
var int   XDd2  = 0

var float YSp12 = 0.0
var int   XSp1  = 0
var int   XSp2  = 0
var float YSd12 = 0.0
var int   XSd1  = 0
var int   XSd2  = 0

//Order Block Refine
ATR = ta.atr(55)

//----- Demand Candle Range -----
var float DCRa1 = 0.0
var float DCRO  = 0.0
var float DCRb1 = 0.0

if bar_index >= bar_index_Demand_OB + 1
    DCRa1 := Candle_Range[bar_index - bar_index_Demand_OB + 1] 
    DCRO  := Candle_Range[bar_index - bar_index_Demand_OB]  
    DCRb1 := Candle_Range[bar_index - bar_index_Demand_OB - 1] 

//Demand Min ohlc
var float DminOpen  = 0.0
var float DminHigh  = 0.0
var float DminLow   = 0.0
var float DminClose = 0.0
var float DmaxOpen  = 0.0
var float DmaxHigh  = 0.0
var float DmaxLow   = 0.0
var float DmaxClose = 0.0

if  bar_index > bar_index_Demand_OB + 1
    DminOpen  := math.min(open[bar_index - bar_index_Demand_OB - 2], open[bar_index - bar_index_Demand_OB + 1],  open[bar_index - bar_index_Demand_OB    ], open[bar_index - bar_index_Demand_OB - 1])
    DminHigh  := math.min(high[bar_index - bar_index_Demand_OB - 2], high[bar_index - bar_index_Demand_OB + 1],  high[bar_index - bar_index_Demand_OB    ], high[bar_index - bar_index_Demand_OB - 1])
    DminLow   := math.min(low[bar_index - bar_index_Demand_OB - 2],  low[bar_index - bar_index_Demand_OB + 1],   low[bar_index - bar_index_Demand_OB    ],  low[bar_index - bar_index_Demand_OB - 1])
    DminClose := math.min(close[bar_index - bar_index_Demand_OB - 2],close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB    ],close[bar_index - bar_index_Demand_OB - 1])
else if   bar_index  >= bar_index_Demand_OB 
    DminOpen  := math.min(open[bar_index - bar_index_Demand_OB + 1],  open[bar_index - bar_index_Demand_OB    ], open[bar_index - bar_index_Demand_OB - 1])
    DminHigh  := math.min(high[bar_index - bar_index_Demand_OB + 1],  high[bar_index - bar_index_Demand_OB    ], high[bar_index - bar_index_Demand_OB - 1])
    DminLow   := math.min(low[bar_index - bar_index_Demand_OB + 1],   low[bar_index - bar_index_Demand_OB    ],  low[bar_index - bar_index_Demand_OB - 1])
    DminClose := math.min(close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB    ],close[bar_index - bar_index_Demand_OB - 1])

if  bar_index > bar_index_Demand_OB + 1
    DmaxOpen  := math.max(open[bar_index - bar_index_Demand_OB - 2], open[bar_index - bar_index_Demand_OB + 1],  open[bar_index - bar_index_Demand_OB    ], open[bar_index - bar_index_Demand_OB - 1])
    DmaxHigh  := math.max(high[bar_index - bar_index_Demand_OB - 2], high[bar_index - bar_index_Demand_OB + 1],  high[bar_index - bar_index_Demand_OB    ], high[bar_index - bar_index_Demand_OB - 1])
    DmaxLow   := math.max(low[bar_index - bar_index_Demand_OB - 2],  low[bar_index - bar_index_Demand_OB + 1],   low[bar_index - bar_index_Demand_OB    ],  low[bar_index - bar_index_Demand_OB - 1])
    DmaxClose := math.max(close[bar_index - bar_index_Demand_OB - 2],close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB    ],close[bar_index - bar_index_Demand_OB - 1])
else if  bar_index >= bar_index_Demand_OB 
    DmaxOpen  := math.max(open[bar_index - bar_index_Demand_OB + 1],  open[bar_index - bar_index_Demand_OB    ], open[bar_index - bar_index_Demand_OB - 1])
    DmaxHigh  := math.max(high[bar_index - bar_index_Demand_OB + 1],  high[bar_index - bar_index_Demand_OB    ], high[bar_index - bar_index_Demand_OB - 1])
    DmaxLow   := math.max(low[bar_index - bar_index_Demand_OB + 1],   low[bar_index - bar_index_Demand_OB    ],  low[bar_index - bar_index_Demand_OB - 1])
    DmaxClose := math.max(close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB    ],close[bar_index - bar_index_Demand_OB - 1])

//Demand Order Block Refiner
var float DDA = 0.0
var float DPA = 0.0
 
if DCRO <= (ATR * 0.5)
    DPA := high[bar_index - bar_index_Demand_OB]
    DDA := DminLow
else if DCRO > (ATR * 0.5) and DCRO <= ATR
    if Candle_Body > 0 or Candle_Body == 0
        DPA := close[bar_index - bar_index_Demand_OB]
        DDA := DminLow
    else if Candle_Body < 0 
        DPA := open[bar_index - bar_index_Demand_OB]
        DDA := DminLow
else if DCRO > ATR
    if low[bar_index - bar_index_Demand_OB + 1] < high[bar_index - bar_index_Demand_OB    ]
        if low[bar_index - bar_index_Demand_OB + 1] > low[bar_index - bar_index_Demand_OB]
            DPA := low[bar_index - bar_index_Demand_OB + 1]
            DDA := low[bar_index - bar_index_Demand_OB]
        else if low[bar_index - bar_index_Demand_OB + 1] <= low[bar_index - bar_index_Demand_OB]
            if Candle_Body[bar_index - bar_index_Demand_OB + 1] > 0 or Candle_Body[bar_index - bar_index_Demand_OB + 1] == 0
                if DCRa1 > ATR
                    DPA := DmaxOpen
                    DDA := DminLow
                else if DCRa1 < ATR
                    DPA := DmaxClose
                    DDA := DminLow
            else if Candle_Body[bar_index - bar_index_Demand_OB + 1] < 0 
                if DCRa1 > ATR
                    DPA := DmaxOpen
                    DDA := DminLow
                else if DCRa1 < ATR
                    DPA := DmaxOpen
                    DDA := DminLow
    else if not ((low[bar_index - bar_index_Demand_OB + 1] < high[bar_index - bar_index_Demand_OB    ]))
        if (DminLow - DminOpen ) > (DminLow - DminClose ) and ((DminLow - DminOpen ) <= ATR and (DminLow - DminOpen ) >= ( ATR*0.5)) 
            DPA := DminOpen
            DDA := DminLow
        else if (DminLow - DminOpen ) < (DminLow - DminClose ) and ((DminLow - DminClose ) <= ATR and (DminLow - DminClose ) >= ( ATR*0.5))
            DPA := DminClose
            DDA := DminLow
else 
    if Candle_Body > 0
        DPA := DmaxHigh
        DDA := DminLow
    else if Candle_Body < 0
        DPA := DmaxHigh
        DDA := DmaxLow

//Supply Candle Range
var float SCRa1 = 0.0
var float SCRO  = 0.0
var float SCRb1 = 0.0

SCRa1 := high[bar_index -bar_index_Supply_OB + 1] - low[bar_index -bar_index_Supply_OB + 1]
SCRO  := high[bar_index -bar_index_Supply_OB    ] - low[bar_index -bar_index_Supply_OB    ]
SCRb1 := high[bar_index -bar_index_Supply_OB - 1] - low[bar_index -bar_index_Supply_OB - 1]

//Supply Min/Max ohlc
var float SminOpen  = 0.0
var float SminHigh  = 0.0
var float SminLow   = 0.0
var float SminClose = 0.0
var float SmaxOpen  = 0.0
var float SmaxHigh  = 0.0
var float SmaxLow   = 0.0
var float SmaxClose = 0.0

if  bar_index > bar_index_Supply_OB + 1
    SminOpen  := math.min(open[bar_index - bar_index_Supply_OB - 2], open[bar_index - bar_index_Supply_OB + 1],  open[bar_index - bar_index_Supply_OB    ], open[bar_index - bar_index_Supply_OB - 1])
    SminHigh  := math.min(high[bar_index - bar_index_Supply_OB - 2], high[bar_index - bar_index_Supply_OB + 1],  high[bar_index - bar_index_Supply_OB    ], high[bar_index - bar_index_Supply_OB - 1])
    SminLow   := math.min(low[bar_index - bar_index_Supply_OB - 2],  low[bar_index - bar_index_Supply_OB + 1],   low[bar_index - bar_index_Supply_OB    ],  low[bar_index - bar_index_Supply_OB - 1])
    SminClose := math.min(close[bar_index - bar_index_Supply_OB - 2],close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB    ],close[bar_index - bar_index_Supply_OB - 1])
else if   bar_index  >= bar_index_Supply_OB 
    SminOpen  := math.min(open[bar_index - bar_index_Supply_OB + 1],  open[bar_index - bar_index_Supply_OB    ], open[bar_index - bar_index_Supply_OB - 1])
    SminHigh  := math.min(high[bar_index - bar_index_Supply_OB + 1],  high[bar_index - bar_index_Supply_OB    ], high[bar_index - bar_index_Supply_OB - 1])
    SminLow   := math.min(low[bar_index - bar_index_Supply_OB + 1],   low[bar_index - bar_index_Supply_OB    ],  low[bar_index - bar_index_Supply_OB - 1])
    SminClose := math.min(close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB    ],close[bar_index - bar_index_Supply_OB - 1])

if  bar_index > bar_index_Supply_OB + 1
    SmaxOpen  := math.max(open[bar_index - bar_index_Supply_OB - 2], open[bar_index - bar_index_Supply_OB + 1],  open[bar_index - bar_index_Supply_OB    ], open[bar_index - bar_index_Supply_OB - 1])
    SmaxHigh  := math.max(high[bar_index - bar_index_Supply_OB - 2], high[bar_index - bar_index_Supply_OB + 1],  high[bar_index - bar_index_Supply_OB    ], high[bar_index - bar_index_Supply_OB - 1])
    SmaxLow   := math.max(low[bar_index - bar_index_Supply_OB - 2],  low[bar_index - bar_index_Supply_OB + 1],   low[bar_index - bar_index_Supply_OB    ],  low[bar_index - bar_index_Supply_OB - 1])
    SmaxClose := math.max(close[bar_index - bar_index_Supply_OB - 2],close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB    ],close[bar_index - bar_index_Supply_OB - 1])
else if  bar_index >= bar_index_Supply_OB 
    SmaxOpen  := math.max(open[bar_index - bar_index_Supply_OB + 1],  open[bar_index - bar_index_Supply_OB    ], open[bar_index - bar_index_Supply_OB - 1])
    SmaxHigh  := math.max(high[bar_index - bar_index_Supply_OB + 1],  high[bar_index - bar_index_Supply_OB    ], high[bar_index - bar_index_Supply_OB - 1])
    SmaxLow   := math.max(low[bar_index - bar_index_Supply_OB + 1],   low[bar_index - bar_index_Supply_OB    ],  low[bar_index - bar_index_Supply_OB - 1])
    SmaxClose := math.max(close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB    ],close[bar_index - bar_index_Supply_OB - 1])

//Supply Order Block Refiner
var float SDA = 0.0
var float SPA = 0.0

if SCRO <= (ATR * 0.5)
    SPA := low[bar_index - bar_index_Supply_OB]
    SDA := SmaxHigh
else if SCRO > (ATR * 0.5) and SCRO <= ATR
    if Candle_Body > 0 or Candle_Body == 0
        SPA := close[bar_index - bar_index_Supply_OB]
        SDA := SmaxHigh
    else if Candle_Body < 0 
        SPA := open[bar_index - bar_index_Supply_OB]
        SDA := SmaxHigh
else if SCRO > ATR
    if high[bar_index - bar_index_Supply_OB - 1] > low[bar_index - bar_index_Supply_OB    ]
        if high[bar_index - bar_index_Supply_OB - 1] > high[bar_index - bar_index_Supply_OB]
            SPA := high[bar_index - bar_index_Supply_OB - 1]
            SDA := high[bar_index - bar_index_Supply_OB]
        else if high[bar_index - bar_index_Supply_OB - 1] <= high[bar_index - bar_index_Supply_OB]
            if Candle_Body[bar_index - bar_index_Supply_OB - 1] > 0 or Candle_Body[bar_index - bar_index_Supply_OB - 1] == 0
                if SCRa1 > ATR
                    SPA := SminClose
                    SDA := SmaxHigh
                else if SCRa1 < ATR
                    SPA := SminOpen
                    SDA := SmaxHigh
            else if Candle_Body[bar_index - bar_index_Supply_OB - 1] < 0 
                if SCRa1 > ATR
                    SPA := SminOpen
                    SDA := SmaxHigh
                else if SCRa1 < ATR
                    SPA := SmaxHigh
                    SDA := high[bar_index - bar_index_Supply_OB - 1]
    else if not ((high[bar_index - bar_index_Supply_OB + 1] > low[bar_index - bar_index_Supply_OB    ]))
        if (SmaxHigh - SminOpen ) > (SmaxHigh - SminClose ) and ((SmaxHigh - SminOpen ) <= ATR and (SmaxHigh - SminOpen ) >= ( ATR*0.5)) 
            SPA := SminOpen
            SDA := SmaxHigh
        else if (SmaxHigh - DminOpen ) < (SmaxHigh - DminClose ) and ((SmaxHigh - DminClose ) <= ATR and (SmaxHigh - DminClose ) >= ( ATR*0.5))
            SPA := SminClose
            SDA := SmaxHigh
else 
    if Candle_Body > 0
        SPA := SminLow
        SDA := SmaxHigh
    else if Candle_Body < 0
        SPA := SminLow
        SDA := SmaxHigh

// choose Type Refine
var float DProximal = 0.0
var float DDistal   = 0.0
var float SProximal = 0.0
var float SDistal   = 0.0

if RefineType == 'Defensive'
    if (DPA - DDA) >= ATR * 3
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.7
    else if (DPA - DDA) < ATR * 3 and (DPA - DDA) >= ATR * 2
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.6   
    else if (DPA - DDA) < ATR * 2 and (DPA - DDA) >= ATR *1.6
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.5
    else if (DPA - DDA) < ATR * 1.6 and (DPA - DDA) > ATR
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.25        
    else if (DPA - DDA) <= ATR
        DDistal := DDA
        DProximal := DPA  
else  if RefineType == 'Aggressive'
    DDistal := DDA
    DProximal := DPA    

if RefineType == 'Defensive'
    if (SDA - SPA) >= ATR * 3
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.7
    else if (SDA - SPA) < ATR * 3 and (SDA - SPA) >= ATR * 2
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.6   
    else if (SDA - SPA) < ATR * 2 and (SDA - SPA) >= ATR * 1.6
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.5
    else if (SDA - SPA) < ATR * 1.6 and (SDA - SPA) > ATR 
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.25       
    else if (SDA - SPA) <= ATR 
        SDistal := SDA
        SProximal := SPA  
else  if RefineType == 'Aggressive'
    SDistal := SDA
    SProximal := SPA  

////////////////////////
if Demand_OB_Condition 
    DemandCheck := bar_index_Demand_OB 
    YDp12   := OBRefine == 'On' ? DProximal : high[bar_index - bar_index_Demand_OB]
    XDp1    := bar_index_Demand_OB
    XDp2    := bar_index_Demand_OB + 1
    YDd12   := OBRefine == 'On' ? DDistal : low[bar_index - bar_index_Demand_OB]
    XDd1    := bar_index_Demand_OB
    XDd2    := bar_index_Demand_OB + 1
 
if Supply_OB_Condition
    SupplyCheck := bar_index_Supply_OB
    YSp12   := OBRefine == 'On' ? SProximal : low[bar_index - bar_index_Supply_OB]
    XSp1    := bar_index_Supply_OB
    XSp2    := bar_index_Supply_OB + 1
    YSd12   :=  OBRefine == 'On' ? SDistal : high[bar_index - bar_index_Supply_OB]
    XSd1    := bar_index_Supply_OB
    XSd2    := bar_index_Supply_OB + 1

//Dynamic Drawing Zone
LinerFunctionDem(Xd1, Yd1, Xd2, Yd2 ,Xp1, Yp1, Xp2, Yp2 , Xn) =>
    xd1 = Xd1
    xd2 = Xd2
    yd1 = Yd1
    yd2 = Yd2
    xdn = Xn 
    xdnz = Xn 
    md =  (yd2 - yd1) / (xd2 - xd1)
    bd = yd1 - md*xd1
    Ydnz = md*(xdnz) + bd
    Ydn = md*(xdn) + bd
    xp1 = Xp1
    xp2 = Xp2
    yp1 = Yp1
    yp2 = Yp2
    xpn = Xn 
    xpnz = Xn 
    mp =  (yp2 - yp1) / (xp2 - xp1)
    bp = yp1 - mp*xp1
    Ypnz = mp*(xpnz) + bp
    Ypn = mp*(xpn) + bp
    var bool DemCheck = true
    var int DemCounter = 1
    var line Distal = na
    var line Proximal = na
    var line DLine50per = na
    var linefill fillline = na
    if Demand_OB_Condition
        Distal     := line.new(xd1, yd1, xd2  , yd1 , color = color.rgb(0, 0, 0 , 45) , style = line.style_dashed , width = 1)
        Proximal   := line.new(xp1, yp1, xd2 , yp1 , color = color.rgb(0, 0, 0 , 45) , style = line.style_dashed , width = 1)
        DLine50per := line.new(xp1, (yp1+yd1) / 2 , xd2 , (yp1+yd1) / 2  , color = color.rgb(0, 0, 0) , style = line.style_dotted , width = 1)
        fillline   := linefill.new(Distal ,Proximal ,color = DemBxColor )
    if ((low > YDp12) or xd1 == YDp12[1]) and (DemCheck == true)
        DemCounter := DemCounter + 1
        line.set_x2(Distal, bar_index + 1 )
        line.set_x2(Proximal,  bar_index + 1)
        line.set_x2(DLine50per,  bar_index + 1)
    if (low < YDd12) and (low[1] > YDd12)
        DemCounter := DemCounter
        DemCheck := false
    if Demand_OB_Condition
        DemCounter := 1
        DemCheck := true
    [xd1, xd2, yd1, yd2, xdnz, md, bd, Ydnz, xdn, Ydn,    xp1, xp2, yp1, yp2, xpnz, mp, bp, Ypnz, xpn, Ypn]


LinerFunctionSup(Xd1, Yd1, Xd2, Yd2 , Xp1, Yp1, Xp2, Yp2 , Xn) =>
    xd1 = Xd1
    xd2 = Xd2 
    yd1 = Yd1
    yd2 = Yd2
    xdn = Xn 
    xdnz = Xn 
    md =  (yd2 - yd1) / (xd2 - xd1)
    bd = yd1 - md*xd1
    Ydnz = md*(xdnz) + bd
    Ydn = md*(xdn) + bd
    xp1 = Xp1
    xp2 = Xp2 
    yp1 = Yp1
    yp2 = Yp2
    xpn = Xn 
    xpnz = Xn 
    mp =  (yp2 - yp1) / (xp2 - xp1)
    bp = yp1 - mp*xp1
    Ypnz = mp*(xpnz) + bp
    Ypn = mp*(xpn) + bp
    var bool SupCheck = true
    var int SupCounter = 1
    var line Distal = na
    var line Proximal = na
    var line  SLine50per = na
    var linefill fillline = na
    if Supply_OB_Condition
        Distal     := line.new(xd1, yd1, xdnz , yd1 , color = color.rgb(0, 0, 0, 45) , style = line.style_dashed , width = 1)
        Proximal   := line.new(xp1, yp1, xpnz  , yp1 , color = color.rgb(0, 0, 0 , 45) , style = line.style_dashed , width = 1)
        SLine50per := line.new(xp1, (yp1+yd1) / 2 , xpnz  , (yp1+yd1) / 2  , color = color.rgb(0, 0, 0) , style = line.style_dotted , width = 1)
        fillline   := linefill.new(Distal ,Proximal ,color = SupBxColor )
    if ((high < YSp12) or (xd1 == YSp12[1])) and (SupCheck == true)
        SupCounter := SupCounter + 1
        line.set_x2(Distal, bar_index + 1 )
        line.set_x2(Proximal,  bar_index + 1)
        line.set_x2(SLine50per,  bar_index + 1)
    if (high > YSd12) and (high[1] < YSd12)
        SupCounter := SupCounter
        SupCheck := false
    if Supply_OB_Condition
        SupCounter := 1
        SupCheck := true
    [xd1, xd2, yd1, yd2, xdnz, md, bd, Ydnz, xdn, Ydn ,   xp1, xp2, yp1, yp2, xpnz, mp, bp, Ypnz, xpn, Ypn]


[DDx1 , DDx2 , DDy1, DDy2, DDxz, DDm, DDb, DDyz, DDxn, DDyn,    DPx1 , DPx2 , DPy1, DPy2, DPxz, DPm, DPb, DPyz, DPxn, DPyn] = LinerFunctionDem(XDd1, YDd12, XDd2, YDd12,    XDp1, YDp12, XDp2, YDp12 , bar_index) 
[SDx1 , SDx2 , SDy1, SDy2, SDxz, SDm, SDb, SDyz, SDxn, SDyn,    SPx1 , SPx2 , SPy1, SPy2, SPxz, SPm, SPb, SPyz, SPxn, SPyn] = LinerFunctionSup(XSd1, YSd12, XSd2, YSd12 ,   XSp1, YSp12, XSp2, YSp12, bar_index) 


//=========================================================================
//                   HELPERS & ACTIVE SIDE TRACKING
//=========================================================================

f_labelSize(s) => s == 'tiny'  ? size.tiny  : s == 'small' ? size.small : s == 'normal' ? size.normal : size.large

// Short TF label : "3m", "15m", "1h", "1D"
f_tfShort(tf) =>
    s = timeframe.in_seconds(tf)
    out = s < 60 ? str.tostring(s) + "s" : s < 3600 ? str.tostring(s / 60) + "m" : s < 86400 ? str.tostring(s / 3600) + "h" : str.tostring(s / 86400) + "D"
    out

// Active side : 1 = demand most recent, -1 = supply most recent, 0 = none
var int active_side = 0
if Demand_OB_Condition
    active_side := 1
if Supply_OB_Condition
    active_side := -1


//=========================================================================
//                        MTF FIBONACCI LABELS
//=========================================================================
// For each enabled HTF we request its Major High/Low + side.
// Only LABELS are printed (format : "0.618 15m"), to the right of the chart.
// Nothing is drawn if no OB zone exists on that HTF (side == 0).
//=========================================================================

// Request per-HTF values (Major High/Low + active side)
[mtf1_Hi, mtf1_Lo, mtf1_side] = request.security(syminfo.tickerid, mtf1_tf, [High_Correct_f, Low_Correct_f, active_side], lookahead=barmerge.lookahead_off)
[mtf2_Hi, mtf2_Lo, mtf2_side] = request.security(syminfo.tickerid, mtf2_tf, [High_Correct_f, Low_Correct_f, active_side], lookahead=barmerge.lookahead_off)
[mtf3_Hi, mtf3_Lo, mtf3_side] = request.security(syminfo.tickerid, mtf3_tf, [High_Correct_f, Low_Correct_f, active_side], lookahead=barmerge.lookahead_off)

// ---- label storage per MTF slot (cleared & rebuilt on last bar only) ----
var label[] mtf1_labels = array.new_label()
var label[] mtf2_labels = array.new_label()
var label[] mtf3_labels = array.new_label()

f_clearArr(arr) =>
    if array.size(arr) > 0
        for lb in arr
            label.delete(lb)
        array.clear(arr)

// Build MTF fib labels (labels only; no lines).
// If side == 0 on this HTF -> no zone detected yet -> skip entirely.
f_buildMTFLabels(arr, enabled, tf_name, hi, lo, side, col_offset) =>
    f_clearArr(arr)
    if enabled and side != 0 and not na(hi) and not na(lo)
        // Same rule as current TF :
        //   demand (side=1)  : 0 = Low,  1 = High
        //   supply (side=-1) : 0 = High, 1 = Low
        p0 = side == 1 ? lo : hi
        p1 = side == 1 ? hi : lo
        rng = p1 - p0
        lsz = f_labelSize(mtf_label_size_s)
        tf_tag = f_tfShort(tf_name)
        levels      = array.from(0.0, 0.05, 0.13, 0.144, 0.233, 0.275, 0.31, 0.34, 0.382, 0.5, 0.55, 0.618, 0.786, 0.865, 0.895, 1.0, 1.1, 1.618)
        enabled_arr = array.from(en_0, en_005, en_013, en_0144, en_0233, en_0275, en_031, en_034, en_0382, en_05, en_055, en_0618, en_0786, en_0865, en_0895, en_1, en_11, en_1618)
        colors      = array.from(col_0, col_005, col_013, col_0144, col_0233, col_0275, col_031, col_034, col_0382, col_05, col_055, col_0618, col_0786, col_0865, col_0895, col_1, col_11, col_1618)
        x_pos = bar_index + mtf_label_offset + col_offset
        for i = 0 to 17
            if array.get(enabled_arr, i)
                lvl = array.get(levels, i)
                col = array.get(colors, i)
                p   = p0 + rng * lvl
                // Format demandé : "0.618 15m"
                txt = str.tostring(lvl) + " " + tf_tag
                lb  = label.new(x_pos, p, txt, style=label.style_label_left, color=color.new(col, 85), textcolor=col, size=lsz)
                array.push(arr, lb)

// Only draw once on the last confirmed bar to avoid spam / label limits
if barstate.islast
    f_buildMTFLabels(mtf1_labels, mtf1_en, mtf1_tf, mtf1_Hi, mtf1_Lo, mtf1_side, 0)
    f_buildMTFLabels(mtf2_labels, mtf2_en, mtf2_tf, mtf2_Hi, mtf2_Lo, mtf2_side, 10)
    f_buildMTFLabels(mtf3_labels, mtf3_en, mtf3_tf, mtf3_Hi, mtf3_Lo, mtf3_side, 20)


//=========================================================================
//                        ALERTS  (ORIGINAL, UNCHANGED)
//=========================================================================
var bool LongSignal  = false
var bool ShortSignal = false

var int LockAlertBull = 0
if low <= YDp12 and low[1] > YDp12 and LockAlertBull == 0  
    LockAlertBull := 1
    LongSignal := true
else
    LongSignal := false
if DPy1 != DPy1[1]
    LockAlertBull := 0

var int LockAlertBear = 0
if high >=  YSp12 and high[1] <  YSp12 and LockAlertBear == 0 
    LockAlertBear := 1
    ShortSignal := true
else
    ShortSignal := false
if SPy1 != SPy1[1]
    LockAlertBear := 0

Alert.AlertSender(LongSignal  , Alert_, AlertName, 'Bullish', 'Order Block Signal', 'Full' ,Frequncy, UTC, MoreInfo, MessageBull, open, high, low, close,0,0,0, YDd12 , YDp12)
Alert.AlertSender(ShortSignal , Alert_, AlertName, 'Bearish', 'Order Block Signal', 'Full' ,Frequncy, UTC, MoreInfo, MessageBear, open, high, low, close,0,0,0, YSd12 , YSp12)
````
