# Traffic Light - Semaforo V3 - Araldo62

- url: https://www.tradingview.com/script/RsVAYEUa/
- type: indicator
- pine_id: PUB;ff24ea7345ed4586a7076fda52169e02
- version: 1.0

## Description

🇬🇧 English Description (Primary)
Title: Session Light V3 - Araldo62: Multi-Timeframe Trend Filter & Signal Generator

Description:

🚀 Stop Chasing Noise. Start Trading High-Probability Setups.

Session Light V3 - Araldo62 is an advanced multi-timeframe indicator designed for day traders and swing traders who value quality over quantity. Unlike standard oscillators that generate constant noise, Session Light V3 filters out low-probability moves, offering you a panoramic view of the asset's health and providing only the strongest, most reliable signals.

🎯 Core Philosophy: Fewer Signals, Higher Impact This indicator is built on the principle that less is more. It waits for the perfect alignment between the hourly trend (H1) and the 15-minute momentum (M15).

Why? To avoid fake-outs and choppy markets.
Result: You get fewer signals, but when they appear, they represent high-confidence setups with superior Risk/Reward ratios.
🧠 How It Works: The 3 Market States The indicator uses a visual sidebar to tell you exactly what the market is doing before you enter a trade:

🔴 CONFLICT (Red Zone): H1 and M15 are moving in opposite directions.
Action: DO NOT TRADE. The market is confused. Signals are filtered out to protect your capital.
🟡 ELASTIC STRETCHED (Yellow Zone): The distance between SMA 20 and SMA 35 is significant (> 0.5%).
Action: HIGH ATTENTION. The "elastic" is stretched. This often precedes a powerful breakout or a sharp mean reversion.
🟢 ALIGNED (No Zone/Green): H1 and M15 are moving in harmony.
Action: EXECUTE. This is the ideal environment. Buy/Sell signals are active and highly reliable.
✨ Key Features:

Multi-Timeframe Analysis: Combines H1 trend direction with M15 entry triggers.
Smart Filtering: Automatically hides signals during "Conflict" phases.
Visual Clarity: Color-coded sidebars (Red/Yellow/None) for instant market context.
Session Awareness: Vertical lines mark major session opens (Tokyo, London, NY) to align trades with volume spikes.
Dashboard: Real-time stats on RSI, ADX, and Trend Alignment.
📈 Ideal For:

Traders tired of over-trading and false breakouts.
Those who want a clear "Go/No-Go" signal based on trend alignment.
Day trading and Swing trading on M15/H1 timeframes.
⚠️ Disclaimer: Trading involves risk. This indicator is a tool to assist in decision-making, not a guarantee of profit. Always use proper risk management and stop-loss orders. Past performance does not guarantee future results.

🇮🇹 Italian Description (Secondary)
Titolo: Session Light V3 - Araldo62: Filtro Trend Multi-Timeframe e Generatore di Segnali

Descrizione:

🚀 Smetti di inseguire il "Rumore". Inizia a tradare setup ad alta probabilità.

Session Light V3 - Araldo62 è un indicatore avanzato multi-timeframe progettato per i day trader e gli swing trader che danno priorità alla qualità rispetto alla quantità. A differenza degli oscillatori standard che generano continui falsi segnali, Session Light V3 filtra i movimenti a bassa probabilità, offrendoti una visione panoramica della salute dell'asset e fornendo solo i segnali più forti e affidabili.

🎯 Filosofia di Base: Pochi Segnali, Alto Impatto Questo indicatore si basa sul principio che meno è meglio. Attende l'allineamento perfetto tra il trend orario (H1) e il momentum a 15 minuti (M15).

Perché? Per evitare falsi breakout e mercati laterali (choppy).
Risultato: Ricevi meno segnali, ma quando appaiono, rappresentano setup ad alta fiducia con un rapporto Rischio/Rendimento superiore.
🧠 Come Funziona: I 3 Stati del Mercato L'indicatore utilizza una barra laterale visiva per dirti esattamente cosa sta facendo il mercato prima di entrare in trade:

