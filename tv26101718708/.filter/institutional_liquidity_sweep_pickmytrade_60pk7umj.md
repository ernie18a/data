# Institutional Liquidity Sweep [PickMyTrade]

- url: https://www.tradingview.com/script/60Pk7UmJ-Institutional-Liquidity-Sweep-PickMyTrade/
- type: indicator
- pine_id: PUB;70e9305bdead4012add7db8964b83378
- version: 1.0

## Description

[b]Institutional Liquidity Sweep [PickMyTrade][/b] identifies institutional stop-hunt reversals by measuring five structural microstructure factors at every confirmed swing-level sweep and combining them into a single, readable Confluence Score. When the score clears a configurable threshold — and the sweep aligns with an active Order Block — the indicator fires a directional signal with a score label, an SL/TP projection, and an auto-mitigating OB zone on the chart.

Unlike fixed-threshold crossover tools, this indicator does not assume that every wick below a swing low or above a swing high is meaningful. It asks a structural question instead: [i]given the depth of the sweep, the absorption shown in order flow, the session timing, and whether an institutional Order Block was sitting at that level — how strong is the reversal case?[/i] Five factors answer that question and a weighted score between 0 and 100 summarises the result on every bar.

────────────────────────────────────────────────────────

[b]🔷 WHAT IT MEASURES[/b]

[b]🔸 Swing-Level Sweep Detection[/b]

A bullish sweep is confirmed when the current bar's wick pierces the N-bar swing low while the close returns above it. A bearish sweep is the mirror: wick above the swing high, close back below. The swing level uses a confirmed lookback — no current-bar values enter the swing calculation — making the sweep detection fully non-repainting. This single structural requirement gates the entire indicator: the five factors and the Order Block check only matter on a bar that has already swept a swing level.

[b]🔸 F1 — Wick Rejection Purity (weight 28%)[/b]

How much of the sweep wick was recovered within the same bar? A bar that sweeps 20 points below the swing low but closes only 2 points above it has poor rejection. A bar that sweeps 20 points and closes back near the top of its range has high rejection purity. This factor is z-score normalised over a rolling window so that the same numeric value carries the same weight regardless of instrument volatility.

[b]🔸 F2 — Volume Participation (weight 20%)[/b]

Volume at the sweep bar is z-score normalised against recent history. Elevated volume confirms institutional participation: a stop hunt that clears retail orders but attracts heavy buy (sell) pressure is more likely to reverse than one with below-average volume. A sweep on thin volume gets a low F2 score even if the rejection wick looks clean.

[b]🔸 F3 — CVD Net Absorption (weight 25%)[/b]

Cumulative volume delta tracks the net order flow direction using the close-position formula [pine]bull_vol = volume * (close - low) / (high - low)[/pine]. The single-bar delta at the sweep bar is z-score normalised and sign-adjusted: a bullish sweep wants a positive delta (buyers absorbed the down-spike); a bearish sweep wants a negative delta (sellers absorbed the up-spike). When order flow and price action agree on the reversal, F3 scores high. When they disagree — price sweeps down but sellers are still dominant — F3 penalises the composite score.

[b]🔸 F4 — Structural Recovery (weight 17%)[/b]

How far did the close reclaim the swept swing level relative to the depth of the sweep? If a bar sweeps 30 points below the swing low and closes 25 points above it, recovery is strong. If it closes only 2 points above the swing level having swept 30 points, recovery is weak. This factor rewards bars that decisively reclaim the institutional level rather than barely scratching back above it.

[b]🔸 F5 — Session Window (weight 10%)[/b]

Liquidity events during the London open (07:00–10:00 UTC by default) and the New York open (13:00–16:00 UTC by default) carry a higher institutional weight than off-peak sweeps. This factor scores 1.0 during the London window, 0.85 during the NY window, and 0.45 at all other times. Session hours are configurable in UTC and the session windows are highlighted on the chart.

────────────────────────────────────────────────────────

[b]🔷 THE COMPOSITE SCORE[/b]

Each factor is normalised to a 0–1 scale using z-score transformation. The five normalised scores are then combined with the weights above into a single composite score from 0 to 100:

[i]Score = (0.28 × F1 + 0.20 × F2 + 0.25 × F3 + 0.17 × F4 + 0.10 × F5) × 100[/i]

An Order Block alignment bonus (configurable, default 15 points) is added on top when the sweep level coincides with an active OB zone, with the score capped at 100. The threshold (default 65) is the minimum score required to fire a signal. Raising the threshold to 75–80 restricts signals to the highest-conviction sweeps; lowering it to 50 produces more signals on weaker structure.

────────────────────────────────────────────────────────

[b]🔷 ORDER BLOCKS[/b]

