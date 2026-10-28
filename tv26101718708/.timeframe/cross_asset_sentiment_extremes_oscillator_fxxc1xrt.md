# Cross Asset Sentiment Extremes Oscillator

- url: https://www.tradingview.com/script/FxXC1XrT-Cross-Asset-Sentiment-Extremes-Oscillator/
- type: indicator
- pine_id: PUB;852eef048bab4414af1b730366724923
- version: 1.0

## Description

Cross Asset Sentiment Extremes Oscillator (XSEO)

WHAT IT IS
XSEO is a composite sentiment oscillator that scores market emotion on a 0 to 100 scale and flags the extremes where mean reversion setups cluster. Readings near the bottom of the scale mark washed out fear of the kind that tends to appear near lows. Readings near the top mark crowded greed of the kind that tends to appear near highs. One script covers stocks, indices, and crypto.

TWO BASKETS, ONE ENGINE
The script reads the symbol type and loads the matching basket of external data automatically. A manual override is available in the settings.

Stocks and indices basket:
VIX implied volatility (inverted, high VIX means fear)
NYSE TRIN (inverted, heavy selling pressure means fear)
CBOE equity put/call ratio, ranked in daily context (inverted)
High yield credit spread (inverted, wide spreads mean risk aversion)
Percent of S&P 500 stocks above their 200 day average (breadth strength)
Percent of S&P 500 stocks above their 50 day average (faster breadth)

Crypto basket:
Perp to spot basis on BTC (a funding and leverage proxy, a rich premium means greed)
Coinbase premium versus Binance (US spot demand)
USDT dominance (inverted, cash parked in stables means fear)
ETH/BTC momentum (alt risk appetite)
DXY (inverted, a strong dollar means risk aversion)

Chart internals, active in both modes:
RSI percentile rank (momentum extreme)
Extension from the 200 bar mean
Realized volatility rank, inverted (calm means complacency, spikes mean fear)

HOW IT IS BUILT
Every component is converted to a percentile rank over a lookback window so that different units blend cleanly, and fear oriented series are inverted so that high always means greed. Feeds that only publish daily (put/call, credit spreads, breadth) are ranked inside a daily request and held between updates. Live feeds and the chart internals are ranked on the chart timeframe, so the line keeps moving intraday. Feeds that are unavailable on a given bar (weekends, holidays, closed sessions) are skipped from the average rather than zeroed, which keeps the oscillator honest on 24/7 crypto charts. The external basket and the internals are then blended with an adjustable weight and smoothed.

READING IT
Above the upper threshold (default 80) the market is in the extreme greed zone. Below the lower threshold (default 20) it is in the extreme fear zone. The line colors itself red when hot, green when cold, and gray in the middle, and the background tints inside the zones.

SIGNALS AND ALERTS
Two trigger styles are available.
Zone Exit (default): the buy fires when the oscillator crosses back up out of the fear zone, and the sell fires when it crosses back down out of the greed zone. This waits for the turn and avoids some knife catching.
Zone Entry: fires the moment an extreme zone is entered. Earlier and more aggressive.
Alert conditions are included for both long and short.

SETTINGS
Fear and greed thresholds. Lookback for chart timeframe ranks (in bars) and a separate lookback for daily feeds (in days). External data weight percent, with the remainder going to the chart internals. Smoothing length. An optional display of the external and internal subscores so you can see what is driving a reading.

DATA SOURCES
CBOE:VIX, USI:TRIN.NY, USI:PCCE, FRED:BAMLH0A0HYM2, INDEX:S5TH, INDEX:S5FI, BINANCE:BTCUSDT.P, BINANCE:BTCUSDT, COINBASE:BTCUSD, CRYPTOCAP:USDT.D, BINANCE:ETHBTC, TVC:DXY

TIMEFRAMES AND NOTES
Built for higher timeframe charts but usable intraday. On intraday charts the daily feeds step once per day while everything else updates live. Consider raising the chart timeframe lookback on fast charts, for example 300 to 700 bars on 15 minute charts. Values drawn from the developing daily bar update in real time until that bar closes, which is standard higher timeframe behavior. XSEO is a timing and context tool, not a complete system. It works best as a filter for mean reversion entries at levels you already care about. Nothing here is financial advice.

