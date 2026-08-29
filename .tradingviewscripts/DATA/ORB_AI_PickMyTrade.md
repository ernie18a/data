<!-- tradingview-pine-id: PUB;89bbd61f08114ce6aacbe5a2b1418c58 -->
<!-- tradingviewscripts-format: 1 -->
# ORB AI [PickMyTrade]

Source: https://www.tradingview.com/script/pRUbl7AG-ORB-AI-PickMyTrade/

## Description

ORB AI [PickMyTrade] asks a question most opening-range tools skip: does this
breakout resemble the chart's own past breakouts that worked, or the ones that didn't?
Instead of firing on a single range-break condition, every qualified breakout is scored
across seven independent structural factors, then cross-checked against an on-chart
K-nearest-neighbour library built exclusively from this symbol's own resolved breakout
outcomes. Both numbers are shown — the rule score and the KNN vote — without either one
silently deciding the trade for you.

----------------------------------------------------------------------------------------------------------------

🔷 WHAT IT MEASURES

🔸 Opening Range

The range locks from a configurable session anchor — Exchange Session (the symbol's own
listed timezone), New York 09:30, New York 08:30 (data), London 08:00, Tokyo 09:00, or a
Custom session/timezone pair — over a configurable window (1–120 minutes). If the chart
timeframe is coarser than the chosen window, the range automatically expands to one full
bar and the dashboard notes the effective duration rather than silently misrepresenting
it.

🔸 Rule Confidence (7-factor score)

Every qualified breakout candidate is scored 0–100 across Trend, Momentum, Volume,
Volatility, Structure, Breakout Quality and Liquidity. Trend itself is a blend (35% EMA
alignment, 25% ADX, 25% higher-timeframe read, 15% slope) — the dashboard breaks out all
seven components individually so the score is never a black box.

🔸 Flow Marks — BO / RT / FBO / Sweep

BO tags the confirmed breakout bar. RT tags a retest of the broken range edge that holds
(with a running count). FBO tags a breakout that closed back inside the range — a false
breakout, not a win or loss judgement. Sweep tags a wick that pierced the range edge and
closed back inside — liquidity taken without a directional close.

----------------------------------------------------------------------------------------------------------------

🔷 THE KNN ENGINE (LORENTZIAN DISTANCE)

🔸 How the library is built

Every rule-qualified breakout gets a 6-feature fingerprint (trend, momentum, volume,
volatility, structure, breakout quality). Its outcome is then resolved forward, stop
checked first: 1R target reached before the stop = win, stop first = loss, neither
within the configurable outcome window (15–600 minutes) = discarded as undecided —
drifts are never counted as losses, so the base rate reflects only decisive breakouts.
Every qualified candidate is recorded regardless of outcome, so the library grows
without selection bias.

🔸 How a new candidate is voted

A new candidate is compared to the stored library (up to 300 records) by Lorentzian
distance. The K nearest historical analogues (3–15, default 5) vote, and the vote share
is shown on the signal label and dashboard.

🔸 Advisory vs. Gate

Advisory mode (default) displays the vote as context; it never blocks a signal, so the
set of signalling bars stays fully deterministic regardless of library state. Gate mode
(opt-in) also requires the vote to clear a minimum share before a signal fires — this
trades determinism for selectivity and is only meaningful once the library has grown
past a configurable minimum size.

🔸 Read honestly

With a 6-feature fingerprint, the nearest neighbours of a few-hundred-record library
span roughly half of each feature's range — the vote is a coarse regional tendency, not
a precise analogue match. Loading a different amount of chart history can change the
displayed vote (Advisory) or which candidates pass (Gate); this is inherent to on-chart
instance-based learning and is disclosed rather than hidden. The indicator requires a
symbol with volume data — volume-less feeds (some cash indices / spot FX) cannot render
the KNN engine.

----------------------------------------------------------------------------------------------------------------

🔷 SIGNALS AND DISPLAY

🔸 Dashboard

A compact table shows Session, Regime, ML Engine status (library size / warm-up state),
locked Range, Bias, the 7-factor Rule Confidence bar, Risk-per-Unit, the active Trade
Plan, and a Flow Marks legend. An optional Full mode expands all seven score components.

🔸 Trade Plan overlay

On a qualified signal the indicator draws an entry, stop, and take-profit levels using
one of three configurable methods: a fixed R ladder, an opening-range-width measured-move
projection, or an ATR-scaled EMA-dynamic trail. This is a reference overlay describing
one rules-based way to structure the trade *if* you choose to take it — it is not a
recommendation, and the levels are not a performance claim.

🔸 Non-repainting

Signals evaluate on confirmed closes only. Locked range levels never change once set.
Higher-timeframe reads use `[1]` plus `lookahead_off`. The KNN library is built strictly
from already-resolved past outcomes — no future data is read at any point.

🔸 Alerts

19 `alertcondition()` calls cover long/short entries, false breakouts (combined and
per-direction), confidence-threshold crosses, range completion, trend-context changes,
take-profit and stop touches (combined and per-level), reversals, session-end exits,
approaching-breakout warnings, retests, and sweeps above/below the range. Recommended
alert setting: *Once Per Bar Close*.

----------------------------------------------------------------------------------------------------------------

🔷 INPUTS

🔸 Opening Range — Session anchor, custom session/timezone, range length (minutes).

🔸 Signal Engine — Minimum Rule Confidence threshold, TP method (R Ladder / OR Width
Projection / Dynamic EMA), R-ladder multiples, wide-range-OR filter.

🔸 KNN · ML Engine — Mode (Advisory / Gate / Off), K neighbours, history length,
minimum ML vote (Gate only), outcome window (minutes), Gate minimum library size.

🔸 Filters — Signal Blackout window (session-anchor timezone), max signals per
session, news filter.

🔸 Visual — Bull/bear colours, dashboard position and detail level, Zen mode (hides
text labels, keeps shapes/zones only).

----------------------------------------------------------------------------------------------------------------

🔷 REQUIREMENTS AND LIMITATIONS

Requires a symbol with volume data — the KNN engine cannot render on volume-less feeds
(some cash indices, spot FX). The KNN vote is a coarse regional tendency drawn from a
finite on-chart library, not a precise analogue match or a probability estimate; it is
advisory by default for that reason. Loading a different amount of chart history changes
the displayed vote in Advisory mode, and can change which candidates pass in Gate mode —
this is inherent to on-chart instance-based learning and is disclosed rather than hidden.
This is a decision-support toolkit: it does not place trades, and no element of the
dashboard, score, or trade-plan overlay is a claim about future performance. Always
apply independent risk management.

----------------------------------------------------------------------------------------------------------------

Built natively in Pine Script® v6. Seven-factor rule-based confluence scoring with an
on-chart, self-learning KNN engine using Lorentzian distance over resolved breakout
outcomes — no external libraries, no repainting, no lookahead.

Open source — Mozilla Public License 2.0.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
//  ORB AI [PickMyTrade]
//  Opening Range Breakout with a KNN (Lorentzian distance) engine
//  that learns from the outcomes of this chart's own past breakouts.
//
//  HOW THE ML WORKS (instance-based learning, 100% inside Pine):
//   1. Every rule-qualified breakout candidate gets a 6-feature
//      fingerprint (trend, momentum, volume, volatility, structure,
//      breakout quality — all trade-direction oriented).
//   2. Its outcome is measured forward: reached TP1 (1R) before the
//      stop = win; stop first = loss; NEITHER within the outcome
//      window = discarded as undecided (drifts must not deflate the
//      base rate). Resolved bar-by-bar, stop checked first.
//   3. A new candidate is compared to the stored library with
//      Lorentzian distance; the K nearest past breakouts vote.
//      The vote share — the percentage of the closest past
//      analogues that reached their target — is shown on the label.
//      By DEFAULT this is advisory: it is displayed as context and
//      never blocks a signal, so the set of signalling bars stays
//      fully deterministic. Gate mode (opt-in) also filters on it.
//   4. ALL qualified candidates are recorded — accepted or not —
//      so the library grows without selection bias and the engine
//      never cold-start deadlocks.
//
//  NON-REPAINTING: signals evaluate on confirmed closes only;
//  locked range levels never change; HTF data reads closed bars
//  ([1] + lookahead_off); pivots are used only after confirmation.
//  The KNN library is built strictly from already-resolved past
//  outcomes — no future data is ever read.
//  Note: because the engine learns as history replays, loading a
//  different amount of chart history can produce a different VOTE.
//  In the default Advisory mode that only changes a displayed
//  number — entries, stops and targets are unaffected. In Gate mode
//  it can also change which candidates pass, so Gate mode trades
//  some determinism for selectivity. This is inherent to on-chart
//  learning and is disclosed rather than hidden.
//  Sample-size honesty: with 6 features, the nearest neighbours of
//  a few-hundred-record library span roughly half of each feature's
//  range, so the vote is a coarse regional tendency, not a precise
//  analogue match. It is read as context, which is why Advisory is
//  the default and Gate is opt-in.
//  Requires a symbol with volume data (stocks, futures, crypto) —
//  volume-less feeds (some cash indices / spot FX) cannot render it.
//
//  TP methods: fixed R ladder, classic OR-width measured-move
//  projection, or EMA-dynamic trailing (ATR-scaled). Gap context
//  (open vs previous close / PDH / PDL) feeds the structure score;
//  a wide-range-OR filter stands aside when the range is too wide
//  for breakout continuation to offer acceptable reward-to-risk.
//
//  Recommended alert setting: "Once Per Bar Close".
// ═══════════════════════════════════════════════════════════════
indicator("ORB AI [PickMyTrade]", shorttitle = "ORB AI PMT", overlay = true, max_boxes_count = 200, max_labels_count = 300, max_lines_count = 100)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
var string G_ORB   = "Opening Range"
var string G_SIG   = "Signal Engine"
var string G_KNN   = "KNN · ML Engine"
var string G_FILT  = "Filters"
var string G_TREND = "Trend / Momentum"
var string G_RISK  = "Risk Management"
var string G_DISP  = "Display"

i_or_min     = input.int  (15,    "Opening Range (minutes)", options = [1, 3, 5, 10, 15, 30, 60, 120], group = G_ORB, tooltip = "Length of the opening range, measured from the session anchor. 1/3 serve the 1-minute gapper style; 5-30 is the classic intraday ORB on a 1-15 minute chart. If the chart timeframe is coarser than this, the range automatically expands to one full chart bar and the dashboard notes the effective duration.")
i_anchor     = input.string("New York 09:30", "Session Anchor", options = ["New York 09:30", "New York 08:30 (data)", "London 08:00", "Tokyo 09:00", "Exchange Session", "Custom"], group = G_ORB, tooltip = "Where the opening range starts. New York 09:30 (default): the classic US cash-market open, read in America/New_York time explicitly — correct on CME futures (whose exchange clock is Chicago) and immune to daylight-saving shifts. New York 08:30: the US economic-data release window. London 08:00 and Tokyo 09:00: those markets' cash opens in their own timezones. Exchange Session: the symbol's own regular session open (RTH for stocks, GLOBEX 18:00 ET for CME futures, daily rollover for crypto). Custom: the window below in the timezone below.")
i_custom_ses = input.session("0930-1600", "Custom Session",             group = G_ORB, tooltip = "Only used when Session Anchor is Custom.")
i_custom_tz  = input.string("America/New_York", "Custom Session Timezone", group = G_ORB, tooltip = "IANA timezone the Custom Session times are read in — e.g. America/New_York, Europe/London, Asia/Tokyo. Session strings without an explicit timezone are read in the EXCHANGE's timezone, which on CME futures is Chicago — the classic source of ranges anchored an hour off. An explicit zone also handles daylight-saving for you.")
i_late_min   = input.int  (150,   "No New Signals After (min)", minval = 30, maxval = 720, group = G_ORB, tooltip = "No new signals after this many minutes from the session open — restricts entries to the earlier part of the session.")

i_trigger    = input.string("Close Confirmed", "Entry Trigger", options = ["Close Confirmed", "Intrabar Touch"], group = G_SIG, tooltip = "Close Confirmed (default): a bar must CLOSE beyond the range — later entry, far fewer fakeouts. Intrabar Touch: the entry is modeled at the range level itself, stop-order style, on the first bar whose extreme crosses it — the earliest possible fill, disclosed honestly: the signal still finalises at that bar's close and still requires the bar to pass scoring, so a bar that pierces the level but scores badly does not signal (a real resting stop order would have filled anyway). Fakeout rate is higher by construction.")
i_thresh     = input.int  (70,    "Min Rule Confidence",  minval = 0, maxval = 100, group = G_SIG, tooltip = "Base threshold for the 7-factor rule score. The effective threshold also includes the regime and risk-mode adjustments (shown on the dashboard).")
i_mode       = input.string("Normal", "Risk Mode", options = ["Aggressive", "Normal", "Conservative"], group = G_SIG, tooltip = "Aggressive: lower threshold, tolerates 2 soft warnings. Normal: base threshold, 1 warning. Conservative: higher threshold, zero warnings, and requires 2 consecutive closes beyond the range or a retest.")
i_retests    = input.int  (0,     "Retests Required",     minval = 0, maxval = 3, group = G_SIG, tooltip = "Entries wait for this many retests of the broken level (price wicks back to the level and closes beyond it). 0 = enter on the breakout close. Higher = fewer, later, cleaner entries.")
i_rearm      = input.bool (true,  "Re-Arm After False Breakout",       group = G_SIG, tooltip = "ON = when a signal is tagged as a false breakout (close back inside the range), that direction may signal again later in the session.")
i_max_sigs   = input.int  (2,     "Max Signals Per Session", minval = 1, maxval = 6, group = G_SIG, tooltip = "Hard cap on total entries per session — limits churn on whipsaw days where price breaks one side and then the other.")
i_fbo_min    = input.int  (40,    "False-Breakout Window (minutes)", minval = 5, maxval = 240, group = G_SIG, tooltip = "A signal is tagged as a false breakout if price closes back inside the range within this long after entry (unless TP1 was already reached). Measured in MINUTES so the window means the same thing on every chart timeframe — a bar count would silently become an all-session window on 1-hour charts and tag almost every trade.")
i_sweep_rev  = input.bool (false, "Sweep-Reversal Signals",            group = G_SIG, tooltip = "OFF by default. Fade-the-first-move entries: when a wick sweeps beyond one range edge but the bar closes back inside (liquidity sweep), a REVERSAL signal in the opposite direction can fire on a confirmed close through the range midpoint within the false-breakout window. The stop for reversal entries is the sweep extreme. Scoring and filters still apply.")
i_first_only = input.bool (false, "First Break Direction Only",        group = G_SIG, tooltip = "ON = once one side of the range has broken, the opposite direction — including Sweep-Reversal entries — is disabled for the rest of the session, by whichever side broke first. OFF = both directions stay available up to the session signal cap.")

