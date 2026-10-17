# Auto Swing Trade Set Up v1.0 by [Itto-Ryu]

- url: https://www.tradingview.com/script/VJLIg6Ir-Auto-Swing-Trade-Set-Up-v1-0-by-Itto-Ryu/
- type: indicator
- pine_id: PUB;aaf05f7133c548548eebc4f82269f598
- version: 1.0

## Description

Auto Swing Trade Set Up v1.0 is a Pine Script indicator for TradingView, built for swing traders who have already decided their directional bias from external analysis and need a clean, math-consistent way to draw their entry, stop loss, take profit, and reversal levels on the chart.

Element Visual Purpose
Z1 (first fill) Solid amber box Primary entry zone
Z2 (averaging) Dashed amber box Secondary fill if price extends
Entry mid Dotted amber line The midpoint reference
SL Thick red line Stop loss (ATR-based)
TP1 Green dotted line Take 50% off here
TP2 Teal dotted line Take next 50% (or trail)
SFlip Purple dashed line Above this: Long thesis broken
LFlip Pink dashed line Below this: Short thesis broken
Direction badge Right of price ▲ LONG / ▼ SHORT + R:R ratio


Who This Is For
This tool is built for:
• Discretionary traders who form directional bias from fundamentals, news, sentiment, or proprietary analysis — and need a quick way to mark levels on the chart.
• CMT analysts who score setups using the 7-Pillar Rule-Based System and want the chart to reflect the decision, not make it.
• Crypto / FX / equity swing traders who think in pullback entries with averaging zones,
ATR-anchored stops, and R:R-based targets.
• Anyone who finds full-auto indicators noisy — too many false signals, too many ignored alerts,
too many overrides.

Who This Is NOT For
• Traders who want the indicator to tell them what to do.
• Algorithmic / fully automated systems
• Beginners who haven't yet developed a directional framework.

Principle One : Math, Not Judgment
All level calculations are pure formulas: entry midpoint, ATR multiples, R:R ratios. No conditional logic.No "if RSI is overbought then shift the stop." The same inputs always produce the same outputs.Why this matters: reproducibility. If you mark a Long on BTCUSD at 18:00 with these settings, then check the same chart tomorrow, the zones will be in the same place relative to that bar. There is no hidden state, no learned behavior, no drift.

Principle Two : One Decision, Many Outputs
The only decision you make is Long or Short. From that one bit of information, the indicator produces nine distinct visual elements (two zones, entry mid, SL, TP1, TP2, SFlip, LFlip, direction badge with R:R) each of them quantitatively derived

Why Manual Direction

The trader required to use other indicator for trend identifier and momentum such as EMA 20/50/100/200 , Ichimoku Cloud ,Price pattern and Dow theory , MACD, RSI ,ADX and etc. depend on their familiar or expertise in order to identify the whether they will open Long or Short . This indicator will help trader to get an outline instantly of action zone , entry , SL , TP and other critical point . However , manual decision for short or long might have an advantage because the auto detection or trend following signal might have a fall back as bellowing

• Chop kills auto signals. When price oscillates near the threshold, the indicator flips
Long-Short-Long, generating false setups every few bars.

• Late entries on real moves. When a strong trend breaks out, the indicator confirms only after the optimal entry zone has passed.

• Wrong side on news shocks. When fundamentals (CPI, FOMC, earnings) drive a sudden direction change, technicals lag the move by hours.

So , in practical especially swing trader who gain the profit from the gap might are required to doing the preemptive action such as open short 10% or a few portion when their consider it might be a peak so they can open in the good position before the signal is confirm

The Entry Midpoint

The entry midpoint (entryMid) is the single most important value the indicator computes. Everything else zones, SL, TP, flips — is derived from it.

Reference Selection
Two reference lines are pulled from the chart:
• EMA Fast (default length 20) — the standard short-term trend follower
• BB Basis (SMA-20) — the midline of the Bollinger Band system

