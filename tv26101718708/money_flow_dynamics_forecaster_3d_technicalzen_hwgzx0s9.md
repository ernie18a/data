# Money Flow Dynamics Forecaster 3D [TechnicalZen]

- url: https://www.tradingview.com/script/hWgzX0S9-Money-Flow-Dynamics-Forecaster-3D-TechnicalZen/
- type: indicator
- pine_id: PUB;767f8b1d51834eba84fa539b4b12d5d4
- version: 2.0

## Description

The art of swimming with the whales 🐳

[b]What is this?[/b]

MFDF 3D provides a topological three-dimensional mapping of current market drivers and potential future trajectories.

is a visual analysis indicator that compresses several ideas into one spatial model: recent history, layer depth, directional amplitude, and short-term forward continuation.

Visually a three-dimensional momentum ocean where two independent systems — [b]Money Flow[/b] (MFI-driven) and [b]Price Current[/b] (Hull-VWMA-driven) — are rendered as layered terrains inside a bounded 3D box. Past history forms a waved carpet; the future is slope-extrapolated with exponential decay. When both systems agree, whales appear — 🐳 when the tide is rising, 🐋 when it's falling.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Metaphor — Swimming With the Whales[/b]

Markets do not move on their own. They move because [b]whales[/b] move them — large institutional players whose positions are too big to enter or exit in a single candle. A pension fund building a position, a market maker hedging a block, a macro desk rotating out of a sector — none of them can step in without leaving ripples.

When whales move, they leave two distinct footprints in the tape:

[list]
[*][b]Money Flow[/b] — volume concentrated at favorable prices. You don't see it as a price change at first; you see it as [i]buying pressure accumulating[/i]. MFI, weighted by volume, detects this before it becomes price.
[*][b]Price Current[/b] — the volume-weighted tide. Once enough pressure accumulates, price itself has to drift in the direction the whale is pushing. Hull-VWMA slope tracks this.
[/list]

Retail traders typically see only the second footprint — price moving. By then the whale is already positioned. Money Flow shows you the first footprint [i]before[/i] price has to respond, which is why MFI leads VWMA in this indicator.

The goal is [b]not[/b] to catch the whale — you can't. The goal is to see the ripples early enough to swim [i]with[/i] the tide instead of against it. That's what "swimming with the whales" means: recognizing the institutional current and aligning with it, instead of fading it and getting dragged under.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Fluid Dynamics[/b]

Every oscillator you've used is a single line. MFI is one line. RSI is one line. MACD is two lines and a histogram. They're flat because they pick [i]one smoothing length[/i] and commit to it. You see where momentum is; you don't see its [i]shape[/i].

This indicator draws a [b]family of 20 Hull-smoothed Money Flow variants simultaneously[/b], each using a different HMA length (3, 4, 5, 6, 8, 10, 12, 14, 17, 20, 23, 26, 30, 34, 38, 42, 46, 50, 55, 60). Short HMAs foam at the surface, reacting instantly. Long HMAs move like glaciers. Stitched together across time and depth, they form a genuine [b]fluid[/b] — ripples, waves, surges, cascades, turning-tides — not a line, a current.

The Hull-VWMA carpet is the same idea on a second dimension: 12 depth layers, each the 2-bar percentage slope of a Hull-smoothed Volume-Weighted Moving Average. This is your [b]price current[/b]: where the volume-weighted tide is moving, independent of momentum.

Two independent Wireframes. Shared 3D box. When they agree, the whale arrives.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The 3D Box[/b]

Axes:
[list]
[*]X — time (past bars left of center, forecast right)
[*]Y — amplitude, signed ±100 (positive = bullish, negative = bearish)
[*]Z — depth layer (each HMA length sits at a different depth)
[/list]

Reference planes:
[list]
[*]The translucent Y=0 plane is momentum neutrality — where MFI = 50, VWMA slope = 0. Wireframes rise above it when bullish, sink below when bearish.
[*]The X=0 plane marks the current candle. Everything to the left is memory; everything to the right is forecast.
[*]Nine labeled points (A–I) on the Y=0 plane let you orient instantly.
[/list]

Riders:
[list]
[*]🏄‍♂ — rides the leading edge of the Money Flow terrain (HMA 20 middle layer)
[*]⛵ — rides the Price Current leading edge (Hull-VWMA slope in Hull-VWMA mode, signed-ADX HMA in ADX mode)
[*]🐳 — breaches at the forecast end when both slopes are bullish
[*]🐋 — dives at the forecast end when both slopes are bearish
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Color Aesthetics[/b]

The color choices are not random — they carry semantic weight.

[b]Money Flow terrain[/b] uses traffic-light logic:
[list]
[*]Yellow at neutral (v ≈ 0)
[*]Yellow → Green as bullish momentum grows
[*]Yellow → Red as bearish momentum grows
[*]Solid green above +50, solid red below −50
[/list]

[b]Hull-VWMA carpet[/b] uses a water palette:
[list]
[*]Light blue at neutrality — still water
[*]Light blue → Cyan as money flows in
[*]Light blue → Maroon as money flows out
[/list]

Transparency encodes magnitude: weak signals fade to nearly invisible, strong signals saturate. You read intensity at a glance, without staring at a number.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Forecast[/b]

Past Wireframes tell you where you've been. The right half of the box projects [b]where you're heading[/b].

Each of the 20 + 12 = 32 HMA layers gets slope-extrapolated into the future:

    future[t] = current + slope · t · decay^t

[list]
[*]slope is computed from the last N bars (default 4)
[*]decay (default 0.92) is the honesty multiplier — the further out you go, the less confident the projection, so the slope contribution fades
[*]All forecast values clamp to ±100 so they never escape the box
[/list]

Rendered as translucent ghost terrain in the forecast half, colored with the same palette as the past but softer. You see [b]the shape of projected momentum[/b], not a point estimate.

When both the Money Flow middle-layer slope AND the Hull-VWMA middle-layer slope agree on direction, a whale surfaces at the forecast's far edge. This is [b]confluence[/b] — two independent systems pointing the same way. That's the signal worth swimming toward.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Two Riders — Surfer vs Sailboat[/b]

The two emojis on the present-boundary are not decoration. They represent two fundamentally different kinds of signal — and understanding the difference is the whole game.

🏄‍♂ [b]The Surfer[/b] — rides the Money Flow terrain. Surfers feel the [b]impulse[/b]: every short wave, every gust of buying or selling pressure, every sudden shift in volume-weighted momentum. Surfers are fast, reactive, sensitive. What the surfer tells you: [i]"the wind just picked up"[/i] — or [i]"it just died."[/i] This is the quick, leading signal.

⛵ [b]The Sailboat[/b] — rides the Price Current carpet. Sailboats don't react to gusts; they set their course by the [b]trend[/b] — the steady directional pressure of the volume-weighted tide pushing the boat one way or the other. Slow, deliberate, confirmed. What the sailboat tells you: [i]"the current is actually carrying us this way now."[/i] This is the confirming, lagging signal.

