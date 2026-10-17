# Institutional Levels BEOA

- url: https://www.tradingview.com/script/Gb5hPFxD-Institutional-Levels-BEOA/
- type: indicator
- pine_id: PUB;388844b48ddb4b318f4aae89214b50e1
- version: 1.0

## Description

Full Figure ( Black )

20 Niveau ( orange )

40 Niveau ( Red )

50 Niveau ( Yellow )

60 Niveau ( Green )

80 Niveau ( Blue )

## Source Code

````pine
//@version=6
indicator("Institutional Levels PRO", overlay=true, max_lines_count=500)

daysBack = input.int(1, "Days Back", minval=1)
rangePoints = input.int(5000, "Range (+/- points)", minval=1000)

var line[] lines = array.new_line()

// Starttid
startTime = timenow - daysBack * 24 * 60 * 60 * 1000

// Nærmeste 100-niveau
base = int(math.floor(close / 100.0) * 100)

lowestLevel = base - rangePoints
highestLevel = base + rangePoints

if barstate.islast

    // Slet gamle linjer
    while array.size(lines) > 0
        line.delete(array.pop(lines))

    // Rund ned til nærmeste 100
    firstHundred = int(math.floor(lowestLevel / 100.0) * 100)

    // Tegn alle niveauer
    for hundred = firstHundred to highestLevel by 100

        int[] offsets = array.from(0, 20, 40, 50, 60, 80)

        for i = 0 to array.size(offsets) - 1

            offset = array.get(offsets, i)
            level = hundred + offset

            if level >= lowestLevel and level <= highestLevel

                lineColor =
                     offset == 0  ? color.black :
                     offset == 20 ? color.orange :
                     offset == 40 ? color.red :
                     offset == 50 ? color.yellow :
                     offset == 60 ? color.lime :
                     offset == 80 ? color.blue :
                     color.gray

                l = line.new(
                     x1 = startTime,
                     y1 = level,
                     x2 = time,
                     y2 = level,
                     xloc = xloc.bar_time,
                     extend = extend.right,
                     color = lineColor,
                     width = 1)

                array.push(lines, l)
````
