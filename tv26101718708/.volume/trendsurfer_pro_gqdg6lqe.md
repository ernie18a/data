# TrendSurfer Pro 

- url: https://www.tradingview.com/script/GqDg6lqe/
- type: indicator
- pine_id: PUB;f96832b541454ccba5dffe530a63a7d9
- version: 31.0

## Description

TrendSurfer Pro 🚀

TrendSurfer Pro is a multi-layer trading system built around a core principle: a signal is only valid when multiple independent methods agree. Each component serves a specific, non-redundant role in filtering market noise and identifying high-probability setups.

🧠 How the Components Work Together
The indicator is organized in three layers:

Layer 1 — Trend Context (background conditions)

All signals require alignment with the broader trend before firing. Three independent trend filters run simultaneously:
EMA 750 — long-term directional bias. Bullish signals fire only above it, bearish only below.
Butterworth Filter (2/3-pole) — a zero-lag smoothed trend line that reacts faster than a standard EMA without the noise of raw price. It filters signals that are against the smoothed short-term direction.
VIDYA (Variable Index Dynamic Average) — adapts its smoothing speed to market momentum using a CMO-based efficiency ratio. It is more reactive during trending phases and slower during choppy markets.
These three together define the structural bias. No entry signal fires against all three.

Layer 2 — Entry Signals (timing)

Five signal types identify precise entry points, each using a different market mechanic:
-Master Trend (△▽) — triggers on EMA 4/5 crossover confirmed by RSI > 50 (bull) or < 50 (bear), with price above/below EMA 21, 50, 55, 89, and 750. Engulfing candles on the signal bar are highlighted separately (green/red) to indicate stronger momentum.
-KCandle / Boost (⠾⠻) — detects full engulfing candles where the current bar completely covers the prior bar's range, filtered by EMA 750 side. These identify momentum shifts at key levels and optionally project a "golden area" retracement zone.
-Triangle Signals (▲▼) — fire when the Butterworth Filter changes direction, price is on the correct side of EMA 750 and EMA 25, Stochastic K > 50 (bull) or < 50 (bear), and volume ratio exceeds the threshold. Volume is scaled 1–10 and displayed as a label on the signal bar.
-Order Block Rejections (🟩🟥) — identifies impulsive candles using Z-Score of price change (deviation from SMA of recent changes). When price re-enters the zone of the last opposing candle before the impulse and shows a rejection wick with body outside the zone, a signal fires.
-Liquidity Sweep (✕) — detects when price spikes beyond a pivot high/low (user-defined swing length) and closes back inside. Confirms smart money stop-hunting activity. Also available as a master filter: restrict all other signals to fire only within N bars after a sweep.

Layer 3 — Exit Signals

Take Profit System (🎯) — combines up to 8 indicators (RSI, MACD, Stochastic, Bollinger Bands, Supertrend, CCI, EMA cross, Price Action breakout). A TP signal fires only when the user-defined minimum number of confirmations are met simultaneously (default: 5 of 8). Bearish TP fires above price, bullish below.
Session Rejections (⚡ M) — after a Tokyo, London, or New York session box is drawn, price that breaks above/below the session high/low and then re-enters triggers an External Rejection (⚡). Price that touches and rejects off the session midline triggers an "M" label.
EMA 750 / BF / VIDYA Rejections (R 🟡 🟢🔴) — candles whose wick touches the respective line but whose body remains on the correct side fire a labeled rejection signal. These mark precise dynamic support/resistance touches.

🗂️ Filters
VWAP Filter — restricts signals to the correct side of the daily VWAP
ATR Volatility Score — scores current volatility 1–100 relative to a moving average of ATR. Optionally filter signals below a minimum score.
ATR Channel Mode — creates a dynamic channel around EMA 750 using a long-period ATR multiplier. Signals outside the channel are suppressed.
Yellow Box Filter — isolated stochastic-neutral candles (K between 48–52, not preceded or followed by another neutral candle) generate a yellow rectangle. Signals and KCandle lines are optionally restricted to appear only near these zones.
Time Filters (1/2/3) — three independent session time ranges. Signals fire only within the active windows.

📊 Dashboard Table
The top-right table shows in real time:

EMA 4 vs 5 direction, RSI level, price vs EMA 21/50/55/89/750
Time filter status and active sessions
Buy/Sell volume delta since last VIDYA trend change
ATR value and Vol Score
Overall trend state (VERY BULLISH / BULLISH / BEARISH / VERY BEARISH)

⚙️ How to Use

Set your timezone offset so session boxes align correctly with Tokyo (02:00–08:00 UTC), London (08:00–14:00 UTC), New York (14:00–02:00 UTC).
Choose which master filters to enable (EMA 750, BF, VWAP) based on your timeframe. On lower timeframes (1–5 min), all three recommended. On higher timeframes, BF filter alone may suffice.
Enable the Liquidity Sweep Master Filter if you want to trade only reactive moves after liquidity grabs. Set "Max bars after Sweep" to 3–5 for tight timing.
Use the TP System as an exit confirmation, not an entry. A 🎯 above price after a long entry is the exit signal.
Yellow Box Filter is most useful on 1–5 min charts to avoid trading in random mid-range areas.
Volume label color on Triangle signals: white = standard, orange = high volume (≥9), green = high volume AND price near VWAP — the highest-quality setup.

🔔 Alerts
All signal types have individual alert toggles. Alerts fire once_per_bar_close to avoid repainting. Available alerts: Triangle ▲▼, KCandle, Master Trend, OB Rejection, EMA750/BF/VIDYA Rejection, Session External/Midline Rejection, Liquidity Sweep, TP Bull/Bear, ATR Vol Score.

## Source Code

