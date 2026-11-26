# ALREMI - COT data

- url: https://www.tradingview.com/script/icvRWoh7-ALREMI-COT-data/
- type: indicator
- pine_id: PUB;21a1a3a53e3945a7b26c463b955d4e6e
- version: 1.0

## Description

go against retail and along commerical - cot. COT data gives you opportunity to be the best

## Source Code

````pine
//@version=5
indicator("CoT-Buschi", shorttitle="ALREMI - COT data", precision=0)

import TradingView/LibraryCOT/2 as cot

shortnegative = input(title="Show Shorts as negative numbers?", defval=true)
snn = shortnegative ? -1 : 1

cot_comm_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Long", metricType = "All")
cot_comm_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Short", metricType = "All")
cot_lspecs_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Long", metricType = "All")
cot_lspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Short", metricType = "All")
cot_sspecs_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Long", metricType = "All")
cot_sspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Short", metricType = "All")

comm_long = request.security(cot_comm_long, "1D", close, ignore_invalid_symbol = true)
comm_short = request.security(cot_comm_short, "1D", close, ignore_invalid_symbol = true)
lspecs_long = request.security(cot_lspecs_long, "1D", close, ignore_invalid_symbol = true)
lspecs_short = request.security(cot_lspecs_short, "1D", close, ignore_invalid_symbol = true)
sspecs_long = request.security(cot_sspecs_long, "1D", close, ignore_invalid_symbol = true)
sspecs_short = request.security(cot_sspecs_short, "1D", close, ignore_invalid_symbol = true)

plot (comm_long, color = color.rgb(0, 0, 0, 70), title = "Commercials long", style=plot.style_line,linewidth=2)
plot (comm_short*snn, color = color.rgb(0, 0, 0, 70), title = "Commercials short", style=plot.style_line,linewidth=2)
plot (comm_long - comm_short, color = color.rgb(0, 0, 0), title = "Commercials net", style=plot.style_line,linewidth=3)
plot (lspecs_long, color = color.rgb(226, 214, 46, 70), title = "Large Speculators long", style=plot.style_line,linewidth=1)
plot (lspecs_short*snn, color = color.rgb(216, 208, 59, 70), title = "Large Speculators short", style=plot.style_line,linewidth=1)
plot (lspecs_long - lspecs_short, color = color.rgb(248, 244, 11), title = "Large Speculators net", style=plot.style_line,linewidth=2)
plot(sspecs_long, color = color.rgb(255, 255, 255, 70), title = "Retail long", style=plot.style_line,linewidth=1)
plot(sspecs_short*snn, color = color.rgb(235, 240, 235, 70), title = "Retail short", style=plot.style_line,linewidth=1)
plot(sspecs_long - sspecs_short, color = color.rgb(255, 255, 255), title = "Retail net", style=plot.style_line,linewidth=2)
hline(0, color=color.black, title = "Zero", linestyle=hline.style_dotted,linewidth=1)
````
