//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'255,230,183'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_width5  4

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

input ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT; // Time frame
input int             Periods           = 35;             // Quantile period
input enPrices        PriceUp           = pr_high;        // Price to use for high quantile value
input enPrices        PriceMid          = pr_median;      // Price to use for middle quantile value
input enPrices        PriceDown         = pr_low;         // Price to use for low quantile value
input double          UpperBandPercent  = 90;             // Upper band percent
input double          MedianBandPercent = 50;             // Middle band percent
input double          LowerBandPercent  = 10;             // Lower band percent
input bool            Interpolate       = true;           // Interpolate in multi time frame mode?

//
//
//
//
//

double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],bufferMec[],fupu[],fupd[],fdnd[],fdnu[],count[];
int _mtfHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getName(),PERIOD_CURRENT,Periods,PriceUp,PriceMid,PriceDown,UpperBandPercent,MedianBandPercent,LowerBandPercent)

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
   SetIndexBuffer( 0,fupu,INDICATOR_DATA);      SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer( 2,fdnu,INDICATOR_DATA);      SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer( 4,bufferUp ,INDICATOR_DATA); SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 6,bufferDn ,INDICATOR_DATA); SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 8,bufferMe ,INDICATOR_DATA); SetIndexBuffer(9,bufferMec,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,count    ,INDICATOR_CALCULATIONS); 
      timeFrame = MathMax(_Period,TimeFrame);
   return(0);
}
void OnDeinit(const int reason) { return; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //
   
      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
            if (!timeFrameCheck(timeFrame,time))         return(0);
            if (_mtfHandle==INVALID_HANDLE) _mtfHandle = _mtfCall;
            if (_mtfHandle==INVALID_HANDLE)              return(0);
            if (CopyBuffer(_mtfHandle,7,0,1,result)==-1) return(0); 
      
                //
                //
                //
                //
                //
              
                #define _mtfRatio PeriodSeconds(timeFrame)/PeriodSeconds(_Period)
                int k,n,i = MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-(int)result[0]*_mtfRatio-1,0));
                for (; i<rates_total && !_StopFlag; i++ )
                {
                  #define _mtfCopy(_buff,_buffNo) if (CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)==-1) break; _buff[i] = result[0]
                   _mtfCopy(bufferUp ,4);
                   _mtfCopy(bufferUpc,5);
                   _mtfCopy(bufferDn ,6);
                   _mtfCopy(bufferDnc,7);
                   _mtfCopy(bufferMe ,8);
                   _mtfCopy(bufferMec,9);
                            fupd[i]  = bufferMe[i]; fupu[i] = bufferUp[i]; 
                            fdnu[i]  = bufferMe[i]; fdnd[i] = bufferDn[i]; 

                   //
                   //
                   //
                   //
                   //
                                      
                   #define _mtfInterpolate(_buff) _buff[i-k] = _buff[i]+(_buff[i-n]-_buff[i])*k/n
                      if (!Interpolate) continue;  CopyTime(_Symbol,timeFrame,time[i  ],1,currTime); 
                      if (i<(rates_total-1)) { CopyTime(_Symbol,timeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                         for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                         for(k=1; (i-k)>=0 && k<n; k++)
                         {
                              _mtfInterpolate(bufferMe);
                              _mtfInterpolate(bufferMe);
                              _mtfInterpolate(bufferDn);
                                 fupd[i-k] = bufferMe[i-k]; fupu[i-k] = bufferUp[i-k]; 
                                 fdnu[i-k] = bufferMe[i-k]; fdnd[i-k] = bufferDn[i-k]; 
                         }                                 
                }
                return(i);
      }
   
   //
   //
   //
   //
   //
   
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double prices[3];
             prices[0] = getPrice(PriceUp  ,open,close,high,low,i,rates_total,0);
             prices[1] = getPrice(PriceDown,open,close,high,low,i,rates_total,1);
             prices[2] = getPrice(PriceMid ,open,close,high,low,i,rates_total,2);
                     ArraySort(prices);
      bufferUp[i]  = iQuantile(prices[2],Periods,UpperBandPercent ,i,rates_total,0);
      bufferMe[i]  = iQuantile(prices[1],Periods,MedianBandPercent,i,rates_total,2);
      bufferDn[i]  = iQuantile(prices[0],Periods,LowerBandPercent ,i,rates_total,1);
      fupd[i]      = bufferMe[i]; fupu[i] = bufferUp[i]; 
      fdnu[i]      = bufferMe[i]; fdnd[i] = bufferDn[i]; 
      bufferUpc[i] = (i>0) ? (bufferUp[i]>bufferUp[i-1]) ? 1 : (bufferUp[i]<bufferUp[i-1])? 2 : bufferUpc[i-1] : 0;
      bufferDnc[i] = (i>0) ? (bufferDn[i]>bufferDn[i-1]) ? 1 : (bufferDn[i]<bufferDn[i-1])? 2 : bufferDnc[i-1] : 0;
      bufferMec[i] = (bufferUpc[i]==1 && bufferDnc[i]==1) ? 1 : (bufferUpc[i]==2 && bufferDnc[i]==2) ? 2 : 0;
   }         
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   return(rates_total);         
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define quantileInstances 3
double quantileValues[][quantileInstances];
double quantileArray[];
double iQuantile(double value, int period, double qp, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(quantileArray ,0)!=period) ArrayResize(quantileArray ,period);
   if (ArrayRange(quantileValues,0)!=bars)   ArrayResize(quantileValues,bars);
                  quantileValues[i][instanceNo] = value;
                        for(int k=0; k<period && (i-k)>=0; k++) quantileArray[k] = quantileValues[i-k][instanceNo];
       ArraySort(quantileArray);

   //
   //
   //
   //
   //
   
   double index = (period-1)*qp/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            quantileArray[ind]);
         return((1.0-delta)*quantileArray[ind]+delta*quantileArray[ind+1]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 3
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//
//
//
//
//

string getName()
{
   string path = MQL5InfoString(MQL5_PROGRAM_PATH);
   string data = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Indicators\\";
   string name = StringSubstr(path,StringLen(data));
      return(name);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string getIndicatorName()
{
   string path = MQL5InfoString(MQL5_PROGRAM_PATH);
   string data = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Indicators\\";
   string name = StringSubstr(path,StringLen(data));
      return(name);
}

//
//
//
//
//

int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
string timeFrameToString(int period)
{
   if (period==PERIOD_CURRENT) 
       period = _Period;   
         int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}

//
//
//
//
//

bool timeFrameCheck(ENUM_TIMEFRAMES _timeFrame,const datetime& time[])
{
   static bool warned=false;
   if (time[0]<SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE))
   {
      datetime startTime,testTime[]; 
         if (SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,startTime))
         if (startTime>0)                       { CopyTime(_Symbol,_timeFrame,time[0],1,testTime); SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE,startTime); }
         if (startTime<=0 || startTime>time[0]) { Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+"\nMissing data for "+timeFrameToString(_timeFrame)+" time frame\nRe-trying on next tick"); warned=true; return(false); }
   }
   if (warned) { Comment(""); warned=false; }
   return(true);
}