# 4H Range Scalp V3 - Smart Fakeout

- url: https://www.tradingview.com/script/MfYqi6rS/
- type: strategy
- pine_id: PUB;7863e40f16ba4d178c32d4a872b2e56f
- version: 1.0

## Description

Mettez bien ce script sur le graphique 5 minutes. V

## Source Code

````pine
// @version=5
strategy("4H Range Scalp V3 - Smart Fakeout", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- 1. PARAMÈTRES ---
rr_ratio = input.float(2.0, title="Ratio Risk/Reward")
max_bars_outside = input.int(6, title="Bougies max hors du range", tooltip="Si le prix reste dehors plus de X bougies (ex: 30 min), ce n'est plus un fakeout.")
max_sl_atr = input.float(2.5, title="Filtre Cassure Géante (ATR)", tooltip="Ignore le trade si la mèche de cassure est ridiculement grande.")
use_ema = input.bool(true, title="Filtre Tendance (EMA 200)")

// --- 2. INDICATEURS DE FOND ---
atr = ta.atr(14)
ema200 = ta.ema(close, 200)

// --- 3. GESTION DU RANGE 4H (Heure NY Stricte) ---
// On utilise la timezone "America/New_York" pour que ça marche peu importe où vous habitez
ny_time = time(timeframe.period, "0000-0400", "America/New_York")
in_window = not na(ny_time)

var float r_high = na
var float r_low = na
var float temp_h = na
var float temp_l = na

// Reset chaque nouveau jour à minuit (NY)
if ta.change(time("D", "", "America/New_York"))
    temp_h := na
    temp_l := na
    r_high := na
    r_low := na

// Capture du range
if in_window
    temp_h := math.max(high, na(temp_h) ? high : temp_h)
    temp_l := math.min(low, na(temp_l) ? low : temp_l)
else if in_window[1] and not in_window
    r_high := temp_h
    r_low := temp_l

plot(r_high, "Range High", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=2)
plot(r_low, "Range Low", color=color.new(color.green, 30), style=plot.style_linebr, linewidth=2)
plot(use_ema ? ema200 : na, "EMA 200", color=color.white)

// --- 4. LOGIQUE DE FAKEOUT INTELLIGENT ---
var int bars_out_high = 0
var int bars_out_low = 0
var float ext_high = na
var float ext_low = na
var bool traded_high = false
var bool traded_low = false

// Reset des limites quotidiennes de trade
if ta.change(time("D", "", "America/New_York"))
    traded_high := false
    traded_low := false
    bars_out_high := 0
    bars_out_low := 0

// SCÉNARIO 1 : CASSURE À LA HAUSSE (Recherche de Vente)
if not na(r_high)
    if close > r_high
        bars_out_high += 1
        ext_high := math.max(high, na(ext_high) ? high : ext_high) // Enregistre le sommet
    else if bars_out_high > 0 and close < r_high // Le prix réintègre
        
        // Filtres de Qualité
        valid_time = bars_out_high <= max_bars_outside
        valid_trend = not use_ema or close < ema200
        risk = ext_high - close
        valid_sl = risk < (atr * max_sl_atr) and risk > 0
        
        if valid_time and valid_trend and valid_sl and not traded_high
            tp = close - (risk * rr_ratio)
            strategy.entry("Fakeout Short", strategy.short)
            strategy.exit("Exit Short", "Fakeout Short", stop=ext_high, limit=tp)
            traded_high := true // On ne trade cette ligne qu'une fois par jour
            
        // Reset après réintégration
        bars_out_high := 0
        ext_high := na

// SCÉNARIO 2 : CASSURE À LA BAISSE (Recherche d'Achat)
if not na(r_low)
    if close < r_low
        bars_out_low += 1
        ext_low := math.min(low, na(ext_low) ? low : ext_low) // Enregistre le creux
    else if bars_out_low > 0 and close > r_low // Le prix réintègre
        
        // Filtres de Qualité
        valid_time = bars_out_low <= max_bars_outside
        valid_trend = not use_ema or close > ema200
        risk = close - ext_low
        valid_sl = risk < (atr * max_sl_atr) and risk > 0
        
        if valid_time and valid_trend and valid_sl and not traded_low
            tp = close + (risk * rr_ratio)
            strategy.entry("Fakeout Long", strategy.long)
            strategy.exit("Exit Long", "Fakeout Long", stop=ext_low, limit=tp)
            traded_low := true // On ne trade cette ligne qu'une fois par jour
            
        // Reset après réintégration
        bars_out_low := 0
        ext_low := na
````
