# Volume Weighted RSI PRO | Anonycryptous

- url: https://www.tradingview.com/script/oWzfo668-Volume-Weighted-RSI-PRO-Anonycryptous/
- type: indicator
- pine_id: PUB;bb70dade35df46c39d35947fdd4e4b58
- version: 3.0

## Description

Volume Weighted RSI Pro | Anonycryptous
Description & user manual

Why this indicator is different
Standard RSI treats every bar equally. A bar where 100 lots traded and a bar where 100,000 lots traded produce the same RSI value if the price change was the same. That is a fundamental problem. Price moves on low volume are noise. Price moves on high volume are institutional participation. RSI cannot tell the difference.

Volume Weighted RSI Pro fixes this at the calculation level.
Instead of averaging raw price changes, every gain and loss is multiplied by its relative volume before entering the RSI calculation. A strong move on elevated volume pushes the oscillator harder than the same move on thin participation. A drift in price on below-average volume barely registers. The result is an RSI that reflects who was actually behind the move — not just that a move happened.
But volume-weighted RSI alone is one perspective. The indicator adds a second independent layer through the Money Flow Index — a separate oscillator that weights typical price by volume rather than price change. When both VW RSI and MFI agree on an extreme reading, the confluence is structurally different from either line alone. One can be driven by a single large candle. Two separate calculation methods arriving at the same conclusion is harder to dismiss.

And then there are the liquidity levels.
Most RSI-based indicators live in isolation from price structure. They show you when the oscillator is extended, but not where on the price chart that extension corresponds to meaningful levels. Volume Weighted RSI Pro draws the nearest swing highs and lows directly on the price chart — the levels where stops cluster, where institutions defend positions, and where reversals tend to form. Each level shows the volume ratio at the moment it was created. Each level disappears automatically when price closes through it, and the indicator immediately identifies the next relevant level below or above.
The divergence engine connects oscillator behavior with price structure by drawing lines, endpoint markers, and a highlighted box on the price chart that spans the exact bars involved. Not just a signal — a spatial map of what happened and where.
This is an RSI indicator that knows where it is on the chart.

Important notice
Volume Weighted RSI Pro generates signals based on oscillator behavior, volume analysis, and price structure detection.
These signals are not financial advice.
They do not predict future price movement.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Volume Weighted RSI Pro is a multi-layer oscillator built around a volume-weighted RSI calculation. It combines momentum analysis, divergence detection, volume flow confirmation, and liquidity level mapping in a single indicator across both the oscillator pane and the price chart.

What it includes:
- Volume weighted RSI using relative volume to scale price change contributions
- Money Flow Index as a second independent momentum layer
- EMA signal line with configurable length and crossover markers
- Divergence detection with RSI pane lines and mainchart box visualization
- Liquidity level lines on the price chart from confirmed swing highs and lows
- Volume ratio label per liquidity level showing institutional activity at formation
- Automatic level mitigation: levels disappear when price closes through them
- OB/OS zone boxes with per-zone volume intensity tracking
- Gradient glow fill between the RSI line and midline
- OB/OS exit signals and signal line crossover markers
- Bar coloring and mainchart background based on RSI position
- Live dashboard with RSI value, volume ratio, zone, divergence, signal, and liquidity levels
- Seven alerts covering divergence, exits, and signal line crossovers

2. Core calculation
2.1 Volume weighted RSI
Standard RSI sums gains and losses over a lookback period using Wilder's smoothing (RMA). Volume Weighted RSI Pro applies the same structure but multiplies each bar's price change by its relative volume — the ratio of bar volume to the smoothed volume average — before the RMA smoothing step.
A bar with twice the average volume contributes twice as much to the gain or loss accumulation. A bar with half the average volume contributes half as much. This means the oscillator level reflects participation quality, not just price displacement. In practical terms: trending moves on rising volume push the oscillator to extremes faster. Pullbacks on thin volume barely move it. This creates a cleaner, more institutionally-aware reading than standard RSI.
The volume weighted mode can be toggled off to revert to standard RSI behavior for direct comparison.

2.2 Standard RSI reference line
A standard RSI line is plotted as a secondary reference in the same pane. Its color and width are configurable. Divergence between the volume weighted and standard lines reveals moments where volume is distorting the picture — a large move on thin participation that standard RSI registers but the VW version largely ignores, or vice versa.

2.3 Signal line
An EMA of the volume weighted RSI value acts as a signal line, similar in concept to the signal line in a MACD. The default length is 9. When the VW RSI crosses above the signal line, momentum is accelerating to the upside. When it crosses below, momentum is decelerating. Crossover markers appear at the exact cross point and can be toggled on or off. The signal line is most useful as a filter — only take a setup if the RSI and signal line agree on direction.

2.4 Money Flow Index
The MFI is calculated using typical price ((high + low + close) / 3) multiplied by volume, producing separate positive and negative money flow sums that are then converted to an index between 0 and 100. It shares the same scale as the VW RSI, making direct visual comparison possible.
The MFI responds differently from VW RSI because it weights price level rather than price change. Elevated MFI without elevated VW RSI suggests buying pressure at current levels without strong directional momentum. Both indicators in overbought territory simultaneously is a stronger condition than either alone.

3. Divergence detection
Divergence is detected by comparing pivots in the volume weighted RSI against pivots in price over a configurable lookback window
Bearish divergence: price makes a higher high while VW RSI makes a lower high. Momentum is weakening as price extends — a structural warning.
Bullish divergence: price makes a lower low while VW RSI makes a higher low. Selling pressure is exhausting even as price continues lower — a structural opportunity.
Sensitivity controls the pivot lookback window:
- High: 3-bar pivots. More signals, more false positives.
- Medium: 5-bar pivots. Balanced default.
- Low: 10-bar pivots. Fewer signals, higher quality.

When a divergence confirms, two things are drawn simultaneously. In the RSI pane: a solid line connecting the two pivot RSI values. On the price chart: a box spanning the full price range of the bars involved in the divergence. This makes the spatial relationship between the oscillator event and the price structure immediately visible.
The divergence box does not confirm a trade. It confirms that a structural disagreement between price and momentum occurred, and where on the chart it happened.

