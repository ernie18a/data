//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands stops - multiple stops"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   8
#property indicator_label1  "Bollinger bands stops up stop line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  3
#property indicator_label2  "Bollinger bands stops down stop line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width2  3
#property indicator_label3  "Bollinger bands stops up first stop line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_label4  "Bollinger bands stops down first stop line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_label5  "Bollinger bands stops up second stop line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_label6  "Bollinger bands stops down second stop line"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSandyBrown
#property indicator_label7  "Bollinger bands stops up trend start"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDodgerBlue
#property indicator_width7  2
#property indicator_label8  "Bollinger bands stops down trend start"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrSandyBrown
#property indicator_width8  2

//
//--- input parameters
//

input int                inpAvgPeriod = 20;          // Average period
input ENUM_MA_METHOD     inpMaMethod  = MODE_SMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input int                inpDevPeriod = 0;           // Deviation period (<=1 for same as average period)
input double             inpDeviation = 2;           // Deviation multiplier
input string             __º__01_00   = "";          // .
input string             __º__01_01   = "";          // Risk settings
input string             __º__01_02   = "";          // .
input double             inpRisk      = 0.75;        // Risk multiplier
input double             inpRisk2     = 1.5;         // Risk 2 multiplier
input double             inpRisk3     = 2.5;         // Risk 3 multiplier

//
//--- indicator buffers
//

double lineup[],linedn[],lineup2[],linedn2[],lineup3[],linedn3[],arrowup[],arrowdn[],dev[],avg[],_risk1,_risk2,_risk3;
int  _devHandle,_avgHandle,_devPeriod; 

//
//--- custom structures
//

