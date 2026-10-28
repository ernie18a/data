# OT MTF Trend Dashboard 1.0

- url: https://www.tradingview.com/script/8xpHZsTe/
- type: indicator
- pine_id: PUB;d43fa61404284323bd38d0dc15593477
- version: 1.0

## Description

OT MTF Trend Dashboard 1.0, is a sophisticated trend-following system designed to filter out "market noise" and focus on high-probability entries by aligning multiple technical factors across various timeframes.

Here is a breakdown of its logic and how to trade with it.

1. The Core Components (The Logic)
The script relies on a "triple-filter" logic to generate signals:

A. OT Bot (Sensitivity Filter)
This is a custom volatility-based trailing stop (similar to a Supertrend). It uses a "Key Value" (Sensitivity) and ATR to determine the immediate trend direction.

Heikin Ashi Option: It can use Heikin Ashi candles to smooth out price action, reducing "fake-outs."

SMA 17: A yellow Simple Moving Average acts as a secondary visual baseline for the short-term trend.

B. Supertrend (Main Trend Filter)
This acts as the "Master Trend." For a signal to be valid:

Buy signals only occur when the Supertrend is in a Bullish state (Price above the line).

Sell signals only occur when the Supertrend is in a Bearish state (Price below the line).

C. ADX Filter (Strength Filter)
The Average Directional Index (ADX) measures trend strength, not direction.

Active Range: The script only triggers signals when the ADX is between 15 and 45.

Logic: If ADX < 15, the market is too flat (choppy). If ADX > 45, the trend might be overextended and due for a reversal.

2. The Multi-Timeframe (MTF) Dashboard
The table on your screen is a Confirmation Hub. It looks at timeframes from 1 minute (1m) to 1 week (1W) using the following logic:

Trend Column: Uses EMA 20 and EMA 50 crossovers combined with price slope.

Green (Up): Fast EMA > Slow EMA + Positive Slope.

Red (Down): Fast EMA < Slow EMA + Negative Slope.

Gray (Side): No clear trend or low momentum.

ADX Column: Shows the trend strength for each specific timeframe.

Green: Trending (15–45).

Red: Not trending (below 15 or above 45).

3. How to Trade with this Indicator
Buying Strategy (Long)
Wait for the 'Buy' Label: This appears when the OT Bot flips bullish, the Supertrend is already bullish, and the ADX is in the "Goldilocks" zone (15–45).

Dashboard Confirmation: Look at the MTF Dashboard. Ideally, the AVG (Average) row and the timeframes higher than your current chart should be Green (Up).

Entry: Enter on the close of the candle where the "Buy" label appears.

Stop Loss: Place your stop loss slightly below the Supertrend Line or the OT Trailing Stop line.

Selling Strategy (Short)
Wait for the 'Sell' Label: This appears when the OT Bot flips bearish, the Supertrend is already bearish, and ADX is between 15–45.

Dashboard Confirmation: Ensure the MTF Dashboard shows Red (Down) on higher timeframes and the AVG row.

Entry: Enter on the close of the candle where the "Sell" label appears.

Stop Loss: Place your stop loss slightly above the Supertrend Line.

4. Pro-Tips for Success
The Power of "AVG": Never trade against the AVG Trend on the dashboard. If you are on a 5m chart but the AVG Trend is "Down," skip the "Buy" signals.

Confluence is King: The best trades happen when the Trend color and the ADX color on the dashboard are both Green across multiple timeframes.

Avoid "Side" Markets: If the dashboard is mostly Gray (Side), the market is ranging. This is where most trend-following indicators lose money. Wait for the dashboard to show a clear direction.

Yellow Line (SMA 17): Use this as a trailing exit. If price closes significantly on the "wrong" side of the yellow line, it may be time to take profits before the main signal flips.

## Source Code

````pine
//@version=6
indicator("OT MTF Trend Dashboard 1.0", overlay=true, max_labels_count=500)
 
// ==========================================
// ส่วนที่ 1: ADX Filter
// ==========================================
adx_len = input.int(14, title="ADX Smoothing", group="ADX Filter")
di_len  = input.int(14, title="DI Length",     group="ADX Filter")
adx_min = input.int(15, title="ADX Min (Trending)", group="ADX Filter")
adx_max = input.int(45, title="ADX Max (Trending)", group="ADX Filter")
[plusDI, minusDI, adxValue] = ta.dmi(di_len, adx_len)
is_trend_active = adxValue >= adx_min and adxValue <= adx_max
 
// ==========================================
// ส่วนที่ 2: OT Bot Supertrend Calculation
// ==========================================
a          = input.float(3.0, title="OT Bot Key Value (Sensitivity)", group="OT Bot")
c          = input.int(1,     title="OT Bot ATR Period",              group="OT Bot")
h          = input.bool(true, title="OT Bot: Signals from Heikin Ashi Candles", group="OT Bot")
sma_length = input.int(17,    title="SMA 17 Length", group="OT Bot")
 
