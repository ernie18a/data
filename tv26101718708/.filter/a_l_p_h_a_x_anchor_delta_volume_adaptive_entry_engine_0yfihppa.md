# [ A L P H A X ] ANCHOR Delta Volume Adaptive Entry Engine

- url: https://www.tradingview.com/script/0YfihPPa-A-L-P-H-A-X-ANCHOR-Delta-Volume-Adaptive-Entry-Engine/
- type: indicator
- pine_id: PUB;a6b2eb6ee92d470b8074cf07537a56e4
- version: 1.0

## Description

[b]AlphaX ANCHOR — Liquidity-Anchored Trailing Stop System with Delta Volume Profile, Adaptive Band Scaling, HVN Confluence & 6-Layer Entry Engine[/b]

AlphaX ANCHOR is a professional-grade trend-following and entry precision system built around a proprietary four-band liquidity-anchored trailing stop engine that adapts to volatility in real time. Where conventional trailing stops use a fixed ATR distance and flip on any close beyond it, ANCHOR builds a structured four-layer band system that breathes with market conditions — tightening automatically during low-volatility squeeze phases and expanding during expansion phases — while simultaneously computing a delta-weighted volume profile anchored to the current trend segment. The result is a system that does three things simultaneously: tells you the trend direction with structural confidence, shows you exactly where the institutional volume is concentrated within the current move, and fires precision entries only when price returns to the outer anchor band within a qualifying 6-layer confluence environment. Designed for swing traders, position traders, and trend-following scalpers across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚓ [b]The Anchor Trail Engine — How It Works[/b]

The core of AlphaX ANCHOR is the [b]four-band liquidity-anchored trailing stop system[/b] — a structured set of concentric ATR bands that trail price in the trend direction, each band serving a distinct role in the trade management framework.

[b]Band architecture:[/b]
[list]
[*][b]Band 1 (Inner)[/b] — the closest band to price. Set at the base multiplier × ATR distance (default: 6.5×). Acts as the tightest stop reference — for aggressive traders who want minimal drawdown and are willing to accept more noise exits
[*][b]Band 2 (Mid-Inner)[/b] — base + 1.0× ATR additional offset. The intermediate reference zone
[*][b]Band 3 (Mid-Outer)[/b] — base + 2.0× ATR additional offset. Structural breathing room for normal pullbacks
[*][b]Band 4 (Anchor — Outer)[/b] — base + 3.0× ATR additional offset. The primary trend invalidation level. A close beyond this band flips the trend. This is the band the confluence engine watches for retest entries
[/list]

[b]Trailing mechanics:[/b]
In a bull trend, all four bands trail price upward — ratcheting higher with every bar that closes higher, never moving down. The trail is one-directional: in a bull trend, bands can only move up; in a bear trend, bands can only move down. This ratchet behavior prevents the bands from widening on pullbacks — once a level is established, price must return all the way to Band 4 before a trend flip is triggered. This single property is what makes ANCHOR bands structurally superior to simple ATR trailing stops: they do not exit on noise, only on genuine structural breakdowns.

[b]Trend flip logic:[/b]
A trend flip occurs when the source price closes beyond Band 4 — the outer anchor level. On the flip bar, all four bands immediately reset to the opposite side of price at their respective ATR distances. A ▲ ANCHOR BULL or BEAR ▼ ANCHOR label marks every flip on the chart, giving you clear visual confirmation of every structural trend change.

[b]Heatmap visualization:[/b]
When the Trailing Stop Heatmap is enabled, the space between all four bands is filled with gradient color layers — progressively more opaque from Band 1 to Band 4. This creates an immediate visual depth map of the trailing stop structure: the closer price is to Band 4, the deeper into the "danger zone" the pullback has penetrated. At a glance, you can see whether a pullback is shallow (barely in the inner fill) or deep (approaching the outer anchor line) without reading a single number.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌊 [b]Adaptive Band Scaling — Breathing With Volatility[/b]

Standard ATR trailing stops maintain a fixed multiplier regardless of whether the market is in a squeeze or an expansion phase. ANCHOR solves this with an [b]adaptive scaling system[/b] that continuously adjusts the effective band multiplier based on current volatility context.

[b]How it works:[/b]
The current ATR value is percentile-ranked over the last 100 bars using a percentrank function, producing a real-time volatility percentile reading. Additionally, the system monitors whether Bollinger Bands are compressed inside Keltner Channels — the squeeze condition.

[b]Three scaling states:[/b]
[list]
[*][b]Squeeze active (BB inside KC)[/b] — multiplier scales down to the Adaptive Min Scale (default: 0.85×). Bands tighten. During a squeeze, price movement is compressed and the natural pullback range is narrower — tighter bands correctly reflect this reduced volatility and avoid giving back gains unnecessarily when the market is coiling
[*][b]High volatility (ATR in top 75th percentile)[/b] — multiplier scales up to the Adaptive Max Scale (default: 1.15×). Bands widen. During expansion phases, price swings are larger and a wider band correctly avoids being stopped out by normal volatility noise
[*][b]Normal conditions[/b] — multiplier stays at 1.0× the base setting. No adjustment needed
[/list]

[b]Dashboard readout:[/b]
The current adaptive scale is displayed live on the dashboard as a multiplier value (e.g., 0.85x SQZ or 1.15x) in real time, so you always know whether the system is in tight, normal, or wide band mode.

[b]Why adaptive scaling matters:[/b] A fixed 6.5× ATR trailing stop is too wide during a squeeze and too tight during a volatility spike. Adaptive scaling means ANCHOR is always correctly sized for the current market environment — without any manual adjustment from you.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Delta-Weighted Volume Profile — Anchored to the Trend Segment[/b]

The volume profile in AlphaX ANCHOR is not a standard fixed-range profile. It is a [b]trend-segment-anchored profile[/b] — recomputed from the exact bar where the current trend began (the last Band 4 flip) to the current bar. Every time the trend flips, the profile resets and starts building fresh from the new trend origin.

[b]What this means in practice:[/b] The profile always shows you the volume distribution of the [i]current institutional delivery move[/i] — not an arbitrary date range, not the last N bars, but specifically the price levels where volume has concentrated since the institutional trend began. This is the most relevant possible volume profile for understanding the current trade's context.

[b]Delta weighting:[/b]
When Delta-Weighted Volume is enabled (default: on), each bar's contribution to the volume profile is adjusted by the estimated directional bias of that candle:
[list]
[*]In a bull trend — the bull volume estimate (close position within the high-low range × total volume) is used. Bullish candles contribute more weight to their price levels than bearish candles
[*]In a bear trend — the bear volume estimate is used. Bearish candles carry more weight
[/list]

This delta weighting creates a profile that reflects not just where volume occurred, but where [b]directionally committed volume[/b] occurred — the levels where buyers (in a bull trend) or sellers (in a bear trend) were most active. These are the genuine institutional accumulation and distribution zones, not just high-activity noise zones.

[b]Profile structure:[/b]
The profile is divided into a configurable number of rows (default: 30), each representing an equal price bin across the trend segment's high-low range. The width of each bar in the rendered profile is proportional to the volume in that bin relative to the maximum bin volume — the widest bar is always the highest-volume level.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 [b]POC, Value Area & HVN Detection[/b]

