# Secure BTC 5m Scalper Pro V6  Dynamic Institutional Flow

- url: https://www.tradingview.com/script/LusIfBDb/
- type: indicator
- pine_id: PUB;589d0cd8f4944f24bee13389b5de7476
- version: 1.0

## Description

Overview
Secure BTC 5m Scalper Pro V6 is an institutional-grade, high-probability scalping engine engineered specifically for low-timeframe environments (3m/5m). Built on top of a secured trend-following framework, this version introduces the "5-Star Combo Block"—a real-time data matrix that mathematical scans the last 20 candles to filter out low-volume weekend traps, false breakouts, and retail noise.

Equipped with a highly responsive, custom-built HUD (Heads-Up Display), this tool delivers complete market context at a single glance without cluttering your workspace.

Key Features
Secured Momentum Engine: Utilizes an optimized Supertrend filter combined with a major 200 EMA baseline to trade strictly in the direction of the institutional trend.

The 20-Candle Multi-Metric Scanner: Automatically runs 5 algorithmic checks in the background on every single tick:

Market Flux: Quantifies buyer vs. seller control by checking candle close distribution ratios.

Volatility Impulsion: Measures current body size expansions against a localized ATR baseline to detect explosive breakouts.

Structure Tracker: Implements Dow Theory principles to immediately flag whether the immediate price action is Bullish, Bearish, or stuck in a horizontal Range.

Volume Delta: Approximates localized buying/selling order book pressure by cross-referencing price spreads against volume nodes.

Zone Value (VWAP): Identifies premium vs. discount pricing relative to the institutional volume-weighted average price.

Anti-Wick Risk Management: Dynamically places custom Stop Loss targets by scanning the extreme structural pivots over the last 3 candles and adding localized volatility padding.

Fully Modulable Dashboard: Change positioning (Top, Bottom, Middle) and scale down font sizing dynamically directly from the UI settings menu—fully optimized for iPad, laptop, and multi-screen setups.

How to Use the 5-Star Combo HUD
The script features a live-updating section titled --- LIVE 20b ACTUEL ---. The dashboard fields will dynamically switch background colors based on market conditions:

🟢 Bright Green Cell: Immediate bullish confirmation.

🔴 Bright Red Cell: Immediate bearish confirmation.

⚪ Dark Gray Cell: Flat, neutral, or non-trending market context.

🎯 The Confirmation Rule
When a flashing "GO" signal prints on your chart:

For a LONG Signal: Verify that the live section shows a strong dominance of Green Cells (Bullish Structure, High Volume Delta, Over 55% Buyer Flux).

For a SHORT Signal: Verify that the live section shows a heavy confluence of Red Cells (Bearish Structure, Seller Volume Delta, Under 45% Buyer Flux).

The Filter: If you see a cluster of Gray Cells (Range / Neutral / Mou / Flat), the algorithm is identifying a low-liquidity environment or typical weekend chop. Stay out and preserve capital.

Settings & Configuration
Trend Sensitivity: Tweak the Supertrend factors and baseline EMA lengths to fit your personal execution style.

ADX Threshold Filter: Set your minimum directional index threshold (Recommended: 18) to ensure the engine only fires during real trend expansions.

Execution Modes: Toggle between a localized Fibonacci Extension target (1.618) for aggressive trending days or a strict Manual Risk-to-Reward ratio for mechanical, consistent scalp compounding.

UI Customization: Shift position and scale table parameters inside the "4. Design Tableau" section.

*** ### Disclaimer
Past performance does not guarantee future results. Scalping involves high execution speed and precise risk control. Always test strategy parameters on a demo account before risking live capital.

## Source Code

````pine
//@version=6
indicator("Stratégie SÉCURISÉE: BTC 5m Scalper Pro V6 - FINAL MAX", overlay=true, format=format.price)

// --- 1. SETTINGS ---
factor = input.float(3.0, "Sensibilité Supertrend", step=0.1, group="1. Tendance") 
atrPeriod = input.int(12, "Période Supertrend", group="1. Tendance")
emaLength = input.int(200, "EMA de Fond", group="1. Tendance")

adxThreshold = input.int(18, "Seuil ADX", minval=1, group="2. Filtres") 
useRSI = input.bool(true, "Filtre RSI (>50/<50)", group="2. Filtres")

useFibTarget = input.bool(false, "Utiliser TP Fib (1.618)", group="3. Exécution")
tp_ratio_manual = input.float(1.5, "Ratio R:R Manuel", step=0.1, group="3. Exécution")
sl_padding = input.float(1.5, "Marge SL (Multiplier ATR - Anti-Mèche)", step=0.1, group="3. Exécution")

