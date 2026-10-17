# Liquidity sweep Strong Levels Only

- url: https://www.tradingview.com/script/GEX8Mu0S-Liquidity-sweep-Strong-Levels-Only/
- type: indicator
- pine_id: PUB;367ef7719fb44a68aecc35d673746a11
- version: 1.0

## Description

═══════════════════════════════════════════════════════════
  LIQ · STRONG LEVELS ONLY — Smart Money Liquidity Filter
  BSL / SSL / EQH / EQL  |  Strength Filter  |  Touch Counter
═══════════════════════════════════════════════════════════

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WHAT THIS INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most liquidity indicators flood your chart with every swing
high and low — leaving you guessing which levels actually
matter. This indicator solves that problem.

It shows ONLY the levels where institutional stop hunts are
still likely — levels where the stop-loss pool is still full,
untouched, and worth hunting. Weak and stale levels are
automatically hidden or removed.

Every visible level on this chart is one that passed two
filters:

  1. Price moved significantly away after the level formed
     → confirms institutional participation
  2. Price has not returned to test it more than once
     → confirms stop-loss pool is still intact

EQH · BSL and EQL · SSL (Equal Highs / Equal Lows) are
always shown regardless of filters — they are PRIMARY levels
where the largest stop clusters accumulate.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  THE SMART MONEY CONCEPT BEHIND IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Retail traders place their stop losses:
  → Below swing lows  (these become SSL — Sell-Side Liquidity)
  → Above swing highs (these become BSL — Buy-Side Liquidity)

Institutions need these stop-triggered orders to fill their
own large positions at favorable prices. They deliberately
engineer price to sweep these levels before reversing.

This indicator tracks exactly where those stop pools sit,
how fresh they are, and warns you before you enter a trade
against an unswept level that will hunt your stop first.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WHAT YOU SEE ON THE CHART
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔵 BSL ★          Buy-Side Liquidity — strong, untouched
                    Stop losses sitting above this swing high

  🔴 SSL ★          Sell-Side Liquidity — strong, untouched
                    Stop losses sitting below this swing low

  🟡 EQH · BSL      Equal Highs — PRIMARY level (always shown)
                    Largest buy-side stop cluster

  🟡 EQL · SSL      Equal Lows — PRIMARY level (always shown)
                    Largest sell-side stop cluster

  SSL ★ (1T)        Level has been tested once — weakening
                    Fewer stops remain, use with less conviction

  ✓ BSL / ✓ SSL     Level has been swept (faded dashed line)
                    Stop hunt completed — no longer relevant

  🟠 Candle BG      Sweep candle — a level was swept this bar

Every label also shows the live pip distance from current
price so you can apply distance-based entry rules instantly.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HOW TO USE IT — STEP BY STEP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1 — Read the levels around current price

  Look above → nearest BSL ★ or EQH · BSL
               This is the draw on liquidity for longs
               This is the danger zone for shorts

  Look below → nearest SSL ★ or EQL · SSL
               This is the danger zone for longs
               This is the draw on liquidity for shorts


STEP 2 — Apply the distance rule before entering

  If an opposing level is within 15–20 pips of your entry:
  → DO NOT enter yet
  → Wait for price to sweep that level first
  → Then look for your entry signal after the sweep

  If an EQL · SSL or EQH · BSL exists in any direction:
  → ALWAYS wait for the sweep regardless of distance
  → These are the highest priority levels on the chart


STEP 3 — Confirm the sweep

  A valid sweep looks like:
  → Price wicks BELOW the SSL (or above the BSL)
  → The candle CLOSES back above the SSL (or below BSL)
  → The sweep candle highlight fires (orange background)
  → The level changes to ✓ SSL (faded dashed line)

  A close below the level = not a sweep, it is continuation
  Do not enter — wait for the next SSL below


