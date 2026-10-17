# [uPaSKaL] Trading Notebook

- url: https://www.tradingview.com/script/pTYIcAlA-uPaSKaL-Trading-Notebook/
- type: indicator
- pine_id: PUB;3cbf01422dcf46b783d7ac3628538425
- version: 1.0

## Description

[b]Trading Notebook — Structured Trade Planning Dashboard[/b]

Trading Notebook is a compact chart-based planning panel designed to help discretionary traders keep their trade thesis, checklist, key levels, execution status, and invalidation logic visible directly on the chart.

This script does not generate automatic buy or sell signals. Its purpose is to structure the decision-making process before execution, reduce emotional entries, and keep the trader aligned with a predefined plan.

The compact header displays the active bias, decision state, and weighted setup score at a glance.


[b]Main Purpose[/b]

Most discretionary mistakes happen when the trader enters before confirmation, forgets the original invalidation level, changes the plan after price moves, or mixes multiple scenarios without a clear execution framework.

Trading Notebook solves this by turning the trade idea into a visible checklist-based dashboard.

[list]
[*]Define the active market bias.
[*]Write the current market context.
[*]Track confirmation conditions.
[*]Score the setup using weighted checklist logic.
[*]Display important levels directly on the chart.
[*]Store the trade plan and invalidation condition.
[*]Monitor the setup through optional alerts.
[/list]


[b]Panel Modules[/b]

The panel is divided into six practical modules:

[list]
[*][b]Context[/b] — stores the active market thesis, structure, phase, and main scenario.
[*][b]Checklist[/b] — tracks whether the required setup conditions are confirmed.
[*][b]Levels[/b] — displays important levels from the active profile.
[*][b]Decision[/b] — shows the current execution state.
[*][b]Plan[/b] — stores the trade plan, entry logic, stop logic, and targets.
[*][b]Invalidation[/b] — stores the condition that makes the current idea invalid.
[/list]


[b]Bias & Decision Framework[/b]

Each profile can be assigned one of four bias states:

[list]
[*][b]Bullish[/b]
[*][b]Bearish[/b]
[*][b]Neutral[/b]
[*][b]Waiting[/b]
[/list]

The execution state can be managed through the Decision field:

[list]
[*][b]No Trade[/b] — no valid setup.
[*][b]Watching[/b] — setup is developing.
[*][b]Ready[/b] — execution conditions are nearly complete.
[*][b]Triggered[/b] — entry trigger has occurred.
[*][b]In Trade[/b] — trade is active.
[*][b]Invalidated[/b] — the idea is no longer valid.
[*][b]Completed[/b] — the setup has finished.
[/list]

This separates analysis from execution and helps prevent impulsive decision-making.


[b]Multi-Profile System[/b]

Trading Notebook supports up to [b]5 independent profiles[/b].

Each profile includes:

[list]
[*]Enable / disable switch
[*]Symbol
[*]Title
[*]Bias
[*]Decision state
[*]Context text area
[*]Checklist text area
[*]Checklist Done toggles
[*]Checklist weights
[*]Notes field
[*]Trade plan text area
[*]Invalidation text area
[*]Five custom price levels
[/list]

Only enabled profiles are used in Auto Symbol matching.

The Notes field is stored inside the profile settings, but it is not displayed on the current compact panel layout.


[b]Profile Selection[/b]

The default profile-selection mode is [b]Auto Symbol[/b].

The script supports two profile-selection modes:

[list]
[*][b]Auto Symbol[/b] — automatically selects the enabled profile that matches the current chart symbol.
[*][b]Manual[/b] — allows the user to manually select the active profile.
[/list]

Auto Symbol matches profiles by ticker root. For example, `XAUUSD` can match symbols such as `FOREXCOM:XAUUSD`, `OANDA:XAUUSD`, and other broker versions of the same root ticker.

The matching logic also supports common perpetual suffixes such as `BTCUSDT.P`.

If no symbol match is found, the script can either show a no-match message or use the selected default profile, depending on the user setting.


[b]Checklist & Score Logic[/b]

Each profile includes a custom checklist with up to [b]10 user-defined conditions[/b].

Checklist items are entered in a multiline text area, with one condition per line. Each condition is then confirmed manually through its corresponding Done toggle.

Every checklist item has:

[list]
[*]A Done checkbox
[*]A custom weight from 0 to 10
[/list]

The final score is calculated from completed checklist weight relative to total checklist weight and is displayed from [b]0 to 100[/b].

Score labels:

[list]
[*][b]Weak Setup[/b] — below 40
[*][b]Developing[/b] — 40 to 69
[*][b]Valid Setup[/b] — 70 to 89
[*][b]A+ Setup[/b] — 90 and above
[/list]

This allows more important conditions to carry more influence than secondary confirmations.

Example checklist items:

[list]
[*]HTF bias is clear
[*]Liquidity pool identified
[*]Meaningful liquidity swept
[*]Displacement confirmed
[*]FVG / imbalance exists
[*]MSS / BOS confirmed
[*]OTE zone reached
[*]Volume / CVD confirms
[*]Risk is defined
[*]Invalidation is protected
[/list]

The checklist header displays the completed item count, total item count, weighted score percentage, and a compact progress bar.

Example:

[list]
[*]CHECKLIST 6/10 · 60%
[/list]


[b]Context Module[/b]

The Context module is designed for the core market narrative.

It can include:

[list]
[*]HTF bias
[*]Current structure
[*]Market phase
[*]Primary scenario
[*]Liquidity condition
[*]Confirmation requirement
[/list]

The compact panel displays up to 4 context lines. Longer text is truncated to keep the panel clean and usable.

Example:

[list]
[*]HTF Bias: Bearish
[*]Structure: Range compression
[*]Market Phase: Waiting for sweep
[*]Main Scenario: Short from premium
[/list]


[b]Level Management[/b]

Each profile supports up to [b]5 active levels[/b].

Every level includes:

[list]
[*]Enable / disable switch
[*]Custom name
[*]Price
[*]Level type
[/list]

Available level types:

[list]
[*]Liquidity
[*]Support
[*]Resistance
[*]OTE
[*]FVG
[*]OB
[*]Breaker
[*]Invalidation
[*]Target
[*]Custom
[/list]

Levels can be drawn directly on the chart with customizable labels, line style, and extension mode.

Level settings include:

[list]
[*]Show or hide active profile levels
[*]Show or hide level labels
[*]Tiny, Small, or Normal label size
[*]None, Right, or Both extension
[*]Solid, Dashed, or Dotted line style
[/list]

This allows the notebook to function as both a planning panel and a level-management tool.


[b]Trade Plan Module[/b]

The Plan section stores the practical execution model.

It can include:

[list]
[*]Entry condition
[*]Entry zone
[*]Stop-loss logic
[*]Target levels
[*]Trigger requirement
[*]Confirmation rule
[/list]

Example:

[list]
[*]Short after liquidity sweep + MSS
[*]Entry: 4,305 - 4,325 | SL: 4,340 | TP1: 4,280 | TP2: 4,250
[/list]

The compact panel displays the first two plan lines. Longer plans can still be stored in the profile settings.


[b]Invalidation Module[/b]

The Invalidation module is used to write the condition that invalidates the current trade idea.

Examples:

[list]
[*]Above 4,340.0
[*]Below 58,500.0
[*]Close below demand zone
[*]Break above protected high
[*]Failure to hold OTE
[/list]

Important distinction:

The Invalidation text module is for planning only. It does not trigger alerts by itself.

Invalidation Alert triggers only when price crosses an active chart level whose Type is set to [b]Invalidation[/b].


[b]Alert System[/b]

The script includes optional alert logic for monitoring important setup events.

Available alerts:

[list]
[*][b]Score Alert[/b] — triggers when the setup score reaches the selected threshold.
[*][b]Decision Alert[/b] — triggers when the decision state becomes Ready or Triggered.
[*][b]Level Cross Alert[/b] — triggers when price crosses an active level.
[*][b]Invalidation Alert[/b] — triggers when price crosses an active chart level whose Type is set to Invalidation.
[/list]

Score and decision alerts use standard alert conditions.

Level Cross and Invalidation Cross alerts use dynamic `alert()` messages.

For level-based alerts, create a chart alert using:

[list]
[*][b]Any alert() function call[/b]
[/list]

This allows the alert message to include the active symbol, timeframe, profile number, crossed level name, and crossed price.


[b]Panel Customization[/b]

The panel can be customized through:

[list]
[*]Show Panel on / off
[*]Panel position
[*]Panel size
[*]Dark, Light, or Transparent theme
[*]Maximum visible checklist rows
[*]Use Icons on / off
[/list]

Available panel sizes:

[list]
[*]Tiny
[*]Small
[*]Normal
[/list]

Available panel positions:

[list]
[*]Top Right
[*]Top Left
[*]Bottom Right
[*]Bottom Left
[*]Top Center
[*]Bottom Center
[*]Middle Right
[*]Middle Left
[/list]

If the checklist contains more items than the selected visible row limit, the panel shows how many items are hidden.


[b]Example Workflow[/b]

[list=1]
[*]Create or enable a profile for the active market.
[*]Use Auto Symbol or Manual profile selection.
[*]Define the current market context.
[*]Set the directional bias.
[*]Write the checklist conditions, one condition per line.
[*]Assign higher weights to the most important confirmations.
[*]Mark conditions as Done only after confirmation.
[*]Map liquidity, support, resistance, OTE, FVG, OB, target, or invalidation levels.
[*]Write the trade plan before execution.
[*]Define invalidation clearly.
[*]Update the Decision state as the setup develops.
[/list]


[b]Example Use Case[/b]

