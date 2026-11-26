# Anchored VWAP Regime [ZurvanEG]

- url: https://www.tradingview.com/script/b4l5lcDo-Anchored-VWAP-Regime-ZurvanEG/
- type: indicator
- pine_id: PUB;e8450bb14293410b9efe1bbce83ba9f2
- version: 1.0

## Description

[b]◇ Overview[/b]
Anchored VWAP Regime shows not only where fair value sits, but whether the market has actually accepted a direction away from it.
Standard VWAP answers one question: where is the volume-weighted average price? It does not say whether price is trending away from it, rotating around it, or still forming. Most VWAP-based decisions fail here, especially early in the session and on range days with repeated whipsaws.

This script keeps VWAP as the central reference and adds:
⬦ Deviation bands that stay meaningful from the first bars of the anchor
⬦ A directional gate based on acceptance, not single crosses
⬦ A regime classification combining acceptance, trend spread and rotation
⬦ A bounded directional score that reflects structure, not raw distance
⬦ Saturation zones with reversal markers, a formation box and a secondary higher-period VWAP

[b]◇ How It Works[/b]
1. Anchoring and Weighting
VWAP resets at a fixed time of day, at each exchange session, or on a higher period. Without volume, it falls back to time weighting (TWAP). Either weighting can also be forced.
2. Effective Deviation (σeff)
All bands and distances use σeff: the anchor’s volume-weighted standard deviation, floored by a fraction of ATR. The floor keeps early bands realistic. Later, the anchor’s own deviation takes over.
3. Maturity
Each anchor has a formation phase in minutes. During it, gate and regime are not evaluated, and the score ramps in gradually.
4. Gate and Dead Zone
A close counts as above or below VWAP only outside a ±k·σeff dead zone. The gate flips only after a set number of consecutive closes beyond it.
5. Trend Spread
Fast and slow exponential VWAPs run continuously across anchors. Their ATR-normalised spread measures directional pressure that does not restart every session. Separate entry and exit thresholds prevent flicker. Resuming the last confirmed trend needs only the lower threshold, which shortens needless transitions after shallow pullbacks.
6. Rotation Count
VWAP crosses inside a window clipped to the current anchor are counted. New trends require low rotation. At the balance threshold, the market is classified as Balance.
7. Confirmation
A new regime must persist for a set number of closed bars.

[b]◈ Regimes[/b]
⬦ Trend Up / Trend Down: mature anchor, gate accepted on that side, matching spread, low rotation.
⬦ Balance: rotation at or above the threshold. VWAP acts as a pivot, not a direction.
⬦ Transition: none of the above. Colour follows the score, so the developing lean stays visible.
[image]https://www.tradingview.com/x/YRbqUUDQ/[/image]
[b]◈ Visual Features[/b]
⬦ VWAP Line: regime-coloured, heavier during confirmed trends, with an anchor-period label.
⬦ VWAP ↔ Close Fill: coloured by regime or score, showing which side controls the anchor.
[image]https://www.tradingview.com/x/lIwQ3GAk/[/image]
 ⬦ Deviation Bands: two levels with independent multipliers, a value-area fill and a fill between the bands. Everything breaks cleanly at each anchor shift.
[image]https://www.tradingview.com/x/IJJDCEQy/[/image]
 ⬦ Secondary VWAP: an independent higher-period VWAP (for example, weekly) shown as a label, with an optional line.
[image]https://www.tradingview.com/x/w8IKu6I3/[/image]
 ⬦ Saturation: red upper and green lower levels with zone fills, an optional candle highlight with hold bars, and reversal markers on the first close back inside. Reversals against a confirmed trend can be filtered out.
[image]https://www.tradingview.com/x/HdNsatY7/[/image]
 ⬦ Candle Colouring: plotcandle with regime or score colours.
⬦ Regime Background.
[image]https://www.tradingview.com/x/2IHy61kr/[/image]
 ⬦ Formation Box: the anchor’s opening range until the first mature close outside VWAP ± a set distance. Only the active midline extends right. An optional label shows price delta, estimated volume delta, volume, range in ATR and duration.
[image]https://www.tradingview.com/x/ueg0Uzr1/[/image]

[b] ◈ Practical Use[/b]
⬦ Trend: VWAP and Band 1 act as dynamic support or resistance. Pullbacks that hold on the accepted side, with a score that stays strong, indicate intact structure.
⬦ Balance: VWAP is a pivot. Band extremes, saturation and reversal markers matter more than the line itself.
⬦ Transition: indecision or regime change. Observe rather than act aggressively.
⬦ Formation: a box break in the direction of a later trend gives that trend context. A failed break back into the box is an early warning of balance.

[b]◈ Alerts[/b]
All alerts fire on bar close and can be toggled independently:
⬦ Regime shift to Trend Up / Trend Down
⬦ Formation Box break
⬦ Saturation reversal

Individual alert conditions are provided. A single “Any alert() function call” alert covers all enabled categories.

