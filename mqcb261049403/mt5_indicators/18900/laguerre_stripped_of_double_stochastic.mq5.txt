//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   8
#property indicator_label1  "Fill 1"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'0,205,126',C'155,0,126'
#property indicator_label2  "Fill 2"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'0,180,126',C'180,0,126'
#property indicator_label3  "Fill 3"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'0,155,126',C'205,0,126'
#property indicator_label4  "Laguerre 1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_label5  "Laguerre 2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_label6  "Laguerre 3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGray
#property indicator_label7  "Laguerre 4"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGray
#property indicator_label8  "Double stochastic"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrSilver
#property indicator_width8  2

//
//
//
//
//

input  int    StochasticPeriod  = 55;   // Stochastic period
input  int    EMAPeriod         = 15;   // Smoothing period
input  double Gamma             = 0.75; // Laguerre gamma

double lagg1u[],lagg1d[],lagg2u[],lagg2d[],lagg3u[],lagg3d[],lagg1[],lagg2[],lagg3[],lagg4[],stow[],stoch[];

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
   SetIndexBuffer( 0,lagg1u ,INDICATOR_DATA);
   SetIndexBuffer( 1,lagg1d ,INDICATOR_DATA);
   SetIndexBuffer( 2,lagg2u ,INDICATOR_DATA);
   SetIndexBuffer( 3,lagg2d ,INDICATOR_DATA);
   SetIndexBuffer( 4,lagg3u ,INDICATOR_DATA);
   SetIndexBuffer( 5,lagg3d ,INDICATOR_DATA);
   SetIndexBuffer( 6,lagg1  ,INDICATOR_DATA);
   SetIndexBuffer( 7,lagg2  ,INDICATOR_DATA);
   SetIndexBuffer( 8,lagg3  ,INDICATOR_DATA);
   SetIndexBuffer( 9,lagg4  ,INDICATOR_DATA);
   SetIndexBuffer(10,stoch  ,INDICATOR_DATA);
   SetIndexBuffer(11,stow   ,INDICATOR_CALCULATIONS);
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

   double alpha = 2.0/(1.0+EMAPeriod);
   int i=MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
         int start = MathMax(i-StochasticPeriod+1,0);
         double min = low [ArrayMinimum(low ,start,StochasticPeriod)];
         double max = high[ArrayMaximum(high,start,StochasticPeriod)];
         double sto = (max!=min) ? (close[i]-min)/(max-min)*100.00 : 0;
                stow[i] = (i>0) ? stow[i-1]+alpha*(sto-stow[i-1]) : sto;
   
                min = stow[ArrayMinimum(stow,start,StochasticPeriod)];
                max = stow[ArrayMaximum(stow,start,StochasticPeriod)];
                sto = (max!=min) ? (stow[i]-min)/(max-min)*100.00 : 0;
                stoch[i] = (i>0) ? stoch[i-1]+alpha*(sto-stoch[i-1]) : sto;

      //
      //
      //
      //
      //
      
      double laga,lagb,lagc,lagd; 
         iLaGuerre(stoch[i],Gamma,laga,lagb,lagc,lagd,i,rates_total,0);
            lagg1[i]  = laga;
            lagg2[i]  = lagb;
            lagg3[i]  = lagc;
            lagg4[i]  = lagd;
            lagg1u[i] = laga;
            lagg1d[i] = lagb;
            lagg2u[i] = lagb;
            lagg2d[i] = lagc;
            lagg3u[i] = lagc;
            lagg3d[i] = lagd;
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

double workLag[][4];
void iLaGuerre(double price, double gamma, double& val1, double& val2, double& val3, double& val4, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workLag,0)!=bars) ArrayResize(workLag,bars); instanceNo*=4;

   //
   //
   //
   //
   //

   gamma = MathMax(MathMin(gamma,0.99),0.01);
   if (i>0)
   {      
      workLag[i][instanceNo+0] = (1.0 - gamma)*price                                          + gamma*workLag[i-1][instanceNo+0];
	   workLag[i][instanceNo+1] = -gamma*workLag[i][instanceNo+0] + workLag[i-1][instanceNo+0] + gamma*workLag[i-1][instanceNo+1];
	   workLag[i][instanceNo+2] = -gamma*workLag[i][instanceNo+1] + workLag[i-1][instanceNo+1] + gamma*workLag[i-1][instanceNo+2];
	   workLag[i][instanceNo+3] = -gamma*workLag[i][instanceNo+2] + workLag[i-1][instanceNo+2] + gamma*workLag[i-1][instanceNo+3];
   }	   
   else for (int k=0; k<4; k++) workLag[i][instanceNo+k] = price;
   val1 = workLag[i][instanceNo+0];
   val2 = workLag[i][instanceNo+1];
   val3 = workLag[i][instanceNo+2];
   val4 = workLag[i][instanceNo+3];
}