A trader watching XAUUSD may define:

[list]
[*]Bias: Bearish
[*]Decision: Watching
[*]Context: HTF bearish, range compression, waiting for liquidity sweep
[*]Checklist: liquidity identified, displacement required, MSS/BOS needed, OTE not reached yet
[*]Levels: liquidity high, OTE, FVG, POI, invalidation
[*]Plan: short only after sweep + MSS
[*]Invalidation: above protected high
[/list]

This prevents premature execution because the unfinished checklist conditions, active levels, plan, and invalidation remain visible on the chart.


[b]What This Script Is Not[/b]

Trading Notebook is not an automatic trading system.

It does not predict price direction.

It does not create mechanical buy or sell signals.

It does not execute trades.

It does not guarantee that a high score will produce a profitable trade.

The score is a process-control score, not a probability model.

The quality of the output depends on the quality of the trader’s own framework, checklist, and level selection.


[b]Best Use Cases[/b]

This tool is suitable for:

[list]
[*]Discretionary traders
[*]SMC / ICT traders
[*]Liquidity-based traders
[*]Supply and demand traders
[*]Price-action traders
[*]Intraday traders
[*]Swing traders
[*]Multi-symbol traders
[*]Traders who need a repeatable pre-entry checklist
[/list]


[b]Limitations[/b]

All notebook content is entered through TradingView inputs.

The script does not support live typing directly on the chart.

The script does not automatically save new information outside TradingView’s saved indicator settings.

The Notes field is available in the profile settings, but it is not displayed on the current compact panel.

The checklist score depends entirely on the user-defined framework.

A high score means the user’s own checklist is mostly complete. It does not mean the market has a statistically proven probability of success.


[b]Conclusion[/b]

Trading Notebook is designed to bring structure, discipline, and clarity into discretionary trading.

It keeps the full trade idea visible on the chart:

[list]
[*]Bias
[*]Decision state
[*]Weighted score
[*]Context
[*]Checklist
[*]Levels
[*]Plan
[*]Invalidation
[/list]

A valid trade idea should have a clear thesis, confirmed conditions, mapped levels, defined risk, and a written invalidation point before execution.

This script is built to keep that process visible, organized, and repeatable.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © uPaSKaL

//@version=6
indicator("[uPaSKaL] Trading Notebook", "Notebook", overlay = true, max_lines_count = 50, max_labels_count = 50)

const int NUM_CL = 10
const int NUM_LEVELS = 5
const int COLS = 12
const int MAX_ROWS = 22
const int MAX_CTX_SHOW = 4
const int CL_TEXT_MAX = 28

const string groupPanel = "Panel"
const string groupProfileMode = "Profile Mode"
const string groupLevels = "Level Drawing"
const string groupAlerts = "Alerts"

bool showPanel = input.bool(true, "Show Panel", group = groupPanel)
string panelPosition = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center", "Middle Right", "Middle Left"], group = groupPanel)
string panelSize = input.string("Tiny", "Panel Size", options = ["Tiny", "Small", "Normal"], group = groupPanel)
int maxChecklistRows = input.int(5, "Max Checklist Rows", minval = 3, maxval = 10, group = groupPanel)
string themeMode = input.string("Dark", "Theme", options = ["Dark", "Light", "Transparent"], group = groupPanel)
bool useIcons = input.bool(true, "Use Icons", group = groupPanel)

string profileMode = input.string("Auto Symbol", "Profile Selection", options = ["Manual", "Auto Symbol"], group = groupProfileMode, tooltip = "Auto Symbol picks the profile whose Symbol matches the current chart.")
int manualProfile = input.int(1, "Manual Profile", minval = 1, maxval = 5, group = groupProfileMode)
int defaultProfile = input.int(1, "Default Profile (No Match)", minval = 1, maxval = 5, group = groupProfileMode)
bool useDefaultOnNoMatch = input.bool(false, "Use Default On No Match", group = groupProfileMode, tooltip = "If off, shows a no-match message instead of another symbol's profile.")

bool drawLevels = input.bool(true, "Draw Active Profile Levels", group = groupLevels)
bool showLevelLabels = input.bool(true, "Show Level Labels", group = groupLevels)
string levelLabelSize = input.string("Small", "Level Label Size", options = ["Tiny", "Small", "Normal"], group = groupLevels)
string levelExtend = input.string("Right", "Level Line Extend", options = ["None", "Right", "Both"], group = groupLevels)
string levelStyle = input.string("Dashed", "Level Line Style", options = ["Solid", "Dashed", "Dotted"], group = groupLevels)

bool enableScoreAlert = input.bool(false, "Enable Score Alert", group = groupAlerts)
float scoreThreshold = input.float(70.0, "Score Threshold", minval = 0.0, maxval = 100.0, group = groupAlerts)
bool enableDecisionAlert = input.bool(false, "Enable Decision Alert", group = groupAlerts)
bool enableLevelCrossAlert = input.bool(false, "Enable Level Cross Alert", group = groupAlerts)
bool enableInvalidationAlert = input.bool(false, "Enable Invalidation Alert", group = groupAlerts)

//------------------------------------------------------------------------------
// Profile Inputs (max 5)
//------------------------------------------------------------------------------

const string gP1 = "Profile 1"
bool p1_enable = input.bool(true, 'Enable Profile 1', group = gP1)
string p1_symbol = input.symbol("BTCUSDT", "Symbol", group = gP1, tooltip = "Ticker root match, e.g. BTCUSDT matches BINANCE:BTCUSDT.P")
string p1_title = input.string("BTC Swing", "Title", group = gP1)
string p1_bias = input.string("Bullish", "Bias", options = ["Bullish", "Bearish", "Neutral", "Waiting"], group = gP1)
string p1_decision = input.string("Ready", "Decision", options = ["No Trade", "Watching", "Ready", "Triggered", "In Trade", "Invalidated", "Completed"], group = gP1)
string p1_context = input.text_area("HTF Bias: Bullish\nStructure: Corr. after impulse\nMarket Phase: Waiting for MSS\nMain Scenario: Long after sweep", "Context", group = gP1)
string p1_checklist = input.text_area("HTF bias is clear\nLiquidity pool identified\nMeaningful liquidity swept\nDisplacement confirmed\nFVG / imbalance exists\nMSS / BOS confirmed\nOTE zone reached\nVolume / CVD confirms\nRisk is defined\nInvalidation is protected", "Checklist Items (one per line)", group = gP1)
bool p1_cl1_d = input.bool(false, 'Done 1', group = gP1, inline = 'cl1')
int p1_cl1_w = input.int(1, 'W1', minval = 0, maxval = 10, group = gP1, inline = 'cl1')
bool p1_cl2_d = input.bool(false, 'Done 2', group = gP1, inline = 'cl2')
int p1_cl2_w = input.int(1, 'W2', minval = 0, maxval = 10, group = gP1, inline = 'cl2')
bool p1_cl3_d = input.bool(false, 'Done 3', group = gP1, inline = 'cl3')
int p1_cl3_w = input.int(1, 'W3', minval = 0, maxval = 10, group = gP1, inline = 'cl3')
bool p1_cl4_d = input.bool(false, 'Done 4', group = gP1, inline = 'cl4')
int p1_cl4_w = input.int(1, 'W4', minval = 0, maxval = 10, group = gP1, inline = 'cl4')
bool p1_cl5_d = input.bool(false, 'Done 5', group = gP1, inline = 'cl5')
int p1_cl5_w = input.int(1, 'W5', minval = 0, maxval = 10, group = gP1, inline = 'cl5')
bool p1_cl6_d = input.bool(false, 'Done 6', group = gP1, inline = 'cl6')
int p1_cl6_w = input.int(1, 'W6', minval = 0, maxval = 10, group = gP1, inline = 'cl6')
bool p1_cl7_d = input.bool(false, 'Done 7', group = gP1, inline = 'cl7')
int p1_cl7_w = input.int(1, 'W7', minval = 0, maxval = 10, group = gP1, inline = 'cl7')
bool p1_cl8_d = input.bool(false, 'Done 8', group = gP1, inline = 'cl8')
int p1_cl8_w = input.int(1, 'W8', minval = 0, maxval = 10, group = gP1, inline = 'cl8')
bool p1_cl9_d = input.bool(false, 'Done 9', group = gP1, inline = 'cl9')
int p1_cl9_w = input.int(1, 'W9', minval = 0, maxval = 10, group = gP1, inline = 'cl9')
bool p1_cl10_d = input.bool(false, 'Done 10', group = gP1, inline = 'cl10')
int p1_cl10_w = input.int(1, 'W10', minval = 0, maxval = 10, group = gP1, inline = 'cl10')
string p1_notes = input.text_area("", "Notes", group = gP1)
string p1_plan = input.text_area("Long after liquidity sweep + MSS\nEntry: 59,200 - 59,800 | SL: 58,500 | TP1: 60,500 | TP2: 61,250", "Trade Plan", group = gP1)
string p1_invalid = input.text_area("Below 58,500.0", "Invalidation", group = gP1)
bool p1_lv1_en = input.bool(true, 'Lv1 On', group = gP1, inline = 'lv1')
string p1_lv1_name = input.string("Liquidity High", "Name1", group = gP1, inline = "lv1")
float p1_lv1_price = input.float(61250.0, 'Price1', group = gP1, inline = 'lv1')
string p1_lv1_type = input.string("Liquidity", "Type1", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP1, inline = "lv1")
bool p1_lv2_en = input.bool(true, 'Lv2 On', group = gP1, inline = 'lv2')
string p1_lv2_name = input.string("Sellside Liquidity", "Name2", group = gP1, inline = "lv2")
float p1_lv2_price = input.float(60500.0, 'Price2', group = gP1, inline = 'lv2')
string p1_lv2_type = input.string("Liquidity", "Type2", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP1, inline = "lv2")
bool p1_lv3_en = input.bool(true, 'Lv3 On', group = gP1, inline = 'lv3')
string p1_lv3_name = input.string("FVG High", "Name3", group = gP1, inline = "lv3")
float p1_lv3_price = input.float(59850.0, 'Price3', group = gP1, inline = 'lv3')
string p1_lv3_type = input.string("FVG", "Type3", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP1, inline = "lv3")
bool p1_lv4_en = input.bool(true, 'Lv4 On', group = gP1, inline = 'lv4')
string p1_lv4_name = input.string("POI / OB", "Name4", group = gP1, inline = "lv4")
float p1_lv4_price = input.float(59200.0, 'Price4', group = gP1, inline = 'lv4')
string p1_lv4_type = input.string("OB", "Type4", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP1, inline = "lv4")
bool p1_lv5_en = input.bool(true, 'Lv5 On', group = gP1, inline = 'lv5')
string p1_lv5_name = input.string("Invalidation", "Name5", group = gP1, inline = "lv5")
float p1_lv5_price = input.float(58500.0, 'Price5', group = gP1, inline = 'lv5')
string p1_lv5_type = input.string("Invalidation", "Type5", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP1, inline = "lv5")