[b]Point of Control (POC):[/b]
The single price bin with the highest volume in the current trend segment. This is the price level where the most delta-weighted volume has traded since the trend began — the most liquid price in the current institutional move. Plotted as a solid purple line extending from the trend start to the right edge of the profile. The POC price is displayed live on the dashboard and is available as a take-profit target mode.

[b]Value Area High (VAH) and Value Area Low (VAL):[/b]
The price range containing a configurable percentage of total segment volume (default: 70%). The value area represents the zone where the market spent 70% of its time and volume — the institutional fair value range for the current trend segment. VAH is plotted as a dashed yellow-green line; VAL as a dashed red line. These levels act as natural support and resistance within the trend — price frequently respects VAH and VAL on pullbacks before continuing in the trend direction.

[b]High Volume Nodes (HVNs):[/b]
Local volume peaks within the profile — bins where volume is higher than both the bin immediately below and the bin immediately above. These are the [b]institutional congregation zones</b> — price levels where significant two-sided activity occurred. HVNs frequently act as magnets: price is attracted to them, and once reached, tends to spend time at them before continuing. Identified algorithmically across all bins, HVN levels are plotted as horizontal lines extending from the trend start, styled and colored by the configured settings. The highest-volume HVN receives a bold line and a price label.

[b]HVN confluence scoring:[/b]
The confluence engine awards 1 point when either the current close or the outer Band 4 level is within a tolerance of ±0.35× ATR of any HVN level. An entry that fires at the anchor band while simultaneously sitting at an HVN level means you are buying or selling at a level where the most institutional volume has transacted — a genuinely high-conviction entry location.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚖ [b]Trend Equilibrium — Premium/Discount Positioning[/b]

The [b]Trend Equilibrium line[/b] is the midpoint between the highest high and the lowest low since the current trend began (the trendHigh and trendLow of the segment). Plotted as a purple dotted line directly on the chart.

This level serves as the dynamic premium/discount divider for the current trend segment:
[list]
[*][b]Below equilibrium = discount[/b] — price is in the lower half of the trend segment range. For bull trends, this is the institutional accumulation zone — the preferred entry location for long positions
[*][b]Above equilibrium = premium[/b] — price is in the upper half of the range. For bear trends, this is the institutional distribution zone — the preferred entry location for short positions
[/list]

The [b]Require PD Zone[/b] setting enforces that long signals only fire when price is in discount and short signals only fire when price is in premium. This one filter alone eliminates a substantial class of low-quality entries — those that occur when price has already extended far from the segment midpoint and the risk/reward is structurally poor.

Unlike a fixed-range PD calculation, this equilibrium adapts dynamically to the current trend segment — it is always the midpoint of [i]this trend's</i> range, making it the most contextually accurate premium/discount reference available.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 6-Layer Confluence Engine[/b]

Entry signals fire only when price touches the outer Band 4 anchor level within a qualifying 6-layer confluence environment. Each layer votes independently. The default minimum is 4 of 6.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 1 — Anchor Trend Direction[/b]

Awards 1 point when the ANCHOR system's current trend direction agrees with the signal. Bull signals require trend == 1; bear signals require trend == -1. This is also a [b]hard positional requirement[/b] — the anchor touch condition itself requires a bull trend for longs (price touching Band 4 from above) and a bear trend for shorts (price touching Band 4 from below). The trend direction is therefore inherently confirmed by the signal trigger condition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 2 — HTF Bias[/b]

Awards 1 point when the higher timeframe EMA structure (default: 60-minute, 21/55 EMAs) agrees with the signal direction. The HTF condition for ANCHOR is stricter than in other AlphaX systems: the HTF fast EMA must be above the slow EMA [b]and</b> the HTF close must be above the HTF fast EMA for a bull vote — requiring both EMA alignment and price confirmation on the higher timeframe simultaneously.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 3 — ADX Trend Strength[/b]

Awards 1 point when ADX meets the minimum threshold (default: 18). Confirms the market is in a genuine trending phase where Band 4 retests are likely to produce continuation moves rather than range reversals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 4 — Volume Delta[/b]

Awards 1 point when the estimated volume delta (bull volume EMA minus bear volume EMA) agrees with the signal direction. Confirms that the institutional order flow pressure at the anchor touch is directionally consistent with the trend. A Band 4 touch with opposing volume delta is a warning sign — institutions may be distributing at the level, not accumulating.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 5 — Premium/Discount Zone[/b]

Awards 1 point when price is in the correct zone relative to the trend equilibrium level — discount for longs, premium for shorts. A Band 4 touch in the discount zone means you are entering at the outer structural boundary of the trend [i]and</i> the lower half of the segment range — the optimal dual positioning that maximizes risk/reward.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 6 — HVN Confluence[/b]

Awards 1 point when the current close or the Band 4 level is within ATR tolerance of any detected High Volume Node from the segment profile. This is the layer that bridges the trailing stop system and the volume profile — when a Band 4 retest coincides with an HVN, price is returning to the outer structural boundary precisely where the most institutional volume has traded. The convergence of structural (Band 4) and volumetric (HVN) confluence at the same price level is the highest-quality entry condition ANCHOR can detect.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Signal Firing Logic[/b]

An ANCHOR signal fires when [b]all of the following are simultaneously true:[/b]
[list]
[*]Price has touched Band 4 from the correct side — low within Band 4 tolerance for longs (bull trend), high within Band 4 tolerance for shorts (bear trend)
[*]The close is back on the correct side of Band 4 — close above Band 4 for longs, close below for shorts (confirming the touch was a retest, not a breakdown)
[*]Confluence score meets or exceeds the configured minimum (default: 4 of 6)
[*]Session filter confirms active hours (when enabled)
[*]Signal cooldown has elapsed since the last signal (default: 8 bars)
[*]Show Entry Signals is enabled
[/list]

[b]Live confluence display:[/b]
A small label near the current Band 4 level on the last bar shows the live bull and bear scores in the format [b]B 5/6 · S 2/6[/b] — updating in real time so you can monitor the confluence state without looking at the dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Exit Guidance System[/b]

ANCHOR provides two live guidance levels plotted as dotted circles on the chart when a signal fires — not hard mechanical exits, but [b]institutionally informed price targets[/b] for use in your own exit planning.

[b]SL Guide:[/b]
The stop loss guide is anchored to a configurable band (default: Band 4 — the outer anchor). The SL band can be set to any of the four bands depending on your risk tolerance. Band 4 represents the structural invalidation level — the trend has flipped if price closes beyond it. Band 1 is the tightest option for aggressive stop placement.

[b]TP Guide (three modes):[/b]
[list]
[*][b]POC Target (default)[/b] — the take-profit guide points to the current segment POC. This is the most structurally meaningful target: in a bull trend, a Band 4 retest entry with a POC target means you are entering at the lowest point of the trend's volume structure and targeting the price where the most institutional activity occurred. The POC frequently acts as a magnet — price is drawn back to it after pullbacks
[*][b]Opposite Band[/b] — the TP guide points to the trendHigh (bull) or trendLow (bear) of the current segment — the opposite extreme of the trend range. Maximum trend extension target
[*][b]ATR Multiple[/b] — a fixed ATR distance from the entry close (default: 2.5×). Simple and consistent across all instruments and timeframes
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The real-time dashboard displays the complete internal state across four sections, updated on every bar.

