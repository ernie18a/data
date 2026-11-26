# Bubble volume engine xjump

- url: https://www.tradingview.com/script/FaHVuJmM-Bubble-volume-engine-xjump/
- type: indicator
- pine_id: PUB;b1d0945b51354c9abef21dae5dce97f2
- version: 1.0

## Description

Ecco una descrizione pronta da usare. Te la do in tre versioni di lunghezza diversa, scegli quella che ti serve in base al canale dove la pubblichi (TradingView ha limiti diversi da una pagina blog o un README).

📝 Versione SHORT — TradingView "Short description" (1-2 righe)
Motore di lettura dell'order flow che combina Delta Volume, struttura candela, sweep di liquidità, divergenze CVD e trend HTF in un sistema a confluenza 5★. Auto-tuning su tutti i timeframe.

📄 Versione MEDIUM — Descrizione TradingView completa
Volume Flow Engine PRO trasforma il Delta Volume da semplice indicatore in un motore completo di lettura del flusso. Invece di mostrarti solo "dove sono i compratori vs venditori", combina cinque livelli di contesto — delta normalizzato, struttura candela, liquidità, volume relativo, trend di timeframe superiore — in un punteggio di confluenza da 0 a 5 stelle che decide visivamente l'importanza di ogni segnale.

Cosa rileva:

Bolle delta posizionate dentro le candele, dimensionate sulla forza statistica del flusso (z-score)
Assorbimento di liquidità — quando il prezzo sweepa un massimo/minimo ma chiude contro il delta, segnale di smart money che assorbe gli stop
Divergenze CVD/Prezzo — quando il Cumulative Delta diverge dal prezzo, segnale di esaurimento del movimento
Pattern VSA — Up Thrust, Spring, No Demand, No Supply per leggere accumulazione e distribuzione
Filtro Trend HTF — premia le bolle allineate al trend del timeframe superiore, scarta quelle controtrend
VWAP intracandela — verifica che chi ha spinto sia rimasto dominante fino alla chiusura
Auto-tuning per timeframe: Lo script riconosce automaticamente se sei su 1m, 5m, 15m, 1h, 4h, Daily, e regola da solo Lower Timeframe, Higher Timeframe, dimensione bolle, soglie di filtro e modalità no-repaint. Puoi anche disattivare l'auto-mode e configurare tutto manualmente.

Dashboard integrata nell'angolo del grafico riassume lo stato corrente: delta, z-score, score di confluenza, trend HTF, direzione CVD, posizione vs VWAP, e una riga "Stato" che traduce tutto in un'azione leggibile (STRONG BUY, BUY ABSORB, DIV BEARISH, ecc.).

Non è un indicatore di entry/exit automatici. È uno strumento di lettura del flusso che ti dice quando il mercato sta facendo qualcosa di rilevante e perché. Sta a te decidere cosa farne.

Funziona su tutti gli strumenti volume-enabled: crypto, futures, azioni, indici, forex pairs maggiori.

📚 Versione LONG — Per descrizione dettagliata, README, blog, manuale
Cos'è Volume Flow Engine PRO
È un indicatore TradingView (Pine v6) che legge il flusso di ordini ricostruendo il Delta Volume dai dati di un timeframe inferiore, e lo arricchisce con il contesto necessario perché un segnale di delta possa diventare un segnale operativo. Il delta da solo è spesso bugiardo: un volume di acquisto enorme può essere assorbito da venditori più forti, una candela rialzista può nascondere distribuzione, un breakout con delta perfetto può essere un trap di liquidità. Questo script affronta esattamente questo problema.

La filosofia
Tre principi guidano il design:

1. Il delta va contestualizzato. Un delta di +1000 contratti significa cose diverse su BTC e su EURUSD. Lo z-score normalizza il delta sulla sua deviazione standard locale, rendendo la forza confrontabile tra strumenti e periodi.

2. La confluenza vale più del singolo segnale. Una bolla con score 1/5 vale molto poco. Una con 5/5 sta segnalando che delta, volume, struttura, liquidità e trend HTF stanno dicendo la stessa cosa. Lo script ti aiuta a distinguerle visivamente con colore, dimensione e trasparenza graduati.

3. L'occhio deve leggere prima del cervello. Le bolle stanno dentro la candela, la dimensione è proporzionale alla forza, le divergenze hanno background colorato, i pattern VSA hanno marker chiari. Apri il grafico e in due secondi sai dove guardare.

Cosa fa, in dettaglio
Delta Volume con z-score — Richiede al timeframe inferiore (1s, 1m, 5m, ecc. a seconda del grafico) i dati di volume up/down, calcola il delta netto per ogni candela, e lo normalizza con media e deviazione standard a 20 periodi. Il risultato è uno z-score con segno che ti dice quante deviazioni standard sopra/sotto la media è il delta corrente. Sopra 1.5σ = "aggressivo", sopra 2σ = "estremo".

Bolle dentro la candela — Posizione direzionale: bolle buy al 65% del range della candela, bolle sell al 35%. Quando lo score sale, la bolla migra verso il centro del corpo (segnale forte e ben centrato). Dimensione scalata su 5 livelli (Tiny/Small/Normal/Large/Huge) in base al z-score, con cap utente per evitare bolle che escono dalle candele su zoom out.

Assorbimento di liquidità — Detection: la candela ha sweepato il massimo (o minimo) delle ultime 20 candele, ma chiude dalla parte opposta, mentre il delta è contro la chiusura. Tradotto: i venditori (o compratori) hanno preso liquidità sopra/sotto un livello, ma qualcuno di più grande ha assorbito tutto e ha portato il prezzo nella direzione opposta. Marcato con triangolo cyan (ABS+) o arancione (ABS-) e bolla dedicata.

Divergenze CVD/Prezzo — Calcola un CVD locale (somma rolling del delta su 50 candele), individua i pivot di prezzo e di CVD, e quando prezzo fa nuovo massimo ma CVD no (o viceversa), segnala divergenza con label rossa/verde sopra/sotto la candela e background colorato. Questa è la feature predittiva più potente dello script.

