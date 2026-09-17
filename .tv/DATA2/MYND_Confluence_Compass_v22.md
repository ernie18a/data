<!-- tradingview-pine-id: PUB;c207e53a9c4946b6a57f3e1d190df6ab -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MYND Confluence Compass v2.2

Source: https://www.tradingview.com/script/JWC6w6VR-MYND-Confluence-Compass-v2-2/

## Description

MYND Confluence Compass [v2.2]

A multi-timeframe trend + momentum + trend-strength dashboard with gated entry signals, a two-tier exit system, a self-tracked honest read on whether its own trades are actually working, and now a set of frequency and quality fixes built directly from 2 live test screenshots.

WHAT IT DOES

This indicator checks your current chart timeframe plus up to 3 higher timeframes, classifying each one independently as Bullish, Bearish, or Flat from its own EMA trend direction, RSI/MACD momentum, and ADX trend-strength read. An entry signal only fires when enough of those timeframes actually agree - either by simple majority vote (Equal Weight mode) or by a combined weighted score. Once in a trade, a two-tier exit system watches for early signs of weakening momentum and a volatility-adaptive trailing stop.

HOW IT WORKS

Trend counts as up when price is above a fast EMA, that fast EMA is above a slow EMA, and Supertrend agrees on direction. Momentum counts as bullish when RSI is above its midline with a rising MACD histogram. Both only qualify if ADX clears the relevant minimum trend-strength threshold. Every higher-timeframe read uses that timeframe's own most recently CLOSED bar only, never the still-forming one, to avoid repainting.

KEY FEATURES

A live dashboard showing every enabled timeframe's state and ADX, the current confluence score (now with an active-timeframe count and optional HTF-veto tag), an average-ADX gate readout, tracked position and bars-in-trade, live open-trade P&L with ladder-tier status, and both rolling and all-time Live Trade Accuracy. A volatility-adaptive trailing stop line on the chart, optionally tightened per profit-ladder tier reached. Light/Dark theme presets plus a colorblind-safe signal color option. Full customization throughout, with tooltips on every setting that benefits from one.

HOW TO USE IT

Works out of the box with most v2.2 defaults pre-engaged, since they are targeted fixes rather than neutral options. If you want to compare against the prior version's behavior, every new gate can be switched off individually (see the Reference workbook's Directions & Notes tab). Watch the Confluence Score's active-timeframe count to understand at a glance how many timeframes are actually voting right now. Compare the Rolling and All-Time Live Trade Accuracy rows to tell "is it working lately" apart from "has it ever worked."

SETTINGS WORTH TUNING FIRST

Enable Adaptive Confluence Denominator - the direct fix for a starved-vote entry-frequency problem. Entry Confirmation Bars and Enable Cooldown After Exit - the two levers most aimed at whipsaw-loss trade quality. Require ADX Rising and Enable Per-Timeframe ADX Minimum - complementary frequency/quality levers, best tuned together. Enable Progressive Stop Tightening on Ladder Tiers - review what it changes before turning it on, since it's the one feature here that alters real exit behavior rather than just filtering entries.

WHAT THIS TOOL DELIBERATELY DOES NOT DO

Position/Bars-in-Trade/Live P&L/both Live Trade Accuracy stats remain signal-only - not connected to any real broker or exchange position. The Partial Profit-Taking Ladder stays informational-only unless Progressive Stop Tightening is explicitly turned on, since this tool tracks trade direction, not position size.

ALERTS

15 alerts total, all standard alertcondition() alerts - v2.2 added no new alert types, only tightened the conditions feeding the existing entry/exit alerts. Individual alerts cover Long/Short Entry, Long/Short Weakening Warning, Long/Short Exit, Bullish/Bearish Confluence Building, Live Trade Accuracy Warning, and Ladder Tier 1/2/3 Reached. Three combo alerts bundle these down to 1-2 watchlist slots: ALL Entries, ALL Exits & Warnings, and ALL Signals.

FEEDBACK WELCOME

If you've tweaked a setting, found a combination with another indicator that works well, or have an idea for what would make this more useful, I'd genuinely like to hear about it - drop a comment below (it helps other users too), or send a direct message if you'd rather keep the details private.

This tool can only tell you what has aligned and worked recently on this symbol/timeframe - it is not a guarantee of future performance. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator(title="MYND Confluence Compass v2.2", shorttitle="MYND CC v2.2", overlay=true, max_labels_count=500, max_lines_count=500)

// =====================================================================================
// MYND CONFLUENCE COMPASS v2.2
// Multi-timeframe trend + momentum + trend-strength dashboard with gated entry signals
// and a two-tier exit system (early "weakening" warning + volatility-adaptive trailing
// stop exit). Tool #1 of the MYND swing-trading suite - this is a full upgrade of the
// original v1.0 (built 2026-08-10), retrofitted to every standard adopted since, plus a
// genuine "full sweep" review that caught 2 real issues and added real new capability.

// =====================================================================================

// ---------------------------------------------------------------------------
// INPUTS - TIMEFRAMES
// ---------------------------------------------------------------------------
grpTF = "Timeframes"
enableHTF1 = input.bool(true, "Enable HTF 1", group=grpTF, tooltip="Include this higher timeframe in the confluence read below.")
htf1        = input.timeframe("240", "HTF 1", group=grpTF, tooltip="Higher timeframe #1. Its state is always read from its own most recently CLOSED bar, never the still-forming one, to avoid repainting.")
enableHTF2 = input.bool(true, "Enable HTF 2", group=grpTF, tooltip="Include this higher timeframe in the confluence read below.")
htf2        = input.timeframe("D",   "HTF 2", group=grpTF, tooltip="Higher timeframe #2. Its state is always read from its own most recently CLOSED bar, never the still-forming one, to avoid repainting.")
enableHTF3 = input.bool(true, "Enable HTF 3", group=grpTF, tooltip="Include this higher timeframe in the confluence read below.")
htf3        = input.timeframe("W",   "HTF 3", group=grpTF, tooltip="Higher timeframe #3. Its state is always read from its own most recently CLOSED bar, never the still-forming one, to avoid repainting.")
allowedDisagree = input.int(1, "Allowed Disagreeing Timeframes", minval=0, maxval=3, group=grpTF, tooltip="Equal Weight mode only: how many enabled timeframes (including the current chart) are allowed to disagree with the majority direction before the entry gate still opens. 0 = all enabled timeframes must agree (very strict - can sit out large moves for long stretches). Default raised to 1 in v2.1.")
enableWeeklyVeto = input.bool(false, "Enable HTF 3 Opposition Veto (softer than full unanimity)", group=grpTF, tooltip="When on, blocks an entry if HTF 3 below (your longest configured timeframe - Weekly by default) is actively opposed to that entry's direction, regardless of Weighting Mode or Allowed Disagreeing Timeframes above. Lets you loosen the main agreement requirement for more trade frequency while still refusing to enter directly against your longest timeframe. No effect if HTF 3 is disabled. Off by default - purely additive on top of v2.0 behavior.")
enableAdaptiveDenominator = input.bool(true, "Enable Adaptive Confluence Denominator", group=grpTF, tooltip="New in v2.2, ON by default - a real fix, not a cosmetic option. When on, Allowed Disagreeing Timeframes (Equal Weight mode) is measured against only the timeframes CURRENTLY reading Bull/Bear, not every enabled timeframe - a timeframe sitting FLAT purely from weak ADX no longer silently counts as a 'no' vote. Weighted mode's percentage is adjusted the same way. Turn off to restore the exact v2.1 denominator behavior (every enabled timeframe counts toward the total regardless of whether it's currently voting).")

