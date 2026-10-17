# Moving average cloud strategy

- url: https://www.tradingview.com/script/6P5ZiEpk-Moving-average-cloud-strategy/
- type: indicator
- pine_id: PUB;WR05g0jB4pwXwmB1KdxNxxZpfFkJutzH
- version: 1.0

## Description

Hi folks!

Here a script uses the moving average cloud. A sma (50, aqua) and a sma (200, olive) are plotted on the cart. When both sma go up the cloud is green. When both sma go down the cloud is red. When sma (200, olive) goes down and sma (50, aqua) goes up the cloud is orange. When sma (200, olive) goes up and sma (50, aqua) goes down the cloud is lime.

There three entry points in this strategy.

Long
Aggressive: When the cloud turns orange and price closes above the sma (200).
Neutral: When the both sma make the golden cross.
Cautious: When the cloud is green and price closes sma (200) after searching for support. So not when there's a great distance between them.

In case you missed the entry point you can jump in when price CLOSES above sma (50). So after it searched for support on that line. The cloud has to be green at that moment. 

Short
Aggressive: When the cloud turns lime and price CLOSES below the sma (200).
Neutral: When the both sma make the death cross.
Cautious: When the cloud is green and price is above the sma (200).

In case you missed the entry point you can jump in when price CLOSES above sma (50). So after it searched for support on that line.

There are also two exit points in this strategy.
Cautious: When price closes on the other side of the sma (50).
Neutral: When the cloud changes color.
Aggressive: When price closes on the other side of the sma (200). There's always the opportunity that the price searches for support at the sma (200) line and goes from that moment in the direction you want.

Don't wait for the cross of the both sma. Very usually you give a huge part of your profit away at that point.

Remember: Above the cloud is bullish area, never go short there. Below the cloud is bearish area, never go long there.

Remember 2: When the clouds changes rapidly from color we're not in a trend. The sma (200) will be almost flat at those situations. It's a sign not to go into a trade since the market doesn't know in which direction it will go.

## Source Code

````pine
//@version=3
study("My Script", overlay=true)
smaShort=sma(close,50)
smaLong=sma(close,200)

fillColor = smaShort >= smaShort[1] and smaLong >=smaLong[1] ? color(green,50) : smaShort <= smaShort[1] and smaLong >=smaLong[1] ? color(lime,50) : smaShort <= smaShort[1] and smaLong <=smaLong[1] ? color(red,50) : smaShort >= smaShort[1] and smaLong <=smaLong[1] ? color(orange,50) : na

p1 = plot(smaShort,color=aqua, linewidth=3)
p2 = plot(smaLong,color=olive,linewidth=3)

fill(p1,p2,color=fillColor)
plot(close)
````
