# SMC Supply & Demand Zones - H4 / H1 / M10

- url: https://www.tradingview.com/script/zQkubyMl-SMC-Supply-Demand-Zones-H4-H1-M10/
- type: indicator
- pine_id: PUB;f87dea9f3c67414e809f04cef48fab66
- version: 9.0

## Description

Automatically identifies and draws supply and demand zones across three timeframes (H4, H1, and M10) simultaneously on any chart, using a strict volume-confirmed impulse candle definition rooted in Smart Money Concepts (SMC).
How zones are built
A zone is created only when all three conditions are met on the same candle:

Body size ≥ 1.5 × ATR(14) — filters out indecision candles
Close breaks beyond the prior 5 candles' high (demand) or low (supply) — confirms impulsive intent
Volume ≥ 1.5 × SMA(volume, 20) — requires institutional-level participation

Zone boundaries follow the SMC base candle rule: demand zones span from the impulse candle's open down to its low; supply zones span from its high down to its open.
Visual design
Each timeframe uses a distinct colour family so you can read confluence at a glance — H4 in blue, H1 in orange, M10 in green. Lighter shades mark demand, darker shades mark supply. When price closes fully through a zone, it fades to grey and is tagged with [m] (mitigated) — it stays on the chart for context but is visually de-emphasised. Each zone carries a label (e.g. "H4 D", "H1 S") pinned to its right edge.
Settings

Toggle each timeframe on/off independently
Adjust the body multiplier, prior-bar lookback, and volume multiplier to match the instrument
Set separate caps for active and mitigated zones per timeframe (FIFO — oldest removed first)
Full colour control per timeframe and direction
Toggle labels and borders separately

Non-repainting
All three timeframe feeds use request.security() with lookahead = barmerge.lookahead_off and gaps = barmerge.gaps_off. Zones are created only on the bar where an impulse candle's close is first confirmed — no bar-0 data is used.
Recommended use
Load on your entry timeframe (M10 or M5) and use the H4/H1 zones as bias and confluence levels. Look for price to sweep into a higher-TF zone and react — that is your area of interest for entry confirmation on the lower timeframe.

## Source Code

````pine
//@version=6
indicator(
     title            = "SMC Supply & Demand Zones — H4 / 2H / H1 / M30 / M10 / M5 / M1",
     shorttitle       = "SD Zones v1.7",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500)

// ══════════════════════════════════════════════════════════════════════════════
// ── INPUTS
// ══════════════════════════════════════════════════════════════════════════════
// gbpusd 8/1 8/1.5
//eurgbp 8/1.1 8/1.3
// Timeframe toggles
i_showH4    = input.bool(true,  "Show H4 zones",   group = "Timeframes")
i_showH2    = input.bool(true, "Show 2H zones",   group = "Timeframes")
i_showH1    = input.bool(true,  "Show H1 zones",   group = "Timeframes")
i_show30m   = input.bool(false, "Show M30 zones",  group = "Timeframes")
i_showM10   = input.bool(false,  "Show M10 zones",  group = "Timeframes")
i_showM5    = input.bool(false, "Show M5 zones",   group = "Timeframes")
i_showM1    = input.bool(false, "Show M1 zones",   group = "Timeframes")

// Impulse detection
i_atrLen    = input.int  (8,  "ATR length",
              minval  = 1, maxval = 200,
              tooltip = "Period for the ATR used in impulse body-size filtering. Applied to every timeframe.",
              group   = "Impulse Detection")
i_bodyMult  = input.float(0.8, "Body ≥ ATR ×",
              minval  = 0.1, step = 0.1,
              tooltip = "Impulse body must be at least this multiple of ATR(length).",
              group   = "Impulse Detection")
i_priorLen  = input.int  (2, "Prior bars for Hi/Lo break",
              minval  = 2, maxval = 50,
              tooltip = "Number of prior bars whose high (or low) the impulse close must exceed.",
              group   = "Impulse Detection")
i_volSmaLen = input.int  (8,  "Volume MA length",
              minval  = 2, maxval = 200,
              tooltip = "Lookback period for the volume moving average used in the impulse filter. Applies to H4 / 2H / H1 / M30 / M10.",
              group   = "Impulse Detection")
i_volSmaLenLTF = input.int(20, "Volume MA length (M5 / M1)",
              minval  = 2, maxval = 200,
              tooltip = "Separate volume-SMA lookback used only for the M5 and M1 timeframes. Lower timeframes are noisier, so a longer baseline is usually preferable.",
              group   = "Impulse Detection")
