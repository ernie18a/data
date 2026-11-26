# RPFXBYDAN Liquidity Sweep Cascade [SMC]

- url: https://www.tradingview.com/script/oWMl2HaV-RPFXBYDAN-Liquidity-Sweep-Cascade-SMC/
- type: indicator
- pine_id: PUB;4be21104a07f473ba8b807f4aac79e7b
- version: 5.0

## Description

# Publication settings

**Publish this open-source, not invite-only/closed-source.** Every concept used here (liquidity sweeps, CISD, FVG, order blocks, kill zones, SMT divergence) is public-domain ICT/SMC terminology, not proprietary logic — TradingView's moderators specifically hold closed-source and invite-only scripts to a much higher bar (you have to justify what's unique enough to hide, and why it's worth paying for). Open-source sidesteps that requirement entirely and is the safer, more defensible choice for a script built from publicly-known building blocks combined in an original way.

# Title

RPFXBYDAN Liquidity Sweep Cascade [SMC]

# Description 

**Why these pieces are combined (not a mashup for its own sake)**

Each concept here exists to solve a specific failure mode of using it alone. A liquidity sweep by itself is noise — most swing highs/lows get taken out without reversing. Requiring a CISD (a shift in orderflow) after the sweep filters out sweeps that don't actually reverse. Requiring the entry to land inside a Fair Value Gap in the discount/premium half of the range filters out CISDs that reverse but leave a bad entry price. None of these three alone is a tradeable signal; the combination is the point.

The three-tier structure exists because a signal on one timeframe alone doesn't tell you if you're trading with or against the bigger picture. Tier 1 establishes the higher-timeframe liquidity/imbalance context. Tier 2 only starts hunting once Tier 1 completes, confirming the reaction on a mid-timeframe inside a session kill zone. Tier 3 only starts once Tier 2 completes, and is the only tier that produces a real stop/target — it's the culmination of the other two agreeing, not an independent signal. That sequential gating (each tier consumed by exactly one attempt from the tier above it) is the original mechanism in this script, not the individual concepts themselves.

SMT divergence and Inverse FVG tracking are optional add-ons layered on top of that same gated engine, off by default, for traders who already use those specific confluences.

**What this is**

A three-tier Smart Money Concepts checklist that only flags a setup once liquidity, structure, and risk all line up across three timeframes:

- **Tier 1 – HTF Context**: a higher-timeframe liquidity sweep reacting into an HTF imbalance (your Point of Interest).
- **Tier 2 – Mid Structure**: inside a session/kill-zone window, a mid-timeframe (default 15m) sweep, shift in orderflow (CISD), and Fair Value Gap / order block — only evaluated once Tier 1 has completed.
- **Tier 3 – Entry**: on your chart's own timeframe, a sweep, CISD, and FVG (or a confirmed Inverse FVG retest if no fresh FVG appears) — only evaluated once Tier 2 has completed. This is the only tier with a defined stop, a fixed R-multiple take-profit, and a Risk:Reward gate.

Optional confluence layers: SMT divergence against a correlated symbol (e.g. ES vs NQ), and an HTF directional bias readout.

A live table shows exactly which of the checklist items are satisfied, tier by tier, so you can see why a setup is or isn't "complete" instead of guessing.

**How to use it**

1. Set Tier 1's HTF input to something meaningfully higher than your chart (e.g. 4H/Daily if you trade 5m-15m).
2. Set Tier 2's mid-timeframe input (default 15m).
3. Enable the kill zone(s) you actually trade (New York AM is on by default).
4. Optionally set a correlated symbol for SMT divergence.
5. Watch the table: green checks across all three tiers plus R:R = a completed setup. Alerts fire automatically on completion (bullish and bearish are separate alert conditions).

**Limitations (read before trusting a green table)**

