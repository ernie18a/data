# Liquidity Absorption and Rejection Orderflow @MaxMaserati

- url: https://www.tradingview.com/script/Qt40jcF2-Liquidity-Absorption-and-Rejection-Orderflow-MaxMaserati/
- type: indicator
- pine_id: PUB;6226f8beb7c7440485271e3b2b5217a3
- version: 1.0

## Description

Liquidity Absorption and Rejection Orderflow

An order flow analysis engine that tracks every high and low the market forms and classifies what happened when price returned to that level — whether passive orders defended it, were absorbed, or were broken through — using footprint delta and volume ratio analysis. Every level on the chart shows a ● when untouched and a ✕ when price has crossed it, so the trader sees the status of each liquidity pool at a glance without reading the outcome text.

─── WHY THESE COMPONENTS TOGETHER ───

Volume analysis alone shows whether activity at a price level was above or below average, but cannot tell which side was dominant. Footprint delta alone shows the buy/sell imbalance but has no structural anchor — it does not know which historical level it is measuring against, or whether price closed back through it. Passive order level tracking alone shows where orders were resting but cannot determine whether they held or were consumed.

This script integrates all three simultaneously. The structural level comes from the price history. The volume ratio against the moving average determines conviction. The footprint delta percentage determines which side was dominant. All three feed into a single classification engine that produces one outcome label per level touched.

─── LEVEL STATES AND MARKERS ───

Every level carries a ● or ✕ marker and falls into one of four states:

Last — the most recent closed candle's high and low. These are the first passive orders price is approaching on the live candle. The marker switches from ● to ✕ the moment the live candle's high or low crosses the level intrabar — no need to wait for the candle to close. Resets automatically when the next candle opens.

  Sell Limit Orders Liquidity ●  →  not yet reached on the live candle
  Sell Limit Orders Liquidity ✕  →  live candle has traded through this level

[image]https://www.tradingview.com/x/o5ox3PeW/[/image]

Untouched — historical highs and lows price has not revisited since they were formed. Passive orders are presumed resting here. Always shows ●.

  Sell Limit Orders Liquidity ●
  Buy Limit Orders Liquidity ●

Touched — levels price has visited. Whether liquidity remains is unknown. The outcome label shows what the volume and delta evidence suggests happened. Always shows ✕.

  Sell Limit Orders Liquidity ✕ > Sellers Defended Level
  Buy Limit Orders Liquidity ✕ > Sellers Rejected by Buyers

Absorbed — levels where the outcome engine determined passive orders were consumed or overwhelmed. Solid wider line, highest priority formatting. Always shows ✕.

  Sell Limit Orders Liquidity ✕ > Bull Trap, Weak Breakout (Low Vol)
  Buy Limit Orders Liquidity ✕ > Sellers Exhausted, Buyers Breakout

A ★ marker appears additionally on any level where the candle's body closed at the extreme — a wickless interaction — indicating maximum commitment.

─── THE OUTCOME ENGINE ───

When price touches a level, the engine classifies the interaction. With footprint data:

  At a high level — close back below (Touched):
    sell_pct = sell_volume / total_volume
    sell_dom = sell_pct >= delta_threshold
    sell_dom AND vol_ratio >= exhaustion → "Buyers Exhausted, Sellers Dominate"
    sell_dom AND vol_ratio >= absorption → "Sellers Absorbed Buyers"
    not sell_dom                         → "Buyers Rejected by Sellers"

  At a high level — close above (Absorbed):
    buy_dom AND vol_ratio >= exhaustion  → "Sellers Exhausted, Buyers Breakout"
    buy_dom                              → "Buyers Overwhelmed Sellers"
    vol_ratio <= capitulation            → "Bull Trap, Weak Breakout (Low Vol)"

The same logic runs in mirror for low levels. Without footprint data the engine falls back to body/wick proportion analysis — all outcomes remain available with less precision.

─── LABEL FORMAT ───

The Label Format setting controls what appears on every level:

  Name only:             Sell Limit Orders ●  /  Buy Limit Orders ✕
  Name + Liquidity:      Sell Limit Orders Liquidity ●  /  Buy Limit Orders Liquidity ✕  (default)
  Name + Orders + Liquidity:  Sell Orders Liquidity ●  /  Buy Orders Liquidity ✕

The Order Name setting switches the base name across all levels: Limit Orders (BLO/SLO), Passive (PB/PS), or abbreviated forms. The ● / ✕ marker display can be turned off independently in settings.

─── CONTEXT TABLE ───

Volume and Delta — current bar volume ratio against the moving average and raw footprint delta.
Vol Context — NORMAL / HIGH (Buyers or Sellers Absorbing) / EXTREME (Exhaustion zone) / LOW (Stop hunt zone).
CC Bid/Ask — current candle buy and sell volume percentage split.
PC Bid/Ask — prior candle buy and sell volume percentage split.
Last High Hit — outcome of the most recent high-level interaction.
Last Low Hit — outcome of the most recent low-level interaction.

─── HOW TO USE ───

1. Watch the Last levels — Sell Limit Orders Liquidity above and Buy Limit Orders Liquidity below. These are the first passive orders the live candle is approaching. When the marker switches from ● to ✕ intrabar, price has just crossed that liquidity pool.

2. When a level transitions to Touched with an outcome like "Sellers Defended Level" or "Buyers Rejected by Sellers", the passive orders at that level held. Treat the level as active resistance or support on retest.

3. When the label shows ✕ with "Buyers Overwhelmed Sellers" or "Sellers Exhausted, Buyers Breakout", the passive orders were consumed. That level is now potential support or resistance on retest in the opposite direction.