[b]🔸 Detection[/b]

A bullish Order Block is the last bearish candle before a sequence of N consecutive bullish candles (an upside impulse). A bearish Order Block is the last bullish candle before N consecutive bearish candles (a downside impulse). The impulse candle count is configurable (default 3). Only confirmed, closed bars enter the OB detection — no current-bar data is used.

[b]🔸 Zones[/b]

Each active OB is drawn as a persistent price zone box extending from the OB candle's high to its low. Bull OB zones use the bull colour; bear OB zones use the bear colour. When a new OB forms, the previous OB of the same direction is replaced. The right edge of each box extends bar-by-bar until mitigated.

[b]🔸 Mitigation[/b]

A bull OB is mitigated when price closes below the bottom of the zone. A bear OB is mitigated when price closes above the top. On mitigation the box is deleted and the zone is deregistered. The info table shows "Aligned" when the sweep level currently sits inside an active OB zone, "Active" when an OB exists but is not being swept, and "None" when no OB is registered.

[b]🔸 Score Bonus[/b]

When a sweep aligns with an active OB — meaning the swept swing level falls within the OB zone's price range — the composite score receives the OB bonus. This reflects the structural significance of a sweep-and-reversal occurring at a previously identified institutional reference level.

────────────────────────────────────────────────────────

[b]🔷 SESSION WINDOWS[/b]

London and New York open windows are highlighted on the chart as faint background tints (yellow for London, teal for NY). These are the hours during which institutional desks are most active and liquidity sweep events are most frequently observed. Session highlighting can be toggled off independently of the session weight applied to F5.

────────────────────────────────────────────────────────

[b]🔷 SIGNAL LOGIC[/b]

A long signal fires when three conditions are simultaneously true on the same bar:
[list=1]
[*]A bullish sweep is detected (wick below the N-bar swing low, close above it)
[*]The composite score meets or exceeds the threshold
[*]Price is above the trend EMA (macro direction filter)
[/list]

A short signal fires under the symmetric conditions using the swing high and requiring price to be below the EMA. The signal is edge-triggered — it fires once on the first qualifying bar and resets when conditions are no longer met. The signal label shows "ILS" followed by the rounded score (e.g. [i]ILS 72[/i]).

────────────────────────────────────────────────────────

[b]🔷 HOW TO READ IT[/b]

[b]🔸 Confluence Pressure Band[/b]

A fill band extends from the trend EMA to ±1 ATR. The opacity of the fill scales continuously with the composite score — a faint band indicates a low-scoring environment; a deep saturated band indicates a high-scoring environment even before a sweep fires.

[b]🔸 Entry Shapes[/b]

Circles indicate high-conviction signals (score ≥ 80); triangles indicate standard signals (score ≥ threshold). The shape appears at the sweep bar with a score label. Shapes are coloured at full intensity for high conviction and at 75% opacity for standard signals.

[b]🔸 OB Zone Boxes[/b]

Semi-transparent filled boxes mark active Order Block zones. They extend to the right on every bar until mitigated by a close through the zone boundary. When a sweep lands inside a box, the OB bonus is added to the score at that moment.

[b]🔸 Session Highlights[/b]

Faint yellow and teal background tints mark London and NY open windows respectively. Sweeps outside both windows score lower on F5 and require the other four factors to compensate.

[b]🔸 Info Table[/b]

The top-right table shows seven live values at every bar: the composite score, all five normalised factor scores (0–1), the active session, and the OB zone status. Factor scores above 0.60 are highlighted in lime green.

[b]🔸 SL / TP Lines[/b]

Dashed red and green lines mark the ATR-based stop loss and take profit levels at each signal bar. The SL is placed beyond the sweep wick by a configurable ATR multiple; the TP is set at the SL distance multiplied by the risk:reward ratio. Both lines extend 8 bars to the right and do not repaint.

────────────────────────────────────────────────────────

[b]🔷 INPUTS[/b]

[b]🔸 Sweep Detection[/b]
[list]
[*][i]Swing Lookback[/i] — N-bar window defining the swing high/low that must be swept. Default 20.
[/list]

[b]🔸 Confluence Score[/b]
[list]
[*][i]Score Threshold[/i] — minimum composite score (0–100) to fire a signal. Default 65.
[*][i]Normalisation Window[/i] — rolling window for z-score normalisation. Default 50.
[*][i]Order Block Score Bonus[/i] — additional points when sweep aligns with an OB zone. Default 15.
[/list]

[b]🔸 Order Blocks[/b]
[list]
[*][i]Show OB Zones[/i] — toggle OB box drawing.
[*][i]Impulse Candles Required[/i] — consecutive same-direction candles to identify an impulse. Default 3.
[/list]