- This is a deterministic, rule-based approximation of a discretionary trading concept. Every judgment call in the code — how CISD is defined, where the 50% discount/premium line sits, how SMT divergence is measured — is this author's interpretation, not a universally agreed-upon standard.
- Higher-timeframe values only update when that HTF candle closes, by design, so they can lag price intentionally.
- Bar Replay does not render this script's drawings/table live (a TradingView platform limitation with drawing objects, not a bug in the script) — use a live or normal historical chart to watch it work.
- No indicator predicts the future. Backtest and forward-test on your own instrument and timeframe before risking real money. Nothing here is financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Originally built as a single-timeframe PO1 strategy checklist,
// now rebuilt as the three-tier cascade shown in the narrated trade-breakdown recordings:
//   TIER 1 (HTF context)   -> HTF liquidity sweep reacting into an HTF imbalance/POI
//   TIER 2 (mid structure) -> inside a kill zone, a mid-timeframe (default 15m) sweep + CISD + FVG/OB
//                             confirming the reaction, only unlocked once Tier 1 completes
//   TIER 3 (entry)         -> on this chart's own timeframe, a sweep + CISD + FVG (or an Inverse FVG,
//                             see below) that is the actual trade trigger, only unlocked once Tier 2
//                             completes
// PLUS Inverse FVG (IFVG) tracking: when the most recent Fair Value Gap on this chart's timeframe gets
// fully violated, it flips polarity (support <-> resistance). If Tier 3 is hunting and a normal FVG
// hasn't shown up, a confirmed retest/rejection of that flipped zone is accepted as the entry trigger
// instead, tagged "IFVG" everywhere it's drawn.
// 
// READ BEFORE USING — same caveat as v1/v2, now stronger given the size of this rewrite:
// This is this author's best deterministic translation of the checklist PDF plus roughly 40 minutes of
// narrated trade breakdowns. It is NOT confirmed by the strategy's creator. The three-tier gating in
// particular makes several judgment calls the videos never state explicitly:
//   - Tier 2 is only allowed to start hunting once Tier 1 completes AND it's inside an enabled kill
//     zone; Tier 3 is only allowed to start once Tier 2 completes. Each tier is "consumed" by one
//     attempt from the tier above it (tracked via bar-index comparisons) so it doesn't keep re-firing
//     off a stale completion.
//   - Discount/premium (50% equilibrium) is checked at all three tiers for consistency, even though the
//     recordings most clearly demonstrate it at the mid/entry tiers.
//   - R:R and the fixed TP/SL only apply at Tier 3 (the actual trade). Tiers 1-2 completing just means
//     "zone confirmed," not "risk defined."
//   - IFVG tracking keeps only the single most recent bullish-origin and bearish-origin FVG on this
//     chart's timeframe, not a full history of every gap. That matches the videos' examples (one
//     specific nearby FVG flipping), not an exhaustive order-block/FVG library.
// Still not implemented: cross-symbol "dealing range" confirmation (using a correlated pair's own 50%
// level to validate the primary symbol's range) and breaker blocks. Treat this as v3 of an ongoing
// build. Given how much bigger this rewrite is than v1/v2, expect to paste this into the Pine Editor
// and fix at least one syntax error before it runs — that has been true every round so far.
//@version=6
indicator("RPFXBYDAN Liquidity Sweep Cascade", shorttitle="RPFXBYDAN Liquidity Sweep Cascade", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================== TIER 1 (HTF) INPUTS ==============================
grpHTF = "Tier 1 - HTF Context"
htf        = input.timeframe("240", "HTF for liquidity & POI", group=grpHTF, tooltip="Pick something meaningfully higher than your chart's timeframe, e.g. 4H/Daily if you trade 5m-15m.")
swingLen   = input.int(10, "HTF swing pivot length", minval=2, maxval=50, group=grpHTF)

// ============================== TIER 2 (MID) INPUTS ==============================
grpMid = "Tier 2 - Mid Structure (new in v3)"
midTF      = input.timeframe("15", "Mid timeframe for structure shift", group=grpMid, tooltip="The recordings used 15m between HTF context and 1m/5m entries.")
midSwingLen = input.int(5, "Mid swing pivot length", minval=2, maxval=50, group=grpMid)

// ============================== SHARED CISD / FVG / RR INPUTS (apply to all 3 tiers) ==============================
grpCISD = "CISD / FVG / R:R (shared across all 3 tiers)"
cisdMode = input.string("Swing High/Low (recommended)", "CISD confirmation level", options=["Swing High/Low (recommended)", "Origin Candle Open (aggressive)"], group=grpCISD, tooltip="Two 2026-07-11 videos showed the Origin Candle Open trigger firing too early and going straight to stop loss. What was actually demonstrated was a close beyond the last swing high/low before the sweep leg, with displacement. Swing High/Low matches that; Origin Candle Open is the older, earlier, more aggressive trigger.")
requireDisplacement = input.bool(true, "Require the confirming candle to show displacement (momentum)", group=grpCISD)
displacementMult    = input.float(1.5, "Displacement = candle range >= this x the 14-bar ATR", minval=0.5, step=0.1, group=grpCISD)
cisdLookback     = input.int(20, "Max bars scanned back for CISD/order-block origin", minval=3, maxval=100, group=grpCISD)
cisdTimeout      = input.int(40, "Cancel a tier's hunt if no CISD within N bars of its sweep", minval=5, maxval=300, group=grpCISD)
requireRejection = input.bool(false, "Require sweep candle to close back inside the level", group=grpCISD)
fvgTimeout  = input.int(15, "Cancel a tier's hunt if no FVG within N bars of its CISD", minval=3, maxval=200, group=grpCISD)
fvgMinTicks = input.float(0.0, "Minimum FVG size in ticks (0 = no filter)", minval=0.0, group=grpCISD)
minRR = input.float(2.0, "Tier 3 fixed R multiple to target ('1:2 and nothing more')", minval=0.5, step=0.5, group=grpCISD)

// ============================== ENTRY CONFIRMATION INPUTS (new) ==============================
grpEntry = "Entry Confirmation ('when to take it')"
requireRetestForEntry = input.bool(true, "Require a retest INTO the FVG before confirming entry", group=grpEntry, tooltip="Off: the old behavior — the tier completes the instant the FVG appears. On (recommended, matches the videos): the tier waits for a later candle to wick back into the FVG and hold before it prints a TAKE label, sets R:R, and fires the completion alert. This applies to any tier with its Entry/TP/SL lines turned on.")
retestTimeout = input.int(20, "Cancel the hunt if no retest within N bars of the FVG forming", minval=3, maxval=200, group=grpEntry)

// ============================== IFVG INPUTS ==============================
grpIFVG = "Inverse FVG (new in v3)"
useIFVG = input.bool(true, "Track IFVG and allow it to substitute for Tier 3's FVG", group=grpIFVG)

// ============================== KILL ZONE INPUTS ==============================
grpSession = "Kill Zone / Session Filter"
requireKillzone = input.bool(true, "Require Tier 2 sweep + Tier 3 completion inside an enabled kill zone", group=grpSession)
sessTZ    = input.string("America/New_York", "Session timezone", group=grpSession)
useNYAM   = input.bool(true, "New York AM Killzone", group=grpSession)
nyamSess  = input.session("0930-1100", "NY AM hours", group=grpSession)
useNYPM   = input.bool(false, "New York PM Killzone", group=grpSession)
nypmSess  = input.session("1330-1600", "NY PM hours", group=grpSession)
useLondon = input.bool(false, "London Killzone", group=grpSession)
londonSess = input.session("0200-0500", "London hours", group=grpSession)
useAsia   = input.bool(false, "Asian Killzone", group=grpSession)
asiaSess  = input.session("2000-0000", "Asian hours", group=grpSession)

// ============================== SMT DIVERGENCE INPUTS ==============================
grpSMT = "SMT Divergence (applies to Tier 2 + Tier 3)"
useSMT      = input.bool(false, "Compute & display SMT divergence", group=grpSMT)
requireSMT  = input.bool(false, "Require SMT divergence for a completed Tier 3 entry", group=grpSMT)
corrSymbol  = input.symbol("", "Correlated symbol (e.g. ES1! if this chart is NQ1!)", group=grpSMT)
smtTF       = input.timeframe("15", "SMT comparison timeframe", group=grpSMT, tooltip="SMT is judged on this timeframe for BOTH this symbol and the correlated one, independent of your chart's timeframe. Default 15m per your spec for Simple Mode below; this same setting also feeds the optional SMT confluence on the regular 3-tier cascade.")
ltfSwingLen = input.int(5, "Swing length for SMT (on smtTF) + Tier 3's own entry pivots (on chart TF)", minval=2, maxval=50, group=grpSMT)

// ============================== SIMPLE MODE (new) ==============================
// A separate, independent gate for Tier 3's entry hunt, built exactly to spec: 15m SMT divergence, then
// a swing low/high sweep, then a 15m Shift confirming it (closing back through the prior opposing swing),
// all on simpleTF. Once that sequence completes, Tier 3's own sweep+CISD+FVG+retest engine takes over
// to find the precise 1-minute 2:1 R:R entry — same execution machinery as the regular cascade, just a
// simpler, single-timeframe trigger feeding it instead of the HTF->Mid cascade. Off by default; the
// regular 3-tier cascade is completely untouched when this is off.
grpSimple = "Simple Mode (15m SMT + Sweep + Shift -> 1m 2:1 Entry)"
useSimpleMode  = input.bool(false, "Use Simple Mode to gate Tier 3 entries (instead of the HTF/Mid cascade)", group=grpSimple, tooltip="When on, Tier 3 hunts are triggered by this sequence instead of gateT3: 15m SMT divergence -> swing low/high sweep -> 15m Shift (close through the prior opposing swing). Tier 1/2 keep running in the background but no longer feed Tier 3 while this is on.")
simpleTF       = input.timeframe("15", "Simple Mode timeframe (SMT + sweep + shift)", group=grpSimple)
simpleSwingLen = input.int(5, "Swing pivot length on Simple Mode's timeframe", minval=2, maxval=50, group=grpSimple)
simpleLookback = input.int(20, "Max bars (on simpleTF) scanned back for the Shift's swing level", minval=3, maxval=100, group=grpSimple)
simpleStepTimeout = input.int(400, "Cancel the sequence if the next step doesn't happen within N bars (this chart's TF)", minval=5, maxval=3000, group=grpSimple, tooltip="Counted in THIS CHART's bars, not simpleTF bars. Applies between SMT->sweep and sweep->Shift. On a 1m chart with simpleTF=15, each 15m candle is 15 chart bars, so 400 ≈ 6.5 hours of patience (≈27 fifteen-minute candles) between steps. The old default of 60 (1 hour, ≈4 fifteen-minute candles) was too tight and was killing sequences before Shift could ever confirm — raise this further if you still see sequences time out before a Shift.")

grpBias = "HTF Bias (info only)"
showBias = input.bool(true, "Show HTF directional bias in the table", group=grpBias)

grpT12Trade = "Tier 1 & 2 Entry/TP/SL (new)"
showEntryT1T2  = input.bool(false, "Draw Entry/TP/SL lines when Tier 1 or Tier 2 completes (not just Tier 3)", group=grpT12Trade, tooltip="Off by default: Tier 1 has no gating and re-hunts constantly, so leaving this on redraws a full Entry/SL/TP set every time and clutters the chart. Turn on only if you specifically want 'what if I entered here' reference lines for Tier 1/2.")
gateT1T2OnRR   = input.bool(false, "Also require Tier 1/2 to pass the R:R check before the cascade can advance", group=grpT12Trade, tooltip="Off by default: turning this on makes Tier 2/3 unlock less often, since Tier 1 (and then Tier 2) now has to clear its own R:R hurdle first, not just sweep+CISD+FVG.")
showZoneT1T2   = input.bool(false, "Show premium/discount zone shading on Tier 1 & 2 (Tier 3 always shows it)", group=grpT12Trade)
showTier12Marks = input.bool(false, "Show Tier 1/2 POI/OB/sweep/shift/FVG drawings on the chart", group=grpT12Trade, tooltip="OFF by default: Tier 1/2 drawings were the single biggest source of chart clutter (multiple full-width Entry/SL/TP lines, POI/OB boxes, sweep/shift labels all stacking on top of the actual Tier 3 signal). Tier 1/2 keep computing and gating Tier 3 (or, in Simple Mode, keep running in the background) either way — this only hides their boxes/lines/labels. Turn ON only if you specifically want to see the HTF/Mid reasoning behind each Tier 3 signal.")

grpStyle = "Display"
discountColor  = input.color(color.new(color.red, 75), "Discount (lower half)", group=grpStyle, tooltip="Matches the reference recordings: discount (the buy-side half, where entries sit) is the maroon/red zone, premium (the sell-side half, where targets sit) is the teal/green zone.")
premiumColor   = input.color(color.new(color.teal, 75), "Premium (upper half)", group=grpStyle)
shiftBullColor = input.color(color.green, "Shift / CISD line (bullish)", group=grpStyle)
shiftBearColor = input.color(color.red, "Shift / CISD line (bearish)", group=grpStyle)
smtColor       = input.color(color.blue, "SMT divergence line", group=grpStyle)
showTable     = input.bool(true, "Show live checklist table", group=grpStyle)
tablePosInput = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpStyle)
showTradePanel = input.bool(true, "Show a fixed Entry/SL/TP panel (middle-right) for the current Tier 3 trade", group=grpStyle, tooltip="This is a table, not a chart label, so it always sits in a fixed screen corner and never overlaps candles or other markers regardless of zoom or how far price has moved since entry.")
panelStaleBars = input.int(500, "Trade panel: hide trade after this many bars", minval=0, group=grpStyle, tooltip="The panel always sits next to the current price, which makes an old trade look current even if it fired days ago. Once the most recent Tier 3 trade is older than this many bars, the panel switches to 'No active trade' instead of showing stale numbers. Set to 0 to disable this cutoff and always show the last trade regardless of age.")

grpAlerts = "Alerts"
alertT1T2 = input.bool(true, "Also alert on Tier 1 / Tier 2 completions", group=grpAlerts, tooltip="Tier 3 (the full cascade, or the Simple Mode entry) always alerts. Turn this on to also fire an alert() the instant Tier 1 or Tier 2 individually completes, before Tier 3 confirms — useful if you want to react earlier in the cascade instead of waiting for the final entry tier.")
labelRightOffset = input.int(15, "Push Entry/SL/TP on-chart labels this many bars into the blank right margin", minval=0, maxval=200, group=grpStyle, tooltip="TradingView leaves empty space past the last bar by default (visible on the right of your chart). This pushes the Entry/Stop Loss/Take Profit labels out into that blank space instead of sitting on the current candle. Raise this if your chart's right margin is wider than default and the labels still land on price action; lower it (or set to 0) if your margin is narrow and they're floating off past the visible edge.")

tablePosition = tablePosInput == "Top Right" ? position.top_right : tablePosInput == "Top Left" ? position.top_left : tablePosInput == "Bottom Right" ? position.bottom_right : position.bottom_left

// ============================== TIER STATE TYPE ==============================
type TierState
    bool  pending       = false
    bool  cisdDone      = false
    bool  fvgFound      = false
    bool  levelOK       = false
    bool  rrOK          = false
    bool  complete      = false
    bool  justCompleted = false
    bool  usedIFVG      = false
    bool  smtFlag       = false
    bool  awaitingRetest = false
    int   sweepBar       = na
    float sweepLevel     = na
    float rangeOpp       = na
    float cisdLevel      = na
    int   cisdBar        = na
    int   fvgBar         = na
    float gapTop         = na
    float gapBot         = na
    float entryPrice     = na
    float targetPrice    = na
    box   poiBox = na
    box   obBox  = na
    line  sweepLine = na
    line  cisdLine  = na
    box   fvgBox  = na
    box   premBox = na
    box   discBox = na
    line  eqLine = na
    line  tpLine = na
    line  slLine = na
    line  entryLine = na
    label sweptLabel    = na
    label shiftLabel    = na
    label slLabel       = na
    label tpLabel       = na
    label entryLabel    = na
    label completeLabel = na
    label takeLabel     = na
    label outcomeLabel  = na
    bool  tradeLive  = false
    float liveEntry  = na
    float liveStop   = na
    float liveTarget = na
    int   liveEntryBar = na
    int   liveEntryTime = na
    int   consumedParentBar = na

var TierState t1Bull = TierState.new()
var TierState t1Bear = TierState.new()
var TierState t2Bull = TierState.new()
var TierState t2Bear = TierState.new()
var TierState t3Bull = TierState.new()
var TierState t3Bear = TierState.new()

// ============================== TIER 1 (HTF) PIVOTS ==============================
getHTFPivots() =>
    ph = ta.pivothigh(high, swingLen, swingLen)
    pl = ta.pivotlow(low, swingLen, swingLen)
    [ph, pl]

[htfPHraw, htfPLraw] = request.security(syminfo.tickerid, htf, getHTFPivots(), lookahead=barmerge.lookahead_off)

var float htfPivotHigh     = na
var float htfPivotLow      = na
var float prevHtfPivotHigh = na
var float prevHtfPivotLow  = na
if not na(htfPHraw)
    prevHtfPivotHigh := htfPivotHigh
    htfPivotHigh := htfPHraw
if not na(htfPLraw)
    prevHtfPivotLow := htfPivotLow
    htfPivotLow := htfPLraw