These are two [b]different[/b] kinds of information, not two views of the same thing:

[list]
[*]The surfer sees the impulse [i]before[/i] it matures into committed direction.
[*]The sailboat confirms that the impulse has turned into real directional displacement.
[/list]

[b]When both agree — surfer AND sailboat pointing the same way — momentum builds faster than either signal could account for alone.[/b] That agreement is the proof that big money isn't just testing the waters; they're actually moving them. That's when a whale surfaces.

[list]
[*]Surfer alone = wind, no commitment yet. An impulse without confirmation — interesting but unconfirmed.
[*]Sailboat alone = drift, no fresh push. A trend without new pressure — may be tired.
[*]Surfer + Sailboat = whale. Both fresh impulse [i]and[/i] committed direction. Institutional participation confirmed.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Reading the Whales — What They Mean For Decisions[/b]

A whale is [b]not[/b] a liquidity-grab signal. It is a [b]confluence[/b] signal: both independent systems have agreed on direction at the same time.

[list]
[*]🐳 — Money Flow [i]and[/i] Price Current are both rising. Buyers are accumulating AND getting filled at progressively higher prices. This is sustained pressure, not a stop-hunt or a single-bar spike.
[*]🐋 — Both falling together. Selling pressure AND price giving ground in lockstep.
[*][b]No whale[/b] — the two systems disagree, or both are flat. Low-conviction zone.
[/list]

[b]Decision framework[/b]
[list]
[*]🐳 → align long, don't fade. This is a conviction trade, not a reversal bet. Big money is actually pushing the tape, so size up with the tide instead of against it.
[*]🐋 → exit longs or consider shorting. Don't buy the dip blindly — the volume-weighted price is confirming the sellers, not fighting them.
[*]No whale → stand aside, or scale out of existing positions. Wait for confluence before committing fresh risk.
[/list]

The mental model: "is big money actually moving the tape right now, or just shuffling?" Whale = pushing. No whale = shuffling.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Helpful Tip — Money Flow Leads Price Current[/b]

How to Use It in Practice
The best way to use the indicator is to read it in layers. It is not a one-glance yes or no system. Its advantage comes from helping the user see whether a move has internal support, whether the structure is broadening or thinning, and whether the present slope still has credible continuation.
• Start with orientation: Keep the default camera first. Learn where the zero plane is, where present time sits, and how positive and negative terrain occupies the box.
• Read the momentum terrain first: Look for height, curvature, and continuity across layers. A broad aligned rise or fall is stronger than a single sharp spike on only the fast layers.
• Check the oscillator carpet next: In Hull-VWMA mode, ask whether price-current slope supports momentum. In ADX mode, ask whether directional trend strength is building under the move.
• Inspect the forecast half: Use the ghosted forward half as a continuation sketch, not as a promise. Flattening structure, decaying height, or diverging layers often matter more than the exact projected endpoint.
• Use the whale as confirmation, not as the whole trade: The whale is most useful when it appears after the terrain has already become coherent, not when the picture is still fragmented and noisy.
Practical setup profiles

 [b]Fast tape[/b]
[b]Suggested mode:[/b] MFI + Hull-VWMA
[b]What to emphasize:[/b] Steeper terrain changes and quicker second-signal response.
[b]Reading style:[/b] Use for intraday pulse and immediate continuation checks.

[b]Cleaner swing structure[/b]
[b]Suggested mode:[/b] RSI + Hull-VWMA
[b]What to emphasize:[/b] Broader curvature and less volume sensitivity.
[b]Reading style:[/b] Use when the user wants smoother rhythm and cleaner layer alignment.

[b]Trend-strength confirmation[/b]
[b]Suggested mode:[/b] MFI or RSI + ADX
[b]What to emphasize:[/b] Whether directional pressure is actually strengthening underneath the move.
[b]Reading style:[/b] Use when momentum looks attractive but may be structurally weak.

In practice, the [b]Money Flow terrain (yellow/green/red) turns before the Hull-VWMA carpet (cyan/blue/maroon)[/b]. Volume-driven accumulation and distribution show up in MFI first — price only has to move afterwards to reflect what already happened underneath.

What to watch for:
[list]
[*]Momentum terrain flipping color while the carpet is still flat → [b]early warning[/b]. A whale sighting may be forming but is not yet confirmed.
[*]Carpet starting to tilt the same way → [b]confirmation building[/b]. Slopes are aligning.
[*]🐳 / 🐋 appears at the forecast edge → [b]confluence[/b]. Both systems point the same way. Act.
[/list]

Read the terrain first. Wait for the carpet to catch up. Act on the whale.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Why This Is Different[/b]

Traditional oscillators answer: [i]"what is momentum doing right now?"[/i]

This indicator answers:
[list]
[*][i]What is money flow doing across every smoothing horizon at once?[/i] — the 20-layer Wireframe shows the full shape of momentum, not a single slice
[*][i]What is the volume-weighted price doing independently?[/i] — the Hull-VWMA carpet is a second, independent witness
[*][i]What do they predict together?[/i] — slope-extrapolated forecasts fill the future half; confluence emojis mark conviction
[*][i]How strong is the signal?[/i] — opacity, saturation, and emoji presence are all quantitative encodings
[/list]

No threshold to wait for. No line to cross. The ocean tells you where you are — and the whales tell you where it's heading.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Best Used With Volume-Weighted Candles[/b]

Switch your TradingView chart's bar type (top-left dropdown) to [b]Volume Candles[/b].

Here's why this matters: the Hull-VWMA layer is already volume-weighted mathematically. When the chart's candles are ALSO volume-weighted, every visible pixel speaks the same language — price, indicator terrain, and forecast are all reading the same volume-filtered reality.

[list]
[*]Thin-volume wicks and gap-outs stop polluting the chart, so they stop polluting the forecast
[*]🐳 / 🐋 confluence signals calibrate more cleanly because both the price action and the indicator see the same "what the volume actually cared about"
[*]On plain OHLC candles the indicator still works — but low-liquidity price spikes can disagree with the terrain. On VWC they move in lockstep.
[/list]

