# Vegas+ EMA+ BOLL

- url: https://www.tradingview.com/script/Gk6owUPV/
- type: indicator
- pine_id: PUB;cb0467fcc2e44d19a0a86ae1ffd48de9
- version: 1.0

## Description

Vegas+EMA+BOLL
It can adjust parameters itself, control whether to display the parameters.

## Source Code

````pine
//@version=5 
indicator("Vegas通道 + EMA组 + BOLL", shorttitle="Vegas+EMA+BB", overlay=true)
                                                                                                 
// === Vegas 核心 ===
len_trigger = input.int(12,  "触发线 EMA12",   minval=1, group="Vegas核心")                      
len_fast    = input.int(144, "通道快线 EMA144", minval=1, group="Vegas核心")                     
len_slow    = input.int(169, "通道慢线 EMA169", minval=1, group="Vegas核心")                     
len_filter  = input.int(576, "长期过滤 EMA576", minval=1, group="Vegas核心")                     
show_filter = input.bool(true, "显示长期过滤线", group="Vegas核心")                              
show_signal = input.bool(true, "显示穿越信号",   group="Vegas核心")
show_bg     = input.bool(true, "通道位置背景",   group="Vegas核心")                              
                                                                  
// === 自定义 EMA 组（默认 7/26/55/100/150/200，可关可改）===                                    
show_ema1 = input.bool(false, "显示 EMA1", group="EMA组"),  len_ema1 = input.int(7,   "EMA1周期", minval=1, group="EMA组")                                                                  
show_ema2 = input.bool(false, "显示 EMA2", group="EMA组"),  len_ema2 = input.int(26,  "EMA2周期", minval=1, group="EMA组")                                                                  
show_ema3 = input.bool(false, "显示 EMA3", group="EMA组"),  len_ema3 = input.int(55,  "EMA3周期", minval=1, group="EMA组")                                                                  
show_ema4 = input.bool(false, "显示 EMA4", group="EMA组"),  len_ema4 = input.int(100, "EMA4周期", minval=1, group="EMA组")                                                                  
show_ema5 = input.bool(false, "显示 EMA5", group="EMA组"),  len_ema5 = input.int(150, "EMA5周期", minval=1, group="EMA组")                                                                  
show_ema6 = input.bool(false, "显示 EMA6", group="EMA组"),  len_ema6 = input.int(200, "EMA6周期", minval=1, group="EMA组")                                                                  
                                                                  
// === 布林带（默认关闭显示）===                                                                 
show_bb  = input.bool(false, "显示布林带",  group="布林带")       
bb_len   = input.int(20,   "BB 周期",       minval=1, group="布林带")                            
bb_src   = input.source(close, "BB 数据源", group="布林带")                                      
bb_mult  = input.float(2.0, "BB 标准差倍数", minval=0.1, step=0.1, group="布林带")               
                                                                                                 
// === 计算 ===                                                                                  
ema12  = ta.ema(close, len_trigger)                                                              
ema144 = ta.ema(close, len_fast)                                  
ema169 = ta.ema(close, len_slow)
ema576 = ta.ema(close, len_filter)                                                               
                                             
upper = math.max(ema144, ema169)                                                                 
lower = math.min(ema144, ema169)                                  
                                                                                                 
e1 = ta.ema(close, len_ema1)
e2 = ta.ema(close, len_ema2)                                                                     
e3 = ta.ema(close, len_ema3)                                      
e4 = ta.ema(close, len_ema4)                                                                     
e5 = ta.ema(close, len_ema5)
e6 = ta.ema(close, len_ema6)                                                                     
                                                                  
bb_basis = ta.sma(bb_src, bb_len)                                                                
bb_dev   = bb_mult * ta.stdev(bb_src, bb_len)
bb_upper = bb_basis + bb_dev                                                                     
bb_lower = bb_basis - bb_dev                                      
                                                                                                 
// === 画 Vegas 通道 ===                                          
p144 = plot(ema144, "EMA144", color=color.new(color.red,  0), linewidth=2)                       
p169 = plot(ema169, "EMA169", color=color.new(color.blue, 0), linewidth=2)                       
fill(p144, p169, color=color.new(color.orange, 85), title="Vegas通道")
                                                                                                 
plot(ema12, "EMA12触发线", color=color.new(color.yellow, 0), linewidth=1)                        
plot(show_filter ? ema576 : na, "EMA576过滤", color=color.new(color.gray, 0), linewidth=2)       
                                                                                                 
// === 画自定义 EMA 组 ===                                                                       
plot(show_ema1 ? e1 : na, "EMA1", color=color.new(#ef5350, 0), linewidth=1)
plot(show_ema2 ? e2 : na, "EMA2", color=color.new(#ff9800, 0), linewidth=1)                      
plot(show_ema3 ? e3 : na, "EMA3", color=color.new(#ffd600, 0), linewidth=1)                      
plot(show_ema4 ? e4 : na, "EMA4", color=color.new(#26a69a, 0), linewidth=1)                      
plot(show_ema5 ? e5 : na, "EMA5", color=color.new(#29b6f6, 0), linewidth=1)                      
plot(show_ema6 ? e6 : na, "EMA6", color=color.new(#ab47bc, 0), linewidth=2)                      
                                                                                                 
// === 画布林带 ===                                                                              
bbU = plot(show_bb ? bb_upper : na, "BB上轨", color=color.new(color.teal, 0))                    
bbM = plot(show_bb ? bb_basis : na, "BB中轨", color=color.new(color.gray, 0))                    
bbL = plot(show_bb ? bb_lower : na, "BB下轨", color=color.new(color.teal, 0))
fill(bbU, bbL, color=show_bb ? color.new(color.teal, 92) : na, title="BB填充")                   
                                                                                                 
// === 通道位置背景 ===                                                                          
bg_color = close > upper ? color.new(color.green, 92) :                                          
           close < lower ? color.new(color.red,   92) :                                          
                           color.new(color.gray,  92)
bgcolor(show_bg ? bg_color : na, title="通道位置")                                               
                                                                                                 
// === 穿越信号 ===                          
cross_up   = ta.crossover(ema12,  upper)                                                         
cross_down = ta.crossunder(ema12, lower)                          
                                                                                                 
plotshape(show_signal and cross_up,   "多头穿越", shape.triangleup,   location.belowbar,color.green, size=size.small, text="多")                                                         
plotshape(show_signal and cross_down, "空头穿越", shape.triangledown, location.abovebar,color.red,   size=size.small, text="空")                                                         
                         
// === 提醒 ===                                                                                  
alertcondition(cross_up,   "Vegas多头穿越", "EMA12上穿Vegas通道") 
alertcondition(cross_down, "Vegas空头穿越", "EMA12下穿Vegas通道")
````
