# Intermarket Confluence Engine | Anonycryptous

- url: https://www.tradingview.com/script/2dBTYgkg-Intermarket-Confluence-Engine-Anonycryptous/
- type: indicator
- pine_id: PUB;626c6f45ee8e4b2a9436d36b198e1a53
- version: 1.0

## Description

Intermarket Confluence Engine (ICE) | Anonycryptous
Description & user manual

Why this indicator exists
Most indicators analyze one asset in isolation. They look at price, momentum, volume, or volatility — all on the same chart, all based on the same data feed. That is useful, but it leaves out the context that drives markets at a deeper level: the relationship between assets, the macro regime, the direction of capital flow across instruments.

ICE approaches the problem differently.
Instead of analyzing a single price series, it takes two assets and computes their ratio. That ratio becomes the subject of analysis — not the individual prices. The result is a view of relative strength, regime state, and intermarket context that no single-asset indicator can produce.

It runs eight independent analytical engines on that ratio. Each engine returns a directional score. Those scores are weighted based on the selected asset class and combined into a single confluence number from -10 to +10. The dashboard shows the engine breakdown, the macro state, and the current statistical position of the ratio in its historical distribution — all in one compact panel.

ICE is not a signal indicator. It does not tell you when to buy or sell. It tells you what the current relationship between two assets looks like across eight independent dimensions, and how much those dimensions agree with each other.

Important notice
ICE does not generate trading signals.
It does not tell you when to buy or sell.
It does not predict market direction.
It does not guarantee any outcome.
All trading decisions remain entirely with the user.
Always apply your own judgment and manage your own risk.

1. Overview
ICE is a ratio-based intermarket confluence scoring system. It takes two configurable assets, computes their price ratio (Asset A divided by Asset B), and runs that ratio through eight analytical engines simultaneously.

The nine engines are:
- Relative strength — how much Asset A is outperforming or underperforming Asset B on a rate-of-change basis
- Trend — EMA structure and slope direction of the ratio
- Momentum — volume-weighted RSI and MACD histogram alignment on the ratio
- Volatility — Bollinger Band width, ATR percentile, and squeeze state of the ratio
- Statistical extremes — Z-score and historical percentile position of the ratio
- Macro regime — direction of DXY, VIX, and 10-year Treasury yields
- Liquidity — yield curve proxy using 10-year yield rate of change
- Intermarket correlation — rolling correlation between the ratio and each macro feed
- Volume participation — OBV slope and relative volume confirmation on both assets

Each engine is weighted based on the selected asset class. A custom weighting mode is available for manual control. All weights are normalized so the final score always maps to the -10 to +10 range regardless of class selection.

The chart displays the ratio as a line with an EMA stack (21, 50, 200), Bollinger Bands, and statistical deviation bands based on Z-score distance from the historical mean. Signals fire when confluence crosses configurable thresholds. Divergence between the ratio and its volume-weighted RSI is detected mechanically and shown on the chart.

2. The ratio
2.1 What it represents
The ratio is simply the price of Asset A divided by the price of Asset B. If Asset A is gold (XAUUSD) and Asset B is silver (XAGUSD), the ratio is the gold/silver ratio — how many ounces of silver one ounce of gold can buy. If Asset A is NQ futures and Asset B is ES futures, the ratio represents the relative performance of tech versus the broad market.
The ratio rises when Asset A outperforms Asset B. It falls when Asset B outperforms Asset A. All eight engines work on this ratio, not on the underlying prices.

2.2 What is plotted
The ratio line is the primary visual element. It is colored gold when above its 50-period EMA and grey when below. The EMA stack (green for the 21, blue for the 50, white for the 200) shows the structural state of the ratio trend.
Two band systems are visible simultaneously:
Statistical deviation bands — based on Z-score. The upper band is the historical mean plus 2 standard deviations (configurable). The lower band is the mean minus 2 standard deviations. When the ratio is near or beyond these bands, the Statistical engine activates and the dashboard notes an extreme condition.
Bollinger Bands — a separate volatility-based band using a configurable period and multiplier. These bands are lighter and secondary to the statistical bands.
Squeeze markers appear as small squares along the statistical mean when the Bollinger Bands are contained inside the Keltner Channel — indicating compressed volatility and a potential breakout.

2.3 Signal markers
Signals are plotted directly on the ratio chart using triangles and circles. All markers use plotshape, not labels.
Large triangles up (green) — strong bull confluence (score above +6)
Large triangles down (red) — strong bear confluence (score below -6)
Small triangles up (faded green) — moderate bull confluence (score between +3.5 and +6)
Small triangles down (faded red) — moderate bear confluence (score between -3.5 and -6)
Cyan circles — bullish momentum divergence aligned with positive score
Orange circles — bearish momentum divergence aligned with negative score
Purple squares — active volatility squeeze

3. The eight engines
3.1 Relative strength engine
This engine measures how much Asset A is outperforming Asset B on a rate-of-change basis. It computes the ROC of each asset independently over a configurable period (default 14) and subtracts them to get a delta. That delta is then Z-score normalized over a longer lookback (default 50) to assess whether the current outperformance is historically significant.
The engine also tracks the velocity of the ratio itself — the first derivative of the ratio — and whether the ratio is above its own EMA.
Score: +1 when the RS Z-score is above 0.5 and the ratio is above its EMA. -1 when the RS Z-score is below -0.5 and the ratio is below its EMA. 0 otherwise.
The dashboard shows the raw RS Z-score in the state section so you can see how far from neutral the relative strength is reading.

3.2 Trend engine
The trend engine evaluates the EMA alignment of the ratio across three periods (21, 50, 200), the slope direction using linear regression, and optionally a higher timeframe EMA confirmation.
A full bull stack is when EMA 21 is above EMA 50 and EMA 50 is above EMA 200, combined with a positive slope. A full bear stack is the reverse. Transitional states occur when the stack is broken but slope still has a direction.
The HTF trend filter uses a configurable higher timeframe (default weekly) and checks whether the chosen asset is above its 50-period EMA on that timeframe. When enabled, the trend engine only scores positively if the HTF also confirms.
Score: +1 for confirmed bull trend. -1 for confirmed bear trend. 0 for compression or transition.
The trend state shown in the dashboard (Expansion, Contraction, Transitional, Compression) reflects the combination of stack state and slope direction.

3.3 Momentum engine
The momentum engine uses a volume-weighted RSI applied to the ratio. The weighting uses the combined average volume of both assets, normalized by its own moving average. This is the same architecture as VW RSI Pro — gains and losses are scaled by relative volume before the RSI calculation, so bars with above-average volume have more influence on the RSI than bars with below-average volume.
Alongside the VW RSI, the engine computes MACD histogram acceleration (the change in histogram value, not just its level). This distinguishes between momentum that is building and momentum that is present but decelerating.
Score: +1 when VW RSI is above 52 and MACD histogram is positive. -1 when VW RSI is below 48 and MACD histogram is negative. 0 otherwise.
The VW RSI value is shown in the state section of the dashboard. Values above 55 are colored green, below 45 red, between them grey.

3.4 Volatility engine
The volatility engine assesses whether the ratio is in a phase of compression or expansion, and which direction expansion is occurring.
It computes Bollinger Band width relative to its 100-bar average — widening bands indicate expansion, narrowing bands indicate compression. ATR percentile rank over a configurable lookback (default 100 bars) provides a second volatility measure. A squeeze is identified when the Bollinger Bands are fully contained within the Keltner Channel.
Score: +1 when volatility is expanding and the ratio is above the Bollinger midline, or when a squeeze releases upward. -1 for the same conditions in the downward direction. 0 during compression or neutral volatility states.
The vol state (Squeeze, Breakout, Expansion, Compression, Neutral) is shown in the dashboard state section. Squeeze appears in purple, breakout in gold, expansion in the configured bull color.

3.5 Statistical extremes engine
This engine measures where the current ratio stands within its own historical distribution. It computes a Z-score of the ratio over a configurable lookback (default 50) and a historical percentile rank over a longer window (default 252 bars, approximately one year of daily data).
When the ratio is more than 1.5 standard deviations above its mean and above the 80th percentile, it is classified as historically expensive — a potential mean reversion candidate to the downside. When it is more than 1.5 standard deviations below its mean and below the 20th percentile, it is historically cheap — a potential mean reversion candidate to the upside.
Score: +1 at extreme lows (below mean, below 20th percentile). -1 at extreme highs (above mean, above 80th percentile). 0 within normal range.
The Z-score and historical percentile are shown in the dashboard state section. A gold highlight on the Z-score indicates an active extreme condition.
The mean reversion probability displayed in the extended panel is a normalized version of the absolute Z-score distance — a rough proxy for how far the ratio has stretched from its historical center. It is not a probability in the statistical sense, but a relative measure of extension.

3.6 Macro regime engine
The macro regime engine uses three external data feeds — DXY (dollar index), VIX (volatility index), and TNX (10-year Treasury yield) — loaded via request.security(). It evaluates the trend direction of each feed relative to a smoothed EMA (configurable length, default 20) and classifies the current macro environment.
The global regime classification (Risk-On / Risk-Off / Mixed) appears in the dashboard header. It is always based on the same three-signal count regardless of asset class: VIX level, DXY trend, and yield direction.
The macro score, however, is class-aware. Each asset class has its own logic:
Gold / Silver — risk-off conditions (elevated VIX, falling yields, falling dollar) favor Asset A (gold). Risk-on conditions (low VIX, rising yields, rising dollar) favor Asset B (silver outperforms on industrial demand). Score is +1 for acute risk-off, -1 for sustained risk-on.
Crypto — DXY direction is the primary gatekeeper. Falling DXY and falling yields are bullish for crypto. Rising DXY and rising yields are bearish. VIX provides a third signal. Two of the three conditions must align for a score to fire.
Forex — trend-following regime logic. Risk-on environments favor the ratio direction, risk-off favors the reverse.
Indices — same structure as Forex. Risk-on = positive bias.
Commodities — DXY-led. Falling dollar supports commodity ratios.
Score: +1 for regime favorable to Asset A. -1 for regime favorable to Asset B. 0 for mixed.

