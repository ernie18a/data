# Risk-Adjusted Performance Rankings | NickJoan

- url: https://www.tradingview.com/script/vQ1tVnwF-Risk-Adjusted-Performance-Rankings-NickJoan/
- type: indicator
- pine_id: PUB;16acba315b29415487b7559204ec58c1
- version: 1.0

## Description

Risk-Adjusted Performance Rankings | NickJoan

Core Idea

Risk-Adjusted Performance Rankings is a multi-asset comparison dashboard designed to rank up to 15 symbols by how efficiently they convert recent price movement into risk-adjusted return. Instead of looking only at raw price performance, the indicator evaluates three classic performance measures: Sharpe, Sortino and Omega over a user-defined lookback window and organizes the results into a table.

The script can be used in two ways:

• As a metrics table, where all three risk-adjusted values are shown side by side for each asset.
• As a ranking tool, where the symbols are sorted by Sharpe, Sortino, Omega, or a composite Z-Score score.

Calculation Logic

The indicator works by taking the percentage return of each symbol over the selected period and then building three separate statistics from that same return stream.

1. Return calculation

For each symbol, the script first calculates the one-bar rate of change. This creates a rolling return series that acts as the base input for all three risk-adjusted metrics.

2. Sharpe ratio

The Sharpe calculation measures average return relative to total return volatility.

• The script calculates the mean of returns over the selected lookback.
• It calculates the standard deviation of those returns.
• It divides mean return by standard deviation.
• It then multiplies by the square root of the lookback length to create a rolling-style scaled value.

In practical terms, a higher Sharpe reading means the asset has produced more return for each unit of total volatility.

3. Sortino ratio

The Sortino ratio is similar to Sharpe, but it only penalizes downside volatility.

• The script collects only negative returns from the lookback window.
• It computes the standard deviation of those downside returns.
• It divides mean return by that downside deviation.
• It then scales the result by the square root of the lookback.

This means Sortino rewards assets that may have volatile upside moves but relatively controlled downside behavior.

4. Omega ratio

The Omega calculation compares total gains to total losses over the selected window.

• All positive returns are summed as gains.
• All negative returns are converted to positive values and summed as losses.
• Omega is computed as the ratio of total gains to total losses.

A value above 1 suggests gains outweigh losses, while a value below 1 suggests the opposite. 

Ranking Logic

The indicator supports several ranking modes, and each one uses the same asset list but applies a different sort key.

Metrics Table

In Metrics Table mode, the script shows:

• The ticker name.
• Sharpe.
• Sortino.
• Omega.

This mode is the most direct view if you want to inspect each asset’s raw values without sorting.

Sharpe / Sortino / Omega ranking

When one of these modes is selected:

• The table sorts the assets by that chosen metric.
• The highest values appear at the top.
• The table becomes a direct performance leaderboard.

Z-Score ranking

The Z-Score mode is a composite ranking system.

• The script first computes the mean and standard deviation of each metric across all 15 assets.
• It then converts each asset’s Sharpe, Sortino, and Omega into z-scores.
• Those three standardized values are averaged into one composite score.
• Assets are sorted by that final score.

This allows apples-to-apples comparison even when the raw metrics live on different numeric scales.

What the Colors Mean

The script uses color thresholds to make the table easier to read at a glance.

Sharpe colors

Sharpe cells are colored according to the input range defined by:

• Sharpe Min
• Sharpe Max

Values below the minimum are treated as weak.
Values between the lower zone and upper zone are shown as progressively stronger.
Values above the upper threshold are treated as strong.

Sortino colors

Sortino uses the same idea, but with its own range:

• Sortino Min
• Sortino Max

This allows the heatmap to reflect downside-adjusted performance independently from Sharpe.

Omega colors

Omega is especially important because it is naturally centered around 1.0.

• Values below the lower threshold are weak.
• Values between the band limits gradually improve.
• Values above the upper threshold are strong.

Z-Score colors

The Z-Score mode uses a standardized color logic:

• Strongly negative values are weak.
• Slightly negative values are mid-negative.
• Slightly positive values are mid-positive.
• Strongly positive values are strong.

This helps show whether an asset is above or below the group average on a normalized basis.

Table Output

Metrics Table output
In this mode, the table displays:

• Column 1: ticker.
• Column 2: Sharpe.
• Column 3: Sortino.
• Column 4: Omega.

Single-metric ranking output
In Sharpe, Sortino, and Omega modes, the table displays:

• Rank number.
• Ticker.
• Chosen metric.

This keeps the interface minimal while still showing the full ranked order.

Z-Score output
In this mode, the table displays:

• Rank number.
• Ticker.
• Sharpe Z.
• Sortino Z.
• Omega Z.
• Average score.

This view is useful when you want a compact, relative ranking rather than raw values.

Inputs

The indicator has four main input groups.

Calculation

• Period: defines the lookback window used for all metric calculations.

Table

• Display Mode: chooses between Metrics Table, Sharpe, Sortino, Omega, and Z-Score.
• Table Position: controls where the table is placed on the chart.