The indicator then picks the appropriate one based on your chosen direction:
refHi = max(EMA20, BB_basis)
refLo = min(EMA20, BB_basis)
entryMid = isLong ? refHi : refLo
Rationale: For a Long, you want to enter on a pullback toward a support reference — the higher of the two candidates is usually closer to current price, making fills more likely. For a Short, the inverse.

ATR Clamping
Raw EMA/BB references sometimes sit too close to (or too far from) current price to be useful as entry zones. The indicator clamps the entryMid into a sensible band defined by ATR:
// LONG case
if entryMid > close: // too high
entryMid = close − ATR × 0.3
elif entryMid < close − ATR × 0.7: // too low
entryMid = close − ATR × 0.5

Dual Entry Zones
The indicator paints two zones stacked around the entryMid:

Zone Formulas
For a Long setup:
zone1Hi = entryMid + ATR × Z1_width // above mid
zone1Lo = entryMid // at mid
zone2Hi = entryMid // at mid
zone2Lo = entryMid − ATR × Z2_width // below mid
For a Short setup, the geometry inverts: Z1 sits below mid (first fill on a rally) and Z2 sits above
(averaging if rally extends).

Default Widths
Parameter Default Meaning
Z1 width 0.3 × ATR Slim zone for primary fill
Z2 width 0.6 × ATR Wider zone for averaging fills

How to Use Each Zone

Z1 (first fill, solid amber): Your primary entry. Allocate the larger portion of your intended position size here. Typical approach is 60-70% of position into Z1.

Z2 (averaging, dashed amber): Only triggers if price pushes past entryMid into the deep zone. Allocate the remaining 30-40% here. Beyond Z2, the next reference is SL — if price reaches SL without bouncing, the trade is invalidated and you accept the loss as planned.

Warning: Z2 is for averaging, NOT for unlimited adding. The math assumes total position cost basis falls between entryMid and Z2's deep edge. Adding outside Z2 voids the SL/TP geometry — your actual R:R will not match what's displayed.

Stop Loss (SL)

// LONG
slLevel = entryMid − ATR × SL_multiplier

// SHORT
slLevel = entryMid + ATR × SL_multiplier
risk = abs(entryMid − slLevel)

Default SL multiplier: 1.5 × ATR. This places the stop outside ordinary volatility, reducing premature stop-outs from noise while keeping the loss bounded.

Take Profit (TP1 & TP2) TPs are computed by R:R multiples of the calculated risk:

// LONG
tp1Level = entryMid + risk × TP1_RR // default RR = 1.5
tp2Level = entryMid + risk × TP2_RR // default RR = 2.5
// SHORT (subtract instead of add)

Execution playbook:
• TP1 hit: Close 50% of position. Move SL to breakeven (entryMid) for the remainder.
• TP2 hit: Close 25% of position. Trail the final 25% with EMA20 or a moving stop.
• Beyond TP2: You are now in a runner. The trade has paid its R, your downside is zero (breakeven SL). Let the winner work.

Flip Lines (SFlip & LFlip)

Flip lines mark the points where your directional thesis is broken. If price closes past a flip line, you should re-evaluate — possibly exiting and flipping direction.

// LONG case
shortFlip = entryMid + ATR × Flip_multiplier // upside flip
longFlip = slLevel // = SL

// SHORT case
shortFlip = slLevel // = SL
longFlip = entryMid − ATR × Flip_multiplier // downside flip

Default Flip multiplier: 2.0 × ATR. The asymmetry is deliberate: one flip line coincides with your SL(because if SL is hit, the thesis is dead by definition); the other sits one extra ATR's worth out, marking the point where the OPPOSITE trade would now make sense.

Settings & Configuration

All settings are accessible via the indicator's Settings dialog in TradingView. Defaults are tuned for swing trading on 1H-Daily charts; adjust per timeframe and instrument.

Trade Direction Group
Input Type Default Purpose
Direction Dropdown Long Pick Long or Short
Show Zones Checkbox True Master on/off for all visuals

Risk Settings Group

