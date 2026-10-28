//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "RSi of adaptive T3"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "RSi of adaptive T3"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

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

input ENUM_TIMEFRAMES TimeFrame      = PERIOD_CURRENT; // Time frame
input int             RsiPeriod      = 25;             // Rsi period
input enPrices        Price          = pr_close;       // Price to use
input enRsiTypes      RsiType        = rsi_rap;        // Rsi type
input double          T3Period       = 15;             // T3 Calculation period
input double          T3Hot          = 0.7;            // T3 hot value
input bool            T3Original     = true;           // Original Tillson T3 calculation?
input double          LevelUp        = 80;             // Level up
input double          LevelDown      = 20;             // Level down
input int             AdaptivePeriod = 25;             // Period for adapting
input int             ColorSteps     = 20;             // Color steps for drawing
input color           ColorFrom      = clrOrangeRed;   // Color down
input color           ColorTo        = clrLimeGreen;   // Color Up
input bool            ShowLine       = true;           // Show colored line
input bool            Interpolate    = true;           // Interpolate in multi time frame mode?

//
//
//
//
//
//

double rsi[],rsic[],rsiha[],rsihb[],rsihc[],count[];
int     _mtfHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,RsiPeriod,Price,RsiType,T3Period,T3Hot,T3Original,LevelUp,LevelDown,AdaptivePeriod,ColorSteps)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int cSteps;
int OnInit()
{
   SetIndexBuffer(0,rsiha,INDICATOR_DATA); 
   SetIndexBuffer(1,rsihb,INDICATOR_DATA); 
   SetIndexBuffer(2,rsihc,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(3,rsi  ,INDICATOR_DATA); 
   SetIndexBuffer(4,rsic ,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(5,count,INDICATOR_CALCULATIONS); 
   
      //
      //
      //
      //
      //
      
      cSteps = (ColorSteps>1) ? ColorSteps : 2;
         PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,cSteps);
         PlotIndexSetInteger(1,PLOT_COLOR_INDEXES,cSteps);
         for (int i=0;i<cSteps;i++) PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,gradientColor(i,cSteps,ColorFrom,ColorTo));
         if (ShowLine)
               for (int i=0;i<cSteps;i++) PlotIndexSetInteger(1,PLOT_LINE_COLOR,i,gradientColor(i,cSteps,ColorFrom,ColorTo));
         else  for (int i=0;i<cSteps;i++) PlotIndexSetInteger(1,PLOT_LINE_COLOR,i,clrNONE);
         timeFrame = MathMax(_Period,TimeFrame);
            if (timeFrame != _Period) _mtfHandle = _mtfCall;
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" "+getRsiName(RsiType)+" T3 adaptive filtered ("+(string)RsiPeriod+","+(string)T3Period+","+(string)AdaptivePeriod+")");
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
            if (_mtfHandle==INVALID_HANDLE) _mtfHandle = _mtfCall;
            if (_mtfHandle==INVALID_HANDLE)              return(0);
            if (CopyBuffer(_mtfHandle,5,0,1,result)==-1) return(0); 
      
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
                          _mtfCopy(rsiha,0);
                          _mtfCopy(rsihb,1);
                          _mtfCopy(rsihc,2);
                          _mtfCopy(rsi  ,3);
                          _mtfCopy(rsic ,4);
                   
                          //
                          //
                          //
                          //
                          //
                   
                          if (!Interpolate) continue;  CopyTime(_Symbol,TimeFrame,time[i  ],1,currTime); 
                              if (i<(rates_total-1)) { CopyTime(_Symbol,TimeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                              #define _interpolate(_buff) _buff[i-k] = _buff[i]+(_buff[i-n]-_buff[i])*k/n
                                 for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                                 for(k=1; (i-k)>=0 && k<n; k++)
                                 {
                                    _interpolate(rsiha);
                                    _interpolate(rsihb);
                                    _interpolate(rsi  );
                                 }
                }
                return(i);
      }

   //
   //
   //
   //
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total; i++)
   {
     double price  = getPrice(Price,open,close,high,low,i,rates_total);
     double dev    = iDeviation(price,iSma(price,AdaptivePeriod,rates_total,i,0),AdaptivePeriod,rates_total,i);
     double avg    = iSma(dev,AdaptivePeriod,rates_total,i,1);
     double period = (dev!=0) ? T3Period*avg/dev : T3Period;

         //
         //
         //
         //
         //
           
         rsi[i]   = iRsi(RsiType,iT3(price,period,T3Hot,T3Original,i,rates_total,0),RsiPeriod,i,rates_total);
         rsiha[i] = rsi[i];
         rsihb[i] = (rsi[i]>LevelUp) ? LevelUp :  (rsi[i]<LevelDown) ? LevelDown : rsi[i];
         rsic[i]  = MathFloor(MathMin(rsi[i],99.9999)*cSteps/100.0);
         rsihc[i] = rsic[i];
   }
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
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

#define _rsiInstances    1
#define _rsiInstanceSize 13
double workRsi[][_rsiInstances*_rsiInstanceSize];
#define _price  0
#define _prices 3
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1
#define _smallRsiValue 0.0000000000000001

double iRsi(int rsiMode, double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
      int z = instanceNo*_rsiInstanceSize; 
   
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
            return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],_smallRsiValue)+1));
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
                   workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/MathMax(up+dn,_smallRsiValue)-workRsi[r-1][z+_rsival]);
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
            return(100 * up /MathMax(up + dn,_smallRsiValue));      
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
            return(50*(up-dn)/MathMax(up+dn,_smallRsiValue)+50);      
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
                   workRsi[r][instanceNo+_rsival] = 100.0-100.0/(1.0+sump/MathMax(sumn,_smallRsiValue));
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
                          workRsi[r][instanceNo+_rsival] = 100-100/(1.0+(avgUp/MathMax(avgDn,_smallRsiValue)));
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
            return(MathMax(MathMin((mom/MathMax(moa,_smallRsiValue)+1.0)*50.0,100.00),0.00)); 
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

double workDev[];
double iDeviation(double price, double dMA, int period, int totalBars, int i)
{
   if (ArrayRange(workDev,0)!= totalBars) ArrayResize(workDev,totalBars); workDev[i] = price;
   double dSum = 0;
      for(int k=0; (i-k)>=0 && k<period; k++) dSum += (workDev[i-k]-dMA)*(workDev[i-k]-dMA);
   return(MathSqrt(dSum/period));
}

//
//
//
//
//

double workSma[][2];
double iSma(double price, int period, int totalBars, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= totalBars) ArrayResize(workSma,totalBars);

   //
   //
   //
   //
   //

   workSma[r][instanceNo] = price;
   double avg = price; int k=1; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo];  
   return(avg/(double)k);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _t3Instances    1
#define _t3InstanceSize 6
double workT3[][_t3Instances*_t3InstanceSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != bars)                ArrayResize(workT3,bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*_t3InstanceSize; for (int k=0; k<_t3InstanceSize; k++) workT3[r][k+buffer] = price;
   if (r>1 && period>1)
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
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

#define _pricesInstances    1
#define _pricesInstanceSize 4
double workHa[][_pricesInstances*_pricesInstanceSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesInstanceSize;
         
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