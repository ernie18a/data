【通用】ATR=ATR(14)。EMA20=close的20期EMA。偏多環境=close>=EMA20 或 EMA20>EMA20[3]。偏空環境=close<EMA20 且 EMA20<EMA20[3]。做空時先把序列鏡像：h=-low、l=-high、c=-close，再套用做多公式。

【一、圓弧底做多／圓弧頂做空】用長度len=36、55、80、120、180、260、420逐一檢查，任一個成立即可。
1. edge=max(4,round(0.16*len))。inner=max(12,len-2*edge)。bottom=l在[edge,edge+inner-1]根前的最小值，bottomOff為該根距今根數。
2. minArm=max(5,round(0.06*len))。maxArm=max(minArm+4,round(0.62*len))。
3. 左緣leftRim=h在[bottomOff+minArm,min(len-1,bottomOff+maxArm)]的最大值。右緣區間為[max(0,bottomOff-maxArm),bottomOff-minArm]。rightRim=此區間h最大值。matchedRim=此區間內最接近leftRim的h。
4. depth=leftRim-bottom。depth/|leftRim|須在6%~75%。bottomPos=bottomOff/(len-1)*100須在18~82。
5. completion=clamp((rightRim-bottom)/depth*100,0,100)，須>=40。若completion>=88，須|leftRim-matchedRim|/depth*100<=46。
6. U形取樣：k=0..20，idx=round(k/20*(len-1))。span在idx>=bottomOff時取len-1-bottomOff，否則取bottomOff。norm=clamp(|idx-bottomOff|/span,0,1)。ideal=bottom+depth*norm^2。c[idx]落在ideal±0.40*depth內算命中。命中率須>=45%。c[idx]<=bottom+0.28*depth的比例（底寬）須>=9%。
7. 臂段：armSeg=max(3,round(0.08*len))。leftArm、centerArm、rightArm分別為c[round(0.72*len)]、c[round(0.46*len)]、c[round(0.18*len)]的armSeg期SMA。leftLift=leftArm-centerArm。rightLift=rightArm-centerArm。兩者都須>=0.10*depth。做空時min(leftLift,rightLift)須>=0.18*depth。
8. 現價：(c-bottom)/depth*100>=58。c>=EMA(c,clamp(armSeg,4,12))-0.15*ATR。
9. 目標未達：neck+depth>c+0.1*ATR，其中neck=leftRim。

以上全成立即成立。做多：偏空環境下的圓弧底仍可做多，成立即可。做空：圓弧頂須成立，且為偏空環境（close<EMA20 且 EMA20<EMA20[3]），並在鏡像序列上通過全部條件。若close>=EMA20 或 EMA20>EMA20[3]則不做空。

進場價（兩方向皆須通過風險過濾）：
- 早期（completion<88）：用pivotlow(l,左3右2)得最近波段低點S。須bottom<S<neck，且S形成後不超過max(6,round(0.18*len))根。entry=S+0.15*ATR，stop=S-0.70*ATR，|c-entry|/ATR<=1.35。
- 完成後（completion>=88）：做多在c>=neck+0.08*ATR時進場。stop=min(neck-0.72*ATR,最近6根最低-0.18*ATR)。做空鏡像：c<=neck-0.08*ATR，stop=max(neck+0.72*ATR,最近6根最高+0.18*ATR)。
- 回測：突破後1~20根內，做多在low<=neck*(1+1.8%)且close>=neck*(1-1.8%)時進場。stop=最近fastSupportLen=max(3,min(12,round(0.06*len)))根最低-0.45*ATR。做空鏡像。突破定義為做多close>neck*1.0015，做空close<neck*0.9985。
- 風險過濾：|entry-stop|/entry<=4.5%，且|entry-stop|<=3*ATR，且stop在進場價的反側。

出場：
- 做多：close<bottom-0.25*ATR。或close>=目標neck+depth。或觸及stop。或close<EMA20 且 EMA20<=EMA20[3] 且 close<EMA50 且 close<neck-0.2*ATR。
- 做空：close>極值（圓弧頂最高點）+0.25*ATR。或close<=目標neck-depth。或觸及stop。或close>EMA20 且 EMA20>=EMA20[3] 且 close>EMA50 且 close>neck+0.2*ATR。

【二、雙底做多／雙頂做空】pivotlow(low,3,3)取最近兩個低點P1（舊）、P2（新）。雙頂用pivothigh，鏡像處理。
1. 兩點相距8~100根。|P1-P2|/((P1+P2)/2)<=8%。
2. neck=兩點間的最高high（雙頂為最低low）。height=neck-min(P1,P2)>=2*ATR。
3. 每個樞紐的寬度=其前後各10根內，low<=樞紐+0.22*(neck-樞紐)的根數。寬度須<=5或>=7，6不算。
4. completion=(close-min(P1,P2))/height*100，限制在0~100，須>=48。
5. P2距今根數<=max(4,round(0.55*相距根數))。最近min(12,P2距今根數+1)根的最低low>=P2-0.2*ATR。
6. 目標neck+height>close+0.1*ATR。

全成立則做多。雙頂鏡像（completion=(extreme-close)/height，P2以high判斷）為做空，且須為偏空環境。
進場：|close-P2|/ATR<=1.35且未突破時進場，stop=P2∓0.70*ATR（做多減，做空加）。突破後回測neck進場，stop=最近6根最低-0.45*ATR（做空為最高+0.45*ATR）。
出場：close反向穿越P2極值0.25*ATR，或到達目標neck±height，或觸及stop。