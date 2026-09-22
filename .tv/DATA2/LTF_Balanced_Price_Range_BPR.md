<!-- tradingview-pine-id: PUB;c585b57fb99745a1bf348de760b798ef -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# LTF Balanced Price Range (BPR)

Source: https://www.tradingview.com/script/Hbzu8aj0-LTF-BPR-Balanced-Price-Range-D4A/

## Description

LTF BPR (Balanced Price Range)

Why working on my other BPR script: [HTF BPR](https://www.tradingview.com/script/9Ylk05RI-HTF-BPR-Balanced-Price-Range/), I thought it would be interesting to have BPR script that shows BPR from lower timeframe and hence this script was created. The logic is simply the same as in higher timeframe BPR script, with a few differences:

- the main one is to simplify the drawings, this script only draws average line from lower timeframe BPR. The main reason for this is that otherwise you can have too many BPR drawings which overlap and make it look very busy on the chart. From my experience the average line from LTF BPR is a reasonable level which the price usually interacts with. Once candles close beyond this line, the BPR won't hold in most cases.
- the average line is only drawn where the BPR formed and is not extended to avoid having too many lines on the chart. 
- another difference is that there are no side markers or labels like in the HTF script

Who is this script for
- students who follow ICT methodology
- scalper traders who want to see where price has already been balanced on lower timeframe

Since two scripts are very similar in what they do, the large part of script description is taken from the other script and only modified where appropriate.

Introduction to BPR Concept
Balanced Price Range (BPR) is especially important ICT methodology, as it helps to navigate institutional order flow. It pinpoints price zones where opposing market inefficiencies intersect, leaving pools of resting liquidity and unexecuted orders. This indicator automates the identification of these overlapping structures across any asset class while using data from lower timeframe (the script pulls data using pine function request.security_lower_tf)

What is BPR
A Balanced Price Range - frequently referred to as a double Fair Value Gap occurs when a bullish FVG and a bearish FVG directly overlap. Because both buyers and sellers created imbalances across the exact same price window, these overlapping zones become high-probability reaction areas. In algorithmic price delivery, BPRs serve as primary rebalancing targets where the market seeks liquidity before expanding or reversing.

What is FVG
FVG or Fair Value Gap is a three-candle formation where the middle candle moves so aggressively creating displacement that it leaves a gap between the wick of the prior candle and the wick of the following candle.

Trading Lower Timeframe BPRs
BPR entries remain one of the most underrated setup models in ICT trading. This script should help to pinpoint areas which may be important levels where the price is going to reverse from after seeking to re-balance and/or to give opportunity for Smart Money to re-enter the market. While using the script, one can easily observe that price very often reverses, which is seen as wicking out to/from these areas. With some experience you can learn how to use this information to make advantage of knowing which levels have been balanced and are not likely to be reversed to while the trend continues in the opposite direction.

The Underlying Mechanics
- Single Inefficiencies: A standard Fair Value Gap represents one-sided delivery—a rapid displacement where either buyers or sellers were largely absent.
- Dual Inefficiencies: A BPR represents a corridor that price aggressively skipped twice — once going up without sellers, and second time going down without buyers.
- Algorithmic Repricing: When price returns to a BPR, the delivery algorithm is repricing an area of double inefficiency. Because both buy-side and sell-side resting orders line up inside this narrow range, retests typically trigger decisive expansion away from the zone.

SETTINGS:
- Show LTF BPRs - enable displaying of BPR zones on lower timeframe
- Looback - how many previous bars are used to find BPRs
- Auto Lower timeframe (one step down) - when enabled, the script works using data from the previous lower timeframe below the chart's timeframe, eg. when on 1m chart, the script uses 15sec data, 5m chart -> 1m data and so on.
- Manual HTF - when the previous option is not enabled, you can select manualy any lower timeframe (it won't work with current timeframe or higher timeframe)
- Max BPR Length (LTF bars) - max distance between two opposing FVGs which are part of the same BPR
- Stop drawing BPR after X Candles - BPR is removed from the chart after this many bars
- Volume Imbalance Included - include volume imbalance as part of FVG which is part of BPR
- FVG Size Filter  (x LTF ATR) - limit the size of LTF FVG that is used to create valid BPR. Use 0 to ignore this limit.
- Bull/Bear Average Line - BPR decoration settings
- Mitigated BPR - select what happens when BPR is fully mitigated (the price closes through it).

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('LTF Balanced Price Range (BPR)', 'LTFBPRT', overlay=true, max_lines_count=500)

var g_LTFBPR = "LTF BPR - Balanced Price Range"
show_ltfbpr  = input.bool(true,   'Show LTF BPRs',                     inline='bpra',    group=g_LTFBPR)
bar_count_ltf = input.int(500,     '   Lookback (chart bars)',              inline='bpra',    group=g_LTFBPR, maxval=1000, tooltip="How many recent chart bars are checked for active BPRs. Max = 1000")
autoLTF      = input.bool(true,   'Auto Lower Timeframe (one step down)',                group=g_LTFBPR, tooltip="Automatically steps one TF level below the chart (e.g. 5m→1m, 1m→15s, 1H→15m). Disable to use the manual TF below.")
ltf           = input.timeframe("1","Manual LTF",                                         group=g_LTFBPR, tooltip="Manual lower timeframe to scan for BPRs (used only when Auto Lower Timeframe is disabled)")
lookback_ltf  = input.int(50,      'Max BPR Length (LTF bars)',                           group=g_LTFBPR, maxval=400, tooltip="Max LTF-bar distance between the two FVGs that form a BPR. Max = 400")
closeBPR_ltf  = input.int(300,     'Stop Drawing BPR after X Chart Bars',                 group=g_LTFBPR)
VI_included  = input.bool(false,  'Volume Imbalance Included',                           group=g_LTFBPR, tooltip="Adjusts FVG zone boundaries to include volume imbalances. Can reduce BPR detection — disable if results seem sparse.")
filterBPR    = input.float(0.0,   'FVG Size Filter (× LTF ATR)',                           group=g_LTFBPR, minval=0, step=0.1, tooltip="Component FVGs must be larger than this multiple of ATR(200) on the LTF. Default 0 = no filter. Raise to suppress noise.")
bullCol      = input.color(color.new(color.aqua, 20),       'Bull/Bear Average Line',  inline='ltfbpr1',   group=g_LTFBPR)
bearCol      = input.color(color.rgb(255,30,170,20),        '',      inline='ltfbpr1',   group=g_LTFBPR)
ltfbpr_style = input.string(line.style_dotted, '', options=[line.style_dashed, line.style_dotted, line.style_solid],  inline='ltfbpr1', group=g_LTFBPR)
ln_width     = input.int(2,       '',                                   inline='ltfbpr1', group=g_LTFBPR)
filledBpr_ltf = input.string('Remove', 'Mitigated BPR', ['Remove', 'Highlight'], inline='mit', group=g_LTFBPR)
mitigCol     = input.color(color.silver, '',                            inline='mit',     group=g_LTFBPR)

ltfbpr_switch = last_bar_index - bar_index <= bar_count_ltf
tf_ms         = time - time[1]

resolve_auto_ltf() =>
    string r = ltf
    if timeframe.isminutes
        m = timeframe.multiplier
        if m <= 1
            r := "15S"          // 1m  → 15s
        else if m <= 5
            r := "1"            // 5m  → 1m
        else if m <= 15
            r := "5"            // 15m → 5m
        else if m <= 60
            r := "15"           // 1H  → 15m
        else if m <= 240
            r := "60"           // 4H  → 1H
        else
            r := "240"          // >4H → 4H
    else if timeframe.isdaily
        r := "240"              // D   → 4H
    else if timeframe.isweekly
        r := "1D"               // W   → D
    else if timeframe.ismonthly
        r := "1W"               // M   → W
    else
        r := ltf
    r

type LTF
    array<float> o
    array<float> h
    array<float> l
    array<float> c
    array<int>   t

type fvg
    float top       
    float bottom   
    int   t1      
    int   t2 

type bpr_ltf
    bool  act        = false
    bool  bull       = true
    int   start_time            
    float top                   
    float bottom                
    line  ln             

method manageBPR(array<bpr_ltf> this, float ltf_close, int limit_ms) =>
    if this.size() > 0
        for i = this.size() - 1 to 0
            b = this.get(i)

            if (time - b.start_time) > limit_ms
                line.delete(b.ln)
                this.remove(i)
                continue     

            line.set_x2(b.ln, b.start_time + tf_ms * 3)

            if b.bull and b.act and ltf_close < b.bottom
                b.act := false
                if filledBpr_ltf == 'Remove'
                    line.delete(b.ln)
                    this.remove(i)
                    continue
                else
                    line.set_color(b.ln, mitigCol)
                    line.set_style(b.ln, line.style_dashed)
                    line.set_width(b.ln, 1)

            if not b.bull and b.act and ltf_close > b.top
                b.act := false
                if filledBpr_ltf == 'Remove'
                    line.delete(b.ln)
                    this.remove(i)
                    continue
                else
                    line.set_color(b.ln, mitigCol)
                    line.set_style(b.ln, line.style_dashed)
                    line.set_width(b.ln, 1)

var ltfData     = LTF.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<int>())
var ltfDataPrev = LTF.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<int>())

