//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Sadukey"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Sadukey"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen,clrSandyBrown
#property indicator_width1  5

double valo[],valc[],valh[],vall[],valcl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,valo,INDICATOR_DATA);
   SetIndexBuffer(1,valh,INDICATOR_DATA);
   SetIndexBuffer(2,vall,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_DATA);
   SetIndexBuffer(4,valcl,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Sadukey");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,65); for(; i<rates_total && !_StopFlag; i++)
     {
      valh[i]=0.11859648*((open[i-0]+close[i-0]+high[i-0]+low[i-0])/4+close[i-0])/2
              +0.11781324*((open[i-1]+close[i-1]+high[i-1]+low[i-1])/4 +close[i-1])/2
              +0.11548308*((open[i-2]+close[i-2]+high[i-2]+low[i-2])/4 +close[i-2])/2
              +0.11166411*((open[i-3]+close[i-3]+high[i-3]+low[i-3])/4 +close[i-3])/2
              +0.10645106*((open[i-4]+close[i-4]+high[i-4]+low[i-4])/4 +close[i-4])/2
              +0.09997253*((open[i-5]+close[i-5]+high[i-5]+low[i-5])/4 +close[i-5])/2
              +0.09238688*((open[i-6]+close[i-6]+high[i-6]+low[i-6])/4 +close[i-6])/2
              +0.08387751*((open[i-7]+close[i-7]+high[i-7]+low[i-7])/4 +close[i-7])/2
              +0.07464713*((open[i-8]+close[i-8]+high[i-8]+low[i-8])/4 +close[i-8])/2
              +0.06491178*((open[i-9]+close[i-9]+high[i-9]+low[i-9])/4 +close[i-9])/2
              +0.05489443*((open[i-10]+close[i-10]+high[i-10]+low[i-10])/4 +close[i-10])/2
              +0.04481833*((open[i-11]+close[i-11]+high[i-11]+low[i-11])/4 +close[i-11])/2
              +0.03490071*((open[i-12]+close[i-12]+high[i-12]+low[i-12])/4 +close[i-12])/2
              +0.02534672*((open[i-13]+close[i-13]+high[i-13]+low[i-13])/4 +close[i-13])/2
              +0.01634375*((open[i-14]+close[i-14]+high[i-14]+low[i-14])/4 +close[i-14])/2
              +0.00805678*((open[i-15]+close[i-15]+high[i-15]+low[i-15])/4 +close[i-15])/2
              +0.00062421*((open[i-16]+close[i-16]+high[i-16]+low[i-16])/4 +close[i-16])/2
              -0.00584512*((open[i-17]+close[i-17]+high[i-17]+low[i-17])/4 +close[i-17])/2
              -0.01127391*((open[i-18]+close[i-18]+high[i-18]+low[i-18])/4 +close[i-18])/2
              -0.01561738*((open[i-19]+close[i-19]+high[i-19]+low[i-19])/4 +close[i-19])/2
              -0.01886307*((open[i-20]+close[i-20]+high[i-20]+low[i-20])/4 +close[i-20])/2
              -0.02102974*((open[i-21]+close[i-21]+high[i-21]+low[i-21])/4 +close[i-21])/2
              -0.02216516*((open[i-22]+close[i-22]+high[i-22]+low[i-22])/4 +close[i-22])/2
              -0.02234315*((open[i-23]+close[i-23]+high[i-23]+low[i-23])/4 +close[i-23])/2
              -0.02165992*((open[i-24]+close[i-24]+high[i-24]+low[i-24])/4 +close[i-24])/2
              -0.02022973*((open[i-25]+close[i-25]+high[i-25]+low[i-25])/4 +close[i-25])/2
              -0.01818026*((open[i-26]+close[i-26]+high[i-26]+low[i-26])/4 +close[i-26])/2
              -0.01564777*((open[i-27]+close[i-27]+high[i-27]+low[i-27])/4 +close[i-27])/2
              -0.01277219*((open[i-28]+close[i-28]+high[i-28]+low[i-28])/4 +close[i-28])/2
              -0.00969230*((open[i-29]+close[i-29]+high[i-29]+low[i-29])/4 +close[i-29])/2
              -0.00654127*((open[i-30]+close[i-30]+high[i-30]+low[i-30])/4 +close[i-30])/2
              -0.00344276*((open[i-31]+close[i-31]+high[i-31]+low[i-31])/4 +close[i-31])/2
              -0.00050728*((open[i-32]+close[i-32]+high[i-32]+low[i-32])/4 +close[i-32])/2
              +0.00217042*((open[i-33]+close[i-33]+high[i-33]+low[i-33])/4 +close[i-33])/2
              +0.00451354*((open[i-34]+close[i-34]+high[i-34]+low[i-34])/4 +close[i-34])/2
              +0.00646441*((open[i-35]+close[i-35]+high[i-35]+low[i-35])/4 +close[i-35])/2
              +0.00798513*((open[i-36]+close[i-36]+high[i-36]+low[i-36])/4 +close[i-36])/2
              +0.00905725*((open[i-37]+close[i-37]+high[i-37]+low[i-37])/4 +close[i-37])/2
              +0.00968091*((open[i-38]+close[i-38]+high[i-38]+low[i-38])/4 +close[i-38])/2
              +0.00987326*((open[i-39]+close[i-39]+high[i-39]+low[i-39])/4 +close[i-39])/2
              +0.00966639*((open[i-40]+close[i-40]+high[i-40]+low[i-40])/4 +close[i-40])/2
              +0.00910488*((open[i-41]+close[i-41]+high[i-41]+low[i-41])/4 +close[i-41])/2
              +0.00824306*((open[i-42]+close[i-42]+high[i-42]+low[i-42])/4 +close[i-42])/2
              +0.00714199*((open[i-43]+close[i-43]+high[i-43]+low[i-43])/4 +close[i-43])/2
              +0.00586655*((open[i-44]+close[i-44]+high[i-44]+low[i-44])/4 +close[i-44])/2
              +0.00448255*((open[i-45]+close[i-45]+high[i-45]+low[i-45])/4 +close[i-45])/2
              +0.00305396*((open[i-46]+close[i-46]+high[i-46]+low[i-46])/4 +close[i-46])/2
              +0.00164061*((open[i-47]+close[i-47]+high[i-47]+low[i-47])/4 +close[i-47])/2
              +0.00029596*((open[i-48]+close[i-48]+high[i-48]+low[i-48])/4 +close[i-48])/2
              -0.00093445*((open[i-49]+close[i-49]+high[i-49]+low[i-49])/4 +close[i-49])/2
              -0.00201426*((open[i-50]+close[i-50]+high[i-50]+low[i-50])/4 +close[i-50])/2
              -0.00291701*((open[i-51]+close[i-51]+high[i-51]+low[i-51])/4 +close[i-51])/2
              -0.00362661*((open[i-52]+close[i-52]+high[i-52]+low[i-52])/4 +close[i-52])/2
              -0.00413703*((open[i-53]+close[i-53]+high[i-53]+low[i-53])/4 +close[i-53])/2
              -0.00445206*((open[i-54]+close[i-54]+high[i-54]+low[i-54])/4 +close[i-54])/2
              -0.00458437*((open[i-55]+close[i-55]+high[i-55]+low[i-55])/4 +close[i-55])/2
              -0.00455457*((open[i-56]+close[i-56]+high[i-56]+low[i-56])/4 +close[i-56])/2
              -0.00439006*((open[i-57]+close[i-57]+high[i-57]+low[i-57])/4 +close[i-57])/2
              -0.00412379*((open[i-58]+close[i-58]+high[i-58]+low[i-58])/4 +close[i-58])/2
              -0.00379323*((open[i-59]+close[i-59]+high[i-59]+low[i-59])/4 +close[i-59])/2
              -0.00343966*((open[i-60]+close[i-60]+high[i-60]+low[i-60])/4 +close[i-60])/2
              -0.00310850*((open[i-61]+close[i-61]+high[i-61]+low[i-61])/4 +close[i-61])/2
              -0.00285188*((open[i-62]+close[i-62]+high[i-62]+low[i-62])/4 +close[i-62])/2
              -0.00273508*((open[i-63]+close[i-63]+high[i-63]+low[i-63])/4 +close[i-63])/2
              -0.00274361*((open[i-64]+close[i-64]+high[i-64]+low[i-64])/4 +close[i-64])/2
              +0.01018757*((open[i-65]+close[i-65]+high[i-65]+low[i-65])/4 +close[i-65])/2;

      vall[i]=0.11859648*(((open[i-0]+close[i-0]+high[i-0]+low[i-0])/4+open[i-0])/2)
              +0.11781324*(((open[i-1]+close[i-1]+high[i-1]+low[i-1])/4 +open[i-1])/2)
              +0.11548308*(((open[i-2]+close[i-2]+high[i-2]+low[i-2])/4 +open[i-2])/2)
              +0.11166411*(((open[i-3]+close[i-3]+high[i-3]+low[i-3])/4 +open[i-3])/2)
              +0.10645106*(((open[i-4]+close[i-4]+high[i-4]+low[i-4])/4 +open[i-4])/2)
              +0.09997253*(((open[i-5]+close[i-5]+high[i-5]+low[i-5])/4 +open[i-5])/2)
              +0.09238688*(((open[i-6]+close[i-6]+high[i-6]+low[i-6])/4 +open[i-6])/2)
              +0.08387751*(((open[i-7]+close[i-7]+high[i-7]+low[i-7])/4 +open[i-7])/2)
              +0.07464713*(((open[i-8]+close[i-8]+high[i-8]+low[i-8])/4 +open[i-8])/2)
              +0.06491178*(((open[i-9]+close[i-9]+high[i-9]+low[i-9])/4 +open[i-9])/2)
              +0.05489443*(((open[i-10]+close[i-10]+high[i-10]+low[i-10])/4 +open[i-10])/2)
              +0.04481833*(((open[i-11]+close[i-11]+high[i-11]+low[i-11])/4 +open[i-11])/2)
              +0.03490071*(((open[i-12]+close[i-12]+high[i-12]+low[i-12])/4 +open[i-12])/2)
              +0.02534672*(((open[i-13]+close[i-13]+high[i-13]+low[i-13])/4 +open[i-13])/2)
              +0.01634375*(((open[i-14]+close[i-14]+high[i-14]+low[i-14])/4 +open[i-14])/2)
              +0.00805678*(((open[i-15]+close[i-15]+high[i-15]+low[i-15])/4 +open[i-15])/2)
              +0.00062421*(((open[i-16]+close[i-16]+high[i-16]+low[i-16])/4 +open[i-16])/2)
              -0.00584512*(((open[i-17]+close[i-17]+high[i-17]+low[i-17])/4 +open[i-17])/2)
              -0.01127391*(((open[i-18]+close[i-18]+high[i-18]+low[i-18])/4 +open[i-18])/2)
              -0.01561738*(((open[i-19]+close[i-19]+high[i-19]+low[i-19])/4 +open[i-19])/2)
              -0.01886307*(((open[i-20]+close[i-20]+high[i-20]+low[i-20])/4 +open[i-20])/2)
              -0.02102974*(((open[i-21]+close[i-21]+high[i-21]+low[i-21])/4 +open[i-21])/2)
              -0.02216516*(((open[i-22]+close[i-22]+high[i-22]+low[i-22])/4 +open[i-22])/2)
              -0.02234315*(((open[i-23]+close[i-23]+high[i-23]+low[i-23])/4 +open[i-23])/2)
              -0.02165992*(((open[i-24]+close[i-24]+high[i-24]+low[i-24])/4 +open[i-24])/2)
              -0.02022973*(((open[i-25]+close[i-25]+high[i-25]+low[i-25])/4 +open[i-25])/2)
              -0.01818026*(((open[i-26]+close[i-26]+high[i-26]+low[i-26])/4 +open[i-26])/2)
              -0.01564777*(((open[i-27]+close[i-27]+high[i-27]+low[i-27])/4 +open[i-27])/2)
              -0.01277219*(((open[i-28]+close[i-28]+high[i-28]+low[i-28])/4 +open[i-28])/2)
              -0.00969230*(((open[i-29]+close[i-29]+high[i-29]+low[i-29])/4 +open[i-29])/2)
              -0.00654127*(((open[i-30]+close[i-30]+high[i-30]+low[i-30])/4 +open[i-30])/2)
              -0.00344276*(((open[i-31]+close[i-31]+high[i-31]+low[i-31])/4 +open[i-31])/2)
              -0.00050728*(((open[i-32]+close[i-32]+high[i-32]+low[i-32])/4 +open[i-32])/2)
              +0.00217042*(((open[i-33]+close[i-33]+high[i-33]+low[i-33])/4 +open[i-33])/2)
              +0.00451354*(((open[i-34]+close[i-34]+high[i-34]+low[i-34])/4 +open[i-34])/2)
              +0.00646441*(((open[i-35]+close[i-35]+high[i-35]+low[i-35])/4 +open[i-35])/2)
              +0.00798513*(((open[i-36]+close[i-36]+high[i-36]+low[i-36])/4 +open[i-36])/2)
              +0.00905725*(((open[i-37]+close[i-37]+high[i-37]+low[i-37])/4 +open[i-37])/2)
              +0.00968091*(((open[i-38]+close[i-38]+high[i-38]+low[i-38])/4 +open[i-38])/2)
              +0.00987326*(((open[i-39]+close[i-39]+high[i-39]+low[i-39])/4 +open[i-39])/2)
              +0.00966639*(((open[i-40]+close[i-40]+high[i-40]+low[i-40])/4 +open[i-40])/2)
              +0.00910488*(((open[i-41]+close[i-41]+high[i-41]+low[i-41])/4 +open[i-41])/2)
              +0.00824306*(((open[i-42]+close[i-42]+high[i-42]+low[i-42])/4 +open[i-42])/2)
              +0.00714199*(((open[i-43]+close[i-43]+high[i-43]+low[i-43])/4 +open[i-43])/2)
              +0.00586655*(((open[i-44]+close[i-44]+high[i-44]+low[i-44])/4 +open[i-44])/2)
              +0.00448255*(((open[i-45]+close[i-45]+high[i-45]+low[i-45])/4 +open[i-45])/2)
              +0.00305396*(((open[i-46]+close[i-46]+high[i-46]+low[i-46])/4 +open[i-46])/2)
              +0.00164061*(((open[i-47]+close[i-47]+high[i-47]+low[i-47])/4 +open[i-47])/2)
              +0.00029596*(((open[i-48]+close[i-48]+high[i-48]+low[i-48])/4 +open[i-48])/2)
              -0.00093445*(((open[i-49]+close[i-49]+high[i-49]+low[i-49])/4 +open[i-49])/2)
              -0.00201426*(((open[i-50]+close[i-50]+high[i-50]+low[i-50])/4 +open[i-50])/2)
              -0.00291701*(((open[i-51]+close[i-51]+high[i-51]+low[i-51])/4 +open[i-51])/2)
              -0.00362661*(((open[i-52]+close[i-52]+high[i-52]+low[i-52])/4 +open[i-52])/2)
              -0.00413703*(((open[i-53]+close[i-53]+high[i-53]+low[i-53])/4 +open[i-53])/2)
              -0.00445206*(((open[i-54]+close[i-54]+high[i-54]+low[i-54])/4 +open[i-54])/2)
              -0.00458437*(((open[i-55]+close[i-55]+high[i-55]+low[i-55])/4 +open[i-55])/2)
              -0.00455457*(((open[i-56]+close[i-56]+high[i-56]+low[i-56])/4 +open[i-56])/2)
              -0.00439006*(((open[i-57]+close[i-57]+high[i-57]+low[i-57])/4 +open[i-57])/2)
              -0.00412379*(((open[i-58]+close[i-58]+high[i-58]+low[i-58])/4 +open[i-58])/2)
              -0.00379323*(((open[i-59]+close[i-59]+high[i-59]+low[i-59])/4 +open[i-59])/2)
              -0.00343966*(((open[i-60]+close[i-60]+high[i-60]+low[i-60])/4 +open[i-60])/2)
              -0.00310850*(((open[i-61]+close[i-61]+high[i-61]+low[i-61])/4 +open[i-61])/2)
              -0.00285188*(((open[i-62]+close[i-62]+high[i-62]+low[i-62])/4 +open[i-62])/2)
              -0.00273508*(((open[i-63]+close[i-63]+high[i-63]+low[i-63])/4 +open[i-63])/2)
              -0.00274361*(((open[i-64]+close[i-64]+high[i-0]+low[i-64])/4 +open[i-64])/2)
              +0.01018757*(((open[i-65]+close[i-65]+high[i-65]+low[i-65])/4 +open[i-65])/2);
      valo[i] = valh[i];
      valc[i] = vall[i];
      valcl[i]=(valh[i]>vall[i]) ? 0 : 1;
     }
   return (i);
  }
//+------------------------------------------------------------------+
