# Tick Velocity [DYNA]

- url: https://www.tradingview.com/script/ZzlODNYc-Tick-Velocity-DYNA/
- type: indicator
- pine_id: PUB;09173175ef114d1981ea50955c8f4631
- version: 1.0

## Description

Tick Velocity measures the speed of price movement on every bar, normalized by ATR and log-compressed so the reading works consistently across any instrument and any timeframe. Instead of asking "did price go up or down?" it asks "how fast did price move?" -- and that distinction makes all the difference when you need to spot momentum bursts and exhaustion in real time.

Most momentum tools tell you the direction of a move but not its intensity relative to normal conditions. A 50-point move on a major index means something very different during a quiet afternoon versus an opening-bell surge. Tick Velocity strips away that ambiguity by expressing every bar's price change as a multiple of recent volatility with log compression, giving you a clean, comparable speed reading that doesn't get crushed by outlier spikes.


[b]Key Features[/b]

[list]
[*] [b]ATR-Normalized Velocity[/b] -- price change divided by ATR, so readings are comparable across instruments and timeframes without manual adjustment
[*] [b]Log-Compressed Scale[/b] -- extreme spikes are tamed so the histogram uses its full visual range, making normal-range momentum readable even after outlier moves
[*] [b]Signal Line[/b] -- a smoothed EMA overlay shows sustained momentum direction, filtering out bar-to-bar noise
[*] [b]Dynamic Spike Detection[/b] -- automatically identifies bars where velocity exceeds a configurable multiple of its recent average, with separate bullish and bearish alerts
[*] [b]Smart Exhaustion Detection[/b] -- flags fading momentum only after periods of genuine activity, so you don't get false exhaustion signals during quiet consolidation
[*] [b]Confirmed-Bar Logic[/b] -- all signals are evaluated on the completed bar, so what you see on the chart stays on the chart with no repainting
[*] [b]Clean Visual Design[/b] -- color-coded histogram with dynamic threshold lines and signal line makes it easy to read momentum state at a glance
[/list]


[b]How It Works[/b]

When you add Tick Velocity to your chart, a histogram appears in a separate pane below price. Each bar in the histogram represents the speed of that candle's price change: green bars mean price moved up, red bars mean price moved down, and the height of each bar shows how fast the move was. Log compression keeps the scale readable -- a massive gap-up spike won't flatten everything else into an invisible line.

An orange signal line (EMA) overlays the histogram, smoothing out bar-to-bar noise to show you the sustained momentum direction. When the signal line holds above zero, bulls are in control; when it dips below, bears are driving.

Two sets of threshold lines frame the histogram. The outer yellow lines mark the spike threshold -- when a bar pushes beyond these lines, price moved significantly faster than normal, indicating a momentum burst. The inner purple lines mark the exhaustion threshold -- when bars shrink inside these lines after a period of elevated activity, momentum is fading and the market may be pausing or preparing to reverse. The smart exhaustion gate ensures purple zones only appear after real momentum -- not during quiet consolidation.

Background shading reinforces these conditions. A yellow tint appears on confirmed spike bars, and a purple tint appears on confirmed exhaustion bars, making it easy to scan through the chart and see where momentum surged or faded.

[image]https://www.tradingview.com/x/DG3eyMpg/[/image]
[i]Tick Velocity histogram showing bullish and bearish velocity bars, with spike threshold lines (yellow) and exhaustion bands (purple). Background highlights mark confirmed spike and exhaustion events.[/i]


[b]Settings[/b]

The core settings control sensitivity. The Velocity Lookback (default 10) determines how many bars are used to calculate the average velocity -- lower values make the indicator more responsive for scalping, higher values smooth it out for swing trading. The ATR Period (default 14) controls the normalization window. The Signal Smoothing (default 5) sets the EMA period for the orange signal line.

