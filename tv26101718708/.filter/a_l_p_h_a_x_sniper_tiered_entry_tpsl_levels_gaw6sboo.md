# [ A L P H A X ] Sniper - Tiered Entry + TP/SL Levels

- url: https://www.tradingview.com/script/gAw6SBoo-A-L-P-H-A-X-Sniper-Tiered-Entry-TP-SL-Levels/
- type: indicator
- pine_id: PUB;0aceb1f217144f6f885c023a56ebf75a
- version: 3.0

## Description

[b]AlphaX Sniper — Multi-Layer Confluence Scoring, Tiered Entry Grading, ATR-Based TP/SL Levels, Trailing Stop & Sniper Kill Zones[/b]

[image]https://www.tradingview.com/x/jF4njIpG/[/image]
AlphaX Sniper is a precision entry system built around a multi-factor confluence scoring engine that evaluates trend strength, oscillator positioning, volume, session quality, and higher timeframe bias simultaneously — then grades every signal into one of three tiers: A, AA, or AAA. Designed for traders who want surgical, high-confidence entries rather than a constant stream of noise. Built for XAUUSD, forex majors, and indices across intraday timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]

[i]Full chart view showing trend ribbon, tiered signal labels, TP/SL levels, sniper kill zones, and trailing stop[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The Trend Engine — How It Works[/b]

At the foundation of AlphaX Sniper is a [b]four-EMA Trend Engine[/b] that scores the current market structure from -4 to +4 and classifies it into distinct trend states:

[list]
[*][b]Fast EMA (8)[/b] — immediate momentum reference, most sensitive to price changes
[*][b]Medium EMA (21)[/b] — intermediate trend confirmation layer
[*][b]Slow EMA (55)[/b] — the trend backbone, filters short-term noise
[*][b]Anchor EMA (200)[/b] — the macro structural divider; being above or below it determines the dominant bias
[/list]

The engine scores four independent conditions each bar:
[list]
[*]EMA ribbon alignment (Fast > Medium > Slow for bull, reverse for bear)
[*]Fast EMA slope direction (accelerating up or down)
[*]Medium EMA slope direction
[*]Price position relative to the Anchor EMA
[/list]

Each condition contributes ±1 to the [b]Trend Score[/b], producing a value from -4 to +4:
[list]
[*][b]+4 / +3[/b] — Strong Bull Trend
[*][b]+2[/b] — Moderate Bull Trend
[*][b]+1[/b] — Mild Bull
[*][b]0[/b] — Neutral / Ranging
[*][b]-1[/b] — Mild Bear
[*][b]-2[/b] — Moderate Bear Trend
[*][b]-4 / -3[/b] — Strong Bear Trend
[/list]

The space between the Fast EMA and Slow EMA is filled with a [b]Trend Ribbon[/b] — yellow-green during bull conditions, red during bear conditions, and gray when the market is neutral or transitioning. The ribbon visually communicates the current trend state at a glance without requiring you to read any values.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]The Confluence Scoring System[/b]

Every signal in AlphaX Sniper is produced by a [b]real-time confluence scoring engine[/b] that evaluates six independent factors and produces a bull score and a bear score from 0 to 100 on every bar.

[b]Trend Strength (up to 30 points)[/b]
[list]
[*]Strong Bull/Bear Trend (score ±3 or ±4) — 30 points
[*]Moderate Trend (score ±2) — 20 points
[*]Mild Trend (score ±1) — 10 points
[*]Neutral — 0 points
[/list]

[b]RSI Positioning (up to 20 points)[/b]
[list]
[*]RSI recovering from pullback zone (crossing back above/below threshold) — 20 points
[*]RSI sitting in pullback zone — 12 points
[*]RSI already extended in the opposite direction — up to -15 points (penalty)
[/list]

[b]Stochastic Trigger (up to 15 points)[/b]
[list]
[*]%K crossing %D while recovering from oversold/overbought territory — 15 points
[*]%K/%D crossover alone — 12 points
[*]%K exiting oversold or overbought zone — 8 points
[/list]

[b]MACD Alignment (up to 10 points)[/b]
[list]
[*]When MACD filter is enabled: aligned and accelerating — 10 points; aligned but flat — 5 points
[*]When MACD filter is disabled: full 10 points awarded by default (does not penalize)
[/list]

[b]Volume Quality (up to 10 points)[/b]
[list]
[*]Volume spike (>1.5× the 20-SMA) — 10 points
[*]Above-average volume (>1.0×) — 7 points
[*]Meets minimum volume threshold — 4 points
[/list]

[b]Candle Structure, HTF Bias & Session (up to 10 points)[/b]
[list]
[*]Strong directional candle with solid body — 5 points
[*]Higher timeframe EMA alignment confirming the same direction — 5 points
[*]London/NY overlap session — 5 points; London or NY solo — 3 points; Asia — 0 points
[/list]

[b]Penalty Deductions[/b]
[list]
[*]RSI at extreme opposing level — up to -15 points
[*]Low volatility (ATR filter active and failing) — -10 points
[*]Asian session — -8 points
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Three-Tier Signal Grading (A / AA / AAA)[/b]

[i]Tiered signal labels — AAA signals carry the highest confluence score and strongest setup quality[/i]

Once the confluence scores are calculated and all filters pass, signals are graded into three quality tiers:

[list]
[*][b]AAA ▲ / ▼[/b] — Score ≥ 65. Maximum confluence. All major factors aligned. Highest-conviction entries. Displayed with the brightest label color.
[*][b]AA ▲ / ▼[/b] — Score 45–64. Strong setup with multiple confirming factors. High-quality entry with most conditions in your favor.
[*][b]A ▲ / ▼[/b] — Score 30–44. Valid setup meeting all trigger and filter requirements, but fewer confirming factors. Still a filtered, quality signal — not noise.
[/list]

Signals below 30 are never displayed regardless of trigger conditions. The tier label appears directly on the chart with the score printed in parentheses so you can see exactly how strong the confluence was: e.g. [b]▲ AAA (71)[/b] or [b]▼ AA (52)[/b].

A [b]cooldown window[/b] (default: 5 bars) prevents back-to-back signals from firing in quick succession during choppy conditions. Bull and bear cooldowns are tracked independently.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]ATR-Based TP/SL Levels[/b]

[i]Automatically plotted TP1, TP2, TP3, and SL dashed lines extending forward from every signal bar[/i]

Every signal automatically generates a full set of [b]Take Profit and Stop Loss levels[/b] based on the current ATR, placing them at configurable multiples of market volatility rather than fixed pip values:

[list]
[*][b]Stop Loss[/b] — 1.5× ATR from entry (default) — tight enough to protect capital, wide enough to breathe
[*][b]TP1[/b] — 1.5× ATR — the conservative first target, ideal for partial profit-taking
[*][b]TP2[/b] — 3.0× ATR — the primary target for the main portion of the position
[*][b]TP3[/b] — 5.0× ATR — the extended runner target for strong momentum moves
[/list]

All levels are plotted as dashed horizontal lines extending 25 bars forward from the signal bar with clean price labels. As price hits each level, a [b]TP1 ✓ / TP2 ✓ / TP3 ✓[/b] marker appears on the chart and the dashboard TP Status updates in real time. When the stop loss is hit, a [b]SL ✕[/b] marker appears and the active trade state resets.

