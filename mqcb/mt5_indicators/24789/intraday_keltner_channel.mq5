//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Upper band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_DOT

//
//---
//

input int                inpPeriod     = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
input double             inpMultiplier = 1.0;         // ATR multiplier

double val[],valu[],vald[],tr[];
ENUM_TIMEFRAMES _timeFrame=PERIOD_D1; string _timeFrameName = "day"; int _maHandle;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,val ,INDICATOR_DATA);
   SetIndexBuffer(2,vald,INDICATOR_DATA);
   SetIndexBuffer(3,tr ,INDICATOR_CALCULATIONS);
      if (_Period==PERIOD_D1)                        { _timeFrame = PERIOD_W1;  _timeFrameName = "week";  }
      if (_Period==PERIOD_W1 || _Period==PERIOD_MN1) { _timeFrame = PERIOD_MN1; _timeFrameName = "month"; }
      
         _maHandle = iMA(_Symbol,_Period,inpPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(_maHandle,"Average")) return(INIT_FAILED);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Intra-"+_timeFrameName+" Keltner channel ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_maHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      int      _highTfBar  = iBarShift(_Symbol,_timeFrame,time[i]);
      datetime _highTfTime = iTime(_Symbol,_timeFrame,_highTfBar);
      int      _firstBar   = iBarShift(_Symbol,_Period,_highTfTime);
         
         //
         //
         //
         
         tr[i] = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];
         
            int k=1,_period = (_timeFrame==PERIOD_MN1) ? inpPeriod : i-(rates_total-_firstBar-1)+1; if (_period>inpPeriod) _period = inpPeriod;
            double _atr = tr[i]; for (; k<_period && i>=k; k++) _atr += tr[i-k];
                   _atr /= (double)k;
                   valu[i] = val[i] + inpMultiplier*_atr;
                   vald[i] = val[i] - inpMultiplier*_atr;
   }      
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------