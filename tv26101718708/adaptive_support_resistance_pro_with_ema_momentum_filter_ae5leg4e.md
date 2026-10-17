# Adaptive Support & Resistance Pro with EMA Momentum Filter

- url: https://www.tradingview.com/script/aE5LeG4E-Adaptive-Support-Resistance-Pro-with-EMA-Momentum-Filter/
- type: indicator
- pine_id: PUB;1f638bcb4dcb48ce87db81c89cabff65
- version: 1.0

## Description

## Description
This indicator is an advanced tool designed to identify adaptive Support and Resistance (S/R) zones and combine them with an Exponential Moving Average (EMA) momentum filter. Unlike static S/R lines, this script uses a combination of momentum oscillators and dynamic pivot calculations to find high-probability reversal zones on higher or current timeframes.

The core philosophy of this indicator is to prevent "knife-catching." Instead of firing a signal immediately when a support or resistance level is formed, it waits for the price to confirm a change in momentum by crossing the EMA line in the direction of the trade.

---

## How It Works (Under the Hood)

### 1. Support & Resistance Detection
The script uses a multi-layered filter to detect true pivot points:
* **Legacy RSI & Modified RSI:** It evaluates overbought (>75) and oversold (<25) conditions using a 9-period Relative Strength Index.
* **Chande Momentum Oscillator (CMO) based on HMA:** It applies a 1-period CMO logic over Hull Moving Averages (HMA 5 and HMA 12) to detect immediate shifts in market velocity.
* **Close Pivots:** It uses deviation-free highest/lowest calculations (`ta.highest` and `ta.lowest`) combined with `ta.valuewhen` to fetch precise structural levels.

A **Support Zone** is formed only when the RSI is oversold, the CMO shows an upward momentum shift (>50), and a local low pivot is confirmed. 
A **Resistance Zone** is formed when the RSI is overbought, the CMO shows a downward shift (<-50), and a local high pivot is confirmed.

### 2. S/R Timeframe Flexibility
Through the `request.security` function, users can plot these adaptive levels from higher timeframes (HTF) onto their current chart. To prevent **repainting** and back-shifting signals, the script strictly uses `barmerge.lookahead_off`.

### 3. EMA Momentum Trigger (The Confirmation Filter)
To filter out false breakouts and premature entries during heavy trend extensions, an EMA filter is introduced:
* **BUY Signal:** Triggered only when a new Support level has been established AND the price successfully closes above the EMA (`ta.crossover`).
* **SELL Signal:** Triggered only when a new Resistance level has been established AND the price successfully closes below the EMA (`ta.crossunder`).

**Strict Discipline:** The script uses an internal state machine (`waitForBuyBreak` / `waitForSellBreak`) ensuring that **only ONE signal** is fired per newly created S/R level. This completely eliminates the "whipsaw" effect (multiple false signals) when the price is consolidating or chopping around the moving average.

---

## Settings & Customization

* **Line Width / Colors:** Fully customize the visual thickness and color styling of your Support and Resistance zones.
* **S/R Timeframe:** Leave it blank for the current chart timeframe, or select higher timeframes (e.g., 4H or 1D) for macro level analysis.
* **Enable EMA Filter:** Toggle this option ON to use the momentum confirmation logic, or OFF to see signals immediately upon S/R level creation.
* **EMA Length:** Adjust the period of the confirmation line (Default is 50, but can be set to 20 for faster entries or 200 for macro trend-following).

---

## Alerts
The script includes three built-in alert conditions for automation:
1. `New S/R line` - Triggers whenever a new support or resistance level is plotted.
2. `BUY Signal` - Triggers when the EMA crossover confirms the support bounce.
3. `SELL Signal` - Triggers when the EMA crossunder confirms the resistance rejection.

## Disclaimer
This indicator is meant for educational and analytical purposes only. Past performance does not guarantee future results. Always practice proper risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Aleksin_Aleksandar

//@version=6
indicator("Adaptive Support & Resistance Pro with EMA Momentum Filter", shorttitle="Adaptive Support & Resistance Pro + Signals + EMA", overlay=true, max_lines_count=500)

// Support and Resistance
line_width = input.int(15, title="Line Width", minval=1, maxval=100)
sr_tf = input.timeframe('', title='S/R Timeframe')

// Support and Resistance line color inputs
support_color = input.color(color.rgb(51, 63, 51), title="Support Line Color")
resistance_color = input.color(color.rgb(82, 56, 56), title="Resistance Line Color")

// Signal Settings
enableSignals = input.bool(true, "Enable Buy/Sell Signals")

