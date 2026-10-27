# TZ-REVE

- url: https://www.tradingview.com/script/gi9GRrAp-TZ-REVE/
- type: indicator
- pine_id: PUB;41815cf2ba3a49249ca3ec5579b55517
- version: 1.0

## Description

TZ-REVE is a sub-panel indicator that seeks to provide a concise overview of what is going on in the market dynamics of the instrument in the period shown on the chart, i.e. short- and longer trends, analysis of ranges and volume events all in one visual. Because it has a steep learning curve, an analyis for the last/current candle  of all these is also provided in four catchwords.

TZ stands for TrendZones, because depicts the TrendZones situation. TrendZones is a channel indicator which I published some time ago.
REVE stands for Range Extension Volume Expansion, for which I published several attempt's.
In this indicator I used code from their scripts. I tried to improve the visual presentation. 

A new feature is the Center Zone with colored patches to indicates short up- and downtrends derived from how a three period moving average moves in relation to a nine period and twenty period MA. This results in five colors: 
    • White for a situation which I call “transition”, there the 3MA either moves down while above both 9MA and 20MA or moves up while below both 9MA and 20MA or some other non-color situations;
    • Transparent Green indicates upward movement, which I called “rise(rising)”, here the 3MA moves up while above 9MA but below 20MA
    • Lime green indicates strong upward movement, which I called “soar(soaring)”, here the 3MA moves up while above both the 9MA and the 20MA.
    • Brown indicates a downward movement called “drop(dropping)”, when the 3MA moves down while below 20MA but above 9MA.
    • Transparent Fuchsia indicates a strong downward movement called “plunge(plunging)”, when the 3MA moves down while below both 9MA and 20MA.
To show this, I created an indicator out of these three MA’s in which the zones in between these lines are colored with the same logic, the thick green line is 3MA, the purple thin line is 9MA, the gray thin line is 20MA: Three MA example: https://www.tradingview.com/x/FtlQHAX0/

I refer to the columns pointing upward and downward as ‘ticks’. They represent the range and direction of three last periods. The direction is NOT calculated as close above or below open (like in candlesticks) but as close above or below the highest of the two previous closes. The ticks get four possible colors:
    • Yellow for small range up- and downticks
    • Gray for ‘normal’ range up- and downticks
    • Green for wide range upticks
    • Purple for wide range downticks
The length of the Tick Columns is calculated through a comparison of the current True Range with the Average True Range of the last 50 periods, taken as 100 percent. The result is marked as ‘small’ when this current TR is less then 60 percent , ‘wide’ when more then 110 percent, ‘normal’ otherwise. 

The TrendZones Situation is depicted with the green and blue thick line above the Center Zone and the orange and red line below it. In fact these are stretches of the same line. This line is calculated as a percent of the distance of the hl2 from the COG where Upper Curve minus Lower Curve is taken as 100 percent. The Situation line is made invisible where the candle or bar crosses the COG.
The colors are:
    • Red when the bar is in the red strong downtrend zone
    • Orange if the bar is in the orange downtrend zone
    • Invisible when bar crosses COG (“sideways”)
    • Green for the bar in the green uptrend zone
    • Blue when in the strong uptrend zone.
Where the direction of the Tick coincides with the trend, the Tick column is ‘crowned’ with a dot of the same color as the Situation line.
To show this, I have put a TrendZones (updated version) in the example chart: 
Trendzones Situation example: https://www.tradingview.com/x/VnvelToK/

When volume in a certain period is higher than normal, I call this a ‘volume event’. A volume event indicates that the price action is supported with many buyers and sellers. To calculate whether a volume event happened and how big it is, we need to know the ‘normal’ volume. In the case of volume, ‘average’ cannot be used, because outliers in volume are so huge that  they make the average too high to find smaller volume events in the following timeframes. To avoid the outlier influence, I use the ‘median’ of fifty periods as ‘normal’, using that as 100 percent. This leads to five cohorts for the current volume: 
    • 0-120 percent of normal: Unremarkable volume – no marker
    • 120-150 percent of normal: Much volume – gray triangle
    • 150-180 percent of normal: High volume – orange triangle
    • 180-210 percent of normal: Huge volume – red triangle
    • 210 and higher percent of normal: Extreme volume – maroon triangle
