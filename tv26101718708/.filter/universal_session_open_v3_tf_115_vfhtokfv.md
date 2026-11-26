# Universal Session Open V.3 - TF 1/15

- url: https://www.tradingview.com/script/vfHToKfv/
- type: indicator
- pine_id: PUB;c6dd8cf006844bc98418c3ffce6dee13
- version: 1.0

## Description

DESCRIZIONE DELLO SCRIPT:
Cos'è Universal Session Open V3?
L’Universal Session Open V3 è un indicatore avanzato studiato per lavorare sui timeframe a 1 e 15 minuti. È progettato per i trader che vogliono unire la ciclicità del tempo (le sessioni di borsa) con la precisione millimetrica dei volumi (Volume Profile e vPOC).

Lo scopo di questo strumento è mappare con esattezza l'attività delle tre sessioni principali (Tokyo, Londra e New York) per individuare i livelli in cui le istituzioni hanno accumulato i massimi volumi.

Caratteristiche Principali
Tracciamento Sessioni Intraday: Evidenzia l'apertura esatta di Tokyo, Londra e New York con linee e label dedicate.

Volume Profile Integrato: Calcola e traccia in tempo reale il POC (Point of Control), il VAH (Value Area High) e il VAL (Value Area Low) di ciascuna sessione.

Virgin POC (vPOC) Dinamici: Alla chiusura di ogni sessione, se il POC non è stato toccato, l'indicatore lo trasforma in un vPOC tratteggiato e semi-trasparente, estendendolo verso destra. La linea si interrompe automaticamente nel momento esatto in cui il prezzo la tocca nel futuro.

Grafica Ottimizzata per SMC: I colori e i livelli sono studiati per essere puliti e riposanti, perfetti per essere usati insieme ad altri indicatori (es. FVG e SMC).

Come Imposto la Mia Operatività (La Strategia di Confluenza)
Per ottenere il massimo da questo indicatore, vi spiego la mia regola di trading ferrea che unisce struttura, tempo e volume:

Identifico la Fascia SMC: Aspetto che il prezzo entri in una zona di interesse istituzionale. Uso i rettangoli Rosa (Premium/Supply) per cercare vendite e i rettangoli Blu (Discount/Demand) per cercare acquisti.

Cerco la Confluenza con il vPOC: Guardo se all'interno di quella fascia è presente un vPOC non mitigato (linea rosa tratteggiata generata dall'indicatore).

Controllo le Conferme nella Dashboard: Verifico sulla dashboard che la borsa attuale mostri un'estensione del volume significativa e che la pressione Buy/Sell (Delta) confermi l'inversione.

Il Trigger d'Ingresso: Se il vPOC è dentro la fascia e i volumi confermano, quello è il mio livello esatto per piazzare l'ordine.

Gestione dello Stop Loss e del Rischio
Lo Stop Loss va posizionato sempre appena fuori dalla fascia SMC (sotto la fascia blu per i Long, sopra la fascia rosa per gli Short). Questo permette di rischiare pochissimi pip a fronte di guadagni molto più grandi, mantenendo un Risk/Reward medio di 1:3 o superiore. Se il prezzo tocca un vPOC che si trova nel "vuoto" (fuori dalle fasce di ordine SMC), lo ignoro.

NOTE PER LA COMMUNITY:
Questo indicatore viene rilasciato gratuitamente per tutti i trader che vogliono fare un salto di qualità nella lettura dei volumi e delle sessioni. Se lo trovi utile per il tuo trading, lascia un "Boost" e aggiungilo ai preferiti!

________

What is Universal Session Open V3?
Universal Session Open V3 is an advanced indicator specifically designed for 1-minute and 15-minute timeframes. It is tailored for traders who want to combine time cycles (market sessions) with precise volume data (Volume Profile and vPOCs).

This tool accurately maps the activity of the three major trading sessions (Tokyo, London, and New York) to identify the exact levels where institutions have accumulated the highest trading volume.

Key Features
Intraday Session Tracking: Highlights the exact opening prices for Tokyo, London, and New York with dedicated lines and labels.

Integrated Volume Profile: Calculates and plots the POC (Point of Control), VAH (Value Area High), and VAL (Value Area Low) for each session in real-time.

Dynamic Virgin POCs (vPOC): At the end of each session, if the POC remains untouched, the indicator converts it into a dashed, semi-transparent vPOC line and extends it to the right. The line automatically stops plotting the exact moment price mitigates it in the future.

