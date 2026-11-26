# Infinity Flow Oscillator

- url: https://www.tradingview.com/script/0BgVHvDc-Infinity-Flow-Oscillator/
- type: indicator
- pine_id: PUB;791c9c3a12194cf5bf8a39f679277d52
- version: 1.0

## Description

Infinity Flow Oscillator — Rmi / Mfo Wave Energy & Range Compression

Flow is a momentum and pressure oscillator designed to help traders read directional flow, internal market pressure, wave movement and compression conditions in one clean lower-panel tool.

The oscillator combines several components into a single visual flow reading:

• RMI Flow
• MFI Pressure
• WaveTrend Energy
• Range Compression / Expansion
• Flow Score from -100 to +100
• Bullish and bearish confirmation dots
• Strong and extreme momentum zones
• Layered fills and cloud-style visual structure

The goal of this oscillator is to make momentum easier to read visually. It is not designed to predict price movement or replace a full trading plan. It should be used as a confirmation and context tool together with price action, market structure, support and resistance, volume conditions and risk management.

────────────────────────────
MAIN CONCEPT
────────────────────────────

The oscillator reads the market through a normalized flow scale.

The center line represents balance.

Above zero:
Bullish pressure is dominant.

Below zero:
Bearish pressure is dominant.

Near zero:
Market flow is neutral, mixed or indecisive.

The stronger the oscillator moves away from zero, the stronger the directional pressure becomes.

The tool uses layered fills and color transitions to make the state of the market visible at a glance.

Bullish flow is displayed with cyan / green-style visual pressure.
Bearish flow is displayed with pink / red-style visual pressure.
Compression or range conditions can be highlighted with a softer background layer.

────────────────────────────
WHAT THE OSCILLATOR SHOWS
────────────────────────────

1. Flow Line

The main flow line represents the final combined oscillator value. It blends momentum, money flow, wave movement and compression logic into one reading.

When the flow line rises above zero, bullish pressure is increasing.
When the flow line falls below zero, bearish pressure is increasing.

2. Signal Line

The signal line smooths the main flow reading.

When the flow line crosses above the signal line, bullish momentum may be improving.
When the flow line crosses below the signal line, bearish momentum may be improving.

3. Bullish and Bearish Dots

Bullish dots appear when the flow line crosses above the signal line under valid conditions.
Bearish dots appear when the flow line crosses below the signal line under valid conditions.

These dots are designed as visual confirmation markers, not automatic trade entries.

4. Strong Momentum Zones

The strong levels mark areas where momentum becomes more directional.

Above the positive strong level:
Bullish pressure is considered stronger.

Below the negative strong level:
Bearish pressure is considered stronger.

5. Extreme Zones

The extreme levels show areas where the market may be stretched.

A strong move into the upper extreme zone can show aggressive bullish pressure.
A strong move into the lower extreme zone can show aggressive bearish pressure.

Extreme readings do not automatically mean reversal. In strong trends, extreme conditions can continue longer than expected.

6. Compression / Range Background

The oscillator can highlight compression or range-like conditions.

Compression often means the market is building energy.
Expansion can happen after compression, especially when price breaks structure or a range.

This layer is useful for understanding when the market is quiet, compressed or preparing for a stronger directional move.

────────────────────────────
INPUT GUIDE
────────────────────────────

Show Oscillator

Enables or disables the main oscillator visual.

When enabled, the flow line, signal line, fills and zones are visible.
When disabled, the oscillator can be hidden without removing the script from the chart.

Show Dots

Enables or disables bullish and bearish confirmation dots.

Use this if you want a cleaner oscillator without signal markers.

Flow Length

Controls the sensitivity of the main flow calculation.

Lower values react faster but may create more noise.
Higher values are smoother but react later.

Beginner suggestion:
Use the default value first. Adjust only after watching how the oscillator behaves on your preferred market and timeframe.

Signal Length

Controls the smoothing of the signal line.

Lower values create faster crosses.
Higher values create slower, cleaner crosses.