The Volume Event Triangles are placed in the middle of the Center Zone, pointing in the same direction as the ticks.

In previous versions I tried to calculate the direction of volume markers in a way that not only leads to ‘up’ or ‘down’ but also ‘falter’. Periods with falter are often part of a reversal pattern. For these situations I created a Falter Marker, a black dot on the Center Zone border under the tick column. Although these dots are interesting, they have no practical use in my analysis. They are there because they are a nice feature if the instrument comes without volume, like some indexes.


Because this indicator is crammed with information, it has a steep learning curve. To help understand what is reported by all its features, I created four catch phrases to the right. These concern the last (current) candle or bar.

- On top a catchword for the Center Zone color patches, which represent short up- and downtrend.  These can be ‘rising’, ‘soaring’, ‘dropping’, ‘plunging’ or ‘transition’.

- Then a catchword for the TrendZones Situation.
These can be: ‘S uptrend’, ‘uptrend’, ‘downtrend’, ‘S downtrend’ or ‘sideways’

- Then a catchword for Tick column. 
These can be 
    • ‘Fwide up’ which means wide range pointing up with falter marker
    • ‘wide up’ wide range pointing up
    • Fwide down’ wide range pointing down with falter marker
    • ‘wide down’ wide range pointing down
    • Fsmall up’ small range pointing up with falter marker
    • ‘small up’ small range pointing up
    • ‘Fsmall down’ small range pointing down with falter marker
    • ‘small down’ small range pointing down
    • ‘Fup’ normal range pointing up with falter marker
    • ‘up’ normal range pointing up
    • ‘Fdown’ normal range pointing down with falter marker
    • ‘down’ normal range pointing down


- Then a catchword for volume.
These can be ‘no volume’, ‘normal vol’, ‘much vol’, ‘high vol’, ‘huge vol’ or ‘extreme vol’.

Have fun,
Eykpunter

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eykpunter

//@version=6
indicator("TZ-REVE", overlay=false)
//REVE stands for Range Extension Volume Epansion
//Length of the columns represent relative range extensions. Opacity of the column colors relative volume expansion.
//=================================================================================================================================================
//inputs

//=====switches
evalwish = input.bool(true,"Evaluation of current period",group="Switches")

//=====colors
colA1=input.color(color.rgb(154, 164, 194,10),"Normal Uptick and Downtick Column Color",group="Wave Form Colors")
colA2=input.color(color.new(color.yellow,15),"Small range",group="Wave Form Colors")
colA3=input.color(color.new(color.lime,40),"Wide Uptick Column Color",group="Wave Form Colors")
colA4=input.color(color.new(color.fuchsia,40),"Wide Downtick Column Color",group="Wave Form Colors")
colA5=input.color(color.new(color.white,100),"Invisible Column Color",group="Wave Form Colors")
colB0=input.color(color.white,"Fill Color",group="Center Lines Colors")
colB1=input.color(color.new(color.green, 60),"Rising Color",group="Center Lines Colors")
colB2=input.color(color.lime,"Soaring Color",group="Center Lines Colors")
colB3=input.color(color.rgb(224, 155, 89),"Drop color",group="Center Lines Colors")
colB4=input.color(color.new(color.fuchsia,60),"Plunge Color",group="Center Lines Colors")
colC1=input.color(color.gray,"Much Volume 120%-150%",group="Signal Marker Colors")
colC2=input.color(color.orange,"High Volume 150%-180%",group="Signal Marker Colors")
colC3=input.color(color.red,"Huge Volume 180%-210%",group="Signal Marker Colors")
colC4=input.color(color.maroon,"Extreme Volume over 210%",group="Signal Marker Colors")
colD1=input.color(color.blue,"Strong Uptrend", group = "Trend Zones")
colD2=input.color(color.green,"Uptrend", group = "Trend Zones")
colD3=input.color(color.orange,"Downtrend", group = "Trend Zones")
colD4=input.color(color.red, "Strong Down Trend", group = "Trend Zones")
colD5=input.color(color.new(color.white,100),"Invisible Trend Zones Color", group = "Trend Zones")

