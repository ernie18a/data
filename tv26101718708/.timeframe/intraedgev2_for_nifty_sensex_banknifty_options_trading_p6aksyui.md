# IntraEdgeV2 for Nifty, Sensex, BankNifty, Options Trading

- url: https://www.tradingview.com/script/p6AkSYuI-IntraEdgeV2-for-Nifty-Sensex-BankNifty-Options-Trading/
- type: indicator
- pine_id: PUB;027a3da505624884acb06395294b125a
- version: 6.0

## Description

**IntraEdge Institutional Suite**
*NSE F&O Intraday Engine — Built for Nifty, BankNifty, FinNifty, MidCapNifty, Index Options, Stock Options, and NSE Equities*

IntraEdge is a comprehensive intraday decision support system built specifically for NSE F&O traders. It synthesises institutional order flow, opening range mechanics, sector breadth, volume profile, and macro context into a single indicator, automatically adapting its engine and visuals based on the instrument you load it on.

---

**AUTO-MODE DETECTION**

Switch charts and the indicator reconfigures itself. It reads the instrument type and ticker to automatically select the correct operating mode: Nifty Index / Futures, BankNifty, FinNifty, MidCapNifty, Index Options, Stocks, or Stock Options. Override manually if needed.

---

**TIMEFRAME ROUTING: 4-TIER ARCHITECTURE**

The indicator morphs based on timeframe. On 1m to 15m charts you get the full execution engine. On 30m to 1H you get the imbalance map and doji radar. On 2H to 4H you get gravity magnets. On Daily and above you get the macro matrix. Maths always runs globally; only the visuals change per tier.

---

**CORE EXECUTION ENGINE (Intraday 1m to 15m)**

**Opening Range (OR)**
Plots OR high and low from the 9:15 to 9:30 auction. Tracks first break direction, retest, trap, and quality score. The OR close RMI is latched at exactly the 9:30 bar for session-level conviction bias. OR boxes auto-hide on historical days.

**Confluence Zone: P1**
Scans 9 institutional levels at OR set time (VWAP, VAH/VAL, PDH/PDL, PrevVWAP, weekly bands, FVG, nPOC) and scores the proximity of OR high and low to each. Colocation tags (⚓) flag where OR levels stack with Value Area or PrevVWAP, the highest-probability institutional clusters.

**OR Level Scoring: P2**
Every confirmed touch of the OR high or low is scored across volume, body close, ATR relative size, VWAP position, and RMI momentum. Scores appear as labels on the chart. High-conviction touches (score 7 or above) trigger a dedicated alert.

**Activity Filter: P3**
Detects chop regimes using range compression, VWAP adherence, and volume conditions. When active, the tape locks to WAIT and an alert fires so you know to stop trading the current setup.

**Pre-OR Sweep: P5**
Detects PDH, PDL, or PrevVWAP sweeps in the 9:15 to 9:29 window before the OR sets. Biases the OR break direction against the swept level and displays the result in the HUD.

**Opening Candle Character: P6**
Classifies the first candle's body-to-range ratio and close position to identify institutional intent at the open.

---

**VWAP ENGINE**

Custom expanding-variance VWAP with +/-1 sigma and +/-2 sigma bands. Previous day VWAP computed from scratch and latched at session end. VWAP velocity and acceleration detection. Reclaim, reject, and retest signals with alert. VWAP zone classification displayed in HUD: Value Area / Trending / Exhausted.

**Session Volume Profile (SVP)**
Native integration via the SessionVolumeProfile library. Displays today's POC, VAH, and VAL in real time. Prior session POC (nPOC) used as a gravity magnet throughout the day. SVP warmup warning displayed on first session load.

---

**INSTITUTIONAL ORDER FLOW**

**Synthetic CVD (Cumulative Volume Delta)**
Reconstructs buyer vs seller pressure from candle structure without tick data. Divergence detection: price pivot high with CVD falling signals distribution (delta label above bar). Price pivot low with CVD rising signals accumulation (delta label below bar).

**RMI Oscillator**
14-period Relative Momentum Index, momentum length 3. Used internally across five systems: OR break score, gap trap override, tape confirmation, exhaustion colouring, and the divergence engine.

**RMI Regular Divergence**
Regular Bearish Divergence: price makes a higher high while RMI makes a lower high from an overbought zone. Distribution exhaustion signal, marked with a down arrow (▼D) above the bar.
Regular Bullish Divergence: price makes a lower low while RMI makes a higher low from an oversold zone. Accumulation exhaustion signal, marked with an up arrow (▲D) below the bar.
Fires on the confirmed bar where the RMI slope flips direction. Edge trigger only, no re-firing.

**SMT / RS-RW Divergence**
Structural divergence detection between Nifty and BankNifty across PDH, PDL, and VWAP levels. Includes magnitude Z-Score engine to grade divergence strength. Macro SMT (multi-day structural) tracked separately from intraday SMT. Correlation breakdown threshold configurable.

**Sequenced Trap: Fuel and Spark**
Detects the two-step institutional trap: sweep of a key level (Fuel) followed by a break failure (Spark). Requires both events within a configurable window to confirm. Separate alerts for trap detected and OR break trap.

---

**SECTOR BREADTH ENGINE: P10**

Monitors 10 NSE sector indices (Nifty Bank, IT, Auto, FMCG, Pharma, Metal, Energy, Realty, Infra, Media) against their individual VWAPs in real time. Breadth score, velocity state (Strong In / Neutral / Strong Out), and divergence from price displayed in the HUD Flow and Breadth rows. Three alerts: breadth divergence, velocity spike, HTF breadth confirmation.

**Basis / Carry Engine: P12**
Tracks Nifty futures basis (spot vs futures spread) as a proxy for institutional positioning bias. Carry direction and tight session flags displayed in the Breadth HUD row.

---

**EXPIRY STATE MACHINE: F4**

Four-phase expiry model: Normal, Pin Risk, Gamma, Final Hour. Automatically activates on expiry day (weekly or monthly, configurable). Displays expiry phase in the HUD header and fires transition alerts when the phase changes. Max-pain structural estimate alert when the level is established.

---

**LIQUIDITY ENGINE**

5-minute sweep detection on session high and low. 15-minute and 30-minute HTF sweep detection with separate pools for top and bottom sweeps. Higher Low and Lower High structure formation alerts. HTF sweep status displayed in HUD Tape row.

---

**FVG ENGINE: 1H Imbalance Map**

Detects Fair Value Gaps on the 1H timeframe and maps them as zones on lower timeframe charts. Active FVG direction (Bull / Bear / None) displayed in HUD Inst row. FVG proximity included in P1 confluence scoring.

**Doji Radar**
Advanced doji detection across configurable body/range thresholds. Active on hourly prep and execution tiers.

**M/W Pattern Detection (Double Top / Double Bottom)**
Two-bar swing structure engine tracking higher highs, higher lows, lower highs, lower lows. Double bottom (W) and double top (M) confirmations with labels and dedicated alerts. Recent M/W confirmation shown in HUD Tape row.

---

**MACRO CONTEXT**

**VIX Expected Move Bands**
Daily VIX ceiling and floor computed from India VIX. Weekly VIX bands for expiry boundary reference. ADR (Average Daily Range) used-percentage displayed in HUD and alerted at 90% exhaustion.

**Gap Classification**
Eight gap types: Gap-and-Go, Gap Fill, Flat Open, Gap Trap Bull/Bear, Gap Magnet, Gap Reversal. Gap strategy and percentage displayed in HUD Gap Strat row. Gap trap detection feeds directly into the tape exclusion rules.

**Daily EMA 21 and Weekly VWAP**
Macro bias reference. EMA 21 slope and position displayed in HUD macro context. Weekly VWAP displayed on applicable timeframes.

**Time-of-Day RVOL**
25-epoch intraday volume matrix using 5-bar windows across the session. Compares current bar volume to the historical average for that exact time of day. Anomaly detection with configurable threshold.

---

**HUD: 8-ROW CONSOLIDATED STATUS TABLE**

Live top-right table updating on every confirmed bar:

- **Gap Strat:** gap type, classification, gap percentage
- **Vol/ADR:** VIX regime, ADR used percentage
- **OR State:** break/retest/trap status, P1 confluence tags, colocation anchors
- **VWAP/Vol:** VWAP distance, zone classification, ToD RVOL
- **Inst/SMT:** SMT status, active FVG direction, RMI value with streak counter
- **Breadth:** sector breadth score, basis/carry, tight session flag
- **Flow:** breadth velocity, breadth divergence state
- **Tape/Align:** tape signal, exclusion reason, HTF breadth, recent M/W confirmation

On HTF charts (Daily and above), the HUD switches to a 6-row macro matrix showing macro bias, weekly VWAP, VIX range, ADR, 1H FVG, and nPOC. Auto-hides on Options and Stock charts to keep the chart clean.

---

**ALERTS: 23 CONDITIONS**

Trap Detected · OR Breakout · OR Retest · VWAP Interaction · Liquidity Sweep · Higher Low at Level · Lower High at Level · W-Pattern · M-Pattern · Breadth Divergence · Breadth Velocity Spike · OR Level High-Conviction Touch · Pre-OR Sweep · Activity Filter Activated · ADR Exhausted · VIX Band Touch · SMT / RS-RW Signal · Delta Divergence · Sequenced Trap · Expiry Phase Transition · Max-Pain Strike Set · RMI Regular Bear Divergence · RMI Regular Bull Divergence

All alerts are edge-triggered on confirmed bars. No intrabar spam.

---

**RECOMMENDED USAGE**

Best used on 3m or 5m charts for Nifty and BankNifty F&O intraday trading. Works on 1m for scalping and 15m for session-level context. Apply to the spot index (NIFTY, BANKNIFTY) or the front-month futures contract; auto-detection handles both. For options CE/PE premium charts, switch to a 1m or 3m options contract, and the engine decouples gap and VWAP calculations to the underlying automatically.

*Author: Murali Kumar ( x.com/@geekz) *

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
// IntraEdge v28.9 — NSE F&O Intraday Indicator
// Author: Murali Kumar (X: @geekz)
// ═══════════════════════════════════════════════════════════════════════════════
import jmosullivan/SessionVolumeProfile/12 as SVP

indicator(title="IntraEdgeV2", shorttitle="IntraEdgeV2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

const string INTRAEDGE_VERSION = "28.9"

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS: MASTER OPERATING MODE — v24 Universal 5-Mode Router
// ═══════════════════════════════════════════════════════════════════════════════
string grp_mode = "── Master Operating Mode ──"
// ═══════════════════════════════════════════════════════════════════════════════
// SESSION CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
int SESSION_OPEN      = 915
int OR_END_DEFAULT    = 930
int DEAD_ZONE_START   = 1200
int PM_START          = 1330
int PHASE4_START      = 1415
int SQUAREOFF_TIME    = 1515
int SESSION_CLOSE     = 1530
// AUTO-MODE DETECTION: Reads syminfo.type and syminfo.ticker to automatically select
// the correct operating mode when you switch charts.
// syminfo.type values: "index" = Nifty/BankNifty spot, "futures" = NIFTY1!/BANKNIFTY1!,
//                      "stock" = equities, "option"/"futures_options" = CE/PE contracts
// Override: turn off auto_mode and select manually if auto-detection is wrong.
bool   auto_mode        = input.bool(true, "⚡ Auto-Detect Mode from Chart", group=grp_mode,
                     tooltip="When ON: mode is automatically selected based on the chart instrument (index, futures, options, stock). Turn OFF to select manually.")
string gap_target_override = input.symbol("", "Gap Ref Symbol (Stock Options)", group=grp_mode, tooltip="Leave blank to auto-detect. Used if the options contract root differs from the underlying.")
string op_mode_manual   = input.string("Nifty Index / Futures", "Manual Mode (if Auto OFF)",
                     options=["Nifty Index / Futures", "BankNifty", "FinNifty", "MidCapNifty",
                              "Index Options", "Stocks", "Stock Options"],
                     group=grp_mode,
                     tooltip="Only used when Auto-Detect is OFF. Nifty/BankNifty: Full engine. Index Options: Gap decoupled. Stocks: RS/RW vs Nifty. Stock Options: RS/RW on underlying.")

// ── Auto-Detection Logic ──
// Detects: index (Nifty/BankNifty spot), futures (NIFTY1!/BANKNIFTY1!),
//          options/futures_options (CE/PE), stock (equities)
// NSE index instruments have type "index"; futures have type "futures"
// Options (NSE weekly/monthly): type "option" or "futures_options"
bool _auto_is_bnf     = str.contains(syminfo.ticker, "BANKNIFTY")
bool _auto_is_fin     = str.contains(syminfo.ticker, "FINNIFTY")
bool _auto_is_mid     = str.contains(syminfo.ticker, "MIDCPNIFTY")
bool _auto_is_nxt     = str.contains(syminfo.ticker, "NIFTYNXT50")
bool _auto_is_nifty   = str.contains(syminfo.ticker, "NIFTY") and not _auto_is_bnf and not _auto_is_fin and not _auto_is_mid and not _auto_is_nxt
bool _auto_is_option  = syminfo.type == "option" or syminfo.type == "futures_options"
bool _auto_is_futures = syminfo.type == "futures"
bool _auto_is_stock   = syminfo.type == "stock" or syminfo.type == "dr" or syminfo.type == "fund"
bool _auto_is_index   = syminfo.type == "index"

// Resolve auto mode string (single line — Pine v6 requires no line breaks in expressions)
string _auto_mode = _auto_is_option and (_auto_is_nifty or _auto_is_bnf) ? "Index Options" : _auto_is_option ? "Stock Options" : _auto_is_bnf and (_auto_is_futures or _auto_is_index) ? "BankNifty" : _auto_is_fin and (_auto_is_futures or _auto_is_index) ? "FinNifty" : _auto_is_mid and (_auto_is_futures or _auto_is_index) ? "MidCapNifty" : _auto_is_nifty and (_auto_is_futures or _auto_is_index) ? "Nifty Index / Futures" : _auto_is_stock ? "Stocks" : "Nifty Index / Futures"

string op_mode = auto_mode ? _auto_mode : op_mode_manual

// ═══════════════════════════════════════════════════════════════════════════════
// TIMEFRAME VISIBILITY ROUTER — 4-Tier Top-Down Architecture
// ═══════════════════════════════════════════════════════════════════════════════
// As you cycle Weekly → Daily → 4H → 1H → 5m, the indicator morphs to show
// only the institutional footprints relevant to that exact resolution.
// Math always runs globally — only the visuals change per tier.
int tf_mins = timeframe.isintraday ? timeframe.multiplier : (timeframe.isdaily ? 1440 : (timeframe.isweekly ? 10080 : 40320))

// _box_right: TF-aware session box right edge — declared after ist_t (line ~270).


bool is_micro_execution = tf_mins <= 15                         // 1m, 3m, 5m, 15m  → Full execution engine
bool is_hourly_prep     = tf_mins > 15 and tf_mins <= 60        // 30m, 1H           → Imbalance map + Dojis
bool is_4h_gravity      = tf_mins > 60 and tf_mins <= 240       // 2H, 3H, 4H        → Gravity magnets
bool is_macro_trend     = tf_mins >= 1440                       // Daily, Weekly      → Macro bias only

// Backward-compatible alias — gates all intraday micro-engines (OR, epochs, sweeps, phases)
bool is_htf_chart = not is_micro_execution

bool   auto_scale       = input.bool(true,  "Auto-Scale Math to Timeframe (1m/3m/5m)", group=grp_mode)
bool   auto_strike      = input.bool(true,  "Auto-Detect Strike Step (Indices)",        group=grp_mode)
int    manual_step      = input.int(50,     "Manual Strike Step (Stocks/Options)",       group=grp_mode)
// MINOR-2 FIX: Default raised from 14.0 → 16.5.
// In the 2024–2026 Indian equity regime, India VIX spends most of its time in the
// 13–20 range with a structural floor near 12–13. A 14.0 default placed the "neutral"
// anchor inside what is now historically the Low VIX zone, causing the ATR scaling and
// score gates to underestimate normal daily volatility in Stocks/Stock Options modes.
// 16.5 sits at the true midpoint of the observed neutral band (13–20) and correctly
// reflects the post-pandemic "new normal" for NSE equity volatility.
float vix_override_val = input.float(16.5, "VIX Neutral Value (Stocks/Stock Options mode)",
                     minval=10.0, maxval=30.0, step=0.5, group=grp_mode,
                     tooltip="Used when VIX is disabled in Stocks/Stock Options modes. Controls ATR scaling and score gates. Default 16.5 = calibrated to 2024-2026 NSE neutral regime (updated from 14.0). Raise during known high-volatility periods.")

string grp_risk = "── Risk Management ──"
is_expiry_day     = input.bool(false, "Today is Expiry Day ⚡", group=grp_risk,
                     tooltip="Toggles F4 Expiry State Machine logic. Activates Phase 3/4 ATR dampeners and gamma-risk HUD. Manual toggle mandatory on index expiry days (e.g. Tuesday/Thursday). Toggle OFF all other days.")

string grp_or = "── Opening Range ──"
or_range          = input.string("15 min (9:15-9:30)", "OR Range", options=["15 min (9:15-9:30)","30 min (9:15-9:45)"], group=grp_or)
// or_end_time       = input.int(930,  "OR End Time (HHMM IST)", minval=915, maxval=1000, group=grp_or)
include_first_5   = input.bool(false, "Include First 5 Mins (9:15-9:20)", group=grp_or)
body_confirm_pct  = input.float(80.0,"Body Confirmation Threshold (%)", minval=50.0, maxval=100.0, step=5.0, group=grp_or)
trap_cooldown_bars= input.int(10,   "Trap Cooldown (Bars)", minval=3, maxval=30, group=grp_or)
trap_quality_pct  = input.float(30.0,"Trap Candle Aggression (%)", minval=10.0, maxval=60.0, step=5.0, group=grp_or)
bool show_or_hl  = input.bool(true,  "Show OR High/Low", group=grp_or)
bool show_or_mid = input.bool(true,  "Show OR Mid Line",  group=grp_or)
bool show_f5     = input.bool(true,  "Show F5 (First 5m) High/Low", group=grp_or)
use_rmi_brk_score = input.bool(true, "Use Internal RMI for Breakout Score (5th Point)", group=grp_or, tooltip="When ON: OR breakout score gains a 5th momentum point using internal RMI latched at OR close. +1 if room to move, -1 if already exhausted. Score range -1 to 5. Default ON.")
use_rmi_retest    = input.bool(true, "Use RMI for Retest Quality Filter", group=grp_or, tooltip="When ON: retest labels show ✓ when RMI confirms the rejection, ⚠ when RMI contradicts it (breakout may continue). Default ON. Engine logic unaffected.")
bool show_t05  = input.bool(true,  "Show T+0.5 / T-0.5", group=grp_or)
bool show_t10  = input.bool(true,  "Show T+1.0 / T-1.0", group=grp_or)
bool show_t15  = input.bool(true,  "Show T+1.5 / T-1.5", group=grp_or)
bool show_t20  = input.bool(true,  "Show T+2.0 / T-2.0", group=grp_or)
bool show_coloc_zone = input.bool(true,  "Show OR-L/H + PrevVWAP Confluence Zone", group=grp_or, tooltip="When ON: draws a teal/amber shaded zone between OR-L and PrevVWAP (or OR-H and PrevVWAP) when they are within 30% of the average OR range of each other. Indicates a double-layer institutional support/resistance zone.")

string grp_doji = "── Advanced Doji Radar ──"
doji_threshold    = input.float(0.25,"1H Body Threshold",  group=grp_doji)
show_indecision   = input.bool(false, "Show Indecision Dojis",  group=grp_doji)
show_gravestone   = input.bool(false, "Show Gravestone Dojis",  group=grp_doji)
show_dragonfly    = input.bool(false, "Show Dragonfly Dojis",   group=grp_doji)

string grp_inst = "── Institutional Order Flow ──"
today_only_mode   = input.bool(false, "Today Only — Hide All Labels & Drawings on Historical Days", group=grp_inst, tooltip="When ON: all labels, boxes, and background colors are restricted to today's session only. Historical days show clean price bars with no drawings. OFF by default.\n\n⚠️ BAR REPLAY / BACKTESTING: Keep this OFF when using TradingView Bar Replay. The 'today' anchor is derived from last_bar_time (the final bar in the loaded dataset), not the simulated replay position — all drawings will be hidden for the entire replay until it reaches the actual last trading day.")
show_prev_day_lines = input.bool(true, "Show Previous Day Lines & Labels (PDH/PDL/PDC/PrevVWAP/POC/PWH/PWL/ADR)", group=grp_inst, tooltip="Turn OFF to hide all previous-day reference lines and labels. Keeps chart clean. Engine logic is unaffected.")
show_poc          = input.bool(true,  "Show Naked POC (Prev Day HVN)",              group=grp_inst)
show_pd_vwap      = input.bool(true,  "Show Prev Day VWAP",                         group=grp_inst)
show_sweeps       = input.bool(true,  "Show 5m Liquidity Sweeps (×)",               group=grp_inst)
show_sweeps_15    = input.bool(true,  "Show 15m Liquidity Sweeps (×15)",            group=grp_inst)
show_sweeps_30    = input.bool(true,  "Show 30m Liquidity Sweeps (×30)",            group=grp_inst)
show_nc           = input.bool(false, "Show Nested Compression (NC)",               group=grp_inst)
show_nc_15        = input.bool(true,  "Show NC on 15m",                             group=grp_inst)
show_nc_30        = input.bool(false,  "Show NC on 30m",                             group=grp_inst)
nc_strict         = input.bool(true,  "NC Strict Mode (Wicks)",                     group=grp_inst)
show_ib_15        = input.bool(true,  "Show 15m Inside Bar Compression (IB)",       group=grp_inst)
show_ib_30        = input.bool(true,  "Show 30m Inside Bar Compression (IB)",       group=grp_inst)
htf_label_offset  = input.float(0.5, "HTF Label Offset (ATR)", step=0.1, minval=0.0, maxval=3.0, group=grp_inst)
htf_swp_pct       = input.float(35.0, "HTF Sweep Wick % (15m/30m)", minval=10.0, maxval=50.0, step=5.0, group=grp_inst, tooltip="Min wick as % of 15m/30m candle range to qualify as a sweep. Lower = more signals. Default raised to 35% to reduce noise.")
swp_pct_5m        = input.float(25.0, "5m Sweep Wick %",            minval=10.0, maxval=50.0, step=5.0, group=grp_inst, tooltip="Min upper/lower wick as % of 5m candle range. Default 25% catches most institutional sweeps.")
show_adr          = input.bool(true,  "Show ADR Exhaustion",                        group=grp_inst)
show_fvg          = input.bool(true,  "Show True FVGs (Zones)",                     group=grp_inst)
max_fvg_zones     = input.int(15,    "Base Max FVGs (If Auto-Scale Off)",           group=grp_inst)
show_kz           = input.bool(true,  "Highlight NSE Kill Zones",                   group=grp_inst)
show_abs          = input.bool(true,  "Show Volume Absorption",                     group=grp_inst)
exh_lookback      = input.int(20,    "Exhaustion Lookback (Bars)", minval=5, maxval=50, step=5, group=grp_inst, tooltip="Number of bars for exhaustion swing high/low detection. On 3m chart: 10=30min, 20=60min, 30=90min. Higher = fewer, higher-quality signals. Default 20.")
exh_vol_pct       = input.float(250.0, "Exhaustion Volume Threshold (%)", minval=150.0, maxval=500.0, step=25.0, group=grp_inst, tooltip="Minimum ToD RVOL% required to confirm exhaustion. 200%=2× avg, 250%=2.5× avg. Higher = fewer, more institutional-grade signals. Default 250%.")
show_vwap_sig     = input.bool(true,  "Show VWAP Signals",                          group=grp_inst)
show_vwap_1sd     = input.bool(false,  "Show VWAP ±1σ Bands",                       group=grp_inst)
show_vwap_2sd     = input.bool(false, "Show VWAP ±2σ Bands",                       group=grp_inst)
bool show_p2_labels   = input.bool(false, "Show P2 Confluence Labels (OR H/L/Mid Scores)", group=grp_inst, tooltip="When ON: shows institutional touch labels on OR levels (e.g., OR-L +VA ↑5/9).")
bool show_brk_labels  = input.bool(false, "Show OR Breakout Score Labels", group=grp_inst, tooltip="When ON: shows the conviction score [5/5] next to OR breakout arrows.")
bool show_poc_labels  = input.bool(false, "Show POC Retest Labels", group=grp_inst, tooltip="When ON: shows 'POC BULL TEST' or 'POC BEAR TEST' labels on successful POC defenses.")
show_or_retest    = input.bool(true,  "Show OR Retest (Sniper)",                    group=grp_inst)
show_weekly       = input.bool(false, "Show Previous Week H/L",                     group=grp_inst)
show_hl_lh        = input.bool(false, "Show HL / LH Structure Signals",             group=grp_inst)
hl_atr_mult       = input.float(0.20, "HL/LH Proximity (ATR Multiplier)", minval=0.10, maxval=0.50, step=0.05, group=grp_inst, tooltip="Controls how close price must be to a key level to qualify as HL/LH. Lower = stricter, fewer signals. Default 0.20 (original was 0.30).")
hl_or_gate        = input.bool(true,  "HL/LH Labels: Show Only After OR Sets", group=grp_inst, tooltip="When ON: HL/LH labels only appear after the Opening Range is set. Eliminates pre-OR structure noise. Default ON.")
bool show_mw      = input.bool(true, "Show M/W Pattern (Double Top/Bottom)", group=grp_inst, tooltip="Detects W-Pattern (double bottom) and M-Pattern (double top) within the session. Requires HL/LH signals to be ON.")
float mw_match_prox_mult = input.float(0.15, "M/W Pattern Match Tolerance (ATR)", minval=0.05, maxval=0.30, step=0.05, group=grp_inst, tooltip="How close the two lows (W) or highs (M) must be. 0.15 = 15% of ATR. Lower = stricter.")
vix_anchor_src    = input.string("9:20 Open","VIX Anchor Source", options=["Day Open (9:15)","9:20 Open","9:30 Open","9:45 Open"], group=grp_inst)
show_trend_tape   = input.bool(true, "Show Trend & Tape Rows in HUD", group=grp_inst, tooltip="Trend: 3-layer confluence (VWAP behavior / Swing structure / EMA 21 slope). Tape: actionable WITH/AGAINST/WAIT verdict. Display only — zero engine impact.")
use_rmi_strategy  = input.bool(true, "Use Internal RMI for Strategy Pre-Warning", group=grp_inst, tooltip="When ON: during OR formation, if RMI is OB/OS and conflicts with gap direction, Strategy row shows Gap Trap Likely warning. After OR sets and breaks opposite to gap, overrides Trend Follow with Gap Trap. Default ON.")
use_rmi_tape      = input.bool(true, "Use Internal RMI for Tape Confirmation", group=grp_inst, tooltip="When ON: Tape WITH signal requires OR_close_rmi in room-to-move zone. Prevents entering when momentum already exhausted at OR close. Default ON.")
hud_header_col    = input.color(#88439E, "HUD Header Color", group=grp_inst, tooltip="Background color for the HUD header row. Default: institutional purple #88439E.")
show_main_hud     = input.string("Auto", "Show Main HUD Table", options=["Auto", "Always On", "Minimalist", "Always Off"], group=grp_inst, tooltip="Auto: Displays HUD on Index/Futures charts. Minimalist: Condenses table to a single row. Automatically hides HUD on Options and Stocks to maximize chart visibility.")

// ── Weekly Expected Move Bands ──
// Plots the full-week implied range (daily VIX × √5) on the intraday chart.
// These are the gamma-seller defense levels for the entire options expiry week.
// Most powerful on Thursday/Friday — price approaching these bands = highest-conviction reversals.
// Automatically suppressed on options charts (scale mismatch) and when VIX is disabled.
show_weekly_vix   = input.bool(true,  "Show Weekly Expected Move Bands", group=grp_inst, tooltip="Plots weekly options expiry range (VIX daily move × √5) on the intraday chart. The absolute boundaries gamma sellers defend all week. Disabled automatically on options charts.")

// ── 1H FVG Zones (HTF Imbalance Map) ──
// Detects Fair Value Gaps on the 1-Hour timeframe and draws them on the intraday chart.
// The most explosive 5m setups occur when price taps into an unfilled 1H FVG.
// FVGs are drawn as wide semi-transparent boxes extending forward until filled.
// Automatically suppressed on options charts (premium FVGs are meaningless — use index).
show_h1_fvg       = input.bool(true,  "Show 1H FVG Zones (HTF Imbalance)", group=grp_inst, tooltip="Draws unfilled 1-Hour Fair Value Gaps on the intraday chart. Price tapping a 1H FVG = institutional imbalance zone — highest-conviction entry area. Disabled automatically on options charts.")
max_h1_fvg        = input.int(3, "Max 1H FVG Zones (per side)", minval=1, maxval=5, group=grp_inst, tooltip="Maximum number of unfilled 1H FVGs to show per side (bull/bear). Lower = cleaner chart. Default 3.")

string grp_smt = "── Institutional SMT & Delta ──"
show_smt          = input.bool(true,  "Show SMT Divergence",                        group=grp_smt)
corr_ticker       = input.symbol("NSE:BANKNIFTY1!", "Correlated Index (SMT — Nifty/BNF modes only)",
                     group=grp_smt,
                     tooltip="Active only in Nifty Index/Futures and BankNifty modes. In Index Options, Stocks, and Stock Options modes this input is ignored — the router assigns the correlation target automatically.")
show_cvd_div      = input.bool(true,  "Show Synthetic CVD Divergences",             group=grp_smt)
smt_lookback      = input.int(10,     "SMT Swing Lookback (Bars)", minval=3, maxval=30, group=grp_smt, tooltip="Lower = More SMTs on small dips. Higher = Only major structural SMTs.")
smt_or_gate       = input.bool(true,  "SMT Labels: Show Only After OR Sets", group=grp_smt, tooltip="When ON: SMT labels only appear after the Opening Range is set. Eliminates unactionable pre-OR SMT noise. Engine logic (counters, fuel/spark, HUD) is unaffected.")
// ── RMI Regular Divergence inputs ──
show_rmi_div      = input.bool(true, "Show RMI Regular Divergence",     group=grp_smt)
rmi_div_piv_left  = input.int(5,    "RMI Div: Pivot Left Bars",  minval=2, maxval=20, group=grp_smt)
rmi_div_piv_right = input.int(3,    "RMI Div: Pivot Right Bars", minval=1, maxval=10, group=grp_smt)
corr_threshold     = input.float(0.3, "Correlation Breakdown Threshold", minval=0.0, maxval=0.9, step=0.05, group=grp_smt, tooltip="Threshold for identifying a breakdown in correlation between Nifty and BankNifty. Lower values are more strict.")



string grp_liq = "── F2: Liquidity Grading (v26) ──"
bool liquidity_grading_enable = input.bool(true, "Enable Liquidity-Aware Sizing", group=grp_liq,
     tooltip="In Stocks mode, classifies F&O stocks A/B/C by rolling turnover. Widens SL and filters setups on thin-book names.")
float f_liq_a_threshold = input.float(500.0, "A-grade Turnover Threshold (₹ Cr)", minval=100, group=grp_liq)
float f_liq_b_threshold = input.float(100.0, "B-grade Turnover Threshold (₹ Cr)", minval=25, group=grp_liq)

string grp_expfsm = "── F4: Expiry State Machine (v26) ──"
bool expiry_fsm_enable = input.bool(true, "Enable Expiry-Day Phase Logic", group=grp_expfsm)
int  f_expfsm_pinrisk_start  = input.int(1100, "Pin Risk Start (HHMM)",  minval=1000, maxval=1200, group=grp_expfsm)
int  f_expfsm_gamma_start    = input.int(1330, "Gamma Start (HHMM)",     minval=1300, maxval=1400, group=grp_expfsm)
int  f_expfsm_finalhr_start  = input.int(1445, "Final Hour Start (HHMM)",minval=1400, maxval=1515, group=grp_expfsm)
bool show_max_pain           = input.bool(true, "Show Max-Pain Estimate", group=grp_expfsm)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS: SESSION VOLUME PROFILE (SVP Library)
// ═══════════════════════════════════════════════════════════════════════════════
string grp_svp = "── Session Volume Profile ──"

int  svp_num_rows    = input.int(24,   "Number of Rows",
     minval=12, maxval=48, step=4,
     group=grp_svp,
     tooltip="Number of price levels to divide the session range into. " +
             "24 matches TradingView's built-in SVP default. " +
             "More rows = more precision but higher memory usage. " +
                           "Recommended: 24 or 16 on 1-minute charts to prevent memory pressure.")

int  svp_va_pct      = input.int(70,   "Value Area Coverage (%)",
     minval=60, maxval=80, step=5,
     group=grp_svp,
     tooltip="Percentage of session volume that defines the Value Area. " +
             "70% is market standard and matches TradingView's SVP default.")

bool svp_track_dev   = input.bool(true, "Track Developing Value Area",
     group=grp_svp,
     tooltip="When ON: today's developing POC/VAH/VAL update live throughout " +
             "the session. Used for live trail stop anchor and P1 confluence. " +
             "Turn OFF if indicator is slow — reduces computation on every bar.")

bool show_svp_yday_poc  = input.bool(true,  "Show Yday POC Line",
     group=grp_svp,
     tooltip="Yesterday's Point of Control — the price level with the highest volume " +
             "from the prior session. Strongest magnet for today's session. " +
             "Not available on Day 1 (SVP warmup). Auto-hides when svp_ready = false.")

bool show_svp_today_poc = input.bool(true,  "Show Today POC Line (Developing)",
     group=grp_svp,
     tooltip="Today's developing Point of Control — updates live as the session builds. " +
             "Requires 'Track Developing Value Area' to be ON. " +
             "Shows where the most volume has traded so far today.")

bool show_svp_today_va  = input.bool(true,  "Show Today VAH / VAL Lines (Developing)",
     group=grp_svp,
     tooltip="Today's developing Value Area High and Low — the price band containing " +
             "the configured % of session volume (default 70%). " +
             "Requires 'Track Developing Value Area' to be ON.")



// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS: SECTOR BREADTH + BASIS (P10 / P12)
// ═══════════════════════════════════════════════════════════════════════════════
string grp_breadth = "── Sector Breadth & Basis ──"

bool show_breadth = input.bool(true, "Show Sector Breadth (P10)",
    group=grp_breadth,
    tooltip="Tracks 5 core sectors (BANK/IT/ENERGY/FMCG/AUTO) vs their intraday VWAP. " +
            "Score +1 per sector above VWAP, -1 below. Range -5 to +5. " +
            "Strong Bull ≥+3 / Mixed -2 to +2 / Strong Bear ≤-3.")

bool show_basis = input.bool(true, "Show Futures Basis (P12)",
    group=grp_breadth,
    tooltip="Nifty futures premium/discount vs spot. Uses already-fetched futures " +
            "data — no extra security calls. Active in Nifty mode only.")

// ═══════════════════════════════════════════════════════════════════════════════
// SVP OBJECTS — Session Volume Profile
// ═══════════════════════════════════════════════════════════════════════════════
// todaySVP:     accumulates current session volume profile, live
// yesterdaySVP: snapshot of the completed prior session, latched at day open
// Both declared as var — must persist across bars
// ═══════════════════════════════════════════════════════════════════════════════
var todaySVP = SVP.Object.new(svp_num_rows, svp_va_pct)
todaySVP.trackDevelopingVa := svp_track_dev

var SVP.Object yesterdaySVP = na
var SVP.Object dayBeforeSVP  = na    // D-2 session profile
bool svp_ready = not na(yesterdaySVP) and not na(yesterdaySVP.pointOfControl) and yesterdaySVP.pointOfControl > 0
var int   poc_rising_bars      = 0     // consecutive bars where POC > POC[1]
var int   poc_falling_bars     = 0     // consecutive bars where POC < POC[1]
var int   bars_since_open      = 0

// Yesterday's completed session values (static for the day — never change)
float svp_yday_poc = svp_ready ? yesterdaySVP.pointOfControl : na
float svp_yday_vah = svp_ready ? yesterdaySVP.valueAreaHigh  : na
float svp_yday_val = svp_ready ? yesterdaySVP.valueAreaLow   : na

// Today's developing values (update each confirmed bar when svp_track_dev = true)
float svp_today_poc = svp_track_dev and not na(todaySVP.pointOfControl) ? todaySVP.pointOfControl : na
float svp_today_vah = svp_track_dev and not na(todaySVP.valueAreaHigh) ? todaySVP.valueAreaHigh : na
float svp_today_val = svp_track_dev and not na(todaySVP.valueAreaLow) ? todaySVP.valueAreaLow : na

// ── POC Cross + Retest State Machine ──
var bool  poc_crossed_up       = false // price crossed above today's POC with body confirmation
var bool  poc_crossed_dn       = false // price crossed below today's POC with body confirmation
var float poc_cross_price      = na    // POC value at the moment of cross (migration guard reference)
var int   poc_cross_bar        = na    // bar_index when cross happened (for time-window tagging)
var string poc_cross_t_str     = ""    // captured time string at cross
var bool  poc_retest_up_done   = false // bull retest has already fired this cross cycle
var bool  poc_retest_dn_done   = false // bear retest has already fired this cross cycle

// ── POC Adaptive Proximity & Cluster State (Addition G) ──
var float or_open_adr_pct    = na    // latches once at OR set, stable all session
var bool poc_cluster_latched = false // convergence event triggered

// ── POC Volume Trap State (Addition L) ──
var bool poc_breakout_armed  = false // set when poc_breakout_pending first fires
var bool poc_breakout_fail   = false // set when armed then closes back inside zone
var int  poc_breakout_dir    = 0     // direction of anticipated break (+1 up, -1 dn)
var label poc_trap_lbl       = na    // managed trap warning label

var int   poc_touch_count      = 0     // cumulative POC touches (both directions) since last cross
var array<float> poc_touch_vols = array.new<float>(6, na) // 0-2: bull last/prev/prev2, 3-5: bear
var bool _poc_bull_touch_prev  = false  // explicit series history tracker for touch deduplication
var bool _poc_bear_touch_prev  = false  // explicit series history tracker for touch deduplication


// ═══════════════════════════════════════════════════════════════════════════════
// LOGIC, DATA ROUTING & TIMEFRAME AGGREGATION
// ═══════════════════════════════════════════════════════════════════════════════
ist_h   = hour(time, "Asia/Kolkata")
ist_m   = minute(time, "Asia/Kolkata")
ist_t   = ist_h * 100 + ist_m

// Box right edge: bars remaining until session close (15:30 IST).
// Replaces the hardcoded bar_index+200 offset on all persistent session boxes.
// Uses tf_mins (line 68) and ist_t (just above) — both must be defined first.
// _ist_mins_now converts HHMM integer (e.g. 1030 -> 630 minutes from midnight).
// _bars_to_close = remaining minutes / bar width, rounded up. Minimum 2 bars.
int _ist_mins_now  = (ist_t / 100) * 60 + (ist_t % 100)
int _sess_end_mins = 15 * 60 + 30  // 930 minutes = 15:30 IST session close
var int _box_right_latched = na
int _bars_to_close = _ist_mins_now <= _sess_end_mins ? math.max(2, int(math.ceil(float(_sess_end_mins - _ist_mins_now) / float(tf_mins)))) : nz(_box_right_latched, bar_index + 200) - bar_index

if ist_t >= SESSION_OPEN and ist_t <= SESSION_CLOSE
    _box_right_latched := bar_index + _bars_to_close
int _box_right = nz(_box_right_latched, bar_index + 2)

// HTF: in_market must be true on every bar — IST session gating is meaningless on Daily/Weekly
// bars whose open timestamp is midnight IST, making ist_t = 0 and gating everything to false.
in_market  = is_htf_chart ? true : (ist_t >= SESSION_OPEN and ist_t <= SESSION_CLOSE)
is_new_day = ta.change(time("D")) != 0

var array<label> managed_lbls = array.new<label>(30, na)
if is_new_day
    for i = 0 to 29
        label.delete(array.get(managed_lbls, i))
        array.set(managed_lbls, i, na)


// ── Today-only gate — controlled by today_only_mode input ──
// OFF (default): is_today = true on all bars — all history draws normally
// ON:  is_today = true only on the most recent trading day — prior days completely clean
// NOTE: last_bar_time returns the dataset's FINAL bar — constant regardless of
// live/historical/replay position. In Bar Replay mode, is_today evaluates false
// for all replayed days until the actual last trading session. See input tooltip.
// Keep today_only_mode OFF during Bar Replay.
bool is_today = not today_only_mode or (
    dayofmonth(time, "Asia/Kolkata") == dayofmonth(last_bar_time, "Asia/Kolkata") and
    month(time,      "Asia/Kolkata") == month(last_bar_time,      "Asia/Kolkata") and
    year(time,       "Asia/Kolkata") == year(last_bar_time,       "Asia/Kolkata"))

// Expiry day — manually toggled by user each session.
// NSE schedule (April 2026): Nifty=Monday, BankNifty=Wednesday, FinNifty=Tuesday.
// Auto-detection was removed — NSE changes expiry days without warning.
// User toggles is_expiry_day ON at session start, OFF all other days.
bool is_expiry = is_expiry_day

// ── UNIVERSAL ROUTING MATRIX — v24 ──
bool   is_equity_mode       = op_mode == "Stocks" or op_mode == "Stock Options"
f_get_mode_data(_mode, _corr_ticker, _gap_override, _ticker_id, _prefix, _root) =>
    _smt_target           = ""
    _vol_target           = ""
    _gap_target           = ""
    _auto_strike_override = true
    _use_vix              = true
    if _mode == "Nifty Index / Futures"
        _smt_target          := _corr_ticker
        _vol_target          := "NSE:NIFTY1!"
        _gap_target          := _ticker_id
        _auto_strike_override := true
        _use_vix             := true
    else if _mode == "BankNifty"
        _smt_target          := "NSE:NIFTY1!"
        _vol_target          := "NSE:BANKNIFTY1!"
        _gap_target          := _ticker_id
        _auto_strike_override := true
        _use_vix             := true
    else if _mode == "Index Options"
        _smt_target          := str.contains(_ticker_id, "BANKNIFTY") ? "NSE:NIFTY1!" : "NSE:BANKNIFTY1!"
        _vol_target          := str.contains(_ticker_id, "BANKNIFTY") ? "NSE:BANKNIFTY1!" : "NSE:NIFTY1!"
        _gap_target          := str.contains(_ticker_id, "BANKNIFTY") ? "NSE:BANKNIFTY" : "NSE:NIFTY"
        _auto_strike_override := true
        _use_vix             := true
    else if _mode == "Stocks"
        _smt_target          := "NSE:NIFTY"
        _vol_target          := _ticker_id
        _gap_target          := _ticker_id
        _auto_strike_override := false
        _use_vix             := false
    else if _mode == "FinNifty"
        _smt_target          := "NSE:BANKNIFTY1!"
        _vol_target          := "NSE:FINNIFTY1!"
        _gap_target          := _ticker_id
        _auto_strike_override := true
        _use_vix             := true
    else if _mode == "MidCapNifty"
        _smt_target          := "NSE:NIFTY1!"
        _vol_target          := "NSE:MIDCPNIFTY1!"
        _gap_target          := _ticker_id
        _auto_strike_override := true
        _use_vix             := true
    else if _mode == "Stock Options"
        _smt_target          := "NSE:NIFTY"
        _underlying           = str.length(_gap_override) > 0 ? _gap_override : _prefix + ":" + _root
        _vol_target          := _underlying
        _gap_target          := _underlying
        _auto_strike_override := false
        _use_vix             := false
    [_smt_target, _vol_target, _gap_target, _auto_strike_override, _use_vix]

[smt_target, vol_target, gap_target, auto_strike_override, use_vix] = f_get_mode_data(op_mode, corr_ticker, gap_target_override, syminfo.tickerid, syminfo.prefix, syminfo.root)
bool  _use_ext_gap = gap_target != ticker.standard()
bool _is_options_chart = syminfo.type == "option" or syminfo.type == "futures_options"

// ── Optimized Volume Routing ──
float _spot_vol    = nz(volume)
bool  _use_ext_vol = vol_target != ticker.standard()
float _ext_vol     = _use_ext_vol ? nz(request.security(vol_target, timeframe.period, volume, lookahead=barmerge.lookahead_off)) : _spot_vol
r_vol = _ext_vol > 0 ? _ext_vol : _spot_vol
float vwap_vol = _use_ext_gap ? _spot_vol : r_vol

// ── Core Price & Session Data ──
r_high  = high
r_low   = low
r_close = close
float typ_price = (r_high + r_low + r_close) / 3

var float session_low  = na
var float session_high = na
if is_new_day
    session_low  := na
    session_high := na
if in_market and barstate.isconfirmed
    session_low  := math.min(nz(session_low, low),  low)
    session_high := math.max(nz(session_high, high), high)

float session_range      = session_high - session_low
day_open = request.security(syminfo.tickerid, "D", open,     lookahead=barmerge.lookahead_on)
[pd_high, pd_high2, pd_low, pd_low2, pd_close, pd_adr_5, d_ema21, d_rsi14] = request.security(syminfo.tickerid, "D", [high[1], high[2], low[1], low[2], close[1], ta.sma(high - low, 5)[1], ta.ema(close, 21)[1], ta.rsi(close, 14)[1]], lookahead=barmerge.lookahead_on)
float adr_used_pct = (pd_adr_5 > 0) ? (session_range / pd_adr_5) * 100.0 : 0.0

// ── ATR and Phase Dampeners ──
float pure_atr       = ta.atr(14)
float phase_dampener = (is_expiry and ist_t >= PM_START) ? 0.6 : 1.0
float current_atr    = pure_atr * phase_dampener

// ── VWAP Engine ──
var float _day_open_c = 0.0
if is_new_day or bar_index == 0
    _day_open_c := nz(day_open, typ_price)
var float cum_vol     = 0.0
var float cum_vol_px  = 0.0
var float cum_vol_px2 = 0.0
if is_new_day
    cum_vol      := 0.0
    cum_vol_px   := 0.0
    cum_vol_px2  := 0.0
if in_market and barstate.isconfirmed
    float tp_c   = typ_price - _day_open_c
    cum_vol      += vwap_vol
    cum_vol_px   += vwap_vol * typ_price
    cum_vol_px2  += vwap_vol * tp_c * tp_c
float vwap_val  = cum_vol > 0 ? cum_vol_px / cum_vol : typ_price

// ── OR & POC Proximity ──
var float or_h             = na
var float or_l             = na
var bool  or_set           = false
var float or_vol           = 0.0
var float[] daily_or_ranges   = array.new_float(0)
var float[] or_vol_history    = array.new_float(0)
float or_rng      = or_set ? or_h - or_l : na
float avg_or_rng  = array.size(or_vol_history) > 0 ? array.avg(daily_or_ranges) : or_rng
float _poc_prox_mult = na(or_open_adr_pct) ? 0.20 : or_open_adr_pct > 100 ? 0.15 : or_open_adr_pct < 50 ? 0.25 : 0.20
float _poc_prox = pure_atr * _poc_prox_mult
bool  poc_at_vwap = not _use_ext_gap and not na(vwap_val) and math.abs(svp_today_poc - vwap_val) <= _poc_prox

// Add a date-mismatch warning label at session open when is_expiry_day is ON
// but today is not a known NSE expiry weekday (Mon/Tue/Wed/Thu)
int _dow = dayofweek(time, "Asia/Kolkata")
bool _expiry_day_mismatch = is_expiry_day and _dow == dayofweek.friday
if _expiry_day_mismatch and barstate.islast
    label.new(bar_index, high, "⚠ Expiry toggle may be stale",
              style=label.style_label_down, color=color.orange, textcolor=color.white)

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE F4: Expiry-Day State Machine — v26.0
// ═══════════════════════════════════════════════════════════════════════════
// Purpose:        Phase-aware expiry behavior (pin risk, gamma, final hour)
// Triggers:       is_expiry = true
// Consumers:      Trade Engine phase4_block, Priority 1/2 conviction gates, HUD
// Dependencies:   is_expiry, ist_t
// Daily reset:    None needed (recomputes per-bar from ist_t)
// Security calls: 0
// Budget impact:  31 → 31/40

string f_expfsm_phase = "N/A"
if is_expiry and expiry_fsm_enable
    if ist_t < f_expfsm_pinrisk_start
        f_expfsm_phase := "Normal"
    else if ist_t < f_expfsm_gamma_start
        f_expfsm_phase := "PinRisk"
    else if ist_t < f_expfsm_finalhr_start
        f_expfsm_phase := "Gamma"
    else
        f_expfsm_phase := "FinalHour"

bool f_expfsm_is_pinrisk   = is_expiry and expiry_fsm_enable and f_expfsm_phase == "PinRisk"
bool f_expfsm_is_gamma     = is_expiry and expiry_fsm_enable and f_expfsm_phase == "Gamma"
bool f_expfsm_is_finalhour = is_expiry and expiry_fsm_enable and f_expfsm_phase == "FinalHour"

// Max-pain structural proxy — tight 5-bar range between 13:00-14:30
// NOTE: uses ta.atr(14) directly (not current_atr) because current_atr is declared
// at line ~848 and this block runs at line ~261. ta.atr(14) is a native Pine
// function that works without forward declaration. The phase_dampener applied
// to current_atr is irrelevant here — max-pain is a structural estimate, not
// a risk-sized value. Pure ATR is the correct reference for range compression.
var float f_expfsm_max_pain_est = na
if is_new_day
    f_expfsm_max_pain_est := na
float _global_h5    = ta.highest(high, 5)
float _global_l5    = ta.lowest(low, 5)
float _global_atr14 = ta.atr(14)

if is_expiry and show_max_pain and ist_t >= 1300 and ist_t <= 1430
    if svp_track_dev and not na(svp_today_poc) and (f_expfsm_is_pinrisk or f_expfsm_is_gamma)
        // Use developing POC as the institutional max pain reference (volume-based)
        f_expfsm_max_pain_est := svp_today_poc
    else
        // Fallback: original 5-bar compression heuristic
        float _range5 = _global_h5 - _global_l5
        if barstate.isconfirmed and not na(_global_atr14) and _range5 < _global_atr14 * 0.5
            if na(f_expfsm_max_pain_est) or math.abs(math.avg(_global_h5, _global_l5) - f_expfsm_max_pain_est) > _global_atr14
                f_expfsm_max_pain_est := math.avg(_global_h5, _global_l5)


plot(is_expiry and is_today and is_micro_execution and show_max_pain ? f_expfsm_max_pain_est : na,
     "Max Pain Est ~", color.new(color.fuchsia, 30), 2, plot.style_circles)

string f_expfsm_hud_txt = not (is_expiry and expiry_fsm_enable) ? "N/A" :
     f_expfsm_phase +
     (f_expfsm_is_finalhour ? " ⚠⚠ NO NEW ENTRIES" :
      f_expfsm_is_gamma     ? " ⚠ Gamma/Theta" :
      f_expfsm_is_pinrisk   ? " ⚠ Pin Risk" : "")
color f_expfsm_hud_col = not (is_expiry and expiry_fsm_enable) ? color.silver :
     f_expfsm_is_finalhour ? color.red :
     f_expfsm_is_gamma     ? #ffaa00 :
     f_expfsm_is_pinrisk   ? #ffee00 : #00ff88


int   tf          = timeframe.isintraday ? math.max(1, int(nz(str.tonumber(timeframe.period), 1))) : 1
int   d_fvg_cap   = auto_scale ? (tf >= 5 ? 5 : tf >= 3 ? 8 : 15) : max_fvg_zones
float d_abs_mult  = auto_scale ? (tf >= 5 ? 2.2  : tf >= 3 ? 2.0  : 2.5)  : 2.5
int   fvg_extend  = auto_scale ? int(math.max(6, 60 / tf)) : 12
int   launchpad_bars = int(math.max(1, 60 / tf))





// ═══════════════════════════════════════════════════════════════════════════════
// SVP DATA FETCH — Lower Timeframe Arrays
// ═══════════════════════════════════════════════════════════════════════════════
// getLowerTimeframe() returns:
//   "1" when chart is 1m–14m
//   "5" when chart is 15m–59m
//   This means on a 5m chart, it fetches 1m data — correct for NSE
//
// IMPORTANT: request.security_lower_tf() counts as 1 security call
// regardless of how many LTF bars are returned.
// Budget impact: +1 call → 27/40 total
//
// NSE note: session.ismarket behaves incorrectly in replay mode.
// The library's Session library fixes this internally via syminfo.prefix
// matching — NSE prefix should be recognized. Verify in Step 1.7 Test 5.
// ═══════════════════════════════════════════════════════════════════════════════
string _svp_ltf = SVP.getLowerTimeframe()

[_ltf_high, _ltf_low, _ltf_vol, _ltf_time, _ltf_is_market] = request.security_lower_tf(syminfo.tickerid, _svp_ltf, [high, low, volume, time, session.ismarket])

// ═══════════════════════════════════════════════════════════════════════════════
// SVP COMPUTATION AND DAY ROTATION
// ═══════════════════════════════════════════════════════════════════════════════
// DAY ROTATION LOGIC:
// session.isfirstbar fires on the first bar of each new session.
// At that moment, todaySVP holds the COMPLETE prior session profile.
// Copy it to yesterdaySVP before todaySVP resets for the new session.
//
// IMPORTANT: session.isfirstbar must be checked BEFORE SVP.get() runs.
// If get() runs first, it resets todaySVP at session start before the
// copy happens — yesterdaySVP would capture a fresh empty profile.
// Order is: (1) copy → (2) compute. Do not swap.
// ═══════════════════════════════════════════════════════════════════════════════

// Step 1: Day rotation — copy completed session to yesterday BEFORE get()
if session.isfirstbar
    // MAJOR FIX (Suggestion 3): Rotation order matters critically
    // dayBeforeSVP must be assigned from yesterdaySVP BEFORE yesterdaySVP is assigned from todaySVP
    if not na(yesterdaySVP)
        dayBeforeSVP := yesterdaySVP.copy()   
    if not na(todaySVP)
        yesterdaySVP := todaySVP.copy()



// Step 2: Populate todaySVP with lower timeframe data
SVP.get(todaySVP, _ltf_high, _ltf_low, _ltf_vol, _ltf_time, _ltf_is_market)

// ═══════════════════════════════════════════════════════════════════════════════
// SVP EXPOSED VARIABLES — Used by P1, P2, F09, F31, P9, HUD
// ═══════════════════════════════════════════════════════════════════════════════

// Readiness flag — false on the first session after indicator load
// All downstream features must guard with: if svp_ready

// Yesterday's completed session values (static for the day — never change)

// ── Suggestion 3: Multi-Day POC Cluster (Historical Scar Tissue) ──
float svp_d2_poc = not na(dayBeforeSVP) ? dayBeforeSVP.pointOfControl : na

// Proximity zone: adaptive based on OR-set ADR (Suggestion 1)

// Cluster detection: today's POC near prior sessions (Suggestion 3)
bool _is_d1_align = not na(svp_yday_poc) and math.abs(svp_today_poc - svp_yday_poc) <= _poc_prox
bool _is_d2_align = not na(svp_d2_poc)   and math.abs(svp_today_poc - svp_d2_poc) <= _poc_prox
bool poc_volume_cluster = svp_track_dev and not na(svp_today_poc) and (_is_d1_align or _is_d2_align)
string cluster_type_name = _is_d2_align ? "Multi-Day Cluster" : "POC Alignment"

if poc_volume_cluster and not poc_cluster_latched and barstate.isconfirmed
    poc_cluster_latched := true


// ── POC Migration Engine (Phase 1-B) ──
// Migration direction: compare today's POC to its value N bars ago
// Guard: bars_since_open >= 20 ensures we don't leak POC values from the prior session
float poc_20bar_ago = bars_since_open >= 20 ? svp_today_poc[20] : na


// Rising/falling consecutive bar counters
if barstate.isconfirmed
    poc_rising_bars  := svp_today_poc > svp_today_poc[1] ? poc_rising_bars + 1 : 0
    poc_falling_bars := svp_today_poc < svp_today_poc[1] ? poc_falling_bars + 1 : 0

// Migration velocity classification (5 states)
f_poc_migration_dir(int rising, int falling) =>
    rising >= 5 ? "↑↑" : rising >= 1 ? "↑" : falling >= 5 ? "↓↓" : falling >= 1 ? "↓" : "→"

string poc_migration_dir = f_poc_migration_dir(poc_rising_bars, poc_falling_bars)
// Migration flip detection (for alert)
bool poc_migration_flip_dn = poc_falling_bars == 1 and poc_rising_bars[1] >= 5
bool poc_migration_flip_up = poc_rising_bars  == 1 and poc_falling_bars[1] >= 5

float va_width_session = svp_track_dev and not na(svp_today_vah) and not na(svp_today_val) ? svp_today_vah - svp_today_val : na

// ── POC Regime State (Phase 1-C) ──
f_get_poc_regime(string _poc_migration_dir) =>
    float _thresh = current_atr * 0.30
    float _va_width_20 = not na(va_width_session[20]) ? va_width_session[20] : na
    bool _va_shrinking = not na(va_width_session) and not na(_va_width_20) and va_width_session < _va_width_20 * 0.85
    bool _va_expanding = not na(va_width_session) and not na(_va_width_20) and va_width_session > _va_width_20 * 1.15
    bool _poc_efficiency_move = (_poc_migration_dir == "↑↑" or _poc_migration_dir == "↑") and _va_shrinking
    bool _poc_discovery_move  = (_poc_migration_dir == "↑↑" or _poc_migration_dir == "↑") and _va_expanding
    bool _poc_efficiency_dn   = (_poc_migration_dir == "↓↓" or _poc_migration_dir == "↓") and _va_shrinking
    bool _poc_discovery_dn    = (_poc_migration_dir == "↓↓" or _poc_migration_dir == "↓") and _va_expanding
    string _poc_regime_tag = _poc_efficiency_move ? "Eff ▲" : _poc_discovery_move ? "Disc ▲" : _poc_efficiency_dn ? "Eff ▼" : _poc_discovery_dn ? "Disc ▼" : ""
    string _poc_regime_state = (svp_today_poc > vwap_val and math.abs(svp_today_poc - svp_today_vah) <= _thresh) ? "Trend ▲" : (svp_today_poc < vwap_val and math.abs(svp_today_poc - svp_today_val) <= _thresh) ? "Trend ▼" : (math.abs(svp_today_poc - vwap_val) <= _thresh and (svp_today_vah - svp_today_val) < avg_or_rng * 0.8) ? "Balanced" : (poc_rising_bars >= 1 and svp_today_poc > vwap_val + _thresh) ? "Expanding ▲" : (poc_falling_bars >= 1 and svp_today_poc < vwap_val - _thresh) ? "Expanding ▼" : "Value Area"
    [_poc_regime_tag, _poc_regime_state]

[poc_regime_tag, poc_regime_state] = f_get_poc_regime(poc_migration_dir)



// ── HVN / LVN Detection Helper ──
// volumeRows is map<int, float> in v5+ — key = row index, value = volume at that row
// priceLevelRows was removed in v5 — price levels computed from step and dayLow
// This function returns: 1 = HVN, -1 = LVN, 0 = neutral or no data
// Called ONLY when price is near OR levels — not on every bar
f_svp_node_type(_level, _vp_obj, _atr) =>
    int    _result    = 0
    // Guard against na UDT before accessing properties (prevents Day 1 crash)
    if not na(_vp_obj)
        float  _step      = _vp_obj.step
        float  _day_low   = _vp_obj.dayLow

        // Guard: need valid step and day_low to compute price levels
        if not na(_step) and _step > 0 and not na(_day_low) and map.size(_vp_obj.volumeRows) > 0
            // Total and average volume across all rows
            float _total_vol = 0.0
            int   _num_rows  = map.size(_vp_obj.volumeRows)

            for [_idx, _vol] in _vp_obj.volumeRows
                _total_vol += _vol

            float _avg_vol = _num_rows > 0 ? _total_vol / _num_rows : 0.0

            // Find which row our level falls into
            if _avg_vol > 0
                for [_idx, _vol] in _vp_obj.volumeRows
                    float _row_low  = _day_low + (_idx * _step)
                    float _row_high = _row_low + _step
                    // Check if our OR level falls within this row
                    if _level >= _row_low and _level < _row_high
                        if _vol > _avg_vol * 1.5
                            _result := 1    // HVN — high volume node
                        else if _vol < _avg_vol * 0.5
                            _result := -1   // LVN — low volume node
                        break               // Found our row, stop looping
    _result

 
// ── Underlying VWAP for Options Mode (must be computed before vwap_val) ──
// Requesting raw volume, price, and ±1σ/2σ bands from vol_target (NIFTY1!/BANKNIFTY1!)
// lookahead_on with same-timeframe security eliminates 1-bar lag.
[ext_u_vol, ext_u_hlc3, _u_v, _u_atr, _u_open, _u_close] = request.security(vol_target, timeframe.period, [volume, volume * hlc3, ta.vwap, ta.atr(14), open, close], lookahead=barmerge.lookahead_on)
float _u_up1 = _u_v + _u_atr * 1.0
float _u_dn1 = _u_v - _u_atr * 1.0
float _u_up2 = _u_v + _u_atr * 2.0
float _u_dn2 = _u_v - _u_atr * 2.0

// Local accumulators with confirmed reset logic
var float u_cum_vol = 0.0
var float u_cum_pv  = 0.0
var float u_pm_vol  = 0.0
var float u_pm_pv   = 0.0

if is_new_day and barstate.isconfirmed
    u_cum_vol := 0.0
    u_cum_pv  := 0.0
    u_pm_vol  := 0.0
    u_pm_pv   := 0.0

// Explicit 13:30 reset for PM VWAP
if (ist_t == PM_START) and barstate.isconfirmed
    u_pm_vol := 0.0
    u_pm_pv  := 0.0

if barstate.isconfirmed
    u_cum_vol += nz(ext_u_vol)
    u_cum_pv  += nz(ext_u_hlc3)
    if ist_t >= PM_START
        u_pm_vol += nz(ext_u_vol)
        u_pm_pv  += nz(ext_u_hlc3)

float _u_vwap_early = u_cum_vol > 0 ? u_cum_pv / u_cum_vol : na
float _u_pm_vwap    = u_pm_vol > 0  ? u_pm_pv / u_pm_vol   : na

// ── ATR and Phase Dampeners (moved up for VWAP band overrides) ──
avg_vol = ta.sma(r_vol, 20)

f_update_epoch_matrix(_is_new_day, _in_market, _r_vol, _idx, _d1, _d2, _d3, _d4, _d5, _cur, _is_confirmed) =>
    if _is_new_day and _is_confirmed
        array.clear(_d5)
        array.concat(_d5, _d4)
        array.clear(_d4)
        array.concat(_d4, _d3)
        array.clear(_d3)
        array.concat(_d3, _d2)
        array.clear(_d2)
        array.concat(_d2, _d1)
        array.clear(_d1)
        array.concat(_d1, _cur)
        array.fill(_cur, 0.0)
    
    if _in_market and _is_confirmed
        array.set(_cur, _idx, array.get(_cur, _idx) + _r_vol)
    
    float _s = 0.0
    int   _v = 0
    _v1 = array.get(_d1, _idx)
    _v2 = array.get(_d2, _idx)
    _v3 = array.get(_d3, _idx)
    _v4 = array.get(_d4, _idx)
    _v5 = array.get(_d5, _idx)
    
    if _v1 > 0
        _s += _v1
        _v += 1
    if _v2 > 0
        _s += _v2
        _v += 1
    if _v3 > 0
        _s += _v3
        _v += 1
    if _v4 > 0
        _s += _v4
        _v += 1
    if _v5 > 0
        _s += _v5
        _v += 1
        
    _v > 0 ? _s / _v : 0.0

// ── ToD RVOL Matrix State ──
var float[] epoch_cur = array.new_float(25, 0.0)
var float[] epoch_d1  = array.new_float(25, 0.0)
var float[] epoch_d2  = array.new_float(25, 0.0)
var float[] epoch_d3  = array.new_float(25, 0.0)
var float[] epoch_d4  = array.new_float(25, 0.0)
var float[] epoch_d5  = array.new_float(25, 0.0)

int _mins_since_open = (ist_h * 60 + ist_m) - (9 * 60 + 15)
int epoch_idx        = math.max(0, math.min(24, math.floor(_mins_since_open / 15)))

float h_avg = f_update_epoch_matrix(is_new_day, in_market and is_micro_execution, r_vol, epoch_idx, epoch_d1, epoch_d2, epoch_d3, epoch_d4, epoch_d5, epoch_cur, barstate.isconfirmed)

// Step 6: Compute ToD RVOL and anomaly threshold (MAJOR FIX: Time-of-Epoch Bias)
// Current epoch volume = what has accumulated so far in this 15-min block
float cur_epoch_vol  = array.get(epoch_cur, epoch_idx)
// MAJOR FIX: Prorate the historical average to match elapsed time in current epoch.
// Problem: cur_epoch_vol accumulates incrementally (1m → 5m → 10m → 15m of data),
// but we were dividing against the full 15-minute historical average.
// At 9:30 (5 min into the 9:30–9:45 epoch), cur_epoch_vol has only 5 minutes of
// volume. Dividing by the full 15-min h_avg makes tod_rvol near 0% at epoch start.
// Result: Exhaustion nodes were suppressed for the first 10 minutes of every epoch.
// MAJOR FIX v25.4: Use time_close to measure elapsed minutes in epoch (not time open)
// Problem: _mins_since_open uses bar open time. At 9:15 bar, _mins_since_open=0 → 0%15=0 → divisor=15/15=1.0
//          (divides tiny opening volume by full average, crushing RVOL to near zero)
//          At 9:20 bar, _mins_since_open=5 → divisor=5/15=0.33 but 10min of volume accumulated
//          (divides 10 min of volume by 3-min expectation → RVOL artificially doubled)
// Solution: Use time_close (end of bar) so accumulated volume always matches the prorated divisor
int _c_h = hour(time_close, "Asia/Kolkata")
int _c_m = minute(time_close, "Asia/Kolkata")
int _mins_since_open_close = (_c_h * 60 + _c_m) - (9 * 60 + 15)
int _mins_in_epoch = math.max(1, (_mins_since_open_close % 15) == 0 ? 15 : (_mins_since_open_close % 15))
float _prorated_h_avg = h_avg * (_mins_in_epoch / 15.0)
// MINOR-1 FIX: avg_vol (20-bar SMA) used as h_avg proxy on Day 1 warmup.
// When h_avg == 0 (no epoch history yet), the HUD previously showed "Warming Up"
// with no actionable data. avg_vol is a reasonable single-bar-resolution estimate
// of "normal" volume — not as accurate as the epoch matrix but far better than nothing.
// tod_rvol_warmup is computed as: current epoch accumulation vs the per-epoch
// equivalent of avg_vol (scaled from per-bar to per-15min-block by tf).
// This gives the user a "Basic RVOL" read on their first day with the indicator.
// Once the epoch matrix has ≥1 full trading day of data (h_avg > 0), it takes over.
float _h_avg_proxy  = h_avg > 0 ? _prorated_h_avg : (avg_vol * math.max(1, math.round(15.0 / tf)))
bool  _using_proxy  = h_avg == 0 and _h_avg_proxy > 0
float tod_rvol      = _h_avg_proxy > 0 ? (cur_epoch_vol / _h_avg_proxy) * 100.0 : 0.0
float tod_rvol_pct  = tod_rvol
// Time-aware anomaly threshold — PM/Dead Zone bar is set lower because volume naturally thins
// A 180% spike at 12:30 PM is far more significant than a 250% spike at 9:30 AM
float tod_threshold = (ist_t >= DEAD_ZONE_START and ist_t < PM_START) ? 180.0 : (is_expiry ? 200.0 : 250.0)
bool  tod_rvol_anomaly = _h_avg_proxy > 0 and not _using_proxy and tod_rvol >= tod_threshold
// Volume confirmation for exhaustion/absorption — bridges warmup when h_avg not yet available
bool  tod_vol_confirm  = h_avg > 0 ? (tod_rvol >= 200.0) : (r_vol > avg_vol * d_abs_mult)

// Fix M6: Collapse separate daily OHLC + ADR calls into tuple returns.
// Security call budget: 28 → 26 slots.
var float _u_vah = na
var float _u_val = na
[pw_high, pw_low, pw_vwap] = request.security(syminfo.tickerid, "W", [high[1], low[1], ta.vwap[1]], lookahead=barmerge.lookahead_on)
[pm_high, pm_low] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)
// pw_vwap moved to weekly tuple above
// PHASE 2B: Daily EMA 21 — institutional daily trend bias filter (+1 security call → 33/40)
// Tells you which side of the daily structure price is on before the session opens.
// Below d_ema21 = institutional sellers defending on every intraday rally.
// Above d_ema21 = institutional buyers absorbing every intraday dip.
// Uses close[1] (prior daily close) to avoid intraday repaint on live bar.
// d_ema21 and d_rsi14 moved to daily tuple above
string d_rsi_state = d_rsi14 > 70 ? "OB" : d_rsi14 < 30 ? "OS" : "Neutral"
color  d_rsi_col   = d_rsi14 > 70 ? color.red : d_rsi14 < 30 ? color.green : color.silver

float h4_ema21      = request.security(syminfo.tickerid, "240", ta.ema(close, 21)[1], lookahead=barmerge.lookahead_on)


bool d_above_ema21 = close > d_ema21
string d_ema21_bias = d_above_ema21 ? "Above ▲" : "Below ▼"
color  d_ema21_col  = d_above_ema21 ? #00ff88 : #ff4466

// ── Correlation / RS-RW Data Extraction — v24 ──
// smt_target routes to BankNifty (index modes) or NSE:NIFTY (equity modes)
// All downstream SMT/RS-RW math uses these variables — zero engine changes needed
[c_high, c_low, c_close] = request.security(smt_target, timeframe.period, [high, low, close], lookahead=barmerge.lookahead_off)
[c_pdh, c_pdh2, c_pdl, c_pdl2] = request.security(smt_target, "D", [high[1], high[2], low[1], low[2]], lookahead=barmerge.lookahead_on)
// BankNifty/benchmark ATR — used for SMT magnitude Z-score normalization
float c_atr_rs = request.security(smt_target, timeframe.period, ta.atr(14), lookahead=barmerge.lookahead_off)

// ── FEATURE: Correlation Breakdown (F8 Preview) ──
f_get_corr(_nifty_c, _peer_c) =>
    float _n_ret = ta.change(_nifty_c)
    float _p_ret = ta.change(_peer_c)
    ta.correlation(_n_ret, _p_ret, 20) < corr_threshold

// ── VIX Anchor Capture Logic (Hardened Chart-Scope) ──
var float _o920_chart = na
var float _o930_chart = na
var float _o945_chart = na
if ta.change(time("D", "Asia/Kolkata")) != 0
    _o920_chart := na
    _o930_chart := na
    _o945_chart := na
if ist_t >= 920 and na(_o920_chart)
    _o920_chart := open
if ist_t >= 930 and na(_o930_chart)
    _o930_chart := open
if ist_t >= 945 and na(_o945_chart)
    _o945_chart := open

float vix_anchor = vix_anchor_src == "Day Open (9:15)" ? day_open : vix_anchor_src == "9:20 Open" ? _o920_chart : vix_anchor_src == "9:30 Open" ? _o930_chart : vix_anchor_src == "9:45 Open" ? _o945_chart : day_open

bool is_correlation_broken = f_get_corr(c_close, close)

// use_vix = false in Stocks/Stock Options — VIX irrelevant for single-equity trading
// vix_override_val (input, default 16.5 — updated from 14.0, see MINOR-2 fix) keeps all
// VIX-dependent gates in neutral regime when live VIX feed is disabled
float vix_val = use_vix ? request.security("NSE:INDIAVIX", "D", close[1], lookahead=barmerge.lookahead_on) : vix_override_val
float implied_pct = vix_val / math.sqrt(365)
// implied_pts computed after gap engine defines _gap_u_open — see below gap engine section
string vix_state  = vix_val > 18 ? "High VIX ⚠" : vix_val < 13 ? "Low VIX ✓" : "Normal VIX"
// Fix m3: Single ternary replaces declare-then-reassign pattern
color vix_col = vix_val > 18 ? color.red : vix_val < 13 ? color.green : color.silver

// ── Strike Step — auto_strike_override = false in Stocks/Stock Options ──
// Prevents auto-step from locking to 50/100 increments on stock price charts
int dynamic_step = manual_step
if auto_strike and auto_strike_override
    bool is_bnf    = op_mode == "BankNifty" or str.contains(syminfo.ticker, "BANKNIFTY")
    bool is_fin    = op_mode == "FinNifty" or str.contains(syminfo.ticker, "FINNIFTY")
    bool is_mid    = op_mode == "MidCapNifty" or str.contains(syminfo.ticker, "MIDCPNIFTY")
    bool is_sensex = str.contains(syminfo.ticker, "SENSEX")
    dynamic_step  := (is_bnf or is_sensex) ? 100 : (is_mid ? 25 : 50)

// ═══════════════════════════════════════════════════════════════════════════════
// PHASE 2A: Weekly Anchored VWAP (Native — zero security calls)
// ═══════════════════════════════════════════════════════════════════════════════
// Resets every Monday at the open of the first bar of the week.
// F&O desks watch this level for weekly positioning bias — if Nifty is below
// weekly VWAP mid-week, institutions are underwater and defending on every rally.
// Uses the same volume routing as the intraday engine (r_vol, already computed).
// Note: r_vol is set later in the script — w_vwap uses volume directly here
// since r_vol depends on ext_vol which requires _use_ext_gap (already declared).
// M3 FIX: Reset on confirmed Monday IST open bar only — prevents spurious Saturday resets
// (special NSE Muhurat sessions can produce Saturday bars that change time("W"))
bool is_new_week   = dayofweek(time, "Asia/Kolkata") == dayofweek.monday and is_new_day
f_get_weekly_vwap(_is_new_week, _vol, _price, _h, _l, _is_confirmed) =>
    var float _cum_vol = 0.0
    var float _cum_pv  = 0.0
    var float _h_week  = na
    var float _l_week  = na
    
    if _is_new_week
        _cum_vol := 0.0
        _cum_pv  := 0.0
        _h_week  := _h
        _l_week  := _l
    else
        _h_week := math.max(nz(_h_week, _h), _h)
        _l_week := math.min(nz(_l_week, _l), _l)
    
    if _is_confirmed
        _cum_vol += _vol
        _cum_pv  += _vol * _price
    [_cum_vol > 0 ? _cum_pv / _cum_vol : na, _h_week, _l_week]

// f_render_htf_hud removed — superseded by inline rendering in Phase 8 block


[w_vwap, cur_week_h, cur_week_l] = f_get_weekly_vwap(is_new_week, nz(r_vol), typ_price, high, low, barstate.isconfirmed)

float pw_range = not na(pw_high) and not na(pw_low) ? pw_high - pw_low : na
float cur_week_range = not na(cur_week_h) and not na(cur_week_l) ? cur_week_h - cur_week_l : na
float w_range_consumed_pct = not na(pw_range) and pw_range > 0 ? math.min(100, (cur_week_range / pw_range) * 100) : na
string w_range_consumed_txt = not na(w_range_consumed_pct) ? str.tostring(w_range_consumed_pct, "#.#") + "% W range" : "N/A"
color  w_range_consumed_col = not na(w_range_consumed_pct) ? (w_range_consumed_pct > 90 ? color.red : w_range_consumed_pct > 70 ? #ffee00 : color.aqua) : color.silver

// ── Custom Expanding Variance VWAP Engine ──
// Vwap Volume Routing

// ── Prev Day VWAP — computed from scratch, latched at session end ──
// Accumulates today's typ_price*vol, latches into prev_vwap at next day open.
// Also accumulates squared terms (compensated) to latch prev day ±1σ bands.
// More reliable than request.security(ta.vwap[1]) which drifts on live bars.
var float _pv_cum_vol     = 0.0
var float _pv_cum_vol_px  = 0.0
var float _pv_cum_vol_px2 = 0.0   // squared accumulator for prev day stdev
var float _prev_vwap_latch = na
var float _pd_stdev_latch  = 0.0  // latched at session end — prev day σ
var float _pd_open_c       = 0.0  // compensation constant for prev day variance

if is_new_day
    _prev_vwap_latch := _pv_cum_vol > 0 ? _pv_cum_vol_px / _pv_cum_vol : na
    // Compute prev day stdev using compensated variance — same method as today's VWAP engine
    if _pv_cum_vol > 0 and not na(_prev_vwap_latch)
        float _pv_vwap_c = _prev_vwap_latch - _pd_open_c
        float _pv_var    = math.max(0, (_pv_cum_vol_px2 / _pv_cum_vol) - (_pv_vwap_c * _pv_vwap_c))
        _pd_stdev_latch := math.sqrt(_pv_var)
    else
        _pd_stdev_latch := 0.0
    _pd_open_c      := nz(day_open, typ_price)  // latch new day's compensation constant
    _pv_cum_vol     := 0.0
    _pv_cum_vol_px  := 0.0
    _pv_cum_vol_px2 := 0.0

if in_market and barstate.isconfirmed
    float _pv_tp_c  = typ_price - _pd_open_c
    _pv_cum_vol    += vwap_vol
    _pv_cum_vol_px += vwap_vol * typ_price
    _pv_cum_vol_px2 += vwap_vol * _pv_tp_c * _pv_tp_c

float prev_vwap    = _prev_vwap_latch
float pd_stdev     = _pd_stdev_latch
// Previous day Value Area High/Low — used for gap magnet qualifier
// pd_vwap_up1 = prev VWAP + prev σ = yesterday's VAH
// pd_vwap_dn1 = prev VWAP - prev σ = yesterday's VAL
float pd_vwap_up1  = not na(prev_vwap) ? prev_vwap + pd_stdev : na
float pd_vwap_dn1  = not na(prev_vwap) ? prev_vwap - pd_stdev : na

// carry_bias: compares pd_close vs prev_vwap — both on the chart's instrument
// In options/stock modes these are premium/stock values — no institutional carry meaning
// Show N/A in these modes to prevent misleading directional bias in HUD
string carry_bias = ""
color  carry_col  = color.gray
if is_equity_mode or op_mode == "Index Options"
    carry_bias := "N/A"
    carry_col  := color.new(color.gray, 30)
else
    if svp_ready and not na(svp_yday_poc)
        carry_bias := pd_close > prev_vwap and pd_close > svp_yday_poc ? "Strong Bull Carry" :
                      pd_close > prev_vwap                             ? "Bull Carry"        :
                      pd_close < prev_vwap and pd_close < svp_yday_poc ? "Strong Bear Carry" :
                                                                          "Bear Carry"
    else
        carry_bias := pd_close > prev_vwap ? "Bull Carry" : "Bear Carry"

// ── Live Carry Bias Intraday (Phase 3-H) ──
// Static carry_bias uses pd_close vs prev_vwap (computed once, pre-session).
// Live carry: uses current close vs today's POC vs current session VWAP.
string live_carry_status = ""
if svp_track_dev and not na(svp_today_poc) and not _use_ext_gap and in_market
    live_carry_status := close > svp_today_poc and close > vwap_val ? " ✓Live" : close < svp_today_poc and close < vwap_val ? " ✗Live" : close > svp_today_poc and close < vwap_val ? " ~mixed" : close < svp_today_poc and close > vwap_val ? " ~mixed" : ""

    carry_col  := carry_bias == "Strong Bull Carry" ? #00ff88 :
                  carry_bias == "Bull Carry"         ? #00bb66 :
                  carry_bias == "Strong Bear Carry"  ? #ff4466 :
                  carry_bias == "Bear Carry"         ? #cc2244 : color.gray

// ── Tight Prior Session Detection (VAL or VAH near PrevVWAP) ──
// Uses pd_stdev (prior day volume-weighted σ) as the threshold.
// When VAL ≈ pVWAP within 0.5σ: yesterday's lower value area was at VWAP level —
// extremely tight bullish balance, buyers accepted right up to the mean.
// When VAH ≈ pVWAP within 0.5σ: yesterday's upper value area was at VWAP level —
// extremely tight bearish balance, sellers capped at the mean.
// pd_stdev = 0 on Day 1 — the pd_stdev > 0 guard prevents false fires.
float _tight_thresh  = pd_stdev * 0.5
bool  val_pvwap_tight = svp_ready and not na(svp_yday_val) and not na(prev_vwap) and
      pd_stdev > 0 and math.abs(svp_yday_val - prev_vwap) <= _tight_thresh
bool  vah_pvwap_tight = svp_ready and not na(svp_yday_vah) and not na(prev_vwap) and
      pd_stdev > 0 and math.abs(svp_yday_vah - prev_vwap) <= _tight_thresh
string _tight_tag = val_pvwap_tight ? " · Tight↑" : vah_pvwap_tight ? " · Tight↓" : ""

// ── nPOC — v27 Phase 2: SVP Real POC ──
// Source upgraded from single-bar highest-volume proxy to SVP library POC.
// The old proxy (highest r_vol bar's typ_price) was a rough approximation —
// it finds the bar with the most volume but not necessarily the price level
// with the most total volume across all bars at that price.
// SVP correctly accumulates volume across all bars at each price level.
//
// Fallback: when SVP is warming up (day 1), prev_poc falls back to the
// old single-bar proxy so POC display is never blank on first load.
//
// The old accumulator variables (daily_high_vol, daily_poc_price) are kept
// ONLY as the warmup fallback. They are not used when svp_ready = true.
// Do not remove them — they ensure correct behavior on day 1.

var float daily_high_vol  = 0.0
var float daily_poc_price = na

if is_new_day
    daily_high_vol  := 0.0
    daily_poc_price := na

if in_market and barstate.isconfirmed and r_vol > daily_high_vol
    daily_high_vol  := r_vol
    daily_poc_price := typ_price

// prev_poc: SVP real POC when ready, old proxy as fallback
// This is the single variable all downstream code references
var float prev_poc = na
if is_new_day
    prev_poc := svp_ready ? svp_yday_poc : daily_poc_price

// Numerically stable variance using compensated summation.
// Problem with naive formula E[X²] - E[X]²: both terms are ~24000² ≈ 576,000,000
// Subtracting two nearly-equal large floats causes catastrophic cancellation → stdev ≈ 0.
// Problem with Welford: its internal mean diverges from true VWAP (cum_vol_px/cum_vol)
// because it uses a plain incremental average, not volume-weighted VWAP → σ bands drift.
// Fix: shift typ_price by day_open (compensation constant c) before squaring.
// tp_c = typ_price - day_open ≈ ±200 pts → tp_c² ≈ 40,000 (no cancellation risk)
// Identity: Var(X) = Var(X - c), so stdev is correct and centered on true VWAP. ✓
// nz(day_open, typ_price) guards against na on first bar — fallback to typ_price (c=0, safe).
// Compensation constant is latched at session start so it stays fixed all day.
float _vwap_c = vwap_val - _day_open_c
float _var    = cum_vol > 0 ? math.max(0, (cum_vol_px2 / cum_vol) - (_vwap_c * _vwap_c)) : 0.0
float stdev   = math.sqrt(_var)

float nearest_npoc = na
if not na(prev_poc)
    nearest_npoc := prev_poc

float vwap_up1  = vwap_val + stdev
float vwap_dn1  = vwap_val - stdev
float vwap_up2  = vwap_val + (stdev * 2)
float vwap_dn2  = vwap_val - (stdev * 2)

// Override with true underlying VWAP and bands in options mode
// Eliminates proxy ATR bands in favor of institutional futures levels.
if _use_ext_gap and not na(_u_v)
    vwap_val := _u_v
    vwap_up1 := _u_up1
    vwap_dn1 := _u_dn1
    vwap_up2 := _u_up2
    vwap_dn2 := _u_dn2

// MINOR FIX v25.3: Remove barstate.isconfirmed from boolean — HUD must read live
// Problem: isconfirmed on the boolean means HUD Strategy row only shows "RUNAWAY" for
//          a split second at bar close — useless warning during a massive candle forming
// Solution: Keep boolean live so HUD reads it intrabar. Move isconfirmed gate to alert
//           only (prevents phone spam while preserving real-time visual warning)
bool is_hyper_momentum = not _use_ext_gap and in_market and (r_close > vwap_up2 or r_close < vwap_dn2)

// UI Latch: locks true for the remainder of the bar once breached
var bool is_hyper_momentum_bar = false
if barstate.isnew
    is_hyper_momentum_bar := false
if is_hyper_momentum
    is_hyper_momentum_bar := true

// ── Value Area State Engine — Feature A ──
// VAH = vwap_up1 (+1σ), VAL = vwap_dn1 (-1σ) — contains ~68% of day's volume
// Three states drive Tape and Gap Magnet logic:
// F14 Value Area Engine removed in v27 Phase 0
// Placeholder for Phase 2 SVP migration logic

// ── Synthetic CVD Engine ──
float bar_rng = high - low
float delta   = 0.0
if bar_rng > 0
    // True synthetic delta — weights close vs full candle range, not just body.
    // Formula: vol × (2c - h - l) / (h - l)
    // Old formula (close - open) / range misses wick-dominant candles (hammers, shooting stars)
    // where the institutional absorption IS the wick, not the body.
    // A hammer closing +5pts in a 100pt range: old = 5/100 ≈ 0, new = (2c-h-l)/range > 0 → bullish ✓
    delta := r_vol * ((2.0 * close - high - low) / bar_rng)
else if r_vol > 0
    // MAJOR (R8) FIX: Fallback delta for zero-range candles (Open=High=Low=Close, bar_rng=0).
    // These occur on deep OTM or newly-listed option strikes — a doji with volume represents
    // real institutional activity (e.g. large block at the ask = aggressive buying even on flat bar).
    // Leaving delta = 0.0 silently discards that volume from cum_delta, artificially suppressing
    // the CVD line exactly before explosive directional moves in illiquid strikes.
    // Fix: infer direction from the prior close — if this bar's close > prior close, all
    // volume is attributed to the buy side. If close < close[1], sell side. If close == close[1], 0.0.
    delta := r_vol * (close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0)

var float cum_delta       = 0.0
var float pivot_low_cvd   = 0.0
var float pivot_high_cvd  = 0.0

if is_new_day
    cum_delta := 0.0
if in_market and barstate.isconfirmed
    cum_delta += delta

bool cvd_is_pivot_low  = low  == ta.lowest(low,   5)
bool cvd_is_pivot_high = high == ta.highest(high,  5)

// MAJOR-1 FIX: Two-tier CVD architecture.
//
// Tier 1 — Price pivot anchor (confirmed only):
//   pivot_low_cvd / pivot_high_cvd latch cum_delta at confirmed bar close.
//   Rationale: the PRICE level of the pivot (low/high) is what we compare structure against.
//   We need the delta that resolved at that confirmed structural price level.
//   Intrabar latch would capture a delta value before the candle's full order flow settled.
//
// Tier 2 — Live divergence read (current cum_delta, unrestricted):
//   The COMPARISON in cvd_bull_div / cvd_bear_div uses cum_delta directly (not [1]).
//   cum_delta on the current bar reflects all order flow received so far this candle.
//   On a fast Nifty reversal the divergence signal is visible mid-candle in cum_delta —
//   gating the comparison to barstate.isconfirmed would delay the δ label by one full bar,
//   making it useless for the execution entry it is designed to support.
//   barstate.isconfirmed is retained only on the label draw calls to prevent phantom labels.
//
// Result: pivot anchor = clean confirmed data | divergence comparison = live, zero lag.
if barstate.isconfirmed
    if cvd_is_pivot_low
        pivot_low_cvd  := cum_delta
    if cvd_is_pivot_high
        pivot_high_cvd := cum_delta

bool close_upper_half = close > low + (bar_rng * 0.5)
bool close_lower_half = close < low + (bar_rng * 0.5)

// Live cum_delta used for divergence comparison — see MAJOR-1 comment above.
// Label draw gated on barstate.isconfirmed below to prevent phantom intrabar labels.
bool _cvd_enabled = show_cvd_div and op_mode != "Stocks" and not _is_options_chart
bool cvd_bull_div = _cvd_enabled and cvd_is_pivot_low  and low  < low[5]  and cum_delta > pivot_low_cvd[5]  and close_upper_half
bool cvd_bear_div = _cvd_enabled and cvd_is_pivot_high and high > high[5] and cum_delta < pivot_high_cvd[5] and close_lower_half

color cvd_bull_col = #00bb66
color cvd_bear_col = #ff2244

// MINOR-1 FIX: Expiry-day ATR dampener for Phase 3/4.
// Problem: ta.atr(14) looks back 70 minutes (14 bars on 5m) — on expiry day after 13:30,
// this window includes midday chop where an OTM option was moving 5–10 pts/bar.
// By 14:00–14:30 (Phase 4), the same OTM option may be decaying toward zero with
// 0.5 pt/bar movement. A 14-bar ATR of 7 pts produces stops that are 14× too wide,
// making the risk engine structurally unable to protect capital in late-expiry decay.
// Dampener: 0.6× applied only when is_expiry AND ist_t >= PM_START (Phase 3+).
// This tightens SL distances and label offsets without touching any engine logic.
// Non-expiry days: phase_dampener = 1.0 (zero impact, identical to original).
// Expiry Phase 1/2 (9:15–13:30): phase_dampener = 1.0 (gamma not dominant yet).
// Expiry Phase 3/4 (13:30+): phase_dampener = 0.6 (gamma/theta regime correction).
// 0.6 is a conservative choice — review against live Nifty expiry data and adjust.
//
// CRITICAL-2 FIX: Decouple pure mathematical ATR from risk-adjusted ATR.
// Problem: phase_dampener was applied directly to current_atr, which is then used as the
// denominator in SMT Z-score distance normalization (line ~1625). At exactly 13:30,
// the denominator shrinks 40%, causing _bull_nifty_dist to spike by ~66% in a single tick.
// This creates a statistically invalid discontinuity in the 20-bar rolling stdev window,
// blowing up the Z-score and triggering false 4.0σ+ clusters during late-expiry moves.
// Solution: Compute pure_atr (true mathematical ATR) separately. Use it for all SMT/Z-score
// math. Use current_atr (dampened) only for risk/SL positioning. This preserves statistical
// geometry through the 15:30 close.
//
// MINOR NOTE — Intentional step-function at 13:30 on expiry:
// current_atr drops 40% at exactly 13:30 IST on expiry days. This is by design —
// the gamma/theta regime genuinely changes at that timestamp. However, any trailing
// stop anchored to current_atr (e.g. rolling_low_3 - current_atr * 0.1) will show
// a 1-bar visual shift at 13:30. This is NOT a repaint — the SL moves in the
// profit direction (tightening). Inform users: the jump at 13:30 on expiry is
// expected behavior reflecting the shift from trend-following to decay-protection mode.
// current_atr moved up to line 420 to support VWAP band overrides

// ── FEATURE: VWAP Velocity & Acceleration ──
f_get_vwap_velocity(_vwap, _atr, _mintick) =>
    float _slope_raw = (_vwap - nz(_vwap[10], _vwap)) / 10
    float _slope_atr = _slope_raw / math.max(_mintick, (_atr / 10))
    [_slope_atr > 0.2, _slope_atr < -0.2]

[is_vwap_trending_up, is_vwap_trending_dn] = f_get_vwap_velocity(vwap_val, current_atr, syminfo.mintick)

var label _cvd_bull_lbl = na
var label _cvd_bear_lbl = na
if cvd_bull_div and barstate.isconfirmed and is_today and not (is_equity_mode or _is_options_chart)
    label.delete(_cvd_bull_lbl)
    _cvd_bull_lbl := label.new(bar_index, low  - (current_atr * 0.6), "δ", style=label.style_none, textcolor=cvd_bull_col, size=size.small)
if cvd_bear_div and barstate.isconfirmed and is_today and not (is_equity_mode or _is_options_chart)
    label.delete(_cvd_bear_lbl)
    _cvd_bear_lbl := label.new(bar_index, high + (current_atr * 0.6), "δ", style=label.style_none, textcolor=cvd_bear_col, size=size.small)
// ── Persistent Arrays & State ──

// ── HTF Sweep OHLC — Live series with natural repaint protection ──
// CRITICAL-1 FIX: Reverted from high[1] + lookahead_on back to live series.
// Problem: high[1] with lookahead_on on a 5m chart evaluating 15m HTF was fetching
// the 15m bar from 15–30 minutes PRIOR, completely missing current price action.
// Example: At 9:30, is_15m_close fires correctly, but h15_high was analyzing 9:00–9:15,
// missing the 9:15–9:30 wick you're trying to evaluate for sweep detection.
// Solution: Use live series (high, not high[1]). The is_15m_close AND barstate.isconfirmed
// double gate ensures these are ONLY evaluated on the exact tick the HTF bar closes.
// This naturally prevents intrabar repaint — the state machine handles it.
// Result: Sweeps now analyze current real-time price action, not lagged data.
// CRITICAL FIX v25.2: Restore lookahead_on for historical backtesting alignment
// Problem: Without lookahead_on, historical engine returns data from PREVIOUS completed HTF bar
// Solution: Use lookahead_on but gate strictly via is_15m_close AND barstate.isconfirmed
// Result: Historical backtest matches live execution; no repaint (state machine prevents it)
f_get_nc() => [high, high[1], high[2], low, low[1], low[2], open, open[1], open[2], close, close[1], close[2]]
// ── HTF Synchronization Matrix ──
// [SC-ISSUE-3] ARCHITECTURAL NOTE: Uses dual-gate (is_HTF_close AND barstate.isconfirmed) 
// to synchronize 15m/30m data from a 5m chart. lookahead_on provides the forming bar's 
// high/low/close, but the gates ensure we only act on fully confirmed HTF candles.
[h15_high, _h15_h1, _h15_h2, h15_low, _h15_l1, _h15_l2, h15_open, _h15_o1, _h15_o2, h15_close, _h15_c1, _h15_c2] = request.security(syminfo.tickerid, "15", f_get_nc(), lookahead=barmerge.lookahead_on)
[h30_high, _h30_h1, _h30_h2, h30_low, _h30_l1, _h30_l2, h30_open, _h30_o1, _h30_o2, h30_close, _h30_c1, _h30_c2] = request.security(syminfo.tickerid, "30", f_get_nc(), lookahead=barmerge.lookahead_on)

// ── PM Session VWAP ──
var float pm_cum_vol    = 0.0
var float pm_cum_vol_px = 0.0
// MINOR-4 NOTE: is_pm_start uses na(ist_t[1]) to handle the first bar of the dataset.
// Edge case: if the chart is loaded mid-session (e.g. at 13:35), bar 0 has no prior bar,
// so ist_t[1] is na. The na() guard fires, treating the first visible bar as PM session
// start and resetting pm_cum_vol — causing the PM VWAP to only accumulate from the first
// visible bar, not from true 13:30. This is a known Pine limitation for mid-session loads
// and is acceptable — PM VWAP recovers to a reasonable value within 2–3 bars.
// No fix applied: the alternative (removing the na guard) would leave pm_cum_vol = 0.0
// on the true first bar of a fresh load, producing na PM VWAP until 13:30 arrives.
f_set_managed_lbl(int idx, bool fire, string anchor, float y_off_atr, string txt, color col, string size_str) =>
    if fire and is_today
        label.delete(array.get(managed_lbls, idx))
        string sz = size_str == "normal" ? size.normal : size_str == "tiny" ? size.tiny : size.small
        float y_pos = anchor == "high" ? high + current_atr * y_off_atr : anchor == "low" ? low - current_atr * y_off_atr : close
        array.set(managed_lbls, idx, label.new(bar_index, y_pos, txt, style=label.style_none, textcolor=col, size=sz))

f_set_managed_lbl_shape(int idx, bool fire, string anchor, float y_off_atr, string txt, color bg_col, color txt_col, string style_str, string size_str) =>
    if fire and is_today
        label.delete(array.get(managed_lbls, idx))
        string sz = size_str == "normal" ? size.normal : size_str == "tiny" ? size.tiny : size.small
        string l_style = style_str == "up" ? label.style_label_up : label.style_label_down
        float y_pos = anchor == "high" ? high + current_atr * y_off_atr : anchor == "low" ? low - current_atr * y_off_atr : close
        array.set(managed_lbls, idx, label.new(bar_index, y_pos, txt, style=l_style, color=bg_col, textcolor=txt_col, size=sz))

f_manage_level_line(line _l, float _val, color _col, int _w, string _style, int _left, int _right) =>
    line.delete(_l)
    line _res = not na(_val) ? line.new(_left, _val, _right, _val, color=_col, width=_w, style=_style == "dashed" ? line.style_dashed : _style == "dotted" ? line.style_dotted : line.style_solid) : na
    _res


bool is_pm_start = ist_t >= PM_START and (ist_t[1] < PM_START or na(ist_t[1]))
if is_new_day or is_pm_start
    pm_cum_vol    := 0.0
    pm_cum_vol_px := 0.0
if ist_t >= PM_START and barstate.isconfirmed
    pm_cum_vol    += vwap_vol
    pm_cum_vol_px += vwap_vol * typ_price

float pm_vwap = pm_cum_vol > 0 ? pm_cum_vol_px / pm_cum_vol : na

// Override PM VWAP in options mode as institutional reference
if _use_ext_gap and not na(_u_pm_vwap)
    pm_vwap := _u_pm_vwap  // accurate PM reset from underlying data

var int pm_vwap_load_warmup = 0
if barstate.isconfirmed
    pm_vwap_load_warmup += 1

f_set_managed_lbl(24, is_pm_start and barstate.isconfirmed and is_micro_execution and pm_vwap_load_warmup > 5, "high", 0.0, "▷ PM SESSION", color.new(color.orange, 0), "small")

// ── OR State Machine & Session Tracking ──
int or_eff_end_val = or_range == "15 min (9:15-9:30)" ? 930 : 945
int or_start_val   = include_first_5 ? SESSION_OPEN : 920

f_fetch_or(_start, _end) =>
    var float _h = na
    var float _l = na
    _t = hour(time, "Asia/Kolkata") * 100 + minute(time, "Asia/Kolkata")
    if ta.change(time("D")) != 0
        _h := na
        _l := na
    if _t >= _start and _t < _end
        _h := na(_h) ? high : math.max(_h, high)
        _l := na(_l) ? low  : math.min(_l, low)
    [_h, _l]

[sec_or_h, sec_or_l] = request.security(syminfo.tickerid, "1", f_fetch_or(or_start_val, or_eff_end_val), lookahead=barmerge.lookahead_on)





var int   or_cross_dir     = 0
var int   or_break_dir     = 0
var int   trap_up_cooldown = 0
var int   trap_dn_cooldown = 0
var int   bars_since_break_up = 0
var int   bars_since_break_dn = 0
var int   consecutive_inside  = 0
var int   bars_inside_or      = 0

var bool  bull_targets_active = false
var bool  bear_targets_active = false
var int   break_time          = 0

var bool retest_up_done   = false
var bool retest_dn_done   = false
var bool retest2_up_done  = false
var bool retest2_dn_done  = false

var bool t05_hit_up = false
var bool t05_hit_dn = false
var bool t10_hit_up = false  // P6: T+1.0R hit tracker for breakeven trail
var bool t10_hit_dn = false


// ── SMT Accumulation Exit State ──
// Tracks clustered SMT divergences against an open position
// 3+ opposing SMTs within a rolling window = thesis invalidation → clean exit
var int smt_bull_recent = 0   // bullish SMT count within rolling window (bars since last)
var int smt_bear_recent = 0   // bearish SMT count within rolling window

// ── Phase 3: ToD RVOL — Epoch Matrix (25×5) ──
// 25 epochs × 15-min blocks covers 375-min trading day (9:15–15:30)
// 6 arrays: epoch_cur (today accumulating) + d1–d5 (5-day rolling history)
// Rotated on is_new_day: d4→d5, d3→d4, d2→d3, d1→d2, cur→d1, cur reset to 0
// All initialized to 0.0 — valid-day divisor guards against false RVOL on warmup days
// Declarations hoisted to lines ~205–210 (before epoch rotation block) — do not re-declare here.

var float f5_h = na
var float f5_l = na

// ── P6: Opening Candle Character ──
// Classifies session type from the F5 candle (9:15–9:20).
// Latched once at 9:20 on barstate.isconfirmed. Resets daily.
var string p6_session_char = "Unknown"
var bool   p6_char_set     = false

// ── P5: Pre-OR Sweep Detection ──
// Detects PDH/PDL/PrevVWAP sweeps before OR sets (9:15 to OR end).
// Direction latch: 1=top swept (bear bias), -1=bot swept (bull bias).
var int    p5_sweep_dir    = 0
var string p5_sweep_level  = ""

// ── P2: OR Level Bounce / Rejection Score ──
// Test count trackers — how many times each level has been touched this session
var int or_h_test_count = 0
var int or_l_test_count = 0
var int or_m_test_count = 0
// Last score computed — stored for HUD display between touch bars
var int    p2_last_score  = 0
var string p2_last_label  = ""
var color  p2_last_col    = color.silver

// ── P1: Confluence Zone State — cached at OR set, valid all session ──
var bool   _p1_computed     = false
var int    or_h_conf_weight = 0
var int    or_l_conf_weight = 0
var int    or_m_conf_weight = 0
var string or_h_conf_levels = ""
var string or_l_conf_levels = ""
var string or_m_conf_levels = ""

// ── P2: Persistent single label per OR level — avoids stacking ──
var label _p2_h_lbl = na
var label _p2_l_lbl = na
var label _p2_m_lbl = na

// ── P1 / Coloc: Persistent session boxes ──
// Declared here (before is_new_day block) so box.delete calls in the rollover
// block can reference them without "Undeclared identifier" scope errors.
var box _p1_h_box  = na
var box _p1_l_box  = na
var box _p1_m_box  = na
var box _coloc_box_sup = na
var box _coloc_box_res = na

// ── M/W Line Management ──
var line _last_w_line = na
var line _last_m_line = na

// ── M/W Pattern State ──
var float last_swing_low      = na
var float last_swing_high     = na
var int   last_swing_low_bar  = na
var int   last_swing_high_bar = na
var float last_swing_low_rmi  = na
var float last_swing_high_rmi = na
var int   bars_since_w        = 9999
var int   bars_since_m        = 9999
var string last_w_conf        = ""
var string last_m_conf        = ""

// ── P3: Conditional Activity Filter state ──
// Condition counters persist across bars — reset on is_new_day.
var int p3_narrow_count      = 0  // consecutive bars inside developing VA
var int p3_neutral_rmi_count = 0  // consecutive bars with RMI 40-60
var int p3_no_struct_count   = 0  // bars since last swing_vote change
var int p3_poc_cross_count   = 0  // bars since developing POC oscillation
var int p3_last_swing_vote   = 0  // tracks swing_vote changes

// ── M/W Persistent Labels ──
var label _last_w_lbl = na
var label _last_m_lbl = na


// ── P4: Break Velocity Classification ──
// Computed once at first_break_up/dn. Cached for session.
// HV = enter immediately, NRML = standard, GRND = wait for retest.
var float  p4_velocity  = na
var string p4_class     = ""

var int   stored_brk_score          = 0
var bool  stored_anchor_contradiction = false
var bool  stored_score_vol          = false
var bool  stored_score_body         = false
var bool  stored_score_atr          = false
var bool  stored_score_vwp          = false
var int   stored_score_rmi          = 0    // v23: 5th point — -1=penalty, 0=neutral, +1=confirmed
var int   stored_score_rsi          = 0    // -1=RSI penalty fired, 0=neutral
var int   stored_score_poc          = 0    // +1=POC supports break, -1=contradicts, 0=neutral
var bool  or_trap_warned            = false // v23: latches true when Gap Trap Likely was showing at OR set — bridges orphan window

var bool vwap_reclaimed       = false
var bool vwap_rejected        = false
var bool vwap_r1_retest_done  = false
var bool vwap_r1_reject_done  = false





// ── Expiry FSM State (v26) ──
// C5 FIX: Replace string series comparison with numeric proxy for alert reliability
var int _fsm_phase_n = 0

// Trade Engine Variables Removed







if is_new_day
    or_h                   := na
    or_l                   := na
    or_set                 := false
    or_cross_dir           := 0
    or_break_dir           := 0
    trap_up_cooldown       := 0
    trap_dn_cooldown       := 0
    bars_since_break_up    := 0
    bars_since_break_dn    := 0
    consecutive_inside     := 0
    bars_inside_or         := 0
    or_vol                 := 0.0
    break_time             := 0
    bull_targets_active    := false
    bear_targets_active    := false
    retest_up_done         := false
    retest_dn_done         := false
    retest2_up_done        := false
    retest2_dn_done        := false
    session_low            := low
    session_high           := high
    bars_since_open        := 1
    t05_hit_up             := false
    t05_hit_dn             := false
    smt_bull_recent        := 0
    smt_bear_recent        := 0
    f5_h                   := na
    f5_l                   := na
    stored_brk_score       := 0
    stored_anchor_contradiction := false
    stored_score_vol       := false
    stored_score_body      := false
    stored_score_atr       := false
    stored_score_vwp       := false
    stored_score_rmi       := 0
    stored_score_rsi       := 0
    stored_score_poc       := 0
    or_trap_warned         := false
    vwap_reclaimed         := false
    vwap_rejected          := false
    vwap_r1_retest_done    := false
    vwap_r1_reject_done    := false
    // ── POC State Machine Resets ──
    poc_crossed_up       := false
    poc_crossed_dn       := false
    poc_cross_price      := na
    poc_cross_bar        := na
    poc_cross_t_str      := ""
    poc_retest_up_done   := false
    poc_retest_dn_done   := false
    poc_touch_count      := 0
    for i = 0 to 5
        array.set(poc_touch_vols, i, na)
    _poc_bull_touch_prev := false
    _poc_bear_touch_prev := false


    // ── Suggestion 1: Adaptive Proximity Reset ──
    or_open_adr_pct      := na
    poc_cluster_latched  := false
    
    // ── Suggestion 4: Volume Trap Reset ──
    poc_breakout_armed   := false
    poc_breakout_fail    := false
    poc_breakout_dir     := 0
    label.delete(poc_trap_lbl)
    poc_trap_lbl         := na

    poc_rising_bars      := 0
    poc_falling_bars     := 0

    // Engine resets removed
    _fsm_phase_n           := 0
    p6_session_char        := "Unknown"
    p6_char_set            := false
    p5_sweep_dir           := 0
    p5_sweep_level         := ""
    _p1_computed        := false
    or_h_test_count := 0
    or_l_test_count := 0
    or_m_test_count := 0
    p2_last_score   := 0
    p2_last_label   := ""
    p2_last_col     := color.silver
    or_h_conf_weight    := 0
    or_l_conf_weight    := 0
    or_m_conf_weight    := 0
    or_h_conf_levels    := ""
    or_l_conf_levels    := ""
    or_m_conf_levels    := ""
    p3_narrow_count      := 0
    p3_neutral_rmi_count := 0
    p3_no_struct_count   := 0
    p3_poc_cross_count   := 0
    p3_last_swing_vote   := 0
    p4_velocity := na
    p4_class    := ""
    last_swing_low      := na
    last_swing_high     := na
    last_swing_low_bar  := na
    last_swing_high_bar := na
    last_swing_low_rmi  := na
    last_swing_high_rmi := na
    bars_since_w        := 9999
    bars_since_m        := 9999
    last_w_conf         := ""
    last_m_conf         := ""
    label.delete(_p2_h_lbl)
    label.delete(_p2_l_lbl)
    label.delete(_p2_m_lbl)
    _p2_h_lbl := na
    _p2_l_lbl := na
    _p2_m_lbl := na

    // Delete all session-scoped boxes on day rollover.
    // Without this, boxes persist into the next session because their draw block
    // is gated on or_set (which resets to false at new_day before barstate.islast fires).
    box.delete(_p1_h_box)
    box.delete(_p1_l_box)
    box.delete(_p1_m_box)
    box.delete(_coloc_box_sup)
    box.delete(_coloc_box_res)
    _p1_h_box  := na
    _p1_l_box  := na
    _p1_m_box  := na
    _coloc_box_sup := na
    _coloc_box_res := na


if not is_new_day and in_market and barstate.isconfirmed
    bars_since_open += 1
if in_market and ist_t >= SESSION_OPEN and ist_t < SESSION_OPEN + 5
    f5_h := na(f5_h) ? high : math.max(f5_h, high)
    f5_l := na(f5_l) ? low  : math.min(f5_l, low)

// SESSION_OPEN = 915, so SESSION_OPEN + 5 = 920. Latch catches first bar at or after 9:20.
if ist_t >= 920 and barstate.isconfirmed and not p6_char_set and not na(f5_h) and not na(f5_l)
    float _p6_range    = f5_h - f5_l
    float _p6_body     = math.abs(close - open)
    float _p6_body_pct = _p6_range > 0 ? _p6_body / _p6_range : 0.0
    float _p6_close_pct = _p6_range > 0 ? (close - f5_l) / _p6_range : 0.5
    p6_session_char := _p6_range > current_atr * 1.0 and _p6_close_pct >= 0.75 ? "Wide Bull" : _p6_range > current_atr * 1.0 and _p6_close_pct <= 0.25 ? "Wide Bear" : _p6_body_pct < 0.25 ? "Doji" : _p6_range < current_atr * 0.5 ? "Inside" : "Normal"
    p6_char_set := true

// ── P6 HUD display strings — recomputed each bar (cheap, char is latched) ──
string p6_hud_txt = p6_session_char == "Wide Bull" ? "Wide Bull ▲ — Trend Day Bias" : p6_session_char == "Wide Bear" ? "Wide Bear ▼ — Trend Day Bias" : p6_session_char == "Doji" ? "Doji — Range Day Bias" : p6_session_char == "Inside" ? "Inside — Compression · Wait" : p6_session_char == "Normal" ? "Normal" : "Forming..."
color p6_hud_col = p6_session_char == "Wide Bull" ? #00ff88 : p6_session_char == "Wide Bear" ? #ff4466 : p6_session_char == "Doji" ? #ffee00 : p6_session_char == "Inside" ? #00aaff : p6_session_char == "Normal" ? color.silver : color.new(color.gray, 40)

bool _is_open_bar = (ist_t == SESSION_OPEN)
// 1. Price levels are now handled strictly by the 1-Minute Security Engine
// 2. Volume accumulates natively on bar close (restricted by or_start_val)
if in_market and ist_t >= or_start_val and ist_t < or_eff_end_val and barstate.isconfirmed
    or_vol += r_vol

// Wait until exact OR end to fetch the completed 1m security values and lock them
if not or_set and ist_t >= or_eff_end_val and not na(sec_or_h)
    or_set := true
    or_h   := sec_or_h
    or_l   := sec_or_l
    
    array.push(daily_or_ranges, or_h - or_l)
    if array.size(daily_or_ranges) > 5
        array.shift(daily_or_ranges)
    array.push(or_vol_history, or_vol)
    if array.size(or_vol_history) > 5
        array.shift(or_vol_history)

// ── Suggestion 1: Latch ADR for stable session proximity ──
if or_set and na(or_open_adr_pct) and barstate.isconfirmed
    or_open_adr_pct := adr_used_pct

f_get_seal_close(_end) =>
    var float c = na
    if ta.change(time("D", "Asia/Kolkata")) != 0
        c := na
    _t = hour(time, "Asia/Kolkata") * 100 + minute(time, "Asia/Kolkata")
    if _t == _end and na(c)
        c := close
    c

float first_candle_close = request.security(syminfo.tickerid, "5", f_get_seal_close(or_eff_end_val), lookahead=barmerge.lookahead_on)

float retest_buf  = math.max(current_atr * 0.1, or_rng * 0.03)
float avg_or_vol  = array.size(or_vol_history)  > 0 ? array.avg(or_vol_history)  : or_vol

string or_quality   = not or_set ? "" : or_rng < avg_or_rng * 0.7 ? " [Tight]" : or_rng > avg_or_rng * 1.3 ? " [Wide]" : " [Normal]"
float  or_vol_ratio = avg_or_vol > 0 ? or_vol / avg_or_vol : 1.0
string or_vol_tag   = or_set ? (or_vol_ratio > 1.3 ? " Heavy" : or_vol_ratio < 0.7 ? " Thin" : "") : ""
float  or_mid       = or_set ? math.avg(or_h, or_l) : na

// ── OR-L / OR-H + SVP VA + PrevVWAP Co-location Detection ──
// _coloc_thresh: 30% of the 20-day average OR range (~12-18pts on typical Nifty).
// Guards: or_set ensures OR is formed; not na(prev_vwap) excludes Day 1.
// svp_ready guards all yday VA references.
float _coloc_thresh = or_set and not na(avg_or_rng) ? avg_or_rng * 0.30 : na

// ── Dual-level pairings (any two levels co-located) ──
bool orl_pvwap_coloc = or_set and not na(or_l) and not na(prev_vwap) and
     not na(_coloc_thresh) and math.abs(or_l - prev_vwap) <= _coloc_thresh
bool orh_pvwap_coloc = or_set and not na(or_h) and not na(prev_vwap) and
     not na(_coloc_thresh) and math.abs(or_h - prev_vwap) <= _coloc_thresh

bool val_orl_coloc   = or_set and svp_track_dev and not na(svp_today_val) and not na(or_l) and
     not na(_coloc_thresh) and math.abs(svp_today_val - or_l) <= _coloc_thresh
bool vah_orh_coloc   = or_set and svp_track_dev and not na(svp_today_vah) and not na(or_h) and
     not na(_coloc_thresh) and math.abs(svp_today_vah - or_h) <= _coloc_thresh

// ── Triple-stack detection (all three in one zone) ──
bool support_triple  = orl_pvwap_coloc and val_orl_coloc   // VAL + OR-L + pVWAP
bool resist_triple   = orh_pvwap_coloc and vah_orh_coloc   // VAH + OR-H + pVWAP

// ── Composite flags for box and HUD (any co-location active on that side) ──
bool support_coloc   = orl_pvwap_coloc or val_orl_coloc    // at least one support pairing
bool resist_coloc    = orh_pvwap_coloc or vah_orh_coloc    // at least one resistance pairing
 

string candle_anchor = ""
if or_set and not na(first_candle_close) and not na(or_mid)
    candle_anchor := first_candle_close > or_mid ? " · Bull Anchor" : " · Bear Anchor"

// ── Universal Body Confirmation Formula ──
f_confirm_pct(level, is_up) =>
    float bh  = math.max(open, close)
    float bl  = math.min(open, close)
    float tb  = bh - bl
    float res = 0.0
    if tb > 0
        if is_up
            body_above = math.max(0, bh - math.max(level, bl))
            res        := (body_above / tb) * 100
        else
            res := (math.max(0, math.min(bh, level) - bl) / tb) * 100
    res



if or_set and barstate.isconfirmed
    if close > or_h and or_cross_dir != 1
        or_cross_dir := 1
    else if close < or_l and or_cross_dir != -1
        or_cross_dir := -1
    else if close <= or_h and close >= or_l
        or_cross_dir := 0

float pct_above_orh = f_confirm_pct(or_h, true)
float pct_below_orl = f_confirm_pct(or_l, false)

// barstate.isconfirmed gates or_break_dir to candle close only
// Prevents intrabar repaint: wick spike triggers body_confirm mid-candle, trade enters at wick top
if or_cross_dir == 1  and pct_above_orh >= body_confirm_pct and or_break_dir != 1 and barstate.isconfirmed
    or_break_dir := 1
    break_time   := ist_t
if or_cross_dir == -1 and pct_below_orl >= body_confirm_pct and or_break_dir != -1 and barstate.isconfirmed
    or_break_dir := -1
    break_time   := ist_t

float inner_buf_val   = (or_h - or_l) * 0.15
bool  genuinely_inside = or_set and close < (or_h - inner_buf_val) and close > (or_l + inner_buf_val)
if barstate.isconfirmed
    consecutive_inside := genuinely_inside ? consecutive_inside + 1 : 0

if or_break_dir != 0 and (consecutive_inside >= 2 or (or_break_dir == 1 and bars_since_break_up >= 10 and close < or_mid) or (or_break_dir == -1 and bars_since_break_dn >= 10 and close > or_mid))
    // MAJOR-3 FIX: Reset bars_since_break counters on OR re-entry.
    // Without this reset, a failed first breakout left bars_since_break_up/dn
    // at whatever value it had accumulated (e.g. 15–30 bars). The trap signal
    // at line ~1136 requires bars_since_break <= 5, so the second breakout attempt's
    // trap window was permanently blocked — the most profitable Nifty pattern
    // (False Break → Re-Entry) was silently suppressed for the rest of the session.
    // Resetting to 0 re-arms the 5-bar trap detection window for the next break attempt.
    or_break_dir        := 0
    or_cross_dir        := 0
    bars_since_break_up := 0
    bars_since_break_dn := 0

if or_break_dir == 1  and or_break_dir[1] != 1
    bull_targets_active := true
    bear_targets_active := false
    bars_since_break_up := 0
    bars_inside_or      := 0
    retest_dn_done      := false
    retest2_dn_done     := false
    t05_hit_up          := false
else if or_break_dir == -1 and or_break_dir[1] != -1
    bear_targets_active := true
    bull_targets_active := false
    bars_since_break_dn := 0
    bars_inside_or      := 0
    retest_up_done      := false
    retest2_up_done     := false
    t05_hit_dn          := false

if barstate.isconfirmed
    if not (or_break_dir == 1  and or_break_dir[1] != 1)
        bars_since_break_up += 1
    if not (or_break_dir == -1 and or_break_dir[1] != -1)
        bars_since_break_dn += 1
    if or_break_dir == 0
        bars_inside_or += 1

bool first_break_up = or_break_dir == 1  and or_break_dir[1] != 1
bool first_break_dn = or_break_dir == -1 and or_break_dir[1] != -1

// ── P4: Break Velocity Classification ──
// Velocity = points beyond OR level / or_rng / bars elapsed (capped at 5)
// Computed on the exact bar that first_break_up/dn fires (barstate.isconfirmed).
// Cached — does not change after initial classification.
// GRIND breakouts have higher retest probability — used by P2 (Phase 7) base rate.
if (first_break_up or first_break_dn) and barstate.isconfirmed and not na(or_rng) and or_rng > 0
    float _p4_pts = first_break_up ? math.max(0.0, close - or_h) : math.max(0.0, or_l - close)
    // elapsed = 1.0: this IS bar 1 of the confirmed break. bars_since_break_up is a rolling
    // session accumulator (not a break-formation counter) and reads 0 on this bar anyway.
    // Velocity = impulse distance beyond OR / OR range — clean single-bar momentum measure.
    float _p4_elapsed = 1.0
    p4_velocity := (_p4_pts / or_rng) / _p4_elapsed
    p4_class    := p4_velocity >= 0.25 ? "HV" : p4_velocity >= 0.10 ? "NRML" : "GRND"

f_time_str(int t) =>
    t > 0 ? str.tostring(math.floor(t / 100), "00") + ":" + str.tostring(t % 100, "00") : ""
string break_t_str = break_time > 0 ? " " + f_time_str(break_time) : ""

string retest_status = ""
if or_break_dir == 1
    retest_status := retest_up_done ? (retest2_up_done ? " · R2✓" : " · R1✓") : ""
else if or_break_dir == -1
    retest_status := retest_dn_done ? (retest2_dn_done ? " · R2✓" : " · R1✓") : ""

// ── Static Targets (Dynamic Visibility) ──
bool show_bull_targets = or_set and close > or_h
bool show_bear_targets = or_set and close < or_l

// Targets calculated unconditionally — trade engine needs ext_h20/ext_l20 for all setup types.
// Visual plot series (p_t_*) below still gate on show_bull_targets / show_bear_targets.
float ext_h05 = or_h + (or_rng * 0.5)
float ext_h10 = or_h + (or_rng * 1.0)
float ext_h15 = or_h + (or_rng * 1.5)
float ext_h20 = or_h + (or_rng * 2.0)
float ext_l05 = or_l - (or_rng * 0.5)
float ext_l10 = or_l - (or_rng * 1.0)
float ext_l15 = or_l - (or_rng * 1.5)
float ext_l20 = or_l - (or_rng * 2.0)

// ═══════════════════════════════════════════════════════════════════════════════
// INTERNAL RMI ENGINE — v23
// ═══════════════════════════════════════════════════════════════════════════════
// Lightweight Wilder 14-period RMI, momentum=3, fixed 70/30 levels.
// Matches MEdge defaults. Placed here — after or_set logic, before gap strategy —
// so all downstream consumers (score, strategy, tape) have valid values.
// Used for:
//   Phase 1: Breakout score 5th point (or_close_rmi latched at OR set)
//   Phase 2: Strategy pre-warning during OR formation + Gap Trap override post-break
//   Phase 3: Tape WITH confirmation + exhaustion color coding
// No regime complexity — simple fixed levels, zero engine impact.

float _rmi_up  = ta.rma(math.max(ta.change(close, 3), 0.0), 14)
float _rmi_dn  = ta.rma(math.max(-ta.change(close, 3), 0.0), 14)
float _rmi_val = _rmi_dn == 0 ? 100.0 : _rmi_up == 0 ? 0.0 : 100.0 - (100.0 / (1.0 + _rmi_up / _rmi_dn))
bool  _rmi_ob  = _rmi_val >= 70.0
bool  _rmi_os  = _rmi_val <= 30.0

// OR-close RMI — latched at the exact bar when or_set flips true
// This is the session-level conviction signal. Resets daily.
// or_close_rmi > 70 = opening auction exhausted to upside → short bias all day
// or_close_rmi < 30 = opening auction exhausted to downside → long bias all day
// or_close_rmi 40-60 = neutral auction → trend day likely, follow the break
// MAJOR FIX v25.3: OR conviction latch — use _rmi_val[1] without isconfirmed gate
// Problem: `or_set and na(or_close_rmi) and barstate.isconfirmed` waits for the 9:30
//          bar to CLOSE (9:35) before latching. Opening auction momentum already resolved
//          at 9:30 — capturing at 9:35 is a 5-minute lag in the conviction baseline.
// Solution: On the tick that or_set first becomes true (9:30 open), latch _rmi_val[1]
//           which is the fully confirmed RMI of the last OR bar (9:25–9:30 close).
//           Zero lag, zero repaint — [1] is always a confirmed historical value.
var float or_close_rmi = na
if is_new_day
    or_close_rmi := na
if or_set and na(or_close_rmi)
    or_close_rmi := _rmi_val[1]  // Zero-lag latch: captures RMI exactly at OR close

// Pre-warning flags — used by Strategy row during OR formation only
// _rmi_forming_ob: RMI already OB while OR is still forming → gap trap short likely
// _rmi_forming_os: RMI already OS while OR is still forming → gap trap long likely
bool _rmi_forming_ob = not or_set and _rmi_val > 70.0
bool _rmi_forming_os = not or_set and _rmi_val < 30.0

// ── Consecutive RMI bar counter ──
// Tracks how many confirmed bars RMI has been continuously rising or falling.
// Positive = rising streak, Negative = falling streak. Resets on direction change or new day.
// Displayed in HUD Int RMI row: "84.1 OB ⚠  ↑6" = OB and rising for 6 bars = 18min on 3m
// High streak (6+) when OB = exhaustion has been building, not a brief spike — high conviction
var int _rmi_consec = 0
// ── RMI Divergence Engine — state variables ──
var float _div_last_ph_price   = na
var float _div_last_ph_rmi     = na
var int   _div_last_ph_rmi_bar = na
var bool  _div_last_ph_in_ob   = false

var float _div_ext_ph_price    = na
var float _div_ext_ph_rmi      = na
var int   _div_ext_ph_bar      = na

var float _div_last_pl_price   = na
var float _div_last_pl_rmi     = na
var int   _div_last_pl_rmi_bar = na
var bool  _div_last_pl_in_os   = false

var float _div_ext_pl_price    = na
var float _div_ext_pl_rmi      = na
var int   _div_ext_pl_bar      = na

var label _rmi_div_bull_lbl = na
var label _rmi_div_bear_lbl = na

if is_new_day
    _rmi_consec := 0
    _div_last_ph_price   := na
    _div_last_ph_rmi     := na
    _div_last_ph_rmi_bar := na
    _div_last_ph_in_ob   := false
    _div_ext_ph_price    := na
    _div_ext_ph_rmi      := na
    _div_ext_ph_bar      := na
    _div_last_pl_price   := na
    _div_last_pl_rmi     := na
    _div_last_pl_rmi_bar := na
    _div_last_pl_in_os   := false
    _div_ext_pl_price    := na
    _div_ext_pl_rmi      := na
    _div_ext_pl_bar      := na
    label.delete(_rmi_div_bull_lbl)
    label.delete(_rmi_div_bear_lbl)
    _rmi_div_bull_lbl := na
    _rmi_div_bear_lbl := na

if barstate.isconfirmed
    if _rmi_val > _rmi_val[1]
        _rmi_consec := _rmi_consec > 0 ? _rmi_consec + 1 : 1
    else if _rmi_val < _rmi_val[1]
        _rmi_consec := _rmi_consec < 0 ? _rmi_consec - 1 : -1
    else
        _rmi_consec := 0
string _rmi_dir = _rmi_consec > 0 ? "↑" : _rmi_consec < 0 ? "↓" : "→"
int    _rmi_abs = math.abs(_rmi_consec)

// ── RMI Divergence Engine — pivot detection and conditions ──
float _div_ph_price  = ta.pivothigh(high,     rmi_div_piv_left, rmi_div_piv_right)
float _div_pl_price  = ta.pivotlow(low,       rmi_div_piv_left, rmi_div_piv_right)
float _div_ph_rmi    = ta.pivothigh(_rmi_val, rmi_div_piv_left, rmi_div_piv_right)
float _div_pl_rmi    = ta.pivotlow(_rmi_val,  rmi_div_piv_left, rmi_div_piv_right)

if not na(_div_ph_price)
    _div_last_ph_price := _div_ph_price

if not na(_div_ph_rmi)
    _div_last_ph_rmi     := _div_ph_rmi
    _div_last_ph_rmi_bar := bar_index - rmi_div_piv_right
    _div_last_ph_in_ob   := _div_ph_rmi >= 70.0
    if _div_last_ph_in_ob
        _div_ext_ph_price := high[rmi_div_piv_right]
        _div_ext_ph_rmi   := _div_ph_rmi
        _div_ext_ph_bar   := bar_index - rmi_div_piv_right

if not na(_div_pl_price)
    _div_last_pl_price := _div_pl_price

if not na(_div_pl_rmi)
    _div_last_pl_rmi     := _div_pl_rmi
    _div_last_pl_rmi_bar := bar_index - rmi_div_piv_right
    _div_last_pl_in_os   := _div_pl_rmi <= 30.0
    if _div_last_pl_in_os
        _div_ext_pl_price := low[rmi_div_piv_right]
        _div_ext_pl_rmi   := _div_pl_rmi
        _div_ext_pl_bar   := bar_index - rmi_div_piv_right

int _div_h_bars = nz(ta.highestbars(_rmi_val, rmi_div_piv_right + 1), 0)
int _div_l_bars = nz(ta.lowestbars(_rmi_val,  rmi_div_piv_right + 1), 0)
float _div_peak_rmi     = ta.highest(_rmi_val, rmi_div_piv_right + 1)
float _div_trough_rmi   = ta.lowest(_rmi_val,  rmi_div_piv_right + 1)
int _div_peak_bar       = bar_index + _div_h_bars
int _div_trough_bar     = bar_index + _div_l_bars

float _div_peak_price   = ta.highest(high, rmi_div_piv_right + 1)
float _div_trough_price = ta.lowest(low,   rmi_div_piv_right + 1)

bool _div_imm_bear = not na(_div_last_ph_price) and not na(_div_last_ph_rmi) and
                     _div_peak_price > _div_last_ph_price and
                     _div_peak_rmi   < _div_last_ph_rmi   and
                     (_div_last_ph_in_ob or _div_peak_rmi >= 70.0)

bool _div_ext_bear = not na(_div_ext_ph_price) and not na(_div_ext_ph_rmi) and
                     _div_peak_price > _div_ext_ph_price and
                     _div_peak_rmi   < _div_ext_ph_rmi   and
                     _div_peak_bar   > _div_ext_ph_bar

bool _div_imm_bull = not na(_div_last_pl_price) and not na(_div_last_pl_rmi) and
                     _div_trough_price < _div_last_pl_price and
                     _div_trough_rmi   > _div_last_pl_rmi  and
                     (_div_last_pl_in_os or _div_trough_rmi <= 30.0)

bool _div_ext_bull = not na(_div_ext_pl_price) and not na(_div_ext_pl_rmi) and
                     _div_trough_price < _div_ext_pl_price and
                     _div_trough_rmi   > _div_ext_pl_rmi  and
                     _div_trough_bar   > _div_ext_pl_bar

// Slope gate — fires only on the bar where slope flips direction (edge trigger).
// Uses existing _rmi_consec — no new slope variable needed.
bool _slope_flipped_dn = _rmi_consec < 0 and _rmi_consec[1] >= 0
bool _slope_flipped_up = _rmi_consec > 0 and _rmi_consec[1] <= 0

bool rmi_div_bear = show_rmi_div and barstate.isconfirmed and _slope_flipped_dn and (_div_imm_bear or _div_ext_bear)
bool rmi_div_bull = show_rmi_div and barstate.isconfirmed and _slope_flipped_up and (_div_imm_bull or _div_ext_bull)

// ── RMI Regular Divergence labels ──
// Offset 0.9 vs CVD's 0.6 to avoid stacking on the same bar.
// barstate.isconfirmed is already inside rmi_div_bull/bear — no need to repeat.
if rmi_div_bull and is_today
    label.delete(_rmi_div_bull_lbl)
    _rmi_div_bull_lbl := label.new(bar_index, low  - (current_atr * 0.9), "▲D",
        style=label.style_none, textcolor=#00bb66, size=size.small)
if rmi_div_bear and is_today
    label.delete(_rmi_div_bear_lbl)
    _rmi_div_bear_lbl := label.new(bar_index, high + (current_atr * 0.9), "▼D",
        style=label.style_none, textcolor=#ff2244, size=size.small)

// ── Gap Analysis & Magnet ──
// ── Decoupled Macro Gap + ADR Engine — v24 (hoisted tuple) ──
// gap_target decouples gap calculation from options theta decay.
// In index/stock modes gap_target == syminfo.tickerid — day_open/pd_close reused directly.
// CRITICAL-2 FIX: ADR previously used lookahead_on on the daily resolution.
// In a deep backtest the daily bar transition timing is imprecise — lookahead_on
// can occasionally pull the current day's H-L into the "prior 5-day" SMA, creating
// ADR boundaries that were unknowable at the time of trading (backtest bias).
// Removed lookahead_on from ADR. [1] offset alone is sufficient — it guarantees
// yesterday's completed daily bar without any forward-leak risk.
//
// MAJOR-2 FIX: _gap_u_open, _gap_u_pdc, and adr_5 previously consumed 3 separate
// security() slots for the gap_target path (Options/Stock-Options modes).
// Hoisted into a single tuple call — saves 2 slots (now ~28/40 vs 30/40).
// Non-gap-target path (index/stock modes) continues to reuse day_open/pd_close/adr_5
// computed from syminfo.tickerid — zero extra calls needed there.

// _gu_session_h/l declared here (before the launchpad block at line ~1096 that references them).
// Populated later in the CRIT-2 ADR block — var preserves values across bars.
var float _gu_session_h = na
var float _gu_session_l = na

float _gap_u_open = na
float _gap_u_pdc  = na
float adr_5       = na

if _use_ext_gap
    // Mixed-shift design — intentional, not a bug:
    //   open         → no shift, forward-looked via lookahead_on = TODAY's gap_target open.
    //   close[1]     → yesterday's closing price (prior confirmed daily bar)
    //   sma(h-l,5)[1]→ yesterday's 5-day ADR SMA (prior confirmed daily bar)
    //   VAH/VAL      → yesterday's underlying Value Area High/Low for magnet abort
    [_gu_o, _gu_c, _gu_adr, _gu_vah, _gu_val] = request.security(gap_target, "D",
        [open, close[1], ta.sma(high - low, 5)[1], ta.vwap[1] + ta.atr(14)[1], ta.vwap[1] - ta.atr(14)[1]],
        lookahead=barmerge.lookahead_on)
    _gap_u_open := _gu_o
    _gap_u_pdc  := _gu_c
    adr_5       := _gu_adr
    _u_vah      := _gu_vah
    _u_val      := _gu_val
else
    _gap_u_open := day_open
    _gap_u_pdc  := pd_close
    adr_5       := pd_adr_5
float  gap_pct  = _gap_u_pdc > 0 ? ((_gap_u_open - _gap_u_pdc) / _gap_u_pdc) * 100 : 0.0

// M1 FIX: Explicit lookahead_off — documents intent and guards against future Pine default changes
float _ext_close_raw = request.security(vol_target, timeframe.period, close, lookahead=barmerge.lookahead_off)
_u_close := _use_ext_gap ? _ext_close_raw : close

// ═══════════════════════════════════════════════════════════════════════════════
// P10: SECTOR BREADTH — 5 Core Sectors (VWAP-based intraday scoring)
// ═══════════════════════════════════════════════════════════════════════════════
// Architecture: compare each sector's current price to its intraday VWAP.
// Above VWAP = +1 (institutional acceptance above value), below = -1.
// This is intraday position, not overnight change — correct for ORB timing.
//
// 5 sectors chosen by Nifty weight (covers ~70% of index):
//   BANKNIFTY ~33%, CNXIT ~13%, CNXENERGY ~12%, CNXFMCG ~6%, CNXAUTO ~6%
//
// VWAP fetched as ta.vwap — Pine's built-in session VWAP, same as chart VWAP.
// lookahead_off: prevents future bar contamination on same-TF security calls.
// Gated by show_breadth — when false, all values na, HUD shows "Disabled".
// Budget: +5 calls → 29/40 total.

[_sb_bank_close, _sb_bank_vwap] = if show_breadth
    request.security("NSE:BANKNIFTY",  timeframe.period, [close, ta.vwap], lookahead=barmerge.lookahead_off)
else
    [float(na), float(na)]

[_sb_it_close, _sb_it_vwap] = if show_breadth
    request.security("NSE:CNXIT",      timeframe.period, [close, ta.vwap], lookahead=barmerge.lookahead_off)
else
    [float(na), float(na)]

[_sb_enrg_close, _sb_enrg_vwap] = if show_breadth
    request.security("NSE:CNXENERGY",  timeframe.period, [close, ta.vwap], lookahead=barmerge.lookahead_off)
else
    [float(na), float(na)]

[_sb_fmcg_close, _sb_fmcg_vwap] = if show_breadth
    request.security("NSE:CNXFMCG",  timeframe.period, [close, ta.vwap], lookahead=barmerge.lookahead_off)
else
    [float(na), float(na)]

[_sb_auto_close, _sb_auto_vwap] = if show_breadth
    request.security("NSE:CNXAUTO",    timeframe.period, [close, ta.vwap], lookahead=barmerge.lookahead_off)
else
    [float(na), float(na)]

// ═══════════════════════════════════════════════════════════════════════════════
// P10: Cap-Weighted Breadth + Velocity + Divergence
// ═══════════════════════════════════════════════════════════════════════════════
// Architecture changes from v1:
//
// 1. CAP-WEIGHTED SCORE: Each sector contributes its Nifty weight, not equal +1/-1.
//    BankNifty = 3.3, IT = 1.3, Energy = 1.2, FMCG = 0.6, Auto = 0.6.
//    Range -7.0 to +7.0. Heavyweight alignment dominates the score correctly.
//
// 2. VELOCITY (5-bar flip count): Tracks how many sectors flipped above/below VWAP
//    in last 5 bars. 3+ bull flips during OR formation = institutional money moving
//    in real time, BEFORE the OR breaks. This is the leading signal.
//
// 3. DIVERGENCE: Compares Nifty's 5-bar price change to breadth's 5-bar score change.
//    Price up + breadth down = institutional distribution into retail (bearish).
//    Price down + breadth up = institutional accumulation (bullish reversal setup).
//
// Sector weights based on approximate Nifty 50 sector weight (Q1 2026):
//   Financials (BankNifty proxy):    33% → weight 3.3
//   IT:                              13% → weight 1.3
//   Energy (Reliance/ONGC proxy):    12% → weight 1.2
//   FMCG (defensive):                 6% → weight 0.6
//   Auto (cyclical):                  6% → weight 0.6
//   Total tracked weight: ~70% of Nifty index

// ── Per-sector states (above/below VWAP) ──
bool _b_bank_bull = not na(_sb_bank_close) and not na(_sb_bank_vwap) and _sb_bank_close > _sb_bank_vwap
bool _b_bank_bear = not na(_sb_bank_close) and not na(_sb_bank_vwap) and _sb_bank_close < _sb_bank_vwap
bool _b_it_bull   = not na(_sb_it_close)   and not na(_sb_it_vwap)   and _sb_it_close   > _sb_it_vwap
bool _b_it_bear   = not na(_sb_it_close)   and not na(_sb_it_vwap)   and _sb_it_close   < _sb_it_vwap
bool _b_enrg_bull = not na(_sb_enrg_close) and not na(_sb_enrg_vwap) and _sb_enrg_close > _sb_enrg_vwap
bool _b_enrg_bear = not na(_sb_enrg_close) and not na(_sb_enrg_vwap) and _sb_enrg_close < _sb_enrg_vwap
bool _b_fmcg_bull = not na(_sb_fmcg_close) and not na(_sb_fmcg_vwap) and _sb_fmcg_close > _sb_fmcg_vwap
bool _b_fmcg_bear = not na(_sb_fmcg_close) and not na(_sb_fmcg_vwap) and _sb_fmcg_close < _sb_fmcg_vwap
bool _b_auto_bull = not na(_sb_auto_close) and not na(_sb_auto_vwap) and _sb_auto_close > _sb_auto_vwap
bool _b_auto_bear = not na(_sb_auto_close) and not na(_sb_auto_vwap) and _sb_auto_close < _sb_auto_vwap

// ── CHANGE 1: Cap-Weighted Score ──
// Each sector contributes ±weight based on Nifty weighting.
// Range -7.0 to +7.0. Score reflects actual institutional weight, not raw count.
float _w_bank = 3.3
float _w_it   = 1.3
float _w_enrg = 1.2
float _w_fmcg = 0.6
float _w_auto = 0.6

float p10_score = 0.0
int   p10_valid = 0  // count of sectors with valid data

if _b_bank_bull or _b_bank_bear
    p10_valid += 1
    p10_score += _b_bank_bull ? _w_bank : -_w_bank
if _b_it_bull or _b_it_bear
    p10_valid += 1
    p10_score += _b_it_bull   ? _w_it   : -_w_it
if _b_enrg_bull or _b_enrg_bear
    p10_valid += 1
    p10_score += _b_enrg_bull ? _w_enrg : -_w_enrg
if _b_fmcg_bull or _b_fmcg_bear
    p10_valid += 1
    p10_score += _b_fmcg_bull ? _w_fmcg : -_w_fmcg
if _b_auto_bull or _b_auto_bear
    p10_valid += 1
    p10_score += _b_auto_bull ? _w_auto : -_w_auto

// State thresholds calibrated to cap-weighted scale:
//   ≥ +3.0  = Bull   (heavyweights aligned bullish — Bank+IT or Bank+Energy minimum)
//   ≤ -3.0  = Bear   (heavyweights aligned bearish)
//   In between = Mixed
string p10_state = not show_breadth ? "Off" : p10_valid < 3 ? "Warming" : p10_score >= 3.0 ? "Bull" : p10_score <= -3.0 ? "Bear" : "Mixed"

// ── CHANGE 2: Breadth Velocity (Flip Counter) ──
// Tracks individual sector flips in last 5 bars on confirmed bars.
// Bull flip = sector was below VWAP 5 bars ago, now above.
// Bear flip = sector was above 5 bars ago, now below.
// Velocity is the LEADING signal — fires before score reaches Bull/Bear state.

var int p10_bull_flips_5bar = 0
var int p10_bear_flips_5bar = 0

// Daily reset
if is_new_day
    p10_bull_flips_5bar := 0
    p10_bear_flips_5bar := 0

if true
    if barstate.isconfirmed and in_market
        int _bull_count = 0
        int _bear_count = 0
        if not na(_sb_bank_close[5])
            if _b_bank_bull and _b_bank_bear[5]
                _bull_count += 1
            if _b_bank_bear and _b_bank_bull[5]
                _bear_count += 1
        if not na(_sb_it_close[5])
            if _b_it_bull and _b_it_bear[5]
                _bull_count += 1
            if _b_it_bear and _b_it_bull[5]
                _bear_count += 1
        if not na(_sb_enrg_close[5])
            if _b_enrg_bull and _b_enrg_bear[5]
                _bull_count += 1
            if _b_enrg_bear and _b_enrg_bull[5]
                _bear_count += 1
        if not na(_sb_fmcg_close[5])
            if _b_fmcg_bull and _b_fmcg_bear[5]
                _bull_count += 1
            if _b_fmcg_bear and _b_fmcg_bull[5]
                _bear_count += 1
        if not na(_sb_auto_close[5])
            if _b_auto_bull and _b_auto_bear[5]
                _bull_count += 1
            if _b_auto_bear and _b_auto_bull[5]
                _bear_count += 1
        p10_bull_flips_5bar := _bull_count
        p10_bear_flips_5bar := _bear_count

// Velocity state — captures the strongest directional flip within the 5-bar window
string p10_velocity_state = p10_bull_flips_5bar >= 3 and p10_bear_flips_5bar == 0 ? "Strong In"  : p10_bear_flips_5bar >= 3 and p10_bull_flips_5bar == 0 ? "Strong Out" : p10_bull_flips_5bar >= 2 and p10_bull_flips_5bar > p10_bear_flips_5bar ? "Money In"  : p10_bear_flips_5bar >= 2 and p10_bear_flips_5bar > p10_bull_flips_5bar ? "Money Out" : "Stable"

// ── CHANGE 3: Breadth-Price Divergence ──
// Compares Nifty's own 5-bar price change to breadth score 5-bar change.
// Active only when both moves are meaningful (not chop within noise).

float _price_chg_5bar = (close - close[5]) / close[5] * 100.0  // % change
float _breadth_chg_5bar = na(p10_score[5]) ? na : (p10_score - p10_score[5])

// Thresholds: 0.10% price move and 1.0 score change = meaningful
float _price_thresh   = 0.10  // % — calibrated for Nifty intraday
float _breadth_thresh = 1.0   // score units — represents at least one Bank or two minor sector flips

bool p10_div_bear = not na(_breadth_chg_5bar) and _price_chg_5bar >  _price_thresh and _breadth_chg_5bar < -_breadth_thresh
bool p10_div_bull = not na(_breadth_chg_5bar) and _price_chg_5bar < -_price_thresh and _breadth_chg_5bar >  _breadth_thresh

string p10_div_state = p10_div_bear ? "BEAR DIV" : p10_div_bull ? "BULL DIV" : "None"

// ── P10 Breadth Divergence at POC (Addition H) ──
// Breadth divergence happening AT today's developing POC = distribution or accumulation
// at the highest-volume institutional reference level. Higher conviction than generic divergence.
bool p10_div_bear_at_poc = p10_div_bear and svp_track_dev and not na(svp_today_poc) and
     math.abs(close - svp_today_poc) <= current_atr * 0.20 and barstate.isconfirmed
bool p10_div_bull_at_poc = p10_div_bull and svp_track_dev and not na(svp_today_poc) and
     math.abs(close - svp_today_poc) <= current_atr * 0.20 and barstate.isconfirmed


// ═══════════════════════════════════════════════════════════════════════════════
// P10 HTF CONFLUENCE LAYER
// ═══════════════════════════════════════════════════════════════════════════════
// Compares today's intraday breadth state to HTF context already in the code.
// Zero new security calls — reuses d_ema21, d_rsi14, w_vwap from existing fetches.
//
// Six states, ranked by predictive value (highest first):
//   Reversal Bull  : Daily RSI <= 30 AND today's breadth = Bull (trend-end signal)
//   Reversal Bear  : Daily RSI >= 70 AND today's breadth = Bear (trend-end signal)
//   Aligned Bull   : Above d_ema21 + above w_vwap + breadth = Bull (trend continuation)
//   Aligned Bear   : Below d_ema21 + below w_vwap + breadth = Bear (trend continuation)
//   Counter-Trend  : Daily/weekly trend opposes today's breadth direction (low conviction)
//   Neutral        : Mixed signals or breadth not yet at Bull/Bear state
//
// HTF data sources:
//   d_ema21         : Daily 21 EMA (line 812)
//   d_above_ema21   : close > d_ema21 (line 831)
//   d_rsi14         : Daily RSI on prior close (line 812)
//   d_rsi_state     : "OB" >70 / "OS" <30 / "Neutral" (line 825)
//   w_vwap          : Weekly VWAP (line 1035)

// Daily trend direction
bool _htf_d_bull = not na(d_ema21) and close > d_ema21
bool _htf_d_bear = not na(d_ema21) and close < d_ema21

// Weekly VWAP direction (only meaningful when scale matches — same guard as HTF HUD)
// Without this guard, options charts (premium ~150) compared to weekly VWAP (~24000)
// produce permanently false readings. The 50% scale-match threshold catches that.
bool _htf_w_scale_ok = not na(w_vwap) and math.abs(close - w_vwap) < (close * 0.5)
bool _htf_w_bull = _htf_w_scale_ok and close > w_vwap
bool _htf_w_bear = _htf_w_scale_ok and close < w_vwap

// Daily RSI extremes
bool _htf_d_ob = not na(d_rsi14) and d_rsi14 >= 70
bool _htf_d_os = not na(d_rsi14) and d_rsi14 <= 30

// Today's breadth direction (alias for readability)
bool _t_bull = p10_state == "Bull"
bool _t_bear = p10_state == "Bear"

// State classification — most specific match wins
// Reversal states checked first (highest signal value)
// Aligned states require BOTH daily and weekly trend alignment
// Counter-trend fires when daily OR weekly disagrees with today's breadth
string p10_htf_align = not show_breadth or p10_state == "Off" or p10_state == "Warming" ? "N/A" : _htf_d_os and _t_bull ? "Reversal Bull" : _htf_d_ob and _t_bear ? "Reversal Bear" : _htf_d_bull and _htf_w_bull and _t_bull ? "Aligned Bull" : _htf_d_bear and _htf_w_bear and _t_bear ? "Aligned Bear" : (_htf_d_bull or _htf_w_bull) and _t_bear ? "Counter-Trend" : (_htf_d_bear or _htf_w_bear) and _t_bull ? "Counter-Trend" : "Neutral"

// HUD display
string p10_htf_hud_txt = p10_htf_align == "N/A" ? "—" : p10_htf_align == "Reversal Bull" ? "⚡ Reversal Bull (RSI OS + Breadth ▲)" : p10_htf_align == "Reversal Bear" ? "⚡ Reversal Bear (RSI OB + Breadth ▼)" : p10_htf_align == "Aligned Bull" ? "▲ Aligned Bull (D+W+Breadth)" : p10_htf_align == "Aligned Bear" ? "▼ Aligned Bear (D+W+Breadth)" : p10_htf_align == "Counter-Trend" ? "⚠ Counter-Trend (Breadth vs HTF)" : "Neutral"

color p10_htf_hud_col = p10_htf_align == "Reversal Bull" ? #00ffaa : p10_htf_align == "Reversal Bear" ? #ff44aa : p10_htf_align == "Aligned Bull" ? #00ff88 : p10_htf_align == "Aligned Bear" ? #ff4466 : p10_htf_align == "Counter-Trend" ? #ffaa00 : p10_htf_align == "Neutral" ? color.silver : color.new(color.gray, 40)

// ── Per-sector detail string (unchanged from v1) ──
string _sb_bank_ch = na(_sb_bank_close) or na(_sb_bank_vwap) ? "·" : _sb_bank_close > _sb_bank_vwap ? "B▲" : "B▼"
string _sb_it_ch   = na(_sb_it_close)   or na(_sb_it_vwap)   ? "·" : _sb_it_close   > _sb_it_vwap   ? "T▲" : "T▼"
string _sb_enrg_ch = na(_sb_enrg_close) or na(_sb_enrg_vwap) ? "·" : _sb_enrg_close > _sb_enrg_vwap ? "E▲" : "E▼"
string _sb_fmcg_ch = na(_sb_fmcg_close) or na(_sb_fmcg_vwap) ? "·" : _sb_fmcg_close > _sb_fmcg_vwap ? "F▲" : "F▼"
string _sb_auto_ch = na(_sb_auto_close) or na(_sb_auto_vwap) ? "·" : _sb_auto_close > _sb_auto_vwap ? "A▲" : "A▼"

string p10_detail = _sb_bank_ch + " " + _sb_it_ch + " " + _sb_enrg_ch + " " + _sb_fmcg_ch + " " + _sb_auto_ch

// ── HUD strings ──

// Score row: "+5.2/7 ▲ Bull  B▲ T▲ E▲ F▼ A▲"
string p10_score_str = (p10_score >= 0 ? "+" : "") + str.tostring(p10_score, "#.#")
string p10_hud_txt = p10_state == "Off" ? "Disabled" : p10_state == "Warming" ? "Warming up..." : p10_score_str + "/7 " + (p10_state == "Bull" ? "▲ Bull" : p10_state == "Bear" ? "▼ Bear" : "→ Mixed") + "  " + p10_detail

color p10_hud_col = p10_state == "Bull" ? #00ff88 : p10_state == "Bear" ? #ff4466 : p10_state == "Mixed" ? #ffaa00 : color.new(color.gray, 40)

// Velocity row: "3↑ flips · 0↓ (5-bar)" or "1↑ · 1↓ Stable"
string p10_vel_hud_txt = p10_state == "Off" or p10_state == "Warming" ? "—" : str.tostring(p10_bull_flips_5bar) + "↑ · " + str.tostring(p10_bear_flips_5bar) + "↓ (5b) " + (p10_velocity_state == "Strong In" ? "▲▲ Strong In" : p10_velocity_state == "Strong Out" ? "▼▼ Strong Out" : p10_velocity_state == "Money In" ? "▲ Money In" : p10_velocity_state == "Money Out" ? "▼ Money Out" : "≈ Stable")

color p10_vel_hud_col = p10_velocity_state == "Strong In" ? #00ff88 : p10_velocity_state == "Money In" ? #00bb66 : p10_velocity_state == "Strong Out" ? #ff4466 : p10_velocity_state == "Money Out" ? #cc2244 : color.silver

// Divergence row: only fires when active — silver "None" otherwise
string p10_div_hud_txt = p10_state == "Off" or p10_state == "Warming" ? "—" : p10_div_bear ? "⚠ BEAR DIV  Price↑ Breadth↓" : p10_div_bull ? "⚠ BULL DIV  Price↓ Breadth↑" : "None"

color p10_div_hud_col = p10_div_bear ? #ff4466 : p10_div_bull ? #00ff88 : color.new(color.gray, 40)

// ── P12: Index Basis Spread ──
// Futures close vs spot close. Reuses _ext_close_raw — 0 new security calls.
// Active only in index modes where vol_target is a futures contract.
// Excess = raw basis vs its 20-bar SMA (removes structural carry component).

bool   _p12_active    = show_basis and not _use_ext_gap and not is_equity_mode and not na(_ext_close_raw) and _ext_close_raw > 0
float  p12_basis_raw  = _p12_active ? (_ext_close_raw - close) : na
int    _p12_bars_since_day = ta.barssince(is_new_day)    // must be unconditional for consistent history
float  _p12_sma_raw   = ta.sma(nz(p12_basis_raw), 20)   // must be unconditional for consistent history
float  p12_basis_sma  = _p12_active and _p12_bars_since_day >= 20 ? _p12_sma_raw : na
float  p12_excess     = _p12_active and not na(p12_basis_sma) ? p12_basis_raw - p12_basis_sma : na
float  _p12_thresh    = syminfo.mintick * 5

string p12_state = not _p12_active or na(p12_excess) ? "N/A" : p12_excess > _p12_thresh ? "Premium" : p12_excess < -_p12_thresh ? "Discount" : "Fair"
string p12_hud_txt = p12_state == "N/A" ? "N/A" : str.tostring(nz(p12_basis_raw), "#.#") + " pts " + (p12_state == "Premium" ? "↑ Premium" : p12_state == "Discount" ? "↓ Discount" : "≈ Fair")
color p12_hud_col = p12_state == "Premium" ? #00ff88 : p12_state == "Discount" ? #ff4466 : color.silver

// ═══════════════════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════════════════
// FEATURE F2: Liquidity-Aware Sizing — v26.0
// ═══════════════════════════════════════════════════════════════════════════
// Purpose:        Grade F&O stocks by rolling turnover, adjust SL and gates
// Triggers:       Stocks mode only (op_mode == "Stocks")
// Consumers:      Trade Engine SL calcs, Priority 5/6 gates, HUD
// Dependencies:   op_mode
// Daily reset:    None (rolls daily via ta.sma on D resolution)
// Security calls: +1 (daily turnover SMA)
// Budget impact:  30 → 31/40

bool f_liq_active = op_mode == "Stocks" and liquidity_grading_enable
float f_liq_turnover_cr = f_liq_active ? request.security(syminfo.tickerid, "D", ta.sma(volume * close, 20)[1], lookahead=barmerge.lookahead_on) / 1e7 : na
string f_liq_grade = not f_liq_active or na(f_liq_turnover_cr) ? "—" : f_liq_turnover_cr >= f_liq_a_threshold ? "A" : f_liq_turnover_cr >= f_liq_b_threshold ? "B" : "C"
color f_liq_grade_col = f_liq_grade == "A" ? #00ff88 : f_liq_grade == "B" ? #ffaa00 : f_liq_grade == "C" ? #ff4466 : color.silver

bool f_liq_is_c = f_liq_grade == "C"
float f_liq_sl_buffer = f_liq_is_c ? 0.4 : 0.1
string f_liq_hud_txt = not f_liq_active ? "N/A (not Stocks mode)" : na(f_liq_turnover_cr) ? "Warming up" : f_liq_grade + " Grade | ₹" + str.tostring(f_liq_turnover_cr, "#.#") + " Cr/day"

// implied_pts placed here — requires _gap_u_open (defined above) for correct index anchor
// In options modes day_open is the premium open (~100-200pts) → nonsensically small VIX range
// _gap_u_open = decoupled index open (Nifty/BankNifty) — correct base for implied range
float vix_anchor_price = _use_ext_gap ? _gap_u_open : day_open
int   implied_pts      = int(math.round((implied_pct / 100) * vix_anchor_price))
string gap_type = math.abs(gap_pct) < 0.2 ? "Flat" : gap_pct > 0.75 ? "Gap Up" : gap_pct < -0.75 ? "Gap Down" : gap_pct > 0 ? "Small Up" : "Small Down"
string gap_strat = "Assessing..."
// Fix m2: Explicit color type annotation replaces the implicit `var`-less declaration.
// The original `strat_col = color.silver` without a type was re-initialized to silver
// every bar then immediately overwritten by `:=`. Explicit declaration is unambiguous
// and survives any future restructuring of the gap strategy block.
color strat_col = color.silver

var bool gap_filled = false
if is_new_day
    gap_filled := false
// Use _gap_u_pdc (decoupled gap reference) for gap fill detection — not pd_close.
// In options modes gap_pct is measured against the index close, so gap fill
// must also be measured against the index price, not the premium's pd_close.
// Collapse into a single tuple — saves 3 slots
float _gf_low  = na
float _gf_high = na
var float _gu_live_h = na
var float _gu_live_l = na

if _use_ext_gap
    // m8 FIX: Explicit lookahead_off — live H/L tracking, no future-bar leakage intended
    [_gu_live_h_new, _gu_live_l_new] = request.security(gap_target, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
    _gu_live_h := _gu_live_h_new
    _gu_live_l := _gu_live_l_new
    _gf_low  := _gu_live_l
    _gf_high := _gu_live_h
    if is_new_day
        _gu_session_h := _gu_live_h
        _gu_session_l := _gu_live_l
    else if in_market
        _gu_session_h := math.max(nz(_gu_session_h, _gu_live_h), _gu_live_h)
        _gu_session_l := math.min(nz(_gu_session_l, _gu_live_l), _gu_live_l)
else
    _gf_low  := low
    _gf_high := high
if not gap_filled and math.abs(gap_pct) > 0.2 and in_market
    if (gap_pct > 0 and _gf_low <= _gap_u_pdc) or (gap_pct < 0 and _gf_high >= _gap_u_pdc)
        gap_filled := true

// ── v27 Phase 2: Gap Magnet VA Qualifier — SVP Upgrade ──
// Gap magnet only primes if today's open is inside yesterday's value area.
// If today's open is above yesterday's VAH or below yesterday's VAL, the
// magnet aborts — institutional acceptance has moved, magnet is structurally invalid.
//
// UPGRADE from v26.2: VA source changed from ATR-proxy (pd_vwap_up1/dn1)
// to real SVP value area (svp_yday_vah/val) in Nifty/BankNifty modes.
// The ATR proxy (prev_vwap ± stdev) systematically overestimates the value area
// on trend days and underestimates on consolidation days. SVP real VA is accurate.
//
// Fallback chain (when SVP not yet ready — day 1 after indicator load):
//   Non-options modes: falls back to pd_vwap_up1/dn1 (ATR proxy, v26.2 behavior)
//   Options modes: _u_vah/_u_val unchanged (no SVP for options underlying)
//
// Options mode: VA abort uses _u_vah/_u_val (index underlying VA, not premium VA)
// This is unchanged from v26.2 — SVP tracks chart instrument only (the premium),
// so we cannot use svp_yday_vah for options mode VA abort.

// ── Non-options VA source: SVP real VA with ATR proxy fallback ──
float _pd_va_high = _use_ext_gap ? na : (svp_ready ? svp_yday_vah : pd_vwap_up1)

float _pd_va_low = _use_ext_gap ? na : (svp_ready ? svp_yday_val : pd_vwap_dn1)

bool pd_va_above = _use_ext_gap ? (not na(_u_vah) and _gap_u_open > _u_vah) : (not na(_pd_va_high) and day_open > _pd_va_high)
bool pd_va_below = _use_ext_gap ? (not na(_u_val) and _gap_u_open < _u_val) : (not na(_pd_va_low) and day_open < _pd_va_low)

bool just_filled        = gap_filled and (bar_index == 0 or not gap_filled[1])
// Launchpad: gap opened + waited 1 hour + price never recovered more than 30% of gap
// 30% threshold: institutional algorithms defend Go-and-Go days at 25-33% retracement
// gap_size uses decoupled values — consistent with gap_pct which also uses _gap_u_open/_gap_u_pdc
// MAJOR-1 FIX: In options modes, session_low/session_high are the PREMIUM's intraday range
// (e.g., CE at ₹180 low against ₹200 open). gap_size is the INDEX gap (e.g., 150 pts Nifty).
// day_open - gap_size * 0.3 = 200 - 45 = 155 → session_low > 155 (₹180 > 155) fires launchpad
// on nonsensical cross-instrument arithmetic. Fix: use underlying session data for comparison.
// _gu_session_l/h are populated for _use_ext_gap modes in the CRIT-2 block above.
// For non-options modes, _lp variables fall back to the original session_low/high values.
float gap_size = math.abs(_gap_u_open - _gap_u_pdc)
float _lp_session_low  = _use_ext_gap ? nz(_gu_session_l, _gap_u_open) : session_low
float _lp_session_high = _use_ext_gap ? nz(_gu_session_h, _gap_u_open) : session_high
float _lp_day_open     = _use_ext_gap ? _gap_u_open : day_open
bool is_launchpad_up = gap_pct >  0.5 and bars_since_open >= launchpad_bars and _lp_session_low  > (_lp_day_open - gap_size * 0.3)
bool is_launchpad_dn = gap_pct < -0.5 and bars_since_open >= launchpad_bars and _lp_session_high < (_lp_day_open + gap_size * 0.3)

// ── Launchpad + POC Anchor (Phase 3-I) ──
// POC-anchored launchpad: day_open is within _poc_prox of today's developing POC
bool poc_launchpad_up = is_launchpad_up and svp_track_dev and not na(svp_today_poc) and
     math.abs(svp_today_poc - day_open) <= _poc_prox * 1.5
bool poc_launchpad_dn = is_launchpad_dn and svp_track_dev and not na(svp_today_poc) and
     math.abs(svp_today_poc - day_open) <= _poc_prox * 1.5



// In options mode: use underlying session data (already computed via _lp_* variables)
// to detect runaway gaps — prevents magnet firing on launchpad/go-and-go days
// _lp_session_high < (_lp_day_open + gap_size * 0.3) = price never retraced 30% of gap = runaway
bool _opt_launchpad_up = _use_ext_gap and is_launchpad_up
bool _opt_launchpad_dn = _use_ext_gap and is_launchpad_dn

bool active_gap_magnet = not gap_filled and math.abs(gap_pct) > 0.75
                         and not (gap_pct > 0.75 and pd_va_above)
                         and not (gap_pct < -0.75 and pd_va_below)

if or_set
    if gap_filled and math.abs(gap_pct) > 0.2
        gap_strat := "Gap Filled ✓"
        strat_col := color.orange
    else if active_gap_magnet
        gap_strat := "Gap Magnet → " + str.tostring(_use_ext_gap ? _gap_u_pdc : pd_close, "#.#")
        strat_col := #ff8800
    else if is_launchpad_up
        gap_strat := poc_launchpad_up ? "Launchpad + POC ⚓ DO NOT SHORT" : "Launchpad: DO NOT SHORT"
        strat_col := color.fuchsia
    else if is_launchpad_dn
        gap_strat := poc_launchpad_dn ? "Launchpad + POC ⚓ DO NOT BUY"   : "Launchpad: DO NOT BUY"
        strat_col := color.fuchsia
    // ── v23 D3: Gap Trap CONFIRMED — moved ABOVE RUNAWAY ──
    // A1+B2: or_close_rmi threshold aligned with Tape gate (>60 DN, <40 UP)
    // A genuine gap trap requires RMI to confirm exhaustion at OR close.
    // A strong bear day can gap up and break down with or_close_rmi = 50 — that is NOT a trap.
    else if use_rmi_strategy and gap_pct > 0.2 and or_break_dir == -1 and not na(or_close_rmi) and or_close_rmi > 60
        gap_strat := "Gap Trap ↓ — Follow Break"
        strat_col := #ff8800
    else if use_rmi_strategy and gap_pct < -0.2 and or_break_dir == 1 and not na(or_close_rmi) and or_close_rmi < 40
        gap_strat := "Gap Trap ↑ — Follow Break"
        strat_col := #ff8800
    // ── v23 D2: Gap Trap PENDING — bridges the orphan window between OR set and break confirm ──
    // or_trap_warned was latched during pre-OR formation (Gap Trap Likely was showing).
    // or_break_dir == 0 means no confirmed break yet — 1-3 bar window.
    // Replaces misleading "Trend Follow" during this critical window.
    else if use_rmi_strategy and or_trap_warned and or_break_dir == 0
        gap_strat := "Gap Trap Pending → Watch Break"
        strat_col := #ff8800
    // ── v23 D4: RUNAWAY gated with RMI ──
    // is_hyper_momentum + RMI OB/OS = genuine runaway trend → full signal
    // is_hyper_momentum WITHOUT RMI confirmation = exhaustion spike, not a trend day
    // On gap trap days the final spike into VWAP +2σ is the exhaustion top — NOT a runaway
    else if is_hyper_momentum_bar and (_rmi_ob or _rmi_os)
        gap_strat := "RUNAWAY — No Fade"
        strat_col := color.red
    else if is_hyper_momentum_bar and not (_rmi_ob or _rmi_os)
        gap_strat := "Extended — Caution"
        strat_col := #ff8800
    else if math.abs(gap_pct) < 0.2
        gap_strat := "Range Play"
        strat_col := color.white
    else if math.abs(gap_pct) > 1.5
        gap_strat := "Fade Extreme"
        strat_col := color.yellow
    else
        gap_strat := "Trend Follow"
        strat_col := color.green

// ── Options Mode Premium Warning — v24 (Post-Evaluation Append) ──
// MUST be after the entire if or_set block completes — not before or inside it.
// MAJOR-2 FIX: Replaced color-muting approach with a text prefix [OPT].
//
// Old approach: muted green/white to amber — this created a false visual equivalence
// between "Trend Follow ⚠ Premium" (amber) and "Launchpad: DO NOT SHORT" (fuchsia),
// making an options chart look like a higher-risk environment than a clear structural
// block signal, which is backwards from the trader's decision hierarchy.
//
// New approach: prefix [OPT] is prepended to all strategy text on options charts.
// Structural signal colors (fuchsia, red, orange, yellow) are NEVER modified.
// The [OPT] tag reminds the trader that OR/VWAP levels are computed on the premium
// rather than the underlying, without overriding the primary directional verdict.
// This means "Launchpad: DO NOT SHORT" stays fuchsia — the dominant cue is correct.
if (op_mode == "Index Options" or op_mode == "Stock Options") and or_set
    gap_strat := "[OPT] " + gap_strat

// ── v23 D1+D2: Gap Trap pre-warning + or_trap_warned latch ──
// During OR formation: fires when RMI conflicts with gap direction
// Latches or_trap_warned at the moment OR sets so the pending state can bridge the gap
// C1: or_trap_warned is NOT reset when or_break_dir resets to 0 (price returns inside OR)
// It is a session-level conviction latch — resets only on is_new_day. Intentional.
if not or_set and use_rmi_strategy
    if gap_pct > 0.2 and _rmi_forming_ob
        gap_strat := "Gap Trap Likely ↓"
        strat_col := #ff8800
    else if gap_pct < -0.2 and _rmi_forming_os
        gap_strat := "Gap Trap Likely ↑"
        strat_col := #ff8800

// Latch or_trap_warned at the exact bar OR sets if a Gap Trap Likely was active
// This preserves the pre-OR warning context through the break confirmation window
if or_set and not or_trap_warned and use_rmi_strategy
    if gap_pct > 0.2 and not na(or_close_rmi) and or_close_rmi > 60
        or_trap_warned := true
    else if gap_pct < -0.2 and not na(or_close_rmi) and or_close_rmi < 40
        or_trap_warned := true

// ── ADR Bands ──
// adr_5: in options modes syminfo.tickerid is the premium — CE/PE range ~30-80pts vs index ~200pts
// Tape uses adr_used_pct < 80 as execution gate — premium ADR makes this gate structurally wrong
// adr_5 is now computed inside the hoisted gap_target tuple block above (CRITICAL-2 / MAJOR-2 fix).
// adr_upper/lower: anchor to _gap_u_open (decoupled index open) in options modes
// day_open is the premium open in options mode — wrong price base for index ADR bands
float adr_upper = _use_ext_gap ? _gap_u_open + (adr_5 * 0.5) : day_open + (adr_5 * 0.5)
float adr_lower = _use_ext_gap ? _gap_u_open - (adr_5 * 0.5) : day_open - (adr_5 * 0.5)

// CRIT-2 FIX (updated): Underlying index session range handled in the collapsed _gf_low/_gf_high block above.

float true_session_range = _use_ext_gap ? nz(_gu_session_h - _gu_session_l, 0.0) : session_range
bool  early_adr_exhaustion = adr_used_pct >= 90 and ist_t <= 1100

bool gate_gap_filter      = math.abs(gap_pct) < 0.75 or bars_since_open >= launchpad_bars + int(math.max(1, 30 / tf))
float trap_quality_thresh = (or_h - or_l) * (trap_quality_pct / 100)

bool trap_qual_up = close[1] < open[1] and math.abs(close[1] - open[1]) >= trap_quality_thresh
bool trap_qual_dn = close[1] > open[1] and math.abs(close[1] - open[1]) >= trap_quality_thresh

bool trap_up_signal = or_set and bars_since_open >= launchpad_bars + 3 and gate_gap_filter and trap_up_cooldown == 0 and trap_qual_up and (or_break_dir == 0 and or_break_dir[1] == 1  and bars_since_break_up <= 5 and not t05_hit_up)
bool trap_dn_signal = or_set and bars_since_open >= launchpad_bars + 3 and gate_gap_filter and trap_dn_cooldown == 0 and trap_qual_dn and (or_break_dir == 0 and or_break_dir[1] == -1 and bars_since_break_dn <= 5 and not t05_hit_dn)

if trap_up_signal and is_today and barstate.isconfirmed
    trap_up_cooldown := trap_cooldown_bars
    string _trap_sfx = or_h_conf_weight >= 2 ? " HVN" : ""
    f_set_managed_lbl_shape(20, true, "high", 0.0, "▽" + _trap_sfx, #ff2244, color.white, "down", "small")
if trap_dn_signal and is_today and barstate.isconfirmed
    trap_dn_cooldown := trap_cooldown_bars
    string _trap_sfx = or_l_conf_weight >= 2 ? " HVN" : ""
    f_set_managed_lbl_shape(21, true, "low", 0.0, "△" + _trap_sfx, #00bb66, color.white, "up", "small")

if barstate.isconfirmed
    if trap_up_cooldown > 0
        trap_up_cooldown -= 1
    if trap_dn_cooldown > 0
        trap_dn_cooldown -= 1

f_compute_brk_scores() =>
    float _body_rng  = math.max(syminfo.mintick, high - low)
    bool  _brk_vol   = r_vol > avg_vol * 1.5
    bool  _vol_up    = first_break_up and _brk_vol
    bool  _vol_dn    = first_break_dn and _brk_vol
    float _brk_body_up   = math.max(0, math.min(close, high) - or_h)
    float _brk_body_dn   = math.max(0, or_l - math.max(close, open))
    float _brk_total     = math.abs(close - open)
    bool  _body_up   = first_break_up and (_brk_total > 0 ? (_brk_body_up / _brk_total) * 100 : 0.0) >= 50.0
    bool  _body_dn   = first_break_dn and (_brk_total > 0 ? (_brk_body_dn / _brk_total) * 100 : 0.0) >= 50.0
    float _buf       = current_atr * 0.25
    bool  _atr_up    = first_break_up and close > (or_h + _buf)
    bool  _atr_dn    = first_break_dn and close < (or_l - _buf)
    bool  _vwp_up    = first_break_up and (_use_ext_gap ? _u_close > vwap_val : r_close > vwap_val)
    bool  _vwp_dn    = first_break_dn and (_use_ext_gap ? _u_close < vwap_val : r_close < vwap_val)
    int   _brk_rmi_up = 0
    int   _brk_rmi_dn = 0
    if use_rmi_brk_score and not na(or_close_rmi)
        if first_break_up
            _brk_rmi_up := or_close_rmi < 60 ? 1 : or_close_rmi > 70 ? -1 : 0
        if first_break_dn
            _brk_rmi_dn := or_close_rmi > 40 ? 1 : or_close_rmi < 30 ? -1 : 0
    int _rsi_pen_up = (not na(d_rsi14) and d_rsi14 > 70 and gap_pct > -0.5) ? -1 : 0
    int _rsi_pen_dn = (not na(d_rsi14) and d_rsi14 < 30 and gap_pct <  0.5) ? -1 : 0
    int _poc_up = first_break_up and svp_track_dev and not na(svp_today_poc) ? (svp_today_poc < or_l ? 1 : svp_today_poc > or_h ? -1 : 0) : 0
    int _poc_dn = first_break_dn and svp_track_dev and not na(svp_today_poc) ? (svp_today_poc > or_h ? 1 : svp_today_poc < or_l ? -1 : 0) : 0
    int _sc_up = (_vol_up ? 1 : 0) + (_body_up ? 1 : 0) + (_atr_up ? 1 : 0) + (_vwp_up ? 1 : 0) + _brk_rmi_up + _rsi_pen_up + _poc_up
    int _sc_dn = (_vol_dn ? 1 : 0) + (_body_dn ? 1 : 0) + (_atr_dn ? 1 : 0) + (_vwp_dn ? 1 : 0) + _brk_rmi_dn + _rsi_pen_dn + _poc_dn
    [_sc_up, _sc_dn, _vol_up, _vol_dn, _body_up, _body_dn, _atr_up, _atr_dn, _vwp_up, _vwp_dn, _brk_rmi_up, _brk_rmi_dn, _rsi_pen_up, _rsi_pen_dn, _poc_up, _poc_dn]

[brk_score_up, brk_score_dn, score_vol_up, score_vol_dn, score_body_up, score_body_dn, score_atr_up, score_atr_dn, score_vwp_up, score_vwp_dn, score_rmi_up, score_rmi_dn, score_rsi_pen_up, score_rsi_pen_dn, score_poc_up, score_poc_dn] = f_compute_brk_scores()
float body_rng  = math.max(syminfo.mintick, high - low)
int brk_score    = first_break_up ? brk_score_up : first_break_dn ? brk_score_dn : 0


bool anchor_contradiction = false
if first_break_up and str.contains(candle_anchor, "Bear")
    anchor_contradiction := true
if first_break_dn and str.contains(candle_anchor, "Bull")
    anchor_contradiction := true

if first_break_up
    stored_brk_score            := brk_score_up
    stored_anchor_contradiction := anchor_contradiction
    stored_score_vol            := score_vol_up
    stored_score_body           := score_body_up
    stored_score_atr            := score_atr_up
    stored_score_vwp            := score_vwp_up
    stored_score_rmi            := score_rmi_up
    stored_score_rsi            := score_rsi_pen_up
    stored_score_poc            := score_poc_up
else if first_break_dn
    stored_brk_score            := brk_score_dn
    stored_anchor_contradiction := anchor_contradiction
    stored_score_vol            := score_vol_dn
    stored_score_body           := score_body_dn
    stored_score_atr            := score_atr_dn
    stored_score_vwp            := score_vwp_dn
    stored_score_rmi            := score_rmi_dn
    stored_score_rsi            := score_rsi_pen_dn
    stored_score_poc            := score_poc_dn

if or_break_dir == 0 and or_break_dir[1] != 0
    stored_brk_score            := 0
    stored_anchor_contradiction := false
    stored_score_vol            := false
    stored_score_body           := false
    stored_score_atr            := false
    stored_score_vwp            := false
    stored_score_rmi            := 0
    stored_score_rsi            := 0
    stored_score_poc            := 0
    // or_trap_warned intentionally NOT reset here — it is a session-level latch
    // bridging the gap between OR set and break confirmation. Resets only on new day.

f_draw_break_arrows(int _brk_score, bool _anchor_contr) =>
    if (first_break_up or first_break_dn) and barstate.isconfirmed and _brk_score >= 2 and is_today
        int _display_score = math.min(5, math.max(0, _brk_score))
        string _score_txt = show_brk_labels ? "[" + str.tostring(_display_score) + "/5]" : ""
        color _break_up_col = #00ff88
        color _break_dn_col = #ff4466
        if first_break_up
            color _dyn = vix_val > 18 ? #ffaa00 : _break_up_col
            color _ac  = _anchor_contr ? #ffaa00 : _brk_score >= 3 ? _dyn : color.new(_dyn, 60)
            string _sfx = str.length(p4_class) > 0 ? " " + p4_class : ""
            string _txt = _anchor_contr ? "↑ " + _score_txt + _sfx + " ⚠" : "↑ " + _score_txt + _sfx
            f_set_managed_lbl_shape(22, true, "low", 0.3, _txt, color.new(color.black, 100), _ac, "up", _brk_score >= 3 ? "normal" : "small")
        if first_break_dn
            color _dyn = vix_val > 18 ? #ffaa00 : _break_dn_col
            color _ac  = _anchor_contr ? #ffaa00 : _brk_score >= 2 ? _dyn : color.new(_dyn, 60)
            string _sfx = str.length(p4_class) > 0 ? " " + p4_class : ""
            string _txt = _anchor_contr ? "↓ " + _score_txt + _sfx + " ⚠" : "↓ " + _score_txt + _sfx
            f_set_managed_lbl_shape(23, true, "high", 0.3, _txt, color.new(color.black, 100), _ac, "down", _brk_score >= 3 ? "normal" : "small")

f_draw_break_arrows(brk_score, anchor_contradiction)

float pct_above_vwap = _use_ext_gap ? 0.0 : f_confirm_pct(vwap_val, true)
float pct_below_vwap = _use_ext_gap ? 0.0 : f_confirm_pct(vwap_val, false)

// Fix m1: Changed `or` to `and` for both crossed conditions.
// `or` (either of 2 prior bars below) allowed re-triggering when price had been above
// VWAP for a bar then oscillated — r_close[2] still below VWAP re-fired the "reclaim"
// every bar. `and` requires BOTH prior bars to have been on the wrong side, enforcing
// a genuine fresh cross rather than a chop-zone re-entry.
// Same stricter logic applied to prev_vwap crossed conditions for consistency.
// Gated in options mode to prevent scale-mismatch false positives.
bool vwap_recently_crossed_up = not _use_ext_gap and r_close[1] < vwap_val[1] and r_close[2] < vwap_val[2]
bool vwap_recently_crossed_dn = not _use_ext_gap and r_close[1] > vwap_val[1] and r_close[2] > vwap_val[2]
bool vwap_recently_crossed_up_u = _use_ext_gap and _u_close[1] < vwap_val[1] and _u_close[2] < vwap_val[2]
bool vwap_recently_crossed_dn_u = _use_ext_gap and _u_close[1] > vwap_val[1] and _u_close[2] > vwap_val[2]

// ── FEATURE: VWAP Reclaim Quality Scoring ──
f_get_vwap_scores(_r_close, _vwap_val, _crossed_up, _crossed_dn, _vol_sma20, _vol, _h, _l, _o, _c, _rmi_rising_ext, _rmi_falling_ext, _rmi, _t) =>
    bool _vol_surge   = _vol > _vol_sma20 * 1.5
    bool _bull_close  = (_h != _l) and ((_c - _o) / (_h - _l) > 0.7)
    bool _bear_close  = (_h != _l) and ((_o - _c) / (_h - _l) > 0.7)
    bool _rmi_rising  = _rmi > 50 and _rmi_rising_ext
    bool _rmi_falling = _rmi < 50 and _rmi_falling_ext
    bool _prime_time  = _t >= 930 and _t <= 1100
    int _r_score = (_r_close > _vwap_val and _crossed_up) ? ((_vol_surge ? 2 : 0) + (_bull_close ? 1 : 0) + (_rmi_rising ? 1 : 0) + (_prime_time ? 1 : 0)) : 0
    int _j_score = (_r_close < _vwap_val and _crossed_dn) ? ((_vol_surge ? 2 : 0) + (_bear_close ? 1 : 0) + (_rmi_falling ? 1 : 0) + (_prime_time ? 1 : 0)) : 0
    [_r_score, _j_score]

// m3 FIX: Pass r_vol not volume — on options charts volume is premium contract turnover,
// not the underlying futures volume that drives institutional VWAP interaction quality
bool _rmi_rising_ext  = ta.rising(_rmi_val, 3)
bool _rmi_falling_ext = ta.falling(_rmi_val, 3)
float _r_vol_sma20     = ta.sma(r_vol, 20)
[vwap_reclaim_score, vwap_reject_score] = f_get_vwap_scores(r_close, vwap_val, vwap_recently_crossed_up, vwap_recently_crossed_dn, _r_vol_sma20, r_vol, high, low, open, close, _rmi_rising_ext, _rmi_falling_ext, _rmi_val, ist_t)

float _u_body    = _use_ext_gap ? math.max(math.abs(_u_close - _u_open), syminfo.mintick) : 0.0
float _u_confirm = _use_ext_gap ? (_u_close > vwap_val ? math.max(0, _u_close - math.max(vwap_val, _u_open)) : math.max(0, math.min(vwap_val, _u_open) - _u_close)) : 0.0
float _u_confirm_pct = _use_ext_gap ? (_u_confirm / _u_body) * 100 : 0.0

pct_above_vwap := _use_ext_gap ? (not na(_u_close) and _u_close > vwap_val ? _u_confirm_pct : 0.0) : f_confirm_pct(vwap_val, true)
pct_below_vwap := _use_ext_gap ? (not na(_u_close) and _u_close < vwap_val ? _u_confirm_pct : 0.0) : f_confirm_pct(vwap_val, false)
bool vwap_reclaim = show_vwap_sig and barstate.isconfirmed and (_use_ext_gap ? (not na(_u_close) and _u_close > vwap_val and pct_above_vwap >= 50.0 and vwap_recently_crossed_up_u) : (vwap_reclaim_score >= 3 and pct_above_vwap >= body_confirm_pct))
bool vwap_reject  = show_vwap_sig and barstate.isconfirmed and (_use_ext_gap ? (not na(_u_close) and _u_close < vwap_val and pct_below_vwap >= 50.0 and vwap_recently_crossed_dn_u) : (vwap_reject_score >= 3 and pct_below_vwap >= body_confirm_pct))

float pct_above_pvwap = f_confirm_pct(prev_vwap, true)
float pct_below_pvwap = f_confirm_pct(prev_vwap, false)
bool  pvwap_recently_crossed_up = r_close[1] < prev_vwap[1] and r_close[2] < prev_vwap[2]
bool  pvwap_recently_crossed_dn = r_close[1] > prev_vwap[1] and r_close[2] > prev_vwap[2]
bool  prev_vwap_cross_up = r_close > prev_vwap and pvwap_recently_crossed_up and pct_above_pvwap >= body_confirm_pct
bool  prev_vwap_cross_dn = r_close < prev_vwap and pvwap_recently_crossed_dn and pct_below_pvwap >= body_confirm_pct

if (vwap_reclaim or vwap_reject) and barstate.isconfirmed
    if vwap_reclaim
        vwap_reclaimed      := true
        vwap_rejected       := false
        vwap_r1_retest_done := false
    if vwap_reject
        vwap_rejected       := true
        vwap_reclaimed      := false
        vwap_r1_reject_done := false

float vwap_proximity     = current_atr * 0.20
bool  touched_vwap_from_above = low  <= vwap_val + vwap_proximity and low  >= vwap_val - vwap_proximity
bool  retest_close_holds      = r_close > vwap_val
bool  body_holds_above        = pct_above_vwap >= 50.0

bool vwap_reclaim_retest = show_vwap_sig and vwap_reclaimed and not vwap_r1_retest_done and not vwap_reclaim and touched_vwap_from_above and retest_close_holds and body_holds_above and barstate.isconfirmed

// ── VWAP Retest at POC Enhancement (Phase 3-E) ──
bool vwap_reclaim_retest_at_poc = vwap_reclaim_retest and poc_at_vwap

if vwap_reclaim_retest
    vwap_r1_retest_done := true

bool touched_vwap_from_below = high >= vwap_val - vwap_proximity and high <= vwap_val + vwap_proximity
bool reject_close_holds      = r_close < vwap_val
bool body_holds_below        = pct_below_vwap >= 50.0

bool vwap_reject_retest = show_vwap_sig and vwap_rejected and not vwap_r1_reject_done and not vwap_reject and touched_vwap_from_below and reject_close_holds and body_holds_below and barstate.isconfirmed

// ── VWAP Reject Retest at POC Enhancement (Phase 3-E) ──
bool vwap_reject_retest_at_poc  = vwap_reject_retest  and poc_at_vwap

if vwap_reject_retest
    vwap_r1_reject_done := true

// ── Retest Logic ──
bool bull_close_req = (auto_scale and tf >= 3) ? close > (or_h + retest_buf) : close > or_h
bool bear_close_req = (auto_scale and tf >= 3) ? close < (or_l - retest_buf) : close < or_l

// Fix M4: barstate.isconfirmed gates all four retest bools.
// Without it, a wick touch mid-candle with live close momentarily above OR permanently
// latches retest_up/dn_done = true before the bar has confirmed — suppressing all future
// retest detection for the session even when the actual candle close didn't qualify.
// m9 FIX: bars_since_break_up/dn > 1 prevents same-bar retest on wide-range breakout bars
// (a 9:45 break on 30m OR that retests within the same candle is not a structural retest)
bool or_retest_bull = show_or_retest and barstate.isconfirmed and not retest_up_done and or_break_dir == 1  and stored_brk_score >= 2 and bars_since_break_up > 1 and low  <= or_h + retest_buf and low  >= or_h - retest_buf and bull_close_req
bool or_retest_bear = show_or_retest and barstate.isconfirmed and not retest_dn_done and or_break_dir == -1 and stored_brk_score >= 2 and bars_since_break_dn > 1 and high >= or_l - retest_buf and high <= or_l + retest_buf and bear_close_req
if or_retest_bull
    retest_up_done := true
if or_retest_bear
    retest_dn_done := true

bool or_retest2_bull = show_or_retest and barstate.isconfirmed and retest_up_done and not retest2_up_done and or_break_dir == 1  and stored_brk_score >= 2 and low  <= or_h + retest_buf and low  >= or_h - retest_buf and bull_close_req
bool or_retest2_bear = show_or_retest and barstate.isconfirmed and retest_dn_done and not retest2_dn_done and or_break_dir == -1 and stored_brk_score >= 2 and high >= or_l - retest_buf and high <= or_l + retest_buf and bear_close_req
if or_retest2_bull
    retest2_up_done := true
if or_retest2_bear
    retest2_dn_done := true

// ── OR Retest Variables Moved to f_draw_retest_labels ──

// ── Sweep Detection (5m) ──
float up_wick   = high - math.max(open, close)
float dn_wick   = math.min(open, close) - low

bool valid_top_wick = (high - low) > 0 and (up_wick >= (high - low) * (swp_pct_5m / 100))
bool valid_bot_wick = (high - low) > 0 and (dn_wick >= (high - low) * (swp_pct_5m / 100))

// MINOR-1 FIX: `show_adr and not _use_ext_gap` guard on ADR sweep conditions.
// In options modes, adr_upper (~22,100) and adr_lower (~21,900) are index prices.
// A premium close (~₹150) will never exceed 22,100, so these conditions are permanently
// false — evaluating them on every bar is dead computation. Suppressed with the same guard
// used on the visual plots. Non-options modes: behavior unchanged (guard is false).
bool top_sweep = show_sweeps and barstate.isconfirmed and valid_top_wick and ((high > pd_high and close < pd_high) or (or_set and high > or_h and close < or_h) or (show_adr and not _use_ext_gap and high > adr_upper and close < adr_upper) or (show_weekly and high > pw_high and close < pw_high) or (high > pd_close and close < pd_close) or (show_pd_vwap and not na(prev_vwap) and high > prev_vwap and close < prev_vwap) or (show_poc and not na(prev_poc) and high > prev_poc and close < prev_poc) or (svp_track_dev and not na(svp_today_poc) and high > svp_today_poc and close < svp_today_poc and bars_since_open >= 12))
bool bot_sweep = show_sweeps and barstate.isconfirmed and valid_bot_wick and ((low < pd_low and close > pd_low) or (or_set and low < or_l and close > or_l) or (show_adr and not _use_ext_gap and low < adr_lower and close > adr_lower) or (show_weekly and low < pw_low and close > pw_low) or (low < pd_close and close > pd_close) or (show_pd_vwap and not na(prev_vwap) and low < prev_vwap and close > prev_vwap) or (show_poc and not na(prev_poc) and low < prev_poc and close > prev_poc) or (svp_track_dev and not na(svp_today_poc) and low < svp_today_poc and close > svp_today_poc and bars_since_open >= 12))


// ── P5: Pre-OR Sweep Detection ──
// Watches PDH, PDL, PrevVWAP only — only levels relevant before OR forms.
// Window: SESSION_OPEN to or_eff_end_val (9:15–9:29 on 15m OR, 9:15–9:44 on 30m OR).
// Uses valid_top_wick / valid_bot_wick already computed above (same thresholds).
// Latch: first sweep per day wins. p5_sweep_dir == 0 guard prevents re-firing.

bool _p5_window = not or_set and in_market and ist_t >= SESSION_OPEN and ist_t < or_eff_end_val and barstate.isconfirmed

// Top sweeps (institutional sell-stop hunt → bear bias after)
bool _p5_top_pdh   = _p5_window and valid_top_wick and not na(pd_high) and high > pd_high and close < pd_high
bool _p5_top_pvwap = _p5_window and valid_top_wick and not na(prev_vwap) and high > prev_vwap and close < prev_vwap
bool _p5_top_pdl   = _p5_window and valid_top_wick and not na(pd_low) and high > pd_low and close < pd_low

// ── P5 Pre-OR Sweep pPOC Tagging (Addition O) ──
bool _p5_top_ppoc  = _p5_window and valid_top_wick and not na(svp_yday_poc) and high > svp_yday_poc and close < svp_yday_poc
bool _p5_bot_ppoc  = _p5_window and valid_bot_wick and not na(svp_yday_poc) and low < svp_yday_poc and close > svp_yday_poc

// Bottom sweeps (institutional buy-stop hunt → bull bias after)
bool _p5_bot_pdl   = _p5_window and valid_bot_wick and not na(pd_low) and low < pd_low and close > pd_low
bool _p5_bot_pvwap = _p5_window and valid_bot_wick and not na(prev_vwap) and low < prev_vwap and close > prev_vwap
bool _p5_bot_pdh   = _p5_window and valid_bot_wick and not na(pd_high) and low < pd_high and close > pd_high

bool p5_top_sweep = (_p5_top_pdh or _p5_top_pvwap or _p5_top_pdl or _p5_top_ppoc) and p5_sweep_dir == 0
bool p5_bot_sweep = (_p5_bot_pdl or _p5_bot_pvwap or _p5_bot_pdh or _p5_bot_ppoc) and p5_sweep_dir == 0

// Latch direction and level name on first detected sweep
if p5_top_sweep
    p5_sweep_dir   := 1
    p5_sweep_level := _p5_top_ppoc ? "pPOC" : _p5_top_pdh ? "PDH" : _p5_top_pvwap ? "PrevVWAP" : "PDL"
if p5_bot_sweep
    p5_sweep_dir   := -1
    p5_sweep_level := _p5_bot_ppoc ? "pPOC" : _p5_bot_pdl ? "PDL" : _p5_bot_pvwap ? "PrevVWAP" : "PDH"


// ── P5 HUD display strings ──
string p5_hud_txt = p5_sweep_dir == 1 ? "× " + p5_sweep_level + " Swept → Bear bias" : p5_sweep_dir == -1 ? "× " + p5_sweep_level + " Swept → Bull bias" : not or_set ? "Clean — No sweep" : ""
color p5_hud_col = p5_sweep_dir == 1 ? #ff8844 : p5_sweep_dir == -1 ? #44ddaa : color.new(color.gray, 40)
// C4 FIX: Use or_eff_end (user-configured OR end time) not hardcoded OR_END_DEFAULT (930)
// On 30m OR days, OR_END_DEFAULT=930 fires absorption during active OR construction (9:30–9:45)
bool is_abs    = show_abs and (ist_t >= or_eff_end_val) and tod_vol_confirm and (high - low > 0) and (math.abs(close - open) < (high - low) * 0.3) and barstate.isconfirmed

// Phase 3: Exhaustion signals use ToD RVOL instead of flat avg_vol
// exh_vol_confirm: uses exh_vol_pct threshold (input, default 250%) against ToD RVOL
// Fallback to avg_vol * d_abs_mult * 1.3 during matrix warmup (h_avg == 0)
// or_set gate: pre-OR exhaustion signals are noise — OR formation naturally creates swing highs/lows
bool exh_vol_confirm = h_avg > 0 ? (tod_rvol >= exh_vol_pct) : (r_vol > avg_vol * d_abs_mult * 1.3)
// Hoist ta.highest/ta.lowest to unconditional global scope — Pine warning fix.
// These series functions must execute on every bar regardless of or_set to maintain
// a consistent lookback window. If gated inside `or_set and (...)`, short-circuit
// evaluation skips them when or_set=false, corrupting the historical calculation.
float _exh_swing_high = ta.highest(high, exh_lookback)
float _exh_swing_low  = ta.lowest(low,  exh_lookback)
// MAJOR FIX v25.2: Add barstate.isconfirmed to prevent intrabar alert spam
// Problem: volatile candles momentarily touch swing highs/lows mid-candle, firing phantom alerts
// Solution: Require bar confirmation before exhaustion nodes trigger
var bool exhaustion_top = false
var int last_exh_top_bar = 0
bool raw_exh_top = or_set and (high == _exh_swing_high) and valid_top_wick and exh_vol_confirm and barstate.isconfirmed
if raw_exh_top and (bar_index - last_exh_top_bar > 3)
    exhaustion_top := true
    last_exh_top_bar := bar_index
else if barstate.isconfirmed
    exhaustion_top := false

var int last_exh_bot_bar = 0
bool raw_exh_bot = or_set and (low  == _exh_swing_low)  and valid_bot_wick and exh_vol_confirm and barstate.isconfirmed
var bool exhaustion_bot = false
if raw_exh_bot and (bar_index - last_exh_bot_bar > 3)
    exhaustion_bot := true
    last_exh_bot_bar := bar_index
else if barstate.isconfirmed
    exhaustion_bot := false

// ── HTF Sweep Detection (Fully Loaded 15m/30m Matrix + CTA Safety) ──

// 1. Calculate Wick Proportions using LIVE HTF data (no [1] lag)
// 1. Calculate Wick Proportions using LIVE HTF data (no [1] lag)
// Moved into gated blocks below (Fix 6) to eliminate future-data leakage in global scope.
var bool h15_vtw = false
var bool h15_vbw = false
var bool h30_vtw = false
var bool h30_vbw = false

if barstate.isconfirmed
    h15_vtw := false
    h15_vbw := false
    h30_vtw := false
    h30_vbw := false


bool new_hour = ta.change(time("60")) != 0
// MAJOR-3 FIX: new_15m and new_30m removed — never referenced anywhere in the script.
// HTF close detection (CRITICAL FIX v25.3): Modular arithmetic on time_close
// Problem: ta.change(time("15")) fires on the OPEN of the new 15m bar (e.g. 9:30 bar),
//          not the CLOSE of the previous bar (e.g. 9:25–9:30 bar). With lookahead_on this
//          causes h15_high to fetch the future forming HTF bar, leaking future data.
// Problem: time_close equality breaks on abnormal NSE sessions (Diwali Muhurat etc.)
// Solution: Modular arithmetic on time_close fires on the exact bar whose close timestamp
//           lands on the HTF boundary. Survives all abnormal session hours.
// Example:  9:25–9:30 bar has time_close = 9:30:00 → minute(time_close) % 15 == 0 ✅
//           9:30–9:35 bar has time_close = 9:35:00 → minute(time_close) % 15 == 5 ❌
bool is_15m_close = (minute(time_close) % 15) == 0
// CRITICAL FIX v25.4: NSE 9:15 open shifts 30m boundaries to :15 and :45
// 30m closes: 9:45(45), 10:15(15), 10:45(45), 11:15(15) → minute % 30 == 15
// Bug: % 30 == 0 targeted :00 and :30 — those never occur as NSE 30m closes → dead code
bool is_30m_close = (minute(time_close) % 30) == 15

// MINOR-3 FIX: HTF sweep megaexpressions decomposed into named pool bools.
// Each level pool is independently readable and editable — no more 350-char single lines.
// Logic is byte-for-byte identical. Named bools: h15_swept_* / h30_swept_*
// ALSO: `show_adr and not _use_ext_gap` guard applied to HTF ADR pool conditions,
// consistent with the MINOR-1 fix on 5m sweeps — index-scale levels never fire on options.

// 3. Master trigger: live wick + precise bar + 5m close confirmation in each pool
// ── 15m Top Sweep pools ──
bool h15_swept_pdh    = h15_high > pd_high    and h15_close < pd_high
bool h15_swept_orh    = or_set and h15_high > or_h      and h15_close < or_h
bool h15_swept_adr_up = show_adr and not _use_ext_gap and h15_high > adr_upper  and h15_close < adr_upper
bool h15_swept_pwh    = show_weekly and h15_high > pw_high    and h15_close < pw_high
bool h15_swept_pdc_t  = h15_high > pd_close   and h15_close < pd_close
bool h15_swept_pvwap_t = show_pd_vwap and not na(prev_vwap) and h15_high > prev_vwap and h15_close < prev_vwap
// bool h15_swept_poc_t  = show_poc and not na(prev_poc) and h15_high > prev_poc   and h15_close < prev_poc

// ── 15m Bottom Sweep pools ──
bool h15_swept_pdl    = h15_low < pd_low      and h15_close > pd_low
bool h15_swept_orl    = or_set and h15_low < or_l      and h15_close > or_l
bool h15_swept_adr_dn = show_adr and not _use_ext_gap and h15_low < adr_lower   and h15_close > adr_lower
bool h15_swept_pwl    = show_weekly and h15_low < pw_low     and h15_close > pw_low
bool h15_swept_pdc_b  = h15_low < pd_close    and h15_close > pd_close
bool h15_swept_pvwap_b = show_pd_vwap and not na(prev_vwap) and h15_low < prev_vwap  and h15_close > prev_vwap
// bool h15_swept_poc_b  = show_poc and not na(prev_poc) and h15_low < prev_poc    and h15_close > prev_poc


// Temporarily removed 3-day POC sweep pool for v27 Phase 0
bool h15_swept_poc_t = false

bool h15_swept_poc_b = false

var bool h15_top_sweep = false
var bool h15_bot_sweep = false
if barstate.isconfirmed
    h15_top_sweep := false
    h15_bot_sweep := false

if show_sweeps_15 and is_15m_close and barstate.isconfirmed
    float _u = h15_high - math.max(h15_open, h15_close)
    float _d = math.min(h15_open, h15_close) - h15_low
    float _r = h15_high - h15_low
    h15_vtw := _r > 0 and (_u >= _r * (htf_swp_pct / 100))
    h15_vbw := _r > 0 and (_d >= _r * (htf_swp_pct / 100))
    
    h15_top_sweep := is_today and h15_vtw and (h15_swept_pdh or h15_swept_orh or h15_swept_adr_up or h15_swept_pwh or h15_swept_pdc_t or h15_swept_pvwap_t or h15_swept_poc_t)
    h15_bot_sweep := is_today and h15_vbw and (h15_swept_pdl or h15_swept_orl or h15_swept_adr_dn or h15_swept_pwl or h15_swept_pdc_b or h15_swept_pvwap_b or h15_swept_poc_b)

bool h30_swept_pdh    = h30_high > pd_high    and h30_close < pd_high
bool h30_swept_orh    = or_set and h30_high > or_h      and h30_close < or_h
bool h30_swept_adr_up = show_adr and not _use_ext_gap and h30_high > adr_upper  and h30_close < adr_upper
bool h30_swept_pwh    = show_weekly and h30_high > pw_high    and h30_close < pw_high
bool h30_swept_pdc_t  = h30_high > pd_close   and h30_close < pd_close
bool h30_swept_pvwap_t = show_pd_vwap and not na(prev_vwap) and h30_high > prev_vwap and h30_close < prev_vwap
// Temporarily removed 3-day POC sweep pool for v27 Phase 0
bool h30_swept_poc_t = false

bool h30_swept_pdl    = h30_low < pd_low      and h30_close > pd_low
bool h30_swept_orl    = or_set and h30_low < or_l      and h30_close > or_l
bool h30_swept_adr_dn = show_adr and not _use_ext_gap and h30_low < adr_lower   and h30_close > adr_lower
bool h30_swept_pwl    = show_weekly and h30_low < pw_low     and h30_close > pw_low
bool h30_swept_pdc_b  = h30_low < pd_close    and h30_close > pd_close
bool h30_swept_pvwap_b = show_pd_vwap and not na(prev_vwap) and h30_low < prev_vwap  and h30_close > prev_vwap
// Temporarily removed 3-day POC sweep pool for v27 Phase 0
bool h30_swept_poc_b = false

var bool h30_top_sweep = false
var bool h30_bot_sweep = false
if barstate.isconfirmed
    h30_top_sweep := false
    h30_bot_sweep := false

if show_sweeps_30 and is_30m_close and barstate.isconfirmed
    float _u = h30_high - math.max(h30_open, h30_close)
    float _d = math.min(h30_open, h30_close) - h30_low
    float _r = h30_high - h30_low
    h30_vtw := _r > 0 and (_u >= _r * (htf_swp_pct / 100))
    h30_vbw := _r > 0 and (_d >= _r * (htf_swp_pct / 100))

    h30_top_sweep := is_today and h30_vtw and (h30_swept_pdh or h30_swept_orh or h30_swept_adr_up or h30_swept_pwh or h30_swept_pdc_t or h30_swept_pvwap_t or h30_swept_poc_t)
    h30_bot_sweep := is_today and h30_vbw and (h30_swept_pdl or h30_swept_orl or h30_swept_adr_dn or h30_swept_pwl or h30_swept_pdc_b or h30_swept_pvwap_b or h30_swept_poc_b)

// ── SMT Divergence Engine ──
bool is_n_swing_h = high == ta.highest(high, smt_lookback)
bool is_n_swing_l = low  == ta.lowest(low,  smt_lookback)
bool is_b_swing_h = c_high == ta.highest(c_high, smt_lookback)
bool is_b_swing_l = c_low  == ta.lowest(c_low,  smt_lookback)

var int smt_bear_cooldown = 0
var int smt_bull_cooldown = 0

// ── SMT / RS-RW Polarity Router — v24 ──
// Raw divergence: detects structural swing divergence between chart and benchmark
bool _raw_div_pdl = show_smt and is_n_swing_l and not is_b_swing_l and barstate.isconfirmed
bool _raw_div_pdh = show_smt and is_n_swing_h and not is_b_swing_h and barstate.isconfirmed

// Polarity routing by mode:
// Index mode:  instrument lower low vs BankNifty = absorption = BULLISH divergence
// Equity mode: stock lower low vs Nifty          = relative weakness = BEARISH signal
// Swapping at source means entire downstream engine — fuel system, cooling pause
// bypass, SMT counters, thesis break logic, HUD — inherits correct polarity
// with zero engine rewrites needed anywhere downstream.
bool smt_bull_pdl = is_equity_mode ? _raw_div_pdh : _raw_div_pdl
bool smt_bear_pdh = is_equity_mode ? _raw_div_pdl : _raw_div_pdh
color smt_col = smt_bear_pdh ? color.red : smt_bull_pdl ? color.green : color.silver
// Display gate uses RAW geometry bools — not engine-remapped bools.
// In equity mode _raw_div_pdh = stock made higher high vs Nifty (plots at HIGH).
// In equity mode _raw_div_pdl = stock made lower low vs Nifty (plots at LOW).
// Using engine bools (smt_bull_pdl/smt_bear_pdh) in equity mode would anchor
// arrows on the wrong wick — visually broken, structurally misleading.
bool raw_bear_show = _raw_div_pdh and (not smt_or_gate or or_set)
bool raw_bull_show = _raw_div_pdl and (not smt_or_gate or or_set)

// MAJOR-2 FIX: smt_bull_col / smt_bear_col were referenced in label draws below
// but never declared anywhere in the file — a silent undefined variable that either
// causes a compile error or resolves to na (invisible labels) in Pine v6.
// Declared here, immediately before their first use. Colours match the CVD palette
// for visual consistency: green = bullish absorption, red = bearish distribution.
color smt_bull_col = #00ff88  // Green — Bullish SMT / RS Strength
color smt_bear_col = #ff2244  // Red   — Bearish SMT / RS Weakness

var label _smt_bear_lbl = na
var label _smt_bull_lbl = na

if true
    if raw_bear_show and is_today
        smt_bear_cooldown := 10
        color  lbl_col = is_equity_mode ? smt_bull_col : smt_bear_col
        string lbl_txt = is_equity_mode ? "▲" : "▼"
        label.delete(_smt_bear_lbl)
        _smt_bear_lbl := label.new(bar_index, high + (current_atr * 0.4), lbl_txt, style=label.style_none, textcolor=lbl_col, size=size.small)
    if raw_bull_show and is_today
        smt_bull_cooldown := 10
        color  lbl_col = is_equity_mode ? smt_bear_col : smt_bull_col
        string lbl_txt = is_equity_mode ? "▼" : "▲"
        label.delete(_smt_bull_lbl)
        _smt_bull_lbl := label.new(bar_index, low  - (current_atr * 0.4), lbl_txt, style=label.style_none, textcolor=lbl_col, size=size.small)
    if barstate.isconfirmed
        if smt_bear_cooldown > 0
            smt_bear_cooldown -= 1
        if smt_bull_cooldown > 0
            smt_bull_cooldown -= 1
    if barstate.isconfirmed
        smt_bull_recent  := math.max(0, smt_bull_recent - 1)
        smt_bear_recent  := math.max(0, smt_bear_recent - 1)
    if smt_bull_pdl
        smt_bull_recent := math.min(5, smt_bull_recent + 2)
    if smt_bear_pdh
        smt_bear_recent := math.min(5, smt_bear_recent + 2)

// ── SMT Magnitude Z-Score Engine — Feature B (patched) ──
// Quantitative fix: spread must be continuous on EVERY bar for ta.stdev() to work correctly.
// Sparse na-based series causes ta.stdev() to return na or erratic values (mostly empty window).
// Solution: compute bull and bear spreads continuously as a correlation baseline,
// then sample the Z-score only when the SMT signal actually fires.
// This gives ta.stdev() a dense 20-bar series to work with — statistically valid output.
// Pivot references — same lookback as SMT engine uses
float _nifty_swing_low  = ta.lowest(low,     smt_lookback)
float _nifty_swing_high = ta.highest(high,   smt_lookback)
float _bnf_swing_low    = ta.lowest(c_low,   smt_lookback)
float _bnf_swing_high   = ta.highest(c_high, smt_lookback)
// Continuous baseline distances — computed every bar regardless of SMT state
// CRITICAL-2 FIX: Use pure_atr (undampened) instead of current_atr to preserve statistical geometry.
// At 13:30 on expiry, current_atr drops 40%, causing distance denominators to shrink and
// distances to spike 66% in a single tick. This creates false Z-score blowouts in the 20-bar
// rolling stdev. Pure ATR remains continuous, preventing the artificial discontinuity.
float _bull_nifty_dist  = math.abs(low    - _nifty_swing_low)  / math.max(pure_atr, 1)
float _bull_bnf_dist    = math.abs(c_low  - _bnf_swing_low)    / math.max(nz(c_atr_rs, pure_atr), 1)
float _bear_nifty_dist  = math.abs(high   - _nifty_swing_high) / math.max(pure_atr, 1)
float _bear_bnf_dist    = math.abs(c_high - _bnf_swing_high)   / math.max(nz(c_atr_rs, pure_atr), 1)
// Continuous spreads — dense series, no na gaps, valid stdev input
float cont_bull_spread  = _bull_nifty_dist - _bull_bnf_dist
float cont_bear_spread  = _bear_bnf_dist   - _bear_nifty_dist
// Rolling stdev over dense 20-bar window — statistically valid baseline
float bull_stdev        = ta.stdev(cont_bull_spread, 20)
float bear_stdev        = ta.stdev(cont_bear_spread, 20)
// Z-score sampled on RAW structural divergence — not the engine-remapped bools.
// In equity mode smt_bull_pdl = _raw_div_pdh (high divergence), but cont_bull_spread
// measures LOW distances. Sampling on smt_bull_pdl in equity mode would compute
// bull spread on a high-divergence bar — geometric mismatch, wrong Z-score.
// Using _raw_div_pdl / _raw_div_pdh guarantees the correct spread is always sampled
// against the correct physical side of the candle structure.
// Fix C3: Gate z-score latch inside barstate.isconfirmed — prevents intrabar correlation
// values from skewing the deviation threshold. Continuous spreads (cont_bull/bear_spread)
// still compute every tick (required for ta.stdev window density), but the z-score
// capture only happens when the candle has fully resolved its structure.
var float smt_zscore    = 0.0
if barstate.isconfirmed
    if _raw_div_pdl and bull_stdev > 0
        smt_zscore := cont_bull_spread / bull_stdev
    if _raw_div_pdh and bear_stdev > 0
        smt_zscore := cont_bear_spread / bear_stdev

// Single-use bypass guard — prevents multiple cooling_pause bypasses in one session
if is_new_day
    smt_zscore      := 0.0

// ── Sequenced Trap: "Fuel + Spark" System ──
// Fuel = institutional divergence signal (SMT or CVD) within 5-bar memory window
// Spark = liquidity sweep (any TF) landing inside that window
// m5 FIX: Use nz(ta.barssince(...), 999) idiom instead of int variable + not na() guard.
// Eliminates 6 named int series allocations. nz returns 999 (>> 5) when barssince = na
// (signal has never fired), so the <= 5 comparison cleanly returns false. Same logic,
// fewer series, more readable.
// FIX: Extract ta.barssince calls to global scope (executed unconditionally every bar)
// to avoid Pine compiler warning about historical function dependency.
int _bs_smt_bull = ta.barssince(smt_bull_pdl)
int _bs_cvd_bull = ta.barssince(cvd_bull_div)
int _bs_smt_bear = ta.barssince(smt_bear_pdh)
int _bs_cvd_bear = ta.barssince(cvd_bear_div)
int _bs_bot_sweep = ta.barssince(bot_sweep or h15_bot_sweep or h30_bot_sweep)
int _bs_top_sweep = ta.barssince(top_sweep or h15_top_sweep or h30_top_sweep)

bool fuel_bullish = nz(_bs_smt_bull, 999) <= 5 or nz(_bs_cvd_bull, 999) <= 5
bool fuel_bearish = nz(_bs_smt_bear, 999) <= 5 or nz(_bs_cvd_bear, 999) <= 5

// Track barssince any sweep fired — enables reverse sequence detection (sweep-first, fuel after)
bool fuel_bullish_rev = nz(_bs_bot_sweep, 999) <= 5 and smt_bull_pdl
bool fuel_bearish_rev = nz(_bs_top_sweep, 999) <= 5 and smt_bear_pdh

// Backward-compat aliases used in SMT HUD status row
bool act_bull_smt = nz(_bs_smt_bull, 999) <= 5
bool act_bear_smt = nz(_bs_smt_bear, 999) <= 5

// bot_trap: sweep lands inside bullish fuel window → long setup (standard: fuel-first)
//           OR: SMT fires after sweep within 5 bars (reverse: sweep-first)
bool bot_trap = ((bot_sweep or h15_bot_sweep or h30_bot_sweep) and fuel_bullish) or fuel_bullish_rev
// top_trap: sweep lands inside bearish fuel window → short setup (standard: fuel-first)
//           OR: SMT fires after sweep within 5 bars (reverse: sweep-first)
bool top_trap = ((top_sweep or h15_top_sweep or h30_top_sweep) and fuel_bearish) or fuel_bearish_rev

// ── M4 FIX: Sweep Price Memory — anchors reverse-sequence SL to the actual sweep bar ──
// Problem: When fuel_bullish_rev fires (SMT confirmed AFTER the sweep, not before), the
// Priority 1 entry used `low` of the CURRENT (SMT confirmation) bar as the SL anchor.
// That bar's low has no structural significance — it's the low of a confirmation candle,
// not the low of the sweep that defines the structural invalidation level.
// Fix: Latch the extreme price of every sweep event as it fires. When a reverse-sequence
// trap entry fires, route SL to the latched sweep low/high. For standard fuel-first traps,
// current bar low/high is still the correct anchor (sweep is on the same bar as entry signal).
// Reset to na daily so stale prior-day sweep lows don't anchor intraday positions.
var float last_bot_sweep_low  = na
var float last_top_sweep_high = na
if is_new_day
    last_bot_sweep_low  := na
    last_top_sweep_high := na
if bot_sweep and barstate.isconfirmed and or_set
    last_bot_sweep_low := low
else if h15_bot_sweep and barstate.isconfirmed and or_set
    last_bot_sweep_low := h15_low
else if h30_bot_sweep and barstate.isconfirmed and or_set
    last_bot_sweep_low := h30_low

if top_sweep and barstate.isconfirmed and or_set
    last_top_sweep_high := high
else if h15_top_sweep and barstate.isconfirmed and or_set
    last_top_sweep_high := h15_high
else if h30_top_sweep and barstate.isconfirmed and or_set
    last_top_sweep_high := h30_high

// ── Dead Zone ──
bool dead_zone = in_market and ist_t >= DEAD_ZONE_START and ist_t < PM_START

 
// ── Global Micro-Fractal Swing Arrays ──
// MUST be computed unconditionally in global scope on every bar.
// Pine Script series functions (ta.lowest/ta.highest) require continuous execution history.
// Placing them inside conditional blocks (if is_long and t10_hit_up) causes historical
// distortion — the lookback window only covers bars where the condition was true,
// not the actual last 3 candles on the chart. This produces wildly inaccurate trail stops.
// [1] offset: excludes the live unconfirmed candle — only closed bars used for structure.
float rolling_low_3  = ta.lowest(low[1],  3)
float rolling_high_3 = ta.highest(high[1], 3)

// Trade Engine Gates Removed

float global_prem_adr_5 = adr_5
// C3 FIX: Use index open as anchor in options/ext-gap modes — day_open is the premium open
// (e.g. ₹180) which produces premium-scale ADR bands rather than index-scale TP clamps
float _prem_anchor       = _use_ext_gap ? nz(_gap_u_open, day_open) : day_open
float global_prem_adr_upper = _prem_anchor + (global_prem_adr_5 * 0.5)
float global_prem_adr_lower = _prem_anchor - (global_prem_adr_5 * 0.5)

// Trade Management Removed

// ── Target Hit Memory ──
if bull_targets_active and not na(ext_h05) and high >= ext_h05
    t05_hit_up := true
if bear_targets_active and not na(ext_l05) and low  <= ext_l05
    t05_hit_dn := true

// VIX Ceiling/Floor: computed from index anchor in all modes, na in options mode
// vix_anchor_price correctly uses _gap_u_open (index open) in options, day_open otherwise
// Double protection: na in options mode at computation level + not _use_ext_gap on plot vars
float vix_ceiling = not _use_ext_gap and not na(vix_anchor_price) ? vix_anchor_price + implied_pts : na
float vix_floor   = not _use_ext_gap and not na(vix_anchor_price) ? vix_anchor_price - implied_pts : na

// ── POC + VIX Ceiling/Floor Convergence (Phase 3-J) ──
float _vix_conv_thresh = implied_pts > 0 ? implied_pts * 0.20 : current_atr * 1.5

bool poc_near_vix_ceil = svp_track_dev and not na(svp_today_poc) and
     not na(vix_ceiling) and use_vix and
     math.abs(svp_today_poc - vix_ceiling) <= _vix_conv_thresh and
     barstate.isconfirmed

bool poc_near_vix_floor = svp_track_dev and not na(svp_today_poc) and
     not na(vix_floor) and use_vix and
     math.abs(svp_today_poc - vix_floor) <= _vix_conv_thresh and
     barstate.isconfirmed

var bool _poc_vix_alerted = false
if is_new_day
    _poc_vix_alerted := false
bool _poc_vix_conv_edge = (poc_near_vix_ceil or poc_near_vix_floor) and not _poc_vix_alerted
if _poc_vix_conv_edge
    _poc_vix_alerted := true


// ── Weekly Expected Move Bands ──
// Formula: daily implied move × √5 = full-week options expiry expected range
// √5 because NSE has 5 trading sessions per week; this is standard options math.
// These are the absolute boundary levels where gamma sellers defend most aggressively.
// Most powerful signal: Thursday/Friday price touching weekly band = highest-conviction reversal.
// Suppressed on options charts (_use_ext_gap = true) — premium scale vs index scale mismatch.
// Suppressed when show_weekly_vix is OFF or use_vix is OFF.
float _weekly_implied_pts = implied_pts * math.sqrt(5)
bool _show_weekly_bands = show_weekly_vix and use_vix and not _use_ext_gap and not _is_options_chart and op_mode != "Stocks"
float weekly_vix_ceil = _show_weekly_bands and not na(vix_anchor_price) ? vix_anchor_price + _weekly_implied_pts : na
float weekly_vix_floor = _show_weekly_bands and not na(vix_anchor_price) ? vix_anchor_price - _weekly_implied_pts : na

// ── Nested Compression Detection ──
f_nested(a_high, a_low, a_open, a_close, b_high, b_low, b_open, b_close, strict) =>
    float a_top  = strict ? a_high : math.max(a_open, a_close)
    float a_bot  = strict ? a_low  : math.min(a_open, a_close)
    float b_top  = strict ? b_high : math.max(b_open, b_close)
    float b_bot  = strict ? b_low  : math.min(b_open, b_close)
    float a_body = math.abs(a_close - a_open)
    float b_body = math.abs(b_close - b_open)
    b_top < a_top and b_bot > a_bot and b_body < a_body

f_get_nc_state(_h2, _l2, _o2, _c2, _h1, _l1, _o1, _c1, _h0, _l0, _o0, _c0, _is_close, _strict, _show_nc, _show_nctf, _show_ib) =>
    bool _c1c2 = _is_close and f_nested(_h2, _l2, _o2, _c2, _h1, _l1, _o1, _c1, _strict)
    bool _c2c3 = _is_close and f_nested(_h1, _l1, _o1, _c1, _h0, _l0, _o0, _c0, _strict)
    bool _bear = _show_nc and _show_nctf and _is_close and barstate.isconfirmed and _c1c2 and _c2c3 and (_c2 < _o2) and (_c1 < _o1) and (_c0 < _o0)
    bool _bull = _show_nc and _show_nctf and _is_close and barstate.isconfirmed and _c1c2 and _c2c3 and (_c2 > _o2) and (_c1 > _o1) and (_c0 > _o0)
    bool _ibc_c1c2 = _h1 < _h2 and _l1 > _l2
    bool _ibc_c2c3 = _h0 < _h1 and _l0 > _l1
    bool _ibc_shrink = math.abs(_c0 - _o0) < math.abs(_c1 - _o1) and math.abs(_c1 - _o1) < math.abs(_c2 - _o2)
    bool _ibc = _show_nc and _show_ib and _is_close and barstate.isconfirmed and _ibc_c1c2 and _ibc_c2c3 and _ibc_shrink and not _bear and not _bull
    [_bear, _bull, _ibc]

[nc15_bearish, nc15_bullish, ibc15] = f_get_nc_state(_h15_h2, _h15_l2, _h15_o2, _h15_c2, _h15_h1, _h15_l1, _h15_o1, _h15_c1, h15_high, h15_low, h15_open, h15_close, is_15m_close, nc_strict, show_nc, show_nc_15, show_ib_15)

[nc30_bearish, nc30_bullish, ibc30] = f_get_nc_state(_h30_h2, _h30_l2, _h30_o2, _h30_c2, _h30_h1, _h30_l1, _h30_o1, _h30_c1, h30_high, h30_low, h30_open, h30_close, is_30m_close, nc_strict, show_nc, show_nc_30, show_ib_30)

// ── Directional Launchpad Filters ──
// Launchpad down = "DO NOT BUY" → all longs blocked
// Launchpad up   = "DO NOT SHORT" → all shorts blocked
bool bull_allowed = not is_launchpad_dn
bool bear_allowed = not is_launchpad_up

// Dynamic TP Removed

// ── Step B: Setup Detection ──
// Gate hierarchy (outer to inner):
//   kill_switch → engine_dz → cooling_pause → Phase 4 block → bull/bear_allowed → setup logic
// P3: Phase 4 (≥14:15) is management-only — no new entries, insufficient time for targets
// phase4_block: NSE F&O 14:15 execution cutoff — expiry/squareoff pressure on index F&O
// Not applicable to Stocks mode — individual equities trade cleanly until 15:15
// is_equity_mode = false for all index/options modes where phase4 is structurally critical
bool phase4_block = (ist_t >= PHASE4_START or f_expfsm_is_finalhour) and not is_equity_mode

// Re-entry cooldown decays inside barstate.isconfirmed block below (with SMT counters)

// ── EMA 21 Calculation & Slope Logic ──
float ema21 = ta.ema(close, 21)

// VIX-adaptive dead band — breathes with volatility regime
float ema_dead_mult = vix_val > 18 ? 0.20 : vix_val < 13 ? 0.10 : 0.15
float ema_dead_band = current_atr * ema_dead_mult
bool  ema_dead      = math.abs(close - ema21) < ema_dead_band

// Slope magnitude gate — prevents micro-slopes from voting
float ema_slope     = ema21 - ema21[3]
float ema_slope_min = current_atr * 0.05
bool  ema_flat      = math.abs(ema_slope) < ema_slope_min

// EMA vote: price side AND slope direction must agree
int ema_vote = (ema_dead or ema_flat)                               ? 0
             : (close > ema21 and ema_slope >  ema_slope_min)       ? 1
             : (close < ema21 and ema_slope < -ema_slope_min)       ? -1
             : 0

float h4_ema_dead   = current_atr * 0.15
int   h4_ema_vote   = math.abs(close - h4_ema21) < h4_ema_dead ? 0 : close > h4_ema21 ? 1 : -1

// ── Swing Structure Vote — ghost-proof, resets daily ──
var int   swing_vote = 0
var float last_ph    = na
var float last_pl    = na

if is_new_day
    swing_vote := 0
    last_ph    := na
    last_pl    := na

if or_set and na(last_ph) and barstate.isconfirmed
    last_ph := or_h
if or_set and na(last_pl) and barstate.isconfirmed
    last_pl := or_l

// Use shorter right lookback during the first hour, standard after
int _piv_right = ist_t <= 1000 ? 2 : 5   // 6-min vs 15-min lag on 3m chart
float piv_h = ta.pivothigh(high, 5, _piv_right)
float piv_l = ta.pivotlow(low,  5, _piv_right)

int _ph_vote = swing_vote
int _pl_vote = swing_vote
if barstate.isconfirmed
    if not na(piv_h) and or_set and bars_since_open > 5
        _ph_vote := piv_h > last_ph ? 1 : -1
        last_ph  := piv_h
    if not na(piv_l) and or_set and bars_since_open > 5
        _pl_vote := piv_l > last_pl ? 1 : -1
        last_pl  := piv_l

    if not na(piv_h) and not na(piv_l) and or_set and bars_since_open > 5
        swing_vote := math.round((_ph_vote + _pl_vote) / 2.0)
    else if not na(piv_h) and or_set and bars_since_open > 5
        swing_vote := _ph_vote
    else if not na(piv_l) and or_set and bars_since_open > 5
        swing_vote := _pl_vote

// ── Macro SMT Detection ──
bool _nifty_new_dh   = pd_high > pd_high2
bool _bnf_new_dh     = c_pdh   > c_pdh2
bool _nifty_new_dl   = pd_low  < pd_low2
bool _bnf_new_dl     = c_pdl   < c_pdl2

bool macro_smt_bear  = _nifty_new_dh and not _bnf_new_dh
bool macro_smt_bull  = _nifty_new_dl and not _bnf_new_dl
string macro_smt_txt = macro_smt_bear ? "▼ SMT Distribution — Short Rallies" : macro_smt_bull ? "▲ SMT Accumulation — Buy Dips" : "Correlated — No SMT Bias"
color  macro_smt_col = macro_smt_bear ? #ff4466 : macro_smt_bull ? #00ff88 : color.silver

// INJECTION: Macro SMT acts as a tie-breaker (±1) ONLY after intraday OR is set
int macro_vote = (or_set and macro_smt_bear) ? -1 : (or_set and macro_smt_bull) ? 1 : 0

// ── Trend Alignment Gate (v26.2) ──
// N3 FIX: Integrated macro_vote into the majority-vote score (>= 2 of 4 signals)
int _trend_long_score  = (ema_vote > 0 ? 1 : 0) + (swing_vote > 0 ? 1 : 0) + (_use_ext_gap ? (_u_close > vwap_val ? 1 : 0) : (close > vwap_val ? 1 : 0)) + (macro_vote > 0 ? 1 : 0) + (h4_ema_vote > 0 ? 1 : 0)
int _trend_short_score = (ema_vote < 0 ? 1 : 0) + (swing_vote < 0 ? 1 : 0) + (_use_ext_gap ? (_u_close < vwap_val ? 1 : 0) : (close < vwap_val ? 1 : 0)) + (macro_vote < 0 ? 1 : 0) + (h4_ema_vote < 0 ? 1 : 0)
bool trend_allows_long  = or_break_dir != -1 or _trend_long_score  >= 3
bool trend_allows_short = or_break_dir != 1  or _trend_short_score >= 3


// Smart Eject Removed

// ── SMT Stack Support Variables ──
float smt_prox        = current_atr * 0.75
bool near_bull_level = (or_set and math.abs(close - or_l) <= smt_prox) or
     (not _use_ext_gap and not na(adr_lower) and math.abs(close - adr_lower) <= smt_prox) or
     (not na(vix_floor)  and math.abs(close - vix_floor)  <= smt_prox) or
     (not na(pd_low)     and math.abs(close - pd_low)     <= smt_prox) or
     (not na(prev_vwap)  and math.abs(close - prev_vwap)  <= smt_prox) or
     (not na(weekly_vix_floor) and math.abs(close - weekly_vix_floor) <= smt_prox)

bool near_bear_level = (or_set and math.abs(close - or_h) <= smt_prox) or
     (not _use_ext_gap and not na(adr_upper) and math.abs(close - adr_upper) <= smt_prox) or
     (not na(vix_ceiling) and math.abs(close - vix_ceiling) <= smt_prox) or
     (not na(pd_high)    and math.abs(close - pd_high)    <= smt_prox) or
     (not na(prev_vwap)  and math.abs(close - prev_vwap)  <= smt_prox) or
     (not na(weekly_vix_ceil) and math.abs(close - weekly_vix_ceil) <= smt_prox)
// MAJOR FIX v25.4: Block index-scale levels from polluting premium-scale SL anchor math
// Problem: In Options mode, adr_lower/vix_floor retain index values (~22,000) for HUD display
//          math.max(22000, or_l=150) always picks 22000 → math.min(low=150, 22000) picks low
//          Result: SMT Stack SL silently anchors to wick only, structural anchor bypassed
// Solution: Gate index levels with not _use_ext_gap so options mode uses only premium-scale values
float _valid_adr_l = not _use_ext_gap ? adr_lower   : na
float _valid_vix_l = not _use_ext_gap ? vix_floor   : na
float _valid_adr_u = not _use_ext_gap ? adr_upper   : na
float _valid_vix_u = not _use_ext_gap ? vix_ceiling : na
float smt_bull_sl_anchor = or_set ? math.max(nz(_valid_adr_l, nz(or_l, day_open)), math.max(nz(_valid_vix_l, nz(or_l, day_open)), or_l)) : nz(_valid_adr_l, close - current_atr * 2.0)
float smt_bear_sl_anchor = or_set ? math.min(nz(_valid_adr_u, nz(or_h, day_open)), math.min(nz(_valid_vix_u, nz(or_h, day_open)), or_h)) : nz(_valid_adr_u, close + current_atr * 2.0)
float smt_wick_close_thresh = vix_val > 18 ? 0.6 : 0.5
bool bull_wick_rejection = valid_bot_wick and (bar_rng > 0) and (close > low + bar_rng * smt_wick_close_thresh)
bool bear_wick_rejection = valid_top_wick and (bar_rng > 0) and (close < low + bar_rng * (1.0 - smt_wick_close_thresh))
bool smt_bull_spark   = (close > open or bull_wick_rejection) and barstate.isconfirmed
bool smt_bear_spark   = (close < open or bear_wick_rejection) and barstate.isconfirmed

// ── Step B: Setup Detection ──
// Single unified execution block — no shadow duplicate.
// Fix C4: barstate.isconfirmed added to outer gate — ensures trade_entry := close captures
// the confirmed candle close, not an intrabar tick. Without this, the engine could enter
// at a mid-candle price on a fast Nifty bar (e.g. 9:15–9:20 volatility spike), corrupting
// ── Doji Radar Data ──
// REVERTED: [1] offsets restored. Without them, h1_rng/h1_body_ratio/h1_up_pct/h1_dn_pct
// flickered intrabar between hour closes (h1_high reflected the live forming 1H bar).
// With [1], request.security returns the just-completed prior 1H bar — stable and 
// correctly aligned with the new_hour Doji Radar gate at line 4141.
[h1_high, h1_low, h1_open, h1_close, h1_h3, h1_l3] = request.security(syminfo.tickerid, "60", [high[1], low[1], open[1], close[1], high[3], low[3]], lookahead=barmerge.lookahead_on)

float h1_rng        = h1_high - h1_low
float h1_body_ratio = h1_rng > 0 ? math.abs(h1_close - h1_open) / h1_rng : 1.0
float h1_up_pct     = h1_rng > 0 ? (h1_high - math.max(h1_open, h1_close)) / h1_rng : 0.0
float h1_dn_pct     = h1_rng > 0 ? (math.min(h1_open, h1_close) - h1_low)  / h1_rng : 0.0

// ── FVG Engine ──
var box[] active_bull_fvgs = array.new_box()
var box[] active_bear_fvgs = array.new_box()

f_process_fvgs() =>
    bool bull_fvg = show_fvg and (low > high[2]) and (close[1] > open[1])
    bool bear_fvg = show_fvg and (high < low[2]) and (close[1] < open[1])

    if bull_fvg and barstate.isconfirmed and is_today
        array.push(active_bull_fvgs, box.new(left=bar_index[2], top=low, right=bar_index + fvg_extend, bottom=high[2], border_color=color.new(#00bb66, 60), bgcolor=color.new(#00bb66, 80)))
        if array.size(active_bull_fvgs) > d_fvg_cap
            box.delete(array.shift(active_bull_fvgs))
    if bear_fvg and barstate.isconfirmed and is_today
        array.push(active_bear_fvgs, box.new(left=bar_index[2], top=low[2], right=bar_index + fvg_extend, bottom=high, border_color=color.new(#ff2244, 60), bgcolor=color.new(#ff2244, 80)))
        if array.size(active_bear_fvgs) > d_fvg_cap
            box.delete(array.shift(active_bear_fvgs))

    if array.size(active_bull_fvgs) > 0
        for i = array.size(active_bull_fvgs) - 1 to 0
            b = array.get(active_bull_fvgs, i)
            if bar_index > box.get_left(b) + 2 and low <= box.get_top(b)
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(#00bb66, 95))
                box.set_border_color(b, color.new(#00bb66, 95))
                array.remove(active_bull_fvgs, i)

    if array.size(active_bear_fvgs) > 0
        for i = array.size(active_bear_fvgs) - 1 to 0
            b = array.get(active_bear_fvgs, i)
            if bar_index > box.get_left(b) + 2 and high >= box.get_bottom(b)
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(#ff2244, 95))
                box.set_border_color(b, color.new(#ff2244, 95))
                array.remove(active_bear_fvgs, i)

f_process_fvgs()

// ── 1H FVG Logic ──
var float active_fvg_top = na
var float active_fvg_bot = na
var string active_fvg_dir = "None"

bool _show_h1_fvgs = show_h1_fvg and not _use_ext_gap and not _is_options_chart
if true
    bool is_1h_fvg_bull = _show_h1_fvgs and (h1_low > h1_h3)
    bool is_1h_fvg_bear = _show_h1_fvgs and (h1_high < h1_l3)

    bool is_1h_close = (minute(time_close) % 60) == 15 and bars_since_open > 12
    if is_1h_close and barstate.isconfirmed
        if is_1h_fvg_bull and (h1_low - h1_h3) >= current_atr * 0.5
            if active_fvg_dir != "BULL FVG" or na(active_fvg_bot)
                active_fvg_top := h1_low
                active_fvg_bot := h1_h3
                active_fvg_dir := "BULL FVG"
        else if is_1h_fvg_bear and (h1_l3 - h1_high) >= current_atr * 0.5
            if active_fvg_dir != "BEAR FVG" or na(active_fvg_top)
                active_fvg_top := h1_l3
                active_fvg_bot := h1_high
                active_fvg_dir := "BEAR FVG"

    if active_fvg_dir == "BULL FVG" and barstate.isconfirmed and close < active_fvg_bot
        active_fvg_top := na
        active_fvg_bot := na
        active_fvg_dir := "None"
    if active_fvg_dir == "BEAR FVG" and barstate.isconfirmed and close > active_fvg_top
        active_fvg_top := na
        active_fvg_bot := na
        active_fvg_dir := "None"



// ── P1: Confluence Zone — Proximity Check ──
// Returns true if _reference is within _threshold points of _level.
// Used by f_scan_confluence to test every structural level against OR H/L/Mid.
f_in_zone(_level, _reference, _threshold) => not na(_reference) and not na(_level) and math.abs(_level - _reference) <= _threshold

// ── P1: Confluence Scanner ──
// Scans all structural levels for proximity to a given OR level.
// Returns [weight, level_string] where:
//   weight >= 4 = CLUSTER, weight 2-3 = ZONE, weight 0-1 = NAKED
//   level_string = comma-separated names of matching levels (for HUD)
// Called ONCE at or_set — results are cached, not recomputed every bar.
// LVN at the level = weight -1 (price moves through fast — not a support)
f_scan_confluence(_or_level, _atr, _svp_ok) =>
    // MAJOR FIX: Clamp threshold to prevent double-counting on compressed ORs
    float _thresh = math.min(_atr * 0.25, math.max(syminfo.mintick, or_rng * 0.4))
    int   _w      = 0
    string _lvls  = ""

    // SVP levels — weight 2 each (highest institutional significance)
    if _svp_ok
        if f_in_zone(_or_level, svp_yday_poc, _thresh)
            _w    += 2
            _lvls += "POC "
        if f_in_zone(_or_level, svp_yday_vah, _thresh)
            _w    += 2
            _lvls += "VAH "
        if f_in_zone(_or_level, svp_yday_val, _thresh)
            _w    += 2
            _lvls += "VAL "
        if f_in_zone(_or_level, svp_today_poc, _thresh) and bars_since_open >= 12
            _w    += 2
            _lvls += "dPOC "

    // HVN/LVN — weight ±1 (volume node quality at this exact level)
    int _node = f_svp_node_type(_or_level, yesterdaySVP, _atr)
    if _node == 1
        _w    += 1
        _lvls += "HVN "
    else if _node == -1
        _w    -= 1
        _lvls += "LVN "

    // PD levels — weight 1 each
    if f_in_zone(_or_level, pd_high, _thresh)
        _w    += 1
        _lvls += "PDH "
    if f_in_zone(_or_level, pd_low, _thresh)
        _w    += 1
        _lvls += "PDL "
    if f_in_zone(_or_level, pd_close, _thresh)
        _w    += 1
        _lvls += "PDC "
    if f_in_zone(_or_level, prev_vwap, _thresh)
        _w    += 1
        _lvls += "pVWAP "
    if not _svp_ok and f_in_zone(_or_level, prev_poc, _thresh)
        _w    += 1
        _lvls += "nPOC "
    if f_in_zone(_or_level, vix_ceiling, _thresh)
        _w    += 1
        _lvls += "VIXc "
    if f_in_zone(_or_level, vix_floor, _thresh)
        _w    += 1
        _lvls += "VIXf "
    if f_in_zone(_or_level, adr_upper, _thresh)
        _w    += 1
        _lvls += "ADRh "
    if f_in_zone(_or_level, adr_lower, _thresh)
        _w    += 1
        _lvls += "ADRl "
    // 1H FVG edge confluence — active FVG near OR level
    if active_fvg_dir != "None"
        if f_in_zone(_or_level, active_fvg_top, _thresh) or f_in_zone(_or_level, active_fvg_bot, _thresh)
            _w    += 1
            _lvls += "FVG "

    // Trim trailing space
    if str.length(_lvls) > 0
        _lvls := str.substring(_lvls, 0, str.length(_lvls) - 1)

    [_w, _lvls]

// ── P1: Zone State from Weight ──
f_zone_state(_w) => _w >= 4 ? "CLUSTER" : _w >= 2 ? "ZONE" : "NAKED"

// ── P1: Compute confluence once when OR sets ──
// _p1_computed latch: scanner runs exactly once per session — on the first confirmed
// bar after or_set flips true. Works correctly even when all weights are 0 (NAKED levels).
// is_new_day resets _p1_computed to false, re-arming each session.
if or_set and not _p1_computed and barstate.isconfirmed
    _p1_computed := true
    [_hw, _hl] = f_scan_confluence(or_h,   current_atr, svp_ready)
    [_lw, _ll] = f_scan_confluence(or_l,   current_atr, svp_ready)
    [_mw, _ml] = f_scan_confluence(or_mid, current_atr, svp_ready)
    or_h_conf_weight := _hw
    or_l_conf_weight := _lw
    or_m_conf_weight := _mw
    or_h_conf_levels := _hl
    or_l_conf_levels := _ll
    or_m_conf_levels := _ml

string or_h_zone = f_zone_state(or_h_conf_weight)
string or_l_zone = f_zone_state(or_l_conf_weight)
string or_m_zone = f_zone_state(or_m_conf_weight)

// ── P2: OR Level Bounce / Rejection Score ──
// Fires on barstate.isconfirmed when price is within 0.25 ATR of OR H, Mid, or L.
// Scores the probability the level holds (bounce) or breaks (rejection).
// Score range: 0–9 for OR-H/L, 0–7 for OR-Mid (softer level).

// P2 proximity: smaller of 0.25 ATR or 35% of OR range
// On compressed OR days, or_rng is small — 0.25 ATR would overlap adjacent levels
// Using min() prevents the OR-Mid bubble from bleeding into OR-H or OR-L territory
float _p2_prox = or_set and not na(or_rng) and or_rng > 0 ? math.min(current_atr * 0.25, or_rng * 0.35) : current_atr * 0.25
bool p2_at_or_h = or_set and not na(or_h)   and math.abs(close - or_h)   <= _p2_prox
bool p2_at_or_l = or_set and not na(or_l)   and math.abs(close - or_l)   <= _p2_prox
bool p2_at_or_m = or_set and not na(or_mid) and math.abs(close - or_mid) <= _p2_prox

// Approach direction determines expected move: bounce (hold) vs rejection (break)
bool p2_or_h_bounce = p2_at_or_h and close[1] >= or_h  // from above → support test
bool p2_or_h_reject = p2_at_or_h and close[1] <  or_h  // from below → resistance test
bool p2_or_l_bounce = p2_at_or_l and close[1] >= or_l  // from above → support test
bool p2_or_l_reject = p2_at_or_l and close[1] <  or_l  // from below → resistance test
bool p2_or_m_bounce = p2_at_or_m and close[1] >= or_mid // support test
bool p2_or_m_reject = p2_at_or_m and close[1] <  or_mid // resistance test

// ── Update test counts on confirmed touch — moved to fire blocks below ──

// ── Base Rate ──
// Starting score before adjustments. Reflects session type and test history.
f_p2_base(_test_count, _session_char, _is_bounce) =>
    // Decay: 1st=4, 2nd=3, 3rd+=2 (less punitive than original v27.0 to allow late-session conviction)
    int _base = _test_count == 1 ? 4 : _test_count == 2 ? 3 : _test_count >= 3 ? 2 : 3

    // Session character: directional bias of the session
    // Wide Bull session supports bounces (above) and rejections (below)
    // Wide Bear session supports rejections (above) and bounces (below)
    // For bounce_bull (price held by support): Wide Bull supports it → +1
    // For reject_bear (price rejected by resistance): Wide Bear supports it → +1
    // Doji: weakens any directional level (both bounces and rejections suspect)
    int _char_mod = (_session_char == "Wide Bull" or _session_char == "Wide Bear") ?  1 : (_session_char == "Doji") ? -1 : 0

    // Helper: does the breadth state SUPPORT the expected outcome?
    // For bounce: Bull breadth supports (level holds because buyers are strong)
    // For reject: Bear breadth supports (level holds because sellers are strong)
    int _breadth_mod = (_is_bounce  and p10_state == "Bull") or (not _is_bounce and p10_state == "Bear") ?  1 : (_is_bounce  and p10_state == "Bear") or (not _is_bounce and p10_state == "Bull") ? -1 : 0

    // Velocity: same direction logic as breadth
    int _velocity_mod = (_is_bounce  and p10_velocity_state == "Strong In") or (not _is_bounce and p10_velocity_state == "Strong Out") ?  1 : (_is_bounce  and p10_velocity_state == "Strong Out") or (not _is_bounce and p10_velocity_state == "Strong In") ? -1 : 0

    // Divergence: BEAR DIV says price is rallying without breadth → resistance more likely to break
    // BEAR DIV at OR-H reject → reject MORE likely (price weak structurally, reverses) → +2
    // Wait — bear divergence means price is up but breadth is fading
    //   At OR-H reject: bear div SUPPORTS the rejection (price will reverse) → +2
    //   At OR-L bounce: bear div OPPOSES the bounce (price still has downside) → -2
    int _div_mod = (_is_bounce  and p10_div_bull) or (not _is_bounce and p10_div_bear) ?  2 : (_is_bounce  and p10_div_bear) or (not _is_bounce and p10_div_bull) ? -2 : 0

    // HTF alignment: Reversal states are direction-specific reversal signals
    // Reversal Bull (RSI OS + breadth turning Bull) supports bounces, opposes rejections
    // Reversal Bear (RSI OB + breadth turning Bear) supports rejections, opposes bounces
    // Aligned states support continuation in the trend's direction
    int _htf_mod = (_is_bounce  and p10_htf_align == "Reversal Bull") or (not _is_bounce and p10_htf_align == "Reversal Bear") ?  2 : (_is_bounce  and p10_htf_align == "Reversal Bear") or (not _is_bounce and p10_htf_align == "Reversal Bull") ? -2 : (_is_bounce  and p10_htf_align == "Aligned Bull") or (not _is_bounce and p10_htf_align == "Aligned Bear") ?  1 : (_is_bounce  and p10_htf_align == "Aligned Bear") or (not _is_bounce and p10_htf_align == "Aligned Bull") ? -1 : p10_htf_align == "Counter-Trend" ? -1 : 0

    math.max(0, _base + _char_mod + _breadth_mod + _velocity_mod + _div_mod + _htf_mod)

// ── Factor Scoring ──
// 6 factors each contributing ±1 or +2 (confluence).
// _is_bounce: true = expect level to hold, false = expect break.
f_p2_factors(_is_bounce, _or_level, _conf_weight) =>
    int _s = 0

    // F1: RMI — exhaustion state vs expected direction
    _s += _is_bounce ? (_rmi_val <= 35 ? 1 : _rmi_val >= 65 ? -1 : 0) : (_rmi_val >= 65 ? 1 : _rmi_val <= 35 ? -1 : 0)

    // F2: VWAP side — institutional alignment
    _s += (_is_bounce ? close > vwap_val : close < vwap_val) ? 1 : 0

    // F3: ToD RVOL — volume confirmation at touch
    _s += (h_avg > 0 and tod_rvol >= 150.0) ? 1 : 0

    // F4: Wick quality at the level
    float _rng = math.max(high - low, syminfo.mintick)
    _s += _is_bounce ? ((dn_wick / _rng) >= 0.40 ? 1 : 0) : ((up_wick / _rng) >= 0.40 ? 1 : 0)

    // F5: SVP volume node type at this level
    if svp_ready
        int _node = f_svp_node_type(_or_level, yesterdaySVP, current_atr)
        _s += _node == 1 ? 1 : _node == -1 ? -1 : 0

    // F6: Confluence bonus from P1
    _s += _conf_weight >= 4 ? 2 : _conf_weight >= 2 ? 1 : 0

    // ── P2 7th Factor: POC Alignment (Phase 3-D2 / Addition F) ──
    // F7: Today's developing POC position relative to the OR level being tested
    // For a BOUNCE at OR-L: POC below OR-L = institutional floor below = +1 (supports bounce)
    //                       POC inside OR  = neutral = 0
    //                       POC above OR-H = entire value area is resistance = -1
    // For a REJECTION at OR-H: symmetric (POC above = +1 supports rejection, below = -1)
    if svp_track_dev and not na(svp_today_poc) and bars_since_open >= 12
        _s += _is_bounce ?
             (svp_today_poc < _or_level - _poc_prox ? 1 :
              svp_today_poc > or_h                  ? -1 : 0) :
             (svp_today_poc > _or_level + _poc_prox ? 1 :
              svp_today_poc < or_l                  ? -1 : 0)



    _s

// ── Score Builder ──
f_p2_build(_level_name, _level_price, _is_bounce, _test_count, _conf_weight, _conf_levels, _max_score) =>
    int _base    = f_p2_base(_test_count, p6_session_char, _is_bounce)
    int _factors = f_p2_factors(_is_bounce, _level_price, _conf_weight)
    int _total   = math.min(math.max(_base + _factors, 0), _max_score)

    string _arrow  = _is_bounce ? "↑" : "↓"
    string _action = _is_bounce ? "Bou" : "Rej"
    string _pfx    = _conf_weight >= 4 ? "⚡CLUSTER " : _conf_weight >= 2 ? "ZONE " : ""
    string _cstr   = str.length(_conf_levels) > 0 ? "+" + _conf_levels + " " : " "
    string _lbl    = _level_name + _cstr + _arrow + str.tostring(_total) + "/" + str.tostring(_max_score) + " " + _pfx + _action

    color _col = _is_bounce and _total >= 5 ? #00ff88 : _is_bounce and _total >= 3 ? #00bb66 : _is_bounce ? #008844 : not _is_bounce and _total >= 5 ? #f24b94 : not _is_bounce and _total >= 3 ? #c23c76 : #922d58
    [_total, _lbl, _col]

// ── Fire P2 on confirmed touch bars ──
// _p2_fired prevents OR-H and OR-Mid from both firing on the same bar if they overlap.
// OR-H takes priority over OR-Mid; OR-L takes priority over OR-Mid.
// P2 guard: do not fire if OR is too compressed to distinguish H/Mid/L
bool _p2_or_viable = or_set and not na(or_rng) and or_rng >= current_atr * 0.3

if true
    var bool _p2_fired_this_bar = false
    if barstate.isnew
        _p2_fired_this_bar := false
    if barstate.isconfirmed and is_today and is_micro_execution and or_set and _p2_or_viable
        bool _p2_h_edge = p2_at_or_h and not p2_at_or_h[1]
        bool _p2_l_edge = p2_at_or_l and not p2_at_or_l[1]
        bool _p2_m_edge = p2_at_or_m and not p2_at_or_m[1]
        if _p2_h_edge and not _p2_fired_this_bar
            _p2_fired_this_bar := true
            if p2_or_h_bounce or p2_or_h_reject
                or_h_test_count += 1
                bool _is_b = p2_or_h_bounce
                [_sc, _lb, _co] = f_p2_build("OR-H", or_h, _is_b, or_h_test_count, or_h_conf_weight, or_h_conf_levels, 9)
                p2_last_score := _sc
                p2_last_label := _lb
                p2_last_col   := _co
                if _sc >= 2 and show_p2_labels
                    label.delete(_p2_h_lbl)
                    _p2_h_lbl := label.new(bar_index, _is_b ? low - current_atr * 0.6 : high + current_atr * 0.6, _lb, style = _is_b ? label.style_label_up : label.style_label_down, color = _co, textcolor = color.white, size = size.small)
        if _p2_l_edge and not _p2_fired_this_bar
            _p2_fired_this_bar := true
            if p2_or_l_bounce or p2_or_l_reject
                or_l_test_count += 1
                bool _is_b = p2_or_l_bounce
                [_sc, _lb, _co] = f_p2_build("OR-L", or_l, _is_b, or_l_test_count, or_l_conf_weight, or_l_conf_levels, 9)
                p2_last_score := _sc
                p2_last_label := _lb
                p2_last_col   := _co
                if _sc >= 2 and show_p2_labels
                    label.delete(_p2_l_lbl)
                    _p2_l_lbl := label.new(bar_index, _is_b ? low - current_atr * 0.6 : high + current_atr * 0.6, _lb, style = _is_b ? label.style_label_up : label.style_label_down, color = _co, textcolor = color.white, size = size.small)
        bool _p2_mid_not_at_boundary = not p2_at_or_h and not p2_at_or_l and math.abs(close - or_mid) < math.abs(close - or_h) and math.abs(close - or_mid) < math.abs(close - or_l)
        if _p2_m_edge and not _p2_fired_this_bar and _p2_mid_not_at_boundary
            _p2_fired_this_bar := true
            if p2_or_m_bounce or p2_or_m_reject
                or_m_test_count += 1
                bool _is_b = p2_or_m_bounce
                [_sc, _lb, _co] = f_p2_build("OR-Mid", or_mid, _is_b, or_m_test_count, or_m_conf_weight, or_m_conf_levels, 7)
                p2_last_score := _sc
                p2_last_label := _lb
                p2_last_col   := _co
                if _sc >= 2 and show_p2_labels
                    label.delete(_p2_m_lbl)
                    _p2_m_lbl := label.new(bar_index, _is_b ? low - current_atr * 0.6 : high + current_atr * 0.6, _lb, style = _is_b ? label.style_label_up : label.style_label_down, color = _co, textcolor = color.white, size = size.small)


// ── P3: Conditional Activity Filter ──
// Replaces hard 12:00–13:30 Dead Zone block with real-time chop detection.
// Activates when 3/6 conditions true (normal days) or 4/6 (expiry days).
// Runs all session — can activate early on grinding range days,
// and stays inactive on trend days even inside 12:00–13:30 window.
//
// Phase 4 block (14:15+) is UNCHANGED — that is a regulatory constraint.
// dead_zone bool retained — still drives the bgcolor shading below.

// Update counters every confirmed in-market bar
bool p3_filter_active = false
string p3_reason = ""

if true
    if in_market and barstate.isconfirmed
        bool _p3_in_va = svp_ready and not na(svp_today_vah) and not na(svp_today_val) ? (close >= svp_today_val and close <= svp_today_vah) : (close >= vwap_dn1 and close <= vwap_up1)
        p3_narrow_count := _p3_in_va ? math.min(p3_narrow_count + 1, 15) : 0
        p3_neutral_rmi_count := (_rmi_val >= 40 and _rmi_val <= 60) ? math.min(p3_neutral_rmi_count + 1, 20) : 0
        if swing_vote != p3_last_swing_vote
            p3_no_struct_count  := 0
            p3_last_swing_vote  := swing_vote
        else if swing_vote == 0
            p3_no_struct_count  := math.min(p3_no_struct_count + 1, 25)
        // Edge detection: latch transitions false→true only on the actual cross bar
        bool _p3_poc_edge = (poc_crossed_up and not poc_crossed_up[1]) or (poc_crossed_dn and not poc_crossed_dn[1])
        if _p3_poc_edge and barstate.isconfirmed
            p3_poc_cross_count := math.min(p3_poc_cross_count + 1, 10)
        else if p3_poc_cross_count > 0 and bar_index % 5 == 0
            p3_poc_cross_count -= 1
    bool p3_c1_low_vol       = h_avg > 0 and tod_rvol < 60.0
    bool p3_c2_narrow_range  = p3_narrow_count >= 6
    bool p3_c3_neutral_rmi   = p3_neutral_rmi_count >= 8
    bool p3_c4_no_structure  = p3_no_struct_count >= 10 and swing_vote == 0
    bool p3_c5_balanced_va   = svp_ready and not na(svp_today_vah) and not na(svp_today_val) and bars_since_open >= 12 and (svp_today_vah - svp_today_val) < current_atr * 0.4
    bool p3_c6_poc_chop      = svp_ready and not na(svp_today_poc) and p3_poc_cross_count >= 3
    int p3_condition_count = (p3_c1_low_vol ? 1 : 0) + (p3_c2_narrow_range ? 1 : 0) + (p3_c3_neutral_rmi ? 1 : 0) + (p3_c4_no_structure ? 1 : 0) + (p3_c5_balanced_va ? 1 : 0) + (p3_c6_poc_chop ? 1 : 0)
    int _base_threshold = is_expiry ? 4 : 3
    int p3_threshold    = svp_ready ? _base_threshold : math.max(2, _base_threshold - 1)
    p3_filter_active := in_market and or_set and p3_condition_count >= p3_threshold and not phase4_block
    if p3_filter_active
        if p3_c1_low_vol
            p3_reason += "Low Vol "
        if p3_c2_narrow_range
            p3_reason += "Chop Range "
        if p3_c3_neutral_rmi
            p3_reason += "No Momentum "
        if p3_c4_no_structure
            p3_reason += "No Structure "
        if p3_c5_balanced_va
            p3_reason += "Balanced VA "
        if p3_c6_poc_chop
            p3_reason += "POC Chop "
        p3_reason := str.length(p3_reason) > 0 and str.endswith(p3_reason, " ") ? str.substring(p3_reason, 0, str.length(p3_reason) - 1) : p3_reason

bool poc_cross_up = false
bool poc_cross_dn = false
bool poc_bull_retest = false
bool poc_bear_retest = false
bool poc_bull_retest_failed = false
bool poc_bear_retest_failed = false
bool poc_vol_depleting = false
bool poc_vol_escalating = false
bool poc_breakout_pending = false
bool poc_escape_likely = false
bool poc_crossback_up = false
bool poc_crossback_dn = false
bool _poc_wick_only_bull = false
bool _poc_wick_only_bear = false

if true
    float _pct_above_poc = f_confirm_pct(svp_today_poc, true)
    float _pct_below_poc = f_confirm_pct(svp_today_poc, false)
    bool _poc_recently_below = close[1] < svp_today_poc[1] and close[2] < svp_today_poc[2]
    bool _poc_recently_above = close[1] > svp_today_poc[1] and close[2] > svp_today_poc[2]
    poc_cross_up := svp_track_dev and not na(svp_today_poc) and barstate.isconfirmed and or_set and in_market and is_today and (not p3_filter_active or ist_t >= PM_START) and bars_since_open >= 3 and close > svp_today_poc and _pct_above_poc >= 50.0 and _poc_recently_below
    poc_cross_dn := svp_track_dev and not na(svp_today_poc) and barstate.isconfirmed and or_set and in_market and is_today and (not p3_filter_active or ist_t >= PM_START) and bars_since_open >= 3 and close < svp_today_poc and _pct_below_poc >= 50.0 and _poc_recently_above
    if poc_cross_up and barstate.isconfirmed
        poc_crossed_up     := true
        poc_crossed_dn     := false
        poc_cross_price    := svp_today_poc
        poc_cross_bar      := bar_index
        poc_cross_t_str    := str.tostring(ist_h, "00") + ":" + str.tostring(ist_m, "00")
        poc_retest_up_done := false
    if poc_cross_dn and barstate.isconfirmed
        poc_crossed_dn     := true
        poc_crossed_up     := false
        poc_cross_price    := svp_today_poc
        poc_cross_bar      := bar_index
        poc_cross_t_str    := str.tostring(ist_h, "00") + ":" + str.tostring(ist_m, "00")
        poc_retest_dn_done := false
    if not na(poc_cross_price) and not na(svp_today_poc) and barstate.isconfirmed
        if math.abs(svp_today_poc - poc_cross_price) > _poc_prox * 2.0
            poc_crossed_up  := false
            poc_crossed_dn  := false
            poc_cross_price := na
    bool _poc_touch_from_above = low  <= svp_today_poc + _poc_prox and low  >= svp_today_poc - _poc_prox
    bool _poc_touch_from_below = high >= svp_today_poc - _poc_prox and high <= svp_today_poc + _poc_prox
    bool _poc_bull_touch_event = poc_crossed_up and not poc_cross_up and _poc_touch_from_above and close > svp_today_poc and _pct_above_poc >= 50.0 and barstate.isconfirmed and in_market and is_today and not p3_filter_active
    bool _poc_bull_touch_new   = _poc_bull_touch_event and not _poc_bull_touch_prev
    if _poc_bull_touch_new
        poc_touch_count += 1
        array.set(poc_touch_vols, 2, array.get(poc_touch_vols, 1))
        array.set(poc_touch_vols, 1, array.get(poc_touch_vols, 0))
        array.set(poc_touch_vols, 0, tod_rvol_pct)
    poc_bull_retest := _poc_bull_touch_event and not poc_retest_up_done
    if poc_bull_retest
        poc_retest_up_done := true
    bool _poc_bear_touch_event = poc_crossed_dn and not poc_cross_dn and _poc_touch_from_below and close < svp_today_poc and _pct_below_poc >= 50.0 and barstate.isconfirmed and in_market and is_today and not p3_filter_active
    bool _poc_bear_touch_new   = _poc_bear_touch_event and not _poc_bear_touch_prev
    if _poc_bear_touch_new
        poc_touch_count += 1
        array.set(poc_touch_vols, 5, array.get(poc_touch_vols, 4))
        array.set(poc_touch_vols, 4, array.get(poc_touch_vols, 3))
        array.set(poc_touch_vols, 3, tod_rvol_pct)
    poc_bear_retest := _poc_bear_touch_event and not poc_retest_dn_done
    if poc_bear_retest
        poc_retest_dn_done := true
    poc_bull_retest_failed := poc_crossed_up and not poc_retest_up_done and not poc_cross_up and _poc_touch_from_above and close < svp_today_poc - _poc_prox and _pct_below_poc >= 50.0 and barstate.isconfirmed and in_market and is_today
    if barstate.isconfirmed
        _poc_bull_touch_prev := _poc_bull_touch_event
        _poc_bear_touch_prev := _poc_bear_touch_event
    bool _bull_depleting   = not na(array.get(poc_touch_vols, 2)) and array.get(poc_touch_vols, 0) < array.get(poc_touch_vols, 1) and array.get(poc_touch_vols, 1) < array.get(poc_touch_vols, 2)
    bool _bear_depleting   = not na(array.get(poc_touch_vols, 5)) and array.get(poc_touch_vols, 3) < array.get(poc_touch_vols, 4) and array.get(poc_touch_vols, 4) < array.get(poc_touch_vols, 5)
    poc_vol_depleting := _bull_depleting or _bear_depleting
    bool _bull_escalating  = not na(array.get(poc_touch_vols, 2)) and array.get(poc_touch_vols, 0) > array.get(poc_touch_vols, 1) and array.get(poc_touch_vols, 1) > array.get(poc_touch_vols, 2)
    bool _bear_escalating  = not na(array.get(poc_touch_vols, 5)) and array.get(poc_touch_vols, 3) > array.get(poc_touch_vols, 4) and array.get(poc_touch_vols, 4) > array.get(poc_touch_vols, 5)
    poc_vol_escalating := _bull_escalating or _bear_escalating
    poc_breakout_pending := poc_vol_depleting and barstate.isconfirmed
    poc_escape_likely    := poc_vol_escalating and barstate.isconfirmed
    if poc_breakout_pending and not poc_breakout_armed and barstate.isconfirmed
        poc_breakout_fail := false
        if _bull_depleting and _bear_depleting
            poc_breakout_armed := false
        else
            poc_breakout_armed := true
            poc_breakout_dir   := _bull_depleting ? 1 : (_bear_depleting ? -1 : (poc_crossed_up ? 1 : -1))
    if poc_breakout_armed and barstate.isconfirmed
        bool _break_confirmed = poc_breakout_dir == 1 ? close > svp_today_poc + _poc_prox * 2.0 : close < svp_today_poc - _poc_prox * 2.0
        if _break_confirmed
            poc_breakout_armed := false
            for i = 0 to 5
                array.set(poc_touch_vols, i, na)
            poc_touch_count := 0
    if poc_breakout_armed and barstate.isconfirmed
        bool _trap_close = poc_breakout_dir == 1 ? close < svp_today_poc - _poc_prox : close > svp_today_poc + _poc_prox
        if _trap_close
            poc_breakout_fail  := true
            poc_breakout_armed := false
            for i = 0 to 5
                array.set(poc_touch_vols, i, na)
            poc_touch_count := 0
    if poc_bull_retest_failed
        poc_crossed_up  := false
        poc_cross_price := na
    poc_bear_retest_failed := poc_crossed_dn and not poc_retest_dn_done and not poc_cross_dn and _poc_touch_from_below and close > svp_today_poc + _poc_prox and _pct_above_poc >= 50.0 and barstate.isconfirmed and in_market and is_today
    if poc_bear_retest_failed
        poc_crossed_dn  := false
        poc_cross_price := na
    poc_crossback_dn := poc_crossed_up and poc_retest_up_done and close < svp_today_poc - _poc_prox and _pct_below_poc >= 50.0 and barstate.isconfirmed
    if poc_crossback_dn
        poc_crossed_up  := false
        poc_cross_price := na
    poc_crossback_up := poc_crossed_dn and poc_retest_dn_done and close > svp_today_poc + _poc_prox and _pct_above_poc >= 50.0 and barstate.isconfirmed
    if poc_crossback_up
        poc_crossed_dn  := false
        poc_cross_price := na
    _poc_wick_only_bull := poc_bull_retest and close > svp_today_poc + _poc_prox
    _poc_wick_only_bear := poc_bear_retest and close < svp_today_poc - _poc_prox

// ── POC Quality Overlays (Phase 2) ──

// 2-A: Volume-Confirmed Retest Classification
// Read tod_rvol_pct on the retest bar
f_get_poc_coloc() =>
    if _use_ext_gap
        ["", false]
    else
        bool _poc_at_yday_poc  = svp_ready and not na(svp_yday_poc) and math.abs(svp_today_poc - svp_yday_poc) <= _poc_prox
        bool _poc_at_prev_vwap = not na(prev_vwap) and math.abs(svp_today_poc - prev_vwap) <= _poc_prox
        bool _poc_at_or_mid    = or_set and not na(or_mid) and math.abs(svp_today_poc - or_mid) <= _poc_prox
        bool _poc_at_or_h      = or_set and not na(or_h) and math.abs(svp_today_poc - or_h) <= _poc_prox
        bool _poc_at_or_l      = or_set and not na(or_l) and math.abs(svp_today_poc - or_l) <= _poc_prox
        string _poc_coloc_name = _poc_at_yday_poc ? "+pPOC" : _poc_at_prev_vwap ? "+pV" : _poc_at_or_mid ? "+ORm" : _poc_at_or_h ? "+ORH" : _poc_at_or_l ? "+ORL" : poc_at_vwap ? "+VWAP" : ""
        bool _poc_at_any_level = _poc_at_yday_poc or _poc_at_prev_vwap or _poc_at_or_mid or _poc_at_or_h or _poc_at_or_l or poc_at_vwap
        [_poc_coloc_name, _poc_at_any_level]

f_get_poc_alert_suffix() =>
    string _poc_retest_vol_tag = tod_rvol_pct < 80 ? "✓" : tod_rvol_pct > 120 ? "⚠" : ""
    string _poc_rmi_tag = (poc_bull_retest and _rmi_val > 50 and _rmi_consec > 0) or (poc_bear_retest and _rmi_val < 50 and _rmi_consec < 0) ? "✓" : (poc_bull_retest and _rmi_val < 40) or (poc_bear_retest and _rmi_val > 60) ? "⚠" : ""
    string _poc_time_tag = ist_t < 1030 ? "Early" : ist_t < 1200 ? "Prime" : ist_t < 1330 ? "Dead" : ist_t < 1430 ? "PM" : ist_t < 1515 ? "Phase4" : "Late"
    string _poc_depth_tag = _poc_wick_only_bull or _poc_wick_only_bear ? "⚡" : "~"
    [_poc_coloc_name, _poc_at_any_level] = f_get_poc_coloc()
    _poc_retest_vol_tag + _poc_rmi_tag + " " + _poc_depth_tag + " [" + _poc_time_tag + "]" + (_poc_at_any_level ? "\n" + _poc_coloc_name : "")

string poc_alert_suffix = f_get_poc_alert_suffix()



// ── HL / LH Structure ──
// hl_atr_mult: user-controlled proximity threshold (default 0.20, was 0.30)
// hl_or_gate:  when ON, HL/LH only fires after OR sets — eliminates pre-OR noise
f_get_hl_lh_state() =>
    float _prox = current_atr * hl_atr_mult
    
    bool _hl_at_or_high = or_set and math.abs(close - or_h)    <= _prox
    bool _hl_at_or_low  = or_set and math.abs(close - or_l)    <= _prox
    bool _hl_at_or_mid  = or_set and math.abs(close - or_mid)  <= _prox
    bool _hl_at_vwap    = _use_ext_gap ? math.abs(_u_close - vwap_val) <= _prox : math.abs(close - vwap_val) <= _prox
    bool _hl_at_pvwap   = math.abs(close - prev_vwap)           <= _prox
    bool _hl_at_pdh     = math.abs(close - pd_high)             <= _prox
    bool _hl_at_pdl     = math.abs(close - pd_low)              <= _prox
    bool _hl_at_level   = _hl_at_or_high or _hl_at_or_low or _hl_at_or_mid or _hl_at_vwap or _hl_at_pvwap or _hl_at_pdh or _hl_at_pdl
    
    bool _hl_anchor = (math.abs(low[1] - or_l)    <= _prox) or (math.abs(low[1] - or_h)    <= _prox) or (math.abs(low[1] - or_mid)  <= _prox) or (math.abs(low[1] - vwap_val) <= _prox) or (math.abs(low[1] - pd_low)   <= _prox) or (math.abs(low[1] - pd_high)  <= _prox) or (math.abs(low[1] - prev_vwap) <= _prox)
    bool _hl_forming = in_market and (not hl_or_gate or or_set) and _hl_at_level and low > low[1] and low[2] > low[1] and _hl_anchor and barstate.isconfirmed

    bool _lh_anchor = (math.abs(high[1] - or_h)    <= _prox) or (math.abs(high[1] - or_l)    <= _prox) or (math.abs(high[1] - or_mid)  <= _prox) or (math.abs(high[1] - vwap_val) <= _prox) or (math.abs(high[1] - pd_high)  <= _prox) or (math.abs(high[1] - pd_low)   <= _prox) or (math.abs(high[1] - prev_vwap) <= _prox)
    bool _lh_forming = in_market and (not hl_or_gate or or_set) and _hl_at_level and high < high[1] and high[2] < high[1] and _lh_anchor and barstate.isconfirmed
    
    [_hl_forming, _lh_forming]

[hl_forming, lh_forming] = f_get_hl_lh_state()

// ── Double Top & Double Bottom Tracking (M/W Patterns) ──
// (State variables declared in global var block above — no redeclaration needed)

float mw_match_prox = current_atr * mw_match_prox_mult
float mw_level_prox = current_atr * 0.25
int   mw_min_bars   = math.max(12, int(90 / math.max(tf, 1))) // normalises to 90 minutes across timeframes.
// Hard floor of 12 bars ensures minimum separation on HTF charts (15m = 3H minimum).
int   mw_max_bars   = int(240 / math.max(tf, 1))

bool is_double_bottom = false
string w_confluence = ""

if show_mw and hl_forming
    if not na(last_swing_low) and math.abs(low[1] - last_swing_low) <= mw_match_prox and (bar_index - last_swing_low_bar) >= mw_min_bars and (bar_index - last_swing_low_bar) <= mw_max_bars
        bool _val_conf = svp_ready and not na(svp_today_val) and math.abs(low[1] - svp_today_val) <= mw_level_prox
        bool _vwap_dn  = not svp_ready and math.abs(low[1] - vwap_dn1) <= mw_level_prox
        bool _or_l     = math.abs(low[1] - or_l) <= mw_level_prox
        bool _pm_l     = math.abs(low[1] - pm_low) <= mw_level_prox
        bool _rmi_div  = _rmi_val[1] > last_swing_low_rmi + 3.0
        bool _poc_conf = svp_track_dev and not na(svp_today_poc) and math.abs(low[1] - svp_today_poc) <= mw_level_prox
        
        if _val_conf or _vwap_dn or _or_l or _pm_l or _rmi_div or bot_sweep[1] or _poc_conf

            is_double_bottom := true
            w_confluence := _val_conf ? "VAL" : _vwap_dn ? "VWAP-1σ" : _or_l ? "OR Low" : _pm_l ? "PM Low" : _poc_conf ? "dPOC" : bot_sweep[1] ? "Sweep" : _rmi_div ? "RMI Div" : "Structural"

            if _rmi_div and w_confluence != "RMI Div"
                w_confluence += " + RMI Div"
            if is_today and is_micro_execution
                line.delete(_last_w_line)
                label.delete(_last_w_lbl)
                _last_w_line := line.new(x1=last_swing_low_bar, y1=last_swing_low, x2=bar_index - 1, y2=low[1], color=color.new(#00ff88, 40), style=line.style_dashed, width=2)
                _last_w_lbl  := label.new(x=bar_index - 1, y=low[1], text="W-Pattern\n" + w_confluence, style=label.style_label_up, color=color.new(#00ff88, 80), textcolor=color.green, size=size.small)
            // Pattern fired — do NOT update last_swing_low
        else
            // Pattern did not fire (confluence failed) — update anchor for next comparison
            last_swing_low := low[1]
            last_swing_low_bar := bar_index - 1
            last_swing_low_rmi := _rmi_val[1]
    else
        // No prior swing low or outside window — update anchor
        last_swing_low := low[1]
        last_swing_low_bar := bar_index - 1
        last_swing_low_rmi := _rmi_val[1]

bool is_double_top = false
string m_confluence = ""

if show_mw and lh_forming
    if not na(last_swing_high) and math.abs(high[1] - last_swing_high) <= mw_match_prox and (bar_index - last_swing_high_bar) >= mw_min_bars and (bar_index - last_swing_high_bar) <= mw_max_bars
        bool _vah_conf = svp_ready and not na(svp_today_vah) and math.abs(high[1] - svp_today_vah) <= mw_level_prox
        bool _vwap_up  = not svp_ready and math.abs(high[1] - vwap_up1) <= mw_level_prox
        bool _or_h     = math.abs(high[1] - or_h) <= mw_level_prox
        bool _pm_h     = math.abs(high[1] - pm_high) <= mw_level_prox
        bool _rmi_div  = _rmi_val[1] < last_swing_high_rmi - 3.0

        // ── M/W Pattern POC Confluence (Phase 3-D) ──
        bool _poc_conf_m = svp_track_dev and not na(svp_today_poc) and math.abs(high[1] - svp_today_poc) <= mw_level_prox
        
        if _vah_conf or _vwap_up or _or_h or _pm_h or _rmi_div or top_sweep[1] or _poc_conf_m
            is_double_top := true
            m_confluence := _vah_conf ? "VAH" : _vwap_up ? "VWAP+1σ" : _or_h ? "OR High" : _pm_h ? "PM High" : _poc_conf_m ? "dPOC" : top_sweep[1] ? "Sweep" : _rmi_div ? "RMI Div" : "Structural"

            if _rmi_div and m_confluence != "RMI Div"
                m_confluence += " + RMI Div"
            if is_today and is_micro_execution
                line.delete(_last_m_line)
                label.delete(_last_m_lbl)
                _last_m_line := line.new(x1=last_swing_high_bar, y1=last_swing_high, x2=bar_index - 1, y2=high[1], color=color.new(#ff4466, 40), style=line.style_dashed, width=2)
                _last_m_lbl  := label.new(x=bar_index - 1, y=high[1], text="M-Pattern\n" + m_confluence, style=label.style_label_down, color=color.new(#ff4466, 80), textcolor=color.red, size=size.small)
            // Pattern fired — do NOT update last_swing_high
        else
            // Pattern did not fire (confluence failed) — update anchor for next comparison
            last_swing_high := high[1]
            last_swing_high_bar := bar_index - 1
            last_swing_high_rmi := _rmi_val[1]
    else
        // No prior swing high or outside window — update anchor
        last_swing_high := high[1]
        last_swing_high_bar := bar_index - 1
        last_swing_high_rmi := _rmi_val[1]


if is_double_bottom
    bars_since_w := 0
    last_w_conf := w_confluence
else if in_market and barstate.isconfirmed
    bars_since_w += 1

if is_double_top
    bars_since_m := 0
    last_m_conf := m_confluence
else if in_market and barstate.isconfirmed
    bars_since_m += 1


if new_hour and barstate.isconfirmed and is_today and (is_micro_execution or is_hourly_prep)
    if show_indecision and h1_body_ratio < doji_threshold and h1_up_pct > 0.25 and h1_dn_pct > 0.25
        label.new(bar_index[1], high[1], "", style=label.style_diamond, color=#ffee00, size=size.small)
    if show_gravestone and h1_body_ratio < doji_threshold and h1_up_pct > 0.60 and h1_dn_pct < 0.15
        label.new(bar_index[1], high[1], "", style=label.style_diamond, color=#ff2244, size=size.small)
    if show_dragonfly and h1_body_ratio < doji_threshold and h1_dn_pct > 0.60 and h1_up_pct < 0.15
        label.new(bar_index[1], low[1],  "", style=label.style_diamond, color=#00bb66, size=size.small)

// Draw the active zone as a persistent box extended to the right edge
var box   _fvg_box      = na
var label _fvg_zone_lbl = na  // persistent — prevents label accumulation on every islast tick
if _show_h1_fvgs and (is_micro_execution or is_hourly_prep) and barstate.islast
    box.delete(_fvg_box)
    label.delete(_fvg_zone_lbl)
    if not na(active_fvg_top) and not na(active_fvg_bot)
        bool _is_bull_zone = active_fvg_dir == "BULL FVG"
        color _fvg_border  = _is_bull_zone ? color.new(#00ff88, 40) : color.new(#ff4466, 40)
        color _fvg_bg      = _is_bull_zone ? color.new(#00ff88, 92) : color.new(#ff4466, 92)
        _fvg_box := box.new(left=bar_index - 300, top=active_fvg_top, right=bar_index + 100, bottom=active_fvg_bot, border_color=_fvg_border, bgcolor=_fvg_bg, border_width=1, border_style=line.style_dashed)
        // Right-edge label on the zone - shift further right to avoid OR Low collision
        _fvg_zone_lbl := label.new(bar_index + 20, (active_fvg_top + active_fvg_bot) / 2, "1H " + active_fvg_dir, style=label.style_label_left, color=_fvg_border, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// TREND & TAPE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

// ── VWAP Vote — weighted ±2 (primary institutional signal) ──
// Uses existing vwap state variables already computed above
// near_vwap (proximity within ATR*0.20) = neutral — no conviction either side
//
// MAJOR-1 FIX: In options modes (_use_ext_gap = true), use the underlying index VWAP
// for the trend vote rather than the premium VWAP.
// The premium VWAP is corrupted by two options-specific forces:
//   1. Theta decay: a call option can grind below its average price all day while
//      Nifty steadily rallies — the premium VWAP falls as theta erodes the value.
//   2. IV crush: after a high-volatility event (RBI, expiry gap), IV collapses rapidly,
//      dragging the premium below its VWAP regardless of directional movement.
// Institutional options traders make directional decisions based on the UNDERLYING index
// VWAP structure, not the premium's own time-weighted average. The premium VWAP is
// meaningless as a trend signal — only useful as a local execution reference level
// (which we keep for vwap_val in trap/retest logic; that is not touched here).
// Implementation: a single extra security() call fetches ta.vwap of gap_target at the
// chart's timeframe. In non-options modes, _use_ext_gap = false → reuses vwap_val
// (zero extra calls). In options modes, _use_ext_gap = true → one new call (29/40).
// CRITICAL (R10) FIX: Both _u_vwap and _u_close now pulled from vol_target (FUTURES).
// Previous version routed _u_close to gap_target (SPOT index). The futures/spot basis
// (BankNifty futures often 150-300 pts above spot) meant _u_close was always below
// _u_vwap by exactly the basis — permanently locking vwap_vote = -1 (false Bear bias)
// and displaying "-200 pts" VWAP Dist in the HUD that just reflected the basis, not
// actual deviation from institutional VWAP. VWAP and Close must come from the same
// instrument to produce a meaningful comparison. Futures-to-futures is correct.
// CRITICAL ALIGNMENT FIX: Custom VWAP to force exact IST daily reset on external feeds
float _u_vwap = vwap_val

float _u_prox  = _use_ext_gap ? nz(c_atr_rs, current_atr) * 0.20 : vwap_proximity

int vwap_vote = 0
if _use_ext_gap
    // Options mode: ±1 vote using UNDERLYING close vs underlying VWAP.
    // Comparing like-for-like: both values on the same instrument scale.
    // Full ±2 scoring (reclaim/reject/band states) not replicated for the underlying —
    // the state machine would require an extra security() call per state variable.
    // ±1 from a correctly-compared underlying direction > ±2 from a premium that is
    // structurally corrupted by theta decay and IV crush throughout the session.
    if math.abs(_u_close - _u_vwap) <= _u_prox
        vwap_vote := 0                          // Dead zone — no directional conviction
    else if _u_close > _u_vwap
        vwap_vote := 1                          // Underlying above VWAP → bull bias
    else
        vwap_vote := -1                         // Underlying below VWAP → bear bias
else
    // Non-options mode: full ±2 scoring with confirmed reclaim/reject state machine
    float _vwap_vote_vah = svp_ready and not na(svp_today_vah) ? svp_today_vah : vwap_up1
    float _vwap_vote_val = svp_ready and not na(svp_today_val) ? svp_today_val : vwap_dn1
    
    if math.abs(close - vwap_val) <= vwap_proximity
        vwap_vote := 0
    else if vwap_reclaimed or vwap_reclaim_retest or close > _vwap_vote_vah
        vwap_vote := 2   // Strong bull: body-confirmed reclaim or trending above institutional value
    else if close > vwap_val and not vwap_rejected
        vwap_vote := 1   // Weak bull: above VWAP, no recent rejection
    else if vwap_rejected or vwap_reject_retest or close < _vwap_vote_val
        vwap_vote := -2  // Strong bear: body-confirmed rejection or trending below institutional value
    else if close < vwap_val and not vwap_reclaimed
        vwap_vote := -1  // Weak bear: below VWAP, no recent reclaim

// ── Final Trend Score: range -6 to +6 ──
// vwap_vote: ±2 (primary weight)
// swing_vote: ±1 (structural confirmation)
// ema_vote: ±1 (tiebreaker)


f_lbl(_cond, _val, _txt, _bg_col, _txt_col) =>
    var label lbl = label.new(na, na, "", style=label.style_label_left, size=size.small)
    if barstate.islast
        if _cond and not na(_val)
            label.set_xy(lbl, bar_index + 2, _val)
            label.set_text(lbl, _txt)
            label.set_color(lbl, _bg_col)
            label.set_textcolor(lbl, _txt_col)
        else
            label.set_xy(lbl, na, na)

int trend_score = vwap_vote + swing_vote + ema_vote + h4_ema_vote + macro_vote

// ── Trend Arrow String Builder ──
string trend_arrows = (vwap_vote  > 0 ? "▲" : vwap_vote  < 0 ? "▼" : "○") + (swing_vote > 0 ? "▲" : swing_vote < 0 ? "▼" : "○") + (ema_vote   > 0 ? "▲" : ema_vote   < 0 ? "▼" : "○") + (h4_ema_vote > 0 ? "▲" : h4_ema_vote < 0 ? "▼" : "○") + (macro_vote > 0 ? "M▲" : macro_vote < 0 ? "M▼" : "")

// ── Trend Label & Cell Color ──
string trend_txt = ""
color  trend_val_col = color.silver
color  trend_bg_col  = color.new(color.gray, 80)

if not or_set
    trend_txt     := "···  Forming"
    trend_val_col := color.new(color.gray, 40)
    trend_bg_col  := color.new(color.gray, 90)
else if trend_score >= 6
    trend_txt     := trend_arrows + "  Strong Bull"
    trend_val_col := color.white
    trend_bg_col  := color.new(#00ff88, 50)
else if trend_score >= 4
    trend_txt     := trend_arrows + "  Bull"
    trend_val_col := color.white
    trend_bg_col  := color.new(#00bb66, 60)
else if trend_score >= 2
    trend_txt     := trend_arrows + "  Weak Bull"
    trend_val_col := color.white
    trend_bg_col  := color.new(#00bb66, 80)
else if trend_score <= -2 and trend_score > -4
    trend_txt     := trend_arrows + "  Weak Bear"
    trend_val_col := color.white
    trend_bg_col  := color.new(#ff2244, 80)
else if trend_score <= -4 and trend_score > -6
    trend_txt     := trend_arrows + "  Bear"
    trend_val_col := color.white
    trend_bg_col  := color.new(#ff2244, 60)
else if trend_score <= -6
    trend_txt     := trend_arrows + "  Strong Bear"
    trend_val_col := color.white
    trend_bg_col  := color.new(#ff2244, 50)
else
    // score +1 / -1 / 0 = conflicted/neutral
    trend_txt     := trend_arrows + "  Conflicted"
    trend_val_col := #ffee00
    trend_bg_col  := color.new(color.gray, 75)

// ── TAPE Logic ──
// Synthesizes OR direction + trend score + session state + ADR into one actionable word
// TAPE is driven by VWAP behavior and OR direction — NOT by EMA (too slow for real-time action)
// WITH   = OR direction aligned with trend conviction, session active, room to move
// AGAINST= OR direction opposing tape, or structural conflict, or launchpad blocking
// WAIT   = time/ADR/conflict-based no-trade condition — reason shown so trader knows when it lifts

string tape_txt     = ""
string tape_reason  = ""
color  tape_val_col = color.silver
color  tape_bg_col  = color.new(color.gray, 80)

if true
    int _vote_contributors = (vwap_vote != 0 ? 1 : 0) + (swing_vote != 0 ? 1 : 0) + (ema_vote != 0 ? 1 : 0) + (h4_ema_vote != 0 ? 1 : 0)
    bool tape_bull_aligned = or_break_dir == 1  and trend_score >= 2 and _vote_contributors >= 2 and not is_vwap_trending_dn
    bool tape_bear_aligned = or_break_dir == -1 and trend_score <= -2 and _vote_contributors >= 2 and not is_vwap_trending_up
    bool tape_time_ok = not p3_filter_active and not phase4_block
    bool tape_adr_ok       = adr_used_pct < 80
    bool tape_or_set       = or_set
    
    bool tape_rmi_ok_bull = not use_rmi_tape or na(or_close_rmi) or or_close_rmi < 65
    bool tape_rmi_ok_bear = not use_rmi_tape or na(or_close_rmi) or or_close_rmi > 35
    bool tape_gap_trap_dn = use_rmi_tape and gap_pct > 0.2 and or_break_dir == -1 and not na(or_close_rmi) and or_close_rmi > 60
    bool tape_gap_trap_up = use_rmi_tape and gap_pct < -0.2 and or_break_dir == 1  and not na(or_close_rmi) and or_close_rmi < 40

    if not tape_or_set
        tape_txt     := "WAIT"
        tape_reason  := "  Forming"
        tape_val_col := color.new(color.gray, 30)
        tape_bg_col  := color.new(color.gray, 85)
    
    else if not tape_time_ok
        tape_txt     := "WAIT"
        tape_reason  := phase4_block ? "  Phase 4" : "  " + p3_reason
        tape_val_col := color.new(color.gray, 30)
        tape_bg_col  := color.new(color.gray, 85)
    else if not tape_adr_ok
        tape_txt     := "WAIT"
        tape_reason  := "  ADR Exhausted"
        tape_val_col := color.new(color.gray, 30)
        tape_bg_col  := color.new(color.gray, 85)
    else if tape_gap_trap_dn or tape_gap_trap_up
        tape_txt     := "AGAINST"
        tape_reason  := tape_gap_trap_dn ? "  Gap Trap ↓" : "  Gap Trap ↑"
        tape_val_col := color.white
        tape_bg_col  := color.new(#ff8800, 55)
    else if use_rmi_tape and or_trap_warned and or_break_dir == 0
        tape_txt     := "WAIT"
        tape_reason  := "  Gap Trap Brewing"
        tape_val_col := #ffee00
        tape_bg_col  := color.new(#ff8800, 70)
    else if active_gap_magnet and or_break_dir != 0
        tape_txt     := "AGAINST"
        tape_reason  := "  Gap Magnet"
        tape_val_col := color.white
        tape_bg_col  := color.new(#ff8800, 55)
    else if (or_break_dir == 1 and trend_score <= -1) or (or_break_dir == -1 and trend_score >= 1)
        tape_txt     := "AGAINST"
        tape_reason  := "  Trap Risk"
        tape_val_col := color.white
        tape_bg_col  := color.new(#ff8800, 55)
    else if (is_launchpad_up and or_break_dir == -1) or (is_launchpad_dn and or_break_dir == 1)
        tape_txt     := "AGAINST"
        tape_reason  := "  Launchpad Block"
        tape_val_col := color.white
        tape_bg_col  := color.new(#ff8800, 55)
    else if (tape_bull_aligned and not tape_rmi_ok_bull) or (tape_bear_aligned and not tape_rmi_ok_bear)
        tape_txt     := "WAIT"
        tape_reason  := "  RMI Exhausted"
        tape_val_col := #ffee00
        tape_bg_col  := color.new(color.gray, 80)
    else if (tape_bull_aligned and not is_launchpad_dn and tape_rmi_ok_bull) or (tape_bear_aligned and not is_launchpad_up and tape_rmi_ok_bear)
        tape_txt     := tape_bull_aligned ? "WITH ▲" : "WITH ▼"
        tape_reason  := tape_bull_aligned ? "  Bull Breakout" : "  Bear Breakout"
        string _poc_tape_tag = (poc_regime_state == "Expanding ▲" or poc_regime_state == "Expanding ▼") ? " +Mig" :
                               (r_close > svp_today_poc + _poc_prox) ? " +POC Sup" : 
                               (r_close < svp_today_poc - _poc_prox) ? " +POC Res" : " @ POC"
        tape_reason += (svp_track_dev and not na(svp_today_poc)) ? _poc_tape_tag : ""
        tape_val_col := color.white
        tape_bg_col  := tape_bull_aligned ? color.new(#00ff88, 45) : color.new(#ff2244, 45)
    else
        tape_txt     := "WAIT"
        tape_reason  := math.abs(trend_score) <= 1 ? "  Conflicted" : "  No Alignment"
        tape_val_col := #ffee00
        tape_bg_col  := color.new(color.gray, 80)

// ═══════════════════════════════════════════════════════════════════════════════
// STYLE & HUD
// ═══════════════════════════════════════════════════════════════════════════════
// P3: Gray shading now driven by conditions, not fixed clock.
// Appears when filter is active — lifts on trend days even inside 12:00-13:30.
// dead_zone retained as a fallback: if P3 never triggers but clock is in DZ window,
// a lighter shade still shows as a visual reminder of the statistical dead zone.
color _bg_session_zone = not is_today or not is_micro_execution ? na : 
     p3_filter_active ? color.new(color.gray, 95) : 
     (dead_zone and not p3_filter_active) ? color.new(color.gray, 99) :
     (show_kz and in_market and ist_t >= SESSION_OPEN and ist_t <= 1015) ? color.new(#0088ff, 95) :
     (show_kz and in_market and ist_t >= PHASE4_START and ist_t <= SQUAREOFF_TIME) ? color.new(#ff8800, 95) : na
bgcolor(_bg_session_zone, title="Session Zones")

// ── Plot Variables — show_prev_day_lines gates PD reference visuals, is_today gates all on historical days ──
// is_htf_chart gates intraday-only visuals (OR, PM VWAP, F5, targets, intraday VWAP) to na on HTF.
// ═══════════════════════════════════════════════════════════════════════════════
// PLOT VARIABLE ROUTING — Timeframe Visibility Matrix
// ═══════════════════════════════════════════════════════════════════════════════
// Each variable is shown only on the tier(s) where it adds value.
// Engine math is unaffected — only visuals change.
//
// MICRO (≤15m):  Full execution — VWAP, OR, sweeps, targets, F5
// HOURLY (≤60m): Imbalance map — 1H FVGs, Doji Radar, Daily VIX, PDH/PDL
// 4H  (≤240m):  Gravity magnets — PDH/PDL, PWH/PWL, POC, ADR
// MACRO (≥1D):   Bias only — Weekly VWAP, D EMA21, Weekly VIX bands

// ── Available on ALL tiers (structural references) ──
float p_pdh      = show_prev_day_lines and in_market and is_today ? pd_high  : na
float p_pdl      = show_prev_day_lines and in_market and is_today ? pd_low   : na
float p_pdc      = show_prev_day_lines and in_market and not active_gap_magnet and not gap_filled and is_today ? pd_close : na
float p_gap_mag  = show_prev_day_lines and in_market and active_gap_magnet and not gap_filled and is_today ? pd_close : na

// ── MICRO + HOURLY: Intraday VWAP (daily reset is meaningful ≤1H) ──
// Suppressed in Options Mode (_use_ext_gap) because VWAP is at index scale and plots off-screen
float p_vwap_val  = in_market and is_today and (is_micro_execution or is_hourly_prep) and not _use_ext_gap ? vwap_val : na
float p_vwap_up1  = in_market and show_vwap_1sd and is_today and is_micro_execution and not _use_ext_gap and (close >= or_l) ? vwap_up1 : na
float p_vwap_dn1  = in_market and show_vwap_1sd and is_today and is_micro_execution and not _use_ext_gap and (close <= or_h) ? vwap_dn1 : na
float p_prev_vwap = show_prev_day_lines and show_pd_vwap and in_market and is_today and (is_micro_execution or is_hourly_prep) ? prev_vwap : na
float p_pm_vwap   = in_market and ist_t >= PM_START and is_today and is_micro_execution and not _use_ext_gap and pm_vwap_load_warmup > 5 ? pm_vwap : na

// ── MICRO only: OR lines, F5, targets, PM VWAP ──
float p_or_h   = show_or_hl and or_set and in_market and is_today and is_micro_execution ? or_h  : na
float p_or_mid = show_or_mid and or_set and in_market and is_today and is_micro_execution ? or_mid : na
float p_or_l   = show_or_hl and or_set and in_market and is_today and is_micro_execution ? or_l  : na
float p_t_h05  = show_t05 and show_bull_targets and is_today and is_micro_execution ? ext_h05 : na
float p_t_h10  = show_t10 and show_bull_targets and is_today and is_micro_execution ? ext_h10 : na
float p_t_h15  = show_t15 and show_bull_targets and is_today and is_micro_execution ? ext_h15 : na  // ← T+1.5
float p_t_h20  = show_t20 and show_bull_targets and is_today and is_micro_execution ? ext_h20 : na
float p_t_l05  = show_t05 and show_bear_targets and is_today and is_micro_execution ? ext_l05 : na
float p_t_l10  = show_t10 and show_bear_targets and is_today and is_micro_execution ? ext_l10 : na
float p_t_l15  = show_t15 and show_bear_targets and is_today and is_micro_execution ? ext_l15 : na  // ← T-1.5
float p_t_l20  = show_t20 and show_bear_targets and is_today and is_micro_execution ? ext_l20 : na
bool  show_f5_now = show_f5 and in_market and ist_t >= 920 and ist_t < PM_START and is_today and is_micro_execution
float p_f5_h   = show_f5_now ? f5_h : na
float p_f5_l   = show_f5_now ? f5_l : na
bool ps_gap_dn = just_filled and gap_pct > 0 and is_today and is_micro_execution
bool ps_gap_up = just_filled and gap_pct < 0 and is_today and is_micro_execution

// ── HOURLY + MICRO: Daily VIX ceiling/floor (prep + execution reference) ──
float p_vix_ceil  = use_vix and in_market and is_today and not _use_ext_gap and not _is_options_chart and (is_micro_execution or is_hourly_prep) ? vix_ceiling : na
float p_vix_floor = use_vix and in_market and is_today and not _use_ext_gap and not _is_options_chart and (is_micro_execution or is_hourly_prep) ? vix_floor   : na

// ── 4H + MACRO: PWH/PWL, POC, ADR (gravity magnets — zoom out to see) ──
float p_pw_high   = show_prev_day_lines and show_weekly and in_market and is_today and (is_4h_gravity or is_macro_trend) ? pw_high : na
float p_pw_low    = show_prev_day_lines and show_weekly and in_market and is_today and (is_4h_gravity or is_macro_trend) ? pw_low  : na
float p_poc       = show_prev_day_lines and show_poc and in_market and is_today and (is_4h_gravity or is_macro_trend) ? prev_poc : na
float p_adr_upper = show_prev_day_lines and show_adr and in_market and is_today and not _use_ext_gap and (is_4h_gravity or is_macro_trend) ? adr_upper : na
float p_adr_lower = show_prev_day_lines and show_adr and in_market and is_today and not _use_ext_gap and (is_4h_gravity or is_macro_trend) ? adr_lower : na

// ── MACRO only: Weekly VIX bands (absolute weekly expiry boundaries) ──
float p_weekly_ceil  = _show_weekly_bands and in_market and is_today and is_macro_trend ? weekly_vix_ceil  : na
float p_weekly_floor = _show_weekly_bands and in_market and is_today and is_macro_trend ? weekly_vix_floor : na

// ── MICRO + HOURLY: SVP Lines — yday POC and today's developing POC/VA ──
// svp_ready guard ensures yday POC is hidden on Day 1 (no prior session data yet).
// svp_track_dev guard ensures today's lines only appear when the developing
// profile is being computed (svp_track_dev = true in inputs).
// Timeframe: MICRO + HOURLY — same visibility tier as prev_vwap.
// Suppressed on options charts (_use_ext_gap) where price scale is premium, not index.
float p_svp_yday_poc  = show_svp_yday_poc  and svp_ready and in_market and is_today and
     not _use_ext_gap and (is_micro_execution or is_hourly_prep) ? svp_yday_poc  : na

float p_svp_today_poc = show_svp_today_poc and svp_track_dev and in_market and is_today and
     not _use_ext_gap and (is_micro_execution or is_hourly_prep) ? svp_today_poc : na

float p_svp_today_vah = show_svp_today_va  and svp_track_dev and in_market and is_today and
     not _use_ext_gap and (is_micro_execution or is_hourly_prep) ? svp_today_vah : na

float p_svp_today_val = show_svp_today_va  and svp_track_dev and in_market and is_today and
     not _use_ext_gap and (is_micro_execution or is_hourly_prep) ? svp_today_val : na


// ── Reference Level Plots — Timeframe Visibility Matrix ──
// MICRO + HOURLY: Intraday VWAP, ±1σ, Prev VWAP, PM VWAP
plot(p_vwap_up1,  "VWAP +1σ",    color.new(#ff2244, 55), 1, plot.style_linebr)
plot(p_vwap_dn1,  "VWAP -1σ",    color.new(#00bb66, 55), 1, plot.style_linebr)
plot(p_pm_vwap,   "PM VWAP",     color.new(#ffaa00, 15), 2, plot.style_circles)
plot(p_vwap_val,  "VWAP",        color.new(#00aaff, 20), 2, plot.style_linebr)
// MICRO only: OR lines, targets, F5
var line l_pdc = na, var line l_gap = na, var line l_pdh = na, var line l_pdl = na
var line l_t_h05 = na, var line l_t_h10 = na, var line l_t_h15 = na, var line l_t_h20 = na
var line l_t_l05 = na, var line l_t_l10 = na, var line l_t_l15 = na, var line l_t_l20 = na
var line l_f5_h = na, var line l_f5_l = na
var line l_vix_c = na, var line l_vix_f = na
var line l_pw_h = na, var line l_pw_l = na, var line l_adr_u = na, var line l_adr_l = na
var line l_w_ceil = na, var line l_w_floor = na
var line l_poc = na, var line l_svp_y_poc = na, var line l_prev_vwap = na
var line _or_h_line = na, var line _or_m_line = na, var line _or_l_line = na
var box  _poc_zone_box = na

if is_new_day
    line.delete(_or_h_line), line.delete(_or_m_line), line.delete(_or_l_line)
    line.delete(l_pdc), line.delete(l_gap), line.delete(l_pdh), line.delete(l_pdl)
    line.delete(l_t_h05), line.delete(l_t_h10), line.delete(l_t_h15), line.delete(l_t_h20)
    line.delete(l_t_l05), line.delete(l_t_l10), line.delete(l_t_l15), line.delete(l_t_l20)
    line.delete(l_f5_h), line.delete(l_f5_l)
    line.delete(l_vix_c), line.delete(l_vix_f)
    line.delete(l_pw_h), line.delete(l_pw_l), line.delete(l_adr_u), line.delete(l_adr_l)
    line.delete(l_w_ceil), line.delete(l_w_floor)
    line.delete(l_poc), line.delete(l_svp_y_poc), line.delete(l_prev_vwap)
    _or_h_line := na, _or_m_line := na, _or_l_line := na
    l_pdc := na, l_gap := na, l_pdh := na, l_pdl := na
    l_t_h05 := na, l_t_h10 := na, l_t_h15 := na, l_t_h20 := na
    l_t_l05 := na, l_t_l10 := na, l_t_l15 := na, l_t_l20 := na
    l_f5_h := na, l_f5_l := na
    l_vix_c := na, l_vix_f := na
    l_pw_h := na, l_pw_l := na, l_adr_u := na, l_adr_l := na
    l_w_ceil := na, l_w_floor := na
    l_poc := na, l_svp_y_poc := na, l_prev_vwap := na
    box.delete(_poc_zone_box)
    _poc_zone_box := na

// P5 sweep labels use managed_lbls[18/19] — no var label needed
f_set_managed_lbl(18, p5_top_sweep and is_today and is_micro_execution, "high", 0.4, "× PRE", color.new(#ff8844, 30), "tiny")
f_set_managed_lbl(19, p5_bot_sweep and is_today and is_micro_execution, "low",  0.4, "× PRE", color.new(#44ddaa, 30), "tiny")

if barstate.islast and is_today
    int _or_left = bar_index - math.max(0, bars_since_open - 1)
    
    // ── Migrated Session Levels (Plot Limit Fix) ──
    l_pdc   := f_manage_level_line(l_pdc,   p_pdc,       color.new(#aaaaaa, 50), 1, "solid",  _or_left, _box_right)
    l_gap   := f_manage_level_line(l_gap,   p_gap_mag,   #ff8800,                2, "solid",  _or_left, _box_right)
    l_pdh   := f_manage_level_line(l_pdh,   p_pdh,       color.new(#ff2244, 30), 1, "solid",  _or_left, _box_right)
    l_pdl   := f_manage_level_line(l_pdl,   p_pdl,       color.new(#00bb66, 20), 1, "solid",  _or_left, _box_right)
    
    l_t_h05 := f_manage_level_line(l_t_h05, p_t_h05,     color.new(#ff2244, 30), 1, "solid",  _or_left, _box_right)
    l_t_h10 := f_manage_level_line(l_t_h10, p_t_h10,     color.new(#ff2244, 10), 1, "solid",  _or_left, _box_right)
    l_t_h15 := f_manage_level_line(l_t_h15, p_t_h15,     color.new(#ff2244, 20), 1, "solid",  _or_left, _box_right)
    l_t_h20 := f_manage_level_line(l_t_h20, p_t_h20,     color.new(#ff2244, 10), 1, "solid",  _or_left, _box_right)
    
    l_t_l05 := f_manage_level_line(l_t_l05, p_t_l05,     color.new(#00bb66, 30), 1, "solid",  _or_left, _box_right)
    l_t_l10 := f_manage_level_line(l_t_l10, p_t_l10,     color.new(#00bb66, 10), 1, "solid",  _or_left, _box_right)
    l_t_l15 := f_manage_level_line(l_t_l15, p_t_l15,     color.new(#00bb66, 20), 1, "solid",  _or_left, _box_right)
    l_t_l20 := f_manage_level_line(l_t_l20, p_t_l20,     color.new(#00bb66, 10), 1, "solid",  _or_left, _box_right)
    
    l_f5_h  := f_manage_level_line(l_f5_h,  p_f5_h,      color.new(#ffee00, 30), 1, "solid",  _or_left, _box_right)
    l_f5_l  := f_manage_level_line(l_f5_l,  p_f5_l,      color.new(#ffee00, 30), 1, "solid",  _or_left, _box_right)
    
    l_vix_c := f_manage_level_line(l_vix_c, p_vix_ceil,  color.new(#ace5dc, 30), 1, "solid",  _or_left, _box_right)
    l_vix_f := f_manage_level_line(l_vix_f, p_vix_floor, color.new(#ace5dc, 30), 1, "solid",  _or_left, _box_right)
    
    l_pw_h   := f_manage_level_line(l_pw_h,   p_pw_high, color.new(#9c27b0, 30), 2, "solid",  _or_left, _box_right)
    l_pw_l   := f_manage_level_line(l_pw_l,   p_pw_low,  color.new(#9c27b0, 30), 2, "solid",  _or_left, _box_right)
    
    l_adr_u  := f_manage_level_line(l_adr_u,  p_adr_upper, color.new(#ff00ff, 40), 1, "dotted", _or_left, _box_right)
    l_adr_l  := f_manage_level_line(l_adr_l,  p_adr_lower, color.new(#ff00ff, 40), 1, "dotted", _or_left, _box_right)

    l_w_ceil := f_manage_level_line(l_w_ceil, p_weekly_ceil,  color.new(#ff2244, 60), 2, "solid",  _or_left, _box_right)
    l_w_floor := f_manage_level_line(l_w_floor, p_weekly_floor, color.new(#00ff88, 60), 2, "solid",  _or_left, _box_right)

    l_poc       := f_manage_level_line(l_poc,       p_poc,           color.new(color.fuchsia, 30), 2, "solid",  _or_left, _box_right)
    l_svp_y_poc := f_manage_level_line(l_svp_y_poc, p_svp_yday_poc,  color.new(#ff00ff, 10),       2, "solid",  _or_left, _box_right)
    l_prev_vwap := f_manage_level_line(l_prev_vwap, p_prev_vwap,     color.new(#aaaaaa, 40),       1, "dotted", _or_left, _box_right)


    // ── OR Lines & POC Box ──
    if or_set and is_micro_execution
        line.delete(_or_h_line), line.delete(_or_m_line), line.delete(_or_l_line)
        if show_or_hl
            _or_h_line := line.new(_or_left, or_h, _box_right, or_h, color=color.new(#ff2244, 20), width=4, style=line.style_solid)
            _or_l_line := line.new(_or_left, or_l, _box_right, or_l, color=color.new(#00bb66, 20), width=4, style=line.style_solid)
        if show_or_mid
            _or_m_line := line.new(_or_left, or_mid, _box_right, or_mid, color=color.new(#ffaa00, 30), width=2, style=line.style_solid)
        
        if svp_track_dev and not na(svp_today_poc)
            box.delete(_poc_zone_box)
            _poc_zone_box := box.new(left=_or_left, top=svp_today_poc + _poc_prox, right=_box_right, bottom=svp_today_poc - _poc_prox, border_color=color.new(#ff00ff, 80), bgcolor=color.new(#ff00ff, 94), border_width=1)

// MICRO + HOURLY: SVP Lines — Developing POC/VAH/VAL
plot(p_svp_today_poc, "Today POC",      color.new(#ff00ff, 40), 2, plot.style_circles)
plot(p_svp_today_vah, "Today VA High",  color.new(#e040fb, 40), 1, plot.style_linebr)
plot(p_svp_today_val, "Today VA Low",   color.new(#ab47bc, 40), 1, plot.style_linebr)
// ── Signal Shapes ──
// v23: Exhaustion arrows color-coded by internal RMI confirmation
// Faded fuchsia  = exhaustion without RMI confirmation
f_lbl(show_prev_day_lines and show_pd_vwap and in_market and (is_micro_execution or is_hourly_prep), prev_vwap, "Prev VWAP", #aaaaaa, color.white)
f_lbl(in_market and (is_micro_execution or is_hourly_prep) and not _use_ext_gap, vwap_val, "VWAP",     #00aaff, color.white)
f_lbl(in_market and is_macro_trend, w_vwap,  "W VWAP",  #2196F3, color.white)
f_lbl(in_market and is_macro_trend, d_ema21, "D EMA21", #ff9800, color.black)
f_lbl(show_or_hl and or_set and in_market and is_micro_execution, or_h,   "OR High", #ff2244, color.white)
f_lbl(show_or_mid and or_set and in_market and is_micro_execution, or_mid, "OR Mid",  #ffaa00, color.black)
f_lbl(show_or_hl and or_set and in_market and is_micro_execution, or_l,   "OR Low",  #00bb66, color.white)
f_lbl(show_t05 and show_bull_targets and not na(ext_h05) and is_micro_execution, ext_h05, "T+0.5", #ff2244, color.white)
f_lbl(show_t10 and show_bull_targets and not na(ext_h10) and is_micro_execution, ext_h10, "T+1.0", #ff2244, color.white)
f_lbl(show_t15 and show_bull_targets and not na(ext_h15) and is_micro_execution, ext_h15, "T+1.5", #ff2244, color.white)
f_lbl(show_t20 and show_bull_targets and not na(ext_h20) and is_micro_execution, ext_h20, "T+2.0", #ff2244, color.white)
f_lbl(show_t05 and show_bear_targets and not na(ext_l05) and is_micro_execution, ext_l05, "T-0.5", #00bb66, color.white)
f_lbl(show_t10 and show_bear_targets and not na(ext_l10) and is_micro_execution, ext_l10, "T-1.0", #00bb66, color.white)
f_lbl(show_t15 and show_bear_targets and not na(ext_l15) and is_micro_execution, ext_l15, "T-1.5", #00bb66, color.white)
f_lbl(show_t20 and show_bear_targets and not na(ext_l20) and is_micro_execution, ext_l20, "T-2.0", #00bb66, color.white)
f_lbl(show_f5_now and is_micro_execution, f5_h, "F5 High", #ffee00, color.black)
f_lbl(show_f5_now and is_micro_execution, f5_l, "F5 Low",  #ffee00, color.black)
f_lbl(in_market and use_vix and not _use_ext_gap and not _is_options_chart and (is_micro_execution or is_hourly_prep), vix_ceiling, "VIX Ceiling", #ace5dc, color.black)
f_lbl(in_market and use_vix and not _use_ext_gap and not _is_options_chart and (is_micro_execution or is_hourly_prep), vix_floor,   "VIX Floor",   #ace5dc, color.black)

// SVP right-edge labels
f_lbl(show_svp_yday_poc  and svp_ready and in_market and not _use_ext_gap and
     (is_micro_execution or is_hourly_prep),
     svp_yday_poc,  "Yday POC", color.new(#ff00ff, 10), color.white)

f_lbl(show_svp_today_poc and svp_track_dev and in_market and not _use_ext_gap and
     (is_micro_execution or is_hourly_prep),
     svp_today_poc, "POC",      color.new(#ff00ff, 40), color.white)

f_lbl(show_svp_today_va  and svp_track_dev and in_market and not _use_ext_gap and
     (is_micro_execution or is_hourly_prep),
     svp_today_vah, "VAH",      color.new(#e040fb, 40), color.white)

f_lbl(show_svp_today_va  and svp_track_dev and in_market and not _use_ext_gap and
     (is_micro_execution or is_hourly_prep),
     svp_today_val, "VAL",      color.new(#ab47bc, 40), color.white)

f_lbl(_show_weekly_bands and in_market and is_macro_trend, weekly_vix_ceil,  "W Expiry ↑", #ffaa00, color.black)
f_lbl(_show_weekly_bands and in_market and is_macro_trend, weekly_vix_floor, "W Expiry ↓", #ffaa00, color.black)

f_draw_retest_labels() =>
    string _r_bull_sfx  = not use_rmi_retest ? "" : _rmi_val < 50 ? "✓" : _rmi_val > 65 ? "⚠" : ""
    string _r_bear_sfx  = not use_rmi_retest ? "" : _rmi_val > 50 ? "✓" : _rmi_val < 35 ? "⚠" : ""
    color  _r_bull_warn = _rmi_val > 65 ? #ffaa00 : #00ff88
    color  _r_bear_warn = _rmi_val < 35 ? #ffaa00 : #ff4466

    if is_today
        float _rej_q_up = (close - low)  / body_rng
        float _rej_q_dn = (high - close) / body_rng

        bool _r1_up_strong  = or_retest_bull  and (_rej_q_up >= 0.65 or or_h_conf_weight >= 2)
        bool _r1_up_weak    = or_retest_bull  and _rej_q_up <  0.65 and or_h_conf_weight  < 2
        bool _r1_dn_strong  = or_retest_bear  and (_rej_q_dn >= 0.65 or or_l_conf_weight >= 2)
        bool _r1_dn_weak    = or_retest_bear  and _rej_q_dn <  0.65 and or_l_conf_weight  < 2
        bool _r2_up_strong  = or_retest2_bull and (_rej_q_up >= 0.65 or or_h_conf_weight >= 2)
        bool _r2_up_weak    = or_retest2_bull and _rej_q_up <  0.65 and or_h_conf_weight  < 2
        bool _r2_dn_strong  = or_retest2_bear and (_rej_q_dn >= 0.65 or or_l_conf_weight >= 2)
        bool _r2_dn_weak    = or_retest2_bear and _rej_q_dn <  0.65 and or_l_conf_weight  < 2

        f_set_managed_lbl(0, _r1_up_strong, "low", 0.0, "R" + _r_bull_sfx, color.new(_r_bull_warn, 0), "small")
        f_set_managed_lbl(1, _r1_up_weak, "low", 0.0, "R" + _r_bull_sfx, color.new(#00ff88, 50), "small")
        f_set_managed_lbl(2, _r1_dn_strong, "high", 0.0, "R" + _r_bear_sfx, color.new(_r_bear_warn, 0), "small")
        f_set_managed_lbl(3, _r1_dn_weak, "high", 0.0, "R" + _r_bear_sfx, color.new(#ff4466, 50), "small")
        f_set_managed_lbl(4, _r2_up_strong, "low", 0.0, "R2" + _r_bull_sfx, color.new(_r_bull_warn, 0), "small")
        f_set_managed_lbl(5, _r2_up_weak, "low", 0.0, "R2" + _r_bull_sfx, color.new(#00ff88, 50), "small")
        f_set_managed_lbl(6, _r2_dn_strong, "high", 0.0, "R2" + _r_bear_sfx, color.new(_r_bear_warn, 0), "small")
        f_set_managed_lbl(7, _r2_dn_weak, "high", 0.0, "R2" + _r_bear_sfx, color.new(#ff4466, 50), "small")

f_draw_retest_labels()



if or_set and barstate.islast and is_today and is_micro_execution
    box.delete(_p1_h_box)
    box.delete(_p1_l_box)
    box.delete(_p1_m_box)
    float _p1_buf = current_atr * 0.25
    if or_h_zone != "NAKED" and not na(or_h)
        color _hc = or_h_zone == "CLUSTER" ? color.new(#7b2d8b, 72) : color.new(#ff8800, 82)
        _p1_h_box := box.new(left = bar_index - 1, top = or_h + _p1_buf, right = _box_right, bottom = or_h - _p1_buf, border_color = color.new(color.gray, 80), bgcolor = _hc, border_width = 1)
    if or_l_zone != "NAKED" and not na(or_l)
        color _lc = or_l_zone == "CLUSTER" ? color.new(#7b2d8b, 72) : color.new(#ff8800, 82)
        _p1_l_box := box.new(left = bar_index - 1, top = or_l + _p1_buf, right = _box_right, bottom = or_l - _p1_buf, border_color = color.new(color.gray, 80), bgcolor = _lc, border_width = 1)
    if or_m_zone != "NAKED" and not na(or_mid)
        color _mc = or_m_zone == "CLUSTER" ? color.new(#7b2d8b, 72) : color.new(#ff8800, 82)
        _p1_m_box := box.new(left = bar_index - 1, top = or_mid + _p1_buf, right = _box_right, bottom = or_mid - _p1_buf, border_color = color.new(color.gray, 80), bgcolor = _mc, border_width = 1)
    if show_coloc_zone and support_coloc
        float  _anchor    = or_l
        float  _pvwap_val = not na(prev_vwap) ? prev_vwap : _anchor
        float  _va_val    = svp_track_dev and not na(svp_today_val) ? svp_today_val : svp_ready and not na(svp_yday_val) ? svp_yday_val : _anchor
        float  _zone_top  = math.max(or_l, math.max(orl_pvwap_coloc ? _pvwap_val : _anchor, val_orl_coloc ? _va_val : _anchor))
        float  _zone_bot  = math.min(or_l, math.min(orl_pvwap_coloc ? _pvwap_val : _anchor, val_orl_coloc ? _va_val : _anchor))
        color  _zone_col  = support_triple ? color.new(#ffd700, 82) : val_orl_coloc ? color.new(#00ffcc, 82) : color.new(#00cccc, 85)
        color  _bdr_col   = support_triple ? color.new(#ffd700, 45) : val_orl_coloc ? color.new(#00ffcc, 40) : color.new(#00cccc, 50)
        int    _cl        = bar_index - math.max(0, bars_since_open - 1)
        if na(_coloc_box_sup)
            _coloc_box_sup := box.new(left=_cl, top=_zone_top, right=_box_right, bottom=_zone_bot, border_color=_bdr_col, bgcolor=_zone_col, border_width=1, border_style=line.style_dashed)
        else
            box.set_top(_coloc_box_sup, _zone_top)
            box.set_bottom(_coloc_box_sup, _zone_bot)
            box.set_right(_coloc_box_sup, _box_right)
            box.set_border_color(_coloc_box_sup, _bdr_col)
            box.set_bgcolor(_coloc_box_sup, _zone_col)
    else if not na(_coloc_box_sup)
        box.delete(_coloc_box_sup)
        _coloc_box_sup := na
    if show_coloc_zone and resist_coloc
        float  _anchor    = or_h
        float  _pvwap_val = not na(prev_vwap) ? prev_vwap : _anchor
        float  _va_val    = svp_track_dev and not na(svp_today_vah) ? svp_today_vah : svp_ready and not na(svp_yday_vah) ? svp_yday_vah : _anchor
        float  _zone_top  = math.max(or_h, math.max(orh_pvwap_coloc ? _pvwap_val : _anchor, vah_orh_coloc ? _va_val : _anchor))
        float  _zone_bot  = math.min(or_h, math.min(orh_pvwap_coloc ? _pvwap_val : _anchor, vah_orh_coloc ? _va_val : _anchor))
        color  _zone_col  = resist_triple ? color.new(#ffd700, 82) : vah_orh_coloc ? color.new(#ff8800, 82) : color.new(#ffaa00, 88)
        color  _bdr_col   = resist_triple ? color.new(#ffd700, 45) : vah_orh_coloc ? color.new(#ff8800, 45) : color.new(#ffaa00, 55)
        int    _cl        = bar_index - math.max(0, bars_since_open - 1)
        if na(_coloc_box_res)
            _coloc_box_res := box.new(left=_cl, top=_zone_top, right=_box_right, bottom=_zone_bot, border_color=_bdr_col, bgcolor=_zone_col, border_width=1, border_style=line.style_dashed)
        else
            box.set_top(_coloc_box_res, _zone_top)
            box.set_bottom(_coloc_box_res, _zone_bot)
            box.set_right(_coloc_box_res, _box_right)
            box.set_border_color(_coloc_box_res, _bdr_col)
            box.set_bgcolor(_coloc_box_res, _zone_col)
    else if not na(_coloc_box_res)
        box.delete(_coloc_box_res)
        _coloc_box_res := na

float htf_offset_val = current_atr * htf_label_offset

var label _h15_top_lbl = na
var label _h15_bot_lbl = na
var label _h30_top_lbl = na
var label _h30_bot_lbl = na
if is_new_day
    label.delete(_h15_top_lbl)
    _h15_top_lbl := na
    label.delete(_h15_bot_lbl)
    _h15_bot_lbl := na
    label.delete(_h30_top_lbl)
    _h30_top_lbl := na
    label.delete(_h30_bot_lbl)
    _h30_bot_lbl := na

if h15_top_sweep and is_today
    label.delete(_h15_top_lbl)
    _h15_top_lbl := label.new(bar_index, high + htf_offset_val, "×", style=label.style_none, textcolor=#ff2244, size=size.small)
if h15_bot_sweep and is_today
    label.delete(_h15_bot_lbl)
    _h15_bot_lbl := label.new(bar_index, low  - htf_offset_val, "×", style=label.style_none, textcolor=#00bb66, size=size.small)
if h30_top_sweep and is_today
    label.delete(_h30_top_lbl)
    _h30_top_lbl := label.new(bar_index, high + htf_offset_val, "×", style=label.style_none, textcolor=#ff2244, size=size.normal)
if h30_bot_sweep and is_today
    label.delete(_h30_bot_lbl)
    _h30_bot_lbl := label.new(bar_index, low  - htf_offset_val, "×", style=label.style_none, textcolor=#00bb66, size=size.normal)

type ExecHudCtx
    bool  or_set
    float or_h
    float or_l
    int   ist_h
    int   ist_m
    int   ist_t
    float or_eff_end_val
    int   or_cross_dir
    int   or_break_dir
    string break_t_str
    string or_quality
    string or_vol_tag
    string candle_anchor
    string retest_status
    int   stored_brk_score
    bool  stored_score_vol
    bool  stored_score_body
    bool  stored_score_atr
    bool  stored_score_vwp
    int   stored_score_rmi
    int   stored_score_rsi          // -1=RSI penalty, 0=neutral
    int   stored_score_poc          // +1=POC confirms, -1=contradicts, 0=neutral
    bool  stored_anchor_contradiction
    int   bars_inside_or
    int   consecutive_inside
    bool  auto_mode
    bool  is_expiry
    int   tf
    float r_close
    float dynamic_step
    bool  _use_ext_gap
    float _u_vwap
    float vwap_val
    float _u_close
    float implied_pts
    bool  use_vix
    string vix_state
    float vix_anchor_price
    bool  _show_weekly_bands
    float _weekly_implied_pts
    bool  is_equity_mode
    float smt_zscore
    color smt_col
    bool  smt_bear_pdh
    bool  smt_bull_pdl
    float or_close_rmi
    float _rmi_val
    string _rmi_dir
    int   _rmi_abs
    bool  _rmi_ob
    bool  _rmi_os
    float mintick
    string d_ema21_bias
    float d_ema21
    bool  d_above_ema21
    float w_vwap
    float d_rsi14
    string d_rsi_state
    float h_avg
    float tod_rvol
    bool  tod_rvol_anomaly
    float tod_threshold
    bool  _using_proxy
    float or_vol_ratio
    float _h_avg_proxy
    string active_fvg_dir
    float active_fvg_top
    float active_fvg_bot

f_get_session_phase(int t, float or_eff_end) =>
    t >= SESSION_OPEN and t < or_eff_end ? "Phase 1" : t >= or_eff_end and t < DEAD_ZONE_START ? "Phase 2" : t >= DEAD_ZONE_START and t < PM_START ? "Dead Zone" : t >= PM_START and t < PHASE4_START ? "Phase 3" : t >= PHASE4_START and t <= SESSION_CLOSE ? "Phase 4" : "Closed"

f_get_session_quality(int t, float or_eff_end) =>
    t >= or_eff_end and t < 1015 ? " · Prime" : (t >= 1015 and t < 1100) or (t >= PM_START and t < PHASE4_START) ? " · Standard" : t >= 1100 and t < DEAD_ZONE_START ? " · Low" : t >= PHASE4_START ? " · Noise" : ""

f_get_exec_hud_strings(ExecHudCtx ctx) =>
    int end_h    = math.floor(ctx.or_eff_end_val / 100)
    int end_m    = int(ctx.or_eff_end_val) % 100
    int mins_left = (end_h * 60 + end_m) - (ctx.ist_h * 60 + ctx.ist_m)
    string forming_str = "Forming [" + str.tostring(math.max(0, mins_left)) + "m]"
    string dot_vol  = ctx.stored_score_vol  ? "●" : "○"
    string dot_body = ctx.stored_score_body ? "●" : "○"
    string dot_atr  = ctx.stored_score_atr  ? "●" : "○"
    string dot_vwp  = ctx.stored_score_vwp  ? "●" : "○"
    string dot_rmi  = ctx.stored_score_rmi > 0 ? "●" : ctx.stored_score_rmi < 0 ? "⊗" : "○"
    string dot_rsi  = ctx.stored_score_rsi < 0 ? "⊗" : "○"
    string dot_poc  = ctx.stored_score_poc > 0 ? "●" : ctx.stored_score_poc < 0 ? "⊗" : "○"
    string score_dots  = dot_vol + dot_body + dot_atr + dot_vwp + dot_rmi + dot_rsi + dot_poc
    string score_grade = ctx.stored_brk_score >= 5 ? " Max Conviction" : ctx.stored_brk_score >= 4 ? " Strong" : ctx.stored_brk_score >= 2 ? " Weak" : ctx.stored_brk_score < 0 ? " Exhaustion ⚠" : ""
    string rmi_detail  = ctx.stored_score_rmi > 0 ? "✓" : ctx.stored_score_rmi < 0 ? "⊗" : "○"
    string poc_detail  = ctx.stored_score_poc > 0 ? "✓" : ctx.stored_score_poc < 0 ? "⊗" : "○"
    string score_detail = " [Vol" + (ctx.stored_score_vol ? "✓" : "○") + " Body" + (ctx.stored_score_body ? "✓" : "○") + " ATR" + (ctx.stored_score_atr ? "✓" : "○") + " VWP" + (ctx.stored_score_vwp ? "✓" : "○") + " RMI" + rmi_detail + " RSI" + (ctx.stored_score_rsi < 0 ? "⊗" : "○") + " POC" + poc_detail + "]"
    string brk_score_str = ctx.stored_brk_score != 0 ? "\n" + score_dots + score_grade + score_detail : ""
    string contradiction_tag = ctx.stored_anchor_contradiction ? " ⚡" : ""
    string or_state_txt = not ctx.or_set ? forming_str : (ctx.or_cross_dir == 1 and ctx.or_break_dir != 1) ? "Testing UP ⏳" : (ctx.or_cross_dir == -1 and ctx.or_break_dir != -1) ? "Testing DN ⏳" : (ctx.or_break_dir == 1) ? "Broke UP" + ctx.break_t_str + ctx.or_quality + ctx.or_vol_tag + ctx.candle_anchor + ctx.retest_status + brk_score_str + contradiction_tag : (ctx.or_break_dir == -1) ? "Broke DN" + ctx.break_t_str + ctx.or_quality + ctx.or_vol_tag + ctx.candle_anchor + ctx.retest_status + brk_score_str + contradiction_tag : "Inside [" + str.tostring(ctx.bars_inside_or) + "]" + (ctx.consecutive_inside >= 3 ? " · Compressed [" + str.tostring(ctx.consecutive_inside) + "]" : "")
    string _mode_tag = ctx.auto_mode ? " ⚡" : ""
    string header_txt = ctx.is_expiry ? "⚡ Expiry [" + str.tostring(ctx.tf) + "m]" : "IntraEdge v" + INTRAEDGE_VERSION + " [" + str.tostring(ctx.tf) + "m]" + _mode_tag
    float  atm        = math.round(ctx.r_close / ctx.dynamic_step) * ctx.dynamic_step
    float  _ref_vwap  = ctx._use_ext_gap ? ctx._u_vwap  : ctx.vwap_val
    float  _ref_close = ctx._use_ext_gap ? ctx._u_close : ctx.r_close
    float  vwap_dist     = _ref_close - _ref_vwap
    float  vwap_dist_pct = ctx.implied_pts > 0 ? (math.abs(vwap_dist) / ctx.implied_pts) * 100 : 0
    string vwap_dist_txt = (vwap_dist > 0 ? "+" : "") + str.tostring(vwap_dist, "#") + " pts (" + str.tostring(vwap_dist_pct, "#") + "%)" + (vwap_dist_pct > 70 ? " ⚠" : "")
    color vwap_dist_col = vwap_dist >= 0 ? color.green : color.red
    string session_phase = f_get_session_phase(ctx.ist_t, ctx.or_eff_end_val)
    color  session_col   = ctx.ist_t >= SESSION_OPEN  and ctx.ist_t < DEAD_ZONE_START ? color.blue : ctx.ist_t >= DEAD_ZONE_START and ctx.ist_t < PM_START ? color.gray : color.orange
    string session_quality = f_get_session_quality(ctx.ist_t, ctx.or_eff_end_val)
    string session_txt = session_phase + session_quality + (ctx.ist_t >= 1130 and ctx.ist_t < DEAD_ZONE_START ? " · DZ in " + str.tostring(math.max(0, 12 * 60 - (ctx.ist_h * 60 + ctx.ist_m))) + "m" : ctx.ist_t >= DEAD_ZONE_START and ctx.ist_t < PM_START ? " · PM in " + str.tostring(math.max(0, 13 * 60 + 30 - (ctx.ist_h * 60 + ctx.ist_m))) + "m" : ctx.ist_t >= 1500 and ctx.ist_t <= SESSION_CLOSE ? " · Closes in " + str.tostring(math.max(0, 15 * 60 + 30 - (ctx.ist_h * 60 + ctx.ist_m))) + "m" : "")
    string vix_hud_txt = ctx.use_vix ? ctx.vix_state + " | " + str.tostring(int(math.round(ctx.vix_anchor_price - ctx.implied_pts))) + " - " + str.tostring(int(math.round(ctx.vix_anchor_price + ctx.implied_pts))) + (ctx._show_weekly_bands ? " | W: " + str.tostring(int(math.round(ctx.vix_anchor_price - ctx._weekly_implied_pts))) + "-" + str.tostring(int(math.round(ctx.vix_anchor_price + ctx._weekly_implied_pts))) : "") : "N/A (Disabled)"
    string div_name_bull  = ctx.is_equity_mode ? "Rel. Strength ▲"    : "Bullish SMT"
    string div_name_bear  = ctx.is_equity_mode ? "Rel. Weakness ▼"    : "Bearish SMT"
    string div_name_flat  = ctx.is_equity_mode ? "Correlated to Index" : "Correlated"
    string _zscore_sign   = ctx.is_equity_mode ? "" : (ctx.smt_zscore > 0 ? "+" : (ctx.smt_zscore < 0 ? "-" : ""))
    string _zscore_body   = "  " + _zscore_sign + str.tostring(math.abs(ctx.smt_zscore), "#.#") + "σ"
    string smt_zscore_str = math.abs(ctx.smt_zscore) >= 1.0 ? _zscore_body : ""
    string smt_mag_label  = math.abs(ctx.smt_zscore) >= 2.0 ? " (Severe)" : math.abs(ctx.smt_zscore) >= 1.5 ? " (Strong)" : ""
    string _smt_entry     = smt_zscore_str + smt_mag_label
    string smt_status_v23 = ctx.smt_bear_pdh ? div_name_bear + _smt_entry : ctx.smt_bull_pdl ? div_name_bull + _smt_entry : div_name_flat
    color  smt_col_v23    = math.abs(ctx.smt_zscore) >= 2.0 ? #ffee00 : ctx.smt_col
    string _rmi_consec_str = ctx._rmi_abs > 0 ? "  " + ctx._rmi_dir + str.tostring(ctx._rmi_abs) : ""
    string _rmi_disp_val = ctx.or_set and not na(ctx.or_close_rmi) ? str.tostring(math.round(ctx.or_close_rmi, 1)) + (ctx.or_close_rmi >= 70 ? " OB ⚠" : ctx.or_close_rmi <= 30 ? " OS ⚠" : " Neutral") + _rmi_consec_str : str.tostring(math.round(ctx._rmi_val, 1)) + (ctx._rmi_ob ? " OB" : ctx._rmi_os ? " OS" : "") + _rmi_consec_str
    color _rmi_disp_col  = (ctx.or_set and not na(ctx.or_close_rmi)) ? (ctx.or_close_rmi >= 70 ? #ff2244 : ctx.or_close_rmi <= 30 ? #00ff88 : color.silver) : (ctx._rmi_ob ? #ff2244 : ctx._rmi_os ? #00ff88 : color.silver)
    string tod_rvol_str  = ctx.tod_rvol > 0 ? str.tostring(math.round(ctx.tod_rvol), "#") + "%" : "--"
    string tod_anom_str  = ctx.tod_rvol_anomaly ? " ▲ Anomaly" : (ctx.tod_rvol >= ctx.tod_threshold * 0.7 ? " Elevated" : " Normal")
    string _tod_label = ctx.h_avg > 0 ? "ToD RVOL: " : (ctx._using_proxy ? "Basic RVOL: " : "ToD RVOL: ")
    string _tod_sfx   = ctx.h_avg > 0 ? tod_anom_str  : (ctx._using_proxy ? " (proxy)" : "Warming Up")
    string _fused_txt = ctx.h_avg > 0 ? "ToD " + tod_rvol_str + tod_anom_str + " | OR: " + str.tostring(ctx.or_vol_ratio, "#.#") + "×" : "Warming Up"
    string _tod_main = ctx._h_avg_proxy > 0 ? _tod_label + tod_rvol_str + _tod_sfx : "ToD RVOL: Warming Up"
    string _fvg_hud_txt = ctx.active_fvg_dir == "None" or na(ctx.active_fvg_top) ? "No Active 1H FVG" : ctx.active_fvg_dir + " (" + str.tostring(ctx.active_fvg_bot, "#") + "–" + str.tostring(ctx.active_fvg_top, "#") + ")"
    color  _fvg_hud_col = ctx.active_fvg_dir == "BULL FVG" ? #00ff88 : ctx.active_fvg_dir == "BEAR FVG" ? #ff4466 : color.silver

    [header_txt, atm, or_state_txt, vwap_dist_txt, vwap_dist_col, session_txt, session_col, vix_hud_txt, smt_status_v23, smt_col_v23, _rmi_disp_val, _rmi_disp_col, _fused_txt, _tod_main, _fvg_hud_txt, _fvg_hud_col]




f_set_managed_lbl(8, nc15_bearish, "high", 0.5, "↓", #ff4466, "small")
f_set_managed_lbl(9, nc15_bullish, "low", 0.5, "↑", #00bb66, "small")
f_set_managed_lbl(10, nc30_bearish, "high", 0.5, "↓", #ff4466, "normal")
f_set_managed_lbl(11, nc30_bullish, "low", 0.5, "↑", #00bb66, "normal")
f_set_managed_lbl(12, ibc15, "low", 0.5, "○", #ffee00, "small")
f_set_managed_lbl(13, ibc30, "low", 0.5, "○", #ffee00, "normal")

f_set_managed_lbl(14, hl_forming and show_hl_lh and not is_double_bottom, "low", 0.0, "·", #00ff88, "small")
f_set_managed_lbl(15, lh_forming and show_hl_lh and not is_double_top, "high", 0.0, "·", #ff4466, "small")

f_set_managed_lbl(16, vwap_reclaim_retest, "low", 0.5, "▴", #00ff88, "small")
f_set_managed_lbl(17, vwap_reject_retest, "high", 0.5, "▾", #ff4466, "small")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// Phase 8 + HTF: Consolidated 8-Row HUD
bool _is_opt_or_stock = op_mode == "Index Options" or op_mode == "Stock Options" or op_mode == "Stocks"
bool _render_main_hud = show_main_hud == "Always On" or show_main_hud == "Minimalist" ? true : show_main_hud == "Always Off" ? false : not _is_opt_or_stock
bool _is_minimalist   = show_main_hud == "Minimalist"

var table status_tbl = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 60), border_width=1)

f_render_htf_hud() =>
    string adr_txt   = str.tostring(adr_used_pct, "#.#") + "% " + (adr_used_pct > 85 ? "Exhausted ⚠" : adr_used_pct > 60 ? "Elevated" : "Normal")
    color  adr_col   = adr_used_pct > 85 ? color.red : color.aqua
    string _htf_tf_label = timeframe.isdaily ? "Daily" : timeframe.isweekly ? "Weekly" : timeframe.ismonthly ? "Monthly" : str.tostring(timeframe.multiplier) + "H"
    table.cell(status_tbl, 0, 0, "HTF Matrix: " + _htf_tf_label, text_color=color.white, text_size=size.small, bgcolor=hud_header_col)
    table.merge_cells(status_tbl, 0, 0, 1, 0)
    table.cell(status_tbl, 0, 1, "Macro Bias", text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 1, (d_above_ema21 ? "Bullish" : "Bearish"), text_color=(d_above_ema21 ? color.green : color.red), text_size=size.small)
    table.cell(status_tbl, 0, 2, "W VWAP", text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 2, (close > w_vwap ? "Above" : "Below"), text_color=(close > w_vwap ? color.green : color.red), text_size=size.small)
    table.cell(status_tbl, 0, 3, "VIX Range", text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 3, vix_state, text_color=vix_col, text_size=size.small)
    table.cell(status_tbl, 0, 4, "ADR Used", text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 4, adr_txt, text_color=adr_col, text_size=size.small)
    table.cell(status_tbl, 0, 5, "1H FVG", text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 5, (active_fvg_dir == "None" ? "None" : active_fvg_dir), text_color=(active_fvg_dir == "BULL FVG" ? color.green : active_fvg_dir == "BEAR FVG" ? color.red : color.silver), text_size=size.small)
    string _npoc_source = svp_ready ? "" : " [proxy]"
    string _npoc_txt = not na(prev_poc) ? str.tostring(prev_poc, "#.##") + _npoc_source : "N/A"
    table.cell(status_tbl, 0, 6, "nPOC",    text_color=color.silver, text_size=size.small)
    table.cell(status_tbl, 1, 6, _npoc_txt, text_color=color.new(color.fuchsia, 0), text_size=size.small)

f_get_vwap_zone_txt(float r_c, float u2, float d2, float vh, float vl, bool at_poc) =>
    r_c > u2 ? "Exhausted ▲" : r_c > vh ? "Trending ▲" : r_c < d2 ? "Exhausted ▼" : r_c < vl ? "Trending ▼" : at_poc ? "At POC" : "Value Area"

f_render_exec_hud(ExecHudCtx ctx) =>
    string adr_txt   = str.tostring(adr_used_pct, "#.#") + "% " + (adr_used_pct > 85 ? "Exhausted ⚠" : adr_used_pct > 60 ? "Elevated" : "Normal")
    [header_txt, atm, or_state_txt, vwap_dist_txt, vwap_dist_col, session_txt, session_col, vix_hud_txt, smt_status_v23, smt_col_v23, _rmi_disp_val, _rmi_disp_col, _fused_txt, _tod_main, _fvg_hud_txt, _fvg_hud_col] = f_get_exec_hud_strings(ctx)
    string _c1_gap = gap_strat + " (" + (ctx._use_ext_gap ? "Idx " : "") + gap_type + " " + str.tostring(gap_pct, "#.##") + "%)"
    string _c2_vol = "VIX: " + vix_state + " | ADR: " + adr_txt
    string _c3_or_state = or_state_txt
    if or_set
        string _p1_h_txt = "H: " + or_h_zone
        string _p1_l_txt = "L: " + or_l_zone
        string _sup_tag = support_triple  ? " ⚓L:VA+pV" : val_orl_coloc   ? " ⚓L+VA"    : orl_pvwap_coloc ? " ⚓L+pV"    : ""
        string _res_tag = resist_triple   ? " ⚓H:VA+pV" : vah_orh_coloc   ? " ⚓H+VA"    : orh_pvwap_coloc ? " ⚓H+pV"    : ""
        string _coloc_tag = _sup_tag + _res_tag
        _c3_or_state := or_state_txt + " | " + _p1_h_txt + "  " + _p1_l_txt + _coloc_tag
        
    float _va_high_z = svp_ready and not na(svp_today_vah) ? svp_today_vah : vwap_up1
    float _va_low_z  = svp_ready and not na(svp_today_val) ? svp_today_val : vwap_dn1
    bool _at_yday_poc = svp_ready and not na(svp_yday_poc) and math.abs(r_close - svp_yday_poc) <= current_atr * 0.25
    string _vwap_zone_txt = f_get_vwap_zone_txt(r_close, vwap_up2, vwap_dn2, _va_high_z, _va_low_z, _at_yday_poc)
    string _c4_vwap = vwap_dist_txt + " (" + _vwap_zone_txt + ") | " + (ctx.or_set ? _tod_main : _fused_txt)
    string _c5_inst = smt_status_v23 + " | FVG: " + _fvg_hud_txt + " | RMI: " + _rmi_disp_val
    string _carry_txt  = carry_bias + _tight_tag
    string _c6_breadth = p10_hud_txt + " | Basis: " + p12_hud_txt + " | " + _carry_txt
    string _c7_flow    = "Vel: " + p10_vel_hud_txt + " | Div: " + p10_div_hud_txt
    string _c8_tape    = tape_txt + tape_reason + " | HTF: " + p10_htf_hud_txt
    if bars_since_w <= 5 or bars_since_m <= 5
        string _mw_tag = ""
        if bars_since_w <= 5
            _mw_tag += " | W @ " + last_w_conf
        if bars_since_m <= 5
            _mw_tag += " | M @ " + last_m_conf
        _c8_tape += _mw_tag

    if _is_minimalist
        for _row = 1 to 9
            table.cell(status_tbl, 0, _row, "")
            table.cell(status_tbl, 1, _row, "")
        string _min_txt = tape_txt + tape_reason + " | Bias: " + (ctx.d_above_ema21 ? "Bull" : "Bear") + " | " + smt_status_v23
        table.cell(status_tbl, 0, 0, "IntraEdge", text_color=color.white, text_size=size.small, bgcolor=hud_header_col)
        table.cell(status_tbl, 1, 0, _min_txt, text_color=tape_val_col, text_size=size.small)
    else
        table.cell(status_tbl, 0, 0, header_txt, text_color=color.white, text_size=size.small, bgcolor=ctx.is_expiry ? color.new(#ff6600, 20) : hud_header_col)
        table.merge_cells(status_tbl, 0, 0, 1, 0)
        table.cell(status_tbl, 0, 1, "Gap Strat", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 1, _c1_gap, text_color=strat_col, text_size=size.small)
        table.cell(status_tbl, 0, 2, "Vol/ADR", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 2, _c2_vol, text_color=color.white, text_size=size.small)
        table.cell(status_tbl, 0, 3, "OR State", text_color=color.silver, text_size=size.small)
        color or_state_col = not ctx.or_set ? color.silver : (ctx.or_cross_dir == 1 and ctx.or_break_dir != 1) ? color.yellow : (ctx.or_cross_dir == -1 and ctx.or_break_dir != -1) ? color.yellow : (ctx.or_break_dir == 1) ? #00ff88 : (ctx.or_break_dir == -1) ? #ff4466 : color.silver
        table.cell(status_tbl, 1, 3, _c3_or_state, text_color=or_state_col, text_size=size.small)
        table.cell(status_tbl, 0, 4, "VWAP/Vol", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 4, _c4_vwap, text_color=color.white, text_size=size.small)
        table.cell(status_tbl, 0, 5, "Inst/SMT", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 5, _c5_inst, text_color=smt_col_v23, text_size=size.small)
        table.cell(status_tbl, 0, 6, "Breadth", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 6, _c6_breadth, text_color=p10_hud_col, text_size=size.small)
        table.cell(status_tbl, 0, 7, "Flow", text_color=color.silver, text_size=size.small)
        table.cell(status_tbl, 1, 7, _c7_flow, text_color=p10_vel_hud_col, text_size=size.small)
        if show_trend_tape
            table.cell(status_tbl, 0, 8, "Tape/Align", text_color=color.silver, text_size=size.small)
            table.cell(status_tbl, 1, 8, _c8_tape, text_color=tape_val_col, text_size=size.small)
        if svp_track_dev and not na(svp_today_poc)
            string _cluster_tag = poc_volume_cluster ? " [" + cluster_type_name + " ⚓]" : ""
            string _retest_pend = ""
            if poc_crossed_up
                _retest_pend := not poc_retest_up_done ? " (Retest Pend)" : ""
            else if poc_crossed_dn
                _retest_pend := not poc_retest_dn_done ? " (Retest Pend)" : ""
            
            string _poc_time_tag = poc_cross_t_str != "" ? " @ " + poc_cross_t_str : ""
            string _poc_row_txt = "Dir: " + poc_migration_dir + " (" + poc_regime_tag + ")" + _poc_time_tag + _retest_pend + " | Touches: " + str.tostring(poc_touch_count) + _cluster_tag
            color _poc_row_col = (poc_migration_dir == "↑↑" or poc_migration_dir == "↑") ? #00ff88 : (poc_migration_dir == "↓↓" or poc_migration_dir == "↓") ? #ff4466 : color.white
            table.cell(status_tbl, 0, 9, "POC Engine", text_color=color.silver, text_size=size.small)
            table.cell(status_tbl, 1, 9, _poc_row_txt, text_color=_poc_row_col, text_size=size.small)

f_build_hud_ctx() =>
    ExecHudCtx.new(or_set, or_h, or_l, ist_h, ist_m, ist_t, or_eff_end_val, or_cross_dir, or_break_dir, break_t_str, or_quality, or_vol_tag, candle_anchor, retest_status, stored_brk_score, stored_score_vol, stored_score_body, stored_score_atr, stored_score_vwp, stored_score_rmi, stored_score_rsi, stored_score_poc, stored_anchor_contradiction, bars_inside_or, consecutive_inside, auto_mode, is_expiry, tf, r_close, dynamic_step, _use_ext_gap, _u_vwap, vwap_val, _u_close, implied_pts, use_vix, vix_state, vix_anchor_price, _show_weekly_bands, _weekly_implied_pts, is_equity_mode, smt_zscore, smt_col, smt_bear_pdh, smt_bull_pdl, or_close_rmi, _rmi_val, _rmi_dir, _rmi_abs, _rmi_ob, _rmi_os, syminfo.mintick, d_ema21_bias, d_ema21, d_above_ema21, w_vwap, d_rsi14, d_rsi_state, h_avg, tod_rvol, tod_rvol_anomaly, tod_threshold, _using_proxy, or_vol_ratio, _h_avg_proxy, active_fvg_dir, active_fvg_top, active_fvg_bot)

if barstate.islast and _render_main_hud
    if is_htf_chart
        f_render_htf_hud()
    else
        f_render_exec_hud(f_build_hud_ctx())






// ── Alerts ──
// Fix M9: barstate.isconfirmed gates both VIX cross conditions.
// ta.crossover/crossunder evaluate on every tick in TradingView's alert engine.
// Without confirmation, a gap-open bar that touches the VIX ceiling intrabar then
// closes inside fires a "VIX Band Touch" alert that the candle never confirmed.
// On Nifty expiry mornings with 100+ pt gap opens this creates repeated phantom alerts
// in the first 2–3 minutes before the 9:15 candle closes.
bool vix_cross_up = ta.crossover(close,  vix_ceiling) and barstate.isconfirmed
bool vix_cross_dn = ta.crossunder(close, vix_floor)   and barstate.isconfirmed

// MINOR-5 FIX: barstate.isconfirmed added — consistent with VIX Band Touch and Delta
// Divergence alert gates. trap_up_signal depends on trap_qual_up = close[1] < open[1]
// which references the prior bar and does not change intrabar, but the outer condition
// also includes bars_since_break_up <= 5 and trap_up_cooldown == 0 which can momentarily
// be true intrabar before the cooldown assignment fires. Explicit confirmation gate
// ── PHASE 7: Macro-Calibrated Alerts ──
// Alerts are now filtered by the same institutional gates as the Trade Engine.
bool alert_bull_ok = bull_allowed and not macro_smt_bear and (na(weekly_vix_ceil) or close < weekly_vix_ceil)
bool alert_bear_ok = bear_allowed and not macro_smt_bull and (na(weekly_vix_floor) or close > weekly_vix_floor)

alertcondition((trap_up_signal or trap_dn_signal) and barstate.isconfirmed,   "Trap Detected",          "{{ticker}}: OR Break Trap — Failed breakout detected")
alertcondition(((first_break_up and alert_bull_ok) or (first_break_dn and alert_bear_ok)) and barstate.isconfirmed, "OR Breakout", "{{ticker}}: OR Breakout Detected (Macro Aligned)")
alertcondition((or_retest_bull and alert_bull_ok) or (or_retest_bear and alert_bear_ok), "OR Retest",   "{{ticker}}: OR Sniper Retest Confirmed")

// m4 FIX: Add barstate.isconfirmed — vwap_reclaim/reject evaluate live pct_above/below_vwap
// which fluctuates intrabar and would spam alerts on candles that briefly cross VWAP then reverse
alertcondition((vwap_reclaim or vwap_reject or vwap_reclaim_retest or vwap_reject_retest) and barstate.isconfirmed, "VWAP Interaction", "{{ticker}}: VWAP Reclaim, Reject, or Retest")
alertcondition(top_sweep or bot_sweep or h15_top_sweep or h15_bot_sweep or h30_top_sweep or h30_bot_sweep, "Liquidity Sweep", "{{ticker}}: Institutional Liquidity Swept")
alertcondition(hl_forming and not hl_forming[1],                           "Higher Low at Level",    "{{ticker}}: Higher Low structure forming")
alertcondition(lh_forming and not lh_forming[1],                           "Lower High at Level",    "{{ticker}}: Lower High structure forming")

alertcondition(is_double_bottom, "W-Pattern (Double Bottom)", "{{ticker}}: High-Conviction W-Pattern Reversal Detected")
alertcondition(is_double_top, "M-Pattern (Double Top)", "{{ticker}}: High-Conviction M-Pattern Reversal Detected")

// ── v27 NEW ALERTS ──

// [A1] P10 Breadth Divergence — edge trigger fires on the first bar divergence appears.
// Bear div = price up, breadth fading = institutional distribution into retail.
// Bull div = price down, breadth recovering = institutional accumulation.
bool _p10_div_bear_edge = p10_div_bear and not p10_div_bear[1] and barstate.isconfirmed
bool _p10_div_bull_edge = p10_div_bull and not p10_div_bull[1] and barstate.isconfirmed

// ── POC Institutional Alerts (Phase 5) ──
// A1/A2: Today POC Bull/Bear Retest (Successful defense)
alertcondition(poc_bull_retest and not poc_bull_retest[1], "POC Bull Retest", "{{ticker}}: POC Bullish Defense confirmed")
alertcondition(poc_bear_retest and not poc_bear_retest[1], "POC Bear Retest", "{{ticker}}: POC Bearish Defense confirmed")

// A3/A4: POC Failed Bull/Bear Retest (Flip detection)
alertcondition(poc_bull_retest_failed and not poc_bull_retest_failed[1], "POC Failed Bull Retest", "{{ticker}}: POC Bull Defense FAILED - probable flip")
alertcondition(poc_bear_retest_failed and not poc_bear_retest_failed[1], "POC Failed Bear Retest", "{{ticker}}: POC Bear Defense FAILED - probable flip")

// A5/A6: POC Cross-Back (Reversal detection)
alertcondition(poc_crossback_dn and not poc_crossback_dn[1], "POC Cross-Back Down", "{{ticker}}: Price failed POC recovery - cross-back down")
alertcondition(poc_crossback_up and not poc_crossback_up[1], "POC Cross-Back Up", "{{ticker}}: Price failed POC rejection - cross-back up")

// A7: POC Migration Flip (Momentum reversal)
bool _poc_flip_up = poc_migration_dir == "↑" and poc_migration_dir[1] != "↑" and poc_migration_dir[1] != "↑↑"
bool _poc_flip_dn = poc_migration_dir == "↓" and poc_migration_dir[1] != "↓" and poc_migration_dir[1] != "↓↓"
alertcondition(_poc_flip_up or _poc_flip_dn, "POC Migration Flip", "{{ticker}}: Institutional POC migration flip detected")

// A8: POC Breakout Pending (Multi-touch volume depletion)
alertcondition(poc_breakout_pending and not poc_breakout_pending[1], "POC Breakout Pending", "{{ticker}}: Multi-touch volume exhaustion - Breakout likely")
alertcondition(poc_escape_likely and not poc_escape_likely[1], "POC Escape Likely", "{{ticker}}: Multi-touch volume escalation - Escape move likely")

// A9: VWAP Retest at POC
alertcondition(vwap_reclaim_retest_at_poc or vwap_reject_retest_at_poc, "VWAP+POC Retest", "{{ticker}}: High-Conviction VWAP/POC Cluster Retest")

// A10: Breadth Divergence at POC (Addition H)
alertcondition(p10_div_bear_at_poc and not p10_div_bear_at_poc[1], "Breadth Bear Div @ POC", "{{ticker}}: Breadth Diverging (Bearish) at POC")
alertcondition(p10_div_bull_at_poc and not p10_div_bull_at_poc[1], "Breadth Bull Div @ POC", "{{ticker}}: Breadth Diverging (Bullish) at POC")

// A11: POC at VIX Boundary (Addition J)
alertcondition(_poc_vix_conv_edge, "POC VIX Boundary", "{{ticker}}: POC converging with VIX Ceiling/Floor")

// Suggestion 3 & 4 Alerts
alertcondition(poc_cluster_latched and not poc_cluster_latched[1], "POC Cluster Alert", "{{ticker}}: POC Converged with Prior Volume Node (Institutional Alignment)")
alertcondition(poc_breakout_fail and not poc_breakout_fail[1], "POC Volume Trap", "{{ticker}}: Failed POC Breakout - Institutional Trap Confirmed")


alertcondition(_p10_div_bear_edge or _p10_div_bull_edge,


    "Breadth Divergence",
    "{{ticker}}: Breadth diverging from price — check Flow row in HUD for direction")

// [A2] P10 Breadth Velocity Spike — fires when momentum flips to Strong In/Out.
// Leading signal: sectors rotating above/below VWAP in bulk BEFORE score crosses threshold.
bool _p10_vel_spike_in  = p10_velocity_state == "Strong In"  and p10_velocity_state[1] != "Strong In"  and barstate.isconfirmed
bool _p10_vel_spike_out = p10_velocity_state == "Strong Out" and p10_velocity_state[1] != "Strong Out" and barstate.isconfirmed
alertcondition(_p10_vel_spike_in or _p10_vel_spike_out,
    "Breadth Velocity Spike",
    "{{ticker}}: 3+ sectors flipped VWAP side simultaneously — check Flow row in HUD")

// [A3] P2 High-Conviction OR Touch — score ≥7 = CLUSTER confluence + multiple confirming factors.
// Edge trigger: p2_last_score changes only when P2 fires, so != prior bar correctly identifies
// the exact bar the high-score touch was confirmed.
bool _p2_high_conviction = p2_last_score >= 7 and p2_last_score != p2_last_score[1] and barstate.isconfirmed
alertcondition(_p2_high_conviction,
    "OR Level High-Conviction Touch",
    "{{ticker}}: OR level touch scored ≥7 — strong institutional level, check P2 label for detail")

// [A4] P5 Pre-OR Sweep — fires at most once per session, before OR sets.
// PDH/PDL/PrevVWAP sweep in 9:15–9:29 biases the OR break direction opposite to the swept level.
alertcondition(p5_top_sweep or p5_bot_sweep,
    "Pre-OR Sweep Detected",
    "{{ticker}}: Pre-OR institutional sweep — check Pre-OR row in HUD for bias direction")

// [A5] P3 Activity Filter ON — edge trigger fires only on the bar the filter activates.
// Notifies to stop trading the current setup — chop regime detected.
bool _p3_just_activated = p3_filter_active and not p3_filter_active[1] and barstate.isconfirmed
alertcondition(_p3_just_activated,
    "Activity Filter Activated",
    "{{ticker}}: Chop regime detected — tape locked to WAIT, check HUD for conditions")

var bool _adr_alerted = false
if is_new_day
    _adr_alerted := false
bool _fire_adr_alert = adr_used_pct > 90 and not _adr_alerted and barstate.isconfirmed
if _fire_adr_alert
    _adr_alerted := true
alertcondition(_fire_adr_alert,               "ADR Exhausted",          "{{ticker}}: ADR Range 90% exhausted. Cease trend trading.")
alertcondition(vix_cross_up or vix_cross_dn,                               "VIX Band Touch",         "{{ticker}}: Price reached daily VIX expected move")
alertcondition(smt_bear_pdh or smt_bull_pdl,                               "SMT / RS-RW Signal",     "{{ticker}}: Structural divergence detected.")

alertcondition((cvd_bull_div or cvd_bear_div) and barstate.isconfirmed,    "Delta Divergence",       "{{ticker}}: Order Flow Divergence. Heavy limit absorption.")
alertcondition((bot_trap or top_trap) and barstate.isconfirmed,         "Sequenced Trap",         "{{ticker}}: SMT + Sweep confluence trap detected.")

// Numeric state change is the safe pattern for phase transition alerts.
int _new_phase_n = f_expfsm_is_finalhour ? 3 : f_expfsm_is_gamma ? 2 : f_expfsm_is_pinrisk ? 1 : 0
bool _fsm_changed = _new_phase_n != _fsm_phase_n and is_expiry and expiry_fsm_enable
if _fsm_changed
    _fsm_phase_n := _new_phase_n
alertcondition(_fsm_changed and barstate.isconfirmed,
    "Expiry Phase Transition", "{{ticker}}: Expiry phase changed — review positions")
alertcondition(not na(f_expfsm_max_pain_est) and na(f_expfsm_max_pain_est[1]) and barstate.isconfirmed, 
     "Max-Pain Strike Set", "{{ticker}}: Expiry structural pin zone estimate established")

// ── v27 NEW ALERTS ──
// [A8] RMI Regular Bear Divergence
// Price HH + RMI LH — OB zone exhaustion. Fires once on confirmed slope-flip bar.
alertcondition(rmi_div_bear,
    "RMI Regular Bear Divergence",
    "{{ticker}} {{interval}}: RMI Bear Divergence — price HH, RMI LH. OB exhaustion — potential reversal down.")

// [A9] RMI Regular Bull Divergence
// Price LL + RMI HL — OS zone exhaustion. Fires once on confirmed slope-flip bar.
alertcondition(rmi_div_bull,
    "RMI Regular Bull Divergence",
    "{{ticker}} {{interval}}: RMI Bull Divergence — price LL, RMI HL. OS exhaustion — potential reversal up.")

float p_pm_high = show_prev_day_lines and in_market and is_today and (is_4h_gravity or is_macro_trend) ? pm_high : na
float p_pm_low  = show_prev_day_lines and in_market and is_today and (is_4h_gravity or is_macro_trend) ? pm_low  : na
float p_pw_vwap = show_prev_day_lines and in_market and is_today and (is_4h_gravity or is_macro_trend) ? pw_vwap : na

f_lbl(in_market and (is_4h_gravity or is_macro_trend), pm_high, "M High", #6a1b9a, color.white)
f_lbl(in_market and (is_4h_gravity or is_macro_trend), pm_low,  "M Low",  #6a1b9a, color.white)
f_lbl(in_market and (is_4h_gravity or is_macro_trend), pw_vwap, "PW VWAP", #7b1fa2, color.white)

// SVP warmup warning — fires only on first session after indicator load
if not svp_ready and session.isfirstbar and barstate.isconfirmed and is_today
    label.new(bar_index, high + current_atr * 2,
        "SVP Warming Up — POC/VAH/VAL available from tomorrow",
        style     = label.style_label_down,
        color     = color.new(#ff8800, 20),
        textcolor = color.white,
        size      = size.small)

// ── Quality-Decorated POC Retest Labels (Phase 4-B) ──
if show_poc_labels and (poc_bull_retest or poc_bear_retest) and is_today and is_micro_execution
    string _poc_lbl_txt = (poc_bull_retest ? "POC BULL TEST " : "POC BEAR TEST ") + 
                          poc_alert_suffix + 
                          (poc_volume_cluster ? " +" + cluster_type_name : "") +
                          (_use_ext_gap ? " (Theta Skewed)" : "")

    color _poc_lbl_col = poc_bull_retest ? color.new(#00ff88, 20) : color.new(#ff4466, 20)
    if poc_bull_retest
        f_set_managed_lbl_shape(18, true, "low", 0.0, _poc_lbl_txt, _poc_lbl_col, color.white, "up", "small")
    else
        f_set_managed_lbl_shape(19, true, "high", 0.0, _poc_lbl_txt, _poc_lbl_col, color.white, "down", "small")

// ── Suggestion 4: Volume Trap Indicator ──
if poc_breakout_fail and not poc_breakout_fail[1] and is_today
    poc_trap_lbl := label.new(bar_index, high + current_atr * 0.4, "⊠", 
              style=label.style_none, 
              textcolor=#ff8800, 
              size=size.normal)
````