````pine
//@version=6
indicator(title = 'TrendSurfer Pro 🚀 8.6', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// === TIMEZONE SETTINGS ===
useUTC = input.bool(true, "Use UTC Timezone ⏰", group="Timezone")
utcOffset = input.int(2, "UTC Offset (hours)", minval=-12, maxval=14, group="Timezone", tooltip="Set your timezone offset from UTC. Auto-adjusts when changing assets - Imposta l'offset del fuso orario rispetto all'UTC. Si regola automaticamente quando si cambia strumento finanziario.")

// === SIGNALS FILTERS ===
enableCleanMode = input.bool(true, title = 'Enable Clean Mode 🧹', group = "Signals Filters", tooltip = "Hide VWAP, Butterworth Filter, VIDYA, EMA750 and the SuperTrend line from the chart (sets them to 100% transparency) without affecting their use in signal filtering - Nasconde VWAP, Butterworth Filter, VIDYA, EMA750 e la linea SuperTrend dal grafico (trasparenza al 100%) senza modificarne l'uso nel filtraggio dei segnali")
enableMobileMode = input.bool(false, title = 'Enable Mobile Mode 📱', group = "Signals Filters", tooltip = "Riduce la Master Trend Table alle righe essenziali: Titolo, Buy Volume, Sell Volume, Volat. Score, Current Trend - Reduces the Master Trend Table to essential rows only")
enableVWAPFilter = input.bool(false, title = 'Enable VWAP Master Filter for all signals 📉', group = "Signals Filters", tooltip = "Show only bullish signals above VWAP and bearish signals below VWAP - Mostra solo segnali rialzisti sopra VWAP e segnali ribassisti sotto VWAP")
enableEMA750MasterFilter = input.bool(true, title = 'Enable EMA750 Master Filter for all signals 📈', group = "Signals Filters", tooltip = "Show only bullish signals above EMA750 and bearish signals below EMA750")
enableButterworthMasterFilter = input.bool(false, title = 'Enable Butterworth Master Filter for all signals 〽️', group = "Signals Filters", tooltip = "Show only bullish signals above BF and bearish signals below BF")
enableBPRMasterFilter = input.bool(false, title = 'Enable BPR Master Filter for all signals 📦', group = "Signals Filters", tooltip = "Show signals only when price is inside an active BPR (Balanced Price Range) zone - Mostra i segnali solo quando il prezzo è all'interno di una zona BPR attiva")
enableMTCandleMasterFilter = input.bool(true, title = 'Enable MT Candles Master Filter for all signals 🕯️', group = "Signals Filters", tooltip = "Show only signals whose direction matches the MT Bar Color: bullish signals only on green candles, bearish signals only on red candles - Mostra solo i segnali la cui direzione corrisponde al MT Bar Color: segnali rialzisti solo su candele verdi, ribassisti solo su candele rosse")
enableSweepMasterFilter = input.bool(false, title = 'Enable Liquidity Sweep Master Filter for all signals 💧', group = "Signals Filters", tooltip = "Show signals only within X candles after a Liquidity Sweep - Mostra i segnali solo entro X candele dopo un Liquidity Sweep")
sweepMasterFilterBars   = input.int(5, title = 'Max bars after Sweep', minval = 1, maxval = 100, group = "Signals Filters")
enableSuperTrendMasterFilter = input.bool(false, title = 'Enable SuperTrend Master Filter for all signals 🌊', group = "Signals Filters", tooltip = "Show only bullish signals above the SuperTrend line and bearish signals below it. Take Profit signals are excluded - Mostra solo segnali rialzisti sopra la linea del SuperTrend e ribassisti sotto. I segnali Take Profit sono esclusi")
superTrendFactor = input.float(2.0, title = 'SuperTrend Multiplier', minval = 0.1, step = 0.1, group = "Signals Filters", tooltip = "ATR multiplier of the SuperTrend used by the SuperTrend Master Filter - Moltiplicatore ATR del SuperTrend usato dal SuperTrend Master Filter")
superTrendAtrLen = input.int(10, title = 'SuperTrend ATR Length', minval = 1, group = "Signals Filters", tooltip = "ATR period of the SuperTrend used by the SuperTrend Master Filter - Periodo ATR del SuperTrend usato dal SuperTrend Master Filter")

// === ATR PERSONALIZZABILE ===
enableVolScoreFilter = input.bool(false, "Enable Volatility Score Master Filter for all signals 🎚️", group = "ATR Volatility Score 📊", tooltip = "Show signals only if ATR Volatility Score >= minimum threshold - Mostra i segnali solo se ATR Volatility Score >= soglia minima")
volScoreMinThreshold = input.int(40, "Min Volatility Score (1-100)", minval = 1, maxval = 100, group = "ATR Volatility Score 📊")
atrVolPeriod = input.int(14, "ATR Period (Volatility Score)", minval=1, group="ATR Volatility Score 📊")
atrVolMAPeriod = input.int(5, "ATR MA Period (score calibration)", minval=1, group="ATR Volatility Score 📊", tooltip="Moving average of the ATR used as a reference. ATR > MA = high volatility, ATR < MA = low volatility - Media mobile dell'ATR usata come riferimento. ATR > MA = alta volatilità, ATR < MA = bassa volatilità.")
atrVolSensitivity = input.float(2.0, "Sensitivity (1-5)", minval=0.5, maxval=5.0, step=0.5, group="ATR Volatility Score 📊", tooltip="Amplifies or reduces the score's response. Higher values ​​= more responsive - Amplifica o riduce la risposta del punteggio. Valori alti = più reattivo.")


atrVol   = ta.atr(atrVolPeriod)
atrVolMAAdapted =
     timeframe.in_seconds() <= 60   ? atrVolMAPeriod * 5  :
     timeframe.in_seconds() <= 120  ? atrVolMAPeriod * 3  :
     timeframe.in_seconds() <= 180  ? atrVolMAPeriod * 2  :
     timeframe.in_seconds() <= 300  ? atrVolMAPeriod      :
     timeframe.in_seconds() <= 900  ? math.round(atrVolMAPeriod / 2) :
     timeframe.in_seconds() <= 1800 ? math.round(atrVolMAPeriod / 3) :
     timeframe.in_seconds() <= 3600 ? math.round(atrVolMAPeriod / 5) :
     timeframe.in_seconds() <= 14400 ? math.round(atrVolMAPeriod * 3) :
     atrVolMAPeriod

atrVolMA = ta.sma(atrVol, math.max(2, atrVolMAAdapted))
atrVolDev   = atrVolMA > 0 ? (atrVol / atrVolMA - 1.0) * 100.0 * atrVolSensitivity : 0.0
atrVolScore = math.max(1, math.min(100, math.round(50 + atrVolDev)))
atrScoreColor = atrVolScore < 30 ? color.rgb(255, 82, 82) : atrVolScore < 60 ? color.rgb(255, 165, 0) : color.rgb(0, 230, 118)

// === ATR MODE ===
enableATRMode = input.bool(false, title = 'Enable ATR Mode 📊', group = "ATR Bands Filter", tooltip = "When enabled, ATR bands become visible and signals are filtered: only signals within the ATR channel around EMA750 are shown. Use the multiplier below to control the channel width.\nQuando attivo, le bande ATR diventano visibili e i segnali vengono filtrati: vengono mostrati solo i segnali all'interno del canale ATR attorno all'EMA750. Usa il moltiplicatore sotto per controllare l'ampiezza del canale.")
atrMultiplier = input.float(5, title = 'ATR Channel Multiplier (1-100)', minval = 1, maxval = 100, step = 0.5, group = "ATR Bands Filter", tooltip = "Change the ATR Channel area to filter all signals exept Session Rejections and Target Signals - Cambia l'area del Canale ATR per filtrare tutti i segnali eccetto i Rifiuti di Sessione e i Segnali di Target")

// === SWEEP RR SYSTEM ===
grpSweepRR = "Trade Manager System ⚙️"
showSweepRR       = input.bool(false,  "Show Trade on Chart 📊",                         group = grpSweepRR, tooltip = "Display TP/SL boxes and trade lines on the chart for each Liquidity Sweep signal.\nMostra i box TP/SL e le linee di trade sul grafico per ogni segnale Liquidity Sweep.")
entrySignalModeSW = input.string("Master Trend Signals", "Entry Signal 📡", options = ["Master Trend Signals", "Liquidity Sweep", "MT Line Rejection", "MT Line First Touch", "Order Block Rejection", "VIDYA Rejection", "Butterworth Rejection", "Session External Rejection", "Session Midline Rejection", "EMA 750 Rejection", "Anomalous TP Signals", "SuperTrend"], group = grpSweepRR, tooltip = "Scegli quale segnale apre i trade visualizzati. TP/SL/Partial/BE/Trailing restano invariati qualunque sia la scelta.\nChoose which signal opens the displayed trades. TP/SL/Partial/BE/Trailing remain unchanged regardless of the choice.")
tpModeSW          = input.string("RR Fisso", "TP Mode 🎯", options = ["RR Fisso", "Swing Mode"], group = grpSweepRR, tooltip = "RR Fisso: TP = entry ± (SL distance × Risk:Reward Ratio). Swing Mode: TP at the previous swing level (falls back to the fixed Risk:Reward when there is no valid swing).\nRR Fisso: TP = entrata ± (distanza SL × Risk:Reward Ratio). Swing Mode: TP al precedente livello di swing (se non c'è uno swing valido usa il Risk:Reward fisso).")
useFixedRR_SW     = tpModeSW == "RR Fisso"
slModeSW          = input.string("Percent", "SL Mode 📐", options = ["Wick Buffer", "Percent", "Pips"], group = grpSweepRR, tooltip = "Wick Buffer: SL oltre il wick spazzato + buffer in pips (comportamento originale). Percent: SL come % fissa dal prezzo di entrata. Pips: SL come distanza fissa in pips dal prezzo di entrata.\nWick Buffer: SL beyond the swept wick + pip buffer (original behavior). Percent: SL as a fixed % from entry price. Pips: SL as a fixed pip distance from entry price.")
rrSlPips_SW       = input.float(50.0, "SL Buffer (pips oltre wick) (SL Mode = Wick Buffer)",  minval = 0.1,      group = grpSweepRR, tooltip = "Extra pips added beyond the candle wick to place the Stop Loss. Increase to reduce noise-triggered stops.\nPips aggiuntivi oltre il wick della candela per posizionare lo Stop Loss. Aumentare per ridurre i falsi stop.")
stopLossPctSW     = input.float(0.1,  "Stop Loss % (SL Mode = Percent)",  minval = 0.01, step = 0.01, group = grpSweepRR, tooltip = "Stop Loss distance as a percentage of the entry price. Used only when SL Mode = Percent.\nDistanza dello Stop Loss come percentuale del prezzo di entrata. Usato solo con SL Mode = Percent.")
stopLossPipsSW    = input.float(20.0, "Stop Loss (pips) (SL Mode = Pips)", minval = 0.1, step = 0.1, group = grpSweepRR, tooltip = "Stop Loss distance in pips from the entry price. Used only when SL Mode = Pips.\nDistanza dello Stop Loss in pips dal prezzo di entrata. Usato solo con SL Mode = Pips.")
rrRatio_SW        = input.float(3.0,  "Risk:Reward Ratio",            minval = 0.1, step = 0.1, group = grpSweepRR, tooltip = "Used when TP Mode = RR Fisso (and as a fallback in Swing Mode when there is no valid swing): TP = entry ± (SL distance × ratio).\nUsato con TP Mode = RR Fisso (e come ripiego in Swing Mode quando non c'è uno swing valido): TP = entrata ± (distanza SL × ratio).")
enableBE_SW       = input.bool(false, "Enable Breakeven 🔒",                             group = grpSweepRR, tooltip = "When price reaches the Breakeven RR level, the Stop Loss is automatically moved to entry price.\nQuando il prezzo raggiunge il livello Breakeven RR, lo Stop Loss viene spostato automaticamente al prezzo di entrata.")
beRatio_SW        = input.float(1.0,  "Breakeven at RR",              minval = 0.1, step = 0.1, group = grpSweepRR, tooltip = "The Risk:Reward level at which Breakeven is triggered. Example: 2.0 means BE activates when price moves 2× the SL distance in profit.\nIl livello Risk:Reward al quale si attiva il Breakeven. Esempio: 2.0 significa che il BE scatta quando il prezzo si muove di 2× la distanza SL in profitto.")
enableTrailing_SW   = input.bool(false, "Enable Trailing Stop 🔁",                              group = grpSweepRR)
trailStartRR_SW     = input.float(2,  "Trailing Stop Start at RR",  minval = 0.1, step = 0.1, group = grpSweepRR, tooltip = "Defines at which Risk:Reward level the trailing activates. \nDefinisce a quale livello di rischio/rendimento si attiva il trailing stop.")
trailStepPips_SW    = input.float(500.0,  "Trailing Stop Step (pips)",  minval = 0.1, step = 0.1, group = grpSweepRR, tooltip = "Defines how many pips the SL trails behind the price. \nDefinisce a quanti pips di distanza lo stop loss segue il prezzo.")
enablePartialSW = input.bool(false, "Enable Partial Close 🎯",                    group = grpSweepRR, tooltip = "Chiude parzialmente (ai fini di stats/visualizzazione) il trade Sweep al raggiungimento del RR impostato.\nPartially closes (for stats/visualization purposes) the Sweep trade once the set RR level is reached.")
partialRRSW     = input.float(1.0,  "Partial Close at RR",                        minval = 0.1, step = 0.1, group = grpSweepRR)
partialPctSW    = input.float(50.0, "Partial Close % (peso nel risultato netto)", minval = 1.0, maxval = 99.0, step = 1.0, group = grpSweepRR, tooltip = "Percentuale del trade considerata chiusa al livello di parziale nel calcolo del risultato netto finale.\nPercentage of the trade considered closed at the partial level in the final net result calculation.")
overlapTrades_SW  = input.bool(false, "Overlap Trades 🔀",                               group = grpSweepRR, tooltip = "Allow multiple trades to be open simultaneously. When disabled, a new trade is only opened after the previous one closes.\nConsente più trade aperti contemporaneamente. Se disattivo, un nuovo trade viene aperto solo dopo la chiusura del precedente.")
overlapLimit_SW   = input.int(10, "Overlap Limit 🔢", minval = 1, group = grpSweepRR, tooltip = "Maximum number of trades open at the same time when Overlap Trades is enabled.\nNumero massimo di operazioni aperte contemporaneamente quando Overlap Trades è attivo.")
showPipLabels_SW  = input.bool(false, "Show TP/SL/BE/TS Pip Labels 🟢🔴",                          group = grpSweepRR, tooltip = "Show pip distance labels on the TP, SL, Breakeven and Trailing Stop levels on the chart.\nMostra le etichette con la distanza in pips sui livelli TP, SL, Breakeven e Trailing Stop sul grafico.")
showEntryLabel_SW = input.bool(false, "Show Entry Label 🏷️", group = grpSweepRR, tooltip = "Show a label at the entry price with price and RR info.\nMostra un'etichetta al prezzo di entrata con prezzo e info RR.")
showPartialLabelSW = input.bool(false, "Show Partial Close Label 🏷️", group = grpSweepRR, tooltip = "Disattivando, sparisce solo l'etichetta 'PARTIAL' sul grafico: la linea arancione del livello di parziale resta visibile.\nWhen disabled, only the 'PARTIAL' label disappears from the chart: the orange partial-level line stays visible.")
showLivePnL_SW    = input.bool(true, "Show Live P&L Label 💹", group = grpSweepRR, tooltip = "Show a live label updating pips and R in real time while the trade is open.\nMostra un'etichetta live che aggiorna pips e R in tempo reale mentre il trade è aperto.")
showSwingLine_SW  = input.bool(true,  "Show Swing→TP Line 〰️",                          group = grpSweepRR, tooltip = "Draw a dashed line from the previous swing level used as TP target (only in Swing Mode).\nDisegna una linea tratteggiata dal precedente livello swing usato come target TP (solo in Swing Mode).")
showSweepTable    = input.bool(false,  "Show Trade Stats Table",                         group = grpSweepRR, tooltip = "Display the Liquidity Sweep performance statistics table in the bottom-left corner of the chart.\nMostra la tabella delle statistiche di performance del Liquidity Sweep nell'angolo in basso a sinistra del grafico.")
sweepTableTextSize = input.string("small", title = 'Stats Table Text Size 📏', options = ["tiny", "small", "normal", "large", "huge"], group = grpSweepRR, tooltip = "Font size of the Trade Stats table text.\nDimensione del testo della tabella Trade Stats.")
showSweepSessStats= input.bool(true,  "Show Session Stats in Table",                    group = grpSweepRR, tooltip = "Show per-session breakdown (TF1, TF2, TF3, Off-Filter) inside the Sweep Stats table.\nMostra il dettaglio per sessione (TF1, TF2, TF3) all'interno della tabella Sweep Stats.")
bestByPips_SW     = input.bool(true,  "Best Session: rank by Pips (invece di WR)",      group = grpSweepRR, tooltip = "When enabled, the best session is ranked by net pips (wins − losses). When disabled, it ranks by Win Rate.\nQuando attivo, la sessione migliore è classificata per pips netti (vittorie − perdite). Se disattivo, si usa il Win Rate.")
alertSweepTPSL    = input.bool(true,  "Trade Signal TP/SL/BE/TS Alert 🎯",              group = grpSweepRR, tooltip = "Send an alert when a trade opened by the selected Entry Signal hits TP, SL, Breakeven or Trailing Stop. The message shows the signal name.\nInvia un alert quando un trade aperto dall'Entry Signal selezionato raggiunge TP, SL, Breakeven o Trailing Stop. Il messaggio riporta il nome del segnale.")
entryAlertSW      = input.bool(true,  "Entry Alert 🔔",                                 group = grpSweepRR, tooltip = "Send an alert when a trade opens. The message shows the direction (▲ long / ▼ short), the signal name, the risk:reward, and the entry, SL and TP prices.\nInvia un alert all'apertura del trade. Il messaggio riporta la direzione (▲ long / ▼ short), il nome del segnale, il rischio/rendimento e i prezzi di entrata, SL e TP.")
tradeUpdateAlertSW = input.bool(true,  "Trade Update Alert 📈",                         group = grpSweepRR, tooltip = "Send an alert each time an open trade reaches a new R multiple (1R, 2R, 3R...), measured on the original risk. Alerts stop when the trade hits TP or SL.\nInvia un alert ogni volta che un trade aperto raggiunge un nuovo multiplo di R (1R, 2R, 3R...), misurato sul rischio iniziale. Gli alert si fermano quando il trade raggiunge TP o SL.")

// === LIQUIDITY SWEEP ===
enableLiqSweep      = input.bool(true,  "Enable Liquidity Sweeps ❌",               group = "Liquidity Sweep 💧")
showSweepLines_TS   = input.bool(true,  "Show Sweep Lines",                          group = "Liquidity Sweep 💧")
sweepLookback_TS    = input.int(1,      "Sweep Lookback (re-entry candles)",          group = "Liquidity Sweep 💧", minval=1, maxval=10, tooltip="Maximum number of candles after a spike beyond a swing level to confirm price has re-entered the range.\nNumero massimo di candele dopo uno spike oltre un livello swing per confermare il rientro del prezzo.")
swingLenSweep_TS    = input.int(5,      "Swing Length — Sweep",                      group = "Liquidity Sweep 💧", minval=1, maxval=50, tooltip="Number of candles left & right used to identify swing highs/lows for Liquidity Sweep detection.\nNumero di candele sinistra/destra per identificare swing high/low usati per il rilevamento dei Liquidity Sweep.")
sweepEMAFilter_TS   = input.bool(true,  "Apply EMA750 Filter to Sweeps",             group = "Liquidity Sweep 💧", tooltip = "Bullish sweeps only above EMA750, bearish only below")
sweepVIDYAFilter_TS = input.bool(false, "Apply VIDYA Filter to Sweeps",              group = "Liquidity Sweep 💧", tooltip = "Bullish sweeps only above VIDYA, bearish only below")
sweepVWAPFilter_TS  = input.bool(false, "Apply VWAP Filter to Sweeps",               group = "Liquidity Sweep 💧")

// === BPR (BALANCED PRICE RANGE) SETTINGS ===
enableBPR          = input.bool(true, title = 'Show BPR (overlapping FVG) 📦', group = "BPR Settings 📦", tooltip = "Balanced Price Range: area dove un Fair Value Gap rialzista e uno ribassista si sovrappongono - Balanced Price Range: area where a bullish and a bearish Fair Value Gap overlap")
bprTimeframe        = input.timeframe("", "BPR Timeframe", group = "BPR Settings 📦", tooltip = "Timeframe usato per calcolare i BPR, indipendente dal timeframe del grafico. Lascia vuoto (Chart) per seguire automaticamente il timeframe del grafico - Timeframe used to calculate the BPRs, independent from the chart timeframe. Leave empty (Chart) to automatically follow the chart's timeframe")
bprCount            = input.int(10, "Max BPR Boxes on Chart", minval = 1, maxval = 50, group = "BPR Settings 📦")
bprMitigationTypeWick = input.string("Close", "BPR Mitigation Type", options = ["Wick", "Close"], group = "BPR Settings 📦") == "Wick"
bprMitigationPct    = input.int(100, "BPR Mitigation %", minval = 1, maxval = 100, step = 10, group = "BPR Settings 📦")
bprStyleInput       = input.string(line.style_solid, "BPR Border Style", options = [line.style_solid, line.style_dotted, line.style_dashed], group = "BPR Settings 📦")
bprBullColor        = input.color(#00d4511a, "Bullish BPR Border Color", group = "BPR Settings 📦")
bprBearColor        = input.color(color.rgb(255, 82, 82, 90), "Bearish BPR Border Color", group = "BPR Settings 📦")
bprGrayBorderColor  = input.color(color.rgb(120, 123, 134, 90), "Gray Box Border Color (FVG not yet confirmed)", group = "BPR Settings 📦")
bprGrayFillColor    = input.color(color.new(color.gray, 90), "Gray Box Fill Color (FVG not yet confirmed)", group = "BPR Settings 📦")
bprBullFillColor    = input.color(color.new(#00d451, 90), "Bullish BPR Fill Color", group = "BPR Settings 📦")
bprBearFillColor    = input.color(color.new(color.red, 90), "Bearish BPR Fill Color", group = "BPR Settings 📦")
bprLabelSize        = input.string(size.small, "BPR Label Size", options = [size.auto, size.tiny, size.normal, size.small, size.large], group = "BPR Settings 📦")
bprBullLabelColor   = input.color(#00d451, "Bullish BPR Label Text Color", group = "BPR Settings 📦")
bprBearLabelColor   = input.color(color.red, "Bearish BPR Label Text Color", group = "BPR Settings 📦")
enableBPREMADisplayFilter = input.bool(true, "Filter BPR display by EMA (bull sopra / bear sotto)", group = "BPR Settings 📦", tooltip = "Mostra solo BPR rialziste sopra la EMA e BPR ribassiste sotto la EMA - Only show bullish BPR above the EMA and bearish BPR below the EMA")
bprEMAPeriod        = input.int(750, "BPR EMA Period", minval = 1, group = "BPR Settings 📦")
showMitigatedBPR    = input.bool(false, "Show Mitigated BPR", group = "BPR Settings 📦", tooltip = "Se attivo, le BPR mitigate/invalidate restano visibili sul grafico (congelate nel punto in cui sono state invalidate) invece di essere cancellate - If enabled, mitigated/invalidated BPRs remain visible on the chart (frozen at the point where they were invalidated) instead of being deleted")
enableHTFBPR        = input.bool(true, "Show Higher Timeframe BPR 📦⬆️", group = "BPR Settings 📦", tooltip = "Mostra, assieme alle BPR normali, le BPR calcolate su un secondo timeframe superiore a scelta - Shows, alongside the normal BPRs, the BPRs calculated on a second, higher timeframe of your choice")
htfBPRTimeframe     = input.timeframe("15", "HTF BPR Timeframe", group = "BPR Settings 📦", tooltip = "Timeframe usato per calcolare le BPR di livello superiore - Timeframe used to calculate the higher timeframe BPRs")
htfBprCount         = input.int(10, "Max HTF BPR Boxes on Chart", minval = 1, maxval = 50, group = "BPR Settings 📦")
htfBprBullColor     = input.color(color.rgb(0, 150, 255, 60), "HTF Bullish BPR Border Color", group = "BPR Settings 📦")
htfBprBearColor     = input.color(#ffa50033, "HTF Bearish BPR Border Color", group = "BPR Settings 📦")
htfBprBullFillColor = input.color(color.new(#0096ff, 88), "HTF Bullish BPR Fill Color", group = "BPR Settings 📦")
htfBprBearFillColor = input.color(color.new(#ffa500, 88), "HTF Bearish BPR Fill Color", group = "BPR Settings 📦")
htfBprBullLabelColor = input.color(#0096ff, "HTF Bullish BPR Label Text Color", group = "BPR Settings 📦")
htfBprBearLabelColor = input.color(#ffa500, "HTF Bearish BPR Label Text Color", group = "BPR Settings 📦")

// === TOGGLE PER UP/DOWN SIGNAL ===
enableUpSignal = input.bool(true, title = 'Enable Up Triangle Signal ▲', group = "Triangles Signals Settings ▲▼", tooltip = "Show/Hide Up Triangle signals - Mostra/Nascondi i segnali triangolo verde")
enableDownSignal = input.bool(true, title = 'Enable Down Triangle Signal ▼', group = "Triangles Signals Settings ▲▼", tooltip = "Show/Hide Down Triangle signals - Mostra/Nascondi i segnali triangolo rosso")
src = close
sm = input.int(0, title = 'Smoothing Period', group = "Triangles Signals Settings ▲▼") 
cd = input.float(1, title = 'Constant D')

// === FILTRO VOLUME PER SEGNALI ===
enableVolumeFilter = input.bool(true, title = 'Triangles Signals Volume Filter 🎚️', group = "Triangles Signals Volume Filter 🔺 / 🔻")
volumeFilterMode = input.string("Range", title = "Volume Filter Mode", options = ["Singolo", "Range"], group = "Triangles Signals Volume Filter 🔺 / 🔻", tooltip = "Show only signals with a FIXED value (for example only signals with volume 10) VS Show only signals with value in the RANGE (for example between 7 and 10) - Mostra solo i segnali con un valore FISSO (ad esempio solo i segnali con volume 10) VS Mostra solo i segnali con valore compreso nell'INTERVALLO (ad esempio tra 7 e 10)")
volumeFilterSingle = input.int(10, title = "Specific Volume (6-10)", minval = 6, maxval = 10, group = "Triangles Signals Volume Filter 🔺 / 🔻")
volumeFilterMin = input.int(6, title = "Min Volume (6-10)", minval = 6, maxval = 10, group = "Triangles Signals Volume Filter 🔺 / 🔻")
volumeFilterMax = input.int(10, title = "Max Volume (6-10)", minval = 6, maxval = 10, group = "Triangles Signals Volume Filter 🔺 / 🔻")

// === GESTIONE ETICHETTE SEGNALI TRIANGOLARI ===
maxLabels = input.int(500, title = 'Triangles signals max labels (10-500)', minval = 10, maxval = 500, tooltip = "Maximum number of labels indicating the volume of the candle - Numero massimo di etichette indicanti il volume della candela")
var array<label> volumeLabels = array.new_label()

// === PARAMETRI VWAP PROXIMITY ===
vwapProximityPercentage = input.float(0.06, title = 'VWAP proximity for GREEN LABELS (0.01-1)', minval = 0.01, maxval = 1.0, step = 0.01, tooltip = "Distance % from VWAP for a green volume label - Distanza in % dal VWAP per un'etichetta volume verde")

// === VOLUME STRENGTH 1-10 (INDIPENDENTE DAI SEGNALI TRIANGOLARI) ===
grpVolStrength = "Volume Strength 1-10 📊"
showVolStrengthLabels = input.bool(true, "Enable Volume Strength Labels (every bar)🔢🏷️", group = grpVolStrength, tooltip = "Mostra un'etichetta 1-10 su ogni candela in base alla forza del volume. Funzione indipendente dai segnali triangolari e dal loro filtro volume - Shows a 1-10 label on every candle based on volume strength. Independent from triangle signals and their volume filter")
vsHideOnSignalBars = input.bool(true, "Hide Label on Triangle Signal Bars 🚫", group = grpVolStrength, tooltip = "Nasconde questa etichetta sulle barre dove compare già un Up/Down Triangle, per evitare sovrapposizioni grafiche - Hides this label on bars where an Up/Down Triangle already appears, to avoid visual overlap")
vsVolumeMAPeriod = input.int(20, "Volume MA Period", minval = 1, group = grpVolStrength)
vsLabelSize = input.string("small", "Label Size", options = ["tiny", "small", "normal", "large", "huge"], group = grpVolStrength)
vsColorByStrength = input.bool(true, "Color Labels by Strength 🎨", group = grpVolStrength)
vsLabelOffset = input.float(0.18, "Label Distance from candle (x range)", minval = 0.05, maxval = 1.0, step = 0.01, group = grpVolStrength, tooltip = "Distanza maggiore di quella usata dalle etichette dei segnali triangolari (0.1), per ridurre ulteriormente le sovrapposizioni - Greater distance than the one used by triangle signal labels (0.1), to further reduce overlaps")

vsEnableVolumeFilter = input.bool(true, "Volume Strength Labels Filter 🔢", group = grpVolStrength, tooltip = "Mostra solo le etichette che soddisfano il filtro - Show only labels that satisfy the filter")
vsVolumeFilterMode = input.string("Range", "Volume Filter Mode", options = ["Singolo", "Range"], group = grpVolStrength)
vsVolumeFilterSingle = input.int(10, "Specific Volume (4-10)", minval = 4, maxval = 10, group = grpVolStrength)
vsVolumeFilterMin = input.int(7, "Min Volume (4-10)", minval = 4, maxval = 10, group = grpVolStrength)
vsVolumeFilterMax = input.int(10, "Max Volume (4-10)", minval = 4, maxval = 10, group = grpVolStrength)

vsEnableEMAFilter = input.bool(true, "Enable EMA Trend Filter 📈", group = grpVolStrength, tooltip = "Sopra EMA mostra solo volumi rialzisti (long), sotto EMA mostra solo volumi ribassisti (short) - Above EMA shows only bullish (long) volume, below EMA shows only bearish (short) volume")
vsUseMasterEMA750 = input.bool(true, "Use TSP Master EMA750 (consigliato) ✅", group = grpVolStrength, tooltip = "Riusa la EMA750 già calcolata e disegnata in TSP invece di calcolarne una nuova - Reuses the EMA750 already calculated and plotted in TSP instead of computing a new one")
vsEmaFilterPeriod = input.int(750, "Custom EMA Period (se Master EMA750 disattivata)", minval = 1, group = grpVolStrength)

vsLowColor = input.color(color.rgb(251, 147, 0), "Low Strength Color (4-5)", group = grpVolStrength)
vsMidColor = input.color(color.rgb(255, 255, 255), "Mid Strength Color (6-7)", group = grpVolStrength)
vsHighColor = input.color(color.rgb(0, 255, 64), "High Strength Color (8-10)", group = grpVolStrength)

vsMaxLabels = input.int(500, "Max Labels (10-500)", minval = 10, maxval = 500, group = grpVolStrength)
var array<label> vsVolLabels = array.new_label()

// === ORDER BLOCKS SETTINGS ===
enableOrderBlocks = input.bool(true, "Enable Order Blocks 🧱 ", group = "Order Blocks")
zscore_length = input.int(20, "Z-Score Period", minval=5, group = "Order Blocks", tooltip="Number of bars used to calculate the mean and standard deviation of price changes for the Z-Score. Higher values = smoother, less reactive.\nNumero di barre usato per calcolare media e deviazione standard delle variazioni di prezzo per lo Z-Score. Valori alti = più smussato, meno reattivo.")
zscore_threshold = input.float(1.5, "Z-Score Threshold", minval=0.5, step=0.1, group = "Order Blocks", tooltip="Minimum Z-Score value to consider a candle as an impulsive move and create an Order Block. Higher values = fewer but stronger signals.\nValore minimo dello Z-Score per considerare una candela come movimento impulsivo e creare un Order Block. Valori alti = meno segnali ma più forti.")
ob_lookback = input.int(5, "Impulse Lookback", minval=2, group = "Order Blocks", tooltip="Number of candles to look back before the impulse move to find the last opposing candle for the Order Block zone.\nNumero di candele da guardare indietro prima del movimento impulsivo per trovare l'ultima candela opposta della zona Order Block.")
show_bullish_ob = input.bool(true, "Show Bullish Zones", group = "Order Blocks")
show_bearish_ob = input.bool(true, "Show Bearish Zones", group = "Order Blocks")
prevent_overlap_ob = input.bool(true, "Prevent Overlapping Zones", group = "Order Blocks")
show_midline_ob = input.bool(true, "Show Zone Midline", group = "Order Blocks")
max_age_ob = input.int(100, "Max Zone Age (bars)", minval=10, group = "Order Blocks")
bull_color_ob = input.color(color.new(color.green, 95), "Bullish Zone", group = "Order Blocks")
bear_color_ob = input.color(color.new(color.red, 92), "Bearish Zone", group = "Order Blocks")
bull_border_ob = input.color(color.new(color.green, 100), "Bullish Border", group = "Order Blocks")
bear_border_ob = input.color(color.new(color.red, 100), "Bearish Border", group = "Order Blocks")
bull_midline_ob = input.color(color.new(color.green, 80), "Bullish Midline", group = "Order Blocks")
bear_midline_ob = input.color(color.new(color.red, 80), "Bearish Midline", group = "Order Blocks")
show_rejections_ob = input.bool(true, "Show Rejection Signals 🟩🟥", group = "Order Blocks")
rejection_threshold_ob = input.float(50, "Rejection Threshold % 🪛", minval=1, step=1, group = "Order Blocks")
useOBEMAFilter = input.bool(true, "Enable EMA Filter for Order Blocks ", group = "Order Blocks")
obEMAPeriod = input.int(750, "Order Blocks EMA Period", minval=1, group = "Order Blocks", tooltip = "EMA to filter Order Blocks signals - Default 750")

// === BUTTERWORTH FILTER SETTINGS ===
enableButterworthFilter = input.bool(true, title = 'Enable Butterworth Filter 〽️​', group = "Butterworth Filter")
bfColor = input.color(color.new(#ffee00, 80), title = 'BF Line Color', group = "Butterworth Filter")
bfThickness = input.int(1, title = 'BF Line Thickness', minval = 1, maxval = 4, group = "Butterworth Filter")
showBFRejection = input.bool(true, title = 'Show Butterworth Rejection 🟡', group = "Butterworth Filter")
useBFEMAFilter = input.bool(true, title = 'Enable EMA Filter for BF Rejection', group = "Butterworth Filter")
bfEMAPeriod = input.int(5, title = 'BF Rejection EMA Period', minval = 1, group = "Butterworth Filter")

// Butterworth hardcoded params
bfLength = 20
bfPoles  = 2
bfSrc    = close

// === VIDYA SETTINGS ===
showVidyaLine = input.bool(true, "Show VIDYA Line", group = "VIDYA (Variable Index Dynamic Average) 🧬")
vidyaUpColor = input.color(#17dfad, "VIDYA Uptrend Color", group = "VIDYA (Variable Index Dynamic Average) 🧬", inline = "vidya_colors")
vidyaDownColor = input.color(#dd326b, "VIDYA Downtrend Color", group = "VIDYA (Variable Index Dynamic Average) 🧬", inline = "vidya_colors")
vidyaLineThickness = input.int(1, "VIDYA Line Thickness", minval = 1, maxval = 4, group = "VIDYA (Variable Index Dynamic Average) 🧬")
showVidyaRejection = input.bool(true, title = 'Show VIDYA Rejection 🟢🔴', group = "VIDYA (Variable Index Dynamic Average) 🧬")
useVidyaEMAFilter = input.bool(true, title = 'Enable EMA Filter for VIDYA Rejection', group = "VIDYA (Variable Index Dynamic Average) 🧬")
vidyaRejEMAPeriod = input.int(5, title = 'VIDYA Rejection EMA Period', minval = 1, group = "VIDYA (Variable Index Dynamic Average) 🧬")

// VIDYA hardcoded params
vidya_length    = 10
vidya_momentum  = 20
band_distance   = 0.0
pivot_left_bars = 3

// === KCANDLE/BOOST PARAMETERS ===
emaLen = input.int(750, "KCandles Filter EMA lenght", minval=1, group = "KCandle/Boost ⠾/⠻")
extendBars = input.int(20, "Kcandles Lines Extension in bars", minval=1, group = "KCandle/Boost ⠾/⠻")
maxLines = input.int(500, "Kcandles Max Lines (10-500)", minval=10, maxval = 500, group = "KCandle/Boost ⠾/⠻")
showGoldenArea = input.bool(false, "Show Golden Area", group = "KCandle/Boost ⠾/⠻")
goldenAreaLowerLevel = input.float(25, "Bullish Golden Area Lower Level (%)", minval=0, maxval=49, step=1, group = "KCandle/Boost ⠾/⠻")
goldenAreaUpperLevel = input.float(75, "Bearish Golden Area Upper Level (%)", minval=51, maxval=100, step=1, group = "KCandle/Boost ⠾/⠻")
showKCandleLines = input.bool(false, "Show KCandle Lines 🟰", group = "KCandle/Boost ⠾/⠻")
line25Color = input.color(color.rgb(0, 255, 0, 50), "25% line color", group = "KCandle/Boost ⠾/⠻")
line75Color = input.color(color.rgb(255, 0, 0, 50), "75% line color", group = "KCandle/Boost ⠾/⠻")
showKCandleBarcolor = input.bool(false, "Show KCandle bar color", group = "KCandle/Boost ⠾/⠻", tooltip = "Show engulfing candles on the chart")
kCandleBullColor = input.color(color.rgb(0, 255, 0, 40), "Bullish KCandle color", group = "KCandle/Boost ⠾/⠻")
kCandleBearColor = input.color(color.rgb(255, 0, 0, 40), "Bearish KCandle color", group = "KCandle/Boost ⠾/⠻")

// === FILTRO ORARIO 1 ===
enableTimeFilter = input.bool(true, title = 'Enable Time Filter 1 🕘', group ="➖➖➖➖➖➖➖➖ Time Filter 1 ➖➖➖➖➖➖➖➖")
timeFilter1Session = input.session("0600-1400", title = 'Time Filter 1 Range', group ="➖➖➖➖➖➖➖➖ Time Filter 1 ➖➖➖➖➖➖➖➖", tooltip = "Session format automatically adjusts to asset timezone")
showTimeFilter1Background = input.bool(false, title = 'Show Time Filter 1 Background', group ="➖➖➖➖➖➖➖➖ Time Filter 1 ➖➖➖➖➖➖➖➖")
timeFilter1BgColor = input.color(color.new(#299fff, 97), title = 'Time Filter 1 Background Color', group ="➖➖➖➖➖➖➖➖ Time Filter 1 ➖➖➖➖➖➖➖➖")

// === FILTRO ORARIO 2 ===
enableTimeFilter2 = input.bool(true, title = 'Enable Time Filter 2 🕒', group = "🟰🟰🟰🟰🟰🟰🟰🟰 Time Filter 2 🟰🟰🟰🟰🟰🟰🟰🟰")
timeFilter2Session = input.session("1400-2200", title = 'Time Filter 2 Range', group = "🟰🟰🟰🟰🟰🟰🟰🟰 Time Filter 2 🟰🟰🟰🟰🟰🟰🟰🟰", tooltip = "Session format automatically adjusts to asset timezone")
showTimeFilter2Background = input.bool(false, title = 'Show Time Filter 2 Background', group = "🟰🟰🟰🟰🟰🟰🟰🟰 Time Filter 2 🟰🟰🟰🟰🟰🟰🟰🟰")
timeFilter2BgColor = input.color(color.new(#ff6d00, 97), title = 'Time Filter 2 Background Color', group = "🟰🟰🟰🟰🟰🟰🟰🟰 Time Filter 2 🟰🟰🟰🟰🟰🟰🟰🟰")

// === FILTRO ORARIO 3 ===
enableTimeFilter3 = input.bool(true, title = 'Enable Time Filter 3 🕑', group = "➗➗➗➗➗➗➗➗ Time Filter 3 ➗➗➗➗➗➗➗➗")
timeFilter3Session = input.session("2200-0600", title = 'Time Filter 3 Range', group = "➗➗➗➗➗➗➗➗ Time Filter 3 ➗➗➗➗➗➗➗➗", tooltip = "Session format automatically adjusts to asset timezone")
showTimeFilter3Background = input.bool(false, title = 'Show Time Filter 3 Background', group = "➗➗➗➗➗➗➗➗ Time Filter 3 ➗➗➗➗➗➗➗➗")
timeFilter3BgColor = input.color(color.new(#9200e6, 97), title = 'Time Filter 3 Background Color', group = "➗➗➗➗➗➗➗➗ Time Filter 3 ➗➗➗➗➗➗➗➗")

// === VWAP BREAKING CANDLES ===
showVWAPPurpleCandles = input.bool(false, 'Show VWAP Breaking Candles 📉', group = "VWAP Breaking Candles", tooltip = "Show the candles breaking the VWAP")
vwapPurpleBullColor = input.color(color.rgb(0, 187, 255), "Bullish Breakout color", group = "VWAP Breaking Candles")
vwapPurpleBearColor = input.color(color.rgb(255, 0, 115), "Bearish Breakout color", group = "VWAP Breaking Candles")

// === PREVIOUS DAY HIGH / LOW / CLOSE ===
showPrevDayClose = input.bool(true,  "Show Previous Day Close Line 📅",  group = "Previous Day Levels")
showPrevDayHigh  = input.bool(true,  "Show Previous Day High Line 🔺",   group = "Previous Day Levels")
showPrevDayLow   = input.bool(true,  "Show Previous Day Low Line 🔻",    group = "Previous Day Levels")
prevDayCloseColor = input.color(color.new(color.white,  0), "Close Line Color", group = "Previous Day Levels")
prevDayHighColor  = input.color(color.new(#00e676,      0), "High Line Color",  group = "Previous Day Levels")
prevDayLowColor   = input.color(color.new(#ff1744,      0), "Low Line Color",   group = "Previous Day Levels")
showPrevDayLabel  = input.bool(true,  "Show Labels",                     group = "Previous Day Levels")
enablePDAlert     = input.bool(true,  "Enable Alert on Touch (bar close) 🔔", group = "Previous Day Levels", tooltip = "Invia un alert once per bar close quando il prezzo tocca PD High, Low o Close")

var float prevDayClosePrice = na
var float prevDayHighPrice  = na
var float prevDayLowPrice   = na

var line  pdCloseLine  = na
var line  pdHighLine   = na
var line  pdLowLine    = na
var label pdCloseLabel = na
var label pdHighLabel  = na
var label pdLowLabel   = na

pdcRaw = request.security(syminfo.tickerid, "D", nz(close[1], close), lookahead=barmerge.lookahead_on)
pdhRaw = request.security(syminfo.tickerid, "D", nz(high[1],  high),  lookahead=barmerge.lookahead_on)
pdlRaw = request.security(syminfo.tickerid, "D", nz(low[1],   low),   lookahead=barmerge.lookahead_on)

newDay = timeframe.change("D")

if newDay
    prevDayClosePrice := pdcRaw
    prevDayHighPrice  := pdhRaw
    prevDayLowPrice   := pdlRaw
    if not na(pdCloseLine)
        line.delete(pdCloseLine)
    if not na(pdHighLine)
        line.delete(pdHighLine)
    if not na(pdLowLine)
        line.delete(pdLowLine)
    if not na(pdCloseLabel)
        label.delete(pdCloseLabel)
    if not na(pdHighLabel)
        label.delete(pdHighLabel)
    if not na(pdLowLabel)
        label.delete(pdLowLabel)
    if showPrevDayClose
        pdCloseLine  := line.new(bar_index, prevDayClosePrice, bar_index + 1, prevDayClosePrice,
             xloc=xloc.bar_index, extend=extend.right, color=prevDayCloseColor, width=1, style=line.style_dotted)
        if showPrevDayLabel
            pdCloseLabel := label.new(bar_index, prevDayClosePrice,
                 "Previous Day Close: " + str.tostring(prevDayClosePrice, format.mintick),
                 style=label.style_label_down, color=color.new(prevDayCloseColor, 100),
                 textcolor=prevDayCloseColor, size=size.small, xloc=xloc.bar_index)
    if showPrevDayHigh
        pdHighLine   := line.new(bar_index, prevDayHighPrice,  bar_index + 1, prevDayHighPrice,
             xloc=xloc.bar_index, extend=extend.right, color=prevDayHighColor,  width=1, style=line.style_dotted)
        if showPrevDayLabel
            pdHighLabel  := label.new(bar_index, prevDayHighPrice,
                 "Previous Day High: " + str.tostring(prevDayHighPrice, format.mintick),
                 style=label.style_label_down, color=color.new(prevDayHighColor, 100),
                 textcolor=prevDayHighColor, size=size.small, xloc=xloc.bar_index)
    if showPrevDayLow
        pdLowLine    := line.new(bar_index, prevDayLowPrice,   bar_index + 1, prevDayLowPrice,
             xloc=xloc.bar_index, extend=extend.right, color=prevDayLowColor,   width=1, style=line.style_dotted)
        if showPrevDayLabel
            pdLowLabel   := label.new(bar_index, prevDayLowPrice,
                 "Previous Day Low: " + str.tostring(prevDayLowPrice, format.mintick),
                 style=label.style_label_down, color=color.new(prevDayLowColor, 100),
                 textcolor=prevDayLowColor, size=size.small, xloc=xloc.bar_index)

if barstate.islast
    if showPrevDayClose and not na(pdCloseLine)
        line.set_x2(pdCloseLine, bar_index + 20)
        if showPrevDayLabel and not na(pdCloseLabel)
            label.set_x(pdCloseLabel, bar_index + 20)
    if showPrevDayHigh and not na(pdHighLine)
        line.set_x2(pdHighLine, bar_index + 20)
        if showPrevDayLabel and not na(pdHighLabel)
            label.set_x(pdHighLabel, bar_index + 20)
    if showPrevDayLow and not na(pdLowLine)
        line.set_x2(pdLowLine, bar_index + 20)
        if showPrevDayLabel and not na(pdLowLabel)
            label.set_x(pdLowLabel, bar_index + 20)

// === MASTER TREND SETTINGS ===
showMasterTrend = input.bool(true, title = 'Show Master Trend Signals △▽', group = "Master Trend")
masterTrendBullColor = input.color(color.rgb(255, 242, 0, 60), title = 'Bullish Signal Color △ (no engulfing)', group = "Master Trend")
masterTrendBearColor = input.color(color.rgb(255, 242, 0, 60), title = 'Bearish Signal Color ▽ (no engulfing)', group = "Master Trend")
masterTrendEngulfBullColor = input.color(color.rgb(0, 255, 0, 50), title = 'Bullish Engulfing Signal Color △', group = "Master Trend")
masterTrendEngulfBearColor = input.color(color.rgb(255, 0, 0, 50), title = 'Bearish Engulfing Signal Color ▽', group = "Master Trend")
masterTrendLineColor = input.color(color.rgb(255, 255, 255, 85), title = 'Master Trend Line Color', group = "Master Trend")
masterTrendLineStyle = input.string("Dotted", title = 'Master Trend Line Style', options = ["Solid", "Dashed", "Dotted"], group = "Master Trend")
masterTrendLineExtension = input.int(25, title = 'Master Trend Line Extension (bars)', minval = 0, maxval = 500, group = "Master Trend")
showMasterTrendRejection = input.bool(true, title = 'Show Master Trend Rejection (Green & Red "R")', group = "Master Trend")
rsiMTPeriod = 14
ema4Period  = 4
ema5Period  = 5
ema21Period = 21
sma50Period = 50
ema55Period = 55

// === MASTER TREND TABLE ===
showMasterTrendTable = input.bool(true, title = 'Show Master Trend Table 📊', group = "Master Trend")
showBestMTHour = input.bool(false, title = 'Show Best MT Hour Row ⏰', group = "Master Trend", tooltip = "Mostra/nascondi la riga Best MT Hour nella tabella Master Trend - Show/hide the Best MT Hour row in the Master Trend table")
mtHourWindowSize = input.int(2, title = 'Best MT Hour Window Size (1 to 6 hours) ⏰', minval = 1, maxval = 6, group = "Master Trend", tooltip = "Ampiezza della fascia oraria (in ore) usata per calcolare la Best MT Hour, ad esempio 1, 2, 3, 4, 5 o 6 ore - Size of the hourly window (in hours) used to calculate the Best MT Hour, e.g. 1, 2, 3, 4, 5 or 6 hours")
tableBullColor = input.color(color.new(color.green, 0), title = 'Bullish Indicator Color', group = "Master Trend")
tableBearColor = input.color(color.new(color.red, 0), title = 'Bearish Indicator Color', group = "Master Trend")
tableNeutralColor = input.color(color.new(color.gray, 0), title = 'Neutral Indicator Color', group = "Master Trend")
tableTextSize = input.string("small", title = 'Table Text Size 📏', options = ["tiny", "small", "normal", "large", "huge"], group = "Master Trend")
showLastSigTable = input.bool(true, title = 'Show Last Signal Table 📋', group = "Master Trend")
lastSigTableTextSize = input.string("small", title = 'Last Signal Table Text Size 📏', options = ["tiny", "small", "normal", "large", "huge"], group = "Master Trend")

// === SESSIONS SETTINGS ===
showTokyoSession = input.bool(true, "Show Tokyo Session 💴", group = 'Sessions')
tokyoSessionTime = input.session("0200-0215", "Tokyo Session Range", group = 'Sessions', tooltip = "Session format automatically adjusts to asset timezone")
tokyoSessionColor = input.color(color.new(#8e21f3, 80), "Tokyo Session color", group = 'Sessions')
tokyoExtensionLength = input.int(500, "Tokyo Session Lines Extension (max 500)", minval = 0, maxval = 500, group = 'Sessions')
showTokyoSessionLabel = input.bool(true, "Show Tokyo Session Label", group = 'Sessions')
showLondonSession = input.bool(true, "Show London Session 💶", group = 'Sessions')
londonSessionTime = input.session("0800-0815", "London Session Range", group = 'Sessions', tooltip = "Session format automatically adjusts to asset timezone")
londonSessionColor = input.color(color.new(#003bfd, 80), "London Session color", group = 'Sessions')
londonExtensionLength = input.int(500, "London Session Lines Extension (max 500)", minval = 0, maxval = 500, group = 'Sessions')
showLondonSessionLabel = input.bool(true, "Show London Session Label", group = 'Sessions')
showNewYorkSession = input.bool(true, "Show New York Session 💵", group = 'Sessions')
newYorkSessionTime = input.session("1400-1415", "New York Session Range", group = 'Sessions', tooltip = "Session format automatically adjusts to asset timezone")
newYorkSessionColor = input.color(color.new(#fffb00, 80), "New York Session color", group = 'Sessions')
newYorkExtensionLength = input.int(500, "New York Session Lines Extension (max 500)", minval = 0, maxval = 500, group = 'Sessions')
showNewYorkSessionLabel = input.bool(true, "Show New York Session Label", group = 'Sessions')
tokyoSessionLineColor = input.color(color.new(#b121f3, 4), "Tokyo Session Extended Lines Color", group = 'Sessions')
londonSessionLineColor = input.color(color.new(#002df8, 0), "London Session Extended Lines Color", group = 'Sessions')
newYorkSessionLineColor = input.color(color.new(#ffd000, 0), "New York Session Extended Lines Color", group = 'Sessions')
showSessionExternalRejection = input.bool(true, title = 'Show Session External Rejection ⚡', group = "Sessions")
showSessionMidlineRejection = input.bool(true, title = 'Show Session Midline Rejection (Orange "M")', group = "Sessions")

// === TAKE PROFIT SYSTEM ===
enableTakeProfit = input.bool(true, "Enable Take Profit System 🎯", group="⭕⭕⭕⭕⭕ Take Profit System ⭕⭕⭕⭕⭕")
applyTPTimeFilter = input.bool(true, "Apply Time Filters to TP signals", group="⭕⭕⭕⭕⭕ Take Profit System ⭕⭕⭕⭕⭕")
applyTPVWAPFilter = input.bool(false, "Apply VWAP Filter to TP signals", group="⭕⭕⭕⭕⭕ Take Profit System ⭕⭕⭕⭕⭕")
excludeAnomalousTPFromMTFilter = input.bool(true, "Exclude Anomalous TP from MT Candles Filter 🚫", group="⭕⭕⭕⭕⭕ Take Profit System ⭕⭕⭕⭕⭕", tooltip = "Quando attivo, i segnali TP anomali (TP Bull sotto EMA750 / TP Bear sopra EMA750) non vengono più filtrati dal MT Candles Master Filter e possono comparire indipendentemente dal colore delle candele MT - When enabled, anomalous TP signals (TP Bull below EMA750 / TP Bear above EMA750) bypass the MT Candles Master Filter entirely and can appear regardless of MT candle color")
tpBullColor = input.color(color.rgb(0, 255, 8, 0), "Bullish TP Target Color 🎯", group="TP Visual Settings")
tpBearColor = input.color(color.rgb(255, 0, 0, 0), "Bearish TP Target Color 🎯", group="TP Visual Settings")
tpLineExtension = input.int(25, "TP Line Extension (bars)", minval=1, maxval=500, group="TP Visual Settings", tooltip="Number of bars to extend TP signal line")
tpLineColor = input.color(color.rgb(0, 255, 0, 60), "TP Line Color", group="TP Visual Settings")
tpLabelDistanceATR = input.float(0.5, "TP Label Distance (x ATR)", minval=0.05, maxval=5.0, step=0.05, group="TP Visual Settings", tooltip="Distanza costante dell'etichetta TP dal simbolo, calcolata come multiplo dell'ATR(14): resta uniforme su qualsiasi candela o livello di zoom, invece di dipendere dal range della singola candela - Constant TP label distance from the marker, calculated as a multiple of ATR(14): stays uniform across any candle or zoom level instead of depending on that candle's range")

// TP System — parametri fissi
useTPRSI        = true
useTPMACD       = false
useTPStoch      = true
useTPBB         = false
useTPSTrend     = true
useTPCCI        = true
useTPEMA        = false
useTPPriceAction = true
minTPConfirmations = 5
tpRsiLen        = 25
tpRsiOB         = 55
tpRsiOS         = 45
tpMacdFastLen   = 12
tpMacdSlowLen   = 26
tpMacdSignalLen = 9
tpStochKLen     = 14
tpStochDLen     = 3
tpStochSmoothK  = 3
tpBBLen         = 20
tpBBMult        = 2.0
tpSTAtrMult     = 3.0
tpSTAtrLen      = 10
tpCCILen        = 20
tpCCIOB         = 100
tpCCIOS         = -100
tpEMAFastLen    = 12
tpEMASlowLen    = 26
tpLookBackBars  = 5

// === CHART CUSTOMIZATION ===
ema750Color = input.color(color.new(#f8f8f8, 0), "EMA 750 color 📈", group = "Chart customization 🎨")
ema750Thickness = input.int(1, "EMA 750 thickness", minval = 1, maxval = 4, group = "Chart customization 🎨")
showEMA750Rejection = input.bool(true, title = 'Show EMA750 Rejection (White "R")', group = "Chart customization 🎨")
vwapColor = input.color(color.new(#c2185c, 35), "VWAP color 📉", group = "Chart customization 🎨")
vwapThickness = input.int(1, "VWAP thickness", minval = 1, maxval = 4, group = "Chart customization 🎨")
upperBandColor = input.color(color.rgb(139, 139, 139, 100), "Upper Band color", group = "Chart customization 🎨")
lowerBandColor = input.color(color.rgb(139, 139, 139, 100), "Lower Band color", group = "Chart customization 🎨")
bandsThickness = input.int(1, "Bands thickness", minval = 1, maxval = 4, group = "Chart customization 🎨")
upperFillColor = input.color(color.new(#00bcd4, 100), "Upper Band Fill Color", group = "Chart customization 🎨")
lowerFillColor = input.color(color.new(#ff5252, 100), "Lower Band Fill Color", group = "Chart customization 🎨")

upperFillColorDynamic = enableATRMode ? color.new(#00bcd4, 90) : upperFillColor
lowerFillColorDynamic = enableATRMode ? color.new(#ff5252, 90) : lowerFillColor

enableMTBarColor  = input.bool(true, "Enable Master Trend Bar Color 🎨", group = "Chart customization 🎨",
  tooltip = "Colora le candele in base allo stato della tabella MasterTrend: Verde = tutti bull, Rosso = tutti bear, Grigio = neutrale")
mtBarColorBull    = input.color(color.rgb(0, 230, 118, 10),  "MT Bar Color – Bullish",  group = "Chart customization 🎨")
mtBarColorBear    = input.color(color.rgb(255, 70,  70,  10), "MT Bar Color – Bearish",  group = "Chart customization 🎨")
mtBarColorNeutral = input.color(color.rgb(150, 150, 150, 30), "MT Bar Color – Neutral",  group = "Chart customization 🎨")

// === ALERTS SETTINGS ===
enableUpTriangleAlert = input.bool(true, title = 'Enable Up Triangle Alert ▲', group = "Alerts Settings 🔊")
enableDownTriangleAlert = input.bool(true, title = 'Enable Down Triangle Alert ▼', group = "Alerts Settings 🔊")
enableVolStrengthAlert = input.bool(true, title = 'Enable Volume Strength 1-10 Alert 🔢', group = "Alerts Settings 🔊")
enableKCandleBullAlert = input.bool(true, title = 'Enable KCandle Bullish Alert ⠾', group = "Alerts Settings 🔊")
enableKCandleBearAlert = input.bool(true, title = 'Enable KCandle Bearish Alert ⠻', group = "Alerts Settings 🔊")
enableMasterTrendBullAlert = input.bool(true, title = 'Enable Master Trend Bullish Alert △', group = "Alerts Settings 🔊")
enableMasterTrendBearAlert = input.bool(true, title = 'Enable Master Trend Bearish Alert ▽', group = "Alerts Settings 🔊")
enableBullOBRejectionAlert = input.bool(true, title = 'Enable Bullish OB Rejection Alert 🟩', group = "Alerts Settings 🔊")
enableBearOBRejectionAlert = input.bool(true, title = 'Enable Bearish OB Rejection Alert 🟥', group = "Alerts Settings 🔊")
enableMasterTrendRejectionAlert = input.bool(true, title = 'Enable Master Trend Rejection Alert (Green & Red "R")', group = "Alerts Settings 🔊")
enableSessionBullERAlert = input.bool(true, title = 'Enable Session Bullish External Rejection Alert ⚡', group = "Alerts Settings 🔊")
enableSessionBearERAlert = input.bool(true, title = 'Enable Session Bearish External Rejection Alert ⚡', group = "Alerts Settings 🔊")
enableEMA750BullRejectionAlert = input.bool(true, title = 'Enable EMA750 Bullish Rejection Alert (White "R")', group = "Alerts Settings 🔊")
enableEMA750BearRejectionAlert = input.bool(true, title = 'Enable EMA750 Bearish Rejection Alert (White "R")', group = "Alerts Settings 🔊")
enableSessionMidlineBullRejectionAlert = input.bool(true, title = 'Enable Session Midline Bullish Rejection Alert (Orange "M")', group = "Alerts Settings 🔊")
enableSessionMidlineBearRejectionAlert = input.bool(true, title = 'Enable Session Midline Bearish Rejection Alert (Orange "M")', group = "Alerts Settings 🔊")
enableTPBullAlert = input.bool(true, title = 'Enable Take Profit Bullish Alert 🎯', group = "Alerts Settings 🔊")
enableTPBearAlert = input.bool(true, title = 'Enable Take Profit Bearish Alert 🎯', group = "Alerts Settings 🔊")
enableBFBullRejectionAlert = input.bool(true, title = 'Enable Butterworth Bullish Rejection Alert 🟡', group = "Alerts Settings 🔊")
enableBFBearRejectionAlert = input.bool(true, title = 'Enable Butterworth Bearish Rejection Alert 🟡', group = "Alerts Settings 🔊")
enableVidyaBullRejectionAlert = input.bool(true, title = 'Enable VIDYA Bullish Rejection Alert 🟢', group = "Alerts Settings 🔊")
enableVidyaBearRejectionAlert = input.bool(true, title = 'Enable VIDYA Bearish Rejection Alert 🔴', group = "Alerts Settings 🔊")
enableBullSweepAlert_TS = input.bool(true, title = 'Enable Bullish Liquidity Sweep Alert 🔵', group = "Alerts Settings 🔊")
enableBearSweepAlert_TS = input.bool(true, title = 'Enable Bearish Liquidity Sweep Alert 🟠', group = "Alerts Settings 🔊")
enableBPRInAlert = input.bool(false, title = 'Enable BPR In Alert 📦', group = "Alerts Settings 🔊", tooltip = "Una candela chiude dentro una BPR (verde o rossa) - A candle closes inside a BPR (green or red)")
enableBPROutAlert = input.bool(true, title = 'Enable BPR Out Alert 📦', group = "Alerts Settings 🔊", tooltip = "Una candela chiude fuori da una BPR nella direzione del trend - A candle closes outside a BPR in the trend direction")
enableVolScoreAlert = input.bool(false, title = 'Enable ATR Volatility Score Alert 📊 (≥ threshold)', group = "Alerts Settings 🔊")

// ══════════════════════════════════════════════════════════════
// FUNZIONI
// ══════════════════════════════════════════════════════════════
getTimezoneString() =>
    useUTC ? "UTC" + (utcOffset >= 0 ? "+" + str.tostring(utcOffset) : str.tostring(utcOffset)) : syminfo.timezone

passesVolScoreFilter() =>
    not enableVolScoreFilter or atrVolScore >= volScoreMinThreshold

cleanC(color c) =>
    enableCleanMode ? color.new(c, 100) : c

vidya_calc(src_vidya, vidya_length, vidya_momentum) =>
    float momentum = ta.change(src_vidya)
    float sum_pos_momentum = math.sum(momentum >= 0 ? momentum : 0.0, vidya_momentum)
    float sum_neg_momentum = math.sum(momentum >= 0 ? 0.0 : -momentum, vidya_momentum)
    float abs_cmo = math.abs(100 * (sum_pos_momentum - sum_neg_momentum) / (sum_pos_momentum + sum_neg_momentum))
    float alpha = 2 / (vidya_length + 1)
    var float vidya_value = 0.0
    vidya_value := alpha * abs_cmo / 100 * src_vidya + (1 - alpha * abs_cmo / 100) * nz(vidya_value[1])
    ta.sma(vidya_value, 15)

swTxtSize(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

htfTFLabel(string tf) =>
    tf == "" ? "Chart" :
     tf == "D" ? "1D" :
     tf == "W" ? "1W" :
     tf == "M" ? "1M" :
     (str.tonumber(tf) >= 60 and str.tonumber(tf) % 60 == 0) ? str.tostring(int(str.tonumber(tf) / 60)) + "h" :
     tf + "m"

// ══════════════════════════════════════════════════════════════
// TYPES
// ══════════════════════════════════════════════════════════════
type OrderBlock
    box zone_box
    line mid_line
    float top
    float bottom
    int birth_bar
    bool is_bullish
    bool is_active

type MasterTrendLine
    line trend_line
    float price_level
    int start_bar
    bool touchedForEntry

type SessionLine
    float high_price
    float low_price
    float mid_price
    int start_bar
    int end_bar
    bool high_broken
    bool low_broken

type SessionLiveState
    float sessionLow
    float sessionHigh
    int   startTime
    box   liveBox
    label liveLabel
    line  liveHighLine
    line  liveLowLine

type TPLine
    line tp_line
    float price_level
    int start_bar

type SweepTrade
    box    slBox
    box    tpBox
    label  tpLbl
    label  slLbl
    label  entryLbl
    label  liveLbl
    line   swingLn
    float  slLevel
    float  tpLevel
    float  entryPrice
    float  origSL
    float  swingLevel
    int    signalBar
    int    swingBar
    bool   isBull
    bool   beTriggered
    string session
    bool   trailActivated
    float  trailHighWater
    int    slotIndex
    float  partialLevel
    bool   partialTaken
    float  partialPipsStored
    float  partialRRStored
    line   entryLine
    int    rNotified

type BprFvg
    int   Type = 0
    float Top = na
    float Btm = na
    int   left = na
    int   left2 = na
    int   right = na
    int   cnt = 0
    color fvgClr = na

type MTHourTrade
    float tpLevel
    float slLevel
    bool  isBull
    int   hourBucket
    int   signalBar

// ══════════════════════════════════════════════════════════════
// ARRAYS
// ══════════════════════════════════════════════════════════════
var array<OrderBlock>      active_zones           = array.new<OrderBlock>()
var array<MasterTrendLine> activeMasterTrendLines = array.new<MasterTrendLine>()
var array<SessionLine>     activeSessionLines     = array.new<SessionLine>()
var array<TPLine>          activeTPLines          = array.new<TPLine>()
var array<SweepTrade>      activeSweepTrades      = array.new<SweepTrade>()
var array<MTHourTrade>     activeMTHourTrades     = array.new<MTHourTrade>()
var array<int>             mtHourTotal            = array.new<int>(24, 0)
var array<int>             mtHourWins             = array.new<int>(24, 0)

// ══════════════════════════════════════════════════════════════
// BASE INDICATORS
// ══════════════════════════════════════════════════════════════
bfEMA       = ta.ema(close, bfEMAPeriod)
vidyaRejEMA = ta.ema(close, vidyaRejEMAPeriod)

var float up_trend_volume   = na
var float down_trend_volume = na
var bool  is_trend_up_vidya = false
var float vidya_plot_value  = na

ema25  = ta.ema(close, 25)
ema750 = ta.ema(close, 750)
ema125 = ta.ema(close, 125)
[stFilterLine, stFilterDir] = ta.supertrend(superTrendFactor, superTrendAtrLen)

smootherATR = ta.ema(ta.tr, 750)
upperBand   = ema750 + atrMultiplier * smootherATR
lowerBand   = ema750 - atrMultiplier * smootherATR

float atr_value_vidya = ta.atr(200)
vidya_value = vidya_calc(close, vidya_length, vidya_momentum)
float upper_band_vidya = vidya_value + atr_value_vidya * band_distance
float lower_band_vidya = vidya_value - atr_value_vidya * band_distance

if ta.crossover(close, upper_band_vidya)
    is_trend_up_vidya := true
if ta.crossunder(close, lower_band_vidya)
    is_trend_up_vidya := false
if is_trend_up_vidya
    vidya_plot_value := lower_band_vidya
if not is_trend_up_vidya
    vidya_plot_value := upper_band_vidya
if ta.change(is_trend_up_vidya)
    vidya_plot_value := na

bool trend_cross_up_vidya   = not is_trend_up_vidya[1] and is_trend_up_vidya
bool trend_cross_down_vidya = not is_trend_up_vidya and is_trend_up_vidya[1]

bool vidyaCrossUpChg   = ta.change(trend_cross_up_vidya)
bool vidyaCrossDownChg = ta.change(trend_cross_down_vidya)
bool vidyaTrendFlip    = vidyaCrossUpChg or vidyaCrossDownChg

if vidyaTrendFlip
    up_trend_volume   := 0
    down_trend_volume := 0
if not vidyaTrendFlip
    up_trend_volume   := up_trend_volume   + (close > open ? volume : 0)
    down_trend_volume := down_trend_volume + (close < open ? volume : 0)

float avg_volume_delta = (up_trend_volume + down_trend_volume) / 2
string delta_volume_percent = str.tostring((up_trend_volume - down_trend_volume) / avg_volume_delta * 100, format.percent) == 'NaN%' ? '0%' : str.tostring((up_trend_volume - down_trend_volume) / avg_volume_delta * 100, format.percent)

obEMA      = ta.ema(close, obEMAPeriod)
emaKCandle = ta.ema(close, emaLen)

rsiMT         = ta.rsi(close, rsiMTPeriod)
ema4          = ta.ema(close, ema4Period)
ema5          = ta.ema(close, ema5Period)
ema21         = ta.ema(close, ema21Period)
sma50         = ta.sma(close, sma50Period)
ema55         = ta.ema(close, ema55Period)
ema89ForTable = ta.ema(close, 89)
mtTableAllBull = ema4 > ema5 and rsiMT > 50 and close > ema21 and close > sma50 and close > ema55 and close > ema89ForTable and close > ema750
mtTableAllBear = ema4 < ema5 and rsiMT < 50 and close < ema21 and close < sma50 and close < ema55 and close < ema89ForTable and close < ema750

tpRsi             = ta.rsi(close, tpRsiLen)
tpMacd            = ta.ema(close, tpMacdFastLen) - ta.ema(close, tpMacdSlowLen)
tpMacdSignal      = ta.ema(tpMacd, tpMacdSignalLen)
tpMacdCrossUnder  = ta.crossunder(tpMacd, tpMacdSignal)
tpMacdCrossOver   = ta.crossover(tpMacd, tpMacdSignal)
tpK               = ta.sma(ta.stoch(close, high, low, tpStochKLen), tpStochSmoothK)
tpD               = ta.sma(tpK, tpStochDLen)
tpStochCrossUnder = ta.crossunder(tpK, tpD)
tpStochCrossOver  = ta.crossover(tpK, tpD)
tpBasis           = ta.sma(close, tpBBLen)
tpDev             = tpBBMult * ta.stdev(close, tpBBLen)
tpUpper           = tpBasis + tpDev
tpLower           = tpBasis - tpDev
[_, tpSTDir]      = ta.supertrend(tpSTAtrMult, tpSTAtrLen)
tpCCI             = ta.cci(close, tpCCILen)
tpEMAFast         = ta.ema(close, tpEMAFastLen)
tpEMASlow         = ta.ema(close, tpEMASlowLen)
tpEmaCrossBull    = ta.crossover(tpEMAFast, tpEMASlow)
tpEmaCrossBear    = ta.crossunder(tpEMAFast, tpEMASlow)
tpPriceBreakoutBull = close > close[tpLookBackBars]
tpPriceBreakoutBear = close < close[tpLookBackBars]

pipSize = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
atr14   = ta.atr(14)

// === TIME FILTER ===
isInTimeRange() =>
    if not enableTimeFilter and not enableTimeFilter2 and not enableTimeFilter3
        true
    else
        inRange1 = enableTimeFilter  ? not na(time(timeframe.period, timeFilter1Session, getTimezoneString())) : false
        inRange2 = enableTimeFilter2 ? not na(time(timeframe.period, timeFilter2Session, getTimezoneString())) : false
        inRange3 = enableTimeFilter3 ? not na(time(timeframe.period, timeFilter3Session, getTimezoneString())) : false
        inRange1 or inRange2 or inRange3

vwap = ta.vwap(hl2)

// === ALERT TOUCH PD LEVELS ===
touchedPDC = not na(prevDayClosePrice) and high >= prevDayClosePrice and low <= prevDayClosePrice
touchedPDH = not na(prevDayHighPrice)  and high >= prevDayHighPrice  and low <= prevDayHighPrice
touchedPDL = not na(prevDayLowPrice)   and high >= prevDayLowPrice   and low <= prevDayLowPrice

if enablePDAlert and isInTimeRange()
    if touchedPDC
        alert("📅 PREV DAY CLOSE TOUCHED: " + str.tostring(prevDayClosePrice, format.mintick), alert.freq_once_per_bar)
    if touchedPDH
        alert("🔺 PREV DAY HIGH TOUCHED: "  + str.tostring(prevDayHighPrice,  format.mintick), alert.freq_once_per_bar)
    if touchedPDL
        alert("🔻 PREV DAY LOW TOUCHED: "   + str.tostring(prevDayLowPrice,   format.mintick), alert.freq_once_per_bar)

// === BUTTERWORTH FILTER ===
get2PoleBF(src, length) =>
    PI = 2 * math.asin(1)
    a  = math.exp(-math.sqrt(2) * PI / length)
    b  = 2 * a * math.cos(math.sqrt(2) * PI / length)
    var float bf = na
    bf := b * nz(bf[1]) - math.pow(a, 2) * nz(bf[2]) + ((1 - b + math.pow(a, 2)) / 4) * (src + 2 * nz(src[1]) + nz(src[2]))
    bf

get3PoleBF(src, length) =>
    PI = 2 * math.asin(1)
    a  = math.exp(-PI / length)
    b  = 2 * a * math.cos(1.738 * PI / length)
    c  = math.pow(a, 2)
    var float bf = na
    bf := (b + c) * nz(bf[1]) - (c + b * c) * nz(bf[2]) + math.pow(c, 2) * nz(bf[3]) + ((1 - b + c) * (1 - c) / 8) * (src + 3 * nz(src[1]) + 3 * nz(src[2]) + nz(src[3]))
    bf

bf = bfPoles == 2 ? get2PoleBF(bfSrc, bfLength) : get3PoleBF(bfSrc, bfLength)

// === SWEEP MASTER FILTER ===
var int lastSweepBar = na

passesSweepMasterFilter() =>
    not enableSweepMasterFilter or (not na(lastSweepBar) and (bar_index - lastSweepBar) <= sweepMasterFilterBars)

// === BPR (BALANCED PRICE RANGE) CALCULATION ===
bprImbalanceDetection(top, btm, condition) =>
    condition

getBPRFvg() =>
    BprFvg fd = BprFvg.new()

    isFvgBull = bprImbalanceDetection(low, high[2], low  > high[2] and close[1] > high[2])
    isFvgBear = bprImbalanceDetection(low[2], high, high < low[2]  and close[1] < low[2])

    if isFvgBull
        fd.Type   := 1
        fd.Top    := low
        fd.Btm    := high[2]
        fd.left   := time
        fd.left2  := time[2]
        fd.right  := time
        fd.fvgClr := bprBullColor

    if isFvgBear
        fd.Type   := -1
        fd.Top    := low[2]
        fd.Btm    := high
        fd.left   := time[2]
        fd.left2  := time
        fd.right  := time
        fd.fvgClr := bprBearColor

    [fd, open, close, high, low, high[1], low[1], close[1]]

[bpr_fd, bpr_open_, bpr_close_, bpr_high_, bpr_low_, bpr_high_p, bpr_low_p, bpr_close_p] = request.security(syminfo.tickerid, bprTimeframe, getBPRFvg())

var array<BprFvg> bpr_arrFVDD     = array.new<BprFvg>(0)
var array<BprFvg> bpr_arrFVD_BPR  = array.new<BprFvg>(0)
var array<box>    bpr_arrFVD_BPRBox     = array.new_box(0)
var array<box>    bpr_arrFVD_BPRBoxGray = array.new_box(0)

bprEmaValue = ta.ema(close, bprEMAPeriod)

if bpr_arrFVD_BPRBox.size() > bprCount
    bpr_arrFVD_BPRBox.pop().delete()
    bpr_arrFVD_BPRBoxGray.pop().delete()
    bpr_arrFVD_BPR.pop()

processBPRDetection() =>
    if enableBPR and bpr_open_ != bpr_open_[1]
        bpr_addtimt = 5 * (time[1] - time[2])
        bool bpr_isBPR = false

        if not na(bpr_fd) and not na(bpr_fd[1])
            if bpr_arrFVDD.size() > 0 and (bpr_fd.Type == 1 or bpr_fd.Type == -1)
                bi = 0
                while bi < bpr_arrFVDD.size()
                    oldfd = bpr_arrFVDD.get(bi)
                    c1 = bpr_fd.Top <= oldfd.Top and bpr_fd.Btm >= oldfd.Btm
                    c2 = bpr_fd.Top <= oldfd.Top and bpr_fd.Top > oldfd.Btm and bpr_fd.Btm < oldfd.Btm
                    c3 = bpr_fd.Top > oldfd.Top and bpr_fd.Btm >= oldfd.Btm and bpr_fd.Btm < oldfd.Top
                    c4 = bpr_fd.Top >= oldfd.Top and bpr_fd.Btm <= oldfd.Btm

                    if c1 or c2 or c3 or c4
                        top_ = bpr_fd.Top
                        btm_ = bpr_fd.Btm
                        bleft_ = oldfd.left
                        if c2
                            top_ := bpr_fd.Top
                            btm_ := oldfd.Btm
                        else if c3
                            top_ := oldfd.Top
                            btm_ := bpr_fd.Btm
                        else if c4
                            top_ := oldfd.Top
                            btm_ := oldfd.Btm

                        bpr_isBPR := true
                        // il filtro EMA decide solo se la BPR e' VISIBILE, non se viene tracciata:
                        // conta sempre per il BPR Master Filter anche quando disegnata invisibile
                        bprVisible = not enableBPREMADisplayFilter or (bpr_fd.Type == 1 ? close > bprEmaValue : close < bprEmaValue)
                        bpr_fillColor  = bpr_fd.Type == 1 ? bprBullFillColor : bprBearFillColor
                        bpr_borderClr  = bprVisible ? bpr_fd.fvgClr    : color(na)
                        bpr_fillClr    = bprVisible ? bpr_fillColor    : color(na)
                        bpr_grayBorder = bprVisible ? bprGrayBorderColor : color(na)
                        bpr_grayFill   = bprVisible ? bprGrayFillColor : color(na)
                        bpr_labelColor = bpr_fd.Type == 1 ? bprBullLabelColor : bprBearLabelColor
                        bpr_textClr    = bprVisible ? bpr_labelColor  : color(na)
                        bpr_labelTxt   = bprVisible ? "BPR" : ""
                        bpr_arrFVD_BPR.unshift(BprFvg.new(bpr_fd.Type, top_, btm_, bleft_, time, 0))
                        // parte grigia: dalla nascita del primo FVG fino alla candela che lo rompe/conferma come BPR (statica, non si estende piu)
                        bpr_arrFVD_BPRBoxGray.unshift(box.new(bleft_, top_, time, btm_, border_color=bpr_grayBorder, bgcolor=bpr_grayFill, xloc=xloc.bar_time, border_style=bprStyleInput))
                        // parte colorata: dalla conferma in poi (verde/rosso), si estende ad ogni update come prima
                        bpr_arrFVD_BPRBox.unshift(box.new(time, top_, time, btm_, border_color=bpr_borderClr, bgcolor=bpr_fillClr, xloc=xloc.bar_time, border_style=bprStyleInput, text=bpr_labelTxt, text_size=bprLabelSize, text_halign=text.align_right, text_color=bpr_textClr))

                    bi += 1

        bpr_bullMit = bprMitigationTypeWick ? bpr_low_ : bpr_close_
        bpr_bearMit = bprMitigationTypeWick ? bpr_high_ : bpr_close_

        // testing BPR box mitigation
        if bpr_arrFVD_BPR.size() > 0
            bi = 0
            while bi < bpr_arrFVD_BPR.size()
                fdn = bpr_arrFVD_BPR.get(bi)
                bpr_arrFVD_BPRBox.get(bi).set_right(time + bpr_addtimt)

                bpr_minval = math.min(fdn.Top, fdn.Btm)
                bpr_maxval = math.max(fdn.Top, fdn.Btm)
                bpr_midPnt = (bpr_maxval - bpr_minval) * bprMitigationPct * 0.01

                if fdn.Type == 1
                    if bpr_bullMit < (bpr_maxval - bpr_midPnt)
                        bx  = bpr_arrFVD_BPRBox.remove(bi)
                        bxg = bpr_arrFVD_BPRBoxGray.remove(bi)
                        if showMitigatedBPR
                            bx.set_right(time)
                        else
                            bx.delete()
                            bxg.delete()
                        bpr_arrFVD_BPR.remove(bi)
                        bi -= 1
                else
                    if bpr_bearMit > (bpr_minval + bpr_midPnt)
                        bx  = bpr_arrFVD_BPRBox.remove(bi)
                        bxg = bpr_arrFVD_BPRBoxGray.remove(bi)
                        if showMitigatedBPR
                            bx.set_right(time)
                        else
                            bx.delete()
                            bxg.delete()
                        bpr_arrFVD_BPR.remove(bi)
                        bi -= 1

                bi += 1

        bpr_bullMitp = bprMitigationTypeWick ? bpr_low_p : bpr_close_p
        bpr_bearMitp = bprMitigationTypeWick ? bpr_high_p : bpr_close_p

        // clean stale FVGs used only for BPR pairing
        if bpr_arrFVDD.size() > 0
            bi = 0
            while bi < bpr_arrFVDD.size()
                fdn = bpr_arrFVDD.get(bi)

                bpr_minval = math.min(fdn.Top, fdn.Btm)
                bpr_maxval = math.max(fdn.Top, fdn.Btm)
                bpr_midPnt = (bpr_maxval - bpr_minval) * bprMitigationPct * 0.01

                if fdn.Type == 1
                    if bpr_bullMitp < (bpr_maxval - bpr_midPnt)
                        bpr_arrFVDD.remove(bi)
                        bi -= 1
                else
                    if bpr_bearMitp > (bpr_minval + bpr_midPnt)
                        bpr_arrFVDD.remove(bi)
                        bi -= 1
                bi += 1

        if not na(bpr_fd) and not na(bpr_fd[1])
            if bpr_fd.Type == 1 or bpr_fd.Type == -1
                bpr_arrFVDD.unshift(bpr_fd)

processBPRDetection()

// === HTF BPR (BALANCED PRICE RANGE su timeframe superiore) ===
[htf_bpr_fd, htf_bpr_open_, htf_bpr_close_, htf_bpr_high_, htf_bpr_low_, htf_bpr_high_p, htf_bpr_low_p, htf_bpr_close_p] = request.security(syminfo.tickerid, htfBPRTimeframe, getBPRFvg())

var array<BprFvg> htf_arrFVDD     = array.new<BprFvg>(0)
var array<BprFvg> htf_arrFVD_BPR  = array.new<BprFvg>(0)
var array<box>    htf_arrFVD_BPRBox     = array.new_box(0)
var array<box>    htf_arrFVD_BPRBoxGray = array.new_box(0)

if htf_arrFVD_BPRBox.size() > htfBprCount
    htf_arrFVD_BPRBox.pop().delete()
    htf_arrFVD_BPRBoxGray.pop().delete()
    htf_arrFVD_BPR.pop()

processHTFBPRDetection() =>
    if enableHTFBPR and htf_bpr_open_ != htf_bpr_open_[1]
        htf_addtimt = 5 * (time[1] - time[2])

        if not na(htf_bpr_fd) and not na(htf_bpr_fd[1])
            if htf_arrFVDD.size() > 0 and (htf_bpr_fd.Type == 1 or htf_bpr_fd.Type == -1)
                hi = 0
                while hi < htf_arrFVDD.size()
                    oldfd = htf_arrFVDD.get(hi)
                    c1 = htf_bpr_fd.Top <= oldfd.Top and htf_bpr_fd.Btm >= oldfd.Btm
                    c2 = htf_bpr_fd.Top <= oldfd.Top and htf_bpr_fd.Top > oldfd.Btm and htf_bpr_fd.Btm < oldfd.Btm
                    c3 = htf_bpr_fd.Top > oldfd.Top and htf_bpr_fd.Btm >= oldfd.Btm and htf_bpr_fd.Btm < oldfd.Top
                    c4 = htf_bpr_fd.Top >= oldfd.Top and htf_bpr_fd.Btm <= oldfd.Btm

                    if c1 or c2 or c3 or c4
                        top_ = htf_bpr_fd.Top
                        btm_ = htf_bpr_fd.Btm
                        bleft_ = oldfd.left
                        if c2
                            top_ := htf_bpr_fd.Top
                            btm_ := oldfd.Btm
                        else if c3
                            top_ := oldfd.Top
                            btm_ := htf_bpr_fd.Btm
                        else if c4
                            top_ := oldfd.Top
                            btm_ := oldfd.Btm

                        // funzione solo visiva: nessun filtro EMA, sempre visibile
                        htf_borderClr = htf_bpr_fd.Type == 1 ? htfBprBullColor : htfBprBearColor
                        htf_fillClr   = htf_bpr_fd.Type == 1 ? htfBprBullFillColor : htfBprBearFillColor
                        htf_labelClr  = htf_bpr_fd.Type == 1 ? htfBprBullLabelColor : htfBprBearLabelColor
                        htf_labelTxt  = "BPR " + htfTFLabel(htfBPRTimeframe)
                        htf_arrFVD_BPR.unshift(BprFvg.new(htf_bpr_fd.Type, top_, btm_, bleft_, time, 0))
                        htf_arrFVD_BPRBoxGray.unshift(box.new(bleft_, top_, time, btm_, border_color=bprGrayBorderColor, bgcolor=bprGrayFillColor, xloc=xloc.bar_time, border_style=bprStyleInput))
                        htf_arrFVD_BPRBox.unshift(box.new(time, top_, time, btm_, border_color=htf_borderClr, bgcolor=htf_fillClr, xloc=xloc.bar_time, border_style=bprStyleInput, text=htf_labelTxt, text_size=bprLabelSize, text_halign=text.align_right, text_color=htf_labelClr))

                    hi += 1

        htf_bullMit = bprMitigationTypeWick ? htf_bpr_low_ : htf_bpr_close_
        htf_bearMit = bprMitigationTypeWick ? htf_bpr_high_ : htf_bpr_close_

        if htf_arrFVD_BPR.size() > 0
            hi = 0
            while hi < htf_arrFVD_BPR.size()
                fdn = htf_arrFVD_BPR.get(hi)
                htf_arrFVD_BPRBox.get(hi).set_right(time + htf_addtimt)

                htf_minval = math.min(fdn.Top, fdn.Btm)
                htf_maxval = math.max(fdn.Top, fdn.Btm)
                htf_midPnt = (htf_maxval - htf_minval) * bprMitigationPct * 0.01

                if fdn.Type == 1
                    if htf_bullMit < (htf_maxval - htf_midPnt)
                        bx  = htf_arrFVD_BPRBox.remove(hi)
                        bxg = htf_arrFVD_BPRBoxGray.remove(hi)
                        if showMitigatedBPR
                            bx.set_right(time)
                        else
                            bx.delete()
                            bxg.delete()
                        htf_arrFVD_BPR.remove(hi)
                        hi -= 1
                else
                    if htf_bearMit > (htf_minval + htf_midPnt)
                        bx  = htf_arrFVD_BPRBox.remove(hi)
                        bxg = htf_arrFVD_BPRBoxGray.remove(hi)
                        if showMitigatedBPR
                            bx.set_right(time)
                        else
                            bx.delete()
                            bxg.delete()
                        htf_arrFVD_BPR.remove(hi)
                        hi -= 1

                hi += 1

        htf_bullMitp = bprMitigationTypeWick ? htf_bpr_low_p : htf_bpr_close_p
        htf_bearMitp = bprMitigationTypeWick ? htf_bpr_high_p : htf_bpr_close_p

        if htf_arrFVDD.size() > 0
            hi = 0
            while hi < htf_arrFVDD.size()
                fdn = htf_arrFVDD.get(hi)

                htf_minval = math.min(fdn.Top, fdn.Btm)
                htf_maxval = math.max(fdn.Top, fdn.Btm)
                htf_midPnt = (htf_maxval - htf_minval) * bprMitigationPct * 0.01

                if fdn.Type == 1
                    if htf_bullMitp < (htf_maxval - htf_midPnt)
                        htf_arrFVDD.remove(hi)
                        hi -= 1
                else
                    if htf_bearMitp > (htf_minval + htf_midPnt)
                        htf_arrFVDD.remove(hi)
                        hi -= 1
                hi += 1

        if not na(htf_bpr_fd) and not na(htf_bpr_fd[1])
            if htf_bpr_fd.Type == 1 or htf_bpr_fd.Type == -1
                htf_arrFVDD.unshift(htf_bpr_fd)

processHTFBPRDetection()

// Estende verso destra la fine delle BPR HTF ad ogni barra del grafico (anche in tempo reale),
// invece di aggiornarla solo alla chiusura di ogni barra HTF. Il margine è lo stesso (5 barre) delle BPR normali.
// L'invalidazione (mitigazione) resta legata alla barra HTF; le BPR mitigate escono dall'array e non si estendono più.
extendHTFBPRBoxes() =>
    if enableHTFBPR and htf_arrFVD_BPRBox.size() > 0
        ext = 5 * timeframe.in_seconds() * 1000
        for k = 0 to htf_arrFVD_BPRBox.size() - 1
            htf_arrFVD_BPRBox.get(k).set_right(time + ext)

extendHTFBPRBoxes()

// === BPR MASTER FILTER ===
passesBPRMasterFilter() =>
    result = true
    if enableBPRMasterFilter
        result := false
        if bpr_arrFVD_BPR.size() > 0
            for bi = 0 to bpr_arrFVD_BPR.size() - 1
                fdn  = bpr_arrFVD_BPR.get(bi)
                bTop = math.max(fdn.Top, fdn.Btm)
                bBtm = math.min(fdn.Top, fdn.Btm)
                bprEmaOk = not enableBPREMADisplayFilter or (fdn.Type == 1 ? close > bprEmaValue : close < bprEmaValue)
                if high >= bBtm and low <= bTop and bprEmaOk
                    result := true
                    break
    result

// === MT CANDLES MASTER FILTER ===
passesMTCandleMasterFilter(bool wantBull) =>
    not enableMTCandleMasterFilter or (wantBull ? mtTableAllBull : mtTableAllBear)

// === SUPERTREND MASTER FILTER ===
// Se il filtro è spento o la linea non è ancora disponibile (na) il segnale passa.
passesSTMasterFilter(bool wantBull) =>
    not enableSuperTrendMasterFilter or na(stFilterLine) or (wantBull ? close > stFilterLine : close < stFilterLine)

// === BPR IN / OUT DETECTION (per alert) ===
bool bprBullIn  = false
bool bprBullOut = false
bool bprBearIn  = false
bool bprBearOut = false

if bpr_arrFVD_BPR.size() > 0 and isInTimeRange()
    for bi = 0 to bpr_arrFVD_BPR.size() - 1
        fdn  = bpr_arrFVD_BPR.get(bi)
        bTop = math.max(fdn.Top, fdn.Btm)
        bBtm = math.min(fdn.Top, fdn.Btm)
        wasInside = close[1] <= bTop and close[1] >= bBtm
        isInside  = close    <= bTop and close    >= bBtm
        bprEmaOk  = not enableBPREMADisplayFilter or (fdn.Type == 1 ? close > bprEmaValue : close < bprEmaValue)
        if bprEmaOk
            if fdn.Type == 1
                if not wasInside and isInside and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
                    bprBullIn := true
                if wasInside and not isInside and close > bTop and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
                    bprBullOut := true
            else
                if not wasInside and isInside and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
                    bprBearIn := true
                if wasInside and not isInside and close < bBtm and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
                    bprBearOut := true

// === BF REJECTION ===
bool bfBullRejection = false
bool bfBearRejection = false

if showBFRejection and isInTimeRange()
    isBullishCandle     = close > open
    lowerWickTouchesBF  = low <= bf
    bodyAboveBF         = math.min(open, close) > bf
    bfEMAConditionBull  = not useBFEMAFilter or close > bfEMA
    vwapConditionBull   = not enableVWAPFilter or close > vwap
    ema750ConditionBull = not enableEMA750MasterFilter or close > ema750
    atrConditionBull    = not enableATRMode or close <= upperBand
    if isBullishCandle and lowerWickTouchesBF and bodyAboveBF and bfEMAConditionBull and vwapConditionBull and ema750ConditionBull and atrConditionBull and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
        bfBullRejection := true
    isBearishCandle     = close < open
    upperWickTouchesBF  = high >= bf
    bodyBelowBF         = math.max(open, close) < bf
    bfEMAConditionBear  = not useBFEMAFilter or close < bfEMA
    vwapConditionBear   = not enableVWAPFilter or close < vwap
    ema750ConditionBear = not enableEMA750MasterFilter or close < ema750
    atrConditionBear    = not enableATRMode or close >= lowerBand
    if isBearishCandle and upperWickTouchesBF and bodyBelowBF and bfEMAConditionBear and vwapConditionBear and ema750ConditionBear and atrConditionBear and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
        bfBearRejection := true

// === VIDYA REJECTION ===
bool vidyaBullRejection = false
bool vidyaBearRejection = false

if showVidyaRejection and isInTimeRange() and not na(vidya_value)
    isBullishCandleV      = close > open
    lowerWickTouchesVidya = low <= vidya_value
    bodyAboveVidya        = math.min(open, close) > vidya_value
    vidyaEMACondBull      = not useVidyaEMAFilter or close > vidyaRejEMA
    vwapCondBullV         = not enableVWAPFilter or close > vwap
    ema750CondBullV       = not enableEMA750MasterFilter or close > ema750
    atrCondBullV          = not enableATRMode or close <= upperBand
    if isBullishCandleV and lowerWickTouchesVidya and bodyAboveVidya and vidyaEMACondBull and vwapCondBullV and ema750CondBullV and atrCondBullV and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
        vidyaBullRejection := true
    isBearishCandleV      = close < open
    upperWickTouchesVidya = high >= vidya_value
    bodyBelowVidya        = math.max(open, close) < vidya_value
    vidyaEMACondBear      = not useVidyaEMAFilter or close < vidyaRejEMA
    vwapCondBearV         = not enableVWAPFilter or close < vwap
    ema750CondBearV       = not enableEMA750MasterFilter or close < ema750
    atrCondBearV          = not enableATRMode or close >= lowerBand
    if isBearishCandleV and upperWickTouchesVidya and bodyBelowVidya and vidyaEMACondBear and vwapCondBearV and ema750CondBearV and atrCondBearV and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
        vidyaBearRejection := true

// === KCANDLE/BOOST ===
bull(cOpen, cClose) => cClose > cOpen
bear(cOpen, cClose) => cClose < cOpen

openPrev  = open[1]
closePrev = close[1]

isBullEngulf = bear(openPrev, closePrev) and bull(open, close) and open <= closePrev and close >= openPrev
isBearEngulf = bull(openPrev, closePrev) and bear(open, close) and open >= closePrev and close <= openPrev
isBullValid  = isBullEngulf and close > emaKCandle
isBearValid  = isBearEngulf and close < emaKCandle
isOrange     = isBullValid or isBearValid

// === KCANDLE LINES ===
rangeHL  = high - low
levelMid = low + 0.50 * rangeHL
var line[] lines       = array.new_line()
var box[]  goldenBoxes = array.new_box()

if isOrange and not na(rangeHL) and showKCandleLines and isInTimeRange() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(isBullValid) and passesSTMasterFilter(isBullValid)
    float goldenAreaTop    = na
    float goldenAreaBottom = na
    if isBullValid
        goldenAreaBottom := low + (goldenAreaLowerLevel / 100) * rangeHL
        goldenAreaTop    := levelMid
        l1 = line.new(x1=bar_index, y1=goldenAreaBottom, x2=bar_index + extendBars, y2=goldenAreaBottom, xloc=xloc.bar_index, extend=extend.none, color=line25Color,     width=1, style=line.style_solid)
        l2 = line.new(x1=bar_index, y1=goldenAreaTop,    x2=bar_index + extendBars, y2=goldenAreaTop,    xloc=xloc.bar_index, extend=extend.none, color=kCandleBullColor, width=1, style=line.style_dashed)
        array.push(lines, l1)
        array.push(lines, l2)
    else if isBearValid
        goldenAreaBottom := levelMid
        goldenAreaTop    := low + (goldenAreaUpperLevel / 100) * rangeHL
        l1 = line.new(x1=bar_index, y1=goldenAreaBottom, x2=bar_index + extendBars, y2=goldenAreaBottom, xloc=xloc.bar_index, extend=extend.none, color=kCandleBearColor, width=1, style=line.style_dashed)
        l2 = line.new(x1=bar_index, y1=goldenAreaTop,    x2=bar_index + extendBars, y2=goldenAreaTop,    xloc=xloc.bar_index, extend=extend.none, color=line75Color,     width=1, style=line.style_solid)
        array.push(lines, l1)
        array.push(lines, l2)
    if showGoldenArea and not na(goldenAreaTop) and not na(goldenAreaBottom)
        goldenAreaColorToUse = isBullValid ? kCandleBullColor : kCandleBearColor
        goldenBox = box.new(left=bar_index, top=goldenAreaTop, right=bar_index + extendBars, bottom=goldenAreaBottom, bgcolor=color.new(goldenAreaColorToUse, 85), border_color=color.new(goldenAreaColorToUse, 100), border_width=1)
        array.push(goldenBoxes, goldenBox)
        if array.size(goldenBoxes) > maxLines
            oldBox = array.shift(goldenBoxes)
            box.delete(oldBox)
    if array.size(lines) > maxLines * 2
        for i = 0 to 1
            if array.size(lines) > 0
                old = array.shift(lines)
                line.delete(old)

// === ORDER BLOCKS ===
price_change = close - close[1]
avg_change   = ta.sma(price_change, zscore_length)
std_change   = ta.stdev(price_change, zscore_length)
zscore       = (price_change - avg_change) / std_change

obHighestClose = ta.highest(close, ob_lookback)[1]
obLowestClose  = ta.lowest(close, ob_lookback)[1]

bullish_impulse    = zscore > zscore_threshold and close > open
obEMAConditionBull = not useOBEMAFilter or close > obEMA
strong_bull_ob     = bullish_impulse and close > obHighestClose and obEMAConditionBull and (not enableATRMode or close <= upperBand) and isInTimeRange() and (not enableVWAPFilter or close > vwap) and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesSTMasterFilter(true)

bearish_impulse    = zscore < -zscore_threshold and close < open
obEMAConditionBear = not useOBEMAFilter or close < obEMA
strong_bear_ob     = bearish_impulse and close < obLowestClose and obEMAConditionBear and (not enableATRMode or close >= lowerBand) and isInTimeRange() and (not enableVWAPFilter or close < vwap) and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesSTMasterFilter(false)

is_overlapping(float new_top, float new_bottom, float existing_top, float existing_bottom) =>
    not (new_bottom > existing_top or new_top < existing_bottom)

createBullOB() =>
    if enableOrderBlocks and strong_bull_ob and show_bullish_ob
        base_low   = low[1]
        base_high  = high[1]
        base_index = 1
        for i = 1 to ob_lookback
            if low[i] < base_low
                base_low   := low[i]
                base_high  := high[i]
                base_index := i
        passesEMAFilter = not useOBEMAFilter or base_low > obEMA
        can_create = passesEMAFilter
        if can_create and prevent_overlap_ob and array.size(active_zones) > 0
            for i = 0 to array.size(active_zones) - 1
                ob = array.get(active_zones, i)
                if ob.is_active and ob.is_bullish
                    if is_overlapping(base_high, base_low, ob.top, ob.bottom)
                        can_create := false
                        break
        if can_create
            new_box  = box.new(bar_index - base_index, base_high, bar_index + 1, base_low, border_color=bull_border_ob, bgcolor=bull_color_ob, border_width=1)
            new_line = show_midline_ob ? line.new(bar_index - base_index, (base_high + base_low) / 2, bar_index + 1, (base_high + base_low) / 2, color=bull_midline_ob, style=line.style_dashed, width=1) : na
            ob = OrderBlock.new(new_box, new_line, base_high, base_low, bar_index, true, true)
            array.push(active_zones, ob)

createBullOB()

createBearOB() =>
    if enableOrderBlocks and strong_bear_ob and show_bearish_ob
        base_high  = high[1]
        base_low   = low[1]
        base_index = 1
        for i = 1 to ob_lookback
            if high[i] > base_high
                base_high  := high[i]
                base_low   := low[i]
                base_index := i
        passesEMAFilter = not useOBEMAFilter or base_high < obEMA
        can_create = passesEMAFilter
        if can_create and prevent_overlap_ob and array.size(active_zones) > 0
            for i = 0 to array.size(active_zones) - 1
                ob = array.get(active_zones, i)
                if ob.is_active and not ob.is_bullish
                    if is_overlapping(base_high, base_low, ob.top, ob.bottom)
                        can_create := false
                        break
        if can_create
            new_box  = box.new(bar_index - base_index, base_high, bar_index + 1, base_low, border_color=bear_border_ob, bgcolor=bear_color_ob, border_width=1)
            new_line = show_midline_ob ? line.new(bar_index - base_index, (base_high + base_low) / 2, bar_index + 1, (base_high + base_low) / 2, color=bear_midline_ob, style=line.style_dashed, width=1) : na
            ob = OrderBlock.new(new_box, new_line, base_high, base_low, bar_index, false, true)
            array.push(active_zones, ob)

createBearOB()

checkOBRejections() =>
    bool bullFlag = false
    bool bearFlag = false
    if enableOrderBlocks and array.size(active_zones) > 0
        for i = array.size(active_zones) - 1 to 0
            ob = array.get(active_zones, i)
            if ob.is_active
                box.set_right(ob.zone_box, bar_index + 1)
                if show_midline_ob and not na(ob.mid_line)
                    line.set_x2(ob.mid_line, bar_index + 1)
                is_mitigated = ob.is_bullish ? close < ob.bottom : close > ob.top
                age          = bar_index - ob.birth_bar
                is_expired   = age > max_age_ob
                if is_mitigated or is_expired
                    ob.is_active := false
                    box.set_right(ob.zone_box, bar_index)
                    if show_midline_ob and not na(ob.mid_line)
                        line.set_x2(ob.mid_line, bar_index)
                if show_rejections_ob and ob.is_active
                    zone_height        = ob.top - ob.bottom
                    rejection_distance = zone_height * (rejection_threshold_ob / 100)
                    if ob.is_bullish
                        touches_zone     = low <= ob.top and low >= ob.bottom
                        bounces_up       = close > open and (close - low) > rejection_distance
                        ema_condition    = not useOBEMAFilter or close > obEMA
                        vwap_condition   = not enableVWAPFilter or close > vwap
                        ema750_condition = not enableEMA750MasterFilter or close > ema750
                        bf_condition     = not enableButterworthMasterFilter or close > bf
                        if touches_zone and bounces_up and ema_condition and vwap_condition and ema750_condition and bf_condition and isInTimeRange() and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
                            bullFlag := true
                    else
                        touches_zone     = high >= ob.bottom and high <= ob.top
                        bounces_down     = close < open and (high - close) > rejection_distance
                        ema_condition    = not useOBEMAFilter or close < obEMA
                        vwap_condition   = not enableVWAPFilter or close < vwap
                        ema750_condition = not enableEMA750MasterFilter or close < ema750
                        bf_condition     = not enableButterworthMasterFilter or close < bf
                        if touches_zone and bounces_down and ema_condition and vwap_condition and ema750_condition and bf_condition and isInTimeRange() and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
                            bearFlag := true

    [bullFlag, bearFlag]

[bull_rejection_ob, bear_rejection_ob] = checkOBRejections()

// Scansiona le Master Trend Line attive e segnala il PRIMO tocco (low<=price<=high) di ciascuna linea,
// nella direzione coerente con la posizione del prezzo rispetto a EMA750/Butterworth (stessa logica
// direzionale della MT Line Rejection, ma senza richiedere la conferma a chiusura candela).
// Con Overlap Trades disattivato ogni linea segnala UNA sola volta; se attivo, ritocchi successivi
// della stessa linea possono generare nuovi ingressi.
checkMTLineFirstTouch() =>
    bool bullTouch = false
    bool bearTouch = false
    float bullTouchPrice = na
    float bearTouchPrice = na
    if isInTimeRange() and array.size(activeMasterTrendLines) > 0
        for i = array.size(activeMasterTrendLines) - 1 to 0
            mtLine = array.get(activeMasterTrendLines, i)
            if bar_index > mtLine.start_bar and bar_index <= (mtLine.start_bar + masterTrendLineExtension)
                if low <= mtLine.price_level and high >= mtLine.price_level and (not mtLine.touchedForEntry or overlapTrades_SW)
                    dirBull = close > ema750 and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesSTMasterFilter(true)
                    dirBear = close < ema750 and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesSTMasterFilter(false)
                    if dirBull
                        bullTouch := true
                        bullTouchPrice := mtLine.price_level
                        mtLine.touchedForEntry := true
                    else if dirBear
                        bearTouch := true
                        bearTouchPrice := mtLine.price_level
                        mtLine.touchedForEntry := true
    [bullTouch, bearTouch, bullTouchPrice, bearTouchPrice]

// Segnale SuperTrend: ingresso quando la direzione del SuperTrend cambia (long se diventa rialzista,
// short se diventa ribassista). Rispetta gli stessi Master Filter degli altri segnali.
checkSuperTrendFlip() =>
    flipBull = stFilterDir < 0 and stFilterDir[1] > 0
    flipBear = stFilterDir > 0 and stFilterDir[1] < 0
    bullOk = isInTimeRange() and (not enableVWAPFilter or close > vwap) and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true)
    bearOk = isInTimeRange() and (not enableVWAPFilter or close < vwap) and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false)
    [flipBull and bullOk, flipBear and bearOk]

// ══════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// ══════════════════════════════════════════════════════════════
swingHighSweepTS = ta.pivothigh(high, swingLenSweep_TS, swingLenSweep_TS)
swingLowSweepTS  = ta.pivotlow (low,  swingLenSweep_TS, swingLenSweep_TS)

var float lastSHSweepTS    = na
var float lastSLSweepTS    = na
var int   lastSHBarSweepTS = na
var int   lastSLBarSweepTS = na
var float prevSHSweepTS    = na
var float prevSLSweepTS    = na
var int   prevSHBarSweepTS = na
var int   prevSLBarSweepTS = na

if not na(swingHighSweepTS)
    prevSHSweepTS    := lastSHSweepTS
    prevSHBarSweepTS := lastSHBarSweepTS
    lastSHSweepTS    := swingHighSweepTS
    lastSHBarSweepTS := bar_index - swingLenSweep_TS
if not na(swingLowSweepTS)
    prevSLSweepTS    := lastSLSweepTS
    prevSLBarSweepTS := lastSLBarSweepTS
    lastSLSweepTS    := swingLowSweepTS
    lastSLBarSweepTS := bar_index - swingLenSweep_TS

bearSweep_TS1 = not na(lastSHSweepTS) and high > lastSHSweepTS and close < lastSHSweepTS
bullSweep_TS1 = not na(lastSLSweepTS) and low  < lastSLSweepTS and close > lastSLSweepTS

bearSweep_TS2 = false
bullSweep_TS2 = false
if not na(lastSHSweepTS)
    for i = 1 to sweepLookback_TS
        if close[i] > lastSHSweepTS and close < lastSHSweepTS
            bearSweep_TS2 := true
            break
if not na(lastSLSweepTS)
    for i = 1 to sweepLookback_TS
        if close[i] < lastSLSweepTS and close > lastSLSweepTS
            bullSweep_TS2 := true
            break

bullSweep_TS = enableLiqSweep and (bullSweep_TS1 or bullSweep_TS2) and isInTimeRange() and (not sweepEMAFilter_TS  or close > ema750) and (not sweepVIDYAFilter_TS or (not na(vidya_value) and close > vidya_value)) and (not sweepVWAPFilter_TS or close > vwap) and passesVolScoreFilter() and passesBPRMasterFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
bearSweep_TS = enableLiqSweep and (bearSweep_TS1 or bearSweep_TS2) and isInTimeRange() and (not sweepEMAFilter_TS  or close < ema750) and (not sweepVIDYAFilter_TS or (not na(vidya_value) and close < vidya_value)) and (not sweepVWAPFilter_TS or close < vwap) and passesVolScoreFilter() and passesBPRMasterFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)

if bullSweep_TS or bearSweep_TS
    lastSweepBar := bar_index

// ══════════════════════════════════════════════════════════════
// SESSION TAG
// ══════════════════════════════════════════════════════════════
inTF1_SW = enableTimeFilter  and not na(time(timeframe.period, timeFilter1Session, getTimezoneString()))
inTF2_SW = enableTimeFilter2 and not na(time(timeframe.period, timeFilter2Session, getTimezoneString()))
inTF3_SW = enableTimeFilter3 and not na(time(timeframe.period, timeFilter3Session, getTimezoneString()))

sweepCurSession =
     inTF1_SW ? "TF1" :
     inTF2_SW ? "TF2" :
     inTF3_SW ? "TF3" :
     (enableTimeFilter or enableTimeFilter2 or enableTimeFilter3) ? "Off-Filter" : "No-Filter"

// ══════════════════════════════════════════════════════════════
// SWEEP STATS VARS
// ══════════════════════════════════════════════════════════════
var int   sw_totTrades   = 0
var int   sw_totWins     = 0
var int   sw_totBE       = 0
// ── Trade Off-Filter (aperti fuori dai Time Filter): contati a parte, NON entrano in TOTAL né nelle altre statistiche aggregate ──
var int   sw_off_t  = 0
var int   sw_off_w  = 0
var int   sw_off_be = 0
var float sw_off_wp = 0.0
var float sw_off_lp = 0.0
var float sw_off_wr = 0.0
var float sw_off_lr = 0.0
var float sw_totWinPips  = 0.0
var float sw_totLossPips = 0.0
var float sw_totRRSum    = 0.0

var int   sw_tf1_t   = 0 , var int   sw_tf1_w   = 0 , var int   sw_tf1_be  = 0
var float sw_tf1_wp  = 0.0, var float sw_tf1_lp  = 0.0
var int   sw_tf2_t   = 0 , var int   sw_tf2_w   = 0 , var int   sw_tf2_be  = 0
var float sw_tf2_wp  = 0.0, var float sw_tf2_lp  = 0.0
var int   sw_tf3_t   = 0 , var int   sw_tf3_w   = 0 , var int   sw_tf3_be  = 0
var float sw_tf3_wp  = 0.0, var float sw_tf3_lp  = 0.0

// ── R accumulati per sessione ──
var float sw_tf1_wr = 0.0
var float sw_tf1_lr = 0.0
var float sw_tf2_wr = 0.0
var float sw_tf2_lr = 0.0
var float sw_tf3_wr = 0.0
var float sw_tf3_lr = 0.0
var float sw_tot_wr = 0.0
var float sw_tot_lr = 0.0

// ── Partial Close stats ──
var int   sw_partial_t     = 0
var int   sw_partial_long_t  = 0
var int   sw_partial_short_t = 0
var float sw_partial_wp = 0.0
var float sw_partial_wr = 0.0

// ── Max Concurrent Trades / Streak ──
var int sw_maxConcurrentTrades = 0
var int sw_curWinStreak        = 0
var int sw_curLossStreak       = 0
var int sw_maxWinStreak        = 0
var int sw_maxLossStreak       = 0

var bool sw_lastWasLong  = false
var bool sw_lastWasShort = false

// ══════════════════════════════════════════════════════════════
// FUNZIONE: apri trade sweep
// ══════════════════════════════════════════════════════════════
swOpenTrade(bool isBull, float entry, float sl, float tp, float swingLvl, int swBar, string sess, int slotIdx, float partialLvl) =>
    slDist   = math.abs(entry - sl)
    tpPips   = math.abs(tp    - entry) / pipSize
    slPips   = slDist / pipSize
    rrActual = slDist > 0 ? math.abs(tp - entry) / slDist : rrRatio_SW
    tpTxt    = showPipLabels_SW ? "TP +" + str.tostring(tpPips, "#.#") + " pips / +" + str.tostring(rrActual, "#.##") + "R" : ""
    slTxt    = showPipLabels_SW ? "SL -" + str.tostring(slPips, "#.#") + " pips / -1.00R" : ""
    entryTxt = str.tostring(entry, format.mintick) + " / " + str.tostring(rrActual, "#.##") + "R " + (isBull ? "▲" : "▼")

    slB = isBull
         ? box.new(bar_index, entry, bar_index + 1, sl,    bgcolor=color.new(#ff1744, 85), border_color=color.new(#ff1744, 100), border_width=0)
         : box.new(bar_index, sl,    bar_index + 1, entry, bgcolor=color.new(#ff1744, 85), border_color=color.new(#ff1744, 100), border_width=0)
    tpB = isBull
         ? box.new(bar_index, tp,    bar_index + 1, entry, bgcolor=color.new(#00e676, 85), border_color=color.new(#00e676, 100), border_width=0)
         : box.new(bar_index, entry, bar_index + 1, tp,    bgcolor=color.new(#00e676, 85), border_color=color.new(#00e676, 100), border_width=0)

    tpL = label.new(bar_index + 1, tp, tpTxt, style=label.style_label_left, textcolor=color.white,
         color=showPipLabels_SW ? color.new(#00e676, 50) : color.new(#00e676, 100), size=size.small)
    slL = label.new(bar_index + 1, sl, slTxt, style=label.style_label_left, textcolor=color.white,
         color=showPipLabels_SW ? color.new(#ff1744, 50) : color.new(#ff1744, 100), size=size.small)
    eL  = showEntryLabel_SW ? label.new(bar_index + 1, entry, entryTxt,
         style=label.style_label_left, textcolor=color.white,
         color=color.new(#888888, 50), size=size.small) : na

    safeSwBar = not na(swBar) ? math.max(swBar, bar_index - 6000) : bar_index
    sLn = showSwingLine_SW and not useFixedRR_SW and not na(swingLvl) and not na(swBar)
     ? line.new(safeSwBar, swingLvl, bar_index + 1, swingLvl, color=color.new(color.gray, 40), width=1, style=line.style_dashed)
     : na

    liveL = showLivePnL_SW ? label.new(bar_index + 1, entry, "", style=label.style_label_left, textcolor=color.white, color=color.new(#888888, 50), size=size.small) : na

    entryLn = line.new(bar_index, entry, bar_index + 1, entry, color=color.new(color.gray, 40), width=1, style=line.style_solid)

    array.push(activeSweepTrades, SweepTrade.new(slB, tpB, tpL, slL, eL, liveL, sLn, sl, tp, entry, sl, swingLvl, bar_index, swBar, isBull, false, sess, false, float(na), slotIdx, partialLvl, false, float(na), float(na), entryLn, 0))

    if entryAlertSW
        alert((isBull ? "▲ LONG" : "▼ SHORT") + " | " + str.upper(entrySignalModeSW) + " | RR 1:" + str.tostring(rrActual, "#.##") + " | Entry " + str.tostring(entry, format.mintick) + " | SL " + str.tostring(sl, format.mintick) + " | TP " + str.tostring(tp, format.mintick), alert.freq_once_per_bar)

// ══════════════════════════════════════════════════════════════
// AGGIORNA TRADE SWEEP ATTIVI
// ══════════════════════════════════════════════════════════════
if array.size(activeSweepTrades) > 0
    for i = array.size(activeSweepTrades) - 1 to 0
        t = array.get(activeSweepTrades, i)

        slHit = t.isBull ? low  <= t.slLevel : high >= t.slLevel
        tpHit = t.isBull ? high >= t.tpLevel : low  <= t.tpLevel
        // Se la stessa candela tocca sia SL che TP, senza dati intrabar non sappiamo quale sia
        // stato raggiunto prima: per prudenza viene considerato uno Stop Loss (tpWins = false),
        // e la gestione ricade nel ramo SL/BE/Trailing sottostante in base a dove si trova slLevel.
        tpWins = tpHit and not slHit

        // Partial Close (creditato solo se la candela non tocca lo SL: nel caso ambiguo vale lo SL)
        if enablePartialSW and not t.partialTaken and not na(t.partialLevel) and not slHit
            if (t.isBull ? high >= t.partialLevel : low <= t.partialLevel)
                t.partialTaken := true
                pDist   = math.abs(t.entryPrice - t.origSL)
                pPips   = math.abs(t.partialLevel - t.entryPrice) / pipSize
                pSLPips = pDist / pipSize
                pRR     = pSLPips > 0 ? pPips / pSLPips : 0.0
                t.partialPipsStored := pPips
                t.partialRRStored   := pRR
                if t.session != "Off-Filter"
                    sw_partial_t  += 1
                    if t.isBull
                        sw_partial_long_t += 1
                    else
                        sw_partial_short_t += 1
                    // contributo reale alla posizione: entra solo la quota chiusa (es. 50%), non l'intera distanza del livello
                    sw_partial_wp += pPips * (partialPctSW / 100.0)
                    sw_partial_wr += pRR   * (partialPctSW / 100.0)
                if showPartialLabelSW
                    label.new(bar_index + 3, t.partialLevel,
                         "🎯 PARTIAL " + str.tostring(partialPctSW, "#") + "% +" + str.tostring(pPips, "#.#") + "p/+" + str.tostring(pRR, "#.##") + "R",
                         style=label.style_label_left, textcolor=color.white, color=color.new(#ffa500, 50), size=size.small)
                line.new(bar_index, t.partialLevel, bar_index + 3, t.partialLevel,
                     xloc=xloc.bar_index, extend=extend.none, color=color.new(#ffa500, 0), width=1, style=line.style_solid)

        if slHit or tpHit
            box.set_right(t.slBox, bar_index)
            box.set_right(t.tpBox, bar_index)
            if not na(t.swingLn)
                line.set_x2(t.swingLn, bar_index)
            if not na(t.entryLine)
                line.set_x2(t.entryLine, bar_index)
            if not na(t.liveLbl)
                label.delete(t.liveLbl)
            if not na(t.entryLbl)
                label.set_x(t.entryLbl, math.max(t.signalBar, bar_index - 6000))
                label.set_style(t.entryLbl, label.style_label_right)
                label.set_color(t.entryLbl, color.new(#888888, 50))

            pips     = math.abs(tpWins ? t.tpLevel - t.entryPrice : t.slLevel - t.entryPrice) / pipSize
            isProfit = t.isBull ? t.slLevel > t.entryPrice : t.slLevel < t.entryPrice
            isBE     = t.slLevel == t.entryPrice
            slPipsForRR = math.abs(t.entryPrice - t.origSL) / pipSize

            // ── Fusione ponderata: risultato del parziale (sempre profitto) + risultato della gamba residua ──
            legPips       = tpWins or isProfit ? pips : isBE ? 0.0 : -pips
            partialWeight = t.partialTaken ? partialPctSW / 100.0 : 0.0
            finalWeight   = 1.0 - partialWeight
            netPips       = t.partialTaken ? (t.partialPipsStored * partialWeight) + (legPips * finalWeight) : legPips
            netRR         = slPipsForRR > 0 ? netPips / slPipsForRR : 0.0
            netIsWin      = netPips > 0
            netIsBE       = netPips == 0

            if tpWins
                tpYOffset = t.slotIndex * atr14 * 0.1
                label.set_x(t.tpLbl, bar_index)
                label.set_y(t.tpLbl, t.tpLevel + tpYOffset)
                tpRR = slPipsForRR > 0 ? pips / slPipsForRR : 0.0
                label.set_text(t.tpLbl, showPipLabels_SW ? "+" + str.tostring(pips, "#.#") + " pips / +" + str.tostring(tpRR, "#.##") + "R" : "")
                label.set_color(t.tpLbl, showPipLabels_SW ? color.new(#00e676, 50) : color.new(#00e676, 100))
                box.set_bgcolor     (t.slBox, color.new(#888888, 85))
                box.set_border_color(t.slBox, color.new(#888888, 100))
                label.delete(t.slLbl)
                if alertSweepTPSL
                    alert(str.upper(entrySignalModeSW) + " TP HIT ✅ +" + str.tostring(pips, "#.#") + " pips / +" + str.tostring(tpRR, "#.##") + "R", alert.freq_once_per_bar)

            else
                if isProfit
                    trailYOffset = t.slotIndex * atr14 * 0.1
                    label.set_x(t.slLbl, bar_index)
                    label.set_y(t.slLbl, t.slLevel + trailYOffset)
                    trailRR = slPipsForRR > 0 ? pips / slPipsForRR : 0.0
                    label.set_text(t.slLbl, showPipLabels_SW ? "TRAIL +" + str.tostring(pips, "#.#") + " pips / " + str.tostring(trailRR, "#.##") + "R" : "")
                    label.set_color(t.slLbl, showPipLabels_SW ? color.new(#00e676, 50) : color.new(#00e676, 100))
                    label.delete(t.tpLbl)
                    box.set_bgcolor     (t.slBox, color.new(#888888, 100))
                    box.set_border_color(t.slBox, color.new(#888888, 100))
                    box.set_bgcolor     (t.tpBox, color.new(#888888, 100))
                    box.set_border_color(t.tpBox, color.new(#888888, 100))
                    slGrayTop    = t.isBull ? t.entryPrice : t.origSL
                    slGrayBottom = t.isBull ? t.origSL     : t.entryPrice
                    box.new(t.signalBar, slGrayTop, bar_index, slGrayBottom,
                         bgcolor=color.new(#888888, 85), border_color=color.new(#888888, 100), border_width=0, xloc=xloc.bar_index)
                    profitTop    = t.isBull ? t.slLevel    : t.entryPrice
                    profitBottom = t.isBull ? t.entryPrice : t.slLevel
                    box.new(t.signalBar, profitTop, bar_index, profitBottom,
                         bgcolor=color.new(#00e676, 85), border_color=color.new(#00e676, 100), border_width=0, xloc=xloc.bar_index)
                    tpGrayTop    = t.isBull ? t.tpLevel : t.slLevel
                    tpGrayBottom = t.isBull ? t.slLevel : t.tpLevel
                    box.new(t.signalBar, tpGrayTop, bar_index, tpGrayBottom,
                         bgcolor=color.new(#888888, 85), border_color=color.new(#888888, 100), border_width=0, xloc=xloc.bar_index)
                    if alertSweepTPSL
                        alert(str.upper(entrySignalModeSW) + " TRAIL HIT ✅ +" + str.tostring(pips, "#.#") + " pips / +" + str.tostring(trailRR, "#.##") + "R", alert.freq_once_per_bar)

                else if isBE
                    label.set_x(t.slLbl, bar_index)
                    label.set_text(t.slLbl, showPipLabels_SW ? "BE 🔒 0 pips" : "")
                    label.set_color(t.slLbl, showPipLabels_SW ? color.new(#888888, 50) : color.new(#888888, 100))
                    box.set_bgcolor     (t.slBox, color.new(#888888, 85))
                    box.set_border_color(t.slBox, color.new(#888888, 100))
                    box.set_bgcolor     (t.tpBox, color.new(#888888, 85))
                    box.set_border_color(t.tpBox, color.new(#888888, 100))
                    label.delete(t.tpLbl)
                    if alertSweepTPSL
                        alert(str.upper(entrySignalModeSW) + " BE HIT 🔒 0 pips", alert.freq_once_per_bar)

                else
                    slYOffset = t.slotIndex * atr14 * 0.1
                    label.set_x(t.slLbl, bar_index)
                    label.set_y(t.slLbl, t.slLevel - slYOffset)
                    slRR = slPipsForRR > 0 ? pips / slPipsForRR : 0.0
                    label.set_text(t.slLbl, showPipLabels_SW ? "-" + str.tostring(pips, "#.#") + " pips / -" + str.tostring(slRR, "#.##") + "R" : "")
                    label.set_color(t.slLbl, showPipLabels_SW ? color.new(#ff1744, 50) : color.new(#ff1744, 100))
                    box.set_bgcolor     (t.tpBox, color.new(#888888, 85))
                    box.set_border_color(t.tpBox, color.new(#888888, 100))
                    label.delete(t.tpLbl)
                    if alertSweepTPSL
                        alert(str.upper(entrySignalModeSW) + " SL HIT ❌ -" + str.tostring(pips, "#.#") + " pips / -" + str.tostring(slRR, "#.##") + "R", alert.freq_once_per_bar)

            // ── Statistiche UNIFICATE sul risultato NETTO (parziale + gamba residua fusi) ──
            // I trade Off-Filter (fuori dai Time Filter) vanno solo nella loro riga: non toccano TOTAL, Avg RR, serie e parziali.
            if t.session == "Off-Filter"
                sw_off_t += 1
                if netIsWin
                    sw_off_w  += 1
                    sw_off_wp += netPips
                    sw_off_wr += netRR
                else if netIsBE
                    sw_off_be += 1
                else
                    sw_off_lp += -netPips
                    sw_off_lr += -netRR
            else
                if netIsWin
                    sw_totWins    += 1
                    sw_totWinPips += netPips
                    if slPipsForRR > 0 and not useFixedRR_SW
                        sw_totRRSum += netRR
                    sw_tot_wr += netRR
                    sw_curWinStreak  += 1
                    sw_curLossStreak := 0
                    sw_maxWinStreak := math.max(sw_maxWinStreak, sw_curWinStreak)
                    if t.session == "TF1"
                        sw_tf1_t += 1, sw_tf1_w += 1, sw_tf1_wp += netPips, sw_tf1_wr += netRR
                    else if t.session == "TF2"
                        sw_tf2_t += 1, sw_tf2_w += 1, sw_tf2_wp += netPips, sw_tf2_wr += netRR
                    else if t.session == "TF3"
                        sw_tf3_t += 1, sw_tf3_w += 1, sw_tf3_wp += netPips, sw_tf3_wr += netRR
                else if netIsBE
                    sw_totBE += 1
                    if t.session == "TF1"
                        sw_tf1_t += 1, sw_tf1_be += 1
                    else if t.session == "TF2"
                        sw_tf2_t += 1, sw_tf2_be += 1
                    else if t.session == "TF3"
                        sw_tf3_t += 1, sw_tf3_be += 1
                else
                    sw_totLossPips += -netPips
                    sw_tot_lr      += -netRR
                    sw_curLossStreak += 1
                    sw_curWinStreak  := 0
                    sw_maxLossStreak := math.max(sw_maxLossStreak, sw_curLossStreak)
                    if t.session == "TF1"
                        sw_tf1_t += 1, sw_tf1_lp += -netPips, sw_tf1_lr += -netRR
                    else if t.session == "TF2"
                        sw_tf2_t += 1, sw_tf2_lp += -netPips, sw_tf2_lr += -netRR
                    else if t.session == "TF3"
                        sw_tf3_t += 1, sw_tf3_lp += -netPips, sw_tf3_lr += -netRR

                sw_totTrades += 1
            array.remove(activeSweepTrades, i)

        else
            box.set_right(t.slBox, bar_index + 1)
            box.set_right(t.tpBox, bar_index + 1)
            if not na(t.swingLn)
                line.set_x2(t.swingLn, bar_index + 1)
            if not na(t.entryLine)
                line.set_x2(t.entryLine, bar_index + 1)
            if not na(t.entryLbl) and showEntryLabel_SW
                label.set_x    (t.entryLbl, math.max(t.signalBar, bar_index - 6000))
                label.set_style(t.entryLbl, label.style_label_right)
                label.set_color(t.entryLbl, color.new(#888888, 50))

            // Aggiorna posizione etichette TP e SL a destra della candela corrente
            if not na(t.tpLbl)
                label.set_x    (t.tpLbl, bar_index + 1)
                label.set_style(t.tpLbl, label.style_label_left)
            if not na(t.slLbl)
                label.set_x    (t.slLbl, bar_index + 1)
                label.set_style(t.slLbl, label.style_label_left)

            // Live P&L label (impilata verticalmente in base allo slot del trade, sempre visibile a schermo)
            if showLivePnL_SW and not na(t.liveLbl)
                livePips = t.isBull ? (close - t.entryPrice) / pipSize : (t.entryPrice - close) / pipSize
                slPipsForRR_live = math.abs(t.entryPrice - t.origSL) / pipSize
                liveR    = slPipsForRR_live > 0 ? livePips / slPipsForRR_live : 0.0
                liveIsUp = livePips >= 0
                liveTxt  = (liveIsUp ? "+" : "") + str.tostring(livePips, "#.#") + " pips / " + (liveIsUp ? "+" : "") + str.tostring(liveR, "#.##") + "R"
                liveYOffset = t.slotIndex * atr14 * 0.1
                label.set_x    (t.liveLbl, bar_index + 1)
                label.set_y    (t.liveLbl, close + liveYOffset)
                label.set_text (t.liveLbl, liveTxt)
                label.set_color(t.liveLbl, liveIsUp ? color.new(color.green, 50) : color.new(color.red, 50))

            // Trade Update Alert: nuovo multiplo di R raggiunto (1R, 2R, 3R...) sul rischio iniziale.
            // Gira solo finché il trade è aperto: si ferma da solo quando raggiunge TP o SL.
            if tradeUpdateAlertSW
                updRiskDist = math.abs(t.entryPrice - t.origSL)
                if updRiskDist > 0
                    updBestMove = t.isBull ? high - t.entryPrice : t.entryPrice - low
                    updRReached = int(math.floor(updBestMove / updRiskDist))
                    if updRReached > t.rNotified
                        t.rNotified := updRReached
                        updRPrice = t.isBull ? t.entryPrice + updRiskDist * updRReached : t.entryPrice - updRiskDist * updRReached
                        alert((t.isBull ? "▲ LONG" : "▼ SHORT") + " | " + str.upper(entrySignalModeSW) + " | 🎯 " + str.tostring(updRReached) + "R reached @ " + str.tostring(updRPrice, format.mintick), alert.freq_once_per_bar)

            // Breakeven (attivo dalla candela successiva, come il trailing: senza dati intrabar non si sa se lo stop a BE sarebbe stato toccato prima o dopo)
            if enableBE_SW and not t.beTriggered
                slDist  = math.abs(t.entryPrice - t.origSL)
                beLevel = t.isBull ? t.entryPrice + slDist * beRatio_SW : t.entryPrice - slDist * beRatio_SW
                if (t.isBull ? high >= beLevel : low <= beLevel)
                    t.slLevel     := t.entryPrice
                    t.beTriggered := true
                    if t.isBull
                        box.set_top   (t.slBox, t.entryPrice)
                        box.set_bottom(t.slBox, t.origSL)
                    else
                        box.set_top   (t.slBox, t.origSL)
                        box.set_bottom(t.slBox, t.entryPrice)
                    box.set_bgcolor(t.slBox, color.new(#888888, 85))
                    label.set_y(t.slLbl, t.slLevel)
                    label.set_text(t.slLbl, showPipLabels_SW ? "BE 🔒" : "")

            // Trailing Stop
            if enableTrailing_SW
                slDist       = math.abs(t.entryPrice - t.origSL)
                trailTrigger = t.isBull ? t.entryPrice + slDist * trailStartRR_SW : t.entryPrice - slDist * trailStartRR_SW
                trailStep    = trailStepPips_SW * pipSize
                if not t.trailActivated
                    if (t.isBull ? high >= trailTrigger : low <= trailTrigger)
                        t.trailActivated := true
                        t.trailHighWater := t.isBull ? high : low
                if t.trailActivated
                    if t.isBull
                        if high > t.trailHighWater
                            t.trailHighWater := high
                        newSL = t.trailHighWater - trailStep
                        if newSL > t.slLevel
                            t.slLevel := newSL
                            box.set_top   (t.slBox, t.slLevel)
                            box.set_bottom(t.slBox, t.origSL)
                            label.set_y(t.slLbl, t.slLevel)
                            label.set_text(t.slLbl, showPipLabels_SW ? "TS 🔒" : "")
                    else
                        if low < t.trailHighWater
                            t.trailHighWater := low
                        newSL = t.trailHighWater + trailStep
                        if newSL < t.slLevel
                            t.slLevel := newSL
                            box.set_top   (t.slBox, t.origSL)
                            box.set_bottom(t.slBox, t.slLevel)
                            label.set_y(t.slLbl, t.slLevel)
                            label.set_text(t.slLbl, showPipLabels_SW ? "TS 🔒" : "")

// ══════════════════════════════════════════════════════════════
// TAKE PROFIT SYSTEM
// ══════════════════════════════════════════════════════════════
tpRsiBull         = useTPRSI       and (tpRsi > tpRsiOB)
tpMacdBull        = useTPMACD      and tpMacdCrossUnder
tpStochBull       = useTPStoch     and tpStochCrossUnder and tpK > 80
tpBBBull          = useTPBB        and close > tpUpper
tpSTBull          = useTPSTrend    and tpSTDir == -1
tpCCIBull         = useTPCCI       and (tpCCI > tpCCIOB)
tpEmaBull         = useTPEMA       and tpEmaCrossBear
tpPriceActionBull = useTPPriceAction and tpPriceBreakoutBull

tpRsiBear         = useTPRSI       and (tpRsi < tpRsiOS)
tpMacdBear        = useTPMACD      and tpMacdCrossOver
tpStochBear       = useTPStoch     and tpStochCrossOver and tpK < 20
tpBBBear          = useTPBB        and close < tpLower
tpSTBear          = useTPSTrend    and tpSTDir == 1
tpCCIBear         = useTPCCI       and (tpCCI < tpCCIOS)
tpEmaBear         = useTPEMA       and tpEmaCrossBull
tpPriceActionBear = useTPPriceAction and tpPriceBreakoutBear

tpBullCount = (tpRsiBull ? 1 : 0) + (tpMacdBull ? 1 : 0) + (tpStochBull ? 1 : 0) + (tpBBBull ? 1 : 0) + (tpSTBull ? 1 : 0) + (tpCCIBull ? 1 : 0) + (tpEmaBull ? 1 : 0) + (tpPriceActionBull ? 1 : 0)
tpBearCount = (tpRsiBear ? 1 : 0) + (tpMacdBear ? 1 : 0) + (tpStochBear ? 1 : 0) + (tpBBBear ? 1 : 0) + (tpSTBear ? 1 : 0) + (tpCCIBear ? 1 : 0) + (tpEmaBear ? 1 : 0) + (tpPriceActionBear ? 1 : 0)

tpTimeFilterPassed = not applyTPTimeFilter or isInTimeRange()
tpVWAPFilterBull   = not applyTPVWAPFilter or close > vwap
tpVWAPFilterBear   = not applyTPVWAPFilter or close < vwap

// Nota MT Candle Filter: tpBull sopra EMA750 = pallino rialzista (verde richiesto); tpBull sotto EMA750 = triangolo giù (rosso richiesto)
//                        tpBear sotto EMA750 = pallino ribassista (rosso richiesto); tpBear sopra EMA750 = triangolo su (verde richiesto)
tpMTFilterBull = excludeAnomalousTPFromMTFilter ? (close >= ema750 ? passesMTCandleMasterFilter(true)  : true) : passesMTCandleMasterFilter(close >= ema750)
tpMTFilterBear = excludeAnomalousTPFromMTFilter ? (close >  ema750 ? true : passesMTCandleMasterFilter(false)) : passesMTCandleMasterFilter(close > ema750)

tpBullSignal = enableTakeProfit and (tpBullCount >= minTPConfirmations) and (tpBullCount > tpBearCount) and tpTimeFilterPassed and tpVWAPFilterBull and tpMTFilterBull
tpBearSignal = enableTakeProfit and not tpBullSignal and (tpBearCount >= minTPConfirmations) and (tpBearCount > tpBullCount) and tpTimeFilterPassed and tpVWAPFilterBear and tpMTFilterBear

// === YELLOW BAR LOGIC ===
stoK = ta.sma(ta.stoch(close, high, low, 10), 3)
stoD = ta.sma(stoK, 3)

ema750Plot    = plot(ema750,    title = '750 EMA',    color = cleanC(ema750Color),    linewidth = ema750Thickness)
upperBandPlot = plot(upperBand, title = 'Upper Band', color = upperBandColor, linewidth = bandsThickness)
lowerBandPlot = plot(lowerBand, title = 'Lower Band', color = lowerBandColor, linewidth = bandsThickness)

fill(ema750Plot, upperBandPlot, color = upperFillColorDynamic, title = 'Upper band fill color')
fill(ema750Plot, lowerBandPlot, color = lowerFillColorDynamic, title = 'Lower band fill color')

di = (sm - 1.0) / 2.0 + 1.0
c1 = 2 / (di + 1.0)
c2 = 1 - c1
c3 = 3.0 * (cd * cd + cd * cd * cd)
c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd

var float i1 = na
var float i2 = na
var float i3 = na
var float i4 = na
var float i5 = na
var float i6 = na

i1 := c1 * src + c2 * nz(i1[1])
i2 := c1 * i1  + c2 * nz(i2[1])
i3 := c1 * i2  + c2 * nz(i3[1])
i4 := c1 * i3  + c2 * nz(i4[1])
i5 := c1 * i4  + c2 * nz(i5[1])
i6 := c1 * i5  + c2 * nz(i6[1])

bfr  = -cd * cd * cd * i6 + c3 * i5 + c4 * i4 + c5 * i3
bfrC = bfr > nz(bfr[1]) ? color.green : bfr < nz(bfr[1]) ? color.red : color.blue

plot(enableButterworthFilter ? bf : na, title = 'Butterworth Filter', color = cleanC(bfColor), linewidth = bfThickness)

// SuperTrend (visibile con Clean Mode disattivato, anche se il filtro è spento)
// Un solo plot: il colore è na sulla barra del cambio di direzione, così la linea si interrompe
// senza congiungere i due tratti.
stFilterLineColor = not enableCleanMode ? (stFilterDir != stFilterDir[1] ? color(na) : stFilterDir < 0 ? color.teal : color.red) : color(na)
plot(stFilterLine, title = 'SuperTrend', color = stFilterLineColor, linewidth = 1)

colorChange = bfrC != bfrC[1]
longRange   = close >= ema750 and (not enableATRMode or close <= upperBand) and close > ema25 and stoK > 50
shortRange  = close <= ema750 and (not enableATRMode or close >= lowerBand) and close < ema25 and stoK < 50

volumeMA     = ta.sma(volume, 20)
volumeRatio  = volume / volumeMA
volumeScaled = math.max(1, math.min(10, math.round(volumeRatio * 5)))

vwapDisplayColor = cleanC(barstate.islast ? color.new(vwapColor, 35) : vwapColor)
plot(vwap, title = 'VWAP', color = vwapDisplayColor, linewidth = vwapThickness)

vidya_trend_color = cleanC(is_trend_up_vidya ? vidyaUpColor : vidyaDownColor)
plot(showVidyaLine ? vidya_plot_value : na, color = vidya_trend_color, linewidth = vidyaLineThickness, style = plot.style_linebr, title = "VIDYA Line")

vwapCloseBull = close > vwap and open <= vwap
vwapCloseBear = close < vwap and open >= vwap

isOpenNearVWAP() =>
    vwapDistance  = math.abs(open - vwap)
    vwapProximity = vwap * (vwapProximityPercentage / 100)
    vwapDistance <= vwapProximity

passesVolumeFilter(vol) =>
    if not enableVolumeFilter
        true
    else
        if volumeFilterMode == "Singolo"
            vol == volumeFilterSingle
        else
            vol >= volumeFilterMin and vol <= volumeFilterMax

upSignal   = enableUpSignal   and colorChange and bfrC == color.green and longRange  and close > open and close > ema750 and volumeScaled > 5 and isInTimeRange() and passesVolumeFilter(volumeScaled) and (not enableVWAPFilter or close > vwap) and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
downSignal = enableDownSignal and colorChange and bfrC == color.red   and shortRange and close < open and close < ema750 and volumeScaled > 5 and isInTimeRange() and passesVolumeFilter(volumeScaled) and (not enableVWAPFilter or close < vwap) and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)

// === PLOTSHAPES ===
plotshape(upSignal,   title = 'Up Triangle',   location = location.belowbar, color = color.rgb(16, 213, 219), style = shape.triangleup,   size = size.tiny)
plotshape(downSignal, title = 'Down Triangle', location = location.abovebar, color = color.red,               style = shape.triangledown, size = size.tiny)
plotshape(bull_rejection_ob, title = 'OB Bullish Rejection', location = location.belowbar, color = color.rgb(30, 255, 0, 60), style = shape.square, size = size.tiny)
plotshape(bear_rejection_ob, title = 'OB Bearish Rejection', location = location.abovebar, color = color.rgb(255, 0, 0, 50),  style = shape.square, size = size.tiny)
plotshape(bfBullRejection,    title = 'BF Bullish Rejection',    location = location.belowbar, color = color.rgb(255, 235, 59, 0),  style = shape.circle, size = size.auto)
plotshape(bfBearRejection,    title = 'BF Bearish Rejection',    location = location.abovebar, color = color.rgb(255, 235, 59, 0),  style = shape.circle, size = size.auto)
plotshape(vidyaBullRejection, title = 'VIDYA Bullish Rejection', location = location.belowbar, color = color.rgb(23, 223, 173, 0),  style = shape.circle, size = size.auto)
plotshape(vidyaBearRejection, title = 'VIDYA Bearish Rejection', location = location.abovebar, color = color.rgb(221, 50, 107, 0),  style = shape.circle, size = size.auto)

var int tpBullCount_seq = 0
var int tpBearCount_seq = 0

tpLabelATR = atr14

tpBullNormal  = tpBullSignal and close >= ema750
tpBullAnomaly = tpBullSignal and close < ema750
tpBearNormal  = tpBearSignal and close <= ema750
tpBearAnomaly = tpBearSignal and close > ema750

plotchar(tpBullNormal,  title = 'Take Profit Bull',              location = location.abovebar, color = tpBullColor,  char = '.', size = size.tiny)
plotchar(tpBearNormal,  title = 'Take Profit Bear',               location = location.belowbar, color = tpBearColor,  char = '.', size = size.tiny)
plotshape(tpBullAnomaly, title = 'Take Profit Bull (below EMA750)', location = location.abovebar, color = color.rgb(253, 0, 0, 50), style = shape.triangledown, size = size.tiny)
plotshape(tpBearAnomaly, title = 'Take Profit Bear (above EMA750)', location = location.belowbar, color = color.rgb(0, 255, 0, 50), style = shape.triangleup,   size = size.tiny)

if tpBullSignal
    tpBearCount_seq := 0
    tpBullCount_seq += 1
    label.new(bar_index, high + tpLabelATR * tpLabelDistanceATR, text = "TP" + str.tostring(tpBullCount_seq), color = color.new(color.black, 100), textcolor = color.white, size = size.small, style = label.style_label_down)

if tpBearSignal
    tpBullCount_seq := 0
    tpBearCount_seq += 1
    label.new(bar_index, low - tpLabelATR * tpLabelDistanceATR, text = "TP" + str.tostring(tpBearCount_seq), color = color.new(color.black, 100), textcolor = color.white, size = size.small, style = label.style_label_up)

plotshape(bullSweep_TS, title = "Liq Sweep Bull", style = shape.xcross, location = location.belowbar, color = color.new(#00bcd4, 0), size = size.tiny)
plotshape(bearSweep_TS, title = "Liq Sweep Bear", style = shape.xcross, location = location.abovebar, color = color.new(#ff9800, 0), size = size.tiny)

// === SWEEP LINES ===
if showSweepLines_TS and bullSweep_TS and not na(lastSLSweepTS)
    line.new(lastSLBarSweepTS, lastSLSweepTS, bar_index + 15, lastSLSweepTS, color=color.new(#00bcd4, 0), width=1, style=line.style_dotted)
if showSweepLines_TS and bearSweep_TS and not na(lastSHSweepTS)
    line.new(lastSHBarSweepTS, lastSHSweepTS, bar_index + 15, lastSHSweepTS, color=color.new(#ff9800, 0), width=1, style=line.style_dotted)

// === TP LINES ===
if tpBullSignal or tpBearSignal
    tpLine = line.new(x1=bar_index, y1=close, x2=bar_index + tpLineExtension, y2=close, xloc=xloc.bar_index, extend=extend.none, color=tpLineColor, width=1, style=line.style_solid)
    array.push(activeTPLines, TPLine.new(tpLine, close, bar_index))
    if array.size(activeTPLines) > 500
        oldTPLine = array.shift(activeTPLines)
        line.delete(oldTPLine.tp_line)

// === VOLUME LABELS ===
manageLabelArray() =>
    if array.size(volumeLabels) >= maxLabels
        oldestLabel = array.shift(volumeLabels)
        label.delete(oldestLabel)

if upSignal
    manageLabelArray()
    labelTextColor = if volumeScaled >= 7 and volumeScaled <= 10 and isOpenNearVWAP()
        color.rgb(10, 252, 2)
    else if volumeScaled >= 9
        color.rgb(243, 113, 6)
    else
        color.rgb(255, 255, 255)
    newLabel = label.new(bar_index, low - (high - low) * 0.1, text = str.tostring(volumeScaled), color = color.new(#10d4db, 100), textcolor = labelTextColor, size = size.small, style = label.style_label_up)
    array.push(volumeLabels, newLabel)

if downSignal
    manageLabelArray()
    labelTextColor = if volumeScaled >= 7 and volumeScaled <= 10 and isOpenNearVWAP()
        color.rgb(10, 252, 2)
    else if volumeScaled >= 9
        color.rgb(243, 113, 6)
    else
        color.rgb(255, 255, 255)
    newLabel = label.new(bar_index, high + (high - low) * 0.1, text = str.tostring(volumeScaled), color = color.new(#ff5252, 100), textcolor = labelTextColor, size = size.small, style = label.style_label_down)
    array.push(volumeLabels, newLabel)

// === VOLUME STRENGTH 1-10 - CALCOLO ED ETICHETTE (NON TOCCA LA LOGICA DEI TRIANGOLI) ===
vsVolumeMA     = ta.sma(volume, vsVolumeMAPeriod)
vsVolumeRatio  = volume / vsVolumeMA
vsVolumeScaled = math.max(1, math.min(10, math.round(vsVolumeRatio * 5)))

vsEmaFilterValue = vsUseMasterEMA750 ? ema750 : ta.ema(close, vsEmaFilterPeriod)

vsPassesEMADirection(bool isBull) =>
    if not vsEnableEMAFilter
        true
    else
        isBull ? close > vsEmaFilterValue : close < vsEmaFilterValue

vsLabelSz() =>
    vsLabelSize == "tiny" ? size.tiny : vsLabelSize == "small" ? size.small : vsLabelSize == "normal" ? size.normal : vsLabelSize == "large" ? size.large : size.huge

vsStrengthColor = vsColorByStrength ? (vsVolumeScaled >= 8 ? vsHighColor : vsVolumeScaled >= 6 ? vsMidColor : vsLowColor) : color.white

vsPassesVolumeFilter(vol) =>
    if not vsEnableVolumeFilter
        true
    else
        if vsVolumeFilterMode == "Singolo"
            vol == vsVolumeFilterSingle
        else
            vol >= vsVolumeFilterMin and vol <= vsVolumeFilterMax

vsPassesATRMode(bool isBull) =>
    not enableATRMode or (isBull ? close <= upperBand : close >= lowerBand)

vsManageLabelArray() =>
    if array.size(vsVolLabels) >= vsMaxLabels
        vsOldest = array.shift(vsVolLabels)
        label.delete(vsOldest)

vsIsBull       = close >= open
vsOnSignalBar  = upSignal or downSignal
vsShowThisBar  = showVolStrengthLabels and not (vsHideOnSignalBars and vsOnSignalBar) and vsPassesVolumeFilter(vsVolumeScaled) and vsPassesEMADirection(vsIsBull) and isInTimeRange() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesVolScoreFilter() and vsPassesATRMode(vsIsBull) and passesMTCandleMasterFilter(vsIsBull) and passesSTMasterFilter(vsIsBull)

if vsShowThisBar
    vsManageLabelArray()
    vsLbl = label.new(
         bar_index,
         vsIsBull ? low - (high - low) * vsLabelOffset : high + (high - low) * vsLabelOffset,
         text = str.tostring(vsVolumeScaled),
         style = vsIsBull ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = vsStrengthColor,
         size = vsLabelSz())
    array.push(vsVolLabels, vsLbl)

vsCandleSymbol = vsIsBull ? '▲ Bullish Candle Close' : '▼ Bearish Candle Close'

alertcondition(vsShowThisBar and enableVolStrengthAlert, title = 'Volume Strength 1-10 🔢', message = 'VOLUME STRENGTH')
if vsShowThisBar and enableVolStrengthAlert
    alert('VOLUME STRENGTH: ' + str.tostring(vsVolumeScaled) + ' ' + vsCandleSymbol + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

if upSignal   and enableUpTriangleAlert
    alert('▲ BUY - VOL: ' + str.tostring(volumeScaled) + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if downSignal and enableDownTriangleAlert
    alert('▼ SELL - VOL: ' + str.tostring(volumeScaled) + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(bull_rejection_ob and enableBullOBRejectionAlert, title = 'Bullish OB Rejection 🟩', message = '🟩 BULLISH ORDER BLOCK REJECTION')
alertcondition(bear_rejection_ob and enableBearOBRejectionAlert, title = 'Bearish OB Rejection 🟥', message = '🟥 BEARISH ORDER BLOCK REJECTION')
if bull_rejection_ob and enableBullOBRejectionAlert
    alert('BULLISH ORDER BLOCK REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bear_rejection_ob and enableBearOBRejectionAlert
    alert('BEARISH ORDER BLOCK REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(tpBullSignal and enableTPBullAlert, title = 'Take Profit Bullish 🎯', message = '🎯 TAKE PROFIT BULLISH SIGNAL')
alertcondition(tpBearSignal and enableTPBearAlert, title = 'Take Profit Bearish 🎯', message = '🎯 TAKE PROFIT BEARISH SIGNAL')
if tpBullSignal and enableTPBullAlert
    tpBullAnomalyTxt = tpBullAnomaly ? ' (below EMA750) ▼' : ''
    alert('🎯 TAKE PROFIT ' + str.tostring(tpBullCount_seq) + ' BULLISH' + tpBullAnomalyTxt + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if tpBearSignal and enableTPBearAlert
    tpBearAnomalyTxt = tpBearAnomaly ? ' (above EMA750) ▲' : ''
    alert('🎯 TAKE PROFIT ' + str.tostring(tpBearCount_seq) + ' BEARISH' + tpBearAnomalyTxt + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// === MASTER TREND ===
ema4CrossAbove5 = ta.crossover(ema4, ema5)
ema4CrossBelow5 = ta.crossunder(ema4, ema5)

ema89BullBreakout         = ta.crossover(close, ema89ForTable)
ema89BearBreakout         = ta.crossunder(close, ema89ForTable)
ema89BullBreakoutFiltered = ema89BullBreakout and isInTimeRange()
ema89BearBreakoutFiltered = ema89BearBreakout and isInTimeRange()

isBullishCandleForMasterTrend = stoK > 52 or ema89BullBreakoutFiltered or (isOrange and isBullValid)
isBearishCandleForMasterTrend = stoK < 48 or ema89BearBreakoutFiltered or (isOrange and isBearValid)

masterTrendBullSignal = showMasterTrend and ema4CrossAbove5 and rsiMT > 50 and close > ema21 and close > sma50 and close > ema55 and close > ema89ForTable and close > ema750 and (not enableATRMode or close <= upperBand) and isBullishCandleForMasterTrend and isInTimeRange() and (not enableVWAPFilter or close > vwap) and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
masterTrendBearSignal = showMasterTrend and ema4CrossBelow5 and rsiMT < 50 and close < ema21 and close < sma50 and close < ema55 and close < ema89ForTable and close < ema750 and (not enableATRMode or close >= lowerBand) and isBearishCandleForMasterTrend and isInTimeRange() and (not enableVWAPFilter or close < vwap) and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesVolScoreFilter() and passesSweepMasterFilter() and passesBPRMasterFilter() and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)


masterTrendBullColorDynamic = (isOrange and isBullValid) ? masterTrendEngulfBullColor : masterTrendBullColor
masterTrendBearColorDynamic = (isOrange and isBearValid) ? masterTrendEngulfBearColor : masterTrendBearColor

plotshape(masterTrendBullSignal, title = 'Master Trend Bull', location = location.belowbar, color = masterTrendBullColorDynamic, style = shape.triangleup,   size = size.small)
plotshape(masterTrendBearSignal, title = 'Master Trend Bear', location = location.abovebar, color = masterTrendBearColorDynamic, style = shape.triangledown, size = size.small)

if masterTrendBullSignal or masterTrendBearSignal
    lineStyle  = masterTrendLineStyle == "Solid" ? line.style_solid : masterTrendLineStyle == "Dashed" ? line.style_dashed : line.style_dotted
    masterLine = line.new(x1=bar_index, y1=open, x2=bar_index + masterTrendLineExtension, y2=open, xloc=xloc.bar_index, extend=extend.none, color=masterTrendLineColor, width=1, style=lineStyle)
    array.push(activeMasterTrendLines, MasterTrendLine.new(masterLine, open, bar_index, false))
    if array.size(activeMasterTrendLines) > 500
        oldMTLine = array.shift(activeMasterTrendLines)
        line.delete(oldMTLine.trend_line)

    // === MT HOURLY STATS: registra trade ipotetico RR 1:1 (TP/SL = range candela segnale incl. ombre) ===
    mtCandleRange = high - low
    mtEntry       = close
    mtTP          = masterTrendBullSignal ? mtEntry + mtCandleRange : mtEntry - mtCandleRange
    mtSL          = masterTrendBullSignal ? mtEntry - mtCandleRange : mtEntry + mtCandleRange
    mtHourBucket  = int(hour(time, getTimezoneString()) / mtHourWindowSize)
    array.push(activeMTHourTrades, MTHourTrade.new(mtTP, mtSL, masterTrendBullSignal, mtHourBucket, bar_index))

bool masterTrendBullRejection = false
bool masterTrendBearRejection = false

if showMasterTrendRejection and isInTimeRange() and array.size(activeMasterTrendLines) > 0
    for i = array.size(activeMasterTrendLines) - 1 to 0
        mtLine       = array.get(activeMasterTrendLines, i)
        linePrice    = mtLine.price_level
        lineStartBar = mtLine.start_bar
        if bar_index > lineStartBar and bar_index <= (lineStartBar + masterTrendLineExtension)
            if low <= linePrice and open > linePrice and close > linePrice and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesSTMasterFilter(true)
                masterTrendBullRejection := true
                break
            if high >= linePrice and open < linePrice and close < linePrice and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesSTMasterFilter(false)
                masterTrendBearRejection := true
                break

if masterTrendBullRejection
    label.new(bar_index, low  - (high - low) * 0.01, text = "R", color = color.new(color.green, 100), textcolor = color.green, size = size.normal, style = label.style_label_up)
if masterTrendBearRejection
    label.new(bar_index, high + (high - low) * 0.01, text = "R", color = color.new(color.red,   100), textcolor = color.red,   size = size.normal, style = label.style_label_down)

// === MASTER TREND HOURLY STATS PROCESSING ===
if array.size(activeMTHourTrades) > 0
    for i = array.size(activeMTHourTrades) - 1 to 0
        mt = array.get(activeMTHourTrades, i)
        if bar_index > mt.signalBar
            mtTpHit = mt.isBull ? high >= mt.tpLevel : low  <= mt.tpLevel
            mtSlHit = mt.isBull ? low  <= mt.slLevel : high >= mt.slLevel
            if mtTpHit or mtSlHit
                // se TP e SL vengono toccati nella stessa barra, viene considerato conservativamente come perdita
                mtWin = mtTpHit and not mtSlHit
                mtHourTotal.set(mt.hourBucket, mtHourTotal.get(mt.hourBucket) + 1)
                if mtWin
                    mtHourWins.set(mt.hourBucket, mtHourWins.get(mt.hourBucket) + 1)
                array.remove(activeMTHourTrades, i)

// === BAR COLORS ===
var color candleColor = na
if stoK > 52
    candleColor := color.rgb(0, 233, 250, 50)
else if stoK < 48
    candleColor := color.rgb(255, 82, 82, 50)
else if stoK > 47 and stoK < 53
    candleColor := color.yellow
else
    candleColor := na

kCandleColorFinal  = isBullValid ? kCandleBullColor : kCandleBearColor
isOrangeFiltered   = isOrange and passesSweepMasterFilter() and passesBPRMasterFilter() and (not enableVWAPFilter or (isBullValid ? close > vwap : close < vwap)) and (not enableEMA750MasterFilter or (isBullValid ? close > ema750 : close < ema750)) and (not enableButterworthMasterFilter or (isBullValid ? close > bf : close < bf)) and passesSTMasterFilter(isBullValid)
mtBarColorFinal    = mtTableAllBull ? mtBarColorBull : mtTableAllBear ? mtBarColorBear : mtBarColorNeutral
vwapBreakActive    = showVWAPPurpleCandles and (vwapCloseBull or vwapCloseBear)
vwapBreakColorFinal = vwapCloseBull ? vwapPurpleBullColor : vwapPurpleBearColor

barcolor(
     (isOrangeFiltered and showKCandleBarcolor) ? kCandleColorFinal :
     vwapBreakActive                            ? vwapBreakColorFinal :
     enableMTBarColor                           ? mtBarColorFinal :
     candleColor)

// === TIME FILTER BACKGROUNDS ===
timeFilter1Active = enableTimeFilter  and not na(time(timeframe.period, timeFilter1Session, getTimezoneString()))
timeFilter2Active = enableTimeFilter2 and not na(time(timeframe.period, timeFilter2Session, getTimezoneString()))
timeFilter3Active = enableTimeFilter3 and not na(time(timeframe.period, timeFilter3Session, getTimezoneString()))
bgcolor(showTimeFilter1Background and timeFilter1Active ? timeFilter1BgColor : showTimeFilter2Background and timeFilter2Active ? timeFilter2BgColor : showTimeFilter3Background and timeFilter3Active ? timeFilter3BgColor : na, title = "Time Filter Background")

// === SESSIONS LOGIC ===
var SessionLiveState tokyoState   = SessionLiveState.new(na, na, na, na, na, na, na)
var SessionLiveState londonState  = SessionLiveState.new(na, na, na, na, na, na, na)
var SessionLiveState newYorkState = SessionLiveState.new(na, na, na, na, na, na, na)

isIntradayTimeframe = timeframe.in_seconds() <= 3600

// ── Intrabar a 1 minuto: su M3..H1 high/low della sessione vengono ricostruiti dalle candele da 1 minuto
//    comprese nella finestra, così il box è identico a quello visto in M1 (su M1 e sotto resta la logica barra per barra).
//    Oltre il limite di intrabar disponibili da TradingView si ricade sul high/low della barra del grafico.
useSessionLtf = isIntradayTimeframe and timeframe.in_seconds() > 60
sessionLtfTf  = useSessionLtf ? "1" : timeframe.period
[sessLtfTimes, sessLtfHighs, sessLtfLows] = request.security_lower_tf(syminfo.tickerid, sessionLtfTf, [time, high, low], ignore_invalid_timeframe = true)

maxNa(float a, float b) =>
    na(a) ? b : na(b) ? a : math.max(a, b)

minNa(float a, float b) =>
    na(a) ? b : na(b) ? a : math.min(a, b)

// La barra del grafico appartiene alla sessione se si sovrappone alla finestra (non solo se la sua apertura cade dentro)
sessionOverlapsBar(string sessStr) =>
    tz       = getTimezoneString()
    startMin = int(str.tonumber(str.substring(sessStr, 0, 2))) * 60 + int(str.tonumber(str.substring(sessStr, 2, 4)))
    endMin   = int(str.tonumber(str.substring(sessStr, 5, 7))) * 60 + int(str.tonumber(str.substring(sessStr, 7, 9)))
    barMin   = hour(time, tz) * 60 + minute(time, tz)
    barDur   = int(timeframe.in_seconds() / 60)
    startInWin    = startMin < endMin ? (barMin >= startMin and barMin < endMin) : (barMin >= startMin or barMin < endMin)
    winStartInBar = ((startMin - barMin + 1440) % 1440) < barDur
    startInWin or winStartInBar

// High/low della sessione per la barra corrente: dalle sole candele da 1 minuto dentro la finestra.
// Se i dati intrabar non sono disponibili ritorna high/low della barra; se sono disponibili ma nessun minuto è
// dentro la finestra ritorna na (la barra non aggiorna il box).
sessionBarHL(string sessStr, bool active) =>
    float hi = high
    float lo = low
    if active and useSessionLtf and not na(sessLtfTimes)
        if array.size(sessLtfTimes) > 0
            tz       = getTimezoneString()
            startMin = int(str.tonumber(str.substring(sessStr, 0, 2))) * 60 + int(str.tonumber(str.substring(sessStr, 2, 4)))
            endMin   = int(str.tonumber(str.substring(sessStr, 5, 7))) * 60 + int(str.tonumber(str.substring(sessStr, 7, 9)))
            hi := na
            lo := na
            for k = 0 to array.size(sessLtfTimes) - 1
                tt  = array.get(sessLtfTimes, k)
                m   = hour(tt, tz) * 60 + minute(tt, tz)
                inW = startMin < endMin ? (m >= startMin and m < endMin) : (m >= startMin or m < endMin)
                if inW
                    hi := maxNa(hi, array.get(sessLtfHighs, k))
                    lo := minNa(lo, array.get(sessLtfLows, k))
    [hi, lo]

tokyoSession  = isIntradayTimeframe and (useSessionLtf ? sessionOverlapsBar(tokyoSessionTime)   : not na(time(timeframe.period, tokyoSessionTime,   getTimezoneString())))
londonSession = isIntradayTimeframe and (useSessionLtf ? sessionOverlapsBar(londonSessionTime)  : not na(time(timeframe.period, londonSessionTime,  getTimezoneString())))
nySession     = isIntradayTimeframe and (useSessionLtf ? sessionOverlapsBar(newYorkSessionTime) : not na(time(timeframe.period, newYorkSessionTime, getTimezoneString())))

var int tokyoExtensionBars   = 1
var int londonExtensionBars  = 1
var int newYorkExtensionBars = 1

tf_sec = timeframe.in_seconds()
tokyoExtensionBars   := tf_sec > 0 ? math.round(tokyoExtensionLength   * 60 / tf_sec) : 1
londonExtensionBars  := tf_sec > 0 ? math.round(londonExtensionLength  * 60 / tf_sec) : 1
newYorkExtensionBars := tf_sec > 0 ? math.round(newYorkExtensionLength * 60 / tf_sec) : 1

// Minuti mancanti al termine della sessione. Se la barra chiude entro la sessione si usa la chiusura barra;
// se la barra supera la fine della sessione (es. M30/H1) si usa l'ora corrente.
sessionMinutesLeft(string sessionStr) =>
    tz       = getTimezoneString()
    startMin = int(str.tonumber(str.substring(sessionStr, 0, 2))) * 60 + int(str.tonumber(str.substring(sessionStr, 2, 4)))
    endMin   = int(str.tonumber(str.substring(sessionStr, 5, 7))) * 60 + int(str.tonumber(str.substring(sessionStr, 7, 9)))
    durRaw   = (endMin - startMin + 1440) % 1440
    dur      = durRaw == 0 ? 1440 : durRaw
    closeMin = hour(time_close, tz) * 60 + minute(time_close, tz)
    nowMin   = hour(timenow, tz) * 60 + minute(timenow, tz)
    remClose = (endMin - closeMin + 1440) % 1440
    remNow   = (endMin - nowMin + 1440) % 1440
    remClose <= dur ? remClose : (remNow <= dur ? remNow : 0)

// Funzione unica che gestisce formazione live + box/linee definitive per una sessione qualsiasi
// (elimina la tripla duplicazione Tokyo/London/New York, principale causa del superamento
// del limite di compilazione del main body)
updateSessionLive(SessionLiveState s, bool sessionActive, color sessionColor, color lineColor, bool showLabel, string labelText, string sessionTimeStr, int extensionBars) =>
    [bH, bL] = sessionBarHL(sessionTimeStr, sessionActive)
    if sessionActive and not sessionActive[1]
        s.startTime   := bar_index
        s.sessionLow  := bL
        s.sessionHigh := bH
        if not na(s.liveBox)
            box.delete(s.liveBox)
        if not na(s.liveLabel)
            label.delete(s.liveLabel)
        if not na(s.liveHighLine)
            line.delete(s.liveHighLine)
        if not na(s.liveLowLine)
            line.delete(s.liveLowLine)
        topY = nz(bH, high)
        botY = nz(bL, low)
        s.liveBox      := box.new(bar_index, topY, bar_index + 1, botY, border_color=color.new(sessionColor, 0), bgcolor=sessionColor)
        s.liveLabel    := showLabel ? label.new(bar_index, topY, text = labelText, style = label.style_label_down, color = color.new(lineColor, 100), textcolor = lineColor, size = size.small) : na
        s.liveHighLine := line.new(bar_index, topY, bar_index + 1, topY, color=lineColor, style=line.style_dashed)
        s.liveLowLine  := line.new(bar_index, botY, bar_index + 1, botY, color=lineColor, style=line.style_dashed)
    if sessionActive
        s.sessionLow  := minNa(s.sessionLow,  bL)
        s.sessionHigh := maxNa(s.sessionHigh, bH)
        if not na(s.sessionHigh) and not na(s.sessionLow)
            if not na(s.liveBox)
                box.set_right (s.liveBox, bar_index + 1)
                box.set_top   (s.liveBox, s.sessionHigh)
                box.set_bottom(s.liveBox, s.sessionLow)
            if not na(s.liveLabel)
                minLeft = sessionMinutesLeft(sessionTimeStr)
                label.set_xy  (s.liveLabel, bar_index, s.sessionHigh)
                label.set_text(s.liveLabel, labelText + "  " + str.tostring(minLeft) + " min to complete")
            if not na(s.liveHighLine)
                line.set_xy1(s.liveHighLine, s.startTime, s.sessionHigh)
                line.set_xy2(s.liveHighLine, bar_index + extensionBars, s.sessionHigh)
            if not na(s.liveLowLine)
                line.set_xy1(s.liveLowLine, s.startTime, s.sessionLow)
                line.set_xy2(s.liveLowLine, bar_index + extensionBars, s.sessionLow)
    if sessionActive[1] and not sessionActive
        if not na(s.liveBox)
            box.delete(s.liveBox)
            s.liveBox := na
        if not na(s.liveLabel)
            label.delete(s.liveLabel)
            s.liveLabel := na
        if not na(s.liveHighLine)
            line.delete(s.liveHighLine)
            s.liveHighLine := na
        if not na(s.liveLowLine)
            line.delete(s.liveLowLine)
            s.liveLowLine := na
        if not na(s.startTime) and not na(s.sessionHigh) and not na(s.sessionLow)
            box.new(s.startTime, s.sessionHigh, bar_index, s.sessionLow, border_color=color.new(sessionColor, 0), bgcolor=sessionColor)
            line.new(s.startTime, s.sessionHigh, s.startTime + extensionBars, s.sessionHigh, color=lineColor)
            line.new(s.startTime, s.sessionLow,  s.startTime + extensionBars, s.sessionLow,  color=lineColor)
            line.new((s.startTime + bar_index) / 2, (s.sessionHigh + s.sessionLow) / 2, s.startTime + extensionBars, (s.sessionHigh + s.sessionLow) / 2, color=color.new(lineColor, 50), style=line.style_dashed)
            if showLabel
                label.new(s.startTime, s.sessionHigh, text=labelText, style=label.style_label_down, color=color.new(lineColor, 100), textcolor=lineColor, size=size.small)
            sessionMidPrice = (s.sessionHigh + s.sessionLow) / 2
            array.push(activeSessionLines, SessionLine.new(s.sessionHigh, s.sessionLow, sessionMidPrice, s.startTime, s.startTime + extensionBars, false, false))
        s.startTime   := na
        s.sessionLow  := na
        s.sessionHigh := na

if showTokyoSession
    updateSessionLive(tokyoState, tokyoSession, tokyoSessionColor, tokyoSessionLineColor, showTokyoSessionLabel, "TOKYO", tokyoSessionTime, tokyoExtensionBars)
if showLondonSession
    updateSessionLive(londonState, londonSession, londonSessionColor, londonSessionLineColor, showLondonSessionLabel, "LONDON", londonSessionTime, londonExtensionBars)
if showNewYorkSession
    updateSessionLive(newYorkState, nySession, newYorkSessionColor, newYorkSessionLineColor, showNewYorkSessionLabel, "NEW YORK", newYorkSessionTime, newYorkExtensionBars)


// === SESSION EXTERNAL REJECTION ===
bool sessionBullishER = false
bool sessionBearishER = false

if showSessionExternalRejection and isInTimeRange() and array.size(activeSessionLines) > 0
    for i = array.size(activeSessionLines) - 1 to 0
        sessionLine  = array.get(activeSessionLines, i)
        sessionHigh  = sessionLine.high_price
        sessionLow   = sessionLine.low_price
        sessionStart = sessionLine.start_bar
        sessionEnd   = sessionLine.end_bar
        if bar_index > sessionStart and bar_index <= sessionEnd
            if not sessionLine.high_broken and close > sessionHigh
                sessionLine.high_broken := true
            if not sessionLine.low_broken  and close < sessionLow
                sessionLine.low_broken  := true
            candleBodyBottom = math.min(open, close)
            candleBodyTop    = math.max(open, close)
            if sessionLine.high_broken and low <= sessionHigh and candleBodyBottom > sessionHigh and high > candleBodyBottom and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesVolScoreFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
                sessionBullishER := true
                break
            if sessionLine.low_broken  and high >= sessionLow  and candleBodyTop < sessionLow   and low < candleBodyTop   and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesVolScoreFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
                sessionBearishER := true
                break

if sessionBullishER
    label.new(bar_index, low  - (high - low) * 0.01, text = "⚡", color = color.new(color.green, 100), textcolor = color.green, size = size.normal, style = label.style_label_up)
if sessionBearishER
    label.new(bar_index, high + (high - low) * 0.01, text = "⚡", color = color.new(color.red,   100), textcolor = color.red,   size = size.normal, style = label.style_label_down)

// === SESSION MIDLINE REJECTION ===
bool sessionMidlineBullRejection = false
bool sessionMidlineBearRejection = false

if showSessionMidlineRejection and isInTimeRange() and array.size(activeSessionLines) > 0
    maxIdx = array.size(activeSessionLines) - 1
    for idx = 0 to maxIdx
        i           = maxIdx - idx
        sessionLine = array.get(activeSessionLines, i)
        sessionMid  = sessionLine.mid_price
        sessionStart = sessionLine.start_bar
        sessionEnd   = sessionLine.end_bar
        if bar_index > sessionStart and bar_index <= sessionEnd
            candleBodyTop    = math.max(open, close)
            candleBodyBottom = math.min(open, close)
            if candleBodyBottom > sessionMid and low <= sessionMid and low < candleBodyBottom and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesVolScoreFilter() and (not enableATRMode or close <= upperBand) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
                sessionMidlineBullRejection := true
                break
            if candleBodyTop < sessionMid and high >= sessionMid and high > candleBodyTop and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesSweepMasterFilter() and passesBPRMasterFilter() and passesVolScoreFilter() and (not enableATRMode or close >= lowerBand) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
                sessionMidlineBearRejection := true
                break

if sessionMidlineBullRejection
    candleRange = math.max(high - low, syminfo.mintick)
    label.new(bar_index, low  - candleRange * 0.01, text = "M", color = color.new(color.orange, 100), textcolor = color.orange, size = size.normal, style = label.style_label_up)
if sessionMidlineBearRejection
    candleRange = math.max(high - low, syminfo.mintick)
    label.new(bar_index, high + candleRange * 0.01, text = "M", color = color.new(color.orange, 100), textcolor = color.orange, size = size.normal, style = label.style_label_down)

// === EMA750 REJECTION ===
bool ema750BullRejection = false
bool ema750BearRejection = false

if showEMA750Rejection and isInTimeRange()
    if close > open and low <= ema750 and math.min(open, close) > ema750 and (not enableEMA750MasterFilter or close > ema750) and (not enableButterworthMasterFilter or close > bf) and passesBPRMasterFilter() and passesSweepMasterFilter() and passesVolScoreFilter() and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
        ema750BullRejection := true
    if close < open and high >= ema750 and math.max(open, close) < ema750 and (not enableEMA750MasterFilter or close < ema750) and (not enableButterworthMasterFilter or close < bf) and passesBPRMasterFilter() and passesSweepMasterFilter() and passesVolScoreFilter() and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)
        ema750BearRejection := true

if ema750BullRejection
    label.new(bar_index, low  - (high - low) * 0.01, text = "R", color = color.new(color.white, 100), textcolor = color.white, size = size.normal, style = label.style_label_up)
if ema750BearRejection
    label.new(bar_index, high + (high - low) * 0.01, text = "R", color = color.new(color.red,   100), textcolor = color.white, size = size.normal, style = label.style_label_down)

// ══════════════════════════════════════════════════════════════
// APRI NUOVI TRADE SWEEP
// ══════════════════════════════════════════════════════════════
// Trade aperti che seguono la strategia: esclusi quelli Off-Filter (fuori dai Time Filter)
countInSessionTrades() =>
    int c = 0
    if array.size(activeSweepTrades) > 0
        for k = 0 to array.size(activeSweepTrades) - 1
            if array.get(activeSweepTrades, k).session != "Off-Filter"
                c += 1
    c

[mtTouchBull, mtTouchBear, mtTouchBullPrice, mtTouchBearPrice] = checkMTLineFirstTouch()
[stFlipBull, stFlipBear] = checkSuperTrendFlip()

sw_entryBull = entrySignalModeSW == "Master Trend Signals"      ? masterTrendBullSignal :
               entrySignalModeSW == "MT Line Rejection"         ? masterTrendBullRejection :
               entrySignalModeSW == "MT Line First Touch"       ? mtTouchBull :
               entrySignalModeSW == "Order Block Rejection"     ? bull_rejection_ob :
               entrySignalModeSW == "VIDYA Rejection"           ? vidyaBullRejection :
               entrySignalModeSW == "Butterworth Rejection"     ? bfBullRejection :
               entrySignalModeSW == "Session External Rejection" ? sessionBullishER :
               entrySignalModeSW == "Session Midline Rejection"  ? sessionMidlineBullRejection :
               entrySignalModeSW == "EMA 750 Rejection"          ? ema750BullRejection :
               entrySignalModeSW == "Anomalous TP Signals"       ? tpBearAnomaly :
               entrySignalModeSW == "SuperTrend"                 ? stFlipBull :
               bullSweep_TS

sw_entryBear = entrySignalModeSW == "Master Trend Signals"      ? masterTrendBearSignal :
               entrySignalModeSW == "MT Line Rejection"         ? masterTrendBearRejection :
               entrySignalModeSW == "MT Line First Touch"       ? mtTouchBear :
               entrySignalModeSW == "Order Block Rejection"     ? bear_rejection_ob :
               entrySignalModeSW == "VIDYA Rejection"           ? vidyaBearRejection :
               entrySignalModeSW == "Butterworth Rejection"     ? bfBearRejection :
               entrySignalModeSW == "Session External Rejection" ? sessionBearishER :
               entrySignalModeSW == "Session Midline Rejection"  ? sessionMidlineBearRejection :
               entrySignalModeSW == "EMA 750 Rejection"          ? ema750BearRejection :
               entrySignalModeSW == "Anomalous TP Signals"       ? tpBullAnomaly :
               entrySignalModeSW == "SuperTrend"                 ? stFlipBear :
               bearSweep_TS

sw_openNowL = countInSessionTrades()
sw_canLong  = sw_openNowL == 0 or (overlapTrades_SW and sw_openNowL < overlapLimit_SW)

if showSweepRR and sw_entryBull and sw_canLong
    entry  = entrySignalModeSW == "MT Line First Touch" ? mtTouchBullPrice : close
    slDist = slModeSW == "Percent" ? entry * (stopLossPctSW / 100) :
             slModeSW == "Pips"    ? stopLossPipsSW * pipSize :
             math.max((entry - low), pipSize) + rrSlPips_SW * pipSize
    tpLvl  = useFixedRR_SW
             ? entry + slDist * rrRatio_SW
             : (not na(prevSHSweepTS) and prevSHSweepTS > entry ? prevSHSweepTS : entry + slDist * rrRatio_SW)
    tpBar  = not na(prevSHBarSweepTS) ? prevSHBarSweepTS : bar_index
    partialLvlL = entry + slDist * partialRRSW
    swOpenTrade(true, entry, entry - slDist, tpLvl, tpLvl, tpBar, sweepCurSession, array.size(activeSweepTrades), partialLvlL)

// ricalcolato dopo l'eventuale apertura del long, così il limite vale anche per la stessa barra
sw_openNowS = countInSessionTrades()
sw_canShort = sw_openNowS == 0 or (overlapTrades_SW and sw_openNowS < overlapLimit_SW)

if showSweepRR and sw_entryBear and sw_canShort
    entry  = entrySignalModeSW == "MT Line First Touch" ? mtTouchBearPrice : close
    slDist = slModeSW == "Percent" ? entry * (stopLossPctSW / 100) :
             slModeSW == "Pips"    ? stopLossPipsSW * pipSize :
             math.max((high - entry), pipSize) + rrSlPips_SW * pipSize
    tpLvl  = useFixedRR_SW
             ? entry - slDist * rrRatio_SW
             : (not na(prevSLSweepTS) and prevSLSweepTS < entry ? prevSLSweepTS : entry - slDist * rrRatio_SW)
    tpBar  = not na(prevSLBarSweepTS) ? prevSLBarSweepTS : bar_index
    partialLvlS = entry - slDist * partialRRSW
    swOpenTrade(false, entry, entry + slDist, tpLvl, tpLvl, tpBar, sweepCurSession, array.size(activeSweepTrades), partialLvlS)

swInSessionOpen = countInSessionTrades()
if swInSessionOpen > sw_maxConcurrentTrades
    sw_maxConcurrentTrades := swInSessionOpen

// === CLEAN OLD SESSION LINES ===
if array.size(activeSessionLines) > 0
    for i = array.size(activeSessionLines) - 1 to 0
        sessionLine = array.get(activeSessionLines, i)
        if bar_index > (sessionLine.end_bar + 10)
            array.remove(activeSessionLines, i)

// === KCANDLE ALERTS ===
kCandleBullSignalFiltered = isBullValid and showKCandleLines and isInTimeRange() and (not enableVWAPFilter or close > vwap) and passesMTCandleMasterFilter(true) and passesSTMasterFilter(true)
kCandleBearSignalFiltered = isBearValid and showKCandleLines and isInTimeRange() and (not enableVWAPFilter or close < vwap) and passesMTCandleMasterFilter(false) and passesSTMasterFilter(false)

alertcondition(kCandleBullSignalFiltered and enableKCandleBullAlert, title = 'KCandle Rialzista ⠾', message = 'KCANDLE BULLISH ENGULFING DETECTED ⠾')
alertcondition(kCandleBearSignalFiltered and enableKCandleBearAlert, title = 'KCandle Ribassista ⠻', message = 'KCANDLE BEARISH ENGULFING DETECTED ⠻')
if kCandleBullSignalFiltered and enableKCandleBullAlert
    alert('KCANDLE BULLISH ENGULFING DETECTED at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if kCandleBearSignalFiltered and enableKCandleBearAlert
    alert('KCANDLE BEARISH ENGULFING DETECTED at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(masterTrendBullSignal and enableMasterTrendBullAlert and isInTimeRange(), title = 'Master Trend Bullish △', message = 'MASTER TREND BULLISH SIGNAL △')
alertcondition(masterTrendBearSignal and enableMasterTrendBearAlert and isInTimeRange(), title = 'Master Trend Bearish ▽', message = 'MASTER TREND BEARISH SIGNAL ▽')
if masterTrendBullSignal and enableMasterTrendBullAlert and isInTimeRange()
    alert('MASTER TREND BULLISH SIGNAL at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if masterTrendBearSignal and enableMasterTrendBearAlert and isInTimeRange()
    alert('MASTER TREND BEARISH SIGNAL at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(masterTrendBullRejection and enableMasterTrendRejectionAlert and isInTimeRange(), title = 'Master Trend Bullish Rejection (Green "R")', message = 'MASTER TREND BULLISH REJECTION (Green "R")')
alertcondition(masterTrendBearRejection and enableMasterTrendRejectionAlert and isInTimeRange(), title = 'Master Trend Bearish Rejection (Red "R")',   message = 'MASTER TREND BEARISH REJECTION (Red "R")')
if masterTrendBullRejection and enableMasterTrendRejectionAlert and isInTimeRange()
    alert('MASTER TREND BULLISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if masterTrendBearRejection and enableMasterTrendRejectionAlert and isInTimeRange()
    alert('MASTER TREND BEARISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(sessionBullishER and enableSessionBullERAlert and isInTimeRange(), title = 'Session Bullish External Rejection ⚡', message = '⚡ SESSION BULLISH EXTERNAL REJECTION')
alertcondition(sessionBearishER and enableSessionBearERAlert and isInTimeRange(), title = 'Session Bearish External Rejection ⚡', message = '⚡ SESSION BEARISH EXTERNAL REJECTION')
if sessionBullishER and enableSessionBullERAlert and isInTimeRange()
    alert('SESSION BULLISH EXTERNAL REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if sessionBearishER and enableSessionBearERAlert and isInTimeRange()
    alert('SESSION BEARISH EXTERNAL REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(sessionMidlineBullRejection and enableSessionMidlineBullRejectionAlert and isInTimeRange(), title = 'Session Midline Bullish Rejection (Orange "M")', message = 'SESSION MIDLINE BULLISH REJECTION (Orange "M")')
alertcondition(sessionMidlineBearRejection and enableSessionMidlineBearRejectionAlert and isInTimeRange(), title = 'Session Midline Bearish Rejection (Orange "M")', message = 'SESSION MIDLINE BEARISH REJECTION (Orange "M")')
if sessionMidlineBullRejection and enableSessionMidlineBullRejectionAlert and isInTimeRange()
    alert('SESSION MIDLINE BULLISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if sessionMidlineBearRejection and enableSessionMidlineBearRejectionAlert and isInTimeRange()
    alert('SESSION MIDLINE BEARISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(ema750BullRejection and enableEMA750BullRejectionAlert and isInTimeRange(), title = 'EMA750 Bullish Rejection (White "R")', message = 'EMA750 BULLISH REJECTION (White "R")')
alertcondition(ema750BearRejection and enableEMA750BearRejectionAlert and isInTimeRange(), title = 'EMA750 Bearish Rejection (White "R")', message = 'EMA750 BEARISH REJECTION (White "R")')
if ema750BullRejection and enableEMA750BullRejectionAlert and isInTimeRange()
    alert('EMA750 BULLISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if ema750BearRejection and enableEMA750BearRejectionAlert and isInTimeRange()
    alert('EMA750 BEARISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(bfBullRejection and enableBFBullRejectionAlert and isInTimeRange(), title = 'Butterworth Bullish Rejection 🟡', message = '🟡 BUTTERWORTH BULLISH REJECTION')
alertcondition(bfBearRejection and enableBFBearRejectionAlert and isInTimeRange(), title = 'Butterworth Bearish Rejection 🟡', message = '🟡 BUTTERWORTH BEARISH REJECTION')
if bfBullRejection and enableBFBullRejectionAlert and isInTimeRange()
    alert('BUTTERWORTH BULLISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bfBearRejection and enableBFBearRejectionAlert and isInTimeRange()
    alert('BUTTERWORTH BEARISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(vidyaBullRejection and enableVidyaBullRejectionAlert and isInTimeRange(), title = 'VIDYA Bullish Rejection 🟢', message = '🟢 VIDYA BULLISH REJECTION')
alertcondition(vidyaBearRejection and enableVidyaBearRejectionAlert and isInTimeRange(), title = 'VIDYA Bearish Rejection 🔴', message = '🔴 VIDYA BEARISH REJECTION')
if vidyaBullRejection and enableVidyaBullRejectionAlert and isInTimeRange()
    alert('VIDYA BULLISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if vidyaBearRejection and enableVidyaBearRejectionAlert and isInTimeRange()
    alert('VIDYA BEARISH REJECTION at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(bullSweep_TS and enableBullSweepAlert_TS, title = 'Bullish Liquidity Sweep 🔵', message = '🔵 BULLISH LIQUIDITY SWEEP')
alertcondition(bearSweep_TS and enableBearSweepAlert_TS, title = 'Bearish Liquidity Sweep 🟠', message = '🟠 BEARISH LIQUIDITY SWEEP')
if bullSweep_TS and enableBullSweepAlert_TS
    alert('🔵 Bullish Liquidity Sweep at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bearSweep_TS and enableBearSweepAlert_TS
    alert('🟠 Bearish Liquidity Sweep at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

volScoreCandleSymbol = close >= open ? '▲ Bullish Candle Close' : '▼ Bearish Candle Close'
volScoreAlertMsg     = '📊 ATR VOLATILITY SCORE: ' + str.tostring(atrVolScore) + ' / 100 ' + volScoreCandleSymbol
alertcondition(atrVolScore >= volScoreMinThreshold and enableVolScoreAlert and isInTimeRange(), title = 'ATR Volatility Score Alert 📊', message = '📊 ATR VOLATILITY SCORE HIGH')
if atrVolScore >= volScoreMinThreshold and enableVolScoreAlert and isInTimeRange()
    alert(volScoreAlertMsg + ' at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

bprInTriggered  = bprBullIn or bprBearIn
bprOutTriggered = bprBullOut or bprBearOut

alertcondition(bprInTriggered  and enableBPRInAlert,  title = 'BPR In 📦',  message = '📦 BPR IN')
alertcondition(bprOutTriggered and enableBPROutAlert, title = 'BPR Out 📦', message = '📦 BPR OUT')
if bprInTriggered and enableBPRInAlert
    bprInMsg = bprBullIn ? '📦🟢 BULLISH BPR IN' : '📦🔴 BEARISH BPR IN'
    alert(bprInMsg + ' (TF ' + bprTimeframe + ') at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bprOutTriggered and enableBPROutAlert
    bprOutMsg = bprBullOut ? '📦🟢 BULLISH BPR OUT' : '📦🔴 BEARISH BPR OUT'
    alert(bprOutMsg + ' (TF ' + bprTimeframe + ') at ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════════════
// LAST SIGNAL TABLE (bottom-right)
// ══════════════════════════════════════════════════════════════
var string lastSig1 = "—"
var string lastSig2 = "—"
var string lastSig3 = "—"
var string lastSigTime1 = ""
var string lastSigTime2 = ""
var string lastSigTime3 = ""

if barstate.isconfirmed
    barTime = str.format_time(time, "HH:mm:ss", getTimezoneString())
    if masterTrendBullSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "▲ MASTER TREND BULLISH" , lastSigTime1 := barTime
    if masterTrendBearSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "▽ MASTER TREND BEARISH" , lastSigTime1 := barTime
    if tpBullSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🎯 TAKE PROFIT BULLISH" , lastSigTime1 := barTime
    if tpBearSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🎯 TAKE PROFIT BEARISH" , lastSigTime1 := barTime
    if upSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "▲ BUY  VOL:" + str.tostring(volumeScaled) , lastSigTime1 := barTime
    if downSignal
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "▼ SELL  VOL:" + str.tostring(volumeScaled) , lastSigTime1 := barTime
    if bull_rejection_ob
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟩 OB BULL REJECTION"   , lastSigTime1 := barTime
    if bear_rejection_ob
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟥 OB BEAR REJECTION"   , lastSigTime1 := barTime
    if masterTrendBullRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "R↑ MT BULL REJECTION"   , lastSigTime1 := barTime
    if masterTrendBearRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "R↓ MT BEAR REJECTION"   , lastSigTime1 := barTime
    if sessionBullishER
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "⚡ SESSION BULL EXT REJ" , lastSigTime1 := barTime
    if sessionBearishER
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "⚡ SESSION BEAR EXT REJ" , lastSigTime1 := barTime
    if sessionMidlineBullRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "M↑ SESSION MID BULL"    , lastSigTime1 := barTime
    if sessionMidlineBearRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "M↓ SESSION MID BEAR"    , lastSigTime1 := barTime
    if ema750BullRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "R↑ EMA750 BULL REJ"     , lastSigTime1 := barTime
    if ema750BearRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "R↓ EMA750 BEAR REJ"     , lastSigTime1 := barTime
    if bfBullRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟡 BF BULL REJECTION"   , lastSigTime1 := barTime
    if bfBearRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟡 BF BEAR REJECTION"   , lastSigTime1 := barTime
    if vidyaBullRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟢 VIDYA BULL REJ"      , lastSigTime1 := barTime
    if vidyaBearRejection
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🔴 VIDYA BEAR REJ"      , lastSigTime1 := barTime
    if bullSweep_TS
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🔵 BULL LIQ SWEEP"      , lastSigTime1 := barTime
    if bearSweep_TS
        lastSig3 := lastSig2          , lastSigTime3 := lastSigTime2
        lastSig2 := lastSig1          , lastSigTime2 := lastSigTime1
        lastSig1 := "🟠 BEAR LIQ SWEEP"      , lastSigTime1 := barTime

if showLastSigTable and barstate.islast and tableTextSize != ""
    lsTS = swTxtSize(lastSigTableTextSize)
    var table lastSigTable = table.new(position.bottom_right, 2, 4, border_width=0)
    table.cell(lastSigTable, 0, 0, "LAST SIGNAL", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=lsTS)
    table.cell(lastSigTable, 1, 0, "TIME",         text_color=color.rgb(180,180,180), bgcolor=color.new(color.black, 100), text_size=lsTS)
    sig1Color = str.contains(lastSig1, "BULL") or str.contains(lastSig1, "BUY") or str.contains(lastSig1, "▲") ? color.rgb(0, 230, 118) : str.contains(lastSig1, "BEAR") or str.contains(lastSig1, "SELL") or str.contains(lastSig1, "▽") or str.contains(lastSig1, "▼") ? color.rgb(255, 82, 82) : color.white
    table.cell(lastSigTable, 0, 1, lastSig1,      text_color=sig1Color,             bgcolor=color.new(color.black, 100), text_size=lsTS)
    table.cell(lastSigTable, 1, 1, lastSigTime1,  text_color=color.rgb(200,200,200), bgcolor=color.new(color.black, 100), text_size=lsTS)
    sig2Color = str.contains(lastSig2, "BULL") or str.contains(lastSig2, "BUY") or str.contains(lastSig2, "▲") ? color.rgb(0, 180, 90) : str.contains(lastSig2, "BEAR") or str.contains(lastSig2, "SELL") or str.contains(lastSig2, "▽") or str.contains(lastSig2, "▼") ? color.rgb(200, 60, 60) : color.rgb(160, 160, 160)
    table.cell(lastSigTable, 0, 2, lastSig2,      text_color=sig2Color,             bgcolor=color.new(color.black, 100), text_size=lsTS)
    table.cell(lastSigTable, 1, 2, lastSigTime2,  text_color=color.rgb(150,150,150), bgcolor=color.new(color.black, 100), text_size=lsTS)
    sig3Color = str.contains(lastSig3, "BULL") or str.contains(lastSig3, "BUY") or str.contains(lastSig3, "▲") ? color.rgb(0, 130, 65) : str.contains(lastSig3, "BEAR") or str.contains(lastSig3, "SELL") or str.contains(lastSig3, "▽") or str.contains(lastSig3, "▼") ? color.rgb(150, 40, 40) : color.rgb(110, 110, 110)
    table.cell(lastSigTable, 0, 3, lastSig3,      text_color=sig3Color,             bgcolor=color.new(color.black, 100), text_size=lsTS)
    table.cell(lastSigTable, 1, 3, lastSigTime3,  text_color=color.rgb(100,100,100), bgcolor=color.new(color.black, 100), text_size=lsTS)

// ══════════════════════════════════════════════════════════════
// SWEEP STATS TABLE (bottom-left)
// ══════════════════════════════════════════════════════════════
sw_wrStr(int wins, int tot) =>
    tot > 0 ? str.tostring(math.round((wins / tot) * 100.0, 1), "#.#") + "%" : "—"
sw_wrColor(int wins, int tot) =>
    tot == 0 ? color.rgb(150,150,150) : (wins / tot) >= 0.5 ? color.rgb(0,230,118) : color.rgb(255,70,70)

// ── sw_diffStr mostra pips + R ──
sw_diffStr(float wp, float lp, float wr, float lr) =>
    diffPips = wp - lp
    diffR    = wr - lr
    pipsTxt  = diffPips >= 0 ? "+" + str.tostring(diffPips, "#.#") : str.tostring(diffPips, "#.#")
    rTxt     = diffR    >= 0 ? "/+" + str.tostring(diffR,   "#.##") + "R" : "/" + str.tostring(diffR, "#.##") + "R"
    (wp > 0 or lp > 0) ? pipsTxt + " " + rTxt : "—"

sw_diffColor(float wp, float lp) =>
    (wp - lp) >= 0 ? color.rgb(0,230,118) : color.rgb(255,70,70)

sw_bestSession() =>
    scores = bestByPips_SW
         ? array.from(
             sw_tf1_t > 0 ? sw_tf1_wp - sw_tf1_lp : -999999.0,
             sw_tf2_t > 0 ? sw_tf2_wp - sw_tf2_lp : -999999.0,
             sw_tf3_t > 0 ? sw_tf3_wp - sw_tf3_lp : -999999.0)
         : array.from(
             (sw_tf1_t - sw_tf1_be) > 0 ? float(sw_tf1_w) / (sw_tf1_t - sw_tf1_be) : -1.0,
             (sw_tf2_t - sw_tf2_be) > 0 ? float(sw_tf2_w) / (sw_tf2_t - sw_tf2_be) : -1.0,
             (sw_tf3_t - sw_tf3_be) > 0 ? float(sw_tf3_w) / (sw_tf3_t - sw_tf3_be) : -1.0)
    best = array.indexof(scores, array.max(scores))
    best == 0 ? "TF1" : best == 1 ? "TF2" : "TF3"

drawSweepStatsTable() =>
    if showSweepTable and barstate.islast
        sw_wr      = (sw_totTrades - sw_totBE) > 0 ? (float(sw_totWins) / (sw_totTrades - sw_totBE)) * 100.0 : 0.0
        sw_totDiff = sw_totWinPips - sw_totLossPips
        sw_bSess   = sw_bestSession()
        nRows_sw   = showSweepSessStats ? 12 : 7
        hdr  = #121212 , dark = #1a1a1a , mid = #222222
        gold = color.rgb(255,215,0) , wht = color.white , grey = color.rgb(180,180,180)

        swTS = swTxtSize(sweepTableTextSize)

        var table swTable = table.new(position.bottom_left, 6, 15,
             border_width=1, border_color=color.rgb(255, 255, 255, 100),
             frame_width=1,  frame_color=color.rgb(255, 255, 255, 100))

        table.cell(swTable, 0, 0, str.upper(entrySignalModeSW) + " STATS 📊", text_color=wht, text_size=swTS, bgcolor=hdr)
        table.merge_cells(swTable, 0, 0, 5, 0)

        tpTxt_sw = useFixedRR_SW ? "RR: " + str.tostring(rrRatio_SW, "#.#") : "TP: swing (else " + str.tostring(rrRatio_SW, "#.#") + "R)"
        slTxt_sw = slModeSW == "Percent" ? "SL: " + str.tostring(stopLossPctSW, "#.##") + "%" : slModeSW == "Pips" ? "SL: " + str.tostring(stopLossPipsSW, "#.#") + " pips" : "SL buf: " + str.tostring(rrSlPips_SW, "#.#") + " pips"
        paramTxt = tpTxt_sw +
                   "  |  " + slTxt_sw +
                   "  |  BE: " + (enableBE_SW ? str.tostring(beRatio_SW, "#.#") + "R" : "OFF") +
                   "  |  TS: " + (enableTrailing_SW ? str.tostring(trailStartRR_SW, "#.#") + "R / " + str.tostring(trailStepPips_SW, "#.#") + " pips" : "OFF") +
                   (enablePartialSW ? "  |  Partial: " + str.tostring(partialRRSW, "#.#") + "R / " + str.tostring(partialPctSW, "#") + "%" : "") +
                   (overlapTrades_SW ? "  |  🔀" : "")
        table.cell(swTable, 0, 1, "⚙️  " + paramTxt, text_color=color.rgb(180,220,255), text_size=swTS, bgcolor=#1a2a3a)
        table.merge_cells(swTable, 0, 1, 5, 1)

        table.cell(swTable, 0, 2, "Session",   text_color=grey, text_size=swTS, bgcolor=#2a2a2a)
        table.cell(swTable, 1, 2, "Trades (W/L/BE)", text_color=grey, text_size=swTS, bgcolor=#2a2a2a)
        table.cell(swTable, 2, 2, "Win Rate",  text_color=grey, text_size=swTS, bgcolor=#2a2a2a)
        table.cell(swTable, 3, 2, "Win Pips",  text_color=grey, text_size=swTS, bgcolor=#2a2a2a)
        table.cell(swTable, 4, 2, "Loss Pips", text_color=grey, text_size=swTS, bgcolor=#2a2a2a)
        table.cell(swTable, 5, 2, "Diff / R",  text_color=grey, text_size=swTS, bgcolor=#2a2a2a)

        // Trade aperti fuori dai tre Time Filter: riga dedicata, esclusi dal TOTAL
        offT   = sw_off_t
        offRow = showSweepSessStats and offT > 0 ? 1 : 0

        if showSweepSessStats
            tf1Txt = str.substring(timeFilter1Session, 0, 2) + ":" + str.substring(timeFilter1Session, 2, 4) + "-" + str.substring(timeFilter1Session, 5, 7) + ":" + str.substring(timeFilter1Session, 7, 9)
            tf2Txt = str.substring(timeFilter2Session, 0, 2) + ":" + str.substring(timeFilter2Session, 2, 4) + "-" + str.substring(timeFilter2Session, 5, 7) + ":" + str.substring(timeFilter2Session, 7, 9)
            tf3Txt = str.substring(timeFilter3Session, 0, 2) + ":" + str.substring(timeFilter3Session, 2, 4) + "-" + str.substring(timeFilter3Session, 5, 7) + ":" + str.substring(timeFilter3Session, 7, 9)
            sess_arr = array.from("TF1 (" + tf1Txt + ")", "TF2 (" + tf2Txt + ")", "TF3 (" + tf3Txt + ")")
            t_arr    = array.from(sw_tf1_t,   sw_tf2_t,   sw_tf3_t)
            w_arr    = array.from(sw_tf1_w,   sw_tf2_w,   sw_tf3_w)
            be_arr   = array.from(sw_tf1_be,  sw_tf2_be,  sw_tf3_be)
            wp_arr   = array.from(sw_tf1_wp,  sw_tf2_wp,  sw_tf3_wp)
            lp_arr   = array.from(sw_tf1_lp,  sw_tf2_lp,  sw_tf3_lp)
            wr_arr   = array.from(sw_tf1_wr,  sw_tf2_wr,  sw_tf3_wr)
            lr_arr   = array.from(sw_tf1_lr,  sw_tf2_lr,  sw_tf3_lr)

            for r = 0 to 2
                sess   = array.get(sess_arr, r)
                tot    = array.get(t_arr,    r)
                wins   = array.get(w_arr,    r)
                beC    = array.get(be_arr,   r)
                wp     = array.get(wp_arr,   r)
                lp     = array.get(lp_arr,   r)
                wr     = array.get(wr_arr,   r)
                lr     = array.get(lr_arr,   r)
                totForWR = tot - beC
                isBest = sess == sw_bSess
                rowBg  = isBest ? #2a2200 : #1a1a1a
                txtC   = isBest ? gold    : color.rgb(200,200,200)

                table.cell(swTable, 0, r+3, sess,              text_color=txtC,                    text_size=swTS, bgcolor=rowBg)
                table.cell(swTable, 1, r+3, tot > 0 ? str.tostring(tot) + " (" + str.tostring(wins) + "/" + str.tostring(tot - wins - beC) + "/" + str.tostring(beC) + ")" : "0", text_color=wht, text_size=swTS, bgcolor=rowBg)
                table.cell(swTable, 2, r+3, sw_wrStr(wins,totForWR),text_color=sw_wrColor(wins,totForWR), text_size=swTS, bgcolor=rowBg)
                wpTxt  = tot > 0 ? str.tostring(wp,"#.#") + " /+" + str.tostring(wr,"#.##") + "R" : "—"
                lpTxt  = tot > 0 ? str.tostring(lp,"#.#") + " /-" + str.tostring(lr,"#.##") + "R" : "—"
                table.cell(swTable, 3, r+3, wpTxt, text_color=color.rgb(0,230,118), text_size=swTS, bgcolor=rowBg)
                table.cell(swTable, 4, r+3, lpTxt, text_color=color.rgb(255,70,70), text_size=swTS, bgcolor=rowBg)
                table.cell(swTable, 5, r+3, tot > 0 ? sw_diffStr(wp, lp, wr, lr) : "—", text_color=tot>0 ? sw_diffColor(wp,lp) : grey, text_size=swTS, bgcolor=rowBg)

            if offT > 0
                offW   = sw_off_w
                offBE  = sw_off_be
                offWp  = sw_off_wp
                offLp  = sw_off_lp
                offWr  = sw_off_wr
                offLr  = sw_off_lr
                offFWR = offT - offBE
                table.cell(swTable, 0, 6, "Off-Filter (no TOTAL)", text_color=color.rgb(200,200,200), text_size=swTS, bgcolor=#1a1a1a)
                table.cell(swTable, 1, 6, str.tostring(offT) + " (" + str.tostring(offW) + "/" + str.tostring(offT - offW - offBE) + "/" + str.tostring(offBE) + ")", text_color=wht, text_size=swTS, bgcolor=#1a1a1a)
                table.cell(swTable, 2, 6, sw_wrStr(offW, offFWR), text_color=sw_wrColor(offW, offFWR), text_size=swTS, bgcolor=#1a1a1a)
                table.cell(swTable, 3, 6, str.tostring(offWp, "#.#") + " /+" + str.tostring(offWr, "#.##") + "R", text_color=color.rgb(0,230,118), text_size=swTS, bgcolor=#1a1a1a)
                table.cell(swTable, 4, 6, str.tostring(offLp, "#.#") + " /-" + str.tostring(offLr, "#.##") + "R", text_color=color.rgb(255,70,70), text_size=swTS, bgcolor=#1a1a1a)
                table.cell(swTable, 5, 6, sw_diffStr(offWp, offLp, offWr, offLr), text_color=sw_diffColor(offWp, offLp), text_size=swTS, bgcolor=#1a1a1a)

            table.cell(swTable, 0, 6 + offRow, "⭐ Best: " + sw_bSess, text_color=gold, text_size=swTS, bgcolor=#1a1a00)
            table.merge_cells(swTable, 0, 6 + offRow, 5, 6 + offRow)

        totRow_sw = showSweepSessStats ? 7 + offRow : 3

        table.cell(swTable, 0, totRow_sw, "TOTAL",                    text_color=gold, text_size=swTS, bgcolor=dark)
        table.cell(swTable, 1, totRow_sw, sw_totTrades > 0 ? str.tostring(sw_totTrades) + " (" + str.tostring(sw_totWins) + "/" + str.tostring(sw_totTrades - sw_totWins - sw_totBE) + "/" + str.tostring(sw_totBE) + ")" : "0", text_color=wht, text_size=swTS, bgcolor=dark)
        table.cell(swTable, 2, totRow_sw, str.tostring(sw_wr,"#.##") + "%",
             text_color=sw_wr>=50 ? color.rgb(0,230,118) : color.rgb(255,70,70), text_size=swTS, bgcolor=dark)
        table.cell(swTable, 3, totRow_sw, str.tostring(sw_totWinPips, "#.#") + " /+" + str.tostring(sw_tot_wr,"#.##") + "R",  text_color=color.rgb(0,230,118), text_size=swTS, bgcolor=dark)
        table.cell(swTable, 4, totRow_sw, str.tostring(sw_totLossPips,"#.#") + " /-" + str.tostring(sw_tot_lr,"#.##") + "R",  text_color=color.rgb(255,70,70), text_size=swTS, bgcolor=dark)
        totDiffTxt = sw_totTrades > 0 ? sw_diffStr(sw_totWinPips, sw_totLossPips, sw_tot_wr, sw_tot_lr) : "—"
        table.cell(swTable, 5, totRow_sw, totDiffTxt,
             text_color=sw_totDiff>=0 ? color.rgb(0,230,118) : color.rgb(255,70,70), text_size=swTS, bgcolor=dark)

        row = totRow_sw + 1

        if enablePartialSW
            partialTxt_sw = "🎯 Partial Closes: " + str.tostring(sw_partial_t) +
                 " (Long: " + str.tostring(sw_partial_long_t) + " / Short: " + str.tostring(sw_partial_short_t) + ")" +
                 (sw_partial_t > 0 ? "  |  +" + str.tostring(sw_partial_wp, "#.#") + " pips / +" + str.tostring(sw_partial_wr, "#.##") + "R" : "")
            table.cell(swTable, 0, row, partialTxt_sw, text_color=color.rgb(180,220,255), text_size=swTS, bgcolor=#1a2a3a)
            table.merge_cells(swTable, 0, row, 5, row)
            row += 1

        if overlapTrades_SW
            mctTxt_sw = "🔺 Max Concurrent Trades: " + str.tostring(sw_maxConcurrentTrades)
            table.cell(swTable, 0, row, mctTxt_sw, text_color=color.rgb(180,220,255), text_size=swTS, bgcolor=#1a2a3a)
            table.merge_cells(swTable, 0, row, 5, row)
            row += 1

        streakTxt_sw = "🟢 Max Winning Streak: " + str.tostring(sw_maxWinStreak) +
             "  |  🔴 Max Losing Streak: " + str.tostring(sw_maxLossStreak)
        table.cell(swTable, 0, row, streakTxt_sw, text_color=color.rgb(180,220,255), text_size=swTS, bgcolor=#1a2a3a)
        table.merge_cells(swTable, 0, row, 5, row)
        row += 1

        if not useFixedRR_SW
            avgRR_sw    = sw_totWins > 0 ? sw_totRRSum / sw_totWins : 0.0
            avgRRTxt_sw = sw_totWins > 0 ? "Avg RR (wins): " + str.tostring(avgRR_sw,"#.##") + ":1" : "Avg RR (wins): —"
            table.cell(swTable, 0, row, avgRRTxt_sw,
                 text_color=avgRR_sw>=1.0 ? color.rgb(0,230,118) : color.rgb(255,70,70), text_size=swTS, bgcolor=dark)
            table.merge_cells(swTable, 0, row, 5, row)
            row += 1

        openCnt_sw  = countInSessionTrades()
        livePips_sw = 0.0
        if array.size(activeSweepTrades) > 0
            for i = 0 to array.size(activeSweepTrades) - 1
                t = array.get(activeSweepTrades, i)
                if t.session != "Off-Filter"
                    livePips_sw += t.isBull ? (close - t.entryPrice) / pipSize : (t.entryPrice - close) / pipSize
        liveTxt_sw   = openCnt_sw > 0 ? (livePips_sw >= 0 ? "  |  +" : "  |  ") + str.tostring(livePips_sw, "#.#") + " pips live" : ""
        openTxt_sw   = str.tostring(openCnt_sw) + " trade" + (openCnt_sw == 1 ? "" : "s") + " open" + liveTxt_sw
        liveColor_sw = openCnt_sw > 0 and livePips_sw >= 0 ? color.rgb(0,230,118) : openCnt_sw > 0 ? color.rgb(255,70,70) : color.rgb(180,220,255)
        table.cell(swTable, 0, row, openTxt_sw, text_color=liveColor_sw, text_size=swTS, bgcolor=mid)
        table.merge_cells(swTable, 0, row, 5, row)

drawSweepStatsTable()

// ══════════════════════════════════════════════════════════════
// MASTER TREND TABLE (top-right)
// ══════════════════════════════════════════════════════════════
vidya_value2 = vidya_calc(close, vidya_length, vidya_momentum)
vidya_raw = vidya_value  // ← aggiungi questa riga

mtHourStr(int h) =>
    h < 10 ? "0" + str.tostring(h) : str.tostring(h)

mtBestHour() =>
    bestH  = -1
    bestWR = -1.0
    for b = 0 to 23
        tot = mtHourTotal.get(b)
        if tot > 0
            wr = float(mtHourWins.get(b)) / tot
            if wr > bestWR
                bestWR := wr
                bestH  := b
    [bestH, bestWR]

drawMasterTrendTable() =>
    if showMasterTrendTable and barstate.islast
        var table masterTrendTable = table.new(position.top_right, 2, 23, border_width=1, frame_width=1)
        ts = tableTextSize == "tiny" ? size.tiny : tableTextSize == "small" ? size.small : tableTextSize == "normal" ? size.normal : tableTextSize == "large" ? size.large : size.huge

        ema4Above5      = ema4  > ema5
        rsiAbove50      = rsiMT > 50
        ema21Condition  = close > ema21
        sma50Condition  = close > sma50
        ema55Condition  = close > ema55
        ema89Condition  = close > ema89ForTable
        ema750Condition = close > ema750

        allBullish = ema4Above5 and rsiAbove50 and ema21Condition and sma50Condition and ema55Condition and ema89Condition and ema750Condition
        allBearish = not ema4Above5 and not rsiAbove50 and not ema21Condition and not sma50Condition and not ema55Condition and not ema89Condition and not ema750Condition

        table.set_frame_color(masterTrendTable, allBullish ? color.rgb(0, 255, 0, 50) : allBearish ? color.rgb(255, 0, 0, 50) : color.rgb(80, 80, 80, 100))

        cellBgColor    = allBullish ? color.new(tableBullColor, 85) : allBearish ? color.new(tableBearColor, 85) : color.new(color.gray, 70)
        neutralBgColor = color.new(color.gray, 70)

        var int mtRow = 0
        mtRow := 0

        table.cell(masterTrendTable, 0, mtRow, "TrendSurfer Pro 🚀", text_color=color.rgb(218, 196, 0), bgcolor=color.new(color.gray, 30), text_size=ts)
        table.cell(masterTrendTable, 1, mtRow, "      v.8.6   🤖",  text_color=color.white,            bgcolor=color.new(color.gray, 30), text_size=ts)
        mtRow += 1

        if not enableMobileMode
            ema4Color  = ema4Above5    ? tableBullColor : tableBearColor
            ema4Symbol = ema4Above5    ? "EMA 4>5"      : "EMA 4<5"
            table.cell(masterTrendTable, 0, mtRow, ema4Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=ema4Color, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            rsiColor  = rsiAbove50 ? tableBullColor : tableBearColor
            rsiSymbol = rsiAbove50 ? "RSI > 50"    : "RSI < 50"
            table.cell(masterTrendTable, 0, mtRow, rsiSymbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=rsiColor, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            ema21Color  = ema21Condition ? tableBullColor : tableBearColor
            ema21Symbol = ema21Condition ? "P > EMA21"   : "P < EMA21"
            table.cell(masterTrendTable, 0, mtRow, ema21Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=ema21Color, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            sma50Color  = sma50Condition ? tableBullColor : tableBearColor
            sma50Symbol = sma50Condition ? "P > SMA50"   : "P < SMA50"
            table.cell(masterTrendTable, 0, mtRow, sma50Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=sma50Color, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            ema55Color  = ema55Condition ? tableBullColor : tableBearColor
            ema55Symbol = ema55Condition ? "P > EMA55"   : "P < EMA55"
            table.cell(masterTrendTable, 0, mtRow, ema55Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=ema55Color, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            ema89Color  = ema89Condition ? tableBullColor : tableBearColor
            ema89Symbol = ema89Condition ? "P > EMA89"   : "P < EMA89"
            table.cell(masterTrendTable, 0, mtRow, ema89Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=ema89Color, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            ema750Color2 = ema750Condition ? tableBullColor : tableBearColor
            ema750Symbol = ema750Condition ? "P > EMA750" : "P < EMA750"
            table.cell(masterTrendTable, 0, mtRow, ema750Symbol, text_color=color.white, bgcolor=cellBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, "⬤", text_color=ema750Color2, bgcolor=cellBgColor, text_size=ts)
            mtRow += 1

            timeFilter1Text = str.substring(timeFilter1Session, 0, 2) + ":" + str.substring(timeFilter1Session, 2, 4) + "-" + str.substring(timeFilter1Session, 5, 7) + ":" + str.substring(timeFilter1Session, 7, 9)
            timeFilter2Text = str.substring(timeFilter2Session, 0, 2) + ":" + str.substring(timeFilter2Session, 2, 4) + "-" + str.substring(timeFilter2Session, 5, 7) + ":" + str.substring(timeFilter2Session, 7, 9)
            timeFilter3Text = str.substring(timeFilter3Session, 0, 2) + ":" + str.substring(timeFilter3Session, 2, 4) + "-" + str.substring(timeFilter3Session, 5, 7) + ":" + str.substring(timeFilter3Session, 7, 9)

            timeFilter1Status = enableTimeFilter  ? " 😁" : " 🥱"
            timeFilter1Color  = enableTimeFilter  ? color.rgb(255, 255, 255) : color.rgb(131, 131, 131, 50)
            table.cell(masterTrendTable, 0, mtRow, "Time Filter 1", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, timeFilter1Text + timeFilter1Status, text_color=timeFilter1Color, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            timeFilter2Status = enableTimeFilter2 ? " 😎" : " 😴"
            timeFilter2Color  = enableTimeFilter2 ? color.rgb(255, 255, 255) : color.rgb(131, 131, 131, 50)
            table.cell(masterTrendTable, 0, mtRow, "Time Filter 2", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, timeFilter2Text + timeFilter2Status, text_color=timeFilter2Color, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            timeFilter3Status = enableTimeFilter3 ? " 🤩" : " 😪"
            timeFilter3Color  = enableTimeFilter3 ? color.rgb(255, 255, 255) : color.rgb(131, 131, 131, 50)
            table.cell(masterTrendTable, 0, mtRow, "Time Filter 3", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, timeFilter3Text + timeFilter3Status, text_color=timeFilter3Color, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            tpStatus      = enableTakeProfit ? "ON 🎯" : "OFF 💤"
            tpStatusColor = enableTakeProfit ? color.rgb(0, 255, 0) : color.rgb(255, 255, 255)
            table.cell(masterTrendTable, 0, mtRow, "TP System", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, tpStatus, text_color=tpStatusColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

        // === BUY / SELL VOLUME — sempre visibili ===
        buyVolumeBgColor    = up_trend_volume   > down_trend_volume ? color.new(tableBullColor, 85) : neutralBgColor
        sellVolumeBgColor   = down_trend_volume > up_trend_volume   ? color.new(tableBearColor, 85) : neutralBgColor
        buyVolumeTextColor  = up_trend_volume   > down_trend_volume ? tableBullColor : color.white
        sellVolumeTextColor = down_trend_volume > up_trend_volume   ? tableBearColor : color.white
        blinkPlus         = timenow % 1000 < 500
        buyVolIncreasing  = up_trend_volume   > up_trend_volume[1]
        sellVolIncreasing = down_trend_volume > down_trend_volume[1]
        buyPlusTxt        = buyVolIncreasing  and blinkPlus ? " +" : ""
        sellPlusTxt       = sellVolIncreasing and blinkPlus ? " +" : ""
        buyVolumeText  = (up_trend_volume   > down_trend_volume ? str.tostring(up_trend_volume,   format.volume) + " ▲" : str.tostring(up_trend_volume,   format.volume)) + buyPlusTxt
        sellVolumeText = (down_trend_volume > up_trend_volume   ? str.tostring(down_trend_volume, format.volume) + " ▼" : str.tostring(down_trend_volume, format.volume)) + sellPlusTxt

        table.cell(masterTrendTable, 0, mtRow, "Buy Volume",  text_color=color.white,       bgcolor=buyVolumeBgColor,  text_size=ts)
        table.cell(masterTrendTable, 1, mtRow, buyVolumeText, text_color=buyVolumeTextColor, bgcolor=buyVolumeBgColor,  text_size=ts)
        mtRow += 1
        table.cell(masterTrendTable, 0, mtRow, "Sell Volume",  text_color=color.white,        bgcolor=sellVolumeBgColor, text_size=ts)
        table.cell(masterTrendTable, 1, mtRow, sellVolumeText, text_color=sellVolumeTextColor, bgcolor=sellVolumeBgColor, text_size=ts)
        mtRow += 1

        // === VOLAT. SCORE — sempre visibile ===
        table.cell(masterTrendTable, 0, mtRow, "VOLAT. SCORE", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
        table.cell(masterTrendTable, 1, mtRow, str.tostring(atrVolScore) + " / 100", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
        mtRow += 1

        if not enableMobileMode
            bprFilterStatus = enableBPRMasterFilter ? "ON ✅  TF " + bprTimeframe : "OFF 💤"
            bprFilterColor  = enableBPRMasterFilter ? color.rgb(0, 255, 0) : color.white
            table.cell(masterTrendTable, 0, mtRow, "BPR Master Filter", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, bprFilterStatus, text_color=bprFilterColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            mtCandleFilterStatus = enableMTCandleMasterFilter ? "ON ✅" : "OFF 💤"
            mtCandleFilterColor  = enableMTCandleMasterFilter ? color.rgb(0, 255, 0) : color.white
            table.cell(masterTrendTable, 0, mtRow, "MT Candles Master Filter", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, mtCandleFilterStatus, text_color=mtCandleFilterColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            sweepFilterStatus = enableSweepMasterFilter ? "ON ✅  max " + str.tostring(sweepMasterFilterBars) + " bars" : "OFF 💤"
            sweepFilterColor  = enableSweepMasterFilter ? color.rgb(0, 255, 0) : color.white
            table.cell(masterTrendTable, 0, mtRow, "Liq.Sweep Master Filter", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, sweepFilterStatus, text_color=sweepFilterColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            stFilterStatus = enableSuperTrendMasterFilter ? "ON ✅" : "OFF 💤"
            stFilterColor  = enableSuperTrendMasterFilter ? color.rgb(0, 255, 0) : color.white
            table.cell(masterTrendTable, 0, mtRow, "SuperTrend Master Filter", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, stFilterStatus, text_color=stFilterColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            volFilterStatus = enableVolScoreFilter ? "≥ " + str.tostring(volScoreMinThreshold) + " ✅" : "OFF 💤"
            table.cell(masterTrendTable, 0, mtRow, "Volat.Score Master Filter", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, volFilterStatus, text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            atrModeStatus = enableATRMode ? "ON ✅  x" + str.tostring(atrMultiplier, "#.#") : "OFF 💤"
            atrModeColor  = enableATRMode ? color.rgb(0, 255, 0) : color.white
            table.cell(masterTrendTable, 0, mtRow, "ATR Mode", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
            table.cell(masterTrendTable, 1, mtRow, atrModeStatus, text_color=atrModeColor, bgcolor=neutralBgColor, text_size=ts)
            mtRow += 1

            if showBestMTHour
                [mtBH, mtBWR] = mtBestHour()
                mtBestHourStartH = mtBH >= 0 ? mtBH * mtHourWindowSize : 0
                mtBestHourEndH   = mtBH >= 0 ? math.min(mtBestHourStartH + mtHourWindowSize - 1, 23) : 0
                mtBestHourTxt = mtBH >= 0
                     ? mtHourStr(mtBestHourStartH) + ":00-" + mtHourStr(mtBestHourEndH) + ":59  WR " + str.tostring(mtBWR * 100, "#.#") + "%  (n=" + str.tostring(mtHourTotal.get(mtBH)) + ")"
                     : "N/A"
                table.cell(masterTrendTable, 0, mtRow, "Best MT Hour (" + str.tostring(mtHourWindowSize) + "h) ⏰", text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
                table.cell(masterTrendTable, 1, mtRow, mtBestHourTxt, text_color=color.white, bgcolor=neutralBgColor, text_size=ts)
                mtRow += 1

        // === CURRENT TREND — sempre visibile ===
        trendText      = ""
        trendBgColor   = neutralBgColor
        trendTextColor = color.white

        if allBullish
            trendText      := "VERY BULLISH 🚀"
            trendBgColor   := cellBgColor
            trendTextColor := color.rgb(0, 255, 0)
        else if allBearish
            trendText      := "VERY BEARISH 💀"
            trendBgColor   := cellBgColor
            trendTextColor := color.rgb(255, 50, 50)
        else if close > ema750 and close > vidya_raw
            trendText      := "BULLISH 📈"
            trendBgColor   := neutralBgColor
            trendTextColor := color.rgb(0, 200, 0)
        else if close < ema750 and close < vidya_raw
            trendText      := "BEARISH 📉"
            trendBgColor   := neutralBgColor
            trendTextColor := color.rgb(200, 50, 50)
        else
            trendText      := "NEUTRAL ⚖️"
            trendBgColor   := neutralBgColor
            trendTextColor := color.rgb(255, 255, 255)

        table.cell(masterTrendTable, 0, mtRow, "Current Trend", text_color=color.white,   bgcolor=trendBgColor, text_size=ts)
        table.cell(masterTrendTable, 1, mtRow, trendText,        text_color=trendTextColor, bgcolor=trendBgColor, text_size=ts)


drawMasterTrendTable()
````
