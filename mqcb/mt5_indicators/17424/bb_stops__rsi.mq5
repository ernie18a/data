//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   6
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DASH
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDodgerBlue
#property indicator_width4  3
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSandyBrown
#property indicator_width5  3
#property indicator_type6   DRAW_COLOR_ARROW
#property indicator_color6  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_width6  2

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
enum enRsiTypes
{
   rsi_cut,  // Cuttler's RSI
   rsi_ehl,  // Ehlers' smoothed RSI
   rsi_har,  // Harris' RSI
   rsi_rap,  // Rapid RSI
   rsi_rsi,  // RSI 
   rsi_rsx,  // RSX
   rsi_slo   // Slow RSI
};

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame
input int             RsiPeriod       = 32;       // RSI period
input enRsiTypes      RsiType         = rsi_rsi;  // RSI type
input enPrices        Price           = pr_close; // Price 
input int             MaPeriod        = 20;       // Bollinger bands period
input enMaTypes       MaMethod        = ma_sma;   // Moving average method
input int             DeviationPeriod = 20;       // Deviations period
input double          Deviation       = 1;        // Deviation
input bool            DeviationSample = false;    // Deviation sample correction?
input double          Risk            = 1;        // Risk
input bool            AlertsOn        = false;    // Turn alerts on?
input bool            AlertsOnCurrent = true;     // Alert on current bar?
input bool            AlertsMessage   = true;     // Display messages on alerts?
input bool            AlertsSound     = false;    // Play sound on alerts?
input bool            AlertsEmail     = false;    // Send email on alerts?
input bool            AlertsNotify    = false;    // Send push notification on alerts?
input bool            Interpolate     = true;     // Interpolate mtf data ?

double rsi[],bba[],bbc[],bblu[],bbld[],amax[],amin[],bmax[],bmin[],trend[],count[];
int     _mtfHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,RsiPeriod,RsiType,Price,MaPeriod,MaMethod,DeviationPeriod,Deviation,DeviationSample,Risk,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotify)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0 ,bmax ,INDICATOR_DATA);
   SetIndexBuffer(1 ,bmin ,INDICATOR_DATA);
   SetIndexBuffer(2 ,rsi  ,INDICATOR_DATA);
   SetIndexBuffer(3 ,bblu ,INDICATOR_DATA);
   SetIndexBuffer(4 ,bbld ,INDICATOR_DATA); 
   SetIndexBuffer(5 ,bba  ,INDICATOR_DATA);  PlotIndexSetInteger(5,PLOT_ARROW,159);
   SetIndexBuffer(6 ,bbc  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7 ,amax ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8 ,amin ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9 ,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,count,INDICATOR_CALCULATIONS);
      timeFrame = MathMax(_Period,TimeFrame);
      IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" bb stops "+getRsiName(RsiType)+" ("+(string)RsiPeriod+","+(string)MaPeriod+")");
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
            if (CopyBuffer(_mtfHandle,10,0,1,result)==-1) return(0); 
      
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
                          _mtfCopy(bmax,0);
                          _mtfCopy(bmin,1);
                          _mtfCopy(rsi ,2);
                          _mtfCopy(bblu,3);
                          _mtfCopy(bbld,4);
                          _mtfCopy(bbc ,6);
                           bba[i] = (i>0) ? (bbc[i]!=bbc[i-1]) ?  (bbc[i]==1) ? bblu[i] : bbld[i] : EMPTY_VALUE : EMPTY_VALUE;
                   
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
                                 _mtfInterpolate(rsi);
                                 _mtfInterpolate(bmax);
                                 _mtfInterpolate(bmin);
                                  if (bbc[i-k]==1) bblu[i-k] = bmin[i-k];
                                  if (bbc[i-k]==2) bbld[i-k] = bmax[i-k];
                                  if (bba[i-k]!=EMPTY_VALUE) bba[i-k] = (bbc[i-k]==1) ? bblu[i-k] : bbld[i-k];
                              }                                 
                }
                return(i);
      }
   
   //
   //
   //
   //
   //
   
   
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      
      rsi[i] = iRsi(RsiType,getPrice(Price,open,close,high,low,i,rates_total,0),RsiPeriod,i,rates_total);
      double dev   = iDeviation(rsi[i],DeviationPeriod,DeviationSample,i,rates_total);
      double ma    = iCustomMa(MaMethod,rsi[i],MaPeriod,i,rates_total,0);
               amax[i]  = ma+dev*Deviation;
               amin[i]  = ma-dev*Deviation;
   	         bmax[i]  = amax[i]+0.5*(Risk-1)*(amax[i]-amin[i]);
	  	         bmin[i]  = amin[i]-0.5*(Risk-1)*(amax[i]-amin[i]);
               trend[i] = (i>0) ? (rsi[i]>amax[i-1]) ? 1 : (rsi[i]<amin[i-1]) ? -1 : trend[i-1] : 0;
                       if (i>0)
                       {
                           if (trend[i]==-1 && amax[i]>amax[i-1]) amax[i] = amax[i-1];
                           if (trend[i]== 1 && amin[i]<amin[i-1]) amin[i] = amin[i-1];
                           if (trend[i]==-1 && bmax[i]>bmax[i-1]) bmax[i] = bmax[i-1];
                           if (trend[i]== 1 && bmin[i]<bmin[i-1]) bmin[i] = bmin[i-1];
                       }                  
               bblu[i] = EMPTY_VALUE; bbld[i] = EMPTY_VALUE;
                  if (trend[i] ==  1) { bblu[i] = bmin[i]; bbc[i] = 1; }
                  if (trend[i] == -1) { bbld[i] = bmax[i]; bbc[i] = 2; }
               bba[i] = (i>0) ? (trend[i]!=trend[i-1]) ? (trend[i]== 1) ? bblu[i] : bbld[i] : EMPTY_VALUE :  EMPTY_VALUE;
   }
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,bbc,rates_total);
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
//

