# [ A L P H A X ] MERIDIAN - Session Intelligence Engine

- url: https://www.tradingview.com/script/AfizU80b-A-L-P-H-A-X-MERIDIAN-Session-Intelligence-Engine/
- type: indicator
- pine_id: PUB;11a5aeabdae04694b9a5875e78e481d1
- version: 1.0

## Description

[b]AlphaX MERIDIAN — Session Intelligence Engine: Multi-Session Range Tracking, Prior Session Break & Retest, Opening Range Breakout, Meridian Bounce & 7-Layer Confluence Scoring[/b]

AlphaX MERIDIAN is a professional-grade session-based trading system built around the foundational truth that institutional price delivery is not random across the clock — it is organized by session. The Asian session defines the overnight range. London breaks it. New York confirms the direction or reverses it. Every major intraday move originates from one of three specific events: a break and retest of the prior session's high or low, a breakout of the opening range, or a pullback to the session's meridian equilibrium level. MERIDIAN detects all three in real time across all three global trading sessions, scores every potential entry through a 7-layer confluence engine, and fires signals only when session bias, VWAP positioning, HTF alignment, volume, and setup quality all confirm simultaneously. The result is a system that puts every trade in its correct session context — not just where price is, but [i]which session it is in[/i], [i]what the prior session established[/i], and [i]where the institutional session bias currently sits[/i]. Designed for active traders across forex, gold, indices, and crypto on M1 through H1 timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 [b]The Session Framework — Why Sessions Define Institutional Flow[/b]

Every liquid market is driven by three geographically separated groups of institutional participants operating in overlapping but distinct time windows: Asian banks and sovereign funds, European institutional desks and London market makers, and American institutional desks and New York banks. Each group has a characteristic trading behavior that shapes price during their active window.

[b]Asian Session — The Range Builder:[/b]
During Asian hours, liquidity is thinner and price tends to consolidate or range within a defined high-low channel. The Asian session range represents the overnight consolidation — the zone where price equilibrates before the European open. The extremes of the Asian range are the first liquidity pools that London will target.

[b]London Session — The Trend Initiator:[/b]
London is the world's most liquid trading session. European institutional desks frequently break the Asian range in the first hours of the London open — hunting the liquidity sitting above and below the overnight extremes before establishing the day's primary directional trend. The London opening range (the first N minutes of the session) frequently establishes the high or low of the day.

[b]New York Session — The Confirmer or Reverser:[/b]
New York either confirms the London trend with continuation, or reverses the late-London move in the early New York hours. The London/NY overlap (typically 13:00–17:00 UTC) is the highest-volume period of the day and frequently produces the largest directional moves.

MERIDIAN is built around this three-session cycle. The prior session's high, low, and meridian are the key reference levels. The opening range of London or NY is the breakout reference. The session VWAP and meridian divide the current session into institutional premium (above) and discount (below). Every signal is evaluated in the context of which session it occurred in and what the prior session established.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏱ [b]Session Tracking Engine[/b]

MERIDIAN runs a fully independent session tracking system for all three global sessions simultaneously, configurable to any timezone.

[b]Session detection:[/b]
Each session is defined by a configurable start and end hour in the selected timezone (default: UTC). The session engine detects the active session on every bar and correctly handles overnight sessions (sessions that span midnight). When no configured session is active, the system enters an OFF state and session-based calculations pause.

[b]Session-by-session OHLC tracking:[/b]
From the first bar of each session, MERIDIAN tracks the rolling high, low, and open of the session in real time. Every new bar within the session extends these values — the session high and low expand with price, and the session meridian recalculates continuously as the range develops.

[b]Session transition logic:[/b]
When a session changes, the completed session's high, low, and meridian are stored as the [b]prior session[/b] reference. These prior session values persist until the next completed session overwrites them — giving you continuous access to the most recently completed session's key levels at all times.

[b]Session VWAP (Volume Weighted Average Price):[/b]
A true session-anchored VWAP is computed from the first bar of each session — cumulative volume-weighted price divided by cumulative volume since the session open. This produces the purest possible VWAP calculation anchored to the correct institutional reference point: the session's opening bar.

[b]Session Meridian (Equilibrium):[/b]
The midpoint of the current session's high-low range — (session high + session low) / 2. This level is the MERIDIAN line, plotted as a purple dotted line on the chart. It represents the current session's equilibrium — above is institutional premium, below is institutional discount, relative to where the session has traded.

[b]Current session box:[/b]
The full range of the active session is visualized as a lightly tinted box extending from the session start bar to the current bar. Asian session boxes are gray, London boxes yellow-green tinted, and New York boxes red-tinted — providing immediate visual session identification across the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 [b]Prior Session Levels — The Institutional Reference Grid[/b]

The most important reference levels in intraday trading are the extremes established by the prior session. These are not arbitrary horizontal lines — they represent the boundaries of the range where an entire session's worth of institutional activity occurred. Breaking these levels is how one session's institutional participants establish control over the next session's price delivery.

[b]Prior Session High (red dashed):[/b]
The highest price reached during the most recently completed session. This is the sell-side resistance level — the level above which bears were unable to sustain prices in the prior session. A close above this level in the current session is a significant break of prior institutional resistance.

[b]Prior Session Low (yellow-green dashed):[/b]
The lowest price of the prior session. This is the buy-side support level — where buyers successfully defended price in the prior session. A close below this level represents a break of prior institutional support.

[b]Prior Session Meridian (purple dotted):[/b]
The midpoint of the prior session's range. This level frequently acts as a magnet — price is drawn to the prior session's 50% level on pullbacks, retracements, and continuation moves. It represents the most-traded price zone of the prior session in range-position terms.

All three prior session levels are plotted as forward-extending lines covering the relevant history window. The prior session name (ASIAN / LONDON / NEW YORK) is displayed on the dashboard so you always know which session's levels you are referencing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 [b]Opening Range — The First N Minutes[/b]

The Opening Range (ORB) is one of the most consistently respected intraday reference structures across all liquid markets. It represents the range established in the first configurable number of minutes of the London or New York session (default: 30 minutes). Once the opening range is set, breakouts above and below its boundaries frequently produce the day's strongest directional moves.

[b]How the opening range is built:[/b]
From the first bar of each London or New York session, MERIDIAN accumulates the highest high and lowest low across all bars that fall within the opening range time window. Once a bar falls outside the ORB time window, the range is locked — the ORB high and ORB low are fixed for the remainder of the session.

