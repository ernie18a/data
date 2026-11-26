# MGI & Momentum Trend

- url: https://www.tradingview.com/script/tpzolP9S/
- type: indicator
- pine_id: PUB;c58858a366514d6592a7a467592586ce
- version: 2.0

## Description

The suite of indicators plotted here serves as an analytical foundation for capturing market "structure" from multiple perspectives. They are designed to facilitate everything from a broad assessment of the market environment based on weekly charts to precise, tactical entry decisions using daily charts.

Below is an explanation of the logic and role of each indicator, along with guidance on adapting them to market conditions.

This system is designed to deliver its full value when customized by the user to suit changing market environments and the specific characteristics of the assets being monitored.
The display is primarily based on weekly charts, with daily charts used as needed.

MarketGoingIndex (MGI) – Macro Liquidity Environment

Look for buying opportunities when the background indicator lights up while the purple line is rising.
Purpose:
This indicator utilizes the yield spread between US junk bonds and US Treasury bonds—one of the metrics most strongly inversely correlated with capital inflows into the stock market (risk-on sentiment). This spread widens sharply when large-scale investors become anxious about the economic outlook. By calculating the "cumulative 4-week momentum" of this spread and inverting the result, we create a leading indicator for the stock market.

Logic:
It is based on the credit spread of US high-yield bonds (junk bonds). A widening spread signifies rising credit risk, while a narrowing spread indicates abundant liquidity.

Role of the Index:
By calculating the "cumulative change" in the spread, it visualizes the direction of capital flow (risk-on vs. risk-off).

