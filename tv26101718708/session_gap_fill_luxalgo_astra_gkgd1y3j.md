# Session Gap Fill [LuxAlgo] astra

- url: https://www.tradingview.com/script/gkGd1y3j-Session-Gap-Fill-LuxAlgo-astra/
- type: indicator
- pine_id: PUB;ecbee8b8067342d2b5a085ad64930cbc
- version: 1.0

## Description

added percentage & dollar values, different colors for gap up and gap down

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © LuxAlgo

//@version=6
indicator('Session Gap Fill [LuxAlgo]','LuxAlgo - Session Gap Fill', overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

//---------------------------------------------------------------------------------------------------------------------
// CONSTANTS & INPUTS
//---------------------------------------------------------------------------------------------------------------------
GREEN = #089981
RED   = #F23645

GREEN_80  = color.new(GREEN,80)
RED_80    = color.new(RED,80)
RED_50    = color.new(RED,50)
SILVER_50 = color.new(color.silver,50)
SILVER_80 = color.new(color.silver,80)

ALL = 'All'
OVERLAPPING = 'Overlapping'
NOOVERLAPPING = 'No Overlapping Wicks'

gapTypeInput = input.string(ALL, 'Gap Type', options = [ALL,OVERLAPPING,NOOVERLAPPING])

filledBullishGapInput = input.bool(true, 'Filled Bullish Gap')
filledBullishGapColorInput = input.color(GREEN_80, '')
filledBearishGapInput = input.bool(true, 'Filled Bearish Gap')
filledBearishGapColorInput = input.color(RED_80, '')
unfilledGapInput = input.bool(true, 'Unfilled Gap')
unfilledGapColorInput = input.color(SILVER_80, '')

//---------------------------------------------------------------------------------------------------------------------
// DATA STRUCTURE
//---------------------------------------------------------------------------------------------------------------------
type gap
    int startBar
    int fillBar
    int startTime
    int endTime    
    string gapType
    float openPrice
    float top
    float bottom
    float lastClose    
    box gapArea    
    line extremePrice
    label tag    
    bool filled = false
    bool valid  = false

var array<gap> gaps = array.new<gap>()

gapStart = session.isfirstbar_regular

//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------
gapType() =>    
    bullishGap = open > close[1]
    bearishGap = open < close[1]
    bullishOverlapping = low < high[1]
    bullishNonOverlapping = low > high[1]
    bearishOverlapping = high > low[1]
    bearishNonOverlapping = high < low[1]

    overlappingGap = (bullishGap and bullishOverlapping) or (bearishGap and bearishOverlapping)
    noOverlappingGap = (bullishGap and bullishNonOverlapping) or (bearishGap and bearishNonOverlapping)
    
    switch
        overlappingGap => OVERLAPPING
        noOverlappingGap => NOOVERLAPPING        
        => ''

gatherData() =>
    if gapStart        
        gaps.push(gap.new(bar_index,bar_index,time,time,gapType(),open,high,low,close[1],na,na,na))
                    
    if gaps.size() > 0
        gap currentGap = gaps.last()
        currentGap.endTime := time        
        currentGap.top := math.max(currentGap.top,high)
        currentGap.bottom := math.min(currentGap.bottom,low)

        if not currentGap.filled
            bool filledGap = (currentGap.openPrice > currentGap.lastClose and currentGap.bottom <= currentGap.lastClose) or (currentGap.openPrice < currentGap.lastClose and currentGap.top >= currentGap.lastClose)
            currentGap.filled := filledGap
            currentGap.fillBar := bar_index            

drawGap(gap currentGap) =>        
    bool isGapDisplayable = currentGap.filled ? (currentGap.openPrice > currentGap.lastClose ? filledBullishGapInput : filledBearishGapInput) : unfilledGapInput

    if isGapDisplayable
        // GAP SIZE CALCULATION
        float gapSize = math.abs(currentGap.openPrice - currentGap.lastClose)
        float gapPercent = (gapSize / currentGap.lastClose) * 100

        string gapText = (currentGap.filled ? 'Filled' : 'Gap') + '\n' + 
                         str.tostring(gapSize, "#.##") + " / " + str.tostring(gapPercent, "#.##") + "%"

        float tagPrice  = currentGap.openPrice > currentGap.lastClose ? currentGap.top : currentGap.bottom        
        int tagTime     = currentGap.startTime + math.round(0.5*(currentGap.endTime - currentGap.startTime))
        string tagStyle = currentGap.openPrice > currentGap.lastClose ? label.style_label_down : label.style_label_up        

        currentGap.tag.delete()
        currentGap.tag := label.new(
            chart.point.new(tagTime,na,tagPrice),
            gapText,
            xloc.bar_time,
            yloc.price,
            color(na),
            tagStyle,
            currentGap.openPrice > currentGap.lastClose ? color.new(filledBullishGapColorInput,0) : color.new(filledBearishGapColorInput,0),
            10
        )

        currentGap.gapArea.delete()    
        currentGap.gapArea := box.new(
            chart.point.new(currentGap.startTime,na,math.max(currentGap.openPrice,currentGap.lastClose)),
            chart.point.new(currentGap.endTime,na,math.min(currentGap.openPrice,currentGap.lastClose)),
            border_color = color(na),
            bgcolor = currentGap.filled ? (currentGap.openPrice > currentGap.lastClose ? filledBullishGapColorInput : filledBearishGapColorInput) : unfilledGapColorInput,
            xloc = xloc.bar_time
        )

//---------------------------------------------------------------------------------------------------------------------
// EXECUTION
//---------------------------------------------------------------------------------------------------------------------
gatherData()

if barstate.islastconfirmedhistory        
    for i = 0 to gaps.size() - 2
        drawGap(gaps.get(i))

if barstate.islast
    if gaps.size() > 0
        drawGap(gaps.last())
````
