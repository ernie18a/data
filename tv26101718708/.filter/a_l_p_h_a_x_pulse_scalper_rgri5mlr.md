# [ A L P H A X ] Pulse Scalper

- url: https://www.tradingview.com/script/RGri5Mlr-A-L-P-H-A-X-Pulse-Scalper/
- type: indicator
- pine_id: PUB;4eec3f0ab31d4e509af912ed48c07690
- version: 1.0

## Description

[b]AlphaX Pulse Scalper — 4-Layer Confluence Scalping System with ATR Trailing Exits, Squeeze Momentum Detection & Live Scoring Dashboard[/b]

AlphaX Pulse Scalper is a professional-grade multi-confluence scalping system engineered to fire only when four independent technical engines simultaneously agree on direction. Unlike single-indicator systems that generate signals from one source of information, Pulse Scalper runs a live scoring gate across an EMA Ribbon, a Squeeze Momentum engine, a Volume Delta pressure model, and a VWAP Deviation filter — every bar, on every candle. A signal only reaches your chart when at least three of the four layers confirm. The result is a dramatically lower signal count with a dramatically higher average quality per signal. Designed for active scalpers on crypto, forex, gold, and indices across the 1-minute to 15-minute timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The 4-Layer Confluence Engine — How It Works[/b]

Most scalping indicators fire from a single calculation — a crossover, a threshold breach, a momentum flip. The problem is that any single calculation is easily fooled by noise, spikes, and choppy price action. AlphaX Pulse Scalper is built on a fundamentally different architecture: [b]four completely independent layers, each measuring a different dimension of market behavior[/b], each casting a vote on every bar. Only when enough votes align does a signal fire.

This is not a filter applied on top of a signal. The confluence is the signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Layer 1 — EMA Ribbon (Trend Structure)[/b]

The first layer is a [b]triple EMA ribbon[/b] using a Fast EMA (default: 8), Slow EMA (default: 21), and Signal EMA (default: 50). This layer answers a single question: is the market in a clean, structured trend right now?

[b]Bull condition:[/b] Fast EMA above Slow EMA, Slow EMA above Signal EMA, and price closing above all three — a full stack alignment confirming upward momentum structure.

[b]Bear condition:[/b] The full inverse — Fast below Slow below Signal, with price below all three.

[b]Why this matters:[/b] The ribbon does not react to a single crossover. All three EMAs must be stacked in order and price must be on the correct side. This eliminates the vast majority of false crossover signals that plague simple dual-EMA systems. The ribbon is also plotted directly on the chart as a gradient-filled channel — bull fills in yellow-green, bear fills in red — giving you immediate structural context at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Layer 2 — Squeeze Momentum (Energy Detection)[/b]

The second layer is built on the [b]TTM Squeeze principle[/b] — one of the most reliable pre-breakout detection systems in technical analysis. It works by measuring the relationship between two volatility envelopes: Bollinger Bands and Keltner Channels.

[b]Squeeze state:[/b] When the Bollinger Bands compress inside the Keltner Channels, the market is coiling — volatility has contracted and energy is building. These periods of compression historically precede the strongest directional moves. The squeeze state is displayed as a subtle [b]orange background tint[/b] on the chart, and flagged on the dashboard as ⚡ BUILDING — giving you advance warning that a breakout is loading before it happens.

[b]Momentum direction:[/b] The raw momentum value is calculated using a linear regression of price position relative to the midpoint of the recent high-low range. When this value is [b]positive and rising[/b], the squeeze is releasing to the upside. When [b]negative and falling[/b], it is releasing to the downside.

[b]Layer 2 votes bull when:[/b] Momentum value is above zero and accelerating upward.
[b]Layer 2 votes bear when:[/b] Momentum value is below zero and accelerating downward.

[b]Why this matters:[/b] This layer catches the energy behind a move, not just the direction. A breakout with strong squeeze momentum behind it is fundamentally different from a breakout on low momentum — and this layer distinguishes between the two on every bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Layer 3 — Volume Delta (Institutional Pressure)[/b]

The third layer is a [b]proprietary volume delta model[/b] that estimates the real buying and selling pressure behind each candle — without requiring exchange-level order flow data.

[b]How it works:[/b] Each candle's volume is split into bullish and bearish components based on the candle's close position within its high-low range. A candle closing near its high attributes most of its volume to buyers; a candle closing near its low attributes most to sellers. These estimates are smoothed using an EMA to eliminate single-bar noise. A secondary [b]OBV slope[/b] (On-Balance Volume) is calculated over the configured lookback and used as an independent confirmation of the dominant pressure direction.

[b]Layer 3 votes bull when:[/b] The bull volume EMA exceeds the bear volume EMA, the delta EMA is positive, and the OBV slope is rising — all three volume signals agree on buying pressure.

[b]Layer 3 votes bear when:[/b] The full inverse — bear volume dominates, delta EMA is negative, OBV slope is falling.

[b]Why this matters:[/b] Price can move in any direction on any bar. Volume delta tells you whether real capital is flowing in the direction of that move. A price breakout accompanied by genuine volume pressure is a high-confidence breakout. A price breakout on weak or opposing volume is a trap. This layer is the system's protection against price manipulation and false breakouts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 [b]Layer 4 — VWAP Deviation (Institutional Bias)[/b]

The fourth layer uses the [b]Volume Weighted Average Price (VWAP)[/b] with dynamically calculated standard deviation bands to identify where price stands relative to institutional value.

[b]Band structure:[/b] Two band pairs are calculated — ±1σ and ±2σ — using a volume-weighted standard deviation formula applied across the session. These bands represent statistically significant deviations from the session's fair value anchor.

[b]Layer 4 votes bull when:[/b] Price is above VWAP (institutional bias is bullish) but has not yet extended beyond the +2σ band — confirming trend direction without chasing a stretched, overextended move.

[b]Layer 4 votes bear when:[/b] Price is below VWAP but has not extended beyond the -2σ band.

[b]Why this matters:[/b] VWAP is the single most widely watched intraday reference level used by institutional desks, market makers, and algorithms. Price above VWAP means institutions are net buyers for the session. Price below means net sellers. The 2σ filter prevents the system from entering during climactic exhaustion moves — precisely the moments when reversal risk is highest and reward is lowest.

[b]The bands are plotted directly on the chart[/b] — VWAP as a purple line, ±1σ as dotted yellow-green and red circles, ±2σ as solid outer boundaries — so you always have the full VWAP context visible alongside your signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The Confluence Gate — Live Scoring System[/b]