Color Scale

• Sharpe Min / Max: controls the heatmap thresholds for Sharpe.
• Sortino Min / Max: controls the heatmap thresholds for Sortino.
• Omega Min / Max: controls the heatmap thresholds for Omega.

Colors

• Strong: the strongest positive color.
• Mid +: the intermediate positive color.
• Mid -: the intermediate negative color.
• Weak: the weakest negative color.

Tickers

The script includes 15 symbol inputs, allowing you to compare a basket of assets at once. This makes it suitable for crypto rotation, watchlist comparison, or broad performance ranking across a selected universe.

How to Use It

This indicator is best used as a relative strength and quality filter, not as a standalone entry signal.

Trend selection

Use the ranking table to see which assets are showing the best risk-adjusted behavior over the chosen period.

Rotation analysis

If you track a basket of coins or market leaders, the indicator can help identify which names are improving in risk-adjusted terms and which ones are losing momentum.

Risk control

A raw gain is not always useful if it comes with excessive volatility or poor downside behavior. This script helps highlight assets with better return efficiency, not just bigger movement.

Multi-factor comparison

Because Sharpe, Sortino, and Omega emphasize different aspects of return quality, the script gives a more balanced view than a single metric alone.

Practical Interpretation

Here is a simple way to read the results:

• High Sharpe: efficient return relative to total volatility.
• High Sortino: strong return with less downside volatility.
• High Omega: gains outweigh losses over the lookback window.
• High Z-Score average: strong performance relative to the rest of the selected universe.

If an asset scores well across all three, it usually represents a stronger and more stable candidate than one that only looks good on one metric.

Best Use Cases

Typical uses include:

• Crypto basket comparison.
• Top-asset ranking.
• Risk-adjusted momentum filtering.
• Rotation watchlists.
• Regime-aware asset selection.

It is especially useful when you want to compare many symbols quickly without manually calculating which ones are actually performing best on a quality-adjusted basis.

Notes

The metric table is only as good as the selected lookback period and asset set.

• Shorter periods react faster but can be noisier.
• Longer periods smooth the results but may lag recent shifts.
• The Z-Score mode is relative to the selected group, so its meaning depends on the symbols you include.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan

//@version=6
indicator("Risk-Adjusted Performance Rankings | NickJoan", shorttitle = "RAPR | NickJoan", overlay=false)

// ─── Inputs ───────────────────────────────────────────────────────────────────
length = input.int(30, "Period", minval=2, group="CALCULATION")

displayMode = input.string("Metrics Table", "Display Mode", options=["Metrics Table", "Sharpe", "Sortino", "Omega", "Z-Score"], group="TABLE", tooltip="Choose how the dashboard is displayed.\n\n• Metrics Table = Raw unsorted Sharpe, Sortino, and Omega values.\n\n• Sharpe / Sortino / Omega = Ranked table sorted by the selected metric.\n\n• Z-Score = Composite ranking using the average of Sharpe, Sortino and Omega Z-scores.")

tablePosInput = input.string("Middle Center", "Table Position", display=display.none, options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="TABLE")

shMin = input.float(0.0, "Sharpe Min", inline="SH", group="COLOR SCALE", step = 0.05)
shMax = input.float(2.5, "Sharpe Max", inline="SH", group="COLOR SCALE", tooltip="Sharpe heatmap range.\n\nThese values control only the table coloring thresholds for Sharpe cells. They do not change the actual Sharpe calculation or ranking math.", step = 0.05)

soMin = input.float(0.0, "Sortino Min", inline="SO", group="COLOR SCALE", step = 0.05)
soMax = input.float(3.0, "Sortino Max", inline="SO", group="COLOR SCALE", tooltip="Sortino heatmap range.\n\nThese values control only the table coloring thresholds for Sortino cells. They do not change the actual Sortino calculation or ranking math.", step = 0.05)

omMin = input.float(0.9, "Omega Min", inline="OM", group="COLOR SCALE", step = 0.05)
omMax = input.float(1.1, "Omega Max", inline="OM", group="COLOR SCALE", tooltip="Omega heatmap range.\n\nThese values control only the table coloring thresholds for Omega cells. They do not change the actual Omega calculation or ranking math.", step = 0.05)

// ─── Color Inputs ─────────────────────────────────────────────────────────────
posStrongColor = input.color(color.green, "Strong", group="COLORS")
posMidColor    = input.color(color.teal, "Mid +", group="COLORS")
negMidColor    = input.color(color.orange, "Mid -", group="COLORS")
negStrongColor = input.color(color.red, "Weak", group="COLORS")

