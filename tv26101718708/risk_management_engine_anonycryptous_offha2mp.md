# Risk Management Engine | Anonycryptous

- url: https://www.tradingview.com/script/ofFha2Mp-Risk-Management-Engine-Anonycryptous/
- type: indicator
- pine_id: PUB;1246c18302024092806afff02b2122d6
- version: 1.0

## Description

Risk management engine | Anonycryptous
Description & user manual

Important notice — read first.

Why is this indicator different?
Most indicators in this collection focus on reading the market — structure, momentum, sessions, entries. 
That was the moment I thought of an indicator, one that protects you and gives you the opportunity to train your discipline.
It was also supposed to be a free indicator; too many people trading aimlessly and soullessly due to the many losses or are victims of so-called gurus.
As said, most risk managers looking at many things, but not at the most important one, the Trader himself.
Risk management engine does none of that. It does not look at price at all. 
It looks only at you, at every input you do, and as soon as you make a mistake or reach your limit, it holds up a mirror to you.
Where other indicators help you find trades, Risk management engine exists to make sure the trades you find do not destroy the account you are trading with. It is the only tool in this collection that is entirely about the trader rather than the market. That makes it, in many ways, the most important one.

You can be right about the market and still blow your account. Risk management engine is the system that prevents that — but only if you use it honestly.

* Note: Risk management engine does not generate trading signals.
- It does not tell you when to buy or sell.
- It does not predict market direction.
- It does not replace your trading strategy or technical analysis.

-What it does
You simply trade using your own strategy/technical analysis, and you use the Risk Management Engine for account management.
The indicator shows you potential entry, stop-loss, and 3 targets.
If your own strategy says entry, the Risk Management Engine shows you the number of max contracts, and especially your stop-loss and potential targets, based on your entered account details.

-What it does more: it holds up a mirror.
Every number on the dashboard is a reflection of your own decisions — your stop placement, your risk tier, your trade results, your discipline. The system tracks what you tell it. It enforces nothing automatically. It stops nothing by force.
This means one thing matters above all else: your honesty with yourself.

It is easy to disable the lockout when the chart goes red. It is easy to skip logging a trade you are not proud of. It is easy to set your tier to full when you should be at half. It is easy to pretend a violation did not happen.
The moment you start deceiving the system, you are not deceiving the indicator. You are deceiving yourself. And the market will make sure you pay for that eventually.

Risk management engine is a tool for traders who are ready to be accountable — not for traders looking for a way around their own rules.
Use it in honestly.
Use it with discipline.

1. Overview
Risk management engine is a real-time risk compliance and position sizing dashboard for traders of all styles and instruments — from futures scalpers on funded accounts to retail forex traders managing their own capital.
The core philosophy is straightforward: before you enter a trade, you should know exactly how much you are risking, how many contracts you are allowed to trade, where your stop is, and where your targets are. After you close a trade, you log the result. The system tracks your session progress, warns you when you are approaching limits, and locks the chart when you have reached them.
Everything is manual. Everything is intentional. Manual logging forces conscious decisions. Conscious decisions build the habit of accountability that separates disciplined traders from impulsive ones.

2. Who this is for
- Prop firm traders tracking daily drawdown limits
- Funded account traders using tiered risk rules
- Retail traders who want a personal risk framework
- Scalpers who need position size calculated instantly
- Any trader who wants structure-based stops
- Anyone who needs visual accountability on their chart
- Traders recovering from a drawdown period
- Traders building consistency through disciplined journaling

This indicator is for traders who understand that risk management is not a constraint on profitability — it is the foundation of it.

3. Core concepts
3.1 The tiered risk system
Risk management engine uses a three-tier risk framework that reflects your performance state during a session. You set your tier manually based on your results. The system then calculates your allowed position size for that tier.
Full — 100% of calculated risk per trade.
Use at the start of a clean session. No deficit carried over. No losses taken yet today.
Half — 50% of calculated risk per trade.
Use after your first losing trade. You are still in the session but at reduced size. Protect the drawdown.
Quarter — 25% of calculated risk per trade.
Use after a second loss or after a rule violation. Minimum exposure. Your only goal is to stop the bleeding and potentially work back toward promotion.
The tier does not change automatically. You change it. That is by design. The moment of demotion is a conscious act of discipline — not something that happens to you, but something you choose to do because you respect the rules.

3.2 Position sizing
Before every trade, risk engine calculates exactly how many contracts you are allowed to trade based on:
- Your daily loss limit
- Your max risk percentage per trade
- Your current risk tier
- Your stop distance in ticks
- Your tick value
The formula is:
Risk amount = daily loss limit × max risk % × tier multiplier
Contracts = floor(risk amount / (stop distance in ticks × tick value))
Example (mnq):
Daily loss limit: $500
Max risk %: 2%
Tier: full (1.0×)
Stop distance: 20 ticks
Tick value: $0.50
Risk amount = $500 × 2% × 1.0 = $10.00
Contracts = floor($10.00 / (20 × $0.50)) = floor($10.00 / $10.00) = 1
You are allowed 1 mnq contract on this setup.

3.3 Structure-based stops
Instead of placing stops at arbitrary price levels based on fear or round numbers, Risk management engine calculates stops from recent pivot structure:

- Long setup: stop below the most recent pivot low plus buffer
- Short setup: stop above the most recent pivot high plus buffer
The buffer is measured in ticks and gives your trade breathing room beyond the exact pivot level. Stops that respect market structure are more meaningful than stops placed at random.
You can also disable the auto-pivot stop and enter a manual stop price if you prefer to set your own level.