Beginner suggestion:
A smoother signal line is usually easier to read when learning the tool.

RMI Length

Controls the RMI-based momentum component.

RMI helps identify directional pressure and momentum shifts. It is useful for detecting when the market starts to build bullish or bearish energy.

MFI Length

Controls the money flow component.

MFI adds a volume-weighted pressure reading to the oscillator. It helps show whether momentum is supported by volume activity.

WaveTrend Length

Controls the wave movement component.

WaveTrend helps create a smoother cyclic reading of market pressure. It can help identify changes in momentum rhythm.

Range / Compression Length

Controls the compression and expansion component.

This part of the oscillator is designed to show when movement is narrow, quiet or compressed compared with normal conditions.

Strong Level

Sets the level used to define strong bullish or bearish flow.

Example:
If the strong level is 50, readings above +50 represent stronger bullish pressure and readings below -50 represent stronger bearish pressure.

Extreme Level

Sets the level used to define extreme bullish or bearish flow.

Example:
If the extreme level is 80, readings above +80 are considered extreme bullish pressure and readings below -80 are considered extreme bearish pressure.

Bull Color

Controls the bullish visual color.

Bear Color

Controls the bearish visual color.

Neutral Color

Controls the neutral or balanced visual color.

Fill Transparency

Controls how visible the oscillator fills are.

Lower transparency makes fills stronger.
Higher transparency makes fills lighter.

Background Compression Highlight

Enables or disables the compression background.

Use this to identify moments where the market may be moving into a quieter range or preparing for a future expansion.

────────────────────────────
HOW TO READ THE TOOL
────────────────────────────

Basic reading:

Flow above zero:
Bullish pressure has the advantage.

Flow below zero:
Bearish pressure has the advantage.

Flow near zero:
No clear directional advantage.

Flow above signal:
Bullish momentum is improving.

Flow below signal:
Bearish momentum is improving.

Flow above strong level:
Bullish momentum is strong.

Flow below negative strong level:
Bearish momentum is strong.

Flow inside extreme zones:
Market pressure is stretched and should be interpreted carefully.

────────────────────────────
BEGINNER TUTORIAL
────────────────────────────

Step 1 — Start with the zero line

The first thing to watch is whether the oscillator is above or below zero.

If it stays mostly above zero, the market is showing bullish pressure.
If it stays mostly below zero, the market is showing bearish pressure.
If it keeps crossing zero, the market may be choppy or undecided.

Step 2 — Watch the flow and signal cross

A bullish cross happens when the flow line crosses above the signal line.
A bearish cross happens when the flow line crosses below the signal line.

These crosses are stronger when they happen in the direction of the broader trend.

Step 3 — Check the strong levels

A bullish cross below zero may be early.
A bullish cross above zero is usually cleaner.
A bullish cross followed by movement above the strong level shows stronger momentum.

The same logic applies in reverse for bearish conditions.

Step 4 — Respect the extreme zones

When the oscillator reaches an extreme zone, the market may be stretched.

This can mean two different things:
• strong trend continuation
• potential exhaustion

Do not assume every extreme reading is a reversal. Use price structure and support/resistance for confirmation.

Step 5 — Use compression as context

When compression appears, the market may be losing directional movement or preparing for expansion.

A compression zone followed by a strong flow breakout can be useful context for trend continuation or range breakout analysis.

────────────────────────────
EXAMPLE USE CASES
────────────────────────────

Example 1 — Bullish confirmation

Price is above a key support area.
The oscillator crosses above the signal line.
Flow moves above zero.
The bullish dot appears.
The flow line continues toward the strong bullish level.

This suggests bullish pressure is improving. A trader may use this as confirmation together with chart structure and risk planning.

Example 2 — Bearish confirmation

Price rejects a resistance area.
The oscillator crosses below the signal line.
Flow moves below zero.
The bearish dot appears.
The flow line continues toward the negative strong level.

This suggests bearish pressure is increasing. A trader may use this as confirmation together with structure and risk planning.

