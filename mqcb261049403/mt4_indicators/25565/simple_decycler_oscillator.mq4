//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrSilver
#property indicator_color2  clrDeepSkyBlue
#property indicator_color3  clrSandyBrown
#property indicator_color4  clrSandyBrown
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2

//
//
//

extern double             HPPeriod   = 125;         // Slow high pass period
extern double             K          = 1.0;         // Slow high pass multiplier
extern double             HPPeriod2  = 100;         // Fast high pass period
extern double             K2         = 1.2;         // Fast high pass multiplier
extern ENUM_APPLIED_PRICE Price      = PRICE_CLOSE; // Price 

double deo[],deo2[],deo2da[],deo2db[],trend[];

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,deo);   
   SetIndexBuffer(1,deo2);
   SetIndexBuffer(2,deo2da);
   SetIndexBuffer(3,deo2db);
   SetIndexBuffer(4,trend);
      for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
      IndicatorShortName("Simple decyler oscillator ("+(string)HPPeriod+","+(string)K+","+(string)HPPeriod2+","+(string)K2+")");
   return(INIT_SUCCEEDED); 
}
void OnDeinit(const int reason){ }


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   
   //
   //
   //
   
      if (trend[i]==-1) CleanPoint(i,deo2da,deo2db);
      for(; i>=0 && !_StopFlag; i--)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
            deo[i]    = 100*K *iHp(price-iHp(price,HPPeriod ,i,rates_total,0),HPPeriod ,i,rates_total,1)/price;
            deo2[i]   = 100*K2*iHp(price-iHp(price,HPPeriod2,i,rates_total,2),HPPeriod2,i,rates_total,3)/price;
            deo2da[i] = deo2db[i] = EMPTY_VALUE;
            if (i<rates_total-1) trend[i]=trend[i+1];
               if (deo2[i]>deo[i]) trend[i] =  1;
               if (deo2[i]<deo[i]) trend[i] = -1;
               if (trend[i]==-1) PlotPoint(i,deo2da,deo2db,deo2);
      }       
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
//

double workHp[][8];
#define  Pi 3.14159265358979323846264338327950288
#define _hpPrice 0
#define _hpValue 1

double iHp(double price, double period, int i, int bars, int instanceNo=0)
{
   if (period<=1) return(0);
   static int workHpSize = -1;
   if (workHpSize<=bars) { ArrayResize(workHp,bars+500); workHpSize = ArrayRange(workHp,0); if (workHpSize<=bars) return(0); } i=bars-i-1; instanceNo*=2;
   
   //
   //
   //

   workHp[i][instanceNo+_hpPrice] = price;
   if (i<=2)  workHp[i][instanceNo+_hpValue] = 0;
   else  
   {          
      double angle = 0.707*2.0*Pi/period;
      double alpha = (cos(angle)+sin(angle)-1.0)/cos(angle);
         
      //
      //
      //
        
      workHp[i][instanceNo+_hpValue] = (1-alpha/2.0)*(1-alpha/2.0)*(workHp[i][instanceNo+_hpPrice]-2.0*workHp[i-1][instanceNo+_hpPrice]+workHp[i-2][instanceNo+_hpPrice]) + 2.0*(1-alpha)*workHp[i-1][instanceNo+_hpValue] - (1-alpha)*(1-alpha)*workHp[i-2][instanceNo+_hpValue];         
   }
   return(workHp[i][instanceNo+_hpValue]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}