# Institutional 7-Point Checklist

- url: https://www.tradingview.com/script/kjEr6l5b-Institutional-7-Point-Checklist/
- type: indicator
- pine_id: PUB;4056237f4da74102acfdf1ba0ffc9384
- version: 2.0

## Description

█  INSTITUTIONAL 7-POINT PRE-TRADE CHECKLIST  v2.0  █
█  Pine Script® v6                                  █

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OBJECTIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most retail traders show up at 9:30 AM with no plan. They react to 5-minute noise and get chopped to pieces. This indicator solves that.

It runs a 7-point institutional checklist automatically — pulling data from the 4H, 1H, and daily timeframes — and displays a real-time pass/fail panel directly on your chart. Before you take a single trade, the panel tells you whether TODAY is even a trading day, what direction to expect, where to enter, and what to target.

The framework combines two proven concepts:
  ▸ 4H Chart Analysis — reading institutional expansion vs consolidation for structural bias
  ▸ Session Profiling — checking whether Asia or London reversed to classify New York as continuation or reversal

v2.0 adds the layers that give you complete market context without switching timeframes:
  ▸ Multi-timeframe liquidity mapping (Daily, Weekly, Monthly highs/lows)
  ▸ Anchored VWAP (Daily, Weekly, Monthly) for institutional cost basis
  ▸ Smart moving averages at the periods that actually matter per timeframe
  ▸ Midnight Open reference line
  ▸ Smart nearest-liquidity detection across all tiers

Everything new is an optional toggle. The default view stays clean — just the checklist, PDH/PDL, Daily VWAP, and the 4H 20 EMA. Power users turn on the layers they want.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE 7 CHECKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 1. Is the 4H expanding?
Evaluates the last three completed 4H candles. "Expanding" means ≥2 candles have bodies larger than the expansion multiplier × ATR(20), AND the most recent candle has small wicks relative to its range. If the 4H is consolidating → no trade today.

✅ 2. Did the prior session reverse or consolidate?
Tracks Asia (6 PM – 2 AM ET) and London (2 AM – 5 AM ET) in real time. A session "reversed" if it swept a key level and closed back through it. "Consolidated" if its range was under 40% of the daily ATR.

✅ 3. Continuation or reversal day?
  ▸ Any prior session reversed → NY = CONTINUATION
  ▸ No session reversed → NY = REVERSAL

✅ 4. Nearest FVG (entry zone)
Scans the 1H for 3-candle Fair Value Gaps — unfilled imbalances from aggressive expansion. Identifies the nearest bullish or bearish FVG with its midpoint price. This is your entry zone.

✅ 5. Nearest external liquidity (target) — NEW: SMART MULTI-TF
Now scans across Daily, Weekly, and Monthly levels (whichever are enabled) and automatically identifies the closest liquidity pool above and below price. The panel shows the tier label (PDH, PWH, PMH, etc.) so you know which level matters most right now. Bigger pools = stronger magnets.

✅ 6. Has price swept external liquidity? (trigger) — NEW: ANY TIER
Monitors sweeps across all enabled tiers. If price takes out PWH while PDH hasn't been swept, that still counts — any tier sweep is a valid trigger. The panel lists exactly which levels have been swept today.

✅ 7. One-sentence bias (auto-generated)
Combines all findings into a single actionable statement:
"4H expanding bearish. NY=CONTINUATION. Pullback into FVG → target PDL."

NEW: CONTEXT ROW
Below the 7 checks, a context line shows price position relative to Daily VWAP and 4H 20 EMA. Example: "above VWAP | above 4H EMA" — a quick confluence check without reading the chart.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEW IN v2.0: LIQUIDITY HIERARCHY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Not all liquidity is equal. A daily level might produce a 10-point displacement on NQ. A weekly level might produce 50 points. A monthly level could fuel a full trend day.

▸ Previous Day H/L (PDH/PDL) — ON by default
  Yesterday's range extremes. Stop losses from day traders. Blue dashed lines.

▸ Previous Week H/L (PWH/PWL) — OFF by default
  Swing trader stops. Much larger pool than daily. Purple dashed lines.

▸ Previous Month H/L (PMH/PML) — OFF by default
  Institutional swing and fund allocation levels. Orange solid lines (thicker for visual hierarchy).

▸ Midnight Open — OFF by default
  Price at 00:00 ET. Directional separator for ICT-style analysis. Gray dotted line. Above midnight open = bullish lean, below = bearish lean.

Each tier has its own color and line weight so you can glance at the chart and instantly see which pool price is approaching. The smart detection in Checks 5 and 6 automatically picks the nearest level regardless of tier.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEW IN v2.0: ANCHORED VWAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VWAP shows where the majority of institutional money actually transacted. It's not just an average — it's the volume-weighted cost basis.

▸ Daily VWAP — ON by default (amber)
  Anchored to today's open. The single most referenced level by institutional algorithms during NY session. When price is above VWAP, institutions are in profit and likely to defend it. Below = underwater.

▸ Weekly VWAP — OFF by default (purple)
  Anchored to Monday's open. Broader lens on net bullish/bearish flow for the week. Confirms your 4H bias: if 4H is expanding bullish AND price is above weekly VWAP = confluence.

▸ Monthly VWAP — OFF by default (orange)
  Background context. Rarely comes into play intraday, but when price tests monthly VWAP at a weekly liquidity level = high-conviction zone.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEW IN v2.0: MOVING AVERAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each MA is chosen for a specific purpose at its timeframe. No filler MAs — every line earns its place on the chart.

▸ 5-MIN 9/21 EMA — execution pair — OFF by default (cyan / indigo)
  After your sweep + displacement, the 5m 9 EMA crossing above/below the 21 EMA confirms micro order-flow shift. The gap between them acts as a dynamic FVG — separation = imbalance, convergence = equilibrium.

  WHY 9 AND 21: The 9 EMA covers roughly 45 minutes — one micro session. The 21 EMA covers ~105 minutes — the 9:30–11:00 kill zone. Together they capture the rhythm of institutional execution.

▸ 1H 9/21 EMA — intraday pulse — OFF by default (cyan / indigo, stepline)
  The 9 EMA represents one full trading session (~6.5 hours). If price rides the 1H 9 EMA during expansion = clean momentum. The 21 EMA covers about two trading days — the intraday trend anchor. Price whipping above/below the 1H 9 EMA = chop warning.

  WHY 9 AND 21: On the 1H, 9 periods = one session's worth of candles. 21 periods ≈ two full sessions. These match the session profiling logic in Check 2 — you're seeing the same structure as numbers.

