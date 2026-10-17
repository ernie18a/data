# Position Size Calculator

- url: https://www.tradingview.com/script/wYmRMAvm/
- type: indicator
- pine_id: PUB;6a1032c4a07543bd808db4f9f9dd3a7c
- version: 1.0

## Description

Title for publish:
Position Size Calculator - Auto Drag & Drop Risk Manager

Short Description:
Auto position size calculator for Futures. Set your $ risk, drag Entry & SL lines, get exact contracts.

Full Description:

📊 Stop guessing your position size.

This tool does the math for you. You define how much you are willing to risk in dollars, drag two lines on the chart, and it tells you exactly how many contracts to trade. No more manual calculators, no more mistakes.

💰 Why Proper Risk Management Is Everything
Most traders don't fail because of a bad strategy, they fail because of bad risk management. If you risk 10% on one trade, you need 11% just to get back to breakeven.

Professional trading means fixed risk per trade. You decide upfront: "I will risk $300 on this trade" - and this indicator calculates the position size so you never risk more than that. This is how you protect your account long-term.

🎯 How It Works
The formula is simple: Contracts = Risk Amount ($) / (Distance between Entry and SL * Point Value)

You don't need to remember it. The indicator calculates it live for you.

Example: You risk $300. Distance is 10 points on MNQ which is $2 per point. Risk per contract is $20. The indicator will show you 15 contracts.

📌 How To Use It The First Time - Important!

Add the indicator to your chart.
Leave Entry Line and Stop Loss on 0 in the settings.
On the first load, it goes into AUTO mode: It takes the current Close price as Entry and places the SL 0.5% below it. You can change that % in settings.
Now just drag and drop the Blue solid line and the Red dashed line [SL] to your desired levels. The table updates instantly.[Entry]
Smart logic: The lines are drawn only to the right extend.right, so they never clutter your chart history. And the AUTO is stored only once, so it won't jump around.

⚙️ Settings Explained

Risk Settings:

Risk Amount ($): Your max loss if SL is hit. This is the core of the calculation.
Instrument Point Value: The dollar value per point. Presets ready for: MNQ ($2), MES ($5), NQ ($20), ES ($50), MGC ($10). You can also use Auto (Chart) to take it from TradingView or set a Custom value.
Trade Levels:

Entry / SL: Always work with drag & drop. 0 = AUTO mode on current price.
AUTO Offset %: How far the SL will be from Entry in AUTO mode.
Table Settings:

Table Position & Size: Move the info panel anywhere - Top Right, Bottom Left, etc. - and change its size so it never blocks your candles.
What You See In The Table:

Direction: Auto-detects LONG / SHORT based on line positions
Stop Distance: Distance in points
Contracts: The number you need - how many contracts to buy/sell
Total Risk & Risk per 1: Your actual total risk and risk for a single contract
Built for Futures traders who want to trade like professionals. Define your stop before you enter!

Disclaimer: This is a utility tool for calculation only and not financial advice.

## Source Code

````pine
// @version=6
indicator("Position Size Calculator - Drag Only FIX AUTO", shorttitle="Risk Calculator AUTO DRAG", overlay=true, max_lines_count=500, max_labels_count=500)

// 1. סיכון
risk_amount = input.float(300, title="Risk Amount ($)", step=50, group="Risk Settings")
point_val_mode = input.string("MNQ ($2)", title="Instrument Point Value", options=["Auto (Chart)", "MNQ ($2)", "MES ($5)", "NQ ($20)", "ES ($50)", "MGC ($10)", "Custom"], group="Risk Settings")
custom_point_val = input.float(2.0, title="Custom Point Value", group="Risk Settings")