Usage (Market Adaptation):
For the US market: It functions using the default settings. Another suitable alternative is FRED:BAA10Y (Moody's Seasoned Baa Corporate Bond Yield Relative to Yield on 10-Year Treasury). Major recessions like the COVID-19 crash (where stock prices drop by nearly 20%) often occur in years ending in "9" or "0" and during the first or second year of a U.S. presidential term. In such cases, it is more effective to gauge the timing of a market bottom reversal by using indicators that offer stronger leading signals for recessions than the standard 10-year/2-year spread—specifically, the spread between 10-year and 3-month Treasury yields (FRED:T10Y3M), which the Federal Reserve prioritizes.

During major recessions like the COVID-19 crash, the FRED:BAMLH0A0HYM2 indicator is too slow to react.
Image
Focus on short-term Treasury yields, to which the Fed is likely to respond quickly (using the FRED:T10Y3M setting).
For the Japanese market: Since it is highly correlated with the U.S. market, I recommend using this as a leading indicator while also monitoring the momentum of the USD/JPY exchange rate and trends in the Nikkei 225 Volatility Index (NI225VI) for supplementary analysis.

2.Intermediate Trend Background Signal (A/D Difference)
Logic:
Uses the SMA of the Advance/Decline (A/D) line to indicate market overheating and trend direction via the background color.

Role:
An indicator that measures market "breadth." Areas with background coloring suggest the market is in an overheated zone with a clear trend.

Operation (Adjustment Method):
Thresholds (-1000, -1500) vary depending on the liquidity of the target market.
If the background color does not appear when you want it to, make the threshold looser (closer to 0).
If there is too much noise, adjust the threshold to be stricter (increase the negative value).

System Usage Workflow
Broad Perspective (Weekly Chart):
Check the capital environment using MGI and assess market "heat" via the background color. When the background turns green or pink, it indicates a phase requiring special attention.

Tactical Decision (Daily Chart):
Check the direction of the VStop line and the price position; consider trend-following trades aligned with the direction seen on the weekly chart.

Temporal Edge (Seasonality Chart):
Check where the current price stands relative to historical anomalies to increase your confidence when buying dips or selling rallies.

Key Points for Use
This system does not provide a single "answer"; rather, it is a tool to assist you in interpreting the current market environment. If you find yourself wondering, "Why did the background color appear but the price didn't follow suit?", try fine-tuning the parameters mentioned above.
Please make investment decisions calmly and at your own risk.

## Source Code

````pine
//@version=6
indicator("MGI & Momentum Trend", overlay=true, timeframe="", timeframe_gaps=true)

// =========================================================================
// 1. 入力設定 (Inputs)
// =========================================================================
grp_vs   = "Trend / VStop (Daily)"
len_vs   = input.int(12, "ATR Length", minval=2, group=grp_vs)
mult_vs  = input.float(2.0, "ATR Multiplier", minval=0.25, step=0.25, group=grp_vs)

grp_mgi  = "Macro Trend (MGI) - Weekly"
sym_mgi  = input.symbol("FRED:BAMLH0A0HYM2", "Credit Spread Symbol", group=grp_mgi)
mom_len  = input.int(4, "Momentum Lookback (Weeks)", minval=1, group=grp_mgi)
lead_bar = input.int(10, "Lead/Lag Offset (Bars)", group=grp_mgi)
norm_len = input.int(250, "Normalization Period", group=grp_mgi)

grp_ad   = "Momentum Trend (Weekly)"
sym_ad   = input.symbol("USI:ADD", "A/D Difference Symbol", group=grp_ad)
ad_sma   = input.int(3, "A/D SMA Length", group=grp_ad)
lvl_grn  = input.float(-1000, "Oversold Threshold (Green)", group=grp_ad)
lvl_pnk  = input.float(-1500, "Panic Threshold (Pink)", group=grp_ad)

// =========================================================================
// 2. 計算処理 (Calculations)
// =========================================================================
f_vstop() =>
    var max_p = close, var min_p = close, var uptrend = true, var float stop_p = na
    atrM = nz(ta.atr(len_vs) * mult_vs, ta.tr)
    max_p := math.max(max_p, close), min_p := math.min(min_p, close)
    stop_p := nz(uptrend ? math.max(stop_p, max_p - atrM) : math.min(stop_p, min_p + atrM), close)
    uptrend := close - stop_p >= 0.0
    if uptrend != uptrend[1] and not barstate.isfirst
        max_p := close, min_p := close
        stop_p := uptrend ? max_p - atrM : min_p + atrM
    [stop_p, uptrend]

f_cum_diff() =>
    past = close[mom_len]
    diff = (past - close)
    ta.cum(nz(diff, 0))

f_normalize(val) =>
    max_p = ta.highest(high, norm_len)
    min_p = ta.lowest(low, norm_len)
    max_v = ta.highest(val, norm_len)
    min_v = ta.lowest(val, norm_len)
    denom = (max_v - min_v) == 0 ? 1 : (max_v - min_v)
    min_p + ((val - min_v) / denom) * (max_p - min_p)

// =========================================================================
// 3. データ取得と実行 (Logic)
// =========================================================================
[vStop, isUp] = request.security(syminfo.tickerid, "1D", f_vstop(), lookahead=barmerge.lookahead_off)
raw_mgi       = request.security(sym_mgi, "1W", f_cum_diff(), lookahead=barmerge.lookahead_off)
ad_val        = request.security(sym_ad, "1W", ta.sma(close, ad_sma), lookahead=barmerge.lookahead_off)

norm_mgi = f_normalize(raw_mgi)

// =========================================================================
// 4. 描画 (Plots)
// =========================================================================
plot(vStop, "Volatility Stop", style=plot.style_line, color=isUp ? #009688 : #F44336, linewidth=2)
plot(norm_mgi, "MarketGoingIndex (Normalized)", color=color.purple, linewidth=2, offset=lead_bar)

bool is_pink  = ad_val <= lvl_pnk
bool is_green = ad_val <= lvl_grn and ad_val > lvl_pnk
bgcolor(is_pink ? color.new(color.fuchsia, 85) : is_green ? color.new(color.green, 85) : na, title="Momentum Trend BG")
````
