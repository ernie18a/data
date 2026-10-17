# Standard Deviation Channel Updated 

- url: https://www.tradingview.com/script/AKX0Wr85-Standard-Deviation-Channel-Updated/
- type: indicator
- pine_id: PUB;73cf92f863ec43d189f255178c2dd4a4
- version: 1.0

## Description

This is a updated script . The code was open source - courtesy leojez 



---

**Title:** Standard Deviation Channel (with "Freeze" Toggle)

**Description:**

Linear Regression and Standard Deviation Channels are fantastic for identifying trends and mean-reversion levels, but they have one major flaw for day traders: **they constantly shift and repaint with every new price tick.**

This script solves that problem by introducing a custom **"Freeze Channel"** toggle.

Instead of chasing a moving target, you can now lock your channel in place and project static, reliable levels forward to trade against.

**Key Features:**

* **Freeze Toggle:** Stop the channel from shifting. You can choose to lock it to the last closed bar (ignoring live tick volatility) or lock it at a specific historical time (like the morning open) to establish fixed levels for the rest of the day.
* **Dual Deviations:** Independently toggle and customize multipliers for both inner (+/- 1) and outer (+/- 2) deviation bands.
* **Pearson's R:** Optional toggle to display the Pearson correlation coefficient to gauge the strength of the trend.
* **True-Level Alerts:** Custom alerts for upper and lower line breaks. The alerts use `line.get_price()`, meaning they trigger precisely based on where the lines are currently drawn on your screen—whether the channel is actively shifting or frozen in place.
* **Visual Customization:** Full control over line colors, fills, and left/right line extensions.

**How to Use the Freeze Feature:**
Go to the indicator settings and check "Freeze Channel".

1. Select **"Lock to Last Closed Bar"** to stop the live candle from wildly altering the channel slope.
2. Select **"Lock to Specific Time"** and enter a timestamp to anchor your channel permanently to a specific historical moment, extending those exact levels into the future.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Diganta

//@version=5
indicator("Standard Deviation Channel", shorttitle="Std Dev Chn", overlay=true)

// --- FREEZE SETTINGS ---
freeze_group = "🛑 Freeze Settings"
freeze_chn = input.bool(false, title="Freeze Channel (Stop Shifting)", group=freeze_group)
freeze_type = input.string("Lock to Last Closed Bar", title="Freeze Method", options=["Lock to Last Closed Bar", "Lock to Specific Time"], group=freeze_group)
freeze_time = input.time(timestamp("2026-05-20 09:15"), title="Specific Time to Lock", group=freeze_group)

// Determine if we should allow the lines to move
bool can_update = true
if freeze_chn
    if freeze_type == "Lock to Last Closed Bar"
        // Freezes the moment real-time live trading starts
        can_update := barstate.ishistory 
    else
        // Freezes exactly at the time selected in the inputs
        can_update := time <= freeze_time

length = input.int(128, title="Length", minval = 1, maxval = 5000)
src = input.source(close, title="Source")

std_dev_chn_group = "Std Dev Channel Settings"
upprinp = input.bool(true, title="Upper Deviation +1", inline = "Upper Deviation", group = std_dev_chn_group)
upprmltinp = input.float(1.0, title="", inline = "Upper Deviation", group = std_dev_chn_group)
lwrinp = input.bool(true, title="Lower Deviation -1", inline = "Lower Deviation", group = std_dev_chn_group)
lwrMultInput = input.float(1.0, title="", inline = "Lower Deviation", group = std_dev_chn_group)
upprinp2 = input.bool(true, title="Upper Deviation +2", inline = "Upper Deviation", group = std_dev_chn_group)
upprmltinp2 = input.float(2.0, title="", inline = "Upper Deviation", group = std_dev_chn_group)
lwrinp2 = input.bool(true, title="Lower Deviation 2-", inline = "Lower Deviation", group = std_dev_chn_group)
lwrmultinp = input.float(2.0, title="", inline = "Lower Deviation", group = std_dev_chn_group)

col_settings_group = "Color Settings"
coluppr = input.color(color.new(color.blue, 95), "", inline = col_settings_group, group = col_settings_group)
collwr = input.color(color.new(color.orange, 95), "", inline = col_settings_group, group = col_settings_group)
coluppr2 = input.color(color.new(color.green, 95), "", inline = col_settings_group, group = col_settings_group)
collwr2 = input.color(color.new(color.green, 95), "", inline = col_settings_group, group = col_settings_group)

visual_settings_group = "Visual Settings"
prinp = input.bool(false, "Show Pearson's R", group = visual_settings_group)
exl = input.bool(false, "Extend Lines Left", group = visual_settings_group)
exr = input.bool(true, "Extend Lines Right", group = visual_settings_group)

exs = switch
    exl and exr => extend.both
    exl => extend.left
    exr => extend.right
    => extend.none

slpclc(source, len) =>
    max_bars_back(source, 5000)
    if len <= 1
        [float(na), float(na), float(na)]
    else
        sumX = 0.0
        sumY = 0.0
        sumXSqr = 0.0
        sumXY = 0.0
        for i = 0 to len - 1 by 1
            val = source[i]
            per = i + 1.0
            sumX += per
            sumY += val
            sumXSqr += per * per
            sumXY += val * per
        slope = (len * sumXY - sumX * sumY) / (len * sumXSqr - sumX * sumX)
        average = sumY / len
        intercept = average - slope * sumX / len + slope
        [slope, average, intercept]
        
