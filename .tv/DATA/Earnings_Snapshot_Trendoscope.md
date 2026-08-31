<!-- tradingview-pine-id: PUB;049b342e307e4fb0b1ef8f9f2d48e219 -->
<!-- tradingviewscripts-format: 1 -->
# Earnings Snapshot [Trendoscope®]

Source: https://www.tradingview.com/script/lu0MTsuD-Earnings-Snapshot-Trendoscope/

## Description

🎲 Overview

The Earnings Snapshot [Trendoscope®] is a custom indicator designed to provide traders and investors with a quick, visual overview of a stock's earnings performance and its impact on price action. This tool automates the analysis of earnings reports by fetching historical and future earnings data, calculating growth metrics for both earnings and price changes, and presenting the information in an intuitive table format on the chart. It also adds interactive labels at key earnings dates for detailed breakdowns.

During the earning season, I was trying to understand the earnings and revenue growth of microsoft in comparison with thier price growth. This involved tidious process of taking scereenshot of multiple earning reports and then drawing correlations between them.

https://www.tradingview.com/x/25W6kUwX/

This script eliminates the tedium of manual data gathering and visualization. It focuses on key metrics like actual vs. estimated earnings, year-over-year (Y2Y) comparisons, and future estimates, while highlighting how these events correlate with price movements. Currently, the script handles earnings per share (EPS) data effectively, but revenue details are not included due to ongoing technical challenges with the available data interfaces in Pine Script. Future updates may incorporate revenue analysis once we find an effective way to present this data.

This indicator is ideal for fundamental analysis, earnings season preparation, or post-earnings reviews, helping users spot patterns such as earnings surprises, growth trends, or price reactions.

🎲 Key Features

[*]Earnings Data: Retrieves actual, estimated, and standardized EPS from TradingView's built-in request.earnings function.
[*]Growth Calculations: Computes percentage changes in earnings and price compared to the previous quarter (Last), year-over-year (Y2Y, based on 4 quarters back), and future estimates.
[*]Visual Table Display: A customizable table in the top-right corner showing dates, growth percentages, and color-coded indicators (lime for positive growth, orange for negative).
[*]On-Chart Infomration: Based on the settings, users can enable presentation of earnings, price and the growth data on chart. 
[*]Historical Depth: Configurable history lookback (up to 24 quarters) to analyze past earnings.
[*]Tooltip Mode: For a cleaner chart, labels show a score summary with full details available on hover.
[*]Future Earnings Integration: Includes upcoming EPS estimates and their projected growth from the last actual earnings.

🎲 Display Modes

🎯Tooltip Mode
If we select tooltip mode, it is better to chose the label size as either large or huge for better visibility. In tooltip mode, the data is not directly presented on the screen. Instead, we display the calculated score on the earnings release bar. The earnings and price growth info will show up upon hovering on the printed score value.

https://www.tradingview.com/x/xPfuGYAO/

🎯Text Mode
In case of text mode, all the calculated earnings and price growth data is printed directly on the chart. This will provide easier access to the data. However, it fills the chart. It is usefull for people who do not use additional indicators on the same chart or someone who trades mainly based on the earnings reports.

https://www.tradingview.com/x/kgtC0hVb/

🎯Tabular Data
Tabular data presents the growth of Earnings and Price based on last quarter as well as Y2Y along with growth of estimated earnings. The table can be hidden through input settings.

https://www.tradingview.com/x/VEere9sB/

🎲 Diving Deep

🎯Information Gathered and Presented
At present, we have tried collating and presenting following information for every earnings.

[*] Q2Q Earnings Growth
[*] Q2Q Price Growth
[*] Y2Y Earnings Growth
[*] Y2Y Price Growth
[*] Q2Q Future Estimated Earning Growth

🎯 Calculation of Score and Color coding
When in text mode, the information of earnings and price growth are printed on the chart completely. These displays are color coded based on a calculated score. You can also see the score directly on the chart when the display mode is tooltip mode. Let us try to understand how this score is calculated.

Score is nothing but combination of different factors of price and earnings growth. Following conditions are considered for the calculation.

[*] If Earnings growth is positive, add 1 else reduce the score by 1
[*] If price growth is positive, add 1 else reduce the score by 1
[*] If Earnings growth percent is higher than price growth percent, then add 1, else reduce the score by 1

Similar calculations are repeated for Y2Y earning and price growth. Finanlly the score also looks at if the future estimated earning is expected to increase from current actual earnings or is it expected to reduce.

