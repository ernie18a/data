# ATR-based TP/SL with Dynamic RR

- url: https://www.tradingview.com/script/P00iC8Ll/
- type: indicator
- pine_id: PUB;8752fa399afd410db38a8f6ff02a9edc
- version: 1.0

## Description

[b]English[/b]
 
This indicator combines the power of the Average True Range (ATR) with dynamic calculations for Take Profit (TP) and Stop Loss (SL) levels, offering a clear visualization of trading opportunities and their respective Risk-Reward Ratios (RRR).

Features:
Dynamic TP/SL Calculation:

TP and SL levels are derived using user-defined ATR multipliers for precise positioning.
Multipliers are flexible, allowing traders to adjust according to their strategies.
Risk-Reward Ratio (RRR):

Automatically calculates and displays the RRR for each trade signal.
Helps traders quickly assess if a trade aligns with their risk management plan.
Entry Conditions:

Buy signals occur when the closing price crosses above the 20-period Simple Moving Average (SMA).
Sell signals occur when the closing price crosses below the 20-period SMA.
Visual Aids:

Red and green lines indicate Stop Loss and Take Profit levels.
Blue and orange labels show the RRR for long and short trades, respectively.
How It Works:
The indicator uses the ATR to calculate TP and SL levels:
TP: Adjusted based on the desired Risk-Reward Ratio (RR).
SL: Proportional to the ATR multiplier.
Entry signals are plotted with "BUY" or "SELL" markers, while the respective TP/SL levels are drawn as horizontal lines.
Why Use This Indicator?
Perfect for traders who value precise risk management.
Helps identify trades with favorable RRR (e.g., greater than 1.5 or 2.0).
Ideal for swing traders, day traders, and scalpers looking to automate their decision-making process.
Customization:
ATR Length: Control the sensitivity of ATR-based calculations.
ATR Multipliers: Set the TP and SL distances relative to the ATR.
Desired RRR: Define the risk/reward ratio you aim to achieve.
Important Notes:
The indicator does not place trades automatically; it is for visual and analytical purposes.
Always backtest and combine it with additional analysis for best results.

[b]French[/b]

Cet indicateur combine la puissance de l’Average True Range (ATR) avec des calculs dynamiques pour les niveaux de Take Profit (TP) et de Stop Loss (SL), tout en offrant une visualisation claire des opportunités de trading et de leurs Ratios Risque/Rendement (RRR).

Fonctionnalités :
Calcul Dynamique des TP/SL :

Les niveaux de TP et SL sont calculés à l'aide de multiplicateurs ATR définis par l’utilisateur pour une position précise.
Les multiplicateurs sont personnalisables pour s'adapter à votre stratégie de trading.
Ratio Risque/Rendement (RRR) :

Calcule et affiche automatiquement le ratio RRR pour chaque signal de trade.
Permet aux traders d’évaluer rapidement si un trade correspond à leur plan de gestion des risques.
Conditions d'Entrée :

Les signaux d'achat apparaissent lorsque le prix de clôture traverse au-dessus de la moyenne mobile simple (SMA) à 20 périodes.
Les signaux de vente apparaissent lorsque le prix de clôture traverse en dessous de la SMA à 20 périodes.
Aides Visuelles :

Lignes rouges et vertes pour indiquer les niveaux de Stop Loss et de Take Profit.
Étiquettes bleues et orange pour afficher le RRR des trades longs et courts, respectivement.
Comment Cela Fonctionne :
L'indicateur utilise l’ATR pour calculer les niveaux TP et SL :
TP : Calculé dynamiquement en fonction du ratio risque/rendement souhaité (RRR).
SL : Proportionnel au multiplicateur ATR défini par l’utilisateur.
Les signaux d’entrée sont représentés par des étiquettes "BUY" ou "SELL", tandis que les niveaux de TP/SL sont tracés sous forme de lignes horizontales.
Pourquoi Utiliser Cet Indicateur ?
Idéal pour les traders soucieux d’une gestion rigoureuse des risques.
Identifie les opportunités de trades avec des RRR favorables (par exemple, supérieurs à 1.5 ou 2.0).
Convient aux swing traders, day traders et scalpeurs souhaitant automatiser leur processus de décision.
Personnalisation :
Longueur de l’ATR : Contrôlez la sensibilité des calculs basés sur l’ATR.
Multiplicateurs ATR : Ajustez les distances TP et SL par rapport à l’ATR.
Ratio RRR souhaité : Définissez le ratio risque/rendement que vous visez.
Remarques Importantes :
Cet indicateur n’exécute pas de trades automatiquement ; il est destiné à un usage visuel et analytique uniquement.
Toujours backtester et combiner avec une analyse supplémentaire pour de meilleurs résultats.

parametre par type de trading:

1. Pour les Scalpers :
Style de trading : Trades rapides sur de petites variations de prix, souvent sur des unités de temps courtes (1 min, 5 min).
Recommandations de paramètres :
ATR Length : 7 (plus court pour réagir rapidement à la volatilité).
Multiplicateur SL : 1.0 (Stop Loss proche pour limiter les pertes).
RR souhaité : 1.5 à 2.0 (bon équilibre entre risque et récompense).
Résultat attendu : Des trades fréquents, avec une probabilité raisonnable de toucher le TP tout en limitant les pertes.