sym1  = input.symbol("INDEX:BTCUSD", "Ticker 1", group="TICKERS", display=display.none)
sym2  = input.symbol("INDEX:ETHUSD", "Ticker 2", group="TICKERS", display=display.none)
sym3  = input.symbol("BINANCE:BNBUSD", "Ticker 3", group="TICKERS", display=display.none)
sym4  = input.symbol("CRYPTO:SOLUSD", "Ticker 4", group="TICKERS", display=display.none)
sym5  = input.symbol("CRYPTO:TRXUSD", "Ticker 5", group="TICKERS", display=display.none)
sym6  = input.symbol("BINANCE:SUIUSD", "Ticker 6", group="TICKERS", display=display.none)
sym7  = input.symbol("BINANCE:DOGEUSD", "Ticker 7", group="TICKERS", display=display.none)
sym8  = input.symbol("MEXC:SPXUSDT", "Ticker 8", group="TICKERS", display=display.none)
sym9  = input.symbol("PYTH:HYPEUSD", "Ticker 9", group="TICKERS", display=display.none)
sym10 = input.symbol("BINANCE:ZECUSD", "Ticker 10", group="TICKERS", display=display.none)
sym11 = input.symbol("CRYPTO:XMRUSD", "Ticker 11", group="TICKERS", display=display.none)
sym12 = input.symbol("BINANCE:AAVEUSD", "Ticker 12", group="TICKERS", display=display.none)
sym13 = input.symbol("CRYPTO:XRPUSD", "Ticker 13", group="TICKERS", display=display.none)
sym14 = input.symbol("BINANCE:ADAUSD", "Ticker 14", group="TICKERS", display=display.none)
sym15 = input.symbol("CRYPTO:LINKUSD", "Ticker 15", group="TICKERS", display=display.none)

// ─── Helpers ──────────────────────────────────────────────────────────────────
getAssetName(asset) =>
    array.get(str.split(asset, ":"), 1)

f_pos(posStr) =>
    posStr == "Top Left" ? position.top_left : posStr == "Top Center" ? position.top_center : posStr == "Top Right" ? position.top_right : posStr == "Middle Left" ? position.middle_left : posStr == "Middle Center" ? position.middle_center : posStr == "Middle Right" ? position.middle_right : posStr == "Bottom Left" ? position.bottom_left : posStr == "Bottom Center" ? position.bottom_center : position.bottom_right

f_fmt(v) =>
    na(v) ? "na" : str.tostring(v, "#.##")

f_txt(v) =>
    na(v) ? color.rgb(170, 170, 170) : color.rgb(235, 235, 235)

f_bg_sharpe(v) =>
    na(v) ? color.new(color.gray, 88) : (v < shMin ? color.new(negStrongColor, 82) : v < shMin + (shMax - shMin) * 0.50 ? color.new(negMidColor, 84) : v < shMax ? color.new(posMidColor, 84) : color.new(posStrongColor, 80))

f_bg_sortino(v) =>
    na(v) ? color.new(color.gray, 88) : (v < soMin ? color.new(negStrongColor, 82) : v < soMin + (soMax - soMin) * 0.50 ? color.new(negMidColor, 84) : v < soMax ? color.new(posMidColor, 84) : color.new(posStrongColor, 80))

f_bg_omega(v) =>
    na(v) ? color.new(color.gray, 88) : (v < omMin ? color.new(negStrongColor, 82) : v < omMin + (omMax - omMin) * 0.50 ? color.new(negMidColor, 84) : v < omMax ? color.new(posMidColor, 84) : color.new(posStrongColor, 80))

f_bg_z(v) =>
    na(v) ? color.new(color.gray, 88) : (v < -1 ? color.new(negStrongColor, 82) : v < 0 ? color.new(negMidColor, 84) : v < 1 ? color.new(posMidColor, 84) : color.new(posStrongColor, 80))

f_asset_bg(row) =>
    row % 2 == 0 ? color.rgb(24, 24, 30) : color.rgb(32, 32, 40)

f_header_bg(col) =>
    col == 0 ? color.rgb(40, 40, 80) : color.rgb(45, 45, 45)

f_title_bg() =>
    color.rgb(20, 20, 24)

f_rank_score(v) =>
    na(v) ? -1000000.0 : v

f_avgz_header_bg() =>
    color.rgb(72, 72, 120)

f_avgz_bg(v) =>
    color.rgb(30, 30, 35)

f_metric_title() =>
    displayMode == "Metrics Table" ? "Metrics Table" : displayMode == "Sharpe" ? "Sharpe Ranking" : displayMode == "Sortino" ? "Sortino Ranking" : displayMode == "Omega" ? "Omega Ranking" : "Z-Score Ranking"

f_metric_bg(v) =>
    displayMode == "Sharpe" ? f_bg_sharpe(v) : displayMode == "Sortino" ? f_bg_sortino(v) : displayMode == "Omega" ? f_bg_omega(v) : f_bg_z(v)

f_metric_header() =>
    displayMode == "Sharpe" ? "Sharpe" : displayMode == "Sortino" ? "Sortino" : displayMode == "Omega" ? "Omega" : "Metric"

f_avgz_txt(v) =>
    na(v) ? color.rgb(170, 170, 170) : v < -1 ? negStrongColor : v < 0 ? negMidColor : v < 1 ? posMidColor : posStrongColor

