# Indicateur PhR v8 3bougies Solde 

- url: https://www.tradingview.com/script/rcLqimvg/
- type: indicator
- pine_id: PUB;805455ef2fc44db2ae79311c249e8c32
- version: 1.0

## Description

Cet indicateur prend le franchissement de deux EMA de votre choix comme indice de momentum haussier et baissier. Un filtre ADX modulable permet d'éviter les faux signaux liés aux phases de range.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rocfil

//@version=6
indicator("Indicateur PhR v8 3bougies Solde ", overlay=true)
plot(close)
//@version=5

// ==========================================
// 1. PARAMÈTRES (INPUTS MODIFIABLES)
// ==========================================
// Gestion des Moyennes Mobiles
ema_fast_len = input.int(20, title="Période EMA Rapide (ex: 20 ou 19)", group="Moyennes Mobiles")
ema_slow_len = input.int(50, title="Période EMA Lente (ex: 50 ou 51)", group="Moyennes Mobiles")
sma_trend_len = input.int(200, title="Période SMA Tendance", group="Moyennes Mobiles")

// Gestion de l'ADX (Filtre Anti-Range)
adx_len       = input.int(14, title="Période de l'ADX", group="Filtre Anti-Range (ADX)")
adx_threshold = input.float(20.0, title="Seuil Minimum ADX", step=0.5, group="Filtre Anti-Range (ADX)")

// Gestion des Ratios Risque / Récompense (Réglables à la décimale près)
rr_trend    = input.float(2.5, title="Ratio R:R (Dans le sens SMA 200)", step=0.1, group="Gestion du Risque")
rr_counter  = input.float(1.0, title="Ratio R:R (Contre SMA 200)", step=0.1, group="Gestion du Risque")

// Configuration du Capital
initial_capital = input.float(100000.0, title="Capital de Départ ($)", group="Gestion du Capital / Risque")
risk_percent    = input.float(1.0, title="Risque par Trade (%)", step=0.1, group="Gestion du Capital / Risque")

// ==========================================
// 2. CALCULS DES INDICATEURS CORPS
// ==========================================
ema_fast  = ta.ema(close, ema_fast_len)
ema_slow  = ta.ema(close, ema_slow_len)
sma_trend = ta.sma(close, sma_trend_len)

// Calcul officiel de l'ADX
[_, _, adx_value] = ta.dmi(adx_len, adx_len)

// Canal d'écart entre les deux EMA
upper_ema_band = math.max(ema_fast, ema_slow)
lower_ema_band = math.min(ema_fast, ema_slow)

// Détection du début de la traversée du canal
started_buy_crossing  = (close[1] <= lower_ema_band[1] and close > lower_ema_band)
started_sell_crossing = (close[1] >= upper_ema_band[1] and close < upper_ema_band)

// Compteur de bougies depuis le début de la traversée
bars_since_buy_start  = ta.barssince(started_buy_crossing)
bars_since_sell_start = ta.barssince(started_sell_crossing)

// Tendance active si l'ADX est au-dessus du seuil
adx_trend_active = adx_value > adx_threshold

// ==========================================
// 3. LOGIQUE DES SIGNAUX (FRANCHISSEMENT DIRECT + FILTRE ADX)
// ==========================================
cross_up = ta.crossover(close, upper_ema_band)
cross_down = ta.crossunder(close, lower_ema_band)

buy_signal  = cross_up and adx_trend_active
sell_signal = cross_down and adx_trend_active

// ==========================================
// 4. AFFICHAGE DES NIVEAUX ET ÉTIQUETTES (DERNIER TRADE)
// ==========================================
plot(ema_fast, color=color.aqua, title="EMA Rapide")
plot(ema_slow, color=color.orange, title="EMA Lente")
plot(sma_trend, color=color.white, linewidth=2, title="SMA Tendance 200")

