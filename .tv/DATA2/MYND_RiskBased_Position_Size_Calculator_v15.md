<!-- tradingview-pine-id: PUB;2d83c0d7a1f543b6825c64c4dda68f16 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MYND Risk-Based Position Size Calculator [v1.5]

Source: https://www.tradingview.com/script/dyQbUVmQ-MYND-Risk-Based-Position-Size-Calculator-v1-5/

## Description

MYND Risk-Based Position Size Calculator [v1.5]

A standalone position-sizing calculator with 3 selectable risk philosophies - Fixed % Risk, Van Tharp R-Multiple/Expectancy, and Kelly Criterion - plus an optional Break-Even Trigger, a 3-tier Partial Profit-Taking Ladder, a Losing-Streak Survivability estimate, a Risk:Reward Ratio readout, live milestone status tags, a live P&L row, and a ladder allocation check.

WHAT IT DOES

Answers "given my account, my entry, my stop, and my chosen risk philosophy, how many shares/contracts should I actually put on" - a calculator, not another chart signal.

HOW IT WORKS

Fixed % Risk is the industry-standard baseline: position size = (Account Equity x Risk%) / Stop Distance. Van Tharp R-Multiple/Expectancy uses the same math but gates it on a positive Expectancy first, computed from your own supplied Win Rate / Average Win (R) / Average Loss (R) via Van Tharp's textbook formula. Kelly Criterion computes a dynamic risk% from your supplied Win Rate and Win/Loss Ratio using the classic f* = p - q/b formula, applied within the same stop-distance sizing formula (a disclosed practitioner adaptation, not a literal full-bankroll wager), with a Kelly Fraction Multiplier (Half-Kelly by default) on top.

This tool has NO access to your actual trade history - it is not a strategy backtester. The Van Tharp, Kelly, and Losing-Streak Survivability inputs are numbers you supply from your own trading record.

KEY FEATURES

A live dashboard showing every step of the calculation, including live status tags and P&L. A Max Position Size safety cap always applied on top of whichever mode's raw output. Up to 7 reference lines plotted directly on the chart, each with an optional price label. Full Total Control, Light/Dark/Custom theme plus a Colorblind-Safe Okabe-Ito palette, full tooltip coverage on every non-obvious setting, and Combo Alert Bundling.

HOW TO USE IT

Set your Account Equity, Direction, Entry Price, and Stop Method. For an actual open trade, set a fixed Entry Price so Live P&L and the [REACHED] tags mean something. Start with Fixed % Risk if you don't have reliable win-rate/R-multiple stats yet. Check the Risk:Reward Ratio and Ladder Allocation Check rows as quick sanity checks. Turn on the Partial Ladder if you scale out of positions, and the Break-Even Trigger if you follow a move-to-break-even habit.

SETTINGS WORTH TUNING FIRST

Account Equity + Risk % of Equity Per Trade. Max Position Size (% of Equity). Entry Price - fixed vs. 0/live close. Risk % Warning Threshold. Partial Ladder Tier R-Multiples/%. Milestone Status Lookback (bars) - increase for trades held longer than 100 bars.

ALERTS

11 individual alertcondition()s (Negative Expectancy Warning, No Kelly Edge Warning, Position Capped by Max Size, Zero Stop Distance Warning, High Risk % Warning, Ladder Over-Allocated Warning, Break-Even Trigger Reached, Take-Profit Target Reached, Partial Ladder Tier 1/2/3 Reached) plus 2 combo bundles (ALL Risk Warnings, ALL Trade Management Milestones).

This tool does not evaluate whether any trade is a good idea - every number is a mechanical consequence of the inputs you provide, and the Van Tharp/Kelly/Streak-Survivability inputs are only as good as your own supplied historical stats. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator("MYND Risk-Based Position Size Calculator [v1.5]", shorttitle="MYND Position Calc v1.5", overlay=true, max_lines_count=10, max_labels_count=10)

// =====================================================================================

//
// HONEST SCOPE: this tool has NO access to your actual trade history (it is not a
// strategy backtester) - Win Rate/Avg Win R/Avg Loss R/Win-Loss Ratio in Modes 2 and 3,
// and the win rate used for the Losing-Streak Survivability estimate, are values YOU
// supply from your own trading record or a separate MYND backtest (e.g. a strategy()
// companion's Strategy Tester report). Garbage in, garbage out - stated directly rather
// than implied to be computed from anything real.
//
// A Max Position Size safety cap (% of equity) is always applied on top of whichever
// mode's raw output, regardless of mode, so a degenerate tiny stop distance can never
// produce an absurdly large, account-risking position size.
//
// STANDARDS: Total Control, Theme & Accessibility (Light/Dark/Custom + Colorblind-Safe
// Okabe-Ito), Tooltip Coverage, Combo Alert Bundling, Full Pre-Delivery Review.
// =====================================================================================

// ---------------------------- INPUTS: ACCOUNT & RISK ----------------------------
grpAcct = "Account & Risk"
accountEquity = input.float(10000.0, "Account Equity ($)", minval=1, group=grpAcct, tooltip="Your total account value. All sizing math scales off this number.")
riskPct = input.float(1.0, "Risk % of Equity Per Trade", minval=0.01, step=0.1, group=grpAcct, tooltip="Used directly in Fixed % Risk mode, and as the underlying risk% in Van Tharp mode when Expectancy is positive. Ignored in Kelly Criterion mode (Kelly computes its own dynamic risk% instead).")
maxPositionPct = input.float(25.0, "Max Position Size (% of Equity), Safety Cap", minval=1, group=grpAcct, tooltip="Always applied on top of whichever mode's raw position size, regardless of mode - protects against a degenerate tiny stop distance producing an absurdly large position. Lower this for a stricter cap.")
currencySymbol = input.string("$", "Currency Symbol (display only)", group=grpAcct, tooltip="Cosmetic only - changes the symbol shown on the dashboard, does not convert any values.")
enableRiskPctWarning = input.bool(true, "Warn When Risk % Exceeds Threshold", group=grpAcct)
riskWarnThresholdPct = input.float(2.0, "Risk % Warning Threshold", minval=0.1, step=0.1, group=grpAcct, tooltip="A soft, non-blocking warning shown on the dashboard (and its own alert) when Risk % of Equity Per Trade above is set higher than this value - a commonly-cited prudent ceiling, not a hard rule. Adjust to whatever fits your own risk tolerance.")