// ─── Calculations ─────────────────────────────────────────────────────────────
f_metrics() =>
    ret = ta.roc(close, 1)
    meanRet = ta.sma(ret, length)
    stdevRet = ta.stdev(ret, length)
    sharpe = stdevRet != 0 ? meanRet / stdevRet : na
    rollingSharpe = sharpe * math.sqrt(length)
    var array<float> negRets = array.new<float>()
    negRets.clear()
    for i = 0 to length - 1
        if ret[i] < 0
            array.push(negRets, ret[i])
    downStdev = array.size(negRets) > 1 ? array.stdev(negRets) : na
    sortino = downStdev != 0 ? meanRet / downStdev : na
    rollingSortino = sortino * math.sqrt(length)
    sumGains = math.sum(ret > 0 ? ret : 0.0, length)
    sumLosses = math.sum(ret < 0 ? -ret : 0.0, length)
    omega = sumLosses != 0 ? sumGains / sumLosses : na
    [rollingSharpe, rollingSortino, omega]

[s1_sh, s1_so, s1_om] = request.security(sym1, timeframe.period, f_metrics())
[s2_sh, s2_so, s2_om] = request.security(sym2, timeframe.period, f_metrics())
[s3_sh, s3_so, s3_om] = request.security(sym3, timeframe.period, f_metrics())
[s4_sh, s4_so, s4_om] = request.security(sym4, timeframe.period, f_metrics())
[s5_sh, s5_so, s5_om] = request.security(sym5, timeframe.period, f_metrics())
[s6_sh, s6_so, s6_om] = request.security(sym6, timeframe.period, f_metrics())
[s7_sh, s7_so, s7_om] = request.security(sym7, timeframe.period, f_metrics())
[s8_sh, s8_so, s8_om] = request.security(sym8, timeframe.period, f_metrics())
[s9_sh, s9_so, s9_om] = request.security(sym9, timeframe.period, f_metrics())
[s10_sh, s10_so, s10_om] = request.security(sym10, timeframe.period, f_metrics())
[s11_sh, s11_so, s11_om] = request.security(sym11, timeframe.period, f_metrics())
[s12_sh, s12_so, s12_om] = request.security(sym12, timeframe.period, f_metrics())
[s13_sh, s13_so, s13_om] = request.security(sym13, timeframe.period, f_metrics())
[s14_sh, s14_so, s14_om] = request.security(sym14, timeframe.period, f_metrics())
[s15_sh, s15_so, s15_om] = request.security(sym15, timeframe.period, f_metrics())

// ─── Z-score logic ────────────────────────────────────────────────────────────
f_z(v, mu, sd) =>
    na(v) or na(mu) or na(sd) or sd == 0 ? na : (v - mu) / sd

f_score(zsh, zso, zom) =>
    na(zsh) or na(zso) or na(zom) ? na : (zsh + zso + zom) / 3.0

var array<float> shArr = array.new<float>()
var array<float> soArr = array.new<float>()
var array<float> omArr = array.new<float>()

array.clear(shArr)
array.clear(soArr)
array.clear(omArr)

array.push(shArr, s1_sh), array.push(shArr, s2_sh), array.push(shArr, s3_sh), array.push(shArr, s4_sh), array.push(shArr, s5_sh)
array.push(shArr, s6_sh), array.push(shArr, s7_sh), array.push(shArr, s8_sh), array.push(shArr, s9_sh), array.push(shArr, s10_sh)
array.push(shArr, s11_sh), array.push(shArr, s12_sh), array.push(shArr, s13_sh), array.push(shArr, s14_sh), array.push(shArr, s15_sh)

array.push(soArr, s1_so), array.push(soArr, s2_so), array.push(soArr, s3_so), array.push(soArr, s4_so), array.push(soArr, s5_so)
array.push(soArr, s6_so), array.push(soArr, s7_so), array.push(soArr, s8_so), array.push(soArr, s9_so), array.push(soArr, s10_so)
array.push(soArr, s11_so), array.push(soArr, s12_so), array.push(soArr, s13_so), array.push(soArr, s14_so), array.push(soArr, s15_so)

array.push(omArr, s1_om), array.push(omArr, s2_om), array.push(omArr, s3_om), array.push(omArr, s4_om), array.push(omArr, s5_om)
array.push(omArr, s6_om), array.push(omArr, s7_om), array.push(omArr, s8_om), array.push(omArr, s9_om), array.push(omArr, s10_om)
array.push(omArr, s11_om), array.push(omArr, s12_om), array.push(omArr, s13_om), array.push(omArr, s14_om), array.push(omArr, s15_om)

shMu = array.size(shArr) > 0 ? array.avg(shArr) : na
shSd = array.size(shArr) > 1 ? array.stdev(shArr) : na
soMu = array.size(soArr) > 0 ? array.avg(soArr) : na
soSd = array.size(soArr) > 1 ? array.stdev(soArr) : na
omMu = array.size(omArr) > 0 ? array.avg(omArr) : na
omSd = array.size(omArr) > 1 ? array.stdev(omArr) : na