//================================================================================================================================================
//centerzone
midplus=50
midminus=-50

//=================================================================================================================================================
//Create ticks

//==tick length
curtr=ta.tr(true) 
compatr= ta.atr(50)
small=curtr<compatr/1.667
wide=curtr>compatr*1.1
tick=curtr/compatr*100

//==tick direction
compare=ta.highest(close[1],2)      //level to calculate direction
closup=close>=compare               //direction up
closdn=close<compare                //direction down

//==upticks
vplus=closup?  2*midplus+tick:na   //lengthened a bit
colup=closup? wide? colA3: small?colA2: colA1: colA5
plot(vplus,"up tick range", colup, 3, plot.style_columns, histbase=midplus, display=display.pane)    //column

vminus=closdn? 2*midminus-tick:na   //lengthened a bit
coldn=closdn? wide? colA4: small? colA2: colA1: colA5
plot(vminus,"down tick range", coldn, 3, plot.style_columns, histbase=midminus, display=display.pane) //column

//================================================================================================================================================
// Trend Zones situation lines

//=======calculate TZ lines
lb=30
med=5
sb=math.round(lb/2)
supper=ta.highest(ta.median(high,med),sb)
upper=ta.sma(supper,lb)
slower=ta.lowest(ta.median(low,med),sb)
lower=ta.sma(slower,lb)
cog=(upper+lower)/2

//=====calculate zone situation
bzone= low>upper
gzone= low>cog and low<upper 
ozone= high<cog and high>lower
rzone= high<lower
szone= not bzone and not gzone and not ozone and not rzone

//======calculate and plot distance to cog as a percent
situation= ((hl2-cog)/(upper-lower))*100
hisup= hl2>=cog
hisdn= hl2<cog
zplus=2*midplus+situation      //hightened a bit to make better visable
zminus=2*midminus+situation      //lowered a bit to make better visible
colzpl= bzone? colD1: gzone? colD2: colD5
colzmi= ozone? colD3: rzone? colD4: colD5

//==uptrends and uptrend markings
plot(zplus,"Uptrends cf Trendzones", colzpl, 3, display=display.pane)
plot(vplus, "up tick markings", hisup? colzpl: na, 2, plot.style_circles, display=display.pane)  //marker in color of histogram

//==downtrents and downtick markings
plot(zminus,"downtrends cf Trendzones", colzmi, 3, display=display.pane)
plot(vminus, "down tick markings", hisdn? colzmi: na, 2, plot.style_circles, display=display.pane)  //marker in color of histogram

//==================================================================================================================================================
//colors for center zone;  uses properties of three moving averages
hl2short=ta.sma(hl2,3)          //short moving average
hl2mid=ta.sma(hl2,9)        //middle moving average
hl2long=ta.sma(hl2,20)      //long moving average
//logic for fills
rise=hl2mid<hl2long and hl2short>hl2mid and hl2short>hl2short[1] 
soar=  hl2mid>hl2long and hl2short>hl2mid and hl2short>hl2short[1] 
drop=  hl2mid>hl2long and hl2short<hl2mid and hl2short<hl2short[1]
plunge=hl2mid<hl2long and hl2short<hl2mid and hl2short<hl2short[1]

//========Create horizontal lines colored equal to histogram and center color zones
pmp=plot(midplus, "Center plus", color=bzone? color.blue: gzone? color.green: ozone?color.orange: rzone?color.red: color.gray, linewidth=1, display=display.pane)
pmm=plot(midminus, "Center minus", color=bzone? color.blue: gzone? color.green: ozone?color.orange: rzone?color.red: color.gray, linewidth=1, display=display.pane)

fill(pmp,pmm, rise? colB1: soar? colB2: drop? colB3: plunge? colB4:  colB0, "short trends")                  //color.rgb(8, 121, 212):na, 2)

//=================================================================================================================================================
//volume calculations

