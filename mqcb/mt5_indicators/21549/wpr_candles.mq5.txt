//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "WPR candles"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "WPR"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrCrimson
#property indicator_level1   0
#property indicator_level2  -100

input int inpWprPeriod=50;      // WPR period
                                //
//--- indicator buffers
//

double wpro[],wprh[],wprl[],wprc[],wprcl[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,wpro,INDICATOR_DATA);
   SetIndexBuffer(1,wprh,INDICATOR_DATA);
   SetIndexBuffer(2,wprl,INDICATOR_DATA);
   SetIndexBuffer(3,wprc,INDICATOR_DATA);
   SetIndexBuffer(4,wprcl,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"WPR candles ("+(string)inpWprPeriod+")");
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

   double _wpr[4];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start = (int)MathMax(i-inpWprPeriod,0);
         double _omax = open[ArrayMaximum(open,_start,inpWprPeriod)];
         double _omin = open[ArrayMinimum(open,_start,inpWprPeriod)];
         double _cmax = close[ArrayMaximum(close,_start,inpWprPeriod)];
         double _cmin = close[ArrayMinimum(close,_start,inpWprPeriod)];
         double _hmax = high[ArrayMaximum(high,_start,inpWprPeriod)];
         double _hmin = high[ArrayMinimum(high,_start,inpWprPeriod)];
         double _lmax = low[ArrayMaximum(low,_start,inpWprPeriod)];
         double _lmin = low[ArrayMinimum(low,_start,inpWprPeriod)];

      //
      //---
      //
     
      _wpr[0] = ((_omax-_omin)!=0) ? -(_omax-open[i])*100/(_omax-_omin) : 0;
      _wpr[1] = ((_hmax-_hmin)!=0) ? -(_hmax-high[i])*100/(_hmax-_hmin) : 0;
      _wpr[2] = ((_lmax-_lmin)!=0) ? -(_lmax-low[i])*100/(_lmax-_lmin) : 0;
      _wpr[3] = ((_cmax-_cmin)!=0) ? -(_cmax-close[i])*100/(_cmax-_cmin) : 0;
      wpro[i] = _wpr[0];
      wprc[i] = _wpr[3];
      wprh[i] = _wpr[ArrayMaximum(_wpr,0,4)];
      wprl[i] = _wpr[ArrayMinimum(_wpr,0,4)];
      wprcl[i]=(wprc[i]>wpro[i]) ? 1 :(wprc[i]<wpro[i]) ? 2 : 0;
     }
   return(i);
  }