3.7 Liquidity engine
The liquidity engine uses the 10-year Treasury yield (TNX) rate of change as a proxy for liquidity conditions. Falling long-term yields indicate looser financial conditions — lower cost of capital, more risk appetite. Rising yields indicate tightening.
The TNX rate of change is computed over 20 bars and smoothed with a 10-bar EMA. When the smoothed ROC is below -0.1, conditions are classified as expanding. Above +0.1, contracting.
Score logic is class-aware:
- Gold / Silver — expanding liquidity (falling yields) is positive for the ratio since gold benefits more from low rates. Contracting is negative.
- Crypto — same direction. Loose liquidity benefits risk assets.
- Forex — inverted. Rising yields support yield-differential-driven pairs.
- Other classes — expansion is positive.
Score: +1 for favorable liquidity, -1 for unfavorable, 0 for neutral.

3.8 Intermarket correlation engine
This engine computes the rolling Pearson correlation between the ratio and each macro feed (DXY, VIX, TNX) over a configurable window (default 30 bars). It then assesses whether the current correlations match the expected structural behavior for the selected asset class.
For the Gold/Silver ratio, for example, historically the ratio is positively correlated with VIX (risk-off pushes gold relative to silver) and negatively correlated with DXY (weaker dollar benefits silver less). When those correlations are in place and above a threshold (±0.15), the engine confirms the macro alignment.
A correlation shift is detected when the sign of a correlation flips compared to 10 bars ago — this is flagged in the dashboard as a regime change signal.
Score: +1 when correlations confirm expected behavior for Asset A outperformance. -1 when they confirm the reverse. 0 when correlations are below threshold or mixed.

3.9 Volume participation engine
This engine measures whether the volume behind the ratio's current move confirms its direction. It uses two inputs: the relative volume difference between Asset A and Asset B, and the slope of the on-balance volume (OBV) calculated on the ratio.
The relative volume comparison checks whether Asset A is attracting more volume than Asset B relative to their combined average. When Asset A draws disproportionately more volume, it indicates institutional interest in the primary asset. The OBV slope uses a 20-bar linear regression to determine whether cumulative directional volume is rising or falling.
A bullish confirmation requires the OBV slope to be positive, the ratio to be above its 21 EMA, and Asset A to have higher relative volume. A bearish confirmation requires the reverse. When volume diverges from price direction — OBV falling while price rises, or vice versa — this is flagged in the extended panel as a volume divergence warning.
Score: +1 when volume participation confirms the ratio move upward. -1 when it confirms downward. 0 when volume is inconclusive or mixed.

4. Adaptive weighting
Each engine returns -1, 0, or +1. Each score is multiplied by the engine's weight for the selected asset class. The sum of all nine weighted scores is normalized against the total possible weight to produce the final confluence score on a -10 to +10 scale.

Asset class presets:
Gold / Silver — statistical extremes and macro regime are weighted most heavily (14 each). This reflects the GSR's mean-reverting nature and strong sensitivity to macro conditions. Volume participation carries moderate weight — on the GSR, volume confirmation is useful but less decisive than macro state.
Crypto — liquidity and momentum are weighted most heavily (14 each). Volume participation also carries elevated weight, since capital rotation between an asset and stablecoins is directly visible in relative volume.
Forex — trend and correlation are weighted most heavily (14 each). Currency pairs respond to trend conditions and intermarket relationships more reliably than statistical extremes.
Indices — momentum and liquidity are weighted most heavily (14 each). Volume participation also carries elevated weight — index futures moves backed by strong volume are more reliable than low-volume drifts.
Commodities — relative strength and volatility are weighted most heavily (14 each). Volume participation carries moderate weight since commodity ratio moves are often driven by volume imbalances between the two assets.
Custom — all nine weights are individually configurable from 0 to 20.
The confidence percentage shown in the dashboard is the spread between the normalized bull and bear score components — a measure of how much the engines agree rather than merely how many fire.

5. Dashboard
The dashboard is a single compact panel with four columns and thirteen rows. It shows the complete scoring state, engine breakdown, and market context in one place.
Header row — indicator name, asset class, confluence label, and score out of 10. The header color reflects the net score direction.
Confidence and regime row — confidence percentage and the global macro regime (Risk-On / Risk-Off / Mixed).
Engine scores — eight engines displayed two per row across four columns. Each engine shows its label and its weighted score with direction indicator. A green upward triangle indicates a positive contribution. A red downward triangle indicates a negative contribution. A grey dot indicates a neutral score.
State section — trend state, volatility state, VW RSI value, and Z-score. The trend state label (Expansion, Contraction, Transitional, Compression) reflects the combination of EMA alignment and slope. The vol state (Squeeze, Breakout, Expansion, Compression, Neutral) reflects the Bollinger/Keltner relationship.
Macro feeds — DXY direction, VIX level, 10-year yield direction, and current divergence state.
Brand footer — version reference.
The extended macro panel (disabled by default) can be enabled in settings for a second panel showing full correlation values, ATR percentile, statistical state detail, OBV slope, volume participation score, volume divergence flag, and liquidity state.

6. Asset pair configuration
6.1 Gold/Silver ratio (GSR)
The gold/silver ratio is the primary design case for ICE. It measures how many ounces of silver are required to buy one ounce of gold. Historically the ratio has ranged between 15 and 120. It is mean-reverting over long cycles but can trend persistently for months or years.
Recommended setup:
- Asset A: OANDA:XAUUSD
- Asset B: OANDA:XAGUSD
- Asset class: Gold / Silver
The statistical extremes engine is particularly relevant here. When the ratio is near historical highs (above the 80th percentile, Z-score above 1.5), silver has historically outperformed gold significantly over the following months. When near historical lows, gold has tended to recover its premium.
The macro regime engine is also central. Acute risk-off events (2008, 2020) spike the GSR rapidly as gold outperforms. Sustained risk-on environments with rising yields and industrial demand tend to compress it.

6.2 Crypto setups
For crypto ratio analysis, stablecoin dominance (CRYPTOCAP:USDT.D) as Asset B provides a direct view of capital rotation between an asset and cash equivalents. When the ratio rises, the asset is gaining relative to stablecoins — capital is flowing in. When it falls, capital is rotating out.
Recommended setups:
- BINANCE:BTCUSDT / CRYPTOCAP:USDT.D — Bitcoin vs stablecoin dominance
- BINANCE:SOLUSDT / CRYPTOCAP:USDT.D — SOL vs stablecoin dominance
- BINANCE:ETHUSDT / CRYPTOCAP:USDT.D — ETH vs stablecoin dominance
- Asset class: Crypto for all of the above
BTC.D (Bitcoin dominance, CRYPTOCAP:BTC.D) as Asset B can be used to measure altcoin performance relative to Bitcoin specifically — useful for identifying altseason conditions.

6.3 NQ futures setups
For Nasdaq and MNQ trading, ratio analysis provides directional and regime context.
Recommended setups:
- CME_MINI:NQ1! / CME_MINI:ES1! — Nasdaq vs S&P 500. When this ratio rises, tech is outperforming the broad market. A falling ratio suggests defensive rotation or underperformance of growth. Asset class: Indices.
- CME_MINI:NQ1! / CME_MINI:RTY1! — Nasdaq vs Russell 2000. Large-cap growth vs small-cap. Risk appetite proxy. Asset class: Indices.
- CME_MINI:NQ1! / TVC:DXY — NQ relative to dollar strength. Strong inverse relationship historically. Asset class: Indices.

6.4 Precious metals and commodities
- OANDA:XAUUSD / TVC:DXY — gold relative to dollar. One of the cleanest inverse relationships in macro markets. Asset class: Commodities or Gold/Silver.
- OANDA:XAUUSD / CME_MINI:ES1! — gold vs equities. Risk-off proxy. When this ratio rises, gold is outperforming stocks. Asset class: Commodities.
- TVC:USOIL / TVC:NATGAS — oil vs natural gas relative value. Asset class: Commodities.

6.5 Forex setups
For currency pairs, use the pair itself as a ratio — Asset A as the base currency ETF or index, Asset B as the quote. Alternatively, use currency index feeds directly.
- FX:EURUSD as a direct entry (ratio of EUR to USD)
- TVC:DXY / FX:EURUSD — dollar index vs euro. Asset class: Forex.

7. Macro feeds
The three macro feeds are loaded via request.security() and must resolve on TradingView.
Default symbols:
- DXY: TVC:DXY
- VIX: CBOE:VIX
- 10-year yield: TVC:TNX
These can be changed in the Macro Feeds settings group if alternative data sources are preferred. Each feed can be individually disabled — if all three are disabled, the macro regime, liquidity, and correlation engines return neutral (0) scores.
On lower timeframes (1m, 3m), macro feeds may have limited bar history, which can cause some engines to return neutral until sufficient data is loaded. From 15m and higher, all engines should be fully active. On very low timeframes, the statistical engines also require a minimum number of bars before the lookbacks are satisfied.

8. How to use
8.1 Reading the score
The confluence score on a -10 to +10 scale communicates direction and intensity simultaneously. It does not communicate timing.

A score of +7 with 70% confidence means six or seven engines are aligned in a bullish direction for Asset A relative to Asset B, with the weighted agreement being high. It does not mean a trade should be entered immediately — it means the current relative conditions strongly favor Asset A.
A score near 0 with low confidence means the engines are split. This is not a bearish signal — it is the absence of a clear signal. In practice, scores between -3 and +3 with confidence below 40% suggest the ratio is in a mixed or transitional regime.

