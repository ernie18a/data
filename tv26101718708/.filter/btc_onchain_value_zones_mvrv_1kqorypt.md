# BTC On-Chain Value Zones [MVRV]

- url: https://www.tradingview.com/script/1KqOryPT-BTC-On-Chain-Value-Zones-MVRV/
- type: indicator
- pine_id: PUB;7c4bf66f807848b3b768de955b20cc0d
- version: 1.0

## Description

BTC Onchain Value Zones (MVRV)
Bitcoin has a cost basis. Realized Price is the average price at which every coin in circulation last moved onchain, which makes it a reasonable proxy for what the average holder actually paid. This script plots that level directly on your price chart and builds valuation zones around it.
MVRV is just price divided by Realized Price. When MVRV falls under 1, the average holder is sitting at a loss. Historically that condition has clustered around cycle lows and long accumulation ranges. When MVRV stretches well above 2.5, the market is carrying a large amount of unrealized profit, and historically that has clustered around distribution phases and cycle highs. It is a slow, structural read, not a trade trigger.

Why I rebuilt it
The common version of this idea relied on the IntoTheBlock MVRV feed. That feed stopped updating in August 2025 and TradingView flagged it as discontinued. Scripts using it did not throw an error. They quietly froze on a stale value and kept plotting a line that meant nothing, which is worse than breaking outright.
This version calculates MVRV itself from two live feeds:
Realized Price = Realized Cap / Circulating Supply
MVRV = Price / Realized Price
Realized Cap comes from CoinMetrics and Circulating Supply from Glassnode. If either symbol is unavailable on your plan, the script falls back to an alternate ticker automatically. If supply goes dark entirely, it derives supply from market cap divided by price so the realized line keeps working rather than vanishing.

The zones
Deep buy below 0.85, meaning capitulation territory where holders are heavily underwater.
Buy below 1.0, meaning price sits under the aggregate cost basis.
Fair value between 1.0 and 2.5.
Sell above 2.5.
Euphoria above 3.5.
Every threshold is adjustable in settings. The zones are drawn in price terms, not as an oscillator, so you can see exactly what dollar level each multiple sits at right now.

Signals
Markers fire when MVRV crosses a threshold on the daily close. Triangles mark entries into the buy and sell zones, labels mark deep value and euphoria, and a circle marks the moment price reclaims its cost basis, which has historically been a useful bottom confirmation. Alerts are available for each event individually, for any buy event, for any sell event, and for a stale data feed.

Diagnostics
Two tables. The top right shows current MVRV, realized price in dollars, the active zone, how many days old the onchain data is, and which feeds are supplying it. The bottom right lists all six candidate symbols with their current values, marked green if live and red if dead. If a data provider retires a ticker two years from now, you will see it immediately instead of trusting a frozen line.

How to use it
Onchain data updates once per day, so use this on a daily chart or higher. It is built for position sizing and accumulation decisions across weeks and months, not for entries. Treat the zones as context for whatever you are already doing.

One honest caveat. MVRV peaks have declined with every cycle as Bitcoin has matured and the holder base has grown. The 3.5 euphoria level was routine in 2013 and 2017 and has been harder to reach since. Adjust the upper thresholds to fit the market you are actually trading rather than assuming past extremes will repeat.

This is for informational purposes only and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
// BTC On-Chain Value Zones — MVRV / Realized Price
// Realized Price = Realized Cap / Supply.  MVRV synthesized (old ITB feed is dead).
// All symbol inputs are input.string (NOT input.symbol) so a dead feed can't hard-error the script.
indicator("BTC On-Chain Value Zones [MVRV]", "Value Zones", overlay = true)

// ===== Feeds =====
mode = input.string("Price / Realized", "MVRV mode", options = ["Price / Realized", "MktCap / RealCap"])
rcA  = input.string("COINMETRICS:BTC_MARKETCAPREAL", "Realized cap - primary")
rcB  = input.string("BTC_MARKETCAPREAL",             "Realized cap - fallback")
spA  = input.string("GLASSNODE:BTC_SUPPLY",          "Supply - primary")
spB  = input.string("BTC_SUPPLY",                    "Supply - fallback")
mcA  = input.string("GLASSNODE:BTC_MARKETCAP",       "Market cap - primary")
mcB  = input.string("CRYPTOCAP:BTC",                 "Market cap - fallback")

ff(s) => request.security(s, "1D", close, ignore_invalid_symbol = true)

rc1 = ff(rcA)
rc2 = ff(rcB)
sp1 = ff(spA)
sp2 = ff(spB)
mc1 = ff(mcA)
mc2 = ff(mcB)

