# [PRO] Professional Range Filter + EMA 200: Balanced Trend Rider

- url: https://www.tradingview.com/script/mwSUf2kN/
- type: indicator
- pine_id: PUB;807c09dab7e545fc94bbcc5b179178ce
- version: 1.0

## Description

Questo indicatore è una soluzione completa per il Trend Following, progettata per identificare ingressi ad alta precisione filtrando il rumore del mercato laterale. Combina la reattività del Range Filter con la solidità della EMA 200, integrando un filtro dinamico basato sui volumi per evitare i falsi segnali tipici dei mercati piatti.

La logica si basa sulla "Price Action" adattiva: non cerchiamo di indovinare il massimo o il minimo, ma seguiamo la forza del mercato quando viene confermata da volumi istituzionali.

🛠 Caratteristiche Principali
Filtro Trend Madre (EMA 200): Una regola d'oro del trading. Cerchiamo solo ingressi Long se il prezzo è sopra la media a 200 periodi e Short se è al di sotto.

Range Filter Adattivo: Utilizza un calcolo basato sulla volatilità (ATR) per creare una linea di trend dinamica che segue il prezzo, fungendo sia da trigger di ingresso che da trailing stop.

Anti-Flat Volume Filter: Una funzione intelligente che blocca i segnali se il volume della candela corrente è inferiore alla media (SMA 20). Questo permette di scartare i breakout deboli e le fasi di consolidamento notturno o pre-apertura.

Clean Signals (State Machine): Il codice include una gestione dello stato per evitare lo "spam" di segnali. Una volta generato un BUY, l'indicatore non ripeterà il segnale finché non si verificherà una condizione opposta, mantenendo il grafico pulito e leggibile.

📈 Come usarlo
Ingresso Long: Il Range Filter diventa Verde, il prezzo chiude sopra la EMA 200 e i volumi confermano la spinta.

Ingresso Short: Il Range Filter diventa Rosso, il prezzo chiude sotto la EMA 200 e i volumi confermano la spinta.

Uscita: Puoi utilizzare il cambio di colore del filtro o impostare un Take Profit basato sulla distanza dal filtro stesso.

⚙️ Impostazioni Consigliate
L'indicatore è ottimizzato per il timeframe a 5 minuti e 15 minuti, ma può essere adattato a qualsiasi asset:

Scalping (5m): Mantieni il Range Multiplier tra 2.5 e 3.0.

Swing Trading (1h+): Aumenta il Range Period a 150 per segnali ancora più filtrati e duraturi.

⚠️ Disclaimer
Il trading comporta rischi. Questo script è fornito a scopo educativo e non costituisce una consulenza finanziaria. Esegui sempre dei backtest prima di utilizzarlo in un conto reale.

🏷 Tag (per la ricerca)
Trend Analysis Range Filter EMA Volume Scalping Trading Strategy

## Source Code

````pine
//@version=5
indicator("Professional RF: Balanced Edition", overlay=true)

// ==========================================
// 1. INPUT PARAMETRI
// ==========================================
emaLength   = input.int(200, title="Filtro Trend (EMA 200)")
rfPer       = input.int(100, title="Range Period")
rfMult      = input.float(3.0, title="Range Multiplier")

// Filtro Volume (Più leggero dell'ADX)
useVolFilter = input.bool(true, title="Usa Filtro Volume (Anti-Flat)")
volLength    = input.int(20, title="Media Volume")

// ==========================================
// 2. CALCOLI TECNICI
// ==========================================
// EMA 200
ema200 = ta.ema(close, emaLength)

// Range Filter Logic
var float filter = na
smrng = ta.ema(ta.atr(1), rfPer) * rfMult
filter := close > nz(filter[1]) ? math.max(nz(filter[1]), close - smrng) : math.min(nz(filter[1]), close + smrng)

// Calcolo Volume
volAvg = ta.sma(volume, volLength)
volConfirm = useVolFilter ? volume >= volAvg : true

// Direzione
bool isUpward = close > filter
bool isDownward = close < filter

// ==========================================
// 3. LOGICA SEGNALI PULITI (ANTI-RUMORE)
// ==========================================
var int lastSignal = 0 

// Condizione Buy: Filtro gira, sopra EMA 200, conferma Volume
buyCond = isUpward and not (close[1] > filter[1]) and close > ema200 and volConfirm and lastSignal <= 0
if buyCond
    lastSignal := 1

// Condizione Sell: Filtro gira, sotto EMA 200, conferma Volume
sellCond = isDownward and not (close[1] < filter[1]) and close < ema200 and volConfirm and lastSignal >= 0
if sellCond
    lastSignal := -1

// ==========================================
// 4. VISUALIZZAZIONE
// ==========================================
plot(filter, color=isUpward ? color.green : color.red, linewidth=3, title="Range Filter")
plot(ema200, color=color.new(color.yellow, 50), title="EMA 200")

plotshape(buyCond,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.green, size=size.small, text="BUY",  textcolor=color.white)
plotshape(sellCond, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red,   size=size.small, text="SELL", textcolor=color.white)

// Alert
alertcondition(buyCond,  "BUY",  "Segnale BUY con Volumi!")
alertcondition(sellCond, "SELL", "Segnale SELL con Volumi!")
````
