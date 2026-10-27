# Autobot Terminal v6 - FIXED

- url: https://www.tradingview.com/script/2MDX3PV1-Autobot-Terminal-v6-FIXED/
- type: indicator
- pine_id: PUB;e5b7eb09f4424f498fbb9e130512abe3
- version: 1.0

## Description

AUTOBOT TERMINAL v6 – Professional Smart Money Trading System

AUTOBOT TERMINAL v6 ek advanced multi-timeframe trading system hai jo Smart Money Concepts, VWAP confirmation aur higher timeframe trend filtering ko combine karta hai.

Ye indicator specially crypto, forex aur indices trading ke liye design kiya gaya hai jisme low-quality trades ko filter karke high-probability setups identify kiye jaate hain.

Core Features

• Daily 200 SMA Macro Trend Filter
• 4H Smart Support & Resistance Detection
• Previous Day High / Low Liquidity Levels
• 1H Candle Confirmation Engine
• VWAP Entry Confirmation
• Auto Buy / Sell Signal Detection
• Smart Stop Loss & Target Calculation
• Auto Risk-to-Reward Management
• Live Trade Level Plotting
• Professional Real-Time Dashboard
• Non-Repainting Structure
• Session-Based Trade Filtering

Trading Logic

LONG Trades:

- Market Daily 200 SMA ke above hona chahiye
- Price support zone me hona chahiye
- 1H bullish confirmation required
- VWAP crossover confirmation

SHORT Trades:

- Market Daily 200 SMA ke below hona chahiye
- Price resistance zone me hona chahiye
- 1H bearish confirmation required
- VWAP crossunder confirmation

Dashboard Features

Dashboard automatically show karta hai:

- Current Market Trend
- Active Trade Status
- Entry Price
- Stop Loss
- Target Levels
- Session Status
- Zone Detection

Recommended Timeframes

Execution Timeframe:

- 5 Minutes
- 15 Minutes

Confirmation Timeframes:

- 1 Hour
- 4 Hour
- Daily

Best Markets

- BTCUSD
- ETHUSD
- XAUUSD
- NAS100
- US30
- EURUSD

Important Notes

- Indicator non-repainting structure use karta hai
- Higher timeframe confirmation required hai
- Sideways market me signals avoid kare
- Proper risk management mandatory hai
- Best results trending markets me milte hain

Developed for professional multi-timeframe execution and institutional-style trading analysis.

## Source Code

````pine
//@version=5
indicator("Autobot Terminal v6 - FIXED", overlay=true, max_labels_count=500, max_lines_count=500)

// ==================== TIME WINDOW ====================
session_input = input.session("0700-1800", title="IST Allowed Trade Session")
user_name     = input.string("@santoshpsiii", title="Trader Identity")

in_session = not na(time(timeframe.period, session_input))

// ==================== DAILY TREND FILTER ====================
dailySmaVal = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(close, 200),
     barmerge.gaps_off,
     barmerge.lookahead_off)

macro_bullish = close > dailySmaVal
macro_bearish = close < dailySmaVal

plot(dailySmaVal, title="Daily 200 SMA", color=color.blue, linewidth=2)

// ==================== PREVIOUS DAY LEVELS ====================
pdh_val = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

pdl_val = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

plot(pdh_val, title="Prev Day High", color=color.orange, linewidth=1)
plot(pdl_val, title="Prev Day Low", color=color.aqua, linewidth=1)

// ==================== 4H SUPPORT / RESISTANCE ====================
ph_4h_raw = request.security(
     syminfo.tickerid,
     "240",
     ta.pivothigh(high, 10, 10),
     barmerge.gaps_off,
     barmerge.lookahead_off)

pl_4h_raw = request.security(
     syminfo.tickerid,
     "240",
     ta.pivotlow(low, 10, 10),
     barmerge.gaps_off,
     barmerge.lookahead_off)

var float res_4h = na
var float sup_4h = na

if not na(ph_4h_raw)
    res_4h := ph_4h_raw

if not na(pl_4h_raw)
    sup_4h := pl_4h_raw

