# Power Order Blocks [ChartPrime]

- url: https://www.tradingview.com/script/qN6ElREt-Power-Order-Blocks-ChartPrime/
- type: indicator
- pine_id: PUB;651873263ea641c5a2f681bee48b7a2e
- version: 1.0

## Description

[b]🔶 OVERVIEW[/b]
[b]Power Order Blocks [ChartPrime][/b] is an advanced structural detection engine designed to identify high-probability supply and demand zones. Unlike standard order block indicators, this tool focuses on "Power" — the intensity of the displacement following the block's formation, combined with a live information panel, equilibrium mapping, and touch tracking built directly into each zone.

It identifies the specific candle where institutional participants likely placed large orders, marks the resulting price inefficiency, and tracks these zones in real time until they are either mitigated or invalidated.


[b]🔶 CORE CONCEPT — THE DISPLACEMENT VALIDATOR[/b]

The foundation of a "Power" Order Block is the displacement that follows it. For a zone to be considered valid, the market must move away from it with significant force.

The script uses a [b]Displacement Multiplier[/b] to ensure quality:
• It compares the size of the engulfing candle to the previous candle's range.
• If the breakout candle isn't large enough relative to the setup candle, the zone is ignored.
• This filters out low-conviction market noise and focuses on areas of true institutional sponsorship.


[b]🔶 THE POWER RATING SYSTEM[/b]

Every detected block is assigned a "Power" percentage. This rating provides immediate context regarding the strength of the move that created the zone.

• [b]Calculation:[/b] The indicator compares the current displacement candle against the largest candle observed over a [b]100-bar lookback[/b].
• [b]Meaning:[/b] A 100% Power rating indicates the strongest displacement seen in recent history, suggesting a massive imbalance between buyers and sellers.
• [b]Visual Intensity:[/b] When [b]Power Intensity[/b] is enabled, the fill color of each block becomes more vivid as its Power % increases. High-power zones are immediately visible at a glance — weaker zones fade into the background naturally.

This allows traders to prioritize "High Power" zones, which typically offer more significant structural support or resistance.


[b]🔶 DYNAMIC ZONE MANAGEMENT[/b]

The indicator manages zones dynamically to keep the chart clean and relevant:

[list]
[*] [b]Bullish Order Blocks (Demand):[/b] Formed when a bearish candle is followed by a high-displacement bullish candle. The zone is invalidated if price closes below the bottom of the block.
[*] [b]Bearish Order Blocks (Supply):[/b] Formed when a bullish candle is followed by a high-displacement bearish candle. The zone is invalidated if price closes above the top of the block.
[*] [b]Overlapping Cleanup:[/b] If a new order block forms that significantly overlaps an existing one, the script automatically removes the older, redundant zone to prevent clutter.
[*] [b]Block Limit:[/b] A maximum of 10 active blocks per side are tracked at any time, ensuring chart performance remains clean.
[/list]


[b]🔶 THE INFO PANEL[/b]

Each active Order Block renders a dedicated [b]Info Panel[/b] — a secondary box that floats at the right edge of the zone and updates in real time.

The panel displays:
• [b]Zone Direction:[/b] "Bullish OB" or "Bearish OB"
• [b]Power %:[/b] The relative displacement strength at the time of formation
• [b]Touch Counter:[/b] How many times price has tapped the zone boundary without breaking it

The touch counter is particularly valuable — a zone that has been tested multiple times without breaking demonstrates strong institutional defense and may represent a higher-conviction setup.


[b]🔶 EQUILIBRIUM LINE[/b]

When [b]Show Equilibrium Line[/b] is enabled, a line is drawn at the exact midpoint (50% level) of each Order Block.

• This level represents the theoretical "fair value" within the zone.
• Price often reacts precisely at the equilibrium before continuing in the original direction.
• It provides a refined entry reference within a wider zone, improving risk-to-reward on entries.


[b]🔶 RETEST SIGNALS (MITIGATION)[/b]

When [b]Show Retest Labels[/b] is enabled, the script monitors active zones for price interaction.

• If price returns to touch the boundary of a Bullish OB without breaking it, an upward arrow [b]⇡[/b] appears below the bar.
• If price returns to touch the boundary of a Bearish OB without breaking it, a downward arrow [b]⇣[/b] appears above the bar.
• A minimum [b]10-bar cooldown[/b] between signals prevents label spam on extended zone interactions.
• Each confirmed retest also increments the Touch Counter inside the Info Panel.


[b]🔶 VISUAL ELEMENTS[/b]

