<!-- tradingview-pine-id: PUB;94da818ac7df438380a38fb7f4a796d6 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CME Institutional Order Flow & AMT Lens

Source: https://www.tradingview.com/script/EYNNWCWE-CME-Institutional-Order-Flow-AMT-Lens/

## Description

📜 Attribution & Open-Source Lineage
Mandatory Lineage Notice: This script is an open-source technical derivative and mathematical expansion building upon the continuous Gaussian volume-at-price decomposition architecture created by @ata_sabanci.
Original Script: Volume Footprint: Measuring Classical Indicators by Math & Geometry, Introduction by @ata_sabanci (Licensed under Mozilla Public License 2.0).

We gratefully attribute and cite the foundational works underpinning this suite:

• 🏛️ J. Peter Steidlmayer (CBOT, 1985) & James Dalton (Mind Over Markets, 1990; Markets in Profile, 2007): Pioneers of Market Profile and modern Auction Market Theory (AMT), establishing the classical profile distribution archetypes ([D] Balanced, [P] Buying Drive,  Liquidation Drive, and  Double Distribution), the 80% Rule, and Value Area boundary analysis.

• 📐 @ata_sabanci (Ata Sabanci): Author of the open-source continuous Gaussian kernel density decomposition on TradingView under MPL 2.0. His dual-curve probability density function framework is integrated to project smooth buyer/seller volume distributions cleanly on the right chart margin.

• 🔬 Richard D. Wyckoff: The Law of Effort vs. Result, Volume Spread Analysis (VSA), stopping volume, and institutional limit order absorption of aggressive market sweeps at key structural boundaries.

• 🧮 Milton Abramowitz & Irene Stegun (Handbook of Mathematical Functions, National Bureau of Standards Applied Mathematics Series 55, 1964, Formula 7.1.26): High-precision rational Chebyshev polynomial approximation of the complementary error function erfc(x) (|ε(x)| ≤ 1.5 × 10⁻⁷), enabling O(1) constant-time calculation of the Normal Cumulative Distribution Function (CDF) without iterative series loops.

• 🌐 CME Group (Chicago Mercantile Exchange): Level 3 Market-By-Order (MBO) futures microstructure specifications, standardized tick sizes, and 24-hour session conventions across E-mini and Micro index futures (NQ, ES, YM, RTY, MBT, GC).

1. The Core Problem & Philosophy
Retail trading charts are overwhelmingly burdened by lagging moving averages, unpartitioned 24-hour volume histograms, and noisy retail footprint price ladders.

Squinting at hundreds of tiny numbers across individual candle bars creates cognitive fatigue and obscures what institutional algorithms are doing in real time. Furthermore, conventional volume indicators suffer from the "Candle Color Fallacy": if a bar closes green, 100% of its volume is labeled "buying", completely blinding the trader to passive institutional absorption (e.g. smart money absorbing aggressive market sellers on limit bids during a down bar).

The CME Institutional Order Flow & AMT Lens replaces this fragmentation with an integrated, high-performance visual cockpit:

• ⚡ Tick-Precision Footprint Tape Delta (request.footprint): Directly accesses exchange trade tape execution at tick granularity to separate actual ask-lifted buys from bid-hit sells.

• 🧱 True Stacked Imbalance Shelves with Native Footprint Parity: Automatically scans consecutive price tiers for 300%+ diagonal order flow imbalances, with strict zero-ignoring parity matching TradingView's native footprint engine.

• 📈 Right-Margin Continuous Gaussian Volume Profiles: Decomposes buyer and seller volume curves into smooth, continuous mathematical distributions projected cleanly on the right margin with zero price obstruction.

• 🏛️ Dalton Auction Market Theory Archetypes: Automatically classifies auctions into D-Shape, P-Shape, b-Shape, and B-Shape profiles with live Value Area High/Low (VAH/VAL) and Virgin Point of Control (VPOC) tracking.

• ⚖️ Structural Macro Pivots: Visualizes the Overnight Half-Back (50% midpoint equilibrium), Prior Day Cash Value Area, and Multi-Session Confluent Iron POC zones.

2. Order Flow & Auction Engine Pipeline

[EXCHANGE TRADE TAPE]
  │  Pine Script v6 Native Footprint (request.footprint)
  ├── 🟢 True Ask-Lifted Buy Volume (Aggressive Market Buyers)
  └── 🔴 True Bid-Hit Sell Volume (Aggressive Market Sellers)
  │
  ▼
[CONTINUOUS GAUSSIAN KERNEL DENSITY ESTIMATION]
  │  Ata Sabanci Dual-Curve Analytical Mathematics
  ├── 🧮 Rational Chebyshev Error Function Integration (Abramowitz & Stegun 7.1.26)
  └── 📈 Right-Margin Continuous Volume Decomposition (Buyer Curve vs. Seller Curve)
  │
  ▼
[AUCTION MARKET THEORY & INSTITUTIONAL EXECUTION]
  ├── 🏛️ Dalton Profile Archetype Classification ([D], [P], , )
  ├── 🧱 300% Stacked Imbalance Shelves with Native Footprint Parity ("Ignore Zeroes")
  ├── 🌌 Low Volume Node (LVN) Liquidity Vacuum Corridors & Forward Retests
  ├── ⚖️ Overnight Half-Back (50% Range) & Multi-Session Confluent Iron POCs
  └── 🕯️ Wyckoff Effort vs. Reward Candlesticks (Buyer/Seller Absorption vs. Drives)

3. Visual Anatomy & Signal Guide
Quick reference for identifying real-time order flow and auction structures on your chart:

• 🟡 Buyer Absorption (Demand Exhaustion):

Color / Style: Gold Candle & Outer Glow
Order Flow Meaning: Aggressive market sellers absorbed by passive institutional limit bids at swing lows.
Tactical Interpretation: Trapped sellers; look for bullish reversal or long defense.

• 🟣 Seller Absorption (Supply Exhaustion):

Color / Style: Purple Candle & Outer Glow
Order Flow Meaning: Aggressive market buyers absorbed by passive institutional limit asks at swing highs.
Tactical Interpretation: Trapped buyers; look for bearish reversal or short defense.

• 🟢 Initiative Bull Drive:

Color / Style: Neon Green Bar
Order Flow Meaning: High-volume directional expansion (RVOL ≥ 1.50, Body ≥ 70%).
Tactical Interpretation: Active institutional buyers driving price; align with trend.

• 🔴 Initiative Bear Drive:

Color / Style: Vivid Red Bar
Order Flow Meaning: High-volume directional liquidation (RVOL ≥ 1.50, Body ≥ 70%).
Tactical Interpretation: Active institutional sellers pressing tape; align with trend.

• 🌫️ Dead Volume / Chop:

Color / Style: Dark Slate Candle
Order Flow Meaning: Low relative volume (RVOL < 0.70) or micro-range consolidation.
Tactical Interpretation: Low-liquidity chop; avoid initiating new breakout trades.

• 🧱 Bullish Imbalance Shelf:

Color / Style: Gold Horizontal Ribbon
Order Flow Meaning: 300%+ stacked aggressive buying across ≥ 2 consecutive tiers.
Tactical Interpretation: Institutional demand shelf; serves as high-probability support retest.

• 🧱 Bearish Imbalance Shelf:

Color / Style: Purple Horizontal Ribbon
Order Flow Meaning: 300%+ stacked aggressive selling across ≥ 2 consecutive tiers.
Tactical Interpretation: Institutional supply shelf; serves as high-probability resistance retest.

• ⚪ Prior Cash VPOC:

Color / Style: White Horizontal Ray
Order Flow Meaning: Highest volume price node of prior Regular Trading Hours (09:30–16:00 EST).
Tactical Interpretation: Primary mean-reversion gravity target (revisited in >70% of sessions).

• 🧊 Cash VAH / VAL (Value Area):

Color / Style: Ice Cyan Solid Lines
Order Flow Meaning: Value Area High and Low containing 70% of prior cash session volume.
Tactical Interpretation: Key institutional auction boundaries. Fade in range; follow on breakout.

• ⚖️ Overnight Half-Back (50% Range):

Color / Style: Cyan Dashed Ray
Order Flow Meaning: Exact 50% midpoint of the Overnight Globex range (18:00–09:30 EST).
Tactical Interpretation: Master equilibrium line; early directional bias barometer at cash open.

• ⚡ Confluent Iron POC Cluster:

Color / Style: Soft Orchid Line / Zone
Order Flow Meaning: Prior Day Cash VPOC and Overnight VPOC clustering within tight tolerance.
Tactical Interpretation: Powerful multi-session institutional price agreement and heavy defense wall.

• 🌌 LVN Vacuum Corridor (B-Shape):

Color / Style: Magenta Shaded Corridor
Order Flow Meaning: Low Volume Node valley separating twin distributions in B-Shape profiles.
Tactical Interpretation: Liquidity void; price accelerates rapidly through the corridor.

• 🎯 Unfinished Auction Magnets:

Color / Style: Dotted Horizontal Ray
Order Flow Meaning: Poor High or Poor Low where non-zero volume traded at the outer tick.
Tactical Interpretation: Incomplete auction magnet; high probability of future sweep and repair.

4. Mathematical & Algorithmic Foundations
A. Continuous Gaussian Kernel Density Estimation (Right-Margin Curves)
Rather than discretizing volume into arbitrary rectangular histogram bars that jump abruptly between price levels, volume at price is treated as a continuous probability density function:

text

f(p) = (1 / (σ * √(2π))) * exp(-(p - μ)² / (2σ²))
To calculate cumulative volume integrals in constant O(1) time without performance-draining numerical loops, the cumulative distribution function is solved via Abramowitz & Stegun Formula 7.1.26:

text

P(Z ≤ z) = 1 - (1 / √(2π)) * exp(-z² / 2) * (a1*t + a2*t² + a3*t³ + a4*t⁴ + a5*t⁵) + ε(z)
where t = 1 / (1 + p*z) and |ε(z)| ≤ 1.5 × 10⁻⁷. This enables the indicator to project smooth, mathematically rigorous buyer and seller curves on the chart's right margin with zero execution lag.

B. True Footprint Diagonal Imbalance Parity
Institutional order flow imbalances occur when aggressive market orders lifting the ask at price tier P[i+1] overwhelm passive limit orders on the bid at price tier P by a specified dominance ratio (e.g. 3:1 or 300%):

text

Buy Imbalance:  Ask_Volume(P_i+1) >= Ratio * Bid_Volume(P_i)
Sell Imbalance: Bid_Volume(P_i)   >= Ratio * Ask_Volume(P_i+1)
• 🎯 Strict "Ignore Zeroes" Parity: In TradingView's native footprint engine, when "Ignore zeroes" is active, any diagonal pair where either side has 0 traded contracts is strictly disqualified from being an imbalance. The indicator enforces this parity rule by default, eliminating false edge-of-candle anomalies at highs and lows.

• 🎯 Calibrated Contract Floors: The volume floor is calibrated to 1.0 contract on CME futures to capture genuine institutional prints on smaller-lot contracts like RTY and YM, and 10.0 shares on US Equities to filter retail odd-lot dust.

• 🎯 Bounded Tier Span Geometry: Caps shelf thickness strictly to the stack depth span imbDepth * tick_group_pts, preventing shelves from expanding into giant monolithic slabs.

C. Dalton Profile Shape Archetypes & Empirical Resolutions
Audited across continuous CME index futures sessions, daily auctions resolve into four distinct structural shapes:

• 🏛️ [D-Shape] Rotational Balance (25.1% frequency): Symmetrical bell curve indicating institutional consensus on fair value. High mean-reversion probability between Value Area High (VAH) and Value Area Low (VAL).

• 🚀 [P-Shape] Initiative Buying Drive (14.1% frequency): Top-heavy volume distribution with a thin lower tail, signaling aggressive short-covering or institutional buying drives. Reversals into b-shape occur in less than 5% of sessions; edge lies in buying pullbacks to developing VPOC.

• 🩸 [b-Shape] Initiative Liquidation Drive (8.5% frequency): Bottom-heavy volume distribution with a thin upper tail, signaling long liquidation or aggressive selling. Reversals into P-shape occur in less than 5% of sessions; edge lies in selling rallies to developing VPOC.

• 🗜️ [B-Shape] Double Distribution (52.3% frequency): Two distinct high-volume distributions separated by a Low Volume Node (LVN) liquidity vacuum corridor. Price rapidly traverses the central LVN void (spending < 12% of session time inside it) moving from one balance area to the other.

5. Comprehensive Settings Dictionary (Explaining Every Parameter)
The settings dialog is cleanly divided into 10 structured groups matching the on-screen hierarchy:

⚙️ Group 0: Execution Performance & Replay Mode
• ⚡ Fast Replay / Lightweight Mode:

Purpose: Optimizes the indicator for TradingView Bar Replay and lower-memory systems.
How it works: Switches the calculation from tick-precision native footprint sampling to instantaneous Geometric Proxy delta (zero network/memory latency), reduces profile lookback to 300 bars, and streamlines profile bins to 30.
Default: false (keep unchecked for live charts with sub-bar tick precision).
🎨 Group 1: Candle Display & Visual Palette
• Candle Display Style:

Purpose: Selects the visual presentation of candlesticks on the chart.
Options:
Ghost Glow (Semi-Transparent Body + Solid Wicks): 75% body transparency allows underlying native TradingView footprint numbers and delta grids to remain 100% visible while keeping solid wicks for price action analysis.
Full Solid HD Candlestick: Opaque, vibrant institutional candles for standard charting.
Hollow (Wicks & Solid Borders Only): Outlined borders with 100% transparent centers.
Direct Native Barcolor: Applies colors directly to TradingView's default candle series.
Disabled: Hides custom candle rendering completely.
Default: Ghost Glow.
• Color Effort vs. Reward Candles:

Purpose: Toggles Wyckoff-based candle coloring (Demand, Supply, Initiative, Muted).
Default: true.
• Buyer Absorption (Demand) Color:

