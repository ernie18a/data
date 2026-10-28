//+-------------------------------------------------------------------------------------+
//|                                                                 Minions.Hikkake.mq5 |
//| (CC) Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License|
//|                                                          http://www.MinionsLabs.com |
//+-------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Descriptors                                                      |
//+------------------------------------------------------------------+
#property copyright   "www.MinionsLabs.com"
#property link        "http://www.MinionsLabs.com"
#property version     "1.0"
#property description "Minions in the quest for the Hikakke patterns"
#property description " "
#property description "(CC) Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License"



//+------------------------------------------------------------------+
//| Indicator Settings                                               |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "Sell"            
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Buy"             
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Hikkake"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "HikkakeEntry"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrMagenta
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2





//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int      bufferSell_ID=0;         // put names on buffers!
int      bufferBuy_ID=1;          //
int      bufferHikkake_ID=2;      // 
int      bufferHikkakeEntry_ID=3; //

double   tickSize;                // minimum tick size for the symbol   

double   bufferSell[];            // buffers for holding the data...
double   bufferBuy[];             //
double   bufferHikkake[];         // 
double   bufferHikkakeEntry[];    //


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
  {

   SetIndexBuffer(bufferBuy_ID,bufferBuy,INDICATOR_DATA);
   SetIndexBuffer(bufferSell_ID,bufferSell,INDICATOR_DATA);
   SetIndexBuffer(bufferHikkake_ID,bufferHikkake,INDICATOR_DATA);
   SetIndexBuffer(bufferHikkakeEntry_ID,bufferHikkakeEntry,INDICATOR_DATA);

// prepare the arrows for the entry signals...
   PlotIndexSetInteger(bufferSell_ID,PLOT_ARROW,234);
   PlotIndexSetInteger(bufferBuy_ID,PLOT_ARROW,233);
   PlotIndexSetInteger(bufferHikkake_ID,PLOT_ARROW,108);
   PlotIndexSetInteger(bufferHikkakeEntry_ID,PLOT_ARROW,158);

   PlotIndexSetInteger(bufferSell_ID,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(bufferBuy_ID,PLOT_ARROW_SHIFT,10);

   tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);   //gets the tick size for the symbol. Will be used to place an order...

   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) 
  {

   int i;

   for(i=MathMax(3,prev_calculated-1);  i<rates_total;  i++) 
     {

      // HIKKAKE signal... 
      if((high[i-2]<high[i-3] && low[i-2]>low[i-3]) && 
         (high[i-1]<high[i-2] && low[i-1]<low[i-2])
         ) 
        {
         bufferHikkake[i-3] = high[i-3];   // marks the full hikkake pattern BUY
         bufferHikkake[i-2] = high[i-2];   //
         bufferHikkake[i-1] = high[i-1];   //
         bufferHikkake[i]=EMPTY_VALUE;
         bufferBuy[i]=EMPTY_VALUE;
         bufferSell[i]=EMPTY_VALUE;

         bufferHikkakeEntry[i]=high[i-2]+tickSize;  //plots the first bar entry point...

           } else {

         if((high[i-2]<high[i-3] && low[i-2]>low[i-3]) && 
            (high[i-1]>high[i-2] && low[i-1]>low[i-2])) 
           {
            bufferHikkake[i-3] = low[i-3];     // marks the full hikkake pattern SELL
            bufferHikkake[i-2] = low[i-2];     //
            bufferHikkake[i-1] = low[i-1];     //
            bufferHikkake[i]=EMPTY_VALUE;
            bufferBuy[i]=EMPTY_VALUE;
            bufferSell[i]=EMPTY_VALUE;

            bufferHikkakeEntry[i]=low[i-2]-tickSize;   //plots the first bar entry point...

              } else {
            bufferHikkake[i]=EMPTY_VALUE;        //do not print the symbol
            bufferHikkakeEntry[i]=EMPTY_VALUE;
            bufferBuy[i]=EMPTY_VALUE;
            bufferSell[i]=EMPTY_VALUE;
           }

        }

      //checks and extends the additional bars for entry, if a Hikkake is still valid...
      if(bufferHikkakeEntry[i-2]==EMPTY_VALUE && bufferHikkakeEntry[i-1]>0 && bufferHikkakeEntry[i]==EMPTY_VALUE) 
        {   // Bar 2 needed...
         bufferHikkakeEntry[i]=bufferHikkakeEntry[i-1];
        }
      if(bufferHikkakeEntry[i-3]==EMPTY_VALUE && bufferHikkakeEntry[i-2]>0 && bufferHikkakeEntry[i-1]>0 && bufferHikkakeEntry[i]==EMPTY_VALUE) 
        {   // Bar 3 needed...  and that's enough for the setup!
         bufferHikkakeEntry[i]=bufferHikkakeEntry[i-1];
        }


      // check for BUY signals...
      if((bufferHikkakeEntry[i]>0  &&  bufferHikkake[i-1]>0 && bufferHikkake[i-1]==high[i-1]) || 
         (bufferHikkakeEntry[i]>0 && bufferHikkake[i-2]>0 && bufferHikkake[i-2]==high[i-2]) ||
         (bufferHikkakeEntry[i]>0 && bufferHikkake[i-3]>0 && bufferHikkake[i-3]==high[i-3])
         ) 
        {        //It is a BUY!

         if(high[i]>=bufferHikkakeEntry[i] && bufferBuy[i-1]==EMPTY_VALUE && bufferBuy[i-2]==EMPTY_VALUE) 
           {
            bufferBuy[i]=bufferHikkakeEntry[i];
           }
        }

      // check for SELL signals...
      if((bufferHikkakeEntry[i]>0  &&  bufferHikkake[i-1]>0 && bufferHikkake[i-1]==low[i-1]) || 
         (bufferHikkakeEntry[i]>0 && bufferHikkake[i-2]>0 && bufferHikkake[i-2]==low[i-2]) ||
         (bufferHikkakeEntry[i]>0 && bufferHikkake[i-3]>0 && bufferHikkake[i-3]==low[i-3])
         ) 
        {        //It is a SELL!

         if(low[i]<=bufferHikkakeEntry[i] && bufferSell[i-1]==EMPTY_VALUE && bufferSell[i-2]==EMPTY_VALUE) 
           {
            bufferSell[i]=bufferHikkakeEntry[i];
           }
        }

     }

   // return the prev_calculated value for the next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
