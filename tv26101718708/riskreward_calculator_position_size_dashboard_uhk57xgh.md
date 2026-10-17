# Risk/Reward Calculator & Position Size Dashboard

- url: https://www.tradingview.com/script/uHK57xGH/
- type: indicator
- pine_id: PUB;7cd351d7ee50471caf778c5be2926c03
- version: 1.0

## Description

📝 DESCRIPTION (ENGLISH)
Risk/Reward Calculator and Position Size - Professional Dashboard
This advanced indicator helps you plan every trade with mathematical precision, automatically calculating Take Profit, Draw Down, and profits based on your capital, position size, and selected instrument.
KEY FEATURES:
🎯 Smart Take Profit Calculation
Percentage Mode: enter your desired % and the script calculates the exact price
Specific Price Mode: enter your target price and the script calculates the corresponding %
Full support for LONG and SHORT positions
💰 Dynamic Draw Down Management
Set maximum risk in dollars (e.g., $500)
Calculation automatically adapts to your position size
With size 0.01 and $500 risk = 500 points distance
With size 0.02 and $500 risk = 250 points distance
📊 Professional Dashboard
Top-right table with all crucial data
Adjustable size (Small, Normal, Large)
Shows: Capital, Size/Leverage, Value per Point, TP, Profit, DD, Entry Price
📈 Visual Chart Lines
White line: Entry Price
Solid green line: TP Long
Dotted green line: TP Short
Dotted red lines: DD Long and Short (optional)
Adjustable line length
🌍 Multi-Instrument Support
Gold (XAU - 100)
Silver (XAG - 5000)
Standard Forex (EURUSD - 100,000)
Bitcoin (BTC - 1)
Ethereum (ETH - 1)
Indices (US30/NAS100 - 1)
Custom (enter your own multiplier)
HOW TO USE:
Add the indicator to your chart
Open settings (⚙️)
Set your capital and select the instrument
Enter position size and leverage
Choose TP mode (Percentage or Specific Price)
Set Max Draw Down
Read the results in the dashboard!
PRACTICAL EXAMPLE:
Capital: $10,000
Instrument: Gold (XAU)
Size: 0.01 lots
Max DD: $500
Entry: 4218.97 (current price)
TP Mode: Specific Price → 4250
Result: Dashboard shows TP Long at 4250.00 (0.74%), profit of $31.03, DD Long at 3718.97 [-500 pts]
PERFECT FOR:
Traders who want precise calculations before entering positions
Professional risk management
Visual trade planning
Multi-timeframe analysis
Prop trading and demo accounts

____________

📝 DESCRIZIONE (ITALIANO)
Calcolatore Risk/Reward e Position Size - Dashboard Professionale
Questo indicatore avanzato ti aiuta a pianificare ogni trade con precisione matematica, calcolando automaticamente Take Profit, Draw Down e profitti in base al tuo capitale, size e strumento selezionato.
FUNZIONALITÀ PRINCIPALI:
🎯 Calcolo Take Profit Intelligente
Modalità Percentuale: inserisci la % desiderata e lo script calcola il prezzo esatto
Modalità Prezzo Specifico: inserisci il prezzo target e lo script calcola la % corrispondente
Supporto completo per posizioni LONG e SHORT
💰 Gestione Draw Down Dinamica
Imposta il rischio massimo in dollari (es. 500$)
Il calcolo si adatta automaticamente alla tua size
Con size 0.01 e rischio 500$ = 500 punti di distanza
Con size 0.02 e rischio 500$ = 250 punti di distanza
📊 Dashboard Professionale
Tabella in alto a destra con tutti i dati cruciali
Dimensione regolabile (Piccola, Normale, Grande)
Mostra: Capitale, Size/Leva, Valore per Punto, TP, Profitto, DD, Entry Price
📈 Linee Visive sul Grafico
Linea bianca: Prezzo di Entry
Linea verde continua: TP Long
Linea verde tratteggiata: TP Short
Linee rosse tratteggiate: DD Long e Short (opzionali)
Lunghezza linee regolabile
🌍 Supporto Multi-Strumento
Oro (XAU - 100)
Argento (XAG - 5000)
Forex Standard (EURUSD - 100.000)
Bitcoin (BTC - 1)
Ethereum (ETH - 1)
Indici (US30/NAS100 - 1)
Personalizzato (inserisci il tuo moltiplicatore)
COME USARLO:
Aggiungi l'indicatore al grafico
Apri le impostazioni (⚙️)
Imposta il tuo capitale e seleziona lo strumento
Inserisci la size e la leva
Scegli la modalità TP (Percentuale o Prezzo Specifico)
Imposta il Max Draw Down
Leggi i risultati nella dashboard!
ESEMPIO PRATICO:
Capitale: 10.000$
Strumento: Oro (XAU)
Size: 0.01 lotti
Max DD: 500$
Entry: 4218.97 (prezzo attuale)
TP Mode: Prezzo Specifico → 4250
Risultato: La dashboard mostra TP Long a 4250.00 (0.74%), profitto di 31.03$, DD Long a 3718.97 [-500 pts]
PERFETTO PER:
Trader che vogliono calcoli precisi prima di entrare in posizione
Gestione professionale del rischio
Pianificazione visiva dei trade
Multi-timeframe analysis
Prop trading e conti demo

