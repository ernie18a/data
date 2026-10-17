# Uptrick: Adaptive Trend Trail

- url: https://www.tradingview.com/script/f4N0F439-Uptrick-Adaptive-Trend-Trail/
- type: indicator
- pine_id: PUB;6f2fdb5737654d8cb3b6fdd9afdc5ec8
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick: Adaptive Trend Trail is a trend-following overlay indicator that holds one of three states, bullish, bearish or neutral, where neutral applies only before the first confirmed flip on the chart. That state is visualized through a layered ATR trail or volatility bands, colored candles, and reversal labels. Rather than deriving direction from a single crossover, the indicator builds a composite regime score from nine weighted measurements, requires agreement from three internally calculated adaptive Supertrends, and then applies confirmation, cooldown and hysteresis rules whose strictness changes with measured market conditions. It also includes a valuation meter and a set of internal simulation statistics displayed in the Data Window.

The design intent is to require more evidence before accepting a state change when measured directional efficiency is low, rather than to detect every turn as early as possible.

[b][i]Originality[/i][/b]
A trend state can be derived from a single measurement: a moving average cross, one Supertrend, or one oscillator threshold. Each responds to a different aspect of price and each has conditions where it carries less information. A long moving average responds slowly. A single volatility-stop line can change direction repeatedly when price oscillates within its band width. An oscillator carries no information about price structure or volatility state. This script combines measurements that are informative under different conditions, so that no single one can force a state change on its own, and it makes the strictness of the decision depend on measured market conditions rather than holding it fixed.

[b][i]Why these specific components were chosen[/i]:[/b]
Directional efficiency (net movement over total path traveled over 10 bars) is used because it distinguishes directional movement from back-and-forth movement covering the same ground. Its inverse, chop, is the central control variable of the script. Chop is not only an input to the score; it directly changes how many Supertrends must agree, how many bars a signal must persist, how wide the hysteresis gate is, and how long the cooldown lasts. This is the mechanism that lets one configuration behave differently in high-efficiency and low-efficiency conditions without the user changing settings.

Three Supertrends at different ATR lengths (fast 9, medium 14, slow 21) are used instead of one because a single Supertrend returns a binary direction with no measure of agreement. Three produce a vote count, which serves both as a gate (how many must agree) and as a continuous input to the composite score (vote difference divided by three). Their ATR multipliers are not fixed: chop and volatility expansion are added on top of the user's base factor, so all three widen as efficiency falls or volatility expands.

Distance from the EMA baseline and momentum are both normalized by ATR rather than used raw. This expresses them relative to recent volatility and reduces their dependence on the instrument's absolute price scale, so the same threshold values remain meaningful on instruments with very different nominal prices.

Baseline slope and a slower HL2 baseline slope are included because distance alone does not distinguish a market moving away from its mean from one moving back toward it. Two slopes at different speeds mean a short-term push against a flat longer-term structure contributes less to the score than an aligned move.

RSI is included with a small weight (0.08) as a momentum cross-check rather than as a signal generator. At that weight it cannot on its own carry the score past the gate.

Candle pressure (body direction and close location within the bar) and structure breaks (close beyond the prior N-bar high or low) are included with small weights (0.05 each) because they respond on the current bar, adding a small amount of immediacy to a score otherwise built from lagging averages.

[b]How they work together[/b]: the nine fields are blended into one regime value smoothed by a 3-period EMA. That value must exceed a dynamic gate whose size grows with selectivity, chop and volatility deviation. Price must also be displaced from the baseline. Momentum must have the correct sign. The Supertrend vote must be confirmed and persistent. Only then does a candidate exist, and the candidate must persist for one to three consecutive bars depending on chop, with a cooldown of six to ten bars since the last flip. A separate strong-move path can bypass the candidate persistence requirement and the cooldown when all three Supertrends agree unanimously, the score exceeds the gate by an additional margin, momentum is strong and efficiency is above 0.42. It does not bypass the underlying Supertrend persistence requirement. Finally, a takeover rule requires the fast Supertrend plus at least one slower one to agree with the new direction, so a flip cannot occur against the shorter-term Supertrend structure.

The valuation meter and the internal simulation exist to provide context on the same chart rather than requiring separate indicators: one shows where smoothed RSI currently sits on a segmented scale, the other reports how the script's own state changes would have resolved under a simple trailing-stop assumption.

