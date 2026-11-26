# Ultimate Scalping Tool 2.0 [BullByte]

- url: https://www.tradingview.com/script/kPWyXkFM-Ultimate-Scalping-Tool-2-0-BullByte/
- type: indicator
- pine_id: PUB;21ce750e7ed0447c9583ab00af2c8acf
- version: 1.0

## Description

[b]Ultimate Scalping Tool 2.0 [BullByte][/b]


[b]What This Tool Was Built For[/b]

UST 2.0 is a flux oscillator designed to help scalpers and intraday traders read market state more clearly. It sits in the lower pane of your chart and shows you whether the current market environment is trending cleanly, compressing before a move, chopping in a range, or losing momentum after an extension.

[b]The core idea is simple. Four internal measurements feed into one oscillator.[/b] Each measurement looks at a different part of market behavior: how cleanly price is traveling, whether momentum is meaningful given current volatility, what volatility itself is doing, and whether participation is building or fading. These four readings are weighted differently depending on what the market is doing right now. During a trend, directional measurements get more weight. During compression, volatility and flow get more weight. During a range, momentum and participation matter most.

The output is displayed as a candle on the oscillator pane. The candle color, the regime label, the confluence histogram, and the structural overlays all update on every bar to give you a current read on conditions. This is not a signal generator. It is a state monitor. You still need to decide when and how to act.

---

[b]Why Version 2.0 Exists Separately[/b]

