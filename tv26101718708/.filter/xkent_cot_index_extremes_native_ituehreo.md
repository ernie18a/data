# xKen-t COT Index & Extremes (Native)

- url: https://www.tradingview.com/script/iTUEHreo-xKen-t-COT-Index-Extremes-Native/
- type: indicator
- pine_id: PUB;5f4ca611025a47b09d30ee81356d1b02
- version: 1.0

## Description

[b]Overview
[/b]
COT Index & Extremes (Native) turns Commitments of Traders positioning into a single, decision-ready sentiment reading. It fetches CFTC COT data directly, converts a chosen trader group's net position into a 0–100 index that shows where current positioning sits within its own historical range, and flags when that positioning reaches a bullish or bearish extreme. The goal is to replace "eyeballing" raw COT lines with a defined, repeatable number.
The concept behind it
Raw COT net positions are hard to act on because "a lot" or "a little" only means something relative to an asset's own history. This script applies a position-in-range normalization (in the spirit of a Williams %R calculation, but applied to positioning rather than price): it takes the selected group's net position (long minus short) and measures where today's value falls between its lowest and highest readings over a lookback window, scaled 0–100. A reading near 100 means positioning is at the top of its historical range; near 0, the bottom. Two windows are used together — a short (26-week) read for the current swing in sentiment and a long (~3-year, 156-week) read for the structural picture.
Extremes are then defined mechanically: at or above 80 = an extreme in that group's positioning (bullish bias for commercials), at or below 20 = the opposite extreme (bearish bias). This makes "extreme" a number you can journal and alert on, not a subjective judgment.

[b]What it does
[/b]
- Fetches CFTC COT data natively and auto-resolves the correct futures contract from the chart's symbol — no need to wire in another indicator as a data source.

- Builds the net position for the selected trader group and normalizes it to the 0–100 index (short and long lookbacks).

- Marks the bullish/bearish extreme threshold zones and states a plain bias: BULLISH, BEARISH, or NO EDGE.

- Lets you switch between Commercial, Non-Commercial, and Retail (non-reportable) groups. Note these read differently — commercial hedgers are commonly used as a contrarian ("smart money") read at extremes, while non-commercials and retail are the crowd typically faded at extremes.

- Fires alerts when the index crosses into a bullish or bearish extreme.
When a symbol has no CFTC data (cash indices, most single stocks, crypto, exotic crosses), it clearly states "NO COT — use the futures symbol" and prompts you, instead of silently plotting a misleading line off price.

- Displays a panel confirming the resolved CFTC code, the active trader group, and whether the chart is on the correct (weekly) timeframe.

[b]What's original here
[/b]
Most COT tools plot raw net positions or require you to wire in another indicator's data. This one is self-contained and reframes the data for decision-making through three things: (1) it fetches CFTC Commitment of Traders data natively via TradingView's COT library and auto-resolves the correct contract from the chart's futures symbol, so no source-wiring is needed; (2) it converts a chosen trader group's net position (long − short) into a 0–100 "position-in-range" index — a Williams-style normalization showing where current positioning sits within its own historical range over a short (26w) and long (~3y) lookback — so an "extreme" becomes a defined number (≥80 / ≤20) instead of a visual guess; and (3) it switches cleanly between Commercial, Non-Commercial, and Retail groups and states a plain bullish/bearish/neutral bias from the index. When a symbol has no CFTC data (cash indices, most stocks, exotic crosses) it says so and prompts for the futures symbol, rather than silently plotting noise. A panel confirms the resolved CFTC code, the group, and whether you're on the correct weekly timeframe.

[b]How to use it
[/b]
1. Open a weekly chart of the futures symbol (e.g. 6E1!, GC1!, DX1!, ES1!, 6N1!) — not the cash index or spot pair. COT is weekly data, and the lookbacks are counted in weekly bars.
2. Read the index and bias. ≥80 = bullish extreme, ≤20 = bearish extreme, mid-range = no positioning edge.
3. Use it as directional context, confirmed by your own entry method, levels, and risk management.
4. If the panel shows no code, enter the 6-digit CFTC code manually in settings, or switch to the contract's futures symbol.

[b]Inputs[/b]
Trader group (Commercial / Non-Commercial / Retail) · optional CFTC code override · include-options toggle · short and long lookbacks · bullish/bearish thresholds · display and shading options.

[b]Attribution[/b]
COT data access uses TradingView's official LibraryCOT. This script's original contribution is the index construction, bias logic, no-data handling, and presentation built on top of that data.

[b]Limitations and disclaimer[/b]
COT is weekly, reported with a lag, and only exists for CFTC-reported futures — so this is context, not a timing signal, and it will not read non-CFTC instruments. Positioning extremes indicate potential, not certainty, and can persist for extended periods. This is an analysis tool, not financial advice. Always confirm with your own analysis and manage risk.

## Source Code

````pine
//@version=6
// COT INDEX & EXTREMES (NATIVE) - v2.0
// Fetches CFTC COT data directly via TradingView LibraryCOT - no wired source.
// USE ON A WEEKLY CHART, on the FUTURES symbol (CME:6E1!, COMEX:GC1!, ICEUS:DX1!, CME_MINI:ES1!).
// Lookbacks are counted in WEEKLY bars. No-COT symbols (cash indices, most stocks/crypto) say so.
// If the import errors, change "/4" to the current library version number.