// ==================== 1H CONFIRMATION ====================
h1_open = request.security(
     syminfo.tickerid,
     "60",
     open[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

h1_close = request.security(
     syminfo.tickerid,
     "60",
     close[1],
     barmerge.gaps_off,
     barmerge.lookahead_off)

// ==================== VWAP ====================
vwapVal = ta.vwap(close)
plot(vwapVal, color=color.purple, title="VWAP", linewidth=2)

// ==================== ZONE LOGIC ====================
at_support_zone =
     (not na(sup_4h) and close >= sup_4h and close <= sup_4h * 1.01) or
     (not na(pdl_val) and close >= pdl_val and close <= pdl_val * 1.01)

at_resistance_zone =
     (not na(res_4h) and close <= res_4h and close >= res_4h * 0.99) or
     (not na(pdh_val) and close <= pdh_val and close >= pdh_val * 0.99)

// ==================== CONFIRMATION ====================
h1_bearish_confirm =
     h1_close < h1_open or
     (not na(pdl_val) and h1_close < pdl_val)

h1_bullish_confirm =
     h1_close > h1_open or
     (not na(sup_4h) and h1_close > sup_4h)

// ==================== SIGNALS ====================
short_trigger =
     in_session and
     macro_bearish and
     at_resistance_zone and
     h1_bearish_confirm and
     ta.crossunder(close, vwapVal)

buy_trigger =
     in_session and
     macro_bullish and
     at_support_zone and
     h1_bullish_confirm and
     ta.crossover(close, vwapVal)

whale_trigger =
     in_session and
     macro_bearish and
     at_support_zone and
     ta.crossover(close, vwapVal)

// ==================== TRADE MANAGEMENT ====================
var float entry_p = na
var float sl_p = na
var float tg1_p = na
var float tg2_p = na

var string current_trade = "NONE"

// SHORT ENTRY
if short_trigger and current_trade == "NONE"

    entry_p := close

    active_res =
         not na(res_4h) ? res_4h :
         not na(pdh_val) ? pdh_val :
         close

    sl_p := active_res * 1.005

    risk = sl_p - entry_p

    tg1_p := entry_p - (risk * 1.5)
    tg2_p := entry_p - (risk * 3.0)

    current_trade := "SHORT"

// LONG ENTRY
if (buy_trigger or whale_trigger) and current_trade == "NONE"

    entry_p := close

    active_sup =
         not na(sup_4h) ? sup_4h :
         not na(pdl_val) ? pdl_val :
         close

    sl_p := active_sup * 0.995

    risk = entry_p - sl_p

    tg1_p := entry_p + (risk * 1.5)
    tg2_p := entry_p + (risk * 3.0)

    current_trade := buy_trigger ? "LONG" : "WHALE LONG"

// ==================== EXIT SYSTEM ====================
if current_trade == "SHORT"

    if low <= tg2_p or high >= sl_p

        current_trade := "NONE"
        entry_p := na
        sl_p := na
        tg1_p := na
        tg2_p := na

if current_trade == "LONG" or current_trade == "WHALE LONG"

    if high >= tg2_p or low <= sl_p

        current_trade := "NONE"
        entry_p := na
        sl_p := na
        tg1_p := na
        tg2_p := na

// ==================== SIGNAL PLOTS ====================
plotshape(
     short_trigger and current_trade == "SHORT",
     title="SHORT",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL")

plotshape(
     buy_trigger and current_trade == "LONG",
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="BUY")

plotshape(
     whale_trigger and current_trade == "WHALE LONG",
     title="WHALE",
     style=shape.circle,
     location=location.belowbar,
     color=color.yellow,
     size=size.small,
     text="W")

// ==================== LIVE LEVELS ====================
plot(entry_p, title="Entry", color=color.white, style=plot.style_linebr)
plot(sl_p, title="SL", color=color.red, style=plot.style_linebr)
plot(tg1_p, title="TG1", color=color.orange, style=plot.style_linebr)
plot(tg2_p, title="TG2", color=color.green, style=plot.style_linebr)

// ==================== DASHBOARD ====================
var table bot_dash = table.new(
     position.top_right,
     2,
     8,
     bgcolor=color.new(color.black, 10),
     border_width=1)

if barstate.islast

    table.cell(bot_dash, 0, 0, "AUTOBOT v6")
    table.cell(bot_dash, 1, 0, user_name)

    table.cell(bot_dash, 0, 1, "Session")
    table.cell(bot_dash, 1, 1, in_session ? "ACTIVE" : "BLOCKED")

    table.cell(bot_dash, 0, 2, "Trend")
    table.cell(bot_dash, 1, 2, macro_bullish ? "BULLISH" : "BEARISH")

    zone_txt =
         at_support_zone ? "SUPPORT" :
         at_resistance_zone ? "RESISTANCE" :
         "NO TRADE"

    table.cell(bot_dash, 0, 3, "Zone")
    table.cell(bot_dash, 1, 3, zone_txt)

    table.cell(bot_dash, 0, 4, "Trade")
    table.cell(bot_dash, 1, 4, current_trade)

    table.cell(bot_dash, 0, 5, "Entry")
    table.cell(bot_dash, 1, 5, str.tostring(entry_p))

    table.cell(bot_dash, 0, 6, "SL")
    table.cell(bot_dash, 1, 6, str.tostring(sl_p))

    table.cell(bot_dash, 0, 7, "TG2")
    table.cell(bot_dash, 1, 7, str.tostring(tg2_p))
````