If you want one setup to remember: [b]Volume Candles + this indicator + default settings[/b]. Swim with the whales.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Best Paired With [url=https://www.tradingview.com/script/ejlOagzv-Smart-Candle-Structures-TechnicalZen/]Smart Candle Structures [TechnicalZen][/url][/b]

This indicator answers one question: [i]"Is big money flowing, and in which direction?"[/i] It does not answer: [i]"At what price level should I enter, exit, or place my stop?"[/i]

For that you need [b]structural context[/b] — the levels where the market has historically reacted. [url=https://www.tradingview.com/script/ejlOagzv-Smart-Candle-Structures-TechnicalZen/]Smart Candle Structures [TechnicalZen][/url] (order blocks, fair value gaps, liquidity pools, break-of-structure / change-of-character zones) maps exactly those levels.

The two tools are complementary, not redundant:

[list]
[*][b]Smart Candle Structures[/b] gives you [b]WHERE[/b] — the structural level worth reacting at.
[*][b]MFD Forecaster[/b] gives you [b]WHETHER AND WHEN[/b] — is the flow actually supporting a reaction here, and is it committed enough to act on?
[/list]

The ideal workflow:

[list=1]
[*]Smart Candle Structures highlights a level worth watching (an unfilled order block, a liquidity sweep, a CHoCH break).
[*]Price arrives at that level. You don't act yet.
[*]Watch this indicator: is the surfer turning? Is the sailboat joining? Is a whale forming in the forecast half?
[*]Structure + confluence = your trigger. Structure without confluence = low-conviction trap. Confluence without structure = direction without location.
[/list]

Pair them and you have both legs of the trade: [b]the right place, at the right moment, with conviction[/b].

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]TradingView Chart Stretch — Feature, Not Bug[/b]

Pine drawings live in chart coordinates (bar_index × price), so they stretch with your chart. Most indicator authors fight this. We lean into it.

[list]
[*][b]Horizontal zoom[/b] → bar spacing changes → the 3D box widens or tightens organically. Zoom in tight to inspect individual layer positions; zoom out to see broad wave cycles.
[*][b]Pane height[/b] changes → vertical proportions adjust. Invisible ±50 anchor plots lock the Y range so the box never jumps when values move.
[*][b]Emojis scale with the pane[/b] — surfers and whales always read clearly at any zoom.
[/list]

The indicator [b]breathes with your viewport[/b]. That's what a real 3D visualization should do in a chart environment. It's responsive by design, not despite itself.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Settings Overview[/b]

[b]Core[/b]
[list]
[*]Time Span — past bars rendered (default 15). Also the forecast horizon.
[*]Momentum Source — [b]MFI[/b] (volume-weighted, default) or RSI (pure price)
[*]Momentum Length — 14 default
[*]Rib Amplification — stretches the ribs vertically to fill the box
[/list]

[b]Oscillator (Hull-VWMA)[/b]
[list]
[*]VWMA Length — default 30
[*]HMA Length — default 20
[*]Hull-VWMA Scale — amplifies the slope into ±100
[*]Bull/Bear/Neutral Tint colors
[/list]

[b]Camera[/b]
[list]
[*]Yaw — horizontal rotation (−180 to +180)
[*]Pitch — vertical tilt (default 5° = eye-level)
[*]Scale X / Y / Z — box proportions
[/list]

[b]Forecast[/b]
[list]
[*]Slope Lookback — bars used to compute current slope (default 4)
[*]Decay per Bar — how slope contribution fades into the future (default 0.92)
[/list]

[b]Display[/b]
[list]
[*]Box Wireframe, Y=0 plane, Axis markers, Mesh wireframe, Grids (all togglable)
[*]Show Emoji Markers — master toggle for all four emojis
[/list]


[b]Quick-Start Tips[/b]

[list=1]
[*]Load with defaults.
[*]Switch chart bar type to Volume Candles.
[*]Watch for 🐳 and 🐋 — they're rare, by design. They mean confluence.
[*]Read the color gradient — yellow is neutral, bright green / cyan is strong bull, red / maroon is strong bear.
[*]Try yaw presets: 0 = front view, 45 = corner, 90 = side, 180 = back.
[*]Lower time spans (10–15) for intraday, higher (25–40) for daily and weekly.
[*]Money Flow leads Price Current. If the yellow/green/red terrain is already turning while the cyan/blue/maroon carpet is still flat, you're early — the whale hasn't confirmed yet, but it's forming.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Disclaimer[/b]

This indicator is a visualization and analytical tool. It is [b]not[/b] financial advice, a trade recommendation, or a signal service.

[list]
[*]The whale emojis, forecast terrain, and slope extrapolations are mathematical projections from past data. They describe what [i]has been[/i] and what [i]linear decay would suggest next[/i] — not what markets will actually do. Markets are non-linear and reflexive; forecasts can and will be wrong.
[*]No indicator eliminates risk. Confluence signals reduce noise, they do not guarantee outcomes. Every trade can lose.
[*]Past performance — of this tool, or of any setup you build with it — does not predict future results.
[*]Use with your own risk management (position sizing, stop placement, portfolio exposure). The indicator has no awareness of your account, your instruments, or your time horizon.
[*]Do your own research. Consider speaking to a licensed financial professional before making investment decisions, especially on leveraged or derivative instruments.
[/list]

By using this indicator you accept that all trading decisions and their consequences are your own. The author assumes no liability for losses incurred through use of this tool.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]The art of swimming with the whales.[/i]
— TechnicalZen

## Source Code

````pine
// Money Flow Dynamics Forecaster 3D [TechnicalZen]
// "The art of swimming with the whales"
//
// Two independent layered terrains inside a bounded 3D box:
//   MOMENTUM TERRAIN — 20 HMA layers of MFI (or RSI). Yellow/green/red gradient.
//   PRICE CURRENT CARPET — 12 layers: VWMA 2-bar slope OR signed-ADX HMAs (per oscType). Cyan / light-blue / maroon.
//
// Axes (box coordinates):
//   X = time (past on the left X<0, forecast on the right X>0, X=0 = current bar)
//   Y = signed amplitude, ±100 (above Y=0 plane = bullish, below = bearish)
//   Z = depth layer (each HMA length sits at a different Z, forming the fluid dynamics)
//
// Forecast: each layer is slope-extrapolated with exponential decay into the future half.
// Confluence: 🐳 appears at the forecast end when both middle-layer slopes are bullish;
// 🐋 when both are bearish. 🏄‍♂ rides the momentum leading edge; ⛵ rides the carpet.
//
// Invisible plot(±50) anchors pin the pane's Y range so the box stays a constant size.

//@version=6
indicator("Money Flow Dynamics Forecaster 3D [TechnicalZen]", "MFD Forecaster 3D", overlay = false, max_polylines_count = 100, max_lines_count = 300, max_labels_count = 20, calc_bars_count = 1000)

//---------------------------------------------------------------------------------------------------------------------}
int    timeSpan    = input.int(15, "Time Span (bars each side of 0)", minval = 5, maxval = 100, tooltip = "Number of past bars to render. Around 15 reads cleanly — higher values pile the strips on top of each other.")
string momentumSrc = input.string("MFI", "Momentum Source", options = ["MFI", "RSI"], tooltip = "MFI = Money Flow Index (volume-weighted momentum). RSI = Relative Strength Index (pure price momentum).")
int    rsiLen      = input.int(14, "Momentum Length", minval = 2)
float yAmp     = input.float(2.0, "Rib Amplification", minval = 0.5, maxval = 5.0, step = 0.1, tooltip = "Stretches momentum ribs vertically. MFI/RSI rarely hits 0/100, so the raw centered value (x-50)*2 usually stays in ±40. Bumping amp makes moderate swings fill more of the ±100 axis. Clamped to ±100.")