4. Liquidity levels
Liquidity levels are drawn on the price chart at confirmed swing highs and lows using a pivot detection engine. They represent the price levels where stop orders are likely to cluster — below swing lows for buy stops and above swing highs for sell stops. These are the levels that institutional participants use as targets when running liquidity.
Each level is a horizontal line that starts at the pivot bar and extends to the right in real time. The nearest level is fully opaque. Additional levels fade with distance from current price.
Each level displays a volume ratio label at its origin — the bar's volume at the time of pivot formation relative to the recent average. A level formed on 2.1x average volume is more institutionally significant than one formed on 0.7x volume. This context is part of reading the level.
When price closes through a level, it is removed immediately. The indicator repopulates from the remaining valid pivots. There is no manual cleanup and no visual clutter from levels that have already been swept.
The detail level setting controls how aggressively levels are detected:
- Minimal: wide pivot lookback, only the most significant structural highs and lows qualify.
- Standard: balanced detection, practical default across most timeframes.
- Full: tighter pivot lookback, more levels are identified.
The dashboard shows the nearest bull side level (BSL) and bear side level (SSL) by price, updated in real time.

5. OB/OS zone tracking
When the VW RSI enters overbought or oversold territory, the indicator begins accumulating the total volume transacted during that period. When price exits the zone, a filled box is drawn over the duration of the zone on the RSI pane.
The box includes a volume intensity label showing how the average volume inside the zone compared to the baseline average. A zone with 1.8x average volume indicates elevated institutional activity during the extreme reading — the extension was not just price drift but active participation. A zone below 1.0x is thin and less meaningful.
OB/OS zones are off by default.

6. Visual guide
RSI pane elements:
- Bright green/red RSI line — volume weighted RSI, color intensity increases toward OB/OS extremes
- Grey reference line — standard RSI, configurable color and width
- Gold line — signal line (EMA of VW RSI)
- Purple line — MFI
- Gradient glow fill — color intensity increases from midline toward the RSI line, creating a visual depth effect that reflects how extended the oscillator is
- OB/OS background — deepens in red or green when RSI is in extreme territory
- ▲ marker — RSI exiting oversold territory
- ▼ marker — RSI exiting overbought territory
- ✕ marker — RSI/signal line crossover (when enabled)
- Divergence line — solid colored line between the two pivot RSI values

Mainchart elements:
- Horizontal lines — liquidity levels, color and opacity by distance from current price
- Volume label at origin — volume ratio at pivot formation bar
- Divergence box — spans the full price range of the divergence bars
- Background color — subtle green above RSI 50, subtle red below
- Bar coloring — gradient intensity based on RSI position

7. Dashboard reference
The dashboard is positioned bottom right by default and updates on every bar close.
VW RSI — current VW RSI value, colored by position.
Vol ratio — current bar volume relative to the smoothed average. Values above 1.5x are highlighted in gold.
Zone — current RSI zone: overbought, oversold, or neutral.
Divergence — active divergence state if detected on the most recent pivot.
Signal — most recent signal condition.
— Liquidity —
Near BSL — nearest bull side liquidity level below current price.
Near SSL — nearest sell side liquidity level above current price.
Liq levels — count of active levels on each side.
Mode — VW (volume weighted) or STD (standard RSI mode).
Anonycryptous — indicator brand and version.

8. Alerts
Seven alert conditions are available:
- Bullish divergence: price lower low with VW RSI higher low confirmed.
- Bearish divergence: price higher high with VW RSI lower high confirmed.
- OS exit signal: RSI crosses back above the oversold level.
- OB exit signal: RSI crosses back below the overbought level.
- Any divergence: fires on either divergence type.
- Signal cross up: VW RSI crosses above the signal line.
- Signal cross down: VW RSI crosses below the signal line.

9. Settings reference
9.1 RSI settings
- RSI length: lookback period for the VW RSI calculation. Default 14.
- Volume smoothing: lookback for the volume moving average. Default 14.
- Volume weighted mode: toggle between volume weighted and standard RSI.
- Show signal line: toggle the EMA signal line.
- Signal line length: EMA period for the signal line. Default 9.
- Show signal crossovers: toggle ✕ markers at signal line crossovers. Default off.
- Show MFI line: toggle the Money Flow Index line.
- MFI length: lookback for MFI calculation. Default 14.
- MFI color: default brand purple.
- MFI line width: 1 to 4. Default 2.
- Overbought level: threshold for OB signals and zone tracking. Default 70.
- Oversold level: threshold for OS signals and zone tracking. Default 30.

9.2 Divergence
- Sensitivity: pivot lookback window — high (3), medium (5), low (10).
- Show bullish divergence.
- Show bearish divergence.
- Divergence box on mainchart: draws the price range box on the price chart.
- Div line width: stroke weight of divergence lines. 1 to 4. Default 2.

9.3 Liquidity levels
- Show liquidity levels: toggle all liquidity lines on the price chart.
- Detail level: minimal, standard, or full pivot sensitivity.
- Pivot lookback: swing detection window. Default 10.
- Max levels each side: maximum lines shown above and below current price. Default 2.

9.4 OB/OS zones
- Show OB/OS zones: toggle zone boxes in the RSI pane. Default off.
- Volume intensity label: show per-zone volume ratio label.
- Zone transparency: fill opacity for OB/OS zone boxes.

9.5 Visuals
- Bull color: primary bull color across all elements.
- Bear color: primary bear color across all elements.
- Bull div color: color for bullish divergence lines and box.
- Bear div color: color for bearish divergence lines and box.
- Std RSI color: color of the standard RSI reference line.
- Std RSI width: stroke weight of the reference line.
- Bar coloring: gradient bar color based on RSI position.
- Signal size: size of OB/OS exit markers — tiny, small, or normal.
- Show background color: subtle mainchart background based on RSI direction.
- Background transparency: opacity of the mainchart background.

9.6 Dashboard
- Show dashboard.
- Position: top left, top right, bottom left, or bottom right.
- Size: tiny, small, or normal.

10. How to use
10.1 Reading divergence
Divergence is not a signal to enter immediately. It is a warning that the relationship between momentum and price is breaking down. The most effective approach is to wait for the divergence box to appear on the price chart and then look for a second confirmation — a signal line crossover, an OB/OS exit marker, or a price reaction at a nearby liquidity level — before treating the setup as actionable.
Divergence on its own can persist for many bars before price reacts. Use it as directional context, not as a trigger.

10.2 Using liquidity levels
The liquidity lines show where the market has unfinished business — swing levels that formed on meaningful volume and have not yet been revisited. When the VW RSI is approaching overbought or showing bearish divergence and price is simultaneously approaching a sell-side liquidity level above, those two conditions are pointing at the same structural event from different angles.
The volume ratio label at each level is particularly useful. A level formed on 0.6x average volume is a weak level that may not generate a meaningful reaction. A level formed on 2.5x average volume suggests a move was initiated or defended with institutional size. Treat these differently.

