//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Multi JMA slopes"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "Multi JMA slopes up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Multi JMA slopes down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_width2  2
//
//---
//
input int                inpPeriod1 =  8; // Period 1
input int                inpPeriod2 = 11; // Period 2
input int                inpPeriod3 = 14; // Period 3
input int                inpPeriod4 = 17; // Period 4
input int                inpPeriod5 = 20; // Period 5

input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

double histou[],histod[],avg1[],avg2[],avg3[],avg4[],avg5[];
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,histou,INDICATOR_DATA); 
   SetIndexBuffer(1,histod,INDICATOR_DATA); 
   SetIndexBuffer(2,avg1,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(3,avg2,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(4,avg3,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(5,avg4,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(6,avg5,INDICATOR_CALCULATIONS); 
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Multi JMA slopes ("+string(inpPeriod1)+","+string(inpPeriod2)+","+string(inpPeriod3)+","+string(inpPeriod4)+","+string(inpPeriod5)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      avg1[i] = iSmooth(_price,inpPeriod1,0,i,0);
      avg2[i] = iSmooth(_price,inpPeriod2,0,i,1);
      avg3[i] = iSmooth(_price,inpPeriod3,0,i,2);
      avg4[i] = iSmooth(_price,inpPeriod4,0,i,3);
      avg5[i] = iSmooth(_price,inpPeriod5,0,i,4);
         histou[i] = histod[i] = 0;
         if (i>0)
         {
            if (avg1[i]>avg1[i-1]) histou[i]++;
            if (avg1[i]<avg1[i-1]) histod[i]--;
            if (avg2[i]>avg2[i-1]) histou[i]++;
            if (avg2[i]<avg2[i-1]) histod[i]--;
            if (avg3[i]>avg3[i-1]) histou[i]++;
            if (avg3[i]<avg3[i-1]) histod[i]--;
            if (avg4[i]>avg4[i-1]) histou[i]++;
            if (avg4[i]<avg4[i-1]) histod[i]--;
            if (avg5[i]>avg5[i-1]) histou[i]++;
            if (avg5[i]<avg5[i-1]) histod[i]--;
         }
   }      
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smoothInstances     5
#define _smoothInstancesSize 10
#define _smoothRingSize      11
double workSmooth[_smoothRingSize][_smoothInstances*_smoothInstancesSize];
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9
//
//
//
double iSmooth(double price, double length, double phase, int i, int instance=0)
{
   int _indP = (int)MathMod(i-1,_smoothRingSize);
   int _indC = (int)MathMod(i  ,_smoothRingSize);
   int _inst = instance*_smoothInstancesSize;

   if(i==0 || length<=1) { int k=0; for(; k<volty; k++) workSmooth[_indC][_inst+k]=price; for(; k<_smoothInstancesSize; k++) workSmooth[_indC][_inst+k]=0; return(price); }

   //
   //
   //

      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1.0)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = price - workSmooth[_indP][_inst+bsmax], absDel1 = MathAbs(del1);
      double del2 = price - workSmooth[_indP][_inst+bsmin], absDel2 = MathAbs(del2);
      int   _indF = (int)MathMod(i-MathMin(i,10),_smoothRingSize);

      workSmooth[_indC][_inst+volty]  = (absDel1 > absDel2) ? absDel1 : (absDel1 < absDel2) ? absDel2 : 0;
      workSmooth[_indC][_inst+vsum]   = workSmooth[_indP][_inst+vsum]+(workSmooth[_indC][_inst+volty]-workSmooth[_indF][_inst+volty])*0.1;
      workSmooth[_indC][_inst+avolty] = workSmooth[_indP][_inst+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(workSmooth[_indC][_inst+vsum]-workSmooth[_indP][_inst+avolty]);
      
      double dVolty    = (workSmooth[_indC][_inst+avolty]>0) ? workSmooth[_indC][_inst+volty]/workSmooth[_indC][_inst+avolty]: 0;
      double dVoltyTmp = MathPow(len1,1.0/pow1);
         if (dVolty > dVoltyTmp) dVolty = dVoltyTmp;
         if (dVolty < 1.0)       dVolty = 1.0;

      //
      //
      //

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if(del1 > 0) workSmooth[_indC][_inst+bsmax] = price; else workSmooth[_indC][_inst+bsmax] = price - Kv*del1;
         if(del2 < 0) workSmooth[_indC][_inst+bsmin] = price; else workSmooth[_indC][_inst+bsmin] = price - Kv*del2;

      //
      //
      //

      double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

          workSmooth[_indC][_inst+0] = price + alpha*(workSmooth[_indP][_inst+0]-price);
          workSmooth[_indC][_inst+1] = (price - workSmooth[_indC][_inst+0])*(1-beta) + beta*workSmooth[_indP][_inst+1];
          workSmooth[_indC][_inst+2] = (workSmooth[_indC][_inst+0] + corr*workSmooth[_indC][_inst+1]);
          workSmooth[_indC][_inst+3] = (workSmooth[_indC][_inst+2] - workSmooth[_indP][_inst+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*workSmooth[_indP][_inst+3];
          workSmooth[_indC][_inst+4] = (workSmooth[_indP][_inst+4] + workSmooth[_indC][_inst+3]);
   return(workSmooth[_indC][_inst+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
}    
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+