float yawDeg   = input.float(20,  "Yaw (°)",            group = "Camera", minval = -180, maxval = 180, tooltip = "Viewer presets (from I looking toward): 0°=G (back/mid), 90°=F (right-mid), 135°=B, 180°=E (front/mid), -90°=H (left-mid), -135°=D.")
float pitchDeg = input.float(5,   "Pitch (°)",          group = "Camera", minval = 1,   maxval = 89, tooltip = "Eye-level at ~5°. Top-down (above Y=100) at ~89°. Intermediate values tilt between.")
float sTime    = input.float(1.2, "Scale X (Time, bars per unit)", group = "Camera", step = 0.1, minval = 0.1)
float sAlt     = input.float(0.4, "Scale Y (Vertical)",            group = "Camera", step = 0.1, minval = 0.1, tooltip = "Fixed scale for Y axis. Keeps box size constant regardless of volatility.")
float sDepth   = input.float(0.4, "Scale Z (Depth)",               group = "Camera", step = 0.1, minval = 0.1, tooltip = "Fixed scale for Z axis.")

string oscType    = input.string("Hull-VWMA", "Oscillator Type", options = ["Hull-VWMA", "ADX"], group = "Oscillator")
int    vwmaLen    = input.int(30, "VWMA Length",     group = "Oscillator", minval = 2)
float  oscScale   = input.float(500.0, "Hull-VWMA Scale", group = "Oscillator", minval = 1.0, step = 10.0, tooltip = "Slope is a tiny % change — multiplier pushes it into the ±100 box range. Raise if signal looks flat.")
int    adxLen     = input.int(14,  "ADX Length (DMI period)", group = "Oscillator", minval = 2)
bool   showOsc    = input.bool(true, "Show Oscillator Carpet", group = "Oscillator", tooltip = "Renders the 12-layer carpet (Hull-VWMA slopes or signed-ADX HMAs, depending on Oscillator Type).")
color  oscBullCol = input.color(#00BCD4, "Bull Color (osc > 0)", group = "Oscillator", tooltip = "Cyan family — extreme positive oscillator.")
color  oscBearCol = input.color(#800000, "Bear Color (osc < 0)", group = "Oscillator", tooltip = "Maroon family — extreme negative oscillator.")
color  oscNeutCol = input.color(#87CEEB, "Neutral Tint (mag ≈ 0)", group = "Oscillator", tooltip = "Light blue — weak signals blend toward this color.")
int   offsetX  = input.int(0,     "Offset X",           group = "Camera")
float offsetY  = input.float(0,   "Offset Y",           group = "Camera")

bool  showAxisLabels = input.bool(false, "Show Axis Markers",             group = "Display", tooltip = "Labels at -100, 0, +100 on both Y and Z axes.")
bool  showMesh    = input.bool(true, "Mesh Wireframe",                   group = "Display", tooltip = "Adds dotted columns through the depth layers for a crosshatch feel.")
int   meshDiv     = input.int(5, "Mesh Divisions per Strip",             group = "Display", minval = 1, maxval = 10, tooltip = "Bigger = fewer mesh columns = less clutter. Auto-throttles upward when Time Span is large.")
bool  showEmoji   = input.bool(true, "Show Emoji Markers", group = "Display", tooltip = "🏄‍♂ at momentum (MFI/RSI) leading edge, ⛵ at VWMA (or ADX) leading edge. 🐳 (bull) or 🐋 (bear) at forecast leading edge when both middle-layer slopes agree.")

bool  showForecast     = input.bool(true,  "Show Slope Forecast",        group = "Forecast", tooltip = "Extrapolates each layer forward using its current slope, with exponential decay. Projects a ghost terrain into the future half of the box.")
int   forecastSlopeLen = input.int(4,      "Slope Lookback (bars)",      group = "Forecast", minval = 2, maxval = 50, tooltip = "How many past bars to compute the slope from. Shorter = more reactive, longer = smoother. Capped internally to Time Span to fit the ring buffer.")
float forecastDecay    = input.float(0.92, "Forecast Decay per Bar",     group = "Forecast", minval = 0.5, maxval = 1.0, step = 0.01, tooltip = "Each future bar the slope contribution multiplies by this factor. 1.0 = pure linear extrapolation, 0.9 = strong fade, 0.95 = gentle fade.")

bool  showFloorGrid = input.bool(true,  "Y=0 Floor Grid",           group = "Wireframe", tooltip = "Mesh on the water surface (Y=0) — ribs punch through it.")
bool  showBackGrid  = input.bool(true,  "Back Wall Grid (Z=+100)",  group = "Wireframe", tooltip = "Mesh on the far Z wall (past side).")
bool  showSideGrid  = input.bool(false, "Side Wall Grid (X=-100)",  group = "Wireframe", tooltip = "Mesh on the left X wall.")
int   gridStep      = input.int(25, "Grid Spacing",                 group = "Wireframe", minval = 10, maxval = 50)

color boxColor    = input.color(color.new(color.gray, 60),  "Box Wireframe",           group = "Style")
color nowPlaneCol = input.color(color.new(color.white, 75), "X=0 Plane",               group = "Style")
color yZeroEdge   = input.color(color.new(#64B5F6, 55),     "Y=0 Slab Edge",           group = "Style")
color axisLabelCol= input.color(color.new(color.white, 30), "Axis Markers",            group = "Style")
color gridColor   = input.color(color.new(color.white, 88), "Wireframe Grid",          group = "Style")

//---------------------------------------------------------------------------------------------------------------------}
type Camera
    int anchorX
    float anchorY
    float cYaw
    float sYaw
    float cPit
    float sPit
    float sT
    float sA
    float sD

method project(Camera this, float x, float y, float z) =>
    float xs = x * this.sT
    float ys = y * this.sA
    float zs = z * this.sD
    float screenX = xs * this.cYaw - zs * this.sYaw
    float screenY = ys * this.cPit + (xs * this.sYaw + zs * this.cYaw) * this.sPit
    chart.point.from_index(this.anchorX + int(screenX), this.anchorY + screenY)


//---------------------------------------------------------------------------------------------------------------------}
float rsiRaw = momentumSrc == "MFI" ? ta.mfi(hlc3, rsiLen) : ta.rsi(close, rsiLen)

// ---- MOMENTUM TERRAIN (20 depth layers, HMA lengths from 3 → 60) ----
float _rH0  = ta.hma(rsiRaw, 3)
float _rH1  = ta.hma(rsiRaw, 4)
float _rH2  = ta.hma(rsiRaw, 5)
float _rH3  = ta.hma(rsiRaw, 6)
float _rH4  = ta.hma(rsiRaw, 8)
float _rH5  = ta.hma(rsiRaw, 10)
float _rH6  = ta.hma(rsiRaw, 12)
float _rH7  = ta.hma(rsiRaw, 14)
float _rH8  = ta.hma(rsiRaw, 17)
float _rH9  = ta.hma(rsiRaw, 20)
float _rH10 = ta.hma(rsiRaw, 23)
float _rH11 = ta.hma(rsiRaw, 26)
float _rH12 = ta.hma(rsiRaw, 30)
float _rH13 = ta.hma(rsiRaw, 34)
float _rH14 = ta.hma(rsiRaw, 38)
float _rH15 = ta.hma(rsiRaw, 42)
float _rH16 = ta.hma(rsiRaw, 46)
float _rH17 = ta.hma(rsiRaw, 50)
float _rH18 = ta.hma(rsiRaw, 55)
float _rH19 = ta.hma(rsiRaw, 60)

f_rsiCenter(float r) =>
    float raw = na(r) ? 50.0 : r
    math.max(-100.0, math.min(100.0, (raw - 50.0) * 2.0 * yAmp))

// Ring buffer must hold max(timeSpan+1, forecastSlopeLen+1) slots — fixes the slope-lookback wrap bug
int _bufSize = math.max(timeSpan + 1, forecastSlopeLen + 1)

var matrix<float> rsiTerrain = matrix.new<float>(20, _bufSize, 0.0)
int _rsiColIdx = bar_index % _bufSize
rsiTerrain.set(0,  _rsiColIdx, f_rsiCenter(_rH0))
rsiTerrain.set(1,  _rsiColIdx, f_rsiCenter(_rH1))
rsiTerrain.set(2,  _rsiColIdx, f_rsiCenter(_rH2))
rsiTerrain.set(3,  _rsiColIdx, f_rsiCenter(_rH3))
rsiTerrain.set(4,  _rsiColIdx, f_rsiCenter(_rH4))
rsiTerrain.set(5,  _rsiColIdx, f_rsiCenter(_rH5))
rsiTerrain.set(6,  _rsiColIdx, f_rsiCenter(_rH6))
rsiTerrain.set(7,  _rsiColIdx, f_rsiCenter(_rH7))
rsiTerrain.set(8,  _rsiColIdx, f_rsiCenter(_rH8))
rsiTerrain.set(9,  _rsiColIdx, f_rsiCenter(_rH9))
rsiTerrain.set(10, _rsiColIdx, f_rsiCenter(_rH10))
rsiTerrain.set(11, _rsiColIdx, f_rsiCenter(_rH11))
rsiTerrain.set(12, _rsiColIdx, f_rsiCenter(_rH12))
rsiTerrain.set(13, _rsiColIdx, f_rsiCenter(_rH13))
rsiTerrain.set(14, _rsiColIdx, f_rsiCenter(_rH14))
rsiTerrain.set(15, _rsiColIdx, f_rsiCenter(_rH15))
rsiTerrain.set(16, _rsiColIdx, f_rsiCenter(_rH16))
rsiTerrain.set(17, _rsiColIdx, f_rsiCenter(_rH17))
rsiTerrain.set(18, _rsiColIdx, f_rsiCenter(_rH18))
rsiTerrain.set(19, _rsiColIdx, f_rsiCenter(_rH19))

// Momentum gradient: yellow @ 0 → green @ +50/+100 ; yellow @ 0 → red @ -50/-100
f_rsiColor(float v) =>
    v >= 50.0 ? #00E676 : v <= -50.0 ? #FF5252 : v >= 0.0 ? color.from_gradient(v / 50.0, 0, 1, #FFEB3B, #00E676) : color.from_gradient((-v) / 50.0, 0, 1, #FFEB3B, #FF5252)

// ADX (signed via DI direction)
[_pdi, _mdi, adxRaw] = ta.dmi(adxLen, adxLen)
float adxDir    = _pdi >= _mdi ? 1.0 : -1.0
float adxSigned = adxRaw * adxDir

// ---- ADX TERRAIN (12 HMA layers of signed ADX) — fills the carpet when oscType = "ADX" ----
float _aH0  = ta.hma(adxSigned, 3)
float _aH1  = ta.hma(adxSigned, 5)
float _aH2  = ta.hma(adxSigned, 7)
float _aH3  = ta.hma(adxSigned, 10)
float _aH4  = ta.hma(adxSigned, 14)
float _aH5  = ta.hma(adxSigned, 19)
float _aH6  = ta.hma(adxSigned, 25)
float _aH7  = ta.hma(adxSigned, 32)
float _aH8  = ta.hma(adxSigned, 40)
float _aH9  = ta.hma(adxSigned, 49)
float _aH10 = ta.hma(adxSigned, 59)
float _aH11 = ta.hma(adxSigned, 70)

// ---- Hull-VWMA TERRAIN (12 depth layers) ----
float vwmaSrc = ta.vwma(close, vwmaLen)

float _hma0  = ta.hma(vwmaSrc, 3)
float _hma1  = ta.hma(vwmaSrc, 5)
float _hma2  = ta.hma(vwmaSrc, 7)
float _hma3  = ta.hma(vwmaSrc, 10)
float _hma4  = ta.hma(vwmaSrc, 14)
float _hma5  = ta.hma(vwmaSrc, 19)
float _hma6  = ta.hma(vwmaSrc, 25)
float _hma7  = ta.hma(vwmaSrc, 32)
float _hma8  = ta.hma(vwmaSrc, 40)
float _hma9  = ta.hma(vwmaSrc, 49)
float _hma10 = ta.hma(vwmaSrc, 59)
float _hma11 = ta.hma(vwmaSrc, 70)

f_slope(float hmaNow, float hmaPrev) =>
    float raw = not na(hmaPrev) and hmaPrev != 0.0 ? (hmaNow - hmaPrev) / hmaPrev * 100.0 * oscScale : 0.0
    math.max(-100.0, math.min(100.0, raw))

f_clampAdx(float v) => math.max(-100.0, math.min(100.0, nz(v)))

float osc0  = f_slope(_hma0,  _hma0[2])
float osc1  = f_slope(_hma1,  _hma1[2])
float osc2  = f_slope(_hma2,  _hma2[2])
float osc3  = f_slope(_hma3,  _hma3[2])
float osc4  = f_slope(_hma4,  _hma4[2])
float osc5  = f_slope(_hma5,  _hma5[2])
float osc6  = f_slope(_hma6,  _hma6[2])
float osc7  = f_slope(_hma7,  _hma7[2])
float osc8  = f_slope(_hma8,  _hma8[2])
float osc9  = f_slope(_hma9,  _hma9[2])
float osc10 = f_slope(_hma10, _hma10[2])
float osc11 = f_slope(_hma11, _hma11[2])

var matrix<float> ampTerrain = matrix.new<float>(12, _bufSize, 0.0)
int _colIdx = bar_index % _bufSize
// Mode-aware: VWMA slopes (already clamped in f_slope) OR HMAs of signed-ADX (clamped via f_clampAdx).
bool _isVwma = oscType == "Hull-VWMA"
ampTerrain.set(0,  _colIdx, _isVwma ? osc0  : f_clampAdx(_aH0))
ampTerrain.set(1,  _colIdx, _isVwma ? osc1  : f_clampAdx(_aH1))
ampTerrain.set(2,  _colIdx, _isVwma ? osc2  : f_clampAdx(_aH2))
ampTerrain.set(3,  _colIdx, _isVwma ? osc3  : f_clampAdx(_aH3))
ampTerrain.set(4,  _colIdx, _isVwma ? osc4  : f_clampAdx(_aH4))
ampTerrain.set(5,  _colIdx, _isVwma ? osc5  : f_clampAdx(_aH5))
ampTerrain.set(6,  _colIdx, _isVwma ? osc6  : f_clampAdx(_aH6))
ampTerrain.set(7,  _colIdx, _isVwma ? osc7  : f_clampAdx(_aH7))
ampTerrain.set(8,  _colIdx, _isVwma ? osc8  : f_clampAdx(_aH8))
ampTerrain.set(9,  _colIdx, _isVwma ? osc9  : f_clampAdx(_aH9))
ampTerrain.set(10, _colIdx, _isVwma ? osc10 : f_clampAdx(_aH10))
ampTerrain.set(11, _colIdx, _isVwma ? osc11 : f_clampAdx(_aH11))

// Invisible anchors force the pane to always span a fixed Y range — box size stays constant.
plot( 50, color = color.new(color.black, 100), display = display.all, title = "pane anchor top")
plot(-50, color = color.new(color.black, 100), display = display.all, title = "pane anchor bottom")

// Auto-throttle the mesh when timeSpan is large — keeps line counts under max_lines_count=300.
int meshDivEff = timeSpan <= 20 ? meshDiv : timeSpan <= 40 ? math.max(meshDiv, 5) : timeSpan <= 60 ? math.max(meshDiv, 8) : math.max(meshDiv, 12)

// ---- Line-budget cascade: estimate lines, auto-disable low-priority layers (side → back → doubleMesh → floor → meshOff) ----
int   _safeBudget  = 285
int   _gY          = 200 / gridStep + 1
int   _gX          = 2 * timeSpan / gridStep + 1
bool  _useSide     = showSideGrid
bool  _useBack     = showBackGrid
bool  _useFloor    = showFloorGrid
bool  _useMesh     = showMesh
int   _meshDivAuto = meshDivEff
int _est = 16 + (_useFloor ? _gY + _gX : 0) + (_useBack ? _gY + _gX : 0) + (_useSide ? _gY + _gY : 0) + (_useMesh ? int(math.ceil(float(timeSpan) / _meshDivAuto)) * 30 : 0)
if _est > _safeBudget
    _useSide := false
    _est := 16 + (_useFloor ? _gY + _gX : 0) + (_useBack ? _gY + _gX : 0) + (_useMesh ? int(math.ceil(float(timeSpan) / _meshDivAuto)) * 30 : 0)
if _est > _safeBudget
    _useBack := false
    _est := 16 + (_useFloor ? _gY + _gX : 0) + (_useMesh ? int(math.ceil(float(timeSpan) / _meshDivAuto)) * 30 : 0)
if _est > _safeBudget
    _meshDivAuto := _meshDivAuto * 2
    _est := 16 + (_useFloor ? _gY + _gX : 0) + (_useMesh ? int(math.ceil(float(timeSpan) / _meshDivAuto)) * 30 : 0)
if _est > _safeBudget
    _useFloor := false
    _est := 16 + (_useMesh ? int(math.ceil(float(timeSpan) / _meshDivAuto)) * 30 : 0)
if _est > _safeBudget
    _useMesh := false

if barstate.islast
    for p in polyline.all
        p.delete()
    for ln in line.all
        ln.delete()
    for lbl in label.all
        lbl.delete()

    float _yawRad = yawDeg * math.pi / 180
    float _pitRad = pitchDeg * math.pi / 180

    float _cYaw = math.cos(_yawRad)
    float _sYaw = math.sin(_yawRad)
    float _cPit = math.cos(_pitRad)
    float _sPit = math.sin(_pitRad)

    Camera cam = Camera.new(
         anchorX = bar_index + offsetX,
         anchorY = 0.0 + offsetY,
         cYaw    = _cYaw,
         sYaw    = _sYaw,
         cPit    = _cPit,
         sPit    = _sPit,
         sT      = sTime,
         sA      = sAlt,
         sD      = sDepth
     )

    float T  = timeSpan
    int   Ti = timeSpan    // integer copy for loop bounds (avoids float-in-for-counter quirks)

    // Box wireframe (unchanged — 12 edges, ±T × ±100 × ±100)
    line.new(cam.project(-T, -100, -100), cam.project( T, -100, -100), color = boxColor)
    line.new(cam.project( T, -100, -100), cam.project( T, -100,  100), color = boxColor)
    line.new(cam.project( T, -100,  100), cam.project(-T, -100,  100), color = boxColor)
    line.new(cam.project(-T, -100,  100), cam.project(-T, -100, -100), color = boxColor)
    line.new(cam.project(-T,  100, -100), cam.project( T,  100, -100), color = boxColor)
    line.new(cam.project( T,  100, -100), cam.project( T,  100,  100), color = boxColor)
    line.new(cam.project( T,  100,  100), cam.project(-T,  100,  100), color = boxColor)
    line.new(cam.project(-T,  100,  100), cam.project(-T,  100, -100), color = boxColor)
    line.new(cam.project(-T, -100, -100), cam.project(-T,  100, -100), color = boxColor)
    line.new(cam.project( T, -100, -100), cam.project( T,  100, -100), color = boxColor)
    line.new(cam.project( T, -100,  100), cam.project( T,  100,  100), color = boxColor)
    line.new(cam.project(-T, -100,  100), cam.project(-T,  100,  100), color = boxColor)

    // X=0 plane (past/future divider at current bar)
    line.new(cam.project(0, -100, -100), cam.project(0,  100, -100), color = nowPlaneCol)
    line.new(cam.project(0,  100, -100), cam.project(0,  100,  100), color = nowPlaneCol)
    line.new(cam.project(0,  100,  100), cam.project(0, -100,  100), color = nowPlaneCol)
    line.new(cam.project(0, -100,  100), cam.project(0, -100, -100), color = nowPlaneCol)

    // Y=0 outline (water surface)
    array<chart.point> yZero = array.new<chart.point>()
    yZero.push(cam.project(-T, 0, -100))
    yZero.push(cam.project( T, 0, -100))
    yZero.push(cam.project( T, 0,  100))
    yZero.push(cam.project(-T, 0,  100))
    polyline.new(yZero, closed = true, fill_color = color.new(#000000, 100), line_color = yZeroEdge, line_width = 1)

    // ---- Wireframe grids (auto-throttled by line-budget cascade) ----
    if _useFloor
        for gz = -100 to 100 by gridStep
            line.new(cam.project(-T, 0, gz), cam.project(T, 0, gz), color = gridColor)
        for gx = -Ti to Ti by gridStep
            line.new(cam.project(gx, 0, -100), cam.project(gx, 0, 100), color = gridColor)
    if _useBack
        for gy = -100 to 100 by gridStep
            line.new(cam.project(-T, gy, 100), cam.project(T, gy, 100), color = gridColor)
        for gx = -Ti to Ti by gridStep
            line.new(cam.project(gx, -100, 100), cam.project(gx, 100, 100), color = gridColor)
    if _useSide
        for gy = -100 to 100 by gridStep
            line.new(cam.project(-T, gy, -100), cam.project(-T, gy, 100), color = gridColor)
        for gz = -100 to 100 by gridStep
            line.new(cam.project(-T, -100, gz), cam.project(-T, 100, gz), color = gridColor)

    // ---- MOMENTUM TERRAIN: 20 depth layers, 19 strips ----
    // Ring-buffer aware: head = current slot, oldest = (head - (timeSpan-1)) mod bufSize
    int rsiHead   = bar_index % _bufSize
    int rsiOldest = (rsiHead - (timeSpan - 1) + _bufSize * 10) % _bufSize
    float zStepR  = 200.0 / 19.0
    for d = 0 to 18
        array<chart.point> terrR = array.new<chart.point>()
        float zd1 = -100.0 + d       * zStepR
        float zd2 = -100.0 + (d + 1) * zStepR
        for tt = 0 to timeSpan - 1
            int hxi = (rsiOldest + tt) % _bufSize
            terrR.push(cam.project(tt - timeSpan, rsiTerrain.get(d, hxi), zd1))
        for tt = timeSpan - 1 to 0
            int hxi = (rsiOldest + tt) % _bufSize
            terrR.push(cam.project(tt - timeSpan, rsiTerrain.get(d + 1, hxi), zd2))
        int midT  = timeSpan / 2
        int midHx = (rsiOldest + midT) % _bufSize
        float avgR = (rsiTerrain.get(d, midHx) + rsiTerrain.get(d + 1, midHx)) / 2.0
        color rCol = f_rsiColor(avgR)
        polyline.new(terrR, closed = true, fill_color = color.new(rCol, 88), line_color = color.new(rCol, 65), line_width = 1)

    // Dotted mesh columns through all 20 momentum layers
    if _useMesh
        for tt = 0 to timeSpan - 1 by _meshDivAuto
            int hxi = (rsiOldest + tt) % _bufSize
            for d = 0 to 18
                float rvA = rsiTerrain.get(d, hxi)
                float rvB = rsiTerrain.get(d + 1, hxi)
                float zd  = -100.0 + d       * zStepR
                float zd1 = -100.0 + (d + 1) * zStepR
                color segC = f_rsiColor((rvA + rvB) / 2.0)
                line.new(cam.project(tt - timeSpan, rvA, zd), cam.project(tt - timeSpan, rvB, zd1), color = color.new(segC, 80), width = 1, style = line.style_dotted)

    // ---- Oscillator carpet (past): 12 layers — unified Hull-VWMA slopes OR signed-ADX HMAs per oscType ----
    if showOsc
        int head   = bar_index % _bufSize
        int oldest = (head - (timeSpan - 1) + _bufSize * 10) % _bufSize
        float zStep = 200.0 / 11.0
        for d = 0 to 10
            array<chart.point> terr = array.new<chart.point>()
            float zd1 = -100.0 + d       * zStep
            float zd2 = -100.0 + (d + 1) * zStep
            for tt = 0 to timeSpan - 1
                int hxi = (oldest + tt) % _bufSize
                float amp = ampTerrain.get(d, hxi)
                terr.push(cam.project(tt - timeSpan, amp, zd1))
            for tt = timeSpan - 1 to 0
                int hxi = (oldest + tt) % _bufSize
                float amp = ampTerrain.get(d + 1, hxi)
                terr.push(cam.project(tt - timeSpan, amp, zd2))
            int midT = timeSpan / 2
            int midHx = (oldest + midT) % _bufSize
            float midAmpD   = ampTerrain.get(d, midHx)
            float midAmpD1  = ampTerrain.get(d + 1, midHx)
            float avgAmp    = (midAmpD + midAmpD1) / 2.0
            float magAmp    = (math.abs(midAmpD) + math.abs(midAmpD1)) / 2.0
            color sideCol   = avgAmp >= 0 ? oscBullCol : oscBearCol
            color baseCol   = color.from_gradient(math.min(1.0, magAmp / 50.0), 0, 1, oscNeutCol, sideCol)
            int   fillA     = int(math.max(70.0, 94.0 - magAmp * 0.3))
            int   lineA     = int(math.max(45.0, 75.0 - magAmp * 0.2))
            polyline.new(terr, closed = true, fill_color = color.new(baseCol, fillA), line_color = color.new(baseCol, lineA), line_width = 1)

        if _useMesh
            for tt = 0 to timeSpan - 1 by _meshDivAuto
                int hxi = (oldest + tt) % _bufSize
                for d = 0 to 10
                    float amp_d  = ampTerrain.get(d, hxi)
                    float amp_d1 = ampTerrain.get(d + 1, hxi)
                    float zd_d   = -100.0 + d       * zStep
                    float zd_d1  = -100.0 + (d + 1) * zStep
                    line.new(cam.project(tt - timeSpan, amp_d,  zd_d), cam.project(tt - timeSpan, amp_d1, zd_d1), color = color.new(oscNeutCol, 75), width = 1, style = line.style_dotted)

    // ---- Axis markers: -100, 0, +100 on both Y and Z ----
    if showAxisLabels
        chart.point yPlus  = cam.project(-T,  100, 100)
        chart.point yZeroL = cam.project(-T,    0, 100)
        chart.point yMinus = cam.project(-T, -100, 100)
        label.new(yPlus.index,  yPlus.price,  "Y +100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        label.new(yZeroL.index, yZeroL.price, "Y 0",    color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        label.new(yMinus.index, yMinus.price, "Y -100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        chart.point zPlus  = cam.project(-T, -100,  100)
        chart.point zZeroZ = cam.project(-T, -100,    0)
        chart.point zMinus = cam.project(-T, -100, -100)
        label.new(zPlus.index,  zPlus.price,  "Z +100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)
        label.new(zZeroZ.index, zZeroZ.price, "Z 0",    color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)
        label.new(zMinus.index, zMinus.price, "Z -100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)

        // Y=0 plane reference points A-I
        chart.point pA = cam.project(-T, 0, -100)
        chart.point pB = cam.project( T, 0, -100)
        chart.point pC = cam.project( T, 0,  100)
        chart.point pD = cam.project(-T, 0,  100)
        chart.point pE = cam.project( 0, 0, -100)
        chart.point pF = cam.project( T, 0,    0)
        chart.point pG = cam.project( 0, 0,  100)
        chart.point pH = cam.project(-T, 0,    0)
        chart.point pI = cam.project( 0, 0,    0)
        label.new(pA.index, pA.price, "A", color = #00000000, textcolor = axisLabelCol, style = label.style_label_up,   size = size.tiny)
        label.new(pB.index, pB.price, "B", color = #00000000, textcolor = axisLabelCol, style = label.style_label_up,   size = size.tiny)
        label.new(pC.index, pC.price, "C", color = #00000000, textcolor = axisLabelCol, style = label.style_label_down, size = size.tiny)
        label.new(pD.index, pD.price, "D", color = #00000000, textcolor = axisLabelCol, style = label.style_label_down, size = size.tiny)
        label.new(pE.index, pE.price, "E", color = #00000000, textcolor = axisLabelCol, style = label.style_label_up,   size = size.tiny)
        label.new(pF.index, pF.price, "F", color = #00000000, textcolor = axisLabelCol, style = label.style_label_up,   size = size.tiny)
        label.new(pG.index, pG.price, "G", color = #00000000, textcolor = axisLabelCol, style = label.style_label_down, size = size.tiny)
        label.new(pH.index, pH.price, "H", color = #00000000, textcolor = axisLabelCol, style = label.style_label_up,   size = size.tiny)
        label.new(pI.index, pI.price, "I", color = #00000000, textcolor = axisLabelCol, style = label.style_label_center, size = size.tiny)

    // ---- FORECAST TERRAIN: slope-extrapolate each HMA layer into the future half ----
    int   _fcCurrIdx  = bar_index % _bufSize
    int   _fcSlopeLen = math.min(forecastSlopeLen, timeSpan)         // cap to ring-buffer range
    int   _fcPastIdx  = (_fcCurrIdx - _fcSlopeLen + _bufSize * 10) % _bufSize

    // Momentum forecast strips (19 between 20 layers) — always drawn regardless of oscType
    if showForecast
        for d = 0 to 18
            float _currD  = rsiTerrain.get(d,     _fcCurrIdx)
            float _pastD  = rsiTerrain.get(d,     _fcPastIdx)
            float _currD1 = rsiTerrain.get(d + 1, _fcCurrIdx)
            float _pastD1 = rsiTerrain.get(d + 1, _fcPastIdx)
            float _slopeD  = (_currD  - _pastD)  / _fcSlopeLen
            float _slopeD1 = (_currD1 - _pastD1) / _fcSlopeLen
            float zd1 = -100.0 + d       * zStepR
            float zd2 = -100.0 + (d + 1) * zStepR
            array<chart.point> fcR = array.new<chart.point>()
            for ft = 0 to timeSpan
                float vd = math.max(-100.0, math.min(100.0, _currD + _slopeD * ft * math.pow(forecastDecay, ft)))
                fcR.push(cam.project(ft, vd, zd1))
            for ft = timeSpan to 0
                float vd = math.max(-100.0, math.min(100.0, _currD1 + _slopeD1 * ft * math.pow(forecastDecay, ft)))
                fcR.push(cam.project(ft, vd, zd2))
            color rcC = f_rsiColor((_currD + _currD1) / 2.0)
            polyline.new(fcR, closed = true, fill_color = color.new(rcC, 94), line_color = color.new(rcC, 78), line_width = 1)

        // Oscillator forecast strips — unified across modes via ampTerrain
        float zStepV = 200.0 / 11.0
        for d = 0 to 10
            float _currD  = ampTerrain.get(d,     _fcCurrIdx)
            float _pastD  = ampTerrain.get(d,     _fcPastIdx)
            float _currD1 = ampTerrain.get(d + 1, _fcCurrIdx)
            float _pastD1 = ampTerrain.get(d + 1, _fcPastIdx)
            float _slopeD  = (_currD  - _pastD)  / _fcSlopeLen
            float _slopeD1 = (_currD1 - _pastD1) / _fcSlopeLen
            float zd1 = -100.0 + d       * zStepV
            float zd2 = -100.0 + (d + 1) * zStepV
            array<chart.point> fcV = array.new<chart.point>()
            for ft = 0 to timeSpan
                float vd = math.max(-100.0, math.min(100.0, _currD + _slopeD * ft * math.pow(forecastDecay, ft)))
                fcV.push(cam.project(ft, vd, zd1))
            for ft = timeSpan to 0
                float vd = math.max(-100.0, math.min(100.0, _currD1 + _slopeD1 * ft * math.pow(forecastDecay, ft)))
                fcV.push(cam.project(ft, vd, zd2))
            float _avgMag = (math.abs(_currD) + math.abs(_currD1)) / 2.0
            float _avgV   = (_currD + _currD1) / 2.0
            color _sideC  = _avgV >= 0 ? oscBullCol : oscBearCol
            color _baseC  = color.from_gradient(math.min(1.0, _avgMag / 50.0), 0, 1, oscNeutCol, _sideC)
            polyline.new(fcV, closed = true, fill_color = color.new(_baseC, 95), line_color = color.new(_baseC, 80), line_width = 1)

    //  ---- Emoji markers (mode-aware second signal for confluence) ----
    if showEmoji
        float _rsiMid    = rsiTerrain.get(9, _fcCurrIdx)
        float _rsiPast   = rsiTerrain.get(9, _fcPastIdx)
        float _rsiSlope  = (_rsiMid - _rsiPast) / _fcSlopeLen

        // Second signal is always ampTerrain middle layer — unified across modes
        float _secondMid   = ampTerrain.get(5, _fcCurrIdx)
        float _secondPast  = ampTerrain.get(5, _fcPastIdx)
        float _secondSlope = (_secondMid - _secondPast) / _fcSlopeLen

        // 🏄‍♂ at momentum (MFI/RSI) leading edge
        chart.point _rsiPt = cam.project(0, _rsiMid, 0)
        label.new(_rsiPt.index, _rsiPt.price, "🏄‍♂", color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.large)

        // ⛵ at second-signal leading edge (VWMA carpet OR signed ADX)
        chart.point _vwmaPt = cam.project(0, _secondMid, 0)
        label.new(_vwmaPt.index, _vwmaPt.price, "⛵", color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.large)

        // 🐳 / 🐋 at forecast leading edge when both middle-layer slopes agree
        bool _bullConfluence = _rsiSlope > 0 and _secondSlope > 0
        bool _bearConfluence = _rsiSlope < 0 and _secondSlope < 0
        if _bullConfluence or _bearConfluence
            string _whaleEmoji = _bullConfluence ? "🐳" : "🐋"
            float  _rsiEndY    = math.max(-100.0, math.min(100.0, _rsiMid + _rsiSlope * timeSpan * math.pow(forecastDecay, timeSpan)))
            chart.point _fcPt = cam.project(timeSpan, _rsiEndY, 0)
            label.new(_fcPt.index, _fcPt.price, _whaleEmoji, color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.huge)

//---------------------------------------------------------------------------------------------------------------------}
// end
````