plot(htfPivotHigh, "Tier1 HTF Pivot High", color=color.new(color.orange, 40), style=plot.style_circles, linewidth=1)
plot(htfPivotLow, "Tier1 HTF Pivot Low", color=color.new(color.orange, 40), style=plot.style_circles, linewidth=1)

htfBias = (not na(htfPivotHigh) and not na(prevHtfPivotHigh) and not na(htfPivotLow) and not na(prevHtfPivotLow)) ? (htfPivotHigh > prevHtfPivotHigh and htfPivotLow > prevHtfPivotLow ? "Bullish" : (htfPivotHigh < prevHtfPivotHigh and htfPivotLow < prevHtfPivotLow ? "Bearish" : "Mixed")) : "Forming"

// ============================== TIER 2 (MID) PIVOTS ==============================
getMidPivots() =>
    ph = ta.pivothigh(high, midSwingLen, midSwingLen)
    pl = ta.pivotlow(low, midSwingLen, midSwingLen)
    [ph, pl]

[midPHraw, midPLraw] = request.security(syminfo.tickerid, midTF, getMidPivots(), lookahead=barmerge.lookahead_off)

var float midPivotHigh = na
var float midPivotLow  = na
if not na(midPHraw)
    midPivotHigh := midPHraw
if not na(midPLraw)
    midPivotLow := midPLraw

plot(midPivotHigh, "Tier2 Mid Pivot High", color=color.new(color.blue, 40), style=plot.style_circles, linewidth=1)
plot(midPivotLow, "Tier2 Mid Pivot Low", color=color.new(color.blue, 40), style=plot.style_circles, linewidth=1)

dataNotReady = na(htfPivotHigh) or na(htfPivotLow) or na(midPivotHigh) or na(midPivotLow)

// ============================== KILL ZONE CHECK ==============================
inSession(sess) => not na(time(timeframe.period, sess, sessTZ))
sessionOK = not requireKillzone or (useNYAM and inSession(nyamSess)) or (useNYPM and inSession(nypmSess)) or (useLondon and inSession(londonSess)) or (useAsia and inSession(asiaSess))

// ============================== TIER 3 (ENTRY, this chart's own timeframe) PIVOTS + SMT DATA ==============================
// Not gated on useSMT: Simple Mode requires this fetch to run whenever a correlated symbol is set,
// regardless of the old cascade's "compute & display" toggle. useSMT still fully controls the old
// cascade's own confluence gating further down (unaffected by this), and the drawing gate below only
// shows the SMT line/label when useSMT or Simple Mode actually wants it visible.
haveCorr = corrSymbol != ""

var float ltfPivotHigh    = na
var float ltfPivotLow     = na
var int   ltfPivotHighBar = na
var int   ltfPivotLowBar  = na
ltfPH = ta.pivothigh(high, ltfSwingLen, ltfSwingLen)
ltfPL = ta.pivotlow(low, ltfSwingLen, ltfSwingLen)
if not na(ltfPH)
    ltfPivotHigh    := ltfPH
    ltfPivotHighBar := bar_index - ltfSwingLen
if not na(ltfPL)
    ltfPivotLow    := ltfPL
    ltfPivotLowBar := bar_index - ltfSwingLen

getCorrData() =>
    ph2 = ta.pivothigh(high, ltfSwingLen, ltfSwingLen)
    pl2 = ta.pivotlow(low, ltfSwingLen, ltfSwingLen)
    [ph2, pl2, high, low]

// Both legs of the SMT comparison run on smtTF (default 5m), NOT the chart's own timeframe — 1-minute
// swing points are too noisy to judge divergence off. This is separate from ltfPivotHigh/Low above,
// which stay chart-native because those still drive Tier 3's own entry-timeframe sweep detection.
[corrPHraw, corrPLraw, corrHigh, corrLow] = request.security(haveCorr ? corrSymbol : syminfo.tickerid, smtTF, getCorrData(), lookahead=barmerge.lookahead_off)

var float corrPivotHigh = na
var float corrPivotLow  = na
if haveCorr and not na(corrPHraw)
    corrPivotHigh := corrPHraw
if haveCorr and not na(corrPLraw)
    corrPivotLow := corrPLraw

getSMTPivots() =>
    ph3 = ta.pivothigh(high, ltfSwingLen, ltfSwingLen)
    pl3 = ta.pivotlow(low, ltfSwingLen, ltfSwingLen)
    [ph3, pl3, high, low]

[smtPHraw, smtPLraw, smtHigh, smtLow] = request.security(syminfo.tickerid, smtTF, getSMTPivots(), lookahead=barmerge.lookahead_off)

var float smtPivotHigh    = na
var float smtPivotLow     = na
var int   smtPivotHighBar = na
var int   smtPivotLowBar  = na
if not na(smtPHraw)
    smtPivotHigh    := smtPHraw
    smtPivotHighBar := bar_index
if not na(smtPLraw)
    smtPivotLow    := smtPLraw
    smtPivotLowBar := bar_index

bullSMTNow = haveCorr and not na(smtPivotLow) and not na(corrPivotLow) and smtLow < smtPivotLow and corrLow >= corrPivotLow
bearSMTNow = haveCorr and not na(smtPivotHigh) and not na(corrPivotHigh) and smtHigh > smtPivotHigh and corrHigh <= corrPivotHigh

// Mark SMT divergence directly on the chart, the way the videos point at it: this symbol makes a new
// low/high while the correlated symbol fails to confirm it. The line connects the actual two comparison
// points on THIS chart — the prior swing pivot and the new low/high that swept past it — since the
// correlated symbol's own price can't be plotted here (different instrument, different scale).
var line  smtBullLine  = na
var line  smtBearLine  = na
var label smtBullLabel = na
var label smtBearLabel = na

if bullSMTNow and (useSMT or useSimpleMode)
    line.delete(smtBullLine)
    smtBullLine := line.new(smtPivotLowBar, smtPivotLow, bar_index, smtLow, color=smtColor, width=2, style=line.style_dotted)
    label.delete(smtBullLabel)
    smtBullLabel := label.new(bar_index, smtLow, "SMT", style=label.style_label_up, color=smtColor, textcolor=color.white, size=size.small)

if bearSMTNow and (useSMT or useSimpleMode)
    line.delete(smtBearLine)
    smtBearLine := line.new(smtPivotHighBar, smtPivotHigh, bar_index, smtHigh, color=smtColor, width=2, style=line.style_dotted)
    label.delete(smtBearLabel)
    smtBearLabel := label.new(bar_index, smtHigh, "SMT", style=label.style_label_down, color=smtColor, textcolor=color.white, size=size.small)

// ============================== SIMPLE MODE: 15m SMT -> SWEEP -> SHIFT ==============================
// Data for the sweep + shift steps, fetched once on simpleTF (default 15m). Mirrors the CISD swing-level
// scan used elsewhere, just evaluated inside the simpleTF security context instead of on the chart.
getSimpleData() =>
    ph = ta.pivothigh(high, simpleSwingLen, simpleSwingLen)
    pl = ta.pivotlow(low, simpleSwingLen, simpleSwingLen)
    float bullSwing = high
    float bearSwing = low
    for i = 0 to simpleLookback - 1
        if close[i] < open[i]
            bullSwing := math.max(bullSwing, high[i])
        else
            break
    for i = 0 to simpleLookback - 1
        if close[i] > open[i]
            bearSwing := math.min(bearSwing, low[i])
        else
            break
    [ph, pl, high, low, close, bullSwing, bearSwing]

[simplePHraw, simplePLraw, simpleHigh, simpleLow, simpleClose, simpleBullSwing, simpleBearSwing] = request.security(syminfo.tickerid, simpleTF, getSimpleData(), lookahead=barmerge.lookahead_off)

var float simplePivotHigh = na
var float simplePivotLow  = na
if not na(simplePHraw)
    simplePivotHigh := simplePHraw
if not na(simplePLraw)
    simplePivotLow := simplePLraw

type SimpleState
    bool  smtConfirmed = false
    bool  sweepDone    = false
    bool  shiftDone    = false
    int   smtBar       = na
    int   sweepBar     = na
    float sweepLevel   = na
    float shiftTarget  = na
    float shiftLevel   = na
    int   consumedBar  = na
    line  sweepLine  = na
    label sweepLabel = na
    line  shiftLine  = na
    label shiftLabel = na

var SimpleState simpleBull = SimpleState.new()
var SimpleState simpleBear = SimpleState.new()

// Step 1 (bull): 15m SMT bullish divergence arms the sequence and resets anything stale from before.
if bullSMTNow
    simpleBull.smtConfirmed := true
    simpleBull.sweepDone    := false
    simpleBull.shiftDone    := false
    simpleBull.smtBar       := bar_index

// Timeout: drop the arming if the next step doesn't happen in time.
if simpleBull.smtConfirmed and not simpleBull.sweepDone and not na(simpleBull.smtBar) and (bar_index - simpleBull.smtBar) > simpleStepTimeout
    simpleBull.smtConfirmed := false
if simpleBull.sweepDone and not simpleBull.shiftDone and not na(simpleBull.sweepBar) and (bar_index - simpleBull.sweepBar) > simpleStepTimeout
    simpleBull.smtConfirmed := false
    simpleBull.sweepDone    := false

// Step 2 (bull): after SMT, a swing-low sweep on simpleTF.
if simpleBull.smtConfirmed and not simpleBull.sweepDone and not na(simplePivotLow) and simpleLow < simplePivotLow
    simpleBull.sweepDone   := true
    simpleBull.sweepBar    := bar_index
    simpleBull.sweepLevel  := simpleLow
    // Capture the "previous high to take out" ONCE, right here at the sweep. Using the live
    // simpleBullSwing value on later bars instead of this fixed snapshot was the bug that kept the
    // sequence from ever reaching Shift: simpleBullSwing keeps re-scanning "the swing high of whatever
    // bearish run is happening right now," so it silently drifted forward bar by bar instead of staying
    // anchored to the actual level from before the sweep, and a moving target is very hard to close through.
    simpleBull.shiftTarget := simpleBullSwing
    line.delete(simpleBull.sweepLine)
    simpleBull.sweepLine := line.new(bar_index - 2, simplePivotLow, bar_index + 20, simplePivotLow, color=smtColor, style=line.style_dashed)
    label.delete(simpleBull.sweepLabel)
    simpleBull.sweepLabel := label.new(bar_index, simpleLow, "SIMPLE Swept Low", style=label.style_label_down, color=smtColor, textcolor=color.white, size=size.tiny)

