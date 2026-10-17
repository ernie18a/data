# F-GEM Trend & Momentum System

- url: https://www.tradingview.com/script/stEhguJH/
- type: indicator
- pine_id: PUB;3830eedd604b4994b3243b4a56c6ca07
- version: 1.0

## Description

[b]Description:[/b]
This indicator is the official algorithmic representation of the Flashwave ELITE trading module. Built for disciplined traders, it eliminates market noise and focuses purely on high-probability trend continuation setups based on Jesse Livermore's "Line of Least Resistance" logic.  
The system relies on a strict combination of Moving Averages, Market Structure, and Price Action to identify precise entry points.  

⚙️ [b]Core Mechanics:[/b]
#Directional Filter (EMA 100 - White Line): Determines the macro trend. We only look for LONGs when the price and EMA 20 are above a rising EMA 100. We only look for SHORTs when they are below a falling EMA 100.  

#Momentum Trigger (EMA 20 - Blue Line): Identifies the pullback zone. The script waits for the price to retest the EMA 20 to ensure we enter with momentum.  

#Pivotal Point Structure: Uses algorithmic pivot highs and lows to map local structure and identify the boundaries of recent corrections.  

#Price Action Confirmation: Triggers a signal ONLY when a valid reversal candle (Engulfing, Pin Bar, or Hammer) closes beyond the established Pivotal Point. The market must prove its strength before entry.  

🚀 How to Read the Signals:Green Triangle (LONG): Printed below the bar when a bullish pullback completes and breaks the local Pivotal Point, perfectly aligned with the rising EMA 100 trend.  Red Triangle (SHORT): Printed above the bar when a bearish pullback completes and breaks the local Pivotal Point, perfectly aligned with the falling EMA 100 trend.  

⚠️ [b]F-GEM Pro Tips & Risk Management:[/b]

This indicator is a powerful tool, but it requires strict human execution:Avoid Consolidation : If the EMA 100 is flat and the EMA 20 crosses it chaotically, IGNORE THE SIGNALS. The system dictates: Zero trades = Zero losses. You do not trade if the market does not give you an edge.  Risk to Reward (RR): The core philosophy of Flashwave ELITE demands a minimum RR of 1:2 or 1:3
Set your Stop Loss tightly behind the entry candle and your Take Profit strictly at 1:3 
Never close a position purely based on emotions.  
Patience is profit. Let the market prove its direction.

## Source Code

````pine
//@version=6
indicator("Flashwave ELITE - F-GEM Signals", overlay=true)

// 1. USTAWIENIA TECHNICZNE
ema100 = ta.ema(close, 100)
ema20 = ta.ema(close, 20)

plot(ema100, color=color.white, title="EMA 100 (Kierunek)", linewidth=2)
plot(ema20, color=color.blue, title="EMA 20 (Momentum)", linewidth=2)

// 2. FILTR KIERUNKU (LOGIKA LIVERMORE'A)
longTrend = ema100 > ema100[1] and close > ema100 and ema20 > ema100
shortTrend = ema100 < ema100[1] and close < ema100 and ema20 < ema100

// 3. ROZPOZNAWANIE ŚWIEC WEJŚCIOWYCH (ENG / PIN / HAMMER)
// Formacje Bullish (Dla wejść LONG)
bullishEngulfing = close > open and close[1] < open[1] and close > open[1] and open <= close[1]
bullishPinBar = (close > open ? (open - low) : (close - low)) > 2 * math.abs(close - open) and (high - (close > open ? close : open)) < math.abs(close - open)

// Formacje Bearish (Dla wejść SHORT)
bearishEngulfing = close < open and close[1] > open[1] and close < open[1] and open >= close[1]
bearishPinBar = (high - (close > open ? close : open)) > 2 * math.abs(close - open) and ((close > open ? open : close) - low) < math.abs(close - open)

bullishCandle = bullishEngulfing or bullishPinBar
bearishCandle = bearishEngulfing or bearishPinBar

// 4. PIVOTAL POINT - ALGORYTMICZNE WYZNACZANIE STRUKTURY
leftBars = 5
rightBars = 5
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float lastPivotHigh = na
var float lastPivotLow = na

if not na(ph)
    lastPivotHigh := ph
if not na(pl)
    lastPivotLow := pl

// 5. TRIGGER WEJŚCIA (CHECKLISTA F-GEM)
// Warunek LONG: Trend rosnący, cena dotyka/zbliża się do EMA 20, świeca popytowa, zamknięcie powyżej ostatniego Pivota.
longCondition = longTrend and ta.lowest(low, 3) <= ema20 and bullishCandle and close > lastPivotHigh

// Warunek SHORT: Trend malejący, cena dotyka/zbliża się do EMA 20, świeca podażowa, zamknięcie poniżej ostatniego Pivota.
shortCondition = shortTrend and ta.highest(high, 3) >= ema20 and bearishCandle and close < lastPivotLow

// 6. WIZUALIZACJA SYGNAŁÓW
plotshape(series=longCondition, title="Wejście LONG", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.normal, text="LONG")
plotshape(series=shortCondition, title="Wejście SHORT", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.normal, text="SHORT")
````