i_ml_mode    = input.string("Advisory", "KNN Mode", options = ["Advisory", "Gate", "Off"], group = G_KNN, tooltip = "Advisory (default): the KNN vote is measured and displayed on the signal label and dashboard, but never blocks a signal — so which bars signal is fully deterministic. Gate: the vote must also clear the minimum below for a signal to fire; this suppresses signals and is only worth enabling once the library is large (see Warm-Up tooltip). Off: no KNN at all.")
i_k          = input.int  (5,     "K Neighbors",          minval = 3, maxval = 15, group = G_KNN, tooltip = "Number of nearest historical analogues that vote on each new breakout.")
i_knn_len    = input.int  (300,   "History Length",       minval = 50, maxval = 500, group = G_KNN, tooltip = "Maximum resolved breakout outcomes stored in the learning library.")
i_conf_min   = input.float(0.60,  "Min ML Vote",          minval = 0.5, maxval = 1.0, step = 0.05, group = G_KNN, tooltip = "Minimum fraction of the K neighbors that must be winners. Only enforced in Gate mode. Note the arithmetic: with K=5 this means at least 3 of 5 neighbors, which even an uninformative library would satisfy roughly 40-50% of the time — so treat Gate mode as a signal-frequency reducer, not a guarantee.")
i_out_min    = input.int  (150,   "Outcome Window (minutes)", minval = 15, maxval = 600, group = G_KNN, tooltip = "How long a recorded breakout has to resolve. Reaches the 1R target first: recorded as a win. Hits the stop first: recorded as a loss. Touches NEITHER within this window: discarded as undecided — drifts are not counted as losses, so the library's base rate reflects only decisive breakouts. In MINUTES so the learning horizon is identical on every chart timeframe.")
i_warmup     = input.int  (30,    "Warm-Up Outcomes",     minval = 5, maxval = 200, group = G_KNN, tooltip = "Until the library holds this many resolved outcomes the vote is not shown, and labels read 'learning'. Sample-size honesty: the library gains roughly one row per breakout episode, so about one per trading day — warm-up therefore needs roughly that many sessions of chart history. Your plan's bar limit sets the ceiling: a 5-minute RTH chart holds around 256 sessions on Premium but a 1-minute chart holds only about 51 (and far fewer on lower plans), so on fast timeframes the library stays small. The dashboard always shows the current library size.")
i_gate_min   = input.int  (150,   "Gate: Min Library",    minval = 50, maxval = 500, group = G_KNN, tooltip = "Gate mode does not filter anything until the library reaches this size — below it, a K-of-5 vote from a sparse 6-dimensional library would remove signals without carrying real information, so the script keeps behaving as Advisory. Raise it if you want gating to be conservative; it cannot make gating start earlier than Warm-Up.")
i_show_vote  = input.bool (false, "Show Analogue Votes On Signals", group = G_KNN, tooltip = "OFF (default): signal labels show the rule score; the library's aggregate statistics stay on the dashboard (size and base rate), where sample size makes them meaningful. ON: each signal label also shows how many of the K nearest past breakouts reached their target. A single vote of 5 neighbours moves ±20 points per neighbour, so per-signal votes are statistical context for a LARGE library (150+ records), not a per-trade prediction — leave this off until the library is big.")

i_f_trend    = input.bool (true,  "Trend Filter",                      group = G_FILT, tooltip = "Blocks longs when the directional trend score is below 35 (and shorts when above 65).")
i_f_vol      = input.bool (true,  "Volume Filter",                     group = G_FILT, tooltip = "Blocks signals when breakout-bar relative volume is below the minimum. Note: the indicator needs a symbol that provides volume data (stocks, futures, crypto).")
i_vol_min    = input.float(0.8,   "Min Relative Volume",  minval = 0.1, step = 0.1, group = G_FILT)
i_f_atr      = input.bool (true,  "ATR Filter",                        group = G_FILT, tooltip = "Blocks signals when ATR as a percent of price is below the minimum — avoids dead, low-range conditions.")
i_atr_min    = input.float(0.03,  "Min ATR % of Price",   minval = 0.0, step = 0.01, group = G_FILT)
i_f_wide     = input.bool (true,  "Wide-Range OR Filter",              group = G_FILT, tooltip = "Blocks signals when the opening range is unusually wide (vs its 10-session average or vs ATR). A wide range leaves poor reward-to-risk for breakout continuation; the dashboard shows the filtered state.")
i_news_off   = input.bool (false, "Stand Aside Today (news)",          group = G_FILT, tooltip = "Manual kill-switch for FOMC/CPI/major-news days — blocks all new signals while ON. Levels, scores and the dashboard keep updating so you can still observe.")
i_f_vwap     = input.bool (false, "VWAP Filter",                       group = G_FILT, tooltip = "ON = enforce the taught alignment rule as a hard gate: longs only when price is above session VWAP, shorts only below. OFF (default) = VWAP position stays a weighted part of the structure score instead of a veto. Ignored on symbols without volume data.")
i_blackout   = input.session("0000-0000", "Signal Blackout Window",    group = G_FILT, tooltip = "No new signals inside this window, read in the session anchor's timezone — e.g. 0955-1005 to stand aside around the 10:00 ET data releases. Leave 0000-0000 for no blackout.")

i_ema_fast   = input.int  (9,     "EMA Fast",             minval = 2, group = G_TREND)
i_ema_mid    = input.int  (21,    "EMA Mid",              minval = 2, group = G_TREND)
i_ema_slow   = input.int  (50,    "EMA Slow",             minval = 2, group = G_TREND)
i_htf        = input.timeframe("60", "Higher Timeframe",              group = G_TREND, tooltip = "Trend on this timeframe feeds the trend score. Read from CLOSED higher-timeframe bars only (no lookahead). Ignored if the chart timeframe is not below it.")
i_htf_ema    = input.int  (20,    "Higher-TF EMA Length", minval = 2, group = G_TREND)
i_swing      = input.int  (5,     "Swing Pivot Strength", minval = 2, maxval = 20, group = G_TREND, tooltip = "Bars each side to confirm a swing high/low. Confirmed pivots feed the structure score.")

i_sl_basis   = input.string("ATR", "Stop-Loss Basis", options = ["ATR", "ORB Midpoint", "ORB Opposite Side", "Breakout Candle"], group = G_RISK, tooltip = "ATR: entry -/+ ATR multiple. ORB Midpoint: middle of the range. ORB Opposite Side: the far side of the range (widest). Breakout Candle: the low/high of the entry bar (tightest).")
i_sl_mult    = input.float(1.5,   "SL ATR Multiplier",    minval = 0.5, maxval = 5.0, step = 0.25, group = G_RISK)
i_tp_method  = input.string("R Ladder", "TP Method", options = ["R Ladder", "OR Width Projection", "Dynamic (EMA)"], group = G_RISK, tooltip = "R Ladder: targets at fixed R multiples. OR Width Projection: the classic measured move — targets at 0.5x / 1.0x / 1.5x the opening-range width beyond the broken level. Dynamic (EMA): profits are booked when price closes back through the fast EMA while in profit (ATR-scaled), so exits stretch on trend days and cut when momentum fades. The ML engine always learns on the fixed 1R outcome regardless of this setting.")
i_tp2_r      = input.float(2.0,   "TP2 (R multiple)",     minval = 1.25, maxval = 10.0, step = 0.25, group = G_RISK, tooltip = "TP1 is always 1R (and is what the ML engine learns on). TP2 and TP3 are R-multiple extensions. Used by the R Ladder method.")
i_tp3_r      = input.float(3.0,   "TP3 (R multiple)",     minval = 1.5, maxval = 15.0, step = 0.25, group = G_RISK)
i_adapt_sl   = input.bool (true,  "Adaptive SL (BE after TP1)",        group = G_RISK, tooltip = "ON = after TP1 is touched, the suggested stop moves to the entry price (break-even).")
i_amb        = input.string("Stop first", "Same-Bar TP+SL Resolution", options = ["Stop first", "Target first"], group = G_RISK, tooltip = "When one bar's range covers BOTH the target and the stop, bar data cannot tell you which came first. Stop first (default) assumes the adverse fill — the conservative reading, and the same convention the KNN engine uses to label its stored outcomes, so the chart and the learning agree. Target first assumes the favourable fill and will make results look better than they were.")
i_trail_len  = input.int  (10,    "Trail Lookback (bars)", minval = 2, group = G_RISK)
i_trail_mult = input.float(3.0,   "Trail ATR Multiplier", minval = 0.5, step = 0.25, group = G_RISK, tooltip = "Chandelier-style trailing suggestion plotted while a trade plan is active.")