3.4 Risk/reward visualization
Once your stop is set, three take profit levels are drawn on the chart automatically based on your risk distance:
- Tp1 = entry + (stop distance × rr1 ratio)
- Tp2 = entry + (stop distance × rr2 ratio)
- Tp3 = entry + (stop distance × rr3 ratio)
Default ratios: 1:1, 1:2, 1:3 — all adjustable.
A red risk zone box fills the area between entry and stop. A green reward zone box fills the area between entry and tp1. This gives you an immediate visual read on the asymmetry of your planned trade before you enter.
If the red box looks bigger than the green box — reconsider!

3.5 The carryover system
When you are demoted from one tier to a lower tier, you carry a deficit from that session into the next. You must earn back half of what you lost before you are eligible to promote back to a higher tier.
Example:
You lost 12 points at full tier.
You are demoted to half.
Your carryover deficit = 12 points.
Your promotion threshold = 12 / 2 = 6 points.
At half tier in the next session, you log your results.
The dashboard shows: 3.5 / 6.0
You still need 2.5 more points to promote back to full.
Quarter risk violation special case:
If you had a rule violation at quarter tier, an additional deficit is added on top of the standard carryover. You must dig out of a deeper hole — because violations carry consequences, not just losses.

3.6 Session lockout
The session ends and the chart is covered with a status overlay when any of the following occur:
- Daily target reached — green overlay, walk away with the win
- Maximum trades reached — red overlay, session over
- Maximum losses reached — red overlay, session over
- Rule violation logged — red overlay, immediate lockout
The lockout can be disabled in settings. There is a tooltip that reads: "Disable at your own peril."
That is not a joke. The lockout exists for a reason. Traders who disable it and continue trading after a lockout trigger are making a choice that the system cannot protect them from. Only their own discipline can.

4. Understanding result units
Risk management engine supports four result units to match how you measure your own performance:
Points — price distance between entry and exit. Common for futures traders.
Ticks — smallest price increment. One point equals the number of ticks per point for your instrument.
Dollar — direct monetary result. Works for any instrument.
Percent — result as a percentage of your account or reference value.
Choose the unit that matches how you think about your trades. Consistency matters more than which unit you pick. Do not switch mid-session.
For mnq, points is the most natural unit. For crypto or equity traders, dollar is usually clearer.

5. Settings overview
Account & risk
- Daily loss limit
- Max risk per trade (%)
- Daily target
- Max trades per session
- Max losses per session
- Tick value
- Ticks per point

Risk tier
- Current tier (full / half / quarter)
- Carryover deficit
- Promotion threshold

Stop settings
- Auto-pivot stop on/off
- Pivot lookback
- Stop buffer (ticks)
- Manual stop price

Risk/reward
- Rr1, rr2, rr3 ratios
- Visual zone colors

Trade log
- Up to 10 trade slots
- Tier per trade
- Result per trade
- Violation flag

Result units
- Points / ticks / dollar / percent

Session lockout
- Enable/disable
- Overlay color

Dashboard
- Position
- Size

6. Dashboard reference
The dashboard updates in real time as you log trades.
Rows displayed:
- Risk tier — current tier
- Contracts — allowed contracts for this setup
- Risk amount — dollar risk for this trade
- Stop — calculated stop price
- Tp1 / tp2 / tp3 — take profit levels
- Session p&l — cumulative result this session
- Trades — trades logged / max trades
- Losses — losses logged / max losses
- Target — progress toward daily target
- Carryover — deficit / promotion threshold
- Status — active / target hit / locked
Header color reflects current session health: green for active and progressing, red for locked or in violation.

7. How to use
7.1 Before the session
1. Set your daily loss limit and daily target
2. Set your tick value and ticks per point for your instrument
3. Set your risk/reward ratios
4. Set your starting tier (usually full if no carryover)
5. Update carryover deficit if you are carrying one from a previous session
6. Clear all trade log slots from yesterday

7.2 Before each trade
1. Check the dashboard — confirm your tier and allowed contracts
2. Identify your stop level — either auto-pivot or manual
3. Read the rr visualization on the chart — entry, stop, tp levels
4. Confirm the asymmetry looks acceptable before entering

7.3 After each trade
1. Open indicator settings
2. Go to the trade log section
3. Find the next empty trade slot
4. Select the tier you actually used
5. Enter the result in your chosen unit — positive for a win, negative for a loss
6. Close settings — dashboard updates instantly
Do this every time. No exceptions. Not logging a trade because you do not like the result is the first step toward self-deception.

7.4 Mid-session adjustments
After a loss — manually change your tier to half.
After a second loss — change to quarter.
After a violation — log it as violation, accept the lockout.
The system recalculates allowed contracts and shows your new promotion threshold automatically.

7.5 Session end
When the session ends:
- Target hit: walk away. Do not give it back.
- Locked out by losses: walk away. Come back tomorrow.
- Violation: accept the consequence. Log it honestly.

Manual reset for next session:
1. Clear all trade log slots back to none / 0
2. Update carryover deficit if you are carrying one
3. Set your new starting tier
4. Adjust daily loss limit if needed for the new day

8. Tips & best practices
8.1 The most important rule
Log every trade. Immediately after it closes. Not later. Not after "one more trade." Right now.
The discipline of immediate logging is itself a trading skill. It keeps you present, accountable, and aware of exactly where you stand at all times.

8.2 Respect the tier system
The tier system only works if you apply it consistently.
If you take a loss and stay at full because "it was a good setup" or "the market was unusual today" — you are not using the system. You are using the system when it is convenient and ignoring it when it is not.
Apply the demotion every time, without exception. The whole point of the tier system is that it removes the emotional decision from the equation. Commit to the rules before the session starts, not in the middle of a losing run.

