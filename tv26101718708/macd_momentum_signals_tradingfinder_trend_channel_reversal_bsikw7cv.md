# MACD Momentum Signals [TradingFinder] Trend Channel & Reversal

- url: https://www.tradingview.com/script/bSiKW7Cv-MACD-Momentum-Signals-TradingFinder-Trend-Channel-Reversal/
- type: indicator
- pine_id: PUB;6364d0b944f24d5bb80ae9463985a093
- version: 1.0

## Description

🔵[b]Introduction[/b]

The Moving Average Convergence Divergence (MACD) is one of the most widely used momentum indicators in technical analysis, helping traders identify changes in trend direction, momentum strength, and potential price reversals. The MACD calculation is based on the difference between two Exponential Moving Averages (EMA), typically the 12-period and 26-period averages. A 9-period Signal Line is then applied to the MACD Line, while the MACD Histogram represents the distance between them. When the Histogram expands above zero, bullish momentum is strengthening relative to the Signal Line; when it expands below zero, bearish momentum is gaining strength. Changes in the Histogram can also reveal when an existing price movement begins losing momentum.

[image]https://www.tradingview.com/x/GQUgmgHD/[/image]

However, a MACD crossover does not always represent a reliable buying or selling opportunity. During strong trends, bearish crossovers may appear while the broader market remains bullish, and bullish crossovers can occur during temporary corrections within a downtrend. In sideways markets, frequent MACD crossovers often produce conflicting trading signals without establishing a clear directional movement. Another challenge appears when price has already traveled a considerable distance from its average. Even when momentum remains strong, entering an extended movement can expose traders to unfavorable entry locations. For this reason, MACD momentum analysis becomes more meaningful when combined with price action, trend strength, and volatility-based price levels.

The combination of MACD Momentum Signals and a dynamic Trend Channel provides a broader perspective on these market conditions. Alongside the classic MACD oscillator, an EMA 200 Trend Channel uses Average True Range (ATR) to calculate five upper bands and five lower bands around the central moving average. These volatility-based bands help identify the position of price relative to its long-term average, distinguish normal price fluctuations from extended movements, and locate areas where bullish or bearish momentum may begin weakening. As market volatility increases or decreases, the distance between channel levels adjusts accordingly, allowing traders to evaluate price movements under changing market conditions.

The signal system combines MACD crossovers, momentum acceleration, trend quality, price confirmation, and channel interactions to identify different trading scenarios. Standard BUY and SELL signals focus on developing directional movements, while BUY+ and SELL+ signals highlight potential trend continuation opportunities following temporary corrections. Reversal signals examine price reactions around selected channel bands and changes in MACD momentum to identify possible turning points. By separating Momentum Shift, Trend Continuation, and Reversal setups, traders can interpret bullish and bearish signals according to the current market structure instead of relying on traditional MACD crossovers alone.

🔵[b]How to Use[/b]

The MACD oscillator and the Trend Channel work together to evaluate both momentum and price positioning. The oscillator displays the MACD Line in purple and the Signal Line in turquoise, accompanied by a four-color MACD Histogram. Turquoise histogram bars indicate positive momentum, while pink bars represent negative momentum. Lighter colors highlight periods when momentum is weakening in its current direction. Cross points mark interactions between the MACD and Signal lines, while the shaded area between them provides an additional visual reference for momentum changes.

On the price chart, the 200-period EMA forms the center of the Trend Channel, with five ATR-based bands extending above and below it. The upper bands help measure bullish price extension, while the lower bands identify progressively deeper bearish price extensions. These levels can serve as dynamic reference zones for evaluating trend continuation, corrections, and potential reversals. The signal engine combines this information with MACD momentum, shorter-term trend conditions, price action, and directional quality. BUY and SELL signals appear as triangles, while BUY R and SELL R signals use diamond markers. To reduce entries after excessive price extensions, new BUY signals are restricted above the third upper band, and new SELL signals are restricted below the third lower band.

🟣[b]Bullish Trend[/b]


[b]BUY Signal[/b]

A BUY signal appears when bullish momentum begins developing and the price structure provides sufficient confirmation of an upward movement. The initial condition involves a bullish MACD crossover, where the MACD Line moves above the Signal Line and the Histogram becomes positive. The indicator then examines whether bullish momentum is accelerating, price action supports the upward movement, and the trend-quality conditions are strong enough to validate the setup.