STEP 4 — Enter after sweep confirmation

  After a valid SSL sweep on your HTF (15M recommended):
  → Drop to your entry timeframe (1M recommended)
  → Wait for a Break of Structure (BOS) to the upside
  → Enter at your preferred Fib level (0.21 entry, 0.705 TP)
  → SL below the sweep wick with buffer
  → TP at the next BSL or EQH · BSL above


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  RECOMMENDED SETUP FOR SMC TRADERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  15M chart  → Add this indicator for HTF level context
               Use it to identify draw on liquidity and
               danger zones before every trade

  1M chart   → Add the companion HTF version of this indicator
               (LIQ · 15M on 1M) to see 15M levels directly
               on your entry timeframe without switching charts

  Best pairs:  EUR/USD · GBP/USD · GBP/JPY · USD/JPY

  Best session: London–New York overlap produces the
                cleanest sweeps and highest follow-through


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ⚙️ Core Settings

  Lookback Length (default 106)
    How many bars back the indicator tracks levels.
    106 is the optimal value for intraday swing detection.
    Increase to 200+ for higher timeframe swing analysis.

  Swing Pivot Bars (default 5)
    Left and right bars required to confirm a swing.
    5 = standard SMC swing detection.
    Lower = more sensitive (more levels, more noise).
    Higher = only major swings (fewer, stronger levels).

  EQH / EQL Tolerance % (default 0.030)
    How close two highs or lows must be to qualify as equal.
    0.030% works well for EUR/USD and GBP/USD.
    Increase slightly for JPY pairs.

  Line Extension
    How far right the level lines extend.


  🎯 Strength Filter (the key settings)

  Min Move Away — default 10 pips
    Price must move at least this many pips away from the
    level immediately after it forms. Levels with weak moves
    are hidden — they lack institutional participation.

    EUR/USD → 10 pips
    GBP/USD → 12 pips
    GBP/JPY → 20 pips

  Max Touches Before Invalid — default 1
    How many times price can approach a level without sweeping
    before it is automatically removed.
    1 = strictest (recommended) — first touch weakens,
        second touch invalidates
    2 = lenient — gives levels a second chance

  Touch Zone — default 3 pips
    How close price must come to count as a touch.
    3 pips catches genuine approaches while ignoring noise.
    Increase to 5 pips if you find levels disappearing too fast.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INFO PANEL (top right of chart)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  BSL Active      → How many strong buy-side levels remain
  SSL Active      → How many strong sell-side levels remain
  BSL Swept       → Total buy-side levels swept this session
  SSL Swept       → Total sell-side levels swept this session
  BSL Invalidated → Levels removed by touch filter (too stale)
  SSL Invalidated → Levels removed by touch filter (too stale)
  Sweep Now       → YES if a sweep just occurred this bar


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Three alerts available (set via TradingView alert menu):

  → Strong BSL Swept   — buy-side level swept, watch for short
  → Strong SSL Swept   — sell-side level swept, watch for long
  → Strong Level Swept — either direction swept

  These alerts only fire on STRONG levels that passed the
  filter — no noise from weak or stale levels.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  COMMON MISTAKES TO AVOID
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✗ Entering a long while an SSL ★ sits within 15–20 pips below
    → Price will sweep it first and hit your stop

  ✗ Ignoring an EQL · SSL because it looks far away
    → Equal lows are always magnets — distance does not matter

  ✗ Treating a (1T) level the same as a fresh level
    → Touched levels have fewer stops — react with less force

  ✗ Entering immediately when the sweep candle fires
    → Wait for the BOS confirmation on your entry timeframe

  ✗ Using this indicator alone without HTF structure bias
    → Always confirm the sweep aligns with your HTF direction


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  THE CORE PRINCIPLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Every candle is either building a liquidity pool,
  hunting a liquidity pool, or delivering away from
  a swept pool.

  Your job is to identify the pool, wait for the hunt
  to complete, and enter during the delivery.

  This indicator shows you exactly where the pools are
  and whether they are still worth hunting.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Built for SMC / ICT traders operating on EUR/USD,
  GBP/USD, GBP/JPY and USD/JPY on 1M–15M timeframes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  LIQUIDITY POOLS · BSL / SSL  [STRONG LEVELS ONLY]
//  Only shows SSL/BSL where:
//    1. Price moved significantly away after formation (strong sweep potential)
//    2. Level has not been tested more than once (fresh = valid)
//  EQH · EQL levels are ALWAYS shown (primary — no filter applied)
// ─────────────────────────────────────────────────────────────────────────────
indicator("LIQ · Strong Levels Only", "LIQ·S", overlay = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 200,
     max_bars_back    = 4900)