var array<fvg> bull_fvgs = array.new<fvg>()
var array<fvg> bear_fvgs = array.new<fvg>()
var array<bpr_ltf> bprArr    = array.new<bpr_ltf>()

effective_ltf = autoLTF ? resolve_auto_ltf() : ltf
lookback_ms   = lookback_ltf * timeframe.in_seconds(effective_ltf) * 1000 
ltf_atr       = nz(request.security(syminfo.tickerid, effective_ltf, ta.atr(200)))

filter_fvg(float a, float b) => a - b > ltf_atr * filterBPR

ltfO = request.security_lower_tf(syminfo.tickerid, effective_ltf, open)
ltfH = request.security_lower_tf(syminfo.tickerid, effective_ltf, high)
ltfL = request.security_lower_tf(syminfo.tickerid, effective_ltf, low)
ltfC = request.security_lower_tf(syminfo.tickerid, effective_ltf, close)
ltfT = request.security_lower_tf(syminfo.tickerid, effective_ltf, time)

prune_old_fvgs(int ref_t) =>
    while bull_fvgs.size() > 0 and ref_t - bull_fvgs.get(0).t2 > lookback_ms
        bull_fvgs.shift()
    while bear_fvgs.size() > 0 and ref_t - bear_fvgs.get(0).t2 > lookback_ms
        bear_fvgs.shift()

