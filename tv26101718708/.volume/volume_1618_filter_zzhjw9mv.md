# Volume 1.618 Filter

- url: https://www.tradingview.com/script/zzHjw9MV-Volume-1-618-Filter/
- type: indicator
- pine_id: PUB;4044a2e19e9d43009050abae715361f8
- version: 1.0

## Description

//@version=5
indicator("Volume 1.618 Filter", overlay=false)

// Calculate 6-period SMA of volume
volMA = ta.sma(volume, 6)

// Calculate Fibonacci threshold
fibThreshold = volMA * 1.618

// Check if current volume exceeds threshold
highVol = volume > fibThreshold

// Plot volume bars
plot(volume,
     style=plot.style_columns,
     color=highVol ? color.lime : color.gray)

// Plot average volume
plot(volMA,
     color=color.blue,
     linewidth=2)

// Plot 1.618 threshold
plot(fibThreshold,
     color=color.orange,
     linewidth=2)

## Source Code

````pine
//@version=5
indicator("Volume 1.618 Filter", overlay=false)

// Calculate 6-period SMA of volume
volMA = ta.sma(volume, 6)

// Calculate Fibonacci threshold
fibThreshold = volMA * 1.618

// Check if current volume exceeds threshold
highVol = volume > fibThreshold

// Plot volume bars
plot(volume,
     style=plot.style_columns,
     color=highVol ? color.lime : color.gray)

// Plot average volume
plot(volMA,
     color=color.blue,
     linewidth=2)

// Plot 1.618 threshold
plot(fibThreshold,
     color=color.orange,
     linewidth=2)
````
