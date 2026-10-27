# Compass | Anonycryptous

- url: https://www.tradingview.com/script/v8bX6109-Compass-Anonycryptous/
- type: indicator
- pine_id: PUB;57209f29226d49b59d02ff16e533deef
- version: 1.0

## Description

Compass | Anonycryptous
Description & user manual

Credits
The weekly psychological level calculation in this indicator is based on open-source code originally published on TradingView. The original script was created by plasmapug. Continued development was done by infernixx, Peshocore, and xtech5192 in collaboration with TradersReality. Significant modifications have been made to integrate this component into the Compass framework.

Why this indicator is different
Most indicators answer one question. A moving average tells you the trend direction. An oscillator tells you momentum. A session box tells you the time. A volume indicator tells you participation. Each one is useful. None of them tells you where you are.
Before placing a trade, a trader needs to answer several questions simultaneously. What session is active and what does that mean for the type of price action to expect? Where does the macro trend stand? Is volume confirming the move or contradicting it? Are there open imbalances nearby that price may return to? How much of the day's expected range has already been consumed? Where are the key structural levels — pivots, the daily open, prior week references?
Answering each of these questions separately requires stacking tool after tool until the chart becomes unreadable. Compass answers all of them at once.
It is not a signal indicator. It does not fire arrows or tell you when to buy or sell. What it does is something more fundamental: it gives you a complete read of the market environment before any decision is made. Sessions, trend, volume, imbalances, range levels, pivots, psychological references — all in one overlay, all configurable, all on one chart.
The design philosophy is orientation first. Decision second. Compass tells you where you are. What you do with that is your responsibility.

Important notice
Compass does not generate trading signals.
It does not tell you when to buy or sell.
It does not predict market direction.
It does not replace your trading strategy or your own analysis.
All illustrative examples in this manual are for educational purposes only and are not trading recommendations.
All trading decisions remain entirely with the user.
Always apply your own judgment and manage your own risk.

1. Overview
Compass is a comprehensive market context indicator that combines eleven independent analysis frameworks into one unified overlay. Every component is individually toggleable. Six presets are included for different trading styles, from fast scalping to full multi-component analysis.

What it includes:
- Five-EMA suite with adaptive cloud around the EMA 50
- EMA crossover system with configurable signals and candle coloring
- Stochastic RSI background alerts with four alert types and RSI divergence detection
- PVSRA volume vector candle analysis with zone tracking and configurable thresholds
- Eight global market sessions with automatic DST awareness
- Average daily, weekly, and monthly range levels with 50% midpoints
- Classic pivot points with mid-point levels
- Daily open reference line with historical opens
- Fair value gap detection with partial absorption tracking
- Weekly psychological level tracking
- Live dashboard with eighteen data points across all active components

2. EMA suite
Five exponential moving averages are plotted simultaneously: EMA 5, EMA 13, EMA 50, EMA 200, and EMA 800. Together they cover short-term momentum, medium-term trend direction, macro trend, and long-term structural bias.
The EMA 50 is wrapped in a dynamic cloud calculated from two standard deviations of price. The cloud expands during volatility and contracts during consolidation. A widening cloud indicates active price discovery. A thinning cloud indicates equilibrium or compression before a directional move.
The EMA 200 is the primary macro bias filter. Price above it defines a broadly bullish environment. Price below it defines a broadly bearish environment. This is shown in the dashboard at all times.
The EMA 800 provides long-term structural context, particularly useful on mid to higher timeframes where it marks the gravitational center of multi-month price structure.
All five EMA lengths are configurable. Each has individual color and transparency controls. An EMA label option displays the current value at the right edge of each line.

3. EMA cross system
The EMA cross tracks a configurable fast EMA crossing a configurable slow EMA and marks the crossover bar. All candles after a cross continue in the direction of that cross until the opposite cross fires.
Three display modes are available: show both the fast and slow EMA lines, show a single consolidated EMA line, or hide the EMA lines entirely while keeping the crossover signals visible.
This component is a trend state indicator, not a trade trigger. A bull cross does not mean buy. It means the short-term trend has shifted upward relative to the medium-term average.
Signals and candle coloring can be toggled independently.

4. Stochastic RSI
The stochastic RSI component runs a standard stochastic RSI calculation and generates background color alerts based on crossover conditions at configurable band levels.
Four alert types are available, each independently toggleable:
Middle band crossover — K line crosses D line near the 50 level. Indicates a possible trend shift in momentum.
Overbought/oversold crossover — K line crosses D line from overbought or oversold territory. Indicates a potential reversal from an extreme.
Entering overbought — K line crosses above the upper band. Indicates that momentum has moved into overbought territory.
Entering oversold — K line crosses below the lower band. Indicates that momentum has moved into oversold territory.
The dashboard displays the current stochastic RSI state and the RSI value. RSI appears in green when above the midline and in red when below. Regular bullish and bearish divergence is detected automatically and shown in the dashboard as a directional label. When divergence is active, a thin reference line appears on the price chart marking the divergence candles.

5. PVSRA volume vector analysis
PVSRA analysis colors candles based on volume relative to the 10-bar average and the relationship between volume and candle spread.
Four vector types:

Green vector — bullish bar where volume is at or above the green/red threshold (default 200% of the 10-bar average), or where volume multiplied by spread is the highest of the last 10 bars. Indicates strong bullish institutional participation.
Red vector — same conditions on a bearish bar. Indicates strong bearish institutional participation.
Blue vector — bullish bar where volume is at or above the blue/violet threshold (default 150% of average). Indicates elevated bullish volume below the institutional threshold.
Violet vector — same conditions on a bearish bar. Indicates elevated bearish volume.
Grey — no vector conditions met. Normal volume.
Both thresholds are configurable directly from the settings panel. Blue and violet signals are strictly exclusive from green and red — a bar cannot qualify for both simultaneously.
Vector candle zones draw boxes at each vector candle location and remain active until price moves through the zone, marking areas where elevated institutional activity was detected at the time the candle formed.
The PVSRA override input allows a different symbol to be used for the volume calculation. This is useful when the charted instrument has unreliable volume data, such as CFDs, perpetual swaps, or instruments where the primary volume is on a related market.

6. Market sessions
Eight global trading sessions are tracked simultaneously, each with automatic DST awareness. Sessions are displayed as expanding boxes with high and low lines and a real-time label showing the session open.
Sessions included:
- London: 08:00–16:30 UTC
- New York: 14:30–21:00 UTC
- Tokyo: 00:00–06:00 UTC
- Hong Kong: 01:30–08:00 UTC
- Sydney: 22:00–06:00 UTC
- EU brinks: 08:00–09:00 UTC
- US brinks: 14:00–15:00 UTC
- Frankfurt: 07:00–16:30 UTC

DST is handled automatically for London, New York, and Sydney. No manual adjustment is needed. Each session can be toggled individually, and box color, transparency, and label color are fully configurable per session.
Session context matters because market behavior differs significantly depending on which participants are active. London and New York overlap produces the highest volume and fastest price movement. Tokyo and Sydney sessions tend to consolidate. The brinks windows mark the transition periods where session highs and lows often form.

7. Range levels
Three statistical range frameworks measure the expected price range for the current period based on historical averages.
Average daily range (ADR) — the expected high and low for the current trading day. When price reaches the ADR level, the day's expected range has been consumed. Moves beyond the ADR are extension moves that occur with lower statistical probability and often mean-revert. The dashboard shows ADR % used — how much of today's expected range has already been consumed. Above 80% indicates the day is approaching its expected limit.
Average weekly range (AWR) — the same concept applied to the current week. Useful for assessing how much room the week has left to move.
Average monthly range (AMR) — the same concept applied to the current month. Provides macro context for position sizing and target expectations.
Each framework includes a 50% midpoint level marking the center of the expected range. The ADR measure from daily open option calculates the range starting from that day's open price rather than the statistical high, making the levels static for the entire day.
All three frameworks have individual lookback period inputs, color controls, line styles, and label toggles.

8. Pivot points
Classic pivot points are calculated from the prior day's high, low, and close. Levels include PP, R1/S1, R2/S2, R3/S3, and M mid-point levels between each major level.
Pivot points provide structural reference for the current session. Price above PP defines a broadly bullish day structure. R levels act as potential resistance targets. S levels act as potential support targets. M levels provide intermediate precision references between major pivots.
All levels can be toggled individually. Lines extend rightward from the prior session and can optionally extend in both directions. Each level has individual color and line style controls.

9. Daily open
A horizontal line marks the current day's opening price. This is one of the most referenced structural levels among short-term traders because it defines the starting point for the day's price discovery.
Price above the daily open reflects a bullish session bias. Price below reflects a bearish session bias. When price oscillates around the daily open without committing direction, the session is in balance — a lower probability environment for trend trades.
Historical daily opens can optionally be shown as reference for prior day context.

10. Fair value gaps
A fair value gap is a three-bar imbalance where price moved through a range without leaving two-sided trade — the low of the upper candle is above the high of the lower candle (bullish gap) or vice versa (bearish gap). These areas represent unfinished business where the market may return to achieve balance.
Gaps are filtered by a minimum width threshold expressed as a multiple of ATR. Gaps narrower than the threshold are excluded. Partial absorption is tracked — as price returns into the gap, the fill color changes to show how much of the imbalance has been recovered.
Fully mitigated gaps can be kept on the chart as historical reference or deleted automatically to maintain a clean view.

11. Psychological levels
Weekly psychological levels mark the prior week's high and low as calculated by a specific session-anchored method. These levels represent deliberate structural references where participants have previously committed size — breakouts and rejections around these levels tend to be more intentional than random price noise.
Three GMT offset options accommodate the session anchor calculation for different global market structures. Two mode options are available: crypto (weekly reset on Saturday Sydney open) and forex (weekly reset on Monday Tokyo open).

12. Settings reference
Preset
- Custom: full manual control over all settings.
- Clean scalper: sessions, EMA suite, FVG, subtle candle coloring. Low noise.
- Full context: everything on, medium transparency. Best for analysis.
- Signal focus: EMA cross, stoch RSI background, PVSRA bar color prominent. Rest subtle.
- Minimal: sessions, daily open, ADR only. No signals.
- PVSRA pro: PVSRA and vector candle zones central. EMA 200 and 800 only.

Global settings
- Master opacity offset (custom preset only): shifts all transparency values simultaneously.
- Show bull/bear label text: shows or hides text on EMA cross signal triangles.

EMA suite
- Show EMA suite and labels
- Individual EMA color and transparency controls
- EMA cloud fill and border transparency
- EMA line width

EMA cross
- Show EMA cross signals
- Fast EMA, slow EMA, and consolidated EMA lengths
- Show both EMAs or consolidated only
- Bull, bear, and neutral colors and transparency
- Cross EMA line width

Stochastic RSI
- Show stochastic RSI background alerts
- RSI length and stochastic length
- Overbought and oversold band levels
- Individual alert type toggles (four types)
- Alert colors and transparency
- RSI divergence lookback period
- Divergence line color and width

PVSRA
- Vector colors (red, green, violet, blue, regular up/down)
- Green/red threshold (× average volume, default 2.0)
- Blue/violet threshold (× average volume, default 1.5)
- Include spread filter for green/red classification
- Override symbol toggle and input
- Show vector candle zones with transparency and width settings