For example, after a period of downward movement or consolidation, the MACD Histogram may begin expanding into positive territory while price starts closing higher and recovering above a shorter-term moving average. If directional strength improves and the bullish movement satisfies the required conditions, a BUY signal appears below the candlestick. The confirmation can occur shortly after the initial MACD crossover, allowing the system to evaluate the developing movement rather than requiring every condition to align on the crossover candle itself.

[image]https://www.tradingview.com/x/DxqcVP9N/[/image]

[b]"BUY+" Signal[/b]

A BUY+ signal identifies potential continuation opportunities during an existing bullish trend. After an upward movement, the market may enter a temporary correction in which price pulls back and the positive MACD Histogram begins contracting. This weakening momentum does not necessarily indicate a bearish reversal; it may represent a short pause before buyers regain control.

The indicator evaluates the depth of the momentum correction, the behavior of price during the pullback, and the subsequent recovery of bullish pressure. When the MACD Histogram begins expanding again, the price confirms renewed upward movement, and the broader bullish conditions remain valid, a BUY+ signal appears below the candlestick. This signal is particularly useful for traders looking for opportunities to participate in trend continuation rather than entering only at the initial bullish MACD crossover.

[b]"BUY R" Signal[/b]

A BUY R signal focuses on potential bullish reversals following an extended downward movement. The initial setup develops when price reaches or penetrates a selected lower Trend Channel band while the MACD Histogram remains negative. This interaction identifies a possible reversal area, but touching the band alone is not sufficient to generate a buying signal.

The indicator monitors whether price moves back inside the selected channel level, whether bearish momentum begins weakening, and whether price establishes a bullish reaction. A recovery in the MACD Histogram, an improving MACD Line, and a bullish close above recent short-term highs provide the required confirmation. When these conditions align, a BUY R diamond appears below the price chart. In particularly strong bearish trends, additional confirmation is required to reduce premature countertrend signals. This setup identifies a potential bullish reaction rather than guaranteeing a complete reversal of the prevailing downtrend.

🟣[b]Bearish Trend[/b]

[b]SELL Signal[/b]

A SELL signal appears when bearish momentum begins developing alongside weakening price conditions. The process starts with a bearish MACD crossover, where the MACD Line moves below the Signal Line and the Histogram enters negative territory. The signal engine then evaluates bearish momentum acceleration, price direction, trend strength, and the quality of the emerging downward movement.

For example, after an upward correction or a period of consolidation, the MACD Histogram may turn negative while price begins closing lower and moving below its shorter-term average. When bearish momentum gains sufficient strength and price action confirms the downward movement, a SELL signal appears above the corresponding candlestick. The purpose of this signal is to identify developing bearish opportunities while reducing dependence on isolated MACD crossovers.

[image]https://www.tradingview.com/x/DCBRmdpF/[/image]

[b]"SELL+" Signal[/b]

A SELL+ signal represents a potential continuation opportunity within an established bearish trend. During a downward movement, temporary buying pressure may produce an upward correction, causing the negative MACD Histogram to contract toward the zero line. Although bearish momentum temporarily weakens, the broader market structure may remain bearish.

The indicator monitors the depth of this correction and looks for renewed selling pressure. When the Histogram begins expanding negatively again, price confirms downward movement, and the bearish trend conditions remain valid, a SELL+ signal appears above the candlestick. This helps traders distinguish between a temporary bullish correction and the resumption of bearish momentum, particularly during sustained downward trends.

"SELL R" Signal

A SELL R signal identifies potential bearish reactions after price extends toward the upper Trend Channel bands. The setup begins when price reaches or penetrates the selected upper band while the MACD Histogram remains positive. However, an extended bullish movement does not automatically indicate a selling opportunity, especially when price continues advancing with strong directional momentum.

For confirmation, the system monitors whether price returns inside the selected band, whether the MACD Histogram begins contracting, and whether price breaks below recent short-term lows. The MACD Line must also show weakening bullish momentum. When these conditions align, a SELL R diamond appears above the candlestick. If the broader bullish trend remains particularly strong, the system requires stronger bearish confirmation before issuing a reversal signal. This approach helps distinguish a potential bearish reversal setup from ordinary price fluctuations near the upper channel bands.

[image]https://www.tradingview.com/x/yq9j66yM/[/image]

🔵[b]Settings[/b]

[i]Fast Length[/i]: Sets the fast EMA period used in the MACD calculation.