[b]ORB visualization:[/b]
The completed opening range is rendered as an orange-tinted box on the chart, spanning from the first ORB bar to the last ORB bar. This box remains on the chart as a reference level for the session.

[b]Dashboard ORB status:[/b]
The dashboard displays the ORB status as FORMING (while the range is still building) or SET (once locked), along with the exact ORB high and low prices. This gives you advance notice before the ORB is complete — you can watch it forming in real time and prepare for the Setup B breakout signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Session Bias — VWAP and Meridian Positioning[/b]

MERIDIAN defines the current session's directional bias through two independent price positioning checks that together create a clear institutional bias reading.

[b]VWAP bias:[/b]
Price above the session VWAP indicates institutional net-buying for the session — the volume-weighted average of all transactions favors the bull side. Price below indicates net-selling. The VWAP bias is updated on every bar as new volume flows in.

[b]Meridian bias:[/b]
Price above the session meridian (the session range midpoint) means price is in the upper, premium half of the session range. Price below is in the discount half.

[b]Combined session bias:[/b]
[list]
[*][b]sessBull[/b] — price is both above VWAP and above the session meridian. Both the volume-weighted and range-position measures confirm bullish institutional bias
[*][b]sessBear[/b] — price is both below VWAP and below the session meridian. Both measures confirm bearish institutional bias
[/list]

This combined bias is the most important single dashboard reading in MERIDIAN. A bullish session bias means the institutional context favors long entries. A bearish session bias favors shorts. Entries against the combined session bias carry the highest failure rate of any MERIDIAN setup.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Three Setup Types — A, B, and C[/b]

MERIDIAN fires signals through three distinct setup configurations, each representing a different institutional entry scenario anchored to session-based reference levels. All three can be enabled simultaneously.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup A — Prior Session Break & Retest[/b]

The most institutionally significant setup type. Fires when:
[list]
[*]The current session's price closes above the prior session high (long) or below the prior session low (short) — the structural break of the prior session's boundary
[*]Within 30 bars of the break, price pulls back to within ATR tolerance of the broken level
[*]A qualifying rejection candle forms at the retest — confirming the broken level has flipped from resistance to support (long) or support to resistance (short)
[/list]

[b]Why prior session break and retest is the highest-quality setup:[/b] When London breaks the Asian high and then retests it, the break has been confirmed as a genuine institutional breakout rather than a wick spike. The retest at the prior session level provides the optimal entry price — buying exactly at the prior resistance that has now become support, with the stop below the level and the continuation target above. This is the institutional "break, retest, continue" sequence that produces the cleanest risk/reward in session-based trading.

[b]Break detection markers:[/b] Small semi-transparent circles appear above (prior high break) or below (prior low break) the bar that closes through the prior session boundary — alerting you that a pending retest setup is now active. The system tracks the pending retest for up to 30 bars. If no qualifying retest occurs within that window, the pending state expires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup B — Opening Range Breakout[/b]

The high-momentum setup type. Fires when:
[list]
[*]The opening range has been fully set (ORB locked after the opening range period has elapsed)
[*]Price closes above the ORB high (long) or below the ORB low (short) — the first close-based break of the opening range boundary
[*]The close is on the correct side of the prior bar's close relative to the ORB level — confirming the break is not a wick through and back
[*]A qualifying bull or bear rejection candle (minimum 50% wick ratio) confirms the breakout bar's directional commitment
[/list]

[b]Why the ORB breakout is a high-conviction institutional signal:[/b] The opening range represents the indecision of the first N minutes of a session — the market testing price levels before committing to a direction. The first body close beyond the ORB boundary is the signal that the indecision has resolved and institutional order flow has committed to a direction. The rejection candle requirement ensures the break was not passive drift but a genuine directional conviction bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup C — Meridian Bounce[/b]

The continuation and trend-following setup type. Fires when:
[list]
[*]The session bias is fully established (sessBull for long, sessBear for short)
[*]Price pulls back to within ATR tolerance of the session meridian (the session range midpoint)
[*]A qualifying rejection candle forms — confirming the meridian held and price is rejecting back in the bias direction
[/list]

[b]Why the meridian bounce is a reliable continuation entry:[/b] In a trending session where price is above VWAP and above the session midpoint (sessBull), the meridian represents the natural pullback target — the highest-volume price zone within the session's lower half. Institutional buyers who missed the initial move use meridian pullbacks to add to positions. The rejection at the meridian in a sessBull environment is the continuation entry that offers the tightest stop (just below the meridian) with the continuation toward the session high as the target.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 7-Layer Confluence Engine[/b]

Every potential entry across all three setup types is scored through the same 7-layer confluence engine. The minimum default is 5 of 7.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 1 — Session Bias (Combined)[/b]

Awards 1 point when the combined session bias (sessBull for long, sessBear for short) agrees with the signal direction. This requires both VWAP positioning and meridian positioning to be aligned — the strongest single session-level directional indicator available.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 2 — VWAP Positioning[/b]

Awards 1 point when price is on the correct side of the session VWAP — above for longs, below for shorts. The VWAP layer is available independently from the combined session bias layer. On bars where price is above VWAP but below the meridian (or vice versa), the session bias may not score but the VWAP layer still contributes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 3 — HTF Bias[/b]

Awards 1 point when the higher timeframe EMA structure (default: 60-minute, 21/55 EMA pair) agrees with the signal direction. Ensures the session-level setup is aligned with the macro institutional flow. A session setup against the HTF trend carries the highest failure rate of any setup type.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 4 — Trading Session Enabled[/b]

Awards 1 point when the current session is one of the configured tradeable sessions (London and NY on by default, Asian off by default). This layer enforces session selectivity — preventing signals from firing during sessions you have chosen not to trade. If the Asian session is disabled for trading, Asian session signals are blocked at this layer regardless of how strong the other confluences are.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 5 — Volume Expansion[/b]

Awards 1 point when the current bar's volume exceeds the volume moving average by the configured minimum multiplier (default: 1.1×). Confirms that the rejection candle or breakout bar has genuine institutional participation behind it — not a low-volume drift through a reference level.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 6 — Rejection Candle Quality[/b]

Awards 1 point when a qualifying bull or bear rejection candle is present. Bull rejection requires a bullish close with the close-to-low distance exceeding 50% of the bar range. Bear rejection requires a bearish close with the high-to-close distance exceeding 50%. This layer ensures the reference level produced a visible, decisive price rejection — not a passive touch.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 7 — Setup Type Trigger[/b]

