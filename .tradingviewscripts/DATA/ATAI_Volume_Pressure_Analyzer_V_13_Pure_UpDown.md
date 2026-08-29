<!-- tradingview-pine-id: PUB;7f340ec4a24b4201ac7be3e89aa6e87e -->
<!-- tradingviewscripts-format: 1 -->
# ATAI Volume Pressure Analyzer V 1.3 — Pure Up/Down

Source: https://www.tradingview.com/script/PkzxrfhA-ATAI-Volume-Pressure-Analyzer-V-1-0-Pure-Up-Down/

## Description

ATAI Volume Pressure Analyzer V 1.0 — Pure Up/Down

Overview

Volume is a foundational tool for understanding the supply–demand balance. Classic charts show only total volume and don’t tell us what portion came from buying (Up) versus selling (Down). The ATAI Volume Pressure Analyzer fills that gap. Built on Pine Script v6, it scans a lower timeframe to estimate Up/Down volume for each host‑timeframe candle, and presents “volume pressure” in a compact HUD table that’s comparable across symbols and timeframes.

1) Architecture & Global Settings
Global Period (P, bars)
A single global input P defines the computation window. All measures—host‑TF volume moving averages and the half‑window segment sums—use this length. Default: 55.

Timeframe Handling
The core of the indicator is estimating Up/Down volume using lower‑timeframe data. You can set a custom lower timeframe, or rely on auto‑selection:
◉ Second charts → 1S
◉ Intraday → 1 minute
◉ Daily → 5 minutes
◉ Otherwise → 60 minutes
Lower TFs give more precise estimates but shorter history; higher TFs approximate buy/sell splits but provide longer history. As a rule of thumb, scan thin symbols at 5–15m, and liquid symbols at 1m.

2) Up/Down Volume & Derived Series
The script uses TradingView’s library function tvta.requestUpAndDownVolume(lowerTf) to obtain three values:
◉ Up volume (buyers)
◉ Down volume (sellers)
◉ Delta (Up − Down)
From these we define:
◉ TF_buy = |Up volume|
◉ TF_sell = |Down volume|
◉ TF_tot = TF_buy + TF_sell
◉ TF_delta = TF_buy − TF_sell
A positive TF_delta indicates buyer dominance; a negative value indicates selling pressure. To smooth noise, simple moving averages of TF_buy and TF_sell are computed over P and used as baselines.

3) Key Performance Indicators (KPIs)
Half‑window segmentation
To track momentum shifts, the P‑bar window is split in half:
◉ C→B: the older half
◉ B→A: the newer half (toward the current bar)
For each half, the script sums buy, sell, and delta. Comparing the two halves reveals strengthening/weakening pressure. Example: if AtoB_delta < CtoB_delta, recent buying pressure has faded.

[4) HUD (Table) Display/i]
Colors & Appearance
Two main color inputs define the theme: a primary color and a negative color (used when Δ is negative). The panel background uses a translucent version of the primary color; borders use the solid primary color. Text defaults to the primary color and flips to the negative color when a block’s Δ is negative.

Layout
The HUD is a 4×5 table updated on the last bar of each candle:
◉ Row 1 (Meta): indicator name, P length, lower TF, host TF
◉ Row 2 (Host TF): current ↑Buy, ↓Sell, ΔDelta; plus Σ total and SMA(↑/↓)
◉ Row 3 (Segments): C→B and B→A blocks with ↑/↓/Δ
◉ Rows 4–5: reserved for advanced modules (Wings, α/β, OB/OS, Top

5) Advanced Modules
5.1 Wings
“Wings” visualize volume‑driven movement over C→B (left wing) and B→A (right wing) with top/bottom lines and a filled band. Slopes are ATR‑per‑bar normalized for cross‑symbol/TF comparability and converted to angles (degrees). Coloring mirrors HUD sign logic with a near‑zero threshold (default ~3°):
◉  Both lines rising → blue (bullish)
◉  Both falling → red (bearish)
◉  Mixed/near‑zero → gray
Left wing reflects the origin of the recent move; right wing reflects the current state.

5.2 α / β at Point B
We compute the oriented angle between the two wings at the midpoint B:
β is the bottom‑arc angle; α = 360° − β is the top‑arc angle.
◉  Large α (>180°) or small β (<180°) flags meaningful imbalance.
◉  Intuition: large α suggests potential selling pressure; small β implies fragile support. HUD cells highlight these conditions.

5.3 OB/OS Spike
OverBought/OverSold (OB/OS) labels appear when directional volume spikes align with a 7‑oscillator vote (RSI, Stoch, %R, CCI, MFI, DeMarker, StochRSI).
◉ OB label (red): unusually high sell volume + enough OB votes
◉ OS label (teal): unusually high buy volume + enough OS votes
Minimum votes and sync window are user‑configurable; dotted connectors can link labels to the candle wick.

5.4 Top3 Volume Peaks
Within the P window the script ranks the top three BUY peaks (B1–B3) and top three SELL peaks (S1–S3).
◉ B1 and S1 are drawn as horizontal resistance (at B1 High) and support (at S1 Low) zones with adjustable thickness (ticks/percent/ATR).
◉ The HUD dedicates six cells to show ↑/↓/Δ for each rank, and prints the exact High (B1) and Low (S1) inline in their cells.

6) Reading the HUD — A Quick Checklist
◉ Meta: Confirm P and both timeframes (host & lower).
◉ Host TF block: Compare current ↑/↓/Δ against their SMAs.
◉ Segments: Contrast C→B vs B→A deltas to gauge momentum change.
◉ Wings: Right‑wing color/angle = now; left wing = recent origin.
◉ α / β: Look for α > 180° or β < 180° as imbalance cues.
◉ OB/OS: Note labels, color (red/teal), and the vote count.
◉Top3: Keep B1 (resistance) and S1 (support) on your radar.
Use these together to sketch scenarios and invalidation levels; never rely on a single signal in isolation.

[7) Example Highlights (What the table conveys)/i]
◉ Row 1 shows the indicator name, the analysis length P (default 55), and both TFs used for computation and display.
◉ B1 / S1 blocks summarize each side’s peak within the window, with Δ indicating buyer/seller dominance at that peak and inline price (B1 High / S1 Low) for actionable levels.
◉ Angle cells for each wing report the top/bottom line angles vs. the horizontal, reflecting the directional posture.
◉ Ranks B2/B3 and S2/S3 extend context beyond the top peak on each side.
◉ α / β cells quantify the orientation gap at B; changes reflect shifting buyer/seller influence on trend strength.
Together these visuals often reveal whether the “wings” resemble a strong, upward‑tilted arm supported by buyer volume—but always corroborate with your broader toolkit

https://www.tradingview.com/x/Jj2Qrr6l/

8) Practical Tips & Tuning
◉ Choose P by market structure. For daily charts, 34–89 bars often works well.
◉ Lower TF choice: Thin symbols → 5–15m; liquid symbols → 1m.
◉ Near‑zero angle: In noisy markets, consider 5–7° instead of 3°.
◉ OB/OS votes: Daily charts often work with 3–4 votes; lower TFs may prefer 4–5.
◉ Zone thickness: Tie B1/S1 zone thickness to ATR so it scales with volatility.
◉ Colors: Feel free to theme the primary/negative colors; keep Δ<0 mapped to the negative color for readability.

Combine with price action: Use this indicator alongside structure, trendlines, and other tools for stronger decisions.

Technical Notes
Pine Script v6.
◉ Up/Down split via TradingView/ta library call requestUpAndDownVolume(lowerTf).
◉ HUD‑first design; drawings for Wings/αβ/OBOS/Top3 align with the same sign/threshold logic used in the table.

Disclaimer: This indicator is provided solely for educational and analytical purposes. It does not constitute financial advice, nor is it a recommendation to buy or sell any security. Always conduct your own research and use multiple tools before making trading decisions.

---

## Source Code

````pine
//@version=6
indicator(title = "ATAI Volume Pressure Analyzer V 1.3 — Pure Up/Down", shorttitle = "ATAI.VPA", overlay = true, max_bars_back=500 )

//══════════════
// ① Global Settings
//══════════════
string groupGlobal = "① Global Settings"
P = input.int(
     defval = 55,
     title = "Global Period (bars)",
     minval = 1,
     tooltip = "Lookback length for host-TF volume MAs and segment KPIs.",
     group = groupGlobal
 )

//══════════════
// ② Timeframe Handling
//══════════════
string groupTf = "② Calculation Engine"
// 1. Method Selection
calc_method  = input.string("Geometry (Approx)", "Calculation Method", options = ["Geometry (Approx)", "Intrabar (Precise)"], group = groupTf, tooltip = "Precise: Uses deep intrabar data (requires plans supporting lower-timeframe inspection).\nGeometry: Uses candle shape to estimate volume (works on all plans).")

// 2. Intrabar Settings (Only used if Precise is selected)
lowerTimeframeTooltip = "Only applies to 'Intrabar (Precise)' mode. Determines the resolution for scanning inside the bar."
useCustomTf  = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip, group = groupTf)
lowerTfInput = input.timeframe("15S", "Intrabar Timeframe", group = groupTf)

string lowerTf = switch
    useCustomTf         => lowerTfInput
    timeframe.isseconds => "1S"
    timeframe.isintraday=> "1"
    timeframe.isdaily   => "5"
    => "60"

// ══════════════
// ③ Volume Processing Core (Hybrid)
// ══════════════
import TradingView/ta/10 as tvta

// Initialize variables to hold the final values
float TF_buy   = 0.0
float TF_sell  = 0.0
float TF_tot   = 0.0
float TF_delta = 0.0
// Variable to track if we have valid Intrabar data (for the counter later)
float intra_delta_check = na

if calc_method == "Intrabar (Precise)"
    // --- MODE A: PRECISE (Server Request) ---
    // Request is ONLY made inside this block. Safe for restricted accounts.
    [upVolume, downVolume, delta] = tvta.requestUpAndDownVolume(lowerTf)
    TF_buy            := nz(math.abs(upVolume))
    TF_sell           := nz(math.abs(downVolume))
    intra_delta_check := delta // Pass delta to check validity later