i_volMaType = input.string("SMA", "Volume MA type",
              options = ["SMA", "WMA"],
              tooltip = "Averaging method for the volume baseline in the impulse filter. SMA weights every bar equally (steadier, more conservative). WMA weights recent bars more (adapts faster to changing volume). Applies to all timeframes.",
              group   = "Impulse Detection")
i_volMult   = input.float(1.1, "Volume ≥ MA ×",
              minval  = 0.1, step = 0.1,
              tooltip = "Impulse candle volume must be at least this multiple of the volume MA (SMA or WMA).",
              group   = "Impulse Detection")

// Zone management
i_maxZones  = input.int(20, "Max active zones per TF",
              minval  = 1, maxval = 100,
              tooltip = "Oldest zone is dropped (FIFO) when this cap is reached.",
              group   = "Zone Management")
i_maxMit    = input.int(10, "Max mitigated zones per TF",
              minval  = 0, maxval = 50,
              tooltip = "Oldest mitigated zone is dropped (FIFO) when this cap is reached.",
              group   = "Zone Management")
i_onTouch   = input.string("Stop stretch", "On zone touch",
              options  = ["Extend always", "Stop stretch", "Delete"],
              tooltip  = "Extend always: box grows right indefinitely. Stop stretch: right edge freezes the bar price first re-enters the zone. Delete: zone removed immediately on touch.",
              group    = "Zone Management")
i_touchCooldown = input.int(60, "Touch cooldown (minutes)",
              minval  = 0, maxval = 1440,
              tooltip = "Minimum time that must pass after zone creation before a touch is registered. Prevents the impulse candle itself or the bars immediately after from triggering the touch logic. Set to 0 to disable.",
              group   = "Zone Management")

