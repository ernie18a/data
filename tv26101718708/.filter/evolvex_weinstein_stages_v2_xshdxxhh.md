# EvolveX Weinstein Stages v2

- url: https://www.tradingview.com/script/xShdxXHH-EvolveX-Weinstein-Stages-v2/
- type: indicator
- pine_id: PUB;bf7734365c7542e089cfe1c3d9e736a3
- version: 2.0

## Description

Stan Weinstein stage analysis
Using Stage Analysis, it becomes clear that stocks typically go through four distinct stages in their lifecycle:
Stage One (Base)
Stage Two (Advancing)
Stage Three (Distribution)
Stage Four (Declining)

## Source Code

````pine
//@version=5
indicator("EvolveX Weinstein Stages", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
smaLength        = input.int(30,    "30W SMA Length",                      minval=1)
ma50Length       = input.int(50,    "50-Day MA Length",                    minval=1)
slopeLookback    = input.int(4,     "SMA Slope Lookback (wks)",            minval=1, maxval=10)
slopeThreshPct   = input.float(0.5, "SMA Flat Threshold % (4-wk change)",  minval=0.1, maxval=5.0, step=0.1)
volSmaLength     = input.int(10,    "Volume SMA Length (wks)",             minval=1)
volMultBreakout  = input.float(1.5, "Vol Multiplier – Breakout",           minval=1.0, step=0.1)
volMultBreakdown = input.float(1.5, "Vol Multiplier – Breakdown",          minval=1.0, step=0.1)
rsIndex          = input.symbol("SPY", "RS Benchmark  (use BTCUSDT for crypto altcoins)")
rsSmaLength      = input.int(10,    "Mansfield RS SMA (wks)",              minval=1)
showVolBars      = input.bool(true,  "Show Volume Surge Markers")
show50MA         = input.bool(true,  "Show 50-Day MA")
requireVolConfirm= input.bool(false, "Require Volume Confirm for Stage Entry (S1→S2 / S3→S4)")

// ─────────────────────────────────────────────────────────────────────────────
// CRYPTO AUTO-DETECTION
// RS vs SPY is meaningless for crypto; use RS vs BTC for altcoins.
// For BTC itself RS is disabled — nothing meaningful to compare against.
// ─────────────────────────────────────────────────────────────────────────────
isCrypto = syminfo.prefix == "BINANCE"  or syminfo.prefix == "COINBASE" or
           syminfo.prefix == "BYBIT"    or syminfo.prefix == "KRAKEN"   or
           syminfo.prefix == "BITFINEX" or syminfo.prefix == "BITMEX"   or
           syminfo.prefix == "BITSTAMP" or syminfo.prefix == "GEMINI"   or
           syminfo.prefix == "KUCOIN"   or syminfo.prefix == "OKX"
isBTC    = syminfo.basecurrency == "BTC" or
           syminfo.ticker == "BTCUSD"   or syminfo.ticker == "BTCUSDT"
rsActive = not isBTC   // RS disabled for BTC itself; active for all equities + altcoins

// ─────────────────────────────────────────────────────────────────────────────
// STAGE COLORS
//   S1 Base         → Sky Blue
//   S2 Advancing    → Vivid Green
//   S3 Distribution → Bright Orange
//   S4 Declining    → Vivid Red
// ─────────────────────────────────────────────────────────────────────────────
C_S1 = #29B6F6
C_S2 = #00C853
C_S3 = #FF6D00
C_S4 = #FF1744

// ─────────────────────────────────────────────────────────────────────────────
// WEEKLY DATA  (all computed inside request.security to avoid MTF distortion)
// ─────────────────────────────────────────────────────────────────────────────
[wClose, wOpen, wVol, wSMA] = request.security(
     syminfo.tickerid, "W",
     [close, open, volume, ta.sma(close, smaLength)],
     barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ── CRITICAL FIX: slope lookback computed IN weekly context ─────────────────
// Original code applied [slopeLookback] on the daily chart AFTER the security
// call — meaning [4] referenced 4 *daily* bars, not 4 *weeks*.
// This call computes the SMA 4 weekly bars ago correctly inside the W context.
wSMAPrior = request.security(syminfo.tickerid, "W",
     ta.sma(close, smaLength)[slopeLookback],
     barmerge.gaps_off, lookahead=barmerge.lookahead_off)

wVolSMA = request.security(syminfo.tickerid, "W",
     ta.sma(volume, volSmaLength),
     barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// 50-DAY MA  (daily timeframe, plotted as secondary reference)
// ─────────────────────────────────────────────────────────────────────────────
ma50 = ta.sma(close, ma50Length)

// ─────────────────────────────────────────────────────────────────────────────
// MANSFIELD RELATIVE STRENGTH
// Formula: (stock/benchmark ratio ÷ ratio 52w ago − 1) × 100
// Positive = outperforming; Negative = underperforming
// ─────────────────────────────────────────────────────────────────────────────
benchClose  = request.security(rsIndex, "W", close,
     barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsRatio     = wClose / benchClose
mansfieldRS = (rsRatio / rsRatio[52] - 1) * 100
mrsSmoothed = ta.sma(mansfieldRS, rsSmaLength)
rsRising    = mrsSmoothed > mrsSmoothed[1]
rsPositive  = mrsSmoothed > 0

// ─────────────────────────────────────────────────────────────────────────────
// SMA SLOPE CLASSIFICATION
// Flat:    |4-week SMA change| < slopeThreshPct% of current SMA value
// Rising:  positive slope beyond flat threshold
// Falling: negative slope beyond flat threshold
//
// IMPORTANT: these are mutually exclusive — isSMAFlat is checked first,
// so isSMARising and isSMAFalling are never true when the SMA is flat.
// ─────────────────────────────────────────────────────────────────────────────
smaSlope     = wSMA - wSMAPrior
slopePctAbs  = math.abs(smaSlope) / wSMA * 100
isSMAFlat    = slopePctAbs <= slopeThreshPct
isSMARising  = smaSlope > 0 and not isSMAFlat
isSMAFalling = smaSlope < 0 and not isSMAFlat

// ─────────────────────────────────────────────────────────────────────────────
// VOLUME FLAGS
// ─────────────────────────────────────────────────────────────────────────────
isVolSurgeUp   = wVol > wVolSMA * volMultBreakout  and wClose > wOpen
isVolSurgeDown = wVol > wVolSMA * volMultBreakdown and wClose < wOpen
isDryUpVol     = wVol < wVolSMA * 0.7

// ─────────────────────────────────────────────────────────────────────────────
// STRICT SEQUENTIAL STATE MACHINE
//
//   Weinstein's immutable cycle:  S1 → S2 → S3 → S4 → S1
//
//   S1  Base:         SMA FLAT. Price basing near 30W MA. Follows S4.
//   S2  Advancing:    Price ABOVE a RISING 30W MA. Entry from S1 needs vol confirm.
//   S3  Distribution: Follows S2. SMA flattens or turns. Price stalls/drops.
//   S4  Declining:    Price BELOW a FALLING 30W MA. Entry from S3 needs vol confirm.
//
//   ILLEGAL TRANSITIONS (prevented by checking prevStage):
//     S2 → S4  (must pass through S3)
//     S4 → S2  (must pass through S1)
//     S4 → S3  (S3 only follows S2)
//     S1 → S3  (S3 only follows S2)
//
//   Recovery allowed:
//     S3 → S2  (failed distribution — price reclaims rising SMA with vol)
//
//   Failed base:
//     S1 → S3 → S4  (base fails; S1→S3 fires first, then S3→S4 next bar)
// ─────────────────────────────────────────────────────────────────────────────
var color stageColor = na   // persists across bars; THIS is the source of truth

// prevStage = previous bar's confirmed stage
// Assigned at top before any this-bar updates — equivalent to stageColor[1]
color prevStage = stageColor

bool prevIsS1 = prevStage == C_S1
bool prevIsS2 = prevStage == C_S2
bool prevIsS3 = prevStage == C_S3
bool prevIsS4 = prevStage == C_S4
bool prevIsNA = na(prevStage)

// ── STAGE 2 ──────────────────────────────────────────────────────────────────
// Entry: from S1 or S3 (recovery), close above rising SMA, vol confirm optional
//   FIX: Original required wOpen > wSMA — this blocked the actual breakout bar
//   (where open is still below SMA in a S1 base). Only wClose matters.
// Hold:  was in S2 last bar AND price still above 30W SMA
//   Weinstein: "hold your position while the stock stays above the 30-week MA"
bool s2VolOk = requireVolConfirm ? isVolSurgeUp : true
bool s2Entry = (prevIsS1 or prevIsS3 or prevIsNA) and
               wClose > wSMA and isSMARising and s2VolOk
bool s2Hold  = prevIsS2 and wClose > wSMA
bool goS2    = s2Entry or s2Hold

// ── STAGE 3 ──────────────────────────────────────────────────────────────────
// Entry: was in S2 last bar but no longer meets S2 hold condition
//   (price fell below 30W SMA, OR SMA stopped rising → distribution begins)
//   Also: was in S1 and failed base (price drops below falling SMA)
// Hold:  stay in S3 while S2 has not been recaptured
bool s3Entry = (prevIsS2 and not goS2) or
               (prevIsS1 and wClose < wSMA and isSMAFalling)
bool s3Hold  = prevIsS3 and not goS2
bool goS3    = s3Entry or s3Hold

// ── STAGE 4 ──────────────────────────────────────────────────────────────────
// Entry: ONLY from S3. Close below falling SMA, vol confirm optional.
//   FIX: Original code checked S4 before S3 in the if/else chain — stocks
//   in S2 with price crashing below a falling SMA jumped directly to S4,
//   skipping S3 entirely. Now S4 entry is gated to prevIsS3 only.
// Hold:  was in S4 last bar AND price still below 30W SMA
//   Weinstein: "take the oath — never hold a stock in Stage 4"
bool s4VolOk = requireVolConfirm ? isVolSurgeDown : true
bool s4Entry = prevIsS3 and wClose < wSMA and isSMAFalling and s4VolOk
bool s4Hold  = prevIsS4 and wClose < wSMA
bool goS4    = s4Entry or s4Hold

// ── STAGE 1 ──────────────────────────────────────────────────────────────────
// Entry: from S4 when S4 hold breaks (price recovers above SMA or SMA flattens)
//   FIX: Original included isSMARising in S1 condition — Stage 1 is by
//   definition a FLAT SMA base. Rising SMA = S2 territory, not S1.
// Hold:  remain in S1 until S2 entry conditions are met
// Init:  on first bars (prevIsNA) default to S1 unless S2 conditions are met
bool s1Entry = prevIsS4 and not goS4
bool s1Hold  = prevIsS1 and not goS2
bool goS1    = s1Entry or s1Hold or (prevIsNA and not goS2)

// ── ASSIGN STAGE ─────────────────────────────────────────────────────────────
// Priority: S2 and S4 first (active trends), then S3 and S1 (transitions).
// S4 is only reachable from S3 (enforced above via prevIsS3 gate).
if goS2
    stageColor := C_S2
else if goS4
    stageColor := C_S4
else if goS3
    stageColor := C_S3
else if goS1
    stageColor := C_S1
// else: stageColor retains its prior var value (no unclassified bars)

// ─────────────────────────────────────────────────────────────────────────────
// BAR COLOR & MOVING AVERAGES
// ─────────────────────────────────────────────────────────────────────────────
barcolor(stageColor)

// 30W SMA — primary Weinstein trend filter (black, bold)
plot(wSMA, "30-Week SMA", color=color.black, linewidth=2)

// 50-Day MA — secondary reference (dashed grey)
plot(show50MA ? ma50 : na, "50-Day MA",
     color=color.new(#555555, 30), linewidth=1, style=plot.style_line)

// ─────────────────────────────────────────────────────────────────────────────
// STAGE 4 ENTRY LABEL  ("Take the oath")
// Fires once on the first bar of S4 — uses stageColor[1] which is the prior
// bar's confirmed stage (correct because stageColor is a var, so [1] = last
// bar's final value after its if/else assignment).
// ─────────────────────────────────────────────────────────────────────────────
bool s4JustEntered = stageColor == C_S4 and stageColor[1] != C_S4
if s4JustEntered
    label.new(bar_index, high,
         "⚠ S4",
         color=C_S4, textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// VOLUME SURGE MARKERS
// ─────────────────────────────────────────────────────────────────────────────
plotshape(showVolBars and isVolSurgeUp and
          (stageColor == C_S1 or stageColor == C_S2),
     "Vol Breakout",  shape.triangleup,   location.belowbar,
     color.new(C_S2, 10), size=size.tiny)

plotshape(showVolBars and isVolSurgeDown and
          (stageColor == C_S3 or stageColor == C_S4),
     "Vol Breakdown", shape.triangledown, location.abovebar,
     color.new(C_S4, 10), size=size.tiny)

plotshape(showVolBars and isDryUpVol and
          (stageColor == C_S1 or stageColor == C_S3),
     "Vol Dry-Up",    shape.circle,       location.belowbar,
     color.new(color.gray, 40), size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// TABLE — stage panel, Mansfield RS, volume status
// FIX: now reads stageColor (the single source of truth, a var) directly.
// Original read currentColor (non-var, reset each bar) which could show a
// stale or na value on the last bar depending on execution order.
// ─────────────────────────────────────────────────────────────────────────────
var table t = table.new(
     position.bottom_right, 2, 7,
     bgcolor=color.new(#FFFFFF, 0),
     border_width=1,
     border_color=color.new(#CCCCCC, 0),
     frame_width=2,
     frame_color=color.new(#888888, 0))

if barstate.islast
    bool isS1 = stageColor == C_S1
    bool isS2 = stageColor == C_S2
    bool isS3 = stageColor == C_S3
    bool isS4 = stageColor == C_S4

    // SMA direction label for header
    string smaDir = isSMAFlat    ? " (Flat ─)" :isSMARising  ? " (Rising ↑)"  : " (Falling ↓)"

    // ── Row 0: Header ────────────────────────────────────────────────────────
    table.cell(t, 0, 0, "Weinstein Stage Analysis",
         bgcolor=color.new(#222222, 0), text_color=color.white,
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 0, "30W SMA" + smaDir,
         bgcolor=color.new(#222222, 0), text_color=color.new(#AAAAAA, 0),
         text_size=size.normal, text_halign=text.align_right)

    // ── Row 1: Stage 1 – Base ─────────────────────────────────────────────
    table.cell(t, 0, 1, "  S1   Base",
         bgcolor=isS1 ? C_S1 : color.new(#F0F0F0, 0),
         text_color=isS1 ? color.white : color.new(#29B6F6, 0),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 1, isS1 ? "● ACTIVE" : "",
         bgcolor=isS1 ? C_S1 : color.new(#F0F0F0, 0),
         text_color=isS1 ? color.white : color.new(#29B6F6, 0),
         text_size=size.normal, text_halign=text.align_right)

    // ── Row 2: Stage 2 – Advancing ────────────────────────────────────────
    table.cell(t, 0, 2, "  S2   Advancing",
         bgcolor=isS2 ? C_S2 : color.new(#F0F0F0, 0),
         text_color=isS2 ? color.white : color.new(#00C853, 0),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 2, isS2 ? "● ACTIVE" : "",
         bgcolor=isS2 ? C_S2 : color.new(#F0F0F0, 0),
         text_color=isS2 ? color.white : color.new(#00C853, 0),
         text_size=size.normal, text_halign=text.align_right)

    // ── Row 3: Stage 3 – Distribution ────────────────────────────────────
    table.cell(t, 0, 3, "  S3   Distribution",
         bgcolor=isS3 ? C_S3 : color.new(#F0F0F0, 0),
         text_color=isS3 ? color.white : color.new(#FF6D00, 0),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 3, isS3 ? "● ACTIVE" : "",
         bgcolor=isS3 ? C_S3 : color.new(#F0F0F0, 0),
         text_color=isS3 ? color.white : color.new(#FF6D00, 0),
         text_size=size.normal, text_halign=text.align_right)

    // ── Row 4: Stage 4 – Declining ────────────────────────────────────────
    table.cell(t, 0, 4, "  S4   Declining",
         bgcolor=isS4 ? C_S4 : color.new(#F0F0F0, 0),
         text_color=isS4 ? color.white : color.new(#FF1744, 0),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 4, isS4 ? "● ACTIVE" : "",
         bgcolor=isS4 ? C_S4 : color.new(#F0F0F0, 0),
         text_color=isS4 ? color.white : color.new(#FF1744, 0),
         text_size=size.normal, text_halign=text.align_right)

    // ── Row 5: Mansfield RS + Volume ─────────────────────────────────────
    string mrsLabel = isCrypto and not isBTC ? "RS vs BTC" :
                      isBTC                  ? "RS: N/A"   :
                                               "Mansfield RS"
    string mrsText  = not rsActive                       ? "RS: N/A (BTC)"             :
                      rsPositive  and rsRising           ? mrsLabel + ": + Rising  ↑"  :
                      rsPositive  and not rsRising       ? mrsLabel + ": + Falling ↓"  :
                      not rsPositive and rsRising        ? mrsLabel + ": − Rising  ↑"  :
                                                           mrsLabel + ": − Falling ↓"
    color mrsColor  = not rsActive ? color.new(#999999, 0) :
                      rsPositive   ? color.new(#1565C0, 0) : color.new(#AD1457, 0)

    table.cell(t, 0, 5, mrsText,
         bgcolor=color.new(#EEEEEE, 0), text_color=mrsColor,
         text_size=size.normal, text_halign=text.align_left)

    string volText  = isVolSurgeUp   ? "Vol: Surge ▲" :
                      isVolSurgeDown ? "Vol: Surge ▼" :
                      isDryUpVol     ? "Vol: Dry-Up"  : "Vol: Normal"
    color  volColor = isVolSurgeUp   ? C_S2 :
                      isVolSurgeDown ? C_S4 : color.new(#555555, 0)

    table.cell(t, 1, 5, volText,
         bgcolor=color.new(#EEEEEE, 0), text_color=volColor,
         text_size=size.normal, text_halign=text.align_left)

    // ── Row 6: S4 Exit Warning ────────────────────────────────────────────
    table.cell(t, 0, 6, isS4 ? "⚠  STAGE 4 — EXIT ALL LONGS" : "",
         bgcolor=isS4 ? color.new(C_S4, 60) : color.new(#EEEEEE, 0),
         text_color=color.white,
         text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 6, "",
         bgcolor=isS4 ? color.new(C_S4, 60) : color.new(#EEEEEE, 0))
````