[b][i]Features[/i][/b]
[list]
[*]Single trend state driving all visuals, bullish or bearish once the first flip occurs, neutral before that point
[*]Composite regime score built from nine weighted fields, blended and smoothed with a 3-period EMA
[*]Weighting: baseline distance 0.22, Supertrend consensus 0.20, momentum 0.19, baseline slope 0.14, slow baseline slope 0.10, directional efficiency 0.09, RSI 0.08, candle pressure 0.05, structure break 0.05
[*]Directional efficiency engine measuring net movement against total path over 10 bars, producing a chop value used throughout the script
[*]Volatility regime measurement comparing current ATR to its 50-period EMA, producing expansion and deviation values
[*]Three internally calculated Supertrends (fast, medium, slow) used for logic only and not plotted on the chart
[*]Adaptive Supertrend factors, where chop and volatility expansion are added on top of each user-set base multiplier, with the slow Supertrend receiving the largest adjustment
[*]Vote-based Supertrend consensus requiring two of three in normal conditions and three of three when chop exceeds 0.70
[*]Supertrend persistence requirement of one confirmed bar normally and two when chop exceeds 0.72
[*]Dynamic hysteresis gate that widens with the selectivity input, with chop, and with volatility deviation
[*]Price displacement filter requiring close to be above or below the baseline by an ATR-scaled amount
[*]Momentum sign filter requiring directional momentum beyond a small deadband
[*]Adaptive confirmation requiring one, two or three consecutive candidate bars depending on measured chop
[*]Strong-move path that can bypass the candidate confirmation requirement and the cooldown when all three Supertrends agree, the score clears the gate by an additional 0.26, momentum exceeds 0.16 and efficiency exceeds 0.42, while still requiring Supertrend persistence
[*]Takeover rule requiring the fast Supertrend plus one slower Supertrend to align with the new direction before any flip
[*]Adaptive cooldown of six to ten bars between state changes, scaled by chop
[*]All state changes evaluated on confirmed bars only, so the state does not flip on an unclosed bar
[*]Trail overlay mode with three layers constructed at 0.55, 1.15 and 1.60 ATR multiples from the smoothed baseline, placed below it in bullish states and above it in bearish states, scaled by the width input
[*]Bands overlay mode with three levels on each side of the baseline at 1.30, 2.00 and 2.90 ATR multiples, scaled by the width input, using an additional smoothing stage applied to the already-smoothed baseline and ATR
[*]Overlay None mode that hides the Trail and Bands while leaving the other independently controlled outputs available
[*]Smoothness control applied to the baseline and ATR used for the overlay geometry
[*]Trend candles that recolor the price bars to the active state
[*]Reversal labels printed on the bar where the state changes, placed relative to the outer trail layer
[*]Valuation meter drawn as a table with a segmented scale and a pointer showing where 3-period smoothed RSI(14) currently sits
[*]Four meter sizes: Off, Compact (11 segments), Normal (17 segments) and Large (25 segments)
[*]Six meter positions covering top and bottom, left, center and right
[*]Internal historical trade simulation driven by the script's own state changes, reported in the Data Window
[*]Simulation outputs: return percent, win rate percent, profit factor, maximum drawdown percent and closed trade count
[*]Simulation uses a fixed 10000 starting equity and full-equity sizing, with a fee equal to 0.1 percent of entry equity deducted at entry and a further amount equal to 0.1 percent of that same entry equity applied at exit
[*]Simulation stop is set from the outer trail on the entry bar, constrained to at least one minimum tick beyond the entry close, and thereafter can only move in the position's favorable direction using the previous bar's outer trail value
[*]Simulation return figure includes unrealized profit or loss on any position still open, so it is not a closed-trade-only figure
[*]Two alert conditions, one for the bullish flip and one for the bearish flip, each carrying the ticker in the message
[/list]

[b][i]Inputs[/i][/b]
[i]Group 01, Trend Engine
[/i]
Trend Length, default 34, range 10 to 200. Sets the primary EMA baseline used for the overlay, the distance field and the baseline slope field. It also determines two internally derived lengths: the slower HL2 baseline is calculated at approximately 70 percent of this value with a floor of 10, and the structure-break lookback is approximately 12 percent of this value with a floor of 3.
Momentum Length, default 12, range 3 to 100. Lookback used to measure directional momentum before ATR normalization.

Signal Selectivity, default 0.35, range 0.10 to 1.25. Raises both the hysteresis gate and the required price displacement. Higher values produce fewer state changes.

[i]Group 02, Supertrend Confirmation[/i]
Fast Length, default 9, range 2 to 100. ATR length of the fast internal Supertrend.
Fast Factor, default 1.45, range 0.25 to 10.0. Base ATR multiplier of the fast internal Supertrend before adaptive widening.

Medium Length, default 14, range 2 to 150. ATR length of the medium internal Supertrend.
Medium Factor, default 1.95, range 0.25 to 10.0. Base ATR multiplier of the medium internal Supertrend.

Slow Length, default 21, range 2 to 200. ATR length of the slow internal Supertrend, acting as the broader continuation confirmation.

Slow Factor, default 2.55, range 0.25 to 10.0. Base ATR multiplier of the slow internal Supertrend.