Since there are 7 factors, the score can vary from -7 to +7. Higher the score, the greener the text background will be and lesser the score, the text background will turn more towards red.

🎯 Limitations

[*] Assumes quarterly earnings; irregular reporting schedules may affect Y2Y accuracy.
[*] Historical depth is limited to 24 quarters to avoid performance issues, but can be adjusted.
[*] Works best on daily/weekly timeframes where earnings bars are visible.
[*] No alerts or backtesting integration; this is purely a visualization tool.

🎯  Example of Interpretations 

[*]A green label with positive growth in both earnings and price suggests a strong beat with bullish reaction.
[*]Orange cells in Y2Y might indicate slowing growth despite a recent beat.
[*]Negative future estimates could signal caution for upcoming reports.

If you encounter issues or have suggestions, feel free to provide feedback. This script aims to streamline your manual analysis—happy trading!

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
indicator("Earnings Snapshot [Trendoscope®]", "ES[Trendoscope®]", overlay = true, max_labels_count = 500)

enum DisplayType
    TEXT = "Text"
    TOOLTIP = "Tooltip"

hma = ta.hma(close, 200)

history = input.int(5, 'History', minval=1, maxval=24, step=1, display = display.none)

displayType = input.enum(DisplayType.TEXT, 'On Chart', inline='d', display = display.none)
displaySize = input.string(size.normal, '', [size.huge, size.large, size.normal, size.small, size.tiny],
                     'Select display type and size', inline='d', display=display.none)

displayAsTable = input.bool(true, 'Show Table', inline='t', display = display.none)


displayAsTooltip = displayType == DisplayType.TOOLTIP

type Earnings
    float actual
    float estimated
    float standardized
    chart.point date
    Earnings lastEarnings
    Earnings y2yEarnings
    Earnings y1Earnings
    int dir
    float priceBefore
    float priceAfter
    float futureEstimated
    int futureDate

    

earningsActual = request.earnings(syminfo.tickerid, earnings.actual,barmerge.gaps_on)
earningsEstimated = request.earnings(syminfo.tickerid, earnings.estimate,barmerge.gaps_on)
earningsStandardised = request.earnings(syminfo.tickerid, earnings.standardized ,barmerge.gaps_on)
var array<Earnings> earningsArray = array.new<Earnings>()

if(not na(earningsActual))
    Earnings lastEarnings = na
    if(earningsArray.size()>0)
        lastEarnings := earningsArray.first()
        lastEarnings.futureEstimated := earningsEstimated
        lastEarnings.futureDate := time
    y2yEarings = (earningsArray.size()>=4)? earningsArray.get(3) : na
    y1Earnings = (earningsArray.size()>=3)? earningsArray.get(2) : na
    Earnings currentEarnings = Earnings.new(earningsActual, earningsEstimated, earningsStandardised,
                                             chart.point.now(high) , lastEarnings, y2yEarings, y1Earnings, close>hma?1:-1, close[1], close)
    earningsArray.unshift(currentEarnings)

method growth(Earnings current, Earnings last)=>
    earningsGrowth = 100*(current.actual - last.actual)/math.abs(last.actual)
    priceGrowth = 100*(current.priceAfter - last.priceAfter)/math.abs(last.priceAfter)
    [earningsGrowth, priceGrowth]