[b]🔸 Session Windows[/b]
[list]
[*][i]Show Session Highlights[/i] — toggle background session tints.
[*][i]Chart Timezone[/i] — must match your chart timezone for accurate session hour detection.
[*][i]London Open Hour / NY Open Hour[/i] — start of each window in UTC. Defaults: London 7, NY 13.
[*][i]Window Width[/i] — hours each session window spans. Default 3.
[/list]

[b]🔸 Signal Levels[/b]
[list]
[*][i]Show SL / TP Lines[/i] — toggle projection lines.
[*][i]SL ATR Multiplier[/i] — stop loss distance as ATR multiple. Default 1.5.
[*][i]Risk : Reward[/i] — TP as a multiple of the SL distance. Default 2.0.
[*][i]ATR Period[/i] — Default 14.
[*][i]Trend EMA Period[/i] — macro direction filter. Default 50.
[/list]

[b]🔸 Visual / Display[/b]
[list]
[*][i]Bull / Bear Colour[/i] — base colours for all directional elements.
[*][i]Confluence Pressure Band[/i] — toggle the EMA fill band.
[*][i]Zen Mode[/i] — hides all text labels; only shapes and zones remain.
[*][i]Show Info Table[/i] — toggle the top-right factor breakdown table.
[/list]

────────────────────────────────────────────────────────

[b]🔷 REQUIREMENTS AND LIMITATIONS[/b]

The indicator requires a minimum of [i]Normalisation Window[/i] bars before z-score statistics are meaningful. On short-history charts or when first applied, z-scores will be zero and the score will rely primarily on F5 (session timing).

CVD is estimated from the close-position formula — a synthetic approximation of net order flow, not true bid/ask volume. On illiquid instruments or timeframes where intrabar price travel is minimal, the CVD delta is noisy and F3 will contribute less discriminative power.

Order Block detection uses a simplified impulse model (N consecutive same-direction closes). The single-active-OB-per-direction design is intentional: the indicator tracks the most recent OB, not a full library of zones.

Session timing is meaningful on intraday timeframes (15M through 4H). On daily or weekly charts, F5 will score at its off-peak value — toggle off session highlights on higher timeframes.

The composite score is a relative measure, not an absolute probability. A score of 72 means the current sweep bar shows strong structural confluence relative to normalised distributions — it does not imply a 72% probability of reversal.

────────────────────────────────────────────────────────

[i]Built natively in Pine Script® v6. Five-factor confluence scoring using z-score normalisation with rolling statistics, non-repainting swing-level sweep detection, auto-mitigating Order Block zones, and session-weighted structural analysis. No external libraries, no data feeds, no fixed lookback arrays.[/i]

[i]Open source — Mozilla Public License 2.0. Published by PickMyTrade_Official.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade — Institutional Liquidity Sweep [PMT]
//
// Identifies institutional stop-hunt reversals using a Multi-Factor Sweep
// Confluence Score (MFSCS) — five structural microstructure factors scored and
// weighted at every confirmed swing-level sweep bar:
//
//   F1 = Wick Rejection Purity   — fraction of sweep depth recovered in the same bar
//   F2 = Volume Participation    — volume z-score; elevated sweep volume = institutional
//   F3 = CVD Net Absorption      — order flow absorbed at the sweep bar (signed)
//   F4 = Structural Recovery     — how far the close reclaimed the swept swing level
//   F5 = Session Window          — London / NY open windows carry higher institutional weight
//
// An Order Block (OB) layer adds structural confluence: when a swing-level sweep
// aligns with a recently formed OB zone, the composite score receives a bonus.
// OB zones are drawn as persistent boxes and mitigated when price closes through them.
//
// Signal fires when:
//   · A confirmed swing-level wick sweep is detected (bar closes back inside the swing)
//   · Composite MFSCS score ≥ configurable threshold (0-100)
//   · Price is on the correct side of the trend EMA
// Non-repainting. No request.security() lookahead.

//@version=6
indicator(
    title            = "Institutional Liquidity Sweep [PMT]",
    shorttitle       = "ILS [PMT]",
    overlay          = true,
    max_labels_count = 50,
    max_lines_count  = 100,
    max_boxes_count  = 30
)

var string G_SWEEP = "Sweep Detection"
var string G_SCORE = "Confluence Score"
var string G_OB    = "Order Blocks"
var string G_SESS  = "Session Windows"
var string G_VIS   = "Visual"
var string G_RISK  = "Signal Levels"
var string G_ZEN   = "Zen / Display"
var string G_DBG   = "Developer Tools"

i_swing        = input.int  (20,   "Swing Lookback (bars)",       minval=5,  maxval=100, group=G_SWEEP,
    tooltip="N-bar swing high/low used to define liquidity levels. Wider = fewer but more significant sweeps.")

