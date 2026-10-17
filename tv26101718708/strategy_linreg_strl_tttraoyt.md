# Strategy LinReg ST@RL

- url: https://www.tradingview.com/script/TtTraOYt/
- type: strategy
- pine_id: PUB;fa841053b6694eb798c4f4082856ec52
- version: 12.0

## Description

Strategy LinReg ST@RL 

Strategy LinReg ST@RL is a visual trend following indicator.
 It is compiled in PINE Script Version V5 language.

This indicator/strategy, based on Linear Regression Calculation, is intended to help beginners (and also the more experienced ones) to trade in the right direction of the market trend and test strategy. It allows you to avoid the mistakes of always trading against the trend. 

Strategy based on an original idea of @KivancOzbilgic (SuperTrend) and DevLucem (@LucemAnb) (Lin Reg ++)                                  
A  special credit goes to - KivancOzbilgic and @LucemAnb which inspired me a lot to improve this indicator/Strategy.

This indicator can be configured to your liking,according to your needs or your tastes. 

The indicator/Strategy works in multi time frame. 
The settings (length, offset, deviation, smoothing) are identical for all time frames if “Conf Auto” is not checked. 
In this case the default settings (time frame=H1 settings) apply for all time frames. 

The choice of source setting is common for all time frames. 

If “Auto Conf”  is checked,
 then the settings will be optimized for each selected time frame (1m-3m H2 H3 H1 H4 & Daily). Time frames, other than 1m-3m H2 H3 H1 H4 & Daily will be affected with the default settings corresponding to the H1 time frame and will therefore not be optimized! The default setting values of each time frame (1m-3m H2 H3 H1 H4 & Daily) can be configured differently and optimized by you. 

REVERSAL mode: Signal Buy=Sell and Signal Sell=Buy. 
This option may be better than the regular strategy. Default mode is Reversal option. 

Note that only for 1m (1 minute) Time frame, the option REVERSAL is opposite as default choice in configuration. (If reversal option is checked, then option for time frame 1m is not reversal!)

Trend indications (potential sell or buy areas) are displayed as a background color (bullish: green or bearish: red), assume that the market is moving in one direction. 
You can tune the input, style and visibility settings to match your own preferences or habits. 

Label Info (Simple or Full) gives trend info for each Exit (or current trade)

The choice of indicator colors is suitable for a graph with a "dark" theme, which you will probably need to modify for visual comfort, if you are using a "Light" mode or a custom mode. 

This script is an indicator that you can run on standard chart types. It also works on non-standard chart types but the results will be skewed and different. 

Non-standard charts are: 

• Heikin Ashi (HA) 
• Renko 
• Kagi 
• Point & Figure 
• Range 

As a reminder: No indicator is capable of providing accurate signals 100% of the time. Every now and then, even the best will fail, leaving you with a losing deal. Whichever indicator you base yourself on, remember to follow the basic rules of risk management and capital allocation. 

BINANCE:BTCUSDT 


! Français ! 
Strategy LinReg ST@RL 

Stratégie LinReg ST@RL est un indicateur visuel de suivi de tendance.
Il est compilé en langage PINE Script Version V5.

Stratégie basée sur une idée originale de @KivancOzbilgic (SuperTrend) et DevLucem (@LucemAnb) (Lin Reg ++) Un crédit spécial va à - KivancOzbilgic et @LucemAnb qui m'ont beaucoup inspiré pour améliorer cet indicateur/stratégie.

Cet indicateur/strategie, basé sur le calcul de régression linéaire, est destiné à aider les débutants (et aussi les plus expérimentés) à trader dans le bon sens de la tendance du marché et à tester la stratégie. Cela vous permet d'éviter les erreurs de toujours négocier à contre-courant. 

Cet indicateur peut être configuré à votre guise, selon vos besoins ou vos goûts. 

L'indicateur/Stratégie fonctionne sur plusieurs bases de temps.
 Les réglages (longueur, décalage, déviation, lissage) sont identiques pour toutes les bases de temps si 
« Conf Auto » n'est pas coché. Dans ce cas, les paramètres par défaut (intervalle de temps=paramètres H1) s'appliquent à toutes les bases de temps. 

Le choix du réglage de la source est commun à toutes les bases de temps.

 Si "Auto Conf" est coché, alors les paramètres seront optimisés pour chaque base de temps sélectionnée (1m-3m H2 H3 H1 H4 & Daily). Les bases de temps, autres que 1m-3m H2 H3 H1 H4 & Daily seront affectées par les paramètres par défaut correspondant à la base de temps H1 et ne seront donc pas optimisées ! Les valeurs de réglage par défaut de chaque période (1m-3m H2 H3 H1 H4 & Daily) peuvent être configurées différemment et optimisées par vous. 

Mode REVERSAL : Signal Achat=Vente et Signal Vente=Achat. Cette option peut être meilleure que la stratégie habituelle. Le mode par défaut est l'option REVERSAL. 

Notez que seulement pour la base de temps de 1m (1 minute), l'option REVERSAL est l’opposée du choix par défaut dans la configuration. (Si l'option REVERSAL est cochée, alors l'option pour la base de temps 1 m n'est pas  REVERSAL !) 

