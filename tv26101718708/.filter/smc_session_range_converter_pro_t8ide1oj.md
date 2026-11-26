# SMC Session Range Converter Pro (%)

- url: https://www.tradingview.com/script/t8IDE1oJ/
- type: indicator
- pine_id: PUB;a9756495fb20470ba762e2e7ca94ffd6
- version: 1.0

## Description

Cos'è questo indicatore?
Questo script è uno strumento statistico avanzato progettato per i trader che utilizzano gli Smart Money Concepts (SMC). Calcola la media del range percentuale di prezzo (Massimo - Minimo) degli ultimi 3 mesi per le tre sessioni principali: Tokyo, Londra e New York.
Perché è fondamentale per la tua strategia?
Nello Smart Money Concepts, conoscere la volatilità media di ogni singola borsa ti offre un vantaggio statistico enorme:
Target realistici: Evita di impostare Take Profit (TP) irrealistici che superano il movimento medio della sessione corrente.
Riconoscere l'espansione: Se il range medio di Londra è dell'$1.4\%$ e oggi si muove già dell'$1.3\%$ prima di New York, sai che la sessione ha quasi esaurito la sua forza e potresti aspettarti una pausa o un'inversione.
Nessun fuso orario errato: 
Cattura il prezzo di apertura esatto della prima candela utile in base all'orario del tuo grafico, senza i classici problemi dei fusi orari standard degli altri indicatori.
Caratteristiche principaliOrari Europei di Default: 
Già pre impostato sugli orari della borsa in Europa/Roma (Tokyo 00:00-09:00, Londra 09:00-17:30, NY 14:30-22:00).
Dashboard Pulita: Una tabella discreta posizionata in basso a destra per non coprire il grafico, indicatori FVG o altre analisi.
Completamente Personalizzabile: Nelle impostazioni puoi modificare gli orari, il colore di sfondo della tabella, la posizione e la dimensione del testo.
Alert Integrati: Possibilità di attivare un alert automatico che ti avvisa se la sessione corrente supera il suo range medio a 3 mesi.

## Source Code

````pine
// @version=5
indicator("SMC Session Range Converter Pro (%)", overlay=true)

// --- 1. Orari delle Sessioni di Default (Orario di Roma/Europa) ---
tok_sess = input.session("0000-0900", "Sessione Tokyo")
lon_sess = input.session("0900-1730", "Sessione Londra")
ny_sess  = input.session("1430-2200", "Sessione New York")
length   = input.int(65, "Giorni per la Media (3 Mesi)", minval=1)

// --- 2. Impostazioni Grafiche della Tabella (Default su bottom_right) ---
table_pos  = input.string("bottom_right", "Posizione Tabella", options=["top_right", "bottom_right", "top_left", "bottom_left"])
table_size = input.string("small", "Dimensione Testo", options=["tiny", "small", "normal", "large"])
bg_col     = input.color(color.new(color.black, 20), "Colore Sfondo Tabella")

// Conversione posizione per Pine Script
t_pos = table_pos == "top_right" ? position.top_right : table_pos == "bottom_right" ? position.bottom_right : table_pos == "top_left" ? position.top_left : position.bottom_left
// Conversione dimensione testo
t_size = table_size == "tiny" ? size.tiny : table_size == "small" ? size.small : table_size == "normal" ? size.normal : size.large

// --- 3. Funzione per calcolare il Range % ---
get_session_range(sess) =>
    var float s_open = na
    var float s_high = na
    var float s_low = na
    var float s_range_pct = na
    
    in_sess = not na(time(timeframe.period, sess))
    
    if ta.change(time("D"))
        s_open := na
        s_high := na
        s_low := na
        s_range_pct := na

    if in_sess
        if na(s_open)
            s_open := open
            s_high := high
            s_low := low
        else
            s_high := math.max(s_high, high)
            s_low := math.min(s_low, low)
            
        s_range_pct := ((s_high - s_low) / s_open) * 100
        
    [s_range_pct, in_sess]

// Calcolo
[tok_pct, tok_in] = get_session_range(tok_sess)
[lon_pct, lon_in] = get_session_range(lon_sess)
[ny_pct, ny_in]   = get_session_range(ny_sess)

// Memoria per i dati storici
var float last_tok = na
var float last_lon = na
var float last_ny  = na

if ta.change(time("D"))
    if not na(tok_pct[1])
        last_tok := tok_pct[1]
    if not na(lon_pct[1])
        last_lon := lon_pct[1]
    if not na(ny_pct[1])
        last_ny := ny_pct[1]

// Medie 3 mesi
avg_tok = ta.sma(last_tok, length)
avg_lon = ta.sma(last_lon, length)
avg_ny  = ta.sma(last_ny, length)

// --- 4. Alert di Breakout della Volatilità ---
if tok_in and tok_pct > avg_tok
    alert("Tokyo ha superato il suo range medio!", alert.freq_once_per_bar)
if lon_in and lon_pct > avg_lon
    alert("Londra ha superato il suo range medio!", alert.freq_once_per_bar)
if ny_in and ny_pct > avg_ny
    alert("New York ha superato il suo range medio!", alert.freq_once_per_bar)

// --- 5. Creazione Tabella Dinamica ---
var table info_table = table.new(t_pos, 2, 4, bgcolor=bg_col, border_color=color.gray, border_width=1)

if barstate.islast
    // Header
    table.cell(info_table, 0, 0, "Sessione", text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 0, "Range Medio 3M", text_color=color.white, text_size=t_size)
    
    // Righe
    table.cell(info_table, 0, 1, "Tokyo", text_color=color.yellow, text_size=t_size)
    table.cell(info_table, 1, 1, na(avg_tok) ? "Calcolo..." : str.tostring(avg_tok, "#.##") + "%", text_color=color.white, text_size=t_size)
    
    table.cell(info_table, 0, 2, "Londra", text_color=color.blue, text_size=t_size)
    table.cell(info_table, 1, 2, na(avg_lon) ? "Calcolo..." : str.tostring(avg_lon, "#.##") + "%", text_color=color.white, text_size=t_size)
    
    table.cell(info_table, 0, 3, "New York", text_color=color.orange, text_size=t_size)
    table.cell(info_table, 1, 3, na(avg_ny) ? "Calcolo..." : str.tostring(avg_ny, "#.##") + "%", text_color=color.white, text_size=t_size)
````
