# XA.3 - NQ Lead Tracker

- url: https://www.tradingview.com/script/uEjWPGiU-XA-3-NQ-Lead-Tracker/
- type: indicator
- pine_id: PUB;14c3f96d25984acea33f7736076cf8d2
- version: 1.0

## Description

══════════════════════════════════════════════
XA.3 – NQ LEAD TRACKER
══════════════════════════════════════════════

PURPOSE
Identify when correlated markets begin moving before NQ, providing an early indication that NQ may soon follow.

HOW IT WORKS
• Monitors up to 10 user-selectable lead symbols.
• Each lead is checked for a breakout above/below its own recent range.
• If enough enabled leads trigger before NQ, an Up Lead or Down Lead signal is plotted.
• Arrow count represents the number of active lead symbols contributing to the signal.

SETTINGS
• Lead Symbols – Select which markets to monitor.
• Use Lookback Filter – Require breakouts over a recent range (recommended ON).
• Lookback Period – Number of bars used for breakout detection (default: 8).
• Upside/Downside Leads Needed – Minimum number of lead symbols required to generate a signal.
• Comparison Timeframe – Timeframe used to evaluate the lead symbols.

INTENDED USE
Use as an early warning tool to gauge market participation and leadership before NQ confirms a move. It is designed to complement price action, not generate standalone trade entries.
══════════════════════════════════════════════

## Source Code

