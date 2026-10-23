//+------------------------------------------------------------------+
//|                                             Daily_FiboPiv_DK.mq5 |
//|                                        Copyright © 2008, Kalenzo | 
//|                                      bartlomiej.gorski@gmail.com | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, Kalenzo"
//---- link to the website of the author
#property link "bartlomiej.gorski@gmail.com" 
//---- indicator version number
#property version   "1.10"

//---- number of indicator buffers
#property indicator_buffers 0 
//---- 0 graphical plots are used in total
#property indicator_plots   0
//---- drawing the indicator in the main window
#property indicator_chart_window
//+------------------------------------------------+ 
//|  declaration of constants                      |
//+------------------------------------------------+ 
#define RESET  0 // the constant for returning the indicator recalculation command to the terminal
#define STRING "                                         "
//+------------------------------------------------+ 
//| Enumeration for the level width                |
//+------------------------------------------------+ 
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------+ 
//| Enumeration for the level style                |
//+------------------------------------------------+ 
enum STYLE
  {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   //Dot-dash line with double dots
  };
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input color NotEven_levels_color=clrGreen; //color of the odd price level
input STYLE NotEven_levels_style=DASHDOTDOT_;//style of the odd price level
input ENUM_WIDTH NotEven_levels_width=w_1;//width of the odd price level

input color Even_levels_color=clrBlue; //color of the even price level
input STYLE Even_levels_style=STYLE_SOLID;//style of the even price level
input ENUM_WIDTH Even_levels_width=w_1;//width of the even price level

input color Pivot_levels_color=clrRed; //pivot color
input STYLE Pivot_levels_style=STYLE_SOLID;//pivot style
input ENUM_WIDTH Pivot_levels_width=w_3;//width of pivot

input uint  FontSize=10; //Text font size
//+----------------------------------------------+

string font;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   font="Arial Black";
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- delete the level, if necessary
   ObjectDelete(0,"R18");
   ObjectDelete(0,"R17");
   ObjectDelete(0,"R16");
   ObjectDelete(0,"R15");
   ObjectDelete(0,"R14");
   ObjectDelete(0,"R13");
   ObjectDelete(0,"R12");
   ObjectDelete(0,"R11");
   ObjectDelete(0,"R10");
   ObjectDelete(0,"R9");
   ObjectDelete(0,"R8");
   ObjectDelete(0,"R7");
   ObjectDelete(0,"R6");
   ObjectDelete(0,"R5");
   ObjectDelete(0,"R4");
   ObjectDelete(0,"R3");
   ObjectDelete(0,"R2");
   ObjectDelete(0,"R1");
   
   ObjectDelete(0,"Daily Pivot");
   
   ObjectDelete(0,"S18");
   ObjectDelete(0,"S17");
   ObjectDelete(0,"S16");
   ObjectDelete(0,"S15");
   ObjectDelete(0,"S14");
   ObjectDelete(0,"S13");
   ObjectDelete(0,"S12");
   ObjectDelete(0,"S11");
   ObjectDelete(0,"S10");
   ObjectDelete(0,"S9");
   ObjectDelete(0,"S8");
   ObjectDelete(0,"S7");
   ObjectDelete(0,"S6");
   ObjectDelete(0,"S5");
   ObjectDelete(0,"S4");
   ObjectDelete(0,"S3");
   ObjectDelete(0,"S2");
   ObjectDelete(0,"S1");
   
   ObjectDelete(0,"R18Tx");
   ObjectDelete(0,"R17Tx");
   ObjectDelete(0,"R16Tx");
   ObjectDelete(0,"R15Tx");
   ObjectDelete(0,"R14Tx");
   ObjectDelete(0,"R13Tx");
   ObjectDelete(0,"R12Tx");
   ObjectDelete(0,"R11Tx");
   ObjectDelete(0,"R10Tx");
   ObjectDelete(0,"R9Tx");
   ObjectDelete(0,"R8Tx");
   ObjectDelete(0,"R7Tx");
   ObjectDelete(0,"R6Tx");
   ObjectDelete(0,"R5Tx");
   ObjectDelete(0,"R4Tx");
   ObjectDelete(0,"R3Tx");
   ObjectDelete(0,"R2Tx");
   ObjectDelete(0,"R1Tx");

   ObjectDelete(0,"Daily Pivot Tx");

   ObjectDelete(0,"S18Tx");
   ObjectDelete(0,"S17Tx");
   ObjectDelete(0,"S16Tx");
   ObjectDelete(0,"S15Tx");
   ObjectDelete(0,"S14Tx");
   ObjectDelete(0,"S13Tx");
   ObjectDelete(0,"S12Tx");
   ObjectDelete(0,"S11Tx");
   ObjectDelete(0,"S10Tx");
   ObjectDelete(0,"S9Tx");
   ObjectDelete(0,"S8Tx");
   ObjectDelete(0,"S7Tx");
   ObjectDelete(0,"S6Tx");
   ObjectDelete(0,"S5Tx");
   ObjectDelete(0,"S4Tx");
   ObjectDelete(0,"S3Tx");
   ObjectDelete(0,"S2Tx");
   ObjectDelete(0,"S1Tx");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- declaration of local variables
   string trendinfo;
   datetime iTime[6];
   double iHigh[6],iLow[6],iClose[6];

