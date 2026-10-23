//+------------------------------------------------------------------+
//|                                                    LRDegrees.mq4 |
//|                           Copyright 2017, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "https://www.mql5.com/en/users/3rjfx. ~ By 3rjfx ~ Created: 2017/01/12"
#property link      "https://forge.mql5.io"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property strict
//--
#property description "MetaTrader 4 Forex Indicator Double Line of LinearRegression with Degrees and Trend Alerts."
//--
/* Update_01 (06/04/2017): 
   Update to fix a bug about the trend line does not update.
*/
//--
#property indicator_chart_window
#property indicator_buffers 4
//--
enum SetDegree
  {
    Line2,
    Line1
  };
//--
//---
input SetDegree           degress = Line2;         // Set Linear Degrees Line
input int          barsCountLine1 = 35;            // Linear Regression 1 Bars to count
input int          barsCountLine2 = 5;             // Linear Regression 2 Bars to count
input color          LRLineColor1 = clrRed;        // Linear Regression Line1 Color
input color          LRLineColor2 = clrBlue;       // Linear Regression Line2 Color
input color          RoundedColor = clrAqua;       // Rounded Color
input color              UpsColor = clrAqua;       // Arrow Up Color
input color              DnsColor = clrOrangeRed;  // Arrow Down Color
input color            PriceColor = clrSnow;       // Arrow Right Price  Color
input ENUM_LINE_STYLE LRLineStyle = STYLE_SOLID;   // Linear Regression Line style
input int             LRLineWidth = 2;             // Linear Regression Line width
//--
input bool              MsgAlerts = true;
input bool            SoundAlerts = true;
input bool            eMailAlerts = false;
input string       SoundAlertFile = "alert.wav";
//--
//--- buffers
double DegreesUp[];
double DegreesDn[];
double LRBuffers1[];
double LRBuffers2[];
//--
int corner=1;
int dist_x=144;
int dist_xt=104;
int dist_y=80;
//--
int cmal,xmal;
int posalert;
int prevalert;
int bar_count;
//--
color stgBull=clrBlue;
color stsBull=clrAqua;
color stsBear=clrYellow;
color stgBear=clrRed;
color txtrbl=clrWhite;
color txtblk=clrBlack;
color rndclr;
color arrclr;
color txtclr;
//--
long Chart_Id;
//--
string name;
string dtext;
string Albase,AlSubj,AlMsg;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator buffers mapping
//---
   Chart_Id=ChartID();
   bar_count=120;
   IndicatorShortName("LR Degrees ("+_Symbol+")");
   name="LR Degrees";
   IndicatorDigits(_Digits);
//--- indicator buffers mapping
   IndicatorBuffers(4);
   //---
   SetIndexBuffer(0,DegreesUp);
   SetIndexBuffer(1,DegreesDn);
   SetIndexBuffer(2,LRBuffers1);
   SetIndexBuffer(3,LRBuffers2);
//--- indicator lines
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
//--- indicator labels
   SetIndexLabel(0,"UpDegrees");
   SetIndexLabel(1,"DnDegrees");
   SetIndexLabel(2,"LR_Line1");
   SetIndexLabel(3,"LR_Line2");
   //--
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   //---
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   //--
   ObjectsDeleteAll();
   GlobalVariablesDeleteAll();
//----
   return;
  }
//---------//
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
//------
   if(rates_total<bar_count) return(0);
