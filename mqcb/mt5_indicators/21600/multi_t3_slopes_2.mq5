//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Multi T3 slopes"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Multi T3 slopes up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Multi T3 slopes down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_width2  2
//
//---
//
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input enT3Type           inpT3Type  = t3_fulksmat; // T3 type
input double             inpT3Hot   = 0.7;         // T3 hot 
input int                inpPeriod1 =  8; // Period 1
input int                inpPeriod2 = 11; // Period 2
input int                inpPeriod3 = 14; // Period 3
input int                inpPeriod4 = 17; // Period 4
input int                inpPeriod5 = 20; // Period 5
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

double histou[],histod[],averages[][5];
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,histou,INDICATOR_DATA); 
   SetIndexBuffer(1,histod,INDICATOR_DATA); 
   IndicatorSetString(INDICATOR_SHORTNAME,"Multi T3 slopes ("+string(inpT3Hot)+","+string(inpPeriod1)+","+string(inpPeriod2)+","+string(inpPeriod3)+","+string(inpPeriod4)+","+string(inpPeriod5)+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if (ArrayRange(averages,0)!=rates_total) ArrayResize(averages,rates_total);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      averages[i][0] = iT3(_price,inpPeriod1,inpT3Hot,inpT3Type==t3_fulksmat,i,0);
      averages[i][1] = iT3(_price,inpPeriod2,inpT3Hot,inpT3Type==t3_fulksmat,i,1);
      averages[i][2] = iT3(_price,inpPeriod3,inpT3Hot,inpT3Type==t3_fulksmat,i,2);
      averages[i][3] = iT3(_price,inpPeriod4,inpT3Hot,inpT3Type==t3_fulksmat,i,3);
      averages[i][4] = iT3(_price,inpPeriod5,inpT3Hot,inpT3Type==t3_fulksmat,i,4);
         histou[i] = histod[i] = 0;
         if (i>0)
         {
            if (averages[i][0]>averages[i-1][0]) histou[i]++;
            if (averages[i][0]<averages[i-1][0]) histod[i]--;
            if (averages[i][1]>averages[i-1][1]) histou[i]++;
            if (averages[i][1]<averages[i-1][1]) histod[i]--;
            if (averages[i][2]>averages[i-1][2]) histou[i]++;
            if (averages[i][2]<averages[i-1][2]) histod[i]--;
            if (averages[i][3]>averages[i-1][3]) histou[i]++;
            if (averages[i][3]<averages[i-1][3]) histod[i]--;
            if (averages[i][4]>averages[i-1][4]) histou[i]++;
            if (averages[i][4]<averages[i-1][4]) histod[i]--;
         }
   }      
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances     5
#define _t3InstancesSize 6
#define _t3RingSize      5
double workT3[_t3RingSize][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//
//
double iT3(double price,double period,double hot,bool original,int i, int instance=0)
{
   if(ArrayRange(workT3Coeffs,0)<(instance+1)) ArrayResize(workT3Coeffs,instance+1);
   if(workT3Coeffs[instance][_period]!=period)
   {
      workT3Coeffs[instance][_period]= period;
      workT3Coeffs[instance][_c1]    = -hot*hot*hot;
      workT3Coeffs[instance][_c2]    = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instance][_c3]    = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instance][_c4]    = 1+3*hot+hot*hot*hot+3*hot*hot;
      workT3Coeffs[instance][_alpha] = (original) ? 2.0/(1.0+period) : 2.0/(2.0+(period-1.0)/2.0);
   }
   
   //
   //
   //
   
      int _indP = (int)MathMod(i-1,_t3RingSize);
      int _indC = (int)MathMod(i  ,_t3RingSize);
      int _inst = instance*_t3InstancesSize;
   
      for(int k=0; k<_t3InstancesSize; k++) workT3[_indC][k+_inst]=(i>0) ? workT3[_indP][k+_inst]: price;
      if(i>0 && period>1)
      {
         workT3[_indC][_inst  ] = workT3[_indP][_inst  ]+workT3Coeffs[instance][_alpha]*(price                 -workT3[_indP][_inst  ]);
         workT3[_indC][_inst+1] = workT3[_indP][_inst+1]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst  ]-workT3[_indP][_inst+1]);
         workT3[_indC][_inst+2] = workT3[_indP][_inst+2]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+1]-workT3[_indP][_inst+2]);
         workT3[_indC][_inst+3] = workT3[_indP][_inst+3]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+2]-workT3[_indP][_inst+3]);
         workT3[_indC][_inst+4] = workT3[_indP][_inst+4]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+3]-workT3[_indP][_inst+4]);
         workT3[_indC][_inst+5] = workT3[_indP][_inst+5]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+4]-workT3[_indP][_inst+5]);
      }
      return(workT3Coeffs[instance][_c1]*workT3[_indC][_inst+5]+
             workT3Coeffs[instance][_c2]*workT3[_indC][_inst+4]+
             workT3Coeffs[instance][_c3]*workT3[_indC][_inst+3]+
             workT3Coeffs[instance][_c4]*workT3[_indC][_inst+2]);

   //
   //
   //
   #undef  _period
   #undef  _c1
   #undef  _c2
   #undef  _c3
   #undef  _c4
}
//
//
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