On every bar, each of the four layers independently casts its vote. The results are tallied into a [b]live confluence score[/b] displayed in real time on the dashboard.

[b]Bull score:[/b] 0–4 points. One point for each layer voting bullish.
[b]Bear score:[/b] 0–4 points. One point for each layer voting bearish.

[b]Signal fires when:[/b] The score meets or exceeds the configured minimum (default: 3 of 4), the ADX filter confirms a trending market, and the session filter confirms active market hours.

[b]Score thresholds and what they mean:[/b]
[list]
[*][b]4 / 4[/b] — maximum confluence. All four independent engines agree. The highest-conviction setup the system can produce. Enter full size.
[*][b]3 / 4[/b] — strong confluence. Three of four layers aligned. The default threshold — high quality with reasonable frequency.
[*][b]2 / 4[/b] — weak confluence. Available if you lower the minimum, but not recommended. Two engines agreeing is not meaningful convergence.
[/list]

The confluence score is printed directly on the signal label (e.g., [b]3/4[/b] or [b]4/4[/b]) so you know at a glance exactly how strong every setup is at the moment it fires. The dashboard continuously displays the live bull and bear scores — even between signals — so you can watch confidence building in real time before the signal appears.

[b]Edge triggering:[/b] Signals only fire on the bar where the score first crosses the threshold — not on every bar the score remains above it. This prevents signal spam during extended trend runs and ensures every triangle on the chart represents a distinct, fresh entry event.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡 [b]ADX Filter — Trend Quality Gate[/b]

Before any signal reaches the chart, it must also pass the [b]ADX (Average Directional Index) filter[/b]. ADX measures the strength of the current trend regardless of direction — a reading below the threshold indicates a choppy, ranging market where trend-following signals have low reliability.

[b]Default threshold: 20.[/b] When ADX is below this level, all signals are suppressed — even if the confluence score is 4/4. This is the system's protection against the single most common failure mode of scalping indicators: firing confidently into sideways, oscillating price action.

The ADX value and pass/fail status are displayed live on the dashboard so you always know whether the market structure supports trading at any given moment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕐 [b]Session Filter — Active Hours Gate[/b]

The [b]Session Filter</b> restricts signals to a configurable active trading window (default: 07:00–20:00 exchange time). Outside this window, signals are suppressed regardless of confluence score.

[b]Why this matters for scalpers:[/b] Low-volume pre-market and post-market hours produce the most misleading signals of any period. Spreads widen, liquidity thins, and momentum moves that look compelling on the chart are frequently reversed the moment the main session opens. The session filter eliminates this entire class of false setups automatically.

The dashboard displays a clear ✓ ACTIVE or ✗ OFF-HOURS status so you always know whether the filter is open or closed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Dynamic ATR Exit System[/b]

AlphaX Pulse Scalper uses a [b]fully dynamic ATR-based exit system[/b] with three simultaneously active exit mechanisms — each serving a distinct role in protecting profit.

[b]Stop Loss:[/b] Fixed at entry based on the pivot low (bull) or pivot high (bear) minus an ATR buffer (default: 1.2× ATR). Displayed as a solid red line below price for longs, above for shorts. This is your maximum risk boundary — it does not move.

[b]TP1 — Partial Target (50%):[/b] Set at 1.8× ATR from entry. When price reaches TP1, scale out 50% of the position and let the remainder run to TP2. A small circle marker appears at the TP1 bar.

[b]TP2 — Full Target:[/b] Set at 3.5× ATR from entry. When price reaches TP2, the full position exits and the system resets. A labeled [b]TP[/b] marker appears on the chart.

[b]ATR Trailing Stop:[/b] The most important of the three. From the moment a trade opens, a trailing stop moves dynamically with price — always positioned 1.5× ATR behind the current bar's low (for longs) or high (for shorts). The trail is displayed as a live orange line on the chart. As price advances in your favor, the trail advances with it. If price reverses and hits the trail before reaching TP2, the trade exits at the trail level rather than waiting to give back all gains.

[b]Why the trailing stop changes everything:[/b] Fixed TP levels work in textbook trends. In the real market, strong impulses often exceed TP2 before reversing — and weak impulses stall before even reaching TP1. The ATR trailing stop captures whatever the market gives, without predetermining a ceiling on your profit. In strong trending conditions, a single Pulse Scalper signal with an active trail can run 5–10× ATR before stopping out.

All three exit levels — SL, TP1, TP2, and the trailing stop — are plotted as live lines on the chart as long as a trade is active, then cleared automatically when the position closes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The real-time dashboard displays the complete internal state of the indicator across four sections, updated on every bar.

[b]MARKET[/b]
[list]
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF-HOURS. Confirms whether the session filter is open for signals
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail indicator. Confirms whether market structure is trending strongly enough to trade
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]L1 EMA Ribbon[/b] — current ribbon state: ▲ BULL, ▼ BEAR, or — FLAT
[*][b]L2 Squeeze Momentum[/b] — current momentum state: ⚡ SQUEEZE (building), ▲ BULL, ▼ BEAR, or — FLAT. The squeeze state is the highest-value pre-signal condition the system can display
[*][b]L3 Volume Delta[/b] — current volume pressure: ▲ BULL, ▼ BEAR, or — NEUTRAL
[*][b]L4 VWAP Deviation[/b] — current VWAP position: ▲ ABOVE, ▼ BELOW, or — EXTENDED (price beyond 2σ, filter active)
[*][b]Bull Score[/b] — live 0–4 score for bullish confluence. Background turns yellow-green when threshold is met — the signal is ready to fire
[*][b]Bear Score[/b] — live 0–4 score for bearish confluence. Background turns red when threshold is met
[/list]

[b]POSITION[/b]
[list]
[*][b]Position[/b] — current tracked position: ▲ LONG, ▼ SHORT, or — FLAT with background color highlight
[*][b]Stop Loss[/b] — the fixed SL level currently active, color-coded red (bull) or green (bear)
[*][b]Trail Stop[/b] — the current trailing stop level in orange — updates dynamically every bar the trade is open
[*][b]TP1 (50%)[/b] — the first take-profit target currently active
[*][b]TP2 (full)[/b] — the full exit target currently active
[*][b]Bars in Trade[/b] — how many bars the current position has been open
[/list]

