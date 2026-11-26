# Vol-Control Fund Positioning

- url: https://www.tradingview.com/script/5gHQJXjj-Vol-Control-Fund-Positioning/
- type: indicator
- pine_id: PUB;67ca00ab997a4caea983a2b6898bd5ad
- version: 1.0

## Description

[b]The investors who sell because nothing happened[/b]

In 2017 the American stock market was so calm that a whole class of institutional portfolios held more equities than their own capital, simply because the rules they follow told them to. Reconstructed with the model behind this indicator, their estimated equity exposure reached 135 per cent of capital at its peak that year and still stood at 111 per cent on the last session before 5 February 2018. By 14 February it was 47 per cent. None of these portfolios had changed its view of the economy, of earnings or of valuations, and most of them have no view at all. What had changed was a single number, the volatility of the past few weeks, and the rule translated that number into selling. This indicator exists to make such buying and selling, driven by rules rather than by opinions, visible to anyone who looks at a chart, because it moves prices whether or not one knows about it.

[b]A rule instead of an opinion[/b]

A volatility control portfolio sets itself a target, typically a level of annual volatility such as ten per cent, and then sizes its equity position so that the portfolio as a whole moves roughly that much. The arithmetic is disarmingly simple. If the market has recently been moving at an annualised twenty per cent, a ten per cent target means holding half the capital in equities and the rest in cash, and if the market calms down to eight per cent, the same target calls for 125 per cent, which is achieved with futures or borrowed money, usually up to a ceiling of 150 per cent. Exposure is therefore target volatility divided by realised volatility, capped at a maximum leverage, and recalculated every day.

[pine]
exposure = min(max_leverage, target_vol / realised_vol)
[/pine]

Such rules are not a fringe product. S&P Dow Jones Indices publishes a whole family of risk control indices built on exactly this formula, and its own research describes how pension plans with defined benefits and insurers selling variable annuities use them to obtain a smoother path of returns that fits their liabilities better (Cheng et al., 2021). There is academic support for the idea as well. Moreira and Muir (2017) showed that portfolios which take less risk when volatility is high earned higher returns relative to their risk across a range of equity factors, and Harvey et al. (2018), testing more than sixty assets, found that volatility targeting raises the Sharpe ratio for equities and credit and reduces the severity of extreme losses across all asset classes, since the worst days tend to arrive when volatility is already high and the portfolio run to a volatility target is already small.

[b]Why a sensible rule becomes everybody's problem[/b]

What is prudent for a single pension fund acquires a different character once a large amount of money follows the same rule, because the rule is procyclical by construction. It buys when markets have been quiet, which usually means after they have risen, and it sells when volatility jumps, which usually means while they are falling. Volatility, in turn, does not arrive and leave in single days but clusters, a property that Engle (1982) formalised when he showed that the recent past carries information about the variance to come, so that a violent day is rarely followed by calm and the selling continues for as long as the volatility estimate keeps rising. A detail that surprises most people is that the rule does not care about direction. Realised volatility is computed from squared returns, so a three per cent rally raises the estimate just as a three per cent decline does, and a sharp rebound in a nervous market can trigger further selling from these portfolios.

The consequence for everybody else is that part of the supply and demand in equity markets is mechanical and, within limits, predictable. Bank research follows this group of investors closely, Deutsche Bank's weekly [i]Investor Positioning and Flows[/i] report for instance carries its own section on the equity allocation of volatility control funds (Deutsche Bank, 2026, cited in Finvaulta, 2026), yet neither the methods behind such estimates nor the amounts of money involved are public.

[b]Rebuilding the machine from public rules[/b]

Because the rule depends on nothing but prices, the positioning can nonetheless be rebuilt from the chart itself. This script is not affiliated with or endorsed by Deutsche Bank or any other bank, and it does not attempt to reproduce their figures, which are unavailable, but reconstructs the mechanism from rules that are documented in public. The most detailed of these is the S&P methodology, in which realised volatility is the higher of two exponentially weighted estimates of daily log returns, one with a decay factor of 0.94 that reacts quickly and one with 0.97 that reacts more slowly, annualised with 252 trading days, and in which two days pass between the observation of volatility and the rebalancing of the index (S&P Dow Jones Indices, 2014, 2024). The same pair of decay factors appeared as early as 1996 in J.P. Morgan's [i]RiskMetrics[/i], where 0.94 served for trading horizons and 0.97 for investment horizons (J.P. Morgan/Reuters, 1996).

[pine]
variance_t = lambda * variance_t-1 + (1 - lambda) * ln(P_t / P_t-1)^2
realised_vol = sqrt(252 * max(variance_0.94, variance_0.97))
[/pine]

Real portfolios are not all built alike, and so the indicator blends four stylised designs, weighted equally because nobody outside these funds knows how the money is actually distributed across them.

[list=1]
[*]The S&P convention just described, with the two exponentially weighted estimates.
[*]A plain average of squared returns over one month, since S&P permits equally weighted estimates as an alternative to exponential weighting (Cheng et al., 2021), with a window of my choosing, as S&P does not publish one.
[*]The same over three months, again a window of my choosing.
[*]A balanced portfolio of sixty per cent equities and forty per cent US Treasuries, represented by the IEF fund and scaled to the same target on the volatility of the whole portfolio, so that the correlation between stocks and bonds enters the calculation. Its equity exposure is the equity share multiplied by the scaling factor. Risk control products combining an equity and a bond index exist in the S&P family (S&P Dow Jones Indices, 2024), which is why this design is included by default.
[/list]

The weights can be changed under the Custom preset, and a design without data, such as the bond portfolio before IEF started trading in 2002, simply drops out of the average. For readers who want to follow one type of fund rather than the blend, a preset menu replaces the four designs with a single rule.

[list]
[*][b]S&P risk control[/b] uses the decay factors of 0.94 and 0.97 that govern the S&P 500 Daily Risk Control indices.
[*][b]Fast decay[/b] uses the pair of 0.8705 and 0.99725 that S&P applies to one of its global risk control indices (JPMorgan Chase & Co., 2026).
[*][b]Simple weighted[/b] takes the higher of the volatility over one month and over three months.
[*][b]Balanced 60/40[/b] follows only the stock and bond portfolio.
[*][b]Custom[/b] opens every setting of the four designs.
[/list]

On SPY every preset cut its exposure in at least nine of the ten shock episodes, whereas the top zone was followed by a clearly larger reduction for the blend, the simple weighted and the balanced design, less clearly for the pure S&P rule and not at all for the fast decay rule, whose slow second factor keeps exposure from building up in calm markets in the first place. The blend therefore remains the default.

What distinguishes this from an ordinary volatility indicator is that it does not stop at measuring volatility but translates it into the positions a specific group of investors must hold, with their leverage ceiling, their implementation delay and, in the fourth design, the diversification their bonds provide. From that translation follow the outputs a volatility line cannot give, namely the adjustment already fixed for the next session, the size of move that would force these portfolios to sell, and the scale of that selling for moves of a given size.

[b]What appears on the chart[/b]

