# ALREMI - COT Retail

- url: https://www.tradingview.com/script/JypVkAbh-ALREMI-COT-Retail/
- type: indicator
- pine_id: PUB;134e5fcda5784821b01bee88f6a0b93c
- version: 1.0

## Description

retail cot data only, very good using with supply a nd demand

## Source Code

````pine
//@version=5
indicator("ALREMI - COT Retail", shorttitle="COT Retail", precision=0)

import TradingView/LibraryCOT/2 as cot

shortnegative = input(title="Show Shorts as negative numbers?", defval=true)
snn = shortnegative ? -1 : 1

cot_sspecs_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Long", metricType = "All")
cot_sspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Short", metricType = "All")

sspecs_long = request.security(cot_sspecs_long, "1D", close, ignore_invalid_symbol = true)
sspecs_short = request.security(cot_sspecs_short, "1D", close, ignore_invalid_symbol = true)

plot(sspecs_long, color = color.rgb(255, 255, 255, 70), title = "Retail long", style=plot.style_line,linewidth=1)
plot(sspecs_short*snn, color = color.rgb(235, 240, 235, 70), title = "Retail short", style=plot.style_line,linewidth=1)
plot(sspecs_long - sspecs_short, color = color.rgb(255, 255, 255), title = "Retail net", style=plot.style_line,linewidth=2)

hline(0, color=color.gray, title = "Zero", linestyle=hline.style_dotted,linewidth=1)
````
