# Mean Deviation Trail | Lyro RS

- url: https://www.tradingview.com/script/vFa51mb9-Mean-Deviation-Trail-Lyro-RS/
- type: indicator
- pine_id: PUB;01ed3565163f4e95a32b1d846315eb4c
- version: 1.0

## Description

[b]Introduction:[/b]
The Mean Deviation Trail (MDT) is an adaptive trend-following overlay that pairs Mean Absolute Deviation (MAD) volatility normalization with a signed, smoothed deviation signal to produce a dynamic, self-adjusting trail. Instead of relying on a fixed-width channel, MDT continuously measures how far — and in which direction — price departs from its mean, then modulates the trail width in real time. The outcome is a trail that tightens during strong directional regimes and widens during low-momentum or choppy phases.

[b]How It Works[/b]

[list=1]
[*][b]Deviation Engine[/b] — All calculations are anchored to an EMA of the source. From this anchor, the signed normalized deviation is computed:
Deviation Raw = (Price − EMA) / MAD
This captures both the direction and the relative magnitude of price displacement. A user-selectable smoothing MA (16 types) is then applied to filter noise from the raw signal.

[*][b]MAD Volatility Normalizer[/b] — Mean Absolute Deviation is calculated across a rolling lookback:
MAD = Σ |Price − EMA| / Length
Unlike standard deviation, MAD is not inflated by squared error terms, making it more resistant to outlier spikes and producing a smoother volatility anchor.

[*][b]Adaptive Trail Width[/b] — The smoothed deviation signal is scaled against its 80-bar peak to produce [i]sigNorm[/i] (a value between 0 and 1). This drives the multiplier between two user-defined extremes:
[list]
[*]Strong deviation → multiplier approaches the [b]Tight[/b] value → trail hugs price.
[*]Weak deviation → multiplier approaches the [b]Wide[/b] value → trail drifts away.
[/list]
Multiplier = Wide − sigNorm × (Wide − Tight)
Bandwidth = MAD × Multiplier

[*][b]Trail & Outer Band[/b] — The trail sits below price in uptrends and above price in downtrends, offset from the EMA by the adaptive bandwidth. An optional outer band plots at half-bandwidth on the opposite side, useful as a soft confirmation level.

[*][b]Trend State[/b] — Trend flips when the smoothed deviation crosses zero. Each flip prints a Long or Short label and resets the trail on the opposite side of price.
[/list]

[b]Key Features[/b]

[list]
[*][b]16 Smoothing MA Types[/b] — SMA, EMA, WMA, VWMA, DEMA, TEMA, RMA, HMA, LSMA, SMMA, ALMA, ZLSMA, FRAMA, KAMA, JMA, T3.
[*][b]Adaptive Trail Width[/b] — Tight in high-deviation regimes, wide when momentum decays.
[*][b]Optional Outer Band[/b] — A half-width band on the opposite side for additional context.
[*][b]Gradient & Trend Color Modes[/b] — Gradient scales color intensity with deviation strength; Trend applies flat directional coloring.
[*][b]Colored Candles & Bar Color[/b] — Full chart integration with signal-aware candle coloring.
[*][b]Long / Short Signal Labels[/b] — Printed at trend crossovers with 𝓛𝓸𝓷𝓰 / 𝓢𝓱𝓸𝓻𝓽 labels.
[*][b]Color Palettes[/b] — Classic, Mystic, Accented, Royal, or fully custom.
[*][b]Status Table[/b] — Displays live Trend direction and Strength (Weak / Moderate / Strong).
[*][b]Alerts[/b] — Confirmed Bullish and Bearish alert conditions included.
[/list]

[b]Signal Interpretation[/b]

[list]
[*]A [b]Long[/b] signal (𝓛𝓸𝓷𝓰 label, below bar) fires when the smoothed deviation crosses above zero — price is pulling away from the mean to the upside and the trail flips below price.
[*]A [b]Short[/b] signal (𝓢𝓱𝓸𝓻𝓽 label, above bar) fires when the smoothed deviation crosses below zero — price is pulling away from the mean to the downside and the trail flips above price.
[*][b]Strength = Strong[/b] indicates the deviation signal is near its recent peak — trend is mature and the trail is tight. [b]Weak[/b] indicates a fading or compressing regime — the trail loosens, and continuation should be treated with more caution.
[/list]

[b]Recommended Settings[/b]

[list]
[*][b]Long-Term Investing:[/b] 1D, MA Length 40, Smoothing 20, MAD 14
[*][b]Swing Trading:[/b] 4h, default settings
[*][b]Intraday Trading:[/b] 15m, MA Length 20, Smoothing 9, MAD 7, Tight 0.4, Wide 1.8
[/list]