▸ 4H 20 EMA — swing direction — ON by default (green, stepline, thick)
  This is the primary MA. It represents roughly one trading week. Institutional swing traders watch the 4H 20 EMA for pullback entries. When your expansion candles are pushing away from this level = strong momentum. When they're drifting back = fading expansion.

  WHY 20: On the 4H chart, 20 periods = ~3.3 trading days. This captures the core weekly rhythm — the period where institutional swing positions are managed.

▸ DAILY 20 EMA — monthly trend — OFF by default (yellow, stepline)
  Roughly one month of trading days. If price is above the D 20 EMA, the intermediate trend supports your intraday bias. Below it, your bullish setups have headwind.

  WHY 20: 20 trading days ≈ 1 calendar month. This is the standard period institutional portfolio managers use for intermediate trend assessment.

▸ DAILY 50 SMA — quarterly trend — OFF by default (orange, stepline)
  About 2.5 months of data. When the D 20 EMA is above the D 50 SMA = healthy trend. When they converge or cross = transition zone where 4H consolidation becomes more common. Background context, not a trade trigger.

  WHY 50: 50 trading days ≈ one quarter. Fund managers and institutional desks use this as the boundary between "trending" and "mean-reverting."

IMPORTANT: Higher-timeframe MAs projected onto a 5-min chart appear as staircase lines (stepline style). This is correct — the staircase shows you exactly where the value was when the higher timeframe last printed. It's not a bug; it's a feature.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT APPEARS ON YOUR CHART
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DEFAULT VIEW (clean — what loads when you first add the indicator):
  ▸ Checklist panel with all 7 checks + context row
  ▸ PDH/PDL liquidity lines (blue dashed)
  ▸ FVG zone (green or red shaded box)
  ▸ Daily VWAP (amber line)
  ▸ 4H 20 EMA (green stepline)
  ▸ Summary badge: TRADE READY / WAIT FOR SETUP / NO TRADE TODAY

OPTIONAL LAYERS (toggle on in settings):
  ▸ PWH/PWL (purple dashed)
  ▸ PMH/PML (orange solid, thicker)
  ▸ Midnight Open (gray dotted)
  ▸ Weekly VWAP (purple line)
  ▸ Monthly VWAP (orange line)
  ▸ 5m 9/21 EMA pair (cyan/indigo)
  ▸ 1H 9/21 EMA pair (cyan/indigo stepline)
  ▸ D 20 EMA (yellow stepline)
  ▸ D 50 SMA (orange stepline)
  ▸ Price labels on all level lines

All colors are fully customizable in settings.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FULL PROPERTIES / SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THRESHOLDS:
  ▸ Expansion multiplier (1.5) — body must exceed this × ATR(20). Raise for volatile instruments, lower for quieter ones.
  ▸ Max wick-to-range ratio (0.35) — candle must be cleaner than this threshold to count as expansion.
  ▸ 4H candles to evaluate (4) — how many candles the script considers for expansion profiling.

SESSIONS:
  ▸ Asia session (1800–0200) — overnight accumulation window
  ▸ London session (0200–0500) — primary reversal window
  ▸ New York session (0930–1600) — execution window
  ▸ Timezone (America/New_York) — also supports America/Chicago, Europe/London, Asia/Tokyo, UTC

LIQUIDITY LEVELS:
  ▸ Previous Day H/L (on) — blue dashed, width 2
  ▸ Previous Week H/L (off) — purple dashed, width 2
  ▸ Previous Month H/L (off) — orange solid, width 3
  ▸ Midnight Open (off) — gray dotted, width 1
  ▸ All colors are customizable per tier

ANCHORED VWAP:
  ▸ Daily VWAP (on) — amber, width 2
  ▸ Weekly VWAP (off) — purple, width 2
  ▸ Monthly VWAP (off) — orange, width 1

MOVING AVERAGES:
  ▸ 5m 9/21 EMA (off) — cyan fast / indigo slow
  ▸ 1H 9/21 EMA (off) — cyan fast / indigo slow, stepline
  ▸ 4H 20 EMA (on) — green, stepline, thick
  ▸ D 20 EMA (off) — yellow, stepline
  ▸ D 50 SMA (off) — orange, stepline
  ▸ All colors customizable

FAIR VALUE GAP:
  ▸ Plot FVGs on chart (on) — green box = bullish, red box = bearish

DISPLAY:
  ▸ Show checklist panel (on)
  ▸ Panel position (top_right) — 6 positions available
  ▸ Panel text size (small) — tiny / small / normal / large / huge
  ▸ Header/summary text size (normal) — controls title and badge
  ▸ Show price labels on levels (on) — small tags at the right edge of each line


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE — STEP BY STEP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETUP:
  1. Add to a 5-minute chart (NQ, ES, or your instrument)
  2. The panel auto-populates from 4H, 1H, and daily data — no timeframe switching needed
  3. Toggle on additional layers as desired in settings

MORNING ROUTINE:

  6:00 AM — Open chart. Panel shows:
    ▸ Check 1: 4H expanding? If ❌ → no trade today, done
    ▸ Check 2: What did Asia and London do?
    ▸ Check 3: Continuation or reversal day?
    ▸ Context: Price vs VWAP and 4H EMA alignment

  6:15 AM — Read auto-generated bias (Check 7). Write it down.

  9:15 AM — Panel updates:
    ▸ Check 4: FVG present? Zone is shaded on chart
    ▸ Check 5: Nearest liquidity above/below with tier labels

  9:30 AM — Watch for Check 6 to flip green (sweep at any tier)

  TRADE READY (all checks green):
    ▸ Drop to 5-min for timing
    ▸ Wait for displacement + CISD in your bias direction
    ▸ Use 5m 9/21 EMA cross as micro-confirmation (if enabled)
    ▸ Enter after confirmation
    ▸ Stop above/below the sweep
    ▸ Target the opposite liquidity pool

  10:30 AM — In profit, stopped out, or no setup. Done for the day.