rc = na(rc1) ? rc2 : rc1 <= 0 ? rc2 : rc1
mc = na(mc1) ? mc2 : mc1 <= 0 ? mc2 : mc1
spD = na(mc) ? na : close <= 0 ? na : mc / close
sp = na(sp1) ? (na(sp2) ? spD : sp2 <= 0 ? spD : sp2) : sp1 <= 0 ? (na(sp2) ? spD : sp2) : sp1

srcR = na(rc) ? "none" : na(rc1) ? "rc-alt" : rc1 <= 0 ? "rc-alt" : "rc-pri"
srcS = na(sp) ? "none" : na(sp1) ? (na(sp2) ? "sp-derived" : "sp-alt") : sp1 <= 0 ? "sp-alt" : "sp-pri"

realP = na(rc) ? na : na(sp) ? na : sp <= 0 ? na : rc / sp
mvrvP = na(realP) ? na : realP <= 0 ? na : close / realP
mvrvC = na(rc) ? na : na(mc) ? na : rc <= 0 ? na : mc / rc
mvrv  = mode == "MktCap / RealCap" ? mvrvC : mvrvP
ok    = na(mvrv) ? false : na(realP) ? false : mvrv > 0 and realP > 0

// ===== Feed freshness =====
var float pRc = na
var int   pT  = na
chg  = na(rc) ? false : na(pRc) ? true : rc != pRc
pT  := chg ? time : pT
pRc := na(rc) ? pRc : rc
ageD  = na(pT) ? na : math.floor((timenow - pT) / 86400000)
stale = na(ageD) ? true : ageD > 5

// ===== Zone thresholds =====
deepBuy = input.float(0.85, "Deep buy (capitulation) <", step = 0.05)
buyThr  = input.float(1.0,  "Buy zone (below cost basis) <", step = 0.05)
sellThr = input.float(2.5,  "Sell zone >", step = 0.05)
euphThr = input.float(3.5,  "Euphoria / top >", step = 0.05)

// ===== Visibility =====
showFill = input.bool(true,  "Fill zones on price")
showBg   = input.bool(true,  "Shade extremes")
showLine = input.bool(true,  "Threshold lines")
showMark = input.bool(true,  "Event markers")
showTbl  = input.bool(true,  "Data table")
showDiag = input.bool(true,  "Feed diagnostics table")

// ===== Zone state =====
inDeepBuy = ok ? mvrv < deepBuy : false
inBuy     = ok ? mvrv < buyThr  : false
inSell    = ok ? mvrv > sellThr : false
inEuph    = ok ? mvrv > euphThr : false

// ===== Price-level bands =====
pReal = plot(ok ? realP : na,           "Realized price (cost basis)", color.new(color.orange, showLine or showFill ? 0 : 100), 2)
pDeep = plot(ok ? realP * deepBuy : na, "Deep-buy level",              color.new(color.green,  showLine ? 40 : 100), 1)
pSell = plot(ok ? realP * sellThr : na, "Sell level",                  color.new(color.red,    showLine ? 40 : 100), 1)
pEuph = plot(ok ? realP * euphThr : na, "Euphoria level",              color.new(color.red,    showLine ? 25 : 100), 1)

fill(pReal, pDeep, showFill ? color.new(color.green, 88) : na)
fill(pSell, pEuph, showFill ? color.new(color.red, 88)   : na)

bgcolor(showBg and inDeepBuy ? color.new(color.green, 85) : na)
bgcolor(showBg and inEuph    ? color.new(color.red, 85)   : na)

// ===== Events =====
armed   = ok ? not na(mvrv[1]) : false
entBuy  = armed ? mvrv[1] >= buyThr  and mvrv < buyThr  : false
entDeep = armed ? mvrv[1] >= deepBuy and mvrv < deepBuy : false
reclaim = armed ? mvrv[1] <= buyThr  and mvrv > buyThr  : false
entSell = armed ? mvrv[1] <= sellThr and mvrv > sellThr : false
entEuph = armed ? mvrv[1] <= euphThr and mvrv > euphThr : false

plotshape(showMark and entBuy,  "Buy",      shape.triangleup,   location.belowbar, color.new(color.green, 0), size = size.tiny)
plotshape(showMark and entDeep, "DeepBuy",  shape.labelup,      location.belowbar, color.new(color.green, 0), text = "DEEP", textcolor = color.black, size = size.tiny)
plotshape(showMark and reclaim, "Reclaim",  shape.circle,       location.belowbar, color.new(color.aqua, 0),  size = size.tiny)
plotshape(showMark and entSell, "Sell",     shape.triangledown, location.abovebar, color.new(color.red, 0),   size = size.tiny)
plotshape(showMark and entEuph, "Euphoria", shape.labeldown,    location.abovebar, color.new(color.red, 0),   text = "TOP", textcolor = color.black, size = size.tiny)