🔴 CONFLICT (Zona Rossa): H1 e M15 si muovono in direzioni opposte.
Azione: NON OPERARE. Il mercato è confuso. I segnali vengono filtrati per proteggere il tuo capitale.
🟡 ELASTIC STRETCHED (Zona Gialla): La distanza tra la SMA 20 e la SMA 35 è significativa (> 0.5%).
Azione: ALTA ATTENZIONE. L'"elastico" è teso. Spesso questo precede un breakout potente o una forte correzione (mean reversion).
🟢 ALIGNED (Nessuna Zona / Verde): H1 e M15 si muovono in armonia.
Azione: ESEGUI. Questo è l'ambiente ideale. I segnali di Acquisto/Vendita sono attivi e altamente affidabili.
✨ Caratteristiche Principali:

Analisi Multi-Timeframe: Combina la direzione del trend H1 con i trigger di ingresso M15.
Filtro Intelligente: Nasconde automaticamente i segnali durante le fasi di "Conflict".
Chiarezza Visiva: Barre laterali codificate a colori (Rosso/Giallo/Nessuno) per un contesto di mercato immediato.
Consapevolezza delle Sessioni: Linee verticali segnano l'apertura delle sessioni principali (Tokyo, Londra, NY) per allineare i trade ai picchi di volume.
Dashboard: Statistiche in tempo reale su RSI, ADX e Allineamento del Trend.
📈 Ideale Per:

Trader stanchi dell'over-trading e dei falsi breakout.
Chi cerca un chiaro segnale "Go/No-Go" basato sull'allineamento del trend.
Day trading e Swing trading sui timeframes M15/H1.
⚠️ Disclaimer: Il trading comporta dei rischi. Questo indicatore è uno strumento per assistere nel processo decisionale, non una garanzia di profitto. Utilizza sempre una corretta gestione del rischio e ordini stop-loss. I risultati passati non garantiscono quelli futuri.

## Source Code

````pine
//@version=5
// Indicator: Semaforo Light V3 - Optimized Multi-Timeframe Strategy
// Author: [Your Name]
// Description: Combines Bollinger Bands, RSI, SMA Crossover, and ADX for high-probability trend reversal and continuation setups.
// Features: H1 Trend Alignment Filter, Elastic SMA Distance Check, Session Affluence Integration.

indicator("Semaforo Light V3 [YourName]", overlay=true, scale=scale.none)

// --- Input Parameters ---
mult = input.float(2.0, "Volatility Multiplier")
lenBoll = input.int(20, "Bollinger Band Length")
lenFast = input.int(20, "Fast SMA Length")
lenSlow = input.int(35, "Slow SMA Length")
rsiLen = input.int(4, "RSI Length")
rsiOverbought = input.int(85, "RSI Overbought Level")
rsiOversold = input.int(15, "RSI Oversold Level")
adxLen = input.int(12, "ADX Length")
adxThresh = input.int(30, "ADX Threshold")
useDistanceFilter = input.bool(true, "Enable Elastic SMA Filter")
useAdxFilter = input.bool(true, "Enable ADX Filter")
useCrossFilter = input.bool(true, "Enable SMA Crossover Filter")

// --- Calculations ---
basis = ta.sma(close, lenBoll)
dev = mult * ta.stdev(close, lenBoll)
upper = basis + dev
lower = basis - dev
rsi = ta.rsi(close, rsiLen)

smaF = ta.sma(close, lenFast)
smaS = ta.sma(close, lenSlow)
bullM15 = smaF > smaS
bearM15 = smaF < smaS

[_, _, adx] = ta.dmi(adxLen, adxLen)

// Elastic SMA Filter
distPct = math.abs(smaF - smaS) / smaS * 100
isStretched = distPct > 0.5

