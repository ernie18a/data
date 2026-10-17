# Simple Sweep CISD Signal by zmos

- url: https://www.tradingview.com/script/DGTYYbpJ-Simple-Sweep-CISD-Signal-by-zmos/
- type: indicator
- pine_id: PUB;dea80340cf954e51ac1dbb210ac1888d
- version: 1.0

## Description

Simple Sweep CISD Signal
Identifies high-probability BUY and SELL opportunities using EMA 200 trend direction, liquidity sweeps, and CISD confirmation. Includes ATR-based filters, automatic Entry, Stop Loss, TP levels, and real-time TradingView alerts. Optimized for Gold (XAUUSD) and Nasdaq (US100/NAS100) on the 5-minute timeframe.

## Source Code

````pine
//@version=5
indicator("Simple Sweep CISD Signal", overlay=true, max_labels_count=50, max_lines_count=20)

// ============================================================
// INPUTS
// ============================================================

emaLen       = input.int(200,   "EMA Length",                        group="Trend Filter")
emaDistATR   = input.float(0.3, "Distance minimale EMA (en ATR)",    step=0.1, group="Trend Filter")
liqLookback  = input.int(10,    "Liquidity Lookback (bougies)",      minval=3, maxval=50, group="Sweep Settings")
atrLen       = input.int(14,    "ATR Length",                        group="ATR Settings")
maxCandleATR = input.float(1.5, "Taille max bougie confirmation (ATR)", step=0.1, group="ATR Settings")
rr1          = input.float(1.5, "Risk Reward TP1", step=0.1,         group="Risk Management")
rr2          = input.float(2.0, "Risk Reward TP2", step=0.1,         group="Risk Management")
useSession   = input.bool(true, "Activer filtre de session",         group="Session Filter")
sessionChoice = input.string("London + NY", "Session active",
                 options=["London", "New York", "London + NY"],      group="Session Filter")
showEma      = input.bool(true, "Afficher EMA 200",                  group="Display")

// ============================================================
// CALCULS DE BASE
// ============================================================

ema200 = ta.ema(close, emaLen)
atr    = ta.atr(atrLen)

// Filtre session (UTC)
londonSession = (hour >= 7  and hour < 16)
nySession     = (hour >= 13 and hour < 22)
sessionOK = not useSession ? true :
             sessionChoice == "London"   ? londonSession :
             sessionChoice == "New York" ? nySession :
             (londonSession or nySession)

// ============================================================
// DÉTECTION DU SWEEP
// ============================================================

recentLow  = ta.lowest(low,   liqLookback)[1]
recentHigh = ta.highest(high, liqLookback)[1]

// Sweep bullish : wick casse sous recentLow, corps clôture au-dessus
bullSweep = (low < recentLow) and (close > recentLow)

// Sweep bearish : wick casse au-dessus de recentHigh, corps clôture en-dessous
bearSweep = (high > recentHigh) and (close < recentHigh)

// ============================================================
// ÉTAT DU SWEEP EN ATTENTE (persistant entre bougies)
// ============================================================

var float sweepHighBull = na
var float sweepLowBear  = na
var bool  pendingBull   = false
var bool  pendingBear   = false

if bullSweep
    sweepHighBull := high
    pendingBull   := true
    pendingBear   := false
    sweepLowBear  := na

if bearSweep
    sweepLowBear  := low
    pendingBear   := true
    pendingBull   := false
    sweepHighBull := na

// ============================================================
// CONFIRMATION CISD
// ============================================================

candleSize = high - low

// CISD Bullish : bougie suivant le sweep clôture au-dessus du high du sweep
cisdBull = pendingBull[1]
         and not na(sweepHighBull[1])
         and (close > sweepHighBull[1])
         and (candleSize <= maxCandleATR * atr)
         and (close > ema200)
         and ((close - ema200) >= emaDistATR * atr)
         and sessionOK

