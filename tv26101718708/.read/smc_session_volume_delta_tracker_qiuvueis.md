# SMC Session Volume & Delta Tracker

- url: https://www.tradingview.com/script/QIUvUeIs/
- type: indicator
- pine_id: PUB;642042ffcaac40499a1cc1600b5529c0
- version: 1.0

## Description

## 🇮🇹 Versione Italiana

### **Cos'è questo indicatore?**
Questo script è la versione avanzata (2.0) del nostro tracker volumetrico per Smart Money Concepts (SMC). Oltre a calcolare l'affluenza di capitali rispetto alla media storica degli ultimi 20 giorni, introduce una metrica fondamentale: il **Delta del Volume (Pressione B/S)**. 

### **Come funziona il Delta del Volume?**
L'algoritmo analizza la Price Action e la struttura di ogni singola candela per scomporre il volume totale in volume d'acquisto (Buyer) e volume di vendita (Seller). Nella dashboard vedrai la percentuale esatta di forza tra le due fazioni:
* **Testo Verde (es. 55% / 45%):** I compratori hanno il controllo del volume di sessione.
* **Testo Rosso (es. 42% / 58%):** I venditori stanno dominando la sessione.
* **Testo Bianco:** Equilibrio e potenziale fase di accumulazione/distribuzione.

### **Perché è fondamentale per la tua strategia a 3, 5 e 15 minuti?**
Sui time frame bassi il mercato è pieno di rumore. Questo indicatore ti dà la conferma istituzionale:
* **Validazione dei CHoCH e BOS:** Se il prezzo rompe una struttura al rialzo e la Pressione B/S è sopra il 52% (Verde), hai la conferma che lo Smart Money sta comprando.
* **Filtro per i Fakeout:** Se vedi una rottura ma la pressione è contraria o in equilibrio, molto probabilmente è una Stop Hunt.

### **Caratteristiche principali**
* **Calcolo in tempo reale del Delta** (Buyer vs Seller).
* **Affluenza di Capitale %** rispetto alla media a 20 giorni.
* **Dashboard personalizzabile** in dimensione e posizione sul grafico.

---

## 🇬🇧 English Version

### **What is this indicator?**
This script is the advanced version (2.0) of our volume tracker designed for Smart Money Concepts (SMC). In addition to measuring capital flow against the 20-day historical average, it introduces a crucial metric: **Volume Delta (B/S Pressure)**.

### **How does the Volume Delta work?**
The algorithm dissects the Price Action and structure of every single candle to split total volume into buying volume (Buyers) and selling volume (Sellers). The dashboard displays the exact balance of power:
* **Green Text (e.g., 55% / 45%):** Buyers are in control of the session's volume.
* **Red Text (e.g., 42% / 58%):** Sellers are dominating the session.
* **White Text:** Market in balance, potential accumulation or distribution phase.

### **Why is it essential for 3m, 5m, and 15m timeframes?**
Low timeframes are filled with noise. This indicator provides institutional confirmation:
* **Validate CHoCH and BOS:** If price breaks structure to the upside and B/S Pressure is above 52% (Green), you have confirmation that Smart Money is buying.
* **Filter out Fakeouts:** If you see a breakout but the pressure is opposite or balanced, it is highly likely a Stop Hunt.

### **Key Features**
* **Real-time Delta Calculation** (Buyers vs Sellers).
* **Capital Flow %** compared to the 20-day average.
* **Customizable Dashboard** (adjust size and position on the chart).

## Source Code

````pine
//@version=5
indicator("SMC Session Volume & Delta Tracker", overlay=false)

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
// FUNZIONE LOGICA: CALCOLO VOLUME E DELTA
// ==========================================
in_session(sess) => not na(time(timeframe.period, sess, "UTC+2")) // Orario Roma

// Funzione per colorare il testo del Delta
get_delta_color(buy_pct) =>
    buy_pct > 52.0 ? color.green : (buy_pct < 48.0 ? color.red : color.white)

// Variabili per l'accumulo della sessione corrente
var float vol_tokyo = 0.0, var float buy_tokyo = 0.0
var float vol_london = 0.0, var float buy_london = 0.0
var float vol_ny = 0.0, var float buy_ny = 0.0

// Storico per le medie (20 giorni)
var float[] history_tokyo = array.new_float(0)
var float[] history_london = array.new_float(0)
var float[] history_ny = array.new_float(0)

// Reset di sessione
change_tokyo = in_session(t_tokyo) and not in_session(t_tokyo)[1]
change_london = in_session(t_london) and not in_session(t_london)[1]
change_ny = in_session(t_ny) and not in_session(t_ny)[1]