Example 3 — Avoiding weak signals

A bullish dot appears, but the flow line is still below zero.
Price is also under resistance.
The oscillator does not reach the strong bullish level.

This may indicate a weaker bullish attempt. A beginner may choose to wait for stronger confirmation.

Example 4 — Strong trend continuation

The oscillator stays above zero for a long period.
Pullbacks remain above the signal line or quickly recover.
Flow repeatedly returns toward the strong bullish zone.

This can indicate that bullish momentum remains active. In this situation, bearish crosses may be temporary pullbacks rather than full reversals.

Example 5 — Range or compression behavior

The oscillator stays near zero.
Bullish and bearish crosses appear frequently.
Compression background is visible.
Price is moving sideways.

This can indicate a range or low-direction environment. In this situation, signals may be less reliable unless price breaks out with confirmation.

────────────────────────────
SUGGESTED BEGINNER SETTINGS
────────────────────────────

For cleaner signals:
Use longer lengths.
Use a smoother signal line.
Keep dots enabled.
Watch only crosses that happen near or beyond the zero line.

For faster signals:
Use shorter lengths.
Use a faster signal line.
Expect more noise and more false moves.

For trend confirmation:
Focus on whether the oscillator remains above or below zero.
Use strong levels to confirm momentum expansion.

For range detection:
Watch the compression background and repeated crosses around zero.

────────────────────────────
HOW TO COMBINE WITH OTHER TOOLS
────────────────────────────

This oscillator works best as a confirmation tool.

Possible combinations:

1. Price action
Use the oscillator to confirm breakouts, pullbacks and reversals.

2. Support and resistance
Bullish signals are more meaningful near support.
Bearish signals are more meaningful near resistance.

3. Trend indicators
Use the oscillator to confirm trend strength and avoid entering against strong momentum.

4. Volume analysis
The MFI component helps include money flow pressure, but additional volume tools may still provide useful context.

5. Risk management
Always define stop loss, invalidation level and target logic before entering a trade.

────────────────────────────
ALERTS
────────────────────────────

The oscillator can be used with alert conditions such as:

Bullish dot
Bearish dot
Strong bullish flow
Strong bearish flow
Extreme bullish flow
Extreme bearish flow

Suggested alert workflow:

1. Add the oscillator to the chart.
2. Open the TradingView alert window.
3. Select the oscillator as the alert source.
4. Choose the condition you want to monitor.
5. Use alerts as notifications, not as automatic trading decisions.

────────────────────────────
IMPORTANT NOTES
────────────────────────────

This script is an analytical oscillator. It is not a complete trading system.

It does not guarantee entries, exits or profitable results.

Market conditions can change quickly. Trend, volatility, liquidity, news and session behavior can affect all oscillator readings.

The tool should be tested on each market and timeframe before being used in live trading decisions.

Past signals do not guarantee future results.

Use proper risk management at all times.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("INFINITY FLOW OSCILLATOR", "IFO", overlay=false, max_labels_count=500, max_lines_count=50, max_boxes_count=50)

gMain = "⚡ INFINITY FLOW OSCILLATOR"
showOsc = input.bool(true, "Show Oscillator", group=gMain, tooltip="Enable or disable the full Infinity Flow Oscillator visual engine.")
src = input.source(hlc3, "Source", group=gMain, tooltip="Price source used by the RMI, MFI, WaveTrend and flow score calculations. HLC3 is smoother than close and works well for a visual companion oscillator.")
flowSmooth = input.int(3, "Flow Smoothing", minval=1, maxval=50, group=gMain, tooltip="Final smoothing applied to the combined Flow Score. Lower values react faster. Higher values create smoother waves.")
signalLen = input.int(9, "Signal Length", minval=1, maxval=100, group=gMain, tooltip="Signal line smoothing length. Crosses between the Flow Score and the signal line can be used as early confirmation dots.")