// Step 3 (bull): the 15m Shift — close back through the prior opposing swing high ("taking out previous high"),
// compared against the level captured at sweep time (shiftTarget), not the live-scanning simpleBullSwing.
if simpleBull.sweepDone and not simpleBull.shiftDone and not na(simpleBull.shiftTarget) and simpleClose > simpleBull.shiftTarget
    simpleBull.shiftDone  := true
    simpleBull.shiftLevel := simpleBull.shiftTarget
    line.delete(simpleBull.shiftLine)
    simpleBull.shiftLine := line.new(simpleBull.sweepBar, simpleBullSwing, bar_index, simpleBullSwing, color=shiftBullColor, width=2)
    label.delete(simpleBull.shiftLabel)
    simpleBull.shiftLabel := label.new(bar_index, simpleBullSwing, "SIMPLE Shift ✓ (prev high taken)", style=label.style_label_up, color=shiftBullColor, textcolor=color.white, size=size.small)

// Ready once the Shift confirms; only re-locks on an actual Tier 3 success (set further down), same
// "consumed on success, not on attempt" fix used for the regular cascade's gates.
simpleBullReady = simpleBull.shiftDone and (na(simpleBull.consumedBar) or simpleBull.consumedBar < simpleBull.smtBar)

// Mirror for bear: SMT bearish divergence -> swing-high sweep -> Shift taking out the previous low.
if bearSMTNow
    simpleBear.smtConfirmed := true
    simpleBear.sweepDone    := false
    simpleBear.shiftDone    := false
    simpleBear.smtBar       := bar_index

if simpleBear.smtConfirmed and not simpleBear.sweepDone and not na(simpleBear.smtBar) and (bar_index - simpleBear.smtBar) > simpleStepTimeout
    simpleBear.smtConfirmed := false
if simpleBear.sweepDone and not simpleBear.shiftDone and not na(simpleBear.sweepBar) and (bar_index - simpleBear.sweepBar) > simpleStepTimeout
    simpleBear.smtConfirmed := false
    simpleBear.sweepDone    := false

if simpleBear.smtConfirmed and not simpleBear.sweepDone and not na(simplePivotHigh) and simpleHigh > simplePivotHigh
    simpleBear.sweepDone   := true
    simpleBear.sweepBar    := bar_index
    simpleBear.sweepLevel  := simpleHigh
    // Same fix as the bull side: snapshot the "previous low to take out" at the moment of sweep instead
    // of comparing against the live-recomputed simpleBearSwing on every later bar.
    simpleBear.shiftTarget := simpleBearSwing
    line.delete(simpleBear.sweepLine)
    simpleBear.sweepLine := line.new(bar_index - 2, simplePivotHigh, bar_index + 20, simplePivotHigh, color=smtColor, style=line.style_dashed)
    label.delete(simpleBear.sweepLabel)
    simpleBear.sweepLabel := label.new(bar_index, simpleHigh, "SIMPLE Swept High", style=label.style_label_up, color=smtColor, textcolor=color.white, size=size.tiny)

if simpleBear.sweepDone and not simpleBear.shiftDone and not na(simpleBear.shiftTarget) and simpleClose < simpleBear.shiftTarget
    simpleBear.shiftDone  := true
    simpleBear.shiftLevel := simpleBear.shiftTarget
    line.delete(simpleBear.shiftLine)
    simpleBear.shiftLine := line.new(simpleBear.sweepBar, simpleBearSwing, bar_index, simpleBearSwing, color=shiftBearColor, width=2)
    label.delete(simpleBear.shiftLabel)
    simpleBear.shiftLabel := label.new(bar_index, simpleBearSwing, "SIMPLE Shift ✓ (prev low taken)", style=label.style_label_down, color=shiftBearColor, textcolor=color.white, size=size.small)

simpleBearReady = simpleBear.shiftDone and (na(simpleBear.consumedBar) or simpleBear.consumedBar < simpleBear.smtBar)

// ============================== CISD / ORDER-BLOCK ORIGIN HELPERS ==============================
// Two videos (2026-07-11) showed the same failure mode this originally used: confirming the shift on a
// close beyond the origin candle's open fires too early and "goes straight into your stop loss." What
// was actually demonstrated both times was a close beyond the last swing high/low BEFORE the sweep leg,
// on a candle with real displacement (momentum), not just any close. Both levels are computed below;
// cisdMode picks which one gates entries, defaulting to the swing-based one those videos argued for.
getBullCISDLevel() =>
    float lvlOpen = open
    float lvlSwing = high
    int originOffset = 0
    for i = 0 to cisdLookback - 1
        if close[i] < open[i]
            lvlOpen := open[i]
            lvlSwing := math.max(lvlSwing, high[i])
            originOffset := i
        else
            break
    [lvlOpen, lvlSwing, originOffset]

getBearCISDLevel() =>
    float lvlOpen = open
    float lvlSwing = low
    int originOffset = 0
    for i = 0 to cisdLookback - 1
        if close[i] > open[i]
            lvlOpen := open[i]
            lvlSwing := math.min(lvlSwing, low[i])
            originOffset := i
        else
            break
    [lvlOpen, lvlSwing, originOffset]

// this chart's own average candle range, used to judge "displacement" (momentum) on the CISD candle
avgRange = ta.atr(14)

// ============================== GENERIC TIER ENGINE ==============================
// gateOK          - allowed to start a brand new sweep hunt this bar
// applyRR         - compute fixed-R target / SL / TP (Tier 3 only)
// applySessionGate- require sessionOK for this tier's completion (Tier 3 only; Tier 2's gate already
//                   requires sessionOK before it can even start)
// requireSMTHere  - require SMT divergence for completion (Tier 3 only, and only if user turned it on)
// smtNow          - this bar's raw SMT condition, snapshotted onto the tier at sweep time
processTierBull(TierState st, float pivotLow, float pivotHigh, bool gateOK, bool applyRR, bool gateOnRR, bool drawZone, bool applySessionGate, bool requireSMTHere, bool smtNow, color tierColor, string tierTag, bool drawVisuals) =>
    st.justCompleted := false

    if st.pending and not st.cisdDone and not na(st.sweepBar) and (bar_index - st.sweepBar) > cisdTimeout
        st.pending  := false
        st.sweepBar := na
    if st.pending and st.cisdDone and not st.fvgFound and not na(st.cisdBar) and (bar_index - st.cisdBar) > fvgTimeout
        st.pending  := false
        st.cisdDone := false
    if st.pending and st.awaitingRetest and not na(st.fvgBar) and (bar_index - st.fvgBar) > retestTimeout
        st.pending        := false
        st.awaitingRetest := false

    // The actual "take it" trigger: a later candle wicks back into the FVG and holds. Checked here, BEFORE
    // this bar's own fvgCond block runs below, so a freshly-formed FVG can never confirm against itself —
    // it always takes at least one more bar of price action.
    bullRetestCond = st.awaitingRetest and not na(st.gapTop) and not na(st.gapBot) and low <= st.gapTop and close >= st.gapBot
    if st.pending and st.awaitingRetest and bullRetestCond
        stop   = st.sweepLevel
        entry  = st.gapTop
        risk   = entry - stop
        needed = risk * minRR
        roomToOpposing = na(st.rangeOpp) ? na : st.rangeOpp - entry
        st.entryPrice  := entry
        st.rrOK        := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
        st.targetPrice := risk > 0 ? entry + needed : na

        // Line drawing for SL/TP/Entry now lives entirely in repositionLineLabels(), which redraws them
        // together with their labels every bar so the line always ends exactly at the label instead of
        // drifting apart from it.
        st.complete      := st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
        st.justCompleted := st.complete
        if risk > 0 and st.complete
            st.tradeLive    := true
            st.liveEntry    := entry
            st.liveStop     := stop
            st.liveTarget   := st.targetPrice
            st.liveEntryBar := bar_index
            st.liveEntryTime := time
        if drawVisuals
            // Only draw the banner when this is an actual, actionable signal (st.complete). A retest that
            // fails the R:R check or session gate isn't something to announce with a giant label — showing
            // a gray "TAKE" banner for every failed attempt was exactly what was overtaking the chart.
            label.delete(st.completeLabel)
            label.delete(st.takeLabel)
            if st.complete
                st.takeLabel := label.new(bar_index, entry, "▲ TAKE LONG " + tierTag, style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.large)
        st.awaitingRetest := false
        st.pending        := false

    sweepCond = gateOK and not na(pivotLow) and low < pivotLow and (not requireRejection or close > pivotLow) and not st.pending
    if sweepCond
        st.pending    := true
        st.cisdDone   := false
        st.fvgFound   := false
        st.levelOK    := false
        st.rrOK       := false
        st.complete   := false
        st.usedIFVG   := false
        st.smtFlag    := smtNow
        st.sweepBar   := bar_index
        st.sweepLevel := low
        st.rangeOpp   := pivotHigh
        [cisdLvlOpen, cisdLvlSwing, originOffset] = getBullCISDLevel()
        st.cisdLevel  := cisdMode == "Origin Candle Open (aggressive)" ? cisdLvlOpen : cisdLvlSwing
        st.cisdBar    := na

        if drawVisuals
            box.delete(st.poiBox)
            st.poiBox := box.new(bar_index - 2, pivotLow, bar_index + 20, low, border_color=tierColor, bgcolor=color.new(tierColor, 85), text=tierTag + " POI", text_color=tierColor, text_size=size.small)
            line.delete(st.sweepLine)
            st.sweepLine := line.new(bar_index - 2, pivotLow, bar_index + 20, pivotLow, color=tierColor, style=line.style_dashed)
            label.delete(st.sweptLabel)
            st.sweptLabel := label.new(bar_index - 2, pivotLow, tierTag + " Swept Low", style=label.style_label_down, color=tierColor, textcolor=color.white, size=size.tiny)

            box.delete(st.obBox)
            st.obBox := box.new(bar_index - originOffset - 1, high[originOffset], bar_index - originOffset + 1, low[originOffset], border_color=color.purple, bgcolor=color.new(color.purple, 85), text=tierTag + " OB", text_color=color.purple, text_size=size.small)

    if st.pending and not st.cisdDone and low < st.sweepLevel
        st.sweepLevel := low

    bullDisplacementOK = not requireDisplacement or (high - low) >= avgRange * displacementMult
    if st.pending and not st.cisdDone and close > st.cisdLevel and bullDisplacementOK
        st.cisdDone := true
        st.cisdBar  := bar_index
        if drawVisuals
            line.delete(st.cisdLine)
            st.cisdLine := line.new(st.sweepBar, st.cisdLevel, bar_index, st.cisdLevel, color=shiftBullColor, width=2)
            label.delete(st.shiftLabel)
            st.shiftLabel := label.new(bar_index, st.cisdLevel, tierTag + " Swing High — Shift ✓", style=label.style_label_up, color=shiftBullColor, textcolor=color.white, size=size.small)

    fvgCond = low > high[2]
    if st.pending and st.cisdDone and not st.fvgFound and fvgCond
        gapLow  = high[2]
        gapHigh = low
        gapSize = gapHigh - gapLow
        sizeOK  = fvgMinTicks == 0.0 or gapSize >= fvgMinTicks * syminfo.mintick

        if sizeOK
            eq     = na(st.rangeOpp) ? na : (st.rangeOpp + st.sweepLevel) / 2
            midFVG = (gapHigh + gapLow) / 2
            st.levelOK  := not na(eq) and midFVG < eq
            st.fvgFound := true
            st.gapTop   := gapHigh
            st.gapBot   := gapLow

            boxCol = st.levelOK ? discountColor : color.new(color.gray, 80)
            if drawVisuals
                box.delete(st.fvgBox)
                st.fvgBox := box.new(bar_index - 2, gapHigh, bar_index + 20, gapLow, border_color=color.lime, bgcolor=boxCol, text=tierTag + " FVG", text_color=color.lime, text_size=size.small)

            if not na(eq) and drawZone and drawVisuals
                box.delete(st.premBox)
                box.delete(st.discBox)
                line.delete(st.eqLine)
                st.premBox := box.new(st.sweepBar, st.rangeOpp, bar_index, eq, border_color=na, bgcolor=premiumColor, text="PREMIUM", text_color=color.white, text_size=size.tiny)
                st.discBox := box.new(st.sweepBar, eq, bar_index, st.sweepLevel, border_color=na, bgcolor=discountColor, text="DISCOUNT", text_color=color.white, text_size=size.tiny)
                st.eqLine  := line.new(st.sweepBar, eq, bar_index, eq, color=color.new(color.gray, 30), style=line.style_dotted)

            st.entryPrice := gapHigh
            waitForRetest = applyRR and requireRetestForEntry and gateOnRR
            if waitForRetest
                st.awaitingRetest := true
                st.fvgBar := bar_index
                st.rrOK   := false
            else if applyRR
                stop   = st.sweepLevel
                risk   = st.entryPrice - stop
                needed = risk * minRR
                roomToOpposing = na(st.rangeOpp) ? na : st.rangeOpp - st.entryPrice
                st.rrOK := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
                st.targetPrice := risk > 0 ? st.entryPrice + needed : na

                // Line drawing now happens centrally in repositionLineLabels() alongside the labels.
                if risk > 0
                    earlyComplete = st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
                    if earlyComplete
                        st.tradeLive    := true
                        st.liveEntry    := st.entryPrice
                        st.liveStop     := stop
                        st.liveTarget   := st.targetPrice
                        st.liveEntryBar := bar_index
                        st.liveEntryTime := time
            else
                st.rrOK := true

            st.complete := st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
            st.justCompleted := st.complete
            if drawVisuals
                lblTxt = tierTag + " Bullish" + (waitForRetest ? " — watching for retest" : (applyRR and not na(st.targetPrice) ? "\nTP " + str.tostring(st.targetPrice, format.mintick) : ""))
                label.delete(st.completeLabel)
                st.completeLabel := label.new(bar_index, gapHigh, lblTxt, style=label.style_label_down, color=st.complete ? color.green : color.new(color.gray, 40), textcolor=color.white, size=size.small)

        if not (sizeOK and applyRR and requireRetestForEntry and gateOnRR)
            st.pending := false
    st.complete