//------
//--- Set Last error value to Zero
   ResetLastError();
   ChartRedraw(0);
   //--
   int l,r,j,
       dtxt=0;
   //---
   bool dgrsUp=false;
   bool dgrsDn=false;
   //--
   double x,y,z,
          a,b,c;
   double sumy=0.0,
          sumx1=0.0,
          sumxy=0.0,
          sumx2=0.0;
   double suma=0.0,
          sumb1=0.0,
          sumab=0.0,
          sumb2=0.0;
   //--
   double hmax=0.0,
          lmin=0.0;
   //--
   double cur_degrees=0.0,
          prev1_degrees=0.0,
          prev2_degrees=0.0,
          div1_degrees=0.0,
          div0_degrees=0.0;
   //--
   //-- prepare the Highest and Lowest Price
   int HL=1+(int)WindowFirstVisibleBar();
   int Hi=iHighest(_Symbol,0,MODE_HIGH,HL,0);
   int Lo=iLowest(_Symbol,0,MODE_LOW,HL,0);
   if(Hi!=-1) hmax=high[Hi];
   if(Lo!=-1) lmin=low[Lo];
   //--
   double rangetb=(hmax-lmin);
   double toplevel1=lmin+(rangetb/1000*838);
   double toplevel2=lmin+(rangetb/1000*618);
   double midlevel=lmin+(rangetb/1000*500);
   double botlevel2=lmin+(rangetb/1000*382);
   double botlevel1=lmin+(rangetb/1000*162);
   //--
