<!-- tradingview-pine-id: PUB;bc3433f6aabb466686c93613a18b4c46 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Implied Market Structure

Source: https://www.tradingview.com/script/sMhnCi0K-Implied-Market-Structure/

## Description

You have seen the day. The S&P 500 closes green, the financial press calls it a rally, and half the names in a typical portfolio did not participate. Or the index is flat while a handful of stocks you actually own move several percent. The cash print of SPX is a weighted average. It can look healthy while the market underneath is narrow, and it can look dull while single names are already running. Breadth indicators catch that after the close, once advancing issues and new highs have printed. The options market is already quoting a related question, because index options and single-stock options together imply how much the constituents are expected to move, and how much they are expected to move together, over the next month. That is not the same as knowing what realised breadth will do next week. It is a reading of the surface that is being priced now.

Implied Market Structure is that reading, turned into a pane. It does not look at the price of the chart you dropped it on. It reads three Cboe indices that already live on TradingView (DSPX, COR3M, VIXEQ) and maps them into an options-derived forward-looking market structure: what kind of tape the listed surface is paying for. Direction still comes from your own setup. This script answers how that setup should be expressed, whether as an index overlay, a single-stock book, a hedge, or a smaller size. Open a daily SPX, ES or SPY chart, add the script, and read the dashboard before you argue with the line.

What you are looking at, from the pane outward. The thick line is the IMS score on a 0 to 10 scale, a one-dimensional summary of two ranks: high DSPX percentile plus low COR3M percentile. Near 10 the surface is paying for stock-level divergence. Near 0 it is paying for a herd. The line is green at or above 7.5, red at or below 2.5, and blue in between. Those two horizontal marks are not regime thresholds. They are score tails. The faint grey line at 5 is the midpoint of the summary, nothing more. The thinner, smoother line is a 21-day EMA of the same score, updated on daily changes. If it has fallen by at least 0.20 over five days the dashboard says FALLING; the opposite move is RISING; anything smaller is FLAT, so a one-tick wriggle does not rename the trend. The shaded band between 2.5 and 7.5 is only a mid-score fill. Optional grey bands around the line, off by default, are a 21-day standard deviation of the score, not a forecast interval. Two further optional lines, also off by default, plot the DSPX rank and the inverse COR3M rank on the same 0 to 10 scale when you want to see which factor is doing the work. Background colour, in the default Position mode, follows the two-dimensional regime rather than the score, so a mid-range line can still sit in a blue COMPRESSED patch. Dynamic mode instead tints the pane by the 0 to 10 reading. Off leaves the pane unshaded.

The same regime colours the candles, or the price line if you are not on candlesticks. Green is STOCK PICKING. Red is INDEX TAPE or BROAD STRESS, with tape drawn a little more faded than stress. Blue is COMPRESSED. MIXED is a weaker blue. That colour is a weather reminder. It is not a long or a short in ES or SPX.

The table at the top right is the actual reading, row by row. IMS score is the 0 to 10 summary, printed to two decimals, with confirmed D or live D on the right. Confirmed D, the default, uses the last completed daily Cboe print, so the last bar on a daily chart is yesterday’s structure and does not wander with the developing session. Live D uses the current daily close and can flip while cash is open. Regime is the two-dimensional class: INDEX TAPE, STOCK PICKING, BROAD STRESS, COMPRESSED or MIXED. INDEX TAPE is high implied correlation and low expected dispersion, the index treated as one factor, which is when ES and SPY trades and index puts are the more natural tools and single-stock selection is swimming against a herd. STOCK PICKING is the opposite corner, high dispersion and low correlation, which is Cboe’s stated use of DSPX as a read on the opportunity set for names (Cboe, n.d.a), not a long signal in the index. BROAD STRESS is both high, movement with togetherness, when reducing size and using index hedges tends to hurt less than hunting for the one name that will decouple. COMPRESSED is both low, quiet on both axes. MIXED means at least one series is still in the middle, so you leave IMS in the background. Why restates the corner in words, DSPX HIGH, MID or LOW and COR3M the same, which is the reason the regime is what it is. A score of 5.4 with both factors LOW is still COMPRESSED. The line looks mid because low dispersion and low correlation pull the summary in opposite directions. That is why the table exists.