if(barstate.islast)
    lastEarnings = earningsArray.first()
    lastEarnings.futureEstimated := earnings.future_eps
    lastEarnings.futureDate := earnings.future_time

    var dataTable = table.new(position.top_right, 6, earningsArray.size()+2, na, chart.fg_color, 1, chart.fg_color, 1)

    dataTable.cell(0, 0, 'Date', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(1, 0, 'Last', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(3, 0, 'Y2Y', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(5, 0, 'Future', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)

    dataTable.cell(1, 1, 'Earning', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(2, 1, 'Price', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(3, 1, 'Earning', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(4, 1, 'Price', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
    dataTable.cell(5, 1, 'Earning', text_color=color.white, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)

    dataTable.merge_cells(0,0,0,1)
    dataTable.merge_cells(1,0,2,0)
    dataTable.merge_cells(3,0,4,0)
    for [index, earningData] in earningsArray
        if(index >= history)
            break
        data = ''
        score = 0
        dataTable.cell(0, index+2, str.format_time(earningData.date.time, "yyyy-MM-dd", syminfo.timezone), text_color=chart.fg_color, bgcolor=color.new(color.maroon, 50), text_formatting=text.format_bold)
        if(not na(earningData.lastEarnings))
            [earningsGrowth, priceGrowth] = earningData.growth(earningData.lastEarnings)
            earningsGrowthInfo = str.format('Earnings(Last) : {0} -> {1} ({2})',
                                                 earningData.lastEarnings.actual, earningData.actual,
                                                 str.tostring(earningsGrowth, format.percent))
            priceInfo = str.format('Price(Last) : {0} -> {1} ({2})',
                                                 str.tostring(earningData.lastEarnings.priceAfter, format.mintick), 
                                                 str.tostring(nz(earningData.priceAfter, earningData.priceBefore), format.mintick),
                                                 str.tostring(priceGrowth, format.percent))
            score += (earningsGrowth>0?1:earningsGrowth<0?-1:0)+
                         (priceGrowth>0?1:priceGrowth<0?-1:0)+
                         (earningsGrowth>priceGrowth?1:earningsGrowth<priceGrowth?-1:0)
            data+=earningsGrowthInfo+'\n'+
                     priceInfo+'\n'
            dataTable.cell(1, index+2, str.tostring(earningsGrowth, format.percent),
                         text_color=chart.fg_color, bgcolor = color.new(earningsGrowth>0?color.lime:color.orange, 80))
            dataTable.cell(2, index+2, str.tostring(priceGrowth, format.percent),
                         text_color=chart.fg_color, bgcolor = color.new(priceGrowth>0?color.lime:color.orange, 80))

            if(not na(earningData.y2yEarnings))
                [yEarningsGrowth, yPriceGrowth] = earningData.growth(earningData.y2yEarnings)
                yEarningsGrowthInfo = str.format('Earnings(Y2Y) : {0} -> {1} ({2})',
                                                 earningData.y2yEarnings.actual, earningData.actual,
                                                 str.tostring(yEarningsGrowth, format.percent))
                yPriceInfo = str.format('Price(Y2Y) : {0} -> {1} ({2})',
                                                 str.tostring(earningData.y2yEarnings.priceAfter, format.mintick), 
                                                 str.tostring(nz(earningData.priceAfter, earningData.priceBefore), format.mintick),
                                                 str.tostring(yPriceGrowth, format.percent))
                score += (yEarningsGrowth>0?1:yEarningsGrowth<0?-1:0)+
                         (yPriceGrowth>0?1:yPriceGrowth<0?-1:0)+
                         (yEarningsGrowth>yPriceGrowth?1:yEarningsGrowth<yPriceGrowth?-1:0)
                data+=yEarningsGrowthInfo+'\n'+
                         yPriceInfo+'\n'
                dataTable.cell(3, index+2, str.tostring(yEarningsGrowth, format.percent),
                             text_color=chart.fg_color, bgcolor = color.new(yEarningsGrowth>0?color.lime:color.orange, 80))
                dataTable.cell(4, index+2, str.tostring(yPriceGrowth, format.percent),
                             text_color=chart.fg_color, bgcolor = color.new(yPriceGrowth>0?color.lime:color.orange, 80))

            if(not na(earningData.futureEstimated))
                estimatedGrowth = 100*(earningData.futureEstimated - earningData.actual)/math.abs(earningData.actual)
                estimateInfo = str.format('Estimate : {0} -> {1} ({2})',
                                                 earningData.actual, earningData.futureEstimated,
                                                 str.tostring(estimatedGrowth, format.percent))
                score += (estimatedGrowth>0?1:estimatedGrowth<0?-1:0)
                data+=estimateInfo
                dataTable.cell(5, index+2, str.tostring(estimatedGrowth, format.percent),
                             text_color=chart.fg_color, bgcolor = color.new(estimatedGrowth>0?color.lime:color.orange, 80))

        lblColor = color.from_gradient(score, -7, 7, color.red, color.green)
        label.new(earningData.date, displayAsTooltip? str.tostring(score):data, xloc.bar_time, earningData.dir>0?yloc.belowbar:yloc.abovebar, color.new(lblColor, 70),
                     displayAsTooltip?label.style_text_outline:(earningData.dir>0?label.style_label_up:label.style_label_down), 
                     displayAsTooltip?lblColor: chart.fg_color, displaySize, text.align_left, displayAsTooltip? data: na, font.family_monospace)
````
