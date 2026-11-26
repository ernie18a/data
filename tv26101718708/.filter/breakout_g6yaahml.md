# Breakout

- url: https://www.tradingview.com/script/G6YAAhmL-Breakout/
- type: indicator
- pine_id: PUB;dad7ed443c854020993702b7dec227fb
- version: 11.0

## Description

Breakout is an overlay indicator for identifying pre-breakout trade context using supply/demand zones, higher-timeframe alignment, moving-average structure, and confluence scoring.

This script is for analysis and planning only. It does not place orders or guarantee results.

What it does

Breakout helps visualize potential long and short setups before price breaks out of a key zone. It combines:

- Key magnet supply/demand zones (strongest reaction levels only)
- HTF trade zones auto-anchored by chart timeframe
- Pre-trade setup boxes with entry, stop, and target
- Diamond markers for high-confluence turning points
- Liquidity levels for potential sweep/SFP context
- Optional info panel with bias, levels, and active setup details

How it works

Magnet zones: pivot highs/lows cluster into levels. Levels price revisits gain strength. Only the strongest are drawn.

HTF trade regime: each chart timeframe uses two higher anchor timeframes. Long ideas can be filtered to HTF demand zones; shorts to HTF supply zones. Zones use confirmed HTF swing highs/lows with ATR-based width and reach.

Setup engine: setups form when zone context, trend/MA structure, confidence score, and cooldown align. Stops use risk percent, MA support/resistance, swing levels, and a max distance cap. Targets use a configurable minimum risk/reward.

Diamond signals: require structure (SFP, reversal, or MA setup), zone context, and supporting momentum/trend. Optional volume spike and RSI divergence add confluence. Not every pivot prints a diamond.

Volume and divergence: abnormal volume spikes (relative volume and z-score) can combine with RSI divergence in diamonds and setup scoring.

MTF data uses request.security() with barmerge.lookahead_off to avoid lookahead on higher-timeframe context.

How to use

1. Add Breakout to your chart.
2. Choose your execution timeframe.
3. Keep HTF zone filter on for higher-timeframe alignment.
4. Wait for price at HTF zone plus key magnet zone, then diamond or setup box with confidence at or above Min Confidence.
5. Use entry, stop, and target from the active setup box for planning.
6. Manage risk with your own rules.

Main settings

- Risk: risk per trade, min R/R, max hold bars
- Filters: min confidence, approach distance, cooldown, volume, vol spike and divergence
- HTF zones: trade inside HTF S/D only, auto anchors, zone width and reach
- Display: zones, setups, liquidity, labels, info panel, EMAs, diamond spacing

Alerts

- Breakout Long Setup
- Breakout Short Setup
- Breakout Approaching Demand
- Breakout Approaching Supply

Alerts reflect script conditions at alert time. They are not trade recommendations.

Disclaimer

Educational and informational use only. Not financial advice. Trading involves risk, including loss of capital. Past results do not guarantee future performance. Use at your own discretion.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// BREAKOUT — TradingView Pine Script v6
// 
// Purpose: Dynamic S/D magnets + OB-boosted zone ranking, HTF confluence,
//          liquidity pools (SSL/BSL boxes + DRAW), regime/vector candles, ultimate flip markers
// 
// Version: 6.7.0
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Breakout v6.7", shorttitle="Breakout", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1: INPUTS & CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Zone & Confluence Filters ─────────────────────────────────────────────────
group_conf = "Zone & Confluence"
approachInput = input.float(2.0, "Zone Approach Distance (%)", minval=0.5, maxval=10.0, step=0.25, group=group_conf)
adaptiveApproach = input.bool(true, "Adapt Approach Distance to Volatility (ATR)", group=group_conf)
useVolumeConf = input.bool(true, "Use Volume Confirmation", group=group_conf)
volLookback = input.int(20, "Volume Lookback", minval=10, maxval=50, group=group_conf)
volThreshold = input.float(1.3, "Volume Threshold (x Avg)", minval=1.0, maxval=3.0, step=0.1, group=group_conf)
useVolDivConfluence = input.bool(true, "Cross-Ref Volume Spikes + Divergence", group=group_conf)
volSpikeMult = input.float(2.2, "Abnormal Volume Spike (x Avg)", minval=1.5, maxval=6.0, step=0.1, group=group_conf)
volSpikeZ = input.float(2.0, "Volume Spike Z-Score", minval=1.0, maxval=4.0, step=0.25, group=group_conf)

// ─── Session Times (UTC) ───────────────────────────────────────────────────────
group_session = "Session Times (UTC)"
londonStart = input.int(8, "London Start", minval=0, maxval=23, group=group_session)
londonEnd = input.int(16, "London End", minval=0, maxval=23, group=group_session)
nyStart = input.int(14, "NY Start", minval=0, maxval=23, group=group_session)
nyEnd = input.int(22, "NY End", minval=0, maxval=23, group=group_session)

// ─── Multi-Timeframe Settings ──────────────────────────────────────────────────
group_mtf = "Multi-Timeframe Confluence"
useMTF = input.bool(true, "Use MTF Confluence", group=group_mtf)
mtfHigher = input.timeframe("15", "Higher Timeframe", group=group_mtf)
mtfTrendLookback = input.int(50, "Trend Lookback (Higher TF bars)", minval=20, maxval=200, group=group_mtf)

// ─── HTF Trade Zones (per-TF trade regime) ──────────────────────────────────────
// Anchor every chart's trades to higher-timeframe supply/demand zones so signals
// line up across timeframes (e.g. a 5m long only inside a 1H/4H demand zone).
group_htfz = "HTF S/D Zones"
htfZoneAuto = input.bool(true, "Auto-Pick HTF Anchors by Chart TF", group=group_htfz)
htfZone1Manual = input.timeframe("60", "HTF Zone 1 (manual)", group=group_htfz)
htfZone2Manual = input.timeframe("240", "HTF Zone 2 (manual)", group=group_htfz)
htfZoneBufferMult = input.float(0.20, "HTF Zone Width (x HTF ATR)", minval=0.05, maxval=2.0, step=0.05, group=group_htfz)
htfZoneApproachMult = input.float(0.35, "HTF Zone Approach (x HTF ATR)", minval=0.0, maxval=3.0, step=0.05, group=group_htfz)
htfTradeReachMult = input.float(0.85, "HTF Trade Reach (x HTF ATR)", minval=0.1, maxval=3.0, step=0.05, group=group_htfz)
showHtfZones = input.bool(true, "Draw HTF Zones", group=group_htfz)
htfHideNearKey = input.bool(true, "Hide HTF Zone When Key Magnet Overlaps", group=group_htfz)
showHtfLead = input.bool(true, "HTF LEAD Glow (next magnet box)", tooltip="Highlights the HTF zone price is most likely to trade into next — trade back up/down into that box.", group=group_htfz)

// ─── Display Settings ──────────────────────────────────────────────────────────
group_disp = "Display"
showZones = input.bool(true, "Show Key S/D Zones (magnets only)", group=group_disp)
showLiquidity = input.bool(false, "Show Liquidity / Future SFP Levels", group=group_disp)
showLabels = input.bool(false, "Show Zone Strength Labels", group=group_disp)
showInfoPanel = input.bool(false, "Show Info Panel (table)", group=group_disp)
showEMAs = input.bool(false, "Show Moving Averages", group=group_disp)
maxZonesPerSide = input.int(2, "Max Zones Per Side (above/below)", minval=1, maxval=6, group=group_disp)
minZoneStrength = input.int(3, "Min Zone Strength (reactions)", minval=2, maxval=6, group=group_disp)
zoneClusterMult = input.float(1.25, "Zone Cluster Width (xATR)", minval=0.3, maxval=2.5, step=0.05, group=group_disp)
zoneStackMinMult = input.float(1.5, "Min Zone Spacing (xATR, anti-stack)", minval=0.5, maxval=4.0, step=0.1, group=group_disp)
liqTolMult = input.float(0.15, "Liquidity Equal-Level Tolerance (xATR)", minval=0.02, maxval=0.5, step=0.01, group=group_disp)
zoneLookback = input.int(50, "Zone Lookback Bars", minval=20, maxval=300, group=group_disp)
stickyZones = input.bool(true, "Sticky Zones (hold until taken out)", tooltip="Once drawn, a zone stays locked until price CLOSES through it. Won't flicker on 1m. Zones price is inside always stay visible.", group=group_disp)
alertZoneFlip = input.bool(false, "Alert On Zone Flip", group=group_disp)
showPreviousZones = input.bool(false, "Show Previous Calendar Zones (D/W/M/Q)", group=group_disp)