## Source Code

````pine
//@version=6
indicator("Risk/Reward Calculator & Position Size Dashboard", overlay=true, max_labels_count=500)

// --- INPUTS ---
grp_main = "📊 General Settings"
capitale = input.float(10000, "Capital ($)", group=grp_main)

dash_size_input = input.string("Normal", "📏 Dashboard Size", options=["Small", "Normal", "Large"], group=grp_main)
dash_size = dash_size_input == "Small" ? size.small : dash_size_input == "Normal" ? size.normal : size.large

asset_preset = input.string("Gold (XAU - 100)", "📌 Instrument Preset", 
     options=["Gold (XAU - 100)", "Silver (XAG - 5000)", "Standard Forex (EURUSD - 100,000)", "Bitcoin (BTC - 1)", "Ethereum (ETH - 1)", "Indices (US30/NAS100 - 1)", "Custom"], 
     group=grp_main)

custom_contract_size = input.float(100, "Custom Contract Size", group=grp_main)

contract_size = switch asset_preset
    "Gold (XAU - 100)" => 100.0
    "Silver (XAG - 5000)" => 5000.0
    "Standard Forex (EURUSD - 100,000)" => 100000.0
    "Bitcoin (BTC - 1)" => 1.0
    "Ethereum (ETH - 1)" => 1.0
    "Indices (US30/NAS100 - 1)" => 1.0
    => custom_contract_size

size = input.float(0.01, "Size (Lots)", group=grp_main)
leva = input.float(100, "Leverage (x)", group=grp_main)

use_current_price = input.bool(true, "✅ Use current market price", group=grp_main)
manual_entry = input.float(0.0, "Manual Entry Price", group=grp_main)

float raw_entry = use_current_price ? close : (manual_entry > 0 ? manual_entry : close)
float entry_price = ta.valuewhen(barstate.islast, raw_entry, 0)

grp_risk = "⚖️ Risk & Reward Settings"
max_dd = input.float(500, "Max Drawdown / Risk ($)", group=grp_risk)

tp_mode = input.string("Percentage (%)", "🎯 TP Calculation Mode:", options=["Percentage (%)", "Specific Price"], group=grp_risk)
target_profit_pct = input.float(0.25, "Target Profit (%)", group=grp_risk)
target_price_long = input.float(0.0, "Target Price LONG", group=grp_risk)
target_price_short = input.float(0.0, "Target Price SHORT", group=grp_risk)

grp_lines = "📈 Chart Lines"
show_entry_line = input.bool(true, "Show Entry Line (White)", group=grp_lines)
show_tp_long_line = input.bool(true, "Show TP Long Line (Green)", group=grp_lines)
show_tp_short_line = input.bool(true, "Show TP Short Line (Green Dotted)", group=grp_lines)
show_dd_lines = input.bool(false, "Show DD Lines (Red)", group=grp_lines)
bars_back = input.int(50, "Line Length (bars)", group=grp_lines, minval=10, maxval=500, tooltip="How many bars back the horizontal lines start.")

// --- CALCOLI ---
float final_tp_long = 0.0
float final_tp_short = 0.0
float final_pct_long = 0.0
float final_pct_short = 0.0

if tp_mode == "Percentage (%)"
    final_tp_long := entry_price * (1 + (target_profit_pct / 100.0))
    final_tp_short := entry_price * (1 - (target_profit_pct / 100.0))
    final_pct_long := target_profit_pct
    final_pct_short := target_profit_pct
else 
    final_tp_long := target_price_long > 0 ? target_price_long : entry_price
    final_tp_short := target_price_short > 0 ? target_price_short : entry_price
    final_pct_long := ((final_tp_long - entry_price) / entry_price) * 100.0
    final_pct_short := ((entry_price - final_tp_short) / entry_price) * 100.0

float value_per_point = size * contract_size 
float profit_long = (final_tp_long - entry_price) * value_per_point
float profit_short = (entry_price - final_tp_short) * value_per_point

float points_to_dd = max_dd / value_per_point
float final_dd_long = entry_price - points_to_dd
float final_dd_short = entry_price + points_to_dd

// --- DISEGNO LINEE CON line.new() ---
var line ln_entry = na
var line ln_tp_long = na
var line ln_tp_short = na
var line ln_dd_long = na
var line ln_dd_short = na