Awards 1 point when any of the three enabled setup types fires on the current bar — a prior session retest (Setup A), an ORB breakout (Setup B), or a meridian bounce (Setup C). This layer is both a confluence score contributor and a hard prerequisite — no signal can fire without at least one setup type triggering.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕯 [b]Rejection Candle Confirmation[/b]

All three setup types require a qualifying rejection candle for a signal to fire. Two candle types qualify:

[b]Bull rejection:[/b] A bullish close (close above open) where the distance from close to bar low exceeds 50% of the total bar range. The bar closed in its upper half — buyers dominated and rejected the level being tested.

[b]Bear rejection:[/b] A bearish close where the distance from bar high to close exceeds 50% of the total range. The bar closed in its lower half — sellers dominated the rejection.

The same 50% wick threshold applies across all three setup types, ensuring every MERIDIAN signal has a consistent, minimum candle quality standard regardless of which session event triggered it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Session-Anchored Stop Loss Placement[/b]

MERIDIAN places the stop loss at the most conservative of several session-based reference levels, plus an ATR buffer.

[b]For bull signals:[/b] The stop is placed at the minimum of the current bar's low, the prior session high (the retested level), the ORB low (if applicable), and the session meridian — whichever is lowest — minus the configured ATR buffer (default: 1.0× ATR). This ensures the stop is beyond the level that would structurally invalidate the signal.

[b]For bear signals:[/b] The stop is at the maximum of the current bar's high, the prior session low, the ORB high, and the session meridian, plus the ATR buffer.

[b]Dynamic TP target:[/b] The take profit is computed as `risk × R multiple` (default: 2.5R) from the entry close — adapting to the actual stop distance rather than using a fixed ATR projection. On entries where the session reference stop is very close to entry, this naturally produces a tighter target; on wider stops, the target scales accordingly.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 16-row real-time dashboard displays the complete internal state across five sections.

[b]SESSION[/b]
[list]
[*][b]Active[/b] — the currently active session: ASIAN, LONDON, NEW YORK, or OFF
[*][b]VWAP Bias[/b] — ▲ ABOVE or ▼ BELOW, showing whether price is above or below the session VWAP. Color-coded yellow-green and red
[*][b]Meridian[/b] — the exact price of the current session's equilibrium midpoint (session high + low / 2), color-coded purple
[/list]

[b]PRIOR SESSION[/b]
[list]
[*][b]Prior Sess[/b] — which session completed most recently: ASIAN, LONDON, or NEW YORK
[*][b]Prior Hi / Lo[/b] — the exact high and low of the prior session displayed as a price pair. These are the Setup A reference levels
[/list]

[b]OPENING RANGE[/b]
[list]
[*][b]ORB Status[/b] — FORMING (still within the ORB time window) or SET (locked, breakout mode active). Orange when SET
[*][b]ORB Hi / Lo[/b] — the exact opening range high and low prices once the range is locked
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — higher timeframe EMA alignment: ▲ BULL, ▼ BEAR, or — FLAT
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull Score[/b] — live 0–7 score. Background highlights yellow-green when threshold is met
[*][b]Bear Score[/b] — live 0–7 score. Background highlights red when threshold is met
[/list]

