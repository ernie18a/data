//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
#property version   "2.10"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label1  "Step stochastic filling"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGray,clrLimeGreen,clrOrange
#property indicator_width2  2
#property indicator_label2  "Step stochastic"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGray,clrLimeGreen,clrOrange
#property indicator_width3  2
#property indicator_label3  "Step stochastic signal"

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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

input ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame
input int             AtrPeriod       = 10;             // Average range calculation period
input double          KFast           = 1.5;            // Fast stochastic
input double          KSlow           = 1.0;            // Slow stochastic
input enPrices        Price           = pr_median;      // Price to use in calculations
input int             MaPeriod        = 3;              // Price filter period (<=1 for no filtering)
input enMaTypes       MaType          = ma_ema;         // Price filter average type
input int             Window          = 256;            // Average range minimum maximum window size
input bool            SmoothAtr       = true;           // Use smoothed average range (valid for price filter > 1)?
input bool            AlertsOn        = false;          // Turn alerts on?
input bool            AlertsOnCurrent = true;           // Alert on current bar?
input bool            AlertsMessage   = true;           // Display messageas on alerts?
input bool            AlertsSound     = false;          // Play sound on alerts?
input bool            AlertsEmail     = false;          // Send email on alerts?
input bool            AlertsNotify    = false;          // Send push notification on alerts?
input bool            Interpolate     = true;           // Interpolate mtf data ?

double stoch1[],stoch2[],stoch1c[],stoch2c[],fill1[],fill2[],count[];
int _mtfHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,AtrPeriod,KFast,KSlow,Price,MaPeriod,MaType,Window,SmoothAtr,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotify)

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
   SetIndexBuffer( 0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer( 1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer( 2,stoch1 ,INDICATOR_DATA);
   SetIndexBuffer( 3,stoch1c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 4,stoch2 ,INDICATOR_DATA);
   SetIndexBuffer( 5,stoch2c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 6,count  ,INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
         timeFrame = MathMax(_Period,TimeFrame);
      IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" Step stochastic ("+(string)AtrPeriod+", fast "+(string)KFast+", slow "+(string)KSlow+", ma "+(string)MaPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
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
            if (CopyBuffer(_mtfHandle,6,0,1,result)==-1) return(0); 
      
                //
                //
                //
                //
                //
              
                #define _mtfRatio PeriodSeconds(timeFrame)/PeriodSeconds(_Period)
                int i,k,n,limit = MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-(int)result[0]*_mtfRatio-1,0));
                for (i=limit; i<rates_total && !_StopFlag; i++ )
                {
                  #define _mtfCopy(_buff,_buffNo) if (CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)==-1) break; _buff[i] = result[0]
                          _mtfCopy(fill1  ,0);
                          _mtfCopy(fill2  ,1);
                          _mtfCopy(stoch1 ,2);
                          _mtfCopy(stoch1c,3);
                          _mtfCopy(stoch2 ,4);
                          _mtfCopy(stoch2c,5);
                   
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
                                  _mtfInterpolate(fill1 );
                                  _mtfInterpolate(fill2 );
                                  _mtfInterpolate(stoch1);
                                  _mtfInterpolate(stoch2);
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
             prices[0] = iCustomMa(MaType,getPrice(Price,open,close,high,low,i,rates_total),MaPeriod,i,rates_total,0);
             prices[1] = (!SmoothAtr) ? high[i] : iCustomMa(MaType,high[i]                 ,MaPeriod,i,rates_total,1);
             prices[2] = (!SmoothAtr) ? low[i]  : iCustomMa(MaType,low[i]                  ,MaPeriod,i,rates_total,2);
             ArraySort(prices);
      iStepStochastic(stoch1,stoch2,prices[1],prices[2],prices[0],AtrPeriod,KSlow,KFast,Window,i,rates_total);
      fill1[i] = stoch1[i];
      fill2[i] = stoch2[i];
      stoch1c[i] = (stoch1[i]>stoch2[i]) ? 1 : (stoch1[i]<stoch2[i]) ? 2 : (i>0) ? stoch1c[i-1] : 0 ;
      stoch2c[i] = stoch1c[i];
   }
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,stoch1c,rates_total);
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

