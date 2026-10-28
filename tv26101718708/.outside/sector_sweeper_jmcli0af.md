# Sector Sweeper

- url: https://www.tradingview.com/script/JmcLi0AF-Sector-Sweeper/
- type: indicator
- pine_id: PUB;8dafb306a776427786189dee3e28176f
- version: 1.0

## Description

[b]Ranks the 11 sectors and 12 key industries by performance — strongest at the top — so you know where to hunt before you pick a stock.[/b]

Strong stocks tend to come from strong groups.[b] Sector Sweeper[/b] shows which sectors and industries are leading the market right now, ranked top to bottom on one clean board — so you start your search in the right place instead of guessing.

[b]It works on its own — nothing else required.[/b]

[b]How it measures — no black box[/b]

Each row pulls that ETF's closing prices and computes its percent change over your lookback window; the lists are then sorted strongest to weakest. No smoothing, no proprietary formula — the value is having all 23 groups measured by the same yardstick, on one board, updated every bar, instead of flipping through 23 charts to build the same picture by hand.

[b]What it shows — two tables[/b]

[b]•SECTORS[/b]  — the 11 S&P sector ETFs (Technology, Financials, Energy, Health Care, …), ranked by performance over your lookback.

[b]•SUB-INDUSTRIES[/b]  — 12 sharper themes (Semiconductors, Software, Biotech, Oil Services, Gold Miners, Airlines, …), ranked the same way.

Each row shows the ETF and its % move over the lookback. Green = up, red = down, and the[b] #1 in each list is highlighted in gold[/b]

[b]How to read it[/b] 

• Top of the list = where money is flowing. Bottom = what's lagging.
• Use it **top-down**: spot the strongest sector or industry here, then go find the leading stocks inside that group.
• Watch it over time — a group climbing the board is rotating into favor; one sliding down is falling out of it.

[b]Settings — defaults work out of the box[/b]

[b]• Lookback (bars[/b]) — the performance window (20 by default ≈ about a month on a daily chart).
• Each table has its own [b]position[/b] (default: Sectors = Middle Left, Sub-Industries = Middle Right) plus table[b] size[/b], [b]dark/light[/b] theme, and colors.

⚠ Educational tool for market context and planning. It ranks performance — it does not give buy/sell signals or predict price. Not financial advice.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────
// Sector Sweeper — by BlueBeck
// Sector & sub-industry relative-strength board (top-down rotation)
// © 2026 BlueBeck
// ─────────────────────────────────────────────────────────────
//@version=6
indicator("Sector Sweeper", "Sweeper", overlay = true)

// ── Inputs ────────────────────────────────────────────────────────────────────
i_len  = input.int(20, "Lookback (bars)", minval = 1, maxval = 500)