[b]⚠️ Disclaimer[/b]
This indicator is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Always combine with price action, proper risk management, and additional analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Mean Deviation Trail | Lyro RS", "Mean Deviation Trail | Lyro RS", overlay=true)


import LyroRS/LMAs/1 as DynamicMAs

// ─────────────────────────────────────────────────────────────────────────────
// Input Groups
// ─────────────────────────────────────────────────────────────────────────────
engine_g  = "𝗗𝗘𝗩𝗜𝗔𝗧𝗜𝗢𝗡 𝗘𝗡𝗚𝗜𝗡𝗘"
band_g    = "𝗕𝗔𝗡𝗗 𝗦𝗘𝗧𝗧𝗜𝗡𝗚𝗦"
display_g = "𝗗𝗜𝗦𝗣𝗟𝗔𝗬"
colors_g  = "𝗖𝗢𝗟𝗢𝗥𝗦"
table_g   = "𝗧𝗔𝗕𝗟𝗘"

// ─────────────────────────────────────────────────────────────────────────────
// Deviation Engine Inputs
// ─────────────────────────────────────────────────────────────────────────────
source    = input.source(close, "Source",            group=engine_g, tooltip="Price source for all calculations.")
maLen     = input.int(30,       "MA Length",         group=engine_g, tooltip="EMA used as the central mean anchor.")
smoothType = input.string("EMA", "Smoothing MA", options=["SMA", "EMA", "WMA", "VWMA", "DEMA", "TEMA", "RMA", "HMA", "LSMA", "SMMA", "ALMA", "ZLSMA", "FRAMA", "KAMA", "JMA", "T3"], group=engine_g, tooltip="Moving average type applied to smooth the signed deviation signal.")
smoothLen  = input.int(14,       "Smoothing Length",  group=engine_g, tooltip="Lookback period for the deviation smoothing MA.")
madLen   = input.int(9,       "MAD Length",       group=engine_g, tooltip="Lookback for Root Mean Square Deviation — the volatility normalizer.")

// ─────────────────────────────────────────────────────────────────────────────
// Band Settings
// ─────────────────────────────────────────────────────────────────────────────
multTight = input.float(0.3, "Multiplier Tight (High Deviation)", step=0.1, group=band_g, tooltip="MAD multiplier when deviation is strong — trail hugs price.")
multWide  = input.float(1.5, "Multiplier Wide  (Low Deviation)",  step=0.1, group=band_g, tooltip="MAD multiplier when deviation is weak — trail drifts wide.")

// ─────────────────────────────────────────────────────────────────────────────
// Display Inputs
// ─────────────────────────────────────────────────────────────────────────────
colorMode = input.string("Gradient", "Color Mode",
 options=["Trend", "Gradient"],
 group=display_g, display=display.none, inline="d1",
 tooltip="Gradient: color intensity scales with deviation strength. Trend: flat UpC/DnC color.")
showFill  = input.bool(true, "Band Fill",  group=display_g, display=display.none, inline="d2")
showOuter = input.bool(false, "Outer Band", group=display_g, display=display.none, inline="d2")

// ─────────────────────────────────────────────────────────────────────────────
// Color Palette — LyroRS Style
// ─────────────────────────────────────────────────────────────────────────────
ColMode = input.string("Mystic", "Color Palette",
 options=["Classic", "Mystic", "Accented", "Royal"],
 group=colors_g, display=display.none, inline="pal",
 tooltip="Choose a predefined color scheme.")