gRmi = "🧬 RMI / MFI FLOW"
rmiLen = input.int(14, "RMI Length", minval=1, group=gRmi, tooltip="Length used for the Relative Momentum Index component. This keeps the oscillator connected to the RMI Trend logic used in the main indicator.")
rmiMomLen = input.int(5, "RMI Momentum Length", minval=1, group=gRmi, tooltip="Momentum distance used by the RMI. Higher values measure broader directional pressure; lower values react faster.")
mfiLen = input.int(14, "MFI Length", minval=1, group=gRmi, tooltip="Money Flow Index length. This adds volume pressure to the oscillator, so the wave can distinguish weak momentum from stronger money flow.")
rmiWeight = input.float(0.35, "RMI Weight", minval=0.0, maxval=1.0, step=0.05, group=gRmi, tooltip="Weight of the RMI component inside the final Flow Score.")
mfiWeight = input.float(0.25, "MFI Weight", minval=0.0, maxval=1.0, step=0.05, group=gRmi, tooltip="Weight of the MFI volume-pressure component inside the final Flow Score.")

gWave = "🌊 WAVETREND ENERGY"
wtFastLen = input.int(10, "WaveTrend Fast Length", minval=1, group=gWave, tooltip="Fast smoothing length used by the WaveTrend cycle component.")
wtSlowLen = input.int(21, "WaveTrend Slow Length", minval=1, group=gWave, tooltip="Slow smoothing length used by the WaveTrend cycle component.")
wtWeight = input.float(0.35, "WaveTrend Weight", minval=0.0, maxval=1.0, step=0.05, group=gWave, tooltip="Weight of the WaveTrend cycle component inside the final Flow Score.")

gRange = "🧱 RANGE / COMPRESSION ENERGY"
atrLen = input.int(14, "ATR Length", minval=1, group=gRange, tooltip="ATR length used to measure current volatility expansion and compression.")
atrBaseLen = input.int(100, "ATR Baseline Length", minval=2, group=gRange, tooltip="Baseline smoothing used to compare current ATR to its longer-term average. This creates the compression/expansion layer.")
compressionTrigger = input.float(35.0, "Compression Trigger", minval=0.0, maxval=100.0, step=1.0, group=gRange, tooltip="When compression rises above this level, the oscillator background highlights a potential range/compression phase.")
rangeWeight = input.float(0.05, "Expansion Weight", minval=0.0, maxval=0.50, step=0.01, group=gRange, tooltip="Small directional boost added when volatility expands. Keep this low so the oscillator remains momentum-driven instead of volatility-driven.")

gLevels = "🎚️ LEVELS"
weakLevel = input.float(20.0, "Weak Pressure Level", minval=1.0, maxval=100.0, step=1.0, group=gLevels, tooltip="Early bull/bear pressure threshold. Above +level is early bullish pressure; below -level is early bearish pressure.")
strongLevel = input.float(50.0, "Strong Pressure Level", minval=1.0, maxval=100.0, step=1.0, group=gLevels, tooltip="Strong trend pressure threshold. Above +level means strong bull flow; below -level means strong bear flow.")
extremeLevel = input.float(80.0, "Extreme Pressure Level", minval=1.0, maxval=100.0, step=1.0, group=gLevels, tooltip="Extreme exhaustion threshold. Above +level is extreme bull pressure; below -level is extreme bear pressure.")