Concept credit: builds on the classic composite fear and greed approach of blending volatility, positioning, breadth, and credit data into a single gauge.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
// Cross-Asset Sentiment Extremes Oscillator (XSEO)
// Companion to CSEO — auto-switches component basket for stocks/indices vs crypto (BTC/ETH etc.)
// Daily-only feeds are ranked in daily context and held intraday; live feeds + chart internals move in real time.
indicator("Cross-Asset Sentiment Extremes Oscillator", shorttitle="XSEO", overlay=false)

// ================= INPUTS =================
mode_in    = input.string("Auto", "Asset Mode", options=["Auto", "Stocks/Indices", "Crypto"], tooltip="Auto detects via syminfo.type. Override if charting CRYPTOCAP indices, futures, etc.")
fear_th    = input.float(20, "Extreme Fear Threshold (Buy)", minval=0, maxval=100)
greed_th   = input.float(80, "Extreme Greed Threshold (Sell)", minval=0, maxval=100)
len_fast   = input.int(252, "Percentile Lookback — Chart TF (bars)", minval=20, tooltip="Rank window for live components + internals, in chart bars. 252 on daily = 1yr. On 15m try 300–700.")
len_daily  = input.int(252, "Percentile Lookback — Daily Series (days)", minval=20, tooltip="Rank window for daily-only feeds (put/call, HY OAS, breadth). Always in days regardless of chart TF.")
w_ext      = input.int(60, "External Data Weight %", minval=0, maxval=100, tooltip="Remainder goes to chart-derived internals (RSI rank, 200-bar extension, realized vol).")
smooth_len = input.int(3, "Smoothing (bars)", minval=1)
sig_mode   = input.string("Zone Exit (confirmed)", "Signal Trigger", options=["Zone Exit (confirmed)", "Zone Entry (early)"], tooltip="Exit = fires when oscillator leaves the extreme zone (later, safer). Entry = fires when it enters (earlier, like CSEO).")
show_parts = input.bool(false, "Show External / Internal Sub-Scores")

is_crypto = mode_in == "Crypto" or (mode_in == "Auto" and syminfo.type == "crypto")

// ================= EXTERNAL DATA — EQUITY BASKET =================
vix    = request.security("CBOE:VIX",           timeframe.period, close, lookahead=barmerge.lookahead_off)
trin   = request.security("USI:TRIN.NY",        timeframe.period, close, lookahead=barmerge.lookahead_off)
pc_r   = request.security("USI:PCCE",           "D", ta.percentrank(close, len_daily), lookahead=barmerge.lookahead_off)
hy_r   = request.security("FRED:BAMLH0A0HYM2",  "D", ta.percentrank(close, len_daily), lookahead=barmerge.lookahead_off)
s5th_r = request.security("INDEX:S5TH",         "D", ta.percentrank(close, len_daily), lookahead=barmerge.lookahead_off)
s5fi_r = request.security("INDEX:S5FI",         "D", ta.percentrank(close, len_daily), lookahead=barmerge.lookahead_off)

eq1 = 100 - ta.percentrank(vix, len_fast)    // high VIX = fear -> low score
eq2 = 100 - ta.percentrank(trin, len_fast)   // high TRIN = selling pressure -> low score
eq3 = 100 - pc_r                             // high put/call = fear -> low score
eq4 = 100 - hy_r                             // wide HY spread = risk-off -> low score
eq5 = s5th_r                                 // % SPX above 200d = breadth strength
eq6 = s5fi_r                                 // % SPX above 50d = faster breadth

// ================= EXTERNAL DATA — CRYPTO BASKET =================
perp   = request.security("BINANCE:BTCUSDT.P", timeframe.period, close, lookahead=barmerge.lookahead_off)
spot   = request.security("BINANCE:BTCUSDT",   timeframe.period, close, lookahead=barmerge.lookahead_off)
cbase  = request.security("COINBASE:BTCUSD",   timeframe.period, close, lookahead=barmerge.lookahead_off)
usdt_d = request.security("CRYPTOCAP:USDT.D",  timeframe.period, close, lookahead=barmerge.lookahead_off)
ethbtc = request.security("BINANCE:ETHBTC",    timeframe.period, close, lookahead=barmerge.lookahead_off)
dxy    = request.security("TVC:DXY",           timeframe.period, close, lookahead=barmerge.lookahead_off)

basis = (perp - spot) / spot * 100    // perp premium over spot = funding/leverage proxy
cprem = (cbase - spot) / spot * 100   // Coinbase premium = US spot demand proxy

