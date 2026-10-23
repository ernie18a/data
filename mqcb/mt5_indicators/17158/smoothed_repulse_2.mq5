//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Smoothed repulse zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Smoothed repulse middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Smoothed repulse"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrangeRed
#property indicator_width3  3

//
//
//
//
//

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};
enum enColorOn
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle  // Change color on middle level cross
};

input int       RepulsePeriod   = 14;          // Repulse period
input enMaTypes RepulseAvgType  = ma_ema;      // Repulse average method
input int       RepulseAvgMult  = 5;           // Repulse average multiplier
input enColorOn ColorOn         = chg_onLevel; // Color change on  
input int       LevelPeriod     = 50;          // Levels period
input double    LevelUp         = 90;          // Upper level
input double    LevelDown       = 10;          // Lower level
input bool      AlertsOn        = false;       // Turn alerts on?
input bool      AlertsOnCurrent = true;        // Alert on current bar?
input bool      AlertsMessage   = true;        // Display messageas on alerts?
input bool      AlertsSound     = false;       // Play sound on alerts?
input bool      AlertsEmail     = false;       // Send email on alerts?
input bool      AlertsNotify    = false;       // Send push notification on alerts?

double rep[],repc[],fup[],fmi[],fdn[];

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
   SetIndexBuffer(2,fmi,INDICATOR_DATA);
   SetIndexBuffer(3,rep,INDICATOR_DATA);
   SetIndexBuffer(4,repc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed repulse ("+(string)RepulsePeriod+","+(string)RepulseAvgMult+")");
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);

   int i=(int)MathMax(prev_calculated-1,0); for (;i<rates_total && !_StopFlag; i++)
   {
      int length = MathMin(i,RepulsePeriod);
               int    start = MathMax(i-length+1,0);
               double min   = high[ArrayMinimum(high,start,length)];
               double max   = low [ArrayMaximum(low ,start,length)];
               double bull  = iCustomMa(RepulseAvgType,100*(3.0*close[i]-2.0*min-open[i-length])/close[i],length*RepulseAvgMult,i,rates_total,0);
               double bear  = iCustomMa(RepulseAvgType,100*(open[i-length]+2.0*max-3.0*close[i])/close[i],length*RepulseAvgMult,i,rates_total,1);

            //
            //
            //
            //
            //
                  
               rep[i] = bull-bear;
               start  = MathMax(i-LevelPeriod+1,0);
               min    = rep[ArrayMinimum(rep,start,LevelPeriod)];
               max    = rep[ArrayMaximum(rep,start,LevelPeriod)];
                  double rn = max-min;
                     fup[i]  = min+rn*LevelUp  /100.0;
                     fdn[i]  = min+rn*LevelDown/100.0;
                     fmi[i]  = (fup[i]+fdn[i])/2.0;
                     switch (ColorOn)
                     {
                        case chg_onLevel :  repc[i] = (rep[i]>fup[i]) ? 1 : (rep[i]<fdn[i]) ? 2 : (rep[i]<fup[i] && rep[i]>fdn[i]) ? 0 : (i>0) ? repc[i-1]: 0; break;
                        case chg_onMiddle : repc[i] = (rep[i]>fmi[i]) ? 1 : (rep[i]<fmi[i]) ? 2 : (i>0) ? repc[i-1] : 0; break;
                        default :           repc[i] = (i>0) ? (rep[i]>rep[i-1]) ? 1 : (rep[i]<rep[i-1]) ? 2 : repc[i-1] : 0;
                     }                  
   }
   manageAlerts(time,repc,rates_total);
   return(i);
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
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" smoothed repulse state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" smoothed repulse",message);
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

#define _maInstances 2
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