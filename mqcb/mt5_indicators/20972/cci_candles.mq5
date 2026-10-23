//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI candles"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "cci"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrSandyBrown

input int  inpCciPeriod = 32;  // CCI period
                               //
//--- indicator buffers
//

double ccio[],ccih[],ccil[],ccic[],ccicl[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,ccio,INDICATOR_DATA);
   SetIndexBuffer(1,ccih,INDICATOR_DATA);
   SetIndexBuffer(2,ccil,INDICATOR_DATA);
   SetIndexBuffer(3,ccic,INDICATOR_DATA);
   SetIndexBuffer(4,ccicl,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI candles ("+(string)inpCciPeriod+")");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);

//
//---
//

   double _cci[4];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double avgh=0,avgl=0,avgo=0,avgc=0;
      for(int k=0; k<inpCciPeriod && (i-k)>=0; k++)
        {
         avgh += high[i-k];
         avgl += low[i-k];
         avgo += open[i-k];
         avgc += close[i-k];
        }
      avgh /= inpCciPeriod;
      avgl /= inpCciPeriod;
      avgo /= inpCciPeriod;
      avgc /= inpCciPeriod;
      double devh=0,devl=0,devo=0,devc=0;
      for(int k=0; k<inpCciPeriod && (i-k)>=0; k++)
        {
         devh += MathAbs(high[i-k] -avgh);
         devl += MathAbs(low[i-k]  -avgl);
         devo += MathAbs(open[i-k] -avgo);
         devc += MathAbs(close[i-k]-avgc);
        }
      devh /= inpCciPeriod;
      devl /= inpCciPeriod;
      devo /= inpCciPeriod;
      devc /= inpCciPeriod;

      //
      //---
      //

      _cci[0]=(devh!=0) ?(high[i] -avgh)/(0.015*devh) : 0;
      _cci[1]=(devl!=0) ?(low[i]  -avgl)/(0.015*devl) : 0;
      _cci[2]=(devo!=0) ?(open[i] -avgo)/(0.015*devo) : 0;
      _cci[3]=(devc!=0) ?(close[i]-avgc)/(0.015*devc) : 0;
      ccio[i] = _cci[2];
      ccic[i] = _cci[3];
      ccih[i] = _cci[ArrayMaximum(_cci,0,4)];
      ccil[i] = _cci[ArrayMinimum(_cci,0,4)];
      ccicl[i]=(ccic[i]>ccio[i]) ? 1 :(ccic[i]<ccio[i]) ? 2 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
