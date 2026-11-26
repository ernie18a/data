# DMT Full Control Pro V2 [DearmasTrader]

- url: https://www.tradingview.com/script/eKwe8KQq/
- type: strategy
- pine_id: PUB;7a13899ac7974b1fb1de2f15bc3b0470
- version: 1.0

## Description

This is the official documentation for integrating the TradingView Strategy V2 with your DearmasTrader platform (V1.8.5+).

Our TradingView Strategy V2 has been optimized to send ultra-low latency signals, specifically designed to communicate with the internal engine of our DCA (Dollar Cost Averaging) system. When using this strategy, the analytical "brain" is in TradingView, but capital execution is protected by DearmasTrader.

Below, we detail all the possibilities and commands you can use to maximize your returns without risking your budget.

🛠️ How Does the Connection Work?
DearmasTrader operates under a "Directional Lock" system and strict capital management. This means that:

TradingView tells you WHEN and IN WHICH DIRECTION to enter. (Sends the Signal).

DearmasTrader decides HOW to execute that capital and at what price to average down. (Ignoring erroneous or excessive TV volumes).
Connect Strategy V2 to your Bot by pasting your unique URL and Webhook Token in the Alerts section of TradingView.

📡 Webhook Message Options (Payloads)
When you configure the Strategy V2 alert, the JSON message you send to the Webhook will determine how the bot reacts. You have two ways to operate: Strict Commands (Our recommendation) and Neutral Commands.

1️⃣ Strict Directional Commands (Safest / Recommended)
These commands force DearmasTrader to check if the Bot is pre-configured for that same direction. If there is human error (e.g., you send SHORT to a Long bot), the system will reject the order to protect you.

"action": "LONG"

Ideal for: Strategy V2 configured only to buy on dips.

Bot Response: If the bot in your panel is in LONG, it will execute its base order (BaseOrder) and display its DCA grid downwards. If your bot was in SHORT, it will ignore it as a security vulnerability.

"action": "SHORT"

Ideal for: V2 strategies trading bearish bounces.

Bot Response: Identical to Long, but exclusively for short selling. It will display the DCA grid upwards.

2️⃣ Neutral (Flexible) Commands
These commands tell DearmasTrader to initiate a cycle regardless of the situation, adapting to the bot's current native configuration.

"action": "ENTRY" or "action": "OPEN"
Ideal for: Strategy creators who use a single webhook to activate a bot, regardless of its configuration in the panel.

Bot Response: It will read the configuration in the DearmasTrader panel and open a Long position if the bot indicates Long, or a Short position if the bot indicates Short.

3️⃣ Panic Button or Take Profit (Close) Command
TradingView can close a position regardless of the PnL (Profit-to-Low) signal from DearmasTrader (e.g., a trailing stop detected in TradingView by a moving average crossover).

"action": "CLOSE" (or EXIT, FLAT)
Bot Response: DearmasTrader will execute an immediate market order, closing 100% of the current position, canceling all pending Safety Orders, and returning to inactive status (WaitForSignal: true). It will be clean and ready to hunt for a new entry.

⚙️ Golden Rules on Financial Capital and DCA
If you see parameters like "contracts": 1000 in your TradingView message from strategy V2, DON'T WORRY. In the overall architecture, DearmasTrader V1.8.5+ implements "Anti-Volume Overwrite".

📝 What does this mean? Even if TradingView sends a message saying "Buy 1000 BTC", your internal bot will ignore it on initial entries (OPEN/ENTRY). DearmasTrader will always use the margin budget from your BaseOrderVolume and will progressively increase it using your SafetyOrders table configured in the web panel. DCA always takes precedence over risk.

🎯 Best Practice V2: Bidirectional Accounts (Hedging)
With Strategy V2, we often want to trade both long and short positions on the same pair (e.g., BTC/USDT). To avoid conflicts of cross-positions, the professional method supported by our team is:

Create two different bots in DearmasTrader. One bot (BTC-LONG-V2) pre-set to long, and another bot (BTC-SHORT-V2) pre-set to short. Both bots will generate two different webhook links in your admin panel.

In TradingView V2: Create two separate alerts. In the "Long Condition" alert, paste the webhook of your long bot. In the "Short Condition" alert, paste the webhook of your short bot.

This way, you isolate risk and allow opposing strategies to perform their DCA (Dollar-Cost Analyzed) by averaging without canceling each other out or causing sudden closures on the Binance/Bybit exchange.

Developed and maintained by the Quantitative Engineering team at [DearmasTrader]

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════
// DMT FULL CONTROL PRO V2 — DearmasTrader Webhook Strategy
// Versión: 2.0 | Pine Script V6 | Todos los indicadores
// ═══════════════════════════════════════════════════════════════
//@version=6
strategy(title="🚀 DMT Full Control Pro V2 [DearmasTrader]",
     shorttitle="DMT V2",
     overlay=true,
     pyramiding=0,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=10,
     initial_capital=1000,
     commission_type=strategy.commission.percent,
     commission_value=0.05)

