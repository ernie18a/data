# [ A L P H A X ] SURGE

- url: https://www.tradingview.com/script/9mjcGrdT-A-L-P-H-A-X-SURGE/
- type: indicator
- pine_id: PUB;232299374ad44e5e9c50df4868f6cae2
- version: 1.0

## Description

[b]AlphaX SURGE — Liquidity Sweep + Market Structure + Premium/Discount Confluence Engine: Smart Money Concepts with 6-Layer Institutional Entry System, HTF Bias Filter & Order Block Detection[/b]

AlphaX SURGE is a professional-grade smart money concepts system built around the three foundational mechanics that drive institutional price delivery: liquidity sweeps, market structure shifts, and premium/discount zone positioning. Where most SMC indicators simply draw labels on a chart, SURGE integrates these concepts into a live 6-layer confluence scoring engine that only fires when a genuine liquidity grab, a confirmed structure event, correct PD zone positioning, higher timeframe bias alignment, squeeze momentum, and volume delta pressure are all pointing in the same direction simultaneously. The result is a system that reads the market the way institutional traders do — not chasing breakouts, not entering on arbitrary crossovers, but waiting for the precise sequence of events that precedes the highest-probability directional moves. Designed for active traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏦 [b]The Smart Money Framework — How Institutions Move Price[/b]

To understand AlphaX SURGE, you first need to understand the three-phase institutional trade cycle that the system is designed to detect.

[b]Phase 1 — Liquidity Accumulation:[/b]
Institutions need massive order size. They cannot fill that size at a single price — they need a pool of counterparty orders. Retail stop losses clustered below swing lows (sell-side liquidity) and above swing highs (buy-side liquidity) are that pool. Before a major directional move, institutions deliberately push price into these liquidity pools to trigger stops and fill their positions against the retail orders being stopped out.

[b]Phase 2 — Structure Shift:[/b]
After the liquidity grab, the institution has filled its position. Now price reverses aggressively. This reversal breaks the prior market structure — creating either a [b]Change of Character (CHoCH)[/b] if it reverses the previous trend, or confirming a [b]Break of Structure (BOS)[/b] continuation if it aligns with the existing trend. The structure event is the confirmation that the liquidity sweep was genuine, not noise.

[b]Phase 3 — Delivery:[/b]
With positions filled and structure confirmed, the institution delivers price to its target. This delivery phase is what SURGE is designed to capture — entering at the moment the sweep and structure confirmation align with the broader institutional context.

AlphaX SURGE does not simply detect these phases independently. It requires them to occur in the correct sequence and within a qualifying multi-layer confluence environment before any signal fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💧 [b]Liquidity Sweep Detection[/b]

The sweep detection engine identifies the moment institutions grab liquidity from a significant swing level. Every swing high and swing low is tracked in real time using a configurable pivot length (default: 5 bars). These levels represent the two most important current liquidity pools — the sell-side liquidity (SSL) below the most recent swing low, and the buy-side liquidity (BSL) above the most recent swing high.

[b]Bull Liquidity Sweep (SSL Grab):[/b]
[list]
[*]The bar's low extends below the tracked swing low level by at least the minimum sweep wick threshold (default: 0.05× ATR)
[*]The bar closes back above the swing low level — confirming the wick was a grab, not a genuine breakdown
[*]The bar closes bullish (close above open) — confirming buying pressure on the reversal close
[/list]

[b]Bear Liquidity Sweep (BSL Grab):[/b]
[list]
[*]The bar's high extends above the tracked swing high level by at least the minimum wick threshold
[*]The bar closes back below the swing high level
[*]The bar closes bearish — confirming selling pressure on the reversal close
[/list]

[b]The minimum sweep wick filter[/b] is a critical quality gate. Without it, any bar that briefly touches a swing level and reverses would register as a sweep. The ATR-normalized wick requirement ensures the grab extended far enough below or above the level to genuinely trigger stop orders — not just grazed the level on low momentum.

[b]Sweep recency:[/b] To accommodate the reality that entry signals often develop one bar after the sweep rather than on the sweep bar itself, SURGE accepts sweeps from the current or immediately preceding bar. This one-bar lookback prevents missed entries on fast-moving setups where the structure confirmation fires on the bar immediately following the sweep candle.

[b]Visual output:[/b] Every confirmed sweep is marked with a diamond shape — yellow-green below the bar for bull sweeps, red above for bear sweeps — providing instant visual identification of every liquidity grab on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Market Structure Engine — BOS & CHoCH[/b]

The market structure engine runs a real-time tracking system for the current structural trend and identifies every significant structure event as it occurs.

[b]Structural trend tracking:[/b]
The engine continuously tracks the most recent confirmed swing high and swing low. When price closes above the most recent swing high, a bullish structure break is detected. When price closes below the most recent swing low, a bearish structure break is detected. The structural trend variable updates on every such event — shifting between bullish (1) and bearish (-1) states.

[b]Change of Character (CHoCH):[/b]
A CHoCH occurs when a structure break happens in the opposite direction of the current structural trend. A bullish CHoCH means price was in a bearish structural trend and has now broken above a swing high — the character of the market has changed. A bearish CHoCH is the inverse. CHoCH events are the highest-quality structure signals in the system — they represent a genuine reversal of the institutional order flow direction. Labeled on the chart in orange.

[b]Break of Structure (BOS):[/b]
A BOS occurs when a structure break aligns with the current structural trend — a continuation event. A bullish BOS in a bullish trend confirms the uptrend is intact. A bearish BOS in a bearish trend confirms the downtrend continues. Labeled on the chart in yellow-green (bull) or red (bear).

[b]Signal type control:[/b]
Two settings independently toggle which structure types can trigger signals:
[list]
[*][b]Allow CHoCH Reversal Setups[/b] — enables signals on trend-reversal structure events. These are typically the highest-reward setups but require the sweep and confluence conditions to be exceptionally strong
[*][b]Allow BOS Continuation Setups[/b] — enables signals on trend-continuation structure events. These are typically higher-frequency and occur within established directional flows
[/list]

Both can be enabled simultaneously, giving SURGE the ability to detect both reversal and continuation setups across all market conditions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 [b]Order Block Detection & Visualization[/b]

Every confirmed structure event automatically spawns an [b]Order Block[/b] — the institutional supply or demand zone that preceded the structure break. Order blocks represent the price range where the institutional position was built before the delivery move.

[b]How order blocks are spawned:[/b]
When a bullish CHoCH or bullish BOS is confirmed, SURGE looks back up to the configured lookback period (default: 12 bars) to find the most recent [b]bearish candle[/b] prior to the structure break — the last selling candle before the institutional buying move began. The high and low of that candle become the bull order block zone.

When a bearish CHoCH or bearish BOS is confirmed, SURGE looks back to find the most recent [b]bullish candle[/b] — the last buying candle before the institutional selling move began. That candle's range becomes the bear order block zone.

[b]Why this candle:[/b] The last opposing candle before a major directional move is where institutions were absorbing the final counterparty orders. It is the true origin of the move — and the zone where unfilled institutional orders are most likely to remain, making it the natural magnet for price on any retest.

[b]Order block visualization:[/b] Each order block is rendered as a semi-transparent box extending forward by the configured number of bars (default: 20). Bull order blocks are shaded yellow-green; bear order blocks in red. The most recent active order block of each direction is tracked by the confluence system.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚖ [b]Premium / Discount Zone Engine[/b]

The Premium/Discount framework is one of the most powerful filtering tools in institutional price action analysis. It answers a simple question: is price currently cheap or expensive relative to the recent dealing range?

[b]Dealing range calculation:[/b]
On every bar, SURGE calculates the highest high and lowest low over the configured range length (default: 50 bars). The midpoint of this range is the [b]Equilibrium level[/b] — the 50% point of the current dealing range, plotted as a purple dotted line on the chart.

[b]Discount zone:[/b] Price at or below equilibrium. From an institutional perspective, price is cheap — this is where smart money buys. Bull entries in discount align with the institutional buying thesis.

[b]Premium zone:[/b] Price at or above equilibrium. Price is expensive — this is where smart money sells. Bear entries in premium align with the institutional selling thesis.

[b]Why this filter dramatically improves accuracy:[/b] A bullish sweep and structure confirmation at premium prices is a low-quality setup — you are buying at the top of the range where institutions are looking to distribute, not accumulate. The same bullish setup in discount is a structurally superior entry — buying at the institutional accumulation zone where the reward-to-risk profile is fundamentally better. The PD zone filter enforces this discipline automatically, blocking counter-PD setups before they reach the confluence gate.

