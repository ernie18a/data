//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Balance of market power zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Balance of market power middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Balance of market power"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrangeRed
#property indicator_width3  3

//
//
//
//
//

enum enColorOn
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle  // Change color on middle level cross
};

input double    BompSmoothPeriod = 90;           // Balance of market power smoothing period
input double    BompSmoothPhase  =  0;           // Balance of market power smoothing phase
input int       BandsPeriod      =  9;           // Bands period
input double    BandsDeviation   = 0.5;          // Bands deviation
input enColorOn ColorOn          = chg_onMiddle; // Color change on  
input bool      AlertsOn         = false;        // Turn alerts on?
input bool      AlertsOnCurrent  = true;         // Alert on current bar?
input bool      AlertsMessage    = true;         // Display messageas on alerts?
input bool      AlertsSound      = false;        // Play sound on alerts?
input bool      AlertsEmail      = false;        // Send email on alerts?
input bool      AlertsNotify     = false;        // Send push notification on alerts?

double val[],valc[],fup[],fmi[],fdn[];

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
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
      for (int i=0; i<2; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"Balance of market power ("+(string)BompSmoothPeriod+")");
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
   
   int colorOn = (BandsPeriod>1) ? ColorOn : chg_onSlope;
   int i=(int)MathMax(prev_calculated-1,0); for (;i<rates_total && !_StopFlag; i++)
   {
         double range = MathMax(high[i]-low[i],DBL_MIN);
         double buo   = (high[i]-open[i])/range;
         double buc   = (close[i]-low[i])/range;
         double buoc  = MathMax(close[i]-open[i],0)/range;
         double beo   = (open[i]-low[i])/range;
         double bec   = (high[i]-close[i])/range;
         double beoc  = MathMax(open[i]-close[i],0)/range;
      
         //
         //
         //
         //
         //
         
         val[i] = iSmooth((buo+buc+buoc)/3.0-(beo+bec+beoc)/3.0,BompSmoothPeriod,BompSmoothPhase,i,rates_total,0);
         if (BandsPeriod>1)
         {
            double avg = iSmooth(val[i],BandsPeriod,BompSmoothPhase,i,rates_total,1);
            double dev = 0;
               for(int k=0; k<BandsPeriod && (i-k)>=0; k++) dev += MathPow((val[i-k]-avg),2); dev = MathSqrt(dev/BandsPeriod);
                  fup[i] = avg+dev;
                  fdn[i] = avg-dev;
                  fmi[i] = avg;
         }
         else { fup[i] = fdn[i] = fmi[i] = val[i]; }    
         switch (colorOn)
         {
            case chg_onLevel :  valc[i] = (val[i]>fup[i]) ? 1 : (val[i]<fdn[i]) ? 2 : (val[i]<fup[i] && val[i]>fdn[i]) ? 0 : (i>0) ? valc[i-1]: 0; break;
            case chg_onMiddle : valc[i] = (val[i]>fmi[i]) ? 1 : (val[i]<fmi[i]) ? 2 : (i>0) ? valc[i-1] : 0; break;
            default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
         }                  
   }
   manageAlerts(time,valc,rates_total);
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

      message = _Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" Balance of market power state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" Balance of market power",message);
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

#define _smoothInstances     2
#define _smoothInstancesSize 10
double  _smthWork[][_smoothInstances*_smoothInstancesSize];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iSmooth(double price, double length, double phase, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(_smthWork,0)!=bars) ArrayResize(_smthWork,bars); instanceNo*=_smoothInstancesSize;
   if (price==EMPTY_VALUE) price=0;

   int k = 0; if (r==0) { for(; k<7; k++) _smthWork[0][instanceNo+k]=price; for(; k<10; k++) _smthWork[0][instanceNo+k]=0; return(price); }

      //
      //
      //
      //
      //
  
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - _smthWork[r-1][instanceNo+bsmax];
      double del2   = price - _smthWork[r-1][instanceNo+bsmin];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = (int)MathMin(r,10);

         _smthWork[r][instanceNo+volty] = (MathAbs(del1) > MathAbs(del2)) ? MathAbs(del1): (MathAbs(del1) < MathAbs(del2)) ? MathAbs(del2) : 0;
         _smthWork[r][instanceNo+vsum]  = _smthWork[r-1][instanceNo+vsum] + (_smthWork[r][instanceNo+volty]-_smthWork[r-forBar][instanceNo+volty])*div;
        
         //
         //
         //
         //
         //
              
         _smthWork[r][instanceNo+avolty] = _smthWork[r-1][instanceNo+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(_smthWork[r][instanceNo+vsum]-_smthWork[r-1][instanceNo+avolty]);
         double dVolty = (_smthWork[r][instanceNo+avolty] > 0) ? _smthWork[r][instanceNo+volty]/_smthWork[r][instanceNo+avolty] : 0;  
            if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
            if (dVolty < 1)                      dVolty = 1.0;

         //
         //
         //
         //
         //
        
         double pow2 = MathPow(dVolty, pow1);
         double len2 = MathSqrt(0.5*(length-1))*len1;
         double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

            if (del1 > 0) _smthWork[r][instanceNo+bsmax] = price; else _smthWork[r][instanceNo+bsmax] = price - Kv*del1;
            if (del2 < 0) _smthWork[r][instanceNo+bsmin] = price; else _smthWork[r][instanceNo+bsmin] = price - Kv*del2;

      //
      //
      //
      //
      //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         _smthWork[r][instanceNo+0] = price + alpha*(_smthWork[r-1][instanceNo+0]-price);
         _smthWork[r][instanceNo+1] = (price - _smthWork[r][instanceNo+0])*(1-beta) + beta*_smthWork[r-1][instanceNo+1];
         _smthWork[r][instanceNo+2] = (_smthWork[r][instanceNo+0] + R*_smthWork[r][instanceNo+1]);
         _smthWork[r][instanceNo+3] = (_smthWork[r][instanceNo+2] - _smthWork[r-1][instanceNo+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*_smthWork[r-1][instanceNo+3];
         _smthWork[r][instanceNo+4] = (_smthWork[r-1][instanceNo+4] + _smthWork[r][instanceNo+3]);

   //
   //
   //
   //
   //

   return(_smthWork[r][instanceNo+4]);
}