// ---------------------------- INPUTS: TRADE SETUP ----------------------------
grpTrade = "Trade Setup"
direction = input.string("Long", "Direction", options=["Long", "Short"], group=grpTrade)
entryPriceInput = input.float(0.0, "Entry Price (0 = use current chart Close)", minval=0, group=grpTrade)
stopModeIn = input.string("Manual Stop Price", "Stop Method", options=["Manual Stop Price", "ATR-Based Stop", "% Distance Stop"], group=grpTrade, tooltip="Manual: type your own stop price below. ATR-Based: the stop is computed automatically as (ATR x ATR Stop Multiple) away from the Entry Price. % Distance: the stop is placed a fixed % away from the Entry Price. Both automatic modes use the direction that makes sense for Direction below.")
stopPriceInput = input.float(0.0, "Manual Stop Price (used when Stop Method = Manual)", minval=0, group=grpTrade)
atrLen = input.int(14, "ATR Length (used when Stop Method = ATR-Based)", minval=1, group=grpTrade)
atrMult = input.float(2.0, "ATR Stop Multiple (used when Stop Method = ATR-Based)", minval=0.1, step=0.1, group=grpTrade)
stopPctInput = input.float(3.0, "Stop Distance % (used when Stop Method = % Distance Stop)", minval=0.01, step=0.1, group=grpTrade, tooltip="Stop is placed this % away from Entry Price, in the direction that makes sense for Direction below - e.g. 3.0 with Direction=Long places the stop 3% below entry.")
contractMultiplier = input.float(1.0, "Contract/Share Multiplier", minval=0.0001, step=0.5, group=grpTrade, tooltip="Set above 1.0 for instruments where one unit represents more than $1 of price movement per point (e.g. a futures contract's point value, or 100 for a standard equity option contract). Leave at 1.0 for stocks/ETFs/spot forex/crypto sized in plain units.")
roundToWhole = input.bool(true, "Round Position Size to Whole Units", group=grpTrade, tooltip="On (default): rounds down to the nearest whole share/contract - appropriate for stocks and futures. Turn off for instruments that support fractional sizing (many crypto venues, some fractional-share brokers).")

// ---------------------------- INPUTS: POSITION SIZING MODE ----------------------------
grpMode = "Position Sizing Mode"
sizingMode = input.string("Fixed % Risk", "Sizing Mode", options=["Fixed % Risk", "Van Tharp R-Multiple/Expectancy", "Kelly Criterion"], group=grpMode, tooltip="Fixed % Risk: the industry-standard baseline. Van Tharp: same math, gated on a positive Expectancy computed from your own supplied trade stats. Kelly Criterion: computes its own dynamic risk% from your supplied win rate/win-loss ratio instead of using Risk % of Equity above.")
targetRMultiple = input.float(2.0, "Take-Profit Target (R-multiple)", minval=0, group=grpMode, tooltip="The take-profit reference price is shown at this many multiples of your stop distance from the entry, in the profitable direction - a common minimum reward:risk target, not auto-executed.")
breakEvenEnable = input.bool(true, "Show Break-Even Trigger Reference", group=grpMode)
breakEvenRMultiple = input.float(1.0, "Break-Even Trigger (R-multiple)", minval=0.1, step=0.1, group=grpMode, tooltip="A common practitioner habit is moving the stop to break-even once price reaches some R-multiple of profit. This shows that reference price and fires an alert only - it never moves a real order.")

// ---------------------------- INPUTS: VAN THARP R-MULTIPLE/EXPECTANCY MODE ----------------------------
grpTharp = "Van Tharp R-Multiple/Expectancy Mode (you supply these from your own trading record)"
histWinRate = input.float(50.0, "Historical Win Rate (%)", minval=0, maxval=100, group=grpTharp, tooltip="Your OWN supplied win rate for this system/setup - this tool has no access to your actual trade history.")
histAvgWinR = input.float(2.0, "Average Win (R-multiple)", minval=0, group=grpTharp, tooltip="Your average winning trade's size, expressed in multiples of R (your own initial risk per trade).")
histAvgLossR = input.float(1.0, "Average Loss (R-multiple, positive number)", minval=0, group=grpTharp, tooltip="Your average losing trade's size, expressed as a POSITIVE multiple of R (e.g. 1.0 if losers average a full stop-out).")

// ---------------------------- INPUTS: KELLY CRITERION MODE ----------------------------
grpKelly = "Kelly Criterion Mode (you supply these from your own trading record)"
kellyWinRate = input.float(50.0, "Kelly: Win Rate (%)", minval=0, maxval=100, group=grpKelly)
kellyWinLossRatio = input.float(2.0, "Kelly: Win/Loss Ratio (avg win $ / avg loss $)", minval=0.01, group=grpKelly, tooltip="Average winning trade's dollar size divided by average losing trade's dollar size (Kelly's 'b' term).")
kellyFractionMult = input.float(0.5, "Kelly Fraction Multiplier", minval=0, maxval=1, step=0.05, group=grpKelly, tooltip="Full Kelly (1.0) is mathematically optimal for long-run growth but produces large, psychologically brutal drawdowns. Half-Kelly (0.5, the default) is the standard practitioner adjustment - trades some growth for materially less volatility. Set to 1.0 for full Kelly.")