The PD filter can be toggled off for traders who prefer to trade all qualifying setups regardless of range position — useful on strongly trending markets where price consistently stays on one side of equilibrium.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 [b]HTF Bias Filter — Multi-Timeframe Alignment[/b]

The Higher Timeframe Bias filter is one of the most consequential filters in the entire system. A setup that occurs against the higher timeframe trend is a counter-trend trade — it may look compelling on the current timeframe but is fighting the dominant institutional flow.

[b]How it works:[/b]
SURGE pulls two EMAs from the configured higher timeframe (default: 60-minute) — a fast EMA (default: 21) and a slow EMA (default: 55). When the fast HTF EMA is above the slow HTF EMA, the higher timeframe trend is bullish. When below, it is bearish.

[b]Bull bias:[/b] Fast HTF EMA above slow HTF EMA — the higher timeframe institutional flow is upward. Bull setups on the current timeframe are with-trend trades.

[b]Bear bias:[/b] Fast HTF EMA below slow HTF EMA — the higher timeframe flow is downward. Bear setups are with-trend trades.

[b]The power of HTF alignment in SMC trading:[/b] A bullish sweep and CHoCH on M5 in the direction of a confirmed H1 uptrend is a fundamentally different trade from the same setup occurring against an H1 downtrend. The HTF filter ensures SURGE only fires setups where the current timeframe structure event is aligned with the broader institutional delivery direction — the single highest-quality filter available for SMC-based systems.

The HTF timeframe is fully configurable. For M1–M5 scalping, H1 is the default. For M15–H1 trading, H4 or Daily is recommended.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 6-Layer Confluence Engine[/b]

All six layers score independently on every bar. A signal only fires when the score meets the configured minimum (default: 4 of 6), the sweep condition is active, a qualifying structure event has occurred, and the ADX, session, and cooldown conditions are met.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 1 — Liquidity Sweep[/b]

The foundational layer. Awards 1 point when a qualifying liquidity sweep (SSL for bull, BSL for bear) has occurred on the current or immediately preceding bar. This layer is also a [b]hard requirement[/b] — regardless of the confluence score, no SURGE signal can fire without a recent sweep. This is the event that initiates the institutional sequence. Without a genuine liquidity grab, the setup is not a SURGE setup.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 2 — Market Structure[/b]

Awards 1 point when the current structural trend agrees with the signal direction — a bullish structural trend for bull signals, bearish for bear. The structure layer also enforces the [b]structure type requirement[/b]: a qualifying CHoCH or BOS must have occurred (subject to the Allow CHoCH / Allow BOS settings) for a signal to fire. Structure is both a scoring layer and a hard prerequisite, identical to the sweep requirement.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 3 — Premium / Discount Zone[/b]

Awards 1 point when price is in the correct PD zone for the signal direction — discount for bull signals, premium for bear signals. When the PD filter setting is off, this layer always votes in favor. This layer encodes the institutional value positioning principle: buy cheap, sell expensive.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 4 — HTF Bias[/b]

Awards 1 point when the higher timeframe EMA structure agrees with the signal direction. This is the multi-timeframe alignment layer — the most macro of the six confluence inputs. When HTF bias is disabled in settings, this layer always votes in favor.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 5 — Squeeze Momentum[/b]

The TTM Squeeze momentum layer — identical to the implementation in Pulse Scalper and VOID. When the Bollinger Band/Keltner Channel squeeze fires with directional momentum (positive and rising for bull, negative and falling for bear), this layer votes. The orange squeeze background tint provides pre-signal awareness when energy is compressing. A SURGE setup that coincides with a squeeze release means the SMC structure event and the breakout energy event are occurring simultaneously — one of the highest-quality convergences the system can detect.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 6 — Volume Delta[/b]

The proprietary volume pressure model — splitting each candle's volume into estimated bull and bear components, confirmed by OBV slope. This layer confirms that real institutional capital flow is behind the sweep and structure move. A liquidity sweep with no volume delta confirmation is a weak, potentially algorithmic sweep. A sweep with strong volume delta agreement means genuine order flow drove the grab — the highest-quality sweep condition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Signal Firing Logic[/b]

A SURGE signal fires when [b]all of the following are simultaneously true:[/b]
[list]
[*]A qualifying liquidity sweep occurred on the current or immediately preceding bar (hard requirement — independent of scoring)
[*]A qualifying structure event (CHoCH or BOS per settings) has confirmed the structural direction (hard requirement)
[*]Confluence score meets or exceeds the configured minimum (default: 4 of 6)
[*]VWAP bias confirms — price above VWAP for bull, below for bear (when VWAP filter is enabled)
[*]ADX confirms a trending market above the minimum threshold
[*]Session filter confirms active market hours
[*]Signal cooldown has elapsed since the last signal in the same direction (default: 10 bars)
[/list]

[b]Edge triggering:[/b] The signal fires only on the bar the conditions first become true — not repeatedly while they remain true. Each triangle is a distinct, fresh setup event.

[b]Score label:[/b] Every signal prints the live confluence count (e.g., [b]5/6[/b] or [b]6/6[/b]) directly on the chart so you know the quality of every setup at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Sweep-Anchored Stop Loss Placement[/b]

SURGE includes a purpose-built stop loss mode specifically designed for liquidity sweep setups: [b]SL Beyond Sweep Wick[/b] (default: on).

When enabled, the stop loss for a bull entry is placed at the [b]tracked swing low level[/b] (the level that was swept) minus an ATR buffer. For a bear entry, the stop is placed at the [b]tracked swing high level[/b] plus an ATR buffer.

[b]Why this is the structurally correct stop for sweep setups:[/b] The sweep wick represents the maximum extent of the institutional grab. If price returns below the swept swing low (bull) and closes there, the sweep thesis is invalidated — institutions were not grabbing that liquidity for a reversal, the level was genuinely broken. Placing the stop at the swept level is therefore not an arbitrary distance — it is the exact price at which the setup's core premise is proven wrong.

When this setting is off, the stop reverts to a standard ATR distance from the entry bar's low or high.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡 [b]Dynamic ATR Exit System[/b]

[b]Stop Loss:[/b] Placed at the swept swing level (when enabled) or bar extreme, plus an ATR buffer (default: 1.3×). Your structural invalidation boundary.

[b]TP1 — Partial Target (50%):[/b] 2.0× ATR from entry — slightly wider than the Pulse Scalper and VOID defaults, reflecting the higher-conviction, lower-frequency nature of SURGE setups. Scale out 50% here and move the remainder to breakeven.

[b]TP2 — Full Target:[/b] 3.8× ATR from entry. Full position exits on TP2 hit. A labeled [b]TP[/b] marker appears on the chart.

[b]ATR Trailing Stop:[/b] Dynamic stop advancing with price every bar at 1.6× ATR behind the current bar's extreme. Plotted as a live orange line. In genuine institutional delivery moves following a sweep, price frequently extends well beyond the fixed TP2 — the trail captures this extension without predetermining a ceiling on the gain.

All exit levels are plotted as live lines for the duration of the trade and cleared automatically on exit.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The real-time dashboard displays the complete internal state across four sections, updated on every bar.

[b]STRUCTURE[/b]
[list]
[*][b]Trend[/b] — current market structure state: ▲ BULLISH, ▼ BEARISH, or — RANGE. This reflects the confirmed structural trend as tracked by the BOS/CHoCH engine
[*][b]Liquidity[/b] — live sweep detection status: ▲ SSL SWEEP (sell-side grab, bullish signal) or ▼ BSL SWEEP (buy-side grab, bearish signal). Updates in real time on sweep bars
[*][b]PD Zone[/b] — current premium/discount position: ◧ DISCOUNT, ◧ PREMIUM, or — EQ (at equilibrium). Color-coded yellow-green for discount, red for premium
[/list]

[b]HTF / SESSION[/b]
[list]
[*][b]HTF Bias[/b] — higher timeframe EMA alignment: ▲ BULL or ▼ BEAR. Confirms whether the macro institutional flow supports the current setup direction
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF. Confirms whether the session filter is open for signals
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail indicator
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Momentum[/b] — squeeze and directional momentum state: ⚡ SQZ (squeeze building), ▲ or ▼ for directional momentum, or — for flat
[*][b]Vol Delta[/b] — volume pressure direction: ▲ BULL, ▼ BEAR, or —
[*][b]Bull Score[/b] — live 0–6 score. Background highlights yellow-green when threshold is met
[*][b]Bear Score[/b] — live 0–6 score. Background highlights red when threshold is met
[/list]

