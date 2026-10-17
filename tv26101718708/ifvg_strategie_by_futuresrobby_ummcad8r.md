# iFVG Strategie by Futures.Robby

- url: https://www.tradingview.com/script/UmmCad8R/
- type: indicator
- pine_id: PUB;cfb067ec5f53476bbcfdaf75227a025c
- version: 1.0

## Description

iFVG Strategy Checklist by Futures.Robby
Description
This script is a manual checklist designed to help traders evaluate their setups based on the iFVG (Inverse Fair Value Gap) strategy. It serves as a visual aid directly on the chart and does not perform automatic market analysis, signal generation, or independent trade execution.

How It Works
The script creates an interactive, compact table directly on the chart. Traders manually select which criteria are met in the indicator settings, and the script automatically calculates the percentage score, dynamically changing the background color of the result line:

Green (≥ 60%): Good fulfillment of the criteria.

Orange (40–59%): Partial fulfillment of the criteria.

Red (< 40%): Poor fulfillment of the criteria.

To optimize performance and save resources, the table is calculated and displayed exclusively on the historically last (most recent) bar.

Checklist Criteria
The checklist is divided into two logical main sections:

1. Trade Criteria (8 Points)
Eight manually selectable conditions to determine setup quality:

Trade in Bias: The trade follows the trend direction of the higher timeframes (H1/H4/Daily).

BE Level: A clear swing point exists between the entry and the planned target.

Sweep: Price has taken out a significant swing point (liquidity) before the inverse signal.

Displacement: The iFVG is pierced by one or more clearly recognizable, strong candles.

Leg FVG Closed: There are no open m1 to m5 FVGs remaining between the entry and the target.

FVG Reaction: Price reacted to an FVG (ideally from a higher timeframe) during the preceding sweep.

FVG Size: The size of the FVG is between an ideal 6 to 10 points.

Number of Candles: The setup developed within a maximum of 6 candles.

2. Targets (1 Point)
Six optional target conditions that can be flexibly selected. As long as at least one of these targets is active, it counts as 1 combined point toward the overall evaluation:

Equal H / L: Equal highs or equal lows are present.

Session H / L: A major session high or low is targeted.

News H / L: An extreme high or low from an economic news event serves as the target.

HTF Swing Point: A significant swing point from a higher timeframe.

HTF OB: An unmitigated order block from a higher timeframe.

HTF FVG: A fair value gap from a higher timeframe.

Settings and Customization (Inputs)
The user interface and the chart table of the indicator are completely in English. The tooltips provide bilingual guidance (German/English).

Group: Trade Criteria
Trade in Bias (Checkbox)

Tooltip: Trendrichtung folgt dem Trend der HTF (H1/H4/daily) / Trend direction follows the HTF trend (H1/H4/daily)

BE Level (Checkbox)

Tooltip: Es existiert ein deutlicher Swingpunkt zwischen Tradeeinstieg und Ziel / A clear swing point exists between trade entry and target

Sweep (Checkbox)

Tooltip: Kurs hat vor dem Inverse z.B. einen markanten Swing angelaufen / Price has reached a significant swing before the inverse

Displacement (Checkbox)

Tooltip: IFVG wird von einer / mehreren deutlich erkennbar starken Kerzen durchstoßen / IFVG is pierced by one or more clearly strong candles

Leg FVG closed (Checkbox)

Tooltip: Zwischen Tradeeinstieg und Ziel liegen keine offenen m1 bis m5 FVG's / No open m1 to m5 FVGs between trade entry and target

FVG Reaction (Checkbox)

Tooltip: Kurs hat beim Sweep an einer FVG reagiert – idealerweise aus HTF / Price reacted to an FVG during the sweep – ideally from HTF

FVG Size (Checkbox)

Tooltip: 6 bis 10 Punkte / 6 to 10 points

Number of Candles (Checkbox)

Tooltip: max. 6 Kerzen / max. 6 candles

Group: Targets
Equal H / L (Checkbox)

Tooltip: Hochs oder Tiefs sind gleich / Highs or lows are equal

Session H / L (Checkbox)

Tooltip: Session-Hoch oder -Tief wird erreicht / Session high or low is reached

News H / L (Checkbox)

Tooltip: News-Hoch oder -Tief wird erreicht / News high or low is reached

HTF Swing Point (Checkbox)

Tooltip: Swingpunkt aus höherer Zeitebene / Swing point from higher timeframe

