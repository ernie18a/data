# Prism Intelligence SPX  GEX Confluence and Sniper Entry System

- url: https://www.tradingview.com/script/pntn3ivw-Prism-Intelligence-SPX-GEX-Confluence-and-Sniper-Entry-System/
- type: indicator
- pine_id: PUB;df6854c985854ce99c433caf351c9290
- version: 1.0

## Description

Prism Intelligence SPX is a professional-grade overlay indicator built specifically
for SPX intraday and swing trading. It combines dealer gamma exposure (GEX) levels,
volatility regime analysis, and a 12-component confluence scoring system to identify
high-conviction long entries and precise exits — with zero signal noise between
setups.

The indicator is designed to be updated once before the open each session using
inputs from your GEX data provider or newsletter, then left to run autonomously
throughout the day.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DATA SUBSCRIPTION NOTICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator fetches the following external symbols via request.security(). Some
may require a paid data subscription depending on your TradingView account tier:

• CBOE:VIX    — CBOE Volatility Index
• CBOE:VIX3M  — CBOE 3-Month Volatility Index
• CBOE:VVIX   — CBOE Volatility of Volatility Index
• CBOE:SKEW   — CBOE SKEW Index
• USI:PCCE    — CBOE Equity Put/Call Ratio
• USI:ADVN.NY — NYSE Advancing Issues
• USI:DECL.NY — NYSE Declining Issues

If any of these display as N/A in the dashboard table, check your TradingView data
permissions under Profile → Manage Plan → Data.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is provided for informational and educational purposes only. It does
not constitute financial advice, a recommendation to buy or sell any security, or a
guarantee of any particular outcome. All trading involves risk, including the
possible loss of principal. Past signal performance does not guarantee future
results. You are solely responsible for your own trading decisions. Always conduct
your own research and consult a qualified financial advisor before making any
investment decisions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS — THREE-LAYER ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LAYER 1 — MACRO REGIME CONTEXT
A 12-point confluence score is calculated from a combination of session inputs and
auto-fetched market data. The score determines whether conditions favor aggressive
positioning, cautious positioning, or staying flat. A score of 9 or higher with
price above the HVL (gamma flip level) is required for any long signal to activate.

LAYER 2 — LOCAL TREND FILTER
The MA9 slope and price position relative to MA9 are evaluated on every bar. Long
signals are fully suppressed when short-term momentum is declining — this prevents
buying into intraday downtrends even when the macro score is green.

LAYER 3 — PRECISION ENTRY TRIGGER
Within the right macro and trend context, signals fire on specific price-action
events: MA20 reclaims, MA9 reclaims, opening range momentum confirmation (bars
3–8 of the session), HVL reclaims, and key level bounces. Exits fire on MA20
breaks or HVL loss.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNALS ON CHART
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔺 TEAL TRIANGLE — Sniper Long (below bar)
Highest conviction long entry. Score ≥9, above HVL, local uptrend confirmed,
triggered by MA20 reclaim, HVL reclaim, opening momentum confirmation, or key
level bounce (HVL / Put Wall / Lower Band).

🔺 LIME TRIANGLE — Aggressive Long (below bar)
Faster entry off MA9 reclaim in the same high-score context. Suitable for
momentum continuation or scalp trades. Fires only when not already covered by
a Sniper Long on the same bar.

◆ YELLOW DIAMOND — Caution (below bar)
Score 6–8 with valid MA reclaim and local uptrend. Setup is valid but conviction
is lower — consider reducing size or using tighter stops.

🔻 RED TRIANGLE — Exit (above bar)
MA20 broken in a high-score regime, or HVL broken at any score, or confluence
score collapsed below 6. Get flat or tighten stops immediately.

✕ RED X — HVL Breach (above bar)
Price crossed below the gamma flip level. Regime may be shifting bearish — treat
all long exposure with caution until price reclaims HVL.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AUTOMATIC LEVEL OVERLAY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All levels extend right with labeled price callouts. No extra input required.

DAILY EXPECTED MOVE ±1σ  (purple dashed)
Derived from VIX using the standard dealer pricing formula:
  prev_close × (VIX / 100) / √252
Upper and lower bands represent the 1-standard-deviation daily range that options
dealers are pricing. Price reaching either band mid-session is a natural
mean-reversion reference and often marks an intraday exhaustion point.

OPENING RANGE HIGH / LOW  (yellow dotted)
High and low of the first N bars of RTH (default 6 bars = 30 minutes on a 5-min
chart, configurable in settings). OR High breakout signals momentum continuation;
OR Low breakdown signals potential intraday reversal. Among the most reliable
intraday reference levels for SPX specifically.