[b]Live confluence label:[/b] During active sessions, a small label near the session box displays [b]B x/7 · S x/7[/b] in real time, updated every bar — identical to ANCHOR, PIVOT, and the other systems in the AlphaX suite.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Current Session Box[/b] — a lightly tinted box covering the full range of the active session from its first bar to the current bar. Gray for Asian, yellow-green tinted for London, red tinted for New York
[*][b]Session VWAP (cyan)[/b] — the volume-weighted average price anchored to the session start, plotted as a solid cyan line. The most important intraday reference for institutional fair value
[*][b]Session Meridian (purple dots)[/b] — the session range midpoint (50% of the current session's high-low range), continuously updated
[*][b]Prior Session High (red dashed)[/b] — the completed prior session's high. Setup A reference level for long setups
[*][b]Prior Session Low (yellow-green dashed)[/b] — the prior session's low. Setup A reference level for short setups
[*][b]Prior Session Meridian (purple dotted)[/b] — the midpoint of the prior session's range
[*][b]Opening Range Box (orange tinted)[/b] — the locked ORB from the session start to the end of the opening range period. Setup B reference box
[*][b]● Break markers (semi-transparent circles)[/b] — appear above the bar (prior high break) or below (prior low break) at the moment of the structural break, signaling a pending retest opportunity
[*][b]▲ Triangle (below bar, yellow-green)[/b] — long signal. All conditions confirmed across any of the three setup types
[*][b]▼ Triangle (above bar, red)[/b] — short signal
[*][b]Live confluence label[/b] — B x/7 · S x/7 near the current session range on the last bar
[*][b]SL Guide (red dotted circles)[/b] — session-anchored stop loss reference level
[*][b]TP Guide (yellow-green dotted circles)[/b] — dynamically computed reward target
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX MERIDIAN — Step by Step[/b]

[b]Step 1 — Begin Each Session with a Reference Review[/b]
[list]
[*]At the start of each London or NY session, check the dashboard for Prior Hi / Lo — these are your key Setup A reference levels for the session
[*]Note the ORB Status — during the first 30 minutes of London or NY, watch the ORB forming. The ORB Hi / Lo will be your Setup B breakout reference once SET
[*]Check HTF Bias — does the higher timeframe trend favor longs or shorts? This is the filter that determines which direction's signals you prioritize
[/list]

[b]Step 2 — Monitor Session Bias Development[/b]
[list]
[*]As the session opens and develops, watch the VWAP Bias and Meridian rows on the dashboard. When both show ▲ ABOVE, the session bias is fully bullish — prioritize long setups. Both ▼ BELOW = prioritize shorts
[*]Watch the live B/S score label near the session box. When the bull or bear score approaches the threshold, a signal may be imminent
[/list]

[b]Step 3 — Enter on the MERIDIAN Signal[/b]
[list]
[*]A ▲ triangle below the bar confirms one of the three setup types has fired with sufficient confluence
[*]Read the signal context: did price just retest the prior session high? Break the ORB? Bounce from the session meridian? The setup type determines which level your stop references
[*]The SL and TP guides appear as dotted circles. The SL is the session-anchored structural stop. The TP is the R-multiple target
[*]Setup A retests are the highest-quality entries — the prior session level has been validated as the new support/resistance. Setup B ORB breaks are highest-momentum. Setup C meridian bounces are best in strongly trending sessions
[/list]

[b]Step 4 — Manage Within the Session Context[/b]
[list]
[*]Watch the session VWAP as the trade develops — price returning to VWAP during a long trade is a warning sign that session bias may be weakening
[*]If the session meridian switches sides (price moves from above to below the session midpoint), the session bias has flipped. Consider tightening the stop or taking partial profit
[*]Session transitions are exits: if London closes while you are in a trade, the session reference levels will update to New York levels on the NY open. Reassess the position in the context of the new session
[/list]

[b]Step 5 — End of Session Reset[/b]
[list]
[*]At session end, the current session's high, low, and meridian become the prior session reference for the next session
[*]The ORB resets for the new session's opening
[*]Review the completed session's range and meridian before the next session opens — these become your Setup A reference levels going forward
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Session shows OFF[/b] — no active session is being tracked. All signals are blocked and session reference levels may be stale
[*][b]Session bias is split — VWAP and Meridian disagree[/b] — price above VWAP but below the session meridian (or vice versa) means the session has no clear institutional direction. The combined session bias layer will not score, reducing confluence quality
[*][b]HTF Bias opposes the session bias[/b] — a bullish session bias against a bearish HTF means the current session is moving counter to the macro trend. These setups carry significantly higher reversal risk
[*][b]ORB Status shows FORMING[/b] — the opening range has not been locked. No Setup B signals can fire. Do not anticipate the ORB breakout before the range is set
[*][b]Prior Hi / Lo shows — on the dashboard[/b] — no completed prior session data is available. Setup A setups cannot fire. This occurs at the start of the first session after the chart loads
[*][b]Confluence score is at minimum threshold exactly[/b] — when the score is at exactly the minimum and one or two filters are failing, the setup is borderline. Reduce position size or wait for a higher-quality signal
[*][b]Multiple setup types firing simultaneously in the same direction[/b] — this is usually a positive signal, but verify the session context. If the ORB breakout, prior session retest, and meridian bounce are all triggering at the same time in the same bar, one of them is likely being triggered by coincidental price overlap rather than genuine session mechanics
[/list]

[b]The ideal MERIDIAN setup:[/b]
[list]
[*]London or NY session active with tradeSessOk confirmed
[*]HTF Bias and Session Bias both aligned in the same direction
[*]Prior session high or low recently broken (Setup A pending) OR ORB locked and ready for Setup B
[*]Price returning to the reference level with VWAP and Meridian both on the correct side
[*]Strong rejection candle with volume above average
[*]Confluence score at 6/7 or 7/7
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🌐 Three-session tracking engine — Asian, London, and New York sessions tracked simultaneously with configurable start/end hours and timezone support
[*]📊 Session-anchored VWAP — true cumulative VWAP computed from the first bar of each session, providing the most accurate institutional fair value reference per session
[*]📍 Prior session levels — high, low, and meridian of the most recently completed session maintained and displayed as dashed reference lines
[*]📦 Opening Range Box — first N minutes of London/NY captured as an orange ORB box with live FORMING / SET status. Breakout reference for Setup B
[*]⚖ Session Meridian (Equilibrium) — the session range midpoint plotted as a purple dotted line, the equilibrium level for Setup C bounces and the combined session bias divider
[*]🏷 Three setup types — Setup A (Prior Session Break & Retest), Setup B (Opening Range Breakout), Setup C (Meridian Bounce) — all configurable independently
[*]🔮 Pending retest tracking — 30-bar retest window after every prior session break, with break circle markers at the moment of the structural break
[*]🧠 7-layer confluence engine — Session Bias, VWAP Position, HTF Bias, Trading Session Gate, Volume Expansion, Rejection Candle, and Setup Type Trigger scored independently every bar
[*]📊 Live confluence label near the session box — B x/7 · S x/7 updating in real time on the current bar
[*]🎯 Session-anchored stop loss — stop placed at the most conservative of multiple session reference levels, not a fixed ATR distance
[*]💹 Dynamic R-multiple TP target — computed as risk × R multiple, adapting to the actual stop distance
[*]📡 HTF EMA bias filter — dual-condition higher timeframe alignment (EMA crossover + price confirmation)
[*]⏱ Session trading filter — independently enable or disable signal firing for each of the three sessions
[*]🎨 Session-coded color system — session box tints differentiate Asian (gray), London (yellow-green), and New York (red) at a glance
[*]📊 16-row live dashboard — Session, Prior Session, Opening Range, Filters, and Confluence sections updated in real time
[*]🔔 6 alert conditions — long/short entry, prior high/low break, ORB long/short breakout
[*]⚙ Fully configurable — all session hours, timezone, ORB duration, setup type enables, confluence minimum, HTF timeframe and EMAs, volume filter, session trading gates, SL buffer, R-multiple target, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Session Engine[/b]
[list]
[*]Session Timezone — UTC / America/New_York / Europe/London / Asia/Tokyo. Set to your preferred reference timezone
[*]Track Asian Session — toggle Asian session tracking on or off
[*]Asian Start / End (hour) — hour boundaries for the Asian session in the selected timezone (defaults: 0 / 8)
[*]Track London Session — toggle London session tracking
[*]London Start / End (hour) — hour boundaries for London (defaults: 8 / 13)
[*]Track NY Session — toggle New York session tracking
[*]NY Start / End (hour) — hour boundaries for NY (defaults: 13 / 21)
[*]Opening Range (mins) — the number of minutes from the session open used to build the ORB (default: 30)
[/list]

[b]Entries & Confluence[/b]
[list]
[*]Setup A · Prior Session Break & Retest — toggle the break-and-retest setup type
[*]Setup B · Opening Range Breakout — toggle the ORB breakout setup type
[*]Setup C · Meridian Bounce — toggle the session equilibrium bounce setup type
[*]Retest Tolerance (xATR) — maximum ATR distance from the reference level that still qualifies as a retest (default: 0.35)
[*]Min Confluence Layers (of 7) — minimum score to fire a signal (default: 5)
[*]Show Entry Signals — toggle signal triangles
[*]Show Confluence Label — toggle the live B/S score label near the session box
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 6)
[/list]