Optimized for SMC: Colors and levels are clean and non-intrusive, making it the perfect companion for other indicators like FVG and SMC setups.

Trading Strategy & Confluence Rules
To get the most out of this indicator, here is my strict trading plan combining structure, time, and volume:

Identify the SMC Zone: Wait for the price to enter an institutional area of interest. Use Pink rectangles (Premium/Supply) for shorts and Blue rectangles (Discount/Demand) for longs.

Find the vPOC Confluence: Check if there is an unmitigated vPOC (dashed pink line created by the indicator) lying inside that specific SMC zone.

Check the Dashboard Confirmations: Look at your volume dashboard to verify that the current session shows significant volume extension and that the Buy/Sell pressure (Delta) confirms the reversal.

The Entry Trigger: If the vPOC is inside the zone and volume confirms it, that is the exact level to place the order.

Risk Management & Stop Loss
Always place the Stop Loss just outside the SMC zone (below the blue zone for Longs, above the pink zone for Shorts). This allows for a very tight Stop Loss and much larger targets, maintaining a Risk/Reward ratio of 1:3 or higher. If the price touches a vPOC that sits in "no man's land" (outside of valid SMC zones), ignore it.

NOTES FOR THE COMMUNITY:
This indicator is released for free to help traders level up their volume and session analysis. If you find it useful, please leave a Boost and add it to your favorites!

## Source Code

````pine
//@version=5
indicator("Universal Session Open V.3 - TF 1/15", overlay=true, max_lines_count=500)

// ==========================================
// CONFIGURAZIONE INPUT
// ==========================================
tokyo_sess  = input.session("0000-0900", "Orario Tokyo", group="Orari Borse")
london_sess = input.session("0900-1730", "Orario Londra", group="Orari Borse")
ny_sess     = input.session("1430-2200", "Orario New York", group="Orari Borse")

// Colori Aperture
c_tokyo  = input.color(color.yellow, "Colore Apertura Tokyo", group="Colori Aperture")
c_london = input.color(color.blue, "Colore Apertura Londra", group="Colori Aperture")
c_ny     = input.color(color.orange, "Colore Apertura New York", group="Colori Aperture")

// Impostazioni Volume Profile
show_vp     = input.bool(true, "Mostra Volume Profile (POC, VAH, VAL)", group="Impostazioni Volume Profile")
rows_count  = input.int(30, "Precisione Profilo (Numero livelli)", minval=10, maxval=100, group="Impostazioni Volume Profile")
c_poc       = input.color(color.white, "Colore POC Corrente", group="Impostazioni Volume Profile")
c_va        = input.color(color.new(color.gray, 30), "Colore Value Area (VAH/VAL)", group="Impostazioni Volume Profile")

// Impostazioni Virgin POC (vPOC)
show_vpoc   = input.bool(true, "Estendi Virgin POC (vPOC)", group="Impostazioni vPOC")