All ATR multiples are fully configurable. Adjust the SL multiple tighter for higher-timeframe trades or wider for volatile instruments like XAUUSD during news events.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡 [b]Trailing Stop[/b]

A [b]dynamic trailing stop</b> follows the active trade, ratcheting in the direction of the move to protect accumulated profits:

[list]
[*]During a long trade — the trail is calculated as [i]close − (ATR × multiplier)[/i] and only moves upward, never retracing
[*]During a short trade — the trail is [i]close + (ATR × multiplier)[/i] and only moves downward
[*]If price violates the trailing stop, the active trade state resets and the trail line disappears
[*]Default trail multiplier: 2.0× ATR — aggressive enough to capture trends while giving the position room to breathe
[/list]

The trailing stop is plotted as a step-line in the bull or bear color and updates on every bar in real time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🗺 [b]Sniper Kill Zones[/b]

[i]Shaded entry zones appearing on signal bars — the price area between the entry candle and the stop loss level[/i]

On every signal bar, AlphaX Sniper draws a [b]Sniper Kill Zone[/b] — a shaded rectangular box that marks the entry price area:

[list]
[*]For bull signals — the zone spans from the signal bar's high down to the stop loss level, colored in the bull theme
[*]For bear signals — the zone spans from the stop loss level down to the bar's low, colored in the bear theme
[*]The box extends forward a configurable number of bars (default: 6) to visually represent the entry window
[/list]

Kill zones serve as a visual reminder of where a valid re-entry or limit order can be placed after the initial signal bar closes. If price pulls back into the zone during the next few bars, the setup is still within its original risk structure.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏱ [b]Session Filter & Session Quality[/b]

Session timing has a direct impact on signal quality. AlphaX Sniper tracks four session windows based on UTC/GMT time:

[list]
[*][b]London/NY Overlap[/b] — highest liquidity, strongest follow-through, 100 session quality score
[*][b]New York[/b] — strong directional sessions, 85 quality score
[*][b]London[/b] — clean trend sessions especially in the open, 80 quality score
[*][b]Asia[/b] — lowest liquidity, prone to false moves, 30 quality score — signals here receive an -8 point penalty
[/list]

The optional [b]Session Filter[/b] can be enabled to block all signals outside of London and NY entirely. When disabled (default), the session quality factor still penalizes Asian session signals through the scoring system — you see them, but they score lower.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 [b]Live Dashboard[/b]

[i]Real-time dashboard showing all key market state values at a glance[/i]

The built-in dashboard displays a full snapshot of current market conditions in real time:

[list]
[*][b]TREND[/b] — current trend state: STRONG BULL / BULL / MILD BULL / NEUTRAL / MILD BEAR / BEAR / STRONG BEAR
[*][b]TREND SCORE[/b] — the raw score from -4 to +4 powering the trend classification
[*][b]RSI[/b] — current RSI value color-coded by zone (overbought / neutral / oversold)
[*][b]STOCH K[/b] — current stochastic %K value with overbought/oversold coloring
[*][b]MACD[/b] — current MACD state: BULL MOM / BULL / BEAR MOM / BEAR / FLAT
[*][b]VOLUME[/b] — volume classification (SPIKE / HIGH / NORMAL / DRY) with live ×ratio vs the 20-SMA
[*][b]ATR[/b] — current ATR value and ATR as a percentage of price
[*][b]SESSION[/b] — current active session name (LN/NY / NEW YORK / LONDON / ASIA / OFF-SESSION)
[*][b]HTF BIAS[/b] — higher timeframe EMA alignment: BULLISH / BEARISH / NEUTRAL
[*][b]ACTIVE TRADE[/b] — current trade direction: LONG / SHORT / NONE
[*][b]TP STATUS[/b] — live progress through the TP levels: RUNNING → TP1 ✓ → TP2 ✓✓ → TP3 ✓✓✓ / SL HIT
[*][b]BULL SCORE[/b] — current bull confluence score out of 100
[*][b]BEAR SCORE[/b] — current bear confluence score out of 100
[/list]

Dashboard position (Top Right default), text size, and colors are all configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Sniper — Step by Step[/b]

[b]Step 1 — Read the Dashboard[/b]
[list]
[*]Check the Trend and Trend Score — are you in a strong trend or a neutral range?
[*]Check HTF Bias — does the higher timeframe EMA structure confirm your direction?
[*]Check Session — are you in London or NY? If Asia, expect lower-quality signals.
[/list]

[b]Step 2 — Wait for a Tiered Signal[/b]
[list]
[*]An [b]▲ AAA / AA / A[/b] label below the bar is your bull entry signal
[*]A [b]▼ AAA / AA / A[/b] label above the bar is your bear entry signal
[*]Prioritize AAA signals in trending markets — these represent maximum confluence
[*]AA signals are still high quality and tradable in most conditions
[*]A signals are valid but consider taking smaller size or waiting for additional confirmation
[/list]

[b]Step 3 — Use the Kill Zone for Entry[/b]
[list]
[*]Enter at the close of the signal bar, or wait for a pullback into the Kill Zone
[*]A limit order inside the Kill Zone can offer a better entry price while staying within the original risk structure
[/list]

[b]Step 4 — Set Your Levels[/b]
[list]
[*]Stop Loss is plotted automatically — honor it
[*]Target TP1 first for a partial close, then trail the remainder toward TP2 and TP3
[*]Let the trailing stop manage the remainder once TP1 is achieved
[/list]

[b]Step 5 — Monitor TP Progress[/b]
[list]
[*]The dashboard TP Status updates as each level is hit
[*]TP ✓ markers appear on the chart at the bar where each target was reached
[*]If the trailing stop tightens and triggers before TP3, that is the system protecting your profit — respect it
[/list]

[b]Step 6 — Reset on SL Hit[/b]
[list]
[*]An [b]SL ✕[/b] marker appears when price hits the stop level
[*]The active trade state resets — the dashboard returns to NONE and TP tracking clears
[*]Reassess the dashboard for a fresh signal before re-entering
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]📊 Four-EMA Trend Engine with -4 to +4 scoring — classifies trend into 7 distinct strength states
[*]🎯 Three-tier signal grading (A / AA / AAA) — score printed on every label for full transparency
[*]🧠 Multi-factor confluence scoring across trend, RSI, Stochastic, MACD, volume, session, and HTF bias
[*]📐 Automatic ATR-based TP1 / TP2 / TP3 and SL levels plotted on every signal
[*]🛡 Dynamic trailing stop — ratchets with the move, resets on breach
[*]🗺 Sniper Kill Zones — shaded entry boxes marking the valid entry area for limit orders
[*]⏱ Session-aware scoring — London/NY overlap rewarded, Asia penalized
[*]🔭 Higher timeframe bias filter — built-in HTF EMA alignment check without switching charts
[*]⚙ Optional filters — Volume, Candle Body Strength, MACD Alignment, ATR Volatility Minimum, Session
[*]🕒 Configurable signal cooldown — prevents signal spam during choppy transitions
[*]📋 Live 13-row dashboard — trend state, scores, oscillators, volume, session, trade status, TP progress
[*]🎨 Cohesive dual-tone color system — yellow-green for bull, red for bear, gray for neutral
[*]🔔 17 alert conditions — tiered entries, any entry, TP levels, SL, trend state changes
[*]⚙ Fully configurable — all EMA periods, RSI/Stoch parameters, TP/SL multiples, filters, colors, and dashboard settings
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Trend Engine[/b]
[list]
[*]Trend Fast EMA — momentum reference (default: 8)
[*]Trend Medium EMA — intermediate confirmation (default: 21)
[*]Trend Slow EMA — trend backbone (default: 55)
[*]Trend Anchor EMA — macro structural divider (default: 200)
[*]Show Trend EMAs — toggle EMA line and ribbon visibility
[*]Show Anchor EMA (200) — toggle the 200 EMA separately
[/list]

