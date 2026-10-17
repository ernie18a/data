# Universal Session Open V.2

- url: https://www.tradingview.com/script/nz4b2NeH/
- type: indicator
- pine_id: PUB;ff53a6e0b2524769b0761c2b5bdd5724
- version: 1.0

## Description

📌 Cos'è questo indicatore?
L'Apertura Borse Universale V.2 è un indicatore essenziale per chi fa trading usando i concetti di Smart Money (SMC) e Price Action. Traccia in modo millimetrico i prezzi di apertura delle tre sessioni principali: Tokyo, Londra e New York.

Il prezzo di apertura di una borsa funge spessissimo da livello istituzionale chiave (Supporto/Resistenza) durante la giornata di contrattazione. Questa versione 2 è stata completamente riscritta per eliminare ogni errore di calcolo e permetterti di vedere esattamente dove i mercati aprono le loro porte.

⚙️ Caratteristiche Principali
Precisione Millimetrica (UTC+2 Roma): Le aperture sono calcolate esattamente al primo minuto di ciascuna borsa (Tokyo 00:00, Londra 09:00, New York 14:30), senza sfasamenti dovuti al fuso orario del grafico.

Niente Sovrapposizioni Visive: Le linee orizzontali di apertura iniziano sulla prima candela della sessione e si fermano esattamente alla chiusura della sessione stessa.

Storico Completo (Novità V.2): Le linee dei giorni precedenti rimangono finalmente visibili nello storico, permettendoti di fare backtest visivo sui vecchi livelli di apertura.

Design Pulito: Un piccolo pallino segnala visivamente la candela esatta dell'apertura, lasciando il grafico libero dal rumore.

💡 Come usarlo nel Trading (SMC)
Identifica i livelli chiave: Usa le linee di apertura come zone di attrazione del prezzo o potenziali livelli di rimbalzo (Open Session Manipulation).

Analisi del contesto: Combinalo con il tuo indicatore di Range Medio o con i rettangoli delle sessioni per capire la struttura di mercato intraday.

Analisi multi-timeframe: Funziona perfettamente su qualsiasi timeframe (1m, 5m, 15m, ecc.), garantendo sempre la massima precisione della linea.

🛠️ Impostazioni Personalizzabili
Puoi modificare manualmente gli orari di apertura e chiusura delle sessioni direttamente dal menu delle impostazioni dell'indicatore per adattarli ai tuoi strumenti di trading preferiti.


🇬🇧 ENGLISH VERSION
Script Title
Universal Session Open V.2

Script Description
📌 What is this indicator?
The Universal Session Open V.2 is an essential indicator for anyone trading with Smart Money Concepts (SMC) and Price Action. It accurately tracks the exact opening prices of the three major trading sessions: Tokyo, London, and New York.

The opening price of a session very often acts as a key institutional level (Support/Resistance) during the trading day. This Version 2 has been completely rewritten to eliminate any calculation errors, allowing you to see exactly where the markets open.

⚙️ Key Features
To-the-Minute Precision (UTC+2 Rome): Openings are calculated exactly at the very first minute of each session (Tokyo 00:00, London 09:00, New York 14:30), without any offset caused by your chart's timezone.

No Visual Overlap: The horizontal open lines begin on the first candle of the session and stop exactly when the session ends.

Full Historical Data (New in V.2): Previous days' lines now remain visible in your chart's history, allowing you to visually backtest past opening levels.

Clean Design: A small dot visually marks the exact opening candle, keeping your chart clutter-free.

💡 How to use it in Trading (SMC)
Identify key levels: Use the opening lines as price magnets or potential bounce levels (Open Session Manipulation).

Analyze the context: Combine it with your Average Range indicator or session rectangles to understand the intraday market structure.

Multi-timeframe analysis: It works perfectly on any timeframe (1m, 5m, 15m, etc.), always guaranteeing the maximum precision of the lines.

🛠️ Customizable Settings
You can manually adjust the opening and closing hours of the sessions directly within the indicator settings menu to adapt them to your preferred trading assets.

## Source Code

````pine
//@version=5
indicator("Apertura Borse Universale", overlay=true, max_lines_count=500)

// ==========================================
// CONFIGURAZIONE ORARI (In base a UTC+2 Roma)
// ==========================================
tokyo_sess  = input.session("0000-0900", "Orario Tokyo", group="Orari Borse")
london_sess = input.session("0900-1730", "Orario Londra", group="Orari Borse")
ny_sess     = input.session("1430-2200", "Orario New York", group="Orari Borse")

// Funzione per capire se siamo sulla candela ESATTA di apertura della borsa
is_open(sess) =>
    in_sess = not na(time(timeframe.period, sess, "GMT+2"))
    in_sess and not in_sess[1]

// Funzione per capire se la sessione è appena finita
is_close(sess) =>
    in_sess = not na(time(timeframe.period, sess, "GMT+2"))
    not in_sess and in_sess[1]

// Variabili per salvare i riferimenti alle linee correnti
var line current_tokyo = na
var line current_london = na
var line current_ny = na

// ==========================================
// LOGICA DI TRACCIAMENTO STORICO
// ==========================================

// --- TOKYO ---
if is_open(tokyo_sess)
    // Crea una nuova linea senza cancellare quella vecchia
    current_tokyo := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=color.yellow, width=2)

// Allunga la linea fino alla fine della sessione corrente
if not na(current_tokyo) and not na(time(timeframe.period, tokyo_sess, "GMT+2"))
    line.set_x2(current_tokyo, bar_index)


// --- LONDRA ---
if is_open(london_sess)
    current_london := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=color.blue, width=2)

if not na(current_london) and not na(time(timeframe.period, london_sess, "GMT+2"))
    line.set_x2(current_london, bar_index)


// --- NEW YORK ---
if is_open(ny_sess)
    current_ny := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=color.orange, width=2)

if not na(current_ny) and not na(time(timeframe.period, ny_sess, "GMT+2"))
    line.set_x2(current_ny, bar_index)


// ==========================================
// PALLINI SULLA CANDELA DI APERTURA ESATTA
// ==========================================
plotshape(is_open(tokyo_sess), title="Inizio Tokyo", style=shape.circle, location=location.absolute, color=color.yellow, size=size.tiny)
plotshape(is_open(london_sess), title="Inizio Londra", style=shape.circle, location=location.absolute, color=color.blue, size=size.tiny)
plotshape(is_open(ny_sess), title="Inizio New York", style=shape.circle, location=location.absolute, color=color.orange, size=size.tiny)
````
