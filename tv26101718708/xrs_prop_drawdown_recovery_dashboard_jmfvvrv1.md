# XRS Prop Drawdown Recovery Dashboard

- url: https://www.tradingview.com/script/jmfVvRV1-XRS-Prop-Drawdown-Recovery-Dashboard/
- type: indicator
- pine_id: PUB;e9f22a439333411b98e7de41923716c7
- version: 1.0

## Description

[b]XRS Prop Drawdown Recovery Dashboard[/b]

The XRS Drawdown Recovery Dashboard is a risk management and trade planning tool designed to help traders create a structured recovery plan after experiencing drawdown in a funded account, prop firm account, or personal trading account.

Instead of increasing position size and attempting to recover losses through aggressive trading, this dashboard focuses on preserving remaining drawdown while using asymmetric risk-to-reward ratios, limited trade counts, and disciplined risk management to improve the probability of long-term account survival.

## How It Works

Select:

* Account Size
* Total Drawdown Allowance
* Remaining Drawdown
* Recovery Speed (Conservative, Balanced, or Aggressive)

The dashboard automatically calculates a dynamic recovery plan based on the amount of drawdown remaining.

The recovery engine adjusts:

* Suggested position size
* Risk per trade
* Maximum trades per day
* Stop loss distance
* Take profit distance
* Risk-to-reward ratio
* Daily loss limit
* Recovery targets
* Trading rules based on account condition

As drawdown becomes more severe, the dashboard automatically shifts into more defensive recovery modes and recommends tighter risk controls, fewer trades, and larger reward-to-risk requirements.

## Recovery Philosophy

Most traders fail recovery attempts because they increase risk as drawdown increases.

This dashboard follows the opposite approach:

* Risk decreases as drawdown increases.
* Trade frequency decreases as drawdown increases.
* Required reward-to-risk ratios increase as drawdown increases.
* Capital preservation becomes the primary objective.

The goal is not to recover losses as quickly as possible.

The goal is to recover losses while maximizing account survival.

## Recovery States

### Survival

Designed for accounts with very little drawdown remaining.

Focus:

* Smallest position sizes
* Highest reward-to-risk ratios
* One high-quality trade opportunity
* Strict capital preservation

### Critical

For accounts approaching dangerous drawdown levels.

Focus:

* Reduced trade frequency
* Limited daily exposure
* High-quality A+ setups only

### Defensive

For moderate drawdown situations.

Focus:

* Controlled risk
* Selective entries
* Balanced recovery pace

### Controlled

For healthier account conditions where recovery remains important.

Focus:

* Moderate risk allocation
* Multiple opportunities
* Consistent execution

### Normal

For accounts with substantial drawdown available.

Focus:

* Standard risk management
* Consistent process
* Controlled growth

## Suggested Usage

This tool works best when combined with:

* A proven trading strategy
* Consistent trade execution
* Defined stop losses
* Positive expectancy setups
* Strict adherence to daily loss limits

The dashboard is intended to provide a framework for disciplined decision-making and should not be used as a replacement for a complete trading plan.

## Key Features

✔ Dynamic recovery engine

✔ Position size recommendations

✔ Risk-per-trade calculations

✔ Daily loss limits

✔ Recovery state detection

✔ Maximum trade count suggestions

✔ Recovery speed adjustment

✔ Reward-to-risk optimization

✔ Drawdown management framework

[b]## Educational Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

Nothing contained within this indicator, its calculations, suggestions, or displayed recovery plans should be considered financial advice, investment advice, trading advice, or a recommendation to buy or sell any financial instrument.

Trading futures, stocks, options, forex, cryptocurrencies, and other financial products involves substantial risk and may result in significant losses, including the loss of your entire account balance.

Past performance does not guarantee future results.

All trading decisions are made solely at your own discretion and risk. You are responsible for evaluating your own financial situation, risk tolerance, and trading objectives before placing any trade.

The creator of this indicator assumes no responsibility for any trading losses, missed opportunities, or financial damages resulting from the use of this tool.