s1_zsh = f_z(s1_sh, shMu, shSd)
s2_zsh = f_z(s2_sh, shMu, shSd)
s3_zsh = f_z(s3_sh, shMu, shSd)
s4_zsh = f_z(s4_sh, shMu, shSd)
s5_zsh = f_z(s5_sh, shMu, shSd)
s6_zsh = f_z(s6_sh, shMu, shSd)
s7_zsh = f_z(s7_sh, shMu, shSd)
s8_zsh = f_z(s8_sh, shMu, shSd)
s9_zsh = f_z(s9_sh, shMu, shSd)
s10_zsh = f_z(s10_sh, shMu, shSd)
s11_zsh = f_z(s11_sh, shMu, shSd)
s12_zsh = f_z(s12_sh, shMu, shSd)
s13_zsh = f_z(s13_sh, shMu, shSd)
s14_zsh = f_z(s14_sh, shMu, shSd)
s15_zsh = f_z(s15_sh, shMu, shSd)

s1_zso = f_z(s1_so, soMu, soSd)
s2_zso = f_z(s2_so, soMu, soSd)
s3_zso = f_z(s3_so, soMu, soSd)
s4_zso = f_z(s4_so, soMu, soSd)
s5_zso = f_z(s5_so, soMu, soSd)
s6_zso = f_z(s6_so, soMu, soSd)
s7_zso = f_z(s7_so, soMu, soSd)
s8_zso = f_z(s8_so, soMu, soSd)
s9_zso = f_z(s9_so, soMu, soSd)
s10_zso = f_z(s10_so, soMu, soSd)
s11_zso = f_z(s11_so, soMu, soSd)
s12_zso = f_z(s12_so, soMu, soSd)
s13_zso = f_z(s13_so, soMu, soSd)
s14_zso = f_z(s14_so, soMu, soSd)
s15_zso = f_z(s15_so, soMu, soSd)

s1_zom = f_z(s1_om, omMu, omSd)
s2_zom = f_z(s2_om, omMu, omSd)
s3_zom = f_z(s3_om, omMu, omSd)
s4_zom = f_z(s4_om, omMu, omSd)
s5_zom = f_z(s5_om, omMu, omSd)
s6_zom = f_z(s6_om, omMu, omSd)
s7_zom = f_z(s7_om, omMu, omSd)
s8_zom = f_z(s8_om, omMu, omSd)
s9_zom = f_z(s9_om, omMu, omSd)
s10_zom = f_z(s10_om, omMu, omSd)
s11_zom = f_z(s11_om, omMu, omSd)
s12_zom = f_z(s12_om, omMu, omSd)
s13_zom = f_z(s13_om, omMu, omSd)
s14_zom = f_z(s14_om, omMu, omSd)
s15_zom = f_z(s15_om, omMu, omSd)

s1_sc = f_score(s1_zsh, s1_zso, s1_zom)
s2_sc = f_score(s2_zsh, s2_zso, s2_zom)
s3_sc = f_score(s3_zsh, s3_zso, s3_zom)
s4_sc = f_score(s4_zsh, s4_zso, s4_zom)
s5_sc = f_score(s5_zsh, s5_zso, s5_zom)
s6_sc = f_score(s6_zsh, s6_zso, s6_zom)
s7_sc = f_score(s7_zsh, s7_zso, s7_zom)
s8_sc = f_score(s8_zsh, s8_zso, s8_zom)
s9_sc = f_score(s9_zsh, s9_zso, s9_zom)
s10_sc = f_score(s10_zsh, s10_zso, s10_zom)
s11_sc = f_score(s11_zsh, s11_zso, s11_zom)
s12_sc = f_score(s12_zsh, s12_zso, s12_zom)
s13_sc = f_score(s13_zsh, s13_zso, s13_zom)
s14_sc = f_score(s14_zsh, s14_zso, s14_zom)
s15_sc = f_score(s15_zsh, s15_zso, s15_zom)

// ─── Arrays for names / values ────────────────────────────────────────────────
var array<string> namesArr = array.new<string>()
var array<float> sharpeArr = array.new<float>()
var array<float> sortinoArr2 = array.new<float>()
var array<float> omegaArr2 = array.new<float>()
var array<float> scoreArr = array.new<float>()
var array<float> rankScoreArr = array.new<float>()
var array<float> zshArr = array.new<float>()
var array<float> zsoArr = array.new<float>()
var array<float> zomArr = array.new<float>()
var array<float> sharpeRankArr = array.new<float>()
var array<float> sortinoRankArr = array.new<float>()
var array<float> omegaRankArr = array.new<float>()

array.clear(namesArr)
array.clear(sharpeArr)
array.clear(sortinoArr2)
array.clear(omegaArr2)
array.clear(scoreArr)
array.clear(rankScoreArr)
array.clear(zshArr)
array.clear(zsoArr)
array.clear(zomArr)
array.clear(sharpeRankArr)
array.clear(sortinoRankArr)
array.clear(omegaRankArr)

