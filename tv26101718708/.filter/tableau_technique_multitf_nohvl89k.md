# Tableau Technique Multi-TF

- url: https://www.tradingview.com/script/nOHVl89K/
- type: indicator
- pine_id: PUB;9ad828f31af8404a9abd6d5b29da32b6
- version: 1.0

## Description

The 4-hour timeframe is now fully integrated into the table, using the same signal logic (RSI + EMA crossover) as the other timeframes. The table will display signals like:

    "Achat Fort" / "Vente Forte" (strong buy/sell)
    "Achat" / "Vente" (buy/sell)
    "Neutre" (neutral).

Great job! The script is now complete with support for 1m, 5m, 15m, 30m, 1h, and 4h timeframes.

## Source Code

````pine
//@version=6
indicator("Tableau Technique Multi-TF", overlay=true)

// --- PARAMÈTRES ---
rsiLength = input.int(14, "Période RSI", minval=1)
emaLength = input.int(20, "Période EMA", minval=1)

// --- FONCTION DE CALCUL DES SIGNAUX ---
// Cette fonction définit la logique de signal
get_signal(tf) =>
    // Récupération des données pour l'unité de temps spécifiée
    s_close = request.security(syminfo.tickerid, tf, close)
    s_rsi   = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLength))
    s_ema   = request.security(syminfo.tickerid, tf, ta.ema(close, emaLength))

    string signal = "Neutre"
    color  c_bg   = color.gray

    if s_rsi > 60 and s_close > s_ema
        signal := "Achat Fort"
        c_bg   := color.new(color.green, 20)
    else if s_rsi > 50 or s_close > s_ema
        signal := "Achat"
        c_bg   := color.new(color.green, 60)
    else if s_rsi < 40 and s_close < s_ema
        signal := "Vente Forte"
        c_bg   := color.new(color.red, 20)
    else if s_rsi < 50 or s_close < s_ema
        signal := "Vente"
        c_bg   := color.new(color.red, 60)

    [signal, c_bg]

// --- RÉCUPÉRATION DES SIGNAUX ---
[s1m, c1m]   = get_signal("1")
[s5m, c5m]   = get_signal("5")
[s15m, c15m] = get_signal("15")
[s30m, c30m] = get_signal("30")
[s1h, c1h]   = get_signal("60")
[s4h, c4h]   = get_signal("240")

// --- CRÉATION DU TABLEAU ---
var table mainTable = table.new(position.top_right, 2, 7, border_width = 1)

if barstate.islast
    // Entêtes
    table.cell(mainTable, 0, 0, "Timeframe", bgcolor=color.gray, text_color=color.white)
    table.cell(mainTable, 1, 0, "Signal",    bgcolor=color.gray, text_color=color.white)

    // Ligne 1m
    table.cell(mainTable, 0, 1, "1 min",  bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 1, s1m,      bgcolor=c1m,   text_color=color.white)

    // Ligne 5m
    table.cell(mainTable, 0, 2, "5 min",  bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 2, s5m,      bgcolor=c5m,   text_color=color.white)

    // Ligne 15m
    table.cell(mainTable, 0, 3, "15 min", bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 3, s15m,     bgcolor=c15m,  text_color=color.white)

    // Ligne 30m
    table.cell(mainTable, 0, 4, "30 min", bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 4, s30m,     bgcolor=c30m,  text_color=color.white)

    // Ligne 1h
    table.cell(mainTable, 0, 5, "1 heure", bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 5, s1h,      bgcolor=c1h,   text_color=color.white)

    // Ligne 4h
    table.cell(mainTable, 0, 6, "4 heures", bgcolor=color.black, text_color=color.white)
    table.cell(mainTable, 1, 6, s4h,      bgcolor=c4h,   text_color=color.white)
````
