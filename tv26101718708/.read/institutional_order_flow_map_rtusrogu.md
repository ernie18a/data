# Institutional Order Flow Map

- url: https://www.tradingview.com/script/RtUSROgU-Institutional-Order-Flow-Map/
- type: indicator
- pine_id: PUB;a7a571f82eb343e6907f5a84475e5dd4
- version: 1.0

## Description

[b]WHAT IT DOES[/b]
Institutional Order Flow Map (IOFM) is a fully original Smart Money
Concepts indicator built in Pine Script v6. It detects and visualizes
where institutional players are actively placing orders by analyzing
three simultaneous data streams: abnormal volume activity, price
rejection behavior, and structural pivot zones.

The result is a clean, layered map of the market showing exactly where
large participants have been buying and selling, how strong each zone
is relative to others, and which direction the institutional order
flow is currently pointing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]WHAT MAKES IT ORIGINAL[/b]

Most SMC indicators detect Order Blocks using only price structure
(pivot highs and lows). IOFM adds two additional layers that are
not combined in any existing public indicator:

1. Institutional Footprint Detection
   Each candle is evaluated for three conditions simultaneously:
   volume exceeds the 20-bar SMA by a user-defined multiplier,
   the rejection wick exceeds a minimum percentage of the total
   candle range, and the candle closes in the direction of the
   move. When all three align, the candle is marked as an
   institutional footprint. A Volume Climax marker appears when
   volume exceeds 1.5x the standard threshold, indicating extreme
   institutional participation.

2. Order Density Score (0-100)
   Every zone receives a weighted quality score calculated from
   three independent components. Volume Score contributes up to
   40 points based on how elevated volume was at the pivot.
   Rejection Score contributes up to 30 points based on the
   wick-to-range ratio at the pivot. Trend Alignment Score
   contributes 30 points when the zone type agrees with the
   EMA200 trend direction. Only zones above the minimum score
   threshold are displayed, ensuring the chart shows only the
   strongest institutional areas.

3. Flow Direction Engine
   A signed cumulative delta is calculated for each bar as
   (close - open) / range x volume. This measures whether buying
   or selling pressure dominated each candle. The sum of this
   delta over the calculation period is normalized to a -100
   to +100 scale and displayed as a directional flow label.
   This tells traders whether institutional money is currently
   flowing into or out of the market, independent of price
   direction alone.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]HOW TO USE[/b]

Step 1 — Read the Footprint markers
Green upward arrows (▲) mark candles where institutions were
actively buying: high volume, strong lower wick, and bullish
close. Red downward arrows (▼) mark institutional selling.
The 🏛 BUY and 🏛 SELL labels appear on Volume Climax candles
where institutional activity was extreme. These are the highest
conviction footprint signals.

Step 2 — Identify the strongest zones
Green boxes are Buy Zones (demand areas) where institutional
buyers previously accumulated positions. Red boxes are Sell
Zones (supply areas) where institutional sellers distributed.
Each zone displays a score (for example B 78 or S 65).
Higher scores indicate stronger institutional interest at
that level. Only zones above the minimum score threshold
are shown to keep the chart clean.

[b]Step 3 — Watch for mitigation[/b]
When price closes through a Buy Zone from above, the zone
fades to indicate it has been mitigated (consumed). When
price closes through a Sell Zone from below, the same
happens. Mitigated zones are no longer considered active
institutional areas and should be treated with lower
confidence.

Step 4 — Check Flow Direction
The Flow Direction label in the top-right of the chart
shows the current institutional bias: Buying, Selling,
or Neutral. This is based on the cumulative signed delta
calculation, not just price direction. Use this to confirm
whether the footprint markers and zone interactions are
backed by actual order flow.

Step 5 — Read the Dashboard
The top-right panel shows: Institutional Bias (Bullish
or Bearish based on zone strength comparison), Flow
Direction and Strength (0-100), Top Buy Zone score,
Top Sell Zone score, current Footprint reading, Volume
status, and count of active zones on each side.