DSPX shows the raw Cboe dispersion level, then the trailing percentile in parentheses, then HIGH, MID or LOW. Green on that row is high dispersion. Red is low dispersion, the herd side of that axis, even when the regime as a whole is the quieter blue of COMPRESSED. COR3M shows the raw implied-correlation level the same way. Green there is low correlation, the picking side. Red is high correlation, the tape side. The percentiles in those rows are rounded to whole numbers. The score above them uses the unrounded ranks, so 25p and 18p can sit next to 5.4 without a contradiction. Vol overlay is VIXEQ’s percentile, labelled ELEVATED at or above 70, SUBDUED at or below 40, otherwise NORMAL, with the word overlay on the row so it is not mistaken for a third term in the score. VIXEQ does not enter the 0 to 10 line and does not move the regime. You can hold STOCK PICKING and still see constituent implied volatility elevated. The first fact is structure. The second is the vol climate around it. Trend is the EMA slope already described. Status is ACTIVE once DSPX and COR3M both have a rank, and WARMING UP until the lookback fills. If a feed is late the score stays blank rather than collapsing toward zero.

The grid under those rows is the same two-dimensional plane drawn as a table. Rows are DSPX, high at the top, low at the bottom. Columns are COR3M, low on the left, high on the right. PICK is high dispersion with low correlation. STRESS is both high. COMP is both low. TAPE is low dispersion with high correlation. MIXED sits in the centre, and the dotted cells are the mixed edges where only one factor has left the middle. The highlighted cell is the current corner. The footer under the grid says score = summary and matrix = 2D grid, which is the whole design in six words: the line compresses two ranks, the grid keeps them apart.

The small block at the bottom right of the pane is the watermark, the same facts for screenshots: ticker and timeframe, the score, the regime with the Why line, and confirmed daily or live daily. Colour across every theme keeps the same jobs. Green is high dispersion, low correlation, stock picking, subdued VIXEQ. Red is high correlation, index tape, broad stress, elevated VIXEQ. Blue, the primary colour of the theme, is compressed or mid. The eight themes only change the paint, not the meaning.

Cboe built DSPX to measure expected 30-day dispersion in the S&P 500 from index options and from selected single-stock options (Cboe Global Markets and S&P Dow Jones Indices, 2023; Cboe, n.d.a). COR3M is the ATM constant-maturity estimate of average correlation among the top 50 names (Cboe, n.d.b). VIXEQ is the cap-weighted 30-day implied volatility of that same basket, published as a DSPX component and scheduled for live calculation in November 2024 (Cboe Global Markets and S&P Dow Jones Indices, 2024). IMS does not rebuild those formulas. It ranks the published daily closes over a trailing window of daily prints, default 252 sessions, inside the daily request, so the lookback remains 252 daily observations on an hourly chart as well as on a daily chart. The ranks are smoothed with a short daily EMA. High and low for the corners enter at the 60th and 40th percentiles and, with hysteresis on, leave only after 55 and 45, which stops a one-percentile wobble from renaming the tape. Daily is the timeframe this was written for. Trend and bands follow daily changes on the host chart, so they are exact on a daily pane and only as fine as the host timeframe on a weekly one.

Alerts fire on a confirmed bar for the step from one regime into another, including MIXED -> STOCK PICKING, for leaving a corner, for the score crossing 7.5 or 2.5, for a turn in the daily EMA slope, and for VIXEQ first reaching the elevated overlay band. Wire them to a notification, not to an order. The script will not tell you whether SPX is going up, and it does not claim to forecast next week’s realised breadth. It tells you, each morning, whether the listed options surface is treating the next month as a crowd or as 500 separate stories.

DSPX has been live since 27 September 2023. VIXEQ’s live window is shorter, so its percentile can stay blank until the lookback fills. The ranks are relative to that window, not to a decade of history. No return forecast is claimed, and Cboe, S&P DJI and VIX remain trademarks of their owners.

References

Cboe (n.d.a) Cboe S&P 500 Dispersion Index. Available at: https://www.cboe.com/us/indices/dispersion/ 

Cboe (n.d.b) Implied Correlation. Available at: https://www.cboe.com/us/indices/implied/ 

Cboe Global Markets and S&P Dow Jones Indices (2023) S&P Dow Jones Indices and Cboe Global Markets to Launch the Cboe S&P 500 Dispersion Index. Available at: https://www.prnewswire.com/news-releases/sp-dow-jones-indices-and-cboe-global-markets-to-launch-the-cboe-sp-500-dispersion-index-301937523.html 

Cboe Global Markets and S&P Dow Jones Indices (2024) Cboe Global Markets and S&P Dow Jones Indices Plan to Launch New Cboe S&P 500 Constituent Volatility Index (VIXEQ). Available at: https://www.prnewswire.com/news-releases/cboe-global-markets-and-sp-dow-jones-indices-plan-to-launch-new-cboe-sp-500-constituent-volatility-index-vixeq-302279208.html