// MODIFICA QUI: Colore rosa semi-trasparente e stile tratteggiato
c_vpoc      = input.color(color.new(#d681a9, 40), "Colore vPOC (Desaturato/Semi-trasparente)", group="Impostazioni vPOC")
s_vpoc      = line.style_dashed // Stile tratteggiato per default per i vPOC

// ==========================================
// FUNZIONI DI CONTROLLO SESSIONE
// ==========================================
is_open(sess) =>
    in_sess = not na(time(timeframe.period, sess, "GMT+2"))
    in_sess and not in_sess[1]

in_session(sess) =>
    not na(time(timeframe.period, sess, "GMT+2"))

is_close(sess) =>
    in_sess = not na(time(timeframe.period, sess, "GMT+2"))
    in_sess[1] and not in_sess

// ==========================================
// STRUTTURE DATI E VARIABILI PER IL VOLUME PROFILE
// ==========================================
var float[] tk_prices = array.new_float(0)
var float[] tk_volumes = array.new_float(0)
var float[] ld_prices = array.new_float(0)
var float[] ld_volumes = array.new_float(0)
var float[] ny_prices = array.new_float(0)
var float[] ny_volumes = array.new_float(0)

// Linee e Label correnti
var line open_tk = na, var line poc_tk = na, var line vah_tk = na, var line val_tk = na
var line open_ld = na, var line poc_ld = na, var line vah_ld = na, var line val_ld = na
var line open_ny = na, var line poc_ny = na, var line vah_ny = na, var line val_ny = na

var label lbl_open_tk = na, var label lbl_poc_tk = na, var label lbl_vah_tk = na, var label lbl_val_tk = na
var label lbl_open_ld = na, var label lbl_poc_ld = na, var label lbl_vah_ld = na, var label lbl_val_ld = na
var label lbl_open_ny = na, var label lbl_poc_ny = na, var label lbl_vah_ny = na, var label lbl_val_ny = na

// Array storici per tracciamento Virgin POC attivi
var line[] active_vpocs = array.new_line(0)
var label[] active_vpoc_lbls = array.new_label(0)

// Funzione interna per calcolare POC, VAH, VAL
calc_vp(prices, volumes) =>
    if array.size(prices) > 0 and array.size(volumes) > 0
        max_vol = 0.0
        float poc_p = na 
        total_vol = 0.0
        
        for i = 0 to array.size(volumes) - 1
            v = array.get(volumes, i)
            total_vol := total_vol + v
            if v > max_vol
                max_vol := v
                poc_p := array.get(prices, i)
        
        va_target = total_vol * 0.70
        va_current = max_vol
        
        poc_index = 0
        for i = 0 to array.size(prices) - 1
            if array.get(prices, i) == poc_p
                poc_index := i
                break
                
        up_idx = poc_index
        dn_idx = poc_index
        
        while va_current < va_target and (up_idx < array.size(prices) - 1 or dn_idx > 0)
            v_up = up_idx < array.size(prices) - 1 ? array.get(volumes, up_idx + 1) : 0.0
            v_dn = dn_idx > 0 ? array.get(volumes, dn_idx - 1) : 0.0
            
            if v_up >= v_dn
                up_idx := up_idx + 1
                va_current := va_current + v_up
            else
                dn_idx := dn_idx - 1
                va_current := va_current + v_dn
                
        vah_p = array.get(prices, up_idx)
        val_p = array.get(prices, dn_idx)
        [poc_p, vah_p, val_p]
    else
        [na, na, na]

// ==========================================
// LOGICA DI TRACCIAMENTO SESSIONI E vPOC
// ==========================================

// --- TOKYO ---
if is_open(tokyo_sess)
    open_tk := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=c_tokyo, width=2)
    lbl_open_tk := label.new(x=bar_index, y=open, text="TK Open", color=color.new(color.black, 100), textcolor=c_tokyo, style=label.style_label_left, size=size.small)
    poc_tk := na, vah_tk := na, val_tk := na 
    array.clear(tk_prices)
    array.clear(tk_volumes)
    if not na(high) and not na(low)
        step = (high - low) / rows_count
        for i = 0 to rows_count - 1
            array.push(tk_prices, low + (step * i))
            array.push(tk_volumes, 0.0)

if in_session(tokyo_sess)
    line.set_x2(open_tk, bar_index)
    label.set_x(lbl_open_tk, bar_index)
    if array.size(tk_prices) > 0
        for i = 0 to array.size(tk_prices) - 1
            p = array.get(tk_prices, i)
            if high >= p and low <= p
                array.set(tk_volumes, i, array.get(tk_volumes, i) + (volume / rows_count))
    
    if show_vp
        [poc, vah, val] = calc_vp(tk_prices, tk_volumes)
        if not na(poc)
            if na(poc_tk)
                poc_tk := line.new(x1=line.get_x1(open_tk), y1=poc, x2=bar_index, y2=poc, color=c_poc, width=2)
                vah_tk := line.new(x1=line.get_x1(open_tk), y1=vah, x2=bar_index, y2=vah, color=c_va, width=1, style=line.style_dashed)
                val_tk := line.new(x1=line.get_x1(open_tk), y1=val, x2=bar_index, y2=val, color=c_va, width=1, style=line.style_dashed)
                
                lbl_poc_tk := label.new(x=bar_index, y=poc, text="TK POC", color=color.new(color.black, 100), textcolor=c_poc, style=label.style_label_left, size=size.small)
                lbl_vah_tk := label.new(x=bar_index, y=vah, text="TK VAH", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
                lbl_val_tk := label.new(x=bar_index, y=val, text="TK VAL", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
            else
                line.set_x2(poc_tk, bar_index), line.set_y1(poc_tk, poc), line.set_y2(poc_tk, poc)
                line.set_x2(vah_tk, bar_index), line.set_y1(vah_tk, vah), line.set_y2(vah_tk, vah)
                line.set_x2(val_tk, bar_index), line.set_y1(val_tk, val), line.set_y2(val_tk, val)
                
                label.set_x(lbl_poc_tk, bar_index), label.set_y(lbl_poc_tk, poc)
                label.set_x(lbl_vah_tk, bar_index), label.set_y(lbl_vah_tk, vah)
                label.set_x(lbl_val_tk, bar_index), label.set_y(lbl_val_tk, val)

if is_close(tokyo_sess) and show_vpoc and not na(poc_tk)
    // MODIFICA QUI: Applica il colore desaturato, riduce l'opacità e lo stile tratteggiato
    line.set_color(poc_tk, c_vpoc)
    line.set_style(poc_tk, s_vpoc) 
    
    label.delete(lbl_poc_tk) 
    v_lbl = label.new(x=bar_index, y=line.get_y1(poc_tk), text="TK vPOC", color=color.new(color.black, 100), textcolor=c_vpoc, style=label.style_label_left, size=size.small)
    array.push(active_vpocs, poc_tk)
    array.push(active_vpoc_lbls, v_lbl)

// --- LONDRA ---
if is_open(london_sess)
    open_ld := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=c_london, width=2)
    lbl_open_ld := label.new(x=bar_index, y=open, text="LD Open", color=color.new(color.black, 100), textcolor=c_london, style=label.style_label_left, size=size.small)
    poc_ld := na, vah_ld := na, val_ld := na
    array.clear(ld_prices)
    array.clear(ld_volumes)
    if not na(high) and not na(low)
        step = (high - low) / rows_count
        for i = 0 to rows_count - 1
            array.push(ld_prices, low + (step * i))
            array.push(ld_volumes, 0.0)

if in_session(london_sess)
    line.set_x2(open_ld, bar_index)
    label.set_x(lbl_open_ld, bar_index)
    if array.size(ld_prices) > 0
        for i = 0 to array.size(ld_prices) - 1
            p = array.get(ld_prices, i)
            if high >= p and low <= p
                array.set(ld_volumes, i, array.get(ld_volumes, i) + (volume / rows_count))
    
    if show_vp
        [poc, vah, val] = calc_vp(ld_prices, ld_volumes)
        if not na(poc)
            if na(poc_ld)
                poc_ld := line.new(x1=line.get_x1(open_ld), y1=poc, x2=bar_index, y2=poc, color=c_poc, width=2)
                vah_ld := line.new(x1=line.get_x1(open_ld), y1=vah, x2=bar_index, y2=vah, color=c_va, width=1, style=line.style_dashed)
                val_ld := line.new(x1=line.get_x1(open_ld), y1=val, x2=bar_index, y2=val, color=c_va, width=1, style=line.style_dashed)
                
                lbl_poc_ld := label.new(x=bar_index, y=poc, text="LD POC", color=color.new(color.black, 100), textcolor=c_poc, style=label.style_label_left, size=size.small)
                lbl_vah_ld := label.new(x=bar_index, y=vah, text="LD VAH", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
                lbl_val_ld := label.new(x=bar_index, y=val, text="LD VAL", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
            else
                line.set_x2(poc_ld, bar_index), line.set_y1(poc_ld, poc), line.set_y2(poc_ld, poc)
                line.set_x2(vah_ld, bar_index), line.set_y1(vah_ld, vah), line.set_y2(vah_ld, vah)
                line.set_x2(val_ld, bar_index), line.set_y1(val_ld, val), line.set_y2(val_ld, val)
                
                label.set_x(lbl_poc_ld, bar_index), label.set_y(lbl_poc_ld, poc)
                label.set_x(lbl_vah_ld, bar_index), label.set_y(lbl_vah_ld, vah)
                label.set_x(lbl_val_ld, bar_index), label.set_y(lbl_val_ld, val)

if is_close(london_sess) and show_vpoc and not na(poc_ld)
    line.set_color(poc_ld, c_vpoc)
    line.set_style(poc_ld, s_vpoc) // Applica stile tratteggiato
    
    label.delete(lbl_poc_ld)
    v_lbl = label.new(x=bar_index, y=line.get_y1(poc_ld), text="LD vPOC", color=color.new(color.black, 100), textcolor=c_vpoc, style=label.style_label_left, size=size.small)
    array.push(active_vpocs, poc_ld)
    array.push(active_vpoc_lbls, v_lbl)

// --- NEW YORK ---
if is_open(ny_sess)
    open_ny := line.new(x1=bar_index, y1=open, x2=bar_index, y2=open, color=c_ny, width=2)
    lbl_open_ny := label.new(x=bar_index, y=open, text="NY Open", color=color.new(color.black, 100), textcolor=c_ny, style=label.style_label_left, size=size.small)
    poc_ny := na, vah_ny := na, val_ny := na
    array.clear(ny_prices)
    array.clear(ny_volumes)
    if not na(high) and not na(low)
        step = (high - low) / rows_count
        for i = 0 to rows_count - 1
            array.push(ny_prices, low + (step * i))
            array.push(ny_volumes, 0.0)

if in_session(ny_sess)
    line.set_x2(open_ny, bar_index)
    label.set_x(lbl_open_ny, bar_index)
    if array.size(ny_prices) > 0
        for i = 0 to array.size(ny_prices) - 1
            p = array.get(ny_prices, i)
            if high >= p and low <= p
                array.set(ny_volumes, i, array.get(ny_volumes, i) + (volume / rows_count))
    
    if show_vp
        [poc, vah, val] = calc_vp(ny_prices, ny_volumes)
        if not na(poc)
            if na(poc_ny)
                poc_ny := line.new(x1=line.get_x1(open_ny), y1=poc, x2=bar_index, y2=poc, color=c_poc, width=2)
                vah_ny := line.new(x1=line.get_x1(open_ny), y1=vah, x2=bar_index, y2=vah, color=c_va, width=1, style=line.style_dashed)
                val_ny := line.new(x1=line.get_x1(open_ny), y1=val, x2=bar_index, y2=val, color=c_va, width=1, style=line.style_dashed)
                
                lbl_poc_ny := label.new(x=bar_index, y=poc, text="NY POC", color=color.new(color.black, 100), textcolor=c_poc, style=label.style_label_left, size=size.small)
                lbl_vah_ny := label.new(x=bar_index, y=vah, text="NY VAH", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
                lbl_val_ny := label.new(x=bar_index, y=val, text="NY VAL", color=color.new(color.black, 100), textcolor=c_va, style=label.style_label_left, size=size.small)
            else
                line.set_x2(poc_ny, bar_index), line.set_y1(poc_ny, poc), line.set_y2(poc_ny, poc)
                line.set_x2(vah_ny, bar_index), line.set_y1(vah_ny, vah), line.set_y2(vah_ny, vah)
                line.set_x2(val_ny, bar_index), line.set_y1(val_ny, val), line.set_y2(val_ny, val)
                
                label.set_x(lbl_poc_ny, bar_index), label.set_y(lbl_poc_ny, poc)
                label.set_x(lbl_vah_ny, bar_index), label.set_y(lbl_vah_ny, vah)
                label.set_x(lbl_val_ny, bar_index), label.set_y(lbl_val_ny, val)

if is_close(ny_sess) and show_vpoc and not na(poc_ny)
    line.set_color(poc_ny, c_vpoc)
    line.set_style(poc_ny, s_vpoc) // Applica stile tratteggiato
    
    label.delete(lbl_poc_ny)
    v_lbl = label.new(x=bar_index, y=line.get_y1(poc_ny), text="NY vPOC", color=color.new(color.black, 100), textcolor=c_vpoc, style=label.style_label_left, size=size.small)
    array.push(active_vpocs, poc_ny)
    array.push(active_vpoc_lbls, v_lbl)

// ==========================================
// CONTROLLO CONTINUO SUI vPOC
// ==========================================
if array.size(active_vpocs) > 0
    for i = array.size(active_vpocs) - 1 to 0
        l = array.get(active_vpocs, i)
        lbl = array.get(active_vpoc_lbls, i)
        y = line.get_y1(l)
        
        if (high >= y and low <= y) or barstate.islast
            if high >= y and low <= y
                array.remove(active_vpocs, i)
                array.remove(active_vpoc_lbls, i)
        else
            line.set_x2(l, bar_index)
            label.set_x(lbl, bar_index)

// ==========================================
// SEGNALI DI ALERT
// ==========================================
alertcondition(is_open(tokyo_sess), title="Apertura Tokyo", message="Tokyo Session Open!")
alertcondition(is_open(london_sess), title="Apertura Londra", message="London Session Open!")
alertcondition(is_open(ny_sess), title="Apertura New York", message="New York Session Open!")
````
