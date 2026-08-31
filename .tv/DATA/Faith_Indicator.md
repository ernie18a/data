<!-- tradingview-pine-id: PUB;iqm0QQ8h7ypMUiPWkepHx0QiXTn1GHVD -->
<!-- tradingviewscripts-format: 1 -->
# Faith Indicator

Source: https://www.tradingview.com/script/ev2TidhJ-Faith-Indicator/

## Description

This indicator compares buyers demand with sellers supply volumes and calculates which prevails. Therefore it only works if volume is published. Buyers demand is assumed for a period in which a higher high is reached with more volume. Sellers supply is recognized by a lower low combined with more volume.
The average of sellers supplies is subtracted from buyers demand, the result is graded because a statement like “The faith in this period was ## percent” has no meaning. We can conclude to more faith and less faith but not represent it in some exact number. 

This indicator assigns the following grades:
Very high faith graduated as 8 
High faith as 6
Good faith as 4
Some Faith as 2
Little Faith as 1
Neither Faith nor Distrust as zero
Self Protection Distrust graduated as -8
Fear Distrust as -6
Anxiety Distrust as -4
Suspicion Distrust as -2
Doubt Distrust as -1
It is presented as a histogram with blue staves pointing up (meaning faith) and red staves pointing down (meaning distrust)

The background is colored using the Hull Agreement Indicator (Hullag), which I published before. Hullag graduates price movements in five grades to which it assigns a background color. These are as follows:
grade 2: blue, clear upward movement
grade 1: green, some upward movement
grade 0: silver, neither upward nor downward movement
grade -1: maroon, some downward movement
grad -2: red, clear downward movement.

Use of the Faith Indicator:
The indicator shows price action/momentum as a background color and volume action analyzed as a grade of faith in the form of a histogram. Usually faith comes together with rising prices (blue/green background) and distrust with lowering prices (red/maroon background), however contrarian situations occur, e.g. lowering prices while the market has good faith. These can be explained by minority sellers who act contrary to the feelings in the market. You can then decide that this might be an unsustainable move of the quotes.
If the faith indicator confirms the price movement, you might assume that the move is meaningful and will go further. Also if you see faith diminishing you might assume that the move is coming to an end and the tide is going to turn.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eykpunter

//@version=4
study(title="Faith Indicator", shorttitle="Faith") //Buyers or Sellers Dominance or Faith of the Market

per = input(type=input.integer , title="periods for averaging" , defval=10)
up = high>high[1] and volume>volume[1]   //Buyers volume when both higher high and more volume
down = low<low[1] and volume>volume[1]   //Sellers volume when both lower low and more volume

vproc=volume/highest(volume, 30)*200     //Used for calculation of volume expansion in a kind of percentage
volup = up ? vproc : 0                   //Entered in the series of Buyers volume
voldown = down ? vproc : 0               //Entered in the series of Sellers volume

maup = sma(volup, per)                   //Average Buyers volume, sma and 10 periods seem to work best
madown = sma(voldown, per)               //Average Sellers volume

difvol = maup - madown                     //Faith of the market, i.e. buyers dominate the volume or sellers dominate it
u1 = difvol>60 ? 8 : 0                     //Very high faith graduated as 8
u2 = difvol>40 and difvol<=60 ? 6 : 0      //High faith as 6
u3 = difvol>20 and difvol<=40 ? 4 : 0      //Good faith as 4
u4 = difvol>10 and difvol<=20 ? 2 : 0      //Some Faith as 2
u5 = difvol>0 and difvol<=10 ? 1 : 0       //Little Faith as 1
d1 = difvol<-60 ? -8 : 0                   //Very High mistrust graduated as -8    
d2 = difvol<-40 and difvol >=-60 ? -6 : 0  //High Mistrust as -6
d3 = difvol<-20 and difvol >=-40 ? -4 : 0  //Bad Mistrust as -4 
d4 = difvol<-10 and difvol >=-20 ? -2 : 0  //Some Mistrust as -2
d5 = difvol<0 and difvol>=-10 ? -1 : 0     //Little Mistrust as -1
dif = u1+u2+u3+u4+u5+d1+d2+d3+d4+d5        //Grades are either zero or something, adding them all up gives the grade in this instance

plot(dif , "Grade of Faith" , dif > 0 ? color.blue : color.red , style=plot.style_histogram , transp=0 , linewidth=5)

//Backgroud colors taken from Hull Moving Average Agreement Indicator (Hullag)
fhl=20                                     //number of periods for fast Hull ma
shl=25                                     //number of periods for slow Hull ma
trnd=0.1                                   //minimum ATR difference required to call the ma a trend
istrend=trnd*atr(30)                       //Calculate minimum ATR as a kind of tangent

fh=hma(close, fhl)                         //fast Hull Moving Average
fangle=fh[0]-fh[1]                         //angle of fast hull slope calculated as a kind of tangent
var ftrend= 0                              //initialise fast trend graduation
ftrend:= fangle>istrend? 1:fangle<-istrend?-1:0 //fast trend either 1, 0 or -1 meaning uptrend, no trend, down trend

sh=hma(close, shl)                         //slow Hull Moving Average
sangle=sh[0]-sh[1]                         //angle of slow hull slope as a kind of tangent
var strend=0                               // initialise slow trend graduation
strend:= sangle>istrend? 1:sangle<-istrend? -1:0 //slow trend either 1, 0 or -1 meaning uptrend, no trend, down trend

hullag= ftrend+strend                      //possible graduations are 2, 1, 0, -1, -2
bg2 = color.new(color.blue,65)             //color when both hma agree on up trend, i.e. grade 2
bg1 = color.new(color.green,75)            //color when one hma has up trend, one no trend, i.e. grade 1
bg0 = color.new(color.silver,85)           //color when either both hma have no trend or have opposite trend, i.e. grad zero
bgm1 = color.new(color.maroon,80)          //color when one hma has down trend, one no trend, i.e. grade -1
bgm2 = color.new(color.red,65)             // color when both hma agree on down trend, i.e. grade -2
bgcolor(hullag==2?bg2: hullag==1?bg1: hullag==0?bg0: hullag==-1?bgm1: bgm2)
````
