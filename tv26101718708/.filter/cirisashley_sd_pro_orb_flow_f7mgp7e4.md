# CirisAshley S&D Pro | ORB + Flow

- url: https://www.tradingview.com/script/f7mGP7e4-CirisAshley-S-D-Pro-ORB-Flow/
- type: indicator
- pine_id: PUB;f18be02972814c01bad072eddf9ea294
- version: 18.0

## Description

Green boxes on the chart are support zones — areas where price has bounced up before. Red boxes are resistance zones — areas where price has been rejected before.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CirisAshley
//@version=6
indicator("OG Master Indy", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ══════════════════════════════════════════════
//   INPUTS
// ══════════════════════════════════════════════

// --- Support/Resistance Zones ---
show_sr           = input.bool(true,  "Show S/R Zones",              group="① Support & Resistance")
sr_lookback       = input.int(10,     "S/R Bar Lookback",            group="① Support & Resistance")
sr_extend_bars    = input.int(20,     "S/R Zone Extend (bars)",      group="① Support & Resistance")
sr_box_opacity    = input.int(85,     "Zone Opacity",                group="① Support & Resistance", minval=0, maxval=100)
c_support         = input.color(#00E676, "Support Zone Color",       group="① Support & Resistance")
c_resist          = input.color(#FF1744, "Resistance Zone Color",    group="① Support & Resistance")

// --- EMAs ---
show_emas         = input.bool(true,  "Show EMA Lines",              group="② EMA Settings")
ema_fast          = input.int(9,      "Fast EMA",                    group="② EMA Settings")
ema_slow          = input.int(21,     "Slow EMA",                    group="② EMA Settings")
c_ema_bull        = input.color(#00E676, "EMA Bull Color",           group="② EMA Settings")
c_ema_bear        = input.color(#FF1744, "EMA Bear Color",           group="② EMA Settings")

// --- A+ Signal Arrows ---
show_arrows       = input.bool(true,  "Show A+ Signal Arrows",       group="③ A+ Signal")
atr_mult          = input.float(0.5,  "ATR Filter Multiplier",       group="③ A+ Signal")
c_aplus           = input.color(#FFD600, "A+ Signal Color",          group="③ A+ Signal")

// --- GO Execution Arrows ---
show_go           = input.bool(true,  "Show GO Execution Arrows",    group="③ GO Execution")
go_atr_mult       = input.float(1.2,  "Min ATR Momentum Factor",     group="③ GO Execution")
go_body_pct       = input.float(0.6,  "Min Candle Body %",           group="③ GO Execution")
go_session_filter = input.bool(true,  "Session Filter (NY/London/Asia)", group="③ GO Execution")
c_go_buy          = input.color(#00E676, "GO Buy Color",             group="③ GO Execution")
c_go_sell         = input.color(#FF1744, "GO Sell Color",            group="③ GO Execution")

// --- Daily Bias ---
show_daily_bias   = input.bool(true,  "Show Daily Bias Label",       group="④ Daily Bias")
daily_ema_len     = input.int(50,     "Daily Bias EMA (D TF)",       group="④ Daily Bias")

// --- VWAP / Volume ---
show_vwap         = input.bool(true,  "Show VWAP Line",              group="⑤ VWAP & Volume")
show_vol_label    = input.bool(true,  "Show Volume Label",           group="⑤ VWAP & Volume")
vol_ma_len        = input.int(20,     "Volume MA Length",            group="⑤ VWAP & Volume")
c_vwap            = input.color(#FFD600, "VWAP Line Color",          group="⑤ VWAP & Volume")

// --- Zone Retest ---
show_zone_retest  = input.bool(true,  "Show Zone Retest Labels",     group="⑥ Zone Retest")

// --- EMA Retest ---
show_ema_retest   = input.bool(true,  "Show EMA Retest Labels",      group="⑦ EMA Retest")

// --- Order Blocks ---
show_ob           = input.bool(true,  "Show Order Blocks",           group="⑧ Order Blocks")
ob_lookback       = input.int(10,     "Order Block Lookback",        group="⑧ Order Blocks")
ob_opacity        = input.int(75,     "Order Block Opacity",         group="⑧ Order Blocks", minval=0, maxval=100)
c_ob              = input.color(#AA00FF, "Order Block Color",        group="⑧ Order Blocks")

// --- Fair Value Gaps ---
show_fvg          = input.bool(true,  "Show FVG Box + Label",        group="⑨ Fair Value Gaps")
fvg_opacity       = input.int(80,     "FVG Box Opacity",             group="⑨ Fair Value Gaps")
c_fvg_bull        = input.color(#00B8D4, "FVG Up Color",             group="⑨ Fair Value Gaps")
c_fvg_bear        = input.color(#FF6D00, "FVG Down Color",           group="⑨ Fair Value Gaps")

// --- Market Condition ---
show_mkt_condition = input.bool(true, "Show Market Condition",       group="⑩ Market Condition")

// --- NY ORB System ---
show_orb15        = input.bool(true,  "── 15 Min ORB System",        group="⑪ NY ORB System")
orb15_box_opacity = input.int(85,     "15M ORB Box Opacity",         group="⑪ NY ORB System", minval=0, maxval=100)
orb15_extend      = input.int(150,    "15M ORB Line Extend (bars)",  group="⑪ NY ORB System")
c_orb15           = input.color(#FF8C00, "15M ORB Color",            group="⑪ NY ORB System")
show_orb30        = input.bool(true,  "── 30 Min ORB System",        group="⑪ NY ORB System")
orb30_box_opacity = input.int(85,     "30M ORB Box Opacity",         group="⑪ NY ORB System", minval=0, maxval=100)
orb30_extend      = input.int(150,    "30M ORB Line Extend (bars)",  group="⑪ NY ORB System")
c_orb30           = input.color(#FF69B4, "30M ORB Color",            group="⑪ NY ORB System")

// --- London ORB System ---
show_lon15        = input.bool(true,  "Show 15 Min ORB (London)",    group="⑫ London ORB System")
show_lon30        = input.bool(true,  "Show 30 Min ORB (London)",    group="⑫ London ORB System")
lon_box_opacity   = input.int(80,     "London ORB Box Opacity",      group="⑫ London ORB System")
lon_extend        = input.int(100,    "London ORB Line Extend",      group="⑫ London ORB System")
c_orb_lon         = input.color(#00BCD4, "London ORB Color",         group="⑫ London ORB System")

// --- Asia ORB System ---
show_asia15       = input.bool(true,  "Show 15 Min ORB (Asia)",      group="⑬ Asia ORB System")
show_asia30       = input.bool(true,  "Show 30 Min ORB (Asia)",      group="⑬ Asia ORB System")
asia_box_opacity  = input.int(80,     "Asia ORB Box Opacity",        group="⑬ Asia ORB System")
asia_extend       = input.int(100,    "Asia ORB Line Extend",        group="⑬ Asia ORB System")
c_orb_asia        = input.color(#9C27B0, "Asia ORB Color",           group="⑬ Asia ORB System")

// --- Liquidity Sweep ---
show_liq_sweep    = input.bool(true,  "── Liquidity Sweep Arrows",   group="⑭ Liquidity Sweep")
liq_lookback      = input.int(10,     "Sweep Lookback (bars)",       group="⑭ Liquidity Sweep", minval=3, maxval=50)
c_liq             = input.color(#9269AF, "Liquidity Sweep Color",    group="⑭ Liquidity Sweep")

// --- Break of Structure / CHoCH ---
show_bos          = input.bool(true,  "── Break of Structure + CHoCH", group="⑮ BOS & CHoCH")
bos_lookback      = input.int(10,     "Structure Lookback (bars)",     group="⑮ BOS & CHoCH", minval=3, maxval=50)
c_bos             = input.color(#FF69B4, "BOS / CHoCH Color",          group="⑮ BOS & CHoCH")

// --- Session High / Low Lines ---
show_session_hl   = input.bool(true,  "── Session High/Low Lines",    group="⑯ Session High/Low")
show_sess_ny      = input.bool(true,  "NY Session (9:30–16:00)",      group="⑯ Session High/Low")
show_sess_london  = input.bool(true,  "London Session (3:00–8:00)",   group="⑯ Session High/Low")
show_sess_asia    = input.bool(true,  "Asia Session (7:00pm–2:00am)", group="⑯ Session High/Low")
sess_extend       = input.int(20,     "Extend Lines (bars)",          group="⑯ Session High/Low")
c_sess_hl         = input.color(#5CFFB0, "Session H/L Line Color",   group="⑯ Session High/Low")

// --- Range Detection System ---
show_range        = input.bool(true,   "── Range Detection System",       group="⑰ Range System")
range_lookback    = input.int(20,      "Range Lookback (bars)",           group="⑰ Range System", minval=10, maxval=100)
range_atr_thresh  = input.float(0.5,  "ATR Compression Threshold",       group="⑰ Range System", minval=0.1, maxval=1.0)
range_adx_thresh  = input.int(20,     "ADX Threshold (below = range)",   group="⑰ Range System", minval=10, maxval=40)
range_box_opacity = input.int(88,     "Range Box Opacity",               group="⑰ Range System", minval=0, maxval=100)
c_range           = input.color(#00BCD4, "Range Box Color",              group="⑰ Range System")
c_sniper_buy      = input.color(#00E676, "Sniper Buy Color",             group="⑰ Range System")
c_sniper_sell     = input.color(#FF1744, "Sniper Sell Color",            group="⑰ Range System")

// ══════════════════════════════════════════════
//   GLOBAL CONSTANTS
// ══════════════════════════════════════════════
barMs = timeframe.in_seconds() * 1000

// ══════════════════════════════════════════════
//   COLORS (all driven by input.color() fields)
// ══════════════════════════════════════════════
color_bull       = c_support
color_bear       = c_resist
color_bull_faded = color.new(c_support, sr_box_opacity)
color_bear_faded = color.new(c_resist,  sr_box_opacity)
color_vwap       = c_vwap
color_neutral    = color.new(#B0BEC5, 0)
color_ob         = c_ob
color_fvg_bull   = c_fvg_bull
color_fvg_bear   = c_fvg_bear
color_aplus      = c_aplus
color_go_buy     = c_go_buy
color_go_sell    = c_go_sell
color_orb_15     = c_orb15
color_orb_30     = c_orb30
color_orb_lon    = c_orb_lon
color_orb_asia   = c_orb_asia
color_liq        = c_liq
color_bos        = c_bos
color_sess_hl    = c_sess_hl

// ══════════════════════════════════════════════
//   1. SUPPORT & RESISTANCE ZONES
// ══════════════════════════════════════════════
isResistanceBar = ta.pivothigh(high, sr_lookback, sr_lookback)
isSupportBar    = ta.pivotlow(low,  sr_lookback, sr_lookback)

if show_sr and not na(isResistanceBar)
    box.new(bar_index - sr_lookback - sr_extend_bars, isResistanceBar, bar_index - sr_lookback + sr_extend_bars, isResistanceBar - (high[sr_lookback] - low[sr_lookback]) * 0.2, border_color=color_bear, bgcolor=color_bear_faded, border_width=1, border_style=line.style_solid)

if show_sr and not na(isSupportBar)
    box.new(bar_index - sr_lookback - sr_extend_bars, isSupportBar + (high[sr_lookback] - low[sr_lookback]) * 0.2, bar_index - sr_lookback + sr_extend_bars, isSupportBar, border_color=color_bull, bgcolor=color_bull_faded, border_width=1, border_style=line.style_solid)

// ══════════════════════════════════════════════
//   2. EMA 9 & 21
// ══════════════════════════════════════════════
ema9        = ta.ema(close, ema_fast)
ema21       = ta.ema(close, ema_slow)
isBullTrend = ema9 > ema21
isBearTrend = ema9 < ema21

plot(ema9,  "EMA 9",  color=show_emas ? (isBullTrend ? c_ema_bull : c_ema_bear) : na, linewidth=2)
plot(ema21, "EMA 21", color=show_emas ? (isBullTrend ? c_ema_bull : c_ema_bear) : na, linewidth=2, style=plot.style_circles)

// ══════════════════════════════════════════════
//   3. A+ BUY / SELL ARROWS
// ══════════════════════════════════════════════
atr          = ta.atr(14)
bullPullback = isBullTrend and low <= ema9 + atr * atr_mult and close > ema9 and close[1] <= ema9
bearPullback = isBearTrend and high >= ema9 - atr * atr_mult and close < ema9 and close[1] >= ema9

volMA    = ta.sma(volume, vol_ma_len)
volRatio = volume / volMA
highVol  = volRatio >= 1.0

bullEngulf = close > open and close > high[1]
bearEngulf = close < open and close < low[1]

aPlus_Buy  = bullPullback and bullEngulf and highVol and isBullTrend
aPlus_Sell = bearPullback and bearEngulf and highVol and isBearTrend

plotshape(show_arrows and aPlus_Buy,  "A+ Signal Buy",  shape.triangleup,   location.belowbar, color_aplus, size=size.normal, text="A+ Signal")
plotshape(show_arrows and aPlus_Sell, "A+ Signal Sell", shape.triangledown, location.abovebar, color_aplus, size=size.normal, text="A+ Signal")

// ══════════════════════════════════════════════
//   GO EXECUTION ARROWS
// ══════════════════════════════════════════════
nySession     = hour(time, "America/New_York") >= 9 and hour(time, "America/New_York") < 16
londonSession = hour(time, "UTC") >= 7 and hour(time, "UTC") < 12
asiaSession   = hour(time, "UTC") >= 0 and hour(time, "UTC") < 6
activeSession = go_session_filter ? (nySession or londonSession or asiaSession) : true

candleRange = high - low
candleBody  = math.abs(close - open)
strongBody  = candleRange > 0 and (candleBody / candleRange) >= go_body_pct

atrMA       = ta.sma(atr, 10)
atrExpanded = atr > atrMA
highVol2    = volRatio >= 1.5

pivotHigh     = ta.pivothigh(high, 3, 0)
pivotLow      = ta.pivotlow(low, 3, 0)
nearResistance = not na(pivotHigh) and math.abs(close - pivotHigh) < atr
nearSupport    = not na(pivotLow)  and math.abs(close - pivotLow)  < atr

go_Buy  = aPlus_Buy  and strongBody and atrExpanded and highVol2 and activeSession and not nearResistance
go_Sell = aPlus_Sell and strongBody and atrExpanded and highVol2 and activeSession and not nearSupport

plotshape(show_go and go_Buy,  "GO Buy",  shape.triangleup,   location.belowbar, color_go_buy,  size=size.large, text="GO")
plotshape(show_go and go_Sell, "GO Sell", shape.triangledown, location.abovebar, color_go_sell, size=size.large, text="GO")

// ══════════════════════════════════════════════
//   4. DAILY BIAS + MARKET CONDITION TABLE
// ══════════════════════════════════════════════
dailyClose = request.security(syminfo.tickerid, "D", close)
dailyEMA   = request.security(syminfo.tickerid, "D", ta.ema(close, daily_ema_len))
dailyBias  = dailyClose > dailyEMA ? "DAILY: BUYS 📈" : "DAILY: SELLS 📉"
dailyColor = dailyClose > dailyEMA ? color_bull : color_bear

vwapValue  = ta.vwap(close)

score_bias  = (isBullTrend and dailyClose > dailyEMA) or (isBearTrend and dailyClose < dailyEMA) ? 1 : 0
score_vwap  = (isBullTrend and close > vwapValue) or (isBearTrend and close < vwapValue) ? 1 : 0
score_vol   = volRatio >= 1.0 ? 1 : 0
score_ema   = math.abs(ema9 - ema21) > atr * 0.3 ? 1 : 0
score_trend = (close > ema9 and isBullTrend) or (close < ema9 and isBearTrend) ? 1 : 0
mktScore    = score_bias + score_vwap + score_vol + score_ema + score_trend

tfLabel  = timeframe.period == "1" ? "1M" : timeframe.period == "2" ? "2M" : timeframe.period == "3" ? "3M" : timeframe.period == "5" ? "5M" : timeframe.period == "15" ? "15M" : timeframe.period == "30" ? "30M" : timeframe.period == "60" ? "1H" : timeframe.period == "240" ? "4H" : timeframe.period == "D" ? "D" : timeframe.period == "W" ? "W" : timeframe.period
mktLabel = mktScore >= 4 ? tfLabel + ": ✅ GOOD" : mktScore == 3 ? tfLabel + ": ⚠️ CAUTION" : tfLabel + ": ❌ CHOPPY"
mktColor = mktScore >= 4 ? color.new(#00E676, 15) : mktScore == 3 ? color.new(#FFD600, 15) : color.new(#FF1744, 15)

var table infoPanel = table.new(position.top_right, 1, 2, border_width=1)
if barstate.islast
    if show_daily_bias
        table.cell(infoPanel, 0, 0, dailyBias, text_color=color.white, text_size=size.normal, bgcolor=color.new(dailyColor, 20))
    if show_mkt_condition
        table.cell(infoPanel, 0, 1, mktLabel, text_color=color.white, text_size=size.normal, bgcolor=mktColor)

// ══════════════════════════════════════════════
//   5. VWAP LINE + VOLUME LABEL
// ══════════════════════════════════════════════
plot(show_vwap ? vwapValue : na, "VWAP", color=color_vwap, linewidth=2, style=plot.style_line)

volSignal      = volRatio >= 2.0 ? "🔥 EXTREME VOL" : volRatio >= 1.5 ? "⚡ HIGH VOL" : volRatio >= 1.0 ? "✅ AVG VOL" : "🔇 LOW VOL"
volSignalColor = volRatio >= 2.0 ? color.new(#FF6D00, 0) : volRatio >= 1.5 ? color.new(#FFD600, 0) : volRatio >= 1.0 ? color_bull : color_neutral
priceVsVwap    = close > vwapValue ? "ABOVE VWAP" : "BELOW VWAP"
vwapLabelText  = priceVsVwap + " | " + volSignal

var label volLabel = na
label.delete(volLabel)
if show_vol_label
    volLabel := label.new(bar_index, low * 0.999, vwapLabelText, color=color.new(#212121, 10), textcolor=volSignalColor, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//   6. ZONE RETEST LABELS
// ══════════════════════════════════════════════
var float lastResistance = na
var float lastSupport    = na
if not na(isResistanceBar)
    lastResistance := isResistanceBar
if not na(isSupportBar)
    lastSupport := isSupportBar

zoneRetestBuy  = not na(lastResistance) and close[1] > lastResistance and low <= lastResistance * 1.002 and close > lastResistance and close > open
zoneRetestSell = not na(lastSupport)    and close[1] < lastSupport    and high >= lastSupport * 0.998   and close < lastSupport    and close < open

if show_zone_retest and zoneRetestBuy
    labelPrice = low - atr * 2.5
    label.new(bar_index, labelPrice, "◆ RETEST BUY", color=color.new(color_bull, 10), textcolor=color.white, style=label.style_label_upper_left, size=size.small)
    line.new(bar_index, labelPrice, bar_index, low, color=color.new(color_bull, 40), width=1, style=line.style_dashed)

if show_zone_retest and zoneRetestSell
    labelPrice = high + atr * 2.5
    label.new(bar_index, labelPrice, "◆ RETEST SELL", color=color.new(color_bear, 10), textcolor=color.white, style=label.style_label_lower_left, size=size.small)
    line.new(bar_index, labelPrice, bar_index, high, color=color.new(color_bear, 40), width=1, style=line.style_dashed)

// ══════════════════════════════════════════════
//   7. EMA RETEST LABELS
// ══════════════════════════════════════════════
emaRetestBuy  = isBullTrend and low[1] > ema9[1] and low <= ema9 * 1.001 and close > ema9 and close > open
emaRetestSell = isBearTrend and high[1] < ema9[1] and high >= ema9 * 0.999 and close < ema9 and close < open

if show_ema_retest and emaRetestBuy
    labelPrice = low - atr * 1.5
    label.new(bar_index, labelPrice, "◆ EMA RETEST BUY", color=color.new(color_bull, 25), textcolor=color.white, style=label.style_label_upper_left, size=size.small)
    line.new(bar_index, labelPrice, bar_index, ema9, color=color.new(color_bull, 50), width=1, style=line.style_dashed)

if show_ema_retest and emaRetestSell
    labelPrice = high + atr * 1.5
    label.new(bar_index, labelPrice, "◆ EMA RETEST SELL", color=color.new(color_bear, 25), textcolor=color.white, style=label.style_label_lower_left, size=size.small)
    line.new(bar_index, labelPrice, bar_index, ema9, color=color.new(color_bear, 50), width=1, style=line.style_dashed)

// ══════════════════════════════════════════════
//   8. ORDER BLOCKS
// ══════════════════════════════════════════════
obStrength = atr * 1.5
isBullOB   = close[1] < open[1] and close > open and (close - open) > obStrength
isBearOB   = close[1] > open[1] and close < open and (open - close) > obStrength

if show_ob and isBullOB
    box.new(bar_index - 1, open[1], bar_index + ob_lookback, close[1], border_color=color_ob, bgcolor=color.new(color_ob, ob_opacity), border_width=1)
    label.new(bar_index - 1, low[1], "OB", color=color.new(color_ob, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)

if show_ob and isBearOB
    box.new(bar_index - 1, close[1], bar_index + ob_lookback, open[1], border_color=color_ob, bgcolor=color.new(color_ob, ob_opacity), border_width=1)
    label.new(bar_index - 1, high[1], "OB", color=color.new(color_ob, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ══════════════════════════════════════════════
//   9. FAIR VALUE GAPS
// ══════════════════════════════════════════════
fvgUp   = low > high[2]
fvgDown = high < low[2]

if show_fvg and fvgUp
    box.new(bar_index - 2, low, bar_index, high[2], border_color=color_fvg_bull, bgcolor=color.new(color_fvg_bull, fvg_opacity), border_width=1, border_style=line.style_dotted)
    label.new(bar_index, low, "FVG↑", color=color.new(color_fvg_bull, 20), textcolor=color.white, style=label.style_label_upper_left, size=size.tiny)

if show_fvg and fvgDown
    box.new(bar_index - 2, low[2], bar_index, high, border_color=color_fvg_bear, bgcolor=color.new(color_fvg_bear, fvg_opacity), border_width=1, border_style=line.style_dotted)
    label.new(bar_index, high, "FVG↓", color=color.new(color_fvg_bear, 20), textcolor=color.white, style=label.style_label_lower_left, size=size.tiny)

// ══════════════════════════════════════════════
//   11. NY ORB SYSTEM — 15 Min & 30 Min
// ══════════════════════════════════════════════
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
isNYOpen = (nyHour == 9 and nyMinute == 30) and not (nyHour[1] == 9 and nyMinute[1] == 30)

var int orb_today = na
if isNYOpen
    orb_today := dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York")
isToday_orb = not na(orb_today) and dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York") == orb_today

var float orb15_high = na, var float orb15_low = na, var bool orb15_set = false, var int orb15_startBar = na, var int orb15_endBar = na
var float orb30_high = na, var float orb30_low = na, var bool orb30_set = false, var int orb30_startBar = na, var int orb30_endBar = na
var float orb15_rH = na, var float orb15_rL = na, var float orb30_rH = na, var float orb30_rL = na
var bool orb15_bullBroke = false, var bool orb15_bearBroke = false, var bool orb30_bullBroke = false, var bool orb30_bearBroke = false
var box orb15_box = na, var box orb30_box = na

if isNYOpen
    orb15_set := false
    orb30_set := false
    orb15_startBar := bar_index
    orb30_startBar := bar_index
    orb15_rH := high
    orb15_rL := low
    orb30_rH := high
    orb30_rL := low
    orb15_bullBroke := false
    orb15_bearBroke := false
    orb30_bullBroke := false
    orb30_bearBroke := false
    box.delete(orb15_box)
    box.delete(orb30_box)

if not orb15_set and not na(orb15_startBar) and nyHour == 9 and nyMinute >= 30
    orb15_rH := math.max(nz(orb15_rH, high), high)
    orb15_rL := math.min(nz(orb15_rL, low),  low)
if not orb30_set and not na(orb30_startBar) and nyHour == 9 and nyMinute >= 30
    orb30_rH := math.max(nz(orb30_rH, high), high)
    orb30_rL := math.min(nz(orb30_rL, low),  low)
if not orb15_set and not na(orb15_startBar) and nyHour == 9 and nyMinute >= 45
    orb15_high := orb15_rH
    orb15_low  := orb15_rL
    orb15_set  := true
    orb15_endBar := bar_index
if not orb30_set and not na(orb30_startBar) and nyHour == 10 and nyMinute == 0
    orb30_high := orb30_rH
    orb30_low  := orb30_rL
    orb30_set  := true
    orb30_endBar := bar_index

orb15_bullBreak = orb15_set and not orb15_bullBroke and close > orb15_high and close[1] <= orb15_high
orb15_bearBreak = orb15_set and not orb15_bearBroke and close < orb15_low  and close[1] >= orb15_low
orb30_bullBreak = orb30_set and not orb30_bullBroke and close > orb30_high and close[1] <= orb30_high
orb30_bearBreak = orb30_set and not orb30_bearBroke and close < orb30_low  and close[1] >= orb30_low

if orb15_bullBreak
    orb15_bullBroke := true
if orb15_bearBreak
    orb15_bearBroke := true
if orb30_bullBreak
    orb30_bullBroke := true
if orb30_bearBreak
    orb30_bearBroke := true

// ── ORB Breakout signals (using labels instead of plotshape to stay under plot limit) ──
if show_orb15 and orb15_bullBreak
    label.new(bar_index, low, "ORB15↑", color=color.new(color_orb_15, 10), textcolor=color.white, style=label.style_label_up, size=size.small)
if show_orb15 and orb15_bearBreak
    label.new(bar_index, high, "ORB15↓", color=color.new(color_orb_15, 10), textcolor=color.white, style=label.style_label_down, size=size.small)
if show_orb30 and orb30_bullBreak
    label.new(bar_index, low, "ORB30↑", color=color.new(color_orb_30, 10), textcolor=color.white, style=label.style_label_up, size=size.small)
if show_orb30 and orb30_bearBreak
    label.new(bar_index, high, "ORB30↓", color=color.new(color_orb_30, 10), textcolor=color.white, style=label.style_label_down, size=size.small)

if show_orb15 and orb15_set and bar_index == orb15_endBar
    box.delete(orb15_box)
    orb15_box := box.new(orb15_startBar, orb15_high, bar_index + orb15_extend, orb15_low, border_color=color_orb_15, bgcolor=color.new(color_orb_15, orb15_box_opacity), border_width=2, text="15 Min ORB", text_color=color_orb_15, text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)
if show_orb30 and orb30_set and bar_index == orb30_endBar
    box.delete(orb30_box)
    orb30_box := box.new(orb30_startBar, orb30_high, bar_index + orb30_extend, orb30_low, border_color=color_orb_30, bgcolor=color.new(color_orb_30, orb30_box_opacity), border_width=2, text="30 Min ORB", text_color=color_orb_30, text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)

if barstate.islast and isToday_orb
    if show_orb15 and orb15_set
        orb15HColor = orb15_bullBroke ? color_bull : orb15_bearBroke ? color_bear : color_orb_15
        orb15HLabel = orb15_bullBroke ? "15M ORB HIGH | SUPPORT - Add Buy on pullback" : orb15_bearBroke ? "15M ORB HIGH | MAJOR RESIST - Warning for longs" : "15M ORB HIGH | Awaiting breakout"
        line.new(orb15_startBar, orb15_high, bar_index + orb15_extend, orb15_high, color=orb15HColor, width=2, style=orb15_bullBroke ? line.style_solid : line.style_dashed)
        label.new(bar_index, orb15_high, orb15HLabel, color=color.new(orb15HColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
        orb15LColor = orb15_bullBroke ? color.new(color_bull, 20) : orb15_bearBroke ? color_bear : color_orb_15
        orb15LLabel = orb15_bullBroke ? "15M ORB LOW | MAJOR SUPPORT - Trend failing if lost" : orb15_bearBroke ? "15M ORB LOW | RESISTANCE - Add short on bounce" : "15M ORB LOW | Awaiting breakout"
        line.new(orb15_startBar, orb15_low, bar_index + orb15_extend, orb15_low, color=orb15LColor, width=2, style=orb15_bearBroke ? line.style_solid : line.style_dashed)
        label.new(bar_index, orb15_low, orb15LLabel, color=color.new(orb15LColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
    if show_orb30 and orb30_set
        orb30HColor = orb30_bullBroke ? color_bull : orb30_bearBroke ? color_bear : color_orb_30
        orb30HLabel = orb30_bullBroke ? "30M ORB HIGH | SUPPORT - Add Buy on pullback" : orb30_bearBroke ? "30M ORB HIGH | MAJOR RESIST - Warning for longs" : "30M ORB HIGH | Awaiting breakout"
        line.new(orb30_startBar, orb30_high, bar_index + orb30_extend, orb30_high, color=orb30HColor, width=2, style=orb30_bullBroke ? line.style_solid : line.style_dashed)
        label.new(bar_index, orb30_high, orb30HLabel, color=color.new(orb30HColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
        orb30LColor = orb30_bullBroke ? color.new(color_bull, 20) : orb30_bearBroke ? color_bear : color_orb_30
        orb30LLabel = orb30_bullBroke ? "30M ORB LOW | MAJOR SUPPORT - Trend failing if lost" : orb30_bearBroke ? "30M ORB LOW | RESISTANCE - Add short on bounce" : "30M ORB LOW | Awaiting breakout"
        line.new(orb30_startBar, orb30_low, bar_index + orb30_extend, orb30_low, color=orb30LColor, width=2, style=orb30_bearBroke ? line.style_solid : line.style_dashed)
        label.new(bar_index, orb30_low, orb30LLabel, color=color.new(orb30LColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//   12. LONDON ORB SYSTEM
// ══════════════════════════════════════════════
lonHour   = hour(time, "America/New_York")
lonMinute = minute(time, "America/New_York")
isLonOpen = lonHour == 3 and lonMinute == 0 and (lonHour[1] < 3 or (lonHour[1] == 3 and lonMinute[1] > 0))

var int lon_today = na
if isLonOpen
    lon_today := dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York")
isToday_lon = not na(lon_today) and dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York") == lon_today

var float lon15_high = na, var float lon15_low = na, var bool lon15_set = false, var int lon15_time = na, var int lon15_end = na, var float lon15_rH = na, var float lon15_rL = na
var float lon30_high = na, var float lon30_low = na, var bool lon30_set = false, var int lon30_time = na, var int lon30_end = na, var float lon30_rH = na, var float lon30_rL = na
var bool lon15_bullBroke = false, var bool lon15_bearBroke = false, var bool lon30_bullBroke = false, var bool lon30_bearBroke = false
var box lon15_box = na, var box lon30_box = na

if isLonOpen
    lon15_set := false
    lon30_set := false
    lon15_bullBroke := false
    lon15_bearBroke := false
    lon30_bullBroke := false
    lon30_bearBroke := false
    lon15_time := time
    lon30_time := time
    lon15_rH := high
    lon15_rL := low
    lon30_rH := high
    lon30_rL := low
    box.delete(lon15_box)
    box.delete(lon30_box)

if not lon15_set and lonHour == 3
    lon15_rH := math.max(nz(lon15_rH, high), high)
    lon15_rL := math.min(nz(lon15_rL, low),  low)
    if lonMinute >= 15
        lon15_high := lon15_rH
        lon15_low  := lon15_rL
        lon15_set  := true
        lon15_end  := time

if not lon30_set and (lonHour == 3 or (lonHour == 4 and lonMinute == 0))
    lon30_rH := math.max(nz(lon30_rH, high), high)
    lon30_rL := math.min(nz(lon30_rL, low),  low)
    if lonHour == 3 and lonMinute >= 30
        lon30_high := lon30_rH
        lon30_low  := lon30_rL
        lon30_set  := true
        lon30_end  := time

lon15_bullBreak = lon15_set and close > lon15_high and close[1] <= lon15_high
lon15_bearBreak = lon15_set and close < lon15_low  and close[1] >= lon15_low
lon30_bullBreak = lon30_set and close > lon30_high and close[1] <= lon30_high
lon30_bearBreak = lon30_set and close < lon30_low  and close[1] >= lon30_low

if lon15_bullBreak
    lon15_bullBroke := true
if lon15_bearBreak
    lon15_bearBroke := true
if lon30_bullBreak
    lon30_bullBroke := true
if lon30_bearBreak
    lon30_bearBroke := true

if show_lon15 and lon15_set and lon15_end == time
    box.delete(lon15_box)
    lon15_box := box.new(lon15_time, lon15_high, time + barMs * lon_extend, lon15_low, xloc=xloc.bar_time, border_color=color_orb_lon, bgcolor=color.new(color_orb_lon, lon_box_opacity), border_width=2, text="15 Min London ORB", text_color=color_orb_lon, text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)
if show_lon30 and lon30_set and lon30_end == time
    box.delete(lon30_box)
    lon30_box := box.new(lon30_time, lon30_high, time + barMs * lon_extend, lon30_low, xloc=xloc.bar_time, border_color=color_orb_lon, bgcolor=color.new(color_orb_lon, lon_box_opacity), border_width=2, text="30 Min London ORB", text_color=color_orb_lon, text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)

if barstate.islast and isToday_lon
    if show_lon15 and lon15_set
        lon15HColor = lon15_bullBroke ? color_bull : lon15_bearBroke ? color_bear : color_orb_lon
        lon15HLabel = lon15_bullBroke ? "LON 15M HIGH — SUPPORT 🟢 (Add Buy)" : lon15_bearBroke ? "LON 15M HIGH — MAJOR RESIST 🔴 (Warning)" : "LON 15M HIGH"
        line.new(lon15_time, lon15_high, lon15_time + barMs * lon_extend, lon15_high, xloc=xloc.bar_time, color=lon15HColor, width=2, style=line.style_dashed)
        label.new(bar_index, lon15_high, lon15HLabel, color=color.new(lon15HColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
        lon15LColor = lon15_bullBroke ? color.new(color_bull, 30) : lon15_bearBroke ? color_bear : color_orb_lon
        lon15LLabel = lon15_bullBroke ? "LON 15M LOW — MAJOR SUPPORT 🟢 (Trend Failing?)" : lon15_bearBroke ? "LON 15M LOW — RESISTANCE 🔴 (Add Short)" : "LON 15M LOW"
        line.new(lon15_time, lon15_low, lon15_time + barMs * lon_extend, lon15_low, xloc=xloc.bar_time, color=lon15LColor, width=2, style=line.style_dashed)
        label.new(bar_index, lon15_low, lon15LLabel, color=color.new(lon15LColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
    if show_lon30 and lon30_set
        lon30HColor = lon30_bullBroke ? color_bull : lon30_bearBroke ? color_bear : color_orb_lon
        lon30HLabel = lon30_bullBroke ? "LON 30M HIGH — SUPPORT 🟢 (Add Buy)" : lon30_bearBroke ? "LON 30M HIGH — MAJOR RESIST 🔴 (Warning)" : "LON 30M HIGH"
        line.new(lon30_time, lon30_high, lon30_time + barMs * lon_extend, lon30_high, xloc=xloc.bar_time, color=lon30HColor, width=2, style=line.style_solid)
        label.new(bar_index, lon30_high, lon30HLabel, color=color.new(lon30HColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
        lon30LColor = lon30_bullBroke ? color.new(color_bull, 30) : lon30_bearBroke ? color_bear : color_orb_lon
        lon30LLabel = lon30_bullBroke ? "LON 30M LOW — MAJOR SUPPORT 🟢 (Trend Failing?)" : lon30_bearBroke ? "LON 30M LOW — RESISTANCE 🔴 (Add Short)" : "LON 30M LOW"
        line.new(lon30_time, lon30_low, lon30_time + barMs * lon_extend, lon30_low, xloc=xloc.bar_time, color=lon30LColor, width=2, style=line.style_solid)
        label.new(bar_index, lon30_low, lon30LLabel, color=color.new(lon30LColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//   13. ASIA ORB SYSTEM
// ══════════════════════════════════════════════
asiaHour   = hour(time, "America/New_York")
asiaMinute = minute(time, "America/New_York")
isAsiaOpen = asiaHour == 19 and asiaMinute == 0 and (asiaHour[1] < 19 or (asiaHour[1] == 19 and asiaMinute[1] > 0))

var int asia_today = na
if isAsiaOpen
    asia_today := dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York")
isToday_asia = not na(asia_today) and dayofmonth(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + year(time, "America/New_York") == asia_today

var float asia15_high = na, var float asia15_low = na, var bool asia15_set = false, var int asia15_time = na, var int asia15_end = na, var float asia15_rH = na, var float asia15_rL = na
var float asia30_high = na, var float asia30_low = na, var bool asia30_set = false, var int asia30_time = na, var int asia30_end = na, var float asia30_rH = na, var float asia30_rL = na
var bool asia15_bullBroke = false, var bool asia15_bearBroke = false, var bool asia30_bullBroke = false, var bool asia30_bearBroke = false
var box asia15_box = na, var box asia30_box = na

if isAsiaOpen
    asia15_set := false
    asia30_set := false
    asia15_bullBroke := false
    asia15_bearBroke := false
    asia30_bullBroke := false
    asia30_bearBroke := false
    asia15_time := time
    asia30_time := time
    asia15_rH := high
    asia15_rL := low
    asia30_rH := high
    asia30_rL := low
    box.delete(asia15_box)
    box.delete(asia30_box)

if not asia15_set and asiaHour == 19
    asia15_rH := math.max(nz(asia15_rH, high), high)
    asia15_rL := math.min(nz(asia15_rL, low),  low)
    if asiaMinute >= 15
        asia15_high := asia15_rH
        asia15_low  := asia15_rL
        asia15_set  := true
        asia15_end  := time

if not asia30_set and (asiaHour == 19 or (asiaHour == 20 and asiaMinute == 0))
    asia30_rH := math.max(nz(asia30_rH, high), high)
    asia30_rL := math.min(nz(asia30_rL, low),  low)
    if asiaHour == 19 and asiaMinute >= 30
        asia30_high := asia30_rH
        asia30_low  := asia30_rL
        asia30_set  := true
        asia30_end  := time

asia15_bullBreak = asia15_set and close > asia15_high and close[1] <= asia15_high
asia15_bearBreak = asia15_set and close < asia15_low  and close[1] >= asia15_low
asia30_bullBreak = asia30_set and close > asia30_high and close[1] <= asia30_high
asia30_bearBreak = asia30_set and close < asia30_low  and close[1] >= asia30_low

if asia15_bullBreak
    asia15_bullBroke := true
if asia15_bearBreak
    asia15_bearBroke := true
if asia30_bullBreak
    asia30_bullBroke := true
if asia30_bearBreak
    asia30_bearBroke := true

if show_asia15 and asia15_set and asia15_end == time
    box.delete(asia15_box)
    asia15_box := box.new(asia15_time, asia15_high, time + barMs * asia_extend, asia15_low, xloc=xloc.bar_time, border_color=color_orb_asia, bgcolor=color.new(color_orb_asia, asia_box_opacity), border_width=2, text="15 Min Asia ORB", text_color=color_orb_asia, text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)
if show_asia30 and asia30_set and asia30_end == time
    box.delete(asia30_box)
    asia30_box := box.new(asia30_time, asia30_high, time + barMs * asia_extend, asia30_low, xloc=xloc.bar_time, border_color=color_orb_asia, bgcolor=color.new(color_orb_asia, asia_box_opacity), border_width=2, text="30 Min Asia ORB", text_color=color_orb_asia, text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)

if barstate.islast and isToday_asia
    if show_asia15 and asia15_set
        a15HColor = asia15_bullBroke ? color_bull : asia15_bearBroke ? color_bear : color_orb_asia
        a15HLabel = asia15_bullBroke ? "ASIA 15M HIGH — SUPPORT 🟢 (Add Buy)" : asia15_bearBroke ? "ASIA 15M HIGH — MAJOR RESIST 🔴 (Warning)" : "ASIA 15M HIGH"
        line.new(asia15_time, asia15_high, asia15_time + barMs * asia_extend, asia15_high, xloc=xloc.bar_time, color=a15HColor, width=2, style=line.style_dashed)
        label.new(bar_index, asia15_high, a15HLabel, color=color.new(a15HColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
        a15LColor = asia15_bullBroke ? color.new(color_bull, 30) : asia15_bearBroke ? color_bear : color_orb_asia
        a15LLabel = asia15_bullBroke ? "ASIA 15M LOW — MAJOR SUPPORT 🟢 (Trend Failing?)" : asia15_bearBroke ? "ASIA 15M LOW — RESISTANCE 🔴 (Add Short)" : "ASIA 15M LOW"
        line.new(asia15_time, asia15_low, asia15_time + barMs * asia_extend, asia15_low, xloc=xloc.bar_time, color=a15LColor, width=2, style=line.style_dashed)
        label.new(bar_index, asia15_low, a15LLabel, color=color.new(a15LColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
    if show_asia30 and asia30_set
        a30HColor = asia30_bullBroke ? color_bull : asia30_bearBroke ? color_bear : color_orb_asia
        a30HLabel = asia30_bullBroke ? "ASIA 30M HIGH — SUPPORT 🟢 (Add Buy)" : asia30_bearBroke ? "ASIA 30M HIGH — MAJOR RESIST 🔴 (Warning)" : "ASIA 30M HIGH"
        line.new(asia30_time, asia30_high, asia30_time + barMs * asia_extend, asia30_high, xloc=xloc.bar_time, color=a30HColor, width=2, style=line.style_solid)
        label.new(bar_index, asia30_high, a30HLabel, color=color.new(a30HColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
        a30LColor = asia30_bullBroke ? color.new(color_bull, 30) : asia30_bearBroke ? color_bear : color_orb_asia
        a30LLabel = asia30_bullBroke ? "ASIA 30M LOW — MAJOR SUPPORT 🟢 (Trend Failing?)" : asia30_bearBroke ? "ASIA 30M LOW — RESISTANCE 🔴 (Add Short)" : "ASIA 30M LOW"
        line.new(asia30_time, asia30_low, asia30_time + barMs * asia_extend, asia30_low, xloc=xloc.bar_time, color=a30LColor, width=2, style=line.style_solid)
        label.new(bar_index, asia30_low, a30LLabel, color=color.new(a30LColor, 15), textcolor=color.white, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//   14. LIQUIDITY SWEEP DETECTOR
// ══════════════════════════════════════════════
liq_pivotHigh = ta.pivothigh(high, liq_lookback, 1)
liq_pivotLow  = ta.pivotlow(low,  liq_lookback, 1)

var float liq_lastHigh = na
var float liq_lastLow  = na
if not na(liq_pivotHigh)
    liq_lastHigh := liq_pivotHigh
if not na(liq_pivotLow)
    liq_lastLow := liq_pivotLow

liq_sweepBull = not na(liq_lastLow)  and low < liq_lastLow  and close > liq_lastLow  and close > open
liq_sweepBear = not na(liq_lastHigh) and high > liq_lastHigh and close < liq_lastHigh and close < open

plotshape(show_liq_sweep and liq_sweepBull, "Liq Sweep Bull", shape.triangleup,   location.belowbar, color_liq, size=size.small, text="SWEEP")
plotshape(show_liq_sweep and liq_sweepBear, "Liq Sweep Bear", shape.triangledown, location.abovebar, color_liq, size=size.small, text="SWEEP")

// ══════════════════════════════════════════════
//   15. BREAK OF STRUCTURE (BOS) + CHANGE OF CHARACTER (CHoCH)
// ══════════════════════════════════════════════
bos_pivotHigh = ta.pivothigh(high, bos_lookback, bos_lookback)
bos_pivotLow  = ta.pivotlow(low,  bos_lookback, bos_lookback)

var float bos_lastSwingHigh = na
var float bos_lastSwingLow  = na
if not na(bos_pivotHigh)
    bos_lastSwingHigh := bos_pivotHigh
if not na(bos_pivotLow)
    bos_lastSwingLow := bos_pivotLow

bos_bull = not na(bos_lastSwingHigh) and close > bos_lastSwingHigh and close[1] <= bos_lastSwingHigh[1]
bos_bear = not na(bos_lastSwingLow)  and close < bos_lastSwingLow  and close[1] >= bos_lastSwingLow[1]
choch_bull    = bos_bull and isBearTrend
choch_bear    = bos_bear and isBullTrend
pure_bos_bull = bos_bull and isBullTrend
pure_bos_bear = bos_bear and isBearTrend

if show_bos and pure_bos_bull
    line.new(bar_index - 1, bos_lastSwingHigh, bar_index, bos_lastSwingHigh, color=color_bos, width=1, style=line.style_dashed)
    label.new(bar_index, bos_lastSwingHigh, "BOS", color=color.new(color_bos, 15), textcolor=color.white, style=label.style_label_down, size=size.small)
if show_bos and pure_bos_bear
    line.new(bar_index - 1, bos_lastSwingLow, bar_index, bos_lastSwingLow, color=color_bos, width=1, style=line.style_dashed)
    label.new(bar_index, bos_lastSwingLow, "BOS", color=color.new(color_bos, 15), textcolor=color.white, style=label.style_label_up, size=size.small)
if show_bos and choch_bull
    line.new(bar_index - 1, bos_lastSwingHigh, bar_index, bos_lastSwingHigh, color=color_bos, width=2, style=line.style_solid)
    label.new(bar_index, bos_lastSwingHigh, "CHoCH", color=color.new(color_bos, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)
if show_bos and choch_bear
    line.new(bar_index - 1, bos_lastSwingLow, bar_index, bos_lastSwingLow, color=color_bos, width=2, style=line.style_solid)
    label.new(bar_index, bos_lastSwingLow, "CHoCH", color=color.new(color_bos, 0), textcolor=color.white, style=label.style_label_up, size=size.normal)

// ── BOS/CHoCH signals (labels instead of plotshape) ──
if show_bos and (pure_bos_bull or choch_bull)
    label.new(bar_index, low, pure_bos_bull ? "▲" : "▲", color=color.new(color_bos, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if show_bos and (pure_bos_bear or choch_bear)
    label.new(bar_index, high, pure_bos_bear ? "▼" : "▼", color=color.new(color_bos, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ══════════════════════════════════════════════
//   16. SESSION HIGH / LOW LINES
// ══════════════════════════════════════════════
nySessionActive   = nyHour >= 9 and not (nyHour == 9 and nyMinute < 30) and nyHour < 16
lonSessionActive  = lonHour >= 3 and lonHour < 8
asiaSessionActive = asiaHour >= 19 or asiaHour < 2

var float ny_sessHigh = na,  var float ny_sessLow = na,  var int ny_sessStart = na
var line  ny_highLine = na,  var line  ny_lowLine = na
var label ny_highLabel = na, var label ny_lowLabel = na

if isNYOpen
    ny_sessHigh  := high
    ny_sessLow   := low
    ny_sessStart := bar_index
if nySessionActive and not na(ny_sessStart)
    ny_sessHigh := math.max(nz(ny_sessHigh, high), high)
    ny_sessLow  := math.min(nz(ny_sessLow,  low),  low)
if show_session_hl and show_sess_ny and not na(ny_sessStart)
    line.delete(ny_highLine)
    line.delete(ny_lowLine)
    label.delete(ny_highLabel)
    label.delete(ny_lowLabel)
    ny_highLine  := line.new(ny_sessStart, ny_sessHigh, bar_index + sess_extend, ny_sessHigh, color=color_sess_hl, width=1, style=line.style_dashed)
    ny_lowLine   := line.new(ny_sessStart, ny_sessLow,  bar_index + sess_extend, ny_sessLow,  color=color_sess_hl, width=1, style=line.style_dashed)
    ny_highLabel := label.new(bar_index + sess_extend, ny_sessHigh, "NY HIGH", color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    ny_lowLabel  := label.new(bar_index + sess_extend, ny_sessLow,  "NY LOW",  color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)

var float lon_sessHigh = na,  var float lon_sessLow = na,  var int lon_sessStart = na
var line  lon_highLine = na,  var line  lon_lowLine = na
var label lon_highLabel = na, var label lon_lowLabel = na

if isLonOpen
    lon_sessHigh  := high
    lon_sessLow   := low
    lon_sessStart := bar_index
if lonSessionActive and not na(lon_sessStart)
    lon_sessHigh := math.max(nz(lon_sessHigh, high), high)
    lon_sessLow  := math.min(nz(lon_sessLow,  low),  low)
if show_session_hl and show_sess_london and not na(lon_sessStart)
    line.delete(lon_highLine)
    line.delete(lon_lowLine)
    label.delete(lon_highLabel)
    label.delete(lon_lowLabel)
    lon_highLine  := line.new(lon_sessStart, lon_sessHigh, bar_index + sess_extend, lon_sessHigh, color=color_sess_hl, width=1, style=line.style_dashed)
    lon_lowLine   := line.new(lon_sessStart, lon_sessLow,  bar_index + sess_extend, lon_sessLow,  color=color_sess_hl, width=1, style=line.style_dashed)
    lon_highLabel := label.new(bar_index + sess_extend, lon_sessHigh, "LON HIGH", color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    lon_lowLabel  := label.new(bar_index + sess_extend, lon_sessLow,  "LON LOW",  color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)

var float asia_sessHigh = na,  var float asia_sessLow = na,  var int asia_sessStart = na
var line  asia_highLine = na,  var line  asia_lowLine = na
var label asia_highLabel = na, var label asia_lowLabel = na

if isAsiaOpen
    asia_sessHigh  := high
    asia_sessLow   := low
    asia_sessStart := bar_index
if asiaSessionActive and not na(asia_sessStart)
    asia_sessHigh := math.max(nz(asia_sessHigh, high), high)
    asia_sessLow  := math.min(nz(asia_sessLow,  low),  low)
if show_session_hl and show_sess_asia and not na(asia_sessStart)
    line.delete(asia_highLine)
    line.delete(asia_lowLine)
    label.delete(asia_highLabel)
    label.delete(asia_lowLabel)
    asia_highLine  := line.new(asia_sessStart, asia_sessHigh, bar_index + sess_extend, asia_sessHigh, color=color_sess_hl, width=1, style=line.style_dashed)
    asia_lowLine   := line.new(asia_sessStart, asia_sessLow,  bar_index + sess_extend, asia_sessLow,  color=color_sess_hl, width=1, style=line.style_dashed)
    asia_highLabel := label.new(bar_index + sess_extend, asia_sessHigh, "ASIA HIGH", color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    asia_lowLabel  := label.new(bar_index + sess_extend, asia_sessLow,  "ASIA LOW",  color=color.new(color_sess_hl, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ══════════════════════════════════════════════
//   17. RANGE DETECTION SYSTEM
//   Universal — works on any instrument, session, timeframe
//   Three filters: ATR compression + ADX + price structure
//   Draws range box, fires SNIPER BUY/SELL at boundaries
//   Warns on breakout so you don't fade a real move
// ══════════════════════════════════════════════

// ── ADX Calculation (14 period) ──
adx_len       = 14
up_move       = high - high[1]
down_move     = low[1] - low
plus_dm       = up_move > down_move and up_move > 0 ? up_move : 0.0
minus_dm      = down_move > up_move and down_move > 0 ? down_move : 0.0
atr14         = ta.atr(adx_len)
plus_di       = 100 * ta.ema(plus_dm, adx_len)  / atr14
minus_di      = 100 * ta.ema(minus_dm, adx_len) / atr14
dx            = math.abs(plus_di - minus_di) / (plus_di + minus_di) * 100
adx_val       = ta.ema(dx, adx_len)

// ── ATR Compression ──
// Current ATR vs its own moving average — compression = ranging
atr_current   = ta.atr(14)
atr_avg       = ta.sma(atr_current, range_lookback)
atr_compressed = atr_current < atr_avg * range_atr_thresh

// ── Price Structure ──
// Range high and low over lookback period
range_high    = ta.highest(high, range_lookback)
range_low     = ta.lowest(low,  range_lookback)
range_size    = range_high - range_low

// Price oscillating = not making new highs/lows beyond lookback
// Tight range = range size is small relative to ATR
tightRange    = range_size < atr_current * range_lookback * 0.5

// ── Range Mode Detection ──
// All three filters must agree
inRange       = adx_val < range_adx_thresh and atr_compressed and tightRange

// ── Range Boundary Signals ──
// SNIPER BUY: in range mode + price touches range low + bullish rejection candle
sniperBuy     = show_range and inRange and low <= range_low * 1.001 and close > open and close > range_low and volume > volMA

// SNIPER SELL: in range mode + price touches range high + bearish rejection candle
sniperSell    = show_range and inRange and high >= range_high * 0.999 and close < open and close < range_high and volume > volMA

// ── Range Breakout Warning ──
// Price closes outside range with strong volume = range is over
rangeBreakUp   = inRange[1] and close > range_high and volume > volMA * 1.5
rangeBreakDown = inRange[1] and close < range_low  and volume > volMA * 1.5

// ── Range Mode Label ──
rangeModeText  = inRange ? "📦 RANGE MODE" : "🚀 TREND MODE"
rangeModeColor = inRange ? color.new(c_range, 15) : color.new(#FF8C00, 15)

var label rangeModeLabel = na
label.delete(rangeModeLabel)
if show_range
    rangeModeLabel := label.new(bar_index, low * 0.9995, rangeModeText, color=rangeModeColor, textcolor=color.white, style=label.style_label_upper_left, size=size.small)

// ── Draw Range Box (updates every bar while in range) ──
var box rangeBox = na
if show_range
    if inRange
        box.delete(rangeBox)
        rangeBox := box.new(bar_index - range_lookback, range_high, bar_index + 10, range_low, border_color=color.new(c_range, 40), bgcolor=color.new(c_range, range_box_opacity), border_width=1, border_style=line.style_dashed)
    else
        box.delete(rangeBox)

// ── SNIPER Signals ──
plotshape(show_range and sniperBuy,  "Sniper Buy",  shape.triangleup,   location.belowbar, c_sniper_buy,  size=size.normal, text="SNIPER BUY")
plotshape(show_range and sniperSell, "Sniper Sell", shape.triangledown, location.abovebar, c_sniper_sell, size=size.normal, text="SNIPER SELL")

// ── Breakout Warning Labels ──
if show_range and rangeBreakUp
    label.new(bar_index, high, "⚡ RANGE BREAK UP", color=color.new(c_sniper_buy, 10), textcolor=color.white, style=label.style_label_down, size=size.small)

if show_range and rangeBreakDown
    label.new(bar_index, low, "⚡ RANGE BREAK DOWN", color=color.new(c_sniper_sell, 10), textcolor=color.white, style=label.style_label_up, size=size.small)

// ══════════════════════════════════════════════
//   ALERTS
// ══════════════════════════════════════════════
alertcondition(aPlus_Buy,       "A+ Signal Buy",            "CirisAshley: A+ SIGNAL BUY triggered")
alertcondition(aPlus_Sell,      "A+ Signal Sell",           "CirisAshley: A+ SIGNAL SELL triggered")
alertcondition(go_Buy,          "GO Buy",                   "CirisAshley: GO BUY — Execute now")
alertcondition(go_Sell,         "GO Sell",                  "CirisAshley: GO SELL — Execute now")
alertcondition(zoneRetestBuy,   "Zone Retest Buy",          "CirisAshley: ZONE RETEST BUY triggered")
alertcondition(zoneRetestSell,  "Zone Retest Sell",         "CirisAshley: ZONE RETEST SELL triggered")
alertcondition(emaRetestBuy,    "EMA Retest Buy",           "CirisAshley: EMA RETEST BUY triggered")
alertcondition(emaRetestSell,   "EMA Retest Sell",          "CirisAshley: EMA RETEST SELL triggered")
alertcondition(isBullOB or isBearOB, "Order Block",         "CirisAshley: ORDER BLOCK detected")
alertcondition(fvgUp,           "FVG Up",                   "CirisAshley: FAIR VALUE GAP UP detected")
alertcondition(fvgDown,         "FVG Down",                 "CirisAshley: FAIR VALUE GAP DOWN detected")
alertcondition(orb15_bullBreak, "NY 15M ORB Bull Break",    "CirisAshley: NY 15M ORB BULLISH BREAKOUT")
alertcondition(orb15_bearBreak, "NY 15M ORB Bear Break",    "CirisAshley: NY 15M ORB BEARISH BREAKDOWN")
alertcondition(orb30_bullBreak, "NY 30M ORB Bull Break",    "CirisAshley: NY 30M ORB BULLISH BREAKOUT")
alertcondition(orb30_bearBreak, "NY 30M ORB Bear Break",    "CirisAshley: NY 30M ORB BEARISH BREAKDOWN")
alertcondition(lon15_bullBreak, "London 15M ORB Bull Break","CirisAshley: LONDON 15M ORB BULLISH BREAKOUT")
alertcondition(lon15_bearBreak, "London 15M ORB Bear Break","CirisAshley: LONDON 15M ORB BEARISH BREAKDOWN")
alertcondition(lon30_bullBreak, "London 30M ORB Bull Break","CirisAshley: LONDON 30M ORB BULLISH BREAKOUT")
alertcondition(lon30_bearBreak, "London 30M ORB Bear Break","CirisAshley: LONDON 30M ORB BEARISH BREAKDOWN")
alertcondition(asia15_bullBreak,"Asia 15M ORB Bull Break",  "CirisAshley: ASIA 15M ORB BULLISH BREAKOUT")
alertcondition(asia15_bearBreak,"Asia 15M ORB Bear Break",  "CirisAshley: ASIA 15M ORB BEARISH BREAKDOWN")
alertcondition(asia30_bullBreak,"Asia 30M ORB Bull Break",  "CirisAshley: ASIA 30M ORB BULLISH BREAKOUT")
alertcondition(asia30_bearBreak,"Asia 30M ORB Bear Break",  "CirisAshley: ASIA 30M ORB BEARISH BREAKDOWN")
alertcondition(liq_sweepBull,   "Liquidity Sweep Bull",     "CirisAshley: BULLISH LIQUIDITY SWEEP — possible long entry")
alertcondition(liq_sweepBear,   "Liquidity Sweep Bear",     "CirisAshley: BEARISH LIQUIDITY SWEEP — possible short entry")
alertcondition(pure_bos_bull,   "BOS Bullish",              "CirisAshley: BREAK OF STRUCTURE — Bullish continuation")
alertcondition(pure_bos_bear,   "BOS Bearish",              "CirisAshley: BREAK OF STRUCTURE — Bearish continuation")
alertcondition(choch_bull,      "CHoCH Bullish",            "CirisAshley: CHANGE OF CHARACTER — Bullish reversal signal")
alertcondition(choch_bear,      "CHoCH Bearish",            "CirisAshley: CHANGE OF CHARACTER — Bearish reversal signal")
alertcondition(sniperBuy,       "Sniper Buy",               "CirisAshley: SNIPER BUY — Range floor entry")
alertcondition(sniperSell,      "Sniper Sell",              "CirisAshley: SNIPER SELL — Range ceiling entry")
alertcondition(rangeBreakUp,    "Range Break Up",           "CirisAshley: RANGE BREAKOUT UP — Trend mode beginning")
alertcondition(rangeBreakDown,  "Range Break Down",         "CirisAshley: RANGE BREAKOUT DOWN — Trend mode beginning")
````
