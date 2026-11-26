# CHOP Dashboard (avoid sideway action)

- url: https://www.tradingview.com/script/RVGPiS33/
- type: indicator
- pine_id: PUB;3fefb75dcf0345a585eabfbe0ab41414
- version: 1.0

## Description

CHOP Dashboard 

... ist ein Multi-Faktor Flow- und Momentum-Dashboard für TradingView, das Delta-Flow, Volume, Trend, Supertrend und Marktstruktur in einem kompakten Interface kombiniert.

Der Indikator analysiert Kauf- und Verkaufsdruck über ein dynamisches Score-System und erkennt Trend-, Expansion- sowie Chop-Phasen in Echtzeit. Zusätzlich integriert das Dashboard Volume-Filter, EMA-Trend-Bias, CVD-Logik und Supertrend-Bestätigung für präzisere Signale.

Features:
• Delta & Flow EMA Analyse
• Dynamisches Buy/Sell Score-System
• CHOP Market Context Detection
• Expansion & Impulse-Erkennung
• EMA50 Trendfilter
• Supertrend Integration
• Kompaktes Live-Dashboard
• Optimiert für schnelle Marktanalyse

Geeignet für Scalping, Intraday- und Swing-Trading.

## Source Code

````pine
//@version=6
indicator("CHOP Dashboard PRO FIXED", overlay=true, precision=2, max_lines_count=500)

// =====================================================
// INPUTS
// =====================================================
len             = input.int(10, "Flow EMA Länge", minval=1)
useTrendFilter  = input.bool(true, "Trend Bias nutzen")
useVolFilter    = input.bool(true, "Volume nutzen")
useSupertrend   = input.bool(true, "Supertrend nutzen")
useChopContext  = input.bool(true, "CHOP nur als Kontext")
showCVD         = input.bool(true, "CVD anzeigen")

dashPos         = input.string(
     "Top Right",
     "Dashboard Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"]
)

// CHOP
chopLen         = input.int(14, "CHOP Länge")
chopThreshold   = input.float(61.8, "CHOP Threshold")

// SUPERTREND
stAtrLen        = input.int(7, "Supertrend ATR")
stFactor        = input.float(2.0, "Supertrend Faktor")

// =====================================================
// DASH POSITION
// =====================================================
pos =
     dashPos == "Top Right"
         ? position.top_right
         : dashPos == "Top Left"
             ? position.top_left
             : dashPos == "Bottom Right"
                 ? position.bottom_right
                 : position.bottom_left

// =====================================================
// DELTA PROXY
// =====================================================
barRange = math.max(high - low, syminfo.mintick)
delta = not na(volume) ? volume * ((close - open) / barRange) : 0

// =====================================================
// FLOW
// =====================================================
flowEma = not na(delta) ? ta.ema(delta, len) : 0

// ROBUSTER THRESHOLD
threshold = ta.ema(math.abs(delta), 20) * 1.2

// =====================================================
// CVD
// =====================================================
var float cvd = 0.0
newDay = ta.change(dayofmonth) != 0

if newDay
    cvd := 0

cvd += delta

// =====================================================
// VOLUME
// =====================================================
volAvg = ta.sma(volume, 20)
highVol = volume > volAvg * 1.3

// =====================================================
// TREND
// =====================================================
ema50 = ta.ema(close, 50)

trendUp = close > ema50
trendDn = close < ema50

// =====================================================
// SUPERTREND
// =====================================================
[supertrend, direction] = ta.supertrend(stFactor, stAtrLen)

// bestätigter Zustand (geschlossene Kerze)
stBull = direction[1] < 0
stBear = direction[1] > 0

// echte Flip-Signale
stBuySignal  = direction[1] > 0 and direction < 0
stSellSignal = direction[1] < 0 and direction > 0

// =====================================================
// CHOP INDEX
// =====================================================
atrSeries = ta.atr(1)
atrSum = ta.sma(atrSeries, chopLen) * chopLen

hh = ta.highest(high, chopLen)
ll = ta.lowest(low, chopLen)

chop =
     100 *
     math.log10(atrSum / math.max(hh - ll, syminfo.mintick)) /
     math.log10(chopLen)

isChop = chop > chopThreshold

// =====================================================
// EXPANSION DETECTION
// =====================================================
body = math.abs(close - open)
bodyExp = body > ta.ema(body, 20) * 1.5

atrFast = ta.atr(5)
atrSlow = ta.atr(20)

rangeExpansion = atrFast > atrSlow * 1.25
impulse = bodyExp and rangeExpansion

// =====================================================
// SCORE SYSTEM
// =====================================================
buyScore = 0
sellScore = 0

