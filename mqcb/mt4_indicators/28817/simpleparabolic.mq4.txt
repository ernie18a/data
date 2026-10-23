//--------------------------------------------------------------------
// RSIPowerTrend.mq4
// Catch the rebound
//--------------------------------------------------------------------
#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    10
#property indicator_buffers 2      // Number of buffers
#property indicator_color1 Green    // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line
#property strict
#property version     "1.9"      // Current version of the Expert Advisor


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Buf_0[],Buf_1[];     // Declaring arrays (for indicator buffers)
string Color[2];

extern double Step          = 0.02;
extern double Maximum       = 0.2;
extern bool   Notif         = False;
extern bool   SendAlert     = True;
//--------------------------------------------------------------------
int init()                          // Special function init()
  {
   SetIndexBuffer(0,Buf_0);         // Assigning an array to a buffer
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2); // Line style
   SetIndexBuffer(1,Buf_1);         // Assigning an array to a buffer
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2); // Line style
   Color[1] = "Neutre";
   return (INIT_SUCCEEDED);                          // Exit the special funct. init()

  }
//--------------------------------------------------------------------
int start()                         // Special function start()
  {
   int i,                           // Bar index
       Counted_bars;                // Number of counted bars
//--------------------------------------------------------------------
   Counted_bars=IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;           // Index of the first uncounted
   double SAR;

   while(i>=0)                      // Loop for uncounted bars
     {

      SAR    = NormalizeDouble(iSAR(NULL,0,Step,Maximum,i),Digits);

      if(SAR <= Close[i])
        {
         Buf_0[i] = 5;
         Color[0] = "Green";
        }

      else
         if(SAR >= Close[i])
           {
            Color[0] = "Red";
            Buf_1[i] = 5;
           }

      i--;                          // Calculating index of the next bar
     }

   Comment("......................................................................\n"
           +"EASYADX @@@ 2018 \n"+ "AUTHOR : RAY LEPATRON \n" + "CONTACT : RAY.WAVETRADER@GMAIL.COM \n" + "Donate me (Bitcoin): 3Pjg1UYyJBsScjTmVrsEWx5tuRAV8m3sJp \n" + "......................................................................\n");

   if(aNewBarEVENT())
     {
      if(Color[0] != Color[1])
        {
         Color[1] = Color[0];
         Manager();
         if(Color[0] == "Green")
           {
            if(Notif)
               Notification("SimpleParabolic",Symbol(),"BUY SIGNAL");
            if(SendAlert)
               SendAlertto("SimpleParabolic",Symbol(),"BUY SIGNAL");
           }

         if(Color[0] == "Red")
           {
            if(Notif)
               Notification("SimpleParabolic",Symbol(),"SELL SIGNAL");
            if(SendAlert)
               SendAlertto("SimpleParabolic",Symbol(),"SELL SIGNAL");
           }
        }
     }


//--------------------------------------------------------------------
   return 0;                          // Exit the special funct. start()
  }
//--------------------------------------------------------------------//--------------------------------------------------------------------
void Manager()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==false)
         continue;

      if(OrderSymbol() == Symbol())
        {
         if((OrderType() == OP_BUY) && (NormalizeDouble(iSAR(NULL,0,Step,0.2,1),Digits) >  Close[1]))
           {
            if(Notif)
               Notification("OrderManager",Symbol(),"CLOSE BUY");
            if(SendAlert)
               SendAlertto("OrderManager",Symbol(),"CLOSE BUY");
           }
         else
            if((OrderType() == OP_SELL) && (NormalizeDouble(iSAR(NULL,0,Step,0.2,1),Digits) <  Close[1]))
              {
               if(Notif)
                  Notification("OrderManager",Symbol(),"CLOSE SELL");
               if(SendAlert)
                  SendAlertto("OrderManager",Symbol(),"CLOSE SELL");
              }
        }
     }
  }

// Notification
void Notification(string text,string devise, string signal)
  {
   SendNotification(text+" Signal sur "+devise+" : "+signal);
  }

//Alerte
void SendAlertto(string text,string devise, string signal)
  {
   Alert(text+" Signal sur "+devise+" : "+signal);
  }

//New Candle
bool aNewBarEVENT()
  {
   static  int anAlreadyObservedBarCOUNT = EMPTY;    // .INIT
   if(Bars > anAlreadyObservedBarCOUNT)              // .TEST
     {
      anAlreadyObservedBarCOUNT = Bars;     // .UPD
      return(true);                         // .ACK
     }
   return(false);                                    // .NACK
  }
//+------------------------------------------------------------------+