The main line shows where today's estimated exposure stands relative to the past five years, as a percentile between 0 and 100. A reading of 85 means that exposure was at or below today's level on 85 per cent of the days in that window. Alternatively the line can show the exposure itself in per cent of capital, together with the leverage ceiling. The colour of the line shifts gradually from green at the bottom of the range over blue in the middle to red at the top, or in five steps if the stepped colouring is preferred, the same colour is used for the candles if candle colouring is on, and a shaded area between the line and the midpoint makes the distance from normal visible at a glance. Five zones, from very low below the 10th percentile to very high above the 90th, are marked by bands and faint lines, and by default only the two extremes tint the background. Dots mark the days on which the reading enters one of the extremes. The zones are descriptive labels, not buy or sell instructions, and the thresholds can be moved.

[quote]A reading pinned at 100 for weeks, as in 2017, is no error. When volatility is low enough, every design reaches its leverage ceiling and the estimated exposure stays at the same maximum day after day, and since the percentile counts days at or below today's level, it remains at 100 until the ceiling is left.[/quote]

The dashboard adds what the line cannot show and comes in two versions. The simple one answers the questions most readers have.

[list]
[*]Where positioning stands and how much of their capital these portfolios hold in equities.
[*]How that compares with the past five years, shown as a rank out of 100.
[*]Whether they will buy or sell at the next session.
[*]How large a move would make them sell.
[/list]

The professional version goes further and reports the estimated exposure, its percentile and its change over one and five days. Because of the lag of two days, tomorrow's adjustment is already determined by closes that lie in the past, and the row labelled scheduled next session shows it, positive when the portfolios will add equities and negative when they will reduce them. The four volatility estimates are listed side by side. Two further rows state the size of the next day's move, downwards and upwards, beyond which target exposure starts to fall, and an optional table shows how much target exposure would change after moves of one, two or three per cent in either direction, with the bond leg assumed unchanged. All changes are expressed in percentage points of exposure. A field for assets under management converts them into dollars, but it is set to zero by default, since no reliable public figure for the size of these strategies exists and any number entered there would lend the output a precision it does not have.

Four alerts are available.

[list]
[*][b]Very High[/b] fires when the reading enters the top zone.
[*][b]Very Low[/b] fires when it enters the bottom zone.
[*][b]Mid Range Entry[/b] fires when it returns to the middle.
[*][b]Deleveraging Event[/b] fires when estimated exposure is cut by more than a chosen number of percentage points in a single day, ten by default.
[/list]

A status row at the bottom of the dashboard reports whether the model is still warming up, whether data for the symbol or the bond leg is missing, and whether the chart is intraday or a crypto market, where the convention of 252 trading days per year understates volatility levels although the percentile remains comparable. On continuous futures such as ES1! the price jumps at every contract roll unless the chart is adjusted for contract rolls, and the model would read that jump as a market move, so the index itself or an adjusted chart is the better choice.

[b]What history says about the reading[/b]

The model was tested on daily data for the SPDR S&P 500 ETF from 1993 to September 2026 and the iShares Treasury bond fund IEF from 2002, following a hypothesis written down before the first calculation. Ten shock dates were fixed in advance, from the Lehman collapse in September 2008 to the tariff shock of April 2025, and in nine of them the estimated exposure fell by between 25 and 61 per cent within twenty sessions. After 5 August 2024 it fell from 74 to 55 per cent within ten sessions, and during March 2020 from an already low 35 to 14 per cent. The one miss is instructive. In June 2022 exposure had been falling for months and stood at 38 per cent before the shock, so there was comparatively little left to sell and the cut amounted to 18 per cent. The test confirms direction and timing, whereas the size of these episodes in dollars cannot be checked with public data.

The more useful finding concerns the percentile. When the reading was in its top decile, the following 21 sessions brought an average reduction of 6.0 to 7.6 percentage points of exposure, against an average of practically zero across all days, measured on periods that do not overlap so that the same episode was not counted several times, with p values between 0.002 and 0.006. Across the zones the average change over the following month ran from plus 3.4 points in the lowest zone to minus 6.9 in the highest, although the two lower zones hardly differed from each other, which is the reason they are presented as labels rather than as signals. Part of this pattern is mechanical and should be read as such, because volatility tends to return to its average and exposure is its inverse. A very high reading means calm, and calm has historically been followed by less calm more often than by more.

Two further results shaped the design. Modelling several targets at once, say five, ten, twelve and fifteen per cent, changes the percentile only where the leverage ceiling binds, and the percentile of such a blend correlated at 0.9995 with that of the single ten per cent model, so the indicator uses one target. The balanced stock and bond portfolio, by contrast, behaves differently enough to matter, as its daily changes correlated at only 0.72 with those of the design that holds equities alone, the gap being largest in years like 2013 when bonds diversified and smallest in 2022 when stocks and bonds fell together.

[b]Using it without overestimating it[/b]

The indicator is best read as a description of how fragile or how supported the market is from the side of investors who follow rules, and it is best read once a day after the close. With the default lag the exposure, its percentile and the scheduled change are fixed by earlier closes and do not move during the session, whereas the move thresholds and the scenarios depend on the current daily bar and keep changing until it closes. A very high reading says that a large amount of money is invested because markets have been quiet and will leave if they stop being quiet. This is a reason to be modest with leverage, to consider protection while volatility is still low, and to expect a shock to be amplified rather than absorbed. A very low reading after a sharp decline says that much of the forced selling has already happened and that the same rule will buy back gradually once volatility subsides, a support that depends entirely on that subsidence actually taking place. The scheduled change and the move thresholds help to put a single day into context, for instance to understand why a market that has just fallen one or two per cent may meet additional mechanical supply over the following sessions. Perhaps the most lasting use has little to do with timing at all, namely to size one's own positions by recent volatility instead of by a fixed amount, which is the very idea the academic work cited above supports.

What the indicator does not do should be stated as plainly. It makes no claim about future returns, and no trading rule built on its zones has been tested. The four designs are a stylised sample of a market whose real composition, targets, rebalancing bands and use of implied volatility vary from manager to manager. The same flows are estimated by bank research desks as well, so the indicator offers a picture that professionals already have rather than an advantage over them. Its bond leg consists of US Treasuries on every chart, which suits American indices and fits European or Asian ones poorly, and in those cases a preset without the bond portfolio, such as the S&P risk control preset, is the better choice. Finally, the model works on daily data regardless of the chart's timeframe, and the changes over one and five days are counted in trading days on weekly and intraday charts too.

[b]References[/b]

Cheng, T., Yi, C., Banerjee, A. and Srivastava, V. (2021) [i]Limiting Risk Exposure with S&P Risk Control Indices[/i]. New York: S&P Dow Jones Indices. Available at: https://www.spglobal.com/spdji/en/documents/research/research-limiting-risk-exposure-with-sp-risk-control-indices.pdf (Accessed: 27 September 2026).

Deutsche Bank (2026) [i]Investor Positioning and Flows[/i], 28 August 2026. Frankfurt am Main: Deutsche Bank. Cited in: Finvaulta (2026) [i]Sideways at Modestly Overweight[/i]. Available at: https://finvaulta.com/research/deutsche-bank/sideways-at-modestly-overweight-2026-08-28 (Accessed: 27 September 2026).

Engle, R.F. (1982) 'Autoregressive conditional heteroscedasticity with estimates of the variance of United Kingdom inflation', [i]Econometrica[/i], 50(4), pp. 987-1007.

Harvey, C.R., Hoyle, E., Korgaonkar, R., Rattray, S., Sargaison, M. and Van Hemert, O. (2018) 'The impact of volatility targeting', [i]Journal of Portfolio Management[/i], 45(1), pp. 14-33. doi:10.3905/jpm.2018.45.1.014.