Input Default Purpose
SL = ATR x 1.5 Stop multiplier
TP1 R:R 1.5 First profit target ratio
TP2 R:R 2.5 Second profit target ratio
Flip = ATR x 2.0 Direction-flip threshold
Line Length 50 bars How far back lines/boxes extend
Zone 1 width 0.3 × ATR Slim entry zone
Zone 2 width 0.6 × ATR Wide averaging zone

Tuning Per Timeframe

The defaults are a balanced compromise. For your style, consider:
Timeframe SL TP1 TP2 Flip
Scalp (5-15m) 1.0 1.0 1.5 1.5
Intraday (1H) 1.2 1.5 2.5 2.0
Swing (4H-D) 1.5 (default) 1.5 2.5 2.0
Position (D-W) 2.0 2.0 3.5 3.0

Common Mistakes To Avoid
• Re-running the indicator after price has moved. The zones recompute live on each bar. If you
formed your thesis at one bar's close, place your orders at THOSE levels, not the levels the indicator shows three bars later.
• Flipping direction without exiting first. Toggling Long → Short while a Long position is open
generates new zones for the Short setup but does NOT close your Long. Close manually first.
• Trading both directions on the same chart. Don't load two instances. Use one chart per
directional view. If you need to see both, use chart layouts (vertical split).
• Ignoring the SFlip / LFlip lines. These are not decorative. When price breaks them on a closing
basis, your thesis is broken. Acknowledge it.
• Over-tweaking the ATR multipliers per trade. Pick a setting per timeframe and stick with it for at least 20 trades before adjusting. Frequent tweaking is curve-fitting.

Enjoy ! developed by Thiranat Ngamchitcharoen (Itto-Ryu)

( Itto-Ryu is derived from school of one cut , this inspired me to create the series of indicator that help the trader which often need to make a decision at a glance before a good position have passed . )
Protected script

This script is published as closed-source. However, you can use it freely and without any limitations – learn more here.


Thiranat
Disclaimer
The information and publications are not meant to be, and do not constitute, financial, investment, trading, or other types of advice or recommendations supplied or endorsed by TradingView. Read more in the Terms of Use.

## Source Code

````pine
//@version=6
indicator("Auto Swing Trade Set Up v1.0 by [Itto-Ryu]", overlay=true, max_lines_count=50, max_labels_count=15, max_boxes_count=5)

// ═══════════════════════════════════════════════════════════════
// AUTO SWING TRADE SET UP v1.0 by [Itto-Ryu]
//
// Manual direction swing-trade zone tool — NO auto-detection,
// NO trend scoring, NO MTF analysis. Trader picks Long/Short,
// indicator draws Entry/SL/TP/Flip zones using ATR-based math.
//
// FEATURES:
//   1. Manual Long/Short direction toggle
//   2. Smart Entry mid: EMA20/BB mid + ATR clamp (from v4.3 Pro)
//   3. Dual entry zones (Z1 first fill / Z2 averaging)
//   4. ATR-based SL + dual TP (R:R 1.5/2.5)
//   5. Short/Long flip levels
//   6. On-chart labels for every level
//   7. Hit alerts (Z1/Z2/SL/TP1/TP2)
//   8. Clean chart — NO dashboard, NO clutter
//
// USE CASE:
//   When you've already decided direction from external analysis
//   (CMT 7-Pillar, technical levels, news, etc.) and just need
//   the indicator to draw a clean, math-consistent trade plan.
// ═══════════════════════════════════════════════════════════════

// ─── Mode ───
grp_mode = "Trade Direction"
i_dir = input.string("Long", "Direction", options=["Long", "Short"], group=grp_mode, tooltip="Manual direction selection. No auto-detection.")
i_active = input.bool(true, "Show Zones", group=grp_mode, tooltip="Toggle entire zone display on/off")

