//+------------------------------------------------------------------+
//|                                               J_TPO_Velocity.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a five-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- five colors are used in the histogram
#property indicator_color1 Gray,Lime,Blue,Red,Magenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Len_=14; // Smoothing period
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double ExtBuffer[],ColorExtBuffer[];
int Len;
double normalization,Lenp1half,arr1[],arr2[],arr3[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables
   Len=Len_;
   if(Len<3) Len=3;
   normalization=12.0/(Len*(Len-1)*(Len+1));
   Lenp1half=(Len+1)*0.5;
//---- initialization of variables of the start of data calculation 
   min_rates_total=2*Len+1;
//---- memory distribution for variables' arrays
   int size=Len+2;
   if(ArrayResize(arr1,size)<size) {Print("Failed to distribute the memory for arr1[] array"); return(-1);}
   if(ArrayResize(arr2,size)<size) {Print("Failed to distribute the memory for arr2[] array"); return(-1);}
   if(ArrayResize(arr3,size)<size) {Print("Failed to distribute the memory for arr3[] array"); return(-1);}

   ArrayInitialize(arr1,0);
   ArrayInitialize(arr2,0);
   ArrayInitialize(arr3,0);

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the MAPeriod indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- set ColorExtBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);

//---- indexing the elements in buffers as timeseries
   ArraySetAsSeries(ExtBuffer,true);
   ArraySetAsSeries(ColorExtBuffer,true);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculation of the half of the range                             |
//+------------------------------------------------------------------+  
double Range(int period,const double &High[],const double &Low[],int shift)
  {
//----
   double H=High[ArrayMaximum(High,shift,period)];
   double L=Low[ArrayMinimum(Low,shift,period)];
//----
   return((H-L)/_Point);
  }
//+------------------------------------------------------------------+
//| Расчет J_TPO                                                     |
//+------------------------------------------------------------------+  
double J_TPO_value(int period,const double &Array[],int shift)
  {
//----
   double value;
   double accum,tmp,maxval;
   int j,maxloc,m;
   bool flag;

   accum=0;

   for(m=1; m<=period; m++)
     {
      arr2[m] = m;
      arr3[m] = m;
      arr1[m] = Array[shift+period-m];
     }

   for(m=1; m<period; m++)
     {
      maxval = arr1[m];
      maxloc = m;
      for(j=m+1; j<=period; j++)
         if(arr1[j]<maxval)
           {
            maxval = arr1[j];
            maxloc = j;
           }

      tmp=arr1[m];
      arr1[m]=arr1[maxloc];
      arr1[maxloc]=tmp;
      tmp=arr2[m];
      arr2[m]=arr2[maxloc];
      arr2[maxloc]=tmp;
     }

   m=1;
   while(m<Len)
     {
      j=m+1;
      flag=true;
      accum=arr3[m];

      while(flag)
        {
         if(arr1[m]!=arr1[j])
           {
            if(j-m>1)
              {
               accum=accum/(j-m);
               for(int n=m; n<=j-1; n++) arr3[n]=accum;
              }

            flag=false;
           }
         else
           {
            accum+=arr3[j];
            j++;
           }
        }
      m=j;
     }

   for(accum=0,m=1; m<=period; m++) accum+=(arr3[m]-Lenp1half) *(arr2[m]-Lenp1half);

   value=normalization*accum;
//----
   return(value);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit1,limit2;

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit1=rates_total-min_rates_total-1; // starting index for calculation of all bars
      limit2=limit1-1;
     }
   else
     {
      limit1=rates_total-prev_calculated; // starting index for calculation of new bars
      limit2=limit1;                      // starting index for calculation of new bars
     }

//---- main indicator calculation loop
   for(int bar=limit1; bar>=0 && !IsStopped(); bar--) ExtBuffer[bar]=J_TPO_value(Len,close,bar)*Range(Len,high,low,bar)/Len;

//---- main cycle of the indicator coloring
   for(int bar=limit2; bar>=0 && !IsStopped(); bar--)
     {
      ColorExtBuffer[bar]=0;

      if(ExtBuffer[bar]>0)
        {
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=1;
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=2;
        }

      if(ExtBuffer[bar]<0)
        {
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=3;
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=4;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
