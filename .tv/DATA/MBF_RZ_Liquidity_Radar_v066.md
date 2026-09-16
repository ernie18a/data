<!-- tradingview-pine-id: PUB;f69e5059e9f3435985816f8ca2ed1a95 -->
<!-- tradingview-pine-version: 15.0 -->
<!-- tradingviewscripts-format: 1 -->
# MBF & RZ Liquidity Radar v0.6.6

Source: https://www.tradingview.com/script/eWnG3bJU-Liquidity-Radar-Engine-Pools-Sweeps-and-Next-Draw/

## Description

This script answers one question continuously: which pool of resting liquidity was taken most recently, was it reclaimed, and where is price likely being delivered next. It is a context and narration tool, not a signal generator. It never tells you to enter.

**The three pool states — the core idea**

Most liquidity tools mark a level and then delete it the moment price touches it. That throws away the information that matters. Here a pool moves through three distinct states, drawn differently at each:

- **LIVE** — resting, untouched, still a magnet.
- **SWEPT** — taken, but price has not closed back through the origin. The sweep may still fail. Nothing is confirmed yet.
- **RECLAIMED** — taken and price closed back through the origin. This is the completed sweep-and-reclaim, and it is the only state the narration treats as a story worth acting on.

Separating SWEPT from RECLAIMED is the entire point of the script. A sweep without a reclaim is not a setup, and collapsing the two into one "hit" state hides the distinction that decides whether anything happened.

**What it draws**

Pool levels are built from prior-period highs and lows, session extremes, equal highs and lows, and swing pivots, each drawn according to its state. A liquidity glow fades with pool age so stale levels visibly recede rather than cluttering the chart indefinitely. A Next Draw ring marks the nearest unswept pool in the direction of the current higher-timeframe bias — the level price is being pulled toward. A Delivery Map shows where price has been delivered from and to. A narration bar states the current condition in plain words; when it reads that no sweep has happened yet, there is no story and nothing to do.

**The two engines that gate the narration**

Higher-timeframe bias reads structure on a higher timeframe from pivot sequence and reports bullish, bearish, or neutral/choppy. Bias decides which side of a sweep is worth watching. It is a filter, never a position, and it never extends how long anything is held.

Lower-timeframe change-of-character confirms that structure on the entry timeframe has actually shifted after a reclaim. This is the difference between a level being touched and a level being rejected.

Response presets (Fast, Balanced, Strict, Manual) set the pivot left and right bar counts independently, trading detection latency against confirmation lag. This is worth being precise about: the presets change how soon an event is detected. They do not lower what counts as an event. Strict reproduces the original timing exactly.

**Optional breadth**

Advance-decline and TICK feeds can be requested to flag exhaustion. These require the relevant index symbols on your data plan. Without them the breadth row reads unavailable and everything else continues to work normally.

**Using it with the sequence engine**

This script publishes five numbered plots as an export bridge, intended to be read as external sources by the companion script "Liquidity Sequence Suite — 4-Confirmation Engine". Wiring them lets that script consume this one's pool ledger, next-draw level and bias rather than recomputing them, so both agree on what happened and when. Wire each numbered source to the matching numbered field once. The exports are display-only and cost nothing if unused — this script is fully standalone and needs no companion.

**Limitations and shortcomings — please read**

- Pivot-based structure confirms with lag by definition. A pivot is only a pivot once the required bars to its right exist, so higher-timeframe bias and change-of-character both arrive after the turn, not at it. Faster presets shorten that lag. Nothing removes it.
- Higher-timeframe values update while the higher-timeframe bar is forming. Intrabar bias and change-of-character states are provisional and can change within the bar.
- Prior-period level requests use the standard previous-bar idiom and do not repaint. The pivot requests use no lookahead. Nothing in this script draws a level earlier on history than it could have appeared live.
- Pool detection is capped for performance. On very long histories or very low timeframes the oldest pools are dropped, so panel counts reflect what is tracked rather than everything that ever existed.
- Breadth is optional and depends on your data subscription.
- This is a context tool. It produces no entries, no stops, no targets and no performance claim. It is an indicator, not a strategy.
- Nothing here is financial advice.

**Originality**

Written clean-room from a written specification of publicly described concepts — resting liquidity above highs and below lows, sweeps, reclaims, equal highs and lows, session and prior-period levels. No third-party source was consulted or adapted. All code is original.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  MBF & RZ LIQUIDITY RADAR  --  v0.6.0b (2026-09-06)  --  CLEAN REWRITE
//  0.6.0b: sweep tags are small plain text; WAIT names a trend day (pools breaking, not sweeping).
//  0.6.1: TREND row and LIKELY PATH. Trend = chart structure (last two swings
//         by pivot: HH+HL up, LH+LL down), plus HTF bias, plus the direction
//         pools are breaking. Two of three agree = a trend; otherwise MIXED.
//         Likely path = the next two untouched pools in the trend direction.
//         Delivery Map header now says STRONGEST; the chart marker says
//         NEAREST DRAW, so the two stop looking like a disagreement.
//  0.6.2: trend is a MAJORITY of the three votes (two up = UP). The nearest
//         draw marker follows the Trend, not the 60m bias alone. The Break
//         row is blank when there is no story. Trend reasoning lives in a
//         hover tooltip so the panel stays narrow.
//  0.6.3: when a story is live, Likely is the story's path (target, then the
//         next pool beyond it), not the trend fallback. A fresh side whose
//         bars-to-target exceed your clock reads "past your clock, use the
//         1m trigger" in the Do row instead of "go".
//  0.6.4: intrabar, a stop on the wrong side of price reads "stop being
//         tested, ends on a close through" with no reward number. New-day
//         reset uses the Timezone input, not the exchange day. A story
//         against the Trend row says so.
//  0.6.5: a fresh side with BOTH bias and trend against it reads "counter-
//         trend scalp only, quarter size, or skip" instead of "go". One
//         opposing vote = half size (unchanged). Never a veto after arm.
//  0.6.6: the chart marker is the first level of the Likely path — the same
//         number as the panel — labelled NEXT DRAW. The old nearest-with-bias-
//         override marker could disagree with the Trend and Likely rows.
//  0.6.7: STORYTELLER OVERLAP FIX (display only, 2026-09-10). The live line
//         concatenated every clause every time (state+target+stop+reward+ETA+
//         bias+your-position+pools-passed+carried-over) into one table cell.
//         Pine tables never wrap, they only grow, so the bar routinely spanned
//         wide/tall enough to plow into the LIQUIDITY panel and the ULTRA
//         STATUS table sitting nearby. New 'Compact storyteller' input
//         (default ON) trims the live line to state+target+stop+the one
//         must-not-drop live-position warning (EXIT / move-to-BE); the
//         numbers are already broken out cleanly in the panel below, so this
//         is not losing information, just not saying it twice. New
//         'Storyteller max characters' input is a hard backstop applied
//         either way, so the line can never grow unbounded again. Journal rows
//         get the same cap at the point they're written. Nothing about
//         detection, the state machine, or any drawn number changed.
// -----------------------------------------------------------------------------
//  DETECTION is v0.5.8, untouched except for two strictness rules:
//    - a sweep must pierce the pool by at least a minimum depth (default
//      0.10 x ATR, floor 2 ticks); a two-cent poke is not a sweep
//    - detection runs on the last N bars only (default 3000)
//  Pools, sweep, reclaim, reject, break, next draw, HTF bias, LTF CHoCH and
//  the bridge exports are the v0.5.8 code.
//
//  THE STORY LAYER is written once, from this spec, and nothing in the display
//  computes anything -- it prints fields.
//    starts : a pool is swept (depth qualified). A live story is only taken
//             over by an equal-or-heavier pool. A lighter pool swept on the
//             story's DRAW side is a leg (counted), never a new story.
//    arms   : a body closes back through the swept level inside the window
//             (window scales with the chart: 1m = 3 bars, 5m = 6, 15m = 9),
//             then the lower-timeframe structure break confirms.
//    draw   : the nearest untouched pool on the story side, live every bar.
//    stop   : the swept wick, then the last CONFIRMED higher low / lower high
//             once one exists.
//    ends   : close through the stop -- close through the confirmed HL/LH --
//             close back through the swept level before arming -- window
//             expired -- a heavier pool on the draw side is swept.
//    reads  : WAIT / WATCH / LONG / SHORT / RUNNING / DONE
//             LONG or SHORT is printed only for a fresh entry: R:R at least
//             1.5 to the draw, stop at most 3 x ATR. Otherwise RUNNING.
//    bias   : HTF bias against the story blocks BEFORE arming; after arming
//             it is a note ("half size"), never a veto.
//
//  EVERYTHING ON SCREEN IS PLAIN WORDS. No symbols.
//  Panel: Story / Target / Stop / Do / Pools.  Storyteller: one sentence,
//  journal rows above it.  Chart marker: NEXT DRAW.
//
//  Removed on purpose for this rewrite: counter track, width-gate text on
//  running stories, extension logic, display-time recomputation.
//  Kept: My entry (position in R, against-the-story exit call), journal,
//  new-day reset, direction colours as inputs, timezone input.
//
//  Clean-room notice: written from a written specification of publicly
//  described SMC/ICT concepts. No third-party source was consulted or adapted.
//  Original work (c) MBF & RZ Trading.
// =============================================================================

indicator('MBF & RZ Liquidity Radar v0.6.6', shorttitle='MBF LIQ', overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=100)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
gP = 'Pools — what counts as liquidity'
use_struct  = input.bool(true,  'Structure swings',      group=gP, tooltip='Confirmed swing highs and lows. The bread-and-butter intraday pool.')
use_sess    = input.bool(true,  'Session highs / lows',  group=gP, tooltip='Asia, London and New York extremes. The levels an algo is most likely to run.')
use_prior   = input.bool(true,  'Prior day / week',      group=gP, tooltip='PDH/PDL and PWH/PWL — the highest-conviction pools on the chart.')
use_eq      = input.bool(true,  'Equal highs / lows',    group=gP, tooltip='Two or more pivots within a tolerance band. Stops stack behind these, so they draw price hardest.')
eq_tol_atr  = input.float(0.20, 'Equal-level tolerance (×ATR)', minval=0.05, maxval=1.0, step=0.05, group=gP)
piv_len     = input.int(8, 'Swing length (LEFT bars = significance)', minval=2, maxval=50, group=gP)
// [v0.5.2] ta.pivothigh(src, left, right): LEFT sets how significant a swing must
// be, RIGHT sets how long you WAIT to find out. v0.5.0 used left==right, so an
// 8-bar swing took 8 bars to confirm and the pool did not exist until then. On a
// 1m chart that is an 8-minute blind window before a level can even be swept.
// Cutting only the RIGHT side reduces latency without loosening what counts as a
// swing. Nothing about sweep, reclaim or CHoCH logic is relaxed.
resp_mode_in = input.string('Auto', 'Response Mode', options=['Auto','Turbo','Fast','Balanced','Strict','Manual'], group=gP,
     tooltip='Fast = earliest confirmation, more minor pools (broken ones prune to state 4). Balanced = recommended for 1m-5m scalping. Strict = v0.5.0 behavior (left==right). Manual = use the explicit right-side inputs.')
piv_right_m = input.int(3, 'Manual: chart pivot RIGHT bars', minval=1, maxval=50, group=gP)
int _cs = timeframe.in_seconds(timeframe.period)
string resp_mode = resp_mode_in != 'Auto' ? resp_mode_in : _cs <= 30 ? 'Turbo' : _cs <= 60 ? 'Fast' : 'Balanced'
string chart_role = _cs <= 60 ? 'TRIGGER' : _cs <= 300 ? 'STRUCTURE' : 'BIAS'
bool   is_trigger = chart_role == 'TRIGGER'
int piv_right = resp_mode == 'Turbo' ? 1 : resp_mode == 'Fast' ? 2 : resp_mode == 'Balanced' ? 3 : resp_mode == 'Strict' ? piv_len : piv_right_m

