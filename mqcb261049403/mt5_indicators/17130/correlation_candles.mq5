//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1   "correlation candles"
#property indicator_type1    DRAW_COLOR_CANDLES
#property indicator_color1   clrGray,clrLimeGreen,clrSandyBrown
#property indicator_maximum  1
#property indicator_minimum -1

//
//
//
//
//

enum enCorrType
{
   cor_spe,  // Spearman rank correlation
   cor_pea   // Pearson rank correlation
};
input int        CorPeriod = 32;      // Correlation rank
input enCorrType CorType   = cor_spe; // Correlation type

double canc[],cano[],canh[],canl[],colors[];
string corrNames[] = {"Spearman","Pearson"};

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
   SetIndexBuffer(0,cano  ,INDICATOR_DATA);
   SetIndexBuffer(1,canh  ,INDICATOR_DATA);
   SetIndexBuffer(2,canl  ,INDICATOR_DATA);
   SetIndexBuffer(3,canc  ,INDICATOR_DATA);
   SetIndexBuffer(4,colors,INDICATOR_COLOR_INDEX);
      IndicatorSetString(INDICATOR_SHORTNAME,corrNames[CorType]+" candles ("+(string)CorPeriod+")");
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
      int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
      {
         double values[4];
         values[0] = iCorrelation(CorType,open[i] ,CorPeriod,i,rates_total,0);
         values[1] = iCorrelation(CorType,close[i],CorPeriod,i,rates_total,1);
         values[2] = iCorrelation(CorType,high[i] ,CorPeriod,i,rates_total,2);
         values[3] = iCorrelation(CorType,low[i]  ,CorPeriod,i,rates_total,3);
                colors[i] = (values[0]>values[1]) ? 2 : (values[0]<values[1]) ? 1 : 0; ArraySort(values);
                canl[i]   = values[0];
                cano[i]   = (open[i]>close[i]) ? values[1] :  values[2];
                canc[i]   = (open[i]<close[i]) ? values[1] :  values[2];
                canh[i]   = values[3];
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

#define correlationInstances 4
double iCorrelation(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case cor_pea  : return(iPearson(price,(int)length,r,bars,instanceNo));
      case cor_spe  : return(iSpearman(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workPearson[][correlationInstances];
double iPearson(double value, int period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workPearson,0)!=bars) ArrayResize(workPearson,bars); workPearson[i][instanceNo]=value;
   
   //
   //
   //
   //
   //
   
   double SumXY=0, SumXX=0, SumYY=0, SumY=0, SumX=0;         
   for(int k=0; k<period && (i-k)>=0; k++)
   {
      double val = workPearson[i-k][instanceNo];
             SumX  += val;  
             SumY  += k;  
             SumXX += val*val;
             SumYY += k*k;         
             SumXY += val*k; 
   }
   double SXY    =  period*SumXY-SumY*SumX; 
   double SXXYY  = (period*SumXX-SumX*SumX)*(period*SumYY-SumY*SumY);
   double result = (SXXYY!=0) ? -SXY/(MathSqrt(MathAbs(SXXYY))) : 0;
   return(result);
}

//
//
//
//
//

double workSpearman[][correlationInstances];
double iSpearman(double value, int period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workSpearman,0)!=bars) ArrayResize(workSpearman,bars); workSpearman[i][instanceNo]=value;

   //
   //
   //
   //
   //
      
   double total=0; 
   double data[]; ArrayResize(data, period); ArrayInitialize(data,0);
      for (int k=0; k<period && (i-k)>=0; k++) data[k] = workSpearman[i-k][instanceNo];
      for (int k=0; k<period; k++) { int max = ArrayMaximum(data); total += (max-k)*(max-k); data[max] = 0; }
	return(1.0-6.0*total/(period*(period*period-1.0)));
}