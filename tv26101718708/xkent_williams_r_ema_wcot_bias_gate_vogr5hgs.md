# xKen-t Williams %R + EMA w/COT Bias Gate

- url: https://www.tradingview.com/script/voGR5hGs-xKen-t-Williams-R-EMA-w-COT-Bias-Gate/
- type: indicator
- pine_id: PUB;6ec0b85ac9934702a44341002e2916cd
- version: 1.0

## Description

[b]What's original here
[/b]
This isn't a Williams %R repaint. Standard %R gives a level; this script converts it into a filtered, context-aware timing engine through four combined mechanisms: (1) exit-from-extreme triggers that fire when %R crosses back out of −80/−20 rather than when it reaches them, so signals mark the reversal instead of the ongoing move; (2) EMA-side confirmation that validates the exit against the 13-EMA; (3) a −50 regime filter that blocks counter-regime signals; and (4) a directional-bias gate that normalizes any external series you feed it (e.g. a COT commercial-net line) to a 0–100 position-in-range index and suppresses every signal that disagrees with that bias. The gate is the core idea — it makes the oscillator time entries only in a separately chosen direction, turning a reversal oscillator into a with-context pullback tool. A status table surfaces %R, its EMA, the regime, the active bias, the higher-timeframe read, and the last signal in one place.

Overview
A Williams %R momentum tool rebuilt around three ideas: it signals on the exit from an extreme rather than the touch, confirms that exit with the %R/EMA relationship, and can gate every signal by an external directional bias (such as Commitments of Traders positioning) so only signals agreeing with that bias are shown. This targets the two classic Williams %R weaknesses — catching falling knives at the band, and firing endless counter-trend reversals during strong trends.
What it calculates

[b]- Williams %R (default 21):[/b] the standard oscillator (0 to −100) measuring where the close sits within the lookback's high-low range.

[b]- 13-EMA of %R:[/b] a smoothing/confirmation line.

[b]- Triggers:[/b] in "Band exit" mode a long fires when %R crosses back up through −80 (leaving oversold) and a short when it crosses back down through −20 (leaving overbought). In "EMA cross in zone" mode the trigger is %R crossing its EMA while in the lower/upper half. Either way, it marks the turn, not the extreme reading itself.

[b]- EMA confirmation (optional):[/b] requires %R on the trigger side of its EMA at signal time.
Regime filter (optional): longs only when the %R EMA is above the −50 midline, shorts only when below.

[b]- COT Bias Gate:[/b][b][/b] point the "COT source" input at any external series on the chart — e.g. a Commitments of Traders commercial-net or COT-index line. The script converts it to a 0–100 position-in-range index over a lookback; ≥80 is treated as bullish bias, ≤20 as bearish. With the gate on, longs show only in a bullish bias and shorts only in a bearish one; opposite-bias signals are suppressed. You can also set the bias manually or turn the gate off for standalone %R.

[b]- Divergence (optional):[/b] regular bull/bear divergence between price pivots and %R pivots.
Higher-timeframe read (optional): shows a higher-timeframe %R value in the table for top-down context.

[b]How to use it
[/b]
1. Add it on your entry timeframe (defaults: %R 21, EMA 13, band-exit, EMA confirmation on).
2. Set the bias — manually (Bullish/Bearish), or "Auto" pointed at a COT/context line, or Off.
3. Trade the markers: green up-triangle = confirmed long trigger, red down-triangle = confirmed short. Combine with your own levels and risk management.

[b]Notes and limitations
[/b]
- Divergence markers are drawn back at the confirmed pivot using an offset — they plot in the past and can repaint until the pivot forms. Treat them as context, not a standalone trigger.

- The gate reads whatever series feeds the source input; on the default (Close) the "bias" is computed from price, not COT — point it at a real COT/context line for it to be meaningful.

- The higher-timeframe read uses non-lookahead requests (no future data).

- Analysis tool for timing within a chosen bias. It does not predict outcomes and is not financial advice.

## Source Code

````pine
//@version=6
// THE WILLY+  -  Williams %R confluence engine  -  v2.0
// Fires on the EXIT from an extreme (the turn), confirms with the %R/EMA cross,
// and can be gated by COT bias. Divergence + HTF read optional.

indicator("xKen-t Williams %R + EMA w/COT Bias Gate", overlay = false, precision = 2)

cYel=#F4D35E
cAqua=#5AC8FA
cGreen=#52C08A
cRed=#E5564E
cDim=#8A9A94
cInk=#0E1517

gW="Williams %R"
wprLen=input.int(21,"%R length",minval=1,group=gW)
emaLen=input.int(13,"EMA length",minval=1,group=gW)
showFill=input.bool(true,"Shade band",group=gW)
upperBand=-20.0
lowerBand=-80.0
hh=ta.highest(high,wprLen)
ll=ta.lowest(low,wprLen)
wpr=(hh-ll)!=0 ? 100*(close-hh)/(hh-ll) : 0.0
wprEma=ta.ema(wpr,emaLen)

gT="Triggers"
mode=input.string("Band exit (cross -80/-20)","Trigger type",options=["Band exit (cross -80/-20)","EMA cross in zone"],group=gT)
emaConfirm=input.bool(true,"Require %R on correct side of EMA",group=gT)
regimeFilter=input.bool(false,"Regime filter (EMA vs -50 midline)",group=gT)
lTrig = mode=="Band exit (cross -80/-20)" ? ta.crossover(wpr,lowerBand)  : (ta.crossover(wpr,wprEma)  and wpr<-50)
sTrig = mode=="Band exit (cross -80/-20)" ? ta.crossunder(wpr,upperBand) : (ta.crossunder(wpr,wprEma) and wpr>-50)
lEmaOk = not emaConfirm or wpr>=wprEma
sEmaOk = not emaConfirm or wpr<=wprEma
lRegOk = not regimeFilter or wprEma>-50
sRegOk = not regimeFilter or wprEma<-50