---

## Source Code

````pine
//@version=6
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// (c) EdgeTools
//
// Implied Market Structure (IMS)
// Options-derived SPX market structure. Not a breadth forecast.
// DSPX and COR3M ranks are computed on the daily series inside request.security,
// so a 252 lookback is 252 daily prints on any chart timeframe.
// Default data is the last completed daily bar (no intraday regime flip).
// Score (0-10) is a 1D summary: 0.05 * (DSPX pct + (100 - COR3M pct)).
// Regime is the 2D corner of DSPX vs COR3M with hysteresis (enter 60/40, leave 55/45).
// VIXEQ is a vol overlay only. It does not enter the score.

indicator("Implied Market Structure", shorttitle="IMS", overlay=false,
     max_bars_back=5000, max_lines_count=500)

hi_in  = 60.0
hi_out = 55.0
lo_in  = 40.0
lo_out = 45.0
veq_hot_lvl = 70.0
tape_line = 2.5
pick_line = 7.5
ema_len   = 21

i_conf = input.bool(true, "Confirmed Daily Bars", group="Data",
     tooltip="On: last completed daily print. Regime and alerts do not move with the developing session. Off: current daily close, can flip intraday.")
i_lb = input.int(252, "Percentile Lookback (days)", minval=63, maxval=504, group="Data",
     tooltip="Daily observations, independent of the chart timeframe.")
i_smooth = input.int(5, "Rank Smoothing (days)", minval=1, maxval=21, group="Data",
     tooltip="EMA of the daily percentile, computed on the daily series.")
i_hyst = input.bool(true, "Regime Hysteresis", group="Data",
     tooltip="High starts at 60 and holds until 55. Low starts at 40 and holds until 45.")
i_band = input.int(21, "Band Lookback (days)", minval=10, maxval=126, group="Data",
     tooltip="Daily stdev window for the optional bands. Separate from rank smoothing.")
i_tr_n = input.int(5, "Trend Span (days)", minval=2, maxval=21, group="Data")
i_tr_min = input.float(0.20, "Trend Min Move", minval=0.05, maxval=1.0, step=0.05, group="Data",
     tooltip="IMS-EMA must move at least this much over the trend span before RISING/FALLING.")

i_zones   = input.bool(true, "Show Score Zones", group="Display")
i_trend   = input.bool(true, "Show Trend Line", group="Display")
i_bands   = input.bool(false, "Show Bands", group="Display")
i_dspx_ln = input.bool(false, "Show DSPX Rank", group="Display")
i_cor_ln  = input.bool(false, "Show Inverse COR3M Rank", group="Display")
i_matrix  = input.bool(true, "Show DSPX/COR Matrix", group="Display")
i_bg_mode = input.string("Position", "Background Mode",
     options=["Off", "Position", "Dynamic"], group="Display",
     tooltip="Position = 2D regime. Dynamic = 0-10 score.")
i_bg_int  = input.int(85, "Background Intensity", minval=70, maxval=95, step=5, group="Display")

i_candles   = input.bool(true, "Color Candles", group="Candle Coloring")
i_candle_tr = input.int(20, "Base Transparency", minval=0, maxval=60, step=5, group="Candle Coloring")

i_dash     = input.bool(true, "Show Dashboard", group="Dashboard")
i_dash_pos = input.string("Top Right", "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"], group="Dashboard")
i_dash_sz  = input.string("Normal", "Size", options=["Tiny", "Small", "Normal", "Large"], group="Dashboard")

i_wm     = input.bool(true, "Show Watermark", group="Watermark")
i_wm_pos = input.string("Bottom Right", "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"], group="Watermark")
i_wm_sz  = input.string("Large", "Size", options=["Small", "Normal", "Large", "Huge"], group="Watermark")