i_score_thresh = input.int  (65,   "Score Threshold (0-100)",     minval=20, maxval=95,  group=G_SCORE,
    tooltip="Minimum composite score (0-100) required to fire a signal. 50=permissive | 65=balanced (default) | 80=high conviction only.")
i_z_len        = input.int  (50,   "Normalisation Window",        minval=10, maxval=200, group=G_SCORE,
    tooltip="Rolling window for z-score normalisation across all five factors. Larger = more stable, slower to adapt to regime shifts.")
i_ob_bonus     = input.int  (15,   "Order Block Score Bonus",     minval=0,  maxval=30,  group=G_SCORE,
    tooltip="Score points added (0-100 scale) when the sweep level aligns with an active Order Block zone.")

show_ob        = input.bool (true,  "Show OB Zones",              group=G_OB)
i_ob_imp       = input.int  (3,    "Impulse Candles Required",    minval=2,  maxval=5,   group=G_OB,
    tooltip="Consecutive same-direction candles defining an impulse. The last opposing candle before the impulse becomes the Order Block.")

show_session   = input.bool (true,  "Show Session Highlights",    group=G_SESS,
    tooltip="Shades the London and NY open windows — the most active hours for institutional order flow. The session weight (F5) is applied regardless of whether highlights are shown.")
i_tz           = input.string("UTC", "Chart Timezone",            group=G_SESS,
    options=["UTC", "America/New_York", "Europe/London", "Asia/Tokyo"],
    tooltip="Must match your chart timezone for correct session detection.")
i_lon_hr       = input.int  (7,    "London Open Hour (UTC)",      minval=0, maxval=23,   group=G_SESS,
    tooltip="Start of the London session window in UTC hours. Default 7 = 07:00 UTC.")
i_ny_hr        = input.int  (13,   "NY Open Hour (UTC)",          minval=0, maxval=23,   group=G_SESS,
    tooltip="Start of the NY session window in UTC hours. Default 13 = 13:00 UTC.")
i_sess_hrs     = input.int  (3,    "Window Width (hours)",        minval=1, maxval=6,    group=G_SESS,
    tooltip="How many hours each session window spans from its open hour.")

show_levels    = input.bool (true,  "Show SL / TP Lines",         group=G_RISK)
sl_atr_mult    = input.float(1.5,   "SL ATR Multiplier",          minval=0.5, maxval=5.0,  step=0.1, group=G_RISK, active=show_levels)
rr_ratio       = input.float(2.0,   "Risk : Reward",              minval=0.5, maxval=10.0, step=0.1, group=G_RISK, active=show_levels)
atr_period     = input.int  (14,    "ATR Period",                 minval=5,  maxval=50,              group=G_RISK)
ema_period     = input.int  (50,    "Trend EMA Period",           minval=5,  maxval=500,             group=G_RISK,
    tooltip="Longs only above this EMA, shorts only below. Prevents counter-trend sweep signals during trending markets.")