gR = 'Sweep & reclaim'
reclaim_win = input.int(12, 'Reclaim window (bars)', minval=2, maxval=60, group=gR,
     tooltip='After a pool is swept, price has this many bars to close back through it. Past the window the sweep goes stale and stops being a trade premise.')
rj_tol = input.float(0.10, 'Reject test tolerance (×ATR)', minval=0.0, maxval=1.0, step=0.05, group=gR,
     tooltip='How close price must come back to a reclaimed level for the return to count as a test. A test that CLOSES THROUGH the level is acceptance and cancels the story; only a test that closes back on the reclaim side marks the level REJECTED.')
require_body = input.bool(true, 'Reclaim needs a body close', group=gR,
     tooltip='ON: the reclaiming candle must close beyond the pool, not just wick back. OFF: any close back inside counts.')
sweep_min_atr = input.float(0.10, 'Minimum sweep depth (x ATR, floor 2 ticks)', minval=0.0, maxval=1.0, step=0.05, group=gR)
reclaim_auto = input.bool(true, 'Auto reclaim window (1m = 3, 5m = 6, 15m = 9)', group=gR)
int reclaim_eff = not reclaim_auto ? reclaim_win : _cs <= 60 ? 3 : _cs <= 300 ? 6 : _cs <= 900 ? 9 : reclaim_win
show_stale  = input.bool(false, 'Keep stale sweeps drawn', group=gR)

gH = 'Chart hygiene'
hist_bars     = input.int(3000, 'Detection history (bars, 0 = all)', minval=0, maxval=50000, step=500, group=gH)
max_pools     = input.int(40, 'Max pools tracked', minval=10, maxval=80, group=gH,
     tooltip='Hard cap on the pool array. Every per-tick scan is linear in this number, so lowering it is the fastest cure for a slow chart. Was hard-coded at 60.')
redraw_ticks  = input.int(4, 'Redraw after N ticks of price movement', minval=1, maxval=40, group=gH,
     tooltip='Drawing is refreshed on bar close, or once price has moved this many ticks. Raise it if the chart still feels heavy. Detection and alerts are never throttled.')
draw_per_side = input.int(4, 'Untouched pools drawn per side', minval=1, maxval=20, group=gH,
     tooltip='Only the N nearest untouched pools above and below price are drawn. Every pool is still TRACKED (sweeps, reclaims, Next Draw, panel counts all see the full set) — this only limits what is painted, so the chart shows the pools that matter now instead of every level in history.')
swept_ttl = input.int(30, 'Keep swept / reclaimed drawn (bars)', minval=5, maxval=300, group=gH,
     tooltip='Dotted (swept) and dashed (reclaimed) lines auto-clear this many bars after the sweep. The story lives in the panel and the swept / reclaim tags — old dotted lines are the main source of chart crowding.')

gD = 'Display'
txt_sz_s = input.string('Normal', 'Text size', options=['Small','Normal','Large','Huge'], group=gD)
plain_sz_s  = input.string('Small', 'Panel rows text size', options=['Tiny','Small','Normal','Large'], group=gD)
story_sz_s  = input.string('Small', 'Storyteller text size', options=['Tiny','Small','Normal','Large'], group=gD)
show_pools   = input.bool(true, 'Draw pool lines', group=gD)
show_tags    = input.bool(true, 'Sweep / reclaim tags', group=gD)
show_panel   = input.bool(true, 'Status panel', group=gD)
panel_mode   = input.string('Compact', 'Panel detail', group=gD, options=['Compact','Full'],
     tooltip="COMPACT (default): the four rows that decide a trade — last sweep, stop reference, state, breadth. FULL: adds level, pool counts, next draw and the 3-magnet ladder. The magnet ladder and next-draw rows auto-hide anyway whenever the Delivery Map or the ring marker is showing them, so Full never duplicates what is already on screen.")
compact_txt  = input.bool(true, 'Small panel text', group=gD,
     tooltip='Uses the smaller of the two text sizes for all dashboards, independent of the Text size setting above.')