// 2. רמות - גרירה בלבד, 0 = AUTO חד פעמי על מחיר נוכחי
entry_price = input.price(0, title="Entry Line | 0=AUTO על מחיר נוכחי, אחר כך גרור", confirm=true, group="Trade Levels")
sl_price = input.price(0, title="Stop Loss | 0=AUTO, אחר כך גרור", confirm=true, group="Trade Levels")
auto_offset_percent = input.float(0.5, title="AUTO Offset % כשלא לוחצים", minval=0.05, step=0.1, group="Trade Levels")
entry_color = input.color(color.new(#2962FF, 0), title="Entry Color", group="Trade Levels")
sl_color = input.color(color.new(#F23645, 0), title="SL Color", group="Trade Levels")

// 3. טבלה
table_pos_in = input.string("Bottom Right", title="Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group="Table Settings")
table_size_in = input.string("Normal", title="Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table Settings")

// 4. חישובים
float point_val = syminfo.pointvalue
if point_val_mode == "MNQ ($2)"
    point_val := 2.0
else if point_val_mode == "MES ($5)"
    point_val := 5.0
else if point_val_mode == "NQ ($20)"
    point_val := 20.0
else if point_val_mode == "ES ($50)"
    point_val := 50.0
else if point_val_mode == "MGC ($10)"
    point_val := 10.0
else if point_val_mode == "Custom"
    point_val := custom_point_val

// === תיקון לוגי - שומר AUTO פעם אחת בלבד ===
var float autoEntryStored = na
var float autoSLStored = na
if na(autoEntryStored)
    autoEntryStored := close
    autoSLStored := close * (1 - auto_offset_percent/100)

float finalEntry = entry_price == 0 ? autoEntryStored : entry_price
float finalSL = sl_price == 0 ? (entry_price == 0 ? autoSLStored : finalEntry * (1 - auto_offset_percent/100)) : sl_price

bool valid_trade = finalEntry != finalSL and finalEntry > 0 and finalSL > 0
float dist_points = math.abs(finalEntry - finalSL)
float risk_per_1 = dist_points * point_val
int contracts = valid_trade and risk_per_1 > 0 ? math.max(0, math.round(risk_amount / risk_per_1)) : 0
float actual_risk = contracts * risk_per_1
bool is_long = finalEntry > finalSL

// 5. ציור רק ימינה - בלי היסטוריה
var line entry_line = na
var line sl_line = na
var label entry_lbl = na
var label sl_lbl = na

if barstate.islast
    if not na(entry_line)
        line.delete(entry_line)
    if not na(sl_line)
        line.delete(sl_line)
    if not na(entry_lbl)
        label.delete(entry_lbl)
    if not na(sl_lbl)
        label.delete(sl_lbl)

    if valid_trade
        entry_line := line.new(bar_index, finalEntry, bar_index + 1, finalEntry, color=entry_color, width=2, extend=extend.right)
        sl_line := line.new(bar_index, finalSL, bar_index + 1, finalSL, color=sl_color, width=2, extend=extend.right, style=line.style_dashed)
        linefill.new(entry_line, sl_line, color=color.new(sl_color, 85))

        entry_lbl := label.new(bar_index + 3, finalEntry, text="ENTRY: " + str.tostring(finalEntry, format.mintick), style=label.style_label_down, color=color.new(entry_color, 100), textcolor=entry_color, size=size.small)
        sl_lbl := label.new(bar_index + 3, finalSL, text="SL: " + str.tostring(finalSL, format.mintick), style=label.style_label_up, color=color.new(sl_color, 100), textcolor=sl_color, size=size.small)

// 6. טבלה
var table risk_panel = na
if barstate.islast
    if not na(risk_panel)
        table.delete(risk_panel)
        
    var pos = position.bottom_right
    if table_pos_in == "Top Right"
        pos := position.top_right
    else if table_pos_in == "Top Left"
        pos := position.top_left
    else if table_pos_in == "Bottom Left"
        pos := position.bottom_left
    else if table_pos_in == "Middle Right"
        pos := position.middle_right
    else if table_pos_in == "Middle Left"
        pos := position.middle_left
        
    var t_size = size.normal
    if table_size_in == "Tiny"
        t_size := size.tiny
    else if table_size_in == "Small"
        t_size := size.small
    else if table_size_in == "Large"
        t_size := size.large
    else if table_size_in == "Huge"
        t_size := size.huge

    risk_panel := table.new(pos, 2, 5, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
    
    if valid_trade
        color dir_color = is_long ? color.rgb(6, 162, 47) : color.rgb(207, 23, 23)
        table.cell(risk_panel, 0, 0, "Direction:", text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 1, 0, is_long? "LONG" : "SHORT", text_color=dir_color, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 0, 1, "Stop Distance:", text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 1, 1, str.tostring(dist_points, "#.##") + " pts", text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 0, 2, "Contracts:", text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 1, 2, str.tostring(contracts), text_color=color.yellow, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 0, 3, "Total Risk:", text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 1, 3, "$" + str.tostring(actual_risk, "#.##"), text_color=color.white, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 0, 4, "Risk per 1:", text_color=color.gray, text_halign=text.align_left, text_size=t_size)
        table.cell(risk_panel, 1, 4, "$" + str.tostring(risk_per_1, "#.##"), text_color=color.gray, text_halign=text.align_left, text_size=t_size)
    else
        table.cell(risk_panel, 0, 0, "Waiting for Chart Click", text_color=color.gray, text_size=t_size)
````