[i]Slow Length[/i]: Sets the slow EMA period used in the MACD calculation.

[i]Signal Length[/i]: Adjusts the smoothing period of the MACD Signal Line.

[i]Signal Sensitivity[/i]: Selects Responsive, Balanced, or Conservative signal confirmation.

[i]Reversal Zone[/i]: Selects the channel band used to identify potential reversal setups.

[i]Channel EMA Length[/i]: Sets the period of the central moving average.

[i]Band Smoothing[/i]: Adjusts the smoothing of channel-width changes.

[i]Band Spacing (ATR)[/i]: Controls the ATR-based distance between consecutive bands.

[i]Show MACD Cloud[/i]: Shows or hides the shaded area between the MACD and Signal lines.

[i]Show Cross Points[/i]: Displays markers at MACD Line and Signal Line crossovers.

[i]Show Channel[/i]: Shows or hides the EMA channel and its upper and lower bands.

[i]Show Channel Fill[/i]: Enables or disables the transparent shading near the central EMA.

[i]Show Buy & Sell[/i]: Shows or hides trading signals on the price chart.

[i]Show "Buy+" & "Sell+"[/i]: Enables or disables trend continuation signals.

[i]Show Reversal Signals[/i]: Shows or hides BUY R and SELL R signals.

🔵[b]Conclusion[/b]

MACD momentum analysis offers valuable information about market direction, momentum acceleration, and potential trend changes, but traditional MACD crossover signals become more informative when evaluated alongside price structure and volatility. By combining the MACD Histogram, Signal Line, trend-quality conditions, and an EMA 200 Trend Channel, this approach provides additional context for interpreting bullish and bearish price movements. The five upper and five lower ATR bands help traders evaluate price extension, while the momentum signals distinguish between developing trends, continuation opportunities, and potential reversal areas.

The combination of BUY/SELL, BUY+/SELL+, and BUY R/SELL R signals allows traders to examine different phases of market movement without relying on a single type of MACD crossover. Momentum signals provide directional confirmation, continuation setups highlight potential entries after corrections, and reversal signals identify developing reactions around volatility-based channel levels. Together, these features support a more structured approach to MACD trading, trend following, price action analysis, and reversal identification across Forex, Crypto, Stocks, and other financial markets.

## Source Code

````pine
//@version=6
indicator("MACD Momentum Signals [TradingFinder] Trend Channel & Reversal", "Modern MACD ", overlay=false, max_labels_count=500)


//Inputs

FastLen=input.int(12,"Fast Length",minval=1,group="Signal Settings",tooltip="Fast EMA period for MACD.")
SlowLen=input.int(26,"Slow Length",minval=2,group="Signal Settings",tooltip="Slow EMA period for MACD.")
SignalLen=input.int(9,"Signal Length",minval=1,group="Signal Settings",tooltip="Smoothing period for the MACD signal line.")
Sensitivity=input.string("Balanced","Signal Sensitivity",options=["Responsive","Balanced","Conservative"],group="Signal Settings",tooltip="Controls how easily signals are confirmed.")
ReversalBand=input.string("Band 5","Reversal Zone",options=["Band 2","Band 3","Band 4","Band 5"],group="Signal Settings",tooltip="Band reached before a reversal setup can begin.")

ChannelBasisLen=input.int(200,"Channel EMA Length",minval=1,group="Channel",tooltip="Period of the channel center line.")
ChannelSmoothLen=input.int(12,"Band Smoothing",minval=1,maxval=100,group="Channel",tooltip="Smooths changes in channel width.")
ChannelWidth=input.float(1.50,"Band Spacing (ATR)",minval=0.1,maxval=10.0,step=0.05,group="Channel",tooltip="ATR distance between each band.")

ShowMacdCloud=input.bool(true,"Show MACD Cloud",group="Display",tooltip="Fill the space between MACD and signal lines.")
ShowCrossMarks=input.bool(true,"Show Cross Points",group="Display",tooltip="Mark crossings of MACD and signal lines.")
ShowChannel=input.bool(true,"Show Channel",group="Display",tooltip="Show EMA 200 and five bands on each side.")
ShowFill=input.bool(true,"Show Channel Fill",group="Display",tooltip="Show a soft fill near the center line.")
ShowSignals=input.bool(true,"Show Buy / Sell",group="Display",tooltip="Show trade signals on the price chart.")
ShowContinuation=input.bool(true,"Show Buy+ / Sell+",group="Display",tooltip="Show trend continuation signals.")
ShowReversal=input.bool(true,"Show Reversal Signals",group="Display",tooltip="Show confirmed BUY R and SELL R signals.")


