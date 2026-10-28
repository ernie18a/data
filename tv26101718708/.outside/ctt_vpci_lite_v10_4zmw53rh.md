# CTT - VPCI Lite V1.0

- url: https://www.tradingview.com/script/4ZmW53rh-CTT-VPCI-Lite-V1-0/
- type: indicator
- pine_id: PUB;8a19dd8ed76e45668a5a03e57666a88f
- version: 1.0

## Description

CTT - VPCI Lite V1.0

A lightweight stats dashboard overlay that displays key volume, price, and momentum metrics directly on your chart in a clean, configurable table.

WHAT IT DOES

VPCI Lite gives you an at-a-glance view of the numbers that matter most during a trading session. All stats are displayed in a single table overlay on your chart — no separate pane needed.

CHG% — Session price change from yesterday's close.
RVOL — Relative Volume compared to a selectable historical average (1, 5, 10, 5+10 blend, or 21 day). Adjusted with a U-shape curve during regular hours so RVOL reads accurately throughout the session, not just at the close.
VOL — Current session volume, formatted with K/M/B abbreviations.
$VOL — Dollar Volume (price x volume). Shows how much capital is flowing through the ticker.
ADR — Average Daily Range as a percentage. Selectable between 14 or 20 period.
ATR — Average True Range in price points. Selectable between 14 or 20 period.
RSI — 14-period Relative Strength Index. Off by default, toggle on in settings.

COLOR CODING

Every metric is color-coded so you can read the table at a glance without parsing numbers:

Green — Bullish. Positive CHG%, high RVOL (1.5x+), up-candle volume, asset up on the day.
Red — Bearish. Negative CHG%, down-candle volume, asset down on the day.
Blue — Neutral-positive. RVOL at or above average (1.0x+).
Gray — Neutral or no data available.

RSI uses threshold coloring: green at oversold (30 or below), red at overbought (70 or above), yellow and blue for the zones in between.

ASSET PRICES

Optionally display daily change percentages or live prices for major assets directly in the stats table:

QQQ, SPY, DJI — Index change percentages, green/red by direction.
BTC, ETH — Crypto prices, green/red by daily change direction.
Each asset is individually toggleable.

SETTINGS

Stats Display — Toggle each metric on or off. Choose RVOL averaging period (1/5/10/5+10/21 day) and ADR/ATR periods (14 or 20).
Asset Prices — Toggle each asset ticker on or off.
Layout — Position the stats table anywhere on the chart (9 positions available).

HOW TO USE

Add the indicator to any chart. The stats table appears at your chosen position showing the metrics you've enabled. All data updates in real-time.
RVOL above 1.5x suggests heavy participation relative to recent sessions. RVOL below 0.5x suggests low-interest, choppy conditions. Use the asset price tickers to keep tabs on market context without flipping between charts.

MOBILE
Works on TradingView mobile. Position the table using the Layout setting to avoid overlapping chart controls on smaller screens. Bottom-right or top-right work best on most devices.

NOTES

This is the Lite edition. It focuses on clean, essential market stats without signals, profiles, or filters.
Works on any symbol and any timeframe — equities, futures, crypto, forex.
This indicator is a tool for monitoring market conditions — it is not financial advice. Always use proper risk management.

Published by Confluence Trading Tools LLC

## Source Code

````pine
//@version=6

indicator('CTT - VPCI Lite V1.0', shorttitle='CTT VPCI Lite', overlay=true, max_boxes_count=1)

grp_stats = '1. Stats Display'
showCHG  = input.bool(true, 'Show CHG%', group=grp_stats)
showRVOL = input.bool(true, 'Show RVOL', inline='rvol', group=grp_stats)
rvolMode = input.string('5 Day', '', options=['1 Day', '5 Day', '10 Day', '5+10 Day', '21 Day'], inline='rvol', group=grp_stats)
showVOL  = input.bool(true, 'Show Volume', group=grp_stats)
showDVOL = input.bool(true, 'Show Dollar Volume', group=grp_stats)
showRSI  = input.bool(false, 'Show RSI', group=grp_stats)
showADR  = input.bool(true, 'Show ADR', inline='adr', group=grp_stats)
adrPeriod = input.int(20, '', options=[14, 20], inline='adr', group=grp_stats)
showATR  = input.bool(true, 'Show ATR', inline='atr', group=grp_stats)
atrPeriod = input.int(14, '', options=[14, 20], inline='atr', group=grp_stats)

grp_assets = '2. Asset Prices'
showBTC = input.bool(false, 'Bitcoin (BTC)', group=grp_assets)
showETH = input.bool(false, 'Ethereum (ETH)', group=grp_assets)
showQQQ = input.bool(false, 'QQQ', group=grp_assets)
showSPY = input.bool(false, 'SPY', group=grp_assets)
showDJI = input.bool(false, 'DJI', group=grp_assets)

