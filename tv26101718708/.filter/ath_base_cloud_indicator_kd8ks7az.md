# ATH Base Cloud Indicator

- url: https://www.tradingview.com/script/kD8KS7az/
- type: indicator
- pine_id: PUB;1d8329a435634bef94acbb68d9483501
- version: 3.0

## Description

웨돔이가 쓰는 ATH Base의 구름대 지표를 대충 모방한 지표입니다.
아마 ATH Base 만든 걔네들은 저 선들에다가 Envelope같은 밴드만 추가해서 쓰는 걸로 추측됨.
만약에 완벽하게 모방하고 싶으면 저 지표 각 선들마다 밴드 붙여서 따로 사용하세요.
지표로 날먹하려는 레퍼럴 충들 따끔하게 혼내려고 오늘 깔짝거리면서 만든 지표입니다.
추세 끝판왕 지표라고 지들 커뮤니티에 써놓긴 했던데 사실 로직 다 뜯어보면 일반 이평선 지표랑 크게 다를 거 없음여 ㅋㅋㅋ 그래도 나름 매매할 때 도움될 것 같기도 합니다. ㅅㄱ

## Source Code

````pine
//@version=5
indicator("구름대 지표", overlay=true, max_lines_count=500)

// ─── 공통 설정 ─────────────────────────────────────────
ma_type    = input.string("EMA", "MA 종류", options=["SMA","EMA","DEMA","TEMA","LSMA","WMA","MF","VAMA","TMA","HMA","JMA","Kijun v2","EDSMA","McGinley"])
ma_len     = input.int(900,   "MA 길이",          minval=1)
ratio      = input.float(50.0,"비율 (%)",         minval=0.0, maxval=100.0, step=0.5)
smooth_len = input.int(20,    "Center Smooth",    minval=1)
band_width = input.float(0.5, "Width (ATR 배수)", minval=0.01, maxval=10.0, step=0.05)
atr_len    = input.int(500,   "ATR 길이",         minval=1)
atr_smooth = input.int(10,    "ATR Smooth",       minval=1)

// ─── 리본 모드 ─────────────────────────────────────────
ribbon_mode = input.bool(false, "Ribbon Mode",
     tooltip="ON: center_raw(비율 혼합값)을 다음 Wave 소스로 연쇄\nOFF: 각 Wave가 지정 타임프레임 독립 계산")

// ─── JMA 설정 ──────────────────────────────────────────
jurik_phase = input.int(3, "JMA Phase", group="JMA Settings")
jurik_power = input.int(1, "JMA Power", group="JMA Settings")

// ─── Kijun 설정 ────────────────────────────────────────
kidiv = input.int(1, "Kijun Divider", maxval=4, group="Kijun Settings")

// ─── VAMA 설정 ─────────────────────────────────────────
volatility_lookback = input.int(10, "VAMA Volatility Lookback", group="VAMA Settings")

// ─── MF 설정 ───────────────────────────────────────────
mf_beta     = input.float(0.8, "MF Beta",              minval=0.0, maxval=1.0, step=0.1, group="MF Settings")
mf_feedback = input.bool(false,"MF Feedback",          group="MF Settings")
mf_z        = input.float(0.5, "MF Feedback Weighting",minval=0.0, maxval=1.0, step=0.1, group="MF Settings")

// ─── EDSMA 설정 ────────────────────────────────────────
ssf_length = input.int(20, "SSF Length", minval=1,       group="EDSMA Settings")
ssf_poles  = input.int(2,  "SSF Poles",  options=[2, 3], group="EDSMA Settings")

// ─── Wave 설정 ─────────────────────────────────────────
show_all = input.bool(true, "Show All Waves")