4. Untouched levels (●) further from price show where deeper pools of passive orders are resting. These are the natural targets for extended moves.

5. The ★ marker on any level signals a wickless body close — maximum aggression, highest-conviction interaction.

6. Use the Context Table's Last High Hit and Last Low Hit rows to read the most recent order flow resolution without scanning the chart.

─── SETTINGS ───

Multi-Timeframe — the timeframe on which level tracking runs. Blank uses the chart timeframe.
Candle Bias Coloring — candle direction coloring and color configuration.
Limit Orders — Order Name, Label Format, ● / ✕ marker toggle, colors for buy and sell limits, individual toggles and line styles for Last, Untouched, Touched, and Absorbed levels, maximum Untouched levels shown per side.
Absorption Logic — historical lookback range, label text visibility, arrow visibility.
Footprint and Order Flow — footprint delta toggle, ticks per row, value area percentage, volume MA period.
Outcome Thresholds — volume ratio multipliers for absorption, exhaustion, and capitulation, and delta dominance threshold.
Context Table — position, text size, and color.

─── NOTES ───

Footprint delta requires a TradingView plan with intraday tick data. Without it the indicator falls back to body/wick proportion analysis — all outcome labels remain available but are less precise. The Last level ✕ marker fires intrabar as soon as the live candle's high or low crosses the level — it does not wait for the bar to close. All other classification uses confirmed closed candle values.

## Source Code

````pine
//@version=6
indicator("Liquidity Absorption and Rejection Orderflow @MaxMaserati", "Liquidity Absorption and Rejection @MaxMaserati", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────
grp_mtf = "Multi-Timeframe" 
mtf_in = input.timeframe("", "Calculation Timeframe)", group=grp_mtf,
     tooltip="Set to a higher timeframe to track liquidity levels formed on HTF candles while viewing a lower timeframe chart. Leave blank to run on the current chart timeframe.")

grp_colors = "Candle Bias Coloring"
show_bias_color = input.bool(true, "Enable Bias Candle Coloring", group=grp_colors,
     tooltip="Colors each candle by direction: bullish close (close > open) uses the Bullish color, bearish close uses the Bearish color, and doji (close = open) uses Neutral.")
col_bias_bull = input.color(color.lime, "Bullish", inline="bias", group=grp_colors)
col_bias_bear = input.color(color.red,  "Bearish", inline="bias", group=grp_colors)
col_bias_neut = input.color(color.gray, "Neutral", inline="bias", group=grp_colors)

grp_lo = "Limit Orders"
naming_style = input.string("Limit Orders (BLO/SLO)", "Order Name", options=["Limit Orders (BLO/SLO)", "Passive (PB/PS)", "Abbrev (BLO/SLO)", "Abbrev (PB/PS)"], group=grp_lo,
     tooltip="Sets the base name used in every level label.\n\nLimit Orders (BLO/SLO): Buy Limit Orders / Sell Limit Orders\nPassive (PB/PS): Passive Buyers / Passive Sellers\nAbbrev (BLO/SLO): BLO / SLO\nAbbrev (PB/PS): PB / PS")
label_order = input.string("Name + Liquidity", "Label Format", options=["Name only", "Name + Liquidity", "Name + Orders + Liquidity"], group=grp_lo,
     tooltip="Controls how levels are labelled on the chart.\n\nName only:\n  Sell Limit Orders ● / Buy Limit Orders ✕\n\nName + Liquidity (default):\n  Sell Limit Orders Liquidity ● / Buy Limit Orders Liquidity ✕\n\nName + Orders + Liquidity:\n  Sell Orders Liquidity ● / Buy Orders Liquidity ✕")
col_lo_buy  = input.color(#00e676, "Buy Limits",  inline="lo1", group=grp_lo)
col_lo_sell = input.color(#e91e63, "Sell Limits", inline="lo1", group=grp_lo)

show_last = input.bool(true, "Show Last", inline="last1", group=grp_lo,
     tooltip="Shows the most recent closed candle high and low as simple limit order markers. Label shows the order name + ● when price has not yet touched the level, or ✕ when price crosses it during the live candle. Resets on every candle close.")
last_width     = input.int(2, "Width", inline="last1", group=grp_lo)
last_style_str = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="last1", group=grp_lo)
last_ext       = input.int(5, "Ext", inline="last1", group=grp_lo)

show_unt      = input.bool(true, "Show Untouched", inline="u1", group=grp_lo,
     tooltip="Shows lines at historical highs and lows that price has NOT yet revisited since they were formed. Passive orders are presumed resting at these levels — sellers above, buyers below.")
unt_width     = input.int(1, "Width", inline="u1", group=grp_lo)
unt_style_str = input.string("Dotted", "Style", options=["Solid", "Dashed", "Dotted"], inline="u1", group=grp_lo)
unt_ext       = input.int(5, "Ext", inline="u1", group=grp_lo)
max_unt_sell  = input.int(2, "Max Sells", inline="u2", group=grp_lo, minval=2, maxval=20,
     tooltip="Number of Untouched sell limit levels shown above current price. Increase to see more historical resistance levels.")
max_unt_buy   = input.int(2, "Max Buys",  inline="u2", group=grp_lo, minval=2, maxval=20,
     tooltip="Number of Untouched buy limit levels shown below current price. Increase to see more historical support levels.")

show_tch      = input.bool(true, "Show Touched", inline="t1", group=grp_lo,
     tooltip="Shows lines at levels price has visited. Whether liquidity remains is unknown — price may have absorbed only some orders. The outcome label shows what the volume and delta evidence suggests happened.")
tch_width     = input.int(1, "Width", inline="t1", group=grp_lo)
tch_style_str = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], inline="t1", group=grp_lo)
tch_ext       = input.int(20, "Ext", inline="t1", group=grp_lo)

