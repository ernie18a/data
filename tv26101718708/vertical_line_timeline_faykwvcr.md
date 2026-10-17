# Vertical Line Timeline

- url: https://www.tradingview.com/script/faYkwVCR-Vertical-Line-Timeline/
- type: indicator
- pine_id: PUB;25820af0bf384dfc8d4af4b60ee092e6
- version: 1.0

## Description

Vertical Line Timeline for custom hours

Like London session
Ny session

and all other session

## Source Code

````pine
//@version=6
indicator("Vertical Line Timeline", overlay=true, scale=scale.none)

sess0 = input.float(17,   "Time 0")
sess1 = input.float(23,   "Time 1")
sess2 = input.float(23.3, "Time 2")
sess3 = input.float(2,    "Time 3")
sess4 = input.float(10.3, "Time 4")
sess5 = input.float(6,    "Time 5")
sess6 = input.float(8.3,  "Time 6")
sess7 = input.float(12.3, "Time 7")
sess8 = input.float(13,   "Time 8")
// sess9  = input.float(13, "Time 9")
// sess10 = input.float(15, "Time 10")

min0 = sess0 - math.floor(sess0)
cond0 = hour == math.floor(sess0) and minute == (min0 * 100)
plot(cond0 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.black, 60))

min1 = sess1 - math.floor(sess1)
cond1 = hour == math.floor(sess1) and minute == (min1 * 100)
plot(cond1 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.blue, 60))

min2 = sess2 - math.floor(sess2)
cond2 = hour == math.floor(sess2) and minute == (min2 * 100)
plot(cond2 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.blue, 60))

min3 = sess3 - math.floor(sess3)
cond3 = hour == math.floor(sess3) and minute == (min3 * 100)
plot(cond3 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.green, 60))

min4 = sess4 - math.floor(sess4)
cond4 = hour == math.floor(sess4) and minute == (min4 * 100)
plot(cond4 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.green, 60))

min5 = sess5 - math.floor(sess5)
cond5 = hour == math.floor(sess5) and minute == (min5 * 100)
plot(cond5 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.orange, 60))

min6 = sess6 - math.floor(sess6)
cond6 = hour == math.floor(sess6) and minute == (min6 * 100)
plot(cond6 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.orange, 60))

min7 = sess7 - math.floor(sess7)
cond7 = hour == math.floor(sess7) and minute == (min7 * 100)
plot(cond7 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.purple, 60))

min8 = sess8 - math.floor(sess8)
cond8 = hour == math.floor(sess8) and minute == (min8 * 100)
plot(cond8 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.purple, 60))

// min9 = sess9 - math.floor(sess9)
// cond9 = hour == math.floor(sess9) and minute == (min9 * 100)
// plot(cond9 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.maroon, 60))

// min10 = sess10 - math.floor(sess10)
// cond10 = hour == math.floor(sess10) and minute == (min10 * 100)
// plot(cond10 ? 10e20 : na, style=plot.style_histogram, color=color.new(color.maroon, 60))
````
