# FX Position Size Calculator: Risk-Based Lot Sizing

- url: https://www.tradingview.com/script/jxAhRoGM-FX-Position-Size-Calculator-Risk-Based-Lot-Sizing/
- type: indicator
- pine_id: PUB;e9ca155c6f11406bb3627534c601bb77
- version: 2.0

## Description

Every blown forex account has the same root cause: position size was too big for the stop loss. This indicator fixes that in one drag.

HOW IT WORKS
1. Set your account balance, account currency, and risk % (default 1%)
2. Click on the chart to drop the Entry line, then drag it to your planned entry
3. Click again to drop the Stop Loss line, drag it to your planned stop
4. (Optional) Add a Take Profit line for instant Reward:Risk

The info table updates live with:
• Lot Size (the headline number)
• Units and Micro Lots
• Stop distance in pips
• Risk in your account currency
• Reward:Risk ratio and potential reward

ACCOUNT CURRENCY CONVERSION
Supports USD, EUR, GBP, AUD, CAD, JPY, and CHF accounts. The indicator pulls the live cross rate from your broker so pip value is always converted correctly, no manual maths, no spreadsheet, no copy-paste between tabs.

COVERAGE
Forex majors and minors (any pair where the quote currency is one of the seven majors above). Indices, metals, and crypto are not supported, a warning shows if you load it on a non FX symbol.

WHY THIS EXISTS
Most "position size calculators" on TradingView require you to type the stop in pips. That's the slow part, you have to switch to a measuring tool, count, switch back, type. This one reads the stop straight off the chart, so a full risk, managed setup takes about three seconds.

The web version at fxsizecalc.com adds prop firm presets (FTMO, MyForexFunds, FundedNext, etc.) that respect each firm's daily and overall drawdown rules, handy if you're trading a funded account and one bad sizing decision ends the challenge.

OPEN SOURCE & FREE
The source is fully open, fork it, modify it, build on it. If you want a feature added, drop a comment.

Trade safe.

## Source Code

````pine
//@version=5
// ─────────────────────────────────────────────────────────────────────────────
//  FX Position Size Calculator  —  by fxsizecalc.com
//  v2 (2026-05-27): added smart auto-hide when Entry/Stop prices don't match
//                    the current symbol (prevents Y-axis distortion when you
//                    switch pairs without resetting the price inputs).
//
//  Drag the Entry and Stop Loss lines on the chart. The indicator computes
//  the exact lot size that risks the specified % of your account, with full
//  account-currency conversion for the major retail currencies.
//
//  Free full calculator + prop firm presets: https://fxsizecalc.com
// ─────────────────────────────────────────────────────────────────────────────
indicator("FX Position Size Calculator [fxsizecalc.com]", overlay=true, max_lines_count=10, max_boxes_count=10, max_labels_count=10)

// ═══════════════════════════════ INPUTS ═══════════════════════════════
gAcct = "Account"
acctBalance = input.float(10000.0, "Account Balance", minval=0.0, group=gAcct, tooltip="Your total account equity")
acctCcy     = input.string("USD", "Account Currency", options=["USD","EUR","GBP","AUD","CAD","JPY","CHF"], group=gAcct)
riskPct     = input.float(1.0, "Risk % per Trade", minval=0.01, maxval=100.0, step=0.1, group=gAcct, tooltip="Most professionals risk 0.5% – 2% per trade")

gTrade = "Trade Setup"
entryPrice = input.price(0.0, "Entry Price", group=gTrade, confirm=true, tooltip="Click on the chart to place, then drag the line")
stopPrice  = input.price(0.0, "Stop Loss",   group=gTrade, confirm=true, tooltip="Click on the chart to place, then drag the line")
useTP      = input.bool(true, "Show Take Profit", group=gTrade)
tpPrice    = input.price(0.0, "Take Profit",  group=gTrade, confirm=true)

