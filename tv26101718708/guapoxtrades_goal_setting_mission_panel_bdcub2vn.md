# Guapoxtrades Goal Setting & Mission Panel

- url: https://www.tradingview.com/script/bDCUb2VN-Guapoxtrades-Goal-Setting-Mission-Panel/
- type: indicator
- pine_id: PUB;79060cf51bc5478bad56ad68ba7935cd
- version: 1.0

## Description

GT Mission Panel™ - By Guapo Trades®

Purpose- Accountability Framework towards the operator mission

Overview
The GT Mission Panel™ is a trader accountability and goal-management system designed to keep your long-term objectives visible while you operate in the short-term environment of the financial markets.

Many traders spend years developing technical skills but struggle with consistency, discipline, emotional control, and maintaining focus on their larger purpose.

The GT Mission Panel™ was created to help bridge that gap.

Rather than acting as a trading signal generator, this tool serves as a daily reminder of:
Who you are
What you're building
Why you're trading
What rules you must follow
What goals still remain ahead

The objective is simple:
Keep your mission visible when emotions are trying to take control.

Core Features
Mission Statement Integration
Create a personalized mission statement that remains visible directly on your chart.

Your mission becomes part of your trading environment rather than something forgotten in a notebook.

Purpose Reminder:
Storing the deeper reason behind your journey.

Whether your objective is:
Financial freedom
Family security
Business ownership
Legacy building
Personal growth

The purpose remains visible while decisions are being made.

Personal Creed System
Display your personal trading creed directly on your charts.

Examples:
Trade like a professional.
Protect capital first.
Discipline over emotion.
Process over outcome.

Your creed becomes a constant reinforcement mechanism.
Goal Tracking Framework & Monitor progress toward major milestones.

Examples:
Emergency Fund
LLC Formation
Capital Goals
Business Expansion
Family Trust Development

Track progress while maintaining focus on long-term execution.

Progress Meter
Automatically calculates completion percentage based on completed goals.
This creates a visual representation of progress rather than relying solely on memory.

Rule Reminder Engine
Display critical trading rules directly on your chart.
Examples:
Never risk more than 2%.
No revenge trading.
Trade only high-quality setups.
Trade with a clear mind.
When discipline is most needed, your rules remain visible.
Identity Reinforcement

The GT Mission Panel™ encourages traders to align daily actions with the person they are trying to become.

Instead of focusing solely on profit and loss, traders are reminded to think in terms of:
Process
Discipline
Consistency
Character
Long-term execution
Decision Accountability Question

The panel includes a powerful self-assessment checkpoint:
"Does this trade serve the mission?"
This simple question can help prevent impulsive decisions and emotional trades.

Why GT Mission Panel™?
Most traders lose money because of:
Emotional decision making
Lack of discipline
Goal drift
Overtrading
Revenge trading
Impatience

Very few tools address the psychological side of trading.

The GT Mission Panel™ was built specifically to keep traders focused on the behaviors required for long-term success.

Best Used For
✔ New Traders
✔ Experienced Traders
✔ Goal-Oriented Individuals
✔ Accountability Systems
✔ Trading Psychology Development
✔ Risk Management Reinforcement
✔ Habit Formation
✔ Business Owners
✔ Personal Growth Frameworks
✔ Long-Term Wealth Building

Educational Purpose
The GT Mission Panel™ is not designed to predict market direction or generate trade signals.
Its purpose is to serve as a personal accountability and organizational framework that helps traders remain aligned with their long-term objectives and trading rules.
The indicator is intended to support discipline, consistency, and decision-making processes through visual reminders and goal tracking.

Visual Optimization
GT Mission Panel™ was designed primarily for dark-theme chart layouts.
Panel colors, transparency levels, and contrast settings were optimized specifically for dark backgrounds to maximize readability and reduce visual clutter.

Users utilizing light-themed charts may wish to customize the appearance through:
Settings → Panel Transparency