const string gP2 = "Profile 2"
bool p2_enable = input.bool(true, 'Enable Profile 2', group = gP2)
string p2_symbol = input.symbol("XAUUSD", "Symbol", group = gP2, tooltip = "Match by ticker root, e.g. XAUUSD works for OANDA:XAUUSD, FOREXCOM:XAUUSD, etc.")
string p2_title = input.string("Gold Intraday", "Title", group = gP2)
string p2_bias = input.string("Bearish", "Bias", options = ["Bullish", "Bearish", "Neutral", "Waiting"], group = gP2)
string p2_decision = input.string("Watching", "Decision", options = ["No Trade", "Watching", "Ready", "Triggered", "In Trade", "Invalidated", "Completed"], group = gP2)
string p2_context = input.text_area("HTF Bias: Bearish\nStructure: Range compression\nMarket Phase: Waiting for sweep\nMain Scenario: Short from premium", "Context", group = gP2)
string p2_checklist = input.text_area("HTF bias is clear\nLiquidity pool identified\nMeaningful liquidity swept\nDisplacement confirmed\nFVG / imbalance exists\nMSS / BOS confirmed\nOTE zone reached\nVolume / CVD confirms\nRisk is defined\nInvalidation is protected", "Checklist Items (one per line)", group = gP2)
bool p2_cl1_d = input.bool(false, 'Done 1', group = gP2, inline = 'cl1')
int p2_cl1_w = input.int(1, 'W1', minval = 0, maxval = 10, group = gP2, inline = 'cl1')
bool p2_cl2_d = input.bool(false, 'Done 2', group = gP2, inline = 'cl2')
int p2_cl2_w = input.int(1, 'W2', minval = 0, maxval = 10, group = gP2, inline = 'cl2')
bool p2_cl3_d = input.bool(false, 'Done 3', group = gP2, inline = 'cl3')
int p2_cl3_w = input.int(1, 'W3', minval = 0, maxval = 10, group = gP2, inline = 'cl3')
bool p2_cl4_d = input.bool(false, 'Done 4', group = gP2, inline = 'cl4')
int p2_cl4_w = input.int(1, 'W4', minval = 0, maxval = 10, group = gP2, inline = 'cl4')
bool p2_cl5_d = input.bool(false, 'Done 5', group = gP2, inline = 'cl5')
int p2_cl5_w = input.int(1, 'W5', minval = 0, maxval = 10, group = gP2, inline = 'cl5')
bool p2_cl6_d = input.bool(false, 'Done 6', group = gP2, inline = 'cl6')
int p2_cl6_w = input.int(1, 'W6', minval = 0, maxval = 10, group = gP2, inline = 'cl6')
bool p2_cl7_d = input.bool(false, 'Done 7', group = gP2, inline = 'cl7')
int p2_cl7_w = input.int(1, 'W7', minval = 0, maxval = 10, group = gP2, inline = 'cl7')
bool p2_cl8_d = input.bool(false, 'Done 8', group = gP2, inline = 'cl8')
int p2_cl8_w = input.int(1, 'W8', minval = 0, maxval = 10, group = gP2, inline = 'cl8')
bool p2_cl9_d = input.bool(false, 'Done 9', group = gP2, inline = 'cl9')
int p2_cl9_w = input.int(1, 'W9', minval = 0, maxval = 10, group = gP2, inline = 'cl9')
bool p2_cl10_d = input.bool(false, 'Done 10', group = gP2, inline = 'cl10')
int p2_cl10_w = input.int(1, 'W10', minval = 0, maxval = 10, group = gP2, inline = 'cl10')
string p2_notes = input.text_area("", "Notes", group = gP2)
string p2_plan = input.text_area("Short after liquidity sweep + MSS\nEntry: 4,305 - 4,325 | SL: 4,340 | TP1: 4,280 | TP2: 4,250", "Trade Plan", group = gP2)
string p2_invalid = input.text_area("Above 4,340.0", "Invalidation", group = gP2)
bool p2_lv1_en = input.bool(true, 'Lv1 On', group = gP2, inline = 'lv1')
string p2_lv1_name = input.string("Liquidity High", "Name1", group = gP2, inline = "lv1")
float p2_lv1_price = input.float(4380.0, 'Price1', group = gP2, inline = 'lv1')
string p2_lv1_type = input.string("Liquidity", "Type1", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP2, inline = "lv1")
bool p2_lv2_en = input.bool(true, 'Lv2 On', group = gP2, inline = 'lv2')
string p2_lv2_name = input.string("Sellside Liquidity", "Name2", group = gP2, inline = "lv2")
float p2_lv2_price = input.float(4345.0, 'Price2', group = gP2, inline = 'lv2')
string p2_lv2_type = input.string("Liquidity", "Type2", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP2, inline = "lv2")
bool p2_lv3_en = input.bool(true, 'Lv3 On', group = gP2, inline = 'lv3')
string p2_lv3_name = input.string("FVG High", "Name3", group = gP2, inline = "lv3")
float p2_lv3_price = input.float(4310.0, 'Price3', group = gP2, inline = 'lv3')
string p2_lv3_type = input.string("FVG", "Type3", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP2, inline = "lv3")
bool p2_lv4_en = input.bool(true, 'Lv4 On', group = gP2, inline = 'lv4')
string p2_lv4_name = input.string("POI / OB", "Name4", group = gP2, inline = "lv4")
float p2_lv4_price = input.float(4280.0, 'Price4', group = gP2, inline = 'lv4')
string p2_lv4_type = input.string("OB", "Type4", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP2, inline = "lv4")
bool p2_lv5_en = input.bool(true, 'Lv5 On', group = gP2, inline = 'lv5')
string p2_lv5_name = input.string("Invalidation", "Name5", group = gP2, inline = "lv5")
float p2_lv5_price = input.float(4250.0, 'Price5', group = gP2, inline = 'lv5')
string p2_lv5_type = input.string("Invalidation", "Type5", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP2, inline = "lv5")

