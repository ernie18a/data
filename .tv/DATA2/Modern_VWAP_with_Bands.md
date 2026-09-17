<!-- tradingview-pine-id: PUB;41c3fe2e210f45d7aabab886ff939484 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Modern VWAP with Bands

Source: https://www.tradingview.com/script/m0ND7lSN-Modern-VWAP-with-Bands/

## Description

Modern VWAP with Bands is an anchored Volume Weighted Average Price overlay designed to show how far price has moved from its current volume-weighted reference and highlight unusually extended conditions that may be relevant to mean-reversion analysis.

The indicator combines an anchored VWAP, five configurable deviation bands, distance-based candle coloring, outer-band reversion signals, configurable Target and Stop reference levels, and separate historical Bull and Bear signal-outcome tables.

WHAT THE INDICATOR CALCULATES

The Trading Style setting determines the VWAP anchor period and price source.

Intraday = Daily VWAP using HLC3.

Swing/Daily = Weekly VWAP using HL2.

Long-term = Monthly VWAP using Close.

The VWAP resets automatically when the selected Daily, Weekly or Monthly anchor changes.

Five upper and five lower deviation bands are calculated around VWAP.

When ATR Bands is enabled, each deviation level represents an ATR multiple.

When ATR Bands is disabled, each deviation level represents a percentage offset from VWAP.

This allows the band structure to adapt either to current volatility or to fixed percentage distance from the VWAP reference.

WHY THE COMPONENTS ARE COMBINED

VWAP provides the central volume-weighted reference.

The deviation bands measure progressively larger extensions away from that reference.

The candle-coloring system provides a visual representation of how extended price currently is.

The outer Dev 5 signal logic identifies occasions when price moves through the most extreme configured band.

The Bull and Bear tables then provide historical context showing how those signals resolved using the selected Target and Stop assumptions.

Together, these components provide a workflow for identifying the current VWAP reference, measuring extension, highlighting extreme movement, identifying outer-band events and reviewing their historical outcomes.

BAR COLOR DISTANCE

Bar Color Distance Mode controls how distance from VWAP is normalized.

ATR mode measures absolute distance from VWAP relative to ATR.

% VWAP mode calculates the absolute percentage distance from the VWAP itself:

Absolute distance from VWAP / VWAP × 100

For example, if VWAP is 100 and the selected price source is 102, the % VWAP distance is 2%.

Auto mode uses ATR normalization when ATR Bands is enabled and % VWAP normalization when percentage bands are being used.

This keeps the candle-color distance measurement aligned with the selected band methodology.

REVERSION SIGNALS

A Bull reversion signal occurs when the closing price crosses below the lower Dev 5 band.

A Bear reversion signal occurs when the closing price crosses above the upper Dev 5 band.

These signals identify extreme extensions from VWAP. They do not confirm that a reversal has already started and should not be interpreted as predictions that price must return to VWAP.

Require Outside Dev 5 can apply an additional extension requirement beyond the Dev 5 band before a signal is accepted.

Dev 5 Outside % controls how far beyond Dev 5 price must extend when this filter is enabled.

The optional Cool Off Period prevents another accepted signal for a selected number of bars after the previous signal.

Show Reversion Signals controls only the visibility of the Bull and Bear markers. The underlying signal calculations and historical outcome tracking continue to operate when the markers are hidden.

ENTRY, TARGET AND STOP

The reference entry for both Bull and Bear signals is the closing price of the signal candle.

Bull Stop is positioned below the Bull reference entry according to Bull Stop %.

Bear Stop is positioned above the Bear reference entry according to Bear Stop %.

Target Source can be set to User % or VWAP.

With User % selected, Bull Target % and Bear Target % determine the Target distance from the signal-bar close.

With VWAP selected, the Target is the VWAP value that existed when the signal occurred.

The VWAP Target is fixed at that signal-bar value. It does not continue moving as the VWAP changes on later candles.

The Target and Stop lines displayed on the chart use the same corresponding values used by the historical outcome tables.

HISTORICAL SIGNAL-OUTCOME TABLES

The Bull and Bear tables provide simplified historical signal-outcome statistics.

T = Target reached.

S = Stop reached.

The displayed percentage is the number of Target outcomes divided by the total number of resolved Target and Stop outcomes for that direction.

The percentage is an internal historical measurement produced by the indicator's predefined evaluation rules. It is not a probability, expected win rate, accuracy prediction or guarantee of future performance.

The reference entry is the close of the signal candle.

Target and Stop evaluation begins on the following candle. Price movement that occurred earlier within the signal candle is therefore not used to determine an outcome after an entry at that candle's close.

If both the Target and Stop are touched during the same later candle, OHLC data cannot determine which level occurred first. The script therefore records the event conservatively as a Stop outcome.

