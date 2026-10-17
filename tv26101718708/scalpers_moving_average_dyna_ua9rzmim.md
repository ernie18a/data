# Scalper's Moving Average [DYNA]

- url: https://www.tradingview.com/script/ua9RzmIm-Scalper-s-Moving-Average-DYNA/
- type: indicator
- pine_id: PUB;6b2d38361c384deebad00ef4520a5be9
- version: 1.0

## Description

Scalper's Moving Average is an adaptive overlay line that automatically adjusts its speed based on market conditions. In trending markets it tracks price closely, keeping you in the move. In choppy, sideways markets it flattens out, filtering noise and keeping you from getting whipsawed. It is built on the Kaufman Adaptive Moving Average (KAMA) algorithm, tuned specifically for 1-5 minute scalping charts.

Most moving averages force you to choose between speed and smoothness. A fast MA gives early signals but generates constant false flips in chop. A slow MA filters noise but lags behind real moves, costing you ticks on every entry. Scalper's Moving Average solves this tradeoff by measuring how efficiently price is moving and adjusting its responsiveness in real time.


[b]Key Features[/b]

[list]
[*] [b]Adaptive Speed[/b] -- Automatically speeds up when price is trending and slows down when the market is chopping, so you get one line that does the work of two
[*] [b]Slope Color Coding[/b] -- The KAMA line changes color based on its slope direction: teal for rising, red for falling, gray for flat. Instant visual read of trend bias
[*] [b]Distance Fill[/b] -- Optional shaded area between price and KAMA shows how far price has stretched from its adaptive mean, helping you spot overextension and pullback entries
[*] [b]Slope Flip Markers[/b] -- Small triangle markers appear on the chart when the KAMA slope changes direction, flagging potential trend shifts at a glance. An ATR-based filter and cooldown system suppress noise flips in choppy markets
[*] [b]No Repainting[/b] -- Slope flip signals use confirmed-bar logic and will not change once printed
[/list]


[b]How It Works[/b]

When you add the indicator to your chart, you will see a single colored line overlaid on your candles. This is the KAMA line. Unlike a standard EMA or SMA, it does not move at a fixed speed. Instead, it calculates an efficiency ratio on every bar -- comparing how far price has moved in one direction versus how much total back-and-forth movement occurred. When that ratio is high (strong trend), the line speeds up and hugs price closely. When the ratio is low (chop), the line barely moves.

The line color tells you the current slope direction at a glance. A teal line means KAMA is rising and momentum favors the bulls. A red line means KAMA is falling and momentum favors the bears. A gray line means the slope is flat and the market has no clear direction -- a signal to stay patient.

When the slope changes direction, a small triangle marker appears directly on the KAMA line. An "UP" triangle marks a bullish flip, and a "DN" triangle marks a bearish flip. These transitions are the earliest indication that the adaptive trend bias has shifted. To keep the chart clean, flips are filtered by an ATR-scaled minimum slope threshold -- tiny wiggles in chop are ignored -- and a cooldown period prevents rapid-fire labels from stacking up.

[image]https://www.tradingview.com/x/oexfRVU5/[/image]
[i]KAMA line hugging price tightly during a trending move, with distance fill showing the stretch between price and the adaptive average.[/i]


[b]Distance Fill[/b]

The optional distance fill shades the area between the close price and the KAMA line. When price is above KAMA the fill is teal; when below, the fill is red. When price is hugging KAMA closely (within the dead-zone threshold), the fill turns neutral gray, giving you an instant visual cue that the market is chopping and there is no meaningful stretch to trade. The width of the colored fill tells you how far price has stretched from its adaptive mean. A wide fill suggests the move may be overextended -- not the ideal time to chase. A narrowing fill as price pulls back toward KAMA can highlight better entry zones where risk-to-reward improves.

[image]https://www.tradingview.com/x/UWUxN1uS/[/image]
[i]Distance fill expanding during a strong move, then narrowing as price pulls back to KAMA -- a potential re-entry zone.[/i]


[b]Settings[/b]

The core settings control the KAMA calculation. [b]KAMA Length[/b] (default 10) sets the lookback window for the efficiency ratio -- lower values make the line more reactive, higher values smooth it out. [b]Fast Constant[/b] (default 2) determines the fastest the line can move when the trend is strong. [b]Slow Constant[/b] (default 30) determines how sluggish the line becomes in chop. The defaults are tuned for 1-3 minute charts and work well for most scalping scenarios.

The flip filter settings control label quality. [b]Min Slope (ATR %)[/b] (default 0.15) sets the minimum slope magnitude as a fraction of ATR -- raise it to filter out more noise flips in choppy conditions. [b]Cooldown Bars[/b] (default 5) enforces a minimum gap between flip labels, preventing clusters of rapid UP/DN markers. Both settings also define the neutral dead-zone for slope coloring and fill.

Under visual settings, you can toggle the distance fill on or off and adjust the KAMA line thickness.


[b]Alerts[/b]

[list]
[*] [b]Slope Flip Bullish[/b] -- Fires when the KAMA slope turns from flat or falling to rising. Message: [i]"Scalper's Moving Average [DYNA]: KAMA slope flipped bullish. Trend may be turning up."[/i]
[*] [b]Slope Flip Bearish[/b] -- Fires when the KAMA slope turns from flat or rising to falling. Message: [i]"Scalper's Moving Average [DYNA]: KAMA slope flipped bearish. Trend may be turning down."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Scalper's Moving Average [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Start with the default 10/2/30 settings on 1-3 minute charts before making adjustments
[*] When the KAMA line is flat and gray, avoid trend-following trades -- the market is chopping
[*] Use the distance fill to time entries: enter on pullbacks toward KAMA rather than chasing extended moves
[*] Combine slope flip signals with volume or support/resistance levels for higher-confidence entries
[*] If trading 5-minute charts, consider increasing KAMA Length to 14 or 20 for smoother signals
[/list]


