<!-- tradingview-pine-id: PUB;5853f86116f84f9fad43390cab9485ca -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MOYA Sessions & Volume Profile [RealSebastianMoya]

Source: https://www.tradingview.com/script/UfNIqD4u-MOYA-Sessions-Volume-Profile-RealSebastianMoya/

## Description

Hello traders!

Introducing: "MOYA Sessions and Volume Profile"

This script rebuilds a full Volume Profile for any session length you choose — from a single Tokyo/London/New York session up to a full Yearly cycle — and layers on POC, Value Area High/Low, a live in-progress profile, and (new) real futures volume normalization for Forex/CFD charts.

But before getting into the settings, it's worth explaining where this way of reading the market comes from, because the indicator has no real value if you don't know what questions it's actually answering.

The Underlying Theory: Auction Market Theory

The market isn't a line going up or down. It's a continuous auction. At every moment, buyers and sellers are negotiating a "fair" price, and price moves searching for the level where both sides are willing to transact in volume.

This theory — originally developed for Market Profile by J. Peter Steidlmayer at the CBOT — starts from a simple idea:

Price tells you where the market moved. Volume tells you how much conviction was behind that move.

A regular candlestick chart only shows you the time sequence of price. A Volume Profile rotates that information 90 degrees and asks a different question at every price level: "how much actually traded here?"

The level with the most activity is the Point of Control (POC) — the price the market has "voted" for most often as fair.

The Two Market Regimes

Under this theory, the market constantly alternates between two regimes:

Balance / Equilibrium
Technical name: Balance, Rotational Value Area
What it means: Buyers and sellers accept a range and price rotates inside it without clear direction
Profile shape: Bell curve (D-Shape) — POC centered

Imbalance / Trend
Technical name: Imbalance, Trend Day, Directional Auction
What it means: One side (buyers or sellers) dominates and price refuses to rotate, moving away from the range
Profile shape: Spike (P-Shape or b-Shape) — POC at one extreme

Knowing which regime the market is in completely changes what a touch of the POC or a Value Area edge should mean to you. This is what many newer traders miss: they apply the same rule ("buy at VAL, sell at VAH") regardless of regime, and end up fading strong trends as if they were reversions.

Correct Terminology — What Each Thing Is Actually Called

Here's the real vocabulary used when trading with Volume Profile, so you know exactly which term to use and what each one means:

Levels

POC (Point of Control): the price with the highest traded volume in the session. It's the center of gravity of price.
VAH (Value Area High): the upper boundary of the zone where 70% (adjustable) of volume occurred.
VAL (Value Area Low): the lower boundary of that same zone.
Value Area (VA): the full range between VAH and VAL — the fair price zone accepted by the market.
Naked POC: a POC from a previous session that price has not yet returned to touch. These act as strong magnets because they represent unresolved business.

Price Behaviors

Mean Reversion: when price moves away from the POC but returns to it because the market is in balance. This is the dominant behavior inside an equilibrium regime.
Continuation: when price breaks a Value Area extreme and keeps moving in that direction without returning, because the market is in imbalance.
Rejection: price touches a level (VAH, VAL, or POC) and snaps back quickly, leaving a wick — a sign that level was defended.
Acceptance: price enters a zone and stays there, building new volume — a sign the market considers that new range fair.
Excess: a long, thin wick with no volume behind it — a sign of violent rejection of a price, typical at range extremes.
Breakout: when price exits the Value Area with force and increasing volume. If acceptance follows the breakout, it confirms as a trend start; if there's no acceptance, it's a false breakout (fakeout) and price returns to the range (this is mean reversion after a failed breakout attempt).
Double Distribution (B-Shape): when the profile shows two high-volume zones separated by a low-volume zone — indicates the market was in two distinct price agreements during the session, typical of a trend that paused midway.

On Buyers and Sellers

Classic Volume Profile doesn't directly measure who bought or sold (that's what Delta/CVD does, not part of pure profile reading), but dominance can be inferred by observing:

If the POC shifts upward session after session, buyers are defending higher prices, buyer control.
If the POC shifts downward session after session, seller control.
If the POC stays relatively fixed while volume grows, both sides are actively negotiating without ceding ground, balance, indecisive market.

How the Indicator Works Within This Theory

The script tracks session boundaries using exact timeframe change detection and rebuilds the price/volume grid every time a new session starts.

Each candle's volume is distributed across the price levels its high-low range actually touched (body/wick weighted model), so the profile reflects where price genuinely spent time and volume — not just where it closed.

Once a session closes, the script locates the POC and expands outward, level by level, until the configured percentage of total volume (default 70%) is captured — that boundary becomes your Value Area.

Rather than just showing you where price moved, this helps you answer:

Where did volume concentrate during the session?
Was the session accepted (balance) or rejected (imbalance)?
Where is the fair price zone for this period?
How does that zone line up against higher or lower timeframe context?

While a session is still forming, the script keeps its profile, POC, and Value Area updating in real time (Live Zone) — not just the last closed session — so you can react to developing structure instead of only analyzing it afterward.

Trading Scenarios — How This Is Actually Traded

These are the real scenarios where this reading applies. You add the chart; here's the logic behind each one.

Scenario 1 — Mean Reversion Inside Balance
Regime context: The previous session's profile shows a bell-curve shape (D-Shape), POC centered, and a wide Value Area that has stayed stable across several sessions. This indicates a market in balance.
What you see on the Volume Profile: Current price is drifting away from the POC toward the VAH without growing volume behind it (little real push).
Reading: Since we're in a balance regime, the move toward VAH is likely testing the edge of the range, not the start of a trend.
How it's traded: Look for a short on rejection at the VAH, targeting the POC. Stop above the VAH with a small buffer. This is the classic fade trade — and it only makes sense because the regime is balance; the same signal in a trending regime would be a trap.

Scenario 2 — Continuation After a Breakout With Acceptance
Regime context: Price breaks above the previous session's VAH. Instead of falling back, price stays above that level for several candles, and the new forming profile (Live Zone) starts building its own POC above the old VAH.
What you see on the Volume Profile: Acceptance — the market is actively trading in the new price range, not just passing through it.
Reading: This is evidence of directional imbalance — control shifted hands (likely to buyers) and a new Value Area is forming higher up.
How it's traded: Look for a long entry on the first pullback into the old VAH (which now acts as support — the classic resistance-to-support flip), targeting the next significant volume level from a higher timeframe (e.g., the weekly POC if you're trading on Daily). Stop below the old POC.

Scenario 3 — False Breakout (Fakeout) — Reversion, Not Continuation

