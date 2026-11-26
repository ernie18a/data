# FIRST 15 SWEEP + VOL 1.6 + CISD Indicator SANJEEV

- url: https://www.tradingview.com/script/QybiCZuF-FIRST-15-SWEEP-VOL-1-6-CISD-Indicator-SANJEEV/
- type: indicator
- pine_id: PUB;52bd7e1f1e0b457c98c46ca2ccda3314
- version: 1.0

## Description

*FIRST 15 MIN SWEEP + VOLUME 1.6 + CISD - by Sanjeev*

This indicator is built for *NIFTY 500, 2-4% Gapping Stocks on 5-Min* - It catches the Smart Money Reversal after first 15 min liquidity grab.

*LOGIC (3 Candles Concept):*

1.  *Candle 1 (9:15-9:30 IST):* Marks First 15 Min High & Low - This is Initial Liquidity Pool (Orange Zone).
2.  *Candle 2 (Swap):* A candle closes OUTSIDE the first 15 zone - Bullish close above High or Bearish close below Low. This is Stop Hunt setup.
3.  *Candle 3 (Sweep + CISD):* Next candle sweeps Candle 2's high/low (makes a new high/low) but *closes BACK INSIDE* the First 15 Zone. This is Liquidity Sweep + Hammer / Inverted Hammer.

*MERGED FILTERS for Accuracy (Why this is different):*

- *Volume Spurt 1.6x:* Candle 3 volume must be > 1.6x of 20 SMA Volume. No volume = No Smart Money = No Trade.
- *CISD (Change In State of Delivery):* Candle 3 must break previous candle's high/low with strong close. This confirms Buyer/Seller dominance.
- *Auto Levels:* Entry = Candle 3 Close, SL = Candle 3 High/Low, Targets = 1:2, 1:4, 1:6 RR (customizable).

*HOW TO USE:*

1.  Set chart to *5-Min, NSE Stocks*
2.  At 9:30 AM, indicator will plot Orange High/Low.
3.  Wait for *LONG* or *SHORT* label after 9:30. Only take trades with volume confirmation.
4.  Entry at label close, SL at wick, Book T1 at 1:2, trail to T2 & T3.
5.  For your workflow: Use it only on pre-market 2-4% movers list.

*SETTINGS:*
- Vol Mult: Keep 1.6 (increase to 1.8 for less signals)
- Use CISD ON for high accuracy
- RR: Default 2, 4, 6 - Change as per your risk

*Best For:* Intraday reversal, Opening Liquidity Grab, BankNifty & Midcap volatile stocks. Avoid on flat news-less days.

_Disclaimer: For educational purpose only. Not financial advice. Test on paper before live

## Source Code

````pine
// @version=6
indicator("FIRST 15 SWEEP + VOL 1.6 + CISD FINAL", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

rr1 = input.float(2.0, "T1 RR", 0.5, 10.0, 0.5)
rr2 = input.float(4.0, "T2 RR", 0.5, 10.0, 0.5)
rr3 = input.float(6.0, "T3 RR", 0.5, 10.0, 0.5)
vMult = input.float(1.6, "Vol Mult", 1.1, 3.0, 0.1)
useVol = input.bool(true, "Use Vol 1.6?")
useCISD = input.bool(true, "Use CISD?")

var float fH = na
var float fL = na
var bool fCap = false
var int fBar = na
bool newDay = ta.change(time("D"))!= 0
bool in15 = not na(time(timeframe.period, "0915-0930", "Asia/Kolkata"))
if newDay
    fCap := false
    fH := na
    fL := na
    fBar := na
if in15 and not in15[1]
    fH := high
    fL := low
else if in15
    fH := math.max(fH, high)
    fL := math.min(fL, low)
if not in15 and in15[1]
    fCap := true
    fBar := bar_index

plot(fCap? fH : na, "F15 High", color=color.orange, style=plot.style_linebr, linewidth=2)
plot(fCap? fL : na, "F15 Low", color=color.orange, style=plot.style_linebr, linewidth=2)

vAvg = ta.sma(volume, 20)
bool vUp = volume > vAvg * vMult and volume > volume[1]
bool vDn = volume > vAvg * vMult and volume > volume[1]
bool cBull = close > high[1]
bool cBear = close < low[1]

bool after = fCap and bar_index > fBar
bool rawBull = false
bool rawBear = false
if after
    rawBull := close[1] < fL and low < low[1] and close > fL
    rawBear := close[1] > fH and high > high[1] and close < fH

bool bullSig = rawBull and (useVol? vUp : true) and (useCISD? cBull : true)
bool bearSig = rawBear and (useVol? vDn : true) and (useCISD? cBear : true)

var float eP = na
var float slP = na
var float t1P = na
var float t2P = na
var float t3P = na
var line eL = na
var line slL = na
var line t1L = na
var line t2L = na
var line t3L = na

if bullSig or bearSig
    line.delete(eL)
    line.delete(slL)
    line.delete(t1L)
    line.delete(t2L)
    line.delete(t3L)
    eP := close
    float risk = na
    if bullSig
        slP := low
        risk := eP - slP
        t1P := eP + risk * rr1
        t2P := eP + risk * rr2
        t3P := eP + risk * rr3
        eL := line.new(bar_index, eP, bar_index+1, eP, color=color.green, width=2, extend=extend.right)
        slL := line.new(bar_index, slP, bar_index+1, slP, color=color.red, style=line.style_dashed, extend=extend.right)
    else
        slP := high
        risk := slP - eP
        t1P := eP - risk * rr1
        t2P := eP - risk * rr2
        t3P := eP - risk * rr3
        eL := line.new(bar_index, eP, bar_index+1, eP, color=color.red, width=2, extend=extend.right)
        slL := line.new(bar_index, slP, bar_index+1, slP, color=color.red, style=line.style_dashed, extend=extend.right)
    t1L := line.new(bar_index, t1P, bar_index+1, t1P, color=color.green, width=1, extend=extend.right)
    t2L := line.new(bar_index, t2P, bar_index+1, t2P, color=color.green, width=2, extend=extend.right)
    t3L := line.new(bar_index, t3P, bar_index+1, t3P, color=color.green, width=3, extend=extend.right)

plotshape(bullSig, "LONG", style=shape.labelup, location=location.belowbar, color=color.new(color.green,0), text="LONG", size=size.small)
plotshape(bearSig, "SHORT", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,0), text="SHORT", size=size.small)
alertcondition(bullSig, "LONG", "LONG VOL+CISD")
alertcondition(bearSig, "SHORT", "SHORT VOL+CISD")
````
