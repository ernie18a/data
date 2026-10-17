# Adaptive S/R Box Zones with Dynamic Stop Loss & EMA Filter

- url: https://www.tradingview.com/script/H7Bfin54-Adaptive-S-R-Box-Zones-with-Dynamic-Stop-Loss-EMA-Filter/
- type: indicator
- pine_id: PUB;8fc499904da94a88bc9583fe20f1e387
- version: 2.0

## Description

Title: Adaptive S/R Box Zones with Dynamic Stop Loss & EMA Filter

Description:
This indicator is an advanced tool designed to automatically identify key Support and Resistance (S/R) levels by blending momentum, volatility, and structural pivot points. The core objective of the script is to visualize asymmetric risk zones (Stop Loss zones) and filter out false breakouts using an integrated EMA momentum filter.

How it works:
S/R Detection Logic: Levels are not derived from simple highs and lows. The script utilizes a sophisticated algorithm that dynamically combines the RSI (Relative Strength Index) to spot extreme overbought/oversold conditions, a HMA-based CMO (Chande Momentum Oscillator) for momentum confirmation, and historical Close Pivots.

Asymmetric SL Zones (Boxes): Instead of standard symmetric lines that often distort spatial risk, the indicator renders dynamic box shapes. The height of these zones automatically adapts to the market's current volatility using the ATR (Average True Range).

The Resistance Zone expands asymmetrically upward from the level, offering a clear visual map for placing Stop Losses on Short setups.

The Support Zone expands asymmetrically downward from the level, defining the logical Stop Loss area for Long setups.

EMA Momentum Filter & Trigger: The script features an optional EMA crossover filter. When enabled, the detection of a new S/R zone acts as a dynamic "setup alert", while the actual BUY or SELL signal triggers only when the price breaks through the EMA line, confirming directional momentum.

Key Features & Inputs:
Zone Height (ATR Multiplier): Controls the thickness of the risk zones based on market volatility.

S/R Timeframe: Multi-timeframe (MTF) functionality to plot higher time frame levels onto your current chart.

Signal Trigger Mode: Toggle between On Candle Close and After Candle Close (waits for the candle to seal to prevent repainting).

EMA Filter Toggle: Can be fully deactivated if you prefer to receive raw signals immediately upon the formation of S/R levels.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Aleksin_Aleksandar

//@version=6
indicator("Adaptive Support & Resistance Pro (Box SL Zones + Trigger)", shorttitle="Adaptive S/R Box Zones with Dynamic Stop Loss & EMA Filter", overlay=true, max_boxes_count=500)

// Support and Resistance Settings
zone_height_atr = input.float(1.5, title="Zone Height (ATR Multiplier)", minval=0.1, tooltip="Koliko će zona biti široka na gore/dole u ATR jedinicama za SL")
atr_length      = input.int(14, title="ATR Length for Zone Height")
sr_tf           = input.timeframe('', title='S/R Timeframe')

// Support and Resistance zone color inputs
support_color    = input.color(color.rgb(51, 63, 51, 60), title="Support Zone Color")
resistance_color = input.color(color.rgb(82, 56, 56, 60), title="Resistance Zone Color")

// Signal Settings
enableSignals    = input.bool(true, "Enable Buy/Sell Signals")
signalTrigger    = input.string("After Candle Close", "Signal Trigger Mode", options=["On Candle Close", "After Candle Close"], tooltip="Izaberi da li signal okida odmah unutar svećice ili tek nakon što se ona zatvori (potvrdi).")

// NOVI INPUTI: Boje za BUY i SELL signale (sada se menjaju i u Style tabu)
buy_signal_color  = input.color(color.rgb(22, 34, 23), title="BUY Signal Label Color")
sell_signal_color = input.color(color.rgb(32, 18, 18), title="SELL Signal Label Color")

// =====================================================================
// EMA FILTER SETTINGS
// =====================================================================
useEmaFilter = input.bool(true, "Enable EMA Filter", group="EMA Filter Settings", tooltip="Kada je uključeno, nivo priprema signal, a proboj EMA ga aktivira.")
emaLength    = input.int(10, "EMA Length", minval=1, group="EMA Filter Settings")
showEma      = input.bool(true, "Show EMA Line", group="EMA Filter Settings")
emaColor     = input.color(color.rgb(0, 0, 0), "EMA Color", group="EMA Filter Settings")