cr1 = ta.percentrank(basis, len_fast)               // rich perp basis = greed
cr2 = ta.percentrank(cprem, len_fast)               // strong US bid = greed
cr3 = 100 - ta.percentrank(usdt_d, len_fast)        // rising stablecoin dominance = cash parked = fear
cr4 = ta.percentrank(ta.roc(ethbtc, 30), len_fast)  // ETH/BTC momentum = alt risk appetite
cr5 = 100 - ta.percentrank(dxy, len_fast)           // strong dollar = risk-off

// ================= CHART-DERIVED INTERNALS (any symbol, any TF) =================
in1 = ta.percentrank(ta.rsi(close, 14), len_fast)                                // momentum extreme
in2 = ta.percentrank(close / ta.sma(close, 200) - 1, len_fast)                   // extension from 200-bar mean
in3 = 100 - ta.percentrank(ta.stdev(ta.change(math.log(close)), 20), len_fast)   // calm = complacency, vol spike = fear

// ================= COMPOSITE (na-safe: missing feeds are skipped, not zeroed) =================
s1 = is_crypto ? cr1 : eq1
s2 = is_crypto ? cr2 : eq2
s3 = is_crypto ? cr3 : eq3
s4 = is_crypto ? cr4 : eq4
s5 = is_crypto ? cr5 : eq5
s6 = is_crypto ? na : eq6

v1 = na(s1) ? 0.0 : s1
n1 = na(s1) ? 0 : 1
v2 = na(s2) ? 0.0 : s2
n2 = na(s2) ? 0 : 1
v3 = na(s3) ? 0.0 : s3
n3 = na(s3) ? 0 : 1
v4 = na(s4) ? 0.0 : s4
n4 = na(s4) ? 0 : 1
v5 = na(s5) ? 0.0 : s5
n5 = na(s5) ? 0 : 1
v6 = na(s6) ? 0.0 : s6
n6 = na(s6) ? 0 : 1
ext_n     = n1 + n2 + n3 + n4 + n5 + n6
ext_score = ext_n > 0 ? (v1 + v2 + v3 + v4 + v5 + v6) / ext_n : na

iv1 = na(in1) ? 0.0 : in1
ic1 = na(in1) ? 0 : 1
iv2 = na(in2) ? 0.0 : in2
ic2 = na(in2) ? 0 : 1
iv3 = na(in3) ? 0.0 : in3
ic3 = na(in3) ? 0 : 1
int_n     = ic1 + ic2 + ic3
int_score = int_n > 0 ? (iv1 + iv2 + iv3) / int_n : na

osc_raw = na(ext_score) and na(int_score) ? na : na(ext_score) ? int_score : na(int_score) ? ext_score : (ext_score * w_ext + int_score * (100 - w_ext)) / 100
osc     = ta.sma(osc_raw, smooth_len)

// ================= SIGNALS =================
cross_up_fear  = ta.crossover(osc, fear_th)
cross_dn_fear  = ta.crossunder(osc, fear_th)
cross_up_greed = ta.crossover(osc, greed_th)
cross_dn_greed = ta.crossunder(osc, greed_th)

early    = sig_mode == "Zone Entry (early)"
buy_sig  = early ? cross_dn_fear : cross_up_fear
sell_sig = early ? cross_up_greed : cross_dn_greed

// ================= VISUALS =================
plot(osc, "XSEO", color = osc > 60 ? color.red : osc < 40 ? color.green : color.gray, linewidth=2)
plot(show_parts ? ext_score : na, "External Sub-Score", color=color.new(color.orange, 50), linewidth=1)
plot(show_parts ? int_score : na, "Internal Sub-Score", color=color.new(color.aqua, 50), linewidth=1)

hline(greed_th, "Extreme Greed (Sell)", color=color.red, linestyle=hline.style_dashed)
hline(50, "Neutral", color=color.gray, linestyle=hline.style_dotted)
hline(fear_th, "Extreme Fear (Buy)", color=color.green, linestyle=hline.style_dashed)

bgcolor(buy_sig ? color.new(color.green, 78) : sell_sig ? color.new(color.red, 78) : osc < fear_th ? color.new(color.green, 92) : osc > greed_th ? color.new(color.red, 92) : na, title="Zones & Signals")

// ================= ALERTS =================
alertcondition(buy_sig, title="XSEO Long: Extreme Fear — Buy", message="XSEO: Extreme fear buy signal")
alertcondition(sell_sig, title="XSEO Short: Extreme Greed — Sell", message="XSEO: Extreme greed sell signal")
````