[b]TREND[/b]
[list]
[*][b]Anchor Trend[/b] — current ANCHOR system trend direction: ▲ BULLISH or ▼ BEARISH. This is the primary trend state — the direction all long entries must align with
[*][b]Adaptive[/b] — current adaptive scale multiplier (e.g., 0.85x SQZ, 1.00x, or 1.15x) with squeeze state flag. Tells you whether bands are currently tighter or wider than the base setting
[*][b]PD Zone[/b] — current premium/discount position relative to the trend equilibrium: ◧ DISCOUNT, ◧ PREMIUM, or — EQ
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — higher timeframe EMA alignment: ▲ BULL, ▼ BEAR, or — FLAT
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail
[*][b]Vol Delta[/b] — current volume delta direction: ▲ BULL, ▼ BEAR, or —
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF
[/list]

[b]VOLUME[/b]
[list]
[*][b]POC[/b] — current Point of Control price level. Updated in real time as the profile builds
[*][b]VAH / VAL[/b] — Value Area High and Value Area Low levels for the current trend segment
[*][b]HVN Count[/b] — number of High Volume Nodes currently detected in the segment profile
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull Score[/b] — live 0–6 score. Background highlights yellow-green when threshold is met
[*][b]Bear Score[/b] — live 0–6 score. Background highlights red when threshold is met
[*][b]Anchor Band[/b] — the current Band 4 price level in real time — the exact price where the next retest entry would occur
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Band 4 (Anchor — thick solid line)[/b] — the outer trailing stop and primary structural level. Yellow-green in bull trend, red in bear trend. The most important line on the chart
[*][b]Band 3 (semi-transparent)[/b] — mid-outer reference, 2× ATR inside Band 4
[*][b]Band 2 (more transparent)[/b] — mid-inner reference, 1× ATR inside Band 4
[*][b]Band 1 (most transparent)[/b] — inner reference, base ATR distance from price
[*][b]Heatmap fills[/b] — gradient color fills between all four bands. Deepening opacity toward Band 4 creates a visual depth map of trailing stop risk
[*][b]Trend Equilibrium Line (purple dots)[/b] — the dynamic midpoint of the current trend segment's high-low range
[*][b]▲ ANCHOR BULL / BEAR ▼ ANCHOR label[/b] — appears on every trend flip at the Band 4 flip price, marking each structural direction change
[*][b]▲ Triangle (below bar)[/b] — long entry signal at Band 4 retest with confluence confirmed
[*][b]▼ Triangle (above bar)[/b] — short entry signal at Band 4 retest with confluence confirmed
[*][b]Live confluence label[/b] — B x/6 · S x/6 score label near the current Band 4 level on the last bar, updating in real time
[*][b]Volume profile bars[/b] — delta-weighted horizontal bars rendered to the right of the current price, color-matched to trend direction, proportional to bin volume
[*][b]POC line (purple solid)[/b] — the highest-volume level in the current trend segment
[*][b]VAH line (yellow-green dashed)[/b] — Value Area High boundary
[*][b]VAL line (red dashed)[/b] — Value Area Low boundary
[*][b]HVN lines[/b] — horizontal lines at every local volume peak. The dominant HVN (highest volume) receives a bold line and price label
[*][b]SL Guide (red dotted circles)[/b] — stop loss reference level at the configured anchor band
[*][b]TP Guide (yellow-green dotted circles)[/b] — take-profit reference pointing to POC, opposite band extreme, or ATR target
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX ANCHOR — Step by Step[/b]

[b]Step 1 — Establish Trend Context[/b]
[list]
[*]Check the dashboard: what is the Anchor Trend? This is your trading direction — only take longs in ▲ BULLISH, only take shorts in ▼ BEARISH
[*]Check HTF Bias — does the higher timeframe agree? A bull Anchor Trend with bull HTF Bias is the ideal setup condition
[*]Check the Adaptive row — is the system in squeeze mode (0.85x SQZ)? If so, bands are tighter and a Band 4 touch is more likely. Expansion mode (1.15x) means wider bands and deeper pullbacks to reach Band 4
[*]Note the POC and VAH/VAL levels on the dashboard and the chart. These are your key target and support/resistance levels within the current trend
[/list]

[b]Step 2 — Watch for Band 4 Approach[/b]
[list]
[*]Monitor the heatmap — as price pulls back from the trend high, it moves progressively through the Band 1, 2, 3 fills. By the time price is deep in the Band 3 fill and approaching the solid Band 4 line, a retest touch is imminent
[*]Check the live confluence label near Band 4. Is the bull score at or near the threshold? If so, a signal may fire on the next bar
[*]Check the PD Zone row — is price in discount for a long entry? A Band 4 touch in discount zone is the optimal entry scenario
[/list]

[b]Step 3 — Enter on the ANCHOR Triangle[/b]
[list]
[*]A ▲ triangle confirms the Band 4 touch with qualifying confluence. Enter on the close or next bar open
[*]Note whether an HVN level is near the entry price — an HVN + Band 4 confluence entry is the highest-quality ANCHOR setup
[*]The SL Guide dotted line shows your stop reference. The TP Guide shows the POC, opposite extreme, or ATR target depending on your mode setting
[/list]

[b]Step 4 — Manage with the Band Structure[/b]
[list]
[*]As the trade moves in your favor, watch the bands ratchet upward (bull) with price — your trailing stop is automatically rising
[*]The POC line is your primary profit target in POC Target mode. As price approaches the POC, consider scaling out
[*]The VAH level (bull trend) acts as the next resistance after POC — if price clears VAH with momentum, the trade has potential to reach the trendHigh
[*]If price pulls back into the Band 3 or Band 4 zone again without a trend flip, this is a secondary entry opportunity — the same confluence check applies
[/list]

[b]Step 5 — Trend Flip Exit[/b]
[list]
[*]A close beyond Band 4 triggers a trend flip — the BEAR ▼ ANCHOR label appears, the bands invert, and the volume profile resets for the new trend segment
[*]Exit the prior trend position on the flip bar or the following open
[*]Wait for the new trend to establish and a Band 4 retest to develop in the new direction before re-entering
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Trend flips are occurring rapidly[/b] — multiple ▲ / ▼ ANCHOR flip labels in quick succession indicate a choppy, oscillating market where the Band 4 trailing stop is being crossed repeatedly. The volume profile will be very short (few bars since last flip) and the POC will be meaningless. Wait for a trend to establish and sustain for at least 10–15 bars before looking for Band 4 retest entries
[*][b]HTF Bias opposes the anchor trend[/b] — a bull ANCHOR trend with bear HTF Bias means the current timeframe is moving against the higher timeframe flow. Band 4 retest entries in this environment carry significantly reduced success rates
[*][b]ADX ✗ on the dashboard[/b] — the market is not trending. ANCHOR is a trend-following system by design — Band 4 touches in ranging markets frequently result in immediate trend flips rather than continuations
[*][b]HVN Count shows 0[/b] — the volume profile has not yet built enough data to identify volume nodes. This typically occurs immediately after a fresh trend flip. Wait for the trend to develop more bar history before relying on HVN confluence
[*][b]Adaptive shows 1.15x (expansion)[/b] and price is approaching Band 4 rapidly — high-volatility expansion phases can produce fast, aggressive moves to Band 4 and beyond. Reduce position size in expansion mode entries
[*][b]Price is in premium for a bull entry or discount for a bear entry[/b] — the PD Zone filter will block these automatically when enabled, but if disabled, be aware that entries at the wrong side of equilibrium carry structurally poor risk/reward
[/list]