[b]◈ Notes[/b]
⬦ Nothing is judged before the anchor matures. This is intentional.
⬦ Regime confirmation is delayed by design.
⬦ On spot and CFD instruments, volume is usually tick volume. The formation volume delta is an estimate.
⬦ Saturation marks stretch, not reversal. A reversal marker shows that the stretch has paused, not that a turn is confirmed.
⬦ The score describes regime quality. It is not an entry signal on its own.
⬦ Values on the realtime bar update until the bar closes.

[b]◈ Conclusion[/b]
Anchored VWAP Regime turns anchored VWAP into a regime framework on the price chart. By refusing to judge an immature anchor and by rewarding structure over distance, it separates genuine acceptance from whipsaw around VWAP. It does not replace price structure or risk management. It shows how the market is treating fair value, so VWAP can be used as a trend filter, a pullback reference or a rotation pivot, depending on the regime in force.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©ZurvanEG
// @version=6 

// In the Name of God of Infinite Time and Space
// ───────────────────────────────────────────────────────────────── ─── ─
//    Title : 𝗩𝗪𝗔𝗣 - 𝗔nchored 𝗩𝗪𝗔𝗣 𝗥egime [𝗭urvān𝗘𝗚]
//            Anchored VWAP that waits for the anchor to mature, requires
//            accepted closes before committing to a direction, and scores
//            the move by structure rather than by distance alone.
// Language : TradingView's Pine Script® v6
// ───────────────────────────────────────────────────────────────── ─── ─


// #START_REGION
// ▾▾▾▾▾▾▾▾▾▾▾▾▾
const string ltitle = '𝗩𝗪𝗔𝗣 - 𝗔nchored 𝗩𝗪𝗔𝗣 𝗥egime [𝗭urvān𝗘𝗚]'
const string stitle = '⧕𝗩𝗪𝗔𝗣'
indicator(title = ltitle, shorttitle = stitle, overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)


// ───────
// >ENUMS< ⑴
// ────▾──
enum AnchorMode
    tod     = 'Time of Day'
    session = 'Exchange Session'
    period  = 'Period'

enum Weighting
    auto    = 'Auto'
    volume  = 'Volume (VWAP)'
    time    = 'Time (TWAP)'

enum Regime
    unknown    = 'Unknown'
    trendUp    = 'Trend Up'
    trendDn    = 'Trend Down'
    balance    = 'Balance'
    transition = 'Transition'

enum CandleMode
    off     = 'Off'
    score   = 'Score'
    regime  = 'Regime'