HTF OB (Checkbox)

Tooltip: Orderblock aus höherer Zeitebene / Order block from higher timeframe

HTF FVG (Checkbox)

Tooltip: Fair Value Gap aus höherer Zeitebene / Fair Value Gap from higher timeframe

Targets count as 1 point (Info text field)

Tooltip: Alle Zielbedingungen zählen zusammen als ein Punkt / All target conditions count together as one point

Table Position & Size
Window Position: Determines the placement on the chart.

Options: Top Right, Top Left, Bottom Right, Bottom Left

Table Size: Adjusts the scaling of the table.

Options: normal, small, tiny

Group: Appearance
Header Background Color: The background color for the section headers (Default: Gray).

Header Text Color: The text color for the table headers (Default: White).

Row Background Color: The background color for the individual criteria rows (Default: Black).

General Text Color: The default text color for all criteria labels (Default: White).

Highlight Ticked Text: Enables a visual highlight for fulfilled criteria. When turned on, the text color of the criterion changes as soon as its checkbox is activated.

Ticked Text Color: The color the text changes to when checked (Default: Green).

Chart Table Elements
Table Headers:
Trade Checklist (Main header)

Targets (Subheader for the target block)

Status Symbols:
✅ = Condition fulfilled (Cell has a green background).

❌ = Condition not fulfilled (Cell has a red background).

Important Note
This tool is not an automated indicator, but a visual decision aid for traders who want to apply their strategy rules in a structured and disciplined way.

## Source Code

````pine
//@version=5
// © 2025 kp_eu_de
// Released under the MIT License
indicator("iFVG Strategie by Futures.Robby", overlay=true)

// Inputs for the checklist
group_check = "Trade Criteria"
bias = input.bool(false, "Trade in Bias", tooltip="Trendrichtung folgt dem Trend der HTF (H1/H4/daily) / Trend direction follows the HTF trend (H1/H4/daily)", group=group_check)
beLevel = input.bool(false, "BE Level", tooltip="Es existiert ein deutlicher Swingpunkt zwischen Tradeeinstieg und Ziel / A clear swing point exists between trade entry and target", group=group_check)
sweep = input.bool(false, "Sweep", tooltip="Kurs hat vor dem Inverse z.B. einen markanten Swing angelaufen / Price has reached a significant swing before the inverse", group=group_check)
displacement = input.bool(false, "Displacement", tooltip="IFVG wird von einer / mehreren deutlich erkennbar starken Kerzen durchstoßen / IFVG is pierced by one or more clearly strong candles", group=group_check)
legFVG = input.bool(false, "Leg FVG closed", tooltip="Zwischen Tradeeinstieg und Ziel liegen keine offenen m1 bis m5 FVG's / No open m1 to m5 FVGs between trade entry and target", group=group_check)
fvgReaktion = input.bool(false, "FVG Reaction", tooltip="Kurs hat beim Sweep an einer FVG reagiert – idealerweise aus HTF / Price reacted to an FVG during the sweep – ideally from HTF", group=group_check)
fvgGroesse = input.bool(false, "FVG Size", tooltip="6 bis 10 Punkte / 6 to 10 points", group=group_check)
anzahlKerzen = input.bool(false, "Number of Candles", tooltip="max. 6 Kerzen / max. 6 candles", group=group_check)

// Inputs for targets
group_ziele = "Targets"
equalHL = input.bool(false, "Equal H / L", tooltip="Hochs oder Tiefs sind gleich / Highs or lows are equal", group=group_ziele)
sessionHL = input.bool(false, "Session H / L", tooltip="Session-Hoch oder -Tief wird erreicht / Session high or low is reached", group=group_ziele)
newsHL = input.bool(false, "News H / L", tooltip="News-Hoch oder -Tief wird erreicht / News high or low is reached", group=group_ziele)
htfSwing = input.bool(false, "HTF Swing Point", tooltip="Swingpunkt aus höherer Zeitebene / Swing point from higher timeframe", group=group_ziele)
htfOB = input.bool(false, "HTF OB", tooltip="Orderblock aus höherer Zeitebene / Order block from higher timeframe", group=group_ziele)
htfFVG = input.bool(false, "HTF FVG", tooltip="Fair Value Gap aus höherer Zeitebene / Fair Value Gap from higher timeframe", group=group_ziele)

