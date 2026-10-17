# GuapoxTrades - GT Check-In / Reminder List

- url: https://www.tradingview.com/script/uJycTSGC-GuapoxTrades-GT-Check-In-Reminder-List/
- type: indicator
- pine_id: PUB;fc12896fbf8f4e68bcd9c5408869c2e3
- version: 1.0

## Description

Guapoxtrades GT Check-In & Rule Base™

Trading Discipline • Psychological Accountability • Pre-Trade Decision Support

The Guapoxtrades GT Check-In & Rule Base™ indicator was designed to help traders maintain consistency, discipline, and emotional awareness before entering the market.

While most indicators focus exclusively on chart analysis, this tool focuses on the trader behind the chart.

The objective is simple:
Protect psychology. Protect capital. Protect consistency.

Core Features

GT Check-In System
A built-in accountability module that allows traders to manually log trading check-ins throughout the day.

The system tracks:
Current check-in count
Maximum allowed check-ins
Emotional state
Trading motivation
Behavioral risk factors
Discipline status

By requiring the trader to consciously identify why they are returning to the chart, the indicator helps reduce emotional decision-making and impulsive trading behavior.

Psychological Risk Detection
The Check-In Auditor evaluates selected emotional and behavioral inputs and classifies trading conditions into categories such as:
Stable
Caution
At Limit
High Risk
Violation

This provides an immediate visual reminder of whether current trading behavior remains aligned with the trader's rules and objectives.

Rule Base Reminder Panel
The Rule Base panel acts as a permanent trading playbook displayed directly on the chart.

Examples include:
Session restrictions
Maximum trades per day
Risk management reminders
Lot size verification
Reward-to-risk requirements
Entry confirmation procedures

This keeps critical rules visible during live market conditions when discipline is often tested the most.

Mini Trade Plan Engine

The indicator includes a lightweight planning module capable of displaying:
Entry Level
Stop Loss Level
Take Profit Level

These levels can be manually defined before trade execution to encourage planning before participation.

The goal is to reinforce process-driven trading rather than emotionally driven execution.
Custom Branding & Personalization

Users may customize:
Username
Check-In Messages
Trading Rules
Reminder Statements
Panel Positions
Color Schemes
Panel Transparency

This allows the indicator to become a personalized trading operating system rather than a generic reminder tool.

Why This Indicator Was Created

Most traders fail because of:
Impulse trading
Overtrading
Revenge trading
Lack of structure
Emotional decision-making

The GT Check-In & Rule Base™ was built to act as a psychological checkpoint before capital is placed at risk.

The indicator encourages traders to slow down, review their process, and verify that every trade aligns with their predefined trading plan.

Because in reality:
Most trading mistakes occur before the trade is ever placed.

Visual Design Notice
This indicator was developed and optimized primarily for dark-theme chart environments.
Panel colors, text contrast, transparency levels, and visual spacing were designed using dark-background chart layouts to maximize readability while minimizing chart obstruction.

Users operating on lighter chart themes may need to customize the appearance through:
Settings → Style
Panel Tint
Header Tint
Marker Color
Text Size
Panel Position
Entry / Stop Loss / Take Profit Colors

These settings allow the indicator to be adjusted to virtually any charting environment while preserving functionality.

Recommended Use:
This indicator is best used:
✅ Before entering a trade
✅ During active trade management
✅ During periods of emotional stress
✅ As part of a structured trading routine
✅ Alongside a complete trading plan

The GT Check-In & Rule Base™ is designed to complement technical analysis, not replace it.

Disclaimer - Educational Use Only.

The Guapoxtrades GT Check-In & Rule Base™ indicator is intended solely for educational, organizational, and informational purposes.

This tool does not provide financial advice, investment advice, trading recommendations, or guarantees of profitability.

The psychological assessments, discipline classifications, reminders, check-in systems, and trade planning tools contained within this indicator are designed to assist traders in maintaining structure and consistency but do not predict future market outcomes.

Trading forex, futures, stocks, cryptocurrencies, options, and other financial instruments involves substantial risk and may result in the loss of capital.

Users are solely responsible for their own trading decisions, risk management practices, and financial results. Past performance does not guarantee future performance.

© Guapoxtrades. All Rights Reserved. Built for disciplined traders.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © GuapoxTrades

