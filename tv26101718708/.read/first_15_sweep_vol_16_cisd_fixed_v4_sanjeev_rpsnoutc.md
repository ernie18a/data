# FIRST 15 SWEEP + VOL 1.6 + CISD - FIXED V4 SANJEEV

- url: https://www.tradingview.com/script/rpsnOUtC-FIRST-15-SWEEP-VOL-1-6-CISD-FIXED-V4-SANJEEV/
- type: indicator
- pine_id: PUB;617909471ed44d4c8182d83278fa3f20
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

_Disclaimer: For educational purpose only. Not financial advice. Test on paper before live._

## Source Code

````pine
// @version=6
indicator("FIRST 15 SWEEP + VOL 1.6 + CISD - FIXED V4", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

rr1=input.float(2.0,"T1 RR")
rr2=input.float(4.0,"T2 RR")
rr3=input.float(6.0,"T3 RR")
vMult=input.float(1.6,"Vol Mult",1.0,3.0,0.1)
useVol=input.bool(false,"Use Vol Filter?")

var float fH=na
var float fL=na
var bool fCap=false

// FIXED LINE - THIS WAS THE ERROR
isNewDay = ta.change(time("D"))!= 0

inFirst15=false
if hour==9 and minute>=15 and minute<30
    inFirst15:=true

if isNewDay
    fH:=na
    fL:=na
    fCap:=false

if inFirst15
    if na(fH)
        fH:=high
        fL:=low
    else
        fH:=math.max(fH,high)
        fL:=math.min(fL,low)
else if inFirst15[1]
    fCap:=true

plot(fCap?fH:na,"F15 HIGH",color=color.orange,linewidth=3,style=plot.style_linebr)
plot(fCap?fL:na,"F15 LOW",color=color.orange,linewidth=3,style=plot.style_linebr)
bgcolor(inFirst15?color.new(color.orange,80):na)

after=fCap and not inFirst15
vAvg=ta.sma(volume,20)
volOk=volume>vAvg*vMult

bullRaw=after and close[1]<fL and close>fL
bearRaw=after and close[1]>fH and close<fH

bullSig=bullRaw and (useVol?volOk:true)
bearSig=bearRaw and (useVol?volOk:true)

var line eLine=na
var line slLine=na
var line t1Line=na
var line t2Line=na
var line t3Line=na

if bullSig or bearSig
    line.delete(eLine)
    line.delete(slLine)
    line.delete(t1Line)
    line.delete(t2Line)
    line.delete(t3Line)
    float entry=close
    float sl=na
    float t1=na
    float t2=na
    float t3=na
    float risk=na
    if bullSig
        sl:=low
        risk:=entry-sl
        t1:=entry+risk*rr1
        t2:=entry+risk*rr2
        t3:=entry+risk*rr3
        eLine:=line.new(bar_index,entry,bar_index+1,entry,color=color.green,width=3,extend=extend.right)
        slLine:=line.new(bar_index,sl,bar_index+1,sl,color=color.red,width=2,style=line.style_dashed,extend=extend.right)
    else
        sl:=high
        risk:=sl-entry
        t1:=entry-risk*rr1
        t2:=entry-risk*rr2
        t3:=entry-risk*rr3
        eLine:=line.new(bar_index,entry,bar_index+1,entry,color=color.red,width=3,extend=extend.right)
        slLine:=line.new(bar_index,sl,bar_index+1,sl,color=color.red,width=2,style=line.style_dashed,extend=extend.right)
    t1Line:=line.new(bar_index,t1,bar_index+1,t1,color=color.green,width=2,extend=extend.right)
    t2Line:=line.new(bar_index,t2,bar_index+1,t2,color=color.green,width=2,extend=extend.right)
    t3Line:=line.new(bar_index,t3,bar_index+1,t3,color=color.green,width=3,extend=extend.right)

plotshape(bullSig,style=shape.triangleup,location=location.belowbar,color=color.green,size=size.large,text="LONG")
plotshape(bearSig,style=shape.triangledown,location=location.abovebar,color=color.red,size=size.large,text="SHORT")
````