if change_tokyo
    if vol_tokyo > 0
        array.push(history_tokyo, vol_tokyo)
        if array.size(history_tokyo) > 20
            array.shift(history_tokyo)
    vol_tokyo := 0.0
    buy_tokyo := 0.0

if change_london
    if vol_london > 0
        array.push(history_london, vol_london)
        if array.size(history_london) > 20
            array.shift(history_london)
    vol_london := 0.0
    buy_london := 0.0

if change_ny
    if vol_ny > 0
        array.push(history_ny, vol_ny)
        if array.size(history_ny) > 20
            array.shift(history_ny)
    vol_ny := 0.0
    buy_ny := 0.0

// Calcolo del volume Toro (Buy) vs Orso (Sell) della singola candela
candle_range = high - low
candle_body  = math.abs(close - open)
buy_volume   = 0.0

if candle_range > 0
    // Proporzione del volume basata su chiusura e range della candela
    buy_pressure = ((close - low) + (close - open)) / (2 * candle_range)
    buy_volume := nz(volume) * math.max(0, math.min(1, buy_pressure))

// Accumulo dei volumi nella sessione attiva
if in_session(t_tokyo)
    vol_tokyo  += nz(volume)
    buy_tokyo  += buy_volume
if in_session(t_london)
    vol_london += nz(volume)
    buy_london += buy_volume
if in_session(t_ny)
    vol_ny  += nz(volume)
    buy_ny  += buy_volume

// Calcolo delle medie storiche
avg_tokyo  = array.size(history_tokyo) > 0 ? array.avg(history_tokyo) : na
avg_london = array.size(history_london) > 0 ? array.avg(history_london) : na
avg_ny     = array.size(history_ny) > 0 ? array.avg(history_ny) : na

// Calcolo affluenza totale %
affluenza_tokyo  = not na(avg_tokyo) and avg_tokyo > 0 ? (vol_tokyo / avg_tokyo) * 100 : 100.0
affluenza_london = not na(avg_london) and avg_london > 0 ? (vol_london / avg_london) * 100 : 100.0
affluenza_ny     = not na(avg_ny) and avg_ny > 0 ? (vol_ny / avg_ny) * 100 : 100.0

// Calcolo del Delta in percentuale (Quota Buyer vs Quota Seller)
pct_buy_tokyo  = vol_tokyo > 0 ? (buy_tokyo / vol_tokyo) * 100 : 50.0
pct_buy_london = vol_london > 0 ? (buy_london / vol_london) * 100 : 50.0
pct_buy_ny     = vol_ny > 0 ? (buy_ny / vol_ny) * 100 : 50.0

// ==========================================
// DASHBOARD VISIVA AGGIORNATA
// ==========================================
var table info_table = table.new(table_pos, 3, 4, bgcolor=color.new(color.black, 15), border_color=color.gray, border_width=1)

if barstate.islast
    // Intestazione
    table.cell(info_table, 0, 0, "Sessione", text_color=color.white, text_size=table_size)
    table.cell(info_table, 1, 0, "Affluenza Cap.", text_color=color.white, text_size=table_size)
    table.cell(info_table, 2, 0, "Pressione B/S", text_color=color.white, text_size=table_size)
    
    // Tokyo
    table.cell(info_table, 0, 1, "Tokyo", text_color=color.yellow, text_size=table_size)
    table.cell(info_table, 1, 1, str.tostring(affluenza_tokyo, "#.#") + "%", text_color=affluenza_tokyo > 100 ? color.green : color.white, text_size=table_size)
    table.cell(info_table, 2, 1, str.tostring(pct_buy_tokyo, "#.#") + "% / " + str.tostring(100 - pct_buy_tokyo, "#.#") + "%", text_color=get_delta_color(pct_buy_tokyo), text_size=table_size)
    
    // Londra
    table.cell(info_table, 0, 2, "Londra", text_color=color.blue, text_size=table_size)
    table.cell(info_table, 1, 2, str.tostring(affluenza_london, "#.#") + "%", text_color=affluenza_london > 100 ? color.green : color.white, text_size=table_size)
    table.cell(info_table, 2, 2, str.tostring(pct_buy_london, "#.#") + "% / " + str.tostring(100 - pct_buy_london, "#.#") + "%", text_color=get_delta_color(pct_buy_london), text_size=table_size)
    
    // New York
    table.cell(info_table, 0, 3, "New York", text_color=color.orange, text_size=table_size)
    table.cell(info_table, 1, 3, str.tostring(affluenza_ny, "#.#") + "%", text_color=affluenza_ny > 100 ? color.green : color.white, text_size=table_size)
    table.cell(info_table, 2, 3, str.tostring(pct_buy_ny, "#.#") + "% / " + str.tostring(100 - pct_buy_ny, "#.#") + "%", text_color=get_delta_color(pct_buy_ny), text_size=table_size)
````