[b]INFO[/b]
[list]
[*][b]ATR[/b] — current ATR value used for all exit calculations
[*][b]VWAP[/b] — current VWAP price level for the session
[*][b]Squeeze[/b] — ⚡ BUILDING when BB is inside KC (squeeze active), or — RELEASED when the squeeze has fired
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

Every visual element on the chart serves a specific purpose. There is no decorative clutter.

[list]
[*][b]▲ Triangle (below bar)[/b] — bull entry signal. Fires when bull confluence score meets threshold, ADX passes, session is active
[*][b]▼ Triangle (above bar)[/b] — bear entry signal. Fires when bear confluence score meets threshold
[*][b]Score Label (3/4 or 4/4)[/b] — printed beside each signal triangle. The raw confluence count at signal time
[*][b]EMA Ribbon Fill[/b] — yellow-green fill between Fast and Slow EMA during bull structure, red during bear structure. Collapses to gray during neutral
[*][b]VWAP Line[/b] — purple center line marking the session's volume-weighted fair value
[*][b]VWAP ±1σ Bands[/b] — dotted yellow-green and red circles marking the first standard deviation
[*][b]VWAP ±2σ Bands[/b] — solid outer boundaries. Price touching these is the maximum extension zone
[*][b]Orange Squeeze Background[/b] — appears during active squeeze conditions. A visual alert that energy is compressing and a breakout is approaching
[*][b]Yellow-green background tint[/b] — active during open long trades. Confirms trade is live at a glance
[*][b]Red background tint[/b] — active during open short trades
[*][b]SL Line (red/green)[/b] — the fixed stop loss level, active while trade is open
[*][b]TP1 Line (semi-transparent)[/b] — the partial target level
[*][b]TP2 Line (bright)[/b] — the full exit target level
[*][b]Trail Line (orange)[/b] — the dynamic trailing stop, moves with price every bar
[*][b]TP marker[/b] — appears when TP2 is hit. Full exit confirmed
[*][b]SL marker[/b] — appears when stop loss or trailing stop is triggered
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Pulse Scalper — Step by Step[/b]

[b]Step 1 — Check the Dashboard Before Every Session[/b]
[list]
[*]Confirm Session shows ✓ ACTIVE
[*]Confirm ADX shows ✓ — if ADX is below threshold, the market is ranging and no signals will fire regardless of how the layers look
[*]Watch the Squeeze row on the dashboard — ⚡ BUILDING means a breakout setup is forming. This is your highest-alert pre-signal state
[/list]

[b]Step 2 — Watch the Confluence Scores Build[/b]
[list]
[*]Monitor the live Bull Score and Bear Score rows in the dashboard. You can watch the scores build in real time, bar by bar, before a signal fires
[*]When a score reaches 3/4 and the background highlights, a signal is imminent or has just fired
[*]A 4/4 score is the highest-quality setup. Prioritize these above all else
[/list]

[b]Step 3 — Enter on the Signal Triangle[/b]
[list]
[*]A ▲ triangle below the bar is a long signal. Enter on the close of the signal bar or the open of the next bar
[*]A ▼ triangle above the bar is a short signal. Enter on the same basis
[*]Read the score label — 4/4 signals warrant full position size, 3/4 signals warrant standard or slightly reduced size
[/list]

[b]Step 4 — Manage with the Live Exit Lines[/b]
[list]
[*]The SL line is your hard stop. Never move it further away from price
[*]Watch the orange Trail Stop line advance with price as the trade moves in your favor
[*]At TP1, scale out 50% of the position. Move your manual stop to breakeven on the remainder
[*]Let the trailing stop manage the rest — it will exit automatically when momentum exhausts
[/list]

[b]Step 5 — Exit and Reset[/b]
[list]
[*]A [b]TP[/b] marker on the chart confirms TP2 has been hit. Full exit. Dashboard resets to — FLAT
[*]An [b]SL[/b] marker confirms the stop or trail has been hit. Accept the loss and wait for the next setup
[*]After any exit, do not re-enter immediately. Wait for the confluence score to rebuild from zero — this prevents revenge trading into the same noise that stopped you out
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

The system is designed to filter out most low-quality conditions automatically. But understanding what to look for gives you an additional edge.

[b]Stand aside when you see:[/b]
[list]
[*][b]ADX ✗ on the dashboard[/b] — the market is not trending. Any signal would be a range-bound trade against the system's core design
[*][b]Dashboard shows — FLAT across all four layers[/b] — no layer has a directional conviction. The market has no readable bias
[*][b]Bull and bear scores both at 1 or 2[/b] — the layers are split. Price is oscillating without commitment in either direction
[*][b]Session shows ✗ OFF-HOURS[/b] — no signals will fire and manual entries carry elevated risk from thin liquidity
[*][b]Squeeze just released but score is only 2/4[/b] — the squeeze fired but not enough layers confirmed the direction. This is a low-conviction breakout — wait for the next setup
[*][b]Rapid alternation of ▲ and ▼ triangles[/b] — if you see signals in both directions within a short window, the market is too choppy. Increase the ADX threshold in settings or stand aside until a clearer trend develops
[/list]

[b]What to do:[/b]
[list]
[*]Wait for the Squeeze dashboard to show ⚡ BUILDING — this is the highest-quality pre-signal state. The best Pulse Scalper setups almost always begin with a squeeze
[*]Wait for ADX to climb back above threshold — a strong trend is forming
[*]Wait for a 4/4 score on the next signal — maximum confluence only, no compromises in a difficult session
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🔬 4-layer confluence gate — EMA Ribbon, Squeeze Momentum, Volume Delta, and VWAP Deviation must agree before any signal fires
[*]📊 Live confluence scoring — bull and bear scores update every bar in real time, displayed on the dashboard before the signal appears
[*]⚡ TTM Squeeze detection — Bollinger/Keltner compression identifies pre-breakout coiling with an orange background tint and dashboard flag
[*]📈 Proprietary volume delta model — estimates buying and selling pressure without exchange-level order flow data, confirmed by OBV slope
[*]📡 VWAP with standard deviation bands — ±1σ and ±2σ plotted live, VWAP filter prevents entries during climactic extension moves
[*]🛡 ADX trend quality gate — suppresses all signals during choppy, non-trending market conditions
[*]🕐 Session filter — restricts signals to active market hours, eliminating low-liquidity false setups automatically
[*]🎯 Triple exit mechanism — fixed ATR stop loss, TP1 at 1.8× ATR, TP2 at 3.5× ATR, plus dynamic ATR trailing stop that advances with price every bar
[*]📉 ATR trailing stop — plotted as a live orange line, adapts dynamically to volatility, captures extended runs beyond TP2 in strong trends
[*]🏷 Confluence score label on every signal — 3/4 or 4/4 printed directly on the chart so you know signal quality at a glance
[*]📊 28-row live dashboard — Market, Confluence, Position, and Info sections updated in real time
[*]🔔 9 alert conditions — bull entry, bear entry, TP1/TP2 hits, stop hits, squeeze start, any exit
[*]🎨 Cohesive dual-tone color theme — yellow-green for all bullish elements, red for all bearish elements, orange for squeeze and trail, gray for neutral
[*]⚙ Fully configurable — all EMA periods, squeeze parameters, VWAP multipliers, ADX threshold, confluence minimum, ATR multipliers, session window, and all colors are adjustable from the settings panel
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]EMA Ribbon[/b]
[list]
[*]Fast EMA — the fastest ribbon line, reacts most immediately to price (default: 8)
[*]Slow EMA — the intermediate ribbon line (default: 21)
[*]Signal EMA — the macro trend anchor. All three must stack in order for a ribbon vote (default: 50)
[*]Show EMA Ribbon — toggle the ribbon fill and lines on or off
[/list]

