//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "DMI stochastic extreme"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "DMI stochastic extreme"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

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
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};

input ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT; // Time frame
input int             DmiPeriod         = 32;             // DMI period
input int             StochasticPeriod  = 50;             // Stochastic period
input int             StochasticSlowing =  9;             // Stochastic slowing period
input enMaTypes       SmoothingMethod   = ma_smma;        // Smoothing method for atr and dmi calculation
input enColorOn       ColorOn           = cc_onLevels;    // Change color on :
input double          LevelUp           = 90;             // Level up
input double          LevelDown         = 10;             // Level down
input bool            alertsOn          = false;          // Turn alerts on?
input bool            alertsOnCurrent   = true;           // Alert on current bar?
input bool            alertsMessage     = true;           // Display messageas on alerts?
input bool            alertsSound       = false;          // Play sound on alerts?
input bool            alertsEmail       = false;          // Send email on alerts?
input bool            alertsNotify      = false;          // Send push notification on alerts?
input bool            Interpolate       = true;           // Interpolate mtf data ?

//
//
//
//
//

double sto[],stoc[],fillu[],filld[],count[];
int indHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,DmiPeriod,StochasticPeriod,StochasticSlowing,SmoothingMethod,ColorOn,LevelUp,LevelDown,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify)

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
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,sto  ,INDICATOR_DATA); 
   SetIndexBuffer(3,stoc ,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(4,count,INDICATOR_CALCULATIONS); 
      IndicatorSetInteger(INDICATOR_LEVELS,3); 
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,LevelDown);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,(LevelUp+LevelDown)/2);
         timeFrame = MathMax(_Period,TimeFrame);
            if (timeFrame != _Period) indHandle = _mtfCall;
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" DMI stochastic extreme ("+(string)DmiPeriod+","+(string)StochasticPeriod+")");
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
   
      //
      //
      //
      //
      //
      
      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
            if (indHandle == INVALID_HANDLE) indHandle = _mtfCall;
            if (indHandle == INVALID_HANDLE) return(0);
            if (CopyBuffer(indHandle,4,0,1,result)==-1) return(0); 
             
            //
            //
            //
            //
            //
              
            #define _processed EMPTY_VALUE-1
               int i,limit = rates_total-(int)MathMin(result[0]*PeriodSeconds(timeFrame)/PeriodSeconds(_Period),rates_total); 
               for (limit=MathMax(MathMin(limit,rates_total-1),0); limit>0 && !IsStopped(); limit--) if (count[limit]==_processed) break;
               for (i=MathMin(limit,MathMax(prev_calculated-1,0)); i<rates_total && !IsStopped(); i++    )
               {
                   if (CopyBuffer(indHandle,0,time[i],1,result)==-1) break; fillu[i] = result[0];
                   if (CopyBuffer(indHandle,1,time[i],1,result)==-1) break; filld[i] = result[0];
                   if (CopyBuffer(indHandle,2,time[i],1,result)==-1) break; sto[i]   = result[0];
                   if (CopyBuffer(indHandle,3,time[i],1,result)==-1) break; stoc[i]  = result[0];
                                                                            count[i] = _processed;
                   
                   //
                   //
                   //
                   //
                   //
                   
                   #define _interpolate(buff,i,k,n) buff[i-k] = buff[i]+(buff[i-n]-buff[i])*k/n
                   if (!Interpolate) continue; CopyTime(_Symbol,TimeFrame,time[i  ],1,currTime); 
                      if (i<(rates_total-1)) { CopyTime(_Symbol,TimeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                      int n,k;
                         for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                         for(k=1; (i-k)>=0 && k<n; k++) _interpolate(sto,i,k,n);
                }     
                if (i!=rates_total) return(0); 
                for (i=MathMin(limit,MathMax(prev_calculated-1,0)); i<rates_total && !IsStopped(); i++    )
                {
                     fillu[i] = sto[i];
                     filld[i] = MathMax(MathMin(sto[i],LevelUp),LevelDown);
                }
                return(rates_total);
         }

   //
   //
   //
   //
   //

   double LevelMi = (LevelUp+LevelDown)/2.0;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double dhh     = (i>0) ? high[i]-high[i-1] : 0;
      double dll     = (i>0) ? low[i-1]-low[i]   : 0;
      double tr      = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      double atr     = iCustomMa(SmoothingMethod,tr,DmiPeriod,i,rates_total,0);

         double plusDM  = (dhh>dll && dhh>0) ? dhh : 0;
         double minusDM = (dll>dhh && dll>0) ? dll : 0;
         double plusDI  = 100*iCustomMa(SmoothingMethod,plusDM ,DmiPeriod,i,rates_total,1)/atr;
         double minusDI = 100*iCustomMa(SmoothingMethod,minusDM,DmiPeriod,i,rates_total,2)/atr;
         double osc     = plusDI-minusDI;
                sto[i]  = iStoch(osc,osc,osc,StochasticPeriod,StochasticSlowing,rates_total,i);
                switch(ColorOn)
                {
                     case cc_onLevels: stoc[i] = (sto[i]>LevelUp)  ? 1 : (sto[i]<LevelDown) ? 2 : 0; break;
                     case cc_onMiddle: stoc[i] = (sto[i]>LevelMi)  ? 1 : (sto[i]<LevelMi)   ? 2 : 0; break;
                     default :         stoc[i] = (i>0) ? (sto[i]>sto[i-1]) ? 1 : (sto[i]<sto[i-1]) ? 2 : 0 : 0;
                }                  
                fillu[i] = sto[i];
                filld[i] = MathMax(MathMin(sto[i],LevelUp),LevelDown);
   }
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,stoc,rates_total);
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

void manageAlerts(const datetime& time[], double& ttrend[], int bars)
{
   if (!alertsOn) return;
      int whichBar = bars-1; if (!alertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (ttrend[whichBar] != ttrend[whichBar-1])
      {
         if (ttrend[whichBar] == 1) doAlert(time1,"up");
         if (ttrend[whichBar] == 2) doAlert(time1,"down");
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

      string message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" dmi stochastic extreme state changed to "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" dmi stochastic extreme",message);
         if (alertsNotify)  SendNotification(message);
         if (alertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

double workSto[][5];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
double iStoch(double priceR, double priceH, double priceL, int period, int slowing, int bars, int i, int instanceNo=0)
{
   if (ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); instanceNo *= 5;
   
   //
   //
   //
   //
   //
   
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
      for (int k=1; k<period && (i-k)>=0; k++)
      {
         workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
         workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
      }                   
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for(int k=0; k<slowing && (i-k)>=0; k++)
      {
         sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
         sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
      }

   //
   //
   //
   //
   //
   
   if(sumhigh!=0.0) 
         return(100.0*sumlow/sumhigh);
   else  return(0);    
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

color getColor(int stepNo, int totalSteps, color from, color to)
{
   double stes = (double)totalSteps-1.0;
   double step = (from-to)/(stes);
   return((color)round(from-step*stepNo));
}
color gradientColor(int step, int totalSteps, color from, color to)
{
   color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
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
#define _maWorkBufferx2 2*_maInstances

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

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
         int i; for(i=ArraySize(_tfsPer)-1;i>=0;i--) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}