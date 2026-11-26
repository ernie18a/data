# Intrangle - Straddle / Strangle

- url: https://www.tradingview.com/script/BWsF0S4k-Intrangle-Straddle-Strangle/
- type: indicator
- pine_id: PUB;FsIZ6pOkdHpbYto9jDicZkZurI4fij6d
- version: 1.0

## Description

[b]Intrangle[/b] is an indicator to assist Nifty / Bank Nifty Option Writers / Sellers to identify the PE / CE legs to Sell for Straddle and Strangle positions for Intraday. 
[b]Basic Idea[/b]: (My Conclusion for making this Indicator)
1)	Last 10 Years data says Nifty / Bank Nifty More than 66% of times Index are sideways or rangebound (within 1% day) .
2)	Mostly, First one hour high and low working as good support and resistance.
Once First one hour complete, this indicator will show Strangle High (CE), Strangle Low (PE) and Straddle (CE/PE).
[b]Straddle:[/b]
If you want to do straddle strategy, sell at the money strike (CE/PE) when price comes near to the straddle line (black line), 
[b]Strangle:[/b]
If you want to do Strangle strategy, sell Strangle High (CE) and Strangle Low (PE) when price comes near to the straddle line (black line). Both Strangle High and Low will be out of the money when price near to the straddle line (black line).

[b]Adjustment:[/b] option adjustment to be done based on the price movement. Adjustment purely up to the user / trader.

[b]Note1:[/b] If price not comes to near straddle line after first hour, better to stay light… 

[b]Note2:[/b] If first hour not giving wide High / Low, don’t use strangle strike based on this indicator. Straddle can be done any day with require adjustment / hedge. This Indicator is purely for education purpose, user / trader has to be back-tested before their start using it. 

This indicator will work in Nifty / Bank Nifty only. Best Time frames are 3/5/15 Mins. This is purely made for Intraday

Happy Trading 😊

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Saravanan_Ragavan

//@version=4

//Intrangle is an indicator to assist Nifty / Bank Nifty Option Writers / Sellers to identify the PE / CE legs to Sell for Straddle and Strangle positions. 

//Basic Idea: (My Conclusion for making this Indicator)
//1)	Last 10 Years data says Nifty / Bank Nifty More than 66% of times Index are sideways or rangebound (within 1% day) .
//2)	Mostly, First one hour high and low working as good support and resistance.

//Once First one hour complete, this indicator will show Strangle High (CE), Strangle Low (PE) and Straddle (CE/PE).

//Straddle:
//If you want to do straddle strategy, sell at the money strike (CE/PE) when price comes near to the straddle line (black line), 

//Strangle:
//If you want to do Strangle strategy, sell Strangle High (CE) and Strangle Low (PE) when price comes near to the straddle line (black line). Both Strangle High and Low will be out of the money when price near to the straddle line (black line).

//Adjustment: option adjustment to be done based on the price movement. Adjustment purely up to the user / trader.

//Notes: If first hour not giving wide High / Low, don’t use strangle strike based on this indicator. Straddle can be done any day with require adjustment / hedge. This Indicator is purely for education purpose, user / trader has to be back-tested before their start using it. 

// Happy Trading 😊




study("Intrangle - Straddle / Strangle", shorttitle="Intrangle", overlay=true)

Lo = security(symbol=syminfo.tickerid, resolution="60", expression=low)
Hi = security(symbol=syminfo.tickerid, resolution="60", expression=high)

// Time Period for different purposes
T1 = time(timeframe.period, "1015-1016")
T2 = time(timeframe.period, "1015-1530")
T3 = time(timeframe.period, "0915-1014")


// Bg Color for first One Hour
bgcolor(T3 ? color.gray : color.white)

// One Hour High Low
one_hour_Low = valuewhen(T1, Lo, 0)
one_hour_High = valuewhen(T1, Hi, 0)



nifty_high_test = round(one_hour_High/50,0) * 50
bnifty_high_test = round(one_hour_High/100,0) * 100

nifty_low_test = round(one_hour_Low/50,0) * 50 
bnifty_low_test = round(one_hour_Low/100,0) * 100




n_strangle_high = (nifty_high_test < one_hour_High ? nifty_high_test +50 : nifty_high_test) 
bn_strangle_high = (bnifty_high_test < one_hour_High ? bnifty_high_test +100 : bnifty_high_test) 


n_strangle_low = (nifty_low_test > one_hour_Low ? nifty_low_test - 50 : nifty_low_test) 
bn_strangle_low = (bnifty_low_test > one_hour_Low ? bnifty_low_test - 100 : bnifty_low_test) 



straddle = ( (syminfo.root=="NIFTY") ? ((n_strangle_high+n_strangle_low)/2) : (syminfo.root=="BANKNIFTY") ? ((bn_strangle_high+bn_strangle_low) / 2 ) :na )

strangle_high = ( (syminfo.root=="NIFTY") ? n_strangle_high : (syminfo.root=="BANKNIFTY") ? bn_strangle_high : na )
strangle_low = ( (syminfo.root=="NIFTY") ? n_strangle_low : (syminfo.root=="BANKNIFTY") ? bn_strangle_low : na )


plot(T2 ? strangle_low :na, "Strangle Low", style=plot.style_linebr, linewidth=2)
plot(T2 ? strangle_high:na, "Strangle High", style=plot.style_linebr, linewidth=2)



plot(T2 ? straddle:na, "Straddle", style=plot.style_linebr, linewidth=2, color=color.black)


Z2 = valuewhen(T1, bar_index, 0)

StraddleLabel = label.new(Z2, straddle + 3 , textcolor=color.black, style=label.style_none, size=size.large, text=tostring(straddle))
StraddleText = label.get_text(id=StraddleLabel)
label.set_text(StraddleLabel, text= "           Straddle  " + StraddleText + "   CE / PE")



StranglehLabel = label.new(Z2, strangle_high + 3 , textcolor=color.green, style=label.style_none, size=size.large, text=tostring(strangle_high))
StranglehText = label.get_text(id=StranglehLabel)
label.set_text(StranglehLabel, text= "      Strangle " + StranglehText + "   CE")


StranglelLabel = label.new(Z2, strangle_low - 3 , textcolor=color.red, style=label.style_none, size=size.large, text=tostring(strangle_low))
StranglelText = label.get_text(id=StranglelLabel)
label.set_text(StranglelLabel, text= "      Strangle " + StranglelText + "   PE")
````