struct sStops
{
   double upline;
   double downline;
   double upline2;
   double downline2;
   double upline3;
   double downline3;
   int    trend;
   bool   trendChange;
};

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,lineup ,INDICATOR_DATA);
   SetIndexBuffer(1,linedn ,INDICATOR_DATA);
   SetIndexBuffer(2,lineup2,INDICATOR_DATA);
   SetIndexBuffer(3,linedn2,INDICATOR_DATA);
   SetIndexBuffer(4,lineup3,INDICATOR_DATA);
   SetIndexBuffer(5,linedn3,INDICATOR_DATA);
   SetIndexBuffer(6,arrowup,INDICATOR_DATA); PlotIndexGetInteger(6,PLOT_ARROW,159);
   SetIndexBuffer(7,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(7,PLOT_ARROW,159);
   SetIndexBuffer(8,dev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,avg,INDICATOR_CALCULATIONS);
         double _risks[3];
                _risks[0] = inpRisk;
                _risks[1] = inpRisk2;
                _risks[2] = inpRisk3; ArraySort(_risks);
                                                _risk1 = _risks[0];
                                                _risk2 = _risks[1];
                                                _risk3 = _risks[2];
         _devPeriod = inpDevPeriod>1 ? inpDevPeriod : inpAvgPeriod;
         _devHandle = iStdDev(_Symbol,0,_devPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(_devHandle,"Standard deviation")) return(INIT_FAILED);
         _avgHandle = iMA(_Symbol,0,inpAvgPeriod,0,inpMaMethod,inpPrice);   if (!_checkHandle(_avgHandle,"Moving average")) return(INIT_FAILED);
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
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   if(BarsCalculated(_devHandle)<rates_total) return(prev_calculated);
   if(BarsCalculated(_avgHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
            if (CopyBuffer(_devHandle,0,0,_copyCount,dev)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_avgHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   sStops _result;
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      _result = iStops(getPrice(inpPrice,open,close,high,low,i),avg[i],dev[i],inpDeviation,_risk1,_risk2,_risk3,i);
         lineup[i]  = _result.upline3;
         linedn[i]  = _result.downline3;
         lineup2[i] = _result.upline;
         linedn2[i] = _result.downline;
         lineup3[i] = _result.upline2;
         linedn3[i] = _result.downline2;
         arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
         arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
   }          
   return(i);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _stopsInstances 1
#define _stopsInstancesSize 9
#define _stopsRingSize 6
double workStops[_stopsRingSize][_stopsInstances*_stopsInstancesSize];
#define _stopsAmin  0
#define _stopsAmax  1 
#define _stopsBmin  2
#define _stopsBmax  3 
#define _stopsCmin  4
#define _stopsCmax  5 
#define _stopsDmin  6
#define _stopsDmax  7 
#define _stopsTrend 8

//
//---
//

sStops iStops(double value, double average, double deviation, double bands, double risk, double risk2, double risk3, int i, int instance=0)
{
   int _indC = (i  )%_stopsRingSize;
   int _indP = (i-1)%_stopsRingSize;
   int _inst = instance*_stopsInstancesSize;
   
   //
   //---
   //
   
   workStops[_indC][_inst+_stopsAmax]  = average+bands*deviation;
   workStops[_indC][_inst+_stopsAmin]  = average-bands*deviation;
   workStops[_indC][_inst+_stopsBmax]  = average+risk*deviation;
   workStops[_indC][_inst+_stopsBmin]  = average-risk*deviation;
   workStops[_indC][_inst+_stopsCmax]  = average+risk2*deviation;
   workStops[_indC][_inst+_stopsCmin]  = average-risk2*deviation;
   workStops[_indC][_inst+_stopsDmax]  = average+risk3*deviation;
   workStops[_indC][_inst+_stopsDmin]  = average-risk3*deviation;
	workStops[_indC][_inst+_stopsTrend] = (i>0) ? (value>workStops[_indP][_inst+_stopsAmax]) ? 1 : (value<workStops[_indP][_inst+_stopsAmin]) ? -1 : workStops[_indP][_inst+_stopsTrend] : 0;
      if (i>0)
      {
         if (workStops[_indC][_inst+_stopsTrend]==-1)
         {
            if (workStops[_indC][_inst+_stopsAmax]>workStops[_indP][_inst+_stopsAmax]) workStops[_indC][_inst+_stopsAmax] = workStops[_indP][_inst+_stopsAmax];
            if (workStops[_indC][_inst+_stopsBmax]>workStops[_indP][_inst+_stopsBmax]) workStops[_indC][_inst+_stopsBmax] = workStops[_indP][_inst+_stopsBmax];
            if (workStops[_indC][_inst+_stopsCmax]>workStops[_indP][_inst+_stopsCmax]) workStops[_indC][_inst+_stopsCmax] = workStops[_indP][_inst+_stopsCmax];
            if (workStops[_indC][_inst+_stopsDmax]>workStops[_indP][_inst+_stopsDmax]) workStops[_indC][_inst+_stopsDmax] = workStops[_indP][_inst+_stopsDmax];
         }         
         if (workStops[_indC][_inst+_stopsTrend]==1)
         {
            if (workStops[_indC][_inst+_stopsAmin]<workStops[_indP][_inst+_stopsAmin]) workStops[_indC][_inst+_stopsAmin] = workStops[_indP][_inst+_stopsAmin];
            if (workStops[_indC][_inst+_stopsBmin]<workStops[_indP][_inst+_stopsBmin]) workStops[_indC][_inst+_stopsBmin] = workStops[_indP][_inst+_stopsBmin];
            if (workStops[_indC][_inst+_stopsCmin]<workStops[_indP][_inst+_stopsCmin]) workStops[_indC][_inst+_stopsCmin] = workStops[_indP][_inst+_stopsCmin];
            if (workStops[_indC][_inst+_stopsDmin]<workStops[_indP][_inst+_stopsDmin]) workStops[_indC][_inst+_stopsDmin] = workStops[_indP][_inst+_stopsDmin];
         }         
      }                  
   
      //
      //---
      //
      
      sStops _result;
	          _result.trend       = (int)workStops[_indC][_inst+_stopsTrend];
             _result.trendChange = (i>0) ? ( workStops[_indC][_inst+_stopsTrend]!=workStops[_indP][_inst+_stopsTrend]) : false;
             _result.upline      =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsBmin] : EMPTY_VALUE;
             _result.downline    =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsBmax] : EMPTY_VALUE;
             _result.upline2     =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsCmin] : EMPTY_VALUE;
             _result.downline2   =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsCmax] : EMPTY_VALUE;
             _result.upline3     =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsDmin] : EMPTY_VALUE;
             _result.downline3   =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsDmax] : EMPTY_VALUE;
      return(_result);   

   //
   //
   //
   
   #undef _stopsAmax
   #undef _stopsAmin
   #undef _stopsBmax
   #undef _stopsBmin
   #undef _stopsCmax
   #undef _stopsCmin
   #undef _stopsDmax
   #undef _stopsDmin
   #undef _stopsTrend
};

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

//
//----
//

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