Clamp(V,Lo,Hi)=>math.max(Lo,math.min(Hi,V))



//Logic

Fast=ta.ema(close,FastLen)
Slow=ta.ema(close,SlowLen)
Macd=Fast-Slow
Signal=ta.ema(Macd,SignalLen)
Hist=Macd-Signal
CrossUp=ta.crossover(Macd,Signal)
CrossDown=ta.crossunder(Macd,Signal)

Basis=ta.ema(close,55)
FastBasis=ta.ema(close,21)
ChannelBasis=ta.ema(close,ChannelBasisLen)
Atr=ta.atr(21)
SmoothedAtr=ta.ema(Atr,ChannelSmoothLen)
Step=SmoothedAtr*ChannelWidth
SignalAtr=ta.atr(14)
[PlusDI,MinusDI,Adx]=ta.dmi(14,14)
Slope=(Basis-Basis[5])/(SignalAtr+1e-10)
EffNum=math.abs(close-close[20])
EffDen=math.sum(math.abs(ta.change(close)),20)
Eff=EffDen>0?EffNum/EffDen:0.0
TrendScore=Clamp(100*(0.40*Clamp(Adx/35.0,0,1)+0.35*Eff+0.25*Clamp(math.abs(Slope)/1.5,0,1)),0,100)
TrendAdjust=Sensitivity=="Responsive"?-4.0:Sensitivity=="Conservative"?6.0:0.0
QualityAdjust=Sensitivity=="Responsive"?-5.0:Sensitivity=="Conservative"?6.0:0.0
DepthAdjust=Sensitivity=="Responsive"?-0.07:Sensitivity=="Conservative"?0.08:0.0
RecoveryAdjust=Sensitivity=="Responsive"?-0.15:Sensitivity=="Conservative"?0.25:0.0
ShiftTrendLimit=Clamp(42.0*0.85+TrendAdjust,0,100)
ContinueTrendLimit=Clamp(42.0+TrendAdjust,0,100)
RequiredDepth=Clamp(0.20+DepthAdjust,0.05,0.90)
RequiredRecovery=math.max(0,0.45+RecoveryAdjust)
TrendBull=close>Basis and PlusDI>MinusDI and Slope>0 and TrendScore>=ContinueTrendLimit
TrendBear=close<Basis and MinusDI>PlusDI and Slope<0 and TrendScore>=ContinueTrendLimit
BullBias=close>Basis and PlusDI>MinusDI and Slope>0 and (close-Basis)/(SignalAtr+1e-10)<=3.0
BearBias=close<Basis and MinusDI>PlusDI and Slope<0 and (Basis-close)/(SignalAtr+1e-10)<=3.0
BullShiftContext=(BullBias or (close>=Basis-SignalAtr*0.35 and close>FastBasis and FastBasis>FastBasis[1] and PlusDI>MinusDI*0.85 and Slope>-0.15)) and close>open and close>close[1] and close-Basis<=SignalAtr*3.0
BearShiftContext=(BearBias or (close<=Basis+SignalAtr*0.35 and close<FastBasis and FastBasis<FastBasis[1] and MinusDI>PlusDI*0.85 and Slope<0.15)) and close<open and close<close[1] and Basis-close<=SignalAtr*3.0

MomentumDelta=Hist-Hist[1]
MacdMax=ta.highest(math.abs(Macd),100)
HistMax=ta.highest(math.abs(Hist),100)
DeltaMax=ta.highest(math.abs(MomentumDelta),100)
MomentumScore=Clamp(100*(0.45*math.abs(Macd)/(MacdMax+1e-10)+0.35*math.abs(Hist)/(HistMax+1e-10)+0.20*math.abs(MomentumDelta)/(DeltaMax+1e-10)),0,100)
BullMomentum=Clamp(50+50*(0.25*Macd/(MacdMax+1e-10)+0.45*Hist/(HistMax+1e-10)+0.30*MomentumDelta/(DeltaMax+1e-10)),0,100)
BearMomentum=100-BullMomentum
BullQuality=Clamp(0.45*TrendScore+0.35*BullMomentum+0.20*MomentumScore,0,100)
BearQuality=Clamp(0.45*TrendScore+0.35*BearMomentum+0.20*MomentumScore,0,100)