8.2 Using the score with price action
ICE works on the ratio — not on the underlying price. To apply it to a trade on the underlying asset, you need to interpret the score in context.
On a BTC/USDT.D ratio chart with a score of -7, the ratio is falling — BTC is losing ground relative to stablecoin dominance. This is a macro tailwind for a bearish BTC view. It does not tell you where to enter or where to put your stop. It tells you the broader relative conditions are bearish.
Combine ICE with a price-action tool, a structure indicator, or an entry system applied to the actual trading instrument. ICE provides the regime and relative context. The entry decision remains with the user.

8.3 Divergence signals
When the ratio makes a lower low but the VW RSI makes a higher low, a bullish divergence is detected. When the ratio makes a higher high but the VW RSI makes a lower high, a bearish divergence is detected. These are mechanical detections using pivot analysis.
Divergence signals that align with the net confluence score carry more weight. A bullish divergence on a ratio that is already scoring positively on four or five engines is a stronger condition than a divergence in an otherwise neutral scoring environment. Cyan circles mark bull divergence, orange circles mark bear divergence.

8.4 Squeeze and volatility breakouts
When the volatility engine identifies a squeeze (Bollinger Bands inside the Keltner Channel), a purple square appears along the statistical mean line. This indicates compressed volatility and an elevated probability of a significant directional move.
When the squeeze releases, the volatility engine contributes its score in the direction of the breakout. Combined with trend and momentum alignment, a squeeze release can produce a rapid score shift. These moments are marked on the chart and flagged in the dashboard vol state row.

8.5 Statistical extremes
The statistical engine is most useful on the Gold/Silver ratio and other fundamentally mean-reverting pairs. When the Z-score exceeds 1.5 and the ratio is in the top 20% of its historical range, the statistical engine scores negatively — signaling that the ratio has historically tended to revert from this level.
This is not a timing signal. The ratio can remain at extremes for weeks or months. The statistical engine scores the degree of extension, not the moment of reversal. Use it alongside momentum and trend engines to assess whether the extreme is beginning to resolve.

9. Settings reference
Asset configuration
- Asset A — the primary asset. Default: XAUUSD.
- Asset B — the secondary asset. Default: XAGUSD. The ratio is Asset A divided by Asset B.
- Plot ratio line — toggles the main ratio line on the chart.
- Plot ratio EMAs — toggles the 21/50/200 EMA stack on the ratio.
- Plot std dev bands — toggles the statistical deviation bands and Bollinger Bands.

Asset class and weighting
- Asset class — selects the weighting preset. Options: Gold/Silver, Crypto, Forex, Indices, Commodities, Custom.

- Individual weight inputs — only active in Custom mode. Each engine can be weighted from 0 to 20.

Macro feeds
- Use DXY / VIX / TNX — individual toggles for each macro feed.
- DXY / VIX / TNX symbol — configurable symbols. Defaults: TVC:DXY, CBOE:VIX, TVC:TNX.
- Macro smoothing — EMA length for the macro feed trend detection. Default 20.

Relative strength engine
- ROC length — rate of change period for both assets. Default 14.
- RS EMA length — EMA applied to the ratio for trend confirmation. Default 21.
- RS Z-score lookback — lookback for normalization of the RS delta. Default 50.

Trend engine
- Fast / Slow / Macro EMA — the three EMA periods for the ratio. Defaults: 21, 50, 200.
- MTF trend filter — enables the higher timeframe confirmation gate.
- HTF timeframe — the timeframe used for the HTF EMA check. Default weekly.

Momentum engine
- RSI length — period for the VW RSI calculation. Default 14.
- Volume smoothing — SMA length for volume normalization. Default 14.
- Volume weighted RSI — enables volume weighting on the RSI. Default on.
- MACD fast / slow / signal — MACD parameters applied to the ratio. Defaults: 12, 26, 9.

Volatility engine
- BB length / BB multiplier — Bollinger Band parameters. Defaults: 20, 2.0.
- ATR length — period for ATR calculation. Default 14.
- ATR percentile lookback — historical window for ATR percentile ranking. Default 100.
- Squeeze KC length / multiplier — Keltner Channel parameters for squeeze detection. Defaults: 20, 1.5.

Statistical extremes engine
- Z-score lookback — window for Z-score calculation. Default 50.
- Percentile lookback — historical window for percentile ranking. Default 252 (approximately one year of daily data).
- Z-score extreme threshold — standard deviations from mean required to classify as extreme. Default 1.5.

Correlation engine
- Correlation window — rolling window for Pearson correlation. Default 30.

Visuals
- Bull / bear / neutral color — configurable colors for all directional elements.
- Ratio line color — color of the main ratio line.
- Show score background — colors the pane background faintly by net score direction.
- Background transparency — transparency level for the score background. Default 93.

Dashboard
- Show dashboard — master toggle. Default on.
- Position — Top Left, Top Right, Bottom Left, Bottom Right. Default Bottom Right.
- Size — Tiny, Small, Normal. Default Tiny.
- Show extended macro panel — enables a second panel with full correlation, volume, and statistical detail. Default off. Recommended for desktop only.

10. Notes
- ICE operates on a ratio of two assets. If either asset has no data on the current chart timeframe, the ratio will be unavailable and the engines will not fire. Ensure both symbols resolve correctly in TradingView before interpreting the dashboard.
- The macro feeds (DXY, VIX, TNX) are loaded separately via request.security(). On lower timeframes, the feed data may require a few bars to warm up before producing stable readings. All engines should be fully active from the 15m timeframe and above.
- The volume used by the momentum engine is the combined average of both asset volumes. On ratio pairs where one or both assets have zero or unavailable volume (such as some index feeds), the volume-weighted RSI falls back to an unweighted RSI automatically.
- All statistical calculations (Z-score, percentile rank) require a minimum number of bars equal to the lookback period. On charts with limited history or very short timeframes, these engines may return neutral until sufficient bars are loaded.
- The correlation engine requires both assets to have non-constant price series over the correlation window. On very stable or pegged assets, correlation may be undefined and the engine returns neutral.
- ICE does not repaint. All scores and signals are based on confirmed bar data.
- The indicator is designed for ratio analysis. It can technically be used with a single asset by setting Asset B to a constant reference (such as a stablecoin or index), but it was built around the two-asset ratio concept and performs best in that context.

