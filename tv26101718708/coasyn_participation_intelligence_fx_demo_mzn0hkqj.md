# Coasyn Participation Intelligence FX DEMO

- url: https://www.tradingview.com/script/mZN0hkQJ-Coasyn-Participation-Intelligence-FX-DEMO/
- type: indicator
- pine_id: PUB;49841c91dbbf47a38f4811c9d607df05
- version: 1.0

## Description

Coasyn Participation Intelligence (Demo)

Coasyn Participation Intelligence is a TradingView indicator designed to provide a clear participation panel directly on your chart.

This demonstration version offers a preview of the indicator and its interface while introducing the Participation Intelligence concept.

Demo Features
Participation Intelligence panel
Clear visual dashboard
Lightweight chart display
Clean operator-focused interface
Pine Script® Version 6

The full version expands upon this foundation with additional functionality and a more complete operator experience.

Developed by Coasyn

We Build Behaviour.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coasyn

//@version=6
indicator("Coasyn Participation Intelligence — FX DEMO", overlay=true, max_labels_count=20, max_lines_count=20)

//────────────────────────────────────────────────────────
// COASYN • Participation Intelligence • DEMO
// Reduced feature surface for TradingView publication.
// Full version includes presets, volatility gate, compact/screenshot modes,
// expanded permission logic, and premium alert states.
//────────────────────────────────────────────────────────

showPanel = input.bool(true, "Show Demo Panel", group="Display")
panelPosition = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")
sessionInput = input.session("0700-1100", "Active Session", group="Demo Rules")
spreadPips = input.float(0.3, "Manual Spread / Cost Estimate (pips)", minval=0.0, step=0.1, group="Demo Rules")

inSession = not na(time(timeframe.period, sessionInput))
emaFast = ta.ema(close, 20)
emaSlow = ta.ema(close, 50)
trendGood = close > emaFast and emaFast > emaSlow

sessionScore = inSession ? 25 : 0
spreadScore = spreadPips <= 2.0 ? 25 : spreadPips <= 3.5 ? 10 : 0
trendScore = trendGood ? 25 : 10
readyScore = inSession and spreadScore >= 10 and trendGood ? 25 : 0
qualityScore = sessionScore + spreadScore + trendScore + readyScore

state = qualityScore >= 80 ? "FAVORABLE" : qualityScore >= 55 ? "CAUTION" : "RESTRICTED"
permission = state == "FAVORABLE" ? "PARTICIPATION ALLOWED" : state == "CAUTION" ? "VERIFY" : "WAIT"
primaryBlocker = not inSession ? "Outside active session" : spreadScore == 0 ? "Spread/cost elevated" : not trendGood ? "Trend not aligned" : "Clear"

stateColor = state == "FAVORABLE" ? color.lime : state == "CAUTION" ? color.orange : color.red

pos = switch panelPosition
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

var table panel = table.new(pos, 4, 10, border_width=1)

bg = color.rgb(8, 11, 14)
card = color.rgb(17, 22, 27)
header = color.rgb(20, 24, 30)
gold = color.rgb(255, 215, 0)
muted = color.rgb(145, 150, 156)

clearPanel() =>
    for r = 0 to 9
        for c = 0 to 3
            table.cell(panel, c, r, "", bgcolor=color.new(bg, 100), text_color=color.white, text_size=size.tiny)

barBlocks = math.round(math.max(0, math.min(10, qualityScore / 10)))
barText = str.repeat("█", barBlocks) + str.repeat("░", 10 - barBlocks)

if barstate.islast and showPanel
    clearPanel()

    table.cell(panel, 0, 0, "COASYN • PARTICIPATION INTELLIGENCE", bgcolor=header, text_color=gold, text_size=size.small)
    table.merge_cells(panel, 0, 0, 2, 0)
    table.cell(panel, 3, 0, state, bgcolor=header, text_color=stateColor, text_size=size.small)

    table.cell(panel, 0, 1, "FREE DEMO VERSION", bgcolor=header, text_color=muted, text_size=size.tiny)
    table.merge_cells(panel, 0, 1, 3, 1)

    table.cell(panel, 0, 2, "FIELD QUALITY", bgcolor=card, text_color=color.white, text_size=size.tiny)
    table.merge_cells(panel, 0, 2, 3, 2)

    table.cell(panel, 0, 3, str.tostring(qualityScore) + " / 100", bgcolor=card, text_color=stateColor, text_size=size.large)
    table.merge_cells(panel, 0, 3, 3, 3)

    table.cell(panel, 0, 4, barText, bgcolor=card, text_color=stateColor, text_size=size.small)
    table.merge_cells(panel, 0, 4, 3, 4)

    table.cell(panel, 0, 5, "PERMISSION", bgcolor=card, text_color=color.orange, text_size=size.tiny)
    table.cell(panel, 1, 5, permission, bgcolor=card, text_color=stateColor, text_size=size.tiny)
    table.merge_cells(panel, 1, 5, 3, 5)

    table.cell(panel, 0, 6, "PRIMARY BLOCKER", bgcolor=card, text_color=color.orange, text_size=size.tiny)
    table.cell(panel, 1, 6, primaryBlocker, bgcolor=card, text_color=stateColor, text_size=size.tiny)
    table.merge_cells(panel, 1, 6, 3, 6)

    table.cell(panel, 0, 7, "SESSION", bgcolor=bg, text_color=color.orange, text_size=size.tiny)
    table.cell(panel, 1, 7, inSession ? "ACTIVE" : "OUTSIDE", bgcolor=bg, text_color=color.orange, text_size=size.tiny)

    table.cell(panel, 0, 8, "SPREAD", bgcolor=bg, text_color=color.lime, text_size=size.tiny)
    table.cell(panel, 1, 8, str.tostring(spreadPips, "#.0") + " pips", bgcolor=bg, text_color=color.lime, text_size=size.tiny)

    table.cell(panel, 0, 9, "Full version: presets • volatility • premium alerts • expanded permission logic", bgcolor=header, text_color=muted, text_size=size.tiny)
    table.merge_cells(panel, 0, 9, 3, 9)

if barstate.islast and not showPanel
    clearPanel()
````
