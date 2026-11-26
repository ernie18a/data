# Spread 10Y - Andamento differenziale rendimenti D/W 

- url: https://www.tradingview.com/script/CyGrFUrA/
- type: indicator
- pine_id: PUB;445a7aa5ab6a449fbcd9c6d095de3e18
- version: 1.0

## Description

Calculates changes in yield spreads on a daily and weekly basis. It helps monitor the "trend" of these changes to make short- and long-term trading decisions in the foreign exchange market.

## Source Code

````pine
//@version=5
indicator("Spread 10Y - Etichette Storiche D/W Corretto", overlay=false, max_labels_count=500)

// ==========================================
// 1. INPUT E ACQUISIZIONE DATI
// ==========================================
ticker_usa  = input.string("US10Y", "Ticker USA")
ticker_ger  = input.string("DE10Y", "Ticker GER")
soglia_iper = input.float(140.0, "Soglia Ipercomprato (bps)")
tipo_ottica = input.string("Giornaliera", "Ottica Etichette", options=["Giornaliera", "Settimanale"])

// Recupero dei dati daily nativi
yield_usa = request.security(ticker_usa, "D", close)
yield_ger = request.security(ticker_ger, "D", close)
yield_spread = (yield_usa - yield_ger) * 100

// ==========================================
// 2. LOGICA DI CONFRONTO CORRETTA (VERDE / ROSSO)
// ==========================================
// Storico giornaliero: prende il valore della candela precedente del foglio
spread_ieri = yield_spread[1]

// Storico settimanale: identifica il cambio della settimana sul tempo di borsa
bool fine_settimana = ta.change(time("W")) != 0 or barstate.islast

// Memorizzazione dinamica dello spread di chiusura della settimana scorsa
var float spread_settimana_scorsa = na
if fine_settimana[1]
    spread_settimana_scorsa := yield_spread[1]

// Definizione dinamica del colore basata sull'ottica reale
color colore_dinamico = color.gray
bool mostra_etichetta = false

if tipo_ottica == "Giornaliera"
    colore_dinamico := yield_spread >= spread_ieri ? color.green : color.red
    mostra_etichetta := ta.change(time("D")) != 0
else
    // Ottica Settimanale (Applica il colore confrontando i dati di venerdì in venerdì)
    colore_dinamico := yield_spread >= spread_settimana_scorsa ? color.green : color.red
    mostra_etichetta := fine_settimana

// ==========================================
// 3. FILTRO PREZZO EMA 50 E ALERT
// ==========================================
ema50_prezzo = ta.ema(close, 50)
tolleranza   = close * 0.0005
test_ema50   = math.abs(close - ema50_prezzo) <= tolleranza
condizione_alert = test_ema50 and (yield_spread >= soglia_iper)

if condizione_alert
    alert("ATTENZIONE EURO FUTURE: Prezzo su EMA 50 e Spread a " + str.tostring(yield_spread, "#.#") + " bps!", alert.freq_once_per_bar_close)

// ==========================================
// 4. GRAFICA ED ETICHETTE STORICHE MULTI-COLORE
// ==========================================
plot(yield_spread, "Spread bps", color=colore_dinamico, linewidth=2)
hline(soglia_iper, "Soglia", color=color.gray, linestyle=hline.style_dashed)
plotshape(condizione_alert, "Inversione", shape.triangleup, location=location.bottom, color=color.green, size=size.small)

if mostra_etichetta and not na(yield_spread)
    string testo_etichetta = str.tostring(yield_spread, "#.#")
    label.new(
         x=bar_index, 
         y=yield_spread, 
         text=testo_etichetta, 
         color=colore_dinamico, 
         textcolor=color.white, 
         style=label.style_label_down, 
         size=size.small
         )
````