check_bpr_overlap(float new_top, float new_bot, int new_t1, int new_t2, bool is_bull) =>
    opposite = is_bull ? bear_fvgs : bull_fvgs
    if opposite.size() > 0
        for idx = opposite.size() - 1 to 0
            h = opposite.get(idx)
            if new_t2 - h.t2 > lookback_ms
                break                             
            ovl_top = math.min(new_top, h.top)
            ovl_bot = math.max(new_bot, h.bottom)
            if ovl_top > ovl_bot                 
                mid = math.avg(ovl_top, ovl_bot)
                bprArr.push(bpr_ltf.new(
                     act          = true,
                     bull       = is_bull,
                     start_time = time,
                     top        = ovl_top,
                     bottom     = ovl_bot,
                     ln         = line.new(math.min(new_t1, h.t1), mid, new_t2, mid, color = is_bull ? bullCol : bearCol, style = ltfbpr_style, width = ln_width, xloc  = xloc.bar_time)
                     ))
                break  

register_bull_fvg(float o0, float l0, float c0, float o1, float c1, float o2, float h2, float c2, int t1_ms, int t2_ms) =>
    top = VI_included and c0 > o0 and o0 > c1 ? o0 : VI_included and c0 < o0 and c0 > c1 ? c0 : l0
    btm = VI_included and o2 < c2 and c2 < o1 ? c2 : h2
    if top > btm
        bull_fvgs.push(fvg.new(top=top, bottom=btm, t1=t1_ms, t2=t2_ms))
        check_bpr_overlap(top, btm, t1_ms, t2_ms, true)

register_bear_fvg(float o0, float h0, float c0, float o1, float c1, float o2, float l2, float c2, int t1_ms, int t2_ms) =>
    top = VI_included and o2 > c2 and c2 > o1 ? c2 : l2
    btm = VI_included and o0 > c0 and o0 < c1 ? o0 : VI_included and o0 < c0 and c0 < c1 ? c0 : h0
    if top > btm
        bear_fvgs.push(fvg.new(top=top, bottom=btm, t1=t1_ms, t2=t2_ms))
        check_bpr_overlap(top, btm, t1_ms, t2_ms, false)

