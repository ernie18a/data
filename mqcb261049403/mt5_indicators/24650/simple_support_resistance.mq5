//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207',C'252,225,205'
#property indicator_label2  "Value"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray

//
//---
//

enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
};
input enTimeFrames  inpTimeFrame  = tf_cp1;          // Time frame
double fup[],fdn[],val[],hh[],ll[];
ENUM_TIMEFRAMES _indicatorTimeFrame;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fup,INDICATOR_DATA);      
   SetIndexBuffer(1,fdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,hh ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ll ,INDICATOR_CALCULATIONS);
             _indicatorTimeFrame  = MathMax(_Period,timeFrameGet(inpTimeFrame)); 
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

int OnCalculate (const int rates_total,
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      int _currentBar = iBarShift(_Symbol,_indicatorTimeFrame,time[i]);
      if (_currentBar<0) break;
      if (i==0 || _currentBar!=iBarShift(_Symbol,_indicatorTimeFrame,time[i-1]))
      {
         hh[i] = high[i];
         ll[i] = low[i];
      }
      else
      {
         hh[i] = high[i]>hh[i-1] ? high[i] : hh[i-1];
         ll[i] = low [i]<ll[i-1] ? low[i]  : ll[i-1];
      }               
      double _middle = (hh[i]+ll[i])/2.0;
         val[i] = _middle;
         fup[i] = (high[i]>_middle) ? low[i] : (low[i]<_middle) ? high[i] : (i>0) ? fup[i-1] : close[i];
         fdn[i] = _middle;
   }         
   return(i);         
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//---
//

ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//
//---
//

ENUM_TIMEFRAMES timeFrameGet(int period)
{
   int _size  = ArraySize(_tfsPer);
   int _shift = (period<0 ? MathAbs(period) : 0); 
             if (period<=0) period=_Period;
   
             int i; for(i=0;i<_size;i++) if(period==_tfsPer[i]) break;
   //
   //
   //
         
   return(_tfsPer[(int)MathMin(i+_shift,_size-1)]);
}

