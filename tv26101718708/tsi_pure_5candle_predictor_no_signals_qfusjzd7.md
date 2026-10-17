# TSI Pure 5-Candle Predictor (No Signals)

- url: https://www.tradingview.com/script/qfusJzD7/
- type: indicator
- pine_id: PUB;550fe997403f4e5a94793373818520e2
- version: 1.0

## Description

1. Trend Following Breakout (Trending Market)
Enter the market when the prediction lines become steep and long, indicating strong momentum.
Long Entry: If the price breaks above a recent resistance level and a long, steep Green prediction line appears, buy immediately.
Short Entry: If the price breaks below a key support level and a long, steep Red prediction line points downward, sell immediately.
Take Profit: Use the very end of the prediction line (the 5th candle target price, p5) as your short-term take-profit target.
2. Color Reversal Entry (Counter-Trend / Swing Trading)
Capture the exact moment when the market momentum shifts and the line color flips.
Long Target: Enter a Long position on the exact candle close where the prediction line switches from Red to Green.
Short Target: Enter a Short position on the exact candle close where the prediction line switches from Green to Red.
Stop Loss: Place your Stop Loss right below the recent swing low (for longs) or above the recent swing high (for shorts). This offers an excellent risk-to-reward ratio.
3. The 200 EMA Filter (Trend Protection)
To avoid false signals in a choppy, sideways market, combine this indicator with a major trendline like the 200-period Exponential Moving Average (EMA).
When Price is ABOVE 200 EMA: Only take Long trades when the Green prediction line appears. Completely ignore Red prediction lines (treat them as simple pullbacks, not short entries).
When Price is BELOW 200 EMA: Only take Short trades when the Red prediction line appears. Completely ignore Green prediction lines.

## Source Code

````pine
//@version=5
indicator("TSI Pure 5-Candle Predictor (No Signals)", overlay=true, max_lines_count=50)

// 1. TSI 설정 입력
tsi_long   = input.int(25, title="TSI Long Length")
tsi_short  = input.int(13, title="TSI Short Length")
tsi_signal = input.int(7, title="TSI Signal Length")

// TSI 계산
price_diff = ta.change(close)
double_smoothed_diff = ta.ema(ta.ema(price_diff, tsi_long), tsi_short)
double_smoothed_abs_diff = ta.ema(ta.ema(math.abs(price_diff), tsi_long), tsi_short)
tsi_value = 100 * (double_smoothed_diff / double_smoothed_abs_diff)
tsi_signal_line = ta.ema(tsi_value, tsi_signal)

// 2. 변동성(ATR) 기반 미래 5개 캔들 예상 폭 계산
atr = ta.atr(14)
momentum_factor = math.abs(tsi_value - tsi_signal_line) / 10.0 
predicted_move  = atr * math.max(0.5, momentum_factor)

// 3. 차트 우측 빈 공간에 향후 5개 캔들 예상 경로 그리기
var line pred_l1 = na, var line pred_l2 = na, var line pred_l3 = na, var line pred_l4 = na, var line pred_l5 = na

if barstate.islast
    // 이전 예측선 지우기
    line.delete(pred_l1), line.delete(pred_l2), line.delete(pred_l3), line.delete(pred_l4), line.delete(pred_l5)
    
    // TSI 방향성 결정 (상승/하락)
    int dir = tsi_value > tsi_signal_line ? 1 : -1
    color line_color = dir == 1 ? color.green : color.red
    
    // 현재 종가(close) 기준으로 미래 5단계 예상 가격 연산
    float p0 = close
    float p1 = close + (dir * predicted_move * 0.3)
    float p2 = close + (dir * predicted_move * 0.6)
    float p3 = close + (dir * predicted_move * 0.9)
    float p4 = close + (dir * predicted_move * 1.2)
    float p5 = close + (dir * predicted_move * 1.5)
    
    // 차트 우측에 점선으로 실시간 플롯 (+1 ~ +5 캔들 위치)
    pred_l1 := line.new(bar_index, p0, bar_index + 1, p1, xloc=xloc.bar_index, color=line_color, width=2, style=line.style_dashed)
    pred_l2 := line.new(bar_index + 1, p1, bar_index + 2, p2, xloc=xloc.bar_index, color=line_color, width=2, style=line.style_dashed)
    pred_l3 := line.new(bar_index + 2, p2, bar_index + 3, p3, xloc=xloc.bar_index, color=line_color, width=2, style=line.style_dashed)
    pred_l4 := line.new(bar_index + 3, p3, bar_index + 4, p4, xloc=xloc.bar_index, color=line_color, width=2, style=line.style_dashed)
    pred_l5 := line.new(bar_index + 4, p4, bar_index + 5, p5, xloc=xloc.bar_index, color=line_color, width=2, style=line.style_dashed)
````