[i]Group 03, Overlay[/i]
Overlay, default Trail, options Trail, Bands, None. Selects which overlay geometry is drawn, or hides both.

Width, default 1.00, range 0.40 to 2.50. Scales the distance of all trail layers and all band levels from the baseline. Because the internal simulation uses the outer trail layer as its stop, this input also changes the Data Window statistics. It does not affect the trend engine.

Smoothness, default 5, range 1 to 20. Smooths the baseline and ATR used to build the overlay geometry, and is applied a second time to those already-smoothed values when Bands mode is selected. Because the outer trail layer is built from these smoothed values, this input also changes the Data Window statistics. It does not affect the trend engine.

[i]Group 04, Valuation[/i]
Meter Size, default Normal, options Off, Compact, Normal, Large. Controls whether the meter is shown and how many segments it uses.

Position, default Top Center, options Top Left, Top Center, Top Right, Bottom Left, Bottom Center, Bottom Right.

[b][i]How It Works[/i][/b]
The baseline is an EMA of close over the Trend Length. ATR(14) is the volatility unit and is floored at one tick to avoid division problems on illiquid data.

Directional efficiency is the absolute 10-bar net price change divided by the sum of the absolute bar-to-bar changes over the same window, clamped between 0 and 1. Chop is one minus that value. Efficiency is signed by the 10-bar direction to form the efficiency field.

Volatility regime compares current ATR to its 50-period EMA. Expansion is the amount above one, clamped to 1.25. Deviation is the absolute distance from one, clamped to 1.50.

The three Supertrend factors are the user's base values plus a chop term and a volatility expansion term. Their directions become bullish or bearish votes. The vote requirement is two of three normally and three of three when chop exceeds 0.70, and the confirmed vote must persist for one confirmed bar, or two when chop exceeds 0.72.

Nine fields are then blended. Distance from baseline and momentum are divided by ATR and clamped. Baseline slope and slow baseline slope are three-bar changes divided by ATR and clamped. RSI(14) is centered on 50 and clamped. The Supertrend field is the vote difference divided by three. Candle pressure combines body direction and close location within the bar. Structure is plus one when close breaks the prior N-bar high and minus one when it breaks the prior N-bar low. The weighted sum is smoothed with a 3-period EMA to produce the regime value.

The gate is 0.22 plus selectivity times 0.12, plus chop times 0.085, plus a volatility deviation term capped at 0.06. A bullish candidate exists when the regime exceeds the gate, close is above the baseline by the required ATR displacement, momentum is positive beyond its deadband, and the bullish Supertrend consensus is persistent. The bearish candidate is the mirror.

A candidate must persist for one bar in high-efficiency conditions, two when chop exceeds 0.40, and three when chop exceeds 0.72. The strong-move path can bypass that candidate persistence requirement and the cooldown, but only when all three Supertrends agree, the regime clears the gate by an additional 0.26, momentum exceeds 0.16 in absolute terms and efficiency is above 0.42. Because the strong-move path is itself built on the candidate condition, it does not bypass the Supertrend persistence requirement. It is intended to provide a faster response when directional evidence is unusually strong under the script's own measurements.

Before any flip is accepted, the takeover rule requires the fast Supertrend and at least one of the medium or slow Supertrends to be aligned with the new direction. A cooldown of six bars plus up to four additional bars scaled by chop must also have elapsed since the last flip, unless the strong-move path is active. All of this is evaluated on confirmed bars only.

When the state flips, the counters reset, the label prints, the candles recolor and the overlay switches sides. Before the first flip on a chart the state is neutral, candles are yellow, and the trail layers sit flat on the baseline.

The valuation meter takes RSI(14), smooths it with a 3-period EMA, and maps it onto the selected number of segments with a pointer. It is a positioning display for smoothed RSI and nothing more; it does not measure fair value and is not part of the trend decision.

The Data Window values come from a simplified internal historical trade simulation implemented inside the indicator. The script is an indicator, not a TradingView strategy, so these are not Strategy Tester results and no Strategy Tester properties apply. The simulation opens a position at the close of each flip bar and closes it on either an opposite flip or a stop. The stop is set on the entry bar from the outer trail, constrained to at least one minimum tick beyond the entry close, and thereafter can only move in the position's favorable direction using the previous bar's outer trail value. Starting equity is 10000, the full equity is used on every position, a fee equal to 0.1 percent of entry equity is deducted at entry, and a further amount equal to 0.1 percent of that same entry equity is applied at exit. Win rate and profit factor are classified on the fee-inclusive result of each position. The return figure is calculated from equity including unrealized profit or loss on any position still open, so it is not a closed-trade-only figure.

