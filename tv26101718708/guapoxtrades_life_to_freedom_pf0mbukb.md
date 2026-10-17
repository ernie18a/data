# GUAPOXTRADES - Life To Freedom

- url: https://www.tradingview.com/script/pf0MBuKb-GUAPOXTRADES-Life-To-Freedom/
- type: indicator
- pine_id: PUB;26362a96005649ecac87012c899c2c42
- version: 1.0

## Description

GUAPOXTRADES – Life To Freedom
The Life To Freedom indicator is a financial readiness and risk-management framework designed to help traders evaluate the relationship between employment income, trading capital, and long-term financial independence.
Unlike traditional trading indicators that focus on entries, exits, or market direction, this tool focuses on the trader behind the chart.

Key Features
Freedom Readiness Matrix
Evaluates whether critical financial and business milestones have been achieved before transitioning toward full-time trading.

Metrics include:
Emergency Fund
Trading Consistency
Trades Logged
LLC Creation
Debt-Free Status
Tax Reserve
Market-Funded Status
Opportunity Cost
Positive Monthly Surplus
Recovery Time Engine

Calculates how long it would take employment income to absorb a trading loss based on account size, risk percentage, income, and expenses.

This helps answer:
"How much of my life does a trading mistake cost?"

Primary Engine Analysis
Identifies the primary source supporting financial growth:
Employment, Transitional, Trading

This allows traders to understand when employment remains the primary recovery engine and when trading becomes the dominant contributor.

Opportunity Cost Calculator
Measures the amount of time committed to employment and evaluates whether work obligations may be limiting trading opportunities, analysis, or business development.

Multi-Job Income Engine
Supports up to three separate employment sources with independent controls for:
Hourly Wage
Weekly Hours
Active / Inactive Status
Monthly income can also be manually entered when preferred.

GT Freedom Readiness Score
Compares actual financial conditions against selected personal requirements and generates a readiness percentage based on the criteria chosen by the user.

Philosophy
The purpose of this indicator is not to predict market direction.
The purpose is to provide a structured framework for evaluating financial preparedness, risk absorption, and readiness for greater trading independence.
Markets measure price.

Life To Freedom measures preparedness.
Disclaimer: This indicator is provided for educational and informational purposes only. It does not provide financial, legal, tax, or investment advice. All trading involves risk, and past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("GUAPOXTRADES - Life To Freedom", overlay = true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADING CAPITAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
accountBalance = input.float(50000, "Trading Account Balance", minval = 0, group = "Trading Capital")
riskPercent    = input.float(2.0, "Risk / Error % Per Trade", minval = 0.01, step = 0.25, group = "Trading Capital")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INCOME ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useManualIncome = input.bool(false, "Use Manual Monthly Income", group = "Income Engine")
manualIncome    = input.float(4000, "Manual Monthly Income", minval = 0, group = "Income Engine")

job1On    = input.bool(true, "Job 1 Active", group = "Job 1")
job1Wage  = input.float(25, "Job 1 Hourly Wage", minval = 0, group = "Job 1")
job1Hours = input.float(40, "Job 1 Weekly Hours", minval = 0, group = "Job 1")

job2On    = input.bool(false, "Job 2 Active", group = "Job 2")
job2Wage  = input.float(20, "Job 2 Hourly Wage", minval = 0, group = "Job 2")
job2Hours = input.float(20, "Job 2 Weekly Hours", minval = 0, group = "Job 2")

job3On    = input.bool(false, "Job 3 Active", group = "Job 3")
job3Wage  = input.float(15, "Job 3 Hourly Wage", minval = 0, group = "Job 3")
job3Hours = input.float(10, "Job 3 Weekly Hours", minval = 0, group = "Job 3")

monthlyExpenses = input.float(2500, "Monthly Expenses", minval = 0, group = "Life Expenses")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REALITY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emergencyFund = input.float(30000, "Emergency Fund", minval = 0, group = "Reality Engine")
emergencyMonthsRequired = input.float(12, "Emergency Fund Months Required", minval = 1, group = "Reality Engine")

profitableMonths = input.int(12, "Profitable Months Documented", minval = 0, group = "Reality Engine")
profitableMonthsRequired = input.int(12, "Profitable Months Required", minval = 1, group = "Reality Engine")

tradesLogged = input.int(100, "Trades Logged", minval = 0, group = "Reality Engine")
tradesRequired = input.int(100, "Trades Required", minval = 1, group = "Reality Engine")

llcCreated = input.bool(false, "LLC Created", group = "Reality Engine")
debtFree   = input.bool(true, "Debt Free", group = "Reality Engine")
taxReserve = input.bool(false, "Tax Reserve Ready", group = "Reality Engine")

hoursLostWeekly  = input.float(40, "Hours Lost To Employment Weekly", minval = 0, group = "Opportunity Cost")
opportunityLimit = input.float(10, "Opportunity Cost Pass Threshold", minval = 0, group = "Opportunity Cost")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUIREMENT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
reqEmergencyFund = input.bool(true, "Require Emergency Fund", group = "Requirement Engine")
reqConsistency   = input.bool(true, "Require Consistency", group = "Requirement Engine")
reqTradesLogged  = input.bool(true, "Require 100 Trades Logged", group = "Requirement Engine")
reqLLC           = input.bool(false, "Require LLC Created", group = "Requirement Engine")
reqDebtFree      = input.bool(true, "Require Debt Free", group = "Requirement Engine")
reqTaxReserve    = input.bool(false, "Require Tax Reserve", group = "Requirement Engine")
reqMarketFunded  = input.bool(true, "Require Market Funded", group = "Requirement Engine")
reqOpportunity   = input.bool(true, "Require Opportunity Cost", group = "Requirement Engine")
reqSurplus       = input.bool(true, "Require Positive Surplus", group = "Requirement Engine")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GT STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
miniMode  = input.bool(false, "Mini Mode", group = "GT Style")
tintLevel = input.int(80, "Panel Tint / Transparency", minval = 0, maxval = 100, group = "GT Style")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Center", "Top Right",
                "Middle Left", "Middle Center", "Middle Right",
                "Bottom Left", "Bottom Center", "Bottom Right"],
     group = "GT Style")