[b]Filters[/b]
[list]
[*]HTF Trend Filter — toggle the higher timeframe EMA alignment requirement
[*]HTF Timeframe — the higher timeframe for EMA data (default: 60-minute)
[*]HTF Fast / Slow EMA — EMA periods on the HTF (defaults: 21 / 55)
[*]Volume Confirm — when on, entry volume must exceed the average by the minimum multiplier
[*]Min Volume vs Avg — minimum volume ratio (default: 1.1)
[*]Volume Avg Length — SMA length for volume baseline (default: 20)
[*]Trade London Session — when on, signals can fire during London hours
[*]Trade NY Session — when on, signals can fire during NY hours
[*]Trade Asian Session — when on, signals can fire during Asian hours (default: off — Asian sessions typically produce lower-quality setups)
[/list]

[b]Exit Guidance[/b]
[list]
[*]ATR Length — ATR calculation lookback (default: 14)
[*]Show SL / TP Guides — toggle stop and target dotted circle plots
[*]SL Distance (xATR) — ATR buffer added beyond the session-anchored stop reference (default: 1.0)
[*]TP Reward (R) — take profit as a multiple of the actual risk from entry to stop (default: 2.5)
[/list]

[b]Display[/b]
[list]
[*]Show Current Session Box — toggle the session range box
[*]Show Prior Session H/L — toggle prior session high, low, and meridian dashed lines
[*]Show Session VWAP — toggle the session VWAP line
[*]Show Opening Range Box — toggle the ORB orange box
[*]Show Dashboard — toggle the full dashboard panel
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish signals and London session elements
[*]Bear / Bear Bright — red family for all bearish signals and NY session elements
[*]Opening Range — orange for ORB box and status indicators
[*]Meridian / EQ — purple for session meridian, prior session meridian, and equilibrium elements
[*]Session VWAP — cyan for the session VWAP line
[*]SL Guide / TP Guide — stop and target circle colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (6 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Meridian Long — all conditions confirmed. Long signal fired
[*]Meridian Short — all conditions confirmed. Short signal fired
[/list]

[b]Structure Alerts[/b]
[list]
[*]Meridian Break Prior High — price has closed above the prior session high. Setup A long retest window is now active — watch for the retest
[*]Meridian Break Prior Low — price has closed below the prior session low. Setup A short retest window is now active
[/list]

[b]Opening Range Alerts[/b]
[list]
[*]Meridian ORB Long — opening range broken to the upside with all setup and confluence conditions confirmed
[*]Meridian ORB Short — opening range broken to the downside with all conditions confirmed
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and indices on M5–M15[/b] in UTC timezone:
[list]
[*]Session hours in UTC — gold and forex are most active during London (08:00–13:00) and NY (13:00–21:00) hours. Asian session trading is disabled by default for clean intraday setups
[*]ORB at 30 minutes — the classic institutional opening range. The first 30 minutes of London and NY frequently establish the session's directional commitment
[*]Retest tolerance at 0.35× ATR — sensitive enough to catch genuine retests on M5–M15 without requiring price to tick exactly at the level
[*]TP Reward at 2.5R — session-based setups on gold and forex typically produce moves sufficient to achieve 2.5R when the session bias is correctly identified
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Cooldown to 3, reduce SL Buffer to 0.5, reduce TP Reward to 1.5–2.0, use tighter Retest Tolerance at 0.2
[*][b]H1 intraday swing[/b] — increase ORB to 60 minutes (capturing the first full H1 candle), increase Retest Tolerance to 0.5, increase TP Reward to 3.5–4.0, set HTF to H4 or Daily
[*][b]Crypto (BTC, ETH)[/b] — use UTC timezone, enable all three sessions (crypto trades 24/7), reduce retest tolerance to 0.25 for the narrower wicks typical of crypto support/resistance retests
[*][b]Indices (NAS100, US30)[/b] — focus exclusively on NY session (13:30–20:00 UTC for US equity cash session), disable London trading for equity index instruments, tighten ORB to 15 minutes (the US equity opening range is frequently set in the first 15 minutes)
[*][b]More signals[/b] — lower Min Confluence to 4, enable Asian trading, disable volume filter
[*][b]Highest-quality only[/b] — raise Min Confluence to 6–7, enable only Setup A and B (disable meridian bounce), require London and NY only
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]⏱ [b]Session traders and market structure players[/b] — MERIDIAN is the definitive session intelligence system. Every reference level, every bias indicator, and every signal type is anchored to the session clock
[*]🥇 [b]Gold (XAUUSD) and forex intraday traders[/b] — the three-session framework is most powerful on instruments where London and New York session transitions drive the most significant intraday moves. Default settings are calibrated for gold and major forex pairs
[*]📊 [b]Opening range traders[/b] — the ORB system provides a complete, rules-based opening range breakout framework with confluence scoring, volume confirmation, and rejection candle quality filtering
[*]🎯 [b]Break-and-retest traders[/b] — Setup A is the quantitative implementation of the prior session break and retest — the most reliable institutional intraday pattern across all liquid markets
[*]🧠 [b]Traders who use VWAP as a primary reference[/b] — the session-anchored VWAP and the VWAP-based bias scoring system make MERIDIAN the ideal companion for any VWAP-centric trading approach
[*]📈 [b]Traders who want session context on every trade[/b] — every signal label, every dashboard row, and every reference level in MERIDIAN tells you exactly where you are in the session cycle and what the institutional context is
[*]⚠ [b]Traders who struggle with time-of-day discipline[/b] — the session trading gates (enable/disable individual sessions) enforce time-of-day discipline automatically. If you do not trade the Asian session, disable it and no Asian signals will ever appear
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Session state, VWAP, meridian, ORB values, and confluence scoring all finalize on confirmed bars only
[*]The session boxes and prior session lines are redrawn on the last bar only for chart performance. On very fast timeframes with long chart history, this redraw happens on every new bar's render — this is normal behavior for last-bar-only visual updates
[*]The VWAP is a true session-anchored VWAP — it resets at each session's first bar and accumulates correctly through the entire session. It is not a daily VWAP or a rolling VWAP
[*]The prior session data updates at session transitions. On the very first session after the chart loads, no prior session data may be available — the Prior Hi / Lo dashboard rows will show — until the first session completes
[*]The 30-bar retest window for Setup A (prior session break and retest) starts from the bar of the break. If no retest occurs within 30 bars, the pending retest state expires. On slower timeframes (H1), 30 bars may cover many hours — consider reducing the window or accepting that H1 retests sometimes take longer to develop
[*]Maximum 500 labels, 500 lines, and 50 boxes are rendered. With three sessions each potentially drawing boxes and lines, the limit is practically sufficient for standard chart history. On very long chart histories on very fast timeframes, the oldest visual elements may be removed by TradingView's rendering limits
[*]The session timezone setting must match the timezone in which you want session boundaries defined. UTC is the default and recommended for instruments that trade globally. For US equity index traders, America/New_York may be more intuitive
[*]The indicator does not connect to any broker or account — the dashboard and signals are purely analytical
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that the market tells a different story in every session — and who want a system that reads each chapter in real time.[/i]