[b]The ideal ANCHOR setup condition:[/b]
[list]
[*]Anchor Trend established for 15+ bars — sufficient history for meaningful volume profile
[*]HTF Bias aligned with trend direction
[*]ADX ✓ confirming a trending market
[*]Adaptive at 1.0x or 0.85x (normal or squeeze — not expansion)
[*]Price in discount (bull) or premium (bear)
[*]Band 4 touch coincides with a visible HVN level
[*]Confluence score at 5/6 or 6/6
[/list]

When all these conditions align simultaneously, an ANCHOR entry is the closest to a textbook institutional continuation setup the system can produce.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]⚓ Four-band liquidity-anchored trailing stop — Band 1 through Band 4, each ATR offset apart, ratcheting in trend direction with a one-directional lock preventing widening on pullbacks
[*]🌊 Adaptive band scaling — automatically tightens during squeeze phases and widens during high-volatility expansion. Scale multiplier displayed live on dashboard
[*]🔥 Trailing stop heatmap — gradient opacity fills between all four bands creating a real-time visual depth map of pullback risk from shallow to deep
[*]📊 Delta-weighted volume profile — anchored to the current trend segment from the last Band 4 flip, using directional volume weighting for institutional accuracy
[*]📍 POC detection — highest-volume level in the current trend segment plotted live and available as a TP target mode
[*]📐 Value Area High/Low — 70% volume concentration zone for the current trend segment, plotted as dynamic support/resistance levels
[*]🔮 HVN detection — algorithmic local volume peak identification across all profile bins. Lines extend from the trend origin through the profile
[*]⚖ Trend equilibrium — dynamic PD zone midpoint anchored to the current trend segment high and low, updating in real time as the segment expands
[*]📡 HTF bias filter — dual-EMA + price confirmation from a configurable higher timeframe, stricter condition than standard EMA crossover
[*]🧠 6-layer confluence gate — Anchor Trend, HTF Bias, ADX, Volume Delta, PD Zone, and HVN Confluence all scored independently on every bar
[*]📊 Live confluence label on chart — B x/6 · S x/6 displayed near Band 4 in real time without requiring dashboard attention
[*]🎯 Three TP target modes — POC Target (institutional magnet), Opposite Band (maximum trend extension), or ATR Multiple (fixed distance)
[*]⚙ Configurable SL anchor band — choose Band 1 through Band 4 for stop placement based on your risk preference and trading style
[*]🏷 Trend flip labels — ▲ ANCHOR BULL and BEAR ▼ ANCHOR labels mark every structural trend change on the chart
[*]📊 18-row live dashboard — Trend, Filters, Volume, and Confluence sections updated in real time
[*]🔔 6 alert conditions — bull/bear trend flips, long/short entries, and HVN + anchor confluence touches
[*]🎨 Fully cohesive dual-tone color system — yellow-green for all bullish elements, red for all bearish, orange for squeeze, purple for VWAP/equilibrium/POC
[*]⚙ Fully configurable — ATR length, base multiplier, adaptive scaling range, volume profile rows and width, value area percentage, HTF timeframe and EMA periods, ADX threshold, PD zone requirement, TP mode, SL band, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Anchor Trail Engine[/b]
[list]
[*]ATR Length — lookback for the ATR calculation used in all band offsets (default: 14)
[*]Source — price source for trailing stop calculations (default: close)
[*]Band Offset (Base) — ATR multiplier for Band 1, the innermost band. Bands 2–4 add +1, +2, +3 automatically (default: 6.5)
[*]Adaptive Band Scaling — toggles the volatility-adaptive multiplier adjustment
[*]Adaptive Min Scale — multiplier floor applied during squeeze conditions (default: 0.85)
[*]Adaptive Max Scale — multiplier ceiling applied during high-volatility expansion (default: 1.15)
[/list]

[b]Volume Profile[/b]
[list]
[*]Show Volume Profile — toggle the rendered profile bars to the right of price
[*]Profile Rows — number of price bins in the volume profile (default: 30)
[*]Profile Width (Bars) — maximum horizontal width of the profile in bars (default: 40)
[*]Delta-Weighted Volume — when on, weights each bar's contribution by directional candle bias
[*]Show HVN Levels — toggle horizontal High Volume Node lines
[*]HVN Line Style — Dotted / Solid / Dashed
[*]HVN Line Width — thickness of HVN lines (default: 1)
[*]Show Value Area (POC/VAH/VAL) — toggle POC, VAH, and VAL line plots
[*]Value Area % — percentage of total volume used to define the value area boundaries (default: 70%)
[*]Show Trend Equilibrium — toggle the dynamic segment midpoint line
[/list]

[b]Confluence & Entries[/b]
[list]
[*]HTF Trend Filter — toggle the higher timeframe EMA bias requirement
[*]HTF Timeframe — the higher timeframe for EMA calculations (default: 60-minute)
[*]HTF Fast / Slow EMA — EMA periods on the higher timeframe (defaults: 21 / 55)
[*]ADX Trend Filter — toggle the ADX minimum requirement
[*]ADX Length — ADX calculation lookback (default: 14)
[*]ADX Minimum — threshold below which signals are suppressed (default: 18)
[*]Volume Delta Filter — toggle the volume delta directional requirement
[*]Volume MA Length — EMA smoothing length for volume delta calculation (default: 14)
[*]Require PD Zone — when on, longs require discount positioning, shorts require premium
[*]Session Filter — toggle active hours restriction (default: off — ANCHOR is designed for all-session use on most instruments)
[*]Active Session — configurable session window
[*]Min Layers (of 6) — minimum confluence score to fire a signal (default: 4)
[*]Signal Cooldown — minimum bars between consecutive signals (default: 8)
[*]Show Entry Signals — toggle signal triangles on or off
[*]Show Confluence Label — toggle the live B/S score label near Band 4
[/list]

[b]Exit Guidance[/b]
[list]
[*]Show SL / TP Guides — toggle the guide level dotted circle plots
[*]SL Anchor Band — which of the four bands to use as the stop loss reference (default: Band 4)
[*]TP Target Mode — POC Target / Opposite Band / ATR Multiple
[*]TP ATR Mult — ATR distance for the ATR Multiple TP mode (default: 2.5)
[/list]

[b]Display[/b]
[list]
[*]Trailing Stop Heatmap — toggle the gradient opacity fills between bands
[*]Trend Flip Labels — toggle the ▲ ANCHOR BULL / BEAR ▼ ANCHOR labels
[*]Show Dashboard — toggle the full dashboard panel
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish bands, fills, and labels
[*]Bear / Bear Bright — red family for all bearish elements
[*]Squeeze — orange for squeeze state indicators
[*]Equilibrium — purple for the trend equilibrium line
[*]POC Line — purple for the Point of Control
[*]VAH / VAL Lines — yellow-green and red for value area boundaries
[*]SL Guide / TP Guide — stop and target guide line colors
[*]Bull / Bear Label Text — text color for confluence and flip labels
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (6 total)[/b]

[b]Trend Alerts[/b]
[list]
[*]Anchor Bull Flip — trend has anchored bullish. Band 4 closed above, all bands reset upward. Watch outer band for pullback entry development
[*]Anchor Bear Flip — trend has anchored bearish. Band 4 closed below, all bands reset downward
[/list]

