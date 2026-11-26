# SMC Session Volume Tracker

- url: https://www.tradingview.com/script/CscBIqkJ/
- type: indicator
- pine_id: PUB;cdcb776b90f5463d9f5ba9ede9074327
- version: 1.0

## Description

## 🇮🇹 Versione Italiana

### **Cos'è questo indicatore?**
Questo script è uno strumento avanzato di analisi volumetrica progettato per i trader che utilizzano gli Smart Money Concepts (SMC). Calcola l'affluenza di capitali in tempo reale confrontando il volume totale della sessione corrente con la media storica dei volumi degli ultimi 20 giorni di quella stessa borsa.

### **Perché è fondamentale per la tua strategia?**
Nello Smart Money Concepts, la liquidità è tutto. Sapere se i grandi capitali stanno effettivamente entrando a mercato ti offre un vantaggio operativo enorme:
* **Conferma dei Breakout:** Se vedi un BOS o un CHoCH ma l'affluenza di capitali è bassa, potrebbe trattarsi di una Stop Hunt. Se l'affluenza è sopra il 100%, il movimento è guidato dalle istituzioni.
* **Evitare i mercati "morti":** Ti dice subito se una sessione ha abbastanza carburante per muoversi o se è meglio stare a guardare.
* **Validazione dei POI:** Un'entrata su un Order Block ha molte più probabilità di successo se avviene nel momento in cui l'affluenza di capitali è ai massimi.

### **Caratteristiche principali**
* **Orari Europei di Default:** Già preimpostato sugli orari della borsa in Europa/Roma.
* **Dashboard Altamente Personalizzabile:** Puoi modificare la posizione della tabella sul grafico e la dimensione del testo per adattarla a qualsiasi schermo.
* **Colorazione Intelligente:** I dati diventano verdi quando l'affluenza supera il 100% rispetto alla media a 20 giorni, indicando una forte immissione di liquidità.

---

## 🇬🇧 English Version

### **What is this indicator?**
This script is an advanced volume analysis tool designed for traders using Smart Money Concepts (SMC). It calculates real-time capital flow by comparing the current session's total volume with the historical average volume of that specific session over the past 20 days.

### **Why is it essential for your strategy?**
In Smart Money Concepts, liquidity is everything. Knowing whether institutions are actually injecting money into the market gives you a huge edge:
* **Confirm Breakouts:** If you see a BOS or CHoCH but the capital flow is low, it might be a Stop Hunt. If the flow is above 100%, the move is backed by smart money.
* **Avoid Flat Markets:** It instantly tells you if a session has enough fuel to move or if it's better to sit on the sidelines.
* **Validate POIs:** An entry at an Order Block has much higher odds of success if it aligns with peak session liquidity.

### **Key Features**
* **Default European Hours:** Pre-configured for European/Rome market hours.
* **Highly Customizable Dashboard:** Adjust table position and text size to fit any screen perfectly.
* **Smart Coloring:** Text turns green when the current volume exceeds 100% of the 20-day average, signaling strong institutional activity.

## Source Code

````pine
//@version=5
indicator("SMC Session Volume Tracker", overlay=false)

// ==========================================
// CONFIGURAZIONE ORARI E TABELLA
// ==========================================
t_tokyo  = input.session("0000-0900", "Sessione Tokyo", group="Orari Sessioni")
t_london = input.session("0900-1730", "Sessione Londra", group="Orari Sessioni")
t_ny     = input.session("1430-2200", "Sessione New York", group="Orari Sessioni")

// Opzioni di personalizzazione della tabella
table_pos  = input.string(position.bottom_right, "Posizione Tabella", 
             options=[position.top_right, position.bottom_right, position.top_left, position.bottom_left], group="Stile Dashboard")
table_size = input.string(size.small, "Dimensione Testo", 
             options=[size.tiny, size.small, size.normal, size.large], group="Stile Dashboard")

// ==========================================
// FUNZIONE LOGICA: CALCOLO VOLUME DI SESSIONE
// ==========================================
in_session(sess) => not na(time(timeframe.period, sess, "UTC+2")) // Impostato su orario Roma

var float vol_tokyo = 0.0
var float vol_london = 0.0
var float vol_ny = 0.0

var float[] history_tokyo = array.new_float(0)
var float[] history_london = array.new_float(0)
var float[] history_ny = array.new_float(0)

change_tokyo = in_session(t_tokyo) and not in_session(t_tokyo)[1]
change_london = in_session(t_london) and not in_session(t_london)[1]
change_ny = in_session(t_ny) and not in_session(t_ny)[1]

if change_tokyo
    if vol_tokyo > 0
        array.push(history_tokyo, vol_tokyo)
        if array.size(history_tokyo) > 20
            array.shift(history_tokyo)
    vol_tokyo := 0.0

if change_london
    if vol_london > 0
        array.push(history_london, vol_london)
        if array.size(history_london) > 20
            array.shift(history_london)
    vol_london := 0.0

if change_ny
    if vol_ny > 0
        array.push(history_ny, vol_ny)
        if array.size(history_ny) > 20
            array.shift(history_ny)
    vol_ny := 0.0

if in_session(t_tokyo)
    vol_tokyo := vol_tokyo + nz(volume)
if in_session(t_london)
    vol_london := vol_london + nz(volume)
if in_session(t_ny)
    vol_ny := vol_ny + nz(volume)

avg_tokyo = array.size(history_tokyo) > 0 ? array.avg(history_tokyo) : na
avg_london = array.size(history_london) > 0 ? array.avg(history_london) : na
avg_ny = array.size(history_ny) > 0 ? array.avg(history_ny) : na

affluenza_tokyo = not na(avg_tokyo) and avg_tokyo > 0 ? (vol_tokyo / avg_tokyo) * 100 : 100.0
affluenza_london = not na(avg_london) and avg_london > 0 ? (vol_london / avg_london) * 100 : 100.0
affluenza_ny = not na(avg_ny) and avg_ny > 0 ? (vol_ny / avg_ny) * 100 : 100.0

// ==========================================
// DASHBOARD VISIVA PERSONALIZZABILE
// ==========================================
var table info_table = table.new(table_pos, 2, 4, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.islast
    // Intestazione
    table.cell(info_table, 0, 0, "Sessione", text_color=color.white, text_size=table_size)
    table.cell(info_table, 1, 0, "Affluenza Cap.", text_color=color.white, text_size=table_size)
    
    // Tokyo
    table.cell(info_table, 0, 1, "Tokyo", text_color=color.yellow, text_size=table_size)
    table.cell(info_table, 1, 1, str.tostring(affluenza_tokyo, "#.##") + "%", text_color=affluenza_tokyo > 100 ? color.green : color.white, text_size=table_size)
    
    // Londra
    table.cell(info_table, 0, 2, "Londra", text_color=color.blue, text_size=table_size)
    table.cell(info_table, 1, 2, str.tostring(affluenza_london, "#.##") + "%", text_color=affluenza_london > 100 ? color.green : color.white, text_size=table_size)
    
    // New York
    table.cell(info_table, 0, 3, "New York", text_color=color.orange, text_size=table_size)
    table.cell(info_table, 1, 3, str.tostring(affluenza_ny, "#.##") + "%", text_color=affluenza_ny > 100 ? color.green : color.white, text_size=table_size)
````