[list]
[*] [b]Main OB Body:[/b] A filled rectangle spanning the order block's price range, extending forward in time. Fill intensity reflects the Power % when Power Intensity is enabled.
[*] [b]Info Panel:[/b] A secondary box at the right edge of each zone displaying Power % and Touch Count, updated live.
[*] [b]Equilibrium Line:[/b] A midpoint line inside each block marking the 50% level of the zone.
[*] [b]Retest Arrows:[/b] Clean arrow labels (⇡ / ⇣) marking the first tap into an active zone.
[*] [b]Color Coding:[/b] Fully customizable colors for Bullish (Demand) and Bearish (Supply) zones.
[/list]


[b]🔶 HOW TO USE[/b]

[list]
[*] [b]Entry Zones:[/b] Wait for price to return to a high-power zone. The Retest Arrow confirms the touch. Consider entries near the equilibrium line for tighter stops.
[*] [b]Zone Prioritization:[/b] Use the Power % to filter setups. Zones rated 70%+ represent the strongest institutional imbalances and are generally more reliable.
[*] [b]Touch Count Context:[/b] A zone with 0 touches is fresh and untested — typically the highest probability. Zones with multiple touches may be weakening.
[*] [b]Trend Confirmation:[/b] In a healthy trend, the market should consistently create and respect Power Order Blocks in the direction of the trend.
[*] [b]Stop Loss Placement:[/b] Order blocks provide logical structural levels for stops — just below a Bullish OB bottom or above a Bearish OB top.
[*] [b]Confluence:[/b] Combine the Power Rating, Equilibrium Line, and Touch Count together for the highest-quality setups.
[/list]


[b]🔶 SETTINGS REFERENCE[/b]

[list]
[*] [b]Displacement Multiplier:[/b] Controls how aggressive the displacement filter is. Higher values require a stronger engulfing move to validate a zone.
[*] [b]Bullish / Bearish OB Color:[/b] Set the fill color for each zone type.
[*] [b]Text Color:[/b] Controls the color of text inside the Info Panel.
[*] [b]Show Equilibrium Line:[/b] Toggles the midpoint line inside each block.
[*] [b]Power Intensity:[/b] When enabled, fill transparency scales with Power % — stronger zones appear more vivid.
[*] [b]Show Retest Labels:[/b] Toggles the ⇡ / ⇣ arrow labels on zone interactions.
[/list]


[b]🔶 CONCLUSION[/b]

[b]Power Order Blocks [ChartPrime][/b] provides a systematic way to map institutional footprint on the chart. By combining strict displacement validation with a relative power rating, live info panels, equilibrium mapping, and touch tracking, it transforms raw price action into a clear and actionable map of supply and demand imbalances — allowing traders to trade alongside the strongest market moves with precision and confidence.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime
//@version=6