[b]Part of the DYNA Ecosystem[/b]

Scalper's Moving Average is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Scalper's Moving Average [DYNA]
// Adaptive moving average that hugs price tightly in trends and flattens in
// chop. Based on Kaufman Adaptive Moving Average (KAMA) with fast/slow
// constants tuned for 1-5 minute scalping charts.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Scalper's Moving Average [DYNA]", shorttitle = "ScalpMA [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800
color FILL_BULL     = color.new(#26a69a, 85)
color FILL_BEAR     = color.new(#ef5350, 85)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
string GRP_CORE = "Core Settings"
int    i_kamaLen   = input.int(10,   "KAMA Length",    minval = 2,  maxval = 100, group = GRP_CORE)
int    i_fastConst = input.int(2,    "Fast Constant",  minval = 1,  maxval = 10,  group = GRP_CORE)
int    i_slowConst = input.int(30,   "Slow Constant",  minval = 10, maxval = 100, group = GRP_CORE)

// --- Flip Filter ---
string GRP_FILTER = "Flip Filter"
float  i_atrThresh  = input.float(0.15, "Min Slope (ATR %)", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "Slope must exceed this fraction of ATR to register a flip. Higher = fewer labels.", group = GRP_FILTER)
int    i_cooldown   = input.int(5,      "Cooldown Bars",     minval = 0,   maxval = 20,  tooltip = "Minimum bars between flip labels.", group = GRP_FILTER)

// --- Visual ---
string GRP_VIS = "Visual"
bool   i_showFill   = input.bool(true, "Show Distance Fill", group = GRP_VIS)
int    i_lineWidth  = input.int(2,     "KAMA Line Width", minval = 1, maxval = 5, group = GRP_VIS)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Kaufman Adaptive Moving Average (manual implementation) ---
// KAMA adapts its smoothing constant based on the efficiency ratio (ER).
// In trending markets ER -> 1 and KAMA tracks price closely (fast).
// In choppy markets ER -> 0 and KAMA barely moves (slow).

float direction  = math.abs(close - close[i_kamaLen])
float volatility = math.sum(math.abs(close - close[1]), i_kamaLen)
float er         = bar_index < i_kamaLen or nz(volatility) == 0 ? 0.0 : nz(direction) / volatility

float fastSC = 2.0 / (i_fastConst + 1)
float slowSC = 2.0 / (i_slowConst + 1)
float sc     = math.pow(er * (fastSC - slowSC) + slowSC, 2)

// Seed KAMA with close on first bar; otherwise recursive update.
// Previous version used nz(kama[1]) which erased the var seed on bar 1.
var float kama = na
kama := na(kama[1]) ? close : kama[1] + sc * (close - kama[1])

// --- ATR for threshold scaling ---
float atr = ta.atr(14)

// --- Slope detection with neutral dead-zone (2-bar smoothed slope) ---
float kamaSlope = (kama - nz(kama[2], kama)) / 2
float deadZone  = atr * i_atrThresh

color kamaColor = kamaSlope > deadZone ? BULL_COLOR : kamaSlope < -deadZone ? BEAR_COLOR : NEUTRAL_COLOR

// --- Slope flip detection (confirmed-bar logic; 2-bar smoothed slope) ---
float prevSlope  = (nz(kama[1], kama) - nz(kama[3], kama)) / 2
float prev2Slope = (nz(kama[2], kama) - nz(kama[4], kama)) / 2

// Raw flips: slope crossed the dead-zone threshold
bool rawBull = prevSlope > deadZone and prev2Slope <= deadZone
bool rawBear = prevSlope < -deadZone and prev2Slope >= -deadZone

// --- Cooldown filter ---
var int barsSinceFlip = 0
barsSinceFlip := barsSinceFlip + 1

bool slopeBull = rawBull and barsSinceFlip >= i_cooldown
bool slopeBear = rawBear and barsSinceFlip >= i_cooldown

if slopeBull or slopeBear
    barsSinceFlip := 0

// --- Distance fill color (neutral when price hugs KAMA) ---
color fillColor = math.abs(close - kama) < deadZone ? color.new(NEUTRAL_COLOR, 90) : close >= kama ? FILL_BULL : FILL_BEAR

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- KAMA line ---
p_kama  = plot(kama,  "KAMA",  color = kamaColor, linewidth = i_lineWidth)

// --- Price line (transparent, used for fill only) ---
p_close = plot(close, "Close", color = na, display = display.none)

// --- Distance fill between price and KAMA ---
fill(p_close, p_kama, color = i_showFill ? fillColor : na, title = "Distance Fill")

// --- Slope flip markers (offset from candles for visibility) ---
plotshape(slopeBull, "Bullish Flip", style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.tiny, text = "UP", textcolor = BULL_COLOR)
plotshape(slopeBear, "Bearish Flip", style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.tiny, text = "DN", textcolor = BEAR_COLOR)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(slopeBull, title = "Slope Flip Bullish", message = "Scalper's Moving Average [DYNA]: KAMA slope flipped bullish. Trend may be turning up.")
alertcondition(slopeBear, title = "Slope Flip Bearish", message = "Scalper's Moving Average [DYNA]: KAMA slope flipped bearish. Trend may be turning down.")
````