The Spike Multiplier (default 2.0) sets how far above average a bar must travel to count as a spike. Raise it to 2.5 or 3.0 if you only want the strongest bursts. The Exhaustion Multiplier (default 0.5) sets how far below average velocity must drop to flag exhaustion. The Exhaustion Gate Multiplier (default 1.5) ensures exhaustion only triggers when recent activity exceeds the longer-term baseline by this factor -- preventing false signals during quiet consolidation. Threshold lines, background highlights, and the signal line can each be toggled independently under Visual settings.


[b]Alerts[/b]

[list]
[*] [b]Bullish Velocity Spike[/b] -- fires when upward velocity exceeds the spike threshold on a confirmed bar. Message: [i]"Bullish velocity spike -- strong upward momentum burst."[/i]
[*] [b]Bearish Velocity Spike[/b] -- fires when downward velocity exceeds the spike threshold on a confirmed bar. Message: [i]"Bearish velocity spike -- strong downward momentum burst."[/i]
[*] [b]Velocity Exhaustion[/b] -- fires when velocity drops below the exhaustion threshold after a period of elevated activity. Message: [i]"Tick Velocity exhaustion detected -- momentum fading after active period, possible pause or reversal."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Tick Velocity [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Use velocity spikes at key support and resistance levels to confirm breakouts -- a spike adds conviction that the level break is real
[*] Watch for exhaustion signals after extended trends to time profit-taking or tighten stop-loss placement
[*] Combine with volume indicators for added confirmation -- a velocity spike on high volume is more meaningful than one on thin volume
[*] Adjust the lookback period to match your trading style: 5-7 for scalping, 10-15 for intraday, 20+ for swing trading
[*] On lower timeframes (1-3 minute), consider raising the spike multiplier to reduce noise from normal market fluctuations
[/list]


[b]Part of the DYNA Ecosystem[/b]

Tick Velocity is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Tick Velocity [DYNA]
// Measures the speed of price movement to identify momentum surges and exhaustion.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Tick Velocity [DYNA]", overlay = false, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800
color SPIKE_COLOR   = #ffeb3b   // Yellow highlight for velocity spikes
color EXHAUST_COLOR = #9c27b0   // Purple for exhaustion zones

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
string GRP_CORE = "Core Settings"
int    i_velocityLookback   = input.int(10, "Velocity Lookback", minval = 2, maxval = 100, group = GRP_CORE, tooltip = "Number of bars used to calculate the average velocity. Lower values = more sensitive.")
int    i_atrPeriod          = input.int(14, "ATR Period", minval = 1, maxval = 200, group = GRP_CORE, tooltip = "Period for ATR normalization. Adjusts velocity for the instrument's volatility.")
float  i_spikeMultiplier    = input.float(2.0, "Spike Multiplier", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "Velocity above this multiple of average = momentum spike.")
float  i_exhaustionMultiplier = input.float(0.5, "Exhaustion Multiplier", minval = 0.01, maxval = 1.0, step = 0.05, group = GRP_CORE, tooltip = "Velocity below this multiple of average = exhaustion.")
int    i_signalLength       = input.int(5, "Signal Smoothing", minval = 2, maxval = 20, group = GRP_CORE, tooltip = "EMA period for the signal line overlay. Smooths velocity to show sustained momentum.")
float  i_exhaustionGateMult = input.float(1.5, "Exhaustion Gate Multiplier", minval = 1.0, maxval = 5.0, step = 0.1, group = GRP_CORE, tooltip = "Exhaustion only triggers when recent avg velocity exceeds this multiple of the longer-term baseline. Prevents false exhaustion during quiet consolidation.")

// --- Visual ---
string GRP_VIS = "Visual"
bool   i_showThresholds = input.bool(true, "Show Threshold Lines", group = GRP_VIS, tooltip = "Display dynamic spike and exhaustion threshold lines.")
bool   i_showBackground = input.bool(true, "Highlight Spike / Exhaustion Bars", group = GRP_VIS, tooltip = "Shade the background on spike and exhaustion bars.")
bool   i_showSignalLine = input.bool(true, "Show Signal Line", group = GRP_VIS, tooltip = "Display the smoothed velocity EMA line.")

// --- Alerts ---
string GRP_ALERT = "Alerts"
bool   i_alertSpike      = input.bool(true, "Alert on Velocity Spike", group = GRP_ALERT)
bool   i_alertExhaustion = input.bool(true, "Alert on Exhaustion", group = GRP_ALERT)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- ATR-normalized velocity ---
float atrValue    = ta.atr(i_atrPeriod)
float safeAtr     = math.max(atrValue, syminfo.mintick)
float rawVelocity = (close - close[1]) / safeAtr

// --- Log compression: preserves direction & proportionality, caps visual range ---
float velocity = math.sign(rawVelocity) * math.log(1 + math.abs(rawVelocity))

// --- Average absolute velocity (for dynamic thresholds) ---
float absVelocity    = math.abs(velocity)
float avgVelocity    = ta.sma(absVelocity, i_velocityLookback)
float safeAvg        = math.max(avgVelocity, syminfo.mintick)
float baselineAvg    = ta.sma(absVelocity, i_velocityLookback * 5)  // longer-term baseline

// --- Signal line (smoothed velocity) ---
float signalLine = ta.ema(velocity, i_signalLength)

// --- Dynamic thresholds (use [1] offset for confirmed-bar alignment) ---
float prevAvg             = nz(avgVelocity[1], safeAvg)
float spikeThreshold      = i_spikeMultiplier * prevAvg
float exhaustionThreshold = i_exhaustionMultiplier * prevAvg

// --- Condition detection (confirmed-bar: reference [1]) ---
bool isBullSpike   = velocity[1] > spikeThreshold
bool isBearSpike   = velocity[1] < -spikeThreshold
bool isSpike       = isBullSpike or isBearSpike
bool isExhaustion  = math.abs(velocity[1]) < exhaustionThreshold and prevAvg > i_exhaustionGateMult * nz(baselineAvg[1], safeAvg)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Histogram color ---
color histColor = velocity > 0 ? BULL_COLOR : velocity < 0 ? BEAR_COLOR : NEUTRAL_COLOR

// --- Velocity histogram ---
plot(velocity, "Tick Velocity", color = histColor, style = plot.style_histogram, linewidth = 3)

// --- Signal line ---
plot(i_showSignalLine ? signalLine : na, "Signal Line", color = color.new(WARNING_COLOR, 20), linewidth = 2)

// --- Zero line ---
hline(0, "Zero Line", color = NEUTRAL_COLOR, linestyle = hline.style_dotted)

// --- Dynamic threshold lines (aligned with detection logic using [1] offset) ---
plot(i_showThresholds ? spikeThreshold : na, "Spike Threshold (+)", color = color.new(SPIKE_COLOR, 50), linewidth = 1, style = plot.style_line)
plot(i_showThresholds ? -spikeThreshold : na, "Spike Threshold (-)", color = color.new(SPIKE_COLOR, 50), linewidth = 1, style = plot.style_line)
plot(i_showThresholds ? exhaustionThreshold : na, "Exhaustion Threshold (+)", color = color.new(EXHAUST_COLOR, 60), linewidth = 1, style = plot.style_line)
plot(i_showThresholds ? -exhaustionThreshold : na, "Exhaustion Threshold (-)", color = color.new(EXHAUST_COLOR, 60), linewidth = 1, style = plot.style_line)

// --- Background highlights ---
bgcolor(i_showBackground and isSpike ? color.new(SPIKE_COLOR, 85) : na, title = "Spike Background")
bgcolor(i_showBackground and isExhaustion ? color.new(EXHAUST_COLOR, 90) : na, title = "Exhaustion Background")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(i_alertSpike and isBullSpike, title = "Bullish Velocity Spike", message = "Tick Velocity [DYNA]: Bullish velocity spike -- strong upward momentum burst.")
alertcondition(i_alertSpike and isBearSpike, title = "Bearish Velocity Spike", message = "Tick Velocity [DYNA]: Bearish velocity spike -- strong downward momentum burst.")
alertcondition(i_alertExhaustion and isExhaustion, title = "Velocity Exhaustion", message = "Tick Velocity [DYNA]: Exhaustion detected -- momentum fading after active period, possible pause or reversal.")
````
