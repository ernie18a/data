# ALREMI - COT Non-Commercials

- url: https://www.tradingview.com/script/K3vLP3tj-ALREMI-COT-Non-Commercials/
- type: indicator
- pine_id: PUB;ae68abfed6204f3288070c6bda08c70d
- version: 1.0

## Description

cot non commericals very good to use with supply and demand strategy

## Source Code

````pine
//@version=5
indicator("ALREMI - COT Non-Commercials", shorttitle="COT Non-Commercials", precision=0)

import TradingView/LibraryCOT/2 as cot

shortnegative = input(title="Show Shorts as negative numbers?", defval=true)
snn = shortnegative ? -1 : 1

cot_lspecs_long = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Long", metricType = "All")
cot_lspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Short", metricType = "All")

lspecs_long = request.security(cot_lspecs_long, "1D", close, ignore_invalid_symbol = true)
lspecs_short = request.security(cot_lspecs_short, "1D", close, ignore_invalid_symbol = true)

plot (lspecs_long, color = color.rgb(226, 214, 46, 70), title = "Large Speculators long", style=plot.style_line,linewidth=1)
plot (lspecs_short*snn, color = color.rgb(216, 208, 59, 70), title = "Large Speculators short", style=plot.style_line,linewidth=1)
plot (lspecs_long - lspecs_short, color = color.rgb(248, 244, 11), title = "Large Speculators net", style=plot.style_line,linewidth=2)

hline(0, color=color.gray, title = "Zero", linestyle=hline.style_dotted,linewidth=1)
````