PREVIOUS DAY HIGH / CLOSE / LOW  (silver dashed)
Non-repainting confirmed daily OHLC. PDH and PDL define the overnight reference
frame and are key levels for gap analysis. PDC is the primary overnight positioning
level — price often gravitates here when the session lacks a directional catalyst.

MANUAL SESSION LEVELS  (drawn from your inputs each session)
• Call Wall  (red dashed)    — Primary dealer call resistance strike
• Put Wall   (green dashed)  — Primary 0DTE dealer put support strike
• HVL        (orange solid)  — Gamma flip level / regime boundary
• Risk Trigger (teal solid)  — Primary swing model upside target
• Lower Band  (blue dotted)  — Swing model downside support

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKGROUND ZONE COLORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Faint teal   — Score ≥9 and above HVL. Full green light environment.
Faint yellow — Score 6–8 and above HVL. Cautious but tradeable.
Faint red    — Price below HVL. Danger zone — long bias suspended.

Colors apply only to confirmed closed bars and do not fill future bars.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DASHBOARD TABLE  (top-right corner)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All 20 rows update in real time. Color-coded status dot on each row.

MANUAL INPUTS (update before the open each session):
  Regime         CONSTRUCTIVE / TRANSITIONAL / CONTESTED / BEARISH
  Q-Score        MenthorQ composite score 0–12
  Net GEX        Net dealer gamma in billions (positive = pinning environment)
  Call Wall       Primary dealer call resistance strike
  Put Wall        Primary 0DTE put support strike
  HVL             Gamma flip / regime boundary
  Risk Trigger    Primary swing model upside target
  Lower Band      Swing model downside support

AUTO-CALCULATED (live, no input required):
  VIX            Spot implied volatility + compressing/expanding status
  Term Struct    CONTANGO (VIX < VIX3M) or BACKWARDATION — regime indicator
  VRP            Volatility Risk Premium (VIX minus 30-day HV annualized)
  IV Rank        VIX percentile over trailing 252 bars
  VVIX           Vol-of-vol — green below 100, red above 110
  SKEW           Tail risk — green below 130, red above 140
  PCCE           Equity put/call ratio — green above 0.80 (contrarian long)
  CTA Proxy      Price vs MA20/50/200 structure (0–4 long signals)
  NYMO           NYSE McClellan Oscillator (calculated from ADVN/DECL)
  Entry Score    Total confluence score /12 with teal/yellow/red color coding

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MANUAL INPUTS — FULL REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Input           Range       Description
─────────────────────────────────────────────────────────────────
Regime          4 options   CONSTRUCTIVE (+2), TRANSITIONAL (+1),
                            CONTESTED (0), BEARISH (0)
Q-Score         0–12        MenthorQ composite score
Net GEX (B)     any         Net gamma in billions. Positive = dealer
                            pinning, negative = dealer amplifying moves
Call Wall       price       Largest dealer call OI strike (resistance)
Put Wall        price       Largest 0DTE dealer put OI strike (support)
HVL             price       Gamma flip level — the most important level.
                            Above = dealers buy dips; Below = dealers
                            sell rallies
Risk Trigger    price       Primary swing model upside target
Lower Band      price       Primary swing model downside support
CTA Z-Score     -3 to 3     CTA equity positioning z-score (MenthorQ)
L/S Barometer   0–0.5       Long/short vol barometer (low = less hedging)
Vol Control     any         Vol control fund ratio (≤1.05 = re-entry zone)
Expiry          3 options   MONTHLY / WEEKLY / NONE (context only)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONFLUENCE SCORING — HOW POINTS ARE ASSIGNED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Component             Max    Condition
──────────────────────────────────────────────────────────────────
Regime                2      CONSTRUCTIVE=2, TRANSITIONAL=1, else 0
Q-Score               2      ≥10=2, ≥7=1, else 0
Net GEX positive      1      GEX > 0
VIX compressing       1      VIX < MA10 < MA20
Term contango         1      VIX < VIX3M
VVIX calm             1      VVIX < 100
SKEW not extreme      1      SKEW < 135
PCCE elevated         1      PCCE > 0.80 (contrarian long)
CTA constructive      1      CTA Z-Score > 0.5
Low hedging demand    1      L/S Barometer < 0.20
Vol control entry     1      Vol ratio ≤ 1.05
Positive breadth      1      NYMO > 0
──────────────────────────────────────────────────────────────────
TOTAL                 12

Score ≥9 + above HVL → Sniper Long eligible
Score 6–8 + above HVL → Caution Long eligible
Score <6 or below HVL → No long signals

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Opening Range bars (default 6):
  Adjust for your timeframe —
  5-min chart:  6 bars = 30 min OR, 3 bars = 15 min OR
  1-min chart:  30 bars = 30 min OR
  15-min chart: 2 bars = 30 min OR

