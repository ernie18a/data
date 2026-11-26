# ALREMI - COT Commercials

- url: https://www.tradingview.com/script/JrLebHMb-ALREMI-COT-Commercials/
- type: indicator
- pine_id: PUB;3b6d8283554f49ba8332c05ba85f2734
- version: 1.0

## Description

cot commericial very good to use wit supply and demand strategy

## Source Code

````pine
//@version=5
indicator("ALREMI - COT Commercials", shorttitle="COT Commercials", precision=0)

import TradingView/LibraryCOT/2 as cot

shortnegative = input(title="Show Shorts as negative numbers?", defval=true)
snn = shortnegative ? -1 : 1

cot_comm_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Long", metricType = "All")
cot_comm_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Short", metricType = "All")

comm_long = request.security(cot_comm_long, "1D", close, ignore_invalid_symbol = true)
comm_short = request.security(cot_comm_short, "1D", close, ignore_invalid_symbol = true)

plot (comm_long, color = color.rgb(0, 0, 0, 70), title = "Commercials long", style=plot.style_line,linewidth=2)
plot (comm_short*snn, color = color.rgb(0, 0, 0, 70), title = "Commercials short", style=plot.style_line,linewidth=2)
plot (comm_long - comm_short, color = color.rgb(0, 0, 0), title = "Commercials net", style=plot.style_line,linewidth=3)

hline(0, color=color.gray, title = "Zero", linestyle=hline.style_dotted,linewidth=1)
````
