# 4H Encompassing Candle Highlighter

- url: https://www.tradingview.com/script/phnJEUJZ-4H-Encompassing-Candle-Highlighter/
- type: indicator
- pine_id: PUB;3dcc1d82898545e1b992b21ca098f66c
- version: 5.0

## Description

Highlights 4h candles that encompass the previous 4h candle to quickly scan for manipulation.

## Source Code

````pine
//@version=6
indicator("Engulfing candle highlighter", overlay=true)

// --- Inputs ---
tf_input       = input.timeframe("240", "Target Timeframe", confirm=false)
wick_filter    = input.string("Off", "Wick Filter Preference", options=["Off", "Bullish Wick (Long Lower)", "Bearish Wick (Long Upper)"])
session_filter = input.string("All Day", "Trading Session Filter", options=["All Day", "London Open Only", "New York Open Only", "London & NY Opens"])
session_tz     = input.string("UTC", "Session Timezone", options=["UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Exchange"])
use_trend_fltr = input.bool(false, "Enable HTF Trend Filter (200 EMA)", inline="trend")
trend_ema_len  = input.int(200, "EMA Length", inline="trend")

// Timezone Resolution
active_tz = session_tz == "Exchange" ? syminfo.timezone : session_tz

// Session Time Definitions
// Adjust these time ranges if using local times instead of UTC
london_session = "0700-1100:1234567"
ny_session     = "1300-1700:1234567"

// Check session window active state using chosen timezone
in_london = not na(time(timeframe.period, london_session, active_tz))
in_ny     = not na(time(timeframe.period, ny_session, active_tz))
in_both   = in_london or in_ny

bool session_allowed = switch session_filter
    "London Open Only"   => in_london
    "New York Open Only" => in_ny
    "London & NY Opens"  => in_both
    => true

// --- Data Fetching ---
[tf_high, tf_low, tf_open, tf_close, prev_tf_high, prev_tf_low, htf_ema] = request.security(
     syminfo.tickerid, tf_input, 
     [high, low, open, close, high[1], low[1], ta.ema(close, trend_ema_len)], 
     barmerge.gaps_on, barmerge.lookahead_off
 )

// --- Calculations ---
is_encompassing = (tf_high > prev_tf_high) and (tf_low < prev_tf_low)

tf_max_body = math.max(tf_open, tf_close)
tf_min_body = math.min(tf_open, tf_close)
upper_wick  = tf_high - tf_max_body
lower_wick  = tf_min_body - tf_low

// Establish pure strict state flags
is_bullish = is_encompassing and (lower_wick > upper_wick) and (tf_close > prev_tf_high)
is_bearish = is_encompassing and (upper_wick > lower_wick) and (tf_close < prev_tf_low)

std_bullish = is_encompassing and (tf_close > prev_tf_high)
std_bearish = is_encompassing and (tf_close < prev_tf_low)

// --- HTF Trend Logic ---
bool trend_bullish_allowed = not use_trend_fltr or (tf_close > htf_ema)
bool trend_bearish_allowed = not use_trend_fltr or (tf_close < htf_ema)

// --- Routing & Isolation Matrix ---
bool trigger_bullish = false
bool trigger_bearish = false

if wick_filter == "Off"
    trigger_bullish := std_bullish
    trigger_bearish := std_bearish
if wick_filter == "Bullish Wick (Long Lower)"
    trigger_bullish := is_bullish
if wick_filter == "Bearish Wick (Long Upper)"
    trigger_bearish := is_bearish

// Apply Session and Trend Filters
trigger_bullish := trigger_bullish and session_allowed and trend_bullish_allowed
trigger_bearish := trigger_bearish and session_allowed and trend_bearish_allowed

// --- Visual Color Assignment ---
color display_color = na

if trigger_bullish
    display_color := color.blue
if trigger_bearish
    display_color := color.red

// --- Render Elements ---
bgcolor(not na(display_color) ? color.new(display_color, 85) : na, title="Engulfing Candle Highlight")
plotshape(not na(display_color), title="Engulfing Signal", style=shape.triangleup, location=location.bottom, color=display_color, size=size.small)
````