[b]Entry Alerts[/b]
[list]
[*]Anchor Long Entry — Band 4 touched from above with confluence confirmed. Long signal fired
[*]Anchor Short Entry — Band 4 touched from below with confluence confirmed. Short signal fired
[/list]

[b]HVN Confluence Alerts[/b]
[list]
[*]HVN + Anchor Long Touch — price is touching the anchor band at or near a High Volume Node support zone. Pre-signal awareness alert
[*]HVN + Anchor Short Touch — price is touching the anchor band at or near a High Volume Node resistance zone
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, crypto, and indices on M5–H1[/b]. ANCHOR is uniquely versatile — the volume profile adapts to any trend length and the adaptive scaling handles any volatility regime:
[list]
[*]Band Offset at 6.5× — wide enough to avoid noise exits on intraday timeframes while keeping the trail structurally relevant
[*]HTF at 60-minute — provides meaningful context for M5–M15 intraday trading
[*]Delta-Weighted Volume on — directional weighting produces the most institutionally relevant profile on all liquid instruments
[*]Value Area at 70% — the standard institutional value area definition used by professional volume profile traders
[*]Session filter off by default — ANCHOR is designed for continuous multi-session trading on most instruments
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Band Offset to 4.5–5.5, reduce ATR Length to 10, increase Profile Rows to 20 for faster profile builds
[*][b]H4 / Daily swing trading[/b] — increase Band Offset to 8.0–10.0, set HTF to Weekly, reduce Profile Rows to 15–20 for cleaner node identification, increase TP ATR Mult to 4.0–5.0
[*][b]Crypto (BTC, ETH)[/b] — increase Adaptive Max Scale to 1.25 to accommodate wider expansion swings, increase Band Offset to 7.5–8.5
[*][b]Low-volatility forex pairs[/b] — reduce Band Offset to 5.5–6.0, reduce Adaptive Min Scale to 0.80 for tighter squeeze-phase bands
[*][b]Tighter signal quality[/b] — raise Min Layers to 5/6, enable PD Zone requirement, raise ADX minimum to 22
[*][b]More frequent signals[/b] — lower Min Layers to 3, disable HTF filter, disable PD Zone requirement
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]📈 [b]Trend followers and swing traders[/b] — the four-band trailing stop with heatmap visualization is built specifically for riding extended directional moves with structural confidence, not second-guessing every pullback
[*]📊 [b]Volume profile traders[/b] — the delta-weighted, trend-anchored profile provides the most contextually relevant volume analysis available for any given trend segment
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — default settings are tuned for these instruments. The adaptive band scaling handles XAUUSD's distinctive alternation between low-volatility coiling and high-velocity expansion
[*]🎯 [b]Pullback entry traders[/b] — ANCHOR is specifically designed to fire at the outer structural boundary of the trend (Band 4) rather than on breakouts or initial moves. Every entry is a pullback-to-structure trade at the institutional trailing stop level
[*]📡 [b]Multi-timeframe traders[/b] — the HTF bias filter and trend equilibrium system create a natural multi-timeframe framework within a single indicator
[*]🧠 [b]Traders who want volume context with every entry[/b] — the live POC, VAH/VAL, and HVN levels provide immediate institutional volume context for every trade without requiring a separate volume profile tool
[*]🔥 [b]Visual traders[/b] — the heatmap, gradient fills, trend flip labels, and volume profile create one of the richest single-indicator chart environments in the AlphaX suite. Everything needed for a complete trend trade is visible on the chart simultaneously
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Band positions and trend state finalize on confirmed bars only
[*]The volume profile is recomputed on every bar using the full trend segment history. On very long trend segments (hundreds of bars), this computation is resource-intensive. The max_bars_back is set to 5000 to accommodate extended trend segments. If you notice performance degradation on very low timeframes with long chart history, reduce Profile Rows or reduce the chart's visible bar count
[*]The volume profile is rendered only on the last bar and redrawn on every real-time update. Historical bars show the band structure but not the profile rendering — the profile always reflects the current trend segment state
[*]When a trend flip occurs, the volume profile resets completely. The first few bars after a flip will show a very short profile with minimal data — meaningful HVN confluence typically requires 15–20+ bars of trend history to develop
[*]The adaptive scale is based on ATR percentrank over 100 bars. On instruments or timeframes with less than 100 bars of history, the percentrank may not be fully calibrated. This is a warm-up effect and resolves naturally as history accumulates
[*]The session filter is off by default because ANCHOR is designed as a multi-session trend system. Unlike scalping systems that are most effective during active hours, ANCHOR band retests can occur at any time during a developing trend. Enable the session filter only if you specifically want to restrict entries to active trading hours on your instrument
[*]The Trade Status section tracks position direction from signal to exit within the chart session — it does not connect to your broker or brokerage account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that the most powerful entries are not at the breakout — they are at the moment price returns to the structural anchor where institutions are waiting.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX — ANCHOR v1.0
// Liquidity-Anchored Trailing Stop + Delta Volume Profile + Confluence Engine
// Rebuilt & extended from liquidity-anchored trail concepts — AlphaX branded.