// ─── Signal Settings ───────────────────────────────────────────────────────────
group_signals = "Signals"
showReversalDiamonds = input.bool(false, "Show Reversal Diamonds", group=group_signals)
showBullReversalDiamond = input.bool(false, "Show Bull Reversal Diamond", group=group_signals)
showBearReversalDiamond = input.bool(false, "Show Bear Reversal Diamond", group=group_signals)
bullSignalColor = input.color(#FFFFFF, "Bull Reversal Diamond Color", group=group_signals)
bearSignalColor = input.color(#BF00FF, "Bear Reversal Diamond Color", group=group_signals)
// ─── Zone Colors ────────────────────────────────────────────────────────────────
group_colors = "🎨 Zone Colors"
useCustomZoneColors = input.bool(false, "Use Custom Zone Colors (off = SRUS defaults)", group=group_colors)
demandColor = input.color(#16C784, "Demand Zone", group=group_colors)
supplyColor = input.color(#9C27B0, "Supply Zone", group=group_colors)
demandFlippedColor = input.color(#5C8A74, "Flipped → Demand", group=group_colors)
supplyFlippedColor = input.color(#6D4C77, "Flipped → Supply", group=group_colors)
htfDemandColor = input.color(#00BCD4, "HTF Demand Zone", group=group_colors)
htfSupplyColor = input.color(#FF9800, "HTF Supply Zone", group=group_colors)

// Resolved colors: pickers when custom mode is on, hardcoded SRUS brand defaults when off.
demandBase    = useCustomZoneColors ? demandColor        : #16C784
supplyBase    = useCustomZoneColors ? supplyColor        : #9C27B0
demandFlip    = useCustomZoneColors ? demandFlippedColor : #5C8A74
supplyFlip    = useCustomZoneColors ? supplyFlippedColor : #6D4C77
htfDemandBase = useCustomZoneColors ? htfDemandColor     : #00BCD4
htfSupplyBase = useCustomZoneColors ? htfSupplyColor     : #FF9800

// ─── Zone Upgrades ─────────────────────────────────────────────────────────────
group_zup = "Zone Upgrades"
showMajorGlow = input.bool(true, "Major Zone Emphasis (x5 + HTF stacked)", group=group_zup)
showTargetLabel = input.bool(false, "Show Target Zone Label (legacy)", group=group_zup)
showZoneDistancePct = input.bool(true, "Show % Distance On Zones", tooltip="Folded into LEAD / HTF / DRAW tags only — no floating % spam.", group=group_zup)
showReversalZoneFill = input.bool(true, "Major Zone Reversal Shade (bull demand / bear supply)", tooltip="Major demand = bullish reversal tint. Major supply = bearish reversal tint. Kept light so candles stay readable.", group=group_zup)
majorZoneColor = input.color(#FFD700, "Major Zone Border (gold)", group=group_zup)
useObZoneBoost = input.bool(true, "Order-Block Boost On Key Magnets", tooltip="Scores existing S/D magnets higher when they overlap a displacement order block. Does not draw separate OB boxes or change zone colors.", group=group_zup)
obDisplaceMult = input.float(1.6, "OB Displacement (xATR)", minval=0.8, maxval=4.0, step=0.1, group=group_zup)
obBodyOverlapMult = input.float(0.35, "OB Match Tolerance (xATR)", minval=0.1, maxval=1.5, step=0.05, group=group_zup)
showObZoneTag = input.bool(false, "Tag OB-Boosted Zones (text only)", tooltip="Optional · OB text on labels. Zone colors stay demand/supply defaults.", group=group_zup)

// ─── Calendar S/D Zones (Daily / Weekly / MTD / YTD) ───────────────────────────
group_cal = "Calendar S/D Zones"
showCalDaily = input.bool(false, "Daily S/D (prev session)", group=group_cal)
showCalWeekly = input.bool(false, "Weekly S/D (prev week)", group=group_cal)
showCalMTD = input.bool(false, "Monthly S/D (prev month)", group=group_cal)
showCalYTD = input.bool(false, "Yearly S/D (prev year)", group=group_cal)
showCalQuarterly = input.bool(false, "Quarterly S/D (prev quarter)", group=group_cal)
showPrevCalDaily = input.bool(false, "Show Previous Daily Zones", group=group_cal)
showPrevCalWeekly = input.bool(false, "Show Previous Weekly Zones", group=group_cal)
showPrevCalMTD = input.bool(false, "Show Previous Monthly Zones", group=group_cal)
showPrevCalQuarterly = input.bool(false, "Show Previous Quarterly Zones", group=group_cal)
calZoneBandMult = input.float(0.15, "Calendar Zone Width (x Daily ATR)", minval=0.05, maxval=1.0, step=0.05, group=group_cal)
calZoneStyle = input.string("Outline Only", "Calendar Zone Style", options=["Faint Boxes", "Outline Only", "Dotted Line"], group=group_cal)
calZoneBorderStyle = input.string("Dotted", "Calendar Border Style", options=["Solid", "Dashed", "Dotted"], group=group_cal)
calZoneFillTransp = input.int(90, "Calendar Fill Transparency", minval=70, maxval=100, step=1, group=group_cal)
calZoneLineWidth = input.int(2, "Calendar Line Width", minval=1, maxval=3, group=group_cal)
calZoneLookback = input.int(120, "Calendar Zone Bars Back", minval=30, maxval=500, group=group_cal)
calZoneSmart = input.bool(true, "Smart Fade: Dim Calendar Zones Far From Price", group=group_cal)
calZoneNearPct = input.float(1.0, "Smart Fade Near-Price %", minval=0.2, maxval=5.0, step=0.1, group=group_cal)
showCalLabels = input.bool(false, "Show Calendar Zone Labels", group=group_cal)
colorCalDaily = input.color(#00FF00, "Daily Color", group=group_cal)
colorCalWeekly = input.color(#FFA500, "Weekly Color", group=group_cal)
colorCalMTD = input.color(#CC00FF, "MTD Color", group=group_cal)
colorCalYTD = input.color(#FFFFFF, "YTD Color", group=group_cal)
colorCalQuarterly = input.color(#FF0000, "Quarterly Color", group=group_cal)

// ─── Regime Coloring (zone-aware trend persistence) ─────────────────────────────
group_regime = "Regime Coloring"
showRegimeCandles = input.bool(true, "Color Candles by Regime", tooltip="Candles stay bull/bear color until the regime flips.", group=group_regime)
showConvictionTiers = input.bool(true, "Vivid Regime Candles", tooltip="On = solid trend color. Off = softer tint. Color still holds for the full regime.", group=group_regime)
showSessionShading = input.bool(false, "Show Session Shading", group=group_regime)
showRegimeCloud = input.bool(false, "Show Regime Ribbon Cloud", group=group_regime)
showRegimeLabels = input.bool(false, "Show Regime Flip Marks (×)", group=group_regime)
showRegimeVolume = input.bool(false, "Show Regime Volume Histogram", group=group_regime)
regimeBullColor = input.color(#16C784, "Bull Regime Color (green)", group=group_regime)
regimeBearColor = input.color(#BF00FF, "Bear Regime Color (Sniper purple)", group=group_regime)
regimeReversalColor = input.color(#FFFFFF, "Major Reversal Candle (optional white)", group=group_regime)
colorMajorRevWhite = input.bool(false, "Paint Major Reversal Candles White", tooltip="Off = keep trend color; ultimate top/bottom still override.", group=group_regime)
showLiqSweepMarks = input.bool(false, "Show Liq Sweep Proxy Marks", tooltip="Optional. Diamonds mark major reversals.", group=group_regime)
minMajorReversalScore = input.int(5, "Major Reversal Threshold", minval=3, maxval=8, group=group_regime)
showUltFlipCandles = input.bool(true, "Ultimate Top / Bottom (× on candles)", tooltip="Climax rejection at key magnets. Paints the candle via regime overlay and marks with × (no labels).", group=group_regime)
ultTopColor = input.color(#FF1744, "Ultimate Top Color (bearish red)", group=group_regime)
ultBotColor = input.color(#FFFFFF, "Ultimate Bottom Color (bullish white)", group=group_regime)
minRegimeFlipScore = input.int(2, "Regime Flip Min Confluence", minval=1, maxval=4, group=group_regime)

// ─── Vector Candles (PVSRA) ───────────────────────────────────────────────────
group_vector = "Vector Candles (PVSRA)"
showVectorCandles = input.bool(true, "Show Vector Candles on Chart", tooltip="Colors vector/climax candles: Lime (Bull Climax), Red (Bear Climax), Cyan (Bull Active), Magenta (Bear Active). Normal candles keep regime trend colors.", group=group_vector)
vectorLookback = input.int(10, "Vector Volume Lookback", minval=5, maxval=50, group=group_vector)
vectorClimaxMult = input.float(2.0, "Climax Volume Multiplier (x Avg)", minval=1.2, maxval=3.0, step=0.1, group=group_vector)
vectorActiveMult = input.float(1.5, "Active Volume Multiplier (x Avg)", minval=1.0, maxval=2.5, step=0.1, group=group_vector)
useVectorInReversals = input.bool(true, "Integrate Vector Candles into Reversals", tooltip="Uses climax and active vector candles at key S/D magnets to score more accurate reversal points.", group=group_vector)
vectorClimaxBullCol = input.color(#00FF00, "Bull Climax Color (Lime)", group=group_vector)
vectorClimaxBearCol = input.color(#FF0000, "Bear Climax Color (Red)", group=group_vector)
vectorActiveBullCol = input.color(#00E5FF, "Bull Active Color (Cyan)", group=group_vector)
vectorActiveBearCol = input.color(#D500F9, "Bear Active Color (Magenta)", group=group_vector)

// ─── Liquidity Magnet (pools → DRAW + zone boost; no rail farm) ───────────────
group_liq = "Liquidity Magnet"
useLiqMagnet = input.bool(true, "Enable Liquidity Magnet Engine", tooltip="Ranks BSL/SSL pools (equal swings + sweep events). Feeds zone LEAD scoring, DRAW path, and optional pool boxes/labels.", group=group_liq)
liqMode = input.string("Scalp", "Liq Mode Preset", options=["Scalp", "Swing", "Custom"], group=group_liq)
boostZonesWithLiq = input.bool(true, "Boost S/D Boxes Near Untapped Liq", tooltip="When a Breakout magnet sits on untapped BSL/SSL, it scores higher as LEAD and tags · LIQ.", group=group_liq)
showLiqDraw = input.bool(false, "Show DRAW Liq Target (tag)", tooltip="Orange DRAW tab on the next BSL/SSL magnet. Off by default — Breakout S/D zones stay the main overlay.", group=group_liq)
showLiqPoolZones = input.bool(false, "Show Liq Boxes", tooltip="Toggle key SSL/BSL liquidity boxes. Off by default so only Breakout S/D zones show.", group=group_liq)
showLiqPoolLabels = input.bool(false, "Show Liq Labels", tooltip="Score tabs on key pools. Off by default.", group=group_liq)
liqBoxMinScore = input.float(40.0, "Min Score for Key Liq", minval=20, maxval=90, step=5, tooltip="Pool must clear this magnet score to be eligible.", group=group_liq)
liqBoxMaxPerSide = input.int(2, "Key Liq Per Side", minval=1, maxval=3, tooltip="1 = nearest only. 2 = nearest + strongest (catches higher far BSL/SSL like Liq Hunter).", group=group_liq)
liqZoneOpacity = input.int(90, "Liq Pool Box Transparency", minval=70, maxval=98, tooltip="Higher = more translucent fill. Background still paints.", group=group_liq)
liqBuyColor = input.color(#14B8A6, "Buy-Side Liq (BSL / teal)", group=group_liq)
liqSellColor = input.color(#F43F5E, "Sell-Side Liq (SSL / rose)", group=group_liq)
liqTakenColor = input.color(#64748B, "Taken Liq Color", group=group_liq)
useLiqInReversals = input.bool(true, "Use Sweep-Reclaim in Reversal Scores", group=group_liq)
showLiqReclaimMarks = input.bool(false, "Show Sweep-Reclaim Flags", tooltip="Off by default. Engine still scores reclaim when enabled above.", group=group_liq)
liqDrawColor = input.color(#F59E0B, "LEAD Liquidity Color", group=group_liq)
liqMinImpact = input.float(55.0, "Min Reclaim Impact", minval=30, maxval=90, step=5, group=group_liq)
liqCoolBars = input.int(10, "Reclaim Cooldown (bars)", minval=3, maxval=40, group=group_liq)

// ─── Trade Visualizer ──────────────────────────────────────────────────────────
group_trade = "Trade Visualizer"
showTradeVisualizer     = input.bool(false, "Show Active Trade Visualizer", group=group_trade)
showTradeHistory        = input.bool(false, "Show Completed Trade History", group=group_trade)
showTrendBanner         = input.bool(false, "Show Trend Banner", group=group_trade)
showTrendBg             = input.bool(false, "Color Background by Trend", group=group_trade)
showTrendLine           = input.bool(false, "Show Trend-Colored Price Line", group=group_trade)
tradeRiskReward         = input.float(2.0, "R:R Target", minval=1.0, maxval=5.0, step=0.25, group=group_trade)
tradeStopType           = input.string("ATR", "Stop Loss Type", options=["Swing", "ATR"], group=group_trade)
tradeSwingLookback      = input.int(3, "Swing Lookback (bars)", minval=1, maxval=10, group=group_trade)
tradeStopAtrMult        = input.float(1.5, "SL ATR Multiplier", minval=0.5, maxval=4.0, step=0.25, group=group_trade)

// ─── Conviction Meter (ADX + DMI + price structure) ─────────────────────────────
group_trend = "Conviction Meter"
useAdxTrendFilter = input.bool(true, "Use ADX Trend Filter", group=group_trend)
adxLength = input.int(14, "ADX Length", minval=5, maxval=50, group=group_trend)
adxStrongThreshold = input.int(25, "Strong Trend ADX Threshold", minval=10, maxval=50, group=group_trend)
trendRequirePriceStructure = input.bool(true, "Require Price Structure (HH/HL or LH/LL)", group=group_trend)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2: SESSION VALIDATION
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Session Check (UTC) ───────────────────────────────────────────────────────
currentHour = hour(time, "UTC")
inLondon = currentHour >= londonStart and currentHour < londonEnd
inNY = currentHour >= nyStart and currentHour < nyEnd
inSession = inLondon or inNY

sessionName = inLondon ? "LONDON" : inNY ? "NY" : "CLOSED"

// Drawing objects never extend more than this many bars into the future (prevents autoscale zoom-out).
zoneDrawAhead = 5

// Label lanes — keep key / HTF / LEAD LIQ tags in separate columns.
lblLaneKey  = 4    // LEAD · MAJOR on Breakout magnets
lblLaneHtf  = 18   // HTF zone tags
lblLaneLiq  = 28   // LEAD LIQ target
lblLanePool = 40   // SSL/BSL score tabs (old LiqMagnet rail)

f_pctAway(float lvl) =>
    math.abs(lvl - close) / close * 100.0

f_pctAwayText(float lvl) =>
    str.tostring(f_pctAway(lvl), "#.#") + "%"

// Signed % like old LiqMagnet tabs (e.g. -0.46% / +0.56%).
f_pctAwaySigned(float lvl) =>
    p = close != 0 ? (lvl - close) / close * 100.0 : 0.0
    (p >= 0 ? "+" : "") + str.tostring(p, "#.##") + "%"

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3: MULTI-TIMEFRAME ANALYSIS (NON-REPAINTING)
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Higher Timeframe Data (NO LOOKAHEAD - fixes repainting) ──────────────────
chartTfSec = timeframe.in_seconds(timeframe.period)
mtfInputSec = timeframe.in_seconds(mtfHigher)
htfTf = mtfInputSec > chartTfSec ? mtfHigher : timeframe.period

// Use barmerge.lookahead_off to prevent repainting
htfClose = request.security(syminfo.tickerid, htfTf, close, lookahead=barmerge.lookahead_off)
htfHigh = request.security(syminfo.tickerid, htfTf, high, lookahead=barmerge.lookahead_off)
htfLow = request.security(syminfo.tickerid, htfTf, low, lookahead=barmerge.lookahead_off)
htfOpen = request.security(syminfo.tickerid, htfTf, open, lookahead=barmerge.lookahead_off)

// ─── Higher Timeframe Trend ────────────────────────────────────────────────────
htfEMA20 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
htfEMA50 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfEMA200 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 200), lookahead=barmerge.lookahead_off)

htfBullish = htfEMA20 > htfEMA50 and htfEMA50 > htfEMA200 and htfClose > htfEMA20
htfBearish = htfEMA20 < htfEMA50 and htfEMA50 < htfEMA200 and htfClose < htfEMA20
htfTrendAligned = htfBullish or htfBearish

// ─── Higher Timeframe Structure ────────────────────────────────────────────────
htfSwingHigh = request.security(syminfo.tickerid, htfTf, ta.pivothigh(high, 5, 5), lookahead=barmerge.lookahead_off)
htfSwingLow = request.security(syminfo.tickerid, htfTf, ta.pivotlow(low, 5, 5), lookahead=barmerge.lookahead_off)

// ─── HTF Trade Zone Anchors (per-TF regime) ────────────────────────────────────
// Auto-pick two higher anchors relative to the chart TF so each timeframe gets its
// own zone regime (5m → 1H/4H, 1H → 4H/1D, 4H → 1D/1W, etc.).
zoneTf1 = htfZoneAuto ? (chartTfSec <= 300 ? "60" : chartTfSec <= 900 ? "240" : chartTfSec <= 3600 ? "240" : chartTfSec <= 14400 ? "D" : "W") : htfZone1Manual
zoneTf2 = htfZoneAuto ? (chartTfSec <= 300 ? "240" : chartTfSec <= 900 ? "D" : chartTfSec <= 3600 ? "D" : chartTfSec <= 14400 ? "W" : "M") : htfZone2Manual

// Returns the most recent CONFIRMED swing high/low (held forward) + ATR on that TF.
f_htfZone() =>
    ph = ta.pivothigh(high, 5, 5)
    pl = ta.pivotlow(low, 5, 5)
    var float heldHigh = na
    var float heldLow = na
    if not na(ph)
        heldHigh := ph
    if not na(pl)
        heldLow := pl
    [heldHigh, heldLow, ta.atr(14)]

[z1High, z1Low, z1Atr] = request.security(syminfo.tickerid, zoneTf1, f_htfZone(), lookahead=barmerge.lookahead_off)
[z2High, z2Low, z2Atr] = request.security(syminfo.tickerid, zoneTf2, f_htfZone(), lookahead=barmerge.lookahead_off)

// Build demand (around swing low) / supply (around swing high) bands per anchor.
z1Band = nz(z1Atr) * htfZoneBufferMult
z2Band = nz(z2Atr) * htfZoneBufferMult
z1Reach = nz(z1Atr) * htfZoneApproachMult
z2Reach = nz(z2Atr) * htfZoneApproachMult
z1TradeReach = nz(z1Atr) * htfTradeReachMult
z2TradeReach = nz(z2Atr) * htfTradeReachMult

// Price is "in" a zone when the current candle overlaps the band; "near" adds reach.
inZ1Demand = not na(z1Low) and high >= (z1Low - z1Band - z1TradeReach) and low <= (z1Low + z1Band)
inZ1Supply = not na(z1High) and low <= (z1High + z1Band + z1TradeReach) and high >= (z1High - z1Band)
inZ2Demand = not na(z2Low) and high >= (z2Low - z2Band - z2TradeReach) and low <= (z2Low + z2Band)
inZ2Supply = not na(z2High) and low <= (z2High + z2Band + z2TradeReach) and high >= (z2High - z2Band)

inHtfDemandZone = inZ1Demand or inZ2Demand
inHtfSupplyZone = inZ1Supply or inZ2Supply
// Confluence is strongest when BOTH anchors agree on the same side.
htfDemandStacked = inZ1Demand and inZ2Demand
htfSupplyStacked = inZ1Supply and inZ2Supply

// ─── Draw HTF Zones (refreshed on last bar to stay clean) ──────────────────────
var box   hz1d = na
var box   hz1s = na
var box   hz2d = na
var box   hz2s = na
var label hz1dL = na
var label hz1sL = na
var label hz2dL = na
var label hz2sL = na
// Sticky HTF LEAD id: 1=z1D 2=z1S 3=z2D 4=z2S
var int htfLeadId = -1

f_drawHtfZone(box bx, label lb, float lvl, float band, bool isSup, int leftBar, string tag, bool isLead) =>
    box b = bx
    label l = lb
    if not na(lvl)
        fillColBase = isSup ? supplyBase : demandBase
        bcolBase = isSup ? htfSupplyBase : htfDemandBase
        // LEAD HTF box glows brighter so the magnet target is obvious; still thin border.
        col = color.new(fillColBase, isLead ? 72 : 88)
        bcol = isLead ? color.new(bcolBase, 0) : color.new(bcolBase, 25)
        brdW = isLead ? 2 : 1
        lblTxt = (isLead ? "LEAD · " : "") + tag + (showZoneDistancePct ? " · " + f_pctAwayText(lvl) : "")
        // Nudge non-LEAD HTF tags off the band center so they do not sit on key-zone labels.
        yLbl = isLead ? lvl : lvl + (isSup ? band * 0.35 : -band * 0.35)
        if na(b)
            b := box.new(leftBar, lvl + band, bar_index + 8, lvl - band, bgcolor=col, border_color=bcol, border_width=brdW)
            l := label.new(bar_index + lblLaneHtf, yLbl, lblTxt, color=color.new(color.gray, 100), textcolor=isLead ? color.white : bcolBase, style=label.style_label_left, size=size.tiny)
        else
            box.set_lefttop(b, leftBar, lvl + band)
            box.set_rightbottom(b, bar_index + 8, lvl - band)
            box.set_bgcolor(b, col)
            box.set_border_color(b, bcol)
            box.set_border_width(b, brdW)
            label.set_xy(l, bar_index + lblLaneHtf, yLbl)
            label.set_text(l, lblTxt)
            label.set_textcolor(l, isLead ? color.white : bcolBase)
    [b, l]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4: DYNAMIC SUPPLY/DEMAND ZONES
// ═══════════════════════════════════════════════════════════════════════════════

// ─── ATR & Volatility ──────────────────────────────────────────────────────────
atrLength = 14
atrValue = ta.atr(atrLength)
atrPrior = atrValue[10]
lowVolatility = atrValue < atrPrior

// Small vertical nudge so near-identical levels do not paint on top of each other.
f_labelYNudge(float lvl, int slot) =>
    lvl + (slot % 3 == 1 ? atrValue * 0.12 : slot % 3 == 2 ? -atrValue * 0.12 : 0.0)

// Zone draw tiers — see-through fills, but border brightness + rank show which magnet leads.
f_zoneFillTransp(int strn, int rank) =>
    // High transparency so zone fills never bury candles.
    base = strn >= 5 ? 82 : strn >= 4 ? 88 : 94
    math.min(97, base + rank * 4)

f_zoneHalfMult(int strn) =>
    // Slimmer bands — less bulk over price action.
    strn >= 5 ? 0.18 : strn >= 4 ? 0.14 : 0.11

f_zoneBorderNeon(bool isSup) =>
    isSup ? color.rgb(204, 0, 255) : color.rgb(0, 255, 136)

// Leading zone (rank 0) = brightest; each lower rank fades so strength order is obvious.
f_zoneRankBorderTransp(int strn, int rank) =>
    if rank == 0
        strn >= 5 ? 0 : strn >= 4 ? 5 : 20
    else
        base = strn >= 5 ? 5 : strn >= 4 ? 18 : 40
        math.min(70, base + rank * 14)

f_zoneCrossSpan(int strn, int rank) =>
    rank == 0 ? (strn >= 3 ? 4 : 3) : strn >= 3 ? 3 : 2

f_zoneCrossArmMult(int strn, int rank) =>
    rank == 0 ? (strn >= 3 ? 0.58 : 0.48) : strn >= 3 ? 0.42 : 0.32

f_zoneBorderColor(bool isSup, int strn, int rank) =>
    color.new(f_zoneBorderNeon(isSup), f_zoneRankBorderTransp(strn, rank))

// Vivid interior tint uses the user's demand/supply colors so reversal zones read green/purple at a glance.
f_zoneNeonColor(color baseCol, bool isSup, int strn) =>
    baseCol

// ─── Calendar S/D Zones (Daily / Weekly / Monthly / Quarterly / Yearly) ─────────────────────────
// Period high = supply band, period low = demand band (GPS-style calendar anchors).
// Daily/Weekly use the prior completed period; Monthly/Quarterly/Yearly use the prior completed
// period so the zones stay fixed for the whole current period instead of updating every day.

calAtr = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off)
calBand = nz(calAtr) * calZoneBandMult

calDHi = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
calDLo = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
calWHi = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
calWLo = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)
calMtdHi = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_off)
calMtdLo = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_off)
calQtdHi = request.security(syminfo.tickerid, "3M", high[1], lookahead=barmerge.lookahead_off)
calQtdLo = request.security(syminfo.tickerid, "3M", low[1], lookahead=barmerge.lookahead_off)
calYtdHi = request.security(syminfo.tickerid, "12M", high[1], lookahead=barmerge.lookahead_off)
calYtdLo = request.security(syminfo.tickerid, "12M", low[1], lookahead=barmerge.lookahead_off)

// Previous calendar-period zones (one full period before the current completed period).
prevDHi = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_off)
prevDLo = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_off)
prevWHi = request.security(syminfo.tickerid, "W", high[2], lookahead=barmerge.lookahead_off)
prevWLo = request.security(syminfo.tickerid, "W", low[2], lookahead=barmerge.lookahead_off)
prevMHi = request.security(syminfo.tickerid, "M", high[2], lookahead=barmerge.lookahead_off)
prevMLo = request.security(syminfo.tickerid, "M", low[2], lookahead=barmerge.lookahead_off)
prevQHi = request.security(syminfo.tickerid, "3M", high[2], lookahead=barmerge.lookahead_off)
prevQLo = request.security(syminfo.tickerid, "3M", low[2], lookahead=barmerge.lookahead_off)

var box   calDd = na
var box   calDs = na
var box   calWd = na
var box   calWs = na
var box   calMtdD = na
var box   calMtdS = na
var box   calYtdD = na
var box   calYtdS = na
var box   calQtdD = na
var box   calQtdS = na
var label calDdL = na
var label calDsL = na
var label calWdL = na
var label calWsL = na
var label calMtdDL = na
var label calMtdSL = na
var label calYtdDL = na
var label calYtdSL = na
var label calQtdDL = na
var label calQtdSL = na

f_drawCalSdZone(box bx, label lb, float lvl, float band, color periodCol, bool isSup, int leftBar, string tag, bool enabled) =>
    box b = bx
    label l = lb
    if not enabled
        if not na(b)
            box.delete(b)
            b := na
        if not na(l)
            label.delete(l)
            l := na
    else if not na(lvl) and band > 0
        // Map style inputs to Pine line styles.
        borderStyle = calZoneBorderStyle == "Dashed" ? line.style_dashed : calZoneBorderStyle == "Dotted" ? line.style_dotted : line.style_solid
        // Smart fade: full visibility when price is close, otherwise dim the calendar zone so it doesn't fight key zones.
        pct = f_pctAway(lvl)
        near = pct <= calZoneNearPct
        farFade = calZoneSmart and not near
        // Fill always uses demand/supply colors so bullish zones read green and bearish zones read purple.
        fillColBase = isSup ? supplyBase : demandBase
        fillTransp = calZoneStyle == "Outline Only" ? 100 : calZoneStyle == "Dotted Line" ? 100 : farFade ? math.min(100, calZoneFillTransp + 2) : calZoneFillTransp
        fillCol = color.new(fillColBase, fillTransp)
        brdTransp = farFade ? 40 : 0
        brdCol = color.new(periodCol, brdTransp)
        brdWidth = farFade ? 1 : calZoneLineWidth
        // Dotted line style forces a very light, single-line look.
        lineStyle = calZoneStyle == "Dotted Line" ? line.style_dotted : borderStyle
        lblBase = showCalLabels ? tag : ""
        lblPct = showZoneDistancePct ? f_pctAwayText(lvl) : ""
        lblTxt = lblBase != "" and lblPct != "" ? lblBase + " · " + lblPct : lblBase != "" ? lblBase : lblPct
        if na(b)
            b := box.new(leftBar, lvl + band, bar_index + 8, lvl - band, bgcolor=fillCol, border_color=brdCol, border_width=brdWidth, border_style=lineStyle)
            if lblTxt != ""
                l := label.new(bar_index + 8, lvl, lblTxt, color=color.new(color.gray, 100), textcolor=periodCol, style=label.style_label_left, size=size.tiny)
        else
            box.set_lefttop(b, leftBar, lvl + band)
            box.set_rightbottom(b, bar_index + 8, lvl - band)
            box.set_bgcolor(b, fillCol)
            box.set_border_color(b, brdCol)
            box.set_border_width(b, brdWidth)
            box.set_border_style(b, lineStyle)
            if lblTxt != ""
                if na(l)
                    l := label.new(bar_index + 8, lvl, lblTxt, color=color.new(color.gray, 100), textcolor=periodCol, style=label.style_label_left, size=size.tiny)
                else
                    label.set_xy(l, bar_index + 8, lvl)
                    label.set_text(l, lblTxt)
                    label.set_textcolor(l, periodCol)
            else if not na(l)
                label.delete(l)
                l := na
    [b, l]

// Muted, dashed previous calendar-period zones (D/W/M/Q) drawn behind live zones.
f_drawPrevCalZone(float lvl, float band, color periodCol, bool isSup, string tag, bool enabled, box[] boxes, label[] labels) =>
    if enabled and not na(lvl) and band > 0
        leftBar = bar_index - calZoneLookback
        fillCol = color.new(color.gray, 92)
        brdCol = color.new(periodCol, 55)
        bx = box.new(leftBar, lvl + band, bar_index + 8, lvl - band, bgcolor=fillCol, border_color=brdCol, border_width=1, border_style=line.style_dashed)
        array.push(boxes, bx)
        if showLabels or showCalLabels
            lbl = showZoneDistancePct ? tag + " · " + f_pctAwayText(lvl) : tag
            lb = label.new(bar_index + 8, lvl, lbl, color=color.new(color.gray, 100), textcolor=color.orange, style=label.style_label_left, size=size.tiny)
            array.push(labels, lb)

if barstate.islast
    calLeft = bar_index - calZoneLookback
    [b1, l1] = f_drawCalSdZone(calDd, calDdL, calDLo, calBand, colorCalDaily, false, calLeft, "D D", showCalDaily)
    calDd := b1
    calDdL := l1
    [b2, l2] = f_drawCalSdZone(calDs, calDsL, calDHi, calBand, colorCalDaily, true, calLeft, "D S", showCalDaily)
    calDs := b2
    calDsL := l2
    [b3, l3] = f_drawCalSdZone(calWd, calWdL, calWLo, calBand, colorCalWeekly, false, calLeft, "W D", showCalWeekly)
    calWd := b3
    calWdL := l3
    [b4, l4] = f_drawCalSdZone(calWs, calWsL, calWHi, calBand, colorCalWeekly, true, calLeft, "W S", showCalWeekly)
    calWs := b4
    calWsL := l4
    [b5, l5] = f_drawCalSdZone(calMtdD, calMtdDL, calMtdLo, calBand, colorCalMTD, false, calLeft, "MTD D", showCalMTD)
    calMtdD := b5
    calMtdDL := l5
    [b6, l6] = f_drawCalSdZone(calMtdS, calMtdSL, calMtdHi, calBand, colorCalMTD, true, calLeft, "MTD S", showCalMTD)
    calMtdS := b6
    calMtdSL := l6
    [b7, l7] = f_drawCalSdZone(calYtdD, calYtdDL, calYtdLo, calBand, colorCalYTD, false, calLeft, "YTD D", showCalYTD)
    calYtdD := b7
    calYtdDL := l7
    [b8, l8] = f_drawCalSdZone(calYtdS, calYtdSL, calYtdHi, calBand, colorCalYTD, true, calLeft, "YTD S", showCalYTD)
    calYtdS := b8
    calYtdSL := l8
    [b9, l9] = f_drawCalSdZone(calQtdD, calQtdDL, calQtdLo, calBand, colorCalQuarterly, false, calLeft, "QTD D", showCalQuarterly)
    calQtdD := b9
    calQtdDL := l9
    [b10, l10] = f_drawCalSdZone(calQtdS, calQtdSL, calQtdHi, calBand, colorCalQuarterly, true, calLeft, "QTD S", showCalQuarterly)
    calQtdS := b10
    calQtdSL := l10

// ─── Volume Analysis ─────────────────────────────────────────────────────────────
avgVolume = ta.sma(volume, volLookback)
relativeVolume = volume / avgVolume
highVolume = relativeVolume > volThreshold

// Abnormal volume spike (statistical): either a big multiple of avg OR a high z-score.
volStdev = ta.stdev(volume, volLookback)
volZScore = volStdev > 0 ? (volume - avgVolume) / volStdev : 0.0
volSpike = relativeVolume >= volSpikeMult or volZScore >= volSpikeZ
// Directional climax — spike with conviction in the candle body.
bullVolSpike = volSpike and close > open and (close - open) > (high - close)
bearVolSpike = volSpike and close < open and (open - close) > (close - low)

// ─── Vector Candle (PVSRA) Calculations ────────────────────────────────────────
volAvgVector = ta.sma(volume, vectorLookback)
spreadVector = high - low
volSpreadVector = volume * spreadVector
volSpreadHighest = ta.highest(volSpreadVector, vectorLookback)
isClimaxVector = volume >= (volAvgVector * vectorClimaxMult) or volSpreadVector == volSpreadHighest
isVectorActive = volume >= (volAvgVector * vectorActiveMult)

isBullClimax = isClimaxVector and close >= open
isBearClimax = isClimaxVector and close < open
isBullActive = isVectorActive and not isClimaxVector and close >= open
isBearActive = isVectorActive and not isClimaxVector and close < open

// ─── Pivot Points for Zone Detection ─────────────────────────────────────────────
leftBars = 5
rightBars = 5

// Regular pivots (5-bar lookback)
pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow = ta.pivotlow(low, leftBars, rightBars)

// Strong pivots (10-bar lookback)
strongPivotHigh = ta.pivothigh(high, 10, 10)
strongPivotLow = ta.pivotlow(low, 10, 10)

// Persistent bull/bear regime — declared early so zone LEAD scoring can read it.
var string regime = "neutral"

// ─── Order-Block Displacement (boosts existing magnets — never drawn alone) ─────
// Bull OB = last bearish body before upward displacement.
// Bear OB = last bullish body before downward displacement.
// Magnets that overlap these bodies get higher draw priority + signal weight.
var float recentBullObMid = na
var float recentBullObHalf = na
var int   recentBullObBar = na
var float recentBearObMid = na
var float recentBearObHalf = na
var int   recentBearObBar = na

bullDisplace = close - ta.lowest(low, 6) >= atrValue * obDisplaceMult and close > open
bearDisplace = ta.highest(high, 6) - close >= atrValue * obDisplaceMult and close < open
obVolOk = relativeVolume >= 1.1 or volSpike

if useObZoneBoost and bullDisplace and obVolOk
    for oi = 1 to 10
        if close[oi] < open[oi]
            recentBullObMid := (open[oi] + close[oi]) / 2.0
            recentBullObHalf := math.max(math.abs(open[oi] - close[oi]) / 2.0, atrValue * 0.12)
            recentBullObBar := bar_index - oi
            break
if useObZoneBoost and bearDisplace and obVolOk
    for oi = 1 to 10
        if close[oi] > open[oi]
            recentBearObMid := (open[oi] + close[oi]) / 2.0
            recentBearObHalf := math.max(math.abs(open[oi] - close[oi]) / 2.0, atrValue * 0.12)
            recentBearObBar := bar_index - oi
            break

// Expire stale OB anchors so old displacement does not keep boosting forever.
obMaxAge = zoneLookback * 3
if not na(recentBullObBar) and bar_index - recentBullObBar > obMaxAge
    recentBullObMid := na
    recentBullObHalf := na
    recentBullObBar := na
if not na(recentBearObBar) and bar_index - recentBearObBar > obMaxAge
    recentBearObMid := na
    recentBearObHalf := na
    recentBearObBar := na

f_obOverlap(float lvl, bool isSup) =>
    tol = atrValue * obBodyOverlapMult
    bullHit = not isSup and not na(recentBullObMid) and math.abs(lvl - recentBullObMid) <= math.max(nz(recentBullObHalf), tol)
    bearHit = isSup and not na(recentBearObMid) and math.abs(lvl - recentBearObMid) <= math.max(nz(recentBearObHalf), tol)
    bullHit or bearHit

f_obScoreAt(float lvl, bool isSup, float volSnap) =>
    int sc = 0
    if useObZoneBoost and f_obOverlap(lvl, isSup)
        sc := 1
        if volSnap >= volThreshold
            sc += 1
        // Fresh displacement near the magnet = stronger institutional footprint.
        ageBars = isSup ? (na(recentBearObBar) ? 999 : bar_index - recentBearObBar) : (na(recentBullObBar) ? 999 : bar_index - recentBullObBar)
        if ageBars <= 20
            sc += 1
    sc

// ─── Key Magnet Zone Engine ────────────────────────────────────────────────────
// Instead of drawing every pivot (clutter), pivots are clustered into levels and we
// only show the ones price keeps reacting to (magnets). Strength = reaction count.
// kzObScore = order-block confluence layered on the same magnet (0–3).
var float[] kzPrice    = array.new_float()
var int[]   kzStrength = array.new_int()
var int[]   kzBar      = array.new_int()
var bool[]  kzSupply   = array.new_bool()
// Flip tracking (parallel to the arrays above — must stay index-aligned at all times):
//   kzFlipped   = has this level changed roles (demand<->supply)
//   kzFlipState = 0 intact | 1 confirmed flip (closed through) | 2 flip + retest-confirmed
//   kzFlipBar   = bar_index when the flip occurred (used for fade-out priority)
var bool[]  kzFlipped   = array.new_bool()
var int[]   kzFlipState = array.new_int()
var int[]   kzFlipBar   = array.new_int()
var float[] kzVolRel    = array.new_float()
var int[]   kzObScore   = array.new_int()

// Register a pivot into the level pool: merge into a nearby level (magnet) or add new.
// Once a magnet reaches minZoneStrength, its price + origin bar LOCK so 1m pivots
// cannot keep sliding the zone around under price.
f_registerLevel(float[] aP, int[] aS, int[] aB, bool[] aSup, bool[] aFlip, int[] aFlipSt, int[] aFlipBar, float[] aVol, int[] aOb, float p, bool isSup, int curBar, float clusterDist, float volSnap, int initStr, int obSnap) =>
    int hit = -1
    if array.size(aP) > 0
        for i = 0 to array.size(aP) - 1
            if hit == -1 and array.get(aSup, i) == isSup and math.abs(array.get(aP, i) - p) <= clusterDist
                hit := i
    if hit == -1
        array.push(aP, p)
        array.push(aS, initStr)
        array.push(aB, curBar)
        array.push(aSup, isSup)
        array.push(aFlip, false)
        array.push(aFlipSt, 0)
        array.push(aFlipBar, na)
        array.push(aVol, volSnap)
        array.push(aOb, obSnap)
    else
        prevStr = array.get(aS, hit)
        array.set(aS, hit, math.min(prevStr + 1, 6))
        // Only nudge price/origin while the magnet is still forming.
        if prevStr < minZoneStrength
            array.set(aP, hit, (array.get(aP, hit) + p) / 2.0)
            array.set(aB, hit, curBar)
        array.set(aVol, hit, math.max(array.get(aVol, hit), volSnap))
        array.set(aOb, hit, math.max(array.get(aOb, hit), obSnap))

clusterDist = atrValue * zoneClusterMult
if not na(pivotHigh)
    f_registerLevel(kzPrice, kzStrength, kzBar, kzSupply, kzFlipped, kzFlipState, kzFlipBar, kzVolRel, kzObScore, pivotHigh, true, bar_index, clusterDist, relativeVolume[rightBars], 1, f_obScoreAt(pivotHigh, true, relativeVolume[rightBars]))
if not na(pivotLow)
    f_registerLevel(kzPrice, kzStrength, kzBar, kzSupply, kzFlipped, kzFlipState, kzFlipBar, kzVolRel, kzObScore, pivotLow, false, bar_index, clusterDist, relativeVolume[rightBars], 1, f_obScoreAt(pivotLow, false, relativeVolume[rightBars]))
if not na(strongPivotHigh)
    f_registerLevel(kzPrice, kzStrength, kzBar, kzSupply, kzFlipped, kzFlipState, kzFlipBar, kzVolRel, kzObScore, strongPivotHigh, true, bar_index, clusterDist, relativeVolume[10], 2, f_obScoreAt(strongPivotHigh, true, relativeVolume[10]))
if not na(strongPivotLow)
    f_registerLevel(kzPrice, kzStrength, kzBar, kzSupply, kzFlipped, kzFlipState, kzFlipBar, kzVolRel, kzObScore, strongPivotLow, false, bar_index, clusterDist, relativeVolume[10], 2, f_obScoreAt(strongPivotLow, false, relativeVolume[10]))

// Refresh OB scores on existing magnets when new displacement prints.
if useObZoneBoost and array.size(kzPrice) > 0 and (bullDisplace or bearDisplace)
    for ri = 0 to array.size(kzPrice) - 1
        rp = array.get(kzPrice, ri)
        rSup = array.get(kzSupply, ri)
        rVol = array.get(kzVolRel, ri)
        array.set(kzObScore, ri, math.max(array.get(kzObScore, ri), f_obScoreAt(rp, rSup, rVol)))

// Prune stale levels (untouched for a long time) and cap the candidate pool.
// Never prune a magnet price is currently inside — that is the bounce zone.
pruneAge = zoneLookback * 6
if array.size(kzPrice) > 0
    pIdx = array.size(kzPrice) - 1
    while pIdx >= 0 and array.size(kzPrice) > 0
        if pIdx >= array.size(kzPrice)
            pIdx := array.size(kzPrice) - 1
            if pIdx < 0
                break
        pp = array.get(kzPrice, pIdx)
        ph = atrValue * f_zoneHalfMult(array.get(kzStrength, pIdx))
        priceInside = high >= pp - ph and low <= pp + ph
        if not priceInside and bar_index - array.get(kzBar, pIdx) > pruneAge
            array.remove(kzPrice, pIdx)
            array.remove(kzStrength, pIdx)
            array.remove(kzBar, pIdx)
            array.remove(kzSupply, pIdx)
            array.remove(kzFlipState, pIdx)
            array.remove(kzFlipped, pIdx)
            array.remove(kzFlipBar, pIdx)
            array.remove(kzVolRel, pIdx)
            array.remove(kzObScore, pIdx)
            if array.size(kzPrice) == 0
                pIdx := -1
            // else item shifted into pIdx — re-check without decrementing
        else
            pIdx -= 1
while array.size(kzPrice) > 40
    // Prefer shifting the oldest non-in-zone magnet.
    dropIdx = 0
    for di = 0 to array.size(kzPrice) - 1
        dpp = array.get(kzPrice, di)
        dph = atrValue * f_zoneHalfMult(array.get(kzStrength, di))
        if not (high >= dpp - dph and low <= dpp + dph)
            dropIdx := di
            break
    array.remove(kzPrice, dropIdx)
    array.remove(kzStrength, dropIdx)
    array.remove(kzBar, dropIdx)
    array.remove(kzSupply, dropIdx)
    array.remove(kzFlipped, dropIdx)
    array.remove(kzFlipState, dropIdx)
    array.remove(kzFlipBar, dropIdx)
    array.remove(kzVolRel, dropIdx)
    array.remove(kzObScore, dropIdx)

// ─── Zone Flip Detection (runs every bar close — non-repainting) ───────────────
// A level flips role when a candle CLOSES through its band in the wrong direction
// for its current role (close-through alone confirms → state 1, role inverts).
// A later single-bar retest of the band that closes back through in the new role's
// breakout direction upgrades confidence → state 2 (role unchanged). Iterate freely
// on these rules; this is the part most likely to be tuned.
flipHalf = atrValue * 0.2
bool zoneFlipEvent = false
if array.size(kzPrice) > 0
    for i = 0 to array.size(kzPrice) - 1
        lvl = array.get(kzPrice, i)
        isSup = array.get(kzSupply, i)
        if not array.get(kzFlipped, i)
            // Demand fails when price closes below its band; supply fails when above.
            brokeDemand = (not isSup) and close < (lvl - flipHalf)
            brokeSupply = isSup and close > (lvl + flipHalf)
            if brokeDemand or brokeSupply
                array.set(kzFlipped, i, true)
                array.set(kzFlipState, i, 1)
                array.set(kzFlipBar, i, bar_index)
                array.set(kzSupply, i, not isSup)  // role inverts going forward
                zoneFlipEvent := true
        else if array.get(kzFlipState, i) == 1
            // Retest-rejection candle: wick taps the flipped band, close exits in the
            // new role's breakout direction → upgrade to retest-confirmed (state 2).
            newIsSup = array.get(kzSupply, i)
            retestTouch = high >= (lvl - flipHalf) and low <= (lvl + flipHalf)
            closedBack = newIsSup ? close < (lvl - flipHalf) : close > (lvl + flipHalf)
            if retestTouch and closedBack
                array.set(kzFlipState, i, 2)

// ─── Sticky displayed zones (locked until close-through takeout) ────────────────
// These are what the chart draws. Once pinned, price/half stay fixed so 1m
// re-scoring cannot swap boxes every bar. Removed only when close takes them out.
var float[] szPrice  = array.new_float()
var float[] szHalf   = array.new_float()
var int[]   szStr    = array.new_int()
var bool[]  szSup    = array.new_bool()
var bool[]  szFlip   = array.new_bool()
var int[]   szFlipSt = array.new_int()
var int[]   szOb     = array.new_int()
var int[]   szLeft   = array.new_int()
var int     szLeadIdx = -1

f_szRemove(int idx) =>
    array.remove(szPrice, idx)
    array.remove(szHalf, idx)
    array.remove(szStr, idx)
    array.remove(szSup, idx)
    array.remove(szFlip, idx)
    array.remove(szFlipSt, idx)
    array.remove(szOb, idx)
    array.remove(szLeft, idx)

f_szFindNear(float lvl, bool isSup, float tol) =>
    int found = -1
    if array.size(szPrice) > 0
        for i = 0 to array.size(szPrice) - 1
            if found == -1 and array.get(szSup, i) == isSup and math.abs(array.get(szPrice, i) - lvl) <= tol
                found := i
    found

f_szCountSide(bool above) =>
    int n = 0
    if array.size(szPrice) > 0
        for i = 0 to array.size(szPrice) - 1
            sp = array.get(szPrice, i)
            if above ? sp > close : sp <= close
                n += 1
    n

f_priceInBand(float lvl, float half) =>
    high >= lvl - half and low <= lvl + half

// Drop sticky zones only when a confirmed close takes them out (invalidated).
if stickyZones and barstate.isconfirmed and array.size(szPrice) > 0
    zi = array.size(szPrice) - 1
    while zi >= 0 and array.size(szPrice) > 0
        // Guard: after a remove emptied the array, stop before array.get.
        if zi >= array.size(szPrice)
            zi := array.size(szPrice) - 1
            if zi < 0
                break
        zl = array.get(szPrice, zi)
        zh = array.get(szHalf, zi)
        zs = array.get(szSup, zi)
        takenOut = zs ? close > zl + zh : close < zl - zh
        if takenOut
            f_szRemove(zi)
            if szLeadIdx == zi
                szLeadIdx := -1
            else if szLeadIdx > zi
                szLeadIdx -= 1
            // Removed last item → exit; otherwise same zi now holds the next candidate.
            if array.size(szPrice) == 0
                zi := -1
        else
            // Keep meta in sync from magnet pool without moving the locked price.
            if array.size(kzPrice) > 0
                for ki = 0 to array.size(kzPrice) - 1
                    if array.get(kzSupply, ki) == zs and math.abs(array.get(kzPrice, ki) - zl) <= math.max(zh, atrValue * 0.25)
                        array.set(szStr, zi, math.max(array.get(szStr, zi), array.get(kzStrength, ki)))
                        array.set(szOb, zi, math.max(array.get(szOb, zi), array.get(kzObScore, ki)))
                        array.set(szFlip, zi, array.get(kzFlipped, ki))
                        array.set(szFlipSt, zi, array.get(kzFlipState, ki))
            zi -= 1

// Admit strong magnets into sticky slots (empty capacity, or price is inside).
if stickyZones and array.size(kzPrice) > 0
    admitTol = atrValue * zoneClusterMult
    for ki = 0 to array.size(kzPrice) - 1
        ks = array.get(kzStrength, ki)
        if ks >= minZoneStrength
            kp = array.get(kzPrice, ki)
            ksup = array.get(kzSupply, ki)
            kh = atrValue * f_zoneHalfMult(ks)
            already = f_szFindNear(kp, ksup, admitTol)
            inBand = f_priceInBand(kp, kh)
            if already >= 0
                array.set(szStr, already, math.max(array.get(szStr, already), ks))
                array.set(szOb, already, math.max(array.get(szOb, already), array.get(kzObScore, ki)))
            else
                above = kp > close
                sideCount = f_szCountSide(above)
                canAdmit = inBand or sideCount < maxZonesPerSide
                if canAdmit
                    // If over capacity but price is inside, drop farthest opposite-of-touch sticky on that side.
                    if inBand and sideCount >= maxZonesPerSide and array.size(szPrice) > 0
                        farIdx = -1
                        float farDist = -1.0
                        for si = 0 to array.size(szPrice) - 1
                            sp = array.get(szPrice, si)
                            sh = array.get(szHalf, si)
                            sameSide = above ? sp > close : sp <= close
                            if sameSide and not f_priceInBand(sp, sh)
                                d = math.abs(sp - close)
                                if d > farDist
                                    farDist := d
                                    farIdx := si
                        if farIdx >= 0
                            f_szRemove(farIdx)
                            if szLeadIdx == farIdx
                                szLeadIdx := -1
                            else if szLeadIdx > farIdx
                                szLeadIdx -= 1
                            sideCount := f_szCountSide(above)
                    if inBand or sideCount < maxZonesPerSide
                        // Anti-stack: skip if another sticky is already too close.
                        tooClose = false
                        stackDist = atrValue * zoneStackMinMult
                        if array.size(szPrice) > 0
                            for si = 0 to array.size(szPrice) - 1
                                if array.get(szSup, si) == ksup and math.abs(array.get(szPrice, si) - kp) < stackDist
                                    tooClose := true
                        if not tooClose
                            array.push(szPrice, kp)
                            array.push(szHalf, kh)
                            array.push(szStr, ks)
                            array.push(szSup, ksup)
                            array.push(szFlip, array.get(kzFlipped, ki))
                            array.push(szFlipSt, array.get(kzFlipState, ki))
                            array.push(szOb, array.get(kzObScore, ki))
                            array.push(szLeft, array.get(kzBar, ki))

// ─── Liquidity Magnet Engine (BSL/SSL pools → zone boost + DRAW + pool boxes) ─
// Ported from LiqMagnet v2: scored pools + TAKEN + sweep-reclaim + optional
// red/teal pool boxes (the bands that catch local bottoms/tops).
liqIsScalp = liqMode == "Scalp"
liqIsSwing = liqMode == "Swing"
// Align with LiqMagnet v2 presets so the same overhead BSL/SSL pools form.
liqEffPivot = liqIsScalp ? 1 : liqIsSwing ? 3 : 2
liqEffTouches = 2
liqEffCluster = liqIsScalp ? 0.15 : liqIsSwing ? 0.50 : 0.30
liqEffZ = liqIsScalp ? 1.8 : liqIsSwing ? 2.2 : 2.0
liqEffWick = liqIsScalp ? 0.80 : liqIsSwing ? 1.20 : 1.0
liqEffMaxPools = liqIsScalp ? 16 : liqIsSwing ? 20 : 18
liqEffDecay = liqIsScalp ? 0.55 : liqIsSwing ? 0.10 : 0.35
liqEffFade = liqIsScalp ? 14 : liqIsSwing ? 28 : 10
liqEffMaxAge = liqIsScalp ? 400 : liqIsSwing ? 1500 : 500
liqEffPivotHist = liqIsScalp ? 8 : liqIsSwing ? 12 : 8
liqEffKeyScore = liqIsScalp ? math.min(liqBoxMinScore, 35.0) : liqIsSwing ? math.max(liqBoxMinScore, 45.0) : liqBoxMinScore
liqTfSec = timeframe.in_seconds()
liqIs1m = liqTfSec > 0 and liqTfSec <= 60
liqIsLtf = liqTfSec > 0 and liqTfSec <= 300
liqEffImpact = liqIs1m ? math.max(liqMinImpact, 68.0) : liqIsLtf ? math.max(liqMinImpact, 60.0) : liqMinImpact
liqEffCool = liqIs1m ? math.max(liqCoolBars, 20) : liqIsLtf ? math.max(liqCoolBars, 14) : liqCoolBars

liqTrendDir = regime == "bull" ? 1 : regime == "bear" ? -1 : 0
liqBody = math.abs(close - open)
liqUpWick = high - math.max(close, open)
liqDnWick = math.min(close, open) - low
liqRng = math.max(high - low, syminfo.mintick)
liqClosePos = (close - low) / liqRng
liqAbnormalVol = volZScore >= liqEffZ
liqNewHigh20 = high >= ta.highest(high, 20)
liqNewLow20 = low <= ta.lowest(low, 20)
liqSweepHighEvt = useLiqMagnet and liqAbnormalVol and liqUpWick >= liqBody * liqEffWick and liqNewHigh20
liqSweepLowEvt = useLiqMagnet and liqAbnormalVol and liqDnWick >= liqBody * liqEffWick and liqNewLow20

// Pivot series must be computed every bar (Pine series continuity).
liqPh = ta.pivothigh(high, liqEffPivot, liqEffPivot)
liqPl = ta.pivotlow(low, liqEffPivot, liqEffPivot)

var float[] lpPrice = array.new_float()
var int[]   lpBar = array.new_int()
var bool[]  lpBuy = array.new_bool()
var float[] lpBase = array.new_float()
var int[]   lpTouches = array.new_int()
var int[]   lpType = array.new_int()
var bool[]  lpTaken = array.new_bool()
var int[]   lpTapBar = array.new_int()
var box[]   lpBox = array.new_box()
var label[] lpLabel = array.new_label()
var float[] lpPhHist = array.new_float()
var float[] lpPlHist = array.new_float()

f_lpScore(int i) =>
    base = array.get(lpBase, i)
    age = bar_index - array.get(lpBar, i)
    fresh = math.max(35.0, 100.0 - age * liqEffDecay)
    isBuy = array.get(lpBuy, i)
    aligns = liqTrendDir != 0 and ((isBuy and liqTrendDir == 1) or (not isBuy and liqTrendDir == -1))
    math.min(100.0, math.max(0.0, 0.6 * base + 0.4 * fresh + (aligns ? 15.0 : 0.0)))

f_lpFind(float lvl, bool isBuy) =>
    int idx = -1
    if array.size(lpPrice) > 0
        for i = 0 to array.size(lpPrice) - 1
            if idx == -1 and array.get(lpBuy, i) == isBuy and math.abs(array.get(lpPrice, i) - lvl) <= liqEffCluster * atrValue
                idx := i
    idx

f_lpDeleteVisuals(int idx) =>
    bx = array.get(lpBox, idx)
    if not na(bx)
        box.delete(bx)
    la = array.get(lpLabel, idx)
    if not na(la)
        label.delete(la)

f_lpRemove(int idx) =>
    f_lpDeleteVisuals(idx)
    array.remove(lpPrice, idx)
    array.remove(lpBar, idx)
    array.remove(lpBuy, idx)
    array.remove(lpBase, idx)
    array.remove(lpTouches, idx)
    array.remove(lpType, idx)
    array.remove(lpTaken, idx)
    array.remove(lpTapBar, idx)
    array.remove(lpBox, idx)
    array.remove(lpLabel, idx)

// Create real geometry at register time (sweep = wick→body like Liq Hunter).
f_lpMkVisuals(float lvl, bool isBuy, int ptype) =>
    color c = isBuy ? liqBuyColor : liqSellColor
    box bx = box(na)
    if showLiqPoolZones
        fillT = math.max(liqZoneOpacity, 88)
        if ptype == 0
            z1 = isBuy ? math.max(close, open) : math.min(close, open)
            bx := box.new(bar_index, lvl, bar_index, z1, border_color=color.new(c, 55), bgcolor=color.new(c, fillT), border_width=1, border_style=line.style_dotted, extend=extend.right)
        else
            half = atrValue * 0.18
            bx := box.new(bar_index, lvl + half, bar_index, lvl - half, border_color=color.new(c, 60), bgcolor=color.new(c, math.min(96, fillT + 2)), border_width=1, border_style=line.style_dotted, extend=extend.right)
        // Hide until key-selection refresh promotes it.
        box.set_border_color(bx, na)
        box.set_bgcolor(bx, na)
    label la = label(na)
    [bx, la]

f_lpEnsureBox(int idx) =>
    bx = array.get(lpBox, idx)
    if na(bx) and showLiqPoolZones
        lvl = array.get(lpPrice, idx)
        isBuy = array.get(lpBuy, idx)
        ptype = array.get(lpType, idx)
        c = isBuy ? liqBuyColor : liqSellColor
        leftB = array.get(lpBar, idx)
        fillT = math.max(liqZoneOpacity, 88)
        if ptype == 0
            half = atrValue * 0.35
            bx := box.new(leftB, lvl + (isBuy ? 0.0 : half), bar_index, lvl - (isBuy ? half : 0.0), border_color=color.new(c, 55), bgcolor=color.new(c, fillT), border_width=1, border_style=line.style_dotted, extend=extend.right)
        else
            half2 = atrValue * 0.18
            bx := box.new(leftB, lvl + half2, bar_index, lvl - half2, border_color=color.new(c, 60), bgcolor=color.new(c, math.min(96, fillT + 2)), border_width=1, border_style=line.style_dotted, extend=extend.right)
        array.set(lpBox, idx, bx)
    bx

// Nearest bias for slot 0; raw score for slot 1+ (higher far magnets).
f_lpMatterScore(int i) =>
    sc = f_lpScore(i)
    distAtr = atrValue > 0 ? math.abs(array.get(lpPrice, i) - close) / atrValue : 0.0
    sc / (1.0 + distAtr * 0.45)

f_lpRegister(float lvl, bool isBuy, float baseScore, int ptype) =>
    score = math.min(100.0, baseScore)
    idx = f_lpFind(lvl, isBuy)
    if idx >= 0
        array.set(lpTouches, idx, array.get(lpTouches, idx) + 1)
        array.set(lpBase, idx, math.min(100.0, math.max(array.get(lpBase, idx), score) + 5.0))
        array.set(lpBar, idx, bar_index)
        if array.get(lpTaken, idx)
            array.set(lpTaken, idx, false)
            array.set(lpTapBar, idx, 0)
    else
        weakIdx = -1
        float weakVal = 1e10
        if array.size(lpPrice) >= liqEffMaxPools
            for k = 0 to array.size(lpPrice) - 1
                s = array.get(lpTaken, k) ? -1.0 : f_lpScore(k)
                if s < weakVal
                    weakVal := s
                    weakIdx := k
        canWrite = array.size(lpPrice) < liqEffMaxPools or (weakIdx >= 0 and weakVal < score)
        if canWrite
            [bxN, laN] = f_lpMkVisuals(lvl, isBuy, ptype)
            if array.size(lpPrice) >= liqEffMaxPools and weakIdx >= 0
                f_lpDeleteVisuals(weakIdx)
                array.set(lpPrice, weakIdx, lvl)
                array.set(lpBar, weakIdx, bar_index)
                array.set(lpBuy, weakIdx, isBuy)
                array.set(lpBase, weakIdx, score)
                array.set(lpTouches, weakIdx, 1)
                array.set(lpType, weakIdx, ptype)
                array.set(lpTaken, weakIdx, false)
                array.set(lpTapBar, weakIdx, 0)
                array.set(lpBox, weakIdx, bxN)
                array.set(lpLabel, weakIdx, laN)
            else
                array.push(lpPrice, lvl)
                array.push(lpBar, bar_index)
                array.push(lpBuy, isBuy)
                array.push(lpBase, score)
                array.push(lpTouches, 1)
                array.push(lpType, ptype)
                array.push(lpTaken, false)
                array.push(lpTapBar, 0)
                array.push(lpBox, bxN)
                array.push(lpLabel, laN)

if useLiqMagnet and barstate.isconfirmed
    if not na(liqPh)
        touches = 1
        if array.size(lpPhHist) > 0
            for j = 0 to array.size(lpPhHist) - 1
                if math.abs(liqPh - array.get(lpPhHist, j)) <= liqEffCluster * atrValue
                    touches += 1
        array.push(lpPhHist, liqPh)
        if array.size(lpPhHist) > liqEffPivotHist
            array.shift(lpPhHist)
        baseH = 18 + touches * 10 + (touches >= liqEffTouches ? 12.0 : 0.0) + (liqAbnormalVol ? 15.0 : 0.0)
        f_lpRegister(liqPh, true, math.min(80.0, baseH), 1)
    if not na(liqPl)
        touchesL = 1
        if array.size(lpPlHist) > 0
            for j = 0 to array.size(lpPlHist) - 1
                if math.abs(liqPl - array.get(lpPlHist, j)) <= liqEffCluster * atrValue
                    touchesL += 1
        array.push(lpPlHist, liqPl)
        if array.size(lpPlHist) > liqEffPivotHist
            array.shift(lpPlHist)
        baseL = 18 + touchesL * 10 + (touchesL >= liqEffTouches ? 12.0 : 0.0) + (liqAbnormalVol ? 15.0 : 0.0)
        f_lpRegister(liqPl, false, math.min(80.0, baseL), 1)
    if liqSweepHighEvt
        f_lpRegister(high, true, 40 + math.min(30.0, volZScore * 5.0), 0)
    if liqSweepLowEvt
        f_lpRegister(low, false, 40 + math.min(30.0, volZScore * 5.0), 0)

float bestBullLiqImp = 0.0
float bestBearLiqImp = 0.0
if useLiqMagnet and barstate.isconfirmed and array.size(lpPrice) > 0
    for i = array.size(lpPrice) - 1 to 0
        if not array.get(lpTaken, i) and bar_index > array.get(lpBar, i)
            lvl = array.get(lpPrice, i)
            isBuy = array.get(lpBuy, i)
            tapped = isBuy ? high > lvl : low < lvl
            if tapped
                array.set(lpTaken, i, true)
                array.set(lpTapBar, i, bar_index)
                imp = f_lpScore(i) + math.min(18.0, volZScore * 4.0) + (array.get(lpTouches, i) >= 2 ? 10.0 : 0.0)
                if isBuy and close < lvl and liqClosePos < 0.40
                    if liqTrendDir == -1
                        imp += 16.0
                    else if liqTrendDir == 1
                        imp -= 22.0
                    if imp > bestBearLiqImp
                        bestBearLiqImp := imp
                if not isBuy and close > lvl and liqClosePos > 0.60
                    if liqTrendDir == 1
                        imp += 16.0
                    else if liqTrendDir == -1
                        imp -= 22.0
                    if imp > bestBullLiqImp
                        bestBullLiqImp := imp

if useLiqMagnet and barstate.isconfirmed and array.size(lpPrice) > 0
    for i = array.size(lpPrice) - 1 to 0
        kill = false
        if array.get(lpTaken, i) and bar_index - array.get(lpTapBar, i) > liqEffFade
            kill := true
        if bar_index - array.get(lpBar, i) > liqEffMaxAge
            kill := true
        if kill
            f_lpRemove(i)

var int lastLiqSigBar = 0
liqLoneBull = useLiqMagnet and not liqIsLtf and liqSweepLowEvt and barstate.isconfirmed and close > open and liqClosePos > 0.60
liqLoneBear = useLiqMagnet and not liqIsLtf and liqSweepHighEvt and barstate.isconfirmed and close < open and liqClosePos < 0.40
liqBullCand = useLiqMagnet and ((bestBullLiqImp >= liqEffImpact) or liqLoneBull)
liqBearCand = useLiqMagnet and ((bestBearLiqImp >= liqEffImpact) or liqLoneBear)
if liqIsLtf and liqTrendDir != 0
    if liqTrendDir == 1
        liqBearCand := false
    else if liqTrendDir == -1
        liqBullCand := false
if liqBullCand and liqBearCand
    if bestBullLiqImp >= bestBearLiqImp
        liqBearCand := false
    else
        liqBullCand := false
liqCoolOk = bar_index - lastLiqSigBar >= liqEffCool
if not liqCoolOk
    liqBullCand := false
    liqBearCand := false
bool liqBullReclaim = false
bool liqBearReclaim = false
if barstate.isconfirmed
    if liqBullCand
        liqBullReclaim := true
        lastLiqSigBar := bar_index
    if liqBearCand
        liqBearReclaim := true
        lastLiqSigBar := bar_index

f_nearestUntapped(bool wantBuy, bool above) =>
    float best = na
    if useLiqMagnet and array.size(lpPrice) > 0
        for i = 0 to array.size(lpPrice) - 1
            if not array.get(lpTaken, i) and array.get(lpBuy, i) == wantBuy
                lvl = array.get(lpPrice, i)
                ok = above ? lvl > close : lvl < close
                if ok and (na(best) or (above ? lvl < best : lvl > best))
                    best := lvl
    best

float magnetBsl = f_nearestUntapped(true, true)
float magnetSsl = f_nearestUntapped(false, false)
float liqDrawLvl = na
if useLiqMagnet
    if liqTrendDir == 1
        liqDrawLvl := magnetBsl
    else if liqTrendDir == -1
        liqDrawLvl := magnetSsl
    else
        liqDrawLvl := na(magnetBsl) ? magnetSsl : na(magnetSsl) ? magnetBsl : math.abs(magnetBsl - close) <= math.abs(magnetSsl - close) ? magnetBsl : magnetSsl

// True when a zone level sits on untapped liquidity (helps Breakout boxes make sense).
f_zoneOnLiq(float lvl, bool isSup) =>
    bool hit = false
    if useLiqMagnet and boostZonesWithLiq and array.size(lpPrice) > 0
        tol = math.max(atrValue * liqEffCluster, atrValue * 0.25)
        for i = 0 to array.size(lpPrice) - 1
            if not hit and not array.get(lpTaken, i)
                // Supply zone ↔ BSL above; demand zone ↔ SSL below
                wantBuy = isSup
                if array.get(lpBuy, i) == wantBuy and math.abs(array.get(lpPrice, i) - lvl) <= tol
                    hit := true
    hit

plotshape(showLiqReclaimMarks and liqBullReclaim, title="Liq Sweep Reclaim Bull", style=shape.flag, location=location.belowbar, color=color.white, size=size.tiny)
plotshape(showLiqReclaimMarks and liqBearReclaim, title="Liq Sweep Reclaim Bear", style=shape.flag, location=location.abovebar, color=#E100FF, size=size.tiny)

// Key liquidity = nearest + strongest per side (so higher far BSL shows like Liq Hunter).
if barstate.islast and useLiqMagnet and array.size(lpPrice) > 0
    eliteBox = array.new_int()
    needVis = showLiqPoolZones or showLiqPoolLabels
    if needVis
        // Pin nearest untapped BSL / SSL / DRAW magnets first.
        for i = 0 to array.size(lpPrice) - 1
            if array.get(lpTaken, i)
                continue
            lvlI = array.get(lpPrice, i)
            pin = false
            if not na(magnetBsl) and array.get(lpBuy, i) and math.abs(lvlI - magnetBsl) <= atrValue * 0.35
                pin := true
            if not na(magnetSsl) and not array.get(lpBuy, i) and math.abs(lvlI - magnetSsl) <= atrValue * 0.35
                pin := true
            if not na(liqDrawLvl) and math.abs(lvlI - liqDrawLvl) <= atrValue * 0.35
                pin := true
            if pin
                already = false
                if array.size(eliteBox) > 0
                    for e = 0 to array.size(eliteBox) - 1
                        if array.get(eliteBox, e) == i
                            already := true
                if not already
                    array.push(eliteBox, i)
        // Slot 0 = nearest-bias, slot 1+ = raw score (catches higher far liquidity).
        for pass = 0 to 1
            wantAbove = pass == 0
            for slot = 0 to liqBoxMaxPerSide - 1
                bestI = -1
                float bestVal = -1.0
                useRawScore = slot >= 1
                for i = 0 to array.size(lpPrice) - 1
                    if array.get(lpTaken, i)
                        continue
                    if f_lpScore(i) < liqEffKeyScore
                        continue
                    lvlI = array.get(lpPrice, i)
                    sideOk = wantAbove ? lvlI > close : lvlI < close
                    if not sideOk
                        continue
                    if wantAbove != array.get(lpBuy, i)
                        continue
                    already2 = false
                    if array.size(eliteBox) > 0
                        for e = 0 to array.size(eliteBox) - 1
                            if array.get(eliteBox, e) == i
                                already2 := true
                    if already2
                        continue
                    val = useRawScore ? f_lpScore(i) : f_lpMatterScore(i)
                    if not na(liqDrawLvl) and math.abs(lvlI - liqDrawLvl) <= atrValue * 0.55
                        val += 20.0
                    if val > bestVal
                        bestVal := val
                        bestI := i
                if bestI >= 0
                    array.push(eliteBox, bestI)

    for i = 0 to array.size(lpPrice) - 1
        lvl = array.get(lpPrice, i)
        isBuy = array.get(lpBuy, i)
        sc = f_lpScore(i)
        bx = array.get(lpBox, i)
        la = array.get(lpLabel, i)
        isElite = false
        if array.size(eliteBox) > 0
            for e = 0 to array.size(eliteBox) - 1
                if array.get(eliteBox, e) == i
                    isElite := true
        showKey = isElite and not array.get(lpTaken, i)
        showLbl = showLiqPoolLabels and showKey
        showBox = showLiqPoolZones and showKey
        isDraw = not na(liqDrawLvl) and math.abs(lvl - liqDrawLvl) <= atrValue * 0.55

        if showLbl
            cLive = isDraw ? liqDrawColor : isBuy ? liqBuyColor : liqSellColor
            liveTxt = (isDraw ? "DRAW · " : "") + str.tostring(lvl, format.mintick) + "  ·  " + str.tostring(math.round(sc)) + "  ·  " + f_pctAwaySigned(lvl)
            if na(la)
                la := label.new(bar_index + lblLanePool, lvl, liveTxt, style=label.style_label_left, color=color.new(cLive, 10), textcolor=isDraw ? color.black : color.white, size=size.tiny)
                array.set(lpLabel, i, la)
            else
                label.set_xy(la, bar_index + lblLanePool, lvl)
                label.set_text(la, liveTxt)
                label.set_color(la, color.new(cLive, 10))
                label.set_textcolor(la, isDraw ? color.black : color.white)
        else if not na(la)
            label.set_text(la, "")
            label.set_color(la, na)

        if showBox
            bx := f_lpEnsureBox(i)
            cLive2 = isDraw ? liqDrawColor : isBuy ? liqBuyColor : liqSellColor
            fillT = math.max(liqZoneOpacity, 88)
            if not na(bx)
                box.set_border_color(bx, color.new(cLive2, isDraw ? 35 : 55))
                box.set_border_width(bx, 1)
                box.set_border_style(bx, line.style_dotted)
                box.set_bgcolor(bx, color.new(cLive2, fillT))
        else if not na(bx)
            box.set_border_color(bx, na)
            box.set_bgcolor(bx, na)

var line liqLeadRail = na
var box  liqLeadBox = na
var label liqDrawLbl = na
if barstate.islast
    if not na(liqLeadRail)
        line.delete(liqLeadRail)
        liqLeadRail := na
    if not na(liqLeadBox)
        box.delete(liqLeadBox)
        liqLeadBox := na
    if not na(liqDrawLbl)
        label.delete(liqDrawLbl)
        liqDrawLbl := na
    if useLiqMagnet and showLiqDraw and not na(liqDrawLvl)
        // Band + DRAW tag when no sticky/key zone already owns this level.
        leadOwnedByZone = false
        if stickyZones and array.size(szPrice) > 0
            for oi = 0 to array.size(szPrice) - 1
                if math.abs(array.get(szPrice, oi) - liqDrawLvl) <= atrValue * 0.55
                    leadOwnedByZone := true
                    break
        else if array.size(kzPrice) > 0
            for oi = 0 to array.size(kzPrice) - 1
                if array.get(kzStrength, oi) >= minZoneStrength and math.abs(array.get(kzPrice, oi) - liqDrawLvl) <= atrValue * 0.55
                    leadOwnedByZone := true
                    break
        // Also skip duplicate band if a key pool box already sits here.
        if not leadOwnedByZone and array.size(lpPrice) > 0
            for oi = 0 to array.size(lpPrice) - 1
                if not array.get(lpTaken, oi) and math.abs(array.get(lpPrice, oi) - liqDrawLvl) <= atrValue * 0.55
                    leadOwnedByZone := true
                    break
        if not leadOwnedByZone
            leadHalf = atrValue * 0.22
            leftLead = bar_index - 40
            liqLeadBox := box.new(leftLead, liqDrawLvl + leadHalf, bar_index + 6, liqDrawLvl - leadHalf, bgcolor=color.new(liqDrawColor, 90), border_color=color.new(liqDrawColor, 35), border_width=1, border_style=line.style_dotted)
            liqLeadRail := line.new(leftLead, liqDrawLvl, bar_index + 6, liqDrawLvl, color=color.new(liqDrawColor, 25), style=line.style_dotted, width=1)
            sideTag = liqDrawLvl > close ? "BSL" : "SSL"
            liqTxt = "DRAW · " + sideTag + " · " + str.tostring(liqDrawLvl, format.mintick)
            if showZoneDistancePct
                liqTxt += " · " + f_pctAwaySigned(liqDrawLvl)
            liqDrawLbl := label.new(bar_index + lblLaneLiq, liqDrawLvl, liqTxt, color=color.new(liqDrawColor, 10), textcolor=color.black, style=label.style_label_left, size=size.tiny)

// ─── Liquidity levels (legacy equal-pivot rails; optional) ─────────────────────
var float liqLastPH = na
var float liqLastPL = na
var line[]  liqLines = array.new_line()
var label[] liqLabels = array.new_label()
var bool[]  liqIsBuy = array.new_bool()

liqTol = atrValue * liqTolMult
if not na(pivotHigh)
    if showLiquidity and not na(liqLastPH) and math.abs(pivotHigh - liqLastPH) <= liqTol
        lvl = math.max(pivotHigh, liqLastPH)
        ln = line.new(bar_index[rightBars], lvl, bar_index + 5, lvl, color=color.new(color.yellow, 0), style=line.style_dotted, width=1)
        array.push(liqLines, ln)
        array.push(liqIsBuy, true)
        lb = label.new(bar_index + 5, lvl, "BSL", color=color.new(color.yellow, 90), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)
        array.push(liqLabels, lb)
    liqLastPH := pivotHigh
if not na(pivotLow)
    if showLiquidity and not na(liqLastPL) and math.abs(pivotLow - liqLastPL) <= liqTol
        lvl = math.min(pivotLow, liqLastPL)
        ln = line.new(bar_index[rightBars], lvl, bar_index + 5, lvl, color=color.new(color.yellow, 0), style=line.style_dotted, width=1)
        array.push(liqLines, ln)
        array.push(liqIsBuy, false)
        lb = label.new(bar_index + 5, lvl, "SSL", color=color.new(color.yellow, 90), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)
        array.push(liqLabels, lb)
    liqLastPL := pivotLow

float liqAboveLevel = na
float liqBelowLevel = na
// Prefer magnet-engine nearest untapped pools when enabled.
if useLiqMagnet
    liqAboveLevel := magnetBsl
    liqBelowLevel := magnetSsl
if array.size(liqLines) > 0
    lIdx = array.size(liqLines) - 1
    while lIdx >= 0
        ln = array.get(liqLines, lIdx)
        lvl = line.get_y1(ln)
        isBuy = array.get(liqIsBuy, lIdx)
        swept = isBuy ? high > lvl : low < lvl
        stale = bar_index - line.get_x1(ln) > pruneAge
        if swept or stale
            line.delete(ln)
            label.delete(array.get(liqLabels, lIdx))
            array.remove(liqLines, lIdx)
            array.remove(liqLabels, lIdx)
            array.remove(liqIsBuy, lIdx)
        else
            line.set_x2(ln, bar_index + 5)
            label.set_x(array.get(liqLabels, lIdx), bar_index + 5)
            if not useLiqMagnet
                if lvl > close and (na(liqAboveLevel) or lvl < liqAboveLevel)
                    liqAboveLevel := lvl
                if lvl < close and (na(liqBelowLevel) or lvl > liqBelowLevel)
                    liqBelowLevel := lvl
        lIdx -= 1
while array.size(liqLines) > 6
    line.delete(array.shift(liqLines))
    label.delete(array.shift(liqLabels))
    array.shift(liqIsBuy)

// Nearest key magnet above/below price (prefer sticky drawn zones when enabled).
float nearestKeyAbove = na
int   nearestKeyAboveStr = 0
int   nearestKeyAboveOb = 0
float nearestKeyBelow = na
int   nearestKeyBelowStr = 0
int   nearestKeyBelowOb = 0
useStickyKeys = stickyZones and array.size(szPrice) > 0
if useStickyKeys
    for i = 0 to array.size(szPrice) - 1
        kp = array.get(szPrice, i)
        ks = array.get(szStr, i)
        ko = array.get(szOb, i)
        if kp > close and (na(nearestKeyAbove) or kp < nearestKeyAbove)
            nearestKeyAbove := kp
            nearestKeyAboveStr := ks
            nearestKeyAboveOb := ko
        if kp < close and (na(nearestKeyBelow) or kp > nearestKeyBelow)
            nearestKeyBelow := kp
            nearestKeyBelowStr := ks
            nearestKeyBelowOb := ko
else if array.size(kzPrice) > 0
    for i = 0 to array.size(kzPrice) - 1
        kp = array.get(kzPrice, i)
        ks = array.get(kzStrength, i)
        ko = array.get(kzObScore, i)
        if ks >= minZoneStrength
            if kp > close and (na(nearestKeyAbove) or kp < nearestKeyAbove)
                nearestKeyAbove := kp
                nearestKeyAboveStr := ks
                nearestKeyAboveOb := ko
            if kp < close and (na(nearestKeyBelow) or kp > nearestKeyBelow)
                nearestKeyBelow := kp
                nearestKeyBelowStr := ks
                nearestKeyBelowOb := ko

// Strength tiers — chart brightness maps to these; stronger = higher reversal odds.
// OB-boosted magnets count one tier higher for "strong" quality gates.
demandMagnetStrong = not na(nearestKeyBelow) and (nearestKeyBelowStr >= 4 or (nearestKeyBelowStr >= 3 and nearestKeyBelowOb >= 2))
supplyMagnetStrong = not na(nearestKeyAbove) and (nearestKeyAboveStr >= 4 or (nearestKeyAboveStr >= 3 and nearestKeyAboveOb >= 2))
demandMagnetElite = not na(nearestKeyBelow) and (nearestKeyBelowStr >= 5 or (nearestKeyBelowStr >= 4 and nearestKeyBelowOb >= 2))
supplyMagnetElite = not na(nearestKeyAbove) and (nearestKeyAboveStr >= 5 or (nearestKeyAboveStr >= 4 and nearestKeyAboveOb >= 2))
demandObBoosted = not na(nearestKeyBelow) and nearestKeyBelowOb >= 1
supplyObBoosted = not na(nearestKeyAbove) and nearestKeyAboveOb >= 1

f_keyNearHtf(float keyLvl, float htfLvl, float htfBand) =>
    not na(keyLvl) and not na(htfLvl) and htfBand > 0 and math.abs(keyLvl - htfLvl) <= htfBand * 1.25

// Score which HTF box price is most likely to trade into next (path + proximity).
f_htfMagnetScore(float lvl, float band, bool isSup, bool visible) =>
    float sc = -1e18
    if visible and not na(lvl) and band > 0
        sideOk = isSup ? lvl > close : lvl < close
        inBand = high >= (lvl - band) and low <= (lvl + band)
        distAtr = atrValue > 0 ? math.abs(lvl - close) / math.max(atrValue, band) : 999.0
        if inBand or sideOk
            sc := inBand ? 55.0 : (1.0 / (distAtr + 0.25)) * 32.0
            priceFalling = close < close[3] or close < close[1]
            priceRising = close > close[3] or close > close[1]
            pathDemand = regime == "bear" or (regime != "bull" and priceFalling)
            pathSupply = regime == "bull" or (regime != "bear" and priceRising)
            onPath = (not isSup and pathDemand) or (isSup and pathSupply)
            againstPath = (not isSup and pathSupply and not pathDemand) or (isSup and pathDemand and not pathSupply)
            if onPath
                sc += 16
            else if againstPath
                sc -= 22
            approaching = (not isSup and priceFalling) or (isSup and priceRising)
            if approaching
                sc += 10
            if (regime == "bull" and not isSup) or (regime == "bear" and isSup)
                sc += 6
    sc

if showHtfZones and barstate.islast
    leftRef = bar_index - 300
    skipZ1D = htfHideNearKey and f_keyNearHtf(nearestKeyBelow, z1Low, z1Band)
    skipZ1S = htfHideNearKey and f_keyNearHtf(nearestKeyAbove, z1High, z1Band)
    skipZ2D = htfHideNearKey and f_keyNearHtf(nearestKeyBelow, z2Low, z2Band)
    skipZ2S = htfHideNearKey and f_keyNearHtf(nearestKeyAbove, z2High, z2Band)

    // Pick the single HTF box price is most likely to magnet into next.
    s1d = f_htfMagnetScore(z1Low, z1Band, false, not skipZ1D)
    s1s = f_htfMagnetScore(z1High, z1Band, true, not skipZ1S)
    s2d = f_htfMagnetScore(z2Low, z2Band, false, not skipZ2D)
    s2s = f_htfMagnetScore(z2High, z2Band, true, not skipZ2S)
    // Slight preference for the higher anchor when scores are close (stronger magnet).
    s2d += s2d > -1e17 ? 2.0 : 0.0
    s2s += s2s > -1e17 ? 2.0 : 0.0
    bestHtfScore = math.max(s1d, math.max(s1s, math.max(s2d, s2s)))
    int bestHtfId = -1
    if bestHtfScore > -1e17
        bestHtfId := s1d >= bestHtfScore ? 1 : s1s >= bestHtfScore ? 2 : s2d >= bestHtfScore ? 3 : 4
    // Hysteresis — only switch LEAD when the new target clearly wins.
    curHtfScore = htfLeadId == 1 ? s1d : htfLeadId == 2 ? s1s : htfLeadId == 3 ? s2d : htfLeadId == 4 ? s2s : -1e18
    curStillVisible = (htfLeadId == 1 and not skipZ1D) or (htfLeadId == 2 and not skipZ1S) or (htfLeadId == 3 and not skipZ2D) or (htfLeadId == 4 and not skipZ2S)
    if showHtfLead and bestHtfId >= 0
        if htfLeadId < 0 or not curStillVisible or bestHtfScore > curHtfScore + 8.0
            htfLeadId := bestHtfId
    else if not showHtfLead
        htfLeadId := -1

    leadZ1D = showHtfLead and htfLeadId == 1
    leadZ1S = showHtfLead and htfLeadId == 2
    leadZ2D = showHtfLead and htfLeadId == 3
    leadZ2S = showHtfLead and htfLeadId == 4

    if skipZ1D
        if not na(hz1d)
            box.delete(hz1d)
            hz1d := na
        if not na(hz1dL)
            label.delete(hz1dL)
            hz1dL := na
    else
        [b1d, l1d] = f_drawHtfZone(hz1d, hz1dL, z1Low, z1Band, false, leftRef, zoneTf1 + " D", leadZ1D)
        hz1d := b1d
        hz1dL := l1d
    if skipZ1S
        if not na(hz1s)
            box.delete(hz1s)
            hz1s := na
        if not na(hz1sL)
            label.delete(hz1sL)
            hz1sL := na
    else
        [b1s, l1s] = f_drawHtfZone(hz1s, hz1sL, z1High, z1Band, true, leftRef, zoneTf1 + " S", leadZ1S)
        hz1s := b1s
        hz1sL := l1s
    if skipZ2D
        if not na(hz2d)
            box.delete(hz2d)
            hz2d := na
        if not na(hz2dL)
            label.delete(hz2dL)
            hz2dL := na
    else
        [b2d, l2d] = f_drawHtfZone(hz2d, hz2dL, z2Low, z2Band, false, leftRef, zoneTf2 + " D", leadZ2D)
        hz2d := b2d
        hz2dL := l2d
    if skipZ2S
        if not na(hz2s)
            box.delete(hz2s)
            hz2s := na
        if not na(hz2sL)
            label.delete(hz2sL)
            hz2sL := na
    else
        [b2s, l2s] = f_drawHtfZone(hz2s, hz2sL, z2High, z2Band, true, leftRef, zoneTf2 + " S", leadZ2S)
        hz2s := b2s
        hz2sL := l2s

if barstate.islast and not showHtfZones
    if not na(hz1d)
        box.delete(hz1d)
        hz1d := na
    if not na(hz1s)
        box.delete(hz1s)
        hz1s := na
    if not na(hz2d)
        box.delete(hz2d)
        hz2d := na
    if not na(hz2s)
        box.delete(hz2s)
        hz2s := na
    if not na(hz1dL)
        label.delete(hz1dL)
        hz1dL := na
    if not na(hz1sL)
        label.delete(hz1sL)
        hz1sL := na
    if not na(hz2dL)
        label.delete(hz2dL)
        hz2dL := na
    if not na(hz2sL)
        label.delete(hz2sL)
        hz2sL := na

// Draw only the strongest N key zones (refreshed on the last bar to stay clean).
var box[]   kzBoxes = array.new_box()
var line[]  kzCrossLines = array.new_line()
var label[] kzLbls  = array.new_label()
var label[] kzDistLbls = array.new_label()
var label   kzLeadLbl = na
var label[] kzMajorLbls = array.new_label()
var box[]   prevCalBoxes = array.new_box()
var label[] prevCalLbls = array.new_label()
if barstate.islast
    if not na(kzLeadLbl)
        label.delete(kzLeadLbl)
        kzLeadLbl := na
    if array.size(kzMajorLbls) > 0
        for i = 0 to array.size(kzMajorLbls) - 1
            label.delete(array.get(kzMajorLbls, i))
        array.clear(kzMajorLbls)
    if array.size(kzBoxes) > 0
        for i = 0 to array.size(kzBoxes) - 1
            box.delete(array.get(kzBoxes, i))
        array.clear(kzBoxes)
    if array.size(kzCrossLines) > 0
        for i = 0 to array.size(kzCrossLines) - 1
            line.delete(array.get(kzCrossLines, i))
        array.clear(kzCrossLines)
    if array.size(kzLbls) > 0
        for i = 0 to array.size(kzLbls) - 1
            label.delete(array.get(kzLbls, i))
        array.clear(kzLbls)
    if array.size(kzDistLbls) > 0
        for i = 0 to array.size(kzDistLbls) - 1
            label.delete(array.get(kzDistLbls, i))
        array.clear(kzDistLbls)
    if array.size(prevCalBoxes) > 0
        for i = 0 to array.size(prevCalBoxes) - 1
            box.delete(array.get(prevCalBoxes, i))
        array.clear(prevCalBoxes)
    if array.size(prevCalLbls) > 0
        for i = 0 to array.size(prevCalLbls) - 1
            label.delete(array.get(prevCalLbls, i))
        array.clear(prevCalLbls)
    if showZones and (stickyZones ? array.size(szPrice) > 0 : array.size(kzPrice) > 0)
        leftCap = bar_index - 400
        leadApproachPct = adaptiveApproach ? math.max(approachInput, atrValue / close * 100 * 0.75) : approachInput
        priceFalling = close < close[3] or close < close[1]
        priceRising = close > close[3] or close > close[1]
        pathWantsDemand = regime == "bear" or (regime != "bull" and priceFalling)
        pathWantsSupply = regime == "bull" or (regime != "bear" and priceRising)

        // ── Sticky path: draw locked roster (no re-rank flicker) ──
        if stickyZones
            // LEAD among sticky only — hysteresis so the tag does not chatter on 1m.
            int bestLead = -1
            float bestLeadScore = -1e18
            for li = 0 to array.size(szPrice) - 1
                lp = array.get(szPrice, li)
                lSup = array.get(szSup, li)
                ls = array.get(szStr, li)
                lh = array.get(szHalf, li)
                inBand = f_priceInBand(lp, lh)
                sideOk = lSup ? lp > close : lp < close
                distAtr = atrValue > 0 ? math.abs(lp - close) / atrValue : 999.0
                if inBand or (sideOk and distAtr <= 6.0)
                    lScore = inBand ? 40.0 : (1.0 / (distAtr + 0.2)) * 28.0
                    lScore += float(ls * ls) * 0.35
                    onPath = (not lSup and pathWantsDemand) or (lSup and pathWantsSupply)
                    if onPath
                        lScore += 12
                    if array.get(szFlip, li)
                        lScore -= 8
                    // Untapped liquidity under/over the magnet = stronger LEAD (stops to clear).
                    if boostZonesWithLiq and f_zoneOnLiq(lp, lSup)
                        lScore += 18
                    // Same idea as LEAD boxes: the zone on LEAD LIQ becomes the structure LEAD.
                    if not na(liqDrawLvl) and math.abs(lp - liqDrawLvl) <= atrValue * 0.55
                        lScore += 28
                    if lScore > bestLeadScore
                        bestLeadScore := lScore
                        bestLead := li
            // Prefer sticky zone that sits on LEAD LIQ when scores are close.
            if not na(liqDrawLvl)
                for li = 0 to array.size(szPrice) - 1
                    if math.abs(array.get(szPrice, li) - liqDrawLvl) <= atrValue * 0.55
                        if bestLead < 0 or math.abs(array.get(szPrice, bestLead) - liqDrawLvl) > atrValue * 0.55
                            bestLead := li
                            break
            // Only switch LEAD if clearly better, or current lead gone / taken out.
            curLeadOk = szLeadIdx >= 0 and szLeadIdx < array.size(szPrice)
            if not curLeadOk
                szLeadIdx := bestLead
            else if bestLead >= 0 and bestLead != szLeadIdx
                curScore = 0.0
                clp = array.get(szPrice, szLeadIdx)
                cdist = atrValue > 0 ? math.abs(clp - close) / atrValue : 999.0
                curScore := f_priceInBand(clp, array.get(szHalf, szLeadIdx)) ? 40.0 : (1.0 / (cdist + 0.2)) * 28.0
                if bestLeadScore > curScore + 8.0
                    szLeadIdx := bestLead

            drawnAbove = 0
            drawnBelow = 0
            for best = 0 to array.size(szPrice) - 1
                p = array.get(szPrice, best)
                isS = array.get(szSup, best)
                strn = array.get(szStr, best)
                half = array.get(szHalf, best)
                flipped = array.get(szFlip, best)
                fstate = array.get(szFlipSt, best)
                obBoost = array.get(szOb, best)
                isObZone = useObZoneBoost and obBoost >= 1
                inBandNow = f_priceInBand(p, half)
                isLead = best == szLeadIdx
                onLiq = boostZonesWithLiq and f_zoneOnLiq(p, isS)
                onLeadLiq = not na(liqDrawLvl) and math.abs(p - liqDrawLvl) <= atrValue * 0.55
                sideRank = p > close ? drawnAbove : drawnBelow
                rank = isLead or inBandNow or onLeadLiq ? 0 : sideRank + 1
                isMajor = (strn >= 5 and ((not isS and htfDemandStacked) or (isS and htfSupplyStacked))) or (strn >= 4 and obBoost >= 2 and ((not isS and inHtfDemandZone) or (isS and inHtfSupplyZone))) or (onLiq and strn >= 4 and ((not isS and inHtfDemandZone) or (isS and inHtfSupplyZone)))
                lft = math.max(array.get(szLeft, best), leftCap)
                baseCol = flipped ? (isS ? supplyFlip : demandFlip) : (isS ? supplyBase : demandBase)
                tcol = f_zoneNeonColor(baseCol, isS, strn)
                brdCol = isMajor or onLeadLiq ? color.new(onLeadLiq ? liqDrawColor : majorZoneColor, 15) : f_zoneBorderColor(isS, strn, rank)
                if flipped and fstate == 2 and not isMajor and not onLeadLiq
                    brdCol := color.new(f_zoneBorderNeon(isS), math.max(0, f_zoneRankBorderTransp(strn, rank) - 8))
                lnStyle = (flipped and fstate < 2) ? line.style_dashed : line.style_solid
                brdWidth = 1
                drawAsBox = strn >= 4 or isLead or inBandNow or onLiq or onLeadLiq
                revFillCol = isS ? supplyBase : demandBase
                boxFillCol = (isMajor and showReversalZoneFill) ? revFillCol : onLeadLiq ? liqDrawColor : tcol
                if not drawAsBox
                    xMid = bar_index + 1
                    barSpan = f_zoneCrossSpan(strn, rank)
                    arm = half * f_zoneCrossArmMult(strn, rank)
                    array.push(kzCrossLines, line.new(xMid - barSpan, p, xMid + barSpan, p, color=brdCol, width=brdWidth, style=lnStyle))
                    array.push(kzCrossLines, line.new(xMid, p - arm, xMid, p + arm, color=brdCol, width=brdWidth, style=lnStyle))
                else
                    fillTransp = f_zoneFillTransp(strn, rank)
                    if flipped and fstate < 2
                        fillTransp := math.min(96, fillTransp + 4)
                    if inBandNow
                        fillTransp := math.min(fillTransp, isMajor and showReversalZoneFill ? 72 : 76)
                    else if isMajor and showReversalZoneFill
                        fillTransp := isLead ? 74 : 78
                    else if isMajor and showMajorGlow
                        fillTransp := math.max(80, fillTransp - 4)
                    else if isLead
                        fillTransp := math.max(76, fillTransp - 6)
                    if onLeadLiq
                        fillTransp := math.max(72, fillTransp - 8)
                    else if onLiq
                        fillTransp := math.max(70, fillTransp - 6)
                    bx = box.new(lft, p + half, bar_index + 3, p - half, bgcolor=color.new(boxFillCol, fillTransp), border_color=brdCol, border_width=brdWidth, border_style=lnStyle)
                    array.push(kzBoxes, bx)
                // One combined tag in the key lane — no floating % / separate LIQ pills.
                if isLead or onLeadLiq
                    leadTxt = onLeadLiq ? "LEAD LIQ" : "LEAD"
                    leadTxt += " x" + str.tostring(strn) + (isS ? " S" : " D")
                    if inBandNow
                        leadTxt += " · IN"
                    else if onLiq and not onLeadLiq
                        leadTxt += " · LIQ"
                    if showZoneDistancePct and not inBandNow
                        leadTxt += " · " + f_pctAwayText(p)
                    if isMajor
                        leadTxt += isS ? " · BEAR" : " · BULL"
                    if showObZoneTag and isObZone
                        leadTxt += " · OB"
                    kzLeadLbl := label.new(bar_index + lblLaneKey, p, leadTxt, color=color.new(onLeadLiq ? liqDrawColor : brdCol, 40), textcolor=color.white, style=label.style_label_left, size=size.tiny)
                else if isMajor
                    majTxt = (isS ? "MAJOR · BEAR" : "MAJOR · BULL") + (inBandNow ? " · IN" : "") + (onLiq ? " · LIQ" : "") + (showObZoneTag and isObZone ? " · OB" : "")
                    if showZoneDistancePct and not inBandNow
                        majTxt += " · " + f_pctAwayText(p)
                    majLblCol = isS ? supplyBase : demandBase
                    array.push(kzMajorLbls, label.new(bar_index + lblLaneKey, f_labelYNudge(p, sideRank), majTxt, color=color.new(majLblCol, 55), textcolor=majLblCol, style=label.style_label_left, size=size.tiny))
                else if showLabels
                    ftag = flipped ? (fstate == 2 ? " FLIP*" : " FLIP") : ""
                    obtag = showObZoneTag and isObZone ? " OB" : ""
                    intag = inBandNow ? " IN" : ""
                    liqtag = onLiq ? " LIQ" : ""
                    lb = label.new(bar_index + lblLaneKey, f_labelYNudge(p, sideRank + 1), (isS ? "SUPPLY x" : "DEMAND x") + str.tostring(strn) + ftag + obtag + intag + liqtag, color=color.new(tcol, 85), textcolor=color.white, style=label.style_label_left, size=size.tiny)
                    array.push(kzLbls, lb)
                if p > close
                    drawnAbove += 1
                else
                    drawnBelow += 1
        else
            // Legacy non-sticky re-rank path (off by default).
            int leadKzIdx = -1
            float leadBestScore = -1e18
            for li = 0 to array.size(kzPrice) - 1
                ls = array.get(kzStrength, li)
                if ls >= minZoneStrength
                    lp = array.get(kzPrice, li)
                    lSup = array.get(kzSupply, li)
                    distAtr = atrValue > 0 ? math.abs(lp - close) / atrValue : 999.0
                    sideOk = lSup ? lp > close : lp < close
                    if sideOk and distAtr <= 6.0
                        lScore = (1.0 / (distAtr + 0.2)) * 28.0 + float(ls * ls) * 0.35
                        if lScore > leadBestScore
                            leadBestScore := lScore
                            leadKzIdx := li
            prio = array.new_float(array.size(kzStrength))
            for i = 0 to array.size(kzStrength) - 1
                s = array.get(kzStrength, i)
                array.set(prio, i, s < minZoneStrength ? -1e18 : s * s * 0.5)
            if leadKzIdx >= 0
                array.set(prio, leadKzIdx, array.get(prio, leadKzIdx) + 1000.0)
            drawnAbove = 0
            drawnBelow = 0
            stackDist = atrValue * zoneStackMinMult
            drawnAbovePrices = array.new_float()
            drawnBelowPrices = array.new_float()
            keepGoing = true
            while keepGoing
                if drawnAbove >= maxZonesPerSide and drawnBelow >= maxZonesPerSide
                    keepGoing := false
                else
                    best = -1
                    float bestVal = -1e18
                    for i = 0 to array.size(prio) - 1
                        v = array.get(prio, i)
                        if v > bestVal
                            pp = array.get(kzPrice, i)
                            above = pp > close
                            sideOk = (above and drawnAbove < maxZonesPerSide) or (not above and drawnBelow < maxZonesPerSide)
                            if sideOk
                                tooClose = false
                                sidePrices = above ? drawnAbovePrices : drawnBelowPrices
                                if array.size(sidePrices) > 0
                                    for j = 0 to array.size(sidePrices) - 1
                                        if math.abs(pp - array.get(sidePrices, j)) < stackDist
                                            tooClose := true
                                if not tooClose
                                    bestVal := v
                                    best := i
                    if best == -1 or bestVal <= -1e17
                        keepGoing := false
                    else
                        p = array.get(kzPrice, best)
                        isS = array.get(kzSupply, best)
                        strn = array.get(kzStrength, best)
                        flipped = array.get(kzFlipped, best)
                        fstate = array.get(kzFlipState, best)
                        obBoost = array.get(kzObScore, best)
                        isObZone = useObZoneBoost and obBoost >= 1
                        isLead = best == leadKzIdx
                        sideRank = p > close ? drawnAbove : drawnBelow
                        rank = isLead ? 0 : sideRank + 1
                        isMajor = strn >= 5 and ((not isS and htfDemandStacked) or (isS and htfSupplyStacked))
                        lft = math.max(array.get(kzBar, best), leftCap)
                        half = atrValue * f_zoneHalfMult(strn)
                        baseCol = flipped ? (isS ? supplyFlip : demandFlip) : (isS ? supplyBase : demandBase)
                        tcol = f_zoneNeonColor(baseCol, isS, strn)
                        brdCol = isMajor ? color.new(majorZoneColor, 15) : f_zoneBorderColor(isS, strn, rank)
                        lnStyle = (flipped and fstate < 2) ? line.style_dashed : line.style_solid
                        drawAsBox = strn >= 4 or isLead
                        boxFillCol = (isMajor and showReversalZoneFill) ? (isS ? supplyBase : demandBase) : tcol
                        if not drawAsBox
                            xMid = bar_index + 1
                            array.push(kzCrossLines, line.new(xMid - 3, p, xMid + 3, p, color=brdCol, width=1, style=lnStyle))
                            array.push(kzCrossLines, line.new(xMid, p - half * 0.4, xMid, p + half * 0.4, color=brdCol, width=1, style=lnStyle))
                        else
                            fillTransp = f_zoneFillTransp(strn, rank)
                            if isMajor and showReversalZoneFill
                                fillTransp := 78
                            bx = box.new(lft, p + half, bar_index + 3, p - half, bgcolor=color.new(boxFillCol, fillTransp), border_color=brdCol, border_width=1, border_style=lnStyle)
                            array.push(kzBoxes, bx)
                        if isLead
                            kzLeadLbl := label.new(bar_index + 4, p, "LEAD x" + str.tostring(strn) + (isS ? " S" : " D"), color=color.new(brdCol, 45), textcolor=color.white, style=label.style_label_left, size=size.tiny)
                        if p > close
                            array.push(drawnAbovePrices, p)
                            drawnAbove += 1
                        else
                            array.push(drawnBelowPrices, p)
                            drawnBelow += 1
                        array.set(prio, best, -1e18)
        // Previous completed calendar-period zones (D/W/M/Q) as muted historical reference.
        if showPreviousZones
            f_drawPrevCalZone(prevDHi, calBand, colorCalDaily, true, "PREV D S", showPrevCalDaily, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevDLo, calBand, colorCalDaily, false, "PREV D D", showPrevCalDaily, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevWHi, calBand, colorCalWeekly, true, "PREV W S", showPrevCalWeekly, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevWLo, calBand, colorCalWeekly, false, "PREV W D", showPrevCalWeekly, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevMHi, calBand, colorCalMTD, true, "PREV M S", showPrevCalMTD, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevMLo, calBand, colorCalMTD, false, "PREV M D", showPrevCalMTD, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevQHi, calBand, colorCalQuarterly, true, "PREV Q S", showPrevCalQuarterly, prevCalBoxes, prevCalLbls)
            f_drawPrevCalZone(prevQLo, calBand, colorCalQuarterly, false, "PREV Q D", showPrevCalQuarterly, prevCalBoxes, prevCalLbls)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6: CANDLESTICK CONFIRMATION PATTERNS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Bullish Candlestick Patterns ──────────────────────────────────────────────
// Bullish engulfing: current candle body engulfs previous candle body
bullishEngulfing = close > open and close > high[1] and open < low[1]

// Hammer: small body at top, long lower wick (at least 2x body)
bodySize = math.abs(close - open)
lowerWick = open < close ? open - low : close - low
upperWick = open < close ? high - close : high - open
isHammer = bodySize > 0 and lowerWick > bodySize * 2 and upperWick < bodySize

// Bullish pin bar: close near high, long lower wick
bullishPinBar = close > open and (close - low) > (high - close) * 2 and close > (high + low) / 2

// Morning star (simplified: 3 candles)
morningStar = close[2] < open[2] and math.abs(close[1] - open[1]) < bodySize[2] * 0.5 and close > open and close > (high[2] + low[2]) / 2

bullishCandle = bullishEngulfing or isHammer or bullishPinBar or morningStar

// ─── Bearish Candlestick Patterns ──────────────────────────────────────────────
// Bearish engulfing: current candle body engulfs previous candle body
bearishEngulfing = close < open and close < low[1] and open > high[1]

// Shooting star: small body at bottom, long upper wick (at least 2x body)
isShootingStar = bodySize > 0 and upperWick > bodySize * 2 and lowerWick < bodySize

// Bearish pin bar: close near low, long upper wick
bearishPinBar = close < open and (high - close) > (close - low) * 2 and close < (high + low) / 2

// Evening star (simplified: 3 candles)
eveningStar = close[2] > open[2] and math.abs(close[1] - open[1]) < bodySize[2] * 0.5 and close < open and close < (high[2] + low[2]) / 2

bearishCandle = bearishEngulfing or isShootingStar or bearishPinBar or eveningStar

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7: MARKET CONTEXT (trend, momentum, zone proximity)
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Current Trend (Current TF) ────────────────────────────────────────────────
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

bullishTrend = ema20 > ema50 and close > ema20
bearishTrend = ema20 < ema50 and close < ema20
bullishRegime = close > ema200 and ema20 > ema200
bearishRegime = close < ema200 and ema20 < ema200
ema20BouncingUp = ema20 >= ema20[1]
ema20RollingOver = ema20 <= ema20[1]

// Bullish long context around moving-average reclaim/retest behavior.
bullishBias = ema20 > ema50
crossAbove200 = ta.crossover(close, ema200)
longFlip200 = crossAbove200 or (close > ema200 and close[1] <= ema200[1])
longRetest200 = bullishBias and low <= ema200 and close > ema200
longPullback20 = bullishBias and low <= ema20 and close > ema20 and ema20BouncingUp
longMASetup = longFlip200 or longRetest200 or longPullback20

// Bearish short context around the moving-average reclaim/retest behavior.
shortReclaim200 = bearishRegime and crossAbove200
shortReject200 = bearishRegime and high >= ema200 and close < ema200
shortAbove20And200 = bearishRegime and close > ema20 and close > ema200
shortMASetup = shortReclaim200 or shortReject200 or shortAbove20And200 or (bearishRegime and close > ema20 and ema20RollingOver)

// ─── RSI & Momentum ────────────────────────────────────────────────────────────
rsi = ta.rsi(close, 14)
rsiOversold = rsi < 35
rsiOverbought = rsi > 65
rsiNeutral = rsi >= 35 and rsi <= 65

// ─── MACD for Momentum Confirmation ──────────────────────────────────────────────
[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)
macdBullish = macdLine > signalLine and macdHist > 0
macdBearish = macdLine < signalLine and macdHist < 0

// ─── RSI Divergence (for reversal plays at strong zones) ───────────────────────
var float lastPLprice = na
var float prevPLprice = na
var float lastPLrsi = na
var float prevPLrsi = na
if not na(pivotLow)
    prevPLprice := lastPLprice
    prevPLrsi := lastPLrsi
    lastPLprice := pivotLow
    lastPLrsi := rsi[rightBars]

var float lastPHprice = na
var float prevPHprice = na
var float lastPHrsi = na
var float prevPHrsi = na
if not na(pivotHigh)
    prevPHprice := lastPHprice
    prevPHrsi := lastPHrsi
    lastPHprice := pivotHigh
    lastPHrsi := rsi[rightBars]

// Bullish div = lower price low but higher RSI low (fires on pivot confirmation)
bullDiv = not na(pivotLow) and not na(prevPLprice) and lastPLprice < prevPLprice and lastPLrsi > prevPLrsi
bearDiv = not na(pivotHigh) and not na(prevPHprice) and lastPHprice > prevPHprice and lastPHrsi < prevPHrsi

// Proximity to strong zones (where reversals are highest quality)
nearStrongDemand = not na(strongPivotLow) and math.abs(low - strongPivotLow) < atrValue
nearStrongSupply = not na(strongPivotHigh) and math.abs(high - strongPivotHigh) < atrValue

// Reversal triggers: divergence printed at a strong support/resistance
reversalLong = bullDiv and nearStrongDemand
reversalShort = bearDiv and nearStrongSupply

// ─── Distance to Nearest Zones ─────────────────────────────────────────────────
// Find nearest demand zone (below price) — pivots + key magnets
float nearestDemandDist = na
float nearestDemandLevel = na
for i = 0 to zoneLookback
    if not na(pivotLow[i])
        dist = (close - pivotLow[i]) / close * 100
        if dist > 0 and (na(nearestDemandDist) or dist < nearestDemandDist)
            nearestDemandDist := dist
            nearestDemandLevel := pivotLow[i]
if not na(nearestKeyBelow)
    keyDemandDist = (close - nearestKeyBelow) / close * 100
    if keyDemandDist > 0 and (na(nearestDemandDist) or keyDemandDist < nearestDemandDist)
        nearestDemandDist := keyDemandDist
        nearestDemandLevel := nearestKeyBelow

// Find nearest supply zone (above price) — pivots + key magnets
float nearestSupplyDist = na
float nearestSupplyLevel = na
for i = 0 to zoneLookback
    if not na(pivotHigh[i])
        dist = (pivotHigh[i] - close) / close * 100
        if dist > 0 and (na(nearestSupplyDist) or dist < nearestSupplyDist)
            nearestSupplyDist := dist
            nearestSupplyLevel := pivotHigh[i]
if not na(nearestKeyAbove)
    keySupplyDist = (nearestKeyAbove - close) / close * 100
    if keySupplyDist > 0 and (na(nearestSupplyDist) or keySupplyDist < nearestSupplyDist)
        nearestSupplyDist := keySupplyDist
        nearestSupplyLevel := nearestKeyAbove

// ─── Zone Approach Detection ───────────────────────────────────────────────────
// Fire when price is APPROACHING a zone (not just at it).
// On volatile symbols/high TFs a flat % is too tight, so widen it with ATR.
atrPct = atrValue / close * 100
approachThreshold = adaptiveApproach ? math.max(approachInput, atrPct * 0.75) : approachInput

approachingDemand = not na(nearestDemandDist) and nearestDemandDist < approachThreshold and nearestDemandDist > 0
approachingSupply = not na(nearestSupplyDist) and nearestSupplyDist < approachThreshold and nearestSupplyDist > 0

// ─── Directional Approach Filter ─────────────────────────────────────────────
// Only fire if price is moving TOWARD the zone (not oscillating sideways)
priceMovingTowardDemand = close < close[1]  // falling into demand
priceMovingTowardSupply = close > close[1]   // rising into supply

validDemandApproach = approachingDemand and priceMovingTowardDemand
validSupplyApproach = approachingSupply and priceMovingTowardSupply

// Magnet approach — price moving toward a proven key level (works on all TFs).
magnetDemandApproach = not na(nearestKeyBelow) and nearestKeyBelowStr >= minZoneStrength and (close - nearestKeyBelow) / close * 100 < approachThreshold and priceMovingTowardDemand
magnetSupplyApproach = not na(nearestKeyAbove) and nearestKeyAboveStr >= minZoneStrength and (nearestKeyAbove - close) / close * 100 < approachThreshold and priceMovingTowardSupply

// Zone interaction context (used by regime coloring).
bullSfpStrongZone = not na(strongPivotLow) and low < strongPivotLow and close > strongPivotLow and close > open and highVolume
bearSfpStrongZone = not na(strongPivotHigh) and high > strongPivotHigh and close < strongPivotHigh and close < open and highVolume
atZoneDemand = validDemandApproach or magnetDemandApproach or nearStrongDemand
atZoneSupply = validSupplyApproach or magnetSupplyApproach or nearStrongSupply
bullVolDivReversal = useVolDivConfluence and atZoneDemand and (bullVolSpike or bullDiv) and (rsiOversold or bullDiv or close > open)
bearVolDivReversal = useVolDivConfluence and atZoneSupply and (bearVolSpike or bearDiv) and (rsiOverbought or bearDiv or close < open)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7B: ZONE-AWARE REGIME COLORING (Chandelier/SuperTrend hybrid)
// ═══════════════════════════════════════════════════════════════════════════════
// Flips ONLY at opposing S/D zone + scored confluence on bar CLOSE. Non-repainting.

atDemandRegimeZone = inHtfDemandZone or nearStrongDemand or atZoneDemand or demandMagnetStrong
atSupplyRegimeZone = inHtfSupplyZone or nearStrongSupply or atZoneSupply or supplyMagnetStrong

wickRange = math.max(high - low, syminfo.mintick)
bullWickRejection = (close - low) / wickRange > 0.65 and close > open
bearWickRejection = (high - close) / wickRange > 0.60 and close < open

atDemandRevStrict = atDemandRegimeZone or atDemandRegimeZone[rightBars]
atSupplyRevStrict = atSupplyRegimeZone or atSupplyRegimeZone[rightBars]
bullDivAtZone = bullDiv and atDemandRevStrict
bearDivAtZone = bearDiv and atSupplyRevStrict

// Must be at a proven key magnet (not just broad HTF band). OB-boosted x3 magnets qualify.
// Tops get a slightly wider touch — supply wicks often spike through the band.
atKeyDemandMagnet = atDemandRevStrict and not na(nearestKeyBelow) and (nearestKeyBelowStr >= 4 or (nearestKeyBelowStr >= 3 and nearestKeyBelowOb >= 2)) and math.abs(low - nearestKeyBelow) <= atrValue * 0.65
atKeySupplyMagnet = atSupplyRevStrict and not na(nearestKeyAbove) and (nearestKeyAboveStr >= 4 or (nearestKeyAboveStr >= 3 and nearestKeyAboveOb >= 2)) and math.abs(high - nearestKeyAbove) <= atrValue * 0.85

bullLiqSweep = bullWickRejection and volSpike and atDemandRevStrict
bearLiqSweep = bearWickRejection and volSpike and atSupplyRevStrict

// ─── Ultimate Top / Bottom — climax rejection signaling potential trend flip ───
// Bottoms kept as-is (working well). Tops tuned for buying-climax / distribution prints.
ultBody = math.abs(close - open)
ultRange = math.max(high - low, syminfo.mintick)
ultUpperWick = high - math.max(open, close)
ultLowerWick = math.min(open, close) - low
ultSmallBody = ultBody / ultRange <= 0.35
// Upper-wick rejection: shooting star / pin / weak close — does NOT require a red candle.
ultTopWickReject = ultRange > 0 and ultUpperWick / ultRange >= 0.50 and ultUpperWick >= ultLowerWick * 1.4 and close <= (high + low) * 0.55
ultTopPattern = bearWickRejection or ultTopWickReject or isShootingStar or bearishPinBar
// Local rally into supply counts even if regime hasn't fully flipped bull yet.
ultHighestClose8 = ta.highest(close, 8)
ultHighestHigh12 = ta.highest(high, 12)
ultTopExtended = close > close[5] or close >= ultHighestClose8[1] or high >= ultHighestHigh12[1]
ultTopRegimeOk = regime == "bull" or (ultTopExtended and atSupplyRegimeZone)
// Softer exhaustion than bottoms — RSI often tops out earlier than 65 on crypto/alts.
ultTopExhaust = rsiOverbought or rsi >= 58 or bearDivAtZone or ultSmallBody or (ultUpperWick / ultRange >= 0.60)
ultTopVol = volSpike or bearVolSpike or relativeVolume >= volThreshold or (relativeVolume >= 1.15 and ultTopWickReject)
// Also allow HTF supply touch when key magnet is thin/missing on 1m.
ultTopAtSupply = atKeySupplyMagnet or (inHtfSupplyZone and not na(nearestKeyAbove) and math.abs(high - nearestKeyAbove) <= atrValue * 1.1)

ultBotCandle = regime == "bear" and atKeyDemandMagnet and bullWickRejection and (volSpike or bullVolSpike or relativeVolume >= volThreshold) and (rsiOversold or bullDivAtZone or ultSmallBody) and close > open
ultTopCandle = ultTopRegimeOk and ultTopAtSupply and ultTopPattern and ultTopVol and ultTopExhaust
ultBotFire = showUltFlipCandles and ultBotCandle and not ultBotCandle[1]
ultTopFire = showUltFlipCandles and ultTopCandle and not ultTopCandle[1]

// Regime confluence score — requires min hits so soft single factors cannot flip color.
bullRegimeScore =
     (bullSfpStrongZone ? 2 : 0)
     + (reversalLong ? 2 : 0)
     + (bullVolDivReversal ? 2 : 0)
     + (bullLiqSweep ? 2 : 0)
     + (ultBotCandle ? 2 : 0)
     + (bullVolSpike and atDemandRegimeZone ? 1 : 0)
     + (volSpike and atDemandRegimeZone and close > open ? 1 : 0)
     + (bullDivAtZone ? 1 : 0)
     + (longMASetup and atDemandRegimeZone ? 1 : 0)
     + (macdBullish and atDemandRegimeZone and close > open ? 1 : 0)
     + (bullishCandle and atDemandRegimeZone and close > open ? 1 : 0)
     + (demandObBoosted and atKeyDemandMagnet and close > open ? 1 : 0)
     + (rsiOversold and atDemandRegimeZone and close > open ? 1 : 0)
     + (useVectorInReversals and isBearClimax and atDemandRegimeZone ? 2 : 0)
     + (useVectorInReversals and (isBullClimax or isBullActive) and atDemandRegimeZone ? 2 : 0)
     + (useLiqInReversals and liqBullReclaim ? 2 : 0)

bearRegimeScore =
     (bearSfpStrongZone ? 2 : 0)
     + (reversalShort ? 2 : 0)
     + (bearVolDivReversal ? 2 : 0)
     + (bearLiqSweep ? 2 : 0)
     + (ultTopCandle ? 2 : 0)
     + (bearVolSpike and atSupplyRegimeZone ? 1 : 0)
     + (volSpike and atSupplyRegimeZone and close < open ? 1 : 0)
     + (bearDivAtZone ? 1 : 0)
     + (shortMASetup and atSupplyRegimeZone ? 1 : 0)
     + (macdBearish and atSupplyRegimeZone and close < open ? 1 : 0)
     + (bearishCandle and atSupplyRegimeZone and close < open ? 1 : 0)
     + (supplyObBoosted and atKeySupplyMagnet and close < open ? 1 : 0)
     + (rsiOverbought and atSupplyRegimeZone and close < open ? 1 : 0)
     + (useVectorInReversals and isBullClimax and atSupplyRegimeZone ? 2 : 0)
     + (useVectorInReversals and (isBearClimax or isBearActive) and atSupplyRegimeZone ? 2 : 0)
     + (useLiqInReversals and liqBearReclaim ? 2 : 0)

bullZoneRev = atDemandRegimeZone and bullRegimeScore >= minRegimeFlipScore and bullRegimeScore >= bearRegimeScore
bearZoneRev = atSupplyRegimeZone and bearRegimeScore >= minRegimeFlipScore and bearRegimeScore > bullRegimeScore

priorRegime = regime
if bullZoneRev
    regime := "bull"
else if bearZoneRev
    regime := "bear"

regimeFlipBull = bullZoneRev and priorRegime != "bull"
regimeFlipBear = bearZoneRev and priorRegime != "bear"

// BOS = first structure break from neutral; CHoCH = character change bull↔bear — marked with ×.
plotshape(showRegimeLabels and regimeFlipBull, title="Bull Regime Flip", style=shape.xcross, location=location.belowbar, color=regimeBullColor, size=size.tiny)
plotshape(showRegimeLabels and regimeFlipBear, title="Bear Regime Flip", style=shape.xcross, location=location.abovebar, color=regimeBearColor, size=size.tiny)

// Ultimate flip × — same overlay family as regime candle coloring (no text labels).
plotshape(showRegimeCandles and ultBotFire, title="Ultimate Bottom ×", style=shape.xcross, location=location.belowbar, color=ultBotColor, size=size.tiny)
plotshape(showRegimeCandles and ultTopFire, title="Ultimate Top ×", style=shape.xcross, location=location.abovebar, color=ultTopColor, size=size.tiny)

regimeFillCol = regime == "bull" ? color.new(regimeBullColor, 88) : regime == "bear" ? color.new(regimeBearColor, 88) : na

// Structural reversal signatures only — no generic candle patterns or sticky windows.
bullRevCore = bullSfpStrongZone or reversalLong or bullVolDivReversal or bullDivAtZone or ultBotCandle
bearRevCore = bearSfpStrongZone or reversalShort or bearVolDivReversal or bearDivAtZone or ultTopCandle

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7C: MAJOR REVERSAL RECOGNITION (S/D zone + OB + structural gate)
// ═══════════════════════════════════════════════════════════════════════════════

bullMajorZoneHit = atDemandRevStrict and (nearestKeyBelowStr >= 5 or (nearestKeyBelowStr >= 4 and nearestKeyBelowOb >= 2)) and htfDemandStacked
bearMajorZoneHit = atSupplyRevStrict and (nearestKeyAboveStr >= 5 or (nearestKeyAboveStr >= 4 and nearestKeyAboveOb >= 2)) and htfSupplyStacked

// Hard structural — SFP / liq sweep / elite div / ultimate flip at OB-boosted magnet.
bullHardStruct = bullSfpStrongZone or bullLiqSweep or (bullDivAtZone and demandMagnetElite) or (ultBotCandle and (demandObBoosted or nearestKeyBelowStr >= 4)) or (useVectorInReversals and isBearClimax and atKeyDemandMagnet) or (useLiqInReversals and liqBullReclaim and atKeyDemandMagnet)
bearHardStruct = bearSfpStrongZone or bearLiqSweep or (bearDivAtZone and supplyMagnetElite) or (ultTopCandle and (supplyObBoosted or nearestKeyAboveStr >= 4)) or (useVectorInReversals and isBullClimax and atKeySupplyMagnet) or (useLiqInReversals and liqBearReclaim and atKeySupplyMagnet)

bullStructNow = atKeyDemandMagnet and bullHardStruct
bearStructNow = atKeySupplyMagnet and bearHardStruct
bullStructFire = bullStructNow and not bullStructNow[1]
bearStructFire = bearStructNow and not bearStructNow[1]

// Reversal score — structural + OB boost (candle patterns stay out of diamonds).
bullRevScore = (bullLiqSweep ? 2 : 0)
             + (bullSfpStrongZone ? 2 : 0)
             + (bullDivAtZone and demandMagnetElite ? 2 : 0)
             + (bullMajorZoneHit ? 2 : 0)
             + (inHtfDemandZone ? 1 : 0)
             + (regimeFlipBull ? 2 : 0)
             + (demandObBoosted ? 1 : 0)
             + (nearestKeyBelowOb >= 2 ? 1 : 0)
             + (ultBotCandle ? 2 : 0)
             + (useVectorInReversals and isBearClimax and atDemandRegimeZone ? 2 : 0)
             + (useVectorInReversals and (isBullClimax or isBullActive) and atDemandRegimeZone ? 1 : 0)
             + (useLiqInReversals and liqBullReclaim ? 2 : 0)
             + (boostZonesWithLiq and not na(nearestKeyBelow) and f_zoneOnLiq(nearestKeyBelow, false) ? 1 : 0)

bearRevScore = (bearLiqSweep ? 2 : 0)
             + (bearSfpStrongZone ? 2 : 0)
             + (bearDivAtZone and supplyMagnetElite ? 2 : 0)
             + (bearMajorZoneHit ? 2 : 0)
             + (inHtfSupplyZone ? 1 : 0)
             + (regimeFlipBear ? 2 : 0)
             + (supplyObBoosted ? 1 : 0)
             + (nearestKeyAboveOb >= 2 ? 1 : 0)
             + (ultTopCandle ? 2 : 0)
             + (useVectorInReversals and isBullClimax and atSupplyRegimeZone ? 2 : 0)
             + (useVectorInReversals and (isBearClimax or isBearActive) and atSupplyRegimeZone ? 1 : 0)
             + (useLiqInReversals and liqBearReclaim ? 2 : 0)
             + (boostZonesWithLiq and not na(nearestKeyAbove) and f_zoneOnLiq(nearestKeyAbove, true) ? 1 : 0)

revScore = math.max(bullRevScore, bearRevScore)
// If score is purely from a regime flip with no other confluence, require at least zone context.
scoreWithZoneContext = (bullRevScore > 0 and atDemandRegimeZone) or (bearRevScore > 0 and atSupplyRegimeZone)
revScore := scoreWithZoneContext ? revScore : 0

isMajorBullRev = bullStructFire and bullHardStruct and bullRevScore >= minMajorReversalScore and bullRevScore >= bearRevScore
isMajorBearRev = bearStructFire and bearHardStruct and bearRevScore >= minMajorReversalScore and bearRevScore > bullRevScore
isMajorReversal = isMajorBullRev or isMajorBearRev
regimeRevCandle = colorMajorRevWhite and isMajorReversal
revCandleCol = regimeReversalColor

// Liq Sweep proxy markers (optional).
plotshape(showLiqSweepMarks and bullLiqSweep, title="Bull Liq Sweep Proxy", style=shape.triangleup, location=location.belowbar, color=color.new(regimeBullColor, 0), size=size.tiny)
plotshape(showLiqSweepMarks and bearLiqSweep, title="Bear Liq Sweep Proxy", style=shape.triangledown, location=location.abovebar, color=color.new(regimeBearColor, 0), size=size.tiny)

validBullRevSignal = isMajorBullRev
validBearRevSignal = isMajorBearRev

plotshape(showReversalDiamonds and showBullReversalDiamond and validBullRevSignal, title="Bull Reversal Diamond", style=shape.diamond, location=location.belowbar, color=bullSignalColor, size=size.tiny)
plotshape(showReversalDiamonds and showBearReversalDiamond and validBearRevSignal, title="Bear Reversal Diamond", style=shape.diamond, location=location.abovebar, color=bearSignalColor, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8: TRADE VISUALIZER (one active trade at a time)
// ═══════════════════════════════════════════════════════════════════════════════
// Simulates one position per direction from major-reversal signals. No new
// position is opened until the active one is stopped, invalidated, or hits TP.
// Draws entry/SL/TP lines + a risk box and keeps a short history of past trades.

var bool   inTrade = false
var bool   tradeLong = false
var float  tradeEntry = na
var float  tradeSL = na
var float  tradeTP = na
var int    tradeEntryBar = na
var int    tradeExitBar = na
var line   tradeEntryLine = na
var line   tradeSLLine = na
var line   tradeTPLine = na
var label  tradeEntryLabel = na
var box    tradeRiskBox = na

var line[]  histEntryLines = array.new_line()
var line[]  histSLLines = array.new_line()
var line[]  histTPLines = array.new_line()
var label[] histExitLabels = array.new_label()
maxHistTrades = 20
tradeDrawAhead = 50

// Pre-calculate swing levels so ta.lowest/ta.highest are called on every bar (Pine consistency warning CW10003).
swingLow = ta.lowest(low, tradeSwingLookback)
swingHigh = ta.highest(high, tradeSwingLookback)

if showTradeVisualizer
    // ─── Check existing trade for exit ───
    bool closedThisBar = false

    // Clear history if history display is disabled
    if not showTradeHistory
        while array.size(histEntryLines) > 0
            line.delete(array.shift(histEntryLines))
            line.delete(array.shift(histSLLines))
            line.delete(array.shift(histTPLines))
            label.delete(array.shift(histExitLabels))

    if inTrade
        if tradeLong
            if low <= tradeSL
                // SL hit
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (tradeSL - tradeEntry) / tradeEntry * 100
                lbl = label.new(bar_index + 1, tradeSL, "LONG SL · " + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBearColor, 30), textcolor=color.white, style=label.style_label_up, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true
            else if high >= tradeTP
                // TP hit
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (tradeTP - tradeEntry) / tradeEntry * 100
                lbl = label.new(bar_index + 1, tradeTP, "LONG TP · +" + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBullColor, 30), textcolor=color.white, style=label.style_label_up, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true
            else if isMajorBearRev and bearRevScore >= bullRevScore
                // Invalidated by opposite signal
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (close - tradeEntry) / tradeEntry * 100
                lbl = label.new(bar_index + 1, close, "LONG INVALID · " + (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBearColor, 30), textcolor=color.white, style=label.style_label_up, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true
        else
            // Short trade
            if high >= tradeSL
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (tradeEntry - tradeSL) / tradeEntry * 100
                lbl = label.new(bar_index + 1, tradeSL, "SHORT SL · " + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBearColor, 30), textcolor=color.white, style=label.style_label_down, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true
            else if low <= tradeTP
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (tradeEntry - tradeTP) / tradeEntry * 100
                lbl = label.new(bar_index + 1, tradeTP, "SHORT TP · +" + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBullColor, 30), textcolor=color.white, style=label.style_label_down, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true
            else if isMajorBullRev and bullRevScore >= bearRevScore
                if not na(tradeEntryLine)
                    line.set_x2(tradeEntryLine, bar_index)
                if not na(tradeSLLine)
                    line.set_x2(tradeSLLine, bar_index)
                if not na(tradeTPLine)
                    line.set_x2(tradeTPLine, bar_index)
                pnl = (tradeEntry - close) / tradeEntry * 100
                lbl = label.new(bar_index + 1, close, "SHORT INVALID · " + (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.##") + "%", color=color.new(regimeBearColor, 30), textcolor=color.white, style=label.style_label_down, size=size.small)
                if showTradeHistory
                    array.push(histExitLabels, lbl)
                    array.push(histEntryLines, tradeEntryLine)
                    array.push(histSLLines, tradeSLLine)
                    array.push(histTPLines, tradeTPLine)
                else
                    label.delete(lbl)
                    line.delete(tradeEntryLine)
                    line.delete(tradeSLLine)
                    line.delete(tradeTPLine)
                inTrade := false
                closedThisBar := true

        // Prune old history after closing
        if array.size(histEntryLines) > maxHistTrades
            line.delete(array.shift(histEntryLines))
            line.delete(array.shift(histSLLines))
            line.delete(array.shift(histTPLines))
            label.delete(array.shift(histExitLabels))

    // ─── Open new trade if flat and a major reversal fires ───
    if not inTrade and not closedThisBar
        if isMajorBullRev and bullRevScore >= minMajorReversalScore
            entry = close
            sl = tradeStopType == "Swing" ? swingLow - atrValue * 0.2 : entry - atrValue * tradeStopAtrMult
            risk = entry - sl
            tp = entry + risk * tradeRiskReward
            inTrade := true
            tradeLong := true
            tradeEntry := entry
            tradeSL := sl
            tradeTP := tp
            tradeEntryBar := bar_index
            tradeEntryLine := line.new(bar_index, entry, bar_index + tradeDrawAhead, entry, color=color.new(regimeBullColor, 0), style=line.style_solid, width=1)
            tradeSLLine := line.new(bar_index, sl, bar_index + tradeDrawAhead, sl, color=color.new(color.red, 0), style=line.style_dashed, width=1)
            tradeTPLine := line.new(bar_index, tp, bar_index + tradeDrawAhead, tp, color=color.new(color.green, 0), style=line.style_solid, width=1)
            tradeRiskBox := box.new(bar_index, sl, bar_index + tradeDrawAhead, tp, bgcolor=color.new(regimeBullColor, 92), border_color=color.new(regimeBullColor, 60), border_width=1)
            tradeEntryLabel := label.new(bar_index, entry, "LONG ENTRY", color=color.new(regimeBullColor, 25), textcolor=color.white, style=label.style_label_up, size=size.small)
        else if isMajorBearRev and bearRevScore >= minMajorReversalScore
            entry = close
            sl = tradeStopType == "Swing" ? swingHigh + atrValue * 0.2 : entry + atrValue * tradeStopAtrMult
            risk = sl - entry
            tp = entry - risk * tradeRiskReward
            inTrade := true
            tradeLong := false
            tradeEntry := entry
            tradeSL := sl
            tradeTP := tp
            tradeEntryBar := bar_index
            tradeEntryLine := line.new(bar_index, entry, bar_index + tradeDrawAhead, entry, color=color.new(regimeBearColor, 0), style=line.style_solid, width=1)
            tradeSLLine := line.new(bar_index, sl, bar_index + tradeDrawAhead, sl, color=color.new(color.red, 0), style=line.style_dashed, width=1)
            tradeTPLine := line.new(bar_index, tp, bar_index + tradeDrawAhead, tp, color=color.new(color.green, 0), style=line.style_solid, width=1)
            tradeRiskBox := box.new(bar_index, sl, bar_index + tradeDrawAhead, tp, bgcolor=color.new(regimeBearColor, 92), border_color=color.new(regimeBearColor, 60), border_width=1)
            tradeEntryLabel := label.new(bar_index, entry, "SHORT ENTRY", color=color.new(regimeBearColor, 25), textcolor=color.white, style=label.style_label_down, size=size.small)

    // ─── Extend active trade objects into the future ───
    if inTrade
        if not na(tradeEntryLine)
            line.set_x2(tradeEntryLine, bar_index + tradeDrawAhead)
        if not na(tradeSLLine)
            line.set_x2(tradeSLLine, bar_index + tradeDrawAhead)
        if not na(tradeTPLine)
            line.set_x2(tradeTPLine, bar_index + tradeDrawAhead)
        if not na(tradeRiskBox)
            box.set_lefttop(tradeRiskBox, bar_index, tradeTP)
            box.set_rightbottom(tradeRiskBox, bar_index + tradeDrawAhead, tradeSL)
        if not na(tradeEntryLabel)
            label.set_xy(tradeEntryLabel, bar_index - 2, tradeEntry)

// ─── Cleanup when visualizer disabled ───
if not showTradeVisualizer
    if not na(tradeEntryLine)
        line.delete(tradeEntryLine)
        tradeEntryLine := na
    if not na(tradeSLLine)
        line.delete(tradeSLLine)
        tradeSLLine := na
    if not na(tradeTPLine)
        line.delete(tradeTPLine)
        tradeTPLine := na
    if not na(tradeRiskBox)
        box.delete(tradeRiskBox)
        tradeRiskBox := na
    if not na(tradeEntryLabel)
        label.delete(tradeEntryLabel)
        tradeEntryLabel := na
    while array.size(histEntryLines) > 0
        line.delete(array.shift(histEntryLines))
        line.delete(array.shift(histSLLines))
        line.delete(array.shift(histTPLines))
        label.delete(array.shift(histExitLabels))
    inTrade := false

// ADX + DMI + price structure — global scope for conviction meter.
[diPlus, diMinus, adxValue] = ta.dmi(adxLength, adxLength)
adxStrong = adxValue >= adxStrongThreshold

hh = ta.pivothigh(high, 3, 3)
ll = ta.pivotlow(low, 3, 3)
var float lastHH = na
var float lastLL = na
if not na(hh)
    lastHH := hh
if not na(ll)
    lastLL := ll

bullStructure = not na(lastHH) and not na(lastLL) and lastHH > nz(lastHH[1]) and lastLL > nz(lastLL[1])
bearStructure = not na(lastHH) and not na(lastLL) and lastHH < nz(lastHH[1]) and lastLL < nz(lastLL[1])

// Finite trend-score components (each 0/1) for candle-tier classification.
scoreBullAdx = useAdxTrendFilter ? (adxStrong and diPlus > diMinus ? 1 : 0) : 1
scoreBullHtf = htfBullish ? 1 : 0
scoreBullMacd = macdBullish ? 1 : 0
scoreBullRsi = rsi > 50 ? 1 : 0
scoreBullVol = highVolume ? 1 : 0
scoreBullStructure = trendRequirePriceStructure ? (bullStructure ? 1 : 0) : 0

scoreBearAdx = useAdxTrendFilter ? (adxStrong and diMinus > diPlus ? 1 : 0) : 1
scoreBearHtf = htfBearish ? 1 : 0
scoreBearMacd = macdBearish ? 1 : 0
scoreBearRsi = rsi < 50 ? 1 : 0
scoreBearVol = highVolume ? 1 : 0
scoreBearStructure = trendRequirePriceStructure ? (bearStructure ? 1 : 0) : 0

bullTrendScore = scoreBullAdx + scoreBullHtf + scoreBullMacd + scoreBullRsi + scoreBullVol + scoreBullStructure
bearTrendScore = scoreBearAdx + scoreBearHtf + scoreBearMacd + scoreBearRsi + scoreBearVol + scoreBearStructure

// Finite thresholds: 5+ confirmations = strong, otherwise noise.
strongBullTrend = regime == "bull" and bullTrendScore >= 5 and bullTrendScore > bearTrendScore
strongBearTrend = regime == "bear" and bearTrendScore >= 5 and bearTrendScore > bullTrendScore

// Candles stay trend-colored for the full regime until flip.
// Conviction only changes how vivid — never drops back to grey mid-trend.
regimeShallowNeutral = color.new(#4A4A4A, 0)
regimeBullBar = color.new(regimeBullColor, showConvictionTiers ? 0 : 45)
regimeBearBar = color.new(regimeBearColor, showConvictionTiers ? 0 : 45)
regimeBarCol = regime == "bull" ? regimeBullBar : regime == "bear" ? regimeBearBar : regimeShallowNeutral

// Priority: ultimate flip candle (UT/UB) → optional major-rev white → vector candle colors (if enabled) → persistent regime color.
// UT/UB are part of the same candle overlay — painted bar + × mark, no separate labels.
paintUltBot = showUltFlipCandles and ultBotCandle
paintUltTop = showUltFlipCandles and ultTopCandle

vectorCandleCol = isBullClimax ? vectorClimaxBullCol :
                  isBearClimax ? vectorClimaxBearCol :
                  isBullActive ? vectorActiveBullCol :
                  isBearActive ? vectorActiveBearCol : na

candlePaintCol = paintUltBot ? color.new(ultBotColor, 0) :
                 paintUltTop ? color.new(ultTopColor, 0) :
                 regimeRevCandle ? revCandleCol :
                 (showVectorCandles and not na(vectorCandleCol)) ? vectorCandleCol :
                 regimeBarCol

barcolor(showRegimeCandles ? candlePaintCol : na, title="Regime Candles")

// ─── Trend Background & Banner ───────────────────────────────────────────────
trendBgColor = showTrendBg ? (strongBullTrend ? color.new(regimeBullColor, 92) : strongBearTrend ? color.new(regimeBearColor, 92) : regime == "bull" ? color.new(regimeBullColor, 96) : regime == "bear" ? color.new(regimeBearColor, 96) : na) : na
bgcolor(trendBgColor, title="Trend Background")

var table trendBanner = table.new(position.top_left, 1, 1, bgcolor=color.new(color.black, 80), border_color=color.new(color.gray, 50), frame_width=1)
if showTrendBanner and barstate.islast
    bannerText = strongBullTrend ? "▲ UPTREND" : strongBearTrend ? "▼ DOWNTREND" : regime == "bull" ? "▲ BULLISH BIAS" : regime == "bear" ? "▼ BEARISH BIAS" : "— NEUTRAL"
    bannerCol = strongBullTrend ? color.new(regimeBullColor, 70) : strongBearTrend ? color.new(regimeBearColor, 70) : regime == "bull" ? color.new(regimeBullColor, 85) : regime == "bear" ? color.new(regimeBearColor, 85) : color.new(color.gray, 85)
    table.cell(trendBanner, 0, 0, "   " + bannerText + "   ", text_color=color.white, text_size=size.large, bgcolor=bannerCol)
else if not showTrendBanner and barstate.islast and not na(trendBanner)
    table.cell(trendBanner, 0, 0, "", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))

plot(showTrendLine ? close : na, "Trend Line", color=regimeBarCol, linewidth=1, style=plot.style_line)

htfAlignedToRegime = (regime == "bull" and htfBullish) or (regime == "bear" and htfBearish)
macdAlignedToRegime = (regime == "bull" and macdBullish) or (regime == "bear" and macdBearish)
volConfirmingRegime = (regime == "bull" and highVolume) or (regime == "bear" and highVolume)
rsiSupportingRegime = (regime == "bull" and rsi > 50) or (regime == "bear" and rsi < 50)
adxAlignedToRegime = (regime == "bull" and diPlus > diMinus and adxStrong) or (regime == "bear" and diMinus > diPlus and adxStrong)
structureAlignedToRegime = (regime == "bull" and bullStructure) or (regime == "bear" and bearStructure)
convictionScore = (htfAlignedToRegime ? 17 : 0) + (macdAlignedToRegime ? 17 : 0) + (volConfirmingRegime ? 17 : 0) + (rsiSupportingRegime ? 17 : 0) + (adxAlignedToRegime ? 16 : 0) + (structureAlignedToRegime ? 16 : 0)

// ─── Session Background Shading (very high transparency) ─────────────────────────
// London/NY overlap gets a blended tint so the two windows never visually clash.
londonBgColor = color.new(#1E88E5, 96)
nyBgColor = color.new(#FF8F00, 96)
overlapBgColor = color.new(#9C27B0, 96)
sessionBgCol = showSessionShading ? (inLondon and inNY ? overlapBgColor : inLondon ? londonBgColor : inNY ? nyBgColor : na) : na
bgcolor(sessionBgCol, title="Session Shading")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9: INFO PANEL (Top Right)
// ═══════════════════════════════════════════════════════════════════════════════

if showInfoPanel and barstate.islast
    // ── Composite bias (combines trend, HTF, MACD, 200-EMA regime) ──
    biasScore = (bullishTrend ? 1 : 0) + (htfBullish and useMTF ? 1 : 0) + (macdBullish ? 1 : 0) + (close > ema200 ? 1 : 0) - (bearishTrend ? 1 : 0) - (htfBearish and useMTF ? 1 : 0) - (macdBearish ? 1 : 0) - (close < ema200 ? 1 : 0)
    biasText = biasScore >= 2 ? "BULLISH" : biasScore <= -2 ? "BEARISH" : "MIXED"
    biasColor = biasScore >= 2 ? color.rgb(57, 255, 20) : biasScore <= -2 ? color.rgb(255, 64, 96) : color.rgb(200, 200, 80)
    headerColor = biasScore >= 2 ? color.new(color.green, 70) : biasScore <= -2 ? color.new(color.red, 70) : color.new(color.gray, 70)

    var table infoPanel = table.new(position.top_right, 2, 14,
                                   bgcolor=color.new(#0a0e1a, 8),
                                   border_color=color.new(color.gray, 60), border_width=1,
                                   frame_color=color.new(color.gray, 40), frame_width=1)

    // ── Header: symbol + live bias ──
    table.cell(infoPanel, 0, 0, "  BREAKOUT · " + syminfo.ticker + " · " + timeframe.period + "  ", text_color=color.white, text_size=size.small, bgcolor=headerColor)
    table.cell(infoPanel, 1, 0, "  " + biasText + "  ", text_color=biasColor, text_size=size.small, bgcolor=headerColor)

    // ── Bias breakdown ──
    table.cell(infoPanel, 0, 1, "BIAS", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(color.gray, 85))
    table.cell(infoPanel, 1, 1, "200EMA " + (close > ema200 ? "ABOVE" : "BELOW"), text_color=close > ema200 ? color.green : color.red, text_size=size.tiny, bgcolor=color.new(color.gray, 85))

    table.cell(infoPanel, 0, 2, "Trend " + timeframe.period, text_color=color.gray, text_size=size.tiny)
    trendText = bullishTrend ? "BULLISH" : bearishTrend ? "BEARISH" : "NEUTRAL"
    trendColor = bullishTrend ? color.green : bearishTrend ? color.red : color.gray
    table.cell(infoPanel, 1, 2, trendText, text_color=trendColor, text_size=size.tiny)

    table.cell(infoPanel, 0, 3, "Trend HTF " + (useMTF ? mtfHigher : "off"), text_color=color.gray, text_size=size.tiny)
    htfTrendText = not useMTF ? "OFF" : htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL"
    htfTrendColor = not useMTF ? color.gray : htfBullish ? color.green : htfBearish ? color.red : color.gray
    table.cell(infoPanel, 1, 3, htfTrendText, text_color=htfTrendColor, text_size=size.tiny)

    table.cell(infoPanel, 0, 4, "RSI / MACD", text_color=color.gray, text_size=size.tiny)
    rsiColor = rsi < 35 ? color.green : rsi > 65 ? color.red : color.silver
    macdShort = macdBullish ? "▲" : macdBearish ? "▼" : "—"
    table.cell(infoPanel, 1, 4, str.tostring(rsi, "#.") + "  " + macdShort, text_color=rsiColor, text_size=size.tiny)

    table.cell(infoPanel, 0, 5, "Volume", text_color=color.gray, text_size=size.tiny)
    volColor = volSpike ? color.orange : highVolume ? color.green : color.gray
    divTag = bullDiv ? " +divB" : bearDiv ? " +divR" : ""
    spikeTag = volSpike ? " SPIKE" : ""
    table.cell(infoPanel, 1, 5, str.tostring(relativeVolume, "#.##") + "x" + spikeTag + divTag, text_color=volColor, text_size=size.tiny)

    // ── Key levels & liquidity ──
    table.cell(infoPanel, 0, 6, "LEVELS", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(color.gray, 85))
    table.cell(infoPanel, 1, 6, "magnet / liquidity", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.gray, 85))

    table.cell(infoPanel, 0, 7, "Key Supply", text_color=color.gray, text_size=size.tiny)
    supTxt = na(nearestKeyAbove) ? "—" : str.tostring(nearestKeyAbove, format.mintick) + "  x" + str.tostring(nearestKeyAboveStr) + (nearestKeyAboveOb >= 1 ? " OB" : "")
    table.cell(infoPanel, 1, 7, supTxt, text_color=color.rgb(255, 120, 120), text_size=size.tiny)

    table.cell(infoPanel, 0, 8, "Key Demand", text_color=color.gray, text_size=size.tiny)
    demTxt = na(nearestKeyBelow) ? "—" : str.tostring(nearestKeyBelow, format.mintick) + "  x" + str.tostring(nearestKeyBelowStr) + (nearestKeyBelowOb >= 1 ? " OB" : "")
    table.cell(infoPanel, 1, 8, demTxt, text_color=color.rgb(120, 255, 120), text_size=size.tiny)

    table.cell(infoPanel, 0, 9, "Liq BSL/SSL", text_color=color.gray, text_size=size.tiny)
    liqTxt = useLiqMagnet ? ((na(magnetBsl) ? "—" : str.tostring(magnetBsl, format.mintick)) + " / " + (na(magnetSsl) ? "—" : str.tostring(magnetSsl, format.mintick))) : ((na(liqAboveLevel) ? "—" : str.tostring(liqAboveLevel, format.mintick)) + " / " + (na(liqBelowLevel) ? "—" : str.tostring(liqBelowLevel, format.mintick)))
    table.cell(infoPanel, 1, 9, liqTxt, text_color=useLiqMagnet ? liqDrawColor : color.yellow, text_size=size.tiny)

    table.cell(infoPanel, 0, 10, "LEAD LIQ", text_color=color.gray, text_size=size.tiny)
    drawTxt = not useLiqMagnet ? "OFF" : na(liqDrawLvl) ? "—" : str.tostring(liqDrawLvl, format.mintick) + " · " + f_pctAwayText(liqDrawLvl)
    table.cell(infoPanel, 1, 10, drawTxt, text_color=liqDrawColor, text_size=size.tiny)

    // ── HTF zone status ──
    table.cell(infoPanel, 0, 11, "HTF Zone " + zoneTf1 + "/" + zoneTf2, text_color=color.gray, text_size=size.tiny)
    htfZoneTxt = not showHtfZones ? "OFF" : inHtfDemandZone and inHtfSupplyZone ? "BOTH" : inHtfDemandZone ? (htfDemandStacked ? "DEMAND++" : "DEMAND") : inHtfSupplyZone ? (htfSupplyStacked ? "SUPPLY++" : "SUPPLY") : "—"
    htfZoneColor = not showHtfZones ? color.gray : inHtfDemandZone ? color.green : inHtfSupplyZone ? color.red : color.gray
    table.cell(infoPanel, 1, 11, htfZoneTxt, text_color=htfZoneColor, text_size=size.tiny)

    // ── Trend Strength / Conviction meter ──
    convictionMeterColor = color.from_gradient(convictionScore, 0, 100, color.gray, regime == "bull" ? regimeBullColor : regime == "bear" ? regimeBearColor : color.gray)
    table.cell(infoPanel, 0, 12, "Conviction", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(color.gray, 85))
    table.cell(infoPanel, 1, 12, str.tostring(convictionScore) + "/100", text_color=convictionMeterColor, text_size=size.tiny, bgcolor=color.new(color.gray, 85))

    // ── Footer: session + regime ──
    sessColor = inSession ? color.green : color.gray
    regimeTxt = regime == "bull" ? "BULL" : regime == "bear" ? "BEAR" : "NEUTRAL"
    regimeCol = regime == "bull" ? regimeBullColor : regime == "bear" ? regimeBearColor : color.gray
    table.cell(infoPanel, 0, 13, sessionName, text_color=sessColor, text_size=size.tiny, bgcolor=color.new(color.gray, 90))
    table.cell(infoPanel, 1, 13, regimeTxt, text_color=regimeCol, text_size=size.tiny, bgcolor=color.new(color.gray, 90))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10: ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Alert Conditions ──────────────────────────────────────────────────────────
alertcondition(alertZoneFlip and zoneFlipEvent,
             "Breakout Zone Flipped",
             "{{ticker}} key S/D zone flipped role on {{interval}}")

alertcondition(isMajorReversal,
             "Breakout Major Reversal",
             "{{ticker}} major reversal on {{interval}}")

alertcondition(bullLiqSweep or bearLiqSweep,
             "Breakout Liq Sweep Proxy",
             "{{ticker}} inferred liq sweep on {{interval}}")

alertcondition(ultBotFire,
             "Breakout Ultimate Bottom",
             "{{ticker}} ultimate bottom (potential bull flip) on {{interval}}")

alertcondition(ultTopFire,
             "Breakout Ultimate Top",
             "{{ticker}} ultimate top (potential bear flip) on {{interval}}")

alertcondition(regimeFlipBull or regimeFlipBear,
             "Breakout Regime Flip",
             "{{ticker}} regime flipped on {{interval}}")

alertcondition(liqBullReclaim or liqBearReclaim,
             "Breakout Liq Sweep Reclaim",
             "{{ticker}} liquidity sweep-reclaim on {{interval}}")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11: EMA PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

// EMA overlays — off by default (toggle in Display settings).
plot(showEMAs ? ema20 : na, "MA 20", color=color.new(#39FF14, 35), linewidth=1, style=plot.style_line)
plot(showEMAs ? ema50 : na, "MA 50", color=color.new(#FFFFFF, 40), linewidth=1, style=plot.style_line)
plot(showEMAs ? ema200 : na, "MA 200", color=color.new(#BF00FF, 35), linewidth=1, style=plot.style_line)

// Regime ribbon cloud — EMA 20/50 fill tinted by persistent zone-aware regime.
regimeCloudEma20 = plot(showRegimeCloud ? ema20 : na, "Regime Cloud EMA20", color=color.new(color.gray, 100), linewidth=1, display=display.none)
regimeCloudEma50 = plot(showRegimeCloud ? ema50 : na, "Regime Cloud EMA50", color=color.new(color.gray, 100), linewidth=1, display=display.none)
fill(regimeCloudEma20, regimeCloudEma50, color=showRegimeCloud ? regimeFillCol : na, title="Regime Ribbon Cloud")

// Volume histogram colored by regime. Pine v6 restricts one indicator script to a single pane,
// so this overlays on the price pane; for a true detached volume pane use a companion non-overlay script.
volumeHistColor = regime == "bull" ? regimeBullColor : regime == "bear" ? regimeBearColor : color.gray
plot(showRegimeVolume ? volume : na, title="Regime Volume", style=plot.style_histogram, color=color.new(volumeHistColor, 50))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12: PRICE SCALE FIX - Prevent chart zoom issues
// ═══════════════════════════════════════════════════════════════════════════════

// TradingView auto-fit gets confused when objects extend far into future.
// We use a transparent plot at current price to anchor the scale.
// Also add explicit price scale hint
plot(close, "Price Anchor", color=color.new(color.gray, 100), display=display.none)

// Force price scale to stay within reasonable bounds by plotting invisible lines at current ATR range
plot(close + atrValue * 3, "Upper Scale Limit", color=color.new(color.gray, 100), display=display.none)
plot(close - atrValue * 3, "Lower Scale Limit", color=color.new(color.gray, 100), display=display.none)

// ═══════════════════════════════════════════════════════════════════════════════
// END OF INDICATOR
// ═══════════════════════════════════════════════════════════════════════════════
````
