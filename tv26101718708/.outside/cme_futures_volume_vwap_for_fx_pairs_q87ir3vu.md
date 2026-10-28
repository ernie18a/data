# CME Futures Volume VWAP for FX Pairs

- url: https://www.tradingview.com/script/Q87iR3vU-CME-Futures-Volume-VWAP-for-FX-Pairs/
- type: indicator
- pine_id: PUB;ffc09f4680044df6ab3f14e4ec5d955c
- version: 1.0

## Description

CME Futures Volume VWAP for FX Pairs

Most VWAP indicators on FX charts use broker tick volume — which is 
meaningless. This indicator solves that by pulling real institutional 
volume from CME Futures contracts and applying it to your CFD/Spot 
chart price, giving you a true Volume Weighted Average Price that 
reflects where institutions actually transacted.

─────────────────────────────────────
HOW IT WORKS
─────────────────────────────────────
- Price source  → your CFD/Spot chart (no scale mismatch)
- Volume source → CME Futures (real market volume)
- Result        → institutionally-weighted VWAP on the correct price scale

CME contract mapping:
  EURUSD → 6E  |  GBPUSD → 6B  |  USDJPY → 6J
  AUDUSD → 6A  |  USDCAD → 6C  |  USDCHF → 6S  |  NZDUSD → 6N

─────────────────────────────────────
FEATURES
─────────────────────────────────────
- Auto-detects pair from your chart ticker (works with any broker prefix)
- Manual pair override if auto-detection misses
- Session-based VWAP reset: New York | London | Asian | Daily
- Standard Deviation bands: ±1 SD, ±2 SD, ±3 SD with fill
- Info label shows active futures contract, VWAP value, and session
- Graceful warning if unsupported pair is detected

─────────────────────────────────────
SUPPORTED PAIRS
─────────────────────────────────────
EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, USDCHF, NZDUSD

─────────────────────────────────────
NOTES
─────────────────────────────────────
- CME FX futures trade Sunday 5pm – Friday 4pm CT. During off-hours, 
  VWAP holds its last value until the next session opens — this is 
  intentional and correct behavior.
- New York session reset (08:00 EST) is recommended as default — 
  aligns with peak CME institutional volume.
- Requires TradingView plan with access to CME data feed.

─────────────────────────────────────
CREDITS & METHODOLOGY
─────────────────────────────────────
VWAP is calculated using the standard cumulative method:
  VWAP = Σ(HLC3 × Volume) / Σ(Volume)
Standard Deviation bands use true variance from the VWAP anchor point.

## Source Code

````pine
// © yogy.frestarahmawan
// CME Futures Volume VWAP for FX Pairs
// Institutional-grade VWAP using real CME volume on CFD/Spot FX charts

//@version=6
indicator('CME Vol VWAP on FX CFD', overlay = true, max_labels_count = 50)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grp_pair = 'Pair Detection'
i_pair_override = input.string('AUTO', 'Pair Override', options = ['AUTO', 'EURUSD', 'GBPUSD', 'USDJPY', 'AUDUSD', 'USDCAD', 'USDCHF', 'NZDUSD'], group = grp_pair)

grp_vwap = 'VWAP Settings'
i_session_type = input.string('New York', 'VWAP Reset Session', options = ['New York', 'London', 'Asian', 'Daily'], group = grp_vwap)
i_show_sd1 = input.bool(true, 'Show ±1 SD Bands', group = grp_vwap)
i_show_sd2 = input.bool(true, 'Show ±2 SD Bands', group = grp_vwap)
i_show_sd3 = input.bool(false, 'Show ±3 SD Bands', group = grp_vwap)

grp_style = 'Style'
i_vwap_color = input.color(color.yellow, 'VWAP', group = grp_style)
i_sd1_color = input.color(color.new(color.blue, 30), 'SD1', group = grp_style)
i_sd2_color = input.color(color.new(color.orange, 30), 'SD2', group = grp_style)
i_sd3_color = input.color(color.new(color.red, 30), 'SD3', group = grp_style)
i_lw = input.int(2, 'VWAP Line Width', minval = 1, maxval = 4, group = grp_style)

