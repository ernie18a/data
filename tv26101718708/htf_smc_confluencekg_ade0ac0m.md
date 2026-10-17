# HTF SMC Confluence[KG]

- url: https://www.tradingview.com/script/ade0aC0m-HTF-SMC-Confluence-KG/
- type: indicator
- pine_id: PUB;e26509a0244d4c77a706c1ed3f3e8f89
- version: 1.0

## Description

HTF SMC Confluence is basically lazy trader's best friend — because who has time to actually switch timeframes like some kind of animal?
It slaps a big higher timeframe candle right onto your chart, throws in Fair Value Gaps, Market Structure Shifts, and Displacement Zones, and whispers "institutional money was HERE" so you don't have to go hunting for it yourself.
It was built around one gloriously obvious idea: that trading a 5-minute chart while completely ignoring the daily is like navigating a highway by only looking at your hood ornament. This tool finally makes you look up — without making you do any extra work. Confluence, served hot, on a single canvas. You're welcome.

─────────────────────────────────────────────────────────────
WHAT EACH COMPONENT DOES
─────────────────────────────────────────────────────────────
 
1. HTF CANDLE (plotted to the right of price)
 
   A full OHLC candle from a higher timeframe is rendered live to the right of
   your current price action. It updates tick by tick — the body, wick, and
   color all reflects the evolving HTF candle in real time. Up to 5 historical
   HTF candles can be displayed side by side for recent context. The wick is
   precisely centered on the candle body, and the candle repositions itself
   automatically on every bar so it always floats cleanly beyond the rightmost
   price bar.
 
   What it tells you: the current mood of the higher timeframe. A bullish daily
   candle forming while the 5m sells off is a very different scenario than a
   bearish daily candle in distribution.
 
2. HIGH / LOW LINES
 
   Solid horizontal lines are drawn from the HTF candle's high and low, running
   across the chart and labeled "High" and "Low." These mark the range that
   institutional players defined on the higher timeframe. Price tends to respect
   these levels — they act as magnets, decision zones, and areas of liquidity.
 
3. MIDLINE (dotted)
 
   A dotted line sits exactly halfway between the HTF High and Low — the
   equilibrium of the HTF range. In SMC theory, this is called the "50% level"
   or "CE" (Consequent Encroachment). Price retracing to this level inside a
   bullish candle is often an optimal entry zone. It is subtle by design —
   informational, not dominant.
 
4. FAIR VALUE GAP (FVG)
 
   A Fair Value Gap is a three-candle imbalance pattern. When a candle moves so
   aggressively in one direction that it leaves a gap between the first and
   third candle's wicks — price skipped over that zone. Institutions tend to
   return to these gaps to "fill" the imbalance before continuing the move.
   Bearish FVGs are highlighted in red, bullish in green. A label mark each
   box. Up to a user-defined maximum number of FVGs are tracked and old ones
   are automatically removed.
 
5. MARKET STRUCTURE SHIFT (MSS)
 
   An MSS occurs the moment price decisively closes beyond a prior swing point,
   signaling a change in directional intent. A bearish MSS is when price
   closes below a recent swing low — the market is no longer making higher
   lows. A bullish MSS is when price closes above a recent swing high. A
   horizontal line is drawn at the broken level and labeled "MSS." Up to 5
   recent MSS events are displayed; older ones clean up automatically.
 
6. DISPLACEMENT ZONE
 
   Displacement is a series of consecutive strong candles in one direction
   where the average body size exceeds a multiple of the ATR. It represents
   institutional aggression — the moment "smart money" stepped in hard and
   drove price. These zones are shaded on the chart and serve as reference
   for where the real move originated, helping traders distinguish displacement
   from manipulation.

─────────────────────────────────────────────────────────────
RECOMMENDED TIMEFRAME COMBINATIONS
─────────────────────────────────────────────────────────────
 