gVisual = "🎨 LEGENDARY VISUALS"
showWave = input.bool(true, "Show Main Wave", group=gVisual, tooltip="Display the main Flow Score wave.")
showSignal = input.bool(true, "Show Signal Line", group=gVisual, tooltip="Display the smoothed signal line used for early confirmation crosses.")
showHistogram = input.bool(true, "Show Flow Histogram", group=gVisual, tooltip="Display the difference between Flow Score and signal line as a soft histogram behind the wave.")
showFills = input.bool(true, "Show Wave Fills", group=gVisual, tooltip="Fill the area between the wave and the zero line with bull/bear transparent layers.")
showCloud = input.bool(true, "Show Wave/Signal Cloud", group=gVisual, tooltip="Fill the space between the Flow Score and the signal line. This adds a second visual layer for impulse and weakening pressure.")
showZones = input.bool(true, "Show Extreme Zones", group=gVisual, tooltip="Display layered bull/bear pressure zones around +50/+80 and -50/-80.")
showCompressionBg = input.bool(true, "Show Compression Background", group=gVisual, tooltip="Highlight the oscillator background when volatility compression is detected.")
showDots = input.bool(true, "Show Confirmation Dots", group=gVisual, tooltip="Show small dots when the Flow Score crosses the signal line.")
showPanel = input.bool(true, "Show Mini Panel", group=gVisual, tooltip="Display a small state panel with Flow, RMI, MFI, WaveTrend and Compression values.")