//---- copy newly appeared data into the arrays 
   if(CopyTime(Symbol(),PERIOD_D1,0,1,iTime)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_D1,0,6,iClose)<=0) return(RESET);
   if(CopyHigh(Symbol(),PERIOD_D1,0,6,iHigh)<=0) return(RESET);
   if(CopyLow(Symbol(),PERIOD_D1,0,6,iLow)<=0) return(RESET);

   MqlDateTime tm;
   TimeToStruct(iTime[5],tm);
   double yesterday_close=0.0,yesterday_high=0.0,yesterday_low=0.0;

   if(tm.day_of_week==MONDAY)
     {
      TimeToStruct(iTime[4],tm);
      
      if(tm.day_of_week==FRIDAY)
        {
         yesterday_close=iClose[4];
         yesterday_high=iHigh[4];
         yesterday_low=iLow[4];
        }
      else
        {
         for(int d=5; d>=0; d--)
           {
            TimeToStruct(iTime[d],tm);

            if(tm.day_of_week==FRIDAY)
              {
               yesterday_close=iClose[d];
               yesterday_high=iHigh[d];
               yesterday_low=iLow[d];
               break;
              }
           }
        }
     }
   else
     {
      yesterday_close=iClose[5];
      yesterday_high=iHigh[5];
      yesterday_low=iLow[5];
     }

//---- Calculation of pivots
   double R=yesterday_high-yesterday_low;//range
   double p=(yesterday_high+yesterday_low+yesterday_close)/3;// Standard Pivot
//----
   double r18=p + (R * 3.000);
   double r17=p + (R * 2.764);
   double r16=p + (R * 2.618);
   double r15=p + (R * 2.500);
   double r14=p + (R * 2.382);
   double r13=p + (R * 2.236);
   double r12=p + (R * 2.000);
   double r11=p + (R * 1.764);
   double r10=p + (R * 1.618);
   double r9=p + (R * 1.500);
   double r8=p + (R * 1.382);
   double r7=p + (R * 1.236);
   double r6=p + (R * 1.000);
   double r5=p + (R * 0.764);
   double r4=p + (R * 0.618);
   double r3=p + (R * 0.500);
   double r2=p + (R * 0.382);
   double r1=p + (R * 0.236);
//----
   double s1=p - (R * 0.236);
   double s2=p - (R * 0.382);
   double s3=p - (R * 0.500);
   double s4=p - (R * 0.618);
   double s5=p - (R * 0.764);
   double s6=p - (R * 1.000);
   double s7=p - (R * 1.236);
   double s8=p - (R * 1.382);
   double s9=p - (R * 1.500);
   double s10=p - (R * 1.618);
   double s11=p - (R * 1.764);
   double s12=p - (R * 2.000);
   double s13=p - (R * 2.236);
   double s14=p - (R * 2.382);
   double s15=p - (R * 2.500);
   double s16=p - (R * 2.618);
   double s17=p - (R * 2.764);
   double s18=p - (R * 3.000);
   
   int bar10=rates_total-10;
