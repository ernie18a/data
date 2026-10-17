# lewisyang_V2

- url: https://www.tradingview.com/script/YvzzoxrO/
- type: indicator
- pine_id: PUB;c03c8107e76f4d81b83575cbbe470129
- version: 1.0

## Description

营业收入 (Total Revenue)： $Q0 > Q1 > Q2 > Q3$净利润 (Net Income)： $Q0 > Q1 > Q2 > Q3$净利润率 (Net Margin)： $Q0 > Q1 > Q2 > Q3$

## Source Code

````pine
//@version=5
indicator("财务三连增扫描器_V2", overlay=true)

// --- 1. 获取季度财务数据 (FQ 代表财季) ---
f_rev = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "FQ")
f_ni  = request.financial(syminfo.tickerid, "NET_INCOME", "FQ")
f_nm  = request.financial(syminfo.tickerid, "NET_MARGIN", "FQ")

// 容错处理：如果数据是 na，则当作 0 处理
nz_f(val) => na(val) ? 0 : val

// --- 2. 捕捉最近 4 个季度的数据点 ---
// 我们捕捉最近 4 次数据发生变化时的值，确保对比的是不同的财季
get_q_data(src) =>
    q0 = nz_f(src)
    q1 = nz_f(ta.valuewhen(ta.change(src), src[1], 0))
    q2 = nz_f(ta.valuewhen(ta.change(src), src[1], 1))
    q3 = nz_f(ta.valuewhen(ta.change(src), src[1], 2))
    [q0, q1, q2, q3]

[r0, r1, r2, r3] = get_q_data(f_rev)
[n0, n1, n2, n3] = get_q_data(f_ni)
[m0, m1, m2, m3] = get_q_data(f_nm)

// --- 3. 连涨判断 (本季 > 前1季 > 前2季 > 前3季) ---
rev_up = r0 > r1 and r1 > r2 and r2 > r3
ni_up  = n0 > n1 and n1 > n2 and n2 > n3 // [FIXED] 之前这里误写成了 r3
nm_up  = m0 > m1 and m1 > m2 and m2 > m3

// 最终判定
is_passed = rev_up and ni_up and nm_up

// --- 4. 导出给筛选器 (必须用 plot，筛选器才能识别这个列) ---
// 我们把通过的结果画成 1 (合格) 和 0 (淘汰)
plot(is_passed ? 1 : 0, title="财务面试结果", display=display.none)

// --- 5. 图表视觉呈现 ---
plotshape(is_passed, title="通过信号", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small)
bgcolor(is_passed ? color.new(color.green, 90) : na)
````