// DELTA
buyScore += delta > threshold ? 1 : 0
sellScore += delta < -threshold ? 1 : 0

// FLOW EMA
buyScore += flowEma > 0 ? 1 : 0
sellScore += flowEma < 0 ? 1 : 0

// VOLUME
if useVolFilter
    buyScore += highVol and delta > 0 ? 1 : 0
    sellScore += highVol and delta < 0 ? 1 : 0

// TREND
if useTrendFilter
    buyScore += trendUp ? 1 : 0
    sellScore += trendDn ? 1 : 0

// SUPERTREND
if useSupertrend
    buyScore += stBull ? 1 : 0
    sellScore += stBear ? 1 : 0

// IMPULSE BONUS
buyScore += impulse and close > open ? 2 : 0
sellScore += impulse and close < open ? 2 : 0

// CHOP KONTEXT
if useChopContext
    buyScore -= isChop ? 1 : 0
    sellScore -= isChop ? 1 : 0

// =====================================================
// SIGNALS
// =====================================================
strongBuy = buyScore >= 6 and buyScore > sellScore
strongSell = sellScore >= 6 and sellScore > buyScore

buy  = buyScore >= 3 and not strongBuy
sell = sellScore >= 3 and not strongSell

// =====================================================
// STATUS TEXT
// =====================================================
flowStatus =
     strongBuy
         ? "🟢 STRONG BUY"
         : buy
             ? "🟢 BUY"
             : strongSell
                 ? "🔴 STRONG SELL"
                 : sell
                     ? "🔴 SELL"
                     : "⚪ NO EDGE"

flowColor =
     strongBuy or buy
         ? color.lime
         : strongSell or sell
             ? color.red
             : color.gray

marketState =
     isChop
         ? "CHOP"
         : impulse
             ? "EXPANSION"
             : "TREND"

marketColor =
     isChop
         ? color.orange
         : impulse
             ? color.aqua
             : color.green

// =====================================================
// SUPERTREND TEXT
// =====================================================
stText =
     stBuySignal
         ? "BUY SIGNAL"
         : stSellSignal
             ? "SELL SIGNAL"
             : stBull
                 ? "BULLISH"
                 : "BEARISH"

// =====================================================
// PLOTS
// =====================================================
plot(
     delta,
     title="Delta",
     style=plot.style_columns,
     color=delta >= 0
         ? color.new(color.green, 35)
         : color.new(color.red, 35)
)

plot(flowEma, title="Flow EMA", color=color.yellow)
plot(ema50, title="EMA50", color=color.blue)

plot(
     supertrend,
     title="Supertrend",
     color=direction < 0 ? color.green : color.red,
     linewidth=2
)

bgcolor(
     strongBuy
         ? color.new(color.green, 85)
         : strongSell
             ? color.new(color.red, 85)
             : impulse
                 ? color.new(color.aqua, 88)
                 : isChop
                     ? color.new(color.orange, 92)
                     : na
)
/// =====================================================
// DASHBOARD
// =====================================================
var table dash = table.new(
     pos,
     2,
     7, // vorher 10
     bgcolor=color.new(color.black, 75),
     border_width=1
)

if barstate.islast

    // STATUS
    table.cell(
         dash,
         0,
         0,
         "FLOW STATUS",
         bgcolor=color.aqua,
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         0,
         flowStatus,
         text_color=flowColor
    )

    // BUY SCORE
    table.cell(
         dash,
         0,
         1,
         "BUY SCORE",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         1,
         str.tostring(buyScore),
         text_color=buyScore > sellScore ? color.lime : color.white
    )

    // SELL SCORE
    table.cell(
         dash,
         0,
         2,
         "SELL SCORE",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         2,
         str.tostring(sellScore),
         text_color=sellScore > buyScore ? color.red : color.white
    )

    // VOLUME
    table.cell(
         dash,
         0,
         3,
         "VOLUME",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         3,
         highVol ? "HIGH" : "LOW",
         text_color=highVol ? color.orange : color.gray
    )

    // MARKET
    table.cell(
         dash,
         0,
         4,
         "MARKET",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         4,
         marketState,
         text_color=marketColor
    )

    // TREND
    table.cell(
         dash,
         0,
         5,
         "TREND",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         5,
         trendUp ? "UP" : "DOWN",
         text_color=trendUp ? color.green : color.red
    )

    // SUPERTREND
    table.cell(
         dash,
         0,
         6,
         "SUPERTREND",
         text_color=color.white
    )

    table.cell(
         dash,
         1,
         6,
         stText,
         text_color=stBull ? color.lime : color.red
    )
````
