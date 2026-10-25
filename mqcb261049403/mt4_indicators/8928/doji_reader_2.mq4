//+------------------------------------------------------------------+
//|                                                Doji Reader 2.mq4 |
//|                               Copyright © 2009,  MQL PROGRAMMING |
//|                                  mailto:mqlprogramming@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009,  MQL PROGRAMMING"
#property link      "mailto:mqlprogramming@gmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 2


extern bool      AnAlert=true; //false to disable alert 
extern bool      ShowCandleBox=true; //false to hide the candle box
extern color     BoxColor=SkyBlue; //add your fav color 
extern bool      ShowStar=true; //false to hide star 
extern color     StarColor=NavajoWhite; //add your fav color 
extern int       StarWidth=2; //add width size of star 
extern bool      ShowText=true; //false to hide text 
extern color     FontColor=White; //add your fav color 
extern int       FontSize=8; //add font size 
extern bool      VerticalText=false; //add true to verticalize text 
extern bool      MyBrokerHas5Digits=false; //add true if use 5 decimals

//---- input parameters for regular doji
extern bool      FindRegularDoji=true; //false to disable
extern int       MinLengthOfUpTail=3; //candle with upper tail equal or more than this will show up
extern int       MinLengthOfLoTail=3; //candle with lower tail equal or more than this will show up
extern double    MaxLengthOfBody=1; //candle with body less or equal with this will show up
     
//---- input parameters for dragonfly doji
extern bool      FindDragonflyDoji=true; //false to disable
extern int       MaxLengthOfUpTail1=0; //candle with upper tail equal or more than this will show up
extern int       MinLengthOfLoTail1=3; //candle with lower tail equal or more than this will show up
extern double    MaxLengthOfBody1=1; //candle with body less or equal with this will show up

//---- input parameters for gravestone doji
extern bool      FindGravestoneDoji=true; //false to disable
extern int       MinLengthOfUpTail2=3; //candle with upper tail equal or more than this will show up
extern int       MaxLengthOfLoTail2=0; //candle with lower tail equal or more than this will show up
extern double    MaxLengthOfBody2=1; //candle with body less or equal with this will show up