devcalc(source, len, slope, average, intercept) =>
    upDev = 0.0
    dnDev = 0.0
    stdDevAcc = 0.0
    dsxx = 0.0
    dsyy = 0.0
    dsxy = 0.0
    periods = len - 1
    daY = intercept + slope * periods / 2
    val = intercept
    for j = 0 to periods by 1
        price = high[j] - val
        if price > upDev
            upDev := price
        price := val - low[j]
        if price > dnDev
            dnDev := price
        price := source[j]
        dxt = price - average
        dyt = val - daY
        price -= val
        stdDevAcc += price * price
        dsxx += dxt * dxt
        dsyy += dyt * dyt
        dsxy += dxt * dyt
        val += slope
    stdDev = math.sqrt(stdDevAcc / (periods == 0 ? 1 : periods))
    pearsonR = dsxx == 0 or dsyy == 0 ? 0 : dsxy / math.sqrt(dsxx * dsyy)
    [stdDev, pearsonR, upDev, dnDev]
    
[s, a, i] = slpclc(src, length)
st_price = i + s * (length - 1)
end_price = i

// We only update the coordinates if 'can_update' is true. Otherwise they stay frozen.
var line base_line = line.new(na, na, na, na, width=1, extend=exs, style=line.style_dashed, color=color.new(collwr, 0))
if can_update
    line.set_xy1(base_line, bar_index - length + 1, st_price)
    line.set_xy2(base_line, bar_index, end_price)
    
[stdDev, pearsonR, upDev, dnDev] = devcalc(src, length, s, a, i)
upprst_price = st_price + (upprinp ? upprmltinp * stdDev : upDev)
upprend_price = end_price + (upprinp ? upprmltinp * stdDev : upDev)
var line uppr = line.new(na, na, na, na, width=1, style=line.style_dashed, extend=exs, color=color.new(coluppr, 0))

lwrst_price = st_price + (lwrinp ? -lwrMultInput * stdDev : -dnDev)
lwrend_price = end_price + (lwrinp ? -lwrMultInput * stdDev : -dnDev)
var line lwr = line.new(na, na, na, na, width=1, style=line.style_dashed, extend=exs, color=color.new(collwr, 0))

if can_update
    line.set_xy1(uppr, bar_index - length + 1, upprst_price)
    line.set_xy2(uppr, bar_index, upprend_price)
    line.set_xy1(lwr, bar_index - length + 1, lwrst_price)
    line.set_xy2(lwr, bar_index, lwrend_price)

// Linefills defined using var so they naturally freeze when the lines freeze
var linefill lf1 = linefill.new(uppr, base_line, color = coluppr)
var linefill lf2 = linefill.new(base_line, lwr, color = collwr)

// Uses the same math block for Dev 2 to keep code clean and fast
[stdDev2, pearsonR2, upDev2, dnDev2] = devcalc(src, length, s, a, i)
upprst_price2 = st_price + (upprinp2 ? upprmltinp2 * stdDev2 : upDev2)
upprend_price2 = end_price + (upprinp2 ? upprmltinp2 * stdDev2 : upDev2)
var line uppr2 = line.new(na, na, na, na, width=1, style=line.style_dashed, extend=exs, color=color.new(coluppr2, 0))

lwrst_price2 = st_price + (lwrinp2 ? -lwrmultinp * stdDev2 : -dnDev2)
lwrend_price2 = end_price + (lwrinp2 ? -lwrmultinp * stdDev2 : -dnDev2)
var line lwr2 = line.new(na, na, na, na, width=1, style=line.style_dashed, extend=exs, color=color.new(collwr2, 0))

if can_update
    line.set_xy1(uppr2, bar_index - length + 2, upprst_price2)
    line.set_xy2(uppr2, bar_index, upprend_price2)
    line.set_xy1(lwr2, bar_index - length + 2, lwrst_price2)
    line.set_xy2(lwr2, bar_index, lwrend_price2)

var label r = label.new(na, na, "", color = color.new(color.white, 100), textcolor=color.new(coluppr, 0), size=size.normal, style=label.style_label_up)
if can_update
    if prinp and not na(pearsonR)
        label.set_xy(r, bar_index - length + 1, lwrst_price)
        label.set_text(r, str.tostring(pearsonR, "#.################"))
    else
        label.set_xy(r, na, na) // Hides label if toggled off
    
// --- ALERTS ---
// By using line.get_price, the alerts will read exactly where the lines are drawn, whether shifting or frozen.
uppr_val = line.get_price(uppr, bar_index)
lwr_val = line.get_price(lwr, bar_index)
uppr2_val = line.get_price(uppr2, bar_index)
lwr2_val = line.get_price(lwr2, bar_index)

uppr_break = ta.crossover(close, uppr_val)
lwr_break = ta.crossunder(close, lwr_val)
uppr2_break = ta.crossover(close, uppr2_val)
lwr2_break = ta.crossunder(close, lwr2_val)

alertcondition(uppr_break, title = "Upper Line Break Alert", message = "Upper Line has been broken!")
alertcondition(lwr_break, title = "Lower Line Break Alert", message = "Lower Line has been broken!")
alertcondition(uppr2_break, title = "Upper 2 Line Break Alert", message = "Upper 2 Line has been broken!")
alertcondition(lwr2_break, title = "Lower 2 Line Break Alert", message = "Lower 2 Line has been broken!")
````
