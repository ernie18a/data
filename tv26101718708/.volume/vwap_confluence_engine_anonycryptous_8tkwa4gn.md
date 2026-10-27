# VWAP Confluence Engine | Anonycryptous

- url: https://www.tradingview.com/script/8TKwa4GN-VWAP-Confluence-Engine-Anonycryptous/
- type: indicator
- pine_id: PUB;baeb0b6959f541fcb61c6f0db1612560
- version: 1.0

## Description

VWAP Confluence Engine | Anonycryptous
Description & user manual

Why this indicator is different
Most traders run VWAP and RSI as two separate tools. VWAP tells you where price is relative to the volume-weighted average. RSI tells you about momentum. The problem is that these two readings constantly disagree, and when they do, the trader is left guessing which one to trust. Price sits above VWAP while RSI turns down. RSI pushes above its midline while price is still below VWAP. Every one of those moments is a decision made under conflicting information, and that is exactly where most intraday accounts bleed.

The VWAP Confluence Engine removes the guessing. Instead of showing you two panels that argue with each other, it forces agreement before it shows a directional state. Three independent measurements have to point the same way: price relative to VWAP, a volume-weighted RSI, and the Money Flow Index. When all three align bullish, the candle is painted in the bull color. When all three align bearish, it is painted in the bear color. When they disagree, the candle is neutral, and that neutral state is the most important output in the whole system. It is the market telling you it has not decided, and that you should not decide either.

This turns a chart full of conflicting signals into a single color-coded read. One glance tells you direction, momentum, and participation at the same time.

But direction alone is only half of a trade. A signal in the wrong location is a trap, no matter how clean the momentum looks. So the engine also maps support and resistance zones from swing pivots, flips those zones as price reclaims or loses them, and tells you in a dashboard where the nearest level sits above and below. A bull agreement firing directly into a heavy resistance zone is a very different proposition from the same agreement firing off a reclaimed support. The indicator gives you both pieces in one view.

And because a single timeframe is never the whole story, a compact multi-timeframe bar shows the same agreement logic across six timeframes at once. When every timeframe is the same color, the decision is easy. When they are mixed, that is information too.

Important notice
The VWAP Confluence Engine generates visual states based on VWAP position, volume-weighted momentum, money flow, and price structure. These states are not financial advice. They do not predict future price movement. They do not guarantee profitability. All trading decisions are made entirely by the user. Always manage your own risk. Always apply your own judgment.

1. Overview
The VWAP Confluence Engine is an overlay indicator that combines VWAP, a volume-weighted RSI, and the Money Flow Index into a single three-way agreement system, then places that agreement in the context of support and resistance structure and higher timeframe trend.

What it includes:
- Anchored VWAP with selectable reset period (hour, 4 hours, day, week, month)
- Volume-weighted RSI that scales price change by relative volume
- Money Flow Index as an independent confirmation layer
- Three-way agreement candle coloring: bull, bear, and neutral
- Gradient fill between VWAP and price that intensifies with distance
- Support and resistance zones from four independent pivot lengths, with zone flip logic
- Divergence detection with a box drawn on the price chart
- Higher timeframe filter that can gate signals to trade only with the larger trend
- Sentiment transition markers on the exact bar agreement changes
- Two configurable EMAs for optional extra confirmation, independent of the signal engine
- Main dashboard with agreement state, VWAP position, VW RSI, MFI, divergence, nearest levels, and a dedicated higher timeframe section
- Compact multi-timeframe bar across six configurable timeframes
- Optional background coloring
- Alerts for agreement changes and divergence

2. Core logic
2.1 The three-way agreement
Everything in this indicator is built around one question: do all three measurements agree?

The three measurements are:
- VWAP position. Is price above or below the anchored VWAP.
- Volume-weighted RSI. Is momentum above or below its midline.
- Money Flow Index. Is money flow above or below its midline.

A bull state requires price above VWAP, VW RSI above the midline, and MFI above the midline at the same time. A bear state requires all three below. Anything else is neutral.

This is deliberately strict. The indicator does not paint a color unless all three independent readings confirm each other. That is why the neutral state matters so much. It is not a weakness in the signal, it is the signal. It marks the stretches where price is chopping, where momentum and money flow disagree, and where forcing a trade usually ends badly.

2.2 Volume-weighted RSI
Standard RSI treats every bar equally. A move on thin volume and a move on heavy volume produce the same RSI value if the price change is the same. The volume-weighted RSI multiplies each bar's price change by its relative volume, the ratio of that bar's volume to a smoothed average, before the smoothing step. Moves on strong participation push the oscillator harder. Moves on weak participation barely register. The result reflects who was behind the move, not just that a move occurred.

2.3 Money Flow Index
The MFI is calculated from typical price multiplied by volume, producing positive and negative money flow that is converted to a 0 to 100 index. It responds differently from the VW RSI because it weights price level rather than price change. Requiring both to agree means two independent volume-based calculations have to arrive at the same conclusion, which is a stronger condition than either one alone.

3. VWAP and the fill
The VWAP is anchored to a selectable period. Day is the default and the most useful for intraday scalping, resetting at each session open. Week and month give longer-term institutional reference levels. Hour and 4 hours give shorter references for very fast trading.

The fill between VWAP and price is drawn with a gradient. Near VWAP it is almost invisible. The further price travels from VWAP, the more the fill intensifies, up to a configurable maximum. This gives an immediate visual sense of how stretched price is from its volume-weighted average without adding any clutter when price is hugging the line. The fill color follows the agreement state.

4. Support and resistance zones
The engine detects swing highs and lows using four independent pivot lengths, each of which can be toggled and adjusted. Instead of drawing thin lines, it draws zones with a thickness based on the average true range, so each level is a band rather than a single price.

The zones flip color based on where price is relative to them:
- When price is above a zone, it is drawn in the bull color, acting as support.
- When price is below a zone, it is drawn in the bear color, acting as resistance.
- When price is inside a zone, it is drawn in the neutral color, marking active interaction.

This flip logic reflects a basic principle of price structure: old resistance becomes new support once it is reclaimed, and old support becomes new resistance once it is lost. The zone color always tells you which role the level is currently playing.

The maximum number of zones shown per pivot length is configurable, so the chart stays as clean or as detailed as you want.

5. Divergence
Divergence is detected by comparing pivots in the VW RSI against pivots in price.

Bearish divergence: price makes a higher high while VW RSI makes a lower high. Momentum is weakening as price extends.

Bullish divergence: price makes a lower low while VW RSI makes a higher low. Selling pressure is fading even as price continues down.

Sensitivity controls the pivot lookback window. High uses a 3-bar window for more signals and more noise. Medium uses 5 bars. Low uses a 10-bar window for fewer, higher quality signals.

