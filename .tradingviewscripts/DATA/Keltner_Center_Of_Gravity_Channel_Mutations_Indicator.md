<!-- tradingview-pine-id: PUB;7fefd68aa2c34e87b6aeb14ffcdef6cf -->
<!-- tradingviewscripts-format: 1 -->
# Keltner Center Of Gravity Channel Mutations Indicator

Source: https://www.tradingview.com/script/sZvBR1Vq-KCGmut/

## Description

“KCGmut” stands for “Mutations Of Keltner Center Of Gravity Channel”.
After adding the ‘KeltCOG Width’ label to the KeltCOG, I got the idea of creating a subpanel indicator to show the development of the width-percent in previous periods. After some more thinking, I decided that the development of the COG-width-percent should also be reported and somehow the indicator should report whether the close is over (momentum is up), in (momentum is sideways) or under (momentum is down) the COG ( This is the gray area in the channel). 

Borrowing from other scripts:
I tweeked the script of the KeltCOG (published) to calculate the columns and of REVE (also published) to calculate the volume spikes. Because the KeltCOG script had the default option to let the script chose lookback and adapt the width, I decided to not provide inputs to tweek lookback or channel width. Thus, if you use a KeltCOG in default setting, REVE and KCGmut together in the same chart, these will provide consistent complementary information about the candle. This layout has this combination:
https://www.tradingview.com/x/ybdAOZyn/
I added actual volume to show where volume spikes occur.

Columns
For the channel-width-percent half of the value is used and for the COG-width-percent the whole to get a better image
By plotting the columns of the full width before those of the COG, in two series of positive and negative values, I created the illusion of a column with a different colored patch representing the COG (most are black) at the bottom where it points up (showing momentum is up), in the middle when the close is in the COG (no momentum) or at the top when the close is below the COG (showing momentum is down)

coloring drama
When nothing much happens, i.e. the channels keep the same width of shrink a bit, the columns get an unobtrusive color, black for the small COG patches and bluish gray for the channel columns pointing up or sideways, reddish gray when pointing down. If the COG increases (drama) the patches get colored lime (up), red (down) or orange (sideways, very seldom). If the channel increases, the columns get colored gold (up), maroon (down) or orange (sideways). Because the COG is derived from a Donchian channel, drama means a new high or low in the lookback period. Drama in the KeltCOG channel just means increase in volatility.

histogram showing volume spikes
Blue spikes indicate more then twice as much volume then recently normal, Maroon spikes indicate clear increases less then twice. To prevent the histogram from disappearing behind a column it is plotted first, spikes made longer then the column and also plotted both positive and negative. Single volume spikes don’t mean much, however if these occur in consecutive series and also come together with drama like new highs or increase in volatility, volume is worth noting. I regard such events as ‘voting’, the market ‘votes’ up or down. The REVE analyses these events to asses whether the volume stems from huge institutional traders (‘whales’) or large numbers of small traders (‘muppets’). This might be interesting too.

Remarks about momentum
Like in MACD, momentum has a direction. The difference is that in KCGmut momentum is a choise of the market to move above the COG (uptrend) or in (sideways) or under (downtrend), whereas in MACD the indicator shows the energy with which the market moves up or down. How does the market ‘choose’? The market doesn’t ‘think’, but still it comes to decisions. I see an analogy with the way a swarm of birds decides to go here or there, up or down, or land in a tree. All birds seem to agree but I guess a single bird has not much say in what the swarm does.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eykpunter

//@version=5
indicator("Keltner Center Of Gravity Channel Mutations Indicator", shorttitle="KCGMut")

//calculate lookback
//script automatically adepts lookback to timeframe
per=14                               //initialize per
setper= 14                           //initialize setper
tf=timeframe.period
setper:= tf=="M"? 14: tf=="W"? 14: tf=="D"? 21: tf=="240"? 28: tf=="180"? 28: tf=="120"? 35: tf=="60"? 35: tf=="45"? 35: tf=="30"? 42: tf=="15"? 42: tf=="5"? 49: tf=="3"? 49: tf=="1"? 56: 10
per:= setper