// ────────
// >INPUTS< ⑵
// ─────▾──
const string g_ang        = 'Anchor and Source'
AnchorMode   i_anchorMode = input.enum     (AnchorMode.period,  'Anchor · Mode',               group = g_ang, display = display.none,                                                                           tooltip = 'Time of Day: fixed clock time.\nExchange Session: first bar of the broker session.\nPeriod: each new Anchor · Period.')
int          i_anchorHHMM = input.int      (1800,               'Anchor · Time (HHMM)',        group = g_ang, display = display.none, minval = 0,    maxval = 2359, active = i_anchorMode == AnchorMode.tod,    tooltip = '1800 NY = Globex open for Gold.\nAlternatives: 0300 London, 0820 COMEX.')
string       i_tz         = input.string   ('America/New_York', 'Anchor · Timezone',           group = g_ang, display = display.none,                               active = i_anchorMode == AnchorMode.tod,    tooltip = 'Timezone of Anchor · Time. New York handles DST.')
string       i_anchorTf   = input.timeframe('D',                'Anchor · Period',             group = g_ang, display = display.none,                               active = i_anchorMode == AnchorMode.period)
float        i_src        = input.source   (hlc3,               'Price Source',                group = g_ang, display = display.none)
Weighting    i_weight     = input.enum     (Weighting.auto,     'Weighting',                   group = g_ang, display = display.none,                                                                           tooltip = 'Auto = volume; falls back to time (TWAP) when volume is missing.')
const string g_nse        = 'Noise & Maturity'
int          i_atrLen     = input.int      (14,                 'ATR Length',                  group = g_nse, display = display.none, minval = 1,                                                               tooltip = 'Noise unit for σ floor, Spread, Drift and box range.')
float        i_floorK     = input.float    (0.4,                'σ Floor (×ATR)',              group = g_nse, display = display.none, minval = 0,                step = 0.05,                                   tooltip = 'σeff = max(σ, k·ATR).\nKeeps bands open right after the anchor.')
int          i_matMin     = input.int      (120,                'Maturity (minutes)',          group = g_nse, display = display.none, minval = 0,                                                               tooltip = 'No gate / regime before this.')
const string g_reg        = 'Regime'
int          i_fLen       = input.int      (10,                 'EVWAP · Fast Length',         group = g_reg, display = display.none, minval = 2,                                                               tooltip = 'Bars. EVWAP = EMA(src·w) / EMA(w)')
int          i_sLen       = input.int      (16,                 'EVWAP · Slow Length',         group = g_reg, display = display.none, minval = 3,                                                               tooltip = 'Bars. Forced above Fast.')
bool         i_showBg     = input.bool     (false,              'Background',                  group = g_reg, display = display.none,                              inline = 'reg0')
int          i_bgTr       = input.int      (93,                 '           Transp',           group = g_reg, display = display.none, minval = 0,    maxval = 100, inline = 'reg0', active = i_showBg)
CandleMode   i_candle     = input.enum     (CandleMode.score,   'Candle Colour',               group = g_reg, display = display.none)
const string g_bnd        = 'VWAP & Bands'
bool         i_showVw     = input.bool     (true,               'VWAP · Show',                 group = g_bnd, display = display.none,                                                                           tooltip = 'Colour follows regime. Breaks at each anchor.')
bool         i_vwLbOn     = input.bool     (true,               'VWAP · Period Label',         group = g_bnd, display = display.none,                                               active = i_showVw,          tooltip = 'Anchor period at the right end of the VWAP line.')
bool         i_vcFillOn   = input.bool     (true,               'VWAP↔Close · Fill',           group = g_bnd, display = display.none)
string       i_vcFillSrc  = input.string   ('Score',            'VWAP↔Close · Colour Source',  group = g_bnd, display = display.none, options = ['Regime', 'Score'],                active = i_vcFillOn)
int          i_vcFillTr   = input.int      (85,                 'VWAP↔Close · Transparency',   group = g_bnd, display = display.none, minval = 0,    maxval = 100,                  active = i_vcFillOn)
bool         i_b1On       = input.bool     (true,               'Band 1 · Show',               group = g_bnd, display = display.none)
float        i_b1K        = input.float    (1.0,                'Band 1 · Multiplier (×σeff)', group = g_bnd, display = display.none, minval = 0.1,              step = 0.1,        active = i_b1On)
bool         i_b2On       = input.bool     (true,               'Band 2 · Show',               group = g_bnd, display = display.none)
float        i_b2K        = input.float    (2.0,                'Band 2 · Multiplier (×σeff)', group = g_bnd, display = display.none, minval = 0.1,              step = 0.1,        active = i_b2On)
bool         i_fVaOn      = input.bool     (true,               'Value Area · Fill',           group = g_bnd, display = display.none,                                               active = i_b1On,            tooltip = 'Fill between ±Band 1. Colour follows regime.')
int          i_fVaTr      = input.int      (93,                 'Value Area · Transparency',   group = g_bnd, display = display.none, minval = 0,    maxval = 100,                  active = i_b1On and i_fVaOn)
bool         i_f12On      = input.bool     (true,               'Band 1↔2 · Fill',             group = g_bnd, display = display.none,                                               active = i_b1On and i_b2On)
bool         i_vw2On      = input.bool     (true,               'VWAP 2 · Label',              group = g_bnd, display = display.none,                                                                           tooltip = 'Independent VWAP on another period (e.g. weekly).\nLabel at its current level.')
bool         i_vw2Line    = input.bool     (false,              'VWAP 2 · Line',               group = g_bnd, display = display.none,                                               active = i_vw2On)
string       i_vw2Tf      = input.timeframe('W',                'VWAP 2 · Period',             group = g_bnd, display = display.none,                                               active = i_vw2On)
const string g_sat        = 'Saturation'
bool         i_satLn      = input.bool     (true,               'Show Lines',                  group = g_sat, display = display.none)
float        i_satK       = input.float    (2.5,                'Level (×σeff)',               group = g_sat, display = display.none, minval = 1,                step = 0.1,                                    tooltip = '|Z| ≥ this = stretched.')
bool         i_satZn      = input.bool     (true,               'Zone · Fill',                 group = g_sat, display = display.none)
float        i_satZnK     = input.float    (0.3,                'Zone · Width (×σeff)',        group = g_sat, display = display.none, minval = 0.1,              step = 0.1,        active = i_satZn)
bool         i_satRev     = input.bool     (false,              'Reversal · Show',             group = g_sat, display = display.none,                                                                           tooltip = 'Marks the first close back inside Saturation after a saturated bar.')
bool         i_satRevTr   = input.bool     (false,              'Reversal · Trend Filter',     group = g_sat, display = display.none,                                               active = i_satRev,          tooltip = 'Hides reversals against a confirmed trend (stretch in trend direction).')
const string g_box        = 'Formation Box'
bool         i_showBox    = input.bool     (true,               'Box · Show',                  group = g_box, display = display.none,                                                                           tooltip = 'Anchor high/low until the box exit.')
float        i_boxK       = input.float    (1.3,                'Box · Exit (×σeff)',          group = g_box, display = display.none, minval = 0.1,              step = 0.1,                                    tooltip = 'Box ends at the first mature close outside VWAP ± this.')
bool         i_boxMid     = input.bool     (true,               'Midline · Show',              group = g_box, display = display.none,                                               active = i_showBox,         tooltip = 'Box midline. Current anchor extends right; past ones stop at their anchor.')
bool         i_boxLb      = input.bool     (true,               'Label · Show',                group = g_box, display = display.none, inline = 'box0',                              active = i_showBox)
string       i_lbSize     = input.string   (size.small,         '             Size',           group = g_box, display = display.none, inline = 'box0',                              active = i_showBox and i_boxLb, options = [size.tiny, size.small, size.normal])
bool         i_lbDP       = input.bool     (false,              'ΔPrice',                      group = g_box, display = display.none, inline = 'box1',                              active = i_showBox and i_boxLb)
bool         i_lbDV       = input.bool     (true,               'ΔVolume',                     group = g_box, display = display.none, inline = 'box1',                              active = i_showBox and i_boxLb)
bool         i_lbV        = input.bool     (true,               'Volume',                      group = g_box, display = display.none, inline = 'box1',                              active = i_showBox and i_boxLb)
bool         i_lbR        = input.bool     (false,              'Range',                       group = g_box, display = display.none, inline = 'box2',                              active = i_showBox and i_boxLb)
bool         i_lbT        = input.bool     (false,              'Duration',                    group = g_box, display = display.none, inline = 'box2',                              active = i_showBox and i_boxLb)
const string g_alt        = 'Alerts'
bool         i_alReg      = input.bool     (true,               'Regime · Trend Up / Down',    group = g_alt, display = display.none,                                                                           tooltip = 'Fires when a new Trend Up or Trend Down is confirmed.')
bool         i_alBox      = input.bool     (true,               'Formation Box · Break',       group = g_alt, display = display.none,                                                                           tooltip = 'Fires on the first mature close outside VWAP ± Box Exit.')
bool         i_alRev      = input.bool     (true,               'Saturation · Reversal',       group = g_alt, display = display.none,                                                                           tooltip = 'Fires on a shown Saturation Reversal marker.')