ha_ticker = ticker.heikinashi(syminfo.tickerid)
ha_close  = request.security(ha_ticker, timeframe.period, close)
src_ot    = h ? ha_close : close
 
xATR_ot  = ta.atr(c)
nLoss_ot = a * xATR_ot
 
var float xATRTrailingStop = 0.0
xATRTrailingStop := src_ot > nz(xATRTrailingStop[1], 0) and src_ot[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), src_ot - nLoss_ot) : src_ot < nz(xATRTrailingStop[1], 0) and src_ot[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), src_ot + nLoss_ot) : src_ot > nz(xATRTrailingStop[1], 0) ? src_ot - nLoss_ot : src_ot + nLoss_ot
 
// SMA 17 (Yellow Line)
sma17 = ta.sma(close, sma_length)
plot(sma17, color=color.yellow, title="SMA 17", linewidth=2)
 
// ==========================================
// ส่วนที่ 3: Supertrend (Filter หลัก)
// ==========================================
st_atr_length = input.int(8,   title="Supertrend ATR Length", group="Supertrend")
st_factor     = input.float(2.0, title="Supertrend Factor",   group="Supertrend")
[supertrend, direction] = ta.supertrend(st_factor, st_atr_length)
plot(supertrend, title="Supertrend Line", color=direction < 0 ? color.rgb(12, 77, 241) : color.rgb(12, 77, 241), linewidth=1, style=plot.style_linebr)
 
// ==========================================
// ส่วนที่ 4: Signal Logic
// ==========================================
ema1  = ta.ema(src_ot, 1)
above = ta.crossover(ema1, xATRTrailingStop)
below = ta.crossunder(ema1, xATRTrailingStop)
 
buy_consistent  = (src_ot > xATRTrailingStop and above) and (direction < 0)
sell_consistent = (src_ot < xATRTrailingStop and below) and (direction > 0)
 
buy_final  = buy_consistent  and is_trend_active
sell_final = sell_consistent and is_trend_active
 
plotshape(buy_final,  title="OT Buy",  text='Buy',  style=shape.labelup,   location=location.belowbar, color=color.rgb(34, 130, 6),   textcolor=color.white, size=size.tiny)
plotshape(sell_final, title="OT Sell", text='Sell', style=shape.labeldown, location=location.abovebar, color=color.rgb(230, 23, 23), textcolor=color.white, size=size.tiny)
 
barcolor(src_ot > xATRTrailingStop ? color.rgb(34, 130, 6) : color.rgb(230, 23, 23))
 
// ==========================================
// ส่วนที่ 5: MULTI-TIMEFRAME TREND DASHBOARD ⭐
//   - Trend cell (เขียว/แดง/เทา) ตามสถานะ Up/Down/Side
//   - ADX cell  (เขียว/แดง)     ตามว่า Trending (15-45) หรือไม่
// ==========================================
showTrendTable = input.bool(true, title="Show Trend Dashboard", group="Trend Dashboard")
trendTablePos  = input.string("top_right", title="Position",
     options=["top_right","middle_right","bottom_right","top_left","middle_left","bottom_left"], group="Trend Dashboard")
showADXCol     = input.bool(true, title="Show ADX Column", group="Trend Dashboard")
 