Candle coloring
- Enable candle coloring
- Coloring mode: EMA cross / PVSRA / EMA 200 / off
- Bull and bear candle color and transparency

Market sessions
- Show market sessions
- Session timezone
- Show sessions on weekends
- Session high/low line style and width
- Per session: toggle, box color, transparency, label color

Range levels
- Show ADR, AWR, AMR (individual toggles)
- Lookback periods for each
- Show 50% midpoint levels
- Measure from daily open (ADR only)
- Color, transparency, line width, line style, labels

Pivot points
- Show PP, R1/S1, R2/S2, R3/S3, M levels individually
- Show labels
- Extend lines both directions
- Individual level colors and line styles
- Pivot line width

Daily open
- Show daily open
- Show label
- Show historical daily opens
- Color, transparency, line width

Fair value gaps
- Show fair value gaps
- Width filter (ATR multiplier)
- Extend to current bar
- Bullish and bearish FVG colors
- Mitigation fill colors
- Keep historical FVGs after mitigation

Psychological levels
- Show psy levels and labels
- Show historical psy levels
- GMT offset (GMT+1, GMT+2, GMT+3)
- Psy type: crypto or forex
- High and low colors and transparency

Dashboard
- Show dashboard
- Position: top left, top right, bottom left, bottom right
- Size: tiny, small, normal

13. Dashboard reference
The dashboard provides eighteen live data points across all active components:
Session — the currently active market session.
EMA cross — current EMA cross direction: bull or bear.
EMA 200 — whether price is above or below the EMA 200.
Stoch RSI — current stochastic RSI condition.
RSI — current RSI value, colored green above midline and red below.
RSI divergence — active bullish or bearish divergence, or none.
PVSRA — current candle vector type.
ADR % used — how much of today's expected daily range has been consumed.
FVG active — count of open unmitigated fair value gaps and mitigation percentage.
Psy level — whether price is above or below the prior week's psychological level.
Timezone — active session timezone setting.
VCZ active — count of active vector candle zones above and below current price.
Pivot PP — current pivot point value.
Daily open — current daily open price and direction.

14. How to use
14.1 Initial setup
Select a preset that matches your primary trading style. Adjust the session timezone to match your location or your primary exchange. If you trade an instrument with unreliable volume data, enable the PVSRA override and set it to a correlated liquid instrument. Set the ADR lookback period to your preference — 14 days is a standard starting point. For FVGs, set the width filter to 0.5 or higher to exclude minor gaps.

14.2 Reading the dashboard
The dashboard is the fastest way to orient yourself on a new chart or a new session. Check session, EMA cross direction, EMA 200 position, stoch RSI state, and ADR consumed before anything else. Five seconds to a full picture of where the market stands.

14.3 Reading the chart
Check EMA alignment. When EMA 13, EMA 50, and EMA 200 are stacked in the same direction, the trend is more significant than a single crossover. Divergence between them reflects a transition or competing timeframe pressures.
Check ADR percentage. Below 50% means the day has statistical room to move. Above 80% means the day is near its expected limit and extension moves are less probable.
Look for open FVGs near current price. An unmitigated FVG in the direction of the prevailing trend is a precision reference area where price has historically returned.
Check the psy level. If price is approaching the prior week's high or low, be aware that participant behavior around those references tends to be deliberate.

14.4 Timeframe guide
1 minute to 3 minutes — clean scalper preset, candle coloring set to EMA cross.
5 minutes to 15 minutes — clean scalper or signal focus preset.
30 minutes to 1 hour — full context preset, use ADR and pivot points.
4 hours to daily — full context or minimal preset.

14.5 Tips
PVSRA override — use when your broker's volume data is unreliable, when you trade a CFD or derivative with synthetic volume, or when you want spot market volume for a futures chart.
Master opacity offset — adding 10 to 20 increases overall transparency and dims the chart if it feels cluttered. Subtracting 10 to 20 makes all elements more prominent. This shifts all transparency values simultaneously without changing individual settings. Only active in custom preset.
Not every component needs to be active at once. Most traders will find three to four components provide the context they need for their specific setup.

15. Disclaimer
This indicator is provided for educational and informational purposes only.
Nothing in this document constitutes financial advice or any form of trading recommendation.
Trading financial instruments involves substantial risk of loss.
Past performance is not indicative of future results.
You may lose all of your invested capital.
All trading decisions are made entirely by the user.
Use at your own discretion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous


// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Anonycryptous

