<!-- tradingview-pine-id: PUB;ZT8ETlIbXoy3zMQtgrjcEPBS5lhQVMHB -->
<!-- tradingviewscripts-format: 1 -->
# Vortex MTF

Source: https://www.tradingview.com/script/lMirygPG-Vortex-MTF/

## Description

Understanding Vortex Indicator (VI)
The vortex indicator was first developed by Etienne Botes and Douglas Siepman who introduced the concept in the January 2010 edition of “Technical Analysis of Stocks & Commodities.” The vortex indicator is based on two trendlines: VI+ and VI-.

What is the Vortex Indicator (VI)?
A vortex indicator (VI) is an indicator composed of two lines - an uptrend line (VI+) and a downtrend line (VI-). These lines are typically colored green and red respectively. A vortex indicator is used to spot trend reversals and confirm current trends.

Vortex Indicator Calculations
The calculation for the indicator is divided into four parts.

1. True range (TR) is the greatest of:

Current high minus current low
Current high minus previous close
Current low minus previous close
2. Uptrend and downtrend movement:

VM+ = Absolute value of current high minus prior low
VM- = Absolute value of current low minus prior high
3. Parameter length (n)

Decide on a parameter length (between 14 and 30 days is common)
Sum the last n period’s true range, VM+ and VM-:
Sum of the last n periods’ true range = SUM TRn
Sum of the last n periods’ VM+ = SUM VMn+
Sum of the last n periods’ VM- = SUM VMn−
4. Create the trendlines VI+ and VI-

SUM VMn+/SUM TRn = VIn+
SUM VMn-/SUM TRn = VIn−
Repeating this process daily forms the VI+ and VI- trendlines.
The traditional application of using VI- and VI+ crossovers can result in a number of false trade signals when price action is choppy. Increase the number of periods used in the indicator to reduce this, for example, using 25 periods instead of 14.

What is MTF?
Multiple Time Frame Analysis is the technique of analyzing several time frames of the same asset before entering a trade. This type of analysis is best done using a top-down approach, i.e. starting at a higher time frame and working your way down, via several lower time frames, until the execution time frame is reached where a trade could be entered. Traders who use this technique usually look at 3 or 4 different time frames to identify the general trend and find the best entries. They minimize their risk and improve the odds of success simply by taking the bigger picture into account. It can easily be combined with any trading strategy.

Time frames are usually several times apart. For example a day trader who trades hourly charts, could analyse the weekly (high time frame), the daily (7 times smaller), the 4 hour (6 times smaller) and finally the hourly time frame (execution time frame, 4 times smaller). TradingView has a chart layout feature with multiple charts per layout, so you can analyse an asset on multiple time frames under one tab in your browser.

Summary
With MTF, you can see the Vortex indicator values for a specific time period without changing the graph time period.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © melihtuna
//@version=4
study(title="Vortex MTF", shorttitle="VI MTF")
period_ = input(14, title="Period", minval=2)
res = input("240", type=input.resolution, title="Resolution")
r = res == "" ? timeframe.period : res

VMP = sum(security(syminfo.tickerid, r, abs(high - low[1])), period_)
VMM = sum(security(syminfo.tickerid, r, abs(low - high[1])), period_)
STR = sum(security(syminfo.tickerid, r, atr(1)), period_)
VIP = VMP / STR
VIM = VMM / STR

plot(VIP, title="VI +", color=#3BB3E4)
plot(VIM, title="VI -", color=#FF006E)
````