zielHinweis = input.string("", title="Targets count as 1 point", tooltip="Alle Zielbedingungen zählen zusammen als ein Punkt / All target conditions count together as one point", group=group_ziele)

// Window position and size
pos = input.string("Top Right", title="Window Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
sizeInput = input.string("normal", title="Table Size", options=["normal", "small", "tiny"])

// Inputs for appearance
group_design = "Appearance"
bgHeaderColor = input.color(color.gray, "Header Background Color", group=group_design)
textHeaderColor = input.color(color.white, "Header Text Color", group=group_design)
bgRowColor = input.color(color.black, "Row Background Color", group=group_design)
textNormalColor = input.color(color.white, "General Text Color", group=group_design)
useTickedColor = input.bool(false, "Highlight Ticked Text", group=group_design)
textTickedColor = input.color(color.green, "Ticked Text Color", group=group_design)

textSize = sizeInput == "tiny" ? size.tiny :
     sizeInput == "small" ? size.small :
     size.normal

pos_map = pos == "Top Right" ? position.top_right :
     pos == "Top Left"  ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

// Calculate score
bools_check = array.from(bias, beLevel, sweep, displacement, legFVG, fvgReaktion, fvgGroesse, anzahlKerzen)
names_check = array.from("Trade in Bias", "BE Level", "Sweep", "Displacement", "Leg FVG closed", "FVG Reaction", "FVG Size", "Number of Candles")

bools_ziele = array.from(equalHL, sessionHL, newsHL, htfSwing, htfOB, htfFVG)
names_ziele = array.from("Equal H / L", "Session H / L", "News H / L", "HTF Swing Point", "HTF OB", "HTF FVG")

gesamt = 9  // 8 individual points + 1 target block
erfuellt = 0

for i = 0 to array.size(bools_check) - 1
    if array.get(bools_check, i)
        erfuellt := erfuellt + 1

zielErfuellt = false
for i = 0 to array.size(bools_ziele) - 1
    if array.get(bools_ziele, i)
        zielErfuellt := true

if zielErfuellt
    erfuellt := erfuellt + 1

prozent = math.round(erfuellt / gesamt * 100)
farbe = prozent >= 60 ? color.green : prozent >= 40 ? color.orange : color.red

// Create table
var table checklist = table.new(pos_map, 2, array.size(bools_check) + array.size(bools_ziele) + 5, border_width=1)

if barstate.islast
    table.cell(checklist, 0, 0, "Trade Checklist", text_color=textHeaderColor, bgcolor=bgHeaderColor, text_size=textSize)
    table.cell(checklist, 1, 0, "", bgcolor=bgHeaderColor, text_size=textSize)

    table.cell(checklist, 0, 1, str.tostring(erfuellt) + " of " + str.tostring(gesamt) + " = " + str.tostring(prozent) + "%", text_color=color.white, bgcolor=farbe, text_size=textSize)
    table.cell(checklist, 1, 1, "", bgcolor=farbe, text_size=textSize)

    for i = 0 to array.size(bools_check) - 1
        name = array.get(names_check, i)
        aktiv = array.get(bools_check, i)
        status = aktiv ? "✅" : "❌"
        farbeZelle = aktiv ? color.green : color.red
        curTextColor = aktiv and useTickedColor ? textTickedColor : textNormalColor
        
        table.cell(checklist, 0, i + 2, name, text_color=curTextColor, bgcolor=bgRowColor, text_size=textSize)
        table.cell(checklist, 1, i + 2, status, text_color=color.white, bgcolor=farbeZelle, text_size=textSize)

    zielStart = array.size(bools_check) + 2
    table.cell(checklist, 0, zielStart, "Targets", text_color=textHeaderColor, bgcolor=bgHeaderColor, text_size=textSize)
    table.cell(checklist, 1, zielStart, "", bgcolor=bgHeaderColor, text_size=textSize)

    for i = 0 to array.size(bools_ziele) - 1
        name = array.get(names_ziele, i)
        aktiv = array.get(bools_ziele, i)
        status = aktiv ? "✅" : "❌"
        farbeZelle = aktiv ? color.green : color.red
        curTextColor = aktiv and useTickedColor ? textTickedColor : textNormalColor
        
        table.cell(checklist, 0, zielStart + i + 1, name, text_color=curTextColor, bgcolor=bgRowColor, text_size=textSize)
        table.cell(checklist, 1, zielStart + i + 1, status, text_color=color.white, bgcolor=farbeZelle, text_size=textSize)
````
