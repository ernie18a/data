# The Octopus - Pullback Long Entry [EMA+MACD]

- url: https://www.tradingview.com/script/unKw2grX-The-Octopus-Pullback-Long-Entry-EMA-MACD/
- type: indicator
- pine_id: PUB;827d1273c0a74f048fc7be5d4e7be361
- version: 1.0

## Description

[b]Description:[/b]
Welcome to the Pullback Long Entry [EMA+MACD] indicator! If you love catching the perfect dip during a solid uptrend, this tool is designed exactly for you. Built with daytraders and trend-following investors in mind, this script takes the guesswork out of "buying the dip" by combining classic momentum indicators with smart price-action detection.

[b]🚀 How It Works[/b]
Instead of chasing breakouts, this strategy waits for the market to take a breather. It scans for a specific sequence of red candles (a pullback) within an established trend. Once a pullback is detected, it uses the confluence of EMA crossovers and MACD momentum to pinpoint the exact moment the buyers step back in.

[b]✨ Key Features[/b]
Smart Pullback Detection: Automatically counts red candles within a customizable lookback window to identify a genuine dip rather than just market noise.

[b]Multi-Tiered Signals: [/b]The indicator provides three levels of entry signals directly on your chart:

▲ Strong Long: The ultimate setup. Triggered by a confirmed pullback combining an EMA crossover and bullish MACD momentum.

△ Medium Long (long?): A calculated aggressive entry. Triggered by the first green candle after a sequence of red candles, backed by MACD support.

◇ Early Alert: A quick heads-up signal when the MACD histogram flips green while a pullback is still active. Time to put the ticker on your watchlist!

Dynamic Take Profit Levels: Automatically plots 3 customizable Take Profit (TP) lines (e.g., 0.20%, 0.50%, 1.00%) on your chart as soon as a Strong Long signal hits, helping you secure gains mechanically.

Ironclad Trend Filters: Optional toggles to ensure you only take long positions when the price is above the VWAP or the 200 EMA—keeping you strictly on the right side of the macro trend.

Real-Time Dashboard: A sleek, built-in HUD (Heads Up Display) table in the corner of your chart. It shows you exactly which conditions are currently met and gives the setup a dynamic "Score" out of 10.

[b]⚙️ Fully Customizable[/b]
Every trader is different, so everything in this script is adaptable to your timeframe and style:

Tweak the fast/slow/trend EMA lengths.

Adjust MACD parameters.

Define your own "pullback" criteria (number of minimum red candles and lookback window).

Set your own Take Profit percentages and display lengths.

Move or hide the dashboard as needed.

[b]🔔 Built-In Alerts[/b]
You don't need to stare at the screen all day. The script includes custom alert conditions for Strong Longs, Medium Longs, and Early Alerts so you can be notified exactly when your setup is ready to fire.

Add it to your chart, customize your parameters, and let's catch those perfect pullbacks! Happy trading! 📈

*** Disclaimer: This script is for educational and informational purposes only. Always backtest your strategies and manage your risk appropriately.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © Claude / Anthropic — Pullback Long Entry Signal
//@version=6
indicator("Pullback Long Entry [EMA+MACD]", overlay=true, max_labels_count=500, max_lines_count=500)

// ════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════

g1 = "EMA Settings"
eFast  = input.int(9,   "Fast EMA (bleu)",   minval=1,   group=g1)
eSlow  = input.int(20,  "Slow EMA (orange)", minval=1,   group=g1)
eTrend = input.int(200, "Trend EMA (200)",   minval=50,  group=g1)

g2 = "MACD Settings"
mFast = input.int(12, "MACD Fast",   minval=1, group=g2)
mSlow = input.int(26, "MACD Slow",   minval=1, group=g2)
mSig  = input.int(9,  "MACD Signal", minval=1, group=g2)

g3 = "Pullback Detection"
minRed   = input.int(5,  "Min Red Candles",     minval=2, maxval=20, group=g3)
lookback = input.int(12, "Lookback Window (bars)", minval=5, maxval=40, group=g3)