When a divergence confirms, a box is drawn on the price chart spanning the full high-to-low range of the swing involved, with a small label naming the divergence type. This shows not just that a divergence happened, but exactly where on the chart it occurred. The dashboard also reports the current divergence state.

6. Higher timeframe filter
The higher timeframe filter, when enabled, requires the higher timeframe to agree with the current direction before a candle can be painted bull or bear. On a lower timeframe this prevents counter-trend coloring during a pullback inside a larger trend.

The filter can be turned off entirely. With it off, candle coloring is based only on the current timeframe's three-way agreement. This is a deliberate choice left to the trader: strict alignment with the higher timeframe, or faster response on the current one. The dashboard always shows the higher timeframe bias regardless of whether the filter is gating signals, so the context is available either way.

7. Multi-timeframe bar
The multi-timeframe bar is a compact panel showing the agreement direction across six timeframes at once. Each slot is fully configurable, defaulting to 5m, 15m, 1h, 4h, D, and W. Each shows a colored triangle, up for bull, down for bear, a dot for neutral, with the timeframe label colored to match.

This is the fastest read in the indicator. When every timeframe is the same color, alignment is strong and the decision is simple. When the shorter timeframes are one color and the higher ones another, price is at a transition or in conflict, and the bar shows that at a glance.

8. Sentiment transitions
When the agreement state changes, a small marker is plotted on the exact bar where it happened. A triangle up when the state flips to bull, a triangle down when it flips to bear, a dot when it drops into neutral. These mark the moments the read changed, which is often more actionable than the state simply being green or red for many bars in a row.

9. Dashboard reference
The main dashboard updates on every bar and shows:

Agreement - the current three-way state: bull, bear, or hold.
VWAP - whether price is above or below the anchored VWAP.
VW RSI - current volume-weighted RSI value, colored by position.
MFI - current Money Flow Index value.
Divergence - active divergence state, if any.
Near Support - nearest zone level below current price.
Near Resist - nearest zone level above current price.
VWAP Anchor - the current VWAP reset period.

The higher timeframe section, which can be toggled, adds for the selected higher timeframe: its agreement state, VWAP position, VW RSI, MFI, whether the higher timeframe filter is active, and a warning if the current chart timeframe is below the recommended minimum for the system.

10. How to use
10.1 The core read
Wait for agreement. A bull or bear colored candle means all three measurements confirm each other. A neutral candle means they do not. The single most valuable habit this indicator encourages is to simply stand aside when candles are neutral. Those stretches are where the market has not chosen a direction, and where forcing a trade tends to produce the worst outcomes.

10.2 Location matters as much as direction

A colored candle tells you the direction is confirmed. The support and resistance zones tell you whether the location is any good. A bull agreement firing straight into a heavy resistance zone above is a low quality entry, even though the momentum looks clean. The same bull agreement firing off a zone that has just flipped from resistance to support is a far better proposition. Read the two together, never direction alone.

10.3 Using the higher timeframe
If you want to trade only in the direction of the larger trend, enable the higher timeframe filter. Colored candles will then only appear when the current and higher timeframe agree. If you prefer to react faster and judge context yourself, leave it off and use the higher timeframe section of the dashboard and the multi-timeframe bar as reference rather than as a hard gate.

10.4 Divergence as context
A divergence box is a warning that momentum and price have started to disagree, not an instruction to enter. The most reliable approach is to wait for a divergence box near a support or resistance zone and then look for the agreement state to actually flip before acting. Divergence can persist for many bars before price responds.

10.5 Illustrative bull scenario
Educational example only. Not a trading recommendation.
Price pulls back to a support zone that flipped from resistance a few sessions earlier. The multi-timeframe bar shows the higher timeframes already bullish. A bullish divergence box appears at the zone. On the next bar the agreement state flips to bull, painting the candle and plotting a transition triangle. Direction, location, momentum, and higher timeframe are all pointing the same way at the same place.

10.6 Illustrative bear scenario
Educational example only. Not a trading recommendation.
Price rallies into a resistance zone overhead. VW RSI and MFI are both rolling over. A bearish divergence box is drawn across the swing. The agreement state flips to bear and a transition triangle down prints. The higher timeframe section confirms a bearish bias. The setup has direction, structure, and higher timeframe agreement in one location.

11. Recommended use
This system is built for intraday trading and works best on the higher intraday timeframes rather than the very fastest ones, where noise overwhelms the agreement logic. The dashboard includes a timeframe check that flags when you are below the recommended minimum. Pivot settings for the support and resistance zones can be tuned per instrument and timeframe; smaller pivot lengths surface shorter-term levels, larger ones surface major structure.

12. Settings reference
VWAP: anchor period, line color, line width.
VW RSI: length, volume smoothing, midline, overbought and oversold levels, divergence sensitivity, divergence toggle and hold, divergence box toggle and transparency.
MFI: enable, length, midline.
HTF filter: enable, timeframe, RSI midline.
S/R zones: show toggle, four pivot lengths with individual show toggles, max zones per pivot, zone thickness by ATR, zone transparency.
Visuals: bull, bear, and neutral colors, candle coloring toggle, VWAP fill toggle and transparency, background color toggle and transparency, sentiment transition toggle.
Moving averages: two EMAs, each with show toggle, length, color, transparency, and width. The EMAs are an optional visual aid for extra confirmation only. They are not part of the agreement engine and do not influence candle coloring, signals, or any other calculation.
Dashboards: main dashboard show, position, size, HTF section toggle, HTF section timeframe. Multi-timeframe bar show, position, size, and six configurable timeframe slots.

13. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document or in the indicator output constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital. Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator("VWAP Confluence Engine | Anonycryptous", shorttitle="VCE | Anonycryptous", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=1000)

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP CONFLUENCE ENGINE | Anonycryptous
// VWAP · VW RSI · MFI · Divergence · HTF Filter · S/R Zones · Dual Dashboard
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Group Constants ──────────────────────────────────────────────────────────
var string G_VWAP  = "VWAP Settings"
var string G_RSI   = "VW RSI Settings"
var string G_MFI   = "MFI Settings"
var string G_HTF   = "HTF Filter"
var string G_SR    = "Support & Resistance Zones"
var string G_VIS   = "Visuals"
var string G_EMA   = "Moving Averages"
var string G_DASH1 = "Dashboard — Main"
var string G_DASH2 = "Dashboard — MTF"