string getRsiName(int method)
{
   switch (method)
   {
      case rsi_rsi: return("RSI");
      case rsi_rsx: return("RSX");
      case rsi_cut: return("Cuttler's RSI");
      case rsi_har: return("Haris' RSI");
      case rsi_rap: return("Rapid RSI");
      case rsi_slo: return("Slow RSI");
      case rsi_ehl: return("Ehlers' smoothed RSI");
      default:      return("");
   }      
}

//
//
//
//
//

#define rsiInstances 3
double workRsi[][rsiInstances*13];
#define _price  0
#define _prices 3
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
      int z = instanceNo*13; 
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/MathMax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
            return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
         }
         
      //
      //
      //
      //
      //
      
      case rsi_slo :
         {         
            double up = 0, dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
                   workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/MathMax(up+dn,DBL_MIN)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            double up = 0, dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            return(100 * up /MathMax(up + dn,DBL_MIN));      
         }            
         
      //
      //
      //
      //
      //
               
      case rsi_ehl :
         {
            double up = 0, dn = 0;
            workRsi[r][z+_prices] = (r>2) ? (workRsi[r][z+_price]+2.*workRsi[r-1][z+_price]+workRsi[r-2][z+_price])/4.0 : price;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_prices]- workRsi[r-k-1][z+_prices];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            return(50*(up-dn)/MathMax(up+dn,DBL_MIN)+50);      
         }            

      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) 
                        sump += diff;
                  else  sumn -= diff;
            }
                   workRsi[r][instanceNo+_rsival] = 100.0-100.0/(1.0+sump/MathMax(sumn,DBL_MIN));
            return(workRsi[r][instanceNo+_rsival]);
         }            

      //
      //
      //
      //
      //

      case rsi_har :
         {
            double avgUp=0,avgDn=0,up=0,dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
                          workRsi[r][instanceNo+_rsival] = 100-100/(1.0+(avgUp/MathMax(avgDn,DBL_MIN)));
                   return(workRsi[r][instanceNo+_rsival]);
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = MathAbs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00)); 
         }            
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

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=bars) ArrayResize(workDev,bars); workDev[i][instanceNo] = value;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
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

void manageAlerts(const datetime& _time[], double& _trend[], int bars)
{
   if (AlertsOn)
   {
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = _time[whichBar];
      if (_trend[whichBar] != _trend[whichBar-1])
      {
         if (_trend[whichBar] == 1) doAlert(time1," up");
         if (_trend[whichBar] == 2) doAlert(time1," down");
      }         
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

      //
      //
      //
      //
      //

      string message = timeFrameToString(_Period)+" "+TimeToString(TimeLocal(),TIME_SECONDS)+" "+_Symbol+" bb stops "+getRsiName(RsiType)+" state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" bb stops "+getRsiName(RsiType),message);
         if (AlertsNotify)  SendNotification(message);
         if (AlertsSound)   PlaySound("alert2.wav");
   }
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