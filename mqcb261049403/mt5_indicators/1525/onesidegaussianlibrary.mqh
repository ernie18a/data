//+------------------------------------------------------------------+
//|                                       OneSideGaussianLibrary.mqh |
//|                                       Copyright © 2008, Tinytjan |
//|                                                 tinytjan@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Tinytjan"
#property link      "tinytjan@mail.ru"

#define MAXLENGTH 34

int    levels[]={1,2,3,5,8,13,21,MAXLENGTH};
double GaussianBuffer[][8];
//+------------------------------------------------------------------+
//|  smoothing algorithms enumeration                                |
//+------------------------------------------------------------------+
enum SmoothMode
  {
   Smooth1 = 0,
   Smooth2,
   Smooth3,
   Smooth4,
   Smooth5,
   Smooth6,
   Smooth7,
   Smooth8
  };
//+------------------------------------------------------------------+
//|  price timeseries enumeration                                    |
//+------------------------------------------------------------------+
enum Applied_price_
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------------------------+
//| Gaussian function                                                |
//+------------------------------------------------------------------+
// Counts function Exp((x - x0)^2/s^2)
// x0 - higher point of function
// x  - point function is counted at
// s  - width of function // don't forget about 3-sigma rule

double Gaussian(int Size,int X)
  {
//----
   return(MathExp(-X*X*9/((Size+1)*(Size+1))));
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GaussianInit()
  {
//----
   ArrayResize(GaussianBuffer,MAXLENGTH);

   for(int k=0; k<8; k++)
     {
      double sum=0.0;
      for(int i=0; i<MAXLENGTH; i++)
        {
         if(i>=levels[k]) break;
         GaussianBuffer[i][k]=Gaussian(levels[k],i);
         sum+=GaussianBuffer[i][k];
        }
        
      for(int i=0; i<MAXLENGTH; i++)
        {
         if(i>=levels[k]) break;
         GaussianBuffer[i][k]/=sum;
        }
     }
//----                            
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Smooth(
              SmoothMode level,
              int Rates_total,                 // maximum number of bars
              Applied_price_ PriceMode,        // Price constant
              int   index,                     // Shift index relative to the current bar by a specified number of periods backward or forward
              const double &Open[],
              const double &Low[],
              const double &High[],
              const double &Close[]
              )
  {
//----
   double sum = 0;
   int    limit = levels[level];

   if(index>=(Rates_total-limit)) return(CountPrice(PriceMode,index,Open,Low,High,Close));

   for(int i=0; i<limit; i++) sum+=GaussianBuffer[i][level]*CountPrice(PriceMode,index+i,Open,Low,High,Close);
//----
   return(sum);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SmoothArray(
                   SmoothMode level,
                   double &array[],
                   int Rates_total,            // maximum number of bars
                   Applied_price_ PriceMode,   // Price constant
                   int   index                 // Shift index relative to the current bar by a specified number of periods backward or forward
                   )
  {
//----
   double sum = 0;
   int    limit = levels[level];

   if(index>=(Rates_total-limit)) return(array[index]);

   for(int i=0; i<limit; i++) sum+=GaussianBuffer[i][level]*array[index+i];
//----
   return(sum);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price series                                 |
//+------------------------------------------------------------------+ 
double CountPrice(
                  Applied_price_ PriceMode, // Price constant
                  int   index,              // Shift index relative to the current bar by a specified number of periods backward or forward
                  const double &Open[],
                  const double &Low[],
                  const double &High[],
                  const double &Close[]
                  )
//CountPrice(PriceMode, index, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(int(PriceMode))
     {
      //---- Price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[index]);
      case  PRICE_OPEN: return(Open[index]);
      case  PRICE_HIGH: return(High[index]);
      case  PRICE_LOW: return(Low[index]);
      case  PRICE_MEDIAN: return((High[index]+Low[index])/2.0);
      case  PRICE_TYPICAL: return((Close[index]+High[index]+Low[index])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[index]+High[index]+Low[index])/4.0);

      //----                            
      case  8: return((Open[index]+Close[index])/2.0);
      case  9: return((Open[index]+Close[index]+High[index]+Low[index])/4.0);
      //----                                
      case 10:
        {
         if(Close[index]>Open[index])return(High[index]);
         else
           {
            if(Close[index]<Open[index])
               return(Low[index]);
            else return(Close[index]);
           }
        }
      //----         
      case 11:
        {
         if(Close[index]>Open[index])return((High[index]+Close[index])/2.0);
         else
           {
            if(Close[index]<Open[index])
               return((Low[index]+Close[index])/2.0);
            else return(Close[index]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[index]+Low[index]+Close[index];

         if(Close[index]<Open[index]) res=(res+Low[index])/2;
         if(Close[index]>Open[index]) res=(res+High[index])/2;
         if(Close[index]==Open[index]) res=(res+Close[index])/2;
         return(((res-Low[index])+(res-High[index]))/2);
        }
      //----
      default: return(Close[index]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