processTierBear(TierState st, float pivotHigh, float pivotLow, bool gateOK, bool applyRR, bool gateOnRR, bool drawZone, bool applySessionGate, bool requireSMTHere, bool smtNow, color tierColor, string tierTag, bool drawVisuals) =>
    st.justCompleted := false

    if st.pending and not st.cisdDone and not na(st.sweepBar) and (bar_index - st.sweepBar) > cisdTimeout
        st.pending  := false
        st.sweepBar := na
    if st.pending and st.cisdDone and not st.fvgFound and not na(st.cisdBar) and (bar_index - st.cisdBar) > fvgTimeout
        st.pending  := false
        st.cisdDone := false
    if st.pending and st.awaitingRetest and not na(st.fvgBar) and (bar_index - st.fvgBar) > retestTimeout
        st.pending        := false
        st.awaitingRetest := false

    // The actual "take it" trigger: a later candle wicks back into the FVG and holds. Checked here, BEFORE
    // this bar's own fvgCond block runs below, so a freshly-formed FVG can never confirm against itself —
    // it always takes at least one more bar of price action.
    bearRetestCond = st.awaitingRetest and not na(st.gapTop) and not na(st.gapBot) and high >= st.gapBot and close <= st.gapTop
    if st.pending and st.awaitingRetest and bearRetestCond
        stop   = st.sweepLevel
        entry  = st.gapBot
        risk   = stop - entry
        needed = risk * minRR
        roomToOpposing = na(st.rangeOpp) ? na : entry - st.rangeOpp
        st.entryPrice  := entry
        st.rrOK        := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
        st.targetPrice := risk > 0 ? entry - needed : na

        // Line drawing now happens centrally in repositionLineLabels() alongside the labels.
        st.complete      := st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
        st.justCompleted := st.complete
        if risk > 0 and st.complete
            st.tradeLive    := true
            st.liveEntry    := entry
            st.liveStop     := stop
            st.liveTarget   := st.targetPrice
            st.liveEntryBar := bar_index
            st.liveEntryTime := time
        if drawVisuals
            label.delete(st.completeLabel)
            label.delete(st.takeLabel)
            if st.complete
                st.takeLabel := label.new(bar_index, entry, "▼ TAKE SHORT " + tierTag, style=label.style_label_down, color=color.lime, textcolor=color.black, size=size.large)
        st.awaitingRetest := false
        st.pending        := false

    sweepCond = gateOK and not na(pivotHigh) and high > pivotHigh and (not requireRejection or close < pivotHigh) and not st.pending
    if sweepCond
        st.pending    := true
        st.cisdDone   := false
        st.fvgFound   := false
        st.levelOK    := false
        st.rrOK       := false
        st.complete   := false
        st.usedIFVG   := false
        st.smtFlag    := smtNow
        st.sweepBar   := bar_index
        st.sweepLevel := high
        st.rangeOpp   := pivotLow
        [cisdLvlOpen, cisdLvlSwing, originOffset] = getBearCISDLevel()
        st.cisdLevel  := cisdMode == "Origin Candle Open (aggressive)" ? cisdLvlOpen : cisdLvlSwing
        st.cisdBar    := na

        if drawVisuals
            box.delete(st.poiBox)
            st.poiBox := box.new(bar_index - 2, high, bar_index + 20, pivotHigh, border_color=tierColor, bgcolor=color.new(tierColor, 85), text=tierTag + " POI", text_color=tierColor, text_size=size.small)
            line.delete(st.sweepLine)
            st.sweepLine := line.new(bar_index - 2, pivotHigh, bar_index + 20, pivotHigh, color=tierColor, style=line.style_dashed)
            label.delete(st.sweptLabel)
            st.sweptLabel := label.new(bar_index - 2, pivotHigh, tierTag + " Swept High", style=label.style_label_up, color=tierColor, textcolor=color.white, size=size.tiny)

            box.delete(st.obBox)
            st.obBox := box.new(bar_index - originOffset - 1, high[originOffset], bar_index - originOffset + 1, low[originOffset], border_color=color.purple, bgcolor=color.new(color.purple, 85), text=tierTag + " OB", text_color=color.purple, text_size=size.small)

    if st.pending and not st.cisdDone and high > st.sweepLevel
        st.sweepLevel := high

    bearDisplacementOK = not requireDisplacement or (high - low) >= avgRange * displacementMult
    if st.pending and not st.cisdDone and close < st.cisdLevel and bearDisplacementOK
        st.cisdDone := true
        st.cisdBar  := bar_index
        if drawVisuals
            line.delete(st.cisdLine)
            st.cisdLine := line.new(st.sweepBar, st.cisdLevel, bar_index, st.cisdLevel, color=shiftBearColor, width=2)
            label.delete(st.shiftLabel)
            st.shiftLabel := label.new(bar_index, st.cisdLevel, tierTag + " Swing Low — Shift ✓", style=label.style_label_down, color=shiftBearColor, textcolor=color.white, size=size.small)

    fvgCond = high < low[2]
    if st.pending and st.cisdDone and not st.fvgFound and fvgCond
        gapHigh = low[2]
        gapLow  = high
        gapSize = gapHigh - gapLow
        sizeOK  = fvgMinTicks == 0.0 or gapSize >= fvgMinTicks * syminfo.mintick

        if sizeOK
            eq     = na(st.rangeOpp) ? na : (st.sweepLevel + st.rangeOpp) / 2
            midFVG = (gapHigh + gapLow) / 2
            st.levelOK  := not na(eq) and midFVG > eq
            st.fvgFound := true
            st.gapTop   := gapHigh
            st.gapBot   := gapLow

            boxCol = st.levelOK ? premiumColor : color.new(color.gray, 80)
            if drawVisuals
                box.delete(st.fvgBox)
                st.fvgBox := box.new(bar_index - 2, gapHigh, bar_index + 20, gapLow, border_color=color.fuchsia, bgcolor=boxCol, text=tierTag + " FVG", text_color=color.fuchsia, text_size=size.small)

            if not na(eq) and drawZone and drawVisuals
                box.delete(st.premBox)
                box.delete(st.discBox)
                line.delete(st.eqLine)
                st.premBox := box.new(st.sweepBar, st.sweepLevel, bar_index, eq, border_color=na, bgcolor=premiumColor, text="PREMIUM", text_color=color.white, text_size=size.tiny)
                st.discBox := box.new(st.sweepBar, eq, bar_index, st.rangeOpp, border_color=na, bgcolor=discountColor, text="DISCOUNT", text_color=color.white, text_size=size.tiny)
                st.eqLine  := line.new(st.sweepBar, eq, bar_index, eq, color=color.new(color.gray, 30), style=line.style_dotted)

            st.entryPrice := gapLow
            waitForRetest = applyRR and requireRetestForEntry and gateOnRR
            if waitForRetest
                st.awaitingRetest := true
                st.fvgBar := bar_index
                st.rrOK   := false
            else if applyRR
                stop   = st.sweepLevel
                risk   = stop - st.entryPrice
                needed = risk * minRR
                roomToOpposing = na(st.rangeOpp) ? na : st.entryPrice - st.rangeOpp
                st.rrOK := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
                st.targetPrice := risk > 0 ? st.entryPrice - needed : na

                // Line drawing now happens centrally in repositionLineLabels() alongside the labels.
                if risk > 0
                    earlyComplete = st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
                    if earlyComplete
                        st.tradeLive    := true
                        st.liveEntry    := st.entryPrice
                        st.liveStop     := stop
                        st.liveTarget   := st.targetPrice
                        st.liveEntryBar := bar_index
                        st.liveEntryTime := time
            else
                st.rrOK := true

            st.complete := st.levelOK and (not gateOnRR or st.rrOK) and (not applySessionGate or sessionOK) and (not requireSMTHere or not useSMT or st.smtFlag)
            st.justCompleted := st.complete
            if drawVisuals
                lblTxt = tierTag + " Bearish" + (waitForRetest ? " — watching for retest" : (applyRR and not na(st.targetPrice) ? "\nTP " + str.tostring(st.targetPrice, format.mintick) : ""))
                label.delete(st.completeLabel)
                st.completeLabel := label.new(bar_index, gapLow, lblTxt, style=label.style_label_up, color=st.complete ? color.red : color.new(color.gray, 40), textcolor=color.white, size=size.small)

        if not (sizeOK and applyRR and requireRetestForEntry and gateOnRR)
            st.pending := false
    st.complete

