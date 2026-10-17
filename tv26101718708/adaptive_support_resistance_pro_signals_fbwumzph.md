# Adaptive Support & Resistance Pro + Signals

- url: https://www.tradingview.com/script/fbWUmZpH-Adaptive-Support-Resistance-Pro-Signals/
- type: indicator
- pine_id: PUB;c4b2112f24294c218940c48f03442901
- version: 1.0

## Description

Overview 

Adaptive Support & Resistance Pro is a dynamic technical analysis tool designed to automatically identify, calculate, and plot key Support and Resistance (S/R) levels on your chart. Unlike traditional pivot-based indicators, this script uses a hybrid approach combining Momentum, Relative Strength, and Volatility filters to pinpoint institutional supply and demand zones.
To ensure professional-grade execution, the script is fully optimized to prevent repainting. It operates strictly in real-time, aligning historical signals with the exact moments these key levels were formed.

How It Works (The Engine)
The indicator calculates its levels based on three core components:

Chande Momentum Oscillator (CMO) via HMA: It analyzes the rate of change between two Hull Moving Averages (HMA) of different periods to detect strong shifts in market momentum.

Relative Strength Index (RSI): A 9-period RSI filters out minor market noise, ensuring that support levels are only tracked in oversold conditions ([symbol="NYSE:RSI"]NYSE:RSI[/symbol] < 25$) and resistance levels in overbought conditions ([symbol="NYSE:RSI"]NYSE:RSI[/symbol] > 75$).

Legacy Close Pivots: The script analyzes extreme high/low deviations over a specific lookback period to establish the structural price floor or ceiling.

When all three conditions align, a new Support or Resistance price level is established.

Key Features & Settings

Multi-Timeframe (S/R Timeframe): You can plot S/R levels from higher timeframes (e.g., Daily or 4-Hour) directly onto your lower timeframe execution chart (e.g., 15-minute) for top-down analysis.

Signal Trigger Modes: Under the settings, you can choose how signals are displayed:
   On Candle Close: Displays a BUY or SELL label immediately on the candle that confirmed the new level.
    After Candle Close: Waits for the confirmation candle to close and prints the signal on the next candle, providing an extra layer of validation.

Strict One Signal Per Level Rule: The script features built-in logic that guarantees only one signal will ever be triggered per new structural level, completely eliminating label clutter and overlapping signals.

How to Use It (Trading Strategy)

Support & BUY Signals: Look for green BUY labels after the market prints a fresh support line. This indicates that momentum has shifted upwards from an oversold structural area.

Resistance & SELL Signals: Look for red SELL labels when price prints a fresh resistance line. This indicates institutional selling pressure in an overbought area.

Breakouts & Re-tests: The drawn lines stay on the chart, allowing you to monitor future re-tests of these adaptive zones.

Disclaimer

Past performance does not guarantee future results. This indicator is meant to be used as a supportive tool alongside your own risk management and trading plan.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Aleksin_Aleksandar

//@version=6
indicator("Adaptive Support & Resistance Pro + Signals", shorttitle="Adaptive Support & Resistance Pro + Signals", overlay=true, max_lines_count=500)

// Support and Resistance
line_width = input.int(15, title="Line Width", minval=1, maxval=100)
sr_tf = input.timeframe('', title='S/R Timeframe')

// Support and Resistance line color inputs
support_color = input.color(color.rgb(51, 70, 52), title="Support Line Color")
resistance_color = input.color(color.rgb(87, 62, 62), title="Resistance Line Color")

// Signal Settings
enableSignals = input.bool(true, "Enable Buy/Sell Signals")
signalTrigger = input.string("After Candle Close", "Signal Trigger Mode", options=["On Candle Close", "After Candle Close"], tooltip="On Candle Close okida signal odmah na svećici koja je napravila nivo. After Candle Close čeka da se zatvori i prva sledeća svećica.")

// Legacy RSI calc
rsi_src = close
len = 9
up1 = ta.rma(math.max(ta.change(rsi_src), 0), len)
down1 = ta.rma(-math.min(ta.change(rsi_src), 0), len)
legacy_rsi = down1 == 0 ? 100 : up1 == 0 ? 0 : 100 - 100 / (1 + up1 / down1)

// CMO based on HMA
length1 = 1
src1 = ta.hma(open, 5)[1]
src2 = ta.hma(close, 12)

momm1 = ta.change(src1)
momm2 = ta.change(src2)

f1(float m, float n) =>
    m >= n ? m : 0.0

f2(float m, float n) =>
    m >= n ? 0.0 : -m

m1 = f1(momm1, momm2)
m2 = f2(momm1, momm2)

sm1 = math.sum(m1, length1)
sm2 = math.sum(m2, length1)

percent(float nom, float div) =>
    100 * nom / div

cmo_new = percent(sm1 - sm2, sm1 + sm2)