// ─── GRUPO 1: MODO DE OPERACIÓN ─────────────────────────────────
var string G1 = "⚙️ Modo de Operación"
tradeMode    = input.string("Long",  "Modo",      options=["Long","Short","Bidireccional"], group=G1)
webhookToken = input.string("",      "Bot Secret (Token)", group=G1)
baseVolume   = input.float(100,      "Volumen Base (USDT)", minval=1, step=10, group=G1)
dynamicVol   = input.bool(true,      "Volumen Dinámico x ATR", group=G1)

// ─── GRUPO 2: EMAs ───────────────────────────────────────────────
var string G2 = "📈 EMAs (Golden/Death Cross)"
emaFastLen   = input.int(9,   "EMA Rápida", minval=1,  group=G2)
emaSlowLen   = input.int(21,  "EMA Lenta",  minval=5,  group=G2)
useEma       = input.bool(true, "Activar filtro EMA", group=G2)

// ─── GRUPO 3: RSI ────────────────────────────────────────────────
var string G3 = "🔵 RSI"
rsiLen       = input.int(14,  "Longitud RSI",      minval=2,  group=G3)
rsiOB        = input.int(70,  "Sobrecompra (OB)",  minval=50, group=G3)
rsiOS        = input.int(30,  "Sobreventa (OS)",   maxval=50, group=G3)
useRsi       = input.bool(true, "Activar filtro RSI", group=G3)

// ─── GRUPO 4: MACD ───────────────────────────────────────────────
var string G4 = "⚡ MACD"
macdFast     = input.int(12, "MACD Rápido", minval=1, group=G4)
macdSlow     = input.int(26, "MACD Lento",  minval=5, group=G4)
macdSignal   = input.int(9,  "MACD Señal",  minval=1, group=G4)
useMacd      = input.bool(true, "Activar filtro MACD", group=G4)

// ─── GRUPO 5: BANDAS DE BOLLINGER ───────────────────────────────
var string G5 = "🎯 Bandas de Bollinger"
bbLen        = input.int(20,  "BB Longitud", minval=5,  group=G5)
bbMult       = input.float(2.0,"BB Desviación",step=0.1, group=G5)
useBb        = input.bool(false,"Activar filtro BB (Squeeze)", group=G5)

// ─── GRUPO 6: ATR (VOLATILIDAD) ──────────────────────────────────
var string G6 = "🌊 ATR — Filtro de Volatilidad"
atrLen       = input.int(14,  "ATR Longitud",   minval=1, group=G6)
atrMult      = input.float(1.5,"ATR Mínimo (x precio)", step=0.1, group=G6)
useAtr       = input.bool(true, "Filtrar mercado plano con ATR", group=G6)

// ─── GRUPO 7: FILTRO DE VOLUMEN ──────────────────────────────────
var string G7 = "📊 Volumen de Mercado"
volMaLen     = input.int(20, "MA Volumen", minval=5, group=G7)
useVolFilter = input.bool(false,"Requiere volumen superior a la media", group=G7)

// ════════════════════════════════════════════════════════════════
// CÁLCULO DE INDICADORES
// ════════════════════════════════════════════════════════════════

// EMAs
emaFast      = ta.ema(close, emaFastLen)
emaSlow      = ta.ema(close, emaSlowLen)
goldenCross  = ta.crossover(emaFast, emaSlow)
deathCross   = ta.crossunder(emaFast, emaSlow)

// RSI
rsi          = ta.rsi(close, rsiLen)
rsiLong      = rsi < rsiOB   // No sobrecomprado para Long
rsiShort     = rsi > rsiOS   // No sobrevendido para Short

// MACD
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
macdBullish  = macdLine > signalLine and histLine > 0
macdBearish  = macdLine < signalLine and histLine < 0

// Bandas de Bollinger
[bbUpper, bbBasis, bbLower] = ta.bb(close, bbLen, bbMult)
bbSqueeze    = (bbUpper - bbLower) / bbBasis < 0.04  // <4% → mercado comprimido

// ATR
atrVal       = ta.atr(atrLen)
atrFilter    = atrVal > (close * (atrMult / 100))  // Volatilidad mínima

// Volumen
volMa        = ta.sma(volume, volMaLen)
volFilter    = volume > volMa

// ════════════════════════════════════════════════════════════════
// LÓGICA DE SEÑALES COMPUESTA
// ════════════════════════════════════════════════════════════════

// Condiciones base
emaLongOk    = not useEma  or (emaFast > emaSlow)
emaShortOk   = not useEma  or (emaFast < emaSlow)
rsiLongOk    = not useRsi  or rsiLong
rsiShortOk   = not useRsi  or rsiShort
macdLongOk   = not useMacd or macdBullish
macdShortOk  = not useMacd or macdBearish
bbLongOk     = not useBb   or not bbSqueeze
atrOk        = not useAtr  or atrFilter
volOk        = not useVolFilter or volFilter

// Entrada Long: Golden Cross + Confirmaciones
longCondition  = goldenCross and emaLongOk and rsiLongOk and macdLongOk and bbLongOk and atrOk and volOk

// Entrada Short: Death Cross + Confirmaciones
shortCondition = deathCross and emaShortOk and rsiShortOk and macdShortOk and bbLongOk and atrOk and volOk