// ============================== ACTIVE TRADE PANEL (fixed on screen — never sits on top of price) ==============================
// Chasing on-chart labels (redrawing text at the current bar every bar a trade is live) still collided with
// history-anchored labels like the "TAKE" banner or the CISD "Shift" tag, because both live in the same
// bar/price space as the candles. A table is different: it renders in a fixed screen corner regardless of
// zoom, scroll, or how far price has moved since entry, so it's the one place these numbers are guaranteed
// not to overlap anything. The on-chart Entry/SL/TP lines and labels (see repositionLineLabels below) still
// mark the levels directly on the chart; this panel is a guaranteed-readable backup for the same numbers.
var table tradePanel = table.new(position.middle_right, 2, 6, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.gray, frame_width=1, frame_color=color.gray)

// Recency check shared by all six tier states. Keyed off liveEntryBar (which persists), NOT tradeLive —
// tradeLive can flip true->false within the same recalculation pass on a fast trade, before barstate.islast
// ever renders the "active" state to a human watching, which was the original "always says No active trade"
// bug. panelStaleBars keeps an old trade from sitting next to current price looking falsely current.
recentOK(TierState st) =>
    not na(st.liveEntryBar) and (panelStaleBars == 0 or (bar_index - st.liveEntryBar) <= panelStaleBars)