JPMorgan Chase & Co. (2026) [i]Notes Linked to the S&P Risk Control Index Series[/i]. Underlying supplement no. 2-I, dated 17 April 2026, filed under Rule 424(b)(2). Washington, DC: U.S. Securities and Exchange Commission. Available at: https://www.sec.gov/Archives/edgar/data/19617/000121390026045213/ea0285802-17_424b2.pdf (Accessed: 27 September 2026).

J.P. Morgan/Reuters (1996) [i]RiskMetrics Technical Document[/i]. 4th edn. New York: Morgan Guaranty Trust Company. Available at: https://www.msci.com/documents/10199/5915b101-4206-4ba0-aee2-3449d5c7e95a (Accessed: 27 September 2026).

Moreira, A. and Muir, T. (2017) 'Volatility-managed portfolios', [i]Journal of Finance[/i], 72(4), pp. 1611-1644. doi:10.1111/jofi.12513.

S&P Dow Jones Indices (2014) [i]Index Mathematics Methodology[/i]. New York: S&P Dow Jones Indices. Available at: https://www.spice-indices.com/idpfiles/spice-assets/resources/public/documents/methodology-index-math.pdf (Accessed: 27 September 2026).

S&P Dow Jones Indices (2024) [i]S&P Risk Control 2.0 Indices Methodology[/i]. New York: S&P Dow Jones Indices. Available at: https://www.spglobal.com/spdji/pt/documents/methodologies/methodology-sp-risk-control-2-indices.pdf (Accessed: 27 September 2026).

[b]Disclaimer[/b]

[quote]This indicator is provided for educational and analytical purposes. It estimates the positioning of a class of investors from public rules and price data and does not constitute investment advice or a recommendation to buy or sell any security.[/quote]

## Source Code

````pine
//@version=6
// This Pine Script(TM) code is subject to the terms of the Mozilla Public License 2.0
// (c) EdgeTools
// Version 1.0, September 2026

indicator("Vol-Control Fund Positioning", shorttitle="VCPOS", overlay=false, max_lines_count=500, max_labels_count=50, max_bars_back=5000)

// How it works
//
// Volatility-control funds and risk-control indices scale their equity exposure
// by target volatility / realised volatility, capped at a maximum leverage. Their
// positioning is therefore a deterministic function of past returns and can be
// reconstructed from the price of the underlying alone. Banks publish their own
// estimates of this positioning to clients; their specifications and asset
// figures are not public, so this script rebuilds the mechanism from published
// index rules and does not attempt to match anyone's numbers.
//
// Four archetypes are blended with equal weights by default. The true split of
// assets between designs is not observable, so the weights cannot be
// calibrated; they matter little for the percentile and more for daily changes.
// Presets replace the blend with a single documented rule where one exists
// (S&P risk control decay factors 0.94/0.97 and 0.8705/0.99725, per the JPMorgan
// 424B2 prospectus on S&P Risk Control Index notes, SEC, 2026), or with a
// generic design; Custom exposes all archetype settings.
//   A  S&P Risk Control style: realised vol = max of two exponentially weighted
//      volatilities, decay 0.94 (short) and 0.97 (long), variance recursion
//      Var_t = lambda * Var_t-1 + (1 - lambda) * ln(P_t / P_t-1)^2, annualised
//      with 252 days (S&P Dow Jones Indices, Index Mathematics Methodology,
//      risk control section, accessed 27 September 2026).
//   B  One-month equal-weight realised vol (root mean square of log returns).
//   C  Three-month equal-weight realised vol.
//   D  Equity/Treasury portfolio (default 60/40 with IEF) scaled to target vol
//      on the EWMA variance of the portfolio return, so the stock-bond
//      correlation enters; its equity exposure is the equity weight times the
//      scale. Excluded from the blend where bond data are missing.
// Exposure_k = min(max leverage, target vol / realised vol_k), applied with an
// implementation lag (S&P uses two days between observation and rebalancing).
//
// Outputs: blended exposure, its percentile over a rolling window, the change
// already scheduled for the next session (known because of the lag), the size
// of the next-session move beyond which target exposure falls, and the change
// in target exposure for hypothetical moves of 1, 2 and 3 per cent (bond return
// assumed zero in these scenarios). Because realised vol is built from squared
// returns, large up moves also lower exposure.
//
// Validation (EdgeTools/research/43_vol_control_positioning, SPY 1993 to 2026):
// the percentile does not depend on the target vol except through the leverage
// cap, so a single target is used. With the default four-archetype blend,
// exposure fell by 25 to 61 per cent within 20 sessions in 9 of 10
// pre-specified shock episodes. The top decile of the percentile was followed
// by an average 21 session cut of 6.0 to 7.6 pp; the lower zones did not differ
// from each other, so zones are descriptive labels.
//
// References:
//   Harvey, C.R., Hoyle, E., Korgaonkar, R., Rattray, S., Sargaison, M. and
//   Van Hemert, O. (2018) 'The Impact of Volatility Targeting', Journal of
//   Portfolio Management, 45(1).
//   Moreira, A. and Muir, T. (2017) 'Volatility-Managed Portfolios', Journal of
//   Finance, 72(4).
//
// This is a positioning estimate for education and analysis, not a trading
// signal, and no timing rule built on it has been backtested. The assets run by
// vol-control strategies are not observable, so the optional dollar flow is only
// as good as the figure entered for it.

// Model inputs
use_chart_symbol = input.bool(true, "Use Chart Symbol", group="Model",
    tooltip="Off: model runs on the symbol below regardless of the chart.")
custom_symbol = input.symbol("SP:SPX", "Underlying", group="Model",
    tooltip="Used only when the chart symbol is switched off. The model is meant for broad equity indices.")
fund_preset = input.string("Blend of Four Designs", "Fund Type Preset",
    options=["Blend of Four Designs", "S&P Risk Control Index", "Risk Control, Fast Decay", "Risk Control, Simple Weighted", "Balanced 60/40 Vol Control", "Custom"],
    group="Model",
    tooltip="Blend: the four designs below with equal weights, the validated default. S&P Risk Control Index: max of EWMA vols with decay 0.94 and 0.97, the rule of the S&P 500 Daily Risk Control indices, which S&P describes as used by defined benefit plans and variable annuity insurers. Fast Decay: decay 0.8705 and 0.99725, documented for one S&P Global 100 risk control index with a 5% target; on SPY its top zone did not separate. Simple Weighted: max of 21 and 63 day equal-weight vols; S&P allows simple weighting but does not publish the windows, so 21 and 63 are assumptions. Balanced 60/40: equity and Treasury portfolio scaled to target vol, a generic design, not a documented product. Custom: settings in the Archetypes group.")
bond_symbol = input.symbol("NASDAQ:IEF", "Bond Leg (Blend, 60/40, Custom)", group="Model",
    tooltip="Treasury ETF used as the bond leg of design D. Continuous futures contain roll gaps that distort volatility. For non-US indices, prefer a preset without design D.")
target_vol_pct = input.float(10.0, "Target Volatility (%)", minval=2.0, maxval=30.0, step=0.5, group="Model",
    tooltip="Scales the exposure level and scenario sizes. The percentile changes only where the leverage cap binds.")
max_leverage_pct = input.float(150.0, "Maximum Leverage (%)", minval=50.0, maxval=300.0, step=5.0, group="Model",
    tooltip="150% is the maximum leverage used in S&P's own risk control index illustrations.")
