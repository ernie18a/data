# Alpha Forge Core v6.4.15

- url: https://www.tradingview.com/script/ZYQu3dti-Alpha-Forge-Core-v6-4-15/
- type: indicator
- pine_id: PUB;043ff4e05fa2485d98fe31ae9e58f3d8
- version: 2.0

## Description

Alpha Forge Core v6.4.15

Advanced trend, momentum, structure, trade-management, and webhook automation indicator.

This multi-layer decision-support tool is designed to help traders evaluate trend direction, momentum, market regime, price structure, entry conditions, and active trade management from one chart.

Rather than relying on a single crossover or isolated signal, the system combines several confirmation layers to assess whether conditions support a potential long or short setup.

It is intended for discretionary chart analysis, TradingView alerts, and compatible webhook-based automation.

What the indicator analyzes

The script evaluates:

Trend direction
Moving-average alignment
Momentum strength
Adaptive market regime
Higher-timeframe confirmation
Price structure
Breakout conditions
Pullback and reclaim behavior
Entry distance and price extension
Volatility
Signal quality
Active trade state
Protective stop placement
Profit-target progression
Breakeven protection
Trailing-stop protection

These components are combined into a single decision process rather than displayed as unrelated signals.

Automatic market detection

The system can detect the general symbol type using TradingView market information.

Supported categories include:

Stocks
ETFs
Crypto
Forex
Futures
Other supported symbols

When automatic behavior is enabled, the detected market can influence the effective operating configuration.

Crypto scalping behavior

When a crypto symbol is detected, the script can automatically apply its faster Crypto Scalping configuration.

This mode is designed for shorter-term crypto charts and removes higher-timeframe influence from the effective scoring process.

Recommended crypto timeframe:

5 minutes

Pine Script cannot automatically change the chart timeframe. When the current chart does not match the recommended timeframe, the Guide may display a reminder.

Operating presets
Scalping

Designed for shorter timeframes and faster-moving setups. This preset uses more responsive conditions and shorter trade-development windows.

Day

Designed for intraday trading with a balance between responsiveness and confirmation. This is the recommended starting point for many stock and ETF charts.

Swing

Designed for higher timeframes and slower-developing setups. This preset applies more selective confirmation and allows additional time for trades to develop.

Custom

Allows the available settings to be controlled manually.

Suggested starting points:

Stocks and ETFs: 15-minute chart with Day mode
Crypto: 5-minute chart with automatic Crypto Scalping
Short-term scalping: 3-minute to 5-minute charts
Swing trading: 30-minute to 4-hour charts

These are general starting points only. Settings should be evaluated on the intended symbol and timeframe.

Signal grades

Potential entries can be filtered by grade.

Available options include:

A Only
B Only
A and B
All Grades

A-grade setups represent stronger internal alignment.

B-grade setups may appear earlier or with fewer confirmation layers while still meeting the selected eligibility rules.

C-grade setups represent lower-confirmation conditions and are available when All Grades is selected.

Grades describe the amount of confirmation present at the time of the setup. They do not guarantee a particular outcome.

Entry behavior

The engine can identify several types of setup behavior.

Breakout entries

These occur when price moves through an important structure level with sufficient directional confirmation.

Impulse entries

These identify stronger directional expansion when momentum and price accelerate together.

Early reclaim entries

These occur when price briefly loses a key level and then reclaims it with confirmation.

Continuation entries

These identify opportunities within an established trend after a valid pullback or consolidation.

B-grade re-entry

When enabled, the system can permit a controlled re-entry after a valid pullback instead of repeatedly triggering during the same move.

Range and extension protection

The script includes filters intended to reduce weaker entries during unsuitable conditions.

These can include:

Blocking continuation setups in range conditions
Requiring trend-regime eligibility
Limiting entries when price is too far from its reference level
Avoiding repeated entries during an active trade
Waiting for candle-close confirmation
Requiring directional confirmation

These filters are designed to improve consistency, but they may also reduce signal frequency.

Higher-timeframe confirmation

Higher-timeframe alignment can be used as an additional confirmation layer.

The script supports both responsive and confirmed higher-timeframe behavior.

When higher-timeframe influence is disabled, scoring is normalized so that the missing HTF component does not unfairly reduce setup quality.

Trade lifecycle

The indicator tracks a complete trade state from entry through exit.

The lifecycle can include:

Entry confirmation
Protective stop placement
TP1
TP2
TP3
Breakeven activation
Trailing-stop activation
Stop-loss exit
Breakeven exit
Trailing-stop exit
Final target exit

Only one active position is tracked at a time. New entries are blocked until the current position is closed.

Protective stops

Stops can use a combination of structure and ATR-based distance.

Available controls may include:

ATR stop multiplier
Structure buffer
Maximum stop distance
Same-bar target and stop priority
Breakeven activation
Trailing-stop source
Trailing-stop distance

These settings should be matched to the symbol’s volatility and the trader’s risk plan.

Profit targets

The system supports three target levels:

TP1
TP2
TP3

Target progress is shown on the chart and in the dashboard.

Breakeven and trailing protection can be activated after a selected target is reached.

Forge Guide

The Guide has been rebuilt as a forward-looking coaching panel.

Instead of repeating dashboard information, it focuses on what matters next.

It can display:

What the system is waiting for
What to watch next
Whether a setup is armed
Trigger conditions
Invalidation conditions
Remaining setup window
Whether price is too extended
Current trade objective
Active protection
Target progression
Trailing-stop status

Typical Guide states include:

WAIT
WATCH LONG
WATCH SHORT
LONG NEAR READY
SHORT NEAR READY
STAND ASIDE
DO NOT CHASE
MANAGE LONG
MANAGE SHORT
PROTECT PROFIT

The Guide is intended to explain the current condition in plain language without replacing personal judgment.

Dashboard

The compact dashboard focuses on live decision information.

It may display:

Effective preset
Detected market
Trend
Adaptive regime
B eligibility
Momentum
Higher-timeframe state
Structure
Current decision
Active trade
Protection
Last exit
TP1, TP2, and TP3 status

Historical testing statistics and diagnostic counters are not shown in the public dashboard so the chart remains clean and easy to read.

Alerts and webhook automation

The script supports TradingView alerts and JSON webhook messages.

For long-only automation:

buy opens a long position
sell closes the long position

A sell action may be generated when the active long closes through:

TP3
Stop loss
Breakeven
Trailing stop
Another enabled long-exit condition

The JSON format includes fields for:

Secret token
Ticker
Asset type
Action
Price
Strategy
Timeframe
Order type
Stop loss
Take-profit levels

For webhook use:

Enter the secret token in the alert settings.
Enable bot JSON alerts.
Create one TradingView alert using Any alert() function call.
Enter the webhook URL supplied by the connected execution service.
Recreate alerts whenever the script or alert configuration is changed.

Existing alerts continue running the older saved script snapshot until they are recreated.

Important notes

This indicator is a chart-reading and decision-support tool.

It does not predict future price movement and does not guarantee profitable outcomes.

Historical chart behavior may differ from live execution because of:

Spread
Slippage
Liquidity
Latency
Broker rules
Order handling
Market gaps
Partial fills

Signals should be evaluated alongside personal risk management, position sizing, market conditions, and independent analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Forge

//@version=6
indicator("Alpha Forge Core v6.4.18 Elite", shorttitle="AF Core v6.4.18", overlay=true, max_labels_count=500, max_lines_count=500)

// v6.4.18 release cleanup
// - Prevents duplicate C labels when All Grades makes C executable.
// - Aligns dashboard decision colors with chart-side signals, including Longs Only bearish analysis.
// - Removes the ineffective Show Detected Market input; market verification remains visible by default.
//
// v6.4.17 release cleanup
// - Adds true Auto Forex Day and Auto Gold Day configurations.
// - Detects common spot/CFD gold symbols and gold futures separately from generic Forex/Futures.
// - Keeps HTF enabled for Forex/Gold while Crypto remains responsive with HTF disabled.
// - Fixes HTF Off integrity so disabled HTF cannot invalidate armed B setups.
// - Decouples bearish chart analysis from Bot Direction; automation direction no longer suppresses short setup analysis.
// - Improves Forge Guide threshold wording and handles disabled initial protection cleanly.
// - Removes dead public audit/stat inputs while retaining a fixed internal diagnostic window.
// - Preserves the exact long-only webhook schema and trade lifecycle behavior.
//
// v6.4.15 forward-looking Forge Guide
// - Replaces the 41-row testing dashboard with a compact 13-row live decision panel.
// - Keeps performance, grade and audit calculations internal without rendering them publicly.
// - Preserves the v6.4.12 webhook schema, auto-market configuration and All Grades tracking.
// - Restores All Grades (A + B + C) as an explicit tracked-grade option.
// - Removes the separate C-tracking toggle to prevent conflicting settings.
// - C remains visible guidance under A Only, B Only and A + B.
// - In All Grades mode, C can open tracked positions, affect statistics and emit bot entry actions.
// - Preserves v6.4.9 automatic crypto configuration and v6.4.7 correctness repairs.
// - Auto-detects Stocks/ETF, Crypto, Forex and Futures using syminfo.type.
// - Combines Market Profile with Trading Preset instead of multiplying preset menus.
// - Auto-detected Crypto automatically applies the Scalping behavior preset and disables HTF.
// - Keeps the user-selected preset visible, but shows the effective auto preset in the dashboard and Forge Guide.
// - Warns when Crypto Scalping is not being viewed on the recommended 5-minute chart.
// - Normalizes weighted scores when HTF is disabled.
// - Shows Live / Closed / Off HTF mode clearly in the dashboard and Forge Guide.
// - Corrects stop-versus-trail exit-reason classification.
// - Clarifies tracked statistics and Custom-only override inputs.
// - Preserves the validated v6.4.7 scoring, trade-state and lifecycle corrections.

//============================
// INPUTS
//============================
groupMode    = "Mode"
groupMarket  = "Market Profile"
groupHTF     = "Higher Timeframe"
groupVisual  = "Visuals"
groupDash    = "Dashboard"
groupAlerts  = "Alerts"
groupStruct  = "Structure"
groupTP      = "Targets"
groupSignals = "Signal Filter"
groupRisk    = "Risk & Trade Management"
groupRegime  = "Adaptive Regime"
groupCustom  = "Custom Preset Overrides"

mode = input.string("Day", "Trading Preset", options=["Scalping", "Day", "Swing", "Custom"], group=groupMode, tooltip="Scalping is designed for 3–5 minute charts and prioritizes activity. Day is the validated default for 15-minute charts. Swing is designed for 30-minute to 4-hour charts with slower confirmation and wider targets. Custom uses the manual override inputs. Auto Configuration can apply dedicated Crypto, Forex or Gold behavior.")
autoConfiguration = input.bool(true, "Auto Configure By Market", group=groupMode, tooltip="When enabled, Crypto uses Crypto Scalping with HTF off, Forex uses Forex Day with HTF on, and Gold uses Gold Day with wider volatility allowances and HTF on. Pine cannot change the chart timeframe.")

marketProfile = input.string("Auto", "Market Profile", options=["Auto", "Stocks / ETF", "Crypto", "Forex", "Gold", "Futures", "Custom"], group=groupMarket, tooltip="Auto detects the current chart using syminfo.type and common symbol names. Auto Configuration applies dedicated Crypto, Forex and Gold behavior. Select Custom to prevent automatic market behavior.")

customTrendLen          = input.int(34, "Custom Trend Length", minval=5, maxval=200, group=groupCustom)
customBandMult          = input.float(1.25, "Custom Band Multiplier", minval=0.25, maxval=5.0, step=0.05, group=groupCustom)
customOscSmooth         = input.int(5, "Custom Oscillator Smoothing", minval=1, maxval=30, group=groupCustom)
customSigSmooth         = input.int(4, "Custom Signal Smoothing", minval=1, maxval=30, group=groupCustom)
customPivotLen          = input.int(3, "Custom Pivot Length", minval=1, maxval=20, group=groupCustom)
customMinMom            = input.float(0.08, "Custom Minimum Momentum", minval=0.0, maxval=1.0, step=0.01, group=groupCustom)
customStructBreakAtr    = input.float(0.10, "Custom Structure Break ATR", minval=0.0, maxval=2.0, step=0.01, group=groupCustom)
customMaxStretch        = input.float(1.05, "Custom Maximum Entry Stretch", minval=0.25, maxval=3.0, step=0.05, group=groupCustom)
customBreakoutStretch   = input.float(1.30, "Custom Breakout Stretch Cap", minval=0.25, maxval=4.0, step=0.05, group=groupCustom)
customReversalExtreme   = input.float(1.15, "Custom Reversal Extreme", minval=0.25, maxval=4.0, step=0.05, group=groupCustom)

useHTFInput = input.bool(true, "Allow HTF Alignment", group=groupHTF, tooltip="Global HTF permission. Auto-configured Crypto overrides effective HTF to Off because testing showed better responsiveness. The checkbox may remain checked, but the dashboard and Forge Guide show the effective HTF state.")
htfTf  = input.timeframe("60", "Custom HTF Timeframe", group=groupHTF, tooltip="Used only when Trading Preset is Custom. Scalping, Day and Swing supply their own effective HTF timeframe.")