//==Check for presence of volume in the instrument
vavg=ta.sma(volume,3)               //volume level
vmeds=ta.median(volume,5)           //new normal
norvol=ta.median(volume[1],30)    //old normal
highfocus=vavg>norvol and vmeds>norvol    //considarable volume rize
lowfocus =vavg<norvol and vmeds<norvol   //considarble low volume
eqsize=volume[1] == volume[2] and volume[1] == volume[3] and volume[1] == volume[4]
occur=highfocus or lowfocus?1:0
present= math.sum(occur,30)>4 and not eqsize   //no occurrences means no relevant volume; this also excludes fake volume
medvol=ta.median(volume[1], 50)/100    //1 percent of median volume
curvol=volume/medvol        //current volume as percent of median volume

//======create High Volume markers

//===calculate volume cohorts
modvol=curvol<=120? 0: curvol<=150? 1: curvol<=180? 2: curvol<=210? 3: curvol>210? 4: 0  //assign Volume percents to cohorts

//=====volume cohorts booleans
v0=modvol==0     //unremarkable volume
v1=modvol==1     //much volume 120-150 percent (gray)
v2=modvol==2     //high volume 150-180 percent (orange)
v3=modvol==3     //huge volume 180-210 percent (blue)
v4=modvol==4     //extreme volume above 210 percent (maroon)

//======assign colors
cvol=v1? colC1: v2? colC2: v3? colC3: v4? colC4: na   //color.gray:v2?color.red:v3?color.rgb(30, 52, 180):v4?color.maroon:color.white

//===================================================================================================================================================
//Calculate falter
//closup and closdn are already 'native'
//other REVE direction calculation confirms if matching, non matching direction is falter
cl=math.avg(close,2)
pr=cl[2]
op=math.avg(open,2)
up=cl>pr and cl>op
dn=cl<pr and cl<op
falter=not up and not dn or (up and closdn) or (dn and closup)

//==== conclusion:
dirup=closup and not v0//gets triangle up v0 doesn't get a signal
dirdn=closdn and not v0//gets triangle down
dirf0= falter //gets circle as price movement falters

//====================================================================================================================================================
//place volume signal triangles and falter circles

//===initialise labels
var label lbdn = na //for triangle pointing down placed over downpointing column
//var label lbsq = na //for square over downpointing column
var label lbup = na //for triangle pointing up under uppointing column
var label lbcir = na //for falter circle

//====create labels when conditions apply
lbdn:=dirdn?label.new(bar_index, 0, color=cvol, style=label.style_triangledown, size=size.auto):na
lbup:=dirup?label.new(bar_index, 0,color=cvol, style=label.style_triangleup, size=size.auto):na
lbcir:=dirf0?label.new(bar_index, closup?70:-70, color=color.black, style=label.style_circle, size=size.auto):na


//=====================================================================================================================================================
//create evaluation

//======texts
//====pretexts for ticktext
ftext=falter?"F":""
wtext=wide?"wide ":small?"small ":""
dtext=closup?"up":"down"
ticktext=wtext+ftext+dtext //+ctext

//===other texts
trendtext=bzone? "S uptrend": gzone? "uptrend":ozone? "downtrend": rzone?"S downtrend":"sideways"
voltext=not present?"no volume":v0?"normal vol": v1?"much vol": v2?"high vol":
  v3?"huge vol": "extreme vol"
movtext=rise?"rising":soar?"soaring":drop?"dropping":plunge?"plunging":"transition"

//======table
//var evaluation = table.new(position.top_right, columns=4, rows=1, frame_color=framcol, frame_width=2)
var evaltop = table.new(position.top_right,1,2) 
var evalbot = table.new(position.bottom_right,1,2)

if evalwish==true
    table.cell(evaltop,0,0,movtext,text_size=size.small,height=25,text_halign=text.align_right,text_valign=text.align_top)
    table.cell(evaltop,0,1,trendtext,text_size=size.small,height=30,text_halign=text.align_right,text_valign=text.align_top)
    table.cell(evalbot,0,0,ticktext,text_size=size.small,height=30,text_halign=text.align_right,text_valign=text.align_bottom)
    table.cell(evalbot,0,1,voltext,text_size=size.small,height=20,text_halign=text.align_right,text_valign=text.align_bottom)
else
    table.clear(evaltop,0,0,0,0)
    table.clear(evalbot,0,0,0,0)
````