// ---------------------------------------------------------------------------
// INPUTS - TREND (EMA + Supertrend)
// ---------------------------------------------------------------------------
grpTrend = "Trend"
emaFastLen = input.int(20, "EMA Fast Length", minval=1, group=grpTrend, tooltip="Fast EMA length used for the trend-direction check on each timeframe (current chart timeframe, and each enabled HTF via its own self-contained recompute).")
emaSlowLen = input.int(50, "EMA Slow Length", minval=1, group=grpTrend, tooltip="Slow EMA length. Trend only counts as up when price is above the fast EMA AND the fast EMA is above the slow EMA (plus Supertrend direction and ADX qualifying - see Trend Strength group below).")
stFactor   = input.float(3.0, "Trend Supertrend Factor", minval=0.1, step=0.1, group=grpTrend, tooltip="Supertrend used ONLY for trend-direction confirmation in the dashboard/entry logic (not the trailing exit line in the Exit System group).")
stATRLen   = input.int(10, "Trend Supertrend ATR Length", minval=1, group=grpTrend, tooltip="ATR length for the trend-confirmation Supertrend above.")

// ---------------------------------------------------------------------------
// INPUTS - MOMENTUM (RSI + MACD)
// ---------------------------------------------------------------------------
grpMom = "Momentum"
rsiLen  = input.int(14, "RSI Length", minval=1, group=grpMom, tooltip="RSI length used for the momentum-direction check on each timeframe.")
rsiMid  = input.float(50.0, "RSI Midline", group=grpMom, tooltip="RSI reference level - momentum only counts as bullish above this level (with a rising MACD histogram) or bearish below it (with a falling histogram).")
macdFast = input.int(12, "MACD Fast Length", minval=1, group=grpMom, tooltip="Standard MACD fast length, used for the histogram-direction component of the momentum check and the chart-timeframe histogram-deceleration warning below.")
macdSlow = input.int(26, "MACD Slow Length", minval=1, group=grpMom, tooltip="Standard MACD slow length.")
macdSig  = input.int(9,  "MACD Signal Length", minval=1, group=grpMom, tooltip="Standard MACD signal-line length (used to derive the histogram).")

// ---------------------------------------------------------------------------
// INPUTS - TREND STRENGTH (ADX/DMI)
// ---------------------------------------------------------------------------
grpADX = "Trend Strength (ADX/DMI)"
dmiLen    = input.int(14, "DMI Length", minval=1, group=grpADX, tooltip="DMI length used to measure trend strength on each timeframe.")
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=grpADX, tooltip="ADX smoothing length, applied on top of the DMI length above.")
adxMin    = input.float(20.0, "Minimum ADX to Qualify as Trending", minval=0, group=grpADX, tooltip="A timeframe only counts as bullish/bearish if ADX is at or above this level. Filters out choppy, non-trending conditions. This is the only ADX setting that actually affects the entry gate.")
adxStrongMin = input.float(35.0, "Strong Trend ADX Threshold", minval=0, group=grpADX, tooltip="ADX at or above this level is labeled 'Strong' on the dashboard (between Minimum ADX to Qualify and this level is labeled 'Moderate', below Minimum ADX is 'Weak'). Cosmetic/readability only - does not affect the entry gate.")
enablePerTFAdxMin = input.bool(true, "Enable Per-Timeframe ADX Minimum (HTF 1/2/3)", group=grpADX, tooltip="New in v2.2, ON by default. Slower timeframes structurally read smoother/lower ADX more often than faster ones - a single blanket Minimum ADX to Qualify can systematically shut out your slowest HTFs from ever voting. When on, HTF 1/2/3 use their own thresholds below instead of the Minimum ADX to Qualify value above (which still applies to the Current chart timeframe). Turn off to use one flat floor for every timeframe again, matching v2.1.")
adxMinHTF1 = input.float(20.0, "HTF 1 Minimum ADX to Qualify", minval=0, group=grpADX, tooltip="Only used when Enable Per-Timeframe ADX Minimum is on.")
adxMinHTF2 = input.float(17.0, "HTF 2 Minimum ADX to Qualify", minval=0, group=grpADX, tooltip="Only used when Enable Per-Timeframe ADX Minimum is on. Defaults lower than HTF 1, assuming HTF 2 is typically a slower timeframe (e.g. Daily) - adjust if you've reordered your HTFs.")
adxMinHTF3 = input.float(15.0, "HTF 3 Minimum ADX to Qualify", minval=0, group=grpADX, tooltip="Only used when Enable Per-Timeframe ADX Minimum is on. Defaults lowest of the 3, assuming HTF 3 is typically your slowest/longest timeframe (e.g. Weekly) - adjust if you've reordered your HTFs.")
requireAdxRising = input.bool(true, "Require ADX Rising (Current Chart TF) on Entries", group=grpADX, tooltip="New in v2.2, ON by default. Adds an entry condition requiring the Current chart timeframe's ADX to be higher than it was 'ADX Rising Lookback (bars)' below ago - aims to catch a trend as it's actually accelerating rather than merely already qualifying. Scoped to the Current chart timeframe only, not the HTFs. Turn off to remove this condition.")
adxRisingLookback = input.int(1, "ADX Rising Lookback (bars)", minval=1, group=grpADX, tooltip="Only used when Require ADX Rising is on. Current chart ADX must be higher than it was this many bars ago.")
enableAvgAdxGate = input.bool(false, "Enable Average-ADX-Across-Timeframes Gate", group=grpADX, tooltip="New in v2.1. The per-timeframe 'Minimum ADX to Qualify' above only checks each timeframe individually - every timeframe could each just barely clear that bar while the GROUP is still broadly weak. When on, this adds a second gate requiring the AVERAGE ADX across every enabled timeframe (current chart + enabled HTFs) to also clear the minimum below before an entry can fire. Off by default - purely additive on top of v2.0 behavior.")
avgAdxMin = input.float(20.0, "Average ADX Minimum (across enabled timeframes)", minval=0, group=grpADX, tooltip="Only used when Enable Average-ADX-Across-Timeframes Gate is on. The average of ADX across every currently enabled timeframe must be at or above this level for an entry to fire.")

// ---------------------------------------------------------------------------
// INPUTS - CONFLUENCE WEIGHTING
// ---------------------------------------------------------------------------
grpWeight = "Confluence Weighting"
weightMode = input.string("Equal Weight", "Weighting Mode", options=["Equal Weight", "Higher-Timeframe Weighted"], group=grpWeight, tooltip="Equal Weight (the original v1.0 behavior): every enabled timeframe counts the same toward the majority-vote gate. Higher-Timeframe Weighted: each enabled timeframe instead contributes its own weight below to one combined score, so a higher-timeframe disagreement can matter more than a lower-timeframe one.")
wCurrent = input.float(1.0, "Weight - Current Chart TF", minval=0, step=0.1, group=grpWeight, tooltip="Only used when Weighting Mode = Higher-Timeframe Weighted.")
wHTF1 = input.float(1.5, "Weight - HTF 1", minval=0, step=0.1, group=grpWeight, tooltip="Only used when Weighting Mode = Higher-Timeframe Weighted.")
wHTF2 = input.float(2.0, "Weight - HTF 2", minval=0, step=0.1, group=grpWeight, tooltip="Only used when Weighting Mode = Higher-Timeframe Weighted.")
wHTF3 = input.float(2.5, "Weight - HTF 3", minval=0, step=0.1, group=grpWeight, tooltip="Only used when Weighting Mode = Higher-Timeframe Weighted. Defaults assume HTF3 is your longest/most important timeframe (e.g. Weekly) - adjust the weights if you've reordered your HTFs to a different importance ranking.")
minConfluencePct = input.float(70, "Minimum Weighted Confluence % Required", minval=1, maxval=100, group=grpWeight, tooltip="Only used when Weighting Mode = Higher-Timeframe Weighted. The entry gate opens once one direction's weighted score reaches at least this % of the total enabled weight.")