array.push(namesArr, getAssetName(sym1)), array.push(sharpeArr, s1_sh), array.push(sortinoArr2, s1_so), array.push(omegaArr2, s1_om), array.push(scoreArr, s1_sc), array.push(rankScoreArr, f_rank_score(s1_sc)), array.push(zshArr, s1_zsh), array.push(zsoArr, s1_zso), array.push(zomArr, s1_zom), array.push(sharpeRankArr, f_rank_score(s1_sh)), array.push(sortinoRankArr, f_rank_score(s1_so)), array.push(omegaRankArr, f_rank_score(s1_om))
array.push(namesArr, getAssetName(sym2)), array.push(sharpeArr, s2_sh), array.push(sortinoArr2, s2_so), array.push(omegaArr2, s2_om), array.push(scoreArr, s2_sc), array.push(rankScoreArr, f_rank_score(s2_sc)), array.push(zshArr, s2_zsh), array.push(zsoArr, s2_zso), array.push(zomArr, s2_zom), array.push(sharpeRankArr, f_rank_score(s2_sh)), array.push(sortinoRankArr, f_rank_score(s2_so)), array.push(omegaRankArr, f_rank_score(s2_om))
array.push(namesArr, getAssetName(sym3)), array.push(sharpeArr, s3_sh), array.push(sortinoArr2, s3_so), array.push(omegaArr2, s3_om), array.push(scoreArr, s3_sc), array.push(rankScoreArr, f_rank_score(s3_sc)), array.push(zshArr, s3_zsh), array.push(zsoArr, s3_zso), array.push(zomArr, s3_zom), array.push(sharpeRankArr, f_rank_score(s3_sh)), array.push(sortinoRankArr, f_rank_score(s3_so)), array.push(omegaRankArr, f_rank_score(s3_om))
array.push(namesArr, getAssetName(sym4)), array.push(sharpeArr, s4_sh), array.push(sortinoArr2, s4_so), array.push(omegaArr2, s4_om), array.push(scoreArr, s4_sc), array.push(rankScoreArr, f_rank_score(s4_sc)), array.push(zshArr, s4_zsh), array.push(zsoArr, s4_zso), array.push(zomArr, s4_zom), array.push(sharpeRankArr, f_rank_score(s4_sh)), array.push(sortinoRankArr, f_rank_score(s4_so)), array.push(omegaRankArr, f_rank_score(s4_om))
array.push(namesArr, getAssetName(sym5)), array.push(sharpeArr, s5_sh), array.push(sortinoArr2, s5_so), array.push(omegaArr2, s5_om), array.push(scoreArr, s5_sc), array.push(rankScoreArr, f_rank_score(s5_sc)), array.push(zshArr, s5_zsh), array.push(zsoArr, s5_zso), array.push(zomArr, s5_zom), array.push(sharpeRankArr, f_rank_score(s5_sh)), array.push(sortinoRankArr, f_rank_score(s5_so)), array.push(omegaRankArr, f_rank_score(s5_om))
array.push(namesArr, getAssetName(sym6)), array.push(sharpeArr, s6_sh), array.push(sortinoArr2, s6_so), array.push(omegaArr2, s6_om), array.push(scoreArr, s6_sc), array.push(rankScoreArr, f_rank_score(s6_sc)), array.push(zshArr, s6_zsh), array.push(zsoArr, s6_zso), array.push(zomArr, s6_zom), array.push(sharpeRankArr, f_rank_score(s6_sh)), array.push(sortinoRankArr, f_rank_score(s6_so)), array.push(omegaRankArr, f_rank_score(s6_om))
array.push(namesArr, getAssetName(sym7)), array.push(sharpeArr, s7_sh), array.push(sortinoArr2, s7_so), array.push(omegaArr2, s7_om), array.push(scoreArr, s7_sc), array.push(rankScoreArr, f_rank_score(s7_sc)), array.push(zshArr, s7_zsh), array.push(zsoArr, s7_zso), array.push(zomArr, s7_zom), array.push(sharpeRankArr, f_rank_score(s7_sh)), array.push(sortinoRankArr, f_rank_score(s7_so)), array.push(omegaRankArr, f_rank_score(s7_om))
array.push(namesArr, getAssetName(sym8)), array.push(sharpeArr, s8_sh), array.push(sortinoArr2, s8_so), array.push(omegaArr2, s8_om), array.push(scoreArr, s8_sc), array.push(rankScoreArr, f_rank_score(s8_sc)), array.push(zshArr, s8_zsh), array.push(zsoArr, s8_zso), array.push(zomArr, s8_zom), array.push(sharpeRankArr, f_rank_score(s8_sh)), array.push(sortinoRankArr, f_rank_score(s8_so)), array.push(omegaRankArr, f_rank_score(s8_om))
array.push(namesArr, getAssetName(sym9)), array.push(sharpeArr, s9_sh), array.push(sortinoArr2, s9_so), array.push(omegaArr2, s9_om), array.push(scoreArr, s9_sc), array.push(rankScoreArr, f_rank_score(s9_sc)), array.push(zshArr, s9_zsh), array.push(zsoArr, s9_zso), array.push(zomArr, s9_zom), array.push(sharpeRankArr, f_rank_score(s9_sh)), array.push(sortinoRankArr, f_rank_score(s9_so)), array.push(omegaRankArr, f_rank_score(s9_om))
array.push(namesArr, getAssetName(sym10)), array.push(sharpeArr, s10_sh), array.push(sortinoArr2, s10_so), array.push(omegaArr2, s10_om), array.push(scoreArr, s10_sc), array.push(rankScoreArr, f_rank_score(s10_sc)), array.push(zshArr, s10_zsh), array.push(zsoArr, s10_zso), array.push(zomArr, s10_zom), array.push(sharpeRankArr, f_rank_score(s10_sh)), array.push(sortinoRankArr, f_rank_score(s10_so)), array.push(omegaRankArr, f_rank_score(s10_om))
array.push(namesArr, getAssetName(sym11)), array.push(sharpeArr, s11_sh), array.push(sortinoArr2, s11_so), array.push(omegaArr2, s11_om), array.push(scoreArr, s11_sc), array.push(rankScoreArr, f_rank_score(s11_sc)), array.push(zshArr, s11_zsh), array.push(zsoArr, s11_zso), array.push(zomArr, s11_zom), array.push(sharpeRankArr, f_rank_score(s11_sh)), array.push(sortinoRankArr, f_rank_score(s11_so)), array.push(omegaRankArr, f_rank_score(s11_om))
array.push(namesArr, getAssetName(sym12)), array.push(sharpeArr, s12_sh), array.push(sortinoArr2, s12_so), array.push(omegaArr2, s12_om), array.push(scoreArr, s12_sc), array.push(rankScoreArr, f_rank_score(s12_sc)), array.push(zshArr, s12_zsh), array.push(zsoArr, s12_zso), array.push(zomArr, s12_zom), array.push(sharpeRankArr, f_rank_score(s12_sh)), array.push(sortinoRankArr, f_rank_score(s12_so)), array.push(omegaRankArr, f_rank_score(s12_om))
array.push(namesArr, getAssetName(sym13)), array.push(sharpeArr, s13_sh), array.push(sortinoArr2, s13_so), array.push(omegaArr2, s13_om), array.push(scoreArr, s13_sc), array.push(rankScoreArr, f_rank_score(s13_sc)), array.push(zshArr, s13_zsh), array.push(zsoArr, s13_zso), array.push(zomArr, s13_zom), array.push(sharpeRankArr, f_rank_score(s13_sh)), array.push(sortinoRankArr, f_rank_score(s13_so)), array.push(omegaRankArr, f_rank_score(s13_om))
array.push(namesArr, getAssetName(sym14)), array.push(sharpeArr, s14_sh), array.push(sortinoArr2, s14_so), array.push(omegaArr2, s14_om), array.push(scoreArr, s14_sc), array.push(rankScoreArr, f_rank_score(s14_sc)), array.push(zshArr, s14_zsh), array.push(zsoArr, s14_zso), array.push(zomArr, s14_zom), array.push(sharpeRankArr, f_rank_score(s14_sh)), array.push(sortinoRankArr, f_rank_score(s14_so)), array.push(omegaRankArr, f_rank_score(s14_om))
array.push(namesArr, getAssetName(sym15)), array.push(sharpeArr, s15_sh), array.push(sortinoArr2, s15_so), array.push(omegaArr2, s15_om), array.push(scoreArr, s15_sc), array.push(rankScoreArr, f_rank_score(s15_sc)), array.push(zshArr, s15_zsh), array.push(zsoArr, s15_zso), array.push(zomArr, s15_zom), array.push(sharpeRankArr, f_rank_score(s15_sh)), array.push(sortinoRankArr, f_rank_score(s15_so)), array.push(omegaRankArr, f_rank_score(s15_om))