const string gP3 = "Profile 3"
bool p3_enable = input.bool(true, 'Enable Profile 3', group = gP3)
string p3_symbol = input.symbol("EURUSD", "Symbol", group = gP3, tooltip = "Match by ticker root, e.g. EURUSD works across brokers.")
string p3_title = input.string("EURUSD", "Title", group = gP3)
string p3_bias = input.string("Neutral", "Bias", options = ["Bullish", "Bearish", "Neutral", "Waiting"], group = gP3)
string p3_decision = input.string("No Trade", "Decision", options = ["No Trade", "Watching", "Ready", "Triggered", "In Trade", "Invalidated", "Completed"], group = gP3)
string p3_context = input.text_area("", "Context", group = gP3)
string p3_checklist = input.text_area("", "Checklist Items (one per line)", group = gP3)
bool p3_cl1_d = input.bool(false, 'Done 1', group = gP3, inline = 'cl1')
int p3_cl1_w = input.int(1, 'W1', minval = 0, maxval = 10, group = gP3, inline = 'cl1')
bool p3_cl2_d = input.bool(false, 'Done 2', group = gP3, inline = 'cl2')
int p3_cl2_w = input.int(1, 'W2', minval = 0, maxval = 10, group = gP3, inline = 'cl2')
bool p3_cl3_d = input.bool(false, 'Done 3', group = gP3, inline = 'cl3')
int p3_cl3_w = input.int(1, 'W3', minval = 0, maxval = 10, group = gP3, inline = 'cl3')
bool p3_cl4_d = input.bool(false, 'Done 4', group = gP3, inline = 'cl4')
int p3_cl4_w = input.int(1, 'W4', minval = 0, maxval = 10, group = gP3, inline = 'cl4')
bool p3_cl5_d = input.bool(false, 'Done 5', group = gP3, inline = 'cl5')
int p3_cl5_w = input.int(1, 'W5', minval = 0, maxval = 10, group = gP3, inline = 'cl5')
bool p3_cl6_d = input.bool(false, 'Done 6', group = gP3, inline = 'cl6')
int p3_cl6_w = input.int(1, 'W6', minval = 0, maxval = 10, group = gP3, inline = 'cl6')
bool p3_cl7_d = input.bool(false, 'Done 7', group = gP3, inline = 'cl7')
int p3_cl7_w = input.int(1, 'W7', minval = 0, maxval = 10, group = gP3, inline = 'cl7')
bool p3_cl8_d = input.bool(false, 'Done 8', group = gP3, inline = 'cl8')
int p3_cl8_w = input.int(1, 'W8', minval = 0, maxval = 10, group = gP3, inline = 'cl8')
bool p3_cl9_d = input.bool(false, 'Done 9', group = gP3, inline = 'cl9')
int p3_cl9_w = input.int(1, 'W9', minval = 0, maxval = 10, group = gP3, inline = 'cl9')
bool p3_cl10_d = input.bool(false, 'Done 10', group = gP3, inline = 'cl10')
int p3_cl10_w = input.int(1, 'W10', minval = 0, maxval = 10, group = gP3, inline = 'cl10')
string p3_notes = input.text_area("", "Notes", group = gP3)
string p3_plan = input.text_area("", "Trade Plan", group = gP3)
string p3_invalid = input.text_area("", "Invalidation", group = gP3)
bool p3_lv1_en = input.bool(false, 'Lv1 On', group = gP3, inline = 'lv1')
string p3_lv1_name = input.string("", "Name1", group = gP3, inline = "lv1")
float p3_lv1_price = input.float(0.0, 'Price1', group = gP3, inline = 'lv1')
string p3_lv1_type = input.string("Custom", "Type1", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP3, inline = "lv1")
bool p3_lv2_en = input.bool(false, 'Lv2 On', group = gP3, inline = 'lv2')
string p3_lv2_name = input.string("", "Name2", group = gP3, inline = "lv2")
float p3_lv2_price = input.float(0.0, 'Price2', group = gP3, inline = 'lv2')
string p3_lv2_type = input.string("Custom", "Type2", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP3, inline = "lv2")
bool p3_lv3_en = input.bool(false, 'Lv3 On', group = gP3, inline = 'lv3')
string p3_lv3_name = input.string("", "Name3", group = gP3, inline = "lv3")
float p3_lv3_price = input.float(0.0, 'Price3', group = gP3, inline = 'lv3')
string p3_lv3_type = input.string("Custom", "Type3", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP3, inline = "lv3")
bool p3_lv4_en = input.bool(false, 'Lv4 On', group = gP3, inline = 'lv4')
string p3_lv4_name = input.string("", "Name4", group = gP3, inline = "lv4")
float p3_lv4_price = input.float(0.0, 'Price4', group = gP3, inline = 'lv4')
string p3_lv4_type = input.string("Custom", "Type4", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP3, inline = "lv4")
bool p3_lv5_en = input.bool(false, 'Lv5 On', group = gP3, inline = 'lv5')
string p3_lv5_name = input.string("", "Name5", group = gP3, inline = "lv5")
float p3_lv5_price = input.float(0.0, 'Price5', group = gP3, inline = 'lv5')
string p3_lv5_type = input.string("Custom", "Type5", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP3, inline = "lv5")

const string gP4 = "Profile 4"
bool p4_enable = input.bool(false, 'Enable Profile 4', group = gP4)
string p4_symbol = input.symbol("", "Symbol", group = gP4, tooltip = "Leave empty to use chart symbol.")
string p4_title = input.string("Profile 4", "Title", group = gP4)
string p4_bias = input.string("Neutral", "Bias", options = ["Bullish", "Bearish", "Neutral", "Waiting"], group = gP4)
string p4_decision = input.string("No Trade", "Decision", options = ["No Trade", "Watching", "Ready", "Triggered", "In Trade", "Invalidated", "Completed"], group = gP4)
string p4_context = input.text_area("", "Context", group = gP4)
string p4_checklist = input.text_area("", "Checklist Items (one per line)", group = gP4)
bool p4_cl1_d = input.bool(false, 'Done 1', group = gP4, inline = 'cl1')
int p4_cl1_w = input.int(1, 'W1', minval = 0, maxval = 10, group = gP4, inline = 'cl1')
bool p4_cl2_d = input.bool(false, 'Done 2', group = gP4, inline = 'cl2')
int p4_cl2_w = input.int(1, 'W2', minval = 0, maxval = 10, group = gP4, inline = 'cl2')
bool p4_cl3_d = input.bool(false, 'Done 3', group = gP4, inline = 'cl3')
int p4_cl3_w = input.int(1, 'W3', minval = 0, maxval = 10, group = gP4, inline = 'cl3')
bool p4_cl4_d = input.bool(false, 'Done 4', group = gP4, inline = 'cl4')
int p4_cl4_w = input.int(1, 'W4', minval = 0, maxval = 10, group = gP4, inline = 'cl4')
bool p4_cl5_d = input.bool(false, 'Done 5', group = gP4, inline = 'cl5')
int p4_cl5_w = input.int(1, 'W5', minval = 0, maxval = 10, group = gP4, inline = 'cl5')
bool p4_cl6_d = input.bool(false, 'Done 6', group = gP4, inline = 'cl6')
int p4_cl6_w = input.int(1, 'W6', minval = 0, maxval = 10, group = gP4, inline = 'cl6')
bool p4_cl7_d = input.bool(false, 'Done 7', group = gP4, inline = 'cl7')
int p4_cl7_w = input.int(1, 'W7', minval = 0, maxval = 10, group = gP4, inline = 'cl7')
bool p4_cl8_d = input.bool(false, 'Done 8', group = gP4, inline = 'cl8')
int p4_cl8_w = input.int(1, 'W8', minval = 0, maxval = 10, group = gP4, inline = 'cl8')
bool p4_cl9_d = input.bool(false, 'Done 9', group = gP4, inline = 'cl9')
int p4_cl9_w = input.int(1, 'W9', minval = 0, maxval = 10, group = gP4, inline = 'cl9')
bool p4_cl10_d = input.bool(false, 'Done 10', group = gP4, inline = 'cl10')
int p4_cl10_w = input.int(1, 'W10', minval = 0, maxval = 10, group = gP4, inline = 'cl10')
string p4_notes = input.text_area("", "Notes", group = gP4)
string p4_plan = input.text_area("", "Trade Plan", group = gP4)
string p4_invalid = input.text_area("", "Invalidation", group = gP4)
bool p4_lv1_en = input.bool(false, 'Lv1 On', group = gP4, inline = 'lv1')
string p4_lv1_name = input.string("", "Name1", group = gP4, inline = "lv1")
float p4_lv1_price = input.float(0.0, 'Price1', group = gP4, inline = 'lv1')
string p4_lv1_type = input.string("Custom", "Type1", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP4, inline = "lv1")
bool p4_lv2_en = input.bool(false, 'Lv2 On', group = gP4, inline = 'lv2')
string p4_lv2_name = input.string("", "Name2", group = gP4, inline = "lv2")
float p4_lv2_price = input.float(0.0, 'Price2', group = gP4, inline = 'lv2')
string p4_lv2_type = input.string("Custom", "Type2", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP4, inline = "lv2")
bool p4_lv3_en = input.bool(false, 'Lv3 On', group = gP4, inline = 'lv3')
string p4_lv3_name = input.string("", "Name3", group = gP4, inline = "lv3")
float p4_lv3_price = input.float(0.0, 'Price3', group = gP4, inline = 'lv3')
string p4_lv3_type = input.string("Custom", "Type3", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP4, inline = "lv3")
bool p4_lv4_en = input.bool(false, 'Lv4 On', group = gP4, inline = 'lv4')
string p4_lv4_name = input.string("", "Name4", group = gP4, inline = "lv4")
float p4_lv4_price = input.float(0.0, 'Price4', group = gP4, inline = 'lv4')
string p4_lv4_type = input.string("Custom", "Type4", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP4, inline = "lv4")
bool p4_lv5_en = input.bool(false, 'Lv5 On', group = gP4, inline = 'lv5')
string p4_lv5_name = input.string("", "Name5", group = gP4, inline = "lv5")
float p4_lv5_price = input.float(0.0, 'Price5', group = gP4, inline = 'lv5')
string p4_lv5_type = input.string("Custom", "Type5", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP4, inline = "lv5")