textSizeInput = input.string("Tiny", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = "GT Style")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STYLE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos = switch panelPosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right

txtSize = switch textSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INCOME MATH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
job1Weekly = job1On ? job1Wage * job1Hours : 0
job2Weekly = job2On ? job2Wage * job2Hours : 0
job3Weekly = job3On ? job3Wage * job3Hours : 0

weeklyJobIncome = job1Weekly + job2Weekly + job3Weekly
autoMonthlyIncome = weeklyJobIncome * 4.33
monthlyIncome = useManualIncome ? manualIncome : autoMonthlyIncome

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE MATH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
riskDollars      = accountBalance * (riskPercent / 100)
monthlySurplus   = monthlyIncome - monthlyExpenses
weeklyAbsorption = monthlySurplus / 4.33

recoveryWeeks  = weeklyAbsorption > 0 ? riskDollars / weeklyAbsorption : na
recoveryMonths = not na(recoveryWeeks) ? recoveryWeeks / 4.33 : na
runwayMonths   = monthlyExpenses > 0 ? emergencyFund / monthlyExpenses : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REALITY CHECKS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hasEmergencyFund = not na(runwayMonths) and runwayMonths >= emergencyMonthsRequired
hasConsistency   = profitableMonths >= profitableMonthsRequired
hasTradesLogged  = tradesLogged >= tradesRequired
isMarketFunded   = not na(recoveryWeeks) and recoveryWeeks >= 8
hasOpportunity   = hoursLostWeekly >= opportunityLimit
hasSurplus       = monthlySurplus > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// READINESS MATRIX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
activeReqCount = 0
activeReqCount += reqEmergencyFund ? 1 : 0
activeReqCount += reqConsistency ? 1 : 0
activeReqCount += reqTradesLogged ? 1 : 0
activeReqCount += reqLLC ? 1 : 0
activeReqCount += reqDebtFree ? 1 : 0
activeReqCount += reqTaxReserve ? 1 : 0
activeReqCount += reqMarketFunded ? 1 : 0
activeReqCount += reqOpportunity ? 1 : 0
activeReqCount += reqSurplus ? 1 : 0

metReqCount = 0
metReqCount += reqEmergencyFund and hasEmergencyFund ? 1 : 0
metReqCount += reqConsistency and hasConsistency ? 1 : 0
metReqCount += reqTradesLogged and hasTradesLogged ? 1 : 0
metReqCount += reqLLC and llcCreated ? 1 : 0
metReqCount += reqDebtFree and debtFree ? 1 : 0
metReqCount += reqTaxReserve and taxReserve ? 1 : 0
metReqCount += reqMarketFunded and isMarketFunded ? 1 : 0
metReqCount += reqOpportunity and hasOpportunity ? 1 : 0
metReqCount += reqSurplus and hasSurplus ? 1 : 0

readinessPercent = activeReqCount > 0 ? metReqCount / activeReqCount * 100 : 0
missingReqs = activeReqCount - metReqCount

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
primaryEngine = weeklyAbsorption <= 0 ? "TRADING ONLY" :
     recoveryWeeks <= 4 ? "EMPLOYMENT" :
     recoveryWeeks <= 8 ? "TRANSITIONAL" :
     "TRADING"

freedomStatus = readinessPercent >= 100 ? "FREEDOM READY" :
     readinessPercent >= 80 ? str.tostring(missingReqs) + " MISSING" :
     readinessPercent >= 60 ? "TRANSITIONAL" :
     readinessPercent >= 40 ? "BUILDING CAPITAL" :
     "SURVIVAL MODE"

statusColor = readinessPercent >= 100 ? color.lime :
     readinessPercent >= 80 ? color.yellow :
     readinessPercent >= 60 ? color.orange :
     color.red