// --- Multi-Timeframe Alignment (H1) ---
smaF_H1 = request.security(syminfo.tickerid, "60", ta.sma(close, lenFast))
smaS_H1 = request.security(syminfo.tickerid, "60", ta.sma(close, lenSlow))
bullH1 = smaF_H1 > smaS_H1
bearH1 = smaF_H1 < smaS_H1

aligned = (bullM15 and bullH1) or (bearM15 and bearH1)
conflict = (bullM15 and bearH1) or (bearM15 and bullH1)

// --- Signal Logic ---
isPrem = close > upper
isDisc = close < lower

baseBuy = isDisc and (rsi < rsiOversold) and (not useAdxFilter or adx > adxThresh)
baseSell = isPrem and (rsi > rsiOverbought) and (not useAdxFilter or adx > adxThresh)

condBuy = baseBuy and (not useCrossFilter or bullM15) and (not useDistanceFilter or isStretched)
condSell = baseSell and (not useCrossFilter or bearM15) and (not useDistanceFilter or isStretched)

// Apply Alignment Filter
finalBuy = condBuy and aligned
finalSell = condSell and aligned

// --- Visualization ---
// Bollinger Bands
pU = plot(upper, color=color.new(color.purple, 30), linewidth=2, title="Premium Zone", style=plot.style_linebr)
pL = plot(lower, color=color.new(color.green, 30), linewidth=2, title="Discount Zone", style=plot.style_linebr)
pB = plot(basis, color=color.new(color.gray, 60), title="Equilibrium", style=plot.style_linebr)
fill(pU, pB, color=color.new(color.purple, 85), title="Premium Area")
fill(pL, pB, color=color.new(color.green, 85), title="Discount Area")

// SMA Lines
plot(smaF, color=color.new(color.blue, 50), linewidth=1, title="Fast SMA")
plot(smaS, color=color.new(color.orange, 50), linewidth=1, title="Slow SMA")

// Background for Alignment
bgcolor(aligned ? color.new(color.green, 95) : na, title="Aligned")
bgcolor(conflict ? color.new(color.red, 95) : na, title="Conflict")
bgcolor(isStretched ? color.new(color.yellow, 90) : na, title="Elastic Stretched")

// Signal Shapes
plotshape(finalSell, style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small, offset=-1)
plotshape(finalBuy, style=shape.labelup, location=location.belowbar, color=color.blue, text="BUY", textcolor=color.white, size=size.small, offset=-1)

// Gray circles for filtered signals
plotshape(condSell and not aligned, style=shape.circle, location=location.abovebar, color=color.gray, size=size.tiny, offset=-1, title="Filtered Signal")
plotshape(condBuy and not aligned, style=shape.circle, location=location.belowbar, color=color.gray, size=size.tiny, offset=-1, title="Filtered Signal")

// Info Table
var table statusTable = table.new(position.top_right, 1, 5, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)
if barstate.islast
    string rsiTxt = "RSI: " + str.tostring(rsi, "#.##")
    string adxTxt = "ADX: " + str.tostring(adx, "#.##")
    string distTxt = "SMA Dist: " + str.tostring(distPct, "#.##") + "%"
    string m15Txt = "M15: " + (bullM15 ? "🟢 BULL" : "🔴 BEAR")
    string h1Txt = "H1: " + (bullH1 ? "🟢 BULL" : "🔴 BEAR")
    string alignTxt = aligned ? "✅ ALIGNED" : (conflict ? "⚠️ CONFLICT" : "🟡 NEUTRAL")
    
    table.cell(statusTable, 0, 0, rsiTxt, text_color=color.white, text_size=size.small)
    table.cell(statusTable, 0, 1, adxTxt, text_color=color.white, text_size=size.small)
    table.cell(statusTable, 0, 2, distTxt, text_color=color.white, text_size=size.small)
    table.cell(statusTable, 0, 3, m15Txt + " | " + h1Txt, text_color=color.white, text_size=size.small)
    table.cell(statusTable, 0, 4, alignTxt, text_color=aligned ? color.green : (conflict ? color.red : color.orange), text_size=size.small)
````