if barstate.islast
    int x_start = bar_index - bars_back
    
    // Cancella le linee precedenti
    if not na(ln_entry)
        line.delete(ln_entry)
    if not na(ln_tp_long)
        line.delete(ln_tp_long)
    if not na(ln_tp_short)
        line.delete(ln_tp_short)
    if not na(ln_dd_long)
        line.delete(ln_dd_long)
    if not na(ln_dd_short)
        line.delete(ln_dd_short)
    
    // Crea nuove linee
    if show_entry_line
        ln_entry := line.new(x1=x_start, y1=entry_price, x2=bar_index, y2=entry_price, color=color.white, width=2, extend=extend.right)
    
    if show_tp_long_line
        ln_tp_long := line.new(x1=x_start, y1=final_tp_long, x2=bar_index, y2=final_tp_long, color=color.green, width=2, extend=extend.right)
    
    if show_tp_short_line
        ln_tp_short := line.new(x1=x_start, y1=final_tp_short, x2=bar_index, y2=final_tp_short, color=color.green, width=1, style=line.style_dotted, extend=extend.right)
    
    if show_dd_lines
        ln_dd_long := line.new(x1=x_start, y1=final_dd_long, x2=bar_index, y2=final_dd_long, color=color.red, width=1, style=line.style_dotted, extend=extend.right)
        ln_dd_short := line.new(x1=x_start, y1=final_dd_short, x2=bar_index, y2=final_dd_short, color=color.red, width=1, style=line.style_dotted, extend=extend.right)

// --- TABELLA ---
var table infoTable = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 80), frame_color=color.gray, frame_width=1, border_color=color.gray)

if barstate.islast
    table.cell(infoTable, 0, 0, "💰 Capital", text_color=color.white, text_size=dash_size)
    table.cell(infoTable, 1, 0, str.tostring(capitale, "#.##") + " $", text_color=color.green, text_size=dash_size)

    table.cell(infoTable, 0, 1, "📦 Size / Leverage", text_color=color.white, text_size=dash_size)
    table.cell(infoTable, 1, 1, str.tostring(size) + " / " + str.tostring(leva) + "x", text_color=color.white, text_size=dash_size)

    table.cell(infoTable, 0, 2, "💵 Value per Point", text_color=color.white, text_size=dash_size)
    table.cell(infoTable, 1, 2, str.tostring(value_per_point, "#.##") + " $", text_color=color.yellow, text_size=dash_size)

    table.cell(infoTable, 0, 3, "🟢 TP LONG", text_color=color.green, text_size=dash_size)
    table.cell(infoTable, 1, 3, str.tostring(final_tp_long, format.mintick) + " (" + str.tostring(final_pct_long, "#.##") + "%)", text_color=color.green, text_size=dash_size)

    table.cell(infoTable, 0, 4, "💰 LONG Profit", text_color=color.green, text_size=dash_size)
    table.cell(infoTable, 1, 4, str.tostring(profit_long, "#.##") + " $", text_color=color.green, text_size=dash_size)

    table.cell(infoTable, 0, 5, "🔴 DD LONG", text_color=color.red, text_size=dash_size)
    table.cell(infoTable, 1, 5, str.tostring(final_dd_long, format.mintick) + " [-" + str.tostring(points_to_dd, "#.##") + " pts]", text_color=color.red, text_size=dash_size)

    table.cell(infoTable, 0, 6, "🟢 TP SHORT", text_color=color.green, text_size=dash_size)
    table.cell(infoTable, 1, 6, str.tostring(final_tp_short, format.mintick) + " (" + str.tostring(final_pct_short, "#.##") + "%)", text_color=color.green, text_size=dash_size)

    table.cell(infoTable, 0, 7, "💰 SHORT Profit", text_color=color.green, text_size=dash_size)
    table.cell(infoTable, 1, 7, str.tostring(profit_short, "#.##") + " $", text_color=color.green, text_size=dash_size)

    table.cell(infoTable, 0, 8, "🔴 DD SHORT", text_color=color.red, text_size=dash_size)
    table.cell(infoTable, 1, 8, str.tostring(final_dd_short, format.mintick) + " [+" + str.tostring(points_to_dd, "#.##") + " pts]", text_color=color.red, text_size=dash_size)
    
    table.cell(infoTable, 0, 9, "📍 Entry Price", text_color=color.white, text_size=dash_size)
    table.cell(infoTable, 1, 9, str.tostring(entry_price, format.mintick), text_color=color.blue, text_size=dash_size)

    table.cell(infoTable, 0, 10, "⚙️ TP Mode", text_color=color.gray, text_size=dash_size)
    table.cell(infoTable, 1, 10, tp_mode, text_color=color.aqua, text_size=dash_size)
````