Additional visual settings can be adjusted to better match personal chart preferences.

Free Community Edition
The GT Mission Panel™ is provided free of charge as part of the Guapo Trades® commitment to trader development and education.

While many tools focus on finding trades, the GT Mission Panel™ focuses on helping traders become the type of person capable of consistently executing them.

About Guapo Trades®
Guapo Trades® develops professional trading tools focused on:
Market Structure
Liquidity
Probability
Risk Management
Trading Psychology
Trader Education
Transform Market Complexity Into Actionable Information.

Disclaimer- Educational Use Only

GT Mission Panel™ is provided solely for educational and informational purposes. This indicator does not provide financial advice, investment advice, trading advice, or recommendations to buy or sell any financial instrument.

This tool is intended exclusively as a personal organization, accountability, goal-setting, and educational framework.

Trading financial markets involves substantial risk and may not be suitable for all investors. Past performance does not guarantee future results.

Users remain solely responsible for their trading decisions, risk management practices, and financial outcomes.

Always perform your own independent analysis before entering any position.

© Guapo Trades® | Professional Trading Tools Built for Serious Traders

## Source Code

````pine
//@version=6
indicator("GT Mission & Goal Setting Panel — Prototype", overlay=true, max_labels_count=50)

//══════════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
//══════════════════════════════════════════════════════════════════════════════
grpCore    = "1. Core Settings"
grpMission = "2. Mission / Purpose"
grpGoals   = "3. Goal Ladder"
grpRules   = "4. Rule Reminder"
grpStyle   = "5. Style"

//══════════════════════════════════════════════════════════════════════════════
// CORE SETTINGS
//══════════════════════════════════════════════════════════════════════════════
showPanel  = input.bool(true, "Show Mission Panel", group=grpCore)
panelMode  = input.string("Full", "Panel Mode", options=["Mini", "Full"], group=grpCore)
panelPos   = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpCore)

//══════════════════════════════════════════════════════════════════════════════
// MISSION / PURPOSE
//══════════════════════════════════════════════════════════════════════════════
operatorName = input.string("Ghost", "Operator Name", group=grpMission)

mainMission = input.string("Build the life you promised yourself.", "Mission Statement", group=grpMission)
purposeLine = input.string("Take My Family Out the Hood", group=grpMission)
sacrifice   = input.string("Remember what it cost to get here.", "Sacrifice Reminder", group=grpMission)
quote       = input.string("Live like a king. Trade like a ghost.", "Quote / Creed", group=grpMission)

//══════════════════════════════════════════════════════════════════════════════
// GOAL LADDER
//══════════════════════════════════════════════════════════════════════════════
goal1 = input.string("$25K Runway", "Goal 1", group=grpGoals)
goal1Done = input.bool(false, "Goal 1 Complete", group=grpGoals)

goal2 = input.string("Launch LLC", "Goal 2", group=grpGoals)
goal2Done = input.bool(false, "Goal 2 Complete", group=grpGoals)

goal3 = input.string("$100K Capital Base", "Goal 3", group=grpGoals)
goal3Done = input.bool(false, "Goal 3 Complete", group=grpGoals)

goal4 = input.string("GuapoxTrades Enterprise Expansion", "Goal 4", group=grpGoals)
goal4Done = input.bool(false, "Goal 4 Complete", group=grpGoals)

goal5 = input.string("Family Trust / Legacy Structure", "Goal 5", group=grpGoals)
goal5Done = input.bool(false, "Goal 5 Complete", group=grpGoals)

//══════════════════════════════════════════════════════════════════════════════
// RULE REMINDER
//══════════════════════════════════════════════════════════════════════════════
rule1 = input.string("Never Risk > 2%", "Rule 1", group=grpRules)
rule2 = input.string("No revenge trades.", "Rule 2", group=grpRules)
rule3 = input.string("Only trade clean setups.", "Rule 3", group=grpRules)
rule4 = input.string("Only trade w/ a clear mind", "Rule 4", group=grpRules)

