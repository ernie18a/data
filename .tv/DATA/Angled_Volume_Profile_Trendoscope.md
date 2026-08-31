<!-- tradingview-pine-id: PUB;c4d2ca4647324422b584253978ff75d2 -->
<!-- tradingviewscripts-format: 1 -->
# Angled Volume Profile [Trendoscope®]

Source: https://www.tradingview.com/script/MgsLckWl-Angled-Volume-Profile-Trendoscope/

## Description

Volume profile is useful tool to understand the demand and supply zones on horizontal level. But, what if you want to measure the volume levels over trend line? In trending markets, the feature to measure volume over angled levels can be very useful for traders who use these measures. Here is an attempt to provide such tool.

🎲 How to use

🎯 Interactive input for selecting starting point and angle.
Upon loading the script, you will be prompted to select

[*] Start time and price - this is a point which you can select by moving the maroon highlighted label.
[*] End price - though this is shown as maroon bullet, this is price only input. Hence, when you click on the bullet, a horizontal line will appear. Users can move the line to use different End price.

Start and End price are used for identifying the angle at which volume profile need to be calculated. Whereas start time is used as starting time of the volume profile. Last bar of the chart is considered as ending bar.

[https://www.tradingview.com/x/0YhjFROR/](https://www.tradingview.com/x/0YhjFROR/)

🎯 Other settings.

From settings, users can select the colour of volume profile and style. Step multiplier defines the distance at which the profile lines needs to be drawn. Higher multiplier leads to less dense profile lines whereas lower multiplier leads to higher density of profile lines.

[https://www.tradingview.com/x/BqsBr9lH/](https://www.tradingview.com/x/BqsBr9lH/)

🎲 Limitations

🎯 Max 500 lines
Pinescript only allows max 500 lines on an indicator. Due to this, if we set very low multiplier - this can lead to more than 500 profile lines. Due to this some lines can get removed.
[https://www.tradingview.com/x/yInq5ZZ8/](https://www.tradingview.com/x/yInq5ZZ8/)

On the contrary, if multiplier is too high, then you will see very few lines which may not be meaningful.
[https://www.tradingview.com/x/V17PwBHE/](https://www.tradingview.com/x/V17PwBHE/)
Hence, it is important to select optimal multiplier based on your timeframe

🎯 No updates on new bar
Since the profile can spawn many bars, it is not possible to recalculate the whole volume profile when price creates new bars. Hence, there will not be visual update when new bars are created. But, to update the chart, users only need to make another movement of Start or ending point on interactive input.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd, Trendoscope®
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=6
import Trendoscope/LineWrapper/2 as LineWrapper

indicator('Angled Volume Profile [Trendoscope®]', 'AVP[Trendoscope®]', overlay = true, max_lines_count = 500, max_bars_back = 5000)
startX = input.time(0, 'StartX', inline = 'Start', group = 'Coordinates', confirm = true, display = display.none)
startY = input.price(0, 'StartY', inline = 'Start', group = 'Coordinates', confirm = true, display = display.none)

endY = input.price(0, 'EndY', inline = 'End', group = 'Coordinates', confirm = true, display = display.none)

precision = input.int(1000, 'Step Multiplier', minval = 10, step = 100, group = 'Properties', tooltip = 'Multiplier for min tick to define step between profile lines', display = display.none)
lineColor = input.color(color.yellow, '', inline = 'l', group = 'Display', display = display.none)
lineTransparency = input.int(80, '', minval = 0, maxval = 100, step = 5, inline = 'l', group = 'Display', display = display.none)
lineStyle = input.string(line.style_dotted, '', [line.style_dotted, line.style_dashed, line.style_solid], inline = 'l', group = 'Display', tooltip = 'Volume profile line color, transparency and style', display = display.none)

type VolumeProfileLine
	LineWrapper.Line profileLine
	float profileVolume = 0.0

method update(map<float, VolumeProfileLine> this, startXBar, endXBar, startXTime, endXTime, startXValue, endXValue, value) =>
    vLine = this.contains(startXValue) ? this.get(startXValue) : VolumeProfileLine.new(LineWrapper.Line.new(chart.point.new(startXTime, startXBar, startXValue), chart.point.new(endXTime, endXBar, endXValue), color = lineColor, style = lineStyle))
    vLine.profileVolume := vLine.profileVolume + value
    this.put(startXValue, vLine)
    this

roundtoprecision(price, step) =>
    multiplier = 1 / step
    int(price * multiplier) / (multiplier * 1.0)

method add(array<polyline> this, array<chart.point> points) =>
    this.push(polyline.new(points, false, false, xloc.bar_index, color.new(lineColor, lineTransparency), line_style = lineStyle))
    points.clear()

method flush(array<polyline> this) =>
    while this.size() != 0
        this.pop().delete()

var startXBar = 0
var startXTime = 0
var volumeProfiles = map.new<float, VolumeProfileLine>()

var label startLbl = label.new(startX, startY, '', xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.maroon, tooltip = 'Starting Point - Time+Price. Move this to change starting point')
var label endLbl = label.new(last_bar_time, endY, '', xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.maroon, tooltip = 'Ending Point - Only price can be changed. Ending bar is always the last bar')

var float diff = endY - startY
var float step = syminfo.mintick * precision
if time == startX
    startXBar := bar_index
    startXTime := time
    end = diff + close
    startPoint = chart.point.new(time, bar_index, close)
    endPoint = chart.point.new(last_bar_time, last_bar_index, end)
    vLine = LineWrapper.Line.new(startPoint, endPoint, color = lineColor, style = lineStyle)
    volumeProfiles.put(close, VolumeProfileLine.new(vLine, 0.0))

if time >= startX and not na(step)
    endXBar = last_bar_index
    endXTime = last_bar_time
    startDiff = diff * (bar_index - startXBar) / (endXBar - startXBar)
    endDiff = diff * (endXBar - bar_index) / (endXBar - startXBar)

    divisions = int((high - low) / step)
    for price = low to high by step
        startXValue = roundtoprecision(price - startDiff, step)
        endXValue = roundtoprecision(price + endDiff, step)
        volumeProfiles.update(startXBar, endXBar, startXTime, endXTime, startXValue, endXValue, volume / divisions)

    float maxVolume = na

    var bool draw = true
    if barstate.islast and draw
        draw := false
        for volumeProfile in volumeProfiles.values()
            maxVolume := nz(math.max(volumeProfile.profileVolume, maxVolume), volumeProfile.profileVolume)
            maxVolume

        array<chart.point> profilePoints = array.new<chart.point>()
        array<polyline> polyLineArrays = array.new<polyline>()

        polyLineArrays.flush()
        for volumeProfile in volumeProfiles.values()
            percent = volumeProfile.profileVolume * 100 / maxVolume
            newEndX = startXBar + math.floor((last_bar_index - startXBar) * percent / 100)
            newEndY = volumeProfile.profileLine.get_price(newEndX)
            newStartY = volumeProfile.profileLine.p1.price

            if percent != 0
                profilePoints.push(chart.point.from_index(startXBar, newStartY))
                profilePoints.push(chart.point.from_index(newEndX, newEndY))
                profilePoints.push(chart.point.from_index(startXBar, newStartY))

            if profilePoints.size() > 997
                polyLineArrays.add(profilePoints)

        polyLineArrays.add(profilePoints)
````