//@version=6
indicator("GuapoxTrades — GT Check-In / Reminder List", overlay=true, max_labels_count=100, max_lines_count=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
//══════════════════════════════════════════════════════════════════════════════
grpMain     = "1. Check-In Auditor"
grpReminder = "2. Reminder Panel"
grpPlan     = "3. Mini Trade Plan Lines"
grpBrand    = "4. Branding"
grpStyle    = "5. Style"

//══════════════════════════════════════════════════════════════════════════════
// CHECK-IN INPUTS
//══════════════════════════════════════════════════════════════════════════════
showMarker     = input.bool(true, "Show Check-In Marker Line", group=grpMain)
showLabel      = input.bool(true, "Show Check-In Label", group=grpMain)
showCheckPanel = input.bool(false, "Show Check-In Panel", group=grpMain)

checkInTime  = input.time(defval=1747060200000, title="Manual Check-In Time", group=grpMain)
checkInCount = input.int(1, "Today's Check-In Count", minval=0, maxval=20, group=grpMain)
maxCheckIns  = input.int(3, "Max Allowed Check-Ins", minval=1, maxval=20, group=grpMain)

reason = input.string("Routine Check", "Reason", options=["Routine Check", "Trade Management", "Signal Review", "Boredom", "Fear", "Revenge Trading", "Impulse", "Other"], group=grpMain)
emotionState = input.string("Calm", "Trader State", options=["Calm", "Focused", "Impatient", "Fearful", "Greedy", "Frustrated", "Revenge Mode"], group=grpMain)

useCustomMessage = input.bool(true, "Use Custom Check-In Message", group=grpMain)
customMessage    = input.string("Rules first. Trade second.", "Custom Check-In Message", group=grpMain)

//══════════════════════════════════════════════════════════════════════════════
// REMINDER INPUTS
//══════════════════════════════════════════════════════════════════════════════
showReminderPanel = input.bool(true, "Show Reminder Panel", group=grpReminder)

allowedSessions = input.string("London + New York only", "Allowed Sessions", group=grpReminder)
maxTradesPerDay = input.int(2, "Max Trades Per Day", minval=1, maxval=20, group=grpReminder)

reminder1 = input.string("Confirm bias before entry", "Rule 1", group=grpReminder)
reminder2 = input.string("No revenge trading", "Rule 2", group=grpReminder)
reminder3 = input.string("Calculate lot size first", "Rule 3", group=grpReminder)
reminder4 = input.string("Set SL + TP before entry", "Rule 4", group=grpReminder)
reminder5 = input.string("Minimum 1:3 RR", "Rule 5", group=grpReminder)

customReminderFooter = input.string("All Trading First starts off Psychological", group=grpReminder)

//══════════════════════════════════════════════════════════════════════════════
// MINI TRADE PLAN LINE INPUTS
//══════════════════════════════════════════════════════════════════════════════
showPlanLines   = input.bool(true, "Show Mini Entry / SL / TP Lines", group=grpPlan)
entryPrice      = input.float(0.0, "Entry Price", step=0.0001, group=grpPlan)
stopLossPrice   = input.float(0.0, "Stop Loss Price", step=0.0001, group=grpPlan)
takeProfitPrice = input.float(0.0, "Take Profit Price", step=0.0001, group=grpPlan)

lineLengthBars = input.int(25, "Mini Line Length", minval=5, maxval=200, group=grpPlan)
entryColor     = input.color(color.white, "Entry Line Color", group=grpPlan)
slColor        = input.color(color.red, "Stop Loss Line Color", group=grpPlan)
tpColor        = input.color(color.lime, "Take Profit Line Color", group=grpPlan)
planLineWidth  = input.int(1, "Mini Line Width", minval=1, maxval=4, group=grpPlan)

//══════════════════════════════════════════════════════════════════════════════
// BRAND + STYLE
//══════════════════════════════════════════════════════════════════════════════
brandName = "GuapoxTrades"
userName    = input.string("Guapo", "Custom Username", group=grpBrand)
showWelcome = input.bool(true, "Show Welcome Home", group=grpBrand)

checkPanelPos = input.string(
 "Middle Right",
 "Check-In Panel Position",
 options=[
     "Top Right",
     "Top Center",
     "Top Left",
     "Middle Right",
     "Middle Center",
     "Middle Left",
     "Bottom Right",
     "Bottom Center",
     "Bottom Left"
 ],
 group=grpStyle
)

reminderPanelPos = input.string(
 "Top Center",
 "Reminder Panel Position",
 options=[
     "Top Right",
     "Top Center",
     "Top Left",
     "Middle Right",
     "Middle Center",
     "Middle Left",
     "Bottom Right",
     "Bottom Center",
     "Bottom Left"
 ],
 group=grpStyle
)

panelTextSize = input.string("Tiny", "Panel Text Size", options=["Tiny", "Small", "Normal"], group=grpStyle)
panelTint     = input.int(90, "Panel Tint", minval=0, maxval=95, group=grpStyle)
headerTint    = input.int(0, "Header Tint", minval=0, maxval=95, group=grpStyle)
markerColor   = input.color(color.rgb(1, 121, 151), "Brand / Marker Color", group=grpStyle)

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_panelPos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        => position.bottom_left

txtSize = panelTextSize == "Tiny" ? size.tiny : panelTextSize == "Small" ? size.small : size.normal

//══════════════════════════════════════════════════════════════════════════════
// DISCIPLINE LOGIC
//══════════════════════════════════════════════════════════════════════════════
overLimit = checkInCount > maxCheckIns
atLimit   = checkInCount == maxCheckIns

dangerEmotion = emotionState == "Impatient" or emotionState == "Fearful" or emotionState == "Greedy" or emotionState == "Frustrated" or emotionState == "Revenge Mode"
dangerReason  = reason == "Boredom" or reason == "Fear" or reason == "Revenge Trading" or reason == "Impulse"

disciplineText  = overLimit ? "VIOLATION" : atLimit and (dangerEmotion or dangerReason) ? "HIGH RISK" : atLimit ? "AT LIMIT" : dangerEmotion or dangerReason ? "CAUTION" : "STABLE"
disciplineColor = overLimit ? color.red : atLimit ? color.yellow : dangerEmotion or dangerReason ? color.orange : color.lime

autoMessage = overLimit ? "Step away." : atLimit ? "No more checks." : dangerEmotion or dangerReason ? "Pause first." : "Stay disciplined."
finalMessage = useCustomMessage ? customMessage : autoMessage

welcomeText = showWelcome ? "Welcome home, " + userName : "Discipline Mode"

//══════════════════════════════════════════════════════════════════════════════
// CHECK-IN MARKER
//══════════════════════════════════════════════════════════════════════════════
markerBar = time >= checkInTime and time[1] < checkInTime

var line checkLine = na
var label checkLabel = na

if markerBar and showMarker
    if not na(checkLine)
        line.delete(checkLine)

    checkLine := line.new(checkInTime, low, checkInTime, high, xloc=xloc.bar_time, extend=extend.both, color=markerColor, width=2)

    if not na(checkLabel)
        label.delete(checkLabel)

    if showLabel
        checkLabel := label.new(bar_index, high, brandName + "\nGT CHECK-IN\n" + str.tostring(checkInCount) + "/" + str.tostring(maxCheckIns) + "\n" + disciplineText, style=label.style_label_down, textcolor=color.white, color=color.new(markerColor, 0), size=size.small)

if not showLabel and not na(checkLabel)
    label.delete(checkLabel)
    checkLabel := na

//══════════════════════════════════════════════════════════════════════════════
// MINI TRADE PLAN LINES
//══════════════════════════════════════════════════════════════════════════════
var line entryLine = na
var line slLine = na
var line tpLine = na

hasEntry = entryPrice > 0
hasSL    = stopLossPrice > 0
hasTP    = takeProfitPrice > 0

if barstate.islast
    if not showPlanLines
        if not na(entryLine)
            line.delete(entryLine)
            entryLine := na
        if not na(slLine)
            line.delete(slLine)
            slLine := na
        if not na(tpLine)
            line.delete(tpLine)
            tpLine := na

    if showPlanLines
        x1 = bar_index
        x2 = bar_index + lineLengthBars

        if hasEntry
            if na(entryLine)
                entryLine := line.new(x1, entryPrice, x2, entryPrice, xloc=xloc.bar_index, color=entryColor, width=planLineWidth)
            else
                line.set_xy1(entryLine, x1, entryPrice)
                line.set_xy2(entryLine, x2, entryPrice)
                line.set_color(entryLine, entryColor)
                line.set_width(entryLine, planLineWidth)

        if hasSL
            if na(slLine)
                slLine := line.new(x1, stopLossPrice, x2, stopLossPrice, xloc=xloc.bar_index, color=slColor, width=planLineWidth)
            else
                line.set_xy1(slLine, x1, stopLossPrice)
                line.set_xy2(slLine, x2, stopLossPrice)
                line.set_color(slLine, slColor)
                line.set_width(slLine, planLineWidth)

        if hasTP
            if na(tpLine)
                tpLine := line.new(x1, takeProfitPrice, x2, takeProfitPrice, xloc=xloc.bar_index, color=tpColor, width=planLineWidth)
            else
                line.set_xy1(tpLine, x1, takeProfitPrice)
                line.set_xy2(tpLine, x2, takeProfitPrice)
                line.set_color(tpLine, tpColor)
                line.set_width(tpLine, planLineWidth)

//══════════════════════════════════════════════════════════════════════════════
// CHECK-IN PANEL
//══════════════════════════════════════════════════════════════════════════════
var table checkPanel = na
var string lastCheckPanelPos = ""

if na(checkPanel) or checkPanelPos != lastCheckPanelPos
    if not na(checkPanel)
        table.delete(checkPanel)
    checkPanel := table.new(f_panelPos(checkPanelPos), 2, 7, frame_color=color.new(markerColor, 45), frame_width=1)
    lastCheckPanelPos := checkPanelPos

if barstate.islast and showCheckPanel
    bg = color.new(color.black, panelTint)
    header = color.new(markerColor, headerTint)

    table.clear(checkPanel, 0, 0, 1, 6)
    table.cell(checkPanel, 0, 0, brandName, text_color=color.white, bgcolor=header, text_size=txtSize)
    table.cell(checkPanel, 1, 0, "CHECK-IN", text_color=color.white, bgcolor=header, text_size=txtSize)

    table.cell(checkPanel, 0, 1, "User", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 1, welcomeText, text_color=markerColor, bgcolor=bg, text_size=txtSize)

    table.cell(checkPanel, 0, 2, "Checks", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 2, str.tostring(checkInCount) + "/" + str.tostring(maxCheckIns), text_color=disciplineColor, bgcolor=bg, text_size=txtSize)

    table.cell(checkPanel, 0, 3, "Status", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 3, disciplineText, text_color=disciplineColor, bgcolor=bg, text_size=txtSize)

    table.cell(checkPanel, 0, 4, "Reason", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 4, reason, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(checkPanel, 0, 5, "State", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 5, emotionState, text_color=disciplineColor, bgcolor=bg, text_size=txtSize)

    table.cell(checkPanel, 0, 6, "Msg", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(checkPanel, 1, 6, finalMessage, text_color=disciplineColor, bgcolor=bg, text_size=txtSize)

if not showCheckPanel and not na(checkPanel)
    table.clear(checkPanel, 0, 0, 1, 6)

//══════════════════════════════════════════════════════════════════════════════
// REMINDER PANEL
//══════════════════════════════════════════════════════════════════════════════
var table reminderPanel = na
var string lastReminderPanelPos = ""

if na(reminderPanel) or reminderPanelPos != lastReminderPanelPos
    if not na(reminderPanel)
        table.delete(reminderPanel)
    reminderPanel := table.new(f_panelPos(reminderPanelPos), 2, 10, frame_color=color.new(markerColor, 55), frame_width=1)
    lastReminderPanelPos := reminderPanelPos

if barstate.islast and showReminderPanel
    bg = color.new(color.black, panelTint)
    header = color.new(markerColor, headerTint)

    table.clear(reminderPanel, 0, 0, 1, 9)

    table.cell(reminderPanel, 0, 0, "GuapoxTrades", text_color=color.white, bgcolor=header, text_size=txtSize)
    table.cell(reminderPanel, 1, 0, "RULE BASE", text_color=color.white, bgcolor=header, text_size=txtSize)

    table.cell(reminderPanel, 0, 1, "Sessions", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 1, allowedSessions, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 2, "Max Trades", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 2, str.tostring(maxTradesPerDay) + "/day", text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 3, "1", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 3, reminder1, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 4, "2", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 4, reminder2, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 5, "3", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 5, reminder3, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 6, "4", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 6, reminder4, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 7, "5", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 7, reminder5, text_color=color.white, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 8, "Plan Lines", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 8, showPlanLines ? "Entry / SL / TP" : "Hidden", text_color=markerColor, bgcolor=bg, text_size=txtSize)

    table.cell(reminderPanel, 0, 9, "Reminder", text_color=color.white, bgcolor=bg, text_size=txtSize)
    table.cell(reminderPanel, 1, 9, customReminderFooter, text_color=color.lime, bgcolor=bg, text_size=txtSize)

if not showReminderPanel and not na(reminderPanel)
    table.clear(reminderPanel, 0, 0, 1, 9)
````