Individual toggles for Daily EM, Opening Range, and Prev Day levels.
All can be turned off independently if the chart becomes crowded.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BEST TIMEFRAMES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommended: 5-minute and 15-minute
Compatible symbols: SPX, SPCFD, SPY, ES1!, MES1!

The 12-point scoring system is session-level — update the manual inputs once
before the open. The signal triggers (MA crossovers, level bounces) fire
automatically throughout the session.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Five alert conditions are built in. Set them via the Alerts panel (⏰) once the
indicator is on your chart:

• Prism Sniper Long     — Highest conviction entry
• Prism Aggressive Long — Faster MA9-based entry
• Prism Caution         — Score 6–8 setup
• Prism Exit            — Exit or stop-tighten signal
• HVL Breach            — Gamma flip level lost

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELATED RESOURCES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Manual inputs are designed to work directly with data from:
• MenthorQ  (Q-Score, CTA Z-Score, L/S Barometer, Vol Control Ratio)
• SpotGamma, SqueezeMetrics, or similar GEX providers
  (Call Wall, Put Wall, HVL, Net GEX)

The Prism Intelligence newsletter publishes these values prior to each session.

## Source Code

````pine
//@version=6
// max_lines_count: 5 existing + 2 EM + 2 OR + 3 PD = 12 lines. Set to 20 for headroom.
// max_labels_count: same count — 20.
indicator("Prism Intelligence SPX", overlay=true, max_lines_count=20, max_labels_count=20)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION A — MANUAL INPUTS
// ══════════════════════════════════════════════════════════════════════════════
var string GRP  = "📋 Prism Manual Inputs (update each session)"
var string GRP2 = "📐 Auto-Level Settings"

I_REGIME       = input.string("CONSTRUCTIVE", "Regime", options=["CONSTRUCTIVE", "CONTESTED", "TRANSITIONAL", "BEARISH"], group=GRP)
I_Q_SCORE      = input.float(11,      "Q-Score (0-12)",    minval=0,  maxval=12,  group=GRP)
I_NET_GEX_B    = input.float(1.391,   "Net GEX (Billions)",                        group=GRP)
I_CALL_WALL    = input.float(7060,    "Call Wall",                                  group=GRP)
I_PUT_WALL     = input.float(6840,    "Put Wall (0DTE)",                            group=GRP)
I_HVL          = input.float(6830,    "HVL (Gamma Flip)",                           group=GRP)
I_RISK_TRIGGER = input.float(7160.66, "Risk Trigger",                               group=GRP)
I_LOWER_BAND   = input.float(6885.24, "Lower Band",                                 group=GRP)
I_CTA_Z        = input.float(0.72,    "CTA Z-Score",       minval=-3, maxval=3,    group=GRP)
I_LS_BARO      = input.float(0.17,    "L/S Vol Barometer", minval=0,  maxval=0.5,  group=GRP)
I_VOL_RATIO    = input.float(1.0,     "Vol Control Ratio",                          group=GRP)
I_EXPIRY       = input.string("MONTHLY", "Expiry", options=["MONTHLY", "WEEKLY", "NONE"], group=GRP)

// Auto-level toggles
SHOW_EM = input.bool(true,  "Show Daily Expected Move (±1σ)", group=GRP2)
SHOW_OR = input.bool(true,  "Show Opening Range H/L",         group=GRP2)
SHOW_PD = input.bool(true,  "Show Prev Day H/C/L",            group=GRP2)
OR_BARS = input.int(6,      "Opening Range bars (6 = 30 min on 5-min chart)", minval=1, maxval=20, group=GRP2)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION B — REQUEST.SECURITY() CALLS  (all at top scope — v6 requirement)
// ══════════════════════════════════════════════════════════════════════════════
vix   = request.security("CBOE:VIX",    timeframe.period, close)
vix3m = request.security("CBOE:VIX3M",  timeframe.period, close)
vvix  = request.security("CBOE:VVIX",   timeframe.period, close)
skew  = request.security("CBOE:SKEW",   timeframe.period, close)
pcce  = request.security("USI:PCCE",    timeframe.period, close)
advn  = request.security("USI:ADVN.NY", timeframe.period, close)
decl  = request.security("USI:DECL.NY", timeframe.period, close)

// Previous day OHLC — lookahead_on + [1] offset = confirmed, non-repainting
prev_day_high  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prev_day_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
prev_day_low   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION B (cont.) — AUTO-CALCULATED SIGNALS
// ══════════════════════════════════════════════════════════════════════════════