// Legacy Close Pivots calcs - Popravljeno za v6 pomoću ta.valuewhen
len5 = 2

h = ta.highest(len5)
h1 = ta.dev(h, len5) != 0.0 ? na : h
hpivot = ta.valuewhen(not na(h1), h1, 0)

l = ta.lowest(len5)
l1 = ta.dev(l, len5) != 0.0 ? na : l
lpivot = ta.valuewhen(not na(l1), l1, 0)

// Calc Values
rsi_new = ta.rsi(close, 9)
lpivot_new = lpivot
hpivot_new = hpivot

// Osnovni uslovi za S/R detekciju na trenutnom grafikonu
sup_condition = rsi_new < 25 and cmo_new > 50 and not na(lpivot_new)
res_condition = rsi_new > 75 and cmo_new < -50 and not na(hpivot_new)

calcXup() =>
    var float xup = 0.0
    xup := sup_condition ? low : xup[1]
    xup

calcXdown() =>
    var float xdown = 0.0
    xdown := res_condition ? high : xdown[1]
    xdown

// Lines drawing variables (Bez lookahead-a da bi se sprečilo repainting i pomeranje signala unazad)
tf1 = request.security(syminfo.tickerid, sr_tf, calcXup(), barmerge.gaps_off, barmerge.lookahead_off)
tf2 = request.security(syminfo.tickerid, sr_tf, calcXdown(), barmerge.gaps_off, barmerge.lookahead_off)

// =====================================================================
// SIGNAL LOGIC - STRIKTNO JEDAN SIGNAL PO NIVOU
// =====================================================================

// Definisano kao čist bool kako bi radilo ispravno u logičkim uslovima i alertima
bool supportChanged = not na(ta.change(tf1)) and ta.change(tf1) != 0
bool resistanceChanged = not na(ta.change(tf2)) and ta.change(tf2) != 0

newSupport = supportChanged
newResistance = resistanceChanged

var bool triggerBuy = false
var bool triggerSell = false

// Detekcija kada se nivo promeni/stvori
if newSupport
    triggerBuy := true

if newResistance
    triggerSell := true

buySignal = false
sellSignal = false

// Provera za zatvaranje svećice u zavisnosti od izabrane opcije
if barstate.isconfirmed
    if signalTrigger == "On Candle Close"
        if triggerBuy
            buySignal := true
            triggerBuy := false
        if triggerSell
            sellSignal := true
            triggerSell := false
    else // "After Candle Close"
        // Prva svećica detektuje nivo (trigger postaje true), na sledećoj zatvorenoj svećici dajemo signal
        if triggerBuy and not newSupport
            buySignal := true
            triggerBuy := false
        if triggerSell and not newResistance
            sellSignal := true
            triggerSell := false

// Isključi signale ako su deaktivirani u inputima
buySignal := enableSignals ? buySignal : false
sellSignal := enableSignals ? sellSignal : false

// =====================================================================
// SR Line plotting
// =====================================================================

var line tf1_line = line.new(na, na, na, na)
var int tf1_bi_start = 0
var int tf1_bi_end = 0

// Ispravljeni ternarni operatori (?:) da proveravaju bool vrednost, a ne direktno numeričku promenu
tf1_bi_start := supportChanged ? bar_index : tf1_bi_start[1]
tf1_bi_end := supportChanged ? tf1_bi_start : bar_index

if supportChanged
    tf1_line := line.new(
         tf1_bi_start,
         tf1,
         tf1_bi_end,
         tf1,
         color=support_color,
         width=line_width)

line.set_x2(tf1_line, tf1_bi_end)

var line tf2_line = line.new(na, na, na, na)
var int tf2_bi_start = 0
var int tf2_bi_end = 0

tf2_bi_start := resistanceChanged ? bar_index : tf2_bi_start[1]
tf2_bi_end := resistanceChanged ? tf2_bi_start : bar_index

if resistanceChanged
    tf2_line := line.new(
         tf2_bi_start,
         tf2,
         tf2_bi_end,
         tf2,
         color=resistance_color,
         width=line_width)

line.set_x2(tf2_line, tf2_bi_end)

// =====================================================================
// BUY / SELL LABELS
// =====================================================================

plotshape(
     buySignal,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.rgb(35, 51, 36),
     text="BUY",
     textcolor=color.white,
     size=size.small)

plotshape(
     sellSignal,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.rgb(56, 32, 32),
     text="SELL",
     textcolor=color.white,
     size=size.small)

// =====================================================================
// ALERTS
// =====================================================================

// Korišćenje unapred definisanih globalnih bool varijabli rešava v6 Warning
alertcondition(
     supportChanged or resistanceChanged,
     title="New S/R line",
     message="New S/R line")

alertcondition(
     buySignal,
     title="BUY Signal",
     message="BUY signal triggered based on Support level")

alertcondition(
     sellSignal,
     title="SELL Signal",
     message="SELL signal triggered based on Resistance level")
````