actual_ratio = useFibTarget ? 1.618 : tp_ratio_manual

// --- CONFIGURATION DU TABLEAU ---
dash_pos = input.string("Bas Droite", "Position du Tableau", options=["Haut Droite", "Haut Gauche", "Bas Droite", "Bas Gauche", "Milieu Droite"], group="4. Design Tableau")
dash_size = input.string("Normal", "Taille Globale", options=["Auto", "Très Petit", "Petit", "Normal", "Grand"], group="4. Design Tableau")
text_size_20b = input.string("Petit", "Taille Zone 20b", options=["Très Petit", "Petit", "Normal"], group="4. Design Tableau")

// Traductions des inputs pour le code Pine Script v6
pos_table = dash_pos == "Haut Droite" ? position.top_right : (dash_pos == "Haut Gauche" ? position.top_left : (dash_pos == "Bas Gauche" ? position.bottom_left : (dash_pos == "Milieu Droite" ? position.middle_right : position.bottom_right)))
size_table = dash_size == "Très Petit" ? size.tiny : (dash_size == "Petit" ? size.small : (dash_size == "Grand" ? size.large : (dash_size == "Auto" ? size.auto : size.normal)))
size_custom_20b = text_size_20b == "Très Petit" ? size.tiny : (text_size_20b == "Normal" ? size.normal : size.small)

// --- 2. CALCULS ---
[supertrend, direction] = ta.supertrend(factor, atrPeriod)
emaFilter = ta.ema(close, emaLength)
atrValue = ta.atr(14)
rsiValue = ta.rsi(close, 14)
[diplus, minus, adxValue] = ta.dmi(14, 14)

// Signaux au moment T
rawLong = ta.crossover(close, supertrend) and close > emaFilter
rawShort = ta.crossunder(close, supertrend) and close < emaFilter

rsiOkLong = useRSI ? (rsiValue > 50) : true
rsiOkShort = useRSI ? (rsiValue < 50) : true
adxOk = adxValue > adxThreshold 

// --- 3. LOGIQUE DE SIGNAL ---
goLong = rawLong[1] and rsiOkLong[1] and adxOk[1]
goShort = rawShort[1] and rsiOkShort[1] and adxOk[1]

// --- 4. COULEURS BOUGIES ---
flashyGreen = #00FF00
flashyPink = #FF00FF
barcolor(goLong ? flashyGreen : goShort ? flashyPink : na, title="Bougie Signal")

// --- 5. GESTION DES ENTRÉES ET DU RISQUE ---
var float lastEntry = na
var float lastSL = na
var float lastTP = na
var float lastRSI = na  
var int lastTime = na
var string lastType = "ATTENTE"

if goLong
    lastEntry := open 
    float lowestLow = math.min(low[1], math.min(low[2], low[3]))
    lastSL := lowestLow - (atrValue[1] * sl_padding) 
    float risk = lastEntry - lastSL
    lastTP := lastEntry + (risk * actual_ratio)
    lastTime := time
    lastType := "LONG"
    lastRSI := rsiValue[1] 

if goShort
    lastEntry := open 
    float highestHigh = math.max(high[1], math.max(high[2], high[3]))
    lastSL := highestHigh + (atrValue[1] * sl_padding) 
    float risk = lastSL - lastEntry
    lastTP := lastEntry - (risk * actual_ratio)
    lastTime := time
    lastType := "SHORT"
    lastRSI := rsiValue[1] 

// --- 6. CALCULS DU COMBO 5 ÉTOILES (SUR 20 BOUGIES) ---
lookback_period = 20

// Couleurs de fond opaques
bg_green = color.new(color.green, 20)
bg_red = color.new(color.red, 20)
bg_gray = color.new(color.gray, 70)

// 1. Calcul du Flux (% de bougies haussières)
bull_count = 0
for i = 0 to lookback_period - 1
    if close[i] > open[i]
        bull_count := bull_count + 1
bull_percentage = (bull_count / lookback_period) * 100
flux_text = str.tostring(math.round(bull_percentage)) + "% ACH"
color flux_bg_col = bull_percentage > 55 ? bg_green : (bull_percentage < 45 ? bg_red : bg_gray)
color flux_text_col = bull_percentage > 55 or bull_percentage < 45 ? color.white : color.silver

// 2. Calcul de la Volatilité
body_size_avg = 0.0
for i = 0 to lookback_period - 1
    body_size_avg := body_size_avg + math.abs(close[i] - open[i])