8.3 Do not move your sto
The contracts allowed calculation is based on your stop distance. If you move your stop wider to give the trade more room, your actual risk per trade increases beyond what the system calculated. You are now taking more risk than the dashboard shows.
If you want a wider stop — recalculate. Accept fewer contracts. Do not silently increase your exposure.

8.4 The lockout is there for a reason
When the chart goes red and the lockout appears, there is a setting that lets you disable it. Do not use it.
The lockout exists because the rules exist. If you have reached your maximum losses or maximum trades, continuing to trade means operating outside your rules — which means operating in a state where previous decisions have already shown your judgment is impaired for the day.
Come back tomorrow. The market will still be there.

8.5 Target hit means stop
When the dashboard shows target hit and the chart goes green — that is the signal to stop. Not to "go for one more." Not to "see if the trend continues."
Most traders who blow accounts do not do it on bad days. They do it on good days when they got overconfident after hitting their target and kept trading. Walk away with the win. That is a skill.

8.6 Setting realistic targets and limits
Your daily loss limit should be a number that, if lost, does not materially damage your account or your psychology.
Your daily target should be a number that is achievable on a normal day — not your best day ever. Consistent achievement of a realistic target builds an account faster than occasional achievement of an aggressive target.

A useful starting framework:
- Daily loss limit: 2–5% of account
- Max risk per trade: 1–2% of daily loss limit
- Daily target: 2–3× your average risk per trade
- Max trades: 3–5
- Max losses: 2–3

Adjust based on your instrument, style, and account size.

8.7 Instrument tick value setup
The single most common setup error is entering the wrong tick value. If your contracts allowed number seems too high or too low, check your tick value and ticks per point first.
- Mnq: tick value = $0.50, ticks per point = 4
- Es: tick value = $12.50, ticks per point = 4
- Crypto in dollar mode: set tick value to match your contract specification or use dollar result unit

9. What this indicator does not do
- Does not generate buy or sell signals
- Does not predict market direction
- Does not connect to your broker
- Does not automatically stop you from trading
- Does not track open positions in real time
- Does not replace your trading strategy
- Does not guarantee profitability
- Does not prevent violations — you must log them yourself
This is an accountability tool. The accountability only works if you bring the honesty. The indicator brings the structure. You bring the discipline.

10. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation.
All trading decisions are made entirely by the user. The indicator provides calculation tools based on user-entered parameters — the accuracy of any output depends entirely on the accuracy of those inputs.
Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using risk engine or any content in this manual.

## Source Code

````pine


// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Anonycryptous

//@version=6
indicator("Risk Managment Engine | Anonycryptous", shorttitle="RME", overlay=true, max_boxes_count=100, max_labels_count=100)


//══════════════════════════════════════════════════════════════════════════════
// GROUP CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
var string G_RISK = "════════ Risk Parameters ════════"
var string G_TIER = "════════ Risk Tier & Carryover ════════"
var string G_PLAN = "════════ Trade Planning & Stops ════════"
var string G_RR = "════════ RR Levels ════════"
var string G_LOG = "════════ Trade Log (Manual Entry) ════════"
var string G_VIS = "════════ Appearance ════════"