[b]POSITION[/b]
[list]
[*][b]Position[/b] — ▲ LONG, ▼ SHORT, or — FLAT with background color highlight
[*][b]Stop Loss[/b] — active SL level (sweep-anchored or ATR-based), color-coded by direction
[*][b]TP1[/b] — active first take-profit level
[*][b]Bars in Trade[/b] — bars elapsed since entry
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]◆ Diamond (below bar, yellow-green)[/b] — bull liquidity sweep confirmed. SSL grabbed with close back above the swing low
[*][b]◆ Diamond (above bar, red)[/b] — bear liquidity sweep confirmed. BSL grabbed with close back below the swing high
[*][b]CHoCH ▲ / CHoCH ▼ label (orange)[/b] — Change of Character detected. Trend reversal structure event
[*][b]BOS ▲ / BOS ▼ label (yellow-green / red)[/b] — Break of Structure detected. Trend continuation structure event
[*][b]▲ Triangle (below bar)[/b] — bull SURGE entry. All conditions met
[*][b]▼ Triangle (above bar)[/b] — bear SURGE entry. All conditions met
[*][b]Score Label (e.g. 5/6)[/b] — confluence count at signal time on every entry triangle
[*][b]Order Block Boxes[/b] — semi-transparent zones marking institutional supply and demand origins. Yellow-green for bull OBs, red for bear OBs
[*][b]Liquidity Level Lines[/b] — dashed lines projecting the current swing high (sell-side liquidity, red dashed) and swing low (buy-side liquidity, yellow-green dashed) forward
[*][b]Equilibrium Line (purple dots)[/b] — the 50% midpoint of the current dealing range
[*][b]EMA Ribbon Fill[/b] — yellow-green fill during bull EMA structure, red during bear, gray during flat
[*][b]VWAP Line (purple)[/b] — optional, toggleable session VWAP
[*][b]Orange Squeeze Background[/b] — active during Bollinger/Keltner squeeze compression
[*][b]Yellow-green background tint[/b] — active during open long trades
[*][b]Red background tint[/b] — active during open short trades
[*][b]SL / TP1 / TP2 / Trail Lines[/b] — all four exit levels plotted live for the duration of every trade
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX SURGE — Step by Step[/b]

[b]Step 1 — Establish Context Before the Session[/b]
[list]
[*]Check the dashboard: what is the current structural trend and HTF bias? If both show the same direction, you have macro confluence — prioritize setups in that direction
[*]Check the PD Zone row: is price currently in discount (favor longs) or premium (favor shorts)? Price at equilibrium is the lowest-quality PD position — wait for it to develop to one side
[*]Note where the liquidity level lines are on the chart — these dashed lines mark exactly where the next sweep targets are sitting
[/list]

[b]Step 2 — Watch for a Sweep Diamond[/b]
[list]
[*]A yellow-green ◆ diamond below the bar signals an SSL grab — the sweep phase has occurred. The system is now in active scan mode for a SURGE signal
[*]A red ◆ diamond above the bar signals a BSL grab
[*]The sweep is the trigger for your attention — not the entry signal. The entry comes next
[/list]

[b]Step 3 — Confirm the Structure Event[/b]
[list]
[*]Watch for a CHoCH or BOS label to appear following the sweep. A CHoCH after a sweep is the highest-quality sequence — institutional grab followed by genuine trend reversal confirmation
[*]Check the confluence scores on the dashboard. After a sweep, the bull or bear score should be climbing toward the threshold as the structure, PD, and momentum layers align
[/list]

[b]Step 4 — Enter on the SURGE Triangle[/b]
[list]
[*]A ▲ triangle confirms all conditions are met for a long. A ▼ triangle confirms all conditions for a short
[*]Read the score label. A 6/6 signal means every layer — sweep, structure, PD zone, HTF bias, momentum, and volume — are all aligned simultaneously. These are the highest-conviction setups SURGE produces and warrant full position size
[*]A 4/6 or 5/6 signal is still a valid SURGE entry — standard position size, strict stop management
[/list]

[b]Step 5 — Manage with Live Exit Lines[/b]
[list]
[*]The SL line is your swept level invalidation. If the sweep level is retaken cleanly, the setup thesis is gone
[*]Watch the orange trail line advance with price as the institutional delivery move develops
[*]At TP1, scale out 50% and move the remainder to breakeven — let the trail capture the full delivery
[/list]

[b]Step 6 — Exit and Reset[/b]
[list]
[*]A [b]TP[/b] marker confirms TP2 reached — full exit and system reset
[*]An [b]SL[/b] marker confirms stop or trail triggered — close the position and wait for the next sweep event to develop
[*]Do not re-enter on impulse after a stopped trade. The swept level that was just violated is now the new liquidity target for the next setup. Wait for the next clean sweep and structure sequence
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]HTF Bias opposes the setup direction[/b] — a bullish sweep and CHoCH against an H1 downtrend is a counter-trend reversal trade. The institutional macro flow is working against you. These setups fail at a much higher rate than with-trend entries
[*][b]PD Zone is wrong for the direction[/b] — a bull setup in premium or a bear setup in discount means you are entering at the institutionally unfavorable side of the range. Wait for price to correct to the appropriate zone
[*][b]Sweep occurred but no CHoCH or BOS followed[/b] — a sweep without structure confirmation means the liquidity grab did not produce a genuine reversal or continuation. The institution may have filled only part of its position. Wait for structure to develop
[*][b]ADX ✗[/b] — the market is not trending. SMC concepts work best in directional markets. In ranging conditions, sweeps are frequently noise events rather than institutional accumulation
[*][b]Score stuck at 2 or 3 of 6 after a sweep[/b] — the confluence environment is too fragmented. Too many layers are disagreeing. A sweep in isolation is not a trade
[*][b]Multiple sweeps in rapid succession without entry signals[/b] — choppy markets produce repeated liquidity grabs in both directions. The confluence gate will block most of these, but the underlying message is that the market is in an oscillating range — not the institutional delivery environment SURGE is designed for
[*][b]Structure trend and HTF bias are both — or FLAT[/b] — no clear institutional direction exists. No SURGE setup can develop until structural bias is established
[/list]

[b]What to do:[/b]
[list]
[*]Wait for HTF bias and structural trend to align in the same direction — this is the macro setup condition for the highest-quality SURGE signals
[*]Wait for price to reach the correct PD zone for the anticipated direction before the sweep occurs — the ideal sequence is: price in discount, SSL sweep, bullish CHoCH, 5–6/6 confluence signal
[*]Watch the liquidity level lines — price approaching a level is the pre-alert that a sweep may be imminent. Prepare your confluence scan as price approaches those lines
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]💧 Real-time liquidity sweep detection — identifies SSL and BSL grabs with minimum ATR wick filter and close-back confirmation, eliminating noise sweeps
[*]📐 Full market structure engine — tracks swing highs and lows, detects CHoCH and BOS events, maintains a live structural trend state
[*]📦 Automatic order block detection — spawns OB zones on every confirmed structure event, marking the exact institutional origin of each move
[*]⚖ Premium/Discount zone filter — enforces institutionally correct entry positioning using a dynamic equilibrium level across the recent dealing range
[*]📡 HTF bias filter — pulls a dual-EMA structure from a configurable higher timeframe to confirm macro institutional flow alignment
[*]🧠 6-layer confluence gate — Sweep, Structure, PD Zone, HTF Bias, Squeeze Momentum, and Volume Delta must reach the minimum score threshold before a signal fires
[*]📊 Live confluence scoring — bull and bear scores updated every bar, displayed on the dashboard before any signal appears
[*]🔀 CHoCH / BOS signal type control — independently enable reversal setups, continuation setups, or both
[*]🎯 Sweep-anchored stop loss — places the SL at the structural invalidation level (the swept swing point) rather than an arbitrary ATR distance
[*]⚡ TTM Squeeze integration — Bollinger/Keltner compression detection flags pre-breakout energy with orange background tint and dashboard state
[*]📈 Proprietary volume delta model — estimates institutional order flow pressure without exchange-level data, confirmed by OBV slope
[*]🌐 VWAP session bias — enforces institutional session direction alignment on every signal
[*]🛡 Dynamic ATR trailing stop — orange line advances with price every bar, capturing full institutional delivery moves beyond the fixed TP2
[*]💹 Liquidity level lines — dashed projections of the current swing high and swing low showing exactly where the next liquidity pools sit
[*]📊 22-row live dashboard — Structure, HTF/Session, Confluence, and Position sections updated in real time
[*]🔔 12 alert conditions — sweep events, CHoCH events, entry signals, TP1/TP2 hits, and stop hits for both directions
[*]🎨 Fully cohesive dual-tone color system — yellow-green for all bullish elements, red for all bearish, orange for squeeze and trail, purple for VWAP and equilibrium
[*]⚙ Fully configurable — all pivot lengths, OB parameters, PD range, HTF timeframe and EMA periods, confluence minimum, ADX threshold, exit multipliers, session window, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Structure & Liquidity[/b]
[list]
[*]Swing Pivot Length — bars used for pivot high/low detection. Controls the significance of swing levels tracked for sweeps and structure (default: 5)
[*]Show BOS / CHoCH Labels — toggle structure event labels on the chart
[*]Show Liquidity Levels — toggle the dashed swing high and swing low projection lines
[*]Liquidity Line Extend — how many bars forward the liquidity level lines project (default: 25)
[*]Min Sweep Wick (ATR x) — minimum wick extension beyond the swing level required to register a sweep (default: 0.05× ATR)
[/list]