The indicator is designed around a top-down multi-timeframe workflow. The HTF
candle shown on the right should always be at least 4-6x the current chart's
timeframe. Below are the most practical pairings:
 
   CHART TIMEFRAME /                     HTF CANDLE SETTING/                    USE CASE
   ──────────────────────────────────────────────────────
   1 minute...................            15 minute   ...............Scalping with intraday structure
   3 minute ............................30 minute .................Scalping with session context
   5 minute ............................1 hour .....................Intraday momentum trades
   5 minute ........................... 4 hour .................... Intraday with swing context
   15 minute ..........................4 hour .................... Intraday swing setups
   15 minute ..........................Daily (1D) ................ Most common: intraday vs daily
   1 hour ..............................Daily (1D) .................Swing trades
   1 hour ..............................Weekly (1W) ..............Position trade entries
   4 hour ..............................Weekly (1W) ..............Swing / position trading
   
─────────────────────────────────────────────────────────────
HOW TO TRADE WITH THIS INDICATOR
─────────────────────────────────────────────────────────────
 
The indicator does not generate buy or sell signals. Instead, it provides a
structured framework for identifying high-probability setups using confluence.
The following is a general workflow:
 
STEP 1 — READ THE HTF CANDLE
 
   Before anything else, look at the HTF candle on the right. Is it bullish or
   bearish? Is it nearing its high or low? This tells you about the directional bias for
   the session. Only take trades in the direction of the HTF candle unless you
   have strong evidence of a reversal.
 
STEP 2 — IDENTIFY THE RANGE
 
   The High and Low lines define the playing field. Price at or near the HTF
   High is at resistance — look for bearish setups. Price at or near the HTF
   Low is at support — look for bullish setups. The midline is a secondary
   decision zone — often acts as a magnet when price is between the levels.
 
STEP 3 — WAIT FOR STRUCTURE (MSS)
 
   An MSS on the lower timeframe in the direction of your HTF bias is one of
   the strongest confirmation signals. For example: if the daily candle is
   bullish, wait for a bullish MSS on the 5-minute chart — a close above a
   swing high — before entering long. This tells you short-term structure has
   flipped in your favour.
 
STEP 4 — LOOK FOR AN FVG ENTRY
 
   After an MSS, price often retraces into a Fair Value Gap before continuing.
   This gap is your precision entry zone. Enter at the edge of the FVG closest
   to current price. Place your stop loss below the FVG (for longs) or above
   it (for shorts). The FVG acts as your entry trigger and risk anchor.
 
STEP 5 — CONFIRM WITH DISPLACEMENT
 
   If the MSS was preceded by a Displacement Zone — meaning price moved
   aggressively to create the structure break — the setup is higher quality.
   Displacement followed by a retracement into an FVG, with an MSS confirming,
   is the textbook SMC entry pattern this indicator is designed to highlight.
 
STEP 6 — SET TARGETS
 
   Common targets are the HTF High (if long) or HTF Low (if short). The
   midline is a partial-take-profit level. Always assess the risk-to-reward
   before entry — aim for a minimum of 1:2.

─────────────────────────────────────────────────────────────
WHAT THIS INDICATOR DOES NOT DO
─────────────────────────────────────────────────────────────
 
   — It does not generate buy or sell signals
   — It does not repaint historical data (all drawings are forward-only)
   — It does not account for news events, earnings, or macro catalysts
   — It does not guarantee any outcome
   — It is not a standalone trading system

─────────────────────────────────────────────────────────────
DISCLAIMER
─────────────────────────────────────────────────────────────
 