Only one unresolved Bull simulation and one unresolved Bear simulation can be active at the same time.

If another signal in the same direction occurs while that direction already has an unresolved event, it is not added as another independently scored table event.

When Ignore Open Trades on Reset is enabled, unresolved events are discarded when the selected VWAP anchor resets. They are not counted as either a Target or Stop outcome.

These tables are analytical summaries and are not TradingView Strategy Tester backtests.

HOW TO USE

Start by selecting the Trading Style that matches the VWAP reference you want to analyse.

Use Intraday for a Daily VWAP, Swing/Daily for a Weekly VWAP, or Long-term for a Monthly VWAP.

Choose whether the deviation structure should react to current volatility using ATR Bands or represent fixed percentage distances from VWAP.

The inner deviation bands show smaller extensions from VWAP while the outer bands represent progressively larger extensions.

Use the candle colors as a quick visual indication of the current distance from VWAP.

Bull signals identify closes crossing below the lower Dev 5 band.

Bear signals identify closes crossing above the upper Dev 5 band.

These are extreme-extension conditions rather than automatic trade instructions. They can be combined with the trader's own price structure, trend, momentum, support/resistance or other confirmation methods.

Require Outside Dev 5 can be enabled when a greater extension beyond the outer band is desired.

The Cool Off Period can reduce repeated signals when price repeatedly moves around the outer band.

The Bull and Bear tables can then be used to examine how historical signals resolved under the currently selected Target and Stop assumptions.

IMPORTANT SETTINGS

Trading Style controls the VWAP anchor and source.

ATR Bands selects ATR-based or percentage-based deviation bands.

ATR Length controls the volatility calculation used by ATR bands and ATR-normalized visual calculations.

Level 1 Dev through Level 5 Dev control the five distances around VWAP.

Bar Color Distance Mode selects ATR or % VWAP normalization for candle coloring.

Bar Color Contrast Power controls how quickly color intensity increases as price moves farther from VWAP.

Bar Color Outside Boost increases visual emphasis after the most extreme configured distance is exceeded.

Require Outside Dev 5 adds an additional extension filter to signal generation.

Cool Off Period controls the minimum spacing between accepted signals when enabled.

Target Source selects percentage-based Targets or the fixed VWAP value at the signal.

Bull Target %, Bull Stop %, Bear Target % and Bear Stop % define the assumptions used for the corresponding historical signal-outcome calculations.

SIGNAL TIMING AND REPAINTING

The script does not use future-data lookahead, higher-timeframe request.security calculations, pivot calculations or historical pivot backplotting.

Signals are calculated using the current chart candle.

Because the closing price of a live candle changes while that candle is forming, a Bull or Bear signal can appear and disappear before the candle closes.

Once the candle has closed, that historical signal condition is fixed.

The script does not place a confirmed signal retrospectively onto an earlier pivot candle.

LIMITATIONS

VWAP depends on the volume data supplied for the selected chart symbol. Volume can differ between exchanges, brokers and data feeds, so VWAP and its resulting bands may also differ.

The indicator uses chart OHLCV data. It does not use order-book data, bid/ask trade classification or individual transaction-level order flow.

ATR is a historical volatility calculation and responds to changing market conditions rather than predicting them.

Extreme distance from VWAP does not guarantee mean reversion. Price can continue moving farther away from VWAP after a Bull or Bear signal.

Live-candle conditions can change before the candle closes.

The Bull and Bear historical statistics do not model commissions, spread, slippage, execution delay, liquidity, partial fills, leverage, position sizing or true intrabar sequencing.

When both Target and Stop occur inside the same candle range, the actual sequence cannot be determined from OHLC data and the event is therefore classified as a Stop.

Unresolved simulations can be removed at VWAP anchor resets when Ignore Open Trades on Reset is enabled.

The pre-reset and post-reset fading effects are visual features based on the expected length of the selected anchor period. Markets with restricted sessions or gaps may contain a different number of actual chart bars.

Historical results do not imply future performance.

ORIGINAL FUNCTIONALITY

Modern VWAP with Bands is designed as more than a standard VWAP plot.

Its implementation integrates selectable Daily, Weekly and Monthly VWAP anchoring, five ATR-or-percentage deviation zones, VWAP-relative or ATR-normalized candle coloring, configurable extreme-band signal filtering, fixed VWAP-or-percentage Targets, configurable Stops, anchor-reset handling and separate Bull and Bear historical outcome tracking.

The purpose of combining these elements is to connect VWAP location, distance measurement, visual extension analysis, signal generation and historical signal evaluation within one consistent overlay.

---

## Source Code

````pine
//@version=6
indicator(title="Modern VWAP with Bands", overlay=true, explicit_plot_zorder=true)