//----
   //--
   for(r=0; r<barsCountLine1; r++)
     {
      sumy+=iMA(_Symbol,0,1,0,MODE_LWMA,PRICE_WEIGHTED,r);
      sumxy+=iMA(_Symbol,0,1,0,MODE_LWMA,PRICE_WEIGHTED,r)*r;
      sumx1+=r;
      sumx2+=r*r;
     }
   //--
   x=sumx2*barsCountLine1-sumx1*sumx1;
   y=(sumxy*barsCountLine1-sumx1*sumy)/x;
   z=(sumy-sumx1*y)/barsCountLine1;
   //--
   //-- Linear regression MA trend 1
   for(l=0; l<barsCountLine1; l++) LRBuffers1[l]=z+y*l;
   //--
   for(j=0; j<barsCountLine2; j++)
     {
      suma+=iMA(_Symbol,0,1,0,MODE_LWMA,PRICE_WEIGHTED,j);
      sumab+=iMA(_Symbol,0,1,0,MODE_LWMA,PRICE_WEIGHTED,j)*j;
      sumb1+=j;
      sumb2+=j*j;
     }
   //--
   a=sumb2*barsCountLine2-sumb1*sumb1;
   b=(sumab*barsCountLine2-sumb1*suma)/a;
   c=(suma-sumb1*b)/barsCountLine2;
   //--
   //-- Linear regression MA trend 2
   for(l=0; l<barsCountLine2; l++) LRBuffers2[l]=c+b*l;
   //---
   for(int i=bar_count-1; i>=0; i--)
     {
       //--
       if(i==0)
         {
           switch(degress)
             {
               case 0:
                 {
                   cur_degrees=NormalizeDouble(270+(((LRBuffers2[0]-lmin)/(hmax-lmin))*180),2);
                   prev1_degrees=NormalizeDouble(270+(((LRBuffers2[1]-lmin)/(hmax-lmin))*180),2);
                   prev2_degrees=NormalizeDouble(270+(((LRBuffers2[2]-lmin)/(hmax-lmin))*180),2);
                   div1_degrees=prev1_degrees - prev2_degrees;
                   div0_degrees=cur_degrees - prev2_degrees;
                   break;
                 }
               //--
               case 1:
                 {
                   cur_degrees=NormalizeDouble(270+(((LRBuffers1[0]-lmin)/(hmax-lmin))*180),2);
                   prev1_degrees=NormalizeDouble(270+(((LRBuffers1[1]-lmin)/(hmax-lmin))*180),2);
                   prev2_degrees=NormalizeDouble(270+(((LRBuffers1[2]-lmin)/(hmax-lmin))*180),2);
                   div1_degrees=prev1_degrees - prev2_degrees;
                   div0_degrees=cur_degrees - prev2_degrees;
                   break;
                 }
             }
           //--
           if(cur_degrees>360.0) {cur_degrees=NormalizeDouble(cur_degrees-360.0,2);}
           if(cur_degrees==360.0) {cur_degrees=NormalizeDouble(0.0,2);}
           //- To give a value of 90.0 degrees to the indicator, when the price moves up very quickly and make a New Windows Price Max.
           if(cur_degrees==90.0) {cur_degrees=NormalizeDouble(90.0,2);}
           //- To give a value of 270.0 degrees to the indicator, when the price moves down very quickly and make a New Windows Price Min.
           if(cur_degrees==270.0) {cur_degrees=NormalizeDouble(270.0,2);}
           //--
           if(div0_degrees>div1_degrees) {dgrsUp=true; dgrsDn=false; DegreesUp[i]=cur_degrees; DegreesDn[i]=0.0;}
           if(div0_degrees<div1_degrees) {dgrsDn=true; dgrsUp=false; DegreesDn[i]=cur_degrees; DegreesUp[i]=0.0;}
           //---
           if((cur_degrees>=270.0 && cur_degrees<315.0)&&(dgrsDn==true)) {rndclr=stgBear; arrclr=stgBear; txtclr=txtrbl; posalert=11;}
           if((cur_degrees>=270.0 && cur_degrees<315.0)&&(dgrsUp==true)) {rndclr=stgBear; arrclr=stsBear; txtclr=txtrbl; posalert=12;}
           if((cur_degrees>=315.0 && cur_degrees<360.0)&&(dgrsDn==true)) {rndclr=stsBear; arrclr=stgBear; txtclr=txtblk; posalert=21;}
           if((cur_degrees>=315.0 && cur_degrees<360.0)&&(dgrsUp==true)) {rndclr=stsBear; arrclr=stsBull; txtclr=txtblk; posalert=23;}
           if((cur_degrees>=0.0 && cur_degrees<45.0)&&(dgrsUp==true)) {rndclr=stsBull; arrclr=stgBull; txtclr=txtblk; posalert=34;}
           if((cur_degrees>=0.0 && cur_degrees<45.0)&&(dgrsDn==true)) {rndclr=stsBull; arrclr=stsBear; txtclr=txtblk; posalert=32;}
           if((cur_degrees>=45.0 && cur_degrees<=90.0)&&(dgrsUp==true)) {rndclr=stgBull; arrclr=stgBull; txtclr=txtrbl; posalert=44;}
           if((cur_degrees>=45.0 && cur_degrees<=90.0)&&(dgrsDn==true)) {rndclr=stgBull; arrclr=stsBull; txtclr=txtrbl; posalert=43;}
           //---
           dtext=StringTrimRight(StringConcatenate(DoubleToStr(cur_degrees,1),"",CharToStr(176)));
           if(StringLen(dtext)>5) {dtxt=24;}
           else if(StringLen(dtext)==5) {dtxt=20;}
           else {dtxt=17;}
           //--
           //---
           CreateRoundDegrees(Chart_Id,"RoundedDegrees","Wingdings",CharToStr(108),67,rndclr,corner,dist_x,dist_y,true);
           //--
           CreateRoundDegrees(Chart_Id,"TextDegrees","Bodoni MT Black",dtext,8,txtclr,corner,dist_xt+dtxt,dist_y+41,true);    
           //--
           if(dgrsUp) 
              CreateArrowDegrees(Chart_Id,"ArrUpDegrees","ArrDnDegrees","Wingdings",CharToStr(217),23,arrclr,corner,dist_xt+20,dist_y-2,true);
           //--
           if(dgrsDn) 
              CreateArrowDegrees(Chart_Id,"ArrDnDegrees","ArrUpDegrees","Wingdings",CharToStr(218),23,arrclr,corner,dist_xt+20,dist_y+63,true);
           //---
           color clinear1=LRBuffers1[0]>=LRBuffers1[barsCountLine1-1] ? LRLineColor2 : LRLineColor1;
           CreateLRTrendLine(Chart_Id,"LRTrendLine1",time[0],LRBuffers1[0],time[barsCountLine1-1],LRBuffers1[barsCountLine1-1],
                             LRLineWidth,LRLineStyle,clinear1,false,true);
           //--
           color clinear2=LRBuffers2[0]>=LRBuffers2[barsCountLine2-1] ? LRLineColor2 : LRLineColor1;
           CreateLRTrendLine(Chart_Id,"LRTrendLine2",time[0],LRBuffers2[0],time[barsCountLine2-1],LRBuffers2[barsCountLine2-1],
                             LRLineWidth,LRLineStyle,clinear2,false,true);
           //--
           CreateArrowPrice(Chart_Id,"FiboLabelPrice_t1",time[0],toplevel1,PriceColor,STYLE_SOLID,1,ANCHOR_LEFT,true);
           //--
           CreateArrowPrice(Chart_Id,"FiboLabelPrice_t2",time[0],toplevel2,PriceColor,STYLE_SOLID,1,ANCHOR_LEFT,true);
           //--
           CreateArrowPrice(Chart_Id,"FiboLabelPrice_m",time[0],midlevel,PriceColor,STYLE_SOLID,1,ANCHOR_LEFT,true);
           //--
           CreateArrowPrice(Chart_Id,"FiboLabelPrice_b2",time[0],botlevel2,PriceColor,STYLE_SOLID,1,ANCHOR_LEFT,true);
           //--
           CreateArrowPrice(Chart_Id,"FiboLabelPrice_b1",time[0],botlevel1,PriceColor,STYLE_SOLID,1,ANCHOR_LEFT,true);
           //--
         }
     }
   //--
   ChartRedraw(0);
   Sleep(500);
   PosAlerts(posalert);
   //---