grp_layout = '3. Layout'
tablePos = input.string('bottom_right', 'Table Position', options=['top_left', 'top_center', 'top_right', 'middle_left', 'middle_center', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group=grp_layout)

var color c_bull = color.new(color.green, 0)
var color c_bear = color.new(color.red, 0)
var color c_label = color.gray
var color c_neutral = color.gray
var color tableBg = color.new(#03243e, 90)

formatNum(num) =>
    if na(num)
        '-'
    else if num >= 1e9
        str.tostring(num / 1e9, '#.##') + 'B'
    else if num >= 1e6
        str.tostring(num / 1e6, '#.##') + 'M'
    else if num >= 1e3
        str.tostring(num / 1e3, '#.##') + 'K'
    else
        str.tostring(num, '#.##')

f_sm_minus(txt) => str.replace_all(txt, '-', '⁻')
formatRvol(num) => na(num) ? '-' : str.tostring(num, '#.##') + 'x'

type DailyMetrics
    int   dTime
    float dClose
    float dVolume
    float dHigh
    float dLow
    float prevClose
    float atr
    float volPrev
    float volAvg5
    float volAvg10
    float volAvg21

f_daily_data(int atrLen) =>
    DailyMetrics.new(time, close, volume, high, low, close[1], ta.atr(atrLen), volume[1], ta.sma(volume, 5)[1], ta.sma(volume, 10)[1], ta.sma(volume, 21)[1])

dailyData = request.security(syminfo.tickerid, 'D', f_daily_data(atrPeriod), lookahead=barmerge.lookahead_off)

dailyTime    = na(dailyData) ? int(na)   : dailyData.dTime
dailyClose   = na(dailyData) ? float(na) : dailyData.dClose
dailyVolume  = na(dailyData) ? float(na) : dailyData.dVolume
dailyHigh    = na(dailyData) ? float(na) : dailyData.dHigh
dailyLow     = na(dailyData) ? float(na) : dailyData.dLow
prevDayClose = na(dailyData) ? float(na) : dailyData.prevClose
dailyATR     = na(dailyData) ? float(na) : dailyData.atr
dailyVolPrev = na(dailyData) ? float(na) : dailyData.volPrev
dailyVolAvg5 = na(dailyData) ? float(na) : dailyData.volAvg5
dailyVolAvg10 = na(dailyData) ? float(na) : dailyData.volAvg10
dailyVolAvg21 = na(dailyData) ? float(na) : dailyData.volAvg21

bool isRegularHours = timeframe.isintraday and not na(time('', '0930-1600', syminfo.timezone))

int session_minutes = math.max(0, (hour * 60 + minute) - (9 * 60 + 30))
float session_progress = math.max(0.01, math.min(1.0, session_minutes / 390.0))
float uShape = math.min(1.0, session_progress + 0.15 * math.sin(session_progress * math.pi))

bool isDailyDataFromToday = dayofmonth(dailyTime) == dayofmonth(time)
float fixedPrevClose = isDailyDataFromToday ? prevDayClose : dailyClose
float priceChange = (not na(fixedPrevClose) and fixedPrevClose != 0) ? (close - fixedPrevClose) / fixedPrevClose * 100 : 0.0

float volAvg5w  = isRegularHours ? dailyVolAvg5 * uShape : dailyVolAvg5
float volAvg10w = isRegularHours ? dailyVolAvg10 * uShape : dailyVolAvg10
float volAvg21w = isRegularHours ? dailyVolAvg21 * uShape : dailyVolAvg21

rvol_1d = (na(dailyVolPrev) or dailyVolPrev <= 0) ? na : dailyVolume / dailyVolPrev
rvol_5d = (na(volAvg5w) or volAvg5w <= 0) ? na : dailyVolume / volAvg5w
rvol_10d = (na(volAvg10w) or volAvg10w <= 0) ? na : dailyVolume / volAvg10w
rvol_21d = (na(volAvg21w) or volAvg21w <= 0) ? na : dailyVolume / volAvg21w
rvol_5_10 = na(rvol_5d) or na(rvol_10d) ? nz(rvol_5d, rvol_10d) : rvol_5d * 0.6 + rvol_10d * 0.4
rvolValue = rvolMode == '1 Day' ? rvol_1d : rvolMode == '5 Day' ? rvol_5d : rvolMode == '10 Day' ? rvol_10d : rvolMode == '5+10 Day' ? rvol_5_10 : rvol_21d

float dailyRangePct = (na(fixedPrevClose) or fixedPrevClose <= 0) ? na : (dailyHigh - dailyLow) / fixedPrevClose * 100
float adr = showADR ? ta.sma(dailyRangePct, adrPeriod) : na

float rsi14 = showRSI ? ta.rsi(close, 14) : na

[qqq_c, qqq_p] = request.security(showQQQ ? 'QQQ' : '', 'D', [close, close[1]], ignore_invalid_symbol=true)
[spy_c, spy_p] = request.security(showSPY ? 'SPY' : '', 'D', [close, close[1]], ignore_invalid_symbol=true)
[dji_c, dji_p] = request.security(showDJI ? 'DJI' : '', 'D', [close, close[1]], ignore_invalid_symbol=true)
[btc_c, btc_p] = request.security(showBTC ? 'COINBASE:BTCUSD' : '', 'D', [close, close[1]], ignore_invalid_symbol=true)
[eth_c, eth_p] = request.security(showETH ? 'COINBASE:ETHUSD' : '', 'D', [close, close[1]], ignore_invalid_symbol=true)

f_pct(c, p) => (not na(c) and not na(p) and p > 0) ? (c - p) / p * 100 : na

qqqChg = f_pct(qqq_c, qqq_p)
spyChg = f_pct(spy_c, spy_p)
djiChg = f_pct(dji_c, dji_p)
btcChg = f_pct(btc_c, btc_p)
ethChg = f_pct(eth_c, eth_p)

var table tbl = table.new(tablePos, 15, 3, border_width=1, frame_color=color.new(#03243e, 10))

if barstate.islast
    table.clear(tbl, 0, 0, 14, 2)
    int col = 0

    if showCHG
        color chgCol = priceChange > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'CHG%', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(priceChange) ? '-' : f_sm_minus(str.tostring(priceChange, '#.##') + '%'), text_color=chgCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showRVOL
        color rvolCol = na(rvolValue) ? c_neutral : rvolValue >= 1.5 ? c_bull : rvolValue >= 1.0 ? color.new(#2962FF, 0) : c_label
        table.cell(tbl, col, 0, 'RVOL', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, formatRvol(rvolValue), text_color=rvolCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showVOL
        color volCol = close >= open ? c_bull : c_bear
        table.cell(tbl, col, 0, 'VOL', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, formatNum(dailyVolume), text_color=volCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showDVOL
        float dv = dailyVolume * close
        color dvCol = close >= open ? c_bull : c_bear
        table.cell(tbl, col, 0, '$VOL', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, formatNum(dv), text_color=dvCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showADR
        table.cell(tbl, col, 0, 'ADR', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(adr) ? '-' : str.tostring(math.round(adr)) + '%', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showATR
        table.cell(tbl, col, 0, 'ATR', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(dailyATR) ? '-' : str.tostring(dailyATR, '#.##'), text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showRSI
        color rsiCol = na(rsi14) ? c_neutral : rsi14 >= 70 ? c_bear : rsi14 <= 30 ? c_bull : rsi14 >= 55 ? color.new(color.yellow, 0) : rsi14 <= 45 ? color.new(#2962FF, 0) : c_neutral
        table.cell(tbl, col, 0, 'RSI', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(rsi14) ? '-' : str.tostring(rsi14, '#'), text_color=rsiCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showQQQ
        color qCol = na(qqqChg) ? c_neutral : qqqChg > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'QQQ', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(qqqChg) ? '-' : f_sm_minus(str.tostring(qqqChg, '#.##') + '%'), text_color=qCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showSPY
        color sCol = na(spyChg) ? c_neutral : spyChg > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'SPY', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(spyChg) ? '-' : f_sm_minus(str.tostring(spyChg, '#.##') + '%'), text_color=sCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showDJI
        color dCol = na(djiChg) ? c_neutral : djiChg > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'DJI', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(djiChg) ? '-' : f_sm_minus(str.tostring(djiChg, '#.##') + '%'), text_color=dCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showBTC
        color bCol = na(btcChg) ? c_neutral : btcChg > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'BTC', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(btc_c) ? '-' : formatNum(btc_c), text_color=bCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    if showETH
        color eCol = na(ethChg) ? c_neutral : ethChg > 0 ? c_bull : c_bear
        table.cell(tbl, col, 0, 'ETH', text_color=c_label, bgcolor=tableBg, text_size=size.normal)
        table.cell(tbl, col, 1, na(eth_c) ? '-' : formatNum(eth_c), text_color=eCol, bgcolor=tableBg, text_size=size.normal)
        col += 1

    table.cell(tbl, 0, 2, ' ', text_size=size.normal, bgcolor=color.new(color.black, 100))
````
