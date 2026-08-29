<!-- tradingview-pine-id: PUB;m00hCBYMo14LVqq5wau6xKKEj2PUEEwM -->
<!-- tradingviewscripts-format: 1 -->
# Volume Scale by Price (VSP)

Source: https://www.tradingview.com/script/2CV729ZY/

## Description

Volume Scale by Price (VSP) show volume of bar in y-axis (price-axis) with options below:

1. Number of histogram
* Number of histogram = 0 => do not plot volume histogram
* Number of histogram = 1 => plot volume of 21 lasted bar (bar [0] to bar [20])
* Number of histogram = 2 => plot volume of 21 bar next histogram 1 (bar [20] to bar [40])

2. Line width
* Columns width of histogram

3. Volume scale ratio
* Scaling histogram with justifiable ratio depend on time frame and symbol

4. Histogram color
* Color of histogram

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © inno14

//@version=4
study("Volume Scale by Price (VSP)", overlay=true)

num_hist=input(2,minval=0,maxval=2,title="Number of histogram")
vol_size=input(10,minval=2,title="Line width")


//===Ratio===\\
vol_ratio=input(0.2,title="Volume scale ratio",minval=0.01,step=0.01)
dt=time[1]-time[2]
const=volume[1]*vol_ratio

//===Buy Color===\\
vol_col_buy_inpt=input(title="Histogram Buy Color", defval="green", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","red","silver","teal","white","yellow"])
transp_inpt=65
vol_col_buy= 
       vol_col_buy_inpt=="aqua"?color.new(color.aqua,transp_inpt):
       vol_col_buy_inpt=="black"?color.new(color.black,transp_inpt):
       vol_col_buy_inpt=="blue"?color.new(color.blue,transp_inpt):
       vol_col_buy_inpt=="fuchsia"?color.new(color.fuchsia,transp_inpt):
       vol_col_buy_inpt=="gray"?color.new(color.gray,transp_inpt):
       vol_col_buy_inpt=="green"?color.new(color.green,transp_inpt):
       vol_col_buy_inpt=="lime"?color.new(color.lime,transp_inpt):
       vol_col_buy_inpt=="maroon"?color.new(color.maroon,transp_inpt):
       vol_col_buy_inpt=="navy"?color.new(color.navy,transp_inpt):
       vol_col_buy_inpt=="olive"?color.new(color.olive,transp_inpt):
       vol_col_buy_inpt=="orange"?color.new(color.orange,transp_inpt):
       vol_col_buy_inpt=="red"?color.new(color.red,transp_inpt):
       vol_col_buy_inpt=="silver"?color.new(color.silver,transp_inpt):
       vol_col_buy_inpt=="teal"?color.new(color.teal,transp_inpt):
       vol_col_buy_inpt=="white"?color.new(color.white,transp_inpt):
       vol_col_buy_inpt=="yellow"?color.new(color.yellow,transp_inpt):
       color.new(color.green,transp_inpt)
//===Sell Color===\\
vol_col_sell_inpt=input(title="Histogram Sell Color", defval="red", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","red","silver","teal","white","yellow"])
vol_col_sell= 
       vol_col_sell_inpt=="aqua"?color.new(color.aqua,transp_inpt):
       vol_col_sell_inpt=="black"?color.new(color.black,transp_inpt):
       vol_col_sell_inpt=="blue"?color.new(color.blue,transp_inpt):
       vol_col_sell_inpt=="fuchsia"?color.new(color.fuchsia,transp_inpt):
       vol_col_sell_inpt=="gray"?color.new(color.gray,transp_inpt):
       vol_col_sell_inpt=="green"?color.new(color.green,transp_inpt):
       vol_col_sell_inpt=="lime"?color.new(color.lime,transp_inpt):
       vol_col_sell_inpt=="maroon"?color.new(color.maroon,transp_inpt):
       vol_col_sell_inpt=="navy"?color.new(color.navy,transp_inpt):
       vol_col_sell_inpt=="olive"?color.new(color.olive,transp_inpt):
       vol_col_sell_inpt=="orange"?color.new(color.orange,transp_inpt):
       vol_col_sell_inpt=="red"?color.new(color.red,transp_inpt):
       vol_col_sell_inpt=="silver"?color.new(color.silver,transp_inpt):
       vol_col_sell_inpt=="teal"?color.new(color.teal,transp_inpt):
       vol_col_sell_inpt=="white"?color.new(color.white,transp_inpt):
       vol_col_sell_inpt=="yellow"?color.new(color.yellow,transp_inpt):
       color.new(color.red,transp_inpt)
doji_col=color.new(color.black,transp_inpt)
//Hist 1
if(num_hist>=1)
//Anchor 1
    xloc_anchor_1=time[1]+2*dt

//Volume scale
    v0=round(volume[0]/const)
    v1=round(volume[1]/const)
    v2=round(volume[2]/const)
    v3=round(volume[3]/const)
    v4=round(volume[4]/const)
    v5=round(volume[5]/const)
    v6=round(volume[6]/const)
    v7=round(volume[7]/const)
    v8=round(volume[8]/const)
    v9=round(volume[9]/const)
    v10=round(volume[10]/const)
    v11=round(volume[11]/const)
    v12=round(volume[12]/const)
    v13=round(volume[13]/const)
    v14=round(volume[14]/const)
    v15=round(volume[15]/const)
    v16=round(volume[16]/const)
    v17=round(volume[17]/const)
    v18=round(volume[18]/const)
    v19=round(volume[19]/const)
    v20=round(volume[20]/const)

//===Volume length\\
    xloc_0=time[1]-v0*dt
    xloc_1=time[1]-v1*dt
    xloc_2=time[1]-v2*dt
    xloc_3=time[1]-v3*dt
    xloc_4=time[1]-v4*dt
    xloc_5=time[1]-v5*dt
    xloc_6=time[1]-v6*dt
    xloc_7=time[1]-v7*dt
    xloc_8=time[1]-v8*dt
    xloc_9=time[1]-v9*dt
    xloc_10=time[1]-v10*dt
    xloc_11=time[1]-v11*dt
    xloc_12=time[1]-v12*dt
    xloc_13=time[1]-v13*dt
    xloc_14=time[1]-v14*dt
    xloc_15=time[1]-v15*dt
    xloc_16=time[1]-v16*dt
    xloc_17=time[1]-v17*dt
    xloc_18=time[1]-v18*dt
    xloc_19=time[1]-v19*dt
    xloc_20=time[1]-v20*dt


//===Plot Volume Scale by Price (VSP)\\
    l0 = line.new(xloc_anchor_1, close[0], xloc_0, close[0], width = vol_size, color=close[0]>close[1]?vol_col_buy:close[0]<close[1]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l0[1])

    l1 = line.new(xloc_anchor_1, close[1], xloc_1, close[1], width = vol_size, color=close[1]>close[2]?vol_col_buy:close[1]<close[2]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l1[1])

    l2 = line.new(xloc_anchor_1, close[2], xloc_2, close[2], width = vol_size, color=close[2]>close[3]?vol_col_buy:close[2]<close[3]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l2[1])

    l3 = line.new(xloc_anchor_1, close[3], xloc_3, close[3], width = vol_size, color=close[3]>close[4]?vol_col_buy:close[3]<close[4]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l3[1])

    l4 = line.new(xloc_anchor_1, close[4], xloc_4, close[4], width = vol_size, color=close[4]>close[5]?vol_col_buy:close[4]<close[5]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l4[1])

    l5 = line.new(xloc_anchor_1, close[5], xloc_5, close[5], width = vol_size, color=close[5]>close[6]?vol_col_buy:close[5]<close[6]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l5[1])

    l6 = line.new(xloc_anchor_1, close[6], xloc_6, close[6], width = vol_size, color=close[6]>close[7]?vol_col_buy:close[6]<close[7]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l6[1])

    l7 = line.new(xloc_anchor_1, close[7], xloc_7, close[7], width = vol_size, color=close[7]>close[8]?vol_col_buy:close[7]<close[8]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l7[1])

    l8 = line.new(xloc_anchor_1, close[8], xloc_8, close[8], width = vol_size, color=close[8]>close[9]?vol_col_buy:close[8]<close[9]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l8[1])

    l9 = line.new(xloc_anchor_1, close[9], xloc_9, close[9], width = vol_size, color=close[9]>close[10]?vol_col_buy:close[9]<close[10]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l9[1])

    l10 = line.new(xloc_anchor_1, close[10], xloc_10, close[10], width = vol_size, color=close[10]>close[11]?vol_col_buy:close[10]<close[11]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l10[1])

    l11 = line.new(xloc_anchor_1, close[11], xloc_11, close[11], width = vol_size, color=close[11]>close[12]?vol_col_buy:close[11]<close[12]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l11[1])

    l12 = line.new(xloc_anchor_1, close[12], xloc_12, close[12], width = vol_size, color=close[12]>close[133]?vol_col_buy:close[12]<close[13]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l12[1])

    l13 = line.new(xloc_anchor_1, close[13], xloc_13, close[13], width = vol_size, color=close[13]>close[14]?vol_col_buy:close[13]<close[14]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l13[1])

    l14 = line.new(xloc_anchor_1, close[14], xloc_14, close[14], width = vol_size, color=close[14]>close[15]?vol_col_buy:close[14]<close[15]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l14[1])

    l15 = line.new(xloc_anchor_1, close[15], xloc_15, close[15], width = vol_size, color=close[15]>close[16]?vol_col_buy:close[15]<close[16]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l15[1])

    l16 = line.new(xloc_anchor_1, close[16], xloc_16, close[16], width = vol_size, color=close[16]>close[17]?vol_col_buy:close[16]<close[17]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l16[1])

    l17 = line.new(xloc_anchor_1, close[17], xloc_17, close[17], width = vol_size, color=close[17]>close[18]?vol_col_buy:close[17]<close[18]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l17[1])

    l18 = line.new(xloc_anchor_1, close[18], xloc_18, close[18], width = vol_size, color=close[18]>close[1]?vol_col_buy:close[18]<close[19]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l18[1])

    l19 = line.new(xloc_anchor_1, close[19], xloc_19, close[19], width = vol_size, color=close[19]>close[19]?vol_col_buy:close[19]<close[20]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l19[1])

    l20 = line.new(xloc_anchor_1, close[20], xloc_20, close[20], width = vol_size, color=close[20]>close[20]?vol_col_buy:close[20]<close[21]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l20[1])

//Hist 2
if(num_hist==2)
//Anchor 2
    xloc_anchor_2=time[20]

//Volume scale
    v0_2=round(volume[20]/const)
    v1_2=round(volume[21]/const)
    v2_2=round(volume[22]/const)
    v3_2=round(volume[23]/const)
    v4_2=round(volume[24]/const)
    v5_2=round(volume[25]/const)
    v6_2=round(volume[26]/const)
    v7_2=round(volume[27]/const)
    v8_2=round(volume[28]/const)
    v9_2=round(volume[29]/const)
    v10_2=round(volume[30]/const)
    v11_2=round(volume[31]/const)
    v12_2=round(volume[32]/const)
    v13_2=round(volume[33]/const)
    v14_2=round(volume[34]/const)
    v15_2=round(volume[35]/const)
    v16_2=round(volume[36]/const)
    v17_2=round(volume[37]/const)
    v18_2=round(volume[38]/const)
    v19_2=round(volume[39]/const)
    v20_2=round(volume[40]/const)

//===Volume length\\
    xloc_0_2=time[20]-v0_2*dt
    xloc_1_2=time[20]-v1_2*dt
    xloc_2_2=time[20]-v2_2*dt
    xloc_3_2=time[20]-v3_2*dt
    xloc_4_2=time[20]-v4_2*dt
    xloc_5_2=time[20]-v5_2*dt
    xloc_6_2=time[20]-v6_2*dt
    xloc_7_2=time[20]-v7_2*dt
    xloc_8_2=time[20]-v8_2*dt
    xloc_9_2=time[20]-v9_2*dt
    xloc_10_2=time[20]-v10_2*dt
    xloc_11_2=time[20]-v11_2*dt
    xloc_12_2=time[20]-v12_2*dt
    xloc_13_2=time[20]-v13_2*dt
    xloc_14_2=time[20]-v14_2*dt
    xloc_15_2=time[20]-v15_2*dt
    xloc_16_2=time[20]-v16_2*dt
    xloc_17_2=time[20]-v17_2*dt
    xloc_18_2=time[20]-v18_2*dt
    xloc_19_2=time[20]-v19_2*dt
    xloc_20_2=time[20]-v20_2*dt

//===Plot Volume Scale by Price (VSP)\\
    l0_2 = line.new(xloc_anchor_2, close[20], xloc_0_2, close[20], width = vol_size, color=close[20]>close[21]?vol_col_buy:close[20]<close[21]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l0_2[1])

    l1_2 = line.new(xloc_anchor_2, close[21], xloc_1_2, close[21], width = vol_size, color=close[21]>close[22]?vol_col_buy:close[21]<close[22]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l1_2[1])

    l2_2 = line.new(xloc_anchor_2, close[22], xloc_2_2, close[22], width = vol_size, color=close[22]>close[23]?vol_col_buy:close[22]<close[23]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l2_2[1])

    l3_2 = line.new(xloc_anchor_2, close[23], xloc_3_2, close[23], width = vol_size, color=close[23]>close[24]?vol_col_buy:close[23]<close[24]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l3_2[1])

    l4_2 = line.new(xloc_anchor_2, close[24], xloc_4_2, close[24], width = vol_size, color=close[24]>close[25]?vol_col_buy:close[24]<close[25]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l4_2[1])

    l5_2 = line.new(xloc_anchor_2, close[25], xloc_5_2, close[25], width = vol_size, color=close[25]>close[26]?vol_col_buy:close[25]<close[26]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l5_2[1])

    l6_2 = line.new(xloc_anchor_2, close[26], xloc_6_2, close[26], width = vol_size, color=close[26]>close[27]?vol_col_buy:close[26]<close[27]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l6_2[1])

    l7_2 = line.new(xloc_anchor_2, close[27], xloc_7_2, close[27], width = vol_size, color=close[27]>close[28]?vol_col_buy:close[27]<close[28]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l7_2[1])

    l8_2 = line.new(xloc_anchor_2, close[28], xloc_8_2, close[28], width = vol_size, color=close[28]>close[29]?vol_col_buy:close[28]<close[29]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l8_2[1])

    l9_2 = line.new(xloc_anchor_2, close[29], xloc_9_2, close[29], width = vol_size, color=close[29]>close[30]?vol_col_buy:close[29]<close[30]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l9_2[1])

    l10_2 = line.new(xloc_anchor_2, close[30], xloc_10_2, close[30], width = vol_size, color=close[30]>close[31]?vol_col_buy:close[30]<close[31]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l10_2[1])

    l11_2 = line.new(xloc_anchor_2, close[31], xloc_11_2, close[31], width = vol_size, color=close[31]>close[32]?vol_col_buy:close[31]<close[32]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l11_2[1])

    l12_2 = line.new(xloc_anchor_2, close[32], xloc_12_2, close[32], width = vol_size, color=close[32]>close[33]?vol_col_buy:close[32]<close[33]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l12_2[1])

    l13_2 = line.new(xloc_anchor_2, close[33], xloc_13_2, close[33], width = vol_size, color=close[33]>close[34]?vol_col_buy:close[33]<close[34]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l13_2[1])

    l14_2 = line.new(xloc_anchor_2, close[34], xloc_14_2, close[34], width = vol_size, color=close[34]>close[35]?vol_col_buy:close[34]<close[35]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l14_2[1])

    l15_2 = line.new(xloc_anchor_2, close[35], xloc_15_2, close[35], width = vol_size, color=close[35]>close[36]?vol_col_buy:close[35]<close[36]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l15_2[1])

    l16_2 = line.new(xloc_anchor_2, close[36], xloc_16_2, close[36], width = vol_size, color=close[36]>close[37]?vol_col_buy:close[36]<close[37]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l16_2[1])

    l17_2 = line.new(xloc_anchor_2, close[37], xloc_17_2, close[37], width = vol_size, color=close[37]>close[38]?vol_col_buy:close[37]<close[38]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l17_2[1])

    l18_2 = line.new(xloc_anchor_2, close[38], xloc_18_2, close[38], width = vol_size, color=close[38]>close[39]?vol_col_buy:close[38]<close[39]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l18_2[1])

    l19_2 = line.new(xloc_anchor_2, close[39], xloc_19_2, close[39], width = vol_size, color=close[39]>close[40]?vol_col_buy:close[39]<close[40]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l19_2[1])

    l20_2 = line.new(xloc_anchor_2, close[40], xloc_20_2, close[40], width = vol_size, color=close[40]>close[41]?vol_col_buy:close[40]<close[41]?vol_col_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l20_2[1])

//Multi Time Frame Mode - Only 18 bar (limited by security function)
tf_tt=input(true,title="To enable MTF Mode, adjust No. histograms <= 1")
tf_st=input(title="Multi Time Frame Mode", defval="disable", options=["disable","enable"])
tf_inpt=input(title="MTF Time Frame", defval="H4", options=["M5","M15","M30","H1","H4"])

//===Buy Color===\\
vol_col_inpt_tf_buy=input(title="MTF Histogram Buy Color", defval="blue", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","red","silver","teal","white","yellow"])
transp_inpt_tf=60
vol_col_tf_buy= 
       vol_col_inpt_tf_buy=="aqua"?color.new(color.aqua,transp_inpt_tf):
       vol_col_inpt_tf_buy=="black"?color.new(color.black,transp_inpt_tf):
       vol_col_inpt_tf_buy=="blue"?color.new(color.blue,transp_inpt_tf):
       vol_col_inpt_tf_buy=="fuchsia"?color.new(color.fuchsia,transp_inpt_tf):
       vol_col_inpt_tf_buy=="gray"?color.new(color.gray,transp_inpt_tf):
       vol_col_inpt_tf_buy=="green"?color.new(color.green,transp_inpt_tf):
       vol_col_inpt_tf_buy=="lime"?color.new(color.lime,transp_inpt_tf):
       vol_col_inpt_tf_buy=="maroon"?color.new(color.maroon,transp_inpt_tf):
       vol_col_inpt_tf_buy=="navy"?color.new(color.navy,transp_inpt_tf):
       vol_col_inpt_tf_buy=="olive"?color.new(color.olive,transp_inpt_tf):
       vol_col_inpt_tf_buy=="orange"?color.new(color.orange,transp_inpt_tf):
       vol_col_inpt_tf_buy=="red"?color.new(color.red,transp_inpt_tf):
       vol_col_inpt_tf_buy=="silver"?color.new(color.silver,transp_inpt_tf):
       vol_col_inpt_tf_buy=="teal"?color.new(color.teal,transp_inpt_tf):
       vol_col_inpt_tf_buy=="white"?color.new(color.white,transp_inpt_tf):
       vol_col_inpt_tf_buy=="yellow"?color.new(color.yellow,transp_inpt_tf):
       color.new(color.blue,transp_inpt_tf)
//===Sell Color===\\
vol_col_inpt_tf_sell=input(title="MTF Histogram Sell Color", defval="orange", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","red","silver","teal","white","yellow"])
vol_col_tf_sell= 
       vol_col_inpt_tf_sell=="aqua"?color.new(color.aqua,transp_inpt_tf):
       vol_col_inpt_tf_sell=="black"?color.new(color.black,transp_inpt_tf):
       vol_col_inpt_tf_sell=="blue"?color.new(color.blue,transp_inpt_tf):
       vol_col_inpt_tf_sell=="fuchsia"?color.new(color.fuchsia,transp_inpt_tf):
       vol_col_inpt_tf_sell=="gray"?color.new(color.gray,transp_inpt_tf):
       vol_col_inpt_tf_sell=="green"?color.new(color.green,transp_inpt_tf):
       vol_col_inpt_tf_sell=="lime"?color.new(color.lime,transp_inpt_tf):
       vol_col_inpt_tf_sell=="maroon"?color.new(color.maroon,transp_inpt_tf):
       vol_col_inpt_tf_sell=="navy"?color.new(color.navy,transp_inpt_tf):
       vol_col_inpt_tf_sell=="olive"?color.new(color.olive,transp_inpt_tf):
       vol_col_inpt_tf_sell=="orange"?color.new(color.orange,transp_inpt_tf):
       vol_col_inpt_tf_sell=="red"?color.new(color.red,transp_inpt_tf):
       vol_col_inpt_tf_sell=="silver"?color.new(color.silver,transp_inpt_tf):
       vol_col_inpt_tf_sell=="teal"?color.new(color.teal,transp_inpt_tf):
       vol_col_inpt_tf_sell=="white"?color.new(color.white,transp_inpt_tf):
       vol_col_inpt_tf_sell=="yellow"?color.new(color.yellow,transp_inpt_tf):
       color.new(color.orange,transp_inpt_tf)
//MTF - Multi Time Frame Calc
tf_val=
       tf_inpt=="M5"?"5":
       tf_inpt=="M15"?"15":
       tf_inpt=="M30"?"30":
       tf_inpt=="H1"?"60":
       tf_inpt=="H4"?"240":
       "240"

const_mtf=const

volume_tf(i)=>
    volume_tf=
       security(syminfo.tickerid,tf_val,volume[i])

volume_val_0=volume_tf(0)
volume_val_1=volume_tf(1)
volume_val_2=volume_tf(2)
volume_val_3=volume_tf(3)
volume_val_4=volume_tf(4)
volume_val_5=volume_tf(5)
volume_val_6=volume_tf(6)
volume_val_7=volume_tf(7)
volume_val_8=volume_tf(8)
volume_val_9=volume_tf(9)
volume_val_10=volume_tf(10)
volume_val_11=volume_tf(11)
volume_val_12=volume_tf(12)
volume_val_13=volume_tf(13)
volume_val_14=volume_tf(14)
volume_val_15=volume_tf(15)
volume_val_16=volume_tf(16)
volume_val_17=volume_tf(17)
volume_val_18=volume_tf(18)


close_tf(i)=>
    close_tf=
       security(syminfo.tickerid,tf_val,close[i])

close_val_0=close_tf(0)
close_val_1=close_tf(1)
close_val_2=close_tf(2)
close_val_3=close_tf(3)
close_val_4=close_tf(4)
close_val_5=close_tf(5)
close_val_6=close_tf(6)
close_val_7=close_tf(7)
close_val_8=close_tf(8)
close_val_9=close_tf(9)
close_val_10=close_tf(10)
close_val_11=close_tf(11)
close_val_12=close_tf(12)
close_val_13=close_tf(13)
close_val_14=close_tf(14)
close_val_15=close_tf(15)
close_val_16=close_tf(16)
close_val_17=close_tf(17)
close_val_18=close_tf(18)
close_val_19=close_tf(19)

label_yloc_tf(l)=>
    label_yloc_tf=
       security(syminfo.tickerid,tf_val,lowest(low,l)-abs(close-open)*0.5)

label_TF_yloc=label_yloc_tf(18)

if(tf_st=="enable")
//Anchor 1
    xloc_anchor_tf=time[1]+2*dt

//Volume scale Multi Time Frame
    v0_tf=round(volume_val_0/const_mtf)
    v1_tf=round(volume_val_1/const_mtf)
    v2_tf=round(volume_val_2/const_mtf)
    v3_tf=round(volume_val_3/const_mtf)
    v4_tf=round(volume_val_4/const_mtf)
    v5_tf=round(volume_val_5/const_mtf)
    v6_tf=round(volume_val_6/const_mtf)
    v7_tf=round(volume_val_7/const_mtf)
    v8_tf=round(volume_val_8/const_mtf)
    v9_tf=round(volume_val_9/const_mtf)
    v10_tf=round(volume_val_10/const_mtf)
    v11_tf=round(volume_val_11/const_mtf)
    v12_tf=round(volume_val_12/const_mtf)
    v13_tf=round(volume_val_13/const_mtf)
    v14_tf=round(volume_val_14/const_mtf)
    v15_tf=round(volume_val_15/const_mtf)
    v16_tf=round(volume_val_16/const_mtf)
    v17_tf=round(volume_val_17/const_mtf)
    v18_tf=round(volume_val_18/const_mtf)

//===Volume length\\
    xloc_0_tf=time[1]-v0_tf*dt
    xloc_1_tf=time[1]-v1_tf*dt
    xloc_2_tf=time[1]-v2_tf*dt
    xloc_3_tf=time[1]-v3_tf*dt
    xloc_4_tf=time[1]-v4_tf*dt
    xloc_5_tf=time[1]-v5_tf*dt
    xloc_6_tf=time[1]-v6_tf*dt
    xloc_7_tf=time[1]-v7_tf*dt
    xloc_8_tf=time[1]-v8_tf*dt
    xloc_9_tf=time[1]-v9_tf*dt
    xloc_10_tf=time[1]-v10_tf*dt
    xloc_11_tf=time[1]-v11_tf*dt
    xloc_12_tf=time[1]-v12_tf*dt
    xloc_13_tf=time[1]-v13_tf*dt
    xloc_14_tf=time[1]-v14_tf*dt
    xloc_15_tf=time[1]-v15_tf*dt
    xloc_16_tf=time[1]-v16_tf*dt
    xloc_17_tf=time[1]-v17_tf*dt
    xloc_18_tf=time[1]-v18_tf*dt

//===Plot Volume Scale by Price (VSP) Multi Time Frame\\
    l0_tf = line.new(xloc_anchor_tf, close_val_0, xloc_0_tf, close_val_0, width = vol_size, color=close_val_0>close_val_1?vol_col_tf_buy:close_val_0<close_val_1?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l0_tf[1])

    l1_tf = line.new(xloc_anchor_tf, close_val_1, xloc_1_tf, close_val_1, width = vol_size, color=close_val_1>close_val_2?vol_col_tf_buy:close_val_1<close_val_2?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l1_tf[1])

    l2_tf = line.new(xloc_anchor_tf, close_val_2, xloc_2_tf, close_val_2, width = vol_size, color=close_val_2>close_val_3?vol_col_tf_buy:close_val_2<close_val_3?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l2_tf[1])

    l3_tf = line.new(xloc_anchor_tf, close_val_3, xloc_3_tf, close_val_3, width = vol_size, color=close_val_3>close_val_4?vol_col_tf_buy:close_val_3<close_val_4?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l3_tf[1])

    l4_tf = line.new(xloc_anchor_tf, close_val_4, xloc_4_tf, close_val_4, width = vol_size, color=close_val_4>close_val_5?vol_col_tf_buy:close_val_4<close_val_5?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l4_tf[1])

    l5_tf = line.new(xloc_anchor_tf, close_val_5, xloc_5_tf, close_val_5, width = vol_size, color=close_val_5>close_val_6?vol_col_tf_buy:close_val_5<close_val_6?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l5_tf[1])

    l6_tf = line.new(xloc_anchor_tf, close_val_6, xloc_6_tf, close_val_6, width = vol_size, color=close_val_6>close_val_7?vol_col_tf_buy:close_val_6<close_val_7?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l6_tf[1])

    l7_tf = line.new(xloc_anchor_tf, close_val_7, xloc_7_tf, close_val_7, width = vol_size, color=close_val_7>close_val_8?vol_col_tf_buy:close_val_7<close_val_8?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l7_tf[1])

    l8_tf = line.new(xloc_anchor_tf, close_val_8, xloc_8_tf, close_val_8, width = vol_size, color=close_val_8>close_val_9?vol_col_tf_buy:close_val_8<close_val_9?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l8_tf[1])

    l9_tf = line.new(xloc_anchor_tf, close_val_9, xloc_9_tf, close_val_9, width = vol_size, color=close_val_9>close_val_10?vol_col_tf_buy:close_val_9<close_val_10?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l9_tf[1])

    l10_tf = line.new(xloc_anchor_tf, close_val_10, xloc_10_tf, close_val_10, width = vol_size, color=close_val_10>close_val_11?vol_col_tf_buy:close_val_10<close_val_11?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l10_tf[1])

    l11_tf = line.new(xloc_anchor_tf, close_val_11, xloc_11_tf, close_val_11, width = vol_size, color=close_val_11>close_val_12?vol_col_tf_buy:close_val_11<close_val_12?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l11_tf[1])

    l12_tf = line.new(xloc_anchor_tf, close_val_12, xloc_12_tf, close_val_12, width = vol_size, color=close_val_12>close_val_13?vol_col_tf_buy:close_val_12<close_val_13?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l12_tf[1])

    l13_tf = line.new(xloc_anchor_tf, close_val_13, xloc_13_tf, close_val_13, width = vol_size, color=close_val_13>close_val_14?vol_col_tf_buy:close_val_13<close_val_14?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l13_tf[1])

    l14_tf = line.new(xloc_anchor_tf, close_val_14, xloc_14_tf, close_val_14, width = vol_size, color=close_val_14>close_val_15?vol_col_tf_buy:close_val_14<close_val_15?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l14_tf[1])

    l15_tf = line.new(xloc_anchor_tf, close_val_15, xloc_15_tf, close_val_15, width = vol_size, color=close_val_15>close_val_16?vol_col_tf_buy:close_val_15<close_val_16?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l15_tf[1])

    l16_tf = line.new(xloc_anchor_tf, close_val_16, xloc_16_tf, close_val_16, width = vol_size, color=close_val_16>close_val_17?vol_col_tf_buy:close_val_16<close_val_17?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l16_tf[1])

    l17_tf = line.new(xloc_anchor_tf, close_val_17, xloc_17_tf, close_val_17, width = vol_size, color=close_val_17>close_val_18?vol_col_tf_buy:close_val_17<close_val_18?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l17_tf[1])

    l18_tf = line.new(xloc_anchor_tf, close_val_18, xloc_18_tf, close_val_18, width = vol_size, color=close_val_18>close_val_19?vol_col_tf_buy:close_val_18<close_val_19?vol_col_tf_sell:doji_col, xloc=xloc.bar_time)
    line.delete(l18_tf[1])
//Plot label MTF
    label_TF_text="■ Multi Time Frame Mode: "+tf_inpt
    label_TF_MTF = label.new(xloc_anchor_tf, label_TF_yloc, text=label_TF_text, style=label.style_none, textcolor=color.orange, size=size.large, xloc=xloc.bar_time)
    label.delete(label_TF_MTF[1])
//EOF
````