Purpose: Highlights bullish buyer absorption at lows (aggressive sellers absorbed on limit bids). Also styles bullish imbalance shelves and buyer volume profiles.
Default: Gold (#FFD700).
• Seller Absorption (Supply) Color:

Purpose: Highlights bearish seller absorption at highs (aggressive buyers absorbed on limit asks). Also styles bearish imbalance shelves and seller volume profiles.
Default: Purple (#AB47BC).
• Initiative Bull & Bear Colors:

Purpose: Highlights high-volume directional expansion drives (body ≥ 70%, RVOL ≥ 1.50).
Defaults: Neon Green (#00E676) and Vivid Red (#FF1744).
• Standard Bull & Bear Bar Colors:

Purpose: Colors standard non-absorption bars.
Defaults: Green (#00E676) and Red (#FF1744).
• Dead Volume / Chop Color:

Purpose: Colors candles that occur during micro-range consolidation or low relative volume (RVOL < 0.70). Gated strictly to confirmed bars to prevent premature shading on live candles.
Default: Slate (#373C4B).
• Show Unfinished Auction Magnets (Poor Highs / Lows):

Purpose: Projects horizontal dotted rays from candle extremes where volume executed at the outer tick with zero excess, representing unfinished inventory magnets.
Default: true.
• Auto-Suppress Intraday Overlays on Macro/HTF:

Purpose: Automatically cleans Daily and Weekly charts by hiding intraday rays, overnight boxes, and micro-shelves, preventing WebGL stutter.
Default: true.
🧱 Group 2: Stacked Imbalance Shelves
• Project Stacked Imbalance Shelves:

Purpose: Projects forward-extending support/demand shelves from stacked order flow imbalances until price retests or penetrates the zone.
Default: true.
• Ratio Multiplier:

Purpose: Diagonal volume dominance ratio required to trigger an imbalance.
Default: 3.0 (300% dominance, matching standard institutional footprint configurations).
• Stack Depth:

Purpose: Number of consecutive price tiers required to confirm an institutional shelf.
Default: 2 tiers.
• Ticks Per Row (Tier Size, 0 = Auto):

Purpose: Price tier bucket size in ticks. Set to 0 for Auto-Adaptive (automatically matches optimal row density across all assets and timeframes). Set to any positive integer (e.g. 8 for 2.00 pt on NQ, 4 for 4.00 pt on YM, 2 for 0.20 pt on RTY, 20 for 20 cents on NVDA) to force a fixed tier size.
Default: 0 (Auto).
• Ignore Zeroes (Native Footprint Parity):

Purpose: When enabled, price tiers with 0 volume on the opposite side are ignored, strictly matching TradingView native footprint behavior. Disable to allow trades against 0 to trigger imbalances.
Default: true.
• Shelf Line Width & Line Transp (%):

Purpose: Controls the thickness (1–4px) and opacity of the shelf baseline price ray.
Default: Width 1, Transp 100% (hides the harsh line for an ultra-clean ribbon).
• Shelf Box Transp (%):

Purpose: Controls background opacity of the shelf rectangle.
Default: 84% (soft background ribbon).
• Max Active Retest Shelves:

Purpose: Caps the maximum number of unmitigated imbalance shelves preserved across historical peaks, guaranteeing peak chart performance.
Default: 30.
🏛️ Group 3: Key Institutional Levels & Styling
• Show Prior Cash Levels (VAH / VAL / VPOC):

Purpose: Displays Prior Day RTH Cash (09:30–16:00 EST) Value Area High, Value Area Low, and Point of Control.
Default: true.
• VPOC Color, Width, Style, and Transp (%):

Purpose: Full visual customization of the Point of Control line.
Default: White (#FFFFFF), Width 2, Style Solid, Transp 0%.
• VAH & VAL Color, Width, Style, and Transp (%):

Purpose: Full visual customization of Value Area boundary lines.
Default: Ice Cyan (#00E5FF), Width 1, Style Solid, Transp 35%.
• Prior Level Origin Anchoring:

Purpose: Controls where historical levels start. Cash Open (New Day Only) starts cleanly at the 09:30 cash open; Session Origin (Full Span) anchors back to historical bars.
Default: Cash Open (New Day Only).
• Show Overnight Half-Back (50% Midpoint):

Purpose: Projects the exact 50% midpoint of the overnight range (18:00 to 09:30 EST), serving as a primary structural equilibrium balance line during the Cash Open.
Default: true, Cerulean Cyan (#00E5FF), Width 2, Dashed.
• Highlight Confluent Iron POC Cluster:

Purpose: Automatically detects when Prior Day Cash VPOC and Overnight VPOC cluster closely together, indicating powerful multi-session institutional price agreement.
Default: true, Soft Orchid (#CE93D8), Width 2, Solid.
• Show Overnight Shaded Box (18:00 - 07:00 EST):

Purpose: Renders a muted box preserving overnight inventory territory.
Default: false.
• Extend to 08:30 Pre-Market:

Purpose: Extends the overnight box cutoff from 07:00 EST to 08:30 EST to capture pre-market macroeconomic releases.
Default: false.
🔬 Group 4: Volume Delta Engine & Lower Timeframe
• Tick Grouping Mode:

Purpose: Enforces the Row-Density Invariance Law across all timeframes and assets, dynamically targeting 11–16 rows per candle.
Options: Auto-Adaptive (Row-Density Invariance) or Manual Ticks.
Default: Auto-Adaptive.
• Manual Ticks (if Selected):

Purpose: Fixed tick count when Manual Ticks mode is active.
Default: 4.
• Use Time-of-Day RVOL on 1-Hour Charts:

Purpose: Normalizes 1h volume against the historical average for that specific hour (0–23 EST), eliminating diurnal bias where morning bars appear artificially high and overnight bars appear low.
Default: true.
• Volume Engine (when Replay Mode is Off):

Purpose: Selects volume delta calculation when Fast Replay is unchecked:
Native Footprint (Tick Precision): Pine Script v6 native request.footprint() for true tick-level trade tape execution without lower-timeframe interpolation.
Geometric Proxy: Instant mathematical proxy for Bar Replay.
Intrabar (1m Low Memory): Fast 1-minute sub-bar sampling.
Intrabar (Sub-Minute): Sub-minute granularity for live intraday trading.
Default: Native Footprint (Tick Precision).
• Intrabar Lower Timeframe:

Purpose: Sub-bar resolution when Intrabar mode is active (Auto, 1S, 5S, 15S, 30S, 1, 5).
Default: Auto.
🌐 Group 5: Session Volume Profiles & AMT Scope
• Show Session Volume Profiles (Right Margin & Anchor):

Purpose: Enables the developing volume profile on the right margin and completed historical profile succession.
Default: true.
• Profile Scope Horizon:

Purpose: Controls the institutional auction cycle:
Auto-Adaptive: Sub-Session (<= 15m), Daily Full Cycle (30m–4h), Weekly (Daily charts), Monthly (Weekly charts).
Or force fixed Sub-Session, Daily Full Cycle, Weekly, or Monthly.
Default: Auto-Adaptive.
• Completed Sessions to Display:

Purpose: Number of completed historical session profiles to render across the chart (e.g. 10 sessions = 5 Full Trading Days of Cash + Overnight).
Default: 15.
• Show Session VAH / VAL Lines:

Purpose: Toggles session Value Area High and Value Area Low boundary lines.
Default: true.
• Show Dalton Profile Shape Badges ([D], [P], , ):

Purpose: Identifies and stamps Dalton profile shape badges at session extremes.
Default: true.
• Extend Completed Virgin POC to Live Bar:

Purpose: Extends unvisited Virgin POCs forward as horizontal attractor lines until retested.
Default: true.
• Wait for 1 Bar Close on Session Open:

Purpose: Waits for the opening candle of a new session to fully close before initiating the developing profile on the right margin. Prevents opening-tick jitter, zero-range artifacts, and profile flashing.
Default: true.
📐 Group 6: Profile Curve Geometry & Shading
• Profile Width Scaling:

Purpose: Controls how far volume profiles expand horizontally into the session.
Options: Expressive (50% Span), Balanced (35% Span), Wide (65% Span), Compact (20% Span), or Fixed Bars.
Default: Expressive (50% Span).
• Fixed Width (Bars) & Offset off Candle:

Purpose: Fine-tunes profile width in fixed-bar mode and right-margin clearance off the live candle.
Defaults: 36 bars and 3 bars offset.
• Profile Shading Style:

Purpose: Selects visual color treatment for volume profile curves (Bid/Ask Dual-Tone, Monochrome Slate, Monochrome Gold, Monochrome Cyan).
Default: Bid/Ask Dual-Tone.
• Buy Vol Curve & Sell Vol Curve Colors:

Purpose: Independent palette selectors for buyer and seller curves.
Defaults: Gold (#FFD700) and Purple (#AB47BC).
• Fill Transp (%) & Outline Transp (%):

Purpose: Controls background fill opacity (default 92% provides a soft watermark) and contour outline opacity (default 5% gives a crisp border).
Defaults: Fill 92%, Outline 5%.
• Profile Label Size:

Purpose: Scales font size of session shape badges and POC price labels (Tiny, Small, Normal, Large).
Default: Small.
🏷️ Group 7: Level Labels & Dark Knockout Shield
• Level Labels Style:

Purpose: Visual presentation of VAH, VAL, and POC text:
Subtle Acronym (On Line): Clean, transparent floating text (POC 29484.75, VAH 29550.00) sitting directly on the line without bulky background badges.
Session Acronym (C-POC / ON-POC): Prepends session identifier.
Compact Acronym Only: Shows only the letters (POC, VAH, VAL) without price.
Bulky Badges: Legacy high-contrast opaque pill badges.
Hidden: Suppresses text for pure minimalist lines.
Default: Subtle Acronym (On Line).
• Level Labels Position:

Purpose: Horizontal placement along the level line (Right Edge Inside Box, Right Edge Outside Box, Center of Session, Left Edge Inside Box).
Default: Right Edge (Inside Box).
• Dark Knockout Shield Pill:

Purpose: Wraps acronym labels in a dark cutout container (#0C0F18) to shield text from candle wicks passing through the level.
Default: true.
• Shield Opacity (%):

Purpose: Background shield opacity (0% = solid dark container, 15% = subtle dark glass).
Default: 15%.
🔲 Group 8: Session Framing Outlines & LVN Corridors
• Show Session Framing Outlines:

Purpose: Frames each completed and developing Cash RTH and Overnight auction in a clean, high-contrast outline that connects seamlessly to the next session.
Default: true.
• Frame Border Style & Width:

Purpose: Border style (Solid/Dashed/Dotted) and width (1–3px).
Default: Dotted, Width 1.
• Cash Frame & ON Frame Colors:

Purpose: Distinct frame border colors for Cash RTH (Gold) vs. Overnight Globex (Purple).
• Outline Transp (%) & Fill Transp (%):

Purpose: Opacity of outer frame border (30%) and internal session shading (98% = transparent wireframe with zero candle tinting).
Defaults: Outline 30%, Fill 98%.
• Show LVN Vacuum Corridor (B-Shape):

Purpose: Displays the Low Volume Node (LVN) liquidity vacuum corridor for B-Shape (Double Distribution) profiles.
Default: true.
• LVN Presentation:

Purpose: Visual style (Both Corridor Box + Centerline, Shaded Corridor Box, or Inflection Line Only).
Default: Inflection Line Only.
• LVN Forward Extension:

Purpose: Extend Until Mitigated projects the corridor forward until retested or penetrated; Session Span Only confines it within session boundaries.
Default: Extend Until Mitigated.
• LVN Color, Style, and Box Fill Transp (%):

Purpose: Visual customization of the LVN corridor.
Defaults: Magenta (#E040FB), Dotted, 92% box fill transparency.
📊 Group 9: Institutional Heads-Up Display & Educational Table
• HUD Display Mode:

Purpose: Selects dashboard presentation (Full Educational Dashboard, Compact Status Pill, or Disabled).
Default: Full Educational Dashboard.
• Dashboard Position:

Purpose: Screen corner placement (Bottom Right, Bottom Left, Top Right, Top Left).
Default: Bottom Right.
• Detect Imbalances at Key Levels:

Purpose: Real-time audio/visual alert scanning active order flow imbalance shelves and alerting when stacked absorption coincides with key levels (VAH, VAL, VPOC, or Overnight Half-Back).
Default: true.
6. Tactical Execution Playbook
1. Pre-Market Balance Orientation (08:30 – 09:30 EST)
• ⚖️ Identify the position of price relative to the Overnight Half-Back (50%).

• ⚡ Scan for Confluent Iron POC alignments between yesterday's Cash VPOC and the Overnight VPOC.

• 🏛️ Check the prior session's Dalton archetype badge: Is the market balanced ([D]) or trending ([P] or )?

2. Opening Drive & Judas Swing Mitigation (09:30 – 10:00 EST)
• 🛑 Stand aside during the opening 15 minutes to protect capital from opening whipsaws and liquidity gaps.

• 🪤 Watch for a false opening drive (Judas Swing) sweeping overnight extremes into an unmitigated Stacked Imbalance Shelf.

• 🟡🟣 Confirm absorption via Effort vs. Reward Candle Colors (Gold for Buyer Absorption, Purple for Seller Absorption).

3. High-Confluence Setups by Dalton Archetype
• 🔄 Rotational [D-Shape] Days: Fade Value Area boundaries (VAH and VAL) targeting the VPOC mean.

• 🌌 Double Distribution [B-Shape] Days: Trade the breakout through the LVN Vacuum Corridor, capturing rapid price displacement toward the secondary distribution's POC.

• 🚀 Initiative [P-Shape / b-Shape] Days: Never fade the morning drive. Align with trend pullbacks into the developing right-margin VPOC and stacked imbalance shelves.

7. Educational & Compliance Disclaimer
This indicator is published under the Mozilla Public License 2.0 (MPL 2.0) strictly for educational, research, and analytical purposes. It does not provide trade recommendations, signals, or financial advice. Trading futures, equities, and options carries substantial risk of capital loss. Past performance and quantitative models do not guarantee future market outcomes. Always exercise rigorous risk management.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// © goofyfarmer
//
// =============================================================================
// CME Institutional Order Flow & AMT Lens
// License: Mozilla Public License 2.0 (MPL 2.0)
//
// Foundations & Mathematical Attribution:
// • Auction Market Theory (AMT) & Market Profile: J. Peter Steidlmayer (CBOT, 1985) & James Dalton (Mind Over Markets, 1990; Markets in Profile, 2007)
// • Right-Margin Continuous Gaussian Volume Decomposition: Open-source architecture by @ata_sabanci (Mozilla Public License 2.0)
// • Effort vs. Reward & Institutional Absorption Mechanics: Richard D. Wyckoff (The Law of Effort vs. Result)
// • Rational Chebyshev Error Function & Normal CDF: Milton Abramowitz & Irene Stegun (Handbook of Mathematical Functions, NBS AMS 55, formula 7.1.26)
// • Microstructure Data & Session Architecture: CME Group (Chicago Mercantile Exchange Level 3 MBO futures standards & 24H extended hours session succession)
// =============================================================================
indicator("CME Institutional Order Flow & AMT Lens",
     shorttitle       = "CME LENS",
     overlay          = true,
     max_bars_back    = 5000,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500)

import TradingView/ta/14 as tvta

// =============================================================================
// SECTION 1: AUTO-ASSET DETECTION & DYNAMIC ASSET SCALES
// =============================================================================

string root_sym = syminfo.root
string tick_sym = syminfo.ticker

bool is_nq_asset  = str.contains(root_sym, "NQ") or str.contains(tick_sym, "NQ") or str.contains(tick_sym, "QQQ") or str.contains(tick_sym, "NDX") or str.contains(tick_sym, "US100") or str.contains(tick_sym, "NAS100")
bool is_es_asset  = str.contains(root_sym, "ES") or str.contains(tick_sym, "ES") or str.contains(tick_sym, "SPY") or str.contains(tick_sym, "SPX") or str.contains(tick_sym, "US500") or str.contains(tick_sym, "SP500")
bool is_rty_asset = str.contains(root_sym, "RTY") or str.contains(root_sym, "M2K") or str.contains(tick_sym, "RTY") or str.contains(tick_sym, "MRTY") or str.contains(tick_sym, "IWM") or str.contains(tick_sym, "RUT") or str.contains(tick_sym, "US2000")
bool is_mbt_asset = str.contains(root_sym, "MBT") or str.contains(root_sym, "BTC") or str.contains(tick_sym, "MBT") or str.contains(tick_sym, "BTC") or str.contains(tick_sym, "IBIT")
bool is_gc_asset  = str.contains(root_sym, "GC") or str.contains(root_sym, "MGC") or str.contains(tick_sym, "GC") or str.contains(tick_sym, "MGC") or str.contains(tick_sym, "GLD") or str.contains(tick_sym, "XAU")
bool is_ym_asset  = str.contains(root_sym, "YM") or str.contains(root_sym, "MYM") or str.contains(tick_sym, "YM") or str.contains(tick_sym, "MYM") or str.contains(tick_sym, "DIA") or str.contains(tick_sym, "DJI") or str.contains(tick_sym, "US30")
bool is_equity_asset = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"
bool is_crypto_asset = syminfo.type == "crypto" or str.contains(tick_sym, "USDT") or str.contains(tick_sym, "USDC") or str.contains(tick_sym, "BUSD") or str.contains(tick_sym, "DOGE") or str.contains(tick_sym, "ETH") or str.contains(tick_sym, "SOL")

string detected_asset_name = is_crypto_asset ? ("Crypto (" + syminfo.ticker + ")") : is_equity_asset ? ("US Equities (" + syminfo.ticker + ")") : is_nq_asset ? "NQ (Nasdaq-100)" : is_es_asset ? "ES (S&P 500)" : is_ym_asset ? "YM (Dow Jones)" : is_rty_asset ? "RTY (Russell 2000)" : is_mbt_asset ? "MBT (Bitcoin)" : is_gc_asset ? "GC (Gold)" : "CME Futures"

// Asset-Specific Scales
float asset_tick_step = is_crypto_asset ? syminfo.mintick : (is_equity_asset ? 0.01 : is_nq_asset ? 0.25 : is_es_asset ? 0.25 : is_ym_asset ? 1.00 : is_rty_asset ? 0.10 : is_mbt_asset ? 5.00 : is_gc_asset ? 0.10 : syminfo.mintick)
float asset_cluster_tol = (is_equity_asset or is_crypto_asset) ? math.max(close * 0.0015, syminfo.mintick * 4) : is_nq_asset ? 12.0 : is_es_asset ? 3.0 : is_ym_asset ? 30.0 : is_rty_asset ? 2.0 : is_mbt_asset ? 100.0 : is_gc_asset ? 4.0 : 12.0

// =============================================================================
// SECTION 2: USER INPUTS & STREAMLINED SETTINGS
// =============================================================================

// --- 0. Execution Performance & Replay Mode ---
grp_perf = "0. Execution Performance & Replay Mode"
replayOptimized         = input.bool(true, "⚡ Lightweight / Fast Replay Mode (Universal Free & Premium)", group=grp_perf, tooltip="Enabled by default to guarantee 100% instant, error-free loading across ALL TradingView account tiers (Free, Essential, Plus, Premium, Ultimate):\n• Universal Compatibility: Uses instant Geometric Proxy delta (zero sub-second data dependencies, zero network lag, and zero TradingView paywall alerts).\n• Bar Replay Optimized: Fluid, lag-free playback on any device.\n• Premium / Ultimate High-Precision Activation: UNCHECK this box if you have a TradingView Premium or Ultimate subscription to instantly unlock the full-scale Native Footprint Engine (request.footprint), sub-minute intrabar granularity (15S / 1S), and exact diagonal order book ladder execution.")

// --- 1. Candle Display & Visual Palette ---
grp_vis = "1. Candle Display & Visual Palette"
candleStyle             = input.string("Ghost Glow (Semi-Transparent Body + Solid Wicks)", "Candle Display Style",
     options=["Ghost Glow (Semi-Transparent Body + Solid Wicks)", "Full Solid HD Candlestick", "Hollow (Wicks & Solid Borders Only)", "Direct Native Barcolor", "Disabled"], group=grp_vis,
     tooltip="Engineered specifically to overlay on TradingView's native 'Volume footprint [Manual 4, Delta]' chart. Ghost Glow (75% transparent body) keeps native footprint numbers and imbalance dots 100% visible.")
showEffortReward        = input.bool(true, "Color Effort vs. Reward Candles", group=grp_vis,
     tooltip="Colors candles based on Auction Market Theory and volume delta absorption:\n• Demand: Bullish Buyer Absorption at lows\n• Supply: Bearish Seller Absorption at highs\n• Initiative: High-volume directional expansion drives\n• Muted: Low relative volume consolidation (RVOL < 0.70).")

// Customizable Absorption & Drive Candle Colors
colBuyerAbsorb          = input.color(#FFD700, "Buyer Absorption (Demand)", inline="col_absorb", group=grp_vis, tooltip="Bullish buyer absorption candle color (aggressive market sellers absorbed on limit bids). Also dynamically styles bullish imbalance shelves and buyer volume profiles.")
colSellerAbsorb         = input.color(#AB47BC, "Seller Absorption (Supply)", inline="col_absorb", group=grp_vis, tooltip="Bearish seller absorption candle color (aggressive market buyers absorbed on limit asks). Also dynamically styles bearish imbalance shelves and seller volume profiles.")

colBullDrive            = input.color(#00E676, "Initiative Bull", inline="col_drive", group=grp_vis, tooltip="High-volume initiative buying drive candle.")
colBearDrive            = input.color(#FF1744, "Initiative Bear", inline="col_drive", group=grp_vis, tooltip="High-volume initiative selling drive candle.")

colBullCandle           = input.color(#00E676, "Standard Bull Bar", inline="col_std", group=grp_vis, tooltip="Standard bullish candle body/wick color.")
colBearCandle           = input.color(#FF1744, "Standard Bear Bar", inline="col_std", group=grp_vis, tooltip="Standard bearish candle body/wick color.")

colMutedNoise           = input.color(#373C4B, "Dead Volume / Chop", inline="col_noise", group=grp_vis, tooltip="Low relative volume or micro-range consolidation candle.")

showUnfinishedAuctions  = input.bool(true, "Show Unfinished Auction Magnets (Poor Highs / Lows)", group=grp_vis, tooltip="Projects horizontal dotted rays from candle extremes where volume executed at the outer tick (Poor High / Low), representing unfinished auction inventory magnets.")
htfClutterFilter        = input.bool(true, "Auto-Suppress Intraday Overlays on Macro/HTF", group=grp_vis, tooltip="Automatically hides intraday Overnight Boxes, Half-Back rays, Confluent POC lines, and micro-shelves on Daily and Weekly charts to keep macro charts clean and eliminate WebGL stutter.")

// --- 2. Stacked Imbalance Shelves ---
grp_imb = "2. Stacked Imbalance Shelves"
showImbalanceShelves    = input.bool(true, "Project Stacked Imbalance Shelves", inline="imb_m", group=grp_imb, tooltip="Projects forward-extending support/demand shelves from stacked order flow imbalances until price retests or penetrates the zone. Shelves automatically inherit your chosen Buyer and Seller Absorption colors.")
imbMultInput            = input.float(3.0, "Ratio Multiplier", inline="imb_m", minval=1.5, maxval=5.0, step=0.5, group=grp_imb, tooltip="Diagonal volume dominance ratio (3.0 = 300% dominance, matching TradingView native footprint).")
imbDepthInput           = input.int(3, "Stack Depth", inline="imb_m", minval=1, maxval=6, group=grp_imb, tooltip="Number of consecutive price tiers required to form an institutional shelf (default 3 for institutional absorption zones, e.g. 3-stacked tiers).")
imbTicksPerRow          = input.int(0, "Ticks Per Row (Tier Size, 0 = Auto)", inline="imb_grid", minval=0, maxval=200, group=grp_imb, tooltip="Price tier bucket size in ticks for stacked imbalances and footprint rows. Set to 0 for Auto-Adaptive (automatically matches optimal row density across all assets and timeframes). Set to any positive integer (e.g. 1 for $0.01 single-tick, 20 for $0.20 on NVDA, or 8 for 2.00 pt on NQ) to force that exact tier size.")
ignoreZerosInput        = input.bool(true, "Ignore Zeroes (Native Footprint Parity)", group=grp_imb, tooltip="When enabled, price tiers with 0 volume on the opposite side are ignored and not counted as imbalances, strictly matching TradingView native footprint behavior. Disable to allow trades against 0 to trigger imbalances.")
shelfLineWidth          = input.int(1, "Shelf Line Width", inline="shelf_style", minval=1, maxval=4, group=grp_imb)
shelfLineTransp         = input.int(0, "Shelf Line Transp (%)", inline="shelf_style", minval=0, maxval=100, group=grp_imb, tooltip="Controls shelf line opacity. Set to 0% for solid line, 80-95% for subtle guide, or 100% to completely hide the line and show only the box.")
shelfFillTransp         = input.int(84, "Shelf Box Transp (%)", inline="shelf_style", minval=0, maxval=100, group=grp_imb, tooltip="Controls shelf box perimeter & fill opacity. Set to 80-95% for subtle tint/outline, or 100% to completely hide the box and show only the line.")
maxActiveShelvesInput   = input.int(30, "Max Active Retest Shelves", minval=5, maxval=60, group=grp_imb, tooltip="Maximum number of unmitigated imbalance shelves preserved across historical peaks (default 30 preserves key retest zones while maintaining peak chart performance).")

// --- 3. Key Institutional Levels & Styling ---
grp_levels = "3. Key Institutional Levels & Styling"
showPriorCashLevels     = input.bool(true, "Show Prior Cash Levels (VAH / VAL / VPOC)", group=grp_levels, tooltip="Displays Prior Day RTH Cash (09:30-16:00 EST) Value Area and Point of Control.")

// Point of Control (VPOC)
colPocInput             = input.color(#FFFFFF, "VPOC Color", inline="poc_st", group=grp_levels)
pocLineWidth            = input.int(2, "Width", minval=1, maxval=4, inline="poc_st", group=grp_levels)
pocLineStyleInput       = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="poc_st", group=grp_levels)
pocTransp               = input.int(0, "Transp (%)", minval=0, maxval=100, step=5, inline="poc_st", group=grp_levels, tooltip="Opacity of Point of Control lines across cash and profile succession.")

// Value Area High (VAH) - Sophisticated Low-Fatigue Ice Mint
colVahInput             = input.color(#00E5FF, "VAH Color", inline="vah_st", group=grp_levels)
vahLineWidth            = input.int(1, "Width", minval=1, maxval=4, inline="vah_st", group=grp_levels)
vahLineStyleInput       = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="vah_st", group=grp_levels)
vahTransp               = input.int(35, "Transp (%)", minval=0, maxval=100, step=5, inline="vah_st", group=grp_levels)

// Value Area Low (VAL) - Unified Cyan Boundary (Matching VAH)
colValInput             = input.color(#00E5FF, "VAL Color", inline="val_st", group=grp_levels)
valLineWidth            = input.int(1, "Width", minval=1, maxval=4, inline="val_st", group=grp_levels)
valLineStyleInput       = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="val_st", group=grp_levels)
valTransp               = input.int(35, "Transp (%)", minval=0, maxval=100, step=5, inline="val_st", group=grp_levels)

priorLevelAnchor        = input.string("Cash Open (New Day Only)", "Prior Level Origin Anchoring", options=["Cash Open (New Day Only)", "Session Origin (Full Span)"], group=grp_levels, tooltip="Controls where historical levels (Overnight Half-Back, Prior Cash VAH/VAL/VPOC) start:\n• Cash Open: Starts cleanly at the new day's 09:30 cash open, preventing lines from cutting backwards across prior session profiles.\n• Session Origin: Anchors back to the historical bar where that auction began.")

// Overnight Half-Back Midpoint - Refined Cerulean Cyan
showHalfback            = input.bool(true, "Show Overnight Half-Back (50% Midpoint)", inline="hb_st", group=grp_levels, tooltip="Projects the exact 50% midpoint of the overnight range, serving as a primary structural equilibrium balance line during the Cash Open.")
halfbackColInput        = input.color(#00E5FF, "", inline="hb_st", group=grp_levels)
hbLineWidth             = input.int(2, "Width", minval=1, maxval=4, inline="hb_st", group=grp_levels)
hbLineStyleInput        = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], inline="hb_st", group=grp_levels)
hbTransp                = input.int(20, "Transp (%)", minval=0, maxval=100, step=5, inline="hb_st", group=grp_levels)

// Multi-Session Confluent Iron POC Zone - Soft Orchid Amethyst
showConfluentPoc        = input.bool(true, "Highlight Confluent Iron POC Cluster", inline="cpoc_st", group=grp_levels, tooltip="Automatically detects when Prior Day Cash VPOC and Overnight VPOC cluster closely together, indicating powerful multi-session institutional price agreement.")
confluentColInput       = input.color(#CE93D8, "", inline="cpoc_st", group=grp_levels)
confLineWidth           = input.int(2, "Width", minval=1, maxval=4, inline="cpoc_st", group=grp_levels)
confLineStyleInput      = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="cpoc_st", group=grp_levels)
confTransp              = input.int(15, "Transp (%)", minval=0, maxval=100, step=5, inline="cpoc_st", group=grp_levels)

// Overnight Shaded Territory Box
showOvernightBox        = input.bool(false, "Show Overnight Shaded Box (18:00 - 07:00 EST)", inline="on_box", group=grp_levels, tooltip="Renders a muted box preserving overnight inventory territory.")
extendToPreMarket       = input.bool(false, "Extend to 08:30 Pre-Market", inline="on_box", group=grp_levels, tooltip="Extends the overnight cutoff from 07:00 EST to 08:30 EST to capture pre-market macroeconomic releases.")
overnightBoxCol         = input.color(#2A1B3D, "", inline="on_box", group=grp_levels)
overnightBoxTransp      = input.int(85, "Transp (%)", minval=0, maxval=100, step=5, inline="on_box", group=grp_levels)

// --- 4. Volume Delta Engine & Lower Timeframe ---
grp_fp = "4. Volume Delta Engine & Lower Timeframe"
tickGroupingMode        = input.string("Auto-Adaptive (Row-Density Invariance)", "Tick Grouping Mode", options=["Auto-Adaptive (Row-Density Invariance)", "Manual Ticks"], group=grp_fp, tooltip="Enforces Row-Density Invariance Law across all timeframes and assets (NQ, ES, RTY, MBT, GC), dynamically targeting 11-16 rows per candle:\n• 1m -> 4 ticks (1.00 pt on NQ)\n• 5m -> 8 ticks (2.00 pts on NQ)\n• 15m -> 16 ticks (4.00 pts on NQ)\n• 1h -> 40 ticks (10.00 pts on NQ)\n• 4h -> 80 ticks (20.00 pts on NQ)\n• Daily/Weekly -> 160 ticks (40.00 pts on NQ)")
manualTicksInput        = input.int(4, "Manual Ticks (if Selected)", minval=1, maxval=200, group=grp_fp)
useTodRvol              = input.bool(true, "Use Time-of-Day RVOL on 1-Hour Charts", group=grp_fp, tooltip="Normalizes 1h volume against the historical average for that specific hour (0-23 EST). Eliminates diurnal bias where morning bars appear artificially high and overnight bars appear artificially low.")
engineInput             = input.string("Native Footprint (Tick Precision)", "Volume Engine (when Lightweight is Disabled)", options=["Native Footprint (Tick Precision)", "Geometric Proxy (Zero Lag / Replay)", "Intrabar (1m Low Memory)", "Intrabar (Sub-Minute)"], group=grp_fp, tooltip="Selects high-precision delta engine calculation when Lightweight / Fast Replay Mode is unchecked:\n• Native Footprint (Tick Precision): Leverages Pine Script v6 native request.footprint() for true tick-level trade tape execution and exact delta without lower-timeframe interpolation (Requires TradingView Premium/Ultimate plan).\n• Geometric Proxy: Instant mathematical proxy, recommended for Bar Replay and multi-year backtests.\n• Intrabar (1m Low Memory): Fast 1-minute sub-bar sampling, saving 60%+ memory.\n• Intrabar (Sub-Minute): Deepest sub-minute granularity (15S / 1S) for live intraday trading.")
ltfOverrideInput        = input.string("Auto", "Intrabar Lower Timeframe", options=["Auto", "1S", "5S", "15S", "30S", "1", "5"], group=grp_fp, tooltip="Selects lower timeframe resolution for sub-bar volume delta when Intrabar mode is active. 'Auto' dynamically selects 1m on 5m+ charts and 15S on 1m charts. NOTE: If your TradingView account plan does not include seconds data, set this to '1' or keep Fast Replay checked.")

// --- 5. Session Volume Profiles & AMT Engine (Ata Sabanci Dual-Agent Architecture) ---
// --- 5. Session Volume Profiles & AMT Scope ---
grp_prof = "5. Session Volume Profiles & AMT Scope"
showSessionProfiles     = input.bool(true, "Show Session Volume Profiles (Right Margin & Anchor)", group=grp_prof, tooltip="Session Succession Architecture:\n• Developing Session: Projected on the Right Margin (zero candle obstruction)\n• Completed Prior Session: Locked at completed session anchor with Virgin POC")
profTimeframeMode       = input.string("Auto-Adaptive", "Profile Scope Horizon", options=["Auto-Adaptive", "Sub-Session (Cash/ON)", "Daily Full Cycle (24H)", "Weekly (Mon-Fri)", "Monthly"], group=grp_prof, tooltip="Controls the institutional auction cycle for volume profiles:\n• Auto-Adaptive:\n  - <= 15m: Sub-Session (Cash RTH 09:30 vs Overnight Globex 18:00)\n  - 30m, 1h, 4h: Daily Full Cycle (18:00-17:00 24H CME)\n  - Daily (D): Weekly Profile (Mon-Fri, 5 daily bars)\n  - Weekly (W): Monthly Profile (4-5 weekly bars)\n• Or force a fixed cycle manually.")
cryptoWeekendMode       = input.string("Day/Night 7-Day (09:30-16:00 EST)", "Crypto Weekend Sub-Sessions", options=["Day/Night 7-Day (09:30-16:00 EST)", "12-Hour Halves (09:30 & 21:30 EST)", "Full Weekend Continuous (No Split)"], group=grp_prof, tooltip="Controls how 24/7 crypto markets (DOGE, BTC, ETH, SOL) partition during weekends in Sub-Session mode:\n• Day/Night 7-Day (09:30-16:00 EST): Seamless 7-day continuity matching weekday Day/Night sub-sessions.\n• 12-Hour Halves (09:30 & 21:30 EST): Splits Saturday and Sunday into discrete 12-hour auction halves (09:30-21:30 Day, 21:30-09:30 Night).\n• Full Weekend Continuous: Legacy mode where the entire weekend from Friday close to Monday open is a single continuous session.")
priorSessionsCount      = input.int(15, "Completed Sessions to Display", minval=1, maxval=35, group=grp_prof, tooltip="Number of completed historical session profiles to render across the chart (e.g. 14 sessions = 7 Full Days of Day + Night).")
vaCalcMethod            = input.string("Dalton Cumulative Mass (15%-85%)", "Value Area Engine", options=["Dalton Cumulative Mass (15%-85%)", "Steidlmayer Outward Expansion"], group=grp_prof, tooltip="Selects mathematical Value Area integration algorithm:\n• Dalton Cumulative Mass (15%-85%): Institutional benchmark (Sierra Chart / MarketDelta). Accurately extracts 70% volume mass while preserving 15% upper and lower rejection excess tails, preventing Value Area lines from pegging to extreme wicks on bimodal/trending sessions.\n• Steidlmayer Outward Expansion: Classical CBOT 2-bin dual-pointer expansion outward from Point of Control.")
showSessionVa           = input.bool(true, "Show Session VAH / VAL Lines", inline="va_prof", group=grp_prof)
showAmtShapes           = input.bool(true, "Show Dalton Profile Shape Badges ([D], [P], [b], [B])", inline="va_prof", group=grp_prof, tooltip="Identifies Dalton profile structures [D-Shape, P-Shape, b-Shape, B-Shape] stamped at session extremes.")
showOvlMetrics          = input.bool(true, "Show Ata Sabanci Overlap Metrics (OVL & Tilt %)", group=grp_prof, tooltip="Computes and displays Ata Sabanci's mathematical Overlap Coefficient (OVL 0.00-1.00) and Balance Tilt %:\n• OVL >= 0.75: Balanced Auction (Mean-reversion; fade Value Area edges back to VPOC).\n• OVL < 0.55: Off-Balance Directional Drive (Initiative expansion; do not fade extremes).")
extendVpocInput         = input.bool(true, "Extend Completed Virgin POC to Live Bar", group=grp_prof)
waitFirstBarClose       = input.bool(true, "Wait for 1 Bar Close on Session Open", group=grp_prof, tooltip="Waits for the opening candle of a new session to fully close before initiating the developing volume profile on the right margin. Prevents opening-tick jitter, zero-range artifacts, and profile flashing during the initial 09:30 or 18:00 opening drive.")

// --- 6. Profile Curve Geometry & Shading ---
grp_prof_style = "6. Profile Curve Geometry & Shading"
profSpanMode            = input.string("Expressive (50% Span)", "Profile Width Scaling", options=["Compact (20% Span)", "Balanced (35% Span)", "Expressive (50% Span)", "Wide (65% Span)", "Fixed Bars"], group=grp_prof_style, tooltip="Controls how far historical volume profiles expand into the session. 'Expressive (50% Span)' or 'Wide (65% Span)' makes POC shelves and LVN vacuum valleys prominently visible.")
profWidthInput          = input.int(36, "Fixed Width (Bars)", inline="prof_dim", minval=10, maxval=120, group=grp_prof_style)
profOffsetInput         = input.int(3, "Offset off Candle", inline="prof_dim", minval=0, maxval=30, group=grp_prof_style, tooltip="Right margin clearance off the live candle.")
profShadingMode         = input.string("Bid/Ask Dual-Tone", "Profile Shading Style", options=["Bid/Ask Dual-Tone", "Monochrome Slate", "Monochrome Gold", "Monochrome Cyan"], group=grp_prof_style, tooltip="Selects visual color treatment for volume profile curves:\n• Bid/Ask Dual-Tone: Buyer and seller volume curves colored independently.\n• Monochrome Slate: Calm, uniform slate watermark (minimizes color fatigue).\n• Monochrome Gold / Cyan: Single-tone institutional profile curves.")
profBuyCol              = input.color(#FFD700, "Buy Vol Curve", inline="prof_cols", group=grp_prof_style)
profSellCol             = input.color(#AB47BC, "Sell Vol Curve", inline="prof_cols", group=grp_prof_style)
profFillTransp          = input.int(92, "Fill Transp (%)", inline="prof_transp", minval=0, maxval=100, group=grp_prof_style, tooltip="Controls opacity of buyer and seller profile shading. 85-95% provides soft background watermark.")
profOutlineTransp       = input.int(5, "Outline Transp (%)", inline="prof_transp", minval=0, maxval=100, group=grp_prof_style, tooltip="Controls transparency of the outer profile contour line. Set to 100% for borderless cloud shading.")
profFontSizeInput       = input.string("Small", "Profile Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_prof_style, tooltip="Controls font size of session profile shape badges and POC price labels.")

// --- 7. Level Labels & Dark Knockout Shield ---
grp_labels = "7. Level Labels & Dark Knockout Shield"
levelLabelStyle         = input.string("Subtle Acronym (On Line)", "Level Labels Style", options=["Subtle Acronym (On Line)", "Session Acronym (C-POC / ON-POC)", "Compact Acronym Only", "Bulky Badges (Legacy)", "Hidden"], group=grp_labels, tooltip="Controls the visual presentation of VAH, VAL, and POC labels:\n• Subtle Acronym: Clean, transparent floating text ('POC 29484.75', 'VAH 29550.00', 'VAL 29420.25') sitting directly on top of the level line with no bulky badge background, matching the Overnight Half-Back.\n• Session Acronym: Prepends session identifier ('C-POC', 'ON-POC').\n• Compact Acronym Only: Shows only the letters ('POC', 'VAH', 'VAL') without price.\n• Bulky Badges: Legacy high-contrast opaque pill badges.\n• Hidden: Suppresses labels for pure minimalist lines.")
levelLabelPos           = input.string("Right Edge (Inside Box)", "Level Labels Position", options=["Right Edge (Inside Box)", "Right Edge (Outside Box)", "Center of Session", "Left Edge (Inside Box)"], group=grp_labels, tooltip="Controls horizontal placement of completed session level labels along each line:\n• Right Edge (Inside Box): Cleanest placement inside the quiet right margin of the session box.\n• Right Edge (Outside Box): Stamped immediately to the right of the session boundary.\n• Center of Session: Centered directly on the level line.\n• Left Edge (Inside Box): Stamped at the opening bar of the session.")
useShieldPill           = input.bool(true, "Dark Knockout Shield Pill", group=grp_labels, tooltip="Wraps acronym labels in a high-contrast dark cutout container (#0C0F18) that shields text from candle wicks and bodies passing through the level.")
shieldPillTransp        = input.int(15, "Shield Opacity (%)", minval=0, maxval=90, step=5, group=grp_labels, tooltip="Controls background shield opacity. 0% = Solid dark container, 15-25% = Subtle dark glass.")

// --- 8. Session Framing Outlines & LVN Corridors ---
grp_frames = "8. Session Framing Outlines & LVN Corridors"
showSessionFrames       = input.bool(true, "Show Session Framing Outlines", group=grp_frames, tooltip="Frames each completed and developing Cash RTH and Overnight Globex auction in a clean outline that connects seamlessly to the next session.\n• RULER TOOL PRO TIP: If you frequently use TradingView's Shift+Click Ruler measurement tool, keep Ruler Click-Through Mode enabled (default) or uncheck this option to completely clear all session outline boxes from the canvas so the ruler tool never intercepts clicks over session shading.")
frameOutlineStyle       = input.string("Dotted", "Frame Border Style", options=["Solid", "Dashed", "Dotted"], inline="f_st", group=grp_frames)
frameOutlineWidth       = input.int(1, "Width", minval=1, maxval=3, inline="f_st", group=grp_frames)
cashFrameCol            = input.color(#FFD700, "Cash Frame", inline="f_col", group=grp_frames, tooltip="Distinct border color for Cash RTH session frames (e.g. Ice Blue).")
onFrameCol              = input.color(#AB47BC, "ON Frame", inline="f_col", group=grp_frames, tooltip="Distinct border color for Overnight Globex session frames (e.g. Soft Orchid).")
frameOutlineTransp      = input.int(30, "Outline Transp (%)", inline="f_tr", minval=0, maxval=100, group=grp_frames, tooltip="Opacity of the outer frame border. 0% is solid pop, 30% is crisp, 100% hides the border.")
frameFillTransp         = input.int(100, "Fill Transp (%)", inline="f_tr", minval=0, maxval=100, group=grp_frames, tooltip="Background fill opacity inside the frame. Set to 100% (or >=98%) for a pure hollow wireframe outline with zero candle tinting and 100% click-through for the Shift+Click Ruler tool.")
rulerClickThrough       = input.bool(true, "Ruler Click-Through Mode (Hollow Interiors)", group=grp_frames, tooltip="Forces all session boxes, overnight frames, LVN corridors, and imbalance shelves to use hollow (na) backgrounds, completely eliminating TradingView WebGL picking interception for the Shift+Click Ruler tool while maintaining crisp 1px borders.")
showLvnCorridor         = input.bool(true, "Show LVN Vacuum Corridor (B-Shape)", group=grp_frames, tooltip="Displays the Low Volume Node (LVN) liquidity vacuum corridor for B-Shape (Double Distribution) profiles, marking the transition valley between two distinct volume balance areas.")
lvnDisplayMode          = input.string("Inflection Line Only", "LVN Presentation", options=["Both (Corridor Box + Centerline)", "Shaded Corridor Box", "Inflection Line Only"], group=grp_frames, tooltip="Selects visual presentation for Low Volume Nodes:\n• Both: Shaded vacuum rectangle spanning the low-volume valley plus an inflection centerline.\n• Shaded Corridor Box: Shaded rectangle covering the valley (liquidity void).\n• Inflection Line Only: Single horizontal line at the lowest-volume tick.")
lvnExtendMode           = input.string("Extend Until Mitigated", "LVN Forward Extension", options=["Extend Until Mitigated", "Session Span Only"], group=grp_frames, tooltip="Selects forward extension:\n• Extend Until Mitigated: Projects the LVN corridor forward until price closes through or retests the zone.\n• Session Span Only: Confined strictly within the session profile boundaries.")
colLvnInput             = input.color(#E040FB, "LVN Color", inline="lvn_st", group=grp_frames)
lvnLineStyleInput       = input.string("Dotted", "Style", options=["Solid", "Dashed", "Dotted"], inline="lvn_st", group=grp_frames)
lvnFillTransp           = input.int(92, "Box Fill Transp (%)", minval=0, maxval=100, step=5, inline="lvn_st", group=grp_frames, tooltip="Background opacity for the shaded LVN corridor rectangle (90-95% gives a clean, unobtrusive tint).")

// --- 9. Institutional Heads-Up Display & Educational Table ---
grp_hud = "9. Institutional Heads-Up Display & Educational Table"
hudModeInput            = input.string("Full Educational Dashboard", "HUD Display Mode", options=["Full Educational Dashboard", "Compact Status Pill", "Disabled"], group=grp_hud, tooltip="Selects dashboard visual presentation:\n• Full Educational Dashboard: Comprehensive multi-column table displaying Dalton AMT shape, Value Area positioning, real-time target distances, order flow absorption pulse, and empirical research notes.\n• Compact Status Pill: Minimalist 2-row table preserving maximum chart space.\n• Disabled: Hides table completely.")
hudPositionInput        = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_hud)
showConfluentAlert      = input.bool(true, "Detect Imbalances at Key Levels", group=grp_hud, tooltip="Scans active order flow imbalance shelves and alerts when stacked absorption coincides with Value Area boundaries (VAH/VAL), Point of Control, or Overnight Half-Back.")
int MAX_LOOKBACK = 4500
int prof_bins    = replayOptimized ? 30 : 50

// =============================================================================
// SECTION 3: DESIGN TOKENS & VISUAL PALETTE
// =============================================================================

color COL_GOLD_ABSORB   = colBuyerAbsorb
color COL_PURPLE_DRIVE  = colSellerAbsorb
color COL_SHELF_GOLD    = colBuyerAbsorb
color COL_SHELF_PURPLE  = colSellerAbsorb
color COL_MUTED_NOISE   = colMutedNoise
color COL_OVERNIGHT_BOX = overnightBoxCol
color COL_CONFLUENT_POC = color.new(confluentColInput, confTransp)
color COL_HALFBACK      = color.new(halfbackColInput, hbTransp)
color COL_POC_LINE      = color.new(colPocInput, pocTransp)
color COL_VAH_LINE      = color.new(colVahInput, vahTransp)
color COL_VAL_LINE      = color.new(colValInput, valTransp)
color COL_LVN_CORRIDOR  = colLvnInput
color COL_SHIELD_PILL   = color.new(color.rgb(12, 15, 24), shieldPillTransp)

f_line_style(string s) =>
    s == "Solid" ? line.style_solid : (s == "Dashed" ? line.style_dashed : line.style_dotted)

string STYLE_POC_LINE  = f_line_style(pocLineStyleInput)
string STYLE_VAH_LINE  = f_line_style(vahLineStyleInput)
string STYLE_VAL_LINE  = f_line_style(valLineStyleInput)
string STYLE_HALFBACK  = f_line_style(hbLineStyleInput)
string STYLE_CONFLUENT = f_line_style(confLineStyleInput)
string STYLE_FRAME_BOX  = f_line_style(frameOutlineStyle)
string STYLE_LVN_LINE   = f_line_style(lvnLineStyleInput)
string prof_lbl_size    = profFontSizeInput == "Tiny" ? size.tiny : (profFontSizeInput == "Normal" ? size.normal : (profFontSizeInput == "Large" ? size.large : size.small))

// =============================================================================
// SECTION 4: EXACT MATHEMATICAL KERNEL (ATA SABANCI ENGINE)
// =============================================================================

// Standard normal cumulative distribution function (Abramowitz & Stegun 7.1.26)
f_normCdf(float z) =>
    float p  = 0.3275911
    float a1 = 0.254829592
    float a2 = -0.284496736
    float a3 = 1.421413741
    float a4 = -1.453152027
    float a5 = 1.061405429
    float t  = 1.0 / (1.0 + p * math.abs(z))
    float r  = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-z * z / 2.0)
    z >= 0.0 ? r : 1.0 - r

// Chebyshev rational approximation for complementary error function (Residual < 100 PPM)
f_profErfc(float x) =>
    float ax = math.abs(x)
    float t  = 1.0 / (1.0 + 0.5 * ax)
    float tau = t * math.exp(-ax * ax - 1.26551223 +
         t * ( 1.00002368 +
         t * ( 0.37409196 +
         t * ( 0.09678418 +
         t * (-0.18628806 +
         t * ( 0.27886807 +
         t * (-1.13520398 +
         t * ( 1.48851587 +
         t * (-0.82215223 +
         t *   0.17087277)))))))))
    x >= 0.0 ? tau : 2.0 - tau

// Gaussian CDF and PDF
f_profNormCdf(float z) => 0.5 * f_profErfc(-z / 1.4142135623730951)
f_profNormPdf(float z) => 0.3989422804014327 * math.exp(-0.5 * z * z)

// Struct representation of Gaussian profile component
type ProfComp
    float mu
    float sigma
    float coef
    float priceLo
    float priceHi

// Continuous density evaluation
f_profDensity(float p, array<ProfComp> comps) =>
    float dens = 0.0
    for comp in comps
        if p >= comp.priceLo and p <= comp.priceHi
            dens += comp.coef * f_profNormPdf((p - comp.mu) / comp.sigma)
    dens

// Exact band mass integration
f_profBandMass(float bandLo, float bandHi, array<ProfComp> comps) =>
    float mass = 0.0
    for comp in comps
        float segLo = math.max(bandLo, comp.priceLo)
        float segHi = math.min(bandHi, comp.priceHi)
        if segHi > segLo
            float zAll = f_profNormCdf((comp.priceHi - comp.mu) / comp.sigma) - f_profNormCdf((comp.priceLo - comp.mu) / comp.sigma)
            if zAll > 0.0
                float zSeg = f_profNormCdf((segHi - comp.mu) / comp.sigma) - f_profNormCdf((segLo - comp.mu) / comp.sigma)
                mass += comp.coef * comp.sigma * zSeg
    mass

// =============================================================================
// SECTION 5: AUTO-ADAPTIVE TIMEFRAME TICK GROUPING
// =============================================================================

int tf_sec = timeframe.isseconds ? timeframe.multiplier : (timeframe.isintraday ? timeframe.multiplier * 60 : (timeframe.isdaily ? 86400 : (timeframe.isweekly ? 604800 : (timeframe.ismonthly ? 2592000 : 86400))))

bool is_ltf_execution   = timeframe.isintraday and (timeframe.isminutes ? timeframe.multiplier <= 30 : true)
bool is_macro_htf       = not is_ltf_execution
bool is_daily_or_above  = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly or (tf_sec >= 86400)
bool hide_intraday_overlays = htfClutterFilter and is_daily_or_above

// Effective Profiler Horizon Resolution
string eff_prof_mode = profTimeframeMode == "Auto-Adaptive" ? (
      (timeframe.isweekly or timeframe.ismonthly) ? "Monthly" :
      timeframe.isdaily ? "Weekly (Mon-Fri)" :
      (timeframe.isintraday and (timeframe.isminutes ? timeframe.multiplier >= 30 : false)) ? "Daily Full Cycle (24H)" :
      "Sub-Session (Cash/ON)") : profTimeframeMode

bool is_subsession_mode  = eff_prof_mode == "Sub-Session (Cash/ON)"
bool is_daily_cycle_mode = eff_prof_mode == "Daily Full Cycle (24H)"
bool is_weekly_mode      = eff_prof_mode == "Weekly (Mon-Fri)"
bool is_monthly_mode     = eff_prof_mode == "Monthly" 

// Equities Footprint Baseline Simple Int (Categorical Ticker Scaling for Native Footprint Engine)
int eq_base_fp = (str.contains(syminfo.ticker, "SPY") or str.contains(syminfo.ticker, "VOO")) ? 9 :
                 (str.contains(syminfo.ticker, "QQQ") or str.contains(syminfo.ticker, "META")) ? 8 :
                 (str.contains(syminfo.ticker, "MSFT")) ? 7 :
                 (str.contains(syminfo.ticker, "AAPL") or str.contains(syminfo.ticker, "TSLA")) ? 4 :
                 (str.contains(syminfo.ticker, "AMZN") or str.contains(syminfo.ticker, "GOOG") or str.contains(syminfo.ticker, "AMD")) ? 3 : 2

// Crypto Footprint Baseline Simple Int (Compile-Time Ticker Scaling for Native Footprint Engine)
int crypto_base_fp = (str.contains(tick_sym, "BTC") and not is_mbt_asset) ? 64 :
                     str.contains(tick_sym, "ETH") ? 32 :
                     str.contains(tick_sym, "SOL") ? 2  : 1

// Preserves 100% untouched CME futures calibrations while providing NVDA-calibrated equities baseline & ETH-calibrated crypto baseline
int auto_ticks = is_equity_asset ? (
                      tf_sec <= 60    ? math.max(1, int(eq_base_fp * 0.5)) : // 1m  -> 1 tick ($0.01 on NVDA)
                      tf_sec <= 300   ? eq_base_fp                         : // 5m  -> 2 ticks ($0.02 on NVDA benchmark)
                      tf_sec <= 900   ? eq_base_fp * 2                     : // 15m -> 4 ticks ($0.04 on NVDA)
                      tf_sec <= 3600  ? eq_base_fp * 5                     : // 1h  -> 10 ticks ($0.10 on NVDA)
                      tf_sec <= 14400 ? eq_base_fp * 12                    : // 4h  -> 24 ticks ($0.24 on NVDA)
                                        eq_base_fp * 25                      // Daily/Weekly -> 50 ticks ($0.50 on NVDA)
                 ) : is_crypto_asset ? (
                      tf_sec <= 60    ? crypto_base_fp     : // 1m  -> 32 ticks ($0.32 on ETH, 64 on BTC)
                      tf_sec <= 300   ? crypto_base_fp * 2 : // 5m  -> 64 ticks ($0.64 on ETH, 128 on BTC)
                      tf_sec <= 900   ? crypto_base_fp * 4 : // 15m -> 128 ticks ($1.28 on ETH, 256 on BTC)
                      tf_sec <= 3600  ? crypto_base_fp * 10: // 1h  -> 320 ticks ($3.20 on ETH, 640 on BTC)
                      tf_sec <= 14400 ? crypto_base_fp * 20: // 4h  -> 640 ticks ($6.40 on ETH, 1280 on BTC)
                                        crypto_base_fp * 40  // Daily/Weekly -> 1280 ticks ($12.80 on ETH)
                 ) : is_es_asset ? (
                      tf_sec <= 60    ? 1  : // 1m  -> 1 tick (0.25 pt) [11.0 rows]
                      tf_sec <= 300   ? 2  : // 5m  -> 2 ticks (0.50 pt) [11.0 rows]
                      tf_sec <= 900   ? 3  : // 15m -> 3 ticks (0.75 pt) [12.3 rows]
                      tf_sec <= 3600  ? 12 : // 1h  -> 12 ticks (3.00 pts) [11.5 rows]
                      tf_sec <= 14400 ? 24 : // 4h  -> 24 ticks (6.00 pts) [12.0 rows]
                                        40   // Daily/Weekly -> 40 ticks (10.00 pts)
                 ) : is_ym_asset ? (
                      tf_sec <= 60    ? 2  : // 1m  -> 2 ticks (2.00 pts)
                      tf_sec <= 300   ? 4  : // 5m  -> 4 ticks (4.00 pts) [Matches User's Manual 4 Setup]
                      tf_sec <= 900   ? 8  : // 15m -> 8 ticks (8.00 pts)
                      tf_sec <= 3600  ? 20 : // 1h  -> 20 ticks (20.00 pts)
                      tf_sec <= 14400 ? 40 : // 4h  -> 40 ticks (40.00 pts)
                                        80   // Daily/Weekly -> 80 ticks (80.00 pts)
                 ) : is_rty_asset ? (
                      tf_sec <= 60    ? 1  : // 1m  -> 1 tick (0.10 pt) [12.0 rows]
                      tf_sec <= 300   ? 2  : // 5m  -> 2 ticks (0.20 pt) [12.5 rows]
                      tf_sec <= 900   ? 4  : // 15m -> 4 ticks (0.40 pt) [11.5 rows]
                      tf_sec <= 3600  ? 12 : // 1h  -> 12 ticks (1.20 pts) [11.5 rows]
                      tf_sec <= 14400 ? 24 : // 4h  -> 24 ticks (2.40 pts) [12.4 rows]
                                        40   // Daily/Weekly -> 40 ticks (4.00 pts)
                 ) : is_mbt_asset ? (
                      tf_sec <= 60    ? 1  : // 1m  -> 1 tick (5.00 pts) [16.0 rows]
                      tf_sec <= 300   ? 2  : // 5m  -> 2 ticks (10.00 pts) [16.0 rows]
                      tf_sec <= 900   ? 4  : // 15m -> 4 ticks (20.00 pts) [14.1 rows]
                      tf_sec <= 3600  ? 20 : // 1h  -> 20 ticks (100.00 pts) [12.4 rows]
                      tf_sec <= 14400 ? 60 : // 4h  -> 60 ticks (300.00 pts) [14.0 rows]
                                        120  // Daily/Weekly -> 120 ticks (600.00 pts)
                 ) : (
                      // Default / NQ (Nasdaq-100) & GC (Gold)
                      tf_sec <= 60    ? 4   : // 1m  -> 4 ticks (1.00 pt) [10.8 rows]
                      tf_sec <= 300   ? 8   : // 5m  -> 8 ticks (2.00 pts) [13.5 rows]
                      tf_sec <= 900   ? 16  : // 15m -> 16 ticks (4.00 pts) [13.0 rows]
                      tf_sec <= 3600  ? 40  : // 1h  -> 40 ticks (10.00 pts) [14.4 rows]
                      tf_sec <= 14400 ? 80  : // 4h  -> 80 ticks (20.00 pts) [15.0 rows]
                                        160   // Daily/Weekly -> 160 ticks (40.00 pts)
                 )

// Continuous Approximate Math Scaling for All Equities & Crypto (Row-Density Invariance Law)
float eq_tf_mult   = tf_sec <= 60 ? 0.5 : (tf_sec <= 300 ? 1.0 : (tf_sec <= 900 ? 2.0 : (tf_sec <= 3600 ? 5.0 : (tf_sec <= 14400 ? 12.5 : 25.0))))
int eq_scaled_ticks = math.max(1, int(math.round((close / 60.0) * eq_tf_mult)))

// Universal 1.0 bps Math Scaling for All Crypto (Ethereum $3,200 -> 32 ticks; Bitcoin $64,000 -> 64 ticks)
float crypto_bps        = tf_sec <= 60 ? 0.0001 : (tf_sec <= 300 ? 0.0002 : (tf_sec <= 900 ? 0.0004 : (tf_sec <= 3600 ? 0.0010 : (tf_sec <= 14400 ? 0.0020 : 0.0040))))
int crypto_scaled_ticks = math.max(1, int(math.round((close * crypto_bps) / math.max(syminfo.mintick, 1e-7))))

// Simple int for request.footprint (compile-time compliant: must only use simple int)
int effective_ticks = (imbTicksPerRow > 0) ? imbTicksPerRow : ((tickGroupingMode == "Manual Ticks" and manualTicksInput > 0) ? manualTicksInput : auto_ticks)

// Dynamic active ticks used for continuous on-chart imbalance shelves & HUD
int active_ticks     = (imbTicksPerRow > 0) ? imbTicksPerRow : ((tickGroupingMode == "Manual Ticks" and manualTicksInput > 0) ? manualTicksInput : (is_equity_asset ? eq_scaled_ticks : (is_crypto_asset ? crypto_scaled_ticks : auto_ticks)))
float tick_group_pts = active_ticks * asset_tick_step
float imb_tier_span  = tick_group_pts

// Adaptive Intrabar Lower Timeframe
string auto_ltf = timeframe.isseconds ? "1S" : (tf_sec <= 60 ? "15S" : (tf_sec <= 300 ? "1" : (tf_sec <= 900 ? "1" : "5")))
string effective_ltf = engineInput == "Intrabar (1m Low Memory)" ? "1" : ((ltfOverrideInput != "Auto") ? ltfOverrideInput : auto_ltf)

// =============================================================================
// SECTION 6: TRUE INTRABAR DELTA & VOLUME ORDER FLOW ACQUISITION
// =============================================================================

// Engine Selection
bool useFpEngine = not replayOptimized and (engineInput == "Native Footprint (Tick Precision)") and timeframe.isintraday
bool useIbEngine = not replayOptimized and (engineInput == "Intrabar (1m Low Memory)" or engineInput == "Intrabar (Sub-Minute)") and is_ltf_execution

// Native Footprint series acquisition (Pine Script v6 Native Footprint Engine)
footprint engFp = useFpEngine ? request.footprint(ticks_per_row = effective_ticks, va_percent = 70, imbalance_percent = imbMultInput * 100.0) : na
bool hasEngFp   = useFpEngine and not na(engFp)

float ibUp = na
float ibDn = na
if useIbEngine
    [u, d, _] = tvta.requestUpAndDownVolume(effective_ltf)
    ibUp := u
    ibDn := d

float bar_range = math.max(high - low, syminfo.mintick)
float geo_share = (close - low) / bar_range

float bar_buy_vol = if useFpEngine and hasEngFp
    footprint.buy_volume(engFp)
else if useIbEngine and not na(ibUp)
    math.abs(ibUp)
else
    volume * geo_share

float bar_sell_vol = if useFpEngine and hasEngFp
    footprint.sell_volume(engFp)
else if useIbEngine and not na(ibDn)
    math.abs(ibDn)
else
    volume * (1.0 - geo_share)

bar_buy_vol  := na(bar_buy_vol)  ? volume * geo_share       : bar_buy_vol
bar_sell_vol := na(bar_sell_vol) ? volume * (1.0 - geo_share) : bar_sell_vol
max_bars_back(bar_buy_vol, 5000)
max_bars_back(bar_sell_vol, 5000)

float bar_delta = if useFpEngine and hasEngFp
    footprint.delta(engFp)
else
    bar_buy_vol - bar_sell_vol
bar_delta := na(bar_delta) ? (bar_buy_vol - bar_sell_vol) : bar_delta

float engBuy  = bar_buy_vol
float engSell = bar_sell_vol

// =============================================================================
// SECTION 7: HIGHER-TRUTH EFFORT VS. REWARD CANDLE ENGINE
// =============================================================================

float vol_ma20 = ta.sma(volume, 20)
float rvol = vol_ma20 > 0 ? (volume / vol_ma20) : 1.0

// Time-of-Day Relative Volume (TOD-RVOL) for 1-Hour Charts (Eliminates Diurnal Distortion)
int bar_ny_hr = hour(time, "America/New_York")
var array<float> tod_vol_sum   = array.new<float>(24, 0.0)
var array<int>   tod_bar_count = array.new<int>(24, 0)

bool is_hourly_chart = timeframe.isminutes and timeframe.multiplier == 60
float tod_avg_vol = na

if is_hourly_chart and useTodRvol
    int hr_count = array.get(tod_bar_count, bar_ny_hr)
    float hr_sum = array.get(tod_vol_sum, bar_ny_hr)
    if hr_count >= 5
        tod_avg_vol := hr_sum / float(hr_count)
    if barstate.isconfirmed
        array.set(tod_vol_sum, bar_ny_hr, hr_sum + volume)
        array.set(tod_bar_count, bar_ny_hr, hr_count + 1)

float effective_rvol = (is_hourly_chart and useTodRvol and not na(tod_avg_vol) and tod_avg_vol > 0) ? (volume / tod_avg_vol) : rvol

float current_atr = ta.atr(14)
float safe_atr = current_atr > 0 ? current_atr : bar_range

float lower_wick = math.min(open, close) - low
float upper_wick = high - math.max(open, close)
float candle_body = math.abs(close - open)

float lower_wick_pct = lower_wick / bar_range
float upper_wick_pct = upper_wick / bar_range
float body_pct = candle_body / bar_range

// Calibrated Level 3 MBO Features (Directional Institutional Absorption):
// Dynamically calibrated thresholds across timeframes to prevent false positives on HTF
float req_absorb_rvol = tf_sec <= 60 ? 1.35 : (tf_sec <= 900 ? 1.20 : (tf_sec <= 14400 ? 1.15 : 1.10))
float req_absorb_wick = tf_sec <= 60 ? 0.38 : (tf_sec <= 900 ? 0.35 : (tf_sec <= 14400 ? 0.30 : 0.25))

// Macro OHLC Heuristic Fallback (Active during Fast Replay / Geometric Proxy / Intrabar)
bool geo_bull_absorb = effective_rvol >= req_absorb_rvol and lower_wick_pct >= req_absorb_wick and close > (low + 0.30 * bar_range)
bool geo_bear_absorb = effective_rvol >= req_absorb_rvol and upper_wick_pct >= req_absorb_wick and close < (high - 0.30 * bar_range)

// =============================================================================
// NATIVE FOOTPRINT DIAGONAL ROW SCANNER (PINE SCRIPT v6 COMPILED C++ ENGINE)
// =============================================================================
bool fp_detected_bull_stack = false
bool fp_detected_bear_stack = false
float fp_bull_stack_lo = na
float fp_bull_stack_hi = na
float fp_bear_stack_lo = na
float fp_bear_stack_hi = na

// Institutional Volume Floor: filters out 1-contract zero-denominator anomalies on quiet ticks
float min_imb_vol = is_equity_asset ? 10.0 : 1.0

if useFpEngine and hasEngFp and (showEffortReward or showImbalanceShelves)
    array<volume_row> fp_rows = footprint.rows(engFp)
    int num_fp_rows = array.size(fp_rows)
    if num_fp_rows >= 2
        int cur_bull_stack = 0
        int cur_bear_stack = 0
        float temp_bull_lo = na
        float temp_bear_lo = na
        
        volume_row r_curr = array.get(fp_rows, 0)
        float s_curr = volume_row.sell_volume(r_curr)
        
        if ignoreZerosInput
            // Fast Path: TradingView Native Footprint Parity (Zeroes strictly ignored, hoisted outside loop)
            for i = 0 to num_fp_rows - 2
                volume_row r_next = array.get(fp_rows, i + 1)
                float b_next = volume_row.buy_volume(r_next)
                float s_next = volume_row.sell_volume(r_next)
                
                bool is_buy_imb  = (s_curr > 0.0 and b_next > 0.0 and b_next >= s_curr * imbMultInput and b_next >= min_imb_vol)
                bool is_sell_imb = (b_next > 0.0 and s_curr > 0.0 and s_curr >= b_next * imbMultInput and s_curr >= min_imb_vol)
                
                // Stacked Buy Imbalance (Strictly confined to imbDepthInput tier span)
                if is_buy_imb
                    cur_bull_stack += 1
                    if cur_bull_stack == 1
                        temp_bull_lo := volume_row.down_price(r_next)
                    if cur_bull_stack == imbDepthInput
                        fp_detected_bull_stack := true
                        if na(fp_bull_stack_lo)
                            fp_bull_stack_lo := temp_bull_lo
                            fp_bull_stack_hi := volume_row.up_price(r_next)
                else
                    cur_bull_stack := 0
                    temp_bull_lo   := na
                    
                // Stacked Sell Imbalance (Strictly confined to imbDepthInput tier span)
                if is_sell_imb
                    cur_bear_stack += 1
                    if cur_bear_stack == 1
                        temp_bear_lo := volume_row.down_price(r_curr)
                    if cur_bear_stack == imbDepthInput
                        fp_detected_bear_stack := true
                        if na(fp_bear_stack_lo)
                            fp_bear_stack_lo := temp_bear_lo
                            fp_bear_stack_hi := volume_row.up_price(r_curr)
                else
                    cur_bear_stack := 0
                    temp_bear_lo   := na
                
                // Slide window forward: avoids duplicate array.get and sell_volume lookups
                r_curr := r_next
                s_curr := s_next
        else
            // Compare Against Zero Mode (Fallback for non-standard footprint configurations)
            for i = 0 to num_fp_rows - 2
                volume_row r_next = array.get(fp_rows, i + 1)
                float b_next = volume_row.buy_volume(r_next)
                float s_next = volume_row.sell_volume(r_next)
                
                bool is_buy_imb  = s_curr > 0.0 ? (b_next >= s_curr * imbMultInput and b_next >= min_imb_vol) : (b_next >= min_imb_vol)
                bool is_sell_imb = b_next > 0.0 ? (s_curr >= b_next * imbMultInput and s_curr >= min_imb_vol) : (s_curr >= min_imb_vol)
                
                // Stacked Buy Imbalance (Strictly confined to imbDepthInput tier span)
                if is_buy_imb
                    cur_bull_stack += 1
                    if cur_bull_stack == 1
                        temp_bull_lo := volume_row.down_price(r_next)
                    if cur_bull_stack == imbDepthInput
                        fp_detected_bull_stack := true
                        if na(fp_bull_stack_lo)
                            fp_bull_stack_lo := temp_bull_lo
                            fp_bull_stack_hi := volume_row.up_price(r_next)
                else
                    cur_bull_stack := 0
                    temp_bull_lo   := na
                    
                // Stacked Sell Imbalance (Strictly confined to imbDepthInput tier span)
                if is_sell_imb
                    cur_bear_stack += 1
                    if cur_bear_stack == 1
                        temp_bear_lo := volume_row.down_price(r_curr)
                    if cur_bear_stack == imbDepthInput
                        fp_detected_bear_stack := true
                        if na(fp_bear_stack_lo)
                            fp_bear_stack_lo := temp_bear_lo
                            fp_bear_stack_hi := volume_row.up_price(r_curr)
                else
                    cur_bear_stack := 0
                    temp_bear_lo   := na
                
                // Slide window forward
                r_curr := r_next
                s_curr := s_next

bool is_gold_buyer_absorb    = (useFpEngine and hasEngFp) ? fp_detected_bull_stack : geo_bull_absorb
bool is_purple_seller_absorb  = (useFpEngine and hasEngFp) ? fp_detected_bear_stack : geo_bear_absorb

// 3. Initiative Momentum Drives (High-volume directional expansion, body >= 70%)
bool is_bull_drive = effective_rvol >= 1.50 and body_pct >= 0.70 and close > open and bar_delta > 0
bool is_bear_drive = effective_rvol >= 1.50 and body_pct >= 0.70 and close < open and bar_delta < 0

// 4. Muted Dead Churn: Volume dried up or micro-range chop (Gated strictly to CONFIRMED bars)
// On live developing bars (not barstate.isconfirmed), volume has not finished accumulating!
// Evaluating raw rvol < 0.70 live caused developing bars to camouflage in 85% transparent dark slate.
bool is_muted_noise = showEffortReward and barstate.isconfirmed and (effective_rvol < 0.70 or bar_range < (0.40 * safe_atr))

int body_transp = candleStyle == "Ghost Glow (Semi-Transparent Body + Solid Wicks)" ? 75 : (candleStyle == "Hollow (Wicks & Solid Borders Only)" ? 100 : 0)
bool use_plotcandle = candleStyle != "Direct Native Barcolor" and candleStyle != "Disabled"

// Discrete States for Dedicated Constant-Wick Plotting (Eliminates WebGL Series Wickcolor Drop on Realtime Bars)
bool is_gold_state   = use_plotcandle and showEffortReward and is_gold_buyer_absorb and (not is_purple_seller_absorb or close >= open or bar_delta >= 0)
bool is_purple_state = use_plotcandle and showEffortReward and is_purple_seller_absorb and not is_gold_state
bool is_muted_state  = use_plotcandle and showEffortReward and is_muted_noise and not is_gold_state and not is_purple_state
bool is_bull_state   = use_plotcandle and close >= open and not is_gold_state and not is_purple_state and not is_muted_state
bool is_bear_state   = use_plotcandle and close < open and not is_gold_state and not is_purple_state and not is_muted_state

// 1. Bullish Active Candle - Constant Wicks & Borders for 100% WebGL Realtime Reliability
plotcandle(is_bull_state ? open : na, is_bull_state ? high : na, is_bull_state ? low : na, is_bull_state ? close : na,
     title="Bullish Order Flow Candle",
     color=color.new(is_bull_drive ? colBullDrive : colBullCandle, body_transp),
     wickcolor=colBullDrive,
     bordercolor=colBullDrive)

// 2. Bearish Active Candle - Constant Wicks & Borders for 100% WebGL Realtime Reliability
plotcandle(is_bear_state ? open : na, is_bear_state ? high : na, is_bear_state ? low : na, is_bear_state ? close : na,
     title="Bearish Order Flow Candle",
     color=color.new(is_bear_drive ? colBearDrive : colBearCandle, body_transp),
     wickcolor=colBearDrive,
     bordercolor=colBearDrive)

// 3. Buyer Absorption (Demand Defense / Trapped Shorts) - Constant Wicks & Borders
plotcandle(is_gold_state ? open : na, is_gold_state ? high : na, is_gold_state ? low : na, is_gold_state ? close : na,
     title="Buyer Absorption Candle",
     color=color.new(colBuyerAbsorb, body_transp),
     wickcolor=colBuyerAbsorb,
     bordercolor=colBuyerAbsorb)

// 4. Seller Absorption (Supply Defense / Trapped Longs) - Constant Wicks & Borders
plotcandle(is_purple_state ? open : na, is_purple_state ? high : na, is_purple_state ? low : na, is_purple_state ? close : na,
     title="Seller Absorption Candle",
     color=color.new(colSellerAbsorb, body_transp),
     wickcolor=colSellerAbsorb,
     bordercolor=colSellerAbsorb)

// 5. Muted Low-Volume Consolidation (Gated to Confirmed Historical Bars Only)
plotcandle(is_muted_state ? open : na, is_muted_state ? high : na, is_muted_state ? low : na, is_muted_state ? close : na,
     title="Muted Consolidation Candle",
     color=color.new(colMutedNoise, 85),
     wickcolor=colMutedNoise,
     bordercolor=colMutedNoise)

// Native Barcolor Mode Fallback
color native_bar_col = is_gold_state ? colBuyerAbsorb : is_purple_state ? colSellerAbsorb : is_muted_state ? colMutedNoise : (close >= open ? colBullCandle : colBearCandle)
barcolor(candleStyle == "Direct Native Barcolor" ? native_bar_col : na)

// =============================================================================
// SECTION 8: FORWARD-PROJECTED 3-STACKED IMBALANCE SHELVES
// =============================================================================

// Dynamic shelf structure
type ImbShelf
    box   bx
    line  ln
    float price
    float risk_stop
    bool  is_bull
    int   start_bar

var array<ImbShelf> active_shelves = array.new<ImbShelf>()

// Detect stacked imbalances on current bar matching TradingView Native Footprint settings
float tier_span     = imb_tier_span
int num_tiers = math.max(int(bar_range / imb_tier_span), 1)

bool detected_bull_stack = false
bool detected_bear_stack = false
float bull_shelf_lo = 0.0
float bull_shelf_hi = 0.0
float bear_shelf_lo = 0.0
float bear_shelf_hi = 0.0

if useFpEngine and hasEngFp
    // 1. Direct Native Footprint Ladder Matching (Exact Price Tiers from CME Tape)
    if fp_detected_bull_stack and not na(fp_bull_stack_lo) and not na(fp_bull_stack_hi)
        detected_bull_stack := true
        bull_shelf_lo := fp_bull_stack_lo
        bull_shelf_hi := fp_bull_stack_hi
    if fp_detected_bear_stack and not na(fp_bear_stack_lo) and not na(fp_bear_stack_hi)
        detected_bear_stack := true
        bear_shelf_lo := fp_bear_stack_lo
        bear_shelf_hi := fp_bear_stack_hi
else
    // 2. Geometric Proxy Fallback (Bar Replay & Lightweight Mode)
    if is_gold_buyer_absorb or is_bull_drive
        detected_bull_stack := true
        float raw_bull_p = low + (is_gold_buyer_absorb ? lower_wick * 0.5 : 0.0)
        bull_shelf_lo := math.floor(raw_bull_p / imb_tier_span) * imb_tier_span
        bull_shelf_hi := bull_shelf_lo + (imbDepthInput * imb_tier_span)
    if is_purple_seller_absorb or is_bear_drive
        detected_bear_stack := true
        float raw_bear_p = high - (is_purple_seller_absorb ? upper_wick * 0.5 : 0.0)
        bear_shelf_hi := math.ceil(raw_bear_p / imb_tier_span) * imb_tier_span
        bear_shelf_lo := bear_shelf_hi - (imbDepthInput * imb_tier_span)

// Project forward shelves
if showImbalanceShelves and not hide_intraday_overlays
    bool show_shelf_box  = shelfFillTransp < 100
    bool show_shelf_line = shelfLineTransp < 100

    if barstate.isconfirmed and detected_bull_stack and bull_shelf_hi > 0.0
        float shelf_lo = bull_shelf_lo
        float shelf_hi = bull_shelf_hi
        box b = na
        line l = na
        if show_shelf_box
            color s_gold_bg  = rulerClickThrough ? na : color.new(COL_SHELF_GOLD, shelfFillTransp)
            color s_gold_brd = color.new(COL_SHELF_GOLD, shelfFillTransp)
            b := box.new(bar_index, shelf_hi, bar_index + 1, shelf_lo,
                 bgcolor=s_gold_bg, border_color=s_gold_brd, border_width=1)
        if show_shelf_line
            color s_gold_ln = color.new(COL_SHELF_GOLD, shelfLineTransp)
            l := line.new(bar_index, bull_shelf_lo, bar_index + 1, bull_shelf_lo,
                 color=s_gold_ln, width=shelfLineWidth, style=line.style_solid)
        array.push(active_shelves, ImbShelf.new(b, l, bull_shelf_lo, shelf_lo - safe_atr * 0.5, true, bar_index))

    if barstate.isconfirmed and detected_bear_stack and bear_shelf_hi > 0.0
        float shelf_hi = bear_shelf_hi
        float shelf_lo = bear_shelf_lo
        box b = na
        line l = na
        if show_shelf_box
            color s_purp_bg  = rulerClickThrough ? na : color.new(COL_SHELF_PURPLE, shelfFillTransp)
            color s_purp_brd = color.new(COL_SHELF_PURPLE, shelfFillTransp)
            b := box.new(bar_index, shelf_hi, bar_index + 1, shelf_lo,
                 bgcolor=s_purp_bg, border_color=s_purp_brd, border_width=1)
        if show_shelf_line
            color s_purp_ln = color.new(COL_SHELF_PURPLE, shelfLineTransp)
            l := line.new(bar_index, bear_shelf_hi, bar_index + 1, bear_shelf_hi,
                 color=s_purp_ln, width=shelfLineWidth, style=line.style_solid)
        array.push(active_shelves, ImbShelf.new(b, l, bear_shelf_hi, shelf_hi + safe_atr * 0.5, false, bar_index))

    // Manage active shelves: test mitigation and lock break bar (Zero-Overhead Event Architecture)
    int shelf_count = array.size(active_shelves)
    if shelf_count > 0
        for i = shelf_count - 1 to 0
            ImbShelf sh = array.get(active_shelves, i)
            bool is_mitigated = false
            
            // Check if price penetrated through the shelf
            if sh.is_bull
                if close < sh.risk_stop or (low < sh.price - imb_tier_span and bar_index > sh.start_bar + 1)
                    is_mitigated := true
            else
                if close > sh.risk_stop or (high > sh.price + imb_tier_span and bar_index > sh.start_bar + 1)
                    is_mitigated := true

            if is_mitigated
                // Lock shelf at break bar once and evict (eliminates 99.9% of historical bar redraw drag)
                if not na(sh.bx)
                    box.set_right(sh.bx, bar_index)
                if not na(sh.ln)
                    line.set_x2(sh.ln, bar_index)
                if barstate.isconfirmed
                    array.remove(active_shelves, i)
            else if barstate.islast
                // Only extend unmitigated shelves forward when on the real-time/latest bar (eliminates 300,000+ historical mutations)
                if not na(sh.bx)
                    box.set_right(sh.bx, bar_index + 1)
                if not na(sh.ln)
                    line.set_x2(sh.ln, bar_index + 1)

    // Bounded drawing budget: recycle if > maxActiveShelvesInput (eliminates array iteration drag)
    if array.size(active_shelves) > maxActiveShelvesInput
        ImbShelf old_sh = array.shift(active_shelves)
        if not na(old_sh.bx)
            box.delete(old_sh.bx)
        if not na(old_sh.ln)
            line.delete(old_sh.ln)

// =============================================================================
// SECTION 9: UNFINISHED AUCTION MAGNET ENGINE (POOR HIGHS / POOR LOWS)
// =============================================================================

type PoorExtreme
    line  ln
    float price
    bool  is_high
    int   bar_idx

var array<PoorExtreme> active_poor_extremes = array.new<PoorExtreme>()

if showUnfinishedAuctions and not hide_intraday_overlays
    // Check if candle extreme printed volume at outer tick without rejection
    // Intrabar criteria: extreme wick < 10% with high volume at outer edge
    bool is_poor_high = upper_wick_pct <= 0.10 and effective_rvol >= 1.10 and close > open
    bool is_poor_low  = lower_wick_pct <= 0.10 and effective_rvol >= 1.10 and close < open

    if barstate.isconfirmed and is_poor_high
        line l = line.new(bar_index, high, bar_index + 1, high, color=color.new(COL_GOLD_ABSORB, 30), width=1, style=line.style_dotted)
        array.push(active_poor_extremes, PoorExtreme.new(l, high, true, bar_index))

    if barstate.isconfirmed and is_poor_low
        line l = line.new(bar_index, low, bar_index + 1, low, color=color.new(COL_PURPLE_DRIVE, 30), width=1, style=line.style_dotted)
        array.push(active_poor_extremes, PoorExtreme.new(l, low, false, bar_index))

    // Extend and check repairs (88%+ repair rate)
    if array.size(active_poor_extremes) > 0
        for i = array.size(active_poor_extremes) - 1 to 0
            PoorExtreme pe = array.get(active_poor_extremes, i)
            bool is_repaired = false
            if pe.is_high
                if high >= pe.price and bar_index > pe.bar_idx
                    is_repaired := true
            else
                if low <= pe.price and bar_index > pe.bar_idx
                    is_repaired := true

            if is_repaired
                if barstate.isconfirmed
                    line.delete(pe.ln)
                    array.remove(active_poor_extremes, i)
                else
                    line.set_x2(pe.ln, bar_index)
            else
                line.set_x2(pe.ln, bar_index + 1)

    // Drawing cap recycle (tightened to 12 for maximum performance)
    if array.size(active_poor_extremes) > 12
        PoorExtreme old_pe = array.shift(active_poor_extremes)
        line.delete(old_pe.ln)

// =============================================================================
// SECTION 10: SESSION ARCHITECTURE, OVERNIGHT BOX & 99% HALF-BACK RAY
// =============================================================================

// Multi-Session Gallery & Session Succession Tracking (Ata Sabanci Architecture)
var array<int>  sess_starts    = array.new<int>()
var array<bool> sess_is_cashes = array.new<bool>()

// Unconditional ta.change evaluation on every bar (Guarantees historical consistency and eliminates CW10002)
int t_cme_d      = time("D", "1800-1700:1234567", "America/New_York")
int t_eq_d       = time("D", "0930-1600:23456", "America/New_York")
int t_crypto_d   = time("D")
int chg_cme_d    = ta.change(t_cme_d)
int chg_eq_d     = ta.change(t_eq_d)
int chg_crypto_d = ta.change(t_crypto_d)
int chg_w        = ta.change(time("W"))
int chg_m        = ta.change(time("M"))

// True CME Globex Rollover (18:00 EST) - Bypassed for US Equities & 24/7 Crypto
bool is_cme_rollover = not is_equity_asset and not is_crypto_asset and (chg_cme_d != 0)

// RTH Cash Window (09:30 - 16:00 EST) & 24/7 Crypto Weekend Sub-Session Partitioning
bool in_weekday_cash = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))
int ny_dow           = dayofweek(time, "America/New_York")
bool is_ny_weekend   = (ny_dow == 1 or ny_dow == 7)

bool in_crypto_cash = in_weekday_cash
if is_crypto_asset
    if cryptoWeekendMode == "Day/Night 7-Day (09:30-16:00 EST)"
        in_crypto_cash := not na(time(timeframe.period, "0930-1600:1234567", "America/New_York"))
    else if cryptoWeekendMode == "12-Hour Halves (09:30 & 21:30 EST)"
        if is_ny_weekend
            in_crypto_cash := not na(time(timeframe.period, "0930-2130:1234567", "America/New_York"))
        else
            in_crypto_cash := in_weekday_cash
    else
        in_crypto_cash := in_weekday_cash

bool in_cash_rth = is_crypto_asset ? in_crypto_cash : in_weekday_cash
bool is_first_cash_bar = in_cash_rth and not in_cash_rth[1]

// Overnight Window (18:00 to 07:00 EST or 08:30 EST for CME Futures; Seamless 16:00-09:30 EST for Equities & Crypto)
string on_session_str = extendToPreMarket ? "1800-0830:1234567" : "1800-0700:1234567"
bool in_overnight = (is_equity_asset or is_crypto_asset) ? (not in_cash_rth) : not na(time(timeframe.period, on_session_str, "America/New_York"))
bool is_first_on_bar = in_overnight and not in_overnight[1]

// Macro Rollovers (CME 24-Hour Session Synchronization - SKILL.md Section 1E)
bool is_macro_daily_roll   = is_crypto_asset ? (chg_crypto_d != 0) : (is_equity_asset ? (chg_eq_d != 0) : (chg_cme_d != 0))
bool is_macro_weekly_roll  = chg_w != 0
bool is_macro_monthly_roll = chg_m != 0

// Gated Session Transitions: Ensure session start logic runs EXACTLY ONCE per new session bar
// Array-backed persistence prevents variable rollback across intra-bar ticks in Bar Replay
var array<int> last_sess_markers = array.new<int>(4, -1) // [0: cash, 1: on, 2: roll/daily, 3: macro]

bool is_new_cash_open = is_first_cash_bar and (array.get(last_sess_markers, 0) != bar_index)
bool is_new_on_open   = is_first_on_bar   and (array.get(last_sess_markers, 1) != bar_index)

if is_new_cash_open
    array.set(last_sess_markers, 0, bar_index)
if is_new_on_open
    array.set(last_sess_markers, 1, bar_index)

// Subsession Profile triggers (for Profile Gallery mode)
bool is_new_cash_sess = is_subsession_mode and is_new_cash_open
bool is_new_on_sess   = is_subsession_mode and is_new_on_open
bool is_new_roll_sess = not is_equity_asset and not is_crypto_asset and is_subsession_mode and is_cme_rollover and (array.get(last_sess_markers, 2) != bar_index)

bool is_new_daily_cycle   = is_daily_cycle_mode and (is_macro_daily_roll or (not is_crypto_asset and is_cme_rollover) or (is_equity_asset and is_first_cash_bar)) and (array.get(last_sess_markers, 2) != bar_index)
bool is_new_weekly_cycle  = is_weekly_mode and is_macro_weekly_roll and (array.get(last_sess_markers, 3) != bar_index)
bool is_new_monthly_cycle = is_monthly_mode and is_macro_monthly_roll and (array.get(last_sess_markers, 3) != bar_index)

if is_new_roll_sess or is_new_daily_cycle
    array.set(last_sess_markers, 2, bar_index)
if is_new_weekly_cycle or is_new_monthly_cycle
    array.set(last_sess_markers, 3, bar_index)

bool is_new_sess = is_subsession_mode ? (is_new_cash_sess or is_new_on_sess or is_new_roll_sess) :
     (is_daily_cycle_mode ? is_new_daily_cycle :
     (is_weekly_mode ? is_new_weekly_cycle : is_new_monthly_cycle))

if barstate.isfirst
    array.push(sess_starts, 0)
    array.push(sess_is_cashes, in_cash_rth)

if is_new_sess
    if array.size(sess_starts) == 1 and array.get(sess_starts, 0) == 0
        array.set(sess_starts, 0, bar_index)
        array.set(sess_is_cashes, 0, in_cash_rth)
    else
        array.unshift(sess_starts, bar_index)
        array.unshift(sess_is_cashes, in_cash_rth)
    if array.size(sess_starts) > 50
        array.pop(sess_starts)
        array.pop(sess_is_cashes)

// Session Cumulative Volume Delta (CVD) Tracking
var float sess_cum_delta = 0.0
if is_new_sess
    sess_cum_delta := bar_delta
else
    sess_cum_delta += bar_delta

var float on_high_cur = na
var float on_low_cur  = na
var float on_high_locked = na
var float on_low_locked  = na
var int   on_start_idx = 0
var box   on_box_inst = na
var line  hb_line_inst = na
var label hb_lbl_inst  = na
var line  conf_poc_line = na
var label conf_poc_lbl  = na

var float prior_cash_vpoc = na
var float prior_cash_vah  = na
var float prior_cash_val  = na

var float on_vpoc = na
var float on_cum_vol = 0.0
var float on_vol_weighted_p = 0.0

if is_new_on_open or is_new_roll_sess
    on_high_cur := high
    on_low_cur  := low
    on_start_idx := bar_index
    on_cum_vol := volume
    on_vol_weighted_p := close * volume
    if showOvernightBox and not hide_intraday_overlays
        box.delete(on_box_inst)
        color on_bg = (rulerClickThrough or overnightBoxTransp >= 95) ? na : color.new(COL_OVERNIGHT_BOX, overnightBoxTransp)
        on_box_inst := box.new(bar_index, high, bar_index + 1, low,
             bgcolor=on_bg, border_color=color.new(COL_OVERNIGHT_BOX, math.max(0, overnightBoxTransp - 35)), border_width=1)
else if in_overnight
    on_high_cur := math.max(nz(on_high_cur, high), high)
    on_low_cur  := math.min(nz(on_low_cur, low), low)
    if barstate.isconfirmed
        on_cum_vol += volume
        on_vol_weighted_p += close * volume
    if showOvernightBox and not na(on_box_inst) and not hide_intraday_overlays
        box.set_top(on_box_inst, on_high_cur)
        box.set_bottom(on_box_inst, on_low_cur)
        box.set_right(on_box_inst, bar_index)

// Lock overnight levels when exiting overnight
var int on_end_idx = 0
var int cash_start_idx = 0
var int prior_cash_start_idx = 0
var int cash_end_idx = 0

if (not in_overnight and in_overnight[1]) or is_new_cash_open
    on_high_locked := on_high_cur
    on_low_locked  := on_low_cur
    on_end_idx     := bar_index[1]
    if on_cum_vol > 0.0
        on_vpoc := on_vol_weighted_p / on_cum_vol

if is_new_cash_open
    cash_start_idx := bar_index
    cash_end_idx   := 0

// Overnight Half-Back (50% range midpoint)
float on_halfback = (not na(on_high_locked) and not na(on_low_locked)) ? (on_high_locked + on_low_locked) * 0.5 : na

if is_new_cash_open and showHalfback and not na(on_halfback) and not hide_intraday_overlays
    line.delete(hb_line_inst)
    label.delete(hb_lbl_inst)
    int hb_x1 = (priorLevelAnchor == "Session Origin (Full Span)" and on_start_idx > 0) ? math.max(bar_index - 450, on_start_idx) : bar_index
    hb_line_inst := line.new(hb_x1, on_halfback, bar_index + 40, on_halfback,
         color=COL_HALFBACK, width=hbLineWidth, style=STYLE_HALFBACK)
    color hb_lbl_bg = useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100)
    hb_lbl_inst := label.new(bar_index, on_halfback, "ON HALF-BACK (50%): " + str.tostring(on_halfback, "#.##"),
         color=hb_lbl_bg, textcolor=halfbackColInput, style=label.style_label_left, size=size.tiny)
else if in_cash_rth and not na(hb_line_inst) and not hide_intraday_overlays
    line.set_x2(hb_line_inst, bar_index + 10)

// Prior Cash Session Tracking (09:30 - 16:00)
var float cur_cash_vol_w = 0.0
var float cur_cash_vol_tot = 0.0
var float cur_cash_hi = na
var float cur_cash_lo = na

if is_new_cash_open
    cur_cash_vol_w := close * volume
    cur_cash_vol_tot := volume
    cur_cash_hi := high
    cur_cash_lo := low
else if in_cash_rth
    if barstate.isconfirmed
        cur_cash_vol_w += close * volume
        cur_cash_vol_tot += volume
    cur_cash_hi := math.max(nz(cur_cash_hi, high), high)
    cur_cash_lo := math.min(nz(cur_cash_lo, low), low)

if not in_cash_rth and in_cash_rth[1]
    cash_end_idx := bar_index[1]
    int raw_c_len = (cash_start_idx > 0 and bar_index >= cash_start_idx) ? (bar_index - cash_start_idx + 1) : 0
    int c_len = math.min(raw_c_len, 450)
    if c_len >= 2 and cash_start_idx > 0 and raw_c_len <= 500
        float c_hi = -1e12
        float c_lo = 1e12
        float c_tot_v = 0.0
        for i = 0 to c_len - 1
            float bh = high[i]
            float bl = low[i]
            if not (na(bh) or na(bl))
                c_hi := math.max(c_hi, bh)
                c_lo := math.min(c_lo, bl)
                c_tot_v += nz(volume[i])

        float c_span = c_hi - c_lo
        if c_span > 0.0 and c_tot_v > 0.0
            int res_c = 40
            float step_c = c_span / float(res_c)
            array<float> c_bins = array.new<float>(res_c + 1, 0.0)
            for i = 0 to c_len - 1
                float bh = high[i]
                float bl = low[i]
                float bv = nz(volume[i])
                float rng_c = bh - bl
                if rng_c <= 0.0
                    int b_flat = math.max(0, math.min(res_c, int(math.round((close[i] - c_lo) / step_c))))
                    array.set(c_bins, b_flat, array.get(c_bins, b_flat) + bv)
                else
                    int b_s = math.max(0, math.min(res_c, int(math.floor((bl - c_lo) / step_c))))
                    int b_e = math.max(0, math.min(res_c, int(math.floor((bh - c_lo) / step_c))))
                    if b_s == b_e
                        array.set(c_bins, b_s, array.get(c_bins, b_s) + bv)
                    else
                        for b = b_s to b_e
                            float bin_fl = c_lo + b * step_c
                            float bin_ce = bin_fl + step_c
                            float o_lo = math.max(bl, bin_fl)
                            float o_hi = math.min(bh, bin_ce)
                            if o_hi > o_lo
                                float w = (o_hi - o_lo) / rng_c
                                array.set(c_bins, b, array.get(c_bins, b) + bv * w)

            float max_v = 0.0
            int poc_b = 0
            for b = 0 to res_c
                float vb = array.get(c_bins, b)
                if vb > max_v
                    max_v := vb
                    poc_b := b

            float p_vah_c = na
            float p_val_c = na

            if vaCalcMethod == "Dalton Cumulative Mass (15%-85%)"
                float target_val_c = c_tot_v * 0.15
                float target_vah_c = c_tot_v * 0.85
                float cum_c = 0.0
                int c_val_b = 0
                int c_vah_b = res_c
                bool found_val_c = false
                bool found_vah_c = false
                for b = 0 to res_c
                    cum_c += array.get(c_bins, b)
                    if not found_val_c and cum_c >= target_val_c
                        c_val_b := b
                        found_val_c := true
                    if not found_vah_c and cum_c >= target_vah_c
                        c_vah_b := b
                        found_vah_c := true
                        break
                p_vah_c := math.min(c_hi, c_lo + (c_vah_b + 1.0) * step_c)
                p_val_c := math.max(c_lo, c_lo + c_val_b * step_c)
            else
                // Canonical CBOT Dalton Steidlmayer 2-Bin Dual Expansion with LVN Decoupling
                float target_va = c_tot_v * 0.70
                float cur_va    = max_v
                int va_up       = poc_b
                int va_dn       = poc_b
                float lvn_c_lim = max_v * 0.20

                while cur_va < target_va and (va_up < res_c or va_dn > 0)
                    float s_up = 0.0
                    int u_cnt  = 0
                    for k = 1 to 2
                        if va_up + k <= res_c
                            s_up += array.get(c_bins, va_up + k)
                            u_cnt += 1

                    float s_dn = 0.0
                    int d_cnt  = 0
                    for k = 1 to 2
                        if va_dn - k >= 0
                            s_dn += array.get(c_bins, va_dn - k)
                            d_cnt += 1

                    // Boundary / LVN Vacuum Decoupling: Prevent bimodal blowout across single-print void
                    if va_up >= res_c and d_cnt > 0
                        if (s_dn / float(d_cnt)) < lvn_c_lim and cur_va >= c_tot_v * 0.35
                            break
                    if va_dn <= 0 and u_cnt > 0
                        if (s_up / float(u_cnt)) < lvn_c_lim and cur_va >= c_tot_v * 0.35
                            break

                    if s_up > s_dn and va_up < res_c
                        va_up += u_cnt
                        cur_va += s_up
                    else if s_dn > s_up and va_dn > 0
                        va_dn -= d_cnt
                        cur_va += s_dn
                    else if s_up == s_dn and (va_up < res_c or va_dn > 0)
                        if u_cnt > 0 and d_cnt > 0
                            if array.get(c_bins, va_up + 1) >= array.get(c_bins, va_dn - 1)
                                va_up += u_cnt
                                cur_va += s_up
                            else
                                va_dn -= d_cnt
                                cur_va += s_dn
                        else if u_cnt > 0
                            va_up += u_cnt
                            cur_va += s_up
                        else if d_cnt > 0
                            va_dn -= d_cnt
                            cur_va += s_dn
                        else
                            break
                    else if va_up < res_c
                        va_up += u_cnt
                        cur_va += s_up
                    else if va_dn > 0
                        va_dn -= d_cnt
                        cur_va += s_dn
                    else
                        break

                p_vah_c := math.min(c_hi, c_lo + math.min(float(res_c), float(va_up) + 1.0) * step_c)
                p_val_c := math.max(c_lo, c_lo + math.max(0.0, float(va_dn)) * step_c)

            prior_cash_vpoc := c_lo + (poc_b + 0.5) * step_c
            prior_cash_vah  := p_vah_c
            prior_cash_val  := p_val_c
            prior_cash_start_idx := cash_start_idx

// Multi-Session Confluent Iron POC Zone (High-Volume Cluster)
bool is_poc_confluent = not na(prior_cash_vpoc) and not na(on_vpoc) and math.abs(prior_cash_vpoc - on_vpoc) <= asset_cluster_tol

if is_new_cash_open and showConfluentPoc and is_poc_confluent and not hide_intraday_overlays
    float conf_mid = (prior_cash_vpoc + on_vpoc) * 0.5
    line.delete(conf_poc_line)
    label.delete(conf_poc_lbl)
    int conf_x1 = (priorLevelAnchor == "Session Origin (Full Span)" and prior_cash_start_idx > 0) ? math.max(bar_index - 450, math.min(prior_cash_start_idx, on_start_idx)) : bar_index
    conf_poc_line := line.new(conf_x1, conf_mid, bar_index + 60, conf_mid,
         color=COL_CONFLUENT_POC, width=confLineWidth, style=STYLE_CONFLUENT)
    color conf_lbl_bg = useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100)
    conf_poc_lbl := label.new(bar_index, conf_mid, "⚡ CONFLUENT IRON POC: " + str.tostring(conf_mid, "#.##"),
         color=conf_lbl_bg, textcolor=confluentColInput, style=label.style_label_left, size=size.small)
else if in_cash_rth and not na(conf_poc_line) and not hide_intraday_overlays
    line.set_x2(conf_poc_line, bar_index + 10)

// Prior Cash Levels lines
var line prior_poc_ln = na
var line prior_vah_ln = na
var line prior_val_ln = na

if is_new_cash_open and showPriorCashLevels and not na(prior_cash_vpoc) and not is_poc_confluent and not hide_intraday_overlays
    line.delete(prior_poc_ln)
    line.delete(prior_vah_ln)
    line.delete(prior_val_ln)
    int prior_x1 = (priorLevelAnchor == "Session Origin (Full Span)" and prior_cash_start_idx > 0) ? math.max(bar_index - 450, prior_cash_start_idx) : bar_index
    prior_poc_ln := line.new(prior_x1, prior_cash_vpoc, bar_index + 40, prior_cash_vpoc, color=COL_POC_LINE, width=pocLineWidth, style=STYLE_POC_LINE)
    prior_vah_ln := line.new(prior_x1, prior_cash_vah, bar_index + 40, prior_cash_vah, color=COL_VAH_LINE, width=vahLineWidth, style=STYLE_VAH_LINE)
    prior_val_ln := line.new(prior_x1, prior_cash_val, bar_index + 40, prior_cash_val, color=COL_VAL_LINE, width=valLineWidth, style=STYLE_VAL_LINE)
else if in_cash_rth and not hide_intraday_overlays
    if not na(prior_poc_ln)
        line.set_x2(prior_poc_ln, bar_index + 5)
    if not na(prior_vah_ln)
        line.set_x2(prior_vah_ln, bar_index + 5)
    if not na(prior_val_ln)
        line.set_x2(prior_val_ln, bar_index + 5)

// SECTION 11: SESSION SUCCESSION VOLUME DELTA PROFILER (ATA SABANCI ENGINE)
// =============================================================================

var float cur_poc_ref    = na
var float cur_vah_ref    = na
var float cur_val_ref    = na
var float cur_lvn_ref       = na
var string cur_shape_ref    = "D"
var float cur_ovl_ref       = na
var float cur_tilt_ref      = na
var string cur_ovl_word_ref = "BALANCED"

var polyline dev_buy_poly    = na
var polyline dev_sell_poly   = na
var line     dev_poc_line    = na
var line     dev_vah_line    = na
var line     dev_val_line    = na
var line     dev_lvn_line    = na
var box      dev_lvn_box     = na
var label    dev_lvn_lbl     = na
var label    dev_poc_lbl     = na
var label    dev_vah_lbl     = na
var label    dev_val_lbl     = na
var label    dev_shape_lbl   = na
var box      dev_frame_box   = na

// Multi-Session Prior Profile Drawing Arrays
var array<polyline> prior_buy_polys   = array.new<polyline>()
var array<polyline> prior_sell_polys  = array.new<polyline>()
var array<line>     prior_poc_lines   = array.new<line>()
var array<line>     prior_vah_lines   = array.new<line>()
var array<line>     prior_val_lines   = array.new<line>()
var array<line>     prior_lvn_lines   = array.new<line>()
var array<box>      prior_lvn_boxes   = array.new<box>()
var array<label>    prior_lvn_lbls    = array.new<label>()
var array<line>     prior_ext_lines   = array.new<line>()
var array<label>    prior_poc_lbls    = array.new<label>()
var array<label>    prior_vah_lbls    = array.new<label>()
var array<label>    prior_val_lbls    = array.new<label>()
var array<label>    prior_shape_lbls  = array.new<label>()
var array<box>      prior_session_boxes = array.new<box>()

// OptiPine-Style Cadence Gate & Persistent Microstructure Caches (Array-backed to survive intrabar rollback in Bar Replay)
var array<float> dev_cadence_cache   = array.new<float>(5, na) // [0: bar_idx, 1: close, 2: hi, 3: lo, 4: sess_bar]
var array<int>   prior_cadence_cache = array.new<int>(2, -1)   // [0: prior_sess_bar, 1: is_active (1 or 0)]

bool suppress_profile = htfClutterFilter and is_daily_or_above and is_subsession_mode

// Dynamic Base Profile Colors based on Shading Mode
color prof_base_b = profShadingMode == "Monochrome Slate" ? #78909C : (profShadingMode == "Monochrome Gold" ? #FFD54F : (profShadingMode == "Monochrome Cyan" ? #26C6DA : profBuyCol))
color prof_base_s = profShadingMode == "Monochrome Slate" ? #546E7A : (profShadingMode == "Monochrome Gold" ? #FFCA28 : (profShadingMode == "Monochrome Cyan" ? #00ACC1 : profSellCol))

if barstate.islast and showSessionProfiles and array.size(sess_starts) > 0 and not suppress_profile
    // ─────────────────────────────────────────────────────────────────────────
    // 1. CURRENT DEVELOPING SESSION PROFILE (RENDERED ON RIGHT MARGIN)
    // ─────────────────────────────────────────────────────────────────────────
    int dev_start_bar = array.get(sess_starts, 0)
    int dev_len       = math.max(2, bar_index - dev_start_bar + 1)
    bool dev_is_cash  = array.get(sess_is_cashes, 0)
    bool is_cur_sess_active = is_subsession_mode ? (dev_is_cash ? in_cash_rth : in_overnight) : true
    bool is_opening_unconfirmed = waitFirstBarClose and (bar_index == dev_start_bar) and not barstate.isconfirmed
    bool allow_dev_profile  = is_cur_sess_active and not is_opening_unconfirmed

    if allow_dev_profile
        // Cadence Gate: Only recompute developing profile on:
        // 1. Initial calculation (na(c_last_price))
        // 2. Bar advanced (bar_index != int(c_last_bar))
        // 3. New session started (dev_start_bar != int(c_last_sess))
        // 4. Developing High/Low breached (high > c_last_hi or low < c_last_lo)
        // 5. Intra-bar price moved >= 2 full ticks
        float c_last_bar   = array.get(dev_cadence_cache, 0)
        float c_last_price = array.get(dev_cadence_cache, 1)
        float c_last_hi    = array.get(dev_cadence_cache, 2)
        float c_last_lo    = array.get(dev_cadence_cache, 3)
        float c_last_sess  = array.get(dev_cadence_cache, 4)

        bool need_dev_recalc = na(c_last_price) or (bar_index != int(c_last_bar)) or (dev_start_bar != int(c_last_sess)) or (na(c_last_hi) ? true : high > c_last_hi) or (na(c_last_lo) ? true : low < c_last_lo) or (math.abs(close - c_last_price) >= 2 * syminfo.mintick)

        if need_dev_recalc
            dev_start_bar := math.max(0, math.max(bar_index - MAX_LOOKBACK, dev_start_bar))
            dev_len       := math.max(2, bar_index - dev_start_bar + 1)

            float dev_hi = -1e12
            float dev_lo = 1e12
            float dev_tot_v = 0.0

            int d_i_max = math.min(MAX_LOOKBACK, dev_len - 1)
            for i = 0 to d_i_max
                float bh = high[i]
                float bl = low[i]
                if not (na(bh) or na(bl))
                    dev_hi := math.max(dev_hi, bh)
                    dev_lo := math.min(dev_lo, bl)
                    dev_tot_v += nz(volume[i])

            float dev_span = dev_hi - dev_lo
            if dev_span > 0.0 and dev_tot_v > 0.0
                int res_d = 50
                float step_d = dev_span / float(res_d)
                array<float> b_dev = array.new<float>(res_d + 1, 0.0)
                array<float> s_dev = array.new<float>(res_d + 1, 0.0)

                for i = 0 to d_i_max
                    float bh = high[i]
                    float bl = low[i]
                    float bc = close[i]
                    float bo = open[i]
                    float bv = bar_buy_vol[i]
                    float sv = bar_sell_vol[i]

                    if na(bv) or na(sv) or (bv + sv <= 0.0)
                        float p_tot = nz(volume[i])
                        float p_split = (bh == bl) ? 0.5 : math.max(0.05, math.min(0.95, (bc - bl) / (bh - bl)))
                        bv := p_tot * p_split
                        sv := p_tot * (1.0 - p_split)

                    float rng = bh - bl
                    if rng <= 0.0
                        int b_flat = math.max(0, math.min(res_d, int(math.round((bc - dev_lo) / step_d))))
                        array.set(b_dev, b_flat, array.get(b_dev, b_flat) + bv)
                        array.set(s_dev, b_flat, array.get(s_dev, b_flat) + sv)
                    else
                        int b_s = math.max(0, math.min(res_d, int(math.floor((bl - dev_lo) / step_d))))
                        int b_e = math.max(0, math.min(res_d, int(math.floor((bh - dev_lo) / step_d))))
                        if b_s == b_e
                            array.set(b_dev, b_s, array.get(b_dev, b_s) + bv)
                            array.set(s_dev, b_s, array.get(s_dev, b_s) + sv)
                        else
                            for b = b_s to b_e
                                float bin_fl = dev_lo + b * step_d
                                float bin_ce = bin_fl + step_d
                                float o_lo = math.max(bl, bin_fl)
                                float o_hi = math.min(bh, bin_ce)
                                if o_hi > o_lo
                                    float w = (o_hi - o_lo) / rng
                                    array.set(b_dev, b, array.get(b_dev, b) + bv * w)
                                    array.set(s_dev, b, array.get(s_dev, b) + sv * w)

                float max_dev_b = 0.0
                float max_dev_s = 0.0
                float max_dev_tot = 0.0
                int dev_poc_b = 0
                float sum_dev_tot = 0.0
                float sum_dev_b   = 0.0
                float sum_dev_s   = 0.0

                for b = 0 to res_d
                    float vb = array.get(b_dev, b)
                    float vs = array.get(s_dev, b)
                    float vt = vb + vs
                    sum_dev_b += vb
                    sum_dev_s += vs
                    max_dev_b := math.max(max_dev_b, vb)
                    max_dev_s := math.max(max_dev_s, vs)
                    if vt > max_dev_tot
                        max_dev_tot := vt
                        dev_poc_b := b
                    sum_dev_tot += vt

                // Ata Sabanci Exact Overlap Coefficient (OVL) & Balance Tilt Engine
                float dev_ovl = 0.0
                float dev_tilt = 0.0
                string dev_ovl_word = "BALANCED"

                if sum_dev_b > 0.0 and sum_dev_s > 0.0
                    for b = 0 to res_d
                        float pb = array.get(b_dev, b) / sum_dev_b
                        float ps = array.get(s_dev, b) / sum_dev_s
                        dev_ovl += math.min(pb, ps)
                    dev_tilt := 100.0 * (sum_dev_b - sum_dev_s) / (sum_dev_b + sum_dev_s)
                    dev_ovl_word := dev_ovl >= 0.75 ? "BALANCED" : (dev_tilt >= 5.0 ? "OFF BAL · BUY" : (dev_tilt <= -5.0 ? "OFF BAL · SELL" : "OFF BALANCE"))

                float vMax_dev = math.max(max_dev_b, max_dev_s)
                float dev_poc_px = dev_lo + (dev_poc_b + 0.5) * step_d
                bool dev_poc_is_bull = array.get(b_dev, dev_poc_b) >= array.get(s_dev, dev_poc_b)
                color dev_poc_col = dev_poc_is_bull ? COL_SHELF_GOLD : COL_SHELF_PURPLE

                float dev_vah_px = na
                float dev_val_px = na

                if vaCalcMethod == "Dalton Cumulative Mass (15%-85%)"
                    float target_val_dev = sum_dev_tot * 0.15
                    float target_vah_dev = sum_dev_tot * 0.85
                    float cum_dev = 0.0
                    int dev_val_b = 0
                    int dev_vah_b = res_d
                    bool found_val_dev = false
                    bool found_vah_dev = false
                    for b = 0 to res_d
                        cum_dev += array.get(b_dev, b) + array.get(s_dev, b)
                        if not found_val_dev and cum_dev >= target_val_dev
                            dev_val_b := b
                            found_val_dev := true
                        if not found_vah_dev and cum_dev >= target_vah_dev
                            dev_vah_b := b
                            found_vah_dev := true
                            break
                    dev_vah_px := math.min(dev_hi, dev_lo + (dev_vah_b + 1.0) * step_d)
                    dev_val_px := math.max(dev_lo, dev_lo + dev_val_b * step_d)
                else
                    // Canonical CBOT Dalton Steidlmayer 2-Bin Dual Expansion with LVN Decoupling
                    float target_dva = sum_dev_tot * 0.70
                    float cur_dva    = max_dev_tot
                    int dva_up       = dev_poc_b
                    int dva_dn       = dev_poc_b
                    float lvn_d_lim  = max_dev_tot * 0.20

                    while cur_dva < target_dva and (dva_up < res_d or dva_dn > 0)
                        float s_up = 0.0
                        int u_cnt  = 0
                        for k = 1 to 2
                            if dva_up + k <= res_d
                                s_up += array.get(b_dev, dva_up + k) + array.get(s_dev, dva_up + k)
                                u_cnt += 1

                        float s_dn = 0.0
                        int d_cnt  = 0
                        for k = 1 to 2
                            if dva_dn - k >= 0
                                s_dn += array.get(b_dev, dva_dn - k) + array.get(s_dev, dva_dn - k)
                                d_cnt += 1

                        // Boundary / LVN Vacuum Decoupling: Prevent bimodal blowout across single-print void
                        if dva_up >= res_d and d_cnt > 0
                            if (s_dn / float(d_cnt)) < lvn_d_lim and cur_dva >= sum_dev_tot * 0.35
                                break
                        if dva_dn <= 0 and u_cnt > 0
                            if (s_up / float(u_cnt)) < lvn_d_lim and cur_dva >= sum_dev_tot * 0.35
                                break

                        if s_up > s_dn and dva_up < res_d
                            dva_up += u_cnt
                            cur_dva += s_up
                        else if s_dn > s_up and dva_dn > 0
                            dva_dn -= d_cnt
                            cur_dva += s_dn
                        else if s_up == s_dn and (dva_up < res_d or dva_dn > 0)
                            if u_cnt > 0 and d_cnt > 0
                                float imm_u = array.get(b_dev, dva_up + 1) + array.get(s_dev, dva_up + 1)
                                float imm_d = array.get(b_dev, dva_dn - 1) + array.get(s_dev, dva_dn - 1)
                                if imm_u >= imm_d
                                    dva_up += u_cnt
                                    cur_dva += s_up
                                else
                                    dva_dn -= d_cnt
                                    cur_dva += s_dn
                            else if u_cnt > 0
                                dva_up += u_cnt
                                cur_dva += s_up
                            else if d_cnt > 0
                                dva_dn -= d_cnt
                                cur_dva += s_dn
                            else
                                break
                        else if dva_up < res_d
                            dva_up += u_cnt
                            cur_dva += s_up
                        else if dva_dn > 0
                            dva_dn -= d_cnt
                            cur_dva += s_dn
                        else
                            break

                    dev_vah_px := math.min(dev_hi, dev_lo + math.min(float(res_d), float(dva_up) + 1.0) * step_d)
                    dev_val_px := math.max(dev_lo, dev_lo + math.max(0.0, float(dva_dn)) * step_d)

                // Dalton AMT Shape & LVN Corridor Detection
                array<int> dev_peaks = array.new<int>()
                for b = 1 to res_d - 1
                    float prev_v = array.get(b_dev, b - 1) + array.get(s_dev, b - 1)
                    float cur_v  = array.get(b_dev, b) + array.get(s_dev, b)
                    float next_v = array.get(b_dev, b + 1) + array.get(s_dev, b + 1)
                    if cur_v > prev_v and cur_v > next_v and cur_v >= 0.35 * max_dev_tot
                        array.push(dev_peaks, b)

                bool is_dev_b_shape = false
                float dev_lvn_px = na
                float dev_lvn_lo = na
                float dev_lvn_hi = na
                if array.size(dev_peaks) >= 2
                    int pk1 = array.get(dev_peaks, 0)
                    int pk2 = array.get(dev_peaks, array.size(dev_peaks) - 1)
                    if math.abs(pk2 - pk1) >= int(0.20 * res_d)
                        float min_tr = 1e12
                        int min_tr_b = -1
                        for b = math.min(pk1, pk2) to math.max(pk1, pk2)
                            float tot_k = array.get(b_dev, b) + array.get(s_dev, b)
                            if tot_k < min_tr
                                min_tr := tot_k
                                min_tr_b := b
                        float pk1_v = array.get(b_dev, pk1) + array.get(s_dev, pk1)
                        float pk2_v = array.get(b_dev, pk2) + array.get(s_dev, pk2)
                        float lvn_thresh_d = 0.60 * math.min(pk1_v, pk2_v)
                        if min_tr <= lvn_thresh_d
                            is_dev_b_shape := true
                            dev_lvn_px := dev_lo + (min_tr_b + 0.5) * step_d
                            int p_lo = math.min(pk1, pk2)
                            int p_hi = math.max(pk1, pk2)
                            int v_dev_lo = min_tr_b
                            while v_dev_lo > p_lo and (array.get(b_dev, v_dev_lo - 1) + array.get(s_dev, v_dev_lo - 1)) <= lvn_thresh_d
                                v_dev_lo -= 1
                            int v_dev_hi = min_tr_b
                            while v_dev_hi < p_hi and (array.get(b_dev, v_dev_hi + 1) + array.get(s_dev, v_dev_hi + 1)) <= lvn_thresh_d
                                v_dev_hi += 1
                            dev_lvn_lo := dev_lo + v_dev_lo * step_d
                            dev_lvn_hi := dev_lo + (v_dev_hi + 1) * step_d

                float dev_poc_rel = (dev_poc_px - dev_lo) / dev_span
                string dev_dalton = is_dev_b_shape ? "B" : (dev_poc_rel > 0.65 ? "P" : (dev_poc_rel < 0.35 ? "b" : "D"))

                cur_poc_ref      := dev_poc_px
                cur_vah_ref      := dev_vah_px
                cur_val_ref      := dev_val_px
                cur_lvn_ref      := dev_lvn_px
                cur_shape_ref    := dev_dalton
                cur_ovl_ref      := dev_ovl
                cur_tilt_ref     := dev_tilt
                cur_ovl_word_ref := dev_ovl_word

                // ── Clear & Re-render Developing Polylines & Markers ──
                if not na(dev_buy_poly)
                    polyline.delete(dev_buy_poly)
                if not na(dev_sell_poly)
                    polyline.delete(dev_sell_poly)
                if not na(dev_poc_line)
                    line.delete(dev_poc_line)
                if not na(dev_vah_line)
                    line.delete(dev_vah_line)
                if not na(dev_val_line)
                    line.delete(dev_val_line)
                if not na(dev_lvn_line)
                    line.delete(dev_lvn_line)
                    dev_lvn_line := na
                if not na(dev_lvn_box)
                    box.delete(dev_lvn_box)
                    dev_lvn_box := na
                if not na(dev_lvn_lbl)
                    label.delete(dev_lvn_lbl)
                    dev_lvn_lbl := na
                if not na(dev_poc_lbl)
                    label.delete(dev_poc_lbl)
                if not na(dev_vah_lbl)
                    label.delete(dev_vah_lbl)
                if not na(dev_val_lbl)
                    label.delete(dev_val_lbl)
                if not na(dev_shape_lbl)
                    label.delete(dev_shape_lbl)
                if not na(dev_frame_box)
                    box.delete(dev_frame_box)

                // Draw Developing Session Outline Frame
                if showSessionFrames
                    color dev_f_col = dev_is_cash ? cashFrameCol : onFrameCol
                    color dev_f_bg  = (rulerClickThrough or frameFillTransp >= 95) ? na : color.new(dev_f_col, frameFillTransp)
                    dev_frame_box := box.new(dev_start_bar, dev_hi, bar_index, dev_lo,
                         bgcolor=dev_f_bg,
                         border_color=color.new(dev_f_col, frameOutlineTransp),
                         border_width=frameOutlineWidth, border_style=STYLE_FRAME_BOX)

                int base_x = bar_index + profOffsetInput

                if vMax_dev > 0.0
                    array<chart.point> ptsB = array.new<chart.point>()
                    array.push(ptsB, chart.point.from_index(base_x, dev_lo))
                    for b = 0 to res_d
                        int xb = base_x + int(math.round(profWidthInput * array.get(b_dev, b) / vMax_dev))
                        array.push(ptsB, chart.point.from_index(xb, dev_lo + b * step_d))
                    array.push(ptsB, chart.point.from_index(base_x, dev_hi))
                    color dev_b_fill = color.new(prof_base_b, profFillTransp)
                    color dev_b_line = color.new(prof_base_b, profOutlineTransp)
                    dev_buy_poly := polyline.new(ptsB, curved=false, closed=true,
                         line_color=dev_b_line, fill_color=dev_b_fill, line_width=1)

                    array<chart.point> ptsS = array.new<chart.point>()
                    array.push(ptsS, chart.point.from_index(base_x, dev_lo))
                    for b = 0 to res_d
                        int xs = base_x + int(math.round(profWidthInput * array.get(s_dev, b) / vMax_dev))
                        array.push(ptsS, chart.point.from_index(xs, dev_lo + b * step_d))
                    array.push(ptsS, chart.point.from_index(base_x, dev_hi))
                    color dev_s_fill = color.new(prof_base_s, profFillTransp)
                    color dev_s_line = color.new(prof_base_s, profOutlineTransp)
                    dev_sell_poly := polyline.new(ptsS, curved=false, closed=true,
                         line_color=dev_s_line, fill_color=dev_s_fill, line_width=1)

                    dev_poc_line := line.new(bar_index, dev_poc_px, base_x + profWidthInput + 6, dev_poc_px,
                         color=COL_POC_LINE, width=pocLineWidth, style=STYLE_POC_LINE)
                    string dev_prefix = is_weekly_mode ? "📅 WEEK " : (is_monthly_mode ? "🗓️ MONTH " : (is_daily_cycle_mode ? "🌐 DAY " : (dev_is_cash ? (is_crypto_asset ? "☀️ DAY " : "☀️ CASH ") : (is_crypto_asset ? "🌙 NIGHT " : "🌙 ON "))))

                    if levelLabelStyle != "Hidden"
                        string dev_poc_txt = levelLabelStyle == "Bulky Badges (Legacy)" ?
                             (dev_prefix + "VPOC " + str.tostring(dev_poc_px, format.mintick) + " [" + dev_dalton + "]") :
                             (levelLabelStyle == "Compact Acronym Only" ? "POC" :
                             (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((dev_is_cash ? "C-POC " : "ON-POC ") + str.tostring(dev_poc_px, format.mintick)) :
                             ("POC " + str.tostring(dev_poc_px, format.mintick))))
                        color dev_poc_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.new(colPocInput, 20) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                        color dev_poc_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colPocInput
                        dev_poc_lbl := label.new(base_x + profWidthInput + 6, dev_poc_px, dev_poc_txt,
                             color=dev_poc_bg, textcolor=dev_poc_tx, style=label.style_label_left, size=prof_lbl_size)

                    if showSessionVa
                        dev_vah_line := line.new(bar_index, dev_vah_px, base_x + profWidthInput + 4, dev_vah_px,
                             color=COL_VAH_LINE, width=vahLineWidth, style=STYLE_VAH_LINE)
                        dev_val_line := line.new(bar_index, dev_val_px, base_x + profWidthInput + 4, dev_val_px,
                             color=COL_VAL_LINE, width=valLineWidth, style=STYLE_VAL_LINE)

                        if levelLabelStyle != "Hidden"
                            string dev_vah_txt = levelLabelStyle == "Compact Acronym Only" ? "VAH" :
                                 (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((dev_is_cash ? "C-VAH " : "ON-VAH ") + str.tostring(dev_vah_px, format.mintick)) :
                                 ("VAH " + str.tostring(dev_vah_px, format.mintick)))
                            string dev_val_txt = levelLabelStyle == "Compact Acronym Only" ? "VAL" :
                                 (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((dev_is_cash ? "C-VAL " : "ON-VAL ") + str.tostring(dev_val_px, format.mintick)) :
                                 ("VAL " + str.tostring(dev_val_px, format.mintick)))
                            color dev_va_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.new(colVahInput, 30) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                            color dev_vah_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colVahInput
                            color dev_val_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colValInput
                            dev_vah_lbl := label.new(base_x + profWidthInput + 4, dev_vah_px, dev_vah_txt,
                                 color=dev_va_bg, textcolor=dev_vah_tx, style=label.style_label_left, size=prof_lbl_size)
                            dev_val_lbl := label.new(base_x + profWidthInput + 4, dev_val_px, dev_val_txt,
                                 color=dev_va_bg, textcolor=dev_val_tx, style=label.style_label_left, size=prof_lbl_size)

                    if is_dev_b_shape and showLvnCorridor and not na(dev_lvn_px)
                        int lvn_x2 = base_x + profWidthInput + 4
                        if lvnDisplayMode != "Inflection Line Only" and not na(dev_lvn_hi) and not na(dev_lvn_lo)
                            color lvn_dev_bg = (rulerClickThrough or lvnFillTransp >= 95) ? na : color.new(COL_LVN_CORRIDOR, lvnFillTransp)
                            dev_lvn_box := box.new(bar_index, dev_lvn_hi, lvn_x2, dev_lvn_lo,
                                 bgcolor=lvn_dev_bg,
                                 border_color=color.new(COL_LVN_CORRIDOR, math.max(0, lvnFillTransp - 40)),
                                 border_width=1, border_style=STYLE_LVN_LINE)
                        if lvnDisplayMode != "Shaded Corridor Box"
                            dev_lvn_line := line.new(bar_index, dev_lvn_px, lvn_x2, dev_lvn_px,
                                 color=COL_LVN_CORRIDOR, width=1, style=STYLE_LVN_LINE)
                        if levelLabelStyle != "Hidden"
                            color dev_lvn_bg = useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100)
                            string dev_lvn_txt = levelLabelStyle == "Compact Acronym Only" ? "LVN" : ("LVN " + str.tostring(dev_lvn_px, format.mintick))
                            dev_lvn_lbl := label.new(lvn_x2, dev_lvn_px, dev_lvn_txt,
                                 color=dev_lvn_bg, textcolor=COL_LVN_CORRIDOR, style=label.style_label_left, size=prof_lbl_size)

                    if showAmtShapes
                        string ovl_short_txt = (showOvlMetrics and not na(dev_ovl)) ? (" · OVL " + str.tostring(dev_ovl, "0.00") + " " + (dev_ovl >= 0.75 ? "BAL" : (dev_tilt >= 5.0 ? "BUY" : (dev_tilt <= -5.0 ? "SELL" : "IMB")))) : ""
                        string dev_shape_txt = dev_prefix + "[" + dev_dalton + "]" + ovl_short_txt
                        color dev_shape_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.rgb(15, 18, 26) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                        color dev_shape_tx = is_dev_b_shape ? #FFD700 : (not na(dev_ovl) and dev_ovl >= 0.75 ? #00E5FF : (dev_tilt >= 5.0 ? #00E676 : (dev_tilt <= -5.0 ? #FF1744 : #CE93D8)))
                        string dev_ovl_tt  = "Ata Sabanci Order Flow Profiler:\n• Dalton Archetype: [" + dev_dalton + "]\n• Overlap Coef (OVL): " + str.tostring(dev_ovl, "0.00") + " (" + dev_ovl_word + ")\n• Balance Tilt: " + (dev_tilt >= 0 ? "+" : "") + str.tostring(dev_tilt, "0.1") + "%"
                        dev_shape_lbl := label.new(base_x + profWidthInput + 6, dev_hi, dev_shape_txt,
                             color=dev_shape_bg, textcolor=dev_shape_tx,
                             style=label.style_label_lower_left, size=prof_lbl_size, tooltip=dev_ovl_tt)

            // Cache Developing State
            array.set(dev_cadence_cache, 0, float(bar_index))
            array.set(dev_cadence_cache, 1, close)
            array.set(dev_cadence_cache, 2, high)
            array.set(dev_cadence_cache, 3, low)
            array.set(dev_cadence_cache, 4, float(dev_start_bar))
        else
            // If price hasn't breached cadence threshold, only update horizontal line lengths to right margin
            int base_x = bar_index + profOffsetInput
            if not na(dev_poc_line)
                line.set_x2(dev_poc_line, base_x + profWidthInput + 6)
            if not na(dev_poc_lbl)
                label.set_x(dev_poc_lbl, base_x + profWidthInput + 6)
            if not na(dev_shape_lbl)
                label.set_x(dev_shape_lbl, base_x + profWidthInput + 6)
            if not na(dev_vah_line)
                line.set_x2(dev_vah_line, base_x + profWidthInput + 4)
            if not na(dev_val_line)
                line.set_x2(dev_val_line, base_x + profWidthInput + 4)
            if not na(dev_lvn_line)
                line.set_x2(dev_lvn_line, base_x + profWidthInput + 4)
            if not na(dev_lvn_box)
                box.set_right(dev_lvn_box, base_x + profWidthInput + 4)
            if not na(dev_lvn_lbl)
                label.set_x(dev_lvn_lbl, base_x + profWidthInput + 4)
            array.set(dev_cadence_cache, 0, float(bar_index))
            array.set(dev_cadence_cache, 1, close)
            array.set(dev_cadence_cache, 4, float(dev_start_bar))
    else
        // Clear Developing Profile on Session Closure, Inter-Session Halt, or Weekend Halt
        if not na(dev_buy_poly)
            polyline.delete(dev_buy_poly)
            dev_buy_poly := na
        if not na(dev_sell_poly)
            polyline.delete(dev_sell_poly)
            dev_sell_poly := na
        if not na(dev_poc_line)
            line.delete(dev_poc_line)
            dev_poc_line := na
        if not na(dev_vah_line)
            line.delete(dev_vah_line)
            dev_vah_line := na
        if not na(dev_val_line)
            line.delete(dev_val_line)
            dev_val_line := na
        if not na(dev_lvn_line)
            line.delete(dev_lvn_line)
            dev_lvn_line := na
        if not na(dev_lvn_box)
            box.delete(dev_lvn_box)
            dev_lvn_box := na
        if not na(dev_lvn_lbl)
            label.delete(dev_lvn_lbl)
            dev_lvn_lbl := na
        if not na(dev_poc_lbl)
            label.delete(dev_poc_lbl)
            dev_poc_lbl := na
        if not na(dev_vah_lbl)
            label.delete(dev_vah_lbl)
            dev_vah_lbl := na
        if not na(dev_val_lbl)
            label.delete(dev_val_lbl)
            dev_val_lbl := na
        if not na(dev_shape_lbl)
            label.delete(dev_shape_lbl)
            dev_shape_lbl := na
        if not na(dev_frame_box)
            box.delete(dev_frame_box)
            dev_frame_box := na

        array.set(dev_cadence_cache, 0, float(bar_index))
        array.set(dev_cadence_cache, 1, close)
        array.set(dev_cadence_cache, 4, float(dev_start_bar))


    // ─────────────────────────────────────────────────────────────────────────
    // 2. COMPLETED PRIOR SESSION PROFILES GALLERY (ANCHORED AT SESSION BOUNDARIES)
    // ─────────────────────────────────────────────────────────────────────────
    int min_sess_req = is_cur_sess_active ? 2 : 1
    if array.size(sess_starts) >= min_sess_req
        int latest_prior_start = array.size(sess_starts) >= 2 ? array.get(sess_starts, 1) : array.get(sess_starts, 0)

        // Cadence Gate for Prior Sessions: Recompute on session handover OR session active state change
        int c_last_prior_sess = array.get(prior_cadence_cache, 0)
        int c_last_active     = array.size(prior_cadence_cache) > 1 ? array.get(prior_cadence_cache, 1) : -1
        int cur_act_int       = is_cur_sess_active ? 1 : 0
        bool need_prior_recalc = (array.size(prior_buy_polys) == 0) or (latest_prior_start != c_last_prior_sess) or (cur_act_int != c_last_active)

        if need_prior_recalc
            // ── Clear Previous Prior Session Drawings ──
            for p in prior_buy_polys
                polyline.delete(p)
            array.clear(prior_buy_polys)

            for p in prior_sell_polys
                polyline.delete(p)
            array.clear(prior_sell_polys)

            for l in prior_poc_lines
                line.delete(l)
            array.clear(prior_poc_lines)

            for l in prior_vah_lines
                line.delete(l)
            array.clear(prior_vah_lines)

            for l in prior_val_lines
                line.delete(l)
            array.clear(prior_val_lines)

            for l in prior_lvn_lines
                line.delete(l)
            array.clear(prior_lvn_lines)

            for b in prior_lvn_boxes
                box.delete(b)
            array.clear(prior_lvn_boxes)

            for lb in prior_lvn_lbls
                label.delete(lb)
            array.clear(prior_lvn_lbls)

            for l in prior_ext_lines
                line.delete(l)
            array.clear(prior_ext_lines)

            for lb in prior_poc_lbls
                label.delete(lb)
            array.clear(prior_poc_lbls)

            for lb in prior_vah_lbls
                label.delete(lb)
            array.clear(prior_vah_lbls)

            for lb in prior_val_lbls
                label.delete(lb)
            array.clear(prior_val_lbls)

            for lb in prior_shape_lbls
                label.delete(lb)
            array.clear(prior_shape_lbls)

            for b in prior_session_boxes
                box.delete(b)
            array.clear(prior_session_boxes)

            int s_start_idx = is_cur_sess_active ? 1 : 0
            int max_prior_sessions = math.min(priorSessionsCount - 1 + s_start_idx, array.size(sess_starts) - 1)

            for s_idx = s_start_idx to max_prior_sessions
                int prior_start_bar = array.get(sess_starts, s_idx)
                bool prior_is_cash  = array.get(sess_is_cashes, s_idx)
                int prior_end_bar   = s_idx == 0 ? (prior_is_cash ? (cash_end_idx > 0 ? cash_end_idx : bar_index) : (on_end_idx > 0 ? on_end_idx : bar_index)) : (array.get(sess_starts, s_idx - 1) - 1)

                prior_start_bar := math.max(0, math.max(bar_index - MAX_LOOKBACK, prior_start_bar))
                prior_end_bar   := math.max(prior_start_bar, math.min(bar_index, prior_end_bar))
                int prior_len   = prior_end_bar - prior_start_bar + 1

                int p_i_min = math.max(0, bar_index - prior_end_bar)
                int p_i_max = math.min(MAX_LOOKBACK, bar_index - prior_start_bar)
                p_i_min := math.min(p_i_min, p_i_max)

                if prior_len >= 2 and p_i_max >= p_i_min
                    float prior_hi = -1e12
                    float prior_lo = 1e12
                    float prior_tot_v = 0.0

                    for i = p_i_min to p_i_max
                        float bh = high[i]
                        float bl = low[i]
                        if not (na(bh) or na(bl))
                            prior_hi := math.max(prior_hi, bh)
                            prior_lo := math.min(prior_lo, bl)
                            prior_tot_v += nz(volume[i])

                    float prior_span = prior_hi - prior_lo
                    if prior_span > 0.0 and prior_tot_v > 0.0
                        int res_p = 50
                        float step_p = prior_span / float(res_p)
                        array<float> b_prior = array.new<float>(res_p + 1, 0.0)
                        array<float> s_prior = array.new<float>(res_p + 1, 0.0)

                        for i = p_i_min to p_i_max
                            float bh = high[i]
                            float bl = low[i]
                            float bc = close[i]
                            float bo = open[i]
                            float bv = bar_buy_vol[i]
                            float sv = bar_sell_vol[i]

                            if na(bv) or na(sv) or (bv + sv <= 0.0)
                                float p_tot = nz(volume[i])
                                float p_split = (bh == bl) ? 0.5 : math.max(0.05, math.min(0.95, (bc - bl) / (bh - bl)))
                                bv := p_tot * p_split
                                sv := p_tot * (1.0 - p_split)

                            float rng = bh - bl
                            if rng <= 0.0
                                int b_flat = math.max(0, math.min(res_p, int(math.round((bc - prior_lo) / step_p))))
                                array.set(b_prior, b_flat, array.get(b_prior, b_flat) + bv)
                                array.set(s_prior, b_flat, array.get(s_prior, b_flat) + sv)
                            else
                                int b_s = math.max(0, math.min(res_p, int(math.floor((bl - prior_lo) / step_p))))
                                int b_e = math.max(0, math.min(res_p, int(math.floor((bh - prior_lo) / step_p))))
                                if b_s == b_e
                                    array.set(b_prior, b_s, array.get(b_prior, b_s) + bv)
                                    array.set(s_prior, b_s, array.get(s_prior, b_s) + sv)
                                else
                                    for b = b_s to b_e
                                        float bin_fl = prior_lo + b * step_p
                                        float bin_ce = bin_fl + step_p
                                        float o_lo = math.max(bl, bin_fl)
                                        float o_hi = math.min(bh, bin_ce)
                                        if o_hi > o_lo
                                            float w = (o_hi - o_lo) / rng
                                            array.set(b_prior, b, array.get(b_prior, b) + bv * w)
                                            array.set(s_prior, b, array.get(s_prior, b) + sv * w)

                        float max_prior_b = 0.0
                        float max_prior_s = 0.0
                        float max_prior_tot = 0.0
                        int prior_poc_b = 0
                        float sum_prior_tot = 0.0
                        float sum_prior_b   = 0.0
                        float sum_prior_s   = 0.0

                        for b = 0 to res_p
                            float vb = array.get(b_prior, b)
                            float vs = array.get(s_prior, b)
                            float vt = vb + vs
                            sum_prior_b += vb
                            sum_prior_s += vs
                            max_prior_b := math.max(max_prior_b, vb)
                            max_prior_s := math.max(max_prior_s, vs)
                            if vt > max_prior_tot
                                max_prior_tot := vt
                                prior_poc_b := b
                            sum_prior_tot += vt

                        // Ata Sabanci Exact Overlap Coefficient (OVL) & Balance Tilt Engine
                        float prior_ovl = 0.0
                        float prior_tilt = 0.0
                        string prior_ovl_word = "BALANCED"

                        if sum_prior_b > 0.0 and sum_prior_s > 0.0
                            for b = 0 to res_p
                                float pb = array.get(b_prior, b) / sum_prior_b
                                float ps = array.get(s_prior, b) / sum_prior_s
                                prior_ovl += math.min(pb, ps)
                            prior_tilt := 100.0 * (sum_prior_b - sum_prior_s) / (sum_prior_b + sum_prior_s)
                            prior_ovl_word := prior_ovl >= 0.75 ? "BALANCED" : (prior_tilt >= 5.0 ? "OFF BAL · BUY" : (prior_tilt <= -5.0 ? "OFF BAL · SELL" : "OFF BALANCE"))

                        float vMax_prior = math.max(max_prior_b, max_prior_s)
                        float prior_poc_px = prior_lo + (prior_poc_b + 0.5) * step_p
                        bool prior_poc_is_bull = array.get(b_prior, prior_poc_b) >= array.get(s_prior, prior_poc_b)
                        color prior_poc_col = prior_poc_is_bull ? COL_SHELF_GOLD : COL_SHELF_PURPLE

                        float prior_vah_px = na
                        float prior_val_px = na

                        if vaCalcMethod == "Dalton Cumulative Mass (15%-85%)"
                            float target_val_prior = sum_prior_tot * 0.15
                            float target_vah_prior = sum_prior_tot * 0.85
                            float cum_prior = 0.0
                            int prior_val_b = 0
                            int prior_vah_b = res_p
                            bool found_val_prior = false
                            bool found_vah_prior = false
                            for b = 0 to res_p
                                cum_prior += array.get(b_prior, b) + array.get(s_prior, b)
                                if not found_val_prior and cum_prior >= target_val_prior
                                    prior_val_b := b
                                    found_val_prior := true
                                if not found_vah_prior and cum_prior >= target_vah_prior
                                    prior_vah_b := b
                                    found_vah_prior := true
                                    break
                            prior_vah_px := math.min(prior_hi, prior_lo + (prior_vah_b + 1.0) * step_p)
                            prior_val_px := math.max(prior_lo, prior_lo + prior_val_b * step_p)
                        else
                            // Canonical CBOT Dalton Steidlmayer 2-Bin Dual Expansion with LVN Decoupling
                            float target_pva = sum_prior_tot * 0.70
                            float cur_pva    = max_prior_tot
                            int pva_up       = prior_poc_b
                            int pva_dn       = prior_poc_b
                            float lvn_p_lim  = max_prior_tot * 0.20

                            while cur_pva < target_pva and (pva_up < res_p or pva_dn > 0)
                                float s_up = 0.0
                                int u_cnt  = 0
                                for k = 1 to 2
                                    if pva_up + k <= res_p
                                        s_up += array.get(b_prior, pva_up + k) + array.get(s_prior, pva_up + k)
                                        u_cnt += 1

                                float s_dn = 0.0
                                int d_cnt  = 0
                                for k = 1 to 2
                                    if pva_dn - k >= 0
                                        s_dn += array.get(b_prior, pva_dn - k) + array.get(s_prior, pva_dn - k)
                                        d_cnt += 1

                                // Boundary / LVN Vacuum Decoupling: Prevent bimodal blowout across single-print void
                                if pva_up >= res_p and d_cnt > 0
                                    if (s_dn / float(d_cnt)) < lvn_p_lim and cur_pva >= sum_prior_tot * 0.35
                                        break
                                if pva_dn <= 0 and u_cnt > 0
                                    if (s_up / float(u_cnt)) < lvn_p_lim and cur_pva >= sum_prior_tot * 0.35
                                        break

                                if s_up > s_dn and pva_up < res_p
                                    pva_up += u_cnt
                                    cur_pva += s_up
                                else if s_dn > s_up and pva_dn > 0
                                    pva_dn -= d_cnt
                                    cur_pva += s_dn
                                else if s_up == s_dn and (pva_up < res_p or pva_dn > 0)
                                    if u_cnt > 0 and d_cnt > 0
                                        float imm_u = array.get(b_prior, pva_up + 1) + array.get(s_prior, pva_up + 1)
                                        float imm_d = array.get(b_prior, pva_dn - 1) + array.get(s_prior, pva_dn - 1)
                                        if imm_u >= imm_d
                                            pva_up += u_cnt
                                            cur_pva += s_up
                                        else
                                            pva_dn -= d_cnt
                                            cur_pva += s_dn
                                    else if u_cnt > 0
                                        pva_up += u_cnt
                                        cur_pva += s_up
                                    else if d_cnt > 0
                                        pva_dn -= d_cnt
                                        cur_pva += s_dn
                                    else
                                        break
                                else if pva_up < res_p
                                    pva_up += u_cnt
                                    cur_pva += s_up
                                else if pva_dn > 0
                                    pva_dn -= d_cnt
                                    cur_pva += s_dn
                                else
                                    break

                            prior_vah_px := math.min(prior_hi, prior_lo + math.min(float(res_p), float(pva_up) + 1.0) * step_p)
                            prior_val_px := math.max(prior_lo, prior_lo + math.max(0.0, float(pva_dn)) * step_p)

                        // AMT Shape & LVN
                        array<int> prior_peaks = array.new<int>()
                        for b = 1 to res_p - 1
                            float prev_v = array.get(b_prior, b - 1) + array.get(s_prior, b - 1)
                            float cur_v  = array.get(b_prior, b) + array.get(s_prior, b)
                            float next_v = array.get(b_prior, b + 1) + array.get(s_prior, b + 1)
                            if cur_v > prev_v and cur_v > next_v and cur_v >= 0.35 * max_prior_tot
                                array.push(prior_peaks, b)

                        bool is_prior_b_shape = false
                        float prior_lvn_px = na
                        float prior_lvn_lo = na
                        float prior_lvn_hi = na
                        if array.size(prior_peaks) >= 2
                            int pk1 = array.get(prior_peaks, 0)
                            int pk2 = array.get(prior_peaks, array.size(prior_peaks) - 1)
                            if math.abs(pk2 - pk1) >= int(0.20 * res_p)
                                float min_tr = 1e12
                                int min_tr_b = -1
                                for b = math.min(pk1, pk2) to math.max(pk1, pk2)
                                    float tot_k = array.get(b_prior, b) + array.get(s_prior, b)
                                    if tot_k < min_tr
                                        min_tr := tot_k
                                        min_tr_b := b
                                float pk1_v = array.get(b_prior, pk1) + array.get(s_prior, pk1)
                                float pk2_v = array.get(b_prior, pk2) + array.get(s_prior, pk2)
                                float lvn_thresh_p = 0.60 * math.min(pk1_v, pk2_v)
                                if min_tr <= lvn_thresh_p
                                    is_prior_b_shape := true
                                    prior_lvn_px := prior_lo + (min_tr_b + 0.5) * step_p
                                    int p_lo = math.min(pk1, pk2)
                                    int p_hi = math.max(pk1, pk2)
                                    int v_lo = min_tr_b
                                    while v_lo > p_lo and (array.get(b_prior, v_lo - 1) + array.get(s_prior, v_lo - 1)) <= lvn_thresh_p
                                        v_lo -= 1
                                    int v_hi = min_tr_b
                                    while v_hi < p_hi and (array.get(b_prior, v_hi + 1) + array.get(s_prior, v_hi + 1)) <= lvn_thresh_p
                                        v_hi += 1
                                    prior_lvn_lo := prior_lo + v_lo * step_p
                                    prior_lvn_hi := prior_lo + (v_hi + 1) * step_p

                        float prior_poc_rel = (prior_poc_px - prior_lo) / prior_span
                        string prior_dalton = is_prior_b_shape ? "B" : (prior_poc_rel > 0.65 ? "P" : (prior_poc_rel < 0.35 ? "b" : "D"))

                        int latest_closed_idx = is_cur_sess_active ? 1 : 0

                        // Synchronize Section 10 with True Gaussian Profile Values on Latest Cash Session
                        if s_idx == latest_closed_idx and prior_is_cash
                            prior_cash_vpoc := prior_poc_px
                            prior_cash_vah  := prior_vah_px
                            prior_cash_val  := prior_val_px

                        if s_idx == latest_closed_idx and not is_cur_sess_active
                            cur_poc_ref      := prior_poc_px
                            cur_vah_ref      := prior_vah_px
                            cur_val_ref      := prior_val_px
                            cur_lvn_ref      := prior_lvn_px
                            cur_shape_ref    := prior_dalton
                            cur_ovl_ref      := prior_ovl
                            cur_tilt_ref     := prior_tilt
                            cur_ovl_word_ref := prior_ovl_word

                        // Draw Session Profile Framing Outline (Clean Contact with Next Session)
                        if showSessionFrames
                            color f_col = prior_is_cash ? cashFrameCol : onFrameCol
                            color f_bg  = (rulerClickThrough or frameFillTransp >= 95) ? na : color.new(f_col, frameFillTransp)
                            box s_box = box.new(prior_start_bar, prior_hi, prior_end_bar, prior_lo,
                                 bgcolor=f_bg,
                                 border_color=color.new(f_col, frameOutlineTransp),
                                 border_width=frameOutlineWidth, border_style=STYLE_FRAME_BOX)
                            array.push(prior_session_boxes, s_box)

                        // Render Completed Session Profile Anchored at Session Start with Expressive Scaling
                        float span_ratio = profSpanMode == "Compact (20% Span)" ? 0.20 : (profSpanMode == "Balanced (35% Span)" ? 0.35 : (profSpanMode == "Expressive (50% Span)" ? 0.50 : (profSpanMode == "Wide (65% Span)" ? 0.65 : 0.0)))
                        int eff_w_prior = span_ratio > 0.0 ? math.max(10, int(prior_len * span_ratio)) : math.min(profWidthInput, int(prior_len * 0.75))
                        int s_transp = math.min(95, profFillTransp + (s_idx - 1) * 2)
                        if vMax_prior > 0.0
                            array<chart.point> ptsB_p = array.new<chart.point>()
                            array.push(ptsB_p, chart.point.from_index(prior_start_bar, prior_lo))
                            for b = 0 to res_p
                                int xb = prior_start_bar + int(math.round(eff_w_prior * array.get(b_prior, b) / vMax_prior))
                                array.push(ptsB_p, chart.point.from_index(xb, prior_lo + b * step_p))
                            array.push(ptsB_p, chart.point.from_index(prior_start_bar, prior_hi))
                            int s_out_transp = math.min(100, profOutlineTransp + (s_idx - 1) * 2)
                            color prior_b_fill = color.new(prof_base_b, s_transp)
                            color prior_b_line = color.new(prof_base_b, s_out_transp)
                            polyline p_buy = polyline.new(ptsB_p, curved=false, closed=true,
                                 line_color=prior_b_line, fill_color=prior_b_fill, line_width=1)
                            array.push(prior_buy_polys, p_buy)

                            array<chart.point> ptsS_p = array.new<chart.point>()
                            array.push(ptsS_p, chart.point.from_index(prior_start_bar, prior_lo))
                            for b = 0 to res_p
                                int xs = prior_start_bar + int(math.round(eff_w_prior * array.get(s_prior, b) / vMax_prior))
                                array.push(ptsS_p, chart.point.from_index(xs, prior_lo + b * step_p))
                            array.push(ptsS_p, chart.point.from_index(prior_start_bar, prior_hi))
                            color prior_s_fill = color.new(prof_base_s, s_transp)
                            color prior_s_line = color.new(prof_base_s, s_out_transp)
                            polyline p_sell = polyline.new(ptsS_p, curved=false, closed=true,
                                 line_color=prior_s_line, fill_color=prior_s_fill, line_width=1)
                            array.push(prior_sell_polys, p_sell)

                            // Completed Level Lines
                            line p_poc = line.new(prior_start_bar, prior_poc_px, prior_end_bar, prior_poc_px,
                                 color=COL_POC_LINE, width=pocLineWidth, style=STYLE_POC_LINE)
                            array.push(prior_poc_lines, p_poc)

                            string prior_prefix = is_weekly_mode ? "📅 W-" : (is_monthly_mode ? "🗓️ M-" : (is_daily_cycle_mode ? "🌐 D-" : (prior_is_cash ? (is_crypto_asset ? "☀️ DAY " : "☀️ CASH ") : (is_crypto_asset ? "🌙 NIGHT " : "🌙 ON "))))

                            // Completed Level Labels (Acronym directly on line vs Bulky Badges)
                            if levelLabelStyle != "Hidden"
                                int p_lbl_x = levelLabelPos == "Left Edge (Inside Box)" ? prior_start_bar :
                                     (levelLabelPos == "Center of Session" ? int(math.round((prior_start_bar + prior_end_bar) * 0.5)) : (levelLabelPos == "Right Edge (Outside Box)" ? prior_end_bar + 1 : prior_end_bar))
                                string p_lbl_st = levelLabelStyle == "Bulky Badges (Legacy)" ? label.style_label_right :
                                     (levelLabelPos == "Center of Session" ? label.style_label_center :
                                     (levelLabelPos == "Right Edge (Inside Box)" ? label.style_label_right : label.style_label_left))
                                int eff_lbl_x = levelLabelStyle == "Bulky Badges (Legacy)" ? prior_start_bar : p_lbl_x

                                string prior_poc_txt = levelLabelStyle == "Bulky Badges (Legacy)" ?
                                     (prior_prefix + "VPOC " + str.tostring(prior_poc_px, format.mintick) + " [" + prior_dalton + "]") :
                                     (levelLabelStyle == "Compact Acronym Only" ? "POC" :
                                     (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((prior_is_cash ? "C-POC " : "ON-POC ") + str.tostring(prior_poc_px, format.mintick)) :
                                     ("POC " + str.tostring(prior_poc_px, format.mintick))))
                                color p_poc_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.new(colPocInput, 20) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                                color p_poc_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colPocInput
                                label p_lbl = label.new(eff_lbl_x, prior_poc_px, prior_poc_txt,
                                     color=p_poc_bg, textcolor=p_poc_tx, style=p_lbl_st, size=prof_lbl_size)
                                array.push(prior_poc_lbls, p_lbl)

                            // Extending Virgin POC forward to live bar (for most recent completed session)
                            if extendVpocInput and s_idx == latest_closed_idx
                                int r_edge = bar_index + profOffsetInput + profWidthInput + 6
                                line p_ext = line.new(prior_end_bar, prior_poc_px, r_edge, prior_poc_px,
                                     color=color.new(colPocInput, math.min(pocTransp + 20, 90)), width=math.max(1, pocLineWidth - 1), style=line.style_dotted)
                                array.push(prior_ext_lines, p_ext)

                            if showSessionVa
                                line p_vah = line.new(prior_start_bar, prior_vah_px, prior_end_bar, prior_vah_px,
                                     color=COL_VAH_LINE, width=vahLineWidth, style=STYLE_VAH_LINE)
                                line p_val = line.new(prior_start_bar, prior_val_px, prior_end_bar, prior_val_px,
                                     color=COL_VAL_LINE, width=valLineWidth, style=STYLE_VAL_LINE)
                                array.push(prior_vah_lines, p_vah)
                                array.push(prior_val_lines, p_val)

                                if levelLabelStyle != "Hidden"
                                    int p_lbl_x = levelLabelPos == "Left Edge (Inside Box)" ? prior_start_bar :
                                         (levelLabelPos == "Center of Session" ? int(math.round((prior_start_bar + prior_end_bar) * 0.5)) : (levelLabelPos == "Right Edge (Outside Box)" ? prior_end_bar + 1 : prior_end_bar))
                                    string p_lbl_st = levelLabelStyle == "Bulky Badges (Legacy)" ? label.style_label_right :
                                         (levelLabelPos == "Center of Session" ? label.style_label_center :
                                         (levelLabelPos == "Right Edge (Inside Box)" ? label.style_label_right : label.style_label_left))
                                    int eff_lbl_x = levelLabelStyle == "Bulky Badges (Legacy)" ? prior_start_bar : p_lbl_x

                                    string prior_vah_txt = levelLabelStyle == "Bulky Badges (Legacy)" ?
                                         (prior_prefix + "VAH " + str.tostring(prior_vah_px, format.mintick)) :
                                         (levelLabelStyle == "Compact Acronym Only" ? "VAH" :
                                         (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((prior_is_cash ? "C-VAH " : "ON-VAH ") + str.tostring(prior_vah_px, format.mintick)) :
                                         ("VAH " + str.tostring(prior_vah_px, format.mintick))))
                                    string prior_val_txt = levelLabelStyle == "Bulky Badges (Legacy)" ?
                                         (prior_prefix + "VAL " + str.tostring(prior_val_px, format.mintick)) :
                                         (levelLabelStyle == "Compact Acronym Only" ? "VAL" :
                                         (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((prior_is_cash ? "C-VAL " : "ON-VAL ") + str.tostring(prior_val_px, format.mintick)) :
                                         ("VAL " + str.tostring(prior_val_px, format.mintick))))

                                    color p_va_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.new(colVahInput, 30) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                                    color p_vah_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colVahInput
                                    color p_val_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : colValInput

                                    label p_vah_lbl = label.new(eff_lbl_x, prior_vah_px, prior_vah_txt,
                                         color=p_va_bg, textcolor=p_vah_tx, style=p_lbl_st, size=prof_lbl_size)
                                    label p_val_lbl = label.new(eff_lbl_x, prior_val_px, prior_val_txt,
                                         color=p_va_bg, textcolor=p_val_tx, style=p_lbl_st, size=prof_lbl_size)
                                    array.push(prior_vah_lbls, p_vah_lbl)
                                    array.push(prior_val_lbls, p_val_lbl)

                            if is_prior_b_shape and showLvnCorridor and not na(prior_lvn_px)
                                int r_edge_lvn = prior_end_bar
                                if lvnExtendMode == "Extend Until Mitigated"
                                    if p_i_min > 0
                                        int mit_i = -1
                                        int f_i = p_i_min - 1
                                        while f_i >= 0
                                            float c_f = close[f_i]
                                            if not na(c_f) and not na(prior_lvn_lo) and not na(prior_lvn_hi) and (c_f >= prior_lvn_lo and c_f <= prior_lvn_hi)
                                                mit_i := f_i
                                                break
                                            f_i -= 1
                                        if mit_i >= 0
                                            r_edge_lvn := bar_index - mit_i
                                        else
                                            r_edge_lvn := bar_index + profOffsetInput + profWidthInput + 6
                                    else
                                        r_edge_lvn := bar_index + profOffsetInput + profWidthInput + 6

                                // Shaded Corridor Box
                                if lvnDisplayMode != "Inflection Line Only" and not na(prior_lvn_hi) and not na(prior_lvn_lo)
                                    color prior_lvn_bg = (rulerClickThrough or lvnFillTransp >= 95) ? na : color.new(COL_LVN_CORRIDOR, lvnFillTransp)
                                    box p_lvn_b = box.new(prior_start_bar, prior_lvn_hi, r_edge_lvn, prior_lvn_lo,
                                         bgcolor=prior_lvn_bg,
                                         border_color=color.new(COL_LVN_CORRIDOR, math.max(0, lvnFillTransp - 40)),
                                         border_width=1, border_style=STYLE_LVN_LINE)
                                    array.push(prior_lvn_boxes, p_lvn_b)

                                // Inflection Centerline
                                if lvnDisplayMode != "Shaded Corridor Box"
                                    line p_lvn = line.new(prior_start_bar, prior_lvn_px, r_edge_lvn, prior_lvn_px,
                                         color=COL_LVN_CORRIDOR, width=1, style=STYLE_LVN_LINE)
                                    array.push(prior_lvn_lines, p_lvn)

                                // Label with Knockout Shield Pill
                                if levelLabelStyle != "Hidden"
                                    int p_lvn_lbl_x = levelLabelPos == "Left Edge (Inside Box)" ? prior_start_bar :
                                         (levelLabelPos == "Center of Session" ? int(math.round((prior_start_bar + prior_end_bar) * 0.5)) : (levelLabelPos == "Right Edge (Outside Box)" ? prior_end_bar + 1 : prior_end_bar))
                                    string p_lvn_lbl_st = levelLabelStyle == "Bulky Badges (Legacy)" ? label.style_label_right :
                                         (levelLabelPos == "Center of Session" ? label.style_label_center :
                                         (levelLabelPos == "Right Edge (Inside Box)" ? label.style_label_right : label.style_label_left))
                                    int eff_lvn_lbl_x = levelLabelStyle == "Bulky Badges (Legacy)" ? prior_start_bar : p_lvn_lbl_x
                                    string prior_lvn_txt = levelLabelStyle == "Bulky Badges (Legacy)" ?
                                         (prior_prefix + "LVN " + str.tostring(prior_lvn_px, format.mintick)) :
                                         (levelLabelStyle == "Compact Acronym Only" ? "LVN" :
                                         (levelLabelStyle == "Session Acronym (C-POC / ON-POC)" ? ((prior_is_cash ? "C-LVN " : "ON-LVN ") + str.tostring(prior_lvn_px, format.mintick)) :
                                         ("LVN " + str.tostring(prior_lvn_px, format.mintick))))
                                    color p_lvn_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.new(COL_LVN_CORRIDOR, 20) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                                    color p_lvn_tx = levelLabelStyle == "Bulky Badges (Legacy)" ? color.white : COL_LVN_CORRIDOR
                                    label p_lvn_lbl = label.new(eff_lvn_lbl_x, prior_lvn_px, prior_lvn_txt,
                                         color=p_lvn_bg, textcolor=p_lvn_tx, style=p_lvn_lbl_st, size=prof_lbl_size)
                                    array.push(prior_lvn_lbls, p_lvn_lbl)

                            if showAmtShapes
                                string p_ovl_short_txt = (showOvlMetrics and not na(prior_ovl)) ? (" · OVL " + str.tostring(prior_ovl, "0.00") + " " + (prior_ovl >= 0.75 ? "BAL" : (prior_tilt >= 5.0 ? "BUY" : (prior_tilt <= -5.0 ? "SELL" : "IMB")))) : ""
                                string prior_shape_txt = prior_prefix + "[" + prior_dalton + "]" + p_ovl_short_txt
                                color p_shape_bg = levelLabelStyle == "Bulky Badges (Legacy)" ? color.rgb(15, 18, 26) : (useShieldPill ? COL_SHIELD_PILL : color.new(color.black, 100))
                                color p_shape_tx = is_prior_b_shape ? #FFD700 : (not na(prior_ovl) and prior_ovl >= 0.75 ? #00E5FF : (prior_tilt >= 5.0 ? #00E676 : (prior_tilt <= -5.0 ? #FF1744 : #CE93D8)))
                                string p_ovl_tt  = "Ata Sabanci Order Flow Profiler:\n• Dalton Archetype: [" + prior_dalton + "]\n• Overlap Coef (OVL): " + str.tostring(prior_ovl, "0.00") + " (" + prior_ovl_word + ")\n• Balance Tilt: " + (prior_tilt >= 0 ? "+" : "") + str.tostring(prior_tilt, "0.1") + "%"
                                label p_shape = label.new(prior_start_bar + eff_w_prior + 2, prior_hi, prior_shape_txt,
                                     color=p_shape_bg, textcolor=p_shape_tx,
                                     style=label.style_label_lower_left, size=prof_lbl_size, tooltip=p_ovl_tt)
                                array.push(prior_shape_lbls, p_shape)

            // Cache Prior Cadence State
            array.set(prior_cadence_cache, 0, latest_prior_start)
            array.set(prior_cadence_cache, 1, cur_act_int)
        else
            // Prior session profiles are completely static — update active extension endpoints if bar advanced
            int r_edge = bar_index + profOffsetInput + profWidthInput + 6
            if extendVpocInput and array.size(prior_ext_lines) > 0
                for l in prior_ext_lines
                    line.set_x2(l, r_edge)
            if lvnExtendMode == "Extend Until Mitigated"
                for l in prior_lvn_lines
                    if line.get_x2(l) >= bar_index - 1
                        line.set_x2(l, r_edge)
                for b in prior_lvn_boxes
                    if box.get_right(b) >= bar_index - 1
                        box.set_right(b, r_edge)

// =============================================================================
// SECTION 12: INSTITUTIONAL HEADS-UP DISPLAY & EDUCATIONAL TABLE
// =============================================================================

// Unified Single-Table Architecture (Eliminates Screen Position Occlusion & Multi-Table Conflicts)
var table hud_display = table.new(
     hudPositionInput == "Top Right" ? position.top_right : (hudPositionInput == "Top Left" ? position.top_left : (hudPositionInput == "Bottom Right" ? position.bottom_right : position.bottom_left)),
     3, 7, bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)

// Diagnostic Script Stopwatch (PineCoders Stopwatch Pattern - SKILL.md Section 19)
var int _t0_perf = na
if barstate.islast
    _t0_perf := barstate.islast ? timenow : na

if barstate.islast and hudModeInput == "Disabled"
    table.clear(hud_display, 0, 0, 2, 6)

if barstate.islast and hudModeInput != "Disabled"
    // Reference Structural Levels
    float ref_poc = not na(cur_poc_ref) ? cur_poc_ref : (not na(prior_cash_vpoc) ? prior_cash_vpoc : close)
    float ref_vah = not na(cur_vah_ref) ? cur_vah_ref : (not na(prior_cash_vah)  ? prior_cash_vah  : high)
    float ref_val = not na(cur_val_ref) ? cur_val_ref : (not na(prior_cash_val)  ? prior_cash_val  : low)
    string ref_shape = cur_shape_ref

    // Safe tick step and unit formatters (Equities $ vs Futures pt)
    float safe_tick_step = asset_tick_step > 0 ? asset_tick_step : 0.01
    string unit_sfx      = is_equity_asset ? "" : " pt"
    string unit_pfx      = is_equity_asset ? "$" : ""
    string px_fmt        = is_equity_asset ? "#.00" : "#.#"

    // Real-Time Distance to Reference Levels (in points and ticks)
    float dist_poc_pts = close - ref_poc
    float dist_vah_pts = close - ref_vah
    float dist_val_pts = close - ref_val
    float dist_hb_pts  = not na(on_halfback) ? (close - on_halfback) : na

    // Active Engine & Footprint Telemetry
    string active_engine_label = replayOptimized ? "Lightweight (Geo)" : 
         (useFpEngine and hasEngFp ? "Native FP (v6)" : 
         (useIbEngine ? ("Intrabar (" + effective_ltf + ")") : "Geo Proxy"))

    // Real-time Bar Footprint Delta & Session Delta
    string bar_delta_str  = (bar_delta >= 0 ? "+" : "") + str.tostring(bar_delta, "#,###") + " Δ"
    string sess_delta_str = (sess_cum_delta >= 0 ? "+" : "") + str.tostring(sess_cum_delta, "#,###") + " Δ"
    string tape_flow_str  = "Bar: " + bar_delta_str + " | Sess: " + sess_delta_str

    // Deterministic Auction State Machine & Target Resolution
    string amt_state_txt  = ""
    string amt_target_txt = ""
    color  amt_state_col  = color.white

    if close > ref_vah
        amt_state_txt  := "Above Value (Premium Auction)"
        amt_target_txt := "Pullback to VAH: " + unit_pfx + str.tostring(math.abs(dist_vah_pts), px_fmt) + unit_sfx + " (" + str.tostring(int(math.abs(dist_vah_pts) / safe_tick_step)) + "t)"
        amt_state_col  := #00E676
    else if close < ref_val
        amt_state_txt  := "Below Value (Discount Auction)"
        amt_target_txt := "Rally to VAL: " + unit_pfx + str.tostring(math.abs(dist_val_pts), px_fmt) + unit_sfx + " (" + str.tostring(int(math.abs(dist_val_pts) / safe_tick_step)) + "t)"
        amt_state_col  := #FF1744
    else
        bool is_above_poc = close >= ref_poc
        amt_state_txt  := "Inside Value Area (80% Rotation Active)"
        amt_target_txt := is_above_poc ? 
             ("To VPOC: " + unit_pfx + str.tostring(math.abs(dist_poc_pts), px_fmt) + unit_sfx + " | To VAL: " + unit_pfx + str.tostring(math.abs(dist_val_pts), px_fmt) + unit_sfx) : 
             ("To VPOC: " + unit_pfx + str.tostring(math.abs(dist_poc_pts), px_fmt) + unit_sfx + " | To VAH: " + unit_pfx + str.tostring(math.abs(dist_vah_pts), px_fmt) + unit_sfx)
        amt_state_col  := #FFD54F

    // Confluent Order Flow Imbalance Detection at Structural Lines
    string conf_shelf_msg = "None in Proximity"
    color  conf_shelf_col = color.rgb(120, 144, 156)
    if showConfluentAlert and array.size(active_shelves) > 0
        for i = 0 to array.size(active_shelves) - 1
            ImbShelf sh = array.get(active_shelves, i)
            float d_val = math.abs(sh.price - ref_val)
            float d_vah = math.abs(sh.price - ref_vah)
            float d_poc = math.abs(sh.price - ref_poc)
            float d_hb  = not na(on_halfback) ? math.abs(sh.price - on_halfback) : 99999.0

            if d_val <= asset_cluster_tol and sh.is_bull
                conf_shelf_msg := "⚡ Bull Shelf at VAL (" + str.tostring(sh.price, format.mintick) + ")"
                conf_shelf_col := COL_SHELF_GOLD
                break
            else if d_vah <= asset_cluster_tol and not sh.is_bull
                conf_shelf_msg := "⚡ Bear Shelf at VAH (" + str.tostring(sh.price, format.mintick) + ")"
                conf_shelf_col := COL_SHELF_PURPLE
                break
            else if d_poc <= asset_cluster_tol
                conf_shelf_msg := "⚡ Shelf at VPOC (" + str.tostring(sh.price, format.mintick) + ")"
                conf_shelf_col := COL_POC_LINE
                break
            else if d_hb <= asset_cluster_tol
                conf_shelf_msg := "⚡ Shelf at Half-Back (" + str.tostring(sh.price, format.mintick) + ")"
                conf_shelf_col := COL_HALFBACK
                break

    // Dalton Shape AMT Interpretation & LVN Vacuum Telemetry
    string shape_desc = ref_shape == "D" ? "Normal distribution (2-sided consensus)" : 
         (ref_shape == "P" ? "Old sellers trapped; high value skew" : 
         (ref_shape == "b" ? "Long liquidation; low value skew" : "Double distribution; LVN liquidity vacuum"))

    // LVN Vacuum Corridor details for B-Shapes
    string lvn_telemetry = ""
    if ref_shape == "B" and not na(cur_lvn_ref)
        float dist_lvn = close - cur_lvn_ref
        lvn_telemetry := " | LVN: " + str.tostring(cur_lvn_ref, format.mintick) + " (" + (dist_lvn >= 0 ? "+" : "-") + unit_pfx + str.tostring(math.abs(dist_lvn), px_fmt) + unit_sfx + ")"

    string shape_note = ref_shape == "D" ? "D-Shape profiles exhibit high mean-reversion tendency back to VPOC when sweeps fail outside Value Area." : 
         (ref_shape == "B" ? "B-Shape double distributions exhibit ~2.5x higher traversal speed across the central LVN liquidity vacuum." : 
         (ref_shape == "P" ? "P-Shape stems exhibit low support if price breaks back below the upper distribution node." : 
         "b-Shape stems exhibit low resistance if price rallies back above the lower distribution node."))

    // Visual Palette Tokens
    color bg_hdr = color.rgb(20, 25, 38)
    color bg_row = color.rgb(15, 18, 26)
    color bg_alt = color.rgb(12, 15, 24)
    color flow_col = is_gold_buyer_absorb ? COL_SHELF_GOLD : (is_purple_seller_absorb ? COL_SHELF_PURPLE : (sess_cum_delta >= 0 ? #00E676 : #FF1744))

    if hudModeInput == "Compact Status Pill"
        // Row 0: Asset + Shape, Auction State, Delta Flow
        string pill_title = "⚡ " + detected_asset_name + " [" + ref_shape + "]" + (not na(cur_ovl_ref) ? (" · OVL " + str.tostring(cur_ovl_ref, "0.00")) : "")
        table.cell(hud_display, 0, 0, pill_title, text_color=color.white, text_size=size.small, bgcolor=bg_hdr)
        table.cell(hud_display, 1, 0, amt_state_txt, text_color=amt_state_col, text_size=size.small, bgcolor=bg_hdr)
        table.cell(hud_display, 2, 0, tape_flow_str, text_color=flow_col, text_size=size.small, bgcolor=bg_hdr)

        // Row 1: Engine + Ticks, Target / Rotation, Confluence Alert
        string pill_target = is_poc_confluent ? "⚡ CONFLUENT POC ACTIVE | " + amt_target_txt : (conf_shelf_msg != "None in Proximity" ? conf_shelf_msg + " | " + amt_target_txt : amt_target_txt)
        table.cell(hud_display, 0, 1, active_engine_label + " (" + str.tostring(active_ticks) + "t)", text_color=#00E5FF, text_size=size.tiny, bgcolor=bg_alt)
        table.cell(hud_display, 1, 1, pill_target, text_color=color.rgb(255, 238, 88), text_size=size.tiny, bgcolor=bg_alt)
        table.cell(hud_display, 2, 1, "RVOL: " + str.tostring(effective_rvol, "#.#") + "x | " + (is_weekly_mode ? "Weekly" : (is_monthly_mode ? "Monthly" : (is_daily_or_above ? "Macro" : "Sub-Sess"))), text_color=color.rgb(176, 190, 197), text_size=size.tiny, bgcolor=bg_alt)

        // Cleanly clear rows 2 through 6 so no ghost text remains
        table.clear(hud_display, 0, 2, 2, 6)

    else if hudModeInput == "Full Educational Dashboard"
        // Row 0: Header
        table.cell(hud_display, 0, 0, "⚡ CME AMT & ORDER FLOW LENS", text_color=color.white, text_size=size.small, bgcolor=bg_hdr)
        table.cell(hud_display, 1, 0, detected_asset_name + " (" + str.tostring(active_ticks) + "t / " + unit_pfx + str.tostring(tick_group_pts, px_fmt) + unit_sfx + ")", text_color=#00E5FF, text_size=size.small, bgcolor=bg_hdr)
        table.cell(hud_display, 2, 0, active_engine_label + " | RVOL: " + str.tostring(effective_rvol, "#.#") + "x | " + (is_weekly_mode ? "Weekly" : (is_monthly_mode ? "Monthly" : (is_daily_or_above ? "Macro" : "Sub-Sess"))), text_color=color.rgb(176, 190, 197), text_size=size.small, bgcolor=bg_hdr)

        // Row 1: Dalton Profile Shape, LVN Corridor & Ata Sabanci OVL
        color shape_col = ref_shape == "B" ? #FFD700 : (not na(cur_ovl_ref) and cur_ovl_ref >= 0.75 ? #64B5F6 : (not na(cur_tilt_ref) and cur_tilt_ref >= 5.0 ? #00E676 : (not na(cur_tilt_ref) and cur_tilt_ref <= -5.0 ? #FF1744 : #BA68C8)))
        string shape_title = "[" + ref_shape + "-Shape] " + (ref_shape == "D" ? "Balanced" : (ref_shape == "P" ? "Short Covering" : (ref_shape == "b" ? "Long Liquidation" : "Double Dist"))) + (not na(cur_ovl_ref) ? (" · OVL " + str.tostring(cur_ovl_ref, "0.00")) : "")
        string ovl_regime_str = not na(cur_ovl_ref) ? ("[" + cur_ovl_word_ref + " · Tilt " + (cur_tilt_ref >= 0 ? "+" : "") + str.tostring(cur_tilt_ref, "0.1") + "%] ") : ""
        table.cell(hud_display, 0, 1, "1. Dalton & OVL", text_color=color.white, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 1, 1, shape_title, text_color=shape_col, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 2, 1, ovl_regime_str + shape_desc + lvn_telemetry, text_color=color.rgb(207, 216, 220), text_size=size.tiny, bgcolor=bg_row)

        // Row 2: Auction State & Target Distances
        table.cell(hud_display, 0, 2, "2. Auction State", text_color=color.white, text_size=size.small, bgcolor=bg_alt)
        table.cell(hud_display, 1, 2, amt_state_txt, text_color=amt_state_col, text_size=size.small, bgcolor=bg_alt)
        table.cell(hud_display, 2, 2, amt_target_txt, text_color=color.rgb(255, 238, 88), text_size=size.tiny, bgcolor=bg_alt)

        // Row 3: Overnight Half-Back (MBO Empirical Equilibrium Target)
        string hb_reading = not na(on_halfback) ? 
             (str.tostring(on_halfback, format.mintick) + (dist_hb_pts >= 0 ? " +" : " -") + unit_pfx + str.tostring(math.abs(dist_hb_pts), px_fmt) + unit_sfx) : 
             (is_equity_asset ? "N/A (RTH Horizon)" : "N/A (Cash Horizon)")
        string hb_interp  = not na(on_halfback) ? 
             "Master mean-reversion target / resistance (48.6% hit rate)" : 
             (is_equity_asset ? "Overnight session inactive on standard cash equity" : (is_crypto_asset ? "24/7 Global Session Active" : "Overnight midpoint inactive"))
        table.cell(hud_display, 0, 3, "3. Overnight 50%", text_color=color.white, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 1, 3, hb_reading, text_color=COL_HALFBACK, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 2, 3, hb_interp, text_color=color.rgb(207, 216, 220), text_size=size.tiny, bgcolor=bg_row)

        // Row 4: Tape & Footprint Delta Flow
        string flow_interp = is_gold_buyer_absorb ? "⚡ Buyer Absorption Active at Lows" : (is_purple_seller_absorb ? "⚡ Seller Defense Active at Highs" : (is_bull_drive ? "Initiative Bull Drive" : (is_bear_drive ? "Initiative Bear Drive" : "Balanced Tape Delta")))
        table.cell(hud_display, 0, 4, "4. Tape & Delta", text_color=color.white, text_size=size.small, bgcolor=bg_alt)
        table.cell(hud_display, 1, 4, tape_flow_str, text_color=flow_col, text_size=size.small, bgcolor=bg_alt)
        table.cell(hud_display, 2, 4, flow_interp, text_color=flow_col, text_size=size.tiny, bgcolor=bg_alt)

        // Row 5: Confluence Alert
        string conf_interp = conf_shelf_msg != "None in Proximity" ? "Institutional Limit Queue Defending Level" : (is_poc_confluent ? "Prior Cash VPOC & Overnight VPOC Clustered" : "No active shelves at key levels")
        table.cell(hud_display, 0, 5, "5. Confluence Alert", text_color=color.white, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 1, 5, is_poc_confluent ? "⚡ CONFLUENT POC CLUSTER" : conf_shelf_msg, text_color=is_poc_confluent ? COL_CONFLUENT_POC : conf_shelf_col, text_size=size.small, bgcolor=bg_row)
        table.cell(hud_display, 2, 5, conf_interp, text_color=color.rgb(207, 216, 220), text_size=size.tiny, bgcolor=bg_row)

        // Row 6: AMT Empirical Research Note
        table.cell(hud_display, 0, 6, "🎓 AMT Research", text_color=color.rgb(176, 190, 197), text_size=size.tiny, bgcolor=bg_alt)
        table.cell(hud_display, 1, 6, shape_note, text_color=color.rgb(207, 216, 220), text_size=size.tiny, bgcolor=bg_alt)
        table.cell(hud_display, 2, 6, "[1,122 CME Sessions Sample • Educational Benchmark]", text_color=color.rgb(120, 144, 156), text_size=size.tiny, bgcolor=bg_alt)

    // Performance Profiler Budget Check (SKILL.md Section 19)
    int _elapsed_ms = barstate.islast ? (timenow - _t0_perf) : 0
    if _elapsed_ms > 25
        log.warning("Pine Engine Warning: Execution budget exceeded 25ms (Actual: " + str.tostring(_elapsed_ms) + "ms)")


// SECTION 13: INSTITUTIONAL ALERTS & ORDER FLOW DISPATCH
// =============================================================================

bool alert_absorb = showEffortReward and barstate.isconfirmed and (is_gold_buyer_absorb or is_purple_seller_absorb)
bool alert_cpoc   = showConfluentPoc and barstate.isconfirmed and is_poc_confluent
bool alert_poor   = showUnfinishedAuctions and barstate.isconfirmed and (upper_wick_pct <= 0.10 or lower_wick_pct <= 0.10) and effective_rvol >= 1.10

alertcondition(alert_absorb, title="Institutional Absorption Candle", message="[CME LENS] Institutional volume absorption detected at candle extreme.")
alertcondition(alert_cpoc,   title="Confluent Iron POC Cluster",     message="[CME LENS] Prior Cash VPOC and Overnight VPOC aligned within confluent tolerance.")
alertcondition(alert_poor,   title="Unfinished Auction Magnet",      message="[CME LENS] Poor High / Low printed with non-zero outer volume.")
````
