//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Wilders DMI - averages"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "ADX trend"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'200,255,180',clrMistyRose
#property indicator_label2  "ADX"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "ADXR"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGold
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
#property indicator_label4  "Level"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT
//
//---
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int       AdxPeriod    = 14;        // ADX (DMI) period
input double    AdxLevel     = 20;        // ADX level
input bool      ShowADX      = true;      // ADX visible
input bool      ShowADXR     = false;     // ADXR visible
input enMaTypes AverageType  = ma_smma;   // Average type
//
//---
//
double DIp[],DIm[],ADX[],ADXR[],Level[];
string _maNames[] = {"SMA","EMA","SMMA","LWMA"};

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,DIp,INDICATOR_DATA);
   SetIndexBuffer(1,DIm,INDICATOR_DATA);
   SetIndexBuffer(2,ADX,INDICATOR_DATA); 
   SetIndexBuffer(3,ADXR,INDICATOR_DATA); 
   SetIndexBuffer(4,Level,INDICATOR_DATA); 
   IndicatorSetString(INDICATOR_SHORTNAME,_maNames[AverageType]+" Wilder''s DMI ("+string(AdxPeriod)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
double averages[][4];
#define _DIp  0
#define _DIm  1
#define _TR   2
#define _Adx  3

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
   if (ArrayRange(averages,0)!=rates_total) ArrayResize(averages,rates_total);

   //
   //
   //
   //
   //
   
   for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
   {
         double currTR  = MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
         double DeltaHi = high[i] - high[i-1];
	      double DeltaLo = low[i-1] - low[i];
         double plusDM  = 0.00;
         double minusDM = 0.00;
            if ((DeltaHi > DeltaLo) && (DeltaHi > 0)) plusDM  = DeltaHi;
            if ((DeltaLo > DeltaHi) && (DeltaLo > 0)) minusDM = DeltaLo;      
         
         //
         //---
         //
                     
            averages[i][_DIp]  = iCustomMa(AverageType,plusDM ,AdxPeriod,i,rates_total,0);
            averages[i][_DIm]  = iCustomMa(AverageType,minusDM,AdxPeriod,i,rates_total,1);
            averages[i][_TR]   = iCustomMa(AverageType,currTR ,AdxPeriod,i,rates_total,2);
            Level[i]           = AdxLevel;

         //
         //---
         //
                  
            DIp[i]  = 0.00;                   
            DIm[i]  = 0.00;
            ADX[i]  = EMPTY_VALUE;
            ADXR[i] = EMPTY_VALUE;
            if (averages[i][_TR] > 0)
               {              
                  DIp[i] = 100.00 * averages[i][_DIp]/averages[i][_TR];
                  DIm[i] = 100.00 * averages[i][_DIm]/averages[i][_TR];
               }            

            if(ShowADX)
               {
                  double DX;
                  if((DIp[i] + DIm[i])>0) 
                       DX = 100*MathAbs(DIp[i] - DIm[i])/(DIp[i] + DIm[i]); 
                  else DX = 0.00;
                  averages[i][_Adx] = iCustomMa(AverageType,DX,AdxPeriod,i,rates_total,3);
                  ADX[i] = averages[i][_Adx];
                  if(ShowADXR && i>=AdxPeriod)
                         ADXR[i] = 0.5*(ADX[i] + ADX[i-AdxPeriod]);
               }
      }   
   return(rates_total);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _maInstances 4
#define _maWorkBufferx1 _maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