// ─── Risk Settings ───
grp_risk = "Risk Settings"
i_sl_atr = input.float(1.5, "SL = ATR x", minval=0.5, step=0.1, group=grp_risk)
i_tp1_rr = input.float(1.5, "TP1 R:R", minval=1.0, step=0.1, group=grp_risk)
i_tp2_rr = input.float(2.5, "TP2 R:R", minval=1.0, step=0.1, group=grp_risk)
i_flip_atr = input.float(2.0, "Flip = ATR x", minval=1.0, step=0.1, group=grp_risk)
i_line_len = input.int(50, "Line Length (bars)", minval=10, maxval=200, group=grp_risk)
i_zone1_atr = input.float(0.3, "Zone 1 width (ATR x)", minval=0.1, step=0.1, group=grp_risk)
i_zone2_atr = input.float(0.6, "Zone 2 width (ATR x)", minval=0.2, step=0.1, group=grp_risk)

// ─── Indicator Settings ───
grp_ind = "Reference Indicators"
i_ema_fast = input.int(20, "EMA Fast (entry ref)", group=grp_ind)
i_bb_len = input.int(20, "BB Length (entry ref)", group=grp_ind)
i_atr_len = input.int(14, "ATR Length", group=grp_ind)

// ═══════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
emaFast = ta.ema(close, i_ema_fast)
bbBasis = ta.sma(close, i_bb_len)
atrVal = ta.atr(i_atr_len)

bool isLong = i_dir == "Long"

// ─── Smart entryMid: choose nearest reference (EMA20 or BB midline), then clamp ───
// For LONG: prefer reference that's BELOW current price but not too far (pullback target)
// For SHORT: prefer reference that's ABOVE current price but not too far (rally target)
float refHi = math.max(emaFast, bbBasis)
float refLo = math.min(emaFast, bbBasis)
float entryMid = isLong ? refHi : refLo

// LONG: ideal entry is below current price, ~0.3-0.7 ATR away (pullback zone)
if isLong
    if entryMid > close                              // entry above price → pull down
        entryMid := close - atrVal * 0.3
    else if entryMid < close - atrVal * 0.7           // entry too far below → won't fill
        entryMid := close - atrVal * 0.5

// SHORT: ideal entry is above current price, ~0.3-0.7 ATR away (rally zone)
if not isLong
    if entryMid < close                              // entry below price → push up
        entryMid := close + atrVal * 0.3
    else if entryMid > close + atrVal * 0.7           // entry too far above → won't fill
        entryMid := close + atrVal * 0.5

// ─── Zone calculation ───
float zone1Hi = isLong ? entryMid + atrVal * i_zone1_atr : entryMid
float zone1Lo = isLong ? entryMid : entryMid - atrVal * i_zone1_atr
float zone2Hi = isLong ? entryMid : entryMid + atrVal * i_zone2_atr
float zone2Lo = isLong ? entryMid - atrVal * i_zone2_atr : entryMid

float slLevel = isLong ? entryMid - atrVal * i_sl_atr : entryMid + atrVal * i_sl_atr
float risk = math.abs(entryMid - slLevel)
float tp1Level = isLong ? entryMid + risk * i_tp1_rr : entryMid - risk * i_tp1_rr
float tp2Level = isLong ? entryMid + risk * i_tp2_rr : entryMid - risk * i_tp2_rr
float shortFlip = isLong ? entryMid + atrVal * i_flip_atr : slLevel
float longFlip = isLong ? slLevel : entryMid - atrVal * i_flip_atr