[b]Sniper Entry[/b]
[list]
[*]RSI Period — oscillator lookback (default: 9)
[*]RSI Bull Pullback ≤ — threshold defining the bull pullback zone (default: 48)
[*]RSI Bear Pullback ≥ — threshold defining the bear pullback zone (default: 52)
[*]Stoch Length — stochastic lookback (default: 14)
[*]Stoch Smooth — %K smoothing period (default: 3)
[*]Stoch Overbought / Oversold — extreme zone thresholds (default: 75 / 25)
[/list]

[b]Precision Filters[/b]
[list]
[*]Require Volume Confirmation — enforce minimum volume vs 20-SMA (default: off)
[*]Min Volume vs 20-SMA — minimum volume ratio when filter is on (default: 0.6×)
[*]Require Candle Strength — enforce minimum body/range ratio (default: on)
[*]Min Body/Range Ratio — minimum candle body as a fraction of full range (default: 0.25)
[*]Require MACD Alignment — block signals when MACD is counter-directional (default: off)
[*]Filter Low Volatility — require minimum ATR % of price (default: off)
[*]Min ATR % of Price — minimum ATR threshold when volatility filter is on (default: 0.02%)
[*]Signal Cooldown (bars) — minimum bars between same-direction signals (default: 5)
[/list]

[b]TP / SL[/b]
[list]
[*]Show TP/SL Levels — toggle all TP and SL line display
[*]ATR Period for TP/SL — ATR calculation period (default: 14)
[*]Stop Loss ATR Multiple — SL distance (default: 1.5×)
[*]TP1 / TP2 / TP3 ATR Multiples — target distances (defaults: 1.5× / 3.0× / 5.0×)
[/list]

[b]Sniper Zones[/b]
[list]
[*]Show Sniper Kill Zones — toggle entry zone boxes
[*]Zone Forward Extension — how many bars the zone box extends forward (default: 6)
[/list]

[b]Session Filter[/b]
[list]
[*]Enable Session Filter — block signals outside kill zone windows (default: off)
[*]London Open / NY Open / NY Close / Asia Open / Asia Close — configurable GMT hour boundaries
[/list]

[b]Appearance[/b]
[list]
[*]Label Size — Tiny / Small / Normal
[*]Show Trailing Stop — toggle trailing stop line
[*]Trail ATR Multiple — trailing stop distance (default: 2.0×)
[/list]

[b]Colors[/b]
[list]
[*]Full dual-tone color system — every bull, bear, and neutral element is independently configurable
[*]Separate colors for: ribbon, EMAs, labels (background + text), TP lines, SL lines, kill zones, trailing stops, dashboard
[/list]

[b]Dashboard[/b]
[list]
[*]Show Dashboard — toggle visibility
[*]Position — Top Left / Top Right / Bottom Left / Bottom Right (default: Top Right)
[*]Text Size — Tiny / Small / Normal
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]
[list]
[*]AAA Bull Sniper Entry — fires on maximum-confluence bull signals only
[*]AA Bull Sniper Entry — fires on high-quality bull signals
[*]A Bull Sniper Entry — fires on valid bull signals
[*]AAA / AA / A Bear Sniper Entry — same three tiers for bear signals
[*]Any Bull Sniper Entry — fires on any bull signal regardless of tier
[*]Any Bear Sniper Entry — fires on any bear signal regardless of tier
[*]Any Sniper Entry — fires on any signal in either direction
[*]TP1 Hit / TP2 Hit / TP3 Hit — fires when each take profit level is reached
[*]Stop Loss Hit — fires when the stop loss is breached
[*]Strong Bull Trend Started — fires when Trend Score first reaches ≥ +3
[*]Strong Bear Trend Started — fires when Trend Score first reaches ≤ -3
[/list]
All alert messages include {{ticker}} and {{interval}} placeholders for clean webhook integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Default Settings — Optimized For[/b]

The default configuration is specifically tuned for [b]XAUUSD (Gold) on the 1-minute and 5-minute timeframes[/b]:
[list]
[*]RSI period of 9 for fast response to gold's intraday price swings
[*]Candle Strength filter on (0.25 body ratio) to avoid wicks and indecision candles
[*]Cooldown of 5 bars prevents signal clustering during volatile transitions
[*]Session scoring automatically penalizes Asian-session signals on gold
[*]Trail ATR multiple at 2.0× provides generous breathing room for gold's characteristic oscillations
[/list]