//--- done
   return(rates_total);
  }
//--- end OnCalculate()
//---------//

void CreateRoundDegrees(long   chartid, 
                        string lable_name, 
                        string lable_font_model,
                        string lable_obj_text,
                        int    lable_font_size,
                        color  lable_color,
                        int    lable_corner,
                        int    lable_xdist,
                        int    lable_ydist,
                        bool   lable_hidden)
  {  
    //--
    ObjectDelete(chartid,lable_name);
    //--
    ObjectCreate(chartid,lable_name,OBJ_LABEL,0,0,0,0,0); // create rounded degrees
    ObjectSetInteger(chartid,lable_name,OBJPROP_FONTSIZE,lable_font_size); 
    ObjectSetString(chartid,lable_name,OBJPROP_FONT,lable_font_model);
    ObjectSetString(chartid,lable_name,OBJPROP_TEXT,lable_obj_text);
    ObjectSetInteger(chartid,lable_name,OBJPROP_COLOR,lable_color);
    ObjectSetInteger(chartid,lable_name,OBJPROP_CORNER,lable_corner);
    ObjectSetInteger(chartid,lable_name,OBJPROP_XDISTANCE,lable_xdist);
    ObjectSetInteger(chartid,lable_name,OBJPROP_YDISTANCE,lable_ydist);
    ObjectSetInteger(chartid,lable_name,OBJPROP_HIDDEN,lable_hidden);
    //--
  }   
//---------//

void CreateArrowDegrees(long   chartid, 
                        string lable_name1,
                        string lable_name2,
                        string lable_font_model,
                        string lable_obj_text,
                        int    lable_font_size,
                        color  lable_color,
                        int    lable_corner,
                        int    lable_xdist,
                        int    lable_ydist,
                        bool   lable_hidden)
  {  
    //--
    ObjectDelete(chartid,lable_name2);
    ObjectDelete(chartid,lable_name1);
    //--
    ObjectCreate(chartid,lable_name1,OBJ_LABEL,0,0,0,0,0); // create arrow degrees
    ObjectSetInteger(chartid,lable_name1,OBJPROP_FONTSIZE,lable_font_size); 
    ObjectSetString(chartid,lable_name1,OBJPROP_FONT,lable_font_model);
    ObjectSetString(chartid,lable_name1,OBJPROP_TEXT,lable_obj_text);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_COLOR,lable_color);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_CORNER,lable_corner);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_XDISTANCE,lable_xdist);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_YDISTANCE,lable_ydist);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_HIDDEN,lable_hidden);
    //--
  }   