This indicator and the accompanying documentation are provided strictly for
educational and informational purposes only. Nothing contained herein
constitutes financial advice, investment advice, trading advice, or any other
form of professional financial guidance. Past performance of any trading system, strategy, or indicator — including the concepts demonstrated here — is not indicative of future results. Use this tool as one input among many — never as the sole basis for a trade.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HTF SMC Confluence — Built for traders who think in timeframes, not ticks. Happy Trading!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kingshukghosh71
// Features: HTF Candle, High/Low Lines, Mid dotted line, FVG, MSS, Displacement zone
//@version=6
indicator('HTF SMC Confluence[KG]', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

//+------------------------------------------------------------------------------------------------------------+//
//+--- TYPES                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//

type Candle
    float o
    float c
    float h
    float l
    int   o_time
    int   o_idx
    int   c_idx
    box   body
    line  wick_up
    line  wick_down

type Imbalance
    box   b

type MSS_Level
    line  lvl
    label lbl

type DisplacementZone
    box   b

//+------------------------------------------------------------------------------------------------------------+//
//+--- INPUTS                                                                                               ---+//
//+------------------------------------------------------------------------------------------------------------+//

string g_htf  = "HTF Candle ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string g_smc  = "SMC Levels ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string g_fvg  = "Fair Value Gap ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string g_mss  = "Market Structure Shift ━━━━━━━━━━━━━━━━━━━"
string g_disp = "Displacement Zone ━━━━━━━━━━━━━━━━━━━━━━━"

// HTF Candle
htf_show        = input.bool(true,      'Show HTF Candle',           group = g_htf)
htf_tf          = input.timeframe('1D', 'HTF Timeframe',             group = g_htf)
htf_max_display = input.int(1,          'Max HTF Candles', minval=1, maxval=5, group = g_htf)
htf_offset      = input.int(12,         'Offset from bar', minval=1, group = g_htf)
bull_body_col   = input.color(color.new(color.green, 10), 'Bull Body',   inline='body',   group=g_htf)
bear_body_col   = input.color(color.new(color.red,   10), '',            inline='body',   group=g_htf)
bull_border_col = input.color(color.new(color.green,  0), 'Bull Border', inline='border', group=g_htf)
bear_border_col = input.color(color.new(color.red,    0), '',            inline='border', group=g_htf)
bull_wick_col   = input.color(color.new(color.white,  0), 'Bull Wick',   inline='wick',   group=g_htf)
bear_wick_col   = input.color(color.new(color.white,  0), '',            inline='wick',   group=g_htf)

// High / Low + Mid lines
hl_show   = input.bool(true,  'Show H/L Lines',       group = g_smc)
hl_color  = input.color(color.new(color.white, 20), 'H/L Color', group = g_smc)
hl_width  = input.int(1,      'H/L Width', minval=1, maxval=4,   group = g_smc)
mid_show  = input.bool(true,  'Show Mid Dotted Line',             group = g_smc)
mid_color = input.color(color.new(color.gray, 30), 'Mid Color',  group = g_smc)

// Fair Value Gap
fvg_show       = input.bool(true, 'Show FVG',                        group = g_fvg)
fvg_bull_col   = input.color(color.new(color.green, 75), 'Bull FVG', group = g_fvg)
fvg_bear_col   = input.color(color.new(color.red,   60), 'Bear FVG', group = g_fvg)
fvg_border_col = input.color(color.new(color.red,   20), 'FVG Border', group = g_fvg)
fvg_max        = input.int(3,     'Max FVGs', minval=1, maxval=10,   group = g_fvg)
fvg_label_show = input.bool(true, 'Show FVG Label',                  group = g_fvg)

// Market Structure Shift
mss_show     = input.bool(true,  'Show MSS',                         group = g_mss)
mss_lookback = input.int(10,     'MSS Lookback', minval=3, maxval=50, group = g_mss)
mss_col      = input.color(#c0bcbc, 'MSS Color',   group = g_mss)
mss_width    = input.int(1,      'MSS Line Width', minval=1, maxval=3, group = g_mss)

// Displacement Zone
disp_show        = input.bool(true,   'Show Displacement Zone',       group = g_disp)
disp_bull_col    = input.color(color.new(color.green, 80), 'Bull Zone', group = g_disp)
disp_bear_col    = input.color(color.new(color.green, 80), 'Bear Zone', group = g_disp)
disp_min_candles = input.int(3,       'Min Candles for Zone', minval=2, maxval=10, group = g_disp)
disp_atr_mult    = input.float(1.5,   'ATR Multiplier', minval=0.5, step=0.1,     group = g_disp)

//+------------------------------------------------------------------------------------------------------------+//
//+--- CONSTANTS                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

int   CANDLE_WIDTH  = 3
int   CANDLE_BUFFER = 1
color TRANSPARENT   = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- STATE                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//

var array<Candle>           htf_candles = array.new<Candle>(0)
var array<Imbalance>        fvg_boxes   = array.new<Imbalance>(0)
var array<MSS_Level>        mss_levels  = array.new<MSS_Level>(0)
var array<DisplacementZone> disp_zones  = array.new<DisplacementZone>(0)

// HTF H/L/Mid persistent lines
var line  htf_high_line = na
var line  htf_low_line  = na
var line  htf_mid_line  = na
var label htf_high_lbl  = na
var label htf_low_lbl   = na

//+------------------------------------------------------------------------------------------------------------+//
//+--- HELPERS                                                                                              ---+//
//+------------------------------------------------------------------------------------------------------------+//

f_atr(len) => ta.atr(len)

//+------------------------------------------------------------------------------------------------------------+//
//+--- HTF CANDLE                                                                                          ---+//
//+------------------------------------------------------------------------------------------------------------+//

HTFBarTime  = time(htf_tf, 'Kolkata/Asia')
isNewHTFBar = ta.change(HTFBarTime) > 0

if htf_show and isNewHTFBar
    Candle c = Candle.new()
    c.o      := open
    c.c      := close
    c.h      := high
    c.l      := low
    c.o_time := time
    c.o_idx  := bar_index
    c.c_idx  := bar_index
    bool bull = c.c > c.o

    // Body box — wick 
    c.body := box.new(
         bar_index,
         math.max(c.o, c.c),
         bar_index + CANDLE_WIDTH,
         math.min(c.o, c.c),
         bull ? bull_border_col : bear_border_col,
         2,
         bgcolor = bull ? bull_body_col : bear_body_col
     )

    // wick placement 
    c.wick_up := line.new(
         bar_index + CANDLE_WIDTH / 2, c.h,
         bar_index + CANDLE_WIDTH / 2, math.max(c.o, c.c),
         color = bull ? bull_wick_col : bear_wick_col
     )

    c.wick_down := line.new(
         bar_index + CANDLE_WIDTH / 2, math.min(c.o, c.c),
         bar_index + CANDLE_WIDTH / 2, c.l,
         color = bull ? bull_wick_col : bear_wick_col
     )

    htf_candles.unshift(c)

    if htf_candles.size() > htf_max_display
        Candle del = htf_candles.pop()
        box.delete(del.body)
        line.delete(del.wick_up)
        line.delete(del.wick_down)

// live HTF candle OHLC
if htf_show and htf_candles.size() > 0
    Candle cur = htf_candles.first()
    cur.h     := math.max(cur.h, high)
    cur.l     := math.min(cur.l, low)
    cur.c     := close
    cur.c_idx := bar_index
    bool bull  = cur.c > cur.o
    box.set_top(cur.body,          math.max(cur.o, cur.c))
    box.set_bottom(cur.body,       math.min(cur.o, cur.c))
    box.set_bgcolor(cur.body,      bull ? bull_body_col   : bear_body_col)
    box.set_border_color(cur.body, bull ? bull_border_col : bear_border_col)
    line.set_y1(cur.wick_up,   cur.h)
    line.set_y2(cur.wick_up,   math.max(cur.o, cur.c))
    line.set_y1(cur.wick_down, cur.l)
    line.set_y2(cur.wick_down, math.min(cur.o, cur.c))
    line.set_color(cur.wick_up,   bull ? bull_wick_col : bear_wick_col)
    line.set_color(cur.wick_down, bull ? bull_wick_col : bear_wick_col)


if htf_show and (barstate.isrealtime or barstate.islast)
    int sz = htf_candles.size()
    if sz > 0
        for i = sz - 1 to 0 by 1
            Candle c    = htf_candles.get(i)
            int tb      = htf_offset + (CANDLE_WIDTH + CANDLE_BUFFER) * (sz - i - 1)
            int left_x  = bar_index + tb
            int right_x = bar_index + tb + CANDLE_WIDTH
            // True pixel center of the box
            int cx      = left_x + math.round((right_x - left_x) / 2)
            box.set_left(c.body,     left_x)
            box.set_right(c.body,    right_x)
            line.set_x1(c.wick_up,   cx)
            line.set_x2(c.wick_up,   cx)
            line.set_x1(c.wick_down, cx)
            line.set_x2(c.wick_down, cx)

//+------------------------------------------------------------------------------------------------------------+//
//+--- HTF HIGH / LOW / MID LINES                                                                          ---+//
//+------------------------------------------------------------------------------------------------------------+//

if htf_show and hl_show and htf_candles.size() > 0
    Candle cur    = htf_candles.first()
    float htf_h   = cur.h
    float htf_l   = cur.l
    float htf_mid = (htf_h + htf_l) / 2
    int   start   = cur.o_idx
    int   end_x   = bar_index + htf_offset + CANDLE_WIDTH + 2

    if na(htf_high_line)
        // Solid High and Low lines
        htf_high_line := line.new(start, htf_h,   end_x, htf_h,   color=hl_color,  width=hl_width, style=line.style_solid,  extend=extend.none)
        htf_low_line  := line.new(start, htf_l,   end_x, htf_l,   color=hl_color,  width=hl_width, style=line.style_solid,  extend=extend.none)
        // Dotted mid line
        htf_mid_line  := line.new(start, htf_mid, end_x, htf_mid, color=mid_color, width=1,         style=line.style_dotted, extend=extend.none)
        htf_high_lbl  := label.new(start, htf_h, 'High', color=TRANSPARENT, textcolor=hl_color, style=label.style_label_right, size=size.small)
        htf_low_lbl   := label.new(start, htf_l, 'Low',  color=TRANSPARENT, textcolor=hl_color, style=label.style_label_right, size=size.small)
    else
        line.set_xy1(htf_high_line, start, htf_h)
        line.set_xy2(htf_high_line, end_x, htf_h)
        line.set_xy1(htf_low_line,  start, htf_l)
        line.set_xy2(htf_low_line,  end_x, htf_l)
        if mid_show
            line.set_xy1(htf_mid_line, start, htf_mid)
            line.set_xy2(htf_mid_line, end_x, htf_mid)
        label.set_xy(htf_high_lbl, start, htf_h)
        label.set_xy(htf_low_lbl,  start, htf_l)

    // Hide/show mid line 
    line.set_style(htf_mid_line, mid_show ? line.style_dotted : line.style_solid)
    line.set_color(htf_mid_line, mid_show ? mid_color : TRANSPARENT)

//+------------------------------------------------------------------------------------------------------------+//
//+--- FAIR VALUE GAP (FVG)                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//

if fvg_show and bar_index >= 2
    bool bear_fvg = low[2] > high[0]
    bool bull_fvg = high[2] < low[0]

    if bear_fvg and fvg_boxes.size() < fvg_max
        Imbalance imb = Imbalance.new()
        imb.b := box.new(
             bar_index - 1, low[2],
             bar_index,     high[0],
             border_color = fvg_border_col,
             bgcolor      = fvg_bear_col
         )
        if fvg_label_show
            label.new(bar_index, (low[2] + high[0]) / 2, 'FVG',
                 color=color.new(color.red, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        fvg_boxes.push(imb)

    if bull_fvg and fvg_boxes.size() < fvg_max
        Imbalance imb = Imbalance.new()
        imb.b := box.new(
             bar_index - 1, high[2],
             bar_index,     low[0],
             border_color = color.new(color.green, 20),
             bgcolor      = fvg_bull_col
         )
        if fvg_label_show
            label.new(bar_index, (high[2] + low[0]) / 2, 'FVG',
                 color=color.new(color.green, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        fvg_boxes.push(imb)

    while fvg_boxes.size() > fvg_max
        Imbalance del = fvg_boxes.shift()
        box.delete(del.b)

//+------------------------------------------------------------------------------------------------------------+//
//+--- MARKET STRUCTURE SHIFT (MSS)                                                                        ---+//
//+------------------------------------------------------------------------------------------------------------+//

if mss_show and bar_index >= mss_lookback
    float prior_low  = ta.lowest(low,   mss_lookback)[1]
    float prior_high = ta.highest(high, mss_lookback)[1]

    bool bearish_mss = close < prior_low  and close[1] >= prior_low
    bool bullish_mss = close > prior_high and close[1] <= prior_high

    if bearish_mss
        mss_l   = line.new(bar_index - mss_lookback, prior_low, bar_index, prior_low,
                     color=mss_col, width=mss_width, style=line.style_solid)
        mss_lbl = label.new(
                     math.round((bar_index - mss_lookback + bar_index) / 2), prior_low, 'MSS',
                     color=TRANSPARENT, textcolor=mss_col,
                     style=label.style_label_up, size=size.normal)
        MSS_Level lvl = MSS_Level.new()
        lvl.lvl := mss_l
        lvl.lbl := mss_lbl
        mss_levels.push(lvl)

    if bullish_mss
        mss_l   = line.new(bar_index - mss_lookback, prior_high, bar_index, prior_high,
                     color=mss_col, width=mss_width, style=line.style_solid)
        mss_lbl = label.new(
                     math.round((bar_index - mss_lookback + bar_index) / 2), prior_high, 'MSS',
                     color=TRANSPARENT, textcolor=mss_col,
                     style=label.style_label_down, size=size.normal)
        MSS_Level lvl = MSS_Level.new()
        lvl.lvl := mss_l
        lvl.lbl := mss_lbl
        mss_levels.push(lvl)

    while mss_levels.size() > 5
        MSS_Level del = mss_levels.shift()
        line.delete(del.lvl)
        label.delete(del.lbl)

//+------------------------------------------------------------------------------------------------------------+//
//+--- DISPLACEMENT ZONE                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

atr14 = f_atr(14)

if disp_show and bar_index >= disp_min_candles
    bool all_bear = true
    bool all_bull = true

    for i = 0 to disp_min_candles - 1 by 1
        if close[i] >= open[i]
            all_bear := false
        if close[i] <= open[i]
            all_bull := false

    float avg_body = 0.0
    for i = 0 to disp_min_candles - 1 by 1
        avg_body += math.abs(close[i] - open[i])
    avg_body /= disp_min_candles

    bool is_displacement = (all_bear or all_bull) and avg_body > atr14 * disp_atr_mult

    if is_displacement
        float zone_high = ta.highest(high, disp_min_candles)
        float zone_low  = ta.lowest(low,   disp_min_candles)
        color zone_col  = all_bear ? disp_bear_col : disp_bull_col

        DisplacementZone dz = DisplacementZone.new()
        dz.b := box.new(
             bar_index - disp_min_candles + 1, zone_high,
             bar_index, zone_low,
             border_color=TRANSPARENT, bgcolor=zone_col
         )
        disp_zones.push(dz)

        while disp_zones.size() > 5
            DisplacementZone del = disp_zones.shift()
            box.delete(del.b)
//---------End of script----------//
````