//══════════════════════════════════════════════════════════════════════════════
// STYLE
//══════════════════════════════════════════════════════════════════════════════
darkMode     = input.bool(true, "Dark Mode", group=grpStyle)
panelTransp  = input.int(10, "Panel Transparency", minval=0, maxval=100, group=grpStyle)
textSizeOpt  = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grpStyle)

bgColor   = darkMode ? color.new(color.black, panelTransp) : color.new(color.white, panelTransp)
txtColor  = darkMode ? color.white : color.black
softColor = darkMode ? color.new(color.white, 65) : color.new(color.black, 65)
goodColor = color.lime
warnColor = color.orange

txtSize = textSizeOpt == "Tiny" ? size.tiny : textSizeOpt == "Small" ? size.small : size.normal

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_status(done) =>
    done ? "✓ Complete" : "• In Progress"

f_statusColor(done) =>
    done ? goodColor : warnColor

completedGoals = (goal1Done ? 1 : 0) + (goal2Done ? 1 : 0) + (goal3Done ? 1 : 0) + (goal4Done ? 1 : 0) + (goal5Done ? 1 : 0)
progressPct = math.round((completedGoals / 5.0) * 100)

//══════════════════════════════════════════════════════════════════════════════
// PANEL
//══════════════════════════════════════════════════════════════════════════════
rows = panelMode == "Mini" ? 8 : 18

var table missionPanel = na
var string lastPos = ""

if na(missionPanel) or panelPos != lastPos
    if not na(missionPanel)
        table.delete(missionPanel)
    missionPanel := table.new(f_pos(panelPos), 2, rows, frame_color=color.new(color.white, 70), frame_width=1)
    lastPos := panelPos

if barstate.islast and showPanel
    table.clear(missionPanel, 0, 0, 1, rows - 1)

    table.cell(missionPanel, 0, 0, "GT MISSION", text_color=txtColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 0, operatorName, text_color=goodColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 1, "Mission", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 1, mainMission, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 2, "Purpose", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 2, purposeLine, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 3, "Creed", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 3, quote, text_color=goodColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 4, "Progress", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 4, str.tostring(progressPct) + "% Complete", text_color=progressPct >= 80 ? goodColor : warnColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 5, "Reminder", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 5, sacrifice, text_color=warnColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 6, "Rule", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 6, rule1, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

    table.cell(missionPanel, 0, 7, "Rule", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
    table.cell(missionPanel, 1, 7, rule2, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

    if panelMode == "Full"
        table.cell(missionPanel, 0, 8, "Rule", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 8, rule3, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 9, "Rule", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 9, rule4, text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 10, "Goal 1", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 10, goal1 + " — " + f_status(goal1Done), text_color=f_statusColor(goal1Done), bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 11, "Goal 2", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 11, goal2 + " — " + f_status(goal2Done), text_color=f_statusColor(goal2Done), bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 12, "Goal 3", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 12, goal3 + " — " + f_status(goal3Done), text_color=f_statusColor(goal3Done), bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 13, "Goal 4", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 13, goal4 + " — " + f_status(goal4Done), text_color=f_statusColor(goal4Done), bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 14, "Goal 5", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 14, goal5 + " — " + f_status(goal5Done), text_color=f_statusColor(goal5Done), bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 15, "Question", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 15, "Does this trade serve the mission?", text_color=warnColor, bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 16, "Identity", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 16, "Trade like future-you is watching.", text_color=txtColor, bgcolor=bgColor, text_size=txtSize)

        table.cell(missionPanel, 0, 17, "Command", text_color=softColor, bgcolor=bgColor, text_size=txtSize)
        table.cell(missionPanel, 1, 17, "Protect capital. Protect purpose.", text_color=goodColor, bgcolor=bgColor, text_size=txtSize)
````