## Source Code

````pine
// © AlphaX — MERIDIAN v1.0
// Session Intelligence Engine: multi-session ranges, VWAP, meridian EQ & break-retest entries.
// AlphaX branded — styled after ANCHOR.

//@version=6
indicator("[ A L P H A X ] MERIDIAN - Session Intelligence Engine", shorttitle="AlphaX MERIDIAN",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  SESSION ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpSess = "Session Engine"
tzInput     = input.string("UTC", "Session Timezone", options=["UTC", "America/New_York", "Europe/London", "Asia/Tokyo"], group=grpSess)
asianOn     = input.bool(true,  "Track Asian Session",   group=grpSess)
asianStart  = input.int(0,  "Asian Start (hour)",  minval=0, maxval=23, group=grpSess)
asianEnd    = input.int(8,  "Asian End (hour)",    minval=1, maxval=24, group=grpSess)
londonOn    = input.bool(true,  "Track London Session", group=grpSess)
londonStart = input.int(8,  "London Start (hour)", minval=0, maxval=23, group=grpSess)
londonEnd   = input.int(13, "London End (hour)",   minval=1, maxval=24, group=grpSess)
nyOn        = input.bool(true,  "Track NY Session",      group=grpSess)
nyStart     = input.int(13, "NY Start (hour)",     minval=0, maxval=23, group=grpSess)
nyEnd       = input.int(21, "NY End (hour)",       minval=1, maxval=24, group=grpSess)
orbMins     = input.int(30, "Opening Range (mins)", minval=5, maxval=120, group=grpSess,
  tooltip="First N minutes of London/NY = opening range for breakout setup.")

// ═══════════════════════════════════════════════════════════════════════════════
//  ENTRIES & CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════════
grpEntry = "Entries & Confluence"
enableBreakRetest = input.bool(true, "Setup A · Prior Session Break & Retest", group=grpEntry,
  tooltip="Break prior session high/low, then enter on hold/reclaim of that level.")
enableOrbBreak    = input.bool(true, "Setup B · Opening Range Breakout", group=grpEntry,
  tooltip="Break the first N minutes of London/NY, enter on momentum close.")
enableMeridianBnc = input.bool(true, "Setup C · Meridian Bounce", group=grpEntry,
  tooltip="Trending session: pullback to 50% meridian + rejection candle.")
retestAtrTol      = input.float(0.35, "Retest Tolerance (xATR)", minval=0.1, maxval=1.5, step=0.05, group=grpEntry)
minConf           = input.int(5, "Min Confluence Layers (of 7)", minval=4, maxval=7, group=grpEntry)
showSignals       = input.bool(true, "Show Entry Signals", group=grpEntry)
showConfLbl       = input.bool(true, "Show Confluence Label", group=grpEntry)
cooldown          = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpEntry)

// ═══════════════════════════════════════════════════════════════════════════════
//  FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
grpFilt = "Filters"
useHtf      = input.bool(true, "HTF Trend Filter", group=grpFilt)
htfTf       = input.timeframe("60", "HTF Timeframe", group=grpFilt)
htfFast     = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpFilt)
htfSlow     = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpFilt)
useVol      = input.bool(true, "Volume Confirm", group=grpFilt)
volMult     = input.float(1.1, "Min Volume vs Avg", minval=0.8, maxval=3.0, step=0.1, group=grpFilt)
volLen      = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpFilt)
tradeLondon = input.bool(true, "Trade London Session", group=grpFilt)
tradeNy     = input.bool(true, "Trade NY Session", group=grpFilt)
tradeAsian  = input.bool(false, "Trade Asian Session", group=grpFilt)