// ═══════════════════════════════════════════════════════════════
// COLORS (Long=green tones, Short=red tones for direction badge)
// Zone fill = amber (neutral entry color) for both directions
// ═══════════════════════════════════════════════════════════════
color c_entry    = color.new(#EF9F27, 0)            // amber
color c_zone1_bg = color.new(#EF9F27, 85)
color c_zone2_bg = color.new(#EF9F27, 70)
color c_sl       = color.new(#EF4444, 0)            // red
color c_tp1      = color.new(#22C55E, 0)            // green
color c_tp2      = color.new(#5DCAA5, 0)            // teal
color c_sflip    = color.new(#A855F7, 0)            // purple
color c_lflip    = color.new(#EC4899, 0)            // pink

color c_dirBadge = isLong ? color.new(#22C55E, 0) : color.new(#EF4444, 0)

// ═══════════════════════════════════════════════════════════════
// RENDERING
// ═══════════════════════════════════════════════════════════════
var line lnEntryMid = na
var line lnEntryHi = na
var line lnEntryLo = na
var line lnSL = na
var line lnTP1 = na
var line lnTP2 = na
var line lnSFlip = na
var line lnLFlip = na
var box bxZone1 = na
var box bxZone2 = na
var label lbZone1 = na
var label lbZone2 = na
var label lbSL = na
var label lbTP1 = na
var label lbTP2 = na
var label lbSFlip = na
var label lbLFlip = na
var label lbDirection = na

if barstate.islast and i_active
    int x1 = bar_index - i_line_len
    int x2 = bar_index + 10

    // Cleanup
    line.delete(lnEntryMid)
    line.delete(lnEntryHi)
    line.delete(lnEntryLo)
    line.delete(lnSL)
    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnSFlip)
    line.delete(lnLFlip)
    box.delete(bxZone1)
    box.delete(bxZone2)
    label.delete(lbZone1)
    label.delete(lbZone2)
    label.delete(lbSL)
    label.delete(lbTP1)
    label.delete(lbTP2)
    label.delete(lbSFlip)
    label.delete(lbLFlip)
    label.delete(lbDirection)

    // ─── Entry boundary lines ───
    float entryHi = isLong ? zone1Hi : zone2Hi
    float entryLo = isLong ? zone2Lo : zone1Lo

    lnEntryHi := line.new(x1, entryHi, x2, entryHi, color=c_entry, width=2)
    lnEntryLo := line.new(x1, entryLo, x2, entryLo, color=c_entry, width=2, style=line.style_dashed)
    lnEntryMid := line.new(x1, entryMid, x2, entryMid, color=c_entry, width=1, style=line.style_dotted)

    // ─── Zone boxes ───
    bxZone1 := box.new(x1, zone1Hi, x2, zone1Lo, border_color=c_entry, border_width=1, border_style=line.style_solid, bgcolor=c_zone1_bg)
    bxZone2 := box.new(x1, zone2Hi, x2, zone2Lo, border_color=c_entry, border_width=1, border_style=line.style_dashed, bgcolor=c_zone2_bg)

    // ─── SL / TP / Flip lines ───
    lnSL := line.new(x1, slLevel, x2, slLevel, color=c_sl, width=3)
    lnTP1 := line.new(x1, tp1Level, x2, tp1Level, color=c_tp1, width=2, style=line.style_dotted)
    lnTP2 := line.new(x1, tp2Level, x2, tp2Level, color=c_tp2, width=2, style=line.style_dotted)
    lnSFlip := line.new(x1, shortFlip, x2, shortFlip, color=c_sflip, width=1, style=line.style_dashed)
    lnLFlip := line.new(x1, longFlip, x2, longFlip, color=c_lflip, width=1, style=line.style_dashed)

    // ─── Labels ───
    float zone1Mid = (zone1Hi + zone1Lo) / 2
    float zone2Mid = (zone2Hi + zone2Lo) / 2

    lbZone1 := label.new(x2, zone1Mid, "Z1 " + str.tostring(zone1Lo, format.mintick) + "-" + str.tostring(zone1Hi, format.mintick), xloc.bar_index, yloc.price, c_entry, label.style_label_left, color.black, size.small)
    lbZone2 := label.new(x2, zone2Mid, "Z2 " + str.tostring(zone2Lo, format.mintick) + "-" + str.tostring(zone2Hi, format.mintick), xloc.bar_index, yloc.price, color.new(#EF9F27, 30), label.style_label_left, color.white, size.small)
    lbSL := label.new(x2, slLevel, "SL " + str.tostring(slLevel, format.mintick), xloc.bar_index, yloc.price, c_sl, label.style_label_left, color.white, size.small)
    lbTP1 := label.new(x2, tp1Level, "TP1 " + str.tostring(tp1Level, format.mintick), xloc.bar_index, yloc.price, c_tp1, label.style_label_left, color.black, size.small)
    lbTP2 := label.new(x2, tp2Level, "TP2 " + str.tostring(tp2Level, format.mintick), xloc.bar_index, yloc.price, c_tp2, label.style_label_left, color.black, size.small)
    lbSFlip := label.new(x2, shortFlip, "SFLIP " + str.tostring(shortFlip, format.mintick), xloc.bar_index, yloc.price, c_sflip, label.style_label_left, color.white, size.small)
    lbLFlip := label.new(x2, longFlip, "LFLIP " + str.tostring(longFlip, format.mintick), xloc.bar_index, yloc.price, c_lflip, label.style_label_left, color.white, size.small)

    // ─── Direction badge (right of entryMid) ───
    string dirText = isLong ? "▲ LONG" : "▼ SHORT"
    float rr1 = math.abs(entryMid - tp1Level) / risk
    float rr2 = math.abs(entryMid - tp2Level) / risk
    string badgeText = dirText + "  R:R " + str.tostring(rr1, "0.0") + " / " + str.tostring(rr2, "0.0")
    lbDirection := label.new(bar_index + 25, entryMid, badgeText, xloc.bar_index, yloc.price, c_dirBadge, label.style_label_left, color.white, size.normal)

// ═══════════════════════════════════════════════════════════════
// HIT DETECTION + PLOTSHAPES
// ═══════════════════════════════════════════════════════════════
zone1Hit = i_active and low <= zone1Hi and high >= zone1Lo
zone2Hit = i_active and low <= zone2Hi and high >= zone2Lo
slHitLong  = i_active and isLong and ta.crossunder(low, slLevel)
slHitShort = i_active and not isLong and ta.crossover(high, slLevel)
tp1HitLong  = i_active and isLong and ta.crossover(high, tp1Level)
tp1HitShort = i_active and not isLong and ta.crossunder(low, tp1Level)
tp2HitLong  = i_active and isLong and ta.crossover(high, tp2Level)
tp2HitShort = i_active and not isLong and ta.crossunder(low, tp2Level)

plotshape(zone1Hit and not zone1Hit[1], "Zone 1", shape.diamond, location.belowbar, color.new(#EF9F27, 0), size=size.tiny, text="Z1")
plotshape(zone2Hit and not zone2Hit[1], "Zone 2", shape.diamond, location.belowbar, color.new(#EF9F27, 30), size=size.tiny, text="Z2")
plotshape(slHitLong,  "SL Long",  shape.xcross,       location.belowbar, color.new(#EF4444, 0), size=size.small)
plotshape(slHitShort, "SL Short", shape.xcross,       location.abovebar, color.new(#EF4444, 0), size=size.small)
plotshape(tp1HitLong,  "TP1 Long",  shape.triangleup,   location.abovebar, color.new(#22C55E, 0), size=size.small)
plotshape(tp1HitShort, "TP1 Short", shape.triangledown, location.belowbar, color.new(#22C55E, 0), size=size.small)
plotshape(tp2HitLong,  "TP2 Long",  shape.triangleup,   location.abovebar, color.new(#5DCAA5, 0), size=size.small)
plotshape(tp2HitShort, "TP2 Short", shape.triangledown, location.belowbar, color.new(#5DCAA5, 0), size=size.small)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(zone1Hit and not zone1Hit[1], "Zone 1 Hit", "Price entered Zone 1 (first fill)")
alertcondition(zone2Hit and not zone2Hit[1], "Zone 2 Hit", "Price entered Zone 2 (averaging zone)")
alertcondition(slHitLong  or slHitShort,  "SL Hit",  "STOP LOSS hit — EXIT")
alertcondition(tp1HitLong or tp1HitShort, "TP1 Hit", "TP1 hit — close 50%")
alertcondition(tp2HitLong or tp2HitShort, "TP2 Hit", "TP2 hit — close remaining")
alertcondition(ta.crossover(high, shortFlip)  and isLong,      "Long Flip", "Long signal flipped — re-evaluate")
alertcondition(ta.crossunder(low, longFlip) and not isLong,    "Short Flip", "Short signal flipped — re-evaluate")
````
