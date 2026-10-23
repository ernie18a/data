//+------------------------------------------------------------------+
//|                                                 VIndicat_005.mq5 |
//+------------------------------------------------------------------+
#property description "VIndi"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//----
#property indicator_label1  "VIndi"
#property indicator_type1   DRAW_NONE
#property indicator_color1  Gold
//--- input parameters
input int InpNBar=4;       // Period
input int InpXCoord=80;    // X Coordinate
input int InpYCoord=20;    // Y Coordinate
//--- indicator buffers
double IBuf[];
//--- global variables
int    NBar,XCoord,YCoord;
string ShortName;
color  IndColor[64];
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input values
   if(InpNBar<1)NBar=1;
   else NBar=InpNBar;
   XCoord=InpXCoord;
   YCoord=InpYCoord;
//--- indicator buffers mapping
   SetIndexBuffer(0,IBuf,INDICATOR_DATA);
   ArraySetAsSeries(IBuf,true);
//--- set shortname
   ShortName="VIndi";
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---          
   initGraph();

   return(0);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   deleteGraph();
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i;
   double min,max,chan,val;

   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

   min=10000;max=0;
   for(i=0;i<NBar;i++)
     {
      if(Low[i]<min)min=Low[i];
      if(High[i]>max)max=High[i];
     }
   chan=(max-min)/2.0;
   val=Close[0]-(max+min)/2.0;
   if(chan==0)val=1.0;
   else val=val/chan;
   if(val>0.99)val=1.1;
   if(val<-0.99)val=-1.1;
   drawGraph(val);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| initGraph                                                        |
//+------------------------------------------------------------------+
void initGraph()
  {
   int i;
   string nam;

   IndColor[0]=C'255,7,7';
   IndColor[1]=C'250,255,7';
   IndColor[2]=C'225,255,7';
   IndColor[3]=C'200,255,7';
   IndColor[4]=C'175,255,7';
   IndColor[5]=C'150,255,7';
   IndColor[6]=C'125,255,7';
   IndColor[7]=C'100,255,7';
   IndColor[8]=C'75,255,7';
   IndColor[9]=C'50,255,7';
   IndColor[10]=C'25,255,7';
   IndColor[11]=C'130,130,24';
   IndColor[12]=C'25,255,7';
   IndColor[13]=C'50,255,7';
   IndColor[14]=C'75,255,7';
   IndColor[15]=C'100,255,7';
   IndColor[16]=C'125,255,7';
   IndColor[17]=C'150,255,7';
   IndColor[18]=C'175,255,7';
   IndColor[19]=C'200,255,7';
   IndColor[20]=C'225,255,7';
   IndColor[21]=C'250,255,7';
   IndColor[22]=C'255,7,7';

   IndColor[23]=C'56,24,24';
   IndColor[24]=C'32,48,48';
   IndColor[25]=C'32,48,48';
   IndColor[26]=C'32,48,48';
   IndColor[27]=C'32,48,48';
   IndColor[28]=C'32,48,48';
   IndColor[29]=C'32,48,48';
   IndColor[30]=C'32,48,48';
   IndColor[31]=C'32,48,48';
   IndColor[32]=C'32,48,48';
   IndColor[33]=C'32,48,48';
   IndColor[34]=C'130,130,24';
   IndColor[35]=C'32,48,48';
   IndColor[36]=C'32,48,48';
   IndColor[37]=C'32,48,48';
   IndColor[38]=C'32,48,48';
   IndColor[39]=C'32,48,48';
   IndColor[40]=C'32,48,48';
   IndColor[41]=C'32,48,48';
   IndColor[42]=C'32,48,48';
   IndColor[43]=C'32,48,48';
   IndColor[44]=C'32,48,48';
   IndColor[45]=C'56,24,24';

   IndColor[62]=C'54,54,10';
   IndColor[63]=DarkKhaki;

   for(i=0;i<23;i++)
     {
      nam=ShortName+IntegerToString(i);
      ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,31);
      ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord);
      ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+i*4);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[i+23]);
      ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
      ObjectSetString(0,nam,OBJPROP_TEXT,"-");
     }
   nam=ShortName+IntegerToString(23);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-26);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+17);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"- -10");
   nam=ShortName+IntegerToString(24);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+57);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"- 0");
   nam=ShortName+IntegerToString(25);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-29);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+97);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"- +10");
   nam=ShortName+IntegerToString(26);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+17);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");
   nam=ShortName+IntegerToString(27);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+57);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");
   nam=ShortName+IntegerToString(28);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+97);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");

   nam=ShortName+IntegerToString(29);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+13);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"__");
   nam=ShortName+IntegerToString(30);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+111);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"__");

   for(i=31;i<=39;i++)
     {
      nam=ShortName+IntegerToString(i);
      ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-2);
      ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+13+(i-31)*11);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
      ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
      ObjectSetString(0,nam,OBJPROP_TEXT,"|");
     }
   for(i=40;i<=48;i++)
     {
      nam=ShortName+IntegerToString(i);
      ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+13);
      ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+13+(i-40)*11);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
      ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
      ObjectSetString(0,nam,OBJPROP_TEXT,"|");
     }
   nam=ShortName+IntegerToString(49);
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-18);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+57); //29
   ObjectSetInteger(0,nam,OBJPROP_COLOR,DarkKhaki);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"");

  }
//+------------------------------------------------------------------+
//| drawGraph                                                        |
//+------------------------------------------------------------------+
void drawGraph(double level)
  {
   int i,p,c;
   string nam,st;

   p=int(MathRound(10*level));
   if(level>1.001)p=11;
   if(level<-1.001)p=-11;

   p=p+11;
   for(i=0;i<23;i++)
     {
      c=i+23;
      if(i<=p && i>11)c=i;
      if(i>=p && i<11)c=i;
      nam=ShortName+IntegerToString(i);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[c]);
     }
   nam=ShortName+IntegerToString(49);
   st="("+IntegerToString(p-11)+")";
   ObjectSetString(0,nam,OBJPROP_TEXT,st);
  }
//+------------------------------------------------------------------+
//| deleteGraph()                                                    |
//+------------------------------------------------------------------+
void deleteGraph()
  {
   int i;
   string nam;

   for(i=0;i<=49;i++)
     {
      nam=ShortName+IntegerToString(i);
      ObjectDelete(0,nam);
     }
  }
//-----------------------------------------------------------------------------