// ---------------------------------------------------------------------------
// INPUTS - EXIT SYSTEM
// ---------------------------------------------------------------------------
grpExit = "Exit System"
exitFactor   = input.float(2.5, "Trailing Exit Supertrend Factor", minval=0.1, step=0.1, group=grpExit, tooltip="Separate, usually tighter Supertrend used ONLY as the hard trailing-stop exit line on the current chart timeframe. This is what lets winners run - it only exits when price actually violates the adaptive trail, not on a fixed day count or fixed target.")
exitATRLen   = input.int(10, "Trailing Exit ATR Length", minval=1, group=grpExit, tooltip="ATR length for the Exit System's own Supertrend above - separate from the Trend group's Supertrend, which is used only for entry confirmation.")
weakLookback = input.int(3, "Weakening Warning: ADX Falling Bars", minval=2, group=grpExit, tooltip="Number of consecutive bars ADX must be falling (on the chart timeframe) to raise an early 'momentum weakening' warning while a trade is open.")
useHistDecay = input.bool(true, "Also Warn on 2-Bar MACD Histogram Deceleration", group=grpExit, tooltip="When on, 2 consecutive bars of MACD histogram deceleration on the chart timeframe also raises a Weakening Warning, alongside the ADX-falling check above.")

// ---------------------------------------------------------------------------
// INPUTS - SIGNAL SETTINGS
// ---------------------------------------------------------------------------
grpSig = "Signal Settings"
requireVolConfirm = input.bool(false, "Require Volume Confirmation on Entries", group=grpSig, tooltip="When on, Entry Long/Short signals only fire if current volume also clears the multiple of average volume set below. Does not affect the dashboard's confluence read itself, only whether the gate is allowed to actually fire an entry.")
volConfirmLen = input.int(20, "Volume Confirmation Average Length", minval=2, group=grpSig, tooltip="Average volume length used for confirmation. Only applies when Require Volume Confirmation is on.")
volConfirmMult = input.float(1.2, "Volume Confirmation Multiplier", minval=0.5, step=0.1, group=grpSig, tooltip="Volume must be at least this multiple of the average to confirm an entry. Only applies when Require Volume Confirmation is on.")
entryConfirmBars = input.int(2, "Entry Confirmation Bars", minval=1, group=grpSig, tooltip="New in v2.2, default 2 (was implicitly 1 in every prior version - the gate fired the instant it opened). The confluence entry gate must stay continuously open for this many consecutive bars before an entry actually fires, filtering out single-bar whipsaw flips. Set to 1 to restore the original instant-fire behavior.")
enableCooldown = input.bool(true, "Enable Cooldown After Exit", group=grpSig, tooltip="New in v2.2, ON by default. Blocks a new same-direction entry for 'Cooldown Bars After Exit' below immediately after an exit, so the tool can't instantly re-enter the same chop it was just stopped out of.")
cooldownBars = input.int(5, "Cooldown Bars After Exit", minval=1, group=grpSig, tooltip="Only used when Enable Cooldown After Exit is on. Number of bars after an exit before a new entry in the SAME direction as the trade just closed is allowed again. An opposite-direction entry is never blocked by this.")

// ---------------------------------------------------------------------------
// INPUTS - ACCURACY TRACKING
// ---------------------------------------------------------------------------
grpAcc = "Accuracy Tracking"
rollingWindow = input.int(20, "Live Trade Accuracy Rolling Window (trades)", minval=5, group=grpAcc, tooltip="How many of this tool's own most recently CLOSED trades (via the trailing-stop exit, or an opposite-direction flip) the Live Trade Accuracy stat is based on - a rolling, not all-time, window.")
accuracyWarnLevel = input.float(40, "Live Trade Accuracy Warning Level (%)", minval=1, maxval=99, group=grpAcc, tooltip="If Live Trade Accuracy falls below this, the Live Trade Accuracy Warning alert fires.")
minTrackedForAccuracyAlert = input.int(10, "Minimum Tracked Trades for Accuracy Alert", minval=1, group=grpAcc, tooltip="The accuracy alert stays silent until at least this many trades have closed and been graded, to avoid an unreliable early read.")
showAllTimeAccuracy = input.bool(true, "Show All-Time Accuracy (alongside Rolling)", group=grpAcc, tooltip="New in v2.2, ON by default. Adds an All-Time win rate/average return row alongside the existing rolling-window Live Trade Accuracy row, so a great trade aging out of the rolling window doesn't quietly erase its own track record from the dashboard.")

// ---------------------------------------------------------------------------
// INPUTS - THEME & ACCESSIBILITY
// ---------------------------------------------------------------------------
grpTheme = "Theme & Accessibility"
themeMode = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group=grpTheme, tooltip="Light and Dark apply a curated color palette suited to that chart background. Custom uses the individual color pickers in Display instead - Theme Preset overrides them unless set to Custom.")
colorblindMode = input.bool(false, "Colorblind-Safe Signal Colors", group=grpTheme, tooltip="When on, overrides Bullish/Bearish colors to a colorblind-safe blue/orange palette (Okabe-Ito), regardless of Theme Preset or Custom colors.")