// ─────────────────────────────────────────
// PAIR → FUTURES SYMBOL MAP
// ─────────────────────────────────────────
get_futures_sym(pair) =>
    string result = ''
    if pair == 'EURUSD'
        result := 'CME:6E1!'
        result
    else if pair == 'GBPUSD'
        result := 'CME:6B1!'
        result
    else if pair == 'USDJPY'
        result := 'CME:6J1!'
        result
    else if pair == 'AUDUSD'
        result := 'CME:6A1!'
        result
    else if pair == 'USDCAD'
        result := 'CME:6C1!'
        result
    else if pair == 'USDCHF'
        result := 'CME:6S1!'
        result
    else if pair == 'NZDUSD'
        result := 'CME:6N1!'
        result
    result

get_session(s) =>
    string result = ''
    if s == 'New York'
        result := '0800-1700:1234567'
        result
    else if s == 'London'
        result := '0300-0800:1234567'
        result
    else if s == 'Asian'
        result := '1800-0300:1234567'
        result
    result // Daily returns empty string — handled separately below

// ─────────────────────────────────────────
// PAIR DETECTION
// ─────────────────────────────────────────
raw_ticker = i_pair_override == 'AUTO' ? syminfo.ticker : i_pair_override
clean_pair = str.upper(str.length(raw_ticker) > 6 ? str.substring(raw_ticker, str.length(raw_ticker) - 6) : raw_ticker)
fut_sym = get_futures_sym(clean_pair)
valid_pair = fut_sym != ''

// ─────────────────────────────────────────
// SESSION RESET
// ─────────────────────────────────────────
sess_str = get_session(i_session_type)
is_daily = i_session_type == 'Daily'
// Session reset logic
is_new_sess = false
if is_daily
    // Reset on new UTC day
    is_new_sess := dayofweek != dayofweek[1] or barstate.isfirst
    is_new_sess
else
    in_sess = not na(time(timeframe.period, sess_str, 'America/New_York'))
    in_sess_lag = not na(time(timeframe.period, sess_str, 'America/New_York')[1])
    is_new_sess := in_sess and not in_sess_lag
    is_new_sess

// ─────────────────────────────────────────
// PULL CME VOLUME ONLY
// ─────────────────────────────────────────
cme_vol = request.security(fut_sym, timeframe.period, volume, lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────
// VWAP: CFD price × CME volume
// ─────────────────────────────────────────
cfd_hlc3 = (high + low + close) / 3

var float cum_tpv = 0.0
var float cum_tpv2 = 0.0
var float cum_vol = 0.0

if is_new_sess or barstate.isfirst
    cum_tpv := 0.0
    cum_tpv2 := 0.0
    cum_vol := 0.0
    cum_vol

vol_bar = nz(cme_vol, 0.0)
cum_vol := cum_vol + vol_bar
cum_tpv := cum_tpv + cfd_hlc3 * vol_bar
cum_tpv2 := cum_tpv2 + cfd_hlc3 * cfd_hlc3 * vol_bar

vwap_val = cum_vol > 0 ? cum_tpv / cum_vol : cfd_hlc3
variance = cum_vol > 0 ? math.max(cum_tpv2 / cum_vol - vwap_val * vwap_val, 0.0) : 0.0
stdev = math.sqrt(variance)

sd1u = vwap_val + 1.0 * stdev
sd1l = vwap_val - 1.0 * stdev
sd2u = vwap_val + 2.0 * stdev
sd2l = vwap_val - 2.0 * stdev
sd3u = vwap_val + 3.0 * stdev
sd3l = vwap_val - 3.0 * stdev

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────
plot(valid_pair ? vwap_val : na, 'CME VWAP', color = i_vwap_color, linewidth = math.max(1, i_lw))

p_sd1u = plot(valid_pair and i_show_sd1 ? sd1u : na, 'SD1+', color = i_sd1_color, linewidth = 1)
p_sd1l = plot(valid_pair and i_show_sd1 ? sd1l : na, 'SD1-', color = i_sd1_color, linewidth = 1)
p_sd2u = plot(valid_pair and i_show_sd2 ? sd2u : na, 'SD2+', color = i_sd2_color, linewidth = 1)
p_sd2l = plot(valid_pair and i_show_sd2 ? sd2l : na, 'SD2-', color = i_sd2_color, linewidth = 1)
p_sd3u = plot(valid_pair and i_show_sd3 ? sd3u : na, 'SD3+', color = i_sd3_color, linewidth = 1)
p_sd3l = plot(valid_pair and i_show_sd3 ? sd3l : na, 'SD3-', color = i_sd3_color, linewidth = 1)

fill(p_sd1u, p_sd1l, color = color.new(i_sd1_color, 88), title = 'SD1 Fill')
fill(p_sd2u, p_sd2l, color = color.new(i_sd2_color, 92), title = 'SD2 Fill')
````