[b]Order Blocks[/b]
[list]
[*]Show Order Blocks — toggle OB zone boxes on or off
[*]Max Order Blocks — maximum OBs stored in memory simultaneously (default: 25)
[*]OB Extend (bars) — how many bars forward OB boxes project (default: 20)
[*]OB Lookback Bars — how many bars back to search for the origin candle when spawning an OB (default: 12)
[/list]

[b]Premium / Discount[/b]
[list]
[*]Show Equilibrium Line — toggle the dealing range midpoint line
[*]Dealing Range Length — bars used to calculate the high/low range for PD zone positioning (default: 50)
[*]Require Correct PD Zone — when on, longs require discount positioning and shorts require premium positioning (default: on)
[/list]

[b]HTF Bias[/b]
[list]
[*]Use HTF Trend Filter — toggle the higher timeframe bias requirement
[*]HTF Timeframe — the higher timeframe to pull EMA data from (default: 60-minute)
[*]HTF Fast EMA — fast EMA period on the HTF (default: 21)
[*]HTF Slow EMA — slow EMA period on the HTF (default: 55)
[/list]

[b]EMA Ribbon[/b]
[list]
[*]Fast / Slow / Signal EMA — triple ribbon periods (defaults: 8 / 21 / 50)
[*]Show EMA Ribbon — toggle ribbon fill and line plots
[/list]

[b]Squeeze Momentum[/b]
[list]
[*]BB Length / BB Mult — Bollinger Band parameters (defaults: 20 / 2.0)
[*]KC Length / KC Mult — Keltner Channel parameters (defaults: 20 / 1.5)
[*]Momentum Length — linear regression momentum period (default: 12)
[/list]

[b]Volume Delta[/b]
[list]
[*]Volume MA Length — EMA smoothing for volume estimates (default: 14)
[*]OBV Slope Length — lookback for OBV slope directionality (default: 10)
[/list]

[b]VWAP[/b]
[list]
[*]Use VWAP Filter — when on, requires price to be on the correct VWAP side for each signal direction
[*]Show VWAP Line — toggle VWAP line on the chart
[/list]

[b]Confluence Gate[/b]
[list]
[*]Min Layers Required — minimum confluence votes needed for a signal (default: 4 of 6)
[*]Session Filter — toggle active hours restriction
[*]Active Session — configurable session window (default: 0700-2000)
[*]Signal Cooldown — minimum bars between consecutive signals in the same direction (default: 10)
[*]Allow CHoCH Reversal Setups — enables signals on trend-reversal structure events
[*]Allow BOS Continuation Setups — enables signals on trend-continuation structure events
[/list]

[b]ADX Filter[/b]
[list]
[*]Use ADX Filter — toggle the trend quality gate
[*]ADX Length — calculation lookback (default: 14)
[*]ADX Minimum — threshold below which all signals are suppressed (default: 18)
[/list]

[b]Exit Settings[/b]
[list]
[*]ATR Length — lookback for all ATR exit calculations (default: 10)
[*]SL ATR Mult — ATR buffer beyond the swept swing level (default: 1.3)
[*]TP1 ATR Mult — first take-profit distance (default: 2.0)
[*]TP2 ATR Mult — full exit target distance (default: 3.8)
[*]Use ATR Trailing Stop — toggle dynamic trailing stop
[*]Trail ATR Mult — trailing distance from current bar's extreme (default: 1.6)
[*]Show Exit Levels — toggle all exit level lines
[*]SL Beyond Sweep Wick — anchors stop to the swept swing level (default: on)
[/list]

[b]Display[/b]
[list]
[*]Show Confluence Score Label — prints live score on every signal triangle
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish signals, fills, and labels
[*]Bear / Bear Bright — red family for all bearish signals, fills, and labels
[*]Squeeze — orange for squeeze tint and trailing stop line
[*]EMA Fast / Slow / Signal — individual EMA line colors
[*]Ribbon Fill Bull / Bear / Flat — ribbon fill colors for each trend state
[*]Buy-Side / Sell-Side Liquidity — liquidity level line colors
[*]Bull / Bear Order Block — OB box fill and border colors
[*]Equilibrium Line — dealing range midpoint color (default: purple)
[*]VWAP Line — VWAP plot color
[*]BOS Bull / BOS Bear / CHoCH — structure label colors
[*]Bull / Bear Sweep Marker — sweep diamond colors
[*]SL / TP / TP2 / Trail Lines — individual exit level line colors
[*]Long Zone BG / Short Zone BG — active trade background tints
[*]Bull / Bear Label Text — score label text colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (12 total)[/b]

[b]Liquidity Alerts[/b]
[list]
[*]Bull Liquidity Sweep — sell-side liquidity grabbed, watch for long setup development
[*]Bear Liquidity Sweep — buy-side liquidity grabbed, watch for short setup development
[/list]

[b]Structure Alerts[/b]
[list]
[*]Bull CHoCH — bullish Change of Character confirmed, structural trend shifting to bullish
[*]Bear CHoCH — bearish Change of Character confirmed, structural trend shifting to bearish
[/list]

[b]Entry Alerts[/b]
[list]
[*]Bull SURGE Entry — all conditions met: sweep, structure, confluence, ADX, session
[*]Bear SURGE Entry — all conditions met for a short institutional sweep entry
[/list]

[b]Exit Alerts[/b]
[list]
[*]Bull TP1 Hit — scale out 50% of long position
[*]Bull TP2 Hit — full long position exit
[*]Bull Stop Hit — stop loss or trail triggered on long
[*]Bear TP1 Hit — scale out 50% of short position
[*]Bear TP2 Hit — full short position exit
[*]Bear Stop Hit — stop loss or trail triggered on short
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M1–M15[/b]:
[list]
[*]Min Layers at 4/6 — strong confluence while accounting for the complexity of the 6-layer system
[*]HTF at 60-minute — provides meaningful higher timeframe context for intraday M1–M15 setups
[*]Sweep wick at 0.05× ATR — sensitive enough to catch genuine institutional grabs without registering micro-noise sweeps
[*]SL Beyond Sweep Wick on — structurally anchored stop placement at the institutional invalidation level
[*]Allow CHoCH and BOS both on — captures both reversal and continuation setups in the full range of institutional delivery scenarios
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]Higher timeframes (H1, H4)[/b] — set HTF to Daily or Weekly, increase Swing Pivot Length to 8–10, increase TP2 to 5.0–6.0× ATR, raise Min Confidence to 5/6
[*][b]Crypto (BTC, ETH)[/b] — increase Min Sweep Wick to 0.1–0.15× ATR to filter out the higher frequency of noise sweeps in volatile crypto sessions, increase KC Mult to 2.0
[*][b]Indices (NAS100, US30)[/b] — tighten session to 09:30–16:00, increase ADX minimum to 22, set HTF to H4 for intraday M5–M15 trading
[*][b]CHoCH-only mode[/b] — disable Allow BOS Continuation, raise Min Layers to 5/6. This produces the fewest signals but each represents a genuine trend reversal with maximum institutional evidence
[*][b]More signals[/b] — lower Min Layers to 3, reduce Cooldown, disable PD Zone requirement, disable HTF filter
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🏦 [b]Smart money concepts and ICT methodology traders[/b] — SURGE is the quantitative implementation of the core SMC trading sequence: liquidity grab, structure shift, PD zone entry. Everything you execute manually in an SMC framework is automated and filtered here
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — institutional order flow mechanics are most consistent and powerful on these instruments. Default settings are calibrated for gold intraday
[*]📊 [b]Multi-timeframe traders[/b] — the HTF bias filter is built for traders who use higher timeframe confluence as a core component of their trade selection process
[*]🎯 [b]Traders who want to stop buying highs and selling lows[/b] — the PD zone filter enforces the discipline of buying in discount and selling in premium, the foundational institutional positioning principle
[*]🧠 [b]Systematic traders[/b] — the 6-layer confluence score provides a fully quantified quality metric for every setup, replacing subjective SMC judgment with objective numerical scoring
[*]📈 [b]Traders who want to trade with institutions, not against them[/b] — every component of SURGE — the sweep detection, structure engine, PD zone, HTF filter, order blocks, and liquidity lines — is designed to identify and align with genuine institutional order flow
[*]⚠ [b]Traders who struggle with SMC subjectivity[/b] — traditional SMC analysis requires significant discretion. SURGE removes that discretion by encoding the rules objectively and applying them consistently on every bar across all instruments and timeframes
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Structural trend tracking, sweep detection, and confluence scoring all finalize on confirmed bars only
[*]The swing pivot detection has an inherent offset of [b]swingLen[/b] bars — a pivot is only confirmed after [b]swingLen[/b] bars have passed to the right of the pivot bar. This is standard for pivot-based systems and is not repainting — it is real-time confirmation
[*]Order blocks are spawned on structure confirmation bars. The OB origin candle is the most recent opposing candle within the lookback window prior to the structure event — representing the genuine institutional origin zone
[*]The structural trend variable is persistent — once a bullish trend is established by a BOS/CHoCH, it remains bullish until a bearish structure break occurs. This means the structure layer can remain in a favorable state across many bars between signals
[*]Maximum 500 labels and 500 lines and 300 boxes are rendered. On very active low-timeframe charts with long history, oldest labels, order block boxes, and liquidity lines may be removed by TradingView's rendering limits
[*]The VWAP calculation resets at each session start. On 24-hour crypto instruments, consider disabling the VWAP filter for best system behavior
[*]The Trade Status section tracks position direction from signal to exit within the chart session — it does not connect to your broker or brokerage account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that price moves to take liquidity before it moves to deliver value — and who want a system precise enough to be positioned for that delivery every time.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX — SURGE v1.0
// Liquidity Sweep + Market Structure + Premium/Discount Confluence Engine