panel_pos_s  = input.string('Middle Left', 'Panel position', group=gD,
     options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'])
f_pos(string _p) =>
    _p == 'Top Left' ? position.top_left :
     _p == 'Top Center' ? position.top_center :
     _p == 'Top Right' ? position.top_right :
     _p == 'Middle Left' ? position.middle_left :
     _p == 'Middle Center' ? position.middle_center :
     _p == 'Middle Right' ? position.middle_right :
     _p == 'Bottom Left' ? position.bottom_left :
     _p == 'Bottom Center' ? position.bottom_center : position.bottom_right
panel_pos = f_pos(panel_pos_s)

gV = 'Radar visuals (clean-room reimplementation)'
show_story  = input.bool(true, 'Storyteller bar', group=gV, tooltip='One-line live narrative: what was swept, where the story stands, and the current draw. No sweep = no story = no trade.')
story_pos_s = input.string('Bottom Center', 'Storyteller position', group=gV, options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'])
// [v0.6.7] COMPACT STORYTELLER — the sentence-builder below concatenated every
// clause every time (state + target + stop + reward + ETA + bias + your
// position + pools passed + carried-over) into one un-wrapped table cell.
// Pine tables never wrap text, they only grow, so a long bar routinely spanned
// wide/tall enough to plow into the LIQUIDITY panel and the ULTRA STATUS table
// sitting nearby. The Story/Target/Stop/Do numbers already live in the compact
// panel below in clean rows, so the long sentence was mostly duplicating them
// anyway. Compact ON (default) keeps only the essential clause per state.
// story_max_chars is a hard backstop applied EITHER WAY so this can never grow
// unbounded again regardless of future edits to the sentence builder.
// Detection, state machine, and every number shown are untouched — display only.
story_compact   = input.bool(true, 'Compact storyteller (short line)', group=gV,
     tooltip='ON (default): one short clause — state, target, stop, the one thing to do. OFF: the full narrative sentence with bias/pools-passed/carried-over detail. Either way the line is capped by Max characters below.')
story_max_chars = input.int(80, 'Storyteller max characters', minval=30, maxval=220, group=gV,
     tooltip='Hard length cap on the live story line and each journal row. Longer text is cut with an ellipsis rather than left to grow and overlap other panels.')
show_dmap   = input.bool(true, 'Delivery Map table', group=gV, tooltip='MAGNET / LEVEL / PULL ladder of the strongest untouched pools. The word next marks the top magnet.')
dmap_pos_s  = input.string('Top Center', 'Delivery Map position', group=gV, options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'])
dmap_rows   = input.int(4, 'Delivery Map magnets', minval=3, maxval=8, group=gV)
show_nd_mk  = input.bool(true, 'Next Draw marker on chart', group=gV)
show_glow   = input.bool(true, 'Liquidity Glow', group=gV, tooltip='Soft heat band behind each drawn pool. Untouched glows full; a swept pool dims to an EMBER — visibly consumed, not a target any more.')
glow_w      = input.float(0.5, 'Glow height (×ATR)', minval=0.1, maxval=2.0, step=0.1, group=gV)
show_badge  = input.bool(true, 'Radar badge', group=gV)
c_buy  = input.color(#FFD700, 'Buyside (above)', group=gD, inline='c')
c_sell = input.color(#AA00FF, 'Sellside (below)', group=gD, inline='c')
c_pnl  = input.color(#132420, 'Panel background', group=gD, inline='p')
c_ptx  = input.color(#F3EEE2, 'Panel text', group=gD, inline='p')
c_bull = input.color(#AA00FF, 'Bullish (long)',  group=gD, inline='d', tooltip='Direction colours: purple = long, gold = short. Pool lines use the Buyside / Sellside colours above.')
c_bear = input.color(#FFD700, 'Bearish (short)', group=gD, inline='d')
c_stbg = input.color(#0B0F14, 'Storyteller background', group=gD, inline='s')
c_hdr  = input.color(#FFD700, 'Header bar', group=gD, inline='s')
tz_s   = input.string('America/Los_Angeles', 'Timezone (journal)', group=gD, options=['Exchange','America/Los_Angeles','America/New_York','America/Chicago','Europe/London','UTC'])
string tz_eff = tz_s == 'Exchange' ? syminfo.timezone : tz_s

gS = 'Story'
min_rr      = input.float(1.5, 'Minimum reward to risk for a fresh entry', minval=0.5, maxval=5.0, step=0.25, group=gS)
max_stop_atr = input.float(3.0, 'Maximum stop width (x ATR) for a fresh entry', minval=0.5, maxval=10.0, step=0.25, group=gS)
clock_min   = input.int(20, 'Your clock (minutes)', minval=1, maxval=240, group=gS, tooltip='Hard hold ceiling. Bars to target are judged against it.')
my_entry    = input.float(0.0, 'My entry (0 = off)', minval=0.0, step=0.01, group=gS, tooltip='Type your fill. The Do row then shows the position in R and calls the move to breakeven. Warns if you are against the story.')
done_show   = input.int(6, 'Show DONE for (bars) before clearing', minval=1, maxval=100, group=gS)
day_reset   = input.bool(true, 'New-day reset (clear unarmed or done stories at the daily open)', group=gS)
journal_on  = input.bool(true, 'Story journal above the Storyteller', group=gS)
journal_rows = input.int(3, 'Journal rows', minval=1, maxval=8, group=gS)

string SZ_MAJ = txt_sz_s == 'Small' ? size.small : txt_sz_s == 'Normal' ? size.normal : txt_sz_s == 'Large' ? size.large : size.huge
string SZ_MIN = txt_sz_s == 'Small' ? size.tiny  : txt_sz_s == 'Normal' ? size.small  : txt_sz_s == 'Large' ? size.normal : size.large

string SZ_PNL = compact_txt ? size.tiny : SZ_MIN
string SZ_PLAIN = plain_sz_s == 'Tiny' ? size.tiny : plain_sz_s == 'Small' ? size.small : plain_sz_s == 'Normal' ? size.normal : size.large
string SZ_ST  = story_sz_s == 'Tiny' ? size.tiny : story_sz_s == 'Small' ? size.small : story_sz_s == 'Normal' ? size.normal : size.large
string SZ_ST2 = story_sz_s == 'Tiny' ? size.tiny : story_sz_s == 'Small' ? size.small : story_sz_s == 'Normal' ? size.small : size.normal

float atr = ta.atr(14)
float eq_tol = atr * eq_tol_atr
bool _active = hist_bars == 0 or last_bar_index - bar_index <= hist_bars

// ─── POOL TYPE ───────────────────────────────────────────────────────────────
type Pool
    float lvl
    bool  buyside      // true = above price (buy-side liquidity)
    int   born
    int   touches      // 1 = single pivot · 2+ = equal-highs/lows cluster
    string src         // 'SW' 'ASIA' 'LON' 'NY' 'PDH' 'PDL' 'PWH' 'PWL'
    int   state        // 0 untouched · 1 swept · 2 reclaimed · 3 stale
    int   swept_bar
    float swept_wick
    line  ln
    label lb
    box   gbx

var array<Pool> pools = array.new<Pool>()

// ─── MODULE CONTRACT (read by Module 4) ──────────────────────────────────────
var int   lq_swept_side = 0
var float lq_swept_lvl  = na
var int   lq_swept_bar  = na
var float lq_swept_wick = na
var bool  lq_reclaimed  = false
// [v0.5.5] REJECTED — the reclaimed level was retested and HELD. This is the
// third beat of the story and the one the pool model was missing: sweep tells
// you liquidity was taken, reclaim tells you the take failed, reject tells you
// the level has FLIPPED and is now working as the other kind of level.
var bool  lq_rejected   = false
var int   lq_reject_bar = na
// story layer (v0.6.0)
var bool   lq_done      = false
var string lq_done_why  = ''
var int    lq_done_bar  = na
var int    lq_last_done_bar = na
var string lq_last_done_why = ''
var int    lq_passed    = 0
var float  lq_run_ext   = na
var float  lq_pb_ext    = na
var bool   lq_pb_seen   = false
var float  lq_hl_last   = na
var int    lq_ent_bar   = na
var bool   lq_carried   = false
var int   lq_reclaim_bar = na

// ─── SOURCES ─────────────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, piv_len, piv_right)
float pl = ta.pivotlow (low,  piv_len, piv_right)
// chart structure: last two swing highs and lows
var float sh1 = na
var float sh2 = na
var float sl1 = na
var float sl2 = na
if not na(ph)
    sh2 := sh1
    sh1 := ph
if not na(pl)
    sl2 := sl1
    sl1 := pl
int struct_dir = na(sh1) or na(sh2) or na(sl1) or na(sl2) ? 0 : sh1 > sh2 and sl1 > sl2 ? 1 : sh1 < sh2 and sl1 < sl2 ? -1 : 0

// prior day / week — lookahead_on is safe here: [1] is a CLOSED period
[pdh, pdl] = request.security(syminfo.tickerid, 'D', [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', [high[1], low[1]], lookahead=barmerge.lookahead_on)

// session extremes, New York clock
f_sess(string spec) =>
    not na(time(timeframe.period, spec, 'America/New_York'))
bool in_asia = f_sess('1800-0300')
bool in_lon  = f_sess('0300-0800')
bool in_ny   = f_sess('0800-1700')

var float asia_h = na
var float asia_l = na
var float lon_h = na
var float lon_l = na
var float ny_h = na
var float ny_l = na
if in_asia
    asia_h := not in_asia[1] ? high : math.max(nz(asia_h, high), high)
    asia_l := not in_asia[1] ? low  : math.min(nz(asia_l, low), low)
if in_lon
    lon_h := not in_lon[1] ? high : math.max(nz(lon_h, high), high)
    lon_l := not in_lon[1] ? low  : math.min(nz(lon_l, low), low)
if in_ny
    ny_h := not in_ny[1] ? high : math.max(nz(ny_h, high), high)
    ny_l := not in_ny[1] ? low  : math.min(nz(ny_l, low), low)

// ─── POOL CREATION ───────────────────────────────────────────────────────────
f_find(float lvl, bool buyside) =>
    int found = -1
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            Pool p = array.get(pools, i)
            if found < 0 and p.buyside == buyside and p.state == 0 and math.abs(p.lvl - lvl) <= eq_tol
                found := i
    found

f_add(float lvl, bool buyside, string src) =>
    if not na(lvl)
        int hit = use_eq ? f_find(lvl, buyside) : -1
        if hit >= 0
            Pool p = array.get(pools, hit)
            p.lvl := (p.lvl * p.touches + lvl) / (p.touches + 1)
            p.touches += 1
            p.src := 'EQ'          // promoted: equal highs / lows
        else
            array.push(pools, Pool.new(lvl, buyside, bar_index, 1, src, 0, na, na, na, na, na))
            if array.size(pools) > max_pools
                Pool _old = array.shift(pools)
                if not na(_old.ln)
                    line.delete(_old.ln)
                if not na(_old.lb)
                    label.delete(_old.lb)
                if not na(_old.gbx)   // [v0.3.2 P5] glow box was LEAKED here —
                    box.delete(_old.gbx)   // orphans piled into the 100-box cap and
                                           // Pine's auto-eviction made glows vanish/flash
    true

if _active and use_struct and not na(ph)
    f_add(ph, true, 'SW')
if _active and use_struct and not na(pl)
    f_add(pl, false, 'SW')
// session pools register once, when the session closes
if _active and use_sess and not in_asia and in_asia[1]
    f_add(asia_h, true, 'ASIA')
    f_add(asia_l, false, 'ASIA')
if _active and use_sess and not in_lon and in_lon[1]
    f_add(lon_h, true, 'LON')
    f_add(lon_l, false, 'LON')
if _active and use_sess and not in_ny and in_ny[1]
    f_add(ny_h, true, 'NY')
    f_add(ny_l, false, 'NY')
// prior period pools register on the period roll
// [v0.5.2b] CW10002: ta.change() sat behind a short-circuiting `and`, so with
// use_prior OFF the call never executed and its history went stale. Hoisted.
bool _roll_day  = ta.change(time('D')) != 0
bool _roll_week = ta.change(time('W')) != 0
if _active and use_prior and _roll_day
    f_add(pdh, true, 'PDH')
    f_add(pdl, false, 'PDL')
if _active and use_prior and _roll_week
    f_add(pwh, true, 'PWH')
    f_add(pwl, false, 'PWL')

// ─── SWEEP / RECLAIM STATE MACHINE ───────────────────────────────────────────
// UNTOUCHED -> SWEPT   wick beyond the pool, close back inside
// UNTOUCHED -> BROKEN  close beyond the pool — the level BROKE, it was not
//                      swept. Consumed. Never sweepable on a later retest.
// SWEPT     -> RECLAIM close back through the pool origin inside the window
// SWEPT     -> STALE   window expires with no reclaim
// [v0.3.2 P1] CONFIRMED BARS ONLY. Every transition below used to evaluate on
// every realtime tick: a mid-bar wick marked the pool SWEPT and latched the
// state permanently even when the bar finished as a clean break — and the
// reclaim test could latch off a tick that closed nowhere near reclaiming.
// That is the intrabar flashing. The doctrine says wick-through vs close-
// through are different EVENTS — events are only knowable at the bar close.
// [v0.3.2 P2] BROKEN (state 4). A close through a pool consumed nothing in
// v0.3.1 — the pool stayed "untouched fuel". When price later retested the
// broken level from the far side, the wick test fired an INVERTED sweep story
// (support retest read as "buyside taken" = bearish). Broken pools are now
// consumed on the spot.
// [v0.3.2 P3] STORY OWNERSHIP. lq_* globals were overwritten by EVERY sweep of
// ANY of 60 pools, and lq_reclaimed was set by ANY pool's reclaim — pool A's
// reclaim could stamp ✓ onto pool B's story (the false "✓ reclaimed" reads).
// Now: a live story is only taken over by an equal-or-heavier source (PWH/PWL
// 5.0 > PDH/PDL 4.0 > EQ 3.5 > sessions 3.0 > swings 2.0), and only the
// story-owning pool's reclaim can set lq_reclaimed.
f_srcw(string _s) =>
    _s == 'PWH' or _s == 'PWL' ? 5.0 : _s == 'PDH' or _s == 'PDL' ? 4.0 : _s == 'EQ' ? 3.5 : _s == 'SW' ? 2.0 : 3.0
var float lq_story_w = 0.0
var int   last_break_dir = 0     // +1 broke a buyside pool (up), -1 broke a sellside pool (down)
var int   last_break_bar = na
if _active and barstate.isconfirmed and array.size(pools) > 0
    for i = 0 to array.size(pools) - 1
        Pool p = array.get(pools, i)
        if p.state == 0
            bool broke = p.buyside ? close > p.lvl : close < p.lvl
            float _dep = math.max(nz(atr) * sweep_min_atr, syminfo.mintick * 2)
            bool took  = p.buyside ? high >= p.lvl + _dep and close <= p.lvl : low <= p.lvl - _dep and close >= p.lvl
            bool _drawSide = lq_swept_side != 0 and not lq_done and lq_reclaimed and p.buyside == (lq_swept_side == -1)
            if broke
                p.state := 4
                p.swept_bar := bar_index
                last_break_dir := p.buyside ? 1 : -1
                last_break_bar := bar_index
                if _drawSide
                    lq_passed += 1
            else if took
                p.state := 1
                p.swept_bar := bar_index
                p.swept_wick := p.buyside ? high : low
                float _w = f_srcw(p.src)
                bool story_live = lq_swept_side != 0 and not lq_done
                bool _leg = _drawSide and _w <= lq_story_w
                if _leg
                    lq_passed += 1
                if not _leg and (not story_live or _w >= lq_story_w)
                    lq_swept_side := p.buyside ? 1 : -1
                    lq_swept_lvl  := p.lvl
                    lq_swept_bar  := bar_index
                    lq_swept_wick := p.swept_wick
                    lq_reclaimed  := false
                    lq_reclaim_bar := na
                    lq_rejected   := false
                    lq_reject_bar := na
                    lq_story_w := _w
                    lq_done := false
                    lq_done_why := ''
                    lq_done_bar := na
                    lq_passed := 0
                    lq_run_ext := na
                    lq_pb_ext := na
                    lq_pb_seen := false
                    lq_hl_last := na
                    lq_ent_bar := na
                    lq_carried := false
                if show_tags
                    label.new(bar_index, p.swept_wick, 'swept', xloc=xloc.bar_index, yloc=yloc.price,
                         style=label.style_none, textcolor=p.buyside ? c_bear : c_bull, size=size.tiny)
        else if p.state == 1
            // a buyside pool was swept from above -> reclaim is a close back BELOW it
            bool back = p.buyside ? close < p.lvl : close > p.lvl
            bool body_ok = not require_body or (p.buyside ? close < math.min(open, p.lvl) : close > math.max(open, p.lvl))
            if back and body_ok
                p.state := 2
                // [v0.3.2 P3] only the story owner's reclaim marks the story reclaimed
                if not na(lq_swept_bar) and p.swept_bar == lq_swept_bar and (p.buyside ? 1 : -1) == lq_swept_side and p.lvl == lq_swept_lvl
                    lq_reclaimed := true
                    lq_reclaim_bar := bar_index
                if show_tags
                    label.new(bar_index, p.lvl, 'reclaim', xloc=xloc.bar_index, yloc=yloc.price,
                         style=label.style_none, textcolor=p.buyside ? c_bear : c_bull, size=size.tiny)
            else if bar_index - p.swept_bar > reclaim_eff
                p.state := 3
        else if p.state == 2
            // [v0.5.5] RECLAIMED -> REJECTED. Price returned to the reclaimed
            // level and it held. A buyside pool swept from above and reclaimed
            // below is now RESISTANCE: a return that tags it and closes back
            // under confirms the flip. Closing THROUGH is acceptance, which
            // breaks the pool instead (state 4) and ends the story honestly.
            float _rt = na(atr) ? 0.0 : atr * rj_tol
            bool  _tag  = p.buyside ? high >= p.lvl - _rt : low <= p.lvl + _rt
            bool  _held = p.buyside ? close < p.lvl : close > p.lvl
            bool  _thru = p.buyside ? close > p.lvl : close < p.lvl
            if _tag and _held
                p.state := 5
                if not na(lq_swept_bar) and p.swept_bar == lq_swept_bar and (p.buyside ? 1 : -1) == lq_swept_side and p.lvl == lq_swept_lvl
                    lq_rejected := true
                    lq_reject_bar := bar_index
                if show_tags
                    label.new(bar_index, p.lvl, 'reject', xloc=xloc.bar_index, yloc=yloc.price,
                         style=label.style_none, textcolor=p.buyside ? c_bear : c_bull, size=size.tiny)
            else if _thru
                p.state := 4

// ─── DRAW ────────────────────────────────────────────────────────────────────
f_draw(Pool p) =>
    color base = p.buyside ? c_buy : c_sell
    int    lft = math.max(p.born, math.max(0, bar_index - 450))
    int    trp = p.state == 0 ? (p.touches > 1 ? 5 : 25) : p.state == 1 ? 55 : p.state == 2 ? 15 : p.state == 5 ? 0 : 80
    string sty = p.state == 0 or p.state == 5 ? line.style_solid : p.state == 2 ? line.style_dashed : line.style_dotted
    int    wid = p.state == 5 or (p.touches > 1 and p.state == 0) ? 2 : 1
    if na(p.ln)
        p.ln := line.new(lft, p.lvl, bar_index, p.lvl, xloc=xloc.bar_index, extend=extend.right,
             color=color.new(base, trp), width=wid, style=sty)
    else
        line.set_y1(p.ln, p.lvl)
        line.set_y2(p.ln, p.lvl)
        line.set_color(p.ln, color.new(base, trp))
        line.set_style(p.ln, sty)
        line.set_width(p.ln, wid)
    // [v0.3] LIQUIDITY GLOW — heat band; swept pools dim to an ember
    if show_glow
        float _h  = atr * glow_w
        int   _gt = p.state == 0 ? (p.touches > 1 ? 82 : 87) : p.state == 1 ? 94 : 90
        if na(p.gbx)
            p.gbx := box.new(lft, p.lvl + _h, bar_index + 8, p.lvl - _h, bgcolor=color.new(base, _gt), border_color=color.new(base, 100))
        else
            box.set_top(p.gbx, p.lvl + _h)
            box.set_bottom(p.gbx, p.lvl - _h)
            box.set_right(p.gbx, bar_index + 8)
            box.set_bgcolor(p.gbx, color.new(base, _gt))
    else if not na(p.gbx)
        box.delete(p.gbx)
        p.gbx := na
    true

f_kill(Pool p) =>
    if not na(p.ln)
        line.delete(p.ln)
    if not na(p.lb)
        label.delete(p.lb)
    if not na(p.gbx)
        box.delete(p.gbx)

// hide = remove the drawing but keep the pool tracked (na-safe for redraw)
f_hide(Pool p) =>
    if not na(p.ln)
        line.delete(p.ln)
        p.ln := na
    if not na(p.lb)
        label.delete(p.lb)
        p.lb := na
    if not na(p.gbx)
        box.delete(p.gbx)
        p.gbx := na

// [v0.5.3] REDRAW THROTTLE. barstate.islast is true on every tick of the live
// bar, so the whole draw pass re-ran dozens of times per second while price sat
// still. Now it re-runs on bar close, or when price has moved far enough that
// the nearest-pool ordering could actually have changed. Detection, the state
// machine and every bridge export are UNTHROTTLED — this gates drawing only.
var float _last_draw_px = na
bool _px_moved = na(_last_draw_px) or math.abs(close - _last_draw_px) >= syminfo.mintick * redraw_ticks
if barstate.islast and (barstate.isconfirmed or _px_moved)
    _last_draw_px := close
if barstate.islast and show_pools and array.size(pools) > 0 and (barstate.isconfirmed or _px_moved)
    for i = array.size(pools) - 1 to 0
        Pool p = array.get(pools, i)
        if (p.state == 3 and not show_stale) or p.state == 4   // [v0.3.2] broken pools always removed
            f_kill(p)
            array.remove(pools, i)
    // [v0.2.2] draw only what matters NOW: nearest N untouched per side,
    // swept/reclaimed lines expire after swept_ttl bars. Tracking unaffected.
    // [v0.5.3] TIMEOUT FIX. This block used to ask, for every untouched pool,
    // "how many same-side pools are closer than me?" — an inner loop over the
    // whole array inside an outer loop over the whole array. O(n^2). At the 60-
    // pool cap that is 3,600 iterations, and because the block sits under
    // barstate.islast it ran on EVERY TICK, not every bar — roughly 90% of the
    // script's per-tick cost, with f_draw/f_hide touching line and box objects
    // inside it. v0.5.2's faster pivots made it worse by filling the array to
    // the cap more often. Same answer now via two linear passes: collect the
    // untouched distances per side, sort those small arrays, take the k-th
    // nearest as a threshold. O(n) + a sort of a short list.
    if array.size(pools) > 0
        array<float> _db = array.new<float>()
        array<float> _ds = array.new<float>()
        for i = 0 to array.size(pools) - 1
            Pool p = array.get(pools, i)
            if p.state == 0
                if p.buyside
                    array.push(_db, math.abs(p.lvl - close))
                else
                    array.push(_ds, math.abs(p.lvl - close))
        if array.size(_db) > 1
            array.sort(_db, order.ascending)
        if array.size(_ds) > 1
            array.sort(_ds, order.ascending)
        float _thr_b = array.size(_db) >= draw_per_side ? array.get(_db, draw_per_side - 1) : 1e18
        float _thr_s = array.size(_ds) >= draw_per_side ? array.get(_ds, draw_per_side - 1) : 1e18
        for i = 0 to array.size(pools) - 1
            Pool p = array.get(pools, i)
            bool elig = false
            if p.state == 0
                elig := math.abs(p.lvl - close) <= (p.buyside ? _thr_b : _thr_s)
            else
                elig := p.state != 4 and not na(p.swept_bar) and bar_index - p.swept_bar <= swept_ttl   // [v0.3.2] broken never drawn
            if elig
                f_draw(p)
            else
                f_hide(p)

// ─── NEXT DRAW — nearest unswept pool per side ───────────────────────────────
float nd_up = na
float nd_dn = na
string nd_up_src = ''
string nd_dn_src = ''
float nd_up2 = na
float nd_dn2 = na
string nd_up2_src = ''
string nd_dn2_src = ''
if _active and array.size(pools) > 0
    for i = 0 to array.size(pools) - 1
        Pool p = array.get(pools, i)
        if p.state == 0
            if p.buyside and p.lvl > close
                if na(nd_up) or p.lvl < nd_up
                    nd_up2 := nd_up
                    nd_up2_src := nd_up_src
                    nd_up := p.lvl
                    nd_up_src := p.src
                else if na(nd_up2) or p.lvl < nd_up2
                    nd_up2 := p.lvl
                    nd_up2_src := p.src
            if not p.buyside and p.lvl < close
                if na(nd_dn) or p.lvl > nd_dn
                    nd_dn2 := nd_dn
                    nd_dn2_src := nd_dn_src
                    nd_dn := p.lvl
                    nd_dn_src := p.src
                else if na(nd_dn2) or p.lvl > nd_dn2
                    nd_dn2 := p.lvl
                    nd_dn2_src := p.src
// [v0.5.4] The nearest-pool scan stays here; the DIRECTION is now resolved
// after the HTF bias engine below, because bias is an input to it.

// ─── BREADTH ($ADD / $TICK) — a FILTER for size, never a signal ──────────────
gB = 'Breadth ($ADD / $TICK)'
br_on       = input.bool(true, 'Enable breadth read', group=gB, tooltip='ADD = session context, TICK = exhaustion flag. Sets SIZE (full/half/skip) — never an entry. Shows OFFLINE outside NYSE cash hours (06:30-13:00 PT): breadth does not exist overnight, so overnight futures reads stay honest. Verify your data plan returns LIVE USI values before trusting it.')
br_add_sym  = input.symbol('USI:ADD',  'ADD symbol',  group=gB)
br_tick_sym = input.symbol('USI:TICK', 'TICK symbol', group=gB)
br_trend_th = input.int(1000, 'ADD trend threshold', minval=250, group=gB)
br_chop_th  = input.int(500,  'ADD chop band',       minval=100, group=gB)
br_tick_th  = input.int(1000, 'TICK exhaustion',     minval=500, group=gB)
bool  br_cash = not na(time(timeframe.period, '0630-1300', 'America/Los_Angeles'))
float br_add  = br_on ? request.security(br_add_sym,  timeframe.period, close) : na
float br_tick = br_on ? request.security(br_tick_sym, timeframe.period, close) : na
bool  br_mkt  = syminfo.type != 'crypto' and syminfo.type != 'forex' and dayofweek != dayofweek.saturday and dayofweek != dayofweek.sunday
bool  br_live = br_mkt and br_cash and not na(br_add) and not na(br_tick)
bool  br_up   = ta.rising(br_add, 3)
bool  br_dn   = ta.falling(br_add, 3)
int   br_state = not br_live ? 0 : br_add > br_trend_th and br_up ? 1 : br_add < -br_trend_th and br_dn ? 2 : math.abs(br_add) < br_chop_th ? 3 : 4
bool  br_tick_hi = br_live and br_tick >=  br_tick_th
bool  br_tick_lo = br_live and br_tick <= -br_tick_th
string br_txt = (br_state == 0 ? 'OFFLINE' : br_state == 1 ? 'BUYING' : br_state == 2 ? 'SELLING' : br_state == 3 ? 'CHOP' : 'LEAN') + (br_tick_hi ? ' ⚠T+' : br_tick_lo ? ' ⚠T−' : '')
color  br_col = br_state == 1 ? #AA00FF : br_state == 2 ? #8A6D00 : color.gray
alertcondition(br_tick_hi, 'TICK exhaustion up',   'MBF LIQ: +TICK spike — exhaustion; longs into pools get sold here')
alertcondition(br_tick_lo, 'TICK exhaustion down', 'MBF LIQ: -TICK flush — exhaustion; shorts into pools get covered here')

// ─── HTF BIAS — structure-based [v0.5.0 · RZ contribution] ───────────────────
gHB = 'HTF Bias (structure)'
show_htf     = input.bool(true, 'Enable HTF bias engine', group=gHB)
htf_tf       = input.timeframe('60', 'HTF for bias (manual)', group=gHB)
htf_auto     = input.bool(true, 'Auto HTF (steps up only)', group=gHB, tooltip='under 15m reads 60, under 1h reads 240, under 4h reads D, 4h and up reads W')
string htf_eff = not htf_auto ? htf_tf : _cs < 900 ? '60' : _cs < 3600 ? '240' : _cs < 14400 ? 'D' : 'W'
htf_piv_len  = input.int(6, 'HTF swing length (LEFT bars)', minval=2, maxval=50, group=gHB)
htf_piv_r_m  = input.int(2, 'Manual: HTF pivot RIGHT bars', minval=1, maxval=50, group=gHB,
     tooltip='v0.5.0 used right==left. At the default HTF of 60m that meant an HTF swing took 6 x 60m = SIX HOURS to confirm, which is why HTF bias could still read BULLISH well into a sell-off.')
int htf_piv_right = resp_mode == 'Turbo' ? 1 : resp_mode == 'Fast' ? 1 : resp_mode == 'Balanced' ? 2 : resp_mode == 'Strict' ? htf_piv_len : htf_piv_r_m
htf_chop_win = input.int(20, 'Chop window (bars, this chart TF)', minval=2, maxval=200, group=gHB,
     tooltip='If HTF bias would flip again within this many bars of the previous flip, it is tagged NEUTRAL/CHOPPY instead of directional.')
show_htf_lvl = input.bool(true, 'Draw HTF swing high/low reference lines', group=gHB)

[htf_ph, htf_pl] = request.security(syminfo.tickerid, htf_eff, [ta.pivothigh(high, htf_piv_len, htf_piv_right), ta.pivotlow(low, htf_piv_len, htf_piv_right)])

var float htf_last_hi = na
var float htf_last_lo = na
if barstate.isconfirmed
    if not na(htf_ph)
        htf_last_hi := htf_ph
    if not na(htf_pl)
        htf_last_lo := htf_pl

var int htf_state    = 0
var int htf_flip_bar = na
bool htf_up_now   = false
bool htf_dn_now   = false
bool htf_chop_now = false

if show_htf and barstate.isconfirmed and not na(htf_last_hi) and not na(htf_last_lo)
    bool _brokeUp = close > htf_last_hi and htf_state != 1
    bool _brokeDn = close < htf_last_lo and htf_state != -1
    if _brokeUp or _brokeDn
        bool _rapid = not na(htf_flip_bar) and (bar_index - htf_flip_bar) <= htf_chop_win
        int  _newState = _rapid ? 0 : (_brokeUp ? 1 : -1)
        if _newState != htf_state
            htf_up_now   := _newState == 1
            htf_dn_now   := _newState == -1
            htf_chop_now := _newState == 0
        htf_state := _newState
        htf_flip_bar := bar_index

string htf_txt = htf_state == 1 ? 'bullish' : htf_state == -1 ? 'bearish' : 'neutral'
color  htf_col = htf_state == 1 ? c_buy : htf_state == -1 ? c_sell : color.gray

// ─── TREND — majority of three votes: chart structure, HTF bias, pool breaks ──
int    _brk = not na(last_break_bar) and bar_index - last_break_bar <= 20 ? last_break_dir : 0
int    _ups = (struct_dir == 1 ? 1 : 0) + (htf_state == 1 ? 1 : 0) + (_brk == 1 ? 1 : 0)
int    _dns = (struct_dir == -1 ? 1 : 0) + (htf_state == -1 ? 1 : 0) + (_brk == -1 ? 1 : 0)
int    trend_dir = _ups >= 2 ? 1 : _dns >= 2 ? -1 : 0
string trend_txt = trend_dir == 1 ? 'UP, ' + str.tostring(_ups) + ' of 3' : trend_dir == -1 ? 'DOWN, ' + str.tostring(_dns) + ' of 3' : 'MIXED'
string trend_why = 'Structure: ' + (struct_dir == 1 ? 'higher highs and lows' : struct_dir == -1 ? 'lower highs and lows' : 'no clean structure') + '. Bias ' + htf_eff + ': ' + (htf_state == 1 ? 'up' : htf_state == -1 ? 'down' : 'neutral') + '. Pools: ' + (_brk == 1 ? 'breaking up' : _brk == -1 ? 'breaking down' : 'no recent break') + '.'
color  trend_col = trend_dir == 1 ? c_bull : trend_dir == -1 ? c_bear : #B8B8C8

// ═══ [v0.5.4] NEXT DRAW — DIRECTION RESOLUTION, NOW BIAS-AWARE ══════════════
// THE BUG: direction was decided purely by which unswept pool was nearer, with
// no reference to the HTF bias engine sitting twenty lines above it. Observed
// on 45m SPYXUSD at close 776.97: the upside pool 779.34 was 2.37 away, the
// downside pool 774.78 was 2.19 away. The downside won by 0.18 — well inside
// noise — so the Storyteller published "draw ▼ 774.78" while the same panel
// reported HTF bias ▲ BULLISH, price above the opening range, above PDH, and a
// confirmed bullish LTF CHoCH. Hysteresis then held that wrong answer in place.
// Two engines in one script were contradicting each other on screen.
// THE FIX: when bias is directional and the bias side still has an unswept
// pool, the draw points with the bias unless the counter-side pool is closer by
// a real margin (default 0.75x ATR). Distance still decides when bias is
// NEUTRAL/CHOP, when the bias side has no pool left, or when the counter-pool
// is genuinely much closer. Bias is a filter on direction, not an override of
// price — which is the same rule the trader is asked to follow.
// NOTHING WAS LOOSENED: no pool detection, sweep rule or reclaim rule changed.
// This orders two answers that already existed.
nd_hys = input.float(0.25, 'Next-Draw flip hysteresis (×ATR)', minval=0.0, maxval=2.0, step=0.05, group=gV,
     tooltip='The opposite side must be closer by this many ATRs before the published draw direction flips. 0 restores the raw every-tick answer. Raise it if the ◎ marker still ping-pongs on your symbol.')
nd_bias_on = input.bool(true, 'Next Draw respects HTF bias', group=gV,
     tooltip='ON (default): when HTF bias is BULLISH or BEARISH, the published draw points with the bias unless the opposite pool is closer by the margin below. OFF: pure nearest-pool, which is the pre-v0.5.4 behaviour and can point the draw against the bias on a difference of a few ticks. Distance always decides when bias is NEUTRAL/CHOP or when the bias side has no unswept pool left.')
nd_bias_ov = input.float(0.75, 'Counter-bias override (×ATR)', minval=0.0, maxval=5.0, step=0.25, group=gV,
     tooltip='How much closer the counter-bias pool must be before it outranks the bias side. 0.75 ATR means a pool has to be materially nearer, not nearer by noise. Set 0 to make bias absolute whenever a bias-side pool exists.')
int nd_raw = na(nd_up) and na(nd_dn) ? 0 : na(nd_dn) ? 1 : na(nd_up) ? -1 : (nd_up - close <= close - nd_dn ? 1 : -1)
// Bias gate, applied to the raw answer BEFORE hysteresis so the published
// direction is still smoothed exactly as before.
int _lean = trend_dir != 0 ? trend_dir : htf_state
if nd_bias_on and _lean != 0 and nd_raw != 0 and nd_raw != _lean
    // [v0.5.8] Was `not na(...)` alone. A pool can be non-na and still be on
    // the WRONG SIDE of price — nd_up is the nearest unswept pool above when
    // it was scanned, but price can trade through it before the pool state
    // updates. Overriding to bias on the strength of a pool that is no longer
    // overhead is how the arrow and the level came to disagree.
    bool _hasBias = _lean == 1 ? (not na(nd_up) and nd_up > close) : (not na(nd_dn) and nd_dn < close)
    float _dBias  = _lean == 1 ? nd_up - close : close - nd_dn
    float _dOpp   = _lean == 1 ? close - nd_dn : nd_up - close
    if _hasBias and (_dBias - _dOpp) < atr * nd_bias_ov
        nd_raw := _lean
var int nd_hold = 0
int nd_dir = nd_raw
if nd_hold != 0 and nd_raw != 0 and nd_raw != nd_hold
    float _dU = na(nd_up) ? 1e10 : nd_up - close
    float _dD = na(nd_dn) ? 1e10 : close - nd_dn
    bool _flip = nd_raw == 1 ? (_dD - _dU) >= atr * nd_hys : (_dU - _dD) >= atr * nd_hys
    nd_dir := _flip ? nd_raw : nd_hold
// ── [v0.5.8] COHERENCE GUARD — the arrow and the level must agree ──────────
// Reported live on 1m NQ: price 29,438.75, Storyteller "draw ▲ 29,435.50".
// An up-draw pointing at a level BELOW price is nonsense, and it was the
// hysteresis that produced it. The hold above deliberately keeps the previous
// direction until the other side is closer by a margin — but it never checked
// that the HELD side still has a pool on the correct side of price. When price
// trades up through nd_up without sweeping it, nd_up sits below close while
// nd_dir is still +1, and the label prints ▲ at a lower number.
// This is why the fault was intermittent rather than constant: it needs price
// to cross the held pool, so most bars look fine and one in twenty does not.
// The guard: if the published direction's level is missing or on the wrong
// side, the hold is stale. Take the opposite side if IT is valid, otherwise
// publish no direction at all — an honest blank beats a confident wrong arrow.
if nd_dir == 1 and (na(nd_up) or nd_up <= close)
    nd_dir := (not na(nd_dn) and nd_dn < close) ? -1 : 0
else if nd_dir == -1 and (na(nd_dn) or nd_dn >= close)
    nd_dir := (not na(nd_up) and nd_up > close) ? 1 : 0
nd_hold := nd_dir
float nd_lvl = nd_dir == 1 ? nd_up : nd_dir == -1 ? nd_dn : na

var line htf_hi_ln = na
var line htf_lo_ln = na
if barstate.islast and show_htf and show_htf_lvl and not na(htf_last_hi) and not na(htf_last_lo)
    if na(htf_hi_ln)
        htf_hi_ln := line.new(math.max(0, bar_index - 200), htf_last_hi, bar_index + 8, htf_last_hi, xloc=xloc.bar_index, color=color.new(c_buy, 40), width=1, style=line.style_dotted)
        htf_lo_ln := line.new(math.max(0, bar_index - 200), htf_last_lo, bar_index + 8, htf_last_lo, xloc=xloc.bar_index, color=color.new(c_sell, 40), width=1, style=line.style_dotted)
    else
        line.set_y1(htf_hi_ln, htf_last_hi)
        line.set_y2(htf_hi_ln, htf_last_hi)
        line.set_x2(htf_hi_ln, bar_index + 8)
        line.set_y1(htf_lo_ln, htf_last_lo)
        line.set_y2(htf_lo_ln, htf_last_lo)
        line.set_x2(htf_lo_ln, bar_index + 8)
else if barstate.islast and not na(htf_hi_ln)
    line.delete(htf_hi_ln)
    line.delete(htf_lo_ln)
    htf_hi_ln := na
    htf_lo_ln := na

alertcondition(htf_up_now, 'HTF bias turned bullish', 'MBF LIQ: HTF structure shifted BULLISH')
alertcondition(htf_dn_now, 'HTF bias turned bearish', 'MBF LIQ: HTF structure shifted BEARISH')
alertcondition(htf_chop_now, 'HTF bias turned neutral/choppy', 'MBF LIQ: HTF structure turned NEUTRAL/CHOPPY')

// ─── LTF CHoCH CONFIRMATION — the entry trigger [v0.5.0 · RZ contribution] ───
gL = 'LTF CHoCH Confirmation'
use_ltf_choch = input.bool(true, 'Wait for LTF CHoCH after sweep', group=gL,
     tooltip='ON (recommended): a sweep alone does not arm a trade. The entry engine waits for a change of character on the LTF, back in the direction of the next liquidity draw, before arming.')
ltf_tf        = input.timeframe('1', 'LTF for CHoCH (manual)', group=gL)
ltf_auto      = input.bool(true, 'Auto LTF (steps down only)', group=gL, tooltip='1m and below reads the chart, up to 15m reads 1, up to 1h reads 5, up to 4h reads 15, above reads 60')
string ltf_eff = not ltf_auto ? ltf_tf : _cs <= 60 ? timeframe.period : _cs <= 900 ? '1' : _cs <= 3600 ? '5' : _cs <= 14400 ? '15' : '60'
ltf_piv_len   = input.int(3, 'LTF pivot length (LEFT bars)', minval=1, maxval=20, group=gL)
ltf_piv_r_m   = input.int(1, 'Manual: LTF pivot RIGHT bars', minval=1, maxval=20, group=gL)
int ltf_piv_right = resp_mode == 'Turbo' ? 1 : resp_mode == 'Fast' ? 1 : resp_mode == 'Balanced' ? 1 : resp_mode == 'Strict' ? ltf_piv_len : ltf_piv_r_m
choch_valid_win = input.int(60, 'Valid window (bars, this chart TF)', minval=5, maxval=300, group=gL,
     tooltip='After a sweep, price has this many bars on THIS chart timeframe for the LTF CHoCH to occur. Past this, the sweep is stale for entry purposes.')
mark_choch    = input.bool(true, 'Mark confirmation on chart', group=gL)

[ltf_ph, ltf_pl] = request.security(syminfo.tickerid, ltf_eff, [ta.pivothigh(high, ltf_piv_len, ltf_piv_right), ta.pivotlow(low, ltf_piv_len, ltf_piv_right)])

var float ltf_last_hi = na
var float ltf_last_lo = na
if barstate.isconfirmed
    if not na(ltf_ph)
        ltf_last_hi := ltf_ph
    if not na(ltf_pl)
        ltf_last_lo := ltf_pl

var bool ltf_choch_confirmed = false
var int  ltf_choch_bar = na
var int  _prev_story_bar = na
bool choch_now = false

if barstate.isconfirmed and use_ltf_choch
    if not na(lq_swept_bar) and lq_swept_bar != _prev_story_bar
        ltf_choch_confirmed := false
        ltf_choch_bar := na
        _prev_story_bar := lq_swept_bar
    if lq_swept_side != 0 and not ltf_choch_confirmed and not na(lq_swept_bar) and bar_index > lq_swept_bar and (bar_index - lq_swept_bar) <= choch_valid_win
        int _needDir = lq_swept_side == 1 ? -1 : 1
        if _needDir == -1 and not na(ltf_last_lo) and close < ltf_last_lo
            ltf_choch_confirmed := true
            ltf_choch_bar := bar_index
            choch_now := true
        else if _needDir == 1 and not na(ltf_last_hi) and close > ltf_last_hi
            ltf_choch_confirmed := true
            ltf_choch_bar := bar_index
            choch_now := true

if mark_choch and choch_now
    label.new(bar_index, lq_swept_side == 1 ? low : high, 'structure break', xloc=xloc.bar_index, yloc=yloc.price,
         style=lq_swept_side == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(lq_swept_side == 1 ? c_sell : c_buy, 15), textcolor=color.white, size=SZ_MIN)

alertcondition(choch_now, 'LTF CHoCH confirmed', 'MBF LIQ: LTF CHoCH confirmed — entry conditions met')


// ─── STORY LAYER (v0.6.0) — written from the spec in the header ─────────────
// Every field below is set ONCE per bar. The display prints fields; it does
// not compute.
bool story_armed = lq_swept_side != 0 and not lq_done and lq_reclaimed and (not use_ltf_choch or ltf_choch_confirmed)
if barstate.isconfirmed and lq_swept_side != 0 and not lq_done
    bool _long   = lq_swept_side == -1
    bool _armBar = not na(lq_reclaim_bar) and lq_reclaim_bar == bar_index
    if _armBar
        lq_run_ext := _long ? high : low
        lq_pb_ext := na
        lq_pb_seen := false
        lq_hl_last := na
        lq_passed := 0
    // structure tracking after arm: run extreme, pullback extreme, confirmed HL/LH
    bool _structFail = false
    if lq_reclaimed and not _armBar
        if _long
            if high > lq_run_ext
                if lq_pb_seen and not na(lq_pb_ext)
                    lq_hl_last := lq_pb_ext
                lq_run_ext := high
                lq_pb_ext := na
                lq_pb_seen := false
            else
                lq_pb_ext := na(lq_pb_ext) ? low : math.min(lq_pb_ext, low)
                lq_pb_seen := true
            _structFail := (not na(lq_hl_last) and close < lq_hl_last) or (lq_pb_seen and not na(lq_pb_ext) and close < lq_pb_ext and high < lq_run_ext)
        else
            if low < lq_run_ext
                if lq_pb_seen and not na(lq_pb_ext)
                    lq_hl_last := lq_pb_ext
                lq_run_ext := low
                lq_pb_ext := na
                lq_pb_seen := false
            else
                lq_pb_ext := na(lq_pb_ext) ? high : math.max(lq_pb_ext, high)
                lq_pb_seen := true
            _structFail := (not na(lq_hl_last) and close > lq_hl_last) or (lq_pb_seen and not na(lq_pb_ext) and close > lq_pb_ext and low > lq_run_ext)
    // effective stop and the entry window (last bar the pass price was offered)
    float _stopEff = not na(lq_hl_last) and (_long ? lq_hl_last > lq_swept_wick : lq_hl_last < lq_swept_wick) ? lq_hl_last : lq_swept_wick
    float _drawL   = _long ? nd_up : nd_dn
    if lq_reclaimed and not na(_drawL) and not na(_stopEff)
        float _passPx = (_drawL + min_rr * _stopEff) / (1.0 + min_rr)
        if _long ? low <= _passPx : high >= _passPx
            lq_ent_bar := bar_index
    bool _stopHit   = not na(lq_swept_wick) and (_long ? close < lq_swept_wick : close > lq_swept_wick)
    bool _sweepFail = not lq_reclaimed and not _armBar and bar_index > lq_swept_bar and (_long ? close < lq_swept_lvl : close > lq_swept_lvl)
    bool _noReclaim = not lq_reclaimed and bar_index - lq_swept_bar > reclaim_eff
    if _stopHit or _sweepFail or _structFail or _noReclaim
        lq_done := true
        lq_done_why := _stopHit ? 'stop ' + str.tostring(lq_swept_wick, format.mintick) + ' closed through' : _sweepFail ? 'sweep failed, closed back through ' + str.tostring(lq_swept_lvl, format.mintick) : _structFail ? 'structure failed, closed through ' + (_long ? 'higher low' : 'lower high') + (na(lq_hl_last) ? '' : ' ' + str.tostring(lq_hl_last, format.mintick)) : 'no reclaim in ' + str.tostring(reclaim_eff) + ' bars'
        lq_done_bar := bar_index
        lq_last_done_bar := bar_index
        lq_last_done_why := lq_done_why
// new-day reset
bool _newDay = ta.change(dayofmonth(time, tz_eff)) != 0
if day_reset and _newDay and lq_swept_side != 0
    if lq_done or not lq_reclaimed
        lq_done := true
        lq_done_why := 'new session'
        lq_done_bar := bar_index - done_show
    else
        lq_carried := true
// clear a DONE story to WAIT after done_show bars
if barstate.isconfirmed and lq_done and not na(lq_done_bar) and bar_index - lq_done_bar >= done_show
    lq_swept_side := 0
    lq_swept_lvl := na
    lq_swept_bar := na
    lq_swept_wick := na
    lq_reclaimed := false
    lq_reclaim_bar := na
    lq_rejected := false
    lq_reject_bar := na
    lq_done := false
    lq_done_why := ''
    lq_done_bar := na
    lq_passed := 0
    lq_carried := false
bool story_done_now = not na(lq_last_done_bar) and lq_last_done_bar == bar_index

// ─── STORY FIELDS — the only things the display is allowed to read ───────────
bool   rd_long   = lq_swept_side == -1
string rd_side   = rd_long ? 'LONG' : 'SHORT'
float  rd_draw   = lq_swept_side == -1 ? nd_up : lq_swept_side == 1 ? nd_dn : na
string rd_draw_src = lq_swept_side == -1 ? nd_up_src : lq_swept_side == 1 ? nd_dn_src : ''
bool   rd_trailed = lq_swept_side != 0 and not na(lq_hl_last) and (rd_long ? lq_hl_last > lq_swept_wick : lq_hl_last < lq_swept_wick)
float  rd_stop   = lq_swept_side == 0 ? na : rd_trailed ? lq_hl_last : lq_swept_wick
float  rd_width  = lq_swept_side == 0 or na(rd_stop) or nz(atr) <= 0 ? na : math.abs(close - rd_stop) / atr
float  rd_rew    = na(rd_draw) ? na : math.abs(rd_draw - close)
float  rd_risk   = na(rd_stop) ? na : math.abs(close - rd_stop)
float  rd_rr     = na(rd_rew) or na(rd_risk) or rd_risk <= 0 ? na : rd_rew / rd_risk
bool   rd_stop_wrong = lq_swept_side != 0 and not na(rd_stop) and (rd_long ? rd_stop >= close : rd_stop <= close)
float  tf_min    = timeframe.in_seconds(timeframe.period) / 60.0
float  rd_eta    = na(rd_draw) or na(atr) or atr <= 0 ? na : math.ceil(math.abs(rd_draw - close) / atr)
float  rd_pass   = na(rd_draw) or na(rd_stop) ? na : (rd_draw + min_rr * rd_stop) / (1.0 + min_rr)
bool   rd_bias_ok = htf_state == 0 or htf_state == (rd_long ? 1 : -1)
bool   rd_trend_ok = trend_dir == 0 or trend_dir == (rd_long ? 1 : -1)
bool   rd_counter = not rd_bias_ok and not rd_trend_ok
bool   rd_fresh  = story_armed and not na(rd_rr) and rd_rr >= min_rr and not na(rd_width) and rd_width <= max_stop_atr and not rd_stop_wrong
// state: 0 WAIT · 1 WATCH · 2 STAND DOWN (bias, before arm) · 3 LONG/SHORT fresh · 4 RUNNING · 5 DONE
int rd_state = lq_swept_side == 0 ? 0 : lq_done ? 5 : not lq_reclaimed ? 1 : not story_armed ? 1 : rd_fresh ? 3 : 4
if rd_state == 1 and lq_reclaimed and not rd_bias_ok
    rd_state := 2
string rd_state_txt = rd_state == 0 ? 'WAIT' : rd_state == 1 ? 'WATCH' : rd_state == 2 ? 'STAND DOWN' : rd_state == 3 ? rd_side : rd_state == 4 ? rd_side + ' running' : 'DONE'
color  rd_col = rd_state == 0 or rd_state == 5 ? #B8B8C8 : rd_state == 2 ? color.red : rd_state == 1 ? #C9A227 : rd_long ? c_bull : c_bear
// likely path: next two untouched pools in the trend direction (falls back to the nearest-draw direction)
int    _pd = lq_swept_side != 0 and not lq_done and lq_reclaimed ? (rd_long ? 1 : -1) : trend_dir != 0 ? trend_dir : nd_dir
float  path1 = _pd == 1 ? nd_up : _pd == -1 ? nd_dn : na
float  path2 = _pd == 1 ? nd_up2 : _pd == -1 ? nd_dn2 : na
string path1_src = _pd == 1 ? nd_up_src : _pd == -1 ? nd_dn_src : ''
string path2_src = _pd == 1 ? nd_up2_src : _pd == -1 ? nd_dn2_src : ''
string likely_txt = na(path1) ? 'no pool ' + (_pd == -1 ? 'below' : 'above') + ', price discovery' : str.tostring(path1, format.mintick) + (path1_src == '' ? '' : ' ' + path1_src) + (na(path2) ? '' : ', then ' + str.tostring(path2, format.mintick) + (path2_src == '' ? '' : ' ' + path2_src))
// my entry
bool   rd_my_on = my_entry > 0 and lq_swept_side != 0 and not lq_done and not na(rd_stop) and (rd_long ? my_entry > rd_stop : my_entry < rd_stop)
bool   rd_my_against = my_entry > 0 and lq_swept_side != 0 and not lq_done and not na(rd_stop) and not rd_my_on
float  rd_my_r  = not rd_my_on ? na : (rd_long ? close - my_entry : my_entry - close) / math.abs(my_entry - rd_stop)
// journal
// [v0.6.7] Hard length cap — applied to the live story line AND every journal
// row so neither can grow wide enough to overlap the panel or chart annotations.
f_trunc(string _s, int _n) =>
    str.length(_s) > _n ? str.substring(_s, 0, _n - 1) + '…' : _s
var array<string> jrn = array.new<string>()
if journal_on and story_done_now and barstate.isconfirmed
    array.push(jrn, f_trunc(str.format_time(time, 'HH:mm', tz_eff) + ' ' + rd_side + ', passed ' + str.tostring(lq_passed) + ', entry ' + (na(lq_ent_bar) ? 'not offered' : 'offered') + ', ' + lq_last_done_why, story_max_chars))
    if array.size(jrn) > journal_rows
        array.shift(jrn)

// ─── BRIDGE EXPORTS — read by ULTRA via input.source ─────────────────────────
// lq_state encoding: ±3 swept, reclaimed AND rejected (the level has flipped)
//                     ±2 swept AND reclaimed · ±1 swept only · 0 none
// [v0.5.5] ±3 IS NEW. A consumer that tests `abs(lq_state) == 2` for "reclaimed"
// will stop matching once a level is rejected, because the state advances past
// it. Test `abs(lq_state) >= 2` instead. Same class of mistake as the v0.5.1
// pool-counter bug, which counted state 1 only and missed everything that had
// moved on to state 2.
// (+ = buyside pool taken, − = sellside pool taken)
// [v0.4.1] The four ULTRA-consumed exports are numbered BRIDGE 1–4 and listed
// first, so wiring in ULTRA's source dropdowns is a plain number match:
// ULTRA "BRIDGE n" field → MBF LIQ "BRIDGE n · …". No guessing.
plot(lq_done ? 0 : lq_swept_side * (lq_rejected ? 3 : lq_reclaimed ? 2 : 1), 'BRIDGE 1 · lq_state', display=display.data_window)
plot(na(lq_swept_bar) ? 9999 : bar_index - lq_swept_bar, 'BRIDGE 2 · lq_age', display=display.data_window)
plot(lq_swept_wick, 'BRIDGE 3 · lq_swept_wick', display=display.data_window)
plot(nd_lvl, 'BRIDGE 4 · nd_level', display=display.data_window)
plot(nd_dir, 'nd_dir', display=display.data_window)
plot(br_state, 'br_state', display=display.data_window)
plot(lq_swept_lvl, 'lq_swept_lvl', display=display.data_window)
// [v0.5.0] RZ-contribution exports — appended LAST so BRIDGE 1-4 links are untouched:
plot(htf_state, 'htf_state', display=display.data_window)
plot(ltf_choch_confirmed ? 1 : 0, 'ltf_choch', display=display.data_window)
plot(rd_state, 'rd_state', display=display.data_window)
plot(rd_stop, 'rd_stop', display=display.data_window)
plot(rd_draw, 'rd_draw', display=display.data_window)

f_row(table _t, int r, string k, string v, color cv) =>
    table.cell(_t, 0, r, k, text_color=c_ptx, text_size=SZ_PNL, text_halign=text.align_left)
    table.cell(_t, 1, r, v, text_color=cv, text_size=SZ_PNL, text_halign=text.align_right)

// [v0.2.3] pull score: source weight × touch count ÷ ATR-normalized distance.
// PWH/PWL carry the most conviction, then PDH/PDL, then EQ clusters, then
// session extremes, then plain swings. Closer + heavier = stronger magnet.
// [v0.3.2] f_srcw itself moved ABOVE the state machine (story-ownership rule
// needs it); the weighting is unchanged.

f_pull(Pool p) =>
    float _d = math.max(math.abs(p.lvl - close) / math.max(atr, syminfo.mintick), 0.5)
    f_srcw(p.src) * p.touches / _d

f_pullbar(float _sc, float _smax) =>
    int _n = math.round(5 * _sc / math.max(_smax, 0.0001))
    string _b = ''
    for k = 1 to 5
        _b += k <= _n ? '#' : '.'
    _b

f_mag_row(table _t, int _r, int _idx, float _sc, float _smax) =>
    if _idx >= 0
        Pool p = array.get(pools, _idx)
        int _n = math.round(5 * _sc / math.max(_smax, 0.0001))
        string _bar = ''
        for k = 1 to 5
            _bar += k <= _n ? '#' : '.'
        f_row(_t, _r, (p.buyside ? 'above ' : 'below ') + p.src, str.tostring(p.lvl, format.mintick) + '  ' + _bar, p.buyside ? c_buy : c_sell)
    else
        f_row(_t, _r, '-', '-', color.gray)


// ─── [v0.3] RADAR VISUALS — clean-room reimplementation ──────────────────────
int n_live  = 0
int n_swept = 0
int n_recl  = 0
int n_taken = 0
if barstate.islast and array.size(pools) > 0
    for i = 0 to array.size(pools) - 1
        Pool p = array.get(pools, i)
        // [v0.5.1] state 1 = swept-and-awaiting-reclaim (TRANSIENT). A pool that
        // reclaims moves to state 2 the same bar or shortly after, so counting
        // only state 1 made the panel read "/ 0" on exactly the setups that
        // completed — the tradeable ones. Sweeps are now counted as TAKEN
        // (state 1 or 2) with reclaims broken out separately.
        n_live  += p.state == 0 ? 1 : 0
        n_swept += p.state == 1 ? 1 : 0
        n_recl  += (p.state == 2 or p.state == 5) ? 1 : 0
        n_taken += (p.state == 1 or p.state == 2 or p.state == 5) ? 1 : 0


// ─── STORYTELLER — one plain sentence, journal above it ──────────────────────
var table st_tbl = na
var string st_pos_prev = ''
var int st_rows_prev = -1
if show_story and barstate.islast
    int _jr = journal_on ? journal_rows : 0
    if story_pos_s != st_pos_prev or na(st_tbl) or _jr != st_rows_prev
        table.delete(st_tbl)
        st_tbl := table.new(f_pos(story_pos_s), 1, 1 + _jr)
        st_pos_prev := story_pos_s
        st_rows_prev := _jr
    string _draw_s = na(rd_draw) ? 'no pool left, price discovery' : str.tostring(rd_draw, format.mintick) + (rd_draw_src == '' ? '' : ' (' + rd_draw_src + ')')
    string _stop_s = na(rd_stop) ? '' : str.tostring(rd_stop, format.mintick) + (rd_trailed ? ', trailed' : '')
    string _rr_s   = na(rd_rr) ? '' : str.tostring(rd_rr, '#.#') + ' to 1'
    string _eta_s  = na(rd_eta) ? '' : 'about ' + str.tostring(rd_eta, '#') + ' bars' + (rd_eta * tf_min > clock_min ? ', past your clock' : '')
    string _bias_s = rd_counter ? ' Bias on ' + htf_eff + ' and the trend are both against it. Counter-trend scalp only, quarter size, or skip.' : (rd_bias_ok ? '' : ' Bias on ' + htf_eff + ' is against it, half size.') + (rd_trend_ok ? '' : ' Against the trend.')
    string _test_s = rd_stop_wrong ? ' Stop ' + str.tostring(rd_stop, format.mintick) + ' is being tested, story ends if this bar closes ' + (rd_long ? 'below' : 'above') + ' it.' : ''
    string _my_s   = rd_my_against ? ' YOUR POSITION IS AGAINST THE STORY. EXIT.' : not rd_my_on ? '' : ' You are ' + (rd_my_r >= 0 ? 'up ' : 'down ') + str.tostring(math.abs(rd_my_r), '#.##') + ' R' + (rd_my_r >= 1.0 ? ', move stop to breakeven at ' + str.tostring(my_entry, format.mintick) : '') + '.'
    string _passed_s = lq_passed > 0 ? ' Passed ' + str.tostring(lq_passed) + ' pool' + (lq_passed > 1 ? 's' : '') + '.' : ''
    string _carried_s = lq_carried ? ' Carried from the prior session.' : ''
    bool _trending = not na(last_break_bar) and bar_index - last_break_bar <= 20
    string _line_full = rd_state == 0 ? 'WAIT. No story. Trend ' + trend_txt + '. Likely ' + likely_txt + '. Needs a wick to take a pool and close back.' :
         rd_state == 5 ? 'DONE. ' + lq_done_why + '. Wait for a fresh sweep.' :
         rd_state == 1 and not lq_reclaimed ? 'WATCH. ' + (rd_long ? 'Sellside' : 'Buyside') + ' swept at ' + str.tostring(lq_swept_lvl, format.mintick) + '. ' + rd_side + ' if it closes back ' + (rd_long ? 'above' : 'below') + ' within ' + str.tostring(math.max(0, reclaim_eff - (bar_index - lq_swept_bar))) + ' bars. Target ' + _draw_s + '. Wrong at ' + _stop_s + '.' + ((rd_long ? close < lq_swept_lvl : close > lq_swept_lvl) ? ' Price is back through the level. Failing unless it closes back.' : '') :
         rd_state == 1 ? 'WATCH. Reclaimed ' + str.tostring(lq_swept_lvl, format.mintick) + '. ' + rd_side + ' once the ' + ltf_eff + ' breaks structure. Target ' + _draw_s + '. Wrong at ' + _stop_s + '.' :
         rd_state == 2 ? 'STAND DOWN. Sweep says ' + rd_side + ', bias on ' + htf_eff + ' says ' + (htf_state == 1 ? 'up' : 'down') + '. No side until it arms.' :
         rd_state == 3 ? rd_side + '. Target ' + _draw_s + '. Stop ' + _stop_s + '. Reward ' + _rr_s + '. ' + _eta_s + '.' + _bias_s + _my_s + _passed_s + _carried_s :
         rd_side + ' running. Target ' + _draw_s + '. Stop ' + _stop_s + '.' + _test_s + (na(rd_rr) or rd_stop_wrong ? '' : ' Reward here ' + _rr_s + ', no fresh entry.') + (na(rd_pass) ? '' : ' Fresh entry at ' + str.tostring(rd_pass, format.mintick) + (rd_long ? ' or lower' : ' or higher') + (na(lq_ent_bar) ? '' : ', last offered ' + str.tostring(bar_index - lq_ent_bar) + ' bars ago') + '.') + _bias_s + _my_s + _passed_s + _carried_s
    // [v0.6.7] COMPACT — keeps only state, target, stop, and the one live-position
    // warning that must never get dropped (EXIT / move-to-BE). Everything else
    // (bias footnotes, pools-passed, carried-over, ETA prose) already lives in
    // the Story/Target/Stop/Do panel rows, so trimming it here is not losing
    // information the person doesn't already have somewhere on the chart.
    string _short_my = rd_my_against ? ' EXIT — against the story.' : (rd_my_on and rd_my_r >= 1.0) ? ' Move stop to BE.' : ''
    string _line_compact = rd_state == 0 ? 'WAIT. Likely ' + likely_txt + '.' :
         rd_state == 5 ? 'DONE. Wait for a fresh sweep.' :
         rd_state == 1 and not lq_reclaimed ? 'WATCH. ' + (rd_long ? 'Sellside' : 'Buyside') + ' swept ' + str.tostring(lq_swept_lvl, format.mintick) + '. Target ' + _draw_s + '.' :
         rd_state == 1 ? 'WATCH. Reclaimed ' + str.tostring(lq_swept_lvl, format.mintick) + '. Target ' + _draw_s + '.' :
         rd_state == 2 ? 'STAND DOWN. ' + rd_side + ' vs bias.' :
         rd_state == 3 ? rd_side + '. Target ' + _draw_s + '. Stop ' + _stop_s + '. R ' + _rr_s + '.' + _short_my :
         rd_side + ' running. Target ' + _draw_s + '. Stop ' + _stop_s + '.' + _short_my
    string _line = f_trunc(story_compact ? _line_compact : _line_full, story_max_chars)
    if _jr > 0
        for r = 0 to _jr - 1
            int _ji = array.size(jrn) - _jr + r
            table.cell(st_tbl, 0, r, _ji >= 0 ? array.get(jrn, _ji) : '', text_color=#CFCFD8, bgcolor=color.new(c_stbg, 0), text_size=SZ_ST2)
    table.cell(st_tbl, 0, _jr, _line, text_color=rd_state == 3 or rd_state == 4 ? rd_col : c_ptx, bgcolor=color.new(c_stbg, 0), text_size=SZ_ST)
else if not show_story and not na(st_tbl)
    table.delete(st_tbl)
    st_tbl := na

// ── DELIVERY MAP — MAGNET / LEVEL / PULL, ▶ on the strongest ──
var table dm_tbl = na
var string dm_pos_prev = dmap_pos_s
if show_dmap and barstate.islast
    if dmap_pos_s != dm_pos_prev or na(dm_tbl)
        table.delete(dm_tbl)
        dm_tbl := table.new(f_pos(dmap_pos_s), 3, dmap_rows + 1, bgcolor=color.new(c_pnl, 12), frame_color=color.new(c_sell, 60), frame_width=1)
        dm_pos_prev := dmap_pos_s
    table.cell(dm_tbl, 0, 0, 'STRONGEST', text_color=#111111, text_size=SZ_PNL, bgcolor=color.new(c_hdr, 35))
    table.cell(dm_tbl, 1, 0, 'LEVEL',  text_color=#111111, text_size=SZ_PNL, bgcolor=color.new(c_hdr, 35))
    table.cell(dm_tbl, 2, 0, 'PULL',   text_color=#111111, text_size=SZ_PNL, bgcolor=color.new(c_hdr, 35))
    var array<int>   dm_idx = array.new<int>()
    var array<float> dm_sc  = array.new<float>()
    array.clear(dm_idx)
    array.clear(dm_sc)
    if array.size(pools) > 0
        for r = 1 to dmap_rows
            int _bi = -1
            float _bs = 0.0
            for i = 0 to array.size(pools) - 1
                Pool p = array.get(pools, i)
                if p.state == 0 and not array.includes(dm_idx, i)
                    float _sc = f_pull(p)
                    if _sc > _bs
                        _bs := _sc
                        _bi := i
            if _bi >= 0
                array.push(dm_idx, _bi)
                array.push(dm_sc, _bs)
    float dm_top = array.size(dm_sc) > 0 ? array.get(dm_sc, 0) : 1.0
    for r = 1 to dmap_rows
        if r <= array.size(dm_idx)
            Pool p = array.get(pools, array.get(dm_idx, r - 1))
            float _sc = array.get(dm_sc, r - 1)
            color _cc = p.buyside ? c_buy : c_sell
            table.cell(dm_tbl, 0, r, (p.buyside ? 'above ' : 'below ') + p.src, text_color=_cc, text_size=SZ_PNL, text_halign=text.align_left)
            table.cell(dm_tbl, 1, r, str.tostring(p.lvl, format.mintick), text_color=c_ptx, text_size=SZ_PNL, text_halign=text.align_right)
            table.cell(dm_tbl, 2, r, f_pullbar(_sc, dm_top), text_color=_cc, text_size=SZ_PNL, text_halign=text.align_left)
        else
            table.cell(dm_tbl, 0, r, '', text_size=SZ_PNL)
            table.cell(dm_tbl, 1, r, '', text_size=SZ_PNL)
            table.cell(dm_tbl, 2, r, '', text_size=SZ_PNL)
else if not na(dm_tbl)
    table.delete(dm_tbl)
    dm_tbl := na


// ─── NEXT DRAW — the chart marker (first level of the Likely path) ──────────
var line  nd_ln = na
var label nd_lb = na
if show_nd_mk and barstate.islast and not na(path1)
    line.delete(nd_ln)
    label.delete(nd_lb)
    color _nc = _pd == 1 ? c_bull : c_bear
    nd_ln := line.new(bar_index - 30, path1, bar_index + 8, path1, color=_nc, width=2, style=line.style_solid)
    nd_lb := label.new(bar_index + 8, path1, 'NEXT DRAW ' + (_pd == 1 ? 'above ' : 'below ') + str.tostring(path1, format.mintick) + (path1_src == '' ? '' : ' ' + path1_src), style=label.style_label_left, color=color.new(c_pnl, 0), textcolor=_nc, size=SZ_MAJ)
else if barstate.islast
    line.delete(nd_ln)
    label.delete(nd_lb)
    nd_ln := na
    nd_lb := na

// ── ⚡ badge ──
var table z_tbl = na
if show_badge and barstate.islast
    if na(z_tbl)
        z_tbl := table.new(position.bottom_right, 1, 1)
    table.cell(z_tbl, 0, 0, 'R', text_color=#AA00FF, bgcolor=color.new(c_pnl, 35), text_size=SZ_PNL)
else if not na(z_tbl)
    table.delete(z_tbl)
    z_tbl := na


// ─── PANEL — Story / Target / Stop / Do / Pools ──────────────────────────────
f_prow(table _t, int r, string k, string v, color cv, string tip = '') =>
    table.cell(_t, 0, r, k, text_color=c_ptx, text_size=SZ_PLAIN, text_halign=text.align_left, bgcolor=color.new(c_pnl, 0))
    table.cell(_t, 1, r, v, text_color=cv, text_size=SZ_PLAIN, text_halign=text.align_right, bgcolor=color.new(c_pnl, 0), tooltip=tip)
var table t = na
var string t_sig = ''
if show_panel and barstate.islast
    bool _full = panel_mode == 'Full'
    int  _rows = 8 + (_full ? 4 : 0)
    string _sig = panel_pos_s + str.tostring(_rows) + plain_sz_s
    if _sig != t_sig
        table.delete(t)
        t := na
        t_sig := _sig
    if na(t)
        t := table.new(panel_pos, 2, _rows, bgcolor=color.new(c_pnl, 0), frame_color=color.new(c_hdr, 40), frame_width=1)
    table.cell(t, 0, 0, 'MBF & RZ LIQUIDITY - ' + chart_role + ' ' + timeframe.period, text_color=#111111, text_size=SZ_PNL, text_halign=text.align_left, bgcolor=color.new(c_hdr, 35))
    table.cell(t, 1, 0, '', bgcolor=color.new(c_hdr, 35))
    string _story = rd_state_txt + (rd_state >= 3 and rd_state <= 4 ? (rd_counter ? ', counter-trend' : not rd_bias_ok ? ', half size' : not rd_trend_ok ? ', against trend' : '') : '')
    string _target = lq_swept_side == 0 or lq_done ? '-' : na(rd_draw) ? 'discovery' : str.tostring(rd_draw, format.mintick) + (rd_draw_src == '' ? '' : ' ' + rd_draw_src) + (lq_passed > 0 ? ', passed ' + str.tostring(lq_passed) : '')
    string _stop = lq_swept_side == 0 or lq_done or na(rd_stop) ? '-' : str.tostring(rd_stop, format.mintick) + (rd_trailed ? ' trailed' : '') + (na(rd_width) ? '' : ', ' + str.tostring(rd_width, '#.#') + ' ATR')
    string _do = rd_state == 0 ? (not na(last_break_bar) and bar_index - last_break_bar <= 20 ? 'trend, wait for a sweep' : 'nothing') :
         rd_state == 5 ? 'wait for a fresh sweep' :
         rd_my_against ? 'AGAINST THE STORY, EXIT' :
         rd_state == 4 and rd_stop_wrong ? 'stop being tested, ends on a close through' :
         rd_my_on ? 'hold, ' + (rd_my_r >= 0 ? 'up ' : 'down ') + str.tostring(math.abs(rd_my_r), '#.##') + ' R' + (rd_my_r >= 1.0 ? ', stop to breakeven' : '') :
         rd_state == 1 and not lq_reclaimed ? 'wait for the close back' :
         rd_state == 1 ? 'wait for the ' + ltf_eff + ' break' :
         rd_state == 2 ? 'stand down, bias against' :
         rd_state == 3 and not na(rd_eta) and rd_eta * tf_min > clock_min ? 'past your clock, about ' + str.tostring(rd_eta, '#') + ' bars here' + (is_trigger ? '' : ', use the 1m trigger') :
         rd_state == 3 and rd_counter ? 'counter-trend scalp only, quarter size, or skip, reward ' + str.tostring(rd_rr, '#.#') + ' to 1' :
         rd_state == 3 ? 'go, reward ' + str.tostring(rd_rr, '#.#') + ' to 1' + (na(rd_eta) ? '' : ', about ' + str.tostring(rd_eta, '#') + ' bars') + (is_trigger ? '' : ', trigger on 1m') :
         'hold, fresh entry at ' + (na(rd_pass) ? '-' : str.tostring(rd_pass, format.mintick)) + (my_entry == 0 ? ', set my entry' : '')
    string _pools = (lq_swept_side == 0 ? 'none' : (lq_swept_side == 1 ? 'buyside ' : 'sellside ') + str.tostring(lq_swept_lvl, format.mintick) + ' ' + (lq_done ? 'done' : lq_rejected ? 'rejected' : lq_reclaimed ? 'reclaimed' : 'swept')) + ', live ' + str.tostring(n_live) + ', taken ' + str.tostring(n_taken)
    f_prow(t, 1, 'Story',  _story, rd_col)
    f_prow(t, 2, 'Target', _target, lq_swept_side == 0 or lq_done ? #B8B8C8 : rd_long ? c_bull : c_bear)
    f_prow(t, 3, 'Stop',   _stop, lq_swept_side == 0 or lq_done ? #B8B8C8 : c_ptx)
    f_prow(t, 4, 'Do',     _do, rd_my_against ? color.red : rd_col)
    f_prow(t, 5, 'Pools',  _pools, #B8B8C8)
    f_prow(t, 6, 'Trend',  trend_txt, trend_col, trend_why)
    f_prow(t, 7, 'Likely', likely_txt, trend_col)
    if _full
        f_prow(t, 8, 'Bias ' + htf_eff, show_htf ? htf_txt : 'off', show_htf ? htf_col : #B8B8C8)
        f_prow(t, 9, 'Break ' + ltf_eff, not use_ltf_choch ? 'off' : lq_swept_side == 0 or lq_done ? '-' : ltf_choch_confirmed ? 'confirmed' : 'waiting', not use_ltf_choch or lq_swept_side == 0 or lq_done ? #B8B8C8 : ltf_choch_confirmed ? color.lime : #C9A227)
        f_prow(t, 10, 'Breadth', br_state == 0 ? 'offline' : br_txt, br_col)
        f_prow(t, 11, 'Mode', resp_mode + ', window ' + str.tostring(reclaim_eff) + ' bars', #B8B8C8)
else if not show_panel and not na(t)
    table.delete(t)
    t := na


// ─── ALERTS ──────────────────────────────────────────────────────────────────
var int rd_state_prev = -1
bool rd_changed = barstate.isconfirmed and rd_state != rd_state_prev
if barstate.isconfirmed
    rd_state_prev := rd_state
alertcondition(lq_swept_side != 0 and lq_swept_bar == bar_index, 'Liquidity swept', 'MBF LIQ: a pool was taken. Story started, watch for the reclaim.')
alertcondition(lq_reclaimed and lq_reclaim_bar == bar_index, 'Sweep reclaimed', 'MBF LIQ: swept level reclaimed.')
alertcondition(rd_changed and rd_state == 3, 'Side offered', 'MBF LIQ: fresh LONG or SHORT passing every gate. Read Target, Stop, Do, then the bracket.')
alertcondition(rd_changed, 'Radar state changed', 'MBF LIQ: state changed. Read the panel.')
alertcondition(story_done_now, 'Story complete', 'MBF LIQ: story DONE. Flat until a fresh sweep.')
````