//@version=6
indicator("[ A L P H A X ] ANCHOR", shorttitle="AlphaX ANCHOR",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=300, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ INPUTS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

grpTrail = "Anchor Trail Engine"
atrLen     = input.int(14,    "ATR Length",              minval=1, group=grpTrail)
src        = input.source(close, "Source",               group=grpTrail)
bandMult   = input.float(6.5, "Band Offset (Base)",       minval=1.0, maxval=20.0, step=0.1, group=grpTrail,
  tooltip="Base ATR multiplier for the inner band. Bands 2–4 add +1, +2, +3 automatically.")
useAdaptive = input.bool(true, "Adaptive Band Scaling",   group=grpTrail,
  tooltip="Tightens bands in low-volatility squeeze; widens slightly in expansion.")
adaptMin   = input.float(0.85, "Adaptive Min Scale",    minval=0.5, maxval=1.0, step=0.05, group=grpTrail)
adaptMax   = input.float(1.15, "Adaptive Max Scale",      minval=1.0, maxval=1.5, step=0.05, group=grpTrail)

grpVP = "Volume Profile"
vpShow     = input.bool(true,  "Show Volume Profile",     group=grpVP)
vpRows     = input.int(30,     "Profile Rows",            minval=5, maxval=100, group=grpVP)
vpWidth    = input.int(40,     "Profile Width (Bars)",    minval=5, maxval=120, group=grpVP)
vpDelta    = input.bool(true,  "Delta-Weighted Volume",   group=grpVP,
  tooltip="Weights each bar's volume by bullish/bearish candle bias.")
vpPeaks    = input.bool(true,  "Show HVN Levels",         group=grpVP)
vpPeakStyle = input.string("Dotted", "HVN Line Style", options=["Dotted", "Solid", "Dashed"], group=grpVP)
vpPeakWidth = input.int(1,     "HVN Line Width",          minval=1, maxval=4, group=grpVP)
showVA     = input.bool(true,  "Show Value Area (POC/VAH/VAL)", group=grpVP)
vaPct      = input.float(70.0, "Value Area %",            minval=50, maxval=90, step=5, group=grpVP)
showEq     = input.bool(true,  "Show Trend Equilibrium",    group=grpVP)

grpConf = "Confluence & Entries"
useHtf     = input.bool(true,  "HTF Trend Filter",        group=grpConf)
htfTF      = input.timeframe("60", "HTF Timeframe",        group=grpConf)
htfFast    = input.int(21,     "HTF Fast EMA",            minval=5, maxval=100, group=grpConf)
htfSlow    = input.int(55,     "HTF Slow EMA",            minval=10, maxval=200, group=grpConf)
useADX     = input.bool(true,  "ADX Trend Filter",        group=grpConf)
adxLen     = input.int(14,     "ADX Length",              minval=7, maxval=30, group=grpConf)
adxMin     = input.float(18,   "ADX Minimum",             minval=10, maxval=40, group=grpConf)
useVolDelta = input.bool(true, "Volume Delta Filter",     group=grpConf)
volLen     = input.int(14,     "Volume MA Length",        minval=5, maxval=50, group=grpConf)
requirePd  = input.bool(true,  "Require PD Zone",         group=grpConf,
  tooltip="Longs in discount (below EQ). Shorts in premium (above EQ).")
useSession = input.bool(false, "Session Filter",          group=grpConf)
sessStart  = input.session("0700-2000", "Active Session", group=grpConf)
minConf    = input.int(4,      "Min Layers (of 6)",       minval=3, maxval=6, group=grpConf)
cooldown   = input.int(8,      "Signal Cooldown (bars)",  minval=1, maxval=50, group=grpConf)
showSignals = input.bool(true, "Show Entry Signals",      group=grpConf)
showConfLbl = input.bool(true, "Show Confluence Label",   group=grpConf)

grpExit = "Exit Guidance"
showExits  = input.bool(true,  "Show SL / TP Guides",     group=grpExit)
slBandStr  = input.string("4", "SL Anchor Band", options=["1", "2", "3", "4"], group=grpExit)
slBand     = int(str.tonumber(slBandStr))
tpMode     = input.string("POC Target", "TP Target Mode",
  options=["POC Target", "Opposite Band", "ATR Multiple"], group=grpExit)
tpAtrMult  = input.float(2.5,  "TP ATR Mult",             minval=0.5, maxval=8.0, step=0.1, group=grpExit)

grpVis = "Display"
showHeatmap = input.bool(true, "Trailing Stop Heatmap",   group=grpVis)
showFlipLbl = input.bool(true, "Trend Flip Labels",       group=grpVis)
showDash    = input.bool(true, "Show Dashboard",          group=grpVis)
dashPos     = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors"
colBull       = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear       = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze    = input.color(#ff9800, "Squeeze",            group=grpColors)
colNeutral    = input.color(#555555, "Neutral",            group=grpColors)
colEqLine     = input.color(#8b6fd0, "Equilibrium",        group=grpColors)
colPoc        = input.color(#8b6fd0, "POC Line",           group=grpColors)
colVaHigh     = input.color(#c8e624, "VAH Line",           group=grpColors)
colVaLow      = input.color(#ff1744, "VAL Line",           group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
colLabelBull  = input.color(#0d0d0d, "Bull Label Text",    group=grpColors)
colLabelBear  = input.color(#ffffff, "Bear Label Text",    group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec    = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ HELPERS ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

peakLineStyle(st) =>
    switch st
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

f_adx(len) =>
    float up   = ta.change(high)
    float down = -ta.change(low)
    float plusDM  = up > down and up > 0 ? up : 0.0
    float minusDM = down > up and down > 0 ? down : 0.0
    float trVal   = ta.tr(true)
    float trRma   = ta.rma(trVal, len)
    float plusRma  = trRma != 0 ? 100 * ta.rma(plusDM, len) / trRma : 0.0
    float minusRma = trRma != 0 ? 100 * ta.rma(minusDM, len) / trRma : 0.0
    float sumDM = plusRma + minusRma
    float dx = sumDM != 0 ? 100 * math.abs(plusRma - minusRma) / sumDM : 0.0
    ta.rma(dx, len)

pickBand(m, b1, b2, b3, b4) =>
    m == 1 ? b1 : m == 2 ? b2 : m == 3 ? b3 : b4

// ═══════════════════════════════════════════════════════════════════════════════
// ═════════════════════ ADAPTIVE VOLATILITY ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

atrVal = ta.atr(atrLen)
bbBasis = ta.sma(close, 20)
bbDev   = 2.0 * ta.stdev(close, 20)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
kcBasis = ta.ema(close, 20)
kcRange = ta.atr(20)
kcUpper = kcBasis + 1.5 * kcRange
kcLower = kcBasis - 1.5 * kcRange
sqzOn   = bbUpper < kcUpper and bbLower > kcLower

atrPct  = ta.percentrank(atrVal, 100)
adaptScale = useAdaptive ? (sqzOn ? adaptMin : atrPct > 75 ? adaptMax : 1.0) : 1.0
effMult = bandMult * adaptScale
mult2 = effMult + 1.0
mult3 = effMult + 2.0
mult4 = effMult + 3.0

// ═══════════════════════════════════════════════════════════════════════════════
// ═════════════════════ ANCHOR TRAILING STOP ENGINE ════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var float ts1 = na
var float ts2 = na
var float ts3 = na
var float ts4 = na
var int   trend = 1

upper1 = src - atrVal * effMult
upper2 = src - atrVal * mult2
upper3 = src - atrVal * mult3
upper4 = src - atrVal * mult4
lower1 = src + atrVal * effMult
lower2 = src + atrVal * mult2
lower3 = src + atrVal * mult3
lower4 = src + atrVal * mult4

if trend == 1
    if src < nz(ts4[1], upper4)
        trend := -1
        ts1 := lower1
        ts2 := lower2
        ts3 := lower3
        ts4 := lower4
    else
        ts1 := math.max(upper1, nz(ts1[1], upper1))
        ts2 := math.max(upper2, nz(ts2[1], upper2))
        ts3 := math.max(upper3, nz(ts3[1], upper3))
        ts4 := math.max(upper4, nz(ts4[1], upper4))
else
    if src > nz(ts4[1], lower4)
        trend := 1
        ts1 := upper1
        ts2 := upper2
        ts3 := upper3
        ts4 := upper4
    else
        ts1 := math.min(lower1, nz(ts1[1], lower1))
        ts2 := math.min(lower2, nz(ts2[1], lower2))
        ts3 := math.min(lower3, nz(ts3[1], lower3))
        ts4 := math.min(lower4, nz(ts4[1], lower4))

trendChange = trend != trend[1]
activeCol   = trend == 1 ? colBull : colBear

var float trendHigh = high
var float trendLow  = low
var int   trendStartBar = 0

if trendChange
    trendHigh := math.max(high, ts4)
    trendLow  := math.min(low, ts4)
    trendStartBar := bar_index
else
    trendHigh := math.max(trendHigh, high)
    trendLow  := math.min(trendLow, low)

eqLevel   = (trendHigh + trendLow) / 2.0
inDiscount = close < eqLevel
inPremium  = close > eqLevel
pdOKLong   = not requirePd or inDiscount
pdOKShort  = not requirePd or inPremium

// ═══════════════════════════════════════════════════════════════════════════════
// ═════════════════════ HTF / ADX / VOLUME DELTA ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

htfClose = request.security(syminfo.tickerid, htfTF, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
htfOKLong  = not useHtf or htfBull
htfOKShort = not useHtf or htfBear

adxVal = f_adx(adxLen)
adxOK  = not useADX or adxVal >= adxMin

candleRange = high - low
bullVolEst  = candleRange != 0 ? volume * (close - low) / candleRange : volume * 0.5
bearVolEst  = volume - bullVolEst
volDelta    = ta.ema(bullVolEst, volLen) - ta.ema(bearVolEst, volLen)
volBull     = volDelta > 0
volBear     = volDelta < 0
volOKLong   = not useVolDelta or volBull
volOKShort  = not useVolDelta or volBear

inSession = not useSession or not na(time(timeframe.period, sessStart))

// ═══════════════════════════════════════════════════════════════════════════════
// ═════════════════════ VOLUME PROFILE (TREND SEGMENT) ═════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var box[]   vpBoxes  = array.new_box()
var line[]  vpLines  = array.new_line()
var label[] vpLabels = array.new_label()

var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var float[] hvnPrices = array.new_float()
var float[] vpVolumes = array.new_float()

vpOffset = vpWidth + 12
hvnStyle = peakLineStyle(vpPeakStyle)

// Compute profile every bar so confluence works on history; draw only on last bar.
float segHigh = trendHigh
float segLow  = trendLow
float binSize = segHigh > segLow ? (segHigh - segLow) / vpRows : syminfo.mintick
float maxVol  = 0.0
float totalVol = 0.0
int   pocIdx  = 0

array.clear(hvnPrices)
if array.size(vpVolumes) != vpRows
    array.clear(vpVolumes)
    for j = 0 to vpRows - 1
        array.push(vpVolumes, 0.0)
else
    for i = 0 to vpRows - 1
        array.set(vpVolumes, i, 0.0)

int segLen = math.max(0, bar_index - trendStartBar)
int lookback = math.min(segLen, 4999)

if binSize > 0
    for i = 0 to lookback
        float px = hlc3[i]
        int binIdx = math.min(vpRows - 1, math.max(0, int((px - segLow) / binSize)))
        float wVol = volume[i]
        if vpDelta
            float rng = high[i] - low[i]
            float bEst = rng != 0 ? wVol * (close[i] - low[i]) / rng : wVol * 0.5
            wVol := trend == 1 ? bEst : wVol - bEst
        float cur = array.get(vpVolumes, binIdx)
        float nxt = cur + wVol
        array.set(vpVolumes, binIdx, nxt)
        totalVol += wVol
        if nxt > maxVol
            maxVol := nxt

    for i = 0 to vpRows - 1
        if array.get(vpVolumes, i) > array.get(vpVolumes, pocIdx)
            pocIdx := i
    pocPrice := segLow + binSize * (pocIdx + 0.5)

    float vaTarget = totalVol * vaPct / 100.0
    float vaAccum  = array.get(vpVolumes, pocIdx)
    int vaLo = pocIdx
    int vaHi = pocIdx
    while vaAccum < vaTarget and (vaLo > 0 or vaHi < vpRows - 1)
        float volBelow = vaLo > 0 ? array.get(vpVolumes, vaLo - 1) : -1.0
        float volAbove = vaHi < vpRows - 1 ? array.get(vpVolumes, vaHi + 1) : -1.0
        if volBelow >= volAbove and vaLo > 0
            vaLo -= 1
            vaAccum += array.get(vpVolumes, vaLo)
        else if vaHi < vpRows - 1
            vaHi += 1
            vaAccum += array.get(vpVolumes, vaHi)
        else if vaLo > 0
            vaLo -= 1
            vaAccum += array.get(vpVolumes, vaLo)
        else
            break
    vahPrice := segLow + binSize * (vaHi + 1)
    valPrice := segLow + binSize * vaLo

    for i = 0 to vpRows - 1
        float vol = array.get(vpVolumes, i)
        float top = segLow + binSize * (i + 1)
        float btm = segLow + binSize * i
        float mid = (top + btm) / 2.0
        if vpPeaks and i > 0 and i < vpRows - 1
            float prevV = array.get(vpVolumes, i - 1)
            float nextV = array.get(vpVolumes, i + 1)
            if vol > prevV and vol > nextV
                array.push(hvnPrices, mid)

if barstate.islast
    for b in vpBoxes
        box.delete(b)
    for l in vpLines
        line.delete(l)
    for lb in vpLabels
        label.delete(lb)
    array.clear(vpBoxes)
    array.clear(vpLines)
    array.clear(vpLabels)

    if binSize > 0 and totalVol > 0
        for i = 0 to vpRows - 1
            float vol = array.get(vpVolumes, i)
            float top = segLow + binSize * (i + 1)
            float btm = segLow + binSize * i
            float mid = (top + btm) / 2.0
            int boxW = maxVol > 0 ? int((vol / maxVol) * vpWidth) : 0
            color binCol = color.from_gradient(boxW, 0, vpWidth, color.new(activeCol, 70), activeCol)

            if vpShow and boxW > 0
                box bx = box.new(bar_index + vpOffset + 1, top, bar_index + vpOffset - boxW, btm,
                  bgcolor=binCol, border_color=color.new(chart.bg_color, 0))
                array.push(vpBoxes, bx)

            if vpPeaks and i > 0 and i < vpRows - 1
                float prevV = array.get(vpVolumes, i - 1)
                float nextV = array.get(vpVolumes, i + 1)
                if vol > prevV and vol > nextV
                    int lineEnd = bar_index + vpOffset - (vpShow ? boxW : 0)
                    line ln = line.new(trendStartBar, mid, lineEnd, mid,
                      color=color.new(activeCol, boxW == vpWidth ? 0 : 40),
                      width=boxW == vpWidth ? 3 : vpPeakWidth, style=hvnStyle)
                    array.push(vpLines, ln)
                    if boxW == vpWidth
                        label lb = label.new(trendStartBar, mid, "HVN", color=binCol, size=size.tiny, style=label.style_circle)
                        label lb2 = label.new(bar_index + vpOffset + 1, mid, str.tostring(mid, format.mintick),
                          color=na, textcolor=colTextLt, size=size.small, style=label.style_label_left)
                        array.push(vpLabels, lb)
                        array.push(vpLabels, lb2)

        if showVA
            int vaEnd = bar_index + vpOffset + 2
            line pocLn = line.new(trendStartBar, pocPrice, vaEnd, pocPrice,
              color=color.new(colPoc, 20), width=2, style=line.style_solid)
            line vahLn = line.new(trendStartBar, vahPrice, vaEnd, vahPrice,
              color=color.new(colVaHigh, 40), width=1, style=line.style_dashed)
            line valLn = line.new(trendStartBar, valPrice, vaEnd, valPrice,
              color=color.new(colVaLow, 40), width=1, style=line.style_dashed)
            array.push(vpLines, pocLn)
            array.push(vpLines, vahLn)
            array.push(vpLines, valLn)
            label pocLbl = label.new(vaEnd, pocPrice, "POC", color=na, textcolor=colPoc, size=size.tiny, style=label.style_label_left)
            array.push(vpLabels, pocLbl)

// ═══════════════════════════════════════════════════════════════════════════════
// ═════════════════════ CONFLUENCE SCORING & ENTRIES ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

nearHVN(float[] prices, float px, float tol) =>
    bool hit = false
    int n = array.size(prices)
    if n > 0
        for i = 0 to n - 1
            if math.abs(px - array.get(prices, i)) <= tol
                hit := true
                break
    hit

float hvnTol = atrVal * 0.35
bool atAnchorLong  = trend == 1 and low <= ts4 + hvnTol and close > ts4
bool atAnchorShort = trend == -1 and high >= ts4 - hvnTol and close < ts4
bool hvnConfluence = nearHVN(hvnPrices, close, hvnTol) or nearHVN(hvnPrices, ts4, hvnTol)

int bullScore = (trend == 1 ? 1 : 0) + (htfOKLong ? 1 : 0) + (adxOK ? 1 : 0) +
     (volOKLong ? 1 : 0) + (pdOKLong ? 1 : 0) + (hvnConfluence ? 1 : 0)
int bearScore = (trend == -1 ? 1 : 0) + (htfOKShort ? 1 : 0) + (adxOK ? 1 : 0) +
     (volOKShort ? 1 : 0) + (pdOKShort ? 1 : 0) + (hvnConfluence ? 1 : 0)

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

bool bullSignal = showSignals and atAnchorLong and bullScore >= minConf and inSession and cooled
bool bearSignal = showSignals and atAnchorShort and bearScore >= minConf and inSession and cooled

if bullSignal or bearSignal
    lastSigBar := bar_index

// Exit guidance levels
float slGuide = pickBand(slBand, ts1, ts2, ts3, ts4)
float tpGuide = na
if tpMode == "POC Target" and not na(pocPrice)
    tpGuide := pocPrice
else if tpMode == "Opposite Band"
    tpGuide := trend == 1 ? trendHigh : trendLow
else
    tpGuide := trend == 1 ? close + atrVal * tpAtrMult : close - atrVal * tpAtrMult

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════ PLOTS ══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

plot1 = plot(trendChange ? na : ts1, "Stop 1", color=color.new(activeCol, 80), linewidth=1, style=plot.style_linebr, display=display.none)
plot2 = plot(trendChange ? na : ts2, "Stop 2", color=color.new(activeCol, 55), linewidth=1, style=plot.style_linebr, display=display.none)
plot3 = plot(trendChange ? na : ts3, "Stop 3", color=color.new(activeCol, 30), linewidth=2, style=plot.style_linebr, display=display.none)
plot4 = plot(trendChange ? na : ts4, "Stop 4 (Anchor)", color=color.new(activeCol, 0), linewidth=3, style=plot.style_linebr)

fillDisp = showHeatmap ? display.all : display.none
fill(plot1, plot2, color.new(activeCol, 92), title="Inner Heat", display=fillDisp)
fill(plot2, plot3, color.new(activeCol, 78), title="Mid Heat",   display=fillDisp)
fill(plot3, plot4, color.new(activeCol, 62), title="Outer Heat", display=fillDisp)

plot(showEq ? eqLevel : na, "Trend EQ", color=color.new(colEqLine, 35), linewidth=1, style=plot.style_linebr)

plot(showExits and (bullSignal or bearSignal or (trend == 1 and not trendChange)) ? slGuide : na,
  "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and (bullSignal or bearSignal) ? tpGuide : na,
  "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)

plotshape(bullSignal, title="Anchor Long", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.small)
plotshape(bearSignal, title="Anchor Short", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.small)

if showFlipLbl and trendChange
    if trend == 1
        label.new(bar_index, ts4, "▲ ANCHOR\nBULL", color=color.new(colBull, 15),
          textcolor=colLabelBull, style=label.style_label_up, size=size.small)
    else
        label.new(bar_index, ts4, "BEAR\n▼ ANCHOR", color=color.new(colBear, 15),
          textcolor=colLabelBear, style=label.style_label_down, size=size.small)

if showConfLbl and barstate.islast
    string confTxt = "B " + str.tostring(bullScore) + "/6  ·  S " + str.tostring(bearScore) + "/6"
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    float lblY = trend == 1 ? ts4 + atrVal * 0.5 : ts4 - atrVal * 0.5
    label.new(bar_index, lblY, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════ DASHBOARD ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 18,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX ANCHOR", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── TREND ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    string trTxt = trend == 1 ? "▲ BULLISH" : "▼ BEARISH"
    color  trClr = trend == 1 ? colBull : colBear
    table.cell(dash, 0, 2, "ANCHOR TREND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, trTxt, text_color=trClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "ADAPTIVE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, str.tostring(adaptScale, "#.##") + "x" + (sqzOn ? " SQZ" : ""),
      text_color=sqzOn ? colSqueeze : colTextLt, text_size=size.small, bgcolor=dbg)

    string pdTxt = inDiscount ? "◧ DISCOUNT" : inPremium ? "◧ PREMIUM" : "— EQ"
    color  pdClr = inDiscount ? colBull : inPremium ? colBear : colNeutral
    table.cell(dash, 0, 4, "PD ZONE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, pdTxt, text_color=pdClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    table.cell(dash, 0, 6, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 7, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, str.tostring(adxVal, "#.#") + (adxOK ? " ✓" : " ✗"),
      text_color=adxOK ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, volBull ? "▲ BULL" : volBear ? "▼ BEAR" : "—",
      text_color=volBull ? colBull : volBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "SESSION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, inSession ? "✓ ACTIVE" : "✗ OFF",
      text_color=inSession ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "─── VOLUME ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 10, "", bgcolor=secBg)

    table.cell(dash, 0, 11, "POC", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, not na(pocPrice) ? str.tostring(pocPrice, format.mintick) : "—",
      text_color=colPoc, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "VAH / VAL", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, not na(vahPrice) ? str.tostring(vahPrice, format.mintick) + " / " + str.tostring(valPrice, format.mintick) : "—",
      text_color=colTextLt, text_size=size.tiny, bgcolor=dbg)

    table.cell(dash, 0, 13, "HVN COUNT", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 13, str.tostring(array.size(hvnPrices)),
      text_color=colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 14, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 14, "", bgcolor=secBg)

    table.cell(dash, 0, 15, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 15, str.tostring(bullScore) + "/6" + (bullScore >= minConf ? " ✓" : ""),
      text_color=bullScore >= minConf ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 16, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 16, str.tostring(bearScore) + "/6" + (bearScore >= minConf ? " ✓" : ""),
      text_color=bearScore >= minConf ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

    table.cell(dash, 0, 17, "ANCHOR BAND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 17, str.tostring(ts4, format.mintick),
      text_color=trClr, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════ ALERTS ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(trendChange and trend == 1, title="Anchor Bull Flip",
  message="[AlphaX ANCHOR] BULL FLIP — Trend anchored bullish. Watch outer band for pullback entries.")
alertcondition(trendChange and trend == -1, title="Anchor Bear Flip",
  message="[AlphaX ANCHOR] BEAR FLIP — Trend anchored bearish. Watch outer band for pullback entries.")
alertcondition(bullSignal, title="Anchor Long Entry",
  message="[AlphaX ANCHOR] LONG — Anchor band retest + confluence fired.")
alertcondition(bearSignal, title="Anchor Short Entry",
  message="[AlphaX ANCHOR] SHORT — Anchor band retest + confluence fired.")
alertcondition(atAnchorLong and hvnConfluence, title="HVN + Anchor Long Touch",
  message="[AlphaX ANCHOR] Price touched anchor band at HVN support zone.")
alertcondition(atAnchorShort and hvnConfluence, title="HVN + Anchor Short Touch",
  message="[AlphaX ANCHOR] Price touched anchor band at HVN resistance zone.")
````