g4 = "Take Profit"
tp1Pct = input.float(0.20, "TP1 %", minval=0.05, step=0.05, group=g4)
tp2Pct = input.float(0.50, "TP2 %", minval=0.05, step=0.05, group=g4)
tp3Pct = input.float(1.00, "TP3 %", minval=0.05, step=0.05, group=g4)
showTP = input.bool(true,  "Afficher les lignes TP", group=g4)
tpBars = input.int(25, "Longueur TP lines (bars)", minval=5, maxval=200, group=g4)

g5 = "Filtres (optionnel)"
filterVWAP = input.bool(false, "Requiert prix > VWAP",    group=g5)
filter200  = input.bool(false, "Requiert prix > 200 EMA", group=g5)

g6 = "Tableau de bord"
showTable  = input.bool(true, "Afficher la boite", group=g6)
tblPosStr  = input.string(position.top_right, "Position de la boite",
    options=[position.top_left,    position.top_center,    position.top_right,
             position.middle_left, position.middle_center, position.middle_right,
             position.bottom_left, position.bottom_center, position.bottom_right],
    group=g6)

// ════════════════════════════════════════════════════════════════
// CALCULS DE BASE
// ════════════════════════════════════════════════════════════════

e9   = ta.ema(close, eFast)
e20  = ta.ema(close, eSlow)
e200 = ta.ema(close, eTrend)
vwapVal = ta.vwap(hlc3)
atr14   = ta.atr(14)

// Prix réel (non-synthétique) pour les niveaux TP — fonctionne correctement en mode Heikin Ashi
realClose = request.security(syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)

[macdLine, sigLine, hist] = ta.macd(close, mFast, mSlow, mSig)

// ════════════════════════════════════════════════════════════════
// CONDITIONS EMA
// ════════════════════════════════════════════════════════════════

emaCross = ta.crossover(e9, e20)   // 9 vient de croiser AU-DESSUS du 20
emaBull  = e9 > e20                // 9 est au-dessus du 20 (tendance haussière)

// ════════════════════════════════════════════════════════════════
// CONDITIONS MACD
// ════════════════════════════════════════════════════════════════

macdCross = ta.crossover(macdLine, sigLine)  // MACD vient de croiser au-dessus du signal
macdBull  = macdLine > sigLine               // MACD au-dessus du signal
histFlip  = hist > 0.0 and hist[1] <= 0.0   // Histogramme qui passe au vert

// ════════════════════════════════════════════════════════════════
// DÉTECTION DU PULLBACK
// ════════════════════════════════════════════════════════════════

// Nombre de chandelles rouges dans la fenêtre lookback
redInWindow = 0
for i = 1 to lookback
    if close[i] < open[i]
        redInWindow += 1

hadPullback = redInWindow >= minRed

// Séquence consécutive de chandelles rouges juste avant la bougie actuelle
streak = 0
for i = 1 to 15
    if close[i] < open[i]
        streak += 1
    else
        break

// Première chandelle verte après une séquence de rouges
firstGreen = streak >= minRed and close > open

// Chandelle actuelle haussière
bullCandle = close >= open

// ════════════════════════════════════════════════════════════════
// FILTRES
// ════════════════════════════════════════════════════════════════

aboveVWAP = close > vwapVal
above200  = close > e200
filterOK  = (not filterVWAP or aboveVWAP) and (not filter200 or above200)

// ════════════════════════════════════════════════════════════════
// SIGNAUX
// ════════════════════════════════════════════════════════════════

// SIGNAL FORT : EMA cross + MACD + pullback detecte
strongLong = filterOK and bullCandle and ((emaCross and (macdBull or macdCross) and hadPullback) or (macdCross and emaBull and firstGreen and hadPullback) or (emaCross and macdCross))