Les indications de tendance (zones potentielles de vente ou d'achat) sont affichées en couleur de fond (haussier : vert ou baissier : rouge), supposons que le marché évolue dans une direction. Vous pouvez ajuster les paramètres d'entrée, de style et de visibilité en fonction de vos propres préférences ou habitudes. 

Les informations sur l'étiquette (simples ou complètes) donnent des informations sur de chaque clôture (ou position en cours) 

Le choix des couleurs des indicateurs est adapté à un graphique avec un thème "sombre", qu'il vous faudra probablement modifier pour le confort visuel, si vous utilisez un mode "Clair" ou un mode personnalisé. 

Ce script est un indicateur que vous pouvez exécuter sur des types de graphiques standard. Cela fonctionne également sur les types de graphiques non standard, mais les résultats seront faussés et différents.

 Les graphiques non standard sont : 

• Heikin Ashi (HA) 
• Renko 
• Kagi 
• Point & Figure 
• Range 

Pour rappel : Aucun indicateur n'est capable de fournir des signaux précis 100% du temps. De temps en temps, même les meilleurs échoueront, vous laissant avec une affaire perdante. Quel que soit l'indicateur sur lequel vous vous basez, rappelez-vous de suivre les règles de base de la gestion des risques et de l'allocation du capital.

## Source Code

````pine
// This Source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RegisL76
// strategy based on an original idea of @KivancOzbilgic (SuperTrend) and DevLucem (@LucemAnb) (Lin Reg ++)                                  //
// TradingView version : a special credit goes to - KivancOzbilgic and @LucemAnb which inspired me a lot to improve this indicator/Strategy. //

// ******************** //
// © RegisL76 //
// V 
// ******************** //
// Strategy LinReg ST V1
// V1.0 publiée 27/03/2022 (v845)
// V2.0 publiée 03/04/2022 (v921)
// V3.0 publiée 06/04/2022 (v927)
// V4.0 publiée 04/05/2022 (v938)
// V5.0 publiée 20/04/2023 (v1574)
// V6.0 publiée 28/06/2023 (v1780)

// Strategy LinReg ST V2@RL
// V7.0 publiée 18/02/2024 (v40)
// V8.0 publiée 20/02/2024 (v43)
// V9.0 publiée 06/07/2024 (v170)
// **************************************************************************************************
// 
// **************************************************************************************************

// TradingView Pine V5 //
// @version=5
// TradingView Pine V5 // 

 
// *********************************************************************************************************************************************************************************************************** //
// ********************************************* Parametres Par Defaut Optimisés Pour BTC/USDT Perp Binance TF= 1m 3m 5m 15m 30m H1 H2 H3 H4 Daily Weekly  *************************************************** //
// *********************************************************************************************************************************************************************************************************** //
strategy('Strategy LinReg ST V2@RL',shorttitle='LinRegST-V2@RL', overlay=true, margin_long=30,margin_short=30,commission_value=0.05,
 default_qty_value=65,initial_capital=2000,default_qty_type= strategy.percent_of_equity, currency=currency.USD,pyramiding=0,
 calc_on_order_fills=false,calc_on_every_tick=false,process_orders_on_close=false,max_labels_count=500,max_lines_count=500,max_bars_back=5000)

// ****************************************************************************************************************************************** // 
//                                       Parametres par defaut pour BTC/USDT Perp Binance TF=H1                                               //
// *************************************************** LINEAR REGRESSION INPUTS ************************************************************* //
THANKS          = input.string('THANKS i -->>', tooltip=
 'Have good winning trades and enjoy !'
 ,                                                                                                               confirm=true, group='CONFIRMATION NEEDED')

CONFIG = input.string('CONFIG-->>',tooltip='MEMO -->>'
 +'\nDef BTCUSDT Perp : Low -  ??  -  ?? - ?? -  ?? - REGULAR : ALL TF !'
 +'\n---------------------------------------------------------------'
 +'\n1m  BTCUSDT Perp : Low - 232 - 2 - 3.3  - 9 - REGULAR' 
 +'\n3m  BTCUSDT Perp : Low -  90 - 4 - 3.3 - 12 - REGULAR'
 +'\n5m  BTCUSDT Perp : Low -  87 - 0 - 3.3 - 12 - REGULAR'
 +'\n15m BTCUSDT Perp : Low -  81 - 0 - 3.3 - 12 - REGULAR'
 +'\n30m BTCUSDT Perp : Low -  50 - 0 - 3.3 - 10 - REGULAR'
 +'\nH1  BTCUSDT Perp : Low -  48 - 0 - 3.3  - 9 - REGULAR' 
 +'\nH2  BTCUSDT Perp : Low -  75 - 7 - 2.2  - 3 - REGULAR'
 +'\nH3  BTCUSDT Perp : Low -  64 - 3 - 1.9  - 4 - REGULAR'
 +'\nH4  BTCUSDT Perp : Low -  23 - 0 - 1.6  - 4 - REGULAR'
 +'\nD   BTCUSDT Perp : Low -  52 - 2 - 1.7  - 9 - REGULAR'
 +'\nW   BTCUSDT Perp : Low -  14 - 0 - 0.7  - 5 - REGULAR' 
 +'\nONLY FOR : '
 +'\n1m 3m 5m 15m 30m H2 H3 H4 DAILY WEEKLY'
 +'\nIF "CONF AUTO"',                                                                                             confirm=true, group='CONFIRMATION NEEDED')

NOTA            = input.string('READ i -->>',tooltip='Inputs Marked With * Influence The Result Of The Stategy !',confirm=true, group='CONFIRMATION NEEDED')

// *********************************************************************************************************************** //
buy_only        = input       (false, 'BUY ONLY*',                                                      tooltip ='[Buy only] & [Sell only] both checked or both unchecked = [BUY + SELL]'
 ,                                                                                                      group='For All TF',                                          inline='ALLTF')
 
sell_only       = input       (false, 'SELL ONLY*',                                                     tooltip ='[Buy only] & [Sell only] both checked or both unchecked = [BUY + SELL]'
 ,                                                                                                      group='For All TF',                                          inline='ALLTF')

// **************************************************** STOP LOSS Inputs ************************************************* //
sl1             = input.float (1.1, 'STOP LOSS %*'                 ,  minval=0.2,maxval=10,step=0.05
 ,                                                                                                      tooltip='Stop Loss : 0 to 10 % of Position Size, 100% with X10 [Default Value For All TimeFrame] (Default=11%)'
 ,                                                                                                      group='For All TF')
 
slX10           = input.bool  (true,'STOP LOSS X 10*',                                                  tooltip='Stop Loss X10 Multiplier'
 ,                                                                                                      group='For All TF',                                          inline='SL')
 
no_sl           = input.bool  (false,'DISABLE STOP LOSS*',                                              tooltip='Checked=Disable Exit by Stop Loss'
 ,                                                                                                      group='For All TF')

// **************************************************** TAKE PROFIT Inputs *********************************************** // 
tp1             = input.float (4.35, 'TAKE PROFIT %*' ,               minval=0.2,maxval=10,step=0.05
 ,                                                                                                      tooltip='Take Profit : 0 to 10 % of Position Size, 100% with X10 [Default Value For All TimeFrame] (Default=43.5%)'
 ,                                                                                                      group='For All TF')
 
tpX10           = input.bool  (true,'TAKE PROFIT X 10*',                                                tooltip='Take Profit X10 Multiplier'
 ,                                                                                                      group='For All TF',                                          inline='TP')
 
no_tp           = input.bool  (true ,'DISABLE TAKE PROFIT*',                                            tooltip='Checked=Disable Exit by Take Profit'
 ,                                                                                                      group='For All TF')
// **************************************************** DISPLAY Inputs *************************************************** //
line_thick      = input.int   (2,     'Line LR Thickness',                    minval=1, maxval=4,       group='COMMON INPUTS DISPLAY',                               inline='LR')
signals         = input.string('All', 'Line LR Signals Display', options=['All','Last 500 Bars'],       group='COMMON INPUTS DISPLAY',                               inline='LR')

color_up        = input.color (color.new(#82fc00, 0),'Up Color'  ,                                    group='COMMON INPUTS DISPLAY',                               inline='COLOR')
color_down      = input.color (color.new(#ff0000, 0),'Down Color',                                    group='COMMON INPUTS DISPLAY',                               inline='COLOR')

y_Pos_factor    = input.float (2.0,   'Label Y Position Factor',      minval=0.0,maxval=20.0,step=0.25, group='COMMON INPUTS DISPLAY')

show_trade_info = input       (true,  'Show Trade Infos',                                           
 tooltip='Display Or Not The Trade Infos Label',                                                        group='COMMON INPUTS DISPLAY')

show_full_info = input        (false, 'Show Full Infos Label',                                           
 tooltip='Display Full Or Simple Trade Infos Label',                                                    group='COMMON INPUTS DISPLAY')
 
ShowMarginTable= input       (true, 'Show Margin Table',                                           
 tooltip='Display Margin Call Infos',                                                                   group='COMMON INPUTS DISPLAY')

MarginTablePos = input.string(position.top_right,'Margin Table Position', 
                                                             [position.top_right,position.top_center,position.top_left],   group='COMMON INPUTS DISPLAY')

ShowLegendTable = input.bool  (true, 'Show Legend ', tooltip='Show Legend of Label',                     group='COMMON INPUTS DISPLAY')
ShowLiquidPrice = input.bool  (true, 'Show Liquidation Price ', tooltip='Show Liquidation Price',        group='COMMON INPUTS DISPLAY')
barscolors      = input       (true,  'Trend Bars Colors',                                            
 tooltip='Displays Or Not The Color Of The Candles According To The Trend Of The Strategy, Instead Of The Standard Colors'
 ,                                                                                                       group='COMMON INPUTS DISPLAY',                              inline='INFO')

ExtOffset  = input.int   (7 ,title='offset Extend Trend lines',minval = 2,maxval=100,step=1,tooltip ='Default=7')
 
trans_Col_bg    = input.float (88,   'Trend Background Transparency',  minval=86,  maxval=90,  step=1,   group='COMMON INPUTS DISPLAY')
show_sl_line    = input.bool  (true, 'Show SL Line',                                                     group='COMMON INPUTS DISPLAY',                              inline='SL-TP')
show_tp_line    = input.bool  (true, 'Show TP Line', tooltip='Show TP / SL Lines & Backgrounds',         group='COMMON INPUTS DISPLAY',                              inline='SL-TP')

showIntermedSignal= input.bool(true, 'Show intermediate Signals', tooltip='Show intermediate Signals',   group='ALERT MESSAGES')
showBuySignal     = input.bool(true, 'Show Buy Signals',          tooltip='Show Buy Signals',            group='ALERT MESSAGES')
showSellSignal    = input.bool(true, 'Show Sell Signals',         tooltip='Show Sell Signals',           group='ALERT MESSAGES')
showTpSignal      = input.bool(true, 'Show Exit TP Signals',      tooltip='Show Exit TP Signals',        group='ALERT MESSAGES')
showSlSignal      = input.bool(true, 'Show Exit SL Signals',      tooltip='Show Exit SL Signals',        group='ALERT MESSAGES')
showExitSignal    = input.bool(true, 'Show Exit Signals',         tooltip='Show Exit Signals',           group='ALERT MESSAGES')

source          = input       (low,   'COMMON SOURCE*',tooltip='(Default is "LOW")',                     group='DEFAULT FOR ALL TF')
conf_auto       = input.bool  (true,'CONF AUTO 1m 3m 5m 15m 30m H1 H2 H3 H4 DAILY WEEKLY*',
 tooltip='CONF AUTO Only For Timeframe 1m 3m 5m 15m 30m H1 H2 H3 H4 DAILY WEEKLY, ELSE ALL OTHER TF = DEF CONF !', 
                                                                                           confirm=true, group='DEFAULT FOR ALL TF')

// ------------------------------------------------------------------------------------------------- //
// Parametres defaut pour ALL Time Frame = DEFAUT Futures BTC/USDT Perp : Low - ?? - ?? - ?? - ?? - REGULAR // Default //
// ------------------------------------------------------------------------------------------------- //
length_Def         = input.int      (232,   'DEFAULT LENGTH* --',        minval=1,                  group='COMMON DEFAULT CONFIG FOR ALL TF, EXCEPT IF CONF AUTO',   inline='DEFAULT CONF')
offset_Def         = input.int      (0,     'DEFAULT OFFSET* --',        minval=0,                  group='COMMON DEFAULT CONFIG FOR ALL TF, EXCEPT IF CONF AUTO',   inline='DEFAULT CONF')
dev_Def            = input.float    (1,     'DEFAULT DEVIATION*',        minval=0.1,      step=0.1, group='COMMON DEFAULT CONFIG FOR ALL TF, EXCEPT IF CONF AUTO',   inline='DEFAULT CONF') 
smoothing_Def      = input.int      (1,     'DEFAULT SMOOTHING*',        minval=1,                  group='COMMON DEFAULT CONFIG FOR ALL TF, EXCEPT IF CONF AUTO',   inline='DEFAULT CONF')
reversal_Def       = input          (false, 'DEFAULT REVERSAL* ',                                   group='COMMON DEFAULT CONFIG FOR ALL TF, EXCEPT IF CONF AUTO',   inline='DEFAULT CONF',                                                    
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// ------------------------------------------------------------------------------------------------- //


// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = 1m Futures BTC/USDT Perp : Low  - 115 - 3 - 3.3 - 1 - REGULAR - CONF AUTO 1m ! -    //
// *********************************************************************************************************************** //
length_1m       = input.int      (232,    'LENGTH 1m* --',                  minval=1,                  group='CONFIG ONLY FOR 1m, IF CONF AUTO',                       inline='1m')
offset_1m       = input.int      (2,      'OFFSET 1m* -----' ,              minval=0,                  group='CONFIG ONLY FOR 1m, IF CONF AUTO',                       inline='1m')
dev_1m          = input.float    (3.3,    'DEVIATION 1m*',                  minval=0.1,      step=0.1, group='CONFIG ONLY FOR 1m, IF CONF AUTO',                       inline='1m') 
smoothing_1m    = input.int      (9,      'SMOOTHING 1m*',                  minval=1,                  group='CONFIG ONLY FOR 1m, IF CONF AUTO',                       inline='1m')
reversal_1m     = input          (false,  'REVERSAL 1m*',                                              group='CONFIG ONLY FOR 1m, IF CONF AUTO',                       inline='1m',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** // 
// Parametres de base pour Time Frame = 3m Futures BTC/USDT Perp : Low  - 142 - 0 - 3.9 - 1 - REGULAR - CONF AUTO 3m ! -    //
// *********************************************************************************************************************** //
length_3m       = input.int      (90,   'LENGTH 3m* --',                  minval=1,                  group='CONFIG ONLY FOR 3m, IF CONF AUTO',                       inline='3m')
offset_3m       = input.int      (4,    'OFFSET 3m* -----' ,              minval=0,                  group='CONFIG ONLY FOR 3m, IF CONF AUTO',                       inline='3m')
dev_3m          = input.float    (3.3,  'DEVIATION 3m*',                  minval=0.1,      step=0.1, group='CONFIG ONLY FOR 3m, IF CONF AUTO',                       inline='3m') 
smoothing_3m    = input.int      (12,   'SMOOTHING 3m*',                  minval=1,                  group='CONFIG ONLY FOR 3m, IF CONF AUTO',                       inline='3m')
reversal_3m     = input          (false,'REVERSAL 3m*',                                              group='CONFIG ONLY FOR 3m, IF CONF AUTO',                       inline='3m',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = 5m Futures BTC/USDT Perp : Low  - 169 - 1 - 2.3 - 1 - REGULAR - CONF AUTO 5m ! -    //
// *********************************************************************************************************************** //
length_5m       = input.int      (87,   'LENGTH 5m* --',               minval=1,                  group='CONFIG ONLY FOR 5m, IF CONF AUTO',                          inline='5m')
offset_5m       = input.int      (0,    'OFFSET 5m* -----' ,           minval=0,                  group='CONFIG ONLY FOR 5m, IF CONF AUTO',                          inline='5m')
dev_5m          = input.float    (3.3,  'DEVIATION 5m*',               minval=0.1,      step=0.1, group='CONFIG ONLY FOR 5m, IF CONF AUTO',                          inline='5m')
smoothing_5m    = input.int      (12,   'SMOOTHING 5m*',               minval=1,                  group='CONFIG ONLY FOR 5m, IF CONF AUTO',                          inline='5m')
reversal_5m     = input          (false,'REVERSAL 5m*',                                           group='CONFIG ONLY FOR 5m, IF CONF AUTO',                          inline='5m',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = 15m Futures BTC/USDT Perp : Low  - 167 - 0 - 0.6 - 6 - REGULAR - CONF AUTO 15m ! -    //
// *********************************************************************************************************************** //
length_15m       = input.int      (81,   'LENGTH 15m* --',              minval=1,                  group='CONFIG ONLY FOR 15m, IF CONF AUTO',                        inline='15m')
offset_15m       = input.int      (0,    'OFFSET 15m* -----' ,          minval=0,                  group='CONFIG ONLY FOR 15m, IF CONF AUTO',                        inline='15m')
dev_15m          = input.float    (3.3,  'DEVIATION 15m*',              minval=0.1,      step=0.1, group='CONFIG ONLY FOR 15m, IF CONF AUTO',                        inline='15m')
smoothing_15m    = input.int      (12,   'SMOOTHING 15m*',              minval=1,                  group='CONFIG ONLY FOR 15m, IF CONF AUTO',                        inline='15m')
reversal_15m     = input          (false,'REVERSAL 15m*',                                          group='CONFIG ONLY FOR 15m, IF CONF AUTO',                        inline='15m',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = 30m Futures BTC/USDT Perp : Low  - 115 - 2 - 0.9 - 7 - REGULAR - CONF AUTO 30m ! -    //
// *********************************************************************************************************************** //
length_30m       = input.int      (50,   'LENGTH 30m* --',              minval=1,                  group='CONFIG ONLY FOR 30m, IF CONF AUTO',                        inline='30m')
offset_30m       = input.int      (0,    'OFFSET 30m* -----' ,          minval=0,                  group='CONFIG ONLY FOR 30m, IF CONF AUTO',                        inline='30m')
dev_30m          = input.float    (3.3,  'DEVIATION 30m*',              minval=0.1,      step=0.1, group='CONFIG ONLY FOR 30m, IF CONF AUTO',                        inline='30m')
smoothing_30m    = input.int      (10,   'SMOOTHING 30m*',              minval=1,                  group='CONFIG ONLY FOR 30m, IF CONF AUTO',                        inline='30m')
reversal_30m     = input          (false,'REVERSAL 30m*',                                          group='CONFIG ONLY FOR 30m, IF CONF AUTO',                        inline='30m',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
 // ------------------------------------------------------------------------------------------------- //
// Parametres de base pour Time Frame = H1 Futures BTC/USDT Perp : Low - 196 - 3 - 2.2 - 1 - REGULAR - CONF AUTO H1 ! -    //
// ------------------------------------------------------------------------------------------------- //
length_H1          = input.int      (48,  'LENGTH H1* --',              minval=1,                  group='CONFIG ONLY FOR H1, IF CONF AUTO',                         inline='H1')
offset_H1          = input.int      (0,   'OFFSET H1* -----',           minval=0,                  group='CONFIG ONLY FOR H1, IF CONF AUTO',                         inline='H1')
dev_H1             = input.float    (3.3, 'DEVIATION H1*',              minval=0.1,      step=0.1, group='CONFIG ONLY FOR H1, IF CONF AUTO',                         inline='H1')
smoothing_H1       = input.int      (9,   'SMOOTHING H1*',              minval=1,                  group='CONFIG ONLY FOR H1, IF CONF AUTO',                         inline='H1')
reversal_H1        = input          (false,'REVERSAL H1*',                                         group='CONFIG ONLY FOR H1, IF CONF AUTO',                         inline='H1',
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = H2 Futures BTC/USDT Perp : Low - 70 - 7 - 2.2 - 3 - REGULAR - CONF AUTO H2 ! -    //
// *********************************************************************************************************************** //
length_H2       = input.int      (75,     'LENGTH H2* --',               minval=1,                  group='CONFIG ONLY FOR H2, IF CONF AUTO',                        inline='H2')
offset_H2       = input.int      (7,      'OFFSET H2* -----' ,           minval=0,                  group='CONFIG ONLY FOR H2, IF CONF AUTO',                        inline='H2')
dev_H2          = input.float    (2.2,    'DEVIATION H2*',               minval=0.1,      step=0.1, group='CONFIG ONLY FOR H2, IF CONF AUTO',                        inline='H2') 
smoothing_H2    = input.int      (3,      'SMOOTHING H2*',               minval=1,                  group='CONFIG ONLY FOR H2, IF CONF AUTO',                        inline='H2')
reversal_H2     = input          (false,  'REVERSAL _H2*',                                          group='CONFIG ONLY FOR H2, IF CONF AUTO',                        inline='H2',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = H3 Futures BTC/USDT Perp : Low - 64 - 3 - 1.9 - 4 - REGULAR - CONF AUTO H3 ! -    //
// *********************************************************************************************************************** //
length_H3       = input.int      (64,     'LENGTH H3* --',               minval=1,                  group='CONFIG ONLY FOR H3, IF CONF AUTO',                        inline='H3')
offset_H3       = input.int      (3,      'OFFSET H3* -----' ,           minval=0,                  group='CONFIG ONLY FOR H3, IF CONF AUTO',                        inline='H3')
dev_H3          = input.float    (1.9,    'DEVIATION H3*',               minval=0.1,      step=0.1, group='CONFIG ONLY FOR H3, IF CONF AUTO',                        inline='H3') 
smoothing_H3    = input.int      (4,      'SMOOTHING H3*',               minval=1,                  group='CONFIG ONLY FOR H3, IF CONF AUTO',                        inline='H3')
reversal_H3     = input          (false,  'REVERSAL H3*',                                           group='CONFIG ONLY FOR H3, IF CONF AUTO',                        inline='H2',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = H4 Futures BTC/USDT Perp : Low - 23 - 2 - 1.6 - 4 - REGULAR - CONF AUTO H4 ! -    //
// *********************************************************************************************************************** //
length_H4       = input.int      (23,     'LENGTH H4* --',               minval=1,                  group='CONFIG ONLY FOR H4, IF CONF AUTO',                        inline='H4')
offset_H4       = input.int      (0,      'OFFSET H4* -----' ,           minval=0,                  group='CONFIG ONLY FOR H4, IF CONF AUTO',                        inline='H4')
dev_H4          = input.float    (1.6,    'DEVIATION H4*',               minval=0.1,      step=0.1, group='CONFIG ONLY FOR H4, IF CONF AUTO',                        inline='H4') 
smoothing_H4    = input.int      (4,      'SMOOTHING H4*',               minval=1,                  group='CONFIG ONLY FOR H4, IF CONF AUTO',                        inline='H4')
reversal_H4     = input          (false,  'REVERSAL H4*',                                           group='CONFIG ONLY FOR H4, IF CONF AUTO',                        inline='H4',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = D  Futures BTC/USDT Perp : Low - 52 - 2 - 1.7 - 9 - REGULAR - CONF AUTO D  ! -    //
// *********************************************************************************************************************** //
length_D       = input.int      (52,      'LENGTH Daily* --',             minval=1,                 group='CONFIG ONLY FOR DAILY, IF CONF AUTO',                     inline='DAILY')
offset_D       = input.int      (2,       'OFFSET Daily* -----' ,         minval=0,                 group='CONFIG ONLY FOR DAILY, IF CONF AUTO',                     inline='DAILY')
dev_D          = input.float    (1.7,     'DEVIATION Daily*',             minval=0.1,      step=0.1,group='CONFIG ONLY FOR DAILY, IF CONF AUTO',                     inline='DAILY') 
smoothing_D    = input.int      (9,       'SMOOTHING Daily*',             minval=1,                 group='CONFIG ONLY FOR DAILY, IF CONF AUTO',                     inline='DAILY')
reversal_D     = input          (false,   'REVERSAL Daily*',                                        group='CONFIG ONLY FOR DAILY, IF CONF AUTO',                     inline='DAILY',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// *********************************************************************************************************************** //
// Parametres de base pour Time Frame = W  Futures BTC/USDT Perp : Low - 14 - 0 - 0.7 - 5 - REGULAR - CONF AUTO W  ! -    //
// *********************************************************************************************************************** //
length_W       = input.int      (16,      'LENGTH Weekly* --',            minval=1,                 group='CONFIG ONLY FOR WEEKLY, IF CONF AUTO',                    inline='WEEKLY')
offset_W       = input.int      (1,       'OFFSET Weekly* -----' ,        minval=0,                 group='CONFIG ONLY FOR WEEKLY, IF CONF AUTO',                    inline='WEEKLY')
dev_W          = input.float    (0.7,     'DEVIATION Weekly*',            minval=0.1,     step=0.1, group='CONFIG ONLY FOR WEEKLY, IF CONF AUTO',                    inline='WEEKLY') 
smoothing_W    = input.int      (6,       'SMOOTHING Weekly*',            minval=1,                 group='CONFIG ONLY FOR WEEKLY, IF CONF AUTO',                    inline='WEEKLY')
reversal_W     = input          (false,   'REVERSAL Weekly*',                                       group='CONFIG ONLY FOR WEEKLY, IF CONF AUTO',                    inline='WEEKLY',                              
 tooltip='Reversal = Reversal Strategy Method (Buy = Sell & Sell = Buy) ! May Be Better (Or Not !) Than The Regular Strategy !')
// ********************************************************************************************************************************************* //

// Default Conf //
smoothing=smoothing_Def
loop=length_Def
dev=dev_Def
conf='[CONF DEF]' // Default Conf //
reversal=reversal_Def

if (timeframe.period =='1') and conf_auto
    smoothing:=smoothing_1m
    loop:=length_1m
    dev:=dev_1m
    conf:='[CONF 1m]'
    reversal:=reversal_1m

if (timeframe.period =='3') and conf_auto
    smoothing:=smoothing_3m
    loop:=length_3m
    dev:=dev_3m
    conf:='[CONF 3m]'
    reversal:=reversal_3m

if (timeframe.period =='5') and conf_auto
    smoothing:=smoothing_5m
    loop:=length_5m
    dev:=dev_5m
    conf:='[CONF 5m]'
    reversal:=reversal_5m

if (timeframe.period =='15') and conf_auto
    smoothing:=smoothing_15m
    loop:=length_15m
    dev:=dev_15m
    conf:='[CONF 15m]'
    reversal:=reversal_15m

if (timeframe.period =='30') and conf_auto
    smoothing:=smoothing_30m
    loop:=length_30m
    dev:=dev_30m
    conf:='[CONF 30m]'
    reversal:=reversal_30m

if timeframe.period =='60' and conf_auto    
    smoothing:=smoothing_H1
    loop:=length_H1
    dev:=dev_H1
    conf:='[CONF H1]'
    reversal:=reversal_H1

if timeframe.period =='120' and conf_auto    
    smoothing:=smoothing_H2
    loop:=length_H2
    dev:=dev_H2
    conf:='[CONF H2]'
    reversal:=reversal_H2

if timeframe.period =='180' and conf_auto    
    smoothing:=smoothing_H3
    loop:=length_H3
    dev:=dev_H3
    conf:='[CONF H3]'
    reversal:=reversal_H3

if timeframe.period =='240' and conf_auto    
    smoothing:=smoothing_H4
    loop:=length_H4
    dev:=dev_H4
    conf:='[CONF H4]'
    reversal:=reversal_H4

if timeframe.period =='D' and conf_auto    
    smoothing:=smoothing_D
    loop:=length_D
    dev:=dev_D
    conf:='[CONF D]'
    reversal:=reversal_D

if timeframe.period =='W' and conf_auto    
    smoothing:=smoothing_W
    loop:=length_W
    dev:=dev_W
    conf:='[CONF W]'
    reversal:=reversal_W

data(x) =>
    ta.sma(request.security(syminfo.tickerid,timeframe.period, x), smoothing)
    
// ********************************************************************************************************************************************* //
// Default Conf //
linreg   = data(ta.linreg(source, length_Def, offset_Def))
linreg_p = data(ta.linreg(source, length_Def, offset_Def + 1))

if (timeframe.period =='1') and conf_auto
    linreg   := data(ta.linreg(source, length_1m, offset_1m))
    linreg_p := data(ta.linreg(source, length_1m, offset_1m + 1))

if (timeframe.period =='3') and conf_auto
    linreg   := data(ta.linreg(source, length_3m, offset_3m))
    linreg_p := data(ta.linreg(source, length_3m, offset_3m + 1))

if timeframe.period =='5' and conf_auto
    linreg   := data(ta.linreg(source, length_5m, offset_5m))
    linreg_p := data(ta.linreg(source, length_5m, offset_5m + 1))

if timeframe.period =='15' and conf_auto
    linreg   := data(ta.linreg(source, length_15m, offset_15m))
    linreg_p := data(ta.linreg(source, length_15m, offset_15m + 1))

if timeframe.period =='30' and conf_auto
    linreg   := data(ta.linreg(source, length_30m, offset_30m))
    linreg_p := data(ta.linreg(source, length_30m, offset_30m + 1))

if timeframe.period =='60' and conf_auto
    linreg   := data(ta.linreg(source, length_H1, offset_H1))
    linreg_p := data(ta.linreg(source, length_H1, offset_H1 + 1))

if timeframe.period =='120' and conf_auto
    linreg   := data(ta.linreg(source, length_H2, offset_H2))
    linreg_p := data(ta.linreg(source, length_H2, offset_H2 + 1))

if timeframe.period =='180' and conf_auto
    linreg   := data(ta.linreg(source, length_H3, offset_H3))
    linreg_p := data(ta.linreg(source, length_H3, offset_H3 + 1))

if timeframe.period =='240' and conf_auto
    linreg   := data(ta.linreg(source, length_H4, offset_H4))
    linreg_p := data(ta.linreg(source, length_H4, offset_H4 + 1))

if timeframe.period =='D' and conf_auto
    linreg   := data(ta.linreg(source, length_D, offset_D))
    linreg_p := data(ta.linreg(source, length_D, offset_D + 1))

if timeframe.period =='W' and conf_auto
    linreg   := data(ta.linreg(source, length_W, offset_W))
    linreg_p := data(ta.linreg(source, length_W, offset_W + 1))
    
// ********************************************************************************************************************************************* //
x = bar_index 
slope = linreg - linreg_p
intercept = linreg - x * slope
deviationSum = 0.0

for i = 0 to loop - 1 by 1
    deviationSum += math.pow(source[i] - (slope * (x - i) + intercept), 2)
    deviationSum

// Default Conf //
deviation = math.sqrt(deviationSum / length_Def)
x1 = x - length_Def
y1 = slope * (x - length_Def) + intercept
lengthHist=length_Def

if (timeframe.period =='1') and conf_auto
    deviation := math.sqrt(deviationSum / length_1m)
    x1 := x - length_1m
    y1 := slope * (x - length_1m) + intercept
    lengthHist:=length_1m

if (timeframe.period =='3') and conf_auto
    deviation := math.sqrt(deviationSum / length_3m)
    x1 := x - length_3m
    y1 := slope * (x - length_3m) + intercept
    lengthHist:=length_3m

if (timeframe.period =='5') and conf_auto
    deviation := math.sqrt(deviationSum / length_5m)
    x1 := x - length_5m
    y1 := slope * (x - length_5m) + intercept
    lengthHist:=length_5m

if (timeframe.period =='15') and conf_auto
    deviation := math.sqrt(deviationSum / length_15m)
    x1 := x - length_15m
    y1 := slope * (x - length_15m) + intercept
    lengthHist:=length_15m

if (timeframe.period =='30') and conf_auto
    deviation := math.sqrt(deviationSum / length_30m)
    x1 := x - length_30m
    y1 := slope * (x - length_30m) + intercept
    lengthHist:=length_30m

if timeframe.period =='60' and conf_auto
    deviation := math.sqrt(deviationSum / length_H1)
    x1 := x - length_H1
    y1 := slope * (x - length_H1) + intercept
    lengthHist:=length_H1

if timeframe.period =='120' and conf_auto
    deviation := math.sqrt(deviationSum / length_H2)
    x1 := x - length_H2
    y1 := slope * (x - length_H2) + intercept
    lengthHist:=length_H2

if timeframe.period =='180' and conf_auto
    deviation := math.sqrt(deviationSum / length_H3)
    x1 := x - length_H3
    y1 := slope * (x - length_H3) + intercept
    lengthHist:=length_H3

if timeframe.period =='240' and conf_auto
    deviation := math.sqrt(deviationSum / length_H4)
    x1 := x - length_H4
    y1 := slope * (x - length_H4) + intercept
    lengthHist:=length_H4

if timeframe.period =='D' and conf_auto
    deviation := math.sqrt(deviationSum / length_D)
    x1 := x - length_D
    y1 := slope * (x - length_D) + intercept
    lengthHist:=length_D

if timeframe.period =='W' and conf_auto
    deviation := math.sqrt(deviationSum / length_W)
    x1 := x - length_W
    y1 := slope * (x - length_W) + intercept
    lengthHist:=length_W

x2 = x
y2 = linreg

// ********************************************************************************************************************************************* //
b  = line(na) 
dp = line(na)
dm = line(na)

bHist  = line(na)
dpHist = line(na)
dmHist = line(na)

bHist1 = line(na)
dpHist1= line(na)
dmHist1= line(na)

b := line.new(x1, y1, x2, y2, xloc.bar_index, extend.right, color.white,style=line.style_dashed, width=line_thick)
line.delete(b[1])

bHist := line.new(x1[lengthHist], y1[lengthHist], x2[lengthHist], y2[lengthHist], xloc.bar_index, extend.none,
 color.white,style=line.style_dashed, width=line_thick)
line.delete(bHist[1])

bHist1 := line.new(x1[lengthHist*2], y1[lengthHist*2], x2[lengthHist*2], y2[lengthHist*2], xloc.bar_index, extend.none,
 color.white,style=line.style_dashed, width=line_thick)
line.delete(bHist1[1])

dp := line.new(x1, deviation * dev + y1, x2, deviation * dev + y2,   xloc.bar_index, extend.right,
 color_up,style=line.style_dashed, width=line_thick)
line.delete(dp[1])

dpHist := line.new(x1[lengthHist], deviation * dev + y1[lengthHist], x2[lengthHist], deviation * dev + y2[lengthHist],
 xloc.bar_index, extend.none, color_up,style=line.style_dashed, width=line_thick)
line.delete(dpHist[1])

dpHist1 := line.new(x1[lengthHist*2], deviation * dev + y1[lengthHist*2], x2[lengthHist*2], deviation * dev + y2[lengthHist*2],
 xloc.bar_index, extend.none, color_up,style=line.style_dashed, width=line_thick)
line.delete(dpHist1[1])

dm := line.new(x1, -deviation * dev + y1, x2, -deviation * dev + y2, xloc.bar_index, extend.right,
 color_down,style=line.style_dashed, width=line_thick)
line.delete(dm[1])

dmHist := line.new(x1[lengthHist], -deviation * dev + y1[lengthHist], x2[lengthHist], -deviation * dev + y2[lengthHist],
 xloc.bar_index, extend.none, color_down,style=line.style_dashed, width=line_thick)
line.delete(dmHist[1])

dmHist1 := line.new(x1[lengthHist*2], -deviation * dev + y1[lengthHist*2], x2[lengthHist*2], -deviation * dev + y2[lengthHist*2],
 xloc.bar_index, extend.none, color_down,style=line.style_dashed, width=line_thick)
line.delete(dmHist1[1])

// ********************************************************************************************************************************************* //
// Signaux 
dm_current = -deviation * dev + y2
dp_current = deviation  * dev + y2

// *** Linear Regression Buy & Sell Signal Regular Mode *** //
sell  = ta.crossunder (close, dm_current)
buy = ta.crossover    (close, dp_current)
BuySignalColor =color.new(#00ff00, 50)
SellSignalColor=color.new(#ff00e6, 30)

// ********************************************************************************************************************************************* //
plotshape(not reversal ? buy :  na, title='BUY',     style=shape.triangleup,  location=location.top,color=color.new(#00ff00, 0),size=size.tiny,
 text='Buy',     textcolor=color.new(#87a4f1, 0),show_last=signals == 'All' ? 99999999 : 500)
if not reversal and buy
    line.new(bar_index, high, bar_index,low, xloc=xloc.bar_index, extend=extend.both, color=BuySignalColor, style=line.style_dashed, width=1)

plotshape(not reversal ? sell : na, title='SELL',    style=shape.triangledown,location=location.top,color=color.new(#ff0000, 0) ,size=size.tiny,
 text='Sell',    textcolor=color.new(#87a4f1, 0),show_last=signals == 'All' ? 99999999 : 500)
if not reversal and sell
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=SellSignalColor, style=line.style_dashed, width=1)

plotshape(reversal ?     buy :  na, title='SELL Rv', style=shape.triangledown,location=location.top,color=color.new(#ff0000, 0),size=size.tiny,
 text='Sell\nRv',textcolor=color.new(#87a4f1, 0),show_last=signals == 'All' ? 99999999 : 500)
if reversal and buy
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=SellSignalColor, style=line.style_dashed, width=1) 

plotshape(reversal ?     sell:  na, title='BUY Rv',  style=shape.triangleup,  location=location.top,color=color.new(#00ff00, 0) ,size=size.tiny,
 text='Buy\nRv', textcolor=color.new(#87a4f1, 0),show_last=signals == 'All' ? 99999999 : 500)
if reversal and sell
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=BuySignalColor, style=line.style_dashed, width=1)

// Affichage Signal (Triangle Up or Down)
plotshape(buy  and not reversal ? dp_current : na,"CrossBuy",    shape.triangleup,   location.absolute,#5ff387,size=size.small)
plotshape(sell and not reversal ? dm_current : na,"CrossSell",   shape.triangledown, location.absolute,#f65555,size=size.small)
plotshape(buy  and     reversal ? dp_current : na,"CrossSellRv", shape.triangledown, location.absolute,#f65555,size=size.small)
plotshape(sell and     reversal ? dm_current : na,"CrossBuyRv",  shape.triangleup,   location.absolute,#5ff387,size=size.small) 

// ******************************************************************************** // 
// *** Define F_print_last function For Current Trade Infos *** //
f_print_last(_offsetx, _offsety, _lab_styl, _bkg_color, _text, _color_text, _size) =>
    // *** Create label *** //.
    var _label = label(na)
    label.delete(_label)
    _label := label.new(bar_index+_offsetx, _offsety, _text, xloc.bar_index, yloc.price, _bkg_color, _lab_styl, _color_text, _size, text.align_center)
    _label

// ******************************************************************************** // 
// *** Define F_print2 function For Trades Infos *** //
f_print2(_offsetx, _offsety, _lab_styl, _bkg_color, _text, _color_text, _size) =>
    // *** Create label *** //.
    var _label = label(na)
    // label.delete(_label) // permanent label //
    _label := label.new(bar_index + _offsetx, _offsety, _text, xloc.bar_index, yloc.price, _bkg_color, _lab_styl, _color_text, _size, text.align_center)
    _label

// ******************************************************************************** //
// [Buy Only] & [Sell Only]' both checked or no checked = [BUY + SELL]              //
if (sell_only and buy_only) or (not sell_only and not buy_only)
    sell_only:=false
    buy_only:=false
    
// ******************************************************************************** // 
// Gestion Des Multiplicateurs Stop Loss  //
// Managing Stop Loss Multipliers         //
sl=sl1
if slX10 and sl>0
    sl:=sl1*10

if no_sl
    sl:=0

// *************************************** // 
stp_loss_enable=bool(na)
if sl==0
    stp_loss_enable:=false
else
    stp_loss_enable:=true

// *************************************** // 
// Gestion Des Multiplicateurs Take Profit //
// Managing Take Profit Multipliers        //
tp=tp1
if tpX10 and tp>0
    tp:=tp1*10

if no_tp
    tp:=0

// *************************************** // 
tp_enable=bool(na)
if tp==0
    tp_enable:=false
else
    tp_enable:=true  

// ******************************************************************************************************************** // 
trend = -1
trend := nz(trend[1], trend)

// ************************************************ LINEAR REGRESSION METHODE ***************************************** //
// Trend == 1 --> Long If Not Reverse //
if not reversal 
    trend := trend == -1 and buy ? 1 : trend == 1 and sell ? -1 : trend
else
    trend := trend == 1 and buy ? -1 : trend == -1 and sell ? 1 : trend

changeCond = trend != trend[1]

// ********************************************************************************************************************* // 
var no_bar=int(0)
varip int no_trend =0 // Varip //
var last_trend=int(na)
//-------------------------//
no_bar:=no_bar+1
last_trend:=no_bar-no_trend
varip trade = float(0)
//-------------------------//
if changeCond
    no_trend := no_bar
    
// ******************************************************************************** // 
var buySignal=bool(na) 

if not reversal
    buySignal:= changeCond and trend == 1
else
    buySignal:= changeCond and trend == -1

// ******************************************************************************** // 
var sellSignal = bool(na)

if not reversal
    sellSignal:= changeCond and trend == -1
else
    sellSignal:= changeCond and trend == 1

// ******************************************************************************** // 
var bool sl_lg       =na
var bool sl_sh       =na
var bool stop_loss   =na

var bool tp_lg       =na
var bool tp_sh       =na
var bool take_profit =na

// ********************************************************************************************************** // 
// Gestion des Numeros de Trade, En Accord Avec La Liste Des Transactions Du testeur De Strategie TradindView //
// Management of Trade Numbers, In Accordance With The TradindView Strategy tester's Transactions List        //
// ********************************************************************************************************** //
// ********************************************************************************************************** //
// ************************** modifying this section is not recommended ! *********************************** //
// ********************************************************************************************************** //
if (changeCond and not sell_only and not buy_only) and trade==0       // ************************************ //
    trade:=trade+1                                                    // ************************************ //  
else 
    if (changeCond and not sell_only and not buy_only)                // ************************************ //
        trade:=trade+1

if  trade==0 and not reversal and buySignal and buy_only              // ************************************ //
    trade:=trade+1

if  trade==0 and not reversal and sellSignal and sell_only            // ************************************ //
    trade:=trade+1
    
if  trade==0 and reversal and buySignal and sell_only                 // ************************************ //
    trade:=trade+1

if  trade==0 and reversal and sellSignal and buy_only                 // ************************************ //
    trade:=trade+1    
// ********************************************************************************************************** //

// ******************************************************************************** // 
// ******************************* STRATEGY *************************************** //
// ******************************************************************************** // 
var str_lg=bool(na)
var str_sh=bool(na)

// !!! Varip -> start_price!!! 
varip start_price=float(na) // varip //

//**************************************************************************//
// Trend == 1 --> Long Normal
if trend == 1 and changeCond and not reversal and not str_lg
    str_lg:=true
    str_sh:=false
    start_price:=close
    sl_lg:=false
    sl_sh:=false
    tp_lg:=false
    tp_sh:=false

// Trend == -1 --> Short Normal
if trend == -1 and changeCond and not reversal and not str_sh
    str_lg:=false
    str_sh:=true
    start_price:=close
    sl_lg:=false
    sl_sh:=false
    tp_lg:=false
    tp_sh:=false

//**************************************************************************//
// Trend == -1 -->Short Reversal
if trend == -1 and changeCond and reversal and not str_sh
    str_lg:=false
    str_sh:=true
    start_price:=close
    sl_lg:=false
    sl_sh:=false
    tp_lg:=false
    tp_sh:=false

// Trend == 1 --> Long Reversal
if trend == 1 and changeCond and reversal and not str_lg
    str_lg:=true
    str_sh:=false
    start_price:=close
    sl_lg:=false
    sl_sh:=false
    tp_lg:=false
    tp_sh:=false

// **************************************************************************************************************************************************** // 
// ************************************************ Strategy Entry LG - SH - LG Rev - SH Rev ********************************************************** //
// **************************************************************************************************************************************************** // 
if not reversal and str_lg and not sell_only and buySignal
    strategy.entry('Lg', strategy.long, comment = 'Lg '+str.format('{0,number,#}',trade))
    stop_loss:=false
    take_profit:=false

if not reversal and str_sh and not buy_only and sellSignal
    strategy.entry('Sh', strategy.short,comment = 'Sh '+str.format('{0,number,#}',trade))
    stop_loss:=false
    take_profit:=false

if     reversal and str_lg and not sell_only and sellSignal
    strategy.entry('Lg Rev', strategy.long,comment = 'Lg Rev '+str.format('{0,number,#}',trade))
    stop_loss:=false
    take_profit:=false

if     reversal and str_sh and not buy_only and buySignal
    strategy.entry('Sh Rev', strategy.short,comment = 'Sh Rev '+str.format('{0,number,#}',trade))
    stop_loss:=false
    take_profit:=false
    
//**************************************************************************//
// Difference De Prix % depuis l'entrée en position
// Price Difference % since entry into position
// Avg_Price +- (Avg_Price * D_per100 / 100) --> Previus Price 
d_per100=(close - strategy.position_avg_price) / strategy.position_avg_price

var txt_end_trade=string(na)
total_days=string(na)

//**************************************************************************//
if str.tonumber(timeframe.period)<=240
    total_days:='\nHist '+str.format('{0,number,#.#} ', (bar_index*str.tonumber(timeframe.period)/1440)) +' DAYS'

if timeframe.period=='D'
    total_days:='\nHist '+str.format('{0,number,#.#} ', (bar_index)) +' DAYS'
    
if timeframe.period=='W'
    total_days:='\nHist '+str.format('{0,number,#.#} ', (bar_index*7)) +' DAYS'
 
if timeframe.period=='M'
    total_days:='\nHist '+str.format('{0,number,#.#} ', (bar_index*30.4375)) +' DAYS'

if (timeframe.period!='M' or timeframe.period!='W' or timeframe.period!='D') and (str.tonumber(timeframe.period)>240 or str.tonumber(timeframe.period)<1)
    total_days:='\nHist ???' + ' DAYS'
    
//**************************************************************************//
since_days=string(na)
//  si le script s'exécute sur la barre en temps réel (parametre de strategy:calc_on_every_tick=true)
since=bar_index-bar_index[last_trend]-1

//  si le script s'exécute sur la barre précédant immédiatement la barre en temps réel (parametre de strategy:calc_on_every_tick=false)
if barstate.islastconfirmedhistory
    since:=bar_index-bar_index[last_trend]-1

//**************************************************************************//
if str.tonumber(timeframe.period)<=240
    since_days:='\nSince '+str.format('{0,number,#.#} ', (since*str.tonumber(timeframe.period)/1440)) +' DAYS'

if timeframe.period=='D'
    since_days:='\nSince '+str.format('{0,number,#.#} ', (since)) +' DAYS'
    
if timeframe.period=='W'
    since_days:='\nSince '+str.format('{0,number,#.#} ', (since*7)) +' DAYS'
 
if timeframe.period=='M'
    since_days:='\nSince '+str.format('{0,number,#.#} ', (since*30.4375)) +' DAYS'

if (timeframe.period!='M' or timeframe.period!='W' or timeframe.period!='D') and (str.tonumber(timeframe.period)>240 or str.tonumber(timeframe.period)<1)
    since_days:='\nSince ???' + ' DAYS'

//**************************************************************************//
SizePosUsd=string(na)
SizePosBtc   =float(na)

if trade>=1
    SizePosUsd:=strategy.account_currency+str.tostring(strategy.position_size*start_price,format =' #.##')
    SizePosBtc:=strategy.position_size

PnlFlag=string(na) 
GreenCircle  =string('🟢')
RedCircle    =string('🔴')
WhiteCircle  =string('⚪')
Comm=strategy.closedtrades.commission(strategy.closedtrades - 1)

if strategy.opentrades.profit(0)<0
    PnlFlag:=RedCircle
else if strategy.opentrades.profit(0)>0
    PnlFlag:=GreenCircle
else
    PnlFlag:=WhiteCircle

if show_full_info
    txt_end_trade:='# '+str.format('{0,number,#}',trade) +
     ' ' + PnlFlag  +
     '\n<last # '+str.format('{0,number,#}',trade[last_trend]) +
     '\n<'    + syminfo.basecurrency +str.format(' {0,number,#.########} ',strategy.position_size) +
     '\n<'    + SizePosUsd +
     '\nSL '  + str.format('{0,number,#.###}',sl)+'%'+ ' TP '   +str.format('{0,number,#.###}',tp)+'%' +
     '\n<E '  + str.format('{0,number,#.########} '     + strategy.account_currency,close[last_trend]) +
     '\n=C '  + str.format('{0,number,#.########} '     + strategy.account_currency,close) +
     '\nd '   + str.format('{0,number,#.########} '     + strategy.account_currency,close-close[last_trend]) +
     '\n<%d ' + str.format('{0,number,#.##%}',d_per100) +
     '\n=PnL '+ str.format('{0,number,#.##} '           + strategy.account_currency ,strategy.opentrades.profit(0)) +
     '\nComm ' + str.format('{0,number,-#.### }'       + strategy.account_currency ,Comm) +
     total_days + 
     since_days
else
    txt_end_trade:='# '+str.format('{0,number,#}',trade) +
     ' ' + PnlFlag  + 
     '\n<'    + syminfo.basecurrency +str.format(' {0,number,#.########} ',strategy.position_size) +
     '\n<'    + SizePosUsd +
     '\n<%d '  + str.format('{0,number,#.##%}',d_per100) +
     '\nPnL ' + str.format('{0,number,#.##} '           + strategy.account_currency ,strategy.opentrades.profit(0)) +
     '\nComm ' + str.format('{0,number,-#.## }'          + strategy.account_currency ,Comm) +
     since_days

// ************************************ //
// Label Horizontal Position Setting    //
atr = ta.sma(ta.tr, loop) 
high_pos=ohlc4 + (y_Pos_factor * atr)
low_pos=ohlc4  - (y_Pos_factor * atr)
// ************************************ //

var f2=label(na)
if trade==0
    label.delete(f2)
pnl_color=color(na)

if strategy.opentrades.profit(0)<0
    pnl_color:=color.new(#080808, 0)
else if strategy.opentrades.profit(0)>0
    pnl_color:=color.new(#ffffff, 0)
else
    pnl_color:=color.new(#fbe78c, 0)
    
varip trade_dir=string(na)
// ----------------------------------------------------------------------------
txt_end_trade:=txt_end_trade +'\n'+str.format_time(time, "yyyy-MM-dd", "UTC")+'\ntrig='+str.format_time(time, "HH:mm", "UTC")+' UTC ' + '\n' + conf
// ----------------------------------------------------------------------------
// Alert Intermediat Buy / Sell
if ta.crossunder (close, dm_current) and not reversal and showIntermedSignal
    alert('\nIntermediate BUY Signal\n'+txt_end_trade, alert.freq_all)

if ta.crossover (close, dp_current) and not reversal and showIntermedSignal
    alert('\nIntermediate SELL Signal\n'+txt_end_trade, alert.freq_all)    

if ta.crossunder (close, dm_current) and reversal and showIntermedSignal
    alert('\nIntermediate SELL Signal Rev.\n'+txt_end_trade, alert.freq_all)

if ta.crossover (close, dp_current) and reversal and showIntermedSignal
    alert('\nIntermediate BUY Signal Rev.\n'+txt_end_trade, alert.freq_all)

// **************************************************************************************************************** //
// *** Ordre Des Parametres Pour F_Print2 : (_Offsetx,_Offsety,_Lab_styl,_Bkg_color,_Text,_Color_text,_Size)    *** //
// *** Order Of Parameters For F_Print2: (_Offsetx, _Offsety, _Lab_styl, _Bkg_color, _Text, _Color_text, _Size) *** //
// **************************************************************************************************************** //
ColorLg =color.new(#65ff65, 40)
ColorSh =color.new(#ff6565, 40)
// ----------------------------------------------------------------------------
if buySignal and show_trade_info and not reversal and not sell_only 
    f2:=f_print2( 1,high_pos,label.style_label_down, ColorLg, 
     'Lg '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Lg '

if buySignal and not reversal and not sell_only
    if showBuySignal    
        alert('\nBUY Signal\n'+txt_end_trade, alert.freq_all)
    trade_dir:='Lg '
// ----------------------------------------------------------------------------
if buySignal and show_trade_info and     reversal and not buy_only 
    f2:=f_print2( 1,low_pos,label.style_label_up, ColorSh, 
     'ShRv '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='ShRv '

if buySignal and     reversal and not buy_only
    if showSellSignal
        alert('\nSELL Rev. SIGNAL\n'+txt_end_trade, alert.freq_all)
    trade_dir:='ShRv '
// ----------------------------------------------------------------------------
if sellSignal and show_trade_info and not reversal and not buy_only 
    f2:=f_print2( 1,low_pos,label.style_label_up, ColorSh, 
     'Sh '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Sh '

if sellSignal and not reversal and not buy_only
    if showSellSignal
        alert('\nSELL SIGNAL\n'+txt_end_trade, alert.freq_all)
    trade_dir:='Sh '
// ----------------------------------------------------------------------------
if sellSignal and show_trade_info and     reversal and not sell_only 
    f2:=f_print2( 1,high_pos,label.style_label_down, ColorLg, 
     'LgRv '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='LgRv '

if sellSignal and     reversal and not sell_only
    if showBuySignal
        alert('\nBUY Rev. SIGNAL\n'+txt_end_trade, alert.freq_all)   
    trade_dir:='LgRv '
// ----------------------------------------------------------------------------
// ********************************************************************************************************************************************************** // 
//                                                        CALCUL des valeurs de Stop Loss et Take Profit                                                      //
// ********************************************************************************************************************************************************** //
// Prix EXIT Stop Loss & Take Profit calculés en pourcentage de la taille de la Position 
// Valeurs P&L calculées en pourcentage de la taille de la Position 
// FORMULE de CALCUL du Prix de Sortie : PRICE_TP.SL_usd = ((PRICE_usd x SIZE_btc x TP.SL_% / 100) +- (PRICE_usd x SIZE_btc)) / SIZE_btc
// Les Valeurs des Commissions d'Entrée & de Sortie sont prises en Compte !
SLLgValUsd= ( ( (start_price*SizePosBtc) - (start_price*SizePosBtc*sl/100) ) / SizePosBtc )+strategy.opentrades.commission(0)
SLShValUsd= ( ( (start_price*SizePosBtc) + (start_price*SizePosBtc*sl/100) ) / SizePosBtc )-strategy.opentrades.commission(0)

TPLgValUsd= ( ( (start_price*SizePosBtc) + (start_price*SizePosBtc*tp/100) ) / SizePosBtc )+strategy.opentrades.commission(0)
TPShValUsd= ( ( (start_price*SizePosBtc) - (start_price*SizePosBtc*tp/100) ) / SizePosBtc )-strategy.opentrades.commission(0)
// La valeurUSD du P&L           = ValeurUSD de la position     +- (ValeurUSD de la position     * TP%.SL% / 100)
// Le prixUSD de Sortie du TP.SL = Prix d'entrée de la position +- (Prix d'entrée de la position * TP%.SL% / 100)
// ********************************************************************************************************************************************************** //

// ********************************************************************************************************************************************************** // 
// ********************************************************************* STOP LOSS ************************************************************************** // 
// ********************************************************************************************************************************************************** // 
// SIGNAL SL
if close <= SLLgValUsd and stp_loss_enable and str_lg and not sell_only
    sl_lg := true
    stop_loss:=true

if close >= SLShValUsd and stp_loss_enable and str_sh and not buy_only
    sl_sh := true
    stop_loss:=true

// **************************************************************************************************************** //
// *** Ordre Des Parametres Pour F_Print2 : (_Offsetx,_Offsety,_Lab_styl,_Bkg_color,_Text,_Color_text,_Size)    *** //
// *** Order Of Parameters For F_Print2: (_Offsetx, _Offsety, _Lab_styl, _Bkg_color, _Text, _Color_text, _Size) *** //
// **************************************************************************************************************** //
varip sl_price=float(na) // varip //

ColorSlLg=color.new(#cd38ff, 40)
ColorSlSh=color.new(#cd38ff, 40)

if sl_lg and stp_loss_enable and not reversal and show_trade_info and str_lg and not sell_only 
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorSlLg, 
     'SL LG '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '    

if sl_lg and stp_loss_enable and not reversal and str_lg
    strategy.close('Lg', comment = 'STOP LOSS LG '+str.format('{0,number,#}',trade),immediately = true)
    if showSlSignal
        alert('\nSTOP LOSS LG\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    sl_price:=close
    trade_dir:='Null '   

// ******************************************************************************** // 
if sl_sh and stp_loss_enable and not reversal and show_trade_info and str_sh and not buy_only
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorSlSh, 
     'SL SH '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if sl_sh and stp_loss_enable and not reversal and str_sh
    strategy.close('Sh', comment = 'STOP LOSS SH '+str.format('{0,number,#}',trade),immediately = true)
    if showSlSignal
        alert('\nSTOP LOSS SH\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    sl_price:=close
    trade_dir:='Null '   

// ******************************************************************************** //
// ******************************************************************************** //
if sl_lg and stp_loss_enable and reversal and show_trade_info and str_lg and not sell_only
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorSlLg, 
     'SL LGRv '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if sl_lg and stp_loss_enable and reversal and str_lg
    strategy.close('Lg Rev', comment = 'STOP LOSS LG Rev. '+str.format('{0,number,#}',trade),immediately = true)
    if showSlSignal
        alert('\nSTOP LOSS LG Rev.\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    sl_price:=close
    trade_dir:='Null '   

// ******************************************************************************** // 
if sl_sh and stp_loss_enable and reversal and show_trade_info and str_sh and not buy_only
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorSlSh, 
     'SL SHRv '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if sl_sh and stp_loss_enable and reversal and str_sh
    strategy.close('Sh Rev', comment = 'STOP LOSS SH Rev. '+str.format('{0,number,#}',trade),immediately = true)
    if showSlSignal
        alert('\nSTOP LOSS SH Rev.\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    sl_price:=close
    trade_dir:='Null '  

// ********************************************************************************************************************************************************** // 
// ********************************************************************* TAKE PROFIT ************************************************************************ // 
// ********************************************************************************************************************************************************** //
// SIGNAL TP
if close >= TPLgValUsd and tp_enable and str_lg and not sell_only
    tp_lg := true
    take_profit:=true

if close <= TPShValUsd and tp_enable and str_sh and not buy_only
    tp_sh := true
    take_profit:=true

// **************************************************************************************************************** //
// *** Ordre Des Parametres Pour F_Print2 : (_Offsetx,_Offsety,_Lab_styl,_Bkg_color,_Text,_Color_text,_Size)    *** //
// *** Order Of Parameters For F_Print2: (_Offsetx, _Offsety, _Lab_styl, _Bkg_color, _Text, _Color_text, _Size) *** //
// **************************************************************************************************************** //
varip tp_price=float(na) //varip //

ColorTp=color.new(#004500, 22)

if tp_lg and tp_enable and not reversal and show_trade_info and str_lg and not sell_only 
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorTp, 
     'TP LG '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if tp_lg and tp_enable and not reversal and str_lg
    strategy.close('Lg', comment = 'TAKE PROFIT LG '+str.format('{0,number,#}',trade),immediately = true)
    if showTpSignal
        alert('\nTAKE PROFIT LG\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    tp_price:=close
    trade_dir:='Null ' 

// ******************************************************************************** // 
if tp_sh and tp_enable and not reversal and show_trade_info and str_sh and not buy_only
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorTp, 
     'TP SH '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if tp_sh and tp_enable and not reversal and str_sh
    strategy.close('Sh', comment = 'TAKE PROFIT SH '+str.format('{0,number,#}',trade),immediately = true)
    if showTpSignal
        alert('\nTAKE PROFIT SH\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    tp_price:=close
    trade_dir:='Null '  

// ******************************************************************************** //
// ******************************************************************************** //
if tp_lg and tp_enable and reversal and show_trade_info and str_lg and not sell_only
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorTp, 
     'TP LGRv '+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if tp_lg and tp_enable and reversal and str_lg
    strategy.close('Lg Rev', comment = 'TAKE PROFIT LG Rev. '+str.format('{0,number,#}',trade),immediately = true)
    if showTpSignal
        alert('\nTAKE PROFIT LG Rev.\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    tp_price:=close
    trade_dir:='Null '   

// ******************************************************************************** // 
if tp_sh and tp_enable and reversal and show_trade_info and str_sh and not buy_only
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorTp, 
     'TP SHRv'+txt_end_trade,
     pnl_color, size.normal)
    trade_dir:='Null '

if tp_sh and tp_enable and reversal and str_sh
    strategy.close('Sh Rev', comment = 'TAKE PROFIT SH Rev. '+str.format('{0,number,#}',trade),immediately = true)
    if showTpSignal
        alert('\nTAKE PROFIT SH Rev.\n'+txt_end_trade, alert.freq_all)
    str_lg:=false
    str_sh:=false
    tp_price:=close
    trade_dir:='Null '  

// ********************************************************************************************************************************************************** // 
//                                                                           EXIT                                                                             //
// ********************************************************************************************************************************************************** // 
// **************************************************************************************************************** //
// *** Ordre Des Parametres Pour F_Print2 : (_Offsetx,_Offsety,_Lab_styl,_Bkg_color,_Text,_Color_text,_Size)    *** //
// *** Order Of Parameters For F_Print2: (_Offsetx, _Offsety, _Lab_styl, _Bkg_color, _Text, _Color_text, _Size) *** //
// **************************************************************************************************************** //
ColorExit =color.new(#7471ff, 40)

if changeCond and sellSignal and not reversal and buy_only and show_trade_info and not stop_loss and not take_profit
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorExit,
     'ExLg '+txt_end_trade,
     pnl_color, size.normal)
    stop_loss:=false
    take_profit:=false
    trade_dir:='Null '

if changeCond and sellSignal and not reversal and buy_only 
    strategy.close('Lg',comment = 'Exit Lg '+str.format('{0,number,#}',trade), immediately=true)
    if showExitSignal
        alert('\nEXIT LG\n'+txt_end_trade, alert.freq_all) 
    stop_loss:=false
    take_profit:=false
    trade:=trade+1
    trade_dir:='Null '
    str_lg:=false
    str_sh:=false  

// ********************************************************************************************************************************************************** //
if changeCond and buySignal and not reversal and sell_only and show_trade_info and not stop_loss and not take_profit
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorExit, 
     'ExSh '+txt_end_trade,
     pnl_color, size.normal)
    stop_loss:=false
    take_profit:=false
    trade_dir:='Null '

if changeCond and buySignal and not reversal and sell_only
    strategy.close('Sh', comment = 'Exit Sh '+str.format('{0,number,#}',trade), immediately=true)
    if showExitSignal
        alert('\nEXIT SH\n'+txt_end_trade, alert.freq_all)
    stop_loss:=false
    take_profit:=false
    trade:=trade+1
    trade_dir:='Null '    
    str_lg:=false
    str_sh:=false  

// ********************************************************************************************************************************************************** //
// ********************************************************************************************************************************************************** //
if changeCond and sellSignal and reversal and sell_only and show_trade_info and not stop_loss and not take_profit
    f2:=f_print2( 0,high_pos,label.style_label_down, ColorExit, 
     'ExShRv '+txt_end_trade,
     pnl_color, size.normal)
    stop_loss:=false
    take_profit:=false
    trade_dir:='Null '

if changeCond and sellSignal and reversal and sell_only
    strategy.close('Sh Rev', comment = 'Exit Sh Rev '+str.format('{0,number,#}',trade), immediately=true)
    if showExitSignal
        alert('\nEXIT SH REV.\n'+txt_end_trade, alert.freq_all)
    stop_loss:=false
    take_profit:=false
    trade:=trade+1
    trade_dir:='Null '
    str_lg:=false
    str_sh:=false   

// ********************************************************************************************************************************************************** //
if changeCond and buySignal and reversal and buy_only and show_trade_info and not stop_loss and not take_profit
    f2:=f_print2( 0,low_pos,label.style_label_up, ColorExit, 
     'ExLgRv '+txt_end_trade,
     pnl_color, size.normal)
    stop_loss:=false
    take_profit:=false
    trade_dir:='Null '

if changeCond and buySignal and reversal and buy_only
    strategy.close('Lg Rev', comment = 'Exit Lg Rev '+str.format('{0,number,#}',trade), immediately=true)
    if showExitSignal
        alert('\n'+'EXIT LG REV.\n'+txt_end_trade, alert.freq_all)
    stop_loss:=false
    take_profit:=false
    trade:=trade+1
    trade_dir:='Null '     
    str_lg:=false
    str_sh:=false   

// ********************************************* Candle Colors According To Trend Direction ***************************************************************** //
barcolor (not reversal and trend == -1 and barscolors and not buy_only and not stop_loss and not take_profit ? color.new(#ff0000, 55) : 
 not reversal and trend == 1 and barscolors and not sell_only and not stop_loss and not take_profit ? color.new(#00ff00, 55) :
 reversal and trend == -1 and barscolors and not buy_only and not stop_loss and not take_profit ? color.new(#ff0000, 55) :
 reversal and trend == 1 and barscolors and not sell_only and not stop_loss and not take_profit ? color.new(#00ff00, 55) :
 barscolors ? color.new(#2a2a2c, 55) : na )

// ********************************************************************************************************************************************************** //
shp_color =color.new(na, 100)

if not take_profit and not stop_loss
    if str_lg and (linreg >= linreg[1])
        shp_color:=not sell_only ? color.new(#00ff00, 0) : color.new(#00ff00, 80)

    if str_lg and (linreg < linreg[1])
        shp_color:=not sell_only ? color.new(#eaff00, 0) : color.new(#eaff00, 80)
        
    // ------------------------------------------------------------------------------------------------- //
    if str_sh and (linreg < linreg[1])
        shp_color:=not buy_only ? color.new(#ff0000, 0) : color.new(#ff0000, 80)

    if str_sh and (linreg >= linreg[1])
        shp_color:=not buy_only ? color.new(#ff9100, 0) : color.new(#ff9100, 80)

plot(linreg, 'Regression Line', color= shp_color,linewidth=2,style=plot.style_line)

plotshape(linreg, 'PnL Line',style=shape.square,location=location.top, 
 color=(str_lg and (close>=start_price)) or (str_sh and (close<=start_price)) ? color.new(#00ff00,20) : 
 (str_lg and (close<start_price)) or (str_sh and (close>start_price))  ? color.new(#ff0000, 20) : na,size=size.tiny)

// ********************************************************************* Stop Loss Indicator ************************************************************************************ //
sl_lg_price=SLLgValUsd

if show_sl_line and stp_loss_enable and not sell_only  and sl_lg
    sl_lg_price:=sl_price

sl_sh_price=SLShValUsd

if show_sl_line and stp_loss_enable and not buy_only and sl_sh
    sl_sh_price:=sl_price

sl_line_lg=plot(show_sl_line and stp_loss_enable and not sell_only  and (str_lg or sl_lg) and not stop_loss ? sl_lg_price : na,
 title='Stop loss Lg Line',  style=plot.style_linebr, linewidth=2, color=color.new(#ff0000, 0),offset=1)
 
sl_line_sh=plot(show_sl_line and stp_loss_enable and not buy_only and (str_sh or sl_sh) and not stop_loss ? sl_sh_price : na,
 title='Stop loss Sh Line',  style=plot.style_linebr, linewidth=2, color=color.new(#ff0000, 0),offset=1)

// ********************************************************************* Take Profit Indicator ************************************************************************************ //
tp_lg_price=TPLgValUsd

if show_tp_line and tp_enable and not sell_only  and tp_lg
    tp_lg_price:=tp_price

tp_sh_price=TPShValUsd

if show_tp_line and tp_enable and not buy_only and tp_sh
    tp_sh_price:=tp_price

tp_line_lg=plot(show_tp_line and tp_enable and not sell_only  and (str_lg or tp_lg) and not take_profit ? tp_lg_price : na,
 title='Take Profit Lg Line',  style=plot.style_linebr, linewidth=2, color=color.new(#00ff00, 0),offset=1)
 
tp_line_sh=plot(show_tp_line and tp_enable and not buy_only and (str_sh or tp_sh) and not take_profit ? tp_sh_price : na,
 title='Take Profit Sh Line',  style=plot.style_linebr, linewidth=2, color=color.new(#00ff00, 0),offset=1)

// ********************************************************************* Entry Price Indicator ********************************************************************************** //
start_price_line=plot(start_price, title='Start Price Line',  style=plot.style_steplinebr, linewidth=2, color=color.new(#ffff00, 0) , trackprice=true,offset=1, editable=false)

// ********************************************************************* Stop Loss Background *********************************************************************************** //
fill(start_price_line, sl_line_lg , title='Stop Loss Long Background',  color=show_sl_line and stp_loss_enable and not sell_only and not stop_loss ? color.new(#ff4fb3, 80): na, editable=false)
fill(start_price_line, sl_line_sh , title='Stop Loss Short Background', color=show_sl_line and stp_loss_enable and not buy_only and not stop_loss  ? color.new(#ff4fb3, 80): na, editable=false)

// ******************************************************************* Take Profit Background *********************************************************************************** //
fill(start_price_line, tp_line_lg , title='TP Long Background',  color=show_tp_line and tp_enable and not sell_only and not take_profit ? color.new(#00ff00, 90): na, editable=false)
fill(start_price_line, tp_line_sh , title='TP Short Background', color=show_tp_line and tp_enable and not buy_only and not take_profit  ? color.new(#00ff00, 90): na, editable=false)

// dmline & dpline
dmline=plot(dm_current,'dm_current',color=color.new(#00ff00, 0),style=plot.style_line,linewidth=2)
dpline=plot(dp_current,'dp_current',color=color.new(#ff0000, 0),style=plot.style_line,linewidth=2)

// ******************************************************************* Take Profit Background *********************************************************************************** //
var f1=label(na)
if trade==0 or barstate.ishistory 
    label.delete(f1) 

// ******************************************************************* Label Current Position *************************************************************** //
// ***************************************************************************************************************** //
// *** Ordre Des Parametres Pour F_Print_last : (_Offsetx,_Offsety,_Lab_styl,_Bkg_color,_Text,_Color_text,_Size) *** //
// *** Order Of Parameters For F_Print_last: (_Offsetx, _Offsety, _Lab_styl, _Bkg_color, _Text, _Color_text, _Size)  //
// ***************************************************************************************************************** //
// 
// Waiting for current bar to close ! Attente clôture de la barre actuelle ! 
//  si le script s'exécute sur la barre précédant immédiatement la barre en temps réel (parametre de strategy:calc_on_every_tick=false)
WaitingTxt=' ' + WhiteCircle + '\nWaiting for\ncurrent bar\nto close !\n----------\nAttente\nclôture\nde la barre\nactuelle !\n'
var f3=label(na)

if trend==trend[1]
    label.delete(f3)
    f1:=f_print_last(8,close,label.style_label_left,strategy.position_size>0 ? ColorLg : strategy.position_size<0 ? ColorSh : color.new(#cccccc, 22), 
     trade_dir+txt_end_trade, 
     pnl_color, size.normal)
else
    label.delete(f1)
    f3:=f_print_last(8,close,label.style_label_left,strategy.position_size>0 ? ColorLg : strategy.position_size<0 ? ColorSh : color.new(#cccccc, 22), 
     trade_dir + '#' + str.format('{0,number,#}',trade) + WaitingTxt + conf , 
     pnl_color, size.normal)
// ----------------------------------------------------------------------------------------------------------------------------------------------------------
// Extend Trend Line/Shape hl2
ExtendColor=(open[ExtOffset-1]+close[ExtOffset-1])/2<(open+close)/2 ? color.new(#00ff00, 22) : color.new(#ff0303, 22)
plotshape((open[ExtOffset-1]+close[ExtOffset-1])/2,'(open+close)/2)',style=shape.circle,location=location.absolute, 
 color=ExtendColor, size=size.tiny,show_last=1,offset=-ExtOffset+1,editable=false)  

plotshape((open+close)/2,'(open+close)/2)',style=shape.circle,location=location.absolute, color=ExtendColor, size=size.tiny,show_last=1,offset=0,editable=false) 

f_ExtLines(_NbVal,_ExtOffset,_Value1,_Value2,_Value3,_Color1,_Color2,_Color3,_style1,_style2,_style3,_width1,_width2,_width3)=>
// Definition de fonction : trace une pseudo tangente (etendue à droite) pour 1 à 3 courbes
// ! _NbVal== [1 to 3]
// ! _NbVal==1 -> _Value2==float(na) & _Color2==color(na) & _Value3==float(na) & _Color3==color(na)
// ! _NbVal==2 -> _Value3==float(na)) & _Color3==color(na)
    if _NbVal>=1 and _NbVal<4
        _ExtLine1 = line.new(bar_index-_ExtOffset, _Value1[_ExtOffset], bar_index, _Value1, color=_Color1,style=_style1, width=_width1, extend=extend.right)
        line.delete(_ExtLine1[1])
    if _NbVal>=2 and _NbVal<4
        _ExtLine2 = line.new(bar_index-_ExtOffset, _Value2[_ExtOffset], bar_index, _Value2, color=_Color2,style=_style2, width=_width2, extend=extend.right)
        line.delete(_ExtLine2[1])
    if _NbVal==3
        _ExtLine3 = line.new(bar_index-_ExtOffset, _Value3[_ExtOffset], bar_index, _Value3, color=_Color3,style=_style3, width=_width3, extend=extend.right)
        line.delete(_ExtLine3[1])

// Extended Trend line(s) 
f_ExtLines(1,ExtOffset-1,(open+close)/2,float(na),float(na),ExtendColor,color(na),color(na),line.style_solid,line.style_solid,line.style_solid,1,1,1 )

// ********************************************************************************************************************************************************** // 

// ************************************************************************************************* //
// ********************************* Affichage légende Label *************************************** //
// ************************************** Label Legend ********************************************* //
// ************************************************************************************************* //
var table LegendTable = table.new(position.bottom_right, 1, 4, bgcolor =#000000)

if ShowLegendTable and not show_full_info
    table.cell(LegendTable, 0, 0, 'STRATEGY\nLEGEND',text_size=size.small, text_color=color.new(#eff57a, 0),text_halign=text.align_center, text_valign=text.align_top
     ,tooltip= '   STRATEGY LEGEND\n---------------------------\n'+
     '*-Position + N° Trade\n' + GreenCircle + 'Profit ' + RedCircle + 'Loss ' + WhiteCircle + ' ???\n\n'+
     '*-Position Size (BTC)\n'+
     '*-Position Size (USD)\n'+
     '*-Difference (%)\n'+
     '*-PnL (+-USD)\n'+
     '*-Commisions (-USD)\n'+
     '*-Position since X days\n'+
     '*-Bar Closed at Date (UTC)\n'+
     '*-Trigged at hh:mn (UTC)\n' +
     '*-Timeframe Config')

if ShowLegendTable and show_full_info
    table.cell(LegendTable, 0, 0, 'STRATEGY\nFull LEGEND',text_size=size.small, text_color=color.new(#eff57a, 0),text_halign=text.align_center, text_valign=text.align_top
      ,tooltip= '   STRATEGY Full LEGEND\n---------------------------\n\n'+
     '*-Position + N° Trade\n' + GreenCircle + 'Profit ' + RedCircle + 'Loss ' + WhiteCircle + ' ???\n\n'+
     '*-Last Opened Trad #\n'+
     '*-Position Size (BTC)\n'+
     '*-Position Size (USD)\n'+
     '*-SL / TP Value (%)\n'+
     '*-Last Entry Value (USD)\n'+
     '*-Last Bar Value (USD)\n'+
     '*-Difference (USD)\n'+
     '*-Difference (%)\n'+
     '*-PnL (+-USD)\n'+
     '*-Commisions (-USD)\n'+
     '*-Histo Datas Since X Days\n'+
     '*-Position since X days\n'+
     '*-Bar Closed at Date (UTC)\n'+
     '*-Trigged at hh:mn (UTC)\n' +
     '*-Timeframe Config')
// ************************************************************************************************* //
// *** Define ChangePercent function For Trades Infos *** 
changePercent(v1, v2) => 
    float result = ( (v1 / v2) -1 ) * 100
// ************************************************************************************************* //
// *** Define allComm function For Trades Infos *** 
AllComm() =>
    TotComm = 0.0
    for tradeNo = 0 to strategy.closedtrades - 1
        TotComm += strategy.closedtrades.commission(tradeNo)
    result = TotComm
// ************************************************************************************************* //
SumCom=AllComm()

// Prix estimé de liquidation
LiquidPrice=strategy.margin_liquidation_price
plot(ShowLiquidPrice ? LiquidPrice : na, 'Liquidation Price',#ff9800,2, plot.style_stepline,true,join=true)

// margin call, to prevent it.
var f4=label(na)
// % distance du prix actuel par rapport au prix de liquidation estimé pour la position
// price + (price x +-marge / 100) --> Liquidation price
Marge=changePercent(LiquidPrice, close)
MargeAbs=math.abs(Marge)
// Price * Marge% / 100 = Distance (USD)

PerCentEquity=(math.abs(strategy.position_size) * math.abs(strategy.position_avg_price) / (strategy.netprofit + strategy.initial_capital) )*100
Dist_Liq_Price=math.abs(LiquidPrice-close)

AlertMarg1 = 40
AlertMarg2 = 30
ColorMarge=MargeAbs<=AlertMarg2 ? #fb0606 : MargeAbs <=AlertMarg1 ? #f56d05 : #6ded0c

MarginWarningText=MargeAbs<=AlertMarg1 ? '\n ! LIQUIDATION WARNING !\n' : ' '

MargeText=MarginWarningText + 
 '\nEstimated\nLiquidation Price\n' + 
 str.format('{0,number,#.##}',LiquidPrice) + ' ' + strategy.account_currency + 
 '\n-------------------------' + 
 '\nLast Price : ' + str.format('{0,number,#.##}',close) +' ' + strategy.account_currency + 
 '\nat ' + str.format('{0,number,#.##}', MargeAbs) + ' %\nfrom Liquidation Price !' + 
 '\n-------------------------' +
 '\nLast Price at\n' + str.format('{0,number,#.##}',Dist_Liq_Price) + ' ' + strategy.account_currency + '\nfrom Liqu.Price' +
 '\n-------------------------' +
 '\nOpen Trade(s) =' + str.format('{0,number,#}',strategy.opentrades) + 
 '\nClosed Trade(s) =' + str.format('{0,number,#}',strategy.closedtrades) + 
 '\nSumComm : ' + str.format('{0,number,-#.##}',SumCom) + ' ' + strategy.account_currency + 
 '\n-------------------------' +
 '\nEquity ' +  str.format('{0,number,#.##}',strategy.equity) + ' ' + strategy.account_currency + 
 '\nNet Profit ' +  str.format('{0,number,#.##}',strategy.netprofit) + ' ' + strategy.account_currency + 
 '\nIni.capital ' +  str.format('{0,number,#.##}',strategy.initial_capital) + ' ' + strategy.account_currency + 
 '\nPnL '+ str.format('{0,number,#.##} '+ strategy.account_currency ,strategy.opentrades.profit(0)) +
 '\nPnL% ' + str.format(' {0,number,#.##%}',d_per100) +
 '\nComm : ' + str.format('{0,number,-#.##}',Comm) + ' ' + strategy.account_currency + 
 '\n-------------------------' +
 '\n\Trade Price ' + strategy.account_currency + str.format(' {0,number,#.##}',strategy.position_avg_price) +
 '\nTrade Size ' + syminfo.basecurrency + str.format(' {0,number,#.######}',strategy.position_size) + 
 '\nTrade Size ' + strategy.account_currency + str.format(' {0,number,#.##}',strategy.position_size*strategy.position_avg_price) + 
 '\nTrade Size ' + str.format('{0,number,#.##}',PerCentEquity) + '% of Equity' 

label.delete(f4)
if MargeAbs <= AlertMarg1
    f4:=f_print_last(3,LiquidPrice,label.style_label_left,ColorMarge, 
     trade_dir + '#' + str.format('{0,number,#}',trade) + ' ' + PnlFlag + MarginWarningText + 'Estimated\nLiquidation Price\n' + 
     str.format('{0,number,#.##}',LiquidPrice) + ' ' + strategy.account_currency , 
     pnl_color, size.small)

// var table MarginTable = table.new(position.bottom_right, 1, 4, bgcolor =#d50909)
var table MarginTable = table.new(MarginTablePos, 1, 1, bgcolor =#d50909)

if ShowMarginTable 
    table.cell(MarginTable, 0, 0, trade_dir + '#' + str.format('{0,number,#}',trade) + ' ' + PnlFlag + MargeText, text_size=size.small,
     text_color=color.new(#000000, 0),text_halign=text.align_center, text_valign=text.align_top, 
     bgcolor=ColorMarge,tooltip= trade_dir + '#' + str.format('{0,number,#}',trade) + ' ' + PnlFlag + MargeText) 

// ********************************************************************************************************************************************************** // 
// ************************************************************************ END CODE ************************************************************************ // 
// ********************************************************************************************************************************************************** //



// ********************************************************************************************************************************************************** //
// Major fixes:

//  * fixed Tradingview house rule violations on publishing scripts. *

//   Optimization of the strategy's Timeframe parameters.
//   Changing Margin % values (Long and Short)
//   Modification Value of % Commissions
//   Optimization of Timeframe parameters
//   Added a legend for the labels
//   Updated information Margin Call
//   New commission calculation
//   Calc on every tick=true
//   Change values % of Equity & Initial Capital
//   Addition Triangle on Buy or Sell signal (Crossing dp_current/dm_current)
//   Modification of Label Colors f_print2

// NOTES de Mise à Jour : 
// * correction des violations des règles internes de Tradingview sur la publication de scripts. *

// Modif valeurs % de Marges (Long et Short)
// Modif Valeur de % Commissions
// Optimisation parametres Timeframe
// Ajout d'une legende pour les labels
// Ajour info Margin Call
// Nouveau calcul de la commission
// Calc on every tick=true
// Modif valeurs % of Equity & Initial Capital
// Ajout Triangle sur signal Buy ou Sell (Crossing dp_current/dm_current)
// Modif Couleurs des Labels f_print2
````