Pattern VSA classici — Up Thrust (candela rialzista con wick lungo in alto e volume alto = falso breakout up), Spring (specchio in basso), No Demand (rialzo con volume basso = compratori assenti), No Supply (ribasso con volume basso = venditori assenti). Marker piccoli e discreti sopra/sotto la candela.

Filtro Trend HTF — Confronta la chiusura di un timeframe superiore (auto: 4-6× il TF corrente) con una EMA 50. Se la chiusura è sopra = trend bull HTF, sotto = bear. Le bolle allineate al trend HTF ottengono +1 al score, quelle contro -1 e diventano più trasparenti. Disattivabile.

VWAP intracandela — Calcola il VWAP usando i dati LTF della singola candela. Se la chiusura è dalla parte del delta (delta+ con close > VWAP intracandela, o delta- con close < VWAP), bonus +1 al score. Significa che chi ha spinto è rimasto dominante fino al close.

Confluence Score 0–5★ — Somma di cinque condizioni base (delta allineato alla direzione candela, volume relativo confermato, delta strong z-score, sweep liquidità rilevato, struttura candela espansiva) più bonus/malus da HTF trend e VWAP. Clampato 0-5. Visualizzato come stelle nelle etichette e come trasparenza graduata della bolla.

Effort vs Result — Pattern VSA bonus: alto volume + corpo candela piccolo = sforzo enorme senza risultato, tipico di assorbimento o distribuzione in corso. Marcato con piccolo diamante giallo al centro candela.

Auto-Tuning Timeframe — Riconosce automaticamente la categoria del timeframe del grafico (Scalping, Intraday breve/medio/lungo, Swing, Position, Long-term) e applica preset coerenti per LTF, HTF, dimensione bolle massima, filtro display e modalità confirmed-only. Cambia TF nel grafico → tutto si riconfigura. Se vuoi override su qualcosa, basta disattivare Auto e usare i valori manuali.

Dashboard operativa — Tabella in angolo a scelta (5 posizioni, 3 dimensioni) che riassume in 8 righe: Modalità (Auto/Manual), preset attivo, Delta corrente, Z-Score in σ, Score in stelle, stato HTF Trend, direzione CVD, posizione vs VWAP intracandela, e riga Stato che traduce tutto in label leggibile (STRONG BUY, STRONG SELL, BUY ABSORB, SELL ABSORB, DIV BULLISH, DIV BEARISH, UT, SP, ND, NS, Neutro).

Modalità no-repaint — Toggle che mostra tutti i marker solo a barra chiusa. Auto-attivata su scalping e intraday breve (dove il rumore intra-bar inganna di più), disattivata su TF medi e alti (dove vuoi vedere il flusso che si forma).

11 alert configurabili — Delta Bubble, Buy/Sell Delta Bubble, Buy/Sell Absorption, Alta Confluenza (4★+), Massima Confluenza (5★), Up Thrust, Spring, CVD Bullish/Bearish Divergence, Effort vs Result. Tutti collegabili a webhook o notifiche.

Per chi è
Tradisti che usano l'order flow come edge primario o come filtro di conferma su sistemi tecnici. Funziona bene su qualsiasi mercato con dati di volume affidabili: crypto perpetuals e spot, futures CME/CBOE, azioni US/EU principali, indici, forex pairs maggiori. Non funziona su strumenti senza volume reale (alcuni forex broker, ticker sintetici, indici calcolati).

Cosa NON è
Non è un sistema di entry/exit. Non genera segnali long/short automatici. Non garantisce nulla. È uno strumento di lettura del mercato — ti dice quando sta succedendo qualcosa di interessante e cosa, ma sta a te integrarlo nel tuo processo decisionale e gestire il rischio.