// ────────
// >COLORS< ⑶
// ─────▾──
color i_cUp      = #00897b
color i_cDn      = #ff5252
color i_cBal     = #ffffff
color i_cEvF     = color.new(#b747cb, 30)
color i_cEvS     = color.new(#ff9800, 30)
color i_b1C      = color.new(#787b86, 55)
color i_b2C      = color.new(#787b86, 70)
color i_f12C     = color.new(#787b86, 94)
color i_vw2C     = color.new(#b2b5be, 20)
color i_cSatUp   = color.new(#ff5252, 40)
color i_cSatDn   = color.new(#4caf50, 40)
color i_cSatZnUp = color.new(#ff5252, 90)
color i_cSatZnDn = color.new(#4caf50, 90)
color i_cSatCdl  = color.new(#ff9800, 50)
color i_cBoxBg   = color.new(#31a2ff, 95)
color i_cBoxBd   = color.new(#2196f3, 35)
color i_cBoxMid  = color.new(#2196f3, 40)
color i_cLbBg    = color.new(#2196f3, 90)
color i_cLbTx    = color.new(#ffffff, 10)


// ────────────
// >VALIDATION< ⑷
// ─────────▾──
if i_anchorMode == AnchorMode.period and timeframe.in_seconds(i_anchorTf) <= timeframe.in_seconds()
    runtime.error('Anchor · Period must be higher than the chart timeframe.')
if i_anchorMode == AnchorMode.tod and i_anchorHHMM % 100 > 59
    runtime.error('Anchor · Time: minutes must be 00–59.')
if i_vw2On and timeframe.in_seconds(i_vw2Tf) <= timeframe.in_seconds()
    runtime.error('VWAP 2 · Period must be higher than the chart timeframe.')


// ─────────
// >HELPERS< ⑸
// ──────▾──
// @function   bounded tanh.
f_tanh(float x) =>
    float e = math.exp(2 * math.max(math.min(x, 20.0), -20.0))
    (e - 1) / (e + 1)

// @function   HHMM int → 'HH:MM'.
f_hhmm(int t) =>
    int h = int(t / 100)
    int m = t % 100
    (h < 10 ? '0' : '') + str.tostring(h) + ':' + (m < 10 ? '0' : '') + str.tostring(m)


// ──────────────
// >ENGINE TYPES< ⑹
// ───────────▾──
// @type   static engine configuration.
type VwapCfg
    float floorK
    float hystK
    int   accBars
    int   matBars

// @type   anchored VWAP state (shifted sums for float precision).
type Vwap
    float p0     = na
    float sW     = 0.0
    float sWD    = 0.0
    float sWD2   = 0.0
    int   n      = 0
    float value  = na
    float sigma  = na
    float sEff   = na
    bool  mature = false
    int   gate   = 0
    int   runUp  = 0
    int   runDn  = 0

// @function   resets the engine at a new anchor.
method reset(Vwap this, float price) =>
    this.p0     := price
    this.sW     := 0.0
    this.sWD    := 0.0
    this.sWD2   := 0.0
    this.n      := 0
    this.value  := na
    this.sigma  := na
    this.sEff   := na
    this.mature := false
    this.gate   := 0
    this.runUp  := 0
    this.runDn  := 0
    this

// @function   adds one bar: VWAP, σ, σeff, maturity and acceptance gate.
method update(Vwap this, VwapCfg c, float price, float w, float cls, float atr) =>
    float d = price - this.p0
    this.sW   := this.sW + w
    this.sWD  := this.sWD + w * d
    this.sWD2 := this.sWD2 + w * d * d
    this.n    := this.n + 1
    if this.sW > 0
        float m = this.sWD / this.sW
        this.value := this.p0 + m
        this.sigma := math.sqrt(math.max(this.sWD2 / this.sW - m * m, 0.0))
    this.sEff   := math.max(nz(this.sigma), c.floorK * atr)
    this.mature := this.n >= c.matBars and not na(this.value)
    this.runUp  := cls > this.value + c.hystK * this.sEff ? this.runUp + 1 : 0
    this.runDn  := cls < this.value - c.hystK * this.sEff ? this.runDn + 1 : 0
    if this.mature
        if this.runUp >= c.accBars
            this.gate := 1
        else if this.runDn >= c.accBars
            this.gate := -1
    this

// @function   z-score vs VWAP in σeff units.
// @returns    na before maturity.
method z(Vwap this, float price) =>
    this.mature and this.sEff > 0 ? (price - this.value) / this.sEff : na


// ───────────────
// >FORMATION BOX< ⑺
// ────────────▾──
// @type   box visual configuration.
type BoxVis
    bool   show
    color  bg
    color  bd
    int    bw
    string bs
    bool   mid
    color  mc
    string ms
    bool   lbl
    string lsz
    color  lbg
    color  ltx
    bool   fDP
    bool   fDV
    bool   fV
    bool   fR
    bool   fT

// @type   Formation box state.
type FormBox
    box   bx   = na
    label lb   = na
    line  ml   = na
    bool  live = false
    int   b0   = na
    float o0   = na
    float hi   = na
    float lo   = na
    float lc   = na
    float sV   = 0.0
    float sD   = 0.0

// @function   builds/updates the stats label under the box.
method finish(FormBox this, BoxVis c, float atr) =>
    if c.show and c.lbl and not na(this.bx)
        int    r = this.bx.get_right()
        string t = ''
        if c.fDP
            t += 'ΔP ' + str.tostring(this.lc - this.o0, format.mintick) + '\n'
        if c.fDV
            t += 'ΔV ' + str.tostring(this.sD, format.volume) + (this.sV > 0 ? ' (' + str.tostring(this.sD / this.sV * 100, '#.#') + '%)' : '') + '\n'
        if c.fV
            t += 'Vol ' + str.tostring(this.sV, format.volume) + '\n'
        if c.fR
            t += 'Rng ' + str.tostring(atr > 0 ? (this.hi - this.lo) / atr : na, '#.##') + ' ATR\n'
        if c.fT
            int mins = int((r - this.b0 + 1) * timeframe.in_seconds() / 60)
            t += str.format('{0}h{1}m', int(mins / 60), mins % 60) + '\n'
        t := str.length(t) > 0 ? str.substring(t, 0, str.length(t) - 1) : t
        int xm = int((this.b0 + r) / 2)
        if na(this.lb)
            this.lb := label.new(xm, this.lo, t, style = label.style_label_up, color = c.lbg, textcolor = c.ltx, size = c.lsz)
        else
            this.lb.set_xy(xm, this.lo)
            this.lb.set_text(t)
    this

// @function   Opens a new box; closes previous label and stops the previous midline at the anchor.
// @returns    this.
method start(FormBox this, BoxVis c, float atr) =>
    if this.live
        this.finish(c, atr)
    if not na(this.ml)
        this.ml.set_extend(extend.none)
        this.ml.set_x2(bar_index - 1)
    this.lb   := na
    this.live := true
    this.b0   := bar_index
    this.o0   := open
    this.hi   := high
    this.lo   := low
    this.lc   := close
    this.sV   := 0.0
    this.sD   := 0.0
    this.bx   := c.show ? box.new(bar_index, high, bar_index, low, border_color = c.bd, border_width = c.bw, border_style = c.bs, bgcolor = c.bg) : na
    float m    = (high + low) / 2
    this.ml   := c.show and c.mid ? line.new(bar_index, m, bar_index, m, extend = extend.right, color = c.mc, style = c.ms) : na
    this

// @function   Exit check first → breakout bar is not absorbed into the box.
// @returns    true while the box is live.
method step(FormBox this, Vwap v, float k, BoxVis c, float vol, float clv, float atr) =>
    if this.live
        if v.mature and math.abs(close - v.value) > k * v.sEff
            this.live := false
            this.finish(c, atr)
        else
            this.hi := math.max(this.hi, high)
            this.lo := math.min(this.lo, low)
            this.lc := close
            this.sV += vol
            this.sD += vol * (2 * clv - 1)
            if not na(this.bx)
                this.bx.set_right(bar_index)
                this.bx.set_top(this.hi)
                this.bx.set_bottom(this.lo)
            if not na(this.ml)
                float m = (this.hi + this.lo) / 2
                this.ml.set_y1(m)
                this.ml.set_y2(m)
                this.ml.set_x2(bar_index)
            if barstate.islast
                this.finish(c, atr)
    this.live


// ────────────
// >ENGINE RUN< ⑻
// ─────────▾──
int   matBars = math.max(int(math.ceil(i_matMin * 60 / timeframe.in_seconds())), 1)
int   sLenEff = math.max(i_sLen, i_fLen + 1)
float sExit   = math.min(0.15, 0.2)

var VwapCfg cfg  = VwapCfg.new(i_floorK, 0.15, 2, matBars)
var BoxVis  bvis = BoxVis.new(i_showBox, i_cBoxBg, i_cBoxBd, 1, line.style_dashed, i_boxMid, i_cBoxMid, line.style_dotted, i_boxLb, i_lbSize, i_cLbBg, i_cLbTx, i_lbDP, i_lbDV, i_lbV, i_lbR, i_lbT)
var Vwap    eng  = Vwap.new()
var FormBox fb   = FormBox.new()

// >weight
float vRaw = nz(volume)
float w    = switch i_weight
    Weighting.volume => vRaw
    Weighting.time   => 1.0
    => syminfo.volumetype == 'n/a' or na(volume) ? 1.0 : vRaw

// >anchor detection (global scope)
int  tod       = hour(time, i_tz) * 60 + minute(time, i_tz)
int  anchorMin = int(math.floor(i_anchorHHMM / 100)) * 60 + i_anchorHHMM % 100
bool dayChg    = dayofmonth(time, i_tz) != dayofmonth(time[1], i_tz)
bool tfChg     = timeframe.change(i_anchorTf)
bool sesFirst  = session.isfirstbar
bool newAnchor = switch i_anchorMode
    AnchorMode.tod     => tod >= anchorMin and (tod[1] < anchorMin or dayChg)
    AnchorMode.session => sesFirst
    => tfChg

float atr  = nz(ta.atr(i_atrLen))
float rng  = high - low
float clvL = rng > 0 ? (close - low) / rng : 0.5

// >EVWAPs: continuous across anchors
float ewF    = ta.ema(w, i_fLen)
float ewS    = ta.ema(w, sLenEff)
float emF    = ta.ema(i_src * w, i_fLen)
float emS    = ta.ema(i_src * w, sLenEff)
float evF    = ewF > 0 ? emF / ewF : na
float evS    = ewS > 0 ? emS / ewS : na
float spread = atr > 0 ? nz((evF - evS) / atr) : 0.0

// >flat drift: net Slow-EVWAP move, ATR/bar
float drift = atr > 0 ? nz((evS - evS[20]) / (20 * atr)) : 0.0

var int    rotCum    = 0
var int    rotBase   = 0
var int    sideCum   = 0
var int    sideBase  = 0
var int    matCum    = 0
var int    matBase   = 0
var int    lastSide  = 0
var Regime rgS       = Regime.unknown
var Regime rgPend    = Regime.unknown
var int    rgPendN   = 0
var Regime lastTrend = Regime.unknown
var float  scPrev    = 0.0

// >anchor reset (lastTrend survives: EVWAP spread is continuous)
if newAnchor or na(eng.p0)
    eng.reset(i_src)
    fb.start(bvis, atr)
    rotBase  := rotCum
    sideBase := sideCum
    matBase  := matCum
    lastSide := 0
    rgS      := Regime.unknown
    rgPend   := Regime.unknown
    rgPendN  := 0
    scPrev   := 0.0

eng.update(cfg, i_src, w, close, atr)

float vw = eng.value
float se = eng.sEff
float dz = 0.15 * nz(se)
float z  = eng.z(close)

// >side / rotations / persistence (window clipped to anchor)
int side = eng.mature ? (close > vw + dz ? 1 : close < vw - dz ? -1 : 0) : 0
if side != 0
    if lastSide != 0 and side != lastSide
        rotCum += 1
    lastSide := side
sideCum += side
if eng.mature
    matCum += 1


int i_rotWin = 14
int i_rotMax = 1
bool  inWin   = eng.n > i_rotWin
int   rot     = rotCum  - (inWin ? nz(rotCum[i_rotWin])  : rotBase)
int   sideSum = sideCum - (inWin ? nz(sideCum[i_rotWin]) : sideBase)
int   matCnt  = matCum  - (inWin ? nz(matCum[i_rotWin])  : matBase)
float pers    = matCnt > 0 ? sideSum / math.max(matCnt, i_rotWin / 2.0) : 0.0

// >regime: asymmetric hysteresis on Trend Spread
int    rotChopEff = math.max(3, i_rotMax + 1)
Regime cand       = Regime.unknown
if eng.mature
    bool  upHold = rgS == Regime.trendUp and eng.gate != -1 and spread > -sExit
    bool  dnHold = rgS == Regime.trendDn and eng.gate !=  1 and spread <  sExit
    float upEnt  = lastTrend == Regime.trendUp ? sExit : 0.2
    float dnEnt  = lastTrend == Regime.trendDn ? sExit : 0.2
    bool  upNew  = eng.gate ==  1 and spread >=  upEnt and rot <= i_rotMax
    bool  dnNew  = eng.gate == -1 and spread <= -dnEnt and rot <= i_rotMax
    cand := rot >= rotChopEff ? Regime.balance : upHold ? Regime.trendUp : dnHold ? Regime.trendDn : upNew ? Regime.trendUp : dnNew ? Regime.trendDn : Regime.transition

if not eng.mature
    rgS     := Regime.unknown
    rgPend  := Regime.unknown
    rgPendN := 0
else if cand == rgS
    rgPendN := 0
else
    rgPendN := cand == rgPend ? rgPendN + 1 : 1
    rgPend  := cand
    if rgPendN >= 2
        rgS     := cand
        rgPendN := 0
        if cand == Regime.trendUp or cand == Regime.trendDn
            lastTrend := cand

bool isUp    = rgS == Regime.trendUp
bool isDn    = rgS == Regime.trendDn
bool isTrend = isUp or isDn

// >score
// >constants
const float i_scWT    = 0.45   // weight · trend (EVWAP spread)
const float i_scWP    = 0.25   // weight · position beyond dead zone
const float i_scWR    = 0.35   // weight · persistence
const float i_scWG    = 0.30   // weight · confirmed regime

// position: full credit up to Saturation, linear fade to 0 over Exhaustion Fade
float zOut  = na(z) ? 0.0 : z > 0 ? math.max(z - 0.15, 0.0) : math.min(z + 0.15, 0.0)
float az    = na(z) ? 0.0 : math.abs(z)
float exh   = math.max(math.min(1 - (az - i_satK) / 1.0, 1.0), 0.0)
float pos   = f_tanh(zOut / 1.0) * exh
float rgDir = isUp ? 1.0 : isDn ? -1.0 : 0.0

float wSum = i_scWT + i_scWP + i_scWR + i_scWG
float raw  = wSum > 0 ? (i_scWT * f_tanh(spread / 0.2) + i_scWP * pos + i_scWR * pers + i_scWG * rgDir) / wSum : 0.0
float chop = math.max(math.min(1 - (rot - i_rotMax) / (rotChopEff - i_rotMax), 1.0), 0.0)
float flat = 0.15 + (1 - 0.15) * math.min(math.abs(drift) / 0.2, 1.0)
float rr   = math.min(float(eng.n) / matBars, 1.0)
float ramp = math.pow(rr, 1.0)
float tgt  = raw * chop * flat * ramp
float sc   = scPrev + math.max(math.min(tgt - scPrev, 0.1), -0.1)
scPrev    := sc

// >formation box
bool boxLive  = fb.step(eng, i_boxK, bvis, vRaw, clvL, atr)
bool boxBreak = boxLive[1] and not boxLive and not newAnchor

// >VWAP 2 (independent period)
bool  vw2Chg = timeframe.change(i_vw2Tf)
var float v2W  = 0.0
var float v2PW = 0.0
if vw2Chg
    v2W  := 0.0
    v2PW := 0.0
v2W  += w
v2PW += w * i_src
float vw2 = v2W > 0 ? v2PW / v2W : na

// >saturation hold / reversal
bool    sat    = not na(z) and math.abs(z) >= i_satK
var int satAge = 1000000
var int satDir = 0
satAge := newAnchor ? 1000000 : sat ? 0 : satAge + 1
satDir := newAnchor ? 0 : sat ? (z > 0 ? 1 : -1) : satDir
bool  satHeld = satAge <= 1

// first close back inside after a saturated bar (same anchor)
bool satExit = not newAnchor and not na(z) and sat[1] and not sat
bool revDn   = satExit and satDir ==  1 and not (i_satRevTr and isUp)
bool revUp   = satExit and satDir == -1 and not (i_satRevTr and isDn)


// ───────
// >PLOTS< ⑼
// ────▾──
// >colors
color scCol = color.from_gradient(sc, -1, 1, i_cDn, i_cUp)
color rgCol = switch rgS
    Regime.trendUp    => i_cUp
    Regime.trendDn    => i_cDn
    Regime.balance    => i_cBal
    Regime.transition => scCol
    => color.gray

bool  brk = newAnchor
color vwC = newAnchor ? na : rgCol

plot(i_showVw ? vw : na,               'VWAP',       vwC,     1,          plot.style_linebr)
plot(i_showVw and isTrend ? vw : na,   'VWAP Trend', vwC,     2,         plot.style_linebr, display = display.pane)
plot(i_vw2On and i_vw2Line ? vw2 : na, 'VWAP 2',     vw2Chg ? na : i_vw2C, 1, plot.style_linebr, display = display.all - display.status_line)

// >VWAP ↔ close fill
color vcBase = i_vcFillSrc == 'Score' ? scCol : rgCol
pVcV = plot(i_vcFillOn ? vw : na,    'VWAP↔Close · VWAP',  na, display = display.none, editable = false)
pVcC = plot(i_vcFillOn ? close : na, 'VWAP↔Close · Close', na, display = display.none, editable = false)
fill(pVcV, pVcC, i_vcFillOn and eng.mature and not newAnchor ? color.new(vcBase, i_vcFillTr) : na, 'VWAP↔Close Fill')

// >bands
p1u = plot(i_b1On ? vw + i_b1K * se : na, 'Band 1 +', brk ? na : i_b1C, 1, plot.style_linebr, display = display.all - display.status_line)
p1d = plot(i_b1On ? vw - i_b1K * se : na, 'Band 1 −', brk ? na : i_b1C, 1, plot.style_linebr, display = display.all - display.status_line)
p2u = plot(i_b2On ? vw + i_b2K * se : na, 'Band 2 +', brk ? na : i_b2C, 1, plot.style_linebr, display = display.all - display.status_line)
p2d = plot(i_b2On ? vw - i_b2K * se : na, 'Band 2 −', brk ? na : i_b2C, 1, plot.style_linebr, display = display.all - display.status_line)
fill(p1u, p1d, i_fVaOn and not newAnchor ? color.new(rgCol, i_fVaTr) : na, 'Value Area Fill')
fill(p1u, p2u, i_f12On and not newAnchor ? i_f12C : na, 'Band 1↔2 Fill +')
fill(p1d, p2d, i_f12On and not newAnchor ? i_f12C : na, 'Band 1↔2 Fill −')

// >saturation
bool satShow = i_satLn or i_satZn
psu = plot(satShow ? vw + i_satK * se : na, 'Saturation +', i_satLn and not brk ? i_cSatUp : na, 1, plot.style_linebr, linestyle = plot.linestyle_dotted, display = display.all)
psd = plot(satShow ? vw - i_satK * se : na, 'Saturation −', i_satLn and not brk ? i_cSatDn : na, 1, plot.style_linebr, linestyle = plot.linestyle_dotted, display = display.all)
pzu = plot(i_satZn ? vw + (i_satK + i_satZnK) * se : na, 'Sat Zone +', na, display = display.none, editable = false)
pzd = plot(i_satZn ? vw - (i_satK + i_satZnK) * se : na, 'Sat Zone −', na, display = display.none, editable = false)
fill(psu, pzu, i_satZn and not newAnchor ? i_cSatZnUp : na, 'Sat Zone Fill +')
fill(psd, pzd, i_satZn and not newAnchor ? i_cSatZnDn : na, 'Sat Zone Fill −')

// >regime visuals
bgcolor(i_showBg and eng.mature ? color.new(rgCol, i_bgTr) : na, title = 'Regime BG')

bool  cdlOn = i_candle != CandleMode.off
color cdl   = satHeld ? i_cSatCdl : i_candle == CandleMode.regime ? rgCol : scCol
plotcandle(cdlOn ? open : na, cdlOn ? high : na, cdlOn ? low : na, cdlOn ? close : na, 'Candles', cdl, wickcolor = cdl, bordercolor = cdl, display = display.all - display.status_line)

// >saturation reversal
plotshape(i_satRev and revDn, 'Sat Reversal ↓', shape.triangledown, location.abovebar, i_cSatUp, size = size.tiny, display = display.all - display.status_line)
plotshape(i_satRev and revUp, 'Sat Reversal ↑', shape.triangleup,   location.belowbar, i_cSatDn, size = size.tiny, display = display.all - display.status_line)

// >period labels (last bar only)
string vwTxt = switch i_anchorMode
    AnchorMode.tod     => 'VWAP · ' + f_hhmm(i_anchorHHMM)
    AnchorMode.session => 'VWAP · Session'
    => 'VWAP · ' + i_anchorTf

var label vwLb  = na
var label vw2Lb = na
if barstate.islast
    label.delete(vwLb)
    label.delete(vw2Lb)
    vwLb  := i_showVw and i_vwLbOn and not na(vw) ? label.new(bar_index, vw, vwTxt, style = label.style_label_left, color = color.new(rgCol, 85), textcolor = rgCol, size = size.small) : na
    vw2Lb := i_vw2On and not na(vw2) ? label.new(bar_index, vw2, 'VWAP · ' + i_vw2Tf, style = label.style_label_left, color = color.new(i_vw2C, 85), textcolor = i_vw2C, size = size.small) : na


// ────────
// >ALERTS< ⑽
// ─────▾──
bool alUp  = i_alReg and isUp and not isUp[1]
bool alDn  = i_alReg and isDn and not isDn[1]
bool alBox = i_alBox and boxBreak
bool alRev = i_alRev and i_satRev and (revDn or revUp)

alertcondition(alUp,  'Trend Up',       'AVR: Regime → Trend Up')
alertcondition(alDn,  'Trend Down',     'AVR: Regime → Trend Down')
alertcondition(alBox, 'Box Break',      'AVR: Formation Box break')
alertcondition(alRev, 'Sat Reversal',   'AVR: Saturation reversal')

if alUp
    alert('AVR ' + syminfo.ticker + ': Regime → Trend Up',          alert.freq_once_per_bar_close)
if alDn
    alert('AVR ' + syminfo.ticker + ': Regime → Trend Down',        alert.freq_once_per_bar_close)
if alBox
    alert('AVR ' + syminfo.ticker + ': Formation Box break',        alert.freq_once_per_bar_close)
if alRev
    alert('AVR ' + syminfo.ticker + ': Saturation reversal ' + (revDn ? '↓' : '↑'), alert.freq_once_per_bar_close)
// ▴▴▴▴▴▴▴▴▴▴
// #endRegion
````
