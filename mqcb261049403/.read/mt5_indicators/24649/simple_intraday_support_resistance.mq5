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

double fup[],fdn[],val[],hh[],ll[];

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
   if (_Period>=PERIOD_D1)
   {
      Alert("This indicator must work on time frames less than daily");
   }
   SetIndexBuffer(0,fup,INDICATOR_DATA);      
   SetIndexBuffer(1,fdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,hh ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ll ,INDICATOR_CALCULATIONS);
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
   if (_Period>=PERIOD_D1) return(rates_total);
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (i==0 || iBarShift(_Symbol,PERIOD_D1,time[i])!=iBarShift(_Symbol,PERIOD_D1,time[i-1]))
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