//─────────────────────────────────────────────────────────────────────────────
// Color Preset
//─────────────────────────────────────────────────────────────────────────────
groupPreset = "Color Preset"
colorPreset = input.string("Dark Background", "Color Preset", options=["Dark Background", "Light Background"], group=groupPreset)

isLightPreset = colorPreset == "Light Background"
presetWhite = isLightPreset ? color.black : color.white

// Trade Simulation Settings
groupTrade = "Trade Simulation"
bullTP = input.float(2.0, "Bull Target %", tooltip="Bullish Target percentage.\n\nSuggested settings by trading style:\n• Intraday (1m-15m charts): 1.5-3.0%\n• Swing/Daily (1h-4h): 3.0-6.0%\n• Long-term (Daily+): 5.0-12.0%", minval=0.1, maxval=50, step=0.1, group=groupTrade)
bullSL = input.float(1.5, "Bull Stop %", tooltip="Bullish Stop percentage. Aim for 1:1.5 to 1:3 risk-reward ratio (Stop ~0.5-0.7x Target).\n\nSuggested:\n• Intraday: 1.0-2.0%\n• Swing/Daily: 2.0-4.0%\n• Long-term: 4.0-8.0%", minval=0.1, maxval=50, step=0.1, group=groupTrade)
bearTP = input.float(2.0, "Bear Target %", tooltip="Bearish Target percentage.\n\nSuggested settings by trading style:\n• Intraday (1m-15m charts): 1.5-3.0%\n• Swing/Daily (1h-4h): 3.0-6.0%\n• Long-term (Daily+): 5.0-12.0%", minval=0.1, maxval=50, step=0.1, group=groupTrade)
bearSL = input.float(1.5, "Bear Stop %", tooltip="Bearish Stop percentage. Aim for 1:1.5 to 1:3 risk-reward ratio.\n\nSuggested:\n• Intraday: 1.0-2.0%\n• Swing/Daily: 2.0-4.0%\n• Long-term: 4.0-8.0%", minval=0.1, maxval=50, step=0.1, group=groupTrade)
tpSource = input.string("User %", "Target Source", options=["User %", "VWAP"], tooltip="Choose whether targets are based on Bull/Bear Target % inputs or the VWAP value at entry.", group=groupTrade)


coolOffEnabled = input.bool(false, title="Enable Cool Off Period", tooltip="Prevents new signals during the cool-off period after a signal, reducing overtrading.", group=groupTrade)
coolOffPeriod = input.int(10, title="Cool Off Period (bars)", tooltip="Number of bars to wait after a signal before allowing the next one.\n\nSuggested:\n• Intraday: 5-20 bars\n• Swing/Daily: 10-50 bars\n• Long-term: 20-100 bars", minval=1, group=groupTrade)
enableDev5Filter = input.bool(false, title="Require Outside Dev 5", tooltip="Only generate signals if price is outside the Dev 5 band by the specified percentage (more extended mean-reversion setups).", group=groupTrade)
dev5OutsidePercent = input.float(0.5, title="Dev 5 Outside %", tooltip="Minimum percentage price must exceed Dev 5 band for signals (when filter enabled).\nExample range: 0.3-1.0%; adjust for the instrument and timeframe.", minval=0.0, group=groupTrade) / 100