10.3 Using VW RSI and MFI together
When both lines are in overbought territory simultaneously, the condition is stronger than either alone. VW RSI is extended on momentum. MFI confirms that money flow at current price levels is also elevated. The two calculations are independent — their agreement is not trivial.
When they diverge — VW RSI overbought while MFI is not — one of the components is not confirming the other. This does not mean the move is wrong, but the confluence is weaker.

10.4 OB/OS zone volume
When the zone volume label shows above 1.5x, the extreme RSI reading occurred during elevated participation. That tells you the extension was not just mechanical drift — there was active buying or selling pressure behind it. An exit from that zone after a high-volume OB/OS period carries more weight than an exit from a thin zone.

10.5 Illustrative bull scenario
Educational example only. Not a trading recommendation.
VW RSI drops into oversold on above-average volume. A bull-side liquidity level sits 0.8% below current price, formed three sessions ago on 2.1x volume. VW RSI begins making a higher low while price makes a lower low — bullish divergence is confirmed. A divergence box appears on the price chart. The RSI crosses back above the oversold level, firing a ▲ marker. The signal line crossover fires shortly after. Three separate conditions align: oversold exit, bullish divergence, and signal line confirmation.

10.6 Illustrative bear scenario
Educational example only. Not a trading recommendation.
Price rallies into a sell-side liquidity level visible on the chart at 2.2x formation volume. VW RSI is in overbought territory while MFI is also elevated. Price makes a higher high but VW RSI makes a lower high — bearish divergence is drawn on the RSI pane and a box appears on the price chart covering the divergence range. RSI crosses back below overbought. A ▼ marker fires. The setup has divergence, OB exit, and a liquidity level all at the same location.

11. Tips
The volume ratio in the dashboard is one of the most underused readings. A vol ratio below 0.7 means current price action is thin — institutions are not participating. Signals that fire on low volume ratio are less reliable than those that fire on 1.5x or above.
Signal line crossovers are most useful as filters. Toggle them on during active sessions to see where momentum flips are occurring relative to the rest of the setup. Too many crossovers on a given session usually means the market is ranging — reduce position size or wait for the RSI to expand toward an extreme before taking the cross seriously.
The standard RSI reference line reveals when volume weighting is changing the picture. If the VW RSI is significantly above the standard line, it means recent price movement was driven by above-average volume. If the VW RSI is below the standard line, price moved on thin participation — the market did not commit to the direction.
Liquidity level count in the dashboard tells you how many valid structural references remain. When the count drops — because levels are being swept — it means the market is clearing stops. That is meaningful context for the direction of the current move.

12. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document or in the indicator output constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator("Volume Weighted RSI PRO | Anonycryptous", shorttitle="VW RSI Pro", overlay = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════
// VW RSI Pro | Anonycryptous
// Volume Weighted RSI · Divergence · Liquidity Levels · Dashboard
// ═══════════════════════════════════════════════════════════════

// ─── Groups ───────────────────────────────────────────────────
string G_RSI  = "RSI Settings"
string G_DIV  = "Divergence"
string G_LIQ  = "Liquidity Levels"
string G_OBOS = "OB / OS Zones"
string G_VIS  = "Visuals"
string G_DASH = "Dashboard"

// ─── RSI ──────────────────────────────────────────────────────
int   i_rsiLen  = input.int(14,      "RSI Length",            minval=1,  group=G_RSI, tooltip="Number of bars used to calculate the RSI. Default 14. Lower = faster, more noise. Higher = slower, smoother.")
int   i_volLen  = input.int(14,      "Volume Smoothing",      minval=1,  group=G_RSI, tooltip="Lookback for the volume moving average used to normalize per-bar volume. Higher = smoother vol ratio, less reactive.")
bool  i_volWt   = input.bool(true,   "Volume Weighted Mode",             group=G_RSI, tooltip="When ON, price changes are weighted by relative volume before RSI calculation. Higher volume bars have more influence. When OFF, behaves like standard RSI.")
bool  i_showSig  = input.bool(true,  "Show Signal Line",             group=G_RSI, tooltip="Plots an EMA of the VW RSI as a signal line. Crossovers between RSI and signal line are early entry confirmation — especially powerful when combined with divergence.")
int   i_sigLen   = input.int(9,       "Signal Line Length", minval=1,  group=G_RSI, tooltip="EMA length for the signal line. Default 9 — similar to MACD signal. Lower = faster crossovers, more noise.")
bool  i_showCross = input.bool(false, "Show Signal Crossovers",      group=G_RSI, tooltip="Show ✕ markers where VW RSI crosses the signal line. Default off — can get busy on lower timeframes.")
bool  i_showMfi  = input.bool(true,  "Show MFI Line",               group=G_RSI, tooltip="Plots the Money Flow Index as a second line in the RSI pane. MFI uses typical price × volume — a different angle than VW RSI. Confluence when both agree on OB/OS.")
int   i_mfiLen   = input.int(14,     "MFI Length",       minval=1,  group=G_RSI, tooltip="Lookback period for the Money Flow Index calculation. Default 14 matches the RSI length for direct comparison.")
color i_mfiCol   = input.color(color.rgb(116, 3, 254), "MFI Color", group=G_RSI, tooltip="Color of the MFI line. Default brand purple to clearly distinguish it from the VW RSI line.")
int   i_mfiWidth = input.int(2,      "MFI Line Width",   minval=1, maxval=4, group=G_RSI, tooltip="Stroke width of the MFI line. Default 2.")
float i_ob      = input.float(75.0,  "Overbought Level",                 group=G_RSI, tooltip="RSI level considered overbought. Signals and OB zone boxes trigger above this level.")
float i_os      = input.float(25.0,  "Oversold Level",                   group=G_RSI, tooltip="RSI level considered oversold. Signals and OS zone boxes trigger below this level.")

// ─── Divergence ───────────────────────────────────────────────
string i_divSens  = input.string("Low", "Sensitivity", options=["High","Medium","Low"], group=G_DIV, tooltip="Controls the pivot lookback window for divergence detection. High = pivot window 3 bars (more signals, more noise). Medium = 5 bars. Low = 10 bars (fewer but higher quality signals).")
bool  i_showBull  = input.bool(true,  "Show Bullish Divergence",  group=G_DIV, tooltip="Show bullish divergence: price makes lower low while RSI makes higher low. Potential reversal up.")
bool  i_showBear  = input.bool(true,  "Show Bearish Divergence",  group=G_DIV, tooltip="Show bearish divergence: price makes higher high while RSI makes lower high. Potential reversal down.")
bool  i_divBox    = input.bool(true,  "Divergence Box (mainchart)", group=G_DIV, tooltip="Draws a solid box on the price chart highlighting the price range spanned by the divergence. Uses force_overlay.")
int   i_divWidth  = input.int(1,      "Div Line Width", minval=1, maxval=4, group=G_DIV, tooltip="Stroke width of the divergence lines on the RSI pane. 1 = thin, 4 = thick.")

// ─── Liquidity Levels ─────────────────────────────────────────
bool  i_showLiq   = input.bool(true,  "Show Liquidity Levels",     group=G_LIQ, tooltip="Show horizontal liquidity lines on the price chart at recent swing highs and lows. These represent areas where stop orders likely cluster.")
string i_liqMode  = input.string("Standard", "Detail Level", options=["Minimal","Standard","Full"], group=G_LIQ, tooltip="Controls how many liquidity levels are shown. Minimal = 2 levels, larger pivot window. Standard = up to Max Levels. Full = smaller pivot window, up to Max Levels.")
int   i_liqLen    = input.int(10,    "Pivot Lookback",  minval=3,  group=G_LIQ, tooltip="Pivot lookback window for detecting swing highs and lows used as liquidity levels. Higher = fewer but more significant levels.")
int   i_liqMax    = input.int(5,     "Max Levels Each Side", minval=1, maxval=10, group=G_LIQ, tooltip="Maximum number of liquidity levels shown above (SSL) and below (BSL) current price. Nearest level is always most opaque.")
float i_liqATR    = input.float(0.3, "ATR Line Width",            group=G_LIQ, tooltip="Reserved for future use. ATR-based proximity detection for level merging.")

// ─── OB/OS Zones ──────────────────────────────────────────────
bool  i_showOBOS  = input.bool(false, "Show OB/OS Zones",           group=G_OBOS, tooltip="Draw filled boxes on the RSI pane marking periods when RSI was in overbought or oversold territory. Box is finalized when RSI exits the zone.")
bool  i_volLabel  = input.bool(true, "Volume Intensity Label",     group=G_OBOS, tooltip="Show a volume multiplier label on each OB/OS zone. Value shows average bar volume inside the zone vs the 14-bar average. >1.5x = elevated activity.")
int   i_obosTransp= input.int(82,    "Zone Transparency", minval=50, maxval=95, group=G_OBOS, tooltip="Transparency of the OB/OS zone fill. Higher = more transparent. Core and glow layers are drawn separately.")

// ─── Visuals ──────────────────────────────────────────────────
color i_bullCol   = input.color(color.rgb(0,  255, 0),   "Bull Color",  group=G_VIS, tooltip="Primary bull color. Used for RSI plot gradient, bar coloring, oversold signals, and bullish liquidity levels.")
color i_bearCol   = input.color(color.rgb(255, 0,  0),   "Bear Color",  group=G_VIS, tooltip="Primary bear color. Used for RSI plot gradient, bar coloring, overbought signals, and bearish liquidity levels.")
color i_divBullC  = input.color(color.rgb(0,  255, 0),   "Bull Div Color", group=G_VIS, tooltip="Color for bullish divergence lines, dots, and box.")
color i_divBearC  = input.color(color.rgb(255, 0,   0),  "Bear Div Color", group=G_VIS, tooltip="Color for bearish divergence lines, dots, and box.")
bool  i_barCol    = input.bool(true,  "Bar Coloring",               group=G_VIS, tooltip="Color price bars based on RSI position. Gradient intensity increases toward OB/OS extremes.")
string i_sigSize  = input.string("Tiny",  "Signal Size", options=["Tiny","Small","Normal"], group=G_VIS, tooltip="Size of the plotshape signal markers on the RSI pane. Triangles = OB/OS exits.")
color i_stdRsiCol = input.color(color.new(#8b949e, 30), "Std RSI Color",  group=G_VIS, tooltip="Color of the standard RSI reference line in the RSI pane.")
int   i_stdRsiW  = input.int(1, "Std RSI Width", minval=1, maxval=4,          group=G_VIS, tooltip="Stroke width of the standard RSI reference line. Default 2.")
bool  i_showBg    = input.bool(true,  "Show Background Color (mainchart)", group=G_VIS, tooltip="Paints a subtle bull/bear background on the price chart based on VW RSI position relative to midline 50.")
int   i_bgTransp  = input.int(93,    "Background Transparency", minval=80, maxval=99, group=G_VIS, tooltip="Transparency of the mainchart background color. Higher = more subtle.")

// ─── Dashboard ────────────────────────────────────────────────
bool   i_showDash = input.bool(true,   "Show Dashboard",            group=G_DASH)
string i_dashPos  = input.string("Bottom Right", "Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"],   group=G_DASH)
string i_dashSz   = input.string("Tiny", "Size", options=["Tiny","Small","Normal"], group=G_DASH)
int    i_divHold  = input.int(10, "Divergence / signal hold (bars)", minval=1, maxval=50, group=G_DASH,
    tooltip="How many bars the Divergence and Signal rows stay visible in the dashboard after firing. Default 10. Set to 1 for single-bar only.")

// ─── Colors ───────────────────────────────────────────────────
color C_GOLD  = #f5c518
color C_PURP  = #bb86fc
color C_BG    = color.new(#0d1117, 10)
color C_PANEL = color.new(#161b22, 0)
color C_BDR   = color.new(#30363d, 20)
color C_MUTED = color.new(#8b949e, 0)
color C_WHITE = color.new(#ffffff, 0)

// ─── Signal Size ──────────────────────────────────────────────
// plotshape size must be constant — resolved via three separate plots below

// ─── Volume Weighted RSI ──────────────────────────────────────
float priceChange  = ta.change(close)
float volSma       = ta.sma(volume, i_volLen)
float volRatio     = volume / volSma

// Volume weighted gains/losses
float wtGain = i_volWt ? math.max(priceChange, 0) * volRatio : math.max(priceChange, 0)
float wtLoss = i_volWt ? math.max(-priceChange, 0) * volRatio : math.max(-priceChange, 0)

float avgGain = ta.rma(wtGain, i_rsiLen)
float avgLoss = ta.rma(wtLoss, i_rsiLen)
float rs      = avgLoss == 0 ? 100 : avgGain / avgLoss
float vwRsi   = 100 - 100 / (1 + rs)

// Signal line — EMA of vwRsi
float sigLine = ta.ema(vwRsi, i_sigLen)

// Money Flow Index
float typPrice = (high + low + close) / 3
float rawMF    = typPrice * volume
float posMF    = typPrice > typPrice[1] ? rawMF : 0
float negMF    = typPrice < typPrice[1] ? rawMF : 0
float mfRatio  = ta.sma(posMF, i_mfiLen) / math.max(ta.sma(negMF, i_mfiLen), 1)
float mfi      = 100 - 100 / (1 + mfRatio)

// Standard RSI for comparison reference
float stdRsi  = ta.rsi(close, i_rsiLen)

// ─── Pivot Window ─────────────────────────────────────────────
int pivWin = switch i_divSens
    "High"   => 3
    "Medium" => 5
    => 10

// ─── Pivot Detection (always top-level) ───────────────────────
float pivH = ta.pivothigh(vwRsi, pivWin, pivWin)
float pivL = ta.pivotlow(vwRsi,  pivWin, pivWin)

float pivHPrice = ta.pivothigh(high, pivWin, pivWin)
float pivLPrice = ta.pivotlow(low,   pivWin, pivWin)

// Liquidity pivot detection (always top-level)
int liqPivLenMin = i_liqMode == "Minimal" ? i_liqLen + 4 : i_liqMode == "Full" ? math.max(i_liqLen - 3, 3) : i_liqLen
float liqPivH = ta.pivothigh(high, liqPivLenMin, liqPivLenMin)
float liqPivL = ta.pivotlow(low,   liqPivLenMin, liqPivLenMin)

// ATR (always top-level)
float atrVal  = ta.atr(14)

// ─── Divergence State ─────────────────────────────────────────
var float lastPivHRsi   = na
var float lastPivLRsi   = na
var float lastPivHPrice = na
var float lastPivLPrice = na
var int   lastPivHBar   = na
var int   lastPivLBar   = na

// Dashboard hold counters — count down from i_divHold after div/signal fires
var int divBullHold = 0
var int divBearHold = 0
var int sigBullHold = 0
var int sigBearHold = 0

bool isBearDiv = false
if not na(pivH)
    if not na(lastPivHRsi) and vwRsi[pivWin] < lastPivHRsi and high[pivWin] > lastPivHPrice
        isBearDiv := true
    lastPivHRsi   := vwRsi[pivWin]
    lastPivHPrice := high[pivWin]
    lastPivHBar   := bar_index - pivWin

bool isBullDiv = false
if not na(pivL)
    if not na(lastPivLRsi) and vwRsi[pivWin] > lastPivLRsi and low[pivWin] < lastPivLPrice
        isBullDiv := true
    lastPivLRsi   := vwRsi[pivWin]
    lastPivLPrice := low[pivWin]
    lastPivLBar   := bar_index - pivWin

// ─── Divergence / Signal Hold Countdown ───────────────────────
if isBullDiv
    divBullHold := i_divHold
    sigBullHold := i_divHold
else if divBullHold > 0
    divBullHold := divBullHold - 1

if isBearDiv
    divBearHold := i_divHold
    sigBearHold := i_divHold
else if divBearHold > 0
    divBearHold := divBearHold - 1

// ─── Liquidity Level Arrays ───────────────────────────────────
// Each entry: [price, bar_index_of_pivot, vol_ratio_at_pivot]
var array<float> liqHighs    = array.new_float(0)
var array<float> liqHighBars = array.new_float(0)
var array<float> liqHighVols = array.new_float(0)
var array<float> liqLows     = array.new_float(0)
var array<float> liqLowBars  = array.new_float(0)
var array<float> liqLowVols  = array.new_float(0)
var array<line>  liqHLines   = array.new_line(0)
var array<line>  liqLLines   = array.new_line(0)

int maxLiq = i_liqMode == "Minimal" ? 2 : i_liqMode == "Full" ? i_liqMax : math.min(i_liqMax, 5)

if i_showLiq and not na(liqPivH)
    float lvl     = high[liqPivLenMin]
    float pivBar  = bar_index - liqPivLenMin
    float pivVol  = volume[liqPivLenMin] / nz(volSma[liqPivLenMin], 1)
    array.unshift(liqHighs,    lvl)
    array.unshift(liqHighBars, pivBar)
    array.unshift(liqHighVols, pivVol)
    if array.size(liqHighs) > maxLiq
        array.pop(liqHighs)
        array.pop(liqHighBars)
        array.pop(liqHighVols)

if i_showLiq and not na(liqPivL)
    float lvl     = low[liqPivLenMin]
    float pivBar  = bar_index - liqPivLenMin
    float pivVol  = volume[liqPivLenMin] / nz(volSma[liqPivLenMin], 1)
    array.unshift(liqLows,    lvl)
    array.unshift(liqLowBars, pivBar)
    array.unshift(liqLowVols, pivVol)
    if array.size(liqLows) > maxLiq
        array.pop(liqLows)
        array.pop(liqLowBars)
        array.pop(liqLowVols)

// ─── Liquidity Mitigation — remove swept levels ──────────────
// SSL (highs) — broken when close crosses above
if i_showLiq and array.size(liqHighs) > 0
    int i = array.size(liqHighs) - 1
    while i >= 0
        if close > array.get(liqHighs, i)
            array.remove(liqHighs, i)
            array.remove(liqHighBars, i)
            array.remove(liqHighVols, i)
        i := i - 1

// BSL (lows) — broken when close crosses below
if i_showLiq and array.size(liqLows) > 0
    int j = array.size(liqLows) - 1
    while j >= 0
        if close < array.get(liqLows, j)
            array.remove(liqLows, j)
            array.remove(liqLowBars, j)
            array.remove(liqLowVols, j)
        j := j - 1

// ─── OB/OS Zone Tracking ──────────────────────────────────────
var bool  inOB        = false
var bool  inOS        = false
var int   obStartBar  = na
var int   osStartBar  = na
var float obVol       = 0.0
var float osVol       = 0.0
var int   obVolCount  = 0
var int   osVolCount  = 0

bool enteredOB = vwRsi >= i_ob and vwRsi[1] < i_ob
bool enteredOS = vwRsi <= i_os and vwRsi[1] > i_os
bool exitedOB  = vwRsi <  i_ob and vwRsi[1] >= i_ob
bool exitedOS  = vwRsi >  i_os and vwRsi[1] <= i_os

if enteredOB
    inOB       := true
    obStartBar := bar_index
    obVol      := 0.0
    obVolCount := 0
if enteredOS
    inOS       := true
    osStartBar := bar_index
    osVol      := 0.0
    osVolCount := 0

if inOB
    obVol      := obVol + volume
    obVolCount := obVolCount + 1
if inOS
    osVol      := osVol + volume
    osVolCount := osVolCount + 1

// ─── Zone Boxes Draw ──────────────────────────────────────────
// OB zone: drawn when exiting OB
if i_showOBOS and exitedOB and not na(obStartBar)
    float avgZoneVol  = obVolCount > 0 ? obVol / obVolCount : na
    float volMult     = not na(avgZoneVol) ? avgZoneVol / volSma : 1.0
    int   transCore   = i_obosTransp
    int   transGlow   = math.min(transCore + 6, 98)
    color zBearCore   = color.new(i_bearCol, transCore)
    color zBearGlow   = color.new(i_bearCol, transGlow)
    // Glow layer
    box.new(obStartBar, i_ob + (100 - i_ob) * 0.4, bar_index, i_ob,
        border_color = color.new(i_bearCol, 70), bgcolor = zBearGlow,
        border_width = 1, border_style = line.style_solid)
    // Core layer
    box.new(obStartBar, i_ob + (100 - i_ob) * 0.25, bar_index, i_ob,
        border_color = color.new(i_bearCol, 30), bgcolor = zBearCore,
        border_width = 1, border_style = line.style_solid)
    if i_volLabel and not na(avgZoneVol)
        string volTxt = str.tostring(math.round(volMult, 1)) + "x vol"
        label.new(obStartBar, i_ob + (100 - i_ob) * 0.3, volTxt,
            style = label.style_label_right, color = color.new(i_bearCol, 60),
            textcolor = C_WHITE, size = size.tiny)
    inOB := false

if i_showOBOS and exitedOS and not na(osStartBar)
    float avgZoneVol  = osVolCount > 0 ? osVol / osVolCount : na
    float volMult     = not na(avgZoneVol) ? avgZoneVol / volSma : 1.0
    int   transCore   = i_obosTransp
    int   transGlow   = math.min(transCore + 6, 98)
    color zBullCore   = color.new(i_bullCol, transCore)
    color zBullGlow   = color.new(i_bullCol, transGlow)
    box.new(osStartBar, i_os, bar_index, i_os - i_os * 0.4,
        border_color = color.new(i_bullCol, 70), bgcolor = zBullGlow,
        border_width = 1, border_style = line.style_solid)
    box.new(osStartBar, i_os, bar_index, i_os - i_os * 0.25,
        border_color = color.new(i_bullCol, 30), bgcolor = zBullCore,
        border_width = 1, border_style = line.style_solid)
    if i_volLabel and not na(avgZoneVol)
        string volTxt = str.tostring(math.round(volMult, 1)) + "x vol"
        label.new(osStartBar, i_os - i_os * 0.3, volTxt,
            style = label.style_label_right, color = color.new(i_bullCol, 60),
            textcolor = C_WHITE, size = size.tiny)
    inOS := false

// ─── Divergence Draw Function ─────────────────────────────────
drawDiv(int x1, float y1, int x2, float y2, color dCol) =>
    line.new(x1, y1, x2, y2, color=color.new(dCol, 0), width=i_divWidth, style=line.style_solid)

if isBearDiv and i_showBear
    drawDiv(lastPivHBar[1], lastPivHRsi[1], bar_index - pivWin, vwRsi[pivWin], i_divBearC)

if isBullDiv and i_showBull
    drawDiv(lastPivLBar[1], lastPivLRsi[1], bar_index - pivWin, vwRsi[pivWin], i_divBullC)


// ─── Divergence Box on Mainchart (force_overlay) ──────────────
if i_divBox and isBearDiv and i_showBear and not na(lastPivHBar[1])
    int   bx1     = lastPivHBar[1]
    int   bx2     = bar_index - pivWin
    float boxTop  = high[bar_index - bx1]
    float boxBot  = low[bar_index - bx1]
    int   spanLen = bx2 - bx1
    for i = 0 to spanLen
        float h = high[spanLen - i]
        float l = low[spanLen - i]
        if h > boxTop
            boxTop := h
        if l < boxBot
            boxBot := l
    box.new(bx1, boxTop, bx2, boxBot,
        border_color = color.new(i_divBearC, 40),
        border_style = line.style_solid,
        bgcolor      = color.new(i_divBearC, 90),
        border_width = 1,
        force_overlay = true)

if i_divBox and isBullDiv and i_showBull and not na(lastPivLBar[1])
    int   bx1     = lastPivLBar[1]
    int   bx2     = bar_index - pivWin
    float boxTop  = high[bar_index - bx1]
    float boxBot  = low[bar_index - bx1]
    int   spanLen = bx2 - bx1
    for i = 0 to spanLen
        float h = high[spanLen - i]
        float l = low[spanLen - i]
        if h > boxTop
            boxTop := h
        if l < boxBot
            boxBot := l
    box.new(bx1, boxTop, bx2, boxBot,
        border_color = color.new(i_divBullC, 40),
        border_style = line.style_solid,
        bgcolor      = color.new(i_divBullC, 90),
        border_width = 1,
        force_overlay = true)

// ─── Liquidity Lines on Mainchart ─────────────────────────────
// Rebuild on last bar — lines start from pivot bar, extend right
if i_showLiq and barstate.islast
    if array.size(liqHLines) > 0
        for i = 0 to array.size(liqHLines) - 1
            line.delete(array.get(liqHLines, i))
    array.clear(liqHLines)
    if array.size(liqLLines) > 0
        for i = 0 to array.size(liqLLines) - 1
            line.delete(array.get(liqLLines, i))
    array.clear(liqLLines)

    int nH = array.size(liqHighs)
    if nH > 0
        for i = 0 to nH - 1
            float lvl      = array.get(liqHighs, i)
            int   pivBar   = math.max(int(array.get(liqHighBars, i)), bar_index - 300)
            float pivVol   = array.get(liqHighVols, i)
            int   transp   = i == 0 ? 0 : i == 1 ? 40 : 65
            color liqHCol  = color.new(i_bearCol, transp)
            line l = line.new(pivBar, lvl, bar_index + 3, lvl,
                color         = liqHCol,
                width         = 1,
                style         = line.style_solid,
                force_overlay = true,
                extend        = extend.none)
            array.push(liqHLines, l)
            string volLbl = str.tostring(math.round(pivVol, 1)) + "x"
            label.new(pivBar, lvl, volLbl,
                style         = label.style_label_right,
                color         = color.new(i_bearCol, transp + 20),
                textcolor     = color.new(#ffffff, transp),
                size          = size.tiny,
                force_overlay = true)

    int nL = array.size(liqLows)
    if nL > 0
        for i = 0 to nL - 1
            float lvl      = array.get(liqLows, i)
            int   pivBar   = math.max(int(array.get(liqLowBars, i)), bar_index - 300)
            float pivVol   = array.get(liqLowVols, i)
            int   transp   = i == 0 ? 0 : i == 1 ? 40 : 65
            color liqLCol  = color.new(i_bullCol, transp)
            line l = line.new(pivBar, lvl, bar_index + 3, lvl,
                color         = liqLCol,
                width         = 1,
                style         = line.style_solid,
                force_overlay = true,
                extend        = extend.none)
            array.push(liqLLines, l)
            string volLbl = str.tostring(math.round(pivVol, 1)) + "x"
            label.new(pivBar, lvl, volLbl,
                style         = label.style_label_right,
                color         = color.new(i_bullCol, transp + 20),
                textcolor     = color.new(#ffffff, transp),
                size          = size.tiny,
                force_overlay = true)

// ─── Bar Coloring ─────────────────────────────────────────────
color barC = na
if i_barCol
    if vwRsi > 50
        barC := color.from_gradient(vwRsi, 50, i_ob, color.new(i_bullCol, 75), color.new(i_bullCol, 10))
    else if vwRsi < 50
        barC := color.from_gradient(vwRsi, i_os, 50, color.new(i_bearCol, 10), color.new(i_bearCol, 75))
barcolor(barC)

// ─── Mainchart Background ─────────────────────────────────────
bgcolor(i_showBg ? (vwRsi > 50 ? color.new(i_bullCol, i_bgTransp) : color.new(i_bearCol, i_bgTransp)) : na, force_overlay=true, title="Mainchart BG")

// ─── Signals ──────────────────────────────────────────────────
// OB cross signals (price crossing back from OB/OS)
bool sigBull = exitedOS  // RSI exits oversold → buy signal
bool sigBear = exitedOB  // RSI exits overbought → sell signal

// Signal line crossovers
bool sigCrossUp = ta.crossover(vwRsi,  sigLine)
bool sigCrossDn = ta.crossunder(vwRsi, sigLine)

// Divergence signals (stronger)
bool sigBullDiv = isBullDiv
bool sigBearDiv = isBearDiv

// OB/OS exit signals also feed hold counter
if sigBull and sigBullHold == 0
    sigBullHold := i_divHold
else if not sigBull and not isBullDiv and sigBullHold > 0
    sigBullHold := sigBullHold - 1

if sigBear and sigBearHold == 0
    sigBearHold := i_divHold
else if not sigBear and not isBearDiv and sigBearHold > 0
    sigBearHold := sigBearHold - 1

// ─── Signals ──────────────────────────────────────────────────
// y-waarde meegeven als series — plotchar vereist dat voor location.absolute
float yBearExit  = sigBear                       ? i_ob + 4  : na
float yBullExit  = sigBull                       ? i_os - 4  : na
float yCrossUp   = i_showSig and i_showCross and sigCrossUp ? sigLine : na
float yCrossDn   = i_showSig and i_showCross and sigCrossDn ? sigLine : na

plotchar(yBearExit, "Bear Exit OB",   "▼", location.absolute, i_bearCol,              size=size.tiny)
plotchar(yBullExit, "Bull Exit OS",   "▲", location.absolute, i_bullCol,              size=size.tiny)
plotchar(yCrossUp,  "Sig Cross Up",   "✕", location.absolute, color.new(i_bullCol, 0), size=size.tiny)
plotchar(yCrossDn,  "Sig Cross Dn",   "✕", location.absolute, color.new(i_bearCol, 0), size=size.tiny)

// ─── RSI Plot ─────────────────────────────────────────────────
color rsiPlotCol = vwRsi > 50 ? color.from_gradient(vwRsi, 50, i_ob, color.new(i_bullCol, 40), color.new(i_bullCol, 0)) : color.from_gradient(vwRsi, i_os, 50, color.new(i_bearCol, 0), color.new(i_bearCol, 40))

// Reference plots for fills (hidden)
pOB  = plot(i_ob, display=display.none)
pOS  = plot(i_os, display=display.none)
pMid = plot(50,   display=display.none)
pRsi = plot(vwRsi, "VW RSI", color=rsiPlotCol, linewidth=3)
plot(stdRsi, "RSI (ref)", color=i_stdRsiCol, linewidth=i_stdRsiW)
plot(i_showSig ? sigLine : na, "Signal Line", color=color.new(#f5c518, 20), linewidth=1)
plot(i_showMfi ? mfi : na, "MFI", color=color.new(i_mfiCol, 30), linewidth=i_mfiWidth)

// Glow fill — gradient from midline toward OB zone (bear glow)
fill(pMid, pOB,
    top_value    = i_ob,
    bottom_value = i_ob - 10,
    bottom_color = na,
    top_color    = color.from_gradient(vwRsi, i_os, i_ob, color.new(i_bearCol, 100), color.new(i_bearCol, 35)))

// Glow fill — gradient from midline toward OS zone (bull glow)
fill(pMid, pOS,
    top_value    = i_os + 10,
    bottom_value = i_os,
    bottom_color = color.from_gradient(vwRsi, i_os, i_ob, color.new(i_bullCol, 35), color.new(i_bullCol, 100)),
    top_color    = na)

// Main body fill — RSI vs midline, solid gradient glow
fill(pRsi, pMid, vwRsi, 50,
    color.new(chart.bg_color, 100),
    vwRsi > 50 ? i_bullCol : i_bearCol)

// Soft trend fill
fill(pRsi, pMid,
    color = vwRsi > 50 ? color.new(i_bullCol, 88) : color.new(i_bearCol, 88))

// OB/OS reference lines
hline(i_ob, "Overbought", color=color.new(i_bearCol, 40), linestyle=hline.style_solid,  linewidth=1)
hline(i_os, "Oversold",   color=color.new(i_bullCol, 40), linestyle=hline.style_solid,  linewidth=1)
hline(50,   "Midline",    color=color.new(#8b949e,   65), linestyle=hline.style_dotted, linewidth=1)

// OB/OS Background
bgcolor(vwRsi >= i_ob ? color.new(i_bearCol, 82) : na, title="OB Background")
bgcolor(vwRsi <= i_os ? color.new(i_bullCol, 82) : na, title="OS Background")
bgcolor(vwRsi > 50 and vwRsi < i_ob ? color.new(i_bullCol, 95) : vwRsi < 50 and vwRsi > i_os ? color.new(i_bearCol, 95) : na, title="Mid Zone BG")

// ─── Dashboard State Strings ──────────────────────────────────
string divState = divBullHold > 0 ? "▲ BULL DIV" : divBearHold > 0 ? "▼ BEAR DIV" : "— None"
color  divCol   = divBullHold > 0 ? i_divBullC  : divBearHold > 0 ? i_divBearC  : C_MUTED

string zoneStr  = vwRsi >= i_ob ? "▲ OVERBOUGHT" : vwRsi <= i_os ? "▼ OVERSOLD" : "● NEUTRAL"
color  zoneCol  = vwRsi >= i_ob ? i_bearCol       : vwRsi <= i_os ? i_bullCol    : C_MUTED

string sigStr   = sigBullHold > 0 and divBullHold > 0 ? "▲ LONG (div)" :
                  sigBearHold > 0 and divBearHold > 0 ? "▼ SHORT (div)" :
                  sigBullHold > 0 ? "▲ EXIT OS" :
                  sigBearHold > 0 ? "▼ EXIT OB" : "— WAIT"
color  sigCol   = sigBullHold > 0 ? i_bullCol : sigBearHold > 0 ? i_bearCol : C_MUTED

float nearBSL   = array.size(liqLows)  > 0 ? array.get(liqLows,  0) : na
float nearSSL   = array.size(liqHighs) > 0 ? array.get(liqHighs, 0) : na

string bslStr   = not na(nearBSL) ? str.tostring(nearBSL, format.mintick) : "—"
string sslStr   = not na(nearSSL) ? str.tostring(nearSSL, format.mintick) : "—"

string vwRsiStr = str.tostring(math.round(vwRsi, 1))
string volRStr  = str.tostring(math.round(volRatio, 2), "#.##") + "x"
string mfiStr   = str.tostring(math.round(mfi, 1))
color  mfiCol   = mfi >= i_ob ? i_bearCol : mfi <= i_os ? i_bullCol : C_MUTED

// ─── Dashboard ────────────────────────────────────────────────
string dSize       = i_dashSz == "Tiny" ? size.tiny : i_dashSz == "Small" ? size.small : size.normal
string dashPosStr  = i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.bottom_right
color  headCol     = vwRsi >= i_ob ? color.new(i_bearCol, 70) : vwRsi <= i_os ? color.new(i_bullCol, 70) : color.new(C_PURP, 75)

var table dash = table.new(position.bottom_right, 2, 13,
    bgcolor      = C_BG,
    border_color = C_BDR, border_width = 1,
    frame_color  = C_BDR, frame_width  = 1)

if i_showDash and barstate.islast
    table.set_position(dash, dashPosStr)

    // Row 0 — Header
    table.cell(dash, 0, 0, "VW RSI Pro",    text_color=C_WHITE, bgcolor=headCol, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, "Anonycryptous", text_color=C_MUTED, bgcolor=headCol, text_size=dSize, text_halign=text.align_right)

    // Row 1 — VW RSI Value
    table.cell(dash, 0, 1, "VW RSI",   text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, vwRsiStr,   text_color=rsiPlotCol, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 2 — Volume Ratio
    table.cell(dash, 0, 2, "Vol Ratio", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, volRStr,     text_color=volRatio > 1.5 ? C_GOLD : C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 3 — MFI
    table.cell(dash, 0, 3, "MFI",      text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, mfiStr,     text_color=mfiCol,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 4 — Zone
    table.cell(dash, 0, 4, "Zone",    text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, zoneStr,   text_color=zoneCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 5 — Divergence
    table.cell(dash, 0, 5, "Divergence", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, divState,     text_color=divCol,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 6 — Signal
    table.cell(dash, 0, 6, "Signal",  text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, sigStr,    text_color=sigCol,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 7 — Divider
    table.cell(dash, 0, 7, "── Liquidity ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, "",               text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize)

    // Row 8 — Nearest BSL
    table.cell(dash, 0, 8, "Near BSL",  text_color=C_MUTED,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, bslStr,      text_color=i_bullCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 9 — Nearest SSL
    table.cell(dash, 0, 9, "Near SSL",  text_color=C_MUTED,   bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, sslStr,      text_color=i_bearCol,  bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 10 — Liq Count
    table.cell(dash, 0, 10, "Liq Levels", text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 10,
        str.tostring(array.size(liqLows)) + "▲ " + str.tostring(array.size(liqHighs)) + "▼",
        text_color=C_WHITE, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 11 — Volume Mode
    table.cell(dash, 0, 11, "Mode",         text_color=C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, i_volWt ? "VW" : "STD", text_color=i_volWt ? C_PURP : C_MUTED, bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

    // Row 12 — Brand
    table.cell(dash, 0, 12, "Anonycryptous", text_color=color.new(C_PURP, 0), bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, "v1.1",          text_color=C_MUTED,              bgcolor=C_PANEL, text_size=dSize, text_halign=text.align_right)

// ─── Alerts ───────────────────────────────────────────────────
alertcondition(isBullDiv,  "Bullish Divergence",  "VW RSI Pro — Bullish Divergence detected")
alertcondition(isBearDiv,  "Bearish Divergence",  "VW RSI Pro — Bearish Divergence detected")
alertcondition(sigBull,    "OS Exit Signal",       "VW RSI Pro — RSI exiting Oversold")
alertcondition(sigBear,    "OB Exit Signal",       "VW RSI Pro — RSI exiting Overbought")
alertcondition(isBullDiv or isBearDiv, "Any Divergence", "VW RSI Pro — Divergence signal fired")
alertcondition(sigCrossUp, "Signal Cross Up", "VW RSI Pro — RSI crossed above Signal Line")
alertcondition(sigCrossDn, "Signal Cross Down", "VW RSI Pro — RSI crossed below Signal Line")
````