i_acct       = input.float(10000, "Account Size ($)",     minval = 100, group = G_RISK, tooltip = "Used only for the dashboard position-size readout — nothing is traded.")
i_risk_pct   = input.float(0.5,   "Risk % Per Trade",     minval = 0.05, maxval = 5.0, step = 0.05, group = G_RISK, tooltip = "The dashboard converts the current Risk/Unit into a suggested position size: floor(account x risk% / dollar-risk-per-unit). Futures use the contract point value; stocks and crypto use 1.")
i_dash_on    = input.bool (true,  "Show Dashboard",                    group = G_DISP)
i_dash_mode  = input.string("Compact", "Dashboard Detail", options = ["Full", "Compact"], group = G_DISP, tooltip = "Compact (default) shows the 9 rows you actually trade from — session, regime, ML state, the range on one line, bias, confidence, risk and the live trade plan. Full adds the seven factor meters plus gap, threshold, trade quality, position size, plan-outcome counts and the active rule set. Compact is the default because the full table covers a large slice of a small chart.")
i_dash_pos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_DISP)
i_dash_size  = input.string("Small", "Dashboard Text Size", options = ["Small", "Normal"], group = G_DISP)
i_show_box   = input.bool (true,  "Shade Opening Range",               group = G_DISP)
i_show_zone  = input.bool (true,  "Show Arming Labels",                group = G_DISP, tooltip = "A small text tag on the ORB High/Low line reporting the live score once a side is close to firing: WATCH within 10 points of the effective threshold, ARMED at or above it. Nothing is shown while a side is inactive.")
i_show_pt    = input.bool (false, "Show Range-Multiple Targets",       group = G_DISP, tooltip = "The classic ORB measured-move levels: 50% and 100% of the range width projected beyond each edge. Reference targets for manual trade management, independent of the signal engine's TP ladder. OFF by default to keep the chart to the core range levels; when ON, the levels draw for the session window on roughly the last 25 sessions (older ones age out of the line budget).")
i_show_ptx   = input.bool (false, "Extended Targets (150/200%)",       group = G_DISP)
i_show_flow  = input.bool (true,  "Show Breakout/Retest Flow Marks",   group = G_DISP, tooltip = "Marks the classic manual workflow: 'BO' where price first closed beyond the range, and 'RT xN' — a single counter that slides to the latest retest and shows how many times the broken level has been retested. A retest = price returns to the broken level and closes back beyond it; more retests usually means a level being defended. Context only — entry labels still require the full signal criteria.")
i_show_pm    = input.bool (false, "Show Premarket High/Low",           group = G_DISP, tooltip = "Premarket levels always feed the structure score automatically; enable this to also plot them. Requires extended-hours data on the chart.")
i_show_ema   = input.bool (false, "Show EMAs",                         group = G_DISP)
i_show_vwap  = input.bool (false, "Show Session VWAP",                 group = G_DISP)
i_bg_trend   = input.bool (false, "Trend Background Tint",             group = G_DISP, tooltip = "Off by default. It tints whole stretches of bars by trend direction, which duplicates the Trend score already shown on the dashboard and, on futures, layers on top of TradingView's own extended-hours shading. Enable it only if you prefer the trend read on the chart rather than in the panel.")
i_bg_sess    = input.bool (true,  "Opening-Range Window Tint",         group = G_DISP)
i_zen        = input.bool (false, "Zen Mode",                          group = G_DISP, tooltip = "Hide all visuals except the range levels and signal labels — clean look for screenshots.")
i_c_bull     = input.color(color.new(#2962FF, 0), "Bull Colour",     group = G_DISP, tooltip = "Applied to everything on the long side: the ORB high, the long breakout zone, long signals, take-profit levels and the bullish trend tint.")
i_c_bear     = input.color(color.new(#FF6D00, 0), "Bear Colour",     group = G_DISP, tooltip = "Applied to everything on the short side: the ORB low, the short breakout zone, short signals, the suggested stop and the bearish trend tint.")
i_c_range    = input.color(color.new(color.gray, 0), "Neutral / Range", group = G_DISP, tooltip = "Applied to direction-neutral elements: the opening-range box and midpoint, premarket levels, the entry line and session-exit markers.")

// ═══════════════════════════════════════════════════════════════
// GUARDS & HELPERS
// ═══════════════════════════════════════════════════════════════
if barstate.isfirst and timeframe.isdwm
    runtime.error("ORB AI [PickMyTrade] works on intraday chart timeframes only — an opening range cannot be measured from daily or higher bars.")

// If the chart timeframe is coarser than the selected duration, the range auto-expands to
// one full chart bar instead of erroring out to a blank chart — the dashboard notes it.
chartMins = math.ceil(timeframe.in_seconds() / 60.0)
effOrMin  = math.max(i_or_min, chartMins)

// Time-based windows converted to this chart's bar count, so every duration in the script
// means the same wall-clock span on a 1-minute chart as on a 1-hour chart.
fboBars   = math.max(1, math.round(i_fbo_min / chartMins))
outBars   = math.max(2, math.round(i_out_min / chartMins))

f_clamp(x) => math.max(0.0, math.min(100.0, x))

// JSON-safe number for webhook payloads: an absent level must serialise as null, never
// as 0, so an automation consumer cannot mistake "no target" for a price of zero.
f_jnum(float v) => na(v) ? "null" : str.tostring(v, format.mintick)

// Stepwise quality of breakout distance in ATRs: rewards decisive-but-not-overextended closes.
f_distQ(d) => d <= 0 ? 0.0 : d < 0.1 ? 55.0 : d <= 0.8 ? 90.0 : d <= 1.5 ? 65.0 : 30.0

f_pos(p) => p == "Top Left" ? position.top_left : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.top_right

f_meter(sc) =>
    int blocks = math.round(f_clamp(nz(sc, 0.0)) / 10)
    string m = ""
    for i = 1 to 10
        m := m + (i <= blocks ? "█" : "░")
    m

// ═══════════════════════════════════════════════════════════════
// BASE CALCULATIONS (all computed every bar)
// ═══════════════════════════════════════════════════════════════
atr       = ta.atr(14)
atrAvg    = ta.sma(atr, 20)
atrRatio  = na(atrAvg) or atrAvg == 0 ? 1.0 : atr / atrAvg
atrPct    = close > 0 ? atr / close * 100 : 0.0

emaFastV  = ta.ema(close, i_ema_fast)
emaMidV   = ta.ema(close, i_ema_mid)
emaSlowV  = ta.ema(close, i_ema_slow)
[diP, diM, adxV] = ta.dmi(14, 14)
rsiV      = ta.rsi(close, 14)
[macdL, sigL, histL] = ta.macd(close, 12, 26, 9)

volSma    = ta.sma(volume, 20)
hasVol    = not na(volSma) and volSma > 0
relVolRaw = hasVol ? volume / volSma : 1.0
volPrRaw  = ta.percentrank(volume, 20)
obvV      = ta.obv
obvEma    = ta.ema(obvV, 20)
vwapV     = ta.vwap

bbBasis   = ta.sma(close, 20)
bbSd      = ta.stdev(close, 20)
bbw       = na(bbBasis) or bbBasis == 0 ? 0.0 : 4 * bbSd / bbBasis
bbwAvg    = ta.sma(bbw, 20)
barRange  = high - low
rangeAvg  = ta.sma(barRange, 20)

chopSumTr = math.sum(ta.tr(true), 14)
chopHH    = ta.highest(high, 14)
chopLL    = ta.lowest(low, 14)
chopV     = na(chopHH) or chopHH - chopLL <= 0 ? 50.0 : 100 * math.log10(chopSumTr / (chopHH - chopLL)) / math.log10(14)

// Higher-timeframe trend: closed HTF bars only ([1] + lookahead_off = non-repainting).
htfOk = timeframe.in_seconds() < timeframe.in_seconds(i_htf)
[htfCloseV, htfEmaV] = request.security(syminfo.tickerid, i_htf, [close[1], ta.ema(close, i_htf_ema)[1]], lookahead = barmerge.lookahead_off)
htfBull = htfOk and not na(htfCloseV) and not na(htfEmaV) and htfCloseV > htfEmaV
htfBear = htfOk and not na(htfCloseV) and not na(htfEmaV) and htfCloseV < htfEmaV

// Confirmed swing pivots (acted on only after i_swing bars — no repaint).
phV = ta.pivothigh(high, i_swing, i_swing)
plV = ta.pivotlow(low, i_swing, i_swing)
var float lastPH = na
var float lastPL = na
if not na(phV)
    lastPH := phV
if not na(plV)
    lastPL := plV

// Previous-day high/low tracked locally (no security call needed).
dayChange = timeframe.change("D")
var float pdh = na
var float pdl = na
var float dHi = na
var float dLo = na
if dayChange
    pdh := dHi
    pdl := dLo
    dHi := high
    dLo := low
else
    dHi := na(dHi) ? high : math.max(dHi, high)
    dLo := na(dLo) ? low : math.min(dLo, low)

// Premarket high/low (extended-hours charts only; na on RTH-only feeds — harmless).
var float pmHi = na
var float pmLo = na
if dayChange
    pmHi := na
    pmLo := na
if session.ispremarket
    pmHi := na(pmHi) ? high : math.max(pmHi, high)
    pmLo := na(pmLo) ? low : math.min(pmLo, low)

// ═══════════════════════════════════════════════════════════════
// OPENING RANGE STATE MACHINE
// ═══════════════════════════════════════════════════════════════
// All session tests run unconditionally every bar; the anchor mode just selects one.
// Every preset window carries an explicit IANA timezone — session strings without one are
// read in the exchange's clock (Chicago on CME), which anchors a "0930" range at 10:30 ET.
inNYSess     = not na(time(timeframe.period, "0930-1600", "America/New_York"))
inNYDataSess = not na(time(timeframe.period, "0830-1600", "America/New_York"))
inLdnSess    = not na(time(timeframe.period, "0800-1630", "Europe/London"))
inTokSess    = not na(time(timeframe.period, "0900-1530", "Asia/Tokyo"))
inCustSess   = not na(time(timeframe.period, i_custom_ses, i_custom_tz))
inAnchorSess = i_anchor == "New York 09:30" ? inNYSess : i_anchor == "New York 08:30 (data)" ? inNYDataSess : i_anchor == "London 08:00" ? inLdnSess : i_anchor == "Tokyo 09:00" ? inTokSess : i_anchor == "Custom" ? inCustSess : false

// A new session starts either by ENTERING the window (24-hour feeds: futures, crypto,
// extended-hours charts) or by the anchor-timezone DATE rolling over. The second edge is
// essential: on a regular-hours stock chart every bar already sits inside 09:30-16:00, so
// the enter-the-window edge never occurs and the range would never form at all.
// A custom window that crosses midnight (start > end, e.g. 1800-0300) must not be split by
// the date rollover — such windows always leave out-of-session bars, so the first edge
// already covers them.
// Exchange Session anchors to the SYMBOL's own clock, so every other time window read in
// the anchor's timezone (the blackout below) must follow it there — falling through to New
// York would read a blackout typed in exchange time an hour or more off on any non-US feed.
tzAnchor     = i_anchor == "Custom" ? i_custom_tz : i_anchor == "London 08:00" ? "Europe/London" : i_anchor == "Tokyo 09:00" ? "Asia/Tokyo" : i_anchor == "Exchange Session" ? syminfo.timezone : "America/New_York"
newAnchorDay = dayofmonth(time, tzAnchor) != dayofmonth(nz(time[1], time), tzAnchor)
custCrossMid = i_anchor == "Custom" and str.length(i_custom_ses) >= 9 and nz(str.tonumber(str.substring(i_custom_ses, 0, 4)), 0) > nz(str.tonumber(str.substring(i_custom_ses, 5, 9)), 0)
sessFirstBar = i_anchor == "Exchange Session" ? session.isfirstbar_regular : inAnchorSess and (not inAnchorSess[1] or (newAnchorDay and not custCrossMid))

// Session-anchored gap context, measured at whatever session anchor the ORB itself uses.
// Under the default New York anchor this is the 09:30 ET gap vs the previous NY session's
// last close — on stocks AND on CME futures alike. Under Exchange Session on futures the
// anchor is the Globex open, where the measured gap is naturally near zero.
inSessNow = i_anchor == "Exchange Session" ? session.ismarket : inAnchorSess
var float sessOpen = na
var float prevSessClose = na
var float lastSessClose = na
if sessFirstBar
    prevSessClose := lastSessClose
    sessOpen := open
if inSessNow
    lastSessClose := close

var float orbHigh = na
var float orbLow = na
var int   sessStartTime = na
var int   orbEndBar = na
var bool  orbLocked = false
var bool  longUsed = false
var bool  shortUsed = false
var int   sigCount = 0
// All-history outcome counters for the dashboard — factual event counts, no P&L claims.
var int   planCount = 0
var int   tp1Count = 0
var int   fboCount = 0
var bool  longBrokeOnce = false
var bool  shortBrokeOnce = false
var int   longRetests = 0
var int   shortRetests = 0
var bool  longInRetest = false
var bool  shortInRetest = false
var bool  sweptHigh = false
var bool  sweptLow = false
var float sweepHiPx = na
var float sweepLoPx = na
var int   sweepHiBar = na
var int   sweepLoBar = na
var int   longFirstBreakBar = na
var int   shortFirstBreakBar = na
// True when the active plan was filled by an Intrabar Touch whose bar closed back INSIDE
// the range — the canonical touch-mode fakeout, which the close[1]-based FBO test misses.
var bool  longTouchInside = false
var bool  shortTouchInside = false
var int   longSigBar = na
var int   shortSigBar = na
var box   orBoxCur = na
var box   orBoxBot = na
var label orBoxTopLbl = na
var label orBoxBotLbl = na
var float[] orWidthHist = array.new_float()

// Active trade-plan state (display + management only — ML learns from its own queue).
var int   activeDir = 0
var int   tradeStartBar = na
var float entryPx = na
var float slDynPx = na
var float tp1Px = na
var float tp2Px = na
var float tp3Px = na
var bool  tp1Hit = false
var bool  tp2Hit = false
var bool  tp3Hit = false

orMs = effOrMin * 60 * 1000

// A plan still open at the session rollover is formally closed (Flux-style session exit)
// so the alert stream never silently loses a trade.
bool sessExitEvt = false
if sessFirstBar
    sessExitEvt := activeDir != 0
    sessStartTime := time
    orbHigh := high
    orbLow := low
    orbLocked := false
    orbEndBar := na
    longUsed := false
    shortUsed := false
    sigCount := 0
    longBrokeOnce := false
    shortBrokeOnce := false
    longRetests := 0
    shortRetests := 0
    longInRetest := false
    shortInRetest := false
    sweptHigh := false
    sweptLow := false
    sweepHiPx := na
    sweepLoPx := na
    sweepHiBar := na
    sweepLoBar := na
    longTouchInside := false
    shortTouchInside := false
    longFirstBreakBar := na
    shortFirstBreakBar := na
    longSigBar := na
    shortSigBar := na
    activeDir := 0
    tradeStartBar := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

inOR = not na(sessStartTime) and not orbLocked and time - sessStartTime < orMs
if inOR and not sessFirstBar
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

lockNow = not orbLocked and not na(sessStartTime) and time - sessStartTime >= orMs and not na(orbHigh)
if lockNow
    orbLocked := true
    orbEndBar := bar_index
    array.push(orWidthHist, orbHigh - orbLow)
    if array.size(orWidthHist) > 10
        array.shift(orWidthHist)
    if i_show_box and not i_zen
        float _mid = (orbHigh + orbLow) / 2
        orBoxCur := box.new(
             left         = sessStartTime,
             top          = orbHigh,
             right        = time,
             bottom       = _mid,
             xloc         = xloc.bar_time,
             border_color = color.new(i_c_bull, 30),
             border_width = 1,
             bgcolor      = color.new(i_c_bull, 83))
        orBoxBot := box.new(
             left         = sessStartTime,
             top          = _mid,
             right        = time,
             bottom       = orbLow,
             xloc         = xloc.bar_time,
             border_color = color.new(i_c_bear, 30),
             border_width = 1,
             bgcolor      = color.new(i_c_bear, 83))
        label.delete(orBoxTopLbl)
        label.delete(orBoxBotLbl)
        orBoxTopLbl := label.new(bar_index, (orbHigh + _mid) / 2,
             "▲  Long Zone  ·  " + str.tostring(orbHigh, format.mintick),
             xloc=xloc.bar_index, style=label.style_label_right,
             color=color.new(i_c_bull, 75), textcolor=color.new(color.white, 0),
             size=size.small)
        orBoxBotLbl := label.new(bar_index, (_mid + orbLow) / 2,
             "▼  Short Zone  ·  " + str.tostring(orbLow, format.mintick),
             xloc=xloc.bar_index, style=label.style_label_right,
             color=color.new(i_c_bear, 75), textcolor=color.new(color.white, 0),
             size=size.small)

orbMid   = orbLocked ? (orbHigh + orbLow) / 2 : na
orbWidth = orbLocked ? orbHigh - orbLow : na
minsFromOpen = na(sessStartTime) ? na : (time - sessStartTime) / 60000.0
lateBlock = not na(minsFromOpen) and minsFromOpen > i_late_min
barsFromLock = orbLocked and not na(orbEndBar) ? bar_index - orbEndBar : 0

avgORW = array.size(orWidthHist) >= 3 ? array.avg(orWidthHist) : na
isBreakoutDay = orbLocked and not na(avgORW) and avgORW > 0 and orbWidth < 0.65 * avgORW
wideOR = orbLocked and ((not na(avgORW) and avgORW > 0 and orbWidth > 1.75 * avgORW) or (atr > 0 and orbWidth > 2.5 * atr))

// Session-scoped breakout micro-state (sweeps, first breaks, retest counting, consecutive closes).
// The sweep extreme and bar are captured for the optional sweep-reversal entries: the
// extreme becomes the reversal stop, the bar starts the reversal arming window.
if orbLocked and high > orbHigh and close <= orbHigh and not sweptHigh
    sweptHigh := true
    sweepHiPx := high
    sweepHiBar := bar_index
if orbLocked and low < orbLow and close >= orbLow and not sweptLow
    sweptLow := true
    sweepLoPx := low
    sweepLoBar := bar_index
if orbLocked and close > orbHigh and not longBrokeOnce
    longBrokeOnce := true
    longFirstBreakBar := bar_index
if orbLocked and close < orbLow and not shortBrokeOnce
    shortBrokeOnce := true
    shortFirstBreakBar := bar_index
// One increment per retest EPISODE, not per qualifying bar. The latch clears only once
// price has left the tolerance band again, so a pullback that hovers at the broken level
// for several bars counts once — otherwise "Retests Required" would be satisfied by a
// single slow pullback and the retest alert would repeat every bar.
if longInRetest and (na(atr) or na(orbHigh) or low > orbHigh + 0.1 * atr)
    longInRetest := false
if shortInRetest and (na(atr) or na(orbLow) or high < orbLow - 0.1 * atr)
    shortInRetest := false
if not longInRetest and longBrokeOnce and not na(longFirstBreakBar) and bar_index > longFirstBreakBar and close > orbHigh and low <= orbHigh + 0.1 * atr
    longRetests := longRetests + 1
    longInRetest := true
if not shortInRetest and shortBrokeOnce and not na(shortFirstBreakBar) and bar_index > shortFirstBreakBar and close < orbLow and high >= orbLow - 0.1 * atr
    shortRetests := shortRetests + 1
    shortInRetest := true
longRetestOK  = longRetests >= 1
shortRetestOK = shortRetests >= 1

var int longConsec = 0
var int shortConsec = 0
longConsec := orbLocked and close > orbHigh ? longConsec + 1 : 0
shortConsec := orbLocked and close < orbLow ? shortConsec + 1 : 0

// ═══════════════════════════════════════════════════════════════
// 7-FACTOR RULE SCORES (0-100)
// ═══════════════════════════════════════════════════════════════
alignBull  = emaFastV > emaMidV and emaMidV > emaSlowV
alignBear  = emaFastV < emaMidV and emaMidV < emaSlowV
alignS     = alignBull ? 100.0 : alignBear ? 0.0 : 50.0
adxStr     = math.min(100.0, nz(adxV, 0.0) * 2.2)
adxS       = 50.0 + (nz(diP, 0.0) >= nz(diM, 0.0) ? 1.0 : -1.0) * adxStr / 2.0
htfS       = htfBull ? 100.0 : htfBear ? 0.0 : 50.0
slopeNorm  = atr > 0 ? (emaFastV - nz(emaFastV[3], emaFastV)) / atr : 0.0
slopeS     = f_clamp(50.0 + slopeNorm * 60.0)
trendScore = 0.35 * alignS + 0.25 * adxS + 0.25 * htfS + 0.15 * slopeS

rsiAccel   = rsiV - nz(rsiV[3], rsiV)
rsiS       = f_clamp(50.0 + (nz(rsiV, 50.0) - 50.0) * 1.1 + rsiAccel * 2.0)
histNorm   = atr > 0 ? nz(histL, 0.0) / atr : 0.0
histExpand = math.abs(nz(histL, 0.0)) > math.abs(nz(histL[1], 0.0))
histS      = f_clamp(50.0 + histNorm * 100.0 + (histExpand ? (nz(histL, 0.0) > 0 ? 10.0 : -10.0) : 0.0))
rocNorm    = atr > 0 ? (close - nz(close[10], close)) / atr : 0.0
rocS       = f_clamp(50.0 + rocNorm * 15.0)
bodyNorm   = atr > 0 ? (close - open) / atr : 0.0
bodyS      = f_clamp(50.0 + bodyNorm * 35.0)
momScore   = 0.3 * rsiS + 0.3 * histS + 0.2 * rocS + 0.2 * bodyS

relVolS    = f_clamp((relVolRaw - 0.5) * 66.7)
volSpike   = relVolRaw >= 1.5
volPrS     = hasVol ? nz(volPrRaw, 50.0) : 50.0
volBase    = 0.45 * relVolS + 0.35 * volPrS + 0.2 * (volSpike ? 100.0 : 40.0)
obvBull    = hasVol and not na(obvEma) and obvV > obvEma
obvBear    = hasVol and not na(obvEma) and obvV < obvEma
volLongS   = hasVol ? f_clamp(0.8 * volBase + 0.2 * (obvBull ? 90.0 : 25.0)) : 50.0
volShortS  = hasVol ? f_clamp(0.8 * volBase + 0.2 * (obvBear ? 90.0 : 25.0)) : 50.0

atrExpS    = f_clamp((atrRatio - 0.6) * 100.0)
bbwExpS    = na(bbwAvg) or bbwAvg == 0 ? 50.0 : f_clamp((bbw / bbwAvg - 0.6) * 100.0)
rngExpS    = na(rangeAvg) or rangeAvg == 0 ? 50.0 : f_clamp((barRange / rangeAvg - 0.5) * 66.7)
volatScore = 0.4 * atrExpS + 0.3 * bbwExpS + 0.3 * rngExpS

vwapLongS  = hasVol and not na(vwapV) ? (close > vwapV ? 75.0 : 25.0) : 50.0
vwapShortS = hasVol and not na(vwapV) ? (close < vwapV ? 75.0 : 25.0) : 50.0

float resAbove = na
if not na(pdh) and pdh > close
    resAbove := pdh
if not na(lastPH) and lastPH > close and (na(resAbove) or lastPH < resAbove)
    resAbove := lastPH
if not na(pmHi) and pmHi > close and (na(resAbove) or pmHi < resAbove)
    resAbove := pmHi
float supBelow = na
if not na(pdl) and pdl < close
    supBelow := pdl
if not na(lastPL) and lastPL < close and (na(supBelow) or lastPL > supBelow)
    supBelow := lastPL
if not na(pmLo) and pmLo < close and (na(supBelow) or pmLo > supBelow)
    supBelow := pmLo

roomLongAtr  = na(resAbove) or atr <= 0 ? na : (resAbove - close) / atr
roomShortAtr = na(supBelow) or atr <= 0 ? na : (close - supBelow) / atr
roomLongS    = na(roomLongAtr) ? 90.0 : roomLongAtr >= 1.5 ? 85.0 : roomLongAtr >= 0.8 ? 65.0 : roomLongAtr >= 0.4 ? 45.0 : 25.0
roomShortS   = na(roomShortAtr) ? 90.0 : roomShortAtr >= 1.5 ? 85.0 : roomShortAtr >= 0.8 ? 65.0 : roomShortAtr >= 0.4 ? 45.0 : 25.0
aboveSwingS  = not na(lastPH) and close > lastPH ? 85.0 : 40.0
belowSwingS  = not na(lastPL) and close < lastPL ? 85.0 : 40.0

// Gap context: gap-and-go alignment (open beyond the previous day's extreme) strengthens
// the breakout side; a strong gap against the trade direction weakens it.
gapAtr       = na(prevSessClose) or na(sessOpen) or atr <= 0 ? 0.0 : (sessOpen - prevSessClose) / atr
openAbovePDH = not na(pdh) and not na(sessOpen) and sessOpen > pdh
openBelowPDL = not na(pdl) and not na(sessOpen) and sessOpen < pdl
gapLongS     = openAbovePDH ? 90.0 : gapAtr >= 0.3 ? 70.0 : gapAtr <= -0.3 ? 25.0 : 50.0
gapShortS    = openBelowPDL ? 90.0 : gapAtr <= -0.3 ? 70.0 : gapAtr >= 0.3 ? 25.0 : 50.0

structLongS  = 0.30 * vwapLongS + 0.40 * roomLongS + 0.15 * aboveSwingS + 0.15 * gapLongS
structShortS = 0.30 * vwapShortS + 0.40 * roomShortS + 0.15 * belowSwingS + 0.15 * gapShortS

bodyRatio  = barRange > 0 ? math.abs(close - open) / barRange : 0.0
bodyRatioS = f_clamp(bodyRatio * 125.0)
// Scored in minutes since the range locked, not bars, so "a fast breakout" means the same
// elapsed time regardless of chart timeframe.
minsFromLock = barsFromLock * chartMins
speedS     = minsFromLock <= 15 ? 90.0 : minsFromLock <= 50 ? 75.0 : minsFromLock <= 100 ? 55.0 : 35.0
distLongS  = atr > 0 and orbLocked ? f_distQ((close - orbHigh) / atr) : 0.0
distShortS = atr > 0 and orbLocked ? f_distQ((orbLow - close) / atr) : 0.0
consecLS   = longConsec >= 3 ? 90.0 : longConsec == 2 ? 75.0 : longConsec == 1 ? 55.0 : 0.0
consecSS   = shortConsec >= 3 ? 90.0 : shortConsec == 2 ? 75.0 : shortConsec == 1 ? 55.0 : 0.0
qualLongS  = orbLocked and close > orbHigh ? f_clamp(0.25 * distLongS + 0.25 * bodyRatioS + 0.20 * consecLS + 0.15 * speedS + 0.15 * (longRetestOK ? 90.0 : 45.0)) : 50.0
qualShortS = orbLocked and close < orbLow ? f_clamp(0.25 * distShortS + 0.25 * bodyRatioS + 0.20 * consecSS + 0.15 * speedS + 0.15 * (shortRetestOK ? 90.0 : 45.0)) : 50.0

hh20 = ta.highest(high, 20)
ll20 = ta.lowest(low, 20)
eqHighs = not na(pdh) and atr > 0 and math.abs(hh20 - pdh) <= 0.15 * atr
eqLows  = not na(pdl) and atr > 0 and math.abs(ll20 - pdl) <= 0.15 * atr
liqLongS  = f_clamp(50.0 + (sweptLow ? 25.0 : 0.0) + (eqHighs ? 10.0 : 0.0) - (sweptHigh ? 12.0 : 0.0))
liqShortS = f_clamp(50.0 + (sweptHigh ? 25.0 : 0.0) + (eqLows ? 10.0 : 0.0) - (sweptLow ? 12.0 : 0.0))

// ═══════════════════════════════════════════════════════════════
// MARKET REGIME → adaptive weights & threshold
// ═══════════════════════════════════════════════════════════════
string regime = "Range"
if nz(adxV, 0.0) >= 32 and atrRatio >= 1.05
    regime := "Strong Trend"
else if nz(adxV, 0.0) >= 25
    regime := "Trending"
else if chopV >= 61.8
    regime := "Choppy"
else if atrRatio >= 1.35
    regime := "High Volatility"
else if atrRatio <= 0.7
    regime := "Low Volatility"
else if nz(adxV, 0.0) >= 18
    regime := "Weak Trend"

regimeAdj = switch regime
    "Strong Trend" => -6.0
    "Trending" => -3.0
    "Weak Trend" => 2.0
    "Range" => 4.0
    "Choppy" => 8.0
    "High Volatility" => 3.0
    "Low Volatility" => 5.0
    => 0.0
if isBreakoutDay
    regimeAdj := regimeAdj - 4.0

float wT = 0.20
float wM = 0.18
float wVm = 0.15
float wVt = 0.10
float wS = 0.12
float wQ = 0.15
float wL = 0.10
if regime == "Strong Trend" or regime == "Trending"
    wT := wT + 0.06
    wQ := wQ - 0.03
    wL := wL - 0.03
if regime == "Range" or regime == "Choppy"
    wT := wT - 0.06
    wQ := wQ + 0.04
    wL := wL + 0.02
wSum = wT + wM + wVm + wVt + wS + wQ + wL

modeAdj   = i_mode == "Aggressive" ? -8.0 : i_mode == "Conservative" ? 7.0 : 0.0
maxVetoes = i_mode == "Aggressive" ? 2 : i_mode == "Normal" ? 1 : 0
effThresh = f_clamp(i_thresh + modeAdj + regimeAdj)

confLong  = f_clamp((wT * trendScore + wM * momScore + wVm * volLongS + wVt * volatScore + wS * structLongS + wQ * qualLongS + wL * liqLongS) / wSum)
confShort = f_clamp((wT * (100.0 - trendScore) + wM * (100.0 - momScore) + wVm * volShortS + wVt * volatScore + wS * structShortS + wQ * qualShortS + wL * liqShortS) / wSum)

// ═══════════════════════════════════════════════════════════════
// VETOES & HARD FILTERS
// ═══════════════════════════════════════════════════════════════
upWickRatio = barRange > 0 ? (high - math.max(close, open)) / barRange : 0.0
dnWickRatio = barRange > 0 ? (math.min(close, open) - low) / barRange : 0.0

vetoLongWick  = upWickRatio > 0.55
vetoLongMom   = nz(histL, 0.0) < nz(histL[1], 0.0) and nz(histL[1], 0.0) < nz(histL[2], 0.0)
vetoLongExt   = atr > 0 and (close - emaFastV) / atr > 2.5
vetoLongRes   = not na(resAbove) and atr > 0 and resAbove - close < 0.5 * atr
longVetoCount = (vetoLongWick ? 1 : 0) + (vetoLongMom ? 1 : 0) + (vetoLongExt ? 1 : 0) + (vetoLongRes ? 1 : 0)

vetoShortWick  = dnWickRatio > 0.55
vetoShortMom   = nz(histL, 0.0) > nz(histL[1], 0.0) and nz(histL[1], 0.0) > nz(histL[2], 0.0)
vetoShortExt   = atr > 0 and (emaFastV - close) / atr > 2.5
vetoShortSup   = not na(supBelow) and atr > 0 and close - supBelow < 0.5 * atr
shortVetoCount = (vetoShortWick ? 1 : 0) + (vetoShortMom ? 1 : 0) + (vetoShortExt ? 1 : 0) + (vetoShortSup ? 1 : 0)

hardBlockAtr   = i_f_atr and atrPct < i_atr_min
hardBlockVol   = i_f_vol and hasVol and relVolRaw < i_vol_min
hardBlockTrndL = i_f_trend and trendScore < 35
hardBlockTrndS = i_f_trend and trendScore > 65
hardBlockVwapL = i_f_vwap and hasVol and not na(vwapV) and close < vwapV
hardBlockVwapS = i_f_vwap and hasVol and not na(vwapV) and close > vwapV

// ═══════════════════════════════════════════════════════════════
// KNN · LORENTZIAN ML ENGINE
//  Library: resolved outcomes of past qualified breakouts.
//  Pending: candidates waiting for their outcome (TP1 vs SL),
//  resolved bar-by-bar with the stop checked first (conservative).
// ═══════════════════════════════════════════════════════════════
var float[] h_f1  = array.new_float(0)
var float[] h_f2  = array.new_float(0)
var float[] h_f3  = array.new_float(0)
var float[] h_f4  = array.new_float(0)
var float[] h_f5  = array.new_float(0)
var float[] h_f6  = array.new_float(0)
var int[]   h_lbl = array.new_int(0)

var int[]   p_dir = array.new_int(0)
var int[]   p_bar = array.new_int(0)
var float[] p_tp  = array.new_float(0)
var float[] p_sl  = array.new_float(0)
var float[] p_f1  = array.new_float(0)
var float[] p_f2  = array.new_float(0)
var float[] p_f3  = array.new_float(0)
var float[] p_f4  = array.new_float(0)
var float[] p_f5  = array.new_float(0)
var float[] p_f6  = array.new_float(0)

// Resolve pending candidates against this bar (before any new candidate is added).
// Note: Pine's `by` step is always a positive magnitude — direction (here, descending,
// since we remove-while-iterating) is inferred automatically from start > end.
if array.size(p_bar) > 0
    for i = array.size(p_bar) - 1 to 0 by 1
        pDir = array.get(p_dir, i)
        pTp  = array.get(p_tp, i)
        pSl  = array.get(p_sl, i)
        pBar = array.get(p_bar, i)
        int  lbl  = -1
        bool drop = false
        if bar_index > pBar
            hitSL = pDir == 1 ? low <= pSl : high >= pSl
            hitTP = pDir == 1 ? high >= pTp : low <= pTp
            if hitSL
                lbl := 0
            else if hitTP
                lbl := 1
            else if bar_index - pBar >= outBars
                // Timed out with NEITHER level touched: genuinely undecided. Discarded,
                // not counted as a loss — counting drifts as losses deflated the library
                // base rate and made every displayed vote read far more bearish than the
                // decisive evidence supports. Only target-or-stop resolutions teach.
                drop := true
        if lbl >= 0
            array.push(h_f1, array.get(p_f1, i))
            array.push(h_f2, array.get(p_f2, i))
            array.push(h_f3, array.get(p_f3, i))
            array.push(h_f4, array.get(p_f4, i))
            array.push(h_f5, array.get(p_f5, i))
            array.push(h_f6, array.get(p_f6, i))
            array.push(h_lbl, lbl)
            if array.size(h_lbl) > i_knn_len
                array.shift(h_f1)
                array.shift(h_f2)
                array.shift(h_f3)
                array.shift(h_f4)
                array.shift(h_f5)
                array.shift(h_f6)
                array.shift(h_lbl)
        if lbl >= 0 or drop
            array.remove(p_dir, i)
            array.remove(p_bar, i)
            array.remove(p_tp, i)
            array.remove(p_sl, i)
            array.remove(p_f1, i)
            array.remove(p_f2, i)
            array.remove(p_f3, i)
            array.remove(p_f4, i)
            array.remove(p_f5, i)
            array.remove(p_f6, i)

// Lorentzian distance over the 6-feature fingerprint.
f_lor(a1, a2, b1, b2, c1, c2, d1, d2, e1, e2, g1, g2) => math.log(1.0 + math.abs(a1 - a2)) + math.log(1.0 + math.abs(b1 - b2)) + math.log(1.0 + math.abs(c1 - c2)) + math.log(1.0 + math.abs(d1 - d2)) + math.log(1.0 + math.abs(e1 - e2)) + math.log(1.0 + math.abs(g1 - g2))

// Vote of the K nearest resolved breakouts to the given fingerprint.
f_knn(q1, q2, q3, q4, q5, q6) =>
    n = array.size(h_lbl)
    if n < i_k
        0.0
    else
        tmp_d = array.new_float(0)
        tmp_l = array.copy(h_lbl)
        for j = 0 to n - 1
            d = f_lor(q1, array.get(h_f1, j), q2, array.get(h_f2, j), q3, array.get(h_f3, j), q4, array.get(h_f4, j), q5, array.get(h_f5, j), q6, array.get(h_f6, j))
            array.push(tmp_d, d)
        int wins = 0
        int total = 0
        kUse = math.min(i_k, n)
        for _ = 1 to kUse
            int minI = 0
            float minV = array.get(tmp_d, 0)
            if array.size(tmp_d) > 1
                for j = 1 to array.size(tmp_d) - 1
                    if array.get(tmp_d, j) < minV
                        minV := array.get(tmp_d, j)
                        minI := j
            wins := wins + array.get(tmp_l, minI)
            total := total + 1
            array.remove(tmp_d, minI)
            array.remove(tmp_l, minI)
        total > 0 ? wins * 1.0 / total : 0.0

mlLib    = array.size(h_lbl)
// Library base rate, computed globally: a vote only means something RELATIVE to this.
// With a base of ~35%, "2/5 analogues" is neutral, not bearish — so every place the vote
// is shown, the base is shown beside it.
basePctG = mlLib > 0 ? math.round(array.sum(h_lbl) * 100.0 / mlLib) : 0
mlOn     = i_ml_mode != "Off"
mlGate   = i_ml_mode == "Gate"
mlReady  = mlOn and mlLib >= math.max(i_k, i_warmup)
// Gating needs a far larger library than display does: a 5-of-K vote drawn from a small
// 6-D library would cull signals without carrying information, so Gate mode behaves as
// Advisory until the library clears the higher bar.
mlGateOn = mlGate and mlLib >= math.max(i_gate_min, math.max(i_k, i_warmup))

// ═══════════════════════════════════════════════════════════════
// SIGNALS — rule gate → (optional) KNN gate
// ═══════════════════════════════════════════════════════════════
longConfirmOK  = i_mode != "Conservative" or longConsec >= 2 or longRetestOK
shortConfirmOK = i_mode != "Conservative" or shortConsec >= 2 or shortRetestOK

// Rule quality of the breakout itself. Deliberately independent of trading PERMISSION
// (direction already taken, per-session cap, news switch) so that the learning library
// keeps growing from every genuine breakout episode, not only from the ones traded.
// Directional trigger. Close Confirmed: the bar closes beyond the range. Intrabar Touch:
// the bar's extreme crosses the level (fill modeled at the level, stop-order style).
// Sweep-reversal (opt-in): a prior sweep of the OPPOSITE edge plus a confirmed close
// through the midpoint within the false-breakout window — the fade-the-first-move entry.
brkLong   = i_trigger == "Intrabar Touch" ? high > orbHigh : close > orbHigh
brkShort  = i_trigger == "Intrabar Touch" ? low < orbLow : close < orbLow
revLongTrig  = i_sweep_rev and sweptLow and not na(sweepLoBar) and bar_index - sweepLoBar <= fboBars and close > orbMid
revShortTrig = i_sweep_rev and sweptHigh and not na(sweepHiBar) and bar_index - sweepHiBar <= fboBars and close < orbMid

qualLong  = orbLocked and not lateBlock and not hardBlockAtr and not hardBlockVol and not hardBlockTrndL and not hardBlockVwapL and not (i_f_wide and wideOR) and (brkLong or revLongTrig) and longConfirmOK and longRetests >= i_retests and not na(confLong) and confLong >= effThresh and longVetoCount <= maxVetoes and barstate.isconfirmed
qualShort = orbLocked and not lateBlock and not hardBlockAtr and not hardBlockVol and not hardBlockTrndS and not hardBlockVwapS and not (i_f_wide and wideOR) and (brkShort or revShortTrig) and shortConfirmOK and shortRetests >= i_retests and not na(confShort) and confShort >= effThresh and shortVetoCount <= maxVetoes and barstate.isconfirmed

// Which flavour actually fired (reversal only when the breakout trigger itself did not).
isRevLong  = qualLong and not brkLong
isRevShort = qualShort and not brkShort

// The effective fill price: the level itself for touch-mode breakouts, the close otherwise.
entryRefL = i_trigger == "Intrabar Touch" and brkLong ? orbHigh : close
entryRefS = i_trigger == "Intrabar Touch" and brkShort ? orbLow : close

// Trading permission layered on top of rule quality.
inBlackout = i_blackout != "0000-0000" and not na(time(timeframe.period, i_blackout, tzAnchor))
tradeOK    = not i_news_off and not inBlackout and sigCount < i_max_sigs
// Which side broke FIRST, by bar — not "has this side broken yet", which is always true
// for the side currently signalling and made the gate a no-op for Close Confirmed entries.
firstBreakIsShort = shortBrokeOnce and (not longBrokeOnce or shortFirstBreakBar < longFirstBreakBar)
firstBreakIsLong  = longBrokeOnce and (not shortBrokeOnce or longFirstBreakBar < shortFirstBreakBar)
candLong  = qualLong and tradeOK and not longUsed and not (i_first_only and firstBreakIsShort)
candShort = qualShort and tradeOK and not shortUsed and not (i_first_only and firstBreakIsLong)

// Trade-direction-oriented 6-feature fingerprint (0-1 each).
fp1 = (qualShort ? 100.0 - trendScore : trendScore) / 100.0
fp2 = (qualShort ? 100.0 - momScore : momScore) / 100.0
fp3 = (qualShort ? volShortS : volLongS) / 100.0
fp4 = volatScore / 100.0
fp5 = (qualShort ? structShortS : structLongS) / 100.0
fp6 = (qualShort ? qualShortS : qualLongS) / 100.0

float knnVote = na
if (candLong or candShort) and mlOn
    knnVote := f_knn(fp1, fp2, fp3, fp4, fp5, fp6)

// In Advisory mode (default) the vote is measured and displayed but never blocks a
// signal, so the set of signalling bars is fully deterministic. Only Gate mode filters,
// and only once the library is large enough for the vote to carry information.
longSignal  = candLong and (not mlGateOn or nz(knnVote, 0.0) >= i_conf_min)
shortSignal = candShort and (not mlGateOn or nz(knnVote, 0.0) >= i_conf_min)

// Library logging: ONE row per breakout episode, not one per qualifying bar. Consecutive
// bars of the same episode have near-identical fingerprints, so logging each of them would
// fill the K nearest slots with clones of a single episode and collapse the effective
// sample size to one. The lock clears when price stops closing beyond the range.
var bool longLogged = false
var bool shortLogged = false
// Released only once the close-beyond streak has ended AND the episode has stopped
// qualifying — a bare consec==0 check misses Intrabar Touch and Sweep-Reversal episodes,
// whose qualifying bars don't close beyond the range, so the latch would clear and
// immediately re-set every bar, flooding the library with clones of one episode.
if longConsec == 0 and not qualLong
    longLogged := false
if shortConsec == 0 and not qualShort
    shortLogged := false
logLong  = qualLong and not longLogged
logShort = qualShort and not shortLogged

if logLong
    longLogged := true
    _rawSL = isRevLong ? sweepLoPx : i_sl_basis == "ATR" ? entryRefL - i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? low : orbLow
    _minD  = math.max(0.1 * nz(atr, 0.0), syminfo.mintick)
    _slC   = math.min(_rawSL, entryRefL - _minD)
    _rC    = entryRefL - _slC
    array.push(p_dir, 1)
    array.push(p_bar, bar_index)
    array.push(p_tp, entryRefL + _rC)
    array.push(p_sl, _slC)
    array.push(p_f1, fp1)
    array.push(p_f2, fp2)
    array.push(p_f3, fp3)
    array.push(p_f4, fp4)
    array.push(p_f5, fp5)
    array.push(p_f6, fp6)
if logShort
    shortLogged := true
    _rawSL = isRevShort ? sweepHiPx : i_sl_basis == "ATR" ? entryRefS + i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? high : orbHigh
    _minD  = math.max(0.1 * nz(atr, 0.0), syminfo.mintick)
    _slC   = math.max(_rawSL, entryRefS + _minD)
    _rC    = _slC - entryRefS
    array.push(p_dir, -1)
    array.push(p_bar, bar_index)
    array.push(p_tp, entryRefS - _rC)
    array.push(p_sl, _slC)
    array.push(p_f1, fp1)
    array.push(p_f2, fp2)
    array.push(p_f3, fp3)
    array.push(p_f4, fp4)
    array.push(p_f5, fp5)
    array.push(p_f6, fp6)

// ═══════════════════════════════════════════════════════════════
// TRADE PLAN — TP1 (1R) / TP2 / TP3 ladder, adaptive SL, exits
// ═══════════════════════════════════════════════════════════════
bool tp1Evt = false
bool tp2Evt = false
bool tp3Evt = false
bool slEvt  = false
bool revEvt = false
bool stopFirst = i_amb == "Stop first"

// Exit levels are snapshotted the instant their event latches. The entry blocks further
// down reassign slDynPx/tp1Px..tp3Px for a NEW plan, so a stop or target that resolves on
// the same bar as an opposite entry would otherwise be reported at the new plan's price.
float tp1EvtPx = na
float tp2EvtPx = na
float tp3EvtPx = na
float slEvtPx  = na

// Same-bar TP+SL: when one bar's range covers both the target and the stop, the true
// sequence is unknowable from bar data. Resolving the STOP first is the conservative
// convention — and it is the same one the KNN outcome resolver already uses when it
// labels a stored breakout, so what the chart shows and what the engine learns agree.
if activeDir == 1 and not na(tradeStartBar) and bar_index > tradeStartBar
    if stopFirst and low <= slDynPx
        slEvt := true
        slEvtPx := slDynPx
        activeDir := 0
    else if i_tp_method == "Dynamic (EMA)"
        // Book profit when price closes back through the fast EMA while in profit
        // (ATR-scaled thresholds — instrument-agnostic, unlike fixed-% variants).
        if not tp1Hit and emaFastV > entryPx + 0.5 * atr and close < emaFastV
            tp1Hit := true
            tp1Evt := true
            tp1Px := close
            tp1EvtPx := tp1Px
            longSigBar := na
            if i_adapt_sl
                slDynPx := entryPx
        else if tp1Hit and not tp2Hit and emaFastV > tp1Px + 0.25 * atr and close < emaFastV
            tp2Hit := true
            tp2Evt := true
            tp2Px := close
            tp2EvtPx := tp2Px
        else if tp2Hit and not tp3Hit and emaFastV > tp2Px + 0.25 * atr and close < emaFastV
            tp3Hit := true
            tp3Evt := true
            tp3Px := close
            tp3EvtPx := tp3Px
            activeDir := 0
    else
        if not tp1Hit and high >= tp1Px
            tp1Hit := true
            tp1Evt := true
            tp1EvtPx := tp1Px
            longSigBar := na
            if i_adapt_sl
                slDynPx := entryPx
        if tp1Hit and not tp2Hit and high >= tp2Px
            tp2Hit := true
            tp2Evt := true
            tp2EvtPx := tp2Px
        if tp2Hit and not tp3Hit and high >= tp3Px
            tp3Hit := true
            tp3Evt := true
            tp3EvtPx := tp3Px
            activeDir := 0
    if activeDir == 1 and low <= slDynPx and not tp1Evt and not tp2Evt and not tp3Evt
        slEvt := true
        slEvtPx := slDynPx
        activeDir := 0
if activeDir == -1 and not na(tradeStartBar) and bar_index > tradeStartBar
    if stopFirst and high >= slDynPx
        slEvt := true
        slEvtPx := slDynPx
        activeDir := 0
    else if i_tp_method == "Dynamic (EMA)"
        if not tp1Hit and emaFastV < entryPx - 0.5 * atr and close > emaFastV
            tp1Hit := true
            tp1Evt := true
            tp1Px := close
            tp1EvtPx := tp1Px
            shortSigBar := na
            if i_adapt_sl
                slDynPx := entryPx
        else if tp1Hit and not tp2Hit and emaFastV < tp1Px - 0.25 * atr and close > emaFastV
            tp2Hit := true
            tp2Evt := true
            tp2Px := close
            tp2EvtPx := tp2Px
        else if tp2Hit and not tp3Hit and emaFastV < tp2Px - 0.25 * atr and close > emaFastV
            tp3Hit := true
            tp3Evt := true
            tp3Px := close
            tp3EvtPx := tp3Px
            activeDir := 0
    else
        if not tp1Hit and low <= tp1Px
            tp1Hit := true
            tp1Evt := true
            tp1EvtPx := tp1Px
            shortSigBar := na
            if i_adapt_sl
                slDynPx := entryPx
        if tp1Hit and not tp2Hit and low <= tp2Px
            tp2Hit := true
            tp2Evt := true
            tp2EvtPx := tp2Px
        if tp2Hit and not tp3Hit and low <= tp3Px
            tp3Hit := true
            tp3Evt := true
            tp3EvtPx := tp3Px
            activeDir := 0
    if activeDir == -1 and high >= slDynPx and not tp1Evt and not tp2Evt and not tp3Evt
        slEvt := true
        slEvtPx := slDynPx
        activeDir := 0

// False-breakout tagging: close back inside the range within the window
// (impossible after TP1 — the anchor is cleared on the TP1 touch).
// The close[1] term catches the classic case (a bar had closed beyond, now closes back in).
// The touch-inside latch covers Intrabar Touch fills whose own entry bar already closed
// inside — the pierce-and-fade fakeout that the close[1] test alone can never see.
fboLongEvt  = not na(longSigBar) and bar_index > longSigBar and bar_index - longSigBar <= fboBars and orbLocked and close < orbHigh and (nz(close[1], close) >= orbHigh or longTouchInside) and barstate.isconfirmed
fboShortEvt = not na(shortSigBar) and bar_index > shortSigBar and bar_index - shortSigBar <= fboBars and orbLocked and close > orbLow and (nz(close[1], close) <= orbLow or shortTouchInside) and barstate.isconfirmed
fboEvt = fboLongEvt or fboShortEvt
if fboLongEvt
    activeDir := activeDir == 1 ? 0 : activeDir
    if i_rearm
        longUsed := false
    longSigBar := na
    longTouchInside := false
if fboShortEvt
    activeDir := activeDir == -1 ? 0 : activeDir
    if i_rearm
        shortUsed := false
    shortSigBar := na
    shortTouchInside := false

// Signal labels are pushed further from the bar when another signal printed only a few
// bars earlier, so two entries close together cannot overlap into an unreadable stack.
var int lastSigLblBar = na

// New entries. An opposite signal while a plan is still active formally closes
// the old plan first (reversal event) so the alert stream never loses a trade.
if longSignal
    if activeDir == -1
        revEvt := true
    sigCount := sigCount + 1
    longUsed := true
    // Reversal plans are not breakouts, so they must never be tagged "false breakout" —
    // leaving the anchor na makes fboLongEvt structurally impossible for them.
    longSigBar := isRevLong ? int(na) : bar_index
    longTouchInside := brkLong and close < orbHigh
    activeDir := 1
    tradeStartBar := bar_index
    entryPx := entryRefL
    _rawSL = isRevLong ? sweepLoPx : i_sl_basis == "ATR" ? entryPx - i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? low : orbLow
    _minD = math.max(0.1 * nz(atr, 0.0), syminfo.mintick)
    slDynPx := math.min(_rawSL, entryPx - _minD)
    _r = entryPx - slDynPx
    if i_tp_method == "R Ladder"
        tp1Px := entryPx + _r
        tp2Px := entryPx + i_tp2_r * _r
        tp3Px := entryPx + i_tp3_r * _r
    else if i_tp_method == "OR Width Projection"
        tp1Px := math.max(orbHigh + 0.5 * orbWidth, entryPx + 0.5 * _r)
        tp2Px := math.max(orbHigh + 1.0 * orbWidth, entryPx + 1.0 * _r)
        tp3Px := math.max(orbHigh + 1.5 * orbWidth, entryPx + 1.5 * _r)
    else
        tp1Px := na
        tp2Px := na
        tp3Px := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    planCount := planCount + 1
    // Intrabar Touch fills mid-bar, so the rest of THIS bar is live and unobserved by the
    // next-bar-only management loop below. Evaluate the post-fill excursion of the entry
    // bar itself here (Breakout Candle basis uses the bar's own low as the raw stop, so a
    // low-based check would stop every touch-mode plan at birth — check the CLOSE instead).
    if i_trigger == "Intrabar Touch" and brkLong
        bool sbStopL = i_sl_basis == "Breakout Candle" ? close <= slDynPx : low <= slDynPx
        if stopFirst and sbStopL
            slEvt := true
            slEvtPx := slDynPx
            activeDir := 0
        else
            if not na(tp1Px) and high >= tp1Px
                tp1Hit := true
                tp1Evt := true
                tp1EvtPx := tp1Px
                longSigBar := na
                if i_adapt_sl
                    slDynPx := entryPx
            if activeDir == 1 and sbStopL and not tp1Evt
                slEvt := true
                slEvtPx := slDynPx
                activeDir := 0
    _lblOffL = not na(lastSigLblBar) and bar_index - lastSigLblBar <= 12 ? 3.4 : 1.5
    lastSigLblBar := bar_index
    label.new(bar_index, low - atr * _lblOffL, (isRevLong ? "ORB Rev Long\n" : "ORB Long\n") + (i_show_vote and mlOn ? (mlReady ? "analogues " + str.tostring(math.round(nz(knnVote, 0.0) * i_k)) + "/" + str.tostring(i_k) + " · base " + str.tostring(basePctG) + "%" : "learning · score " + str.tostring(math.round(confLong))) : "score " + str.tostring(math.round(confLong))), color = color.new(i_c_bull, 60), textcolor = i_c_bull, style = label.style_label_up, size = size.small)

if shortSignal
    if activeDir == 1
        revEvt := true
    sigCount := sigCount + 1
    shortUsed := true
    shortSigBar := isRevShort ? int(na) : bar_index
    shortTouchInside := brkShort and close > orbLow
    activeDir := -1
    tradeStartBar := bar_index
    entryPx := entryRefS
    _rawSL = isRevShort ? sweepHiPx : i_sl_basis == "ATR" ? entryPx + i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? high : orbHigh
    _minD = math.max(0.1 * nz(atr, 0.0), syminfo.mintick)
    slDynPx := math.max(_rawSL, entryPx + _minD)
    _r = slDynPx - entryPx
    if i_tp_method == "R Ladder"
        tp1Px := entryPx - _r
        tp2Px := entryPx - i_tp2_r * _r
        tp3Px := entryPx - i_tp3_r * _r
    else if i_tp_method == "OR Width Projection"
        tp1Px := math.min(orbLow - 0.5 * orbWidth, entryPx - 0.5 * _r)
        tp2Px := math.min(orbLow - 1.0 * orbWidth, entryPx - 1.0 * _r)
        tp3Px := math.min(orbLow - 1.5 * orbWidth, entryPx - 1.5 * _r)
    else
        tp1Px := na
        tp2Px := na
        tp3Px := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    planCount := planCount + 1
    // Mirror of the long side: evaluate the touch-fill entry bar's own post-fill excursion.
    if i_trigger == "Intrabar Touch" and brkShort
        bool sbStopS = i_sl_basis == "Breakout Candle" ? close >= slDynPx : high >= slDynPx
        if stopFirst and sbStopS
            slEvt := true
            slEvtPx := slDynPx
            activeDir := 0
        else
            if not na(tp1Px) and low <= tp1Px
                tp1Hit := true
                tp1Evt := true
                tp1EvtPx := tp1Px
                shortSigBar := na
                if i_adapt_sl
                    slDynPx := entryPx
            if activeDir == -1 and sbStopS and not tp1Evt
                slEvt := true
                slEvtPx := slDynPx
                activeDir := 0
    _lblOffS = not na(lastSigLblBar) and bar_index - lastSigLblBar <= 12 ? 3.4 : 1.5
    lastSigLblBar := bar_index
    label.new(bar_index, high + atr * _lblOffS, (isRevShort ? "ORB Rev Short\n" : "ORB Short\n") + (i_show_vote and mlOn ? (mlReady ? "analogues " + str.tostring(math.round(nz(knnVote, 0.0) * i_k)) + "/" + str.tostring(i_k) + " · base " + str.tostring(basePctG) + "%" : "learning · score " + str.tostring(math.round(confShort))) : "score " + str.tostring(math.round(confShort))), color = color.new(i_c_bear, 60), textcolor = i_c_bear, style = label.style_label_down, size = size.small)

// Armed states (rule confidence within 10 points of, or above, the effective threshold).
armedLong  = orbLocked and not longUsed and not lateBlock and confLong >= effThresh - 10
armedShort = orbLocked and not shortUsed and not lateBlock and confShort >= effThresh - 10

chandLong  = ta.highest(high, i_trail_len) - i_trail_mult * atr
chandShort = ta.lowest(low, i_trail_len) + i_trail_mult * atr

// ═══════════════════════════════════════════════════════════════
// EVENTS FOR ALERTS
// ═══════════════════════════════════════════════════════════════
// Outcome counters (all-history, factual event counts).
if tp1Evt
    tp1Count := tp1Count + 1
if fboLongEvt or fboShortEvt
    fboCount := fboCount + 1

// Sweep events: the moment a wick beyond an edge closes back inside (liquidity taken).
// Confirmed-only, like every other event here: the latch itself is evaluated intrabar, so
// a bar that pokes above the edge and then closes BEYOND it would otherwise fire a sweep
// alert that the bar's own close retracts — a breakout misreported as a sweep.
sweepHighEvt = sweptHigh and not sweptHigh[1] and barstate.isconfirmed
sweepLowEvt  = sweptLow and not sweptLow[1] and barstate.isconfirmed

orbCompleteEvt = orbLocked and not orbLocked[1] and barstate.isconfirmed
confAboveEvt   = orbLocked and not lateBlock and math.max(nz(confLong, 0.0), nz(confShort, 0.0)) >= effThresh and math.max(nz(confLong[1], 0.0), nz(confShort[1], 0.0)) < effThresh and barstate.isconfirmed
trendChangeEvt = bar_index > 0 and (emaFastV > emaMidV) != (nz(emaFastV[1], emaFastV) > nz(emaMidV[1], emaMidV)) and barstate.isconfirmed
tpAnyEvt       = tp1Evt or tp2Evt or tp3Evt

// Retest events: a confirmed return to the broken level that still closes beyond it.
// Strict '>' means the session reset that zeroes the counters can never fire these.
longRetestEvt  = orbLocked and longRetests > nz(longRetests[1], 0) and barstate.isconfirmed
shortRetestEvt = orbLocked and shortRetests > nz(shortRetests[1], 0) and barstate.isconfirmed
retestEvt      = longRetestEvt or shortRetestEvt

// Machine-readable payloads for webhook automation. alertcondition() messages must be
// const strings, so live prices are delivered through alert() instead. na targets (the
// Dynamic EMA method has none at entry) serialise as null, never as 0.
if longSignal or shortSignal
    string _side = longSignal ? "long" : "short"
    float  _cf   = longSignal ? nz(confLong, 0.0) : nz(confShort, 0.0)
    alert('{"src":"ORB AI [PickMyTrade]","sym":"' + syminfo.tickerid + '","tf":"' + timeframe.period + '","side":"' + _side + '","entry":' + f_jnum(entryPx) + ',"sl":' + f_jnum(slDynPx) + ',"tp1":' + f_jnum(tp1Px) + ',"tp2":' + f_jnum(tp2Px) + ',"tp3":' + f_jnum(tp3Px) + ',"risk_ticks":' + str.tostring(math.round(math.abs(entryPx - slDynPx) / syminfo.mintick)) + ',"score":' + str.tostring(math.round(_cf)) + ',"knn_mode":"' + i_ml_mode + '","knn_vote":' + (mlReady ? str.tostring(math.round(nz(knnVote, 0.0) * 100)) : "null") + '}', alert.freq_once_per_bar_close)

if tp1Evt or tp2Evt or tp3Evt or slEvt
    string _lvl = tp3Evt ? "tp3" : tp2Evt ? "tp2" : tp1Evt ? "tp1" : "sl"
    float  _px  = tp3Evt ? nz(tp3EvtPx, close) : tp2Evt ? nz(tp2EvtPx, close) : tp1Evt ? nz(tp1EvtPx, close) : nz(slEvtPx, close)
    alert('{"src":"ORB AI [PickMyTrade]","sym":"' + syminfo.tickerid + '","tf":"' + timeframe.period + '","event":"' + _lvl + '","price":' + f_jnum(_px) + '}', alert.freq_once_per_bar_close)

// Pre-breakout heads-up: armed side, price enters the quarter-ATR proximity band.
approachLongEvt  = armedLong and atr > 0 and close <= orbHigh and orbHigh - close <= 0.25 * atr and orbHigh - nz(close[1], close) > 0.25 * nz(atr[1], atr) and barstate.isconfirmed
approachShortEvt = armedShort and atr > 0 and close >= orbLow and close - orbLow <= 0.25 * atr and nz(close[1], close) - orbLow > 0.25 * nz(atr[1], atr) and barstate.isconfirmed
approachEvt      = approachLongEvt or approachShortEvt

// ═══════════════════════════════════════════════════════════════
// VISUALS — Order Block AI house style
// ═══════════════════════════════════════════════════════════════
// ORB High is the long trigger, ORB Low is the short trigger — the same blue/orange used
// for every other directional element (zones, signals, TP, stop), so the boundary itself
// tells you which side is which at a glance.
// Per-bar: extend the glass panel across the active session.
// Freezes at session close so historical boxes don't stretch overnight.
if i_show_box and not i_zen and orbLocked and inSessNow
    float _midLive = (orbHigh + orbLow) / 2
    if not na(orBoxCur)
        box.set_right (orBoxCur, time)
        box.set_bottom(orBoxCur, _midLive)
        box.set_bgcolor      (orBoxCur, color.new(i_c_bull, 83))
        box.set_border_color (orBoxCur, color.new(i_c_bull, 30))
    if not na(orBoxBot)
        box.set_right(orBoxBot, time)
        box.set_top  (orBoxBot, _midLive)
        box.set_bgcolor      (orBoxBot, color.new(i_c_bear, 83))
        box.set_border_color (orBoxBot, color.new(i_c_bear, 30))

pOrbHi  = plot(orbLocked ? orbHigh : na, "ORB High", color = color.new(i_c_bull, 0), display = display.data_window, style = plot.style_linebr, linewidth = 1)
pOrbLo  = plot(orbLocked ? orbLow : na, "ORB Low", color = color.new(i_c_bear, 0), display = display.data_window, style = plot.style_linebr, linewidth = 1)
plot(orbLocked and not i_zen ? orbMid : na, "ORB Midpoint", color = color.new(i_c_range, 45), style = plot.style_linebr, linewidth = 1)

// Range-multiple measured-move targets — the classic ORB reference levels, projected
// beyond each edge as multiples of the range width. Drawn as line OBJECTS, not plot()
// calls: each plot() here costs 2 static slots against Pine's 64-output budget even
// while its toggle is off, and 8 of them (plus the premarket pair below) pushed the
// script to 71 slots and runtime error RE10140. Lines cost no plot slots; the segments
// are per-session anyway, and old sessions age out through max_lines_count oldest-first.
var line[] ptLns = array.new_line()
if i_show_pt and not i_zen and lockNow
    array.clear(ptLns)
    array.push(ptLns, line.new(time, orbHigh + 0.5 * orbWidth, time, orbHigh + 0.5 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bull, 55)))
    array.push(ptLns, line.new(time, orbHigh + 1.0 * orbWidth, time, orbHigh + 1.0 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bull, 30)))
    array.push(ptLns, line.new(time, orbLow - 0.5 * orbWidth, time, orbLow - 0.5 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bear, 55)))
    array.push(ptLns, line.new(time, orbLow - 1.0 * orbWidth, time, orbLow - 1.0 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bear, 35)))
    if i_show_ptx
        array.push(ptLns, line.new(time, orbHigh + 1.5 * orbWidth, time, orbHigh + 1.5 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bull, 65)))
        array.push(ptLns, line.new(time, orbHigh + 2.0 * orbWidth, time, orbHigh + 2.0 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bull, 65)))
        array.push(ptLns, line.new(time, orbLow - 1.5 * orbWidth, time, orbLow - 1.5 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bear, 65)))
        array.push(ptLns, line.new(time, orbLow - 2.0 * orbWidth, time, orbLow - 2.0 * orbWidth, xloc = xloc.bar_time, color = color.new(i_c_bear, 65)))
