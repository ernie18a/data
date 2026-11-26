# COT Net Positioning [ConfluenceEdge]

- url: https://www.tradingview.com/script/mEF30fH1-COT-Net-Positioning-ConfluenceEdge/
- type: indicator
- pine_id: PUB;7db83a576149436f97d639313e767686
- version: 1.0

## Description

[b]COT Net Positioning [ConfluenceEdge][/b]

Net positioning from the weekly CFTC Commitments of Traders report — one line per group, plotted as net contracts (long minus short).

[b]The three groups[/b]

[list]
[*]Commercials (blue): hedgers — producers and consumers of the physical commodity. Their net position is the "smart money" side of the report.
[*]Non-Commercials (red): large speculators — funds and trend followers. Usually the opposite side of the commercials.
[*]Retail (green): small, non-reportable traders. Often treated as the contrarian side — but sometimes just small commercials that did not cross the reporting threshold.
[/list]

[b]How to use it[/b]

[list]
[*]The three lines are net (long minus short), so rising = adding longs or covering shorts
[*]Toggle each group on/off — the default shows Commercials + Non-Commercials for a clean read
[*]Works on any symbol with a COT code (futures, FX, indices, metals, energies, crypto via root auto-detection)
[*]Weekly data — use daily+ timeframes
[/list]

The report is released weekly. This indicator shows raw data only — no signals, no interpretation.

Educational content only. Not investment advice.

## Source Code

````pine
//@version=6
indicator("COT Net Positioning [ConfluenceEdge]", shorttitle="COT Net [ConfluenceEdge]", precision=0)

import TradingView/LibraryCOT/2 as cot

showComm    = input.bool(true,  "Commercials net")
showNonComm = input.bool(true,  "Non-Commercials net")
showRetail  = input.bool(false, "Retail (small speculators) net")

// Commercials
cot_comm_long  = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Long", metricType = "All")
cot_comm_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Commercial Positions", metricDirection = "Short", metricType = "All")
comm_long  = request.security(cot_comm_long,  "1D", close, ignore_invalid_symbol = true)
comm_short = request.security(cot_comm_short, "1D", close, ignore_invalid_symbol = true)

// Non-Commercials
cot_lspecs_long  = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Long", metricType = "All")
cot_lspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Noncommercial Positions", metricDirection = "Short", metricType = "All")
lspecs_long  = request.security(cot_lspecs_long,  "1D", close, ignore_invalid_symbol = true)
lspecs_short = request.security(cot_lspecs_short, "1D", close, ignore_invalid_symbol = true)

// Retail (Nonreportable)
cot_sspecs_long  = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Long", metricType = "All")
cot_sspecs_short = cot.COTTickerid(COTType = "Legacy", CFTCCode = cot.convertRootToCOTCode("Auto"), includeOptions = false, metricName = "Nonreportable Positions", metricDirection = "Short", metricType = "All")
sspecs_long  = request.security(cot_sspecs_long,  "1D", close, ignore_invalid_symbol = true)
sspecs_short = request.security(cot_sspecs_short, "1D", close, ignore_invalid_symbol = true)

plot(showComm    ? comm_long  - comm_short   : na, color = color.blue,  title = "Commercials net",     linewidth = 3)
plot(showNonComm ? lspecs_long - lspecs_short : na, color = color.red,   title = "Non-Commercials net", linewidth = 3)
plot(showRetail  ? sspecs_long - sspecs_short : na, color = color.green, title = "Retail net",           linewidth = 2)
hline(0, color = color.black, title = "Zero", linestyle = hline.style_dotted, linewidth = 1)
````