// Originally this only looked at Tier 3. Per request, it now checks all three tiers (T1/T2/T3), both
// directions — six candidates — and shows whichever one most recently produced a trade, tagged with which
// tier it came from so a T1 or T2 trade doesn't get confused for a Tier 3 one.
updateTradePanel() =>
    if showTradePanel
        TierState winner = na
        winnerTag = ""
        winnerBull = true
        bestBar = -1

        if recentOK(t1Bull) and t1Bull.liveEntryBar > bestBar
            winner := t1Bull
            winnerTag := "T1"
            winnerBull := true
            bestBar := t1Bull.liveEntryBar
        if recentOK(t1Bear) and t1Bear.liveEntryBar > bestBar
            winner := t1Bear
            winnerTag := "T1"
            winnerBull := false
            bestBar := t1Bear.liveEntryBar
        if recentOK(t2Bull) and t2Bull.liveEntryBar > bestBar
            winner := t2Bull
            winnerTag := "T2"
            winnerBull := true
            bestBar := t2Bull.liveEntryBar
        if recentOK(t2Bear) and t2Bear.liveEntryBar > bestBar
            winner := t2Bear
            winnerTag := "T2"
            winnerBull := false
            bestBar := t2Bear.liveEntryBar
        if recentOK(t3Bull) and t3Bull.liveEntryBar > bestBar
            winner := t3Bull
            winnerTag := "T3"
            winnerBull := true
            bestBar := t3Bull.liveEntryBar
        if recentOK(t3Bear) and t3Bear.liveEntryBar > bestBar
            winner := t3Bear
            winnerTag := "T3"
            winnerBull := false
            bestBar := t3Bear.liveEntryBar

        if not na(winner)
            dirColor  = winnerBull ? color.blue : color.purple
            arrow     = winnerBull ? "▲ LONG ENTRY" : "▼ SHORT ENTRY"
            statusTxt = arrow + " (" + winnerTag + ")" + (winner.tradeLive ? " (open)" : " (closed)")
            table.cell(tradePanel, 0, 0, statusTxt, text_color=color.white, bgcolor=dirColor, text_size=size.normal)
            table.cell(tradePanel, 1, 0, "", bgcolor=dirColor)
            table.cell(tradePanel, 0, 1, "Entry", text_color=color.white, bgcolor=color.new(dirColor, 70), text_size=size.normal)
            table.cell(tradePanel, 1, 1, str.tostring(winner.liveEntry, format.mintick), text_color=color.white, bgcolor=color.new(dirColor, 70), text_size=size.normal)
            table.cell(tradePanel, 0, 2, "SL", text_color=color.white, bgcolor=color.new(color.red, 70), text_size=size.normal)
            table.cell(tradePanel, 1, 2, str.tostring(winner.liveStop, format.mintick), text_color=color.white, bgcolor=color.new(color.red, 70), text_size=size.normal)
            table.cell(tradePanel, 0, 3, "TP", text_color=color.black, bgcolor=color.new(color.lime, 70), text_size=size.normal)
            table.cell(tradePanel, 1, 3, str.tostring(winner.liveTarget, format.mintick), text_color=color.black, bgcolor=color.new(color.lime, 70), text_size=size.normal)
            table.cell(tradePanel, 0, 4, "R:R", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.normal)
            table.cell(tradePanel, 1, 4, str.tostring(minRR, "#.##") + " : 1", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.normal)
            table.cell(tradePanel, 0, 5, "When", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
            table.cell(tradePanel, 1, 5, str.format_time(winner.liveEntryTime, "MMM dd HH:mm", syminfo.timezone) + " (" + str.tostring(bar_index - winner.liveEntryBar) + " bars ago)", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        else
            table.cell(tradePanel, 0, 0, "No active trade", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.small)
            table.cell(tradePanel, 1, 0, "", bgcolor=color.new(color.gray, 40))
            table.cell(tradePanel, 0, 1, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 1, 1, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 0, 2, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 1, 2, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 0, 3, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 1, 3, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 0, 4, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 1, 4, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 0, 5, "", bgcolor=color.new(color.gray, 90))
            table.cell(tradePanel, 1, 5, "", bgcolor=color.new(color.gray, 90))

// ============================== ON-LINE LABELS (sit in the blank margin to the right, on their own line) ==============================
// Anchoring at bar_index put these right on top of the current bar, colliding with whatever else is
// happening in price action there. TradingView always leaves a blank margin past the last bar — pushing
// the anchor out into that empty space (bar_index + labelRightOffset) is what actually keeps them clear of
// the candles, matching where they need to sit. Text is deliberately just the plain word: the line's color
// (blue/red/lime) already says which level it is, and the exact price is on the fixed panel — restating
// direction arrows, tier tags, and numbers here was the actual clutter.
// Keyed off st.justCompleted, which is true for exactly the one bar a signal fires (processTier resets it
// to false at the top of every bar). That means this only runs ONCE per trade: the line/label position is
// computed a single time and then left alone — it does not keep chasing bar_index forward on every
// subsequent bar. A resolved trade's Entry/SL/TP simply stays wherever it was last drawn; only a genuinely
// new signal (its own justCompleted bar) moves it.
repositionLineLabels(TierState st, bool isBull, bool drawVisuals) =>
    if drawVisuals and st.justCompleted
        x = bar_index + labelRightOffset
        entryColor = isBull ? color.blue : color.purple
        line.delete(st.entryLine)
        line.delete(st.slLine)
        line.delete(st.tpLine)
        st.entryLine := line.new(st.liveEntryBar, st.liveEntry, x, st.liveEntry, color=entryColor, width=2, style=line.style_dashed)
        st.slLine    := line.new(st.liveEntryBar, st.liveStop, x, st.liveStop, color=color.red, width=2, style=line.style_dashed)
        st.tpLine    := line.new(st.liveEntryBar, st.liveTarget, x, st.liveTarget, color=color.lime, width=2, style=line.style_dashed)

        label.delete(st.entryLabel)
        label.delete(st.slLabel)
        label.delete(st.tpLabel)
        st.entryLabel := label.new(x, st.liveEntry, "Entry", style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.normal)
        st.slLabel    := label.new(x, st.liveStop, "Stop Loss", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.normal)
        st.tpLabel    := label.new(x, st.liveTarget, "Take Profit", style=label.style_label_left, color=color.lime, textcolor=color.black, size=size.normal)

// ============================== TRADE OUTCOME TRACKING ==============================
// So a completed signal shows what actually happened afterward, not just a static entry that sits there
// looking "right" forever. Checked every bar for any tier with a live (just-taken) trade. If a single bar's
// range could satisfy both stop and target, the stop is assumed to have hit first — the standard
// conservative assumption when you don't know the intrabar order, since the alternative (assuming the best
// case) would flatter every signal.
checkTradeOutcome(TierState st, bool isBull, string tierTag, bool drawVisuals) =>
    if st.tradeLive
        stoppedOut = isBull ? low <= st.liveStop : high >= st.liveStop
        hitTarget  = isBull ? high >= st.liveTarget : low <= st.liveTarget
        if stoppedOut or hitTarget
            // Entry/Stop Loss/Take Profit are deliberately left alone here — they now persist at the right
            // margin as a standing reference for the last trade this tier took (see repositionLineLabels),
            // resolved or not. Only the one-time "TAKE" banner is cleared, since it already did its job of
            // announcing the signal and isn't needed once the trade is done.
            label.delete(st.takeLabel)
            label.delete(st.completeLabel)
            label.delete(st.outcomeLabel)
        if stoppedOut and drawVisuals
            st.outcomeLabel := label.new(bar_index, st.liveStop, tierTag + " ✕ stopped out", style=isBull ? label.style_label_down : label.style_label_up, color=color.red, textcolor=color.white, size=size.normal)
            st.tradeLive := false
        else if hitTarget and drawVisuals
            st.outcomeLabel := label.new(bar_index, st.liveTarget, tierTag + " ✓ target hit", style=isBull ? label.style_label_up : label.style_label_down, color=color.lime, textcolor=color.black, size=size.normal)
            st.tradeLive := false
        else if stoppedOut or hitTarget
            st.tradeLive := false
            st.tradeLive := false

// ============================== RUN THE CASCADE ==============================
// Tier 1: always allowed to hunt fresh
t1BullComplete = processTierBull(t1Bull, htfPivotLow, htfPivotHigh, true, showEntryT1T2, gateT1T2OnRR, showZoneT1T2, false, false, false, color.orange, "T1 HTF", showTier12Marks)
t1BearComplete = processTierBear(t1Bear, htfPivotHigh, htfPivotLow, true, showEntryT1T2, gateT1T2OnRR, showZoneT1T2, false, false, false, color.orange, "T1 HTF", showTier12Marks)
if alertT1T2 and t1Bull.justCompleted
    alert("T1 HTF LONG CONFIRMED — Entry " + str.tostring(t1Bull.liveEntry, format.mintick) + "  SL " + str.tostring(t1Bull.liveStop, format.mintick) + "  TP " + str.tostring(t1Bull.liveTarget, format.mintick), alert.freq_once_per_bar)
if alertT1T2 and t1Bear.justCompleted
    alert("T1 HTF SHORT CONFIRMED — Entry " + str.tostring(t1Bear.liveEntry, format.mintick) + "  SL " + str.tostring(t1Bear.liveStop, format.mintick) + "  TP " + str.tostring(t1Bear.liveTarget, format.mintick), alert.freq_once_per_bar)

// Tier 2: only a fresh hunt once its matching Tier 1 has completed and this is a NEW Tier 1 cycle,
// and only inside an enabled kill zone.
// IMPORTANT: this gate is keyed off consumedParentBar, which only updates when Tier 2 actually SUCCEEDS
// (justCompleted), not on every attempt. Earlier this was keyed off sweepBar instead, which closed the
// gate the instant Tier 2 took its first swing at a sweep — success or failure. That meant one failed
// attempt permanently locked Tier 2 out until Tier 1 fired an entirely new cycle, which on a slow HTF
// could be days away. This was very likely the reason for long stretches with no signal at all.
gateT2Bull = t1Bull.complete and (na(t2Bull.consumedParentBar) or t2Bull.consumedParentBar < t1Bull.sweepBar) and sessionOK
gateT2Bear = t1Bear.complete and (na(t2Bear.consumedParentBar) or t2Bear.consumedParentBar < t1Bear.sweepBar) and sessionOK
t2BullComplete = processTierBull(t2Bull, midPivotLow, midPivotHigh, gateT2Bull, showEntryT1T2, gateT1T2OnRR, showZoneT1T2, false, false, bullSMTNow, color.blue, "T2 MID", showTier12Marks)
t2BearComplete = processTierBear(t2Bear, midPivotHigh, midPivotLow, gateT2Bear, showEntryT1T2, gateT1T2OnRR, showZoneT1T2, false, false, bearSMTNow, color.blue, "T2 MID", showTier12Marks)
if t2Bull.justCompleted
    t2Bull.consumedParentBar := t1Bull.sweepBar
    if alertT1T2
        alert("T2 MID LONG CONFIRMED — Entry " + str.tostring(t2Bull.liveEntry, format.mintick) + "  SL " + str.tostring(t2Bull.liveStop, format.mintick) + "  TP " + str.tostring(t2Bull.liveTarget, format.mintick), alert.freq_once_per_bar)
if t2Bear.justCompleted
    t2Bear.consumedParentBar := t1Bear.sweepBar
    if alertT1T2
        alert("T2 MID SHORT CONFIRMED — Entry " + str.tostring(t2Bear.liveEntry, format.mintick) + "  SL " + str.tostring(t2Bear.liveStop, format.mintick) + "  TP " + str.tostring(t2Bear.liveTarget, format.mintick), alert.freq_once_per_bar)

// Tier 3: same fix — only a NEW Tier 2 cycle re-opens the gate, and Tier 3 keeps re-attempting sweeps
// against the same Tier 2 completion until it actually succeeds, instead of being burned by its first try.
// Simple Mode override: when on, Tier 3 is gated entirely by the 15m SMT->sweep->Shift sequence above
// instead of the HTF/Mid cascade. Tier 1/2 still run (untouched) but no longer feed Tier 3 while this is on.
gateT3BullCascade = t2Bull.complete and (na(t3Bull.consumedParentBar) or t3Bull.consumedParentBar < t2Bull.sweepBar)
gateT3BearCascade = t2Bear.complete and (na(t3Bear.consumedParentBar) or t3Bear.consumedParentBar < t2Bear.sweepBar)
gateT3Bull = useSimpleMode ? simpleBullReady : gateT3BullCascade
gateT3Bear = useSimpleMode ? simpleBearReady : gateT3BearCascade
t3BullComplete = processTierBull(t3Bull, ltfPivotLow, ltfPivotHigh, gateT3Bull, true, true, true, true, requireSMT, bullSMTNow, color.purple, "ENTRY", true)
t3BearComplete = processTierBear(t3Bear, ltfPivotHigh, ltfPivotLow, gateT3Bear, true, true, true, true, requireSMT, bearSMTNow, color.purple, "ENTRY", true)

// ============================== IFVG TRACKING (this chart's timeframe, most recent of each type only) ==============================
var float lastBullFVGTop = na   // upper bound of the most recent bullish-origin FVG (support zone)
var float lastBullFVGBot = na
var bool  lastBullFVGInv = false
var box   lastBullFVGBox = na

var float lastBearFVGTop = na   // upper bound of the most recent bearish-origin FVG (resistance zone)
var float lastBearFVGBot = na
var bool  lastBearFVGInv = false
var box   lastBearFVGBox = na

rawBullFVG = low > high[2]
rawBearFVG = high < low[2]

if useIFVG and rawBullFVG
    lastBullFVGTop := low
    lastBullFVGBot := high[2]
    lastBullFVGInv := false
    box.delete(lastBullFVGBox)
    lastBullFVGBox := box.new(bar_index - 2, low, bar_index + 20, high[2], border_color=color.teal, bgcolor=color.new(color.teal, 85), text="FVG", text_color=color.teal, text_size=size.tiny)

if useIFVG and rawBearFVG
    lastBearFVGTop := low[2]
    lastBearFVGBot := high
    lastBearFVGInv := false
    box.delete(lastBearFVGBox)
    lastBearFVGBox := box.new(bar_index - 2, low[2], bar_index + 20, high, border_color=color.fuchsia, bgcolor=color.new(color.fuchsia, 85), text="FVG", text_color=color.fuchsia, text_size=size.tiny)

if useIFVG and not na(lastBullFVGBot) and not lastBullFVGInv and close < lastBullFVGBot
    lastBullFVGInv := true
    box.delete(lastBullFVGBox)
    lastBullFVGBox := box.new(bar_index - 2, lastBullFVGTop, bar_index + 20, lastBullFVGBot, border_color=color.fuchsia, bgcolor=color.new(color.fuchsia, 85), text="IFVG", text_color=color.fuchsia, text_size=size.tiny)

if useIFVG and not na(lastBearFVGTop) and not lastBearFVGInv and close > lastBearFVGTop
    lastBearFVGInv := true
    box.delete(lastBearFVGBox)
    lastBearFVGBox := box.new(bar_index - 2, lastBearFVGTop, bar_index + 20, lastBearFVGBot, border_color=color.teal, bgcolor=color.new(color.teal, 85), text="IFVG", text_color=color.teal, text_size=size.tiny)

// a bearish-origin FVG that inverted is now support: bullish retest = wick into it, close back above its top
bullIFVGRetest = useIFVG and lastBearFVGInv and high >= lastBearFVGTop and close > lastBearFVGTop
// a bullish-origin FVG that inverted is now resistance: bearish retest = wick into it, close back below its bottom
bearIFVGRetest = useIFVG and lastBullFVGInv and low <= lastBullFVGBot and close < lastBullFVGBot

// If Tier 3 is hunting its FVG and a normal one hasn't shown up, let a confirmed IFVG retest stand in.
if gateT3Bull and t3Bull.pending and t3Bull.cisdDone and not t3Bull.fvgFound and bullIFVGRetest
    gapHigh = lastBearFVGTop
    gapLow  = lastBearFVGBot
    eq      = na(t3Bull.rangeOpp) ? na : (t3Bull.rangeOpp + t3Bull.sweepLevel) / 2
    midFVG  = (gapHigh + gapLow) / 2
    t3Bull.levelOK  := not na(eq) and midFVG < eq
    t3Bull.fvgFound := true
    t3Bull.usedIFVG := true

    entry  = gapHigh
    stop   = t3Bull.sweepLevel
    risk   = entry - stop
    needed = risk * minRR
    roomToOpposing = na(t3Bull.rangeOpp) ? na : t3Bull.rangeOpp - entry
    t3Bull.entryPrice := entry
    t3Bull.rrOK := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
    t3Bull.targetPrice := risk > 0 ? entry + needed : na

    // Line drawing now happens centrally in repositionLineLabels() alongside the labels.
    t3Bull.complete := t3Bull.levelOK and t3Bull.rrOK and sessionOK and (not requireSMT or not useSMT or t3Bull.smtFlag)
    t3Bull.justCompleted := t3Bull.complete
    if risk > 0 and t3Bull.complete
        t3Bull.tradeLive    := true
        t3Bull.liveEntry    := entry
        t3Bull.liveStop     := stop
        t3Bull.liveTarget   := t3Bull.targetPrice
        t3Bull.liveEntryBar := bar_index
        t3Bull.liveEntryTime := time
    label.delete(t3Bull.completeLabel)
    label.delete(t3Bull.takeLabel)
    if t3Bull.complete
        t3Bull.takeLabel := label.new(bar_index, gapHigh, "▲ TAKE LONG ENTRY (IFVG retest)", style=label.style_label_down, color=color.lime, textcolor=color.black, size=size.large)
    t3Bull.pending := false

if gateT3Bear and t3Bear.pending and t3Bear.cisdDone and not t3Bear.fvgFound and bearIFVGRetest
    gapHigh = lastBullFVGTop
    gapLow  = lastBullFVGBot
    eq      = na(t3Bear.rangeOpp) ? na : (t3Bear.sweepLevel + t3Bear.rangeOpp) / 2
    midFVG  = (gapHigh + gapLow) / 2
    t3Bear.levelOK  := not na(eq) and midFVG > eq
    t3Bear.fvgFound := true
    t3Bear.usedIFVG := true

    entry  = gapLow
    stop   = t3Bear.sweepLevel
    risk   = stop - entry
    needed = risk * minRR
    roomToOpposing = na(t3Bear.rangeOpp) ? na : entry - t3Bear.rangeOpp
    t3Bear.entryPrice := entry
    t3Bear.rrOK := not na(roomToOpposing) and risk > 0 and roomToOpposing >= needed
    t3Bear.targetPrice := risk > 0 ? entry - needed : na

    // Line drawing now happens centrally in repositionLineLabels() alongside the labels.
    t3Bear.complete := t3Bear.levelOK and t3Bear.rrOK and sessionOK and (not requireSMT or not useSMT or t3Bear.smtFlag)
    t3Bear.justCompleted := t3Bear.complete
    if risk > 0 and t3Bear.complete
        t3Bear.tradeLive    := true
        t3Bear.liveEntry    := entry
        t3Bear.liveStop     := stop
        t3Bear.liveTarget   := t3Bear.targetPrice
        t3Bear.liveEntryBar := bar_index
        t3Bear.liveEntryTime := time
    label.delete(t3Bear.completeLabel)
    label.delete(t3Bear.takeLabel)
    if t3Bear.complete
        t3Bear.takeLabel := label.new(bar_index, gapLow, "▼ TAKE SHORT ENTRY (IFVG retest)", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.large)
    t3Bear.pending := false

// Same "only lock the gate on success, not on attempt" fix, applied here too since Tier 3 can complete
// via either the main engine above or the IFVG fallback just above — both set justCompleted the same way.
// When Simple Mode is driving Tier 3, also consume the Simple Mode sequence on success so a single failed
// Tier 3 attempt (bad R:R, no FVG, etc.) doesn't burn it — a fresh Shift (or a later Shift after a new
// sweep) can still re-arm it, mirroring the cascade's own "consume only on success" fix.
if t3Bull.justCompleted
    t3Bull.consumedParentBar := t2Bull.sweepBar
    if useSimpleMode
        simpleBull.consumedBar := simpleBull.smtBar
    // alert() fires immediately, right here, right now — unlike alertcondition() below, it does not depend
    // on justCompleted still reading true later when the bar actually closes. justCompleted is a one-tick
    // pulse: it gets reset to false at the top of every recalculation and is only true again if the
    // completion condition re-fires on that exact tick. A fast candle that satisfies the retest AND blows
    // through target within its own formation can flip justCompleted back to false before that bar's final
    // close-triggered recalculation, which is exactly what alertcondition() would see if an alert is set to
    // trigger "Once Per Bar Close" — the alert silently never fires even though the signal clearly happened.
    // alert() sidesteps this because it's an action taken in the moment, not a series read after the fact.
    alert("LONG ENTRY CONFIRMED — Entry " + str.tostring(t3Bull.liveEntry, format.mintick) + "  SL " + str.tostring(t3Bull.liveStop, format.mintick) + "  TP " + str.tostring(t3Bull.liveTarget, format.mintick), alert.freq_once_per_bar)
if t3Bear.justCompleted
    t3Bear.consumedParentBar := t2Bear.sweepBar
    if useSimpleMode
        simpleBear.consumedBar := simpleBear.smtBar
    alert("SHORT ENTRY CONFIRMED — Entry " + str.tostring(t3Bear.liveEntry, format.mintick) + "  SL " + str.tostring(t3Bear.liveStop, format.mintick) + "  TP " + str.tostring(t3Bear.liveTarget, format.mintick), alert.freq_once_per_bar)

repositionLineLabels(t1Bull, true, showTier12Marks)
repositionLineLabels(t1Bear, false, showTier12Marks)
repositionLineLabels(t2Bull, true, showTier12Marks)
repositionLineLabels(t2Bear, false, showTier12Marks)
repositionLineLabels(t3Bull, true, true)
repositionLineLabels(t3Bear, false, true)

checkTradeOutcome(t1Bull, true, "T1 HTF", showTier12Marks)
checkTradeOutcome(t1Bear, false, "T1 HTF", showTier12Marks)
checkTradeOutcome(t2Bull, true, "T2 MID", showTier12Marks)
checkTradeOutcome(t2Bear, false, "T2 MID", showTier12Marks)
checkTradeOutcome(t3Bull, true, "ENTRY", true)
checkTradeOutcome(t3Bear, false, "ENTRY", true)

// Panel only needs to reflect the final, current state, so this only runs on the last bar rather than
// rebuilding the table on every historical bar.
if barstate.islast
    updateTradePanel()

// ============================== ALERTS ==============================
// These two named conditions are kept for convenience (they show up as "Take Long"/"Take Short" in the
// Create Alert dropdown), but they are NOT the reliable delivery path — see the alert() calls above for why.
// When creating an alert on this script, choose "Any alert() function call" instead of these named
// conditions if you need every signal to actually notify you, especially on fast-moving 1-minute charts.
alertcondition(t3Bull.justCompleted, title="TAKE LONG — Entry Confirmed", message="Liquidity Sweep Cascade: HTF + Mid + Entry tiers confirmed. If retest confirmation is on, the FVG retest just held — take the long now (see Entry/SL/TP lines and the TAKE label).")
alertcondition(t3Bear.justCompleted, title="TAKE SHORT — Entry Confirmed", message="Liquidity Sweep Cascade: HTF + Mid + Entry tiers confirmed. If retest confirmation is on, the FVG retest just held — take the short now (see Entry/SL/TP lines and the TAKE label).")

// Tier 1 / Tier 2 individual-completion alerts, gated by the alertT1T2 toggle above (built into the
// condition itself since alertcondition() needs a plain boolean, not an if-block).
alertcondition(alertT1T2 and t1Bull.justCompleted, title="T1 HTF Long Confirmed", message="Liquidity Sweep Cascade: Tier 1 (HTF) long confirmed.")
alertcondition(alertT1T2 and t1Bear.justCompleted, title="T1 HTF Short Confirmed", message="Liquidity Sweep Cascade: Tier 1 (HTF) short confirmed.")
alertcondition(alertT1T2 and t2Bull.justCompleted, title="T2 MID Long Confirmed", message="Liquidity Sweep Cascade: Tier 2 (Mid) long confirmed.")
alertcondition(alertT1T2 and t2Bear.justCompleted, title="T2 MID Short Confirmed", message="Liquidity Sweep Cascade: Tier 2 (Mid) short confirmed.")

// ============================== CHECKLIST TABLE ==============================
mark(ok) => ok ? "✅" : "⬜"

var table checklist = table.new(tablePosition, 2, 19, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray, frame_width=1, frame_color=color.gray)

if showTable and barstate.islast
    useBull = na(t1Bear.sweepBar) or (not na(t1Bull.sweepBar) and t1Bull.sweepBar >= t1Bear.sweepBar)
    dirLabel = dataNotReady ? "Waiting for HTF/Mid data" : (na(t1Bull.sweepBar) and na(t1Bear.sweepBar) ? "No setup yet" : (useBull ? "Bullish" : "Bearish"))
    headerColor = dataNotReady ? color.new(color.orange, 30) : (useBull ? color.new(color.teal, 30) : color.new(color.red, 30))
    dividerBg = color.new(color.gray, 60)

    t1 = useBull ? t1Bull : t1Bear
    t2 = useBull ? t2Bull : t2Bear
    t3 = useBull ? t3Bull : t3Bear

    table.cell(checklist, 0, 0, "Liquidity Sweep Cascade — " + dirLabel, text_color=color.white, bgcolor=headerColor, text_halign=text.align_left)
    table.cell(checklist, 1, 0, "", bgcolor=headerColor)

    table.cell(checklist, 0, 1, "TIER 1 — HTF Context", text_color=color.silver, bgcolor=dividerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(checklist, 1, 1, "", bgcolor=dividerBg)
    table.cell(checklist, 0, 2, "HTF Sweep + POI", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 2, mark(not na(t1.sweepBar)), text_color=color.white)
    table.cell(checklist, 0, 3, "HTF FVG (imbalance zone)", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 3, mark(t1.fvgFound and t1.levelOK), text_color=color.white)
    table.cell(checklist, 0, 4, "HTF Good R:R (Entry/TP/SL)", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 4, showEntryT1T2 ? mark(t1.rrOK) : "off", text_color=color.white)

    table.cell(checklist, 0, 5, "TIER 2 — Mid Structure (" + midTF + ")", text_color=color.silver, bgcolor=dividerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(checklist, 1, 5, "", bgcolor=dividerBg)
    table.cell(checklist, 0, 6, "Mid Sweep (in Kill Zone)", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 6, mark(not na(t2.sweepBar)), text_color=color.white)
    table.cell(checklist, 0, 7, "Mid CISD", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 7, mark(t2.cisdDone), text_color=color.white)
    table.cell(checklist, 0, 8, "Mid FVG / OB", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 8, mark(t2.fvgFound and t2.levelOK), text_color=color.white)
    table.cell(checklist, 0, 9, "Mid Good R:R (Entry/TP/SL)", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 9, showEntryT1T2 ? mark(t2.rrOK) : "off", text_color=color.white)

    table.cell(checklist, 0, 10, "TIER 3 — Entry (this chart)", text_color=color.silver, bgcolor=dividerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(checklist, 1, 10, "", bgcolor=dividerBg)
    table.cell(checklist, 0, 11, "Entry Sweep", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 11, mark(not na(t3.sweepBar)), text_color=color.white)
    table.cell(checklist, 0, 12, "Entry CISD", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 12, mark(t3.cisdDone), text_color=color.white)
    table.cell(checklist, 0, 13, t3.usedIFVG ? "Entry IFVG (retest)" : "Entry FVG", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 13, mark(t3.fvgFound and t3.levelOK), text_color=color.white)
    table.cell(checklist, 0, 14, requireRetestForEntry ? "Entry Retest + R:R (take it)" : "Entry Good Risk to Reward", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 14, mark(t3.rrOK), text_color=color.white)

    table.cell(checklist, 0, 15, "— Confluence —", text_color=color.silver, bgcolor=dividerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(checklist, 1, 15, "", bgcolor=dividerBg)
    table.cell(checklist, 0, 16, "In Kill Zone (now)", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 16, mark(sessionOK), text_color=color.white)
    table.cell(checklist, 0, 17, "SMT Divergence", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 17, useSMT ? mark(t3.smtFlag) : "off", text_color=color.white)
    table.cell(checklist, 0, 18, "HTF Bias", text_color=color.white, text_halign=text.align_left)
    table.cell(checklist, 1, 18, showBias ? htfBias : "hidden", text_color=color.white)

var label dataNotReadyLabel = na
if dataNotReady and barstate.islast
    label.delete(dataNotReadyLabel)
    dataNotReadyLabel := label.new(bar_index, high, "Cascade: waiting for HTF/Mid history\n(need ~" + str.tostring(swingLen * 2 + 1) + "+ confirmed " + htf + " bars and ~" + str.tostring(midSwingLen * 2 + 1) + "+ confirmed " + midTF + " bars)", style=label.style_label_down, color=color.new(color.orange, 20), textcolor=color.black, size=size.normal)
````