// Extend only while the anchor session is live: the levels freeze at the session close
// instead of stretching through the overnight, which buried the chart in full-width
// horizontal lines and made history look different from the live session.
else if orbLocked and inSessNow and array.size(ptLns) > 0
    for ln in ptLns
        line.set_x2(ln, time)
plot(inOR and not i_zen ? orbHigh : na, "Developing OR High", color = color.new(i_c_bull, 0), display = display.data_window, style = plot.style_linebr, linewidth = 1)
plot(inOR and not i_zen ? orbLow : na, "Developing OR Low", color = color.new(i_c_bear, 0), display = display.data_window, style = plot.style_linebr, linewidth = 1)

// Strength readout as TEXT, not a colour wash: a single persistent label per side tracks
// the current bar and reports "WATCH" (within 10 points of the threshold) or "ARMED" (at
// or above it) with the live score. Nothing is drawn below that — a quiet chart most of
// the time, an explicit number the moment it means something.
f_zoneState(conf, thr) => conf >= thr ? "ARMED" : conf >= thr - 10 ? "WATCH" : ""

var string longZoneState  = ""
var string shortZoneState = ""
var label  longZoneLbl    = na
var label  shortZoneLbl   = na

newLongState  = i_show_zone and orbLocked and not longUsed and not lateBlock and not i_zen ? f_zoneState(nz(confLong, 0.0), effThresh) : ""
newShortState = i_show_zone and orbLocked and not shortUsed and not lateBlock and not i_zen ? f_zoneState(nz(confShort, 0.0), effThresh) : ""