lifeCost = weeklyAbsorption <= 0 ? "No Job Engine" :
     recoveryWeeks > 4 ? str.tostring(recoveryMonths, "#.##") + " Months" :
     str.tostring(recoveryWeeks, "#.##") + " Weeks"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
matrixText(required, reality) =>
    required ? reality ? "YES / REQ" : "NO / REQ" : reality ? "YES / OFF" : "NO / OFF"

matrixColor(required, reality) =>
    required ? reality ? color.lime : color.red : color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table gtPanel = table.new(pos, 2, 20, frame_color = color.white, frame_width = 1, border_color = color.gray, border_width = 1)

if barstate.islast
    table.set_position(gtPanel, pos)
    table.set_bgcolor(gtPanel, color.new(color.black, tintLevel))

    table.cell(gtPanel, 0, 0, "GT LIFE TO FREEDOM", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 0, "v4", text_color = color.white, text_size = txtSize)

    table.cell(gtPanel, 0, 1, "Freedom Status", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 1, freedomStatus, text_color = statusColor, text_size = txtSize)

    table.cell(gtPanel, 0, 2, "Readiness", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 2, str.tostring(readinessPercent, "#") + "%", text_color = statusColor, text_size = txtSize)

    table.cell(gtPanel, 0, 3, "Requirements", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 3, str.tostring(metReqCount) + " / " + str.tostring(activeReqCount), text_color = statusColor, text_size = txtSize)

    table.cell(gtPanel, 0, 4, "Primary Engine", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 4, primaryEngine, text_color = statusColor, text_size = txtSize)

    table.cell(gtPanel, 0, 5, "Recovery Time", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 5, lifeCost, text_color = statusColor, text_size = txtSize)

    table.cell(gtPanel, 0, 6, "Runway", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 6, str.tostring(runwayMonths, "#.##") + " Months", text_color = matrixColor(reqEmergencyFund, hasEmergencyFund), text_size = txtSize)

    table.cell(gtPanel, 0, 7, "Risk / Error", text_color = color.white, text_size = txtSize)
    table.cell(gtPanel, 1, 7, "$" + str.tostring(riskDollars, "#,###.##"), text_color = color.white, text_size = txtSize)

    if not miniMode
        table.cell(gtPanel, 0, 8, "Emergency Fund", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 8, matrixText(reqEmergencyFund, hasEmergencyFund), text_color = matrixColor(reqEmergencyFund, hasEmergencyFund), text_size = txtSize)

        table.cell(gtPanel, 0, 9, "Consistency", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 9, matrixText(reqConsistency, hasConsistency), text_color = matrixColor(reqConsistency, hasConsistency), text_size = txtSize)

        table.cell(gtPanel, 0, 10, "100 Trades", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 10, matrixText(reqTradesLogged, hasTradesLogged), text_color = matrixColor(reqTradesLogged, hasTradesLogged), text_size = txtSize)

        table.cell(gtPanel, 0, 11, "LLC Created", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 11, matrixText(reqLLC, llcCreated), text_color = matrixColor(reqLLC, llcCreated), text_size = txtSize)

        table.cell(gtPanel, 0, 12, "Debt Free", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 12, matrixText(reqDebtFree, debtFree), text_color = matrixColor(reqDebtFree, debtFree), text_size = txtSize)

        table.cell(gtPanel, 0, 13, "Tax Reserve", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 13, matrixText(reqTaxReserve, taxReserve), text_color = matrixColor(reqTaxReserve, taxReserve), text_size = txtSize)

        table.cell(gtPanel, 0, 14, "Market Funded", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 14, matrixText(reqMarketFunded, isMarketFunded), text_color = matrixColor(reqMarketFunded, isMarketFunded), text_size = txtSize)

        table.cell(gtPanel, 0, 15, "Opportunity Cost", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 15, matrixText(reqOpportunity, hasOpportunity), text_color = matrixColor(reqOpportunity, hasOpportunity), text_size = txtSize)

        table.cell(gtPanel, 0, 16, "Positive Surplus", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 16, matrixText(reqSurplus, hasSurplus), text_color = matrixColor(reqSurplus, hasSurplus), text_size = txtSize)

        table.cell(gtPanel, 0, 17, "Monthly Income", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 17, "$" + str.tostring(monthlyIncome, "#,###.##"), text_color = color.white, text_size = txtSize)

        table.cell(gtPanel, 0, 18, "Monthly Surplus", text_color = color.white, text_size = txtSize)
        table.cell(gtPanel, 1, 18, "$" + str.tostring(monthlySurplus, "#,###.##"), text_color = matrixColor(reqSurplus, hasSurplus), text_size = txtSize)

        table.cell(gtPanel, 0, 19, "GT Matrix", text_color = color.gray, text_size = txtSize)
        table.cell(gtPanel, 1, 19, "Reality vs Req", text_color = color.gray, text_size = txtSize)
````