11. Disclaimer
This indicator is provided for educational and informational purposes only.
All outputs are based on historical price data and mathematical calculations.
Past behavior does not guarantee future results.
Trading involves substantial risk of loss.
Use at your own discretion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator("Intermarket Confluence Engine | Anonycryptous", shorttitle="ICE", overlay=false,
     max_labels_count=200, max_lines_count=200, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
// INTERMARKET CONFLUENCE ENGINE | Anonycryptous
// Relative Strength · Trend · Momentum · Volatility · Statistical
// Macro Regime · Liquidity · Correlation · Adaptive Score
// ═══════════════════════════════════════════════════════════════

// ─── Groups ───────────────────────────────────────────────────
string G_ASSET  = "════ Asset Configuration ════"
string G_CLASS  = "════ Asset Class & Weighting ════"
string G_MACRO  = "════ Macro Feeds ════"
string G_RS     = "════ Relative Strength Engine ════"
string G_TREND  = "════ Trend Engine ════"
string G_MOM    = "════ Momentum Engine ════"
string G_VOL    = "════ Volatility Engine ════"
string G_STAT   = "════ Statistical Extremes Engine ════"
string G_CORR   = "════ Correlation Engine ════"
string G_VIS    = "════ Visuals ════"
string G_DASH   = "════ Dashboard ════"

// ─── Asset Configuration ──────────────────────────────────────
string i_symA      = input.symbol("XAUUSD", "Asset A", group=G_ASSET,
     tooltip="Primary asset. The ratio is calculated as Asset A divided by Asset B. Default: Gold (XAUUSD).")
string i_symB      = input.symbol("XAGUSD", "Asset B", group=G_ASSET,
     tooltip="Secondary asset. Default: Silver (XAGUSD). Together with Asset A this produces the Gold/Silver Ratio.")
bool   i_showRatio = input.bool(true, "Plot Ratio Line", group=G_ASSET,
     tooltip="Plots the A/B price ratio as the main line on the chart. The line color changes based on whether the ratio is above or below its 50-period EMA.")
bool   i_showEMA   = input.bool(true, "Plot Ratio EMAs", group=G_ASSET,
     tooltip="Plots three EMAs on the ratio: fast (21), slow (50), and macro (200). Colors are configurable in the Visuals section.")
bool   i_showBands = input.bool(true, "Plot Bands", group=G_ASSET,
     tooltip="Plots two band systems on the ratio. Statistical deviation bands are based on Z-score distance from the historical mean. Bollinger Bands show standard volatility envelopes. Both use colors from the Visuals section.")

// ─── Asset Class ──────────────────────────────────────────────
string i_class = input.string("Gold / Silver", "Asset Class",
     options=["Gold / Silver", "Crypto", "Forex", "Indices", "Commodities", "Custom"],
     group=G_CLASS,
     tooltip="Sets the weighting profile for all eight engines. Each class emphasizes the engines most relevant to that market type. Gold/Silver weights statistical extremes and macro regime most heavily. Crypto weights liquidity and momentum. Forex weights trend and correlation. Indices weight momentum and liquidity. Commodities weight relative strength and volatility. Custom lets you set each engine weight individually.")

// Custom weights — only active when class = Custom
int i_wRS    = input.int(10, "Relative Strength Weight", minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Relative Strength engine. Only active when Asset Class is set to Custom.")
int i_wTR    = input.int(10, "Trend Weight",             minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Trend engine. Only active when Asset Class is set to Custom.")
int i_wMOM   = input.int(10, "Momentum Weight",          minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Momentum engine. Only active when Asset Class is set to Custom.")
int i_wVOL   = input.int(10, "Volatility Weight",        minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Volatility engine. Only active when Asset Class is set to Custom.")
int i_wSTAT  = input.int(10, "Statistical Weight",       minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Statistical Extremes engine. Only active when Asset Class is set to Custom.")
int i_wMACRO = input.int(10, "Macro Regime Weight",      minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Macro Regime engine. Only active when Asset Class is set to Custom.")
int i_wLIQ   = input.int(10, "Liquidity Weight",         minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Liquidity engine. Only active when Asset Class is set to Custom.")
int i_wCORR  = input.int(10, "Correlation Weight",       minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Intermarket Correlation engine. Only active when Asset Class is set to Custom.")
int i_wVOLP  = input.int(10, "Volume Participation Weight", minval=0, maxval=20, group=G_CLASS,
     tooltip="Weight for the Volume Participation engine. Only active when Asset Class is set to Custom.")

// ─── Macro Feeds ──────────────────────────────────────────────
bool   i_useDXY   = input.bool(true,  "Use DXY", group=G_MACRO,
     tooltip="Enables the US Dollar Index as a macro input. The dollar has a strong inverse relationship with gold, commodities, and most risk assets. A rising DXY is generally bearish for these markets.")
bool   i_useVIX   = input.bool(true,  "Use VIX", group=G_MACRO,
     tooltip="Enables the CBOE Volatility Index as a macro input. VIX measures implied volatility on the S&P 500 options market. Elevated VIX readings indicate risk-off conditions.")
bool   i_useTNX   = input.bool(true,  "Use TNX", group=G_MACRO,
     tooltip="Enables the 10-year US Treasury yield as a macro input. Rising yields increase the opportunity cost of holding non-yielding assets like gold and crypto, and signal tightening liquidity conditions.")
string i_symDXY   = input.symbol("TVC:DXY",   "DXY Symbol", group=G_MACRO,
     tooltip="TradingView symbol for the dollar index. Default: TVC:DXY.")
string i_symVIX   = input.symbol("CBOE:VIX",  "VIX Symbol", group=G_MACRO,
     tooltip="TradingView symbol for the volatility index. Default: CBOE:VIX.")
string i_symTNX   = input.symbol("TVC:TNX",   "TNX Symbol", group=G_MACRO,
     tooltip="TradingView symbol for the 10-year Treasury yield. Default: TVC:TNX.")
int    i_macroLen = input.int(20, "Macro EMA Length", minval=5, maxval=100, group=G_MACRO,
     tooltip="EMA period used to smooth each macro feed before comparing it to current price. A shorter value reacts faster to macro changes. A longer value filters out short-term noise and tracks the broader trend. Default 20.")

// ─── Relative Strength Engine ─────────────────────────────────
int i_rocLen   = input.int(14, "ROC Length", minval=2, group=G_RS,
     tooltip="Lookback period for the rate of change calculation on each asset. The RS delta is the difference between ROC(A) and ROC(B). Larger values capture longer-term momentum shifts.")
int i_rsEmaLen = input.int(21, "RS EMA Length", minval=2, group=G_RS,
     tooltip="EMA applied to the ratio itself for structural trend confirmation. The engine scores positively only when the ratio is also above this EMA.")
int i_rsZLen   = input.int(50, "RS Z-Score Lookback", minval=10, group=G_RS,
     tooltip="Lookback for normalizing the RS delta via Z-score. A score above 0.5 standard deviations is considered a significant outperformance by Asset A.")

// ─── Trend Engine ─────────────────────────────────────────────
int    i_ema21  = input.int(21,  "Fast EMA",  minval=2,  group=G_TREND,
     tooltip="Fast EMA period applied to the ratio. Used as the primary short-term trend reference.")
int    i_ema50  = input.int(50,  "Slow EMA",  minval=2,  group=G_TREND,
     tooltip="Slow EMA period applied to the ratio. Used as the medium-term structural reference.")
int    i_ema200 = input.int(200, "Macro EMA", minval=10, group=G_TREND,
     tooltip="Long-period EMA applied to the ratio. Defines the macro structural bias. When all three EMAs are aligned (21 above 50 above 200), the trend engine scores at full strength.")
bool   i_useHTF = input.bool(true, "MTF Trend Filter", group=G_TREND,
     tooltip="When enabled, the trend engine also checks whether Asset A is above its EMA on the selected higher timeframe. A trend score only fires if the HTF confirms the same direction.")
string i_htfTF  = input.timeframe("D", "HTF Timeframe", group=G_TREND,
     tooltip="The higher timeframe used for the MTF trend filter. Default: Daily. Change to Weekly for long-term setups.")

// ─── Momentum Engine ──────────────────────────────────────────
int   i_rsiLen  = input.int(14, "RSI Length", minval=2, group=G_MOM,
     tooltip="Period for the RSI calculation applied to the ratio. The RSI is optionally weighted by relative volume.")
int   i_volLen  = input.int(14, "Volume Smoothing", minval=2, group=G_MOM,
     tooltip="SMA period for normalizing the combined volume of both assets. Volume above this average is considered elevated and increases RSI bar weighting.")
bool  i_volWt   = input.bool(true, "Volume Weighted RSI", group=G_MOM,
     tooltip="When enabled, RSI gains and losses are scaled by the relative volume of the current bar before smoothing. Bars with above-average volume have more influence on the RSI. When disabled, the calculation uses standard unweighted RSI.")
int   i_macdF   = input.int(12, "MACD Fast",   minval=2, group=G_MOM,
     tooltip="Fast EMA period for the MACD applied to the ratio.")
int   i_macdS   = input.int(26, "MACD Slow",   minval=2, group=G_MOM,
     tooltip="Slow EMA period for the MACD applied to the ratio.")
int   i_macdSig = input.int(9,  "MACD Signal", minval=2, group=G_MOM,
     tooltip="Signal line period for the MACD. The engine scores when both the RSI threshold and MACD histogram direction agree.")

// ─── Volatility Engine ────────────────────────────────────────
int   i_bbLen     = input.int(20,  "BB Length",     minval=5, group=G_VOL,
     tooltip="Period for the Bollinger Bands applied to the ratio.")
float i_bbMult    = input.float(2.0, "BB Multiplier", minval=0.5, step=0.1, group=G_VOL,
     tooltip="Standard deviation multiplier for the Bollinger Bands. Higher values widen the bands and require more extreme moves to trigger expansion signals.")
int   i_atrLen    = input.int(14,  "ATR Length",    minval=2, group=G_VOL,
     tooltip="Period for ATR calculation on the ratio. Used for percentile ranking of current volatility.")
int   i_atrPctLen = input.int(100, "ATR Percentile Lookback", minval=20, group=G_VOL,
     tooltip="Historical lookback for ATR percentile ranking. A reading above 60% indicates above-average volatility, which contributes to the expansion classification.")
int   i_sqzLen    = input.int(20,  "Squeeze KC Length", minval=5, group=G_VOL,
     tooltip="Period for the Keltner Channel used to detect the volatility squeeze. A squeeze is active when the Bollinger Bands are fully inside the Keltner Channel.")
float i_sqzMult   = input.float(1.5, "Squeeze KC Multiplier", minval=0.1, step=0.1, group=G_VOL,
     tooltip="ATR multiplier for the Keltner Channel squeeze detection. Lower values make the squeeze condition easier to trigger.")

// ─── Statistical Extremes ─────────────────────────────────────
int   i_zLen     = input.int(50,  "Z-Score Lookback", minval=10, group=G_STAT,
     tooltip="Lookback period for Z-score calculation on the ratio. The Z-score measures how many standard deviations the current ratio is from its historical mean over this window.")
int   i_pctLen   = input.int(252, "Percentile Lookback", minval=50, group=G_STAT,
     tooltip="Historical lookback for percentile ranking. 252 approximates one year of daily bars. The engine scores when both the Z-score extreme and the percentile threshold are exceeded simultaneously.")
float i_zExtreme = input.float(1.5, "Z-Score Extreme Threshold", minval=0.5, step=0.1, group=G_STAT,
     tooltip="How many standard deviations from the mean the ratio must be before the engine classifies it as an extreme. At 1.5, approximately 13% of observations fall beyond this level historically. Lower values trigger more frequently, higher values trigger only at stronger extremes.")

// ─── Correlation Engine ───────────────────────────────────────
int i_corrLen = input.int(30, "Correlation Window", minval=10, group=G_CORR,
     tooltip="Rolling window for the Pearson correlation calculation between the ratio and each macro feed. Shorter windows are more reactive to recent regime changes. Longer windows provide a more stable structural reading.")

// ─── Visuals ──────────────────────────────────────────────────
color i_bullCol     = input.color(color.rgb(0, 255, 0),     "Bull Color",           group=G_VIS,
     tooltip="Color used for bullish signals, EMA 21, stat lower band fill, and positive score background.")
color i_bearCol     = input.color(color.rgb(255, 0, 0),     "Bear Color",           group=G_VIS,
     tooltip="Color used for bearish signals, stat upper band fill, and negative score background.")
color i_neutCol     = input.color(color.rgb(128, 128, 128), "Neutral Color",        group=G_VIS,
     tooltip="Color used for the ratio line when it is below the 50 EMA.")
color i_goldCol     = input.color(#f5c518,                  "Ratio Line Color",     group=G_VIS,
     tooltip="Color of the ratio line when it is above the 50 EMA.")
color i_ema21Col    = input.color(color.rgb(0, 255, 0),     "EMA 21 Color",         group=G_VIS)
color i_ema50Col    = input.color(#00bfff,                  "EMA 50 Color",         group=G_VIS)
color i_ema200Col   = input.color(color.rgb(255, 255, 255), "EMA 200 Color",        group=G_VIS)
color i_statUpCol   = input.color(color.rgb(255, 0, 0),     "Stat Upper Band Color",group=G_VIS,
     tooltip="Color of the upper statistical deviation band (Z-score extreme high). When the ratio is above this line, the Statistical engine classifies the ratio as historically expensive.")
color i_statDnCol   = input.color(color.rgb(0, 255, 0),     "Stat Lower Band Color",group=G_VIS,
     tooltip="Color of the lower statistical deviation band (Z-score extreme low). When the ratio is below this line, the Statistical engine classifies it as historically cheap.")
color i_statMidCol  = input.color(color.rgb(128, 128, 128), "Stat Mean Color",      group=G_VIS,
     tooltip="Color of the statistical mean line (center of the deviation bands). Squeeze markers appear along this line.")
color i_bbCol       = input.color(color.rgb(100, 149, 237), "BB Band Color",        group=G_VIS,
     tooltip="Color of the Bollinger Bands. These are lighter bands separate from the statistical deviation bands.")
color i_sqzCol      = input.color(color.rgb(73, 250, 3),                  "Squeeze Marker Color", group=G_VIS,
     tooltip="Color of the small square markers that appear along the stat mean line when a volatility squeeze is active.")
bool  i_showBg      = input.bool(true, "Show Score Background", group=G_VIS,
     tooltip="Colors the pane background faintly in the bull or bear color when the net confluence score exceeds 3 or falls below -3.")
int   i_bgTransp    = input.int(85, "Background Transparency", minval=10, maxval=99, group=G_VIS,
     tooltip="Transparency of the score background color. Higher values are more transparent.")
float i_sigStrong   = input.float(6.0, "Strong Signal Threshold", minval=1.0, maxval=10.0, step=0.5, group=G_VIS,
     tooltip="Confluence score required to show a strong signal marker (large triangle). Score runs from -10 to +10. Higher threshold = fewer signals. Default 6.0.")
float i_sigMod      = input.float(3.5, "Moderate Signal Threshold", minval=1.0, maxval=10.0, step=0.5, group=G_VIS,
     tooltip="Confluence score required to show a moderate signal marker (small faded triangle). Must be lower than the strong threshold. Default 3.5.")

// ─── Dashboard ────────────────────────────────────────────────
bool   i_showDash  = input.bool(true, "Show Dashboard", group=G_DASH)
string i_dashPos   = input.string("Bottom Right", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
string i_dashSz    = input.string("Tiny", "Size", options=["Tiny","Small","Normal"], group=G_DASH)
bool   i_showExt   = input.bool(false, "Show Extended Panel", group=G_DASH,
     tooltip="Shows a second panel with full correlation values, ATR percentile, OBV slope, statistical state detail, and mean reversion probability. Recommended for desktop only — disable on mobile or small screens.")

// ═══════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════
color C_GOLD  = #f5c518
color C_PURP  = #bb86fc
color C_BG    = color.new(#0d1117, 10)
color C_PANEL = color.new(#161b22, 0)
color C_BDR   = color.new(#30363d, 20)
color C_MUTED = color.new(#8b949e, 0)
color C_WHITE = color.new(#ffffff, 0)

// ═══════════════════════════════════════════════════════════════
// ADAPTIVE WEIGHTS
// ═══════════════════════════════════════════════════════════════
int wRS = 0, int wTR = 0, int wMOM = 0, int wVOL = 0
int wSTAT = 0, int wMACRO = 0, int wLIQ = 0, int wCORR = 0, int wVOLP = 0

if i_class == "Gold / Silver"
    wRS := 8,  wTR := 6,  wMOM := 6,  wVOL := 6
    wSTAT := 14, wMACRO := 14, wLIQ := 8, wCORR := 8,  wVOLP := 6
else if i_class == "Crypto"
    wRS := 8,  wTR := 8,  wMOM := 14, wVOL := 8
    wSTAT := 6,  wMACRO := 10, wLIQ := 14, wCORR := 8,  wVOLP := 10
else if i_class == "Forex"
    wRS := 10, wTR := 14, wMOM := 8,  wVOL := 6
    wSTAT := 8,  wMACRO := 10, wLIQ := 6,  wCORR := 14, wVOLP := 6
else if i_class == "Indices"
    wRS := 8,  wTR := 10, wMOM := 14, wVOL := 8
    wSTAT := 6,  wMACRO := 10, wLIQ := 12, wCORR := 8,  wVOLP := 10
else if i_class == "Commodities"
    wRS := 14, wTR := 8,  wMOM := 8,  wVOL := 12
    wSTAT := 10, wMACRO := 12, wLIQ := 6,  wCORR := 6,  wVOLP := 8
else
    wRS := i_wRS, wTR := i_wTR, wMOM := i_wMOM, wVOL := i_wVOL
    wSTAT := i_wSTAT, wMACRO := i_wMACRO, wLIQ := i_wLIQ, wCORR := i_wCORR, wVOLP := i_wVOLP

float totalWeight = float(wRS + wTR + wMOM + wVOL + wSTAT + wMACRO + wLIQ + wCORR + wVOLP)

// ═══════════════════════════════════════════════════════════════
// ASSET DATA
// ═══════════════════════════════════════════════════════════════
float closeA  = request.security(i_symA, timeframe.period, close)
float closeB  = request.security(i_symB, timeframe.period, close)
float highA   = request.security(i_symA, timeframe.period, high)
float lowA    = request.security(i_symA, timeframe.period, low)
float highB   = request.security(i_symB, timeframe.period, high)
float lowB    = request.security(i_symB, timeframe.period, low)
float volA    = request.security(i_symA, timeframe.period, volume)
float volB    = request.security(i_symB, timeframe.period, volume)

float dxyClose  = i_useDXY ? request.security(i_symDXY, timeframe.period, close) : na
float vixClose  = i_useVIX ? request.security(i_symVIX, timeframe.period, close) : na
float tnxClose  = i_useTNX ? request.security(i_symTNX, timeframe.period, close) : na

float htfEmaA   = i_useHTF ? request.security(i_symA, i_htfTF, ta.ema(close, i_ema50)) : na
float htfCloseA = i_useHTF ? request.security(i_symA, i_htfTF, close) : na

// ═══════════════════════════════════════════════════════════════
// RATIO
// ═══════════════════════════════════════════════════════════════
float ratio    = not na(closeA) and not na(closeB) and closeB != 0 ? closeA / closeB : na
float ratioEma21  = ta.ema(ratio, i_ema21)
float ratioEma50  = ta.ema(ratio, i_ema50)
float ratioEma200 = ta.ema(ratio, i_ema200)

// ═══════════════════════════════════════════════════════════════
// ENGINE 1 — RELATIVE STRENGTH
// ═══════════════════════════════════════════════════════════════
float rocA        = ta.roc(closeA, i_rocLen)
float rocB        = ta.roc(closeB, i_rocLen)
float rsDelta     = rocA - rocB
float rsDeltaMean = ta.sma(rsDelta, i_rsZLen)
float rsDeltaStd  = ta.stdev(rsDelta, i_rsZLen)
float rsZScore    = rsDeltaStd != 0 ? (rsDelta - rsDeltaMean) / rsDeltaStd : 0.0
bool  rsAboveEma  = ratio > ta.ema(ratio, i_rsEmaLen)
int   rsScore     = rsZScore > 0.5 and rsAboveEma ? 1 : rsZScore < -0.5 and not rsAboveEma ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 2 — TREND
// ═══════════════════════════════════════════════════════════════
bool   trendBullStack = ratioEma21 > ratioEma50 and ratioEma50 > ratioEma200
bool   trendBearStack = ratioEma21 < ratioEma50 and ratioEma50 < ratioEma200
bool   trendAbove200  = ratio > ratioEma200
float  ratioSlope     = ta.linreg(ratio, 20, 0) - ta.linreg(ratio, 20, 1)
bool   htfBull        = i_useHTF and not na(htfCloseA) and not na(htfEmaA) ? htfCloseA > htfEmaA : true
bool   htfBear        = i_useHTF and not na(htfCloseA) and not na(htfEmaA) ? htfCloseA < htfEmaA : true
bool   trendBull      = (trendBullStack or (ratio > ratioEma50 and trendAbove200)) and ratioSlope > 0 and (not i_useHTF or htfBull)
bool   trendBear      = (trendBearStack or (ratio < ratioEma50 and not trendAbove200)) and ratioSlope < 0 and (not i_useHTF or htfBear)
string trendState     = trendBull ? "EXPANSION ▲" : trendBear ? "CONTRACTION ▼" : ratioSlope > 0 ? "TRANSITIONAL ▲" : ratioSlope < 0 ? "TRANSITIONAL ▼" : "COMPRESSION ●"
int    trendScore     = trendBull ? 1 : trendBear ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 3 — MOMENTUM (Volume Weighted RSI + MACD)
// ═══════════════════════════════════════════════════════════════
float combinedVol      = (volA + volB) / 2
float combinedVolSma   = ta.sma(combinedVol, i_volLen)
float combinedVolRatio = combinedVolSma != 0 ? combinedVol / combinedVolSma : 1.0
float priceChg         = ta.change(ratio)
float wtGain = i_volWt ? math.max(priceChg, 0) * combinedVolRatio : math.max(priceChg, 0)
float wtLoss = i_volWt ? math.max(-priceChg, 0) * combinedVolRatio : math.max(-priceChg, 0)
float avgGain = ta.rma(wtGain, i_rsiLen)
float avgLoss = ta.rma(wtLoss, i_rsiLen)
float rs_m    = avgLoss == 0 ? 100.0 : avgGain / avgLoss
float vwRsi   = 100.0 - 100.0 / (1.0 + rs_m)
float macdLine = ta.ema(ratio, i_macdF) - ta.ema(ratio, i_macdS)
float macdSigL = ta.ema(macdLine, i_macdSig)
float macdHist = macdLine - macdSigL
bool  momBull  = vwRsi > 52 and macdHist > 0
bool  momBear  = vwRsi < 48 and macdHist < 0
int   momScore = momBull ? 1 : momBear ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 4 — VOLATILITY (BB Width + ATR Percentile + Squeeze)
// ═══════════════════════════════════════════════════════════════
float bbBasis    = ta.sma(ratio, i_bbLen)
float bbDev      = i_bbMult * ta.stdev(ratio, i_bbLen)
float bbUpper    = bbBasis + bbDev
float bbLower    = bbBasis - bbDev
float bbWidth    = (bbUpper - bbLower) / bbBasis
float bbWMean    = ta.sma(bbWidth, 100)
float atrRatio   = ta.atr(i_atrLen)
float atrPctRank = ta.percentrank(atrRatio, i_atrPctLen) / 100.0
float kcBasis    = ta.ema(ratio, i_sqzLen)
float kcRange    = ta.atr(i_sqzLen) * i_sqzMult
float kcUpper    = kcBasis + kcRange
float kcLower    = kcBasis - kcRange
bool  inSqueeze  = bbUpper < kcUpper and bbLower > kcLower
bool  sqzRelease = not inSqueeze and inSqueeze[1]
bool  volExpanding  = bbWidth > bbWMean and atrPctRank > 0.6
bool  volCompressed = bbWidth < bbWMean * 0.7 or inSqueeze
string volState  = inSqueeze ? "SQUEEZE ●" : sqzRelease ? "BREAKOUT ⚡" : volExpanding ? "EXPANSION ▲" : volCompressed ? "COMPRESSION ●" : "NEUTRAL ●"
int   volScore   = volExpanding and ratio > bbBasis ? 1 : volExpanding and ratio < bbBasis ? -1 : sqzRelease and ratio > kcBasis ? 1 : sqzRelease and ratio < kcBasis ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 5 — STATISTICAL EXTREMES (Z-Score + Percentile)
// ═══════════════════════════════════════════════════════════════
float zMean          = ta.sma(ratio, i_zLen)
float zStd           = ta.stdev(ratio, i_zLen)
float zScore         = zStd != 0 ? (ratio - zMean) / zStd : 0.0
float pctRank        = ta.percentrank(ratio, i_pctLen) / 100.0
bool  statExtremeLow = zScore < -i_zExtreme and pctRank < 0.20
bool  statExtremeHigh = zScore > i_zExtreme and pctRank > 0.80
float mrProb         = math.min(math.abs(zScore) / (i_zExtreme * 2), 1.0)
string statState     = statExtremeLow ? "EXTREME LOW ▲" : statExtremeHigh ? "EXTREME HIGH ▼" : math.abs(zScore) > 1.0 ? "STRETCHED ●" : "MEAN RANGE ●"
int   statScore      = statExtremeLow ? 1 : statExtremeHigh ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 6 — MACRO REGIME (DXY + VIX + TNX)
// ═══════════════════════════════════════════════════════════════
float dxyFeed  = nz(dxyClose, nz(dxyClose[1], 100.0))
float vixFeed  = nz(vixClose, nz(vixClose[1], 20.0))
float tnxFeed  = nz(tnxClose, nz(tnxClose[1], 4.0))
float dxyEma   = ta.ema(dxyFeed, i_macroLen)
float vixEma   = ta.ema(vixFeed, i_macroLen)
float vixSma50 = ta.sma(vixFeed, 50)
float tnxEma   = ta.ema(tnxFeed, i_macroLen)
bool  dxyBull  = not na(dxyClose) ? dxyClose > dxyEma  : false
bool  dxyBear  = not na(dxyClose) ? dxyClose < dxyEma  : false
bool  vixHigh  = not na(vixClose) ? vixClose > vixSma50 and vixClose > 20 : false
bool  vixSpike = not na(vixClose) ? vixClose > vixEma * 1.15 : false
bool  tnxRising  = not na(tnxClose) ? tnxClose > tnxEma : false
bool  tnxFalling = not na(tnxClose) ? tnxClose < tnxEma : false

int macroRiskOff = (vixHigh ? 1 : 0) + (not dxyBull ? 1 : 0) + (tnxFalling ? 1 : 0)
int macroRiskOn  = (not vixHigh ? 1 : 0) + (dxyBull ? 1 : 0) + (tnxRising ? 1 : 0)
string macroRegime = macroRiskOff >= 2 ? "RISK-OFF" : macroRiskOn >= 2 ? "RISK-ON" : "MIXED"

int macroScore = 0
if i_class == "Gold / Silver"
    int riskOffCount = (vixHigh or vixSpike ? 1 : 0) + (tnxFalling ? 1 : 0) + (dxyBear ? 1 : 0)
    int riskOnCount  = (not vixHigh and not vixSpike ? 1 : 0) + (tnxRising ? 1 : 0) + (dxyBull ? 1 : 0)
    macroScore := riskOffCount >= 2 ? 1 : riskOnCount >= 2 ? -1 : 0
else if i_class == "Crypto"
    int cryptoBull = (dxyBear ? 1 : 0) + (tnxFalling ? 1 : 0) + (not vixHigh ? 1 : 0)
    int cryptoBear = (dxyBull ? 1 : 0) + (tnxRising ? 1 : 0) + (vixHigh ? 1 : 0)
    macroScore := cryptoBull >= 2 ? 1 : cryptoBear >= 2 ? -1 : 0
else if i_class == "Forex"
    macroScore := macroRiskOn >= 2 ? 1 : macroRiskOff >= 2 ? -1 : 0
else if i_class == "Indices"
    macroScore := macroRiskOn >= 2 ? 1 : macroRiskOff >= 2 ? -1 : 0
else if i_class == "Commodities"
    macroScore := dxyBear and not vixHigh ? 1 : dxyBull ? -1 : 0
else
    macroScore := macroRiskOn >= 2 ? 1 : macroRiskOff >= 2 ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 7 — LIQUIDITY (TNX ROC proxy)
// ═══════════════════════════════════════════════════════════════
float tnxRoc       = ta.roc(tnxFeed, 20)
float tnxRocEma    = ta.ema(tnxRoc, 10)
bool  liqExpanding    = tnxRocEma < -0.1
bool  liqContracting  = tnxRocEma >  0.1
string liqState       = liqExpanding ? "EXPANDING ▲" : liqContracting ? "CONTRACTING ▼" : "NEUTRAL ●"

int liqScore = 0
if i_class == "Forex"
    liqScore := liqContracting ? 1 : liqExpanding ? -1 : 0
else
    liqScore := liqExpanding ? 1 : liqContracting ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ENGINE 8 — INTERMARKET CORRELATION
// ═══════════════════════════════════════════════════════════════
f_corr(series float x, series float y, int len) =>
    float mx  = ta.sma(x, len)
    float my  = ta.sma(y, len)
    float num = ta.sma((x - mx) * (y - my), len)
    float den = ta.stdev(x, len) * ta.stdev(y, len)
    den != 0 ? num / den : 0.0

float corrDXY = i_useDXY ? f_corr(ratio, dxyFeed, i_corrLen) : na
float corrVIX = i_useVIX ? f_corr(ratio, vixFeed, i_corrLen) : na
float corrTNX = i_useTNX ? f_corr(ratio, tnxFeed, i_corrLen) : na
bool  corrDXYShift = not na(corrDXY) ? math.sign(corrDXY) != math.sign(corrDXY[10]) : false
bool  corrVIXShift = not na(corrVIX) ? math.sign(corrVIX) != math.sign(corrVIX[10]) : false

int corrScore = 0
if i_class == "Gold / Silver"
    int corrConf = (not na(corrVIX) and corrVIX > 0.15 ? 1 : 0) + (not na(corrDXY) and corrDXY < -0.15 ? 1 : 0)
    int corrAnti = (not na(corrVIX) and corrVIX < -0.15 ? 1 : 0) + (not na(corrDXY) and corrDXY > 0.15 ? 1 : 0)
    corrScore := corrConf >= 1 ? 1 : corrAnti >= 1 ? -1 : 0
else if i_class == "Crypto"
    corrScore := not na(corrDXY) and corrDXY < -0.3 ? 1 : not na(corrDXY) and corrDXY > 0.3 ? -1 : 0
else if i_class == "Indices"
    corrScore := not na(corrVIX) and corrVIX < -0.3 ? 1 : not na(corrVIX) and corrVIX > 0.3 ? -1 : 0
else
    corrScore := 0

// ═══════════════════════════════════════════════════════════════
// VOLUME / OBV (for extended panel only)
// ═══════════════════════════════════════════════════════════════
float relVolA   = combinedVolSma != 0 ? volA / combinedVolSma : 1.0
float relVolB   = combinedVolSma != 0 ? volB / combinedVolSma : 1.0
float volDiff   = relVolA - relVolB
float obvRatio  = ta.cum(math.sign(ta.change(ratio)) * (volA + volB))
float obvSlope  = ta.linreg(obvRatio, 20, 0) - ta.linreg(obvRatio, 20, 1)
bool  volDiv    = (ratio > ratio[5] and obvSlope < 0) or (ratio < ratio[5] and obvSlope > 0)

// Volume Participation score
bool volBullConf = obvSlope > 0 and ratio > ratioEma21 and volDiff > 0
bool volBearConf = obvSlope < 0 and ratio < ratioEma21 and volDiff < 0
int  volPartScore = volBullConf ? 1 : volBearConf ? -1 : 0

// ═══════════════════════════════════════════════════════════════
// ADAPTIVE SCORING
// ═══════════════════════════════════════════════════════════════
float bRS    = math.max(float(rsScore),    0) * float(wRS)
float bTR    = math.max(float(trendScore), 0) * float(wTR)
float bMOM   = math.max(float(momScore),   0) * float(wMOM)
float bVOL   = math.max(float(volScore),   0) * float(wVOL)
float bSTAT  = math.max(float(statScore),  0) * float(wSTAT)
float bMACRO = math.max(float(macroScore), 0) * float(wMACRO)
float bLIQ   = math.max(float(liqScore),   0) * float(wLIQ)
float bCORR  = math.max(float(corrScore),  0) * float(wCORR)
float bVOLP  = math.max(float(volPartScore), 0) * float(wVOLP)
float rawBull = bRS + bTR + bMOM + bVOL + bSTAT + bMACRO + bLIQ + bCORR + bVOLP

float eRS    = math.abs(math.min(float(rsScore),    0)) * float(wRS)
float eTR    = math.abs(math.min(float(trendScore), 0)) * float(wTR)
float eMOM   = math.abs(math.min(float(momScore),   0)) * float(wMOM)
float eVOL   = math.abs(math.min(float(volScore),   0)) * float(wVOL)
float eSTAT  = math.abs(math.min(float(statScore),  0)) * float(wSTAT)
float eMACRO = math.abs(math.min(float(macroScore), 0)) * float(wMACRO)
float eLIQ   = math.abs(math.min(float(liqScore),   0)) * float(wLIQ)
float eCORR  = math.abs(math.min(float(corrScore),  0)) * float(wCORR)
float eVOLP  = math.abs(math.min(float(volPartScore), 0)) * float(wVOLP)
float rawBear = eRS + eTR + eMOM + eVOL + eSTAT + eMACRO + eLIQ + eCORR + eVOLP

float netRaw   = rawBull - rawBear
float netScore = totalWeight > 0 ? (netRaw / totalWeight) * 10.0 : 0.0
float bullPct  = totalWeight > 0 ? rawBull / totalWeight : 0.0
float bearPct  = totalWeight > 0 ? rawBear / totalWeight : 0.0
float confidence = math.abs(bullPct - bearPct) * 100.0

// ═══════════════════════════════════════════════════════════════
// DIVERGENCE — ratio vs VW RSI
// ═══════════════════════════════════════════════════════════════
int   divPivLen = 5
float pivHRatio = ta.pivothigh(ratio, divPivLen, divPivLen)
float pivLRatio = ta.pivotlow(ratio,  divPivLen, divPivLen)

var float lastPivHR = na, var float lastPivHM = na
var float lastPivLR = na, var float lastPivLM = na

bool bearDiv = false
if not na(pivHRatio)
    if not na(lastPivHR) and ratio[divPivLen] < lastPivHR and vwRsi[divPivLen] > lastPivHM
        bearDiv := true
    lastPivHR := ratio[divPivLen]
    lastPivHM := vwRsi[divPivLen]

bool bullDiv = false
if not na(pivLRatio)
    if not na(lastPivLR) and ratio[divPivLen] > lastPivLR and vwRsi[divPivLen] < lastPivLM
        bullDiv := true
    lastPivLR := ratio[divPivLen]
    lastPivLM := vwRsi[divPivLen]

// ═══════════════════════════════════════════════════════════════
// SIGNALS
// ═══════════════════════════════════════════════════════════════
bool sigBullStrong = netScore >= i_sigStrong
bool sigBearStrong = netScore <= -i_sigStrong
bool sigBullMod    = netScore >= i_sigMod and netScore < i_sigStrong
bool sigBearMod    = netScore <= -i_sigMod and netScore > -i_sigStrong
bool sigBullDiv    = bullDiv and netScore > 0
bool sigBearDiv    = bearDiv and netScore < 0

// ═══════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════
color ratioLineCol = ratio > ratioEma50 ? color.new(i_goldCol, 0) : color.new(i_neutCol, 30)
plot(i_showRatio ? ratio : na, "Ratio A/B", color=ratioLineCol, linewidth=2)

plot(i_showEMA ? ratioEma21  : na, "EMA 21",  color=color.new(i_ema21Col,  40), linewidth=1)
plot(i_showEMA ? ratioEma50  : na, "EMA 50",  color=color.new(i_ema50Col,  40), linewidth=1)
plot(i_showEMA ? ratioEma200 : na, "EMA 200", color=color.new(i_ema200Col, 50), linewidth=1)

float zBandUpper = zMean + zStd * i_zExtreme
float zBandLower = zMean - zStd * i_zExtreme
pStatUpper = plot(i_showBands ? zBandUpper : na, "Stat Upper", color=color.new(i_statUpCol, 60), linewidth=1)
pStatLower = plot(i_showBands ? zBandLower : na, "Stat Lower", color=color.new(i_statDnCol, 60), linewidth=1)
pStatMid   = plot(i_showBands ? zMean      : na, "Stat Mean",  color=color.new(i_statMidCol, 50), linewidth=1)
fill(pStatUpper, pStatMid, color=color.new(i_statUpCol, 93))
fill(pStatLower, pStatMid, color=color.new(i_statDnCol, 93))

pBBUpper = plot(i_showBands ? bbUpper : na, "BB Upper", color=color.new(i_bbCol, 75), linewidth=1)
pBBLower = plot(i_showBands ? bbLower : na, "BB Lower", color=color.new(i_bbCol, 75), linewidth=1)

float atrR = ta.atr(14)
plotshape(sigBullStrong ? ratio - atrR * 0.4 : na, "Bull Strong", shape.triangleup,   location.absolute, i_bullCol, size=size.small)
plotshape(sigBearStrong ? ratio + atrR * 0.4 : na, "Bear Strong", shape.triangledown, location.absolute, i_bearCol, size=size.small)
plotshape(sigBullMod    ? ratio - atrR * 0.3 : na, "Bull Mod",    shape.triangleup,   location.absolute, color.new(i_bullCol, 40), size=size.tiny)
plotshape(sigBearMod    ? ratio + atrR * 0.3 : na, "Bear Mod",    shape.triangledown, location.absolute, color.new(i_bearCol, 40), size=size.tiny)
plotshape(sigBullDiv    ? ratio - atrR * 0.5 : na, "Bull Div",    shape.circle,       location.absolute, color.new(#00e5ff, 0), size=size.tiny)
plotshape(sigBearDiv    ? ratio + atrR * 0.5 : na, "Bear Div",    shape.circle,       location.absolute, color.new(#ff6d00, 0), size=size.tiny)
plotshape(inSqueeze     ? zMean              : na, "Squeeze",     shape.square,       location.absolute, color.new(i_sqzCol, 60), size=size.tiny)

bgcolor(i_showBg and netScore > 3  ? color.new(i_bullCol, i_bgTransp) : na, title="Bull BG")
bgcolor(i_showBg and netScore < -3 ? color.new(i_bearCol, i_bgTransp) : na, title="Bear BG")

// ═══════════════════════════════════════════════════════════════
// DASHBOARD — top-level string resolution
// ═══════════════════════════════════════════════════════════════
string dSize      = i_dashSz == "Tiny" ? size.tiny : i_dashSz == "Small" ? size.small : size.normal
string dashPosStr = i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.bottom_right

f_scoreStr(int sc, int wt) =>
    sc == 1 ? "▲ +" + str.tostring(wt) : sc == -1 ? "▼ -" + str.tostring(wt) : "● 0"

f_scoreCol(int sc, color bull, color bear, color neut) =>
    sc == 1 ? bull : sc == -1 ? bear : neut

string netStr  = netScore > 6 ? "STRONG BULL ▲" : netScore > 3 ? "BULL ▲" : netScore > 0 ? "MILD BULL ▲" : netScore < -6 ? "STRONG BEAR ▼" : netScore < -3 ? "BEAR ▼" : netScore < 0 ? "MILD BEAR ▼" : "NEUTRAL ●"
color  netCol  = netScore > 3 ? i_bullCol : netScore < -3 ? i_bearCol : C_MUTED
color  headCol = netScore > 3 ? color.new(i_bullCol, 65) : netScore < -3 ? color.new(i_bearCol, 65) : color.new(C_PURP, 70)

string confStr  = str.tostring(math.round(confidence, 0)) + "%"
string rsStr    = f_scoreStr(rsScore,    wRS)
string trStr    = f_scoreStr(trendScore, wTR)
string momStr   = f_scoreStr(momScore,   wMOM)
string volStr   = f_scoreStr(volScore,   wVOL)
string statStr  = f_scoreStr(statScore,  wSTAT)
string macStr   = f_scoreStr(macroScore, wMACRO)
string liqStr   = f_scoreStr(liqScore,   wLIQ)
string corrStr  = f_scoreStr(corrScore,  wCORR)
string volpStr  = f_scoreStr(volPartScore, wVOLP)

color rsCol   = f_scoreCol(rsScore,    i_bullCol, i_bearCol, C_MUTED)
color trCol   = f_scoreCol(trendScore, i_bullCol, i_bearCol, C_MUTED)
color momCol  = f_scoreCol(momScore,   i_bullCol, i_bearCol, C_MUTED)
color volCol  = f_scoreCol(volScore,   i_bullCol, i_bearCol, C_MUTED)
color statCol = f_scoreCol(statScore,  i_bullCol, i_bearCol, C_MUTED)
color macCol  = f_scoreCol(macroScore, i_bullCol, i_bearCol, C_MUTED)
color liqCol  = f_scoreCol(liqScore,   i_bullCol, i_bearCol, C_MUTED)
color corrCol = f_scoreCol(corrScore,  i_bullCol, i_bearCol, C_MUTED)
color volpCol = f_scoreCol(volPartScore, i_bullCol, i_bearCol, C_MUTED)

string dxyStr = not na(dxyClose) ? (dxyBull ? "▲ RISING" : "▼ FALLING") : "— N/A"
string vixStr = not na(vixClose) ? (vixHigh ? "▲ ELEVATED" : "▼ LOW")   : "— N/A"
string tnxStr = not na(tnxClose) ? (tnxRising ? "▲ RISING" : "▼ FALLING") : "— N/A"
color  dxyCol = not na(dxyClose) ? (dxyBull ? i_bearCol : i_bullCol) : C_MUTED
color  vixCol = not na(vixClose) ? (vixHigh ? i_bearCol : i_bullCol) : C_MUTED
color  tnxCol = not na(tnxClose) ? (tnxRising ? i_bearCol : i_bullCol) : C_MUTED

string zStr     = str.tostring(math.round(zScore, 2))
string vwRsiStr = str.tostring(math.round(vwRsi, 1))

// ─── Main dashboard ───────────────────────────────────────────
var table dash = table.new(position.bottom_right, 4, 13,
     bgcolor=C_BG, border_color=C_BDR, border_width=1, frame_color=C_BDR, frame_width=1)

// ─── Extended panel ───────────────────────────────────────────
var table extDash = table.new(position.bottom_left, 2, 17,
     bgcolor=C_BG, border_color=C_BDR, border_width=1, frame_color=C_BDR, frame_width=1)

if i_showDash and barstate.islast
    table.set_position(dash, dashPosStr)

    // Row 0 — Header
    table.cell(dash, 0, 0, "ICE",    text_color=C_WHITE, bgcolor=headCol, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, i_class,  text_color=C_MUTED, bgcolor=headCol, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 0, netStr,   text_color=netCol,  bgcolor=headCol, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 0, str.tostring(math.round(netScore, 1)) + " / 10", text_color=netCol, bgcolor=headCol, text_size=dSize, text_halign=text.align_right)

    // Row 1 — Confidence + Regime
    table.cell(dash, 0, 1, "Confidence", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, confStr,      text_color=confidence > 60 ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 1, "Regime",     text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 1, macroRegime,  text_color=macroRegime == "RISK-OFF" ? i_bearCol : macroRegime == "RISK-ON" ? i_bullCol : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 2 — Engines divider
    table.cell(dash, 0, 2, "── Engines ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 2, 2, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 3, 2, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 3 — Rel Str + Trend
    table.cell(dash, 0, 3, "Rel Str",    text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, rsStr,        text_color=rsCol,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 3, "Trend",      text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 3, trStr,        text_color=trCol,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 4 — Momentum + Volatility
    table.cell(dash, 0, 4, "Momentum",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, momStr,       text_color=momCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 4, "Volatility", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 4, volStr,       text_color=volCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 5 — Stat + Macro
    table.cell(dash, 0, 5, "Stat",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, statStr,      text_color=statCol, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 5, "Macro",      text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 5, macStr,       text_color=macCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 6 — Liquidity + Correlation
    table.cell(dash, 0, 6, "Liquidity",  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, liqStr,       text_color=liqCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 6, "Corr",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 6, corrStr,      text_color=corrCol, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)



    // Row 7 — State divider
    table.cell(dash, 0, 7, "── State ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 2, 7, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 3, 7, "", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 8 — Trend State + Vol State
    table.cell(dash, 0, 8, "Trend",      text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, trendState,   text_color=trendBull ? i_bullCol : trendBear ? i_bearCol : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 8, "Vol",        text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 8, volState,     text_color=inSqueeze ? i_sqzCol : sqzRelease ? C_GOLD : volExpanding ? i_bullCol : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 9 — VW RSI + Z-Score
    table.cell(dash, 0, 9, "VW RSI",     text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, vwRsiStr,     text_color=vwRsi > 55 ? i_bullCol : vwRsi < 45 ? i_bearCol : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 9, "Z-Score",    text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 9, zStr,         text_color=math.abs(zScore) > i_zExtreme ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 10 — DXY + VIX
    table.cell(dash, 0, 10, "DXY",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, dxyStr,      text_color=dxyCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 10, "VIX",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 10, vixStr,      text_color=vixCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 11 — 10Y + Divergence
    table.cell(dash, 0, 11, "10Y",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, tnxStr,      text_color=tnxCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 2, 11, "Div",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)
    table.cell(dash, 3, 11, bullDiv ? "▲ BULL" : bearDiv ? "▼ BEAR" : "— None", text_color=bullDiv ? #00e5ff : bearDiv ? #ff6d00 : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 12 — Brand
    table.cell(dash, 0, 12, "Anonycryptous", text_color=color.new(C_PURP, 0), bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, "",              text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 2, 12, "",              text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)
    table.cell(dash, 3, 12, "v1.0",          text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

// ─── Extended macro panel ─────────────────────────────────────
string extPos = dashPosStr == position.bottom_right ? position.bottom_left : dashPosStr == position.bottom_left ? position.bottom_right : dashPosStr == position.top_right ? position.top_left : position.top_right

if i_showDash and i_showExt and barstate.islast
    table.set_position(extDash, extPos)

    // Row 0 — Header
    table.cell(extDash, 0, 0, "ICE · Extended",  text_color=C_WHITE, bgcolor=headCol, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 0, macroRegime,        text_color=macroRegime == "RISK-OFF" ? i_bearCol : macroRegime == "RISK-ON" ? i_bullCol : C_MUTED, bgcolor=headCol, text_size=dSize, text_halign=text.align_right)

    // Row 1 — Divider
    table.cell(extDash, 0, 1, "── Correlation ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 1, "",                  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 2 — Corr DXY
    table.cell(extDash, 0, 2, "Corr vs DXY",  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 2, not na(corrDXY) ? str.tostring(math.round(corrDXY, 2)) : "— N/A", text_color=not na(corrDXY) ? (corrDXY > 0.3 ? i_bullCol : corrDXY < -0.3 ? i_bearCol : C_WHITE) : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 3 — Corr VIX
    table.cell(extDash, 0, 3, "Corr vs VIX",  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 3, not na(corrVIX) ? str.tostring(math.round(corrVIX, 2)) : "— N/A", text_color=not na(corrVIX) ? (corrVIX > 0.3 ? i_bullCol : corrVIX < -0.3 ? i_bearCol : C_WHITE) : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 4 — Corr TNX
    table.cell(extDash, 0, 4, "Corr vs TNX",  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 4, not na(corrTNX) ? str.tostring(math.round(corrTNX, 2)) : "— N/A", text_color=not na(corrTNX) ? (corrTNX > 0.3 ? i_bullCol : corrTNX < -0.3 ? i_bearCol : C_WHITE) : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 5 — Corr Shift
    table.cell(extDash, 0, 5, "Corr Shift",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 5, corrDXYShift or corrVIXShift ? "⚡ SHIFT" : "— Stable", text_color=corrDXYShift or corrVIXShift ? C_GOLD : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 6 — Divider
    table.cell(extDash, 0, 6, "── Statistical ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 6, "",                   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 7 — Z-Score
    table.cell(extDash, 0, 7, "Z-Score",      text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 7, zStr,           text_color=math.abs(zScore) > i_zExtreme ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 8 — Percentile
    table.cell(extDash, 0, 8, "Percentile",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 8, str.tostring(math.round(pctRank * 100, 0)) + "th pct", text_color=pctRank > 0.85 ? i_bearCol : pctRank < 0.15 ? i_bullCol : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 9 — Stat State
    table.cell(extDash, 0, 9, "Stat State",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 9, statState,      text_color=statExtremeLow ? i_bullCol : statExtremeHigh ? i_bearCol : math.abs(zScore) > 1.0 ? C_GOLD : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 10 — MR Probability
    table.cell(extDash, 0, 10, "Reversion %", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 10, str.tostring(math.round(mrProb * 100, 0)) + "%", text_color=mrProb > 0.7 ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 11 — Divider
    table.cell(extDash, 0, 11, "── Volume ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 11, "",              text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 12 — OBV Slope
    table.cell(extDash, 0, 12, "OBV Slope",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 12, obvSlope > 0 ? "▲ RISING" : "▼ FALLING", text_color=obvSlope > 0 ? i_bullCol : i_bearCol, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 12b — Vol Participation score
    table.cell(extDash, 0, 13, "Vol Part",    text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 13, volpStr,       text_color=volpCol, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 14 — Vol Divergence
    table.cell(extDash, 0, 14, "Vol Divergence", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 14, volDiv ? "⚠ DIV" : "— None", text_color=volDiv ? C_GOLD : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 15 — ATR Percentile
    table.cell(extDash, 0, 15, "ATR Pct",     text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 15, str.tostring(math.round(atrPctRank * 100, 0)) + "th", text_color=atrPctRank > 0.7 ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 16 — Liq State
    table.cell(extDash, 0, 16, "Liquidity",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(extDash, 1, 16, liqState,      text_color=liqExpanding ? i_bullCol : liqContracting ? i_bearCol : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(sigBullStrong, "Strong Bull Confluence",  "ICE — Strong Bull Confluence signal fired")
alertcondition(sigBearStrong, "Strong Bear Confluence",  "ICE — Strong Bear Confluence signal fired")
alertcondition(sigBullMod,    "Moderate Bull Signal",    "ICE — Moderate Bull signal")
alertcondition(sigBearMod,    "Moderate Bear Signal",    "ICE — Moderate Bear signal")
alertcondition(sqzRelease,    "Squeeze Breakout",        "ICE — Volatility squeeze released")
alertcondition(sigBullDiv,    "Bull Divergence + Score", "ICE — Bullish divergence with positive score alignment")
alertcondition(sigBearDiv,    "Bear Divergence + Score", "ICE — Bearish divergence with negative score alignment")
alertcondition(statExtremeLow,  "Statistical Extreme Low",  "ICE — Ratio at historical extreme low")
alertcondition(statExtremeHigh, "Statistical Extreme High", "ICE — Ratio at historical extreme high")
alertcondition(corrDXYShift or corrVIXShift, "Correlation Shift", "ICE — Intermarket correlation regime shift detected")
````
