# Visible Range Support and Resistance [BigBeluga]

- url: https://www.tradingview.com/script/G8pmzCkC-Visible-Range-Support-and-Resistance-BigBeluga/
- type: indicator
- pine_id: PUB;cbb2382c65e546f2b5a450d1ab31669c
- version: 2.0

## Description

[b]🔵 OVERVIEW[/b]
[b]Visible Range Support and Resistance [BigBeluga][/b] is a dynamic support/resistance tool that analyzes price structure only within the visible range of your chart. It detects key levels based on clustered pivots inside a binned vertical range and highlights zones where price has historically reacted. The tool adjusts in real-time as you pan or zoom, offering adaptive precision at any scale.

[b]🔵 CONCEPTS[/b]
[list]
[*] [b]Pivot Clustering:[/b] Price highs/lows are collected into horizontal "bins" across the visible chart range. If multiple pivots align within a bin, that area is marked as a potential support or resistance zone.
[image]https://www.tradingview.com/x/g1G2leYZ/[/image]
[*] [b]Visible Range Only:[/b] Calculations are limited strictly to the bars currently visible on the chart. Zooming or panning changes the result.
[image]https://www.tradingview.com/x/R4nt70mK/[/image]
[image]https://www.tradingview.com/x/g8Qo9ySr/[/image]
[*] [b]Bin System:[/b] The visible high-to-low range is divided into 100 horizontal zones (bins) to group pivots and detect confluence.
[*] [b]Multi-Threshold Detection:[/b] Users can enable two separate S/R detection levels with different pivot count thresholds for more nuanced signals. The more pivot points a level has, the thicker and richer the color.
[image]https://www.tradingview.com/x/OOlO7Syo/[/image]
[*] [b]Directional Context:[/b] Labels include arrows (▲ or ▼) to show whether the current price is above (support) or below (resistance) each zone.
[image]https://www.tradingview.com/x/Bmo7rqCx/[/image]
[*] [b]Range Boundaries:[/b] The top and bottom of the visible range are marked with dashed lines and labeled as [i]Top Range[/i] and [i]Bottom Range[/i].
[image]https://www.tradingview.com/x/ILB5QmMI/[/image]
[/list]

[b]🔵 FEATURES[/b]
[list]
[*] Detects S/R zones based on the number of pivots found within each price bin.
[*] 100 horizontal bins divide the visible price range, allowing high resolution detection.
[*] Only uses data from visible bars—zooming out recalculates the indicator for more data.
[*] Customizable number of pivot confirmations (e.g., 2, 3, 4, 5) before a level is shown.
[b]5 Pivots[/b]
[image]https://www.tradingview.com/x/CjfcAMFp/[/image]
[*] Dual-level detection lets you show stronger and weaker zones separately.
[*] Automatically colors support (green) and resistance (blue) with dynamic intensity.
[*] Labels show pivot count and direction (support/resistance).
[*] Automatic cleanup of overlapping levels for visual clarity.
[*] Dashed top/bottom range markers help define the visible scope.
[*] Session SMA calculates from the visible range start (from the chart edge)
[image]https://www.tradingview.com/x/tm6ayCRg/[/image]
[*] Visible range bars count
[image]https://www.tradingview.com/x/PpjfCAix/[/image]
[/list]

[b]🔵 HOW TO USE[/b]
[list]
[*] [b]Zoom in[/b] for precise intra-range support and resistance zones based on current structure.
[*] [b]Zoom out[/b] to load more pivot data and identify long-term levels.
[*] Use the pivot threshold (e.g., 3 or 4) to control signal strength—higher = stronger levels.
[*] Watch for price reactions or breakouts around high-pivot zones to identify key areas.
[*] Combine with trend, volume, or order flow tools to confirm the relevance of each S/R zone.
[*] Adjust line and label colors for better contrast with your chart theme.
[/list]

[b]🔵 CONCLUSION[/b]
[b]Visible Range Support and Resistance [BigBeluga][/b] is a smart, range-sensitive tool for mapping meaningful horizontal levels. By scanning only what you see on the screen, it provides an adaptive edge to traders focused on real-time price action. Whether you’re scalping short-term zones or zooming out for macro structure, this tool flexes with your view to keep the most relevant levels front and center.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Visible Range Support and Resistance [BigBeluga]", "VR SR [BigBeluga]", overlay = true, max_lines_count = 500, max_boxes_count = 500, calc_bars_count = 5000)


// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