// Cierre
closeLong      = deathCross
closeShort     = goldenCross

// ════════════════════════════════════════════════════════════════
// VOLUMEN DINÁMICO (basado en ATR — señales más fuertes = más capital)
// ════════════════════════════════════════════════════════════════
atrNorm      = math.min(atrVal / ta.sma(atrVal, 50), 2.0)  // max 2x
finalVolume  = dynamicVol ? math.round(baseVolume * atrNorm, 2) : baseVolume

// ════════════════════════════════════════════════════════════════
// GENERACIÓN DE ALERTAS (Webhooks DearmasTrader)
// ════════════════════════════════════════════════════════════════

// Payload de Apertura — incluye volumen dinámico
alertLongOpen  = '{"action":"OPEN","direction":"LONG","token":"' + webhookToken + '","volume":' + str.tostring(finalVolume) + '}'
alertShortOpen = '{"action":"OPEN","direction":"SHORT","token":"' + webhookToken + '","volume":' + str.tostring(finalVolume) + '}'
alertClose     = '{"action":"CLOSE","token":"' + webhookToken + '"}'

// ════════════════════════════════════════════════════════════════
// EJECUCIÓN DE LA ESTRATEGIA
// ════════════════════════════════════════════════════════════════
isLong  = tradeMode == "Long"  or tradeMode == "Bidireccional"
isShort = tradeMode == "Short" or tradeMode == "Bidireccional"

// Entradas
if longCondition and isLong
    strategy.entry("Long", strategy.long, alert_message=alertLongOpen)

if shortCondition and isShort
    strategy.entry("Short", strategy.short, alert_message=alertShortOpen)

// Cierres
if closeLong and isLong
    strategy.close("Long", alert_message=alertClose)

if closeShort and isShort
    strategy.close("Short", alert_message=alertClose)

// ════════════════════════════════════════════════════════════════
// VISUALIZACIÓN
// ════════════════════════════════════════════════════════════════

// Plots de EMAs
p1 = plot(emaFast, "EMA Rápida", color=color.new(color.yellow, 0), linewidth=2)
p2 = plot(emaSlow, "EMA Lenta",  color=color.new(color.blue, 0),   linewidth=2)
fill(p1, p2, emaFast > emaSlow ? color.new(color.green, 85) : color.new(color.red, 85))

// Bandas de Bollinger (si activo)
bbUP = plot(useBb ? bbUpper : na, "BB Upper", color=color.new(color.gray, 50), linewidth=1)
bbLW = plot(useBb ? bbLower : na, "BB Lower", color=color.new(color.gray, 50), linewidth=1)
fill(bbUP, bbLW, color=color.new(color.gray, 90))

// Señales visuales en el gráfico
plotshape(longCondition  and isLong,  "🟢 OPEN LONG",  shape.triangleup,   location.belowbar, color.lime,   size=size.normal)
plotshape(shortCondition and isShort, "🔴 OPEN SHORT", shape.triangledown, location.abovebar, color.red,    size=size.normal)
plotshape(closeLong  and isLong,  "⬜ CLOSE LONG",  shape.xcross, location.abovebar, color.yellow, size=size.small)
plotshape(closeShort and isShort, "⬜ CLOSE SHORT", shape.xcross, location.belowbar, color.orange, size=size.small)

// Panel de información
var table infoPanel = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 70), border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)
if barstate.islast
    table.cell(infoPanel, 0, 0, "DMT V2 PRO",     text_color=color.white,   text_size=size.normal, bgcolor=color.new(color.purple, 40))
    table.cell(infoPanel, 1, 0, tradeMode,         text_color=color.yellow,  text_size=size.normal, bgcolor=color.new(color.purple, 40))
    table.cell(infoPanel, 0, 1, "EMA Rápida",      text_color=color.gray)
    table.cell(infoPanel, 1, 1, str.tostring(math.round(emaFast,2)), text_color=color.yellow)
    table.cell(infoPanel, 0, 2, "RSI",             text_color=color.gray)
    table.cell(infoPanel, 1, 2, str.tostring(math.round(rsi,1)), text_color=rsi > rsiOB ? color.red : rsi < rsiOS ? color.green : color.white)
    table.cell(infoPanel, 0, 3, "MACD Hist",       text_color=color.gray)
    table.cell(infoPanel, 1, 3, str.tostring(math.round(histLine,4)), text_color=histLine > 0 ? color.green : color.red)
    table.cell(infoPanel, 0, 4, "ATR",             text_color=color.gray)
    table.cell(infoPanel, 1, 4, str.tostring(math.round(atrVal,4)), text_color=atrOk ? color.green : color.orange)
    table.cell(infoPanel, 0, 5, "Volumen Signal",  text_color=color.gray)
    table.cell(infoPanel, 1, 5, str.tostring(finalVolume) + " USDT", text_color=color.aqua)
    table.cell(infoPanel, 0, 6, "Estado",          text_color=color.gray)
    table.cell(infoPanel, 1, 6, atrOk ? "✅ ACTIVO" : "⚠️ PLANO", text_color=atrOk ? color.green : color.orange)
````
