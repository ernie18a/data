# GreenStar ATR & Trend Strength Screener

- url: https://www.tradingview.com/script/DTJ5b2uB-GreenStar-ATR-Trend-Strength-Screener/
- type: indicator
- pine_id: PUB;4f345f854bae42f0b40fb710fe1b51c3
- version: 7.0

## Description

[b]GreenStar ATR & Trend Strength Screener[/b]

Pine Screener filter script. No chart plots.

Sorting a watchlist often mixes three different checks:

1) Daily trend structure (Minervini-style template rules)
2) ATR-normalized stretch from the 50-day MA
3) Session pace and distance from the low

This script puts those in one scan. MM and xFrom50 come from a single daily data pull per symbol. RVAT and %from LoD run on the screener chart interval. Chg % and Chg Open % round out the daily bar.


[b]Why one script[/b]

These seven columns are the ones I check every day before touching a name.
One script puts all seven on the same row. Daily columns share one request.security call to stay inside Pine Screener's five-call limit.


[b]Columns[/b]

[b]MM[/b] (0 to 8)
Minervini trend template score. One point per rule when true:
1) Close above 150 SMA and 200 SMA
2) 150 SMA above 200 SMA
3) 200 SMA rising vs 22 bars ago
4) 50 SMA above 150 and 200
5) Close above 50 SMA
6) At least 25% above 260-bar low
7) Within 25% of 260-bar high
8) Weighted price momentum composite above 70

Rule 8 uses a price-momentum composite, not an IBD RS rating.

[b]xFrom50[/b] (signed decimal)
Extension from the 50-day SMA in ATR multiples:
% gain from 50 SMA = (close - 50 SMA) / 50 SMA x 100
ATR % = 14-day ATR / close x 100
xFrom50 = % gain / ATR %
Positive = above the MA. Negative = below.

[b]ATR %[/b]
14-day ATR as percent of price. Denominator for xFrom50; also useful on its own for quiet vs volatile names.

[b]RVAT[/b]
Relative Volume at Time (10 sessions, daily anchor). 1.0 = average pace for this clock time. Needs a 5-minute screener interval for intraday session math.

[b]%from LoD[/b] (integer)
(close - session low) / 14-day ATR x 100
0.6 ATR above the low prints as 60. Filter less than 60 to stay near the low.

[b]Chg %[/b]: change vs prior daily close (forming bar on intraday runs).

[b]Chg Open %[/b]: change from today's open to current price.


[b]Pine Screener setup[/b]

1. Favorite the script in Indicators (required for the screener picker).
2. Open Pine Screener, pick a watchlist.
3. Add this script as a filter source.
4. Set interval to 5 minutes for RVAT and %from LoD.
5. Enable columns in the column picker, then sort or filter.

Only columns from added filter scripts appear. Built-in screener filters cannot run in the same pass.

When publishing, use a clean chart with no other scripts on it. This script will not show plots on the chart.


[b]Limitations[/b]

No visible plots on a normal chart. RVAT and %from LoD need a 5-minute screener interval and an active session. Built-in screener filters cannot run in the same pass. Daily columns follow the forming daily bar on intraday runs.


[b]Filter examples[/b]

MM ≥ 6
xFrom50 between 2 and 6
ATR % between 4 and 10
RVAT > 1.2
%from LoD < 60

Daily columns use the forming daily bar on intraday runs (lookahead_off, no repainting). If a column is missing, check the column picker first.


[b]Credits[/b]

MM column: eight trend-template criteria adapted from Minervini Trend Template by yogy.frestarahmawan (Mozilla Public License 2.0).

RVAT: TradingView ta.relativeVolume built-in library.


[b]Disclaimer[/b]

Screening tool only. Not a signal, not financial advice. No entry or exit triggers. Past scan results do not predict future price action.

## Source Code

````pine
//@version=6
// Pine Screener columns only (no chart visuals)
// Credits: MM criteria adapted from Minervini Trend Template by yogy.frestarahmawan (MPL 2.0)
// 3 request.* calls (daily bundle + SPY + LoD 1m lower_tf); RelVol At Time on chart TF; limit is 5
// STS + VCPT match GS2 HUD defaults; no extra request.* (reuse daily close + existing SPY)
indicator("GreenStar ATR & Trend Strength Screener", shorttitle="GS2 ATR Screen", overlay=false)
import TradingView/ta/7

// Keep in sync with GS2 HUD STS & VCP input defaults
STS_LOOKBACK = 25
VCP_LEN = 5
VCP_ADR_LEN = 20
VCP_BASELINE = 50
XFROM50_MAX_LOOKBACK = 65