// Računanje EMA
emaVal = ta.ema(close, emaLength)
plot(showEma ? emaVal : na, title="Filter EMA", color=emaColor, linewidth=2)

// Računanje ATR-a za visinu SL zone
atrVal = ta.atr(atr_length)
zone_offset = atrVal * zone_height_atr

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

f1(float m, float n) => m >= n ? m : 0.0
f2(float m, float n) => m >= n ? 0.0 : -m

m1 = f1(momm1, momm2)
m2 = f2(momm1, momm2)

sm1 = math.sum(m1, length1)
sm2 = math.sum(m2, length1)

percent(float nom, float div) => 100 * nom / div
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

// Osnovni uslovi za S/R detekciju
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
// ZONA + EMA BREJK OKIDAČ
// =====================================================================
chg_tf1 = ta.change(tf1)
chg_tf2 = ta.change(tf2)

bool supportChanged    = not na(chg_tf1) and chg_tf1 != 0
bool resistanceChanged = not na(chg_tf2) and chg_tf2 != 0

var bool waitForBuyBreak = false
var bool waitForSellBreak = false

if supportChanged
    waitForBuyBreak := true

if resistanceChanged
    waitForSellBreak := true

buySignal = false
sellSignal = false

bool emaCrossOver  = ta.crossover(close, emaVal)
bool emaCrossUnder = ta.crossunder(close, emaVal)

bool isTriggerAllowed = signalTrigger == "After Candle Close" ? barstate.isconfirmed : true

if isTriggerAllowed
    if useEmaFilter
        if waitForBuyBreak and emaCrossOver
            buySignal := true
            waitForBuyBreak := false 
        if waitForSellBreak and emaCrossUnder
            sellSignal := true
            waitForSellBreak := false 
    else
        if waitForBuyBreak
            buySignal := true
            waitForBuyBreak := false
        if waitForSellBreak
            sellSignal := true
            waitForSellBreak := false

buySignal := enableSignals ? buySignal : false
sellSignal := enableSignals ? sellSignal : false

// =====================================================================
// S/R BOX ZONES DRAWING (Pravljenje SL zona) - KOREKCIJA
// =====================================================================

// SUPPORT BOX - Sada se širi od detektovane cene NA GORE
var box tf1_box = box.new(na, na, na, na, bgcolor=support_color, border_color=color.new(support_color, 0))
var int tf1_bi_start = 0
var int tf1_bi_end = 0

tf1_bi_start := supportChanged ? bar_index : tf1_bi_start[1]
tf1_bi_end := supportChanged ? tf1_bi_start : bar_index

if supportChanged
    // PROMENA: Support se širi na gore (od tf1 pa naviše)
    tf1_box := box.new(left=tf1_bi_start, top=tf1 + zone_offset, right=tf1_bi_end, bottom=tf1, bgcolor=support_color, border_color=color.new(support_color, 30))

if not na(tf1_box)
    box.set_right(tf1_box, tf1_bi_end)

// RESISTANCE BOX - Sada se širi od detektovane cene NA DOLE
var box tf2_box = box.new(na, na, na, na, bgcolor=resistance_color, border_color=color.new(resistance_color, 0))
var int tf2_bi_start = 0
var int tf2_bi_end = 0

tf2_bi_start := resistanceChanged ? bar_index : tf2_bi_start[1]
tf2_bi_end := resistanceChanged ? tf2_bi_start : bar_index

if resistanceChanged
    // PROMENA: Resistance se širi na dole (od tf2 pa naniže)
    tf2_box := box.new(left=tf2_bi_start, top=tf2, right=tf2_bi_end, bottom=tf2 - zone_offset, bgcolor=resistance_color, border_color=color.new(resistance_color, 30))

if not na(tf2_box)
    box.set_right(tf2_box, tf2_bi_end)

// =====================================================================
// BUY / SELL LABELS & ALERTS
// =====================================================================
plotshape(buySignal, title="BUY Signal", style=shape.labelup, location=location.belowbar, color=buy_signal_color, text="BUY", textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL Signal", style=shape.labeldown, location=location.abovebar, color=sell_signal_color, text="SELL", textcolor=color.white, size=size.small)

alertcondition(supportChanged or resistanceChanged, title="New S/R line", message="New S/R line")
alertcondition(buySignal, title="BUY Signal", message="BUY signal confirmed")
alertcondition(sellSignal, title="SELL Signal", message="SELL signal confirmed")
````