// NYMO — McClellan Oscillator (ratio-adjusted)
net_adv    = (not na(advn) and not na(decl) and (advn + decl) > 0) ? (advn - decl) / (advn + decl) * 1000 : 0.0
nymo_ema19 = ta.ema(net_adv, 19)
nymo_ema39 = ta.ema(net_adv, 39)
nymo       = nymo_ema19 - nymo_ema39

// Log return — na guard
log_ret = (close > 0 and close[1] > 0) ? math.log(close / close[1]) : 0.0

// Historical volatility (annualized %)
hv5  = ta.stdev(log_ret, 5)  * math.sqrt(252) * 100
hv20 = ta.stdev(log_ret, 20) * math.sqrt(252) * 100
hv30 = ta.stdev(log_ret, 30) * math.sqrt(252) * 100

// Volatility Risk Premium
vrp = vix - hv30

// IV Rank
vix_hi  = ta.highest(vix, 252)
vix_lo  = ta.lowest(vix, 252)
iv_rank = (vix_hi - vix_lo != 0) ? (vix - vix_lo) / (vix_hi - vix_lo) * 100 : 0.0

// VIX regime
vix_ma10        = ta.sma(vix, 10)
vix_ma20        = ta.sma(vix, 20)
vix_compressing = vix < vix_ma10 and vix_ma10 < vix_ma20

// Term structure
term_contango = vix < vix3m

// MAs
ma9   = ta.sma(close, 9)
ma20  = ta.sma(close, 20)
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)
cta_score = (close > ma20 ? 1 : 0) + (close > ma50 ? 1 : 0) + (close > ma200 ? 1 : 0) + (ma20 > ma50 ? 1 : 0)

// ── Daily Expected Move (±1σ) ────────────────────────────────────────────────
// Formula: prev_close × (VIX / 100) / √252
// This is the market-implied 1-standard-deviation daily range that dealers are pricing.
// Price touching the upper band = call dealers fully hedged; lower = put dealers hedged.
daily_em    = not na(prev_day_close) and not na(vix) ? prev_day_close * (vix / 100) / math.sqrt(252) : na
em_upper    = not na(daily_em) ? prev_day_close + daily_em : na
em_lower    = not na(daily_em) ? prev_day_close - daily_em : na

// ── Opening Range High / Low ─────────────────────────────────────────────────
// Tracks the high and low of the first OR_BARS bars of each session.
// On a 5-min chart OR_BARS=6 gives the standard 30-minute opening range.
// These levels are among the most reliable intraday reference points for SPX.
var int   day_bar_count = 0
var float or_high       = na
var float or_low        = na

day_bar_count := ta.change(dayofmonth) != 0 ? 1 : day_bar_count + 1

// Reset at new session
if ta.change(dayofmonth) != 0
    or_high := na
    or_low  := na

// Accumulate during opening range window
if day_bar_count <= OR_BARS
    or_high := na(or_high) ? high : math.max(or_high, high)
    or_low  := na(or_low)  ? low  : math.min(or_low,  low)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION C — ENTRY SCORING SYSTEM (confluence 0-12)
// ══════════════════════════════════════════════════════════════════════════════
s1  = I_REGIME == "CONSTRUCTIVE" ? 2 : I_REGIME == "TRANSITIONAL" ? 1 : 0
s2  = I_Q_SCORE >= 10 ? 2 : I_Q_SCORE >= 7 ? 1 : 0
s3  = I_NET_GEX_B > 0 ? 1 : 0
s4  = vix_compressing ? 1 : 0
s5  = term_contango ? 1 : 0
s6  = not na(vvix) and vvix < 100  ? 1 : 0
s7  = not na(skew) and skew < 135  ? 1 : 0
s8  = not na(pcce) and pcce > 0.80 ? 1 : 0
s9  = I_CTA_Z > 0.5    ? 1 : 0
s10 = I_LS_BARO < 0.20 ? 1 : 0
s11 = I_VOL_RATIO <= 1.05 ? 1 : 0
s12 = nymo > 0 ? 1 : 0

total_score = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12

// ══════════════════════════════════════════════════════════════════════════════
// SECTION C2 — SNIPER SIGNAL LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// ── Layer 1: Macro context ──
above_hvl = close > I_HVL
score_hi  = total_score >= 9
score_mid = total_score >= 6 and total_score < 9

// ── Layer 2: Local trend filter ──
local_uptrend = ma9 > ma9[1] and close > ma9

// ── Layer 3A: Opening momentum ──
confirmed_open_window = day_bar_count >= 3 and day_bar_count <= 8
open_momentum_state   = confirmed_open_window and score_hi and above_hvl and close > ma20 and close > open and close > close[1] and ma9 > ma9[1]
open_long             = open_momentum_state and not open_momentum_state[1]

