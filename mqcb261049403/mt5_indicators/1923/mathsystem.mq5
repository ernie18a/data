//+------------------------------------------------------------------+
//|                                                  Math-System.mq5 |
//|                                           Copyright © 2005, XXXX |
//|                                                                  |
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2005, XXXX"
//---- link to the website of the author
#property link      ""
//---- Indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- no buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 0
//---- 0 graphical plots are used
#property indicator_plots  0
//+-----------------------------------+
//|  declaration of enumeration       |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  declaration of enumeration       |
//+-----------------------------------+  
enum Width
  {
   Width1=1, //1
   Width2,   //2
   Width3,   //3
   Width4,   //4
   Width5    //5
  };
//+-----------------------------------+
//|  declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   //----
   SOLID_,       //Solid line
   DASH_,        //Dashed line
   DOT_,         //Dotted line
   DASHDOT_,     //Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
   //----
  };
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_TEXT_POSITION // type of constant
  {
   //----
   Left,   // left
   Right   // Right
   //----
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint   beginer=200;
input uint   periodtotake=200;
input ENUM_TEXT_POSITION TxtPos=Left; // Text position
input uint   TextSize=15;             // Text size
input color  Color_1 = clrMagenta;    // Color of level final_l
input color  Color_2 = clrPink;       // Color of level -1/8
input color  Color_3 = clrBlue;       // Color of level 0/8
input color  Color_4 = clrOrange;     // Color of level 1/8
input color  Color_5 = clrRed;        // Color of level 2/8
input color  Color_6 = clrGreen;      // Color of level 3/8
input color  Color_7 = clrBlue;       // Color of level 4/8
input color  Color_8 = clrGreen;      // Color of level 5/8
input color  Color_9 = clrRed;        // Color of level 6/8
input color  Color_10 = clrOrange;    // Color of level 7/8
input color  Color_11 = clrBlue;      // Color of level 8/8
input color  Color_12 = clrPink;      // Color of level +1/8
input color  Color_13 = clrMagenta;   // Color of level +2/8
//----
input STYLE  Style_1 = SOLID_;      // Line style of level _final l
input STYLE  Style_2 = SOLID_;      // Line style of level -1/8
input STYLE  Style_3 = SOLID_;      // Line style of level 0/8
input STYLE  Style_4 = SOLID_;      // Line style of level 1/8
input STYLE  Style_5 = SOLID_;      // Line style of level 2/8
input STYLE  Style_6 = SOLID_;      // Line style of level 3/8
input STYLE  Style_7 = SOLID_;      // Line style of level 4/8
input STYLE  Style_8 = SOLID_;      // Line style of level 5/8
input STYLE  Style_9 = SOLID_;      // Line style of level 6/8
input STYLE  Style_10 = SOLID_;     // Line style of level 7/8
input STYLE  Style_11 = SOLID_;     // Line style of level 8/8
input STYLE  Style_12 = SOLID_;     // Line style of level +1/8
input STYLE  Style_13 = SOLID_;     // Line style of level +2/8
//----
input Width  Width_1 = Width2;     // Width of line of level _final l
input Width  Width_2 = Width2;     // Width of line of level -1/8
input Width  Width_3 = Width2;     // Width of line of level 0/8
input Width  Width_4 = Width2;     // Width of line of level 1/8
input Width  Width_5 = Width2;     // Width of line of level 2/8
input Width  Width_6 = Width2;     // Width of line of level 3/8
input Width  Width_7 = Width2;     // Width of line of level 4/8
input Width  Width_8 = Width2;     // Width of line of level 5/8
input Width  Width_9 = Width2;     // Width of line of level 6/8
input Width  Width_10 = Width2;    // Width of line of level 7/8
input Width  Width_11 = Width2;    // Width of line of level 8/8
input Width  Width_12 = Width2;    // Width of line of level +1/8
input Width  Width_13 = Width2;    // Width of line of level +2/8
//+----------------------------------------------+
int shift,i2,Worktime,Periods;
double sum,v1,v2,fractal;
double v45,mml00,mml0,mml1,mml2,mml3,mml4,mml5,mml6,mml7,mml8,mml9,mml98,mml99;
double range,octave,mn,mx;
double finalH,finalL;
double x1,x2,x3,x4,x5,x6,y1,y2,y3,y4,y5,y6;
string textArray[14]=
  {
   "mm11_txt","mm13_txt","mm12_txt","mm1_txt","mm2_txt","mm3_txt",
   "mm4_txt","mm5_txt","mm6_txt","mm7_txt","mm8_txt","mm9_txt","mm-1_txt","mm-2_txt"
  };
string lineArray[13]={"mm11","mm12","mm1","mm2","mm3","mm4","mm5","mm6","mm7","mm8","mm9","mm-1","mm-2"};
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,      // Chart ID
                 string name,          // object name
                 int    nwin,          // window index
                 double price,         // price level
                 color  Color,         // line color
                 int    style,         // line style
                 int    width,         // line width
                 string text)          // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,      // chart ID
              string name,          // object name
              int    nwin,          // window index
              double price,         // price level
              color  Color,         // line color
              int    style,         // line style
              int    width,         // line width
              string text)          // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Text Label creation                                             |