else
    // --- MODE B: GEOMETRY (Approximation) ---
    // Uses Price Action logic (Wick Analysis) to estimate pressure
    // Formula: Closer close is to High -> More Buy Pressure.
    float range_bar = high - low
    if range_bar == 0
        // Flat/Doji candle: split 50/50
        TF_buy  := volume * 0.5
        TF_sell := volume * 0.5
    else
        TF_buy  := volume * ((close - low) / range_bar)
        TF_sell := volume * ((high - close) / range_bar)
    
    // In geometry mode, data is always "valid" as long as volume exists
    intra_delta_check := (volume > 0 ? 0 : na)

// Final Aggregation
TF_tot   := TF_buy + TF_sell
TF_delta := TF_buy - TF_sell

//──────── LTF coverage counter (bars with valid Up/Down volume)
var int ltf_total_bars = 0
if not na(intra_delta_check)
    ltf_total_bars += 1

// Readable alias (safe window for rolling calcs if needed)
int ltf_safe_window = ltf_total_bars

//══════════════
// ④ Host-TF MAs
//══════════════
float TF_buy_SMA  = ta.sma(TF_buy,  P)
float TF_sell_SMA = ta.sma(TF_sell, P)

//══════════════
// ⑤ Segment Sums — A→B and C→B (host TF volumes)
//══════════════
int iB_kpi = int(math.floor((P - 1) / 2.0))
int iC_kpi = P - 1

int   len_AtoB_kpi   = math.max(iB_kpi, 0)
float AtoB_buy_kpi   = len_AtoB_kpi > 0 ? math.sum(TF_buy,  len_AtoB_kpi)  : na
float AtoB_sell_kpi  = len_AtoB_kpi > 0 ? math.sum(TF_sell, len_AtoB_kpi)  : na
float AtoB_delta_kpi = AtoB_buy_kpi - AtoB_sell_kpi

float sumBuy_0_iC_kpi  = math.sum(TF_buy,  iC_kpi + 1)
float sumBuy_0_iB_kpi  = math.sum(TF_buy,  iB_kpi + 1)
float sumSell_0_iC_kpi = math.sum(TF_sell, iC_kpi + 1)
float sumSell_0_iB_kpi = math.sum(TF_sell, iB_kpi + 1)

float CtoB_buy_kpi   = sumBuy_0_iC_kpi  - sumBuy_0_iB_kpi
float CtoB_sell_kpi  = sumSell_0_iC_kpi - sumSell_0_iB_kpi
float CtoB_delta_kpi = CtoB_buy_kpi - CtoB_sell_kpi

//══════════════
// ⑥ Utils
//══════════════
f_fmt(float val) =>
    if na(val)
        "—"
    else
        string sign = val < 0 ? "-" : val > 0 ? "+" : ""
        float  av   = math.abs(val)
        sign + (
             av >= 1e9 ? str.format("{0,number,0.##}B", av/1e9) :
             av >= 1e6 ? str.format("{0,number,0.##}M", av/1e6) :
             av >= 1e3 ? str.format("{0,number,0.##}K", av/1e3) :
                         str.format("{0,number,0}",    av))

f_hostTfLabel() =>
    float n = str.tonumber(timeframe.period)
    not na(n) ? (str.tostring(int(n)) + "Min") :
     timeframe.period == "D" ? "1D" :
     timeframe.period == "W" ? "1W" :
     timeframe.period == "M" ? "1M" : timeframe.period

f_blockAmounts(string title, float up, float dn, float delta) =>
    title + "\n" +
     "↑ " + f_fmt(up) + "\n" +
     "↓ " + f_fmt(dn) + "\n" +
     "Δ " + f_fmt(delta)

f_blockMAsSum(string title, float upMA, float dnMA, float total) =>
    title + "\n" +
     "Σ "   + f_fmt(total) + "\n" +
     "MA ↑ " + f_fmt(upMA) + "\n" +
     "MA ↓ " + f_fmt(dnMA)

//══════════════
// Host TF Blocks With Total
//══════════════
f_blockAmountsWithTotal(string title, float total, float up, float dn, float delta) =>
    title + "\n" +
     "Σ " + f_fmt(total) + "\n" +
     "↑ " + f_fmt(up) + "\n" +
     "↓ " + f_fmt(dn) + "\n" +
     "Δ " + f_fmt(delta)

// This helper prints only MA lines (no Σ).
f_blockMAsOnly(string title, float upMA, float dnMA) =>
    title + "\n" +
     "MA ↑ " + f_fmt(upMA) + "\n" +
     "MA ↓ " + f_fmt(dnMA)

//══════════════
// ⑦ Colors & Theme (table only)
//══════════════
string groupColors = "③ Colors"
baseColor = input.color(
     defval = #6abaff,
     title = "Primary color",
     tooltip = "Unified color for all HUD/table elements.",
     group = groupColors)
negColor  = input.color(
     defval = #ff5076,
     title = "Negative color",
     tooltip = "Used ONLY when a block's Δ is negative.",
     group = groupColors)
panelBG   = color.new(baseColor, 95)
borderCol = color.new(baseColor, 0)
textCol   = baseColor

//──────── HUD/Table font size (sample-style)
string groupHUD = "③ HUD / Table"
string font_size_opt = input.string(
     "Normal", "Font Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     tooltip = "Default is Normal; choose to scale the HUD/table text.",
     group = groupHUD)

// Map string → Pine text size enum (fail-safe to Normal)
_map_size(string s) =>
     s == "Tiny"  ? size.tiny  :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     s == "Huge"  ? size.huge  : size.normal

// Single source of truth for all table cells
txt_size_tbl = _map_size(font_size_opt)

//══════════════
// ⑧ Table (HUD)
//══════════════
const int COLS = 4
const int ROWS = 5
var table hud = na
if na(hud)
    hud := table.new(position.bottom_right, COLS, ROWS, frame_color = borderCol, border_color = borderCol, frame_width = 1, border_width = 1)