// ─── Brand Colors ─────────────────────────────────────────────────────────────
color C_BULL  = #00FF00
color C_BEAR  = #FF0000
color C_HOLD  = #57595c
color C_GOLD  = #f5c518
color C_PURP  = #bb86fc
color C_BG    = color.new(#0d1117, 10)
color C_PANEL = color.new(#161b22, 0)
color C_BDR   = color.new(#30363d, 20)
color C_MUTED = color.new(#8b949e, 0)
color C_WHITE = color.new(#ffffff, 0)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — VWAP
// ═══════════════════════════════════════════════════════════════════════════════
string i_vwapAnchor = input.string("Day", "VWAP Anchor",
    options=["Hour", "4 Hours", "Day", "Week", "Month"],
    group=G_VWAP,
    tooltip="Sets the reset period for VWAP. Day = resets at each session open (recommended for intraday scalping). Week/Month = longer-term institutional reference levels. Hour/4H = ultra short-term.")

color  i_vwapCol   = input.color(#f5c518, "VWAP Color",
    group=G_VWAP,
    tooltip="Color of the VWAP line plotted on the chart. Default gold (#f5c518).")

int    i_vwapWidth = input.int(2, "VWAP Line Width", minval=1, maxval=4,
    group=G_VWAP,
    tooltip="Thickness of the VWAP line. 1 = thin, 4 = thick.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — VW RSI
// ═══════════════════════════════════════════════════════════════════════════════
int   i_rsiLen  = input.int(14, "RSI Length", minval=1,
    group=G_RSI,
    tooltip="Lookback period for the Volume Weighted RSI. Default 14. Lower values react faster but produce more noise. Higher values are smoother but lag more.")

int   i_volLen  = input.int(14, "Volume Smoothing", minval=1,
    group=G_RSI,
    tooltip="Lookback for the volume moving average used to normalize per-bar volume. Higher = smoother volume weighting, less reactive to single-bar volume spikes.")

float i_rsiMid  = input.float(50.0, "RSI Midline", minval=1, maxval=99,
    group=G_RSI,
    tooltip="The midline that separates bullish from bearish momentum. Default 50. VW RSI above this = bullish bias. Below = bearish bias.")

float i_ob      = input.float(80.0, "Overbought Level",
    group=G_RSI,
    tooltip="VW RSI level considered overbought. When RSI exceeds this, bearish divergence signals carry extra weight. Used in dashboard zone display.")

float i_os      = input.float(20.0, "Oversold Level",
    group=G_RSI,
    tooltip="VW RSI level considered oversold. When RSI is below this, bullish divergence signals carry extra weight. Used in dashboard zone display.")

string i_divSens = input.string("Low", "Divergence Sensitivity",
    options=["High", "Medium", "Low"],
    group=G_RSI,
    tooltip="Controls the pivot lookback window for divergence detection. High = 3-bar window (more signals, more noise). Medium = 5 bars. Low = 10 bars (fewer signals, higher quality).")

bool  i_showDiv = input.bool(true, "Show Divergence Signals",
    group=G_RSI,
    tooltip="When ON, bullish and bearish divergence between price and VW RSI are detected and shown in the dashboard. Divergence on top of a colored candle = stronger confluence.")

int   i_divHold = input.int(10, "Divergence Hold (bars)", minval=1, maxval=50,
    group=G_RSI,
    tooltip="How many bars the divergence signal stays active in the dashboard after it fires. Default 10. Set lower for tighter signal windows.")

bool  i_showDivBox  = input.bool(true, "Show Divergence Box on Chart",
    group=G_RSI,
    tooltip="Draws a box on the price chart spanning the high-low range of the divergence swing. Bull divergence = green box, bear divergence = red box. A small label appears at the top right of the box showing the divergence type.")

int   i_divBoxTransp = input.int(85, "Divergence Box Transparency", minval=60, maxval=95,
    group=G_RSI,
    tooltip="Transparency of the divergence box fill. Default 85 = subtle. Lower = more visible.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — MFI
// ═══════════════════════════════════════════════════════════════════════════════
bool  i_useMfi  = input.bool(true, "Enable MFI Confirmation",
    group=G_MFI,
    tooltip="When ON, the Money Flow Index (MFI) must agree with VW RSI for a candle to be colored green or red. When OFF, only VWAP + VW RSI are required. MFI adds a volume-based money flow check — reduces false signals in low-volume conditions.")

int   i_mfiLen  = input.int(14, "MFI Length", minval=1,
    group=G_MFI,
    tooltip="Lookback period for the Money Flow Index. Default 14 matches RSI length for direct comparison. MFI uses typical price × volume, giving a different angle than VW RSI alone.")

float i_mfiMid  = input.float(50.0, "MFI Midline", minval=1, maxval=99,
    group=G_MFI,
    tooltip="The midline that separates bullish from bearish money flow. MFI above this = buying pressure dominates. Below = selling pressure dominates.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — HTF FILTER
// ═══════════════════════════════════════════════════════════════════════════════
bool   i_useHTF  = input.bool(true, "Enable HTF Filter",
    group=G_HTF,
    tooltip="When ON, candle coloring and signals only fire when the higher timeframe agrees with the current direction. Prevents counter-trend scalp entries on lower timeframes. Recommended ON for 1m–15m charts.")

string i_htfTF   = input.timeframe("240", "HTF Timeframe",
    group=G_HTF,
    tooltip="The higher timeframe used to check trend alignment. Default 4H. For scalping on 1m–5m, use 15m or 1H. For 30m charts, use 4H or Daily.")

float  i_htfMid  = input.float(50.0, "HTF RSI Midline", minval=1, maxval=99,
    group=G_HTF,
    tooltip="The RSI midline applied to the HTF timeframe. HTF VW RSI must be above this for bull confirmation, below for bear. Default 50.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — S/R ZONES
// ═══════════════════════════════════════════════════════════════════════════════
bool  i_showSR   = input.bool(true, "Show S/R Zones",
    group=G_SR,
    tooltip="Draws horizontal support and resistance zones on the chart based on pivot highs and lows. Zones flip color based on price location: green = support (price above), red = resistance (price below), amber = price is currently interacting with the zone.")

int   i_srLen1   = input.int(5,   "Pivot 1 Length", minval=2,
    group=G_SR,
    tooltip="Lookback bars for Pivot 1 swing detection. Smaller values = more sensitive, shorter-term levels. Recommended: 5 for scalping (1m–15m).")

int   i_srLen2   = input.int(25,  "Pivot 2 Length", minval=2,
    group=G_SR,
    tooltip="Lookback bars for Pivot 2 swing detection. Medium-term structural levels. Recommended: 25 for intraday context.")

int   i_srLen3   = input.int(50,  "Pivot 3 Length", minval=2,
    group=G_SR,
    tooltip="Lookback bars for Pivot 3 swing detection. Higher-timeframe structural swing levels. Recommended: 50 for daily reference.")

int   i_srLen4   = input.int(100, "Pivot 4 Length", minval=2,
    group=G_SR,
    tooltip="Lookback bars for Pivot 4 swing detection. Major swing structure. Recommended: 100 for weekly reference points.")

bool  i_srP1     = input.bool(true,  "Show Pivot 1", group=G_SR, tooltip="Toggle visibility of Pivot 1 zones.")
bool  i_srP2     = input.bool(true,  "Show Pivot 2", group=G_SR, tooltip="Toggle visibility of Pivot 2 zones.")
bool  i_srP3     = input.bool(true,  "Show Pivot 3", group=G_SR, tooltip="Toggle visibility of Pivot 3 zones.")
bool  i_srP4     = input.bool(false, "Show Pivot 4", group=G_SR, tooltip="Toggle visibility of Pivot 4 zones. Off by default — use for major structural reference only.")

int   i_srMaxZones = input.int(3, "Max Zones per Pivot", minval=1, maxval=25,
    group=G_SR,
    tooltip="Maximum number of S/R zones shown per pivot length, for both highs and lows. Default 3 = clean chart. Set higher if you want more historical levels visible. Each pivot length (1–4) shows up to this many zones independently.")

float i_srATR    = input.float(0.3, "Zone Thickness (ATR multiplier)", minval=0.05, step=0.05,
    group=G_SR,
    tooltip="Controls the vertical height of each S/R zone. Calculated as ATR × this multiplier. Higher value = thicker zones that are easier to see but less precise.")

int   i_srTransp = input.int(75, "Zone Transparency", minval=50, maxval=95,
    group=G_SR,
    tooltip="Transparency of the zone fill. Higher = more transparent. Border is always slightly more opaque than the fill for clarity.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
color  i_bullCol   = input.color(#00FF00, "Bull Color",
    group=G_VIS,
    tooltip="Color applied to candles, fills, and zones when all indicators agree bullish. Default fluorescent green.")

color  i_bearCol   = input.color(#FF0000, "Bear Color",
    group=G_VIS,
    tooltip="Color applied to candles, fills, and zones when all indicators agree bearish. Default fluorescent red.")

color  i_holdCol   = input.color(#57595c, "Hold / Neutral Color",
    group=G_VIS,
    tooltip="Color applied to candles and fills when indicators conflict. This is your signal to stay out — do not trade amber candles. Default amber.")

bool   i_candleCol = input.bool(true, "Enable Candle Coloring",
    group=G_VIS,
    tooltip="When ON, candles are colored green (bull agreement), red (bear agreement), or amber (conflict/hold). Turn OFF to see original candle colors while keeping fill and zone logic.")

bool   i_showFill  = input.bool(true, "Show VWAP Fill",
    group=G_VIS,
    tooltip="Fills the area between the VWAP line and the candle body with a gradient color. Green fill above VWAP, red fill below, amber when in a hold zone. Intensity increases toward the candle — stronger color = more distance from VWAP.")

int    i_fillTransp = input.int(85, "Fill Max Transparency", minval=60, maxval=98,
    group=G_VIS,
    tooltip="Controls the maximum opacity of the VWAP fill when price is far from VWAP. Near VWAP the fill is always near-invisible (98% transparent). Higher value = subtler fill overall. Default 85.")

bool   i_showBg    = input.bool(false, "Show Background Color",
    group=G_VIS,
    tooltip="Paints a subtle background color across the entire chart based on the current agreement state. Green = bull agreement, red = bear agreement, amber = hold/conflict. Very transparent by default — use as a soft visual context layer.")

int    i_bgTransp  = input.int(93, "Background Transparency", minval=80, maxval=99,
    group=G_VIS,
    tooltip="Transparency of the background color. Default 93 = very subtle. Lower = stronger color. Recommended range: 90–97 to avoid visual clutter.")

bool   i_showTrans = input.bool(true, "Show Sentiment Transition Signals",
    group=G_VIS,
    tooltip="Plots a small triangle or dot on the chart when agreement sentiment changes. Green triangle up = sentiment flips to bull. Red triangle down = sentiment flips to bear. Grey dot = sentiment drops into hold/conflict. Fires only on the exact transition bar.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════════════════════
bool   i_showEma1  = input.bool(true, "Show EMA 1",
    group=G_EMA,
    tooltip="Displays the first EMA on the chart. Useful as a dynamic trend filter alongside the VWAP confluence system.")

int    i_ema1Len   = input.int(21, "EMA 1 Length", minval=1,
    group=G_EMA,
    tooltip="Period for EMA 1. Default 21 — a common short-term trend reference for intraday trading.")

color  i_ema1Col   = input.color(#2962ff, "EMA 1 Color",
    group=G_EMA,
    tooltip="Color of EMA 1.")

int    i_ema1Transp = input.int(0, "EMA 1 Transparency", minval=0, maxval=90,
    group=G_EMA,
    tooltip="Transparency of EMA 1. 0 = fully opaque, higher = more faded.")

int    i_ema1Width = input.int(1, "EMA 1 Width", minval=1, maxval=5,
    group=G_EMA,
    tooltip="Line thickness of EMA 1.")

bool   i_showEma2  = input.bool(true, "Show EMA 2",
    group=G_EMA,
    tooltip="Displays the second EMA on the chart. Combine with EMA 1 for a moving average stack / trend confirmation.")

int    i_ema2Len   = input.int(50, "EMA 2 Length", minval=1,
    group=G_EMA,
    tooltip="Period for EMA 2. Default 50 — a medium-term trend reference. Price above both EMAs = stronger bull context.")

color  i_ema2Col   = input.color(#ff6d00, "EMA 2 Color",
    group=G_EMA,
    tooltip="Color of EMA 2.")

int    i_ema2Transp = input.int(0, "EMA 2 Transparency", minval=0, maxval=90,
    group=G_EMA,
    tooltip="Transparency of EMA 2. 0 = fully opaque, higher = more faded.")

int    i_ema2Width = input.int(1, "EMA 2 Width", minval=1, maxval=5,
    group=G_EMA,
    tooltip="Line thickness of EMA 2.")

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — DASHBOARDS
// ═══════════════════════════════════════════════════════════════════════════════
bool   i_showDash1  = input.bool(true, "Show Main Dashboard",
    group=G_DASH1,
    tooltip="Displays the main confluence dashboard showing VWAP position, VW RSI value, MFI value, divergence status, agreement state, and nearest S/R levels.")

string i_dash1Pos   = input.string("Bottom Right", "Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"],
    group=G_DASH1,
    tooltip="Screen position of the main dashboard.")

string i_dash1Sz    = input.string("Tiny", "Size",
    options=["Tiny","Small","Normal"],
    group=G_DASH1,
    tooltip="Text size of the main dashboard. Tiny = compact, Normal = easier to read on smaller monitors.")

bool   i_showHtfSection = input.bool(true, "Show HTF Section in Dashboard",
    group=G_DASH1,
    tooltip="Shows a dedicated HTF section at the bottom of the main dashboard. Displays VWAP position, VW RSI, MFI, and filter status for the selected HTF timeframe. Toggle off to keep the dashboard compact.")

string i_htfSectionTF = input.timeframe("240", "HTF Section Timeframe",
    group=G_DASH1,
    tooltip="The timeframe shown in the HTF section of the main dashboard. Independent from the HTF filter timeframe — use this to monitor a specific reference TF (e.g. 4H when scalping on 5m).")

bool   i_showDash2  = input.bool(true, "Show MTF Dashboard",
    group=G_DASH2,
    tooltip="Shows a compact MTF bar with 6 configurable timeframes. Each slot shows a triangle (bull/bear/hold) with the TF label colored to match. Instant multi-timeframe alignment read at a glance.")

string i_dash2Pos   = input.string("Bottom Left", "MTF Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"],
    group=G_DASH2,
    tooltip="Screen position of the MTF timeframe bar.")

string i_dash2Sz    = input.string("Tiny", "MTF Size",
    options=["Tiny","Small","Normal"],
    group=G_DASH2,
    tooltip="Text size of the MTF bar. Tiny = compact, recommended for mobile.")

string i_mtfTF1 = input.timeframe("5",   "MTF Slot 1", group=G_DASH2, tooltip="Timeframe for MTF slot 1. Default 5m.")
string i_mtfTF2 = input.timeframe("15",  "MTF Slot 2", group=G_DASH2, tooltip="Timeframe for MTF slot 2. Default 15m.")
string i_mtfTF3 = input.timeframe("60",  "MTF Slot 3", group=G_DASH2, tooltip="Timeframe for MTF slot 3. Default 1H.")
string i_mtfTF4 = input.timeframe("240", "MTF Slot 4", group=G_DASH2, tooltip="Timeframe for MTF slot 4. Default 4H.")
string i_mtfTF5 = input.timeframe("D",   "MTF Slot 5", group=G_DASH2, tooltip="Timeframe for MTF slot 5. Default Daily.")
string i_mtfTF6 = input.timeframe("W",   "MTF Slot 6", group=G_DASH2, tooltip="Timeframe for MTF slot 6. Default Weekly.")

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════
string vwapAnchorTF = switch i_vwapAnchor
    "Hour"    => "60"
    "4 Hours" => "240"
    "Day"     => "D"
    "Week"    => "W"
    => "M"

bool isNewPeriod = timeframe.change(vwapAnchorTF)

var float cumVol  = 0.0
var float cumHlc3v = 0.0

if isNewPeriod or barstate.isfirst
    cumVol   := 0.0
    cumHlc3v := 0.0

cumVol   += volume
cumHlc3v += hlc3 * volume
float vwapVal = cumVol > 0 ? cumHlc3v / cumVol : hlc3

// ═══════════════════════════════════════════════════════════════════════════════
// VW RSI CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════
float priceChange = ta.change(close)
float volSma      = ta.sma(volume, i_volLen)
float volRatio    = volume / math.max(volSma, 1)

float wtGain = math.max(priceChange, 0) * volRatio
float wtLoss = math.max(-priceChange, 0) * volRatio

float avgGain = ta.rma(wtGain, i_rsiLen)
float avgLoss = ta.rma(wtLoss, i_rsiLen)
float rs      = avgLoss == 0 ? 100 : avgGain / avgLoss
float vwRsi   = 100 - 100 / (1 + rs)

// ═══════════════════════════════════════════════════════════════════════════════
// MFI CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════
float typPrice = hlc3
float rawMF    = typPrice * volume
float posMF    = typPrice > typPrice[1] ? rawMF : 0.0
float negMF    = typPrice < typPrice[1] ? rawMF : 0.0
float mfRatio  = ta.sma(posMF, i_mfiLen) / math.max(ta.sma(negMF, i_mfiLen), 1)
float mfi      = 100 - 100 / (1 + mfRatio)

// ═══════════════════════════════════════════════════════════════════════════════
// HTF VALUES VIA REQUEST.SECURITY
// ═══════════════════════════════════════════════════════════════════════════════
// HTF VWAP — use built-in ta.vwap anchored to HTF session
float htfVwap = request.security(syminfo.tickerid, i_htfTF, ta.vwap)

// HTF VW RSI — calculated on HTF bars
float htfVwRsi = request.security(syminfo.tickerid, i_htfTF, vwRsi)

bool htfBull = htfVwap > 0 and close > htfVwap and htfVwRsi > i_htfMid
bool htfBear = htfVwap > 0 and close < htfVwap and htfVwRsi < i_htfMid

// HTF Section dashboard values — separate TF for display in main dashboard
float htfS_vwap  = request.security(syminfo.tickerid, i_htfSectionTF, ta.vwap)
float htfS_vwRsi = request.security(syminfo.tickerid, i_htfSectionTF, vwRsi)
float htfS_mfi   = request.security(syminfo.tickerid, i_htfSectionTF, mfi)

// ═══════════════════════════════════════════════════════════════════════════════
// AGREEMENT CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════════
bool ltfBull = close > vwapVal and vwRsi > i_rsiMid and (not i_useMfi or mfi > i_mfiMid)
bool ltfBear = close < vwapVal and vwRsi < i_rsiMid and (not i_useMfi or mfi < i_mfiMid)

bool isBull = i_useHTF ? (ltfBull and htfBull) : ltfBull
bool isBear = i_useHTF ? (ltfBear and htfBear) : ltfBear
bool isHold = not isBull and not isBear

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
int pivWin = switch i_divSens
    "High"   => 3
    "Medium" => 5
    => 10

float pivH      = ta.pivothigh(vwRsi, pivWin, pivWin)
float pivL      = ta.pivotlow(vwRsi,  pivWin, pivWin)
float pivHPrice = ta.pivothigh(high,  pivWin, pivWin)
float pivLPrice = ta.pivotlow(low,    pivWin, pivWin)

var float lastPivHRsi   = na
var float lastPivLRsi   = na
var float lastPivHPrice = na
var float lastPivLPrice = na
var int   lastPivHBar   = na
var int   lastPivLBar   = na

// Arrays to track previous pivot bars (needed for [1] indexing in div box)
var array<int> pivHBars = array.new_int(2, na)
var array<int> pivLBars = array.new_int(2, na)

var int divBullHold = 0
var int divBearHold = 0

bool isBearDiv = false
if not na(pivH)
    if not na(lastPivHRsi) and vwRsi[pivWin] < lastPivHRsi and high[pivWin] > lastPivHPrice
        isBearDiv := true
    lastPivHRsi   := vwRsi[pivWin]
    lastPivHPrice := high[pivWin]
    lastPivHBar   := bar_index - pivWin
    array.set(pivHBars, 1, array.get(pivHBars, 0))
    array.set(pivHBars, 0, bar_index - pivWin)

bool isBullDiv = false
if not na(pivL)
    if not na(lastPivLRsi) and vwRsi[pivWin] > lastPivLRsi and low[pivWin] < lastPivLPrice
        isBullDiv := true
    lastPivLRsi   := vwRsi[pivWin]
    lastPivLPrice := low[pivWin]
    lastPivLBar   := bar_index - pivWin
    array.set(pivLBars, 1, array.get(pivLBars, 0))
    array.set(pivLBars, 0, bar_index - pivWin)

if isBullDiv
    divBullHold := i_divHold
else if divBullHold > 0
    divBullHold -= 1

if isBearDiv
    divBearHold := i_divHold
else if divBearHold > 0
    divBearHold -= 1

// ═══════════════════════════════════════════════════════════════════════════════
// ATR FOR ZONES
// ═══════════════════════════════════════════════════════════════════════════════
float atrVal = ta.atr(14)
float zoneH  = atrVal * i_srATR

// ═══════════════════════════════════════════════════════════════════════════════
// S/R PIVOT LEVELS
// ═══════════════════════════════════════════════════════════════════════════════
// All pivot functions must execute at top level
float ph1 = ta.pivothigh(high, i_srLen1, i_srLen1)
float pl1 = ta.pivotlow(low,   i_srLen1, i_srLen1)
float ph2 = ta.pivothigh(high, i_srLen2, i_srLen2)
float pl2 = ta.pivotlow(low,   i_srLen2, i_srLen2)
float ph3 = ta.pivothigh(high, i_srLen3, i_srLen3)
float pl3 = ta.pivotlow(low,   i_srLen3, i_srLen3)
float ph4 = ta.pivothigh(high, i_srLen4, i_srLen4)
float pl4 = ta.pivotlow(low,   i_srLen4, i_srLen4)

// Store active S/R levels — separate high/low arrays per pivot set
var array<float> srH1 = array.new_float(0)
var array<float> srL1 = array.new_float(0)
var array<float> srH2 = array.new_float(0)
var array<float> srL2 = array.new_float(0)
var array<float> srH3 = array.new_float(0)
var array<float> srL3 = array.new_float(0)
var array<float> srH4 = array.new_float(0)
var array<float> srL4 = array.new_float(0)
var array<int>   srB1h = array.new_int(0)
var array<int>   srB1l = array.new_int(0)
var array<int>   srB2h = array.new_int(0)
var array<int>   srB2l = array.new_int(0)
var array<int>   srB3h = array.new_int(0)
var array<int>   srB3l = array.new_int(0)
var array<int>   srB4h = array.new_int(0)
var array<int>   srB4l = array.new_int(0)
var array<box>   srBoxes = array.new_box(0)

f_pushLevel(array<float> arr, array<int> bars, float val, int bIdx, int maxN) =>
    if not na(val)
        array.unshift(arr, val)
        array.unshift(bars, bIdx)
        if array.size(arr) > maxN
            array.pop(arr)
            array.pop(bars)

if i_srP1
    f_pushLevel(srH1, srB1h, ph1, bar_index - i_srLen1, i_srMaxZones)
    f_pushLevel(srL1, srB1l, pl1, bar_index - i_srLen1, i_srMaxZones)
if i_srP2
    f_pushLevel(srH2, srB2h, ph2, bar_index - i_srLen2, i_srMaxZones)
    f_pushLevel(srL2, srB2l, pl2, bar_index - i_srLen2, i_srMaxZones)
if i_srP3
    f_pushLevel(srH3, srB3h, ph3, bar_index - i_srLen3, i_srMaxZones)
    f_pushLevel(srL3, srB3l, pl3, bar_index - i_srLen3, i_srMaxZones)
if i_srP4
    f_pushLevel(srH4, srB4h, ph4, bar_index - i_srLen4, i_srMaxZones)
    f_pushLevel(srL4, srB4l, pl4, bar_index - i_srLen4, i_srMaxZones)

// ─── Draw S/R Zones ───────────────────────────────────────────────────────────
// drawGroup must be defined at top level — not inside if block
drawGroup(array<float> lvls, array<int> bars) =>
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float lvl  = array.get(lvls, i)
            int   bIdx = math.max(array.get(bars, i), bar_index - 900)
            float top  = lvl + zoneH * 0.5
            float bot  = lvl - zoneH * 0.5
            bool priceInZone = close >= bot and close <= top
            bool priceAbove  = close > top
            color zCol    = priceInZone ? i_holdCol : priceAbove ? i_bullCol : i_bearCol
            color zFill   = color.new(zCol, i_srTransp)
            color zBorder = color.new(zCol, math.max(i_srTransp - 20, 0))
            box b = box.new(bIdx, top, bar_index + 5, bot,
                bgcolor      = zFill,
                border_color = zBorder,
                border_width = 1,
                extend       = extend.none)
            array.push(srBoxes, b)

if i_showSR and barstate.islast
    for b in srBoxes
        box.delete(b)
    array.clear(srBoxes)

    if i_srP1
        drawGroup(srH1, srB1h)
        drawGroup(srL1, srB1l)
    if i_srP2
        drawGroup(srH2, srB2h)
        drawGroup(srL2, srB2l)
    if i_srP3
        drawGroup(srH3, srB3h)
        drawGroup(srL3, srB3l)
    if i_srP4
        drawGroup(srH4, srB4h)
        drawGroup(srL4, srB4l)

// ═══════════════════════════════════════════════════════════════════════════════
// CANDLE COLORING
// ═══════════════════════════════════════════════════════════════════════════════
color candleCol = isBull ? i_bullCol : isBear ? i_bearCol : i_holdCol
color wickCol   = isBull ? color.new(i_bullCol, 40) : isBear ? color.new(i_bearCol, 40) : color.new(i_holdCol, 40)

barcolor(i_candleCol ? candleCol : na)
bgcolor(i_showBg ? color.new(candleCol, i_bgTransp) : na)

// ─── Sentiment Transition Signals ─────────────────────────────────────────────
bool toBull = isBull and not isBull[1]
bool toBear = isBear and not isBear[1]
bool toHold = isHold and not isHold[1]

plotshape(i_showTrans and toBull, "Bull Transition", shape.triangleup,
    location.belowbar, color=i_bullCol, size=size.tiny)
plotshape(i_showTrans and toBear, "Bear Transition", shape.triangledown,
    location.abovebar, color=i_bearCol, size=size.tiny)
plotshape(i_showTrans and toHold, "Hold Transition", shape.circle,
    location.belowbar, color=i_holdCol, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP FILL — GRADIENT BETWEEN VWAP AND CLOSE
// ═══════════════════════════════════════════════════════════════════════════════
// color.from_gradient: maps ATR-normalized distance to transparency range
// Near VWAP = near-transparent, far from VWAP = more visible but still subtle
float fillDist    = math.abs(close - vwapVal)
float fillDistNorm = math.min(fillDist / math.max(atrVal * 3.0, 0.0001), 1.0)

color fillBase   = isBull ? i_bullCol : isBear ? i_bearCol : i_holdCol
color fillNear   = color.new(fillBase, 98)
color fillFar    = color.new(fillBase, i_fillTransp)
color fillColor  = color.from_gradient(fillDistNorm, 0.0, 1.0, fillNear, fillFar)

// Plot VWAP and fill reference lines
plot(vwapVal, "VWAP", color=i_vwapCol, linewidth=i_vwapWidth)

// ─── EMAs ─────────────────────────────────────────────────────────────────────
float ema1 = ta.ema(close, i_ema1Len)
float ema2 = ta.ema(close, i_ema2Len)
plot(i_showEma1 ? ema1 : na, "EMA 1", color=color.new(i_ema1Col, i_ema1Transp), linewidth=i_ema1Width)
plot(i_showEma2 ? ema2 : na, "EMA 2", color=color.new(i_ema2Col, i_ema2Transp), linewidth=i_ema2Width)
p_close = plot(i_showFill ? close : na, "Close Ref", color=color.new(color.white, 100), display=display.none)
p_vwap  = plot(i_showFill ? vwapVal : na, "VWAP Fill Ref", color=color.new(color.white, 100), display=display.none)
fill(p_close, p_vwap, color=i_showFill ? fillColor : na)

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Right" ? position.top_right :
     p == "Bottom Left" ? position.bottom_left :
     position.bottom_right

f_sz(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
string vwapPos  = close > vwapVal ? "▲ Above VWAP" : "▼ Below VWAP"
color  vwapPosC = close > vwapVal ? i_bullCol : i_bearCol

string rsiStr   = str.tostring(math.round(vwRsi, 1))
color  rsiCol   = vwRsi > i_ob ? i_bearCol : vwRsi < i_os ? i_bullCol : vwRsi > i_rsiMid ? i_bullCol : i_bearCol

string mfiStr   = str.tostring(math.round(mfi, 1))
color  mfiCol   = mfi > i_mfiMid ? i_bullCol : i_bearCol

string divStr   = divBullHold > 0 ? "▲ Bull Div" : divBearHold > 0 ? "▼ Bear Div" : "— None"
color  divCol   = divBullHold > 0 ? i_bullCol : divBearHold > 0 ? i_bearCol : C_MUTED

string agreeStr = isBull ? "▲ BULL" : isBear ? "▼ BEAR" : "● HOLD"
color  agreeCol = isBull ? i_bullCol : isBear ? i_bearCol : i_holdCol


// Nearest S/R above and below — direct inline scan
float nearSup = na
float nearRes = na

if array.size(srH1) > 0
    for i = 0 to array.size(srH1) - 1
        float lvl = array.get(srH1, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srL1) > 0
    for i = 0 to array.size(srL1) - 1
        float lvl = array.get(srL1, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srH2) > 0
    for i = 0 to array.size(srH2) - 1
        float lvl = array.get(srH2, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srL2) > 0
    for i = 0 to array.size(srL2) - 1
        float lvl = array.get(srL2, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srH3) > 0
    for i = 0 to array.size(srH3) - 1
        float lvl = array.get(srH3, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srL3) > 0
    for i = 0 to array.size(srL3) - 1
        float lvl = array.get(srL3, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srH4) > 0
    for i = 0 to array.size(srH4) - 1
        float lvl = array.get(srH4, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

if array.size(srL4) > 0
    for i = 0 to array.size(srL4) - 1
        float lvl = array.get(srL4, i)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        if lvl > close
            if na(nearRes) or lvl < nearRes
                nearRes := lvl

string supStr = not na(nearSup) ? str.tostring(nearSup, format.mintick) : "—"
string resStr = not na(nearRes) ? str.tostring(nearRes, format.mintick) : "—"

var table dash1 = table.new(position.bottom_right, 2, 17,
    bgcolor=C_BG, border_color=C_BDR, border_width=1, frame_color=C_BDR, frame_width=1)

if i_showDash1 and barstate.islast
    table.set_position(dash1, f_pos(i_dash1Pos))
    string sz = f_sz(i_dash1Sz)
    color hCol = color.new(C_PURP, 75)

    // Row 0 — Header
    table.cell(dash1, 0, 0, "VCE v1.0",             text_color=C_WHITE, bgcolor=hCol, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 0, "Anonycryptous",   text_color=C_MUTED, bgcolor=hCol, text_size=sz, text_halign=text.align_right)

    // Row 1 — Agreement
    table.cell(dash1, 0, 1, "Agreement",        text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 1, agreeStr,           text_color=agreeCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 2 — VWAP Position
    table.cell(dash1, 0, 2, "VWAP",             text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 2, vwapPos,            text_color=vwapPosC, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 3 — VW RSI
    table.cell(dash1, 0, 3, "VW RSI",           text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 3, rsiStr,             text_color=rsiCol,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 4 — MFI
    table.cell(dash1, 0, 4, "MFI",              text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 4, mfiStr,             text_color=mfiCol,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 5 — Divergence
    table.cell(dash1, 0, 5, "Divergence",       text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 5, divStr,             text_color=divCol,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 6 — Divider
    table.cell(dash1, 0, 6, "── Levels ──",     text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 6, "",                 text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz)

    // Row 7 — Nearest Support
    table.cell(dash1, 0, 7, "Near Support",     text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 7, supStr,             text_color=i_bullCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 8 — Nearest Resistance
    table.cell(dash1, 0, 8, "Near Resist",      text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 8, resStr,             text_color=i_bearCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 9 — VWAP Anchor
    table.cell(dash1, 0, 9, "VWAP Anchor",     text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 9, i_vwapAnchor,      text_color=C_GOLD,   bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Rows 10-15 — HTF Section (conditional)
    if i_showHtfSection
        string htfS_vwapStr = close > htfS_vwap ? "▲ Above" : "▼ Below"
        color  htfS_vwapCol = close > htfS_vwap ? i_bullCol : i_bearCol
        string htfS_rsiStr  = str.tostring(math.round(htfS_vwRsi, 1))
        color  htfS_rsiCol  = htfS_vwRsi > i_rsiMid ? i_bullCol : i_bearCol
        string htfS_mfiStr  = str.tostring(math.round(htfS_mfi, 1))
        color  htfS_mfiCol  = htfS_mfi > i_mfiMid ? i_bullCol : i_bearCol
        bool   htfS_bull    = close > htfS_vwap and htfS_vwRsi > i_rsiMid
        bool   htfS_bear    = close < htfS_vwap and htfS_vwRsi < i_rsiMid
        string htfS_agreStr = htfS_bull ? "▲ BULL" : htfS_bear ? "▼ BEAR" : "● HOLD"
        color  htfS_agreCol = htfS_bull ? i_bullCol : htfS_bear ? i_bearCol : i_holdCol

        // Row 10 — HTF Divider
        table.cell(dash1, 0, 10, "── HTF " + i_htfSectionTF + " ──", text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 10, htfS_agreStr,  text_color=htfS_agreCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

        // Row 11 — HTF VWAP
        table.cell(dash1, 0, 11, "VWAP",        text_color=C_MUTED,   bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 11, htfS_vwapStr,  text_color=htfS_vwapCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

        // Row 12 — HTF VW RSI
        table.cell(dash1, 0, 12, "VW RSI",      text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 12, htfS_rsiStr,   text_color=htfS_rsiCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

        // Row 13 — HTF MFI
        table.cell(dash1, 0, 13, "MFI",         text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 13, htfS_mfiStr,   text_color=htfS_mfiCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

        // Row 14 — HTF Filter status
        table.cell(dash1, 0, 14, "HTF Filter",  text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 14, i_useHTF ? "ON" : "OFF", text_color=i_useHTF ? C_PURP : C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

        // Row 15 — TF Check warning
        bool isBelowMin = timeframe.in_seconds() < 30 * 60
        table.cell(dash1, 0, 15, "TF Check",    text_color=C_MUTED,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
        table.cell(dash1, 1, 15, isBelowMin ? "⚠ <30m" : "✓ OK", text_color=isBelowMin ? i_holdCol : i_bullCol, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

    // Row 16 — Brand
    table.cell(dash1, 0, 16, "ANONYCRYPTOUS",   text_color=C_PURP,  bgcolor=C_PANEL, text_size=sz, text_halign=text.align_left)
    table.cell(dash1, 1, 16, "VCE v1.0",            text_color=C_MUTED, bgcolor=C_PANEL, text_size=sz, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════
// MTF BAR — 6 configurable timeframes, triangles + colored labels
// ═══════════════════════════════════════════════════════════════════════════════
f_mtfAgreement(simple string tf) =>
    float r_vwap  = request.security(syminfo.tickerid, tf, ta.vwap)
    float r_vwRsi = request.security(syminfo.tickerid, tf, vwRsi)
    float r_close = request.security(syminfo.tickerid, tf, close)
    bool  b = r_close > r_vwap and r_vwRsi > 50
    bool  s = r_close < r_vwap and r_vwRsi < 50
    b ? 1 : s ? -1 : 0

f_mtfCol(int v) =>
    v == 1 ? i_bullCol : v == -1 ? i_bearCol : i_holdCol

f_mtfTriangle(int v) =>
    v == 1 ? "▲" : v == -1 ? "▼" : "●"

int mtf_s1 = f_mtfAgreement(i_mtfTF1)
int mtf_s2 = f_mtfAgreement(i_mtfTF2)
int mtf_s3 = f_mtfAgreement(i_mtfTF3)
int mtf_s4 = f_mtfAgreement(i_mtfTF4)
int mtf_s5 = f_mtfAgreement(i_mtfTF5)
int mtf_s6 = f_mtfAgreement(i_mtfTF6)

// MTF bar: 2 rows × 7 cols
var table dash2 = table.new(position.bottom_left, 7, 2,
    bgcolor=C_BG, border_color=C_BDR, border_width=1, frame_color=C_BDR, frame_width=1)

if i_showDash2 and barstate.islast
    table.set_position(dash2, f_pos(i_dash2Pos))
    string sz = f_sz(i_dash2Sz)

    // Row 0 — TF labels, colored to match agreement
    table.cell(dash2, 0, 0, "MTF",      text_color=C_PURP,                bgcolor=C_BG,    text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 1, 0, i_mtfTF1,  text_color=f_mtfCol(mtf_s1),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 2, 0, i_mtfTF2,  text_color=f_mtfCol(mtf_s2),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 3, 0, i_mtfTF3,  text_color=f_mtfCol(mtf_s3),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 4, 0, i_mtfTF4,  text_color=f_mtfCol(mtf_s4),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 5, 0, i_mtfTF5,  text_color=f_mtfCol(mtf_s5),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 6, 0, i_mtfTF6,  text_color=f_mtfCol(mtf_s6),      bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)

    // Row 1 — Triangles, colored to match agreement
    table.cell(dash2, 0, 1, "●",                    text_color=C_PURP,           bgcolor=C_BG,    text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 1, 1, f_mtfTriangle(mtf_s1),  text_color=f_mtfCol(mtf_s1), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 2, 1, f_mtfTriangle(mtf_s2),  text_color=f_mtfCol(mtf_s2), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 3, 1, f_mtfTriangle(mtf_s3),  text_color=f_mtfCol(mtf_s3), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 4, 1, f_mtfTriangle(mtf_s4),  text_color=f_mtfCol(mtf_s4), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 5, 1, f_mtfTriangle(mtf_s5),  text_color=f_mtfCol(mtf_s5), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)
    table.cell(dash2, 6, 1, f_mtfTriangle(mtf_s6),  text_color=f_mtfCol(mtf_s6), bgcolor=C_PANEL, text_size=sz, text_halign=text.align_center)

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE BOX ON PRICE CHART — full span high/low like VW RSI Pro
// ═══════════════════════════════════════════════════════════════════════════════
if i_showDivBox and i_showDiv
    if isBullDiv and not na(array.get(pivLBars, 1))
        int   bx1     = array.get(pivLBars, 1)
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
            border_color = color.new(i_bullCol, 40),
            border_style = line.style_solid,
            bgcolor      = color.new(i_bullCol, i_divBoxTransp),
            border_width = 1)
        label.new(bx2, boxTop, "▲ Bull Div",
            style     = label.style_label_lower_left,
            color     = color.new(i_bullCol, 70),
            textcolor = i_bullCol,
            size      = size.tiny)

    if isBearDiv and not na(array.get(pivHBars, 1))
        int   bx1     = array.get(pivHBars, 1)
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
            border_color = color.new(i_bearCol, 40),
            border_style = line.style_solid,
            bgcolor      = color.new(i_bearCol, i_divBoxTransp),
            border_width = 1)
        label.new(bx2, boxTop, "▼ Bear Div",
            style     = label.style_label_lower_left,
            color     = color.new(i_bearCol, 70),
            textcolor = i_bearCol,
            size      = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(isBull and not isBull[1], "Bull Agreement",      "VCE — Bull agreement: VWAP + VW RSI + MFI aligned bullish")
alertcondition(isBear and not isBear[1], "Bear Agreement",      "VCE — Bear agreement: VWAP + VW RSI + MFI aligned bearish")
alertcondition(isHold and not isHold[1], "Hold Zone",           "VCE — Hold zone: indicators conflicting, stand aside")
alertcondition(isBullDiv,               "Bullish Divergence",   "VCE — Bullish divergence detected on VW RSI")
alertcondition(isBearDiv,               "Bearish Divergence",   "VCE — Bearish divergence detected on VW RSI")
````