Step 6 — Combine signals
The strongest setups occur when multiple elements align:
price returning to a high-score zone, a 🏛 footprint
marker on that candle, Flow Direction agreeing with
the zone type, and EMA200 trend in the same direction.
When all four align, the institutional evidence is
at its strongest.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]
CALCULATION LOGIC[/b]

Institutional Footprint conditions:
  inst_vol  = volume > SMA(volume, 20) x vol_multiplier
  lower_rej = lower_wick / candle_range x 100
  upper_rej = upper_wick / candle_range x 100
  inst_buy  = inst_vol AND lower_rej >= wick_threshold AND close > open
  inst_sell = inst_vol AND upper_rej >= wick_threshold AND close < open
  vol_climax = volume > SMA(volume, 20) x (vol_multiplier x 1.5)

Order Density Score:
  vol_score   = min(round(volume_at_pivot / SMA_volume x 25), 40)
  rej_score   = min(round(wick_pct x 0.4), 30)
  trend_score = 30 if zone aligns with EMA200, else 10
  total_score = min(vol_score + rej_score + trend_score, 100)

Flow Direction Engine:
  bar_delta  = (close - open) / candle_range x volume
  flow_sum   = SUM(bar_delta, period)
  flow_max   = HIGHEST(ABS(flow_sum), 50)
  flow_norm  = flow_sum / flow_max x 100
  flow_bull  = flow_norm > 10
  flow_bear  = flow_norm < -10

Zone mitigation:
  Buy Zone mitigated  when low <= zone_bottom
  Sell Zone mitigated when high >= zone_top

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS OVERVIEW

Module A — Institutional Footprint:
  Show Footprint candles — toggle markers on/off
  Volume threshold (SMA x) — multiplier for institutional volume
  Min rejection wick (%) — minimum wick size to qualify

Module B — Order Flow Zones:
  Show Order Flow Zones — toggle zones on/off
  Zone pivot lookback — bars used for pivot detection
  Zone height (ATR x) — vertical size of each zone
  Extend zones (bars) — how far right zones extend
  Fade mitigated zones — toggle mitigation visual

Module C — Flow Direction:
  Flow calculation period — bars for cumulative delta
  Show Flow Direction label — toggle directional label

Module D — Order Density:
  Show score on zones — toggle score labels
  Min score to show — filter threshold (default 60)

Dashboard:
  Show Dashboard — toggle info panel

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS INCLUDED

  Institutional Buy footprint detected
  Institutional Sell footprint detected
  Volume Climax — extreme institutional activity
  Strong Buy — flow direction and footprint aligned bullish
  Strong Sell — flow direction and footprint aligned bearish

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMPATIBILITY

Works on all assets — Crypto, Forex, Stocks, Futures, Indices.
Works on all timeframes.
Best results on 15m to 4H for active trading.
No repainting. All signals calculated on bar close.
No request.security() calls. No lookahead bias.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is provided for educational and informational
purposes only. It does not constitute financial advice or a
recommendation to buy or sell any asset. The Order Density
Score and Flow Direction calculations are mathematical models
based on price and volume data and do not represent actual
order book information. Past institutional footprint patterns
do not guarantee future results. Always apply your own
analysis and use proper risk management before placing
any trade. The author is not responsible for any trading
losses incurred from use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// Institutional Order Flow Map v2.0 — AleksDU

indicator("Institutional Order Flow Map",
          shorttitle        = "IOFM",
          overlay           = true,
          max_boxes_count   = 30,
          max_lines_count   = 100,
          max_labels_count  = 100)

// ── UDT ──────────────────────────────────────────────────────────────────────
type FlowZone
    float top
    float bot
    float score
    bool  is_buy
    bool  mitigated
    box   zbox
    line  zline

// ── SETTINGS ──────────────────────────────────────────────────────────────────
var string G_A = "Module A: Institutional Footprint"
fp_show     = input.bool(true,  "Show Footprint candles",   group=G_A)
fp_vol_mult = input.float(2.0,  "Volume threshold (SMA x)", group=G_A, minval=1.2, maxval=6.0, step=0.1)
fp_wick_pct = input.float(40.0, "Min rejection wick (%)",   group=G_A, minval=10.0, maxval=80.0, step=5.0)