## Source Code

````pine
//@version=6
indicator("XRS Prop Drawdown Recovery Dashboard", shorttitle="XRS DD Recovery", overlay=true)

//────────────────────────────────────────
// Inputs
//────────────────────────────────────────
groupAccount = "Account Settings"

accountPreset = input.string(
     "$50,000",
     "Account Size",
     options=["$25,000", "$50,000", "$100,000", "$150,000"],
     group=groupAccount
)

drawdownPreset = input.string(
     "$2,000",
     "Total Drawdown Size",
     options=["$1,000", "$1,250", "$1,500", "$2,000", "$2,500", "$3,000", "$4,500", "$5,000"],
     group=groupAccount
)

remainingDrawdown = input.float(500, "Drawdown Remaining", minval=0, step=50, group=groupAccount)

groupInstrument = "Instrument Settings"

pointValuePerMicro = input.float(2.00, "Point Value Per Micro / Contract", minval=0.01, step=0.25, group=groupInstrument)
maxAllowedMicros = input.int(10, "Max Allowed Micros / Contracts", minval=1, maxval=100, group=groupInstrument)
minAllowedMicros = input.int(1, "Minimum Micros / Contracts", minval=1, maxval=100, group=groupInstrument)

groupRisk = "Recovery Engine"

recoverySpeed = input.string("Balanced", "Recovery Speed", options=["Conservative", "Balanced", "Aggressive"], group=groupRisk)

defaultStopPts = input.float(20, "Preferred Stop Loss Points", minval=1, step=1, group=groupRisk)
allowStopAdjustment = input.bool(true, "Allow Engine To Adjust Stop Size", group=groupRisk)

minStopPts = input.float(8, "Minimum Stop Points", minval=1, step=1, group=groupRisk)
maxStopPts = input.float(40, "Maximum Stop Points", minval=1, step=1, group=groupRisk)

groupDisplay = "Dashboard Display"

showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDisplay)
dashboardSize = input.string("Compact", "Dashboard Size", options=["Compact", "Large"], group=groupDisplay)

//────────────────────────────────────────
// Account / Drawdown Values
//────────────────────────────────────────
accountSize =
     accountPreset == "$25,000"  ? 25000 :
     accountPreset == "$50,000"  ? 50000 :
     accountPreset == "$100,000" ? 100000 :
     150000

totalDrawdown =
     drawdownPreset == "$1,000" ? 1000 :
     drawdownPreset == "$1,250" ? 1250 :
     drawdownPreset == "$1,500" ? 1500 :
     drawdownPreset == "$2,000" ? 2000 :
     drawdownPreset == "$2,500" ? 2500 :
     drawdownPreset == "$3,000" ? 3000 :
     drawdownPreset == "$4,500" ? 4500 :
     5000

usedDrawdown = math.max(totalDrawdown - remainingDrawdown, 0)
remainingPct = totalDrawdown > 0 ? remainingDrawdown / totalDrawdown * 100 : na
recoveryNeeded = usedDrawdown

//────────────────────────────────────────
// Dynamic Recovery State
//────────────────────────────────────────
recoveryState =
     remainingPct <= 20 ? "SURVIVAL" :
     remainingPct <= 35 ? "CRITICAL" :
     remainingPct <= 60 ? "DEFENSIVE" :
     remainingPct <= 85 ? "CONTROLLED" :
     "NORMAL"

stateColor =
     recoveryState == "SURVIVAL"   ? color.rgb(200, 80, 255) :
     recoveryState == "CRITICAL"   ? color.rgb(255, 60, 60) :
     recoveryState == "DEFENSIVE"  ? color.rgb(255, 160, 0) :
     recoveryState == "CONTROLLED" ? color.rgb(80, 170, 255) :
     color.rgb(80, 220, 120)