// Colours — H4 (red family)
i_h4DemClr  = input.color(color.new(#ed1919, 80), "H4 Demand", group = "Colours — H4")
i_h4SupClr  = input.color(color.new(#ed1919, 80), "H4 Supply", group = "Colours — H4")

// Colours — 2H (amber family)
i_h2DemClr  = input.color(color.new(#FB8C00, 80), "2H Demand", group = "Colours — 2H")
i_h2SupClr  = input.color(color.new(#FB8C00, 80), "2H Supply", group = "Colours — 2H")

// Colours — H1 (green family)
i_h1DemClr  = input.color(color.new(#43A047, 80), "H1 Demand", group = "Colours — H1")
i_h1SupClr  = input.color(color.new(#43A047, 80), "H1 Supply", group = "Colours — H1")

// Colours — 30m (purple family)
i_m30DemClr = input.color(color.new(#9C27B0, 85), "30m Demand", group = "Colours — 30m")
i_m30SupClr = input.color(color.new(#9C27B0, 85), "30m Supply", group = "Colours — 30m")

// Colours — M10 (dark-purple family)
i_m10DemClr = input.color(color.new(#6a3d66, 90), "M10 Demand", group = "Colours — M10")
i_m10SupClr = input.color(color.new(#6a3d66, 90), "M10 Supply", group = "Colours — M10")

// Colours — M5 (blue family)
i_m5DemClr  = input.color(color.new(#1E88E5, 90), "M5 Demand", group = "Colours — M5")
i_m5SupClr  = input.color(color.new(#1E88E5, 90), "M5 Supply", group = "Colours — M5")

// Colours — M1 (cyan family)
i_m1DemClr  = input.color(color.new(#00ACC1, 92), "M1 Demand", group = "Colours — M1")
i_m1SupClr  = input.color(color.new(#00ACC1, 92), "M1 Supply", group = "Colours — M1")

// Mitigated appearance
i_mitMode   = input.string("Keep zone colour", "Mitigated zone colour",
              options = ["Keep zone colour", "Custom colour", "Grey"],
              tooltip = "How a mitigated zone is re-coloured.\n" +
                        "Keep zone colour = keeps its own timeframe colour (only fades it).\n" +
                        "Custom colour    = uses the colour picked below for every mitigated zone.\n" +
                        "Grey             = legacy behaviour (neutral grey).",
              group   = "Colours — Mitigated")
i_mitCustom = input.color(color.new(#787B86, 90), "Mitigated custom colour",
              tooltip = "Only used when Mitigated zone colour = \"Custom colour\". " +
                        "Its own transparency is overridden by the setting below.",
              group   = "Colours — Mitigated")
i_mitTrans  = input.int(90, "Mitigated zone transparency",
              minval  = 50, maxval = 99,
              tooltip = "Higher = fainter mitigated zones.",
              group   = "Colours — Mitigated")

// Alerts — per-timeframe on/off
i_alertH4  = input.bool(true,  "H4 alerts",  group = "Alerts",
             tooltip = "Enable alert conditions for H4 zones (new zone, touch, mitigation).")
i_alertH2  = input.bool(false, "2H alerts",  group = "Alerts",
             tooltip = "Enable alert conditions for 2H zones (new zone, touch, mitigation).")
i_alertH1  = input.bool(true,  "H1 alerts",  group = "Alerts",
             tooltip = "Enable alert conditions for H1 zones (new zone, touch, mitigation).")
i_alert30m = input.bool(false, "30m alerts", group = "Alerts",
             tooltip = "Enable alert conditions for 30m zones (new zone, touch, mitigation).")
i_alertM10 = input.bool(true,  "M10 alerts", group = "Alerts",
             tooltip = "Enable alert conditions for M10 zones (new zone, touch, mitigation).")
i_alertM5  = input.bool(false, "M5 alerts",  group = "Alerts",
             tooltip = "Enable alert conditions for M5 zones (new zone, touch, mitigation).")
i_alertM1  = input.bool(false, "M1 alerts",  group = "Alerts",
             tooltip = "Enable alert conditions for M1 zones (new zone, touch, mitigation).")

// Display
i_showLabels  = input.bool(false, "Show zone labels",  group = "Display")
i_showBorders = input.bool(true,  "Show zone borders", group = "Display")
i_zoneExtend  = input.int(10, "Extend zones right (bars)", minval = 0, maxval = 100, step = 1,
                group   = "Display",
                tooltip = "How many bars past the current bar the zone boxes (and labels) are " +
                          "projected to the right. 0 = right edge sits on the current bar. " +
                          "Frozen zones (Stop-stretch mode) keep the offset they had when frozen.")


// ══════════════════════════════════════════════════════════════════════════════
// ── USER-DEFINED TYPE
// ══════════════════════════════════════════════════════════════════════════════

type Zone
    float  top          // upper price boundary
    float  bot          // lower price boundary
    int    status       // 0 = active | 1 = mitigated | 2 = delete-pending (touch/delete mode)
    int    dir          // 1 = demand | -1 = supply
    string tfLabel      // "H4" | "2H" | "H1" | "30m" | "M10" | "M5" | "M1"
    color  clrActive    // active fill colour
    bool   frozen       // true = stop extending right edge (touch/stop-stretch mode)
    int    createdTime  // bar open-time (ms) when zone was created — used for touch cooldown
    int    creatorClose // HTF close-time (ms) of the impulse candle that created the zone —
                        //   touch only counts once this candle has closed
    bool   alerted      // true once the zone-touch alert has fired (prevents repeats)
    bool   mitAlerted   // true once the zone-mitigation alert has fired (prevents repeats)
    box    bx           // box drawing object
    label  lbl          // label object (na when labels off)

// ══════════════════════════════════════════════════════════════════════════════
// ── SECURITY CALLS  (array syntax — proven to work; lookahead off = no repaint)
// ══════════════════════════════════════════════════════════════════════════════
// Each call returns raw OHLCV + ATR(i_atrLen) + SMA(volume,N) + prior-N hi/lo.
// Impulse conditions are evaluated at chart scope below.

//
// ── BAR-REPLAY SAFETY: clamp every requested timeframe to the chart TF ──
// request.security() cannot serve data from a timeframe LOWER than the chart's.
// During Bar Replay a sub-chart request makes replay abort to the realtime bar.
// math.max() pins each request at or above the chart TF, so replay works on any
// chart timeframe. A module finer than the chart simply requests the chart TF
// (its zone toggle would normally be off in that situation anyway).
chartTfSec = timeframe.in_seconds()
tf_h4  = timeframe.from_seconds(math.max(timeframe.in_seconds("240"), chartTfSec))
tf_h2  = timeframe.from_seconds(math.max(timeframe.in_seconds("120"), chartTfSec))
tf_h1  = timeframe.from_seconds(math.max(timeframe.in_seconds("60"),  chartTfSec))
tf_m30 = timeframe.from_seconds(math.max(timeframe.in_seconds("30"),  chartTfSec))
tf_m10 = timeframe.from_seconds(math.max(timeframe.in_seconds("10"),  chartTfSec))
tf_m5  = timeframe.from_seconds(math.max(timeframe.in_seconds("5"),   chartTfSec))
tf_m1  = timeframe.from_seconds(math.max(timeframe.in_seconds("1"),   chartTfSec))

[h4Hi, h4Lo, h4Cl, h4Op, h4Vol, h4ATR, h4VolMA, h4Hi5, h4Lo5, h4CloseT] = request.security(
     syminfo.tickerid, tf_h4,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLen) : ta.sma(volume, i_volSmaLen)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[h2Hi, h2Lo, h2Cl, h2Op, h2Vol, h2ATR, h2VolMA, h2Hi5, h2Lo5, h2CloseT] = request.security(
     syminfo.tickerid, tf_h2,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLen) : ta.sma(volume, i_volSmaLen)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[h1Hi, h1Lo, h1Cl, h1Op, h1Vol, h1ATR, h1VolMA, h1Hi5, h1Lo5, h1CloseT] = request.security(
     syminfo.tickerid, tf_h1,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLen) : ta.sma(volume, i_volSmaLen)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[m30Hi, m30Lo, m30Cl, m30Op, m30Vol, m30ATR, m30VolMA, m30Hi5, m30Lo5, m30CloseT] = request.security(
     syminfo.tickerid, tf_m30,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLen) : ta.sma(volume, i_volSmaLen)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[m10Hi, m10Lo, m10Cl, m10Op, m10Vol, m10ATR, m10VolMA, m10Hi5, m10Lo5, m10CloseT] = request.security(
     syminfo.tickerid, tf_m10,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLen) : ta.sma(volume, i_volSmaLen)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[m5Hi, m5Lo, m5Cl, m5Op, m5Vol, m5ATR, m5VolMA, m5Hi5, m5Lo5, m5CloseT] = request.security(
     syminfo.tickerid, tf_m5,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLenLTF) : ta.sma(volume, i_volSmaLenLTF)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

[m1Hi, m1Lo, m1Cl, m1Op, m1Vol, m1ATR, m1VolMA, m1Hi5, m1Lo5, m1CloseT] = request.security(
     syminfo.tickerid, tf_m1,
     [high, low, close, open, volume,
      ta.atr(i_atrLen),
      (i_volMaType == "WMA" ? ta.wma(volume, i_volSmaLenLTF) : ta.sma(volume, i_volSmaLenLTF)),
      ta.highest(high, i_priorLen)[1],
      ta.lowest (low,  i_priorLen)[1],
      time_close],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

// ══════════════════════════════════════════════════════════════════════════════
// ── IMPULSE DETECTION  (chart scope — using security values)
// ══════════════════════════════════════════════════════════════════════════════
// All three criteria must hold simultaneously:
//   1) Body size ≥ bodyMult × ATR(14)  on that TF
//   2) Close breaks beyond prior-N bars' high (bull) or low (bear)
//   3) Volume ≥ volMult × SMA(volume, N)  on that TF

h4BullImp = (h4Cl > h4Op and
             math.abs(h4Cl - h4Op) >= i_bodyMult * h4ATR and
             h4Cl > h4Hi5 and
             h4Vol >= i_volMult * h4VolMA)

h4BearImp = (h4Cl < h4Op and
             math.abs(h4Cl - h4Op) >= i_bodyMult * h4ATR and
             h4Cl < h4Lo5 and
             h4Vol >= i_volMult * h4VolMA)

h2BullImp = (h2Cl > h2Op and
             math.abs(h2Cl - h2Op) >= i_bodyMult * h2ATR and
             h2Cl > h2Hi5 and
             h2Vol >= i_volMult * h2VolMA)

h2BearImp = (h2Cl < h2Op and
             math.abs(h2Cl - h2Op) >= i_bodyMult * h2ATR and
             h2Cl < h2Lo5 and
             h2Vol >= i_volMult * h2VolMA)

h1BullImp = (h1Cl > h1Op and
             math.abs(h1Cl - h1Op) >= i_bodyMult * h1ATR and
             h1Cl > h1Hi5 and
             h1Vol >= i_volMult * h1VolMA)

h1BearImp = (h1Cl < h1Op and
             math.abs(h1Cl - h1Op) >= i_bodyMult * h1ATR and
             h1Cl < h1Lo5 and
             h1Vol >= i_volMult * h1VolMA)

m30BullImp = (m30Cl > m30Op and
              math.abs(m30Cl - m30Op) >= i_bodyMult * m30ATR and
              m30Cl > m30Hi5 and
              m30Vol >= i_volMult * m30VolMA)

m30BearImp = (m30Cl < m30Op and
              math.abs(m30Cl - m30Op) >= i_bodyMult * m30ATR and
              m30Cl < m30Lo5 and
              m30Vol >= i_volMult * m30VolMA)

m10BullImp = (m10Cl > m10Op and
              math.abs(m10Cl - m10Op) >= i_bodyMult * m10ATR and
              m10Cl > m10Hi5 and
              m10Vol >= i_volMult * m10VolMA)

m10BearImp = (m10Cl < m10Op and
              math.abs(m10Cl - m10Op) >= i_bodyMult * m10ATR and
              m10Cl < m10Lo5 and
              m10Vol >= i_volMult * m10VolMA)

m5BullImp = (m5Cl > m5Op and
             math.abs(m5Cl - m5Op) >= i_bodyMult * m5ATR and
             m5Cl > m5Hi5 and
             m5Vol >= i_volMult * m5VolMA)

m5BearImp = (m5Cl < m5Op and
             math.abs(m5Cl - m5Op) >= i_bodyMult * m5ATR and
             m5Cl < m5Lo5 and
             m5Vol >= i_volMult * m5VolMA)

m1BullImp = (m1Cl > m1Op and
             math.abs(m1Cl - m1Op) >= i_bodyMult * m1ATR and
             m1Cl > m1Hi5 and
             m1Vol >= i_volMult * m1VolMA)

m1BearImp = (m1Cl < m1Op and
             math.abs(m1Cl - m1Op) >= i_bodyMult * m1ATR and
             m1Cl < m1Lo5 and
             m1Vol >= i_volMult * m1VolMA)

// Rising-edge trackers — a zone is created only on the bar where the flag first
// becomes true, preventing duplicate zones across the many chart bars that map
// to a single higher-TF bar.
var bool h4PrevBull  = false
var bool h4PrevBear  = false
var bool h2PrevBull  = false
var bool h2PrevBear  = false
var bool h1PrevBull  = false
var bool h1PrevBear  = false
var bool m30PrevBull = false
var bool m30PrevBear = false
var bool m10PrevBull = false
var bool m10PrevBear = false
var bool m5PrevBull  = false
var bool m5PrevBear  = false
var bool m1PrevBull  = false
var bool m1PrevBear  = false

// ══════════════════════════════════════════════════════════════════════════════
// ── ZONE ARRAYS
// ══════════════════════════════════════════════════════════════════════════════

var array<Zone> h4Zones  = array.new<Zone>()
var array<Zone> h2Zones  = array.new<Zone>()
var array<Zone> h1Zones  = array.new<Zone>()
var array<Zone> m30Zones = array.new<Zone>()
var array<Zone> m10Zones = array.new<Zone>()
var array<Zone> m5Zones  = array.new<Zone>()
var array<Zone> m1Zones  = array.new<Zone>()

// ══════════════════════════════════════════════════════════════════════════════
// ── ZONE MANAGEMENT FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// addZone() — Creates a Zone with box + optional label; appends to array.
//   Enforces active-zone cap via FIFO shift (oldest zone removed when cap hit).
//   Zone boundaries:
//     Demand (dir=1)  : top = impulse open, bot = impulse low
//     Supply (dir=-1) : top = impulse high, bot = impulse open
//   Inputs : zones (array<Zone>), top, bot, dir, tfLabel, clrActive, creatorClose
//            creatorClose = HTF close-time (ms) of the impulse candle (touch gate)
// ─────────────────────────────────────────────────────────────────────────────
addZone(zones, zTop, zBot, dir, tfLabel, clrActive, creatorClose) =>
    bdrClr = i_showBorders ? color.new(clrActive, 10) : color.new(clrActive, 100)
    bx     = box.new(bar_index, zTop, bar_index + math.max(1, i_zoneExtend), zBot,
                     border_color = bdrClr,
                     border_width = 1,
                     bgcolor      = clrActive)
    z = Zone.new(
        top          = zTop,
        bot          = zBot,
        status       = 0,
        dir          = dir,
        tfLabel      = tfLabel,
        clrActive    = clrActive,
        frozen       = false,
        createdTime  = time,
        creatorClose = creatorClose,
        alerted      = false,
        mitAlerted   = false,
        bx           = bx,
        lbl          = na)
    if i_showLabels
        lbTxt = tfLabel + (dir == 1 ? " D" : " S")
        lbY   = (zTop + zBot) / 2.0
        z.lbl := label.new(bar_index + i_zoneExtend, lbY, lbTxt,
                            color     = color.new(clrActive, 45),
                            textcolor = color.white,
                            style     = label.style_label_right,
                            size      = size.tiny)
    array.push(zones, z)
    // FIFO active-zone cap: drop oldest active zone when limit exceeded
    while array.size(zones) > i_maxZones
        old = array.shift(zones)
        box.delete(old.bx)
        if not na(old.lbl)
            label.delete(old.lbl)

// ─────────────────────────────────────────────────────────────────────────────
// mitColour() — Resolves the fill/border colour used for a mitigated zone.
//   Inputs : baseClr (the zone's own active colour), transp (0–100 transparency)
//   Returns: colour according to i_mitMode
//              "Keep zone colour" → baseClr faded to transp
//              "Custom colour"    → i_mitCustom faded to transp
//              "Grey"             → color.gray faded to transp
// ─────────────────────────────────────────────────────────────────────────────
mitColour(baseClr, transp) =>
    src = (i_mitMode == "Grey"          ? color.gray  :
           i_mitMode == "Custom colour" ? i_mitCustom :
           baseClr)
    color.new(src, transp)

// ─────────────────────────────────────────────────────────────────────────────
// updateZones() — Per-bar zone state machine.
//   Step 1 — Touch detection (active zones only):
//     Touched = bar range overlaps zone price range AND cooldown elapsed.
//     First touch: sets z.alerted = true → drives the anyTouched return value.
//     Visual/state effect depends on i_onTouch:
//       "Delete"       → status 2 (delete-pending)
//       "Stop stretch" → z.frozen = true
//       "Extend always"→ no state change (just signal)
//   Step 2 — Mitigation check (active, non-delete-pending zones):
//     Demand: close < bot → re-colour via mitColour() + [m] tag; drives anyMitigated.
//     Supply: close > top → same.
//   Step 3 — Cleanup: delete status-2 zones (reverse loop, no index shift).
//   Step 4 — Mitigated cap: remove oldest beyond i_maxMit (forward scan).
//   Inputs  : zones (array<Zone>)
//   Returns : [anyTouched (bool), anyMitigated (bool)]
//             anyTouched  = true on the bar a zone is touched for the first time
//             anyMitigated = true on the bar any active zone becomes mitigated
// ─────────────────────────────────────────────────────────────────────────────
updateZones(zones) =>
    anyTouched   = false
    anyMitigated = false
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if z.status == 0
                // ── Step 1: touch detection ──────────────────────────────────
                // A touch counts only once the impulse candle that created the
                // zone has fully closed (chart bar's open time has reached the
                // creator candle's HTF close time) AND the cooldown has elapsed.
                cooldownMs   = i_touchCooldown * 60 * 1000
                cooldownOk   = (time - z.createdTime) >= cooldownMs
                creatorDone  = time >= z.creatorClose
                touched      = creatorDone and cooldownOk and low <= z.top and high >= z.bot
                if touched
                    // First-touch signal for alertcondition()
                    if not z.alerted
                        anyTouched := true
                        z.alerted  := true
                    // Visual/state effect
                    if i_onTouch == "Delete"
                        z.status := 2
                    else if i_onTouch == "Stop stretch"
                        z.frozen := true
                // ── Step 2: mitigation check (skip if marked for deletion) ──
                if z.status == 0
                    if (z.dir == 1 and close < z.bot) or (z.dir == -1 and close > z.top)
                        z.status      := 1
                        z.mitAlerted  := true   // mark zone alerted (single aggregate alert fires below)
                        anyMitigated  := true
                        mitClr         = mitColour(z.clrActive, i_mitTrans)
                        box.set_bgcolor      (z.bx, mitClr)
                        box.set_border_color (z.bx, mitClr)
                        if i_showLabels and not na(z.lbl)
                            label.set_color(z.lbl, mitColour(z.clrActive, 55))
                            label.set_text (z.lbl,
                                 z.tfLabel + (z.dir == 1 ? " D [m]" : " S [m]"))
    // ── Step 3: delete status-2 zones (reverse loop avoids index-shift bug) ──
    if array.size(zones) > 0
        for k = array.size(zones) - 1 to 0
            if array.get(zones, k).status == 2
                zd = array.get(zones, k)
                box.delete(zd.bx)
                if not na(zd.lbl)
                    label.delete(zd.lbl)
                array.remove(zones, k)
    // ── Step 4: mitigated cap — remove oldest (forward scan) ─────────────────
    nMit = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            if array.get(zones, i).status == 1
                nMit += 1
    toRemove = nMit - i_maxMit
    if toRemove > 0
        removed = 0
        i       = 0
        while i < array.size(zones) and removed < toRemove
            z2 = array.get(zones, i)
            if z2.status == 1
                box.delete(z2.bx)
                if not na(z2.lbl)
                    label.delete(z2.lbl)
                array.remove(zones, i)
                removed += 1
                // Do not increment i — array shifted left after removal
            else
                i += 1
    [anyTouched, anyMitigated]

// ─────────────────────────────────────────────────────────────────────────────
// extendZones() — Re-anchors every non-frozen zone box on each bar.
//   Calls set_top + set_bottom + set_right so price boundaries are confirmed
//   and the right edge follows bar_index + i_zoneExtend (sticky-boxes pattern
//   from §10.6), projecting the zone i_zoneExtend bars into the future.
//   Frozen zones (touch/stop-stretch mode) are skipped — their right edge
//   stays fixed at the bar they were first touched.
//   Inputs : zones (array<Zone>)
// ─────────────────────────────────────────────────────────────────────────────
extendZones(zones) =>
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if not z.frozen
                box.set_top   (z.bx, z.top)
                box.set_bottom(z.bx, z.bot)
                box.set_right (z.bx, bar_index + i_zoneExtend)
                if i_showLabels and not na(z.lbl)
                    label.set_x(z.lbl, bar_index + i_zoneExtend)

// ══════════════════════════════════════════════════════════════════════════════
// ── ZONE CREATION  (rising-edge trigger: only on first bar of each new impulse)
// ══════════════════════════════════════════════════════════════════════════════
// Named creation signals are captured BEFORE prev-vars are updated so that
// alertcondition() can reference them as plain bar-scope booleans.

newH4Dem  = i_showH4  and h4BullImp  and not h4PrevBull
newH4Sup  = i_showH4  and h4BearImp  and not h4PrevBear
newH2Dem  = i_showH2  and h2BullImp  and not h2PrevBull
newH2Sup  = i_showH2  and h2BearImp  and not h2PrevBear
newH1Dem  = i_showH1  and h1BullImp  and not h1PrevBull
newH1Sup  = i_showH1  and h1BearImp  and not h1PrevBear
new30mDem = i_show30m and m30BullImp and not m30PrevBull
new30mSup = i_show30m and m30BearImp and not m30PrevBear
newM10Dem = i_showM10 and m10BullImp and not m10PrevBull
newM10Sup = i_showM10 and m10BearImp and not m10PrevBear
newM5Dem  = i_showM5  and m5BullImp  and not m5PrevBull
newM5Sup  = i_showM5  and m5BearImp  and not m5PrevBear
newM1Dem  = i_showM1  and m1BullImp  and not m1PrevBull
newM1Sup  = i_showM1  and m1BearImp  and not m1PrevBear

// H4 zones — demand: open→low | supply: high→open
if newH4Dem
    addZone(h4Zones, h4Op, h4Lo,  1, "H4", i_h4DemClr, h4CloseT)
if newH4Sup
    addZone(h4Zones, h4Hi, h4Op, -1, "H4", i_h4SupClr, h4CloseT)

h4PrevBull := h4BullImp
h4PrevBear := h4BearImp

// 2H zones — demand: open→low | supply: high→open
if newH2Dem
    addZone(h2Zones, h2Op, h2Lo,  1, "2H", i_h2DemClr, h2CloseT)
if newH2Sup
    addZone(h2Zones, h2Hi, h2Op, -1, "2H", i_h2SupClr, h2CloseT)

h2PrevBull := h2BullImp
h2PrevBear := h2BearImp

// H1 zones — demand: open→low | supply: high→open
if newH1Dem
    addZone(h1Zones, h1Op, h1Lo,  1, "H1", i_h1DemClr, h1CloseT)
if newH1Sup
    addZone(h1Zones, h1Hi, h1Op, -1, "H1", i_h1SupClr, h1CloseT)

h1PrevBull := h1BullImp
h1PrevBear := h1BearImp

// 30m zones — demand: open→low | supply: high→open
if new30mDem
    addZone(m30Zones, m30Op, m30Lo,  1, "30m", i_m30DemClr, m30CloseT)
if new30mSup
    addZone(m30Zones, m30Hi, m30Op, -1, "30m", i_m30SupClr, m30CloseT)

m30PrevBull := m30BullImp
m30PrevBear := m30BearImp

// M10 zones — demand: open→low | supply: high→open
if newM10Dem
    addZone(m10Zones, m10Op, m10Lo,  1, "M10", i_m10DemClr, m10CloseT)
if newM10Sup
    addZone(m10Zones, m10Hi, m10Op, -1, "M10", i_m10SupClr, m10CloseT)

m10PrevBull := m10BullImp
m10PrevBear := m10BearImp

// M5 zones — demand: open→low | supply: high→open
if newM5Dem
    addZone(m5Zones, m5Op, m5Lo,  1, "M5", i_m5DemClr, m5CloseT)
if newM5Sup
    addZone(m5Zones, m5Hi, m5Op, -1, "M5", i_m5SupClr, m5CloseT)

m5PrevBull := m5BullImp
m5PrevBear := m5BearImp

// M1 zones — demand: open→low | supply: high→open
if newM1Dem
    addZone(m1Zones, m1Op, m1Lo,  1, "M1", i_m1DemClr, m1CloseT)
if newM1Sup
    addZone(m1Zones, m1Hi, m1Op, -1, "M1", i_m1SupClr, m1CloseT)

m1PrevBull := m1BullImp
m1PrevBear := m1BearImp

// ══════════════════════════════════════════════════════════════════════════════
// ── UPDATE & EXTEND ALL ZONES  (every bar — no barstate.islast guard)
// ══════════════════════════════════════════════════════════════════════════════

[h4Touch,  h4Mit]  = updateZones(h4Zones)
[h2Touch,  h2Mit]  = updateZones(h2Zones)
[h1Touch,  h1Mit]  = updateZones(h1Zones)
[m30Touch, m30Mit] = updateZones(m30Zones)
[m10Touch, m10Mit] = updateZones(m10Zones)
[m5Touch,  m5Mit]  = updateZones(m5Zones)
[m1Touch,  m1Mit]  = updateZones(m1Zones)
extendZones(h4Zones)
extendZones(h2Zones)
extendZones(h1Zones)
extendZones(m30Zones)
extendZones(m10Zones)
extendZones(m5Zones)
extendZones(m1Zones)

// ══════════════════════════════════════════════════════════════════════════════
// ── ALERTS  (alertcondition + alert() — valid in indicator() scripts)
// ══════════════════════════════════════════════════════════════════════════════
// "New zone" conditions (one per TF × direction) fire on the bar a fresh
// impulse qualifies.  Touch uses one aggregate alertcondition.  Mitigation uses
// a dynamic alert() so the message can name the timeframe(s) — a single alert
// fires per bar even when several zones/timeframes mitigate together.
// Zone touched for the first time — each TF contribution gated individually
alertcondition((h4Touch  and i_alertH4)  or
               (h2Touch  and i_alertH2)  or
               (h1Touch  and i_alertH1)  or
               (m30Touch and i_alert30m) or
               (m10Touch and i_alertM10) or
               (m5Touch  and i_alertM5)  or
               (m1Touch  and i_alertM1),
     "Zone Touched",
     "Supply/Demand zone")

// Zone mitigated — dynamic alert() so the message names the timeframe(s).
// All timeframes mitigated on this bar are collected into a single string and a
// single alert() fires (once per bar close). The mitigating zones are already
// flagged z.mitAlerted = true inside updateZones(), so none can re-alert.
// NOTE: alert() requires an alert created on this indicator with the
// "Any alert() function call" condition.
mitTFs = ""
if h4Mit  and i_alertH4
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "H4"
if h2Mit  and i_alertH2
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "2H"
if h1Mit  and i_alertH1
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "H1"
if m30Mit and i_alert30m
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "30m"
if m10Mit and i_alertM10
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "M10"
if m5Mit  and i_alertM5
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "M5"
if m1Mit  and i_alertM1
    mitTFs := mitTFs + (mitTFs == "" ? "" : ", ") + "M1"
if mitTFs != ""
    alert("Supply/Demand zone mitigated — " + mitTFs + " (" + syminfo.ticker + ")",
          alert.freq_once_per_bar_close)

// New zone created — gated by per-TF enable inputs
alertcondition(newH4Dem  and i_alertH4,  "New H4 Demand Zone",  "H4 Demand zone created")
alertcondition(newH4Sup  and i_alertH4,  "New H4 Supply Zone",  "H4 Supply zone created")
alertcondition(newH2Dem  and i_alertH2,  "New 2H Demand Zone",  "2H Demand zone created")
alertcondition(newH2Sup  and i_alertH2,  "New 2H Supply Zone",  "2H Supply zone created")
alertcondition(newH1Dem  and i_alertH1,  "New H1 Demand Zone",  "H1 Demand zone created")
alertcondition(newH1Sup  and i_alertH1,  "New H1 Supply Zone",  "H1 Supply zone created")
alertcondition(new30mDem and i_alert30m, "New 30m Demand Zone", "30m Demand zone created")
alertcondition(new30mSup and i_alert30m, "New 30m Supply Zone", "30m Supply zone created")
alertcondition(newM10Dem and i_alertM10, "New M10 Demand Zone", "M10 Demand zone created")
alertcondition(newM10Sup and i_alertM10, "New M10 Supply Zone", "M10 Supply zone created")
````