KEY RULES:
  ▸ Check 1 is ❌ → close the laptop
  ▸ Can't write bias in one sentence → no trade
  ▸ 0–2 trades per day max
  ▸ The indicator identifies CONDITIONS, not entries. Final execution is yours.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED SETUPS BY STYLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MINIMALIST (learning the framework):
  ON: Checklist panel, PDH/PDL, FVG, Daily VWAP, 4H 20 EMA
  OFF: Everything else
  → Clean chart, just the essentials. Master the 7 checks first.

INTERMEDIATE (adding confluence):
  ADD: PWH/PWL, Midnight Open, 5m 9/21 EMA pair
  → Weekly liquidity for bigger targets, midnight open for directional lean, execution MAs for timing entries.

FULL CONTEXT (experienced trader):
  ADD: PMH/PML, Weekly VWAP, 1H 9/21 EMA, D 20 EMA, D 50 SMA
  → Complete institutional map. Every level you might need is on one chart. Use price labels (on) to read values at a glance.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Three built-in alert conditions:

  ▸ "4H began expanding" — morning wake-up call: today is potentially a trade day
  ▸ "External liquidity swept" — fires on the first sweep of ANY enabled tier (PDH, PWH, PMH, etc.)
  ▸ "ALL CHECKS PASSED" — all 7 conditions met. Eyes on chart — setup is live.

Set via: right-click chart → Add alert → select indicator → choose condition


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MA PERIOD RATIONALE — WHY THESE NUMBERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Every period was chosen to align with a real institutional time horizon:

  5m 9 EMA   = ~45 min  = one micro-session (the opening drive)
  5m 21 EMA  = ~105 min = the 9:30–11:00 AM kill zone window
  1H 9 EMA   = ~1.4 days = one full trading session
  1H 21 EMA  = ~3.2 days = two full sessions (matches session profiling)
  4H 20 EMA  = ~3.3 days = one trading week's core rhythm
  D 20 EMA   = ~1 month  = intermediate trend (monthly portfolio reviews)
  D 50 SMA   = ~2.5 months = quarterly trend (fund allocation cycles)

The 4H 20 EMA is ON by default because it's the single most useful MA for this framework — it directly represents the timeframe the entire strategy is built on.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UNDERLYING ALGORITHM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The entire framework rests on one cycle:

  External liquidity → Internal liquidity → External liquidity
  (Sweep stops) → (Fill the FVG) → (Target opposite stops)

  ▸ The 4H chart tells you the DIRECTION
  ▸ The session profile tells you the TIMING
  ▸ The VWAP tells you the INSTITUTIONAL COST BASIS
  ▸ The MAs tell you whether STRUCTURE supports your bias
  ▸ The 5-minute chart is for EXECUTION ONLY

You read the book from chapter 1, not from the last page.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TUNING TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"Check 1 always red" — lower expansion multiplier to 1.2 or 1.0. Different instruments have different volatility profiles.

"FVG never shows" — there's no unfilled 1H gap right now. Wait for the next expansion candle.

"Session labels wrong" — set the Timezone dropdown to match your chart's exchange timezone.

"VWAP looks flat" — if your instrument has no volume data (some forex/CFD feeds), VWAP defaults to HLC3. Switch to a data feed that provides volume, or disable VWAP.

"Too many lines on chart" — start with the Minimalist setup (see Recommended Setups). Only toggle on new layers after you've used the basic setup for at least a week.

"4H EMA appears as staircase" — this is correct. Higher-timeframe data on a lower-timeframe chart updates in steps. The staircase shows you the exact value at the last 4H close.

"Panel covers price" — change panel position to a different corner, or reduce text size.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIMEFRAMES & INSTRUMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Designed for: 5-minute chart (execution timeframe)
Internally references: 4H (bias), 1H (FVG), Daily/Weekly/Monthly (liquidity + MAs)
Works on: Futures (NQ, ES, YM, RTY), Forex, Crypto, Equities
Best suited for: Intraday traders with a 9:30–11:00 AM ET window


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY PINE SCRIPT v6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is written in Pine Script v6 — the latest version of TradingView's language (released Nov 2024). Benefits over v5:

▸ Strict boolean logic — booleans are always true or false, never na. Eliminates an entire class of edge-case bugs in complex conditions like the multi-check panel.

▸ Short-circuit evaluation — and/or operations stop evaluating the moment the result is determined. Significant performance improvement for scripts with many compound conditions (which this checklist uses heavily).

▸ Future-proof — all new TradingView features going forward are v6 exclusive. Dynamic requests, footprint data, enhanced arrays, and upcoming additions will only work on v6.

▸ Cleaner integer division — 5/2 now correctly returns 2.5 instead of 2. Important for any ratio calculations (expansion multiplier, wick ratios).

If you're migrating from the v1 script (which was v5), the logic is identical — v6 just makes it faster and more reliable.

x.com/tsmake
Developed after reading: https://x.com/L2WTrades/status/2045828490780373189?s=20


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is an EDUCATIONAL TOOL designed to enforce trading discipline. It does NOT generate buy/sell signals, does NOT constitute financial advice, and does NOT guarantee profitability. The checklist identifies structural conditions — the final entry decision, risk management, and position sizing are entirely your responsibility.

Trading futures, equities, options, forex, and crypto carries significant risk of loss. Past performance does not guarantee future results. Backtest thoroughly, start with a simulator, and never risk capital you cannot afford to lose. Consult a licensed financial advisor before making trading decisions.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TAGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ICT, Smart Money, Liquidity, Fair Value Gap, FVG, Session Profile, VWAP, PDH, PDL, PWH, PWL, PMH, PML, Institutional, Checklist, Pre-Market, Bias, External Liquidity, Internal Liquidity, Moving Average, 4H, NQ, ES, Futures, Forex

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════
//  INSTITUTIONAL 7-POINT PRE-TRADE CHECKLIST  v2.0  (Pine Script v6)
// ══════════════════════════════════════════════════════════════════════════
//
//  OBJECTIVE:
//  Automates the institutional morning checklist so you never show up at
//  9:30 blind. Pulls 4H, 1H, and daily data onto a 5-minute chart and
//  displays a real-time pass/fail panel for 7 conditions that must all
//  be met before you look for an entry.
//
//  v2.0 ADDITIONS:
//    ▸ Multi-timeframe liquidity: PDH/L, PWH/L, PMH/L (all toggleable)
//    ▸ Smart nearest-liquidity detection for Checks 5 & 6
//    ▸ Anchored VWAP: Daily (on), Weekly (off), Monthly (off)
//    ▸ Moving averages: 4H 20 EMA, 1H 9/21 EMA, 5m 9/21 EMA, D 50 SMA
//    ▸ Midnight Open reference line
//    ▸ All new layers are optional toggles — clean chart by default
//
//  THE 7 CHECKS:
//    1. Is the 4H expanding? (institutional intent vs accumulation)
//    2. Did the prior session (Asia/London) reverse or consolidate?
//    3. Is today a CONTINUATION or REVERSAL day for New York?
//    4. Where is the nearest 1H Fair Value Gap? (entry zone)
//    5. Where is nearest external liquidity? (target — smart multi-TF)
//    6. Has price swept external liquidity? (trigger — any tier)
//    7. Auto-generated one-sentence bias summary
//
//  CORE ALGORITHM:
//    External liquidity → Internal liquidity → External liquidity
//    (Sweep stops → Fill the FVG → Target opposite stops)
//
//  EDUCATIONAL USE ONLY. NOT FINANCIAL ADVICE.
// ══════════════════════════════════════════════════════════════════════════