grpDash = "Dashboard"
i_size  = input.string("Normal", "Table size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpDash)
secPos  = input.string("Middle Left",  "Sectors table position",        options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpDash)
subPos  = input.string("Middle Right", "Sub-industries table position",  options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpDash)

grpTheme = "Theme & Colors"
darkMode = input.bool(true, "Dark theme (uncheck for light charts)", group = grpTheme)
colGood  = input.color(#089981, "Strong", group = grpTheme, inline = "c1")
colBad   = input.color(#f23645, "Weak",   group = grpTheme, inline = "c1")

// ── Text size helper ──────────────────────────────────────────────────────────
txt_size =
     i_size == "Tiny"  ? size.tiny  :
     i_size == "Small" ? size.small :
     i_size == "Large" ? size.large :
     i_size == "Huge"  ? size.huge  :
     size.normal
// ── Performance function ──────────────────────────────────────────────────────
perf(sym) =>
    c = request.security(sym, timeframe.period, close, lookahead = barmerge.lookahead_off)
    (c / c[i_len] - 1) * 100
// ── 11 SPDR Sectors ───────────────────────────────────────────────────────────
p0  = perf("XLK")
p1  = perf("XLF")
p2  = perf("XLY")
p3  = perf("XLV")
p4  = perf("XLI")
p5  = perf("XLC")
p6  = perf("XLE")
p7  = perf("XLB")
p8  = perf("XLRE")
p9  = perf("XLU")
p10 = perf("XLP")
// ── 12 Sub-Industries ─────────────────────────────────────────────────────────
s0  = perf("SMH")
s1  = perf("IGV")
s2  = perf("HACK")
s3  = perf("XBI")
s4  = perf("KRE")
s5  = perf("OIH")
s6  = perf("XOP")
s7  = perf("TAN")
s8  = perf("JETS")
s9  = perf("XRT")
s10 = perf("ITA")
s11 = perf("GDX")
// ── Label arrays ──────────────────────────────────────────────────────────────
var string[] sec_tck = array.from("XLK","XLF","XLY","XLV","XLI","XLC","XLE","XLB","XLRE","XLU","XLP")
var string[] sec_nms = array.from("Technology","Financials","Cons Disc","Health Care","Industrials","Comm Svcs","Energy","Materials","Real Estate","Utilities","Cons Staples")
var string[] sub_tck = array.from("SMH","IGV","HACK","XBI","KRE","OIH","XOP","TAN","JETS","XRT","ITA","GDX")
var string[] sub_nms = array.from("Semiconductors","Software","Cybersecurity","Biotech","Reg Banks","Oil Services","Oil & Gas E&P","Solar","Airlines","Retail","Aerospace & Def","Gold Miners")
// ── Array builders ────────────────────────────────────────────────────────────
build_sec() =>
    array.from(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
build_sub() =>
    array.from(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11)
// ── Sort descending ───────────────────────────────────────────────────────────
sort_desc(float[] pa) =>
    int n     = array.size(pa)
    int[] idx = array.new_int()
    for i = 0 to n - 1
        array.push(idx, i)
    for i = 0 to n - 2
        for j = 0 to n - 2 - i
            if array.get(pa, array.get(idx, j)) < array.get(pa, array.get(idx, j + 1))
                int tmp = array.get(idx, j)
                array.set(idx, j,     array.get(idx, j + 1))
                array.set(idx, j + 1, tmp)
    idx
// ── BlueBeck theme — navy #0a1527 · gold #c0a571 ───────────────────────────────
c_navy   = #0a1527
c_gold   = #c0a571
c_bodyBg = darkMode ? color.new(#0e1a2f, 0) : color.new(#ffffff, 0)
c_lbl    = darkMode ? #9aa4b2 : #5b6470
c_txt    = darkMode ? #e8e8ec : #0a1527
C_TRANS  = color.new(color.black, 100)

f_pos9(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right
// ── Tables ────────────────────────────────────────────────────────────────────
var table sec_tbl = table.new(f_pos9(secPos), 3, 13, border_width = 0, frame_width = 1, frame_color = c_gold)
var table sub_tbl = table.new(f_pos9(subPos), 3, 13, border_width = 0, frame_width = 1, frame_color = c_gold)
if barstate.islast
    table.clear(sec_tbl, 0, 0, 2, 12)
    table.clear(sub_tbl, 0, 0, 2, 12)
    table.set_position(sec_tbl, f_pos9(secPos))
    table.set_position(sub_tbl, f_pos9(subPos))
    string hdr = "Perf (" + str.tostring(i_len) + "b)"
    // ── Sectors header ────────────────────────────────────────────────────────
    table.cell(sec_tbl, 0, 0, "SECTORS", bgcolor = c_navy, text_color = c_gold, text_size = txt_size, text_halign = text.align_left,   width = 16)
    table.cell(sec_tbl, 1, 0, "ETF",     bgcolor = c_navy, text_color = c_lbl,  text_size = txt_size, text_halign = text.align_center, width = 7)
    table.cell(sec_tbl, 2, 0, hdr,       bgcolor = c_navy, text_color = c_lbl,  text_size = txt_size, text_halign = text.align_right,  width = 10)
    // ── Sector rows ───────────────────────────────────────────────────────────
    float[] sec_pa  = build_sec()
    int[]   sec_idx = sort_desc(sec_pa)
    for row = 0 to 10
        int   i     = array.get(sec_idx, row)
        float p     = array.get(sec_pa,  i)
        bool  bull  = p >= 0
        bool  isTop = row == 0
        color bg    = bull ? color.new(#089981, 78) : color.new(#f23645, 78)
        color tc    = bull ? colGood : colBad
        string pstr = (bull ? "+" : "") + str.tostring(p, "#.00") + "%"
        table.cell(sec_tbl, 0, row + 1, array.get(sec_nms, i), bgcolor = c_bodyBg, text_color = isTop ? c_gold : c_txt, text_size = txt_size, text_halign = text.align_left,   width = 16)
        table.cell(sec_tbl, 1, row + 1, array.get(sec_tck, i), bgcolor = c_bodyBg, text_color = c_lbl,                  text_size = txt_size, text_halign = text.align_center, width = 7)
        table.cell(sec_tbl, 2, row + 1, pstr,                  bgcolor = bg,        text_color = tc,                     text_size = txt_size, text_halign = text.align_right,  width = 10)
    // ── Sub-industries header ─────────────────────────────────────────────────
    table.cell(sub_tbl, 0, 0, "SUB-INDUSTRIES", bgcolor = c_navy, text_color = c_gold, text_size = txt_size, text_halign = text.align_left,   width = 18)
    table.cell(sub_tbl, 1, 0, "ETF",            bgcolor = c_navy, text_color = c_lbl,  text_size = txt_size, text_halign = text.align_center, width = 7)
    table.cell(sub_tbl, 2, 0, hdr,              bgcolor = c_navy, text_color = c_lbl,  text_size = txt_size, text_halign = text.align_right,  width = 10)
    // ── Sub-industry rows ─────────────────────────────────────────────────────
    float[] sub_pa  = build_sub()
    int[]   sub_idx = sort_desc(sub_pa)
    for row = 0 to 11
        int   i     = array.get(sub_idx, row)
        float p     = array.get(sub_pa,  i)
        bool  bull  = p >= 0
        bool  isTop = row == 0
        color bg    = bull ? color.new(#089981, 78) : color.new(#f23645, 78)
        color tc    = bull ? colGood : colBad
        string pstr = (bull ? "+" : "") + str.tostring(p, "#.00") + "%"
        table.cell(sub_tbl, 0, row + 1, array.get(sub_nms, i), bgcolor = c_bodyBg, text_color = isTop ? c_gold : c_txt, text_size = txt_size, text_halign = text.align_left,   width = 18)
        table.cell(sub_tbl, 1, row + 1, array.get(sub_tck, i), bgcolor = c_bodyBg, text_color = c_lbl,                  text_size = txt_size, text_halign = text.align_center, width = 7)
        table.cell(sub_tbl, 2, row + 1, pstr,                  bgcolor = bg,        text_color = tc,                     text_size = txt_size, text_halign = text.align_right,  width = 10)
````
