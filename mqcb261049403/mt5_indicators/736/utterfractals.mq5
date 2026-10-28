//+-----------------------------------------------------------------+
//|                                               UtterFractals.mq5 |
//|                                           Copyright © 2011, RMM |
//|                                                       rmm@nm.ru |
//+-----------------------------------------------------------------+
#property description "Utter Fractals"
//---- author of the indicator
#property copyright "Copyright © 2011, RMM"
//---- link to the website of the author
#property link      "rmm@nm.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- green color is used for the indicator
#property indicator_color1  Green
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color2  Magenta
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 "Down Fractal"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint QuantityOfBars_=1000; // History observation depth in bars
input int  UpLable=217;          // Upper fractal symbol code
input int  DnLable=218;          // Lower fractal symbol code
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double Up[];
double Dn[];
//---- declaration of global variables
double Up_tmp;
double Dn_tmp;
int review=20;
int StartBars;
uint QuantityOfBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   StartBars=6;
   QuantityOfBars=QuantityOfBars_;

//---- set Up[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Up,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(Up,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set Dn[] dynamic array as an indicator buffer
   SetIndexBuffer(1,Dn,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(Dn,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="UtterFractals";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Check for the upper extremum presence                            |
//+------------------------------------------------------------------+
bool ExistUp(uint index,const double &High[])
  {
//----
   if(High[index+1]<High[index] && High[index]>=High[index-1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for the lower extremum presence                            |
//+------------------------------------------------------------------+
bool ExistDn(uint index,const double &Low[])
  {
//----
   if(Low[index+1]>=Low[index] && Low[index]<=Low[index-1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Determining the pattern type in case of the extremum presence    |
//+------------------------------------------------------------------+
int IdentDualExtr(int index,const double &Open[],const double &Low[],const double &High[],const double &Close[])
  {
//----
   int j,type=0;
   bool up_back=false,dn_back=false,up_forward=false,dn_forward=false,upres,dnres;
   string direction;
//--- storing the bar, at which the lower extremum is found
   j=index;
   if(Open[index]<Close[index]) direction="up";
   if(Open[index]>Close[index]) direction="dn";
   upres=ExistUp(j,High);
   dnres=ExistDn(j,Low);

//--- preparing to move back to the past in history along the bars according to the review value 
   while(j<index+review)
     {
      j++;

      if(upres && !dnres && High[j]>Low[index])
        {
         if(High[j]>High[index]&&Open[index]>Close[index]){up_back=true; dn_back=false; direction="dn"; break;}
         if(High[j]<High[index]&&Open[index]>Close[index]){up_back=false; dn_back=false; direction="dn"; break;}

         if(High[j]>High[index]&&Open[index]<Close[index]){up_back=true; dn_back=false; direction="up"; break;}
         if(High[j]<High[index]&&Open[index]<Close[index]){up_back=true; dn_back=false; direction="up"; break;}

         if(High[j]>High[index]&&Open[index]==Close[index]){up_back=true; dn_back=false; direction="up"; break;}
         if(High[j]<High[index]&&Open[index]==Close[index]){up_back=false; dn_back=false; direction="up"; break;}
        }

      if(dnres && !upres)
        {
         if(Low[j]<Low[index]&&Low[j]<High[index]&&Open[index]>Close[index]){up_back=false; dn_back=true; direction="dn"; break;}
         if(Low[j]>Low[index]&&Low[j]<High[index]&&Open[index]>Close[index]){up_back=false; dn_back=true; direction="dn"; break;}

         if(Low[j]<Low[index]&&Low[j]<High[index]&&Open[index]<Close[index]){up_back=false; dn_back=true; direction="up"; break;}
         if(Low[j]>Low[index]&&Low[j]<High[index]&&Open[index]<Close[index]){up_back=false; dn_back=false; direction="up"; break;}

         if(Low[j]<High[index]&&Low[j]<Low[index]&&Open[index]==Close[index]){up_back=false; dn_back=true; direction="up"; break;}
         if(Low[j]<High[index]&&Low[j]>Low[index]&&Open[index]==Close[index]){up_back=false; dn_back=true; direction="up"; break;}
        }
     }

//--- storing the bar, at which the lower extremum is found
   j=index;

//--- preparing to move forward in history along the bars according to the review value 
   while(j>index-review)
     {
      //--- enlarging the move counter forward in history
      j--;

      if(upres && !dnres && High[j]>Low[index])
        {
         if(High[j]>High[index]&&Open[index]>Close[index]){up_forward=true; dn_forward=false; direction="dn"; break;}
         if(High[j]<High[index]&&Open[index]>Close[index]){up_forward=true; dn_forward=false; direction="dn"; break;}

         if(High[j]>High[index]&&Open[index]<Close[index]){up_forward=true; dn_forward=false; direction="up"; break;}
         if(High[j]<High[index]&&Open[index]<Close[index]){up_forward=false; dn_forward=false; direction="up"; break;}

         if(High[j]>High[index]&&Open[index]==Close[index]){up_forward=true; dn_forward=false; direction="up"; break;}
         if(High[j]<High[index]&&Open[index]==Close[index]){up_forward=true; dn_forward=false; direction="up"; break;}
        }

      if(dnres && !upres && Low[j]<High[index])
        {
         if(Low[j]<Low [index]&&Open[index]>Close[index]){up_forward=false; dn_forward=true; direction="dn"; break;}
         if(Low[j]>Low [index]&&Open[index]>Close[index]){up_forward=false; dn_forward=false; direction="dn"; break;}

         if(Low[j]<Low [index]&&Open[index]<Close[index]){up_forward=false; dn_forward=true; direction="up"; break;}
         if(Low[j]>Low [index]&&Open[index]<Close[index]){up_forward=false; dn_forward=true; direction="up"; break;}

         if(Low[j]<Low [index]&&Open[index]==Close[index]){up_forward=false; dn_forward=true; direction="up"; break;}
         if(Low[j]>Low [index]&&Open[index]==Close[index]){up_forward=false; dn_forward=true; direction="up"; break;}
        }
     }

   if( up_back&& up_forward&&direction=="dn") type=1;
   if(!up_back&& up_forward&&direction=="dn") type=2;
   if(!up_back&& up_forward&&direction=="dn") type=3;
   if( up_back&& up_forward&&direction=="dn") type=4;

   if( up_back&& up_forward&&direction=="up") type=5;
   if( up_back&& up_forward&&direction=="up") type=6;
   if( up_back&& up_forward&&direction=="up") type=7;
   if( up_back&& up_forward&&direction=="up") type=8;

   if( dn_back&& dn_forward&&direction=="dn") type=9;
   if( dn_back&& dn_forward&&direction=="dn") type=10;
   if( dn_back&& dn_forward&&direction=="dn") type=11;
   if( dn_back&& dn_forward&&direction=="dn") type=12;

   if( dn_back&& dn_forward&&direction=="up") type=13;
   if(!dn_back&& dn_forward&&direction=="up") type=14;
   if( dn_back&& dn_forward&&direction=="up") type=15;
   if(!dn_back&& dn_forward&&direction=="up") type=16;

   if( dn_back&& up_forward&&direction=="dn") type=17;
   if( dn_back&& up_forward&&direction=="dn") type=18;
   if( dn_back&& up_forward&&direction=="dn") type=19;
   if( dn_back&& up_forward&&direction=="dn") type=20;

   if( dn_back&& up_forward&&direction=="up") type=21;
   if(!dn_back&& up_forward&&direction=="up") type=22;
   if( dn_back&&!up_forward&&direction=="up") type=23;
   if(!dn_back&&!up_forward&&direction=="up") type=24;

   if( up_back&& dn_forward&&direction=="dn") type=25;
   if( up_back&&!dn_forward&&direction=="dn") type=26;
   if(!up_back&& dn_forward&&direction=="dn") type=27;
   if(!up_back&&!dn_forward&&direction=="dn") type=28;

   if( up_back&& dn_forward&&direction=="up") type=29;
   if( up_back&& dn_forward&&direction=="up") type=30;
   if( up_back&& dn_forward&&direction=="up") type=31;
   if( up_back&& dn_forward&&direction=="up") type=32;
//----
   return(type);
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

   bool actual_back,actual_forward;
   int i,j,TypeDuo;

   Up[0]=0;
   Up[1]=0;
   Dn[0]=0;
   Dn[1]=0;

   if(int(QuantityOfBars)>rates_total-21) QuantityOfBars=rates_total-21;
   for(i=int(QuantityOfBars); i>1; i--) // basic iteration
     {
      Up[i]=0;
      Dn[i]=0;
      //--- the upper extremum is found, the lower one is absent

      //--- in case the upper extremum is found
      if(ExistUp(i,high) && !ExistDn(i,high))
        {
         //--- zeroing out the relevance flag when viewed back in history
         actual_back=false;

         //--- storing the bar, at which the upper extremum is found
         j=i;
         //--- preparing to move back to the past in history along the bars according to the review value 
         while(j<i+review)
           {
            //--- enlarging the move counter back in history
            j++;

            //--- if there is an upper extremum and it is above or equal to the current one, then our upper one is irrelevant
            if(ExistUp(j,high) && !ExistDn(j,high) && high[j]>=high[i]) {actual_back=false; break;}

            //--- if there is a lower extremum and it is below the current one, then our upper one is relevant
            if(ExistDn(j,high) && !ExistUp(j,high) && low[j]<high[i]) {actual_back=true;  break;}

            //--- if both lower and upper extremums are found 
            if(ExistDn(j,high) && ExistUp(j,high))
              {

               TypeDuo=IdentDualExtr(j,open,low,high,close);
               switch(TypeDuo)
                 {
                  case 1:
                     actual_back=true;
                     break;
                  case 2:
                     actual_back=true;
                     break;
                  case 3:
                     actual_back=true;
                     break;
                  case 4:
                     actual_back=true;
                     break;
                  case 5:
                     actual_back=true;
                     break;
                  case 6:
                     actual_back=true;
                     break;
                  case 7:
                     actual_back=true;
                     break;
                  case 8:
                     actual_back=true;
                     break;
                  case 9:
                     actual_back=true;
                     break;
                  case 10:
                     actual_back=true;
                     break;
                  case 11:
                     actual_back=true;
                     break;
                  case 12:
                     actual_back=true;
                     break;
                  case 13:
                     actual_back=true;
                     break;
                  case 14:
                     actual_back=true;
                     break;
                  case 15:
                     actual_back=true;
                     break;
                  case 16:
                     actual_back=true;
                     break;
                  case 17:
                     actual_back=true;
                     break;
                  case 18:
                     actual_back=true;
                     break;
                  case 19:
                     actual_back=true;
                     break;
                  case 20:
                     actual_back=true;
                     break;
                  case 21:
                     actual_back=true;
                     break;
                  case 22:
                     actual_back=true;
                     break;
                  case 23:
                     actual_back=false;
                     break;
                  case 24:
                     actual_back=false;
                     break;
                  case 25:
                     actual_back=true;
                     break;
                  case 26:
                     actual_back=true;
                     break;
                  case 27:
                     actual_back=true;
                     break;
                  case 28:
                     actual_back=true;
                     break;
                  case 29:
                     actual_back=true;
                     break;
                  case 30:
                     actual_back=true;
                     break;
                  case 31:
                     actual_back=true;
                     break;
                  case 32:
                     actual_back=true;
                     break;

                 }
               break;
              }
           }

         //--- zeroing out the relevance flag when viewed forward in history
         actual_forward=false;

         //--- storing the bar, at which the upper extremum is found
         j=i;
         //--- preparing to move forward in history along the bars according to the review value 
         while(j>i-review)
           {
            if(j<2) break;
            //--- enlarging the move counter forward in history
            j--;

            //--- if there is an upper extremum and it is above the current one, then our upper one is irrelevant 
            if(ExistUp(j,high) && !ExistDn(j,high) && high[j]>high[i]) {actual_forward=false; break;}

            //--- if there is a lower extremum and it is below the current one, then our upper one is relevant
            if(ExistDn(j,high) && !ExistUp(j,high) && low[j]<high[i]) {actual_forward=true; break;}

            //--- if both lower and upper extremums are found 
            if(ExistDn(j,high) && ExistUp(j,high))
              {
               TypeDuo=IdentDualExtr(j,open,low,high,close);
               switch(TypeDuo)
                 {
                  case 1:
                     actual_forward=true;
                     break;
                  case 2:
                     actual_forward=false;
                     break;
                  case 3:
                     actual_forward=false;
                     break;
                  case 4:
                     actual_forward=true;
                     break;
                  case 5:
                     actual_forward=true;
                     break;
                  case 6:
                     actual_forward=true;
                     break;
                  case 7:
                     actual_forward=true;
                     break;
                  case 8:
                     actual_forward=true;
                     break;
                  case 9:
                     actual_forward=true;
                     break;
                  case 10:
                     actual_forward=true;
                     break;
                  case 11:
                     actual_forward=true;
                     break;
                  case 12:
                     actual_forward=true;
                     break;
                  case 13:
                     actual_forward=true;
                     break;
                  case 14:
                     actual_forward=true;
                     break;
                  case 15:
                     actual_forward=true;
                     break;
                  case 16:
                     actual_forward=true;
                     break;
                  case 17:
                     actual_forward=true;
                     break;
                  case 18:
                     actual_forward=true;
                     break;
                  case 19:
                     actual_forward=true;
                     break;
                  case 20:
                     actual_forward=true;
                     break;
                  case 21:
                     actual_forward=true;
                     break;
                  case 22:
                     actual_forward=true;
                     break;
                  case 23:
                     actual_forward=true;
                     break;
                  case 24:
                     actual_forward=true;
                     break;
                  case 25:
                     actual_forward=true;
                     break;
                  case 26:
                     actual_forward=true;
                     break;
                  case 27:
                     actual_forward=false;
                     break;
                  case 28:
                     actual_forward=false;
                     break;
                  case 29:
                     actual_forward=true;
                     break;
                  case 30:
                     actual_forward=true;
                     break;
                  case 31:
                     actual_forward=true;
                     break;
                  case 32:
                     actual_forward=true;
                 }
               break;
              }
           }

         //--- in case everything is OK behind and ahead
         if(actual_back && actual_forward)
           {
            //--- filling the Up array using Up_tmp variable
            Up_tmp=high[i];
           }
         //--- in case the extremum is irrelevant, the array must be zeroed out using Up_tmp variable
         else Up_tmp=0;

        }
      //--- everything is executed, in case the upper extremum is found  
      //--- in case the upper extremum is absent, the array must be zeroed out using Up_tmp variable 
      else Up_tmp=0;

      //--- the lower extremum is found, the upper one is absent

      //--- in case the lower extremum is found
      if(ExistDn(i,high) && !ExistUp(i,high))
        {
         //--- zeroing out the relevance flag when viewed back in history
         actual_back=false;
         //--- storing the bar, at which the lower extremum is found
         j=i;
         //--- preparing to move back to the past in history along the bars according to the depth_review value 
         while(j<i+review)
           {
            j++;   //--- enlarging the move counter back in history
            //--- if there is a lower extremum and it is below or equal to the current one, then our lower one is irrelevant
            if(ExistDn(j,high) && !ExistUp(j,high) && low[j]<=low[i]) {actual_back=false;  break;}

            //--- if there is an upper extremum and it is above the current one, then our lower one is relevant
            if(ExistUp(j,high) && !ExistDn(j,high) && high[j]>low[i]) {actual_back=true; break;}

            //--- if both lower and upper extremums are found 
            if(ExistDn(j,high) && ExistUp(j,high))
              {
               TypeDuo=IdentDualExtr(j,open,low,high,close);
               switch(TypeDuo)
                 {
                  case 1:
                     actual_back=true;
                     break;
                  case 2:
                     actual_back=true;
                     break;
                  case 3:
                     actual_back=true;
                     break;
                  case 4:
                     actual_back=true;
                     break;
                  case 5:
                     actual_back=true;
                     break;
                  case 6:
                     actual_back=true;
                     break;
                  case 7:
                     actual_back=true;
                     break;
                  case 8:
                     actual_back=true;
                     break;
                  case 9:
                     actual_back=true;
                     break;
                  case 10:
                     actual_back=true;
                     break;
                  case 11:
                     actual_back=true;
                     break;
                  case 12:
                     actual_back=true;
                     break;
                  case 13:
                     actual_back=true;
                     break;
                  case 14:
                     actual_back=true;
                     break;
                  case 15:
                     actual_back=true;
                     break;
                  case 16:
                     actual_back=true;
                     break;
                  case 17:
                     actual_back=true;
                     break;
                  case 18:
                     actual_back=true;
                     break;
                  case 19:
                     actual_back=true;
                     break;
                  case 20:
                     actual_back=true;
                     break;
                  case 21:
                     actual_back=true;
                     break;
                  case 22:
                     actual_back=true;
                     break;
                  case 23:
                     actual_back=true;
                     break;
                  case 24:
                     actual_back=true;
                     break;
                  case 25:
                     actual_back=true;
                     break;
                  case 26:
                     actual_back=false;
                     break;
                  case 27:
                     actual_back=true;
                     break;
                  case 28:
                     actual_back=false;
                     break;
                  case 29:
                     actual_back=true;
                     break;
                  case 30:
                     actual_back=true;
                     break;
                  case 31:
                     actual_back=true;
                     break;
                  case 32:
                     actual_back=true;
                 }
               break;
              }
           }

         //--- zeroing out the relevance flag when viewed forward in history
         actual_forward=false;

         //--- storing the bar, at which the lower extremum is found
         j=i;

         //--- preparing to move forward in history along the bars according to the review value 
         while(j>i-review)
           {
            if(j<2) break;

            //--- enlarging the move counter forward in history
            j--;
            //--- if there is a lower extremum and it is below the current one, then our lower one is irrelevant
            if(ExistDn(j,high) && !ExistUp(j,high) && low[j]<low[i]) {actual_forward=false; break;}

            //--- if there is an upper extremum and it is above the current one, then our lower one has the right to exist
            if(ExistUp(j,high) && !ExistDn(j,high) && high[j]>low[i]) {actual_forward=true; break;}

            //--- if both lower and upper extremums are found
            if(ExistDn(j,high) && ExistUp(j,high))
              {
               TypeDuo=IdentDualExtr(j,open,low,high,close);
               switch(TypeDuo)
                 {
                  case 1:
                     actual_forward=true;
                     break;
                  case 2:
                     actual_forward=true;
                     break;
                  case 3:
                     actual_forward=true;
                     break;
                  case 4:
                     actual_forward=true;
                     break;
                  case 5:
                     actual_forward=true;
                     break;
                  case 6:
                     actual_forward=true;
                     break;
                  case 7:
                     actual_forward=true;
                     break;
                  case 8:
                     actual_forward=true;
                     break;
                  case 9:
                     actual_forward=true;
                     break;
                  case 10:
                     actual_forward=true;
                     break;
                  case 11:
                     actual_forward=true;
                     break;
                  case 12:
                     actual_forward=true;
                     break;
                  case 13:
                     actual_forward=true;
                     break;
                  case 14:
                     actual_forward=false;
                     break;
                  case 15:
                     actual_forward=true;
                     break;
                  case 16:
                     actual_forward=false;
                     break;
                  case 17:
                     actual_forward=true;
                     break;
                  case 18:
                     actual_forward=true;
                     break;
                  case 19:
                     actual_forward=true;
                     break;
                  case 20:
                     actual_forward=true;
                     break;
                  case 21:
                     actual_forward=true;
                     break;
                  case 22:
                     actual_forward=false;
                     break;
                  case 23:
                     actual_forward=true;
                     break;
                  case 24:
                     actual_forward=false;
                     break;
                  case 25:
                     actual_forward=true;
                     break;
                  case 26:
                     actual_forward=true;
                     break;
                  case 27:
                     actual_forward=true;
                     break;
                  case 28:
                     actual_forward=true;
                     break;
                  case 29:
                     actual_forward=true;
                     break;
                  case 30:
                     actual_forward=true;
                     break;
                  case 31:
                     actual_forward=true;
                     break;
                  case 32:
                     actual_forward=true;
                 }
               break;
              }
           }

         //--- in case everything is OK behind and ahead
         if(actual_back && actual_forward)
           {
            //--- filling Dn array using Dn_tmp variable
            Dn_tmp=low[i];
           }
         //--- in case the extremum is irrelevant, the array must be zeroed out using Dn_tmp variable
         else Dn_tmp=0;

        }
      //--- everything is executed, in case the lower extremum is found 
      //--- in case the lower extremum is absent, the array must be zeroed out using Dn_tmp variable  
      else Dn_tmp=0;

      //--- both extremums are found
      //--- if both lower and upper extremums are found
      if(ExistDn(i,high) && ExistUp(i,high))
        {
         TypeDuo=IdentDualExtr(i,open,low,high,close);
         switch(TypeDuo)
           {
            case 1:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 2:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 3:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 4:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 5:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 6:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 7:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 8:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 9:
               Up_tmp=high[i];
               Dn_tmp=0;
               break;
            case 10:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 11:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 12:
               Up_tmp=low[i];
               Dn_tmp=0;
               break;
            case 13:
               Up_tmp=high[i];
               Dn_tmp=0;
               break;
            case 14:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 15:
               Up_tmp=high[i];
               Dn_tmp=0;
               break;
            case 16:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 17:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 18:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 19:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 20:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 21:
               Up_tmp=0;
               Dn_tmp=0;
               break;
            case 22:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 23:
               Up_tmp=high[i];
               Dn_tmp=0;
               break;
            case 24:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 25:
               Up_tmp=0;
               Dn_tmp=0;
               break;
            case 26:
               Up_tmp=0;
               Dn_tmp=low[i];
               break;
            case 27:
               Up_tmp=high[i];
               Dn_tmp=0;
               break;
            case 28:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 29:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 30:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 31:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;
            case 32:
               Up_tmp=high[i];
               Dn_tmp=low[i];
               break;

           }
        }

      //--- if both extremums are not found
      if(!ExistDn(i,high) && !ExistUp(i,high))
        {
         Up_tmp=0;
         Dn_tmp=0;
        }

      //--- Up array is filled directly
      Up[i]=Up_tmp+2*_Point;
      //--- Dn array is filled directly
      Dn[i]=Dn_tmp-2*_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
