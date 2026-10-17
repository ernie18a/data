# Ross Trade Checklist

- url: https://www.tradingview.com/script/h6JSnNT0-Ross-Trade-Checklist/
- type: indicator
- pine_id: PUB;c7bb55ea07ea483cb8c7aa005404d772
- version: 1.0

## Description

A simple discretionary trade checklist built to help traders stay disciplined and avoid taking low-quality setups.

This indicator displays a checklist directly on the chart, allowing you to confirm each condition before entering a trade. A score is calculated in real time, and the indicator will display TRADE READY once your minimum number of required confirmations has been met.

Features
✅ On-chart checklist panel
✅ Live confirmation score
✅ Customizable minimum confirmation requirement
✅ "TRADE READY" / "WAIT" status
✅ Optional trade status banner
✅ Lightweight and works on any market or timeframe
Default Checklist
HTF Bias Confirmed
Liquidity Sweep
9:30 Judas
PO3 Confirmation
IFVG Present
Displacement
Market Structure Shift (MSS)
Good Entry Location
Minimum Risk-to-Reward
Risk Management Check

The checklist is fully customizable through the indicator settings and can be adapted to any trading strategy.

This tool is designed to improve execution consistency by encouraging traders to verify every rule before entering a position.

## Source Code

````pine
//@version=6
indicator("Ross Trade Checklist", overlay = true)

//─────────────────────────────────────
// CHECKLIST INPUTS
// Toggle these inside the indicator settings
//─────────────────────────────────────
htfBias       = input.bool(false, "HTF Bias Confirmed", group = "Trade Checklist")
liquidity     = input.bool(false, "Liquidity Swept", group = "Trade Checklist")
judas         = input.bool(false, "9:30 Judas Complete", group = "Trade Checklist")
po3           = input.bool(false, "PO3 Confirmed", group = "Trade Checklist")
ifvg          = input.bool(false, "IFVG Present", group = "Trade Checklist")
displacement  = input.bool(false, "Displacement Confirmed", group = "Trade Checklist")
mss           = input.bool(false, "Market Structure Shift", group = "Trade Checklist")
entryLocation = input.bool(false, "Good Entry Location", group = "Trade Checklist")
rrAvailable   = input.bool(false, "Minimum RR Available", group = "Trade Checklist")
riskManaged   = input.bool(false, "Risk Within Limit", group = "Trade Checklist")

//─────────────────────────────────────
// DISPLAY SETTINGS
//─────────────────────────────────────
minimumChecks = input.int(
     8,
     "Minimum Checks Required",
     minval = 1,
     maxval = 10,
     group = "Display Settings"
)

showBanner = input.bool(true, "Show Trade Status Banner", group = "Display Settings")

//─────────────────────────────────────
// SCORE
//─────────────────────────────────────
int checks =
     (htfBias       ? 1 : 0) +
     (liquidity     ? 1 : 0) +
     (judas         ? 1 : 0) +
     (po3           ? 1 : 0) +
     (ifvg          ? 1 : 0) +
     (displacement  ? 1 : 0) +
     (mss           ? 1 : 0) +
     (entryLocation ? 1 : 0) +
     (rrAvailable   ? 1 : 0) +
     (riskManaged   ? 1 : 0)

bool tradeReady = checks >= minimumChecks

color readyColor = color.rgb(20, 120, 70)
color waitColor  = color.rgb(180, 45, 45)
color panelColor = color.rgb(25, 25, 30)
color rowColor   = color.rgb(40, 40, 46)
color textColor  = color.white

//─────────────────────────────────────
// HELPER FUNCTION
//─────────────────────────────────────
statusText(bool condition) =>
    condition ? "✓" : "□"

statusColor(bool condition) =>
    condition ? color.lime : color.silver

//─────────────────────────────────────
// CHECKLIST TABLE
//─────────────────────────────────────
var table checklist = table.new(
     position.top_right,
     2,
     13,
     frame_color = color.gray,
     frame_width = 1,
     border_color = color.rgb(70, 70, 75),
     border_width = 1
)

if barstate.islast
    table.cell(
         checklist,
         0,
         0,
         "ROSS TRADE CHECKLIST",
         bgcolor = panelColor,
         text_color = textColor,
         text_size = size.normal
    )

    table.cell(
         checklist,
         1,
         0,
         tradeReady ? "TRADE READY" : "WAIT",
         bgcolor = tradeReady ? readyColor : waitColor,
         text_color = color.white,
         text_size = size.normal
    )

    table.cell(checklist, 0, 1, "HTF Bias", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 1, statusText(htfBias), bgcolor = rowColor, text_color = statusColor(htfBias))

    table.cell(checklist, 0, 2, "Liquidity Sweep", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 2, statusText(liquidity), bgcolor = rowColor, text_color = statusColor(liquidity))

    table.cell(checklist, 0, 3, "9:30 Judas", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 3, statusText(judas), bgcolor = rowColor, text_color = statusColor(judas))

    table.cell(checklist, 0, 4, "PO3", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 4, statusText(po3), bgcolor = rowColor, text_color = statusColor(po3))

    table.cell(checklist, 0, 5, "IFVG", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 5, statusText(ifvg), bgcolor = rowColor, text_color = statusColor(ifvg))

    table.cell(checklist, 0, 6, "Displacement", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 6, statusText(displacement), bgcolor = rowColor, text_color = statusColor(displacement))

    table.cell(checklist, 0, 7, "MSS", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 7, statusText(mss), bgcolor = rowColor, text_color = statusColor(mss))

    table.cell(checklist, 0, 8, "Entry Location", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 8, statusText(entryLocation), bgcolor = rowColor, text_color = statusColor(entryLocation))

    table.cell(checklist, 0, 9, "Minimum RR", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 9, statusText(rrAvailable), bgcolor = rowColor, text_color = statusColor(rrAvailable))

    table.cell(checklist, 0, 10, "Risk Managed", bgcolor = rowColor, text_color = textColor)
    table.cell(checklist, 1, 10, statusText(riskManaged), bgcolor = rowColor, text_color = statusColor(riskManaged))

    table.cell(
         checklist,
         0,
         11,
         "Score",
         bgcolor = panelColor,
         text_color = textColor
    )

    table.cell(
         checklist,
         1,
         11,
         str.tostring(checks) + "/10",
         bgcolor = tradeReady ? readyColor : waitColor,
         text_color = color.white
    )

    table.cell(
         checklist,
         0,
         12,
         "Required",
         bgcolor = panelColor,
         text_color = textColor
    )

    table.cell(
         checklist,
         1,
         12,
         str.tostring(minimumChecks) + "/10",
         bgcolor = panelColor,
         text_color = textColor
    )

//─────────────────────────────────────
// OPTIONAL CHART BANNER
//─────────────────────────────────────
var table banner = table.new(position.bottom_center, 1, 1)

if barstate.islast
    table.cell(
         banner,
         0,
         0,
         showBanner ? (tradeReady ? "✓ TRADE ALLOWED" : "✕ NO TRADE") : "",
         bgcolor = showBanner ? (tradeReady ? readyColor : waitColor) : color.new(color.black, 100),
         text_color = showBanner ? color.white : color.new(color.white, 100),
         text_size = size.large
    )
````