//---------//

void CreateLRTrendLine(long     chartid, 
                       string   line_name,
                       datetime line_time1,
                       double   line_price1,
                       datetime line_time2,
                       double   line_price2,
                       int      line_width,
                       int      line_style,
                       color    line_color,
                       bool     ray_right,
                       bool     line_hidden)
  {  
    //--
    ObjectDelete(chartid,line_name);
    //--
    ObjectCreate(chartid,line_name,OBJ_TREND,0,line_time1,line_price1,line_time2,line_price2); // create trend line
    ObjectSetInteger(chartid,line_name,OBJPROP_WIDTH,line_width);
    ObjectSetInteger(chartid,line_name,OBJPROP_STYLE,line_style);
    ObjectSetInteger(chartid,line_name,OBJPROP_COLOR,line_color);
    ObjectSetInteger(chartid,line_name,OBJPROP_RAY_RIGHT,ray_right);
    ObjectSetInteger(chartid,line_name,OBJPROP_HIDDEN,line_hidden);
    //--
  }   
//---------//

void CreateArrowPrice(long     chart_id,
                      string   arrow_name, 
                      datetime arrow_time,
                      double   arrow_pos,
                      color    arrow_color,
                      int      arrow_style,
                      int      arrow_width,
                      int      anchor,
                      bool     hidden)
  {
    //--
    ObjectDelete(chart_id,arrow_name);
    //--
    ObjectCreate(chart_id,arrow_name,OBJ_ARROW_RIGHT_PRICE,0,arrow_time,arrow_pos); // create arrow right price
    ObjectSetInteger(chart_id,arrow_name,OBJPROP_COLOR,arrow_color);
    ObjectSetInteger(chart_id,arrow_name,OBJPROP_STYLE,arrow_style);
    ObjectSetInteger(chart_id,arrow_name,OBJPROP_WIDTH,arrow_width);
    ObjectSetInteger(chart_id,arrow_name,OBJPROP_ANCHOR,anchor);
    ObjectSetInteger(chart_id,arrow_name,OBJPROP_HIDDEN,hidden);
    //--
  }
//---------//

void DoAlerts(string msgText,string eMailSub)
  {
     if (MsgAlerts) Alert(msgText);
     if (SoundAlerts) PlaySound(SoundAlertFile);
     if (eMailAlerts) SendMail(eMailSub,msgText);
  }
//---------//

string StrTF(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1: return("M1");
       case PERIOD_M5: return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1: return("H1");
       case PERIOD_H4: return("H4");
       case PERIOD_D1: return("D1");
       case PERIOD_W1: return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
  }  
//---------//

void PosAlerts(int curalerts)
   {
    //---
    cmal=Minute();
    if(cmal!=xmal)
      {
        //--
        if((curalerts!=prevalert)&&(curalerts==43))
          {
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend Began to Fall, Bulish Weakened";
            AlMsg=AlSubj+" @ "+TimeToStr(TimeLocal(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==32))
          {     
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Down, Bulish Reversal";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==21))
          {     
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Down, Bearish Strengthened";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }              
        //---
        if((curalerts!=prevalert)&&(curalerts==11))
          {     
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Down, Strong Bearish";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==12))
          {
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend Began to Rise, Bearish Weakened";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==23))
          {
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Up, Bearish Reversal";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==34))
          {
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Up, Bulish Strengthened";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==44))
          {
            Albase=name+" "+_Symbol+", TF: "+StrTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" Trend was Up, Strong Bulish";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //--
        xmal=cmal;
      }
    //---
    return;
   //----
   } //-end PosAlerts()
//---------//
//+------------------------------------------------------------------+