indicator("Institutional 7-Point Checklist v2", shorttitle="7PT-v2", overlay=true,
  max_boxes_count=100, max_lines_count=200, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

// ─── Thresholds ───
grp_t = "Thresholds"
expand_mult = input.float(1.5,  "Expansion multiplier (body vs ATR)", minval=0.5, maxval=5.0, step=0.1, group=grp_t, tooltip="4H candle body must exceed this × ATR(20) to count as expanding.")
wick_ratio  = input.float(0.35, "Max wick-to-range ratio", minval=0.1, maxval=0.9, step=0.05, group=grp_t, tooltip="Total wicks must be less than this fraction of range.")
lookback_4h = input.int(4,      "4H candles to evaluate", minval=2, maxval=10, group=grp_t)

// ─── Sessions ───
grp_s = "Sessions (exchange time)"
asia_sess   = input.session("1800-0200", "Asia session",     group=grp_s)
london_sess = input.session("0200-0500", "London session",   group=grp_s)
ny_sess     = input.session("0930-1600", "New York session",  group=grp_s)
sess_tz     = input.string("America/New_York", "Timezone", options=["America/New_York","America/Chicago","Europe/London","Asia/Tokyo","UTC"], group=grp_s)

// ─── Liquidity Levels ───
grp_liq = "Liquidity Levels"
show_pdhl  = input.bool(true,  "Previous Day H/L (PDH/PDL)",     group=grp_liq)
show_pwhl  = input.bool(false, "Previous Week H/L (PWH/PWL)",    group=grp_liq)
show_pmhl  = input.bool(false, "Previous Month H/L (PMH/PML)",   group=grp_liq)
show_midnt = input.bool(false, "Midnight Open",                   group=grp_liq, tooltip="Price at 00:00 ET — directional separator for ICT-style analysis.")
col_daily  = input.color(color.new(#2563eb, 0),  "Daily level color",   group=grp_liq)
col_weekly = input.color(color.new(#7c3aed, 0),  "Weekly level color",  group=grp_liq)
col_month  = input.color(color.new(#ea580c, 0),  "Monthly level color", group=grp_liq)
col_midnt  = input.color(color.new(#94a3b8, 0),  "Midnight Open color", group=grp_liq)

// ─── VWAP ───
grp_vw = "Anchored VWAP"
show_dvwap = input.bool(true,  "Daily VWAP",   group=grp_vw, tooltip="Volume-weighted average anchored to today's open — institutional cost basis.")
show_wvwap = input.bool(false, "Weekly VWAP",  group=grp_vw, tooltip="Anchored to Monday's open — broader institutional flow direction.")
show_mvwap = input.bool(false, "Monthly VWAP", group=grp_vw, tooltip="Anchored to first of the month — background context level.")
col_dvwap  = input.color(color.new(#f59e0b, 0),  "Daily VWAP color",   group=grp_vw)
col_wvwap  = input.color(color.new(#a855f7, 0),  "Weekly VWAP color",  group=grp_vw)
col_mvwap  = input.color(color.new(#f97316, 0),  "Monthly VWAP color", group=grp_vw)

// ─── Moving Averages ───
grp_ma = "Moving Averages"
show_ma_5m  = input.bool(false, "5m 9/21 EMA (execution pair)",    group=grp_ma, tooltip="Fast execution MAs on your chart timeframe. 9 EMA crossing 21 EMA confirms micro order-flow shift.")
show_ma_1h  = input.bool(false, "1H 9/21 EMA (intraday pulse)",    group=grp_ma, tooltip="9 EMA = one session pulse, 21 EMA = two-day trend anchor.")
show_ma_4h  = input.bool(true,  "4H 20 EMA (swing direction)",     group=grp_ma, tooltip="Key level: institutional swing traders watch 4H 20 EMA for pullback entries.")
show_ma_d50 = input.bool(false, "D 50 SMA (quarterly trend)",      group=grp_ma, tooltip="~2.5 months of data. Healthy trend = price above this level.")
show_ma_d20 = input.bool(false, "D 20 EMA (monthly trend)",        group=grp_ma, tooltip="~1 month of data. Intermediate trend filter.")
col_ma_fast = input.color(color.new(#22d3ee, 0), "Fast MA color (9 EMA)",    group=grp_ma)
col_ma_slow = input.color(color.new(#818cf8, 0), "Slow MA color (21 EMA)",   group=grp_ma)
col_ma_4h   = input.color(color.new(#4ade80, 0), "4H 20 EMA color",         group=grp_ma)
col_ma_d20  = input.color(color.new(#facc15, 0), "D 20 EMA color",          group=grp_ma)
col_ma_d50  = input.color(color.new(#fb923c, 0), "D 50 SMA color",          group=grp_ma)

// ─── FVG ───
grp_fvg = "Fair Value Gap"
show_fvg = input.bool(true, "Plot FVGs on chart", group=grp_fvg)

// ─── Display ───
grp_d = "Display"
show_panel   = input.bool(true, "Show checklist panel", group=grp_d)
panel_pos    = input.string("top_right", "Panel position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=grp_d)
text_sz_in   = input.string("small",  "Panel text size",  options=["tiny","small","normal","large","huge"], group=grp_d, tooltip="Increase for large or high-res screens.")
header_sz_in = input.string("normal", "Header / summary text size", options=["tiny","small","normal","large","huge"], group=grp_d, tooltip="Title and TRADE READY badge size.")
show_labels  = input.bool(true, "Show price labels on levels", group=grp_d, tooltip="Small price tags at the right edge of each liquidity/VWAP/MA line.")

// ═══════════════════════════════════════════════════════════════════
// HIGHER TIMEFRAME DATA
// ═══════════════════════════════════════════════════════════════════

// ─── 4H candle data ───
h4_open  = request.security(syminfo.tickerid, "240", open [1], lookahead=barmerge.lookahead_off)
h4_high  = request.security(syminfo.tickerid, "240", high [1], lookahead=barmerge.lookahead_off)
h4_low   = request.security(syminfo.tickerid, "240", low  [1], lookahead=barmerge.lookahead_off)
h4_close = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_off)
h4_atr   = request.security(syminfo.tickerid, "240", ta.atr(20)[1], lookahead=barmerge.lookahead_off)

h4_c1_body  = request.security(syminfo.tickerid, "240", math.abs(close[1] - open[1]), lookahead=barmerge.lookahead_off)
h4_c2_body  = request.security(syminfo.tickerid, "240", math.abs(close[2] - open[2]), lookahead=barmerge.lookahead_off)
h4_c3_body  = request.security(syminfo.tickerid, "240", math.abs(close[3] - open[3]), lookahead=barmerge.lookahead_off)
h4_c1_range = request.security(syminfo.tickerid, "240", (high[1] - low[1]), lookahead=barmerge.lookahead_off)

// ─── Daily liquidity ───
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low [1], lookahead=barmerge.lookahead_off)

// ─── Weekly liquidity ───
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low [1], lookahead=barmerge.lookahead_off)

// ─── Monthly liquidity ───
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_off)
pml = request.security(syminfo.tickerid, "M", low [1], lookahead=barmerge.lookahead_off)

// ─── Daily ATR for session profiling ───
daily_atr = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════
// MIDNIGHT OPEN
// ═══════════════════════════════════════════════════════════════════
var float midnight_open = na
is_midnight = hour == 0 and minute < math.max(1, timeframe.in_seconds() / 60)
if is_midnight and not is_midnight[1]
    midnight_open := open

// ═══════════════════════════════════════════════════════════════════
// VWAP CALCULATIONS
// ═══════════════════════════════════════════════════════════════════
// Daily VWAP
is_new_day = ta.change(time("D")) != 0
var float d_cum_vol  = 0.0
var float d_cum_pvol = 0.0
if is_new_day
    d_cum_vol  := volume
    d_cum_pvol := hlc3 * volume
else
    d_cum_vol  += volume
    d_cum_pvol += hlc3 * volume
d_vwap = d_cum_vol > 0 ? d_cum_pvol / d_cum_vol : hlc3

// Weekly VWAP
is_new_week = ta.change(time("W")) != 0
var float w_cum_vol  = 0.0
var float w_cum_pvol = 0.0
if is_new_week
    w_cum_vol  := volume
    w_cum_pvol := hlc3 * volume
else
    w_cum_vol  += volume
    w_cum_pvol += hlc3 * volume
w_vwap = w_cum_vol > 0 ? w_cum_pvol / w_cum_vol : hlc3

// Monthly VWAP
is_new_month = ta.change(time("M")) != 0
var float m_cum_vol  = 0.0
var float m_cum_pvol = 0.0
if is_new_month
    m_cum_vol  := volume
    m_cum_pvol := hlc3 * volume
else
    m_cum_vol  += volume
    m_cum_pvol += hlc3 * volume
m_vwap = m_cum_vol > 0 ? m_cum_pvol / m_cum_vol : hlc3

// ═══════════════════════════════════════════════════════════════════
// MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════════
// 5-min execution pair
ma_5m_9  = ta.ema(close, 9)
ma_5m_21 = ta.ema(close, 21)

// 1H EMAs (projected onto chart TF)
ma_1h_9  = request.security(syminfo.tickerid, "60", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
ma_1h_21 = request.security(syminfo.tickerid, "60", ta.ema(close, 21), lookahead=barmerge.lookahead_off)

// 4H 20 EMA (swing direction — primary MA)
ma_4h_20 = request.security(syminfo.tickerid, "240", ta.ema(close, 20), lookahead=barmerge.lookahead_off)

// Daily 20 EMA and 50 SMA
ma_d_20  = request.security(syminfo.tickerid, "D", ta.ema(close, 20),  lookahead=barmerge.lookahead_off)
ma_d_50  = request.security(syminfo.tickerid, "D", ta.sma(close, 50),  lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════
// CHECK 1: IS THE 4H EXPANDING?
// ═══════════════════════════════════════════════════════════════════
c1_ratio = h4_atr > 0 ? h4_c1_body / h4_atr : 0.0
c2_ratio = h4_atr > 0 ? h4_c2_body / h4_atr : 0.0
c3_ratio = h4_atr > 0 ? h4_c3_body / h4_atr : 0.0

expand_count = (c1_ratio >= expand_mult ? 1 : 0) + (c2_ratio >= expand_mult ? 1 : 0) + (c3_ratio >= expand_mult ? 1 : 0)
c1_wick = h4_c1_range > 0 ? (h4_c1_range - h4_c1_body) / h4_c1_range : 1.0
is_expanding = expand_count >= 2 and c1_wick <= (1 - wick_ratio)
expand_direction = h4_close > h4_open ? "bullish" : h4_close < h4_open ? "bearish" : "flat"

// ═══════════════════════════════════════════════════════════════════
// CHECK 2: PRIOR SESSION PROFILE
// ═══════════════════════════════════════════════════════════════════
in_asia   = not na(time(timeframe.period, asia_sess,   sess_tz))
in_london = not na(time(timeframe.period, london_sess, sess_tz))
in_ny     = not na(time(timeframe.period, ny_sess,     sess_tz))

var float asia_open   = na
var float asia_high   = na
var float asia_low    = na
var float asia_close  = na
var float london_open = na
var float london_high = na
var float london_low  = na
var float london_close= na

asia_start   = in_asia   and not in_asia[1]
asia_end     = not in_asia   and in_asia[1]
london_start = in_london and not in_london[1]
london_end   = not in_london and in_london[1]

if asia_start
    asia_open := open
    asia_high := high
    asia_low  := low
if in_asia
    asia_high := math.max(nz(asia_high, high), high)
    asia_low  := math.min(nz(asia_low,  low),  low)
if asia_end
    asia_close := close[1]

if london_start
    london_open := open
    london_high := high
    london_low  := low
if in_london
    london_high := math.max(nz(london_high, high), high)
    london_low  := math.min(nz(london_low,  low),  low)
if london_end
    london_close := close[1]

asia_reversed = false
if not na(asia_close) and not na(pdh) and not na(pdl)
    asia_reversed := (asia_high > pdh and asia_close < pdh) or (asia_low < pdl and asia_close > pdl)

london_reversed = false
london_dir = 0
if not na(london_close) and not na(asia_high) and not na(asia_low)
    bl = london_low < asia_low and london_close > asia_low
    br = london_high > asia_high and london_close < asia_high
    london_reversed := bl or br
    london_dir := bl ? 1 : br ? -1 : 0

asia_range_val   = nz(asia_high) - nz(asia_low)
london_range_val = nz(london_high) - nz(london_low)
asia_consolidated   = not na(daily_atr) and asia_range_val   < daily_atr * 0.4
london_consolidated = not na(daily_atr) and london_range_val < daily_atr * 0.4

// ═══════════════════════════════════════════════════════════════════
// CHECK 3: CONTINUATION OR REVERSAL?
// ═══════════════════════════════════════════════════════════════════
any_reversal = asia_reversed or london_reversed
day_type = any_reversal ? "CONTINUATION" : "REVERSAL"
day_direction = london_reversed ? (london_dir == 1 ? "bullish" : london_dir == -1 ? "bearish" : "undecided") : asia_reversed ? expand_direction : "undecided"

// ═══════════════════════════════════════════════════════════════════
// CHECK 4: NEAREST 1H FVG
// ═══════════════════════════════════════════════════════════════════
h1_h0 = request.security(syminfo.tickerid, "60", high[0], lookahead=barmerge.lookahead_off)
h1_l0 = request.security(syminfo.tickerid, "60", low[0],  lookahead=barmerge.lookahead_off)
h1_h2 = request.security(syminfo.tickerid, "60", high[2], lookahead=barmerge.lookahead_off)
h1_l2 = request.security(syminfo.tickerid, "60", low[2],  lookahead=barmerge.lookahead_off)

bull_fvg_top = h1_l2
bull_fvg_bot = h1_h0
has_bull_fvg = h1_l2 > h1_h0

bear_fvg_top = h1_l0
bear_fvg_bot = h1_h2
has_bear_fvg = h1_h2 < h1_l0

var float fvg_top = na
var float fvg_bot = na
var string fvg_type = ""

if has_bull_fvg and (na(fvg_top) or math.abs(close - (bull_fvg_top + bull_fvg_bot) / 2) < math.abs(close - (nz(fvg_top) + nz(fvg_bot)) / 2))
    fvg_top := bull_fvg_top
    fvg_bot := bull_fvg_bot
    fvg_type := "bullish"
if has_bear_fvg and (na(fvg_top) or math.abs(close - (bear_fvg_top + bear_fvg_bot) / 2) < math.abs(close - (nz(fvg_top) + nz(fvg_bot)) / 2))
    fvg_top := bear_fvg_top
    fvg_bot := bear_fvg_bot
    fvg_type := "bearish"

has_fvg = not na(fvg_top) and not na(fvg_bot)

// ═══════════════════════════════════════════════════════════════════
// CHECK 5: NEAREST EXTERNAL LIQUIDITY (SMART MULTI-TF)
// ═══════════════════════════════════════════════════════════════════
// Build arrays of levels above and below price with labels
// Find the nearest level above and below current price across all tiers

f_nearest(level, cur) =>
    not na(level) ? math.abs(level - cur) : 99999999.0

// Nearest ABOVE price
dist_pdh = close < pdh ? f_nearest(pdh, close) : 99999999.0
dist_pwh = close < pwh and show_pwhl ? f_nearest(pwh, close) : 99999999.0
dist_pmh = close < pmh and show_pmhl ? f_nearest(pmh, close) : 99999999.0

nearest_above_val = math.min(dist_pdh, math.min(dist_pwh, dist_pmh))
nearest_above_label = dist_pdh == nearest_above_val ? "PDH" : dist_pwh == nearest_above_val ? "PWH" : "PMH"
nearest_above_price = nearest_above_label == "PDH" ? pdh : nearest_above_label == "PWH" ? pwh : pmh

// Nearest BELOW price
dist_pdl = close > pdl ? f_nearest(pdl, close) : 99999999.0
dist_pwl = close > pwl and show_pwhl ? f_nearest(pwl, close) : 99999999.0
dist_pml = close > pml and show_pmhl ? f_nearest(pml, close) : 99999999.0

nearest_below_val = math.min(dist_pdl, math.min(dist_pwl, dist_pml))
nearest_below_label = dist_pdl == nearest_below_val ? "PDL" : dist_pwl == nearest_below_val ? "PWL" : "PML"
nearest_below_price = nearest_below_label == "PDL" ? pdl : nearest_below_label == "PWL" ? pwl : pml

has_liquidity = nearest_above_val < 99999999.0 or nearest_below_val < 99999999.0

// Target based on direction
target_label = day_direction == "bearish" ? nearest_below_label : day_direction == "bullish" ? nearest_above_label : "undecided"
target_price = day_direction == "bearish" ? nearest_below_price : day_direction == "bullish" ? nearest_above_price : na

// ═══════════════════════════════════════════════════════════════════
// CHECK 6: SWEEP DETECTION (ANY TIER)
// ═══════════════════════════════════════════════════════════════════
new_day_flag = dayofweek != dayofweek[1] or dayofmonth != dayofmonth[1]

var bool swept_pdh = false
var bool swept_pdl = false
var bool swept_pwh = false
var bool swept_pwl = false
var bool swept_pmh = false
var bool swept_pml = false

if new_day_flag
    swept_pdh := false
    swept_pdl := false
    swept_pwh := false
    swept_pwl := false
    swept_pmh := false
    swept_pml := false

if not na(pdh) and high > pdh
    swept_pdh := true
if not na(pdl) and low < pdl
    swept_pdl := true
if show_pwhl and not na(pwh) and high > pwh
    swept_pwh := true
if show_pwhl and not na(pwl) and low < pwl
    swept_pwl := true
if show_pmhl and not na(pmh) and high > pmh
    swept_pmh := true
if show_pmhl and not na(pml) and low < pml
    swept_pml := true

sweep_occurred = swept_pdh or swept_pdl or swept_pwh or swept_pwl or swept_pmh or swept_pml

// Build sweep description
sweep_parts = (swept_pdh ? "PDH " : "") + (swept_pdl ? "PDL " : "") + (swept_pwh ? "PWH " : "") + (swept_pwl ? "PWL " : "") + (swept_pmh ? "PMH " : "") + (swept_pml ? "PML " : "")
sweep_side = sweep_occurred ? sweep_parts : "no sweep yet"

// ═══════════════════════════════════════════════════════════════════
// CHECK 7: ONE-SENTENCE BIAS
// ═══════════════════════════════════════════════════════════════════
bias_sentence = ""
if is_expanding
    bias_sentence := "4H expanding " + expand_direction + ". NY=" + day_type + "."
    if day_type == "CONTINUATION"
        bias_sentence += " Pullback into FVG → target " + target_label + "."
    else
        bias_sentence += " Wait for sweep + displacement."
else
    bias_sentence := "4H consolidating. NO TRADE."

// ═══════════════════════════════════════════════════════════════════
// PLOT: LIQUIDITY LEVELS
// ═══════════════════════════════════════════════════════════════════
// Helper: delete and redraw a single level line + label
var line ln_pdh  = na
var line ln_pdl  = na
var line ln_pwh  = na
var line ln_pwl  = na
var line ln_pmh  = na
var line ln_pml  = na
var line ln_mid  = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na
var label lb_pmh = na
var label lb_pml = na
var label lb_mid = na

if barstate.islast
    // Clean up old drawings
    line.delete(ln_pdh)
    line.delete(ln_pdl)
    line.delete(ln_pwh)
    line.delete(ln_pwl)
    line.delete(ln_pmh)
    line.delete(ln_pml)
    line.delete(ln_mid)
    label.delete(lb_pdh)
    label.delete(lb_pdl)
    label.delete(lb_pwh)
    label.delete(lb_pwl)
    label.delete(lb_pmh)
    label.delete(lb_pml)
    label.delete(lb_mid)

    // PDH / PDL
    if show_pdhl and not na(pdh)
        ln_pdh := line.new(bar_index - 50, pdh, bar_index + 20, pdh, color=col_daily, style=line.style_dashed, width=2)
        if show_labels
            lb_pdh := label.new(bar_index + 22, pdh, "PDH " + str.tostring(math.round_to_mintick(pdh)), style=label.style_none, textcolor=col_daily, size=size.small)
    if show_pdhl and not na(pdl)
        ln_pdl := line.new(bar_index - 50, pdl, bar_index + 20, pdl, color=col_daily, style=line.style_dashed, width=2)
        if show_labels
            lb_pdl := label.new(bar_index + 22, pdl, "PDL " + str.tostring(math.round_to_mintick(pdl)), style=label.style_none, textcolor=col_daily, size=size.small)

    // PWH / PWL
    if show_pwhl and not na(pwh)
        ln_pwh := line.new(bar_index - 50, pwh, bar_index + 20, pwh, color=col_weekly, style=line.style_dashed, width=2)
        if show_labels
            lb_pwh := label.new(bar_index + 22, pwh, "PWH " + str.tostring(math.round_to_mintick(pwh)), style=label.style_none, textcolor=col_weekly, size=size.small)
    if show_pwhl and not na(pwl)
        ln_pwl := line.new(bar_index - 50, pwl, bar_index + 20, pwl, color=col_weekly, style=line.style_dashed, width=2)
        if show_labels
            lb_pwl := label.new(bar_index + 22, pwl, "PWL " + str.tostring(math.round_to_mintick(pwl)), style=label.style_none, textcolor=col_weekly, size=size.small)

    // PMH / PML
    if show_pmhl and not na(pmh)
        ln_pmh := line.new(bar_index - 50, pmh, bar_index + 20, pmh, color=col_month, style=line.style_solid, width=3)
        if show_labels
            lb_pmh := label.new(bar_index + 22, pmh, "PMH " + str.tostring(math.round_to_mintick(pmh)), style=label.style_none, textcolor=col_month, size=size.small)
    if show_pmhl and not na(pml)
        ln_pml := line.new(bar_index - 50, pml, bar_index + 20, pml, color=col_month, style=line.style_solid, width=3)
        if show_labels
            lb_pml := label.new(bar_index + 22, pml, "PML " + str.tostring(math.round_to_mintick(pml)), style=label.style_none, textcolor=col_month, size=size.small)

    // Midnight Open
    if show_midnt and not na(midnight_open)
        ln_mid := line.new(bar_index - 50, midnight_open, bar_index + 20, midnight_open, color=col_midnt, style=line.style_dotted, width=1)
        if show_labels
            lb_mid := label.new(bar_index + 22, midnight_open, "MID " + str.tostring(math.round_to_mintick(midnight_open)), style=label.style_none, textcolor=col_midnt, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// PLOT: FVG
// ═══════════════════════════════════════════════════════════════════
var box fvg_box = na
if show_fvg and has_fvg and barstate.islast
    if not na(fvg_box)
        box.delete(fvg_box)
    fvg_color = fvg_type == "bullish" ? color.new(color.green, 80) : color.new(color.red, 80)
    fvg_box := box.new(bar_index - 20, fvg_top, bar_index + 20, fvg_bot, bgcolor=fvg_color, border_color=fvg_color)

// ═══════════════════════════════════════════════════════════════════
// PLOT: VWAP
// ═══════════════════════════════════════════════════════════════════
plot(show_dvwap ? d_vwap : na, "Daily VWAP",   color=col_dvwap, linewidth=2, style=plot.style_line)
plot(show_wvwap ? w_vwap : na, "Weekly VWAP",  color=col_wvwap, linewidth=2, style=plot.style_line)
plot(show_mvwap ? m_vwap : na, "Monthly VWAP", color=col_mvwap, linewidth=1, style=plot.style_line)

// ═══════════════════════════════════════════════════════════════════
// PLOT: MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════════
plot(show_ma_5m  ? ma_5m_9  : na, "5m 9 EMA",   color=col_ma_fast, linewidth=1)
plot(show_ma_5m  ? ma_5m_21 : na, "5m 21 EMA",  color=col_ma_slow, linewidth=1)
plot(show_ma_1h  ? ma_1h_9  : na, "1H 9 EMA",   color=col_ma_fast, linewidth=2, style=plot.style_stepline)
plot(show_ma_1h  ? ma_1h_21 : na, "1H 21 EMA",  color=col_ma_slow, linewidth=2, style=plot.style_stepline)
plot(show_ma_4h  ? ma_4h_20 : na, "4H 20 EMA",  color=col_ma_4h,   linewidth=3, style=plot.style_stepline)
plot(show_ma_d20 ? ma_d_20  : na, "D 20 EMA",   color=col_ma_d20,  linewidth=2, style=plot.style_stepline)
plot(show_ma_d50 ? ma_d_50  : na, "D 50 SMA",   color=col_ma_d50,  linewidth=2, style=plot.style_stepline)

// ═══════════════════════════════════════════════════════════════════
// CHECKLIST PANEL
// ═══════════════════════════════════════════════════════════════════
pass_icon(cond) => cond ? "✅" : "❌"

f_sz(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

txt_sz = f_sz(text_sz_in)
hdr_sz = f_sz(header_sz_in)

f_pos(p) =>
    p == "top_right" ? position.top_right : p == "top_left" ? position.top_left : p == "bottom_right" ? position.bottom_right : p == "bottom_left" ? position.bottom_left : p == "middle_right" ? position.middle_right : position.middle_left

if show_panel and barstate.islast
    var table panel = table.new(f_pos(panel_pos), 2, 12, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.new(color.orange, 30))

    // Row 0: Header
    table.cell(panel, 0, 0, "7-POINT PRE-TRADE CHECKLIST v2", text_color=color.orange, text_size=hdr_sz, bgcolor=color.new(color.black, 0))
    table.merge_cells(panel, 0, 0, 1, 0)

    // Check 1
    table.cell(panel, 0, 1, pass_icon(is_expanding) + " 1. 4H expanding?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 1, is_expanding ? expand_direction : "no", text_color=is_expanding ? color.green : color.red, text_size=txt_sz)

    // Check 2
    prior_info = asia_reversed ? "Asia reversed" : london_reversed ? "London reversed" : asia_consolidated and london_consolidated ? "both consolidated" : "mixed"
    table.cell(panel, 0, 2, pass_icon(asia_reversed or london_reversed or asia_consolidated or london_consolidated) + " 2. Prior session?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 2, prior_info, text_color=color.white, text_size=txt_sz)

    // Check 3
    table.cell(panel, 0, 3, pass_icon(is_expanding) + " 3. Day type?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 3, day_type + " (" + day_direction + ")", text_color=day_type == "CONTINUATION" ? color.green : color.orange, text_size=txt_sz)

    // Check 4
    table.cell(panel, 0, 4, pass_icon(has_fvg) + " 4. FVG (entry)?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 4, has_fvg ? fvg_type + " @ " + str.tostring(math.round_to_mintick((fvg_top + fvg_bot) / 2)) : "none", text_color=has_fvg ? color.green : color.red, text_size=txt_sz)

    // Check 5 — now shows nearest level with tier label
    liq_above_txt = nearest_above_val < 99999999.0 ? nearest_above_label + " " + str.tostring(math.round_to_mintick(nearest_above_price)) : "-"
    liq_below_txt = nearest_below_val < 99999999.0 ? nearest_below_label + " " + str.tostring(math.round_to_mintick(nearest_below_price)) : "-"
    table.cell(panel, 0, 5, pass_icon(has_liquidity) + " 5. Liquidity?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 5, "▲" + liq_above_txt + " ▼" + liq_below_txt, text_color=has_liquidity ? color.green : color.red, text_size=txt_sz)

    // Check 6
    table.cell(panel, 0, 6, pass_icon(sweep_occurred) + " 6. Sweep?", text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.cell(panel, 1, 6, sweep_side, text_color=sweep_occurred ? color.green : color.orange, text_size=txt_sz)

    // Check 7 — bias
    table.cell(panel, 0, 7, "📋 7. BIAS:", text_color=color.orange, text_size=txt_sz, text_halign=text.align_left)
    table.merge_cells(panel, 0, 7, 1, 7)
    table.cell(panel, 0, 8, bias_sentence, text_color=color.white, text_size=txt_sz, text_halign=text.align_left)
    table.merge_cells(panel, 0, 8, 1, 8)

    // Context row — price vs VWAP and 4H EMA
    vwap_pos  = show_dvwap and d_vwap > 0 ? (close > d_vwap ? "above VWAP" : "below VWAP") : ""
    ema4h_pos = show_ma_4h and ma_4h_20 > 0 ? (close > ma_4h_20 ? "above 4H EMA" : "below 4H EMA") : ""
    ctx = vwap_pos + (str.length(vwap_pos) > 0 and str.length(ema4h_pos) > 0 ? " | " : "") + ema4h_pos
    table.cell(panel, 0, 9, ctx, text_color=color.gray, text_size=txt_sz, text_halign=text.align_left)
    table.merge_cells(panel, 0, 9, 1, 9)

    // Summary
    all_pass = is_expanding and has_fvg and has_liquidity and sweep_occurred
    summary_text = all_pass ? "✅ TRADE READY" : is_expanding ? "⚠ WAIT FOR SETUP" : "❌ NO TRADE TODAY"
    summary_color = all_pass ? color.green : is_expanding ? color.orange : color.red
    table.cell(panel, 0, 10, summary_text, text_color=color.white, bgcolor=summary_color, text_size=hdr_sz)
    table.merge_cells(panel, 0, 10, 1, 10)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(is_expanding and not is_expanding[1], "4H began expanding", "4H expansion started — potential trade day")
alertcondition(sweep_occurred and not sweep_occurred[1], "External liquidity swept", "Sweep occurred — watch for displacement")
all_pass_alert = is_expanding and has_fvg and has_liquidity and sweep_occurred
alertcondition(all_pass_alert and not all_pass_alert[1], "ALL CHECKS PASSED", "All 7 conditions met — trade ready")

// x.com/tsmake
````