//KeltCOG RELEVANT CODE
//Calculate channel
//Calculate COG
donhigh=ta.highest(high,per)           //COG calculated using values of Donchian channel
donlow=ta.lowest(low,per)
cent=(donhigh+donlow)/2             //center line not plotted, used calculation of widthpercent
donrange=donhigh-donlow
coglow=donlow+donrange*0.382        //Actually a Center Low fibonacci line in my donchian fibonacci channel
coghigh=donlow+donrange*0.618       //center high fibonacci

//Calculate borders
//calculate width (i.e. COG to border)
//script adepts width to lookback period
varwidth=2.00                           //initialize variable width
formula=math.round(2 + per/25 - 6/per, 1)    //Script uses this formula to adapt Width (i.e COG to border) to look back period
varwidth:= formula
dis=ta.atr(per)                        //Keltner channels have lines spaced by average true range
horizontal=false                    //Initialize horizontal boolean. New values only calculated when the COG (Center of Gravity) changes 

outerhigh=coghigh             //initialize Outer Keltner line above COG
outerlow=coglow               //initialize outer Kelner below COG
horizontal:= coglow==coglow[1]?true: false                //set horizontal COG changes result in Keltner changes, otherwize Keltner is horizontal
outerhigh:= horizontal?outerhigh[1]: coghigh+varwidth*dis
outerlow:= horizontal?outerlow[1]: coglow-varwidth*dis

//CALCULATE VALUES FOR INDICATOR
//define direction
trendup=close>coghigh
trenddown=close<coglow
trendside=close<=coghigh and close>=coglow

//define width percent of channel
widchan=outerhigh-outerlow
perchan = trendside? math.round(widchan/cent*25, 1): math.round(widchan/cent*50, 1) //indicator uses half of width, whisch is a little more than atr-percent
negperchan=-perchan

//define width percent of cog
widcog=coghigh-coglow
percog = trendside? math.round(widcog/cent*50, 1) :math.round(widcog/cent*100, 1)
negpercog = -percog

//CALCULATE VOLUME EXPANSION EVENTS
//Function finding the usual value of a series with a pick and choose statistical procedure, inspects 8 periods but averages the 'middlest' 4.
usual(src) =>                                            
    pick = math.sum(src,3) -ta.highest(src,3) -ta.lowest(src,3)    //pick the middle
    (math.sum(pick,6) -ta.highest(pick,6) -ta.lowest(pick,6))/4    //choose the mediocre out of the picks
// end of function

//finding volume events
usuvol= usual(volume) //find something to compare present volume with
relv= volume>usuvol? 100*(volume-usuvol)/volume :0     //only rises reported
eventbig=relv>50
event=relv>20 and relv<=50
evline=eventbig? widchan/cent*60 :event? widchan/cent*45: 0
negevline=eventbig? -widchan/cent*60 :event? -widchan/cent*35: 0
volcol = eventbig? color.blue: color.maroon

//firstplots
plot(evline,    title="volume event pos", color=volcol, style=plot.style_histogram, linewidth=2 )
plot(negevline, title="volume event neg", color=volcol, style=plot.style_histogram, linewidth=2 )

//PRAPARE AND EXECUTE PLOTS

//define swelling situations
chanswellup = widchan>widchan[1] and trendup
chanswelldown = widchan>widchan[1] and trenddown
chanswellside = widchan>widchan[1] and trendside
cogswellup = widcog>widcog[1] and trendup
cogswelldown = widcog>widcog[1] and trenddown
cogswellside = widcog>widcog[1] and trendside

//define colors
chancol = chanswellup? color.rgb(236, 177, 38, 00) : chanswelldown? color.maroon: chanswellside? color.rgb(245,124,00,00): trenddown? color.rgb(210,140,185,0): color.rgb(130,148,164,0)
cogcol = cogswellup ?  color.lime: cogswelldown? color.red: cogswellside? color.orange: color.black

//second plots
plot(trendup or trendside? perchan :na, title="channelwidth as percent of middle line", style=plot.style_columns, color=chancol)
plot(trendup or trendside? percog :na, title="COGwidth as percent of middle line", style=plot.style_columns, color=cogcol )
plot(trenddown or trendside? negperchan :na, title="channelwidth as percent negative", style=plot.style_columns, color=chancol )
plot(trenddown or trendside? negpercog :na, title="COGwidth as percent negative", style=plot.style_columns, color=cogcol )
````