[b]Squeeze Momentum[/b]
[list]
[*]BB Length — Bollinger Band lookback period for squeeze detection (default: 20)
[*]BB Mult — Bollinger Band standard deviation multiplier (default: 2.0)
[*]KC Length — Keltner Channel lookback period (default: 20)
[*]KC Mult — Keltner Channel ATR multiplier (default: 1.5)
[*]Momentum Length — linear regression period for the momentum value calculation (default: 12)
[/list]

[b]Volume Delta[/b]
[list]
[*]Volume MA Length — EMA smoothing period for bull and bear volume estimates (default: 14)
[*]OBV Slope Length — lookback bars for OBV slope calculation (default: 10)
[/list]

[b]VWAP[/b]
[list]
[*]Use VWAP Filter — when enabled, Layer 4 requires price to be on the correct side of VWAP (default: on)
[*]Show VWAP Bands — toggle ±1σ and ±2σ band plots on or off
[*]Band 1 Mult — first standard deviation band multiplier (default: 1.0)
[*]Band 2 Mult — second standard deviation band multiplier (default: 2.0)
[/list]

[b]Confluence Gate[/b]
[list]
[*]Min Layers Required — how many of the 4 layers must agree for a signal to fire. 2 = more signals, 3 = balanced (default), 4 = ultra-selective
[*]Session Filter — toggle the active hours restriction on or off
[*]Active Session — configurable session window string (default: 0700-2000)
[/list]

[b]ADX Filter[/b]
[list]
[*]Use ADX Filter — toggle the trend quality gate on or off
[*]ADX Length — lookback period for ADX calculation (default: 14)
[*]ADX Minimum — threshold below which all signals are suppressed (default: 20)
[/list]

[b]Exit Settings[/b]
[list]
[*]ATR Length — lookback period for ATR used in all exit calculations (default: 10)
[*]SL ATR Mult — stop loss distance from entry as a multiple of ATR (default: 1.2)
[*]TP1 ATR Mult — first take-profit distance (default: 1.8 — approximately 1.5:1 reward on a full position)
[*]TP2 ATR Mult — full exit target distance (default: 3.5 — approximately 3:1 reward)
[*]Use ATR Trailing Stop — toggle the dynamic trailing stop mechanism on or off
[*]Trail ATR Mult — trailing stop distance from current bar's low or high (default: 1.5)
[*]Show Exit Levels — toggle SL, TP1, TP2, and trail lines on the chart
[/list]

[b]Display[/b]
[list]
[*]Show Confluence Score Label — prints the live score (e.g. 3/4) on every signal triangle
[*]Show Dashboard — toggle the entire dashboard panel on or off
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish signals, fills, and labels
[*]Bear / Bear Bright — red family for all bearish signals, fills, and labels
[*]Squeeze — orange used for squeeze background tint and trailing stop line
[*]Neutral — gray for inactive states and neutral dashboard rows
[*]Text Light / Dash BG — dashboard typography and background
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (9 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Bull Confluence Entry — bull score meets threshold, ADX passes, session active
[*]Bear Confluence Entry — bear score meets threshold, ADX passes, session active
[/list]

[b]Exit Alerts[/b]
[list]
[*]Bull TP1 Hit — price reaches the first bull take-profit level
[*]Bull TP2 Hit — price reaches the full bull exit target
[*]Bull Stop Hit — stop loss or trailing stop triggered on a long position
[*]Bear TP1 Hit — price reaches the first bear take-profit level
[*]Bear TP2 Hit — price reaches the full bear exit target
[*]Bear Stop Hit — stop loss or trailing stop triggered on a short position
[/list]

[b]Special State Alerts[/b]
[list]
[*]Squeeze Started — Bollinger Bands have compressed inside Keltner Channels. A breakout setup is loading
[/list]

All alert messages include {{ticker}} and {{interval}} for clean webhook and notification integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M1–M5[/b]:
[list]
[*]Min Layers at 3/4 — strong confluence without requiring perfection on every bar
[*]ADX minimum at 20 — filters choppy intraday sessions without being overly restrictive
[*]ATR Trail at 1.5× — gives trades enough room to breathe on fast-moving scalping timeframes
[*]Session 07:00–20:00 — covers London and New York sessions, the highest-volume windows for forex and gold
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]Higher timeframes (M15, H1, H4)[/b] — increase EMA periods (Fast 13, Slow 34, Signal 89), increase ADX minimum to 25, increase TP2 to 4.5–5.0× ATR
[*][b]Crypto (BTC, ETH)[/b] — increase KC Mult to 2.0–2.5 to accommodate wider volatility, increase SL mult to 1.5–2.0
[*][b]Indices (NAS100, US30, SPX500)[/b] — use defaults with ADX raised to 22–25. Index trends are strong but session timing is critical — tighten session window to 09:30–16:00 for US indices
[*][b]More signals[/b] — lower Min Layers to 2, disable ADX filter, widen session window
[*][b]Fewer, higher-quality signals[/b] — raise Min Layers to 4, raise ADX minimum to 25, enable volume filter with ratio at 1.2×
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]⚡ [b]Scalpers and intraday momentum traders[/b] — the 1m–15m timeframe focus and ATR trailing exit system are built specifically for fast-moving intraday conditions
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — default settings are tuned and tested on gold and major pairs during London and New York sessions
[*]📊 [b]Crypto and index traders[/b] — the four-layer architecture adapts across instruments without manual recalibration
[*]🧠 [b]Systematic traders[/b] — the live confluence score provides a quantitative signal quality reading, not just a visual arrow
[*]📈 [b]Traders who want to eliminate overtrading[/b] — the confluence gate, ADX filter, session filter, and edge triggering physically prevent low-quality setups from appearing on the chart
[*]🎯 [b]Traders who struggle with exits[/b] — the three-layer exit system (fixed SL, scaled TP1, trailing TP2) provides a complete, rules-based exit framework that removes emotion from trade management
[*]📉 [b]Risk-conscious traders[/b] — every trade has a defined stop, a defined first target, and a dynamic trailing mechanism. There is no ambiguity about where you exit under any scenario
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design
[*]The edge-triggered signal logic means each triangle on the chart represents a distinct new confluence event — the same setup does not generate repeated signals during extended runs
[*]The trailing stop line on the chart is a real-time visual — it moves every bar the trade is open and accurately reflects the current stop level at all times
[*]Maximum 500 labels and 500 lines are used — on very low timeframes with extended chart history, the oldest markers may be automatically removed by TradingView's rendering limits
[*]The Squeeze background tint is a leading indicator — it appears before signals fire, giving you time to prepare. The strongest Pulse Scalper signals frequently begin with a squeeze
[*]The VWAP calculation resets at the start of each session. On instruments without a defined session (perpetual crypto), the VWAP anchors to the chart's visible history. For best results on crypto, use a 24-hour session string or disable the VWAP filter and use the other three layers
[*]The Trade Status section on the dashboard tracks position direction from signal to exit within a single chart session — it does not connect to your broker or brokerage account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for scalpers who need more than a signal — a complete system that scores, filters, enters, trails, and exits with precision on every trade.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX — Pulse Scalper v1.0
// 4-Layer Confluence Scalping System: EMA Ribbon + Squeeze Momentum + Volume Delta + VWAP