//────────────────────────────────────────
// Recovery Engine
//────────────────────────────────────────
baseRiskPct =
     recoveryState == "SURVIVAL"   ? 6.0 :
     recoveryState == "CRITICAL"   ? 10.0 :
     recoveryState == "DEFENSIVE"  ? 12.0 :
     recoveryState == "CONTROLLED" ? 15.0 :
     18.0

baseDailyRiskPct =
     recoveryState == "SURVIVAL"   ? 8.0 :
     recoveryState == "CRITICAL"   ? 16.0 :
     recoveryState == "DEFENSIVE"  ? 24.0 :
     recoveryState == "CONTROLLED" ? 30.0 :
     36.0

baseRR =
     recoveryState == "SURVIVAL"   ? 4.0 :
     recoveryState == "CRITICAL"   ? 3.0 :
     recoveryState == "DEFENSIVE"  ? 2.75 :
     recoveryState == "CONTROLLED" ? 2.5 :
     2.0

baseMaxTrades =
     recoveryState == "SURVIVAL"   ? 1 :
     recoveryState == "CRITICAL"   ? 1 :
     recoveryState == "DEFENSIVE"  ? 2 :
     recoveryState == "CONTROLLED" ? 3 :
     4

baseMaxLosses =
     recoveryState == "SURVIVAL"   ? 1 :
     recoveryState == "CRITICAL"   ? 1 :
     recoveryState == "DEFENSIVE"  ? 1 :
     recoveryState == "CONTROLLED" ? 2 :
     2

baseWinGoal =
     recoveryState == "SURVIVAL"   ? 1 :
     recoveryState == "CRITICAL"   ? 1 :
     recoveryState == "DEFENSIVE"  ? 1 :
     recoveryState == "CONTROLLED" ? 2 :
     2

speedRiskMultiplier =
     recoverySpeed == "Conservative" ? 0.75 :
     recoverySpeed == "Aggressive" ? 1.25 :
     1.0

speedTradeAdjustment =
     recoverySpeed == "Conservative" ? -1 :
     recoverySpeed == "Aggressive" ? 1 :
     0

riskPct = baseRiskPct * speedRiskMultiplier
dailyRiskPct = baseDailyRiskPct * speedRiskMultiplier
rrTarget = baseRR

maxTrades = math.max(1, baseMaxTrades + speedTradeAdjustment)
maxLosses = baseMaxLosses
winGoal = baseWinGoal

riskDollarsRaw = remainingDrawdown * (riskPct / 100)
dailyRiskCap = remainingDrawdown * (dailyRiskPct / 100)
riskDollars = math.min(riskDollarsRaw, dailyRiskCap)

rawMicrosAtDefaultStop = defaultStopPts > 0 and pointValuePerMicro > 0 ? riskDollars / (defaultStopPts * pointValuePerMicro) : 0
suggestedMicrosRaw = math.floor(rawMicrosAtDefaultStop)
suggestedMicrosClamped = math.max(minAllowedMicros, math.min(maxAllowedMicros, suggestedMicrosRaw))

needsSmallerStop = suggestedMicrosRaw < minAllowedMicros
adjustedStopForMinSize = minAllowedMicros > 0 and pointValuePerMicro > 0 ? riskDollars / (minAllowedMicros * pointValuePerMicro) : defaultStopPts

engineStopPts =
     allowStopAdjustment and needsSmallerStop ? math.max(minStopPts, math.min(maxStopPts, adjustedStopForMinSize)) :
     defaultStopPts

suggestedMicros = math.max(minAllowedMicros, math.min(maxAllowedMicros, math.floor(riskDollars / (engineStopPts * pointValuePerMicro))))

actualRisk = suggestedMicros * engineStopPts * pointValuePerMicro
takeProfitPts = engineStopPts * rrTarget
targetProfit = suggestedMicros * takeProfitPts * pointValuePerMicro
maxDailyLoss = math.min(dailyRiskCap, actualRisk * maxLosses)
dailyRecoveryTarget = targetProfit * winGoal

riskWarning =
     actualRisk > riskDollars * 1.2 ? "Size/stop exceeds ideal risk." :
     "Risk within plan."