//---- initialization for variables
int counter1=1, counter2=1, counter3=1;
string name1="Doji", name2="Dragonfly", name3="Gravestone";
bool sound1=false, sound2=false, sound3=false;
double H=0.0, L=0.0, C=0.0, O=0.0, pt=0, pt1=0, dis=0;
datetime T=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate(name1, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name1, OBJPROP_XDISTANCE, 15);
   ObjectSet(name1, OBJPROP_YDISTANCE, 21);
   ObjectSetText(name1, "Doji Reader 2, MQL PROGRAMMING", 8, "Tahoma", Gold);
   if(Digits<4) pt1=0.01;
   else pt1=0.0001;
   if(MyBrokerHas5Digits) 
     {
      if(Digits<4) pt=0.001;
      else pt=0.00001;
      switch (Period())
         {
          case 1: dis=10*pt1; break;
          case 5: dis=15*pt1; break;
          case 15: dis=25*pt1; break;
          case 30: dis=35*pt1; break;
          case 60: dis=45*pt1; break;
          case 240: dis=75*pt1; break;
          case 1440: dis=175*pt1; break;
          case 10080: dis=230*pt1; break;
          case 43200: dis=350*pt1; break;
         }
     }
   else 
     {
      pt=pt1;
      switch (Period())
         {
          case 1: dis=20*pt; break;
          case 5: dis=30*pt; break;
          case 15: dis=50*pt; break;
          case 30: dis=75*pt; break;
          case 60: dis=90*pt; break;
          case 240: dis=150*pt; break;
          case 1440: dis=350*pt; break;
          case 10080: dis=460*pt; break;
          case 43200: dis=700*pt; break;
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- delete all object 
   ObjectsDeleteAll(0, OBJ_LABEL);
   ObjectsDeleteAll(0, OBJ_TREND);
   ObjectsDeleteAll(0, OBJ_RECTANGLE);
   ObjectsDeleteAll(0, OBJ_ARROW);
   ObjectsDeleteAll(0, OBJ_TEXT);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   for(i=Bars-1; i>0; i--)
      {

       H=High[i]; L=Low[i]; C=Close[i]; O=Open[i];
       T=Time[i];
       if(FindRegularDoji)
         {
          if(H-C>=MinLengthOfUpTail*pt && C-L>=MinLengthOfLoTail*pt  && MathAbs(C-O)<=MaxLengthOfBody*pt) 
            {
             sound1=true; 
             if(ShowCandleBox) 
               {
                if(ObjectFind("box 1"+counter1)==-1)
                  {
                   ObjectCreate("box 1"+counter1, OBJ_RECTANGLE, 0, Time[i+1], High[i]+(MathMin(Open[i], Close[i])-Low[i])/2, Time[i-1], Low[i]-(MathMin(Open[i], Close[i])-Low[i])/2);
                   ObjectSet("box 1"+counter1, OBJPROP_COLOR, BoxColor);
                  }
               } 
             if(ShowStar)
               {
                if(ObjectFind("star 1"+counter1)==-1)
                  {
                   ObjectCreate("star 1"+counter1, OBJ_ARROW, 0, Time[i], High[i]+(MathMin(Open[i], Close[i])-Low[i])/2+dis, 0);
                   ObjectSet("star 1"+counter1, OBJPROP_ARROWCODE, 181);
                   ObjectSet("star 1"+counter1, OBJPROP_COLOR, StarColor);
                   ObjectSet("star 1"+counter1, OBJPROP_WIDTH, StarWidth);
                  }
               } 
             if(ShowText)
               {
                if(ObjectFind("txt 1"+counter1)==-1)
                  {
                   ObjectCreate("txt 1"+counter1, OBJ_TEXT, 0, Time[i], Low[i]-dis);
                   ObjectSetText("txt 1"+counter1, name1, FontSize, "Tahoma", FontColor);
                   if(VerticalText) ObjectSet("txt 1"+counter1, OBJPROP_ANGLE, 90);
                  }  
                }
              counter1++;
            }
         } 
       if(FindDragonflyDoji)
         {
          if(H-C<=MaxLengthOfUpTail1*pt && C-L>=MinLengthOfLoTail1*pt  && MathAbs(C-O)<=MaxLengthOfBody1*pt)
            {
             counter2++;
             sound2=true; 
             if(ShowCandleBox) 
               {
                if(ObjectFind("box 2"+counter2)==-1)
                  {
                   ObjectCreate("box 2"+counter2, OBJ_RECTANGLE, 0, Time[i+1], High[i]+(MathMin(Open[i], Close[i])-Low[i])/2, Time[i-1], Low[i]-(MathMin(Open[i], Close[i])-Low[i])/2);
                   ObjectSet("box 2"+counter2, OBJPROP_COLOR, BoxColor);
                  }
               } 
             if(ShowStar)
               {
                if(ObjectFind("star 2"+counter2)==-1)
                  {
                   ObjectCreate("star 2"+counter2, OBJ_ARROW, 0, Time[i], High[i]+(MathMin(Open[i], Close[i])-Low[i])/2+dis, 0);
                   ObjectSet("star 2"+counter2, OBJPROP_ARROWCODE, 181);
                   ObjectSet("star 2"+counter2, OBJPROP_COLOR, StarColor);
                   ObjectSet("star 2"+counter2, OBJPROP_WIDTH, StarWidth);
                  }
               } 
             if(ShowText)
               {
                if(ObjectFind("txt 2"+counter2)==-1)
                  {
                   ObjectCreate("txt 2"+counter2, OBJ_TEXT, 0, Time[i], Low[i]-dis);
                   ObjectSetText("txt 2"+counter2, name2, FontSize, "Tahoma", FontColor);
                   if(VerticalText) ObjectSet("txt 2"+counter2, OBJPROP_ANGLE, 90);
                  }  
                }
             }
         } 
       if(FindGravestoneDoji)
         {
          if(H-C>=MinLengthOfUpTail2*pt && C-L<=MaxLengthOfLoTail2*pt  && MathAbs(C-O)<=MaxLengthOfBody2*pt)
            {
             counter3++;
             sound3=true;
             if(ShowCandleBox) 
               {
                if(ObjectFind("box 3"+counter3)==-1)
                  {
                   ObjectCreate("box 3"+counter3, OBJ_RECTANGLE, 0, Time[i+1], High[i]+(MathMin(Open[i], Close[i])-Low[i])/2, Time[i-1], Low[i]-(High[i]-MathMax(Open[i], Close[i]))/2);
                   ObjectSet("box 3"+counter3, OBJPROP_COLOR, BoxColor);
                  }
               } 
             if(ShowStar)
               {
                if(ObjectFind("star 3"+counter3)==-1)
                  {
                   ObjectCreate("star 3"+counter3, OBJ_ARROW, 0, Time[i], High[i]+(MathMin(Open[i], Close[i])-Low[i])/3+dis, 0);
                   ObjectSet("star 3"+counter3, OBJPROP_ARROWCODE, 181);
                   ObjectSet("star 3"+counter3, OBJPROP_COLOR, StarColor);
                   ObjectSet("star 3"+counter3, OBJPROP_WIDTH, StarWidth);
                  }
               } 
             if(ShowText)
               {
                if(ObjectFind("txt 3"+counter3)==-1)
                  {
                   ObjectCreate("txt 3"+counter3, OBJ_TEXT, 0, Time[i], Low[i]-dis);
                   ObjectSetText("txt 3"+counter3, name3, FontSize, "Tahoma", FontColor);
                   if(VerticalText) ObjectSet("txt 3"+counter3, OBJPROP_ANGLE, 90);
                  }  
               }
            }
         } 
      } 
   if(!AnAlert) return(0);
   if(Volume[0]>1) return(0);
   H=High[1]; L=Low[1]; C=Close[1]; O=Open[1];
   if(FindRegularDoji)
     {
      if(H-C>=MinLengthOfUpTail*pt && C-L>=MinLengthOfLoTail*pt && MathAbs(C-O)<=MaxLengthOfBody*pt) 
        {   
         Alert("new regular doji at ",Symbol()," M",Period());
        }
     }
   if(FindDragonflyDoji)
     {
      if(H-C<=MaxLengthOfUpTail1*pt && C-L>=MinLengthOfLoTail1*pt  && MathAbs(C-O)<=MaxLengthOfBody1*pt)
        {
         Alert("new dragonfly doji at ",Symbol()," M",Period()); 
        }
     }
   if(FindGravestoneDoji)
     {
      if(H-C>=MinLengthOfUpTail2*pt && C-L<=MaxLengthOfLoTail2*pt  && MathAbs(C-O)<=MaxLengthOfBody2*pt)
        {  
         Alert("new gravestone doji at ",Symbol()," M",Period());
        }
     }             
   return(0);
  } //end of file 
//+------------------------------------------------------------------+