const string gP5 = "Profile 5"
bool p5_enable = input.bool(false, 'Enable Profile 5', group = gP5)
string p5_symbol = input.symbol("", "Symbol", group = gP5, tooltip = "Leave empty to use chart symbol.")
string p5_title = input.string("Profile 5", "Title", group = gP5)
string p5_bias = input.string("Neutral", "Bias", options = ["Bullish", "Bearish", "Neutral", "Waiting"], group = gP5)
string p5_decision = input.string("No Trade", "Decision", options = ["No Trade", "Watching", "Ready", "Triggered", "In Trade", "Invalidated", "Completed"], group = gP5)
string p5_context = input.text_area("", "Context", group = gP5)
string p5_checklist = input.text_area("", "Checklist Items (one per line)", group = gP5)
bool p5_cl1_d = input.bool(false, 'Done 1', group = gP5, inline = 'cl1')
int p5_cl1_w = input.int(1, 'W1', minval = 0, maxval = 10, group = gP5, inline = 'cl1')
bool p5_cl2_d = input.bool(false, 'Done 2', group = gP5, inline = 'cl2')
int p5_cl2_w = input.int(1, 'W2', minval = 0, maxval = 10, group = gP5, inline = 'cl2')
bool p5_cl3_d = input.bool(false, 'Done 3', group = gP5, inline = 'cl3')
int p5_cl3_w = input.int(1, 'W3', minval = 0, maxval = 10, group = gP5, inline = 'cl3')
bool p5_cl4_d = input.bool(false, 'Done 4', group = gP5, inline = 'cl4')
int p5_cl4_w = input.int(1, 'W4', minval = 0, maxval = 10, group = gP5, inline = 'cl4')
bool p5_cl5_d = input.bool(false, 'Done 5', group = gP5, inline = 'cl5')
int p5_cl5_w = input.int(1, 'W5', minval = 0, maxval = 10, group = gP5, inline = 'cl5')
bool p5_cl6_d = input.bool(false, 'Done 6', group = gP5, inline = 'cl6')
int p5_cl6_w = input.int(1, 'W6', minval = 0, maxval = 10, group = gP5, inline = 'cl6')
bool p5_cl7_d = input.bool(false, 'Done 7', group = gP5, inline = 'cl7')
int p5_cl7_w = input.int(1, 'W7', minval = 0, maxval = 10, group = gP5, inline = 'cl7')
bool p5_cl8_d = input.bool(false, 'Done 8', group = gP5, inline = 'cl8')
int p5_cl8_w = input.int(1, 'W8', minval = 0, maxval = 10, group = gP5, inline = 'cl8')
bool p5_cl9_d = input.bool(false, 'Done 9', group = gP5, inline = 'cl9')
int p5_cl9_w = input.int(1, 'W9', minval = 0, maxval = 10, group = gP5, inline = 'cl9')
bool p5_cl10_d = input.bool(false, 'Done 10', group = gP5, inline = 'cl10')
int p5_cl10_w = input.int(1, 'W10', minval = 0, maxval = 10, group = gP5, inline = 'cl10')
string p5_notes = input.text_area("", "Notes", group = gP5)
string p5_plan = input.text_area("", "Trade Plan", group = gP5)
string p5_invalid = input.text_area("", "Invalidation", group = gP5)
bool p5_lv1_en = input.bool(false, 'Lv1 On', group = gP5, inline = 'lv1')
string p5_lv1_name = input.string("", "Name1", group = gP5, inline = "lv1")
float p5_lv1_price = input.float(0.0, 'Price1', group = gP5, inline = 'lv1')
string p5_lv1_type = input.string("Custom", "Type1", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP5, inline = "lv1")
bool p5_lv2_en = input.bool(false, 'Lv2 On', group = gP5, inline = 'lv2')
string p5_lv2_name = input.string("", "Name2", group = gP5, inline = "lv2")
float p5_lv2_price = input.float(0.0, 'Price2', group = gP5, inline = 'lv2')
string p5_lv2_type = input.string("Custom", "Type2", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP5, inline = "lv2")
bool p5_lv3_en = input.bool(false, 'Lv3 On', group = gP5, inline = 'lv3')
string p5_lv3_name = input.string("", "Name3", group = gP5, inline = "lv3")
float p5_lv3_price = input.float(0.0, 'Price3', group = gP5, inline = 'lv3')
string p5_lv3_type = input.string("Custom", "Type3", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP5, inline = "lv3")
bool p5_lv4_en = input.bool(false, 'Lv4 On', group = gP5, inline = 'lv4')
string p5_lv4_name = input.string("", "Name4", group = gP5, inline = "lv4")
float p5_lv4_price = input.float(0.0, 'Price4', group = gP5, inline = 'lv4')
string p5_lv4_type = input.string("Custom", "Type4", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP5, inline = "lv4")
bool p5_lv5_en = input.bool(false, 'Lv5 On', group = gP5, inline = 'lv5')
string p5_lv5_name = input.string("", "Name5", group = gP5, inline = "lv5")
float p5_lv5_price = input.float(0.0, 'Price5', group = gP5, inline = 'lv5')
string p5_lv5_type = input.string("Custom", "Type5", options = ["Liquidity", "Support", "Resistance", "OTE", "FVG", "OB", "Breaker", "Invalidation", "Target", "Custom"], group = gP5, inline = "lv5")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------