// ── Layer 3B: MA reclaim triggers ──
ma9_reclaim  = ta.crossover(close,  ma9)
ma20_reclaim = ta.crossover(close,  ma20)
ma9_break    = ta.crossunder(close, ma9)
ma20_break   = ta.crossunder(close, ma20)

// ── Layer 3C: HVL crossovers ──
hvl_reclaim = ta.crossover(close,  I_HVL)
hvl_lose    = ta.crossunder(close, I_HVL)

// ── Score transitions ──
score_9_up   = ta.crossover(total_score,  8.5)
score_6_down = ta.crossunder(total_score, 6.0)

// ── Level bounce ──
tol           = 0.003
near_hvl      = math.abs(close - I_HVL)        / I_HVL        < tol and close >= open
near_put_wall = math.abs(close - I_PUT_WALL)   / I_PUT_WALL   < tol and close >= open
near_lower    = math.abs(close - I_LOWER_BAND) / I_LOWER_BAND < tol and close >= open
level_bounce  = near_hvl or near_put_wall or near_lower

// ── Final signals ──
sniper_long     = score_hi  and above_hvl and local_uptrend and (open_long or ma20_reclaim or hvl_reclaim or level_bounce or score_9_up)
aggressive_long = score_hi  and above_hvl and local_uptrend and ma9_reclaim and not sniper_long
sniper_caution  = score_mid and above_hvl and local_uptrend and (ma20_reclaim or hvl_reclaim)
exit_signal     = hvl_lose or (above_hvl and score_hi and ma20_break) or score_6_down
hvl_breach      = hvl_lose

// ══════════════════════════════════════════════════════════════════════════════
// SECTION D — BACKGROUND ZONE COLORING
// ══════════════════════════════════════════════════════════════════════════════
bgcolor(barstate.isconfirmed and not above_hvl           ? color.new(color.red,    92) : na, title="Below HVL — Danger")
bgcolor(barstate.isconfirmed and above_hvl and score_hi  ? color.new(color.teal,   95) : na, title="High Score Zone")
bgcolor(barstate.isconfirmed and above_hvl and score_mid ? color.new(color.yellow, 96) : na, title="Caution Zone")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION D2 — MA PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(ma9,  color=color.new(color.aqua,  40), linewidth=1, title="MA9  (aggressive trigger)")
plot(ma20, color=color.new(color.white, 45), linewidth=1, title="MA20 (sniper trigger)")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION D3 — ALL LEVEL LINES (rebuilt on last bar so inputs stay live)
//
// Levels on chart:
//   MANUAL    : Call Wall, Put Wall, HVL, Risk Trigger, Lower Band
//   AUTO-CALC : Daily EM Upper/Lower, Opening Range H/L, Prev Day H/C/L
// ══════════════════════════════════════════════════════════════════════════════

// Manual level lines
var line  l_call_wall    = na
var line  l_put_wall     = na
var line  l_hvl          = na
var line  l_risk_trigger = na
var line  l_lower_band   = na
var label lb_call_wall    = na
var label lb_put_wall     = na
var label lb_hvl          = na
var label lb_risk_trigger = na
var label lb_lower_band   = na

// Auto level lines — Expected Move
var line  l_em_upper = na
var line  l_em_lower = na
var label lb_em_upper = na
var label lb_em_lower = na

// Auto level lines — Opening Range
var line  l_or_high = na
var line  l_or_low  = na
var label lb_or_high = na
var label lb_or_low  = na

// Auto level lines — Previous Day
var line  l_pd_high  = na
var line  l_pd_close = na
var line  l_pd_low   = na
var label lb_pd_high  = na
var label lb_pd_close = na
var label lb_pd_low   = na