// ===== Alerts =====
alertcondition(entBuy,             "Entered BUY zone",     "BTC MVRV dropped below cost basis - buy zone")
alertcondition(entDeep,            "DEEP value buy",       "BTC MVRV capitulation - deep buy")
alertcondition(reclaim,            "Cost basis reclaimed", "BTC reclaimed realized price - bottom confirm")
alertcondition(entSell,            "Entered SELL zone",    "BTC MVRV overvalued - sell zone")
alertcondition(entEuph,            "EUPHORIA top risk",    "BTC MVRV euphoria - top risk")
alertcondition(entBuy or entDeep,  "Any BUY event",        "BTC on-chain BUY event")
alertcondition(entSell or entEuph, "Any SELL event",       "BTC on-chain SELL event")
alertcondition(stale,              "Feed stale",           "BTC on-chain realized cap feed has stopped updating")

// ===== Data table =====
var table t = table.new(position.top_right, 2, 5, bgcolor = color.white, border_color = color.gray, border_width = 1)
if showTbl and barstate.islast
    reg  = not ok ? "no data" : inDeepBuy ? "DEEP BUY" : inBuy ? "BUY" : inEuph ? "EUPHORIA" : inSell ? "SELL" : "fair"
    creg = not ok ? color.new(color.gray, 80) : inBuy ? color.new(color.green, 75) : inSell ? color.new(color.red, 75) : color.new(color.gray, 85)
    fTxt = na(ageD) ? "no feed" : (stale ? "STALE " : "live ") + str.tostring(ageD, "#") + "d"
    fBg  = stale ? color.new(color.red, 75) : color.new(color.green, 80)
    table.cell(t, 0, 0, "MVRV",   text_color = color.black)
    table.cell(t, 1, 0, ok ? str.tostring(mvrv, "#.##") : "n/a", text_color = color.black)
    table.cell(t, 0, 1, "Real $", text_color = color.black)
    table.cell(t, 1, 1, na(realP) ? "n/a" : str.tostring(realP, format.mintick), text_color = color.black)
    table.cell(t, 0, 2, "Zone",   text_color = color.black)
    table.cell(t, 1, 2, reg,      text_color = color.black, bgcolor = creg)
    table.cell(t, 0, 3, "Feed",   text_color = color.black)
    table.cell(t, 1, 3, fTxt,     text_color = color.black, bgcolor = fBg)
    table.cell(t, 0, 4, "Src",    text_color = color.black)
    table.cell(t, 1, 4, srcR + " / " + srcS, text_color = color.black)

                                                        // ===== Feed diagnostics =====
var table dg = table.new(position.bottom_right, 2, 6, bgcolor = color.white, border_color = color.gray, border_width = 1)
if showDiag and barstate.islast
    v1 = na(rc1) ? "DEAD" : str.tostring(rc1, format.volume)
    v2 = na(rc2) ? "DEAD" : str.tostring(rc2, format.volume)
    v3 = na(sp1) ? "DEAD" : str.tostring(sp1, format.volume)
    v4 = na(sp2) ? "DEAD" : str.tostring(sp2, format.volume)
    v5 = na(mc1) ? "DEAD" : str.tostring(mc1, format.volume)
    v6 = na(mc2) ? "DEAD" : str.tostring(mc2, format.volume)
    table.cell(dg, 0, 0, "RC pri", text_color = color.black)
    table.cell(dg, 1, 0, v1, text_color = color.black, bgcolor = na(rc1) ? color.new(color.red, 75) : color.new(color.green, 80))
    table.cell(dg, 0, 1, "RC alt", text_color = color.black)
    table.cell(dg, 1, 1, v2, text_color = color.black, bgcolor = na(rc2) ? color.new(color.red, 75) : color.new(color.green, 80))
    table.cell(dg, 0, 2, "SP pri", text_color = color.black)
    table.cell(dg, 1, 2, v3, text_color = color.black, bgcolor = na(sp1) ? color.new(color.red, 75) : color.new(color.green, 80))
    table.cell(dg, 0, 3, "SP alt", text_color = color.black)
    table.cell(dg, 1, 3, v4, text_color = color.black, bgcolor = na(sp2) ? color.new(color.red, 75) : color.new(color.green, 80))
    table.cell(dg, 0, 4, "MC pri", text_color = color.black)
    table.cell(dg, 1, 4, v5, text_color = color.black, bgcolor = na(mc1) ? color.new(color.red, 75) : color.new(color.green, 80))
    table.cell(dg, 0, 5, "MC alt", text_color = color.black)
    table.cell(dg, 1, 5, v6, text_color = color.black, bgcolor = na(mc2) ? color.new(color.red, 75) : color.new(color.green, 80))
````