//+------------------------------------------------------------------+
void CreateText(long chart_id,              // chart ID
                string   name,              // object name
                int      nwin,              // window index
                datetime time,              // price level time
                double   price,             // price level
                string   text,              // Labels text
                color    Color,             // Text color
                string   Font,              // Text font
                int      Size,              // Text size
                ENUM_ANCHOR_POINT point)    // The chart corner to Which an text is attached
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
//----
  }
//+------------------------------------------------------------------+
//|  Text Label reinstallation                                       |
//+------------------------------------------------------------------+
void SetText(long chart_id,              // chart ID
             string   name,              // object name
             int      nwin,              // window index
             datetime time,              // price level time
             double   price,             // price level
             string   text,              // Labels text
             color    Color,             // Text color
             string   Font,              // Text font
             int      Size,              // Text size
             ENUM_ANCHOR_POINT point)    // The chart corner to Which an text is attached
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int ch=ArraySize(textArray)-1; ch>=0; ch--) ObjectDelete(0,textArray[ch]);
   for(int ch=ArraySize(lineArray)-1; ch>=0; ch--) ObjectDelete(0,lineArray[ch]);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(rates_total<int(periodtotake)) return(0);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   if(prev_calculated!=rates_total)
     {
      v2=high[ArrayMaximum(high,0,periodtotake)];
      v1=low[ArrayMinimum(low,0,periodtotake)];

      if(v2<=250000 && v2>25000) fractal=100000;
      else if(v2<=25000 && v2>2500) fractal=10000;
      else if(v2<=2500 && v2>250) fractal=1000;
      else if(v2<=250 && v2>25) fractal=100;
      else if(v2<=25 && v2>12.5) fractal=12.5;
      else if(v2<=12.5 && v2>6.25) fractal=12.5;
      else if(v2<=6.25 && v2>3.125) fractal=6.25;
      else if(v2<=3.125 && v2>1.5625) fractal=3.125;
      else if(v2<=1.5625 && v2>0.390625) fractal=1.5625;
      else if(v2<=0.390625 && v2>0) fractal=0.1953125;

      range=(v2-v1);
      sum=MathFloor(MathLog(fractal/range)/MathLog(2));
      octave=fractal*(MathPow(0.5,sum));
      if(octave) mn=MathFloor(v1/octave)*octave;
      else return(0);

      if((mn+octave)>v2) mx=mn+octave;
      else mx=mn+(2*octave);

      if((v1>=3/16*(mx-mn)+mn) && (v2<=9/16*(mx-mn)+mn)) x2=mn+(mx-mn)/2;
      else x2=0;

      if((v1>=mn-(mx-mn)/8) && (v2<=5/8*(mx-mn)+mn) && !x2) x1=mn+(mx-mn)/2;
      else x1=0;

      if((v1>=mn+7*(mx-mn)/16)&& (v2<=13/16*(mx-mn)+mn)) x4=mn+3*(mx-mn)/4;
      else x4=0;

      if((v1>=mn+3*(mx-mn)/8) && (v2<=9/8*(mx-mn)+mn) && !x4) x5=mx;
      else x5=0;

      if((v1>=mn+(mx-mn)/8) && (v2<=7/8*(mx-mn)+mn) && !x1 && !x2 && !x4 && !x5) x3=mn+3*(mx-mn)/4;
      else x3=0;

      if(!(x1+x2+x3+x4+x5)) x6=mx;
      else x6=0;

      finalH=x1+x2+x3+x4+x5+x6;

      if(x1>0) y1=mn;
      else y1=0;

      if(x2>0) y2=mn+(mx-mn)/4;
      else y2=0;

      if(x3>0) y3=mn+(mx-mn)/4;
      else y3=0;

      if(x4>0) y4=mn+(mx-mn)/2;
      else y4=0;

      if(x5>0) y5=mn+(mx-mn)/2;
      else y5=0;

      if(finalH>0 && !(y1+y2+y3+y4+y5)) y6=mn;
      else y6=0;

      finalL=y1+y2+y3+y4+y5+y6;
      v45=(finalH-finalL)/8;
      mml00=(finalL-v45*2);
      mml0=(finalL-v45);
      mml1=(finalL);
      mml2=(finalL+v45);
      mml3=(finalL+2*v45);
      mml4=(finalL+3*v45);
      mml5=(finalL+4*v45);
      mml6=(finalL+5*v45);
      mml7=(finalL+6*v45);
      mml8=(finalL+7*v45);
      mml9=(finalL+8*v45);
      mml99=(finalL+9*v45);
      mml98=(finalL+10*v45);

      CreateText(0,"mm11_txt",0,time[0],mml00,"_финал л "+DoubleToString(finalH,_Digits),Color_1,"Georgia",TextSize,ANCHOR_LOWER);
      CreateText(0,"mm13_txt",0,time[0],mml00,"mml7 "+DoubleToString(mml7,_Digits),Color_1,"Georgia",TextSize,ANCHOR_UPPER);

      CreateText(0,"mm12_txt",0,time[0],mml0,"-1/8 ",Color_2,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm1_txt",0,time[0],mml1,"0/8 ",Color_3,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm2_txt",0,time[0],mml2,"1/8 ",Color_4,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm3_txt",0,time[0],mml3,"2/8 ",Color_5,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm4_txt",0,time[0],mml4,"3/8 ",Color_6,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm5_txt",0,time[0],mml5,"4/8 ",Color_7,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm6_txt",0,time[0],mml6,"5/8 ",Color_8,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm7_txt",0,time[0],mml7,"6/8 ",Color_9,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm8_txt",0,time[0],mml8,"7/8 ",Color_10,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm9_txt",0,time[0],mml9,"8/8 ",Color_11,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm-1_txt",0,time[0],mml99,"+1/8 ",Color_12,"Georgia",TextSize,ANCHOR_LEFT_LOWER);
      CreateText(0,"mm-2_txt",0,time[0],mml98,"+2/8 ",Color_13,"Georgia",TextSize,ANCHOR_LEFT_LOWER);

      SetHline(0,"mm11",0,mml00,Color_1,Style_1,Width_1,"mm11");
      SetHline(0,"mm12",0,mml0,Color_2,Style_2,Width_2,"mm12");
      SetHline(0,"mm1",0,mml1,Color_3,Style_3,Width_3,"mm11");
      SetHline(0,"mm2",0,mml2,Color_4,Style_4,Width_4,"mm12");
      SetHline(0,"mm3",0,mml3,Color_5,Style_5,Width_5,"mm13");
      SetHline(0,"mm4",0,mml4,Color_6,Style_6,Width_6,"mm14");
      SetHline(0,"mm5",0,mml5,Color_7,Style_7,Width_7,"mm15");
      SetHline(0,"mm6",0,mml6,Color_8,Style_8,Width_8,"mm16");
      SetHline(0,"mm7",0,mml7,Color_9,Style_9,Width_9,"mm17");
      SetHline(0,"mm8",0,mml8,Color_10,Style_10,Width_10,"mm18");
      SetHline(0,"mm9",0,mml9,Color_11,Style_11,Width_11,"mm19");
      SetHline(0,"mm-1",0,mml99,Color_12,Style_12,Width_12,"mm-1");
      SetHline(0,"mm-2",0,mml98,Color_13,Style_13,Width_13,"mm-2");
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