indicator("Power Order Blocks [ChartPrime]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{
grp1 = "Order Block Settings"
maxBlocks   = 10
dispThresh  = input.float(0.5, title="Displacement Multiplier", step=0.1, group=grp1, tooltip="How much larger the engulfing candle must be to validate an OB.")
strLookback = 100

grp2 = "Styling"
bullColor   = input.color(#1bd37a, title="Bullish OB Color",  group=grp2)
bearColor   = input.color(#bc14e6, title="Bearish OB Color",  group=grp2)
borderColor = color.new(#ffffff, 100)
textColor   = input.color(color.new(#ffffff, 0),  title="Text Color",   group=grp2)
showEqLine  = input.bool(true, title="Show Equilibrium Line", group=grp2, tooltip="Draws a dashed midpoint line inside each Order Block.")
powerFade   = input.bool(true, title="Power Intensity",       group=grp2, tooltip="Higher power OBs appear more vivid; weaker OBs are more transparent.")

grp3 = "Signals"
showRetests = input.bool(true, title="Show Retest Labels", group=grp3, tooltip="Plots an arrow label when price taps into an active Order Block.")

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙏𝙔𝙋𝙀𝙎
// --------------------------------------------------------------------------------------------------------------------{
type OBBlock
    box   bx
    box   infoBox
    line  eqLine
    int   touches
    int   birthBar
    float obTop
    float obBtm
    float powerPct

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{
var OBBlock[] bullBlocks = array.new<OBBlock>()
var OBBlock[] bearBlocks = array.new<OBBlock>()

var int lastBullRetestBar = na
var int lastBearRetestBar = na

bool isBearishCandle = close[1] < open[1]
bool isBullishDisp   = close > open and close > high[1] and (close - open) > (high[1] - low[1]) * dispThresh
bool bullOB          = isBearishCandle and isBullishDisp

bool isBullishCandle = close[1] > open[1]
bool isBearishDisp   = close < open and close < low[1] and (open - close) > (high[1] - low[1]) * dispThresh
bool bearOB          = isBullishCandle and isBearishDisp

float maxCandleSize = ta.highest(high - low, strLookback)
float atr           = ta.atr(14) * 0.2

// Power % drives transparency: high power = low transp (vivid), low power = high transp (faded)
// Power 100% -> transp 60, Power 0% -> transp 92
calcPowerTransp(float powerPct) =>
    int transp = math.round(92 - (powerPct / 100.0) * 32)
    transp

buildLabel(int touches, float pct) =>
    "Power: " + str.tostring(math.round(pct)) + "%  |  Touches: " + str.tostring(touches)

bool bullRetestRaw = false
bool bearRetestRaw = false

// --- Update bullish blocks ---
int bullSize = array.size(bullBlocks)
if bullSize > 0
    for i = bullSize - 1 to 0
        OBBlock ob  = array.get(bullBlocks, i)
        float   btm = ob.obBtm
        float   top = ob.obTop

        if close < btm
            box.delete(ob.bx)
            box.delete(ob.infoBox)
            if not na(ob.eqLine)
                line.delete(ob.eqLine)
            array.remove(bullBlocks, i)
        else
            int transp = powerFade ? calcPowerTransp(ob.powerPct) : 80
            box.set_bgcolor(ob.bx, color.new(bullColor, transp))
            box.set_right(ob.bx, bar_index + 25)

            box.set_left(ob.infoBox,   bar_index)
            box.set_right(ob.infoBox,  bar_index + 25)
            box.set_top(ob.infoBox,    top)
            box.set_bottom(ob.infoBox, btm)

            if showEqLine and not na(ob.eqLine)
                line.set_x2(ob.eqLine, bar_index)

            if low[1] <= top and low >= top and bar_index > box.get_left(ob.bx)
                bullRetestRaw := true
                ob.touches    += 1
                float pct      = maxCandleSize > 0 ? ((top - btm) / maxCandleSize) * 100 : 0
                box.set_text(ob.infoBox, "Bullish OB\n" + buildLabel(ob.touches, pct))

// --- Update bearish blocks ---
int bearSize = array.size(bearBlocks)
if bearSize > 0
    for i = bearSize - 1 to 0
        OBBlock ob  = array.get(bearBlocks, i)
        float   top = ob.obTop
        float   btm = ob.obBtm

        if close > top
            box.delete(ob.bx)
            box.delete(ob.infoBox)
            if not na(ob.eqLine)
                line.delete(ob.eqLine)
            array.remove(bearBlocks, i)
        else
            int transp = powerFade ? calcPowerTransp(ob.powerPct) : 80
            box.set_bgcolor(ob.bx, color.new(bearColor, transp))
            box.set_right(ob.bx, bar_index + 25)

            box.set_left(ob.infoBox,   bar_index)
            box.set_right(ob.infoBox,  bar_index + 25)
            box.set_top(ob.infoBox,    top)
            box.set_bottom(ob.infoBox, btm)

            if showEqLine and not na(ob.eqLine)
                line.set_x2(ob.eqLine, bar_index)

            if high[1] >= btm and high <= btm and bar_index > box.get_left(ob.bx)
                bearRetestRaw := true
                ob.touches    += 1
                float pct      = maxCandleSize > 0 ? ((top - btm) / maxCandleSize) * 100 : 0
                box.set_text(ob.infoBox, "Bearish OB\n" + buildLabel(ob.touches, pct))

// Apply 10-bar gap filter
bool bullRetest = bullRetestRaw and (na(lastBullRetestBar) or bar_index - lastBullRetestBar >= 10)
bool bearRetest = bearRetestRaw and (na(lastBearRetestBar) or bar_index - lastBearRetestBar >= 10)

if bullRetest
    lastBullRetestBar := bar_index
if bearRetest
    lastBearRetestBar := bar_index

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{
if bullOB
    float  obTop  = high[1]
    float  obBtm  = low[1]
    float  obMid  = math.avg(obTop, obBtm)
    int    obLeft = bar_index[1]
    float  pct    = maxCandleSize > 0 ? ((obTop - obBtm) / maxCandleSize) * 100 : 0
    string lbl    = "Bullish OB\n" + buildLabel(0, pct)
    int    transp = powerFade ? calcPowerTransp(pct) : 80

    if array.size(bullBlocks) > 0
        for i = array.size(bullBlocks) - 1 to 0
            OBBlock old = array.get(bullBlocks, i)
            if obTop >= old.obBtm and obBtm <= old.obTop
                box.delete(old.bx)
                box.delete(old.infoBox)
                if not na(old.eqLine)
                    line.delete(old.eqLine)
                array.remove(bullBlocks, i)

    box newBx = box.new(obLeft, obTop, bar_index, obBtm,
         border_color = borderColor,
         border_style = line.style_dashed,
         bgcolor      = color.new(bullColor, transp))

    box infoBx = box.new(bar_index, obTop, bar_index + 25, obBtm,
         border_color = color.new(bullColor, 40),
         border_style = line.style_solid,
         bgcolor      = color.new(bullColor, 92),
         text         = lbl,
         text_color   = textColor,
         text_size    = size.auto,
         text_halign  = text.align_center,
         text_valign  = text.align_center)

    line eqL = na
    if showEqLine
        eqL := line.new(obLeft, obMid, bar_index, obMid,
             color = color.new(bullColor, 40),
             style = line.style_solid,
             width = 1)

    array.push(bullBlocks, OBBlock.new(newBx, infoBx, eqL, 0, bar_index, obTop, obBtm, pct))

    int bullCount = array.size(bullBlocks)
    if bullCount > maxBlocks
        int trim = bullCount - maxBlocks
        for _i = 0 to trim - 1
            if array.size(bullBlocks) > 0
                OBBlock old = array.shift(bullBlocks)
                box.delete(old.bx)
                box.delete(old.infoBox)
                if not na(old.eqLine)
                    line.delete(old.eqLine)

if bearOB
    float  obTop  = high[1]
    float  obBtm  = low[1]
    float  obMid  = math.avg(obTop, obBtm)
    int    obLeft = bar_index[1]
    float  pct    = maxCandleSize > 0 ? ((obTop - obBtm) / maxCandleSize) * 100 : 0
    string lbl    = "Bearish OB\n" + buildLabel(0, pct)
    int    transp = powerFade ? calcPowerTransp(pct) : 80

    if array.size(bearBlocks) > 0
        for i = array.size(bearBlocks) - 1 to 0
            OBBlock old = array.get(bearBlocks, i)
            if obTop >= old.obBtm and obBtm <= old.obTop
                box.delete(old.bx)
                box.delete(old.infoBox)
                if not na(old.eqLine)
                    line.delete(old.eqLine)
                array.remove(bearBlocks, i)

    box newBx = box.new(obLeft, obTop, bar_index, obBtm,
         border_color = borderColor,
         border_style = line.style_dashed,
         bgcolor      = color.new(bearColor, transp))

    box infoBx = box.new(bar_index, obTop, bar_index + 25, obBtm,
         border_color = color.new(bearColor, 40),
         border_style = line.style_solid,
         bgcolor      = color.new(bearColor, 92),
         text         = lbl,
         text_color   = textColor,
         text_size    = size.auto,
         text_halign  = text.align_center,
         text_valign  = text.align_center)

    line eqL = na
    if showEqLine
        eqL := line.new(obLeft, obMid, bar_index, obMid,
             color = color.new(bearColor, 40),
             style = line.style_solid,
             width = 1)

    array.push(bearBlocks, OBBlock.new(newBx, infoBx, eqL, 0, bar_index, obTop, obBtm, pct))

    int bearCount = array.size(bearBlocks)
    if bearCount > maxBlocks
        int trim = bearCount - maxBlocks
        for _i = 0 to trim - 1
            if array.size(bearBlocks) > 0
                OBBlock old = array.shift(bearBlocks)
                box.delete(old.bx)
                box.delete(old.infoBox)
                if not na(old.eqLine)
                    line.delete(old.eqLine)

// --- Retest labels ---
if showRetests and bullRetest
    label.new(
         x         = bar_index,
         y         = low - atr,
         text      = "⇡",
         style     = label.style_label_up,
         color     = color.new(bullColor, 100),
         textcolor = bullColor,
         size      = size.large)

if showRetests and bearRetest
    label.new(
         x         = bar_index,
         y         = high + atr,
         text      = "⇣",
         style     = label.style_label_down,
         color     = color.new(bearColor, 100),
         textcolor = bearColor,
         size      = size.large)

// --- Alerts ---
alertcondition(bullRetest, title="Bullish OB Retest", message="Price retested a Bullish Order Block.")
alertcondition(bearRetest, title="Bearish OB Retest", message="Price retested a Bearish Order Block.")

// --------------------------------------------------------------------------------------------------------------------}
````