scan_fvgs(LTF d) =>
    n = d.h.size()
    if n >= 3
        for i = 2 to n - 1
            o0 = d.o.get(i)
            h0 = d.h.get(i)
            l0 = d.l.get(i)
            c0 = d.c.get(i)
            o1 = d.o.get(i-1)
            h1 = d.h.get(i-1)
            l1 = d.l.get(i-1)
            c1 = d.c.get(i-1)
            o2 = d.o.get(i-2)
            h2 = d.h.get(i-2)
            l2 = d.l.get(i-2)
            c2 = d.c.get(i-2)
            t1_ms = d.t.get(i-2)
            t2_ms = d.t.get(i)
            if h1 > h2 and l0 > h2 and filter_fvg(l0, h2)
                register_bull_fvg(o0, l0, c0, o1, c1, o2, h2, c2, t1_ms, t2_ms)
            if l1 < l2 and h0 < l2 and filter_fvg(l2, h0)
                register_bear_fvg(o0, h0, c0, o1, c1, o2, l2, c2, t1_ms, t2_ms)

scan_cross_bar_fvgs(LTF prev, LTF cur) =>
    np = prev.h.size()
    nc = cur.h.size()

    if np >= 2 and nc >= 1
        o2 = prev.o.get(np-2)
        h2 = prev.h.get(np-2)
        l2 = prev.l.get(np-2)
        c2 = prev.c.get(np-2)
        o1 = prev.o.get(np-1)
        h1 = prev.h.get(np-1)
        l1 = prev.l.get(np-1)
        c1 = prev.c.get(np-1)
        o0 = cur.o.get(0)
        h0 = cur.h.get(0)
        l0 = cur.l.get(0)
        c0 = cur.c.get(0)
        t1_ms = prev.t.get(np-2)
        t2_ms = cur.t.get(0)
        if h1 > h2 and l0 > h2 and filter_fvg(l0, h2)
            register_bull_fvg(o0, l0, c0, o1, c1, o2, h2, c2, t1_ms, t2_ms)
        if l1 < l2 and h0 < l2 and filter_fvg(l2, h0)
            register_bear_fvg(o0, h0, c0, o1, c1, o2, l2, c2, t1_ms, t2_ms)

    if np >= 1 and nc >= 2
        o2 = prev.o.get(np-1)
        h2 = prev.h.get(np-1)
        l2 = prev.l.get(np-1)
        c2 = prev.c.get(np-1)
        o1 = cur.o.get(0)
        h1 = cur.h.get(0)
        l1 = cur.l.get(0)
        c1 = cur.c.get(0)
        o0 = cur.o.get(1)
        h0 = cur.h.get(1)
        l0 = cur.l.get(1)
        c0 = cur.c.get(1)
        t1_ms = prev.t.get(np-1)
        t2_ms = cur.t.get(1)
        if h1 > h2 and l0 > h2 and filter_fvg(l0, h2)
            register_bull_fvg(o0, l0, c0, o1, c1, o2, h2, c2, t1_ms, t2_ms)
        if l1 < l2 and h0 < l2 and filter_fvg(l2, h0)
            register_bear_fvg(o0, h0, c0, o1, c1, o2, l2, c2, t1_ms, t2_ms)

if timeframe.change(timeframe.period) and show_ltfbpr and ltfbpr_switch
    ltfDataPrev.o := array.copy(ltfData.o)
    ltfDataPrev.h := array.copy(ltfData.h)
    ltfDataPrev.l := array.copy(ltfData.l)
    ltfDataPrev.c := array.copy(ltfData.c)
    ltfDataPrev.t := array.copy(ltfData.t)
    ltfData.o := ltfO
    ltfData.h := ltfH
    ltfData.l := ltfL
    ltfData.c := ltfC
    ltfData.t := ltfT

    if ltfT.size() > 0
        prune_old_fvgs(ltfT.get(ltfT.size() - 1))
    
    scan_cross_bar_fvgs(ltfDataPrev, ltfData)
    scan_fvgs(ltfData)

ltf_close = ltfC.size() > 0 ? ltfC.get(ltfC.size() - 1) : close
limit_ms  = closeBPR_ltf * timeframe.in_seconds(timeframe.period) * 1000

if show_ltfbpr
    bprArr.manageBPR(ltf_close, limit_ms)
````