w1_on  = input.bool(true,  "Wave 1", inline="w1", group="Waves")
w1_col = input.color(#b2b5be, "",    inline="w1", group="Waves")
w1_tf  = input.timeframe("1",   "",  inline="w1", group="Waves")

w2_on  = input.bool(true,  "Wave 2", inline="w2", group="Waves")
w2_col = input.color(#089981, "",    inline="w2", group="Waves")
w2_tf  = input.timeframe("5",   "",  inline="w2", group="Waves")

w3_on  = input.bool(true,  "Wave 3", inline="w3", group="Waves")
w3_col = input.color(#f37021, "",    inline="w3", group="Waves")
w3_tf  = input.timeframe("15",  "",  inline="w3", group="Waves")

w4_on  = input.bool(true,  "Wave 4", inline="w4", group="Waves")
w4_col = input.color(#2962ff, "",    inline="w4", group="Waves")
w4_tf  = input.timeframe("60",  "",  inline="w4", group="Waves")

w5_on  = input.bool(true,  "Wave 5", inline="w5", group="Waves")
w5_col = input.color(#9c27b0, "",    inline="w5", group="Waves")
w5_tf  = input.timeframe("240", "",  inline="w5", group="Waves")

// ═══════════════════════════════════════════════════════
// ─── SSF 헬퍼 ──────────────────────────────────────────
// ═══════════════════════════════════════════════════════
get2PoleSSF(src, length) =>
    PI   = 2 * math.asin(1)
    arg  = math.sqrt(2) * PI / length
    a1   = math.exp(-arg)
    b1   = 2 * a1 * math.cos(arg)
    c2   = b1
    c3   = -math.pow(a1, 2)
    c1   = 1 - c2 - c3
    ssf  = 0.0
    ssf := c1 * src + c2 * nz(ssf[1]) + c3 * nz(ssf[2])
    ssf

get3PoleSSF(src, length) =>
    PI    = 2 * math.asin(1)
    arg   = PI / length
    a1    = math.exp(-arg)
    b1    = 2 * a1 * math.cos(1.738 * arg)
    c1    = math.pow(a1, 2)
    coef2 = b1 + c1
    coef3 = -(c1 + b1 * c1)
    coef4 = math.pow(c1, 2)
    coef1 = 1 - coef2 - coef3 - coef4
    ssf   = 0.0
    ssf  := coef1 * src + coef2 * nz(ssf[1]) + coef3 * nz(ssf[2]) + coef4 * nz(ssf[3])
    ssf

// ═══════════════════════════════════════════════════════
// ─── MA 함수 ───────────────────────────────────────────
// ═══════════════════════════════════════════════════════
f_ma(type, src, len) =>
    float result = na
    if type == "SMA"
        result := ta.sma(src, len)
    if type == "EMA"
        result := ta.ema(src, len)
    if type == "DEMA"
        e      = ta.ema(src, len)
        result := 2 * e - ta.ema(e, len)
    if type == "TEMA"
        e      = ta.ema(src, len)
        result := 3 * (e - ta.ema(e, len)) + ta.ema(ta.ema(e, len), len)
    if type == "LSMA"
        result := ta.linreg(src, len, 0)
    if type == "WMA"
        result := ta.wma(src, len)
    if type == "HMA"
        result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
    if type == "TMA"
        result := ta.sma(ta.sma(src, math.ceil(len / 2)), math.floor(len / 2) + 1)
    if type == "VAMA"
        mid    = ta.ema(src, len)
        dev    = src - mid
        result := mid + math.avg(ta.highest(dev, volatility_lookback), ta.lowest(dev, volatility_lookback))
    if type == "MF"
        ts    = 0.0
        b     = 0.0
        c     = 0.0
        os    = 0.0
        alpha = 2 / (len + 1)
        a     = mf_feedback ? mf_z * src + (1 - mf_z) * nz(ts[1], src) : src
        b    := a > alpha * a + (1 - alpha) * nz(b[1], a) ? a : alpha * a + (1 - alpha) * nz(b[1], a)
        c    := a < alpha * a + (1 - alpha) * nz(c[1], a) ? a : alpha * a + (1 - alpha) * nz(c[1], a)
        os   := a == b ? 1 : a == c ? 0 : os[1]
        ts   := os * (mf_beta * b + (1 - mf_beta) * c) + (1 - os) * (mf_beta * c + (1 - mf_beta) * b)
        result := ts
    if type == "JMA"
        phaseRatio = jurik_phase < -100 ? 0.5 : jurik_phase > 100 ? 2.5 : jurik_phase / 100 + 1.5
        jb         = 0.45 * (len - 1) / (0.45 * (len - 1) + 2)
        ja         = math.pow(jb, jurik_power)
        jma        = 0.0
        e0         = 0.0
        e1         = 0.0
        e2         = 0.0
        e0        := (1 - ja) * src + ja * nz(e0[1])
        e1        := (src - e0) * (1 - jb) + jb * nz(e1[1])
        e2        := (e0 + phaseRatio * e1 - nz(jma[1])) * math.pow(1 - ja, 2) + math.pow(ja, 2) * nz(e2[1])
        jma       := e2 + nz(jma[1])
        result     := jma
    if type == "Kijun v2"
        kijun  = math.avg(ta.lowest(len), ta.highest(len))
        conv   = math.avg(ta.lowest(len / kidiv), ta.highest(len / kidiv))
        result := (kijun + conv) / 2
    if type == "McGinley"
        mg    = 0.0
        mg   := na(mg[1]) ? ta.ema(src, len) : mg[1] + (src - mg[1]) / (len * math.pow(src / mg[1], 4))
        result := mg
    if type == "EDSMA"
        zeros  = src - nz(src[2])
        avg0   = (zeros + zeros[1]) / 2
        ssf    = ssf_poles == 2 ? get2PoleSSF(avg0, ssf_length) : get3PoleSSF(avg0, ssf_length)
        stdev  = ta.stdev(ssf, len)
        alpha  = stdev != 0 ? 5 * math.abs(ssf / stdev) / len : 0.0
        edsma  = 0.0
        edsma := alpha * src + (1 - alpha) * nz(edsma[1])
        result := edsma
    result

// ═══════════════════════════════════════════════════════
// ─── 밴드 계산: [상단, 하단, center_raw] 반환 ──────────
//   center_raw = MA와 소스의 비율 혼합값 (스무딩 전)
//   → 이것이 다음 Wave의 소스가 됨
// ═══════════════════════════════════════════════════════
f_band(src_c) =>
    ma_val      = f_ma(ma_type, src_c, ma_len)
    center_raw  = ma_val + (src_c - ma_val) * (ratio / 100.0)  // 스무딩 전 비율 혼합값
    center      = ta.ema(center_raw, smooth_len)                // 표시용 스무딩
    atr_off     = ta.ema(ta.atr(atr_len), atr_smooth) * band_width
    [center + atr_off, center - atr_off, center_raw]           // center_raw를 다음 소스로 전달

// ═══════════════════════════════════════════════════════
// ─── 리본 모드: center_raw 연쇄 ────────────────────────
// ═══════════════════════════════════════════════════════
[r1u, r1l, cr1] = f_band(close)      // Wave 1: close 기반
[r2u, r2l, cr2] = f_band(cr1)        // Wave 2: Wave 1의 center_raw 기반
[r3u, r3l, cr3] = f_band(cr2)        // Wave 3: Wave 2의 center_raw 기반
[r4u, r4l, cr4] = f_band(cr3)        // Wave 4: Wave 3의 center_raw 기반
[r5u, r5l, cr5] = f_band(cr4)        // Wave 5: Wave 4의 center_raw 기반

// ─── 일반 모드: 타임프레임별 독립 계산 ──────────────────
[n1u, n1l, _c1] = request.security(syminfo.tickerid, w1_tf, f_band(close))
[n2u, n2l, _c2] = request.security(syminfo.tickerid, w2_tf, f_band(close))
[n3u, n3l, _c3] = request.security(syminfo.tickerid, w3_tf, f_band(close))
[n4u, n4l, _c4] = request.security(syminfo.tickerid, w4_tf, f_band(close))
[n5u, n5l, _c5] = request.security(syminfo.tickerid, w5_tf, f_band(close))

// ─── 최종 값 선택 ──────────────────────────────────────
w1u = ribbon_mode ? r1u : n1u
w1l = ribbon_mode ? r1l : n1l
w2u = ribbon_mode ? r2u : n2u
w2l = ribbon_mode ? r2l : n2l
w3u = ribbon_mode ? r3u : n3u
w3l = ribbon_mode ? r3l : n3l
w4u = ribbon_mode ? r4u : n4u
w4l = ribbon_mode ? r4l : n4l
w5u = ribbon_mode ? r5u : n5u
w5l = ribbon_mode ? r5l : n5l

// ─── 플롯 ──────────────────────────────────────────────
plot(show_all and w1_on ? w1u : na, "Wave 1 상단", color=w1_col, linewidth=2)
plot(show_all and w1_on ? w1l : na, "Wave 1 하단", color=w1_col, linewidth=2)

plot(show_all and w2_on ? w2u : na, "Wave 2 상단", color=w2_col, linewidth=2)
plot(show_all and w2_on ? w2l : na, "Wave 2 하단", color=w2_col, linewidth=2)

plot(show_all and w3_on ? w3u : na, "Wave 3 상단", color=w3_col, linewidth=2)
plot(show_all and w3_on ? w3l : na, "Wave 3 하단", color=w3_col, linewidth=2)

plot(show_all and w4_on ? w4u : na, "Wave 4 상단", color=w4_col, linewidth=2)
plot(show_all and w4_on ? w4l : na, "Wave 4 하단", color=w4_col, linewidth=2)

plot(show_all and w5_on ? w5u : na, "Wave 5 상단", color=w5_col, linewidth=2)
plot(show_all and w5_on ? w5l : na, "Wave 5 하단", color=w5_col, linewidth=2)
````
