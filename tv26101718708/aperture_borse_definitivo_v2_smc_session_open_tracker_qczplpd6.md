# Aperture Borse - Definitivo V2 - SMC session open tracker

- url: https://www.tradingview.com/script/qczPlPD6/
- type: indicator
- pine_id: PUB;ecb31b97c2024f30b3dd19cd2d1c4d0f
- version: 1.0

## Description

"Questo indicatore traccia il prezzo di apertura esatto delle tre sessioni principali (Tokyo, Londra, New York) e le collega per mostrare il trend e il bias istituzionale del giorno. Ideale per chi fa trading con gli Smart Money Concepts (SMC) e vuole un grafico pulito, libero da rettangoli invasivi."

ome usarlo:
Trend Following: Se i punti della giornata sono in salita (Tok → Lon → NY), il trend giornaliero è rialzista.

S/R Magnetica: I punti di apertura precedenti (soprattutto Tokyo) fungono da zone di forte attrazione del prezzo o di rimbalzo.

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