//@version=6
indicator("Compass | Anonycryptous", shorttitle="CMP | Anonycryptous", overlay=true, max_bars_back=500, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//══════════════════════════════════════════════════════════════════════════════
// GROUP CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
var string G_PRE   = "════════ Preset ════════"
var string G_GLOB  = "════════ Global settings ════════"
var string G_EMA   = "════════ EMA suite ════════"
var string G_CROSS = "════════ Macro trend (EMA cross) ════════"
var string G_STOCH = "════════ Stoch RSI ════════"
var string G_PVSRA = "════════ PVSRA ════════"
var string G_CANDLE= "════════ Candle coloring ════════"
var string G_SESS  = "════════ Market sessions ════════"
var string G_RANGE = "════════ Range levels (ADR/AWR/AMR) ════════"
var string G_PIVOT = "════════ Pivot points ════════"
var string G_DO    = "════════ Daily open ════════"
var string G_FVG   = "════════ Fair value gaps ════════"
var string G_PSY   = "════════ Psy levels ════════"
var string G_DST   = "════════ DST info ════════"
var string G_DASH  = "════════ Dashboard ════════"
var string G_RSI   = "════════ RSI ════════"

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — PRESET
//══════════════════════════════════════════════════════════════════════════════
preset = input.string("Custom", "Preset", group=G_PRE,
     options=["Custom","Clean Scalper","Full Context","Signal Focus","Minimal","PVSRA Pro"],
     tooltip="Selecting a preset overrides all custom settings below.\n\nClean Scalper: Sessions + EMA suite + FVG + subtle candle coloring. Low noise.\nFull Context: Everything on, medium transparency. Best for analysis.\nSignal Focus: EMA cross + Stoch RSI bgcolor + PVSRA barcolor prominent. Rest subtle.\nMinimal: Sessions + Daily Open + ADR only. No signals.\nPVSRA Pro: PVSRA + Vector Candle Zones central. EMA 200/800 only.\nCustom: Full manual control of all settings.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — GLOBAL
//══════════════════════════════════════════════════════════════════════════════
masterOpacity = input.int(0, "Master Opacity Offset", group=G_GLOB, minval=-50, maxval=90, tooltip="Shifts all transparency values by this amount. Positive = more transparent (dimmer). Negative = less transparent (brighter). Only active in Custom preset.")
showBullText = input.bool(true, "Show Bull/Bear Label Text", group=G_GLOB, tooltip="Shows or hides the 'Bull' and 'Bear' text on the EMA cross signal triangles.")

f_op(int base) =>
    math.max(0, math.min(100, base + (preset == "Custom" ? masterOpacity : 0)))

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — EMA SUITE
//══════════════════════════════════════════════════════════════════════════════
showEMASuite = input.bool(true, "Show EMA suite", group=G_EMA, tooltip="Toggle all 5 EMAs and the cloud on or off. The suite covers short-term momentum (5, 13), medium-term trend (50), macro bias (200), and long-term structure (800).")
showEMALabels = input.bool(false, "Show EMA labels", group=G_EMA, tooltip="Displays the current value of each EMA as a label at the right edge of the chart. Useful for quick reference without hovering.")
col_ema1 = input.color(color.rgb(254,234,74), "EMA 5 Color", group=G_EMA)
op_ema1 = input.int(0, "EMA 5 Transparency", group=G_EMA, minval=0, maxval=100)
col_ema2 = input.color(color.rgb(253,84,87), "EMA 13 Color", group=G_EMA)
op_ema2 = input.int(0, "EMA 13 Transparency", group=G_EMA, minval=0, maxval=100)
col_ema3 = input.color(color.rgb(31,188,211), "EMA 50 Color", group=G_EMA)
op_ema3 = input.int(0, "EMA 50 Transparency", group=G_EMA, minval=0, maxval=100)
col_ema4 = input.color(color.rgb(255,255,255), "EMA 200 Color", group=G_EMA)
op_ema4 = input.int(0, "EMA 200 Transparency", group=G_EMA, minval=0, maxval=100)
col_ema5 = input.color(color.rgb(50,34,144), "EMA 800 Color", group=G_EMA)
op_ema5 = input.int(0, "EMA 800 Transparency", group=G_EMA, minval=0, maxval=100)
col_emaCloud = input.color(color.rgb(155,47,174), "EMA 50 Cloud Fill", group=G_EMA)
op_emaCloud = input.int(60, "Cloud Fill Transparency", group=G_EMA, minval=0, maxval=100)
col_emaCloudBorder = input.color(color.rgb(18,137,123), "EMA 50 Cloud Border", group=G_EMA)
op_emaCloudBorder = input.int(100, "Cloud Border Transparency", group=G_EMA, minval=0, maxval=100)
emaWidth = input.int(1, "EMA line width", group=G_EMA, minval=1, maxval=4, tooltip="Stroke weight of all EMA lines in the suite. Default 1. Increase if lines are hard to read on a busy chart.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — MACRO TREND (EMA CROSS)
//══════════════════════════════════════════════════════════════════════════════
showCross = input.bool(true, "Show EMA cross signals", group=G_CROSS, tooltip="Shows bull/bear triangles at EMA crossover bars and colors subsequent candles in the direction of the cross. Useful as a quick trend state reference — not a trade entry signal.")
crossSrc = input.source(close, "Source", group=G_CROSS)
i_fastEMA = input.int(12, "Fast EMA", group=G_CROSS, minval=1, tooltip="Period of the fast EMA. Lower = more reactive. A crossover of fast over slow triggers the bull cross signal.")
i_slowEMA = input.int(25, "Slow EMA", group=G_CROSS, minval=1, tooltip="Period of the slow EMA. Higher = smoother, fewer crossovers. The gap between fast and slow determines how quickly the cross fires.")
i_defEMA = input.int(25, "Consolidated EMA", group=G_CROSS, minval=1, tooltip="Single EMA shown when show both is off. Use this when you want a clean chart with only one trend reference line and the cross signal.")
i_bothEMAs = input.bool(true, "Show both (fast + slow)", group=G_CROSS, tooltip="When on: both the fast and slow EMA lines are visible. When off: only the consolidated EMA is shown. Cross signals fire in both modes.")
crossLineWidth = input.int(2, "Cross EMA line width", group=G_CROSS, minval=1, maxval=4, tooltip="Stroke weight of the fast and slow EMA lines in the cross system. Independent from the EMA suite width.")
col_crossBull = input.color(color.green, "Bull Cross Color", group=G_CROSS)
op_crossBull = input.int(0, "Bull Cross Transparency", group=G_CROSS, minval=0, maxval=100)
col_crossBear = input.color(color.red, "Bear Cross Color", group=G_CROSS)
op_crossBear = input.int(0, "Bear Cross Transparency", group=G_CROSS, minval=0, maxval=100)
col_crossNeut = input.color(color.rgb(255,83,13), "Neutral Cross Color", group=G_CROSS, tooltip="Color when fast and slow EMA are equal.")
op_crossNeut = input.int(0, "Neutral Transparency", group=G_CROSS, minval=0, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — STOCH RSI
//══════════════════════════════════════════════════════════════════════════════
showStochBG = input.bool(true, "Show Stoch RSI Background Alerts", group=G_STOCH, tooltip="Colors the chart background based on Stoch RSI crossover signals.")
stochSrc = input.source(close, "Source", group=G_STOCH)
smoothK = input.int(3, "K Smoothing", group=G_STOCH, minval=1, tooltip="Smoothing period for the K line.")
smoothD = input.int(3, "D Smoothing", group=G_STOCH, minval=1, tooltip="Smoothing period for the D line.")
lengthRSI = input.int(14, "RSI Length", group=G_STOCH, minval=1)
lengthStoch = input.int(14, "Stochastic Length", group=G_STOCH, minval=1)
bandUpper = input.int(80, "Upper Band (OB)", group=G_STOCH, minval=1, tooltip="Overbought level. Crossunder from above triggers OB alert.")
bandMid = input.int(50, "Middle Band", group=G_STOCH, minval=1, tooltip="Midline crossover/crossunder triggers mid alert.")
bandLower = input.int(20, "Lower Band (OS)", group=G_STOCH, minval=1, tooltip="Oversold level. Crossover from below triggers OS alert.")
stochMidAlerts = input.bool(false, "Crossover Alert at Middle Band", group=G_STOCH, tooltip="Highlights bars when K crosses D near the midline.")
stochOBOSAlerts = input.bool(false, "Crossover Alert at OB/OS Levels", group=G_STOCH, tooltip="Highlights bars when K crosses D from overbought or oversold territory.")
stochAboveAlert = input.bool(false, "Alert K > Upper Band", group=G_STOCH, tooltip="Highlights bars when K crosses down through the upper band.")
stochBelowAlert = input.bool(false, "Alert K < Lower Band", group=G_STOCH, tooltip="Highlights bars when K crosses up through the lower band.")
col_stochBull = input.color(#4CAF50, "Bull Mid Color", group=G_STOCH)
op_stochBull = input.int(70, "Bull Mid Transparency", group=G_STOCH, minval=0, maxval=100)
col_stochBear = input.color(#FF0000, "Bear Mid Color", group=G_STOCH)
op_stochBear = input.int(70, "Bear Mid Transparency", group=G_STOCH, minval=0, maxval=100)
col_stochOS = input.color(#fbc02d, "OS Bull Color", group=G_STOCH)
op_stochOS = input.int(70, "OS Bull Transparency", group=G_STOCH, minval=0, maxval=100)
col_stochOB = input.color(#000000, "OB Bear Color", group=G_STOCH)
op_stochOB = input.int(70, "OB Bear Transparency", group=G_STOCH, minval=0, maxval=100)
col_stochAbove = input.color(#ff0014, "K > Upper Color", group=G_STOCH)
op_stochAbove = input.int(70, "K > Upper Transparency", group=G_STOCH, minval=0, maxval=100)
col_stochBelow = input.color(#4CAF50, "K < Lower Color", group=G_STOCH)
op_stochBelow = input.int(70, "K < Lower Transparency", group=G_STOCH, minval=0, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — RSI
//══════════════════════════════════════════════════════════════════════════════
showRSI = input.bool(true, "Show RSI in dashboard", group=G_RSI, tooltip="Displays the current RSI value in the dashboard. Green when above midline, red when below. Used as a quick momentum reference alongside the Stoch RSI state.")
rsiSrc = input.source(close, "Source", group=G_RSI)
rsiLen = input.int(14, "RSI Length", group=G_RSI, minval=1)
rsiMid = input.int(50, "Midline", group=G_RSI, minval=1, maxval=99)
showRSIDiv      = input.bool(true,  "Show Divergence Line on Chart", group=G_RSI)
rsiDivLookback  = input.int(5,     "Divergence Lookback (bars)", group=G_RSI, minval=2, maxval=20,
     tooltip="Number of bars to look back for pivot highs/lows when detecting divergence.")
rsiDivBullCol   = input.color(color.new(#00ff00, 20), "Div Bull Color", group=G_RSI, inline="divc")
rsiDivBearCol   = input.color(color.new(#ff0000, 20), "Div Bear Color", group=G_RSI, inline="divc")
rsiDivWidth     = input.int(1, "Div Line Width", group=G_RSI, minval=1, maxval=4, inline="divw")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — PVSRA
//══════════════════════════════════════════════════════════════════════════════
col_pvsraRed = input.color(color.red, "Vector: Red", group=G_PVSRA, inline="pv1")
op_pvsraRed = input.int(0, "", group=G_PVSRA, inline="pv1", minval=0, maxval=100)
col_pvsraGreen = input.color(color.lime, "Green", group=G_PVSRA, inline="pv2")
op_pvsraGreen = input.int(0, "", group=G_PVSRA, inline="pv2", minval=0, maxval=100)
col_pvsraViolet = input.color(color.fuchsia, "Violet", group=G_PVSRA, inline="pv3")
op_pvsraViolet = input.int(0, "", group=G_PVSRA, inline="pv3", minval=0, maxval=100)
col_pvsraBlue = input.color(color.blue, "Blue", group=G_PVSRA, inline="pv4")
op_pvsraBlue = input.int(0, "", group=G_PVSRA, inline="pv4", minval=0, maxval=100)
col_pvsraUp = input.color(#999999, "Regular: Up", group=G_PVSRA, inline="pv5")
op_pvsraUp = input.int(0, "", group=G_PVSRA, inline="pv5", minval=0, maxval=100)
col_pvsraDn = input.color(#4d4d4d, "Down", group=G_PVSRA, inline="pv6")
op_pvsraDn = input.int(0, "", group=G_PVSRA, inline="pv6", minval=0, maxval=100)
pvsraVec200mult = input.float(2.0, "Green/Red threshold (× avg vol)", group=G_PVSRA, minval=0.1, step=0.1, tooltip="Volume must be >= this multiple of the 10-bar average for Green/Red vector. Lower = triggers more often.")
pvsraVec150mult = input.float(1.5, "Blue/Violet threshold (× avg vol)", group=G_PVSRA, minval=0.1, step=0.1, tooltip="Volume must be >= this multiple of the 10-bar average for Blue/Violet vector. Must be lower than Green/Red threshold.")
pvsraUseSpread  = input.bool(true,  "Include spread filter for Green/Red", group=G_PVSRA, tooltip="When on: a bar also qualifies as Green/Red if its volume×spread is the highest of the last 10 bars (classic PVSRA rule).")
overridePVSRA = input.bool(false, "Override Symbol for Volume", group=G_PVSRA, tooltip="Use a different symbol for the volume calculation, e.g. INDEX:BTCUSD.")
pvsraSym = input.string("INDEX:BTCUSD", "Override Symbol", group=G_PVSRA)
showVCZ = input.bool(true, "Show Vector Candle Zones", group=G_PVSRA, tooltip="Draws boxes at vector candle locations. Zones are cleared when price moves through them.")
vczMax = input.int(200, "Max Zones", group=G_PVSRA, minval=1, maxval=500, tooltip="Maximum number of VCZ boxes on the chart at once.")
col_vcz = input.color(color.rgb(255,230,75), "Zone Color", group=G_PVSRA)
op_vcz = input.int(90, "Zone Transparency", group=G_PVSRA, minval=0, maxval=100)
vczOverrideCol = input.bool(true, "Override Zone Color", group=G_PVSRA, tooltip="When on: all zones use the color above. When off: zones inherit the PVSRA candle color.")
vczBodyOnly = input.bool(false, "Zone defined by body only", group=G_PVSRA, tooltip="When on: zone top/bottom follows candle open/close. When off: uses full wick range.")
vczClearBody = input.bool(false, "Zones cleared by body only", group=G_PVSRA, tooltip="When on: a zone is cleared only when the candle body moves through it. When off: any wick clears it.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — CANDLE COLORING
//══════════════════════════════════════════════════════════════════════════════
enableCandleColor = input.bool(true, "Enable candle coloring", group=G_CANDLE, tooltip="Master toggle for custom candle coloring. When off, default chart candle colors are used.")
candleColorMode = input.string("EMA Cross", "Coloring Mode", group=G_CANDLE, options=["EMA Cross","PVSRA","EMA 200","Off"], tooltip="EMA Cross: candles colored green/red on fast/slow EMA direction.\nPVSRA: candles colored by volume vector type.\nEMA 200: green above EMA 200, red below.\nOff: disables custom candle coloring.")
col_candleBull = input.color(color.green, "Bull Candle Color", group=G_CANDLE)
op_candleBull = input.int(0, "Bull Candle Transparency", group=G_CANDLE, minval=0, maxval=100, tooltip="Transparency of bull candle color. 0 = fully opaque, 100 = invisible.")
col_candleBear = input.color(color.red, "Bear Candle Color", group=G_CANDLE)
op_candleBear = input.int(0, "Bear Candle Transparency", group=G_CANDLE, minval=0, maxval=100, tooltip="Transparency of bear candle color.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — MARKET SESSIONS
//══════════════════════════════════════════════════════════════════════════════
showSessions = input.bool(false, "Show market sessions", group=G_SESS, tooltip="Master toggle for all session boxes and high/low lines. When off, all session visuals are hidden regardless of individual session settings. Sessions provide context for expected volatility and liquidity conditions.")
sessTZ = input.string("UTC", "Session Timezone", group=G_SESS, options=["UTC","Europe/Amsterdam","Europe/London","America/New_York","America/Chicago","America/Los_Angeles","Asia/Tokyo","Asia/Singapore","Asia/Dubai","Australia/Sydney"], tooltip="Select your timezone.")
showWeekends = input.bool(false, "Show on weekends", group=G_SESS, tooltip="Extends session boxes into Saturday and Sunday. Relevant for crypto markets that trade 24/7.")
sessLineStyle = input.string("Dashed", "Session H/L Line Style", group=G_SESS, options=["Dashed","Solid","Dotted"])
sessLineWidth = input.int(1, "Session Line Width", group=G_SESS, minval=1, maxval=4)

showLon = input.bool(true, "London", group=G_SESS, inline="s1")
col_lon = input.color(color.rgb(120,123,134), "", group=G_SESS, inline="s1")
op_lon = input.int(87, "", group=G_SESS, inline="s1", minval=0, maxval=100)
col_lonL = input.color(color.rgb(120,123,134), "Label", group=G_SESS, inline="s1")
op_lonL = input.int(85, "", group=G_SESS, inline="s1", minval=0, maxval=100)

showNY = input.bool(true, "New York", group=G_SESS, inline="s2")
col_ny = input.color(color.rgb(251,86,91), "", group=G_SESS, inline="s2")
op_ny = input.int(87, "", group=G_SESS, inline="s2", minval=0, maxval=100)
col_nyL = input.color(color.rgb(253,84,87), "Label", group=G_SESS, inline="s2")
op_nyL = input.int(85, "", group=G_SESS, inline="s2", minval=0, maxval=100)

showTok = input.bool(true, "Tokyo", group=G_SESS, inline="s3")
col_tok = input.color(color.rgb(80,174,85), "", group=G_SESS, inline="s3")
op_tok = input.int(87, "", group=G_SESS, inline="s3", minval=0, maxval=100)
col_tokL = input.color(color.rgb(80,174,85), "Label", group=G_SESS, inline="s3")
op_tokL = input.int(85, "", group=G_SESS, inline="s3", minval=0, maxval=100)

showHK = input.bool(true, "Hong Kong", group=G_SESS, inline="s4")
col_hk = input.color(color.rgb(128,127,23), "", group=G_SESS, inline="s4")
op_hk = input.int(87, "", group=G_SESS, inline="s4", minval=0, maxval=100)
col_hkL = input.color(color.rgb(128,127,23), "Label", group=G_SESS, inline="s4")
op_hkL = input.int(85, "", group=G_SESS, inline="s4", minval=0, maxval=100)

showSyd = input.bool(true, "Sydney", group=G_SESS, inline="s5")
col_syd = input.color(color.rgb(37,228,123), "", group=G_SESS, inline="s5")
op_syd = input.int(87, "", group=G_SESS, inline="s5", minval=0, maxval=100)
col_sydL = input.color(color.rgb(37,228,123), "Label", group=G_SESS, inline="s5")
op_sydL = input.int(85, "", group=G_SESS, inline="s5", minval=0, maxval=100)

showEUB = input.bool(true, "EU Brinks", group=G_SESS, inline="s6")
col_eub = input.color(color.rgb(255,255,255), "", group=G_SESS, inline="s6")
op_eub = input.int(87, "", group=G_SESS, inline="s6", minval=0, maxval=100)
col_eubL = input.color(color.rgb(255,255,255), "Label", group=G_SESS, inline="s6")
op_eubL = input.int(85, "", group=G_SESS, inline="s6", minval=0, maxval=100)

showUSB = input.bool(true, "US Brinks", group=G_SESS, inline="s7")
col_usb = input.color(color.rgb(255,255,255), "", group=G_SESS, inline="s7")
op_usb = input.int(87, "", group=G_SESS, inline="s7", minval=0, maxval=100)
col_usbL = input.color(color.rgb(255,255,255), "Label", group=G_SESS, inline="s7")
op_usbL = input.int(85, "", group=G_SESS, inline="s7", minval=0, maxval=100)

showFRA = input.bool(false, "Frankfurt", group=G_SESS, inline="s8")
col_fra = input.color(color.rgb(253,152,39), "", group=G_SESS, inline="s8")
op_fra = input.int(87, "", group=G_SESS, inline="s8", minval=0, maxval=100)
col_fraL = input.color(color.rgb(253,152,39), "Label", group=G_SESS, inline="s8")
op_fraL = input.int(85, "", group=G_SESS, inline="s8", minval=0, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — RANGE LEVELS
//══════════════════════════════════════════════════════════════════════════════
showADR = input.bool(true, "Show ADR", group=G_RANGE, tooltip="Average Daily Range.")
adrLen = input.int(14, "ADR Length (days)", group=G_RANGE, minval=1, maxval=31)
showADR50 = input.bool(false, "Show 50% ADR", group=G_RANGE)
useADRDO = input.bool(false, "Measure from Daily Open", group=G_RANGE)
col_adr = input.color(color.silver, "ADR Color", group=G_RANGE)
op_adr = input.int(50, "ADR Transparency", group=G_RANGE, minval=0, maxval=100)
adrLineWidth = input.int(1, "ADR Line Width", group=G_RANGE, minval=1, maxval=4)

showAWR = input.bool(false, "Show AWR", group=G_RANGE)
awrLen = input.int(4, "AWR Length (weeks)", group=G_RANGE, minval=1, maxval=52)
showAWR50 = input.bool(false, "Show 50% AWR", group=G_RANGE)
col_awr = input.color(color.orange, "AWR Color", group=G_RANGE)
op_awr = input.int(50, "AWR Transparency", group=G_RANGE, minval=0, maxval=100)

showAMR = input.bool(false, "Show AMR", group=G_RANGE)
amrLen = input.int(6, "AMR Length (months)", group=G_RANGE, minval=1, maxval=12)
showAMR50 = input.bool(false, "Show 50% AMR", group=G_RANGE)
col_amr = input.color(color.red, "AMR Color", group=G_RANGE)
op_amr = input.int(50, "AMR Transparency", group=G_RANGE, minval=0, maxval=100)

rangeLineStyle = input.string("Dotted", "Range Line Style", group=G_RANGE, options=["Dotted","Dashed","Solid"])
rangeLabels = input.bool(true, "Show Range Labels", group=G_RANGE)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — PIVOT POINTS
//══════════════════════════════════════════════════════════════════════════════
showPP = input.bool(false, "Show Pivot Point", group=G_PIVOT)
showR1S1 = input.bool(false, "Show R1/S1", group=G_PIVOT)
showR2S2 = input.bool(false, "Show R2/S2", group=G_PIVOT)
showR3S3 = input.bool(false, "Show R3/S3", group=G_PIVOT)
showMlevels = input.bool(true, "Show M Levels", group=G_PIVOT)
showPivLabels = input.bool(true, "Show Labels", group=G_PIVOT)
extendPivots = input.bool(false, "Extend Lines Both Directions", group=G_PIVOT)
col_pp = input.color(color.rgb(254,234,78), "PP Color", group=G_PIVOT)
op_pp = input.int(50, "PP Transparency", group=G_PIVOT, minval=0, maxval=100)
col_r = input.color(color.green, "R Level Color", group=G_PIVOT)
op_r = input.int(50, "R Transparency", group=G_PIVOT, minval=0, maxval=100)
col_s = input.color(color.red, "S Level Color", group=G_PIVOT)
op_s = input.int(50, "S Transparency", group=G_PIVOT, minval=0, maxval=100)
col_m = input.color(color.rgb(255,255,255), "M Level Color", group=G_PIVOT)
op_m = input.int(50, "M Transparency", group=G_PIVOT, minval=0, maxval=100)
pivLineStyle = input.string("Dashed", "Pivot Line Style", group=G_PIVOT, options=["Dotted","Dashed","Solid"])
mLineStyle = input.string("Dashed", "M Level Style", group=G_PIVOT, options=["Dotted","Dashed","Solid"])
pivLineWidth = input.int(1, "Pivot Line Width", group=G_PIVOT, minval=1, maxval=4)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — DAILY OPEN
//══════════════════════════════════════════════════════════════════════════════
showDO = input.bool(true, "Show daily open", group=G_DO, tooltip="Draws a horizontal line at the current day's opening price. A key reference level — price above daily open is generally bullish context for the session, price below is bearish.")
showDOLabel = input.bool(true, "Show label", group=G_DO, tooltip="Displays the daily open price value as a label on the right edge.")
showDOHistory = input.bool(false, "Show historical daily opens", group=G_DO, tooltip="When on: previous days opening levels are shown as reference. Useful for identifying multi-day open clusters and areas of prior balance.")
col_do = input.color(color.rgb(254,234,78), "Daily Open Color", group=G_DO)
op_do = input.int(0, "Daily Open Transparency", group=G_DO, minval=0, maxval=100)
doLineWidth = input.int(1, "Line Width", group=G_DO, minval=1, maxval=4)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — FVG (absorption engine)
//══════════════════════════════════════════════════════════════════════════════
showFVG    = input.bool(true, "Show fair value gaps", group=G_FVG, tooltip="Detects and draws fair value gaps — three-bar imbalances where price moved through without leaving two-sided trade. These are precision areas where price often returns to balance.")
fvgExtend  = input.bool(true, "Extend to current bar", group=G_FVG, tooltip="When on: open FVG boxes extend to the right edge in real time, making unmitigated gaps clearly visible. When off: boxes stay fixed at their formation bars.")
fvgTH      = input.float(0.5, "Width filter (ATR multiplier)", group=G_FVG, minval=0, step=0.1, tooltip="Minimum gap width as a multiple of ATR(144). Filters out insignificant micro-gaps. 0 = show all. 0.5 = only gaps wider than half an ATR. Higher = fewer, more significant gaps only.")
fvgBC      = input.color(color.new(#089981, 55), "Bullish — Imbalance", group=G_FVG, inline="fb")
fvgAC      = input.color(color.new(#fffdfd, 100), "Mitigation", group=G_FVG, inline="fb")
fvgSC      = input.color(color.new(#f23645, 55), "Bearish — Imbalance", group=G_FVG, inline="fd")
fvgFC      = input.color(color.new(#fbf8f8, 100), "Mitigation", group=G_FVG, inline="fd")
fvgVF      = input.bool(true, "Keep historical FVGs", group=G_FVG, tooltip="When on: fully mitigated gaps remain on the chart as reference — useful to see where price has already balanced. When off: mitigated gaps are deleted to keep the chart clean.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — PSY LEVELS
//══════════════════════════════════════════════════════════════════════════════
showPsy = input.bool(true, "Show psy levels", group=G_PSY, tooltip="Draws the prior week's psychological high and low. These are weekly reference levels where participant behavior tends to be deliberate — breakouts and rejections around these levels carry structural significance.")
showPsyLabels = input.bool(true, "Show labels", group=G_PSY, tooltip="Shows text labels on the psychological level lines.")
showPsyHist = input.bool(false, "Show historical psy levels", group=G_PSY, tooltip="When on: prior weeks psychological levels remain visible as historical reference. Helps identify recurring reaction zones.")
col_psyH = input.color(color.orange, "Psy High Color", group=G_PSY)
op_psyH = input.int(30, "Psy High Transparency", group=G_PSY, minval=0, maxval=100)
col_psyL = input.color(color.orange, "Psy Low Color", group=G_PSY)
op_psyL = input.int(30, "Psy Low Transparency", group=G_PSY, minval=0, maxval=100)
psyGMToffset = input.string("GMT+2", "Psy GMT Offset", group=G_PSY, options=["GMT+1","GMT+2","GMT+3"], tooltip="GMT+2 = Sydney buiten DST (apr-okt). GMT+3 = Sydney in DST (okt-apr).")
psyTypeChoice = input.string("crypto", "Psy Type", group=G_PSY, options=["crypto","forex"], tooltip="Crypto: reset op Saturday Sydney open. Forex: reset op Monday Tokyo open.")

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — DST INFO
//══════════════════════════════════════════════════════════════════════════════
showDSTtable = input.bool(false, "Show DST Info Table", group=G_DST)
dstPos = input.string("bottom_center", "Position", group=G_DST, options=["top_right","top_left","top_center","bottom_right","bottom_left","bottom_center"])
col_dstBg = input.color(color.rgb(93,96,107), "Background", group=G_DST)
op_dstBg = input.int(70, "Background Transparency", group=G_DST, minval=0, maxval=100)
col_dstTxt = input.color(color.rgb(31,188,211), "Text", group=G_DST)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
showDash = input.bool(true, "Show dashboard", group=G_DASH, tooltip="Toggle the live data dashboard. Shows current state of all active components in one panel.")
dashPos = input.string("Bottom Right", "Position", group=G_DASH, options=["Top Right","Top Left","Bottom Right","Bottom Left"], tooltip="Corner position of the dashboard panel.")
dashSize = input.string("Small", "Size", group=G_DASH, options=["Tiny","Small","Normal"], tooltip="Text size of the dashboard. Tiny recommended on small screens or when using multiple indicators.")

//══════════════════════════════════════════════════════════════════════════════
// PRESET LOGIC
//══════════════════════════════════════════════════════════════════════════════
isCustom      = preset == "Custom"
isScalper     = preset == "Clean Scalper"
isFullContext = preset == "Full Context"
isSignalFocus = preset == "Signal Focus"
isMinimal     = preset == "Minimal"
isPVSRAPro    = preset == "PVSRA Pro"

p_showEMA    = isCustom ? showEMASuite : not isMinimal
p_showCross  = isCustom ? showCross : isScalper or isSignalFocus or isFullContext
p_showStoch  = isCustom ? showStochBG : isSignalFocus or isFullContext
p_showVCZ    = isCustom ? showVCZ : isPVSRAPro or isFullContext
p_showSess   = isCustom ? showSessions : true
p_showADR    = isCustom ? showADR : isMinimal or isFullContext or isScalper
p_showPivot  = isCustom ? (showPP or showR1S1 or showR2S2 or showR3S3 or showMlevels) : isFullContext
p_showDO     = isCustom ? showDO : true
p_showFVG    = isCustom ? showFVG : isScalper or isFullContext
p_showPsy    = isCustom ? showPsy : isFullContext or isPVSRAPro
p_candleMode = isCustom ? candleColorMode :
     isScalper ? "EMA Cross" :
     isSignalFocus ? "PVSRA" :
     isFullContext ? "EMA 200" :
     isPVSRAPro ? "PVSRA" : "Off"
p_enableCandle = isCustom ? enableCandleColor : not isMinimal

p_op_sess = isMinimal ? 92 : isScalper ? 90 : isFullContext ? 85 : 88
p_op_fvg  = isScalper ? 88 : isFullContext ? 75 : 86
p_op_ema  = isScalper ? 20 : isFullContext ? 0 : 30

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════
validIntra = timeframe.isintraday

f_lineStyle(simple string s) =>
    s == "Dotted" ? line.style_dotted : s == "Solid" ? line.style_solid : line.style_dashed

atrVal = ta.atr(14)

f_c(color c, int op) => color.new(c, f_op(op))

//══════════════════════════════════════════════════════════════════════════════
// EMA SUITE
//══════════════════════════════════════════════════════════════════════════════
ema1 = ta.ema(close, 5)
ema2 = ta.ema(close, 13)
ema3 = ta.ema(close, 50)
ema4 = ta.ema(close, 200)
ema5 = ta.ema(close, 800)

cloudSize = ta.stdev(close, 100) / 4

plot(p_showEMA ? ema1 : na, "EMA 5",   color=f_c(col_ema1, isCustom ? op_ema1 : p_op_ema), linewidth=emaWidth)
plot(p_showEMA ? ema2 : na, "EMA 13",  color=f_c(col_ema2, isCustom ? op_ema2 : p_op_ema), linewidth=emaWidth)
plot(p_showEMA ? ema3 : na, "EMA 50",  color=f_c(col_ema3, isCustom ? op_ema3 : p_op_ema), linewidth=emaWidth)
plot(p_showEMA ? ema4 : na, "EMA 200", color=f_c(col_ema4, isCustom ? op_ema4 : p_op_ema), linewidth=emaWidth)
plot(p_showEMA ? ema5 : na, "EMA 800", color=f_c(col_ema5, isCustom ? op_ema5 : p_op_ema), linewidth=emaWidth + 1)

p_cloudUp = plot(p_showEMA ? ema3 + cloudSize : na, "EMA 50 Cloud Top",    color=f_c(col_emaCloudBorder, isCustom ? op_emaCloudBorder : 100))
p_cloudDn = plot(p_showEMA ? ema3 - cloudSize : na, "EMA 50 Cloud Bottom", color=f_c(col_emaCloudBorder, isCustom ? op_emaCloudBorder : 100))
fill(p_cloudUp, p_cloudDn, color=p_showEMA ? f_c(col_emaCloud, isCustom ? op_emaCloud : 60) : na, title="EMA 50 Cloud")

if p_showEMA and showEMALabels and barstate.islast
    label.new(bar_index + 2, ema1, "5",   style=label.style_none, textcolor=f_c(col_ema1, isCustom ? op_ema1 : p_op_ema), size=size.tiny)
    label.new(bar_index + 2, ema2, "13",  style=label.style_none, textcolor=f_c(col_ema2, isCustom ? op_ema2 : p_op_ema), size=size.tiny)
    label.new(bar_index + 2, ema3, "50",  style=label.style_none, textcolor=f_c(col_ema3, isCustom ? op_ema3 : p_op_ema), size=size.tiny)
    label.new(bar_index + 2, ema4, "200", style=label.style_none, textcolor=f_c(col_ema4, isCustom ? op_ema4 : p_op_ema), size=size.tiny)
    label.new(bar_index + 2, ema5, "800", style=label.style_none, textcolor=f_c(col_ema5, isCustom ? op_ema5 : p_op_ema), size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// MACRO TREND — EMA CROSS
//══════════════════════════════════════════════════════════════════════════════
v_fast = ta.ema(crossSrc, i_fastEMA)
v_slow = ta.ema(crossSrc, i_slowEMA)
v_bias = ta.ema(crossSrc, i_defEMA)

crossBuy  = v_fast > v_slow
crossSell = v_fast < v_slow

crossLineCol = crossBuy  ? f_c(col_crossBull, isCustom ? op_crossBull : 0) :
               crossSell ? f_c(col_crossBear, isCustom ? op_crossBear : 0) :
               f_c(col_crossNeut, isCustom ? op_crossNeut : 0)

plot(p_showCross ? (i_bothEMAs ? v_fast : na) : na, "Cross Fast EMA",   color=crossLineCol, linewidth=crossLineWidth)
plot(p_showCross ? (i_bothEMAs ? v_slow : na) : na, "Cross Slow EMA",   color=crossLineCol, linewidth=crossLineWidth)
plot(p_showCross ? (i_bothEMAs ? na : v_bias) : na, "Consolidated EMA", color=crossLineCol, linewidth=crossLineWidth)

var int cntBuy  = 0
var int cntSell = 0

if crossBuy
    cntBuy  += 1
    cntSell := 0
if crossSell
    cntSell += 1
    cntBuy  := 0

bullSignal = cntBuy  == 1 and crossBuy  and not crossBuy[1]
bearSignal = cntSell == 1 and crossSell and not crossSell[1]

plotshape(p_showCross and bullSignal and showBullText     ? low  : na, "Bull Cross Text", shape.triangleup,   location.belowbar, f_c(col_crossBull, isCustom ? op_crossBull : 0), text="Bull", textcolor=color.black, size=size.small)
plotshape(p_showCross and bullSignal and not showBullText ? low  : na, "Bull Cross",      shape.triangleup,   location.belowbar, f_c(col_crossBull, isCustom ? op_crossBull : 0), size=size.tiny)
plotshape(p_showCross and bearSignal and showBullText     ? high : na, "Bear Cross Text", shape.triangledown, location.abovebar, f_c(col_crossBear, isCustom ? op_crossBear : 0), text="Bear", textcolor=color.black, size=size.small)
plotshape(p_showCross and bearSignal and not showBullText ? high : na, "Bear Cross",      shape.triangledown, location.abovebar, f_c(col_crossBear, isCustom ? op_crossBear : 0), size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// STOCH RSI
//══════════════════════════════════════════════════════════════════════════════
rsi1   = ta.rsi(stochSrc, lengthRSI)
stochK = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
stochD = ta.sma(stochK, smoothD)

crossUpMid = ta.crossover(stochK, stochD)  and (stochK < bandMid   or stochD < bandMid)
crossDnMid = ta.crossunder(stochK, stochD) and (stochK > bandMid   or stochD > bandMid)
crossUpOS  = ta.crossover(stochK, stochD)  and (stochK < bandLower or stochD < bandLower)
crossDnOB  = ta.crossunder(stochK, stochD) and (stochK > bandUpper or stochD > bandUpper)
crossAbove = ta.crossunder(stochK, bandUpper)
crossBelow = ta.crossover(stochK, bandLower)

bgcolor(p_showStoch and stochMidAlerts  and crossUpMid  ? f_c(col_stochBull,  isCustom ? op_stochBull  : 70) : na, title="Stoch Mid Bull BG")
bgcolor(p_showStoch and stochMidAlerts  and crossDnMid  ? f_c(col_stochBear,  isCustom ? op_stochBear  : 70) : na, title="Stoch Mid Bear BG")
bgcolor(p_showStoch and stochOBOSAlerts and crossUpOS   ? f_c(col_stochOS,    isCustom ? op_stochOS    : 70) : na, title="Stoch OS Bull BG")
bgcolor(p_showStoch and stochOBOSAlerts and crossDnOB   ? f_c(col_stochOB,    isCustom ? op_stochOB    : 70) : na, title="Stoch OB Bear BG")
bgcolor(p_showStoch and stochAboveAlert and crossAbove  ? f_c(col_stochAbove, isCustom ? op_stochAbove : 70) : na, title="Stoch K > Upper BG")
bgcolor(p_showStoch and stochBelowAlert and crossBelow  ? f_c(col_stochBelow, isCustom ? op_stochBelow : 70) : na, title="Stoch K < Lower BG")

stochBias = stochK > bandUpper ? "OB" : stochK < bandLower ? "OS" : stochK > bandMid ? "▲ MID" : "▼ MID"

//══════════════════════════════════════════════════════════════════════════════
// RSI + DIVERGENCE
//══════════════════════════════════════════════════════════════════════════════
rsiVal = ta.rsi(rsiSrc, rsiLen)

// Pivot detectie voor divergence
rsiPivHigh = ta.pivothigh(rsiVal, rsiDivLookback, rsiDivLookback)
rsiPivLow = ta.pivotlow(rsiVal, rsiDivLookback, rsiDivLookback)
pricePivH = ta.pivothigh(high, rsiDivLookback, rsiDivLookback)
pricePivL = ta.pivotlow(low, rsiDivLookback, rsiDivLookback)

// Bearish divergence: prijs HH maar RSI LH
var float prevRsiH = na
var float prevPriceH = na
bearDiv = false
if not na(rsiPivHigh)
    if not na(prevRsiH) and not na(prevPriceH)
        if high[rsiDivLookback] > prevPriceH and rsiPivHigh < prevRsiH
            bearDiv := true
    prevRsiH := rsiPivHigh
    prevPriceH := high[rsiDivLookback]

// Bullish divergence: prijs LL maar RSI HL
var float prevRsiL = na
var float prevPriceL = na
bullDiv = false
if not na(rsiPivLow)
    if not na(prevRsiL) and not na(prevPriceL)
        if low[rsiDivLookback] < prevPriceL and rsiPivLow > prevRsiL
            bullDiv := true
    prevRsiL := rsiPivLow
    prevPriceL := low[rsiDivLookback]

// Divergence lijn op price chart
var line rsiDivLine = na
if showRSI and showRSIDiv
    if bullDiv
        if not na(rsiDivLine)
            line.delete(rsiDivLine)
        rsiDivLine := line.new(
             bar_index[rsiDivLookback * 2], prevPriceL,
             bar_index[rsiDivLookback], low[rsiDivLookback],
             color=rsiDivBullCol, width=rsiDivWidth, style=line.style_solid)
    if bearDiv
        if not na(rsiDivLine)
            line.delete(rsiDivLine)
        rsiDivLine := line.new(
             bar_index[rsiDivLookback * 2], prevPriceH,
             bar_index[rsiDivLookback], high[rsiDivLookback],
             color=rsiDivBearCol, width=rsiDivWidth, style=line.style_solid)

// Dashboard waardes
rsiDivStatus = bullDiv ? "▲ BULL DIV" : bearDiv ? "▼ BEAR DIV" : "—"
rsiDivClrDash = bullDiv ? color.new(#00ff00, 0) : bearDiv ? color.new(#ff0000, 0) : color.new(#8b949e, 0)

//══════════════════════════════════════════════════════════════════════════════
// PVSRA
//══════════════════════════════════════════════════════════════════════════════
[pvsraVol, pvsraH, pvsraL, pvsraC, pvsraO] = request.security(
     overridePVSRA ? pvsraSym : syminfo.tickerid, "",
     [volume, high, low, close, open],
     barmerge.gaps_off, barmerge.lookahead_off)

avgVol10   = ta.sma(pvsraVol, 10)
volSpread  = pvsraVol * (pvsraH - pvsraL)
highestVS  = ta.highest(volSpread, 10)
isBullBar  = pvsraC >= pvsraO

pvsraVec200 = pvsraVol >= avgVol10 * pvsraVec200mult or (pvsraUseSpread and volSpread >= highestVS)
pvsraVec150 = pvsraVol >= avgVol10 * pvsraVec150mult and not pvsraVec200

pvsraColor =
     pvsraVec200 and isBullBar      ? f_c(col_pvsraGreen,  isCustom ? op_pvsraGreen  : 0) :
     pvsraVec200 and not isBullBar  ? f_c(col_pvsraRed,    isCustom ? op_pvsraRed    : 0) :
     pvsraVec150 and isBullBar      ? f_c(col_pvsraBlue,   isCustom ? op_pvsraBlue   : 0) :
     pvsraVec150 and not isBullBar  ? f_c(col_pvsraViolet, isCustom ? op_pvsraViolet : 0) :
     isBullBar ? f_c(col_pvsraUp, isCustom ? op_pvsraUp : 0) : f_c(col_pvsraDn, isCustom ? op_pvsraDn : 0)

isVectorCandle = pvsraVec200 or pvsraVec150

var box[] vczAbove = array.new_box()
var box[] vczBelow = array.new_box()

if p_showVCZ and isVectorCandle
    zTop   = vczBodyOnly ? math.max(pvsraO, pvsraC) : pvsraH
    zBot   = vczBodyOnly ? math.min(pvsraO, pvsraC) : pvsraL
    zCol   = vczOverrideCol ? f_c(col_vcz, isCustom ? op_vcz : 90) : color.new(pvsraColor, isCustom ? op_vcz : 90)
    newBox = box.new(bar_index, zTop, bar_index, zBot, bgcolor=zCol, border_width=0)
    if isBullBar
        array.push(vczAbove, newBox)
    else
        array.push(vczBelow, newBox)

f_cleanZones(box[] arr, bool isUp) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            bx = array.get(arr, i)
            box.set_right(bx, bar_index)
            clearHi = vczClearBody ? math.max(open, close) : high
            clearLo = vczClearBody ? math.min(open, close) : low
            cleared = isUp ? clearHi > box.get_top(bx) : clearLo < box.get_bottom(bx)
            if cleared
                array.remove(arr, i)
        while array.size(arr) > vczMax
            box.delete(array.shift(arr))

f_cleanZones(vczAbove, true)
f_cleanZones(vczBelow, false)

//══════════════════════════════════════════════════════════════════════════════
// CANDLE COLORING
//══════════════════════════════════════════════════════════════════════════════
candleBullCol = f_c(col_candleBull, isCustom ? op_candleBull : 0)
candleBearCol = f_c(col_candleBear, isCustom ? op_candleBear : 0)

candleCol =
     p_candleMode == "EMA Cross" ? (crossBuy ? candleBullCol : candleBearCol) :
     p_candleMode == "PVSRA"     ? pvsraColor :
     p_candleMode == "EMA 200"   ? (close > ema4 ? candleBullCol : candleBearCol) : na

barcolor(p_enableCandle and p_candleMode != "Off" ? candleCol : na)

//══════════════════════════════════════════════════════════════════════════════
// MARKET SESSIONS
//══════════════════════════════════════════════════════════════════════════════
f_inSession(string t, string tz) => not na(time(timeframe.period, t, tz))

inLon = p_showSess and showLon and f_inSession("0800-1630", sessTZ)
inNY = p_showSess and showNY and f_inSession("1430-2100", sessTZ)
inTok = p_showSess and showTok and f_inSession("0000-0600", sessTZ)
inHK = p_showSess and showHK and f_inSession("0130-0800", sessTZ)
inSyd = p_showSess and showSyd and f_inSession("2200-0600", sessTZ)
inEUB = p_showSess and showEUB and f_inSession("0800-0900", sessTZ)
inUSB = p_showSess and showUSB and f_inSession("1400-1500", sessTZ)
inFRA = p_showSess and showFRA and f_inSession("0700-1630", sessTZ)

sessLineStyleVal = f_lineStyle(sessLineStyle)

f_drawSession(bool inSess, bool wasInSess, color boxCol, int boxOp, color lineCol, int lineOp, string lbl) =>
    var box   bx = na
    var line  lnH = na
    var line  lnL = na
    var label lb  = na
    var float sH  = na
    var float sL  = na

    bxCol = f_c(boxCol,  isCustom ? boxOp  : p_op_sess)
    lnCol = f_c(lineCol, isCustom ? lineOp : 0)

    if inSess and not wasInSess
        sH  := high
        sL  := low
        bx  := box.new(time, high, time, low, xloc=xloc.bar_time, bgcolor=bxCol, border_color=color.new(lineCol, 25))
        lnH := line.new(time, high, time, high, xloc=xloc.bar_time, color=lnCol, width=sessLineWidth, style=sessLineStyleVal)
        lnL := line.new(time, low,  time, low,  xloc=xloc.bar_time, color=lnCol, width=sessLineWidth, style=sessLineStyleVal)
        lb  := label.new(bar_index, high + atrVal * 0.3, lbl, style=label.style_none, textcolor=lnCol, size=size.small)

    if inSess
        sH := math.max(nz(sH, high), high)
        sL := math.min(nz(sL, low),  low)
        if not na(bx)
            box.set_right(bx, time_close)
            box.set_top(bx, sH)
            box.set_bottom(bx, sL)
            box.set_bgcolor(bx, bxCol)
        if not na(lnH)
            line.set_x2(lnH, time_close)
            line.set_y1(lnH, sH)
            line.set_y2(lnH, sH)
            line.set_color(lnH, lnCol)
        if not na(lnL)
            line.set_x2(lnL, time_close)
            line.set_y1(lnL, sL)
            line.set_y2(lnL, sL)
            line.set_color(lnL, lnCol)
        if not na(lb)
            label.set_y(lb, sH + atrVal * 0.3)
            label.set_x(lb, bar_index)
            label.set_textcolor(lb, lnCol)
    [sH, sL]

[lonH, lonL] = f_drawSession(inLon, inLon[1], col_lon, op_lon, col_lonL, op_lonL, "London")
[nyH,  nyL]  = f_drawSession(inNY,  inNY[1],  col_ny,  op_ny,  col_nyL,  op_nyL,  "New York")
[tokH, tokL] = f_drawSession(inTok, inTok[1], col_tok, op_tok, col_tokL, op_tokL, "Tokyo")
[hkH,  hkL]  = f_drawSession(inHK,  inHK[1],  col_hk,  op_hk,  col_hkL,  op_hkL,  "HK")
[sydH, sydL] = f_drawSession(inSyd, inSyd[1], col_syd, op_syd, col_sydL, op_sydL, "Sydney")
f_drawSession(inEUB, inEUB[1], col_eub, op_eub, col_eubL, op_eubL, "EU Brinks")
f_drawSession(inUSB, inUSB[1], col_usb, op_usb, col_usbL, op_usbL, "US Brinks")
f_drawSession(inFRA, inFRA[1], col_fra, op_fra, col_fraL, op_fraL, "Frankfurt")

activeSessLabel =
     inNY  ? "▶ NEW YORK"   :
     inLon ? "▶ LONDON"     :
     inTok ? "▶ TOKYO"      :
     inHK  ? "▶ HONG KONG"  :
     inSyd ? "▶ SYDNEY"     :
     inEUB ? "▶ EU BRINKS"  :
     inUSB ? "▶ US BRINKS"  :
     inFRA ? "▶ FRANKFURT"  : "— OFF"

//══════════════════════════════════════════════════════════════════════════════
// RANGE LEVELS (ADR / AWR / AMR)
//══════════════════════════════════════════════════════════════════════════════
f_adrHiLo(int len, string tf, bool useOpen) =>
    [rng, rngH, rngL] = request.security(syminfo.tickerid, tf,
         [ta.sma(high - low, len),
          useOpen ? open + ta.sma(high - low, len) / 2 : ta.highest(high, 1),
          useOpen ? open - ta.sma(high - low, len) / 2 : ta.lowest(low, 1)],
         lookahead=barmerge.lookahead_on)
    [rng, rngH, rngL]

rangeStyleVal = f_lineStyle(rangeLineStyle)

[dayAdr,   dayAdrH,   dayAdrL]   = f_adrHiLo(adrLen, "D", useADRDO)
[weekAdr,  weekAdrH,  weekAdrL]  = f_adrHiLo(awrLen, "W", false)
[monthAdr, monthAdrH, monthAdrL] = f_adrHiLo(amrLen, "M", false)

dayAdrH50   = dayAdrH   - dayAdr   / 2
dayAdrL50   = dayAdrL   + dayAdr   / 2
weekAdrH50  = weekAdrH  - weekAdr  / 2
weekAdrL50  = weekAdrL  + weekAdr  / 2
monthAdrH50 = monthAdrH - monthAdr / 2
monthAdrL50 = monthAdrL + monthAdr / 2

f_drawRangeLine(float lvl, string lbl, color clr, int op, int wid) =>
    var line  ln = na
    var label lb = na
    if barstate.islast and not na(lvl) and lvl != 0
        if not na(ln)
            line.delete(ln)
        if not na(lb)
            label.delete(lb)
        ln := line.new(bar_index - 50, lvl, bar_index + 10, lvl, color=f_c(clr, op), width=wid, style=rangeStyleVal)
        if rangeLabels
            lb := label.new(bar_index + 10, lvl, lbl, style=label.style_none, textcolor=f_c(clr, op), size=size.small)

if p_showADR and validIntra
    f_drawRangeLine(dayAdrH, "Hi-ADR" + (useADRDO ? "(DO)" : ""), col_adr, isCustom ? op_adr : 50, adrLineWidth)
    f_drawRangeLine(dayAdrL, "Lo-ADR" + (useADRDO ? "(DO)" : ""), col_adr, isCustom ? op_adr : 50, adrLineWidth)
    if showADR50
        f_drawRangeLine(dayAdrH50, "50% Hi-ADR", col_adr, isCustom ? op_adr : 50, adrLineWidth)
        f_drawRangeLine(dayAdrL50, "50% Lo-ADR", col_adr, isCustom ? op_adr : 50, adrLineWidth)

if showAWR and validIntra
    f_drawRangeLine(weekAdrH, "Hi-AWR", col_awr, isCustom ? op_awr : 50, adrLineWidth)
    f_drawRangeLine(weekAdrL, "Lo-AWR", col_awr, isCustom ? op_awr : 50, adrLineWidth)
    if showAWR50
        f_drawRangeLine(weekAdrH50, "50% Hi-AWR", col_awr, isCustom ? op_awr : 50, adrLineWidth)
        f_drawRangeLine(weekAdrL50, "50% Lo-AWR", col_awr, isCustom ? op_awr : 50, adrLineWidth)

if showAMR and validIntra
    f_drawRangeLine(monthAdrH, "Hi-AMR", col_amr, isCustom ? op_amr : 50, adrLineWidth)
    f_drawRangeLine(monthAdrL, "Lo-AMR", col_amr, isCustom ? op_amr : 50, adrLineWidth)
    if showAMR50
        f_drawRangeLine(monthAdrH50, "50% Hi-AMR", col_amr, isCustom ? op_amr : 50, adrLineWidth)
        f_drawRangeLine(monthAdrL50, "50% Lo-AMR", col_amr, isCustom ? op_amr : 50, adrLineWidth)

adrPct = dayAdr != 0 ? (high - dayAdrL) / dayAdr * 100 : 0

//══════════════════════════════════════════════════════════════════════════════
// PIVOT POINTS
//══════════════════════════════════════════════════════════════════════════════
[dH, dL, dC] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)

pp    = (dH + dL + dC) / 3
pivR1 = 2 * pp - dL
pivS1 = 2 * pp - dH
pivR2 = pp - pivS1 + pivR1
pivS2 = pp - pivR1 + pivS1
pivR3 = 2 * pp + dH - 2 * dL
pivS3 = 2 * pp - (2 * dH - dL)
m0    = (pivS2 + pivS3) / 2
m1    = (pivS1 + pivS2) / 2
m2    = (pp + pivS1) / 2
m3    = (pp + pivR1) / 2
m4    = (pivR1 + pivR2) / 2
m5    = (pivR2 + pivR3) / 2

extDir = extendPivots ? extend.both : extend.right

f_drawPivot(float lvl, string lbl, color clr, int op, simple string st, bool show) =>
    var line  ln = na
    var label lb = na
    if barstate.islast and show and validIntra and not na(lvl)
        if not na(ln)
            line.delete(ln)
        if not na(lb)
            label.delete(lb)
        st_val = st == "Dotted" ? line.style_dotted : st == "Solid" ? line.style_solid : line.style_dashed
        ln := line.new(bar_index - 50, lvl, bar_index + 6, lvl, color=f_c(clr, op), width=pivLineWidth, style=st_val, extend=extDir)
        if showPivLabels
            lb := label.new(bar_index + 6, lvl, lbl, style=label.style_none, textcolor=f_c(clr, op), size=size.small)

f_drawPivot(pp,    "PP", col_pp, isCustom ? op_pp : 50, pivLineStyle, p_showPivot and showPP)
f_drawPivot(pivR1, "R1", col_r,  isCustom ? op_r  : 50, pivLineStyle, p_showPivot and showR1S1)
f_drawPivot(pivS1, "S1", col_s,  isCustom ? op_s  : 50, pivLineStyle, p_showPivot and showR1S1)
f_drawPivot(pivR2, "R2", col_r,  isCustom ? op_r  : 50, pivLineStyle, p_showPivot and showR2S2)
f_drawPivot(pivS2, "S2", col_s,  isCustom ? op_s  : 50, pivLineStyle, p_showPivot and showR2S2)
f_drawPivot(pivR3, "R3", col_r,  isCustom ? op_r  : 50, pivLineStyle, p_showPivot and showR3S3)
f_drawPivot(pivS3, "S3", col_s,  isCustom ? op_s  : 50, pivLineStyle, p_showPivot and showR3S3)
f_drawPivot(m0, "M0", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)
f_drawPivot(m1, "M1", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)
f_drawPivot(m2, "M2", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)
f_drawPivot(m3, "M3", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)
f_drawPivot(m4, "M4", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)
f_drawPivot(m5, "M5", col_m, isCustom ? op_m : 50, mLineStyle, p_showPivot and showMlevels)

//══════════════════════════════════════════════════════════════════════════════
// DAILY OPEN
//══════════════════════════════════════════════════════════════════════════════
dailyOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)

plot(p_showDO and validIntra and showDOHistory ? dailyOpen : na, "Daily Open", color=f_c(col_do, isCustom ? op_do : 0), style=plot.style_stepline, linewidth=doLineWidth)

var line  doLine  = na
var label doLabel = na

if p_showDO and validIntra and not showDOHistory and barstate.islast
    if not na(doLine)
        line.delete(doLine)
    if not na(doLabel)
        label.delete(doLabel)
    doLine := line.new(bar_index - 50, dailyOpen, bar_index + 10, dailyOpen, color=f_c(col_do, isCustom ? op_do : 0), width=doLineWidth)
    if showDOLabel
        doLabel := label.new(bar_index + 10, dailyOpen, "Daily Open", style=label.style_none, textcolor=f_c(col_do, isCustom ? op_do : 0), size=size.small)

//══════════════════════════════════════════════════════════════════════════════
// FVG — ABSORPTION ENGINE 
//══════════════════════════════════════════════════════════════════════════════

type FVGobj
    box    uBox   // unmitigated gap
    box    mBox   // mitigated (absorbed) portion
    box    tBox   // text overlay
    line   cLine  // CE / border line
    bool   isBull

var FVGobj[] fvgList = array.new<FVGobj>()
var float fvgMitPctUp = 0.0   // last bull FVG mitigation %
var float fvgMitPctDn = 0.0   // last bear FVG mitigation %

fvgAtr = nz(ta.atr(144)) * fvgTH

// Detection — same logic as Matrix.
bullFVG = (low - high[2]) > fvgAtr and low > high[2] and close[1] > high[2] and not (low > high[1] or low[1] > high[2])
bearFVG = (low[2] - high) > fvgAtr and high < low[2] and close[1] < low[2] and not (high < low[1] or high[1] < low[2])

if p_showFVG and bullFVG
    gTop = low
    gBot = high[2]
    newObj = FVGobj.new(
         box.new(bar_index - 1, gTop, bar_index, gBot,  bgcolor=fvgBC, border_color=color.new(color.white, 100)),
         box.new(bar_index - 1, gTop, bar_index, gTop,  bgcolor=fvgAC, border_color=color.new(color.white, 100)),
         box.new(bar_index - 1, gTop, bar_index, gBot,  bgcolor=color.new(color.white, 100), border_color=color.new(color.white, 100), text="", text_color=chart.fg_color, text_size=size.small),
         line.new(bar_index - 1, gBot, bar_index, gBot, color=fvgBC, width=2),
         true)
    array.push(fvgList, newObj)

if p_showFVG and bearFVG
    gTop = low[2]
    gBot = high
    newObj = FVGobj.new(
         box.new(bar_index - 1, gTop, bar_index, gBot,  bgcolor=fvgSC, border_color=color.new(color.white, 100)),
         box.new(bar_index - 1, gBot, bar_index, gBot,  bgcolor=fvgFC, border_color=color.new(color.white, 100)),
         box.new(bar_index - 1, gTop, bar_index, gBot,  bgcolor=color.new(color.white, 100), border_color=color.new(color.white, 100), text="", text_color=chart.fg_color, text_size=size.small),
         line.new(bar_index - 1, gTop, bar_index, gTop, color=fvgSC, width=2),
         false)
    array.push(fvgList, newObj)

// Update loop — runs every bar for all active FVGs
var int activeFVGup = 0
var int activeFVGdn = 0

if p_showFVG and array.size(fvgList) > 0
    activeFVGup := 0
    activeFVGdn := 0
    i = array.size(fvgList) - 1
    while i >= 0
        obj   = array.get(fvgList, i)
        uB    = obj.uBox
        mB    = obj.mBox
        tB    = obj.tBox
        cL    = obj.cLine
        isUp  = obj.isBull

        uTop  = uB.get_top()
        uBot  = uB.get_bottom()
        mTop  = mB.get_top()
        mBot  = mB.get_bottom()

        // Extend to current bar if setting is on
        if fvgExtend
            uB.set_right(bar_index)
            mB.set_right(bar_index)
            tB.set_right(bar_index)
            cL.set_x2(bar_index)

        fullyMitigated = false

        if isUp
            // Bullish FVG: price enters from below
            if high > uBot and low < uTop
                if low > uBot
                    // Partial absorption from bottom
                    newMBot = math.min(low, mTop)
                    mB.set_bottom(newMBot)
                    uB.set_top(newMBot)
                    fvgMitPctUp := (mTop - newMBot) / (mTop - uBot) * 100
                    // % shown in dashboard only
                else
                    // Full absorption
                    mB.set_bottom(uBot)
                    uB.set_top(uBot)
                    tB.set_text("")
                    fullyMitigated := true
        else
            // Bearish FVG: price enters from above
            if low < uTop and high > uBot
                if high < uTop
                    // Partial absorption from top
                    newMTop = math.max(high, mBot)
                    mB.set_top(newMTop)
                    uB.set_bottom(newMTop)
                    fvgMitPctDn := (newMTop - mBot) / (uTop - mBot) * 100
                    // % shown in dashboard only
                else
                    // Full absorption
                    mB.set_top(uTop)
                    uB.set_bottom(uTop)
                    tB.set_text("")
                    fullyMitigated := true

        if fullyMitigated
            array.remove(fvgList, i)
            if fvgVF
                // Keep historical — make fully transparent
                uB.set_bgcolor(color.new(color.white, 100))
                mB.set_bgcolor(color.new(color.white, 100))
                cL.set_color(color.new(color.white, 100))
            else
                uB.delete()
                mB.delete()
                tB.delete()
                cL.delete()
        else
            if isUp
                activeFVGup += 1
            else
                activeFVGdn += 1
        i -= 1

//══════════════════════════════════════════════════════════════════════════════
// PSY LEVELS
//══════════════════════════════════════════════════════════════════════════════
validPsyTF = timeframe.isminutes and (timeframe.multiplier == 60 or timeframe.multiplier == 30 or timeframe.multiplier == 15 or timeframe.multiplier == 5 or timeframe.multiplier == 3 or timeframe.multiplier == 1)

// Psy berekening — crypto: Saturday Sydney open / forex: Monday Tokyo open
psyInSession = psyTypeChoice == "crypto" ?
     not na(time("240", "0000-0800:1", psyGMToffset)) :
     not na(time("240", "0000-0800:2", psyGMToffset))
psyNewSession = psyInSession and not psyInSession[1]

var float psyHighFinal = 0.0
var float psyLowFinal = 100000000000.0

psyHighFinal := psyNewSession ? high : psyInSession ? math.max(high, psyHighFinal[1]) : psyHighFinal[1]
psyLowFinal := psyNewSession ? low : psyInSession ? math.min(low, psyLowFinal[1]) : psyLowFinal[1]
psyStartTime = time("D", "0000-0800:1", psyGMToffset)

psyHCol = f_c(col_psyH, isCustom ? op_psyH : 30)
psyLCol = f_c(col_psyL, isCustom ? op_psyL : 30)

plot(p_showPsy and validPsyTF and showPsyHist ? psyHighFinal : na, "Psy High", color=psyHCol, style=plot.style_stepline, linewidth=1)
plot(p_showPsy and validPsyTF and showPsyHist ? psyLowFinal : na, "Psy Low", color=psyLCol, style=plot.style_stepline, linewidth=1)

var line psyHline = na
var line psyLline = na
var label psyHlbl = na
var label psyLlbl = na

if p_showPsy and validPsyTF and not showPsyHist and barstate.islast and psyHighFinal != 0.0
    if not na(psyHline)
        line.delete(psyHline)
    if not na(psyLline)
        line.delete(psyLline)
    if not na(psyHlbl)
        label.delete(psyHlbl)
    if not na(psyLlbl)
        label.delete(psyLlbl)
    psyHline := line.new(bar_index - 300, psyHighFinal, bar_index, psyHighFinal, color=psyHCol)
    psyLline := line.new(bar_index - 300, psyLowFinal, bar_index, psyLowFinal, color=psyLCol)
    if showPsyLabels
        psyHlbl := label.new(bar_index + 3, psyHighFinal, "Psy Hi", style=label.style_none, textcolor=psyHCol, size=size.small)
        psyLlbl := label.new(bar_index + 3, psyLowFinal, "Psy Lo", style=label.style_none, textcolor=psyLCol, size=size.small)

psyStatus = psyHighFinal != 0.0 and close > psyHighFinal ? "▲ ABOVE PSY H" : psyLowFinal != 100000000000.0 and close < psyLowFinal ? "▼ BELOW PSY L" : "● INSIDE"

//══════════════════════════════════════════════════════════════════════════════
// DST TABLE
//══════════════════════════════════════════════════════════════════════════════
dstPosMap =
     dstPos == "top_right"    ? position.top_right :
     dstPos == "top_left"     ? position.top_left :
     dstPos == "top_center"   ? position.top_center :
     dstPos == "bottom_right" ? position.bottom_right :
     dstPos == "bottom_left"  ? position.bottom_left : position.bottom_center

if showDSTtable and barstate.islast
    var table dstTable = table.new(dstPosMap, 1, 8, bgcolor=f_c(col_dstBg, isCustom ? op_dstBg : 70))
    table.cell(dstTable, 0, 0, "London DST: Last Sunday March → Last Sunday October",    text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 1, "New York DST: 2nd Sunday March → 1st Sunday November",   text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 2, "Tokyo: no DST",                                           text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 3, "Hong Kong: no DST",                                       text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 4, "Sydney DST: 1st Sunday October → 1st Sunday April",      text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 5, "EU Brinks DST: Last Sunday March → Last Sunday October", text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 6, "US Brinks DST: 2nd Sunday March → 1st Sunday November", text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dstTable, 0, 7, "Frankfurt DST: Last Sunday March → Last Sunday October", text_color=col_dstTxt, text_halign=text.align_left, text_size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(ta.crossover(v_fast, v_slow),  "EMA Cross Bull",     "Bullish EMA crossover")
alertcondition(ta.crossunder(v_fast, v_slow), "EMA Cross Bear",     "Bearish EMA crossover")
alertcondition(crossUpMid,                    "Stoch RSI Bull Mid", "Stoch RSI bullish cross at midline")
alertcondition(crossDnMid,                    "Stoch RSI Bear Mid", "Stoch RSI bearish cross at midline")
alertcondition(crossUpOS,                     "Stoch RSI Bull OS",  "Stoch RSI bullish cross from oversold")
alertcondition(crossDnOB,                     "Stoch RSI Bear OB",  "Stoch RSI bearish cross from overbought")
alertcondition(isVectorCandle,                "Compass — Vector candle",      "Compass — PVSRA vector candle detected")
alertcondition(ta.crossover(close, dayAdrH),  "Compass — ADR high reached",   "Compass — Price reached ADR high")
alertcondition(ta.crossunder(close, dayAdrL), "Compass — ADR low reached",    "Compass — Price reached ADR low")
alertcondition(bullFVG,                       "Compass — FVG bull formed",      "Compass — Bullish FVG confirmed")
alertcondition(bearFVG,                       "Compass — FVG bear formed",    "Compass — Bearish FVG confirmed")

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
var table dashTR = table.new(position.top_right,    2, 16, bgcolor=color.new(#0d1117,10), border_color=color.new(#30363d,20), border_width=1, frame_color=color.new(#30363d,40), frame_width=1)
var table dashTL = table.new(position.top_left,     2, 16, bgcolor=color.new(#0d1117,10), border_color=color.new(#30363d,20), border_width=1, frame_color=color.new(#30363d,40), frame_width=1)
var table dashBR = table.new(position.bottom_right, 2, 16, bgcolor=color.new(#0d1117,10), border_color=color.new(#30363d,20), border_width=1, frame_color=color.new(#30363d,40), frame_width=1)
var table dashBL = table.new(position.bottom_left,  2, 16, bgcolor=color.new(#0d1117,10), border_color=color.new(#30363d,20), border_width=1, frame_color=color.new(#30363d,40), frame_width=1)

dash = dashPos == "Top Left" ? dashTL : dashPos == "Bottom Right" ? dashBR : dashPos == "Bottom Left" ? dashBL : dashTR

if showDash and barstate.islast
    dSz    = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
    cMuted = color.new(#8b949e, 0)
    cWhite = color.new(#ffffff, 0)
    cPanel = color.new(#161b22, 0)
    cBull  = color.new(#00ff00, 0)
    cBear  = color.new(#ff0000, 0)

    sessHdrCol =
         inNY  ? color.new(col_nyL,  75) :
         inLon ? color.new(col_lonL, 75) :
         inTok ? color.new(col_tokL, 75) :
         color.new(#30363d, 75)

    table.cell(dash, 0, 0, "COMPASS", text_color=cWhite,  text_size=dSz, bgcolor=sessHdrCol, text_halign=text.align_left)
    table.cell(dash, 1, 0, preset,            text_color=cMuted,  text_size=dSz, bgcolor=sessHdrCol, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Session",       text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 1, activeSessLabel, text_color=cWhite, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    crossLabel = crossBuy ? "▲ BULL CROSS" : "▼ BEAR CROSS"
    crossClr   = crossBuy ? cBull : cBear
    table.cell(dash, 0, 2, "EMA Cross", text_color=cMuted,   text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 2, crossLabel,  text_color=crossClr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    ema200lbl = close > ema4 ? "▲ ABOVE 200" : "▼ BELOW 200"
    ema200clr = close > ema4 ? cBull : cBear
    table.cell(dash, 0, 3, "EMA 200",  text_color=cMuted,    text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 3, ema200lbl,  text_color=ema200clr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    stochClr = stochBias == "OB" ? cBear : stochBias == "OS" ? cBull : cMuted
    table.cell(dash, 0, 4, "Stoch RSI", text_color=cMuted,   text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 4, stochBias,   text_color=stochClr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    rsiStr = showRSI ? str.tostring(math.round(rsiVal, 1)) : "—"
    rsiClr = rsiVal >= rsiMid ? cBull : cBear
    table.cell(dash, 0, 5, "RSI", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 5, rsiStr, text_color=rsiClr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    table.cell(dash, 0, 6, "RSI Div", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 6, rsiDivStatus, text_color=rsiDivClrDash, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    pvsraLabel =
         pvsraColor == f_c(col_pvsraGreen,  isCustom ? op_pvsraGreen  : 0) ? "● GREEN VECTOR" :
         pvsraColor == f_c(col_pvsraRed,    isCustom ? op_pvsraRed    : 0) ? "● RED VECTOR" :
         pvsraColor == f_c(col_pvsraBlue,   isCustom ? op_pvsraBlue   : 0) ? "● BLUE VECTOR" :
         pvsraColor == f_c(col_pvsraViolet, isCustom ? op_pvsraViolet : 0) ? "● VIOLET VECTOR" : "— REGULAR"
    table.cell(dash, 0, 7, "PVSRA",    text_color=cMuted,     text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 7, pvsraLabel, text_color=pvsraColor, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    adrPctStr = str.tostring(math.round(adrPct, 1)) + "% ADR used"
    adrPctClr = adrPct > 80 ? cBear : adrPct > 50 ? color.new(#f5c518,0) : cBull
    table.cell(dash, 0, 8, "ADR Range", text_color=cMuted,    text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 8, adrPctStr,   text_color=adrPctClr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    fvgUpStr  = str.tostring(activeFVGup) + "▲"
    fvgDnStr  = str.tostring(activeFVGdn) + "▼"
    fvgPctStr = activeFVGup > 0 ? " " + str.tostring(math.round(fvgMitPctUp)) + "%" : activeFVGdn > 0 ? " " + str.tostring(math.round(fvgMitPctDn)) + "%" : ""
    fvgStr = fvgUpStr + " " + fvgDnStr + fvgPctStr
    fvgClr = activeFVGup > activeFVGdn ? cBull : activeFVGdn > activeFVGup ? cBear : cMuted
    table.cell(dash, 0, 9, "FVG Active", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 9, fvgStr,       text_color=fvgClr, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    table.cell(dash, 0, 10, "Psy Level", text_color=cMuted,  text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 10, psyStatus,   text_color=psyHCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    table.cell(dash, 0, 11, "Timezone", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 11, sessTZ,     text_color=cWhite, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    vczStr = str.tostring(array.size(vczAbove)) + "▲ " + str.tostring(array.size(vczBelow)) + "▼"
    table.cell(dash, 0, 12, "VCZ Active", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 12, vczStr,       text_color=cWhite, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    ppStr = validIntra and not na(pp) ? str.tostring(pp, format.mintick) : "—"
    table.cell(dash, 0, 13, "Pivot PP", text_color=cMuted,                              text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 13, ppStr,      text_color=f_c(col_pp, isCustom ? op_pp : 50), text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    doStr = not na(dailyOpen) ? str.tostring(dailyOpen, format.mintick) : "—"
    doClr = close > dailyOpen ? cBull : cBear
    table.cell(dash, 0, 14, "Daily Open", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 14, doStr,        text_color=doClr,  text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    table.cell(dash, 0, 15, "ANONYCRYPTOUS", text_color=color.new(#bb86fc,0), text_size=dSz, bgcolor=color.new(#0d1117,0), text_halign=text.align_left)
    table.cell(dash, 1, 15, "v1.0",       text_color=color.new(#8b949e,0), text_size=dSz, bgcolor=color.new(#0d1117,0), text_halign=text.align_right)
````