cpyn   = input.bool(false,     "Use Custom Palette", tooltip="Enable manual selection of custom colors for trend signals.", group=colors_g, display=display.none)
cp_UpC = input.color(#00ff00, "Custom Up",   inline="Custom Palette", tooltip="Set a custom color for bullish signals.",  group=colors_g, display=display.none)
cp_DnC = input.color(#ff0000, "Custom Down", inline="Custom Palette", tooltip="Set a custom color for bearish signals.", group=colors_g, display=display.none)

// Palette resolver
color UpC = na
color DnC = na

switch ColMode
    "Classic"  =>
        UpC := #00E676
        DnC := #880E4F
    "Mystic"   =>
        UpC := #30FDCF
        DnC := #E117B7
    "Accented" =>
        UpC := #9618F7
        DnC := #FF0078
    "Royal"    =>
        UpC := #FFC107
        DnC := #673AB7

if cpyn
    UpC := cp_UpC
    DnC := cp_DnC

// ─────────────────────────────────────────────────────────────────────────────
// Table Inputs
// ─────────────────────────────────────────────────────────────────────────────
enable_table = input.bool(true,          "",           group=table_g, display=display.none, inline="T")
pos_table    = input.string("Top Right", "RMDT Table", group=table_g, display=display.none, inline="T",
 options=["Top Left","Middle Left","Bottom Left","Top Right","Middle Right","Bottom Right","Top Center","Middle Center","Bottom Center"])
tsize_input  = input.string("Normal",    "",           group=table_g, display=display.none, inline="T",
 options=["Huge","Large","Normal","Small","Tiny"])

// Table helpers
pot(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Middle Left"   => position.middle_left
        "Bottom Left"   => position.bottom_left
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Bottom Right"  => position.bottom_right
        "Top Center"    => position.top_center
        "Middle Center" => position.middle_center
        "Bottom Center" => position.bottom_center

tsz(s) =>
    switch s
        "Huge"   => size.huge
        "Large"  => size.large
        "Normal" => size.normal
        "Small"  => size.small
        "Tiny"   => size.tiny

// ─────────────────────────────────────────────────────────────────────────────
// MAD Function (LyroRS)
// ─────────────────────────────────────────────────────────────────────────────
mad(src, benchmark, length) =>
    sum_abs_diff = 0.0
    for i = 0 to length - 1
        diff = math.abs(src[i] - benchmark)
        sum_abs_diff := sum_abs_diff + diff
    sum_abs_diff / length


// ─────────────────────────────────────────────────────────────────────────────
// Core Calculations
// ─────────────────────────────────────────────────────────────────────────────
ma      = DynamicMAs.EMA(source, maLen)
madVal = mad(source, ma, madLen)

devRaw  = madVal > 0 ? (source - ma) / madVal : 0.0
float devSig = na
switch smoothType
    "SMA"   => devSig := DynamicMAs.SMA(devRaw, smoothLen)
    "EMA"   => devSig := DynamicMAs.EMA(devRaw, smoothLen)
    "WMA"   => devSig := DynamicMAs.WMA(devRaw, smoothLen)
    "VWMA"  => devSig := DynamicMAs.VWMA(devRaw, volume, smoothLen)
    "DEMA"  => devSig := DynamicMAs.DEMA(devRaw, smoothLen)
    "TEMA"  => devSig := DynamicMAs.TEMA(devRaw, smoothLen)
    "RMA"   => devSig := DynamicMAs.RMA(devRaw, smoothLen)
    "HMA"   => devSig := DynamicMAs.HMA(devRaw, smoothLen)
    "LSMA"  => devSig := DynamicMAs.LSMA(devRaw, smoothLen, 0)
    "SMMA"  => devSig := DynamicMAs.SMMA(devRaw, smoothLen)
    "ALMA"  => devSig := DynamicMAs.ALMA(devRaw, smoothLen, 0, 20)
    "ZLSMA" => devSig := DynamicMAs.ZLSMA(devRaw, smoothLen)
    "FRAMA" => devSig := DynamicMAs.FRAMA(devRaw, smoothLen)
    "KAMA"  => devSig := DynamicMAs.KAMA(devRaw, smoothLen)
    "JMA"   => devSig := DynamicMAs.JMA(devRaw, smoothLen, 0)
    "T3"    => devSig := DynamicMAs.T3(devRaw, smoothLen, 0.5)
sigAbs  = math.abs(devSig)
sigPeak = ta.highest(sigAbs, 80)
sigNorm = sigPeak > 0 ? math.min(sigAbs / sigPeak, 1.0) : 0.0

int  trend = devSig > 0 ? 1 : -1
bool cross = trend != trend[1]

// ─────────────────────────────────────────────────────────────────────────────
// Adaptive Trail
// ─────────────────────────────────────────────────────────────────────────────
mult      = multWide - sigNorm * (multWide - multTight)
bandwidth = madVal * mult

float trail = trend == 1 ? ma - bandwidth : ma + bandwidth
trail       := DynamicMAs.EMA(trail, 3)

float outer = trend == 1 ? ma + bandwidth * 0.5 : ma - bandwidth * 0.5
outer       := DynamicMAs.EMA(outer, 3)

// ─────────────────────────────────────────────────────────────────────────────
// Color Mode — Gradient vs Trend
// ─────────────────────────────────────────────────────────────────────────────
col = colorMode == "Gradient"
     ? (trend == 1
         ? color.from_gradient(sigNorm, 0.05, 0.7, color.new(UpC, 50), UpC)
         : color.from_gradient(sigNorm, 0.05, 0.7, color.new(DnC, 50), DnC))
     : (trend == 1 ? UpC : DnC)

// ─────────────────────────────────────────────────────────────────────────────
// Glow (always on)
// ─────────────────────────────────────────────────────────────────────────────
// glow = madVal * 0.08 * (0.4 + sigNorm * 1.2)

// g3p   = plot(ma + glow * 3, display=display.none, editable=false)
// g2p   = plot(ma + glow * 2, display=display.none, editable=false)
// g1p   = plot(ma + glow,     display=display.none, editable=false)
// pMA   = plot(ma, "MA", col, 2)
// g1b   = plot(ma - glow,     display=display.none, editable=false)
// g2b   = plot(ma - glow * 2, display=display.none, editable=false)
// g3b   = plot(ma - glow * 3, display=display.none, editable=false)

// fill(g3p, g2p, color.new(col, 94))
// fill(g2p, g1p, color.new(col, 88))
// fill(g1p, pMA,  color.new(col, 78))
// fill(pMA,  g1b, color.new(col, 78))
// fill(g1b, g2b, color.new(col, 88))
// fill(g2b, g3b, color.new(col, 94))

// ─────────────────────────────────────────────────────────────────────────────
// Trail & Outer Plot
// ─────────────────────────────────────────────────────────────────────────────
float trailBrk = cross ? float(na) : trail

pt  = plot(trailBrk, "Trail", col, 2, plot.style_linebr)
phl = plot(hl2, display=display.none, editable=false)
fill(pt, phl, hl2, trailBrk, color(na), color.new(col, showFill ? 70 : 100), editable=false)

plot(showOuter ? DynamicMAs.EMA(outer, 3) : na, "Outer", color.new(col, 78), 1)

// ─────────────────────────────────────────────────────────────────────────────
// Candles & Signals
// ─────────────────────────────────────────────────────────────────────────────
plotcandle(open, high, low, close, "Candles", col, col, bordercolor=col, display = display.pane)

plotshape(cross and trend == 1,  title="Long Signal",  location=location.belowbar,
           style=shape.labelup,   text="𝓛𝓸𝓷𝓰",  textcolor=#000000,
           size=size.small, color=UpC, force_overlay=true, display = display.pane)


plotshape(cross and trend == -1, title="Short Signal", location=location.abovebar,
           style=shape.labeldown, text="𝓢𝓱𝓸𝓻𝓽", textcolor=#000000,
           size=size.small, color=DnC, force_overlay=true, display = display.pane)


barcolor(col)

// ─────────────────────────────────────────────────────────────────────────────
// Status Table
// ─────────────────────────────────────────────────────────────────────────────
var table stat_tbl = table.new(pot(pos_table), 100, 100,
 frame_width=1, frame_color=color.gray, border_color=color.gray, border_width=1)

trendLbl    = trend == 1 ? "▲  Bullish" : "▼  Bearish"
trendCol    = trend == 1 ? UpC : DnC
strengthLbl = sigNorm > 0.75 ? "Strong" : sigNorm > 0.4 ? "Moderate" : "Weak"

if enable_table
    table.cell(stat_tbl, 0, 0, "RMDT | 𝓛𝔂𝓻𝓸 𝓡𝓢", text_color=color.white, bgcolor=#000000, text_size=tsz(tsize_input))
    table.cell(stat_tbl, 1, 0, "",                   text_color=color.white, bgcolor=#000000, text_size=tsz(tsize_input))
    table.merge_cells(stat_tbl, 0, 0, 1, 0)

    table.cell(stat_tbl, 0, 1, "Trend",     text_color=color.gray, bgcolor=#000000, text_size=tsz(tsize_input))
    table.cell(stat_tbl, 1, 1, trendLbl,    text_color=trendCol,   bgcolor=#000000, text_size=tsz(tsize_input))

    table.cell(stat_tbl, 0, 2, "Strength",  text_color=color.gray, bgcolor=#000000, text_size=tsz(tsize_input))
    table.cell(stat_tbl, 1, 2, strengthLbl, text_color=trendCol,   bgcolor=#000000, text_size=tsz(tsize_input))


// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(cross and trend == 1  and barstate.isconfirmed, "RMDT Long",  "Root Mean Deviation Trend — Bullish {{ticker}}")
alertcondition(cross and trend == -1 and barstate.isconfirmed, "RMDT Short", "Root Mean Deviation Trend — Bearish {{ticker}}")

// ─────────────────────────────────────────────────────────────────────────────
// ⚠️ Disclaimer: This indicator is for educational purposes only.
// It does not constitute financial advice. Always combine with
// price action, proper risk management, and additional analysis.
// ─────────────────────────────────────────────────────────────────────────────
````