//══════════════════════════════════════════════════════════════════════════════
// BRAND COLORS
//══════════════════════════════════════════════════════════════════════════════
color BULL_COLOR = #00ff00
color BEAR_COLOR = #ff0000
color NEUT_COLOR = #808080
color GOLD_COLOR = #f5c518

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — RISK PARAMETERS
//══════════════════════════════════════════════════════════════════════════════
accountSize = input.float(50000.0, "Account Size ($)", group=G_RISK, minval=0.0, tooltip="Your total account or funded balance. Used for % based P&L conversion and risk calculations.")
availDrawdown = input.float(2500.0, "Daily Loss Limit ($)", group=G_RISK, minval=0.0, tooltip="Maximum dollar loss allowed today. For prop firms: your daily drawdown limit. For retail: your personal daily stop.")
maxRiskPerc = input.float(2.0, "Max Risk % Per Trade", group=G_RISK, minval=0.0, maxval=100.0, tooltip="Percentage of your daily loss limit you are willing to risk on a single trade.")
tickValue = input.float(1.25, "Tick Value ($)", group=G_RISK, minval=0.0, tooltip="Dollar value of one tick for your instrument.\n\nMNQ = $0.50\nNQ = $5.00\nMES = $1.25\nES = $12.50\nCrypto/Forex = check your broker spec.")
pointTicks = input.float(4.0, "Ticks Per Point", group=G_RISK, minval=1.0, tooltip="How many ticks make one point for your instrument.\n\nMNQ/NQ/MES/ES = 4 ticks per point\nCrypto = typically 1\nForex = depends on pip size\n\nUsed to convert between ticks and points.")
dailyTarget = input.float(25.0, "Daily Target", group=G_RISK, minval=0.0, tooltip="Your daily profit target. Unit matches your selected Result Unit in the Trade Log section.")
maxTradesInput = input.int(3, "Max Trades Per Session", group=G_RISK, minval=1, maxval=10, tooltip="Maximum number of trades allowed per session. Reaching this limit ends the session.")
maxLossesInput = input.int(2, "Max Losses Per Session", group=G_RISK, minval=1, maxval=5, tooltip="Maximum number of losing trades before session ends.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — RISK TIER & CARRYOVER
//══════════════════════════════════════════════════════════════════════════════
currentTier = input.string("FULL", "Current Risk Tier", group=G_TIER, options=["FULL","HALF","QUARTER"], tooltip="Your current risk tier for this session.\n\nFULL: 100% of calculated risk per trade.\nHALF: 50% — use after one loss.\nQUARTER: 25% — use after two losses or a violation.\n\nSet this manually at session start.")
carryoverDeficit = input.float(0.0, "Carryover Deficit", group=G_TIER, minval=0.0, tooltip="Result lost at your previous tier that you need to earn back before promoting. Promotion threshold = half of this value. Use the same unit as your Result Unit.")
quarterViolation = input.bool(false, "Quarter Risk Violation Active", group=G_TIER, tooltip="Check this if your previous demotion included a rule violation at Quarter tier. Adds extra deficit on top of standard carryover.")
quarterExtraDeficit = input.float(0.0, "Quarter Violation Extra Deficit", group=G_TIER, minval=0.0, tooltip="Additional deficit to work off if a violation occurred at Quarter tier.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — TRADE PLANNING & STOPS
//══════════════════════════════════════════════════════════════════════════════
tradeDir = input.string("Long", "Trade Direction", group=G_PLAN, options=["Long","Short"], tooltip="Direction of your planned trade. Determines which pivot is used for stop calculation.")
autoStop = input.bool(true, "Enable Auto-Pivot Stop", group=G_PLAN, tooltip="When on: stop is calculated automatically from the most recent pivot high or low plus your buffer.\nWhen off: use the manual stop price below.")
pivotLeft = input.int(3, "Pivot Left Bars", group=G_PLAN, minval=1, tooltip="Bars to the left required for pivot confirmation. Higher = stronger pivots, more lag.")
pivotRight = input.int(3, "Pivot Right Bars", group=G_PLAN, minval=1, tooltip="Bars to the right required for pivot confirmation.")
stopBuffer = input.float(4.0, "Stop Buffer (Ticks)", group=G_PLAN, minval=0.0, tooltip="Additional ticks beyond the pivot level for your stop. Gives breathing room beyond the exact pivot.")
manualStop = input.float(0.0, "Manual Stop Price", group=G_PLAN, minval=0.0, tooltip="Only used when Auto-Pivot Stop is disabled. Enter your exact stop price here.")
showPivotLabels = input.bool(false, "Show Pivot Labels", group=G_PLAN, tooltip="Shows H/L labels at detected pivot highs and lows.")
col_bullStop = input.color(#ff0000, "Long Stop Color", group=G_PLAN)
col_bearStop = input.color(#ff0000, "Short Stop Color", group=G_PLAN)
stopLineWidth = input.int(1, "Stop Line Width", group=G_PLAN, minval=1, maxval=4)
stopLineStyle = input.string("Solid","Stop Line Style", group=G_PLAN, options=["Solid","Dashed","Dotted"])

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — RR LEVELS
//══════════════════════════════════════════════════════════════════════════════
showRRLevels = input.bool(true, "Show RR Levels", group=G_RR, tooltip="Draws entry, stop, TP1, TP2 and TP3 lines on the chart based on your stop distance from the current close.")
showEntryLine = input.bool(true, "Show Entry Line", group=G_RR, tooltip="Draws a line at the current close — your planned entry price.")
col_entry = input.color(#ffffff, "Entry Line Color", group=G_RR)
entryLineWidth = input.int(1, "Entry Line Width", group=G_RR, minval=1, maxval=4)

showTP1 = input.bool(true, "Show TP1", group=G_RR, inline="tp1", tooltip="First take profit level.")
rr1 = input.float(1.0, "RR", group=G_RR, inline="tp1", minval=0.1, step=0.5)
col_tp1 = input.color(color.rgb(0,200,100), "", group=G_RR, inline="tp1")
tp1Width = input.int(1, "", group=G_RR, inline="tp1", minval=1, maxval=4)

showTP2 = input.bool(true, "Show TP2", group=G_RR, inline="tp2", tooltip="Second take profit level.")
rr2 = input.float(2.0, "RR", group=G_RR, inline="tp2", minval=0.1, step=0.5)
col_tp2 = input.color(color.rgb(0,230,80), "", group=G_RR, inline="tp2")
tp2Width = input.int(1, "", group=G_RR, inline="tp2", minval=1, maxval=4)

showTP3 = input.bool(true, "Show TP3", group=G_RR, inline="tp3", tooltip="Third take profit level.")
rr3 = input.float(3.0, "RR", group=G_RR, inline="tp3", minval=0.1, step=0.5)
col_tp3 = input.color(color.rgb(0,255,0), "", group=G_RR, inline="tp3")
tp3Width = input.int(2, "", group=G_RR, inline="tp3", minval=1, maxval=4)

showRiskZone = input.bool(true, "Show Risk Zone (Entry→Stop)", group=G_RR, tooltip="Fills the area between entry and stop with a subtle red background — your risk zone.")
showRewardZone = input.bool(true, "Show Reward Zone (Entry→TP1)", group=G_RR, tooltip="Fills the area between entry and TP1 with a subtle green background — your reward zone.")
rrLabelSize = input.string("Small", "RR Label Size", group=G_RR, options=["Tiny","Small","Normal"])
rrLineExtend = input.int(20, "Line Extend (bars right)", group=G_RR, minval=1, maxval=100, tooltip="How many bars to the right the RR lines extend.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — TRADE LOG
//══════════════════════════════════════════════════════════════════════════════
resultUnit = input.string("Points", "Result Unit", group=G_LOG,
     options=["Points","Ticks","Dollar","Percent"],
     tooltip="How you want to log your trade results.\n\nPoints: Enter points won/lost (futures standard). Example: win 8 points → 8\n\nTicks: Enter ticks won/lost. System converts to points automatically using Ticks Per Point. Example: win 32 ticks → 32\n\nDollar: Enter dollar P&L directly. Most universal. Example: win $400 → 400, lose $250 → -250\n\nPercent: Enter result as % of account size. Example: win 0.8% → 0.8, lose 0.4% → -0.4\n\nAll units are converted internally to a common value for dashboard calculations.")

t1_tier = input.string("None", "Trade 1", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t1", tooltip="Tier used + result for this trade. Enter result in your chosen Result Unit above.")
t1_res = input.float(0.0, "", group=G_LOG, inline="t1")
t2_tier = input.string("None", "Trade 2", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t2")
t2_res = input.float(0.0, "", group=G_LOG, inline="t2")
t3_tier = input.string("None", "Trade 3", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t3")
t3_res = input.float(0.0, "", group=G_LOG, inline="t3")
t4_tier = input.string("None", "Trade 4", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t4")
t4_res = input.float(0.0, "", group=G_LOG, inline="t4")
t5_tier = input.string("None", "Trade 5", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t5")
t5_res = input.float(0.0, "", group=G_LOG, inline="t5")
t6_tier = input.string("None", "Trade 6", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t6")
t6_res = input.float(0.0, "", group=G_LOG, inline="t6")
t7_tier = input.string("None", "Trade 7", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t7")
t7_res = input.float(0.0, "", group=G_LOG, inline="t7")
t8_tier = input.string("None", "Trade 8", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t8")
t8_res = input.float(0.0, "", group=G_LOG, inline="t8")
t9_tier = input.string("None", "Trade 9", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t9")
t9_res = input.float(0.0, "", group=G_LOG, inline="t9")
t10_tier = input.string("None", "Trade 10", group=G_LOG, options=["None","FULL","HALF","QUARTER","Violation"], inline="t10")
t10_res = input.float(0.0, "", group=G_LOG, inline="t10")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — APPEARANCE
//══════════════════════════════════════════════════════════════════════════════
dashPos = input.string("Bottom Right", "Dashboard Position", group=G_VIS, options=["Top Right","Top Left","Bottom Right","Bottom Left"])
dashSize = input.string("Tiny", "Dashboard Size", group=G_VIS, options=["Tiny","Small","Normal"])
showLockout = input.bool(true, "Show Chart Lockout When Session Ends", group=G_VIS, tooltip="Covers the chart with a colored overlay and giant status label when the session is over. Disable at your own peril.")

//══════════════════════════════════════════════════════════════════════════════
// UNIT CONVERSION
//══════════════════════════════════════════════════════════════════════════════
// Convert any result unit to a common internal value (points equivalent)
// Points → use as-is
// Ticks → divide by ticks per point
// Dollar → divide by (tick value × ticks per point) = point value
// Percent → multiply by account size / 100, then divide by point value

pointValue = tickValue * pointTicks // dollar value of 1 point

f_toPoints(float raw) => resultUnit == "Points" ? raw : resultUnit == "Ticks" ? raw / pointTicks : resultUnit == "Dollar" ? raw / pointValue : resultUnit == "Percent" ? (raw / 100.0 * accountSize) / pointValue : raw

unitLabel = resultUnit == "Points" ? "pts" : resultUnit == "Ticks" ? "ticks" : resultUnit == "Dollar" ? "$" : "%"


//══════════════════════════════════════════════════════════════════════════════
// PIVOT DETECTION
//══════════════════════════════════════════════════════════════════════════════
pivHigh = ta.pivothigh(pivotLeft, pivotRight)
pivLow = ta.pivotlow(pivotLeft, pivotRight)

var float lastPivH = na
var float lastPivL = na

if not na(pivHigh)
    lastPivH := pivHigh
if not na(pivLow)
    lastPivL := pivLow

if showPivotLabels
    if not na(pivHigh)
        label.new(bar_index - pivotRight, pivHigh, "H", style=label.style_label_down, color=color.new(BEAR_COLOR,70), textcolor=BEAR_COLOR, size=size.tiny)
    if not na(pivLow)
        label.new(bar_index - pivotRight, pivLow, "L", style=label.style_label_up, color=color.new(BULL_COLOR,70), textcolor=BULL_COLOR, size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// STOP CALCULATION
//══════════════════════════════════════════════════════════════════════════════
bufferPrice = stopBuffer * syminfo.mintick
stopPrice = autoStop ? (tradeDir == "Long" ? lastPivL - bufferPrice : lastPivH + bufferPrice) : manualStop
stopDistTicks = stopPrice != 0 ? math.abs(close - stopPrice) / syminfo.mintick : 0.0
stopValid = stopPrice != 0 and stopDistTicks > 0

//══════════════════════════════════════════════════════════════════════════════
// RR LEVEL CALCULATION
//══════════════════════════════════════════════════════════════════════════════
entryPrice = close
stopDist = math.abs(entryPrice - stopPrice)
rrDir = tradeDir == "Long" ? 1 : -1

tp1Price = entryPrice + rrDir * stopDist * rr1
tp2Price = entryPrice + rrDir * stopDist * rr2
tp3Price = entryPrice + rrDir * stopDist * rr3

//══════════════════════════════════════════════════════════════════════════════
// TRADE LOG PROCESSING
//══════════════════════════════════════════════════════════════════════════════
f_process(string tier, float raw, int trades, int losses, float total, bool viol) =>
    int t2 = trades
    int l2 = losses
    float r2 = total
    bool v2 = viol
    if tier != "None"
        pts = f_toPoints(raw)
        t2 := trades + 1
        r2 := total + pts
        l2 := losses + (pts < 0 ? 1 : 0)
        v2 := viol or (tier == "Violation")
    [t2, l2, r2, v2]

[t1t, t1l, t1r, t1v] = f_process(t1_tier, t1_res, 0, 0, 0.0, false)
[t2t, t2l, t2r, t2v] = f_process(t2_tier, t2_res, t1t, t1l, t1r, t1v)
[t3t, t3l, t3r, t3v] = f_process(t3_tier, t3_res, t2t, t2l, t2r, t2v)
[t4t, t4l, t4r, t4v] = f_process(t4_tier, t4_res, t3t, t3l, t3r, t3v)
[t5t, t5l, t5r, t5v] = f_process(t5_tier, t5_res, t4t, t4l, t4r, t4v)
[t6t, t6l, t6r, t6v] = f_process(t6_tier, t6_res, t5t, t5l, t5r, t5v)
[t7t, t7l, t7r, t7v] = f_process(t7_tier, t7_res, t6t, t6l, t6r, t6v)
[t8t, t8l, t8r, t8v] = f_process(t8_tier, t8_res, t7t, t7l, t7r, t7v)
[t9t, t9l, t9r, t9v] = f_process(t9_tier, t9_res, t8t, t8l, t8r, t8v)
[t10t, t10l, t10r, t10v] = f_process(t10_tier, t10_res, t9t, t9l, t9r, t9v)

tradesTaken = t10t
lossCount = t10l
totalPts = t10r
hasViolation = t10v

// Convert total back to display unit for dashboard
totalDisplay = resultUnit == "Points" ? totalPts :
               resultUnit == "Ticks" ? totalPts * pointTicks :
               resultUnit == "Dollar" ? totalPts * pointValue :
               resultUnit == "Percent" ? totalPts * pointValue / accountSize * 100 : totalPts

// Dollar equivalent always for loss limit tracking
totalDollar = totalPts * pointValue

//══════════════════════════════════════════════════════════════════════════════
// RISK & POSITION SIZING
//══════════════════════════════════════════════════════════════════════════════
tierMult = currentTier == "FULL" ? 1.0 : currentTier == "HALF" ? 0.5 : 0.25
riskAmount = (availDrawdown * maxRiskPerc / 100.0) * tierMult
contractsAllowed = stopValid ? math.floor(riskAmount / (stopDistTicks * tickValue)) : 0

//══════════════════════════════════════════════════════════════════════════════
// WINRATE
//══════════════════════════════════════════════════════════════════════════════
winCount = tradesTaken - lossCount
winRate = tradesTaken > 0 ? winCount / tradesTaken * 100 : 0.0

//══════════════════════════════════════════════════════════════════════════════
// PROMOTION THRESHOLD
//══════════════════════════════════════════════════════════════════════════════
baseThreshold = carryoverDeficit / 2.0
extraThreshold = quarterViolation ? quarterExtraDeficit / 2.0 : 0.0
totalThreshold = baseThreshold + extraThreshold
promotionMet = totalThreshold > 0 and totalPts >= totalThreshold

//══════════════════════════════════════════════════════════════════════════════
// SESSION STATUS
//══════════════════════════════════════════════════════════════════════════════
targetHit = totalPts >= f_toPoints(dailyTarget)
maxTradesReached = tradesTaken >= maxTradesInput
maxLossesReached = lossCount >= maxLossesInput
sessionOver = targetHit or maxTradesReached or maxLossesReached or hasViolation

statusText =
     targetHit ? "🌟 TARGET HIT 🌟" :
     hasViolation ? "❌ RULE VIOLATION ❌" :
     maxTradesReached or maxLossesReached ? "❌ OUT OF SESSION ❌" : "● IN SESSION"

statusColor =
     targetHit ? BULL_COLOR :
     sessionOver ? BEAR_COLOR : BULL_COLOR

//══════════════════════════════════════════════════════════════════════════════
// STOP / ENTRY / TP LINES
//══════════════════════════════════════════════════════════════════════════════
f_lineStyle(simple string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

var line stopLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label stopLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var box riskBox = na
var box rewBox = na

rrLblSz = rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small
stopStyle = f_lineStyle(stopLineStyle)
stopCol = tradeDir == "Long" ? col_bullStop : col_bearStop

if showRRLevels and stopValid and not sessionOver and barstate.islast
    extRight = bar_index + rrLineExtend

    // Delete old
    if not na(stopLine) 
        line.delete(stopLine)
    if not na(entryLine) 
        line.delete(entryLine)
    if not na(tp1Line) 
        line.delete(tp1Line)
    if not na(tp2Line) 
        line.delete(tp2Line)
    if not na(tp3Line) 
        line.delete(tp3Line)
    if not na(stopLbl) 
        label.delete(stopLbl)
    if not na(entryLbl) 
        label.delete(entryLbl)
    if not na(tp1Lbl) 
        label.delete(tp1Lbl)
    if not na(tp2Lbl) 
        label.delete(tp2Lbl)
    if not na(tp3Lbl) 
        label.delete(tp3Lbl)
    if not na(riskBox) 
        box.delete(riskBox)
    if not na(rewBox) 
        box.delete(rewBox)

    // Stop line
    stopLine := line.new(bar_index, stopPrice, extRight, stopPrice,
         color=stopCol, width=stopLineWidth, style=stopStyle)
    stopLbl := label.new(extRight, stopPrice, "STOP — " + str.tostring(stopPrice, format.mintick),
         style=label.style_label_left, color=color.new(stopCol, 80),
         textcolor=stopCol, size=rrLblSz)

    // Entry line
    if showEntryLine
        entryLine := line.new(bar_index, entryPrice, extRight, entryPrice,
             color=col_entry, width=entryLineWidth, style=line.style_solid)
        entryLbl := label.new(extRight, entryPrice, "ENTRY — " + str.tostring(entryPrice, format.mintick),
             style=label.style_label_left, color=color.new(col_entry, 80),
             textcolor=col_entry, size=rrLblSz)

    // TP lines
    if showTP1
        tp1Line := line.new(bar_index, tp1Price, extRight, tp1Price,
             color=col_tp1, width=tp1Width, style=line.style_solid)
        tp1Lbl := label.new(extRight, tp1Price, "TP1 " + str.tostring(rr1, "#.#") + "R — " + str.tostring(tp1Price, format.mintick),
             style=label.style_label_left, color=color.new(col_tp1, 80),
             textcolor=col_tp1, size=rrLblSz)

    if showTP2
        tp2Line := line.new(bar_index, tp2Price, extRight, tp2Price,
             color=col_tp2, width=tp2Width, style=line.style_solid)
        tp2Lbl := label.new(extRight, tp2Price, "TP2 " + str.tostring(rr2, "#.#") + "R — " + str.tostring(tp2Price, format.mintick),
             style=label.style_label_left, color=color.new(col_tp2, 80),
             textcolor=col_tp2, size=rrLblSz)

    if showTP3
        tp3Line := line.new(bar_index, tp3Price, extRight, tp3Price,
             color=col_tp3, width=tp3Width, style=line.style_solid)
        tp3Lbl := label.new(extRight, tp3Price, "TP3 " + str.tostring(rr3, "#.#") + "R — " + str.tostring(tp3Price, format.mintick),
             style=label.style_label_left, color=color.new(col_tp3, 80),
             textcolor=col_tp3, size=rrLblSz)

    // Risk zone box (entry → stop)
    if showRiskZone
        riskTop = math.max(entryPrice, stopPrice)
        riskBot = math.min(entryPrice, stopPrice)
        riskBox := box.new(bar_index, riskTop, extRight, riskBot,
             bgcolor=color.new(BEAR_COLOR, 88), border_color=color.new(BEAR_COLOR, 80), border_width=1)

    // Reward zone box (entry → TP1)
    if showRewardZone and showTP1
        rewTop = math.max(entryPrice, tp1Price)
        rewBot = math.min(entryPrice, tp1Price)
        rewBox := box.new(bar_index, rewTop, extRight, rewBot,
             bgcolor=color.new(BULL_COLOR, 88), border_color=color.new(BULL_COLOR, 80), border_width=1)

else if not (showRRLevels and stopValid and not sessionOver)
    if not na(stopLine) 
        line.delete(stopLine) 
        stopLine := na
    if not na(entryLine) 
        line.delete(entryLine) 
        entryLine := na
    if not na(tp1Line) 
        line.delete(tp1Line) 
        tp1Line := na
    if not na(tp2Line) 
        line.delete(tp2Line) 
        tp2Line := na
    if not na(tp3Line) 
        line.delete(tp3Line) 
        tp3Line := na
    if not na(stopLbl) 
        label.delete(stopLbl) 
        stopLbl := na
    if not na(entryLbl) 
        label.delete(entryLbl) 
        entryLbl := na
    if not na(tp1Lbl) 
        label.delete(tp1Lbl) 
        tp1Lbl := na
    if not na(tp2Lbl) 
        label.delete(tp2Lbl) 
        tp2Lbl := na
    if not na(tp3Lbl) 
        label.delete(tp3Lbl) 
        tp3Lbl := na
    if not na(riskBox) 
        box.delete(riskBox) 
        riskBox := na
    if not na(rewBox) 
        box.delete(rewBox) 
        rewBox := na

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
dashPosVal = dashPos == "Top Right" ? position.top_right :
             dashPos == "Top Left" ? position.top_left :
             dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(dashPosVal, 2, 17,
     bgcolor = color.new(#0d1117, 10),
     border_color = color.new(#30363d, 20),
     border_width = 1,
     frame_color = color.new(#30363d, 40),
     frame_width = 1)

if barstate.islast
    dSz = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
    cMuted = color.new(#8b949e, 0)
    cWhite = color.new(#ffffff, 0)
    cPanel = color.new(#161b22, 0)
    cHead = color.new(statusColor, 75)
    cBull = color.new(BULL_COLOR, 0)
    cBear = color.new(BEAR_COLOR, 0)
    cNeut = color.new(NEUT_COLOR, 0)
    cGold = color.new(GOLD_COLOR, 0)

    // Row 0 — Header
    table.cell(dash, 0, 0, "RISK MANAGMENT ENGINE", text_color=cWhite, text_size=dSz, bgcolor=cHead, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0", text_color=cMuted, text_size=dSz, bgcolor=cHead, text_halign=text.align_right)

    // Row 1 — Status
    table.cell(dash, 0, 1, "Status", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 1, statusText, text_color=color.new(statusColor,0), text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 2 — Risk Tier
    tierColor = currentTier == "FULL" ? cBull : currentTier == "HALF" ? cGold : cBear
    table.cell(dash, 0, 2, "Risk Tier", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 2, currentTier, text_color=tierColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 3 — Direction
    dirColor = tradeDir == "Long" ? cBull : cBear
    table.cell(dash, 0, 3, "Direction", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 3, tradeDir == "Long" ? "▲ LONG" : "▼ SHORT", text_color=dirColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 4 — Entry
    table.cell(dash, 0, 4, "Entry", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(entryPrice, format.mintick), text_color=cWhite, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 5 — Stop
    table.cell(dash, 0, 5, "Stop Price", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 5, stopValid ? str.tostring(stopPrice, format.mintick) : "— Set Stop —", text_color=cBear, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 6 — Stop Distance
    table.cell(dash, 0, 6, "Stop Distance", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 6, stopValid ? str.tostring(math.round(stopDistTicks, 1)) + " ticks" : "—", text_color=cNeut, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 7 — Risk Per Trade
    table.cell(dash, 0, 7, "Risk Per Trade", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 7, "$" + str.tostring(riskAmount, "#.##"), text_color=cNeut, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 8 — Contracts
    cntColor = contractsAllowed > 0 ? cBull : cBear
    table.cell(dash, 0, 8, "Contracts", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 8, contractsAllowed > 0 ? str.tostring(contractsAllowed) : "— Check Stop —", text_color=cntColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 9 — TP Levels
    tpStr = stopValid ? str.tostring(tp1Price, format.mintick) + " / " + str.tostring(tp2Price, format.mintick) + " / " + str.tostring(tp3Price, format.mintick) : "—"
    table.cell(dash, 0, 9, "TP1/TP2/TP3", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 9, tpStr, text_color=cBull, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 10 — Trades Taken
    tradesColor = maxTradesReached ? cBear : tradesTaken >= maxTradesInput - 1 ? cGold : cNeut
    table.cell(dash, 0, 10, "Trades Taken", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(tradesTaken) + " / " + str.tostring(maxTradesInput), text_color=tradesColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 11 — Losses
    lossColor = maxLossesReached ? cBear : lossCount >= maxLossesInput - 1 ? cGold : cNeut
    table.cell(dash, 0, 11, "Losses", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 11, str.tostring(lossCount) + " / " + str.tostring(maxLossesInput), text_color=lossColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 12 — Winrate
    wrColor = winRate >= 60 ? cBull : winRate >= 40 ? cGold : tradesTaken > 0 ? cBear : cNeut
    table.cell(dash, 0, 12, "Win Rate", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 12, tradesTaken > 0 ? str.tostring(math.round(winRate), "#") + "% (" + str.tostring(winCount) + "W / " + str.tostring(lossCount) + "L)" : "—", text_color=wrColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 13 — Session Result
    dispColor = totalDisplay >= 0 ? cBull : cBear
    dispStr = (totalDisplay >= 0 ? "+" : "") + str.tostring(totalDisplay, "#.##") + " " + unitLabel
    dollarStr = " ($" + str.tostring(math.abs(totalDollar), "#.##") + ")"
    table.cell(dash, 0, 13, "Session Result", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 13, dispStr + (resultUnit != "Dollar" ? dollarStr : ""), text_color=dispColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 14 — Daily Target
    targetDisplay = dailyTarget
    targetPct = targetDisplay > 0 ? math.min(math.abs(totalDisplay) / targetDisplay * 100, 100) : 0
    targetColor = targetHit ? cBull : totalDisplay >= targetDisplay * 0.75 ? cGold : cNeut
    table.cell(dash, 0, 14, "Daily Target", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 14, str.tostring(totalDisplay, "#.#") + " / " + str.tostring(targetDisplay, "#.#") + " " + unitLabel + " (" + str.tostring(math.round(targetPct), "#") + "%)", text_color=targetColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 15 — Loss Limit Used
    lossUsedDollar = math.max(-totalDollar, 0)
    lossUsedPct = availDrawdown > 0 ? math.min(lossUsedDollar / availDrawdown * 100, 100) : 0
    ddColor = lossUsedPct > 80 ? cBear : lossUsedPct > 50 ? cGold : cBull
    table.cell(dash, 0, 15, "Loss Limit Used", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 15, str.tostring(math.round(lossUsedPct), "#") + "% ($" + str.tostring(lossUsedDollar, "#.##") + ")", text_color=ddColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    // Row 16 — Promote Threshold
    promColor = promotionMet ? cBull : totalThreshold > 0 ? cGold : cNeut
    promStr = totalThreshold > 0 ? str.tostring(totalPts, "#.#") + " / " + str.tostring(totalThreshold, "#.#") + " pts" + (promotionMet ? " ✓" : "") : "— No Deficit —"
    table.cell(dash, 0, 16, "Promote Threshold", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 16, promStr, text_color=promColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

 
//══════════════════════════════════════════════════════════════════════════════
// CHART LOCKOUT OVERLAY
//══════════════════════════════════════════════════════════════════════════════
var box lockBox = na
var label lockLabel = na

if sessionOver and showLockout and barstate.islast
    if not na(lockBox)
        box.delete(lockBox)
    if not na(lockLabel)
        label.delete(lockLabel)
    lockBox := box.new(bar_index - 500, close * 2, bar_index + 100, 0,
         bgcolor = color.new(statusColor, 75),
         border_color = statusColor,
         border_width = 2)
    lockLabel := label.new(bar_index, close, statusText,
         color = color.new(statusColor, 20),
         textcolor = color.white,
         style = label.style_label_center,
         size = size.huge)
else
    if not na(lockBox)
        box.delete(lockBox)
        lockBox := na
    if not na(lockLabel)
        label.delete(lockLabel)
        lockLabel := na
````