body_size_avg := body_size_avg / lookback_period
atr_filter = ta.atr(lookback_period)
bool is_impulsion = body_size_avg > (atr_filter * 0.4)
vol_text = is_impulsion ? "IMPULSION" : "MOU / FLAT"
color vol_bg_col = is_impulsion ? bg_green : bg_gray
color vol_text_col = is_impulsion ? color.white : color.silver

// 3. Calcul de la Structure (Loi de Dow sur 20 bougies)
is_bullish_struct = ta.highest(high, 5) >= ta.highest(high, lookback_period)[5] and ta.lowest(low, 5) >= ta.lowest(low, lookback_period)[5]
is_bearish_struct = ta.highest(high, 5) <= ta.highest(high, lookback_period)[5] and ta.lowest(low, 5) <= ta.lowest(low, lookback_period)[5]
struct_text = is_bullish_struct ? "HAUSSIÈRE" : (is_bearish_struct ? "BAISSIÈRE" : "RANGE")
color struct_bg_col = is_bullish_struct ? bg_green : (is_bearish_struct ? bg_red : bg_gray)
color struct_text_col = is_bullish_struct or is_bearish_struct ? color.white : color.silver

// 4. Calcul du Volume Delta
vol_delta_sum = 0.0
for i = 0 to lookback_period - 1
    candle_range = (high[i] - low[i]) == 0 ? 1 : (high[i] - low[i])
    pression = ((close[i] - low[i]) - (high[i] - close[i])) / candle_range
    vol_delta_sum := vol_delta_sum + (pression * (na(volume[i]) ? 1 : volume[i]))
v_delta_text = vol_delta_sum > 50 ? "ACHETEUR" : (vol_delta_sum < -50 ? "VENDEUR" : "NEUTRE")
color v_delta_bg_col = vol_delta_sum > 50 ? bg_green : (vol_delta_sum < -50 ? bg_red : bg_gray)
color v_delta_text_col = vol_delta_sum > 50 or vol_delta_sum < -50 ? color.white : color.silver

// 5. Position par rapport au VWAP
vwap_val = ta.vwap(close)
vwap_dist = (close - vwap_val) / vwap_val * 100
vwap_text = vwap_dist > 0.03 ? "HAUT" : (vwap_dist < -0.03 ? "BAS" : "MILIEU")
color vwap_bg_col = vwap_dist > 0.03 ? bg_green : (vwap_dist < -0.03 ? bg_red : bg_gray)
color vwap_text_col = vwap_dist > 0.03 or vwap_dist < -0.03 ? color.white : color.silver

// --- 7. AFFICHAGE INDICATEURS GRAF ---
plot(emaFilter, "EMA 200", color=color.white, linewidth=2)
plot(direction < 0 ? supertrend : na, "ST Vert", color=color.new(color.green, 50), style=plot.style_linebr)
plot(direction > 0 ? supertrend : na, "ST Rouge", color=color.new(color.red, 50), style=plot.style_linebr)

plotshape(goLong, title="Achat Flash", style=shape.labelup, location=location.belowbar, color=flashyGreen, size=size.normal, text="GO", textcolor=color.black)
plotshape(goShort, title="Vente Flash", style=shape.labeldown, location=location.abovebar, color=flashyPink, size=size.normal, text="GO", textcolor=color.white)

// --- 8. LIGNES SL/TP ---
var line slLine = na
var line tpLine = na
var label slLabel = na 
var label tpLabel = na 

if goLong or goShort
    line.delete(slLine)
    line.delete(tpLine)
    label.delete(slLabel)
    label.delete(tpLabel)
    
    slLine := line.new(bar_index, lastSL, bar_index + 15, lastSL, color=color.red, width=2)
    tpLine := line.new(bar_index, lastTP, bar_index + 15, lastTP, color=color.blue, width=2)
    
    string tpText = "OBJECTIF " + (useFibTarget ? "(Fib 1.618)" : "(Ratio " + str.tostring(actual_ratio, "#.#") + ")")
    tpLabel := label.new(x=bar_index + 5, y=lastTP, text=tpText + "\n" + str.tostring(lastTP,  "#"), color=color.blue, style=label.style_label_down, textcolor=color.white, size=size.small)
    slLabel := label.new(x=bar_index + 5, y=lastSL, text="STOP LOSS\n" + str.tostring(lastSL, "#"), color=color.red, style=label.style_label_up, textcolor=color.white, size=size.small)

