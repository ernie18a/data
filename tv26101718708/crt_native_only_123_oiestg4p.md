# CRT Native Only 123

- url: https://www.tradingview.com/script/oiESTg4p/
- type: indicator
- pine_id: PUB;7a57ab8d6fba48b3a469c070119d7307
- version: 1.0

## Description

//@version=6
// ── CRT 감지 함수 ──
// ── 본 차트 LTF CRT 감지 (확정봉 기준: [1]=가장 최근 확정봉) ──
// ── 라벨 그리기 ──
// ── 알림 (②/③봉이 새로 생긴 경우만) ──

## Source Code

````pine
//@version=6
indicator("CRT Native Only – 1·2·3 Icons", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════
// ── 설정 ──
// ════════════════════════════════════════════════════════════════
grp_crt = "── CRT 표시 ──"
show_crt = input.bool(true, "본 차트 CRT 1·2·3 표시", group=grp_crt)

grp_color = "── 색상 ──"
col_crt_bull  = input.color(#1B5E20, "CRT 상승 완성", group=grp_color)
col_crt_bear  = input.color(#880E4F, "CRT 하락 완성", group=grp_color)
col_stage1    = input.color(color.new(#B8860B, 30), "Stage1(①) 색", group=grp_color)
col_stage2    = input.color(color.new(#CC5500, 30), "Stage2(②) 색", group=grp_color)
col_stage3_prog = input.color(color.new(#006064, 20), "Stage3(③) 진행중 색", group=grp_color)

grp_alert = "── 알림 ──"
i_alert_s2 = input.bool(true, "②봉(S2) 발생 시 알림", group=grp_alert)
i_alert_s3 = input.bool(true, "③봉(S3/CRT) 발생 시 알림", group=grp_alert)

f_priceStr(_val) => str.tostring(_val, format.mintick)

// ════════════════════════════════════════════════════════════════
// ── CRT 감지 함수 ──
// ════════════════════════════════════════════════════════════════
detectBearCRT(_o1,_h1,_l1,_c1, _o2,_h2,_l2,_c2, _o3,_h3,_l3,_c3) =>
    _c1>=_o1 and _h2>_h1 and _c2<_h1 and _c3<_o3 and _c3<_l1

detectBullCRT(_o1,_h1,_l1,_c1, _o2,_h2,_l2,_c2, _o3,_h3,_l3,_c3) =>
    _c1<_o1 and _l2<_l1 and _c2>_l1 and _c3>=_o3 and _c3>_h1

// ════════════════════════════════════════════════════════════════
// ── 본 차트 LTF CRT 감지 (확정봉 기준: [1]=가장 최근 확정봉) ──
// ════════════════════════════════════════════════════════════════
// 3개 봉: [3]=①모봉, [2]=②돌파봉, [1]=③확인봉
float lo0 = open[1],  float lh0 = high[1],  float ll0 = low[1],  float lc0 = close[1]
float lo1 = open[2],  float lh1 = high[2],  float ll1 = low[2],  float lc1 = close[2]
float lo2 = open[3],  float lh2 = high[3],  float ll2 = low[3],  float lc2 = close[3]

bool ltf_crt_bear = detectBearCRT(lo2,lh2,ll2,lc2, lo1,lh1,ll1,lc1, lo0,lh0,ll0,lc0)
bool ltf_crt_bull = detectBullCRT(lo2,lh2,ll2,lc2, lo1,lh1,ll1,lc1, lo0,lh0,ll0,lc0)

// S2: ①모봉(양봉/음봉) + ②돌파봉이 ①의 H/L 스윕 후 내부 마감
bool ltf_s2_bear = lc1>=lo1 and lh0>lh1 and lc0<lh1
bool ltf_s2_bull = lc1<lo1  and ll0<ll1 and lc0>ll1

// S3: ②까지 형성된 상태에서 ③봉이 진행중(방향만 확인, 종가 아직 미확정 조건)
bool ltf_s3_bear = lc2>=lo2 and lh1>lh2 and lc1<lh2 and lc0<lo0
bool ltf_s3_bull = lc2<lo2  and ll1<ll2 and lc1>ll2 and lc0>=lo0

int  ltf_state = 0       // 0=없음, 3=S2 bear, 4=S2 bull, 5=S3 bear, 6=S3 bull, 7=CRT bear, 8=CRT bull
int  ltf_mIdx  = 0       // ①봉이 몇 봉 전인지 ([mIdx+1])
bool ltf_bear  = false

if ltf_crt_bear
    ltf_state := 7, ltf_mIdx := 2, ltf_bear := true
else if ltf_crt_bull
    ltf_state := 8, ltf_mIdx := 2, ltf_bear := false
else if ltf_s3_bear
    ltf_state := 5, ltf_mIdx := 2, ltf_bear := true
else if ltf_s3_bull
    ltf_state := 6, ltf_mIdx := 2, ltf_bear := false
else if ltf_s2_bear
    ltf_state := 3, ltf_mIdx := 1, ltf_bear := true
else if ltf_s2_bull
    ltf_state := 4, ltf_mIdx := 1, ltf_bear := false

// ════════════════════════════════════════════════════════════════
// ── 라벨 그리기 ──
// ════════════════════════════════════════════════════════════════
var label[] ltfLabels = array.new_label()

clearLtf() =>
    while array.size(ltfLabels) > 0
        label.delete(array.pop(ltfLabels))

drawLtfCRT() =>
    clearLtf()
    if show_crt and ltf_state >= 3
        int mBar = bar_index - (ltf_mIdx + 1)   // ①봉
        int bBar = mBar + 1                      // ②봉
        int cBar = mBar + 2                      // ③봉
        bool isCRT = ltf_state == 7 or ltf_state == 8
        bool isS3  = ltf_state == 5 or ltf_state == 6
        color stateCol = ltf_bear ? col_crt_bear : col_crt_bull

        // ① 모봉 라벨
        array.push(ltfLabels, label.new(mBar, high[ltf_mIdx + 1], "①",
             xloc=xloc.bar_index, style=label.style_label_down,
             color=color.new(col_stage1, 20), textcolor=#000000, size=size.small))

        // ② 돌파봉 라벨
        float bH_v = high[ltf_mIdx]
        float bL_v = low[ltf_mIdx]
        array.push(ltfLabels, label.new(bBar, ltf_bear ? bH_v : bL_v, "②",
             xloc=xloc.bar_index,
             style=ltf_bear ? label.style_label_down : label.style_label_up,
             color=color.new(col_stage2, 20), textcolor=#000000, size=size.small))

        // ③ 확인봉 라벨 (S3 또는 CRT 단계일 때만)
        if isS3 or isCRT
            float cH_v = high[ltf_mIdx - 1]
            float cL_v = low[ltf_mIdx - 1]
            color s3Col = isCRT ? stateCol : col_stage3_prog
            string ct = isCRT ? "③✓" : "③…"
            array.push(ltfLabels, label.new(cBar, ltf_bear ? cL_v : cH_v, ct,
                 xloc=xloc.bar_index,
                 style=ltf_bear ? label.style_label_up : label.style_label_down,
                 color=color.new(s3Col, 20), textcolor=#FFFFFF, size=size.small))

if barstate.islast
    drawLtfCRT()

// ════════════════════════════════════════════════════════════════
// ── 알림 (②/③봉이 새로 생긴 경우만) ──
// ════════════════════════════════════════════════════════════════
// 상태가 새로 바뀐 봉에서만 알림이 발사되도록 추적
var int last_s2_time = 0
var int last_s3_time = 0

bool is_s2_new = (ltf_state == 3 or ltf_state == 4)
bool is_s3_new = (ltf_state == 5 or ltf_state == 6 or ltf_state == 7 or ltf_state == 8)

// ②봉의 시간 = [ltf_mIdx] (S2일 때 mIdx=1 → time[1])
// ③봉의 시간 = [ltf_mIdx - 1] (S3/CRT일 때 mIdx=2 → time[1])
int s2_anchor_time = is_s2_new ? time[ltf_mIdx]     : 0
int s3_anchor_time = is_s3_new ? time[ltf_mIdx - 1] : 0

bool fire_s2 = i_alert_s2 and is_s2_new and barstate.isconfirmed and s2_anchor_time != last_s2_time
bool fire_s3 = i_alert_s3 and is_s3_new and barstate.isconfirmed and s3_anchor_time != last_s3_time

if fire_s2
    string dir = ltf_bear ? "▼ SHORT" : "▲ LONG"
    string msg = "②봉 발생 (S2)\n"
    msg += syminfo.ticker + "  TF: " + timeframe.period + "\n"
    msg += "방향: " + dir + "\n"
    msg += "①봉 H/L: " + f_priceStr(high[ltf_mIdx + 1]) + " / " + f_priceStr(low[ltf_mIdx + 1]) + "\n"
    msg += "현재가: " + f_priceStr(close)
    alert(msg, alert.freq_once_per_bar)
    last_s2_time := s2_anchor_time

if fire_s3
    bool isCRT = ltf_state == 7 or ltf_state == 8
    string tag = isCRT ? "③봉 확정 (CRT 완성)" : "③봉 발생 (S3 진행중)"
    string dir = ltf_bear ? "▼ SHORT" : "▲ LONG"
    string msg = tag + "\n"
    msg += syminfo.ticker + "  TF: " + timeframe.period + "\n"
    msg += "방향: " + dir + "\n"
    msg += "①봉 H/L: " + f_priceStr(high[ltf_mIdx + 1]) + " / " + f_priceStr(low[ltf_mIdx + 1]) + "\n"
    msg += "현재가: " + f_priceStr(close)
    alert(msg, alert.freq_once_per_bar)
    last_s3_time := s3_anchor_time
````