var string G_B = "Module B: Order Flow Zones"
oz_show      = input.bool(true,  "Show Order Flow Zones",  group=G_B)
oz_pivot_len = input.int(15,     "Zone pivot lookback",    group=G_B, minval=3, maxval=50)
oz_atr_mult  = input.float(0.2,  "Zone height (ATR x)",   group=G_B, minval=0.05, maxval=1.0, step=0.05)
oz_ext       = input.int(20,     "Extend zones (bars)",   group=G_B, minval=5,  maxval=100)
oz_mit       = input.bool(true,  "Fade mitigated zones",  group=G_B)

var string G_C = "Module C: Flow Direction"
fd_len  = input.int(20,    "Flow calculation period",  group=G_C, minval=5, maxval=50)
fd_show = input.bool(true, "Show Flow Direction label", group=G_C)

var string G_D = "Module D: Order Density"
od_show = input.bool(true, "Show score on zones", group=G_D)
od_min  = input.int(60,    "Min score to show",   group=G_D, minval=0, maxval=90,
           tooltip="Only zones with score above this value are shown")

var string G_E = "Dashboard"
dash_show = input.bool(true, "Show Dashboard", group=G_E)

// ── SHARED ────────────────────────────────────────────────────────────────────
atr14   = ta.atr(14)
vol_sma = ta.sma(volume, 20)
ema200  = ta.ema(close, 200)

// ── MODULE A: INSTITUTIONAL FOOTPRINT ────────────────────────────────────────
candle_range = high - low
upper_wick   = high - math.max(open, close)
lower_wick   = math.min(open, close) - low
upper_rej    = candle_range > 0 ? upper_wick / candle_range * 100 : 0.0
lower_rej    = candle_range > 0 ? lower_wick / candle_range * 100 : 0.0
inst_vol     = volume > vol_sma * fp_vol_mult
inst_buy     = inst_vol and lower_rej >= fp_wick_pct and close > open
inst_sell    = inst_vol and upper_rej >= fp_wick_pct and close < open
vol_climax   = volume > vol_sma * (fp_vol_mult * 1.5)