//----
   SetHline(0,"R18",0,r18,Even_levels_color,Even_levels_style,Even_levels_width,false,"R18");
   SetText(0,"R18Tx",0,time[bar10],r18,STRING+"+FIB 300.0",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R17",0,r17,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R17");
   SetText(0,"R17Tx",0,time[bar10],r17,STRING+"+FIB 276.4",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R16",0,r16,Even_levels_color,Even_levels_style,Even_levels_width,false,"R16");
   SetText(0,"R16Tx",0,time[bar10],r16,STRING+"+FIB 261.8",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R15",0,r15,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R15");
   SetText(0,"R15Tx",0,time[bar10],r15,STRING+"+FIB 250.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R14",0,r14,Even_levels_color,Even_levels_style,Even_levels_width,false,"R14");
   SetText(0,"R14Tx",0,time[bar10],r14,STRING+"+FIB 238.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R13",0,r13,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R13");
   SetText(0,"R13Tx",0,time[bar10],r13,STRING+"+FIB 223.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R12",0,r12,Even_levels_color,Even_levels_style,Even_levels_width,false,"R12");
   SetText(0,"R12Tx",0,time[bar10],r12,STRING+"+FIB 223.6",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R11",0,r11,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R11");
   SetText(0,"R11Tx",0,time[bar10],r11,STRING+"+FIB 200.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R10",0,r10,Even_levels_color,Even_levels_style,Even_levels_width,false,"R10");
   SetText(0,"R10Tx",0,time[bar10],r10,STRING+"+FIB 176.4",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R9",0,r9,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R9");
   SetText(0,"R9Tx",0,time[bar10],r9,STRING+"+FIB 161.8",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R8",0,r8,Even_levels_color,Even_levels_style,Even_levels_width,false,"R8");
   SetText(0,"R8Tx",0,time[bar10],r8,STRING+"+FIB 138.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R7",0,r7,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R7");
   SetText(0,"R7Tx",0,time[bar10],r7,STRING+"+FIB 123.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R6",0,r6,Even_levels_color,Even_levels_style,Even_levels_width,false,"R6");
   SetText(0,"R6Tx",0,time[bar10],r6,STRING+"+FIB 100.0",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R5",0,r5,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R5");
   SetText(0,"R5Tx",0,time[bar10],r5,STRING+"+FIB 76.4",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R4",0,r4,Even_levels_color,Even_levels_style,Even_levels_width,false,"R4");
   SetText(0,"R4Tx",0,time[bar10],r4,STRING+"+FIB 61.8",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R3",0,r3,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R3");
   SetText(0,"R3Tx",0,time[bar10],r3,STRING+"+FIB 50.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R2",0,r2,Even_levels_color,Even_levels_style,Even_levels_width,false,"R2");
   SetText(0,"R2Tx",0,time[bar10],r2,STRING+"+FIB 38.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"R1",0,r1,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"R1");
   SetText(0,"R1Tx",0,time[bar10],r1,STRING+"+FIB 23.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);
//----
   SetHline(0,"Daily Pivot",0,p,Pivot_levels_color,Pivot_levels_style,Pivot_levels_width,false,"Daily Pivot");
   SetText(0,"Daily Pivot Tx",0,time[bar10],p,STRING+"Daily Pivot",Pivot_levels_color,font,FontSize,ANCHOR_LOWER);
//----   
   SetHline(0,"S18",0,s18,Even_levels_color,Even_levels_style,Even_levels_width,false,"S18");
   SetText(0,"S18Tx",0,time[bar10],s18,STRING+"-FIB 300.0",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S17",0,s17,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S17");
   SetText(0,"S17Tx",0,time[bar10],s17,STRING+"-FIB 276.4",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S16",0,s16,Even_levels_color,Even_levels_style,Even_levels_width,false,"S16");
   SetText(0,"S16Tx",0,time[bar10],s16,STRING+"-FIB 261.8",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S15",0,s15,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S15");
   SetText(0,"S15Tx",0,time[bar10],s15,STRING+"-FIB 250.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S14",0,s14,Even_levels_color,Even_levels_style,Even_levels_width,false,"S14");
   SetText(0,"S14Tx",0,time[bar10],s14,STRING+"-FIB 238.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S13",0,s13,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S13");
   SetText(0,"S13Tx",0,time[bar10],s13,STRING+"-FIB 223.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S12",0,s12,Even_levels_color,Even_levels_style,Even_levels_width,false,"S12");
   SetText(0,"S12Tx",0,time[bar10],s12,STRING+"-FIB 223.6",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S11",0,s11,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S11");
   SetText(0,"S11Tx",0,time[bar10],s11,STRING+"-FIB 200.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S10",0,s10,Even_levels_color,Even_levels_style,Even_levels_width,false,"S10");
   SetText(0,"S10Tx",0,time[bar10],s10,STRING+"-FIB 176.4",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S9",0,s9,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S9");
   SetText(0,"S9Tx",0,time[bar10],s9,STRING+"-FIB 161.8",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S8",0,s8,Even_levels_color,Even_levels_style,Even_levels_width,false,"S8");
   SetText(0,"S8Tx",0,time[bar10],s8,STRING+"-FIB 138.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S7",0,s7,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S7");
   SetText(0,"S7Tx",0,time[bar10],s7,STRING+"-FIB 123.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S6",0,s6,Even_levels_color,Even_levels_style,Even_levels_width,false,"S6");
   SetText(0,"S6Tx",0,time[bar10],s6,STRING+"-FIB 100.0",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S5",0,s5,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S5");
   SetText(0,"S5Tx",0,time[bar10],s5,STRING+"-FIB 76.4",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S4",0,s4,Even_levels_color,Even_levels_style,Even_levels_width,false,"S4");
   SetText(0,"S4Tx",0,time[bar10],s4,STRING+"-FIB 61.8",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S3",0,s3,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S3");
   SetText(0,"S3Tx",0,time[bar10],s3,STRING+"-FIB 50.0",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S2",0,s2,Even_levels_color,Even_levels_style,Even_levels_width,false,"S2");
   SetText(0,"S2Tx",0,time[bar10],s2,STRING+"-FIB 38.2",Even_levels_color,font,FontSize,ANCHOR_LOWER);

   SetHline(0,"S1",0,s1,NotEven_levels_color,NotEven_levels_style,NotEven_levels_width,false,"S1");
   SetText(0,"S1Tx",0,time[bar10],s1,STRING+"-FIB 23.6",NotEven_levels_color,font,FontSize,ANCHOR_LOWER);
//----
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Creating the horizontal line                                    |
//+------------------------------------------------------------------+
void CreateHline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 double   price,         // horizontal level price
 color    Color,         // color of the line
 int      style,         // style of the line
 int      width,         // width of the line
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,nwin,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Horizontal line redrawing                                       |
//+------------------------------------------------------------------+
void SetHline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 double   price,         // horizontal level price
 color    Color,         // color of the line
 int      style,         // style of the line
 int      width,         // width of the line
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  creating a text label                                           |
//+------------------------------------------------------------------+
void CreateText(long chart_id,// chart ID
                string   name,              // object name
                int      nwin,              // window index
                datetime time,              // price level time
                double   price,             // price level
                string   text,              // Labels text
                color    Color,             // Text color
                string   Font,              // Text font
                int      Size,              // Text size
                ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
                )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
//----
  }
//+------------------------------------------------------------------+
//|  changing a text label                                           |
//+------------------------------------------------------------------+
void SetText(long chart_id,// chart ID
             string   name,              // object name
             int      nwin,              // window index
             datetime time,              // price level time
             double   price,             // price level
             string   text,              // Labels text
             color    Color,             // Text color
             string   Font,              // Text font
             int      Size,              // Text size
             ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
             )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateText(chart_id,name,nwin,time,price,text,Color,Font,Size,point);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,price);
     }
//----
  }
//+------------------------------------------------------------------+