What is Volume Flow Engine PRO
A TradingView Pine v6 indicator that reads order flow by reconstructing Volume Delta from lower timeframe data, then enriches it with the context required to turn a raw delta signal into an actionable one. Delta alone is often misleading: massive buy volume can be absorbed by stronger sellers, a bullish candle can hide distribution, a clean breakout with perfect delta can be a liquidity trap. This script addresses exactly that problem.
The philosophy
Three principles drive the design:
1. Delta needs context. A delta of +1000 contracts means very different things on BTC and EURUSD. The z-score normalizes delta against its local standard deviation, making strength comparable across symbols and time periods.
2. Confluence beats single signals. A 1/5 score bubble is noise. A 5/5 bubble is telling you that delta, volume, structure, liquidity, and HTF trend are all saying the same thing. The script helps you tell them apart visually, with graduated color, size, and transparency.
3. The eye reads before the brain. Bubbles sit inside the candle, size scales with strength, divergences get colored backgrounds, VSA patterns get distinct markers. Open the chart and within two seconds you know where to look.
What it does, in detail
Volume Delta with z-score — Requests up/down volume data from a lower timeframe (1s, 1m, 5m, etc. depending on the chart), computes net delta per candle, and normalizes it with a 20-period rolling mean and standard deviation. The result is a signed z-score telling you how many standard deviations above or below average the current delta is. Above 1.5σ = "aggressive", above 2σ = "extreme".
Bubbles inside the candle — Directional positioning: buy bubbles at 65% of the candle range, sell bubbles at 35%. As the score climbs, the bubble migrates toward the candle body center (strong, well-anchored signal). Size scales across 5 tiers (Tiny / Small / Normal / Large / Huge) based on z-score, with a user-defined cap to prevent bubbles from spilling out of candles on zoom out.
Liquidity absorption — Detection logic: the candle sweeps the high (or low) of the last 20 candles, but closes on the opposite side, while delta is against the close. Translation: sellers (or buyers) took liquidity above/below a level, but something bigger absorbed it all and dragged price the other way. Marked with a cyan triangle (ABS+) or orange triangle (ABS-) and a dedicated bubble.
CVD / Price Divergences — Computes a rolling CVD (cumulative delta sum over 50 candles), identifies price and CVD pivots, and when price prints a new high but CVD doesn't (or vice versa), flags the divergence with a red/green label above/below the candle plus a soft background highlight. This is the most predictive feature of the script — when you see it, pay attention.
Classic VSA patterns — Up Thrust (bullish candle with long upper wick and high volume = failed breakout up), Spring (mirror image to the downside), No Demand (rally with low volume = buyers absent), No Supply (decline with low volume = sellers absent). Small, discreet markers above/below the candle.
HTF Trend filter — Compares the close of a higher timeframe (auto-tuned to 4-6× the current TF) against a 50-period EMA. Close above = HTF bull trend, below = bear. Bubbles aligned with HTF trend get +1 to their score, counter-trend bubbles get -1 and become more transparent automatically. Toggle off if not needed.
Intra-candle VWAP — Calculates VWAP using lower timeframe data within the current candle. If the close lands on the delta's side (positive delta with close above intra-candle VWAP, or negative delta with close below), bonus +1 to score. Meaning: whoever pushed stayed in control all the way to the close.
Confluence Score 0–5★ — Sum of five base conditions (delta aligned with candle direction, relative volume confirmed, delta strong by z-score, liquidity sweep detected, expansive candle structure) plus bonuses/penalties from HTF trend and intra-candle VWAP. Clamped to 0–5. Visualized as stars in labels and graduated bubble transparency.
Effort vs Result — Bonus VSA pattern: high volume + small candle body = massive effort, no result, typical of ongoing absorption or distribution. Marked with a small yellow diamond at the candle's midpoint.
Auto-Tuning by Timeframe — Automatically detects the chart timeframe category (Scalping, Short / Medium / Long Intraday, Swing, Position, Long-term) and applies coherent presets for Lower Timeframe, Higher Timeframe, max bubble size, display filter, and confirmed-bars-only mode. Change the chart TF → everything reconfigures. Want to override a single parameter? Just toggle Auto off and use the manual values.
Operational Dashboard — Configurable corner table (5 positions, 3 sizes) summarizing in 8 rows: Mode (Auto/Manual), active preset, current Delta, Z-Score in σ, Score as stars, HTF Trend state, CVD direction, intra-candle VWAP position, and a State row that translates everything into a readable label (STRONG BUY, STRONG SELL, BUY ABSORB, SELL ABSORB, DIV BULLISH, DIV BEARISH, UT, SP, ND, NS, Neutral).
No-repaint mode — Toggle that renders all markers only on closed bars. Auto-enabled on scalping and short intraday (where intra-bar noise is most deceiving), disabled on medium and high TFs (where you want to see flow forming live).
11 configurable alerts — Delta Bubble, Buy/Sell Delta Bubble, Buy/Sell Absorption, High Confluence (4★+), Max Confluence (5★), Up Thrust, Spring, CVD Bullish/Bearish Divergence, Effort vs Result. All compatible with webhooks and push notifications.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
//  Volume Flow Engine PRO v3
//  Auto-tuning in base al timeframe del grafico
// ═══════════════════════════════════════════════════════════════════
indicator("Volume Flow Engine PRO v3", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

import TradingView/ta/8 as ta


// ═══════════════════════════════════════════════════════════════════
//  AUTO MODE
// ═══════════════════════════════════════════════════════════════════

bool auto_mode = input.bool(true, "🔄 Auto-Tune in base al Timeframe", group = "Auto Mode", tooltip = "Quando ON, lo script imposta automaticamente LTF, HTF, dimensione bolle, filtro display e modalità confirmed in base al timeframe del grafico. Disattiva per usare valori manuali.")


// ═══════════════════════════════════════════════════════════════════
//  INPUTS MANUALI (usati solo se auto_mode = false)
// ═══════════════════════════════════════════════════════════════════

// ── Order Flow ──────────────────────────────────────────────────────
string  bubble_display_in   = input.string("Large/Huge Only", "Show Bubbles", options = ["Show All", "Large/Huge Only", "Huge Only", "None"], group = "Order Flow (manuale)")
float   bubble_percentile   = input.float(65, "Bubble Volume Percentile", minval = 0, maxval = 100, group = "Order Flow (manuale)")
int     delta_avg_length    = input.int(20, "Delta Z-Score Length", minval = 1, group = "Order Flow (manuale)")
string  filter_type         = input.string("Delta Strength", "Filter Type", options = ["Delta Strength", "Net Delta"], group = "Order Flow (manuale)")
bool    intensity_mode      = input.bool(false, "Intensity Mode", group = "Order Flow (manuale)")
bool    minimal_mode        = input.bool(false, "Minimal Mode", group = "Order Flow (manuale)")
bool    confirmed_only_in   = input.bool(false, "Solo barre chiuse", group = "Order Flow (manuale)")

string  max_bubble_size_in  = input.string("Normal", "Dimensione Massima Bolla", options = ["Tiny", "Small", "Normal", "Large"], group = "Bubble Style (manuale)")

bool    show_labels         = input.bool(false, "Mostra Etichette", group = "Bubble Labels")
float   label_percentile    = input.float(90, "Label Volume Percentile", minval = 0, maxval = 100, group = "Bubble Labels")
bool    show_score_stars    = input.bool(true, "Mostra Score nell'Etichetta", group = "Bubble Labels")

// ── HTF Trend ────────────────────────────────────────────────────────
bool    use_htf_trend       = input.bool(true, "Usa Filtro Trend HTF", group = "HTF Trend")
string  htf_input_manual    = input.timeframe("60", "Timeframe HTF (manuale)", group = "HTF Trend (manuale)")
int     htf_ema_length      = input.int(50, "EMA HTF Length", minval = 5, group = "HTF Trend")
bool    dim_against_trend   = input.bool(true, "Bolle controtrend trasparenti", group = "HTF Trend")

// ── CVD Divergence ───────────────────────────────────────────────────
bool    use_cvd_div         = input.bool(true, "Rileva Divergenze CVD/Prezzo", group = "CVD Divergence")
int     cvd_lookback        = input.int(14, "CVD Pivot Lookback", minval = 3, group = "CVD Divergence")
int     cvd_length          = input.int(50, "CVD Rolling Length", minval = 10, group = "CVD Divergence")

// ── Confluence Filters ───────────────────────────────────────────────
bool    use_rel_vol         = input.bool(true, "Usa Filtro Volume Relativo", group = "Confluence Filters")
int     vol_length          = input.int(20, "Lunghezza Media Volume", minval = 1, group = "Confluence Filters")
float   min_rel_vol         = input.float(1.15, "Volume Relativo Minimo", minval = 0.1, step = 0.05, group = "Confluence Filters")
float   aggressive_thresh   = input.float(1.5, "Soglia Delta Aggressivo (z-score)", minval = 0.1, step = 0.1, group = "Confluence Filters")

// ── Candle Structure ─────────────────────────────────────────────────
bool    use_structure       = input.bool(true, "Analisi Struttura Candela", group = "Candle Structure")
float   min_body_ratio      = input.float(0.30, "Body Ratio Minimo", minval = 0.05, maxval = 1.0, step = 0.05, group = "Candle Structure")
float   rejection_wick      = input.float(0.55, "Soglia Wick Rejection", minval = 0.1, maxval = 1.0, step = 0.05, group = "Candle Structure")

// ── Liquidity / Absorption ───────────────────────────────────────────
bool    use_absorption      = input.bool(true, "Evidenzia Assorbimento", group = "Liquidity / Absorption")
int     sweep_length        = input.int(20, "Lookback Sweep Liquidità", minval = 2, group = "Liquidity / Absorption")
float   abs_delta_strength  = input.float(1.5, "Min Delta Strength per Assorbimento", minval = 0.1, step = 0.1, group = "Liquidity / Absorption")

// ── VSA ──────────────────────────────────────────────────────────────
bool    use_vsa             = input.bool(true, "Mostra Pattern VSA", group = "VSA Patterns")

// ── Lower Timeframe ──────────────────────────────────────────────────
string  lowerTFInput_manual = input.timeframe("1", "Lower Timeframe (manuale)", group = "Lower Timeframe (manuale)")

// ── Dashboard ────────────────────────────────────────────────────────
bool    show_dashboard      = input.bool(true, "Mostra Dashboard", group = "Dashboard")
string  dash_position       = input.string("top_right", "Posizione", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group = "Dashboard")
string  dash_size           = input.string("small", "Dimensione", options = ["tiny", "small", "normal"], group = "Dashboard")
bool    show_auto_in_dash   = input.bool(true, "Mostra preset attivo in dashboard", group = "Dashboard")

// ── Colors ───────────────────────────────────────────────────────────
color col_agg_buy   = input.color(color.new(#00ff88, 10),  "Buy Aggressivo",     group = "Colors")
color col_agg_sell  = input.color(color.new(#ff4444, 10),  "Sell Aggressivo",    group = "Colors")
color col_pas_buy   = input.color(color.new(#88ff88, 55),  "Buy Passivo",        group = "Colors")
color col_pas_sell  = input.color(color.new(#ff8888, 55),  "Sell Passivo",       group = "Colors")
color col_abs_buy   = input.color(color.new(#00bcd4,  0),  "Assorbimento Buy",   group = "Colors")
color col_abs_sell  = input.color(color.new(#ff9800,  0),  "Assorbimento Sell",  group = "Colors")
color col_vsa       = input.color(color.new(#e040fb, 20),  "Pattern VSA",        group = "Colors")
color col_div_bear  = input.color(color.new(#ff1744,  0),  "Divergenza Bearish", group = "Colors")
color col_div_bull  = input.color(color.new(#00e676,  0),  "Divergenza Bullish", group = "Colors")


// ═══════════════════════════════════════════════════════════════════
//  AUTO-TUNE PRESETS
// ═══════════════════════════════════════════════════════════════════

int tf_sec = timeframe.in_seconds(timeframe.period)

int tf_category = 4
if tf_sec <= 60
    tf_category := 1
else if tf_sec <= 300
    tf_category := 2
else if tf_sec <= 1800
    tf_category := 3
else if tf_sec <= 7200
    tf_category := 4
else if tf_sec <= 14400
    tf_category := 5
else if tf_sec <= 86400
    tf_category := 6
else
    tf_category := 7

// Lower Timeframe per delta
string auto_ltf = "1"
if tf_category == 1
    auto_ltf := "1S"
else if tf_category == 2
    auto_ltf := "1"
else if tf_category == 3
    auto_ltf := "1"
else if tf_category == 4
    auto_ltf := "5"
else if tf_category == 5
    auto_ltf := "15"
else if tf_category == 6
    auto_ltf := "60"
else
    auto_ltf := "240"

// Higher Timeframe per trend
string auto_htf = "60"
if tf_category == 1
    auto_htf := "15"
else if tf_category == 2
    auto_htf := "60"
else if tf_category == 3
    auto_htf := "240"
else if tf_category == 4
    auto_htf := "D"
else if tf_category == 5
    auto_htf := "D"
else if tf_category == 6
    auto_htf := "W"
else
    auto_htf := "M"

// Dimensione massima bolla
string auto_max_size = "Normal"
if tf_category == 1
    auto_max_size := "Small"
else if tf_category == 2
    auto_max_size := "Small"
else if tf_category == 3
    auto_max_size := "Normal"
else if tf_category == 4
    auto_max_size := "Normal"
else if tf_category == 5
    auto_max_size := "Large"
else
    auto_max_size := "Large"

// Display filtering
string auto_bubble_display = "Large/Huge Only"
if tf_category == 1
    auto_bubble_display := "Huge Only"
else if tf_category == 2
    auto_bubble_display := "Large/Huge Only"
else if tf_category == 3
    auto_bubble_display := "Large/Huge Only"
else if tf_category == 4
    auto_bubble_display := "Large/Huge Only"
else if tf_category >= 5
    auto_bubble_display := "Show All"

// Confirmed only
bool auto_confirmed = false
if tf_category <= 2
    auto_confirmed := true
else
    auto_confirmed := false


// ═══════════════════════════════════════════════════════════════════
//  VALORI EFFETTIVI (auto vs manuale)
// ═══════════════════════════════════════════════════════════════════

string lowerTF         = auto_mode ? auto_ltf            : lowerTFInput_manual
string htf_input       = auto_mode ? auto_htf            : htf_input_manual
string max_bubble_size = auto_mode ? auto_max_size       : max_bubble_size_in
string bubble_display  = auto_mode ? auto_bubble_display : bubble_display_in
bool   confirmed_only  = auto_mode ? auto_confirmed      : confirmed_only_in


// ═══════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

format_k(float v) =>
    float a = math.abs(v)
    string s = v < 0 ? "-" : ""
    string result = ""
    if a >= 1000000
        result := s + str.tostring(a / 1000000, "#.##") + "M"
    else if a >= 1000
        result := s + str.tostring(a / 1000, "#.##") + "K"
    else
        result := s + str.tostring(a, "#")
    result

stars(int score) =>
    string result = "☆☆☆☆☆"
    if score >= 5
        result := "★★★★★"
    else if score == 4
        result := "★★★★☆"
    else if score == 3
        result := "★★★☆☆"
    else if score == 2
        result := "★★☆☆☆"
    else if score == 1
        result := "★☆☆☆☆"
    result

calc_vwap(array<float> prices, array<float> vols) =>
    int n = array.size(prices)
    float pv = 0.0
    float tv = 0.0
    float result = hl2
    if n > 0
        for i = 0 to n - 1
            pv += array.get(prices, i) * array.get(vols, i)
            tv += array.get(vols, i)
        if tv > 0
            result := pv / tv
    result

score_transp(int s) =>
    int result = 65
    if s >= 5
        result := 0
    else if s == 4
        result := 10
    else if s == 3
        result := 25
    else if s == 2
        result := 45
    result

size_cap(string max_size) =>
    int result = 3
    if max_size == "Tiny"
        result := 1
    else if max_size == "Small"
        result := 2
    else if max_size == "Normal"
        result := 3
    else if max_size == "Large"
        result := 4
    result

dash_text_size(string s) =>
    string result = size.small
    if s == "tiny"
        result := size.tiny
    else if s == "normal"
        result := size.normal
    result

dash_pos(string p) =>
    string result = position.top_right
    if p == "top_left"
        result := position.top_left
    else if p == "bottom_right"
        result := position.bottom_right
    else if p == "bottom_left"
        result := position.bottom_left
    else if p == "middle_right"
        result := position.middle_right
    result

preset_name(int cat) =>
    string result = ""
    if cat == 1
        result := "Scalping"
    else if cat == 2
        result := "Intraday breve"
    else if cat == 3
        result := "Intraday medio"
    else if cat == 4
        result := "Intraday lungo"
    else if cat == 5
        result := "Swing"
    else if cat == 6
        result := "Position"
    else
        result := "Long-term"
    result


// ═══════════════════════════════════════════════════════════════════
//  DELTA + LTF DATA
// ═══════════════════════════════════════════════════════════════════

[openDelta, maxDelta, minDelta, lastDelta] = ta.requestVolumeDelta(lowerTF)

float net_delta      = lastDelta
float delta_mean     = ta.sma(net_delta, delta_avg_length)
float delta_stdev    = ta.stdev(net_delta, delta_avg_length)
float delta_z_signed = delta_stdev == 0 ? 0.0 : (net_delta - delta_mean) / delta_stdev
float delta_strength = math.abs(delta_z_signed)

ltfData() => [hlc3, volume]
[ltfPrices, ltfVols] = request.security_lower_tf(syminfo.tickerid, lowerTF, ltfData())
float candle_vwap = calc_vwap(ltfPrices, ltfVols)


// ═══════════════════════════════════════════════════════════════════
//  HTF TREND
// ═══════════════════════════════════════════════════════════════════

float htf_ema   = request.security(syminfo.tickerid, htf_input, ta.ema(close, htf_ema_length), lookahead = barmerge.lookahead_off)
float htf_close = request.security(syminfo.tickerid, htf_input, close, lookahead = barmerge.lookahead_off)

bool htf_bull       = use_htf_trend and htf_close > htf_ema
bool htf_bear       = use_htf_trend and htf_close < htf_ema
bool with_trend     = (net_delta > 0 and htf_bull) or (net_delta < 0 and htf_bear)
bool against_trend  = use_htf_trend and ((net_delta > 0 and htf_bear) or (net_delta < 0 and htf_bull))


// ═══════════════════════════════════════════════════════════════════
//  CVD + DIVERGENZE
// ═══════════════════════════════════════════════════════════════════

float cvd = math.sum(net_delta, cvd_length)

float price_pivot_high = ta.pivothigh(high, cvd_lookback, cvd_lookback)
float price_pivot_low  = ta.pivotlow(low,  cvd_lookback, cvd_lookback)
float cvd_pivot_high   = ta.pivothigh(cvd, cvd_lookback, cvd_lookback)
float cvd_pivot_low    = ta.pivotlow(cvd,  cvd_lookback, cvd_lookback)

var float last_ph_price = na
var float last_ph_cvd   = na
var float last_pl_price = na
var float last_pl_cvd   = na

bool bear_div = false
bool bull_div = false

if not na(price_pivot_high) and not na(cvd_pivot_high)
    if not na(last_ph_price) and not na(last_ph_cvd)
        if price_pivot_high > last_ph_price and cvd_pivot_high < last_ph_cvd
            bear_div := use_cvd_div
    last_ph_price := price_pivot_high
    last_ph_cvd   := cvd_pivot_high

if not na(price_pivot_low) and not na(cvd_pivot_low)
    if not na(last_pl_price) and not na(last_pl_cvd)
        if price_pivot_low < last_pl_price and cvd_pivot_low > last_pl_cvd
            bull_div := use_cvd_div
    last_pl_price := price_pivot_low
    last_pl_cvd   := cvd_pivot_low


// ═══════════════════════════════════════════════════════════════════
//  CANDLE STRUCTURE
// ═══════════════════════════════════════════════════════════════════

float candle_range = high - low
float safe_range   = candle_range > 0 ? candle_range : syminfo.mintick
float body_size    = math.abs(close - open)
float body_ratio   = body_size / safe_range

bool  bull_candle  = close >= open
bool  bear_candle  = close <  open

float upper_wick   = (high - math.max(open, close)) / safe_range
float lower_wick   = (math.min(open, close) - low) / safe_range

bool  candle_expand  = body_ratio >= min_body_ratio
bool  bull_rejection = bull_candle and upper_wick >= rejection_wick
bool  bear_rejection = bear_candle and lower_wick >= rejection_wick

float avg_volume    = ta.sma(volume, vol_length)
float rel_volume    = avg_volume > 0 ? volume / avg_volume : 0.0
bool  rel_vol_ok    = use_rel_vol ? rel_volume >= min_rel_vol : true
bool  high_vol_bar  = volume > avg_volume * 1.5

bool effort_vs_res  = high_vol_bar and body_ratio < 0.25

bool close_above_vwap = close > candle_vwap
bool close_below_vwap = close < candle_vwap
bool vwap_aligned     = (net_delta > 0 and close_above_vwap) or (net_delta < 0 and close_below_vwap)


// ═══════════════════════════════════════════════════════════════════
//  LIQUIDITY
// ═══════════════════════════════════════════════════════════════════

float prior_high = ta.highest(high[1], sweep_length)
float prior_low  = ta.lowest(low[1], sweep_length)
bool  swept_high = high > prior_high and close < prior_high
bool  swept_low  = low  < prior_low  and close > prior_low

bool buy_abs  = use_absorption and net_delta < 0 and bull_candle and swept_low  and delta_strength >= abs_delta_strength and rel_vol_ok
bool sell_abs = use_absorption and net_delta > 0 and bear_candle and swept_high and delta_strength >= abs_delta_strength and rel_vol_ok


// ═══════════════════════════════════════════════════════════════════
//  VSA
// ═══════════════════════════════════════════════════════════════════

bool no_demand = use_vsa and bull_candle and volume < avg_volume * 0.75 and body_ratio < 0.35
bool no_supply = use_vsa and bear_candle and volume < avg_volume * 0.75 and body_ratio < 0.35
bool up_thrust = use_vsa and bull_candle and upper_wick >= 0.5 and high_vol_bar and body_ratio < 0.30
bool spring    = use_vsa and bear_candle and lower_wick >= 0.5 and high_vol_bar and body_ratio < 0.30
bool vsa_active = no_demand or no_supply or up_thrust or spring


// ═══════════════════════════════════════════════════════════════════
//  CONFLUENCE SCORE
// ═══════════════════════════════════════════════════════════════════

bool delta_aligned  = (net_delta > 0 and bull_candle) or (net_delta < 0 and bear_candle)
bool delta_strong   = delta_strength >= aggressive_thresh
bool sweep_detected = swept_high or swept_low
bool struct_ok      = use_structure ? (candle_expand and not bull_rejection and not bear_rejection) : true

int p1 = delta_aligned  ? 1 : 0
int p2 = rel_vol_ok     ? 1 : 0
int p3 = delta_strong   ? 1 : 0
int p4 = sweep_detected ? 1 : 0
int p5 = struct_ok      ? 1 : 0
int score = p1 + p2 + p3 + p4 + p5

int trend_bonus = 0
if use_htf_trend and with_trend
    trend_bonus := 1
else if use_htf_trend and against_trend
    trend_bonus := -1

int vwap_bonus = vwap_aligned ? 1 : 0

int raw_score   = score + trend_bonus + vwap_bonus
int final_score = math.max(0, math.min(5, raw_score))

if buy_abs or sell_abs
    final_score := math.max(final_score, 4)


// ═══════════════════════════════════════════════════════════════════
//  FILTERS
// ═══════════════════════════════════════════════════════════════════

bool  use_strength_filter = filter_type == "Delta Strength"
float filter_val          = use_strength_filter ? delta_strength : math.abs(net_delta)

float bubble_filter = use_strength_filter ? ta.percentile_linear_interpolation(delta_strength, delta_avg_length, bubble_percentile) : ta.percentile_linear_interpolation(math.abs(net_delta), delta_avg_length, bubble_percentile)
float label_filter  = use_strength_filter ? ta.percentile_linear_interpolation(delta_strength, delta_avg_length, label_percentile)  : ta.percentile_linear_interpolation(math.abs(net_delta), delta_avg_length, label_percentile)

bool base_ok       = filter_val > bubble_filter and rel_vol_ok
bool bar_confirmed = barstate.isconfirmed or not confirmed_only


// ═══════════════════════════════════════════════════════════════════
//  COLORI
// ═══════════════════════════════════════════════════════════════════

bool agg_buy  = net_delta > 0 and delta_strong
bool agg_sell = net_delta < 0 and delta_strong

color base_flow_color = col_pas_sell
if agg_buy
    base_flow_color := col_agg_buy
else if agg_sell
    base_flow_color := col_agg_sell
else if net_delta > 0
    base_flow_color := col_pas_buy

color intensity_color = color.new(color.red, 10)
if delta_strength < 0.5
    intensity_color := color.new(color.gray, 70)
else if delta_strength < 1.0
    intensity_color := color.new(color.blue, 50)
else if delta_strength < 2.0
    intensity_color := color.new(color.orange, 30)

color raw_color = intensity_mode ? intensity_color : base_flow_color

int extra_transp = (dim_against_trend and against_trend) ? 30 : 0
int total_transp = math.min(95, score_transp(final_score) + extra_transp)

color scored_color = color.new(raw_color, total_transp)

color bubble_color = scored_color
if buy_abs
    bubble_color := col_abs_buy
else if sell_abs
    bubble_color := col_abs_sell
else if vsa_active
    bubble_color := col_vsa


// ═══════════════════════════════════════════════════════════════════
//  BUBBLE POSITION
// ═══════════════════════════════════════════════════════════════════

float buy_y_base   = 0.65
float sell_y_base  = 0.35
float score_offset = (final_score - 2) * 0.03
float buy_y        = math.min(0.82, math.max(0.50, buy_y_base + score_offset))
float sell_y       = math.max(0.18, math.min(0.50, sell_y_base - score_offset))

float dir_buy_pos  = low + safe_range * buy_y
float dir_sell_pos = low + safe_range * sell_y
float abs_buy_pos  = low + safe_range * 0.20
float abs_sell_pos = low + safe_range * 0.80

float bubble_pos = net_delta >= 0 ? dir_buy_pos : dir_sell_pos
if buy_abs
    bubble_pos := abs_buy_pos
else if sell_abs
    bubble_pos := abs_sell_pos


// ═══════════════════════════════════════════════════════════════════
//  BUBBLE SIZE
// ═══════════════════════════════════════════════════════════════════

bool show_enabled    = bubble_display != "None"
bool show_large_huge = bubble_display == "Large/Huge Only"
bool show_huge_only  = bubble_display == "Huge Only"

int natural_size = 1
if delta_strength >= 2.0
    natural_size := 5
else if delta_strength >= 1.5
    natural_size := 4
else if delta_strength >= 1.0
    natural_size := 3
else if delta_strength >= 0.5
    natural_size := 2

int cap = size_cap(max_bubble_size)
int actual_size = math.min(natural_size, cap)

if buy_abs or sell_abs
    actual_size := math.min(4, cap)

bool size_ok = true
if show_huge_only and natural_size < 5
    size_ok := false
else if show_large_huge and natural_size < 4
    size_ok := false

bool show_any = show_enabled and base_ok and size_ok and bar_confirmed

bool render_tiny   = show_any and not minimal_mode and actual_size == 1
bool render_small  = show_any and not minimal_mode and actual_size == 2
bool render_normal = show_any and not minimal_mode and actual_size == 3
bool render_large  = show_any and not minimal_mode and actual_size == 4
bool render_huge   = show_any and not minimal_mode and actual_size == 5
bool render_dot    = show_any and minimal_mode

plotshape(render_dot    ? bubble_pos : na, title = "Minimal Dot",   style = shape.circle, location = location.absolute, color = bubble_color, size = size.tiny)
plotshape(render_tiny   ? bubble_pos : na, title = "Tiny Bubble",   style = shape.circle, location = location.absolute, color = bubble_color, size = size.tiny)
plotshape(render_small  ? bubble_pos : na, title = "Small Bubble",  style = shape.circle, location = location.absolute, color = bubble_color, size = size.small)
plotshape(render_normal ? bubble_pos : na, title = "Normal Bubble", style = shape.circle, location = location.absolute, color = bubble_color, size = size.normal)
plotshape(render_large  ? bubble_pos : na, title = "Large Bubble",  style = shape.circle, location = location.absolute, color = bubble_color, size = size.large)
plotshape(render_huge   ? bubble_pos : na, title = "Huge Bubble",   style = shape.circle, location = location.absolute, color = bubble_color, size = size.huge)


// ═══════════════════════════════════════════════════════════════════
//  LABEL TEXT
// ═══════════════════════════════════════════════════════════════════

string vsa_tag = ""
if up_thrust
    vsa_tag := "UT"
else if spring
    vsa_tag := "SP"
else if no_demand
    vsa_tag := "ND"
else if no_supply
    vsa_tag := "NS"

string star_suffix = show_score_stars ? "\n" + stars(final_score) : ""
string label_text  = format_k(net_delta) + star_suffix
if buy_abs
    label_text := "ABS+" + star_suffix
else if sell_abs
    label_text := "ABS-" + star_suffix
else if vsa_active
    label_text := vsa_tag + star_suffix

bool show_label = show_labels and show_any and filter_val > label_filter

if show_label and not minimal_mode
    label.new(x = bar_index, y = bubble_pos, text = label_text, style = label.style_label_center, color = color.new(color.white, 100), textcolor = color.black, size = size.small)


// ═══════════════════════════════════════════════════════════════════
//  MARKERS
// ═══════════════════════════════════════════════════════════════════

plotshape(buy_abs  and bar_confirmed ? low + safe_range * 0.10 : na, title = "Buy Absorption",  style = shape.triangleup,   location = location.absolute, color = col_abs_buy,  size = size.small, text = "ABS+")
plotshape(sell_abs and bar_confirmed ? low + safe_range * 0.90 : na, title = "Sell Absorption", style = shape.triangledown, location = location.absolute, color = col_abs_sell, size = size.small, text = "ABS-")

plotshape(use_vsa and up_thrust and bar_confirmed ? high + safe_range * 0.10 : na, title = "Up Thrust", style = shape.xcross, location = location.absolute, color = color.new(#e040fb, 20),  size = size.tiny, text = "UT")
plotshape(use_vsa and spring    and bar_confirmed ? low  - safe_range * 0.10 : na, title = "Spring",    style = shape.xcross, location = location.absolute, color = color.new(#e040fb, 20),  size = size.tiny, text = "SP")
plotshape(use_vsa and no_demand and bar_confirmed ? high + safe_range * 0.05 : na, title = "No Demand", style = shape.cross,  location = location.absolute, color = color.new(color.orange, 30), size = size.tiny, text = "ND")
plotshape(use_vsa and no_supply and bar_confirmed ? low  - safe_range * 0.05 : na, title = "No Supply", style = shape.cross,  location = location.absolute, color = color.new(color.teal,   30), size = size.tiny, text = "NS")

plotshape(effort_vs_res and bar_confirmed ? hl2 : na, title = "Effort vs Result", style = shape.diamond, location = location.absolute, color = color.new(#ffeb3b, 20), size = size.tiny)

plotshape(bear_div and bar_confirmed ? high + safe_range * 0.20 : na, title = "Bearish Divergence", style = shape.labeldown, location = location.absolute, color = col_div_bear, textcolor = color.white, size = size.small, text = "DIV-")
plotshape(bull_div and bar_confirmed ? low  - safe_range * 0.20 : na, title = "Bullish Divergence", style = shape.labelup,   location = location.absolute, color = col_div_bull, textcolor = color.white, size = size.small, text = "DIV+")


// ═══════════════════════════════════════════════════════════════════
//  BACKGROUND
// ═══════════════════════════════════════════════════════════════════

bgcolor(show_any and final_score >= 5 ? color.new(bubble_color, 90) : na, title = "Score Massimo BG")
bgcolor(bear_div ? color.new(col_div_bear, 92) : na, title = "Divergenza Bearish BG")
bgcolor(bull_div ? color.new(col_div_bull, 92) : na, title = "Divergenza Bullish BG")


// ═══════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════

var table dash = table.new(dash_pos(dash_position), 2, 9, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.new(color.gray, 70))

if show_dashboard and barstate.islast
    string txt_sz = dash_text_size(dash_size)
    
    // Header
    table.cell(dash, 0, 0, "Volume Flow",  text_color = color.white, text_size = txt_sz, bgcolor = color.new(color.gray, 60))
    string mode_str = auto_mode ? "AUTO ⚙" : "MANUAL"
    color  mode_col = auto_mode ? color.new(#00e676, 0) : color.new(color.orange, 0)
    table.cell(dash, 1, 0, mode_str,       text_color = mode_col, text_size = txt_sz, bgcolor = color.new(color.gray, 60))
    
    int row = 1
    
    // Preset attivo
    if show_auto_in_dash and auto_mode
        table.cell(dash, 0, row, "Preset",     text_color = color.silver, text_size = txt_sz)
        table.cell(dash, 1, row, preset_name(tf_category) + " (LTF " + lowerTF + ", HTF " + htf_input + ")", text_color = color.new(#00e676, 0), text_size = txt_sz)
        row += 1
    
    // Delta
    color d_col = net_delta > 0 ? col_agg_buy : col_agg_sell
    table.cell(dash, 0, row, "Delta",      text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, format_k(net_delta), text_color = d_col, text_size = txt_sz)
    row += 1
    
    // Z-Score
    table.cell(dash, 0, row, "Z-Score",    text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, str.tostring(delta_z_signed, "#.##") + "σ", text_color = math.abs(delta_z_signed) >= 1.5 ? color.yellow : color.white, text_size = txt_sz)
    row += 1
    
    // Score
    table.cell(dash, 0, row, "Score",      text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, stars(final_score), text_color = final_score >= 4 ? color.yellow : color.white, text_size = txt_sz)
    row += 1
    
    // HTF Trend
    string htf_str = "—"
    color  htf_col = color.gray
    if htf_bull
        htf_str := "▲ BULL"
        htf_col := col_agg_buy
    else if htf_bear
        htf_str := "▼ BEAR"
        htf_col := col_agg_sell
    table.cell(dash, 0, row, "HTF " + htf_input, text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, htf_str,      text_color = htf_col, text_size = txt_sz)
    row += 1
    
    // CVD
    color  cvd_col   = cvd > cvd[1] ? col_agg_buy : col_agg_sell
    string cvd_arrow = cvd > cvd[1] ? "↗ " : "↘ "
    table.cell(dash, 0, row, "CVD",        text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, cvd_arrow + format_k(cvd), text_color = cvd_col, text_size = txt_sz)
    row += 1
    
    // VWAP
    string vwap_str = close_above_vwap ? "▲ Sopra" : close_below_vwap ? "▼ Sotto" : "= Pari"
    color  vwap_col = close_above_vwap ? col_agg_buy : close_below_vwap ? col_agg_sell : color.gray
    table.cell(dash, 0, row, "vs VWAP",    text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, vwap_str,     text_color = vwap_col, text_size = txt_sz)
    row += 1
    
    // Stato
    string state     = "Neutro"
    color  state_col = color.gray
    if buy_abs
        state := "BUY ABSORB"
        state_col := col_abs_buy
    else if sell_abs
        state := "SELL ABSORB"
        state_col := col_abs_sell
    else if bear_div
        state := "DIV BEARISH"
        state_col := col_div_bear
    else if bull_div
        state := "DIV BULLISH"
        state_col := col_div_bull
    else if vsa_active
        state := vsa_tag
        state_col := col_vsa
    else if final_score >= 4
        state := net_delta > 0 ? "STRONG BUY" : "STRONG SELL"
        state_col := net_delta > 0 ? col_agg_buy : col_agg_sell
    table.cell(dash, 0, row, "Stato",      text_color = color.silver, text_size = txt_sz)
    table.cell(dash, 1, row, state,        text_color = state_col, text_size = txt_sz)


// ═══════════════════════════════════════════════════════════════════
//  WARNING
// ═══════════════════════════════════════════════════════════════════

if ta.cum(volume) <= 0 and barstate.islast
    label.new(x = bar_index, y = hl2, text = "Nessun dato volume disponibile\nScegli un simbolo con volume", style = label.style_label_left, textcolor = chart.fg_color)


// ═══════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(show_any,                       title = "Delta Bubble",          message = "Volume Flow Engine: Delta Bubble formata")
alertcondition(show_any and net_delta > 0,     title = "Buy Delta Bubble",      message = "Volume Flow Engine: Buy Bubble formata")
alertcondition(show_any and net_delta < 0,     title = "Sell Delta Bubble",     message = "Volume Flow Engine: Sell Bubble formata")
alertcondition(buy_abs,                        title = "Buy Absorption",        message = "Volume Flow Engine: Assorbimento BUY rilevato")
alertcondition(sell_abs,                       title = "Sell Absorption",       message = "Volume Flow Engine: Assorbimento SELL rilevato")
alertcondition(show_any and final_score >= 4,  title = "Alta Confluenza",       message = "Volume Flow Engine: Segnale ad alta confluenza")
alertcondition(show_any and final_score >= 5,  title = "Massima Confluenza",    message = "Volume Flow Engine: SCORE 5/5 - Segnale top")
alertcondition(up_thrust,                      title = "VSA Up Thrust",         message = "Volume Flow Engine: Up Thrust rilevato")
alertcondition(spring,                         title = "VSA Spring",            message = "Volume Flow Engine: Spring rilevato")
alertcondition(bear_div,                       title = "CVD Bearish Divergence",message = "Volume Flow Engine: Divergenza bearish prezzo/CVD")
alertcondition(bull_div,                       title = "CVD Bullish Divergence",message = "Volume Flow Engine: Divergenza bullish prezzo/CVD")
alertcondition(effort_vs_res,                  title = "Effort vs Result",      message = "Volume Flow Engine: Pattern Effort vs Result rilevato")
````