// ---------------------------- INPUTS: PARTIAL PROFIT-TAKING LADDER ----------------------------
grpLadder = "Partial Profit-Taking Ladder"
enablePartialLadder = input.bool(true, "Enable Partial Profit-Taking Ladder", group=grpLadder)
tier1Enable = input.bool(true, "Tier 1: Enable", group=grpLadder)
tier1R = input.float(1.5, "Tier 1: R-Multiple", minval=0.1, step=0.1, group=grpLadder, tooltip="Take-profit reference price for this tier, expressed as a multiple of your stop distance from entry - not auto-executed. Defaults to 1.5R (deliberately offset from the 1R Break-Even level) so it doesn't sit exactly on top of another line out of the box.")
tier1Pct = input.float(33.0, "Tier 1: % of Position to Close", minval=0, maxval=100, step=1, group=grpLadder, tooltip="What % of your full computed position size this tier represents. The 3 tiers are independent - they don't have to add up to 100%.")
tier2Enable = input.bool(true, "Tier 2: Enable", group=grpLadder)
tier2R = input.float(2.5, "Tier 2: R-Multiple", minval=0.1, step=0.1, group=grpLadder, tooltip="Defaults to 2.5R (deliberately offset from the 2R Take-Profit Target) so it doesn't sit exactly on top of another line out of the box.")
tier2Pct = input.float(33.0, "Tier 2: % of Position to Close", minval=0, maxval=100, step=1, group=grpLadder)
tier3Enable = input.bool(true, "Tier 3: Enable", group=grpLadder)
tier3R = input.float(3.5, "Tier 3: R-Multiple", minval=0.1, step=0.1, group=grpLadder)
tier3Pct = input.float(34.0, "Tier 3: % of Position to Close", minval=0, maxval=100, step=1, group=grpLadder)

// ---------------------------- INPUTS: LOSING-STREAK SURVIVABILITY ----------------------------
grpStreak = "Losing-Streak Survivability"
showStreakRisk = input.bool(true, "Show Losing-Streak Survivability", group=grpStreak)
streakDrawdownThresholdPct = input.float(20.0, "Drawdown Threshold to Model (% of Equity)", minval=1, step=1, group=grpStreak, tooltip="A simple, non-compounding estimate: how many consecutive full losses (at your current effective risk % per trade) it would take to reach this much account drawdown. Not a formal probability-of-ruin model - just a plain-arithmetic reality check.")
streakWinRateInput = input.float(50.0, "Win Rate Used for This Estimate (%)", minval=0, maxval=100, step=1, group=grpStreak, tooltip="Can mirror your Van Tharp or Kelly win rate above, or be set independently - used only for the streak-probability estimate below, which assumes independent trade outcomes.")

// ---------------------------- INPUTS: THEME & ACCESSIBILITY ----------------------------
themeMode = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group="Theme & Accessibility")
colorblindMode = input.bool(false, "Colorblind-Safe Signal Colors", group="Theme & Accessibility", tooltip="Overrides Bullish/Bearish/Warning colors to the Okabe-Ito palette regardless of Theme Preset.")