sortSource = displayMode == "Sharpe" ? sharpeRankArr : displayMode == "Sortino" ? sortinoRankArr : displayMode == "Omega" ? omegaRankArr : rankScoreArr
sortedIdx = array.sort_indices(sortSource, order.descending)

// ─── One table ────────────────────────────────────────────────────────────────
var table t = table.new(f_pos(tablePosInput), 6, 17, bgcolor=color.new(color.black, 8), frame_color=color.white, frame_width=2, border_color=color.gray, border_width=1)

// ─── Draw ─────────────────────────────────────────────────────────────────────
if barstate.islast
    table.set_position(t, f_pos(tablePosInput))
    table.clear(t, 0, 0, 5, 16)

    if displayMode == "Metrics Table"
        table.cell(t, 0, 0, "Metrics Table", text_color=color.white, bgcolor=f_title_bg(), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.merge_cells(t, 0, 0, 3, 0)

        table.cell(t, 0, 1, "Ticker", text_color=color.white, bgcolor=f_header_bg(0), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 1, 1, "Sharpe", text_color=color.white, bgcolor=f_header_bg(1), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 2, 1, "Sortino", text_color=color.white, bgcolor=f_header_bg(2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 3, 1, "Omega", text_color=color.white, bgcolor=f_header_bg(3), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)

        for row = 0 to 14
            nm = array.get(namesArr, row)
            sh = array.get(sharpeArr, row)
            so = array.get(sortinoArr2, row)
            om = array.get(omegaArr2, row)

            table.cell(t, 0, row + 2, nm, text_color=color.white, bgcolor=f_asset_bg(row + 2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_italic)
            table.cell(t, 1, row + 2, f_fmt(sh), text_color=f_txt(sh), bgcolor=f_bg_sharpe(sh), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)
            table.cell(t, 2, row + 2, f_fmt(so), text_color=f_txt(so), bgcolor=f_bg_sortino(so), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)
            table.cell(t, 3, row + 2, f_fmt(om), text_color=f_txt(om), bgcolor=f_bg_omega(om), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)

            table.cell_set_text_font_family(t, 0, row + 2, font.family_default)
            table.cell_set_text_font_family(t, 1, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 2, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 3, row + 2, font.family_monospace)

    else if displayMode == "Z-Score"
        table.cell(t, 0, 0, "Z-Score Ranking", text_color=color.white, bgcolor=f_title_bg(), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.merge_cells(t, 0, 0, 5, 0)

        table.cell(t, 0, 1, "#", text_color=color.white, bgcolor=color.rgb(55, 55, 55), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 1, 1, "Ticker", text_color=color.white, bgcolor=f_header_bg(0), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=9)
        table.cell(t, 2, 1, "Sharpe Z", text_color=color.white, bgcolor=color.rgb(45, 45, 45), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=9)
        table.cell(t, 3, 1, "Sortino Z", text_color=color.white, bgcolor=color.rgb(45, 45, 45), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=9)
        table.cell(t, 4, 1, "Omega Z", text_color=color.white, bgcolor=color.rgb(45, 45, 45), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=9)
        table.cell(t, 5, 1, "Average", text_color=color.white, bgcolor=f_avgz_header_bg(), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=12)

        for row = 0 to 14
            idx = array.get(sortedIdx, row)
            nm = array.get(namesArr, idx)
            zsh = array.get(zshArr, idx)
            zso = array.get(zsoArr, idx)
            zom = array.get(zomArr, idx)
            sc = array.get(scoreArr, idx)

            table.cell(t, 0, row + 2, str.tostring(row + 1), text_color=color.rgb(220, 220, 220), bgcolor=f_asset_bg(row + 2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)
            table.cell(t, 1, row + 2, nm, text_color=color.white, bgcolor=f_asset_bg(row + 2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_italic)
            table.cell(t, 2, row + 2, f_fmt(zsh), text_color=f_txt(zsh), bgcolor=f_bg_z(zsh), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, width=9)
            table.cell(t, 3, row + 2, f_fmt(zso), text_color=f_txt(zso), bgcolor=f_bg_z(zso), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, width=9)
            table.cell(t, 4, row + 2, f_fmt(zom), text_color=f_txt(zom), bgcolor=f_bg_z(zom), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, width=9)
            table.cell(t, 5, row + 2, f_fmt(sc), text_color=f_avgz_txt(sc), bgcolor=f_avgz_bg(sc), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold, width=12)

            table.cell_set_text_font_family(t, 0, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 1, row + 2, font.family_default)
            table.cell_set_text_font_family(t, 2, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 3, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 4, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 5, row + 2, font.family_monospace)

    else
        table.cell(t, 0, 0, f_metric_title(), text_color=color.white, bgcolor=f_title_bg(), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.merge_cells(t, 0, 0, 2, 0)

        table.cell(t, 0, 1, "#", text_color=color.white, bgcolor=color.rgb(55, 55, 55), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 1, 1, "Ticker", text_color=color.white, bgcolor=f_header_bg(0), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)
        table.cell(t, 2, 1, f_metric_header(), text_color=color.white, bgcolor=f_header_bg(1), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)

        for row = 0 to 14
            idx = array.get(sortedIdx, row)
            nm = array.get(namesArr, idx)
            val = displayMode == "Sharpe" ? array.get(sharpeArr, idx) : displayMode == "Sortino" ? array.get(sortinoArr2, idx) : array.get(omegaArr2, idx)

            table.cell(t, 0, row + 2, str.tostring(row + 1), text_color=color.rgb(220, 220, 220), bgcolor=f_asset_bg(row + 2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)
            table.cell(t, 1, row + 2, nm, text_color=color.white, bgcolor=f_asset_bg(row + 2), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_italic)
            table.cell(t, 2, row + 2, f_fmt(val), text_color=f_txt(val), bgcolor=f_metric_bg(val), text_size=size.normal, text_halign=text.align_center, text_valign=text.align_center)

            table.cell_set_text_font_family(t, 0, row + 2, font.family_monospace)
            table.cell_set_text_font_family(t, 1, row + 2, font.family_default)
            table.cell_set_text_font_family(t, 2, row + 2, font.family_monospace)
````