show_brk      = input.bool(true, "Show Absorbed", inline="b1", group=grp_lo,
     tooltip="Shows lines at levels where the outcome engine determined passive orders were CONSUMED — buyers overwhelmed sellers, or sellers absorbed all available buy pressure and broke through. Highest priority state.")
brk_width     = input.int(2, "Width", inline="b1", group=grp_lo)
brk_style_str = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="b1", group=grp_lo)
brk_ext       = input.int(20, "Ext", inline="b1", group=grp_lo)

grp_settings = "Absorption Logic"
lookback = input.int(100, "Max Historical Candles to Scan", group=grp_settings,
     tooltip="How many bars back the script tracks highs and lows as active limit order levels. Increase to see more historical levels. Decrease to reduce CPU load on very long charts.")
show_text   = input.bool(true, "Show  Labels", inline="lv1", group=grp_settings,
     tooltip="Shows the outcome text label next to each level line.")
show_marker = input.bool(true, "Show ● / ✕", group=grp_settings,
     tooltip="Appends ● on levels price has not yet touched and ✕ on levels price has crossed or touched. Applies to all level types including Last, Untouched, Touched, and Absorbed.")
show_arrow = input.bool(true, "Show Arrows", group=grp_settings,
     tooltip="Shows a directional arrow on Touched and Absorbed levels indicating whether current price is above (⬆) or below (⬇) the level.")