// --- 9. TABLEAU DE BORD MODULABLE V6 ---
var table dashboard = table.new(pos_table, 2, 14, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    color typeCol = lastType == "LONG" ? flashyGreen : (lastType == "SHORT" ? flashyPink : color.gray)
    
    string displayTime = na(lastTime) ? "--:--" : str.tostring(hour(lastTime, syminfo.timezone), "00") + ":" + str.tostring(minute(lastTime, syminfo.timezone), "00")
    string currentTimeStr = str.tostring(hour(time, syminfo.timezone), "00") + ":" + str.tostring(minute(time, syminfo.timezone), "00")
    
    string displayRSI = na(lastRSI) ? "50.0" : str.tostring(lastRSI, "#.1")
    color rsiCol = na(lastRSI) ? color.silver : (lastRSI >= 50 ? color.lime : color.red)
    string displayEntry = na(lastEntry) ? "---" : str.tostring(lastEntry, "#")

    // Métriques du Signal Initial
    table.cell(dashboard, 0, 0, "DERN. SIGNAL", text_color=color.white, text_size=size_table)
    table.cell(dashboard, 1, 0, displayTime, text_color=color.yellow, text_size=size_table)
    table.cell(dashboard, 0, 1, "TYPE", text_color=color.white, text_size=size_table)
    table.cell(dashboard, 1, 1, lastType, text_color=typeCol, text_size=size_table)
    table.cell(dashboard, 0, 2, "RSI (Entrée)", text_color=color.silver, text_size=size_table)
    table.cell(dashboard, 1, 2, displayRSI, text_color=rsiCol, text_size=size_table)
    table.cell(dashboard, 0, 3, "ADX (Force)", text_color=color.silver, text_size=size_table)
    table.cell(dashboard, 1, 3, str.tostring(adxValue, "#.1"), text_color=adxValue > adxThreshold ? color.lime : color.red, text_size=size_table)
    
    // SECTION : ANALYSE DES 20 BOUGIES
    table.cell(dashboard, 0, 4, "--- LIVE 20b ACTUEL ---", text_color=color.yellow, text_size=size_custom_20b)
    table.cell(dashboard, 1, 4, "-----------------", text_color=color.yellow, text_size=size_custom_20b)
    
    table.cell(dashboard, 0, 5, "HEURE LOCALE", text_color=color.orange, text_size=size_custom_20b)
    table.cell(dashboard, 1, 5, currentTimeStr, text_color=color.orange, text_size=size_custom_20b)
    
    table.cell(dashboard, 0, 6, "FLUX (20b)", text_color=color.white, text_size=size_custom_20b)
    table.cell(dashboard, 1, 6, flux_text, text_color=flux_text_col, text_size=size_custom_20b, bgcolor=flux_bg_col)
    
    table.cell(dashboard, 0, 7, "VOLATILITÉ", text_color=color.white, text_size=size_custom_20b)
    table.cell(dashboard, 1, 7, vol_text, text_color=vol_text_col, text_size=size_custom_20b, bgcolor=vol_bg_col)
    
    table.cell(dashboard, 0, 8, "STRUCTURE", text_color=color.white, text_size=size_custom_20b)
    table.cell(dashboard, 1, 8, struct_text, text_color=struct_text_col, text_size=size_custom_20b, bgcolor=struct_bg_col)
    
    table.cell(dashboard, 0, 9, "VOL DELTA", text_color=color.white, text_size=size_custom_20b)
    table.cell(dashboard, 1, 9, v_delta_text, text_color=v_delta_text_col, text_size=size_custom_20b, bgcolor=v_delta_bg_col)
    
    table.cell(dashboard, 0, 10, "ZONE VALUE", text_color=color.white, text_size=size_custom_20b)
    table.cell(dashboard, 1, 10, vwap_text, text_color=vwap_text_col, text_size=size_custom_20b, bgcolor=vwap_bg_col)
    
    // SECTION : PARAMÈTRES DU TRADE
    table.cell(dashboard, 0, 11, "-----------------", text_color=color.gray, text_size=size_table)
    table.cell(dashboard, 1, 11, "-----------------", text_color=color.gray, text_size=size_table)
    
    table.cell(dashboard, 0, 12, "Ratio R:R", text_color=color.white, text_size=size_table)
    table.cell(dashboard, 1, 12, str.tostring(actual_ratio, "#.1"), text_color=#FFD700, text_size=size_table)
    table.cell(dashboard, 0, 13, "PRIX ENTRÉE", text_color=color.white, text_size=size_table)
    table.cell(dashboard, 1, 13, displayEntry, text_color=color.white, text_size=size_table)

// --- 10. ALERTES ---
alertcondition(goLong, title="ALERTE PRO ACHAT", message="GO LONG BTC!")
alertcondition(goShort, title="ALERTE PRO VENTE", message="GO SHORT BTC!")
````