// CISD Bearish : bougie suivant le sweep clôture en-dessous du low du sweep
cisdBear = pendingBear[1]
         and not na(sweepLowBear[1])
         and (close < sweepLowBear[1])
         and (candleSize <= maxCandleATR * atr)
         and (close < ema200)
         and ((ema200 - close) >= emaDistATR * atr)
         and sessionOK

// Reset après confirmation
if cisdBull
    pendingBull   := false
    sweepHighBull := na

if cisdBear
    pendingBear  := false
    sweepLowBear := na

// ============================================================
// CALCUL SL / TP
// ============================================================

buyEntry = close
buySL    = math.min(low, low[1]) - atr * 0.1
buyTP1   = buyEntry + (buyEntry - buySL) * rr1
buyTP2   = buyEntry + (buyEntry - buySL) * rr2

sellEntry = close
sellSL    = math.max(high, high[1]) + atr * 0.1
sellTP1   = sellEntry - (sellSL - sellEntry) * rr1
sellTP2   = sellEntry - (sellSL - sellEntry) * rr2

// ============================================================
// AFFICHAGE EMA
// ============================================================

plot(showEma ? ema200 : na, "EMA 200", color=color.new(color.orange, 0), linewidth=2)

// ============================================================
// LABELS SIGNAUX
// ============================================================

if cisdBull
    label.new(bar_index, low - atr * 0.5,
     text="▲ BUY",
     color=color.new(color.lime, 0),
     textcolor=color.white,
     style=label.style_label_up,
     size=size.normal)

if cisdBear
    label.new(bar_index, high + atr * 0.5,
     text="▼ SELL",
     color=color.new(color.red, 0),
     textcolor=color.white,
     style=label.style_label_down,
     size=size.normal)

// ============================================================
// LIGNES ENTRY / SL / TP1 / TP2 (dernier signal uniquement)
// ============================================================

var line lineEntry = na
var line lineSL    = na
var line lineTP1   = na
var line lineTP2   = na

deleteLine(ln) =>
    if not na(ln)
        line.delete(ln)

if cisdBull
    deleteLine(lineEntry)
    deleteLine(lineSL)
    deleteLine(lineTP1)
    deleteLine(lineTP2)
    lineEntry := line.new(bar_index, buyEntry, bar_index + 20, buyEntry,
                  color=color.white,  style=line.style_dashed, width=1)
    lineSL    := line.new(bar_index, buySL,    bar_index + 20, buySL,
                  color=color.red,    style=line.style_solid,  width=1)
    lineTP1   := line.new(bar_index, buyTP1,   bar_index + 20, buyTP1,
                  color=color.lime,   style=line.style_dotted, width=1)
    lineTP2   := line.new(bar_index, buyTP2,   bar_index + 20, buyTP2,
                  color=color.teal,   style=line.style_dotted, width=1)

if cisdBear
    deleteLine(lineEntry)
    deleteLine(lineSL)
    deleteLine(lineTP1)
    deleteLine(lineTP2)
    lineEntry := line.new(bar_index, sellEntry, bar_index + 20, sellEntry,
                  color=color.white,  style=line.style_dashed, width=1)
    lineSL    := line.new(bar_index, sellSL,    bar_index + 20, sellSL,
                  color=color.red,    style=line.style_solid,  width=1)
    lineTP1   := line.new(bar_index, sellTP1,   bar_index + 20, sellTP1,
                  color=color.lime,   style=line.style_dotted, width=1)
    lineTP2   := line.new(bar_index, sellTP2,   bar_index + 20, sellTP2,
                  color=color.teal,   style=line.style_dotted, width=1)

// ============================================================
// ALERTES
// ============================================================

alertcondition(cisdBull, "🟢 CISD BUY Signal",  "Simple Sweep CISD — Signal BUY détecté.")
alertcondition(cisdBear, "🔴 CISD SELL Signal", "Simple Sweep CISD — Signal SELL détecté.")
````