For other instruments or timeframes, consider adjusting:
[list]
[*][b]Higher timeframes (15m, 1H)[/b] — increase EMA periods, increase TP2/TP3 multiples to 4×/7×
[*][b]Forex majors[/b] — reduce Fast EMA to 5–8, reduce SL multiple to 1.0–1.2×
[*][b]Indices (NAS100, US30)[/b] — increase RSI period to 11–14, enable MACD filter for extra precision
[*][b]More signals[/b] — reduce cooldown, disable Candle Strength filter, lower score threshold to ~25
[*][b]Fewer signals[/b] — enable all filters, increase cooldown to 8–10 bars, use AAA alerts only
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🥇 [b]Gold (XAUUSD) scalpers and intraday traders[/b] — default settings tuned specifically for gold's session structure and volatility
[*]📉 [b]Forex traders[/b] — applicable to all majors and minors with minor EMA and RSI adjustments
[*]📊 [b]Index traders[/b] — works on US30, NAS100, SPX500, DAX, and others
[*]🧠 [b]Data-driven traders[/b] — the scored, graded signal system provides a quantitative framework rather than arbitrary lines on a chart
[*]🎯 [b]Precision-focused traders[/b] — tiered grading lets you focus exclusively on AAA setups for the highest-conviction trades
[*]📈 [b]Trade management focused traders[/b] — the automatic TP/SL levels, trailing stop, and live TP status tracker remove the guesswork from position management
[*]⚠ [b]Traders who struggle with overtrading[/b] — the cooldown, minimum score threshold, and optional filters physically prevent low-quality signals from appearing
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]Session detection uses UTC/GMT — the indicator automatically identifies London, NY, and Asia windows on any broker timezone
[*]Higher timeframe bias is calculated using multiplied EMA periods on the same chart rather than requesting a secondary timeframe — this avoids repainting and keeps all calculations on bar close
[*]All signal conditions are evaluated on bar close — the indicator does not repaint
[*]The trailing stop logic and TP hit detection use intrabar high/low values to accurately reflect when levels were reached, consistent with standard trade execution behavior
[*]Maximum 500 labels are used — on very long chart histories at low timeframes, the oldest labels may be automatically removed by TradingView's rendering limits
[*]Volume-based features (volume filter, volume score) may behave differently on instruments with limited volume data — consider disabling the volume filter on synthetics and CFDs if volume data is unreliable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who demand precision over volume — fewer signals, higher conviction, complete trade management.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX
//@version=6
indicator("AlphaX Sniper – Multi Confluence Entry Signals with ATR TP/SL", shorttitle="AlphaX Sniper", overlay=true,
  max_labels_count=500, max_lines_count=500, max_boxes_count=200, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ INPUTS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// ── Trend Engine ───────────────────────────────────────────────────────────────
trendFastLen   = input.int(8,    "Trend Fast EMA",       minval=3,   maxval=30,  group="Trend Engine")
trendMedLen    = input.int(21,   "Trend Medium EMA",     minval=10,  maxval=50,  group="Trend Engine")
trendSlowLen   = input.int(55,   "Trend Slow EMA",       minval=30,  maxval=100, group="Trend Engine")
trendAnchorLen = input.int(200,  "Trend Anchor EMA",     minval=100, maxval=500, group="Trend Engine")
showTrendEMAs  = input.bool(true,"Show Trend EMAs",                              group="Trend Engine")
showAnchorEMA  = input.bool(true,"Show Anchor EMA (200)",                        group="Trend Engine")

// ── Sniper Entry ───────────────────────────────────────────────────────────────
rsiLen         = input.int(9,    "RSI Period",           minval=5,   maxval=20,  group="Sniper Entry")
rsiBullZone    = input.float(48, "RSI Bull Pullback ≤",  minval=25,  maxval=55,  step=1, group="Sniper Entry")
rsiBearZone    = input.float(52, "RSI Bear Pullback ≥",  minval=45,  maxval=75,  step=1, group="Sniper Entry")
stochLen       = input.int(14,   "Stoch Length",         minval=5,   maxval=21,  group="Sniper Entry")
stochSmooth    = input.int(3,    "Stoch Smooth",         minval=1,   maxval=5,   group="Sniper Entry")
stochOB        = input.float(75, "Stoch Overbought",     minval=65,  maxval=95,  step=1, group="Sniper Entry")
stochOS        = input.float(25, "Stoch Oversold",       minval=5,   maxval=35,  step=1, group="Sniper Entry")

// ── Precision Filters ──────────────────────────────────────────────────────────
useVolFilter   = input.bool(false, "Require Volume Confirmation",                group="Precision Filters")
volMultiplier  = input.float(0.6,  "Min Volume vs 20-SMA",   minval=0.3, maxval=2.0, step=0.1, group="Precision Filters")
useDispFilter  = input.bool(true,  "Require Candle Strength",                    group="Precision Filters")
minBodyRatio   = input.float(0.25, "Min Body/Range Ratio",   minval=0.1, maxval=0.8, step=0.05, group="Precision Filters")
useMacdFilter  = input.bool(false, "Require MACD Alignment",                    group="Precision Filters")
useAtrFilter   = input.bool(false, "Filter Low Volatility",                     group="Precision Filters")
atrMinPct      = input.float(0.02, "Min ATR % of Price",     minval=0.01, maxval=0.1, step=0.005, group="Precision Filters")
cooldownBars   = input.int(8,      "Signal Cooldown (bars)",  minval=1, maxval=30, group="Precision Filters")

// ── Take Profit & Stop Loss ────────────────────────────────────────────────────
showTPSL       = input.bool(true,  "Show TP/SL Levels",                          group="TP / SL")
atrTPSLLen     = input.int(14,     "ATR Period for TP/SL",    minval=5, maxval=30, group="TP / SL")
slMultiplier   = input.float(1.5,  "Stop Loss ATR Multiple",  minval=0.5, maxval=4.0, step=0.1, group="TP / SL")
tp1Multiplier  = input.float(1.5,  "TP1 ATR Multiple",        minval=0.5, maxval=4.0, step=0.1, group="TP / SL")
tp2Multiplier  = input.float(3.0,  "TP2 ATR Multiple",        minval=1.0, maxval=8.0, step=0.1, group="TP / SL")
tp3Multiplier  = input.float(5.0,  "TP3 ATR Multiple",        minval=2.0, maxval=12.0, step=0.1, group="TP / SL")

// ── Sniper Zones ───────────────────────────────────────────────────────────────
showSniperZones = input.bool(true, "Show Sniper Kill Zones",                     group="Sniper Zones")
zoneExtendBars  = input.int(6,     "Zone Forward Extension",  minval=2, maxval=20, group="Sniper Zones")

// ── Session Filter ─────────────────────────────────────────────────────────────
useSessionFilter  = input.bool(false,  "Enable Session Filter",                  group="Session Filter")
sessionLondonOpen = input.int(8,       "London Open (GMT Hour)",  minval=0, maxval=23, group="Session Filter")
sessionNYOpen     = input.int(13,      "NY Open (GMT Hour)",      minval=0, maxval=23, group="Session Filter")
sessionNYClose    = input.int(21,      "NY Close (GMT Hour)",     minval=0, maxval=23, group="Session Filter")
sessionAsiaOpen   = input.int(0,       "Asia Open (GMT Hour)",    minval=0, maxval=23, group="Session Filter")
sessionAsiaClose  = input.int(8,       "Asia Close (GMT Hour)",   minval=0, maxval=23, group="Session Filter")

// ── Appearance ─────────────────────────────────────────────────────────────────
labelSizeInput = input.string("Small", "Label Size",
  options=["Tiny","Small","Normal"],                                               group="Appearance")
showTrail      = input.bool(true,  "Show Trailing Stop",                          group="Appearance")
trailATRMult   = input.float(2.0,  "Trail ATR Multiple",  minval=0.5, maxval=5.0, step=0.1, group="Appearance")

// ── Colors ─────────────────────────────────────────────────────────────────────
colBullPrimary   = input.color(#c8e624, "Bull Primary",          group="Colors")
colBullBright    = input.color(#d4f03a, "Bull Bright",           group="Colors")
colBullDim       = input.color(#9ab81c, "Bull Dim",              group="Colors")
colBearPrimary   = input.color(#ff1744, "Bear Primary",          group="Colors")
colBearBright    = input.color(#ff5252, "Bear Bright",           group="Colors")
colBearDim       = input.color(#d50032, "Bear Dim",              group="Colors")
colNeutral       = input.color(#555555, "Neutral",               group="Colors")
colNeutralLight  = input.color(#888888, "Neutral Light",         group="Colors")
colTextLight     = input.color(#cccccc, "Dashboard Text",        group="Colors")
colDashBg        = input.color(#1a1a1a, "Dashboard Background",  group="Colors")
colTrailBull     = input.color(#c8e624, "Trail Stop Bull",       group="Colors")
colTrailBear     = input.color(#ff1744, "Trail Stop Bear",       group="Colors")
colTPLine        = input.color(#c8e624, "TP Line Color",         group="Colors")
colSLLine        = input.color(#ff1744, "SL Line Color",         group="Colors")
colZoneBull      = input.color(#c8e624, "Sniper Zone Bull",      group="Colors")
colZoneBear      = input.color(#ff1744, "Sniper Zone Bear",      group="Colors")
colRibbonBull    = input.color(#9ab81c, "Ribbon Fill Bull",      group="Colors")
colRibbonBear    = input.color(#d50032, "Ribbon Fill Bear",      group="Colors")
colEmaFast       = input.color(#c8e624, "Fast EMA",              group="Colors")
colEmaMed        = input.color(#888888, "Medium EMA",            group="Colors")
colEmaSlow       = input.color(#555555, "Slow EMA",              group="Colors")
colEmaAnchor     = input.color(#555555, "Anchor EMA",            group="Colors")
colBullLabelBg   = input.color(#c8e624, "Bull Label Background", group="Colors")
colBearLabelBg   = input.color(#ff1744, "Bear Label Background", group="Colors")
colBullLabelTxt  = input.color(#1a1a1a, "Bull Label Text",       group="Colors")
colBearLabelTxt  = input.color(#ffffff, "Bear Label Text",       group="Colors")

// ── Dashboard ──────────────────────────────────────────────────────────────────
showDash       = input.bool(true,  "Show Dashboard",                              group="Dashboard")
dashPos        = input.string("Top Right", "Position",
  options=["Top Left","Top Right","Bottom Left","Bottom Right"],                    group="Dashboard")
dashSizeInput  = input.string("Small", "Text Size",
  options=["Tiny","Small","Normal"],                                               group="Dashboard")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ HELPERS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getLabelSize(sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

labelSize    = getLabelSize(labelSizeInput)
dashTextSize = getLabelSize(dashSizeInput)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ TREND ENGINE ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

emaFast   = ta.ema(close, trendFastLen)
emaMed    = ta.ema(close, trendMedLen)
emaSlow   = ta.ema(close, trendSlowLen)
emaAnchor = ta.ema(close, trendAnchorLen)

ribbonBull = emaFast > emaMed and emaMed > emaSlow
ribbonBear = emaFast < emaMed and emaMed < emaSlow

fastSlopeUp   = emaFast > emaFast[1] and emaFast[1] > emaFast[2]
fastSlopeDown = emaFast < emaFast[1] and emaFast[1] < emaFast[2]
medSlopeUp    = emaMed > emaMed[1]
medSlopeDown  = emaMed < emaMed[1]

aboveAnchor = close > emaAnchor
belowAnchor = close < emaAnchor

trendScore = (ribbonBull ? 1 : ribbonBear ? -1 : 0) +
  (fastSlopeUp ? 1 : fastSlopeDown ? -1 : 0) +
  (medSlopeUp ? 1 : medSlopeDown ? -1 : 0) +
  (aboveAnchor ? 1 : belowAnchor ? -1 : 0)

strongBullTrend   = trendScore >= 3
strongBearTrend   = trendScore <= -3
moderateBullTrend = trendScore >= 2
moderateBearTrend = trendScore <= -2

ribbonColor = ribbonBull ? colRibbonBull :
  ribbonBear ? colRibbonBear : colNeutral

plot(showTrendEMAs ? emaFast : na, "Fast EMA",
  color=showTrendEMAs ? color.new(colEmaFast, ribbonBull ? 30 : ribbonBear ? 80 : 60) : na,
  linewidth=1)
plot(showTrendEMAs ? emaMed : na, "Medium EMA",
  color=showTrendEMAs ? color.new(colEmaMed, 30) : na,
  linewidth=1)
plot(showTrendEMAs ? emaSlow : na, "Slow EMA",
  color=showTrendEMAs ? color.new(colEmaSlow, 30) : na,
  linewidth=2)
plot(showAnchorEMA ? emaAnchor : na, "Anchor EMA",
  color=showAnchorEMA ? color.new(colEmaAnchor, 50) : na,
  linewidth=3, style=plot.style_line)

fastPlot = plot(showTrendEMAs ? emaFast : na, display=display.none)
slowPlot = plot(showTrendEMAs ? emaSlow : na, display=display.none)
fill(fastPlot, slowPlot,
  color=showTrendEMAs ? color.new(ribbonColor, 88) : na,
  title="Trend Ribbon")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ OSCILLATORS ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

rsiVal       = ta.rsi(close, rsiLen)
rsiPullUp    = rsiVal <= rsiBullZone and rsiVal > 20
rsiPullDn    = rsiVal >= rsiBearZone and rsiVal < 80
rsiRecoverUp = rsiVal > rsiBullZone and rsiVal[1] <= rsiBullZone
rsiRecoverDn = rsiVal < rsiBearZone and rsiVal[1] >= rsiBearZone

stochK       = ta.stoch(close, high, low, stochLen)
stochD       = ta.sma(stochK, stochSmooth)
stochCrossUp = ta.crossover(stochK, stochD) and stochK < stochOB
stochCrossDn = ta.crossunder(stochK, stochD) and stochK > stochOS
stochFromOS  = stochK[1] < stochOS and stochK > stochOS
stochFromOB  = stochK[1] > stochOB and stochK < stochOB

[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)
macdBullish   = macdLine > signalLine
macdBearish   = macdLine < signalLine
macdMomUp     = macdHist > macdHist[1]
macdMomDn     = macdHist < macdHist[1]
macdBullAlign = macdBullish and macdMomUp
macdBearAlign = macdBearish and macdMomDn

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ VOLATILITY & VOLUME ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

atrVal      = ta.atr(14)
atrPct      = atrVal / close * 100
atrTPSL     = ta.atr(atrTPSLLen)
volSMA      = ta.sma(volume, 20)
volRatio    = volSMA > 0 ? volume / volSMA : 1.0
volOK       = not useVolFilter or volRatio >= volMultiplier
atrOK       = not useAtrFilter or atrPct >= atrMinPct

candleBody  = math.abs(close - open)
candleRange = high - low
bodyRatio   = candleRange > 0 ? candleBody / candleRange : 0
bullCandle  = close > open
bearCandle  = close < open
strongBody  = bodyRatio >= minBodyRatio
candleOK    = not useDispFilter or strongBody

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SESSION FILTER ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

currentHour = hour(time, "UTC")
inLondon    = currentHour >= sessionLondonOpen and currentHour < sessionNYClose
inNY        = currentHour >= sessionNYOpen and currentHour < sessionNYClose
inAsia      = currentHour >= sessionAsiaOpen and currentHour < sessionAsiaClose
inKillZone  = inLondon or inNY
sessionOK   = not useSessionFilter or inKillZone

sessionName = inNY and inLondon ? "LN/NY" :
  inNY ? "NEW YORK" :
  inLondon ? "LONDON" :
  inAsia ? "ASIA" : "OFF-SESSION"

sessionQuality = inNY and inLondon ? 100 :
  inNY ? 85 :
  inLondon ? 80 :
  inAsia ? 30 : 20

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ MULTI-TIMEFRAME CONFLUENCE ═══════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

htfEmaFast = ta.ema(close, trendFastLen * 5)
htfEmaSlow = ta.ema(close, trendSlowLen * 5)
htfBullish = htfEmaFast > htfEmaSlow
htfBearish = htfEmaFast < htfEmaSlow

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SNIPER CONFLUENCE SCORING ════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// Trend exhaustion helpers
emaDist         = math.abs(close - emaAnchor) / emaAnchor * 100
emaExtended     = emaDist > 1.5
emaVeryExtended = emaDist > 3.0

var int ribbonBullBars = 0
var int ribbonBearBars = 0
ribbonBullBars := ribbonBull ? ribbonBullBars + 1 : 0
ribbonBearBars := ribbonBear ? ribbonBearBars + 1 : 0

trendAged     = ribbonBullBars > 80 or ribbonBearBars > 80
trendVeryAged = ribbonBullBars > 150 or ribbonBearBars > 150

calcBullScore() =>
    float s = 0.0
    s += strongBullTrend ? 30.0 : moderateBullTrend ? 20.0 :
      trendScore >= 1 ? 10.0 : 0.0
    s += rsiRecoverUp ? 20.0 : rsiPullUp ? 12.0 : 0.0
    s += stochCrossUp and stochFromOS ? 15.0 :
      stochCrossUp ? 12.0 : stochFromOS ? 8.0 : 0.0
    s += useMacdFilter ? (macdBullAlign ? 10.0 : macdBullish ? 5.0 : 0.0) : 10.0
    s += volRatio > 1.5 ? 10.0 : volRatio > 1.0 ? 7.0 : volOK ? 4.0 : 0.0
    s += bullCandle and strongBody ? 5.0 : bullCandle ? 2.0 : 0.0
    s += htfBullish ? 5.0 : 0.0
    s += sessionQuality >= 80 ? 5.0 : sessionQuality >= 50 ? 3.0 : 0.0
    s -= rsiVal > 75 ? 15.0 : rsiVal > 68 ? 8.0 : 0.0
    s -= not atrOK ? 10.0 : 0.0
    s -= inAsia ? 8.0 : 0.0
    // Exhaustion penalties
    s -= emaVeryExtended ? 20.0 : emaExtended ? 10.0 : 0.0
    s -= trendVeryAged ? 18.0 : trendAged ? 10.0 : 0.0
    math.max(0.0, math.min(100.0, s))

calcBearScore() =>
    float s = 0.0
    s += strongBearTrend ? 30.0 : moderateBearTrend ? 20.0 :
      trendScore <= -1 ? 10.0 : 0.0
    s += rsiRecoverDn ? 20.0 : rsiPullDn ? 12.0 : 0.0
    s += stochCrossDn and stochFromOB ? 15.0 :
      stochCrossDn ? 12.0 : stochFromOB ? 8.0 : 0.0
    s += useMacdFilter ? (macdBearAlign ? 10.0 : macdBearish ? 5.0 : 0.0) : 10.0
    s += volRatio > 1.5 ? 10.0 : volRatio > 1.0 ? 7.0 : volOK ? 4.0 : 0.0
    s += bearCandle and strongBody ? 5.0 : bearCandle ? 2.0 : 0.0
    s += htfBearish ? 5.0 : 0.0
    s += sessionQuality >= 80 ? 5.0 : sessionQuality >= 50 ? 3.0 : 0.0
    s -= rsiVal < 25 ? 15.0 : rsiVal < 32 ? 8.0 : 0.0
    s -= not atrOK ? 10.0 : 0.0
    s -= inAsia ? 8.0 : 0.0
    // Exhaustion penalties
    s -= emaVeryExtended ? 20.0 : emaExtended ? 10.0 : 0.0
    s -= trendVeryAged ? 18.0 : trendAged ? 10.0 : 0.0
    math.max(0.0, math.min(100.0, s))
    
bullScore = calcBullScore()
bearScore = calcBearScore()

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SIGNAL GENERATION ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

mildBullTrend = trendScore >= 1
mildBearTrend = trendScore <= -1

bullTrigger = (rsiRecoverUp or stochCrossUp or stochFromOS) and
  bullCandle and mildBullTrend
bearTrigger = (rsiRecoverDn or stochCrossDn or stochFromOB) and
  bearCandle and mildBearTrend

bullFiltered = bullTrigger and volOK and atrOK and candleOK and sessionOK
bearFiltered = bearTrigger and volOK and atrOK and candleOK and sessionOK

bullGated = bullFiltered and (not useMacdFilter or macdBullish)
bearGated = bearFiltered and (not useMacdFilter or macdBearish)

var int lastBullBar = -999
var int lastBearBar = -999

bullCoolOK = bar_index - lastBullBar >= cooldownBars
bearCoolOK = bar_index - lastBearBar >= cooldownBars

bullAAA = bullGated and bullScore >= 65 and bullCoolOK
bullAA  = bullGated and bullScore >= 45 and bullScore < 65 and bullCoolOK
bullA   = bullGated and bullScore >= 30 and bullScore < 45 and bullCoolOK

bearAAA = bearGated and bearScore >= 65 and bearCoolOK
bearAA  = bearGated and bearScore >= 45 and bearScore < 65 and bearCoolOK
bearA   = bearGated and bearScore >= 30 and bearScore < 45 and bearCoolOK

bullSignal = bullAAA or bullAA or bullA
bearSignal = bearAAA or bearAA or bearA

if bullSignal
    lastBullBar := bar_index
if bearSignal
    lastBearBar := bar_index

bullTier = bullAAA ? "AAA" : bullAA ? "AA" : "A"
bearTier = bearAAA ? "AAA" : bearAA ? "AA" : "A"

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ TP / SL CALCULATION ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var float activeSL    = na
var float activeTP1   = na
var float activeTP2   = na
var float activeTP3   = na
var float activeEntry = na
var int   activeDir   = 0
var int   activeBar   = na
var bool  tp1Hit      = false
var bool  tp2Hit      = false
var bool  tp3Hit      = false
var bool  slHit       = false

if bullSignal
    activeEntry := close
    activeSL    := close - atrTPSL * slMultiplier
    activeTP1   := close + atrTPSL * tp1Multiplier
    activeTP2   := close + atrTPSL * tp2Multiplier
    activeTP3   := close + atrTPSL * tp3Multiplier
    activeDir   := 1
    activeBar   := bar_index
    tp1Hit      := false
    tp2Hit      := false
    tp3Hit      := false
    slHit       := false

if bearSignal
    activeEntry := close
    activeSL    := close + atrTPSL * slMultiplier
    activeTP1   := close - atrTPSL * tp1Multiplier
    activeTP2   := close - atrTPSL * tp2Multiplier
    activeTP3   := close - atrTPSL * tp3Multiplier
    activeDir   := -1
    activeBar   := bar_index
    tp1Hit      := false
    tp2Hit      := false
    tp3Hit      := false
    slHit       := false

if activeDir == 1 and not na(activeEntry)
    if high >= activeTP1 and not tp1Hit
        tp1Hit := true
    if high >= activeTP2 and not tp2Hit
        tp2Hit := true
    if high >= activeTP3 and not tp3Hit
        tp3Hit := true
    if low <= activeSL and not slHit
        slHit := true
        activeDir := 0

if activeDir == -1 and not na(activeEntry)
    if low <= activeTP1 and not tp1Hit
        tp1Hit := true
    if low <= activeTP2 and not tp2Hit
        tp2Hit := true
    if low <= activeTP3 and not tp3Hit
        tp3Hit := true
    if high >= activeSL and not slHit
        slHit := true
        activeDir := 0

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ TRAILING STOP ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

trailATR = ta.atr(14) * trailATRMult
var float trailStop = na

if activeDir == 1
    newTrail = close - trailATR
    if na(trailStop) or newTrail > trailStop
        trailStop := newTrail
    if low < trailStop
        activeDir := 0
        trailStop := na
else if activeDir == -1
    newTrail = close + trailATR
    if na(trailStop) or newTrail < trailStop
        trailStop := newTrail
    if high > trailStop
        activeDir := 0
        trailStop := na
else
    trailStop := na

plot(showTrail and not na(trailStop) ? trailStop : na, "Trailing Stop",
  color=activeDir == 1 ? color.new(colTrailBull, 40) : color.new(colTrailBear, 40),
  linewidth=1, style=plot.style_steplinebr)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ TP/SL PLOTTING ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var line slLine   = na
var line tp1Line  = na
var line tp2Line  = na
var line tp3Line  = na
var label slLabel  = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

if showTPSL and (bullSignal or bearSignal) and not na(activeEntry)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

    extendEnd = bar_index + 25

    slLine := line.new(bar_index, activeSL, extendEnd, activeSL,
      color=color.new(colSLLine, 30), style=line.style_dashed, width=1)
    slLabel := label.new(extendEnd, activeSL,
      text="SL " + str.tostring(activeSL, format.mintick),
      yloc=yloc.price,
      color=color.new(colSLLine, 100),
      textcolor=colSLLine,
      size=size.tiny, style=label.style_none)

    tp1Line := line.new(bar_index, activeTP1, extendEnd, activeTP1,
      color=color.new(colTPLine, 50), style=line.style_dashed, width=1)
    tp1Label := label.new(extendEnd, activeTP1,
      text="TP1 " + str.tostring(activeTP1, format.mintick),
      yloc=yloc.price,
      color=color.new(colTPLine, 100),
      textcolor=color.new(colTPLine, 30),
      size=size.tiny, style=label.style_none)

    tp2Line := line.new(bar_index, activeTP2, extendEnd, activeTP2,
      color=color.new(colTPLine, 30), style=line.style_dashed, width=1)
    tp2Label := label.new(extendEnd, activeTP2,
      text="TP2 " + str.tostring(activeTP2, format.mintick),
      yloc=yloc.price,
      color=color.new(colTPLine, 100),
      textcolor=colTPLine,
      size=size.tiny, style=label.style_none)

    tp3Line := line.new(bar_index, activeTP3, extendEnd, activeTP3,
      color=color.new(colTPLine, 15), style=line.style_dashed, width=1)
    tp3Label := label.new(extendEnd, activeTP3,
      text="TP3 " + str.tostring(activeTP3, format.mintick),
      yloc=yloc.price,
      color=color.new(colTPLine, 100),
      textcolor=colBullBright,
      size=size.tiny, style=label.style_none)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SNIPER KILL ZONES ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if showSniperZones and bullSignal
    zoneTop = high
    zoneBtm = math.min(low, activeSL)
    box.new(bar_index, zoneTop, bar_index + zoneExtendBars, zoneBtm,
      border_color=color.new(colZoneBull, 70),
      bgcolor=color.new(colZoneBull, 94),
      border_width=1, border_style=line.style_dotted)

if showSniperZones and bearSignal
    zoneTop = math.max(high, activeSL)
    zoneBtm = low
    box.new(bar_index, zoneTop, bar_index + zoneExtendBars, zoneBtm,
      border_color=color.new(colZoneBear, 70),
      bgcolor=color.new(colZoneBear, 94),
      border_width=1, border_style=line.style_dotted)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SIGNAL LABELS ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if bullSignal
    scoreText = str.tostring(bullScore, "#")
    bgClr = bullAAA ? color.new(colBullPrimary, 0) :
      bullAA ? color.new(colBullPrimary, 30) :
      color.new(colBullDim, 55)

    label.new(bar_index, low,
      text="▲ " + bullTier + " (" + scoreText + ")",
      yloc=yloc.belowbar,
      color=bgClr,
      textcolor=colBullLabelTxt,
      size=labelSize,
      style=label.style_label_up)

if bearSignal
    scoreText = str.tostring(bearScore, "#")
    bgClr = bearAAA ? color.new(colBearPrimary, 0) :
      bearAA ? color.new(colBearPrimary, 30) :
      color.new(colBearDim, 55)

    label.new(bar_index, high,
      text="▼ " + bearTier + " (" + scoreText + ")",
      yloc=yloc.abovebar,
      color=bgClr,
      textcolor=colBearLabelTxt,
      size=labelSize,
      style=label.style_label_down)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ EXIT SIGNALS ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if activeDir == 1 and tp1Hit and not tp1Hit[1]
    label.new(bar_index, high,
      text="TP1 ✓", yloc=yloc.abovebar,
      color=color.new(colBullDim, 100),
      textcolor=colBullDim,
      size=size.tiny, style=label.style_none)

if activeDir == 1 and tp2Hit and not tp2Hit[1]
    label.new(bar_index, high,
      text="TP2 ✓", yloc=yloc.abovebar,
      color=color.new(colBullPrimary, 100),
      textcolor=colBullPrimary,
      size=size.tiny, style=label.style_none)

if activeDir == 1 and tp3Hit and not tp3Hit[1]
    label.new(bar_index, high,
      text="TP3 ✓", yloc=yloc.abovebar,
      color=color.new(colBullBright, 100),
      textcolor=colBullBright,
      size=size.tiny, style=label.style_none)

if activeDir == -1 and tp1Hit and not tp1Hit[1]
    label.new(bar_index, low,
      text="TP1 ✓", yloc=yloc.belowbar,
      color=color.new(colBullDim, 100),
      textcolor=colBullDim,
      size=size.tiny, style=label.style_none)

if activeDir == -1 and tp2Hit and not tp2Hit[1]
    label.new(bar_index, low,
      text="TP2 ✓", yloc=yloc.belowbar,
      color=color.new(colBullPrimary, 100),
      textcolor=colBullPrimary,
      size=size.tiny, style=label.style_none)

if activeDir == -1 and tp3Hit and not tp3Hit[1]
    label.new(bar_index, low,
      text="TP3 ✓", yloc=yloc.belowbar,
      color=color.new(colBullBright, 100),
      textcolor=colBullBright,
      size=size.tiny, style=label.style_none)

if slHit and not slHit[1]
    slY    = activeEntry > activeSL ? low : high
    slYloc = activeEntry > activeSL ? yloc.belowbar : yloc.abovebar
    label.new(bar_index, slY,
      text="SL ✕", yloc=slYloc,
      color=color.new(colBearPrimary, 100),
      textcolor=colBearBright,
      size=size.tiny, style=label.style_none)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ DASHBOARD ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 14,
      bgcolor=color.new(colDashBg, 0),
      border_width=1,
      border_color=color.new(colNeutral, 70),
      frame_width=2,
      frame_color=color.new(colNeutral, 35))

if showDash and barstate.islast
    // Row 0 — Title
    table.cell(dash, 0, 0, "A L P H A X   S N I P E R",
      text_color=colBullPrimary, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 0, "",
      bgcolor=color.new(colDashBg, 0))
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1 — Trend
    trendText = strongBullTrend ? "▲ STRONG BULL" :
      moderateBullTrend ? "▲ BULL" :
      strongBearTrend ? "▼ STRONG BEAR" :
      moderateBearTrend ? "▼ BEAR" :
      trendScore >= 1 ? "▲ MILD BULL" :
      trendScore <= -1 ? "▼ MILD BEAR" : "— NEUTRAL"
    trendClr = strongBullTrend ? colBullBright :
      moderateBullTrend or trendScore >= 1 ? colBullPrimary :
      strongBearTrend ? colBearBright :
      moderateBearTrend or trendScore <= -1 ? colBearPrimary :
      colNeutralLight
    table.cell(dash, 0, 1, "TREND",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 1, trendText,
      text_color=trendClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 2 — Trend Score
    scoreClr = trendScore >= 3 ? colBullBright :
      trendScore >= 2 ? colBullPrimary :
      trendScore >= 1 ? colBullDim :
      trendScore <= -3 ? colBearBright :
      trendScore <= -2 ? colBearPrimary :
      trendScore <= -1 ? colBearDim : colNeutralLight
    table.cell(dash, 0, 2, "TREND SCORE",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 2, str.tostring(trendScore) + " / 4",
      text_color=scoreClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 3 — RSI
    rsiClr = rsiVal > 70 ? colBearPrimary :
      rsiVal < 30 ? colBullPrimary :
      rsiVal > 60 ? colBearDim :
      rsiVal < 40 ? colBullDim : colNeutralLight
    table.cell(dash, 0, 3, "RSI (" + str.tostring(rsiLen) + ")",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 3, str.tostring(rsiVal, "#.#"),
      text_color=rsiClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 4 — Stochastic
    stochClr = stochK > stochOB ? colBearPrimary :
      stochK < stochOS ? colBullPrimary : colNeutralLight
    table.cell(dash, 0, 4, "STOCH K",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 4, str.tostring(stochK, "#.#"),
      text_color=stochClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 5 — MACD
    macdText = macdBullAlign ? "▲ BULL MOM" :
      macdBullish ? "▲ BULL" :
      macdBearAlign ? "▼ BEAR MOM" :
      macdBearish ? "▼ BEAR" : "— FLAT"
    macdClr = macdBullAlign ? colBullBright :
      macdBullish ? colBullPrimary :
      macdBearAlign ? colBearBright :
      macdBearish ? colBearPrimary : colNeutralLight
    table.cell(dash, 0, 5, "MACD",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 5, macdText,
      text_color=macdClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 6 — Volume
    volText = volRatio > 2.0 ? "SPIKE" :
      volRatio > 1.3 ? "HIGH" :
      volRatio > 0.7 ? "NORMAL" : "DRY"
    volClr = volRatio > 2.0 ? colBullBright :
      volRatio > 1.3 ? colBullPrimary :
      volRatio > 0.7 ? colNeutralLight : colNeutral
    table.cell(dash, 0, 6, "VOLUME",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 6, volText + "  ×" + str.tostring(volRatio, "#.#"),
      text_color=volClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 7 — ATR
    table.cell(dash, 0, 7, "ATR",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 7,
      str.tostring(atrVal, format.mintick) +
      "  (" + str.tostring(atrPct, "#.##") + "%)",
      text_color=colNeutralLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 8 — Session
    sessClr = sessionQuality >= 80 ? colBullPrimary :
      sessionQuality >= 50 ? colBullDim : colNeutral
    table.cell(dash, 0, 8, "SESSION",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 8, sessionName,
      text_color=sessClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 9 — HTF Bias
    htfText = htfBullish ? "▲ BULLISH" :
      htfBearish ? "▼ BEARISH" : "— NEUTRAL"
    htfClr = htfBullish ? colBullPrimary :
      htfBearish ? colBearPrimary : colNeutralLight
    table.cell(dash, 0, 9, "HTF BIAS",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 9, htfText,
      text_color=htfClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 10 — Active Trade
    tradeText = activeDir == 1 ? "▲ LONG" :
      activeDir == -1 ? "▼ SHORT" : "— NONE"
    tradeClr = activeDir == 1 ? colBullPrimary :
      activeDir == -1 ? colBearPrimary : colNeutral
    table.cell(dash, 0, 10, "ACTIVE TRADE",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 10, tradeText,
      text_color=tradeClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 11 — TP Progress
    tpText = not na(activeEntry) and activeDir != 0 ?
      (tp3Hit ? "TP3 ✓✓✓" :
      tp2Hit ? "TP2 ✓✓" :
      tp1Hit ? "TP1 ✓" : "RUNNING") :
      slHit ? "SL HIT" : "—"
    tpClr = tp3Hit ? colBullBright :
      tp2Hit ? colBullPrimary :
      tp1Hit ? colBullDim :
      slHit ? colBearPrimary : colNeutralLight
    table.cell(dash, 0, 11, "TP STATUS",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 11, tpText,
      text_color=tpClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 12 — Bull Score
    bScoreClr = bullScore >= 65 ? colBullBright :
      bullScore >= 45 ? colBullPrimary :
      bullScore >= 30 ? colBullDim : colNeutral
    table.cell(dash, 0, 12, "BULL SCORE",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 12, str.tostring(bullScore, "#") + " / 100",
      text_color=bScoreClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

    // Row 13 — Bear Score
    sScoreClr = bearScore >= 65 ? colBearBright :
      bearScore >= 45 ? colBearPrimary :
      bearScore >= 30 ? colBearDim : colNeutral
    table.cell(dash, 0, 13, "BEAR SCORE",
      text_color=colTextLight, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 13, str.tostring(bearScore, "#") + " / 100",
      text_color=sScoreClr, text_size=dashTextSize,
      bgcolor=color.new(colDashBg, 0))

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ALERTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(bullAAA,
  title="AAA Bull Sniper Entry",
  message="[AlphaX Sniper] AAA BULL entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullAA,
  title="AA Bull Sniper Entry",
  message="[AlphaX Sniper] AA BULL entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullA,
  title="A Bull Sniper Entry",
  message="[AlphaX Sniper] A BULL entry — {{ticker}} {{interval}} @ {{close}}")

alertcondition(bearAAA,
  title="AAA Bear Sniper Entry",
  message="[AlphaX Sniper] AAA BEAR entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearAA,
  title="AA Bear Sniper Entry",
  message="[AlphaX Sniper] AA BEAR entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearA,
  title="A Bear Sniper Entry",
  message="[AlphaX Sniper] A BEAR entry — {{ticker}} {{interval}} @ {{close}}")

alertcondition(bullSignal,
  title="Any Bull Sniper Entry",
  message="[AlphaX Sniper] BULL sniper entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearSignal,
  title="Any Bear Sniper Entry",
  message="[AlphaX Sniper] BEAR sniper entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullSignal or bearSignal,
  title="Any Sniper Entry",
  message="[AlphaX Sniper] Sniper entry signal — {{ticker}} {{interval}} @ {{close}}")

alertcondition(tp1Hit and not tp1Hit[1],
  title="TP1 Hit",
  message="[AlphaX Sniper] TP1 reached — {{ticker}} {{interval}} @ {{close}}")
alertcondition(tp2Hit and not tp2Hit[1],
  title="TP2 Hit",
  message="[AlphaX Sniper] TP2 reached — {{ticker}} {{interval}} @ {{close}}")
alertcondition(tp3Hit and not tp3Hit[1],
  title="TP3 Hit",
  message="[AlphaX Sniper] TP3 reached — {{ticker}} {{interval}} @ {{close}}")
alertcondition(slHit and not slHit[1],
  title="Stop Loss Hit",
  message="[AlphaX Sniper] STOP LOSS hit — {{ticker}} {{interval}} @ {{close}}")

alertcondition(strongBullTrend and not strongBullTrend[1],
  title="Strong Bull Trend Started",
  message="[AlphaX Sniper] Strong BULL trend confirmed — {{ticker}} {{interval}}")
alertcondition(strongBearTrend and not strongBearTrend[1],
  title="Strong Bear Trend Started",
  message="[AlphaX Sniper] Strong BEAR trend confirmed — {{ticker}} {{interval}}")
````