if barstate.islast
    // ── Delete all previous objects ──────────────────────────────────────────
    line.delete(l_call_wall)
    line.delete(l_put_wall)
    line.delete(l_hvl)
    line.delete(l_risk_trigger)
    line.delete(l_lower_band)
    label.delete(lb_call_wall)
    label.delete(lb_put_wall)
    label.delete(lb_hvl)
    label.delete(lb_risk_trigger)
    label.delete(lb_lower_band)
    line.delete(l_em_upper)
    line.delete(l_em_lower)
    label.delete(lb_em_upper)
    label.delete(lb_em_lower)
    line.delete(l_or_high)
    line.delete(l_or_low)
    label.delete(lb_or_high)
    label.delete(lb_or_low)
    line.delete(l_pd_high)
    line.delete(l_pd_close)
    line.delete(l_pd_low)
    label.delete(lb_pd_high)
    label.delete(lb_pd_close)
    label.delete(lb_pd_low)

    // ── Manual levels ────────────────────────────────────────────────────────
    l_call_wall    := line.new(bar_index, I_CALL_WALL,    bar_index + 1, I_CALL_WALL,    extend=extend.right, color=color.new(color.red,    20), style=line.style_dashed, width=1)
    l_put_wall     := line.new(bar_index, I_PUT_WALL,     bar_index + 1, I_PUT_WALL,     extend=extend.right, color=color.new(color.green,  20), style=line.style_dashed, width=1)
    l_hvl          := line.new(bar_index, I_HVL,          bar_index + 1, I_HVL,          extend=extend.right, color=color.new(color.orange,  0), style=line.style_solid,  width=2)
    l_risk_trigger := line.new(bar_index, I_RISK_TRIGGER, bar_index + 1, I_RISK_TRIGGER, extend=extend.right, color=color.new(color.teal,    0), style=line.style_solid,  width=1)
    l_lower_band   := line.new(bar_index, I_LOWER_BAND,   bar_index + 1, I_LOWER_BAND,   extend=extend.right, color=color.new(color.blue,   30), style=line.style_dotted, width=1)

    lb_call_wall    := label.new(bar_index, I_CALL_WALL,    "CALL WALL "  + str.tostring(I_CALL_WALL,    "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.red,    85), textcolor=color.new(color.red,    10), size=size.small)
    lb_put_wall     := label.new(bar_index, I_PUT_WALL,     "PUT WALL "   + str.tostring(I_PUT_WALL,     "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.green,  85), textcolor=color.new(color.green,  10), size=size.small)
    lb_hvl          := label.new(bar_index, I_HVL,          "HVL "        + str.tostring(I_HVL,          "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.orange, 80), textcolor=color.new(color.orange, 10), size=size.small)
    lb_risk_trigger := label.new(bar_index, I_RISK_TRIGGER, "RISK TGT "   + str.tostring(I_RISK_TRIGGER, "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.teal,   80), textcolor=color.new(color.teal,   10), size=size.small)
    lb_lower_band   := label.new(bar_index, I_LOWER_BAND,   "LOWER BAND " + str.tostring(I_LOWER_BAND,   "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.blue,   80), textcolor=color.new(color.blue,   10), size=size.small)

    // ── Daily Expected Move (±1σ) ────────────────────────────────────────────
    // Upper = prev_close + (prev_close × VIX% / √252)
    // Lower = prev_close − same
    // Color: purple — visually distinct from all manual levels
    if SHOW_EM and not na(em_upper) and not na(em_lower)
        l_em_upper  := line.new(bar_index, em_upper, bar_index + 1, em_upper, extend=extend.right, color=color.new(color.purple, 20), style=line.style_dashed, width=1)
        l_em_lower  := line.new(bar_index, em_lower, bar_index + 1, em_lower, extend=extend.right, color=color.new(color.purple, 20), style=line.style_dashed, width=1)
        lb_em_upper := label.new(bar_index, em_upper, "EM+ " + str.tostring(em_upper, "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.purple, 80), textcolor=color.new(color.purple, 10), size=size.small)
        lb_em_lower := label.new(bar_index, em_lower, "EM- " + str.tostring(em_lower, "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.purple, 80), textcolor=color.new(color.purple, 10), size=size.small)

    // ── Opening Range High / Low ─────────────────────────────────────────────
    // Color: yellow-gold — signals intraday range reference
    if SHOW_OR and not na(or_high) and not na(or_low)
        l_or_high  := line.new(bar_index, or_high, bar_index + 1, or_high, extend=extend.right, color=color.new(color.yellow, 30), style=line.style_dotted, width=2)
        l_or_low   := line.new(bar_index, or_low,  bar_index + 1, or_low,  extend=extend.right, color=color.new(color.yellow, 30), style=line.style_dotted, width=2)
        lb_or_high := label.new(bar_index, or_high, "OR HIGH " + str.tostring(or_high, "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.yellow, 80), textcolor=color.new(color.yellow, 10), size=size.small)
        lb_or_low  := label.new(bar_index, or_low,  "OR LOW "  + str.tostring(or_low,  "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.yellow, 80), textcolor=color.new(color.yellow, 10), size=size.small)

    // ── Previous Day High / Close / Low ─────────────────────────────────────
    // Color: silver/gray — clearly "prior session" without competing with live levels
    if SHOW_PD and not na(prev_day_high) and not na(prev_day_close) and not na(prev_day_low)
        l_pd_high  := line.new(bar_index, prev_day_high,  bar_index + 1, prev_day_high,  extend=extend.right, color=color.new(color.silver, 30), style=line.style_dashed, width=1)
        l_pd_close := line.new(bar_index, prev_day_close, bar_index + 1, prev_day_close, extend=extend.right, color=color.new(color.silver, 50), style=line.style_dotted, width=1)
        l_pd_low   := line.new(bar_index, prev_day_low,   bar_index + 1, prev_day_low,   extend=extend.right, color=color.new(color.silver, 30), style=line.style_dashed, width=1)
        lb_pd_high  := label.new(bar_index, prev_day_high,  "PDH " + str.tostring(prev_day_high,  "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.silver, 80), textcolor=color.new(color.silver, 10), size=size.small)
        lb_pd_close := label.new(bar_index, prev_day_close, "PDC " + str.tostring(prev_day_close, "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.silver, 80), textcolor=color.new(color.silver, 10), size=size.small)
        lb_pd_low   := label.new(bar_index, prev_day_low,   "PDL " + str.tostring(prev_day_low,   "0.##"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.silver, 80), textcolor=color.new(color.silver, 10), size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION D4 — SIGNAL DOTS
// ══════════════════════════════════════════════════════════════════════════════
plotshape(sniper_long,     title="Prism Sniper Long",     style=shape.triangleup,   location=location.belowbar, color=color.new(color.teal,  0), size=size.normal)
plotshape(aggressive_long, title="Prism Aggressive Long", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,  0), size=size.small)
plotshape(sniper_caution,  title="Prism Caution",         style=shape.diamond,      location=location.belowbar, color=color.new(color.yellow,0), size=size.small)
plotshape(exit_signal,     title="Prism Exit",            style=shape.triangledown, location=location.abovebar, color=color.new(color.red,   0), size=size.normal)
plotshape(hvl_breach,      title="HVL Breach",            style=shape.xcross,       location=location.abovebar, color=color.new(color.red,   0), size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION E — DASHBOARD TABLE
// ══════════════════════════════════════════════════════════════════════════════
var table t = table.new(position.top_right, 3, 20, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.white, 70))

c_bg  = color.new(color.black,  15)
c_hdr = color.new(color.navy,   10)
c_sep = color.new(color.gray,   60)
c_lbl = color.new(color.white,  20)
c_val = color.new(color.white,   0)
c_g   = color.new(color.green,   0)
c_y   = color.new(color.yellow,  0)
c_r   = color.new(color.red,     0)
c_t   = color.new(color.teal,    0)
c_o   = color.new(color.orange,  0)

if barstate.islast

    table.cell(t, 0, 0, "PRISM INTELLIGENCE  · SPX", text_color=color.white, bgcolor=c_hdr, text_size=size.small)
    table.merge_cells(t, 0, 0, 2, 0)

    r_dot = I_REGIME == "CONSTRUCTIVE" ? c_t : I_REGIME == "TRANSITIONAL" ? c_o : c_r
    table.cell(t, 0, 1, "REGIME",  text_color=c_lbl, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 1, I_REGIME,  text_color=c_val, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 1, "●",       text_color=r_dot, bgcolor=c_bg, text_size=size.small)

    q_dot = I_Q_SCORE >= 10 ? c_t : I_Q_SCORE >= 7 ? c_y : c_r
    table.cell(t, 0, 2, "Q-SCORE",                             text_color=c_lbl, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(I_Q_SCORE, "0") + "/12", text_color=c_val, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 2, "●",                                   text_color=q_dot, bgcolor=c_bg, text_size=size.small)

    g_dot = I_NET_GEX_B > 0 ? c_g : c_r
    g_col = I_NET_GEX_B > 0 ? color.green : color.red
    table.cell(t, 0, 3, "NET GEX",                                 text_color=c_lbl, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(I_NET_GEX_B, "0.000") + "B", text_color=g_col, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 3, "●",                                       text_color=g_dot, bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 4, "CALL WALL",                    text_color=c_lbl,       bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(I_CALL_WALL, "0"), text_color=color.red,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 4, "●",                            text_color=c_r,         bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 5, "PUT WALL",                     text_color=c_lbl,       bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(I_PUT_WALL, "0"),  text_color=color.green, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 5, "●",                            text_color=c_g,         bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 6, "HVL",                          text_color=c_lbl,        bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(I_HVL, "0"),       text_color=color.orange, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 6, "●",                            text_color=c_o,          bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 7, "RISK TRIGGER",                       text_color=c_lbl,      bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(I_RISK_TRIGGER, "0.00"), text_color=color.teal, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 7, "●",                                  text_color=c_t,        bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 8, "-- AUTO-CALC --",  text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)
    table.cell(t, 1, 8, "----------------",  text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)
    table.cell(t, 2, 8, "",                  text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)

    v_dot = vix_compressing ? c_g : c_r
    table.cell(t, 0, 9, "VIX",                     text_color=c_lbl, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 9, str.tostring(vix, "0.00"), text_color=c_val, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 9, "●",                       text_color=v_dot, bgcolor=c_bg, text_size=size.small)

    ts_dot = term_contango ? c_g : c_r
    ts_val = term_contango ? "CONTANGO" : "BACKWARDATION"
    ts_col = term_contango ? color.green : color.red
    table.cell(t, 0, 10, "TERM STRUCT",  text_color=c_lbl,  bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 10, ts_val,         text_color=ts_col, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 10, "●",            text_color=ts_dot, bgcolor=c_bg, text_size=size.small)

    vrp_dot = vrp < -2 ? c_g : vrp <= 0 ? c_y : c_r
    table.cell(t, 0, 11, "VRP",                           text_color=c_lbl,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 11, str.tostring(vrp, "0.0") + "%", text_color=c_val,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 11, "●",                            text_color=vrp_dot, bgcolor=c_bg, text_size=size.small)

    ivr_dot = iv_rank < 20 ? c_g : c_y
    table.cell(t, 0, 12, "IV RANK",                        text_color=c_lbl,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 12, str.tostring(iv_rank, "0") + "%", text_color=c_val,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 12, "●",                              text_color=ivr_dot, bgcolor=c_bg, text_size=size.small)

    vvix_dot = not na(vvix) and vvix < 100 ? c_g : not na(vvix) and vvix > 110 ? c_r : c_y
    table.cell(t, 0, 13, "VVIX",                   text_color=c_lbl,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 13, str.tostring(vvix, "0"),  text_color=c_val,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 13, "●",                      text_color=vvix_dot, bgcolor=c_bg, text_size=size.small)

    skew_dot = not na(skew) and skew < 130 ? c_g : not na(skew) and skew > 140 ? c_r : c_y
    table.cell(t, 0, 14, "SKEW",                   text_color=c_lbl,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 14, str.tostring(skew, "0"),  text_color=c_val,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 14, "●",                      text_color=skew_dot, bgcolor=c_bg, text_size=size.small)

    pcce_dot = not na(pcce) and pcce > 0.80 ? c_g : c_y
    table.cell(t, 0, 15, "PCCE",                     text_color=c_lbl,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 15, str.tostring(pcce, "0.00"), text_color=c_val,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 15, "●",                        text_color=pcce_dot, bgcolor=c_bg, text_size=size.small)

    cta_dot = cta_score >= 3 ? c_g : cta_score == 2 ? c_y : c_r
    table.cell(t, 0, 16, "CTA PROXY",                         text_color=c_lbl,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 16, str.tostring(cta_score) + "/4 LONG", text_color=c_val,   bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 16, "●",                                 text_color=cta_dot, bgcolor=c_bg, text_size=size.small)

    nymo_dot = nymo > 0 ? c_g : c_r
    table.cell(t, 0, 17, "NYMO",                   text_color=c_lbl,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 17, str.tostring(nymo, "0"),  text_color=c_val,    bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 17, "●",                      text_color=nymo_dot, bgcolor=c_bg, text_size=size.small)

    table.cell(t, 0, 18, "-- SIGNAL --",    text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)
    table.cell(t, 1, 18, "----------------", text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)
    table.cell(t, 2, 18, "",                 text_color=color.gray, bgcolor=c_sep, text_size=size.tiny)

    score_dot = score_hi ? c_t : score_mid ? c_y : c_r
    score_col = score_hi ? color.teal : score_mid ? color.yellow : color.red
    table.cell(t, 0, 19, "ENTRY SCORE",                     text_color=c_lbl,     bgcolor=c_bg, text_size=size.small)
    table.cell(t, 1, 19, str.tostring(total_score) + "/12", text_color=score_col, bgcolor=c_bg, text_size=size.small)
    table.cell(t, 2, 19, "●",                               text_color=score_dot, bgcolor=c_bg, text_size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION F — ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(sniper_long,     "Prism Sniper Long",     "SPX sniper entry — score >=9, above HVL, uptrend confirmed")
alertcondition(aggressive_long, "Prism Aggressive Long", "SPX aggressive entry — MA9 reclaim, score >=9, uptrend")
alertcondition(sniper_caution,  "Prism Caution",         "SPX caution — MA reclaim, score 6-8")
alertcondition(exit_signal,     "Prism Exit",            "SPX exit — MA20 lost or HVL lost or score collapsed")
alertcondition(hvl_breach,      "HVL Breach",            "SPX broke below HVL — regime may flip")
````