gC="COT bias gate"
biasInput=input.string("Off","Gate signals by COT bias",options=["Off","Auto (COT source)","Bullish","Bearish","Neutral"],group=gC)
cotSrc=input.source(close,"COT source (for Auto)",group=gC,tooltip="Point at your COT Index or Commercial-net line.")
cotLen=input.int(26,"COT lookback",minval=4,group=gC)
cll=ta.lowest(cotSrc,cotLen)
chh=ta.highest(cotSrc,cotLen)
cotIdx=chh!=cll ? (cotSrc-cll)/(chh-cll)*100 : 50.0
autoBias=cotIdx>=80?"Bullish":cotIdx<=20?"Bearish":"Neutral"
bias=biasInput=="Auto (COT source)"?autoBias:biasInput
gateOn=biasInput!="Off"
lBiasOk=not gateOn or bias=="Bullish"
sBiasOk=not gateOn or bias=="Bearish"

longSig  = lTrig and lEmaOk and lRegOk and lBiasOk
shortSig = sTrig and sEmaOk and sRegOk and sBiasOk

gD="Divergence"
divOn=input.bool(false,"Show %R divergence",group=gD)
lb=input.int(5,"Pivot left",minval=1,group=gD)
rb=input.int(5,"Pivot right",minval=1,group=gD)
oscPL=ta.pivotlow(wpr,lb,rb)
oscPH=ta.pivothigh(wpr,lb,rb)
priceAtPL=low[rb]
priceAtPH=high[rb]
var float pOscPL=na
var float pPricePL=na
var float pOscPH=na
var float pPricePH=na
bullDiv=false
bearDiv=false
if not na(oscPL)
    if not na(pOscPL) and oscPL>pOscPL and priceAtPL<pPricePL
        bullDiv:=true
    pOscPL:=oscPL
    pPricePL:=priceAtPL
if not na(oscPH)
    if not na(pOscPH) and oscPH<pOscPH and priceAtPH>pPricePH
        bearDiv:=true
    pOscPH:=oscPH
    pPricePH:=priceAtPH

gH="Higher timeframe"
mtfOn=input.bool(false,"Show HTF %R in table",group=gH)
htf=input.timeframe("W","HTF",group=gH)
wprHTF=request.security(syminfo.tickerid,htf,wpr,lookahead=barmerge.lookahead_off)

p1=hline(upperBand,"Overbought",color=color.new(cDim,50))
p2=hline(lowerBand,"Oversold",color=color.new(cDim,50))
hline(-50,"Mid",color=color.new(cDim,80),linestyle=hline.style_dotted)
fill(p1,p2,color=showFill?color.new(cAqua,94):na)
plot(wpr,"%R",color=cYel,linewidth=2)
plot(wprEma,"EMA",color=cAqua,linewidth=2)

plotshape(longSig, "Long trigger",  shape.triangleup,   location.bottom, cGreen, size=size.small)
plotshape(shortSig,"Short trigger", shape.triangledown, location.top,    cRed,   size=size.small)
plotshape(divOn and bullDiv, "Bull div", shape.circle, location.bottom, color.new(cGreen,30), size=size.tiny, offset=-rb)
plotshape(divOn and bearDiv, "Bear div", shape.circle, location.top,    color.new(cRed,30),   size=size.tiny, offset=-rb)

gV="Display"
showTable=input.bool(true,"Show table",group=gV)
var string lastSig="none"
if longSig
    lastSig:="LONG"
if shortSig
    lastSig:="SHORT"
var table t=table.new(position.top_right,2,6,frame_color=color.new(cDim,50),frame_width=1)
if showTable and barstate.islast
    bg=color.new(cInk,12)
    regTxt=wprEma>-50?"buyers":"sellers"
    lastCol=lastSig=="LONG"?cGreen:lastSig=="SHORT"?cRed:cDim
    table.cell(t,0,0,"%R",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,0,str.tostring(wpr,"#.0"),text_color=cYel,text_size=size.small,bgcolor=bg)
    table.cell(t,0,1,"EMA",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,1,str.tostring(wprEma,"#.0"),text_color=cAqua,text_size=size.small,bgcolor=bg)
    table.cell(t,0,2,"Regime",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,2,regTxt,text_color=wprEma>-50?cGreen:cRed,text_size=size.small,bgcolor=bg)
    table.cell(t,0,3,"COT gate",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,3,gateOn?bias:"off",text_color=bias=="Bullish"?cGreen:bias=="Bearish"?cRed:cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,0,4,"HTF %R",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,4,mtfOn?str.tostring(wprHTF,"#.0"):"off",text_color=color.white,text_size=size.small,bgcolor=bg)
    table.cell(t,0,5,"Last signal",text_color=cDim,text_size=size.small,bgcolor=bg)
    table.cell(t,1,5,lastSig,text_color=lastCol,text_size=size.small,bgcolor=bg)

alertcondition(longSig, "Willy+ long",  "Willy+ LONG on {{ticker}} - %R exit from oversold, confirmed")
alertcondition(shortSig,"Willy+ short", "Willy+ SHORT on {{ticker}} - %R exit from overbought, confirmed")
````