stopRule =
     recoveryState == "SURVIVAL" ? "1 trade max. Stop after 1 win or 1 loss." :
     recoveryState == "CRITICAL" ? "Stop after 1 loss or 1 clean win." :
     recoveryState == "DEFENSIVE" ? "Stop after 1 loss or 1 clean win." :
     recoveryState == "CONTROLLED" ? "Stop after 2 losses or 2 wins." :
     "Stop after 2 losses, 2 wins, or max trades."

planNote =
     recoveryState == "SURVIVAL" ? "Deep DD. Smallest size. A+ setup only." :
     recoveryState == "CRITICAL" ? "Only A+ setups. No scaling. No revenge trades." :
     recoveryState == "DEFENSIVE" ? "Trade small. Require clean confirmation." :
     recoveryState == "CONTROLLED" ? "Controlled recovery. Avoid overtrading." :
     "Normal recovery. Stay disciplined."

//────────────────────────────────────────
// Helpers
//────────────────────────────────────────
f_money(float value) =>
    "$" + str.tostring(value, "#,###.##")

f_num(float value) =>
    str.tostring(value, "#.##")

f_position(string pos) =>
    pos == "Top Right" ? position.top_right :
     pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

txtSize = dashboardSize == "Compact" ? size.small : size.normal

//────────────────────────────────────────
// Dashboard
//────────────────────────────────────────
var table dash = table.new(f_position(dashboardPosition), 2, 17, border_width=1)

bgHeader = color.rgb(8, 12, 20)
bgRow = color.rgb(14, 20, 30)
bgAlt = color.rgb(18, 26, 38)
txtWhite = color.white
txtMuted = color.rgb(180, 190, 205)
warnColor = color.rgb(255, 215, 100)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "XRS DD RECOVERY", text_color=txtWhite, bgcolor=bgHeader, text_size=txtSize)
    table.cell(dash, 1, 0, recoveryState, text_color=color.white, bgcolor=stateColor, text_size=txtSize)

    table.cell(dash, 0, 1, "Account", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 1, f_money(accountSize), text_color=txtWhite, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 2, "Total DD", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 2, f_money(totalDrawdown), text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 3, "DD Left", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 3, f_money(remainingDrawdown) + " / " + f_num(remainingPct) + "%", text_color=stateColor, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 4, "Recover Need", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 4, f_money(recoveryNeeded), text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 5, "Speed", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 5, recoverySpeed, text_color=txtWhite, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 6, "Risk / Trade", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 6, f_money(actualRisk) + " / " + f_num(riskPct) + "%", text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 7, "Trade Size", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 7, str.tostring(suggestedMicros) + " micros", text_color=txtWhite, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 8, "Stop Loss", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 8, f_num(engineStopPts) + " pts", text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 9, "Take Profit", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 9, f_num(takeProfitPts) + " pts / " + f_money(targetProfit), text_color=txtWhite, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 10, "R:R", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 10, str.tostring(rrTarget, "#.##") + ":1", text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 11, "Max Trades", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 11, str.tostring(maxTrades), text_color=txtWhite, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 12, "Max Losses", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 12, str.tostring(maxLosses), text_color=warnColor, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 13, "Win Goal", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 13, str.tostring(winGoal) + " win(s)", text_color=stateColor, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 14, "Max Daily Loss", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 14, f_money(maxDailyLoss), text_color=warnColor, bgcolor=bgAlt, text_size=txtSize)

    table.cell(dash, 0, 15, "Daily Target", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(dash, 1, 15, f_money(dailyRecoveryTarget), text_color=stateColor, bgcolor=bgRow, text_size=txtSize)

    table.cell(dash, 0, 16, "Rule", text_color=txtMuted, bgcolor=bgAlt, text_size=txtSize)
    table.cell(dash, 1, 16, stopRule, text_color=txtWhite, bgcolor=bgAlt, text_size=txtSize)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 16)
````