[url=https://www.tradingview.com/script/bJmQCnNG-Ultimate-Scalping-Tool-BullByte/]Ultimate Scalping Tool Version 1.0[/url] is still published. It uses a different internal structure and outputs labeled signals like Strong Buy and Pullback Sell. Many traders built their workflows around that approach, and changing it would have broken their setups. Keeping both versions available lets traders choose the workflow that fits how they trade.

[image]https://www.tradingview.com/x/P27ByUvL/[/image]

Version 2.0 shifts away from signal labels toward market state classification. The four internal measurements are different. The adaptive weighting engine is different. The visual output is different. The confluence scoring, multi-timeframe context, and oscillator-native zones are all new. The two scripts serve related but different purposes, which is why they exist side by side rather than as an update that replaces the first one.

The continuity between them is the Flux State Candle concept. That visualization approach worked well enough in version 1.0 that it became the foundation for how version 2.0 displays its output.

---

[b]One Engine, Not a Collection of Indicators[/b]

This is worth addressing directly because it is easy to look at a script that mentions RSI, ATR, and Bollinger Bands and assume it is just wrapping existing indicators together. That is not what is happening here.

RSI does not appear on the chart. ATR does not appear on the chart. Bollinger Bands do not appear on the chart. None of the four internal measurements produce a visible output of their own. They are inputs into a calculation that produces one single output: the Flux Oscillator value. That value is then displayed as a candle.

The reason RSI is used inside the Adaptive Momentum subsystem is not because RSI is a good indicator to show. It is because RSI gives a normalized momentum reading on a known scale, which makes it easier to combine mathematically with the other three measurements on equal footing. The period is not fixed. It changes at runtime based on current volatility, which standard RSI does not do. The output is scaled before it enters the weighting engine. What comes out the other side is not RSI. It is one weighted component of a composite reading.

The same logic applies to ATR inside the Volatility Regime subsystem and to bar-structure calculations inside the Flow Proxy. These are raw materials, not finished products. They feed a pipeline that produces something different from any of them individually.

[b]The four subsystems were chosen because they answer four different questions: is price traveling efficiently, is momentum meaningful right now, is volatility expanding or contracting, and is participation building or fading.[/b] Those four questions together give a more complete picture of market state than any one of them alone. That is the design intent, and it is why the adaptive weighting engine matters. Different market conditions make different questions more relevant. The engine adjusts accordingly.

---

[b]The Four Internal Measurements[/b]

The oscillator is built on four subsystems. Each one measures something the others do not.

[b]Directional Efficiency[/b] looks at how cleanly price is moving. A market that travels 100 points in a straight line has high efficiency. A market that gyrates up and down while netting only 20 points forward has low efficiency. This helps you see whether a trending move is organized or grinding. For scalping, clean efficient moves are easier to work with than choppy grinders.

[b]Adaptive Momentum[/b] uses RSI internally but selects the period based on current volatility. When volatility is high, it uses a shorter period to stay responsive. When volatility is low, it uses a longer period to reduce noise. The reading is then adjusted so that momentum in a high-volatility environment is not overstated and momentum in a quiet environment is not understated.

[b]Volatility Regime[/b] combines three volatility signals: where ATR sits within its recent range, whether short-window ATR is rising or falling relative to long-window ATR, and where Bollinger Band width sits within its range. Positive values mean volatility is expanding. Negative values mean it is contracting. Deep negative values below -0.20 usually mean the market is compressing hard, which often precedes directional expansion.

[b]Flow Proxy[/b] estimates directional participation from bar structure and relative volume. It approximates buying versus selling pressure using close position within range, price velocity weighted by volume, and absorption detection for high-volume bars with small bodies. This is not true order flow because that requires tick data. It is a proxy built from OHLCV data, and it behaves like one.

These four readings are combined using weights that shift based on what the market is doing. You get one oscillator value per bar. That value is displayed as a candle, classified into a regime state, scored for confluence, and optionally blended with a higher-timeframe context reading.

---

[b]How the Regime Classification Works[/b]

The script classifies every bar into one of four states: [b]TREND UP, TREND DOWN, COIL, or RANGE.[/b]

When efficiency is strong, momentum is aligned, and volatility is not compressing, the regime is [b]TREND[/b]. When efficiency is low, volatility is compressing hard, and participation is building, the regime is [b]COIL[/b]. When none of those conditions are met, the regime is [b]RANGE[/b].

The regime label appears near the bottom of the pane on the last bar. The background tint changes subtly based on the regime. This classification affects how the four measurements are weighted before they combine into the oscillator value.

---

[b]The Confluence Histogram[/b]

The gold histogram at the bottom of the pane shows the confluence score from 0 to 100. The score measures how aligned six independent factors are: regime matches oscillator direction, oscillator magnitude is strong, the four internal measurements agree on direction, the higher timeframe aligns with the current one, flow quality is clean without absorption, and volatility context supports the current structure.

A low score means conditions are mixed or weak. A high score means the environment is organized and several factors are confirming the same picture. The histogram grows taller as the score rises. When the bar is short and dark amber, confluence is low. When the bar is tall and bright gold, confluence is high.

This is useful for filtering. If you are watching for a breakout from a consolidation and confluence is at 80, the setup has more environmental support than the same breakout pattern with confluence at 30. The score does not tell you to enter or exit. It tells you whether the broader conditions are organized or scattered.

---

[b]How to Read the Flux State Candle[/b]

The candle is built from the oscillator value, not from price. [b]Green candles mean the oscillator is above its moving average. Red candles mean it is below. Violet candles mean a volume absorption bar was detected[/b], which is a specific condition where high volume produced a small-bodied bar.

The border brightness increases when the oscillator is further from its moving average. A bright border means conviction. A dim border means the reading is close to neutral.

When the candle is consistently green and the cloud below it is stacked with the fast line above the slow line, the oscillator trend is internally aligned in a bullish direction. When the candle flips to red and the cloud inverts, the oscillator trend is bearish. When the cloud is mixed and candles are alternating color frequently, the oscillator is in a transition or range state.

---

[b]Oscillator-Native Zones and Trendlines[/b]

The red and green-cyan lines you see on the oscillator pane are support and resistance zones, but they are zones on the oscillator itself, not on price. They mark levels where the oscillator has repeatedly turned. These are built from confirmed pivot highs and lows.

When the oscillator approaches a red resistance zone that has been touched five times, you know the flux reading is approaching a level where it has reversed before. If price is near a key price level at the same time and confluence is high, that convergence can add weight to a reversal setup you are already watching on the price chart.

The cyan and orange trendlines work the same way. They connect confirmed swing points on the oscillator. A cyan ascending trendline from oscillator swing lows tells you the oscillator structure is building higher. An orange descending trendline from oscillator swing highs tells you the oscillator structure is weakening lower. These lines appear after the swing points are confirmed, not before.

All of these structural tools use confirmed pivot logic, which means they appear a few bars after the actual turning point. This is intentional. Unconfirmed pivots fail frequently. Waiting for confirmation removes most of the false starts. When you see a zone or trendline appear or update, it is showing you structure that has been validated by subsequent price action, not structure that might form.

[b]Reading the oscillator structure in practice looks like this.[/b]

Two red resistance lines sitting around +25 and +30 on the oscillator, both labelled [b]R MAJO[/b]R, tell you that every time flux has pushed up into that band it has been rejected. That ceiling has held six and seven touches respectively. Until flux breaks and closes above those two red lines, the upside is capped on the oscillator. Below there is an[b] S ZONE[/b] 3T sitting near -15. That is the floor that has caught the most recent bounce.

On the trendline side, three cyan ascending lines rising from the lower left are bull trendlines built from oscillator swing lows. The lowest at TL 52% is the broadest support. The middle at TL 66% is tighter. The top at [b]TL 74%[/b] is the steepest and most recent. If flux bounces off the TL 74% line, that is the most important touch right now. An orange descending line pressing down from above is the bear trendline. When flux is squeezed between a rising cyan trendline and a falling orange trendline, that is a classic wedge compression on the oscillator and it often precedes a directional expansion once one side breaks.

[image]https://www.tradingview.com/x/Tz4JeEs5/[/image]

---

[b]Divergence Labels[/b]

When the oscillator and price stop agreeing on direction, the divergence engine marks it on the chart.

There are four labels. Each one means something specific.

[b]DIV+[/b] appears below the oscillator at a swing low. It means price made a lower low on the price chart, but the oscillator made a higher low at the same point. The downward move is losing internal support. This is regular bullish divergence and it tends to appear near potential exhaustion of a downward move.

[b]DIV-[/b] appears above the oscillator at a swing high. It means price made a higher high on the price chart, but the oscillator made a lower high at the same point. The upward move is losing internal support. This is regular bearish divergence and it tends to appear near potential exhaustion of an upward move.

[b]H+[/b] appears as a small circle at a swing low. It means price made a higher low, a normal pullback in an uptrend, but the oscillator made a lower low. The oscillator dipped deeper than price did. This is hidden bullish divergence. It often appears mid-trend during a pullback and can suggest the trend is likely to continue.

[b]H-[/b] appears as a small circle at a swing high. It means price made a lower high, a normal pullback in a downtrend, but the oscillator made a higher high. The oscillator pushed higher than price did. This is hidden bearish divergence. It often appears mid-trend during a bounce and can suggest the downtrend is likely to continue.

All four labels appear a few bars after the actual swing point because the pivot must be confirmed by subsequent bars before the label is placed. When you see a label appear, it is sitting on a past bar where the swing has already been validated. Nothing is marked in advance. The label was not there before, and it will not move or disappear after it appears.

---

[b]How This Fits Into a Price Action Workflow[/b]

Here is one example of how the tool can layer into a real trade setup.

You are watching a 5-minute chart. Price has been consolidating in a tight range for the last hour. On the main price chart, you see a clean horizontal level being tested multiple times. That is your setup area. You are waiting for a breakout.

You glance at the oscillator pane. The regime label says COIL. The flux candles are small and alternating color near the zero line. The confluence histogram is rising and just reached 65. VRI in the dashboard shows -0.25, which is hard compression. COFP is positive and building.

This tells you the oscillator agrees with what you are seeing on price: the market is compressing. Volatility is contracting. Participation is starting to build in one direction. Confluence is improving, meaning the internal measurements are starting to agree.

You wait. Price breaks the consolidation upward on increased volume. At the same moment, the flux candle turns bright green with a strong border. The regime label flips to TREND UP. The confluence histogram jumps to 78. The cloud stacks bullish. The dashboard shows all four internal measurements turned positive.

You already know where your entry is from the price chart. The oscillator is not telling you to buy. The oscillator is telling you the conditions support the breakout you are watching. Efficiency turned positive, meaning price is traveling cleanly. Momentum confirmed. Volatility started expanding. Flow is directional. The environment is organized.

You take the trade based on your price-action plan. You manage the trade from price structure. But while you are in the trade, you glance at the oscillator occasionally. If the flux candle stays green and confluence stays high, conditions remain supportive. If the candle turns red and confluence drops, you tighten your management because the internal read is weakening.

[b]A real chart example of what COIL into expansion looks like:[/b] Gold on the 3-minute chart shows a full cycle, a base building through the early session, a strong impulsive rally, then a controlled rollover where the oscillator hugs just above zero with the regime label reading COIL. The oscillator has compressed hard after the post-peak selloff, and the cyan ascending bull trendline is now acting as the floor of the oscillator structure. This is the compression phase the tool is designed to identify before the next directional move develops.

[image]https://www.tradingview.com/x/eMqyhmzs/[/image]
---

[b]What This Tool Does Not Do[/b]

This script does not tell you where to enter or exit. It does not produce buy and sell signals. The flux candle, the regime label, the confluence score, and the structural overlays all describe conditions, not actions.

The zones and trendlines on the oscillator are not price levels. They are oscillator levels. They tell you where the oscillator has turned before, not where price will turn next.

The HTF oscillator is a simplified version of the current-timeframe calculation. It uses fixed parameters and reduced components for cross-timeframe stability. It is useful for context, but it is not identical to the full engine running on the higher timeframe.

[b]Pivot-based elements appear after confirmation, which means they lag the actual pivot by the confirmation period[/b]. This is intentional. The tradeoff is fewer false signals at the cost of slightly delayed information.

Confluence measures environmental alignment, not trade direction. A high score means conditions are organized. A low score means they are not. Neither tells you to buy or sell.

---

[b]Recommended Timeframes and Settings[/b]

This tool works best on intraday timeframes from 1 minute to 1 hour. For active scalping, use 1-minute to 5-minute charts with the HTF set to 15 minutes. For slightly slower intraday swings, use 15-minute to 60-minute charts with the HTF set to 4 hours or daily.

The multi-timeframe panel should show timeframes that are meaningfully different from your chart timeframe. If you are on 5 minutes, set the panel to 15 minutes, 60 minutes, and 240 minutes. If the panel shows timeframes that are too close together, the readings will be nearly identical and provide no additional information.

The default settings are balanced for general use. If the oscillator is too noisy, increase the DER length or the AMVS base period. If the oscillator is too slow, decrease them. If zones and trendlines are appearing too frequently, increase the minimum touch requirements. If they are not appearing enough, decrease them.

The adaptive weighting setting should generally stay on unless you have a specific reason to use fixed manual weights. The adaptive behavior is part of how the tool adjusts to different market conditions.

---

[b]Understanding the Limitations[/b]

[b]No indicator can predict the future[/b]. This tool shows you the current state of several internal measurements and how aligned they are. It does not know what will happen next.

Markets can shift from organized to chaotic in seconds. A high confluence reading can drop to low confluence on the next bar if one of the internal measurements changes direction. That is normal. [b]The tool is reactive, not predictive[/b].

The S/R zones and trendlines are based on past oscillator behavior. Just because the oscillator turned at a zone five times before does not mean it will turn there again. [b]Past structure informs context but does not guarantee repetition.[/b]

Divergence suggests momentum quality is changing. It does not guarantee reversal. Many divergences resolve with price continuing in the original direction after a brief pause or consolidation.

Volume absorption detection is based on relative volume and body size. It identifies a specific bar condition but does not tell you how the market will respond to that condition.

---

[b]A Note on Expectations[/b]

This script was built to give scalpers and intraday traders more clarity about market state. It was not built to replace chart reading, price action analysis, or trade management discipline.

If you are looking for a tool that tells you exactly when to enter and exit, this is not that tool. If you are looking for a tool that helps you see whether the current environment is organized or messy, whether internal measurements are aligned or conflicting, and whether higher-timeframe context supports or opposes your intended direction, this can help with that.

The best results come when the oscillator is used as confirmation for setups you are already identifying from price structure, not as a standalone signal generator. The flux candle, regime label, confluence score, and structural overlays are all context layers. They work best when layered on top of solid price action principles, not in place of them.

---

[b]Disclaimer[/b]

This script is published for educational purposes. Trading involves substantial risk of loss. No indicator or tool can eliminate that risk. Past performance of any indicator does not predict future results. The author is not responsible for any trading decisions made using this script. Always apply your own risk management, test thoroughly on demo or simulation before live use, and never risk more than you can afford to lose.

-[b]BullByte[/b]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte
//
// ════════════════════════════════════════════════════════════════════════════
//  ULTIMATE SCALPING TOOL 2.0 [BullByte]
//  Version  : 2.0.0
//  Previous : UST 1.0 [BullByte] - remains published and unchanged
// ════════════════════════════════════════════════════════════════════════════
//
//  WHAT THIS INDICATOR IS
//  ─────────────────────────────────────────────────────────────────────────
//  UST 2.0 is a single unified market-state engine built on four original
//  measurement sub-systems that feed into one pipeline:
//
//    DER  → measures directional efficiency of price movement
//    AMVS → measures momentum scaled to the current volatility regime
//    VRI  → measures volatility state across three components
//    COFP → approximates order flow direction from OHLCV data
//
//  These four sub-systems are combined by a regime-aware adaptive weighting
//  engine that shifts the contribution of each component based on whether the
//  market is trending, ranging, or coiling before a breakout.
//
//  The weighted output becomes the Flux Oscillator, displayed as a Flux State
//  Candle (FSC). A six-component Confluence Score (0-100) measures how well
//  aligned the environment is across regime, momentum, agreement, HTF bias,
//  flow quality and volatility context.
//
//  Optional visual overlays - MA Cloud, S/R Zones, Trendlines, Divergence -
//  are drawn on the oscillator pane using confirmed pivot logic. They are
//  confirmation tools, not predictive signals. All pivot-based elements
//  appear after the pivot is confirmed, which means they are offset by the
//  right-pivot lookback bars. This is intentional and disclosed.
//
//  WHAT THIS INDICATOR IS NOT
//  ─────────────────────────────────────────────────────────────────────────
//  This is not a buy/sell signal generator. It does not repaint. It does not
//  use request.security() with lookahead. It is not a strategy. The Confluence
//  Score measures environment quality, not trade direction. No element of this
//  script guarantees any outcome in live or simulated trading.
//
//  DISCLAIMER
//  ─────────────────────────────────────────────────────────────────────────
//  This script is published for educational and analytical purposes only.
//  Trading involves substantial risk of loss. Past indicator behavior is not
//  indicative of future results. The author accepts no responsibility for
//  trading decisions made using this tool. Always apply your own risk
//  management framework.
//
// ════════════════════════════════════════════════════════════════════════════

//@version=6
indicator('Ultimate Scalping Tool 2.0 [BullByte]',
     shorttitle  = 'UST 2.0 [BullByte]',
     overlay     = false,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_labels_count = 500)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 1 - COLOR SYSTEM
//  Naming convention: CLR_[FAMILY]_[INTENSITY]
//  Green = bull | Red = bear | Neutral = structure and text
//  Each role is unique - no two elements share the same color
// ════════════════════════════════════════════════════════════════════════════

// Bull signal family
color CLR_BULL_STRONG = #00ff41   // Primary bull - flux candle, labels, dashboard values
color CLR_BULL_MED    = #00cc33   // Secondary bull - candle body fill
color CLR_BULL_SOFT   = #008f11   // Tertiary bull - cloud fill, reference line
color CLR_BULL_DIM    = #003b00   // Background wash - trending bull regime

// Bear signal family
color CLR_BEAR_STRONG = #ff0000   // Primary bear - flux candle, labels, dashboard values
color CLR_BEAR_MED    = #cc0000   // Secondary bear - candle body fill
color CLR_BEAR_SOFT   = #880000   // Tertiary bear - cloud fill, reference line
color CLR_BEAR_DIM    = #330000   // Background wash - trending bear regime

// Neutral and structure
color CLR_BLACK    = #000000   // Dashboard background
color CLR_PANEL    = #050f05   // Header and cell backgrounds
color CLR_RANGE_BG = #080808   // Range regime background
color CLR_COIL_BG  = #0c0c04   // Coil regime background
color CLR_WHITE    = #e0ffe0   // Primary text on dark backgrounds
color CLR_DIM      = #607060   // Secondary text and inactive labels
color CLR_GHOST    = #1a2a1a   // Disabled fills and ghost elements

// Unique accent roles - each assigned to one element only
color CLR_DIV_REG    = #00ffff   // Regular divergence labels - cyan
color CLR_DIV_HID    = #007777   // Hidden divergence labels - dim cyan
color CLR_MA_FAST    = #39ff14   // Fast MA line - chartreuse
color CLR_MA_MED     = #ffffff   // Medium MA line - white
color CLR_MA_SLOW    = #ff6600   // Slow MA line - orange
color CLR_ABSORPTION = #cc00ff   // Absorption bars - violet, unique state

// Structure element colors - visually distinct from candles and each other
color CLR_SR_RES  = #ff2222   // Resistance zones - bright red
color CLR_SR_SUP  = #00ff88   // Support zones - bright green-cyan
color CLR_TL_BULL = #00ffff   // Bull trendlines - cyan (different from SR sup)
color CLR_TL_BEAR = #ff8800   // Bear trendlines - orange (different from SR res)

// Confluence histogram color family - amber gold, direction-neutral quality indicator
// Distinct from all other color roles in the system
color CLR_CONF_HIGH = #ffd700   // Bright gold - high and elite confluence
color CLR_CONF_MED  = #cc9900   // Mid amber - moderate and good confluence
color CLR_CONF_LOW  = #665500   // Dark amber - low confluence

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 2 - INPUTS
//  Organized by functional group with tooltips on every setting
// ════════════════════════════════════════════════════════════════════════════

// ── Core Engine ─────────────────────────────────────────────────────────────
const string GRP_CORE = 'Core Engine'

derLen = input.int(14, 'DER Length',
     minval  = 5,
     maxval  = 50,
     group   = GRP_CORE,
     tooltip = 'Number of bars used to calculate the Directional Efficiency Ratio. Higher values smooth the ratio but reduce sensitivity. Range 5-50. Default 14.')

amvsBase = input.int(14, 'AMVS Base Period',
     minval  = 5,
     maxval  = 30,
     group   = GRP_CORE,
     tooltip = 'Base RSI period for the Adaptive Momentum engine. The engine selects from three fixed periods (8, 14, 21) based on the current volatility regime relative to this base. Default 14.')

vriLen = input.int(14, 'VRI ATR Length',
     minval  = 5,
     maxval  = 30,
     group   = GRP_CORE,
     tooltip = 'ATR length used inside the Volatility Regime Index. Controls the sensitivity of the primary ATR component. Default 14.')

vriLookback = input.int(100, 'VRI Lookback',
     minval  = 50,
     maxval  = 200,
     group   = GRP_CORE,
     tooltip = 'Historical window for normalizing ATR ratio and Bollinger Band width within the VRI. Larger values produce a more stable baseline. Default 100.')

cofpDeltaLen = input.int(3, 'COFP Smoothing',
     minval  = 1,
     maxval  = 10,
     group   = GRP_CORE,
     tooltip = 'EMA smoothing period applied to the bar-delta signal inside the Composite Order Flow Proxy. Lower values react faster. Default 3.')

// ── Adaptive Weighting ───────────────────────────────────────────────────────
var string GRP_WEIGHT = 'Adaptive Weighting'

enableAdaptive = input.bool(true, 'Enable Adaptive Weighting',
     group   = GRP_WEIGHT,
     tooltip = 'When enabled the engine shifts DER/AMVS/VRI/COFP weights automatically based on detected regime. When disabled the four manual weights below are used as fixed constants throughout all conditions.')

wDER_input = input.float(0.25, 'DER Weight - Manual',
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GRP_WEIGHT,
     tooltip = 'Manual weight for the Directional Efficiency Ratio component. Only active when Adaptive Weighting is disabled. All four weights are auto-normalized so they do not need to sum to 1.0.')

wAMVS_input = input.float(0.25, 'AMVS Weight - Manual',
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GRP_WEIGHT,
     tooltip = 'Manual weight for the Adaptive Momentum component. Only active when Adaptive Weighting is disabled.')

wVRI_input = input.float(0.25, 'VRI Weight - Manual',
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GRP_WEIGHT,
     tooltip = 'Manual weight for the Volatility Regime Index component. Only active when Adaptive Weighting is disabled.')

wCOFP_input = input.float(0.25, 'COFP Weight - Manual',
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GRP_WEIGHT,
     tooltip = 'Manual weight for the Composite Order Flow Proxy component. Only active when Adaptive Weighting is disabled.')

// ── HTF Blend ────────────────────────────────────────────────────────────────
var string GRP_HTF = 'HTF Blend'

enableHTFBlend = input.bool(true, 'Enable HTF Blend',
     group   = GRP_HTF,
     tooltip = 'When enabled the final oscillator is a weighted blend of the current timeframe oscillator and the same oscillator computed on the higher timeframe. This adds multi-timeframe context without switching charts.')

htfTF = input.timeframe('15', 'Higher Timeframe',
     group   = GRP_HTF,
     tooltip = 'The higher timeframe used for the HTF component. Should be at least 3x the current chart timeframe. Example: use 15m when charting 1m or 5m.')

htfAdaptive = input.bool(false, 'HTF Uses Adaptive Weights',
     group   = GRP_HTF,
     tooltip = 'When off the HTF oscillator uses equal fixed weights of 0.25 for each component, which is mathematically stable across all timeframes. When on the HTF uses the same adaptive weights as the current timeframe.')

htfBlendRatio = input.float(0.70, 'Current TF Weight in Blend',
     minval  = 0.50,
     maxval  = 0.90,
     step    = 0.05,
     group   = GRP_HTF,
     tooltip = 'How much of the final oscillator value comes from the current timeframe vs the HTF. 0.70 means 70 percent current and 30 percent HTF. Higher values give more weight to local price action.')

// ── Flux State Candle ─────────────────────────────────────────────────────────
var string GRP_FSC = 'Flux State Candle'

fscShow = input.bool(true, 'Show Flux State Candle',
     group   = GRP_FSC,
     tooltip = 'Displays the oscillator as a candle chart. Green candles indicate the flux is above its moving average. Red candles indicate flux is below. Violet indicates volume absorption state. This is not a price candle.')

fscMALen = input.int(10, 'Flux MA Period',
     minval  = 3,
     maxval  = 50,
     group   = GRP_FSC,
     tooltip = 'Period of the EMA applied to the flux value. The candle color is determined by whether the current flux is above or below this moving average. Also plotted as the green line on the pane.')

fscScale = input.float(100.0, 'Flux Scale',
     minval  = 10.0,
     maxval  = 500.0,
     group   = GRP_FSC,
     tooltip = 'Multiplier applied to the normalized flux value before display. Default 100 means the oscillator range is approximately -100 to +100. Adjust if you want a different visual scale.')

enableVolWeight = input.bool(true, 'Volume Weighted Flux',
     group   = GRP_FSC,
     tooltip = 'When enabled bars with above-average volume amplify the flux signal slightly. Volume weight is capped at 2x to prevent spikes from dominating. The influence is controlled by the Volume Influence parameter.')

volAlpha = input.float(0.3, 'Volume Influence',
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.1,
     group   = GRP_FSC,
     tooltip = 'Controls how strongly volume amplifies the flux signal when Volume Weighted Flux is on. 0 means no volume effect. 1 means full effect. Default 0.3 gives a gentle volume response.')

// ── MA Cloud ──────────────────────────────────────────────────────────────────
var string GRP_MA = 'MA Cloud'

enableMACloud = input.bool(true, 'Enable MA Cloud',
     group   = GRP_MA,
     tooltip = 'Plots three EMAs on the flux and fills the space between them with a color cloud. Green cloud when fast above slow. Red cloud when fast below slow. Neutral when mixed.')

ma1Len = input.int(5, 'Fast EMA Period',
     minval  = 2,
     maxval  = 50,
     group   = GRP_MA,
     tooltip = 'Period for the fastest EMA in the cloud system. Plotted in chartreuse. Shorter periods react faster to flux changes.')

ma2Len = input.int(10, 'Medium EMA Period',
     minval  = 3,
     maxval  = 100,
     group   = GRP_MA,
     tooltip = 'Period for the middle EMA in the cloud system. Plotted in white. Acts as the reference axis for cloud direction.')

ma3Len = input.int(21, 'Slow EMA Period',
     minval  = 5,
     maxval  = 200,
     group   = GRP_MA,
     tooltip = 'Period for the slowest EMA in the cloud system. Plotted in orange. Represents the longer-term flux trend.')

cloudOpacity = input.int(88, 'Cloud Fill Transparency',
     minval  = 70,
     maxval  = 98,
     group   = GRP_MA,
     tooltip = 'Controls how transparent the cloud fill is. Higher number means more transparent. 88 gives a subtle wash without obscuring candles.')

// ── Regime Engine ──────────────────────────────────────────────────────────────
var string GRP_REGIME = 'Regime Engine'

enableRegimeBG = input.bool(true, 'Show Regime Background Color',
     group   = GRP_REGIME,
     tooltip = 'Tints the pane background based on detected market regime. Green wash for bull trend, red wash for bear trend, yellow for coil, neutral for range. Very subtle by design.')

showRegimeLabel = input.bool(true, 'Show Regime Label on Chart',
     group   = GRP_REGIME,
     tooltip = 'Displays the current regime text label near the bottom of the pane at the right edge. Updates on the last bar only. Shows TREND UP, TREND DOWN, COIL or RANGE.')

// ── Confluence Score ───────────────────────────────────────────────────────────
var string GRP_CONF = 'Confluence Score'

enableConfLine = input.bool(true, 'Show Confluence Histogram',
     group   = GRP_CONF,
     tooltip = 'Displays the confluence score as a filled histogram at the bottom of the oscillator pane. The histogram grows taller as the score rises from 0 to 100. The base sits at the Y Floor value and the maximum height is set by the Y Height value.')

confFloor = input.float(-85.0, 'Histogram Floor',
     minval  = -150.0,
     maxval  = -50.0,
     group   = GRP_CONF,
     tooltip = 'The Y position of the bottom edge of the confluence histogram. Default -85 anchors it to the base of the oscillator pane. Raise this value if you want the histogram to float higher on the pane.')

confHeight = input.float(20.0, 'Histogram Height',
     minval  = 10.0,
     maxval  = 50.0,
     group   = GRP_CONF,
     tooltip = 'The maximum height of the confluence histogram in oscillator units. At score 100 the histogram fills the full height. At score 50 it fills half. Default 20 means the histogram travels from the floor up to floor plus 20.')

showConfDash = input.bool(true, 'Show Confluence in Dashboard',
     group   = GRP_CONF,
     tooltip = 'When enabled the score, quality label and component agreement count appear as a dedicated row in the Full Panel dashboard.')

// ── Support and Resistance Zones ───────────────────────────────────────────────
var string GRP_SR = 'S/R Zones'

enableSR = input.bool(true, 'Enable S/R Zones',
     group   = GRP_SR,
     tooltip = 'Detects pivot highs and lows on the oscillator and clusters them into support and resistance zones. These are oscillator-native zones, not price levels. They represent repeated turning points in the flux reading.')

srPivotLeft = input.int(10, 'Pivot Confirmation Left Bars',
     minval  = 3,
     maxval  = 30,
     group   = GRP_SR,
     tooltip = 'Number of bars to the left required to confirm a pivot. Higher values find stronger but fewer pivots.')

srPivotRight = input.int(10, 'Pivot Confirmation Right Bars',
     minval  = 3,
     maxval  = 30,
     group   = GRP_SR,
     tooltip = 'Number of bars to the right required to confirm a pivot. This introduces an offset: zones appear this many bars after the actual pivot. This is confirmed pivot behavior and is intentional.')

maxSRZones = input.int(6, 'Maximum Active Zones',
     minval  = 2,
     maxval  = 10,
     group   = GRP_SR,
     tooltip = 'Maximum number of S/R zones kept in memory at once. When exceeded the weakest zone by touch count is removed. Keeps the display clean.')

minSRTouches = input.int(3, 'Minimum Touches to Display',
     minval  = 2,
     maxval  = 5,
     group   = GRP_SR,
     tooltip = 'A zone must be revisited at least this many times before it is drawn. Higher values show only well-established zones.')

srExtension = input.int(40, 'Zone Extension to the Right',
     minval  = 10,
     maxval  = 150,
     group   = GRP_SR,
     tooltip = 'How many bars to the right of the current bar the zone box extends. Does not affect calculations, only the visual projection of the zone into the future area of the chart.')

showSRGlow = input.bool(false, 'Show Zone Outer Glow',
     group   = GRP_SR,
     tooltip = 'Adds a wider, very transparent halo around each zone body. Makes zones easier to spot at a glance without adding visual weight.')

showSRTouchDots = input.bool(true, 'Show Touch History Markers',
     group   = GRP_SR,
     tooltip = 'Places a small marker at each historical bar where the zone was touched. Up to five markers per zone. Helps visualize how the zone has behaved in the past.')

// ── Trendlines ─────────────────────────────────────────────────────────────────
var string GRP_TL = 'Trendlines'

enableTL = input.bool(true, 'Enable Trendlines',
     group   = GRP_TL,
     tooltip = 'Detects ascending trendlines from swing lows and descending trendlines from swing highs on the oscillator. Trendlines are drawn on the last bar only and are redrawn as new pivots confirm. Cyan for bull, orange for bear.')

tlPivotLeft = input.int(8, 'Pivot Confirmation Left Bars',
     minval  = 1,
     maxval  = 30,
     group   = GRP_TL,
     tooltip = 'Left bar count for trendline pivot confirmation. Higher values find stronger swing points but react more slowly.')

tlPivotRight = input.int(5, 'Pivot Confirmation Right Bars',
     minval  = 1,
     maxval  = 20,
     group   = GRP_TL,
     tooltip = 'Right bar count for trendline pivot confirmation. This is the delay before a trendline pivot is accepted. Trendline labels appear this many bars after the actual pivot point.')

tlExtension = input.int(60, 'Trendline Extension Bars',
     minval  = 10,
     maxval  = 200,
     group   = GRP_TL,
     tooltip = 'How many bars beyond the most recent anchor point the trendline is extended. Longer extension shows where the trendline would be in the future if the slope holds.')

minTLTouches = input.int(2, 'Minimum Touch Count',
     minval  = 2,
     maxval  = 5,
     group   = GRP_TL,
     tooltip = 'A trendline must be validated by at least this many pivot points touching or near it. Higher values produce fewer but more reliable trendlines.')

showTLChannel = input.bool(true, 'Show Parallel Channel Line',
     group   = GRP_TL,
     tooltip = 'Draws a dashed parallel line offset from the main trendline to form a channel. The offset is 8 oscillator units. Useful for identifying breakout zones from within a channel.')

showTLStrength = input.bool(true, 'Show Strength Label',
     group   = GRP_TL,
     tooltip = 'Displays a percentage label at the end of each trendline showing its strength score (0-100 percent). Strength is calculated from touch count, age and slope angle.')

// ── Divergence Engine ──────────────────────────────────────────────────────────
var string GRP_DIV = 'Divergence Engine'

enableDiv = input.bool(true, 'Enable Divergence Detection',
     group   = GRP_DIV,
     tooltip = 'Activates the divergence engine which compares oscillator pivot behavior to price pivot behavior. Divergence labels appear at the confirmed oscillator pivot bar, which is divRight bars in the past. This is standard confirmed pivot behavior.')

showRegDiv = input.bool(true, 'Show Regular Divergence',
     group   = GRP_DIV,
     tooltip = 'Regular bullish: price makes lower low but oscillator makes higher low. Regular bearish: price makes higher high but oscillator makes lower high. These suggest potential reversals.')

showHidDiv = input.bool(true, 'Show Hidden Divergence',
     group   = GRP_DIV,
     tooltip = 'Hidden bullish: price makes higher low but oscillator makes lower low. Hidden bearish: price makes lower high but oscillator makes higher high. These suggest trend continuation.')

divLeft = input.int(5, 'Pivot Confirmation Left Bars',
     minval  = 1,
     maxval  = 20,
     group   = GRP_DIV,
     tooltip = 'Left bar count for divergence pivot confirmation. Matches trendline and SR pivot logic.')

divRight = input.int(2, 'Pivot Confirmation Right Bars',
     minval  = 1,
     maxval  = 10,
     group   = GRP_DIV,
     tooltip = 'Right bar count for divergence pivot confirmation. Divergence labels are plotted this many bars in the past at the actual pivot location. This is not repainting.')

divMin = input.int(5, 'Minimum Bars Between Pivots',
     minval  = 1,
     maxval  = 20,
     group   = GRP_DIV,
     tooltip = 'The two pivots being compared must be at least this many bars apart. Prevents detecting divergences on consecutive bars which would be noise.')

divMax = input.int(60, 'Maximum Bars Between Pivots',
     minval  = 10,
     maxval  = 200,
     group   = GRP_DIV,
     tooltip = 'The two pivots being compared must be no more than this many bars apart. Prevents detecting divergences across unrelated market phases.')

maxDivLabels = input.int(10, 'Maximum Labels on Chart',
     minval  = 1,
     maxval  = 50,
     group   = GRP_DIV,
     tooltip = 'Maximum number of divergence labels kept visible at once. Oldest labels are removed when the limit is reached. Prevents chart clutter on long timeframes.')

minDivGap = input.int(10, 'Minimum Bars Between Signals',
     minval  = 1,
     maxval  = 50,
     group   = GRP_DIV,
     tooltip = 'A new divergence signal of the same type cannot appear within this many bars of the previous one. Prevents clusters of the same signal type on consecutive pivots.')

// ── Dashboard ──────────────────────────────────────────────────────────────────
var string GRP_DASH = 'Dashboard'

dashType = input.string('Full Panel', 'Dashboard Type',
     options = ['Off', 'Compact Bar', 'Corner HUD', 'Full Panel'],
     group   = GRP_DASH,
     tooltip = 'Off: no dashboard. Compact Bar: single row of key values. Corner HUD: 2-column summary. Full Panel: complete readout of all engine outputs including confluence, MTF and signals.')

dashPos = input.string('Top Right', 'Dashboard Position',
     options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'],
     group   = GRP_DASH,
     tooltip = 'Corner of the pane where the dashboard is anchored. Choose the corner that does not overlap your price chart or volume bars.')

dashSz = input.string('Small', 'Dashboard Text Size',
     options = ['Tiny', 'Small', 'Normal'],
     group   = GRP_DASH,
     tooltip = 'Text size inside all dashboard cells. Tiny is best for small screens or when using the Full Panel type to minimize space usage.')

showMTFPanel = input.bool(true, 'Show Multi-Timeframe Panel',
     group   = GRP_DASH,
     tooltip = 'Adds a three-row panel to the Full Panel dashboard showing the flux state on three user-defined timeframes. States are BULL above +25, BEAR below -25, and NEUT in between.')

mtf1 = input.timeframe('15', 'MTF Row 1',
     group   = GRP_DASH,
     tooltip = 'First additional timeframe for the MTF panel. Displayed as BULL BEAR or NEUT based on the flux reading on that timeframe.')

mtf2 = input.timeframe('60', 'MTF Row 2',
     group   = GRP_DASH,
     tooltip = 'Second additional timeframe for the MTF panel.')

mtf3 = input.timeframe('240', 'MTF Row 3',
     group   = GRP_DASH,
     tooltip = 'Third additional timeframe for the MTF panel.')

// ── Reference Lines ────────────────────────────────────────────────────────────
var string GRP_REF = 'Reference Lines'

showRefLines = input.bool(true, 'Show Reference Lines',
     group   = GRP_REF,
     tooltip = 'Draws three horizontal dotted reference lines on the oscillator pane at the upper level, zero, and lower level. These are context markers not signals.')

refUpper = input.float(25.0, 'Upper Reference Level',
     group   = GRP_REF,
     tooltip = 'Y-axis position of the upper reference line. Default 25 marks the bull threshold. The flux oscillator range is approximately -100 to +100.')

refLower = input.float(-25.0, 'Lower Reference Level',
     group   = GRP_REF,
     tooltip = 'Y-axis position of the lower reference line. Default -25 marks the bear threshold.')

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 3 - UTILITY FUNCTIONS
//  All functions declared at global scope as required by Pine Script v6
// ════════════════════════════════════════════════════════════════════════════

// softClamp: maps any real number to (-1, +1) using a tanh approximation
// Uses manual formula because math.tanh is not available in Pine Script
// Formula: tanh(x) = (e^2x - 1) / (e^2x + 1)
// Safety: math.exp can overflow for large x - values beyond ±10 will saturate naturally
softClamp(x) =>
    ex = math.exp(math.max(math.min(2.0 * x, 20.0), -20.0))
    (ex - 1.0) / (ex + 1.0)

// safeDiv: division with zero-denominator guard
// Returns 0.0 when denominator is zero or effectively zero
safeDiv(a, b) =>
    b == 0.0 ? 0.0 : a / b

// tablePos: maps position string to Pine position constant
tablePos(p) =>
    p == 'Top Left'     ? position.top_left    :
     p == 'Top Right'   ? position.top_right   :
     p == 'Bottom Left' ? position.bottom_left :
     position.bottom_right

// textSz: maps size string to Pine size constant
textSz(s) =>
    s == 'Tiny'  ? size.tiny  :
     s == 'Small' ? size.tiny  :
     size.small

// cellH: header cell - dark green background, bright green text, centered
// Used for label cells in the Full Panel dashboard
cellH(tbl, col, row, txt, ts) =>
    table.cell(tbl, col, row, txt,
         text_color  = CLR_BULL_STRONG,
         bgcolor     = color.new(CLR_PANEL, 20),
         text_size   = ts,
         text_halign = text.align_center)

// cellV: value cell - near-black background, caller-supplied text color, centered
// Used for data cells in the Full Panel dashboard
cellV(tbl, col, row, txt, tc, ts) =>
    table.cell(tbl, col, row, txt,
         text_color  = tc,
         bgcolor     = color.new(CLR_BLACK, 30),
         text_size   = ts,
         text_halign = text.align_center)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 4 - DIRECTIONAL EFFICIENCY RATIO (DER)
//
//  Concept: Price movement efficiency is the ratio of net displacement to
//  total path traveled. A straight-line move scores 1.0. A random walk
//  scores near 0. The sign is taken from the net direction.
//
//  Output range: -1.0 (efficient downtrend) to +1.0 (efficient uptrend)
//  The output is smoothed with a 3-bar EMA and modulated by a persistence
//  counter that tracks how many consecutive bars DER has held its direction.
// ════════════════════════════════════════════════════════════════════════════

derCalc(len) =>
    // Net displacement over the window
    netMove = close - close[len]
    // Total path: sum of all absolute single-bar changes
    pathLen = 0.0
    for i = 0 to len - 1 by 1
        pathLen := pathLen + math.abs(close[i] - close[i + 1])
    // Efficiency ratio: 0 = random walk, 1 = perfectly directional
    // safeDiv guards against flat markets where pathLen is zero
    rawER = safeDiv(math.abs(netMove), math.max(pathLen, 0.0001))
    // Sign from direction of net move
    direction = netMove >= 0 ? 1.0 : -1.0
    rawER * direction

rawDER = derCalc(derLen)

// 3-bar EMA smoothing reduces bar-to-bar noise while preserving responsiveness
DER = ta.ema(rawDER, 3)

// Persistence counter: increments while DER is positive, decrements while negative
// Clamped to ±30 bars to prevent unbounded accumulation
var int derPersistence = 0
derPersistence := DER > 0 ? derPersistence + 1 : DER < 0 ? derPersistence - 1 : 0
derPersistence := math.max(-30, math.min(30, derPersistence))

// Confidence rises with persistence - max confidence at 15+ bars of same direction
// This scales DER contribution: confirmed trends carry more weight than brief flips
derConfidence = math.min(math.abs(derPersistence) / 15.0, 1.0)
normDER = DER * (0.6 + derConfidence * 0.4)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 5 - ADAPTIVE MOMENTUM WITH VOLATILITY SCALING (AMVS)
//
//  Concept: RSI is more meaningful when its period matches the current
//  volatility regime. In high volatility, shorter periods capture momentum
//  changes faster. In low volatility, longer periods reduce false readings.
//
//  Implementation note: Pine Script requires RSI length to be a simple int
//  known at compile time. Three fixed RSI series are pre-calculated at
//  periods 8, 14, and 21. The regime selector picks between them at runtime.
//  This achieves adaptive behavior within Pine's type constraints.
//
//  Output range: -1.0 to +1.0 after softClamp
// ════════════════════════════════════════════════════════════════════════════

// ATR ratio vs 50-bar average defines the volatility regime
// volRegime > 1.0 means current volatility is above average
atrBase   = ta.atr(amvsBase)
atrMA50   = ta.sma(atrBase, 50)
volRegime = safeDiv(atrBase, math.max(atrMA50, 0.0001))

// Three fixed RSI calculations - period selected by regime at runtime
// High vol (>1.5x average): period 8 - fast response
// Normal vol (1.0-1.5x):   period 14 - balanced
// Low vol (<1.0x average):  period 21 - smooth, reduces noise
rsi_short   = ta.rsi(close, 8)
rsi_mid     = ta.rsi(close, 14)
rsi_long    = ta.rsi(close, 21)
adaptiveRSI = volRegime > 1.5 ? rsi_short : volRegime > 1.0 ? rsi_mid : rsi_long

// Center RSI around zero and normalize to -1..+1
rawMomentum = (adaptiveRSI - 50.0) / 50.0

// Scale divisor: high volatility dampens (noisy), low volatility amplifies (subtle)
// Clamped to 0.5-2.5 to prevent division extremes
volScaleDivisor = math.max(0.5, math.min(2.5, volRegime))
AMVS = softClamp(rawMomentum / volScaleDivisor * 1.5)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 6 - VOLATILITY REGIME INDEX (VRI)
//
//  Concept: Three independent volatility measurements are combined to form
//  a composite state variable. Each component is normalized to -1..+1.
//  Positive VRI means volatility is expanding. Negative means contracting.
//
//  Component A (40%): ATR percentile position in lookback window
//  Component B (35%): Volatility momentum - short ATR vs long ATR
//  Component C (25%): Bollinger Band width percentile
//
//  Output range: approximately -1.0 to +1.0 after softClamp
// ════════════════════════════════════════════════════════════════════════════

atr14 = ta.atr(vriLen)
atr5  = ta.atr(5)
atr20 = ta.atr(20)

// Component A: Where is current ATR-to-price ratio in its historical range
atrRatio = safeDiv(atr14, close)
atrLo    = ta.lowest(atrRatio, vriLookback)
atrHi    = ta.highest(atrRatio, vriLookback)
compA    = safeDiv(atrRatio - atrLo, math.max(atrHi - atrLo, 0.0001))
compA   := compA * 2.0 - 1.0   // rescale 0..1 to -1..+1

// Component B: Is volatility accelerating or decelerating
// Positive when short ATR is rising above long ATR
volMom = safeDiv(atr5 - atr20, math.max(atr20, 0.0001))
compB  = softClamp(volMom * 3.0)

// Component C: Bollinger Band width percentile
bbBasis = ta.sma(close, 20)
bbDev   = ta.stdev(close, 20)
bbUpper = bbBasis + bbDev * 2.0
bbLower = bbBasis - bbDev * 2.0
bbw     = safeDiv(bbUpper - bbLower, math.max(bbBasis, 0.0001))
bbwLo   = ta.lowest(bbw, vriLookback)
bbwHi   = ta.highest(bbw, vriLookback)
compC   = safeDiv(bbw - bbwLo, math.max(bbwHi - bbwLo, 0.0001))
compC  := compC * 2.0 - 1.0   // rescale 0..1 to -1..+1

// Weighted composite
VRI_raw = compA * 0.40 + compB * 0.35 + compC * 0.25
VRI     = softClamp(VRI_raw * 1.2)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 7 - COMPOSITE ORDER FLOW PROXY (COFP)
//
//  Concept: True order flow requires tick data. This proxy estimates flow
//  direction from three OHLCV-derived inputs. The result is an approximation
//  and is disclosed as such. It is directionally informative but not precise.
//
//  Component 1 (50%): Bar-level buy/sell volume split based on close position
//  Component 2 (35%): Volume-weighted price velocity over 3 bars
//  Component 3 (15%): Absorption detection - high volume with small body
//
//  Output range: approximately -1.0 to +1.0 after EMA smoothing
// ════════════════════════════════════════════════════════════════════════════

// COFP component 1: Bar delta from close position within range
// Close at high implies buying pressure. Close at low implies selling pressure.
closePos        = safeDiv(close - low, math.max(high - low, 0.0001))
buyVol          = volume * closePos
sellVol         = volume * (1.0 - closePos)
barDelta        = safeDiv(buyVol - sellVol, math.max(volume, 1.0))
cofpDelta       = ta.ema(barDelta, cofpDeltaLen)
cofpComponent1  = softClamp(cofpDelta * 2.0)

// COFP component 2: Price velocity weighted by relative volume
// Fast moves on elevated relative volume register as stronger directional flow.
priceVel        = (close - close[3]) / math.max(close[3], 0.0001)
volMA_cofp      = ta.sma(volume, 20)
vwpv            = priceVel * safeDiv(volume, math.max(volMA_cofp, 1.0))
cofpComponent2  = softClamp(vwpv * 200.0)

// COFP component 3: Absorption detection
// High relative volume combined with a small body relative to range indicates
// that aggressive participation was absorbed rather than extended directionally.
// When absorption is present the signal flips as a mild contra-signal.
bodySize         = safeDiv(math.abs(close - open), math.max(high - low, 0.0001))
volSpike         = safeDiv(volume, math.max(ta.sma(volume, 14), 1.0))
isAbsorption     = volSpike > 1.5 and bodySize < 0.35
cofpComponent3   = isAbsorption ? (close > open ? -0.3 : 0.3) : 0.0

// Composite COFP weighted sum with final smoothing
COFP_raw = cofpComponent1 * 0.50 + cofpComponent2 * 0.35 + cofpComponent3 * 0.15
COFP     = ta.ema(COFP_raw, 2)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 8 - REGIME DETECTION ENGINE
//
//  Four states are detected from the four engine outputs:
//
//  TREND UP:   DER strongly positive, AMVS positive, VRI not compressing
//  TREND DOWN: DER strongly negative, AMVS negative, VRI not compressing
//  COIL:       DER near zero (low efficiency), VRI hard compression, COFP building
//  RANGE:      None of the above - default state
//
//  The regime is used by the adaptive weighting engine and for visual display.
//  It is not a trade signal. It describes market structure.
// ════════════════════════════════════════════════════════════════════════════

// State thresholds - tuned for the normalized output ranges of each engine
derCoiling   = math.abs(DER) < 0.20   // DER near zero = low directional efficiency
vriExpanding = VRI > 0.0              // Any positive VRI = volatility expanding
vriHardCoil  = VRI < -0.20            // Hard compression = strong coil
cofpBuilding = math.abs(COFP) > 0.20  // Flow building in either direction

// Priority order: COIL checked first because it overrides trend during compression
isBreakoutPending = derCoiling and vriHardCoil and cofpBuilding
isTrendingBull    = not isBreakoutPending and DER > 0.30 and AMVS > 0.0 and (vriExpanding or VRI > -0.1)
isTrendingBear    = not isBreakoutPending and DER < -0.30 and AMVS < 0.0 and (vriExpanding or VRI > -0.1)
isRangeBound      = not isBreakoutPending and not isTrendingBull and not isTrendingBear

// Visual regime properties
regimeBGColor = isTrendingBull    ? color.new(CLR_BULL_DIM,  85) : isTrendingBear    ? color.new(CLR_BEAR_DIM,  85) :isBreakoutPending ? color.new(CLR_COIL_BG,   85) :color.new(CLR_RANGE_BG, 87)

regimeText = isTrendingBull    ? 'TREND UP'   :
             isTrendingBear    ? 'TREND DOWN' :
             isBreakoutPending ? 'COIL'       :
             'RANGE'

regimeTextColor = isTrendingBull    ? CLR_BULL_STRONG :
                  isTrendingBear    ? CLR_BEAR_STRONG :
                  isBreakoutPending ? #dddd00         :
                  CLR_DIM

bgcolor(enableRegimeBG ? regimeBGColor : na, title = 'Regime Background')

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 9 - ADAPTIVE WEIGHTING ENGINE
//
//  When adaptive mode is on, the four component weights shift based on which
//  regime best explains the current market structure. The logic is:
//
//  COIL:    Flow and volatility lead - COFP 35%, VRI 30%, AMVS 20%, DER 15%
//  TREND:   Efficiency and momentum lead - DER 40%, AMVS 30%, VRI 20%, COFP 10%
//  RANGE:   Momentum and flow lead - AMVS 35%, COFP 35%, DER 15%, VRI 15%
//
//  All weights are normalized after assignment so any combination is valid.
//  When adaptive is off, the four manual inputs are used directly.
// ════════════════════════════════════════════════════════════════════════════

var float wDER  = wDER_input
var float wAMVS = wAMVS_input
var float wVRI  = wVRI_input
var float wCOFP = wCOFP_input

if enableAdaptive
    if isBreakoutPending
        wDER  := 0.15
        wAMVS := 0.20
        wVRI  := 0.30
        wCOFP := 0.35
    else if isTrendingBull or isTrendingBear
        wDER  := 0.40
        wAMVS := 0.30
        wVRI  := 0.20
        wCOFP := 0.10
    else
        wDER  := 0.15
        wAMVS := 0.35
        wVRI  := 0.15
        wCOFP := 0.35
else
    wDER  := wDER_input
    wAMVS := wAMVS_input
    wVRI  := wVRI_input
    wCOFP := wCOFP_input

// Normalize so weights always sum to 1.0 regardless of user input
// Guard against all-zero inputs which would cause division by zero
wTotal = wDER + wAMVS + wVRI + wCOFP
wTotal := wTotal < 0.0001 ? 1.0 : wTotal
wDER  := wDER  / wTotal
wAMVS := wAMVS / wTotal
wVRI  := wVRI  / wTotal
wCOFP := wCOFP / wTotal

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 10 - FLUX OSCILLATOR (CORE OUTPUT)
//
//  The four normalized engine outputs are combined using the adaptive weights.
//  The result is scaled by 100 to produce a readable oscillator range.
//  Output is approximately -100 to +100 in practice.
// ════════════════════════════════════════════════════════════════════════════

// Current timeframe oscillator
oscillator_current = (wDER * normDER + wAMVS * AMVS + wVRI * VRI + wCOFP * COFP) * 100.0

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 11 - HTF OSCILLATOR
//
//  The same four-engine calculation is performed on the higher timeframe
//  using request.security(). lookahead is not used (default gaps_off).
//  The HTF function uses a fixed period of 14 for RSI and the same
//  cofpDeltaLen for consistency.
//
//  When htfAdaptive is true, the current adaptive weights are applied.
//  When false, equal 0.25 weights are used - safer for cross-timeframe math.
// ════════════════════════════════════════════════════════════════════════════

calcHTFOscillator() =>
    // DER component
    htf_net  = close - close[derLen]
    htf_path = 0.0
    for i = 0 to derLen - 1 by 1
        htf_path := htf_path + math.abs(close[i] - close[i + 1])
    htf_der   = safeDiv(math.abs(htf_net), math.max(htf_path, 0.0001)) * (htf_net >= 0 ? 1.0 : -1.0)
    htf_der_s = ta.ema(htf_der, 3)

    // AMVS component - fixed period 14 on HTF for stability
    htf_rsi  = ta.rsi(close, 14)
    htf_amvs = softClamp((htf_rsi - 50.0) / 50.0 * 1.5)

    // VRI simplified - volatility momentum component only
    htf_atr5  = ta.atr(5)
    htf_atr20 = ta.atr(20)
    htf_volm  = safeDiv(htf_atr5 - htf_atr20, math.max(htf_atr20, 0.0001))
    htf_vri   = softClamp(htf_volm * 3.0)

    // COFP simplified - bar delta only
    htf_cp   = safeDiv(close - low, math.max(high - low, 0.0001))
    htf_cofp = softClamp(ta.ema(htf_cp * 2.0 - 1.0, cofpDeltaLen) * 2.0)

    // Return adaptive or fixed-weight result based on user setting
    htfAdaptive ?
         (wDER * htf_der_s + wAMVS * htf_amvs + wVRI * htf_vri + wCOFP * htf_cofp) * 100.0 :
         (0.25  * htf_der_s + 0.25  * htf_amvs + 0.25  * htf_vri + 0.25  * htf_cofp) * 100.0

// No lookahead - gaps_off ensures HTF values do not pull from future bars
htfOscRaw = request.security(syminfo.tickerid, htfTF, calcHTFOscillator(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Blend current and HTF oscillators
oscillator = enableHTFBlend ?
     oscillator_current * htfBlendRatio + htfOscRaw * (1.0 - htfBlendRatio) :
     oscillator_current

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 12 - MOMENTUM ACCELERATION
//
//  Velocity: 3-bar rate of change of the oscillator
//  Acceleration: 2-bar rate of change of velocity
//  Combined they classify momentum into four states
// ════════════════════════════════════════════════════════════════════════════

oscVelocity     = ta.change(oscillator, 3)
oscAcceleration = ta.change(oscVelocity, 2)

// Momentum state from velocity and acceleration sign combination
momentumState = oscAcceleration > 0 and oscVelocity > 0 ? 'Building'  : oscAcceleration < 0 and oscVelocity > 0 ? 'Fading'    : oscAcceleration > 0 and oscVelocity < 0 ? 'Reversing' :'Stable'

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 13 - CONFLUENCE SCORE ENGINE
//
//  Six independent components each scored 0-20 or 0-10.
//  Total maximum: 100. This measures environmental quality, not direction.
//
//  Component 1 (0-20): Regime and oscillator direction alignment
//  Component 2 (0-20): Oscillator magnitude conviction
//  Component 3 (0-20): All four engine components agree on direction
//  Component 4 (0-20): HTF alignment with current timeframe
//  Component 5 (0-10): Order flow quality and absorption state
//  Component 6 (0-10): Volatility context
// ════════════════════════════════════════════════════════════════════════════

oscBull = oscillator > 0.0
oscBear = oscillator < 0.0

// Component 1: Regime matches oscillator direction
comp1 = isTrendingBull and oscBull       ? 20 : isTrendingBear and oscBear       ? 20 : isBreakoutPending and cofpBuilding ? 15 : isRangeBound                     ? 5  : 0

// Component 2: How far is the oscillator from zero
absOsc = math.abs(oscillator)
comp2  = absOsc > 50 ? 20 : absOsc > 35 ? 15 : absOsc > 20 ? 10 : absOsc > 10 ? 5 : 0

// Component 3: Count how many engines agree on direction
agreeDir   = oscBull ? 1 : -1
agreeCount = 0
agreeCount := agreeCount + (normDER > 0 and agreeDir > 0 ? 1 : normDER < 0 and agreeDir < 0 ? 1 : 0)
agreeCount := agreeCount + (AMVS   > 0 and agreeDir > 0 ? 1 : AMVS   < 0 and agreeDir < 0 ? 1 : 0)
agreeCount := agreeCount + (VRI    > 0 and agreeDir > 0 ? 1 : VRI    < 0 and agreeDir < 0 ? 1 : 0)
agreeCount := agreeCount + (COFP   > 0 and agreeDir > 0 ? 1 : COFP   < 0 and agreeDir < 0 ? 1 : 0)
comp3 = agreeCount == 4 ? 20 : agreeCount == 3 ? 13 : agreeCount == 2 ? 6 : 0

// Component 4: HTF alignment
htfBull = htfOscRaw > 0.0
htfBear  = htfOscRaw < 0.0
comp4 = oscBull and htfBull and isTrendingBull ? 20 : oscBear and htfBear  and isTrendingBear ? 20 : oscBull and htfBull                     ? 12 : oscBear and htfBear                     ? 12 : 0

// Component 5: Flow quality - absorption reduces score
comp5 = not isAbsorption and math.abs(COFP) > 0.4 ? 10 : not isAbsorption and math.abs(COFP) > 0.2 ? 6  :isAbsorption                               ? 2  : 0

// Component 6: Volatility context - expanding vol in trend is constructive
comp6 = isBreakoutPending ? 8 : VRI > 0.3 ? 10 : VRI > 0.0 ? 6 : VRI > -0.2 ? 3 : 1

confluenceScore = comp1 + comp2 + comp3 + comp4 + comp5 + comp6

// Label and color mapped from score bands
confLabel = confluenceScore >= 91 ? 'ELITE'    : confluenceScore >= 76 ? 'HIGH'     : confluenceScore >= 56 ? 'GOOD'     : confluenceScore >= 31 ? 'MODERATE' : 'LOW'

confColor = confluenceScore >= 76 ? CLR_CONF_HIGH :confluenceScore >= 31 ? CLR_CONF_MED  :CLR_CONF_LOW

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 14 - FLUX STATE CANDLE (FSC)
//
//  The oscillator is displayed as a synthetic candle chart.
//  Open = previous bar flux value
//  High = max of current and previous
//  Low  = min of current and previous
//  Close = current flux value
//
//  Color logic:
//    Absorption state → violet (unique, unambiguous)
//    Flux above its EMA → green (bull)
//    Flux below its EMA → red (bear)
//
//  Border intensity tracks conviction: brighter border = flux further from MA
// ════════════════════════════════════════════════════════════════════════════

// Volume weight: amplifies flux when volume is above average
// Capped at 2.0x to prevent extreme spikes from dominating the display
volMA20_fsc = ta.sma(volume, 20)
volRatio    = safeDiv(volume, math.max(volMA20_fsc, 1.0))
volWeight   = enableVolWeight ? math.min(volRatio, 2.0) : 1.0

// Flux value and volume-adjusted version
FM_raw  = oscillator / fscScale
FM      = FM_raw * (1.0 + (volWeight - 1.0) * volAlpha)
FM_prev = FM[1]

// Flux moving average - candle color reference
fscMA = ta.ema(FM, fscMALen)

// Conviction: distance of flux from its MA
convDist     = math.abs(FM - fscMA)
fluxStrength = convDist > 0.15 ? 5 : convDist > 0.10 ? 4 : convDist > 0.06 ? 3 : convDist > 0.03 ? 2 : 1

// Direction
fscBull = FM > fscMA

// Candle colors - flat per state, no gradients
fscCandleColor = isAbsorption ? CLR_ABSORPTION : fscBull ? CLR_BULL_MED  : CLR_BEAR_MED

// Border color reflects conviction level using color intensity
// High conviction (4-5): strong primary color. Lower: medium color.
fscBorderColor = isAbsorption          ? CLR_ABSORPTION :
                 fscBull and fluxStrength >= 4 ? CLR_BULL_STRONG :
                 fscBull               ? CLR_BULL_MED  :
                 fluxStrength >= 4     ? CLR_BEAR_STRONG :
                 CLR_BEAR_MED

fscWickColor = isAbsorption ? color.new(CLR_ABSORPTION, 30) :
               fscBull      ? color.new(CLR_BULL_STRONG, 30) :
               color.new(CLR_BEAR_STRONG, 30)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 15 - MA CLOUD
//
//  Three EMAs applied to the normalized flux value FM.
//  Cloud fill between fast-mid and mid-slow pairs.
//  Color driven by alignment: bull when fast > mid > slow, bear when reversed.
// ════════════════════════════════════════════════════════════════════════════

ma1v = ta.ema(FM, ma1Len)
ma2v = ta.ema(FM, ma2Len)
ma3v = ta.ema(FM, ma3Len)

cloudBull  = ma1v > ma2v and ma2v > ma3v
cloudBear  = ma1v < ma2v and ma2v < ma3v
cloudColor = cloudBull ? color.new(CLR_BULL_SOFT, cloudOpacity) :
             cloudBear ? color.new(CLR_BEAR_SOFT, cloudOpacity) :
             color.new(CLR_GHOST, cloudOpacity)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 16 - SUPPORT AND RESISTANCE ZONES
//
//  Zones are detected from oscillator pivot highs and lows.
//  IMPORTANT: These are oscillator-native zones, not price levels.
//  They represent repeated turning points in the composite flux reading.
//
//  Zone lifecycle:
//  1. Pivot detected after srPivotRight bars confirmation
//  2. New zone created or existing zone updated if within tolerance
//  3. Zones older than 400 bars are removed automatically
//  4. When over maxSRZones the weakest zone is removed
//  5. Zones with fewer than minSRTouches are not drawn
//
// Historical safety: left coordinates are clamped to a recent bar range.
//
// ════════════════════════════════════════════════════════════════════════════

// Adaptive tolerance based on oscillator standard deviation
oscStdDev   = ta.stdev(oscillator, 100)
srTolerance = oscStdDev * 0.15
srTolerance := math.max(3.0, math.min(10.0, srTolerance))

// Zone data structure
type SRZone
    float      level        // Current weighted average level
    int        touches      // Number of confirmed pivot touches
    int        firstBar     // Bar index when zone was first created
    int        lastBar      // Bar index of most recent touch
    bool       isResistance // True for resistance, false for support
    array<int> touchBars    // Bar indices of each touch for dot rendering

var array<SRZone> srZones = array.new<SRZone>()

// Drawing object pools - cleared and rebuilt each render pass on last bar
var array<box>   srGlowBoxes   = array.new<box>()
var array<line>  srCenterLines = array.new<line>()
var array<label> srBadges      = array.new<label>()
var array<label> srTouchDots   = array.new<label>()

// Pivot detection - confirmed pivot required, so labels appear srPivotRight bars later
srPivHigh = ta.pivothigh(oscillator, srPivotLeft, srPivotRight)
srPivLow  = ta.pivotlow(oscillator,  srPivotLeft, srPivotRight)

// Update existing zone or create new one for each detected pivot
processPivot(detectedLevel, detectedBar, isRes) =>
    foundMatch = false
    if array.size(srZones) > 0
        for i = 0 to array.size(srZones) - 1 by 1
            z = array.get(srZones, i)
            if z.isResistance == isRes and math.abs(z.level - detectedLevel) <= srTolerance
                // Update zone: increment touches, update level with weighted average
                z.touches := z.touches + 1
                z.lastBar  := detectedBar
                z.level    := (z.level * 2.0 + detectedLevel) / 3.0
                array.push(z.touchBars, detectedBar)
                array.set(srZones, i, z)
                foundMatch := true
                break
    if not foundMatch
        // Create new zone
        newBars = array.new<int>()
        array.push(newBars, detectedBar)
        array.push(srZones, SRZone.new(detectedLevel, 1, detectedBar, detectedBar, isRes, newBars))

if not na(srPivHigh) and enableSR
    processPivot(srPivHigh, bar_index - srPivotRight, true)

if not na(srPivLow) and enableSR
    processPivot(srPivLow, bar_index - srPivotRight, false)

// Expire zones older than 400 bars - keeps memory and display clean
if enableSR and array.size(srZones) > 0
    for i = array.size(srZones) - 1 to 0 by 1
        z = array.get(srZones, i)
        if bar_index - z.lastBar > 400
            array.remove(srZones, i)

// Capacity management: remove weakest zone when over limit
if array.size(srZones) > maxSRZones and enableSR
    minT = 9999
    minI = 0
    for i = 0 to array.size(srZones) - 1 by 1
        z = array.get(srZones, i)
        if z.touches < minT
            minT := z.touches
            minI := i
    array.remove(srZones, minI)

// Render all qualifying zones on the last bar only
if enableSR and barstate.islast

    // Clear all previous drawing objects before rebuilding
    for bx in srGlowBoxes
        box.delete(bx)
    array.clear(srGlowBoxes)
    for ln in srCenterLines
        line.delete(ln)
    array.clear(srCenterLines)
    for lb in srBadges
        label.delete(lb)
    array.clear(srBadges)
    for lb in srTouchDots
        label.delete(lb)
    array.clear(srTouchDots)

    zoneCount = array.size(srZones)
    if zoneCount > 0
        // Maximum safe history offset to avoid buffer limit errors
        // Clamp drawing coordinates to avoid historical offset issues.
        safeHistoryLimit = 500

        for i = 0 to zoneCount - 1 by 1
            z = array.get(srZones, i)

            // Skip zones below minimum touch threshold
            if z.touches < minSRTouches
                continue

            // Safety clamp for left coordinate - prevents buffer limit runtime error
            safeLeft = math.max(z.firstBar, bar_index - safeHistoryLimit)

            // Validate zone is still within a usable range
            if safeLeft < 0
                continue

            rightBar   = bar_index + srExtension
            zoneColor  = z.isResistance ? CLR_SR_RES : CLR_SR_SUP

            // Outer glow - wide, very transparent
            if showSRGlow
                glowBox = box.new(
                     left         = safeLeft,
                     top          = z.level + srTolerance * 1.2,
                     right        = rightBar,
                     bottom       = z.level - srTolerance * 1.2,
                     border_color = color.new(zoneColor, 100),
                     border_width = 0,
                     bgcolor      = color.new(zoneColor, 95))
                array.push(srGlowBoxes, glowBox)

            // Center line - single pixel, full opacity
            // No zone body box is drawn - lines and labels only
            cLine = line.new(
                 x1     = safeLeft,
                 y1     = z.level,
                 x2     = rightBar + 5,
                 y2     = z.level,
                 color  = color.new(zoneColor, 0),
                 width  = 1,
                 style  = line.style_solid,
                 extend = extend.none)
            array.push(srCenterLines, cLine)

            // Strength badge label at right edge
            // Positioned 4 units above resistance lines and 4 units below support lines
            // to prevent overlap with trendline strength labels that sit at the line end Y
            strengthTxt = z.touches >= 5 ? 'MAJOR '  + str.tostring(z.touches) + 'T' :
                          z.touches >= 4 ? 'STRONG ' + str.tostring(z.touches) + 'T' :
                          'ZONE ' + str.tostring(z.touches) + 'T'
            typeTxt = z.isResistance ? 'R' : 'S'
            badgeY  = z.isResistance ? z.level + 4.0 : z.level - 4.0
            badge = label.new(
                 x         = rightBar + 2,
                 y         = badgeY,
                 text      = typeTxt + ' ' + strengthTxt,
                 style     = label.style_label_left,
                 color     = color.new(color.black, 100),
                 textcolor = zoneColor,
                 size      = size.tiny)
            array.push(srBadges, badge)

            // Touch history markers - up to 5 per zone
            if showSRTouchDots
                dotCount = math.min(array.size(z.touchBars), 5)
                if dotCount > 0
                    for d = 0 to dotCount - 1 by 1
                        tBar = array.get(z.touchBars, d)
                        // Only draw if within safe historical range
                        if tBar >= 0 and bar_index - tBar <= safeHistoryLimit
                            dot = label.new(
                                 x         = tBar,
                                 y         = z.level,
                                 text      = '*',
                                 style     = label.style_none,
                                 textcolor = color.new(zoneColor, 20),
                                 size      = size.tiny)
                            array.push(srTouchDots, dot)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 17 - TRENDLINE DETECTION
//
//  Swing lows from the oscillator form ascending trendlines (bull, cyan).
//  Swing highs form descending trendlines (bear, orange).
//
//  The algorithm:
//  1. Pivot history stores the last 50 confirmed pivot points
//  2. For each candidate anchor pair (p1, p2) with valid slope:
//     Count how many other pivots of the same type touch the line
//  3. If touch count >= minTLTouches, draw the line
//  4. Maximum 2 lines per direction to keep chart readable
//
//  All drawing is done on barstate.islast only - objects are rebuilt each bar.
// Trendlines and S/R zones are drawn separately to keep structure readable.
//
//  Label collision prevention:
//  Bull trendline strength labels are placed 8 units ABOVE the line end Y.
//  Bear trendline strength labels are placed 8 units BELOW the line end Y.
//  S/R badge labels are offset from the zone level by 4 units (above for
//  resistance, below for support) so the two label sets do not share the
//  same Y coordinate at the right edge of the chart.
// ════════════════════════════════════════════════════════════════════════════

type FluxPivot
    int   x      // Bar index of pivot
    float y      // Oscillator value at pivot
    bool  isHigh // True for swing high, false for swing low

var array<FluxPivot> pivotHistory = array.new<FluxPivot>()

tlPivHigh = ta.pivothigh(oscillator, tlPivotLeft, tlPivotRight)
tlPivLow  = ta.pivotlow(oscillator,  tlPivotLeft, tlPivotRight)

// Accumulate pivot history - cap at 50 to control memory
if not na(tlPivHigh) and enableTL
    array.push(pivotHistory, FluxPivot.new(bar_index - tlPivotRight, tlPivHigh, true))
    if array.size(pivotHistory) > 50
        array.shift(pivotHistory)

if not na(tlPivLow) and enableTL
    array.push(pivotHistory, FluxPivot.new(bar_index - tlPivotRight, tlPivLow, false))
    if array.size(pivotHistory) > 50
        array.shift(pivotHistory)

// Strength score: normalized combination of touch count, recency and slope angle
calcTLStrength(touches, age, slope) =>
    math.min(touches / 5.0, 1.0) * 0.5 +
     math.max(1.0 - age / 200.0, 0.2) * 0.3 +
     math.min(math.abs(slope) / 0.5, 1.0) * 0.2

// Drawing object pools for trendlines
var array<line>  bullMainLines = array.new<line>()
var array<line>  bullChanLines = array.new<line>()
var array<label> bullStrLabels = array.new<label>()
var array<line>  bearMainLines = array.new<line>()
var array<line>  bearChanLines = array.new<line>()
var array<label> bearStrLabels = array.new<label>()

if barstate.islast and enableTL

    // Clear all previous trendline objects
    if array.size(bullMainLines) > 0
        for i = 0 to array.size(bullMainLines) - 1 by 1
            line.delete(array.get(bullMainLines, i))
    array.clear(bullMainLines)
    if array.size(bullChanLines) > 0
        for i = 0 to array.size(bullChanLines) - 1 by 1
            line.delete(array.get(bullChanLines, i))
    array.clear(bullChanLines)
    if array.size(bullStrLabels) > 0
        for i = 0 to array.size(bullStrLabels) - 1 by 1
            label.delete(array.get(bullStrLabels, i))
    array.clear(bullStrLabels)
    if array.size(bearMainLines) > 0
        for i = 0 to array.size(bearMainLines) - 1 by 1
            line.delete(array.get(bearMainLines, i))
    array.clear(bearMainLines)
    if array.size(bearChanLines) > 0
        for i = 0 to array.size(bearChanLines) - 1 by 1
            line.delete(array.get(bearChanLines, i))
    array.clear(bearChanLines)
    if array.size(bearStrLabels) > 0
        for i = 0 to array.size(bearStrLabels) - 1 by 1
            label.delete(array.get(bearStrLabels, i))
    array.clear(bearStrLabels)

    pc = array.size(pivotHistory)

    if pc >= 2
        // ── Bull trendlines from swing lows ─────────────────────────────
        for i = pc - 1 to math.max(pc - 15, 1)
            if array.size(bullMainLines) >= 2
                break
            p1 = array.get(pivotHistory, i)
            if p1.isHigh
                continue
            for j = i - 1 to math.max(i - 15, 0)
                p2 = array.get(pivotHistory, j)
                if p2.isHigh
                    continue
                dx    = float(p1.x - p2.x)
                dy    = p1.y - p2.y
                slope = dx != 0 ? dy / dx : 0.0
                // Reject negative slopes - bull trendlines must ascend or be flat
                if slope < -0.05
                    continue
                touches = 0
                for k = 0 to pc - 1 by 1
                    p = array.get(pivotHistory, k)
                    if not p.isHigh
                        expectedY = p2.y + slope * float(p.x - p2.x)
                        if math.abs(p.y - expectedY) < 5.0
                            touches := touches + 1
                if touches >= minTLTouches
                    age     = bar_index - p1.x
                    str_val = calcTLStrength(touches, age, slope)
                    x2      = p1.x + tlExtension
                    y2      = p1.y + slope * float(tlExtension)
                    mLine   = line.new(p2.x, p2.y, x2, y2,
                         color = color.new(CLR_TL_BULL, 10), width = 2, style = line.style_solid)
                    array.push(bullMainLines, mLine)
                    if showTLChannel
                        cLine = line.new(p2.x, p2.y + 8.0, x2, y2 + 8.0,
                             color = color.new(CLR_TL_BULL, 65), width = 1, style = line.style_dashed)
                        array.push(bullChanLines, cLine)
                    if showTLStrength
                        sPct = str.tostring(math.round(str_val * 100)) + '%'
                        // Bull label placed 8 units ABOVE line end to avoid S/R badge overlap
                        sLbl = label.new(x2 + 2, y2 + 8.0, text = 'TL ' + sPct,
                             style     = label.style_label_left,
                             color     = color.new(color.black, 100),
                             textcolor = CLR_TL_BULL,
                             size      = size.tiny)
                        array.push(bullStrLabels, sLbl)
                    break
                if array.size(bullMainLines) >= 2
                    break

        // ── Bear trendlines from swing highs ─────────────────────────────
        for i = pc - 1 to math.max(pc - 15, 1)
            if array.size(bearMainLines) >= 2
                break
            p1 = array.get(pivotHistory, i)
            if not p1.isHigh
                continue
            for j = i - 1 to math.max(i - 15, 0)
                p2 = array.get(pivotHistory, j)
                if not p2.isHigh
                    continue
                dx    = float(p1.x - p2.x)
                dy    = p1.y - p2.y
                slope = dx != 0 ? dy / dx : 0.0
                // Reject positive slopes - bear trendlines must descend or be flat
                if slope > 0.05
                    continue
                touches = 0
                for k = 0 to pc - 1 by 1
                    p = array.get(pivotHistory, k)
                    if p.isHigh
                        expectedY = p2.y + slope * float(p.x - p2.x)
                        if math.abs(p.y - expectedY) < 5.0
                            touches := touches + 1
                if touches >= minTLTouches
                    age     = bar_index - p1.x
                    str_val = calcTLStrength(touches, age, slope)
                    x2      = p1.x + tlExtension
                    y2      = p1.y + slope * float(tlExtension)
                    mLine   = line.new(p2.x, p2.y, x2, y2,
                         color = color.new(CLR_TL_BEAR, 10), width = 2, style = line.style_solid)
                    array.push(bearMainLines, mLine)
                    if showTLChannel
                        cLine = line.new(p2.x, p2.y - 8.0, x2, y2 - 8.0,
                             color = color.new(CLR_TL_BEAR, 65), width = 1, style = line.style_dashed)
                        array.push(bearChanLines, cLine)
                    if showTLStrength
                        sPct = str.tostring(math.round(str_val * 100)) + '%'
                        // Bear label placed 8 units BELOW line end to avoid S/R badge overlap
                        sLbl = label.new(x2 + 2, y2 - 8.0, text = 'TL ' + sPct,
                             style     = label.style_label_left,
                             color     = color.new(color.black, 100),
                             textcolor = CLR_TL_BEAR,
                             size      = size.tiny)
                        array.push(bearStrLabels, sLbl)
                    break
                if array.size(bearMainLines) >= 2
                    break

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 18 - DIVERGENCE DETECTION
//
//  Divergences are detected by comparing oscillator pivot values to price
//  pivot values. All labels are plotted at the confirmed pivot bar, which
//  is divRight bars in the past. This is standard confirmed pivot behavior
//  and is not repainting.
//
//  Regular Bull:  Price lower low + oscillator higher low = potential reversal up
//  Regular Bear:  Price higher high + oscillator lower high = potential reversal down
//  Hidden Bull:   Price higher low + oscillator lower low = trend continuation up
//  Hidden Bear:   Price lower high + oscillator higher high = trend continuation down
// ════════════════════════════════════════════════════════════════════════════

// Returns true if the previous occurrence of the condition is within the bar range
inDivRange(cond) =>
    bars = ta.barssince(cond)
    divMin <= bars and bars <= divMax

// Values at the pivot bar
lbrFlux = oscillator[divRight]
lbrLow  = low[divRight]
lbrHigh = high[divRight]

// Pivot confirmation booleans
plFlux = not na(ta.pivotlow( oscillator, divLeft, divRight))
phFlux = not na(ta.pivothigh(oscillator, divLeft, divRight))

// Regular divergences
fluxHL     = lbrFlux > ta.valuewhen(plFlux, lbrFlux, 1) and inDivRange(plFlux[1])
priceLL    = lbrLow  < ta.valuewhen(plFlux, lbrLow,  1)
bullRegDiv = showRegDiv and enableDiv and priceLL and fluxHL and plFlux

fluxLH     = lbrFlux < ta.valuewhen(phFlux, lbrFlux, 1) and inDivRange(phFlux[1])
priceHH    = lbrHigh > ta.valuewhen(phFlux, lbrHigh, 1)
bearRegDiv = showRegDiv and enableDiv and priceHH and fluxLH and phFlux

// Hidden divergences
fluxLL     = lbrFlux < ta.valuewhen(plFlux, lbrFlux, 1) and inDivRange(plFlux[1])
priceHL    = lbrLow  > ta.valuewhen(plFlux, lbrLow,  1)
bullHidDiv = showHidDiv and enableDiv and priceHL and fluxLL and plFlux

fluxHH     = lbrFlux > ta.valuewhen(phFlux, lbrFlux, 1) and inDivRange(phFlux[1])
priceLH    = lbrHigh < ta.valuewhen(phFlux, lbrHigh, 1)
bearHidDiv = showHidDiv and enableDiv and priceLH and fluxHH and phFlux

// Divergence tracking state
var array<label> divLabels   = array.new<label>()
var int lastBullDivBar       = 0
var int lastBearDivBar       = 0
var int lastHidBullBar       = 0
var int lastHidBearBar       = 0
var int totalBullDiv         = 0
var int totalBearDiv         = 0
var int totalHiddenDiv       = 0

// Minimum gap reduces repeated labels on nearby pivots.
canBull  = bar_index - lastBullDivBar >= minDivGap
canBear  = bar_index - lastBearDivBar >= minDivGap
canHBull = bar_index - lastHidBullBar >= minDivGap
canHBear = bar_index - lastHidBearBar >= minDivGap

showBullReg = bullRegDiv and canBull
showBearReg = bearRegDiv and canBear
showBullHid = bullHidDiv and canHBull
showBearHid = bearHidDiv and canHBear

// Label creation with rolling pool management
addDivLabel(yPos, txt, stl, col, tcol, sz) =>
    lb = label.new(bar_index - divRight, yPos, text = txt,
         style = stl, color = col, textcolor = tcol, size = sz)
    array.push(divLabels, lb)
    if array.size(divLabels) > maxDivLabels
        label.delete(array.shift(divLabels))

if showBullReg
    lastBullDivBar := bar_index
    totalBullDiv   := totalBullDiv + 1
    addDivLabel(oscillator[divRight], 'DIV+',
         label.style_label_up, color.new(CLR_DIV_REG, 25), CLR_WHITE, size.small)

if showBearReg
    lastBearDivBar := bar_index
    totalBearDiv   := totalBearDiv + 1
    addDivLabel(oscillator[divRight], 'DIV-',
         label.style_label_down, color.new(CLR_DIV_REG, 25), CLR_WHITE, size.small)

if showBullHid
    lastHidBullBar := bar_index
    totalHiddenDiv := totalHiddenDiv + 1
    addDivLabel(oscillator[divRight], 'H+',
         label.style_circle, color.new(CLR_DIV_HID, 50), CLR_WHITE, size.tiny)

if showBearHid
    lastHidBearBar := bar_index
    totalHiddenDiv := totalHiddenDiv + 1
    addDivLabel(oscillator[divRight], 'H-',
         label.style_circle, color.new(CLR_DIV_HID, 50), CLR_WHITE, size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 19 - MULTI-TIMEFRAME OSCILLATOR
//
//  The same four-engine calculation is run on three user-defined timeframes.
//  Equal weights (0.25 each) are used for consistency across all timeframes.
//  States: BULL above +25, BEAR below -25, NEUT between.
// ════════════════════════════════════════════════════════════════════════════

calcMTFOsc() =>
    n   = close - close[derLen]
    pth = 0.0
    for i = 0 to derLen - 1 by 1
        pth := pth + math.abs(close[i] - close[i + 1])
    d   = safeDiv(math.abs(n), math.max(pth, 0.0001)) * (n >= 0 ? 1.0 : -1.0)
    r   = ta.rsi(close, 14)
    m   = softClamp((r - 50.0) / 50.0 * 1.5)
    a5  = ta.atr(5)
    a20 = ta.atr(20)
    v   = softClamp(safeDiv(a5 - a20, math.max(a20, 0.0001)) * 3.0)
    cp  = safeDiv(close - low, math.max(high - low, 0.0001))
    f   = softClamp(ta.ema(cp * 2.0 - 1.0, cofpDeltaLen) * 2.0)
    (0.25 * d + 0.25 * m + 0.25 * v + 0.25 * f) * 100.0

mtfFlux1 = request.security(syminfo.tickerid, mtf1, calcMTFOsc(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfFlux2 = request.security(syminfo.tickerid, mtf2, calcMTFOsc(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfFlux3 = request.security(syminfo.tickerid, mtf3, calcMTFOsc(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

fluxState(v) =>
    v > 25 ? 'BULL' : v < -25 ? 'BEAR' : 'NEUT'

fluxStateCol(v) =>
    v > 25 ? CLR_BULL_STRONG : v < -25 ? CLR_BEAR_STRONG : CLR_DIM

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 20 - VISUAL PLOTS
// ════════════════════════════════════════════════════════════════════════════

// ── Flux State Candle ────────────────────────────────────────────────────────
// Synthetic candle built from the oscillator value.
// Open  = previous bar flux value
// Close = current bar flux value
// High and low bracket both values to form body and wick.
fsc_o = fscShow ? FM_prev * fscScale : na
fsc_h = fscShow ? math.max(FM, FM_prev) * fscScale : na
fsc_l = fscShow ? math.min(FM, FM_prev) * fscScale : na
fsc_c = fscShow ? FM * fscScale : na

plotcandle(fsc_o, fsc_h, fsc_l, fsc_c,
     title       = 'Flux State Candle',
     color       = fscShow ? color.new(fscCandleColor, 20) : na,
     bordercolor = fscShow ? fscBorderColor : na,
     wickcolor   = fscShow ? fscWickColor   : na)

// ── MA Cloud ──────────────────────────────────────────────────────────────────
ma1Plot = plot(enableMACloud ? ma1v * fscScale : na,
     title = 'Fast EMA', color = color.new(CLR_MA_FAST, 30), linewidth = 1)
ma2Plot = plot(enableMACloud ? ma2v * fscScale : na,
     title = 'Medium EMA', color = CLR_MA_MED, linewidth = 2)
ma3Plot = plot(enableMACloud ? ma3v * fscScale : na,
     title = 'Slow EMA', color = color.new(CLR_MA_SLOW, 30), linewidth = 1)

fill(ma1Plot, ma2Plot, color = enableMACloud ? cloudColor : na, title = 'Upper Cloud Fill')
fill(ma2Plot, ma3Plot, color = enableMACloud ? cloudColor : na, title = 'Lower Cloud Fill')

// Flux MA reference line
plot(fscMA * fscScale,
     title     = 'Flux MA',
     style     = plot.style_line,
     linewidth = 2,
     color     = color.new(CLR_MA_FAST, 0))

// ── Confluence Histogram ──────────────────────────────────────────────────────
// The confluence score (0-100) is displayed as a filled histogram anchored at
// confFloor. A taller bar means a higher score. The histogram top label shows
// the exact score and quality band on the last bar.
// confFloor is the base. confFloor + confHeight is the maximum possible top.
confHistTop  = enableConfLine ? confFloor + (confluenceScore / 100.0) * confHeight : na
confHistBase = enableConfLine ? confFloor : na

confHistPlot = plot(confHistTop,
     title     = 'Confluence Histogram Top',
     style     = plot.style_line,
     linewidth = 1,
     color     = color.new(confColor, 100))

confBasePlot = plot(confHistBase,
     title     = 'Confluence Histogram Base',
     style     = plot.style_line,
     linewidth = 1,
     color     = color.new(CLR_GHOST, 100))

fill(confHistPlot, confBasePlot,
     color = enableConfLine ? color.new(confColor, 45) : na,
     title = 'Confluence Histogram Fill')

// Confluence score label and floor label rebuilt on last bar
var label confScoreLabel = na
var label confFloorLabel = na

if enableConfLine and barstate.islast
    if not na(confScoreLabel)
        label.delete(confScoreLabel)
    if not na(confFloorLabel)
        label.delete(confFloorLabel)

    confTopY = confFloor + (confluenceScore / 100.0) * confHeight

    confScoreLabel := label.new(
         x         = bar_index + 3,
         y         = confTopY,
         text      = 'CONF  ' + str.tostring(confluenceScore) + '  ' + confLabel,
         style     = label.style_label_left,
         color     = color.new(color.black, 100),
         textcolor = confColor,
         size      = size.small)

    confFloorLabel := label.new(
         x         = bar_index + 3,
         y         = confFloor,
         text      = '0',
         style     = label.style_label_left,
         color     = color.new(color.black, 100),
         textcolor = color.new(CLR_DIM, 40),
         size      = size.tiny)

// ── Reference Lines ───────────────────────────────────────────────────────────
// Three horizontal reference lines rebuilt on last bar.
// Upper and lower are dotted threshold markers. Zero is the neutral axis.
var line refUpper_ln = na
var line refZero_ln  = na
var line refLower_ln = na

if showRefLines and barstate.islast
    if not na(refUpper_ln)
        line.delete(refUpper_ln)
    if not na(refZero_ln)
        line.delete(refZero_ln)
    if not na(refLower_ln)
        line.delete(refLower_ln)
    refUpper_ln := line.new(bar_index - 500, refUpper, bar_index + 100, refUpper,
         color  = color.new(CLR_BULL_SOFT, 40),
         width  = 1,
         style  = line.style_dotted,
         extend = extend.right)
    refZero_ln := line.new(bar_index - 500, 0.0, bar_index + 100, 0.0,
         color  = color.new(CLR_DIM, 50),
         width  = 1,
         style  = line.style_solid,
         extend = extend.right)
    refLower_ln := line.new(bar_index - 500, refLower, bar_index + 100, refLower,
         color  = color.new(CLR_BEAR_SOFT, 40),
         width  = 1,
         style  = line.style_dotted,
         extend = extend.right)

// ── Regime Label ──────────────────────────────────────────────────────────────
// Rebuilt on last bar. Positioned at y = -30 to sit clearly above the
// confluence histogram and below the main oscillator body.
// Displays current regime state, symbol, and timeframe for chart context.
var label regimeLabel = na

if showRegimeLabel and barstate.islast
    if not na(regimeLabel)
        label.delete(regimeLabel)
    regimeLabel := label.new(
         x         = bar_index + 3,
         y         = -50.0,
         text      = regimeText + '  ' + syminfo.ticker + '  ' + timeframe.period,
         style     = label.style_label_left,
         color     = color.new(color.black, 100),
         textcolor = regimeTextColor,
         size      = size.small)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 21 - DASHBOARD
//
//  Three display modes:
//  Compact Bar  - single row, 8 columns, key values only
//  Corner HUD   - 2 columns, 7 rows, summary readout
//  Full Panel   - 6 columns, up to 14 rows, complete engine readout
//
//  The table is rebuilt only when the type, position or size setting changes.
//  On every last bar, all cell values are refreshed in place.
//
//  The header row shows symbol and timeframe so the chart context is always
//  visible when the dashboard is the primary reference.
// ════════════════════════════════════════════════════════════════════════════

var table  dash         = na
var string dashKeyPrev  = ''

if dashType != 'Off' and barstate.islast

    // Rebuild table only when layout settings change
    dashKeyNow = str.format('{0}|{1}|{2}', dashType, dashPos, dashSz)

    if dashKeyNow != dashKeyPrev or na(dash)
        if not na(dash)
            table.delete(dash)

        cols = dashType == 'Compact Bar' ? 8 : dashType == 'Corner HUD' ? 2 : 6

        rowCount = dashType == 'Compact Bar' ? 1 :
                   dashType == 'Corner HUD'  ? 7 :
                   showMTFPanel and showConfDash ? 14 :
                   showMTFPanel or  showConfDash ? 13 : 12

        dash := table.new(tablePos(dashPos), cols, rowCount,
             bgcolor      = color.new(CLR_BLACK, 10),
             border_width = 1,
             border_color = color.new(CLR_BULL_SOFT, 60),
             frame_width  = 2,
             frame_color  = color.new(CLR_BULL_STRONG, 40),
             force_overlay = true)

        dashKeyPrev := dashKeyNow

    // Shared derived values used across all display modes
    ts      = textSz(dashSz)
    fluxCol = oscillator > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
    maAbove = FM > fscMA
    maCol   = maAbove ? CLR_BULL_STRONG : CLR_BEAR_STRONG
    maStat  = maAbove ? 'ABOVE' : 'BELOW'

    // ── Compact Bar ────────────────────────────────────────────────────────
    if dashType == 'Compact Bar'
        table.cell(dash, 0, 0, 'FLUX ' + str.tostring(math.round(oscillator, 1)),
             text_color = fluxCol, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, 0, 'MA ' + maStat,
             text_color = maCol,   bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        strTxt = fluxStrength == 5 ? 'MAX' : fluxStrength == 4 ? 'HIGH' :
                 fluxStrength == 3 ? 'MED' : fluxStrength == 2 ? 'LOW'  : 'MIN'
        table.cell(dash, 2, 0, 'STR ' + strTxt,
             text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 3, 0, 'CONF ' + str.tostring(confluenceScore) + ' ' + confLabel,
             text_color = confColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 4, 0, regimeText,
             text_color = regimeTextColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 5, 0, 'DIV ' + str.tostring(totalBullDiv + totalBearDiv),
             text_color = CLR_DIV_REG, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        tlTxt = str.tostring(array.size(bullMainLines)) + 'B ' + str.tostring(array.size(bearMainLines)) + 'R'
        table.cell(dash, 6, 0, 'TL ' + tlTxt,
             text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 7, 0, 'SR ' + str.tostring(array.size(srZones)),
             text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)

    // ── Corner HUD ────────────────────────────────────────────────────────
    else if dashType == 'Corner HUD'
        row = 0
        table.cell(dash, 0, row, 'UST 2.0 ' + syminfo.ticker,
             text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_PANEL, 20),
             text_size = ts, text_halign = text.align_center)
        table.cell(dash, 1, row, timeframe.period,
             text_color = CLR_DIM, bgcolor = color.new(CLR_PANEL, 20),
             text_size = ts, text_halign = text.align_center)
        row := row + 1
        table.cell(dash, 0, row, 'FLUX',   text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, str.tostring(math.round(oscillator, 1)), text_color = fluxCol, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1
        table.cell(dash, 0, row, 'REGIME', text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, regimeText, text_color = regimeTextColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1
        table.cell(dash, 0, row, 'CONF',   text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, str.tostring(confluenceScore) + ' ' + confLabel, text_color = confColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1
        table.cell(dash, 0, row, 'ACCEL',  text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        accelCol = oscAcceleration > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        table.cell(dash, 1, row, momentumState, text_color = accelCol, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1
        table.cell(dash, 0, row, 'FLOW',   text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        cofpCol = COFP > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        table.cell(dash, 1, row, (isAbsorption ? 'ABS ' : '') + str.tostring(math.round(COFP, 2)),
             text_color = isAbsorption ? CLR_ABSORPTION : cofpCol, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1
        table.cell(dash, 0, row, 'DIV',    text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, str.tostring(totalBullDiv) + 'B ' + str.tostring(totalBearDiv) + 'R',
             text_color = CLR_DIV_REG, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)

    // ── Full Panel ────────────────────────────────────────────────────────
    else if dashType == 'Full Panel'
        row = 0

        // Header: symbol and timeframe always visible
        table.cell(dash, 0, row, 'UST 2.0   ' + syminfo.ticker + '   ' + timeframe.period,
             text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_PANEL, 10),
             text_size = ts, text_halign = text.align_center)
        table.merge_cells(dash, 0, row, 3, row)
        table.cell(dash, 4, row, 'BullByte',
             text_color = CLR_DIM, bgcolor = color.new(CLR_PANEL, 10),
             text_size = ts, text_halign = text.align_center)
        table.merge_cells(dash, 4, row, 5, row)
        row := row + 1

        // Flux, MA position, conviction strength
        cellH(dash, 0, row, 'FLUX', ts)
        cellV(dash, 1, row, str.tostring(math.round(oscillator, 1)), fluxCol, ts)
        cellH(dash, 2, row, 'MA', ts)
        cellV(dash, 3, row, maStat, maCol, ts)
        cellH(dash, 4, row, 'STRENGTH', ts)
        cellV(dash, 5, row, str.tostring(fluxStrength) + ' / 5', fluxCol, ts)
        row := row + 1

        // Regime, momentum acceleration, oscillator velocity
        cellH(dash, 0, row, 'REGIME', ts)
        cellV(dash, 1, row, regimeText, regimeTextColor, ts)
        cellH(dash, 2, row, 'ACCEL', ts)
        accelC = oscAcceleration > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 3, row, momentumState, accelC, ts)
        cellH(dash, 4, row, 'VELOCITY', ts)
        velC = oscVelocity > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 5, row, str.tostring(math.round(oscVelocity, 2)), velC, ts)
        row := row + 1

        // Individual engine readouts
        cellH(dash, 0, row, 'DER', ts)
        derC = normDER > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 1, row, str.tostring(math.round(normDER, 2)), derC, ts)
        cellH(dash, 2, row, 'AMVS', ts)
        amvsC = AMVS > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 3, row, str.tostring(math.round(AMVS, 2)), amvsC, ts)
        cellH(dash, 4, row, 'VRI', ts)
        vriC = VRI > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 5, row, str.tostring(math.round(VRI, 2)), vriC, ts)
        row := row + 1

        // COFP, absorption state, volatility regime ratio
        cellH(dash, 0, row, 'COFP', ts)
        cofpC = COFP > 0 ? CLR_BULL_STRONG : CLR_BEAR_STRONG
        cellV(dash, 1, row, str.tostring(math.round(COFP, 2)), isAbsorption ? CLR_ABSORPTION : cofpC, ts)
        cellH(dash, 2, row, 'ABSORB', ts)
        cellV(dash, 3, row, isAbsorption ? 'YES' : 'CLEAR', isAbsorption ? CLR_ABSORPTION : CLR_BULL_MED, ts)
        cellH(dash, 4, row, 'VOL REG', ts)
        volRegC = volRegime > 1.3 ? CLR_BEAR_STRONG : volRegime < 0.8 ? CLR_BULL_MED : CLR_DIM
        cellV(dash, 5, row, str.tostring(math.round(volRegime, 2)), volRegC, ts)
        row := row + 1

        // Confluence section
        if showConfDash
            table.cell(dash, 0, row, 'CONFLUENCE',
                 text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_PANEL, 20),
                 text_size = ts, text_halign = text.align_center)
            table.merge_cells(dash, 0, row, 5, row)
            row := row + 1
            table.cell(dash, 0, row, 'SCORE',   text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 1, row, str.tostring(confluenceScore), text_color = confColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 2, row, 'QUALITY',  text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 3, row, confLabel,  text_color = confColor, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 4, row, 'ALIGN',    text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 5, row, str.tostring(agreeCount) + '/4',
                 text_color = agreeCount == 4 ? CLR_BULL_STRONG : agreeCount >= 3 ? CLR_BULL_MED : CLR_DIM,
                 bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            row := row + 1

        // MTF section
        if showMTFPanel
            table.cell(dash, 0, row, 'MULTI-TIMEFRAME',
                 text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_PANEL, 20),
                 text_size = ts, text_halign = text.align_center)
            table.merge_cells(dash, 0, row, 5, row)
            row := row + 1
            s1 = fluxState(mtfFlux1)
            s2 = fluxState(mtfFlux2)
            s3 = fluxState(mtfFlux3)
            table.cell(dash, 0, row, mtf1 + ' TF', text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 1, row, s1, text_color = fluxStateCol(mtfFlux1), bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 2, row, mtf2 + ' TF', text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 3, row, s2, text_color = fluxStateCol(mtfFlux2), bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 4, row, mtf3 + ' TF', text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            table.cell(dash, 5, row, s3, text_color = fluxStateCol(mtfFlux3), bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
            row := row + 1

        // Signals and structure section
        table.cell(dash, 0, row, 'SIGNALS + STRUCTURE',
             text_color = CLR_BULL_STRONG, bgcolor = color.new(CLR_PANEL, 20),
             text_size = ts, text_halign = text.align_center)
        table.merge_cells(dash, 0, row, 5, row)
        row := row + 1

        table.cell(dash, 0, row, 'BULL DIV',  text_color = CLR_DIV_REG,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, str.tostring(totalBullDiv), text_color = CLR_DIV_REG,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 2, row, 'BEAR DIV',  text_color = CLR_DIV_HID,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 3, row, str.tostring(totalBearDiv), text_color = CLR_DIV_HID,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 4, row, 'HIDDEN',    text_color = CLR_DIM,       bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 5, row, str.tostring(totalHiddenDiv), text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        row := row + 1

        table.cell(dash, 0, row, 'BULL TL',   text_color = CLR_TL_BULL,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 1, row, str.tostring(array.size(bullMainLines)), text_color = CLR_TL_BULL, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 2, row, 'BEAR TL',   text_color = CLR_TL_BEAR,  bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 3, row, str.tostring(array.size(bearMainLines)), text_color = CLR_TL_BEAR, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 4, row, 'S/R ZONES', text_color = CLR_DIM,       bgcolor = color.new(CLR_BLACK, 30), text_size = ts)
        table.cell(dash, 5, row, str.tostring(array.size(srZones)),       text_color = CLR_DIM, bgcolor = color.new(CLR_BLACK, 30), text_size = ts)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 22 - ALERTS
//
//  All alerts are based on confirmed bar-close conditions.
//  No alert fires on intra-bar data. Use alert() in TradingView to set
//  frequency to "Once per bar close" for reliable non-repainting behavior.
// ════════════════════════════════════════════════════════════════════════════


alertcondition(showBullReg,
     title   = 'Regular Bull Divergence',
     message = 'UST 2.0: Regular bullish divergence detected.')

alertcondition(showBearReg,
     title   = 'Regular Bear Divergence',
     message = 'UST 2.0: Regular bearish divergence detected.')

alertcondition(showBullHid,
     title   = 'Hidden Bull Divergence',
     message = 'UST 2.0: Hidden bullish divergence detected.')

alertcondition(showBearHid,
     title   = 'Hidden Bear Divergence',
     message = 'UST 2.0: Hidden bearish divergence detected.')

alertcondition(ta.crossover(FM, fscMA),
     title   = 'Flux Crossed Above MA',
     message = 'UST 2.0: Flux crossed above its moving average.')

alertcondition(ta.crossunder(FM, fscMA),
     title   = 'Flux Crossed Below MA',
     message = 'UST 2.0: Flux crossed below its moving average.')

alertcondition(isBreakoutPending,
     title   = 'Coil State Detected',
     message = 'UST 2.0: Breakout coil forming - low efficiency, hard compression, flow building.')

alertcondition(isAbsorption,
     title   = 'Volume Absorption Bar',
     message = 'UST 2.0: Volume absorption detected - high volume, small body.')

alertcondition(confluenceScore >= 76,
     title   = 'High Confluence Environment',
     message = 'UST 2.0: Confluence score reached HIGH or above.')

alertcondition(isTrendingBull and not isTrendingBull[1],
     title   = 'Bull Trend Regime Started',
     message = 'UST 2.0: Market entered bullish trend regime.')

alertcondition(isTrendingBear and not isTrendingBear[1],
     title   = 'Bear Trend Regime Started',
     message = 'UST 2.0: Market entered bearish trend regime.')

// ════════════════════════════════════════════════════════════════════════════
//END of SCRIPT
// ════════════════════════════════════════════════════════════════════════════
````