// ---------------------------- INPUTS: DISPLAY ----------------------------
showTable = input.bool(true, "Show Dashboard Table", group="Display")
tablePosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display")
tableSizeIn = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Table Header Background", group="Display")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Table Header Text", group="Display")
bullishColorCustom = input.color(color.new(color.lime, 0), "Custom Bullish/Good Color", group="Display", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe is off.")
bearishColorCustom = input.color(color.new(color.red, 0), "Custom Bearish/Warning Color", group="Display", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe is off.")
showPriceLines = input.bool(true, "Show Entry/Stop/Target Lines on Chart", group="Display")
showBreakEvenLine = input.bool(true, "Show Break-Even Line on Chart", group="Display")
showLadderLines = input.bool(true, "Show Partial Ladder Lines on Chart", group="Display")
refLineStyleIn = input.string("Solid", "Reference Line Style (Entry/Stop/Target/BE/Ladder)", options=["Solid", "Dashed", "Dotted"], group="Display", tooltip="Applies to every reference level drawn on the chart - Entry, Stop, Take-Profit Target, Break-Even Trigger, and all 3 Partial Ladder tiers.")
refLineWidth = input.int(2, "Reference Line Width", minval=1, maxval=5, group="Display")
refLineAnchorBars = input.int(15, "Reference Line Left Anchor (bars back)", minval=1, maxval=200, group="Display", tooltip="How many bars back each reference level's visible segment starts before it projects forward (right) from the current price. Cosmetic only - doesn't change any calculation.")
showLineLabels = input.bool(true, "Show Price Labels on Reference Lines", group="Display", tooltip="Adds a small text tag (name + price) at the right end of every reference line, so the chart is self-explanatory without the dashboard open alongside it. Each label's color matches its line's color, which is already fully adjustable above.")
lineLabelSizeIn = input.string("Small", "Reference Line Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
showMilestoneStatus = input.bool(true, "Show Live Milestone Status ([REACHED] tags)", group="Display", tooltip="Tags the Take-Profit Target, Break-Even Trigger, and each Ladder Tier row with [REACHED] once price has touched that level within the Milestone Status Lookback below. Most meaningful when Entry Price is set to a fixed value rather than left at 0 (live close) - with a live-following entry, every reference level recomputes each bar too, making 'reached' less meaningful.")
milestoneLookbackBars = input.int(100, "Milestone Status Lookback (bars)", minval=1, maxval=2000, group="Display", tooltip="How many bars back to check whether price has already touched a reference level, for the [REACHED] tags above. Increase for a trade held longer than the default 100 bars.")
showLivePnL = input.bool(true, "Show Live P&L (if in trade)", group="Display", tooltip="Adds a dashboard row showing current unrealized profit (close vs. Entry Price) in $ and R-multiples. Shows N/A when Entry Price is left at 0, since entryPrice equals close by definition in that case and P&L would always read exactly zero - not a real breakeven reading.")
showLadderAllocationCheck = input.bool(true, "Show Ladder Allocation Check", group="Display", tooltip="Adds a dashboard row totaling your enabled Ladder tiers' % of Position to Close, flagging OVER 100% if they exceed a full position. Also adds its own alert, folded into the ALL Risk Warnings combo.")
breakEvenLineColorCustom = input.color(color.new(color.blue, 0), "Break-Even Line Color", group="Display")
tier1LineColorCustom = input.color(color.new(color.yellow, 0), "Ladder Tier 1 Line Color", group="Display")
tier2LineColorCustom = input.color(color.new(color.orange, 0), "Ladder Tier 2 Line Color", group="Display")
tier3LineColorCustom = input.color(color.new(color.fuchsia, 0), "Ladder Tier 3 Line Color", group="Display")
priceDecimals = input.int(2, "Price Decimal Places (dashboard)", minval=0, maxval=6, group="Display", tooltip="How many decimals to show for Entry/Stop/Target/Break-Even/Ladder prices on the dashboard. Lower this for higher-priced stocks to keep the table narrower; raise it for forex/crypto/low-priced tickers that need more precision. Does not affect the actual math, only the display.")

// =====================================================================================
// THEME RESOLUTION
// =====================================================================================
lightHeaderBg = color.new(color.navy, 0)
lightHeaderText = color.new(color.white, 0)
lightBullish = color.new(color.green, 0)
lightBearish = color.new(color.red, 0)
lightNeutral = color.new(color.gray, 0)

darkHeaderBg = color.new(#1A1F2E, 0)
darkHeaderText = color.new(#E0E0E0, 0)
darkBullish = color.new(#26A69A, 0)
darkBearish = color.new(#EF5350, 0)
darkNeutral = color.new(#787B86, 0)

cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)

headerBgColor = themeMode == "Custom" ? headerBgColorCustom : themeMode == "Dark" ? darkHeaderBg : lightHeaderBg
headerTextColor = themeMode == "Custom" ? headerTextColorCustom : themeMode == "Dark" ? darkHeaderText : lightHeaderText
neutralColor = themeMode == "Dark" ? darkNeutral : lightNeutral
baseBullishColor = themeMode == "Custom" ? bullishColorCustom : themeMode == "Dark" ? darkBullish : lightBullish
baseBearishColor = themeMode == "Custom" ? bearishColorCustom : themeMode == "Dark" ? darkBearish : lightBearish
bullishColor = colorblindMode ? cbBullish : baseBullishColor
bearishColor = colorblindMode ? cbBearish : baseBearishColor

refLineStyleConst = refLineStyleIn == "Solid" ? line.style_solid : refLineStyleIn == "Dashed" ? line.style_dashed : line.style_dotted
lineLabelSizeConst = lineLabelSizeIn == "Tiny" ? size.tiny : lineLabelSizeIn == "Small" ? size.small : lineLabelSizeIn == "Large" ? size.large : lineLabelSizeIn == "Huge" ? size.huge : size.normal

// f_fmt: formats a price using a literal format mask selected by the Price Decimal Places
// input - each branch is a fully self-contained str.tostring() call with its own const
// format string, so this is safe to call anywhere (same pattern already proven in this
// file's modeDetailTxt/warnTxt ternary chains). v1.4: switched from "#"-style masks to
// "0"-style masks so trailing zeros are always shown (e.g. "34.70" not "34.7").
f_fmt(_val) => priceDecimals <= 0 ? str.tostring(_val, "0") : priceDecimals == 1 ? str.tostring(_val, "0.0") : priceDecimals == 2 ? str.tostring(_val, "0.00") : priceDecimals == 3 ? str.tostring(_val, "0.000") : priceDecimals == 4 ? str.tostring(_val, "0.0000") : priceDecimals == 5 ? str.tostring(_val, "0.00000") : str.tostring(_val, "0.000000")

// =====================================================================================
// CORE CALCULATION
// =====================================================================================
entryPrice = entryPriceInput > 0 ? entryPriceInput : close
atrVal = ta.atr(atrLen)
// v1.5: computed unconditionally every bar (never inside a conditional/ternary), matching
// this project's ta.*-safety standard already established for atrVal above.
milestoneHighest = ta.highest(high, milestoneLookbackBars)
milestoneLowest = ta.lowest(low, milestoneLookbackBars)
atrStopPrice = direction == "Long" ? entryPrice - atrVal * atrMult : entryPrice + atrVal * atrMult
pctStopPrice = direction == "Long" ? entryPrice * (1.0 - stopPctInput / 100.0) : entryPrice * (1.0 + stopPctInput / 100.0)
stopPrice = stopModeIn == "ATR-Based Stop" ? atrStopPrice : stopModeIn == "% Distance Stop" ? pctStopPrice : (stopPriceInput > 0 ? stopPriceInput : atrStopPrice)
stopDistance = math.abs(entryPrice - stopPrice)
stopDistancePct = entryPrice > 0 ? stopDistance / entryPrice * 100.0 : 0.0

targetPrice = direction == "Long" ? entryPrice + stopDistance * targetRMultiple : entryPrice - stopDistance * targetRMultiple
breakEvenTriggerPrice = direction == "Long" ? entryPrice + stopDistance * breakEvenRMultiple : entryPrice - stopDistance * breakEvenRMultiple

// ---- Risk:Reward Ratio (Target distance / Stop distance) ----
rewardDistance = math.abs(targetPrice - entryPrice)
rrRatio = stopDistance > 0 ? rewardDistance / stopDistance : 0.0

tier1Price = direction == "Long" ? entryPrice + stopDistance * tier1R : entryPrice - stopDistance * tier1R
tier2Price = direction == "Long" ? entryPrice + stopDistance * tier2R : entryPrice - stopDistance * tier2R
tier3Price = direction == "Long" ? entryPrice + stopDistance * tier3R : entryPrice - stopDistance * tier3R

// ---- Van Tharp Expectancy (R per trade) ----
winRateFrac = histWinRate / 100.0
expectancyR = winRateFrac * histAvgWinR - (1.0 - winRateFrac) * histAvgLossR
tharpHasEdge = expectancyR > 0.0

// ---- Kelly Criterion (f* = p - q/b) ----
kellyP = kellyWinRate / 100.0
kellyQ = 1.0 - kellyP
kellyRaw = kellyWinLossRatio > 0 ? kellyP - kellyQ / kellyWinLossRatio : 0.0
kellyHasEdge = kellyRaw > 0.0
kellyEffective = math.max(0.0, kellyRaw) * kellyFractionMult

// ---- Risk dollar amount by mode ----
riskDollarAmount = sizingMode == "Fixed % Risk" ? accountEquity * riskPct / 100.0 : sizingMode == "Van Tharp R-Multiple/Expectancy" ? (tharpHasEdge ? accountEquity * riskPct / 100.0 : 0.0) : (kellyHasEdge ? accountEquity * kellyEffective : 0.0)

// ---- Raw position size, then Max Position Size safety cap, then rounding ----
rawSizeUnits = stopDistance > 0 and contractMultiplier > 0 ? riskDollarAmount / (stopDistance * contractMultiplier) : 0.0
rawPositionDollarValue = rawSizeUnits * entryPrice * contractMultiplier
maxPositionDollar = accountEquity * maxPositionPct / 100.0
cappedByMax = rawPositionDollarValue > maxPositionDollar and entryPrice > 0 and contractMultiplier > 0
sizeUnitsPreRound = cappedByMax ? maxPositionDollar / (entryPrice * contractMultiplier) : rawSizeUnits
sizeUnits = roundToWhole ? math.floor(sizeUnitsPreRound) : sizeUnitsPreRound
positionDollarValue = sizeUnits * entryPrice * contractMultiplier
pctOfEquityUsed = accountEquity > 0 ? positionDollarValue / accountEquity * 100.0 : 0.0
actualDollarRisked = sizeUnits * stopDistance * contractMultiplier

// ---- Live P&L (v1.5) - close vs. Entry Price, in $ and R-multiples ----
livePnLPoints = direction == "Long" ? close - entryPrice : entryPrice - close
livePnLR = stopDistance > 0 ? livePnLPoints / stopDistance : 0.0
livePnLDollar = livePnLPoints * sizeUnits * contractMultiplier

// ---- Ladder Allocation Check (v1.5) ----
ladderTotalPct = (enablePartialLadder and tier1Enable ? tier1Pct : 0.0) + (enablePartialLadder and tier2Enable ? tier2Pct : 0.0) + (enablePartialLadder and tier3Enable ? tier3Pct : 0.0)
ladderOverAllocated = enablePartialLadder and ladderTotalPct > 100.0

// ---- Live Milestone Status (v1.5) - windowed check, DISPLAY ONLY, distinct from the
// single-bar-crossing booleans below used for alertcondition ----
targetReachedDisp = direction == "Long" ? milestoneHighest >= targetPrice : milestoneLowest <= targetPrice
beReachedDisp = direction == "Long" ? milestoneHighest >= breakEvenTriggerPrice : milestoneLowest <= breakEvenTriggerPrice
tier1ReachedDisp = direction == "Long" ? milestoneHighest >= tier1Price : milestoneLowest <= tier1Price
tier2ReachedDisp = direction == "Long" ? milestoneHighest >= tier2Price : milestoneLowest <= tier2Price
tier3ReachedDisp = direction == "Long" ? milestoneHighest >= tier3Price : milestoneLowest <= tier3Price

f_reachedTag(_reached) => showMilestoneStatus and _reached ? "  [REACHED]" : ""

// ---- Partial Ladder tier sizes (based on the final computed position size) ----
tier1UnitsRaw = sizeUnits * tier1Pct / 100.0
tier2UnitsRaw = sizeUnits * tier2Pct / 100.0
tier3UnitsRaw = sizeUnits * tier3Pct / 100.0
tier1Units = roundToWhole ? math.floor(tier1UnitsRaw) : tier1UnitsRaw
tier2Units = roundToWhole ? math.floor(tier2UnitsRaw) : tier2UnitsRaw
tier3Units = roundToWhole ? math.floor(tier3UnitsRaw) : tier3UnitsRaw

// ---- Losing-Streak Survivability (simple, disclosed estimate - not a formal ruin model) ----
effectiveRiskPctForStreak = accountEquity > 0 ? riskDollarAmount / accountEquity * 100.0 : 0.0
streakHasValidRisk = effectiveRiskPctForStreak > 0.0
streakLossesToThreshold = streakHasValidRisk ? math.floor(streakDrawdownThresholdPct / effectiveRiskPctForStreak) : 0.0
streakProbability = streakHasValidRisk ? math.pow(1.0 - streakWinRateInput / 100.0, streakLossesToThreshold) : 0.0

// =====================================================================================
// RISK WARNINGS
// =====================================================================================
negativeExpectancyWarning = sizingMode == "Van Tharp R-Multiple/Expectancy" and not tharpHasEdge
noKellyEdgeWarning = sizingMode == "Kelly Criterion" and not kellyHasEdge
zeroStopWarning = stopDistance <= 0
highRiskPctWarning = enableRiskPctWarning and riskPct > riskWarnThresholdPct
anyRiskWarning = negativeExpectancyWarning or noKellyEdgeWarning or cappedByMax or zeroStopWarning or highRiskPctWarning or ladderOverAllocated

// =====================================================================================
// TRADE MANAGEMENT MILESTONE ALERTS (price-driven, not ta./request.-based)
// =====================================================================================
breakEvenReached = breakEvenEnable and (direction == "Long" and high >= breakEvenTriggerPrice or direction == "Short" and low <= breakEvenTriggerPrice)
tier1Reached = enablePartialLadder and tier1Enable and (direction == "Long" and high >= tier1Price or direction == "Short" and low <= tier1Price)
tier2Reached = enablePartialLadder and tier2Enable and (direction == "Long" and high >= tier2Price or direction == "Short" and low <= tier2Price)
tier3Reached = enablePartialLadder and tier3Enable and (direction == "Long" and high >= tier3Price or direction == "Short" and low <= tier3Price)
targetReached = direction == "Long" and high >= targetPrice or direction == "Short" and low <= targetPrice
anyMilestoneReached = breakEvenReached or tier1Reached or tier2Reached or tier3Reached or targetReached

// =====================================================================================
// CHART LINES (reference only - entry/stop/target/break-even/ladder)
// Drawn as line.new() horizontal rays, redrawn on the last bar only, extended right from
// a short anchor - one stable current level per line, nothing plotted into history.
// =====================================================================================
var line entryLine = na
var line stopLine = na
var line targetLine = na
var line beLine = na
var line tier1Line = na
var line tier2Line = na
var line tier3Line = na

// v1.4: one label per line, same delete-then-redraw pattern, proven already in this
// suite's Liquidity Sweep/Reclaim Engine tool (label.style_label_left with a var handle).
var label entryLabel = na
var label stopLabel = na
var label targetLabel = na
var label beLabel = na
var label tier1Label = na
var label tier2Label = na
var label tier3Label = na

if barstate.islast
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(targetLine)
    line.delete(beLine)
    line.delete(tier1Line)
    line.delete(tier2Line)
    line.delete(tier3Line)
    label.delete(entryLabel)
    label.delete(stopLabel)
    label.delete(targetLabel)
    label.delete(beLabel)
    label.delete(tier1Label)
    label.delete(tier2Label)
    label.delete(tier3Label)
    anchorBarIdx = bar_index - refLineAnchorBars
    labelBarIdx = bar_index + refLineAnchorBars
    if showPriceLines
        entryLine := line.new(anchorBarIdx, entryPrice, bar_index, entryPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(neutralColor, 0), width=refLineWidth, style=refLineStyleConst)
        stopLine := line.new(anchorBarIdx, stopPrice, bar_index, stopPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(bearishColor, 0), width=refLineWidth, style=refLineStyleConst)
        targetLine := line.new(anchorBarIdx, targetPrice, bar_index, targetPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(bullishColor, 0), width=refLineWidth, style=refLineStyleConst)
        if showLineLabels
            entryLabel := label.new(labelBarIdx, entryPrice, "Entry " + currencySymbol + f_fmt(entryPrice), style=label.style_label_left, color=color.new(neutralColor, 0), textcolor=color.white, size=lineLabelSizeConst)
            stopLabel := label.new(labelBarIdx, stopPrice, "Stop " + currencySymbol + f_fmt(stopPrice), style=label.style_label_left, color=color.new(bearishColor, 0), textcolor=color.white, size=lineLabelSizeConst)
            targetLabel := label.new(labelBarIdx, targetPrice, "Target " + currencySymbol + f_fmt(targetPrice), style=label.style_label_left, color=color.new(bullishColor, 0), textcolor=color.white, size=lineLabelSizeConst)
    if showBreakEvenLine and breakEvenEnable
        beLine := line.new(anchorBarIdx, breakEvenTriggerPrice, bar_index, breakEvenTriggerPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(breakEvenLineColorCustom, 0), width=refLineWidth, style=refLineStyleConst)
        if showLineLabels
            beLabel := label.new(labelBarIdx, breakEvenTriggerPrice, "BE " + currencySymbol + f_fmt(breakEvenTriggerPrice), style=label.style_label_left, color=color.new(breakEvenLineColorCustom, 0), textcolor=color.white, size=lineLabelSizeConst)
    if showLadderLines and enablePartialLadder and tier1Enable
        tier1Line := line.new(anchorBarIdx, tier1Price, bar_index, tier1Price, xloc=xloc.bar_index, extend=extend.right, color=color.new(tier1LineColorCustom, 0), width=refLineWidth, style=refLineStyleConst)
        if showLineLabels
            tier1Label := label.new(labelBarIdx, tier1Price, "T1 " + currencySymbol + f_fmt(tier1Price), style=label.style_label_left, color=color.new(tier1LineColorCustom, 0), textcolor=color.white, size=lineLabelSizeConst)
    if showLadderLines and enablePartialLadder and tier2Enable
        tier2Line := line.new(anchorBarIdx, tier2Price, bar_index, tier2Price, xloc=xloc.bar_index, extend=extend.right, color=color.new(tier2LineColorCustom, 0), width=refLineWidth, style=refLineStyleConst)
        if showLineLabels
            tier2Label := label.new(labelBarIdx, tier2Price, "T2 " + currencySymbol + f_fmt(tier2Price), style=label.style_label_left, color=color.new(tier2LineColorCustom, 0), textcolor=color.white, size=lineLabelSizeConst)
    if showLadderLines and enablePartialLadder and tier3Enable
        tier3Line := line.new(anchorBarIdx, tier3Price, bar_index, tier3Price, xloc=xloc.bar_index, extend=extend.right, color=color.new(tier3LineColorCustom, 0), width=refLineWidth, style=refLineStyleConst)
        if showLineLabels
            tier3Label := label.new(labelBarIdx, tier3Price, "T3 " + currencySymbol + f_fmt(tier3Price), style=label.style_label_left, color=color.new(tier3LineColorCustom, 0), textcolor=color.white, size=lineLabelSizeConst)

// =====================================================================================
// DASHBOARD TABLE
// =====================================================================================
tablePosConst = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Top Right" ? position.top_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.bottom_right
tableSizeConst = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Small" ? size.small : tableSizeIn == "Large" ? size.large : tableSizeIn == "Huge" ? size.huge : size.normal

var table dash = table.new(tablePosConst, 2, 24, border_width=1)

f_cell(_col, _row, _txt, _bg, _txtcol) =>
    table.cell(dash, _col, _row, _txt, bgcolor=_bg, text_color=_txtcol, text_size=tableSizeConst)

if showTable and barstate.islast
    f_cell(0, 0, "MYND Position Calc v1.5", headerBgColor, headerTextColor)
    f_cell(1, 0, "Risk-Based Position Size", headerBgColor, headerTextColor)

    f_cell(0, 1, "Sizing Mode", color.new(color.gray, 85), color.black)
    f_cell(1, 1, sizingMode, color.new(color.gray, 90), color.black)

    f_cell(0, 2, "Direction", color.new(color.gray, 85), color.black)
    f_cell(1, 2, direction, direction == "Long" ? color.new(bullishColor, 80) : color.new(bearishColor, 80), color.black)

    f_cell(0, 3, "Entry Price", color.new(color.gray, 85), color.black)
    f_cell(1, 3, currencySymbol + f_fmt(entryPrice), color.new(color.gray, 90), color.black)

    f_cell(0, 4, "Stop Price (" + stopModeIn + ")", color.new(color.gray, 85), color.black)
    f_cell(1, 4, currencySymbol + f_fmt(stopPrice), color.new(color.gray, 90), color.black)

    f_cell(0, 5, "Stop Distance", color.new(color.gray, 85), color.black)
    f_cell(1, 5, currencySymbol + f_fmt(stopDistance) + "  (" + str.tostring(stopDistancePct, "0.00") + "%)", color.new(color.gray, 90), color.black)

    f_cell(0, 6, "Take-Profit Target (" + str.tostring(targetRMultiple, "0.0") + "R)", color.new(color.gray, 85), color.black)
    f_cell(1, 6, currencySymbol + f_fmt(targetPrice) + f_reachedTag(targetReachedDisp), color.new(bullishColor, 82), color.black)

    f_cell(0, 7, "Risk:Reward Ratio", color.new(color.gray, 85), color.black)
    f_cell(1, 7, str.tostring(rrRatio, "0.0") + " : 1", color.new(color.gray, 90), color.black)

    beTxt = breakEvenEnable ? currencySymbol + f_fmt(breakEvenTriggerPrice) + "  (" + str.tostring(breakEvenRMultiple, "0.0") + "R)" + f_reachedTag(beReachedDisp) : "(disabled)"
    f_cell(0, 8, "Break-Even Trigger", color.new(color.gray, 85), color.black)
    f_cell(1, 8, beTxt, breakEvenEnable ? color.new(breakEvenLineColorCustom, 82) : color.new(color.gray, 92), breakEvenEnable ? color.black : color.gray)

    f_cell(0, 9, "Risk $ Amount (target)", color.new(color.gray, 85), color.black)
    f_cell(1, 9, currencySymbol + str.tostring(riskDollarAmount, "0.00"), color.new(color.gray, 90), color.black)

    f_cell(0, 10, "Position Size (units)", color.new(color.gray, 85), color.black)
    f_cell(1, 10, str.tostring(sizeUnits, "0.##"), cappedByMax ? color.new(bearishColor, 75) : color.new(bullishColor, 80), color.black)

    f_cell(0, 11, "Position Dollar Value", color.new(color.gray, 85), color.black)
    f_cell(1, 11, currencySymbol + str.tostring(positionDollarValue, "0.00") + "  (" + str.tostring(pctOfEquityUsed, "0.00") + "% of equity)", color.new(color.gray, 90), color.black)

    f_cell(0, 12, "Actual $ Risked (final)", color.new(color.gray, 85), color.black)
    f_cell(1, 12, currencySymbol + str.tostring(actualDollarRisked, "0.00"), color.new(color.gray, 90), color.black)

    livePnLTxt = not showLivePnL ? "(disabled)" : entryPriceInput <= 0 ? "N/A (set a fixed Entry Price to track)" : currencySymbol + str.tostring(livePnLDollar, "0.00") + "  (" + str.tostring(livePnLR, "0.00") + "R)"
    livePnLColor = not showLivePnL or entryPriceInput <= 0 ? color.new(color.gray, 90) : livePnLDollar > 0 ? color.new(bullishColor, 82) : livePnLDollar < 0 ? color.new(bearishColor, 82) : color.new(color.gray, 90)
    f_cell(0, 13, "Live P&L (if in trade)", color.new(color.gray, 85), color.black)
    f_cell(1, 13, livePnLTxt, livePnLColor, color.black)

    modeDetailTxt = sizingMode == "Van Tharp R-Multiple/Expectancy" ? "Expectancy = " + str.tostring(expectancyR, "0.000") + "R" + (tharpHasEdge ? " (positive edge)" : " (NEGATIVE/ZERO edge)") : sizingMode == "Kelly Criterion" ? "Kelly f* = " + str.tostring(kellyRaw * 100.0, "0.00") + "%, Effective = " + str.tostring(kellyEffective * 100.0, "0.00") + "%" : "N/A (Fixed % Risk mode)"
    modeDetailColor = (sizingMode == "Van Tharp R-Multiple/Expectancy" and not tharpHasEdge) or (sizingMode == "Kelly Criterion" and not kellyHasEdge) ? color.new(bearishColor, 75) : color.new(color.gray, 90)
    f_cell(0, 14, "Mode Detail", color.new(color.gray, 85), color.black)
    f_cell(1, 14, modeDetailTxt, modeDetailColor, color.black)

    warnTxt = zeroStopWarning ? "Stop equals entry - fix your stop input" : negativeExpectancyWarning ? "NEGATIVE EXPECTANCY - size withheld" : noKellyEdgeWarning ? "NO KELLY EDGE - size withheld" : cappedByMax ? "Capped by Max Position Size" : highRiskPctWarning ? "Risk % exceeds your warning threshold" : ladderOverAllocated ? "Ladder tiers exceed 100% of position" : "None"
    warnColor = anyRiskWarning ? color.new(bearishColor, 70) : color.new(bullishColor, 85)
    f_cell(0, 15, "Risk Warnings", color.new(color.gray, 85), color.black)
    f_cell(1, 15, warnTxt, warnColor, color.black)

    riskThreshTxt = enableRiskPctWarning ? str.tostring(riskPct, "0.00") + "% vs " + str.tostring(riskWarnThresholdPct, "0.00") + "%" + (highRiskPctWarning ? " - ABOVE" : "") : "(disabled)"
    f_cell(0, 16, "Risk % vs Threshold", color.new(color.gray, 85), color.black)
    f_cell(1, 16, riskThreshTxt, highRiskPctWarning ? color.new(bearishColor, 75) : color.new(color.gray, 90), color.black)

    tier1Txt = not enablePartialLadder ? "(disabled)" : not tier1Enable ? "(tier disabled)" : currencySymbol + f_fmt(tier1Price) + " x " + str.tostring(tier1Units, "0.##") + "u (" + str.tostring(tier1Pct, "0.0") + "%, " + str.tostring(tier1R, "0.0") + "R)" + f_reachedTag(tier1ReachedDisp)
    f_cell(0, 17, "Ladder Tier 1", color.new(color.gray, 85), color.black)
    f_cell(1, 17, tier1Txt, enablePartialLadder and tier1Enable ? color.new(tier1LineColorCustom, 82) : color.new(color.gray, 92), enablePartialLadder and tier1Enable ? color.black : color.gray)

    tier2Txt = not enablePartialLadder ? "(disabled)" : not tier2Enable ? "(tier disabled)" : currencySymbol + f_fmt(tier2Price) + " x " + str.tostring(tier2Units, "0.##") + "u (" + str.tostring(tier2Pct, "0.0") + "%, " + str.tostring(tier2R, "0.0") + "R)" + f_reachedTag(tier2ReachedDisp)
    f_cell(0, 18, "Ladder Tier 2", color.new(color.gray, 85), color.black)
    f_cell(1, 18, tier2Txt, enablePartialLadder and tier2Enable ? color.new(tier2LineColorCustom, 82) : color.new(color.gray, 92), enablePartialLadder and tier2Enable ? color.black : color.gray)

    tier3Txt = not enablePartialLadder ? "(disabled)" : not tier3Enable ? "(tier disabled)" : currencySymbol + f_fmt(tier3Price) + " x " + str.tostring(tier3Units, "0.##") + "u (" + str.tostring(tier3Pct, "0.0") + "%, " + str.tostring(tier3R, "0.0") + "R)" + f_reachedTag(tier3ReachedDisp)
    f_cell(0, 19, "Ladder Tier 3", color.new(color.gray, 85), color.black)
    f_cell(1, 19, tier3Txt, enablePartialLadder and tier3Enable ? color.new(tier3LineColorCustom, 82) : color.new(color.gray, 92), enablePartialLadder and tier3Enable ? color.black : color.gray)

    ladderAllocTxt = not showLadderAllocationCheck ? "(disabled)" : not enablePartialLadder ? "(ladder disabled)" : str.tostring(ladderTotalPct, "0.0") + "% allocated" + (ladderOverAllocated ? " - OVER 100%" : "")
    ladderAllocColor = showLadderAllocationCheck and ladderOverAllocated ? color.new(bearishColor, 70) : color.new(color.gray, 90)
    f_cell(0, 20, "Ladder Allocation Check", color.new(color.gray, 85), color.black)
    f_cell(1, 20, ladderAllocTxt, ladderAllocColor, color.black)

    streakLossTxt = not showStreakRisk ? "(disabled)" : not streakHasValidRisk ? "N/A (no active edge)" : str.tostring(streakLossesToThreshold, "0") + " losses at " + str.tostring(streakDrawdownThresholdPct, "0.0") + "% DD"
    f_cell(0, 21, "Streak: Losses to Threshold", color.new(color.gray, 85), color.black)
    f_cell(1, 21, streakLossTxt, color.new(color.gray, 90), color.black)

    streakProbTxt = not showStreakRisk ? "(disabled)" : not streakHasValidRisk ? "N/A" : str.tostring(streakProbability * 100.0, "0.0000") + "% (" + str.tostring(streakWinRateInput, "0.0") + "% WR assumed)"
    f_cell(0, 22, "Streak: Loss-Streak Probability", color.new(color.gray, 85), color.black)
    f_cell(1, 22, streakProbTxt, color.new(color.gray, 90), color.black)

    f_cell(0, 23, "Framing", color.new(color.gray, 85), color.black)
    f_cell(1, 23, "Educational tool - verify before risking capital", color.new(color.gray, 92), color.gray)

// =====================================================================================
// ALERTS - INDIVIDUAL
// =====================================================================================
alertcondition(negativeExpectancyWarning, title="Negative Expectancy Warning", message="MYND Position Calc: Van Tharp Expectancy is zero or negative for the supplied trade stats - no position size recommendation should be taken as profitable.")
alertcondition(noKellyEdgeWarning, title="No Kelly Edge Warning", message="MYND Position Calc: Kelly Criterion computed zero or negative edge (f* <= 0) for the supplied win rate/win-loss ratio - no position is recommended.")
alertcondition(cappedByMax, title="Position Capped by Max Size", message="MYND Position Calc: the raw computed position size exceeded your Max Position Size safety cap and was reduced.")
alertcondition(zeroStopWarning, title="Zero Stop Distance Warning", message="MYND Position Calc: Entry Price and Stop Price are equal - check your stop inputs, position size cannot be computed from a zero stop distance.")
alertcondition(highRiskPctWarning, title="High Risk % Warning", message="MYND Position Calc: Risk % of Equity Per Trade is set above your own warning threshold - review before sizing this trade.")
alertcondition(ladderOverAllocated, title="Ladder Over-Allocated Warning", message="MYND Position Calc: your enabled Partial Ladder tiers add up to more than 100% of the position - reduce one or more tier percentages.")
alertcondition(breakEvenReached, title="Break-Even Trigger Reached", message="MYND Position Calc: price has reached the Break-Even Trigger reference level - consider whether to move your real stop to break-even.")
alertcondition(targetReached, title="Take-Profit Target Reached", message="MYND Position Calc: price has reached the Take-Profit Target reference level.")
alertcondition(tier1Reached, title="Partial Ladder Tier 1 Reached", message="MYND Position Calc: price has reached Partial Ladder Tier 1's reference price.")
alertcondition(tier2Reached, title="Partial Ladder Tier 2 Reached", message="MYND Position Calc: price has reached Partial Ladder Tier 2's reference price.")
alertcondition(tier3Reached, title="Partial Ladder Tier 3 Reached", message="MYND Position Calc: price has reached Partial Ladder Tier 3's reference price.")

// =====================================================================================
// ALERTS - COMBO BUNDLES
// =====================================================================================
alertcondition(anyRiskWarning, title="ALL Risk Warnings (combo)", message="MYND Position Calc: a risk warning is active - check the dashboard before sizing this trade.")
alertcondition(anyMilestoneReached, title="ALL Trade Management Milestones (combo)", message="MYND Position Calc: a trade management milestone (Break-Even Trigger or a Partial Ladder tier) has been reached - check the dashboard for which one.")
````