if newLongState != longZoneState
    label.delete(longZoneLbl)
    if newLongState != ""
        longZoneLbl := label.new(bar_index, orbHigh, newLongState + " " + str.tostring(math.round(nz(confLong, 0.0))), style = label.style_label_down, color = color.new(i_c_bull, newLongState == "ARMED" ? 0 : 45), textcolor = color.white, size = size.tiny)
    longZoneState := newLongState
else if newLongState != ""
    label.set_x(longZoneLbl, bar_index)
    label.set_text(longZoneLbl, newLongState + " " + str.tostring(math.round(nz(confLong, 0.0))))
    label.set_color(longZoneLbl, color.new(i_c_bull, newLongState == "ARMED" ? 0 : 45))

if newShortState != shortZoneState
    label.delete(shortZoneLbl)
    if newShortState != ""
        shortZoneLbl := label.new(bar_index, orbLow, newShortState + " " + str.tostring(math.round(nz(confShort, 0.0))), style = label.style_label_up, color = color.new(i_c_bear, newShortState == "ARMED" ? 0 : 45), textcolor = color.white, size = size.tiny)
    shortZoneState := newShortState
else if newShortState != ""
    label.set_x(shortZoneLbl, bar_index)
    label.set_text(shortZoneLbl, newShortState + " " + str.tostring(math.round(nz(confShort, 0.0))))
    label.set_color(shortZoneLbl, color.new(i_c_bear, newShortState == "ARMED" ? 0 : 45))