2. Pour les Day Traders :
Style de trading : Trades qui durent plusieurs heures dans la journée, souvent sur des unités de temps moyennes (15 min, 1h).
Recommandations de paramètres :
ATR Length : 14 (standard pour capturer une volatilité modérée).
Multiplicateur SL : 1.5 (Stop Loss à distance raisonnable pour supporter les fluctuations intrajournalières).
RR souhaité : 2.0 à 3.0 (ciblez une bonne récompense par rapport au risque).
Résultat attendu : Moins de trades, mais un RR élevé pour compenser les pertes potentielles.

3. Pour les Swing Traders :
Style de trading : Trades qui durent plusieurs jours, souvent sur des unités de temps longues (4h, 1 jour).
Recommandations de paramètres :
ATR Length : 20 (pour capturer des mouvements de volatilité plus larges).
Multiplicateur SL : 2.0 (Stop Loss large pour supporter des fluctuations importantes).
RR souhaité : 3.0 ou plus (ciblez de gros mouvements de prix).
Résultat attendu : Des trades moins fréquents mais potentiellement très lucratifs.

4. Pour les Actifs Volatils (Crypto, Commodités) :
Problème spécifique : Les actifs volatils ont souvent des mouvements brusques.
Recommandations de paramètres :
ATR Length : 7 ou 10 (plus court pour suivre rapidement les variations).
Multiplicateur SL : 1.5 à 2.0 (assez large pour ne pas être déclenché prématurément).
RR souhaité : 1.5 à 2.0 (favorisez des récompenses réalistes sur des mouvements volatils).
Résultat attendu : Trades qui s’adaptent à la volatilité sans sortir trop tôt.

5. Pour les Marchés Stables (Indices, Actions Blue Chip) :
Problème spécifique : Les mouvements sont souvent lents et prévisibles.
Recommandations de paramètres :
ATR Length : 14 ou 20 (capture une volatilité modérée).
Multiplicateur SL : 1.0 à 1.5 (Stop Loss serré pour maximiser l’efficacité).
RR souhaité : 2.0 à 3.0 (ciblez des ratios plus élevés sur des mouvements moins fréquents).
Résultat attendu : Maximisation des profits sur des tendances claires.
Recommandation Générale :

Si vous ne savez pas par où commencer, utilisez ces paramètres par défaut :
ATR Length : 14
Multiplicateur SL : 1.5
RR souhaité : 2.0

## Source Code

````pine
//@version=5
indicator("ATR-based TP/SL with Dynamic RR", overlay=true)

// Paramètres
atrLength = input.int(14, "ATR Length")
desiredRR = input.float(2.0, "Desired RR (Take Profit / Stop Loss)")  // Ratio désiré
atrMultiplierSL = input.float(1.5, "ATR Multiplier for Stop Loss")  // Multiplicateur SL fixe

// Calcul de l'ATR
atr = ta.atr(atrLength)

// Calcul dynamique des multiplicateurs
atrMultiplierTP = desiredRR * atrMultiplierSL  // Calculer le multiplicateur TP à partir du RR

// Conditions d'entrée
longCondition = ta.crossover(close, ta.sma(close, 20))  // Clôture au-dessus de SMA 20
shortCondition = ta.crossunder(close, ta.sma(close, 20))  // Clôture en dessous de SMA 20

// Calcul des niveaux SL/TP
longSl = close - atrMultiplierSL * atr
longTp = close + atrMultiplierTP * atr
shortSl = close + atrMultiplierSL * atr
shortTp = close - atrMultiplierTP * atr

// Calcul du ratio Risque/Rendement
longRisk = close - longSl
longReward = longTp - close
longRR = longReward / longRisk

shortRisk = shortSl - close
shortReward = close - shortTp
shortRR = shortReward / shortRisk

// Gestion des lignes SL/TP
var line longSlLine = na
var line longTpLine = na
var line shortSlLine = na
var line shortTpLine = na

if (longCondition)
    // Supprimer les anciennes lignes si elles existent
    if (not na(longSlLine)) 
        line.delete(longSlLine)
    if (not na(longTpLine)) 
        line.delete(longTpLine)

    // Créer de nouvelles lignes pour SL et TP
    longSlLine := line.new(x1=bar_index, y1=longSl, x2=bar_index + 10, y2=longSl, color=color.red, width=2)
    longTpLine := line.new(x1=bar_index, y1=longTp, x2=bar_index + 10, y2=longTp, color=color.green, width=2)

    // Ajouter un label pour afficher le ratio RR
    label.new(x=bar_index, y=close, text="RR: " + str.tostring(longRR, "#.##"), style=label.style_circle, color=color.blue, textcolor=color.white)

if (shortCondition)
    // Supprimer les anciennes lignes si elles existent
    if (not na(shortSlLine)) 
        line.delete(shortSlLine)
    if (not na(shortTpLine)) 
        line.delete(shortTpLine)

    // Créer de nouvelles lignes pour SL et TP
    shortSlLine := line.new(x1=bar_index, y1=shortSl, x2=bar_index + 10, y2=shortSl, color=color.red, width=2)
    shortTpLine := line.new(x1=bar_index, y1=shortTp, x2=bar_index + 10, y2=shortTp, color=color.green, width=2)

    // Ajouter un label pour afficher le ratio RR
    label.new(x=bar_index, y=close, text="RR: " + str.tostring(shortRR, "#.##"), style=label.style_circle, color=color.orange, textcolor=color.white)

// Affichage des signaux d'entrée
plotshape(series=longCondition, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(series=shortCondition, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")
````