````pine
//@version=6
indicator("XA.3 - NQ Lead Tracker", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupMain = "Main"

nqSymbol = input.symbol("CME_MINI:NQ1!", "Traded Reference Symbol", group=groupMain, tooltip="Use NQ1! as the reference even if you trade MNQ.")
tf = input.timeframe("", "Comparison Timeframe", group=groupMain, tooltip="Blank = chart timeframe.")

useLookback = input.bool(true, "Use Lookback Filter", group=groupMain, tooltip="If ON, each lead must break the highest/lowest level of the lookback period. If OFF, it only compares against the previous bar.")
lookbackBars = input.int(8, "Lookback Period (Bars)", minval=2, group=groupMain, tooltip="Number of previous bars used to determine lead breakout levels.")

upNeeded = input.int(2, "Upside Leads Needed", minval=1, maxval=10, group=groupMain)
dnNeeded = input.int(2, "Downside Leads Needed", minval=1, maxval=10, group=groupMain)

groupLead = "Lead Symbols"

useLead1 = input.bool(true, "Use Lead 1", group=groupLead)
symLead1 = input.symbol("NASDAQ:NDX", "Lead 1", group=groupLead)

useLead2 = input.bool(true, "Use Lead 2", group=groupLead)
symLead2 = input.symbol("NASDAQ:QQQ", "Lead 2", group=groupLead)

useLead3 = input.bool(false, "Use Lead 3", group=groupLead)
symLead3 = input.symbol("CME_MINI:ES1!", "Lead 3", group=groupLead)

useLead4 = input.bool(true, "Use Lead 4", group=groupLead)
symLead4 = input.symbol("AMEX:XLK", "Lead 4", group=groupLead)

useLead5 = input.bool(false, "Use Lead 5", group=groupLead)
symLead5 = input.symbol("NASDAQ:SMH", "Lead 5", group=groupLead)

useLead6 = input.bool(false, "Use Lead 6", group=groupLead)
symLead6 = input.symbol("NASDAQ:SOXX", "Lead 6", group=groupLead)

useLead7 = input.bool(false, "Use Lead 7", group=groupLead)
symLead7 = input.symbol("NASDAQ:AAPL", "Lead 7", group=groupLead)

useLead8 = input.bool(false, "Use Lead 8", group=groupLead)
symLead8 = input.symbol("NASDAQ:MSFT", "Lead 8", group=groupLead)

useLead9 = input.bool(false, "Use Lead 9", group=groupLead)
symLead9 = input.symbol("NASDAQ:NVDA", "Lead 9", group=groupLead)

useLead10 = input.bool(false, "Use Lead 10 Inverse", group=groupLead, tooltip="For inverse symbols like VXN.")
symLead10 = input.symbol("CBOE:VXN", "Lead 10", group=groupLead)

groupVisual = "Visuals"

showConsensusText = input.bool(true, "Show Consensus Text", group=groupVisual)
showLeadStack = input.bool(true, "Show Lead Arrow Stack", group=groupVisual)
showIndividualLeadNumbers = input.bool(false, "Show Individual Lead Numbers", group=groupVisual)

maxStackArrows = input.int(5, "Max Arrows Per Signal", minval=1, maxval=10, group=groupVisual)
arrowSpacingAtr = input.float(0.12, "Arrow Spacing ATR Multiplier", minval=0.01, step=0.01, group=groupVisual)

upColor = input.color(color.lime, "Upside Color", group=groupVisual)
dnColor = input.color(color.red, "Downside Color", group=groupVisual)

showBg = input.bool(false, "Show Background", group=groupVisual)
showTable = input.bool(true, "Show Dashboard", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

useTf = tf == "" ? timeframe.period : tf

fHigh(sym) =>
    request.security(sym, useTf, high, barmerge.gaps_off, barmerge.lookahead_off)

fLow(sym) =>
    request.security(sym, useTf, low, barmerge.gaps_off, barmerge.lookahead_off)

fUpBreak(src) =>
    useLookback ? not na(src) and src > ta.highest(src[1], lookbackBars) : not na(src) and src > src[1]

fDnBreak(src) =>
    useLookback ? not na(src) and src < ta.lowest(src[1], lookbackBars) : not na(src) and src < src[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYMBOL DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nqH = fHigh(nqSymbol)
nqL = fLow(nqSymbol)

h1 = fHigh(symLead1),   l1 = fLow(symLead1)
h2 = fHigh(symLead2),   l2 = fLow(symLead2)
h3 = fHigh(symLead3),   l3 = fLow(symLead3)
h4 = fHigh(symLead4),   l4 = fLow(symLead4)
h5 = fHigh(symLead5),   l5 = fLow(symLead5)
h6 = fHigh(symLead6),   l6 = fLow(symLead6)
h7 = fHigh(symLead7),   l7 = fLow(symLead7)
h8 = fHigh(symLead8),   l8 = fLow(symLead8)
h9 = fHigh(symLead9),   l9 = fLow(symLead9)
h10 = fHigh(symLead10), l10 = fLow(symLead10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEAD LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nqUp = fUpBreak(nqH)
nqDn = fDnBreak(nqL)

lead1Up = useLead1 and fUpBreak(h1)
lead2Up = useLead2 and fUpBreak(h2)
lead3Up = useLead3 and fUpBreak(h3)
lead4Up = useLead4 and fUpBreak(h4)
lead5Up = useLead5 and fUpBreak(h5)
lead6Up = useLead6 and fUpBreak(h6)
lead7Up = useLead7 and fUpBreak(h7)
lead8Up = useLead8 and fUpBreak(h8)
lead9Up = useLead9 and fUpBreak(h9)
lead10Up = useLead10 and fDnBreak(l10)

lead1Dn = useLead1 and fDnBreak(l1)
lead2Dn = useLead2 and fDnBreak(l2)
lead3Dn = useLead3 and fDnBreak(l3)
lead4Dn = useLead4 and fDnBreak(l4)
lead5Dn = useLead5 and fDnBreak(l5)
lead6Dn = useLead6 and fDnBreak(l6)
lead7Dn = useLead7 and fDnBreak(l7)
lead8Dn = useLead8 and fDnBreak(l8)
lead9Dn = useLead9 and fDnBreak(l9)
lead10Dn = useLead10 and fUpBreak(h10)

upScore = 0
upScore += lead1Up ? 1 : 0
upScore += lead2Up ? 1 : 0
upScore += lead3Up ? 1 : 0
upScore += lead4Up ? 1 : 0
upScore += lead5Up ? 1 : 0
upScore += lead6Up ? 1 : 0
upScore += lead7Up ? 1 : 0
upScore += lead8Up ? 1 : 0
upScore += lead9Up ? 1 : 0
upScore += lead10Up ? 1 : 0

dnScore = 0
dnScore += lead1Dn ? 1 : 0
dnScore += lead2Dn ? 1 : 0
dnScore += lead3Dn ? 1 : 0
dnScore += lead4Dn ? 1 : 0
dnScore += lead5Dn ? 1 : 0
dnScore += lead6Dn ? 1 : 0
dnScore += lead7Dn ? 1 : 0
dnScore += lead8Dn ? 1 : 0
dnScore += lead9Dn ? 1 : 0
dnScore += lead10Dn ? 1 : 0

upLead = upScore >= upNeeded and not nqUp
dnLead = dnScore >= dnNeeded and not nqDn

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(14)
spacing = atr * arrowSpacingAtr

upStackCount = math.min(upScore, maxStackArrows)
dnStackCount = math.min(dnScore, maxStackArrows)

bgcolor(showBg and upLead ? color.new(upColor, 88) : na)
bgcolor(showBg and dnLead ? color.new(dnColor, 88) : na)

if showConsensusText and upLead
    label.new(bar_index, low - spacing * 0.6, "UP LEAD " + str.tostring(upScore), style=label.style_none, textcolor=upColor, size=size.small)

if showConsensusText and dnLead
    label.new(bar_index, high + spacing * 0.6, "DOWN LEAD " + str.tostring(dnScore), style=label.style_none, textcolor=dnColor, size=size.small)

if showLeadStack and upLead
    for i = 0 to upStackCount - 1
        label.new(bar_index, low - spacing * (i + 1.6), "▲", style=label.style_none, textcolor=upColor, size=size.normal)

if showLeadStack and dnLead
    for i = 0 to dnStackCount - 1
        label.new(bar_index, high + spacing * (i + 1.6), "▼", style=label.style_none, textcolor=dnColor, size=size.normal)

if showIndividualLeadNumbers and upLead
    txt = ""
    txt += lead1Up ? "1 " : ""
    txt += lead2Up ? "2 " : ""
    txt += lead3Up ? "3 " : ""
    txt += lead4Up ? "4 " : ""
    txt += lead5Up ? "5 " : ""
    txt += lead6Up ? "6 " : ""
    txt += lead7Up ? "7 " : ""
    txt += lead8Up ? "8 " : ""
    txt += lead9Up ? "9 " : ""
    txt += lead10Up ? "10 " : ""
    label.new(bar_index, low - spacing * (upStackCount + 2.4), txt, style=label.style_none, textcolor=upColor, size=size.tiny)

if showIndividualLeadNumbers and dnLead
    txt = ""
    txt += lead1Dn ? "1 " : ""
    txt += lead2Dn ? "2 " : ""
    txt += lead3Dn ? "3 " : ""
    txt += lead4Dn ? "4 " : ""
    txt += lead5Dn ? "5 " : ""
    txt += lead6Dn ? "6 " : ""
    txt += lead7Dn ? "7 " : ""
    txt += lead8Dn ? "8 " : ""
    txt += lead9Dn ? "9 " : ""
    txt += lead10Dn ? "10 " : ""
    label.new(bar_index, high + spacing * (dnStackCount + 2.4), txt, style=label.style_none, textcolor=dnColor, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dash = table.new(position.top_right, 2, 7, border_width=1)

if showTable and barstate.islast
    table.cell(dash, 0, 0, "XA.3 NQ LEADS", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "VALUE", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "UP SCORE")
    table.cell(dash, 1, 1, str.tostring(upScore) + " / " + str.tostring(upNeeded))

    table.cell(dash, 0, 2, "DOWN SCORE")
    table.cell(dash, 1, 2, str.tostring(dnScore) + " / " + str.tostring(dnNeeded))

    table.cell(dash, 0, 3, "NQ UP")
    table.cell(dash, 1, 3, nqUp ? "YES" : "NO")

    table.cell(dash, 0, 4, "NQ DOWN")
    table.cell(dash, 1, 4, nqDn ? "YES" : "NO")

    table.cell(dash, 0, 5, "LOOKBACK")
    table.cell(dash, 1, 5, useLookback ? str.tostring(lookbackBars) + " BARS" : "OFF")

    table.cell(dash, 0, 6, "TIMEFRAME")
    table.cell(dash, 1, 6, useTf)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(upLead, "NQ Upside Lead", "Correlated lead symbols are breaking higher before NQ.")
alertcondition(dnLead, "NQ Downside Lead", "Correlated lead symbols are breaking lower before NQ.")
````