// Reference overlays stay deliberately neutral so they never compete with the two
// signal colours: EMAs step down in opacity by length, VWAP is the crisp neutral line.
plot(i_show_ema and not i_zen ? emaFastV : na, "EMA Fast", color = color.new(i_c_range, 15))
plot(i_show_ema and not i_zen ? emaMidV : na, "EMA Mid", color = color.new(i_c_range, 40))
plot(i_show_ema and not i_zen ? emaSlowV : na, "EMA Slow", color = color.new(i_c_range, 60))
plot(i_show_vwap and hasVol and not i_zen ? vwapV : na, "Session VWAP", color = color.new(i_c_range, 0), linewidth = 1)
// Premarket levels as line objects for the same plot-budget reason as the PT levels.
// Created on the first premarket bar of the day, then stretched to track the developing
// extreme; pmHi/pmLo stay set through the RTH day, so the line keeps extending exactly
// as the old plot did, and freezes when the day rolls over.
var line pmHiLn = na
var line pmLoLn = na
pmStart = session.ispremarket and (barstate.isfirst or not session.ispremarket[1])
if i_show_pm and not i_zen
    if pmStart
        pmHiLn := line.new(time, high, time, high, xloc = xloc.bar_time, color = color.new(i_c_range, 40), style = line.style_dotted)
        pmLoLn := line.new(time, low, time, low, xloc = xloc.bar_time, color = color.new(i_c_range, 40), style = line.style_dotted)
    if not na(pmHiLn) and not na(pmHi)
        line.set_x2(pmHiLn, time)
        line.set_y1(pmHiLn, pmHi)
        line.set_y2(pmHiLn, pmHi)
    if not na(pmLoLn) and not na(pmLo)
        line.set_x2(pmLoLn, time)
        line.set_y1(pmLoLn, pmLo)
        line.set_y2(pmLoLn, pmLo)