import TradingView/LibraryCOT/4 as cot

indicator("xKen-t COT Index & Extremes (Native)", overlay = false, precision = 0)

// ---------------- Inputs ----------------
grp          = input.string("Commercial", "Trader group", options = ["Commercial", "Non-Commercial", "Retail (non-reportable)"], group = "COT data")
cftcOverride = input.string("", "CFTC code override (optional)", group = "COT data", tooltip = "6-digit code if auto fails. e.g. 099741 EUR, 096742 GBP, 097741 JPY, 088691 Gold, 084691 Silver, 098662 USD index, 067651 WTI, 020601 30Y bond. Blank = auto.")
inclOpt      = input.bool(false, "Include options data", group = "COT data")

lenS  = input.int(26,  "Short lookback (weeks)", minval = 4,  group = "Index")
lenL  = input.int(156, "Long lookback (weeks)",  minval = 26, group = "Index")
upT   = input.int(80,  "Bullish extreme >=", minval = 50, maxval = 100, group = "Index")
loT   = input.int(20,  "Bearish extreme <=", minval = 0,  maxval = 50,  group = "Index")
showL = input.bool(true, "Show long-lookback line", group = "Display")
tint  = input.bool(true, "Shade extreme zones", group = "Display")

// ---------------- Resolve CFTC code + fetch NET ----------------
metricName = grp == "Commercial" ? "Commercial Positions" : grp == "Non-Commercial" ? "Noncommercial Positions" : "Nonreportable Positions"
codeAuto = cot.convertRootToCOTCode("Auto")
cftc = str.length(cftcOverride) > 0 ? cftcOverride : codeAuto
hasCot = str.length(cftc) > 0

gLong  = hasCot ? cot.requestCommitmentOfTraders("Legacy", cftc, inclOpt, metricName, "Long",  "All") : na
gShort = hasCot ? cot.requestCommitmentOfTraders("Legacy", cftc, inclOpt, metricName, "Short", "All") : na
net = gLong - gShort

// ---------------- COT Index (Williams-style % of range) ----------------
cotIndex(s, len) =>
    ll  = ta.lowest(s, len)
    hh  = ta.highest(s, len)
    rng = hh - ll
    rng != 0 ? (s - ll) / rng * 100 : 50.0

idxS = cotIndex(net, lenS)
idxL = cotIndex(net, lenL)

// ---------------- Plots ----------------
cS = idxS >= upT ? #52C08A : idxS <= loT ? #E5564E : #9AA7A2
plot(idxS, "COT Index (short)", color = cS, linewidth = 2)
plot(showL ? idxL : na, "COT Index (long)", color = color.new(#E8B44F, 20), linewidth = 1)

hline(upT, "Bullish extreme", color = color.new(#52C08A, 40), linestyle = hline.style_dashed)
hline(50,  "Midline",         color = color.new(color.gray, 70))
hline(loT, "Bearish extreme", color = color.new(#E5564E, 40), linestyle = hline.style_dashed)

bgcolor(tint and idxS >= upT ? color.new(#52C08A, 88) : tint and idxS <= loT ? color.new(#E5564E, 88) : na)

// ---------------- Status / bias panel ----------------
biasTxt = not hasCot ? "NO COT - use the futures symbol" : idxS >= upT ? "BULLISH BIAS" : idxS <= loT ? "BEARISH BIAS" : "NO EDGE - STAND ASIDE"
biasCol = not hasCot ? #E8A24F : idxS >= upT ? #52C08A : idxS <= loT ? #E5564E : #9AA7A2
var label lb = na
label.delete(lb)
if barstate.islast
    txt = biasTxt + (hasCot ? "  -  idx " + str.tostring(idxS, "#") : "")
    lb := label.new(bar_index, na(idxS) ? 50 : idxS, txt, style = label.style_label_left, color = color.new(biasCol, 15), textcolor = color.white, size = size.normal)

var table t = table.new(position.top_left, 2, 3, frame_color = color.new(color.gray, 60), frame_width = 1)
if barstate.islast
    bgc = color.new(#0E1517, 10)
    table.cell(t, 0, 0, "CFTC code", text_color = color.gray, text_size = size.small, bgcolor = bgc)
    table.cell(t, 1, 0, hasCot ? cftc : "none", text_color = hasCot ? #E8B44F : #E5564E, text_size = size.small, bgcolor = bgc)
    table.cell(t, 0, 1, "Group", text_color = color.gray, text_size = size.small, bgcolor = bgc)
    table.cell(t, 1, 1, grp, text_color = color.white, text_size = size.small, bgcolor = bgc)
    table.cell(t, 0, 2, "Timeframe", text_color = color.gray, text_size = size.small, bgcolor = bgc)
    table.cell(t, 1, 2, timeframe.isweekly ? "weekly OK" : "use WEEKLY", text_color = timeframe.isweekly ? #52C08A : #E8A24F, text_size = size.small, bgcolor = bgc)

// ---------------- Alerts ----------------
alertcondition(ta.crossover(idxS, upT),  "COT bullish extreme", "COT INDEX bullish extreme on {{ticker}} - net extreme long")
alertcondition(ta.crossunder(idxS, loT), "COT bearish extreme", "COT INDEX bearish extreme on {{ticker}} - net extreme short")
````
