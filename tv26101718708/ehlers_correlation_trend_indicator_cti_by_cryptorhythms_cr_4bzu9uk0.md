# Ehlers Correlation Trend Indicator CTI by Cryptorhythms [CR]

- url: https://www.tradingview.com/script/4bzu9UK0-Ehlers-Correlation-Trend-Indicator-CTI-by-Cryptorhythms-CR/
- type: indicator
- pine_id: PUB;YwCVIh58WvHb0LcHKdmhRKj250UPNxuw
- version: 1.0

## Description

[b]Ehlers Correlation Trend Indicator CTI by Cryptorhythms [CR][/b]

[b]📜Intro[/b]
In his article “Correlation As A Trend Indicator” in issue May 2020 of TASC, author John Ehlers introduces a new trend indicator that is based on the correlation between a security’s price history and the ideal trend: a straight line. He describes methods for using the indicator to not only identify the onset of new trends but to identify trend failures as well.  He presents what looks like a simple and elegant idea for a trend-detection and mode-switching indicator.

[b]📋Comments[/b]
Careful market selection may be the key to a correct application of the indicator. Even such barebone rules could shine with stocks like AAPL that tend to develop prolonged trends. But for others like CAT, which can keep oscillating in ranges for years, results will be much less impressive. They require a different approach. For example, you would want to buy when Correlation Trend falls significantly below zero and sell when it reaches positive values. 

Therefore, it would be an interesting problem to research Correlation Trend’s ability to identify the switch to a cycle mode. That might help develop countertrend systems and 
trade pullbacks. Another possible application might be to act as a system filter of change from trending mode to mean-reversion mode.

[b]Extras[/b]
As usual when porting indicators to the library here on tradingview, I like to add some extra flare!

💠Customizable Overbought and Oversold Zones for Alert Creation
💠Bar coloration based on trade state for easy visual at a glance chart checking
💠Some basic example Entry and Exit conditions and a simple Trade State Engine to get you going creating your own strategy

[b]Enjoy![/b]
👍 We hope you enjoyed this indicator and find it useful! We post free crypto analysis, strategies and indicators regularly. This is our 81st script on Tradingview!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Correlation Trend Indicator (c) 2013-2019 John F. Ehlers TASC May 2020 Issue

//@version=4
study("Ehlers Correlation Trend Indicator CTI by Cryptorhythms [CR]",max_bars_back=5000)
X = 0.0, Y = 0.0, Corr = 0.0, Sx = 0.0, Sy = 0.0, Sxx = 0.0, Sxy = 0.0, Syy = 0.0, position = 0
Length     =input(20, "Length")
yes0       = input(title="Enable Overbought / Oversold Zones?", type=input.bool, defval=true)
OverBought = input(0.5, "Overbought Threshold")
OverSold   = input(- 0.5, "Oversold Threshold")
yes1       = input(title="Enable Bar Color by Trade?", type=input.bool, defval=true)

result     = for count = 0 to (Length - 1)
    X     := close[count]
    Y     := -count
    Sx    := Sx + X
    Sy    := Sy + Y
    Sxx   := Sxx + X*X
    Sxy   := Sxy + X*Y
    Syy   := Syy + Y*Y
    
if (Length*Sxx - Sx*Sx > 0) and (Length*Syy - Sy*Sy > 0) 
    Corr  := (Length*Sxy - Sx*Sy) / sqrt((Length*Sxx - Sx*Sx)*(Length*Syy - Sy*Sy))
plot         (Corr, color=color.aqua, linewidth=1)
plot         (0, "Zero Line", color=color.teal, style=plot.style_circles)

//Long/Short Conditions - Something I added
entryL      = input(false, "Long: True = Enter on Zero Line Cross / False = Enter OS Cross?")
entryNumL   = entryL==true ? 0 : entryL==false ? OverSold : na
exitL       = input(false, "Long: True = Exit on Zero Line Cross / False = Exit OB Cross?")
exitNumL    = exitL==true ? 0 : exitL==false ? OverBought : na

entryS      = input(false, "Short: True = Enter on Zero Line Cross / False = Enter OB Cross?")
entryNumS   = entryS==true ? 0 : entryS==false ? OverBought : na
exitS       = input(false, "Short: True = Exit on Zero Line Cross / False = Exit OS Cross?")
exitNumS    = exitS==true ? 0 : exitS==false ? OverSold : na

//Trade State Engine - Something I added
longCond   = crossover( Corr, entryNumL) and position==0
exitLong   = crossunder(Corr, exitNumL) and position==1
shortCond  = crossunder(Corr, entryNumS) and position==0
exitShort  = crossover( Corr, exitNumS) and position==2
position  := longCond ? 1 : exitLong ? 0 : shortCond ? 2 : exitShort ? 0 : position[1]

//OB/OS Zones - Something I added
p1         = plot(yes0 ? 1 : na, color=#FF02FF, transp=100)
p2         = plot(yes0 ? -1 : na, color=#FF02FF, transp=100)
p3         = plot(yes0 ? OverBought : na, "OverBought", color=#51CFEE)
p4         = plot(yes0 ? OverSold : na, "OverSold", color=#FF02FF)
fill         (p3, p1, color=#51CFEE, transp=80)
fill         (p4, p2, color=#770043, transp=80)

//Trade State Bar Coloration - Something I added
barcolor(yes1 ? position==1 ? color.lime : position==2 ? color.red : color.gray : na)
````