showTrade = activeDir != 0 and not i_zen
plot(showTrade ? entryPx : na, "Entry", color = color.new(i_c_range, 20), style = plot.style_linebr, linewidth = 1)
plot(showTrade ? slDynPx : na, "Suggested Stop", color = color.new(i_c_bear, 0), style = plot.style_linebr, linewidth = 1)
plot(showTrade ? tp1Px : na, "TP1 (1R)", color = color.new(i_c_bull, 40), style = plot.style_linebr, linewidth = 1)
plot(showTrade ? tp2Px : na, "TP2", color = color.new(i_c_bull, 20), style = plot.style_linebr, linewidth = 1)
plot(showTrade ? tp3Px : na, "TP3", color = color.new(i_c_bull, 0), style = plot.style_linebr, linewidth = 1)
plot(showTrade and activeDir == 1 ? chandLong : showTrade and activeDir == -1 ? chandShort : na, "Trailing Suggestion", color = color.new(i_c_range, 25), style = plot.style_circles, linewidth = 1)

showMarks = not i_zen
// Event markers drawn as labels at the actual event price — labels do not count toward
// Pine's 64-plot limit (each plotshape with text/colors consumes ~3 slots; ten of them
// pushed the script to 72 slots and runtime error RE10140).
// Marker text is always white on a translucent plate — a label's `color` is the plate
// behind the text, so text and plate must never share a colour. TP plates gain weight
// by rung (40 → 20 → 0), matching the TP line grading above.
if showMarks
    if tp1Evt
        label.new(bar_index, nz(tp1EvtPx, close), "TP1", style = label.style_xcross, color = color.new(i_c_bull, 40), textcolor = color.white, size = size.tiny)
    if tp2Evt
        label.new(bar_index, nz(tp2EvtPx, close), "TP2", style = label.style_xcross, color = color.new(i_c_bull, 20), textcolor = color.white, size = size.tiny)
    if tp3Evt
        label.new(bar_index, nz(tp3EvtPx, close), "TP3", style = label.style_xcross, color = color.new(i_c_bull, 0), textcolor = color.white, size = size.tiny)
    if slEvt
        label.new(bar_index, nz(slEvtPx, close), "SL", style = label.style_xcross, color = color.new(i_c_bear, 0), textcolor = color.white, size = size.tiny)
    if fboLongEvt
        label.new(bar_index, orbHigh, "FBO", style = label.style_xcross, color = color.new(i_c_range, 15), textcolor = color.white, size = size.tiny)
    if fboShortEvt
        label.new(bar_index, orbLow, "FBO", style = label.style_xcross, color = color.new(i_c_range, 15), textcolor = color.white, size = size.tiny)
    if sessExitEvt
        label.new(bar_index, close, "EXIT", style = label.style_xcross, color = color.new(i_c_range, 25), textcolor = color.white, size = size.tiny)

// Breakout → Retest workflow marks (context for manual traders, independent of signals).
// ONE label per side per session, updated in place. Spawning a fresh label on every retest
// stacked a dozen of them at the identical price — unreadable, and it burned the 300-label
// budget so older sessions silently lost their marks. "BO" is pinned where the break
// happened; the retest counter slides to the most recent retest and shows the running
// count, so "how many times has this level been retested" is answerable at a glance.
var label longBOLbl  = na
var label shortBOLbl = na
var label longRTLbl  = na
var label shortRTLbl = na

longBOEvt  = longBrokeOnce and not longBrokeOnce[1]
shortBOEvt = shortBrokeOnce and not shortBrokeOnce[1]
if i_show_flow and not i_zen
    if longBOEvt
        longBOLbl := label.new(bar_index, orbHigh, "BO ▲", style = label.style_label_up, color = color.new(i_c_bull, 55), textcolor = color.white, size = size.tiny, tooltip = "Breakout: first confirmed close above the opening range high.")
    if shortBOEvt
        shortBOLbl := label.new(bar_index, orbLow, "BO ▼", style = label.style_label_down, color = color.new(i_c_bear, 55), textcolor = color.white, size = size.tiny, tooltip = "Breakout: first confirmed close below the opening range low.")
    // longRetests == 1 is the first retest of this session, so a new label is created then
    // and only repositioned afterwards — no session-reset bookkeeping needed.
    if longRetestEvt
        if longRetests == 1
            longRTLbl := label.new(bar_index, orbHigh, "RT x1", style = label.style_label_up, color = color.new(i_c_bull, 30), textcolor = color.white, size = size.tiny, tooltip = "Retest: price returned to the broken range high and closed back above it.")
        else if not na(longRTLbl)
            label.set_x(longRTLbl, bar_index)
            label.set_text(longRTLbl, "RT x" + str.tostring(longRetests))
    if shortRetestEvt
        if shortRetests == 1
            shortRTLbl := label.new(bar_index, orbLow, "RT x1", style = label.style_label_down, color = color.new(i_c_bear, 30), textcolor = color.white, size = size.tiny, tooltip = "Retest: price returned to the broken range low and closed back below it.")
        else if not na(shortRTLbl)
            label.set_x(shortRTLbl, bar_index)
            label.set_text(shortRTLbl, "RT x" + str.tostring(shortRetests))