gDisplay = "Display"
showLines = input.bool(true, "Show Entry / SL / TP lines", group=gDisplay)
showZones = input.bool(true, "Shade risk / reward zones", group=gDisplay)
tablePos  = input.string("Top Right", "Info Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gDisplay)
textSize  = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large"], group=gDisplay)
smartHide = input.bool(true, "Auto-hide if prices don't match symbol", group=gDisplay, tooltip="Recommended ON. Hides lines and shows a warning when Entry/Stop prices appear to be from a different symbol (e.g. you switched the chart). Prevents the Y-axis from being skewed.")

// ═══════════════════════════ CURRENCY DETECTION ═══════════════════════════
baseCcy  = syminfo.basecurrency
quoteCcy = syminfo.currency
isForex  = syminfo.type == "forex"

// Pip size: 0.01 for JPY-quoted pairs, 0.0001 for everything else
pipSize = quoteCcy == "JPY" ? 0.01 : 0.0001

// ════════════════════════ WRONG-SYMBOL DETECTION (v2) ════════════════════════
// Pine input.price() values persist across symbols. If a trader sets prices on
// one pair then switches symbols, the stored prices may be at a wildly different
// price level — distorting the Y-axis and producing nonsense lot-size numbers.
// Heuristic: if any of entry/stop/tp is more than 5× (or less than 0.2×) the
// current close, treat the prices as belonging to a different symbol.
priceLooksOff(p) =>
    p > 0 and close > 0 and (p / close > 5.0 or close / p > 5.0)

pricesFromOtherSymbol = priceLooksOff(entryPrice) or priceLooksOff(stopPrice) or priceLooksOff(tpPrice)
hideForWrongSymbol    = smartHide and pricesFromOtherSymbol

// ═══════════════════════ ACCOUNT-CURRENCY CONVERSION ═══════════════════════
// Pip value lands in the QUOTE currency; we need it in the ACCOUNT currency.
// Try both possible cross symbols and pick whichever the broker provides.
prefix = syminfo.prefix == "" ? "" : syminfo.prefix + ":"
convSymQA = prefix + quoteCcy + acctCcy   // e.g. USDEUR (usually does not exist)
convSymAQ = prefix + acctCcy + quoteCcy   // e.g. EURUSD (usually does exist)

convRateQA = request.security(convSymQA, "D", close, ignore_invalid_symbol=true)
convRateAQ = request.security(convSymAQ, "D", close, ignore_invalid_symbol=true)

// quoteToAcctRate = how many ACCT per 1 unit of QUOTE
quoteToAcctRate = quoteCcy == acctCcy ? 1.0 : not na(convRateQA) ? convRateQA : not na(convRateAQ) ? 1.0 / convRateAQ : na

// ═══════════════════════════ POSITION SIZE MATH ═══════════════════════════
stopDistance        = math.abs(entryPrice - stopPrice)
stopPips            = stopDistance / pipSize
riskAmount          = acctBalance * (riskPct / 100.0)
pipValuePerLotQuote = pipSize * 100000.0                       // 1 standard lot = 100,000 units
pipValuePerLotAcct  = pipValuePerLotQuote * quoteToAcctRate

mathOK    = stopPips > 0 and not na(pipValuePerLotAcct) and pipValuePerLotAcct > 0 and not hideForWrongSymbol
lotSize   = mathOK ? riskAmount / (stopPips * pipValuePerLotAcct) : na
units     = na(lotSize) ? na : lotSize * 100000.0
microLots = na(lotSize) ? na : lotSize * 100.0

rrRatio      = useTP and stopDistance > 0 and tpPrice > 0 ? math.abs(tpPrice - entryPrice) / stopDistance : na
rewardAmount = na(rrRatio) ? na : riskAmount * rrRatio

// ═══════════════════════════════ DRAWING ═══════════════════════════════
var line entryLine  = na
var line stopLine   = na
var line tpLine     = na
var box  riskBox    = na
var box  rewardBox  = na
var label warnLabel = na

if barstate.islast
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(tpLine)
    box.delete(riskBox)
    box.delete(rewardBox)
    label.delete(warnLabel)

    if hideForWrongSymbol
        // Don't draw lines/boxes — they'd skew the chart Y-axis. Show a warning instead.
        warnLabel := label.new(bar_index, close, "⚠  Entry / Stop prices don't match this symbol\n\nOpen Settings → reset Entry / Stop / TP to 0 →\nclick on the chart to place new lines for this pair.", style=label.style_label_left, color=color.new(#f59e0b, 0), textcolor=color.white, size=size.normal)
    else
        leftX  = bar_index - 50
        rightX = bar_index + 10

        if showLines and entryPrice > 0
            entryLine := line.new(leftX, entryPrice, rightX, entryPrice, color=color.new(#2962ff, 0), width=2, extend=extend.right)
        if showLines and stopPrice > 0
            stopLine  := line.new(leftX, stopPrice,  rightX, stopPrice,  color=color.new(#ef5350, 0), width=2, style=line.style_dashed, extend=extend.right)
        if showLines and useTP and tpPrice > 0
            tpLine    := line.new(leftX, tpPrice,    rightX, tpPrice,    color=color.new(#26a69a, 0), width=2, style=line.style_dashed, extend=extend.right)

        if showZones and entryPrice > 0 and stopPrice > 0
            riskBox := box.new(leftX, math.max(entryPrice, stopPrice), rightX, math.min(entryPrice, stopPrice), border_color=color.new(#ef5350, 70), bgcolor=color.new(#ef5350, 90), extend=extend.right)
        if showZones and useTP and entryPrice > 0 and tpPrice > 0
            rewardBox := box.new(leftX, math.max(entryPrice, tpPrice),  rightX, math.min(entryPrice, tpPrice),  border_color=color.new(#26a69a, 70), bgcolor=color.new(#26a69a, 92), extend=extend.right)

        if not isForex
            warnLabel := label.new(bar_index, high, "Not a forex pair — this indicator supports FX majors/minors only", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)

// ═══════════════════════════════ INFO TABLE ═══════════════════════════════
tablePosVar = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Bottom Left" ? position.bottom_left : position.middle_right
textSizeVar = textSize == "Tiny" ? size.tiny : textSize == "Small" ? size.small : textSize == "Large" ? size.large : size.normal

var table infoT = table.new(tablePosVar, 2, 11, bgcolor=color.new(#0a0e1a, 5), border_color=color.new(color.gray, 70), border_width=1, frame_color=color.new(#2962ff, 40), frame_width=1)

formatLots(x) =>
    na(x) ? "—" : str.tostring(x, "#.##") + " lots"

formatMoney(x, ccy) =>
    na(x) ? "—" : str.tostring(x, "#,###.##") + " " + ccy

if barstate.islast
    table.clear(infoT, 0, 0, 1, 10)

    table.cell(infoT, 0, 0, "FX Position Size",     text_color=color.white,             bgcolor=color.new(#1e40af, 0), text_size=textSizeVar)
    table.cell(infoT, 1, 0, "fxsizecalc.com",       text_color=color.new(color.white, 20), bgcolor=color.new(#1e40af, 0), text_size=size.small)

    table.cell(infoT, 0, 1, "Pair",                 text_color=color.gray,  text_size=textSizeVar)
    table.cell(infoT, 1, 1, baseCcy + "/" + quoteCcy, text_color=color.white, text_size=textSizeVar)

    table.cell(infoT, 0, 2, "Account",              text_color=color.gray,  text_size=textSizeVar)
    table.cell(infoT, 1, 2, formatMoney(acctBalance, acctCcy), text_color=color.white, text_size=textSizeVar)

    table.cell(infoT, 0, 3, "Risk",                 text_color=color.gray,  text_size=textSizeVar)
    table.cell(infoT, 1, 3, str.tostring(riskPct, "#.##") + "%  ·  " + formatMoney(riskAmount, acctCcy), text_color=color.new(#ef5350, 0), text_size=textSizeVar)

    table.cell(infoT, 0, 4, "Stop Distance",        text_color=color.gray, text_size=textSizeVar)
    table.cell(infoT, 1, 4, (na(stopPips) or stopPips == 0) ? "—" : str.tostring(stopPips, "#.#") + " pips", text_color=color.white, text_size=textSizeVar)

    table.cell(infoT, 0, 5, "LOT SIZE",             text_color=hideForWrongSymbol ? color.new(#f59e0b, 0) : color.yellow, bgcolor=color.new(color.black, 40), text_size=textSizeVar)
    table.cell(infoT, 1, 5, hideForWrongSymbol ? "RESET PRICES" : formatLots(lotSize), text_color=hideForWrongSymbol ? color.new(#f59e0b, 0) : color.yellow, bgcolor=color.new(color.black, 40), text_size=textSizeVar)

    table.cell(infoT, 0, 6, "Units",                text_color=color.gray, text_size=textSizeVar)
    table.cell(infoT, 1, 6, na(units) ? "—" : str.tostring(units, "#,###"), text_color=color.white, text_size=textSizeVar)

    table.cell(infoT, 0, 7, "Micro Lots",           text_color=color.gray, text_size=textSizeVar)
    table.cell(infoT, 1, 7, na(microLots) ? "—" : str.tostring(microLots, "#.#"), text_color=color.white, text_size=textSizeVar)

    table.cell(infoT, 0, 8, "Reward : Risk",        text_color=color.gray, text_size=textSizeVar)
    table.cell(infoT, 1, 8, na(rrRatio) ? "—" : "1 : " + str.tostring(rrRatio, "#.##"), text_color=color.new(#26a69a, 0), text_size=textSizeVar)

    table.cell(infoT, 0, 9, "Potential Reward",     text_color=color.gray, text_size=textSizeVar)
    table.cell(infoT, 1, 9, formatMoney(rewardAmount, acctCcy), text_color=color.new(#26a69a, 0), text_size=textSizeVar)

    table.cell(infoT, 0, 10, "Free · No signup",    text_color=color.new(color.white, 60), text_size=size.tiny)
    table.cell(infoT, 1, 10, "fxsizecalc.com",      text_color=color.new(color.white, 40), text_size=size.tiny)
````
