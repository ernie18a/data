# Apertura borse universale - SMC session tracker

- url: https://www.tradingview.com/script/xNMMsPPg/
- type: indicator
- pine_id: PUB;65b111a87f574ef49609e8a4826f4093
- version: 1.0

## Description

Descrizione dello Script
*"Questo indicatore è uno strumento essenziale e ultra-pulito progettato per i trader che utilizzano gli Smart Money Concepts (SMC). Traccia con assoluta precisione il livello di prezzo di apertura esatto delle tre sessioni principali di mercato e le collega tra loro.

A cosa serve operativamente:

Mappa della liquidità: Ti permette di vedere a colpo d'occhio come le istituzioni muovono il prezzo da una sessione all'altra.

Bias giornaliero: Mostra i punti di rotazione chiave (Tokyo, Londra, New York) senza riempire il grafico con rettangoli enormi e confusi.

Grafico pulito: Una volta rimosse le candele dal grafico, l'indicatore mostra la pura struttura dei movimenti del prezzo tra le sessioni.

Caratteristiche principali:

Universale e Multitimeframe: Funziona perfettamente sia sul Forex (es. EUR/USD) che sui metalli (es. Silver/XAGUSD) e su qualsiasi timeframe (dal 15m al 4H).

Linee di collegamento automatiche: Disegna una linea tra i punti di apertura delle sessioni consecutive per identificare istantaneamente il trend intraday.

Si abbina alla perfezione con il mio secondo indicatore: SMC Session Range Converter Pro (%), che mostra i dati statistici di volatilità in una comoda tabella."

-----

Description
*"This indicator is an essential, ultra-clean tool designed for traders using Smart Money Concepts (SMC). It accurately tracks the exact opening price levels of the three major market sessions and connects them.

How to use it for your trading:

Liquidity Map: It allows you to see at a glance how institutions move price from one session to the next.

Daily Bias: It highlights the key pivot points (Tokyo, London, New York) without cluttering the chart with huge, confusing rectangles.

Clean Charts: By hiding the candles on your chart, the indicator shows the pure structure of price movements between sessions.

Key Features:

Universal & Multi-timeframe: It works perfectly on Forex (e.g., EUR/USD), metals (e.g., Silver/XAGUSD), and any timeframe (from 15m to 4H).

Automatic Connection Lines: It draws lines between the opening prices of consecutive sessions to instantly identify the intraday trend.

It pairs perfectly with my second indicator: SMC Session Range Converter Pro (%), which displays historical volatility data in a clean dashboard."

## Source Code

````pine
// @version=5
indicator("Aperture Borse - Definitivo V2", overlay=true, max_labels_count=500, max_lines_count=500)

// --- 1. Impostazione Orari (Orario locale del tuo grafico) ---
tok_hour = input.int(0, title="Ora Apertura Tokyo", minval=0, maxval=23)
lon_hour = input.int(9, title="Ora Apertura Londra", minval=0, maxval=23)
ny_hour  = input.int(14, title="Ora Apertura New York (Ora)", minval=0, maxval=23)
ny_min   = input.int(30, title="Ora Apertura New York (Minuti)", minval=0, maxval=59)

// --- 2. Rilevamento Candele di Apertura ---
is_new_day = ta.change(time("D")) != 0

// Condizioni per identificare la candela esatta
is_tok = hour == tok_hour and minute == 0
is_lon = hour == lon_hour and minute == 0
is_ny  = hour == ny_hour  and minute == ny_min

// --- 3. Variabili di Memoria ---
var float tokPrice = na
var float lonPrice = na
var float nyPrice  = na

var int last_bar = na
var float last_price = na

// Reset della memoria ogni volta che cambia il giorno
if is_new_day
    tokPrice   := na
    lonPrice   := na
    nyPrice    := na
    last_bar   := na
    last_price := na

// --- 4. Cattura prezzi e Disegno ---

// TOKYO
if is_tok
    tokPrice := open
    label.new(bar_index, tokPrice, "● Tok", color=#00000000, textcolor=color.yellow, style=label.style_none, size=size.small)
    last_bar  := bar_index
    last_price := tokPrice

// LONDRA
if is_lon
    lonPrice := open
    label.new(bar_index, lonPrice, "● Lon", color=#00000000, textcolor=color.blue, style=label.style_none, size=size.small)
    if not na(last_price)
        line.new(last_bar, last_price, bar_index, lonPrice, color=color.new(color.gray, 50), width=1)
    last_bar  := bar_index
    last_price := lonPrice

// NEW YORK
if is_ny
    nyPrice := open
    label.new(bar_index, nyPrice, "● NY", color=#00000000, textcolor=color.orange, style=label.style_none, size=size.small)
    if not na(last_price)
        line.new(last_bar, last_price, bar_index, nyPrice, color=color.new(color.gray, 50), width=1)
    last_bar  := bar_index
    last_price := nyPrice
````