// Kept deliberately faint: this tint can cover hours of bars at a time, and anything
// stronger turns the chart into uneven colour blocks that compete with the candles.
bgcolor(i_bg_trend and not i_zen ? (trendScore >= 65 ? color.new(i_c_bull, 96) : trendScore <= 35 ? color.new(i_c_bear, 96) : na) : na, title = "Trend Background")
bgcolor(i_bg_sess and inOR and not i_zen ? color.new(i_c_range, 90) : na, title = "Opening-Range Window")

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════
dSize = i_dash_size == "Small" ? size.small : size.normal
txtCol = color.new(color.white, 10)
dimCol = color.new(color.gray, 20)

f_kv(tbl, row, k, v, vcol) =>
    table.cell(tbl, 0, row, k, text_color = dimCol, text_halign = text.align_left, text_size = dSize)
    table.cell(tbl, 1, row, v, text_color = vcol, text_halign = text.align_right, text_size = dSize)
    row + 1

f_scoreRow(tbl, row, k, sc) =>
    table.cell(tbl, 0, row, k, text_color = dimCol, text_halign = text.align_left, text_size = dSize)
    table.cell(tbl, 1, row, f_meter(sc) + " " + str.tostring(math.round(nz(sc, 0.0))), text_color = color.from_gradient(nz(sc, 50.0), 0, 100, i_c_bear, i_c_bull), text_halign = text.align_right, text_size = dSize)
    row + 1

var table dash = na
if i_dash_on and not i_zen and na(dash)
    // Near-opaque panel: this dashboard carries 21 rows over live price action, so the
    // translucent treatment used for small info tables would let candles and level lines
    // bleed through the text. The frame keeps the sibling-script look.
    dash := table.new(f_pos(i_dash_pos), 2, 26, bgcolor = color.new(#0C0E12, 8), border_color = color.new(color.gray, 75), border_width = 1, frame_color = color.new(color.gray, 45), frame_width = 1)
    table.merge_cells(dash, 0, 0, 1, 0)

if i_dash_on and not i_zen and barstate.islast and not na(dash)
    isFull   = i_dash_mode == "Full"
    biasLong = nz(confLong, 0.0) >= nz(confShort, 0.0)
    dispConf = biasLong ? confLong : confShort
    biasTxt = not orbLocked ? "WAIT" : biasLong and confLong - confShort > 5 ? "LONG" : not biasLong and confShort - confLong > 5 ? "SHORT" : "NEUTRAL"
    biasCol = biasTxt == "LONG" ? i_c_bull : biasTxt == "SHORT" ? i_c_bear : txtCol
    // "LATE" means the cutoff passed while the session is still open; once the session
    // itself has ended the status says so, instead of implying a live-but-late window.
    sessTxt = not orbLocked and inOR ? "OR FORMING" : orbLocked and not inSessNow ? "SESSION CLOSED" : orbLocked and lateBlock ? "LATE — NO NEW SIGNALS" : orbLocked and i_f_wide and wideOR ? "WIDE OR — FILTERED" : orbLocked ? "ACTIVE" : "WAITING FOR OPEN"
    qualTxt = na(dispConf) ? "—" : dispConf >= effThresh + 10 ? "A+" : dispConf >= effThresh ? "A" : dispConf >= effThresh - 10 ? "B" : "C"
    riskTxt = atrRatio >= 1.35 ? "ELEVATED" : atrRatio <= 0.7 ? "LOW" : "NORMAL"
    regTxt = isBreakoutDay ? regime + " • Breakout Day" : regime
    knnDash = f_knn((biasLong ? trendScore : 100.0 - trendScore) / 100.0, (biasLong ? momScore : 100.0 - momScore) / 100.0, (biasLong ? volLongS : volShortS) / 100.0, volatScore / 100.0, (biasLong ? structLongS : structShortS) / 100.0, (biasLong ? qualLongS : qualShortS) / 100.0)
    mlTag = mlGateOn ? "GATE " : mlGate ? "ADVISORY (gate at " + str.tostring(i_gate_min) + ") " : "ADVISORY "
    mlTxt = not mlOn ? "○ OFF" : mlReady ? "● " + mlTag + str.tostring(math.round(knnDash * i_k)) + "/" + str.tostring(i_k) + " · lib " + str.tostring(mlLib) + " · base " + str.tostring(basePctG) + "%" : "◐ LEARNING · lib " + str.tostring(mlLib) + "/" + str.tostring(math.max(i_k, i_warmup))
    mlCol = not mlOn ? dimCol : mlReady ? i_c_bull : txtCol
    tp1Txt = na(tp1Px) ? "EMA-dyn" : str.tostring(tp1Px, format.mintick)
    tradeTxt = activeDir == 1 ? "LONG " + str.tostring(entryPx, format.mintick) + " | SL " + str.tostring(slDynPx, format.mintick) + " | TP1 " + tp1Txt : activeDir == -1 ? "SHORT " + str.tostring(entryPx, format.mintick) + " | SL " + str.tostring(slDynPx, format.mintick) + " | TP1 " + tp1Txt : "—"
    gapTxt = na(prevSessClose) or na(sessOpen) or prevSessClose <= 0 ? "—" : str.tostring((sessOpen - prevSessClose) / prevSessClose * 100, "#.##") + "%" + (openAbovePDH ? " • above PDH" : openBelowPDL ? " • below PDL" : "")
    // Pre-entry risk must use the SAME formula and floor the entry blocks use, otherwise
    // the number shown before entry differs from the R the plan actually takes (the
    // Breakout Candle model in particular is a fraction of the range, not the full width).
    _pSLl  = i_sl_basis == "ATR" ? close - i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? low : orbLow
    _pSLs  = i_sl_basis == "ATR" ? close + i_sl_mult * atr : i_sl_basis == "ORB Midpoint" ? orbMid : i_sl_basis == "Breakout Candle" ? high : orbHigh
    _pMinD = math.max(0.1 * nz(atr, 0.0), syminfo.mintick)
    _pRaw  = biasLong ? close - _pSLl : _pSLs - close
    float riskVal = activeDir != 0 ? math.abs(entryPx - slDynPx) : na(_pRaw) ? na : math.max(_pRaw, _pMinD)
    int r = 0
    table.cell(dash, 0, r, "ORB AI [PickMyTrade]", text_color = txtCol, text_halign = text.align_center, text_size = dSize)
    r := r + 1
    r := f_kv(dash, r, "Session", sessTxt, txtCol)
    if effOrMin != i_or_min
        r := f_kv(dash, r, "⚠ Timeframe", "OR raised to " + str.tostring(effOrMin) + "m — the " + str.tostring(i_or_min) + "m ORB needs a chart TF of " + str.tostring(i_or_min) + "m or lower", color.new(color.orange, 0))
    r := f_kv(dash, r, "Regime", regTxt, txtCol)
    if isFull
        r := f_kv(dash, r, "Gap", gapTxt, txtCol)
    r := f_kv(dash, r, "ML Engine", mlTxt, mlCol)
    // Compact folds high/low/width into a single line; Full keeps them addressable.
    if isFull
        r := f_kv(dash, r, "ORB High", orbLocked ? str.tostring(orbHigh, format.mintick) : "—", txtCol)
        r := f_kv(dash, r, "ORB Low", orbLocked ? str.tostring(orbLow, format.mintick) : "—", txtCol)
        r := f_kv(dash, r, "ORB Width", orbLocked ? str.tostring(orbWidth, format.mintick) + (effOrMin != i_or_min ? " (OR " + str.tostring(effOrMin) + "m auto)" : "") : "—", txtCol)
    else
        r := f_kv(dash, r, "Range", orbLocked ? str.tostring(orbHigh, format.mintick) + " / " + str.tostring(orbLow, format.mintick) + "  (" + str.tostring(orbWidth, format.mintick) + ")" : "—", txtCol)
    r := f_kv(dash, r, "Bias", biasTxt, biasCol)
    r := f_scoreRow(dash, r, "Rule Confidence", dispConf)
    if isFull
        r := f_kv(dash, r, "Threshold (eff.)", str.tostring(math.round(effThresh)) + " (base " + str.tostring(i_thresh) + ")", txtCol)
    if isFull
        r := f_scoreRow(dash, r, "Trend", biasLong ? trendScore : 100.0 - trendScore)
        r := f_scoreRow(dash, r, "Momentum", biasLong ? momScore : 100.0 - momScore)
        r := f_scoreRow(dash, r, "Volume", biasLong ? volLongS : volShortS)
        r := f_scoreRow(dash, r, "Volatility", volatScore)
        r := f_scoreRow(dash, r, "Structure", biasLong ? structLongS : structShortS)
        r := f_scoreRow(dash, r, "Breakout Quality", biasLong ? qualLongS : qualShortS)
        r := f_scoreRow(dash, r, "Liquidity", biasLong ? liqLongS : liqShortS)
    if isFull
        r := f_kv(dash, r, "Trade Quality", qualTxt, color.from_gradient(nz(dispConf, 50.0), 0, 100, i_c_bear, i_c_bull))
        r := f_kv(dash, r, "Risk Level", "ATR " + str.tostring(atrPct, "#.##") + "% • " + riskTxt, txtCol)
    r := f_kv(dash, r, "Risk / Unit", na(riskVal) ? "—" : str.tostring(riskVal, format.mintick) + " (" + str.tostring(math.round(riskVal / syminfo.mintick)) + " ticks)", txtCol)
    qtyVal = na(riskVal) or riskVal <= 0 ? na : math.floor(i_acct * i_risk_pct / 100 / (riskVal * syminfo.pointvalue))
    if isFull
        r := f_kv(dash, r, "Size @ " + str.tostring(i_risk_pct, "#.##") + "% risk", na(qtyVal) ? "—" : str.tostring(qtyVal) + (qtyVal < 1 ? " (risk exceeds budget)" : ""), txtCol)
        r := f_kv(dash, r, "Plan Outcomes", planCount == 0 ? "—" : str.tostring(planCount) + " plans · TP1 " + str.tostring(math.round(tp1Count * 100.0 / planCount)) + "% · FBO " + str.tostring(fboCount), txtCol)
        r := f_kv(dash, r, "Rules", str.tostring(effOrMin) + "m OR · " + (i_trigger == "Intrabar Touch" ? "touch" : "close-conf") + " · retests " + str.tostring(i_retests) + " · max " + str.tostring(i_max_sigs) + "/day · " + i_mode, dimCol)
    r := f_kv(dash, r, "Trade Plan", tradeTxt, txtCol)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSignal, "ORB AI: Long Entry", "ORB AI [PickMyTrade] {{ticker}}: LONG breakout at {{close}} — rule and KNN gates passed.")
alertcondition(shortSignal, "ORB AI: Short Entry", "ORB AI [PickMyTrade] {{ticker}}: SHORT breakout at {{close}} — rule and KNN gates passed.")
alertcondition(fboEvt, "ORB AI: False Breakout", "ORB AI [PickMyTrade] {{ticker}}: price closed back inside the opening range — false breakout tagged.")
alertcondition(confAboveEvt, "ORB AI: Confidence Above Threshold", "ORB AI [PickMyTrade] {{ticker}}: rule confidence crossed above the effective threshold.")
alertcondition(orbCompleteEvt, "ORB AI: Opening Range Complete", "ORB AI [PickMyTrade] {{ticker}}: opening range locked — watching for qualified breakouts.")
alertcondition(trendChangeEvt, "ORB AI: Trend Change", "ORB AI [PickMyTrade] {{ticker}}: fast/mid EMA relationship flipped — trend context changed.")
alertcondition(tpAnyEvt, "ORB AI: Take Profit Hit", "ORB AI [PickMyTrade] {{ticker}}: a take-profit level of the active trade plan was touched.")
alertcondition(slEvt, "ORB AI: Stop Hit", "ORB AI [PickMyTrade] {{ticker}}: the suggested stop of the active trade plan was touched.")
alertcondition(revEvt, "ORB AI: Reversal", "ORB AI [PickMyTrade] {{ticker}}: opposite signal fired — previous trade plan closed and reversed.")
alertcondition(sessExitEvt, "ORB AI: Session-End Exit", "ORB AI [PickMyTrade] {{ticker}}: session rolled over — the previous session's open trade plan was closed.")
alertcondition(approachEvt, "ORB AI: Approaching Breakout", "ORB AI [PickMyTrade] {{ticker}}: price is within a quarter-ATR of a range edge while armed — a breakout attempt may be near.")
alertcondition(retestEvt, "ORB AI: Retest", "ORB AI [PickMyTrade] {{ticker}}: price returned to the broken range edge and closed back beyond it — retest confirmed.")
alertcondition(fboLongEvt, "ORB AI: False Breakout (Long)", "ORB AI [PickMyTrade] {{ticker}}: the long breakout closed back inside the range — false breakout tagged.")
alertcondition(fboShortEvt, "ORB AI: False Breakout (Short)", "ORB AI [PickMyTrade] {{ticker}}: the short breakout closed back inside the range — false breakout tagged.")
alertcondition(sweepHighEvt, "ORB AI: Sweep Above Range", "ORB AI [PickMyTrade] {{ticker}}: a wick swept above the range high and closed back inside — liquidity taken above.")
alertcondition(sweepLowEvt, "ORB AI: Sweep Below Range", "ORB AI [PickMyTrade] {{ticker}}: a wick swept below the range low and closed back inside — liquidity taken below.")
alertcondition(tp1Evt, "ORB AI: TP1 Hit", "ORB AI [PickMyTrade] {{ticker}}: the first take-profit level of the active trade plan was reached.")
alertcondition(tp2Evt, "ORB AI: TP2 Hit", "ORB AI [PickMyTrade] {{ticker}}: the second take-profit level of the active trade plan was reached.")
alertcondition(tp3Evt, "ORB AI: TP3 Hit", "ORB AI [PickMyTrade] {{ticker}}: the third take-profit level of the active trade plan was reached and the plan closed.")
````
