//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "stochastic"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  3
#property indicator_label2  "signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
  
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
enum enStochPrice
{
   sto_hil, // High/low
   sto_ctc  // Close/close
};
input int          StoPeriod       = 32;      // Stochastic period
input int          StoSlowing      = 9;       // Stochastic slowing period
input enMaTypes    StoMaType       = ma_sma;  // Stochastic average type      
input int          SigPeriod       = 3;       // Stochastic signal period
input enMaTypes    SigMaType       = ma_sma;  // Signal average type      
input enStochPrice StoPrice        = sto_hil; // Price :
input bool         AlertsOn        = false;   // Turn alerts on?
input bool         AlertsOnCurrent = true;    // Alert on current bar?
input bool         AlertsMessage   = true;    // Display messageas on alerts?
input bool         AlertsSound     = false;   // Play sound on alerts?
input bool         AlertsEmail     = false;   // Send email on alerts?
input bool         AlertsNotify    = false;   // Send push notification on alerts?

double sto[],stoc[],sig[];
string _avgNames[]={"SMA","EMA","SMMA","LWMA"};

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
   SetIndexBuffer(0,sto ,INDICATOR_DATA);
   SetIndexBuffer(1,stoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,sig ,INDICATOR_DATA);
      IndicatorSetString(INDICATOR_SHORTNAME,_avgNames[StoMaType]+" stochastic ("+(string)StoPeriod+","+(string)StoSlowing+", of "+(string)SigPeriod+" "+_avgNames[SigMaType]+" signal)");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }
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
   
   //
   //
   //
   //
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      int start = MathMax(i-StoPeriod+1,0);
         double blo     = (StoPrice==sto_hil) ? low[ ArrayMinimum(low ,start,StoPeriod)] : close[ArrayMinimum(close,start,StoPeriod)];
         double bhi     = (StoPrice==sto_hil) ? high[ArrayMaximum(high,start,StoPeriod)] : close[ArrayMaximum(close,start,StoPeriod)];
         double sumlow  = iCustomMa(StoMaType,close[i]-blo,StoSlowing,i,rates_total,0);
         double sumhigh = iCustomMa(StoMaType,bhi     -blo,StoSlowing,i,rates_total,1);
            sto[i]  = (sumhigh!=sumlow) ? 100*sumlow/sumhigh : 100; 
            sig[i]  = iCustomMa(SigMaType,sto[i],SigPeriod,i,rates_total,2);
            stoc[i] = (sto[i]>sig[i]) ? 1 : (sto[i]<sig[i]) ? 2 : (i>0) ? stoc[i-1] : 0;
   }
   manageAlerts(time,stoc,rates_total);
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

void manageAlerts(const datetime& time[], double& trend[], int bars)
{
   if (!AlertsOn) return;
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] == 1) doAlert(time1,"up");
         if (trend[whichBar] == 2) doAlert(time1,"down");
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

      message = _Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" stochastic state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" stochastic",message);
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
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
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
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
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