gColors = "🌈 COLORS"
cBull = input.color(#00d4d4, "Bull Color", group=gColors, tooltip="Bullish color used for the wave, fills, dots and panel states. Default matches the Infinity visual style.")
cBear = input.color(#ff2e63, "Bear Color", group=gColors, tooltip="Bearish color used for the wave, fills, dots and panel states. Default matches the Infinity visual style.")
cMid = input.color(color.new(color.white, 0), "Midline Color", group=gColors, tooltip="Color used for the oscillator zero line and neutral references.")
cRange = input.color(color.orange, "Compression Color", group=gColors, tooltip="Color used when the oscillator detects range compression.")
cPanelBg = input.color(color.new(#000814, 15), "Panel Background", group=gColors, tooltip="Background color of the mini panel.")

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_rmi(series float s, simple int len, simple int momLen) =>
    float ch = s - nz(s[momLen], s)
    float up = ta.rma(math.max(ch, 0.0), len)
    float dn = ta.rma(math.max(-ch, 0.0), len)
    dn == 0.0 ? 100.0 : up == 0.0 ? 0.0 : 100.0 - (100.0 / (1.0 + up / dn))

f_stateText(float v) =>
    v >= extremeLevel ? "EXTREME BULL" : v >= strongLevel ? "STRONG BULL" : v >= weakLevel ? "EARLY BULL" : v <= -extremeLevel ? "EXTREME BEAR" : v <= -strongLevel ? "STRONG BEAR" : v <= -weakLevel ? "EARLY BEAR" : "NEUTRAL"

f_stateColor(float v) =>
    v >= weakLevel ? color.new(cBull, 25) : v <= -weakLevel ? color.new(cBear, 25) : color.new(color.gray, 65)

f_fmt(float v) =>
    str.tostring(v, "#.0")

var array<label> dotLabels = array.new<label>()
f_addDot(float y, string txt, color txtCol) =>
    label lb = label.new(bar_index, y, txt, yloc=yloc.price, style=label.style_label_center, color=color.new(color.black, 100), textcolor=txtCol, size=size.small)
    array.push(dotLabels, lb)
    while array.size(dotLabels) > 100
        label old = array.shift(dotLabels)
        label.delete(old)

rmiRaw = f_rmi(src, rmiLen, rmiMomLen)
mfiRaw = ta.mfi(hlc3, mfiLen)
rmiFlow = (rmiRaw - 50.0) * 2.0
mfiFlow = (mfiRaw - 50.0) * 2.0

esa = ta.ema(src, wtFastLen)
dev = ta.ema(math.abs(src - esa), wtFastLen)
ci = dev != 0.0 ? (src - esa) / (0.015 * dev) : 0.0
wtRaw = ta.ema(ci, wtSlowLen)
wtFlow = f_clamp(wtRaw / 1.5, -100.0, 100.0)

atrNow = ta.atr(atrLen)
atrBase = ta.sma(atrNow, atrBaseLen)
atrRatio = atrBase != 0.0 ? atrNow / atrBase : 1.0
compression = f_clamp((1.0 - atrRatio) * 100.0, 0.0, 100.0)
expansion = f_clamp((atrRatio - 1.0) * 100.0, -100.0, 100.0)
directionalBias = close >= ta.ema(close, 21) ? 1.0 : -1.0

weightSum = math.max(rmiWeight + mfiWeight + wtWeight + rangeWeight, 0.0001)
flowRaw = (rmiFlow * rmiWeight + mfiFlow * mfiWeight + wtFlow * wtWeight + expansion * directionalBias * rangeWeight) / weightSum
flow = ta.ema(f_clamp(flowRaw, -100.0, 100.0), flowSmooth)
signal = ta.ema(flow, signalLen)
hist = flow - signal

flowColor = color.from_gradient(flow, -100.0, 100.0, cBear, cBull)
histColor = hist >= 0.0 ? color.new(cBull, 72) : color.new(cBear, 72)
cloudColor = flow >= signal ? color.new(cBull, 82) : color.new(cBear, 82)
waveFillColor = flow >= 0.0 ? color.new(cBull, 84) : color.new(cBear, 84)
compressionOn = compression >= compressionTrigger

h100 = hline(100, "Upper Limit", color=color.new(cBull, 85))
h80 = hline(80, "Extreme Bull", color=color.new(cBull, 75))
h50 = hline(50, "Strong Bull", color=color.new(cBull, 82))
h20 = hline(20, "Early Bull", color=color.new(cBull, 88))
h0 = hline(0, "Equilibrium", color=color.new(cMid, 45), linestyle=hline.style_dotted)
hm20 = hline(-20, "Early Bear", color=color.new(cBear, 88))
hm50 = hline(-50, "Strong Bear", color=color.new(cBear, 82))
hm80 = hline(-80, "Extreme Bear", color=color.new(cBear, 75))
hm100 = hline(-100, "Lower Limit", color=color.new(cBear, 85))

fill(h100, h80, color=showZones ? color.new(cBull, 88) : na, title="Extreme Bull Layer")
fill(h80, h50, color=showZones ? color.new(cBull, 93) : na, title="Strong Bull Layer")
fill(hm50, hm80, color=showZones ? color.new(cBear, 93) : na, title="Strong Bear Layer")
fill(hm80, hm100, color=showZones ? color.new(cBear, 88) : na, title="Extreme Bear Layer")

pZero = plot(showOsc ? 0.0 : na, "Zero Fill Base", color=color.new(cMid, 92), linewidth=1)
pFlow = plot(showOsc and showWave ? flow : na, "Infinity Flow", color=flowColor, linewidth=3)
pSignal = plot(showOsc and showSignal ? signal : na, "Flow Signal", color=color.new(cMid, 0), linewidth=1)
pHist = plot(showOsc and showHistogram ? hist : na, "Flow Histogram", style=plot.style_columns, histbase=0, color=histColor)

fill(pFlow, pZero, color=showOsc and showFills ? waveFillColor : na, title="Main Wave Fill")
fill(pFlow, pSignal, color=showOsc and showCloud ? cloudColor : na, title="Wave Signal Cloud")

bgcolor(showOsc and showCompressionBg and compressionOn ? color.new(cRange, 88) : na, title="Compression Background")

bullDotRaw = ta.crossover(flow, signal)
bearDotRaw = ta.crossunder(flow, signal)
strongBullRaw = ta.crossover(flow, strongLevel)
strongBearRaw = ta.crossunder(flow, -strongLevel)
extremeBullRaw = ta.crossover(flow, extremeLevel)
extremeBearRaw = ta.crossunder(flow, -extremeLevel)
bullDot = showOsc and showDots and bullDotRaw and flow > -strongLevel
bearDot = showOsc and showDots and bearDotRaw and flow < strongLevel
strongBull = showOsc and strongBullRaw
strongBear = showOsc and strongBearRaw
extremeBull = showOsc and extremeBullRaw
extremeBear = showOsc and extremeBearRaw
compressionReleaseBull = showOsc and compressionOn[1] and not compressionOn and flow > 0 and flow > signal
compressionReleaseBear = showOsc and compressionOn[1] and not compressionOn and flow < 0 and flow < signal

if bullDot and barstate.isconfirmed
    f_addDot(flow, "●", cBull)
if bearDot and barstate.isconfirmed
    f_addDot(flow, "●", cBear)

alertcondition(bullDot and barstate.isconfirmed, "IFO Bull Flow Dot", "INFINITY FLOW OSCILLATOR: Bull flow confirmation dot")
alertcondition(bearDot and barstate.isconfirmed, "IFO Bear Flow Dot", "INFINITY FLOW OSCILLATOR: Bear flow confirmation dot")
alertcondition(strongBull and barstate.isconfirmed, "IFO Strong Bull", "INFINITY FLOW OSCILLATOR: Flow crossed above strong bull level")
alertcondition(strongBear and barstate.isconfirmed, "IFO Strong Bear", "INFINITY FLOW OSCILLATOR: Flow crossed below strong bear level")
alertcondition(extremeBull and barstate.isconfirmed, "IFO Extreme Bull", "INFINITY FLOW OSCILLATOR: Flow crossed into extreme bull zone")
alertcondition(extremeBear and barstate.isconfirmed, "IFO Extreme Bear", "INFINITY FLOW OSCILLATOR: Flow crossed into extreme bear zone")
alertcondition(compressionReleaseBull and barstate.isconfirmed, "IFO Compression Release Bull", "INFINITY FLOW OSCILLATOR: Compression released with bullish flow")
alertcondition(compressionReleaseBear and barstate.isconfirmed, "IFO Compression Release Bear", "INFINITY FLOW OSCILLATOR: Compression released with bearish flow")

var table pan = table.new(position.top_right, 2, 6, bgcolor=cPanelBg, frame_color=color.new(cBull, 35), frame_width=1, border_color=color.new(cBull, 65), border_width=1)

if showPanel and barstate.islast
    table.clear(pan, 0, 0, 1, 5)
    table.cell(pan, 0, 0, "⚡ INFINITY FLOW", text_color=color.white, bgcolor=color.new(cBull, 80), text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(pan, 0, 0, 1, 0)
    table.cell(pan, 0, 1, "State", text_color=color.white, bgcolor=color.new(cBull, 88), text_size=size.tiny, text_halign=text.align_left)
    table.cell(pan, 1, 1, f_stateText(flow), text_color=color.white, bgcolor=f_stateColor(flow), text_size=size.tiny)
    table.cell(pan, 0, 2, "Flow", text_color=color.white, bgcolor=color.new(cBull, 88), text_size=size.tiny, text_halign=text.align_left)
    table.cell(pan, 1, 2, f_fmt(flow), text_color=flow >= 0 ? cBull : cBear, bgcolor=color.new(color.black, 70), text_size=size.tiny)
    table.cell(pan, 0, 3, "RMI / MFI", text_color=color.white, bgcolor=color.new(cBull, 88), text_size=size.tiny, text_halign=text.align_left)
    table.cell(pan, 1, 3, f_fmt(rmiRaw) + " / " + f_fmt(mfiRaw), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.tiny)
    table.cell(pan, 0, 4, "Wave", text_color=color.white, bgcolor=color.new(cBull, 88), text_size=size.tiny, text_halign=text.align_left)
    table.cell(pan, 1, 4, f_fmt(wtFlow), text_color=wtFlow >= 0 ? cBull : cBear, bgcolor=color.new(color.black, 70), text_size=size.tiny)
    table.cell(pan, 0, 5, "Compression", text_color=color.white, bgcolor=color.new(cBull, 88), text_size=size.tiny, text_halign=text.align_left)
    table.cell(pan, 1, 5, f_fmt(compression) + (compressionOn ? " RANGE" : " FREE"), text_color=compressionOn ? cRange : color.white, bgcolor=compressionOn ? color.new(cRange, 70) : color.new(color.black, 70), text_size=size.tiny)
````