var line entry_line = na
var line sl_line = na
var line tp_line = na
var label entry_lbl = na
var label sl_lbl = na
var label tp_lbl = na

if buy_signal or sell_signal
    line.delete(entry_line)
    line.delete(sl_line)
    line.delete(tp_line)
    label.delete(entry_lbl)
    label.delete(sl_lbl)
    label.delete(tp_lbl)
    
    float entry_p = close
    float sl_p    = na
    
    if buy_signal
        int idx = not na(bars_since_buy_start) ? bars_since_buy_start : 0
        sl_p := math.min(lower_ema_band[idx], low[idx])
        
    if sell_signal
        int idx = not na(bars_since_sell_start) ? bars_since_sell_start : 0
        sl_p := math.max(upper_ema_band[idx], high[idx])

    float risk = math.abs(entry_p - sl_p)
    float current_rr = buy_signal ? (close > sma_trend ? rr_trend : rr_counter) : (close < sma_trend ? rr_trend : rr_counter)
    float tp_p    = buy_signal ? entry_p + (risk * current_rr) : entry_p - (risk * current_rr)

    // Tracé des lignes projetées
    entry_line := line.new(bar_index, entry_p, bar_index + 5, entry_p, color=color.blue, width=2)
    sl_line    := line.new(bar_index, sl_p, bar_index + 5, sl_p, color=color.red, width=2, style=line.style_dashed)
    tp_line    := line.new(bar_index, tp_p, bar_index + 5, tp_p, color=color.green, width=2, style=line.style_dashed)
    
    // Étiquettes de prix
    entry_lbl  := label.new(bar_index + 5, entry_p, "Entrée: " + str.tostring(entry_p, "#.#####"), color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
    sl_lbl     := label.new(bar_index + 5, sl_p, "SL: " + str.tostring(sl_p, "#.#####"), color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    tp_lbl     := label.new(bar_index + 5, tp_p, "TP: " + str.tostring(tp_p, "#.#####"), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)

if not na(entry_line) and not (buy_signal or sell_signal)
    line.set_x2(entry_line, bar_index)
    line.set_x2(sl_line, bar_index)
    line.set_x2(tp_line, bar_index)
    label.set_x(entry_lbl, bar_index)
    label.set_x(sl_lbl, bar_index)
    label.set_x(tp_lbl, bar_index)

plotshape(buy_signal, title="Signal Achat", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sell_signal, title="Signal Vente", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ==========================================
// 5. SIMULATION AVEC INTÉRÊTS COMPOSÉS ET VISU TP
// ==========================================
var int active_trade = 0 
var float sim_entry = 0.0
var float sim_sl = 0.0
var float sim_tp = 0.0
var float trade_rr = 0.0
var int entry_bar_index = na 

var float account_balance = initial_capital
var float[] historic_r_multiples = array.new_float(0)

record_trade(float r_multiplier) =>
    array.push(historic_r_multiples, r_multiplier)
    if array.size(historic_r_multiples) > 500
        array.shift(historic_r_multiples)

// Suivi et dénouement des trades
if active_trade == 1
    if low <= sim_sl
        float loss_cash = account_balance * (risk_percent / 100)
        account_balance := account_balance - loss_cash
        record_trade(-1.0)
        active_trade := 0
        entry_bar_index := na 
    else if high >= sim_tp
        float win_cash = account_balance * (risk_percent / 100) * trade_rr
        account_balance := account_balance + win_cash
        record_trade(trade_rr)
        
        label.new(x=bar_index, y=na, text="★", yloc=yloc.abovebar, style=label.style_none, textcolor=color.yellow, size=size.normal)
        
        line.new(entry_bar_index, sim_tp, bar_index, sim_tp, color=color.new(color.gray, 50), width=1, style=line.style_dotted)
        active_trade := 0
        entry_bar_index := na 
else if active_trade == -1
    if high >= sim_sl
        float loss_cash = account_balance * (risk_percent / 100)
        account_balance := account_balance - loss_cash
        record_trade(-1.0)
        active_trade := 0
        entry_bar_index := na 
    else if low <= sim_tp
        float win_cash = account_balance * (risk_percent / 100) * trade_rr
        account_balance := account_balance + win_cash
        record_trade(trade_rr)
        
        label.new(x=bar_index, y=na, text="★", yloc=yloc.belowbar, style=label.style_none, textcolor=color.yellow, size=size.normal)
        
        line.new(entry_bar_index, sim_tp, bar_index, sim_tp, color=color.new(color.gray, 50), width=1, style=line.style_dotted)
        active_trade := 0
        entry_bar_index := na 

// Initialisation virtuelle
if active_trade == 0
    if buy_signal
        active_trade := 1
        sim_entry := close
        entry_bar_index := bar_index 
        int idx = not na(bars_since_buy_start) ? bars_since_buy_start : 0
        sim_sl := math.min(lower_ema_band[idx], low[idx])
        trade_rr := close > sma_trend ? rr_trend : rr_counter
        sim_tp := close + (math.abs(close - sim_sl) * trade_rr)
    else if sell_signal
        active_trade := -1
        sim_entry := close
        entry_bar_index := bar_index 
        int idx = not na(bars_since_sell_start) ? bars_since_sell_start : 0
        sim_sl := math.max(upper_ema_band[idx], high[idx])
        trade_rr := close < sma_trend ? rr_trend : rr_counter
        sim_tp := close - (math.abs(sim_sl - close) * trade_rr)

// ==========================================
// 6. CALCUL ET CONFIGURATION DU TABLEAU DES STATS
// ==========================================
var table score_table = table.new(position.bottom_right, 2, 5, bgcolor=color.new(color.black, 15), border_color=color.gray, border_width=1)

if barstate.islast
    int total_trades = array.size(historic_r_multiples)
    int wins = 0
    float gross_r_profits = 0.0
    float gross_r_losses = 0.0
    
    if total_trades > 0
        for i = 0 to total_trades - 1
            float r_pnl = array.get(historic_r_multiples, i)
            if r_pnl > 0
                gross_r_profits += r_pnl
                wins += 1
            else
                gross_r_losses += math.abs(r_pnl)

    float win_rate = total_trades > 0 ? (wins / total_trades) * 100 : 0.0
    float profit_factor = gross_r_losses > 0 ? gross_r_profits / gross_r_losses : (gross_r_profits > 0 ? 99.0 : 0.0)
    
    table.cell(score_table, 0, 0, "Échantillon (500 Max)", text_color=color.white, bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(score_table, 1, 0, "Statistiques", text_color=color.white, bgcolor=color.new(color.navy, 30), text_size=size.small)
    
    table.cell(score_table, 0, 1, "Nombre de Trades", text_color=color.white, text_size=size.small)
    table.cell(score_table, 1, 1, str.tostring(total_trades), text_color=color.yellow, text_size=size.small)
    
    table.cell(score_table, 0, 2, "Taux de Réussite", text_color=color.white, text_size=size.small)
    table.cell(score_table, 1, 2, str.tostring(win_rate, "#.#") + "%", text_color=win_rate >= 50 ? color.green : color.red, text_size=size.small)
    
    table.cell(score_table, 0, 3, "Taux de Profit (PF)", text_color=color.white, text_size=size.small)
    string pf_display = profit_factor >= 99.0 ? "∞" : str.tostring(profit_factor, "#.##")
    table.cell(score_table, 1, 3, pf_display, text_color=profit_factor >= 1.0 ? color.green : color.red, text_size=size.small)
    
    table.cell(score_table, 0, 4, "Solde Final", text_color=color.white, text_size=size.small)
    table.cell(score_table, 1, 4, "$" + str.tostring(account_balance, "#,###.##"), text_color=account_balance >= initial_capital ? color.green : color.red, text_size=size.small)
````