These assumptions are deliberately simplified. The purpose is to compare the effect of different settings against one another on the same symbol, not to model a tradable account. Full-equity sizing is used so the figures are not dependent on an arbitrary position size choice, and no sizing shown here is being recommended. No slippage, spread, funding cost or gap-through-stop execution is modelled, so the simulation does not reproduce actual execution conditions and may differ materially from live trading. There is no take profit and positions are never partially closed. These values describe the script's own historical state changes under those assumptions and are not evidence about future behavior.

[b][i]How to Use[/i][/b]
Add the indicator to a clean chart and read the current state from the candle color and the overlay side. In Trail mode the layers are constructed below the smoothed baseline while the state is bullish and above it while the state is bearish. In Bands mode the three levels on each side show how far price has extended from the baseline in ATR terms.

Increase Signal Selectivity if you are getting more state changes than you want, or increase Trend Length for a slower baseline. Increase the Supertrend factors to require larger moves before the internal confirmation layer will agree. Reduce the factors and lengths for faster and noisier behavior on lower timeframes.

Width and Smoothness do not affect the trend engine, so flips and alerts are identical regardless of their values. Both do change the Data Window statistics, because the stop used by the internal simulation is drawn from the outer trail layer.

The two alerts fire on confirmed bars when the state changes. Treat the Data Window values as a rough comparison tool between settings on the loaded symbol and history, subject to the assumptions listed above.

Limitations to be aware of: because confirmation, persistence, takeover and cooldown conditions must all be satisfied before a state change is accepted, a flip can occur after price has already moved some distance from where the previous state ended. During lower-efficiency conditions the script requires additional Supertrend agreement and additional confirmation bars, which increases that distance further. These mechanisms intentionally prioritize confirmation over earliest possible detection, and that trade-off cannot be removed by settings, only shifted. Values on the current unclosed bar can change until that bar closes, since state changes are only committed on confirmed bars. The chart begins in a neutral state until the first flip is accepted. Behavior varies substantially between symbols and timeframes, and the defaults are a starting point rather than an optimized configuration.

[b][i]Conclusion[/i][/b]
Uptrick: Adaptive Trend Trail derives a trend state from nine weighted measurements rather than a single crossing, and makes the strictness of that decision a function of measured directional efficiency and volatility through the chop and volatility terms. The overlay, the trend candles, the valuation meter and the internal simulation are there to make that state and its context readable on one chart. It is a decision-support tool for discretionary trend reading and is intended to be used alongside your own analysis and risk management rather than as a standalone system.

[quote]Disclaimer
This indicator is provided for educational and informational purposes only. It is not financial advice and does not constitute a recommendation to buy or sell any instrument. All trading involves risk and can result in substantial losses. Leveraged products can involve additional risks that depend on the instrument, broker and account structure. Past behavior of this indicator, including any statistics it displays, does not predict or guarantee future results. Signals, statistics and visuals vary across symbols, timeframes and market conditions. You are solely responsible for your own trading decisions and should test any tool thoroughly and apply your own risk management before using it with real capital.[/quote]

## Source Code

````pine

// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick

//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝

