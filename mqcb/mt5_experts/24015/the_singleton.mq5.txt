//+------------------------------------------------------------------+
//|  Provide a Singleton Example                                     |
//+------------------------------------------------------------------+
#property copyright   "Copyright © LukeB"
#property link        "https://www.mql5.com/en/users/lukeb"
#property description "MQL5 Singleton Example"
//+----------------------------------------------------------------------------------+
//| Singleton from Linux tutorial http://www.yolinux.com/TUTORIALS/C++Singleton.html |
//| adds a tick counter and display to show it is doing something                    }
//+----------------------------------------------------------------------------------+
class CYoLinux
  {
private:
   static CYoLinux  *m_yoLinux;          // Static pointer to the only instance of Exposure Manager
   int               m_tickCounter;      // A variable so we can have the object do something (Count)
   string            m_counterDisplay;   // A place to store a screen display object name; see it be created and destroyed
   CYoLinux()                            // Private Constructor to create Singleton object
     {
      m_tickCounter=0;                   // ensure initial value is zero
      m_counterDisplay="DisplayCounter"; // Store name for the Display Object
     };
   CYoLinux(CYoLinux const&){};          // Private Copy Constructor prevents copy of the object as part of Singleton pattern
   CYoLinux operator=(CYoLinux const&);  // Private Assignment Operator, prevents assignment as part of Singleton pattern
protected:
public:
   ~CYoLinux() // A Public Destructor for the CYoLinux class
     {
      int windowIndex=ObjectFind(ChartID(),m_counterDisplay); // Find which window the object is in (does it exist?)
      if(windowIndex>=0) // Window found with the object in it
        {
         ObjectDelete(ChartID(),m_counterDisplay); //  Destroy the object, as this is the destructor
        }
      m_yoLinux = NULL;
     }
   static CYoLinux *GetInstance() // A Static Function that will provide a pointer to 'this'
     {
      if(!m_yoLinux) // Does the private m_yoLinux pointer point or not?
        {
         m_yoLinux=new CYoLinux;     // Create Class Object on Demand, put the pointer in the pivate, static pointer
         if( m_yoLinux == NULL )     // this would be a catasrophic failure
          { 
            int err_code=GetLastError();
            string comment_string=__FUNCTION__+": CYoLinux Constructor failed, error: "+IntegerToString(err_code);
            Comment(comment_string); Print(comment_string);
          }
        }
      return(m_yoLinux);               // Return a pointer to the one and only object.
     }
   int GetTicks() // Get (and increment) the value of what is being counted
     {
      m_tickCounter++;                 // New request, increment the counter
      return(m_tickCounter);
     }
   void DisplayObject(string displayText,int xPos,int yPos,color textColor) // Another piece of something for the CYoLinux to do
     {
         static long chartID = ChartID();
         if ( ObjectFind(chartID,m_counterDisplay) < 0 )
          {
            ObjectCreate    (chartID, m_counterDisplay, OBJ_LABEL, 0,  0, 0);
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_FONTSIZE,  12);
            ObjectSetString (chartID, m_counterDisplay, OBJPROP_FONT,      "Times New Roman");
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_ANCHOR,    ANCHOR_LEFT_UPPER);
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_BACK,      true); 
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_SELECTED,  false); 
            ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_HIDDEN,    false);
          }
         ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_XDISTANCE, xPos );
         ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_YDISTANCE, yPos );
         ObjectSetInteger(chartID, m_counterDisplay, OBJPROP_COLOR,     textColor);
         ObjectSetString (chartID, m_counterDisplay, OBJPROP_TEXT,      displayText );
     }
  };
CYoLinux *CYoLinux::m_yoLinux=NULL;  // Initialize Global Pointer;
//+------------------------------------------------------------------+
//|     Initialization Function                                      |
//+------------------------------------------------------------------+
int OnInit()  // ENUM_INIT_RETCODE OnInit() works
  {
   ENUM_INIT_RETCODE init_result = INIT_SUCCEEDED;  // use the environments enum for valid return values
   EventSetTimer(1);        // Start a Timer
   return(init_result);     // Return an int, zero is no error on initiation
  }
//+------------------------------------------------------------------+
//|     De-initialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //  delete YoLinux::yoLinux;     // Cannot access private class member; will not work with a singleton
   delete CYoLinux::GetInstance();  // the Display object remains on the window without an explicit object delete
   EventKillTimer();                // Clean up the timer when the EA stops
  }
//+------------------------------------------------------------------+
//|   Timer Event Function                                           |
//+------------------------------------------------------------------+
void OnTimer()
  {
   //--- Count timer events
   // first use of CYoLinux::GetInstance() creates the object; the GetInstance() method returns a pointer to the object.
   int counter=CYoLinux::GetInstance().GetTicks();  // Get the value of the counter in the object
   string executionMsgText;
   StringConcatenate(executionMsgText,"Timer Counter = ",counter); // make a string to display
   CYoLinux::GetInstance().DisplayObject(executionMsgText,20,75,clrRed);  // Display on the chart
   ChartRedraw(ChartID());
  }
//+------------------------------------------------------------------+
//|    Quote processing function                                     |
//+------------------------------------------------------------------+
void OnTick()
  {
   /*
   //--- Count Quotes
   int counter=CYoLinux::GetInstance().GetTicks();  // Get the value of the counter in the object
   string executionMsgText;
   StringConcatenate(executionMsgText,"Tick Counter = ",counter); // A string to display
   CYoLinux::GetInstance().DisplayObject(executionMsgText,20,75,clrRed);  // Display on the window
   */
  }
//+------------------------------------------------------------------+
