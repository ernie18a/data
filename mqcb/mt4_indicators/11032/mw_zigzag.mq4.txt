//+------------------------------------------------------------------+
//|                                                    MW_ZigZag.mq4 |
//|                        
//|                                                     marwi1@o2.pl |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkTurquoise
#property indicator_color2 Yellow

extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

extern int       barn=300;
extern int       Length=6;

double MA;

double HighMapBuffer[];
double LowMapBuffer[];

double HighMapBuffer1[];
double LowMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(5);
   string short_name;

   short_name="MW_ZIGZAG";
   IndicatorShortName(short_name);

   SetIndexArrow(0,32);
   SetIndexArrow(1,32);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   if(Bars<20) return(-1);

   MA=iMA(NULL,0,20,0,MODE_SMMA,PRICE_MEDIAN,0);
   int n1,i1;
   double b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20;
   double s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,b00;

   int size=100;
   ArrayResize(HighMapBuffer1,size);
   ArrayResize(LowMapBuffer1,size);
//------------      
   i1=0;
   for(n1=0;n1<=20;)
     {
      if(b0>0) {b20=b19; b19=b18; b18=b17; b17=b16; b16=b15; b15=b14; b14=b13;b13=b12; b12=b11; b11=b10; b10=b9; b9=b8; b8=b7; b7=b6; b6=b5;  b5=b4; b4=b3; b3=b2; b2=b1; b1=b0;}

      b0=iCustom(Symbol(),0,"High_Low v2",0,i1);
      b00=iCustom(Symbol(),0,"High_Low v2",0,i1);
      if(b0>0)
         n1+=1;

      i1++;

      if(b19>b20)
        {
         r1=b1; s1=b2;r2=b3; s2=b4; r3=b5; s3=b6; r4=b7; s4=b8; r5=b9; s5=b10;
         r6=b11; s6=b12; r7=b13; s7=b14; r8=b15; s8=b16; r9=b17; s9=b18; r10=b19; s10=b20;
        }
      else
        {
         s1=b1; r1=b2;s2=b3; r2=b4; s3=b5; r3=b6; s4=b7; r4=b8; s5=b9; r5=b10;
         s6=b11; r6=b12;s7=b13; r7=b14; s8=b15; r8=b16; s9=b17; r9=b18; s10=b19; r10=b20;
        }
      HighMapBuffer1[n1]=r10;
      LowMapBuffer1[n1]=s10;
     }

   ObjectDelete("Res1");
   ObjectCreate("Res1",OBJ_HLINE,0,0,r1);
   ObjectSet("Res1",OBJPROP_COLOR,White);
   ObjectSet("Res1",OBJPROP_WIDTH,1);
   ObjectSet("Res1",OBJPROP_RAY,false);
   ObjectSetText("Res1","Up & Price_0 "+r1,10,"Times New Roman",Green);

   ObjectDelete("Sup1");
   ObjectCreate("Sup1",OBJ_HLINE,0,0,s1);
   ObjectSet("Sup1",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup1",OBJPROP_WIDTH,1);
   ObjectSet("Sup1",OBJPROP_RAY,false);
   ObjectSetText("Sup1","Down & Price_1 "+s1,10,"Times New Roman",Green);

//
   ObjectDelete("Res2");
   ObjectCreate("Res2",OBJ_HLINE,0,0,r2);
   ObjectSet("Res2",OBJPROP_COLOR,White);
   ObjectSet("Res2",OBJPROP_WIDTH,1);
   ObjectSet("Res2",OBJPROP_RAY,false);
   ObjectSetText("Res2","Up & Price_0 "+r2,10,"Times New Roman",Green);

   ObjectDelete("Sup2");
   ObjectCreate("Sup2",OBJ_HLINE,0,0,s2);
   ObjectSet("Sup2",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup2",OBJPROP_WIDTH,1);
   ObjectSet("Sup2",OBJPROP_RAY,false);
   ObjectSetText("Sup2","Down & Price_1 "+s2,10,"Times New Roman",Green);
//
   ObjectDelete("Res3");
   ObjectCreate("Res3",OBJ_HLINE,0,0,r3);
   ObjectSet("Res3",OBJPROP_COLOR,White);
   ObjectSet("Res3",OBJPROP_WIDTH,1);
   ObjectSet("Res3",OBJPROP_RAY,false);
   ObjectSetText("Res3","Up & Price_0 "+r3,10,"Times New Roman",Green);

   ObjectDelete("Sup3");
   ObjectCreate("Sup3",OBJ_HLINE,0,0,s3);
   ObjectSet("Sup3",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup3",OBJPROP_WIDTH,1);
   ObjectSet("Sup3",OBJPROP_RAY,false);
   ObjectSetText("Sup3","Down & Price_1 "+s3,10,"Times New Roman",Green);

   ObjectDelete("Res4");
   ObjectCreate("Res4",OBJ_HLINE,0,0,r4);
   ObjectSet("Res4",OBJPROP_COLOR,White);
   ObjectSet("Res4",OBJPROP_WIDTH,1);
   ObjectSet("Res4",OBJPROP_RAY,false);
   ObjectSetText("Res2","Up & Price_0 "+r4,10,"Times New Roman",Green);

   ObjectDelete("Sup4");
   ObjectCreate("Sup4",OBJ_HLINE,0,0,s4);
   ObjectSet("Sup4",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup4",OBJPROP_WIDTH,1);
   ObjectSet("Sup4",OBJPROP_RAY,false);
   ObjectSetText("Sup4","Down & Price_1 "+s4,10,"Times New Roman",Green);

   ObjectDelete("Res5");
   ObjectCreate("Res5",OBJ_HLINE,0,0,r5);
   ObjectSet("Res5",OBJPROP_COLOR,White);
   ObjectSet("Res5",OBJPROP_WIDTH,1);
   ObjectSet("Res5",OBJPROP_RAY,false);
   ObjectSetText("Res5","Up & Price_0 "+r5,10,"Times New Roman",Green);

   ObjectDelete("Sup5");
   ObjectCreate("Sup5",OBJ_HLINE,0,0,s5);
   ObjectSet("Sup5",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup5",OBJPROP_WIDTH,1);
   ObjectSet("Sup5",OBJPROP_RAY,false);
   ObjectSetText("Sup5","Down & Price_1 "+s5,10,"Times New Roman",Green);

//===
   ObjectDelete("Res6");
   ObjectCreate("Res6",OBJ_HLINE,0,0,r6);
   ObjectSet("Res6",OBJPROP_COLOR,White);
   ObjectSet("Res6",OBJPROP_WIDTH,1);
   ObjectSet("Res6",OBJPROP_RAY,false);
   ObjectSetText("Res6","Up & Price_0 "+r6,10,"Times New Roman",Green);

   ObjectDelete("Sup6");
   ObjectCreate("Sup6",OBJ_HLINE,0,0,s6);
   ObjectSet("Sup6",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup6",OBJPROP_WIDTH,1);
   ObjectSet("Sup6",OBJPROP_RAY,false);
   ObjectSetText("Sup6","Down & Price_1 "+s6,10,"Times New Roman",Green);

//
   ObjectDelete("Res7");
   ObjectCreate("Res7",OBJ_HLINE,0,0,r7);
   ObjectSet("Res7",OBJPROP_COLOR,White);
   ObjectSet("Res7",OBJPROP_WIDTH,1);
   ObjectSet("Res7",OBJPROP_RAY,false);
   ObjectSetText("Res7","Up & Price_0 "+r7,10,"Times New Roman",Green);

   ObjectDelete("Sup7");
   ObjectCreate("Sup7",OBJ_HLINE,0,0,s7);
   ObjectSet("Sup7",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup7",OBJPROP_WIDTH,1);
   ObjectSet("Sup7",OBJPROP_RAY,false);
   ObjectSetText("Sup7","Down & Price_1 "+s7,10,"Times New Roman",Green);
//
   ObjectDelete("Res8");
   ObjectCreate("Res8",OBJ_HLINE,0,0,r8);
   ObjectSet("Res8",OBJPROP_COLOR,White);
   ObjectSet("Res8",OBJPROP_WIDTH,1);
   ObjectSet("Res8",OBJPROP_RAY,false);
   ObjectSetText("Res8","Up & Price_0 "+r8,10,"Times New Roman",Green);

   ObjectDelete("Sup8");
   ObjectCreate("Sup8",OBJ_HLINE,0,0,s8);
   ObjectSet("Sup8",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup8",OBJPROP_WIDTH,1);
   ObjectSet("Sup8",OBJPROP_RAY,false);
   ObjectSetText("Sup8","Down & Price_1 "+s8,10,"Times New Roman",Green);

   ObjectDelete("Res9");
   ObjectCreate("Res9",OBJ_HLINE,0,0,r9);
   ObjectSet("Res9",OBJPROP_COLOR,White);
   ObjectSet("Res9",OBJPROP_WIDTH,1);
   ObjectSet("Res9",OBJPROP_RAY,false);
   ObjectSetText("Res9","Up & Price_0 "+r9,10,"Times New Roman",Green);

   ObjectDelete("Sup9");
   ObjectCreate("Sup9",OBJ_HLINE,0,0,s9);
   ObjectSet("Sup9",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup9",OBJPROP_WIDTH,1);
   ObjectSet("Sup9",OBJPROP_RAY,false);
   ObjectSetText("Sup9","Down & Price_1 "+s9,10,"Times New Roman",Green);

   ObjectDelete("Res10");
   ObjectCreate("Res10",OBJ_HLINE,0,0,r10);
   ObjectSet("Res10",OBJPROP_COLOR,White);
   ObjectSet("Res10",OBJPROP_WIDTH,1);
   ObjectSet("Res10",OBJPROP_RAY,false);
   ObjectSetText("Res10","Up & Price_0 "+r10,10,"Times New Roman",Green);

   ObjectDelete("Sup10");
   ObjectCreate("Sup10",OBJ_HLINE,0,0,s10);
   ObjectSet("Sup10",OBJPROP_COLOR,Yellow);
   ObjectSet("Sup10",OBJPROP_WIDTH,1);
   ObjectSet("Sup10",OBJPROP_RAY,false);
   ObjectSetText("Sup10","Down & Price_1 "+s10,10,"Times New Roman",Green);

   return(0);
  }
//+------------------------------------------------------------------+
