//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "TAI"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
//---
input int                inpTaiPeriod   = 5;           // TAI period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input int                inpMaPeriod    = 28;          // Average period
input ENUM_MA_METHOD     inpMaMethod    = MODE_SMA;    // Average type
input int                inpFlPeriod    = 50;          // Floating levels period
input double             inpFlLevelUp   = 80.0;        // Up level %
input double             inpFlLevelDown = 20.0;        // Down level %
//
//---
//
double val[],valc[],levelUp[],levelDn[],avg[];
int _maHandle,_maPeriod;
//------------------------------------------------------------------ 
// Custom indicator initialization function
//------------------------------------------------------------------ 
int OnInit()
{
   //---- indicator buffers mapping
      SetIndexBuffer(0,levelUp,INDICATOR_DATA); 
      SetIndexBuffer(1,levelDn,INDICATOR_DATA);
      SetIndexBuffer(2,val    ,INDICATOR_DATA);
      SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(4,avg    ,INDICATOR_CALCULATIONS);
   //----
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   //----
      _maPeriod = MathMax(inpMaPeriod,1);
      _maHandle = iMA(_Symbol,0,_maPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(_maHandle,"Moving average"))  return(INIT_FAILED);
   //----
      IndicatorSetString(INDICATOR_SHORTNAME,"TAI ("+(string)inpTaiPeriod+","+(string)inpMaPeriod+")");
      return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------ 
// Custom indicator iteration function
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
   if(BarsCalculated(_maHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
            if (CopyBuffer(_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      int    _start = i-inpTaiPeriod+1; if (_start<0) _start=0;
      double _max   = avg[ArrayMaximum(avg,_start,inpTaiPeriod)];
      double _min   = avg[ArrayMinimum(avg,_start,inpTaiPeriod)];            
      
      val[i] = 100.0*((i>0 && avg[i]>avg[i-1]) ? _max-_min : _min-_max)/getPrice(inpPrice,open,close,high,low,i);
             
             _start = i-inpFlPeriod+1; if (_start<0) _start=0;
             _min   = val[ArrayMinimum(val,_start,inpFlPeriod)];
             _max   = val[ArrayMaximum(val,_start,inpFlPeriod)];
      double _range = (_max-_min)*0.01;
      levelUp[i] = _min+inpFlLevelUp  *_range;
      levelDn[i] = _min+inpFlLevelDown*_range;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
   }
   return(i);
}

//------------------------------------------------------------------ 
// Custom functions
//------------------------------------------------------------------ 
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}   
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
//------------------------------------------------------------------
