# Intial Balance VAH/VAL/POC

- url: https://www.tradingview.com/script/DIguNUFF-Intial-Balance-VAH-VAL-POC/
- type: indicator
- pine_id: PUB;4c47f4aa6ebd40f6b253202b79505dea
- version: 1.0

## Description

This is an indicator that can be used to show the Initial Balance volume area profile. The initial balance occurs during the first hour, 9:30 - 10:30 and those lines remain fixed throughout the day. The vol profile bars are also part of what this says, a P shaped profile, for instance, with a move above VAH suggests a trending day up.

## Source Code

````pine
//@version=6
indicator("Intial Balance VAH/VAL/POC", 
overlay = true, 
max_lines_count = 50
)

profileSession = input.session("0930-1030", "Profile time window",display = display.data_window)
displaySession = input.session("0930-1600", "Line display window",display = display.data_window)
sessionTz      = input.string("America/New_York", "Session timezone",display = display.data_window)
lowerTf        = input.timeframe("1", "Lower timeframe source",display = display.data_window)
rows           = input.int(80, "Profile rows", minval = 20, maxval = 200,display = display.data_window)
vaPercent      = input.float(70.0, "Value area %", minval = 50, maxval = 99,display = display.data_window)
maxIntrabars   = input.int(2000, "Max intrabars stored", minval = 100, maxval = 10000,display = display.data_window)

inProfileWindow = not na(time(timeframe.period, profileSession, sessionTz))
newProfile      = inProfileWindow and not inProfileWindow[1]
showPlots       = not na(time(timeframe.period, displaySession, sessionTz))

[hiLtf, loLtf, volLtf] = request.security_lower_tf(
     syminfo.tickerid,
     lowerTf,
     [high, low, volume]
)

var float[] hiArr  = array.new_float()
var float[] loArr  = array.new_float()
var float[] volArr = array.new_float()

var int profileStartTime = na

var line vahLine = na
var line valLine = na
var line pocLine = na

if newProfile
    array.clear(hiArr)
    array.clear(loArr)
    array.clear(volArr)
    profileStartTime := time

if inProfileWindow
    ltfCount = array.size(hiLtf)

    if ltfCount > 0
        for i = 0 to ltfCount - 1
            if array.size(hiArr) < maxIntrabars
                array.push(hiArr, array.get(hiLtf, i))
                array.push(loArr, array.get(loLtf, i))
                array.push(volArr, array.get(volLtf, i))

float vah = na
float val = na
float poc = na

profileCount = array.size(hiArr)

if profileCount > 1
    float profileHigh = array.max(hiArr)
    float profileLow  = array.min(loArr)
    float profileRange = profileHigh - profileLow
    float step = profileRange / rows

    if step > 0
        float[] bins = array.new_float(rows, 0.0)
        float totalVol = 0.0

        for i = 0 to profileCount - 1
            barHigh = array.get(hiArr, i)
            barLow  = array.get(loArr, i)
            barVol  = array.get(volArr, i)

            firstBin = int(math.floor((barLow - profileLow) / step))
            lastBin  = int(math.floor((barHigh - profileLow) / step))

            firstBin := math.max(0, math.min(rows - 1, firstBin))
            lastBin  := math.max(0, math.min(rows - 1, lastBin))

            touchedBins = lastBin - firstBin + 1
            volPerBin = barVol / touchedBins

            for b = firstBin to lastBin
                array.set(bins, b, array.get(bins, b) + volPerBin)

            totalVol += barVol

        float maxVol = 0.0
        int pocBin = 0

        for b = 0 to rows - 1
            binVol = array.get(bins, b)

            if binVol > maxVol
                maxVol := binVol
                pocBin := b

        targetVol = totalVol * vaPercent / 100.0
        cumVol = array.get(bins, pocBin)

        lowBin = pocBin
        highBin = pocBin

        while cumVol < targetVol and (lowBin > 0 or highBin < rows - 1)
            upperVol = highBin < rows - 1 ? array.get(bins, highBin + 1) : -1.0
            lowerVol = lowBin > 0 ? array.get(bins, lowBin - 1) : -1.0

            if upperVol >= lowerVol
                highBin += 1
                cumVol += upperVol
            else
                lowBin -= 1
                cumVol += lowerVol

        poc := profileLow + (pocBin + 0.5) * step
        val := profileLow + lowBin * step
        vah := profileLow + (highBin + 1) * step

        lineEndTime = timestamp(
             sessionTz,
             year(time, sessionTz),
             month(time, sessionTz),
             dayofmonth(time, sessionTz),
             16,
             0
        )

        if na(vahLine)
            vahLine := line.new(profileStartTime, vah, lineEndTime, vah, xloc = xloc.bar_time, color = color.green, width = 2)
            valLine := line.new(profileStartTime, val, lineEndTime, val, xloc = xloc.bar_time, color = color.red, width = 2)
            pocLine := line.new(profileStartTime, poc, lineEndTime, poc, xloc = xloc.bar_time, color = color.yellow, width = 2)
        else
            line.set_xy1(vahLine, profileStartTime, vah)
            line.set_xy2(vahLine, lineEndTime, vah)

            line.set_xy1(valLine, profileStartTime, val)
            line.set_xy2(valLine, lineEndTime, val)

            line.set_xy1(pocLine, profileStartTime, poc)
            line.set_xy2(pocLine, lineEndTime, poc)

plot(showPlots ? vah : na, "VAH", color = color.green)
plot(showPlots ? val : na, "VAL", color = color.red)
plot(showPlots ? poc : na, "POC", color = color.yellow)
````