Regime context: Price breaks below the VAL with a strong candle, but in the following session (or in the indicator's Live Zone) price returns inside the original Value Area without building new volume below.What you see on the Volume Profile: No acceptance — the new profile forming outside the range has very little volume compared to the prior profile, a sign nobody is defending that price.

Reading: The breakout was a liquidity grab, not a real regime change. The market is still in balance.How it's traded: Look for a long entry on the return inside the Value Area, targeting the POC and potentially the opposite VAH. This is the scenario where confusing "breakout" with "continuation" costs the most money — which is why the indicator's Live Zone is key: it lets you see in real time whether the new profile is gaining volume (real continuation) or staying empty (fakeout).

Scenario 4 — Double Distribution (B-Shape) — A Pause Inside a TrendRegime context: The session's profile shows two separate high-volume zones with a thin low-volume "neck" between them.

What you see on the Volume Profile: The market traded heavily in one range, then migrated and traded heavily again in another range, without spending much time in the middle.Reading: This typically occurs inside a trend that paused — two distinct price agreements in the same session, usually connected by a fast directional move (the low-volume "neck" is where price moved without resistance).

How it's traded: The low-volume neck (the thin part of the profile) is a low-liquidity zone — if price returns there, it tends to cut through quickly in either direction, not stay. It's not a zone to trade reversion; it's a zone to wait for price to cross through and react at the POC of whichever side it's heading toward.

Scenario 5 — Multi-Timeframe Confluence (the Indicator's Most Powerful Use)Regime context: You run the indicator on Weekly and see current price touching the weekly VAL. You switch to Daily and see a daily POC also forming right at that same level.

What you see on the Volume Profile: Two different timeframes coinciding at the same price — the "why" (weekly context) and the "when" (daily execution) are aligned.Reading: This confluence across timeframes is the highest-probability signal in the whole system, because it doesn't depend on a single profile — it depends on the market respecting the same level from two different time perspectives.

How it's traded: Take the entry on Daily (precise execution), with directional bias given by the weekly regime (if weekly price is in balance, trade the reversion toward the weekly POC; if weekly is in imbalance, trade continuation toward the next relevant volume level). Stop goes outside the daily Value Area; target is the weekly POC or the opposite VAH/VAL, depending on the identified regime.

Scenario 6 — Using Real Futures Volume to Confirm Regime on Forex/CFDRegime context: You're trading XAUUSD on your CFD broker. Your broker's tick volume is synthetic (it counts price changes, not real contracts), so a profile built on that volume can show a different shape than actual market activity.

What you see on the Volume Profile: With External Futures Volume enabled and auto-detect pointing to COMEX:GC1! (Gold futures), the profile now reflects real futures market participation, while price levels still come from your XAUUSD chart.

Reading: This matters especially when your broker's tick volume gives you a POC in one place and real futures volume gives you a POC somewhere else — the difference tells you that real institutional market activity sits at a different level than what your broker is showing.

How it's traded: Prioritize the POC/VA calculated with real futures volume over native tick volume when the two diverge, because regulated futures volume (CME/COMEX/NYMEX) is auditable and reflects real participation, while tick count only reflects your specific broker's activity.Summary — Why Use This IndicatorThis script is designed for traders who read the market through:Volume Profile and Point of Control / Value Area (Auction Market Theory)Market regime identification (balance vs. imbalance)Multi-timeframe confluenceReal vs. synthetic volume on Forex/CFD instruments

Because you can run the same profile logic across completely different session lengths — from a single hourly cycle to a full year — you can compare how conviction built across timeframes: does the Daily POC sit inside last week's Value Area? Is price accepted or rejected at last month's VAH? That layered context is where this script earns its keep.Note: every scenario assumes you identify the market regime (balance vs. imbalance) first before deciding whether to trade reversion or continuation — trading the wrong signal for the wrong regime is the most common cause of losses when using Volume Profile.

Features
56 Session Lengths — 1 to 55 Minutes (1m, 2m, 3m, 4m, 5m, 6m, 7m, 8m, 9m, 10m, 12m, 15m, 20m, 25m, 30m, 35m, 40m, 45m, 50m, 55m), Tokyo, London, New York, 1 Hour through 12 Hours, Daily through 7 Days, Weekly through 5 Weeks, Monthly through 7 Months, Quarterly, Yearly.

POC, VAH, VAL with lines and text labels.

HVN/LVN — detects multiple volume peaks and valleys per session, not just the single POC.

External Futures Volume — auto-detects the real related futures contract for your symbol (metals, forex, indices, energy, crypto).

Live Panel — POC, VAH, VAL, distance, VA position, active volume source.

Configurable Styling — independent colors, widths, and sizes for every element.

Open Source Attribution and Credits

In strict compliance with TradingViews House Rules regarding open-source code reuse, I explicitly credit and thank the original developer @LeviathanCapital for their open-source script "Market sessions and Volume profile - By Leviathan", which served as the structural foundation for the session isolation and baseline volume array logic in this indicator.

Significant Algorithmic Enhancements and Added Value:

While the primary mathematical grid expansion retains architectural roots from open source, this script introduces massive procedural improvements, structural upgrades, and new calculations developed entirely by me to transform it into an institutional-grade utility:

Automated External Futures Volume Normalization (Forex/CFD Context): Implemented a dictionary algorithm (getAutoFuturesTicker) to auto-detect and scale native tick charts against centralized futures markets (e.g., CME:6E1!, COMEX:GC1!, CME_MINI:NQ1!). This replaces synthetic broker data with authentic trading volume while maintaining local price scales.

Volume Nodes Engine (Multi-Peak HVN / LVN Detection): Developed an array scanning filter that runs on closed sessions to automatically isolate contiguous high/low volume anomalies. This effectively flags multiple supply/demand zones (like the humps of a double-distribution profile) beyond the baseline single POC.

Real-Time Live Zone Tracking: Integrated a dynamic recalculation engine for ongoing unclosed trading sessions, updating developing POCs, VAHs, and VALs seamlessly on the active bar state.

Interactive Live Dashboard Panel: Programmed a comprehensive on-screen status table displaying absolute values for POC/VAH/VAL, current distance from point of control, value area boundary status, and status indicators of the active volume feed.

Expanded Graphical and Period Customization: Redesigned aesthetic configurations, text label sizing, box boundary styles, and added resolution adjustments alongside line right-extensions.

Open Source Attribution and Credits

In strict compliance with TradingViews House Rules regarding open-source code reuse, I explicitly credit and thank the original developer LeviathanCapital for their work.

The original script "Market sessions and Volume profile - By @LeviathanCapital served as the logical foundation for the session isolation and baseline volume array logic in this indicator. All rights and original logical baselines remain under their respective ownership.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © RealSebastianMoya
//@version=6
indicator("MOYA Sessions & Volume Profile [RealSebastianMoya]", shorttitle="MOYA Sessions & Volume Profile [RealSebastianMoya]", overlay=true, max_boxes_count=500, max_bars_back=1000)

// =============================================================================================================
// CREDITS & OPEN-SOURCE ATTRIBUTION:
// Core session segmentation logic and mathematical Volume Profile grid reconstruction calculations are inspired 
// by and derived from the open-source script "Market sessions and Volume profile - By Leviathan" 
// authored by @LeviathanCapital (https://www.tradingview.com/u/LeviathanCapital/).
// All rights and original logical baselines remain under their respective ownership.
// =============================================================================================================

// ============================================================
// INPUTS
// ============================================================
grpSession  = "Session"
sessionType = input.string('Daily', 'Session Type', group=grpSession, options=[
     '1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes',
     '6 Minutes','7 Minutes','8 Minutes','9 Minutes','10 Minutes',
     '12 Minutes','15 Minutes','20 Minutes','25 Minutes','30 Minutes',
     '35 Minutes','40 Minutes','45 Minutes','50 Minutes','55 Minutes',
     'Tokyo','London','New York',
     '1 Hour','2 Hours','3 Hours','4 Hours','5 Hours','6 Hours','7 Hours','8 Hours','9 Hours','10 Hours','11 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'])

grpDisplay  = "Display"
showProf    = input.bool(true,  'Show Volume Profile',   group=grpDisplay)
showPoc     = input.bool(true,  'Show POC',               group=grpDisplay)
showVA      = input.bool(true,  'Show VAH and VAL',       group=grpDisplay)
showVAb     = input.bool(false, 'Show Value Area Box',    group=grpDisplay)
showCur     = input.bool(true,  'Show Live Zone',         group=grpDisplay)
showLabels  = input.bool(true,  'Show Labels',            group=grpDisplay)
showFx      = input.bool(false, 'Show Forex Sessions',    group=grpDisplay)
extendLines = input.bool(false, 'Extend Lines Right',     group=grpDisplay)
extendBars  = input.int(50,     'Extension Bars', minval=1, maxval=500, group=grpDisplay)

grpVP      = "Volume Profile"
resolution = input.int(30,          'Resolution',    minval=5,             group=grpVP)
VAwid      = input.int(70,          'Value Area %',  minval=1, maxval=100, group=grpVP)
dispMode   = input.string('Mode 2', 'Bar Mode', options=['Mode 1','Mode 2','Mode 3'], group=grpVP)
volType    = input.string('Volume', 'Data Type',   options=['Volume','Open Interest'],   group=grpVP)
smoothVol  = input.bool(false, 'Smooth Volume', group=grpVP)
dataTf     = ''

// ============================================================
// INPUTS — EXTERNAL FUTURES VOLUME (with auto-detection)
// ============================================================
grpExtVol         = "External Futures Volume"
useExternalVol    = input.bool(false, "Use External Futures Volume", tooltip="Replaces this chart's native volume with real futures volume — useful on CFD/Forex charts (EURUSD, XAUUSD, GLD, etc.) where broker-reported volume is synthetic and doesn't reflect real market activity. The profile's price levels still come from this chart's own price action; only the total volume per bar is rescaled to match the external futures symbol. Ignored when Data Type is set to Open Interest.", group=grpExtVol)
autoDetectFutures = input.bool(true,  "🔄 Auto Detect Futures Ticker", tooltip="Detecta automáticamente el futuro relacionado según el símbolo del gráfico actual (ej: XAUUSD → GC1!, NAS100 → NQ1!). Si el símbolo actual no está en la tabla, cae automáticamente al ticker manual de abajo.", group=grpExtVol)
externalVolSymbol = input.symbol("CME:6E1!", "Manual Futures Symbol (fallback / si Auto está OFF)", tooltip="Se usa cuando Auto Detect está OFF, o cuando el símbolo actual no tiene mapeo automático. NAS100/US100/USTEC y SPX500/US500 YA se auto-detectan — no hace falta escribirlos aquí. Fallback solo para símbolos fuera de la tabla. Examples — EURUSD: CME:6E1!  |  GBPUSD: CME:6B1!  |  XAUUSD/GLD: COMEX:GC1!  |  XAGUSD/SLV: COMEX:SI1!  |  USOIL: NYMEX:CL1!", group=grpExtVol)
showTickerPanel   = input.bool(true, "Show Vol. Source in Panel", group=grpExtVol)

// ============================================================
// INPUTS — VOLUME NODES (HVN / LVN) — closed sessions only
// ============================================================
grpNodes             = "Volume Nodes (HVN/LVN)"
showHVN              = input.bool(false, "Show HVN (High Volume Nodes)", group=grpNodes, tooltip="Marks the top volume peaks in each CLOSED session's profile — zones of concentrated activity. Detects multiple separate peaks (e.g. both humps of a B-shaped bimodal profile), not just the single global POC.")
showLVN              = input.bool(false, "Show LVN (Low Volume Nodes)", group=grpNodes, tooltip="Marks the deepest volume valleys in each CLOSED session's profile — thin, inefficient zones, often broken through quickly.")
nodeStyle            = input.string("Box", "Node Style", options=["Box", "Line Only"], group=grpNodes, tooltip="Box: fills the node's price zone and extends a dashed reference line through its center. Line Only: just the center line, no fill (fewer chart objects).")
hvnThreshold         = input.float(1.5, "HVN Threshold (x Average Volume)", minval=1.0, maxval=5.0, step=0.1, group=grpNodes, tooltip="A bin qualifies as HVN once its volume reaches this many times the session's AVERAGE bin volume. Lower (e.g. 1.2) = more zones flagged. Higher (e.g. 2.5) = only the most dominant peaks.")
lvnThreshold         = input.float(0.4, "LVN Threshold (x Average Volume)", minval=0.05, maxval=1.0, step=0.05, group=grpNodes, tooltip="A bin qualifies as LVN once its volume drops to this fraction of the session's AVERAGE bin volume. Higher (e.g. 0.7) = more/shallower zones flagged. Lower (e.g. 0.2) = only the deepest gaps.")
minZoneBins          = input.int(1, "Min Zone Size (bins)", minval=1, maxval=10, group=grpNodes, tooltip="Skips zones narrower than this many contiguous bins — raise this to ignore tiny single-row noise and only mark meaningfully wide HVN/LVN zones.")
maxNodesPerSession   = input.int(3, "Max Nodes per Type (per session)", minval=1, maxval=10, group=grpNodes)
showNodeLabels       = input.bool(true, "Show Node Labels", group=grpNodes)
hvnBoxColor          = input.color(color.new(#00e5ff, 85), "HVN Box", inline='hvnc', group=grpNodes)
hvnLineColor         = input.color(#00e5ff, "Line", inline='hvnc', group=grpNodes)
hvnTextColor         = input.color(color.white, "Label", inline='hvnc', group=grpNodes)
hvnWidth             = input.int(2, "Line Width", minval=1, maxval=5, group=grpNodes)
lvnBoxColor          = input.color(color.new(#ff9800, 85), "LVN Box", inline='lvnc', group=grpNodes)
lvnLineColor         = input.color(#ff9800, "Line", inline='lvnc', group=grpNodes)
lvnTextColor         = input.color(color.white, "Label", inline='lvnc', group=grpNodes)
lvnWidth             = input.int(1, "Line Width", minval=1, maxval=5, group=grpNodes)

// ============================================================
// INPUTS — LABEL STYLE (new)
// ============================================================
grpLabelStyle       = "Label Style"
sessionLabelColor   = input.color(color.white, "Session Label Color (e.g. \"Daily\", \"3 Weeks\")", group=grpLabelStyle, tooltip="Controls the color of the big session-name label drawn above each profile. Previously this always followed the chart's theme (white on dark, black on light) with no way to override it.")
sessionLabelSize    = input.string("Normal", "Session Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLabelStyle)
levelLabelSize      = input.string("Small", "POC / VAH / VAL Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLabelStyle, tooltip="POC/VAH/VAL label text color still follows each level's own line color (set in Appearance) — this only controls their size.")

grpColors = "Appearance"
bullCol = input.color(color.rgb(55,107,137,50),  'Bullish Volume',  group=grpColors)
bearCol = input.color(color.rgb(62,63,76,50),    'Bearish Volume',  group=grpColors)
VAbCol  = input.color(color.rgb(107,159,255,90), 'Value Area Box',  group=grpColors)
pocCol  = input.color(color.red,                 'POC',  inline='p', group=grpColors)
pocWid  = input.int(1, 'Width', inline='p', group=grpColors)
vahCol  = input.color(#2962ff,                   'VAH',  inline='h', group=grpColors)
vahWid  = input.int(1, 'Width', inline='h', group=grpColors)
valCol  = input.color(#000000,                   'VAL',  inline='l', group=grpColors)
valWid  = input.int(1, 'Width', inline='l', group=grpColors)
boxBg   = input.color(color.rgb(255,153,0,100),  'Box Background', inline='m', group=grpColors)
boxWid  = input.int(1, 'Width', inline='m', group=grpColors)
showBox = input.bool(true, 'Show Zone Box', group=grpColors)
boxBorderColor = input.color(color.black, 'Box Border', inline='bb', group=grpColors)
boxBorder = input.int(2, 'Width', minval=1, maxval=10, inline='bb', group=grpColors)
boxStyle = input.string('Dashed', 'Box Line Style', options=['Solid','Dotted','Dashed'], group=grpColors)

grpPanel       = "Live Panel"
showPanel      = input.bool(true,         'Show Panel', group=grpPanel)
panelPos       = input.string('Top Right','Position', options=['Top Right','Top Left','Bottom Right','Bottom Left'], group=grpPanel)
panelBgColor   = input.color(color.new(#0b0f17,10), 'Panel Background',  group=grpPanel)
panelTextColor = input.color(color.white,            'Text Color',  group=grpPanel)

// ============================================================
// GLOBAL VARIABLES
// ============================================================
var int  zoneStart   = 0
var int  tokyoStart  = 0
var int  londonStart = 0
var int  nyStart     = 0
int lookback = bar_index - zoneStart
var bool activeZone  = false
var int  dayCount    = 0
var int  weekCount   = 0
var int  monthCount  = 0
var int  minuteCount = 0
var int  hourCount   = 0

var vpGreen    = array.new_float(resolution, 0)
var vpRed      = array.new_float(resolution, 0)
var zoneBounds = array.new_float(resolution, 0)

var float[] ltfOpen   = array.new_float(0)
var float[] ltfClose  = array.new_float(0)
var float[] ltfHigh   = array.new_float(0)
var float[] ltfLow    = array.new_float(0)
var float[] ltfVolume = array.new_float(0)

var float livePOC   = na
var float liveVAH   = na
var float liveVAL   = na
var table infoPanel = na

// ============================================================
// DATA
// ============================================================
string userSymbol = syminfo.prefix + ":" + syminfo.ticker
string oiTicker   = str.format("{0}_OI", userSymbol)
string tfoi       = syminfo.type == "futures" and timeframe.isintraday ? "1D" : timeframe.period
deltaOi = request.security(oiTicker, tfoi, close - close[1], ignore_invalid_symbol=true)

vol() =>
    out = smoothVol ? ta.ema(volume, 5) : volume
    if volType == 'Open Interest'
        out := deltaOi
    out

[dO, dC, dH, dL, dV] = request.security_lower_tf(syminfo.tickerid, dataTf, [open, close, high, low, vol()])

// ============================================================
// AUTO-DETECTION OF RELATED FUTURES TICKER
// Based on the current chart symbol (syminfo.ticker)
// ============================================================
getAutoFuturesTicker() =>
    t = syminfo.ticker
    switch t
        //METALS
        "XAUUSD" => "COMEX:GC1!"
        "XAGUSD" => "COMEX:SI1!"
        "SILVER" => "COMEX:SI1!"

        // FOREX
        "EURUSD" => "CME:6E1!"
        "GBPUSD" => "CME:6B1!"
        "USDJPY" => "CME:6J1!"
        "AUDUSD" => "CME:6A1!"
        "USDCAD" => "CME:6C1!"
        "USDCHF" => "CME:6S1!"
        "NZDUSD" => "CME:6N1!"
        "EURGBP" => "CME:RP1!"
        "AUDCAD" => "CME:ACD1!"
        "GBPJPY" => "CME:PJY1!"
        "GBPAUD" => "CME:GA1!"
        "EURJPY" => "CME:RY1!"
        "EURCHF" => "CME:RF1!"
        "GBPCHF" => "CME:PSF1!"
        "AUDJPY" => "CME:AJY1!"
        "EURAUD" => "CME:EAD1!"
        "EURCAD" => "CME:ECD1!"

        // ÍNDICES
        "US100"   => "CME_MINI:NQ1!"
        "NAS100"  => "CME_MINI:NQ1!"
        "USTEC"   => "CME_MINI:NQ1!"
        "NDX100"  => "CME_MINI:NQ1!"
        "US500"   => "CME_MINI:ES1!"
        "SPX500"  => "CME_MINI:ES1!"
        "SP500"  => "CME_MINI:ES1!"
        "DJ30"    => "CBOT_MINI:YM1!"
        "US30"    => "CBOT_MINI:YM1!"
        "USA30"   => "CBOT_MINI:YM1!"
        "GER30"  => "EUREX:FDXS1!"
        "GER40"  => "EUREX:FDXS1!"
        "DXY"  => "ICEUS:DX1!" 

        // ENERGY
        "USOIL" => "NYMEX:CL1!"
        "NATGAS"   => "NYMEX:NG1!"
        
        // CRYPTO
        "BTCUSD" => "CME:BTC1!"
        "ETHUSD" => "CME:ETH1!"

        => na   // no match → falls to manual ticker

// Determine which symbol is ultimately used: automatic (if there is a match) → manual (fallback) → none.
autoMatch          = getAutoFuturesTicker()
autoMatchFound     = not na(autoMatch)
resolvedExtSymbol  = useExternalVol ? (autoDetectFutures and autoMatchFound ? autoMatch : externalVolSymbol) : na
usingAutoNow       = useExternalVol and autoDetectFutures and autoMatchFound

// External futures volume normalization
externalVolume  = request.security(resolvedExtSymbol, timeframe.period, volume, ignore_invalid_symbol=true)
nativeBarVolume = volume
volScaleFactor  = (useExternalVol and volType == 'Volume' and nativeBarVolume > 0 and not na(externalVolume)) ? externalVolume / nativeBarVolume : 1.0

// ============================================================
// PERIOD DETECTION — using timeframe.change() (correct)
// ============================================================
newDaily     = timeframe.change("D")
newWeekly    = timeframe.change("W")
newMonthly   = timeframe.change("M")
newQuarterly = timeframe.change("3M")
newYearly    = timeframe.change("12M")

utcHour   = hour(time(timeframe.period,'0000-2400','GMT'),'GMT')
utcMinute = minute(time(timeframe.period,'0000-2400','GMT'),'GMT')

newTokyo   = utcHour != utcHour[1]+1 and utcHour != utcHour[1]
endTokyo   = utcHour >= 9  and utcHour[1] < 9
newLondon  = utcHour >= 7  and utcHour[1] < 7
endLondon  = utcHour >= 16 and utcHour[1] < 16
newNewYork = utcHour >= 13 and utcHour[1] < 13
endNewYork = utcHour >= 22 and utcHour[1] < 22

new1h  = utcHour != utcHour[1]
new2h  = utcHour % 2  == 0 and utcHour[1] % 2  != 0
new3h  = utcHour % 3  == 0 and utcHour[1] % 3  != 0
new4h  = utcHour % 4  == 0 and utcHour[1] % 4  != 0
new5h  = utcHour % 5  == 0 and utcHour[1] % 5  != 0
new6h  = utcHour % 6  == 0 and utcHour[1] % 6  != 0
new7h  = utcHour % 7  == 0 and utcHour[1] % 7  != 0
new8h  = utcHour % 8  == 0 and utcHour[1] % 8  != 0
new9h  = utcHour % 9  == 0 and utcHour[1] % 9  != 0
new10h = utcHour % 10 == 0 and utcHour[1] % 10 != 0
new11h = utcHour % 11 == 0 and utcHour[1] % 11 != 0
new12h = utcHour % 12 == 0 and utcHour[1] % 12 != 0

// Counters for multiples — only incremented with timeframe.change()
if newDaily
    dayCount += 1
if newWeekly
    weekCount += 1
if newMonthly
    monthCount += 1

new2D = newDaily   and dayCount   % 2 == 0
new3D = newDaily   and dayCount   % 3 == 0
new4D = newDaily   and dayCount   % 4 == 0
new5D = newDaily   and dayCount   % 5 == 0
new6D = newDaily   and dayCount   % 6 == 0
new7D = newDaily   and dayCount   % 7 == 0
new2W = newWeekly  and weekCount  % 2 == 0
new3W = newWeekly  and weekCount  % 3 == 0
new4W = newWeekly  and weekCount  % 4 == 0
new5W = newWeekly  and weekCount  % 5 == 0
new2M = newMonthly and monthCount % 2 == 0
new3M = newMonthly and monthCount % 3 == 0
new4M = newMonthly and monthCount % 4 == 0
new5M = newMonthly and monthCount % 5 == 0
new6M = newMonthly and monthCount % 6 == 0
new7M = newMonthly and monthCount % 7 == 0

newSession = switch sessionType
    // MINUTES
    '1 Minute'    => utcMinute != utcMinute[1]
    '2 Minutes'   => utcMinute % 2  == 0 and utcMinute[1] % 2  != 0
    '3 Minutes'   => utcMinute % 3  == 0 and utcMinute[1] % 3  != 0
    '4 Minutes'   => utcMinute % 4  == 0 and utcMinute[1] % 4  != 0
    '5 Minutes'   => utcMinute % 5  == 0 and utcMinute[1] % 5  != 0
    '6 Minutes'   => utcMinute % 6  == 0 and utcMinute[1] % 6  != 0
    '7 Minutes'   => utcMinute % 7  == 0 and utcMinute[1] % 7  != 0
    '8 Minutes'   => utcMinute % 8  == 0 and utcMinute[1] % 8  != 0
    '9 Minutes'   => utcMinute % 9  == 0 and utcMinute[1] % 9  != 0
    '10 Minutes'  => utcMinute % 10 == 0 and utcMinute[1] % 10 != 0
    '12 Minutes'  => utcMinute % 12 == 0 and utcMinute[1] % 12 != 0
    '15 Minutes'  => utcMinute % 15 == 0 and utcMinute[1] % 15 != 0
    '20 Minutes'  => utcMinute % 20 == 0 and utcMinute[1] % 20 != 0
    '25 Minutes'  => utcMinute % 25 == 0 and utcMinute[1] % 25 != 0
    '30 Minutes'  => utcMinute % 30 == 0 and utcMinute[1] % 30 != 0
    '35 Minutes'  => utcMinute % 35 == 0 and utcMinute[1] % 35 != 0
    '40 Minutes'  => utcMinute % 40 == 0 and utcMinute[1] % 40 != 0
    '45 Minutes'  => utcMinute % 45 == 0 and utcMinute[1] % 45 != 0
    '50 Minutes'  => utcMinute % 50 == 0 and utcMinute[1] % 50 != 0
    '55 Minutes'  => utcMinute % 55 == 0 and utcMinute[1] % 55 != 0
    // SESSIONS
    'Tokyo'     => newTokyo
    'London'    => newLondon
    'New York'  => newNewYork
    // HOURS
    '1 Hour'    => new1h
    '2 Hours'   => new2h
    '3 Hours'   => new3h
    '4 Hours'   => new4h
    '5 Hours'   => new5h
    '6 Hours'   => new6h
    '7 Hours'   => new7h
    '8 Hours'   => new8h
    '9 Hours'   => new9h
    '10 Hours'  => new10h
    '11 Hours'  => new11h
    '12 Hours'  => new12h
    // DAYS / WEEKS / MONTHS
    'Daily'     => newDaily
    '2 Days'    => new2D
    '3 Days'    => new3D
    '4 Days'    => new4D
    '5 Days'    => new5D
    '6 Days'    => new6D
    '7 Days'    => new7D
    'Weekly'    => newWeekly
    '2 Weeks'   => new2W
    '3 Weeks'   => new3W
    '4 Weeks'   => new4W
    '5 Weeks'   => new5W
    'Monthly'   => newMonthly
    '2 Months'  => new2M
    '3 Months'  => new3M
    '4 Months'  => new4M
    '5 Months'  => new5M
    '6 Months'  => new6M
    '7 Months'  => new7M
    'Quarterly' => newQuarterly
    'Yearly'    => newYearly
    => newDaily

zoneEnd = switch sessionType
    'Tokyo'    => endTokyo
    'London'   => endLondon
    'New York' => endNewYork
    => newSession

// ============================================================
// CORE FUNCTIONS
// ============================================================
profHigh = ta.highest(high, lookback+1)[1]
profLow  = ta.lowest(low,  lookback+1)[1]

resetProfile(enable) =>
    if enable
        array.fill(vpGreen, 0)
        array.fill(vpRed,   0)
        array.clear(ltfOpen)
        array.clear(ltfHigh)
        array.clear(ltfLow)
        array.clear(ltfClose)
        array.clear(ltfVolume)

get_vol(y11, y12, y21, y22, height, v) =>
    nz(math.max(math.min(math.max(y11,y12), math.max(y21,y22)) - math.max(math.min(y11,y12), math.min(y21,y22)), 0) * v / height)

profileAdd(o, h, l, c, v, g) =>
    for i = 0 to array.size(vpGreen) - 1
        zoneTop       = array.get(zoneBounds, i)
        zoneBot       = zoneTop - g
        body_top      = math.max(c, o)
        body_bot      = math.min(c, o)
        itsgreen      = c >= o
        topwick       = h - body_top
        bottomwick    = body_bot - l
        body          = body_top - body_bot
        denom         = 2*topwick + 2*bottomwick + body
        bodyvol       = denom > 0 ? body * v / denom : 0.0
        topwickvol    = denom > 0 ? 2*topwick * v / denom : 0.0
        bottomwickvol = denom > 0 ? 2*bottomwick * v / denom : 0.0
        if volType == 'Volume'
            gVal = array.get(vpGreen,i) + (itsgreen ? get_vol(zoneBot,zoneTop,body_bot,body_top,body,bodyvol) : 0.0) + get_vol(zoneBot,zoneTop,body_top,h,topwick,topwickvol)/2 + get_vol(zoneBot,zoneTop,body_bot,l,bottomwick,bottomwickvol)/2
            rVal = array.get(vpRed,  i) + (itsgreen ? 0.0 : get_vol(zoneBot,zoneTop,body_bot,body_top,body,bodyvol)) + get_vol(zoneBot,zoneTop,body_top,h,topwick,topwickvol)/2 + get_vol(zoneBot,zoneTop,body_bot,l,bottomwick,bottomwickvol)/2
            array.set(vpGreen, i, gVal)
            array.set(vpRed,   i, rVal)
        else if volType == 'Open Interest'
            if v > 0
                array.set(vpGreen, i, array.get(vpGreen,i) + get_vol(zoneBot,zoneTop,body_bot,body_top,body, v))
            if v < 0
                array.set(vpRed,   i, array.get(vpRed,  i) + get_vol(zoneBot,zoneTop,body_bot,body_top,body,-v))

calcSession(update) =>
    array.fill(vpGreen, 0)
    array.fill(vpRed,   0)
    if bar_index > lookback and update
        gap = (profHigh - profLow) / resolution
        for i = 0 to resolution - 1
            array.set(zoneBounds, i, profHigh - gap*i)
        if array.size(ltfOpen) > 0
            for j = 0 to array.size(ltfOpen) - 1
                profileAdd(array.get(ltfOpen,j), array.get(ltfHigh,j), array.get(ltfLow,j), array.get(ltfClose,j), array.get(ltfVolume,j), gap)

pocLevel() =>
    float maxVol   = 0.0
    int   levelInd = 0
    for i = 0 to array.size(vpRed) - 1
        total = array.get(vpRed,i) + array.get(vpGreen,i)
        if total > maxVol
            maxVol   := total
            levelInd := i
    float outLevel = na
    if levelInd != array.size(vpRed) - 1
        outLevel := array.get(zoneBounds,levelInd) - (array.get(zoneBounds,levelInd) - array.get(zoneBounds,levelInd+1)) / 2
    outLevel

valueLevels(poc) =>
    float gap    = (profHigh - profLow) / resolution
    float volSum = array.sum(vpRed) + array.sum(vpGreen)
    float volCnt = 0.0
    float vah    = profHigh
    float val    = profLow
    int   pocInd = 0
    for i = 0 to array.size(zoneBounds) - 2
        if array.get(zoneBounds,i) >= poc and array.get(zoneBounds,i+1) < poc
            pocInd := i
    volCnt += array.get(vpRed,pocInd) + array.get(vpGreen,pocInd)
    for i = 1 to array.size(vpRed)
        upIdx = pocInd - i
        dnIdx = pocInd + i
        if upIdx >= 0 and upIdx < array.size(vpRed)
            volCnt += array.get(vpRed,upIdx) + array.get(vpGreen,upIdx)
            if volCnt >= volSum * (VAwid/100)
                break
            else
                vah := array.get(zoneBounds,upIdx)
        if dnIdx >= 0 and dnIdx < array.size(vpRed)
            volCnt += array.get(vpRed,dnIdx) + array.get(vpGreen,dnIdx)
            if volCnt >= volSum * (VAwid/100)
                break
            else
                val := array.get(zoneBounds,dnIdx) - gap
    [val, vah]

// ============================================================
// VOLUME NODES (HVN/LVN) — only called for CLOSED sessions
// ============================================================
drawNodeZone(topIdx, botIdx, leftEdgeX, lineEndX, gapVal, boxCol, lineCol, textCol, lineWid, txt) =>
    top = array.get(zoneBounds, topIdx)
    bot = array.get(zoneBounds, botIdx) - gapVal
    mid = (top + bot) / 2
    if nodeStyle == "Box"
        box.new(int(leftEdgeX), top, bar_index - 1, bot, border_color=lineCol, border_width=1, border_style=line.style_dashed, bgcolor=boxCol)
    line.new(int(leftEdgeX), mid, lineEndX, mid, color=lineCol, width=lineWid, style=line.style_dashed)
    if showNodeLabels
        label.new(lineEndX, mid, txt, color=color.new(color.black,100), textcolor=textCol, style=label.style_none, size=size.tiny)

markVolumeNodes(leftEdgeX, lineEndX, gapVal) =>
    n = array.size(vpGreen)
    if n >= 1
        float[] totals = array.new_float(n)
        float sumVol = 0.0
        for i = 0 to n - 1
            t = array.get(vpGreen,i) + array.get(vpRed,i)
            array.set(totals, i, t)
            sumVol += t
        float meanVol = n > 0 ? sumVol / n : 0.0

        if meanVol > 0
            float lvnCut = meanVol * lvnThreshold
            float hvnCut = meanVol * hvnThreshold

            float[] lvnZoneVol = array.new_float(0)
            int[]   lvnZoneTop = array.new_int(0)
            int[]   lvnZoneBot = array.new_int(0)
            float[] hvnZoneVol = array.new_float(0)
            int[]   hvnZoneTop = array.new_int(0)
            int[]   hvnZoneBot = array.new_int(0)

            // --- scan for contiguous LOW zones ---
            int li = 0
            while li < n
                if array.get(totals, li) <= lvnCut
                    int   lStart = li
                    float lMinV  = array.get(totals, li)
                    int   lj     = li
                    while lj < n and array.get(totals, lj) <= lvnCut
                        lv = array.get(totals, lj)
                        if lv < lMinV
                            lMinV := lv
                        lj += 1
                    if (lj - lStart) >= minZoneBins
                        array.push(lvnZoneVol, lMinV)
                        array.push(lvnZoneTop, lStart)
                        array.push(lvnZoneBot, lj - 1)
                    li := lj
                else
                    li += 1

            // --- scan for contiguous HIGH zones ---
            int hi = 0
            while hi < n
                if array.get(totals, hi) >= hvnCut
                    int   hStart = hi
                    float hMaxV  = array.get(totals, hi)
                    int   hj     = hi
                    while hj < n and array.get(totals, hj) >= hvnCut
                        hv = array.get(totals, hj)
                        if hv > hMaxV
                            hMaxV := hv
                        hj += 1
                    if (hj - hStart) >= minZoneBins
                        array.push(hvnZoneVol, hMaxV)
                        array.push(hvnZoneTop, hStart)
                        array.push(hvnZoneBot, hj - 1)
                    hi := hj
                else
                    hi += 1

            if showLVN and array.size(lvnZoneVol) > 0
                sortedLvn = array.sort_indices(lvnZoneVol, order.ascending)
                for k = 0 to math.min(maxNodesPerSession, array.size(sortedLvn)) - 1
                    pos = array.get(sortedLvn, k)
                    drawNodeZone(array.get(lvnZoneTop, pos), array.get(lvnZoneBot, pos), leftEdgeX, lineEndX, gapVal, lvnBoxColor, lvnLineColor, lvnTextColor, lvnWidth, "LVN")

            if showHVN and array.size(hvnZoneVol) > 0
                sortedHvn = array.sort_indices(hvnZoneVol, order.descending)
                for k = 0 to math.min(maxNodesPerSession, array.size(sortedHvn)) - 1
                    pos = array.get(sortedHvn, k)
                    drawNodeZone(array.get(hvnZoneTop, pos), array.get(hvnZoneBot, pos), leftEdgeX, lineEndX, gapVal, hvnBoxColor, hvnLineColor, hvnTextColor, hvnWidth, "HVN")

lstyle() =>
    line.style_solid

bstyle() =>
    switch boxStyle
        'Solid'  => line.style_solid
        'Dotted' => line.style_dotted
        'Dashed' => line.style_dashed
        => line.style_dashed

getLabelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

updateIntra(o, h, l, c, v, scale) =>
    if array.size(o) > 0
        for i = 0 to array.size(o) - 1
            array.push(ltfOpen,   array.get(o,i))
            array.push(ltfHigh,   array.get(h,i))
            array.push(ltfLow,    array.get(l,i))
            array.push(ltfClose,  array.get(c,i))
            array.push(ltfVolume, array.get(v,i) * scale)

// ============================================================
// DRAW NEW ZONE
// ============================================================
drawNewZone(update) =>
    if bar_index > lookback and update and array.sum(vpGreen)+array.sum(vpRed) > 0
        gap            = (profHigh - profLow) / resolution
        float leftMax  = bar_index[lookback]
        float rightMax = bar_index[int(lookback/1.4)]
        float rmv      = array.max(vpGreen) + array.max(vpRed)
        float buf      = gap / 10
        int   lineEnd  = bar_index - 1 + (extendLines ? extendBars : 0)

        if showLabels
            label.new((bar_index-1+int(leftMax))/2, profHigh, sessionType, color=color.rgb(0,0,0,100), textcolor=sessionLabelColor, size=getLabelSize(sessionLabelSize))
        if showProf
            for i = 0 to array.size(vpRed) - 1
                gEnd = int(leftMax + (rightMax-leftMax)*(array.get(vpGreen,i)/rmv))
                rEnd = int(gEnd    + (rightMax-leftMax)*(array.get(vpRed,  i)/rmv))
                zTop = array.get(zoneBounds,i)
                zBot = zTop - gap
                if dispMode == 'Mode 2'
                    box.new(int(leftMax), zTop-buf, gEnd, zBot+buf, bgcolor=bullCol, border_width=0)
                    box.new(gEnd,         zTop-buf, rEnd, zBot+buf, bgcolor=bearCol, border_width=0)
                else if dispMode == 'Mode 1'
                    box.new(int(leftMax), zTop-buf, gEnd, zBot+buf, bgcolor=bullCol, border_width=0)
                else
                    box.new(int(leftMax),           zTop-buf, gEnd,         zBot+buf, bgcolor=bullCol, border_width=0)
                    box.new(int(leftMax)-rEnd+gEnd, zTop-buf, int(leftMax), zBot+buf, bgcolor=bearCol, border_width=0)

        if showBox
            box.new(int(leftMax), profHigh, bar_index-1, profLow, boxBorderColor, boxBorder, bstyle(), bgcolor=boxBg)
        poc = pocLevel()
        [val, vah] = valueLevels(poc)
        if showPoc
            line.new(int(leftMax), poc, lineEnd, poc, color=pocCol, width=pocWid, style=lstyle())
            label.new(lineEnd, poc, "POC " + sessionType, color=color.rgb(244,63,94,0), textcolor=pocCol, style=label.style_none, size=getLabelSize(levelLabelSize))
        if showVA
            line.new(int(leftMax), vah, lineEnd, vah, color=vahCol, width=vahWid, style=lstyle())
            line.new(int(leftMax), val, lineEnd, val, color=valCol, width=valWid, style=lstyle())
            label.new(lineEnd, vah, "VAH " + sessionType, color=color.rgb(0,191,165,0), textcolor=vahCol, style=label.style_none, size=getLabelSize(levelLabelSize))
            label.new(lineEnd, val, "VAL " + sessionType, color=color.rgb(0,191,165,0), textcolor=valCol, style=label.style_none, size=getLabelSize(levelLabelSize))
        if showVAb
            box.new(int(leftMax), vah, bar_index-1, val, border_color=color.rgb(54,58,69,100), bgcolor=VAbCol)
        if showHVN or showLVN
            markVolumeNodes(leftMax, lineEnd, gap)

// ============================================================
// DRAW CURRENT ZONE
// ============================================================
drawCurZone(update, del) =>
    var line  pocLine    = na
    var line  vahLine    = na
    var line  valLine    = na
    var box   outBox     = na
    var label sessionLab = na
    var box[] redBoxes   = array.new_box(array.size(vpRed), na)
    var box[] greenBoxes = array.new_box(array.size(vpRed), na)

    if bar_index > lookback and update and array.sum(vpGreen)+array.sum(vpRed) > 0
        if not na(pocLine)
            line.delete(pocLine)
        if not na(vahLine)
            line.delete(vahLine)
        if not na(valLine)
            line.delete(valLine)
        if not na(outBox)
            box.delete(outBox)
        if not na(sessionLab)
            label.delete(sessionLab)
        for i = 0 to array.size(redBoxes) - 1
            b1 = array.get(redBoxes, i)
            b2 = array.get(greenBoxes, i)
            if not na(b1)
                box.delete(b1)
            if not na(b2)
                box.delete(b2)

        gap            = (profHigh - profLow) / resolution
        float leftMax  = bar_index[lookback]
        float rightMax = bar_index[int(lookback/1.4)]
        float rmv      = array.max(vpGreen) + array.max(vpRed)
        float buf      = gap / 10
        int   lineEnd  = bar_index - 1 + (extendLines ? extendBars : 0)

        if showLabels
            sessionLab := label.new((bar_index-1+int(leftMax))/2, profHigh, sessionType, color=color.rgb(0,0,0,100), textcolor=sessionLabelColor, size=getLabelSize(sessionLabelSize))
        if showProf
            for i = 0 to array.size(vpRed) - 1
                gEnd = int(leftMax + (rightMax-leftMax)*(array.get(vpGreen,i)/rmv))
                rEnd = int(gEnd    + (rightMax-leftMax)*(array.get(vpRed,  i)/rmv))
                zTop = array.get(zoneBounds,i)
                zBot = zTop - gap
                if dispMode == 'Mode 2'
                    array.set(greenBoxes, i, box.new(int(leftMax), zTop-buf, gEnd, zBot+buf, bgcolor=bullCol, border_width=0))
                    array.set(redBoxes,   i, box.new(gEnd,         zTop-buf, rEnd, zBot+buf, bgcolor=bearCol, border_width=0))
                else if dispMode == 'Mode 1'
                    array.set(greenBoxes, i, box.new(int(leftMax), zTop-buf, gEnd, zBot+buf, bgcolor=bullCol, border_width=0))
                else
                    array.set(greenBoxes, i, box.new(int(leftMax),           zTop-buf, gEnd,         zBot+buf, bgcolor=bullCol, border_width=0))
                    array.set(redBoxes,   i, box.new(int(leftMax)-rEnd+gEnd, zTop-buf, int(leftMax), zBot+buf, bgcolor=bearCol, border_width=0))

        if showBox
            outBox := box.new(int(leftMax), profHigh, bar_index-1, profLow, boxBorderColor, boxBorder, bstyle(), bgcolor=boxBg)
        else
            outBox := na
        poc = pocLevel()
        [val, vah] = valueLevels(poc)
        if showPoc
            pocLine := line.new(int(leftMax), poc, lineEnd, poc, color=pocCol, width=pocWid, style=lstyle())
            label.new(lineEnd, poc, "POC " + sessionType, color=color.rgb(244,63,94,0), textcolor=pocCol, style=label.style_none, size=getLabelSize(levelLabelSize))
        if showVA
            vahLine := line.new(int(leftMax), vah, lineEnd, vah, color=vahCol, width=vahWid, style=lstyle())
            valLine := line.new(int(leftMax), val, lineEnd, val, color=valCol, width=valWid, style=lstyle())
            label.new(lineEnd, vah, "VAH " + sessionType, color=color.rgb(0,191,165,0), textcolor=vahCol, style=label.style_none, size=getLabelSize(levelLabelSize))
            label.new(lineEnd, val, "VAL " + sessionType, color=color.rgb(0,191,165,0), textcolor=valCol, style=label.style_none, size=getLabelSize(levelLabelSize))
        if showVAb
            box.new(int(leftMax), vah, bar_index-1, val, border_color=color.rgb(54,58,69,100), bgcolor=VAbCol)

    if del
        if not na(pocLine)
            line.delete(pocLine)
        if not na(vahLine)
            line.delete(vahLine)
        if not na(valLine)
            line.delete(valLine)
        if not na(outBox)
            box.delete(outBox)
        for i = 0 to array.size(greenBoxes) - 1
            bg = array.get(greenBoxes, i)
            br = array.get(redBoxes, i)
            if not na(bg)
                box.delete(bg)
            if not na(br)
                box.delete(br)

drawForexBox(startBar, title, top, bottom) =>
    if showBox
        box.new(int(startBar), top, bar_index-1, bottom, boxBorderColor, boxBorder, bstyle(), bgcolor=boxBg)
    if showLabels
        label.new((bar_index-1+int(startBar))/2, top, title, color=color.rgb(0,0,0,100), textcolor=sessionLabelColor, size=getLabelSize(sessionLabelSize))

// ============================================================
// EXECUTION
// ============================================================
calcSession(zoneEnd or (barstate.islast and showCur))
drawNewZone(zoneEnd)
drawCurZone(barstate.islast and not zoneEnd and showCur and activeZone, zoneEnd)

resetProfile(newSession)
updateIntra(dO, dH, dL, dC, dV, volScaleFactor)

if zoneEnd
    activeZone := false
if newSession
    zoneStart  := bar_index
    activeZone := true
if newLondon
    londonStart := bar_index
if newTokyo
    tokyoStart  := bar_index
if newNewYork
    nyStart     := bar_index

// FIX CRÍTICO: math.min + math.max protege contra "historical offset beyond buffer"
londonLB = math.max(1, math.min(bar_index - londonStart + 1, 999))
tokyoLB  = math.max(1, math.min(bar_index - tokyoStart  + 1, 999))
nyLB     = math.max(1, math.min(bar_index - nyStart      + 1, 999))

londonHigh = ta.highest(high, londonLB)
tokyoHigh  = ta.highest(high, tokyoLB)
nyHigh     = ta.highest(high, nyLB)
londonLow  = ta.lowest(low,  londonLB)
tokyoLow   = ta.lowest(low,  tokyoLB)
nyLow      = ta.lowest(low,  nyLB)

if endLondon  and showFx
    drawForexBox(londonStart, 'London',   londonHigh, londonLow)
if endNewYork and showFx
    drawForexBox(nyStart,     'New York', nyHigh,     nyLow)
if endTokyo   and showFx
    drawForexBox(tokyoStart,  'Tokyo',    tokyoHigh,  tokyoLow)

// ============================================================
// LIVE PANEL
// ============================================================
if barstate.islast and array.sum(vpGreen)+array.sum(vpRed) > 0 and not na(profHigh) and profHigh != profLow
    livePOC := pocLevel()
    if not na(livePOC)
        [lvl, lvh] = valueLevels(livePOC)
        liveVAL := lvl
        liveVAH := lvh

getPanelPos(p) =>
    switch p
        'Top Right'    => position.top_right
        'Top Left'     => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Left'  => position.bottom_left
        => position.top_right

if showPanel and barstate.islast
    if not na(infoPanel)
        table.delete(infoPanel)

    nRows = showTickerPanel ? 8 : 7
    infoPanel := table.new(getPanelPos(panelPos), 2, nRows, bgcolor=panelBgColor, border_width=1, border_color=color.gray)
    table.cell(infoPanel, 0, 0, "MOYA Volume Profile",                 text_color=panelTextColor, bgcolor=color.rgb(244,63,94,0), text_size=size.small)
    table.cell(infoPanel, 1, 0, sessionType,                           text_color=panelTextColor, bgcolor=color.rgb(244,63,94,0), text_size=size.small)
    table.cell(infoPanel, 0, 1, "POC",                                 text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 1, str.tostring(livePOC, format.mintick), text_color=color.rgb(244,63,94),  text_size=size.small)
    table.cell(infoPanel, 0, 2, "VAH",                                 text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 2, str.tostring(liveVAH, format.mintick), text_color=color.rgb(0,191,165),  text_size=size.small)
    table.cell(infoPanel, 0, 3, "VAL",                                 text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 3, str.tostring(liveVAL, format.mintick), text_color=color.rgb(0,191,165),  text_size=size.small)
    distPOC = close - livePOC
    table.cell(infoPanel, 0, 4, "POC Dist.",                           text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 4, str.tostring(distPOC, format.mintick), text_color=distPOC >= 0 ? color.rgb(0,191,165) : color.rgb(244,63,94), text_size=size.small)
    posVA = close > liveVAH ? "▲ Above VA" : close < liveVAL ? "▼ Below VA" : "● Inside VA"
    colVA = close > liveVAH ? color.rgb(0,191,165) : close < liveVAL ? color.rgb(244,63,94) : color.white
    table.cell(infoPanel, 0, 5, "Price vs VA",        text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 5, posVA,                 text_color=colVA,          text_size=size.small)
    table.cell(infoPanel, 0, 6, "VA %",                text_color=panelTextColor, text_size=size.small)
    table.cell(infoPanel, 1, 6, str.tostring(VAwid) + "%", text_color=panelTextColor, text_size=size.small)

    // Fila VOL. SOURCE — qué ticker de futuros está activo y si tiene data
    if showTickerPanel
        string srcText  = "Native"
        color  srcColor = panelTextColor
        if useExternalVol
            hasData = not na(externalVolume)
            modeTag = usingAutoNow ? " (auto)" : " (manual)"
            srcText  := (na(resolvedExtSymbol) ? "NO MATCH" : resolvedExtSymbol) + modeTag
            srcColor := hasData ? color.rgb(0,191,165) : color.rgb(244,63,94)
        table.cell(infoPanel, 0, 7, "Vol. Source",  text_color=panelTextColor, text_size=size.small)
        table.cell(infoPanel, 1, 7, srcText,        text_color=srcColor,       text_size=size.small)
````