G1 = "⚙️  Core Settings"
G2 = "🔵  Buy-Side Liquidity (BSL)"
G3 = "🔴  Sell-Side Liquidity (SSL)"
G4 = "⚡  Sweep Settings"
G5 = "📊  Info Panel"
G6 = "🎯  Strength Filter"

lookback      = input.int   (106,   "Lookback Length",            group = G1, minval = 10, maxval = 500)
swing_len     = input.int   (5,     "Swing Pivot Bars",           group = G1, minval = 2,  maxval = 20)
eq_pct        = input.float (0.030, "EQH / EQL Tolerance %",      group = G1, minval = 0.001, step = 0.005)
lbl_sz        = input.string(size.small, "Label Size",             group = G1,
     options = [size.tiny, size.small, size.normal])
ext_right     = input.int   (30,    "Line Extension (bars right)", group = G1, minval = 5, maxval = 100)

show_bsl      = input.bool  (true,    "Show BSL Levels", group = G2)
bsl_col       = input.color (#00BFFF, "BSL Color",       group = G2)

show_ssl      = input.bool  (true,    "Show SSL Levels", group = G3)
ssl_col       = input.color (#FF4C6A, "SSL Color",       group = G3)

show_swept    = input.bool(true, "Keep Swept Levels (faded)", group = G4)
hl_bar        = input.bool(true, "Highlight Sweep Candle",    group = G4)
show_eqzone   = input.bool(true, "Show EQH / EQL Zone Boxes", group = G4)
show_panel    = input.bool(true, "Show Info Panel",           group = G5)

min_move_pips = input.int(10, "Min Move Away (pips)",        group = G6, minval = 3, maxval = 50,
     tooltip = "Price must move at least this many pips away from the level after it forms.")
max_touches   = input.int(1,  "Max Touches Before Invalid",  group = G6, minval = 1, maxval = 3,
     tooltip = "How many times price can approach without sweeping before the level is removed.")
touch_pips    = input.int(3,  "Touch Zone (pips)",           group = G6, minval = 1, maxval = 10,
     tooltip = "How close price must come to count as a touch.")

// ── CONSTANTS ────────────────────────────────────────────────────────────────
EQH_COL    = color.new(#FFD700, 0)
SWEPT_FADE = 75
ZONE_FADE  = 88
pip_size   = syminfo.mintick * 10

// ── HELPERS ──────────────────────────────────────────────────────────────────
f_near(float a, float b) =>
    math.abs(a - b) / ((a + b) * 0.5) * 100 <= eq_pct

f_pips(float a, float b) =>
    math.round(math.abs(a - b) / pip_size, 1)

// ── PIVOTS ───────────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow (low,  swing_len, swing_len)

// ── STRENGTH CHECK ───────────────────────────────────────────────────────────
// At pivot confirmation, swing_len bars have passed since the pivot formed.
// SSL strong = price rallied at least min_move_pips upward after the low.
// BSL strong = price dropped at least min_move_pips downward after the high.
// EQH / EQL bypass this filter — always valid.

ssl_move_ok(float lvl) =>
    ta.highest(high, swing_len) - lvl >= min_move_pips * pip_size

bsl_move_ok(float lvl) =>
    lvl - ta.lowest(low, swing_len) >= min_move_pips * pip_size

// ── ARRAYS — BSL ─────────────────────────────────────────────────────────────
var float[] bp = array.new_float()
var int[]   bi = array.new_int()
var bool[]  ba = array.new_bool()
var bool[]  be = array.new_bool()
var int[]   bt = array.new_int()
var bool[]  bv = array.new_bool()
var line[]  bl = array.new_line()
var label[] bL = array.new_label()

// ── ARRAYS — SSL ─────────────────────────────────────────────────────────────
var float[] sp = array.new_float()
var int[]   si = array.new_int()
var bool[]  sa = array.new_bool()
var bool[]  se = array.new_bool()
var int[]   st = array.new_int()
var bool[]  sv = array.new_bool()
var line[]  sl = array.new_line()
var label[] sL = array.new_label()

// ── REGISTER BSL ─────────────────────────────────────────────────────────────
if show_bsl and not na(ph)
    ph_bi = bar_index - swing_len

    bool is_eqh      = false
    int  eqh_match_i = -1
    if array.size(bp) > 0
        for i = 0 to array.size(bp) - 1
            if array.get(ba, i) and f_near(array.get(bp, i), ph)
                is_eqh      := true
                eqh_match_i := i
                break

    is_strong = is_eqh or bsl_move_ok(ph)

    if is_strong
        lvl_col = is_eqh ? EQH_COL : color.new(bsl_col, 0)
        lw      = is_eqh ? 2       : 1
        ls      = is_eqh ? line.style_solid : line.style_dotted
        txt     = is_eqh ? "EQH · BSL" : "BSL ★"

        if is_eqh and eqh_match_i >= 0
            label.set_text     (array.get(bL, eqh_match_i), "EQH · BSL")
            label.set_textcolor(array.get(bL, eqh_match_i), EQH_COL)
            label.set_x        (array.get(bL, eqh_match_i), bar_index + ext_right)
            line.set_color     (array.get(bl, eqh_match_i), EQH_COL)
            line.set_width     (array.get(bl, eqh_match_i), 2)
            line.set_style     (array.get(bl, eqh_match_i), line.style_solid)
            if show_eqzone
                match_bi = array.get(bi, eqh_match_i)
                match_px = array.get(bp, eqh_match_i)
                top_z    = math.max(match_px, ph) + syminfo.mintick * 3
                bot_z    = math.min(match_px, ph) - syminfo.mintick * 3
                box.new(match_bi, top_z, bar_index + ext_right, bot_z,
                     bgcolor      = color.new(#FFD700, ZONE_FADE),
                     border_color = color.new(#FFD700, 40),
                     border_width = 1)

        array.push(bp, ph)
        array.push(bi, ph_bi)
        array.push(ba, true)
        array.push(be, is_eqh)
        array.push(bt, 0)
        array.push(bv, true)
        array.push(bl, line.new(ph_bi, ph, bar_index + ext_right, ph,
             color = lvl_col, width = lw, style = ls))
        array.push(bL, label.new(bar_index + ext_right, ph, txt,
             color     = color.new(color.black, 100),
             textcolor = lvl_col,
             style     = label.style_label_left,
             size      = lbl_sz))

// ── REGISTER SSL ─────────────────────────────────────────────────────────────
if show_ssl and not na(pl)
    pl_bi = bar_index - swing_len

    bool is_eql      = false
    int  eql_match_i = -1
    if array.size(sp) > 0
        for i = 0 to array.size(sp) - 1
            if array.get(sa, i) and f_near(array.get(sp, i), pl)
                is_eql      := true
                eql_match_i := i
                break

    is_strong = is_eql or ssl_move_ok(pl)

    if is_strong
        lvl_col = is_eql ? EQH_COL : color.new(ssl_col, 0)
        lw      = is_eql ? 2       : 1
        ls      = is_eql ? line.style_solid : line.style_dotted
        txt     = is_eql ? "EQL · SSL" : "SSL ★"

        if is_eql and eql_match_i >= 0
            label.set_text     (array.get(sL, eql_match_i), "EQL · SSL")
            label.set_textcolor(array.get(sL, eql_match_i), EQH_COL)
            label.set_x        (array.get(sL, eql_match_i), bar_index + ext_right)
            line.set_color     (array.get(sl, eql_match_i), EQH_COL)
            line.set_width     (array.get(sl, eql_match_i), 2)
            line.set_style     (array.get(sl, eql_match_i), line.style_solid)
            if show_eqzone
                match_bi = array.get(si, eql_match_i)
                match_px = array.get(sp, eql_match_i)
                top_z    = math.max(match_px, pl) + syminfo.mintick * 3
                bot_z    = math.min(match_px, pl) - syminfo.mintick * 3
                box.new(match_bi, top_z, bar_index + ext_right, bot_z,
                     bgcolor      = color.new(#FFD700, ZONE_FADE),
                     border_color = color.new(#FFD700, 40),
                     border_width = 1)

        array.push(sp, pl)
        array.push(si, pl_bi)
        array.push(sa, true)
        array.push(se, is_eql)
        array.push(st, 0)
        array.push(sv, true)
        array.push(sl, line.new(pl_bi, pl, bar_index + ext_right, pl,
             color = lvl_col, width = lw, style = ls))
        array.push(sL, label.new(bar_index + ext_right, pl, txt,
             color     = color.new(color.black, 100),
             textcolor = lvl_col,
             style     = label.style_label_left,
             size      = lbl_sz))

// ── UPDATE — Sweep · Touch Count · Extend · Cleanup ──────────────────────────
bool bsl_swept_now = false
bool ssl_swept_now = false
int  act_bsl       = 0
int  act_ssl       = 0
int  tot_bsl_sw    = 0
int  tot_ssl_sw    = 0
int  removed_bsl   = 0
int  removed_ssl   = 0

touch_dist = touch_pips * pip_size

// ─── BSL ─────────────────────────────────────────────────────────────────────
if array.size(bp) > 0
    for i = array.size(bp) - 1 to 0
        age = bar_index - array.get(bi, i)
        if age > lookback
            line.delete (array.get(bl, i))
            label.delete(array.get(bL, i))
            array.remove(bp, i)
            array.remove(bi, i)
            array.remove(ba, i)
            array.remove(be, i)
            array.remove(bt, i)
            array.remove(bv, i)
            array.remove(bl, i)
            array.remove(bL, i)
            continue

        if array.get(ba, i)
            lvl   = array.get(bp, i)
            ln    = array.get(bl, i)
            lb    = array.get(bL, i)
            is_eq = array.get(be, i)

            if high > lvl
                bsl_swept_now := true
                array.set(ba, i, false)
                if show_swept
                    line.set_color     (ln, color.new(bsl_col, SWEPT_FADE))
                    line.set_style     (ln, line.style_dashed)
                    label.set_text     (lb, "✓ BSL")
                    label.set_textcolor(lb, color.new(bsl_col, SWEPT_FADE))
                else
                    line.delete (ln)
                    label.delete(lb)
            else
                is_near = (lvl - close) <= touch_dist and (lvl - close) > 0
                if is_near
                    new_touch = array.get(bt, i) + 1
                    array.set(bt, i, new_touch)
                    if not is_eq and new_touch > max_touches
                        line.delete (ln)
                        label.delete(lb)
                        array.remove(bp, i)
                        array.remove(bi, i)
                        array.remove(ba, i)
                        array.remove(be, i)
                        array.remove(bt, i)
                        array.remove(bv, i)
                        array.remove(bl, i)
                        array.remove(bL, i)
                        removed_bsl += 1
                        continue

                act_bsl      += 1
                pip_dist_val  = f_pips(lvl, close)
                touch_cnt     = array.get(bt, i)
                base_txt      = is_eq ? "EQH · BSL" : "BSL ★"
                touch_txt     = not is_eq and touch_cnt > 0 ?
                     " (" + str.tostring(touch_cnt) + "T)" : ""
                pip_txt       = "\n" + str.tostring(pip_dist_val, "#.#") + " pips"
                label.set_text(lb, base_txt + touch_txt + pip_txt)
                line.set_x2   (ln, bar_index + ext_right)
                label.set_x   (lb, bar_index + ext_right)
        else
            tot_bsl_sw += 1

// ─── SSL ─────────────────────────────────────────────────────────────────────
if array.size(sp) > 0
    for i = array.size(sp) - 1 to 0
        age = bar_index - array.get(si, i)
        if age > lookback
            line.delete (array.get(sl, i))
            label.delete(array.get(sL, i))
            array.remove(sp, i)
            array.remove(si, i)
            array.remove(sa, i)
            array.remove(se, i)
            array.remove(st, i)
            array.remove(sv, i)
            array.remove(sl, i)
            array.remove(sL, i)
            continue

        if array.get(sa, i)
            lvl   = array.get(sp, i)
            ln    = array.get(sl, i)
            lb    = array.get(sL, i)
            is_eq = array.get(se, i)

            if low < lvl
                ssl_swept_now := true
                array.set(sa, i, false)
                if show_swept
                    line.set_color     (ln, color.new(ssl_col, SWEPT_FADE))
                    line.set_style     (ln, line.style_dashed)
                    label.set_text     (lb, "✓ SSL")
                    label.set_textcolor(lb, color.new(ssl_col, SWEPT_FADE))
                else
                    line.delete (ln)
                    label.delete(lb)
            else
                is_near = (close - lvl) <= touch_dist and (close - lvl) > 0
                if is_near
                    new_touch = array.get(st, i) + 1
                    array.set(st, i, new_touch)
                    if not is_eq and new_touch > max_touches
                        line.delete (ln)
                        label.delete(lb)
                        array.remove(sp, i)
                        array.remove(si, i)
                        array.remove(sa, i)
                        array.remove(se, i)
                        array.remove(st, i)
                        array.remove(sv, i)
                        array.remove(sl, i)
                        array.remove(sL, i)
                        removed_ssl += 1
                        continue

                act_ssl      += 1
                pip_dist_val  = f_pips(close, lvl)
                touch_cnt     = array.get(st, i)
                base_txt      = is_eq ? "EQL · SSL" : "SSL ★"
                touch_txt     = not is_eq and touch_cnt > 0 ?
                     " (" + str.tostring(touch_cnt) + "T)" : ""
                pip_txt       = "\n" + str.tostring(pip_dist_val, "#.#") + " pips"
                label.set_text(lb, base_txt + touch_txt + pip_txt)
                line.set_x2   (ln, bar_index + ext_right)
                label.set_x   (lb, bar_index + ext_right)
        else
            tot_ssl_sw += 1

// ── SWEEP CANDLE ─────────────────────────────────────────────────────────────
bgcolor(hl_bar and bsl_swept_now ? color.new(bsl_col, 90) : na, title = "BSL Sweep Candle")
bgcolor(hl_bar and ssl_swept_now ? color.new(ssl_col, 90) : na, title = "SSL Sweep Candle")

// ── INFO PANEL ───────────────────────────────────────────────────────────────
if show_panel and barstate.islast
    var table tbl = table.new(position.top_right, 2, 8,
         bgcolor      = color.new(#0D1117, 8),
         border_color = color.new(#FFFFFF, 82),
         border_width = 1,
         frame_color  = color.new(#FFFFFF, 75),
         frame_width  = 1)

    table.cell(tbl, 0, 0, "LIQ · STRONG ONLY",
         text_color = color.white, text_size = size.small, bgcolor = color.new(#161B22, 0))
    table.cell(tbl, 1, 0, "LB · " + str.tostring(lookback),
         text_color = color.gray,  text_size = size.small, bgcolor = color.new(#161B22, 0))
    table.cell(tbl, 0, 1, "🔵 BSL Active",
         text_color = color.new(bsl_col, 0), text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(act_bsl),
         text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 2, "🔴 SSL Active",
         text_color = color.new(ssl_col, 0), text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(act_ssl),
         text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 3, "✓ BSL Swept",
         text_color = color.new(bsl_col, 50), text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(tot_bsl_sw),
         text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 4, "✓ SSL Swept",
         text_color = color.new(ssl_col, 50), text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(tot_ssl_sw),
         text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 5, "🗑 BSL Invalidated",
         text_color = color.new(#888888, 0), text_size = size.small)
    table.cell(tbl, 1, 5, str.tostring(removed_bsl),
         text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 6, "🗑 SSL Invalidated",
         text_color = color.new(#888888, 0), text_size = size.small)
    table.cell(tbl, 1, 6, str.tostring(removed_ssl),
         text_color = color.gray, text_size = size.small)
    sweep_now = bsl_swept_now or ssl_swept_now
    table.cell(tbl, 0, 7, "⚡ Sweep Now",
         text_color = color.new(#FFD700, 0), text_size = size.small)
    table.cell(tbl, 1, 7, sweep_now ? "YES" : "—",
         text_color = sweep_now ? color.new(#FFD700, 0) : color.gray,
         text_size  = size.small)

// ── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(bsl_swept_now,
     "Strong BSL Swept 🔵", "A strong Buy-Side Liquidity level swept — potential reversal down.")
alertcondition(ssl_swept_now,
     "Strong SSL Swept 🔴", "A strong Sell-Side Liquidity level swept — potential reversal up.")
alertcondition(bsl_swept_now or ssl_swept_now,
     "Strong Level Swept ⚡", "A strong liquidity level has been swept.")
````