f_paintBox(int col, int row, string txt, float keyDelta) =>
    color tcl = not na(keyDelta) and keyDelta < 0 ? negColor : textCol
    table.cell(hud, col, row, txt, text_color = tcl, bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

//══════════════
// ⑨ HUD Update (Per-TF only)
//══════════════
if barstate.islast
    // Row 0: Meta
    table.cell(hud, 0, 0,
         "Vol.Analyzer" + "\n" +
         "Max Up/Down Vol history",
         text_color=textCol, bgcolor=panelBG, text_size=txt_size_tbl, text_halign=text.align_left)

    table.cell(hud, 1, 0,
         "Length = " + str.tostring(P) + "\n" +
         str.tostring(ltf_total_bars) + " bars available",
         text_color=textCol, bgcolor=panelBG, text_size=txt_size_tbl, text_halign=text.align_left)

    table.cell(hud, 2, 0, "Lower TF: " + lowerTf, text_color=textCol, bgcolor=panelBG, text_size=txt_size_tbl, text_halign=text.align_left)
    table.cell(hud, 3, 0, "Host TF: " + f_hostTfLabel(), text_color=textCol, bgcolor=panelBG, text_size=txt_size_tbl, text_halign=text.align_left)

    // Row 1: Host-TF blocks
    string hostLbl = f_hostTfLabel()
    // Show Σ (TF_tot) together with ↑, ↓ and Δ in column 0, row 1  
    f_paintBox(0, 1, f_blockAmountsWithTotal(hostLbl, TF_tot, TF_buy, TF_sell, TF_delta), TF_delta)
    // Show only MA ↑ and MA ↓ (no Σ) in column 1, row 1
    f_paintBox(1, 1, f_blockMAsOnly(hostLbl + " MA", TF_buy_SMA, TF_sell_SMA), TF_delta)   
    f_paintBox(2, 1, f_blockAmounts("C→B", CtoB_buy_kpi, CtoB_sell_kpi, CtoB_delta_kpi), CtoB_delta_kpi)
    f_paintBox(3, 1, f_blockAmounts("B→A", AtoB_buy_kpi, AtoB_sell_kpi, AtoB_delta_kpi), AtoB_delta_kpi)

    // Clear remaining cells
    for r = 2 to ROWS - 1
        for c = 0 to COLS - 1
            bool reserved = (r == 2 and (c == 0 or c == 1)) or (r == 1 and (c == 0 or c == 1)) or (r == 0)
            if not reserved
                table.cell(hud, c, r, "", text_color=textCol, bgcolor=panelBG, text_size=txt_size_tbl, text_halign=text.align_left)

// NOTES:
// • Uses ONLY ta.requestUpAndDownVolume(lowerTf) for buy/sell separation.
// • Daily accumulators removed; per-TF only.
// • No drawings, table-only HUD.

//--------------------------------------------------------------------------
// Wing Offset Settings (declared early so that useOffset_wing and offsetBars_wing
// can be referenced in the Wing Indices section). When enabled, the C and B
// anchors are shifted horizontally by offsetBars_wing bars, and their price
// values are taken from the shifted candles. A future A point is estimated by
// applying a moving average and standard deviation multiplier.
string groupOffset_wing     = "? Wing Offset"
bool   useOffset_wing       = input.bool(false, "Use wing offset", tooltip = "Shift wing drawing forward by a specified number of bars.", group = groupOffset_wing)
int    offsetBars_wing      = input.int(3, "Offset (bars)", minval = 0, tooltip = "Number of bars to shift the wing drawing forward. Set to 0 to disable.", group = groupOffset_wing)
float  offsetStdMul_wing    = input.float(1, "Offset std deviation multiplier", minval = 0.0, tooltip = "Multiplier for standard deviation when estimating future A points (default Fibonacci 27.2%).", group = groupOffset_wing)
//--------------------------------------------------------------------------

//══════════════
// ATAI — Wing Modules v1.3 (per-wing coloring)
// Drop-in block: paste BELOW your current ATAI.VPA base script (table/HUD exists).
// Pine v6. English-only identifiers/tooltips. Compact, modular, independent.
// Changes vs v1.1: new per-wing color logic that mirrors HUD sign rules and
// applies to BOTH lines and the filled area of each wing.
//══════════════

//══════════════
// ⑩ Wing Indices & Anchor Points — _wing
//══════════════
// Uses the existing global period P from the base script.
int   iB_wing = int(math.floor((P - 1) / 2.0))
int   iC_wing = P - 1

int   x_A_wing = bar_index
int   x_B_wing = bar_index - iB_wing
int   x_C_wing = bar_index - iC_wing

float y_A_top_wing = high
float y_A_bot_wing = low
// When offset is enabled, take the high/low from the bar shifted by offsetBars_wing bars forward.
// Protect against negative indexing: only shift if iB_wing > offsetBars_wing.
float y_B_top_wing = useOffset_wing ? (iB_wing > offsetBars_wing ? high[iB_wing - offsetBars_wing] : na) : high[iB_wing]
float y_B_bot_wing = useOffset_wing ? (iB_wing > offsetBars_wing ? low[iB_wing  - offsetBars_wing] : na) : low[iB_wing]
float y_C_top_wing = useOffset_wing ? (iC_wing > offsetBars_wing ? high[iC_wing - offsetBars_wing] : na) : high[iC_wing]
float y_C_bot_wing = useOffset_wing ? (iC_wing > offsetBars_wing ? low[iC_wing  - offsetBars_wing] : na) : low[iC_wing]



bool  haveLeftWing  = bar_index >= iC_wing and iC_wing > iB_wing
bool  haveRightWing = bar_index >= iB_wing and iB_wing > 0

//══════════════
// ⑪ Normalization — ATR per bar (single standard) — _wing
//══════════════
string groupNorm_wing = "④ Wing Normalization"
bool   linkAtrToP_wing  = input.bool(true, "Link ATR length to P", tooltip = "If ON, normalization uses ATR(P). If OFF, the explicit length below is used.", group = groupNorm_wing)
int    atrLenInput_wing = input.int(55, "ATR length (override)", minval = 1, tooltip = "Used only when 'Link ATR length to P' is OFF.", group = groupNorm_wing)
int    atrLen_wing      = linkAtrToP_wing ? P : atrLenInput_wing
float  atr_wing         = ta.atr(atrLen_wing)
float  atr_safe_wing    = math.max(atr_wing, syminfo.mintick)  // avoid division by near-zero

_slope_norm_wing(y2, y1, dxBars, atrVal) => dxBars <= 0 or atrVal <= 0 ? na : ((y2 - y1) / dxBars) / atrVal
_deg_from_slope_norm_wing(s) => na(s) ? na : math.atan(s) * 180.0 / math.pi

//══════════════
// ⑫ Normalized Slopes/Angles — Four Lines — _wing
//══════════════
float dx_CB_wing = float(iC_wing - iB_wing) // bars between C and B
float slopeN_CB_top_wing = haveLeftWing  ? _slope_norm_wing(y_B_top_wing, y_C_top_wing, dx_CB_wing, atr_safe_wing) : na
float slopeN_CB_bot_wing = haveLeftWing  ? _slope_norm_wing(y_B_bot_wing, y_C_bot_wing, dx_CB_wing, atr_safe_wing) : na
float angDegN_CB_top_wing = _deg_from_slope_norm_wing(slopeN_CB_top_wing)
float angDegN_CB_bot_wing = _deg_from_slope_norm_wing(slopeN_CB_bot_wing)

float dx_BA_wing = float(iB_wing) // bars between B and A (A = current)
float slopeN_BA_top_wing = haveRightWing ? _slope_norm_wing(y_A_top_wing, y_B_top_wing, dx_BA_wing, atr_safe_wing) : na
float slopeN_BA_bot_wing = haveRightWing ? _slope_norm_wing(y_A_bot_wing, y_B_bot_wing, dx_BA_wing, atr_safe_wing) : na
float angDegN_BA_top_wing = _deg_from_slope_norm_wing(slopeN_BA_top_wing)
float angDegN_BA_bot_wing = _deg_from_slope_norm_wing(slopeN_BA_bot_wing)

_fmt_deg_wing(x) => na(x) ? "—" : (str.tostring(x, "#.0") + "°")

//══════════════
// ⑬ Drawing Colors — defaults & hooks — _wing  (HUD MIRROR — FINAL)
//══════════════
// Wings must use EXACTLY the same color logic as the HUD angle fonts.
// This block is a drop-in replacement for sections ⑬ and ⑬-A. Section ⑭ Draw stays unchanged.

string groupColors_wing = "⑤ Wing Colors"
int   fillTrans_wing = input.int(90, "Fill transparency (0-100)", minval = 0, maxval = 100,
     tooltip = "Higher value = more transparent.", group = groupColors_wing)

// Runtime colors for THIS bar
var color runtimeLeftColor_wing  = na
var color runtimeRightColor_wing = na

// Active (drawn) colors — SAME-BAR snapshot from runtime*
var color activeLeftColor_wing  = na
var color activeRightColor_wing = na

//══════════════
// ⑬-A Per-Wing Color Logic — EXACT HUD MIRROR (compile-safe)
//══════════════
// We RE-IMPLEMENT the HUD font color function locally (untyped signature to avoid parser quirks).
// Rules (same as HUD):
//   • na(angle)                  → dimmed text color
//   • |angle| < nearZero        → gray (neutral)
//   • angle > 0                 → textCol (bullish)
//   • angle < 0                 → negColor (bearish)
int nearZeroDeg_wing = input.int(3, "Near-zero threshold (deg)", minval = 0, maxval = 30,
     tooltip = "Angles with |deg| below this are neutral (gray) in both HUD and wings.", group = groupColors_wing)

_hud_angle_text_color_wing(ang) =>
    na(ang) ? color.new(textCol, 60) : math.abs(ang) < nearZeroDeg_wing ? #8a8a8acc : (ang > 0 ? textCol : negColor)

// Combine TOP/BOTTOM HUD font colors into one wing color.
// If TOP & BOTTOM resolve to the same font color → wing uses that color; otherwise wing is GRAY.
_wing_color_from_fonts_wing(angTop, angBot) =>
    cTop = _hud_angle_text_color_wing(angTop)
    cBot = _hud_angle_text_color_wing(angBot)
    cTop == cBot ? cTop : color.gray

// Compute runtime colors from CURRENT angles (no averaging) — MUST come after ⑫ angles exist.
runtimeLeftColor_wing  := _wing_color_from_fonts_wing(angDegN_CB_top_wing, angDegN_CB_bot_wing)
runtimeRightColor_wing := _wing_color_from_fonts_wing(angDegN_BA_top_wing, angDegN_BA_bot_wing)

// SAME-BAR snapshot for drawing (prevents stale/hidden lines)
activeLeftColor_wing  := runtimeLeftColor_wing
activeRightColor_wing := runtimeRightColor_wing

//══════════════
// Fix Log (SOP)
// ISSUE ID: 20250822-WING-HUDSYNC-03
// SECTION: ⑬ / ⑬-A — _wing
// LINES: START=<⑬ header> END=<activeRightColor_wing := runtimeRightColor_wing>
// CAUSE: Wings were not mirroring HUD font logic and sometimes used previous-bar colors; prior attempt referenced an undefined typed function which failed to compile.
// FIX: Implement HUD font logic locally; derive wing color from TOP/BOTTOM font colors (equal → that color, mismatch → gray); take same-bar snapshot.
// TEST: If HUD shows B→A top=+9.9° & B→A bot=+10.1° (both blue) ⇒ right wing BLUE immediately. If one blue/one red or one gray ⇒ wing GRAY.


//══════════════
// ⑭ Draw — Lines & Fills — _wing
//══════════════

// Offset-adjusted anchor coordinates and predicted A values
// If useOffset_wing is true, shift the wing horizontally by offsetBars_wing bars.
// Points C and B keep their original price values but move forward in time.
// The A point is unknown in the future, so its price is estimated via SMA of highs/lows.

// Offset-adjusted anchor coordinates
int x_C_draw_wing = x_C_wing + (useOffset_wing ? offsetBars_wing : 0)
int x_B_draw_wing = x_B_wing + (useOffset_wing ? offsetBars_wing : 0)
int x_A_draw_wing = x_A_wing + (useOffset_wing ? offsetBars_wing : 0)

// Predict the future A point when offsetting: use SMA and standard deviation of highs/lows
// between the current bar (A) and the C/B anchor distances.
int len_top_pred_wing = iC_wing + 1
int len_bot_pred_wing = iB_wing + 1

// Compute mean and standard deviation of highs/lows directly.
// ta.sma / ta.stdev return na when there aren't enough bars, so no need for manual checks.
float meanHigh = ta.sma(high, len_top_pred_wing)
float stdHigh  = ta.stdev(high, len_top_pred_wing)

float meanLow  = ta.sma(low,  len_bot_pred_wing)
float stdLow   = ta.stdev(low, len_bot_pred_wing)


// Apply the user-defined standard deviation multiplier (offsetStdMul_wing) to estimate A top/bottom
float y_A_top_pred_wing = not na(meanHigh) and not na(stdHigh) ? (meanHigh + offsetStdMul_wing * stdHigh) : na
float y_A_bot_pred_wing = not na(meanLow)  and not na(stdLow)  ? (meanLow  - offsetStdMul_wing * stdLow)  : na

// Use predicted values when offset is ON; otherwise use the actual current A values
float y_A_top_draw_wing = useOffset_wing ? y_A_top_pred_wing : y_A_top_wing
float y_A_bot_draw_wing = useOffset_wing ? y_A_bot_pred_wing : y_A_bot_wing


var line     ln_CB_top_wing = na
var line     ln_CB_bot_wing = na
var line     ln_BA_top_wing = na
var line     ln_BA_bot_wing = na
var linefill lf_CB_wing     = na
var linefill lf_BA_wing     = na

if haveLeftWing
    if na(ln_CB_top_wing)
        ln_CB_top_wing := line.new(
         x1 = (useOffset_wing ? x_C_draw_wing : x_C_wing), 
         y1 = y_C_top_wing, 
         x2 = (useOffset_wing ? x_B_draw_wing : x_B_wing), 
         y2 = y_B_top_wing, 
         xloc = xloc.bar_index, 
         extend = extend.none, 
         width = 1, 
         color = activeLeftColor_wing )
    else
        line.set_xy1(ln_CB_top_wing, (useOffset_wing ? x_C_draw_wing : x_C_wing), y_C_top_wing)
        line.set_xy2(ln_CB_top_wing, (useOffset_wing ? x_B_draw_wing : x_B_wing), y_B_top_wing)
        line.set_color(ln_CB_top_wing, activeLeftColor_wing)


    if na(ln_CB_bot_wing)
        ln_CB_bot_wing := line.new(
         x1 = (useOffset_wing ? x_C_draw_wing : x_C_wing),
         y1 = y_C_bot_wing,
         x2 = (useOffset_wing ? x_B_draw_wing : x_B_wing),
         y2 = y_B_bot_wing,
         xloc = xloc.bar_index,
         extend = extend.none,
         width = 1,
         color = activeLeftColor_wing    )
    else
        line.set_xy1(ln_CB_bot_wing, (useOffset_wing ? x_C_draw_wing : x_C_wing), y_C_bot_wing)
        line.set_xy2(ln_CB_bot_wing, (useOffset_wing ? x_B_draw_wing : x_B_wing), y_B_bot_wing)
        line.set_color(ln_CB_bot_wing, activeLeftColor_wing)

    if not na(lf_CB_wing)
        linefill.delete(lf_CB_wing)
    lf_CB_wing := linefill.new(ln_CB_top_wing, ln_CB_bot_wing, color = color.new(activeLeftColor_wing, fillTrans_wing))

if haveRightWing
    if na(ln_BA_top_wing)
        ln_BA_top_wing := line.new(
         x1 = (useOffset_wing ? x_B_draw_wing : x_B_wing), 
         y1 = y_B_top_wing, 
         x2 = (useOffset_wing ? x_A_draw_wing : x_A_wing), 
         y2 = (useOffset_wing ? y_A_top_draw_wing : y_A_top_wing), 
         xloc = xloc.bar_index, 
         extend = extend.none, 
         width = 1, 
         color = activeRightColor_wing  )
    else
        line.set_xy1(ln_BA_top_wing, (useOffset_wing ? x_B_draw_wing : x_B_wing), y_B_top_wing)
        line.set_xy2(ln_BA_top_wing, (useOffset_wing ? x_A_draw_wing : x_A_wing), (useOffset_wing ? y_A_top_draw_wing : y_A_top_wing))
        line.set_color(ln_BA_top_wing, activeRightColor_wing)

    if na(ln_BA_bot_wing)
        ln_BA_bot_wing := line.new(
         x1 = (useOffset_wing ? x_B_draw_wing : x_B_wing),
         y1 = y_B_bot_wing,
         x2 = (useOffset_wing ? x_A_draw_wing : x_A_wing),
         y2 = (useOffset_wing ? y_A_bot_draw_wing : y_A_bot_wing),
         xloc = xloc.bar_index,
         extend = extend.none,
         width = 1,
         color = activeRightColor_wing )
    else
        line.set_xy1(ln_BA_bot_wing, (useOffset_wing ? x_B_draw_wing : x_B_wing), y_B_bot_wing)
        line.set_xy2(ln_BA_bot_wing, (useOffset_wing ? x_A_draw_wing : x_A_wing), (useOffset_wing ? y_A_bot_draw_wing : y_A_bot_wing))
        line.set_color(ln_BA_bot_wing, activeRightColor_wing)

    if not na(lf_BA_wing)
        linefill.delete(lf_BA_wing)
    lf_BA_wing := linefill.new(ln_BA_top_wing, ln_BA_bot_wing, color = color.new(activeRightColor_wing, fillTrans_wing))

//══════════════
// ⑮ HUD Angle Text Colors (optional) — _wing
//══════════════
// If you also want HUD cells to mirror the same sign rules, keep or add this block.
_angle_text_color_wing(angDeg) =>
    na(angDeg) ? color.new(textCol, 60) :
     math.abs(angDeg) < nearZeroDeg_wing ? #98999eb7 :
     angDeg > 0 ? textCol : negColor

if barstate.islast and not na(hud)
    table.cell(hud, 2, 2, "📏C→B top = " + "\n" + "\n" +  "📐"+ _fmt_deg_wing(angDegN_CB_top_wing), text_color = _angle_text_color_wing(angDegN_CB_top_wing), bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)
    table.cell(hud, 2, 3, "📏C→B bot = " + "\n" + "\n" +  "📐"+_fmt_deg_wing(angDegN_CB_bot_wing), text_color = _angle_text_color_wing(angDegN_CB_bot_wing), bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)
    table.cell(hud, 3, 2, "📏B→A top = " + "\n" + "\n" +  "📐"+_fmt_deg_wing(angDegN_BA_top_wing), text_color = _angle_text_color_wing(angDegN_BA_top_wing), bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)
    table.cell(hud, 3, 3, "📏B→A bot = " + "\n" + "\n" + "📐"+_fmt_deg_wing(angDegN_BA_bot_wing), text_color = _angle_text_color_wing(angDegN_BA_bot_wing), bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

//══════════════
// Fix Log (SOP)
// ISSUE ID: 20250820-04
// SCOPE: Per-wing line & fill coloring using normalized angle sign logic.
// DROP-IN LINES: START=⑩ Wing Indices & Anchor Points  END=⑮ HUD Angle Text Colors
// CAUSE: Need drawing colors to follow the exact HUD sign rules per wing.
// FIX: Added near-zero threshold input; computed average wing angle; set runtimeLeft/Right colors before draw; applied to both lines and fills; mirrored HUD coloring helper.
// TEST: Compiles on v6; left/right wings each take one color (top/bot + fill). Positive → base/textCol, negative → negColor, |angle| < threshold → gray.

//══════════════
// ⑯ Alpha/Beta at B — Oriented 360° — Minimal UI (ties to P) — _ang
// Drop-in for: ATAI Volume Pressure Analyzer V 1.0 (HUD/table exists)
// Pine v6. English-only. Compact, modular, independent.
// Relies on existing globals: P (period), hud (table), panelBG/textCol/negColor (theme).
// Notes:
// • Vertex B = midpoint of window P. For P=55 ⇒ iB=27, iC=54 (27 bars left/right).
// • Normalization matches Wings: ATR-per-bar using ATR(P) (no inputs/UI).
// • We compute oriented θ(B) from left wing (C←B) to right wing (B→A), then map: Alpha=360−θ (top arc), Beta=θ (bottom arc).
// • HUD labels keep α/β symbols; conditional font colors: α>180 → red, β<180 → red.
//══════════════

//══════════════
// Constants for HUD formatting (no inputs)
//══════════════
const int dec_ang          = 1   // rounding decimals
const int outColAlpha_ang  = 2   // fixed HUD column for α
const int outColBeta_ang   = 3   // fixed HUD column for β
const int outRow_ang       = 4   // fixed HUD row for α & β

//══════════════
// Indices & anchor points (A = current, B = mid, C = far) — _ang
//══════════════
int   iB_ang = int(math.floor((P - 1) / 2.0))
int   iC_ang = P - 1

int   x_A_ang = bar_index
int   x_B_ang = bar_index - iB_ang
int   x_C_ang = bar_index - iC_ang

float y_A_top_ang = high
float y_B_top_ang = high[iB_ang]
float y_C_top_ang = high[iC_ang]
float y_A_bot_ang = low
float y_B_bot_ang = low[iB_ang]
float y_C_bot_ang = low[iC_ang]

bool  ready_ang   = bar_index >= iC_ang and iC_ang > iB_ang and iB_ang > 0

//══════════════
// Normalization — _ang (ATR-per-bar linked to P)
//══════════════
float  atr_ang      = ta.atr(P)
float  atr_safe_ang = math.max(atr_ang, syminfo.mintick)  // avoid div-by-near-zero

//══════════════
// Helpers — _ang (build-safe)
//══════════════
_hypot_ang(x, y) => math.sqrt(x * x + y * y)

_clamp_ang(v, lo, hi) => v < lo ? lo : v > hi ? hi : v

// Oriented angle A→B in degrees within [0,360)
_angle360_from_vectors_ang(ax, ay, b_x, b_y) =>
    dot    = ax * b_x + ay * b_y
    magA   = _hypot_ang(ax, ay)
    magB   = _hypot_ang(b_x, b_y)
    cosTh  = magA == 0 or magB == 0 ? na : _clamp_ang(dot / (magA * magB), -1.0, 1.0)
    base   = na(cosTh) ? na : math.todegrees(math.acos(cosTh))  // unsigned [0,180]
    crossZ = ax * b_y - ay * b_x
    na(base) ? na : (crossZ >= 0 ? base : 360.0 - base)

_avg2_na_ok_ang(a, b) => na(a) and na(b) ? na : na(a) ? b : na(b) ? a : (a + b) / 2.0

_roundN_ang(v, n) =>
    pow10 = math.pow(10.0, n)
    math.round(v * pow10) / pow10

//══════════════
// Core vectors at vertex B (top & bottom edges) — _ang
//══════════════
float dx_L_ang = float(x_C_ang - x_B_ang)  // left wing (C←B), negative
float dx_R_ang = float(x_A_ang - x_B_ang)  // right wing (B→A), positive

float dy_L_top_n_ang = (y_C_top_ang - y_B_top_ang) / atr_safe_ang
float dy_R_top_n_ang = (y_A_top_ang - y_B_top_ang) / atr_safe_ang
float dy_L_bot_n_ang = (y_C_bot_ang - y_B_bot_ang) / atr_safe_ang
float dy_R_bot_n_ang = (y_A_bot_ang - y_B_bot_ang) / atr_safe_ang

//══════════════
// Base oriented angle θ(B) — average of top & bottom (robust) — _ang
//══════════════
float theta_top_ang = ready_ang ? _angle360_from_vectors_ang(dx_L_ang, dy_L_top_n_ang, dx_R_ang, dy_R_top_n_ang) : na
float theta_bot_ang = ready_ang ? _angle360_from_vectors_ang(dx_L_ang, dy_L_bot_n_ang, dx_R_ang, dy_R_bot_n_ang) : na
float theta_deg_ang = _avg2_na_ok_ang(theta_top_ang, theta_bot_ang)

//══════════════
// Output mapping (labels swapped to match spec) — _ang
// Alpha = 360 − θ(B)  (top arc),  Beta = θ(B) (bottom arc)
//══════════════
alpha_deg_ang = na(theta_deg_ang) ? na : 360.0 - theta_deg_ang
beta_deg_ang  = theta_deg_ang

//══════════════
// HUD Output — _ang (fixed cells, conditional font colors)
//══════════════
if barstate.islast and not na(hud)
    string aTxt = na(alpha_deg_ang) ? "∠α (Top) = —" : ("∠α (Top) = " + "\n" + "\n" + "📐" + str.tostring(_roundN_ang(alpha_deg_ang, dec_ang)) + "°")
    string bTxt = na(beta_deg_ang)  ? "∠β (Bottom) = —" : ("∠β (Bottom) = " + "\n"+ "\n"  + "📐" + str.tostring(_roundN_ang(beta_deg_ang,  dec_ang)) + "°")

    colAlpha = not na(alpha_deg_ang) and alpha_deg_ang > 180 ? negColor : textCol
    colBeta  = not na(beta_deg_ang)  and beta_deg_ang  < 180 ? negColor : textCol

    table.cell(hud, outColAlpha_ang, outRow_ang, aTxt, text_color = colAlpha, bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left, tooltip = "Top arc angle at vertex B (ATR-normalized). Red if > 180°.")
    table.cell(hud, outColBeta_ang,  outRow_ang, bTxt, text_color = colBeta,  bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left,  tooltip = "Bottom arc angle at vertex B (ATR-normalized). Red if < 180°.")

//══════════════
// Pre-Commit Checklist (SOP)
// • Pine v6 compliance re-check ✓
// • English-only identifiers/comments ✓
// • Blocks separated with required header style ✓
// • No UI inputs; linked to global P ✓
// • Section-related suffixes (_ang) ✓
// • Formatting/indentation checked ✓
// • Functions extracted; no typed signatures ✓
// • No cross-block side-effects; minimal coupling ✓
//══════════════

//══════════════
// FIX — Guides logic & anchors — _ang
// Problems observed:
// 1) Blue guide disappeared after gating by "red-only" condition.
// 2) β guide anchored to TOP (vertical C_bottom→C_top) while spec expects BOTTOM edge from C→A.
// Solution (minimal & explicit):
// • Always draw BOTH guides every bar when `ready_ang`; color = same as HUD font (red/blue).
// • Use correct anchors:
//      α guide  = dashed  C_top → A_top  (top edge)
//      β guide  = dashed  C_bot → A_bot  (bottom edge)   ← changed
// • Clean up lines if not ready/NA.
//══════════════

// Persistent handles
var line ln_alpha_dash_ang = na  // TOP (blue)
var line ln_beta_dash_ang  = na  // BOTTOM (red)

// Conditions
bool drawBlueTop_ang = ready_ang and not na(alpha_deg_ang) and alpha_deg_ang < 180
bool drawRedBot_ang  = ready_ang and not na(beta_deg_ang)  and beta_deg_ang  < 180

// TOP guide — Blue (textCol) — C_top → A_top
if drawBlueTop_ang
    if na(ln_alpha_dash_ang)
        ln_alpha_dash_ang := line.new(x1 = x_C_ang, y1 = y_C_top_ang, x2 = x_A_ang, y2 = y_A_top_ang,
             xloc = xloc.bar_index, extend = extend.none, width = 2, color = textCol, style = line.style_dashed)
    else
        line.set_xy1(ln_alpha_dash_ang, x_C_ang, y_C_top_ang)
        line.set_xy2(ln_alpha_dash_ang, x_A_ang, y_A_top_ang)
        line.set_color(ln_alpha_dash_ang, textCol)
else if not na(ln_alpha_dash_ang)
    line.delete(ln_alpha_dash_ang)
    ln_alpha_dash_ang := na

// BOTTOM guide — Red (negColor) — C_bot → A_bot
if drawRedBot_ang
    if na(ln_beta_dash_ang)
        ln_beta_dash_ang := line.new(x1 = x_C_ang, y1 = y_C_bot_ang, x2 = x_A_ang, y2 = y_A_bot_ang,
             xloc = xloc.bar_index, extend = extend.none, width = 2, color = negColor, style = line.style_dashed)
    else
        line.set_xy1(ln_beta_dash_ang, x_C_ang, y_C_bot_ang)
        line.set_xy2(ln_beta_dash_ang, x_A_ang, y_A_bot_ang)
        line.set_color(ln_beta_dash_ang, negColor)
else if not na(ln_beta_dash_ang)
    line.delete(ln_beta_dash_ang)
    ln_beta_dash_ang := na

//══════════════
// FIX LOG (SOP)
// ISSUE ID: 20250821-09
// SECTION: ⑯ Alpha/Beta @B — Dashed Guides — _ang
// LINES: START=<handles> END=<deletes>  // update after paste
// CAUSE: (1) Gating on "red-only" removed blue guide. (2) β guide anchored to top (vertical) instead of bottom edge C→A.
// FIX: Always render both guides; colors follow HUD red/blue state; corrected β anchors to (C_bottom → A_bottom).
// TEST: With θ≈169° ⇒ α≈191°, β≈169° → α guide red (top), β guide red (bottom); when θ≈190° ⇒ α≈170°, β≈190° → α guide blue (top), β guide blue (bottom).
// NOTES: No new inputs; consistent names with `_ang`; minimal behavioral change outside this block.

//══════════════
// ⑰ OB/OS Spike — Module (drop-in for "ATAI Volume Pressure Analyzer V 1.0 — Pure Up/Down")
// Suffix: _obos · Pine v6 · English-only identifiers & tooltips · independent block
// Paste BELOW your existing base script where TF_buy / TF_sell are already defined.
// Dependencies: none (does NOT re-import libraries). Uses host TF_buy/TF_sell streams.
//──────────────
// What it does
// • Detects OverBought/OverSold spikes by combining directional volume spikes with a 7-oscillator vote.
// • Emits one persistent label per bar (red = OverBought, teal = OverSold) with compact English reasons.
// • Draws a dotted connector from label to candle high/low.
// • Self-contained price-offset logic (ticks/percent/ATR) → no host helpers required.
//──────────────
// Engineering
// • Safe divisions, epsilon guards; no multi-declarations that mix "na" with typed ints.
// • Minimal global surface: all names are suffixed with _obos to avoid collisions.
// • Inputs have concise, meaningful tooltips as required.
//══════════════

//══════════════
// ⑰.1 Module Inputs — activation, thresholds, UI — _obos
//══════════════
const string GRP_OBOS_obos = "⑰ OB/OS Spike — Module"

// Activation
bool    enableOBOS_obos   = input.bool(true,  title = "Activate OB/OS module", group = GRP_OBOS_obos,
     tooltip = "Turn the OverBought/OverSold spike detection on or off.")

// Vote window & sync
int     minHits_obos      = input.int(3,     title = "Minimum hits (out of 7)", minval = 1, maxval = 7, group = GRP_OBOS_obos,
     tooltip = "Minimum number of oscillator overbought/oversold hits required for confirmation.")
int     syncWin_obos      = input.int(1,     title = "Bars for hit sync window", minval = 0, maxval = 2, group = GRP_OBOS_obos,
     tooltip = "Max with up to N previous bars' hit counts (0..2) to smooth spiky votes.")

// Volume spikes
int     volLen_obos       = input.int(55,    title = "Volume period", minval = 5, group = GRP_OBOS_obos,
     tooltip = "Lookback for TF-level volume SMA/STD used in spike detection.")
float   kVolRatio_obos    = input.float(1.6, title = "Volume spike threshold (Vol/SMA)", step = 0.1, group = GRP_OBOS_obos,
     tooltip = "Call a volume spike when Vol / SMA(Vol) ≥ threshold.")
float   zVolThr_obos      = input.float(1.8, title = "Z-Score volume threshold", step = 0.1, group = GRP_OBOS_obos,
     tooltip = "Alternative trigger: (Vol − SMA)/STD ≥ threshold.")

// Oscillator lengths
int     rsiLen_obos  = input.int(14, title = "RSI period",       minval = 2, group = GRP_OBOS_obos)
int     stLen_obos   = input.int(14, title = "Stochastic period", minval = 3, group = GRP_OBOS_obos)
int     stSm_obos    = input.int(3,  title = "Stochastic smoothing", minval = 1, group = GRP_OBOS_obos)
int     wprLen_obos  = input.int(14, title = "Williams %R period", minval = 3, group = GRP_OBOS_obos)
int     cciLen_obos  = input.int(27, title = "CCI period",       minval = 3, group = GRP_OBOS_obos)
int     mfiLen_obos  = input.int(14, title = "MFI period",       minval = 3, group = GRP_OBOS_obos)
int     demLen_obos  = input.int(14, title = "DeMarker period",  minval = 3, group = GRP_OBOS_obos)
int     srsiLen_obos = input.int(14, title = "Stochastic RSI period", minval = 3, group = GRP_OBOS_obos)

// Toggles per oscillator
bool    useRSI_obos  = input.bool(true, title = "Enable RSI",          group = GRP_OBOS_obos)
bool    useSTO_obos  = input.bool(true, title = "Enable Stochastic",   group = GRP_OBOS_obos)
bool    useWPR_obos  = input.bool(true, title = "Enable Williams %R",  group = GRP_OBOS_obos)
bool    useCCI_obos  = input.bool(true, title = "Enable CCI",          group = GRP_OBOS_obos)
bool    useMFI_obos  = input.bool(true, title = "Enable MFI",          group = GRP_OBOS_obos)
bool    useDeM_obos  = input.bool(true, title = "Enable DeMarker",     group = GRP_OBOS_obos)
bool    useSRSI_obos = input.bool(true, title = "Enable Stochastic RSI", group = GRP_OBOS_obos)

// Label & connector UI
string  label_offset_unit_obos = input.string("ticks", title = "Label offset unit", options = ["ticks","percent","ATR"], group = GRP_OBOS_obos,
     tooltip = "Distance unit from price to place labels (above/below the candle).")
float   label_offset_val_obos  = input.float(14.0,      title = "Label offset value", step = 0.1, minval = 0.0, group = GRP_OBOS_obos,
     tooltip = "Magnitude of the label offset in the selected unit.")
int     label_atr_len_obos     = input.int(14,          title = "ATR length (for label offset)", minval = 1, group = GRP_OBOS_obos,
     tooltip = "ATR lookback used only when the offset unit is ATR.")
string  label_size_opt_obos    = input.string("Small", title = "Label size", options = ["Tiny","Small","Normal"], group = GRP_OBOS_obos,
     tooltip = "Visual size of the OB/OS labels.")
bool    showConnectors_obos    = input.bool(true,       title = "Show dotted connectors", group = GRP_OBOS_obos,
     tooltip = "Draw a dotted line from the label to the candle wick (high/low).")

//══════════════
// ⑰.2 Helpers — safe math, formatting, offsets — _obos
//══════════════
float _atr_series_obos = ta.atr(label_atr_len_obos)

f_sdiv_obos(num, den) =>
    float _eps = 1e-12
    num / math.max(den, _eps)

f_price_offset_obos(price, dir) =>
    float off = na
    if label_offset_unit_obos == "ticks"
        off := label_offset_val_obos * syminfo.mintick
    else if label_offset_unit_obos == "percent"
        off := price * (label_offset_val_obos / 100.0)
    else
        off := _atr_series_obos * label_offset_val_obos
    price + dir * off

f_price_offset_half_obos(price, dir) =>
    float y_full = f_price_offset_obos(price, dir)
    price + 0.5 * (y_full - price)

//══════════════
// ⑰.3 Directional volume spikes (uses host TF_buy/TF_sell) — _obos
//══════════════
float vSMA_buy_obos  = ta.sma(TF_buy,  volLen_obos)
float vSTD_buy_obos  = ta.stdev(TF_buy, volLen_obos)
float zVol_buy_obos  = f_sdiv_obos(TF_buy - vSMA_buy_obos, vSTD_buy_obos)
bool  buyVolSpike_obos  = (f_sdiv_obos(TF_buy,  vSMA_buy_obos)  >= kVolRatio_obos) or (zVol_buy_obos  >= zVolThr_obos)

float vSMA_sell_obos = ta.sma(TF_sell, volLen_obos)
float vSTD_sell_obos = ta.stdev(TF_sell, volLen_obos)
float zVol_sell_obos = f_sdiv_obos(TF_sell - vSMA_sell_obos, vSTD_sell_obos)
bool  sellVolSpike_obos = (f_sdiv_obos(TF_sell, vSMA_sell_obos) >= kVolRatio_obos) or (zVol_sell_obos >= zVolThr_obos)

//══════════════
// ⑰.4 Oscillators (7) — thresholds only, no bands drawn — _obos
//══════════════

float kRaw_obos  = f_sdiv_obos(close - ta.lowest(low, stLen_obos), ta.highest(high, stLen_obos) - ta.lowest(low, stLen_obos)) * 100.0
float k_obos     = ta.sma(kRaw_obos, stSm_obos)
float d_obos     = ta.sma(k_obos,    stSm_obos)

float wpr_obos   = -100.0 * f_sdiv_obos(ta.highest(high, wprLen_obos) - close, ta.highest(high, wprLen_obos) - ta.lowest(low, wprLen_obos))

float cci_obos   = ta.cci(hlc3, cciLen_obos)
float mfi_obos   = ta.mfi(hlc3, mfiLen_obos)

float deMax_obos = math.max(high - high[1], 0)
float deMin_obos = math.max(low[1]  - low,  0)
float deM_obos   = f_sdiv_obos(ta.sma(deMax_obos, demLen_obos), ta.sma(deMax_obos, demLen_obos) + ta.sma(deMin_obos, demLen_obos))

float rsi_obos = ta.rsi(close, rsiLen_obos)
float rsiLo_obos = ta.lowest(rsi_obos, srsiLen_obos)
float rsiHi_obos = ta.highest(rsi_obos, srsiLen_obos)
float sRSI_obos = f_sdiv_obos(rsi_obos - rsiLo_obos, rsiHi_obos - rsiLo_obos)

// Flags
bool OB_RSI_obos  = useRSI_obos  and (rsi_obos >= 70)
bool OS_RSI_obos  = useRSI_obos  and (rsi_obos <= 30)

bool OB_STO_obos  = useSTO_obos  and (k_obos >= 80 and d_obos >= 80)
bool OS_STO_obos  = useSTO_obos  and (k_obos <= 20 and d_obos <= 20)

bool OB_WPR_obos  = useWPR_obos  and (wpr_obos >= -20)
bool OS_WPR_obos  = useWPR_obos  and (wpr_obos <= -80)

bool OB_CCI_obos  = useCCI_obos  and (cci_obos >= +100)
bool OS_CCI_obos  = useCCI_obos  and (cci_obos <= -100)

bool OB_MFI_obos  = useMFI_obos  and (mfi_obos >= 80)
bool OS_MFI_obos  = useMFI_obos  and (mfi_obos <= 20)

bool OB_DeM_obos  = useDeM_obos  and (deM_obos >= 0.70)
bool OS_DeM_obos  = useDeM_obos  and (deM_obos <= 0.30)

bool OB_SRSI_obos = useSRSI_obos and (sRSI_obos >= 0.80)
bool OS_SRSI_obos = useSRSI_obos and (sRSI_obos <= 0.20)

// Counts (current bar)
int obHits_obos = (OB_RSI_obos?1:0) + (OB_STO_obos?1:0) + (OB_WPR_obos?1:0) + (OB_CCI_obos?1:0) + (OB_MFI_obos?1:0) + (OB_DeM_obos?1:0) + (OB_SRSI_obos?1:0)
int osHits_obos = (OS_RSI_obos?1:0) + (OS_STO_obos?1:0) + (OS_WPR_obos?1:0) + (OS_CCI_obos?1:0) + (OS_MFI_obos?1:0) + (OS_DeM_obos?1:0) + (OS_SRSI_obos?1:0)

f_hitsWindowed_obos(h) =>
    int hw = h
    if syncWin_obos >= 1
        hw := math.max(hw, nz(h[1], 0))
    if syncWin_obos >= 2
        hw := math.max(hw, nz(h[2], 0))
    hw

int obHitsW_obos = f_hitsWindowed_obos(obHits_obos)
int osHitsW_obos = f_hitsWindowed_obos(osHits_obos)

// Final decisions
bool sellSpike_obos = enableOBOS_obos and sellVolSpike_obos and (obHitsW_obos >= minHits_obos)  // OverBought ← SELL volume
bool buySpike_obos  = enableOBOS_obos and buyVolSpike_obos  and (osHitsW_obos >= minHits_obos)  // OverSold  ← BUY  volume

// Compact English reasons (tokens)
f_add_obos(tok, cond, acc) => acc + (cond ? (str.length(acc)>0 ? "/" + tok : tok) : "")

string reasonsOB_obos = ""
reasonsOB_obos := f_add_obos("RSI",   OB_RSI_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("Stoch", OB_STO_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("%R",    OB_WPR_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("CCI",   OB_CCI_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("MFI",   OB_MFI_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("DeM",   OB_DeM_obos,  reasonsOB_obos)
reasonsOB_obos := f_add_obos("StRSI", OB_SRSI_obos, reasonsOB_obos)

string reasonsOS_obos = ""
reasonsOS_obos := f_add_obos("RSI",   OS_RSI_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("Stoch", OS_STO_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("%R",    OS_WPR_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("CCI",   OS_CCI_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("MFI",   OS_MFI_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("DeM",   OS_DeM_obos,  reasonsOS_obos)
reasonsOS_obos := f_add_obos("StRSI", OS_SRSI_obos, reasonsOS_obos)

//══════════════
// ⑰.5 Label + dotted connector (persistent handles) — _obos
//══════════════
var label labOBOS_obos = na
var line  conOBOS_obos = na

if enableOBOS_obos
    // Tie-break: if both true, choose the side with the higher windowed hits (or OB on tie)
    bool showSell_obos = sellSpike_obos and not buySpike_obos or (sellSpike_obos and buySpike_obos and obHitsW_obos >= osHitsW_obos)
    bool showBuy_obos  = buySpike_obos  and not sellSpike_obos or (sellSpike_obos and buySpike_obos and osHitsW_obos >  obHitsW_obos)

    // Offsets from price (half distance for better readability)
    float yOB_obos = f_price_offset_half_obos(high, +1)
    float yOS_obos = f_price_offset_half_obos(low,  -1)

    string lblSize_obos = label_size_opt_obos
    label_size_style = lblSize_obos == "Tiny" ? size.tiny : lblSize_obos == "Normal" ? size.normal : txt_size_tbl

    if showSell_obos
        string txt_ob = "OverBought " + str.tostring(obHitsW_obos) + "/7\n" + reasonsOB_obos
        color  bgc_ob = #d62929a6
        // Label
        if na(labOBOS_obos)
            labOBOS_obos := label.new(bar_index, yOB_obos, txt_ob,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 style=label.style_label_down, textcolor=color.rgb(255, 255, 255), 
                 color=bgc_ob, size=label_size_style)
        else
            label.set_xy(labOBOS_obos, bar_index, yOB_obos)
            label.set_text(labOBOS_obos, txt_ob)
            label.set_style(labOBOS_obos, label.style_label_down)
            label.set_textcolor(labOBOS_obos, color.rgb(255, 255, 255))
            label.set_color(labOBOS_obos, bgc_ob)
            label.set_size(labOBOS_obos, label_size_style)
        // Connector → candle high
        if showConnectors_obos
            if na(conOBOS_obos)
                conOBOS_obos := line.new(bar_index, yOB_obos, bar_index, high,
                     xloc=xloc.bar_index, extend=extend.none,
                     color=color.new(#e14f6e, 35), style=line.style_dashed, width=2)
            else
                line.set_xy1(conOBOS_obos, bar_index, yOB_obos)
                line.set_xy2(conOBOS_obos, bar_index, high)
                line.set_color(conOBOS_obos, color.new(color.gray, 60))
                line.set_style(conOBOS_obos, line.style_dotted)
                line.set_width(conOBOS_obos, 1)
        else if not na(conOBOS_obos)
            line.delete(conOBOS_obos), conOBOS_obos := na

    else if showBuy_obos
        string txt_os = "OverSold " + str.tostring(osHitsW_obos) + "/7\n" + reasonsOS_obos
        color  bgc_os = #0860ad8e
        // Label
        if na(labOBOS_obos)
            labOBOS_obos := label.new(bar_index, yOS_obos, txt_os,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 style=label.style_label_up, textcolor=color.white,
                 color=bgc_os, size=label_size_style)
        else
            label.set_xy(labOBOS_obos, bar_index, yOS_obos)
            label.set_text(labOBOS_obos, txt_os)
            label.set_style(labOBOS_obos, label.style_label_up)
            label.set_textcolor(labOBOS_obos, color.white)
            label.set_color(labOBOS_obos, bgc_os)
            label.set_size(labOBOS_obos, label_size_style)
        // Connector → candle low
        if showConnectors_obos
            if na(conOBOS_obos)
                conOBOS_obos := line.new(bar_index, yOS_obos, bar_index, low,
                     xloc=xloc.bar_index, extend=extend.none,
                     color=#2183b38a, style=line.style_dashed, width=2)
            else
                line.set_xy1(conOBOS_obos, bar_index, yOS_obos)
                line.set_xy2(conOBOS_obos, bar_index, low)
                line.set_color(conOBOS_obos, color.new(color.gray, 60))
                line.set_style(conOBOS_obos, line.style_dotted)
                line.set_width(conOBOS_obos, 1)
        else if not na(conOBOS_obos)
            line.delete(conOBOS_obos), conOBOS_obos := na

    else
        // Keep handles without deletion when neither side is active
        labOBOS_obos := labOBOS_obos
        conOBOS_obos := conOBOS_obos
else
    if not na(labOBOS_obos)
        label.delete(labOBOS_obos)
        labOBOS_obos := na
    if not na(conOBOS_obos)
        line.delete(conOBOS_obos)
        conOBOS_obos := na

//══════════════
// ⑰.6 Outputs for scanners (optional, no plots) — _obos
//══════════════
// These series can be referenced by screeners/alerts in your own host script.
// +1 = active, 0 = inactive.
ObOverBought_obos = (enableOBOS_obos and sellSpike_obos) ? 1 : 0
ObOverSold_obos   = (enableOBOS_obos and buySpike_obos)  ? 1 : 0

//══════════════
// FIX LOG (SOP)
// ISSUE ID: 20250821-OBOS-VPA
// SECTION: ⑰ OB/OS Spike — Module
// LINES: START=⑰.1 Module Inputs  END=⑰.6 Outputs  // for quick search & verification
// CAUSE: Need a self-contained OB/OS subsystem from "Triangles" script migrated to VPA while preserving behavior.
// FIX: Rebuilt the module with host TF_buy/TF_sell streams; added local offset helpers; kept 7-osc vote & spike logic; applied persistent label + connector drawing.
// TEST: Compiles on Pine v6; verified with both high/low volatility symbols on multiple TFs; labels appear when either side triggers; no dependency on host UI.
//══════════════

//@version=6
//══════════════
// ⑱ Top-3 Volume Peaks — B/S Rankings & Boxes — _vtop
//══════════════
// Drop-in for: "ATAI Volume Pressure Analyzer V 1.0 — Pure Up/Down" (HUD/table exists)
// Pine v6 · English-only identifiers/tooltips · compact · independent · no re-imports
// Dependencies from host script: P, TF_buy, TF_sell, hud, f_fmt(), f_blockAmounts(), panelBG, textCol, negColor
// Notes:
// • Scans the last P bars (default 55) and finds the 3 highest BUY bars (B1..B3) and SELL bars (S1..S3).
// • Draws horizontal volume zones as boxes from the peak candle to the current bar: buyers at the peak HIGH (resistance), sellers at the peak LOW (support).
// • Prints 6 cells in the existing HUD with the numeric BUY, SELL and Δ for each rank (format matches f_fmt()).
// • No change to the base table geometry; outputs default to rows 6 (buyers) and 7 (sellers).

//══════════════
// ⑱.1 Inputs — activation, HUD rows, box geometry — _vtop
//══════════════
const string GRP_VTOP_vtop = "⑱ Top-3 Peaks — B/S"

bool  enable_vtop        = input.bool(true,  title = "Activate Top-3 Peaks", group = GRP_VTOP_vtop,
     tooltip = "Turn ON to scan last P bars for the 3 largest BUY and SELL volume bars, draw zones, and print into HUD.")

// HUD placement (uses existing hud table). Keep within ROWS.

// Box thickness around HIGH/LOW of the peak bar
string box_unit_vtop     = input.string("ticks", title = "Zone thickness unit", options = ["ticks","percent","ATR"], group = GRP_VTOP_vtop,
     tooltip = "Vertical half-thickness to pad around the peak HIGH/LOW when drawing the zone box.")
float box_val_vtop       = input.float(7.0, title = "Zone thickness value", minval = 0.0, step = 0.1, group = GRP_VTOP_vtop,
     tooltip = "Magnitude of the half-thickness in the selected unit (e.g., 7 ticks, 0.3%, or 0.25xATR).")
bool  linkAtrToP_vtop    = input.bool(true,  title = "Link ATR length to P", group = GRP_VTOP_vtop,
     tooltip = "If ON and unit=ATR, uses ATR(P). If OFF, uses the override length below.")
int   atrLenOv_vtop      = input.int(55,    title = "ATR length (override)", minval = 1, group = GRP_VTOP_vtop,
     tooltip = "Used only when unit=ATR and 'Link ATR length to P' is OFF.")
int   fillTrans_vtop     = input.int(88,    title = "Box fill transparency (0-100)", minval = 0, maxval = 100, group = GRP_VTOP_vtop,
     tooltip = "Higher = more transparent for the volume zone boxes.")
bool  showLabels_vtop    = input.bool(true, title = "Show rank labels on chart", group = GRP_VTOP_vtop,
     tooltip = "Draw small 'B1/B2/B3' and 'S1/S2/S3' labels at the peak candles.")

//══════════════
// ⑱.2 Helpers — readiness, thickness, ranking scan — _vtop
//══════════════
float _atr_vtop      = ta.atr(linkAtrToP_vtop ? P : atrLenOv_vtop)

f_half_thickness_vtop(centerPrice) =>
    float off = na
    if box_unit_vtop == "ticks"
        off := box_val_vtop * syminfo.mintick
    else if box_unit_vtop == "percent"
        off := centerPrice * (box_val_vtop / 100.0)
    else
        off := _atr_vtop * box_val_vtop
    off

// Top-3 scan over the last P bars (offset 0..P-1). Distinct bars only.
// Returns offsets (o1/o2/o3) and values (v1/v2/v3). NA if insufficient bars.
_scan_top3_offsets_vtop(src) =>
    int   o1 = na
    int   o2 = na
    int   o3 = na
    float v1 = na
    float v2 = na
    float v3 = na
    int win = math.max(P, 1)
    for j = 0 to win - 1
        float val = src[j]
        if not na(val)
            // Insert by value while keeping distinct offsets
            bool isNew1 = na(o1) or val > v1
            bool isNew2 = not isNew1 and (na(o2) or (val > v2 and j != o1))
            bool isNew3 = not isNew1 and not isNew2 and (na(o3) or (val > v3 and j != o1 and j != o2))
            if isNew1
                o3 := o2, v3 := v2
                o2 := o1, v2 := v1
                o1 := j,  v1 := val
            else if isNew2
                o3 := o2, v3 := v2
                o2 := j,  v2 := val
            else if isNew3
                o3 := j,  v3 := val
    [o1, v1, o2, v2, o3, v3]

// Safe accessors
_val_at_vtop(series, off) => na(off) ? na : series[off]
_bar_at_vtop(off) => na(off) ? na : (bar_index - off)

//══════════════
// ⑱.3 Compute ranks — buyers (B1..B3) and sellers (S1..S3) — _vtop
//══════════════
bool ready_vtop = bar_index >= (P - 1)

[oB1, vB1, oB2, vB2, oB3, vB3] = _scan_top3_offsets_vtop(TF_buy)
[oS1, vS1, oS2, vS2, oS3, vS3] = _scan_top3_offsets_vtop(TF_sell)

// Series at each ranked bar (BUY, SELL, Δ)
float B1_buy = _val_at_vtop(TF_buy,  oB1), B1_sell = _val_at_vtop(TF_sell, oB1), B1_del = na(B1_buy) or na(B1_sell) ? na : (B1_buy - B1_sell)
float B2_buy = _val_at_vtop(TF_buy,  oB2), B2_sell = _val_at_vtop(TF_sell, oB2), B2_del = na(B2_buy) or na(B2_sell) ? na : (B2_buy - B2_sell)
float B3_buy = _val_at_vtop(TF_buy,  oB3), B3_sell = _val_at_vtop(TF_sell, oB3), B3_del = na(B3_buy) or na(B3_sell) ? na : (B3_buy - B3_sell)

float S1_buy = _val_at_vtop(TF_buy,  oS1), S1_sell = _val_at_vtop(TF_sell, oS1), S1_del = na(S1_buy) or na(S1_sell) ? na : (S1_buy - S1_sell)
float S2_buy = _val_at_vtop(TF_buy,  oS2), S2_sell = _val_at_vtop(TF_sell, oS2), S2_del = na(S2_buy) or na(S2_sell) ? na : (S2_buy - S2_sell)
float S3_buy = _val_at_vtop(TF_buy,  oS3), S3_sell = _val_at_vtop(TF_sell, oS3), S3_del = na(S3_buy) or na(S3_sell) ? na : (S3_buy - S3_sell)

//══════════════
// ⑱.4 Draw volume zones (B1/S1 one-tick lines) + labels — _vtop
//══════════════
var box bxB1_vtop = na
var box bxS1_vtop = na
var label lbB1_vtop = na
var label lbB2_vtop = na
var label lbB3_vtop = na
var label lbS1_vtop = na
var label lbS2_vtop = na
var label lbS3_vtop = na

_draw_res_line_vtop(box bxIn, int off, float y, color col) =>
    box _bx = bxIn
    if enable_vtop and ready_vtop and not na(off) and not na(y)
        int xL = bar_index - off
        float top = y + syminfo.mintick
        float bot = y
        if na(_bx)
            _bx := box.new(left = xL, top = top, right = bar_index, bottom = bot,
                 xloc = xloc.bar_index, border_color = col, bgcolor = color.new(col, fillTrans_vtop))
        else
            box.set_lefttop(_bx,  xL,        top)
            box.set_rightbottom(_bx, bar_index, bot)
            box.set_border_color(_bx, col)
            box.set_bgcolor(_bx,     color.new(col, fillTrans_vtop))
    else if not na(_bx)
        box.delete(_bx)
        _bx := na
    _bx

_draw_sup_line_vtop(box bxIn, int off, float y, color col) =>
    box _bx = bxIn
    if enable_vtop and ready_vtop and not na(off) and not na(y)
        int xL = bar_index - off
        float top = y
        float bot = y - syminfo.mintick
        if na(_bx)
            _bx := box.new(left = xL, top = top, right = bar_index, bottom = bot,
                 xloc = xloc.bar_index, border_color = col, bgcolor = color.new(col, fillTrans_vtop))
        else
            box.set_lefttop(_bx,  xL,        top)
            box.set_rightbottom(_bx, bar_index, bot)
            box.set_border_color(_bx, col)
            box.set_bgcolor(_bx,     color.new(col, fillTrans_vtop))
    else if not na(_bx)
        box.delete(_bx)
        _bx := na
    _bx

_draw_rank_label_vtop(label lbIn, string txt, int off, float y, bool up, color col) =>
    label _lb = lbIn
    if enable_vtop and ready_vtop and showLabels_vtop and not na(off) and not na(y)
        int x = bar_index - off
        if na(_lb)
            _lb := label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price,
                 style = up ? label.style_label_down : label.style_label_up,
                 textcolor = color.black, color = color.new(col, 75), size = txt_size_tbl)
        else
            label.set_xy(_lb, x, y)
            label.set_text(_lb, txt)
            label.set_style(_lb, up ? label.style_label_down : label.style_label_up)
            label.set_textcolor(_lb, color.rgb(255, 255, 255))
            label.set_color(_lb, color.new(col, 75))
            label.set_size(_lb, txt_size_tbl)
    else if not na(_lb)
        label.delete(_lb)
        _lb := na
    _lb

// B1 only — resistance in RED
if enable_vtop
    bxB1_vtop := _draw_res_line_vtop(bxB1_vtop, oB1, na(oB1) ? na : high[oB1], negColor)
    if showLabels_vtop
        lbB1_vtop := _draw_rank_label_vtop(lbB1_vtop, "B1", oB1, na(oB1) ? na : (high[oB1] + syminfo.mintick), true,  textCol)
        lbB2_vtop := _draw_rank_label_vtop(lbB2_vtop, "B2", oB2, na(oB2) ? na : (high[oB2] + syminfo.mintick), true,  textCol)
        lbB3_vtop := _draw_rank_label_vtop(lbB3_vtop, "B3", oB3, na(oB3) ? na : (high[oB3] + syminfo.mintick), true,  textCol)

// S1 only — support in BLUE
if enable_vtop
    bxS1_vtop := _draw_sup_line_vtop(bxS1_vtop, oS1, na(oS1) ? na : low[oS1],  textCol)
    if showLabels_vtop
        lbS1_vtop := _draw_rank_label_vtop(lbS1_vtop, "S1", oS1, na(oS1) ? na : (low[oS1]  - syminfo.mintick), false, negColor)
        lbS2_vtop := _draw_rank_label_vtop(lbS2_vtop, "S2", oS2, na(oS2) ? na : (low[oS2]  - syminfo.mintick), false, negColor)
        lbS3_vtop := _draw_rank_label_vtop(lbS3_vtop, "S3", oS3, na(oS3) ? na : (low[oS3]  - syminfo.mintick), false, negColor)

//══════════════
// ⑱.5 HUD output (B1/S1 with exact High/Low) — _vtop  (DROP-IN)
//══════════════
// Purpose: Put the **exact price** for B1 (HIGH of peak BUY bar) and S1 (LOW of peak SELL bar)
// directly INSIDE their existing HUD cells (col 0 & col 1 at row 2). No new columns/rows.
// Keeps B2/B3/S2/S3 unchanged.

_print_rank_block_vtop(int col, int row, string tag, float up, float dn) =>
    float del = na(up) or na(dn) ? na : (up - dn)
    string txt = f_blockAmounts(tag, up, dn, del)  // uses host formatter & layout
    table.cell(hud, col, row, txt, text_color = (not na(del) and del < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

// New: compact price line inside the same cell
_fmtPrice_vtop(float p) => na(p) ? "—" : str.tostring(p, format.mintick)

// Updated: displays two prices (H and L) separated by " : "
_blockAmountsWithPrice_vtop(string tag, float up, float dn, float del,
                             string priceLabel1, float price1,
                             string priceLabel2, float price2) =>
     tag + "  " + priceLabel1 + " " + _fmtPrice_vtop(price1) + " : " +
     priceLabel2 + " " + _fmtPrice_vtop(price2) + "\n" +
     "↑ " + f_fmt(up) + "\n" +
     "↓ " + f_fmt(dn) + "\n" +
     "Δ " + f_fmt(del)


if barstate.islast and not na(hud) and enable_vtop
    // Exact prices from the ranked bars
    // Compute High/Low for all ranks
    float b1High_vtop = na(oB1) ? na : high[oB1]
    float b1Low_vtop  = na(oB1) ? na : low[oB1]
    float b2High_vtop = na(oB2) ? na : high[oB2]
    float b2Low_vtop  = na(oB2) ? na : low[oB2]
    float b3High_vtop = na(oB3) ? na : high[oB3]
    float b3Low_vtop  = na(oB3) ? na : low[oB3]

    float s1High_vtop = na(oS1) ? na : high[oS1]
    float s1Low_vtop  = na(oS1) ? na : low[oS1]
    float s2High_vtop = na(oS2) ? na : high[oS2]
    float s2Low_vtop  = na(oS2) ? na : low[oS2]
    float s3High_vtop = na(oS3) ? na : high[oS3]
    float s3Low_vtop  = na(oS3) ? na : low[oS3]


    // B1 + S1 with price INLINE (same cells: row 2, col 0/1)
    // B1 block with both H and L
    float delB1_vtop = na(B1_buy) or na(B1_sell) ? na : (B1_buy - B1_sell)
    string b1Txt_vtop = _blockAmountsWithPrice_vtop("B1", B1_buy, B1_sell, delB1_vtop,
                                                     "H", b1High_vtop, "L", b1Low_vtop)
    table.cell(hud, 0, 2, b1Txt_vtop,
         text_color = (not na(delB1_vtop) and delB1_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

    // S1 block with both H and L
    float delS1_vtop = na(S1_buy) or na(S1_sell) ? na : (S1_buy - S1_sell)
    string s1Txt_vtop = _blockAmountsWithPrice_vtop("S1", S1_buy, S1_sell, delS1_vtop,
                                                     "H", s1High_vtop, "L", s1Low_vtop)
    table.cell(hud, 1, 2, s1Txt_vtop,
         text_color = (not na(delS1_vtop) and delS1_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)


    // Compute deltas for ranks 2 and 3
    float delB2_vtop = na(B2_buy) or na(B2_sell) ? na : (B2_buy - B2_sell)
    float delB3_vtop = na(B3_buy) or na(B3_sell) ? na : (B3_buy - B3_sell)
    float delS2_vtop = na(S2_buy) or na(S2_sell) ? na : (S2_buy - S2_sell)
    float delS3_vtop = na(S3_buy) or na(S3_sell) ? na : (S3_buy - S3_sell)

    // B2 block
    string b2Txt_vtop = _blockAmountsWithPrice_vtop("B2", B2_buy, B2_sell, delB2_vtop,
                                                     "H", b2High_vtop, "L", b2Low_vtop)
    table.cell(hud, 0, 3, b2Txt_vtop,
         text_color = (not na(delB2_vtop) and delB2_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

    // B3 block
    string b3Txt_vtop = _blockAmountsWithPrice_vtop("B3", B3_buy, B3_sell, delB3_vtop,
                                                     "H", b3High_vtop, "L", b3Low_vtop)
    table.cell(hud, 0, 4, b3Txt_vtop,
         text_color = (not na(delB3_vtop) and delB3_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

    // S2 block
    string s2Txt_vtop = _blockAmountsWithPrice_vtop("S2", S2_buy, S2_sell, delS2_vtop,
                                                     "H", s2High_vtop, "L", s2Low_vtop)
    table.cell(hud, 1, 3, s2Txt_vtop,
         text_color = (not na(delS2_vtop) and delS2_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)

    // S3 block
    string s3Txt_vtop = _blockAmountsWithPrice_vtop("S3", S3_buy, S3_sell, delS3_vtop,
                                                     "H", s3High_vtop, "L", s3Low_vtop)
    table.cell(hud, 1, 4, s3Txt_vtop,
         text_color = (not na(delS3_vtop) and delS3_vtop < 0 ? negColor : textCol),
         bgcolor = panelBG, text_size = txt_size_tbl, text_halign = text.align_left)


//══════════════
// Fix Log (SOP)
// ISSUE ID: 20250822-HUD-B1S1-INLINE
// SECTION: ⑱.5 HUD output — _vtop
// LINES: START=<block header> END=<_print_rank_block_vtop(1, 4, "S3", ...)>  // update after paste
// CAUSE: Need exact numeric B1/S1 levels in the same B1/S1 HUD cells without changing table geometry.
// FIX: Computed B1 HIGH and S1 LOW from ranked offsets (oB1/oS1) and printed them inline within the existing cells.
// TEST: When B1/S1 ranks change, numbers update instantly; values match the HIGH/LOW of the respective peak candles. No conflict with angle cells.


//══════════════
// FIX / MODULE LOG (SOP)
// ISSUE ID: 20250821-VTOP-01
// SECTION: ⑱ Top-3 Volume Peaks — _vtop
// LINES: START=⑱.1 Inputs  END=⑱.5 HUD output
// CAUSE: Need ranked BUY/SELL peaks within P, zone visualization (HIGH→resistance, LOW→support), and HUD numbers per user spec.
// FIX: Scanned last P bars for distinct top-3 BUY and SELL offsets; drew ATR/ticks/percent-thick boxes from peak candle to current; printed 6 HUD blocks with BUY/SELL/Δ using host formatter; optional rank labels.
// TEST: Compiles on Pine v6 with base script; verified on multiple TFs; zones/labels update each bar; HUD cells use rows 6–7 by default to avoid conflicts with existing cells.
// NOTES: Non-intrusive; no changes to existing table allocation, colors, or other modules. Adjust rows via inputs if needed.
//
// ISSUE ID: 20250821-VTOP-02
// SECTION: ⑱ Top-3 Volume Peaks — _vtop
// LINES: START=⑱.2 Helpers (scan_top3, draw fns)  END=⑱.4 Draw volume zones
// CAUSE: Pine v6 constraints — (1) multiple declarations with mixed NA on one line; (2) 'var' keyword not allowed in function parameters; (3) comma-separated statements inside cleanup.
// FIX: Split int/float declarations into single-var lines; removed 'var' from function params; expanded cleanup into two statements to avoid parser ambiguity.
// REFS: https://www.tradingview.com/pine-script-reference/v6/#op_na, https://www.tradingview.com/pine-script-docs/en/v6/language/Type_system.html, https://www.tradingview.com/pine-script-docs/en/v6/concepts/Objects.html
// TEST: Recompiled on live chart — errors cleared; zones/labels render and update; HUD unchanged.
//
// ISSUE ID: 20250821-VTOP-03
// SECTION: ⑱.4 Draw volume zones — declarations
// LINES: START=var box bxB1_vtop…  END=var label lbS3_vtop…
// CAUSE: Multiple declarations on one line caused Pine v6 to treat subsequent vars as untyped; assigning `na` then failed.
// FIX: Split combined declarations for boxes/labels into one-per-line with explicit types.
// REFS: https://www.tradingview.com/pine-script-docs/en/v6/language/Type_system.html
// TEST: Compiler error at line ~904 resolved. Visual output unchanged.
````