showBullTable = input.bool(true, "Show Bull Table", tooltip="Show/hide the bullish historical signal-outcome summary table. T = target reached, S = stop reached, and % = target outcomes divided by resolved outcomes.", group="Signal Tables")
showBearTable = input.bool(true, "Show Bear Table", tooltip="Show/hide the bearish historical signal-outcome summary table. T = target reached, S = stop reached, and % = target outcomes divided by resolved outcomes.", group="Signal Tables")
bullPosStr = input.string("Top Left", "Bull Table Position", tooltip="Choose where the Bull table appears on the chart.", group="Signal Tables", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"])
bearPosStr = input.string("Top Right", "Bear Table Position", tooltip="Choose where the Bear table appears on the chart.", group="Signal Tables", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"])
bullHOffset = input.int(0, "Bull Table H Offset (cols)", tooltip="Horizontal offset (in table columns) for the Bull table.", minval=0, maxval=20, group="Signal Tables")
bullVOffset = input.int(0, "Bull Table V Offset (rows)", tooltip="Vertical offset (in table rows) for the Bull table.", minval=0, maxval=10, group="Signal Tables")
bearHOffset = input.int(0, "Bear Table H Offset (cols)", tooltip="Horizontal offset (in table columns) for the Bear table.", minval=0, maxval=20, group="Signal Tables")
bearVOffset = input.int(0, "Bear Table V Offset (rows)", tooltip="Vertical offset (in table rows) for the Bear table.", minval=0, maxval=10, group="Signal Tables")

showDev1 = input.bool(true, "Show Dev 1", tooltip="Toggle visibility of Deviation Band 1.", group="Deviation Lines")
showDev2 = input.bool(true, "Show Dev 2", tooltip="Toggle visibility of Deviation Band 2.", group="Deviation Lines")
showDev3 = input.bool(true, "Show Dev 3", tooltip="Toggle visibility of Deviation Band 3.", group="Deviation Lines")
showDev4 = input.bool(true, "Show Dev 4", tooltip="Toggle visibility of Deviation Band 4.", group="Deviation Lines")
showDev5 = input.bool(true, "Show Dev 5", tooltip="Toggle visibility of Deviation Band 5.", group="Deviation Lines")

vwapColor = input.color(color.white, "VWAP Color", tooltip="Color used to plot the VWAP line.", group="Deviation Lines")
dev1Color = input.color(color.aqua, "Dev 1 Color", tooltip="Color for Deviation Band 1.", group="Deviation Lines")
dev2Color = input.color(color.blue, "Dev 2 Color", tooltip="Color for Deviation Band 2.", group="Deviation Lines")
dev3Color = input.color(color.orange, "Dev 3 Color", tooltip="Color for Deviation Band 3.", group="Deviation Lines")
dev4Color = input.color(color.red, "Dev 4 Color", tooltip="Color for Deviation Band 4.", group="Deviation Lines")
dev5Color = input.color(color.maroon, "Dev 5 Color", tooltip="Color for Deviation Band 5.", group="Deviation Lines")

activeVwapColor = isLightPreset and vwapColor == color.white ? color.black : vwapColor

// Inputs
barcOn = input.bool(true, title="Color bars/Candles?", tooltip="Enable dynamic bar/candle coloring based on distance from VWAP.")
tradingStyle = input.string("Intraday", title="Trading Style", tooltip="Determines VWAP anchor/reset period:\n• Intraday: Daily VWAP\n• Swing/Daily: Weekly VWAP\n• Long-term: Monthly VWAP", options=["Intraday", "Swing/Daily", "Long-term"])

barColorDistanceMode = input.string("Auto", "Bar Color Distance Mode", options=["Auto", "ATR", "% VWAP"], tooltip="Auto uses ATR normalization when ATR bands are enabled; otherwise it measures percentage distance from VWAP.")
barColorContrastPower = input.float(1.7, "Bar Color Contrast Power", minval=1.0, maxval=4.0, step=0.1, tooltip="Higher values increase color contrast as price moves away from VWAP.")
barColorOutsideBoost = input.float(1.35, "Bar Color Outside Boost", minval=1.0, maxval=3.0, step=0.05, tooltip="Extra color intensity boost when price is outside Dev 5.")
barColorInsideTransp = input.int(55, "Bar Color Inside Transparency", minval=0, maxval=100, tooltip="Base transparency for bars inside Dev 5.")
barColorOutsideTransp = input.int(0, "Bar Color Outside Transparency", minval=0, maxval=100, tooltip="Base transparency for bars outside Dev 5.")
barExtremeColor = input.color(color.yellow, "Bar Extreme Color", tooltip="Extra extreme color beyond Dev 5.")

string timeFrame = switch tradingStyle
    "Intraday" => "D"
    "Swing/Daily" => "W"
    => "M"

src = switch tradingStyle
    "Intraday" => hlc3
    "Swing/Daily" => hl2
    => close

chart_sec = timeframe.in_seconds(timeframe.period)
anchor_sec = timeframe.in_seconds(timeFrame)
expected_bars = math.max(1, math.round(anchor_sec / chart_sec))

fade_before_reset = input.bool(true, title="Fade VWAP Before Reset?", tooltip="Gradually increase transparency as the current anchor period approaches reset.")
fade_portion = input.float(0.15, title="Fade Portion of Anchor", tooltip="Portion of the anchor period used for fade effect near reset.", minval=0.01, maxval=0.5, step=0.01)
fade_after_reset = input.bool(true, title="Fade VWAP After Reset?", tooltip="Apply a short fade-in right after each VWAP reset.")
fade_in_ratio = input.float(0.3, title="Fade In vs Fade Out Length", tooltip="Relative size of fade-in compared to fade-out duration.", minval=0.2, maxval=0.5, step=0.05)
fade_max_extra = input.int(90, title="Max Extra Transparency", tooltip="Maximum additional transparency applied by fading effects (0-100).", minval=0, maxval=100)

level1 = input.float(0.5, title="Level 1 Dev", tooltip="Deviation multiplier/percent for Band Level 1.")
level2 = input.float(1.0, title="Level 2 Dev", tooltip="Deviation multiplier/percent for Band Level 2.")
level3 = input.float(1.5, title="Level 3 Dev", tooltip="Deviation multiplier/percent for Band Level 3.")
level4 = input.float(2.0, title="Level 4 Dev", tooltip="Deviation multiplier/percent for Band Level 4.")
level5 = input.float(2.5, title="Level 5 Dev", tooltip="Deviation multiplier/percent for Band Level 5.")

use_atr = input.bool(true, title="ATR Bands?", tooltip="If enabled, bands use ATR multipliers; otherwise they use percentage offsets from VWAP.")
atr_length = input.int(20, title="ATR Length", tooltip="Lookback period for ATR in dynamic bands. Common values are 14-21; adjust for the instrument and timeframe.", minval=1)


show_arrows = input.bool(true, title="Show Reversion Signals?", tooltip="Show/hide plotted bull/bear reversion signal markers.", group="Signals")
show_entry_lines = input.bool(true, title="Show Entry Lines?", tooltip="Draw horizontal entry lines on signal bars.", group="Signals")
bear_shape_str = input.string("triangledown", title="Bear Signal Shape", tooltip="Marker shape used for bearish signal labels.", options=["triangleup", "triangledown", "circle", "xcross"], group="Signals")
bull_shape_str = input.string("triangleup", title="Bull Signal Shape", tooltip="Marker shape used for bullish signal labels.", options=["triangleup", "triangledown", "circle", "xcross"], group="Signals")
ignore_open_on_reset = input.bool(true, title="Ignore Open Trades on Reset?", tooltip="If enabled, any open simulated trades are closed/reset when anchor period resets.", group="Signals")
bullSigYOffset = input.float(0.3, "Bull Signal V Offset (ATR mult)", tooltip="Vertical offset for bull signal marker in ATR multiples.", minval=-2.0, maxval=3.0, step=0.05, group="Signals")
bearSigYOffset = input.float(0.3, "Bear Signal V Offset (ATR mult)", tooltip="Vertical offset for bear signal marker in ATR multiples.", minval=-2.0, maxval=3.0, step=0.05, group="Signals")

bullSignalColor = input.color(color.lime, "Bull Signal Color", tooltip="Color used for bullish signal markers.", group="Signals")
bearSignalColor = input.color(color.red, "Bear Signal Color", tooltip="Color used for bearish signal markers.", group="Signals")
entryLineColor = input.color(color.yellow, "Entry Line Color", tooltip="Color used for signal entry lines.", group="Signals")

show_stops = input.bool(true, title="Show Stop Lines?", tooltip="Show/hide plotted stop lines for signals.", group="Stops")
sl_color = input.color(color.new(color.red, 0), title="Stop Line Color", tooltip="Color used for stop lines.", group="Stops")
sl_width = input.int(2, title="Stop Line Width", tooltip="Line thickness for stop lines.", minval=1, maxval=4, group="Stops")
sl_linestyle = input.string("Line", title="Stop Line Style", tooltip="Line style for stop lines.", options=["Line", "Line Break"], group="Stops")
sl_length = input.int(3, title="Stop Line Length (bars)", tooltip="Number of bars each stop line extends.", minval=1, maxval=500, group="Stops")

show_tps = input.bool(true, title="Show Target Lines?", tooltip="Show/hide plotted target lines for signals.", group="Targets")
tp_line_color = input.color(color.new(color.lime, 0), title="Target Line Color", tooltip="Color used for target lines.", group="Targets")
tp_line_width = input.int(2, title="Target Line Width", tooltip="Line thickness for target lines.", minval=1, maxval=4, group="Targets")
tp_linestyle = input.string("Line", title="Target Line Style", tooltip="Line style for target lines.", options=["Line", "Dashed", "Dotted"], group="Targets")
tp_length = input.int(3, title="Target Line Length (bars)", tooltip="Number of bars each target line extends.", minval=1, maxval=500, group="Targets")

// VWAP
anchor = timeframe.change(timeFrame)
myvwap = ta.vwap(src, anchor)

bars_since_anchor = nz(ta.barssince(anchor), 0)
fade_bars = math.max(1, math.round(expected_bars * fade_portion))
fade_in_bars = math.max(1, math.round(fade_bars * fade_in_ratio))
bars_left = math.max(0, expected_bars - bars_since_anchor - 1)
fade_out_progress = fade_before_reset and bars_left <= fade_bars ? 1.0 - (bars_left / fade_bars) : 0.0
fade_in_progress = fade_after_reset and bars_since_anchor < fade_in_bars ? 1.0 - (bars_since_anchor / fade_in_bars) : 0.0
fade_alpha = math.round(math.max(fade_out_progress, fade_in_progress) * fade_max_extra)

fade_transp(base) => math.min(100, base + fade_alpha)

vwapPlot = plot(myvwap, color=color.new(activeVwapColor, fade_alpha), linewidth=2, title="VWAP")

// Bands
atr_val = ta.atr(atr_length)

u1 = use_atr ? myvwap + level1 * atr_val : myvwap * (1 + level1 / 100)
l1 = use_atr ? myvwap - level1 * atr_val : myvwap * (1 - level1 / 100)
u2 = use_atr ? myvwap + level2 * atr_val : myvwap * (1 + level2 / 100)
l2 = use_atr ? myvwap - level2 * atr_val : myvwap * (1 - level2 / 100)
u3 = use_atr ? myvwap + level3 * atr_val : myvwap * (1 + level3 / 100)
l3 = use_atr ? myvwap - level3 * atr_val : myvwap * (1 - level3 / 100)
u4 = use_atr ? myvwap + level4 * atr_val : myvwap * (1 + level4 / 100)
l4 = use_atr ? myvwap - level4 * atr_val : myvwap * (1 - level4 / 100)
u5 = use_atr ? myvwap + level5 * atr_val : myvwap * (1 + level5 / 100)
l5 = use_atr ? myvwap - level5 * atr_val : myvwap * (1 - level5 / 100)


// Shapes
bear_shape = switch bear_shape_str
    "triangleup" => shape.triangleup
    "triangledown" => shape.triangledown
    "circle" => shape.circle
    "xcross" => shape.xcross
    => shape.triangleup

bull_shape = switch bull_shape_str
    "triangleup" => shape.triangleup
    "triangledown" => shape.triangledown
    "circle" => shape.circle
    "xcross" => shape.xcross
    => shape.triangledown

// Signals
var int cooldown = 0

if coolOffEnabled and cooldown > 0
    cooldown -= 1

cooldownReady = not coolOffEnabled or cooldown == 0

cross_bull_u5 = ta.crossover(close, u5)
crossunder_bear_l5 = ta.crossunder(close, l5)

isOutsideDev5 = close > u5 * (1 + dev5OutsidePercent) or close < l5 * (1 - dev5OutsidePercent)

signalPassesFilter = not enableDev5Filter or isOutsideDev5
bullSignal = cooldownReady and signalPassesFilter and crossunder_bear_l5
bearSignal = cooldownReady and signalPassesFilter and cross_bull_u5

if coolOffEnabled and (bullSignal or bearSignal)
    cooldown := coolOffPeriod

bull_shape_y = show_arrows and bullSignal ? low - atr_val * bullSigYOffset : na
bear_shape_y = show_arrows and bearSignal ? high + atr_val * bearSigYOffset : na

plotshape(bull_shape_y, title="Bull Signal", style=bull_shape, location=location.absolute, color=bullSignalColor, size=size.tiny)
plotshape(bear_shape_y, title="Bear Signal", style=bear_shape, location=location.absolute, color=bearSignalColor, size=size.tiny)

// Entry lines placed exactly at signal bar
bullEntry = bullSignal ? close : na
bearEntry = bearSignal ? close : na

plot(show_entry_lines ? bullEntry : na, title="Bull Entry Line", color=bullSignal ? entryLineColor : na, linewidth=4, style=plot.style_linebr)
plot(show_entry_lines ? bearEntry : na, title="Bear Entry Line", color=bearSignal ? entryLineColor : na, linewidth=4, style=plot.style_linebr)

// Stop/Target Lines
var array<line> bull_sl_lines = array.new<line>()
var array<line> bear_sl_lines = array.new<line>()
var array<line> bull_tp_lines = array.new<line>()
var array<line> bear_tp_lines = array.new<line>()

sl_line_style = sl_linestyle == "Line Break" ? line.style_dashed : line.style_solid
tp_line_style = switch tp_linestyle
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

if show_stops and bearSignal
    sl_level = close * (1 + bearSL / 100)
    new_line = line.new(bar_index, sl_level, bar_index + sl_length, sl_level, xloc=xloc.bar_index, color=sl_color, width=sl_width, style=sl_line_style)
    array.push(bear_sl_lines, new_line)

if show_stops and bullSignal
    sl_level = close * (1 - bullSL / 100)
    new_line = line.new(bar_index, sl_level, bar_index + sl_length, sl_level, xloc=xloc.bar_index, color=sl_color, width=sl_width, style=sl_line_style)
    array.push(bull_sl_lines, new_line)

if show_tps and bullSignal
    bullTpLineLevel = tpSource == "VWAP" ? myvwap : close * (1 + bullTP / 100)
    new_tp_line = line.new(bar_index, bullTpLineLevel, bar_index + tp_length, bullTpLineLevel, xloc=xloc.bar_index, color=tp_line_color, width=tp_line_width, style=tp_line_style)
    array.push(bull_tp_lines, new_tp_line)

if show_tps and bearSignal
    bearTpLineLevel = tpSource == "VWAP" ? myvwap : close * (1 - bearTP / 100)
    new_tp_line = line.new(bar_index, bearTpLineLevel, bar_index + tp_length, bearTpLineLevel, xloc=xloc.bar_index, color=tp_line_color, width=tp_line_width, style=tp_line_style)
    array.push(bear_tp_lines, new_tp_line)

// Bands Plot
u1Plot = plot(showDev1 ? u1 : na, color=color.new(dev1Color, fade_alpha), title="Upper 1")
l1Plot = plot(showDev1 ? l1 : na, color=color.new(dev1Color, fade_alpha), title="Lower 1")
u2Plot = plot(showDev2 ? u2 : na, color=color.new(dev2Color, fade_alpha), title="Upper 2")
l2Plot = plot(showDev2 ? l2 : na, color=color.new(dev2Color, fade_alpha), title="Lower 2")
u3Plot = plot(showDev3 ? u3 : na, color=color.new(dev3Color, fade_alpha), title="Upper 3")
l3Plot = plot(showDev3 ? l3 : na, color=color.new(dev3Color, fade_alpha), title="Lower 3")
u4Plot = plot(showDev4 ? u4 : na, color=color.new(dev4Color, fade_alpha), title="Upper 4")
l4Plot = plot(showDev4 ? l4 : na, color=color.new(dev4Color, fade_alpha), title="Lower 4")
u5Plot = plot(showDev5 ? u5 : na, color=color.new(dev5Color, fade_alpha), title="Upper 5")
l5Plot = plot(showDev5 ? l5 : na, color=color.new(dev5Color, fade_alpha), title="Lower 5")

// Fixed fills: use plot IDs + fillgaps=false so fills reset cleanly on anchor change.
fill(vwapPlot, u1Plot, color=color.new(dev1Color, fade_transp(92)), title="VWAP to U1", fillgaps=false)
fill(vwapPlot, l1Plot, color=color.new(dev1Color, fade_transp(92)), title="VWAP to L1", fillgaps=false)
fill(u1Plot, u2Plot, color=color.new(dev2Color, fade_transp(92)), title="U1-U2", fillgaps=false)
fill(l1Plot, l2Plot, color=color.new(dev2Color, fade_transp(92)), title="L1-L2", fillgaps=false)
fill(u2Plot, u3Plot, color=color.new(dev3Color, fade_transp(92)), title="U2-U3", fillgaps=false)
fill(l2Plot, l3Plot, color=color.new(dev3Color, fade_transp(92)), title="L2-L3", fillgaps=false)
fill(u3Plot, u4Plot, color=color.new(dev4Color, fade_transp(93)), title="U3-U4", fillgaps=false)
fill(l3Plot, l4Plot, color=color.new(dev4Color, fade_transp(93)), title="L3-L4", fillgaps=false)
fill(u4Plot, u5Plot, color=color.new(dev5Color, fade_transp(94)), title="U4-U5", fillgaps=false)
fill(l4Plot, l5Plot, color=color.new(dev5Color, fade_transp(94)), title="L4-L5", fillgaps=false)

// Stronger bar coloring
barColorUseAtr = barColorDistanceMode == "ATR" or (barColorDistanceMode == "Auto" and use_atr)
rawDist = math.abs(src - myvwap)
distNorm = barColorUseAtr ? rawDist / math.max(atr_val, syminfo.mintick) : rawDist * 100 / math.max(math.abs(myvwap), syminfo.mintick)

bandLow = math.min(level1, level5)
bandHigh = math.max(level1, level5)

t = math.max(0.0, math.min(1.0, (distNorm - bandLow) / math.max(bandHigh - bandLow, 0.0001)))
tAdj = math.pow(t, barColorContrastPower)
outside = distNorm > bandHigh
boosted = outside ? math.min(1.0, tAdj * barColorOutsideBoost) : tAdj

zone1 = 0.20
zone2 = 0.40
zone3 = 0.60
zone4 = 0.80

baseColor = dev1Color
if boosted <= zone1
    baseColor := color.from_gradient(boosted, 0.0, zone1, dev1Color, dev2Color)
else if boosted <= zone2
    baseColor := color.from_gradient(boosted, zone1, zone2, dev2Color, dev3Color)
else if boosted <= zone3
    baseColor := color.from_gradient(boosted, zone2, zone3, dev3Color, dev4Color)
else if boosted <= zone4
    baseColor := color.from_gradient(boosted, zone3, zone4, dev4Color, dev5Color)
else
    baseColor := color.from_gradient(boosted, zone4, 1.0, dev5Color, barExtremeColor)

colorTransp = math.round((outside ? barColorOutsideTransp : barColorInsideTransp) * (1.0 - boosted))
strongBarColor = color.new(baseColor, colorTransp)

var table bullTable = na
var table bearTable = na

var int bullTotal = 0
var int bullWins = 0
var int bearTotal = 0
var int bearWins = 0

// Trade tracking state.
var bool bullTradeOpen = false
var float bullEntryPrice = na
var float bullTpPrice = na
var float bullSlPrice = na
var int bullEntryBar = na

var bool bearTradeOpen = false
var float bearEntryPrice = na
var float bearTpPrice = na
var float bearSlPrice = na
var int bearEntryBar = na

// Optional reset behavior for any open simulated trades.
if anchor and ignore_open_on_reset
    bullTradeOpen := false
    bullEntryPrice := na
    bullTpPrice := na
    bullSlPrice := na
    bullEntryBar := na
    bearTradeOpen := false
    bearEntryPrice := na
    bearTpPrice := na
    bearSlPrice := na
    bearEntryBar := na

// Enter trades on the same bars where signals fire.
if bullSignal and not bullTradeOpen
    bullTradeOpen := true
    bullEntryPrice := close
    bullTpPrice := tpSource == "VWAP" ? myvwap : bullEntryPrice * (1 + bullTP / 100)
    bullSlPrice := bullEntryPrice * (1 - bullSL / 100)
    bullEntryBar := bar_index

if bearSignal and not bearTradeOpen
    bearTradeOpen := true
    bearEntryPrice := close
    bearTpPrice := tpSource == "VWAP" ? myvwap : bearEntryPrice * (1 - bearTP / 100)
    bearSlPrice := bearEntryPrice * (1 + bearSL / 100)
    bearEntryBar := bar_index

// Evaluate exits starting on the bar after the signal-bar close. If both Target/Stop are hit in one bar, count it as a stop outcome (conservative).
if bullTradeOpen and bar_index > bullEntryBar
    bullHitTp = high >= bullTpPrice
    bullHitSl = low <= bullSlPrice
    if bullHitSl or bullHitTp
        bullTotal += 1
        if bullHitTp and not bullHitSl
            bullWins += 1
        bullTradeOpen := false
        bullEntryPrice := na
        bullTpPrice := na
        bullSlPrice := na
        bullEntryBar := na

if bearTradeOpen and bar_index > bearEntryBar
    bearHitTp = low <= bearTpPrice
    bearHitSl = high >= bearSlPrice
    if bearHitSl or bearHitTp
        bearTotal += 1
        if bearHitTp and not bearHitSl
            bearWins += 1
        bearTradeOpen := false
        bearEntryPrice := na
        bearTpPrice := na
        bearSlPrice := na
        bearEntryBar := na

barcolor(barcOn ? strongBarColor : na)

getPosition(string posStr) =>
    switch posStr
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        => position.top_left

if barstate.islast
    // Bull table
    if showBullTable
        bull_h = bullHOffset
        bull_v = bullVOffset
        bull_cols = 4 + bull_h
        bull_rows = 1 + bull_v
        if na(bullTable)
            bullTable := table.new(getPosition(bullPosStr), bull_cols, bull_rows, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.clear(bullTable, 0, 0, bull_cols - 1, bull_rows - 1)
        bullWinRate = bullTotal > 0 ? bullWins * 100.0 / bullTotal : 0.0
        bullLosses = bullTotal - bullWins
        table.cell(bullTable, bull_h, bull_v, "Bull", text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.gray, 80))
        table.cell(bullTable, 1 + bull_h, bull_v, "T:" + str.tostring(bullWins), text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.green, 80))
        table.cell(bullTable, 2 + bull_h, bull_v, "S:" + str.tostring(bullLosses), text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.red, 80))
        table.cell(bullTable, 3 + bull_h, bull_v, str.tostring(bullWinRate, "#.##") + "%", text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.gray, 80))
    else
        if not na(bullTable)
            table.delete(bullTable)
            bullTable := na

    // Bear table
    if showBearTable
        bear_h = bearHOffset
        bear_v = bearVOffset
        bear_cols = 4 + bear_h
        bear_rows = 1 + bear_v
        if na(bearTable)
            bearTable := table.new(getPosition(bearPosStr), bear_cols, bear_rows, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.clear(bearTable, 0, 0, bear_cols - 1, bear_rows - 1)
        bearWinRate = bearTotal > 0 ? bearWins * 100.0 / bearTotal : 0.0
        bearLosses = bearTotal - bearWins
        table.cell(bearTable, bear_h, bear_v, "Bear", text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.gray, 80))
        table.cell(bearTable, 1 + bear_h, bear_v, "T:" + str.tostring(bearWins), text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.green, 80))
        table.cell(bearTable, 2 + bear_h, bear_v, "S:" + str.tostring(bearLosses), text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.red, 80))
        table.cell(bearTable, 3 + bear_h, bear_v, str.tostring(bearWinRate, "#.##") + "%", text_color=presetWhite, text_size=size.small, bgcolor=color.new(color.gray, 80))
    else
        if not na(bearTable)
            table.delete(bearTable)
            bearTable := na
````