// ---------------------------------------------------------------------------
// INPUTS - DISPLAY
// ---------------------------------------------------------------------------
grpDisp = "Display"
showTable    = input.bool(true, "Show Dashboard Table", group=grpDisp)
tablePos     = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpDisp)
tableSize    = input.string("Small", "Table Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDisp)
showExitLine = input.bool(true, "Show Trailing Exit Line", group=grpDisp)
exitLineWidth = input.int(2, "Trailing Exit Line Width", minval=1, maxval=5, group=grpDisp, tooltip="Line thickness for the volatility-adaptive trailing exit line.")
showBgTint = input.bool(false, "Show Confluence Background Tint", group=grpDisp, tooltip="Subtle whole-chart background color reflecting current confluence direction and strength - stronger tint = stronger alignment. Off by default to avoid visual clutter; useful for an at-a-glance read without opening the dashboard.")
bgTintMaxOpacity = input.int(90, "Background Tint Max Transparency", minval=50, maxval=98, group=grpDisp, tooltip="Pine's transparency scale (0=opaque, 100=invisible). This sets the tint's transparency AT FULL confluence strength, so a HIGHER number here means a SUBTLER tint even when all enabled timeframes agree.")
showLivePnL = input.bool(true, "Show Live P&L (open trade) Row", group=grpDisp, tooltip="New in v2.1. Adds a dashboard row showing the current open trade's unrealized % return (using this tool's own tracked signal-only position, not a real broker position), plus a status tag once any enabled Partial Profit-Taking Ladder tier has been reached. Shows 'Flat - no open trade' when no position is currently tracked.")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Table Header Background", group=grpDisp, tooltip="Only applied when Theme Preset is set to Custom.")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Table Header Text", group=grpDisp, tooltip="Only applied when Theme Preset is set to Custom.")
colBullCustom      = input.color(color.new(color.green, 0), "Custom Bullish Color", group=grpDisp, tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
colBearCustom      = input.color(color.new(color.red, 0), "Custom Bearish Color", group=grpDisp, tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
colNeutralCustom   = input.color(color.new(color.gray, 0), "Custom Neutral Color", group=grpDisp, tooltip="Only applied when Theme Preset is set to Custom.")
colWarnCustom      = input.color(color.new(color.orange, 0), "Custom Warning Color", group=grpDisp, tooltip="Only applied when Theme Preset is set to Custom.")

// ---------------------------------------------------------------------------
// INPUTS - PARTIAL PROFIT-TAKING LADDER (new in v2.1)
// ---------------------------------------------------------------------------
grpLadder = "Partial Profit-Taking Ladder"
enableLadder = input.bool(false, "Enable Partial Profit-Taking Ladder", group=grpLadder, tooltip="New in v2.1. Adapted from the MYND Position Size Calculator's R-multiple ladder, but using % Gain From Entry instead - this tool has no fixed initial stop-distance/R-multiple concept (it uses a trailing Supertrend, not a fixed stop). INFORMATIONAL ONLY: Confluence Compass tracks trade DIRECTION only, not position size, so tiers here are milestone markers/alerts, not an instruction to actually scale out of any real position. Off by default - purely additive on top of v2.0 behavior.")
ladderTier1Enable = input.bool(true, "Enable Tier 1", group=grpLadder, inline="t1", tooltip="Fires once when the open trade's unrealized % gain first reaches this level.")
ladderTier1Pct    = input.float(3.0, "Tier 1 % Gain From Entry", minval=0.1, step=0.5, group=grpLadder, inline="t1")
ladderTier2Enable = input.bool(true, "Enable Tier 2", group=grpLadder, inline="t2", tooltip="Fires once when the open trade's unrealized % gain first reaches this level.")
ladderTier2Pct    = input.float(6.0, "Tier 2 % Gain From Entry", minval=0.1, step=0.5, group=grpLadder, inline="t2")
ladderTier3Enable = input.bool(true, "Enable Tier 3", group=grpLadder, inline="t3", tooltip="Fires once when the open trade's unrealized % gain first reaches this level.")
ladderTier3Pct    = input.float(10.0, "Tier 3 % Gain From Entry", minval=0.1, step=0.5, group=grpLadder, inline="t3")
enableLadderStopTighten = input.bool(false, "Enable Progressive Stop Tightening on Ladder Tiers", group=grpLadder, tooltip="New in v2.2, OFF by default - the one new feature this round shipped off on purpose since it's a genuinely bigger behavior change than the others. When on, turns the Ladder tiers from purely informational into a real exit-mechanism change: the Trailing Exit Supertrend Factor is progressively reduced by 'Trailing Stop Tighten % Per Tier Reached' below for each Ladder tier reached on the open trade, floored at 25% of your configured factor so it never collapses to a degenerate near-zero trail. Requires Enable Partial Profit-Taking Ladder to also be on.")
ladderTightenPerTier = input.float(0.15, "Trailing Stop Tighten % Per Tier Reached", minval=0, maxval=0.9, step=0.05, group=grpLadder, tooltip="Only used when Enable Progressive Stop Tightening on Ladder Tiers is on. Fraction the Trailing Exit Supertrend Factor is reduced by, per Ladder tier reached (e.g. 0.15 = 15% tighter per tier, up to 3 tiers).")

// =====================================================================================
// THEME RESOLUTION (Light/Dark/Custom base palette, then Colorblind-Safe override on top)
// =====================================================================================
lightHeaderBg = color.new(color.navy, 0)
lightHeaderText = color.new(color.white, 0)
lightBullish = color.new(color.green, 0)
lightBearish = color.new(color.red, 0)
lightNeutral = color.new(color.gray, 0)
lightWarn = color.new(color.orange, 0)

darkHeaderBg = color.new(#1A1F2E, 0)
darkHeaderText = color.new(#E0E0E0, 0)
darkBullish = color.new(#26A69A, 0)
darkBearish = color.new(#EF5350, 0)
darkNeutral = color.new(#787B86, 0)
darkWarn = color.new(#FFB74D, 0)

cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)

headerBgColor = themeMode == "Custom" ? headerBgColorCustom : themeMode == "Dark" ? darkHeaderBg : lightHeaderBg
headerTextColor = themeMode == "Custom" ? headerTextColorCustom : themeMode == "Dark" ? darkHeaderText : lightHeaderText
baseBullishColor = themeMode == "Custom" ? colBullCustom : themeMode == "Dark" ? darkBullish : lightBullish
baseBearishColor = themeMode == "Custom" ? colBearCustom : themeMode == "Dark" ? darkBearish : lightBearish
neutralColor = themeMode == "Custom" ? colNeutralCustom : themeMode == "Dark" ? darkNeutral : lightNeutral
warnColor = themeMode == "Custom" ? colWarnCustom : themeMode == "Dark" ? darkWarn : lightWarn
bullishColor = colorblindMode ? cbBullish : baseBullishColor
bearishColor = colorblindMode ? cbBearish : baseBearishColor

// ---------------------------------------------------------------------------
// CORE MULTI-TIMEFRAME FUNCTIONS
// f_mtf() - tuple [state, adx], used ONLY for the current chart timeframe (cheap, single
// call, no repaint concern since this is the live chart's own current-bar read).
// f_mtfState()/f_mtfADX() - single-value, fully self-contained duplicates of the same
// logic, used ONLY for HTF request.security() pulls, since a tuple result can't be
// offset with [1] inside request.security() the way a single value can. See header
// comment for why this duplication is necessary, not an oversight.
// ---------------------------------------------------------------------------
f_mtf() =>
    emaFast = ta.ema(close, emaFastLen)
    emaSlow = ta.ema(close, emaSlowLen)
    rsiVal  = ta.rsi(close, rsiLen)
    [_, __, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
    [diP, diM, adxVal] = ta.dmi(dmiLen, adxSmooth)
    [stLine, stDir]    = ta.supertrend(stFactor, stATRLen)
    trendUp = close > emaFast and emaFast > emaSlow and stDir < 0
    trendDn = close < emaFast and emaFast < emaSlow and stDir > 0
    momUp   = rsiVal > rsiMid and histLine > histLine[1]
    momDn   = rsiVal < rsiMid and histLine < histLine[1]
    adxOk   = adxVal >= adxMin
    state   = (trendUp and momUp and adxOk) ? 1 : (trendDn and momDn and adxOk) ? -1 : 0
    [state, adxVal]

f_mtfState(customAdxMin) =>
    emaFastS = ta.ema(close, emaFastLen)
    emaSlowS = ta.ema(close, emaSlowLen)
    rsiValS  = ta.rsi(close, rsiLen)
    [_, __, histLineS] = ta.macd(close, macdFast, macdSlow, macdSig)
    [diPs, diMs, adxValS] = ta.dmi(dmiLen, adxSmooth)
    [stLineS, stDirS]    = ta.supertrend(stFactor, stATRLen)
    trendUpS = close > emaFastS and emaFastS > emaSlowS and stDirS < 0
    trendDnS = close < emaFastS and emaFastS < emaSlowS and stDirS > 0
    momUpS   = rsiValS > rsiMid and histLineS > histLineS[1]
    momDnS   = rsiValS < rsiMid and histLineS < histLineS[1]
    adxOkS   = adxValS >= customAdxMin
    stateS   = (trendUpS and momUpS and adxOkS) ? 1 : (trendDnS and momDnS and adxOkS) ? -1 : 0
    stateS

f_mtfADX() =>
    [diPa, diMa, adxValA] = ta.dmi(dmiLen, adxSmooth)
    adxValA

// Current chart timeframe (always included, live)
[stateC, adxC] = f_mtf()

// Per-Timeframe ADX Minimum (new in v2.2) - effective threshold per HTF slot
effAdxMinHTF1 = enablePerTFAdxMin ? adxMinHTF1 : adxMin
effAdxMinHTF2 = enablePerTFAdxMin ? adxMinHTF2 : adxMin
effAdxMinHTF3 = enablePerTFAdxMin ? adxMinHTF3 : adxMin

// Higher timeframes - previous CLOSED bar only, lookahead disabled (repaint-safe)
state1 = request.security(syminfo.tickerid, htf1, f_mtfState(effAdxMinHTF1)[1], lookahead=barmerge.lookahead_off)
adx1   = request.security(syminfo.tickerid, htf1, f_mtfADX()[1], lookahead=barmerge.lookahead_off)
state2 = request.security(syminfo.tickerid, htf2, f_mtfState(effAdxMinHTF2)[1], lookahead=barmerge.lookahead_off)
adx2   = request.security(syminfo.tickerid, htf2, f_mtfADX()[1], lookahead=barmerge.lookahead_off)
state3 = request.security(syminfo.tickerid, htf3, f_mtfState(effAdxMinHTF3)[1], lookahead=barmerge.lookahead_off)
adx3   = request.security(syminfo.tickerid, htf3, f_mtfADX()[1], lookahead=barmerge.lookahead_off)

// ---------------------------------------------------------------------------
// CONFLUENCE SCORE - EQUAL WEIGHT (majority vote, v1.0 behavior)
// ---------------------------------------------------------------------------
totalEnabled = 1 + (enableHTF1 ? 1 : 0) + (enableHTF2 ? 1 : 0) + (enableHTF3 ? 1 : 0)
countBull = (stateC == 1 ? 1 : 0) + (enableHTF1 and state1 == 1 ? 1 : 0) + (enableHTF2 and state2 == 1 ? 1 : 0) + (enableHTF3 and state3 == 1 ? 1 : 0)
countBear = (stateC == -1 ? 1 : 0) + (enableHTF1 and state1 == -1 ? 1 : 0) + (enableHTF2 and state2 == -1 ? 1 : 0) + (enableHTF3 and state3 == -1 ? 1 : 0)

// Adaptive Confluence Denominator (new in v2.2) - excludes currently-FLAT timeframes (from
// weak ADX or genuine disagreement) from the vote-count denominator, so an idle timeframe
// no longer silently counts as a "disagreement". Floored at 2 (unless only 1 timeframe is
// enabled at all) so a single lone active reading still can't fire an entry by itself.
activeEnabledCount = (stateC != 0 ? 1 : 0) + (enableHTF1 and state1 != 0 ? 1 : 0) + (enableHTF2 and state2 != 0 ? 1 : 0) + (enableHTF3 and state3 != 0 ? 1 : 0)

requiredAlign = enableAdaptiveDenominator ? math.max(activeEnabledCount - allowedDisagree, math.min(totalEnabled, 2)) : math.max(totalEnabled - allowedDisagree, 1)

// ---------------------------------------------------------------------------
// CONFLUENCE SCORE - HIGHER-TIMEFRAME WEIGHTED (new in v2.0)
// ---------------------------------------------------------------------------
totalWeight = wCurrent + (enableHTF1 ? wHTF1 : 0) + (enableHTF2 ? wHTF2 : 0) + (enableHTF3 ? wHTF3 : 0)
weightedBull = (stateC == 1 ? wCurrent : 0) + (enableHTF1 and state1 == 1 ? wHTF1 : 0) + (enableHTF2 and state2 == 1 ? wHTF2 : 0) + (enableHTF3 and state3 == 1 ? wHTF3 : 0)
weightedBear = (stateC == -1 ? wCurrent : 0) + (enableHTF1 and state1 == -1 ? wHTF1 : 0) + (enableHTF2 and state2 == -1 ? wHTF2 : 0) + (enableHTF3 and state3 == -1 ? wHTF3 : 0)
// Adaptive denominator's weighted-mode counterpart - only kicks in with at least 2 active
// timeframes (same floor logic as Equal Weight above), otherwise falls back to totalWeight.
activeTotalWeight = (stateC != 0 ? wCurrent : 0) + (enableHTF1 and state1 != 0 ? wHTF1 : 0) + (enableHTF2 and state2 != 0 ? wHTF2 : 0) + (enableHTF3 and state3 != 0 ? wHTF3 : 0)
effTotalWeight = enableAdaptiveDenominator and activeEnabledCount >= 2 ? activeTotalWeight : totalWeight
weightedBullPct = effTotalWeight > 0 ? weightedBull / effTotalWeight * 100 : 0.0
weightedBearPct = effTotalWeight > 0 ? weightedBear / effTotalWeight * 100 : 0.0

// ---------------------------------------------------------------------------
// WEEKLY-OPPOSITION VETO + AVERAGE-ADX-ACROSS-TIMEFRAMES GATE (new in v2.1)
// ---------------------------------------------------------------------------
weeklyVetoLong  = enableWeeklyVeto and enableHTF3 and state3 == -1
weeklyVetoShort = enableWeeklyVeto and enableHTF3 and state3 == 1

adxSum = adxC + (enableHTF1 ? adx1 : 0) + (enableHTF2 ? adx2 : 0) + (enableHTF3 ? adx3 : 0)
avgAdxAcrossTF = totalEnabled > 0 ? adxSum / totalEnabled : 0.0
avgAdxGateOk = not enableAvgAdxGate or avgAdxAcrossTF >= avgAdxMin

// Require ADX Rising (new in v2.2) - Current chart timeframe only. ta.rising() is computed
// unconditionally every bar (not inline after "or") so its internal rolling state is never
// skipped on bars where the gate itself is disabled - matches this file's established safe
// pattern for adxFalling/other stateful ta.* calls above.
adxRisingRaw = ta.rising(adxC, adxRisingLookback)
adxRisingOk = not requireAdxRising or adxRisingRaw

entryLongCond  = (weightMode == "Equal Weight" ? (countBull >= requiredAlign and countBull > 0) : (weightedBullPct >= minConfluencePct)) and not weeklyVetoLong  and avgAdxGateOk and adxRisingOk
entryShortCond = (weightMode == "Equal Weight" ? (countBear >= requiredAlign and countBear > 0) : (weightedBearPct >= minConfluencePct)) and not weeklyVetoShort and avgAdxGateOk and adxRisingOk

// ---------------------------------------------------------------------------
// OPTIONAL VOLUME CONFIRMATION GATE
// ---------------------------------------------------------------------------
volSma = ta.sma(volume, volConfirmLen)
volOk = requireVolConfirm ? (volume >= volSma * volConfirmMult) : true

// ---------------------------------------------------------------------------
// POSITION STATE TRACKING (signal-only, not a broker position) + TRADE GRADING
// ---------------------------------------------------------------------------
var int posDir = 0
var float posEntryPrice = na
var int entryBarIndex = na
var array<float> tradeResults = array.new_float(0)
var array<float> tradeReturns = array.new_float(0)

// Entry Confirmation Bars (new in v2.2) - the confluence gate must stay continuously open
// for entryConfirmBars consecutive bars before an entry actually fires.
var int longCondStreak = 0
var int shortCondStreak = 0
longCondStreak := entryLongCond ? longCondStreak + 1 : 0
shortCondStreak := entryShortCond ? shortCondStreak + 1 : 0
entryLongConfirmed = longCondStreak >= entryConfirmBars
entryShortConfirmed = shortCondStreak >= entryConfirmBars

// Cooldown After Exit (new in v2.2) - tracks the bar of the last trailing-stop exit per
// direction so a fresh same-direction entry can be blocked for a set number of bars.
// Deliberately NOT set on a same-bar opposite-direction flip (see header/Directions &
// Notes) - only a real trailing-stop exit starts the cooldown.
var int lastLongExitBar = na
var int lastShortExitBar = na
cooldownOkLong  = not enableCooldown or na(lastLongExitBar)  or (bar_index - lastLongExitBar)  >= cooldownBars
cooldownOkShort = not enableCooldown or na(lastShortExitBar) or (bar_index - lastShortExitBar) >= cooldownBars

// All-Time Live Trade Accuracy (new in v2.2) - unbounded counterparts to the rolling
// tradeResults/tradeReturns arrays above, so a great trade aging out of the rolling window
// doesn't quietly disappear from the tool's own track record.
var int allTimeCount = 0
var float allTimeWinSum = 0.0
var float allTimeReturnSum = 0.0

// NOTE (v2.2 compile-fix): a Pine user-defined function cannot reassign (:=) a variable
// declared in the global scope - only reference types (arrays, tables, lines, labels) can
// be mutated from inside a function, via methods like array.push() below. f_gradeTrade()
// therefore only pushes into the two rolling arrays (legal) and RETURNS [wasWin,
// tradeReturnPct] instead of touching allTimeCount/allTimeWinSum/allTimeReturnSum directly
// - each of the 3 call sites below updates those global accumulators itself with the
// returned values.
f_gradeTrade(closePrice, sideClosed, openPrice, resultsArr, returnsArr, window) =>
    tradeReturn = openPrice > 0 ? (closePrice - openPrice) / openPrice * sideClosed : 0.0
    wasWin = tradeReturn > 0
    array.push(resultsArr, wasWin ? 1.0 : 0.0)
    array.push(returnsArr, tradeReturn * 100)
    if array.size(resultsArr) > window
        array.shift(resultsArr)
        array.shift(returnsArr)
    [wasWin, tradeReturn * 100]

prevPosDir = posDir
prevEntryPrice = posEntryPrice

entryLong  = entryLongConfirmed  and not entryLongConfirmed[1]  and posDir != 1  and volOk and cooldownOkLong
entryShort = entryShortConfirmed and not entryShortConfirmed[1] and posDir != -1 and volOk and cooldownOkShort

flipToLong  = entryLong  and prevPosDir == -1
flipToShort = entryShort and prevPosDir == 1

if flipToLong or flipToShort
    // NOTE (v2.0 fix): a same-bar opposite-direction flip closes the prior trade for
    // grading purposes at the flip price - see header comment, issue #2.
    [flipWasWin, flipReturnPct] = f_gradeTrade(close, prevPosDir, prevEntryPrice, tradeResults, tradeReturns, rollingWindow)
    allTimeCount := allTimeCount + 1
    allTimeWinSum := allTimeWinSum + (flipWasWin ? 1.0 : 0.0)
    allTimeReturnSum := allTimeReturnSum + flipReturnPct

if entryLong
    posDir := 1
    posEntryPrice := close
    entryBarIndex := bar_index
if entryShort
    posDir := -1
    posEntryPrice := close
    entryBarIndex := bar_index

// ---------------------------------------------------------------------------
// PARTIAL PROFIT-TAKING LADDER STATE (new in v2.1, % gain from entry, informational only)
// ---------------------------------------------------------------------------
var bool tier1Hit = false
var bool tier2Hit = false
var bool tier3Hit = false

if entryLong or entryShort
    tier1Hit := false
    tier2Hit := false
    tier3Hit := false

livePnLPct = posDir != 0 and not na(posEntryPrice) and posEntryPrice > 0 ? (close - posEntryPrice) / posEntryPrice * posDir * 100.0 : na

ladderTier1Reached = enableLadder and ladderTier1Enable and posDir != 0 and not na(livePnLPct) and livePnLPct >= ladderTier1Pct and not tier1Hit
ladderTier2Reached = enableLadder and ladderTier2Enable and posDir != 0 and not na(livePnLPct) and livePnLPct >= ladderTier2Pct and not tier2Hit
ladderTier3Reached = enableLadder and ladderTier3Enable and posDir != 0 and not na(livePnLPct) and livePnLPct >= ladderTier3Pct and not tier3Hit

if ladderTier1Reached
    tier1Hit := true
if ladderTier2Reached
    tier2Hit := true
if ladderTier3Reached
    tier3Hit := true

ladderTagTxt = enableLadder and (tier1Hit or tier2Hit or tier3Hit) ? " [" + (tier1Hit ? "T1 " : "") + (tier2Hit ? "T2 " : "") + (tier3Hit ? "T3 " : "") + "hit]" : ""

// ---------------------------------------------------------------------------
// EXIT SYSTEM - TIER 2: VOLATILITY-ADAPTIVE TRAILING STOP (hard exit)
// ---------------------------------------------------------------------------
// Progressive Stop Tightening on Ladder Tiers (new in v2.2, off by default) - reduces the
// effective Supertrend factor as more Ladder tiers are reached on the open trade, floored
// at 25% of the configured factor. Requires both toggles on; otherwise factor is unchanged.
tiersHitCount = (tier1Hit ? 1 : 0) + (tier2Hit ? 1 : 0) + (tier3Hit ? 1 : 0)
effectiveExitFactor = enableLadderStopTighten and enableLadder ? math.max(exitFactor * (1 - ladderTightenPerTier * tiersHitCount), exitFactor * 0.25) : exitFactor

[exitLine, exitDir] = ta.supertrend(effectiveExitFactor, exitATRLen)

exitLongSignal  = posDir == 1  and exitDir > 0 and exitDir[1] < 0
exitShortSignal = posDir == -1 and exitDir < 0 and exitDir[1] > 0

if exitLongSignal
    [exitLongWasWin, exitLongReturnPct] = f_gradeTrade(close, 1, posEntryPrice, tradeResults, tradeReturns, rollingWindow)
    allTimeCount := allTimeCount + 1
    allTimeWinSum := allTimeWinSum + (exitLongWasWin ? 1.0 : 0.0)
    allTimeReturnSum := allTimeReturnSum + exitLongReturnPct
    posDir := 0
    posEntryPrice := na
    lastLongExitBar := bar_index
if exitShortSignal
    [exitShortWasWin, exitShortReturnPct] = f_gradeTrade(close, -1, posEntryPrice, tradeResults, tradeReturns, rollingWindow)
    allTimeCount := allTimeCount + 1
    allTimeWinSum := allTimeWinSum + (exitShortWasWin ? 1.0 : 0.0)
    allTimeReturnSum := allTimeReturnSum + exitShortReturnPct
    posDir := 0
    posEntryPrice := na
    lastShortExitBar := bar_index

// ---------------------------------------------------------------------------
// EXIT SYSTEM - TIER 1: WEAKENING WARNING (discretionary heads-up, not an exit)
// ---------------------------------------------------------------------------
[_, __, chartHist] = ta.macd(close, macdFast, macdSlow, macdSig)
adxFalling   = ta.falling(adxC, weakLookback)
histDecaying = useHistDecay and chartHist < chartHist[1] and chartHist[1] < chartHist[2]

weakLongRaw  = posDir == 1  and (adxFalling or histDecaying)
weakShortRaw = posDir == -1 and (adxFalling or histDecaying)
weakLong  = weakLongRaw  and not weakLongRaw[1]
weakShort = weakShortRaw and not weakShortRaw[1]

// ---------------------------------------------------------------------------
// BONUS: CONFLUENCE BUILDING (partial alignment, informational only)
// ---------------------------------------------------------------------------
buildingBullRaw = countBull > countBear and countBull > 0 and countBull < requiredAlign
buildingBearRaw = countBear > countBull and countBear > 0 and countBear < requiredAlign
buildingBull = buildingBullRaw and not buildingBullRaw[1]
buildingBear = buildingBearRaw and not buildingBearRaw[1]

// ---------------------------------------------------------------------------
// LAST SIGNAL TRACKING
// ---------------------------------------------------------------------------
var string lastEventType = "None"
var int lastEventBar = na
if entryLong
    lastEventType := "Long Entry"
    lastEventBar := bar_index
if entryShort
    lastEventType := "Short Entry"
    lastEventBar := bar_index
if exitLongSignal
    lastEventType := "Long Exit"
    lastEventBar := bar_index
if exitShortSignal
    lastEventType := "Short Exit"
    lastEventBar := bar_index
barsSinceEvent = na(lastEventBar) ? na : bar_index - lastEventBar

// ---------------------------------------------------------------------------
// LIVE TRADE ACCURACY - self-tracking, rolling window, graded on REAL closed trades
// ---------------------------------------------------------------------------
liveAccuracyPct = array.size(tradeResults) > 0 ? array.avg(tradeResults) * 100 : na
liveTrackedCount = array.size(tradeResults)
liveAvgReturnPct = array.size(tradeReturns) > 0 ? array.avg(tradeReturns) : na
accuracyLowAlert = liveTrackedCount >= minTrackedForAccuracyAlert and not na(liveAccuracyPct) and liveAccuracyPct < accuracyWarnLevel

// All-Time counterparts (new in v2.2) - unbounded, never age out of a rolling window.
allTimeAccuracyPct = allTimeCount > 0 ? allTimeWinSum / allTimeCount * 100 : na
allTimeAvgReturnPct = allTimeCount > 0 ? allTimeReturnSum / allTimeCount : na

barsInTrade = posDir != 0 and not na(entryBarIndex) ? bar_index - entryBarIndex : na

// ---------------------------------------------------------------------------
// ADX QUALITATIVE STRENGTH LABEL
// ---------------------------------------------------------------------------
f_adxStrengthText(adxVal) =>
    adxVal >= adxStrongMin ? "Strong" : adxVal >= adxMin ? "Moderate" : "Weak"

f_adxCellText(adxVal) =>
    na(adxVal) ? "-" : str.tostring(adxVal, "#.#") + " (" + f_adxStrengthText(adxVal) + ")"

// ---------------------------------------------------------------------------
// CONFLUENCE BACKGROUND TINT (optional)
// ---------------------------------------------------------------------------
tintPct = totalEnabled > 0 ? math.max(countBull, countBear) / totalEnabled : 0.0
tintTransp = int(math.round(100 - (100 - bgTintMaxOpacity) * tintPct))
bgTintColor = not showBgTint ? na : countBull > countBear ? color.new(bullishColor, tintTransp) : countBear > countBull ? color.new(bearishColor, tintTransp) : na
bgcolor(bgTintColor, title="Confluence Background Tint")

// ---------------------------------------------------------------------------
// PLOTS
// ---------------------------------------------------------------------------
plot(showExitLine ? exitLine : na, title="Trailing Exit Line", color=exitDir < 0 ? bullishColor : bearishColor, linewidth=exitLineWidth, style=plot.style_linebr)

plotshape(entryLong,  title="Entry Long",  style=shape.triangleup,   location=location.belowbar, color=bullishColor, size=size.small, text="LONG")
plotshape(entryShort, title="Entry Short", style=shape.triangledown, location=location.abovebar, color=bearishColor, size=size.small, text="SHORT")

plotshape(weakLong,  title="Weakening Warning (Long)",  style=shape.labelup,   location=location.belowbar, color=warnColor, size=size.tiny, text="!", textcolor=color.white)
plotshape(weakShort, title="Weakening Warning (Short)", style=shape.labeldown, location=location.abovebar, color=warnColor, size=size.tiny, text="!", textcolor=color.white)

plotshape(exitLongSignal,  title="Exit Long",  style=shape.xcross, location=location.abovebar, color=warnColor, size=size.small, text="EXIT")
plotshape(exitShortSignal, title="Exit Short", style=shape.xcross, location=location.belowbar, color=warnColor, size=size.small, text="EXIT")

plotshape(ladderTier1Reached, title="Ladder Tier 1 Reached", style=shape.labelup, location=location.belowbar, color=color.new(bullishColor, 30), size=size.tiny, text="T1", textcolor=color.white)
plotshape(ladderTier2Reached, title="Ladder Tier 2 Reached", style=shape.labelup, location=location.belowbar, color=color.new(bullishColor, 30), size=size.tiny, text="T2", textcolor=color.white)
plotshape(ladderTier3Reached, title="Ladder Tier 3 Reached", style=shape.labelup, location=location.belowbar, color=color.new(bullishColor, 30), size=size.tiny, text="T3", textcolor=color.white)

// ---------------------------------------------------------------------------
// DASHBOARD TABLE
// ---------------------------------------------------------------------------
tablePosConst = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
tSize = tableSize == "Tiny" ? size.tiny : tableSize == "Small" ? size.small : tableSize == "Normal" ? size.normal : tableSize == "Large" ? size.large : size.huge

var table dash = table.new(tablePosConst, 3, 13, border_width=1, border_color=color.new(color.gray, 50), frame_color=color.new(color.gray, 50), frame_width=1)

f_stateColor(s) =>
    s == 1 ? bullishColor : s == -1 ? bearishColor : neutralColor

f_stateText(s) =>
    s == 1 ? "BULL" : s == -1 ? "BEAR" : "FLAT"

if showTable and barstate.islast
    table.cell(dash, 0, 0, "MYND Confluence Compass v2.2", text_color=headerTextColor, bgcolor=headerBgColor, text_size=tSize)
    table.cell(dash, 1, 0, "", bgcolor=headerBgColor)
    table.cell(dash, 2, 0, "", bgcolor=headerBgColor)

    table.cell(dash, 0, 1, "Timeframe", text_size=tSize, text_color=headerTextColor, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 1, "State", text_size=tSize, text_color=headerTextColor, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 2, 1, "ADX (Strength)", text_size=tSize, text_color=headerTextColor, bgcolor=color.new(color.gray, 70))

    table.cell(dash, 0, 2, "Current", text_size=tSize)
    table.cell(dash, 1, 2, f_stateText(stateC), text_color=color.white, bgcolor=f_stateColor(stateC), text_size=tSize)
    table.cell(dash, 2, 2, f_adxCellText(adxC), text_size=tSize)

    table.cell(dash, 0, 3, enableHTF1 ? htf1 : "(off)", text_size=tSize)
    table.cell(dash, 1, 3, enableHTF1 ? f_stateText(state1) : "-", text_color=color.white, bgcolor=enableHTF1 ? f_stateColor(state1) : color.new(color.gray, 70), text_size=tSize)
    table.cell(dash, 2, 3, enableHTF1 ? f_adxCellText(adx1) : "-", text_size=tSize)

    table.cell(dash, 0, 4, enableHTF2 ? htf2 : "(off)", text_size=tSize)
    table.cell(dash, 1, 4, enableHTF2 ? f_stateText(state2) : "-", text_color=color.white, bgcolor=enableHTF2 ? f_stateColor(state2) : color.new(color.gray, 70), text_size=tSize)
    table.cell(dash, 2, 4, enableHTF2 ? f_adxCellText(adx2) : "-", text_size=tSize)

    table.cell(dash, 0, 5, enableHTF3 ? htf3 : "(off)", text_size=tSize)
    table.cell(dash, 1, 5, enableHTF3 ? f_stateText(state3) : "-", text_color=color.white, bgcolor=enableHTF3 ? f_stateColor(state3) : color.new(color.gray, 70), text_size=tSize)
    table.cell(dash, 2, 5, enableHTF3 ? f_adxCellText(adx3) : "-", text_size=tSize)

    scoreTxt = str.tostring(countBull) + "B/" + str.tostring(countBear) + "S of " + str.tostring(totalEnabled) + (enableAdaptiveDenominator ? " (" + str.tostring(activeEnabledCount) + " active)" : "")
    weightTxt = (weightMode == "Equal Weight" ? "Equal (req " + str.tostring(requiredAlign) + ")" : "Wtd " + str.tostring(math.max(weightedBullPct, weightedBearPct), "#.#") + "% " + (weightedBullPct > weightedBearPct ? "Bull" : "Bear")) + (enableWeeklyVeto ? " +Veto" : "")
    table.cell(dash, 0, 6, "Confluence Score", text_size=tSize)
    table.cell(dash, 1, 6, scoreTxt, text_size=tSize)
    table.cell(dash, 2, 6, weightTxt, text_size=tSize)

    avgAdxTxt = str.tostring(avgAdxAcrossTF, "#.#")
    avgAdxGateTxt = enableAvgAdxGate ? "Gate ON (min " + str.tostring(avgAdxMin, "#.#") + ")" : "Gate OFF"
    table.cell(dash, 0, 7, "Avg ADX (Gate)", text_size=tSize)
    table.cell(dash, 1, 7, avgAdxTxt, text_size=tSize)
    table.cell(dash, 2, 7, avgAdxGateTxt, text_size=tSize)

    posText  = posDir == 1 ? "LONG" : posDir == -1 ? "SHORT" : "FLAT"
    posColor = posDir == 1 ? bullishColor : posDir == -1 ? bearishColor : neutralColor
    barsInTradeTxt = na(barsInTrade) ? "-" : str.tostring(barsInTrade) + " bars"
    table.cell(dash, 0, 8, "Position", text_size=tSize)
    table.cell(dash, 1, 8, posText, text_color=color.white, bgcolor=posColor, text_size=tSize)
    table.cell(dash, 2, 8, barsInTradeTxt, text_size=tSize)

    livePnLTxt = not showLivePnL ? "(disabled)" : posDir == 0 ? "Flat - no open trade" : na(livePnLPct) ? "-" : str.tostring(livePnLPct, "#.##") + "%" + ladderTagTxt
    livePnLColor = not showLivePnL or posDir == 0 or na(livePnLPct) ? color.new(color.gray, 85) : livePnLPct >= 0 ? color.new(bullishColor, 80) : color.new(bearishColor, 70)
    table.cell(dash, 0, 9, "Live P&L (open trade)", text_size=tSize)
    table.cell(dash, 1, 9, livePnLTxt, bgcolor=livePnLColor, text_size=tSize)
    table.cell(dash, 2, 9, "", text_size=tSize)

    accTxt = na(liveAccuracyPct) ? "Building..." : str.tostring(liveAccuracyPct, "#.#") + "% (" + str.tostring(liveTrackedCount) + " trades)"
    accColor = na(liveAccuracyPct) ? color.new(color.gray, 85) : liveAccuracyPct < accuracyWarnLevel ? color.new(bearishColor, 70) : color.new(bullishColor, 80)
    avgTxt = na(liveAvgReturnPct) ? "-" : str.tostring(liveAvgReturnPct, "#.##") + "% avg"
    table.cell(dash, 0, 10, "Live Trade Accuracy (Rolling)", text_size=tSize)
    table.cell(dash, 1, 10, accTxt, bgcolor=accColor, text_size=tSize)
    table.cell(dash, 2, 10, avgTxt, text_size=tSize)

    allTimeAccTxt = not showAllTimeAccuracy ? "(disabled)" : na(allTimeAccuracyPct) ? "Building..." : str.tostring(allTimeAccuracyPct, "#.#") + "% (" + str.tostring(allTimeCount) + " trades)"
    allTimeAccColor = not showAllTimeAccuracy or na(allTimeAccuracyPct) ? color.new(color.gray, 85) : allTimeAccuracyPct < accuracyWarnLevel ? color.new(bearishColor, 70) : color.new(bullishColor, 80)
    allTimeAvgTxt = not showAllTimeAccuracy or na(allTimeAvgReturnPct) ? "-" : str.tostring(allTimeAvgReturnPct, "#.##") + "% avg"
    table.cell(dash, 0, 11, "Live Trade Accuracy (All-Time)", text_size=tSize)
    table.cell(dash, 1, 11, allTimeAccTxt, bgcolor=allTimeAccColor, text_size=tSize)
    table.cell(dash, 2, 11, allTimeAvgTxt, text_size=tSize)

    lastColor = lastEventType == "Long Entry" or lastEventType == "Long Exit" ? color.new(bullishColor, 70) : lastEventType == "Short Entry" or lastEventType == "Short Exit" ? color.new(bearishColor, 70) : color.new(color.gray, 85)
    lastTxt = na(barsSinceEvent) ? "None yet" : str.tostring(barsSinceEvent) + " bars ago"
    table.cell(dash, 0, 12, "Last Signal", text_size=tSize)
    table.cell(dash, 1, 12, lastEventType, bgcolor=lastColor, text_size=tSize)
    table.cell(dash, 2, 12, lastTxt, text_size=tSize)

// ---------------------------------------------------------------------------
// ALERTS - INDIVIDUAL (standard alertcondition() alerts)
// ---------------------------------------------------------------------------
alertcondition(entryLong,  title="MYND CC - Long Entry",  message="MYND Confluence Compass: LONG entry gate open on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(entryShort, title="MYND CC - Short Entry", message="MYND Confluence Compass: SHORT entry gate open on {{ticker}} ({{interval}}) at {{close}}")

alertcondition(weakLong,  title="MYND CC - Long Weakening Warning",  message="MYND Confluence Compass: Long trend WEAKENING on {{ticker}} ({{interval}}) at {{close}} - consider tightening/partial exit")
alertcondition(weakShort, title="MYND CC - Short Weakening Warning", message="MYND Confluence Compass: Short trend WEAKENING on {{ticker}} ({{interval}}) at {{close}} - consider tightening/partial exit")

alertcondition(exitLongSignal,  title="MYND CC - Long Exit (Trailing Stop)",  message="MYND Confluence Compass: LONG trailing exit hit on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(exitShortSignal, title="MYND CC - Short Exit (Trailing Stop)", message="MYND Confluence Compass: SHORT trailing exit hit on {{ticker}} ({{interval}}) at {{close}}")

alertcondition(buildingBull, title="MYND CC - Bullish Confluence Building", message="MYND Confluence Compass: Bullish confluence building on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(buildingBear, title="MYND CC - Bearish Confluence Building", message="MYND Confluence Compass: Bearish confluence building on {{ticker}} ({{interval}}) at {{close}}")

alertcondition(accuracyLowAlert, title="MYND CC - Live Trade Accuracy Warning", message="MYND Confluence Compass: Live Trade Accuracy has dropped below your warning level on {{ticker}} ({{interval}})")

alertcondition(ladderTier1Reached, title="MYND CC - Ladder Tier 1 Reached", message="MYND Confluence Compass: Partial Profit-Taking Ladder Tier 1 reached on {{ticker}} ({{interval}}) at {{close}} (informational only)")
alertcondition(ladderTier2Reached, title="MYND CC - Ladder Tier 2 Reached", message="MYND Confluence Compass: Partial Profit-Taking Ladder Tier 2 reached on {{ticker}} ({{interval}}) at {{close}} (informational only)")
alertcondition(ladderTier3Reached, title="MYND CC - Ladder Tier 3 Reached", message="MYND Confluence Compass: Partial Profit-Taking Ladder Tier 3 reached on {{ticker}} ({{interval}}) at {{close}} (informational only)")

// ---------------------------------------------------------------------------
// ALERTS - COMBO BUNDLES (entry vs. exit split - the right grouping for a tool with an
// explicit position lifecycle, per MYND_Project_Notes.md)
// ---------------------------------------------------------------------------
comboEntries = entryLong or entryShort
comboExitsWarnings = exitLongSignal or exitShortSignal or weakLong or weakShort or ladderTier1Reached or ladderTier2Reached or ladderTier3Reached
allSignals = comboEntries or comboExitsWarnings or buildingBull or buildingBear

alertcondition(comboEntries, title="MYND CC - ALL Entries", message="MYND Confluence Compass: Entry signal on {{ticker}} ({{interval}}) - check dashboard for direction.")
alertcondition(comboExitsWarnings, title="MYND CC - ALL Exits & Warnings", message="MYND Confluence Compass: Exit or weakening warning on {{ticker}} ({{interval}}) - check dashboard.")
alertcondition(allSignals, title="MYND CC - ALL Signals", message="MYND Confluence Compass: Signal on {{ticker}} ({{interval}}) - check chart/dashboard.")
````