indicator("Uptrick: Adaptive Trend Trail", shorttitle="Adaptive Trend Trail", overlay=true, max_labels_count=300, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01. TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gEngine = "01. Trend Engine"

trendLength = input.int(34, "Trend Length", minval=10, maxval=200, group=gEngine,
     tooltip="Controls the primary trend baseline. Higher values create slower and more stable trend states.")

momentumLength = input.int(12, "Momentum Length", minval=3, maxval=100, group=gEngine,
     tooltip="Lookback used to measure directional momentum.")

sensitivity = input.float(0.35, "Signal Selectivity", minval=0.10, maxval=1.25, step=0.05, group=gEngine,
     tooltip="Controls how much directional evidence is required before the trend can reverse. Higher values produce fewer signals.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02. SUPERTREND CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gST = "02. Supertrend Confirmation"

stFastLength = input.int(9, "Fast Length", minval=2, maxval=100, group=gST,
     tooltip="ATR length of the fast hidden Supertrend. Lower values react more quickly.")

stFastFactor = input.float(1.45, "Fast Factor", minval=0.25, maxval=10.0, step=0.05, group=gST,
     tooltip="Base ATR multiplier of the fast hidden Supertrend. Higher values require a larger move before its direction changes.")

stMidLength = input.int(14, "Medium Length", minval=2, maxval=150, group=gST,
     tooltip="ATR length of the medium hidden Supertrend.")

stMidFactor = input.float(1.95, "Medium Factor", minval=0.25, maxval=10.0, step=0.05, group=gST,
     tooltip="Base ATR multiplier of the medium hidden Supertrend.")

stSlowLength = input.int(21, "Slow Length", minval=2, maxval=200, group=gST,
     tooltip="ATR length of the slow hidden Supertrend. This acts as the broader continuation confirmation.")

stSlowFactor = input.float(2.55, "Slow Factor", minval=0.25, maxval=10.0, step=0.05, group=gST,
     tooltip="Base ATR multiplier of the slow hidden Supertrend. Higher values make broader trend confirmation more selective.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03. OVERLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gOverlay = "03. Overlay"

overlayMode = input.string("Trail", "Overlay", options=["Trail", "Bands", "None"], group=gOverlay,
     tooltip="Trail displays the complete trend ribbon with depth. Bands displays layered volatility zones. None hides the overlay.")

trailSize = input.float(1.00, "Width", minval=0.40, maxval=2.50, step=0.05, group=gOverlay,
     tooltip="Controls the overall distance and thickness of the selected overlay.")

smoothness = input.int(5, "Smoothness", minval=1, maxval=20, group=gOverlay,
     tooltip="Smooths the overlay geometry. Higher values create softer movement.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. VALUATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gMeter = "04. Valuation"

meterMode = input.string("Normal", "Meter Size", options=["Off", "Compact", "Normal", "Large"], group=gMeter,
     tooltip="Controls whether the Valuation meter is displayed and its overall size.")

meterPosition = input.string("Top Center", "Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=gMeter,
     tooltip="Sets the chart position of the Valuation meter.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullColor = #00FFE5
bearColor = #FF00B5
neutralColor = #FFD84D

black = #000000
white = #FFFFFF

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_position(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Top Center" ? position.top_center :
     _p == "Bottom Left" ? position.bottom_left :
     _p == "Bottom Center" ? position.bottom_center :
     _p == "Bottom Right" ? position.bottom_right :
     position.top_right

f_tradePnl(_side, _entry, _exit, _capital) =>
    float gross = _capital * _side * ((_exit - _entry) / _entry)
    float fee = _capital * 0.001
    gross - fee

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE MARKET STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

basis = ta.ema(close, trendLength)

atr = ta.atr(14)
safeATR = math.max(atr, syminfo.mintick)

momentum = ta.ema(close - close[momentumLength], 5) / safeATR
distance = (close - basis) / safeATR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIRECTIONAL EFFICIENCY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

effLength = 10

netMovement = math.abs(close - close[effLength])
travelPath = math.sum(math.abs(close - close[1]), effLength)

efficiency = travelPath > 0.0 ? f_clamp(netMovement / travelPath, 0.0, 1.0) : 0.0
chop = 1.0 - efficiency

effDirection = close > close[effLength] ? 1.0 :
     close < close[effLength] ? -1.0 : 0.0

efficiencyField = efficiency * effDirection

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLATILITY REGIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

normalATR = ta.ema(safeATR, 50)
volRatio = normalATR > 0.0 ? safeATR / normalATR : 1.0

volExpansion = f_clamp(volRatio - 1.0, 0.0, 1.25)
volDeviation = f_clamp(math.abs(volRatio - 1.0), 0.0, 1.50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE SUPERTREND MATRIX
//
// User inputs define each Supertrend's base parameters.
// Chop and volatility then add a small dynamic distance adjustment.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastAdaptiveFactor = stFastFactor + chop * 0.25 + volExpansion * 0.10
midAdaptiveFactor = stMidFactor + chop * 0.35 + volExpansion * 0.15
slowAdaptiveFactor = stSlowFactor + chop * 0.45 + volExpansion * 0.20

[stFast, stFastDirection] = ta.supertrend(fastAdaptiveFactor, stFastLength)
[stMid, stMidDirection] = ta.supertrend(midAdaptiveFactor, stMidLength)
[stSlow, stSlowDirection] = ta.supertrend(slowAdaptiveFactor, stSlowLength)

stFastBull = stFastDirection < 0
stFastBear = stFastDirection > 0

stMidBull = stMidDirection < 0
stMidBear = stMidDirection > 0

stSlowBull = stSlowDirection < 0
stSlowBear = stSlowDirection > 0

bullSTVotes = (stFastBull ? 1 : 0) + (stMidBull ? 1 : 0) + (stSlowBull ? 1 : 0)
bearSTVotes = (stFastBear ? 1 : 0) + (stMidBear ? 1 : 0) + (stSlowBear ? 1 : 0)

// Clean/normal markets = 2/3.
// Very choppy markets = 3/3.
requiredSTVotes = chop > 0.70 ? 3 : 2

bullSTConfirmed = bullSTVotes >= requiredSTVotes
bearSTConfirmed = bearSTVotes >= requiredSTVotes

fullBullST = bullSTVotes == 3
fullBearST = bearSTVotes == 3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND PERSISTENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int bullSTBars = 0
var int bearSTBars = 0

if barstate.isconfirmed
    bullSTBars := bullSTConfirmed ? math.min(bullSTBars + 1, 5) : 0
    bearSTBars := bearSTConfirmed ? math.min(bearSTBars + 1, 5) : 0

stPersistenceRequired = chop > 0.72 ? 2 : 1

bullSTPersistent = bullSTBars >= stPersistenceRequired
bearSTPersistent = bearSTBars >= stPersistenceRequired

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE REGIME COMPONENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

distanceField = f_clamp(distance / 1.20, -1.0, 1.0)
momentumField = f_clamp(momentum / 0.35, -1.0, 1.0)

basisSlope = (basis - basis[3]) / safeATR
slopeField = f_clamp(basisSlope / 0.25, -1.0, 1.0)

rsi = ta.rsi(close, 14)
rsiField = f_clamp((rsi - 50.0) / 20.0, -1.0, 1.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND CONSENSUS FIELD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

stField = (bullSTVotes - bearSTVotes) / 3.0

slowCenter = ta.ema(hl2, math.max(10, int(math.round(trendLength * 0.70))))

slowSlope = (slowCenter - slowCenter[3]) / safeATR
slowSlopeField = f_clamp(slowSlope / 0.25, -1.0, 1.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE BONUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

structureLength = math.max(3, int(math.round(trendLength * 0.12)))

recentHigh = ta.highest(high[1], structureLength)
recentLow = ta.lowest(low[1], structureLength)

bullStructure = close > recentHigh
bearStructure = close < recentLow

structureField = bullStructure ? 1.0 :
     bearStructure ? -1.0 : 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE PRESSURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barRange = math.max(high - low, syminfo.mintick)

bodyPressure = (close - open) / barRange
closeLocation = ((close - low) / barRange - 0.50) * 2.0

pressureField = f_clamp(bodyPressure * 0.60 + closeLocation * 0.40, -1.0, 1.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPOSITE REGIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawRegime =
     distanceField * 0.22 +
     momentumField * 0.19 +
     slopeField * 0.14 +
     slowSlopeField * 0.10 +
     rsiField * 0.08 +
     efficiencyField * 0.09 +
     pressureField * 0.05 +
     structureField * 0.05 +
     stField * 0.20

regime = ta.ema(rawRegime, 3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC HYSTERESIS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

chopPenalty = chop * 0.085
volPenalty = f_clamp(volDeviation * 0.04, 0.0, 0.06)

dynamicGate = 0.22 + sensitivity * 0.12 + chopPenalty + volPenalty

bullZone = regime > dynamicGate
bearZone = regime < -dynamicGate

bullPriceOK = close > basis + safeATR * sensitivity * 0.30
bearPriceOK = close < basis - safeATR * sensitivity * 0.30

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL CANDIDATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullCandidate = bullZone and bullPriceOK and momentum > 0.025 and bullSTPersistent
bearCandidate = bearZone and bearPriceOK and momentum < -0.025 and bearSTPersistent

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

requiredBars = chop > 0.72 ? 3 :
     chop > 0.40 ? 2 : 1

var int bullConfirm = 0
var int bearConfirm = 0

if barstate.isconfirmed
    bullConfirm := bullCandidate ? math.min(bullConfirm + 1, 4) : 0
    bearConfirm := bearCandidate ? math.min(bearConfirm + 1, 4) : 0

bullPersistent = bullConfirm >= requiredBars
bearPersistent = bearConfirm >= requiredBars

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRONG MOVE FAST PASS
//
// Still requires unanimous 3/3 Supertrend confirmation.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

strongBull =
     bullCandidate and
     fullBullST and
     regime > dynamicGate + 0.26 and
     momentum > 0.16 and
     efficiency > 0.42

strongBear =
     bearCandidate and
     fullBearST and
     regime < -(dynamicGate + 0.26) and
     momentum < -0.16 and
     efficiency > 0.42

bullReady = bullPersistent or strongBull
bearReady = bearPersistent or strongBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND TAKEOVER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTakeover = stFastBull and (stMidBull or stSlowBull)
bearTakeover = stFastBear and (stMidBear or stSlowBear)

bullReady := bullReady and bullTakeover
bearReady := bearReady and bearTakeover

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE COOLDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cooldownBars = 6 + int(math.round(chop * 4.0))

var int trend = 0
var int lastFlipBar = na

barsSinceFlip = na(lastFlipBar) ? 100000 : bar_index - lastFlipBar
cooldownDone = barsSinceFlip >= cooldownBars

if barstate.isconfirmed
    if trend != 1 and bullReady and (cooldownDone or strongBull)
        trend := 1
        lastFlipBar := bar_index

        bullConfirm := 0
        bearConfirm := 0
        bullSTBars := 0
        bearSTBars := 0

    else if trend != -1 and bearReady and (cooldownDone or strongBear)
        trend := -1
        lastFlipBar := bar_index

        bullConfirm := 0
        bearConfirm := 0
        bullSTBars := 0
        bearSTBars := 0

bullish = trend == 1
bearish = trend == -1

upSignal = barstate.isconfirmed and trend == 1 and trend[1] != 1
downSignal = barstate.isconfirmed and trend == -1 and trend[1] != -1

trendColor = bullish ? bullColor :
     bearish ? bearColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMOOTH OVERLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

smoothBasis = smoothness > 1 ? ta.ema(basis, smoothness) : basis
smoothATR = smoothness > 1 ? ta.ema(safeATR, smoothness) : safeATR

innerDistance = 0.55 * trailSize
outerDistance = 1.15 * trailSize
depthDistance = 1.60 * trailSize

innerTrail = bullish ? smoothBasis - smoothATR * innerDistance :
     bearish ? smoothBasis + smoothATR * innerDistance :
     smoothBasis

outerTrail = bullish ? smoothBasis - smoothATR * outerDistance :
     bearish ? smoothBasis + smoothATR * outerDistance :
     smoothBasis

depthTrail = bullish ? smoothBasis - smoothATR * depthDistance :
     bearish ? smoothBasis + smoothATR * depthDistance :
     smoothBasis

showTrail = overlayMode == "Trail"
showBands = overlayMode == "Bands"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRAIL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pTrailInner = plot(showTrail ? innerTrail : na, "Trail Inner", color=color.new(trendColor, 100))
pTrailOuter = plot(showTrail ? outerTrail : na, "Trail Outer", color=color.new(trendColor, 100))
pTrailDepth = plot(showTrail ? depthTrail : na, "Trail Depth", color=color.new(trendColor, 100))

fill(pTrailInner, pTrailOuter, color=color.new(trendColor, 68), title="Adaptive Trend Trail")
fill(pTrailOuter, pTrailDepth, color=color.new(trendColor, 87), title="Trail Depth")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bandBasis = ta.ema(smoothBasis, smoothness)
bandATR = ta.ema(smoothATR, smoothness)

upper1 = bandBasis + bandATR * 1.30 * trailSize
upper2 = bandBasis + bandATR * 2.00 * trailSize
upper3 = bandBasis + bandATR * 2.90 * trailSize

lower1 = bandBasis - bandATR * 1.30 * trailSize
lower2 = bandBasis - bandATR * 2.00 * trailSize
lower3 = bandBasis - bandATR * 2.90 * trailSize

pU1 = plot(showBands ? upper1 : na, "Upper Band 1", color=color.new(bearColor, 100))
pU2 = plot(showBands ? upper2 : na, "Upper Band 2", color=color.new(bearColor, 100))
pU3 = plot(showBands ? upper3 : na, "Upper Band 3", color=color.new(bearColor, 100))

pL1 = plot(showBands ? lower1 : na, "Lower Band 1", color=color.new(bullColor, 100))
pL2 = plot(showBands ? lower2 : na, "Lower Band 2", color=color.new(bullColor, 100))
pL3 = plot(showBands ? lower3 : na, "Lower Band 3", color=color.new(bullColor, 100))

fill(pU1, pU2, color=color.new(bearColor, 91), title="Upper Inner Band")
fill(pU2, pU3, color=color.new(bearColor, 72), title="Upper Outer Band")

fill(pL1, pL2, color=color.new(bullColor, 91), title="Lower Inner Band")
fill(pL2, pL3, color=color.new(bullColor, 72), title="Lower Outer Band")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

signalPadding = smoothATR * 1.05

if upSignal
    label.new(bar_index, outerTrail - signalPadding, "𝓤𝓹",
         style=label.style_label_up,
         color=bullColor,
         textcolor=black,
         size=size.normal)

if downSignal
    label.new(bar_index, outerTrail + signalPadding, "𝓓𝓸𝔀𝓷",
         style=label.style_label_down,
         color=bearColor,
         textcolor=white,
         size=size.normal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND CANDLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotcandle(open, high, low, close, "Trend Candles",
     color=trendColor,
     wickcolor=trendColor,
     bordercolor=trendColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALUATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

valuation = f_clamp(ta.ema(ta.rsi(close, 14), 3), 0.0, 100.0)

showMeter = meterMode != "Off"

meterSegments = meterMode == "Compact" ? 11 :
     meterMode == "Large" ? 25 :
     17

meterColumns = meterSegments + 2
centerColumn = int(math.floor((meterColumns - 1) / 2))

meterTextSize = meterMode == "Large" ? size.normal :
     meterMode == "Compact" ? size.tiny :
     size.small

pointerSize = meterMode == "Large" ? size.large :
     meterMode == "Compact" ? size.small :
     size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALUATION METER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table valuationMeter = table.new(
     f_position(meterPosition),
     meterColumns,
     3,
     bgcolor=black,
     frame_color=white,
     frame_width=1,
     border_color=black,
     border_width=0
)

if showMeter and barstate.islast
    table.clear(valuationMeter, 0, 0, meterColumns - 1, 2)

    int pointerIndex = int(math.round(valuation / 100.0 * (meterSegments - 1)))

    for i = 0 to meterColumns - 1
        table.cell(valuationMeter, i, 0, "", bgcolor=black)

    table.cell(valuationMeter, centerColumn, 0, "𝓥𝓪𝓵𝓾𝓪𝓽𝓲𝓸𝓷",
         text_color=white,
         bgcolor=black,
         text_size=meterTextSize,
         text_halign=text.align_center)

    for i = 0 to meterSegments - 1
        bool pointer = i == pointerIndex
        string dot = i == 0 or i == meterSegments - 1 ? "●" : "·"

        table.cell(valuationMeter, i + 1, 1, dot,
             text_color=color.new(white, 30),
             bgcolor=black,
             text_size=meterTextSize,
             text_halign=text.align_center)

        table.cell(valuationMeter, i + 1, 2, pointer ? "▲" : "",
             text_color=white,
             bgcolor=black,
             text_size=pointerSize,
             text_halign=text.align_center)

        table.cell_set_text_font_family(valuationMeter, i + 1, 1, font.family_monospace)
        table.cell_set_text_font_family(valuationMeter, i + 1, 2, font.family_monospace)

if not showMeter and barstate.islast
    table.clear(valuationMeter, 0, 0, meterColumns - 1, 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INTERNAL INDICATOR BACKTEST
// NO STRATEGY / TP / CROSSES / VISUAL EXITS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float equity = 10000.0
var float equityPeak = 10000.0
var float maxDrawdown = 0.0

var int side = 0
var int entryBar = na

var float entryPrice = na
var float entryEquity = na
var float stopPrice = na
var float tradePnL = 0.0

var int closedTrades = 0
var int winningTrades = 0

var float grossProfit = 0.0
var float grossLoss = 0.0

if side != 0 and bar_index > entryBar
    float candidateStop = outerTrail[1]

    if side == 1 and not na(candidateStop)
        stopPrice := math.max(stopPrice, candidateStop)

    if side == -1 and not na(candidateStop)
        stopPrice := math.min(stopPrice, candidateStop)

if side != 0 and bar_index > entryBar
    bool stopHit = side == 1 ? low <= stopPrice : high >= stopPrice
    bool reversal = side == 1 ? downSignal : upSignal
    float exitPrice = stopHit ? stopPrice : reversal ? close : na

    if not na(exitPrice)
        float result = f_tradePnl(side, entryPrice, exitPrice, entryEquity)

        equity += result
        tradePnL += result
        closedTrades += 1

        if tradePnL > 0.0
            winningTrades += 1
            grossProfit += tradePnL
        else if tradePnL < 0.0
            grossLoss += tradePnL

        side := 0
        entryBar := na
        entryPrice := na
        entryEquity := na
        stopPrice := na
        tradePnL := 0.0

if side == 0 and upSignal
    side := 1
    entryBar := bar_index
    entryPrice := close
    entryEquity := equity
    stopPrice := math.min(outerTrail, close - syminfo.mintick)

    float fee = entryEquity * 0.001
    equity -= fee
    tradePnL := -fee

else if side == 0 and downSignal
    side := -1
    entryBar := bar_index
    entryPrice := close
    entryEquity := equity
    stopPrice := math.max(outerTrail, close + syminfo.mintick)

    float fee = entryEquity * 0.001
    equity -= fee
    tradePnL := -fee

float unrealized = 0.0

if side != 0 and not na(entryPrice)
    unrealized := entryEquity * side * ((close - entryPrice) / entryPrice)

liveEquity = equity + unrealized

equityPeak := math.max(equityPeak, liveEquity)

float currentDD = equityPeak > 0.0 ? (equityPeak - liveEquity) / equityPeak : 0.0
maxDrawdown := math.max(maxDrawdown, currentDD)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

backtestReturn = (liveEquity / 10000.0 - 1.0) * 100.0
winRate = closedTrades > 0 ? winningTrades / closedTrades * 100.0 : na
profitFactor = grossLoss < 0.0 ? grossProfit / math.abs(grossLoss) : na

plot(backtestReturn, "Internal Return %", display=display.data_window)
plot(winRate, "Internal Win Rate %", display=display.data_window)
plot(profitFactor, "Internal Profit Factor", display=display.data_window)
plot(maxDrawdown * 100.0, "Internal Max Drawdown %", display=display.data_window)
plot(closedTrades, "Internal Closed Trades", display=display.data_window)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(upSignal, "Adaptive Trend Up", "Adaptive Trend Trail turned bullish on {{ticker}}")
alertcondition(downSignal, "Adaptive Trend Down", "Adaptive Trend Trail turned bearish on {{ticker}}")
````