displaySr1   = input.bool(true, "", inline = "1")
srPivotsQty  = input.int(2, "Pivots", options = [2, 3, 4, 5], tooltip = "How many pivots to collect, before plot level", inline = "1")
displaySr2   = input.bool(false, "", inline = "2")
srPivotsQty1 = input.int(4, "Pivots", options = [2, 3, 4, 5], tooltip = "How many pivots to collect, before plot level", inline = "2")
supColor     = input.color(#1ee585, "Support")
resColor     = input.color(#1e8be5, "Resistance")
bgColor      = input.color(color.rgb(255, 255, 255, 98), "Background Color")
smaCol       = input.color(color.yellow, "Session SMA Color")

type sr 
    line level 
    label lbl

var pivots    = array.new<float>()
var bins      = 100
var pivotBins = array.new<int>(bins, 0)
var BinsPivot = array.new<float>(bins, 0.)
var topLow    = array.new<float>()
var SR        = array.new<sr>()
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

leftChart = chart.left_visible_bar_time
atr       = ta.atr(200) * 0.2

ph = ta.pivothigh(2, 2)
pl = ta.pivotlow(2, 2)


tStep = time - time[1]
bgcolor(time-tStep*2 > leftChart ? bgColor : na)

// @function clean up overlapped levels
cleanupOverlap(self, threshold) =>

    if self.size() > 0
        for i = self.size() - 1 to 1
            sr1 = self.get(i)
            price1 = sr1.level.get_y1()
            
            sr1.level.set_x2(last_bar_time)
            sr1.lbl.set_x(last_bar_time)

            for j = i - 1 to 0 
                sr2 = self.get(j)
                price2 = sr2.level.get_y1()
                sr2.level.set_x2(last_bar_time)
                sr2.lbl.set_x(last_bar_time)

                if math.abs(price1 - price2) < threshold
                    sr2.level.delete()
                    sr2.lbl.delete()

                    self.remove(j)
                    break  


// Store viaibile range pivots and high/low values
var len = 1
if time > leftChart
    len += 1
    switch
        not na(ph) => pivots.push(ph)
        not na(pl) => pivots.push(pl)
    topLow.push(high)
    topLow.push(low)


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
sessionBars = int((time-leftChart)/tStep)
sma = ta.sma(close, len)

plot(time > leftChart ? sma : float(na), title = "Session SMA", color = smaCol)

var dash = table.new(position.top_right, 1, 1, chart.bg_color)

if barstate.islast

    dash.cell(0, 0, "Visible Range Bars: "+ str.tostring(sessionBars), text_color = color.gray)

    top  = topLow.max()
    bot  = topLow.min()
    step = (top-bot)/bins

    // Clean arrays
    for i = 0 to bins -1 
        pivotBins.set(i, 0)
    for i = 0 to bins -1 
        BinsPivot.set(i, 0.)

    for k = 0 to bins - 1
        lower = bot + step * k
        mid   = lower + step/2

        for i = 0 to pivots.size() - 1
            getPivot = pivots.get(i)
            closeTo  = math.abs(getPivot-mid) < atr

            if closeTo  // if pivot close to the middle of the bin add +1 to the pivotBins and store pivot value at BinsPivot
                pivotBins.set(k, pivotBins.get(k) + 1)
                BinsPivot.set(k, getPivot)

        BinsValue = pivotBins.get(k)
        pivot     = BinsPivot.get(k)
        mColor    = close > mid ? supColor : resColor
        direction = close > mid ? "▲" : "▼"
        srColor   = color.from_gradient(BinsValue, 0, 5, color.new(color.black, 100), mColor)

        if BinsValue == srPivotsQty and displaySr1
            lvl = line.new(leftChart, pivot, last_bar_time, pivot, xloc.bar_time, color = srColor, width = srPivotsQty)
            lbl = label.new(last_bar_time, pivot, str.tostring(BinsValue)+ " Pivots"+direction, xloc.bar_time, style = label.style_label_left, textcolor = chart.fg_color, color = color.new(color.black, 100))
            SR.push(sr.new(lvl, lbl))

        if BinsValue == srPivotsQty1 and displaySr2
            lvl = line.new(leftChart, pivot, last_bar_time, pivot, xloc.bar_time, color = srColor, width = srPivotsQty1)
            lbl = label.new(last_bar_time, pivot, str.tostring(BinsValue)+ " Pivots"+direction, xloc.bar_time, style = label.style_label_left, textcolor = chart.fg_color, color = chart.bg_color, force_overlay = true)
            SR.push(sr.new(lvl, lbl))

    // Top/Bottom Range levels
    line.delete(line.new(leftChart, top, last_bar_time, top, xloc.bar_time, color = resColor, style = line.style_dashed)[1])
    line.delete(line.new(leftChart, bot, last_bar_time, bot, xloc.bar_time, color = supColor, style = line.style_dashed)[1])

    label.delete(label.new(last_bar_time - (last_bar_time-leftChart)/2, top, "Top Range\n" + str.tostring(top, "(##,###,###.###)") + "\n▼", xloc = xloc.bar_time, textcolor = chart.fg_color, color = color.new(color.black, 100), style = label.style_label_down)[1])
    label.delete(label.new(last_bar_time - (last_bar_time-leftChart)/2, bot,  "▲\n" + str.tostring(bot, "(##,###,###.###)") + "\nBottom Range", xloc = xloc.bar_time, textcolor = chart.fg_color, color = color.new(color.black, 100), style = label.style_label_up)[1])

    // Clean Levels
    cleanupOverlap(SR, atr*10)
// }
````