bull_col       = input.color(color.new(#2962FF, 0), "Bull Colour", group=G_VIS)
bear_col       = input.color(color.new(#FF6D00, 0), "Bear Colour", group=G_VIS)
show_band      = input.bool (true,  "Confluence Pressure Band",   group=G_VIS,
    tooltip="EMA fill band whose opacity scales continuously with the current sweep confluence score.")

zen_mode       = input.bool (false, "Zen Mode (hide text labels)", group=G_ZEN,
    tooltip="Hides all text labels. Only shapes and zones remain — ideal for screenshots and live use.")
show_table     = input.bool (true,  "Show Info Table",             group=G_ZEN)

dbg_on         = input.bool (false, "Enable Developer Tools",      group=G_DBG,
    tooltip="Activates diagnostic overlays: swing level lines, per-sweep markers, score breakdown labels, OB formation marks, and Pine Script console logging. Off by default.")
dbg_swing      = input.bool (true,  "Show Swing Levels",           group=G_DBG,
    tooltip="Plots the sw_hi and sw_lo step-lines the sweep detector measures against. Useful for confirming the lookback window is set correctly.")
dbg_sweeps     = input.bool (true,  "Mark ALL Sweep Bars",         group=G_DBG,
    tooltip="Marks every bar where a sweep is detected — including those blocked by the score threshold or EMA filter. Separates detection from signal filtering.")
dbg_obs        = input.bool (true,  "Mark OB Formation Bars",      group=G_DBG,
    tooltip="Places a cross on the bar where each Order Block is confirmed, so you can verify the impulse lookback is identifying the correct candle.")
dbg_labels     = input.bool (true,  "Score Labels on Sweep Bars",  group=G_DBG,
    tooltip="Shows a compact breakdown label on every sweep bar: composite score, all five factor values, OB bonus, and the reason the signal fired or was filtered.")
dbg_console    = input.bool (true,  "Console Log on Sweeps",       group=G_DBG,
    tooltip="Logs factor values to the Pine Script console on every sweep bar. Open the console via the Pine Editor to inspect values.")

norm_z(float z) =>
    math.min(1.0, math.max(0.0, (z + 3.0) / 6.0))

float atr       = ta.atr(atr_period)
float ema_line  = ta.ema(close, ema_period)
bool  above_ema = close > ema_line
bool  below_ema = close < ema_line

float hl_rng    = high - low + syminfo.mintick
var float cvd   = 0.0
cvd := cvd + volume * (close - low) / hl_rng - volume * (high - close) / hl_rng
float cvd_delta = ta.change(cvd, 1)

float sw_lo     = ta.lowest (low,  i_swing)[1]
float sw_hi     = ta.highest(high, i_swing)[1]

bool bull_sweep = low  < sw_lo and close > sw_lo
bool bear_sweep = high > sw_hi and close < sw_hi

float sdepth_b  = sw_lo - low  + syminfo.mintick
float sdepth_s  = high  - sw_hi + syminfo.mintick
float f1_bull   = bull_sweep ? math.min(1.0, (close - low)   / sdepth_b) : 0.0
float f1_bear   = bear_sweep ? math.min(1.0, (high  - close) / sdepth_s) : 0.0
float f1_neut   = (high - low) > 0 ? (close - low) / (high - low) : 0.5
float f1_raw    = bull_sweep ? f1_bull : (bear_sweep ? f1_bear : f1_neut)
float f1_mu     = ta.sma  (f1_raw, i_z_len)
float f1_sd     = ta.stdev(f1_raw, i_z_len)
float f1_z      = f1_sd > 0 ? (f1_raw - f1_mu) / f1_sd : 0.0

float f2_mu     = ta.sma  (volume, i_z_len)
float f2_sd     = ta.stdev(volume, i_z_len)
float f2_z      = f2_sd > 0 ? (volume - f2_mu) / f2_sd : 0.0

float f3_mu     = ta.sma  (cvd_delta, i_z_len)
float f3_sd     = ta.stdev(cvd_delta, i_z_len)
float f3_raw    = f3_sd > 0 ? (cvd_delta - f3_mu) / f3_sd : 0.0
float f3_z      = bull_sweep ? f3_raw : (bear_sweep ? -f3_raw : math.abs(f3_raw))

float f4_bull   = bull_sweep and sdepth_b > 0 ? math.min(2.0, (close - sw_lo) / sdepth_b) : 0.0
float f4_bear   = bear_sweep and sdepth_s > 0 ? math.min(2.0, (sw_hi - close) / sdepth_s) : 0.0
float f4_raw    = bull_sweep ? f4_bull : f4_bear
float f4_mu     = ta.sma  (f4_raw, i_z_len)
float f4_sd     = ta.stdev(f4_raw, i_z_len)
float f4_z      = f4_sd > 0 ? (f4_raw - f4_mu) / f4_sd : 0.0

int   bar_hr    = hour(time, i_tz)
bool  in_london = bar_hr >= i_lon_hr and bar_hr < (i_lon_hr + i_sess_hrs)
bool  in_ny     = bar_hr >= i_ny_hr  and bar_hr < (i_ny_hr  + i_sess_hrs)
float f5        = in_london ? 1.0 : (in_ny ? 0.85 : 0.45)

float s1 = norm_z(f1_z)
float s2 = norm_z(f2_z)
float s3 = norm_z(f3_z)
float s4 = norm_z(f4_z)
float s5 = f5

float score_100 = (0.28 * s1 + 0.20 * s2 + 0.25 * s3 + 0.17 * s4 + 0.10 * s5) * 100.0

bool impulse_bull = true
bool impulse_bear = true
for i = 1 to i_ob_imp
    if close[i] <= open[i]
        impulse_bull := false
    if close[i] >= open[i]
        impulse_bear := false

bool bull_ob_formed = impulse_bull and close[i_ob_imp + 1] < open[i_ob_imp + 1]
bool bear_ob_formed = impulse_bear and close[i_ob_imp + 1] > open[i_ob_imp + 1]

var float bull_ob_top = na
var float bull_ob_bot = na
var float bear_ob_top = na
var float bear_ob_bot = na
var box   bull_ob_box = na
var box   bear_ob_box = na

if not na(bull_ob_top) and close < bull_ob_bot
    bull_ob_top := na
    bull_ob_bot := na
    if show_ob and not na(bull_ob_box)
        box.delete(bull_ob_box)
        bull_ob_box := na

if not na(bear_ob_top) and close > bear_ob_top
    bear_ob_top := na
    bear_ob_bot := na
    if show_ob and not na(bear_ob_box)
        box.delete(bear_ob_box)
        bear_ob_box := na

if bull_ob_formed
    bull_ob_top := high[i_ob_imp + 1]
    bull_ob_bot := low [i_ob_imp + 1]
    if show_ob
        if not na(bull_ob_box)
            box.delete(bull_ob_box)
        bull_ob_box := box.new(
            bar_index - (i_ob_imp + 1), bull_ob_top,
            bar_index + 10,             bull_ob_bot,
            border_color = color.new(bull_col, 30),
            bgcolor      = color.new(bull_col, 82),
            border_width = 1)

if bear_ob_formed
    bear_ob_top := high[i_ob_imp + 1]
    bear_ob_bot := low [i_ob_imp + 1]
    if show_ob
        if not na(bear_ob_box)
            box.delete(bear_ob_box)
        bear_ob_box := box.new(
            bar_index - (i_ob_imp + 1), bear_ob_top,
            bar_index + 10,             bear_ob_bot,
            border_color = color.new(bear_col, 30),
            bgcolor      = color.new(bear_col, 82),
            border_width = 1)

if show_ob and not na(bull_ob_box)
    box.set_right(bull_ob_box, bar_index + 5)
if show_ob and not na(bear_ob_box)
    box.set_right(bear_ob_box, bar_index + 5)

bool ob_bull_hit = bull_sweep and not na(bull_ob_bot) and sw_lo >= bull_ob_bot and sw_lo <= bull_ob_top
bool ob_bear_hit = bear_sweep and not na(bear_ob_bot) and sw_hi >= bear_ob_bot and sw_hi <= bear_ob_top
float ob_bonus   = (ob_bull_hit or ob_bear_hit) ? float(i_ob_bonus) : 0.0

float final_score = math.min(100.0, score_100 + ob_bonus)

bool long_sig    = bull_sweep and final_score >= float(i_score_thresh) and above_ema
bool short_sig   = bear_sweep and final_score >= float(i_score_thresh) and below_ema
bool long_entry  = long_sig   and not long_sig [1]
bool short_entry = short_sig  and not short_sig[1]
bool high_conv   = final_score >= 70.0

var int pos_state  = 0
if long_entry
    pos_state := 1
else if short_entry
    pos_state := -1
bool close_long  = pos_state[1] == 1  and short_entry
bool close_short = pos_state[1] == -1 and long_entry

bool  mid_conv    = final_score >= 60.0 and not high_conv
color long_col_c  = high_conv ? bull_col : mid_conv ? color.new(bull_col, 30) : color.new(bull_col, 55)
color short_col_c = high_conv ? bear_col : mid_conv ? color.new(bear_col, 30) : color.new(bear_col, 55)
int   band_a      = int(math.max(8, 100 - int(final_score * 0.92)))

plot(ema_line, "Trend EMA", color=color.new(color.gray, 50), linewidth=1)

plot(dbg_on and dbg_swing ? sw_hi : na, "DBG sw_hi",
     color=color.new(color.yellow, 40), linewidth=1, style=plot.style_stepline)
plot(dbg_on and dbg_swing ? sw_lo : na, "DBG sw_lo",
     color=color.new(color.yellow, 40), linewidth=1, style=plot.style_stepline)

b_top = plot(show_band ? ema_line + atr : na, display=display.none)
b_bot = plot(show_band ? ema_line       : na, display=display.none)
fill(b_top, b_bot,
     color = show_band and above_ema ? color.new(bull_col, band_a) : na,
     title = "Bull Pressure Band")

s_top = plot(show_band ? ema_line       : na, display=display.none)
s_bot = plot(show_band ? ema_line - atr : na, display=display.none)
fill(s_top, s_bot,
     color = show_band and below_ema ? color.new(bear_col, band_a) : na,
     title = "Bear Pressure Band")

bgcolor(show_session and in_london ? color.new(color.yellow, 94) : na, title="London Session")
bgcolor(show_session and in_ny     ? color.new(color.teal,   94) : na, title="NY Session")

bgcolor(long_sig  ? color.new(bull_col, 93) : na, title="Bull Regime")
bgcolor(short_sig ? color.new(bear_col, 93) : na, title="Bear Regime")

plotshape(long_entry  and high_conv     and not zen_mode, "Long High",
          location=location.belowbar, style=shape.circle,     size=size.normal, color=long_col_c)
plotshape(long_entry  and not high_conv and not zen_mode, "Long Normal",
          location=location.belowbar, style=shape.triangleup, size=size.small,  color=long_col_c)
plotshape(long_entry  and zen_mode, "Long Zen",
          location=location.belowbar, style=shape.triangleup, size=size.small,  color=long_col_c)

plotshape(short_entry and high_conv     and not zen_mode, "Short High",
          location=location.abovebar, style=shape.circle,       size=size.normal, color=short_col_c)
plotshape(short_entry and not high_conv and not zen_mode, "Short Normal",
          location=location.abovebar, style=shape.triangledown, size=size.small,  color=short_col_c)
plotshape(short_entry and zen_mode, "Short Zen",
          location=location.abovebar, style=shape.triangledown, size=size.small,  color=short_col_c)

plotshape(close_long  and not zen_mode, "Close Long",
          location=location.abovebar, style=shape.xcross, size=size.tiny,
          color=color.new(color.red,  20))
plotshape(close_short and not zen_mode, "Close Short",
          location=location.belowbar, style=shape.xcross, size=size.tiny,
          color=color.new(color.lime, 20))

if long_entry and not zen_mode
    string sig_lbl = "BUY  " + str.tostring(math.round(final_score))
    label.new(bar_index, low,
              sig_lbl,
              style     = label.style_arrowup,
              color     = color.new(long_col_c,  10),
              textcolor = color.white,
              size      = size.small)

if short_entry and not zen_mode
    string sig_lbl = "SELL  " + str.tostring(math.round(final_score))
    label.new(bar_index, high,
              sig_lbl,
              style     = label.style_arrowdown,
              color     = color.new(short_col_c, 10),
              textcolor = color.white,
              size      = size.small)

var line sl_line = na
var line tp_line = na

if long_entry and show_levels and not zen_mode
    float sl_price = close - atr * sl_atr_mult
    float tp_price = close + atr * sl_atr_mult * rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price,
                        color=color.new(color.red,   30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price,
                        color=color.new(color.green, 30), width=1, style=line.style_dashed)

if short_entry and show_levels and not zen_mode
    float sl_price = close + atr * sl_atr_mult
    float tp_price = close - atr * sl_atr_mult * rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price,
                        color=color.new(color.red,   30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price,
                        color=color.new(color.green, 30), width=1, style=line.style_dashed)

if long_entry and show_levels and not zen_mode
    line.new(bar_index, close, bar_index + 20, sw_hi,
             color=color.new(bull_col, 55), width=1, style=line.style_dotted)

if short_entry and show_levels and not zen_mode
    line.new(bar_index, close, bar_index + 20, sw_lo,
             color=color.new(bear_col, 55), width=1, style=line.style_dotted)

var table tbl = table.new(position.top_right, 2, 9,
    bgcolor      = color.new(color.black, 75),
    border_color = color.new(color.gray,  60),
    border_width = 1,
    frame_color  = color.new(color.gray,  50),
    frame_width  = 1)

if barstate.islast and show_table
    color hdr_c   = color.new(color.gray,  0)
    color txt_c   = color.new(color.white, 0)
    color hi_c    = color.new(color.lime,  0)
    color dim_c   = color.new(color.gray,  40)
    color score_c = final_score >= 70.0 ? hi_c : (final_score >= float(i_score_thresh) ? color.new(bull_col, 0) : dim_c)
    string ob_str = (ob_bull_hit or ob_bear_hit) ? "Aligned" : (not na(bull_ob_top) or not na(bear_ob_top)) ? "Active" : "None"
    color  ob_c   = (ob_bull_hit or ob_bear_hit) ? hi_c : (not na(bull_ob_top) or not na(bear_ob_top)) ? color.new(color.yellow, 0) : dim_c

    table.cell(tbl, 0, 0, "Inst Liq Sweep",
        text_color=hdr_c, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, "PMT",
        text_color=color.new(color.aqua, 0), text_size=size.small, bgcolor=color.new(color.black, 60))

    table.cell(tbl, 0, 1, "Score",      text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(math.round(final_score)) + " / 100",
        text_color=score_c, text_size=size.small)

    table.cell(tbl, 0, 2, "Wick Purity", text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 2, str.format("{0,number,#.##}", s1),
        text_color=s1 > 0.6 ? hi_c : txt_c, text_size=size.small)

    table.cell(tbl, 0, 3, "Volume",     text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 3, str.format("{0,number,#.##}", s2),
        text_color=s2 > 0.6 ? hi_c : txt_c, text_size=size.small)

    table.cell(tbl, 0, 4, "CVD Absorb", text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 4, str.format("{0,number,#.##}", s3),
        text_color=s3 > 0.6 ? hi_c : txt_c, text_size=size.small)

    table.cell(tbl, 0, 5, "Recovery",   text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 5, str.format("{0,number,#.##}", s4),
        text_color=s4 > 0.6 ? hi_c : txt_c, text_size=size.small)

    table.cell(tbl, 0, 6, "Session",    text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 6, in_london ? "London" : (in_ny ? "NY Open" : "Off-Peak"),
        text_color=in_london ? color.new(color.yellow, 0) : (in_ny ? hi_c : dim_c),
        text_size=size.small)

    table.cell(tbl, 0, 7, "OB Zone",    text_color=txt_c, text_size=size.small)
    table.cell(tbl, 1, 7, ob_str,       text_color=ob_c,  text_size=size.small)

    table.cell(tbl, 0, 8, "Threshold",  text_color=dim_c, text_size=size.tiny)
    table.cell(tbl, 1, 8, str.tostring(i_score_thresh) + "+ to fire",
        text_color=dim_c, text_size=size.tiny)

plotshape(dbg_on and dbg_sweeps and bull_sweep and not long_entry,  "DBG Bull Sweep (no signal)",
          location=location.belowbar, style=shape.diamond, size=size.tiny,
          color=color.new(color.aqua, 55))
plotshape(dbg_on and dbg_sweeps and bear_sweep and not short_entry, "DBG Bear Sweep (no signal)",
          location=location.abovebar, style=shape.diamond, size=size.tiny,
          color=color.new(color.orange, 55))

plotshape(dbg_on and dbg_obs and bull_ob_formed, "DBG Bull OB Formed",
          location=location.belowbar, style=shape.cross, size=size.tiny,
          color=color.new(bull_col, 20))
plotshape(dbg_on and dbg_obs and bear_ob_formed, "DBG Bear OB Formed",
          location=location.abovebar, style=shape.cross, size=size.tiny,
          color=color.new(bear_col, 20))

if dbg_on and dbg_labels and (bull_sweep or bear_sweep)
    bool  ema_ok  = bull_sweep ? above_ema : below_ema
    string reason = long_entry or short_entry ? "SIGNAL" : not ema_ok ? "EMA BLOCK" : final_score < float(i_score_thresh) ? "SCORE LOW" : "OTHER"
    string lbl_txt = str.format(
        "{0} S:{1}  OB:+{2}\nF1:{3}  F2:{4}\nF3:{5}  F4:{6}\nF5:{7}  [{8}]",
        bull_sweep ? "BULL" : "BEAR",
        math.round(final_score),
        math.round(ob_bonus),
        str.format("{0,number,#.##}", s1),
        str.format("{0,number,#.##}", s2),
        str.format("{0,number,#.##}", s3),
        str.format("{0,number,#.##}", s4),
        str.format("{0,number,#.##}", f5),
        reason)
    color lbl_col = (long_entry or short_entry) ? color.new(color.lime, 20) : not ema_ok ? color.new(color.gray, 30) : color.new(color.orange, 30)
    if bull_sweep
        label.new(bar_index, low - atr * 1.8,  lbl_txt,
                  style=label.style_label_up,   color=lbl_col,
                  textcolor=color.white,         size=size.tiny)
    else
        label.new(bar_index, high + atr * 1.8, lbl_txt,
                  style=label.style_label_down,  color=lbl_col,
                  textcolor=color.white,          size=size.tiny)

if dbg_on and dbg_console and (bull_sweep or bear_sweep)
    bool  ema_pass = bull_sweep ? above_ema : below_ema
    log.info("[ILS] {0} sweep | Score:{1} OB+{2} | F1:{3} F2:{4} F3:{5} F4:{6} F5:{7} | EMA:{8} | -> {9}",
        bull_sweep ? "BULL" : "BEAR",
        math.round(final_score),
        math.round(ob_bonus),
        str.format("{0,number,#.##}", s1),
        str.format("{0,number,#.##}", s2),
        str.format("{0,number,#.##}", s3),
        str.format("{0,number,#.##}", s4),
        str.format("{0,number,#.##}", f5),
        ema_pass ? "PASS" : "BLOCK",
        (long_entry or short_entry) ? "FIRED" : "NO SIGNAL")

alertcondition(long_entry,  "ILS Long Signal",  "Institutional Liquidity Sweep [PMT]: Bullish sweep — score above threshold")
alertcondition(short_entry, "ILS Short Signal", "Institutional Liquidity Sweep [PMT]: Bearish sweep — score above threshold")
alertcondition(long_entry or short_entry, "ILS Any Signal", "Institutional Liquidity Sweep [PMT]: Signal fired")
alertcondition(close_long,  "ILS Close Long",   "Institutional Liquidity Sweep [PMT]: Close long — bearish sweep confirmed")
alertcondition(close_short, "ILS Close Short",  "Institutional Liquidity Sweep [PMT]: Close short — bullish sweep confirmed")
````