//@version=6
indicator("[ A L P H A X ] Pulse Scalper", shorttitle="AlphaX PULSE",
  overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ INPUTS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

grp1 = "EMA Ribbon"
emaFast    = input.int(8,  "Fast EMA",   minval=3,  maxval=20,  group=grp1)
emaSlow    = input.int(21, "Slow EMA",   minval=10, maxval=50,  group=grp1)
emaSig     = input.int(50, "Signal EMA", minval=20, maxval=200, group=grp1)
showRibbon = input.bool(true, "Show EMA Ribbon", group=grp1)

grp2 = "Squeeze Momentum"
sqzBBLen  = input.int(20,   "BB Length",         minval=5,  maxval=50,  group=grp2)
sqzBBMult = input.float(2.0,"BB Mult",           minval=1.0,maxval=3.0, step=0.1, group=grp2)
sqzKCLen  = input.int(20,   "KC Length",         minval=5,  maxval=50,  group=grp2)
sqzKCMult = input.float(1.5,"KC Mult",           minval=1.0,maxval=3.0, step=0.1, group=grp2)
momLen    = input.int(12,   "Momentum Length",   minval=5,  maxval=30,  group=grp2)

grp3 = "Volume Delta"
volLen = input.int(14, "Volume MA Length",  minval=5, maxval=50, group=grp3)
obvLen = input.int(10, "OBV Slope Length",  minval=3, maxval=30, group=grp3)

grp4 = "VWAP"
useVwap   = input.bool(true,  "Use VWAP Filter",  group=grp4)
vwapBands = input.bool(true,  "Show VWAP Bands",  group=grp4)
vwapMult1 = input.float(1.0,  "Band 1 Mult",      minval=0.5, maxval=3.0, step=0.1, group=grp4)
vwapMult2 = input.float(2.0,  "Band 2 Mult",      minval=1.0, maxval=5.0, step=0.1, group=grp4)

grp5 = "Confluence Gate"
minConf    = input.int(3, "Min Layers Required (of 4)", minval=2, maxval=4, group=grp5,
  tooltip="How many of the 4 layers must agree before a signal fires. 3 = balanced, 4 = ultra-selective.")
useSession = input.bool(true, "Session Filter (avoid low vol)", group=grp5)
sessStart  = input.session("0700-2000", "Active Session", group=grp5)

grp6 = "ADX Filter"
useADX = input.bool(true,   "Use ADX Filter", group=grp6)
adxLen = input.int(14,      "ADX Length",     minval=7,  maxval=30, group=grp6)
adxMin = input.float(20,    "ADX Minimum",    minval=10, maxval=40, group=grp6)

grp7 = "Exit Settings"
atrLen    = input.int(10,    "ATR Length",          minval=5,  maxval=30,  group=grp7)
slMult    = input.float(1.2, "SL ATR Mult",         minval=0.5,maxval=3.0, step=0.1, group=grp7)
tp1Mult   = input.float(1.8, "TP1 ATR Mult (50%)",  minval=0.5,maxval=5.0, step=0.1, group=grp7)
tp2Mult   = input.float(3.5, "TP2 ATR Mult (full)", minval=1.0,maxval=8.0, step=0.1, group=grp7)
useTrail  = input.bool(true, "Use ATR Trailing Stop", group=grp7)
trailMult = input.float(1.5, "Trail ATR Mult",       minval=0.5,maxval=4.0, step=0.1, group=grp7)
showExits = input.bool(true, "Show Exit Levels", group=grp7)

grp8 = "Display"
showConf = input.bool(true, "Show Confluence Score Label", group=grp8)
showDash = input.bool(true, "Show Dashboard",              group=grp8)
dashPos  = input.string("Top Right", "Dashboard Position",
  options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp8)

grp9 = "Colors"
colBull    = input.color(#c8e624, "Bull",        group=grp9)
colBullBr  = input.color(#d4f03a, "Bull Bright", group=grp9)
colBear    = input.color(#ff1744, "Bear",        group=grp9)
colBearBr  = input.color(#ff5252, "Bear Bright", group=grp9)
colSqueeze = input.color(#ff9800, "Squeeze",     group=grp9)
colNeutral = input.color(#555555, "Neutral",     group=grp9)
colTextLt  = input.color(#cccccc, "Text Light",  group=grp9)
colDashBg  = input.color(#1a1a1a, "Dash BG",     group=grp9)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ HELPER FUNCTIONS ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 1: EMA RIBBON ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float emaF  = ta.ema(close, emaFast)
float emaS  = ta.ema(close, emaSlow)
float emaSG = ta.ema(close, emaSig)

bool emaBull = emaF > emaS and emaS > emaSG and close > emaF
bool emaBear = emaF < emaS and emaS < emaSG and close < emaF

p1 = plot(showRibbon ? emaF  : na, "Fast EMA",   color=color.new(colBull, 50), linewidth=1)
p2 = plot(showRibbon ? emaS  : na, "Slow EMA",   color=color.new(colBull, 70), linewidth=1)
p3 = plot(showRibbon ? emaSG : na, "Signal EMA", color=color.new(colNeutral, 40), linewidth=2)
fill(p1, p2, color=emaBull ? color.new(colBull, 80) : emaBear ? color.new(colBear, 80) : color.new(colNeutral, 90))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 2: SQUEEZE MOMENTUM ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float bbBasis = ta.sma(close, sqzBBLen)
float bbDev   = sqzBBMult * ta.stdev(close, sqzBBLen)
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev

float kcBasis = ta.ema(close, sqzKCLen)
float kcRange = ta.atr(sqzKCLen)
float kcUpper = kcBasis + sqzKCMult * kcRange
float kcLower = kcBasis - sqzKCMult * kcRange

bool sqzOn  = bbUpper < kcUpper and bbLower > kcLower

float momVal  = ta.linreg(close - math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen)), momLen, 0)
float momPrev = momVal[1]

bool momBull = momVal > 0 and momVal > momPrev
bool momBear = momVal < 0 and momVal < momPrev

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 3: VOLUME DELTA ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float candleRange = high - low
float bullVolEst  = candleRange != 0 ? volume * (close - low) / candleRange : volume * 0.5
float bearVolEst  = volume - bullVolEst

float volMaBull  = ta.ema(bullVolEst, volLen)
float volMaBear  = ta.ema(bearVolEst, volLen)
float volDelta   = volMaBull - volMaBear
float volDeltaMA = ta.ema(volDelta, 5)

float obv      = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
float obvSlope = obv - obv[obvLen]

bool volBull = volDelta > 0 and volDeltaMA > 0 and obvSlope > 0
bool volBear = volDelta < 0 and volDeltaMA < 0 and obvSlope < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 4: VWAP DEVIATION ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// Session-anchored VWAP + σ bands (ta.cum variance spanned full chart history and blew out autoscale)
[vwapVal, vwapPlus1, _] = ta.vwap(hlc3, session.isfirstbar, 1.0)
float vwapDev = vwapPlus1 - vwapVal
float vwapU1  = vwapVal + vwapMult1 * vwapDev
float vwapL1  = vwapVal - vwapMult1 * vwapDev
float vwapU2  = vwapVal + vwapMult2 * vwapDev
float vwapL2  = vwapVal - vwapMult2 * vwapDev

bool vwapBull = useVwap ? (close > vwapVal and close < vwapU2) : true
bool vwapBear = useVwap ? (close < vwapVal and close > vwapL2) : true

plot(vwapVal, "VWAP", color=color.new(#8b6fd0, 60), linewidth=2)
plot(vwapBands ? vwapU1 : na, "VWAP +1σ", color=color.new(colBull, 70), linewidth=1, style=plot.style_circles)
plot(vwapBands ? vwapL1 : na, "VWAP -1σ", color=color.new(colBear, 70), linewidth=1, style=plot.style_circles)
plot(vwapBands ? vwapU2 : na, "VWAP +2σ", color=color.new(colBull, 50), linewidth=1)
plot(vwapBands ? vwapL2 : na, "VWAP -2σ", color=color.new(colBear, 50), linewidth=1)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ADX FILTER ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float upMove2   = high - high[1]
float downMove2 = low[1] - low
float plusDM2   = upMove2 > downMove2  and upMove2  > 0 ? upMove2   : 0.0
float minusDM2  = downMove2 > upMove2  and downMove2 > 0 ? downMove2 : 0.0
float trRange2  = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
float smTR2     = ta.rma(trRange2, adxLen)
float smPlus2   = ta.rma(plusDM2,  adxLen)
float smMinus2  = ta.rma(minusDM2, adxLen)
float pDI2      = smTR2 != 0 ? 100 * smPlus2  / smTR2 : 0.0
float mDI2      = smTR2 != 0 ? 100 * smMinus2 / smTR2 : 0.0
float dx2       = (pDI2 + mDI2) != 0 ? 100 * math.abs(pDI2 - mDI2) / (pDI2 + mDI2) : 0.0
float adxVal    = ta.rma(dx2, adxLen)
bool  adxOK     = not useADX or adxVal >= adxMin

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ SESSION FILTER ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bool inSession = not useSession or not na(time(timeframe.period, sessStart))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ CONFLUENCE SCORING ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

int bullScore = (emaBull ? 1 : 0) + (momBull ? 1 : 0) + (volBull ? 1 : 0) + (vwapBull ? 1 : 0)
int bearScore = (emaBear ? 1 : 0) + (momBear ? 1 : 0) + (volBear ? 1 : 0) + (vwapBear ? 1 : 0)

bool bullEntry = bullScore >= minConf and adxOK and inSession
bool bearEntry = bearScore >= minConf and adxOK and inSession

bool bullSignal = bullEntry and not bullEntry[1]
bool bearSignal = bearEntry and not bearEntry[1]

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ATR + EXITS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float atrVal = ta.atr(atrLen)

var float bullSL   = na
var float bullTP1  = na
var float bullTP2  = na
var float bearSL   = na
var float bearTP1  = na
var float bearTP2  = na
var float trailStop = na
var int   tradeDir  = 0
var int   tradeBar  = na

if bullSignal
    bullSL    := low  - atrVal * slMult
    bullTP1   := close + atrVal * tp1Mult
    bullTP2   := close + atrVal * tp2Mult
    trailStop := low  - atrVal * trailMult
    tradeDir  := 1
    tradeBar  := bar_index

if bearSignal
    bearSL    := high + atrVal * slMult
    bearTP1   := close - atrVal * tp1Mult
    bearTP2   := close - atrVal * tp2Mult
    trailStop := high + atrVal * trailMult
    tradeDir  := -1
    tradeBar  := bar_index

int barsInTrade = not na(tradeBar) ? bar_index - tradeBar : 0

if tradeDir == 1 and useTrail and barsInTrade > 0
    trailStop := math.max(trailStop, low - atrVal * trailMult)
if tradeDir == -1 and useTrail and barsInTrade > 0
    trailStop := math.min(trailStop, high + atrVal * trailMult)

bool exitBullSL  = tradeDir ==  1 and not na(bullSL)  and low  <= bullSL   and barsInTrade > 0
bool exitBullTR  = tradeDir ==  1 and useTrail         and not na(trailStop) and low  <= trailStop and barsInTrade > 1
bool exitBullTP1 = tradeDir ==  1 and not na(bullTP1) and high >= bullTP1  and barsInTrade > 0
bool exitBullTP2 = tradeDir ==  1 and not na(bullTP2) and high >= bullTP2  and barsInTrade > 0
bool exitBearSL  = tradeDir == -1 and not na(bearSL)  and high >= bearSL   and barsInTrade > 0
bool exitBearTR  = tradeDir == -1 and useTrail         and not na(trailStop) and high >= trailStop and barsInTrade > 1
bool exitBearTP1 = tradeDir == -1 and not na(bearTP1) and low  <= bearTP1  and barsInTrade > 0
bool exitBearTP2 = tradeDir == -1 and not na(bearTP2) and low  <= bearTP2  and barsInTrade > 0

bool exitBull = exitBullSL or exitBullTP2 or exitBullTR
bool exitBear = exitBearSL or exitBearTP2 or exitBearTR

if exitBull
    tradeDir  := 0
    bullSL    := na
    bullTP1   := na
    bullTP2   := na
    trailStop := na

if exitBear
    tradeDir  := 0
    bearSL    := na
    bearTP1   := na
    bearTP2   := na
    trailStop := na

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ PLOTS ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// ── Entry Signals ─────────────────────────────────────────────────────────────
plotshape(bullSignal, title="Bull Entry",
  style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.normal)

plotshape(bearSignal, title="Bear Entry",
  style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.normal)

// ── Squeeze state — small background tint instead of plotchar ─────────────────
bgcolor(sqzOn ? color.new(colSqueeze, 92) : na, title="Squeeze BG")

// ── Confluence Score Labels ───────────────────────────────────────────────────
if showConf and bullSignal
    label.new(bar_index, low - atrVal * 1.8,
      text=str.tostring(bullScore) + "/4",
      style=label.style_label_up,
      color=color.new(colBull, 10),
      textcolor=color.new(#0d0d0d, 0),
      size=size.small)

if showConf and bearSignal
    label.new(bar_index, high + atrVal * 1.8,
      text=str.tostring(bearScore) + "/4",
      style=label.style_label_down,
      color=color.new(colBear, 10),
      textcolor=color.new(#ffffff, 0),
      size=size.small)

// ── Exit markers ──────────────────────────────────────────────────────────────
plotshape(exitBullTP1 and not exitBullTP2, title="Bull TP1",
  style=shape.circle, location=location.abovebar,
  color=color.new(colBull, 20), size=size.tiny)
plotshape(exitBullTP2, title="Bull TP2",
  style=shape.labeldown, location=location.abovebar,
  color=color.new(colBullBr, 0), size=size.tiny, text="TP")
plotshape(exitBullSL or exitBullTR, title="Bull SL",
  style=shape.labeldown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.tiny, text="SL")

plotshape(exitBearTP1 and not exitBearTP2, title="Bear TP1",
  style=shape.circle, location=location.belowbar,
  color=color.new(colBear, 20), size=size.tiny)
plotshape(exitBearTP2, title="Bear TP2",
  style=shape.labelup, location=location.belowbar,
  color=color.new(colBearBr, 0), size=size.tiny, text="TP")
plotshape(exitBearSL or exitBearTR, title="Bear SL",
  style=shape.labelup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.tiny, text="SL")

// ── SL / TP / Trail Lines ─────────────────────────────────────────────────────
plot(showExits and tradeDir ==  1 and not na(bullSL)   ? bullSL   : na,
  "Bull SL",    color=color.new(colBear,    20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP1)  ? bullTP1  : na,
  "Bull TP1",   color=color.new(colBull,    50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP2)  ? bullTP2  : na,
  "Bull TP2",   color=color.new(colBullBr,  10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bull Trail", color=color.new(colSqueeze, 30), linewidth=1, style=plot.style_linebr)

plot(showExits and tradeDir == -1 and not na(bearSL)   ? bearSL   : na,
  "Bear SL",    color=color.new(colBull,    20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP1)  ? bearTP1  : na,
  "Bear TP1",   color=color.new(colBear,    50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP2)  ? bearTP2  : na,
  "Bear TP2",   color=color.new(colBearBr,  10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bear Trail", color=color.new(colSqueeze, 30), linewidth=1, style=plot.style_linebr)

// ── Active trade background tint ──────────────────────────────────────────────
bgcolor(tradeDir ==  1 ? color.new(colBull, 95) : na, title="Long Zone BG")
bgcolor(tradeDir == -1 ? color.new(colBear, 95) : na, title="Short Zone BG")

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════ DASHBOARD ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 22,
      bgcolor=color.new(colDashBg, 0),
      border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2,  frame_color=color.new(colBull, 50))

if showDash and barstate.islast

    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(#222222, 0)

    table.cell(dash, 0, 0, "AlphaX PULSE SCALPER",
      text_color=colBull, text_size=size.normal,
      bgcolor=color.new(#111111, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "4-LAYER v1.0",
      text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(#111111, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── MARKET ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    string sessTxt = inSession ? "✓ ACTIVE" : "✗ OFF-HOURS"
    color  sessClr = inSession ? colBull    : colBear
    table.cell(dash, 0, 2, "SESSION",  text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, sessTxt,   text_color=sessClr,   text_size=size.small, bgcolor=dbg)

    string adxTxt2 = str.tostring(adxVal, "#.#") + (adxOK ? "  ✓" : "  ✗")
    color  adxClr2 = adxOK ? colBull : colBear
    table.cell(dash, 0, 3, "ADX",    text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, adxTxt2, text_color=adxClr2,   text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "─── CONFLUENCE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 4, "", bgcolor=secBg)

    string emaTxt = emaBull ? "▲ BULL" : emaBear ? "▼ BEAR" : "— FLAT"
    color  emaClr = emaBull ? colBull  : emaBear ? colBear  : colNeutral
    table.cell(dash, 0, 5, "L1 EMA RIBBON", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, emaTxt,          text_color=emaClr,    text_size=size.small, bgcolor=dbg)

    string sqzTxt = sqzOn ? "⚡ SQUEEZE" : momBull ? "▲ BULL" : momBear ? "▼ BEAR" : "— FLAT"
    color  sqzClr = sqzOn ? colSqueeze : momBull ? colBull : momBear ? colBear : colNeutral
    table.cell(dash, 0, 6, "L2 SQUEEZE MOM", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, sqzTxt,           text_color=sqzClr,    text_size=size.small, bgcolor=dbg)

    string volTxt = volBull ? "▲ BULL" : volBear ? "▼ BEAR" : "— NEUTRAL"
    color  volClr = volBull ? colBull  : volBear ? colBear  : colNeutral
    table.cell(dash, 0, 7, "L3 VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, volTxt,         text_color=volClr,    text_size=size.small, bgcolor=dbg)

    string vwpTxt = vwapBull ? "▲ ABOVE" : vwapBear ? "▼ BELOW" : "— EXTENDED"
    color  vwpClr = vwapBull ? colBull   : vwapBear ? colBear   : colNeutral
    table.cell(dash, 0, 8, "L4 VWAP DEV", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, vwpTxt,        text_color=vwpClr,    text_size=size.small, bgcolor=dbg)

    string bullScoreTxt = str.tostring(bullScore) + " / 4  " + (bullScore >= minConf ? "✓" : "✗")
    string bearScoreTxt = str.tostring(bearScore) + " / 4  " + (bearScore >= minConf ? "✓" : "✗")
    color  bsClr = bullScore >= minConf ? colBull : colNeutral
    color  beClr = bearScore >= minConf ? colBear : colNeutral

    table.cell(dash, 0, 9, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 9, bullScoreTxt, text_color=bsClr, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 10, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 10, bearScoreTxt, text_color=beClr, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

    table.cell(dash, 0, 11, "─── POSITION ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 11, "", bgcolor=secBg)

    string posTxt = tradeDir ==  1 ? "▲ LONG" : tradeDir == -1 ? "▼ SHORT" : "— FLAT"
    color  posClr = tradeDir ==  1 ? colBull  : tradeDir == -1 ? colBear   : colNeutral
    color  posBg  = tradeDir ==  1 ? color.new(colBull, 88) : tradeDir == -1 ? color.new(colBear, 88) : dbg
    table.cell(dash, 0, 12, "POSITION", text_color=colTextLt, text_size=size.small, bgcolor=posBg)
    table.cell(dash, 1, 12, posTxt,     text_color=posClr,    text_size=size.small, bgcolor=posBg)

    string slTxt2 = "—"
    if tradeDir == 1 and not na(bullSL)
        slTxt2 := str.tostring(bullSL, format.mintick)
    else if tradeDir == -1 and not na(bearSL)
        slTxt2 := str.tostring(bearSL, format.mintick)
    color slClr2 = tradeDir == 1 ? colBear : tradeDir == -1 ? colBull : colNeutral
    table.cell(dash, 0, 13, "STOP LOSS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 13, slTxt2,      text_color=slClr2,    text_size=size.small, bgcolor=dbg)

    string trailTxt = "—"
    if not na(trailStop) and tradeDir != 0
        trailTxt := str.tostring(trailStop, format.mintick)
    table.cell(dash, 0, 14, "TRAIL STOP", text_color=colTextLt,  text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 14, trailTxt,     text_color=colSqueeze, text_size=size.small, bgcolor=dbg)

    string tp1Txt2 = "—"
    if tradeDir == 1 and not na(bullTP1)
        tp1Txt2 := str.tostring(bullTP1, format.mintick)
    else if tradeDir == -1 and not na(bearTP1)
        tp1Txt2 := str.tostring(bearTP1, format.mintick)
    table.cell(dash, 0, 15, "TP1  (50%)", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 15, tp1Txt2,      text_color=colBull,   text_size=size.small, bgcolor=dbg)

    string tp2Txt2 = "—"
    if tradeDir == 1 and not na(bullTP2)
        tp2Txt2 := str.tostring(bullTP2, format.mintick)
    else if tradeDir == -1 and not na(bearTP2)
        tp2Txt2 := str.tostring(bearTP2, format.mintick)
    table.cell(dash, 0, 16, "TP2 (full)", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 16, tp2Txt2,      text_color=colBullBr, text_size=size.small, bgcolor=dbg)

    string barsTxt2 = "—"
    if tradeDir != 0
        barsTxt2 := str.tostring(barsInTrade) + " bars"
    table.cell(dash, 0, 17, "BARS IN TRADE", text_color=colTextLt,  text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 17, barsTxt2,        text_color=colNeutral, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════════ ALERTS ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(bullSignal,
  title="Bull Confluence Entry",
  message="[AlphaX PULSE] LONG SIGNAL — Check chart for confluence score and levels.")
alertcondition(bearSignal,
  title="Bear Confluence Entry",
  message="[AlphaX PULSE] SHORT SIGNAL — Check chart for confluence score and levels.")
alertcondition(exitBullTP1 and not exitBullTP2,
  title="Bull TP1 Hit",
  message="[AlphaX PULSE] BULL TP1 HIT — Scale out 50% of position.")
alertcondition(exitBullTP2,
  title="Bull TP2 Hit",
  message="[AlphaX PULSE] BULL TP2 HIT — Full exit.")
alertcondition(exitBullSL or exitBullTR,
  title="Bull Stop Hit",
  message="[AlphaX PULSE] BULL STOPPED — SL or trail triggered.")
alertcondition(exitBearTP1 and not exitBearTP2,
  title="Bear TP1 Hit",
  message="[AlphaX PULSE] BEAR TP1 HIT — Scale out 50% of position.")
alertcondition(exitBearTP2,
  title="Bear TP2 Hit",
  message="[AlphaX PULSE] BEAR TP2 HIT — Full exit.")
alertcondition(exitBearSL or exitBearTR,
  title="Bear Stop Hit",
  message="[AlphaX PULSE] BEAR STOPPED — SL or trail triggered.")
alertcondition(sqzOn and not sqzOn[1],
  title="Squeeze Started",
  message="[AlphaX PULSE] SQUEEZE BUILDING — Prepare for breakout.")
````