BullPeak=ta.highest(Hist,12)
BearTrough=ta.lowest(Hist,12)
BullDepth=BullPeak>0?(BullPeak-Hist)/(BullPeak+1e-10):0.0
BearDepth=BearTrough<0?(Hist-BearTrough)/(math.abs(BearTrough)+1e-10):0.0
MomentumNoise=ta.ema(math.abs(MomentumDelta),10)
BullPullback=TrendBull and Hist>0 and Hist<Hist[1] and BullDepth>=RequiredDepth and (close<close[1] or low<low[1] or close<FastBasis)
BearPullback=TrendBear and Hist<0 and Hist>Hist[1] and BearDepth>=RequiredDepth and (close>close[1] or high>high[1] or close>FastBasis)
BullRecovery=Hist>0 and Hist>Hist[1] and Hist[1]<=Hist[2] and MomentumDelta>=MomentumNoise*RequiredRecovery and close>close[1] and close>open and close>FastBasis
BearRecovery=Hist<0 and Hist<Hist[1] and Hist[1]>=Hist[2] and -MomentumDelta>=MomentumNoise*RequiredRecovery and close<close[1] and close<open and close<FastBasis
ReversalLevel=ReversalBand=="Band 5"?5:ReversalBand=="Band 4"?4:ReversalBand=="Band 3"?3:2
LowerReversalBand=ChannelBasis-Step*ReversalLevel
UpperReversalBand=ChannelBasis+Step*ReversalLevel
BullReversalTouch=low<=LowerReversalBand and low[1]>LowerReversalBand[1] and Hist<0
BearReversalTouch=high>=UpperReversalBand and high[1]<UpperReversalBand[1] and Hist>0
RecentHigh=ta.highest(high,3)[1]
RecentLow=ta.lowest(low,3)[1]

var BullArmed=false
var BearArmed=false
var int BullPullbackBar=na
var int BearPullbackBar=na
var int BullShiftBar=na
var int BearShiftBar=na
var int LastSignalBar=na
var int LastLongBar=na
var int LastShortBar=na
var BullReversalArmed=false
var BearReversalArmed=false
var int BullReversalBar=na
var int BearReversalBar=na
var float BullReversalLow=na
var float BearReversalHigh=na
var BullReversalReady=true
var BearReversalReady=true
var BullReversalInside=false
var BearReversalInside=false
var int LastBuyReversalBar=na
var int LastSellReversalBar=na

if barstate.isconfirmed
    if CrossUp
        BullShiftBar:=bar_index
        BearShiftBar:=na
    if CrossDown
        BearShiftBar:=bar_index
        BullShiftBar:=na
    if not na(BullShiftBar) and (bar_index-BullShiftBar>2 or Hist<=0)
        BullShiftBar:=na
    if not na(BearShiftBar) and (bar_index-BearShiftBar>2 or Hist>=0)
        BearShiftBar:=na
    if BullPullback and not BullArmed
        BullArmed:=true
        BullPullbackBar:=bar_index
    if BearPullback and not BearArmed
        BearArmed:=true
        BearPullbackBar:=bar_index
    if not TrendBull or Hist<=0 or (BullArmed and bar_index-BullPullbackBar>9)
        BullArmed:=false
        BullPullbackBar:=na
    if not TrendBear or Hist>=0 or (BearArmed and bar_index-BearPullbackBar>9)
        BearArmed:=false
        BearPullbackBar:=na
    if not BullReversalArmed and close>ChannelBasis-Step
        BullReversalReady:=true
    if not BearReversalArmed and close<ChannelBasis+Step
        BearReversalReady:=true
    if BullReversalTouch and BullReversalReady
        BullReversalArmed:=true
        BullReversalReady:=false
        BullReversalInside:=false
        BullReversalBar:=bar_index
        BullReversalLow:=low
        BearReversalArmed:=false
        BearReversalInside:=false
    if BearReversalTouch and BearReversalReady
        BearReversalArmed:=true
        BearReversalReady:=false
        BearReversalInside:=false
        BearReversalBar:=bar_index
        BearReversalHigh:=high
        BullReversalArmed:=false
        BullReversalInside:=false
    if BullReversalArmed
        if low<BullReversalLow
            BullReversalLow:=low
            BullReversalBar:=bar_index
            BullReversalInside:=false
        if close<=LowerReversalBand
            BullReversalInside:=false
        else if close>open
            BullReversalInside:=true
        if bar_index-BullReversalBar>12
            BullReversalArmed:=false
            BullReversalInside:=false
    if BearReversalArmed
        if high>BearReversalHigh
            BearReversalHigh:=high
            BearReversalBar:=bar_index
            BearReversalInside:=false
        if close>=UpperReversalBand
            BearReversalInside:=false
        else if close<open
            BearReversalInside:=true
        if bar_index-BearReversalBar>12
            BearReversalArmed:=false
            BearReversalInside:=false