if fp_show
    if inst_buy
        label.new(bar_index, low - atr14 * 0.3,
                  vol_climax ? "🏛 BUY" : "▲",
                  color=color.new(#00e676, vol_climax ? 5 : 20),
                  textcolor=color.white,
                  size=vol_climax ? size.normal : size.small,
                  style=label.style_label_up)
    if inst_sell
        label.new(bar_index, high + atr14 * 0.3,
                  vol_climax ? "🏛 SELL" : "▼",
                  color=color.new(#ff5252, vol_climax ? 5 : 20),
                  textcolor=color.white,
                  size=vol_climax ? size.normal : size.small,
                  style=label.style_label_down)

barcolor(inst_buy   and fp_show ? color.new(#00e676, 45) :
         inst_sell  and fp_show ? color.new(#ff5252, 45) :
         vol_climax and fp_show ? color.new(#ffe57f, 35) : na)

// ── MODULE B: ORDER FLOW ZONES ────────────────────────────────────────────────
ph = ta.pivothigh(high, oz_pivot_len, oz_pivot_len)
pl = ta.pivotlow (low,  oz_pivot_len, oz_pivot_len)

vol_score(float v)   => math.min(math.round(v / math.max(vol_sma, 1.0) * 25.0), 40)
rej_score(float r)   => math.min(math.round(r * 0.4), 30)
trend_score(bool ib) => ib and close > ema200 ? 30 : not ib and close < ema200 ? 30 : 10

var array<FlowZone> buy_zones  = array.new<FlowZone>()
var array<FlowZone> sell_zones = array.new<FlowZone>()

float oz_half = atr14 * oz_atr_mult * 0.5

// BUY ZONE
if oz_show and not na(pl)
    float zc    = (high[oz_pivot_len] + low[oz_pivot_len]) / 2
    float score = math.min(vol_score(volume[oz_pivot_len]) + rej_score(lower_rej[oz_pivot_len]) + trend_score(true), 100)
    if score >= od_min
        color bg = color.new(#00e676, score >= 70 ? 80 : 88)
        color br = color.new(#00e676, score >= 70 ? 25 : 45)
        // Thin box
        FlowZone z = FlowZone.new(zc + oz_half, zc - oz_half, score, true, false,
             box.new(bar_index - oz_pivot_len, zc + oz_half,
                     bar_index + oz_ext, zc - oz_half,
                     bgcolor=bg, border_color=color.new(#00e676, 95), border_width=0),
             // Top border line only — cleaner look
             line.new(bar_index - oz_pivot_len, zc + oz_half,
                      bar_index + oz_ext, zc + oz_half,
                      color=br, width=1, style=line.style_solid))
        array.push(buy_zones, z)
        // Small label on the line
        if od_show
            label.new(bar_index + oz_ext, zc + oz_half,
                      "B " + str.tostring(math.round(score)),
                      color=color.new(#00e676, 20), textcolor=color.white,
                      size=size.tiny, style=label.style_label_left)

// SELL ZONE
if oz_show and not na(ph)
    float zc    = (high[oz_pivot_len] + low[oz_pivot_len]) / 2
    float score = math.min(vol_score(volume[oz_pivot_len]) + rej_score(upper_rej[oz_pivot_len]) + trend_score(false), 100)
    if score >= od_min
        color bg = color.new(#ff5252, score >= 70 ? 80 : 88)
        color br = color.new(#ff5252, score >= 70 ? 25 : 45)
        FlowZone z = FlowZone.new(zc + oz_half, zc - oz_half, score, false, false,
             box.new(bar_index - oz_pivot_len, zc + oz_half,
                     bar_index + oz_ext, zc - oz_half,
                     bgcolor=bg, border_color=color.new(#ff5252, 95), border_width=0),
             line.new(bar_index - oz_pivot_len, zc - oz_half,
                      bar_index + oz_ext, zc - oz_half,
                      color=br, width=1, style=line.style_solid))
        array.push(sell_zones, z)
        if od_show
            label.new(bar_index + oz_ext, zc - oz_half,
                      "S " + str.tostring(math.round(score)),
                      color=color.new(#ff5252, 20), textcolor=color.white,
                      size=size.tiny, style=label.style_label_left)

// Mitigation
if oz_mit
    if array.size(buy_zones) > 0
        for i = array.size(buy_zones) - 1 to 0
            FlowZone z = array.get(buy_zones, i)
            if not z.mitigated and low <= z.bot
                z.mitigated := true
                box.set_bgcolor(z.zbox, color.new(#00e676, 97))
                line.set_color(z.zline, color.new(#00e676, 75))
    if array.size(sell_zones) > 0
        for i = array.size(sell_zones) - 1 to 0
            FlowZone z = array.get(sell_zones, i)
            if not z.mitigated and high >= z.top
                z.mitigated := true
                box.set_bgcolor(z.zbox, color.new(#ff5252, 97))
                line.set_color(z.zline, color.new(#ff5252, 75))

// Keep max 5 zones per side
if array.size(buy_zones) > 5
    FlowZone old = array.shift(buy_zones)
    box.delete(old.zbox)
    line.delete(old.zline)
if array.size(sell_zones) > 5
    FlowZone old = array.shift(sell_zones)
    box.delete(old.zbox)
    line.delete(old.zline)

// ── MODULE C: FLOW DIRECTION ──────────────────────────────────────────────────
bar_delta = candle_range > 0 ? (close - open) / candle_range * volume : 0.0
flow_sum  = math.sum(bar_delta, fd_len)
flow_max  = ta.highest(math.abs(flow_sum), 50)
flow_norm = flow_max > 0 ? flow_sum / flow_max * 100 : 0.0
flow_bull = flow_norm > 10
flow_bear = flow_norm < -10

if fd_show and barstate.islast
    label.new(bar_index + 2, close,
              flow_bull ? "▲ Flow: BUYING" :
              flow_bear ? "▼ Flow: SELLING" : "◆ Flow: NEUTRAL",
              color=flow_bull ? color.new(#00e676, 15) :
                    flow_bear ? color.new(#ff5252, 15) :
                                color.new(#ffeb3b, 15),
              textcolor=color.white,
              size=size.small, style=label.style_label_left)

// ── STATS ─────────────────────────────────────────────────────────────────────
var float top_buy_score  = 0.0
var float top_sell_score = 0.0
top_buy_score  := 0.0
top_sell_score := 0.0

if array.size(buy_zones) > 0
    for i = 0 to array.size(buy_zones) - 1
        FlowZone z = array.get(buy_zones, i)
        if not z.mitigated and z.score > top_buy_score
            top_buy_score := z.score
if array.size(sell_zones) > 0
    for i = 0 to array.size(sell_zones) - 1
        FlowZone z = array.get(sell_zones, i)
        if not z.mitigated and z.score > top_sell_score
            top_sell_score := z.score

string inst_bias = top_buy_score > top_sell_score ? "Bullish" :
                   top_sell_score > top_buy_score  ? "Bearish" : "Neutral"
color  bias_col  = top_buy_score > top_sell_score  ? #00e676  :
                   top_sell_score > top_buy_score   ? #ff5252  : #ffeb3b

score_col(float s) => s >= 70 ? #00e676 : s >= 50 ? #ffeb3b : #ff9800

// ── DASHBOARD ─────────────────────────────────────────────────────────────────
if dash_show and barstate.islast
    var table dash = table.new(position.top_right, 2, 10,
                               bgcolor=color.new(#0d1117, 5),
                               border_color=color.new(#21262d, 35), border_width=1,
                               frame_color=color.new(#00bcd4, 30), frame_width=1)
    table.cell(dash, 0, 0, "Institutional Order Flow Map",
               bgcolor=color.new(#161b22, 10), text_color=#00bcd4,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, "AleksDU",
               bgcolor=color.new(#161b22, 10), text_color=color.new(#00bcd4, 50),
               text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 1, "Inst. Bias",      text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 1, inst_bias,         text_color=bias_col,   text_size=size.small)
    table.cell(dash, 0, 2, "Flow Direction",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, flow_bull ? "Buying" : flow_bear ? "Selling" : "Neutral",
               text_color=flow_bull ? #00e676 : flow_bear ? #ff5252 : #ffeb3b, text_size=size.small)
    table.cell(dash, 0, 3, "Flow Strength",   text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(math.round(math.abs(flow_norm))) + " / 100",
               text_color=score_col(math.abs(flow_norm)), text_size=size.small)
    table.cell(dash, 0, 4, "Top Buy Zone",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(math.round(top_buy_score)) + " / 100",
               text_color=score_col(top_buy_score), text_size=size.small)
    table.cell(dash, 0, 5, "Top Sell Zone",   text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(math.round(top_sell_score)) + " / 100",
               text_color=score_col(top_sell_score), text_size=size.small)
    table.cell(dash, 0, 6, "Inst. Footprint", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 6, inst_buy ? "BUY" : inst_sell ? "SELL" : "—",
               text_color=inst_buy ? #00e676 : inst_sell ? #ff5252 : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Volume",          text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 7, vol_climax ? "Climax!" : inst_vol ? "Elevated" : "Normal",
               text_color=vol_climax ? #ffe57f : inst_vol ? #ff9800 : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Active Buy Zones",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(array.size(buy_zones)), text_color=#00e676, text_size=size.small)
    table.cell(dash, 0, 9, "Active Sell Zones", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(array.size(sell_zones)), text_color=#ff5252, text_size=size.small)

// ── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(inst_buy,               "IOFM: Inst. Buy",   "Institutional Order Flow: BUY footprint!")
alertcondition(inst_sell,              "IOFM: Inst. Sell",  "Institutional Order Flow: SELL footprint!")
alertcondition(vol_climax,             "IOFM: Vol Climax",  "Institutional Order Flow: Volume Climax!")
alertcondition(flow_bull and inst_buy, "IOFM: Strong Buy",  "Institutional Flow: STRONG BUY signal!")
alertcondition(flow_bear and inst_sell,"IOFM: Strong Sell", "Institutional Flow: STRONG SELL signal!")
````