//@version=6
indicator("[ A L P H A X ] SURGE", shorttitle="AlphaX SURGE",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=300, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ INPUTS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

grpStruct = "Structure & Liquidity"
swingLen      = input.int(5,     "Swing Pivot Length",       minval=2,  maxval=20,  group=grpStruct)
showStructLbl = input.bool(true,  "Show BOS / CHoCH Labels", group=grpStruct)
showLiqLines  = input.bool(true,  "Show Liquidity Levels",    group=grpStruct)
liqLineExt    = input.int(25,    "Liquidity Line Extend",    minval=5,  maxval=100, group=grpStruct)
sweepWickAtr  = input.float(0.05,"Min Sweep Wick (ATR x)",   minval=0.0,maxval=1.0, step=0.05, group=grpStruct)

grpOb = "Order Blocks"
showOB       = input.bool(true,  "Show Order Blocks",        group=grpOb)
maxOBs       = input.int(25,    "Max Order Blocks",         minval=5,  maxval=80,  group=grpOb)
obExtend     = input.int(20,    "OB Extend (bars)",         minval=5,  maxval=100, group=grpOb)
obLookback   = input.int(12,    "OB Lookback Bars",         minval=3,  maxval=30,  group=grpOb)

grpPd = "Premium / Discount"
showPdZone   = input.bool(true,  "Show Equilibrium Line",    group=grpPd)
rangeLen     = input.int(50,    "Dealing Range Length",     minval=20, maxval=200, group=grpPd)
requirePd    = input.bool(true,  "Require Correct PD Zone", group=grpPd,
  tooltip="Longs in discount (below EQ). Shorts in premium (above EQ).")

grpHtf = "HTF Bias"
useHtf       = input.bool(true,  "Use HTF Trend Filter",     group=grpHtf)
htfTF        = input.timeframe("60", "HTF Timeframe",        group=grpHtf)
htfFastLen   = input.int(21,   "HTF Fast EMA",             minval=5,  maxval=100, group=grpHtf)
htfSlowLen   = input.int(55,   "HTF Slow EMA",             minval=10, maxval=200, group=grpHtf)

grp1 = "EMA Ribbon"
emaFast    = input.int(8,  "Fast EMA",   minval=3,  maxval=20,  group=grp1)
emaSlow    = input.int(21, "Slow EMA",   minval=10, maxval=50,  group=grp1)
emaSig     = input.int(50, "Signal EMA", minval=20, maxval=200, group=grp1)
showRibbon = input.bool(true, "Show EMA Ribbon", group=grp1)

grp2 = "Squeeze Momentum"
sqzBBLen  = input.int(20,   "BB Length",       minval=5,  maxval=50,  group=grp2)
sqzBBMult = input.float(2.0,"BB Mult",         minval=1.0,maxval=3.0, step=0.1, group=grp2)
sqzKCLen  = input.int(20,   "KC Length",       minval=5,  maxval=50,  group=grp2)
sqzKCMult = input.float(1.5,"KC Mult",         minval=1.0,maxval=3.0, step=0.1, group=grp2)
momLen    = input.int(12,   "Momentum Length", minval=5,  maxval=30,  group=grp2)

grp3 = "Volume Delta"
volLen = input.int(14, "Volume MA Length", minval=5, maxval=50, group=grp3)
obvLen = input.int(10, "OBV Slope Length", minval=3, maxval=30, group=grp3)

grp4 = "VWAP"
useVwap  = input.bool(true,  "Use VWAP Filter", group=grp4)
showVwap = input.bool(false, "Show VWAP Line",  group=grp4)

grp5 = "Confluence Gate"
minConf      = input.int(4, "Min Layers Required (of 6)", minval=3, maxval=6, group=grp5,
  tooltip="Layers: Sweep, Structure, PD Zone, HTF, Momentum, Volume.")
useSession   = input.bool(true, "Session Filter", group=grp5)
sessStart    = input.session("0700-2000", "Active Session", group=grp5)
cooldown     = input.int(10, "Signal Cooldown (bars)", minval=1, maxval=50, group=grp5)
allowChoch   = input.bool(true, "Allow CHoCH Reversal Setups", group=grp5)
allowCont    = input.bool(true, "Allow BOS Continuation Setups", group=grp5)

grp6 = "ADX Filter"
useADX = input.bool(true,  "Use ADX Filter", group=grp6)
adxLen = input.int(14,     "ADX Length",     minval=7,  maxval=30, group=grp6)
adxMin = input.float(18,   "ADX Minimum",    minval=10, maxval=40, group=grp6)

grp7 = "Exit Settings"
atrLen    = input.int(10,    "ATR Length",          minval=5,  maxval=30,  group=grp7)
slMult    = input.float(1.3, "SL ATR Mult",         minval=0.5,maxval=3.0, step=0.1, group=grp7)
tp1Mult   = input.float(2.0, "TP1 ATR Mult (50%)",  minval=0.5,maxval=5.0, step=0.1, group=grp7)
tp2Mult   = input.float(3.8, "TP2 ATR Mult (full)", minval=1.0,maxval=8.0, step=0.1, group=grp7)
useTrail  = input.bool(true,  "Use ATR Trailing Stop", group=grp7)
trailMult = input.float(1.6, "Trail ATR Mult",       minval=0.5,maxval=4.0, step=0.1, group=grp7)
showExits = input.bool(true,  "Show Exit Levels", group=grp7)
slBeyondSweep = input.bool(true, "SL Beyond Sweep Wick", group=grp7)

grp8 = "Display"
showConf = input.bool(true, "Show Confluence Score Label", group=grp8)
showDash = input.bool(true, "Show Dashboard",              group=grp8)
dashPos  = input.string("Top Right", "Dashboard Position",
  options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp8)

// Colors — keep last so it appears at the bottom of settings
grpColors = "Colors"
colBull         = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr       = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear         = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr       = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze      = input.color(#ff9800, "Squeeze",            group=grpColors)
colNeutral      = input.color(#555555, "Neutral",            group=grpColors)
colEmaFast      = input.color(#c8e624, "EMA Fast",           group=grpColors)
colEmaSlow      = input.color(#9ab81c, "EMA Slow",           group=grpColors)
colEmaSig       = input.color(#555555, "EMA Signal",         group=grpColors)
colRibbonBull   = input.color(#c8e624, "Ribbon Fill Bull",   group=grpColors)
colRibbonBear   = input.color(#ff1744, "Ribbon Fill Bear",   group=grpColors)
colRibbonFlat   = input.color(#555555, "Ribbon Fill Flat",   group=grpColors)
colLiqBull      = input.color(#c8e624, "Buy-Side Liquidity", group=grpColors)
colLiqBear      = input.color(#ff1744, "Sell-Side Liquidity",group=grpColors)
colObBull       = input.color(#c8e624, "Bull Order Block",   group=grpColors)
colObBear       = input.color(#ff1744, "Bear Order Block",   group=grpColors)
colEqLine       = input.color(#8b6fd0, "Equilibrium Line",   group=grpColors)
colVwap         = input.color(#8b6fd0, "VWAP Line",          group=grpColors)
colStructBull   = input.color(#c8e624, "BOS Bull Label",     group=grpColors)
colStructBear   = input.color(#ff1744, "BOS Bear Label",     group=grpColors)
colChoch        = input.color(#ff9800, "CHoCH Label",        group=grpColors)
colSweepBull    = input.color(#c8e624, "Bull Sweep Marker",  group=grpColors)
colSweepBear    = input.color(#ff1744, "Bear Sweep Marker",  group=grpColors)
colSlLine       = input.color(#ff1744, "SL Line",            group=grpColors)
colTpLine       = input.color(#c8e624, "TP Line",            group=grpColors)
colTpLineBr     = input.color(#d4f03a, "TP2 Line",           group=grpColors)
colTrailLine    = input.color(#ff9800, "Trail Line",         group=grpColors)
colLongZone     = input.color(#c8e624, "Long Zone BG",       group=grpColors)
colShortZone    = input.color(#ff1744, "Short Zone BG",      group=grpColors)
colLabelBullTxt = input.color(#0d0d0d, "Bull Label Text",    group=grpColors)
colLabelBearTxt = input.color(#ffffff, "Bear Label Text",    group=grpColors)
colTextLt       = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg       = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader   = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec      = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame    = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ HELPERS ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ORDER BLOCK STORAGE ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var array<float> obTops   = array.new_float()
var array<float> obBtms   = array.new_float()
var array<int>   obBars   = array.new_int()
var array<int>   obDirs   = array.new_int()
var array<box>   obBoxes  = array.new_box()

trimOBs() =>
    while array.size(obTops) > maxOBs
        box bx = array.shift(obBoxes)
        if not na(bx)
            box.delete(bx)
        array.shift(obTops)
        array.shift(obBtms)
        array.shift(obBars)
        array.shift(obDirs)

addOB(float top, float btm, int dir, int leftBar) =>
    trimOBs()
    color fillCol = dir == 1 ? color.new(colObBull, 90) : color.new(colObBear, 90)
    color edgeCol = dir == 1 ? color.new(colObBull, 40) : color.new(colObBear, 40)
    box bx = showOB ? box.new(leftBar, top, bar_index + obExtend, btm,
      border_color=edgeCol, border_width=1, bgcolor=fillCol, xloc=xloc.bar_index) : na
    array.push(obTops, top)
    array.push(obBtms, btm)
    array.push(obBars, leftBar)
    array.push(obDirs, dir)
    array.push(obBoxes, bx)

updateOBs() =>
    int n = array.size(obTops)
    if n > 0
        for i = 0 to n - 1
            box bx = array.get(obBoxes, i)
            if not na(bx)
                box.set_right(bx, bar_index + obExtend)

findOB(int dirWanted) =>
    float oTop = na
    float oBtm = na
    int   oBar = na
    int n = array.size(obTops)
    if n > 0
        for i = 0 to n - 1
            if array.get(obDirs, i) == dirWanted
                int b = array.get(obBars, i)
                if na(oBar) or b > oBar
                    oBar := b
                    oTop := array.get(obTops, i)
                    oBtm := array.get(obBtms, i)
    [oTop, oBtm, oBar]

spawnOB(int dir) =>
    float oTop = na
    float oBtm = na
    int   oBar = na
    for i = 1 to obLookback
        bool bearCandle = close[i] < open[i]
        bool bullCandle = close[i] > open[i]
        if dir == 1 and bearCandle
            oTop := high[i]
            oBtm := low[i]
            oBar := bar_index - i
            break
        if dir == -1 and bullCandle
            oTop := high[i]
            oBtm := low[i]
            oBar := bar_index - i
            break
    if not na(oBar)
        addOB(oTop, oBtm, dir, oBar)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ SWINGS & STRUCTURE ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float pivHi = ta.pivothigh(high, swingLen, swingLen)
float pivLo = ta.pivotlow(low, swingLen, swingLen)

var float shLevel  = na
var float slLevel  = na
var int   shBar    = na
var int   slBar    = na
var int   structTrend = 0

if not na(pivHi)
    shLevel := pivHi
    shBar   := bar_index - swingLen
if not na(pivLo)
    slLevel := pivLo
    slBar   := bar_index - swingLen

float atrVal = ta.atr(atrLen)

bool bosBull = barstate.isconfirmed and not na(shLevel) and close > shLevel
bool bosBear = barstate.isconfirmed and not na(slLevel) and close < slLevel

bool chochBull = bosBull and structTrend == -1
bool chochBear = bosBear and structTrend == 1
bool bosContBull = bosBull and structTrend == 1
bool bosContBear = bosBear and structTrend == -1

if bosBull
    structTrend := 1
if bosBear
    structTrend := -1

bool structBull = structTrend == 1
bool structBear = structTrend == -1

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LIQUIDITY SWEEPS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float minSweep = atrVal * sweepWickAtr

bool bullSweep = barstate.isconfirmed and not na(slLevel) and
  low < slLevel - minSweep and close > slLevel and close > open
bool bearSweep = barstate.isconfirmed and not na(shLevel) and
  high > shLevel + minSweep and close < shLevel and close < open

bool bullSweepRecent = bullSweep or bullSweep[1]
bool bearSweepRecent = bearSweep or bearSweep[1]

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ PREMIUM / DISCOUNT ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float dealHigh = ta.highest(high, rangeLen)
float dealLow  = ta.lowest(low, rangeLen)
float dealEq   = (dealHigh + dealLow) * 0.5

bool inDiscount = close <= dealEq
bool inPremium  = close >= dealEq
bool pdBullOK   = not requirePd or inDiscount
bool pdBearOK   = not requirePd or inPremium

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ HTF BIAS ════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float htfFast = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
float htfSlow = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)
bool  htfBull = htfFast > htfSlow
bool  htfBear = htfFast < htfSlow
bool  htfBullOK = not useHtf or htfBull
bool  htfBearOK = not useHtf or htfBear

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER: EMA RIBBON ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float emaF  = ta.ema(close, emaFast)
float emaS  = ta.ema(close, emaSlow)
float emaSG = ta.ema(close, emaSig)

bool emaBull = emaF > emaS and emaS > emaSG and close > emaF
bool emaBear = emaF < emaS and emaS < emaSG and close < emaF

p1 = plot(showRibbon ? emaF  : na, "Fast EMA",   color=color.new(colEmaFast, 30), linewidth=1)
p2 = plot(showRibbon ? emaS  : na, "Slow EMA",   color=color.new(colEmaSlow, 40), linewidth=1)
p3 = plot(showRibbon ? emaSG : na, "Signal EMA", color=color.new(colEmaSig,  20), linewidth=2)
fill(p1, p2, color=emaBull ? color.new(colRibbonBull, 80) : emaBear ? color.new(colRibbonBear, 80) : color.new(colRibbonFlat, 90))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER: SQUEEZE MOMENTUM ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float bbBasis = ta.sma(close, sqzBBLen)
float bbDev   = sqzBBMult * ta.stdev(close, sqzBBLen)
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev

float kcBasis = ta.ema(close, sqzKCLen)
float kcRange = ta.atr(sqzKCLen)
float kcUpper = kcBasis + sqzKCMult * kcRange
float kcLower = kcBasis - sqzKCMult * kcRange

bool sqzOn = bbUpper < kcUpper and bbLower > kcLower

float momVal  = ta.linreg(close - math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen)), momLen, 0)
float momPrev = momVal[1]
bool momBull  = momVal > 0 and momVal > momPrev
bool momBear  = momVal < 0 and momVal < momPrev

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER: VOLUME DELTA ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float cRange = high - low
float bullVolEst = cRange != 0 ? volume * (close - low) / cRange : volume * 0.5
float bearVolEst = volume - bullVolEst
float volMaBull  = ta.ema(bullVolEst, volLen)
float volMaBear  = ta.ema(bearVolEst, volLen)
float volDelta   = volMaBull - volMaBear
float volDeltaMA = ta.ema(volDelta, 5)
float obv        = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
float obvSlope   = obv - obv[obvLen]
bool volBull = volDelta > 0 and volDeltaMA > 0 and obvSlope > 0
bool volBear = volDelta < 0 and volDeltaMA < 0 and obvSlope < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER: VWAP ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

[vwapVal, _, _] = ta.vwap(hlc3, session.isfirstbar, 1.0)
bool vwapBull = useVwap ? close > vwapVal : true
bool vwapBear = useVwap ? close < vwapVal : true

plot(showVwap ? vwapVal : na, "VWAP", color=color.new(colVwap, 40), linewidth=2)
plot(showPdZone ? dealEq : na, "Equilibrium", color=color.new(colEqLine, 50), linewidth=1, style=plot.style_circles)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ADX ═════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float upMove   = high - high[1]
float downMove = low[1] - low
float plusDM   = upMove > downMove and upMove > 0 ? upMove : 0.0
float minusDM  = downMove > upMove and downMove > 0 ? downMove : 0.0
float trR      = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
float smTR     = ta.rma(trR, adxLen)
float smPlus   = ta.rma(plusDM, adxLen)
float minusR   = ta.rma(minusDM, adxLen)
float pDI      = smTR != 0 ? 100 * smPlus / smTR : 0.0
float mDI      = smTR != 0 ? 100 * minusR / smTR : 0.0
float dx       = (pDI + mDI) != 0 ? 100 * math.abs(pDI - mDI) / (pDI + mDI) : 0.0
float adxVal   = ta.rma(dx, adxLen)
bool  adxOK    = not useADX or adxVal >= adxMin

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ORDER BLOCKS ON STRUCTURE ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.isconfirmed and (chochBull or bosContBull)
    spawnOB(1)
if barstate.isconfirmed and (chochBear or bosContBear)
    spawnOB(-1)
updateOBs()

[obBullTop, obBullBtm, _] = findOB(1)
[obBearTop, obBearBtm, _] = findOB(-1)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ CONFLUENCE & SIGNALS ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bool inSession = not useSession or not na(time(timeframe.period, sessStart))

int bullScore = (bullSweepRecent ? 1 : 0) + (structBull ? 1 : 0) + (pdBullOK ? 1 : 0) +
  (htfBullOK ? 1 : 0) + (momBull ? 1 : 0) + (volBull ? 1 : 0)
int bearScore = (bearSweepRecent ? 1 : 0) + (structBear ? 1 : 0) + (pdBearOK ? 1 : 0) +
  (htfBearOK ? 1 : 0) + (momBear ? 1 : 0) + (volBear ? 1 : 0)

bool bullStructOK = (allowChoch and chochBull) or (allowCont and (bosContBull or structBull))
bool bearStructOK = (allowChoch and chochBear) or (allowCont and (bosContBear or structBear))

var int lastBullSig = -10000
var int lastBearSig = -10000
bool bullCoolOK = bar_index - lastBullSig >= cooldown
bool bearCoolOK = bar_index - lastBearSig >= cooldown

bool bullSetup = bullSweepRecent and bullStructOK and bullScore >= minConf and adxOK and inSession and bullCoolOK and vwapBull
bool bearSetup = bearSweepRecent and bearStructOK and bearScore >= minConf and adxOK and inSession and bearCoolOK and vwapBear

bool bullSignal = bullSetup and not bullSetup[1]
bool bearSignal = bearSetup and not bearSetup[1]

if bullSignal
    lastBullSig := bar_index
if bearSignal
    lastBearSig := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ EXITS ═══════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var float bullSL    = na
var float bullTP1   = na
var float bullTP2   = na
var float bearSL    = na
var float bearTP1   = na
var float bearTP2   = na
var float trailStop = na
var int   tradeDir  = 0
var int   tradeBar  = na

slBaseBull = slBeyondSweep and not na(slLevel) ? slLevel : low
slBaseBear = slBeyondSweep and not na(shLevel) ? shLevel : high

if bullSignal
    bullSL    := slBaseBull - atrVal * slMult
    bullTP1   := close + atrVal * tp1Mult
    bullTP2   := close + atrVal * tp2Mult
    trailStop := slBaseBull - atrVal * trailMult
    tradeDir  := 1
    tradeBar  := bar_index

if bearSignal
    bearSL    := slBaseBear + atrVal * slMult
    bearTP1   := close - atrVal * tp1Mult
    bearTP2   := close - atrVal * tp2Mult
    trailStop := slBaseBear + atrVal * trailMult
    tradeDir  := -1
    tradeBar  := bar_index

int barsInTrade = not na(tradeBar) ? bar_index - tradeBar : 0

if tradeDir == 1 and useTrail and barsInTrade > 0
    trailStop := math.max(trailStop, low - atrVal * trailMult)
if tradeDir == -1 and useTrail and barsInTrade > 0
    trailStop := math.min(trailStop, high + atrVal * trailMult)

bool exitBullSL  = tradeDir ==  1 and not na(bullSL)  and low  <= bullSL   and barsInTrade > 0
bool exitBullTR  = tradeDir ==  1 and useTrail       and not na(trailStop) and low  <= trailStop and barsInTrade > 1
bool exitBullTP1 = tradeDir ==  1 and not na(bullTP1) and high >= bullTP1  and barsInTrade > 0
bool exitBullTP2 = tradeDir ==  1 and not na(bullTP2) and high >= bullTP2  and barsInTrade > 0
bool exitBearSL  = tradeDir == -1 and not na(bearSL)  and high >= bearSL   and barsInTrade > 0
bool exitBearTR  = tradeDir == -1 and useTrail       and not na(trailStop) and high >= trailStop and barsInTrade > 1
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
// ══════════════════════ LIQUIDITY LINES ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var line liqHiLine = na
var line liqLoLine = na

if showLiqLines and barstate.islast
    if not na(shLevel)
        if na(liqHiLine)
            liqHiLine := line.new(bar_index - swingLen, shLevel, bar_index + liqLineExt, shLevel,
              color=color.new(colLiqBear, 30), width=1, style=line.style_dashed, xloc=xloc.bar_index)
        else
            line.set_xy1(liqHiLine, bar_index - swingLen, shLevel)
            line.set_xy2(liqHiLine, bar_index + liqLineExt, shLevel)
    if not na(slLevel)
        if na(liqLoLine)
            liqLoLine := line.new(bar_index - swingLen, slLevel, bar_index + liqLineExt, slLevel,
              color=color.new(colLiqBull, 30), width=1, style=line.style_dashed, xloc=xloc.bar_index)
        else
            line.set_xy1(liqLoLine, bar_index - swingLen, slLevel)
            line.set_xy2(liqLoLine, bar_index + liqLineExt, slLevel)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ PLOTS ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

plotshape(bullSweep, title="Bull Liquidity Sweep",
  style=shape.diamond, location=location.belowbar,
  color=color.new(colSweepBull, 0), size=size.small)

plotshape(bearSweep, title="Bear Liquidity Sweep",
  style=shape.diamond, location=location.abovebar,
  color=color.new(colSweepBear, 0), size=size.small)

plotshape(bullSignal, title="Bull SURGE Entry",
  style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.normal)

plotshape(bearSignal, title="Bear SURGE Entry",
  style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.normal)

if showStructLbl and chochBull
    label.new(bar_index, low - atrVal, "CHoCH ▲", style=label.style_label_up,
      color=color.new(colChoch, 15), textcolor=color.new(colLabelBullTxt, 0), size=size.tiny)
if showStructLbl and chochBear
    label.new(bar_index, high + atrVal, "CHoCH ▼", style=label.style_label_down,
      color=color.new(colChoch, 15), textcolor=color.new(colLabelBearTxt, 0), size=size.tiny)
if showStructLbl and bosContBull and not chochBull
    label.new(bar_index, low - atrVal * 0.5, "BOS ▲", style=label.style_label_up,
      color=color.new(colStructBull, 20), textcolor=color.new(colLabelBullTxt, 0), size=size.tiny)
if showStructLbl and bosContBear and not chochBear
    label.new(bar_index, high + atrVal * 0.5, "BOS ▼", style=label.style_label_down,
      color=color.new(colStructBear, 20), textcolor=color.new(colLabelBearTxt, 0), size=size.tiny)

bgcolor(sqzOn ? color.new(colSqueeze, 92) : na, title="Squeeze BG")
bgcolor(tradeDir ==  1 ? color.new(colLongZone, 95) : na, title="Long Zone BG")
bgcolor(tradeDir == -1 ? color.new(colShortZone, 95) : na, title="Short Zone BG")

if showConf and bullSignal
    label.new(bar_index, low - atrVal * 1.8,
      text=str.tostring(bullScore) + "/6",
      style=label.style_label_up, color=color.new(colBull, 10),
      textcolor=color.new(colLabelBullTxt, 0), size=size.small)

if showConf and bearSignal
    label.new(bar_index, high + atrVal * 1.8,
      text=str.tostring(bearScore) + "/6",
      style=label.style_label_down, color=color.new(colBear, 10),
      textcolor=color.new(colLabelBearTxt, 0), size=size.small)

plotshape(exitBullTP1 and not exitBullTP2, title="Bull TP1", style=shape.circle,
  location=location.abovebar, color=color.new(colBull, 20), size=size.tiny)
plotshape(exitBullTP2, title="Bull TP2", style=shape.labeldown,
  location=location.abovebar, color=color.new(colBullBr, 0), size=size.tiny, text="TP")
plotshape(exitBullSL or exitBullTR, title="Bull SL", style=shape.labeldown,
  location=location.abovebar, color=color.new(colBear, 0), size=size.tiny, text="SL")
plotshape(exitBearTP1 and not exitBearTP2, title="Bear TP1", style=shape.circle,
  location=location.belowbar, color=color.new(colBear, 20), size=size.tiny)
plotshape(exitBearTP2, title="Bear TP2", style=shape.labelup,
  location=location.belowbar, color=color.new(colBearBr, 0), size=size.tiny, text="TP")
plotshape(exitBearSL or exitBearTR, title="Bear SL", style=shape.labelup,
  location=location.belowbar, color=color.new(colBull, 0), size=size.tiny, text="SL")

plot(showExits and tradeDir ==  1 and not na(bullSL)   ? bullSL   : na,
  "Bull SL", color=color.new(colSlLine, 20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP1)  ? bullTP1  : na,
  "Bull TP1", color=color.new(colTpLine, 50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP2)  ? bullTP2  : na,
  "Bull TP2", color=color.new(colTpLineBr, 10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bull Trail", color=color.new(colTrailLine, 30), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearSL)   ? bearSL   : na,
  "Bear SL", color=color.new(colSlLine, 20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP1)  ? bearTP1  : na,
  "Bear TP1", color=color.new(colTpLine, 50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP2)  ? bearTP2  : na,
  "Bear TP2", color=color.new(colTpLineBr, 10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bear Trail", color=color.new(colTrailLine, 30), linewidth=1, style=plot.style_linebr)

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════ DASHBOARD ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 22,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX SURGE", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "SMC v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── STRUCTURE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    string trendTxt = structBull ? "▲ BULLISH" : structBear ? "▼ BEARISH" : "— RANGE"
    color  trendClr = structBull ? colBull : structBear ? colBear : colNeutral
    table.cell(dash, 0, 2, "TREND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, trendTxt, text_color=trendClr, text_size=size.small, bgcolor=dbg)

    string sweepTxt = bullSweep ? "▲ SSL SWEEP" : bearSweep ? "▼ BSL SWEEP" : "— NONE"
    color  sweepClr = bullSweep ? colSweepBull : bearSweep ? colSweepBear : colNeutral
    table.cell(dash, 0, 3, "LIQUIDITY", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, sweepTxt, text_color=sweepClr, text_size=size.small, bgcolor=dbg)

    string pdTxt = inDiscount ? "◧ DISCOUNT" : inPremium ? "◧ PREMIUM" : "— EQ"
    color  pdClr = inDiscount ? colBull : inPremium ? colBear : colNeutral
    table.cell(dash, 0, 4, "PD ZONE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, pdTxt, text_color=pdClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── HTF / SESSION ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    table.cell(dash, 0, 6, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 7, "SESSION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, inSession ? "✓ ACTIVE" : "✗ OFF",
      text_color=inSession ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(adxVal, "#.#") + (adxOK ? " ✓" : " ✗"),
      text_color=adxOK ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 9, "", bgcolor=secBg)

    table.cell(dash, 0, 10, "MOMENTUM", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, sqzOn ? "⚡ SQZ" : momBull ? "▲" : momBear ? "▼" : "—",
      text_color=sqzOn ? colSqueeze : momBull ? colBull : momBear ? colBear : colNeutral,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 11, "VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, volBull ? "▲ BULL" : volBear ? "▼ BEAR" : "—",
      text_color=volBull ? colBull : volBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    string bullScTxt = str.tostring(bullScore) + "/6 " + (bullScore >= minConf ? "✓" : "✗")
    string bearScTxt = str.tostring(bearScore) + "/6 " + (bearScore >= minConf ? "✓" : "✗")
    table.cell(dash, 0, 12, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 12, bullScTxt, text_color=bullScore >= minConf ? colBull : colNeutral,
      text_size=size.small, bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 0, 13, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 13, bearScTxt, text_color=bearScore >= minConf ? colBear : colNeutral,
      text_size=size.small, bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

    table.cell(dash, 0, 14, "─── POSITION ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 14, "", bgcolor=secBg)

    string posTxt = tradeDir == 1 ? "▲ LONG" : tradeDir == -1 ? "▼ SHORT" : "— FLAT"
    color  posBg  = tradeDir == 1 ? color.new(colBull, 88) : tradeDir == -1 ? color.new(colBear, 88) : dbg
    table.cell(dash, 0, 15, "POSITION", text_color=colTextLt, text_size=size.small, bgcolor=posBg)
    table.cell(dash, 1, 15, posTxt,
      text_color=tradeDir == 1 ? colBull : tradeDir == -1 ? colBear : colNeutral,
      text_size=size.small, bgcolor=posBg)

    string slTxt = "—"
    if tradeDir == 1 and not na(bullSL)
        slTxt := str.tostring(bullSL, format.mintick)
    else if tradeDir == -1 and not na(bearSL)
        slTxt := str.tostring(bearSL, format.mintick)
    table.cell(dash, 0, 16, "STOP LOSS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 16, slTxt,
      text_color=tradeDir == 1 ? colBear : tradeDir == -1 ? colBull : colNeutral,
      text_size=size.small, bgcolor=dbg)

    string tpTxt = "—"
    if tradeDir == 1 and not na(bullTP1)
        tpTxt := str.tostring(bullTP1, format.mintick)
    else if tradeDir == -1 and not na(bearTP1)
        tpTxt := str.tostring(bearTP1, format.mintick)
    table.cell(dash, 0, 17, "TP1", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 17, tpTxt, text_color=colTpLine, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 18, "BARS IN TRADE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 18, tradeDir != 0 ? str.tostring(barsInTrade) + " bars" : "—",
      text_color=colNeutral, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════════ ALERTS ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(bullSweep, title="Bull Liquidity Sweep",
  message="[AlphaX SURGE] SSL SWEEP — Sell-side liquidity grabbed, watch for long setup.")
alertcondition(bearSweep, title="Bear Liquidity Sweep",
  message="[AlphaX SURGE] BSL SWEEP — Buy-side liquidity grabbed, watch for short setup.")
alertcondition(chochBull, title="Bull CHoCH",
  message="[AlphaX SURGE] BULL CHoCH — Structure shift to bullish.")
alertcondition(chochBear, title="Bear CHoCH",
  message="[AlphaX SURGE] BEAR CHoCH — Structure shift to bearish.")
alertcondition(bullSignal, title="Bull SURGE Entry",
  message="[AlphaX SURGE] LONG ENTRY — Sweep + structure confluence fired.")
alertcondition(bearSignal, title="Bear SURGE Entry",
  message="[AlphaX SURGE] SHORT ENTRY — Sweep + structure confluence fired.")
alertcondition(exitBullTP1 and not exitBullTP2, title="Bull TP1 Hit",
  message="[AlphaX SURGE] BULL TP1 — Scale out 50%.")
alertcondition(exitBullTP2, title="Bull TP2 Hit",
  message="[AlphaX SURGE] BULL TP2 — Full exit.")
alertcondition(exitBullSL or exitBullTR, title="Bull Stop Hit",
  message="[AlphaX SURGE] BULL STOPPED.")
alertcondition(exitBearTP1 and not exitBearTP2, title="Bear TP1 Hit",
  message="[AlphaX SURGE] BEAR TP1 — Scale out 50%.")
alertcondition(exitBearTP2, title="Bear TP2 Hit",
  message="[AlphaX SURGE] BEAR TP2 — Full exit.")
alertcondition(exitBearSL or exitBearTR, title="Bear Stop Hit",
  message="[AlphaX SURGE] BEAR STOPPED.")
````