void manageAlerts(const datetime& atime[], double& atrend[], int bars)
{
   if (!AlertsOn) return;
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = atime[whichBar];
      if (atrend[whichBar] != atrend[whichBar-1])
      {
         if (atrend[whichBar] == 1) doAlert(time1,"up");
         if (atrend[whichBar] == 2) doAlert(time1,"down");
      }         
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      string message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" step stochastic state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" step stochastic",message);
         if (AlertsNotify)  SendNotification(message);
         if (AlertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _stepStochInstances 1
#define _stepStochSize      16
#define _sstSminMin         0
#define _sstSmaxMin         1
#define _sstSminMid         2
#define _sstSmaxMid         3
#define _sstSminMax         4
#define _sstSmaxMax         5
#define _sstTrendMin        6
#define _sstTrendMid        7
#define _sstTrendMax        8
#define _sstLinemin         9
#define _sstLinemid        10
#define _sstLinemax        11
#define _sstAtr            12
#define _sstHigh           13
#define _sstLow            14
#define _sstValue          15
#define _bigValue EMPTY_VALUE

double iStepWork[][_stepStochInstances*_stepStochSize];
void   iStepStochastic(double& array1[], double& array2[], double value, double valueh, double valuel, int atrPeriod, double kslow, double kfast, int window, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(iStepWork,0)!=bars) ArrayResize(iStepWork,bars); instanceNo*=_stepStochSize;
   
   //
   //
   //
   //
   //
   
   for (int k=0; k<_stepStochSize; k++) iStepWork[i][instanceNo+k]         = 0;
                                        iStepWork[i][instanceNo+_sstValue] = value;
                                        iStepWork[i][instanceNo+_sstHigh]  = valueh;
                                        iStepWork[i][instanceNo+_sstLow]   = valuel;
                                        if (i<window)
                                        {
                                           iStepWork[i][instanceNo+_sstSminMin] = _bigValue;
                                           iStepWork[i][instanceNo+_sstSmaxMin] = _bigValue;
                                           return;
                                        }                                                
   for (int k=0; k<atrPeriod && (i-k-1)>=0; k++) iStepWork[i][instanceNo+_sstAtr] += MathMax(iStepWork[i-k][instanceNo+_sstHigh],iStepWork[i-k-1][instanceNo+_sstLow])-
                                                                                     MathMin(iStepWork[i-k][instanceNo+_sstLow],iStepWork[i-k-1][instanceNo+_sstHigh]);
                                                 iStepWork[i][instanceNo+_sstAtr] /= (double)atrPeriod;

   //
   //
   //
   //
   //
   
   double nATRmax = iStepWork[i][instanceNo+_sstAtr];
   double nATRmin = iStepWork[i][instanceNo+_sstAtr];
      for (int k=1; k<window && (i-k)>=0; k++)
         {
            nATRmax = MathMax(nATRmax,iStepWork[i-k][instanceNo+_sstAtr]); 
            nATRmin = MathMin(nATRmin,iStepWork[i-k][instanceNo+_sstAtr]); 
         }
         double StepSizeMin = (kfast * nATRmin);
         double StepSizeMax = (kfast * nATRmax);
         double StepSizeMid = (kfast * 0.5 * kslow * (nATRmax + nATRmin));
            iStepWork[i][instanceNo+_sstSmaxMin] = value + 2.0 * StepSizeMin;
            iStepWork[i][instanceNo+_sstSminMin] = value - 2.0 * StepSizeMin;
            iStepWork[i][instanceNo+_sstSmaxMid] = value + 2.0 * StepSizeMid;
            iStepWork[i][instanceNo+_sstSminMid] = value - 2.0 * StepSizeMid;
            iStepWork[i][instanceNo+_sstSmaxMax] = value + 2.0 * StepSizeMax;
            iStepWork[i][instanceNo+_sstSminMax] = value - 2.0 * StepSizeMax;
          
          //
          //
          //
          //
          //
          
          #define TrendMin iStepWork[i][instanceNo+_sstTrendMin]
          #define TrendMid iStepWork[i][instanceNo+_sstTrendMid]
          #define TrendMax iStepWork[i][instanceNo+_sstTrendMax]
          #define linemin  iStepWork[i][instanceNo+_sstLinemin]
          #define linemid  iStepWork[i][instanceNo+_sstLinemid]
          #define linemax  iStepWork[i][instanceNo+_sstLinemax]
          if (i>0) 
          {
            for (int k=_sstTrendMin; k<=_sstLinemax; k++) iStepWork[i][instanceNo+k] = iStepWork[i-1][instanceNo+k];               
                  if (value > iStepWork[i-1][instanceNo+_sstSmaxMin]) TrendMin =  1;
                  if (value < iStepWork[i-1][instanceNo+_sstSminMin]) TrendMin = -1;
                  if (value > iStepWork[i-1][instanceNo+_sstSmaxMid]) TrendMid =  1;
                  if (value < iStepWork[i-1][instanceNo+_sstSminMid]) TrendMid = -1;
                  if (value > iStepWork[i-1][instanceNo+_sstSmaxMax]) TrendMax =  1;
                  if (value < iStepWork[i-1][instanceNo+_sstSminMax]) TrendMax = -1;

                  if (TrendMin > 0 && iStepWork[i][instanceNo+_sstSminMin]<iStepWork[i-1][instanceNo+_sstSminMin]) iStepWork[i][instanceNo+_sstSminMin] = iStepWork[i-1][instanceNo+_sstSminMin];
                  if (TrendMin < 0 && iStepWork[i][instanceNo+_sstSmaxMin]>iStepWork[i-1][instanceNo+_sstSmaxMin]) iStepWork[i][instanceNo+_sstSmaxMin] = iStepWork[i-1][instanceNo+_sstSmaxMin];
                  if (TrendMid > 0 && iStepWork[i][instanceNo+_sstSminMid]<iStepWork[i-1][instanceNo+_sstSminMid]) iStepWork[i][instanceNo+_sstSminMid] = iStepWork[i-1][instanceNo+_sstSminMid];
                  if (TrendMid < 0 && iStepWork[i][instanceNo+_sstSmaxMid]>iStepWork[i-1][instanceNo+_sstSmaxMid]) iStepWork[i][instanceNo+_sstSmaxMid] = iStepWork[i-1][instanceNo+_sstSmaxMid];
                  if (TrendMax > 0 && iStepWork[i][instanceNo+_sstSminMax]<iStepWork[i-1][instanceNo+_sstSminMax]) iStepWork[i][instanceNo+_sstSminMax] = iStepWork[i-1][instanceNo+_sstSminMax];
                  if (TrendMax < 0 && iStepWork[i][instanceNo+_sstSmaxMax]>iStepWork[i-1][instanceNo+_sstSmaxMax]) iStepWork[i][instanceNo+_sstSmaxMax] = iStepWork[i-1][instanceNo+_sstSmaxMax];
           }                  
           if (TrendMin > 0) linemin = iStepWork[i][instanceNo+_sstSminMin] + StepSizeMin;
           if (TrendMin < 0) linemin = iStepWork[i][instanceNo+_sstSmaxMin] - StepSizeMin;
           if (TrendMid > 0) linemid = iStepWork[i][instanceNo+_sstSminMid] + StepSizeMid;
           if (TrendMid < 0) linemid = iStepWork[i][instanceNo+_sstSmaxMid] - StepSizeMid;
           if (TrendMax > 0) linemax = iStepWork[i][instanceNo+_sstSminMax] + StepSizeMax;
           if (TrendMax < 0) linemax = iStepWork[i][instanceNo+_sstSmaxMax] - StepSizeMax;

   //
   //
   //
   //
   //
   
   double bsmin = linemax - StepSizeMax;
   double bsmax = linemax + StepSizeMax;
      array1[i] = (bsmax!=bsmin) ? ((linemin - bsmin) / (bsmax - bsmin)) * 100.0 : 0;
      array2[i] = (bsmax!=bsmin) ? ((linemid - bsmin) / (bsmax - bsmin)) * 100.0 : 0;
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

#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
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

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k=1;

   workSma[r][instanceNo+0] = price;
   double avg = price; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
   return(avg);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
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