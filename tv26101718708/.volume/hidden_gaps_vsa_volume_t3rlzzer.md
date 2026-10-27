# Hidden Gap`s VSA Volume

- url: https://www.tradingview.com/script/T3rlZZeR-Hidden-Gap-s-VSA-Volume/
- type: indicator
- pine_id: PUB;Rbu7QbjBhjcf1PoN7RKadIVKCeGj7OVr
- version: 1.0

## Description

If Volume is less then the previous 20 intervals, Volume is gray.
 If Volume is greater then the previous 40 intervals, Volume is black.
 If Volume is less then the previous 2 intervals, Volume is purple.
 If Volume is less then the previous, Volume is red.
 If Volume is greater then the previous, Volume is blue.
 Other - white.
 You can add on the indicator a 2.5 Standart Deviation of a 20 period 
 Bollinger Band Shifted 3 periods forward.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 20/06/2017
// If Volume is less then the previous 20 intervals, Volume is gray.
// If Volume is greater then the previous 40 intervals, Volume is black.
// If Volume is less then the previous 2 intervals, Volume is purple.
// If Volume is less then the previous, Volume is red.
// If Volume is greater then the previous, Volume is blue.
// Other - white.
// You can add on the indicator a 2.5 Standart Deviation of a 20 period 
// Bollinger Band Shifted 3 periods forward.
////////////////////////////////////////////////////////////
study(title="Hidden Gap`s VSA Volume")
Length_HH = input(40, minval=1)
Length_LLSmall = input(2, minval=2)
Length_LLBig = input(20, minval=2)
LengthMA    = input(20, minval=1)
hline(0, color=gray, linestyle=dashed)
xSMA_vol = sma(volume, LengthMA)
xHH_vol = highest(volume, Length_HH)
xLL_volSmall = lowest(volume, Length_LLSmall)
xLL_volBig = lowest(volume, Length_LLBig)
BarColor = iff(volume > xHH_vol[1], black,
             iff(volume < xLL_volBig[1], gray,
              iff(volume < xLL_volSmall[1], purple,
               iff(volume > volume[1], blue, 
                 iff(volume < volume[1], red, white)))))
pos = iff(volume > xSMA_vol, -1,
	     iff(volume < xSMA_vol, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )                   
plot(volume, color=BarColor, title="Vol", style=histogram, linewidth=2)
plot(xSMA_vol, color=black, title="SMA")
````