// --- ค่าสี
cBuy   = color.new(#16de0f, 0)     // เขียว Up / ADX trending
cSell  = color.new(#e01d1a, 0)     // แดง Down / ADX ไม่ trending
cSide  = color.new(#9e9e9e, 0)     // เทา Side
cHead  = color.new(#1e1e1e, 0)
cText  = color.white
cTFbg  = color.new(#2a2a2a, 0)
 
// --- ฟังก์ชันคำนวณเทรนด์ + ADX ของแต่ละ TF
get_trend_adx(string tf) =>
    [c_, h_, l_] = request.security(syminfo.tickerid, tf, [close, high, low], lookahead=barmerge.lookahead_off)
    ema_fast = request.security(syminfo.tickerid, tf, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
    ema_slow = request.security(syminfo.tickerid, tf, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
    [_p, _m, adxV] = request.security(syminfo.tickerid, tf, ta.dmi(di_len, adx_len), lookahead=barmerge.lookahead_off)
 
    ema_fast_prev = request.security(syminfo.tickerid, tf, ta.ema(close, 20)[3], lookahead=barmerge.lookahead_off)
    slope = ema_fast - ema_fast_prev
 
    diff_pct = math.abs(ema_fast - ema_slow) / c_ * 100
 
    is_up   = ema_fast > ema_slow and slope > 0 and diff_pct > 0.05 and adxV >= adx_min
    is_down = ema_fast < ema_slow and slope < 0 and diff_pct > 0.05 and adxV >= adx_min
    trend = is_up ? "Up" : is_down ? "Down" : "Side"
    [trend, adxV]
 
// --- ดึงค่าทุก timeframe
[t1m,  adx1m]  = get_trend_adx("1")
[t5m,  adx5m]  = get_trend_adx("5")
[t15m, adx15m] = get_trend_adx("15")
[t1h,  adx1h]  = get_trend_adx("60")
[t4h,  adx4h]  = get_trend_adx("240")
[t1d,  adx1d]  = get_trend_adx("D")
[t1w,  adx1w]  = get_trend_adx("W")
 
// --- โหวต AVG
score(string t) => t == "Up" ? 1 : t == "Down" ? -1 : 0
total_score = score(t1m) + score(t5m) + score(t15m) + score(t1h) + score(t4h) + score(t1d) + score(t1w)
avg_trend   = total_score >= 2 ? "Up" : total_score <= -2 ? "Down" : "Side"
avg_adx     = (adx1m + adx5m + adx15m + adx1h + adx4h + adx1d + adx1w) / 7
 
// --- ตำแหน่งตาราง
tablePos = trendTablePos == "top_right"     ? position.top_right     :
           trendTablePos == "middle_right"  ? position.middle_right  :
           trendTablePos == "bottom_right"  ? position.bottom_right  :
           trendTablePos == "top_left"      ? position.top_left      :
           trendTablePos == "middle_left"   ? position.middle_left   :
                                              position.bottom_left
 
n_cols = showADXCol ? 3 : 2
var table trendTable = table.new(tablePos, n_cols, 9, border_width=1, border_color=color.new(color.black, 50))
 
// helper
trend_bg(string t) => t == "Up" ? cBuy : t == "Down" ? cSell : cSide
adx_bg(float v)    => (v >= adx_min and v <= adx_max) ? cBuy : cSell   // ⭐ เขียว/แดง ตามค่า ADX
 
if barstate.islast and showTrendTable
    // -- Header --
    table.cell(trendTable, 0, 0, "TREND", bgcolor=cHead, text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 0, "TF",    bgcolor=cHead, text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 0, "ADX", bgcolor=cHead, text_color=cText, text_size=size.normal)
 
    // -- 1m --
    table.cell(trendTable, 0, 1, t1m,  bgcolor=trend_bg(t1m),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 1, "1m", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 1, str.tostring(adx1m, "#.#"), bgcolor=adx_bg(adx1m), text_color=cText)
 
    // -- 5m --
    table.cell(trendTable, 0, 2, t5m,  bgcolor=trend_bg(t5m),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 2, "5m", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 2, str.tostring(adx5m, "#.#"), bgcolor=adx_bg(adx5m), text_color=cText)
 
    // -- 15m --
    table.cell(trendTable, 0, 3, t15m,  bgcolor=trend_bg(t15m), text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 3, "15m", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 3, str.tostring(adx15m, "#.#"), bgcolor=adx_bg(adx15m), text_color=cText)
 
    // -- 1H --
    table.cell(trendTable, 0, 4, t1h,  bgcolor=trend_bg(t1h),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 4, "1H", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 4, str.tostring(adx1h, "#.#"), bgcolor=adx_bg(adx1h), text_color=cText)
 
    // -- 4H --
    table.cell(trendTable, 0, 5, t4h,  bgcolor=trend_bg(t4h),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 5, "4H", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 5, str.tostring(adx4h, "#.#"), bgcolor=adx_bg(adx4h), text_color=cText)
 
    // -- 1D --
    table.cell(trendTable, 0, 6, t1d,  bgcolor=trend_bg(t1d),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 6, "1D", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 6, str.tostring(adx1d, "#.#"), bgcolor=adx_bg(adx1d), text_color=cText)
 
    // -- 1W --
    table.cell(trendTable, 0, 7, t1w,  bgcolor=trend_bg(t1w),  text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 7, "1W", bgcolor=cTFbg,          text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 7, str.tostring(adx1w, "#.#"), bgcolor=adx_bg(adx1w), text_color=cText)
 
    // -- AVG --
    table.cell(trendTable, 0, 8, avg_trend, bgcolor=trend_bg(avg_trend), text_color=cText, text_size=size.normal)
    table.cell(trendTable, 1, 8, "AVG",     bgcolor=cHead,                text_color=cText, text_size=size.normal)
    if showADXCol
        table.cell(trendTable, 2, 8, str.tostring(avg_adx, "#.#"), bgcolor=adx_bg(avg_adx), text_color=cText)
 
// ==========================================
// ส่วนที่ 6: Alerts
// ==========================================
alertcondition(buy_final,  title="OT Buy Signal",  message="OT Bot: BUY signal {{ticker}} @ {{close}}")
alertcondition(sell_final, title="OT Sell Signal", message="OT Bot: SELL signal {{ticker}} @ {{close}}")
````
