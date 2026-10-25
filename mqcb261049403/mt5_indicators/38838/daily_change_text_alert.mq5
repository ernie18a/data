//+------------------------------------------------------------------+
//|                                      Daily Change Text Alert.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property description " "
#property description "'Daily Change' on last 'Number of bars' candles"
#property description "Alert if 'Daily Change' limit reached"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- input parameters
input group             "Text Parameters"
input ENUM_BASE_CORNER     InpCorner               = CORNER_RIGHT_LOWER;// Chart corner for anchoring
input string               InpFont                 = "Lucida Console";  // Font
input int                  InpFontSize             = 12;                // Font size
input ENUM_ANCHOR_POINT    InpAnchor               = ANCHOR_RIGHT_LOWER;// Anchor type
input uchar                InpNumberOfBars         = 3;                 // Number of bars (do not use "0")
input color                InpColorBullish         = clrBlue;           // The color of bullish bars
input color                InpColorBearish         = clrRed;            // The color of bearish bars
input bool                 InpIndent               = true;              // Indent
input double               InpDailyLimit           = 1.0;               // Daily Limit Alert
input group             "Alerts"
input string               InpSoundName            = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions     = 3;           // Repetitions
input uchar                InpSoundPause           = 3;           // Pause, in seconds
input bool                 InpUseSound             = false;       // Use Sound
input bool                 InpAlert                = true;        // Alert
input bool                 InpMail                 = true;        // Send mail
input bool                 InpNotification         = true;        // Send notification
//---
string   m_prefix          = "Daily_Change_Text_"; // prefix for object
double   m_adjusted_point;                         // point value adjusted for 3 or 5 points
string   m_arr_names[];                            // array of names of objects OBJ_TEXT
//---
datetime m_last_sound      = 0;                    // "0" -> D'1970.01.01 00:00';
uchar    m_repetitions     = 0;                    //
string   m_text            = "";                   //
datetime m_prev_bars       = 0;                    // "0" -> D'1970.01.01 00:00';
bool     m_init_error      = false;                // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpNumberOfBars==0)
     {
      Print("\"Number of bars\"==0. Do not use \"0\"");
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
   if(Period()!=PERIOD_D1)
     {
      Print("Chart timeframe must be 'D1'!");
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   m_prefix+=EnumToString(Period())+"_";
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;
   m_adjusted_point=Point()*digits_adjust;
//---
   ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
   ResetLastError();
   if(ArrayResize(m_arr_names,InpNumberOfBars)==-1)
     {
      Print(__FUNCTION__," ArrayResize error");
      return(INIT_SUCCEEDED);
     }
   ArraySetAsSeries(m_arr_names,true);
   for(int i=0; i<InpNumberOfBars; i++)
     {
      m_arr_names[i]=m_prefix+"_"+IntegerToString(i);
      if(!TextCreate(0,m_arr_names[i],0,0,0.0,m_arr_names[i],90,InpFont,InpFontSize,InpColorBearish,ANCHOR_RIGHT))
        {
         ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
         return(INIT_SUCCEEDED);
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
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
   if(m_init_error)
      return(0);
   if(rates_total<=InpNumberOfBars)
      return(0);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---
   if(prev_calculated==0 || prev_calculated!=rates_total)
     {
      //--- create the texts
      int limit=ArraySize(m_arr_names)-1;
      for(int i=limit; i>=0; i--)
        {
         double dc=(close[i]-close[i+1])*100.0/close[i+1];
         string text=DoubleToString(dc,2)+"%";
         if(dc>0)
           {
            if(InpIndent)
               text=" "+text;
            if(!TextMove(0,m_arr_names[i],time[i],high[i]))
               return(0);
            if(!TextChange(0,m_arr_names[i],text,ANCHOR_LEFT,InpColorBullish))
               return(0);
           }
         else
           {
            if(InpIndent)
               text=text+" ";
            if(!TextMove(0,m_arr_names[i],time[i],low[i]))
               return(0);
            if(!TextChange(0,m_arr_names[i],text,ANCHOR_RIGHT,InpColorBearish))
               return(0);
           }
        }
      //---
      return(rates_total);
     }
//-- current bar
   int i=0;
   double dc=(close[i]-close[i+1])*100.0/close[i+1];
   string text=DoubleToString(dc,2)+"%";
   if(dc>0)
     {
      if(InpIndent)
         text=" "+text;
      if(!TextMove(0,m_arr_names[i],time[i],high[i]))
         return(0);
      if(!TextChange(0,m_arr_names[i],text,ANCHOR_LEFT,InpColorBullish))
         return(0);
     }
   else
     {
      if(InpIndent)
         text=text+" ";
      if(!TextMove(0,m_arr_names[i],time[i],low[i]))
         return(0);
      if(!TextChange(0,m_arr_names[i],text,ANCHOR_RIGHT,InpColorBearish))
         return(0);
     }
//--- alert
   if(time[rates_total-1]>m_prev_bars)
     {
      m_last_sound=0;
      m_prev_bars=time[rates_total-1];
      m_repetitions=0;
     }
   if(m_repetitions>=InpSoundRepetitions)
      return(rates_total);
   datetime time_current=TimeCurrent();
   if(time_current-m_last_sound>InpSoundPause)
     {
      if(dc>0.0 || dc>=InpDailyLimit)
        {
         if(InpUseSound)
            PlaySound(InpSoundName);
         m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Daily Change UP, "+TimeToString(time[i]);
         if(InpAlert)
            Alert(m_text);
         m_last_sound=time_current;
         m_repetitions++;
         //---
         if(InpMail)
           {
            SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
           }
         if(InpNotification)
           {
            SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
           }
        }
      else
         if(dc<0.0 || dc<=-InpDailyLimit)
           {
            if(InpUseSound)
               PlaySound(InpSoundName);
            m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Daily Change DOWN, "+TimeToString(time[i]);
            if(InpAlert)
               Alert(m_text);
            m_last_sound=time_current;
            m_repetitions++;
            //---
            if(InpMail)
              {
               SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
              }
            if(InpNotification)
              {
               SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
              }
           }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                const string            text="Text",              // the text itself
                const double            angle=90.0,               // text slope
                const string            font="Lucida Console",    // font
                const int               font_size=10,             // font size
                const color             clr=clrBlue,              // color
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,// anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,10);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the anchor point                                            |
//+------------------------------------------------------------------+
bool TextMove(const long   chart_ID=0,  // chart's ID
              const string name="Text", // object name
              datetime     time=0,      // anchor point time coordinate
              double       price=0)     // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool TextChange(const long   chart_ID=0,              // chart's ID
                const string name="Text",             // object name
                const string text="Text",             // text
                ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT, // anchor type
                const color  clr=clrBlue)             // color
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