f_getPosition(string pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        => position.top_left

f_getTextSize(string sz) =>
    switch sz
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_getTheme(string theme) =>
    color bg = switch theme
        "Light" => color.new(color.rgb(248, 249, 252), 0)
        "Transparent" => color.new(color.rgb(12, 14, 20), 82)
        => color.new(color.rgb(18, 20, 28), 4)
    color txt = theme == "Light" ? color.rgb(28, 32, 40) : color.rgb(225, 228, 235)
    color mod = theme == "Light" ? color.new(color.rgb(255, 255, 255), 0) : color.new(color.rgb(26, 29, 38), 0)
    [bg, txt, mod]

f_biasColor(string bias) =>
    switch bias
        "Bullish" => color.rgb(34, 180, 132)
        "Bearish" => color.rgb(224, 82, 82)
        "Waiting" => color.rgb(230, 170, 70)
        => color.rgb(150, 156, 168)

f_decisionColor(string decision) =>
    switch decision
        "Watching" => color.rgb(230, 170, 70)
        "Ready" => color.rgb(34, 180, 132)
        "Triggered" => color.rgb(72, 145, 230)
        "In Trade" => color.rgb(156, 98, 210)
        "Invalidated" => color.rgb(224, 82, 82)
        "Completed" => color.rgb(34, 180, 132)
        => color.rgb(150, 156, 168)

f_levelTypeColor(string lvlType) =>
    switch lvlType
        "Liquidity" => color.rgb(34, 180, 132)
        "Support" => color.rgb(34, 180, 132)
        "Resistance" => color.rgb(224, 82, 82)
        "OTE" => color.rgb(156, 98, 210)
        "FVG" => color.rgb(230, 170, 70)
        "OB" => color.rgb(72, 145, 230)
        "Breaker" => color.rgb(255, 120, 180)
        "Invalidation" => color.rgb(230, 140, 70)
        "Target" => color.rgb(34, 180, 132)
        => color.rgb(150, 156, 168)

f_getLineStyle(string styleName) =>
    switch styleName
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

f_getLineExtend(string extendName) =>
    switch extendName
        "None" => extend.none
        "Both" => extend.both
        => extend.right

f_nonempty(string txt) =>
    str.length(str.trim(txt)) > 0

f_clLine(string txt, int idx) =>
    string[] lines = str.split(txt, "\n")
    array.size(lines) > idx ? str.trim(array.get(lines, idx)) : ""

f_clCount(string txt) =>
    int n = 0
    for i = 0 to NUM_CL - 1
        if f_nonempty(f_clLine(txt, i))
            n += 1
    n

f_clDoneCount(string txt, bool d1, bool d2, bool d3, bool d4, bool d5, bool d6, bool d7, bool d8, bool d9, bool d10) =>
    int n = 0
    for i = 0 to NUM_CL - 1
        bool di = i == 0 ? d1 : i == 1 ? d2 : i == 2 ? d3 : i == 3 ? d4 : i == 4 ? d5 : i == 5 ? d6 : i == 6 ? d7 : i == 7 ? d8 : i == 8 ? d9 : d10
        if f_nonempty(f_clLine(txt, i)) and di
            n += 1
    n

f_getDone(int idx, bool d1, bool d2, bool d3, bool d4, bool d5, bool d6, bool d7, bool d8, bool d9, bool d10) =>
    idx == 0 ? d1 : idx == 1 ? d2 : idx == 2 ? d3 : idx == 3 ? d4 : idx == 4 ? d5 : idx == 5 ? d6 : idx == 6 ? d7 : idx == 7 ? d8 : idx == 8 ? d9 : d10

f_getWeight(int idx, int w1, int w2, int w3, int w4, int w5, int w6, int w7, int w8, int w9, int w10) =>
    idx == 0 ? w1 : idx == 1 ? w2 : idx == 2 ? w3 : idx == 3 ? w4 : idx == 4 ? w5 : idx == 5 ? w6 : idx == 6 ? w7 : idx == 7 ? w8 : idx == 8 ? w9 : w10

f_calcScore(string txt, bool d1, bool d2, bool d3, bool d4, bool d5, bool d6, bool d7, bool d8, bool d9, bool d10, int w1, int w2, int w3, int w4, int w5, int w6, int w7, int w8, int w9, int w10) =>
    float doneW = 0.0
    float totalW = 0.0
    for i = 0 to NUM_CL - 1
        string ln = f_clLine(txt, i)
        if f_nonempty(ln)
            int w = f_getWeight(i, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10)
            bool d = f_getDone(i, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)
            totalW += w
            doneW += d ? w : 0.0
    totalW > 0.0 ? doneW / totalW * 100.0 : na

f_getScoreLabel(float score) =>
    na(score) ? "N/A" : score < 40.0 ? "Weak Setup" : score < 70.0 ? "Developing" : score < 90.0 ? "Valid Setup" : "A+ Setup"

f_trunc(string txt, int maxLen) =>
    str.length(txt) > maxLen ? str.substring(txt, 0, maxLen - 1) + "…" : txt

f_progressBar(float pct) =>
    int filled = int(math.round(nz(pct) / 20.0))
    string bar = ""
    for i = 0 to 4
        bar += i < filled ? "▮" : "▯"
    bar

f_iconCheck(bool done) =>
    done ? "✓" : "⬜"

f_iconCheckColor(bool done) =>
    done ? color.rgb(46, 204, 113) : color.rgb(95, 100, 110)

f_padMod(table tb, int row, int c0, int c1, color bg) =>
    for c = c0 to c1
        table.cell(tb, c, row, "", bgcolor = bg, text_color = bg, text_size = size.tiny)

f_symbolRoot(string sym) =>
    int sep = str.pos(sym, ":")
    sep >= 0 ? str.substring(sym, sep + 1) : sym

f_normSymbol(string sym) =>
    string s = str.upper(str.trim(f_symbolRoot(sym)))
    str.endswith(s, ".P") ? str.substring(s, 0, str.length(s) - 2) : s

f_profileMatch(string symMatch) =>
    if not f_nonempty(symMatch)
        false
    else
        string matchNorm = f_normSymbol(symMatch)
        string chartNorm = f_normSymbol(syminfo.tickerid)
        string tickerNorm = f_normSymbol(syminfo.ticker)
        syminfo.tickerid == symMatch or syminfo.ticker == symMatch or chartNorm == matchNorm or tickerNorm == matchNorm

f_selectAutoProfile() =>
    int found = 0
    if p1_enable and f_profileMatch(p1_symbol)
        found := 1
    else if p2_enable and f_profileMatch(p2_symbol)
        found := 2
    else if p3_enable and f_profileMatch(p3_symbol)
        found := 3
    else if p4_enable and f_profileMatch(p4_symbol)
        found := 4
    else if p5_enable and f_profileMatch(p5_symbol)
        found := 5
    found

f_moduleHdr(table tb, int row, int c0, int c1, string title, color hdrCol, color txt, string sz) =>
    table.cell(tb, c0, row, title, bgcolor = hdrCol, text_color = txt, text_size = f_getTextSize(sz), text_halign = text.align_left)
    if c1 > c0
        table.merge_cells(tb, c0, row, c1, row)

f_modCell(table tb, int row, int c0, int c1, string txt, color modBg, color fg, string sz, string halign) =>
    table.cell(tb, c0, row, txt, bgcolor = modBg, text_color = fg, text_size = f_getTextSize(sz), text_halign = halign == "L" ? text.align_left : halign == "R" ? text.align_right : text.align_center)
    if c1 > c0
        table.merge_cells(tb, c0, row, c1, row)

f_getLevelLabelSize(string sz) =>
    switch sz
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_formatLevelLabel(string name, float price) =>
    f_nonempty(name) ? name + "  ·  " + str.tostring(price, format.mintick) : str.tostring(price, format.mintick)

f_levelLineColor(color col) =>
    color.new(col, 45)

f_levelLabelBg(string theme) =>
    theme == "Light" ? color.new(color.rgb(255, 255, 255), 15) : color.new(color.rgb(14, 17, 24), 8)

f_updateLevelLine(line ln, label lb, bool enabled, float price, string name, color col, string styleName, string extendName, bool draw, bool labels) =>
    line outLn = ln
    label outLb = lb
    if draw and enabled and price > 0.0
        string lblTxt = f_formatLevelLabel(name, price)
        color lnCol = f_levelLineColor(col)
        color lblBg = f_levelLabelBg(themeMode)
        int lblX = bar_index
        if na(outLn)
            outLn := line.new(bar_index - 1, price, bar_index, price, xloc = xloc.bar_index, extend = f_getLineExtend(extendName), color = lnCol, style = f_getLineStyle(styleName), width = 1)
        else
            line.set_xy1(outLn, bar_index - 1, price)
            line.set_xy2(outLn, bar_index, price)
            line.set_color(outLn, lnCol)
            line.set_style(outLn, f_getLineStyle(styleName))
            line.set_extend(outLn, f_getLineExtend(extendName))
        if labels
            if na(outLb)
                outLb := label.new(lblX, price, lblTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_right, color = lblBg, textcolor = col, size = f_getLevelLabelSize(levelLabelSize), text_font_family = font.family_monospace)
            else
                label.set_xy(outLb, lblX, price)
                label.set_text(outLb, lblTxt)
                label.set_textcolor(outLb, col)
                label.set_color(outLb, lblBg)
                label.set_size(outLb, f_getLevelLabelSize(levelLabelSize))
                label.set_style(outLb, label.style_label_right)
        else if not na(outLb)
            label.delete(outLb)
            outLb := na
    else
        if not na(outLn)
            line.delete(outLn)
            outLn := na
        if not na(outLb)
            label.delete(outLb)
            outLb := na
    [outLn, outLb]

f_levelCross(float price, bool enabled) =>
    enabled and price > 0.0 and (ta.crossover(close, price) or ta.crossunder(close, price))


//------------------------------------------------------------------------------
// Runtime
//------------------------------------------------------------------------------

int autoProfile = f_selectAutoProfile()
bool autoNoMatch = profileMode == "Auto Symbol" and autoProfile == 0
int activeProfile = profileMode == "Manual" ? manualProfile : autoNoMatch and useDefaultOnNoMatch ? defaultProfile : autoProfile
bool showNoMatchMsg = profileMode == "Auto Symbol" and autoProfile == 0 and not useDefaultOnNoMatch

string activeTitle = switch activeProfile
    1 => p1_title
    2 => p2_title
    3 => p3_title
    4 => p4_title
    5 => p5_title
    => ""
string activeBias = switch activeProfile
    1 => p1_bias
    2 => p2_bias
    3 => p3_bias
    4 => p4_bias
    5 => p5_bias
    => "Neutral"
string activeDecision = switch activeProfile
    1 => p1_decision
    2 => p2_decision
    3 => p3_decision
    4 => p4_decision
    5 => p5_decision
    => "No Trade"
string activeContext = switch activeProfile
    1 => p1_context
    2 => p2_context
    3 => p3_context
    4 => p4_context
    5 => p5_context
    => ""
string activeChecklist = switch activeProfile
    1 => p1_checklist
    2 => p2_checklist
    3 => p3_checklist
    4 => p4_checklist
    5 => p5_checklist
    => ""
string activeNotes = switch activeProfile
    1 => p1_notes
    2 => p2_notes
    3 => p3_notes
    4 => p4_notes
    5 => p5_notes
    => ""
string activePlan = switch activeProfile
    1 => p1_plan
    2 => p2_plan
    3 => p3_plan
    4 => p4_plan
    5 => p5_plan
    => ""
string activeInvalid = switch activeProfile
    1 => p1_invalid
    2 => p2_invalid
    3 => p3_invalid
    4 => p4_invalid
    5 => p5_invalid
    => ""
bool activeCl1d = switch activeProfile
    1 => p1_cl1_d
    2 => p2_cl1_d
    3 => p3_cl1_d
    4 => p4_cl1_d
    5 => p5_cl1_d
    => false
int activeCl1w = switch activeProfile
    1 => p1_cl1_w
    2 => p2_cl1_w
    3 => p3_cl1_w
    4 => p4_cl1_w
    5 => p5_cl1_w
    => 0
bool activeCl2d = switch activeProfile
    1 => p1_cl2_d
    2 => p2_cl2_d
    3 => p3_cl2_d
    4 => p4_cl2_d
    5 => p5_cl2_d
    => false
int activeCl2w = switch activeProfile
    1 => p1_cl2_w
    2 => p2_cl2_w
    3 => p3_cl2_w
    4 => p4_cl2_w
    5 => p5_cl2_w
    => 0
bool activeCl3d = switch activeProfile
    1 => p1_cl3_d
    2 => p2_cl3_d
    3 => p3_cl3_d
    4 => p4_cl3_d
    5 => p5_cl3_d
    => false
int activeCl3w = switch activeProfile
    1 => p1_cl3_w
    2 => p2_cl3_w
    3 => p3_cl3_w
    4 => p4_cl3_w
    5 => p5_cl3_w
    => 0
bool activeCl4d = switch activeProfile
    1 => p1_cl4_d
    2 => p2_cl4_d
    3 => p3_cl4_d
    4 => p4_cl4_d
    5 => p5_cl4_d
    => false
int activeCl4w = switch activeProfile
    1 => p1_cl4_w
    2 => p2_cl4_w
    3 => p3_cl4_w
    4 => p4_cl4_w
    5 => p5_cl4_w
    => 0
bool activeCl5d = switch activeProfile
    1 => p1_cl5_d
    2 => p2_cl5_d
    3 => p3_cl5_d
    4 => p4_cl5_d
    5 => p5_cl5_d
    => false
int activeCl5w = switch activeProfile
    1 => p1_cl5_w
    2 => p2_cl5_w
    3 => p3_cl5_w
    4 => p4_cl5_w
    5 => p5_cl5_w
    => 0
bool activeCl6d = switch activeProfile
    1 => p1_cl6_d
    2 => p2_cl6_d
    3 => p3_cl6_d
    4 => p4_cl6_d
    5 => p5_cl6_d
    => false
int activeCl6w = switch activeProfile
    1 => p1_cl6_w
    2 => p2_cl6_w
    3 => p3_cl6_w
    4 => p4_cl6_w
    5 => p5_cl6_w
    => 0
bool activeCl7d = switch activeProfile
    1 => p1_cl7_d
    2 => p2_cl7_d
    3 => p3_cl7_d
    4 => p4_cl7_d
    5 => p5_cl7_d
    => false
int activeCl7w = switch activeProfile
    1 => p1_cl7_w
    2 => p2_cl7_w
    3 => p3_cl7_w
    4 => p4_cl7_w
    5 => p5_cl7_w
    => 0
bool activeCl8d = switch activeProfile
    1 => p1_cl8_d
    2 => p2_cl8_d
    3 => p3_cl8_d
    4 => p4_cl8_d
    5 => p5_cl8_d
    => false
int activeCl8w = switch activeProfile
    1 => p1_cl8_w
    2 => p2_cl8_w
    3 => p3_cl8_w
    4 => p4_cl8_w
    5 => p5_cl8_w
    => 0
bool activeCl9d = switch activeProfile
    1 => p1_cl9_d
    2 => p2_cl9_d
    3 => p3_cl9_d
    4 => p4_cl9_d
    5 => p5_cl9_d
    => false
int activeCl9w = switch activeProfile
    1 => p1_cl9_w
    2 => p2_cl9_w
    3 => p3_cl9_w
    4 => p4_cl9_w
    5 => p5_cl9_w
    => 0
bool activeCl10d = switch activeProfile
    1 => p1_cl10_d
    2 => p2_cl10_d
    3 => p3_cl10_d
    4 => p4_cl10_d
    5 => p5_cl10_d
    => false
int activeCl10w = switch activeProfile
    1 => p1_cl10_w
    2 => p2_cl10_w
    3 => p3_cl10_w
    4 => p4_cl10_w
    5 => p5_cl10_w
    => 0
bool activeLv1en = switch activeProfile
    1 => p1_lv1_en
    2 => p2_lv1_en
    3 => p3_lv1_en
    4 => p4_lv1_en
    5 => p5_lv1_en
    => false
string activeLv1name = switch activeProfile
    1 => p1_lv1_name
    2 => p2_lv1_name
    3 => p3_lv1_name
    4 => p4_lv1_name
    5 => p5_lv1_name
    => ""
float activeLv1price = switch activeProfile
    1 => p1_lv1_price
    2 => p2_lv1_price
    3 => p3_lv1_price
    4 => p4_lv1_price
    5 => p5_lv1_price
    => 0.0
string activeLv1type = switch activeProfile
    1 => p1_lv1_type
    2 => p2_lv1_type
    3 => p3_lv1_type
    4 => p4_lv1_type
    5 => p5_lv1_type
    => "Custom"
bool activeLv2en = switch activeProfile
    1 => p1_lv2_en
    2 => p2_lv2_en
    3 => p3_lv2_en
    4 => p4_lv2_en
    5 => p5_lv2_en
    => false
string activeLv2name = switch activeProfile
    1 => p1_lv2_name
    2 => p2_lv2_name
    3 => p3_lv2_name
    4 => p4_lv2_name
    5 => p5_lv2_name
    => ""
float activeLv2price = switch activeProfile
    1 => p1_lv2_price
    2 => p2_lv2_price
    3 => p3_lv2_price
    4 => p4_lv2_price
    5 => p5_lv2_price
    => 0.0
string activeLv2type = switch activeProfile
    1 => p1_lv2_type
    2 => p2_lv2_type
    3 => p3_lv2_type
    4 => p4_lv2_type
    5 => p5_lv2_type
    => "Custom"
bool activeLv3en = switch activeProfile
    1 => p1_lv3_en
    2 => p2_lv3_en
    3 => p3_lv3_en
    4 => p4_lv3_en
    5 => p5_lv3_en
    => false
string activeLv3name = switch activeProfile
    1 => p1_lv3_name
    2 => p2_lv3_name
    3 => p3_lv3_name
    4 => p4_lv3_name
    5 => p5_lv3_name
    => ""
float activeLv3price = switch activeProfile
    1 => p1_lv3_price
    2 => p2_lv3_price
    3 => p3_lv3_price
    4 => p4_lv3_price
    5 => p5_lv3_price
    => 0.0
string activeLv3type = switch activeProfile
    1 => p1_lv3_type
    2 => p2_lv3_type
    3 => p3_lv3_type
    4 => p4_lv3_type
    5 => p5_lv3_type
    => "Custom"
bool activeLv4en = switch activeProfile
    1 => p1_lv4_en
    2 => p2_lv4_en
    3 => p3_lv4_en
    4 => p4_lv4_en
    5 => p5_lv4_en
    => false
string activeLv4name = switch activeProfile
    1 => p1_lv4_name
    2 => p2_lv4_name
    3 => p3_lv4_name
    4 => p4_lv4_name
    5 => p5_lv4_name
    => ""
float activeLv4price = switch activeProfile
    1 => p1_lv4_price
    2 => p2_lv4_price
    3 => p3_lv4_price
    4 => p4_lv4_price
    5 => p5_lv4_price
    => 0.0
string activeLv4type = switch activeProfile
    1 => p1_lv4_type
    2 => p2_lv4_type
    3 => p3_lv4_type
    4 => p4_lv4_type
    5 => p5_lv4_type
    => "Custom"
bool activeLv5en = switch activeProfile
    1 => p1_lv5_en
    2 => p2_lv5_en
    3 => p3_lv5_en
    4 => p4_lv5_en
    5 => p5_lv5_en
    => false
string activeLv5name = switch activeProfile
    1 => p1_lv5_name
    2 => p2_lv5_name
    3 => p3_lv5_name
    4 => p4_lv5_name
    5 => p5_lv5_name
    => ""
float activeLv5price = switch activeProfile
    1 => p1_lv5_price
    2 => p2_lv5_price
    3 => p3_lv5_price
    4 => p4_lv5_price
    5 => p5_lv5_price
    => 0.0
string activeLv5type = switch activeProfile
    1 => p1_lv5_type
    2 => p2_lv5_type
    3 => p3_lv5_type
    4 => p4_lv5_type
    5 => p5_lv5_type
    => "Custom"

float activeScore = f_calcScore(activeChecklist, activeCl1d, activeCl2d, activeCl3d, activeCl4d, activeCl5d, activeCl6d, activeCl7d, activeCl8d, activeCl9d, activeCl10d, activeCl1w, activeCl2w, activeCl3w, activeCl4w, activeCl5w, activeCl6w, activeCl7w, activeCl8w, activeCl9w, activeCl10w)
string scoreLabel = f_getScoreLabel(activeScore)
string scoreText = na(activeScore) ? "N/A" : str.tostring(int(math.round(activeScore))) + " / 100"
int clTotal = f_clCount(activeChecklist)
int clDone = f_clDoneCount(activeChecklist, activeCl1d, activeCl2d, activeCl3d, activeCl4d, activeCl5d, activeCl6d, activeCl7d, activeCl8d, activeCl9d, activeCl10d)
color biasCol = f_biasColor(activeBias)
color decisionCol = f_decisionColor(activeDecision)
[panelBg, panelText, modBg] = f_getTheme(themeMode)

color hdrCtx = color.new(color.rgb(56, 118, 190), 35)
color hdrCl = color.new(color.rgb(28, 150, 110), 35)
color hdrLv = color.new(color.rgb(130, 82, 175), 35)
color hdrDec = color.new(color.rgb(175, 78, 130), 35)
color hdrPlan = color.new(color.rgb(56, 118, 190), 35)
color hdrInv = color.new(color.rgb(190, 115, 55), 35)
color hdrTxt = color.new(color.white, 8)
color mutedTxt = color.new(panelText, 40)

var line lvLn1 = na
var line lvLn2 = na
var line lvLn3 = na
var line lvLn4 = na
var line lvLn5 = na
var label lvLb1 = na
var label lvLb2 = na
var label lvLb3 = na
var label lvLb4 = na
var label lvLb5 = na

bool shouldDraw = drawLevels and activeProfile > 0 and not showNoMatchMsg
[l1, b1] = f_updateLevelLine(lvLn1, lvLb1, activeLv1en, activeLv1price, activeLv1name, f_levelTypeColor(activeLv1type), levelStyle, levelExtend, shouldDraw, showLevelLabels)
[l2, b2] = f_updateLevelLine(lvLn2, lvLb2, activeLv2en, activeLv2price, activeLv2name, f_levelTypeColor(activeLv2type), levelStyle, levelExtend, shouldDraw, showLevelLabels)
[l3, b3] = f_updateLevelLine(lvLn3, lvLb3, activeLv3en, activeLv3price, activeLv3name, f_levelTypeColor(activeLv3type), levelStyle, levelExtend, shouldDraw, showLevelLabels)
[l4, b4] = f_updateLevelLine(lvLn4, lvLb4, activeLv4en, activeLv4price, activeLv4name, f_levelTypeColor(activeLv4type), levelStyle, levelExtend, shouldDraw, showLevelLabels)
[l5, b5] = f_updateLevelLine(lvLn5, lvLb5, activeLv5en, activeLv5price, activeLv5name, f_levelTypeColor(activeLv5type), levelStyle, levelExtend, shouldDraw, showLevelLabels)
lvLn1 := l1
lvLn2 := l2
lvLn3 := l3
lvLn4 := l4
lvLn5 := l5
lvLb1 := b1
lvLb2 := b2
lvLb3 := b3
lvLb4 := b4
lvLb5 := b5

bool crossLv1 = f_levelCross(activeLv1price, activeLv1en)
bool crossLv2 = f_levelCross(activeLv2price, activeLv2en)
bool crossLv3 = f_levelCross(activeLv3price, activeLv3en)
bool crossLv4 = f_levelCross(activeLv4price, activeLv4en)
bool crossLv5 = f_levelCross(activeLv5price, activeLv5en)
bool anyLevelCross = crossLv1 or crossLv2 or crossLv3 or crossLv4 or crossLv5
string crossedName = crossLv1 ? activeLv1name : crossLv2 ? activeLv2name : crossLv3 ? activeLv3name : crossLv4 ? activeLv4name : crossLv5 ? activeLv5name : ""
float crossedPrice = crossLv1 ? activeLv1price : crossLv2 ? activeLv2price : crossLv3 ? activeLv3price : crossLv4 ? activeLv4price : crossLv5 ? activeLv5price : na
bool invalidCross = (activeLv1type == "Invalidation" and crossLv1) or (activeLv2type == "Invalidation" and crossLv2) or (activeLv3type == "Invalidation" and crossLv3) or (activeLv4type == "Invalidation" and crossLv4) or (activeLv5type == "Invalidation" and crossLv5)

var table panel = table.new(position.top_left, COLS, MAX_ROWS, border_width = 0, border_color = color.new(color.gray, 100), frame_color = color.new(color.gray, 88), frame_width = 1)

if barstate.islast
    table.set_position(panel, f_getPosition(panelPosition))
    table.clear(panel, 0, 0, COLS - 1, MAX_ROWS - 1)
    if showPanel
        string sz = panelSize
        if showNoMatchMsg
            f_modCell(panel, 0, 0, COLS - 1, "No profile for " + syminfo.ticker + ". Set Symbol in a profile.", panelBg, panelText, sz, "L")
        else
            string pctTxt = na(activeScore) ? "0%" : str.tostring(int(math.round(activeScore))) + "%"
            int clHidden = math.max(clTotal - maxChecklistRows, 0)
            string clHdr = (useIcons ? "☑ " : "") + "CHECKLIST " + str.tostring(clDone) + "/" + str.tostring(clTotal) + " · " + pctTxt + " " + f_progressBar(activeScore)
            string modeTag = profileMode == "Manual" ? "M" : "A"

            table.cell(panel, 0, 0, (useIcons ? "▣ " : "") + "NOTEBOOK", bgcolor = panelBg, text_color = panelText, text_size = f_getTextSize(sz), text_halign = text.align_left)
            table.merge_cells(panel, 0, 0, 2, 0)
            table.cell(panel, 3, 0, str.upper(activeBias), bgcolor = color.new(biasCol, 82), text_color = biasCol, text_size = f_getTextSize(sz), text_halign = text.align_center)
            table.merge_cells(panel, 3, 0, 5, 0)
            table.cell(panel, 6, 0, activeDecision, bgcolor = color.new(decisionCol, 82), text_color = decisionCol, text_size = f_getTextSize(sz), text_halign = text.align_center)
            table.merge_cells(panel, 6, 0, 8, 0)
            table.cell(panel, 9, 0, scoreText, bgcolor = panelBg, text_color = panelText, text_size = f_getTextSize(sz), text_halign = text.align_right)
            table.merge_cells(panel, 9, 0, 11, 0)

            f_moduleHdr(panel, 1, 0, 3, (useIcons ? "◆ " : "") + "CONTEXT", hdrCtx, hdrTxt, sz)
            f_moduleHdr(panel, 1, 4, 7, clHdr, hdrCl, hdrTxt, sz)
            f_moduleHdr(panel, 1, 8, 11, (useIcons ? "⚿ " : "") + "LEVELS", hdrLv, hdrTxt, sz)


            int ctxLines = 0
            string[] ctxArr = str.split(activeContext, "\n")
            for i = 0 to MAX_CTX_SHOW - 1
                if array.size(ctxArr) > i and f_nonempty(str.trim(array.get(ctxArr, i)))
                    ctxLines += 1

            int clShow = math.min(clTotal, maxChecklistRows)
            int lvCount = 0
            for i = 0 to NUM_LEVELS - 1
                bool en = i == 0 ? activeLv1en : i == 1 ? activeLv2en : i == 2 ? activeLv3en : i == 3 ? activeLv4en : activeLv5en
                float pr = i == 0 ? activeLv1price : i == 1 ? activeLv2price : i == 2 ? activeLv3price : i == 3 ? activeLv4price : activeLv5price
                if en and pr > 0.0
                    lvCount += 1

            int bodyRows = math.max(math.max(ctxLines, clShow), lvCount)
            int clIdx = 0
            int lvIdx = 0

            for r = 0 to bodyRows - 1
                int row = 2 + r
                string ctxTxt = ""
                if r < ctxLines and array.size(ctxArr) > r
                    ctxTxt := f_trunc(str.trim(array.get(ctxArr, r)), 32)
                f_modCell(panel, row, 0, 3, ctxTxt, modBg, panelText, sz, "L")

                if clIdx < clShow
                    int seen = 0
                    string clTxt = ""
                    bool cld = false
                    for i = 0 to NUM_CL - 1
                        string clt = f_clLine(activeChecklist, i)
                        if f_nonempty(clt)
                            if seen == clIdx
                                clTxt := f_trunc(clt, CL_TEXT_MAX)
                                cld := f_getDone(i, activeCl1d, activeCl2d, activeCl3d, activeCl4d, activeCl5d, activeCl6d, activeCl7d, activeCl8d, activeCl9d, activeCl10d)
                                break
                            seen += 1
                    table.cell(panel, 4, row, f_iconCheck(cld), bgcolor = modBg, text_color = f_iconCheckColor(cld), text_size = f_getTextSize(sz), text_halign = text.align_center)
                    table.cell(panel, 5, row, clTxt, bgcolor = modBg, text_color = panelText, text_size = f_getTextSize(sz), text_halign = text.align_left)
                    table.merge_cells(panel, 5, row, 7, row)
                    clIdx += 1
                else
                    f_padMod(panel, row, 4, 7, modBg)

                if lvIdx < lvCount
                    int seenLv = 0
                    string lvName = ""
                    string lvPrice = ""
                    color lvCol = panelText
                    for i = 0 to NUM_LEVELS - 1
                        bool en = i == 0 ? activeLv1en : i == 1 ? activeLv2en : i == 2 ? activeLv3en : i == 3 ? activeLv4en : activeLv5en
                        string nm = i == 0 ? activeLv1name : i == 1 ? activeLv2name : i == 2 ? activeLv3name : i == 3 ? activeLv4name : activeLv5name
                        float pr = i == 0 ? activeLv1price : i == 1 ? activeLv2price : i == 2 ? activeLv3price : i == 3 ? activeLv4price : activeLv5price
                        string tp = i == 0 ? activeLv1type : i == 1 ? activeLv2type : i == 2 ? activeLv3type : i == 3 ? activeLv4type : activeLv5type
                        if en and pr > 0.0
                            if seenLv == lvIdx
                                lvName := f_trunc(nm, 14)
                                lvPrice := str.tostring(pr, format.mintick)
                                lvCol := f_levelTypeColor(tp)
                                break
                            seenLv += 1
                    table.cell(panel, 8, row, lvName, bgcolor = modBg, text_color = panelText, text_size = f_getTextSize(sz), text_halign = text.align_left)
                    table.merge_cells(panel, 8, row, 9, row)
                    table.cell(panel, 10, row, lvPrice, bgcolor = modBg, text_color = lvCol, text_size = f_getTextSize(sz), text_halign = text.align_right)
                    table.merge_cells(panel, 10, row, 11, row)
                    lvIdx += 1
                else
                    f_padMod(panel, row, 8, 11, modBg)

            int footRow = 2 + bodyRows
            if clHidden > 0
                f_modCell(panel, footRow, 4, 7, "+" + str.tostring(clHidden) + " more items", modBg, mutedTxt, "Tiny", "L")
                footRow += 1

            f_moduleHdr(panel, footRow, 0, 3, (useIcons ? "✎ " : "") + "DECISION", hdrDec, hdrTxt, sz)
            f_moduleHdr(panel, footRow, 4, 7, (useIcons ? "▤ " : "") + "PLAN", hdrPlan, hdrTxt, sz)
            f_moduleHdr(panel, footRow, 8, 11, (useIcons ? "⚠ " : "") + "INVALID", hdrInv, hdrTxt, sz)

            table.cell(panel, 0, footRow + 1, activeDecision, bgcolor = modBg, text_color = decisionCol, text_size = f_getTextSize(sz), text_halign = text.align_center)
            table.merge_cells(panel, 0, footRow + 1, 3, footRow + 1)

            string planLine1 = ""
            string planLine2 = ""
            if f_nonempty(activePlan)
                string[] planLines = str.split(activePlan, "\n")
                if array.size(planLines) > 0
                    planLine1 := f_trunc(str.trim(array.get(planLines, 0)), 42)
                if array.size(planLines) > 1
                    planLine2 := f_trunc(str.trim(array.get(planLines, 1)), 42)
            f_modCell(panel, footRow + 1, 4, 7, planLine1, modBg, panelText, sz, "L")
            if f_nonempty(planLine2)
                f_modCell(panel, footRow + 2, 4, 7, planLine2, modBg, mutedTxt, sz, "L")
            f_modCell(panel, footRow + 1, 8, 11, activeInvalid, modBg, color.rgb(230, 140, 70), sz, "L")

            int metaRow = f_nonempty(planLine2) ? footRow + 3 : footRow + 2
            string meta = syminfo.ticker + " · " + timeframe.period + " · " + modeTag + str.tostring(activeProfile) + " · " + activeTitle + " · " + scoreLabel
            table.cell(panel, 0, metaRow, meta, bgcolor = panelBg, text_color = mutedTxt, text_size = size.tiny, text_halign = text.align_left)
            table.merge_cells(panel, 0, metaRow, 11, metaRow)

bool scoreAlert = enableScoreAlert and not na(activeScore) and activeScore >= scoreThreshold
bool readyAlert = enableDecisionAlert and activeDecision == "Ready"
bool triggeredAlert = enableDecisionAlert and activeDecision == "Triggered"
alertcondition(scoreAlert, "Notebook Score Threshold", "Trading Notebook: score threshold reached.")
alertcondition(readyAlert, "Notebook Decision Ready", "Trading Notebook: decision status is Ready.")
alertcondition(triggeredAlert, "Notebook Decision Triggered", "Trading Notebook: decision status is Triggered.")
if enableLevelCrossAlert and anyLevelCross
    alert("Notebook Level Cross | " + syminfo.ticker + " " + timeframe.period + " | P" + str.tostring(activeProfile) + " | " + crossedName + " @ " + str.tostring(crossedPrice, format.mintick), alert.freq_once_per_bar_close)
if enableInvalidationAlert and invalidCross
    alert("Notebook Invalidation Cross | " + syminfo.ticker + " " + timeframe.period + " | P" + str.tostring(activeProfile), alert.freq_once_per_bar_close)
````