col_arrow_bull = input.color(#00e676, "Bull Arrow", inline="ac1", group=grp_settings)
col_arrow_bear = input.color(#f44336, "Bear Arrow", inline="ac1", group=grp_settings)

grp_fp = "Footprint and Order Flow"
use_fp       = input.bool(true, "Use Footprint Delta", group=grp_fp,
     tooltip="Enables true bid/ask footprint data for outcome classification. Requires a TradingView plan with intraday tick data. When OFF, the indicator falls back to body/wick proportion analysis — all outcome labels still appear but with less precision.")
fp_ticks     = input.int(100, "Ticks per Row",    minval=1,            group=grp_fp,
     tooltip="Tick range per footprint row. Lower values produce finer resolution but require more data. 100 ticks is standard for ES/NQ intraday.")
fp_va        = input.int(70,  "Value Area %",     minval=1, maxval=100, group=grp_fp,
     tooltip="Percentage of total volume defining the Value Area. Standard is 70% — the price range containing 70% of all volume traded in the period.")
vol_lookback = input.int(20,  "Volume MA Period", minval=5, maxval=100, group=grp_fp,
     tooltip="Period for the volume moving average used to classify each interaction. Current bar volume is compared to this average to determine whether activity is Normal, High (Absorption/Exhaustion), or Low (Stop Hunt).")

grp_thresh = "Outcome Thresholds"
absorption_vol_pct   = input.float(1.2, "Absorption: Min Vol Ratio vs Avg",   minval=0.5, step=0.1, group=grp_thresh,
     tooltip="Volume must reach at least this multiple of the moving average for an outcome to be classified as Absorption. Default 1.2x = 20% above average. Raise to require stronger evidence before classifying a level as absorbed.")
exhaustion_vol_pct   = input.float(1.5, "Exhaustion: Min Vol Ratio vs Avg",   minval=0.5, step=0.1, group=grp_thresh,
     tooltip="Volume must reach at least this multiple for an outcome to be classified as Exhaustion. Default 1.5x = 50% above average. Exhaustion signals are the highest-conviction reversals — one side ran out of orders.")
capitulation_vol_pct = input.float(0.8, "Capitulation: Max Vol Ratio vs Avg", minval=0.1, step=0.1, group=grp_thresh,
     tooltip="Volume must be at MOST this multiple for a breakout to be classified as a Stop Hunt or Bull/Bear Trap. Default 0.8x = 20% below average. Low-volume breakouts are suspect — orders were likely thin at that level.")
delta_thresh         = input.float(0.6, "Delta Imbalance Threshold (0-1)",    minval=0.0, maxval=1.0, step=0.05, group=grp_thresh,
     tooltip="Minimum fraction of total footprint volume one side must represent to be considered dominant. Default 0.60 = one side must account for at least 60% of all volume. Raise for stricter signal quality, lower for more frequent classifications.")

grp_table = "Context Table"
show_table  = input.bool(true, "Show Context Table", group=grp_table,
     tooltip="Displays a compact table showing live volume ratio, footprint delta, volume context classification, current and prior candle bid/ask split, and the most recent high and low level outcomes.")
table_pos   = input.string("Top Right", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"], group=grp_table)
table_size  = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large"], group=grp_table)
col_tbl_txt = input.color(color.white, "Table Text Color", group=grp_table)

// ─── HELPERS ───────────────────────────────────────────────────────────────
int  chart_ms   = timeframe.in_seconds(timeframe.period) * 1000
bool is_same_tf = (mtf_in == "") or (mtf_in == timeframe.period)

f_get_size(simple string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.tiny

f_tbl_size(simple string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_tbl_pos(simple string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        => position.top_right

f_get_style(simple string s) =>
    s == "Solid" ? line.style_solid : (s == "Dashed" ? line.style_dashed : line.style_dotted)

f_tf_str(simple string s) =>
    v = str.length(s) == 0 ? timeframe.period : s
    switch v
        "1"   => "M1"
        "3"   => "M3"
        "5"   => "M5"
        "15"  => "M15"
        "30"  => "M30"
        "45"  => "M45"
        "60"  => "H1"
        "120" => "H2"
        "180" => "H3"
        "240" => "H4"
        "360" => "H6"
        "480" => "H8"
        "720" => "H12"
        "D"   => "D"
        "1D"  => "D"
        "W"   => "W"
        "1W"  => "W"
        "M"   => "M"
        "1M"  => "M"
        => v

string tf_suffix = is_same_tf ? "" : " [" + f_tf_str(mtf_in) + "]"
int    mtf_ms    = timeframe.in_seconds(mtf_in == "" ? timeframe.period : mtf_in) * 1000

// ─── MTF DATA ──────────────────────────────────────────────────────────────
[h_high, h_low, h_close, h_open, h_t] = request.security(
     syminfo.tickerid,
     mtf_in == "" ? timeframe.period : mtf_in,
     [high, low, close, open, time],
     barmerge.gaps_off, barmerge.lookahead_off)

int  mtf_secs  = timeframe.in_seconds(mtf_in == "" ? timeframe.period : mtf_in)
int  htf_ratio = math.max(1, math.round(mtf_secs / timeframe.in_seconds(timeframe.period)))

int ext_tch_ms  = math.max(3, is_same_tf ? tch_ext  : 3 * htf_ratio) * chart_ms
int ext_brk_ms  = math.max(3, is_same_tf ? brk_ext  : 3 * htf_ratio) * chart_ms
int ext_unt_ms  = unt_ext  * chart_ms
int ext_last_ms = last_ext * chart_ms

bool is_new_htf = ta.change(h_t) != 0
bool run_logic  = is_same_tf ? barstate.isconfirmed : is_new_htf

float bar_H = is_same_tf ? high  : h_high[1]
float bar_L = is_same_tf ? low   : h_low[1]
float bar_C = is_same_tf ? close : h_close[1]
float bar_O = is_same_tf ? open  : h_open[1]
int   bar_T = is_same_tf ? time  : h_t[1]

float stat_close = (barstate.isrealtime and not barstate.isconfirmed) ? close[1] : close

// ─── FOOTPRINT DATA ────────────────────────────────────────────────────────
fp_data = use_fp ? request.footprint(fp_ticks, fp_va) : na

float cc_buy_vol    = use_fp and not na(fp_data) ? fp_data.buy_volume()  : na
float cc_sell_vol   = use_fp and not na(fp_data) ? fp_data.sell_volume() : na
float bar_total_vol = use_fp and not na(fp_data) ? fp_data.buy_volume() + fp_data.sell_volume() : volume
float bar_delta     = use_fp and not na(fp_data) ? fp_data.delta()      : na
float vol_ma        = ta.sma(bar_total_vol, vol_lookback)

float pc_buy_vol  = cc_buy_vol[1]
float pc_sell_vol = cc_sell_vol[1]

// ─── TYPES ─────────────────────────────────────────────────────────────────
type PriceLevel
    float  price
    int    b_time
    float  op
    float  hi
    float  lo
    float  cl

type ActiveLevelSweep
    float  price
    int    b_time
    string lbl_text
    bool   is_brk
    bool   is_wickless

type RenderGroup
    float         price
    array<string> lbl_texts
    color         ln_col
    int           ln_width
    string        ln_style
    bool          has_arr
    bool          is_bull
    bool          is_wickless
    int           b_time
    int           e_time
    int           priority

var array<PriceLevel>  active_highs  = array.new<PriceLevel>()
var array<PriceLevel>  active_lows   = array.new<PriceLevel>()
var array<RenderGroup> render_groups = array.new<RenderGroup>()
var array<line>        d_lines       = array.new<line>()
var array<label>       d_labels      = array.new<label>()
var array<label>       d_arrows      = array.new<label>()

var ActiveLevelSweep swp_fh = na
var ActiveLevelSweep swp_lh = na
var ActiveLevelSweep swp_fl = na
var ActiveLevelSweep swp_ll = na

var string last_high_outcome  = "—"
var string last_low_outcome   = "—"
var int    last_high_hit_time = 0
var int    last_low_hit_time  = 0
var table  ctx_table          = na

// ─── LABEL BUILDER ─────────────────────────────────────────────────────────
f_get_sell_name() =>
    if naming_style == "Limit Orders (BLO/SLO)"
        "Sell Limit Orders"
    else if naming_style == "Passive (PB/PS)"
        "Passive Sellers"
    else if naming_style == "Abbrev (BLO/SLO)"
        "SLO"
    else
        "PS"

f_get_buy_name() =>
    if naming_style == "Limit Orders (BLO/SLO)"
        "Buy Limit Orders"
    else if naming_style == "Passive (PB/PS)"
        "Passive Buyers"
    else if naming_style == "Abbrev (BLO/SLO)"
        "BLO"
    else
        "PB"

// marker: "●" for untouched, "✕" for touched/absorbed, "" for Last (handled separately)
f_build_lbl(string base_name, bool is_wkless, string marker) =>
    string wk  = is_wkless ? " ★" : ""
    string mk  = show_marker ? " " + marker : ""
    string liq = ""
    if label_order == "Name + Liquidity"
        liq := " Liquidity"
    else if label_order == "Name + Orders + Liquidity"
        liq := " Liquidity"
    base_name + liq + wk + mk + tf_suffix

f_sell_lbl(string outcome, bool is_wkless, bool is_brk) =>
    f_build_lbl(f_get_sell_name(), is_wkless, "✕") + " > " + outcome

f_buy_lbl(string outcome, bool is_wkless, bool is_brk) =>
    f_build_lbl(f_get_buy_name(), is_wkless, "✕") + " > " + outcome

// ─── CLASSIFICATION FUNCTIONS ──────────────────────────────────────────────
f_classify_high(float sweep_price, float c_price, float h_price, float l_price, float o_price,
     float dlt, float buy_v, float sell_v, float tot_v, float v_ma) =>
    string res_out = "—"
    if h_price >= sweep_price
        float vr  = v_ma > 0 ? tot_v / v_ma : 1.0
        float rng = math.max(h_price - l_price, syminfo.mintick)
        bool  cb  = c_price < sweep_price
        if use_fp and not na(dlt) and not na(buy_v) and not na(sell_v) and tot_v > 0
            float sell_pct = sell_v / tot_v
            float buy_pct  = buy_v  / tot_v
            bool  sell_dom = sell_pct >= delta_thresh
            bool  buy_dom  = buy_pct  >= delta_thresh
            if cb
                if sell_dom
                    res_out := vr >= exhaustion_vol_pct ? "Buyers Exhausted, Sellers Dominate" : (vr >= absorption_vol_pct ? "Sellers Absorbed Buyers" : "Sellers Defended Level")
                else
                    res_out := "Buyers Rejected by Sellers"
            else
                if buy_dom
                    res_out := vr >= exhaustion_vol_pct ? "Sellers Exhausted, Buyers Breakout" : "Buyers Overwhelmed Sellers"
                else if vr <= capitulation_vol_pct
                    res_out := "Bull Trap, Weak Breakout (Low Vol)"
                else
                    res_out := "Buyers Breakout"
        else
            float uw   = h_price - math.max(o_price, c_price)
            float bpct = math.abs(c_price - o_price) / rng
            float wpct = uw / rng
            if cb
                if vr >= exhaustion_vol_pct
                    res_out := "Buyers Exhausted, Sellers Dominate"
                else if vr >= absorption_vol_pct
                    res_out := wpct > 0.4 ? "Sellers Absorbed Buyers" : "Sellers Defended Level"
                else if vr <= capitulation_vol_pct
                    res_out := "Stop Hunt"
                else
                    res_out := "Sellers Defended Level"
            else
                if vr >= absorption_vol_pct and bpct > 0.6
                    res_out := "Buyers Breakout"
                else if vr <= capitulation_vol_pct
                    res_out := "Bull Trap, Weak Breakout (Low Vol)"
                else
                    res_out := "Buyers Control"
    bool is_brk = str.contains(res_out, "Breakout") or str.contains(res_out, "Overwhelmed") or str.contains(res_out, "Absorbed") or str.contains(res_out, "Control")
    [res_out, is_brk]

f_classify_low(float sweep_price, float c_price, float h_price, float l_price, float o_price,
     float dlt, float buy_v, float sell_v, float tot_v, float v_ma) =>
    string res_out = "—"
    if l_price <= sweep_price
        float vr  = v_ma > 0 ? tot_v / v_ma : 1.0
        float rng = math.max(h_price - l_price, syminfo.mintick)
        bool  ca  = c_price > sweep_price
        if use_fp and not na(dlt) and not na(buy_v) and not na(sell_v) and tot_v > 0
            float buy_pct  = buy_v  / tot_v
            float sell_pct = sell_v / tot_v
            bool  buy_dom  = buy_pct  >= delta_thresh
            bool  sell_dom = sell_pct >= delta_thresh
            if ca
                if buy_dom
                    res_out := vr >= exhaustion_vol_pct ? "Sellers Exhausted, Buyers Dominate" : (vr >= absorption_vol_pct ? "Buyers Absorbed Sellers" : "Buyers Defended Level")
                else
                    res_out := "Sellers Rejected by Buyers"
            else
                if sell_dom
                    res_out := vr >= exhaustion_vol_pct ? "Buyers Exhausted, Sellers Breakout" : "Sellers Overwhelmed Buyers"
                else if vr <= capitulation_vol_pct
                    res_out := "Bear Trap, Weak Breakout (Low Vol)"
                else
                    res_out := "Sellers Breakout"
        else
            float lw   = math.min(o_price, c_price) - l_price
            float bpct = math.abs(c_price - o_price) / rng
            float wpct = lw / rng
            if ca
                if vr >= exhaustion_vol_pct
                    res_out := "Sellers Exhausted, Buyers Dominate"
                else if vr >= absorption_vol_pct
                    res_out := wpct > 0.4 ? "Buyers Absorbed Sellers" : "Buyers Defended Level"
                else if vr <= capitulation_vol_pct
                    res_out := "Stop Hunt"
                else
                    res_out := "Buyers Defended Level"
            else
                if vr >= absorption_vol_pct and bpct > 0.6
                    res_out := "Sellers Breakout"
                else if vr <= capitulation_vol_pct
                    res_out := "Bear Trap, Weak Breakout (Low Vol)"
                else
                    res_out := "Sellers Control"
    bool is_brk = str.contains(res_out, "Breakout") or str.contains(res_out, "Overwhelmed") or str.contains(res_out, "Absorbed") or str.contains(res_out, "Control")
    [res_out, is_brk]

f_wickless_high(float o, float h, float c) => math.max(o, c) >= h
f_wickless_low(float o,  float l, float c) => math.min(o, c) <= l
f_is_wickless(float o, float h, float l, float c) => math.max(o, c) >= h or math.min(o, c) <= l

f_get_outcome_color(string outcome, bool is_high) =>
    color out_col = color.gray
    if outcome != "—"
        if is_high
            bool is_bull = str.contains(outcome, "Buyers Breakout") or str.contains(outcome, "Buyers Overwhelmed") or str.contains(outcome, "Buyers Control")
            out_col := is_bull ? color.lime : color.red
        else
            bool is_bear = str.contains(outcome, "Sellers Breakout") or str.contains(outcome, "Sellers Overwhelmed") or str.contains(outcome, "Sellers Control")
            out_col := is_bear ? color.red : color.lime
    out_col

// ─── RENDER HELPERS ────────────────────────────────────────────────────────
f_clear_groups() =>
    array.clear(render_groups)

f_add_item(float p_price, string p_txt, color p_col, int p_width, string p_style,
           int p_prio, bool p_arr, bool p_bull, bool p_wkless, int p_bt, int p_et) =>
    bool found = false
    if array.size(render_groups) > 0
        for i = 0 to array.size(render_groups) - 1
            RenderGroup grp = array.get(render_groups, i)
            if math.abs(grp.price - p_price) <= syminfo.mintick / 2
                found := true
                array.push(grp.lbl_texts, p_txt)
                grp.b_time := math.min(grp.b_time, p_bt)
                grp.e_time := math.max(grp.e_time, p_et)
                if p_prio > grp.priority
                    grp.ln_col      := p_col
                    grp.ln_width    := p_width
                    grp.ln_style    := p_style
                    grp.priority    := p_prio
                    grp.has_arr     := p_arr
                    grp.is_bull     := p_bull
                    grp.is_wickless := p_wkless
                else if p_prio == grp.priority
                    grp.has_arr     := grp.has_arr or p_arr
                    grp.is_wickless := grp.is_wickless or p_wkless
                break
    if not found
        array<string> t_arr = array.new<string>()
        array.push(t_arr, p_txt)
        array.push(render_groups, RenderGroup.new(p_price, t_arr, p_col, p_width, p_style, p_arr, p_bull, p_wkless, p_bt, p_et, p_prio))

f_draw_groups() =>
    for d_ln in d_lines
        line.delete(d_ln)
    for d_lb in d_labels
        label.delete(d_lb)
    for d_ar in d_arrows
        label.delete(d_ar)
    array.clear(d_lines)
    array.clear(d_labels)
    array.clear(d_arrows)
    if array.size(render_groups) > 0
        for i = 0 to array.size(render_groups) - 1
            RenderGroup grp = array.get(render_groups, i)
            string combined = ""
            int tsz = array.size(grp.lbl_texts)
            for j = 0 to tsz - 1
                combined += array.get(grp.lbl_texts, j)
                if j < tsz - 1
                    combined += " + "
            array.push(d_lines, line.new(grp.b_time, grp.price, grp.e_time, grp.price,
                 color=grp.ln_col, width=grp.ln_width, style=grp.ln_style, xloc=xloc.bar_time))
            if grp.has_arr and show_arrow
                string arr_chr = grp.is_bull ? "⬆" : "⬇"
                color  arr_col = grp.is_bull ? col_arrow_bull : col_arrow_bear
                array.push(d_arrows, label.new(grp.e_time, grp.price, arr_chr,
                     style=label.style_label_left, textcolor=arr_col,
                     size=f_get_size("small"), color=#ffffff00, xloc=xloc.bar_time))
            if show_text
                int txt_x = (grp.has_arr and show_arrow) ? grp.e_time + chart_ms : grp.e_time
                array.push(d_labels, label.new(txt_x, grp.price, combined,
                     style=label.style_label_left, textcolor=grp.ln_col,
                     size=f_get_size("small"), color=#ffffff00, xloc=xloc.bar_time))

f_render_sweep(ActiveLevelSweep s) =>
    if not na(s)
        bool   use_brk = s.is_brk
        bool   show_it = use_brk ? show_brk : show_tch
        if show_it
            int    w  = use_brk ? brk_width : tch_width
            string st = use_brk ? f_get_style(brk_style_str) : f_get_style(tch_style_str)
            int    ex = time + (use_brk ? ext_brk_ms : ext_tch_ms)
            bool   ab = stat_close > s.price
            color  dc = ab ? col_lo_buy : col_lo_sell
            f_add_item(s.price, s.lbl_text, dc, w, st, 3, true, ab, s.is_wickless, s.b_time, ex)

// ─── CONTEXT TABLE ─────────────────────────────────────────────────────────
f_build_table() =>
    ctx_tbl = table.new(f_tbl_pos(table_pos), 3, 6,
         bgcolor=color.new(#0d0d0d, 10),
         frame_color=color.rgb(60,60,60), frame_width=1,
         border_color=color.rgb(40,40,40), border_width=1)
    tsz        = f_tbl_size(table_size)
    color wht  = col_tbl_txt
    color dark = color.rgb(18,18,18)
    color mid  = color.rgb(28,28,28)

    color vol_col = bar_total_vol > 0 ? (bar_C >= bar_O ? color.lime : color.red) : color.gray
    color del_col = color.gray
    if not na(bar_delta)
        del_col := bar_delta > 0 ? color.lime : (bar_delta < 0 ? color.red : color.gray)

    int row = 0

    float  vr      = vol_ma > 0 ? bar_total_vol / vol_ma : na
    string vol_txt = na(vr) ? "—" : str.tostring(vr, "#.##") + "x avg"
    string dlt_txt = "—"
    if not na(bar_delta)
        dlt_txt := (bar_delta > 0 ? "+" : "") + str.tostring(bar_delta, "#,###") + (bar_delta > 0 ? " (Buy)" : " (Sell)")

    table.cell(ctx_tbl, 0, row, "Volume | Delta", text_color=wht,     text_size=tsz, bgcolor=mid)
    table.cell(ctx_tbl, 1, row, vol_txt,          text_color=vol_col, text_size=tsz, bgcolor=mid)
    table.cell(ctx_tbl, 2, row, dlt_txt,          text_color=del_col, text_size=tsz, bgcolor=mid)
    row += 1

    string vol_ctx = "NORMAL"
    if not na(vr)
        if vr >= exhaustion_vol_pct
            vol_ctx := "EXTREME — Exhaustion zone"
        else if vr >= absorption_vol_pct
            bool is_buy_abs = not na(bar_delta) ? bar_delta > 0 : (bar_C >= bar_O)
            vol_ctx := is_buy_abs ? "HIGH — Buyers Absorbing" : "HIGH — Sellers Absorbing"
        else if vr <= capitulation_vol_pct
            vol_ctx := "LOW — Stop hunt zone"

    table.cell(ctx_tbl, 0, row, "Vol Context", text_color=wht, text_size=tsz, bgcolor=dark)
    table.cell(ctx_tbl, 1, row, vol_ctx,       text_color=wht, text_size=tsz, bgcolor=dark)
    table.merge_cells(ctx_tbl, 1, row, 2, row)
    row += 1

    float  pc_tot = pc_buy_vol + pc_sell_vol
    float  cc_tot = cc_buy_vol + cc_sell_vol
    string pb_t   = pc_tot > 0 ? str.tostring(pc_buy_vol  / pc_tot * 100, "#.#") + "% buy"  : "—"
    string ps_t   = pc_tot > 0 ? str.tostring(pc_sell_vol / pc_tot * 100, "#.#") + "% sell" : "—"
    string cb_t   = cc_tot > 0 ? str.tostring(cc_buy_vol  / cc_tot * 100, "#.#") + "% buy"  : "—"
    string cs_t   = cc_tot > 0 ? str.tostring(cc_sell_vol / cc_tot * 100, "#.#") + "% sell" : "—"

    table.cell(ctx_tbl, 0, row, "CC Bid/Ask", text_color=wht,        text_size=tsz, bgcolor=mid)
    table.cell(ctx_tbl, 1, row, cb_t,         text_color=color.lime, text_size=tsz, bgcolor=mid)
    table.cell(ctx_tbl, 2, row, cs_t,         text_color=color.red,  text_size=tsz, bgcolor=mid)
    row += 1

    table.cell(ctx_tbl, 0, row, "PC Bid/Ask", text_color=wht,        text_size=tsz, bgcolor=dark)
    table.cell(ctx_tbl, 1, row, pb_t,         text_color=color.lime, text_size=tsz, bgcolor=dark)
    table.cell(ctx_tbl, 2, row, ps_t,         text_color=color.red,  text_size=tsz, bgcolor=dark)
    row += 1

    bool  hi_recent = last_high_hit_time > last_low_hit_time  and last_high_hit_time != 0
    bool  lo_recent = last_low_hit_time  > last_high_hit_time and last_low_hit_time  != 0
    color bg_hi     = hi_recent ? color.new(color.green, 70) : mid
    color bg_lo     = lo_recent ? color.new(color.red,   70) : dark
    color h_col     = f_get_outcome_color(last_high_outcome, true)
    color l_col     = f_get_outcome_color(last_low_outcome,  false)
    string h_arr    = h_col == color.lime ? "⬆ " : (h_col == color.red ? "⬇ " : "")
    string l_arr    = l_col == color.lime ? "⬆ " : (l_col == color.red ? "⬇ " : "")

    table.cell(ctx_tbl, 0, row, "Last High Hit",           text_color=wht,   text_size=tsz, bgcolor=bg_hi)
    table.cell(ctx_tbl, 1, row, h_arr + last_high_outcome, text_color=h_col, text_size=tsz, bgcolor=bg_hi)
    table.merge_cells(ctx_tbl, 1, row, 2, row)
    row += 1

    table.cell(ctx_tbl, 0, row, "Last Low Hit",            text_color=wht,   text_size=tsz, bgcolor=bg_lo)
    table.cell(ctx_tbl, 1, row, l_arr + last_low_outcome,  text_color=l_col, text_size=tsz, bgcolor=bg_lo)
    table.merge_cells(ctx_tbl, 1, row, 2, row)

    ctx_tbl

// ─── CANDLE COLORING ───────────────────────────────────────────────────────
is_live_bar    = barstate.isrealtime and not barstate.isconfirmed
color bias_col = bar_C > bar_O ? col_bias_bull : (bar_C < bar_O ? col_bias_bear : col_bias_neut)
barcolor(show_bias_color and not is_live_bar ? bias_col : na)

// ─── CORE LOGIC ────────────────────────────────────────────────────────────
if run_logic
    array<PriceLevel> touched_highs = array.new<PriceLevel>()
    if array.size(active_highs) > 0
        for i = array.size(active_highs) - 1 to 0
            PriceLevel lvl = array.get(active_highs, i)
            if bar_H >= lvl.price
                array.push(touched_highs, lvl)
                array.remove(active_highs, i)
    int num_h = array.size(touched_highs)
    if num_h > 0
        last_high_hit_time := bar_T
        PriceLevel fh = array.get(touched_highs, 0)
        bool fh_wk = f_wickless_high(fh.op, fh.hi, fh.cl)
        [fh_out, fh_brk] = f_classify_high(fh.price, bar_C, bar_H, bar_L, bar_O, bar_delta, cc_buy_vol, cc_sell_vol, bar_total_vol, vol_ma)
        last_high_outcome := fh_out
        swp_fh := ActiveLevelSweep.new(fh.price, fh.b_time, f_sell_lbl(fh_out, fh_wk, fh_brk), fh_brk, fh_wk)
        if num_h > 1
            PriceLevel lh = array.get(touched_highs, num_h - 1)
            bool lh_wk = f_wickless_high(lh.op, lh.hi, lh.cl)
            [lh_out, lh_brk] = f_classify_high(lh.price, bar_C, bar_H, bar_L, bar_O, bar_delta, cc_buy_vol, cc_sell_vol, bar_total_vol, vol_ma)
            swp_lh := ActiveLevelSweep.new(lh.price, lh.b_time, f_sell_lbl(lh_out, lh_wk, lh_brk), lh_brk, lh_wk)
        else
            swp_lh := na

    array<PriceLevel> touched_lows = array.new<PriceLevel>()
    if array.size(active_lows) > 0
        for i = array.size(active_lows) - 1 to 0
            PriceLevel lvl = array.get(active_lows, i)
            if bar_L <= lvl.price
                array.push(touched_lows, lvl)
                array.remove(active_lows, i)
    int num_l = array.size(touched_lows)
    if num_l > 0
        last_low_hit_time := bar_T
        PriceLevel fl = array.get(touched_lows, 0)
        bool fl_wk = f_wickless_low(fl.op, fl.lo, fl.cl)
        [fl_out, fl_brk] = f_classify_low(fl.price, bar_C, bar_H, bar_L, bar_O, bar_delta, cc_buy_vol, cc_sell_vol, bar_total_vol, vol_ma)
        last_low_outcome := fl_out
        swp_fl := ActiveLevelSweep.new(fl.price, fl.b_time, f_buy_lbl(fl_out, fl_wk, fl_brk), fl_brk, fl_wk)
        if num_l > 1
            PriceLevel ll = array.get(touched_lows, num_l - 1)
            bool ll_wk = f_wickless_low(ll.op, ll.lo, ll.cl)
            [ll_out, ll_brk] = f_classify_low(ll.price, bar_C, bar_H, bar_L, bar_O, bar_delta, cc_buy_vol, cc_sell_vol, bar_total_vol, vol_ma)
            swp_ll := ActiveLevelSweep.new(ll.price, ll.b_time, f_buy_lbl(ll_out, ll_wk, ll_brk), ll_brk, ll_wk)
        else
            swp_ll := na

    array.push(active_highs, PriceLevel.new(bar_H, bar_T, bar_O, bar_H, bar_L, bar_C))
    array.push(active_lows,  PriceLevel.new(bar_L, bar_T, bar_O, bar_H, bar_L, bar_C))
    if array.size(active_highs) > lookback
        array.shift(active_highs)
    if array.size(active_lows) > lookback
        array.shift(active_lows)

// ─── RENDER ────────────────────────────────────────────────────────────────
if run_logic or barstate.isrealtime
    f_clear_groups()

    // Last — most recent closed candle high and low
    // Label: "Sell Limit Orders ●" when untouched, "Sell Limit Orders ✕" when price has crossed it
    if show_last
        float last_H  = is_same_tf ? high[1]  : h_high[2]
        float last_L  = is_same_tf ? low[1]   : h_low[2]
        int   last_T  = is_same_tf ? time[1]  : h_t[2]
        int   last_ex = time + ext_last_ms
        bool  H_hit   = high >= last_H or stat_close >= last_H
        bool  L_hit   = low  <= last_L or stat_close <= last_L
        string sell_lbl = f_build_lbl(f_get_sell_name(), false, H_hit ? "✕" : "●")
        string buy_lbl  = f_build_lbl(f_get_buy_name(),  false, L_hit ? "✕" : "●")
        f_add_item(last_H, sell_lbl, col_lo_sell, last_width, f_get_style(last_style_str), 4, false, false, false, last_T, last_ex)
        f_add_item(last_L, buy_lbl,  col_lo_buy,  last_width, f_get_style(last_style_str), 4, false, true,  false, last_T, last_ex)

    // Untouched — historical highs/lows not yet revisited
    // Skip levels that share the same price as Last to prevent label merging
    float last_H_price = is_same_tf ? high[1] : h_high[2]
    float last_L_price = is_same_tf ? low[1]  : h_low[2]

    int h_sz = array.size(active_highs)
    if show_unt and h_sz > 0
        int cnt = math.min(max_unt_sell, h_sz)
        for i = 0 to cnt - 1
            PriceLevel lvl = array.get(active_highs, h_sz - 1 - i)
            if show_last and math.abs(lvl.price - last_H_price) <= syminfo.mintick
                continue
            bool wk = f_wickless_high(lvl.op, lvl.hi, lvl.cl)
            f_add_item(lvl.price, f_build_lbl(f_get_sell_name(), wk, "●"),
                 col_lo_sell, unt_width, f_get_style(unt_style_str), 1, false, false, wk, lvl.b_time, time + ext_unt_ms)

    int l_sz = array.size(active_lows)
    if show_unt and l_sz > 0
        int cnt = math.min(max_unt_buy, l_sz)
        for i = 0 to cnt - 1
            PriceLevel lvl = array.get(active_lows, l_sz - 1 - i)
            if show_last and math.abs(lvl.price - last_L_price) <= syminfo.mintick
                continue
            bool wk = f_wickless_low(lvl.op, lvl.lo, lvl.cl)
            f_add_item(lvl.price, f_build_lbl(f_get_buy_name(), wk, "●"),
                 col_lo_buy, unt_width, f_get_style(unt_style_str), 1, false, true, wk, lvl.b_time, time + ext_unt_ms)

    // Touched / Absorbed — levels price has visited, with outcome label
    f_render_sweep(swp_fh)
    f_render_sweep(swp_lh)
    f_render_sweep(swp_fl)
    f_render_sweep(swp_ll)

    f_draw_groups()

if show_table and barstate.islast
    table.delete(ctx_table)
    ctx_table := f_build_table()
````