dailyMetricsBundle() =>
    c = close
    o = open
    sma50 = ta.sma(c, 50)
    sma150 = ta.sma(c, 150)
    sma200 = ta.sma(c, 200)
    sma200_22 = sma200[22]
    atr14 = ta.atr(14)
    highest_price = ta.highest(high, 260)
    lowest_price = ta.lowest(low, 260)

    // Daily quarter lookbacks (yogy weekly 13/26/39/52 -> 63/126/189/252 on daily bars)
    three_month_rs = 0.4 * (c / c[63])
    six_month_rs = 0.2 * (c / (c[126] * 2))
    nine_month_rs = 0.2 * (c / (c[189] * 3))
    twelve_month_rs = 0.2 * (c / (c[252] * 4))
    mm_rs = (three_month_rs + six_month_rs + nine_month_rs + twelve_month_rs) * 100

    c_1 = (c > sma150) and (c > sma200) ? 1 : 0
    c_2 = sma150 > sma200 ? 1 : 0
    c_3 = sma200 > sma200_22 ? 1 : 0
    c_4 = (sma50 > sma150) and (sma50 > sma200) ? 1 : 0
    c_5 = c > sma50 ? 1 : 0
    c_6 = ((c / lowest_price) - 1) * 100 >= 25 ? 1 : 0
    c_7 = (1 - (c / highest_price)) * 100 <= 25 ? 1 : 0
    c_8 = mm_rs > 70 ? 1 : 0
    mm = c_1 + c_2 + c_3 + c_4 + c_5 + c_6 + c_7 + c_8

    atr14_pct = c > 0 ? atr14 / c * 100 : na
    ma_gain_pct = sma50 > 0 ? (c - sma50) / sma50 * 100 : na
    xfrom50 = atr14_pct > 0 ? ma_gain_pct / atr14_pct : na
    max_xfrom50 = ta.highest(xfrom50, XFROM50_MAX_LOOKBACK)
    pct_max_atrx = max_xfrom50 > 0 ? xfrom50 / max_xfrom50 * 100 : na
    change_pct = c[1] > 0 ? (c - c[1]) / c[1] * 100 : na
    change_open_pct = o > 0 ? (c - o) / o * 100 : na
    pdh = high[1]
    pct_from_pdh = pdh > 0 ? (high - pdh) / pdh * 100 : na
    avg_daily_vol = ta.sma(volume, 10)[1]
    relvol_pct = avg_daily_vol > 0 ? volume / avg_daily_vol * 100 : na

    // VCPT — same formula/defaults as GS2 HUD (daily bars)
    bar_range_pct = low > 0 ? ((high - low) / low) * 100 : na
    adr_pct = ta.sma(bar_range_pct, VCP_ADR_LEN)
    safe_adr = na(adr_pct) or adr_pct == 0 ? 0.0001 : adr_pct
    hi_c = ta.highest(c, VCP_LEN)
    lo_c = ta.lowest(c, VCP_LEN)
    close_spread_pct = lo_c > 0 ? ((hi_c - lo_c) / lo_c) * 100 : na
    hi_p = ta.highest(high, VCP_LEN)
    lo_p = ta.lowest(low, VCP_LEN)
    price_spread_pct = lo_p > 0 ? ((hi_p - lo_p) / lo_p) * 100 : na
    combined_ratio = (close_spread_pct / safe_adr + price_spread_pct / safe_adr) / 2
    highest_ratio = ta.highest(combined_ratio, VCP_BASELINE)
    lowest_ratio = ta.lowest(combined_ratio, VCP_BASELINE)
    range_ratio = highest_ratio - lowest_ratio
    vcpt = range_ratio == 0 ? 0.0 : ((combined_ratio - lowest_ratio) / range_ratio) * 100

    [float(mm), xfrom50, pct_max_atrx, atr14_pct, change_pct, change_open_pct, atr14, pct_from_pdh, relvol_pct, c, vcpt]

intradayLodDist() =>
    newDay = ta.change(time("D")) != 0
    var float lowToday = na
    if newDay
        lowToday := low
    else
        lowToday := math.min(lowToday, low)
    close - lowToday

[mm_score, xfrom50, pct_max_atrx, atr14_pct, change_pct, change_open_pct, atr14_daily, pct_from_pdh, relvol_pct, c_daily, vcpt_score] = request.security(
     syminfo.tickerid, "D", dailyMetricsBundle(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

spy_c = request.security("SPY", "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rs14_spy = c_daily[14] > 0 and spy_c[14] > 0 ? (c_daily / c_daily[14]) / (spy_c / spy_c[14]) * 100 : na

// STS — same as GS2 HUD (stock/SPY ratio percentile over STS_LOOKBACK); reuses c_daily + spy_c
rs_ratio = spy_c > 0 ? c_daily / spy_c : na
rs_percentile_count = 0.0
if not na(rs_ratio)
    for i = 1 to STS_LOOKBACK
        if not na(rs_ratio[i]) and rs_ratio > rs_ratio[i]
            rs_percentile_count += 1
sts_score = (rs_percentile_count / STS_LOOKBACK) * 100

// RelVol At Time must run on chart TF — inside request.security("D") it degrades to vol/avg daily
[curVol, pastVol, _] = ta.relativeVolume(10, "1D", true, true)
rvatRaw = pastVol > 0 ? curVol / pastVol : na
rvat = not na(rvatRaw) ? math.round(rvatRaw * 100) / 100 : na

lodArr = request.security_lower_tf(syminfo.tickerid, "1", intradayLodDist())
dist_from_lod = array.size(lodArr) > 0 ? array.get(lodArr, array.size(lodArr) - 1) : na

pct_from_lod = atr14_daily > 0 ? dist_from_lod / atr14_daily * 100 : na

plot(atr14_pct, "ATR 14d%", display=display.none, precision=2)
plot(xfrom50, "xATR From 50", display=display.none, precision=2)
plot(pct_max_atrx, "%MaxATRx", display=display.none, precision=1)
plot(pct_from_lod, "%ATR from LoD", display=display.none)
plot(rvat, "RelVol At Time", display=display.none, precision=2)
plot(relvol_pct, "RelVol 10D %", display=display.none, precision=2)
plot(rs14_spy, "RS14/SPY %", display=display.none, precision=2)
plot(pct_from_pdh, "%HoD vs Prior", display=display.none, precision=2)
plot(change_pct, "Change %", display=display.none)
plot(change_open_pct, "Change Open %", display=display.none)
plot(mm_score, "Minervini x/8", display=display.none)
plot(sts_score, "STS %", display=display.none, precision=1)
plot(vcpt_score, "VCPT", display=display.none, precision=1)
````