// SIGNAL MOYEN : premiere chandelle verte + MACD support
medLong = filterOK and not strongLong and bullCandle and (firstGreen and (macdBull or histFlip) and hadPullback)

// ALERTE PRECOCE : histogramme MACD passe vert pendant pullback
earlyAlert = filterOK and not strongLong and not medLong and (histFlip and hadPullback)

// ════════════════════════════════════════════════════════════════
// SCORE GLOBAL (0-9)
// ════════════════════════════════════════════════════════════════

score = (emaCross ? 2 : emaBull ? 1 : 0) + (macdCross ? 2 : macdBull ? 1 : 0) + (hadPullback ? 1 : 0) + (firstGreen ? 2 : 0) + (histFlip ? 1 : 0)

// ════════════════════════════════════════════════════════════════
// AFFICHAGE DES SIGNAUX SUR LE GRAPHIQUE
// ════════════════════════════════════════════════════════════════

if strongLong
    label.new(
        x         = bar_index,
        y         = low - atr14 * 0.8,
        text      = "▲ LONG",
        color     = color.new(color.lime, 0),
        textcolor = color.black,
        style     = label.style_label_up,
        size      = size.normal,
        tooltip   = "Score: " + str.tostring(score) + "/10\n" +
                    "Rouges: " + str.tostring(redInWindow) + "/" + str.tostring(minRed) + "\n" +
                    "EMA cross: " + (emaCross ? "OUI" : "non") + "\n" +
                    "MACD cross: " + (macdCross ? "OUI" : "non"))
    if showTP
        tp1 = realClose * (1.0 + tp1Pct / 100.0)
        tp2 = realClose * (1.0 + tp2Pct / 100.0)
        tp3 = realClose * (1.0 + tp3Pct / 100.0)
        line.new(bar_index, tp1, bar_index + tpBars, tp1,
            color=color.new(#00ff88, 10), width=1, style=line.style_dashed)
        line.new(bar_index, tp2, bar_index + tpBars, tp2,
            color=color.new(#00cc66, 10), width=2, style=line.style_dashed)
        line.new(bar_index, tp3, bar_index + tpBars, tp3,
            color=color.new(#009944, 10), width=2, style=line.style_solid)
        label.new(bar_index + tpBars, tp1,
            text="TP1 +" + str.tostring(tp1Pct, "#.##") + "%",
            color=color.new(#00ff88, 60), textcolor=color.white,
            style=label.style_label_left, size=size.tiny)
        label.new(bar_index + tpBars, tp2,
            text="TP2 +" + str.tostring(tp2Pct, "#.##") + "%",
            color=color.new(#00cc66, 60), textcolor=color.white,
            style=label.style_label_left, size=size.tiny)
        label.new(bar_index + tpBars, tp3,
            text="TP3 +" + str.tostring(tp3Pct, "#.##") + "%",
            color=color.new(#009944, 60), textcolor=color.white,
            style=label.style_label_left, size=size.tiny)

if medLong
    label.new(
        x         = bar_index,
        y         = low - atr14 * 0.5,
        text      = "△ long?",
        color     = color.new(color.aqua, 30),
        textcolor = color.black,
        style     = label.style_label_up,
        size      = size.small,
        tooltip   = "1ère verte après " + str.tostring(streak) + " rouges\nMACD: " + (macdCross ? "cross ↑" : "haussier"))

if earlyAlert
    label.new(
        x         = bar_index,
        y         = low - atr14 * 0.2,
        text      = "◇",
        color     = color.new(color.yellow, 50),
        textcolor = color.black,
        style     = label.style_label_up,
        size      = size.tiny,
        tooltip   = "MACD histo passe au vert — pullback actif. Surveiller l'entrée.")

// Fond rouge doux pendant les pullbacks (avant signal)
bgcolor(hadPullback and not emaBull and not strongLong ? color.new(color.red, 93) : na, title="Zone pullback")

// ════════════════════════════════════════════════════════════════
// TABLEAU DE BORD (coin supérieur droit)
// ════════════════════════════════════════════════════════════════

var tbl = table.new(tblPosStr, 2, 9,
    bgcolor      = color.new(color.black, 60),
    border_color = color.new(color.gray, 50),
    border_width = 1,
    frame_color  = color.new(color.gray, 30),
    frame_width  = 1)

if barstate.islast and showTable
    // En-tête
    table.cell(tbl, 0, 0, "CONDITIONS",
        text_color=color.silver, text_size=size.small,
        bgcolor=color.new(color.navy, 50))
    table.cell(tbl, 1, 0, "ÉTAT",
        text_color=color.silver, text_size=size.small,
        bgcolor=color.new(color.navy, 50))

    // Signal principal
    sigTxt   = strongLong ? "▲ FORT LONG" : medLong ? "△ moyen" : earlyAlert ? "◇ alerte" : "—"
    sigColor = strongLong ? color.lime     : medLong ? color.yellow : earlyAlert ? color.orange : color.gray
    table.cell(tbl, 0, 1, "Entrée Long",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 1, sigTxt,
        text_color=sigColor, text_size=size.small)

    // EMA 9/20
    emaTxt   = emaCross ? "CROSS ↑ ✓" : emaBull ? "9 > 20 ✓" : "9 < 20 ✗"
    emaColor = emaCross ? color.lime   : emaBull  ? color.green : color.red
    table.cell(tbl, 0, 2, "EMA 9/20",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 2, emaTxt,
        text_color=emaColor, text_size=size.small)

    // MACD
    macdTxt   = macdCross ? "CROSS ↑ ✓" : macdBull ? "haussier ✓" : "baissier ✗"
    macdColor = macdCross ? color.lime   : macdBull  ? color.green  : color.red
    table.cell(tbl, 0, 3, "MACD",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 3, macdTxt,
        text_color=macdColor, text_size=size.small)

    // Pullback
    pbTxt   = str.tostring(redInWindow) + " rouges / " + str.tostring(minRed) + " min" + (hadPullback ? " ✓" : " ✗")
    pbColor = hadPullback ? color.lime : color.orange
    table.cell(tbl, 0, 4, "Pullback",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 4, pbTxt,
        text_color=pbColor, text_size=size.small)

    // Première verte
    fgTxt   = firstGreen ? "Oui ✓ (après " + str.tostring(streak) + ")" : "Non"
    fgColor = firstGreen ? color.lime : color.gray
    table.cell(tbl, 0, 5, "1ère verte",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 5, fgTxt,
        text_color=fgColor, text_size=size.small)

    // VWAP
    vwapTxt   = aboveVWAP ? "Au-dessus ✓" : "En-dessous"
    vwapColor = aboveVWAP ? color.lime : color.red
    table.cell(tbl, 0, 6, "VWAP",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 6, vwapTxt,
        text_color=vwapColor, text_size=size.small)

    // 200 EMA
    e200Txt   = above200 ? "Au-dessus ✓" : "En-dessous"
    e200Color = above200 ? color.lime : color.red
    table.cell(tbl, 0, 7, "200 EMA",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 7, e200Txt,
        text_color=e200Color, text_size=size.small)

    // Score
    scoreTxt   = str.tostring(score) + " / 10"
    scoreColor = score >= 7 ? color.lime : score >= 5 ? color.yellow : color.red
    table.cell(tbl, 0, 8, "Score",
        text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 8, scoreTxt,
        text_color=scoreColor, text_size=size.small)

// ════════════════════════════════════════════════════════════════
// ALERTES
// ════════════════════════════════════════════════════════════════

alertcondition(strongLong,  "▲ Long Fort",     "ENTRÉE LONG — EMA cross + MACD + pullback")
alertcondition(medLong,     "△ Long Moyen",    "Potentielle entrée — 1ère verte après pullback")
alertcondition(earlyAlert,  "◇ Alerte Précoce","MACD histo vert — pullback en cours, surveiller")
````