i_theme = input.string("EdgeTools", "Color Theme",
     options=["EdgeTools", "Gold", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"], group="Appearance")
i_dark  = input.bool(true, "Dark Mode", group="Appearance")
i_width = input.int(2, "Main Line Width", minval=1, maxval=5, group="Appearance")
i_glow  = input.bool(false, "Glow Effect", group="Appearance")

i_alerts = input.bool(false, "Enable Transition Alerts", group="Alerts",
     tooltip="Dynamic alert: previous regime -> new regime. alertcondition entries are always listed in the TradingView dialog.")

// green: high dispersion / low correlation / stock picking
// red:   high correlation / index tape / broad stress / elevated VIXEQ
// blue:  compressed / mid
var color primary_color = na
var color bullish_color = na
var color bearish_color = na
var color neutral_color = na
var color text_color    = na
var color table_bg      = na
var color header_bg     = na

switch i_theme
    "EdgeTools" =>
        primary_color := i_dark ? #3b82f6 : #2563eb
        bullish_color := i_dark ? #22c55e : #16a34a
        bearish_color := i_dark ? #ef4444 : #dc2626
        neutral_color := i_dark ? #737373 : #525252
        text_color    := i_dark ? #fafafa : #0a0a0a
        table_bg      := i_dark ? #171717 : #f9f9f9
        header_bg     := i_dark ? #262626 : #e5e5e5
    "Gold" =>
        primary_color := i_dark ? #FFD700 : #DAA520
        bullish_color := i_dark ? #FFA500 : #FF8C00
        bearish_color := i_dark ? #FF5252 : #D32F2F
        neutral_color := i_dark ? #C0C0C0 : #808080
        text_color    := i_dark ? color.white : color.black
        table_bg      := i_dark ? #1A1A00 : #FFFEF0
        header_bg     := i_dark ? #2D2600 : #F5F5DC
    "Behavioral" =>
        primary_color := #808080
        bullish_color := #00FF00
        bearish_color := #8B0000
        neutral_color := #FFBF00
        text_color    := i_dark ? color.white : color.black
        table_bg      := i_dark ? #1A1A1A : #F8F8F8
        header_bg     := i_dark ? #2D2D2D : #E8E8E8
    "Quant" =>
        primary_color := #808080
        bullish_color := #FFA500
        bearish_color := #8B0000
        neutral_color := #4682B4
        text_color    := i_dark ? color.white : color.black
        table_bg      := i_dark ? #0D0D0D : #FAFAFA
        header_bg     := i_dark ? #1A1A1A : #F0F0F0
    "Ocean" =>
        primary_color := i_dark ? #20B2AA : #008B8B
        bullish_color := i_dark ? #00CED1 : #4682B4
        bearish_color := i_dark ? #FF4500 : #B22222
        neutral_color := i_dark ? #87CEEB : #2F4F4F
        text_color    := i_dark ? #F0F8FF : #191970
        table_bg      := i_dark ? #001A2E : #E6F7FF
        header_bg     := i_dark ? #002A47 : #CCF2FF
    "Fire" =>
        primary_color := i_dark ? #FF6347 : #DC143C
        bullish_color := i_dark ? #FFD700 : #FF8C00
        bearish_color := i_dark ? #8B0000 : #800000
        neutral_color := i_dark ? #FFA500 : #CD853F
        text_color    := i_dark ? #FFFAF0 : #2F1B14
        table_bg      := i_dark ? #261611 : #FFF8F0
        header_bg     := i_dark ? #3D241A : #FFE4CC
    "Matrix" =>
        primary_color := i_dark ? #00FF41 : #006400
        bullish_color := i_dark ? #39FF14 : #228B22
        bearish_color := i_dark ? #FF073A : #8B0000
        neutral_color := i_dark ? #00FFFF : #008B8B
        text_color    := i_dark ? #C0FF8C : #003300
        table_bg      := i_dark ? #0A1A0A : #E8FFF0
        header_bg     := i_dark ? #112B11 : #CCFFCC
    "Arctic" =>
        primary_color := i_dark ? #87CEFA : #4169E1
        bullish_color := i_dark ? #00BFFF : #0000CD
        bearish_color := i_dark ? #FF1493 : #8B008B
        neutral_color := i_dark ? #B0E0E6 : #483D8B
        text_color    := i_dark ? #F8F8FF : #191970
        table_bg      := i_dark ? #141B47 : #F0F8FF
        header_bg     := i_dark ? #1E2A5C : #E0F0FF

zone_tr  = i_dark ? 90 : 95
band_tr  = i_dark ? 70 : 85
table_tr = i_dark ? 80 : 15

f_pos(pos_string) =>
    switch pos_string
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

f_sz(size_string) =>
    switch size_string
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_px(simple bool conf) =>
    conf ? close[1] : close

f_rk(simple int len, simple int sm, simple bool conf) =>
    float rk = ta.ema(ta.percentrank(close, len), sm)
    conf ? rk[1] : rk

f_hyst(int prev, float pct, float e_hi, float x_hi, float e_lo, float x_lo) =>
    int st = prev
    if na(pct)
        st := prev
    else if prev == 1
        if pct < x_hi
            st := pct <= e_lo ? -1 : 0
    else if prev == -1
        if pct > x_lo
            st := pct >= e_hi ? 1 : 0
    else
        if pct >= e_hi
            st := 1
        else if pct <= e_lo
            st := -1
    st

f_lab(int st) =>
    st == 1 ? "HIGH" : st == -1 ? "LOW" : "MID"

f_lvl(float raw, float pct, int st) =>
    na(raw) ? "n/a" : str.tostring(raw, "#.00") + (na(pct) ? "" : "  (" + str.tostring(pct, "#") + "p)  " + f_lab(st))

dspx     = request.security("CBOE:DSPX", "D", f_px(i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
dspx_pct = request.security("CBOE:DSPX", "D", f_rk(i_lb, i_smooth, i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
cor3m    = request.security("CBOE:COR3M", "D", f_px(i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
cor_pct  = request.security("CBOE:COR3M", "D", f_rk(i_lb, i_smooth, i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
vixeq    = request.security("CBOE:VIXEQ", "D", f_px(i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
veq_pct  = request.security("CBOE:VIXEQ", "D", f_rk(i_lb, i_smooth, i_conf), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

ready = not na(dspx_pct) and not na(cor_pct)
ims   = ready ? 0.05 * (dspx_pct + (100.0 - cor_pct)) : na

x_hi = i_hyst ? hi_out : hi_in
x_lo = i_hyst ? lo_out : lo_in

new_d = timeframe.change("D")
var int dspx_st = 0
var int cor_st  = 0
if not i_conf or new_d or barstate.isfirst
    dspx_st := f_hyst(dspx_st, dspx_pct, hi_in, x_hi, lo_in, x_lo)
    cor_st  := f_hyst(cor_st, cor_pct, hi_in, x_hi, lo_in, x_lo)

tape    = ready and cor_st == 1 and dspx_st == -1
picking = ready and cor_st == -1 and dspx_st == 1
stress  = ready and cor_st == 1 and dspx_st == 1
quiet   = ready and cor_st == -1 and dspx_st == -1

zone_str = not ready ? "NO DATA" : tape ? "INDEX TAPE" : picking ? "STOCK PICKING" : stress ? "BROAD STRESS" : quiet ? "COMPRESSED" : "MIXED"
why_str  = not ready ? "waiting on DSPX/COR3M" : "DSPX " + f_lab(dspx_st) + " / COR3M " + f_lab(cor_st)

veq_hot  = not na(veq_pct) and veq_pct >= veq_hot_lvl
veq_cold = not na(veq_pct) and veq_pct <= lo_in
veq_str  = na(veq_pct) ? "n/a" : veq_hot ? "ELEVATED" : veq_cold ? "SUBDUED" : "NORMAL"
ovl_str  = na(veq_pct) ? "VIXEQ n/a  (not in score)" : "VIXEQ " + str.tostring(veq_pct, "#") + "p  " + veq_str + "  (overlay)"

var float ims_ema = na
var array<float> ema_buf = array.new<float>()
var array<float> ims_buf = array.new<float>()

if (new_d or barstate.isfirst) and not na(ims)
    float a = 2.0 / (ema_len + 1.0)
    ims_ema := na(ims_ema) ? ims : ims_ema + a * (ims - ims_ema)
    array.push(ema_buf, ims_ema)
    if array.size(ema_buf) > i_tr_n
        array.shift(ema_buf)
    array.push(ims_buf, ims)
    if array.size(ims_buf) > i_band
        array.shift(ims_buf)

slope = array.size(ema_buf) >= i_tr_n ? array.last(ema_buf) - array.first(ema_buf) : 0.0
trend = slope > i_tr_min ? 1 : slope < -i_tr_min ? -1 : 0
tr_str = na(ims) ? "n/a" : trend > 0 ? "RISING" : trend < 0 ? "FALLING" : "FLAT"
sd = array.size(ims_buf) >= 8 ? array.stdev(ims_buf) : na

var color zone_col = na
if not ready
    zone_col := neutral_color
else if picking
    zone_col := bullish_color
else if tape or stress
    zone_col := bearish_color
else if quiet
    zone_col := primary_color
else
    zone_col := color.new(primary_color, 20)

line_col = na(ims) ? neutral_color : ims >= pick_line ? bullish_color : ims <= tape_line ? bearish_color : primary_color
d_col = na(dspx) ? neutral_color : dspx_st == 1 ? bullish_color : dspx_st == -1 ? bearish_color : primary_color
c_col = na(cor3m) ? neutral_color : cor_st == 1 ? bearish_color : cor_st == -1 ? bullish_color : primary_color
v_col = na(vixeq) ? neutral_color : veq_hot ? bearish_color : veq_cold ? bullish_color : primary_color

var color bg_col = na
if i_bg_mode == "Dynamic"
    if na(ims)
        bg_col := na
    else if ims <= 4
        bg_col := color.from_gradient(ims, 0, 4, bearish_color, primary_color)
    else if ims >= 6
        bg_col := color.from_gradient(ims, 6, 10, primary_color, bullish_color)
    else
        bg_col := primary_color
else if i_bg_mode == "Position"
    bg_col := ready ? zone_col : na
else
    bg_col := na

bgcolor(not na(bg_col) ? color.new(bg_col, i_bg_int) : na, title="Background")

cndl = not ready ? na :
     picking ? color.new(bullish_color, i_candle_tr) :
     stress ? color.new(bearish_color, i_candle_tr) :
     tape ? color.new(bearish_color, i_candle_tr + 15) :
     quiet ? color.new(primary_color, i_candle_tr + 25) :
     color.new(primary_color, i_candle_tr + 35)
barcolor(i_candles ? cndl : na, title="Candle Color")

plot(i_glow ? ims : na, "Glow 3", color.new(line_col, 95), i_width + 6)
plot(i_glow ? ims : na, "Glow 2", color.new(line_col, 90), i_width + 4)
plot(i_glow ? ims : na, "Glow 1", color.new(line_col, 80), i_width + 2)

plot(ims, "IMS Score", line_col, i_width)
plot(i_trend ? ims_ema : na, "Daily EMA", color.new(primary_color, 40), 1)
plot(i_dspx_ln ? dspx_pct / 10.0 : na, "DSPX Rank", color.new(bullish_color, 40), 1)
plot(i_cor_ln ? (100.0 - cor_pct) / 10.0 : na, "Inverse COR3M Rank", color.new(bearish_color, 40), 1)

up_b = plot(i_bands and not na(sd) ? ims + sd : na, "Upper Band", color.new(color.gray, band_tr), display=display.none)
dn_b = plot(i_bands and not na(sd) ? ims - sd : na, "Lower Band", color.new(color.gray, band_tr), display=display.none)
fill(up_b, dn_b, i_bands ? color.new(color.gray, band_tr) : na, title="Band")

hi_ln = plot(pick_line, color=color.new(bullish_color, 20), linewidth=1, title="Score 7.5")
lo_ln = plot(tape_line, color=color.new(bearish_color, 20), linewidth=1, title="Score 2.5")
fill(hi_ln, lo_ln, i_zones ? color.new(primary_color, zone_tr) : na, title="Mid Score")
plot(5.0, "Mid", color.new(neutral_color, 60), 1, plot.style_line)

var table watermark = table.new(f_pos(i_wm_pos), 1, 4, border_width=0, bgcolor=color.new(color.black, 100))
if i_wm and barstate.islast
    wm_main = f_sz(i_wm_sz)
    wm_sec  = i_wm_sz == "Huge" ? size.large : i_wm_sz == "Large" ? size.normal : size.small
    wm_ter  = i_wm_sz == "Huge" ? size.normal : i_wm_sz == "Large" ? size.small : size.tiny
    wm_col  = i_dark ? color.new(color.white, 30) : color.new(color.black, 40)
    table.cell(watermark, 0, 0, syminfo.ticker + ", " + timeframe.period,
         bgcolor=color.new(color.black, 100), text_color=wm_col, text_size=wm_main, text_halign=text.align_right)
    table.cell(watermark, 0, 1, "IMS: " + (na(ims) ? "n/a" : str.tostring(ims, "#.##")),
         bgcolor=color.new(color.black, 100), text_color=wm_col, text_size=wm_sec, text_halign=text.align_right)
    table.cell(watermark, 0, 2, zone_str + " | " + why_str,
         bgcolor=color.new(color.black, 100), text_color=wm_col, text_size=wm_ter, text_halign=text.align_right)
    table.cell(watermark, 0, 3, i_conf ? "confirmed daily" : "live daily",
         bgcolor=color.new(color.black, 100), text_color=color.new(zone_col, 20), text_size=wm_sec, text_halign=text.align_right)

if i_dash and barstate.islast
    cell_sz = f_sz(i_dash_sz == "Tiny" or i_dash_sz == "Small" ? "Tiny" : "Small")
    hdr_sz  = f_sz(i_dash_sz)
    var table dash = table.new(f_pos(i_dash_pos), 4, 13, border_width=1, bgcolor=color.new(table_bg, table_tr))
    table.clear(dash, 0, 0, 3, 12)
    hdr_bg = color.new(header_bg, 20)
    empty  = color.new(table_bg, table_tr)

    table.cell(dash, 0, 0, "IMS score", text_color=text_color, bgcolor=hdr_bg, text_size=hdr_sz)
    table.cell(dash, 1, 0, na(ims) ? "n/a" : str.tostring(ims, "#.##"), text_color=text_color, bgcolor=hdr_bg, text_size=hdr_sz)
    table.cell(dash, 2, 0, "", bgcolor=hdr_bg)
    table.cell(dash, 3, 0, i_conf ? "confirmed D" : "live D", text_color=text_color, bgcolor=hdr_bg, text_size=cell_sz)

    table.cell(dash, 0, 1, "Regime", text_color=text_color, bgcolor=color.new(zone_col, 80), text_size=hdr_sz)
    table.cell(dash, 1, 1, zone_str, text_color=zone_col, bgcolor=color.new(zone_col, 80), text_size=hdr_sz)
    table.cell(dash, 2, 1, "", bgcolor=empty)
    table.cell(dash, 3, 1, "", bgcolor=empty)

    table.cell(dash, 0, 2, "Why", text_color=text_color, bgcolor=color.new(zone_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 2, why_str, text_color=zone_col, bgcolor=color.new(zone_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 2, "", bgcolor=empty)
    table.cell(dash, 3, 2, "", bgcolor=empty)

    table.cell(dash, 0, 3, "DSPX", text_color=text_color, bgcolor=color.new(d_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 3, f_lvl(dspx, dspx_pct, dspx_st), text_color=d_col, bgcolor=color.new(d_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 3, "", bgcolor=empty)
    table.cell(dash, 3, 3, "", bgcolor=empty)

    table.cell(dash, 0, 4, "COR3M", text_color=text_color, bgcolor=color.new(c_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 4, f_lvl(cor3m, cor_pct, cor_st), text_color=c_col, bgcolor=color.new(c_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 4, "", bgcolor=empty)
    table.cell(dash, 3, 4, "", bgcolor=empty)

    table.cell(dash, 0, 5, "Vol overlay", text_color=text_color, bgcolor=color.new(v_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 5, ovl_str, text_color=v_col, bgcolor=color.new(v_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 5, "", bgcolor=empty)
    table.cell(dash, 3, 5, "", bgcolor=empty)

    t_col = trend > 0 ? bullish_color : trend < 0 ? bearish_color : primary_color
    table.cell(dash, 0, 6, "Trend", text_color=text_color, bgcolor=color.new(t_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 6, tr_str, text_color=t_col, bgcolor=color.new(t_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 6, "", bgcolor=empty)
    table.cell(dash, 3, 6, "", bgcolor=empty)

    st_col = ready ? bullish_color : primary_color
    table.cell(dash, 0, 7, "Status", text_color=text_color, bgcolor=color.new(st_col, 90), text_size=cell_sz)
    table.cell(dash, 1, 7, ready ? "ACTIVE" : "WARMING UP", text_color=st_col, bgcolor=color.new(st_col, 90), text_size=cell_sz)
    table.cell(dash, 2, 7, "", bgcolor=empty)
    table.cell(dash, 3, 7, "", bgcolor=empty)

    table.merge_cells(dash, 1, 1, 3, 1)
    table.merge_cells(dash, 1, 2, 3, 2)
    table.merge_cells(dash, 1, 3, 3, 3)
    table.merge_cells(dash, 1, 4, 3, 4)
    table.merge_cells(dash, 1, 5, 3, 5)
    table.merge_cells(dash, 1, 6, 3, 6)
    table.merge_cells(dash, 1, 7, 3, 7)

    if i_matrix
        on_pick = picking
        on_stress = stress
        on_comp = quiet
        on_tape = tape
        on_mid = ready and not tape and not picking and not stress and not quiet
        mid_bg = color.new(primary_color, 92)

        table.cell(dash, 0, 8, "DSPX \\ COR", text_color=text_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 1, 8, "LOW", text_color=bullish_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 2, 8, "MID", text_color=text_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 3, 8, "HIGH", text_color=bearish_color, bgcolor=hdr_bg, text_size=cell_sz)

        table.cell(dash, 0, 9, "HIGH", text_color=bullish_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 1, 9, "PICK", text_color=on_pick ? color.white : bullish_color, bgcolor=on_pick ? color.new(bullish_color, 40) : empty, text_size=cell_sz)
        table.cell(dash, 2, 9, ".", text_color=neutral_color, bgcolor=dspx_st == 1 and cor_st == 0 ? mid_bg : empty, text_size=cell_sz)
        table.cell(dash, 3, 9, "STRESS", text_color=on_stress ? color.white : bearish_color, bgcolor=on_stress ? color.new(bearish_color, 40) : empty, text_size=cell_sz)

        table.cell(dash, 0, 10, "MID", text_color=text_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 1, 10, ".", text_color=neutral_color, bgcolor=dspx_st == 0 and cor_st == -1 ? mid_bg : empty, text_size=cell_sz)
        table.cell(dash, 2, 10, "MIXED", text_color=on_mid ? text_color : neutral_color, bgcolor=on_mid ? mid_bg : empty, text_size=cell_sz)
        table.cell(dash, 3, 10, ".", text_color=neutral_color, bgcolor=dspx_st == 0 and cor_st == 1 ? mid_bg : empty, text_size=cell_sz)

        table.cell(dash, 0, 11, "LOW", text_color=bearish_color, bgcolor=hdr_bg, text_size=cell_sz)
        table.cell(dash, 1, 11, "COMP", text_color=on_comp ? color.white : primary_color, bgcolor=on_comp ? color.new(primary_color, 40) : empty, text_size=cell_sz)
        table.cell(dash, 2, 11, ".", text_color=neutral_color, bgcolor=dspx_st == -1 and cor_st == 0 ? mid_bg : empty, text_size=cell_sz)
        table.cell(dash, 3, 11, "TAPE", text_color=on_tape ? color.white : bearish_color, bgcolor=on_tape ? color.new(bearish_color, 40) : empty, text_size=cell_sz)

        table.cell(dash, 0, 12, "score = 1D", text_color=neutral_color, bgcolor=empty, text_size=cell_sz)
        table.cell(dash, 1, 12, "matrix = 2D", text_color=neutral_color, bgcolor=empty, text_size=cell_sz)
        table.cell(dash, 2, 12, "", bgcolor=empty)
        table.cell(dash, 3, 12, "", bgcolor=empty)

prev_zone = zone_str[1]
regime_chg = ready and not na(prev_zone) and zone_str != prev_zone and barstate.isconfirmed
leave_pick   = picking[1] and not picking and barstate.isconfirmed
leave_tape   = tape[1] and not tape and barstate.isconfirmed
leave_stress = stress[1] and not stress and barstate.isconfirmed
leave_quiet  = quiet[1] and not quiet and barstate.isconfirmed
mixed_to_pick = picking and prev_zone == "MIXED" and barstate.isconfirmed
ims_up   = ta.crossover(ims, pick_line) and barstate.isconfirmed
ims_dn   = ta.crossunder(ims, tape_line) and barstate.isconfirmed
tr_up    = trend == 1 and nz(trend[1], 0) != 1 and barstate.isconfirmed
tr_dn    = trend == -1 and nz(trend[1], 0) != -1 and barstate.isconfirmed
new_veq  = veq_hot and not veq_hot[1] and barstate.isconfirmed

if i_alerts and regime_chg
    alert("IMS: " + prev_zone + " -> " + zone_str, alert.freq_once_per_bar)

alertcondition(picking and not picking[1], "Enter STOCK PICKING", "IMS: entered STOCK PICKING")
alertcondition(tape and not tape[1], "Enter INDEX TAPE", "IMS: entered INDEX TAPE")
alertcondition(stress and not stress[1], "Enter BROAD STRESS", "IMS: entered BROAD STRESS")
alertcondition(quiet and not quiet[1], "Enter COMPRESSED", "IMS: entered COMPRESSED")
alertcondition(mixed_to_pick, "MIXED to STOCK PICKING", "IMS: MIXED -> STOCK PICKING")
alertcondition(leave_pick, "Leave STOCK PICKING", "IMS: left STOCK PICKING")
alertcondition(leave_tape, "Leave INDEX TAPE", "IMS: left INDEX TAPE")
alertcondition(leave_stress, "Leave BROAD STRESS", "IMS: left BROAD STRESS")
alertcondition(leave_quiet, "Leave COMPRESSED", "IMS: left COMPRESSED")
alertcondition(ims_up, "IMS crossed 7.5", "IMS score crossed above 7.5")
alertcondition(ims_dn, "IMS crossed 2.5", "IMS score crossed below 2.5")
alertcondition(tr_up, "Trend up", "IMS daily EMA slope turned up")
alertcondition(tr_dn, "Trend down", "IMS daily EMA slope turned down")
alertcondition(new_veq, "VIXEQ overlay elevated", "IMS: VIXEQ overlay percentile >= 70")
````