// ═══════════════════════════════════════════════════════════════════════════════
//  EXIT GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
grpExit = "Exit Guidance"
atrLen      = input.int(14, "ATR Length", minval=2, maxval=100, group=grpExit)
showExits   = input.bool(true, "Show SL / TP Guides", group=grpExit)
slAtrMult   = input.float(1.0, "SL Distance (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpExit)
tpRR        = input.float(2.5, "TP Reward (R)", minval=0.5, maxval=20, step=0.5, group=grpExit)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
showSessBox   = input.bool(true, "Show Current Session Box", group=grpVis)
showPriorLvls = input.bool(true, "Show Prior Session H/L", group=grpVis)
showSessVwap  = input.bool(true, "Show Session VWAP", group=grpVis)
showOrbBox    = input.bool(true, "Show Opening Range Box", group=grpVis)
showDash      = input.bool(true, "Show Dashboard", group=grpVis)
dashPos       = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

// ═══════════════════════════════════════════════════════════════════════════════
//  COLORS (ANCHOR palette)
// ═══════════════════════════════════════════════════════════════════════════════
grpColors = "Colors"
colBull       = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear       = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze    = input.color(#ff9800, "Opening Range",      group=grpColors)
colNeutral    = input.color(#555555, "Neutral",            group=grpColors)
colEqLine     = input.color(#8b6fd0, "Meridian / EQ",      group=grpColors)
colVwap       = input.color(#00bcd4, "Session VWAP",       group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec    = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_inSession(int h, int startH, int endH) =>
    startH < endH ? (h >= startH and h < endH) : (h >= startH or h < endH)

f_sessName(int id) =>
    id == 0 ? "ASIAN" : id == 1 ? "LONDON" : id == 2 ? "NEW YORK" : "OFF"

// ═══════════════════════════════════════════════════════════════════════════════
//  SESSION STATE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)
rng    = math.max(high - low, syminfo.mintick)

hNow = hour(time, tzInput)
mNow = minute(time, tzInput)

bool inAsian  = asianOn  and f_inSession(hNow, asianStart,  asianEnd)
bool inLondon = londonOn and f_inSession(hNow, londonStart, londonEnd)
bool inNy     = nyOn     and f_inSession(hNow, nyStart,     nyEnd)

int sessId = inAsian ? 0 : inLondon ? 1 : inNy ? 2 : 3

var int   prevSessId    = 3
bool sessChange = sessId != prevSessId and sessId != 3
bool sessStart  = sessChange or (sessId != 3 and prevSessId == 3)

// Current session OHLC + VWAP + meridian
var float curHi    = na
var float curLo    = na
var float curOpen  = na
var float curMer   = na
var int   curStart = na
var float vwapNum  = 0.0
var float vwapDen  = 0.0
var float sessVwap = na

// Prior completed session
var float priorHi  = na
var float priorLo  = na
var float priorMer = na
var int   priorId  = na

// Opening range (London/NY only)
var float orbHi    = na
var float orbLo    = na
var int   orbStart = na
var bool  orbDone  = false
var int   orbEndBar = na

if sessStart and sessId != 3
    if sessChange and sessId != 3 and prevSessId != 3 and not na(curHi)
        priorHi  := curHi
        priorLo  := curLo
        priorMer := curMer
        priorId  := prevSessId
    curHi   := high
    curLo   := low
    curOpen := open
    curStart := bar_index
    vwapNum := hlc3 * volume
    vwapDen := volume
    sessVwap := hlc3
    orbHi   := high
    orbLo   := low
    orbStart := bar_index
    orbDone := false
    orbEndBar := na
else if sessId != 3
    curHi  := math.max(curHi, high)
    curLo  := math.min(curLo, low)
    curMer := (curHi + curLo) / 2.0
    vwapNum += hlc3 * volume
    vwapDen += volume
    sessVwap := vwapDen > 0 ? vwapNum / vwapDen : sessVwap
    if (sessId == 1 or sessId == 2) and not orbDone
        int minsIn = (hNow - (sessId == 1 ? londonStart : nyStart) + 24) % 24 * 60 + mNow
        if minsIn <= orbMins
            orbHi := math.max(orbHi, high)
            orbLo := math.min(orbLo, low)
        else if na(orbEndBar)
            orbEndBar := bar_index
            orbDone := true

prevSessId := sessId

bool tradeSessOk = (sessId == 0 and tradeAsian) or (sessId == 1 and tradeLondon) or (sessId == 2 and tradeNy)

// ── HTF ───────────────────────────────────────────────────────────────────────
htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
htfOKLong  = not useHtf or htfBull
htfOKShort = not useHtf or htfBear
volOK = not useVol or volume >= volMa * volMult

// ── Session bias ──────────────────────────────────────────────────────────────
aboveVwap = not na(sessVwap) and close > sessVwap
belowVwap = not na(sessVwap) and close < sessVwap
aboveMer  = not na(curMer) and close > curMer
belowMer  = not na(curMer) and close < curMer
sessBull  = aboveVwap and aboveMer
sessBear  = belowVwap and belowMer

// ── Candle triggers ───────────────────────────────────────────────────────────
bullTrig = close > open and (close - low) / rng > 0.5
bearTrig = close < open and (high - close) / rng > 0.5

// ── Setup A: prior session break & retest ─────────────────────────────────────
float tol = atrVal * retestAtrTol
bool brokePriorHi = not na(priorHi) and close > priorHi and close[1] <= priorHi
bool brokePriorLo = not na(priorLo) and close < priorLo and close[1] >= priorLo

var bool pendingRetestLong  = false
var bool pendingRetestShort = false
var int  breakBarLong  = na
var int  breakBarShort = na

if brokePriorHi
    pendingRetestLong  := true
    breakBarLong := bar_index
if brokePriorLo
    pendingRetestShort := true
    breakBarShort := bar_index

if pendingRetestLong and bar_index - nz(breakBarLong, 0) > 30
    pendingRetestLong := false
if pendingRetestShort and bar_index - nz(breakBarShort, 0) > 30
    pendingRetestShort := false

bool retestLong  = pendingRetestLong and not na(priorHi) and low <= priorHi + tol and close > priorHi and bullTrig
bool retestShort = pendingRetestShort and not na(priorLo) and high >= priorLo - tol and close < priorLo and bearTrig

if retestLong
    pendingRetestLong := false
if retestShort
    pendingRetestShort := false

// ── Setup B: opening range breakout ───────────────────────────────────────────
bool orbBreakLong  = orbDone and not na(orbHi) and close > orbHi and close[1] <= orbHi and bullTrig
bool orbBreakShort = orbDone and not na(orbLo) and close < orbLo and close[1] >= orbLo and bearTrig

// ── Setup C: meridian bounce ──────────────────────────────────────────────────
bool merBounceLong  = sessBull and not na(curMer) and low <= curMer + tol and close > curMer and bullTrig
bool merBounceShort = sessBear and not na(curMer) and high >= curMer - tol and close < curMer and bearTrig

// ═══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE (7 layers)
// ═══════════════════════════════════════════════════════════════════════════════
int bullScore = (sessBull ? 1 : 0) + (aboveVwap ? 1 : 0) + (htfOKLong ? 1 : 0) +
     (tradeSessOk ? 1 : 0) + (volOK ? 1 : 0) + (bullTrig ? 1 : 0) +
     ((retestLong or orbBreakLong or merBounceLong) ? 1 : 0)
int bearScore = (sessBear ? 1 : 0) + (belowVwap ? 1 : 0) + (htfOKShort ? 1 : 0) +
     (tradeSessOk ? 1 : 0) + (volOK ? 1 : 0) + (bearTrig ? 1 : 0) +
     ((retestShort or orbBreakShort or merBounceShort) ? 1 : 0)

setupLong  = (enableBreakRetest and retestLong) or (enableOrbBreak and orbBreakLong) or (enableMeridianBnc and merBounceLong)
setupShort = (enableBreakRetest and retestShort) or (enableOrbBreak and orbBreakShort) or (enableMeridianBnc and merBounceShort)

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

bool bullSignal = showSignals and barstate.isconfirmed and setupLong and bullScore >= minConf and cooled and volOK
bool bearSignal = showSignals and barstate.isconfirmed and setupShort and bearScore >= minConf and cooled and volOK

if bullSignal or bearSignal
    lastSigBar := bar_index

float slGuide = na
float tpGuide = na
if bullSignal
    slGuide := math.min(low, nz(priorHi, low), nz(orbLo, low), nz(curMer, low)) - slAtrMult * atrVal
    float risk = close - slGuide
    tpGuide := risk > 0 ? close + risk * tpRR : close + atrVal * tpRR
if bearSignal
    slGuide := math.max(high, nz(priorLo, high), nz(orbHi, high), nz(curMer, high)) + slAtrMult * atrVal
    float riskS = slGuide - close
    tpGuide := riskS > 0 ? close - riskS * tpRR : close - atrVal * tpRR

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS (last bar draw = clean chart)
// ═══════════════════════════════════════════════════════════════════════════════
var box  sessBox = na
var box  orbBox  = na
var line lnPriorHi = na
var line lnPriorLo = na
var line lnPriorMer = na

if barstate.islast
    if not na(sessBox)
        box.delete(sessBox)
        sessBox := na
    if not na(orbBox)
        box.delete(orbBox)
        orbBox := na
    if not na(lnPriorHi)
        line.delete(lnPriorHi)
        lnPriorHi := na
    if not na(lnPriorLo)
        line.delete(lnPriorLo)
        lnPriorLo := na
    if not na(lnPriorMer)
        line.delete(lnPriorMer)
        lnPriorMer := na

    if showSessBox and sessId != 3 and not na(curStart)
        color sCol = sessId == 0 ? color.new(colNeutral, 70) : sessId == 1 ? color.new(colBull, 75) : color.new(colBearBr, 75)
        sessBox := box.new(curStart, curHi, bar_index, curLo, border_color=sCol, bgcolor=color.new(colEqLine, 93), border_width=1)

    if showOrbBox and orbDone and not na(orbStart) and not na(orbHi)
        orbBox := box.new(orbStart, orbHi, nz(orbEndBar, bar_index), orbLo,
          border_color=color.new(colSqueeze, 50), bgcolor=color.new(colSqueeze, 90), border_width=1)

    if showPriorLvls and not na(priorHi)
        lnPriorHi := line.new(bar_index - 80, priorHi, bar_index + 5, priorHi,
          color=color.new(colBear, 45), style=line.style_dashed, width=1)
        lnPriorLo := line.new(bar_index - 80, priorLo, bar_index + 5, priorLo,
          color=color.new(colBull, 45), style=line.style_dashed, width=1)
        lnPriorMer := line.new(bar_index - 80, priorMer, bar_index + 5, priorMer,
          color=color.new(colEqLine, 35), style=line.style_dotted, width=1)

plot(showSessVwap and sessId != 3 ? sessVwap : na, "Session VWAP", color=color.new(colVwap, 25), linewidth=2, style=plot.style_linebr)
plot(sessId != 3 and not na(curMer) ? curMer : na, "Session Meridian", color=color.new(colEqLine, 40), linewidth=1, style=plot.style_linebr)

plot(showExits and not na(slGuide) ? slGuide : na, "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(tpGuide) ? tpGuide : na, "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)

plotshape(bullSignal, title="Meridian Long", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.small)
plotshape(bearSignal, title="Meridian Short", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.small)

plotshape(brokePriorHi, title="Break Prior Hi", style=shape.circle, location=location.abovebar,
  color=color.new(colBullBr, 50), size=size.tiny)
plotshape(brokePriorLo, title="Break Prior Lo", style=shape.circle, location=location.belowbar,
  color=color.new(colBearBr, 50), size=size.tiny)

if showConfLbl and barstate.islast and sessId != 3
    string confTxt = "B " + str.tostring(bullScore) + "/7  ·  S " + str.tostring(bearScore) + "/7"
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    float lblY = close > nz(curMer, close) ? curLo - atrVal * 0.5 : curHi + atrVal * 0.5
    label.new(bar_index, lblY, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 16,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX MERIDIAN", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── SESSION ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    string sTxt = f_sessName(sessId)
    color  sClr = sessId == 1 ? colBull : sessId == 2 ? colBearBr : sessId == 0 ? colNeutral : colNeutral
    table.cell(dash, 0, 2, "ACTIVE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, sTxt, text_color=sClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "VWAP BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, aboveVwap ? "▲ ABOVE" : belowVwap ? "▼ BELOW" : "—",
      text_color=aboveVwap ? colBull : belowVwap ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "MERIDIAN", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, not na(curMer) ? str.tostring(curMer, format.mintick) : "—",
      text_color=colEqLine, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── PRIOR SESSION ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    table.cell(dash, 0, 6, "PRIOR SESS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, not na(priorId) ? f_sessName(priorId) : "—",
      text_color=colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 7, "PRIOR HI / LO", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, not na(priorHi) ? str.tostring(priorHi, format.mintick) + " / " + str.tostring(priorLo, format.mintick) : "—",
      text_color=colTextLt, text_size=size.tiny, bgcolor=dbg)

    table.cell(dash, 0, 8, "─── OPENING RANGE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 8, "", bgcolor=secBg)

    table.cell(dash, 0, 9, "ORB STATUS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, orbDone ? "SET" : (sessId == 1 or sessId == 2) ? "FORMING" : "—",
      text_color=orbDone ? colSqueeze : colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "ORB HI / LO", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, not na(orbHi) ? str.tostring(orbHi, format.mintick) + " / " + str.tostring(orbLo, format.mintick) : "—",
      text_color=colSqueeze, text_size=size.tiny, bgcolor=dbg)

    table.cell(dash, 0, 11, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 11, "", bgcolor=secBg)

    table.cell(dash, 0, 12, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 13, "", bgcolor=secBg)

    table.cell(dash, 0, 14, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 14, str.tostring(bullScore) + "/7" + (bullScore >= minConf ? " ✓" : ""),
      text_color=bullScore >= minConf ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 15, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 15, str.tostring(bearScore) + "/7" + (bearScore >= minConf ? " ✓" : ""),
      text_color=bearScore >= minConf ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="Meridian Long",
  message="[AlphaX MERIDIAN] LONG — session setup fired on {{ticker}} {{interval}}")
alertcondition(bearSignal, title="Meridian Short",
  message="[AlphaX MERIDIAN] SHORT — session setup fired on {{ticker}} {{interval}}")
alertcondition(brokePriorHi, title="Meridian Break Prior High",
  message="[AlphaX MERIDIAN] Prior session high broken — watch for retest long.")
alertcondition(brokePriorLo, title="Meridian Break Prior Low",
  message="[AlphaX MERIDIAN] Prior session low broken — watch for retest short.")
alertcondition(orbBreakLong, title="Meridian ORB Long",
  message="[AlphaX MERIDIAN] Opening range breakout long.")
alertcondition(orbBreakShort, title="Meridian ORB Short",
  message="[AlphaX MERIDIAN] Opening range breakout short.")
````