// =====================================================================
// EMA FILTER SETTINGS
// =====================================================================
useEmaFilter = input.bool(true, "Enable EMA Filter", group="EMA Filter Settings", tooltip="Kada je uključeno, nivo priprema signal, a proboj EMA ga aktivira.")
emaLength    = input.int(10, "EMA Length", minval=1, group="EMA Filter Settings", tooltip="Možeš smanjiti na 50 ili 20 za brže reakcije na manjim TF")
showEma      = input.bool(true, "Show EMA Line", group="EMA Filter Settings")
emaColor     = input.color(color.rgb(0, 0, 0), "EMA Color", group="EMA Filter Settings")

// Računanje EMA
emaVal = ta.ema(close, emaLength)
plot(showEma ? emaVal : na, title="Filter EMA", color=emaColor, linewidth=2)

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

// Legacy Close Pivots calcs
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

// Lines drawing variables
tf1 = request.security(syminfo.tickerid, sr_tf, calcXup(), barmerge.gaps_off, barmerge.lookahead_off)
tf2 = request.security(syminfo.tickerid, sr_tf, calcXdown(), barmerge.gaps_off, barmerge.lookahead_off)

// =====================================================================
// NOVA LOGIKA: ZONA + EMA BREJK OKIDAČ
// =====================================================================

bool supportChanged = not na(ta.change(tf1)) and ta.change(tf1) != 0
bool resistanceChanged = not na(ta.change(tf2)) and ta.change(tf2) != 0

// Var labele koje pamte stanje da li čekamo brejk za trenutnu zonu
var bool waitForBuyBreak = false
var bool waitForSellBreak = false

if supportChanged
    waitForBuyBreak := true

if resistanceChanged
    waitForSellBreak := true

buySignal = false
sellSignal = false

// Detekcija probijanja EMA linije
bool emaCrossOver  = ta.crossover(close, emaVal)
bool emaCrossUnder = ta.crossunder(close, emaVal)

if barstate.isconfirmed
    if useEmaFilter
        // BUY: Ako je zona aktivirana i imamo presek cene iznad EMA
        if waitForBuyBreak and emaCrossOver
            buySignal := true
            waitForBuyBreak := false // Isključi dok se ne stvori nova zona
            
        // SELL: Ako je zona aktivirana i imamo presek cene ispod EMA
        if waitForSellBreak and emaCrossUnder
            sellSignal := true
            waitForSellBreak := false // Isključi dok se ne stvori nova zona
    else
        // Ako je filter isključen, ponaša se standardno na formiranje nivoa
        if waitForBuyBreak
            buySignal := true
            waitForBuyBreak := false
        if waitForSellBreak
            sellSignal := true
            waitForSellBreak := false

// Isključi signale ako su deaktivirani u inputima
buySignal := enableSignals ? buySignal : false
sellSignal := enableSignals ? sellSignal : false

// =====================================================================
// SR Line plotting
// =====================================================================

var line tf1_line = line.new(na, na, na, na)
var int tf1_bi_start = 0
var int tf1_bi_end = 0

tf1_bi_start := supportChanged ? bar_index : tf1_bi_start[1]
tf1_bi_end := supportChanged ? tf1_bi_start : bar_index

if supportChanged
    tf1_line := line.new(tf1_bi_start, tf1, tf1_bi_end, tf1, color=support_color, width=line_width)

line.set_x2(tf1_line, tf1_bi_end)

var line tf2_line = line.new(na, na, na, na)
var int tf2_bi_start = 0
var int tf2_bi_end = 0

tf2_bi_start := resistanceChanged ? bar_index : tf2_bi_start[1]
tf2_bi_end := resistanceChanged ? tf2_bi_start : bar_index

if resistanceChanged
    tf2_line := line.new(tf2_bi_start, tf2, tf2_bi_end, tf2, color=resistance_color, width=line_width)

line.set_x2(tf2_line, tf2_bi_end)

// =====================================================================
// BUY / SELL LABELS
// =====================================================================

plotshape(buySignal, title="BUY Signal", style=shape.labelup, location=location.belowbar, color=color.rgb(22, 34, 23), text="BUY", textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL Signal", style=shape.labeldown, location=location.abovebar, color=color.rgb(32, 18, 18), text="SELL", textcolor=color.white, size=size.small)

// =====================================================================
// ALERTS
// =====================================================================

alertcondition(supportChanged or resistanceChanged, title="New S/R line", message="New S/R line")
alertcondition(buySignal, title="BUY Signal", message="BUY signal (EMA Break confirmed)")
alertcondition(sellSignal, title="SELL Signal", message="SELL signal (EMA Break confirmed)")
````