CanSignal=na(LastSignalBar) or bar_index-LastSignalBar>2
CanLong=CanSignal and (na(LastLongBar) or bar_index-LastLongBar>7)
CanShort=CanSignal and (na(LastShortBar) or bar_index-LastShortBar>7)
ShiftStrength=MomentumNoise*0.20
UpperSignalLimit=ChannelBasis+Step*3
LowerSignalLimit=ChannelBasis-Step*3
AllowBuy=close<=UpperSignalLimit
AllowSell=close>=LowerSignalLimit
BuyShift=barstate.isconfirmed and AllowBuy and CanLong and not na(BullShiftBar) and Hist>0 and MomentumDelta>ShiftStrength and BullShiftContext and TrendScore>=ShiftTrendLimit and BullQuality>=45.0+QualityAdjust
SellShift=barstate.isconfirmed and AllowSell and CanShort and not na(BearShiftBar) and Hist<0 and -MomentumDelta>ShiftStrength and BearShiftContext and TrendScore>=ShiftTrendLimit and BearQuality>=45.0+QualityAdjust
BuyCont=barstate.isconfirmed and AllowBuy and ShowContinuation and CanLong and BullArmed and BullRecovery and BullBias and TrendBull and BullQuality>=48.0+QualityAdjust and not BuyShift
SellCont=barstate.isconfirmed and AllowSell and ShowContinuation and CanShort and BearArmed and BearRecovery and BearBias and TrendBear and BearQuality>=48.0+QualityAdjust and not SellShift
StrongBull=close>Basis and Basis>Basis[3] and FastBasis>FastBasis[3] and PlusDI>MinusDI and Adx>=20
StrongBear=close<Basis and Basis<Basis[3] and FastBasis<FastBasis[3] and MinusDI>PlusDI and Adx>=20
BullReversalMomentum=Hist>Hist[1] and Hist[1]>=Hist[2] and Macd>Macd[1] and MomentumDelta>=MomentumNoise*0.25
BearReversalMomentum=Hist<Hist[1] and Hist[1]<=Hist[2] and Macd<Macd[1] and -MomentumDelta>=MomentumNoise*0.25
BullReversalPrice=BullReversalInside and close>LowerReversalBand and close>RecentHigh and close>open
BearReversalPrice=BearReversalInside and close<UpperReversalBand and close<RecentLow and close<open
BullReversalGuard=not StrongBear or (close>FastBasis and Hist>0)
BearReversalGuard=not StrongBull or (close<FastBasis and Hist<0)
CanBuyReversal=CanSignal and (na(LastBuyReversalBar) or bar_index-LastBuyReversalBar>12)
CanSellReversal=CanSignal and (na(LastSellReversalBar) or bar_index-LastSellReversalBar>12)
BuyReversal=barstate.isconfirmed and AllowBuy and ShowReversal and CanBuyReversal and BullReversalArmed and bar_index>BullReversalBar and BullReversalPrice and BullReversalMomentum and BullReversalGuard and not (BuyShift or SellShift or BuyCont or SellCont)
SellReversal=barstate.isconfirmed and AllowSell and ShowReversal and CanSellReversal and BearReversalArmed and bar_index>BearReversalBar and BearReversalPrice and BearReversalMomentum and BearReversalGuard and not (BuyShift or SellShift or BuyCont or SellCont)

if BuyShift or BuyCont or SellShift or SellCont or BuyReversal or SellReversal
    LastSignalBar:=bar_index
    if BuyShift or BuyCont or BuyReversal
        LastLongBar:=bar_index
    if SellShift or SellCont or SellReversal
        LastShortBar:=bar_index
    BullShiftBar:=na
    BearShiftBar:=na
    BullArmed:=false
    BearArmed:=false
    BullPullbackBar:=na
    BearPullbackBar:=na
    if BuyReversal
        LastBuyReversalBar:=bar_index
        BullReversalArmed:=false
        BullReversalInside:=false
    if SellReversal
        LastSellReversalBar:=bar_index
        BearReversalArmed:=false
        BearReversalInside:=false