impl_lag = input.int(2, "Implementation Lag (days)", minval=0, maxval=5, group="Model",
    tooltip="Days between the volatility observation and the rebalance. S&P risk control indices use two.")
pct_lookback = input.int(1260, "Percentile Lookback (days)", minval=252, maxval=2520, group="Model",
    tooltip="1260 trading days, roughly five years.")
aum_bn = input.float(0.0, "Assumed AUM (USD bn, 0 = off)", minval=0.0, step=10.0, group="Model",
    tooltip="Vol-control AUM is not publicly observable. Leave at zero to show flows as percentage points of exposure only.")
in_weight_a = input.float(1.0, "A: EWMA Weight", minval=0.0, step=0.25, group="Archetypes (Custom preset only)",
    tooltip="Relative weights of the four designs. Zero switches a design off. The settings in this group apply only when the preset is Custom.")
in_lambda_s = input.float(0.94, "A: Short Decay Factor", minval=0.80, maxval=0.995, step=0.005, group="Archetypes (Custom preset only)",
    tooltip="0.94 and 0.97 follow the S&P risk control rules; the higher of the two volatilities is used.")
in_lambda_l = input.float(0.97, "A: Long Decay Factor", minval=0.80, maxval=0.999, step=0.005, group="Archetypes (Custom preset only)")
in_weight_b = input.float(1.0, "B: Short Window Weight", minval=0.0, step=0.25, group="Archetypes (Custom preset only)")
in_window_b = input.int(21, "B: Window (days)", minval=5, maxval=126, group="Archetypes (Custom preset only)")
in_weight_c = input.float(1.0, "C: Long Window Weight", minval=0.0, step=0.25, group="Archetypes (Custom preset only)")
in_window_c = input.int(63, "C: Window (days)", minval=10, maxval=252, group="Archetypes (Custom preset only)")
in_weight_d = input.float(1.0, "D: Multi-Asset Weight", minval=0.0, step=0.25, group="Archetypes (Custom preset only)")
in_equity_share_pct = input.float(60.0, "D: Equity Share (%)", minval=10.0, maxval=100.0, step=5.0, group="Archetypes (Custom preset only)")
// Display
display_mode = input.string("Percentile", "Main Line", options=["Percentile", "Exposure %"], group="Display",
    tooltip="Percentile: rank of today's exposure within the lookback. Exposure %: estimated equity exposure in per cent of capital.")
show_signal_zones = input.bool(true, "Show Zone Thresholds", group="Display")
very_high_threshold = input.float(90.0, "Very High From (percentile)", minval=50.0, maxval=99.0, group="Display",
    tooltip="Descriptive labels. On SPY only the top decile was followed by a measurably larger exposure cut; the lower cut-offs did not separate.")
high_threshold = input.float(70.0, "High From (percentile)", minval=50.0, maxval=99.0, group="Display")
low_threshold = input.float(30.0, "Low Below (percentile)", minval=1.0, maxval=50.0, group="Display")
very_low_threshold = input.float(10.0, "Very Low Below (percentile)", minval=1.0, maxval=50.0, group="Display")
show_area_fill = input.bool(true, "Show Gradient Area", group="Display",
    tooltip="Shades the area between the main line and the midpoint, towards the bearish colour above and the bullish colour below.")
show_markers = input.bool(true, "Show Zone Entry Dots", group="Display",
    tooltip="Dots where the reading enters the very high or very low zone.")
show_last_label = input.bool(true, "Show Last Value Label", group="Display")
background_mode = input.string("Extremes", "Background Mode", options=["Off", "Extremes", "All Zones"], group="Display",
    tooltip="Extremes: only the very high and very low zones are tinted. All Zones: high and low as well, at half the strength.")
background_intensity = input.int(92, "Background Transparency (%)", minval=75, maxval=98, step=1, group="Display")
show_scenarios = input.bool(true, "Show Move Scenarios in Dashboard", group="Display")

show_candle_coloring = input.bool(true, "Color Candles by Indicator", group="Candle Coloring")
candle_base_transparency = input.int(20, "Candle Base Transparency", minval=0, maxval=60, step=5, group="Candle Coloring")

show_dashboard = input.bool(true, "Show Analytics Dashboard", group="Dashboard")
dashboard_position = input.string("Top Right", "Dashboard Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
    group="Dashboard")
dashboard_size = input.string("Normal", "Dashboard Size",
    options=["Tiny", "Small", "Normal", "Large"], group="Dashboard")
dashboard_mode = input.string("Professional", "Dashboard Mode", options=["Professional", "Simple"], group="Dashboard",
    tooltip="Simple: zone, exposure, history rank, tomorrow's scheduled change and the move size that lowers exposure. Professional: all model details and move scenarios.")

show_watermark = input.bool(true, "Show Watermark", group="Watermark")
watermark_position = input.string("Bottom Right", "Watermark Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
    group="Watermark")
watermark_size = input.string("Large", "Watermark Size",
    options=["Small", "Normal", "Large", "Huge"], group="Watermark")

