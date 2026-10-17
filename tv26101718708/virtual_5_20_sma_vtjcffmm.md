# Virtual 5 / 20 SMA

- url: https://www.tradingview.com/script/vTJcffMM/
- type: indicator
- pine_id: PUB;5d8a05a1821a4d9bbcadc07ecf859886
- version: 1.0

## Description

모든차트, 타임프레임 5,20 가상이평

## Source Code

````pine
//@version=6
indicator("Virtual 5 / 20 SMA", overlay=true, max_bars_back=20)

// 가상 SMA 함수
f_virtual_sma(src, len) =>
    float sum = 0.0
    int count = math.min(bar_index + 1, len)

    for i = 0 to len - 1
        if i < count
            sum += src[i]

    sum / count

vma5  = f_virtual_sma(close, 5)
vma20 = f_virtual_sma(close, 20)

plot(vma5,  title="Virtual 5 SMA",  linewidth=2)
plot(vma20, title="Virtual 20 SMA", linewidth=2)
````