//MACD


//Colors


Bull=#087979
Bear=#FF4D9D
ContBull=#32928d
ContBear=#FFB08A
MacdCore=#7D3CFF
SignalCore=#00A8A8
ZeroColor=#F2E9FF
UpperColor=#00A8A8
LowerColor=#FF4D9D
BasisColor=#c9b1eb
AccentColor=#F4D6A6


hline(0,"Zero Line",color=color.new(ZeroColor,75),linestyle=hline.style_dotted)

HistColor=Hist>=0?(Hist>=Hist[1]?color.new(#00A8A8,0):color.new(#7DD3CE,5)):(Hist<=Hist[1]?color.new(#FF4D9D,0):color.new(#FFB08A,5))
plot(Hist,"Histogram Glow",color=color.new(Hist>=0?#00A8A8:#FF4D9D,84),style=plot.style_columns,linewidth=6)
plot(Hist,"MACD Histogram",color=HistColor,style=plot.style_columns,linewidth=3)

PMacdGlow1=plot(Macd,"MACD Glow Outer",color=color.new(MacdCore,90),linewidth=5)
PMacdGlow2=plot(Macd,"MACD Glow Inner",color=color.new(MacdCore,76),linewidth=3)
PSigGlow1=plot(Signal,"Signal Glow Outer",color=color.new(SignalCore,90),linewidth=5)
PSigGlow2=plot(Signal,"Signal Glow Inner",color=color.new(SignalCore,76),linewidth=3)
PMacd=plot(Macd,"MACD Line",color=MacdCore,linewidth=1)
PSignal=plot(Signal,"Signal Line",color=SignalCore,linewidth=1)
fill(PMacd,PSignal,color=ShowMacdCloud?(Macd>=Signal?color.new(#00A8A8,88):color.new(#FF4D9D,88)):na,title="MACD Signal Cloud")

plotshape(ShowCrossMarks and CrossUp?Signal:na,"Bullish Cross",style=shape.circle,location=location.absolute,color=color.new(#7DD3CE,0),size=size.tiny)
plotshape(ShowCrossMarks and CrossDown?Signal:na,"Bearish Cross",style=shape.circle,location=location.absolute,color=color.new(#FF4D9D,0),size=size.tiny)


//Channel

PBasis=plot(ShowChannel?ChannelBasis:na,"Channel EMA",color=BasisColor,linewidth=2,force_overlay=true)
plot(ShowChannel?ChannelBasis:na,"Basis Glow Outer",color=color.new(#F2E9FF,92),linewidth=8,force_overlay=true)
plot(ShowChannel?ChannelBasis:na,"Basis Glow Inner",color=color.new(#7D3CFF,86),linewidth=4,force_overlay=true)

PU1=plot(ShowChannel?ChannelBasis+Step:na,"Upper 1",color=color.new(color.from_gradient(1,1,5,#00A8A8,#7DD3CE),8),linewidth=1,force_overlay=true)
PU2=plot(ShowChannel?ChannelBasis+Step*2:na,"Upper 2",color=color.new(color.from_gradient(2,1,5,#00A8A8,#7DD3CE),22),linewidth=1,force_overlay=true)
PU3=plot(ShowChannel?ChannelBasis+Step*3:na,"Upper 3",color=color.new(color.from_gradient(3,1,5,#00A8A8,#7DD3CE),36),linewidth=1,force_overlay=true)
PU4=plot(ShowChannel?ChannelBasis+Step*4:na,"Upper 4",color=color.new(color.from_gradient(4,1,5,#00A8A8,#7DD3CE),50),linewidth=1,force_overlay=true)
PU5=plot(ShowChannel?ChannelBasis+Step*5:na,"Upper 5",color=color.new(color.from_gradient(5,1,5,#00A8A8,#7DD3CE),64),linewidth=1,force_overlay=true)
PL1=plot(ShowChannel?ChannelBasis-Step:na,"Lower 1",color=color.new(color.from_gradient(1,1,5,#FF4D9D,#7D3CFF),8),linewidth=1,force_overlay=true)
PL2=plot(ShowChannel?ChannelBasis-Step*2:na,"Lower 2",color=color.new(color.from_gradient(2,1,5,#FF4D9D,#7D3CFF),22),linewidth=1,force_overlay=true)
PL3=plot(ShowChannel?ChannelBasis-Step*3:na,"Lower 3",color=color.new(color.from_gradient(3,1,5,#FF4D9D,#7D3CFF),36),linewidth=1,force_overlay=true)
PL4=plot(ShowChannel?ChannelBasis-Step*4:na,"Lower 4",color=color.new(color.from_gradient(4,1,5,#FF4D9D,#7D3CFF),50),linewidth=1,force_overlay=true)
PL5=plot(ShowChannel?ChannelBasis-Step*5:na,"Lower 5",color=color.new(color.from_gradient(5,1,5,#FF4D9D,#7D3CFF),64),linewidth=1,force_overlay=true)
fill(PBasis,PU1,color=ShowFill?color.new(#7DD3CE,95):na,title="Upper Inner Fill")
fill(PBasis,PL1,color=ShowFill?color.new(#FF4D9D,95):na,title="Lower Inner Fill")


//Signals

BuyTriangleY=low-SignalAtr*2
SellTriangleY=high+SignalAtr*2
LabelGap=2+0.80
BuyLabelGap=2+2
plotshape(ShowSignals and BuyShift?BuyTriangleY:na,"BUY Triangle",style=shape.triangleup,location=location.absolute,color=Bull,size=size.small,force_overlay=true)
plotshape(ShowSignals and SellShift?SellTriangleY:na,"SELL Triangle",style=shape.triangledown,location=location.absolute,color=Bear,size=size.small,force_overlay=true)
plotshape(ShowSignals and BuyCont?BuyTriangleY:na,"BUY+ Triangle",style=shape.triangleup,location=location.absolute,color=ContBull,size=size.small,force_overlay=true)
plotshape(ShowSignals and SellCont?SellTriangleY:na,"SELL+ Triangle",style=shape.triangledown,location=location.absolute,color=ContBear,size=size.small,force_overlay=true)
plotshape(ShowSignals and ShowReversal and BuyReversal?BuyTriangleY:na,"BUY R Diamond",style=shape.diamond,location=location.absolute,color=Bull,size=size.small,force_overlay=true)
plotshape(ShowSignals and ShowReversal and SellReversal?SellTriangleY:na,"SELL R Diamond",style=shape.diamond,location=location.absolute,color=Bear,size=size.small,force_overlay=true)

if ShowSignals and BuyShift
    label.new(bar_index,low-SignalAtr*BuyLabelGap,"BUY",style=label.style_none,textcolor=Bull,size=size.small,force_overlay=true)
if ShowSignals and SellShift
    label.new(bar_index,high+SignalAtr*LabelGap,"SELL",style=label.style_none,textcolor=Bear,size=size.small,force_overlay=true)
if ShowSignals and BuyCont
    label.new(bar_index,low-SignalAtr*BuyLabelGap,"BUY+",style=label.style_none,textcolor=ContBull,size=size.small,force_overlay=true)
if ShowSignals and SellCont
    label.new(bar_index,high+SignalAtr*LabelGap,"SELL+",style=label.style_none,textcolor=ContBear,size=size.small,force_overlay=true)
if ShowSignals and ShowReversal and BuyReversal
    label.new(bar_index,low-SignalAtr*BuyLabelGap,"BUY R",style=label.style_none,textcolor=Bull,size=size.small,force_overlay=true)
if ShowSignals and ShowReversal and SellReversal
    label.new(bar_index,high+SignalAtr*LabelGap,"SELL R",style=label.style_none,textcolor=Bear,size=size.small,force_overlay=true)


//Alerts

alertcondition(BuyShift,"BUY","TF-482: BUY on {{ticker}} / {{interval}}")
alertcondition(SellShift,"SELL","TF-482: SELL on {{ticker}} / {{interval}}")
alertcondition(BuyCont,"BUY+","TF-482: BUY+ continuation on {{ticker}} / {{interval}}")
alertcondition(SellCont,"SELL+","TF-482: SELL+ continuation on {{ticker}} / {{interval}}")
alertcondition(BuyReversal,"BUY Reversal","TF-482: BUY reversal on {{ticker}} / {{interval}}")
alertcondition(SellReversal,"SELL Reversal","TF-482: SELL reversal on {{ticker}} / {{interval}}")
````
