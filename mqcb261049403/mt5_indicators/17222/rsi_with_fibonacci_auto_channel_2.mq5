//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 15
#property indicator_plots   10
#property indicator_label1  "Upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'221,247,221'
#property indicator_label2  "Lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'253,238,227'
#property indicator_label3  "Fibo value 0.236"
#property indicator_color3  clrDarkGray
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Fibo value 0.382"
#property indicator_color4  clrDarkGray
#property indicator_type4   DRAW_LINE
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Fibo value 0.618"
#property indicator_color5  clrDarkGray
#property indicator_type5   DRAW_LINE
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Fibo value 0.764"
#property indicator_color6  clrDarkGray
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_DOT
#property indicator_label7  "Fibo value 0.500"
#property indicator_color7  clrDarkGray
#property indicator_type7   DRAW_LINE
#property indicator_label8  "Upper band"
#property indicator_type8   DRAW_COLOR_LINE
#property indicator_color8  clrSilver,clrLimeGreen,clrSandyBrown
#property indicator_width8  2
#property indicator_label9  "Lower band"
#property indicator_type9   DRAW_COLOR_LINE
#property indicator_color9  clrSilver,clrLimeGreen,clrSandyBrown
#property indicator_width9  2
#property indicator_label10 "Rsi"
#property indicator_color10 clrSilver,clrLime,C'255,138,197'
#property indicator_type10  DRAW_COLOR_LINE
#property indicator_width10 4

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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

input int        RsiPeriod     = 14;        // Rsi period
input enPrices   RsiPrice      = pr_close;  // Price
input enRsiTypes RsiType       = rsi_rsi;   // Rsi type
input int        RsiSmooth     = 32;        // Prices smoothing period (<= 1, no smoothing)
input enMaTypes  RsiSmoothType = ma_ema;    // Prices smoothing method
input int        HighLowPeriod = 25;        // Period for Fibonacci channel

//
//
//
//
//

double bufferUp[],bufferUpc[];
double bufferDn[],bufferDnc[];
double bufferMe[],fupu[],fupd[],fdnd[],fdnu[],lev1[],lev2[],lev3[],lev4[],rsi[],rsic[];

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
   SetIndexBuffer( 0,fupu,INDICATOR_DATA); SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer( 2,fdnu,INDICATOR_DATA); SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer( 4,lev1     ,INDICATOR_DATA);
   SetIndexBuffer( 5,lev2     ,INDICATOR_DATA);
   SetIndexBuffer( 6,lev3     ,INDICATOR_DATA);
   SetIndexBuffer( 7,lev4     ,INDICATOR_DATA);
   SetIndexBuffer( 8,bufferMe ,INDICATOR_DATA);
   SetIndexBuffer( 9,bufferUp ,INDICATOR_DATA); SetIndexBuffer(10,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(11,bufferDn ,INDICATOR_DATA); SetIndexBuffer(12,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(13,rsi      ,INDICATOR_DATA); SetIndexBuffer(14,rsic     ,INDICATOR_COLOR_INDEX);
      for (int i=0; i<7; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,getRsiName(RsiType)+" ("+(string)RsiPeriod+","+(string)HighLowPeriod+", smoothing : "+(string)RsiSmooth+")");
   return(0);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      rsi[i] = iRsi(RsiType,iCustomMa(RsiSmoothType,getPrice(RsiPrice,open,close,high,low,i,rates_total),RsiSmooth,i,rates_total),RsiPeriod,i,rates_total);

          int    start = MathMax(i-HighLowPeriod+1,0);
          double ll    = rsi[ArrayMinimum(rsi,start,HighLowPeriod)];
          double hh    = rsi[ArrayMaximum(rsi,start,HighLowPeriod)];
          double rng   = hh-ll;

      bufferUp[i]  = hh;
      bufferDn[i]  = ll;
      bufferMe[i]  = (hh+ll)/2;
      fupd[i]      = bufferMe[i]; fupu[i] = bufferUp[i]; 
      fdnu[i]      = bufferMe[i]; fdnd[i] = bufferDn[i]; 
      lev1[i]      = ll+0.236*rng;
      lev2[i]      = ll+0.382*rng;
      lev3[i]      = ll+0.618*rng;
      lev4[i]      = ll+0.764*rng;
      rsic[i]      = (rsi[i]==hh && hh!=ll) ? 1 : (rsi[i]==ll && hh!=ll) ? 2 : (i>0) ? rsic[i-1] : 0 ;
      bufferUpc[i] = (i>0) ? (bufferUp[i]>bufferUp[i-1]) ? 1 : (bufferUp[i]<bufferUp[i-1]) ? 2 : bufferUpc[i-1] : 0;
      bufferDnc[i] = (i>0) ? (bufferDn[i]>bufferDn[i-1]) ? 1 : (bufferDn[i]<bufferDn[i-1]) ? 2 : bufferDnc[i-1] : 0;
   }         
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

#define _maInstances 1
#define _maWorkBufferx1 _maInstances
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