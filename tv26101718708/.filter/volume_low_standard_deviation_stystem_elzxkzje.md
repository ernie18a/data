# volume low standard deviation stystem

- url: https://www.tradingview.com/script/eLzxKzjE/
- type: strategy
- pine_id: PUB;v6yD0b1VWEr55bXavvBIdjBYExeL2kjc
- version: 1.0

## Description

On the basis of moving average, add moving average and standard deviation line of volume to filter the entry and exit time.
Filter entries and/or exits based on low volume
options = 1, no not enter on low volume
options = 2, exit on low volume
options = 3, both 1 and 2
For others, please refer to the code and notes。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("交易量底部标准差系统", overlay=true)

options = input(1,'')
length = input(40,'')
nlow = input(5,'')
factor = input(1.0,'')

vavg = 0.0
vavgn = 0.0
vsd = 0.0
lowlimit = 0.0
uplimit = 0.0
mavg = 0.0
aror = 0.0
adjvol = 0.0
savevol = 0.0


//Find average volume, replacing bad values
adjvol := volume

if (volume != 0)
	savevol := volume
else
	savevol := savevol[1]
	adjvol := savevol


// Replace high volume days because they distort standard deviation
if (adjvol > 2 * factor * nz(vsd[1]))
	adjvol := savevol
else
	adjvol := adjvol[1]

vavg := sma(adjvol,length)
vsd := stdev(adjvol,length)
vavgn := sma(adjvol,nlow)

// Extreme volume limits
lowlimit := vavg - factor * vsd
uplimit := vavg + 2 * factor * vsd

// System rules based on moving average trend
mavg := sma(close,length/2)

// Only enter on new trend signals
if (options == 2)
	if (mavg > mavg[1] and mavg[1] <= mavg[2])
		strategy.entry("Long", strategy.long)
	if (mavg<mavg[1] and mavg[1]>=mavg[2])
		strategy.entry("Short", strategy.short)
else
	if (mavg > mavg[1] and vavgn > lowlimit)
		strategy.entry("Long", strategy.long)
	if (mavg < mavg[1] and vavgn > lowlimit)
		strategy.entry("Short", strategy.short)

// Exit on low volume
if (options != 1)
	if (mavg<mavg[1] or (strategy.position_size > 0 and vavgn<= lowlimit))
		strategy.close("Long")
	if (mavg>mavg[1] or (strategy.position_size > 0 and vavgn<= lowlimit))
		strategy.close("Short")
else
	if (mavg < mavg[1])
		strategy.close("Long")
	if (mavg > mavg[1])
		strategy.close("Short")
````