// Appearance
color_scheme = input.string("EdgeTools", "Color Theme",
    options=["Gold", "EdgeTools", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"],
    group="Appearance")
use_dark_mode = input.bool(true, "Optimize for Dark Theme", group="Appearance")
main_line_width = input.int(2, "Main Line Width", minval=1, maxval=5, group="Appearance")
enable_glow = input.bool(true, "Enable Glow Effect", group="Appearance")
color_mode = input.string("Gradient", "Line Coloring", options=["Gradient", "Zones"], group="Appearance",
    tooltip="Gradient blends the theme colours continuously and therefore shows intermediate shades between them. Zones uses the theme colours only, in five steps.")

// Alerts
enable_alerts = input.bool(true, "Enable Alerts", group="Alert System",
    tooltip="Off suppresses all alert conditions of this script, even if an alert has been created.")
delever_alert_pp = input.float(10.0, "Deleveraging Alert (pp per day)", minval=1.0, maxval=50.0, step=0.5, group="Alert System")

// Colour themes
var color primary_color = #2196F3
var color bullish_color = #4CAF50
var color bearish_color = #FF5252
var color neutral_color = #808080
var color text_color = color.white
var color bg_color = #000000
var color table_bg_color = #1E1E1E
var color header_bg_color = #2D2D2D

switch color_scheme
    "Gold" =>
        primary_color := use_dark_mode ? #FFD700 : #DAA520
        bullish_color := use_dark_mode ? #FFA500 : #FF8C00
        bearish_color := use_dark_mode ? #FF5252 : #D32F2F
        neutral_color := use_dark_mode ? #C0C0C0 : #808080
        text_color := use_dark_mode ? color.white : color.black
        bg_color := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #1A1A00 : #FFFEF0
        header_bg_color := use_dark_mode ? #2D2600 : #F5F5DC

    "EdgeTools" =>
        primary_color := use_dark_mode ? #3b82f6 : #2563eb
        bullish_color := use_dark_mode ? #22c55e : #16a34a
        bearish_color := use_dark_mode ? #ef4444 : #dc2626
        neutral_color := use_dark_mode ? #737373 : #525252
        text_color := use_dark_mode ? #fafafa : #0a0a0a
        bg_color := use_dark_mode ? #0a0a0a : #fafafa
        table_bg_color := use_dark_mode ? #171717 : #f9f9f9
        header_bg_color := use_dark_mode ? #262626 : #e5e5e5

    "Behavioral" =>
        primary_color := #808080
        bullish_color := #00FF00
        bearish_color := #8B0000
        neutral_color := #FFBF00
        text_color := use_dark_mode ? color.white : color.black
        bg_color := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #1A1A1A : #F8F8F8
        header_bg_color := use_dark_mode ? #2D2D2D : #E8E8E8

    "Quant" =>
        primary_color := #808080
        bullish_color := #FFA500
        bearish_color := #8B0000
        neutral_color := #4682B4
        text_color := use_dark_mode ? color.white : color.black
        bg_color := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #0D0D0D : #FAFAFA
        header_bg_color := use_dark_mode ? #1A1A1A : #F0F0F0

    "Ocean" =>
        primary_color := use_dark_mode ? #20B2AA : #008B8B
        bullish_color := use_dark_mode ? #00CED1 : #4682B4
        bearish_color := use_dark_mode ? #FF4500 : #B22222
        neutral_color := use_dark_mode ? #87CEEB : #2F4F4F
        text_color := use_dark_mode ? #F0F8FF : #191970
        bg_color := use_dark_mode ? #001F3F : #F0F8FF
        table_bg_color := use_dark_mode ? #001A2E : #E6F7FF
        header_bg_color := use_dark_mode ? #002A47 : #CCF2FF

    "Fire" =>
        primary_color := use_dark_mode ? #FF6347 : #DC143C
        bullish_color := use_dark_mode ? #FFD700 : #FF8C00
        bearish_color := use_dark_mode ? #8B0000 : #800000
        neutral_color := use_dark_mode ? #FFA500 : #CD853F
        text_color := use_dark_mode ? #FFFAF0 : #2F1B14
        bg_color := use_dark_mode ? #2F1B14 : #FFFAF0
        table_bg_color := use_dark_mode ? #261611 : #FFF8F0
        header_bg_color := use_dark_mode ? #3D241A : #FFE4CC

    "Matrix" =>
        primary_color := use_dark_mode ? #00FF41 : #006400
        bullish_color := use_dark_mode ? #39FF14 : #228B22
        bearish_color := use_dark_mode ? #FF073A : #8B0000
        neutral_color := use_dark_mode ? #00FFFF : #008B8B
        text_color := use_dark_mode ? #C0FF8C : #003300
        bg_color := use_dark_mode ? #0D1B0D : #F0FFF0
        table_bg_color := use_dark_mode ? #0A1A0A : #E8FFF0
        header_bg_color := use_dark_mode ? #112B11 : #CCFFCC

    "Arctic" =>
        primary_color := use_dark_mode ? #87CEFA : #4169E1
        bullish_color := use_dark_mode ? #00BFFF : #0000CD
        bearish_color := use_dark_mode ? #FF1493 : #8B008B
        neutral_color := use_dark_mode ? #B0E0E6 : #483D8B
        text_color := use_dark_mode ? #F8F8FF : #191970
        bg_color := use_dark_mode ? #191970 : #F8F8FF
        table_bg_color := use_dark_mode ? #141B47 : #F0F8FF
        header_bg_color := use_dark_mode ? #1E2A5C : #E0F0FF

zone_transparency = use_dark_mode ? 90 : 95
band_transparency = use_dark_mode ? 70 : 85
table_transparency = use_dark_mode ? 80 : 15

// Helpers
f_get_table_position(string pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

f_get_text_size(string sz) =>
    switch sz
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

// Model
annualisation = 252.0
target_vol = target_vol_pct / 100.0
max_leverage = max_leverage_pct / 100.0

is_custom = fund_preset == "Custom"
is_blend = fund_preset == "Blend of Four Designs"
is_balanced = fund_preset == "Balanced 60/40 Vol Control"
is_fast = fund_preset == "Risk Control, Fast Decay"
// Simple-weighted risk control replaces the EWMA pair of design A with the max
// of the two window vols, mirroring the EWMA rule with equal weights.
simple_max = fund_preset == "Risk Control, Simple Weighted"

weight_a = is_custom ? in_weight_a : is_balanced ? 0.0 : 1.0
weight_b = is_custom ? in_weight_b : is_blend ? 1.0 : 0.0
weight_c = is_custom ? in_weight_c : is_blend ? 1.0 : 0.0
weight_d = is_custom ? in_weight_d : is_blend or is_balanced ? 1.0 : 0.0
lambda_s = is_custom ? in_lambda_s : is_fast ? 0.8705 : 0.94
lambda_l = is_custom ? in_lambda_l : is_fast ? 0.99725 : 0.97
window_b = is_custom ? in_window_b : 21
window_c = is_custom ? in_window_c : 63
equity_share_pct = is_custom ? in_equity_share_pct : 60.0

equity_share = equity_share_pct / 100.0
all_weights_zero = weight_a + weight_b + weight_c + weight_d <= 0
eff_weight_a = all_weights_zero ? 1.0 : weight_a

f_leverage(float vol) =>
    na(vol) ? na : vol <= 0 ? max_leverage : math.min(max_leverage, target_vol / vol)

f_leverage_d(float vol) =>
    na(vol) ? na : equity_share * f_leverage(vol)

// Archetypes without data (warm-up, missing bond leg) drop out and the remaining
// weights are renormalised.
f_blend(float ka, float kb, float kc, float kd) =>
    float s = 0.0
    float w = 0.0
    if eff_weight_a > 0 and not na(ka)
        s += eff_weight_a * ka
        w += eff_weight_a
    if weight_b > 0 and not na(kb)
        s += weight_b * kb
        w += weight_b
    if weight_c > 0 and not na(kc)
        s += weight_c * kc
        w += weight_c
    if weight_d > 0 and not na(kd)
        s += weight_d * kd
        w += weight_d
    w > 0 ? s / w : na

// Runs in the daily context of the underlying. Returns the state needed both for
// the history and for the next-session scenarios.
f_model() =>
    float r = math.log(close / close[1])
    float r2 = nz(r * r)
    var float var_s = na
    var float var_l = na
    var int n_ret = 0
    if not na(r)
        n_ret += 1
        var_s := na(var_s) ? r2 : lambda_s * var_s + (1 - lambda_s) * r2
        var_l := na(var_l) ? r2 : lambda_l * var_l + (1 - lambda_l) * r2
    bool warm = n_ret >= math.max(window_c, window_b, 63)
    float vol_b = warm ? math.sqrt(annualisation * math.sum(r2, window_b) / window_b) : na
    float vol_c = warm ? math.sqrt(annualisation * math.sum(r2, window_c) / window_c) : na
    float vol_a = not warm ? na : simple_max ? math.max(vol_b, vol_c) : math.sqrt(annualisation * math.max(var_s, var_l))

    float bond_px = request.security(bond_symbol, "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    float rb = math.log(bond_px / bond_px[1])
    var float var_ps = na
    var float var_pl = na
    var int n_port = 0
    if not na(r) and not na(rb)
        float rp = equity_share * r + (1 - equity_share) * rb
        float rp2 = rp * rp
        n_port += 1
        var_ps := na(var_ps) ? rp2 : lambda_s * var_ps + (1 - lambda_s) * rp2
        var_pl := na(var_pl) ? rp2 : lambda_l * var_pl + (1 - lambda_l) * rp2
    float vol_d = warm and n_port >= 63 ? math.sqrt(annualisation * math.max(var_ps, var_pl)) : na

    float exp_target = f_blend(f_leverage(vol_a), f_leverage(vol_b), f_leverage(vol_c), f_leverage_d(vol_d))
    float exp_live = exp_target[impl_lag]
    float exp_next = impl_lag >= 1 ? exp_target[impl_lag - 1] : exp_target
    var int n_live = 0
    if not na(exp_live)
        n_live += 1
    float pr = ta.percentrank(exp_live, pct_lookback)
    float pctl = n_live > pct_lookback ? pr : na
    float sum_b = math.sum(r2, window_b - 1)
    float sum_c = math.sum(r2, window_c - 1)
    float d_state_s = n_port >= 63 ? var_ps : na
    float d_state_l = n_port >= 63 ? var_pl : na
    // Changes are taken in daily bars here so that they keep their meaning on
    // weekly or intraday charts.
    float chg_1d = exp_live - exp_live[1]
    float chg_5d = exp_live - exp_live[5]
    [exp_live, exp_target, exp_next, pctl, var_s, var_l, sum_b, sum_c, d_state_s, d_state_l, vol_a, vol_b, vol_c, vol_d, chg_1d, chg_5d]

// Data
model_symbol = use_chart_symbol ? syminfo.tickerid : custom_symbol

[exp_live, exp_target, exp_next, pctl, d_var_s, d_var_l, d_sum_b, d_sum_c, d_var_ps, d_var_pl, vol_a, vol_b, vol_c, vol_d, exp_change_1d, exp_change_5d] = request.security(model_symbol, "D", f_model(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Scenarios for the next session
// Target exposure after a hypothetical next-session simple return x of the
// equity, bond return zero, once that return has entered every estimate.
f_target_after(float x) =>
    float rr = math.log(1 + x)
    float r2n = rr * rr
    float vs = lambda_s * d_var_s + (1 - lambda_s) * r2n
    float vl = lambda_l * d_var_l + (1 - lambda_l) * r2n
    float vb = math.sqrt(annualisation * (d_sum_b + r2n) / window_b)
    float vc = math.sqrt(annualisation * (d_sum_c + r2n) / window_c)
    float va = simple_max ? math.max(vb, vc) : math.sqrt(annualisation * math.max(vs, vl))
    float rp2n = math.pow(equity_share * rr, 2)
    float vps = lambda_s * d_var_ps + (1 - lambda_s) * rp2n
    float vpl = lambda_l * d_var_pl + (1 - lambda_l) * rp2n
    float vd = na(vps) or na(vpl) ? na : math.sqrt(annualisation * math.max(vps, vpl))
    f_blend(f_leverage(va), f_leverage(vb), f_leverage(vc), f_leverage_d(vd))

f_delta_after(float x) =>
    f_target_after(x) - exp_target

// Smallest absolute move in the given direction that lowers target exposure.
f_sell_trigger(float direction) =>
    float eps = 1e-6
    float result = na
    if not na(exp_target)
        if f_delta_after(direction * 0.10) < -eps
            float lo = 0.0
            float hi = 0.10
            if f_delta_after(0.0) < -eps
                hi := 0.0
            else
                for i = 0 to 39
                    float mid = (lo + hi) / 2
                    if f_delta_after(direction * mid) < -eps
                        hi := mid
                    else
                        lo := mid
            result := hi
    result

// Zones
hi_cut = math.max(very_high_threshold, high_threshold)
mid_hi_cut = math.min(very_high_threshold, high_threshold)
lo_cut = math.min(very_low_threshold, low_threshold)
mid_lo_cut = math.max(very_low_threshold, low_threshold)

is_valid = not na(pctl)
is_very_high = is_valid and pctl >= hi_cut
is_high = is_valid and pctl >= mid_hi_cut and pctl < hi_cut
is_very_low = is_valid and pctl < lo_cut
is_low = is_valid and pctl < mid_lo_cut and pctl >= lo_cut
is_neutral = is_valid and pctl >= mid_lo_cut and pctl < mid_hi_cut

zone_str = not is_valid ? "Warming up" : is_very_high ? "Very high" : is_high ? "High" :
     is_very_low ? "Very low" : is_low ? "Low" : "Mid range"
implication_str = is_valid ? "exposure vs " + str.tostring(math.round(pct_lookback / 252)) + "y history" : "n/a"

scheduled_change = exp_next - exp_live
// On intraday charts the daily change is repeated on every bar of the session,
// so the event is only counted on the first bar of a new day.
new_day = ta.change(time("D")) != 0
delever_event = not na(exp_change_1d) and exp_change_1d * 100 <= -delever_alert_pp and barstate.isconfirmed and
     (not timeframe.isintraday or new_day)

// Zone colours and background
get_zone_color() =>
    if is_very_high
        bearish_color
    else if is_high
        color.new(bearish_color, 40)
    else if is_very_low
        bullish_color
    else if is_low
        color.new(bullish_color, 40)
    else
        primary_color

zone_color = get_zone_color()

// Continuous line colour: bullish at 0, primary at 50, bearish at 100.
f_gradient(float p) =>
    na(p) ? neutral_color : p < 50 ? color.from_gradient(p, 0, 50, bullish_color, primary_color) :
         color.from_gradient(p, 50, 100, primary_color, bearish_color)

use_gradient = color_mode == "Gradient"
zone_base = is_very_high or is_high ? bearish_color : is_very_low or is_low ? bullish_color : primary_color
line_color = use_gradient ? f_gradient(pctl) : is_valid ? zone_color : neutral_color

color final_bg_color = na
if is_valid and background_mode != "Off"
    float soft = background_intensity + (100 - background_intensity) * 0.5
    if is_very_high
        final_bg_color := color.new(bearish_color, background_intensity)
    else if is_very_low
        final_bg_color := color.new(bullish_color, background_intensity)
    else if background_mode == "All Zones" and is_high
        final_bg_color := color.new(bearish_color, soft)
    else if background_mode == "All Zones" and is_low
        final_bg_color := color.new(bullish_color, soft)

bgcolor(final_bg_color, title="Zone Background")

// Candle colouring
zone_candle_transparency = candle_base_transparency + (is_high or is_low ? 25 : is_neutral ? 35 : 0)
candle_color = not show_candle_coloring or not is_valid ? na :
     use_gradient ? color.new(line_color, candle_base_transparency) : color.new(zone_base, zone_candle_transparency)
barcolor(candle_color, title="Candle Coloring")

// Plots
is_pct_mode = display_mode == "Percentile"
main_value = is_pct_mode ? pctl : exp_live * 100

mid_level = is_pct_mode ? 50.0 : 100.0
top_level = is_pct_mode ? 100.0 : max_leverage_pct
show_pct_levels = is_pct_mode and show_signal_zones

// Only the extremes get a band; the inner thresholds stay as faint lines.
p_band_top = plot(show_pct_levels ? 100.0 : na, "Band Top", display=display.none, editable=false)
p_hi = plot(show_pct_levels ? hi_cut : na, "Very High Threshold", color=color.new(bearish_color, band_transparency), linewidth=1)
plot(show_pct_levels ? mid_hi_cut : na, "High Threshold", color=color.new(bearish_color, 80), linewidth=1)
plot(show_pct_levels ? mid_lo_cut : na, "Low Threshold", color=color.new(bullish_color, 80), linewidth=1)
p_lo = plot(show_pct_levels ? lo_cut : na, "Very Low Threshold", color=color.new(bullish_color, band_transparency), linewidth=1)
p_band_bottom = plot(show_pct_levels ? 0.0 : na, "Band Bottom", display=display.none, editable=false)
fill(p_band_top, p_hi, color=color.new(bearish_color, zone_transparency), title="Very High Band")
fill(p_lo, p_band_bottom, color=color.new(bullish_color, zone_transparency), title="Very Low Band")
plot(not is_pct_mode ? max_leverage_pct : na, "Leverage Cap", color=color.new(bearish_color, 50), style=plot.style_circles, linewidth=1)

// Gradient area between the line and the midpoint, split so that each side
// fades towards its own colour.
area_on = show_area_fill and not na(main_value)
p_mid = plot(mid_level, "Midpoint", color=color.new(neutral_color, 65), linewidth=1)
p_area_up = plot(area_on ? math.max(main_value, mid_level) : na, "Area Upper", display=display.none, editable=false)
p_area_dn = plot(area_on ? math.min(main_value, mid_level) : na, "Area Lower", display=display.none, editable=false)
fill(p_area_up, p_mid, top_level, mid_level, color.new(bearish_color, 60), color.new(bearish_color, 100), title="Area Above Midpoint")
fill(p_mid, p_area_dn, mid_level, 0.0, color.new(bullish_color, 100), color.new(bullish_color, 60), title="Area Below Midpoint")

plot(enable_glow ? main_value : na, "Glow Outer", color=color.new(line_color, 90), linewidth=main_line_width + 6)
plot(enable_glow ? main_value : na, "Glow Inner", color=color.new(line_color, 78), linewidth=main_line_width + 3)
plot(main_value, "Main Line", color=line_color, linewidth=main_line_width)

very_high_entry = is_very_high and not is_very_high[1] and is_valid[1]
very_low_entry = is_very_low and not is_very_low[1] and is_valid[1]
neutral_entry = is_neutral and not is_neutral[1] and is_valid[1]

plot(show_markers and (very_high_entry or very_low_entry) ? main_value : na, "Zone Entry",
     color=line_color, style=plot.style_circles, linewidth=main_line_width + 4)

var label last_label = na
if barstate.islast
    label.delete(last_label)
    if show_last_label and not na(main_value)
        string last_txt = is_pct_mode ? str.tostring(main_value, "0") : str.tostring(main_value, "0.0") + "%"
        last_label := label.new(bar_index, main_value, last_txt, style=label.style_label_left,
             color=line_color, textcolor=color.white, size=size.small)

plot(exp_live * 100, "Exposure %", display=display.data_window)
plot(pctl, "Exposure Percentile", display=display.data_window)
plot(exp_change_1d * 100, "Exposure Change 1d (pp)", display=display.data_window)
plot(math.max(vol_a, vol_b, vol_c) * 100, "Highest Realised Vol %", display=display.data_window)
plot(vol_d * 100, "Portfolio Vol D %", display=display.data_window)

// Watermark
watermark_table_pos = f_get_table_position(watermark_position)
watermark_text_sz = f_get_text_size(watermark_size)
watermark_text_sz_small = watermark_size == "Huge" ? size.large : watermark_size == "Large" ? size.normal : size.small
watermark_text_sz_tiny = watermark_size == "Huge" ? size.normal : watermark_size == "Large" ? size.small : size.tiny

var table infoTable = table.new(watermark_table_pos, 2, 4, border_width=0, bgcolor=color.new(color.black, 100))

if show_watermark and barstate.islast
    table.clear(infoTable, 0, 0)
    color watermarkTextColor = use_dark_mode ? color.new(color.white, 30) : color.new(color.black, 40)

    table.cell(infoTable, 0, 0, syminfo.ticker + ", " + timeframe.period, bgcolor=color.new(color.black, 100),
         text_color=watermarkTextColor, text_size=watermark_text_sz, text_halign=text.align_right)
    table.cell(infoTable, 1, 0, "", bgcolor=color.new(color.black, 100), text_color=watermarkTextColor, text_size=watermark_text_sz)

    string indexLine = "Vol-Control Exposure: " + (na(exp_live) ? "n/a" : str.tostring(exp_live * 100, "0.0") + "%")
    table.cell(infoTable, 0, 1, indexLine, bgcolor=color.new(color.black, 100),
         text_color=watermarkTextColor, text_size=watermark_text_sz_small, text_halign=text.align_right)
    table.cell(infoTable, 1, 1, "", bgcolor=color.new(color.black, 100), text_color=watermarkTextColor, text_size=watermark_text_sz_small)

    string zoneLine = zone_str + (is_valid ? " | rank " + str.tostring(pctl, "0") + " of 100" : "")
    table.cell(infoTable, 0, 2, zoneLine, bgcolor=color.new(color.black, 100),
         text_color=watermarkTextColor, text_size=watermark_text_sz_tiny, text_halign=text.align_right)
    table.cell(infoTable, 1, 2, "", bgcolor=color.new(color.black, 100), text_color=watermarkTextColor, text_size=watermark_text_sz_tiny)

    table.cell(infoTable, 0, 3, implication_str, bgcolor=color.new(color.black, 100),
         text_color=color.new(zone_color, 20), text_size=watermark_text_sz_small, text_halign=text.align_right)
    table.cell(infoTable, 1, 3, "", bgcolor=color.new(color.black, 100), text_color=watermarkTextColor, text_size=watermark_text_sz_small)

// Dashboard
f_pp(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x * 100, "0.0") + " pp"

f_flow(float x) =>
    aum_bn > 0 and not na(x) ? f_pp(x) + " | " + (x >= 0 ? "+" : "") + str.tostring(x * aum_bn, "0.0") + " bn" : f_pp(x)

f_trigger_text(float x, string sign, string fmt) =>
    na(x) ? "none within 10%" : x <= 0 ? "any move" : sign + str.tostring(x * 100, fmt) + "%"

// Ten-step bar for a 0 to 100 reading.
f_bar(float p) =>
    int filled = na(p) ? 0 : int(math.round(p / 10))
    str.repeat("▰", filled) + str.repeat("▱", 10 - filled)

f_delta_color(float x) =>
    na(x) ? neutral_color : x < -0.0005 ? bearish_color : x > 0.0005 ? bullish_color : neutral_color

dashboard_table_pos = f_get_table_position(dashboard_position)
dashboard_text_sz = f_get_text_size(dashboard_size)
dashboard_text_sz_small = dashboard_size == "Large" ? size.normal : dashboard_size == "Normal" ? size.small : size.tiny

// Data checks shown in the status row. Crypto trades every day, so the 252-day
// annualisation understates its volatility; the percentile is unaffected.
no_data = na(exp_target) and bar_index > 400
bond_missing = weight_d > 0 and not na(vol_a) and na(vol_d)
crypto_underlying = use_chart_symbol and syminfo.type == "crypto"
// Continuous futures jump at each roll unless back-adjusted, and the jump is read
// as a return, which inflates realised vol around roll dates.
futures_underlying = use_chart_symbol and syminfo.type == "futures"
status_text = no_data ? "No daily data for this symbol" : not is_valid ? "Warming up" :
     bond_missing ? "Bond leg missing, D excluded" : crypto_underlying ? "Crypto: levels scaled for 252 days" :
     futures_underlying ? "Futures: use back-adjusted or SP:SPX" :
     timeframe.isintraday ? "Daily model on intraday chart" : "Active"
status_color = no_data ? bearish_color : not is_valid ? primary_color :
     bond_missing or crypto_underlying or futures_underlying or timeframe.isintraday ? neutral_color : bullish_color

preset_short = switch fund_preset
    "Blend of Four Designs" => "Blend"
    "S&P Risk Control Index" => "S&P risk control"
    "Risk Control, Fast Decay" => "Fast decay"
    "Risk Control, Simple Weighted" => "Simple weighted"
    "Balanced 60/40 Vol Control" => "60/40"
    => "Custom"

var table dashboard = table.new(dashboard_table_pos, 2, 18, border_width=1,
     bgcolor=color.new(table_bg_color, table_transparency))

f_row_bg(int row) =>
    color.new(table_bg_color, row % 2 == 0 ? 45 : 25)

f_label(int row, string txt) =>
    table.cell(dashboard, 0, row, txt, text_color=color.new(text_color, 25), bgcolor=f_row_bg(row),
         text_size=dashboard_text_sz_small, text_halign=text.align_left)

f_value(int row, string txt, color col) =>
    table.cell(dashboard, 1, row, txt, text_color=col, bgcolor=f_row_bg(row),
         text_size=dashboard_text_sz_small, text_halign=text.align_right)

f_header(int row, string left, string right) =>
    color hc = color.new(header_bg_color, 10)
    table.cell(dashboard, 0, row, left, text_color=text_color, bgcolor=hc, text_size=dashboard_text_sz, text_halign=text.align_left)
    table.cell(dashboard, 1, row, right, text_color=color.new(text_color, 30), bgcolor=hc, text_size=dashboard_text_sz_small, text_halign=text.align_right)

f_zone_row(int row) =>
    color zb = color.new(zone_color, 82)
    table.cell(dashboard, 0, row, "Positioning", text_color=text_color, bgcolor=zb, text_size=dashboard_text_sz, text_halign=text.align_left)
    table.cell(dashboard, 1, row, zone_str, text_color=zone_color, bgcolor=zb, text_size=dashboard_text_sz, text_halign=text.align_right)

f_status_row(int row) =>
    color sb = color.new(status_color, 88)
    table.cell(dashboard, 0, row, "Model Status", text_color=color.new(text_color, 25), bgcolor=sb, text_size=dashboard_text_sz_small, text_halign=text.align_left)
    table.cell(dashboard, 1, row, status_text, text_color=status_color, bgcolor=sb, text_size=dashboard_text_sz_small, text_halign=text.align_right)

rank_text = is_valid ? f_bar(pctl) + "  " + str.tostring(pctl, "0") : "n/a"

if show_dashboard and barstate.islast and dashboard_mode == "Simple"
    table.clear(dashboard, 0, 0, 1, 17)
    f_header(0, "VCPOS", preset_short)
    f_zone_row(1)
    f_label(2, "Invested in Equities")
    f_value(2, na(exp_live) ? "n/a" : str.tostring(exp_live * 100, "0") + "% of capital", text_color)
    f_label(3, "Rank vs " + str.tostring(math.round(pct_lookback / 252)) + "y History")
    f_value(3, rank_text, line_color)
    string tomorrow_text = impl_lag < 1 or na(scheduled_change) ? "n/a" :
         scheduled_change > 0.0005 ? "Buying " + f_pp(scheduled_change) :
         scheduled_change < -0.0005 ? "Selling " + f_pp(scheduled_change) : "No change"
    f_label(4, "Next Session")
    f_value(4, tomorrow_text, f_delta_color(scheduled_change))
    float s_trig_dn = f_sell_trigger(-1.0)
    float s_trig_up = f_sell_trigger(1.0)
    f_label(5, "Moves That Trigger Selling")
    f_value(5, f_trigger_text(s_trig_dn, "-", "0.0") + " / " + f_trigger_text(s_trig_up, "+", "0.0"), bearish_color)
    f_status_row(6)

if show_dashboard and barstate.islast and dashboard_mode == "Professional"
    table.clear(dashboard, 0, 0, 1, 17)
    f_header(0, "VCPOS", preset_short + " | " + str.tostring(target_vol_pct, "#.#") + "% | lag " + str.tostring(impl_lag))
    f_zone_row(1)
    f_label(2, "Equity Exposure")
    f_value(2, na(exp_live) ? "n/a" : str.tostring(exp_live * 100, "0.0") + "%", text_color)
    f_label(3, "Percentile (" + str.tostring(pct_lookback) + "d)")
    f_value(3, rank_text, line_color)
    f_label(4, "Change 1d / 5d")
    f_value(4, f_pp(exp_change_1d) + " / " + f_pp(exp_change_5d), f_delta_color(exp_change_1d))
    f_label(5, "Scheduled Next Session")
    f_value(5, impl_lag >= 1 ? f_flow(scheduled_change) : "no lag set", f_delta_color(scheduled_change))
    string vol_text = na(vol_a) ? "n/a" : str.tostring(vol_a * 100, "0.0") + " / " + str.tostring(vol_b * 100, "0.0") + " / " +
         str.tostring(vol_c * 100, "0.0") + " / " + (na(vol_d) ? "n/a" : str.tostring(vol_d * 100, "0.0"))
    f_label(6, "Realised Vol A / B / C / D")
    f_value(6, vol_text, text_color)
    f_label(7, "Target Falls on Move Below")
    f_value(7, f_trigger_text(f_sell_trigger(-1.0), "-", "0.00"), bearish_color)
    f_label(8, "Target Falls on Move Above")
    f_value(8, f_trigger_text(f_sell_trigger(1.0), "+", "0.00"), bearish_color)

    int last_row = 8
    if show_scenarios
        // Scenario rows change the target, which is traded impl_lag sessions later,
        // so they must not be read as additions to the scheduled row above.
        f_header(9, "Next Session Move", "Target Change, Traded in " + str.tostring(impl_lag) + "d")
        array<float> moves = array.from(-0.03, -0.02, -0.01, 0.0, 0.01, 0.02, 0.03)
        for i = 0 to array.size(moves) - 1
            float mv = array.get(moves, i)
            float d = na(exp_target) ? na : f_delta_after(mv)
            int row = 10 + i
            f_label(row, mv == 0 ? "Flat" : (mv > 0 ? "+" : "") + str.tostring(mv * 100, "0") + "%")
            color dc = f_delta_color(d)
            table.cell(dashboard, 1, row, f_flow(d), text_color=dc, bgcolor=color.new(dc, 86),
                 text_size=dashboard_text_sz_small, text_halign=text.align_right)
        last_row := 16

    f_status_row(last_row + 1)

// Alert conditions
alertcondition(very_high_entry and enable_alerts, title="Very High",
     message="VCPOS {{ticker}}: estimated vol-control exposure entered the very high zone")
alertcondition(very_low_entry and enable_alerts, title="Very Low",
     message="VCPOS {{ticker}}: estimated vol-control exposure entered the very low zone")
alertcondition(neutral_entry and enable_alerts, title="Mid Range Entry",
     message="VCPOS {{ticker}}: estimated vol-control exposure back in the mid range")
alertcondition(delever_event and enable_alerts, title="Deleveraging Event",
     message="VCPOS {{ticker}}: one-day cut in estimated vol-control exposure exceeded the alert threshold")
````