showBasis          = input.bool(true, "Show Basis", group=groupVisual)
showBands          = input.bool(true, "Show Bands", group=groupVisual)
showBandFill       = input.bool(true, "Show Regime Fill", group=groupVisual)
showSignals        = input.bool(true, "Show Buy/Sell Signals", group=groupVisual)
showStructure      = input.bool(true, "Show BOS / CHOCH", group=groupVisual)
showWatchs         = input.bool(true, "Show Watch Markers", group=groupVisual)
showGradient       = input.bool(true, "Show Background Gradient", group=groupVisual)
showMidGlow        = input.bool(true, "Show Basis Glow", group=groupVisual)
tintBars           = input.bool(true, "Tint Bars", group=groupVisual)
visualStyle        = input.string("Cinematic", "Visual Style", options=["Clean", "Cinematic"], group=groupVisual)

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
dashboardSize = input.string("Tiny", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)
int statsLookback = 100  // Internal development storage; intentionally not exposed on the public dashboard.
showForgeGuide = input.bool(true, "Show Live Forge Guide", group=groupDash, tooltip="Displays a compact live guidance label beside the latest candle showing the current bias, state, main blocker and next requirement.")
forgeGuideOffset = input.int(5, "Forge Guide Offset (bars)", minval=1, maxval=30, group=groupDash)
forgeGuideSize = input.string("Tiny", "Forge Guide Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

minBarsBetweenStruct = input.int(6, "Min Bars Between BOS/CHOCH", minval=1, group=groupStruct)

showTP1       = input.bool(true, "Show TP1", group=groupTP)
showTP2       = input.bool(true, "Show TP2", group=groupTP)
showTP3       = input.bool(false, "Show TP3", group=groupTP)
showTPLabels  = input.bool(true, "Show TP Labels", group=groupTP)
tpBarsForward = input.int(20, "TP Line Length (bars)", minval=3, maxval=200, group=groupTP)

trackedGrades      = input.string("A + B", "Tracked Signal Grades", options=["A Only", "B Only", "A + B", "All Grades (A + B + C)"], group=groupSignals, tooltip="Controls which signal grades can open tracked positions, affect WR/PF and send executable bot entry actions. Under A Only, B Only or A + B, C remains optional chart guidance only. Select All Grades to trade and statistically track A, B and C.")
stockMode          = input.bool(false, "Stock Mode (Stricter Filters)", group=groupSignals)
confirmEntry       = input.bool(true, "Require Directional Confirmation Candle", group=groupSignals, tooltip="Requires a bullish candle for BUY signals and a bearish candle for SELL signals. Enabled by default because it improved execution quality when used with Breakout Override and Impulse Entries.")
confirmOnClose     = input.bool(true, "Confirm Signals On Candle Close", group=groupSignals, tooltip="Waits for the chart candle to close before publishing a signal. Recommended for alerts and automation.")
useClosedHTF       = input.bool(false, "Custom: Use Last Closed HTF Candle", group=groupHTF, tooltip="Used only when Trading Preset is Custom. Uses the previous fully closed higher-timeframe candle for stable, non-developing HTF alignment.")
minBarsBetweenSigs = input.int(6, "Custom A Signal Cooldown", minval=0, group=groupSignals)
bCooldownBars      = input.int(4, "Custom B Continuation Cooldown", minval=0, group=groupSignals, tooltip="Independent cooldown for practical intraday B continuations and re-entries.")
bMinScore          = input.int(50, "Custom B Minimum Score", minval=35, maxval=75, group=groupSignals, tooltip="Minimum weighted score for the responsive B tier. Lower than A because B is designed to enter on the first valid continuation turn rather than after full mature confirmation.")
bTurnLookback      = input.int(3, "Custom B Pullback Turn Window", minval=1, maxval=8, group=groupSignals, tooltip="Number of bars after a basis touch or shallow pullback in which an improving momentum turn may trigger an earlier B entry.")
bSetupExpiry       = input.int(5, "Custom B Setup Expiry", minval=2, maxval=12, group=groupSignals, tooltip="Arms a B setup on the early turn, then allows a cleaner breakout or pullback-hold entry for this many bars before the setup expires.")
bMaxEntryDistanceAtr = input.float(0.85, "Custom Maximum B Entry Distance (ATR)", minval=0.20, maxval=2.00, step=0.05, group=groupSignals, tooltip="Rejects late B entries that are already too far from the basis. This targets the confirmation-spike problem without suppressing the initial setup arm.")
bMaxEntryCandleAtr = input.float(1.25, "Custom Maximum B Entry Candle Range (ATR)", minval=0.50, maxval=3.00, step=0.05, group=groupSignals, tooltip="Rejects oversized expansion candles as the executable B entry. The setup can remain armed for a cleaner break or pullback hold until expiry.")
bPullbackBufferAtr = input.float(0.20, "B Pullback Hold Buffer (ATR)", minval=0.0, maxval=0.75, step=0.05, group=groupSignals, tooltip="How close price must return toward the stored setup basis to qualify as a pullback-hold entry.")
lockUntilOpposite  = input.bool(true, "Lock A Signals Until Opposite Cycle", group=groupSignals, tooltip="Applies the strict opposite-cycle lock to premium A signals. B continuations use their own cooldown so valid intraday re-entries are not suppressed.")
allowBReentries    = input.bool(true, "Allow B Re-entry After Pullback", group=groupSignals, tooltip="Allows another B continuation after the independent B cooldown when price produces a fresh basis pullback/reclaim or C-to-B follow-through. Enabled by default only because B entries are now restricted to confirmed Trend regimes, reducing the churn seen when unrestricted re-entry was used.")
microStructLen     = input.int(4, "Micro-Structure Length", minval=2, maxval=12, group=groupSignals, tooltip="Short-term structure window used to recognize higher-low/lower-high continuation conditions before the slower pivot structure flips.")
cToBWindow         = input.int(6, "C-to-B Follow-Through Window", minval=1, maxval=20, group=groupSignals, tooltip="Number of bars after an early C warning in which confirmed trend, basis and momentum follow-through may promote the setup to a B continuation.")
int auditBars = 500  // Fixed internal diagnostic window; no dead public audit controls.
enableBreakoutOverride = input.bool(true, "Enable Breakout Override", group=groupSignals, tooltip="Allows qualified structural breakout entries. Enabled by default together with Impulse Entries because the paired configuration produced the strongest A-grade results in testing.")
enableImpulseEntries   = input.bool(true, "Enable Impulse Entries", group=groupSignals, tooltip="Allows qualified momentum-expansion entries. Enabled by default together with Breakout Override because the paired configuration improved signal timing and A-grade frequency.")
enableEarlySignals     = input.bool(true, "Enable Early C Signals", group=groupSignals, tooltip="Enables early counter-trend C signals. They remain chart guidance unless Tracked Signal Grades is set to All Grades (A + B + C).")
showCGuidance         = input.bool(true, "Show C Guidance Labels", group=groupSignals, tooltip="Shows BUY C and SELL C labels. When All Grades is selected they may also become tracked entries; otherwise they remain guidance only.")
cSignalCooldownBars    = input.int(10, "C Signal Cooldown Bars", minval=0, group=groupSignals)
lockCUntilOpposite     = input.bool(false, "Lock C Signals Until Opposite C", group=groupSignals, tooltip="When off, fresh C signals can appear again after the C cooldown. When All Grades is selected, the normal flat-position requirement still prevents repeated C entries during an open trade.")
enableEarlyReclaim     = input.bool(true, "Enable Early Reclaim Entries", group=groupSignals, tooltip="Allows qualified early basis-reclaim/rejection entries. Enabled by default to recover earlier timing while Trend Regime Only eligibility and range blocking control lower-quality continuation trades.")

enableBuySellAlerts   = input.bool(true, "Enable Buy/Sell Alerts", group=groupAlerts)
enableBotJSON         = input.bool(false, "Enable Bot JSON alert()", group=groupAlerts, tooltip="Sends the exact Alpha Forge long-only webhook schema through TradingView Any alert() function call. BUY opens a long and SELL closes the active long.")
webhookSecret        = input.string("", "Webhook Secret Token", group=groupAlerts, tooltip="Paste the exact secret used by your Alpha Forge webhook receiver. The JSON field is always named secret.")
botDirection          = input.string("Longs Only", "Bot Direction", options=["Longs Only", "Longs & Shorts"], group=groupAlerts, tooltip="Longs Only permits LONG_BUY and LONG_SELL actions. Bearish chart signals remain warnings unless the selected exit policy closes an active long. Longs & Shorts also permits short entries and covers.")
tradeExitTarget       = input.string("TP3", "Tracked Trade Exit", options=["TP1", "TP2", "TP3", "Confirmed Opposite A/B", "Any Opposite A/B/C", "First TP or Confirmed Opposite"], group=groupTP, tooltip="Selects the event that closes the internally tracked trade. Bearish chart signals remain warnings unless an opposite-signal exit mode is selected.")
targetAtrLen          = input.int(14, "Target ATR Length", minval=2, group=groupTP)
tp1AtrMult            = input.float(1.00, "Custom TP1 ATR Multiplier", minval=0.1, step=0.05, group=groupTP, tooltip="First volatility target measured from the confirmed entry close.")
tp2AtrMult            = input.float(1.75, "Custom TP2 ATR Multiplier", minval=0.2, step=0.05, group=groupTP, tooltip="Second volatility target. The default breakeven and trailing lifecycle begins here rather than at TP1.")
tp3AtrMult            = input.float(2.50, "Custom TP3 ATR Multiplier", minval=0.3, step=0.05, group=groupTP, tooltip="Final volatility target used by TP3 exit mode and planned reward-to-risk calculations.")

stopMode              = input.string("Structure + ATR", "Protective Stop", options=["Structure + ATR", "ATR", "Percent", "Off"], group=groupRisk, tooltip="Structure + ATR uses the recent protected swing with an ATR buffer, capped by Maximum Structure Stop ATR so an old pivot cannot create excessive risk.")
stopAtrMult           = input.float(1.25, "ATR Stop Multiplier", minval=0.1, step=0.05, group=groupRisk, tooltip="ATR distance used by ATR stops and as the fallback when a valid structure stop is unavailable.")
stopPct               = input.float(1.5, "Percent Stop", minval=0.1, step=0.1, group=groupRisk)
structureBufferAtr    = input.float(0.20, "Structure Stop ATR Buffer", minval=0.0, step=0.05, group=groupRisk, tooltip="Extra ATR distance placed beyond the protected swing level.")
maxStructureStopAtr   = input.float(1.75, "Maximum Structure Stop ATR", minval=0.25, step=0.05, group=groupRisk, tooltip="Caps structure-stop distance from entry. This prevents an old swing from creating a very large loss or blocking the setup through poor planned R:R.")
riskReductionMode = input.string("Off", "Risk Reduction", options=["Off", "Conservative", "Balanced", "Aggressive"], group=groupRisk, tooltip="Optionally reduces the remaining initial risk after a trade moves favorably. The tighter stop is scheduled and becomes active on the next candle, so it cannot use an earlier intrabar low/high. Off preserves the v6.3.9-style baseline. Conservative: trigger 0.85 ATR and retain 0.75 ATR risk. Balanced: trigger 0.75 ATR and retain 0.60 ATR risk. Aggressive: trigger 0.65 ATR and retain 0.40 ATR risk.")

bool useRiskReduction = riskReductionMode != "Off"
float riskReductionTrigger = switch riskReductionMode
    "Conservative" => 0.85
    "Balanced"     => 0.75
    "Aggressive"   => 0.65
    => 10.0

float riskReductionRiskAtr = switch riskReductionMode
    "Conservative" => 0.75
    "Balanced"     => 0.60
    "Aggressive"   => 0.40
    => 0.0
breakevenTrigger      = input.string("After TP2", "Breakeven Trigger", options=["Off", "After TP1", "After TP2"], group=groupRisk, tooltip="Controls when the protective stop moves to entry. After TP2 is the balanced default; moving to breakeven after TP1 produced too many premature scratch trades.")
trailAfterTP2         = input.bool(true, "Activate ATR Trail After TP2", group=groupRisk, tooltip="Starts a one-way ATR trailing stop only after TP2 has been reached.")
trailAtrMult          = input.float(1.75, "Custom Trailing Stop ATR Multiplier", minval=0.1, step=0.05, group=groupRisk, tooltip="Distance of the trailing stop after TP2. The 1.75 ATR default gives established trends more room to continue.")
trailSource           = input.string("Price Extreme", "Trailing Stop Source", options=["Highest Close", "Price Extreme"], group=groupRisk, tooltip="Price Extreme trails from the highest high or lowest low since TP2 and is the validated v6.4.6 default. Highest Close/Lowest Close remains available for a slower, less wick-sensitive trail.")
intrabarPriority      = input.string("Stop First", "Same-Bar Stop/Target Priority", options=["Stop First", "Target First"], group=groupRisk)
useMinRR              = input.bool(false, "Require Minimum Planned R:R", group=groupRisk, tooltip="Hard-blocks entries whose planned TP3 reward is too small versus initial stop risk. Off by default because stale structure pivots can otherwise remove many valid intraday trades.")
minPlannedRR          = input.float(1.25, "Minimum Planned R:R To TP3", minval=0.25, step=0.05, group=groupRisk)

useAdaptiveRegime     = input.bool(true, "Use Adaptive Regime Scoring", group=groupRegime, tooltip="Adds trend, range, volatility and transition context to the weighted score. It is a soft scoring input by default rather than a hard signal veto.")
regimeHoldBars        = input.int(3, "Regime Confirmation Bars", minval=1, maxval=10, group=groupRegime)
regimeAdxLen          = input.int(14, "Regime ADX Length", minval=5, group=groupRegime)
regimeAdxTrend        = input.float(20.0, "Trend ADX Threshold", minval=5.0, step=0.5, group=groupRegime)
blockContinuationRange = input.bool(true, "Block Continuation Entries In Range", group=groupRegime, tooltip="Hard-blocks continuation entries when the adaptive regime is Range. Enabled by default because cross-symbol testing showed better quality when continuation trades were limited to confirmed trend conditions.")
bEligibilityMode      = input.string("Trend Regime Only", "B Eligibility", options=["Always", "Trend Regime Only", "Trend or High Expansion", "Adaptive"], group=groupRegime, tooltip="Controls when B continuation trades are executable. A signals are never affected. Trend Regime Only is the validated default: B trades execute only in confirmed Trend regimes, while Range and Transition conditions remain guidance-only.")

enableStructureAlerts = input.bool(false, "Enable BOS / CHOCH Alerts", group=groupAlerts)

//============================
// BEHAVIOR PRESETS
//============================
// TradingView exposes broad symbol classes, so Gold is refined using common
// spot/CFD/futures ticker naming before generic Forex/Futures classification.
string symbolUpper = str.upper(syminfo.ticker)
bool isForexGold =
     syminfo.type == "forex" and
     (str.contains(symbolUpper, "XAU") or symbolUpper == "GOLD")
bool isCfdGold =
     syminfo.type == "cfd" and
     (str.contains(symbolUpper, "XAU") or str.contains(symbolUpper, "GOLD"))
bool isGoldFuture =
     syminfo.type == "futures" and
     (str.startswith(symbolUpper, "GC") or str.startswith(symbolUpper, "MGC"))
bool detectedGold = isForexGold or isCfdGold or isGoldFuture

string detectedMarket =
     detectedGold              ? "Gold" :
     syminfo.type == "crypto"  ? "Crypto" :
     syminfo.type == "forex"   ? "Forex" :
     syminfo.type == "futures" ? "Futures" :
     syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" or syminfo.type == "index" ? "Stocks / ETF" :
     "Custom"

string effectiveMarket = marketProfile == "Auto" ? detectedMarket : marketProfile
bool autoCryptoConfiguration = autoConfiguration and marketProfile != "Custom" and effectiveMarket == "Crypto"
bool autoForexConfiguration  = autoConfiguration and marketProfile != "Custom" and effectiveMarket == "Forex"
bool autoGoldConfiguration   = autoConfiguration and marketProfile != "Custom" and effectiveMarket == "Gold"
string effectivePreset = autoCryptoConfiguration ? "Scalping" : (autoForexConfiguration or autoGoldConfiguration ? "Day" : mode)
bool presetCustom = effectivePreset == "Custom"
bool effectiveUseHTF = useHTFInput and not autoCryptoConfiguration
string marketModeText = effectiveMarket + (marketProfile == "Auto" ? " (Auto)" : "")
string effectivePresetText =
     autoCryptoConfiguration ? "Crypto Scalping (Auto)" :
     autoGoldConfiguration   ? "Gold Day (Auto)" :
     autoForexConfiguration  ? "Forex Day (Auto)" :
     effectivePreset
float chartSeconds = timeframe.in_seconds(timeframe.period)
bool cryptoTimeframeRecommended = not autoCryptoConfiguration or chartSeconds == 300
bool cryptoTimeframeWarning = autoCryptoConfiguration and not cryptoTimeframeRecommended

int trendLen = autoGoldConfiguration ? 40 : autoForexConfiguration ? 34 : effectivePreset == "Scalping" ? 21 : effectivePreset == "Day" ? 34 : effectivePreset == "Swing" ? 55 : customTrendLen

float bandMult = autoGoldConfiguration ? 1.45 : autoForexConfiguration ? 1.30 : effectivePreset == "Scalping" ? 1.00 : effectivePreset == "Day" ? 1.25 : effectivePreset == "Swing" ? 1.50 : customBandMult

int oscSmooth = autoGoldConfiguration ? 5 : autoForexConfiguration ? 5 : effectivePreset == "Scalping" ? 3 : effectivePreset == "Day" ? 5 : effectivePreset == "Swing" ? 8 : customOscSmooth

int sigSmooth = autoGoldConfiguration ? 4 : autoForexConfiguration ? 4 : effectivePreset == "Scalping" ? 2 : effectivePreset == "Day" ? 4 : effectivePreset == "Swing" ? 6 : customSigSmooth

int pivotLen = autoGoldConfiguration ? 4 : autoForexConfiguration ? 3 : effectivePreset == "Scalping" ? 2 : effectivePreset == "Day" ? 3 : effectivePreset == "Swing" ? 5 : customPivotLen

float minMom = autoGoldConfiguration ? 0.07 : autoForexConfiguration ? 0.06 : effectivePreset == "Scalping" ? 0.03 : effectivePreset == "Day" ? 0.08 : effectivePreset == "Swing" ? 0.12 : customMinMom

float structBreakAtr = autoGoldConfiguration ? 0.12 : autoForexConfiguration ? 0.08 : effectivePreset == "Scalping" ? 0.05 : effectivePreset == "Day" ? 0.10 : effectivePreset == "Swing" ? 0.15 : customStructBreakAtr

float maxStretchForEntry = autoGoldConfiguration ? 1.20 : autoForexConfiguration ? 1.10 : effectivePreset == "Scalping" ? 1.20 : effectivePreset == "Day" ? 1.05 : effectivePreset == "Swing" ? 0.90 : customMaxStretch

float breakoutStretchCap = autoGoldConfiguration ? 1.55 : autoForexConfiguration ? 1.40 : effectivePreset == "Scalping" ? 1.45 : effectivePreset == "Day" ? 1.30 : effectivePreset == "Swing" ? 1.15 : customBreakoutStretch

float reversalExtreme = autoGoldConfiguration ? 1.35 : autoForexConfiguration ? 1.20 : effectivePreset == "Scalping" ? 1.00 : effectivePreset == "Day" ? 1.15 : effectivePreset == "Swing" ? 1.30 : customReversalExtreme

string effectiveHtfTf = autoGoldConfiguration or autoForexConfiguration ? "60" : effectivePreset == "Scalping" ? "15" : effectivePreset == "Day" ? "60" : effectivePreset == "Swing" ? "240" : htfTf

bool effectiveUseClosedHTF = effectivePreset == "Swing" ? true : effectivePreset == "Custom" ? useClosedHTF : false
int effectiveABars = autoGoldConfiguration ? 6 : autoForexConfiguration ? 5 : effectivePreset == "Scalping" ? 4 : effectivePreset == "Day" ? 6 : effectivePreset == "Swing" ? 10 : minBarsBetweenSigs
int effectiveBCooldown = autoGoldConfiguration ? 5 : autoForexConfiguration ? 4 : effectivePreset == "Scalping" ? 3 : effectivePreset == "Day" ? 4 : effectivePreset == "Swing" ? 8 : bCooldownBars
int effectiveBScore = autoGoldConfiguration ? 52 : autoForexConfiguration ? 50 : effectivePreset == "Scalping" ? 48 : effectivePreset == "Day" ? 50 : effectivePreset == "Swing" ? 55 : bMinScore
int effectiveBTurnLookback = autoGoldConfiguration ? 4 : autoForexConfiguration ? 3 : effectivePreset == "Scalping" ? 3 : effectivePreset == "Day" ? 3 : effectivePreset == "Swing" ? 5 : bTurnLookback
int effectiveBExpiry = autoGoldConfiguration ? 6 : autoForexConfiguration ? 5 : effectivePreset == "Scalping" ? 4 : effectivePreset == "Day" ? 5 : effectivePreset == "Swing" ? 8 : bSetupExpiry
float effectiveBMaxDistance = autoGoldConfiguration ? 0.95 : autoForexConfiguration ? 0.90 : effectivePreset == "Scalping" ? 0.75 : effectivePreset == "Day" ? 0.85 : effectivePreset == "Swing" ? 1.00 : bMaxEntryDistanceAtr
float effectiveBMaxCandle = autoGoldConfiguration ? 1.45 : autoForexConfiguration ? 1.30 : effectivePreset == "Scalping" ? 1.10 : effectivePreset == "Day" ? 1.25 : effectivePreset == "Swing" ? 1.50 : bMaxEntryCandleAtr
bool effectiveAllowBReentries = effectivePreset == "Swing" ? false : effectivePreset == "Custom" ? allowBReentries : true
bool effectiveBlockRange = effectivePreset == "Custom" ? blockContinuationRange : true
string effectiveBEligibility = effectivePreset == "Custom" ? bEligibilityMode : "Trend Regime Only"
float effectiveTP1 = autoGoldConfiguration ? 1.00 : autoForexConfiguration ? 0.90 : effectivePreset == "Scalping" ? 0.75 : effectivePreset == "Day" ? 1.00 : effectivePreset == "Swing" ? 1.25 : tp1AtrMult
float effectiveTP2 = autoGoldConfiguration ? 1.85 : autoForexConfiguration ? 1.60 : effectivePreset == "Scalping" ? 1.25 : effectivePreset == "Day" ? 1.75 : effectivePreset == "Swing" ? 2.25 : tp2AtrMult
float effectiveTP3 = autoGoldConfiguration ? 2.75 : autoForexConfiguration ? 2.30 : effectivePreset == "Scalping" ? 1.75 : effectivePreset == "Day" ? 2.50 : effectivePreset == "Swing" ? 3.25 : tp3AtrMult
float effectiveTrailAtr = autoGoldConfiguration ? 1.90 : autoForexConfiguration ? 1.65 : effectivePreset == "Scalping" ? 1.40 : effectivePreset == "Day" ? 1.75 : effectivePreset == "Swing" ? 2.00 : trailAtrMult
string effectiveBreakeven = effectivePreset == "Custom" ? breakevenTrigger : "After TP2"

//============================
// COLORS — ALPHA FORGE REVERSAL PRO BRAND
//============================
bull    = color.rgb(41, 211, 255)    // brand bull
bear    = color.rgb(192, 192, 192)   // silver bear
neutral = color.rgb(93, 107, 122)

bullSoft = color.rgb(28, 200, 255)
bearSoft = color.rgb(160, 160, 160)

bullBgCine  = color.new(bull, 95)
bearBgCine  = color.new(bear, 95)
bullBgClean = color.new(bull, 96)
bearBgClean = color.new(bear, 96)

bullFillStrong = visualStyle == "Cinematic" ? color.new(bull, 72) : color.new(bull, 84)
bearFillStrong = visualStyle == "Cinematic" ? color.new(bear, 78) : color.new(bear, 86)

bullFillSoft = visualStyle == "Cinematic" ? color.new(bull, 88) : color.new(bull, 91)
bearFillSoft = visualStyle == "Cinematic" ? color.new(bear, 88) : color.new(bear, 91)

basisBull    = color.rgb(125, 249, 255)   // accent glow
basisBear    = color.rgb(192, 192, 192)
basisNeutral = color.new(neutral, 10)

bandBull = color.new(bull, 38)
bandBear = color.new(bear, 38)

gradeA_Buy = color.rgb(125, 249, 255)
gradeB_Buy = bull
gradeC_Buy = color.new(bull, 10)

gradeA_Sell = color.rgb(225, 225, 225)
gradeB_Sell = bear
gradeC_Sell = color.new(bear, 10)

dashTextSize =
     dashboardSize == "Tiny" ? size.tiny :
     dashboardSize == "Small" ? size.small :
     size.normal

dashTextColor = color.new(color.white, 0)
dashHeaderBg  = color.new(color.rgb(60, 60, 80), 20)
dashCellBg    = color.new(color.black, 78)
dashBorder    = color.new(color.white, 82)

//============================
// ROLLING TRADE STATS STORAGE
//============================
var int[] statWins = array.new_int()
var float[] statPcts = array.new_float()
var string[] statGrades = array.new_string()
var string[] statReasons = array.new_string()

//============================
// HELPERS
//============================
f_dash_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_bias(_len, _mult) =>
    _lag = math.floor((_len - 1) / 2)
    _basis = ta.ema(close + (close - close[_lag]), _len)
    _atr = ta.atr(_len)
    _vol = ta.highest(_atr, _len * 3) * _mult
    close > _basis and _basis > _basis[1] ? 1 :
     close < _basis and _basis < _basis[1] ? -1 : 0

f_push_stat(_pct, _grade, _reason, _keep) =>
    if not na(_pct)
        array.push(statWins, _pct > 0 ? 1 : 0)
        array.push(statPcts, _pct)
        array.push(statGrades, _grade)
        array.push(statReasons, _reason)

        if array.size(statPcts) > _keep
            array.shift(statWins)
            array.shift(statPcts)
            array.shift(statGrades)
            array.shift(statReasons)

f_state(_bull, _bear) =>
    _bull ? "Bull" : _bear ? "Bear" : "Neutral"

f_fmt(_value) =>
    str.tostring(math.round(_value * 100.0) / 100.0)

//============================
// CORE TREND ENGINE
//============================
lag   = math.floor((trendLen - 1) / 2)
basis = ta.ema(close + (close - close[lag]), trendLen)

atrVal = ta.atr(trendLen)
vol    = ta.highest(atrVal, trendLen * 3) * bandMult

upper = basis + vol
lower = basis - vol

var int trend = 0
if ta.crossover(close, upper)
    trend := 1
if ta.crossunder(close, lower)
    trend := -1

trendSlopeUp   = basis > basis[1]
trendSlopeDown = basis < basis[1]

trendStrongBear = basis < basis[1] and close < basis and close < lower
trendStrongBull = basis > basis[1] and close > basis and close > upper

//============================
// OSC / MOMENTUM
//============================
rawOsc = vol != 0 ? (close - basis) / vol : 0.0
osc    = ta.ema(rawOsc, oscSmooth)
sig    = ta.ema(osc, sigSmooth)
hist   = osc - sig

oscBullBias    = osc > 0
oscBearBias    = osc < 0
oscBullConfirm = osc > sig and hist > hist[1]
oscBearConfirm = osc < sig and hist < hist[1]

momBull = osc > minMom and oscBullConfirm
momBear = osc < -minMom and oscBearConfirm
momText = momBull ? "Bullish" : momBear ? "Bearish" : "Neutral"

//============================
// ADAPTIVE AGGRESSION ENGINE
//============================
histStrength = math.abs(hist)
basisSlopeAbs = math.abs(basis - basis[1])

expansionBull = hist > hist[1] and osc > sig and close > basis
expansionBear = hist < hist[1] and osc < sig and close < basis

trendExpansionBull = trend == 1 and expansionBull and histStrength > minMom * 0.8
trendExpansionBear = trend == -1 and expansionBear and histStrength > minMom * 0.8

marketHotBull = trendExpansionBull and basisSlopeAbs > atrVal * 0.01
marketHotBear = trendExpansionBear and basisSlopeAbs > atrVal * 0.01

marketChop = math.abs(rawOsc) < 0.25 and histStrength < minMom * 0.6

//============================
// ADAPTIVE REGIME — AIO-STYLE HYSTERESIS
//============================
[diPlusReg, diMinusReg, adxReg] = ta.dmi(regimeAdxLen, regimeAdxLen)
atrFastReg = ta.ema(ta.atr(14), 10)
atrSlowReg = ta.ema(ta.atr(14), 40)
volExpandingReg = atrFastReg > atrSlowReg
trendCandidateReg = adxReg >= regimeAdxTrend and math.abs(rawOsc) >= 0.20
rangeCandidateReg = adxReg < regimeAdxTrend * 0.85 or marketChop
int candidateRegime = trendCandidateReg ? (volExpandingReg ? 2 : 1) : rangeCandidateReg ? -1 : 0
var int adaptiveRegime = 0
var int candidateRegimeBars = 0
if candidateRegime == candidateRegime[1]
    candidateRegimeBars += 1
else
    candidateRegimeBars := 1
if candidateRegimeBars >= regimeHoldBars
    adaptiveRegime := candidateRegime
regimeIsRange = useAdaptiveRegime and adaptiveRegime == -1
regimeIsTrend = not useAdaptiveRegime or adaptiveRegime == 1 or adaptiveRegime == 2
regimeLabel = not useAdaptiveRegime ? "Off" : adaptiveRegime == 2 ? "Trend High Vol" : adaptiveRegime == 1 ? "Trend" : adaptiveRegime == -1 ? "Range" : "Transition"

//============================
// HTF
//============================
htfBiasLive = request.security(syminfo.tickerid, effectiveHtfTf, f_bias(trendLen, bandMult), barmerge.gaps_off, barmerge.lookahead_off)
htfBiasClosed = request.security(syminfo.tickerid, effectiveHtfTf, f_bias(trendLen, bandMult)[1], barmerge.gaps_off, barmerge.lookahead_on)
htfBiasRaw = effectiveUseClosedHTF ? htfBiasClosed : htfBiasLive
// HTF Off is a genuine neutral state. Raw HTF data remains available only for
// display/debugging, but cannot affect gates, grades, structure or guidance.
htfBias = effectiveUseHTF ? htfBiasRaw : 0
htfBull = effectiveUseHTF and htfBias == 1
htfBear = effectiveUseHTF and htfBias == -1

htfOkBull = not effectiveUseHTF or htfBull or htfBias == 0
htfOkBear = not effectiveUseHTF or htfBear or htfBias == 0

htfNotStrongBear = not effectiveUseHTF or htfBias != -1
htfNotStrongBull = not effectiveUseHTF or htfBias != 1

htfDataModeText = not effectiveUseHTF ? "Off" : effectiveUseClosedHTF ? "Closed " + effectiveHtfTf : "Live " + effectiveHtfTf
htfStateText = not effectiveUseHTF ? "Off" : htfBull ? "Bull" : htfBear ? "Bear" : "Neutral"

//============================
// STRUCTURE ENGINE
//============================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int structureTrend  = 0
var int lastStructBar   = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

barsOkStruct = na(lastStructBar) or (bar_index - lastStructBar >= minBarsBetweenStruct)

bullBreakRaw = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBreakRaw = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

bullBreakStrong = bullBreakRaw and (close - lastSwingHigh) > atrVal * structBreakAtr
bearBreakStrong = bearBreakRaw and (lastSwingLow - close) > atrVal * structBreakAtr

bullBreak = bullBreakStrong and barsOkStruct
bearBreak = bearBreakStrong and barsOkStruct

bullBOS   = bullBreak and structureTrend >= 0
bearBOS   = bearBreak and structureTrend <= 0
bullCHOCH = bullBreak and structureTrend == -1
bearCHOCH = bearBreak and structureTrend == 1

if bullBreak
    structureTrend := 1
    lastStructBar := bar_index

if bearBreak
    structureTrend := -1
    lastStructBar := bar_index

structBull = structureTrend == 1
structBear = structureTrend == -1

//============================
// ENTRY QUALITY FILTERS
//============================
notTooStretchedLong  = rawOsc < maxStretchForEntry
notTooStretchedShort = rawOsc > -maxStretchForEntry

targetAtr = ta.atr(targetAtrLen)
rawLongStructStop = not na(lastSwingLow) and lastSwingLow < close ? lastSwingLow - targetAtr * structureBufferAtr : close - targetAtr * stopAtrMult
rawShortStructStop = not na(lastSwingHigh) and lastSwingHigh > close ? lastSwingHigh + targetAtr * structureBufferAtr : close + targetAtr * stopAtrMult
longStructCap = close - targetAtr * maxStructureStopAtr
shortStructCap = close + targetAtr * maxStructureStopAtr
longStructStop = math.max(rawLongStructStop, longStructCap)
shortStructStop = math.min(rawShortStructStop, shortStructCap)
longStopCandidate = stopMode == "Structure + ATR" ? longStructStop : stopMode == "ATR" ? close - targetAtr * stopAtrMult : stopMode == "Percent" ? close * (1.0 - stopPct / 100.0) : na
shortStopCandidate = stopMode == "Structure + ATR" ? shortStructStop : stopMode == "ATR" ? close + targetAtr * stopAtrMult : stopMode == "Percent" ? close * (1.0 + stopPct / 100.0) : na
longRiskCandidate = not na(longStopCandidate) ? close - longStopCandidate : na
shortRiskCandidate = not na(shortStopCandidate) ? shortStopCandidate - close : na
longPlannedRR = not na(longRiskCandidate) and longRiskCandidate > syminfo.mintick ? (targetAtr * effectiveTP3) / longRiskCandidate : 999.0
shortPlannedRR = not na(shortRiskCandidate) and shortRiskCandidate > syminfo.mintick ? (targetAtr * effectiveTP3) / shortRiskCandidate : 999.0
longRROk = not useMinRR or stopMode == "Off" or longPlannedRR >= minPlannedRR
shortRROk = not useMinRR or stopMode == "Off" or shortPlannedRR >= minPlannedRR

bullTrendOk = trend == 1 and trendSlopeUp and momBull and htfOkBull and not structBear
bearTrendOk = trend == -1 and trendSlopeDown and momBear and htfOkBear and not structBull

bullPullback = ta.crossover(close, basis) and trend == 1
bearPullback = ta.crossunder(close, basis) and trend == -1

//============================
// REVERSAL RECLAIM LOGIC
//============================
bullExtremeRecover = osc[1] < -reversalExtreme and osc > sig and hist > hist[1]
bearExtremeRecover = osc[1] > reversalExtreme and osc < sig and hist < hist[1]

bullBasisReclaim = close > basis and close[1] <= basis
bearBasisReject  = close < basis and close[1] >= basis

bullBandReclaim = close > lower and close[1] <= lower
bearBandReject  = close < upper and close[1] >= upper

watchRevLongRaw  = bullExtremeRecover and (bullBasisReclaim or bullBandReclaim) and (not effectiveUseHTF or not htfBear)
watchRevShortRaw = bearExtremeRecover and (bearBandReject or bearBasisReject) and (not effectiveUseHTF or not htfBull)

//============================
// STRONG REVERSAL FILTER
//============================
bullCandleStrong = close > open and (close - open) > (high - low) * 0.4
bearCandleStrong = close < open and (open - close) > (high - low) * 0.3

bullMomentumStrong = osc > sig and hist > hist[1] and osc > osc[1]
bearMomentumStrong = osc < sig and hist < hist[1] and osc < osc[1]

//============================
// BREAKOUT / IMPULSE ADDITIONS
//============================
bullBreakout =
     enableBreakoutOverride and
     trend == 1 and
     structBull and
     htfOkBull and
     close > upper and
     close > high[1] and
     osc > sig and
     hist > hist[1] and
     rawOsc < breakoutStretchCap and
     not marketChop

bearBreakout =
     enableBreakoutOverride and
     trend == -1 and
     structBear and
     htfOkBear and
     close < lower and
     close < low[1] and
     osc < sig and
     hist < hist[1] and
     rawOsc > -breakoutStretchCap and
     not marketChop

bullImpulse =
     enableImpulseEntries and
     trend == 1 and
     structBull and
     htfOkBull and
     close > basis and
     oscBullConfirm and
     hist > 0 and
     (
         (close > close[1] and hist > hist[1]) or
         marketHotBull
     ) and
     rawOsc < breakoutStretchCap and
     not marketChop

bearImpulse =
     enableImpulseEntries and
     trend == -1 and
     structBear and
     htfOkBear and
     close < basis and
     oscBearConfirm and
     hist < 0 and
     (
         (close < close[1] and hist < hist[1]) or
         marketHotBear
     ) and
     rawOsc > -breakoutStretchCap and
     not marketChop

//============================
// EARLY RECLAIM ADDITION (v6.2)
//============================
bullEarlyReclaim =
     enableEarlyReclaim and
     trend == 1 and
     structBull and
     htfOkBull and
     close > basis and
     close[1] <= basis and
     osc > sig and
     hist > hist[1] and
     osc > 0 and
     rawOsc < maxStretchForEntry and
     not marketChop

bearEarlyReclaim =
     enableEarlyReclaim and
     trend == -1 and
     structBear and
     htfOkBear and
     close < basis and
     close[1] >= basis and
     osc < sig and
     hist < hist[1] and
     osc < 0 and
     rawOsc > -maxStretchForEntry and
     not marketChop

//============================
// ADAPTIVE B ELIGIBILITY
//============================
// A signals remain unaffected. B is executable only when the selected mode allows
// enough trend or directional expansion to justify continuation entries.
bLongHighExpansion =
     bullBreakout or
     bullImpulse or
     marketHotBull or
     (volExpandingReg and adxReg >= regimeAdxTrend * 0.90 and osc > sig and hist > hist[1] and close > basis)

bShortHighExpansion =
     bearBreakout or
     bearImpulse or
     marketHotBear or
     (volExpandingReg and adxReg >= regimeAdxTrend * 0.90 and osc < sig and hist < hist[1] and close < basis)

bLongAdaptivePass =
     regimeIsTrend or
     (adaptiveRegime == 0 and bLongHighExpansion) or
     (regimeIsRange and bLongHighExpansion and volExpandingReg and adxReg >= regimeAdxTrend * 0.90)

bShortAdaptivePass =
     regimeIsTrend or
     (adaptiveRegime == 0 and bShortHighExpansion) or
     (regimeIsRange and bShortHighExpansion and volExpandingReg and adxReg >= regimeAdxTrend * 0.90)

bLongEligible = switch effectiveBEligibility
    "Always"                  => true
    "Trend Regime Only"       => regimeIsTrend
    "Trend or High Expansion" => regimeIsTrend or bLongHighExpansion
    => bLongAdaptivePass

bShortEligible = switch effectiveBEligibility
    "Always"                  => true
    "Trend Regime Only"       => regimeIsTrend
    "Trend or High Expansion" => regimeIsTrend or bShortHighExpansion
    => bShortAdaptivePass

bLongEligibilityReason =
     bLongEligible ? (regimeIsTrend ? "Trend regime" : bLongHighExpansion ? "Directional expansion" : "Eligible") :
     regimeIsRange ? "Range / low expansion" :
     "No trend expansion"

bShortEligibilityReason =
     bShortEligible ? (regimeIsTrend ? "Trend regime" : bShortHighExpansion ? "Directional expansion" : "Eligible") :
     regimeIsRange ? "Range / low expansion" :
     "No trend expansion"

//============================
// MAIN CONFIRMED SIGNALS — A PREMIUM / B EARLY CONTINUATION
//============================
// A remains the fully confirmed tier. B is deliberately earlier: it reacts to the
// first momentum turn, basis reclaim, trend transition or micro higher-low/lower-high
// rather than waiting for mature momentum and slow pivot structure alignment.
microBull = close > basis and basis > basis[1] and low > ta.lowest(low[1], microStructLen)
microBear = close < basis and basis < basis[1] and high < ta.highest(high[1], microStructLen)
microBullEvent = microBull and not microBull[1]
microBearEvent = microBear and not microBear[1]

trendTransitionBull = trend == 1 and trend[1] != 1
trendTransitionBear = trend == -1 and trend[1] != -1

// Earlier momentum turn: improvement can begin below the mature momBull/momBear threshold.
momTurnLong = close > basis and osc > osc[1] and hist > hist[1] and hist > -minMom * 0.75
momTurnShort = close < basis and osc < osc[1] and hist < hist[1] and hist < minMom * 0.75
momTurnLongEvent = momTurnLong and not momTurnLong[1]
momTurnShortEvent = momTurnShort and not momTurnShort[1]

basisTouchRecentLong = nz(ta.barssince(low <= basis), 100000) <= effectiveBTurnLookback
basisTouchRecentShort = nz(ta.barssince(high >= basis), 100000) <= effectiveBTurnLookback
pullbackTurnLong = basisTouchRecentLong and close > basis and close > open and osc > osc[1] and hist > hist[1]
pullbackTurnShort = basisTouchRecentShort and close < basis and close < open and osc < osc[1] and hist < hist[1]
pullbackTurnLongEvent = pullbackTurnLong and not pullbackTurnLong[1]
pullbackTurnShortEvent = pullbackTurnShort and not pullbackTurnShort[1]

structTransitionBull = bullCHOCH or bullBreakRaw or trendTransitionBull or microBullEvent
structTransitionBear = bearCHOCH or bearBreakRaw or trendTransitionBear or microBearEvent
strongStructOppLong  = structBear and trendStrongBear and (not effectiveUseHTF or htfBear)
strongStructOppShort = structBull and trendStrongBull and (not effectiveUseHTF or htfBull)

// Premium continuation keeps full structure and mature momentum agreement.
buyContA  = bullTrendOk and structBull and bullPullback and oscBullBias and notTooStretchedLong
sellContA = bearTrendOk and structBear and bearPullback and oscBearBias and notTooStretchedShort

// Responsive B context. The actual one-bar trigger is applied later so a persistent
// bullish state cannot print repeated entries.
buyBContext = trend == 1 and trendSlopeUp and htfNotStrongBear and close > basis and not strongStructOppLong and rawOsc < breakoutStretchCap
sellBContext = trend == -1 and trendSlopeDown and htfNotStrongBull and close < basis and not strongStructOppShort and rawOsc > -breakoutStretchCap

buyRev =
     stockMode
     ? (bullExtremeRecover and bullBasisReclaim and bullMomentumStrong and bullCandleStrong and htfNotStrongBear and not trendStrongBear and bullCHOCH)
     : (bullExtremeRecover and bullBasisReclaim and bullMomentumStrong and bullCandleStrong and htfNotStrongBear and not trendStrongBear)

sellRev =
     stockMode
     ? (bearExtremeRecover and bearBasisReject and bearMomentumStrong and bearCandleStrong and htfNotStrongBull and not trendStrongBull and bearCHOCH)
     : (bearExtremeRecover and bearBasisReject and bearMomentumStrong and bearCandleStrong and htfNotStrongBull and not trendStrongBull)

noTrade = trend == 0 or (effectiveUseHTF and htfBias == 0) or momText == "Neutral"

buySignalRawA = (buyContA and not (effectiveBlockRange and regimeIsRange)) or buyRev
sellSignalRawA = (sellContA and not (effectiveBlockRange and regimeIsRange)) or sellRev

reclaimLong  = close > basis and close[1] <= basis
reclaimShort = close < basis and close[1] >= basis

contEntryLong  = trend == 1 and structBull and reclaimLong and oscBullConfirm
contEntryShort = trend == -1 and structBear and reclaimShort and oscBearConfirm

longContinuationAllowed = not (effectiveBlockRange and regimeIsRange)
shortContinuationAllowed = not (effectiveBlockRange and regimeIsRange)

buySignalConfirmedBaseA =
     stockMode
     ? ((buySignalRawA and not noTrade and trend == 1 and structBull) or (bullBreakout and regimeIsTrend) or (bullImpulse and regimeIsTrend) or bullEarlyReclaim)
     : (buySignalRawA or (bullBreakout and regimeIsTrend) or (bullImpulse and regimeIsTrend) or bullEarlyReclaim)

sellSignalConfirmedBaseA =
     stockMode
     ? ((sellSignalRawA and not noTrade and trend == -1 and structBear) or (bearBreakout and regimeIsTrend) or (bearImpulse and regimeIsTrend) or bearEarlyReclaim)
     : (sellSignalRawA or (bearBreakout and regimeIsTrend) or (bearImpulse and regimeIsTrend) or bearEarlyReclaim)

// B context is qualified now; a discrete early trigger is required later.
buySignalConfirmedBaseB = buyBContext and longContinuationAllowed and bLongEligible
sellSignalConfirmedBaseB = sellBContext and shortContinuationAllowed and bShortEligible

//============================
// EARLY C SIGNALS (trimmed)
//============================
earlyShortBase =
     enableEarlySignals and
     (
         (trend == 1 and oscBearConfirm and hist < hist[1] and close < basis and not structBear) or
         (marketHotBull and oscBearConfirm and close < basis)
     ) and
     not marketChop and
     hist < -minMom * 2.00 and
     osc < sig and
     basisSlopeAbs > atrVal * 0.003

earlyLongBase =
     enableEarlySignals and
     (
         (trend == -1 and oscBullConfirm and hist > hist[1] and close > basis and not structBull) or
         (marketHotBear and oscBullConfirm and close > basis)
     ) and
     not marketChop and
     hist > minMom * 2.00 and
     osc > sig and
     basisSlopeAbs > atrVal * 0.003

earlyLong = earlyLongBase
earlyShort = earlyShortBase

recentEarlyLong = nz(ta.barssince(earlyLongBase), 100000) <= cToBWindow
recentEarlyShort = nz(ta.barssince(earlyShortBase), 100000) <= cToBWindow
cToBLong = recentEarlyLong and trend == 1 and close > basis and momTurnLong and htfNotStrongBear and rawOsc < breakoutStretchCap
cToBShort = recentEarlyShort and trend == -1 and close < basis and momTurnShort and htfNotStrongBull and rawOsc > -breakoutStretchCap
// Promotion can occur once when follow-through first becomes valid, not on every bar in the window.
cToBLongEvent = cToBLong and not cToBLong[1]
cToBShortEvent = cToBShort and not cToBShort[1]

buySignalConfirmedBaseB := buySignalConfirmedBaseB or cToBLongEvent
sellSignalConfirmedBaseB := sellSignalConfirmedBaseB or cToBShortEvent

//============================
// WEIGHTED CONFLUENCE GRADING
//============================
int buyScoreRaw = 0
buyScoreRaw += trend == 1 ? 20 : 0
buyScoreRaw += effectiveUseHTF ? (htfBull ? 20 : htfBias == 0 ? 8 : 0) : 0
buyScoreRaw += structBull ? 20 : 0
buyScoreRaw += momBull ? 15 : oscBullConfirm ? 8 : 0
buyScoreRaw += notTooStretchedLong ? 10 : 0
buyScoreRaw += regimeIsTrend ? 10 : regimeIsRange ? 0 : 5
buyScoreRaw += bullBreakout or bullImpulse or bullEarlyReclaim or buyRev ? 5 : 0

int sellScoreRaw = 0
sellScoreRaw += trend == -1 ? 20 : 0
sellScoreRaw += effectiveUseHTF ? (htfBear ? 20 : htfBias == 0 ? 8 : 0) : 0
sellScoreRaw += structBear ? 20 : 0
sellScoreRaw += momBear ? 15 : oscBearConfirm ? 8 : 0
sellScoreRaw += notTooStretchedShort ? 10 : 0
sellScoreRaw += regimeIsTrend ? 10 : regimeIsRange ? 0 : 5
sellScoreRaw += bearBreakout or bearImpulse or bearEarlyReclaim or sellRev ? 5 : 0

// Preserve the 0–100 grading scale when HTF is disabled by normalizing the
// remaining 80 available points. HTF Off therefore neither rewards nor penalizes.
float scoreMax = effectiveUseHTF ? 100.0 : 80.0
int buyScore = int(math.round(float(buyScoreRaw) / scoreMax * 100.0))
int sellScore = int(math.round(float(sellScoreRaw) / scoreMax * 100.0))

buyAQualified = buySignalConfirmedBaseA and buyScore >= 80
sellAQualified = sellSignalConfirmedBaseA and sellScore >= 80
buyBQualified = buySignalConfirmedBaseB and buyScore >= effectiveBScore
sellBQualified = sellSignalConfirmedBaseB and sellScore >= effectiveBScore

buySignalConfirmed = (buyAQualified or buyBQualified) and longRROk
sellSignalConfirmed = (sellAQualified or sellBQualified) and shortRROk

buyConfirmedGrade  = buyAQualified ? "A" : "B"
sellConfirmedGrade = sellAQualified ? "A" : "B"

signalBarReady = not confirmOnClose or barstate.isconfirmed
finalBuyBase  = signalBarReady and (confirmEntry ? (buySignalConfirmed and close >= close[1]) : buySignalConfirmed)
finalSellBase = signalBarReady and (confirmEntry ? (sellSignalConfirmed and close <= close[1]) : sellSignalConfirmed)

trackAllGrades = trackedGrades == "All Grades (A + B + C)"
allowA = trackedGrades == "A Only" or trackedGrades == "A + B" or trackAllGrades
allowB = trackedGrades == "B Only" or trackedGrades == "A + B" or trackAllGrades
allowC = trackAllGrades

buyAllowed  = (buyConfirmedGrade == "A" and allowA) or (buyConfirmedGrade == "B" and allowB)
sellAllowed = (sellConfirmedGrade == "A" and allowA) or (sellConfirmedGrade == "B" and allowB)

earlyLongAllowed  = enableEarlySignals and longRROk
earlyShortAllowed = enableEarlySignals and shortRROk

//============================
// A PREMIUM LOCK / B EVENT COOLDOWN
//============================
// Trade state is declared before the B arming engine so setup state can be position-aware.
var bool tradeActive = false
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var string activeSide = "None"
var float trackedEntryPrice = na
var string trackedEntryGrade = ""
var float activeStop = na
var float activeTrail = na
var float trailAnchor = na
var string lastExitReason = "None"
var int activeEntryBar = na
var float activeEntryAtr = na
var float activeMFEAtr = 0.0
var int earlyStop1Count = 0
var int earlyStop3Count = 0
var float stoppedMfeSum = 0.0
var int stoppedMfeCount = 0
var bool riskReductionActive = false
var int riskReductionCount = 0
var float pendingStop = na
var int pendingStopBar = na
var string pendingStopReason = ""
var int tp1HitBar = na
var int tp2HitBar = na
var float trailActivationAtr = na

var int lastASignalBar = na
var int lastBSignalBar = na
var bool buyALock = false
var bool sellALock = false
var bool longRearmReady = true
var bool shortRearmReady = true

isBuyA = finalBuyBase and buyAllowed and buyConfirmedGrade == "A"
isSellA = finalSellBase and sellAllowed and sellConfirmedGrade == "A"
isBuyB = finalBuyBase and buyAllowed and buyConfirmedGrade == "B"
isSellB = finalSellBase and sellAllowed and sellConfirmedGrade == "B"

aBarsOk = na(lastASignalBar) or (bar_index - lastASignalBar >= effectiveABars)
bBarsOk = na(lastBSignalBar) or (bar_index - lastBSignalBar >= effectiveBCooldown)

buyAFinal = isBuyA and aBarsOk and (not lockUntilOpposite or not buyALock)
sellAFinal = isSellA and aBarsOk and (not lockUntilOpposite or not sellALock)

// B is now a two-stage process. The first early turn arms a setup; the actual entry
// must occur on a clean setup-high/setup-low break or a pullback hold near the stored basis.
bFreshLongEvent = trendTransitionBull or reclaimLong or momTurnLongEvent or pullbackTurnLongEvent or microBullEvent or cToBLongEvent
bFreshShortEvent = trendTransitionBear or reclaimShort or momTurnShortEvent or pullbackTurnShortEvent or microBearEvent or cToBShortEvent
bLongArmTrigger = effectiveAllowBReentries ? bFreshLongEvent : (trendTransitionBull or reclaimLong or momTurnLongEvent or cToBLongEvent)
bShortArmTrigger = effectiveAllowBReentries ? bFreshShortEvent : (trendTransitionBear or reclaimShort or momTurnShortEvent or cToBShortEvent)

var bool longBArmed = false
var bool shortBArmed = false
var int longBSetupBar = na
var int shortBSetupBar = na
var float longBSetupHigh = na
var float longBSetupLow = na
var float shortBSetupHigh = na
var float shortBSetupLow = na
var float longBSetupBasis = na
var float shortBSetupBasis = na
var string longBSetupSource = ""
var string shortBSetupSource = ""

longArmCandidate = not tradeActive and not longBArmed and isBuyB and bBarsOk and longRearmReady and bLongArmTrigger
shortArmCandidate = not tradeActive and not shortBArmed and isSellB and bBarsOk and shortRearmReady and bShortArmTrigger

if longArmCandidate
    longBArmed := true
    shortBArmed := false
    longBSetupBar := bar_index
    longBSetupHigh := high
    longBSetupLow := low
    longBSetupBasis := basis
    longBSetupSource := cToBLongEvent ? "C-to-B Follow-Through" : trendTransitionBull ? "Trend Transition" : reclaimLong ? "Basis Reclaim" : pullbackTurnLongEvent ? "Pullback Turn" : momTurnLongEvent ? "Momentum Turn" : microBullEvent ? "Micro Higher Low" : "Continuation"

if shortArmCandidate
    shortBArmed := true
    longBArmed := false
    shortBSetupBar := bar_index
    shortBSetupHigh := high
    shortBSetupLow := low
    shortBSetupBasis := basis
    shortBSetupSource := cToBShortEvent ? "C-to-B Follow-Through" : trendTransitionBear ? "Trend Transition" : reclaimShort ? "Basis Reject" : pullbackTurnShortEvent ? "Pullback Turn" : momTurnShortEvent ? "Momentum Turn" : microBearEvent ? "Micro Lower High" : "Continuation"

longBExpired = longBArmed and not na(longBSetupBar) and bar_index - longBSetupBar > effectiveBExpiry
shortBExpired = shortBArmed and not na(shortBSetupBar) and bar_index - shortBSetupBar > effectiveBExpiry
longBInvalid = longBArmed and (trend == -1 or close < longBSetupLow or (effectiveUseHTF and htfBear))
shortBInvalid = shortBArmed and (trend == 1 or close > shortBSetupHigh or (effectiveUseHTF and htfBull))
if longBExpired or longBInvalid or tradeActive
    longBArmed := false
if shortBExpired or shortBInvalid or tradeActive
    shortBArmed := false

entryRangeAtr = targetAtr > 0 ? (high - low) / targetAtr : 999.0
longEntryDistanceAtr = targetAtr > 0 ? math.max(0.0, close - basis) / targetAtr : 999.0
shortEntryDistanceAtr = targetAtr > 0 ? math.max(0.0, basis - close) / targetAtr : 999.0
longBQualityOk = entryRangeAtr <= effectiveBMaxCandle and longEntryDistanceAtr <= effectiveBMaxDistance
shortBQualityOk = entryRangeAtr <= effectiveBMaxCandle and shortEntryDistanceAtr <= effectiveBMaxDistance

longBBreakEntry = longBArmed and bar_index > longBSetupBar and close > longBSetupHigh and close > open and hist > hist[1]
shortBBreakEntry = shortBArmed and bar_index > shortBSetupBar and close < shortBSetupLow and close < open and hist < hist[1]
longBPullbackEntry = longBArmed and bar_index > longBSetupBar and low <= longBSetupBasis + targetAtr * bPullbackBufferAtr and close > longBSetupBasis and close > open and osc > osc[1] and hist > hist[1]
shortBPullbackEntry = shortBArmed and bar_index > shortBSetupBar and high >= shortBSetupBasis - targetAtr * bPullbackBufferAtr and close < shortBSetupBasis and close < open and osc < osc[1] and hist < hist[1]

buyBFinal = isBuyB and bBarsOk and longRearmReady and longBArmed and longBQualityOk and (longBBreakEntry or longBPullbackEntry)
sellBFinal = isSellB and bBarsOk and shortRearmReady and shortBArmed and shortBQualityOk and (shortBBreakEntry or shortBPullbackEntry)

// These remain setup candidates. Actual entry labels, alerts and lock updates use entry events later.
finalBuy = buyAFinal or buyBFinal
finalSell = sellAFinal or sellBFinal

if finalBuy and finalSell
    finalBuy := false
    finalSell := false

// Opposite market-cycle events may release premium locks.
if finalSell or bearCHOCH
    buyALock := false
if finalBuy or bullCHOCH
    sellALock := false

//============================
// C SIGNAL COOLDOWN / LOCK
//============================
var int lastCSignalBar = na
var bool cBuyLock = false
var bool cSellLock = false

cBarsOk = na(lastCSignalBar) or (bar_index - lastCSignalBar >= cSignalCooldownBars)

earlyLongRaw  = signalBarReady and earlyLong and earlyLongAllowed and cBarsOk and not finalBuy and not finalSell
earlyShortRaw = signalBarReady and earlyShort and earlyShortAllowed and cBarsOk and not finalBuy and not finalSell

earlyLongFinal  = lockCUntilOpposite ? (earlyLongRaw and not cBuyLock) : earlyLongRaw
earlyShortFinal = lockCUntilOpposite ? (earlyShortRaw and not cSellLock) : earlyShortRaw

if earlyLongFinal and earlyShortFinal
    earlyLongFinal := false
    earlyShortFinal := false

if earlyLongFinal
    lastCSignalBar := bar_index
    cBuyLock := true
    cSellLock := false

if earlyShortFinal
    lastCSignalBar := bar_index
    cSellLock := true
    cBuyLock := false

// Unlock only when the opposite C/confirmed cycle appears.
if finalSell or earlyShortFinal
    cBuyLock := false

if finalBuy or earlyLongFinal
    cSellLock := false

watchRevLong  = watchRevLongRaw and not finalBuy and not finalSell and not earlyLongFinal
watchRevShort = watchRevShortRaw and not finalBuy and not finalSell and not earlyShortFinal

watchLong  = not finalBuy and trend == 1 and structBull and oscBullConfirm and (not effectiveUseHTF or not htfBear) and not earlyLongFinal
watchShort = not finalSell and trend == -1 and structBear and oscBearConfirm and (not effectiveUseHTF or not htfBull) and not earlyShortFinal

decisionText =
     finalBuy ? "BUY " + buyConfirmedGrade :
     finalSell ? "SELL " + sellConfirmedGrade :
     earlyLongFinal ? "BUY C" :
     earlyShortFinal ? "SELL C" :
     watchRevLong ? "WATCH REV LONG" :
     watchRevShort ? "WATCH REV SHORT" :
     watchLong ? "WATCH LONG" :
     watchShort ? "WATCH SHORT" :
     trend == 1 and htfBear and effectiveUseHTF ? "WAIT" :
     trend == -1 and htfBull and effectiveUseHTF ? "WAIT" :
     "NO TRADE"

//============================
// TARGETS
//============================
tp1Long  = close + targetAtr * effectiveTP1
tp2Long  = close + targetAtr * effectiveTP2
tp3Long  = close + targetAtr * effectiveTP3

tp1Short = close - targetAtr * effectiveTP1
tp2Short = close - targetAtr * effectiveTP2
tp3Short = close - targetAtr * effectiveTP3

//============================
// TRADE TRACKER / BOT ACTION STATE
//============================
anyBuySignal  = finalBuy or earlyLongFinal
anySellSignal = finalSell or earlyShortFinal
confirmedBuySignal = finalBuy
confirmedSellSignal = finalSell
cLongTradeSignal = allowC and earlyLongFinal and not finalBuy and not finalSell
cShortTradeSignal = allowC and earlyShortFinal and not finalBuy and not finalSell
tradeBuySignal = finalBuy or cLongTradeSignal
tradeSellSignal = finalSell or cShortTradeSignal

// Chart signals are independent of automation direction.
// Longs Only blocks tracked short entries/webhooks, but bearish chart analysis remains visible.
longChartSignal  = tradeBuySignal and not tradeActive
shortChartSignal = tradeSellSignal and not tradeActive

// C labels may remain visible without becoming tracked positions or bot entries unless All Grades is selected.
longEntryEvent  = longChartSignal
shortEntryEvent = shortChartSignal and botDirection == "Longs & Shorts"
useConfirmedOppositeExit = tradeExitTarget == "Confirmed Opposite A/B" or tradeExitTarget == "First TP or Confirmed Opposite"
useAnyOppositeExit = tradeExitTarget == "Any Opposite A/B/C"
closeLongOppositeEvent  = tradeActive and activeSide == "Long" and ((useConfirmedOppositeExit and confirmedSellSignal) or (useAnyOppositeExit and anySellSignal))
closeShortOppositeEvent = tradeActive and activeSide == "Short" and ((useConfirmedOppositeExit and confirmedBuySignal) or (useAnyOppositeExit and anyBuySignal))
longWarningEvent = tradeActive and activeSide == "Long" and anySellSignal and not closeLongOppositeEvent
shortWarningEvent = tradeActive and activeSide == "Short" and anyBuySignal and not closeShortOppositeEvent

// Chart signals consume analytical cooldowns/locks even when automation direction blocks execution.
// This prevents repeated bearish labels in Longs Only while preserving chart-side analysis.
if longChartSignal
    longBArmed := false
    shortBArmed := false
    longRearmReady := false
    if buyConfirmedGrade == "A" and not cLongTradeSignal
        lastASignalBar := bar_index
        buyALock := true
        sellALock := false
    else if not cLongTradeSignal
        lastBSignalBar := bar_index

if shortChartSignal
    longBArmed := false
    shortBArmed := false
    shortRearmReady := false
    if sellConfirmedGrade == "A" and not cShortTradeSignal
        lastASignalBar := bar_index
        sellALock := true
        buyALock := false
    else if not cShortTradeSignal
        lastBSignalBar := bar_index

// A new same-side trade requires a real reset after the prior position has closed.
longResetSeen = low <= basis or osc <= sig or trend != 1
shortResetSeen = high >= basis or osc >= sig or trend != -1
if not tradeActive and not longChartSignal and longResetSeen
    longRearmReady := true
if not tradeActive and not shortChartSignal and shortResetSeen
    shortRearmReady := true

// Dashboard decision reflects executable action or position management, not setup noise.
decisionText := tradeActive ? (activeSide == "Long" ? "HOLD LONG" : "HOLD SHORT") : longChartSignal ? "BUY " + (cLongTradeSignal ? "C" : buyConfirmedGrade) : shortChartSignal ? (botDirection == "Longs & Shorts" ? "SELL " : "BEARISH ") + (cShortTradeSignal ? "C" : sellConfirmedGrade) : earlyLongFinal ? "WATCH C LONG" : earlyShortFinal ? "WATCH C SHORT" : watchRevLong ? "WATCH REV LONG" : watchRevShort ? "WATCH REV SHORT" : watchLong ? "WATCH LONG" : watchShort ? "WATCH SHORT" : "NO TRADE"

//============================
// SIGNAL SOURCE / LABEL TOOLTIPS
//============================
buySource =
     bullBreakout ? "Breakout" :
     bullImpulse ? "Impulse" :
     bullEarlyReclaim ? "Early Reclaim" :
     buyRev ? "Reversal" :
     buyContA ? "Premium Pullback" :
     buyBFinal and longBPullbackEntry ? longBSetupSource + " → Pullback Hold" :
     buyBFinal and longBBreakEntry ? longBSetupSource + " → Setup Break" :
     cToBLongEvent ? "C-to-B Follow-Through" :
     trendTransitionBull ? "Early Trend Transition" :
     reclaimLong ? "Basis Reclaim" :
     pullbackTurnLongEvent ? "Pullback Momentum Turn" :
     momTurnLongEvent ? "Early Momentum Turn" :
     microBullEvent ? "Micro Higher Low" :
     "Confirmed Long"

sellSource =
     bearBreakout ? "Breakout" :
     bearImpulse ? "Impulse" :
     bearEarlyReclaim ? "Early Reclaim" :
     sellRev ? "Reversal" :
     sellContA ? "Premium Pullback" :
     sellBFinal and shortBPullbackEntry ? shortBSetupSource + " → Pullback Hold" :
     sellBFinal and shortBBreakEntry ? shortBSetupSource + " → Setup Break" :
     cToBShortEvent ? "C-to-B Follow-Through" :
     trendTransitionBear ? "Early Trend Transition" :
     reclaimShort ? "Basis Reject" :
     pullbackTurnShortEvent ? "Pullback Momentum Turn" :
     momTurnShortEvent ? "Early Momentum Turn" :
     microBearEvent ? "Micro Lower High" :
     "Confirmed Short"

trendTip = f_state(trend == 1, trend == -1)
htfTip = not effectiveUseHTF ? "Off" : f_state(htfBull, htfBear)
structTip = f_state(structBull, structBear)

buyActionTip = closeShortOppositeEvent ? "SHORT_BUY / Close Short" : longEntryEvent ? "LONG_BUY" : earlyLongFinal and not allowC ? "Chart guidance only — All Grades not selected" : "Chart signal only"
sellActionTip = closeLongOppositeEvent ? "LONG_SELL / Close Long" : shortEntryEvent ? "SHORT_SELL" : earlyShortFinal and not allowC ? "Chart guidance only — All Grades not selected" : botDirection == "Longs Only" ? "Chart signal only — shorts disabled" : "Chart signal only"

buyTooltip =
     "Alpha Forge BUY " + buyConfirmedGrade +
     "\nSource: " + buySource +
     "\nScore: " + str.tostring(buyScore) + "/100" +
     "\nTrend: " + trendTip +
     "\nHTF: " + htfTip +
     "\nStructure: " + structTip +
     "\nMomentum: " + momText +
     "\nRegime: " + regimeLabel +
     "\nPlanned R:R: " + f_fmt(longPlannedRR) +
     "\nInitial Stop: " + (na(longStopCandidate) ? "Off" : str.tostring(longStopCandidate, format.mintick)) +
     "\nTargets: " + f_fmt(effectiveTP1) + " / " + f_fmt(effectiveTP2) + " / " + f_fmt(effectiveTP3) + " ATR" +
     "\nRisk Reduce: " + (useRiskReduction ? riskReductionMode + " " + f_fmt(riskReductionTrigger) + " ATR → -" + f_fmt(riskReductionRiskAtr) + " ATR risk" : "Off") +
     "\nBE: " + effectiveBreakeven + " | Trail: " + (trailAfterTP2 ? f_fmt(effectiveTrailAtr) + " ATR after TP2" : "Off") +
     "\nEntry: " + str.tostring(close, format.mintick) +
     "\nEntry Stretch: " + f_fmt(longEntryDistanceAtr) + " ATR" +
     "\nEntry Candle: " + f_fmt(entryRangeAtr) + " ATR" +
     "\nBot Action: " + buyActionTip

sellTooltip =
     "Alpha Forge SELL " + sellConfirmedGrade +
     "\nSource: " + sellSource +
     "\nScore: " + str.tostring(sellScore) + "/100" +
     "\nTrend: " + trendTip +
     "\nHTF: " + htfTip +
     "\nStructure: " + structTip +
     "\nMomentum: " + momText +
     "\nRegime: " + regimeLabel +
     "\nPlanned R:R: " + f_fmt(shortPlannedRR) +
     "\nInitial Stop: " + (na(shortStopCandidate) ? "Off" : str.tostring(shortStopCandidate, format.mintick)) +
     "\nTargets: " + f_fmt(effectiveTP1) + " / " + f_fmt(effectiveTP2) + " / " + f_fmt(effectiveTP3) + " ATR" +
     "\nRisk Reduce: " + (useRiskReduction ? riskReductionMode + " " + f_fmt(riskReductionTrigger) + " ATR → -" + f_fmt(riskReductionRiskAtr) + " ATR risk" : "Off") +
     "\nBE: " + effectiveBreakeven + " | Trail: " + (trailAfterTP2 ? f_fmt(effectiveTrailAtr) + " ATR after TP2" : "Off") +
     "\nEntry: " + str.tostring(close, format.mintick) +
     "\nEntry Stretch: " + f_fmt(shortEntryDistanceAtr) + " ATR" +
     "\nEntry Candle: " + f_fmt(entryRangeAtr) + " ATR" +
     "\nBot Action: " + sellActionTip

cBuyTooltip =
     "Alpha Forge BUY C" +
     "\nSource: Early Counter-Trend Reversal" +
     "\nTrend: " + trendTip +
     "\nHTF: " + htfTip +
     "\nStructure: " + structTip +
     "\nMomentum: " + momText +
     "\nEntry: " + str.tostring(close, format.mintick) +
     "\nRisk: Earlier and less confirmed than A/B" +
     "\nBot Action: " + buyActionTip

cSellTooltip =
     "Alpha Forge SELL C" +
     "\nSource: Early Counter-Trend Reversal" +
     "\nTrend: " + trendTip +
     "\nHTF: " + htfTip +
     "\nStructure: " + structTip +
     "\nMomentum: " + momText +
     "\nEntry: " + str.tostring(close, format.mintick) +
     "\nRisk: Earlier and less confirmed than A/B" +
     "\nBot Action: " + sellActionTip

//============================
// VISUALS
//============================
basisColor = trend == 1 ? basisBull : trend == -1 ? basisBear : basisNeutral

pUpper = plot(showBands ? upper : na, "Upper Band", color=bandBear, linewidth=1)
pLower = plot(showBands ? lower : na, "Lower Band", color=bandBull, linewidth=1)

plot(showBasis and showMidGlow ? basis : na, "Basis Glow 4", color=color.new(basisColor, 92), linewidth=12)
plot(showBasis and showMidGlow ? basis : na, "Basis Glow 3", color=color.new(basisColor, 86), linewidth=9)
plot(showBasis and showMidGlow ? basis : na, "Basis Glow 2", color=color.new(basisColor, 78), linewidth=6)
plot(showBasis and showMidGlow ? basis : na, "Basis Glow 1", color=color.new(basisColor, 66), linewidth=4)
pBasisMain = plot(showBasis ? basis : na, "Basis", color=basisColor, linewidth=3)

fillColor =
     trend == 1 ? bullFillSoft :
     trend == -1 ? bearFillSoft :
     color.new(neutral, 94)

fill(pBasisMain, pLower, color=showBandFill and trend == 1 ? bullFillStrong : na)
fill(pBasisMain, pUpper, color=showBandFill and trend == -1 ? bearFillStrong : na)
fill(pUpper, pLower, color=showBandFill ? fillColor : na)

bgcolor(showGradient ? (trend == 1 ? (visualStyle == "Cinematic" ? bullBgCine : bullBgClean) : trend == -1 ? (visualStyle == "Cinematic" ? bearBgCine : bearBgClean) : na) : na)
barcolor(tintBars ? (trend == 1 ? color.new(bullSoft, 72) : trend == -1 ? color.new(bearSoft, 72) : na) : na)

//============================
// LABEL / MARKER COLORS
//============================
buyColorAB  = buyConfirmedGrade == "A" ? gradeA_Buy : gradeB_Buy
sellColorAB = sellConfirmedGrade == "A" ? gradeA_Sell : gradeB_Sell

labelOffset  = atrVal * 0.22
structOffset = atrVal * 0.14

if showSignals and longChartSignal
    string chartBuyGrade = cLongTradeSignal ? "C" : buyConfirmedGrade
    color chartBuyColor = cLongTradeSignal ? gradeC_Buy : buyColorAB
    string chartBuyTooltip = cLongTradeSignal ? cBuyTooltip : buyTooltip
    string buyLabelText = buyRev and not cLongTradeSignal ? "BUY " + chartBuyGrade + " REV" : "BUY " + chartBuyGrade
    label.new(bar_index, low - labelOffset, buyLabelText, style=label.style_label_up, color=color.new(chartBuyColor, 8), textcolor=color.black, size=size.tiny, tooltip=chartBuyTooltip)

if showSignals and shortChartSignal
    string chartSellGrade = cShortTradeSignal ? "C" : sellConfirmedGrade
    color chartSellColor = cShortTradeSignal ? gradeC_Sell : sellColorAB
    string chartSellTooltip = cShortTradeSignal ? cSellTooltip : sellTooltip
    string sellLabelText = sellRev and not cShortTradeSignal ? "SELL " + chartSellGrade + " REV" : "SELL " + chartSellGrade
    label.new(bar_index, high + labelOffset, sellLabelText, style=label.style_label_down, color=color.new(chartSellColor, 8), textcolor=color.white, size=size.tiny, tooltip=chartSellTooltip)

plotshape(showWatchs and watchLong ? low - labelOffset * 0.40 : na, title="Watch Long", style=shape.circle, location=location.absolute, color=color.new(bull, 22), size=size.tiny)
plotshape(showWatchs and watchShort ? high + labelOffset * 0.40 : na, title="Watch Short", style=shape.circle, location=location.absolute, color=color.new(bear, 22), size=size.tiny)

plotshape(showWatchs and watchRevLong ? low - labelOffset * 0.62 : na, title="Watch Rev Long", style=shape.diamond, location=location.absolute, color=color.new(bull, 6), size=size.tiny)
plotshape(showWatchs and watchRevShort ? high + labelOffset * 0.62 : na, title="Watch Rev Short", style=shape.diamond, location=location.absolute, color=color.new(bear, 6), size=size.tiny)

plotshape(showStructure and bullBOS ? high + structOffset : na, title="Bull BOS", style=shape.circle, location=location.absolute, color=color.new(bull, 18), size=size.tiny)
plotshape(showStructure and bearBOS ? low - structOffset : na, title="Bear BOS", style=shape.circle, location=location.absolute, color=color.new(bear, 18), size=size.tiny)

plotshape(showStructure and bullCHOCH ? high + structOffset * 1.45 : na, title="Bull CHOCH", style=shape.diamond, location=location.absolute, color=color.new(bull, 8), size=size.tiny)
plotshape(showStructure and bearCHOCH ? low - structOffset * 1.45 : na, title="Bear CHOCH", style=shape.diamond, location=location.absolute, color=color.new(bear, 8), size=size.tiny)

if showSignals and showCGuidance and earlyLongFinal and not allowC
    label.new(bar_index, low - labelOffset * 1.6, "BUY C", style=label.style_label_up, color=color.new(gradeC_Buy, 0), textcolor=color.black, size=size.tiny, tooltip=cBuyTooltip)

if showSignals and showCGuidance and earlyShortFinal and not allowC
    label.new(bar_index, high + labelOffset * 1.6, "SELL C", style=label.style_label_down, color=color.new(gradeC_Sell, 0), textcolor=color.white, size=size.tiny, tooltip=cSellTooltip)

//============================
// TP LINES / LIVE TARGET UPDATES
//============================
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label tp1Lab = na
var label tp2Lab = na
var label tp3Lab = na

var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var bool activeLong = false
var int activeSignalBar = na

if longEntryEvent or shortEntryEvent
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(tp1Lab)
        label.delete(tp1Lab)
    if not na(tp2Lab)
        label.delete(tp2Lab)
    if not na(tp3Lab)
        label.delete(tp3Lab)
    tp1Line := na
    tp2Line := na
    tp3Line := na
    tp1Lab := na
    tp2Lab := na
    tp3Lab := na

    activeLong := longEntryEvent
    activeSignalBar := bar_index
    activeTP1 := activeLong ? tp1Long : tp1Short
    activeTP2 := activeLong ? tp2Long : tp2Short
    activeTP3 := activeLong ? tp3Long : tp3Short
    tradeActive := true
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    activeSide := activeLong ? "Long" : "Short"
    trackedEntryPrice := close
    trackedEntryGrade := activeLong ? (cLongTradeSignal ? "C" : buyConfirmedGrade) : (cShortTradeSignal ? "C" : sellConfirmedGrade)
    activeStop := activeLong ? longStopCandidate : shortStopCandidate
    activeTrail := na
    trailAnchor := na
    activeEntryBar := bar_index
    activeEntryAtr := targetAtr
    activeMFEAtr := 0.0
    riskReductionActive := false
    pendingStop := na
    pendingStopBar := na
    pendingStopReason := ""
    tp1HitBar := na
    tp2HitBar := na
    trailActivationAtr := na
    lastExitReason := "None"

    tpTextColor = activeLong ? color.black : color.white

    if showTP1
        tp1Line := line.new(activeSignalBar, activeTP1, activeSignalBar + tpBarsForward, activeTP1, xloc=xloc.bar_index, extend=extend.none, color=activeLong ? color.new(bull, 45) : color.new(bear, 45), width=1, style=line.style_dashed)
        if showTPLabels
            tp1Lab := label.new(activeSignalBar + tpBarsForward, activeTP1, "TP1", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=activeLong ? color.new(bull, 10) : color.new(bear, 10), size=size.tiny)

    if showTP2
        tp2Line := line.new(activeSignalBar, activeTP2, activeSignalBar + tpBarsForward, activeTP2, xloc=xloc.bar_index, extend=extend.none, color=activeLong ? color.new(bull, 62) : color.new(bear, 62), width=1, style=line.style_dashed)
        if showTPLabels
            tp2Lab := label.new(activeSignalBar + tpBarsForward, activeTP2, "TP2", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=activeLong ? color.new(bull, 20) : color.new(bear, 20), size=size.tiny)

    if showTP3
        tp3Line := line.new(activeSignalBar, activeTP3, activeSignalBar + tpBarsForward, activeTP3, xloc=xloc.bar_index, extend=extend.none, color=activeLong ? color.new(bull, 78) : color.new(bear, 78), width=1, style=line.style_dashed)
        if showTPLabels
            tp3Lab := label.new(activeSignalBar + tpBarsForward, activeTP3, "TP3", xloc=xloc.bar_index, style=label.style_label_left, textcolor=tpTextColor, color=activeLong ? color.new(bull, 30) : color.new(bear, 30), size=size.tiny)

// Targets are evaluated only after the close-confirmed entry candle.
newTP1Hit = tradeActive and bar_index > activeSignalBar and not tp1Hit and (activeSide == "Long" ? high >= activeTP1 : low <= activeTP1)
newTP2Hit = tradeActive and bar_index > activeSignalBar and not tp2Hit and (activeSide == "Long" ? high >= activeTP2 : low <= activeTP2)
newTP3Hit = tradeActive and bar_index > activeSignalBar and not tp3Hit and (activeSide == "Long" ? high >= activeTP3 : low <= activeTP3)

if newTP1Hit
    tp1Hit := true
    tp1HitBar := bar_index
    if not na(tp1Line)
        line.set_style(tp1Line, line.style_solid)
        line.set_width(tp1Line, 2)
        line.set_color(tp1Line, color.new(color.white, 35))
    if not na(tp1Lab)
        label.set_text(tp1Lab, "TP1 ✓")
        label.set_textcolor(tp1Lab, color.black)
        label.set_color(tp1Lab, color.white)

if newTP2Hit
    tp2Hit := true
    tp2HitBar := bar_index
    trailActivationAtr := activeEntryAtr
    if not na(tp2Line)
        line.set_style(tp2Line, line.style_solid)
        line.set_width(tp2Line, 2)
        line.set_color(tp2Line, color.new(color.white, 35))
    if not na(tp2Lab)
        label.set_text(tp2Lab, "TP2 ✓")
        label.set_textcolor(tp2Lab, color.black)
        label.set_color(tp2Lab, color.white)

if newTP3Hit
    tp3Hit := true
    if not na(tp3Line)
        line.set_style(tp3Line, line.style_solid)
        line.set_width(tp3Line, 2)
        line.set_color(tp3Line, color.new(color.white, 35))
    if not na(tp3Lab)
        label.set_text(tp3Lab, "TP3 ✓")
        label.set_textcolor(tp3Lab, color.black)
        label.set_color(tp3Lab, color.white)

exitAtTP1 = (tradeExitTarget == "TP1" or tradeExitTarget == "First TP or Confirmed Opposite") and newTP1Hit
exitAtTP2 = tradeExitTarget == "TP2" and newTP2Hit
exitAtTP3 = tradeExitTarget == "TP3" and newTP3Hit
longTargetExitEvent  = tradeActive and activeSide == "Long" and (exitAtTP1 or exitAtTP2 or exitAtTP3)
shortTargetExitEvent = tradeActive and activeSide == "Short" and (exitAtTP1 or exitAtTP2 or exitAtTP3)

// Entry-quality diagnostics: only use price action after the confirmed entry candle.
if tradeActive and bar_index > activeSignalBar and not na(trackedEntryPrice) and not na(activeEntryAtr) and activeEntryAtr > 0
    currentMFEAtr = activeSide == "Long" ? math.max(0.0, high - trackedEntryPrice) / activeEntryAtr : math.max(0.0, trackedEntryPrice - low) / activeEntryAtr
    activeMFEAtr := math.max(activeMFEAtr, currentMFEAtr)

// Activate protection scheduled on a prior candle. A new stop can never be created and
// retroactively hit by an earlier extreme from the same candle.
if tradeActive and not na(pendingStop) and not na(pendingStopBar) and bar_index > pendingStopBar
    activeStop := activeSide == "Long" ? math.max(nz(activeStop, pendingStop), pendingStop) : math.min(nz(activeStop, pendingStop), pendingStop)
    riskReductionActive := pendingStopReason == "Risk Reduction" ? true : riskReductionActive
    pendingStop := na
    pendingStopBar := na
    pendingStopReason := ""

// Schedule risk reduction for the next candle only.
riskReductionReady = tradeActive and bar_index > activeSignalBar and useRiskReduction and not riskReductionActive and na(pendingStop) and activeMFEAtr >= riskReductionTrigger and not na(trackedEntryPrice) and not na(activeEntryAtr)
if riskReductionReady
    pendingStop := activeSide == "Long" ? trackedEntryPrice - activeEntryAtr * riskReductionRiskAtr : trackedEntryPrice + activeEntryAtr * riskReductionRiskAtr
    pendingStopBar := bar_index
    pendingStopReason := "Risk Reduction"
    riskReductionCount += 1

// Schedule breakeven only after the target-trigger candle has closed.
breakevenHitBar = effectiveBreakeven == "After TP1" ? tp1HitBar : effectiveBreakeven == "After TP2" ? tp2HitBar : na
breakevenReady = tradeActive and effectiveBreakeven != "Off" and not na(breakevenHitBar) and bar_index > breakevenHitBar and not na(trackedEntryPrice)
if breakevenReady
    activeStop := activeSide == "Long" ? math.max(nz(activeStop, trackedEntryPrice), trackedEntryPrice) : math.min(nz(activeStop, trackedEntryPrice), trackedEntryPrice)

// TP2 trailing begins on the candle after TP2. Use ATR captured at entry/activation,
// not a shrinking live ATR that can silently tighten protection.
trailReady = tradeActive and trailAfterTP2 and tp2Hit and not na(tp2HitBar) and bar_index > tp2HitBar
if trailReady
    trailReference = trailSource == "Highest Close" ? close : activeSide == "Long" ? high : low
    trailAnchor := na(trailAnchor) ? trailReference : activeSide == "Long" ? math.max(trailAnchor, trailReference) : math.min(trailAnchor, trailReference)
    trailAtrBase = nz(trailActivationAtr, activeEntryAtr)
    trailCandidate = activeSide == "Long" ? trailAnchor - trailAtrBase * effectiveTrailAtr : trailAnchor + trailAtrBase * effectiveTrailAtr
    activeTrail := na(activeTrail) ? trailCandidate : activeSide == "Long" ? math.max(activeTrail, trailCandidate) : math.min(activeTrail, trailCandidate)

protectiveLevel = tradeActive ? (na(activeTrail) ? activeStop : activeSide == "Long" ? math.max(nz(activeStop, activeTrail), activeTrail) : math.min(nz(activeStop, activeTrail), activeTrail)) : na
stopHitEvent = tradeActive and bar_index > activeSignalBar and not na(protectiveLevel) and (activeSide == "Long" ? low <= protectiveLevel : high >= protectiveLevel)

selectedTargetHit = longTargetExitEvent or shortTargetExitEvent
processStopFirst = intrabarPriority == "Stop First"
finalStopExit = stopHitEvent and (processStopFirst or not selectedTargetHit)
finalTargetExit = selectedTargetHit and (not processStopFirst or not stopHitEvent)
closeLongEvent  = tradeActive and activeSide == "Long" and (closeLongOppositeEvent or finalTargetExit or finalStopExit)
closeShortEvent = tradeActive and activeSide == "Short" and (closeShortOppositeEvent or finalTargetExit or finalStopExit)
longStopAction = closeLongEvent and finalStopExit
shortStopAction = closeShortEvent and finalStopExit

if closeLongEvent or closeShortEvent
    float exitPrice = na
    string exitReason = "Unknown"
    if finalStopExit
        exitPrice := protectiveLevel
        bool trailControlsExit = not na(activeTrail) and (na(activeStop) or (activeSide == "Long" ? activeTrail > activeStop + syminfo.mintick * 0.5 : activeTrail < activeStop - syminfo.mintick * 0.5))
        bool atBreakeven = not trailControlsExit and not na(activeStop) and math.abs(activeStop - trackedEntryPrice) <= syminfo.mintick
        exitReason := trailControlsExit ? "Trailing Stop" : atBreakeven ? "Breakeven" : riskReductionActive ? "Risk Reduction" : "Stop Loss"
    else if finalTargetExit
        exitPrice := exitAtTP1 ? activeTP1 : exitAtTP2 ? activeTP2 : activeTP3
        exitReason := exitAtTP1 ? "TP1" : exitAtTP2 ? "TP2" : "TP3"
    else
        exitPrice := close
        exitReason := useAnyOppositeExit ? "Opposite A/B/C" : "Opposite A/B"
    if not na(trackedEntryPrice)
        tradePct = activeSide == "Long" ? ((exitPrice - trackedEntryPrice) / trackedEntryPrice) * 100.0 : ((trackedEntryPrice - exitPrice) / trackedEntryPrice) * 100.0
        if (exitReason == "Stop Loss" or exitReason == "Risk Reduction") and not na(activeEntryBar)
            barsHeldAtStop = bar_index - activeEntryBar
            if barsHeldAtStop <= 1
                earlyStop1Count += 1
            if barsHeldAtStop <= 3
                earlyStop3Count += 1
            stoppedMfeSum += activeMFEAtr
            stoppedMfeCount += 1
        f_push_stat(tradePct, trackedEntryGrade, exitReason, statsLookback)
    lastExitReason := exitReason
    tradeActive := false
    activeSide := "None"
    trackedEntryPrice := na
    trackedEntryGrade := ""
    activeStop := na
    activeTrail := na
    trailAnchor := na
    activeEntryBar := na
    activeEntryAtr := na
    activeMFEAtr := 0.0
    riskReductionActive := false
    pendingStop := na
    pendingStopBar := na
    pendingStopReason := ""
    tp1HitBar := na
    tp2HitBar := na
    trailActivationAtr := na

plot(tradeActive ? protectiveLevel : na, "Active Protection", color=color.new(color.orange, 10), linewidth=2, style=plot.style_linebr)
plotshape(showSignals and longWarningEvent ? high + atrVal * 0.10 : na, title="Long Warning", style=shape.flag, location=location.absolute, color=color.new(bear, 5), text="WARN", textcolor=color.white, size=size.tiny)
plotshape(showSignals and shortWarningEvent ? low - atrVal * 0.10 : na, title="Short Warning", style=shape.flag, location=location.absolute, color=color.new(bull, 5), text="WARN", textcolor=color.black, size=size.tiny)

//============================
// SIGNAL FREQUENCY AUDIT
//============================
rawLongSetup = trend == 1 and close > basis and oscBullConfirm
rawShortSetup = trend == -1 and close < basis and oscBearConfirm
blockLongHTF = rawLongSetup and not htfOkBull
blockShortHTF = rawShortSetup and not htfOkBear
blockLongStruct = rawLongSetup and strongStructOppLong
blockShortStruct = rawShortSetup and strongStructOppShort
blockLongMomentum = trend == 1 and close > basis and not oscBullConfirm
blockShortMomentum = trend == -1 and close < basis and not oscBearConfirm
blockLongStretch = rawLongSetup and not notTooStretchedLong
blockShortStretch = rawShortSetup and not notTooStretchedShort
blockLongScore = rawLongSetup and not buyAQualified and not buyBQualified
blockShortScore = rawShortSetup and not sellAQualified and not sellBQualified
blockLongBEligibility = rawLongSetup and not buyAQualified and not bLongEligible
blockShortBEligibility = rawShortSetup and not sellAQualified and not bShortEligible
blockLongCooldown = finalBuyBase and buyAllowed and ((buyConfirmedGrade == "A" and not aBarsOk) or (buyConfirmedGrade == "B" and not bBarsOk))
blockShortCooldown = finalSellBase and sellAllowed and ((sellConfirmedGrade == "A" and not aBarsOk) or (sellConfirmedGrade == "B" and not bBarsOk))
blockLongEntryDistance = longBArmed and longEntryDistanceAtr > effectiveBMaxDistance
blockShortEntryDistance = shortBArmed and shortEntryDistanceAtr > effectiveBMaxDistance
blockLongEntryCandle = longBArmed and entryRangeAtr > effectiveBMaxCandle
blockShortEntryCandle = shortBArmed and entryRangeAtr > effectiveBMaxCandle
blockLongEntryQuality = blockLongEntryDistance or blockLongEntryCandle
blockShortEntryQuality = blockShortEntryDistance or blockShortEntryCandle
longBExpiredEvent = longBExpired and not longBExpired[1]
shortBExpiredEvent = shortBExpired and not shortBExpired[1]

f_roll_count(_cond, _len) =>
    int(math.round(nz(ta.sma(_cond ? 1.0 : 0.0, _len), 0.0) * _len))

auditRaw = f_roll_count(rawLongSetup or rawShortSetup, auditBars)
auditHTF = f_roll_count(blockLongHTF or blockShortHTF, auditBars)
auditStruct = f_roll_count(blockLongStruct or blockShortStruct, auditBars)
auditMom = f_roll_count(blockLongMomentum or blockShortMomentum, auditBars)
auditStretch = f_roll_count(blockLongStretch or blockShortStretch, auditBars)
auditScore = f_roll_count(blockLongScore or blockShortScore, auditBars)
auditBEligibility = f_roll_count(blockLongBEligibility or blockShortBEligibility, auditBars)
auditLock = f_roll_count(blockLongCooldown or blockShortCooldown, auditBars)
auditEntryQuality = f_roll_count(blockLongEntryQuality or blockShortEntryQuality, auditBars)
auditEntryDistance = f_roll_count(blockLongEntryDistance or blockShortEntryDistance, auditBars)
auditEntryCandle = f_roll_count(blockLongEntryCandle or blockShortEntryCandle, auditBars)
auditSetupExpired = f_roll_count(longBExpiredEvent or shortBExpiredEvent, auditBars)
auditA = f_roll_count(finalBuy and buyConfirmedGrade == "A" or finalSell and sellConfirmedGrade == "A", auditBars)
auditB = f_roll_count(finalBuy and buyConfirmedGrade == "B" or finalSell and sellConfirmedGrade == "B", auditBars)

//============================
// DASHBOARD VALUES
//============================
dashPos = f_dash_pos(dashboardPos)

regimeText = trend == 1 ? "Bull" : trend == -1 ? "Bear" : "Neutral"
adaptiveRegimeText = regimeLabel
regimeBg   = trend == 1 ? color.new(bull, 10) : trend == -1 ? color.new(bear, 10) : color.new(neutral, 30)

momBg = momBull ? color.new(bull, 20) : momBear ? color.new(bear, 20) : color.new(neutral, 35)
htfText = not effectiveUseHTF ? "Off" : htfDataModeText + " | " + htfStateText
htfBg   = not effectiveUseHTF ? color.new(neutral, 50) : htfBull ? color.new(bull, 20) : htfBear ? color.new(bear, 20) : color.new(neutral, 35)

structText = structBull ? "Bull" : structBear ? "Bear" : "Neutral"
structBg   = structBull ? color.new(bull, 20) : structBear ? color.new(bear, 20) : color.new(neutral, 35)

tradeText = tradeActive ? activeSide + (trackedEntryGrade == "" ? "" : " " + trackedEntryGrade) : "None"
tradeBg   = activeSide == "Long" ? color.new(bull, 18) : activeSide == "Short" ? color.new(bear, 18) : color.new(neutral, 35)

tp1Text = tradeActive ? (tp1Hit ? "Hit" : "Live") : "n/a"
tp2Text = tradeActive ? (tp2Hit ? "Hit" : "Live") : "n/a"
tp3Text = tradeActive ? (tp3Hit ? "Hit" : "Live") : "n/a"

tp1Bg = tp1Hit ? color.new(color.white, 5) : color.new(neutral, 35)
tp2Bg = tp2Hit ? color.new(color.white, 5) : color.new(neutral, 35)
tp3Bg = tp3Hit ? color.new(color.white, 5) : color.new(neutral, 35)

decisionBg =
     tradeActive ? (activeSide == "Long" ? color.new(bull, 18) : color.new(bear, 18)) :
     longChartSignal ? color.new(cLongTradeSignal ? gradeC_Buy : buyColorAB, 10) :
     shortChartSignal ? color.new(cShortTradeSignal ? gradeC_Sell : sellColorAB, 10) :
     earlyLongFinal ? color.new(gradeC_Buy, 15) :
     earlyShortFinal ? color.new(gradeC_Sell, 15) :
     color.new(neutral, 35)

//============================
// TRUE TRACKED TRADE STATS
//============================
statWinCount = 0
statLossCount = 0
statBECount = 0
statGrossProfit = 0.0
statGrossLoss = 0.0
statNetPct = 0.0
statWinSum = 0.0
statLossSum = 0.0

// Grade-separated test statistics.
statAWins = 0
statALosses = 0
statAGrossProfit = 0.0
statAGrossLoss = 0.0
statBWins = 0
statBLosses = 0
statBGrossProfit = 0.0
statBGrossLoss = 0.0
statCWins = 0
statCLosses = 0
statCGrossProfit = 0.0
statCGrossLoss = 0.0

// Exit-reason counts reveal what is shaping PF.
statTPExits = 0
statStopExits = 0
statBEExits = 0
statTrailExits = 0
statSoftExits = 0
statOppExits = 0

if array.size(statPcts) > 0
    for i = 0 to array.size(statPcts) - 1
        tradeReturn = array.get(statPcts, i)
        tradeGrade = array.get(statGrades, i)
        tradeReason = array.get(statReasons, i)
        statNetPct += tradeReturn

        if tradeReturn > 0
            statWinCount += 1
            statGrossProfit += tradeReturn
            statWinSum += tradeReturn
        else if tradeReturn < 0
            statLossCount += 1
            statGrossLoss += math.abs(tradeReturn)
            statLossSum += math.abs(tradeReturn)
        else
            statBECount += 1

        if tradeGrade == "A"
            if tradeReturn > 0
                statAWins += 1
                statAGrossProfit += tradeReturn
            else if tradeReturn < 0
                statALosses += 1
                statAGrossLoss += math.abs(tradeReturn)
        else if tradeGrade == "B"
            if tradeReturn > 0
                statBWins += 1
                statBGrossProfit += tradeReturn
            else if tradeReturn < 0
                statBLosses += 1
                statBGrossLoss += math.abs(tradeReturn)
        else if tradeGrade == "C"
            if tradeReturn > 0
                statCWins += 1
                statCGrossProfit += tradeReturn
            else if tradeReturn < 0
                statCLosses += 1
                statCGrossLoss += math.abs(tradeReturn)

        if tradeReason == "TP1" or tradeReason == "TP2" or tradeReason == "TP3"
            statTPExits += 1
        else if tradeReason == "Stop Loss"
            statStopExits += 1
        else if tradeReason == "Breakeven"
            statBEExits += 1
        else if tradeReason == "Trailing Stop"
            statTrailExits += 1
        else if tradeReason == "Risk Reduction"
            statSoftExits += 1
        else if tradeReason == "Opposite A/B" or tradeReason == "Opposite A/B/C"
            statOppExits += 1

statClosedTrades = array.size(statPcts)
statDecidedTrades = statWinCount + statLossCount
statWinRate = statDecidedTrades > 0 ? (float(statWinCount) / float(statDecidedTrades)) * 100.0 : na
statProfitFactor = statGrossLoss > 0 ? statGrossProfit / statGrossLoss : statGrossProfit > 0 ? 999.0 : na
statAvgWin = statWinCount > 0 ? statWinSum / statWinCount : na
statAvgLoss = statLossCount > 0 ? statLossSum / statLossCount : na
statPayoff = not na(statAvgWin) and not na(statAvgLoss) and statAvgLoss > 0 ? statAvgWin / statAvgLoss : na
statExpectancy = statDecidedTrades > 0 ? (statWinRate / 100.0) * nz(statAvgWin, 0.0) - (1.0 - statWinRate / 100.0) * nz(statAvgLoss, 0.0) : na

statADecided = statAWins + statALosses
statBDecided = statBWins + statBLosses
statCDecided = statCWins + statCLosses
statAWR = statADecided > 0 ? float(statAWins) / float(statADecided) * 100.0 : na
statBWR = statBDecided > 0 ? float(statBWins) / float(statBDecided) * 100.0 : na
statCWR = statCDecided > 0 ? float(statCWins) / float(statCDecided) * 100.0 : na
statAPF = statAGrossLoss > 0 ? statAGrossProfit / statAGrossLoss : statAGrossProfit > 0 ? 999.0 : na
statBPF = statBGrossLoss > 0 ? statBGrossProfit / statBGrossLoss : statBGrossProfit > 0 ? 999.0 : na
statCPF = statCGrossLoss > 0 ? statCGrossProfit / statCGrossLoss : statCGrossProfit > 0 ? 999.0 : na

statWLText = statClosedTrades > 0 ? str.tostring(statWinCount) + " / " + str.tostring(statLossCount) + " / " + str.tostring(statBECount) : "n/a"
statWinRateText = statDecidedTrades > 0 ? f_fmt(statWinRate) + "%" : "n/a"
statPFText = statGrossLoss > 0 ? f_fmt(statProfitFactor) : statGrossProfit > 0 ? "∞" : "n/a"
statNetText = statClosedTrades > 0 ? f_fmt(statNetPct) + "%" : "n/a"
statAvgText = not na(statAvgWin) or not na(statAvgLoss) ? f_fmt(nz(statAvgWin, 0.0)) + "% / " + f_fmt(nz(statAvgLoss, 0.0)) + "%" : "n/a"
statPayoffText = not na(statPayoff) ? f_fmt(statPayoff) : "n/a"
statExpectancyText = not na(statExpectancy) ? f_fmt(statExpectancy) + "%" : "n/a"
statAText = statADecided > 0 ? "n=" + str.tostring(statADecided) + "  " + f_fmt(statAWR) + "% / " + (statAGrossLoss > 0 ? f_fmt(statAPF) : "∞") : "n/a"
statBText = statBDecided > 0 ? "n=" + str.tostring(statBDecided) + "  " + f_fmt(statBWR) + "% / " + (statBGrossLoss > 0 ? f_fmt(statBPF) : "∞") : "n/a"
statCText = statCDecided > 0 ? "n=" + str.tostring(statCDecided) + "  " + f_fmt(statCWR) + "% / " + (statCGrossLoss > 0 ? f_fmt(statCPF) : "∞") : "n/a"
statExitText = str.tostring(statTPExits) + " / " + str.tostring(statStopExits) + " / " + str.tostring(statSoftExits) + " / " + str.tostring(statBEExits) + " / " + str.tostring(statTrailExits) + " / " + str.tostring(statOppExits)

statWLBg = statClosedTrades > 0 and statWinCount >= statLossCount ? color.new(bull, 18) : color.new(bear, 18)
statWinBg = statDecidedTrades > 0 and statWinRate >= 50 ? color.new(bull, 18) : color.new(bear, 18)
statPFBg = not na(statProfitFactor) and statProfitFactor >= 1.0 ? color.new(bull, 18) : color.new(bear, 18)
statNetBg = statClosedTrades > 0 and statNetPct >= 0 ? color.new(bull, 18) : color.new(bear, 18)

//============================
// LIVE FORGE GUIDE — FORWARD-LOOKING COACHING
//============================
forgeTextSize = forgeGuideSize == "Tiny" ? size.tiny : forgeGuideSize == "Normal" ? size.normal : size.small

longBRemaining = longBArmed and not na(longBSetupBar) ? math.max(0, effectiveBExpiry - (bar_index - longBSetupBar)) : 0
shortBRemaining = shortBArmed and not na(shortBSetupBar) ? math.max(0, effectiveBExpiry - (bar_index - shortBSetupBar)) : 0

longNearReady = not tradeActive and trend == 1 and not longEntryEvent and not longBArmed and rawLongSetup
shortNearReady = not tradeActive and trend == -1 and not shortEntryEvent and not shortBArmed and rawShortSetup

forgeTitle = "FORGE GUIDE"
forgeAction = "WAIT"
forgeLine1 = "Watching for a confirmed setup"
forgeLine2 = trend == 1 ? "Watch: bullish momentum expansion" : trend == -1 ? "Watch: bearish momentum expansion" : "Watch: trend direction to establish"
forgeLine3 = regimeIsRange ? "Avoid: entries inside low expansion" : "Next: structure and momentum alignment"
forgeLine4 = ""

if tradeActive
    forgeAction := activeSide == "Long" ? "MANAGE LONG" : "MANAGE SHORT"
    forgeLine1 := tp3Hit ? "Objective: TP3 reached" : tp2Hit ? "Next objective: TP3" : tp1Hit ? "Next objective: TP2" : "Next objective: TP1"
    forgeLine2 := not na(protectiveLevel) ? "Protection: " + str.tostring(protectiveLevel, format.mintick) : "Protection: pending"
    forgeLine3 := tp2Hit and not na(activeTrail) ? "Trail active — hold while it survives" : "Trade valid while protection holds"
    forgeLine4 := longWarningEvent or shortWarningEvent ? "Watch: opposite-cycle warning" : tp2Hit ? "Watch: trail or TP3" : "Watch: target or protection"
else if longEntryEvent
    forgeAction := "BUY READY"
    forgeLine1 := "Confirmed long entry"
    forgeLine2 := "Grade: " + (cLongTradeSignal ? "C" : buyConfirmedGrade) + " | Trigger: candle close"
    forgeLine3 := na(longStopCandidate) ? "Initial protection: Off" : "Initial protection: " + str.tostring(longStopCandidate, format.mintick)
    forgeLine4 := "Next: manage TP1 / TP2 / TP3"
else if shortChartSignal
    forgeAction := botDirection == "Longs & Shorts" ? "SELL READY" : "BEARISH SIGNAL"
    forgeLine1 := botDirection == "Longs & Shorts" ? "Confirmed short entry" : "Confirmed bearish chart signal"
    forgeLine2 := "Grade: " + (cShortTradeSignal ? "C" : sellConfirmedGrade) + " | Trigger: candle close"
    forgeLine3 := botDirection == "Longs & Shorts" ? (na(shortStopCandidate) ? "Initial protection: Off" : "Initial protection: " + str.tostring(shortStopCandidate, format.mintick)) : "Automation: short entries disabled"
    forgeLine4 := botDirection == "Longs & Shorts" ? "Next: manage TP1 / TP2 / TP3" : "Use as analysis or long-exit context"
else if longBArmed
    forgeAction := "WATCH LONG"
    forgeLine1 := "B setup armed: " + longBSetupSource
    forgeLine2 := "Trigger: close above " + str.tostring(longBSetupHigh, format.mintick)
    forgeLine3 := "Invalid below: " + str.tostring(longBSetupLow, format.mintick)
    forgeLine4 := "Window: " + str.tostring(longBRemaining) + " bars"
else if shortBArmed
    forgeAction := "WATCH SHORT"
    forgeLine1 := "B setup armed: " + shortBSetupSource
    forgeLine2 := "Trigger: close below " + str.tostring(shortBSetupLow, format.mintick)
    forgeLine3 := "Invalid above: " + str.tostring(shortBSetupHigh, format.mintick)
    forgeLine4 := "Window: " + str.tostring(shortBRemaining) + " bars"
else if longNearReady
    forgeAction := "LONG NEAR READY"
    forgeLine1 := not structBull ? "Waiting: bullish structure reclaim" : momText == "Neutral" ? "Waiting: bullish momentum" : not bLongEligible and not buyAQualified ? "Waiting: trend expansion" : "Waiting: confirmed trigger"
    forgeLine2 := trackedGrades == "A Only" ? "Score: " + str.tostring(buyScore) + " | A needs 80" : "Score: " + str.tostring(buyScore) + " | B needs " + str.tostring(effectiveBScore)
    forgeLine3 := regimeIsRange ? "Avoid: range entry" : close > basis ? "Price above basis" : "Watch: basis reclaim"
    forgeLine4 := effectiveUseHTF and htfBear ? "Blocked: bearish HTF" : "Next: bullish confirmation candle"
else if shortNearReady
    forgeAction := "SHORT NEAR READY"
    forgeLine1 := not structBear ? "Waiting: bearish structure reclaim" : momText == "Neutral" ? "Waiting: bearish momentum" : not bShortEligible and not sellAQualified ? "Waiting: trend expansion" : "Waiting: confirmed trigger"
    forgeLine2 := trackedGrades == "A Only" ? "Score: " + str.tostring(sellScore) + " | A needs 80" : "Score: " + str.tostring(sellScore) + " | B needs " + str.tostring(effectiveBScore)
    forgeLine3 := regimeIsRange ? "Avoid: range entry" : close < basis ? "Price below basis" : "Watch: basis rejection"
    forgeLine4 := effectiveUseHTF and htfBull ? "Blocked: bullish HTF" : "Next: bearish confirmation candle"
else if trend == 1
    forgeAction := regimeIsRange ? "STAND ASIDE" : "WAIT FOR LONG"
    forgeLine1 := not structBull ? "Waiting: bullish structure reclaim" : momText == "Neutral" ? "Waiting: momentum expansion" : not bLongEligible ? "Waiting: B eligibility" : "Waiting: confirmed long trigger"
    forgeLine2 := regimeIsRange ? "Blocked: range / low expansion" : "Watch: breakout, impulse, or reclaim"
    forgeLine3 := close > basis + targetAtr * effectiveBMaxDistance ? "Do not chase — price extended" : "Watch: directional close above basis"
    forgeLine4 := effectiveUseHTF and htfBear ? "Need: HTF bullish alignment" : "Invalid if trend flips bearish"
else if trend == -1
    forgeAction := regimeIsRange ? "STAND ASIDE" : "WAIT FOR SHORT"
    forgeLine1 := not structBear ? "Waiting: bearish structure reclaim" : momText == "Neutral" ? "Waiting: momentum expansion" : not bShortEligible ? "Waiting: B eligibility" : "Waiting: confirmed short trigger"
    forgeLine2 := regimeIsRange ? "Blocked: range / low expansion" : "Watch: breakdown, impulse, or rejection"
    forgeLine3 := close < basis - targetAtr * effectiveBMaxDistance ? "Do not chase — price extended" : "Watch: directional close below basis"
    forgeLine4 := effectiveUseHTF and htfBull ? "Need: HTF bearish alignment" : "Invalid if trend flips bullish"
else
    forgeAction := "WAIT"
    forgeLine1 := "Waiting: trend direction"
    forgeLine2 := "Watch: basis slope and structure break"
    forgeLine3 := "Avoid: neutral chop"
    forgeLine4 := "Next: momentum expansion"

forgeGuideText = forgeTitle + "\n" + forgeAction + "\n" + forgeLine1 + "\n" + forgeLine2 + "\n" + forgeLine3 + (forgeLine4 != "" ? "\n" + forgeLine4 : "") + (cryptoTimeframeWarning ? "\nRecommended chart: 5m (current " + timeframe.period + ")" : "")

forgeGuideColor = tradeActive ? (activeSide == "Long" ? color.new(bull, 8) : color.new(bear, 8)) : longEntryEvent or longBArmed or longNearReady or trend == 1 ? color.new(bull, 12) : shortChartSignal or shortBArmed or shortNearReady or trend == -1 ? color.new(bear, 12) : color.new(neutral, 15)
forgeGuideTextColor = tradeActive and activeSide == "Short" or shortChartSignal or shortBArmed or shortNearReady or trend == -1 ? color.white : color.black
var label forgeGuideLabel = na
if barstate.islast
    if showForgeGuide
        guideY = close
        if na(forgeGuideLabel)
            forgeGuideLabel := label.new(bar_index + forgeGuideOffset, guideY, forgeGuideText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=forgeGuideColor, textcolor=forgeGuideTextColor, size=forgeTextSize)
        else
            label.set_xy(forgeGuideLabel, bar_index + forgeGuideOffset, guideY)
            label.set_text(forgeGuideLabel, forgeGuideText)
            label.set_color(forgeGuideLabel, forgeGuideColor)
            label.set_textcolor(forgeGuideLabel, forgeGuideTextColor)
            label.set_size(forgeGuideLabel, forgeTextSize)
    else if not na(forgeGuideLabel)
        label.delete(forgeGuideLabel)
        forgeGuideLabel := na

//============================
// DASHBOARD
//============================
if showDashboard and barstate.islast
    var table dash = table.new(dashPos, 2, 13, bgcolor=dashHeaderBg, border_width=1, border_color=dashBorder)
    table.cell(dash, 0, 0, "AF CORE v6.4.18", text_color=dashTextColor, text_halign=text.align_center, bgcolor=dashHeaderBg, text_size=dashTextSize)
    table.cell(dash, 1, 0, effectivePresetText, text_color=dashTextColor, text_halign=text.align_center, bgcolor=dashHeaderBg, text_size=dashTextSize)
    table.cell(dash, 0, 1, "Market", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 1, marketModeText, text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 0, 2, "Trend", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 2, regimeText, text_color=dashTextColor, bgcolor=regimeBg, text_size=dashTextSize)
    table.cell(dash, 0, 3, "Adaptive Regime", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 3, adaptiveRegimeText, text_color=dashTextColor, bgcolor=regimeIsRange ? color.new(bear, 28) : color.new(bull, 24), text_size=dashTextSize)
    table.cell(dash, 0, 4, "B Eligibility", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 4, (trend == 1 ? (bLongEligible ? "ON" : "OFF") : trend == -1 ? (bShortEligible ? "ON" : "OFF") : "WAIT") + " | " + (trend == 1 ? bLongEligibilityReason : trend == -1 ? bShortEligibilityReason : "Neutral trend"), text_color=dashTextColor, bgcolor=(trend == 1 ? bLongEligible : trend == -1 ? bShortEligible : false) ? color.new(bull, 22) : color.new(bear, 28), text_size=dashTextSize)
    table.cell(dash, 0, 5, "Momentum", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 5, momText, text_color=dashTextColor, bgcolor=momBg, text_size=dashTextSize)
    table.cell(dash, 0, 6, "HTF", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 6, htfText, text_color=dashTextColor, bgcolor=htfBg, text_size=dashTextSize)
    table.cell(dash, 0, 7, "Structure", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 7, structText, text_color=dashTextColor, bgcolor=structBg, text_size=dashTextSize)
    table.cell(dash, 0, 8, "Decision", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 8, decisionText, text_color=dashTextColor, bgcolor=decisionBg, text_size=dashTextSize)
    table.cell(dash, 0, 9, "Trade", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 9, tradeText, text_color=dashTextColor, bgcolor=tradeBg, text_size=dashTextSize)
    table.cell(dash, 0, 10, "Protection", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 10, tradeActive and not na(protectiveLevel) ? str.tostring(protectiveLevel, format.mintick) : "n/a", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 0, 11, "Last Exit", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 11, lastExitReason, text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 0, 12, "TP1 / TP2 / TP3", text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)
    table.cell(dash, 1, 12, tp1Text + " / " + tp2Text + " / " + tp3Text, text_color=dashTextColor, bgcolor=dashCellBg, text_size=dashTextSize)

// Optional single-channel bot JSON. Create one TradingView alert using
f_bot_payload(_action) =>
    "{\"secret\":\"" + webhookSecret + "\",\"ticker\":\"" + syminfo.ticker + "\",\"asset_type\":\"auto\",\"action\":\"" + _action + "\",\"price\":\"" + str.tostring(close, format.mintick) + "\",\"strategy\":\"Alpha Forge Core v6.4.18 Elite\",\"timeframe\":\"" + timeframe.period + "\",\"order_type\":\"market\",\"stop_loss\":\"\",\"take_profit_1\":\"\",\"take_profit_2\":\"\",\"take_profit_3\":\"\"}"

// Exact Alpha Forge long-only webhook schema.
// BUY opens a long; SELL closes the active long.
// Short entries/covers are intentionally excluded because this router schema
// uses SELL exclusively as the close-long action.
if enableBotJSON and longEntryEvent
    alert(f_bot_payload("buy"), alert.freq_once_per_bar_close)

if enableBotJSON and closeLongEvent
    alert(f_bot_payload("sell"), alert.freq_once_per_bar)

alertcondition(enableBuySellAlerts and longEntryEvent, "Alpha Forge Buy", "Alpha Forge BUY on {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and shortChartSignal, "Alpha Forge Bearish Chart Signal", "BEARISH_SIGNAL {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and shortEntryEvent, "Alpha Forge Short Entry", "SHORT_SELL {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and earlyLongFinal and not allowC, "Alpha Forge Buy C Guidance", "Alpha Forge BUY C GUIDANCE on {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and earlyShortFinal and not allowC, "Alpha Forge Sell C Guidance", "Alpha Forge SELL C GUIDANCE on {{ticker}} {{interval}}")

alertcondition(enableBuySellAlerts and longEntryEvent, "Alpha Forge LONG_BUY", "LONG_BUY {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and closeLongEvent, "Alpha Forge LONG_SELL", "LONG_SELL {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and shortEntryEvent, "Alpha Forge SHORT_SELL", "SHORT_SELL {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and closeShortEvent, "Alpha Forge SHORT_BUY", "SHORT_BUY {{ticker}} {{interval}}")

alertcondition(enableBuySellAlerts and newTP1Hit, "Alpha Forge TP1 Hit", "TP1_HIT {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and newTP2Hit, "Alpha Forge TP2 Hit", "TP2_HIT {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and newTP3Hit, "Alpha Forge TP3 Hit", "TP3_HIT {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and longWarningEvent, "Alpha Forge Long Warning", "LONG_WARNING {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and shortWarningEvent, "Alpha Forge Short Warning", "SHORT_WARNING {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and longStopAction, "Alpha Forge Long Stop", "LONG_STOP {{ticker}} {{interval}}")
alertcondition(enableBuySellAlerts and shortStopAction, "Alpha Forge Short Stop", "SHORT_STOP {{ticker}} {{interval}}")

alertcondition(enableStructureAlerts and bullBOS, "Alpha Forge Bullish BOS", "Alpha Forge Bullish BOS on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bearBOS, "Alpha Forge Bearish BOS", "Alpha Forge Bearish BOS on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bullCHOCH, "Alpha Forge Bullish CHOCH", "Alpha Forge Bullish CHOCH on {{ticker}} {{interval}}")
alertcondition(enableStructureAlerts and bearCHOCH, "Alpha Forge Bearish CHOCH", "Alpha Forge Bearish CHOCH on {{ticker}} {{interval}}")
````
